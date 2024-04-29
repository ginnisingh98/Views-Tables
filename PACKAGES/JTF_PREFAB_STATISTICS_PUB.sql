--------------------------------------------------------
--  DDL for Package JTF_PREFAB_STATISTICS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PREFAB_STATISTICS_PUB" AUTHID CURRENT_USER as
/* $Header: jtfprefabsts.pls 120.3 2005/10/28 00:23:12 emekala ship $ */

PROCEDURE INSERT_STATISTICS(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_statistics.policy_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_statistics.wsh_po_id%TYPE,
  p_start_time          IN      jtf_prefab_statistics.start_time%TYPE,
  p_end_time            IN      jtf_prefab_statistics.end_time%TYPE,
  p_last_update_time    IN      jtf_prefab_statistics.last_update_time%TYPE,
  p_pages_last_run      IN      jtf_prefab_statistics.pages_last_run%TYPE,
  p_pages_crawled       IN      jtf_prefab_statistics.pages_crawled%TYPE,
  p_refresh_rate        IN      jtf_prefab_statistics.refresh_rate%TYPE,
  p_system_status       IN      jtf_prefab_statistics.system_status%TYPE,
  p_error_status        IN      jtf_prefab_statistics.error_status%TYPE,
  p_depth               IN      jtf_prefab_statistics.depth%TYPE,
  p_disk_used           IN      jtf_prefab_statistics.disk_used%TYPE,
  p_avg_mem             IN      jtf_prefab_statistics.avg_mem%TYPE,
  p_avg_cpu             IN      jtf_prefab_statistics.avg_cpu%TYPE,
  p_hit_rate            IN      jtf_prefab_statistics.hit_rate%TYPE,

  p_object_version_number OUT  NOCOPY     NUMBER,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
);

PROCEDURE UPDATE_STATISTICS (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_statistics.policy_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_statistics.wsh_po_id%TYPE,
  p_start_time          IN      jtf_prefab_statistics.start_time%TYPE,
  p_end_time            IN      jtf_prefab_statistics.end_time%TYPE,
  p_last_update_time    IN      jtf_prefab_statistics.last_update_time%TYPE,
  p_pages_last_run      IN      jtf_prefab_statistics.pages_last_run%TYPE,
  p_pages_crawled       IN      jtf_prefab_statistics.pages_crawled%TYPE,
  p_refresh_rate        IN      jtf_prefab_statistics.refresh_rate%TYPE,
  p_system_status       IN      jtf_prefab_statistics.system_status%TYPE,
  p_error_status        IN      jtf_prefab_statistics.error_status%TYPE,
  p_depth               IN      jtf_prefab_statistics.depth%TYPE,
  p_disk_used           IN      jtf_prefab_statistics.disk_used%TYPE,
  p_avg_mem             IN      jtf_prefab_statistics.avg_mem%TYPE,
  p_avg_cpu             IN      jtf_prefab_statistics.avg_cpu%TYPE,
  p_hit_rate            IN      jtf_prefab_statistics.hit_rate%TYPE,

  p_object_version_number IN OUT  NOCOPY     NUMBER,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
);

PROCEDURE DELETE_STATISTICS (
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      NUMBER,
  p_wsh_po_id           IN      NUMBER,

  p_object_version_number      IN      NUMBER,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
);

PROCEDURE SELECT_STATISTICS(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_statistics.policy_id%TYPE,
  p_wsh_po_id           IN      jtf_prefab_statistics.wsh_po_id%TYPE,
  p_start_time          OUT  NOCOPY     jtf_prefab_statistics.start_time%TYPE,
  p_end_time            OUT  NOCOPY     jtf_prefab_statistics.end_time%TYPE,
  p_last_update_time    OUT  NOCOPY     jtf_prefab_statistics.last_update_time%TYPE,
  p_pages_last_run      OUT  NOCOPY     jtf_prefab_statistics.pages_last_run%TYPE,
  p_pages_crawled       OUT  NOCOPY     jtf_prefab_statistics.pages_crawled%TYPE,
  p_refresh_rate        OUT  NOCOPY     jtf_prefab_statistics.refresh_rate%TYPE,
  p_system_status       OUT  NOCOPY     jtf_prefab_statistics.system_status%TYPE,
  p_error_status        OUT  NOCOPY     jtf_prefab_statistics.error_status%TYPE,
  p_depth               OUT  NOCOPY     jtf_prefab_statistics.depth%TYPE,
  p_disk_used           OUT  NOCOPY     jtf_prefab_statistics.disk_used%TYPE,
  p_avg_mem             OUT  NOCOPY     jtf_prefab_statistics.avg_mem%TYPE,
  p_avg_cpu             OUT  NOCOPY     jtf_prefab_statistics.avg_cpu%TYPE,
  p_hit_rate            OUT  NOCOPY     jtf_prefab_statistics.hit_rate%TYPE,

  p_object_version_number OUT  NOCOPY   NUMBER,
  p_row_count           OUT  NOCOPY     NUMBER,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
);

END JTF_PREFAB_STATISTICS_PUB;

 

/
