--------------------------------------------------------
--  DDL for Package HZ_CONTACT_PREFERENCE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CONTACT_PREFERENCE_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHBCTVS.pls 120.3 2006/05/18 22:25:31 acng noship $ */

  -- PROCEDURE create_contact_preferences
  --
  -- DESCRIPTION
  --     Create contact preferences.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cp_pref_objs       List of contact preference objects.
  --     p_contact_level_table_id   Contact level table Id.
  --     p_contact_level_table      Contact level table.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE create_contact_preferences(
    p_cp_pref_objs            IN OUT NOCOPY HZ_CONTACT_PREF_OBJ_TBL,
    p_contact_level_table_id  IN         NUMBER,
    p_contact_level_table     IN         VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_contact_preferences
  --
  -- DESCRIPTION
  --     Create or update contact preferences.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cp_pref_objs       List of contact preference objects.
  --     p_contact_level_table_id   Contact level table Id.
  --     p_contact_level_table      Contact level table.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.
  --

  PROCEDURE save_contact_preferences(
    p_cp_pref_objs            IN OUT NOCOPY HZ_CONTACT_PREF_OBJ_TBL,
    p_contact_level_table_id  IN         NUMBER,
    p_contact_level_table     IN         VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2
  );

END HZ_CONTACT_PREFERENCE_BO_PVT;

 

/
