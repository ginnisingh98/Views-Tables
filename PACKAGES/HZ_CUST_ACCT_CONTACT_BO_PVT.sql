--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCT_CONTACT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCT_CONTACT_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHBCRVS.pls 120.2 2006/05/18 22:24:33 acng noship $ */

  -- PROCEDURE create_role_responsbilities
  --
  -- DESCRIPTION
  --     Create role responsibilities.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_rr_objs            List of role responsibility objects.
  --     p_cac_id             Customer account contact Id.
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

  PROCEDURE create_role_responsibilities(
    p_rr_objs                 IN OUT NOCOPY HZ_ROLE_RESPONSIBILITY_OBJ_TBL,
    p_cac_id                  IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_role_responsbilities
  --
  -- DESCRIPTION
  --     Create or update role responsibilities.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_rr_objs            List of role responsibility objects.
  --     p_cac_id             Customer account contact Id.
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

  PROCEDURE save_role_responsibilities(
    p_rr_objs                 IN OUT NOCOPY HZ_ROLE_RESPONSIBILITY_OBJ_TBL,
    p_cac_id                  IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_acct_contacts
  --
  -- DESCRIPTION
  --     Create or update customer account contact.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cac_objs           List of customer account contact objects.
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

  PROCEDURE save_cust_acct_contacts(
    p_cac_objs                IN OUT NOCOPY HZ_CUST_ACCT_CONTACT_BO_TBL,
    p_create_update_flag      IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    p_parent_id               IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    p_parent_osr              IN            VARCHAR2,
    p_parent_obj_type         IN            VARCHAR2
  );

END HZ_CUST_ACCT_CONTACT_BO_PVT;

 

/
