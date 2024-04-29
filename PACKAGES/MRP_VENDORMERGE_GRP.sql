--------------------------------------------------------
--  DDL for Package MRP_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: MRPGVDRS.pls 120.0 2005/09/01 15:53:37 ichoudhu noship $ */

-- Start of comments
--    API name 	   : Merge_Vendor
--    Type	   : Group.
--    Function	   :
--    Pre-reqs	   : None.
--    Parameters   :
--	IN	   : p_api_version       IN   NUMBER	       Required
--		     p_init_msg_list	 IN   VARCHAR2         Optional
--				    Default = FND_API.G_FALSE
--		     p_commit	    	 IN   VARCHAR2	       Optional
--				    Default = FND_API.G_FALSE
--		     p_validation_level	 IN   NUMBER	       Optional
--				    Default = FND_API.G_VALID_LEVEL_FULL
--		     parameter1
--		     parameter2
--				.
--				.
--	OUT	   : x_return_status	 OUT  VARCHAR2(1)
--		     x_msg_count	 OUT	NUMBER
--		     x_msg_data		 OUT	VARCHAR2(2000)
--	             parameter1
--		     parameter2
--				.
--				.
--	Version	   : Current version	1.0
--				Changed....
--			  previous version	1.0
--				Changed....
--			  .
--			  .
--			  previous version	1.0
--				Changed....
--			  Initial version 	1.0
--
--	Notes		: Note text
--      Status complete except for comments in the spec.
-- End of comments

Procedure Merge_Vendor(p_api_version         IN   NUMBER,
                       p_init_msg_list       IN   VARCHAR2 default
                                             FND_API.G_FALSE,
	               p_commit              IN   VARCHAR2 default
                                             FND_API.G_FALSE,
	               p_validation_level    IN   NUMBER  :=
                                             FND_API.G_VALID_LEVEL_FULL,
	               x_return_status       OUT  NOCOPY VARCHAR2,
	               x_msg_count           OUT  NOCOPY NUMBER,
	               x_msg_data            OUT  NOCOPY VARCHAR2,
	               p_vendor_id           IN   NUMBER,
	               p_vendor_site_id      IN   NUMBER,
	               p_dup_vendor_id       IN   NUMBER,
	               p_dup_vendor_site_id  IN   NUMBER            ) ;

END ;


 

/
