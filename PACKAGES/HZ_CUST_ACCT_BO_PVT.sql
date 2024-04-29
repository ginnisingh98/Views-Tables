--------------------------------------------------------
--  DDL for Package HZ_CUST_ACCT_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_ACCT_BO_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHBCAVS.pls 120.3 2008/02/06 09:48:02 vsegu ship $ */

  -- PROCEDURE assign_cust_profile_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer profile object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_profile_obj   Customer profile object.
  --     p_cust_acct_id       Customer account Id.
  --     p_site_use_id        Customer account site use Id.
  --   IN/OUT:
  --     px_cust_profile_rec  Customer profile plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_cust_profile_rec(
    p_cust_profile_obj           IN            HZ_CUSTOMER_PROFILE_BO,
    p_cust_acct_id               IN            NUMBER,
    p_site_use_id                IN            NUMBER,
    px_cust_profile_rec          IN OUT NOCOPY HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE
  );

  -- PROCEDURE create_cust_profile
  --
  -- DESCRIPTION
  --     Create customer profile.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cp_obj             Customer profile object.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
  --   OUT:
  --     x_cp_id              Customer profile Id.
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

  PROCEDURE create_cust_profile(
    p_cp_obj                  IN OUT NOCOPY HZ_CUSTOMER_PROFILE_BO,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_cp_id                   OUT NOCOPY    NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE update_cust_profile
  --
  -- DESCRIPTION
  --     Update customer profile.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cp_obj             Customer profile object.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
  --   OUT:
  --     x_cp_id              Customer profile Id.
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

  PROCEDURE update_cust_profile(
    p_cp_obj                  IN OUT NOCOPY HZ_CUSTOMER_PROFILE_BO,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_cp_id                   OUT NOCOPY    NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE create_cust_profile_amts
  --
  -- DESCRIPTION
  --     Create customer profile amounts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cpa_objs           List of customer profile amount objects.
  --     p_cp_id              Customer profile Id.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
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

  PROCEDURE create_cust_profile_amts(
    p_cpa_objs                IN OUT NOCOPY HZ_CUST_PROFILE_AMT_OBJ_TBL,
    p_cp_id                   IN            NUMBER,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_profile_amts
  --
  -- DESCRIPTION
  --     Create or update customer profile amounts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cpa_objs           List of customer profile amount objects.
  --     p_cp_id              Customer profile Id.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
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

  PROCEDURE save_cust_profile_amts(
    p_cpa_objs                IN OUT NOCOPY HZ_CUST_PROFILE_AMT_OBJ_TBL,
    p_cp_id                   IN            NUMBER,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE create_cust_acct_relates
  --
  -- DESCRIPTION
  --     Create customer account relationships.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_car_objs           List of customer account relationship objects.
  --     p_ca_id              Customer account Id.
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

  PROCEDURE create_cust_acct_relates(
    p_car_objs                IN OUT NOCOPY HZ_CUST_ACCT_RELATE_OBJ_TBL,
    p_ca_id                   IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_acct_relates
  --
  -- DESCRIPTION
  --     Create or update customer account relationships.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_car_objs           List of customer account relationship objects.
  --     p_ca_id              Customer account Id.
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

  PROCEDURE save_cust_acct_relates(
    p_car_objs                IN OUT NOCOPY HZ_CUST_ACCT_RELATE_OBJ_TBL,
    p_ca_id                   IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_bank_acct_uses
  --
  -- DESCRIPTION
  --     Create or update bank account assignments.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_bank_acct_use_objs List of bank account assignment objects.
  --     p_party_id           Party Id.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
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

  PROCEDURE save_bank_acct_uses(
    p_bank_acct_use_objs      IN OUT NOCOPY HZ_BANK_ACCT_USE_OBJ_TBL,
    p_party_id                IN            NUMBER,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE create_payment_method
  --
  -- DESCRIPTION
  --     Create payment method.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_obj Payment method object.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
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

  PROCEDURE create_payment_method(
    p_payment_method_obj      IN OUT NOCOPY HZ_PAYMENT_METHOD_OBJ,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_payment_method
  --
  -- DESCRIPTION
  --     Create or update payment method.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_obj Payment method object.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
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

  PROCEDURE save_payment_method(
    p_payment_method_obj      IN OUT NOCOPY HZ_PAYMENT_METHOD_OBJ,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_cust_accts
  --
  -- DESCRIPTION
  --     Create or update customer accounts.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_ca_objs            List of customer account objects.
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

  PROCEDURE save_cust_accts(
    p_ca_objs                 IN OUT NOCOPY HZ_CUST_ACCT_BO_TBL,
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

  PROCEDURE save_cust_accts(
    p_ca_v2_objs                 IN OUT NOCOPY HZ_CUST_ACCT_V2_BO_TBL,
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

  -- PROCEDURE create_payment_methods
  --
  -- DESCRIPTION
  --     Create payment methods.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_objs Payment method object.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
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
  --   1-FEB-2008    vsegu          Created.

  PROCEDURE create_payment_methods(
    p_payment_method_objs      IN OUT NOCOPY HZ_PAYMENT_METHOD_OBJ_TBL,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

  -- PROCEDURE save_payment_methods
  --
  -- DESCRIPTION
  --     Create or update payment methods.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_payment_method_objs Payment method object.
  --     p_ca_id              Customer account Id.
  --     p_casu_id            Customer account site use Id.
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
  --   1-FEB-2008    vsegu          Created.

  PROCEDURE save_payment_methods(
    p_payment_method_objs      IN OUT NOCOPY HZ_PAYMENT_METHOD_OBJ_TBL,
    p_ca_id                   IN            NUMBER,
    p_casu_id                 IN            NUMBER,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  );

END HZ_CUST_ACCT_BO_PVT;

/
