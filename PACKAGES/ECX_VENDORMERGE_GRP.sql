--------------------------------------------------------
--  DDL for Package ECX_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_VENDORMERGE_GRP" AUTHID CURRENT_USER as
/* $Header: ECXPVMRS.pls 120.0 2005/08/26 20:32:56 sbastida noship $ */

procedure Merge_Vendor (
    p_api_version		 IN	       NUMBER,
    p_init_msg_list 	 IN	       VARCHAR2 default FND_API.G_FALSE,
    p_commit		 IN	       VARCHAR2 default FND_API.G_FALSE,
    p_validation_level	 IN	       NUMBER	default FND_API.G_VALID_LEVEL_FULL,
    p_return_status 	 OUT  NOCOPY   VARCHAR2,
    p_msg_count		 OUT  NOCOPY   NUMBER,
    p_msg_data		 OUT  NOCOPY   VARCHAR2,
    p_vendor_id		 IN	       NUMBER,
    p_dup_vendor_id 	 IN	       NUMBER,
    p_vendor_site_id	 IN	       NUMBER,
    p_dup_vendor_site_id	 IN	       NUMBER,
    p_party_id		 IN	       NUMBER,
    P_dup_party_id		 IN	       NUMBER,
    p_party_site_id 	 IN	       NUMBER,
    p_dup_party_site_id	 IN	       NUMBER
);

end;

 

/
