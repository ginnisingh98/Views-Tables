--------------------------------------------------------
--  DDL for Package PO_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: PO_VendorMerge_GRP.pls 120.0 2006/02/20 03:58:17 scolvenk noship $ */



Procedure Merge_Vendor(
            p_api_version        IN   NUMBER,
	    p_init_msg_list      IN   VARCHAR2 default FND_API.G_FALSE,
	    p_commit             IN   VARCHAR2 default FND_API.G_FALSE,
	    p_validation_level   IN   NUMBER   default FND_API.G_VALID_LEVEL_FULL,
	    x_return_status      OUT  NOCOPY VARCHAR2,
	    x_msg_count          OUT  NOCOPY NUMBER,
	    x_msg_data           OUT  NOCOPY VARCHAR2,
	    p_vendor_id          IN   NUMBER,
	    p_vendor_site_id     IN   NUMBER,
	    p_dup_vendor_id      IN   NUMBER,
	    p_dup_vendor_site_id IN   NUMBER,
	    p_party_id           IN   NUMBER default NULL,
            p_dup_party_id       IN   NUMBER default NULL,
            p_party_site_id      IN   NUMBER default NULL,
            p_dup_party_site_id  IN   NUMBER default NULL
	    );

END;


 

/
