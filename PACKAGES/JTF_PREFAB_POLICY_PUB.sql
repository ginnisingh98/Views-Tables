--------------------------------------------------------
--  DDL for Package JTF_PREFAB_POLICY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PREFAB_POLICY_PUB" AUTHID CURRENT_USER as
/* $Header: jtfprefabpos.pls 120.4 2005/10/28 01:24:01 emekala ship $ */

PROCEDURE INSERT_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           OUT  NOCOPY    jtf_prefab_policies_b.policy_id%TYPE,
  p_policy_name         IN      jtf_prefab_policies_b.policy_name%TYPE,
  p_priority            IN      jtf_prefab_policies_b.priority%TYPE,
  p_description         IN      jtf_prefab_policies_tl.description%TYPE,
  p_enabled_flag        IN      jtf_prefab_policies_b.enabled_flag%TYPE,
  p_application_id      IN      jtf_prefab_policies_b.application_id%TYPE,
  p_all_applications_flag IN    jtf_prefab_policies_b.all_applications_flag%TYPE,
  p_depth               IN      jtf_prefab_policies_b.depth%TYPE,
  p_all_responsibilities_flag IN  jtf_prefab_policies_b.all_responsibilities_flag%TYPE,
  p_all_users_flag      IN      jtf_prefab_policies_b.all_users_flag%TYPE,
  p_refresh_interval    IN      jtf_prefab_policies_b.refresh_interval%TYPE,
  p_interval_unit       IN      jtf_prefab_policies_b.interval_unit%TYPE,
  p_start_time          IN      jtf_prefab_policies_b.start_time%TYPE,
  p_end_time            IN      jtf_prefab_policies_b.end_time%TYPE,
  p_run_always_flag     IN      jtf_prefab_policies_b.run_always_flag%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_policies_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

PROCEDURE UPDATE_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_policies_b.policy_id%TYPE,
  p_policy_name         IN      jtf_prefab_policies_b.policy_name%TYPE,
  p_priority            IN      jtf_prefab_policies_b.priority%TYPE,
  p_description         IN      jtf_prefab_policies_tl.description%TYPE,
  p_enabled_flag        IN      jtf_prefab_policies_b.enabled_flag%TYPE,
  p_application_id      IN      jtf_prefab_policies_b.application_id%TYPE,
  p_all_applications_flag IN      jtf_prefab_policies_b.all_applications_flag%TYPE,
  p_depth               IN      jtf_prefab_policies_b.depth%TYPE,
  p_all_responsibilities_flag IN  jtf_prefab_policies_b.all_responsibilities_flag%TYPE,
  p_all_users_flag      IN      jtf_prefab_policies_b.all_users_flag%TYPE,
  p_refresh_interval    IN      jtf_prefab_policies_b.refresh_interval%TYPE,
  p_interval_unit       IN      jtf_prefab_policies_b.interval_unit%TYPE,
  p_start_time          IN      jtf_prefab_policies_b.start_time%TYPE,
  p_end_time            IN      jtf_prefab_policies_b.end_time%TYPE,
  p_run_always_flag     IN      jtf_prefab_policies_b.run_always_flag%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_policies_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

procedure DELETE_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_policies_b.policy_id%TYPE,

  p_object_version_number IN    jtf_prefab_policies_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

PROCEDURE INSERT_UR_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_ur_policies.policy_id%TYPE,
  p_userresp_id         IN      jtf_prefab_ur_policies.userresp_id%TYPE,
  p_userresp_type       IN      jtf_prefab_ur_policies.userresp_type%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_ur_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

