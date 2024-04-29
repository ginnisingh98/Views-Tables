--------------------------------------------------------
--  DDL for Package Body IBE_CATALOG_PRELOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_CATALOG_PRELOAD_PUB" AS
/* $Header: IBEPCPLB.pls 120.0 2005/05/30 02:54:06 appldev noship $ */


-- Start of comments
--    API name   : Get_Preload_Section_Ids
--    Type       : Public.
--    Function   : Returns ref cursor containing section_ids of sections to be preloaded
--		   into the cache.  Section IDs should come from
--		   IBE_DSP_SECTIONS_B.SECTION_ID or a table with a foreign key to
--		   IBE_DSP_SECTIONS_B.SECTION_ID.  Current implementation returns
--		   all section ids.
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
		) IS

  l_api_name		CONSTANT VARCHAR2(30) 	:= 'Get_Preload_Section_Ids';
  l_api_version		CONSTANT NUMBER		:= 1.0;



BEGIN
   --gzhang 08/08/2002, bug#2488246
   --ibe_util.enable_debug;
   -- standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call (l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
   END IF;

   -- initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   	IBE_UTIL.debug('IBE_CATALOG_PRELOAD_PUB.Get_Preload_Section_Ids(+)');
   END IF;
   -- begin API body

   OPEN x_section_id_csr FOR
	SELECT s.SECTION_ID
	FROM IBE_DSP_SECTIONS_B s
        WHERE sysdate between s.start_date_active and nvl(s.end_date_active,sysdate);

   -- end API body
   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   	IBE_UTIL.debug('IBE_CATALOG_PRELOAD_PUB.Get_Preload_Section_Ids(-)');
   END IF;

   -- standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
	(	p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data  => x_msg_data
        );
   --gzhang 08/08/2002, bug#2488246
   --ibe_util.disable_debug;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );
	--gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );
	--gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
      WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     	FND_MESSAGE.Set_Token('ROUTINE', l_api_name || '4');
     	FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     	FND_MESSAGE.Set_Token('REASON', SQLERRM);
     	FND_MSG_PUB.Add;
	IF	FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN	FND_MSG_PUB.Add_Exc_Msg
			(	G_PKG_NAME,
				l_api_name
			);
	END IF;
	FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	--gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
END Get_Preload_Section_Ids;


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
		) IS
  l_api_name		CONSTANT VARCHAR2(30) 	:= 'Get_Preload_Item_Ids';
  l_api_version		CONSTANT NUMBER		:= 1.0;


BEGIN
   --gzhang 08/08/2002, bug#2488246
   --ibe_util.enable_debug;
   -- standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call (l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.to_Boolean(p_init_msg_list) THEN
	FND_MSG_PUB.initialize;
   END IF;

   -- initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IBE_UTIL.debug('IBE_CATALOG_PRELOAD_PUB.Get_Preload_Item_Ids(+)');
   -- begin API body
   OPEN x_item_id_csr FOR
	SELECT DISTINCT si.INVENTORY_ITEM_ID
	FROM IBE_DSP_SECTIONS_B s, IBE_DSP_SECTION_ITEMS si, MTL_SYSTEM_ITEMS_B i
	WHERE s.SECTION_TYPE_CODE = 'F'	AND s.SECTION_ID = si.SECTION_ID
	AND si.INVENTORY_ITEM_ID = i.INVENTORY_ITEM_ID AND i.WEB_STATUS = 'PUBLISHED'
        AND sysdate between s.start_date_active and nvl(s.end_date_active,sysdate)
        AND sysdate between si.start_date_active and nvl(si.end_date_active,sysdate);

   -- end API body
   IBE_UTIL.debug('IBE_CATALOG_PRELOAD_PUB.Get_Preload_Item_Ids(-)');

   -- standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
	(	p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data  => x_msg_data
        );
   --gzhang 08/08/2002, bug#2488246
   --ibe_util.disable_debug;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );
	--gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );
	--gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
      WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     	FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     	FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     	FND_MESSAGE.Set_Token('REASON', SQLERRM);
     	FND_MSG_PUB.Add;
	IF	FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN	FND_MSG_PUB.Add_Exc_Msg
			(	G_PKG_NAME,
				l_api_name
			);
	END IF;
	FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	--gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
END Get_Preload_Item_Ids;



-------
-- (code for PROCEDURE Preload_Sections removed on 01/19/2005 by rgupta)
-- This procedure is no longer necessary due to a redesign of the iStore
-- Section cache.
--


end IBE_CATALOG_PRELOAD_PUB;

/
