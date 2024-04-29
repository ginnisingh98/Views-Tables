--------------------------------------------------------
--  DDL for Package HZ_AIA_CUSTOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_AIA_CUSTOM_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHAIACS.pls 120.0 2007/12/06 18:32:58 awu noship $ */

  PROCEDURE sync_acct_update
  (
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_org_cust_obj         IN            HZ_ORG_CUST_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_ORG_CUST_BO
  );

  PROCEDURE sync_acct_order
  (
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_org_cust_obj         IN            HZ_ORG_CUST_BO,
    p_created_by_module    IN            VARCHAR2,
    p_obj_source           IN            VARCHAR2 := null,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj           OUT NOCOPY    HZ_ORG_CUST_BO
  );

  PROCEDURE get_acct_merge_obj(
    p_customer_merge_header_id  IN         NUMBER,
    x_account_merge_obj         OUT NOCOPY CRMINTEG_HZ_MERGE_OBJ
  );

  PROCEDURE get_related_org_cust_objs(
    p_batch_id                IN NUMBER,
    p_merge_to_party_id       IN NUMBER,
    x_org_cust_objs           OUT NOCOPY    HZ_ORG_CUST_BO_TBL
  );

  PROCEDURE get_party_merge_objs(
    p_batch_id                  IN         NUMBER,
    p_merge_to_party_id         IN         NUMBER,
    x_party_merge_objs          OUT NOCOPY CRMINTEG_HZ_MERGE_OBJ_TBL
  );

  PROCEDURE get_merge_org_custs(
    p_init_msg_list        IN            VARCHAR2 := FND_API.G_FALSE,
    p_from_org_id          IN            NUMBER,
    p_to_org_id            IN            NUMBER,
    p_from_acct_id         IN            NUMBER,
    p_to_acct_id           IN            NUMBER,
    x_org_cust_objs        OUT NOCOPY    HZ_ORG_CUST_BO_TBL,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_messages             OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  );

END HZ_AIA_CUSTOM_PKG;

/
