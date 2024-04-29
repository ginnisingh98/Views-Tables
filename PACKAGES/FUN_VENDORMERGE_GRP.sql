--------------------------------------------------------
--  DDL for Package FUN_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: funntsms.pls 120.3 2006/03/13 10:32:57 asrivats noship $ */


    PROCEDURE Merge_Vendor(
            -- ***** Standard API Parameters *****
	p_api_version         IN   NUMBER,
	p_init_msg_list       IN   VARCHAR2 default FND_API.G_FALSE,
	p_commit              IN   VARCHAR2 default FND_API.G_FALSE,
	p_validation_level    IN   NUMBER   default FND_API.G_VALID_LEVEL_FULL,
	p_return_status       OUT  NOCOPY   VARCHAR2,
	p_msg_count           OUT  NOCOPY   NUMBER ,
	p_msg_data            OUT  NOCOPY   VARCHAR2,
           -- ****** Merge Input Parameters ******
	p_vendor_id           IN            NUMBER ,
	p_dup_vendor_id       IN            NUMBER ,
	p_vendor_site_id      IN            NUMBER ,
	p_dup_vendor_site_id  IN            NUMBER
	);

END FUN_VendorMerge_GRP;

 

/
