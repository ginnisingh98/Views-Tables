--------------------------------------------------------
--  DDL for Package JTF_PREFAB_CACHE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PREFAB_CACHE_PUB" AUTHID CURRENT_USER as
/* $Header: jtfprefabcas.pls 120.4 2006/09/15 13:04:34 amaddula ship $ */

PROCEDURE INSERT_HOST_APP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_host_app_id         OUT  NOCOPY   jtf_prefab_host_apps.host_app_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_host_apps.wsh_po_id%TYPE,
  p_application_id      IN      jtf_prefab_host_apps.application_id%TYPE,
  p_cache_policy        IN      jtf_prefab_host_apps.cache_policy%TYPE,
  p_cache_clear_flag    IN      jtf_prefab_host_apps.cache_clear_flag%TYPE,
  p_cache_reload_flag   IN      jtf_prefab_host_apps.cache_reload_flag%TYPE,
  p_cache_filter_policy IN      jtf_prefab_host_apps.cache_filter_policy%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_host_apps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE UPDATE_HOST_APP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_host_app_id         IN      jtf_prefab_host_apps.host_app_id%TYPE,
  p_cache_policy        IN      jtf_prefab_host_apps.cache_policy%TYPE,
  p_cache_clear_flag    IN      jtf_prefab_host_apps.cache_clear_flag%TYPE,
  p_cache_reload_flag   IN      jtf_prefab_host_apps.cache_reload_flag%TYPE,
  p_cache_filter_policy IN      jtf_prefab_host_apps.cache_filter_policy%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_host_apps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure SELECT_HOST_APP_FOR_HOST(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_host_app_id         IN      jtf_prefab_host_apps.host_app_id%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_host_apps.object_version_number%TYPE,
  p_wsh_po_id           OUT  NOCOPY    jtf_prefab_host_apps.wsh_po_id%TYPE,
  p_application_id      OUT  NOCOPY    jtf_prefab_host_apps.application_id%TYPE,
  p_cache_policy        OUT  NOCOPY    jtf_prefab_host_apps.cache_policy%TYPE,
  p_cache_clear_flag    OUT  NOCOPY    jtf_prefab_host_apps.cache_clear_flag%TYPE,
  p_cache_reload_flag   OUT  NOCOPY    jtf_prefab_host_apps.cache_reload_flag%TYPE,
  p_cache_filter_policy OUT  NOCOPY    jtf_prefab_host_apps.cache_filter_policy%TYPE,
  p_hostname            OUT  NOCOPY    jtf_prefab_wsh_poes_b.hostname%TYPE,
  p_appname             OUT  NOCOPY    fnd_application_vl.application_name%TYPE,
  p_app_short_name      OUT  NOCOPY    fnd_application_vl.application_short_name%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_HOST_APP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_host_app_id         IN      jtf_prefab_host_apps.host_app_id%TYPE,

  p_object_version_number IN    jtf_prefab_host_apps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_HOST_APPS_FOR_HOST(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_wsh_po_id           IN      jtf_prefab_host_apps.wsh_po_id%TYPE,

  p_object_version_number IN    jtf_prefab_host_apps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE INSERT_CACHE_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_comp_id          OUT  NOCOPY   jtf_prefab_ca_comps_b.ca_comp_id%TYPE,
  p_application_id      IN      jtf_prefab_ca_comps_b.application_id%TYPE,
  p_comp_name           IN      jtf_prefab_ca_comps_b.comp_name%TYPE,
  p_description         IN      jtf_prefab_ca_comps_tl.description%TYPE,
  p_component_key       IN      jtf_prefab_ca_comps_b.component_key%TYPE,
  p_loader_class_name   IN      jtf_prefab_ca_comps_b.loader_class_name%TYPE,
  p_timeout_type        IN      jtf_prefab_ca_comps_b.timeout_type%TYPE,
  p_timeout             IN      jtf_prefab_ca_comps_b.timeout%TYPE,
  p_timeout_unit        IN      jtf_prefab_ca_comps_b.timeout_unit%TYPE,
  p_sgid_enabled_flag   IN      jtf_prefab_ca_comps_b.sgid_enabled_flag%TYPE,
  p_stat_enabled_flag   IN      jtf_prefab_ca_comps_b.stat_enabled_flag%TYPE,
  p_distributed_flag    IN      jtf_prefab_ca_comps_b.distributed_flag%TYPE,
  p_cache_generic_flag  IN      jtf_prefab_ca_comps_b.cache_generic_flag%TYPE,
  p_business_event_name IN      jtf_prefab_ca_comps_b.business_event_name%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_ca_comps_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE UPDATE_CACHE_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_comp_id          IN      jtf_prefab_ca_comps_b.ca_comp_id%TYPE,
  p_application_id      IN      jtf_prefab_ca_comps_b.application_id%TYPE,
  p_comp_name           IN      jtf_prefab_ca_comps_b.comp_name%TYPE,
  p_description         IN      jtf_prefab_ca_comps_tl.description%TYPE,
  p_component_key       IN      jtf_prefab_ca_comps_b.component_key%TYPE,
  p_loader_class_name   IN      jtf_prefab_ca_comps_b.loader_class_name%TYPE,
  p_timeout_type        IN      jtf_prefab_ca_comps_b.timeout_type%TYPE,
  p_timeout             IN      jtf_prefab_ca_comps_b.timeout%TYPE,
  p_timeout_unit        IN      jtf_prefab_ca_comps_b.timeout_unit%TYPE,
  p_sgid_enabled_flag   IN      jtf_prefab_ca_comps_b.sgid_enabled_flag%TYPE,
  p_stat_enabled_flag   IN      jtf_prefab_ca_comps_b.stat_enabled_flag%TYPE,
  p_distributed_flag    IN      jtf_prefab_ca_comps_b.distributed_flag%TYPE,
  p_cache_generic_flag  IN      jtf_prefab_ca_comps_b.cache_generic_flag%TYPE,
  p_business_event_name IN      jtf_prefab_ca_comps_b.business_event_name%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_ca_comps_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE UPDATE_CACHE_COMP_1(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_comp_id          IN      jtf_prefab_ca_comps_b.ca_comp_id%TYPE,

--  p_object_version_number IN OUT jtf_prefab_ca_comps_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_CACHE_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_comp_id          IN      jtf_prefab_ca_comps_b.ca_comp_id%TYPE,

  p_object_version_number IN    jtf_prefab_ca_comps_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE INSERT_HA_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ha_comp_id          OUT  NOCOPY   jtf_prefab_ha_comps.ha_comp_id%TYPE,
  p_host_app_id         IN      jtf_prefab_ha_comps.host_app_id%TYPE,
  p_ca_comp_id          IN      jtf_prefab_ha_comps.ca_comp_id%TYPE,
  p_cache_policy        IN      jtf_prefab_ha_comps.cache_policy%TYPE,
  p_cache_clear_flag    IN      jtf_prefab_ha_comps.cache_clear_flag%TYPE,
  p_cache_reload_flag   IN      jtf_prefab_ha_comps.cache_reload_flag%TYPE,

  p_object_version_number OUT  NOCOPY jtf_prefab_ha_comps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE UPDATE_HA_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ha_comp_id          IN      jtf_prefab_ha_comps.ha_comp_id%TYPE,
  p_cache_policy        IN      jtf_prefab_ha_comps.cache_policy%TYPE,
  p_cache_clear_flag    IN      jtf_prefab_ha_comps.cache_clear_flag%TYPE,
  p_cache_reload_flag   IN      jtf_prefab_ha_comps.cache_reload_flag%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_ha_comps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_HA_COMPS_FOR_HOST_APP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_host_app_id         IN      jtf_prefab_ha_comps.host_app_id%TYPE,

  p_object_version_number IN    jtf_prefab_ha_comps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_HA_COMPS_FOR_CACHE_COMP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_comp_id          IN      jtf_prefab_ha_comps.ca_comp_id%TYPE,

  p_object_version_number IN    jtf_prefab_ha_comps.object_version_number%TYPE,

  x_return_status       OUT   NOCOPY  VARCHAR2,
  x_msg_count           OUT   NOCOPY  NUMBER,
  x_msg_data            OUT   NOCOPY  VARCHAR2
);

PROCEDURE INSERT_CACHE_STAT(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_cache_stat_id       OUT  NOCOPY   jtf_prefab_cache_stats.cache_stat_id%TYPE,
  p_security_group_id   IN      jtf_prefab_cache_stats.security_group_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_cache_stats.wsh_po_id%TYPE,
  p_ca_comp_id          IN      jtf_prefab_cache_stats.ca_comp_id%TYPE,
  p_jvm_id              IN      jtf_prefab_cache_stats.jvm_id%TYPE,
  p_num_cache_miss      IN      jtf_prefab_cache_stats.num_cache_miss%TYPE,
  p_num_cache_hit       IN      jtf_prefab_cache_stats.num_cache_hit%TYPE,
  p_num_loader_miss     IN      jtf_prefab_cache_stats.num_loader_miss%TYPE,
  p_num_invalidate_call IN      jtf_prefab_cache_stats.num_invalidate_call%TYPE,
  p_num_invalidations   IN      jtf_prefab_cache_stats.num_invalidations%TYPE,
  p_num_objects         IN      jtf_prefab_cache_stats.num_objects%TYPE,
  p_expiration_time     IN      jtf_prefab_cache_stats.expiration_time%TYPE,
  p_start_time          IN      jtf_prefab_cache_stats.start_time%TYPE,
  p_end_time            IN      jtf_prefab_cache_stats.end_time%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_cache_stats.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE UPDATE_CACHE_STAT(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_cache_stat_id       IN      jtf_prefab_cache_stats.cache_stat_id%TYPE,
  p_security_group_id   IN      jtf_prefab_cache_stats.security_group_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_cache_stats.wsh_po_id%TYPE,
  p_ca_comp_id          IN      jtf_prefab_cache_stats.ca_comp_id%TYPE,
  p_jvm_id              IN      jtf_prefab_cache_stats.jvm_id%TYPE,
  p_num_cache_miss      IN      jtf_prefab_cache_stats.num_cache_miss%TYPE,
  p_num_cache_hit       IN      jtf_prefab_cache_stats.num_cache_hit%TYPE,
  p_num_loader_miss     IN      jtf_prefab_cache_stats.num_loader_miss%TYPE,
  p_num_invalidate_call IN      jtf_prefab_cache_stats.num_invalidate_call%TYPE,
  p_num_invalidations   IN      jtf_prefab_cache_stats.num_invalidations%TYPE,
  p_num_objects         IN      jtf_prefab_cache_stats.num_objects%TYPE,
  p_expiration_time     IN      jtf_prefab_cache_stats.expiration_time%TYPE,
  p_start_time          IN      jtf_prefab_cache_stats.start_time%TYPE,
  p_end_time            IN      jtf_prefab_cache_stats.end_time%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_cache_stats.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_CACHE_STAT(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure RESET_CACHE_STAT(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,
  p_wsh_po_id           IN      NUMBER,
  p_ca_comp_id          IN      NUMBER,
  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE INSERT_CA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        OUT  NOCOPY   jtf_prefab_ca_filters_b.ca_filter_id%TYPE,
  p_application_id      IN      jtf_prefab_ca_filters_b.application_id%TYPE,
  p_ca_filter_name      IN      jtf_prefab_ca_filters_b.ca_filter_name%TYPE,
  p_description         IN      jtf_prefab_ca_filters_tl.description%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_ca_filters_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE UPDATE_CA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        IN      jtf_prefab_ca_filters_b.ca_filter_id%TYPE,
  p_application_id      IN      jtf_prefab_ca_filters_b.application_id%TYPE,
  p_ca_filter_name      IN      jtf_prefab_ca_filters_b.ca_filter_name%TYPE,
  p_description         IN      jtf_prefab_ca_filters_tl.description%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_ca_filters_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_CA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        IN      jtf_prefab_ca_filters_b.ca_filter_id%TYPE,

  p_object_version_number IN    jtf_prefab_ca_filters_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE INSERT_HA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ha_filter_id        OUT  NOCOPY   jtf_prefab_ha_filters.ha_filter_id%TYPE,
  p_host_app_id         IN      jtf_prefab_ha_filters.host_app_id%TYPE,
  p_ca_filter_id        IN      jtf_prefab_ha_filters.ca_filter_id%TYPE,
  p_cache_filter_enabled_flag IN jtf_prefab_ha_filters.cache_filter_enabled_flag%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_ha_filters.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE UPDATE_HA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ha_filter_id        IN      jtf_prefab_ha_filters.ha_filter_id%TYPE,
  p_cache_filter_enabled_flag IN jtf_prefab_ha_filters.cache_filter_enabled_flag%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_ha_filters.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_HA_FILTERS_F_HOST_APP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_host_app_id         IN      jtf_prefab_ha_filters.host_app_id%TYPE,

  p_object_version_number IN    jtf_prefab_ha_filters.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_HA_FILTERS_F_CA_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        IN      jtf_prefab_ha_filters.ca_filter_id%TYPE,

  p_object_version_number IN    jtf_prefab_ha_filters.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE INSERT_CA_FL_RESP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_fl_resp_id       OUT  NOCOPY   jtf_prefab_ca_fl_resps.ca_fl_resp_id%TYPE,
  p_ca_filter_id        IN      jtf_prefab_ca_fl_resps.ca_filter_id%TYPE,
  p_responsibility_id   IN      jtf_prefab_ca_fl_resps.responsibility_id%TYPE,

  p_object_version_number OUT  NOCOPY jtf_prefab_ca_fl_resps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_CA_FL_RESP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id           IN      jtf_prefab_ca_fl_resps.ca_filter_id%TYPE,

  p_object_version_number IN    jtf_prefab_ca_fl_resps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_CA_FL_RESP(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        IN      jtf_prefab_ca_fl_resps.ca_filter_id%TYPE,
  p_responsibility_id   IN      jtf_prefab_ca_fl_resps.responsibility_id%TYPE,

  p_object_version_number IN    jtf_prefab_ca_fl_resps.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

PROCEDURE INSERT_CA_FL_LANG(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_fl_lang_id       OUT  NOCOPY   jtf_prefab_ca_fl_langs.ca_fl_lang_id%TYPE,
  p_ca_filter_id        IN      jtf_prefab_ca_fl_langs.ca_filter_id%TYPE,
  p_language_code       IN      jtf_prefab_ca_fl_langs.language_code%TYPE,

  p_object_version_number OUT  NOCOPY jtf_prefab_ca_fl_langs.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_CA_FL_LANG(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id           IN      jtf_prefab_ca_fl_langs.ca_filter_id%TYPE,

  p_object_version_number IN    jtf_prefab_ca_fl_langs.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

procedure DELETE_CA_FL_LANG(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ca_filter_id        IN      jtf_prefab_ca_fl_langs.ca_filter_id%TYPE,
  p_language_code       IN      jtf_prefab_ca_fl_langs.language_code%TYPE,

  p_object_version_number IN    jtf_prefab_ca_fl_langs.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY   VARCHAR2,
  x_msg_count           OUT  NOCOPY   NUMBER,
  x_msg_data            OUT  NOCOPY   VARCHAR2
);

END JTF_PREFAB_CACHE_PUB;

 

/
