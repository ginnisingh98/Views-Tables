--------------------------------------------------------
--  DDL for Package HZ_ORG_CONTACT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORG_CONTACT_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHBOCVS.pls 120.3 2006/05/18 22:26:45 acng noship $ */

  -- PROCEDURE create_org_contact_roles
  --
  -- DESCRIPTION
  --     Create org contact roles.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ocr_objs           List of org contact role objects.
  --     p_oc_id              Org contact Id.
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

  PROCEDURE create_org_contact_roles(
    p_ocr_objs              IN OUT NOCOPY HZ_ORG_CONTACT_ROLE_OBJ_TBL,
    p_oc_id                 IN            NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_org_contact_roles
  --
  -- DESCRIPTION
  --     Create or update org contact roles.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ocr_objs           List of org contact role objects.
  --     p_oc_id              Org contact Id.
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

  PROCEDURE save_org_contact_roles(
    p_ocr_objs              IN OUT NOCOPY HZ_ORG_CONTACT_ROLE_OBJ_TBL,
    p_oc_id                 IN            NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_org_contacts
  --
  -- DESCRIPTION
  --     Create or update org contacts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_oc_objs            List of org contact business objects.
  --     p_create_update_flag Create or update flag.
  --     p_parent_org_id      Parent organization Id.
  --     p_parent_org_os      Parent organization original system.
  --     p_parent_org_osr     Parent organization original system reference.
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

  PROCEDURE save_org_contacts(
    p_oc_objs             IN OUT NOCOPY HZ_ORG_CONTACT_BO_TBL,
    p_create_update_flag  IN            VARCHAR2,
    p_obj_source          IN            VARCHAR2 := null,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2,
    p_parent_org_id       IN OUT NOCOPY NUMBER,
    p_parent_org_os       IN OUT NOCOPY VARCHAR2,
    p_parent_org_osr      IN OUT NOCOPY VARCHAR2
  );

END HZ_ORG_CONTACT_BO_PVT;

 

/
