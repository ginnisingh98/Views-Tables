--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCT_SITE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCT_SITE_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHBCSVS.pls 120.3 2008/02/06 10:26:08 vsegu ship $ */

  -- PROCEDURE create_cust_site_uses
  --
  -- DESCRIPTION
  --     Create customer account site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_casu_objs          List of customer account site use objects.
  --     p_ca_id              Customer account Id.
  --     p_cas_id             Customer account site Id.
  --     p_parent_os          Parent original system.
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

  PROCEDURE create_cust_site_uses(
    p_casu_objs               IN OUT NOCOPY HZ_CUST_SITE_USE_BO_TBL,
    p_ca_id                   IN            NUMBER,
    p_cas_id                  IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_site_uses
  --
  -- DESCRIPTION
  --     Create or update customer account site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_casu_objs          List of customer account site use objects.
  --     p_ca_id              Customer account Id.
  --     p_cas_id             Customer account site Id.
  --     p_parent_os          Parent original system.
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

  PROCEDURE save_cust_site_uses(
    p_casu_objs               IN OUT NOCOPY HZ_CUST_SITE_USE_BO_TBL,
    p_ca_id                   IN            NUMBER,
    p_cas_id                  IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_acct_sites
  --
  -- DESCRIPTION
  --     Create or update customer account sites.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cas_objs           List of customer account site objects.
  --     p_create_update_flag Create or update flag.
  --     p_parent_acct_id     Parent customer account Id.
  --     p_parent_acct_os     Parent customer account original system.
  --     p_parent_acct_osr    Parent customer account original system reference.
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

  PROCEDURE save_cust_acct_sites(
    p_cas_objs                IN OUT NOCOPY HZ_CUST_ACCT_SITE_BO_TBL,
    p_create_update_flag      IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    p_parent_acct_id          IN            NUMBER,
    p_parent_acct_os          IN            VARCHAR2,
    p_parent_acct_osr         IN            VARCHAR2
  );

  -- PROCEDURE create_cust_site_v2_uses
  --
  -- DESCRIPTION
  --     Create customer account site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_casu_v2_objs          List of customer account site use objects.
  --     p_ca_id              Customer account Id.
  --     p_cas_id             Customer account site Id.
  --     p_parent_os          Parent original system.
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
  --   31-JAN-2008   vsegu           Created.

  PROCEDURE create_cust_site_v2_uses(
    p_casu_v2_objs               IN OUT NOCOPY HZ_CUST_SITE_USE_V2_BO_TBL,
    p_ca_id                   IN            NUMBER,
    p_cas_id                  IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_site_v2_uses
  --
  -- DESCRIPTION
  --     Create or update customer account site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_casu_v2_objs          List of customer account site use objects.
  --     p_ca_id              Customer account Id.
  --     p_cas_id             Customer account site Id.
  --     p_parent_os          Parent original system.
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
  --    31-JAN-2008   vsegu     Created.

  PROCEDURE save_cust_site_v2_uses(
    p_casu_v2_objs               IN OUT NOCOPY HZ_CUST_SITE_USE_V2_BO_TBL,
    p_ca_id                   IN            NUMBER,
    p_cas_id                  IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_acct_v2_sites
  --
  -- DESCRIPTION
  --     Create or update customer account sites.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cas_v2_objs           List of customer account site objects.
  --     p_create_update_flag Create or update flag.
  --     p_parent_acct_id     Parent customer account Id.
  --     p_parent_acct_os     Parent customer account original system.
  --     p_parent_acct_osr    Parent customer account original system reference.
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
  --   31-JAN-2008    vsegu      Created.

  PROCEDURE save_cust_acct_v2_sites(
    p_cas_v2_objs                IN OUT NOCOPY HZ_CUST_ACCT_SITE_V2_BO_TBL,
    p_create_update_flag      IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    p_parent_acct_id          IN            NUMBER,
    p_parent_acct_os          IN            VARCHAR2,
    p_parent_acct_osr         IN            VARCHAR2
  );

END HZ_CUST_ACCT_SITE_BO_PVT;

/
