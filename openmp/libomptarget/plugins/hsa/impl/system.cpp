/*===--------------------------------------------------------------------------
 *              ATMI (Asynchronous Task and Memory Interface)
 *
 * This file is distributed under the MIT License. See LICENSE.txt for details.
 *===------------------------------------------------------------------------*/
#include <gelf.h>
#include <libelf.h>

#include <cassert>
#include <cstdarg>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <set>
#include <string>

#include "internal.h"
#include "machine.h"
#include "realtimer.h"
#include "rt.h"

#include "msgpack.h"

using core::RealTimer;

#define msgpackErrorCheck(msg, status)                                         \
  if (status != 0) {                                                           \
    printf("[%s:%d] %s failed\n", __FILE__, __LINE__, #msg);                   \
    return HSA_STATUS_ERROR_INVALID_CODE_OBJECT;                               \
  } else {                                                                     \
  }

typedef unsigned char *address;
/*
 * Note descriptors.
 */
typedef struct {
  uint32_t n_namesz; /* Length of note's name. */
  uint32_t n_descsz; /* Length of note's value. */
  uint32_t n_type;   /* Type of note. */
  // then name
  // then padding, optional
  // then desc, at 4 byte alignment (not 8, despite being elf64)
} Elf_Note;

// The following include file and following structs/enums
// have been replicated on a per-use basis below. For example,
// llvm::AMDGPU::HSAMD::Kernel::Metadata has several fields,
// but we may care only about kernargSegmentSize_ for now, so
// we just include that field in our KernelMD implementation. We
// chose this approach to replicate in order to avoid forcing
// a dependency on LLVM_INCLUDE_DIR just to compile the runtime.
// #include "llvm/Support/AMDGPUMetadata.h"
// typedef llvm::AMDGPU::HSAMD::Metadata CodeObjectMD;
// typedef llvm::AMDGPU::HSAMD::Kernel::Metadata KernelMD;
// typedef llvm::AMDGPU::HSAMD::Kernel::Arg::Metadata KernelArgMD;
// using llvm::AMDGPU::HSAMD::AccessQualifier;
// using llvm::AMDGPU::HSAMD::AddressSpaceQualifier;
// using llvm::AMDGPU::HSAMD::ValueKind;
// using llvm::AMDGPU::HSAMD::ValueType;

enum class ArgField : uint8_t {
  Name = 0,
  TypeName = 1,
  Size = 2,
  Align = 3,
  ValueKind = 4,
  ValueType = 5,
  PointeeAlign = 6,
  AddrSpaceQual = 7,
  AccQual = 8,
  ActualAccQual = 9,
  IsConst = 10,
  IsRestrict = 11,
  IsVolatile = 12,
  IsPipe = 13,
  Offset = 14
};

static const std::map<std::string, ArgField> ArgFieldMap = {
    // v2
    {"Name", ArgField::Name},
    {"TypeName", ArgField::TypeName},
    {"Size", ArgField::Size},
    {"Align", ArgField::Align},
    {"ValueKind", ArgField::ValueKind},
    {"ValueType", ArgField::ValueType},
    {"PointeeAlign", ArgField::PointeeAlign},
    {"AddrSpaceQual", ArgField::AddrSpaceQual},
    {"AccQual", ArgField::AccQual},
    {"ActualAccQual", ArgField::ActualAccQual},
    {"IsConst", ArgField::IsConst},
    {"IsRestrict", ArgField::IsRestrict},
    {"IsVolatile", ArgField::IsVolatile},
    {"IsPipe", ArgField::IsPipe},
    // v3
    {".type_name", ArgField::TypeName},
    {".value_kind", ArgField::ValueKind},
    {".address_space", ArgField::AddrSpaceQual},
    {".is_const", ArgField::IsConst},
    {".offset", ArgField::Offset},
    {".size", ArgField::Size},
    {".value_type", ArgField::ValueType},
    {".name", ArgField::Name}};

class KernelArgMD {
 public:
  enum class ValueKind {
    HiddenGlobalOffsetX,
    HiddenGlobalOffsetY,
    HiddenGlobalOffsetZ,
    HiddenNone,
    HiddenPrintfBuffer,
    HiddenDefaultQueue,
    HiddenCompletionAction,
    HiddenMultiGridSyncArg,
    HiddenHostcallBuffer,
    Unknown
  };

  KernelArgMD()
      : name_(std::string()),
        typeName_(std::string()),
        size_(0),
        offset_(0),
        align_(0),
        valueKind_(ValueKind::Unknown) {}

  // fields
  std::string name_;
  std::string typeName_;
  uint32_t size_;
  uint32_t offset_;
  uint32_t align_;
  ValueKind valueKind_;
};

class KernelMD {
 public:
  KernelMD() : kernargSegmentSize_(0ull) {}

  // fields
  uint64_t kernargSegmentSize_;
};

static const std::map<std::string, KernelArgMD::ValueKind> ArgValueKind = {
    //    Including only those fields that are relevant to the runtime.
    //    {"ByValue", KernelArgMD::ValueKind::ByValue},
    //    {"GlobalBuffer", KernelArgMD::ValueKind::GlobalBuffer},
    //    {"DynamicSharedPointer",
    //    KernelArgMD::ValueKind::DynamicSharedPointer},
    //    {"Sampler", KernelArgMD::ValueKind::Sampler},
    //    {"Image", KernelArgMD::ValueKind::Image},
    //    {"Pipe", KernelArgMD::ValueKind::Pipe},
    //    {"Queue", KernelArgMD::ValueKind::Queue},
    {"HiddenGlobalOffsetX", KernelArgMD::ValueKind::HiddenGlobalOffsetX},
    {"HiddenGlobalOffsetY", KernelArgMD::ValueKind::HiddenGlobalOffsetY},
    {"HiddenGlobalOffsetZ", KernelArgMD::ValueKind::HiddenGlobalOffsetZ},
    {"HiddenNone", KernelArgMD::ValueKind::HiddenNone},
    {"HiddenPrintfBuffer", KernelArgMD::ValueKind::HiddenPrintfBuffer},
    {"HiddenDefaultQueue", KernelArgMD::ValueKind::HiddenDefaultQueue},
    {"HiddenCompletionAction", KernelArgMD::ValueKind::HiddenCompletionAction},
    {"HiddenMultiGridSyncArg", KernelArgMD::ValueKind::HiddenMultiGridSyncArg},
    {"HiddenHostcallBuffer", KernelArgMD::ValueKind::HiddenHostcallBuffer},
    // v3
    //    {"by_value", KernelArgMD::ValueKind::ByValue},
    //    {"global_buffer", KernelArgMD::ValueKind::GlobalBuffer},
    //    {"dynamic_shared_pointer",
    //    KernelArgMD::ValueKind::DynamicSharedPointer},
    //    {"sampler", KernelArgMD::ValueKind::Sampler},
    //    {"image", KernelArgMD::ValueKind::Image},
    //    {"pipe", KernelArgMD::ValueKind::Pipe},
    //    {"queue", KernelArgMD::ValueKind::Queue},
    {"hidden_global_offset_x", KernelArgMD::ValueKind::HiddenGlobalOffsetX},
    {"hidden_global_offset_y", KernelArgMD::ValueKind::HiddenGlobalOffsetY},
    {"hidden_global_offset_z", KernelArgMD::ValueKind::HiddenGlobalOffsetZ},
    {"hidden_none", KernelArgMD::ValueKind::HiddenNone},
    {"hidden_printf_buffer", KernelArgMD::ValueKind::HiddenPrintfBuffer},
    {"hidden_default_queue", KernelArgMD::ValueKind::HiddenDefaultQueue},
    {"hidden_completion_action",
     KernelArgMD::ValueKind::HiddenCompletionAction},
    {"hidden_multigrid_sync_arg",
     KernelArgMD::ValueKind::HiddenMultiGridSyncArg},
    {"hidden_hostcall_buffer", KernelArgMD::ValueKind::HiddenHostcallBuffer},
};

enum class CodePropField : uint8_t {
  KernargSegmentSize = 0,
  GroupSegmentFixedSize = 1,
  PrivateSegmentFixedSize = 2,
  KernargSegmentAlign = 3,
  WavefrontSize = 4,
  NumSGPRs = 5,
  NumVGPRs = 6,
  MaxFlatWorkGroupSize = 7,
  IsDynamicCallStack = 8,
  IsXNACKEnabled = 9,
  NumSpilledSGPRs = 10,
  NumSpilledVGPRs = 11
};

static const std::map<std::string, CodePropField> CodePropFieldMap = {
    {"KernargSegmentSize", CodePropField::KernargSegmentSize},
    {"GroupSegmentFixedSize", CodePropField::GroupSegmentFixedSize},
    {"PrivateSegmentFixedSize", CodePropField::PrivateSegmentFixedSize},
    {"KernargSegmentAlign", CodePropField::KernargSegmentAlign},
    {"WavefrontSize", CodePropField::WavefrontSize},
    {"NumSGPRs", CodePropField::NumSGPRs},
    {"NumVGPRs", CodePropField::NumVGPRs},
    {"MaxFlatWorkGroupSize", CodePropField::MaxFlatWorkGroupSize},
    {"IsDynamicCallStack", CodePropField::IsDynamicCallStack},
    {"IsXNACKEnabled", CodePropField::IsXNACKEnabled},
    {"NumSpilledSGPRs", CodePropField::NumSpilledSGPRs},
    {"NumSpilledVGPRs", CodePropField::NumSpilledVGPRs}};

// public variables -- TODO(ashwinma) move these to a runtime object?
atmi_machine_t g_atmi_machine;
ATLMachine g_atl_machine;

hsa_agent_t atl_cpu_agent;
hsa_ext_program_t atl_hsa_program;
hsa_region_t atl_hsa_primary_region;
hsa_region_t atl_gpu_kernarg_region;
std::vector<hsa_amd_memory_pool_t> atl_gpu_kernarg_pools;
hsa_region_t atl_cpu_kernarg_region;
hsa_agent_t atl_gpu_agent;
hsa_profile_t atl_gpu_agent_profile;

static std::vector<hsa_executable_t> g_executables;

std::map<std::string, std::string> KernelNameMap;
std::vector<std::map<std::string, atl_kernel_info_t> > KernelInfoTable;
std::vector<std::map<std::string, atl_symbol_info_t> > SymbolInfoTable;

static atl_dep_sync_t g_dep_sync_type =
    (atl_dep_sync_t)core::Runtime::getInstance().getDepSyncType();

RealTimer SignalAddTimer("Signal Time");
RealTimer HandleSignalTimer("Handle Signal Time");

RealTimer HandleSignalInvokeTimer("Handle Signal Invoke Time");
RealTimer TaskWaitTimer("Task Wait Time");
RealTimer TryLaunchTimer("Launch Time");
RealTimer ParamsInitTimer("Params Init Time");
RealTimer TryLaunchInitTimer("Launch Init Time");
RealTimer ShouldDispatchTimer("Dispatch Eval Time");
RealTimer RegisterCallbackTimer("Register Callback Time");
RealTimer LockTimer("Lock/Unlock Time");
RealTimer TryDispatchTimer("Dispatch Time");
size_t max_ready_queue_sz = 0;
size_t waiting_count = 0;
size_t direct_dispatch = 0;
size_t callback_dispatch = 0;

bool g_atmi_initialized = false;
bool g_atmi_hostcall_required = false;

struct timespec context_init_time;
int context_init_time_init = 0;

/*
   All global values are defined here in one data structure.

   atlc is all internal global values.
   The structure atl_context_t is defined in atl_internal.h
   Most references will use the global structure prefix atlc.
   However the pointer value atlc_p-> is equivalent to atlc.

*/

atl_context_t atlc = {.struct_initialized = false};
atl_context_t *atlc_p = NULL;

hsa_signal_t IdentityORSignal;
hsa_signal_t IdentityANDSignal;
hsa_signal_t IdentityCopySignal;

namespace core {
/* Machine Info */
atmi_machine_t *Runtime::GetMachineInfo() {
  if (!atlc.g_hsa_initialized) return NULL;
  return &g_atmi_machine;
}

void atl_set_atmi_initialized() {
  // FIXME: thread safe? locks?
  g_atmi_initialized = true;
}

void atl_reset_atmi_initialized() {
  // FIXME: thread safe? locks?
  g_atmi_initialized = false;
}

bool atl_is_atmi_initialized() { return g_atmi_initialized; }

void allow_access_to_all_gpu_agents(void *ptr) {
  hsa_status_t err;
  std::vector<ATLGPUProcessor> &gpu_procs =
      g_atl_machine.processors<ATLGPUProcessor>();
  std::vector<hsa_agent_t> agents;
  for (uint32_t i = 0; i < gpu_procs.size(); i++) {
    agents.push_back(gpu_procs[i].agent());
  }
  err = hsa_amd_agents_allow_access(agents.size(), &agents[0], NULL, ptr);
  ErrorCheck(Allow agents ptr access, err);
}

atmi_status_t Runtime::Initialize(atmi_devtype_t devtype) {
  if (atl_is_atmi_initialized()) return ATMI_STATUS_SUCCESS;

  if (devtype == ATMI_DEVTYPE_ALL || devtype & ATMI_DEVTYPE_GPU) {
    ATMIErrorCheck(GPU context init, atl_init_gpu_context());
  }

  if (devtype == ATMI_DEVTYPE_ALL || devtype & ATMI_DEVTYPE_CPU) {
    ATMIErrorCheck(CPU context init, atl_init_cpu_context());
  }

  // create default taskgroup obj
  atmi_taskgroup_handle_t tghandle;
  ATMIErrorCheck(Create default taskgroup, TaskGroupCreate(&tghandle));

  atl_set_atmi_initialized();
  return ATMI_STATUS_SUCCESS;
}

atmi_status_t Runtime::Finalize() {
  // TODO(ashwinma): Finalize all processors, queues, signals, kernarg memory
  // regions
  hsa_status_t err;

  for (uint32_t i = 0; i < g_executables.size(); i++) {
    err = hsa_executable_destroy(g_executables[i]);
    ErrorCheck(Destroying executable, err);
  }
  if (atlc.g_cpu_initialized == true) {
    agent_fini();
    atlc.g_cpu_initialized = false;
  }

  // Finalize queues
  for (auto &p : g_atl_machine.processors<ATLCPUProcessor>()) {
    p.destroyQueues();
  }
  for (auto &p : g_atl_machine.processors<ATLGPUProcessor>()) {
    p.destroyQueues();
  }

  for (uint32_t i = 0; i < SymbolInfoTable.size(); i++) {
    SymbolInfoTable[i].clear();
  }
  SymbolInfoTable.clear();
  for (uint32_t i = 0; i < KernelInfoTable.size(); i++) {
    KernelInfoTable[i].clear();
  }
  KernelInfoTable.clear();

  atl_reset_atmi_initialized();
  err = hsa_shut_down();
  ErrorCheck(Shutting down HSA, err);
  std::cout << ParamsInitTimer;
  std::cout << ParamsInitTimer;
  std::cout << TryLaunchTimer;
  std::cout << TryLaunchInitTimer;
  std::cout << ShouldDispatchTimer;
  std::cout << TryDispatchTimer;
  std::cout << TaskWaitTimer;
  std::cout << LockTimer;
  std::cout << HandleSignalTimer;
  std::cout << RegisterCallbackTimer;

  ParamsInitTimer.reset();
  TryLaunchTimer.reset();
  TryLaunchInitTimer.reset();
  ShouldDispatchTimer.reset();
  HandleSignalTimer.reset();
  HandleSignalInvokeTimer.reset();
  TryDispatchTimer.reset();
  LockTimer.reset();
  RegisterCallbackTimer.reset();
  max_ready_queue_sz = 0;
  waiting_count = 0;
  direct_dispatch = 0;
  callback_dispatch = 0;

  return ATMI_STATUS_SUCCESS;
}

void atmi_init_context_structs() {
  atlc_p = &atlc;
  atlc.struct_initialized = true; /* This only gets called one time */
  atlc.g_cpu_initialized = false;
  atlc.g_hsa_initialized = false;
  atlc.g_gpu_initialized = false;
  atlc.g_tasks_initialized = false;
}

atmi_status_t atl_init_context() {
  atl_init_gpu_context();
  atl_init_cpu_context();

  return ATMI_STATUS_SUCCESS;
}

// Implement memory_pool iteration function
static hsa_status_t get_memory_pool_info(hsa_amd_memory_pool_t memory_pool,
                                         void *data) {
  ATLProcessor *proc = reinterpret_cast<ATLProcessor *>(data);
  hsa_status_t err = HSA_STATUS_SUCCESS;
  // Check if the memory_pool is allowed to allocate, i.e. do not return group
  // memory
  bool alloc_allowed = false;
  err = hsa_amd_memory_pool_get_info(
      memory_pool, HSA_AMD_MEMORY_POOL_INFO_RUNTIME_ALLOC_ALLOWED,
      &alloc_allowed);
  ErrorCheck(Alloc allowed in memory pool check, err);
  if (alloc_allowed) {
    uint32_t global_flag = 0;
    err = hsa_amd_memory_pool_get_info(
        memory_pool, HSA_AMD_MEMORY_POOL_INFO_GLOBAL_FLAGS, &global_flag);
    ErrorCheck(Get memory pool info, err);
    if (HSA_AMD_MEMORY_POOL_GLOBAL_FLAG_FINE_GRAINED & global_flag) {
      ATLMemory new_mem(memory_pool, *proc, ATMI_MEMTYPE_FINE_GRAINED);
      proc->addMemory(new_mem);
      if (HSA_AMD_MEMORY_POOL_GLOBAL_FLAG_KERNARG_INIT & global_flag) {
        DEBUG_PRINT("GPU kernel args pool handle: %lu\n", memory_pool.handle);
        atl_gpu_kernarg_pools.push_back(memory_pool);
      }
    } else {
      ATLMemory new_mem(memory_pool, *proc, ATMI_MEMTYPE_COARSE_GRAINED);
      proc->addMemory(new_mem);
    }
  }

  return err;
}

static hsa_status_t get_agent_info(hsa_agent_t agent, void *data) {
  hsa_status_t err = HSA_STATUS_SUCCESS;
  hsa_device_type_t device_type;
  err = hsa_agent_get_info(agent, HSA_AGENT_INFO_DEVICE, &device_type);
  ErrorCheck(Get device type info, err);
  switch (device_type) {
    case HSA_DEVICE_TYPE_CPU: {
      ;
      ATLCPUProcessor new_proc(agent);
      err = hsa_amd_agent_iterate_memory_pools(agent, get_memory_pool_info,
                                               &new_proc);
      ErrorCheck(Iterate all memory pools, err);
      g_atl_machine.addProcessor(new_proc);
    } break;
    case HSA_DEVICE_TYPE_GPU: {
      ;
      hsa_profile_t profile;
      err = hsa_agent_get_info(agent, HSA_AGENT_INFO_PROFILE, &profile);
      ErrorCheck(Query the agent profile, err);
      atmi_devtype_t gpu_type;
      gpu_type =
          (profile == HSA_PROFILE_FULL) ? ATMI_DEVTYPE_iGPU : ATMI_DEVTYPE_dGPU;
      ATLGPUProcessor new_proc(agent, gpu_type);
      err = hsa_amd_agent_iterate_memory_pools(agent, get_memory_pool_info,
                                               &new_proc);
      ErrorCheck(Iterate all memory pools, err);
      g_atl_machine.addProcessor(new_proc);
    } break;
    case HSA_DEVICE_TYPE_DSP: {
      err = HSA_STATUS_ERROR_INVALID_CODE_OBJECT;
    } break;
  }

  return err;
}

hsa_status_t get_fine_grained_region(hsa_region_t region, void *data) {
  hsa_region_segment_t segment;
  hsa_region_get_info(region, HSA_REGION_INFO_SEGMENT, &segment);
  if (segment != HSA_REGION_SEGMENT_GLOBAL) {
    return HSA_STATUS_SUCCESS;
  }
  hsa_region_global_flag_t flags;
  hsa_region_get_info(region, HSA_REGION_INFO_GLOBAL_FLAGS, &flags);
  if (flags & HSA_REGION_GLOBAL_FLAG_FINE_GRAINED) {
    hsa_region_t *ret = reinterpret_cast<hsa_region_t *>(data);
    *ret = region;
    return HSA_STATUS_INFO_BREAK;
  }
  return HSA_STATUS_SUCCESS;
}

/* Determines if a memory region can be used for kernarg allocations.  */
static hsa_status_t get_kernarg_memory_region(hsa_region_t region, void *data) {
  hsa_region_segment_t segment;
  hsa_region_get_info(region, HSA_REGION_INFO_SEGMENT, &segment);
  if (HSA_REGION_SEGMENT_GLOBAL != segment) {
    return HSA_STATUS_SUCCESS;
  }

  hsa_region_global_flag_t flags;
  hsa_region_get_info(region, HSA_REGION_INFO_GLOBAL_FLAGS, &flags);
  if (flags & HSA_REGION_GLOBAL_FLAG_KERNARG) {
    hsa_region_t *ret = reinterpret_cast<hsa_region_t *>(data);
    *ret = region;
    return HSA_STATUS_INFO_BREAK;
  }

  return HSA_STATUS_SUCCESS;
}

hsa_status_t init_comute_and_memory() {
  hsa_status_t err;

  /* Iterate over the agents and pick the gpu agent */
  err = hsa_iterate_agents(get_agent_info, NULL);
  if (err == HSA_STATUS_INFO_BREAK) {
    err = HSA_STATUS_SUCCESS;
  }
  ErrorCheck(Getting a gpu agent, err);
  if (err != HSA_STATUS_SUCCESS) return err;

  /* Init all devices or individual device types? */
  std::vector<ATLCPUProcessor> &cpu_procs =
      g_atl_machine.processors<ATLCPUProcessor>();
  std::vector<ATLGPUProcessor> &gpu_procs =
      g_atl_machine.processors<ATLGPUProcessor>();
  /* For CPU memory pools, add other devices that can access them directly
   * or indirectly */
  for (auto &cpu_proc : cpu_procs) {
    for (auto &cpu_mem : cpu_proc.memories()) {
      hsa_amd_memory_pool_t pool = cpu_mem.memory();
      for (auto &gpu_proc : gpu_procs) {
        hsa_agent_t agent = gpu_proc.agent();
        hsa_amd_memory_pool_access_t access;
        hsa_amd_agent_memory_pool_get_info(
            agent, pool, HSA_AMD_AGENT_MEMORY_POOL_INFO_ACCESS, &access);
        if (access != 0) {
          // this means not NEVER, but could be YES or NO
          // add this memory pool to the proc
          gpu_proc.addMemory(cpu_mem);
        }
      }
    }
  }

  /* FIXME: are the below combinations of procs and memory pools needed?
   * all to all compare procs with their memory pools and add those memory
   * pools that are accessible by the target procs */
  for (auto &gpu_proc : gpu_procs) {
    for (auto &gpu_mem : gpu_proc.memories()) {
      hsa_amd_memory_pool_t pool = gpu_mem.memory();
      for (auto &cpu_proc : cpu_procs) {
        hsa_agent_t agent = cpu_proc.agent();
        hsa_amd_memory_pool_access_t access;
        hsa_amd_agent_memory_pool_get_info(
            agent, pool, HSA_AMD_AGENT_MEMORY_POOL_INFO_ACCESS, &access);
        if (access != 0) {
          // this means not NEVER, but could be YES or NO
          // add this memory pool to the proc
          cpu_proc.addMemory(gpu_mem);
        }
      }
    }
  }

  g_atmi_machine.device_count_by_type[ATMI_DEVTYPE_CPU] = cpu_procs.size();
  g_atmi_machine.device_count_by_type[ATMI_DEVTYPE_GPU] = gpu_procs.size();

  size_t num_procs = cpu_procs.size() + gpu_procs.size();
  // g_atmi_machine.devices = (atmi_device_t *)malloc(num_procs *
  // sizeof(atmi_device_t));
  atmi_device_t *all_devices = reinterpret_cast<atmi_device_t *>(
      malloc(num_procs * sizeof(atmi_device_t)));
  int num_iGPUs = 0;
  int num_dGPUs = 0;
  for (uint32_t i = 0; i < gpu_procs.size(); i++) {
    if (gpu_procs[i].type() == ATMI_DEVTYPE_iGPU)
      num_iGPUs++;
    else
      num_dGPUs++;
  }
  assert(num_iGPUs + num_dGPUs == gpu_procs.size() &&
         "Number of dGPUs and iGPUs do not add up");
  DEBUG_PRINT("CPU Agents: %lu\n", cpu_procs.size());
  DEBUG_PRINT("iGPU Agents: %d\n", num_iGPUs);
  DEBUG_PRINT("dGPU Agents: %d\n", num_dGPUs);
  DEBUG_PRINT("GPU Agents: %lu\n", gpu_procs.size());

  g_atmi_machine.device_count_by_type[ATMI_DEVTYPE_iGPU] = num_iGPUs;
  g_atmi_machine.device_count_by_type[ATMI_DEVTYPE_dGPU] = num_dGPUs;

  int cpus_begin = 0;
  int cpus_end = cpu_procs.size();
  int gpus_begin = cpu_procs.size();
  int gpus_end = cpu_procs.size() + gpu_procs.size();
  g_atmi_machine.devices_by_type[ATMI_DEVTYPE_CPU] = &all_devices[cpus_begin];
  g_atmi_machine.devices_by_type[ATMI_DEVTYPE_GPU] = &all_devices[gpus_begin];
  g_atmi_machine.devices_by_type[ATMI_DEVTYPE_iGPU] = &all_devices[gpus_begin];
  g_atmi_machine.devices_by_type[ATMI_DEVTYPE_dGPU] = &all_devices[gpus_begin];
  int proc_index = 0;
  for (int i = cpus_begin; i < cpus_end; i++) {
    all_devices[i].type = cpu_procs[proc_index].type();
    all_devices[i].core_count = cpu_procs[proc_index].num_cus();

    std::vector<ATLMemory> memories = cpu_procs[proc_index].memories();
    int fine_memories_size = 0;
    int coarse_memories_size = 0;
    DEBUG_PRINT("CPU memory types:\t");
    for (auto &memory : memories) {
      atmi_memtype_t type = memory.type();
      if (type == ATMI_MEMTYPE_FINE_GRAINED) {
        fine_memories_size++;
        DEBUG_PRINT("Fine\t");
      } else {
        coarse_memories_size++;
        DEBUG_PRINT("Coarse\t");
      }
    }
    DEBUG_PRINT("\nFine Memories : %d", fine_memories_size);
    DEBUG_PRINT("\tCoarse Memories : %d\n", coarse_memories_size);
    all_devices[i].memory_count = memories.size();
    proc_index++;
  }
  proc_index = 0;
  for (int i = gpus_begin; i < gpus_end; i++) {
    all_devices[i].type = gpu_procs[proc_index].type();
    all_devices[i].core_count = gpu_procs[proc_index].num_cus();

    std::vector<ATLMemory> memories = gpu_procs[proc_index].memories();
    int fine_memories_size = 0;
    int coarse_memories_size = 0;
    DEBUG_PRINT("GPU memory types:\t");
    for (auto &memory : memories) {
      atmi_memtype_t type = memory.type();
      if (type == ATMI_MEMTYPE_FINE_GRAINED) {
        fine_memories_size++;
        DEBUG_PRINT("Fine\t");
      } else {
        coarse_memories_size++;
        DEBUG_PRINT("Coarse\t");
      }
    }
    DEBUG_PRINT("\nFine Memories : %d", fine_memories_size);
    DEBUG_PRINT("\tCoarse Memories : %d\n", coarse_memories_size);
    all_devices[i].memory_count = memories.size();
    proc_index++;
  }
  proc_index = 0;
  atl_cpu_kernarg_region.handle = (uint64_t)-1;
  if (cpu_procs.size() > 0) {
    err = hsa_agent_iterate_regions(
        cpu_procs[0].agent(), get_fine_grained_region, &atl_cpu_kernarg_region);
    if (err == HSA_STATUS_INFO_BREAK) {
      err = HSA_STATUS_SUCCESS;
    }
    err = (atl_cpu_kernarg_region.handle == (uint64_t)-1) ? HSA_STATUS_ERROR
                                                          : HSA_STATUS_SUCCESS;
    ErrorCheck(Finding a CPU kernarg memory region handle, err);
  }
  /* Find a memory region that supports kernel arguments.  */
  atl_gpu_kernarg_region.handle = (uint64_t)-1;
  if (gpu_procs.size() > 0) {
    hsa_agent_iterate_regions(gpu_procs[0].agent(), get_kernarg_memory_region,
                              &atl_gpu_kernarg_region);
    err = (atl_gpu_kernarg_region.handle == (uint64_t)-1) ? HSA_STATUS_ERROR
                                                          : HSA_STATUS_SUCCESS;
    ErrorCheck(Finding a kernarg memory region, err);
  }
  if (num_procs > 0)
    return HSA_STATUS_SUCCESS;
  else
    return HSA_STATUS_ERROR_NOT_INITIALIZED;
}

hsa_status_t init_hsa() {
  if (atlc.g_hsa_initialized == false) {
    DEBUG_PRINT("Initializing HSA...");
    hsa_status_t err = hsa_init();
    ErrorCheck(Initializing the hsa runtime, err);
    if (err != HSA_STATUS_SUCCESS) return err;

    err = init_comute_and_memory();
    if (err != HSA_STATUS_SUCCESS) return err;
    ErrorCheck(After initializing compute and memory, err);
    init_dag_scheduler();

    int gpu_count = g_atl_machine.processorCount<ATLGPUProcessor>();
    KernelInfoTable.resize(gpu_count);
    SymbolInfoTable.resize(gpu_count);
    for (uint32_t i = 0; i < SymbolInfoTable.size(); i++)
      SymbolInfoTable[i].clear();
    for (uint32_t i = 0; i < KernelInfoTable.size(); i++)
      KernelInfoTable[i].clear();
    atlc.g_hsa_initialized = true;
    DEBUG_PRINT("done\n");
  }
  return HSA_STATUS_SUCCESS;
}

void init_tasks() {
  if (atlc.g_tasks_initialized != false) return;
  hsa_status_t err;
  int task_num;
  std::vector<hsa_agent_t> gpu_agents;
  int gpu_count = g_atl_machine.processorCount<ATLGPUProcessor>();
  for (int gpu = 0; gpu < gpu_count; gpu++) {
    atmi_place_t place = ATMI_PLACE_GPU(0, gpu);
    ATLGPUProcessor &proc = get_processor<ATLGPUProcessor>(place);
    gpu_agents.push_back(proc.agent());
  }
  int max_signals = core::Runtime::getInstance().getMaxSignals();
  for (task_num = 0; task_num < max_signals; task_num++) {
    hsa_signal_t new_signal;
    // For ATL_SYNC_CALLBACK, we need host to be interrupted
    // upon task completion to resolve dependencies on the host.
    // For ATL_SYNC_BARRIER_PKT, since barrier packets resolve
    // dependencies within the GPU, they can be just agent signals
    // without host interrupts.
    // TODO(ashwinma): for barrier packet with host tasks, should we create
    // a separate list of free signals?
    if (g_dep_sync_type == ATL_SYNC_CALLBACK)
      err = hsa_signal_create(0, 0, NULL, &new_signal);
    else
      err = hsa_signal_create(0, gpu_count, &gpu_agents[0], &new_signal);
    ErrorCheck(Creating a HSA signal, err);
    FreeSignalPool.push(new_signal);
  }
  err = hsa_signal_create(1, 0, NULL, &IdentityORSignal);
  ErrorCheck(Creating a HSA signal, err);
  err = hsa_signal_create(0, 0, NULL, &IdentityANDSignal);
  ErrorCheck(Creating a HSA signal, err);
  err = hsa_signal_create(0, 0, NULL, &IdentityCopySignal);
  ErrorCheck(Creating a HSA signal, err);
  DEBUG_PRINT("Signal Pool Size: %lu\n", FreeSignalPool.size());
  atlc.g_tasks_initialized = true;
}

hsa_status_t callbackEvent(const hsa_amd_event_t *event, void *data) {
#if (ROCM_VERSION_MAJOR >= 3) || \
    (ROCM_VERSION_MAJOR >= 2 && ROCM_VERSION_MINOR >= 3)
  if (event->event_type == HSA_AMD_GPU_MEMORY_FAULT_EVENT) {
#else
  if (event->event_type == GPU_MEMORY_FAULT_EVENT) {
#endif
    hsa_amd_gpu_memory_fault_info_t memory_fault = event->memory_fault;
    // memory_fault.agent
    // memory_fault.virtual_address
    // memory_fault.fault_reason_mask
    // fprintf("[GPU Error at %p: Reason is ", memory_fault.virtual_address);
    std::stringstream stream;
    stream << std::hex << (uintptr_t)memory_fault.virtual_address;
    std::string addr("0x" + stream.str());

    std::string err_string = "[GPU Memory Error] Addr: " + addr;
    err_string += " Reason: ";
    if (!(memory_fault.fault_reason_mask & 0x00111111)) {
      err_string += "No Idea! ";
    } else {
      if (memory_fault.fault_reason_mask & 0x00000001)
        err_string += "Page not present or supervisor privilege. ";
      if (memory_fault.fault_reason_mask & 0x00000010)
        err_string += "Write access to a read-only page. ";
      if (memory_fault.fault_reason_mask & 0x00000100)
        err_string += "Execute access to a page marked NX. ";
      if (memory_fault.fault_reason_mask & 0x00001000)
        err_string += "Host access only. ";
      if (memory_fault.fault_reason_mask & 0x00010000)
        err_string += "ECC failure (if supported by HW). ";
      if (memory_fault.fault_reason_mask & 0x00100000)
        err_string += "Can't determine the exact fault address. ";
    }
    fprintf(stderr, "%s\n", err_string.c_str());
    return HSA_STATUS_ERROR;
  }
  return HSA_STATUS_SUCCESS;
}

atmi_status_t atl_init_gpu_context() {
  if (atlc.struct_initialized == false) atmi_init_context_structs();
  if (atlc.g_gpu_initialized != false) return ATMI_STATUS_SUCCESS;

  hsa_status_t err;
  err = init_hsa();
  if (err != HSA_STATUS_SUCCESS) return ATMI_STATUS_ERROR;

  int gpu_count = g_atl_machine.processorCount<ATLGPUProcessor>();
  for (int gpu = 0; gpu < gpu_count; gpu++) {
    atmi_place_t place = ATMI_PLACE_GPU(0, gpu);
    ATLGPUProcessor &proc = get_processor<ATLGPUProcessor>(place);
    int num_gpu_queues = core::Runtime::getInstance().getNumGPUQueues();
    if (num_gpu_queues == -1) {
      num_gpu_queues = proc.num_cus();
      num_gpu_queues = (num_gpu_queues > 8) ? 8 : num_gpu_queues;
    }
    proc.createQueues(num_gpu_queues);
  }

  if (context_init_time_init == 0) {
    clock_gettime(CLOCK_MONOTONIC_RAW, &context_init_time);
    context_init_time_init = 1;
  }

  err = hsa_amd_register_system_event_handler(callbackEvent, NULL);
    ErrorCheck(Registering the system for memory faults, err);

    init_tasks();
    atlc.g_gpu_initialized = true;
    return ATMI_STATUS_SUCCESS;
}

atmi_status_t atl_init_cpu_context() {
  if (atlc.struct_initialized == false) atmi_init_context_structs();

  if (atlc.g_cpu_initialized != false) return ATMI_STATUS_SUCCESS;

  hsa_status_t err;
  err = init_hsa();
  if (err != HSA_STATUS_SUCCESS) return ATMI_STATUS_ERROR;

  /* Get a CPU agent, create a pthread to handle packets*/
  /* Iterate over the agents and pick the cpu agent */
  int cpu_count = g_atl_machine.processorCount<ATLCPUProcessor>();
  for (int cpu = 0; cpu < cpu_count; cpu++) {
    atmi_place_t place = ATMI_PLACE_CPU(0, cpu);
    ATLCPUProcessor &proc = get_processor<ATLCPUProcessor>(place);
    // FIXME: We are creating as many CPU queues as there are cores
    // But, this will share CPU worker threads with main host thread
    // and the HSA callback thread. Is there any real benefit from
    // restricting the number of queues to num_cus - 2?
    int num_cpu_queues = core::Runtime::getInstance().getNumCPUQueues();
    if (num_cpu_queues == -1) {
      num_cpu_queues = (proc.num_cus() > 8) ? 8 : proc.num_cus();
    }
    cpu_agent_init(cpu, num_cpu_queues);
  }

  init_tasks();
  atlc.g_cpu_initialized = true;
  return ATMI_STATUS_SUCCESS;
}

void *atl_read_binary_from_file(const char *module, size_t *module_size) {
  // Open file.
  std::ifstream file(module, std::ios::in | std::ios::binary);
  if (!(file.is_open() && file.good())) {
    fprintf(stderr, "File %s not found\n", module);
    return NULL;
  }

  // Find out file size.
  file.seekg(0, file.end);
  size_t size = file.tellg();
  file.seekg(0, file.beg);

  // Allocate memory for raw code object.
  void *raw_code_object = malloc(size);
  assert(raw_code_object);

  // Read file contents.
  file.read(reinterpret_cast<char *>(raw_code_object), size);

  // Close file.
  file.close();
  *module_size = size;
  return raw_code_object;
}

bool isImplicit(KernelArgMD::ValueKind value_kind) {
  switch (value_kind) {
    case KernelArgMD::ValueKind::HiddenGlobalOffsetX:
    case KernelArgMD::ValueKind::HiddenGlobalOffsetY:
    case KernelArgMD::ValueKind::HiddenGlobalOffsetZ:
    case KernelArgMD::ValueKind::HiddenNone:
    case KernelArgMD::ValueKind::HiddenPrintfBuffer:
    case KernelArgMD::ValueKind::HiddenDefaultQueue:
    case KernelArgMD::ValueKind::HiddenCompletionAction:
    case KernelArgMD::ValueKind::HiddenMultiGridSyncArg:
    case KernelArgMD::ValueKind::HiddenHostcallBuffer:
      return true;
    default:
      return false;
  }
}

hsa_status_t validate_code_object(hsa_code_object_t code_object,
                                  hsa_code_symbol_t symbol, void *data) {
  hsa_status_t retVal = HSA_STATUS_SUCCESS;
  std::set<std::string> *SymbolSet = static_cast<std::set<std::string> *>(data);
  hsa_symbol_kind_t type;

  uint32_t name_length;
  hsa_status_t err;
  err = hsa_code_symbol_get_info(symbol, HSA_CODE_SYMBOL_INFO_TYPE, &type);
  ErrorCheck(Symbol info extraction, err);
  DEBUG_PRINT("Exec Symbol type: %d\n", type);

  if (type == HSA_SYMBOL_KIND_VARIABLE) {
    err = hsa_code_symbol_get_info(symbol, HSA_CODE_SYMBOL_INFO_NAME_LENGTH,
                                   &name_length);
    ErrorCheck(Symbol info extraction, err);
    char *name = reinterpret_cast<char *>(malloc(name_length + 1));
    err = hsa_code_symbol_get_info(symbol, HSA_CODE_SYMBOL_INFO_NAME, name);
    ErrorCheck(Symbol info extraction, err);
    name[name_length] = 0;

    if (SymbolSet->find(std::string(name)) != SymbolSet->end()) {
      // Symbol already found. Return Error
      DEBUG_PRINT("Symbol %s already found!\n", name);
      retVal = HSA_STATUS_ERROR_VARIABLE_ALREADY_DEFINED;
    } else {
      SymbolSet->insert(std::string(name));
    }

    free(name);
  } else {
    DEBUG_PRINT("Symbol is an indirect function\n");
  }
  return retVal;
}

static std::pair<unsigned char *, unsigned char *>
find_metadata(void *binary, size_t binSize) {
  std::pair<unsigned char *, unsigned char *> failure = {nullptr, nullptr};

  Elf *e = elf_memory(static_cast<char *>(binary), binSize);
  if (elf_kind(e) != ELF_K_ELF) {
    return failure;
  }

  size_t numpHdrs;
  if (elf_getphdrnum(e, &numpHdrs) != 0) {
    return failure;
  }

  for (size_t i = 0; i < numpHdrs; ++i) {
    GElf_Phdr pHdr;
    if (gelf_getphdr(e, i, &pHdr) != &pHdr) {
      continue;
    }
    // Look for the runtime metadata note
    if (pHdr.p_type == PT_NOTE && pHdr.p_align >= sizeof(int)) {
      // Iterate over the notes in this segment
      address ptr = (address)binary + pHdr.p_offset;
      address segmentEnd = ptr + pHdr.p_filesz;

      while (ptr < segmentEnd) {
        Elf_Note *note = reinterpret_cast<Elf_Note *>(ptr);
        address name = (address)&note[1];

        if (note->n_type == 7 || note->n_type == 8) {
          return failure;
        } else if (note->n_type == 10 /* NT_AMD_AMDGPU_HSA_METADATA */ &&
                   note->n_namesz == sizeof "AMD" &&
                   !memcmp(name, "AMD", note->n_namesz)) {
          // code object v2 uses yaml metadata, no longer supported
          return failure;
        } else if (note->n_type == 32 /* NT_AMDGPU_METADATA */ &&
                   note->n_namesz == sizeof "AMDGPU" &&
                   !memcmp(name, "AMDGPU", note->n_namesz)) {

          // n_descsz = 485
          // value is padded to 4 byte alignment, may want to move end up to
          // match
          size_t offset = sizeof(uint32_t) * 3 /* fields */
                          + sizeof("AMDGPU")   /* name */
                          + 1 /* padding to 4 byte alignment */;

          // Including the trailing padding means both pointers are 4 bytes
          // aligned, which may be useful later.
          unsigned char *metadata_start = (unsigned char *)ptr + offset;
          unsigned char *metadata_end =
              metadata_start + core::alignUp(note->n_descsz, 4);
          return {metadata_start, metadata_end};
        }
        ptr += sizeof(*note) + core::alignUp(note->n_namesz, sizeof(int)) +
               core::alignUp(note->n_descsz, sizeof(int));
      }
    }
  }

  return failure;
}

namespace {
int map_lookup_array(msgpack::byte_range message, const char *needle,
                     msgpack::byte_range *res, uint64_t *size) {
  unsigned count = 0;
  struct s : msgpack::functors_defaults<s> {
    s(unsigned &count, uint64_t *size) : count(count), size(size) {}
    unsigned &count;
    uint64_t *size;
    const unsigned char *handle_array(uint64_t N, msgpack::byte_range bytes) {
      count++;
      *size = N;
      return bytes.end;
    }
  };

  msgpack::foreach_map(message,
                       [&](msgpack::byte_range key, msgpack::byte_range value) {
                         if (msgpack::message_is_string(key, needle)) {
                           // If the message is an array, record number of
                           // elements in *size
                           msgpack::handle_msgpack<s>(value, {count, size});
                           // return the whole array
                           *res = value;
                         }
                       });
  // Only claim success if exactly one key/array pair matched
  return count != 1;
}

int map_lookup_string(msgpack::byte_range message, const char *needle,
                      std::string *res) {
  unsigned count = 0;
  struct s : public msgpack::functors_defaults<s> {
    s(unsigned &count, std::string *res) : count(count), res(res) {}
    unsigned &count;
    std::string *res;
    void handle_string(size_t N, const unsigned char *str) {
      count++;
      *res = std::string(str, str + N);
    }
  };
  msgpack::foreach_map(message,
                       [&](msgpack::byte_range key, msgpack::byte_range value) {
                         if (msgpack::message_is_string(key, needle)) {
                           msgpack::handle_msgpack<s>(value, {count, res});
                         }
                       });
  return count != 1;
}

int map_lookup_uint64_t(msgpack::byte_range message, const char *needle,
                        uint64_t *res) {
  unsigned count = 0;
  msgpack::foreach_map(message,
                       [&](msgpack::byte_range key, msgpack::byte_range value) {
                         if (msgpack::message_is_string(key, needle)) {
                           msgpack::foronly_unsigned(value, [&](uint64_t x) {
                             count++;
                             *res = x;
                           });
                         }
                       });
  return count != 1;
}

int array_lookup_element(msgpack::byte_range message, uint64_t elt,
                         msgpack::byte_range *res) {
  int rc = 1;
  uint64_t i = 0;
  msgpack::foreach_array(message, [&](msgpack::byte_range value) {
    if (i == elt) {
      *res = value;
      rc = 0;
    }
    i++;
  });
  return rc;
}

int populate_kernelArgMD(msgpack::byte_range args_element,
                         KernelArgMD *kernelarg) {
  using namespace msgpack;
  int error = 0;
  foreach_map(args_element, [&](byte_range key, byte_range value) -> void {
    if (message_is_string(key, ".name")) {
      foronly_string(value, [&](size_t N, const unsigned char *str) {
        kernelarg->name_ = std::string(str, str + N);
      });
    } else if (message_is_string(key, ".type_name")) {
      foronly_string(value, [&](size_t N, const unsigned char *str) {
        kernelarg->typeName_ = std::string(str, str + N);
      });
    } else if (message_is_string(key, ".size")) {
      foronly_unsigned(value, [&](uint64_t x) { kernelarg->size_ = x; });
    } else if (message_is_string(key, ".offset")) {
      foronly_unsigned(value, [&](uint64_t x) { kernelarg->offset_ = x; });
    } else if (message_is_string(key, ".value_kind")) {
      foronly_string(value, [&](size_t N, const unsigned char *str) {
        std::string s = std::string(str, str + N);
        auto itValueKind = ArgValueKind.find(s);
        if (itValueKind != ArgValueKind.end()) {
          kernelarg->valueKind_ = itValueKind->second;
        }
      });
    }
  });
  return error;
}
} // namespace

static hsa_status_t get_code_object_custom_metadata(void *binary,
                                                    size_t binSize, int gpu) {
  // parse code object with different keys from v2
  // also, the kernel name is not the same as the symbol name -- so a
  // symbol->name map is needed

  std::pair<unsigned char *, unsigned char *> metadata =
      find_metadata(binary, binSize);
  if (!metadata.first) {
    return HSA_STATUS_ERROR_INVALID_CODE_OBJECT;
  }

  uint64_t kernelsSize = 0;
  int msgpack_errors = 0;
  msgpack::byte_range kernel_array;
  msgpack_errors =
      map_lookup_array({metadata.first, metadata.second}, "amdhsa.kernels",
                       &kernel_array, &kernelsSize);
  msgpackErrorCheck(kernels lookup in program metadata, msgpack_errors);

  for (size_t i = 0; i < kernelsSize; i++) {
    assert(msgpack_errors == 0);
    std::string kernelName;
    std::string languageName;
    std::string symbolName;

    msgpack::byte_range element;
    msgpack_errors += array_lookup_element(kernel_array, i, &element);
    msgpackErrorCheck(element lookup in kernel metadata, msgpack_errors);

    msgpack_errors += map_lookup_string(element, ".name", &kernelName);
    msgpack_errors += map_lookup_string(element, ".language", &languageName);
    msgpack_errors += map_lookup_string(element, ".symbol", &symbolName);
    msgpackErrorCheck(strings lookup in kernel metadata, msgpack_errors);

    atl_kernel_info_t info;
    size_t kernel_explicit_args_size = 0;
    uint64_t kernel_segment_size;
    msgpack_errors += map_lookup_uint64_t(element, ".kernarg_segment_size",
                                          &kernel_segment_size);
    msgpackErrorCheck(kernarg segment size metadata lookup in kernel metadata,
                      msgpack_errors);

    // create a map from symbol to name
    DEBUG_PRINT("Kernel symbol %s; Name: %s; Size: %lu\n", symbolName.c_str(),
                kernelName.c_str(), kernel_segment_size);
    KernelNameMap[symbolName] = kernelName;

    bool hasHiddenArgs = false;
    if (kernel_segment_size > 0) {
      uint64_t argsSize;
      size_t offset = 0;

      msgpack::byte_range args_array;
      msgpack_errors +=
          map_lookup_array(element, ".args", &args_array, &argsSize);
      msgpackErrorCheck(kernel args metadata lookup in kernel metadata,
                        msgpack_errors);

      info.num_args = argsSize;

      for (size_t i = 0; i < argsSize; ++i) {
        KernelArgMD lcArg;

        msgpack::byte_range args_element;
        msgpack_errors += array_lookup_element(args_array, i, &args_element);
        msgpackErrorCheck(iterate args map in kernel args metadata,
                          msgpack_errors);

        msgpack_errors += populate_kernelArgMD(args_element, &lcArg);
        msgpackErrorCheck(iterate args map in kernel args metadata,
                          msgpack_errors);

        // TODO(ashwinma): should the below population actions be done only for
        // non-implicit args?
        // populate info with sizes and offsets
        info.arg_sizes.push_back(lcArg.size_);
        // v3 has offset field and not align field
        size_t new_offset = lcArg.offset_;
        size_t padding = new_offset - offset;
        offset = new_offset;
        info.arg_offsets.push_back(lcArg.offset_);
        DEBUG_PRINT("Arg[%lu] \"%s\" (%u, %u)\n", i, lcArg.name_.c_str(),
                    lcArg.size_, lcArg.offset_);
        offset += lcArg.size_;

        // check if the arg is a hidden/implicit arg
        // this logic assumes that all hidden args are 8-byte aligned
        if (!isImplicit(lcArg.valueKind_)) {
          kernel_explicit_args_size += lcArg.size_;
        } else {
          hasHiddenArgs = true;
        }
        kernel_explicit_args_size += padding;
      }
    }

    // add size of implicit args, e.g.: offset x, y and z and pipe pointer, but
    // in ATMI, do not count the compiler set implicit args, but set your own
    // implicit args by discounting the compiler set implicit args
    info.kernel_segment_size =
        (hasHiddenArgs ? kernel_explicit_args_size : kernel_segment_size) +
        sizeof(atmi_implicit_args_t);
    DEBUG_PRINT("[%s: kernarg seg size] (%lu --> %u)\n", kernelName.c_str(),
                kernel_segment_size, info.kernel_segment_size);

    // kernel received, now add it to the kernel info table
    KernelInfoTable[gpu][kernelName] = info;

  }

  return HSA_STATUS_SUCCESS;
}

hsa_status_t populate_InfoTables(hsa_executable_t executable,
                                 hsa_executable_symbol_t symbol, void *data) {
  int gpu = *static_cast<int *>(data);
  hsa_symbol_kind_t type;

  uint32_t name_length;
  hsa_status_t err;
  err = hsa_executable_symbol_get_info(symbol, HSA_EXECUTABLE_SYMBOL_INFO_TYPE,
                                       &type);
  ErrorCheck(Symbol info extraction, err);
  DEBUG_PRINT("Exec Symbol type: %d\n", type);
  if (type == HSA_SYMBOL_KIND_KERNEL) {
    err = hsa_executable_symbol_get_info(
        symbol, HSA_EXECUTABLE_SYMBOL_INFO_NAME_LENGTH, &name_length);
    ErrorCheck(Symbol info extraction, err);
    char *name = reinterpret_cast<char *>(malloc(name_length + 1));
    err = hsa_executable_symbol_get_info(symbol,
                                         HSA_EXECUTABLE_SYMBOL_INFO_NAME, name);
    ErrorCheck(Symbol info extraction, err);
    name[name_length] = 0;

    if (KernelNameMap.find(std::string(name)) == KernelNameMap.end()) {
      // did not find kernel name in the kernel map; this can happen only
      // if the ROCr API for getting symbol info (name) is different from
      // the comgr method of getting symbol info
      ErrorCheck(Invalid kernel name, HSA_STATUS_ERROR_INVALID_CODE_OBJECT);
    }
    atl_kernel_info_t info;
    std::string kernelName = KernelNameMap[std::string(name)];
    // by now, the kernel info table should already have an entry
    // because the non-ROCr custom code object parsing is called before
    // iterating over the code object symbols using ROCr
    if (KernelInfoTable[gpu].find(kernelName) == KernelInfoTable[gpu].end()) {
      ErrorCheck(Finding the entry kernel info table,
                 HSA_STATUS_ERROR_INVALID_CODE_OBJECT);
    }
    // found, so assign and update
    info = KernelInfoTable[gpu][kernelName];

    /* Extract dispatch information from the symbol */
    err = hsa_executable_symbol_get_info(
        symbol, HSA_EXECUTABLE_SYMBOL_INFO_KERNEL_OBJECT,
        &(info.kernel_object));
    ErrorCheck(Extracting the symbol from the executable, err);
    err = hsa_executable_symbol_get_info(
        symbol, HSA_EXECUTABLE_SYMBOL_INFO_KERNEL_GROUP_SEGMENT_SIZE,
        &(info.group_segment_size));
    ErrorCheck(Extracting the group segment size from the executable, err);
    err = hsa_executable_symbol_get_info(
        symbol, HSA_EXECUTABLE_SYMBOL_INFO_KERNEL_PRIVATE_SEGMENT_SIZE,
        &(info.private_segment_size));
    ErrorCheck(Extracting the private segment from the executable, err);

    DEBUG_PRINT(
        "Kernel %s --> %lx symbol %u group segsize %u pvt segsize %u bytes "
        "kernarg\n",
        kernelName.c_str(), info.kernel_object, info.group_segment_size,
        info.private_segment_size, info.kernel_segment_size);

    // assign it back to the kernel info table
    KernelInfoTable[gpu][kernelName] = info;
    free(name);
  } else if (type == HSA_SYMBOL_KIND_VARIABLE) {
    err = hsa_executable_symbol_get_info(
        symbol, HSA_EXECUTABLE_SYMBOL_INFO_NAME_LENGTH, &name_length);
    ErrorCheck(Symbol info extraction, err);
    char *name = reinterpret_cast<char *>(malloc(name_length + 1));
    err = hsa_executable_symbol_get_info(symbol,
                                         HSA_EXECUTABLE_SYMBOL_INFO_NAME, name);
    ErrorCheck(Symbol info extraction, err);
    name[name_length] = 0;

    atl_symbol_info_t info;

    err = hsa_executable_symbol_get_info(
        symbol, HSA_EXECUTABLE_SYMBOL_INFO_VARIABLE_ADDRESS, &(info.addr));
    ErrorCheck(Symbol info address extraction, err);

    err = hsa_executable_symbol_get_info(
        symbol, HSA_EXECUTABLE_SYMBOL_INFO_VARIABLE_SIZE, &(info.size));
    ErrorCheck(Symbol info size extraction, err);

    atmi_mem_place_t place = ATMI_MEM_PLACE(ATMI_DEVTYPE_GPU, gpu, 0);
    DEBUG_PRINT("Symbol %s = %p (%u bytes)\n", name, (void *)info.addr,
                info.size);
    register_allocation(reinterpret_cast<void *>(info.addr), (size_t)info.size,
                        place);
    SymbolInfoTable[gpu][std::string(name)] = info;
    if (strcmp(name, "needs_hostcall_buffer") == 0)
      g_atmi_hostcall_required = true;
    free(name);
  } else {
    DEBUG_PRINT("Symbol is an indirect function\n");
  }
  return HSA_STATUS_SUCCESS;
}

atmi_status_t Runtime::RegisterModuleFromMemory(void **modules,
                                                size_t *module_sizes,
                                                atmi_platform_type_t *types,
                                                const int num_modules,
                                                atmi_place_t place) {
  hsa_status_t err;
  int gpu = place.device_id;
  if (gpu == -1) {
    // user is asking runtime to pick a device
    // TODO(ashwinma): best device of this type? pick 0 for now
    gpu = 0;
  }

  DEBUG_PRINT("Trying to load module to GPU-%d\n", gpu);
  ATLGPUProcessor &proc = get_processor<ATLGPUProcessor>(place);
  hsa_agent_t agent = proc.agent();
  hsa_executable_t executable = {0};
  hsa_profile_t agent_profile;

  err = hsa_agent_get_info(agent, HSA_AGENT_INFO_PROFILE, &agent_profile);
  ErrorCheck(Query the agent profile, err);
  // FIXME: Assume that every profile is FULL until we understand how to build
  // GCN with base profile
  agent_profile = HSA_PROFILE_FULL;
  /* Create the empty executable.  */
  err = hsa_executable_create(agent_profile, HSA_EXECUTABLE_STATE_UNFROZEN, "",
                              &executable);
  ErrorCheck(Create the executable, err);

  // initially empty symbol set for every executable
  std::set<std::string> SymbolSet;

  bool module_load_success = false;
  for (int i = 0; i < num_modules; i++) {
    void *module_bytes = modules[i];
    size_t module_size = module_sizes[i];
    if (types[i] == AMDGCN) {
      // Some metadata info is not available through ROCr API, so use custom
      // code object metadata parsing to collect such metadata info


      
      void *tmp_module = malloc(module_size);
      memcpy(tmp_module, module_bytes, module_size);
      err = get_code_object_custom_metadata(tmp_module, module_size, gpu);
      ErrorCheckAndContinue(Getting custom code object metadata, err);
      free(tmp_module);

      // Deserialize code object.
      hsa_code_object_t code_object = {0};
      err = hsa_code_object_deserialize(module_bytes, module_size, NULL,
                                        &code_object);
      ErrorCheckAndContinue(Code Object Deserialization, err);
      assert(0 != code_object.handle);

      err = hsa_code_object_iterate_symbols(code_object, validate_code_object,
                                            static_cast<void *>(&SymbolSet));
      ErrorCheckAndContinue(Iterating over symbols for execuatable, err);

      /* Load the code object.  */
      err =
          hsa_executable_load_code_object(executable, agent, code_object, NULL);
      ErrorCheckAndContinue(Loading the code object, err);

      // cannot iterate over symbols until executable is frozen

    } else {
      ErrorCheckAndContinue(Loading non - AMDGCN code object,
                            HSA_STATUS_ERROR_INVALID_CODE_OBJECT);
    }
    module_load_success = true;
  }
  DEBUG_PRINT("Modules loaded successful? %d\n", module_load_success);
  if (module_load_success) {
    /* Freeze the executable; it can now be queried for symbols.  */
    err = hsa_executable_freeze(executable, "");
    ErrorCheck(Freeze the executable, err);

    err = hsa_executable_iterate_symbols(executable, populate_InfoTables,
                                         static_cast<void *>(&gpu));
    ErrorCheck(Iterating over symbols for execuatable, err);

    // err = hsa_executable_iterate_program_symbols(executable,
    // iterate_program_symbols, &gpu);
    // ErrorCheckAndContinue(Iterating over symbols for execuatable, err);

    // err = hsa_executable_iterate_agent_symbols(executable,
    // iterate_agent_symbols, &gpu);
    // ErrorCheckAndContinue(Iterating over symbols for execuatable, err);

    // save the executable and destroy during finalize
    g_executables.push_back(executable);
    return ATMI_STATUS_SUCCESS;
  } else {
    return ATMI_STATUS_ERROR;
  }
}

atmi_status_t Runtime::RegisterModuleFromMemory(void **modules,
                                                size_t *module_sizes,
                                                atmi_platform_type_t *types,
                                                const int num_modules) {
  int gpu_count = g_atl_machine.processorCount<ATLGPUProcessor>();
  int some_success = 0;
  atmi_status_t status;
  for (int gpu = 0; gpu < gpu_count; gpu++) {
    atmi_place_t place = ATMI_PLACE_GPU(0, gpu);
    status = core::Runtime::getInstance().RegisterModuleFromMemory(
        modules, module_sizes, types, num_modules, place);
    if (status == ATMI_STATUS_SUCCESS) some_success = 1;
  }

  return (some_success) ? ATMI_STATUS_SUCCESS : ATMI_STATUS_ERROR;
}

atmi_status_t Runtime::RegisterModule(const char **filenames,
                                      atmi_platform_type_t *types,
                                      const int num_modules) {
  std::vector<void *> modules;
  std::vector<size_t> module_sizes;
  for (int i = 0; i < num_modules; i++) {
    size_t module_size;
    void *module_bytes = atl_read_binary_from_file(filenames[i], &module_size);
    if (!module_bytes) return ATMI_STATUS_ERROR;
    modules.push_back(module_bytes);
    module_sizes.push_back(module_size);
  }

  atmi_status_t status = core::Runtime::getInstance().RegisterModuleFromMemory(
      &modules[0], &module_sizes[0], types, num_modules);

  // memory space got by
  // void *raw_code_object = malloc(size);
  for (int i = 0; i < num_modules; i++) {
    free(modules[i]);
  }

  return status;
}

atmi_status_t Runtime::RegisterModule(const char **filenames,
                                      atmi_platform_type_t *types,
                                      const int num_modules,
                                      atmi_place_t place) {
  std::vector<void *> modules;
  std::vector<size_t> module_sizes;
  for (int i = 0; i < num_modules; i++) {
    size_t module_size;
    void *module_bytes = atl_read_binary_from_file(filenames[i], &module_size);
    if (!module_bytes) return ATMI_STATUS_ERROR;
    modules.push_back(module_bytes);
    module_sizes.push_back(module_size);
  }

  atmi_status_t status = core::Runtime::getInstance().RegisterModuleFromMemory(
      &modules[0], &module_sizes[0], types, num_modules, place);

  // memory space got by
  // void *raw_code_object = malloc(size);
  for (int i = 0; i < num_modules; i++) {
    free(modules[i]);
  }

  return status;
}
}  // namespace core
