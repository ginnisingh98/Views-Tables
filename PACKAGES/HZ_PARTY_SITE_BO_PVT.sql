--------------------------------------------------------
--  DDL for Package HZ_PARTY_SITE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_SITE_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHBPSVS.pls 120.3 2006/05/18 22:28:23 acng noship $ */

  -- PROCEDURE create_party_site_uses
  --
  -- DESCRIPTION
  --     Create party site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_psu_objs           List of party site use objects.
  --     p_ps_id              Party site Id.
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

  PROCEDURE create_party_site_uses(
    p_psu_objs                   IN OUT NOCOPY HZ_PARTY_SITE_USE_OBJ_TBL,
    p_ps_id                      IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_party_site_uses
  --
  -- DESCRIPTION
  --     Create or update party site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_psu_objs           List of party site use objects.
  --     p_ps_id              Party site Id.
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

  PROCEDURE save_party_site_uses(
    p_psu_objs                   IN OUT NOCOPY HZ_PARTY_SITE_USE_OBJ_TBL,
    p_ps_id                      IN         NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2
  );

  -- PROCEDURE save_party_sites
  --
  -- DESCRIPTION
  --     Create or update party sites.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ps_objs            List of party site objects.
  --     p_create_update_flag Create or update flag.
  --     p_parent_id          Parent Id.
  --     p_parent_os          Parent original system.
  --     p_parent_osr         Parent original system reference.
  --     p_parent_obj_type    Parent object type.
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

  PROCEDURE save_party_sites(
    p_ps_objs                    IN OUT NOCOPY HZ_PARTY_SITE_BO_TBL,
    p_create_update_flag         IN         VARCHAR2,
    p_obj_source                 IN         VARCHAR2 := null,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,
    p_parent_id                  IN         NUMBER,
    p_parent_os                  IN         VARCHAR2,
    p_parent_osr                 IN         VARCHAR2,
    p_parent_obj_type            IN         VARCHAR2
  );

END HZ_PARTY_SITE_BO_PVT;

 

/