PROCEDURE DELETE_UR_POLICY (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_ur_policies.policy_id%TYPE,
  p_userresp_id         IN      jtf_prefab_ur_policies.userresp_id%TYPE,
  p_userresp_type       IN      jtf_prefab_ur_policies.userresp_type%TYPE,

  p_object_version_number IN    jtf_prefab_ur_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

PROCEDURE DELETE_UR_POLICY (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_ur_policies.policy_id%TYPE,

  p_object_version_number IN    jtf_prefab_ur_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

PROCEDURE CONFIGURE_SYS_POLICY (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_start_flag          IN      jtf_prefab_sys_policies.start_flag%TYPE,
  p_cpu                 IN      jtf_prefab_sys_policies.cpu%TYPE,
  p_memory              IN      jtf_prefab_sys_policies.memory%TYPE,
  p_disk_location       IN      jtf_prefab_sys_policies.disk_location%TYPE,
  p_max_concurrency     IN      jtf_prefab_sys_policies.max_concurrency%TYPE,
  p_use_load_balancer_flag IN      jtf_prefab_sys_policies.use_load_balancer_flag%TYPE,
  p_load_balancer_url   IN      jtf_prefab_sys_policies.load_balancer_url%TYPE,
  p_refresh_flag        IN      jtf_prefab_sys_policies.refresh_flag%TYPE,
  p_interceptor_enabled_flag IN jtf_prefab_sys_policies.interceptor_enabled_flag%TYPE,
  p_cache_memory        IN      jtf_prefab_sys_policies.cache_memory%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_sys_policies.object_version_number%TYPE,
  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

PROCEDURE INSERT_WSH_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           OUT  NOCOPY    jtf_prefab_wsh_poes_b.wsh_po_id%TYPE,
  p_hostname            IN      jtf_prefab_wsh_poes_b.hostname%TYPE,
  p_description         IN      jtf_prefab_wsh_poes_tl.description%TYPE,
  p_weight              IN      jtf_prefab_wsh_poes_b.weight%TYPE,
  p_load_pick_up_flag   IN      jtf_prefab_wsh_poes_b.load_pick_up_flag%TYPE,
  p_cache_size          IN      jtf_prefab_wsh_poes_b.cache_size%TYPE,
  p_wsh_type            IN      jtf_prefab_wsh_poes_b.wsh_type%TYPE,
  p_prefab_enabled_flag IN      jtf_prefab_wsh_poes_b.prefab_enabled_flag%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_wsh_poes_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

PROCEDURE UPDATE_WSH_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_wsh_poes_b.wsh_po_id%TYPE,
  p_hostname            IN      jtf_prefab_wsh_poes_b.hostname%TYPE,
  p_description         IN      jtf_prefab_wsh_poes_tl.description%TYPE,
  p_weight              IN      jtf_prefab_wsh_poes_b.weight%TYPE,
  p_load_pick_up_flag   IN      jtf_prefab_wsh_poes_b.load_pick_up_flag%TYPE,
  p_cache_size          IN      jtf_prefab_wsh_poes_b.cache_size%TYPE,
  p_wsh_type            IN      jtf_prefab_wsh_poes_b.wsh_type%TYPE,
  p_prefab_enabled_flag IN      jtf_prefab_wsh_poes_b.prefab_enabled_flag%TYPE,

  p_object_version_number IN OUT  NOCOPY jtf_prefab_wsh_poes_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

procedure DELETE_WSH_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_wsh_poes_b.wsh_po_id%TYPE,

  p_object_version_number IN    jtf_prefab_wsh_poes_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

PROCEDURE INSERT_WSHP_POLICY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_wshp_policies.wsh_po_id%TYPE,
  p_port                IN      jtf_prefab_wshp_policies.port%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_wshp_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

PROCEDURE DELETE_WSHP_POLICY (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_wshp_policies.wsh_po_id%TYPE,
  p_port                IN      jtf_prefab_wshp_policies.port%TYPE,

  p_object_version_number IN    jtf_prefab_wshp_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

PROCEDURE DELETE_WSHP_POLICY (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_wshp_policies.wsh_po_id%TYPE,

  p_object_version_number IN    jtf_prefab_wshp_policies.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

END JTF_PREFAB_POLICY_PUB;

 

/
