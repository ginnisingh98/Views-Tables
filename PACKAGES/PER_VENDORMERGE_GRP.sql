--------------------------------------------------------
--  DDL for Package PER_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: pevndmrg.pkh 120.0 2006/03/31 05:27:53 bshukla noship $ */
--
-- -- --------------------------------------------------------------------- *
-- Name    : Merge_Vendor
-- -- --------------------------------------------------------------------- *
-- {Start Of Comments}
--
-- Description:
--    This procedure updates HR data when two vendors are merged.
--
-- Pre Conditions:
--   None.
--
-- {End Of Comments}
-- -- --------------------------------------------------------------------- *
procedure merge_vendor
(p_api_version            IN            NUMBER
,p_init_msg_list          IN            VARCHAR2 default FND_API.G_FALSE
,p_commit                 IN            VARCHAR2 default FND_API.G_FALSE
,p_validation_level       IN            NUMBER   default FND_API.G_VALID_LEVEL_FULL
,p_return_status          OUT  NOCOPY   VARCHAR2
,p_msg_count              OUT  NOCOPY   NUMBER
,p_msg_data               OUT  NOCOPY   VARCHAR2
,p_vendor_id              IN            NUMBER
,p_dup_vendor_id          IN            NUMBER
,p_vendor_site_id         IN            NUMBER
,p_dup_vendor_site_id     IN            NUMBER
,p_party_id               IN            NUMBER
,P_dup_party_id           IN            NUMBER
,p_party_site_id          IN            NUMBER
,p_dup_party_site_id      IN            NUMBER
);
END per_vendormerge_grp;

 

/
