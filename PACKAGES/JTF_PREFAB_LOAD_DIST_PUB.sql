--------------------------------------------------------
--  DDL for Package JTF_PREFAB_LOAD_DIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PREFAB_LOAD_DIST_PUB" AUTHID CURRENT_USER as
/* $Header: jtfprefablds.pls 120.2 2005/10/28 00:07:44 emekala ship $ */

PROCEDURE INSERT_PRB(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_policy_id           IN      jtf_prefab_prbs.policy_id%TYPE,
  p_uri                 IN      jtf_prefab_prbs.uri%TYPE,
  p_user_id             IN      jtf_prefab_prbs.user_id%TYPE,
  p_responsibility_id   IN      jtf_prefab_prbs.responsibility_id%TYPE,
  p_application_id      IN      jtf_prefab_prbs.application_id%TYPE,
  p_prefab_hostname     IN      jtf_prefab_prbs.prefab_hostname%TYPE,

  p_object_version_number OUT  NOCOPY  jtf_prefab_prbs.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY    VARCHAR2,
  x_msg_count           OUT  NOCOPY    NUMBER,
  x_msg_data            OUT  NOCOPY    VARCHAR2
);

END JTF_PREFAB_LOAD_DIST_PUB;

 

/
