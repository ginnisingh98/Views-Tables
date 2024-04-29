--------------------------------------------------------
--  DDL for Package JTF_PREFAB_UD_KEY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PREFAB_UD_KEY_PUB" AUTHID CURRENT_USER as
/* $Header: jtfprefabuds.pls 120.2 2005/10/28 00:24:24 emekala ship $ */

PROCEDURE INSERT_UD_KEY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ud_key_id           OUT  NOCOPY     jtf_prefab_ud_keys_b.ud_key_id%TYPE,
  p_application_id      IN      jtf_prefab_ud_keys_b.application_id%TYPE,
  p_ud_key_name         IN      jtf_prefab_ud_keys_b.ud_key_name%TYPE,
  p_description         IN      jtf_prefab_ud_keys_tl.description%TYPE,
  p_filename            IN      jtf_prefab_ud_keys_b.filename%TYPE,
  p_user_defined_keys   IN      jtf_prefab_ud_keys_b.user_defined_keys%TYPE,
  p_enabled_flag        IN      jtf_prefab_ud_keys_b.enabled_flag%TYPE,

  p_object_version_number OUT  NOCOPY   jtf_prefab_ud_keys_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
);

PROCEDURE UPDATE_UD_KEY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ud_key_id           IN      jtf_prefab_ud_keys_b.ud_key_id%TYPE,
  p_application_id      IN      jtf_prefab_ud_keys_b.application_id%TYPE,
  p_ud_key_name         IN      jtf_prefab_ud_keys_b.ud_key_name%TYPE,
  p_description         IN      jtf_prefab_ud_keys_tl.description%TYPE,
  p_filename            IN      jtf_prefab_ud_keys_b.filename%TYPE,
  p_user_defined_keys   IN      jtf_prefab_ud_keys_b.user_defined_keys%TYPE,
  p_enabled_flag        IN      jtf_prefab_ud_keys_b.enabled_flag%TYPE,

  p_object_version_number IN OUT  NOCOPY jtf_prefab_ud_keys_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
);

procedure DELETE_UD_KEY(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2        := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2        := FND_API.G_FALSE,

  p_ud_key_id           IN      jtf_prefab_ud_keys_b.ud_key_id%TYPE,

  p_object_version_number IN    jtf_prefab_ud_keys_b.object_version_number%TYPE,

  x_return_status       OUT  NOCOPY     VARCHAR2,
  x_msg_count           OUT  NOCOPY     NUMBER,
  x_msg_data            OUT  NOCOPY     VARCHAR2
);

END JTF_PREFAB_UD_KEY_PUB;

 

/
