--------------------------------------------------------
--  DDL for Package Body POS_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_VENDORMERGE_GRP" as
-- $Header: POSVMGB.pls 120.1 2005/08/17 16:07:03 bfreeman noship $


PROCEDURE merge_vendor
(
     p_api_version            IN            NUMBER
,    p_init_msg_list          IN            VARCHAR2 default FND_API.G_FALSE
,    p_commit                 IN            VARCHAR2 default FND_API.G_FALSE
,    p_validation_level       IN            NUMBER   default FND_API.G_VALID_LEVEL_FULL
,    p_return_status          OUT  NOCOPY   VARCHAR2
,    p_msg_count              OUT  NOCOPY   NUMBER
,    p_msg_data               OUT  NOCOPY   VARCHAR2
,    p_vendor_id              IN            NUMBER
,    p_dup_vendor_id          IN            NUMBER
,    p_vendor_site_id         IN            NUMBER
,    p_dup_vendor_site_id     IN            NUMBER
,    p_party_id               IN            NUMBER
,    p_dup_party_id           IN            NUMBER
,    p_party_site_id          IN            NUMBER
,    p_dup_party_site_id      IN            NUMBER
)
IS
BEGIN
  pos_sup_prof_mrg_grp.handle_merge(p_vendor_id,
               p_vendor_site_id,
               p_dup_vendor_id,
               p_dup_vendor_site_id,
               p_return_status);
END;

END POS_VENDORMERGE_GRP;

/
