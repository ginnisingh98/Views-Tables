--------------------------------------------------------
--  DDL for Package JTF_PREFAB_FILTER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PREFAB_FILTER_PUB" AUTHID CURRENT_USER as
/* $Header: jtfprefabfls.pls 120.2 2005/10/28 00:07:04 emekala ship $ */

PROCEDURE INSERT_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_filter_id           OUT  NOCOPY  jtf_prefab_filters_b.filter_id%TYPE,
  p_filter_name         IN jtf_prefab_filters_b.filter_name%TYPE,
  p_application_id      IN jtf_prefab_filters_b.application_id%TYPE,
  p_description         IN jtf_prefab_filters_tl.description%TYPE,
  p_filter_string       IN jtf_prefab_filters_b.filter_string%TYPE,
  p_exclusion_flag      IN jtf_prefab_filters_b.exclusion_flag%TYPE,
  p_enabled_flag        IN jtf_prefab_filters_b.enabled_flag%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_filters_b.object_version_number%TYPE,

  x_return_status       OUT   NOCOPY  VARCHAR2,
  x_msg_count           OUT   NOCOPY  NUMBER,
  x_msg_data            OUT   NOCOPY  VARCHAR2
);

PROCEDURE UPDATE_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_filter_id           IN jtf_prefab_filters_b.filter_id%TYPE,
  p_filter_name         IN jtf_prefab_filters_b.filter_name%TYPE,
  p_application_id      IN jtf_prefab_filters_b.application_id%TYPE,
  p_description         IN jtf_prefab_filters_tl.description%TYPE,
  p_filter_string       IN jtf_prefab_filters_b.filter_string%TYPE,
  p_exclusion_flag      IN jtf_prefab_filters_b.exclusion_flag%TYPE,
  p_enabled_flag        IN jtf_prefab_filters_b.enabled_flag%TYPE,

  p_object_version_number IN OUT  NOCOPY  jtf_prefab_filters_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
);

procedure DELETE_FILTER(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_filter_id           IN      jtf_prefab_filters_b.filter_id%TYPE,

  p_object_version_number IN    jtf_prefab_filters_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

END JTF_PREFAB_FILTER_PUB;

 

/
