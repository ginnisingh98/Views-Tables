--------------------------------------------------------
--  DDL for Package AHL_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: AHLGVDMS.pls 120.1 2005/09/23 16:59:56 jeli noship $ */

-- Start of comments
--    API name 	   :MERGE_VENDOR
--    Type	       :Group
--    Function	   :
--    Pre-reqs	   :None
--    Parameters   :
--	IN	   : p_api_version       IN   NUMBER	       Required
--		     p_init_msg_list	 IN   VARCHAR2         Optional
--				    Default = FND_API.G_FALSE
--		     p_commit	    	 IN   VARCHAR2	       Optional
--				    Default = FND_API.G_FALSE
--		     p_validation_level	 IN   NUMBER	       Optional
--				    Default = FND_API.G_VALID_LEVEL_FULL
--  p_vendor_id --> Represents Merge To Vendor
--  p_dup_vendor_id --> Represents Merge From Vendor
--  p_vendor_site_id --> Represents Merge To Vendor Site
--  p_dup_vendor_site_id --> Represents Merge From Vendor Site
--  p_party_id --> Represents Merge To Party
--  p_dup_party_id --> Represents Merge From Party
--  p_party_site_id --> Represents Merge To Party Site
--  p_dup_party_site_id --> Represents Merge From Party Site
--
--	OUT	   : x_return_status	 OUT    VARCHAR2(1)
--		     x_msg_count	 OUT	NUMBER
--		     x_msg_data		 OUT	VARCHAR2(2000)
--				.
--	Version	   : Current version	1.0
--			     Initial version 	1.0
--
--	Notes		: Note text
--      Status complete except for comments in the spec.
-- End of comments

PROCEDURE MERGE_VENDOR(
        p_api_version        IN   NUMBER,
	    p_init_msg_list      IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	    p_commit             IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	    p_validation_level   IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	    x_return_status      OUT  NOCOPY VARCHAR2,
	    x_msg_count          OUT  NOCOPY NUMBER,
	    x_msg_data           OUT  NOCOPY VARCHAR2,
	    p_vendor_id          IN   NUMBER,
	    p_vendor_site_id     IN   NUMBER,
	    p_dup_vendor_id      IN   NUMBER,
	    p_dup_vendor_site_id IN   NUMBER,
        p_party_id           IN   NUMBER,
        p_dup_party_id       IN   NUMBER,
        p_party_site_id      IN   NUMBER,
        p_dup_party_site_id  IN   NUMBER);

END;

 

/
