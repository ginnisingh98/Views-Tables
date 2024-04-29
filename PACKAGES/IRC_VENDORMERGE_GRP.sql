--------------------------------------------------------
--  DDL for Package IRC_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: irvndmrg.pkh 120.0 2005/09/12 07:03:09 mmillmor noship $ */
--
-- -- --------------------------------------------------------------------- *
-- Name    : Merge_Vendor
-- -- --------------------------------------------------------------------- *
-- {Start Of Comments}
--
-- Description:
--    This procedure updates iRec data when two vendors are merged.
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
END irc_vendormerge_grp;

 

/
