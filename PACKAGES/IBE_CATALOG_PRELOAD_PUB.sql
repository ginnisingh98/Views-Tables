--------------------------------------------------------
--  DDL for Package IBE_CATALOG_PRELOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_CATALOG_PRELOAD_PUB" AUTHID CURRENT_USER as
/* $Header: IBEPCPLS.pls 120.0 2005/05/30 03:07:11 appldev noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBE_CATALOG_PRELOAD_PUB';


type IBE_ID_REC is RECORD
(
   id			NUMBER
);

type IBE_CATALOG_REFCURSOR_CSR_TYPE is REF CURSOR;

-- Start of comments
--    API name   : Get_Preload_Section_Ids
--    Type       : Public.
--    Function   : Returns ref cursor containing section_ids of sections to be preloaded
--		   into the cache.  Section IDs should come from
--		   IBE_DSP_SECTIONS_B.SECTION_ID or a table with a foreign key to
--		   IBE_DSP_SECTIONS_B.SECTION_ID.  Current implementation returns all
--		   section ids.
--
--    Pre-reqs   : None.
--    Parameters :
--
--    IN         : p_api_version        	IN  NUMBER   Required
--                 p_init_msg_list      	IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--    OUT        : x_return_status      	OUT NOCOPY VARCHAR2(1)
--                 x_msg_count          	OUT NOCOPY NUMBER
--                 x_msg_data           	OUT NOCOPY VARCHAR2(2000)
--		   x_section_id_csr		OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE
--			Record type = IBE_ID_REC
--
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
  procedure Get_Preload_Section_Ids
		(p_api_version        		IN  NUMBER,
                 p_init_msg_list      		IN  VARCHAR2 := FND_API.G_FALSE,
     		 x_return_status      		OUT NOCOPY VARCHAR2,
                 x_msg_count          		OUT NOCOPY NUMBER,
                 x_msg_data           		OUT NOCOPY VARCHAR2,

		 x_section_id_csr		OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE
		);


-- Start of comments
--    API name   : Get_Preload_Item_Ids
--    Type       : Public.
--    Function   : Returns ref cursor containing inventory_item_ids of items to be
--		   preloaded into the cache.  Item IDs should come from
--		   MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID or a table with a foreign
--		   key to MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID (such as
--		   IBE_DSP_SECTION_ITEMS).  Current implementation returns inventory
--		   item ids of all items in featured sections.
--
--    Pre-reqs   : None.
--    Parameters :
--
--    IN         : p_api_version        	IN  NUMBER   Required
--                 p_init_msg_list      	IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--    OUT        : x_return_status      	OUT NOCOPY VARCHAR2(1)
--                 x_msg_count          	OUT NOCOPY NUMBER
--                 x_msg_data           	OUT NOCOPY VARCHAR2(2000)
--		   x_item_id_csr		OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE
--			Record type = IBE_ID_REC
--
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
  procedure Get_Preload_Item_Ids
		(p_api_version        		IN  NUMBER,
                 p_init_msg_list      		IN  VARCHAR2 := FND_API.G_FALSE,
     		 x_return_status      		OUT NOCOPY VARCHAR2,
                 x_msg_count          		OUT NOCOPY NUMBER,
                 x_msg_data           		OUT NOCOPY VARCHAR2,

		 x_item_id_csr			OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE
		);



-------
-- (code for PROCEDURE Preload_Sections removed on 01/19/2005 by rgupta)
-- This procedure is no longer necessary due to a redesign of the iStore
-- Section cache.
--


end IBE_CATALOG_PRELOAD_PUB;

 

/
