--------------------------------------------------------
--  DDL for Package Body IBE_CATALOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_CATALOG_PVT" AS
/* $Header: IBEVCCTB.pls 120.7.12010000.5 2015/02/05 05:48:11 kdosapat ship $ */



-------
-- (code for PROCEDURE Load_Section removed on 01/19/2005 by rgupta)
-- This procedure is no longer necessary due to a redesign of the iStore
-- Section cache.
--



-- Start of comments
--    API name   : Load_Sections
--    Type       : Private.
--    Function   : Given a list of section IDs, loads supersection and item
--                 information for each section.
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version                IN NUMBER   Required
--                 p_init_msg_list              IN VARCHAR2 Optional
--                 p_validation_level           IN NUMBER   Optional
--		             p_sectid_tbl		            IN JTF_NUMBER_TABLE
--		             p_msite_id		               IN NUMBER
--
--    OUT        : x_return_status              OUT VARCHAR2(1)
--                 x_msg_count                  OUT NUMBER
--                 x_msg_data                   OUT VARCHAR2(2000)
--		             x_supersect_sect_tbl		   OUT NOCOPY JTF_NUMBER_TABLE
--		             x_supersect_supersect_tbl	   OUT NOCOPY JTF_NUMBER_TABLE
--		             x_sctitm_sectid_tbl		      OUT NOCOPY JTF_NUMBER_TABLE
--		             x_sctitm_itmid_tbl		      OUT NOCOPY JTF_NUMBER_TABLE
--		             x_sctitm_usage_tbl		      OUT NOCOPY JTF_VARCHAR2_TABLE_300
--                 x_sctitm_flags_tbl           OUT NOCOPY JTF_VARCHAR2_TABLE_300
--                 x_sctitm_startdt_tbl         OUT NOCOPY JTF_DATE_TABLE
--                 x_sctitm_enddt_tbl           OUT NOCOPY JTF_DATE_TABLE
--                 x_sctitm_assoc_startdt_tbl   OUT NOCOPY JTF_DATE_TABLE
--                 x_sctitm_assoc_enddt_tbl     OUT NOCOPY JTF_DATE_TABLE
--
--    Version    : Current version	1.0
--
--                 Previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments

  procedure Load_Sections
		(p_api_version        		   IN  NUMBER,
       p_init_msg_list      		   IN  VARCHAR2 := NULL,
       p_validation_level   		   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
       x_return_status      		   OUT NOCOPY VARCHAR2,
       x_msg_count          		   OUT NOCOPY NUMBER,
       x_msg_data           		   OUT NOCOPY VARCHAR2,
		 p_sectid_tbl 			         IN  JTF_NUMBER_TABLE,
		 p_msite_id			            IN  NUMBER,
		 x_supersect_sect_tbl		   OUT NOCOPY JTF_NUMBER_TABLE,
		 x_supersect_supersect_tbl	   OUT NOCOPY JTF_NUMBER_TABLE,
		 x_sctitm_sectid_tbl		      OUT NOCOPY JTF_NUMBER_TABLE,
		 x_sctitm_itmid_tbl		      OUT NOCOPY JTF_NUMBER_TABLE,
		 x_sctitm_orgid_tbl			 OUT NOCOPY JTF_NUMBER_TABLE,
		 x_sctitm_usage_tbl		      OUT NOCOPY JTF_VARCHAR2_TABLE_300,
       x_sctitm_flags_tbl           OUT NOCOPY JTF_VARCHAR2_TABLE_300,
       x_sctitm_startdt_tbl         OUT NOCOPY JTF_DATE_TABLE,
       x_sctitm_enddt_tbl           OUT NOCOPY JTF_DATE_TABLE,
       x_sctitm_assoc_startdt_tbl   OUT NOCOPY JTF_DATE_TABLE,
       x_sctitm_assoc_enddt_tbl     OUT NOCOPY JTF_DATE_TABLE
		) IS


  cursor l_orderby_csr(p_sectid NUMBER) IS
	SELECT s.order_by_clause
	FROM IBE_DSP_SECTIONS_VL s
	WHERE s.section_id = p_sectid;


  L_MSIB_STMT CONSTANT VARCHAR2(2000) :=
      'SELECT si.inventory_item_id, si.organization_id, si.usage_name, MSIB.web_status, ' ||
      '       si.start_date_active assoc_start_dt, si.end_date_active assoc_end_date, ' ||
      '       MSIB.start_date_active start_dt, MSIB.end_date_active end_dt ' ||
      'FROM IBE_DSP_SECTION_ITEMS si, MTL_SYSTEM_ITEMS_B MSIB ' ||
      'WHERE si.section_id = :sect_id ' ||
      'AND si.inventory_item_id = MSIB.inventory_item_id ' ||
		'AND si.organization_id = MSIB.organization_id ' ||
      'AND (MSIB.WEB_STATUS = ''PUBLISHED'' OR MSIB.WEB_STATUS = ''UNPUBLISHED'') ' ||
		'AND NVL(MSIB.end_date_active, SYSDATE) >= SYSDATE ' ||
		'AND NVL(si.end_date_active, SYSDATE) >= SYSDATE ';

  L_SECT_MSIB_ORDER_STMT CONSTANT VARCHAR2(100) :=
		'si.SORT_ORDER, MSIB.inventory_item_id';

  L_MSIV_STMT CONSTANT VARCHAR2(2000) :=
      'SELECT si.inventory_item_id, si.organization_id, si.usage_name, MSIV.web_status, ' ||
      '       si.start_date_active assoc_start_dt, si.end_date_active assoc_end_dt, ' ||
      '       MSIV.start_date_active start_dt, MSIV.end_date_active end_dt ' ||
      'FROM IBE_DSP_SECTION_ITEMS si, MTL_SYSTEM_ITEMS_VL MSIV ' ||
      'WHERE si.section_id = :sect_id ' ||
      'AND si.inventory_item_id = MSIV.inventory_item_id ' ||
		'AND si.organization_id = MSIV.organization_id ' ||
      'AND (MSIV.WEB_STATUS = ''PUBLISHED'' OR MSIV.WEB_STATUS = ''UNPUBLISHED'') ' ||
		'AND NVL(MSIV.end_date_active, SYSDATE) >= SYSDATE ' ||
		'AND NVL(si.end_date_active, SYSDATE) >= SYSDATE ';

  L_SECT_MSIV_ORDER_STMT CONSTANT VARCHAR2(100) :=
		'si.SORT_ORDER, MSIV.inventory_item_id';


  l_api_name		         CONSTANT VARCHAR2(30) 	:= 'Load_Sections';
  l_api_version		      CONSTANT NUMBER		:= 1.0;
  l_init_msg_list 	      VARCHAR2(5);
  l_stmt		               VARCHAR2(32767);

  l_sectid_tbl  	         JTF_NUMBER_TABLE;
  l_table_index 	         NUMBER;

  l_supersectid_csr	      IBE_CATALOG_REFCURSOR_CSR_TYPE;
  l_get_supersects         BOOLEAN;
  l_processed_sectid_tbl	JTF_NUMBER_TABLE;
  l_processed_sectid_index NUMBER;
  l_tmp_id		            NUMBER;

  l_str_itms_per_sct       VARCHAR2(20);
  l_itms_per_sct	         NUMBER;
  l_tmp_ord_by_clause 	   VARCHAR2(512);
  l_ord_by_clause	         VARCHAR2(1000);
  l_itmids_csr	            IBE_CATALOG_REFCURSOR_CSR_TYPE;
  l_tmp_itmid		         NUMBER;
  l_tmp_orgid			    NUMBER;
  l_tmp_usage		         VARCHAR2(255);
  l_tmp_status_flag        VARCHAR2(255);
  l_tmp_startdt            DATE;
  l_tmp_enddt              DATE;
  l_tmp_assoc_startdt      DATE;
  l_tmp_assoc_enddt        DATE;
  l_itmid_orgid_stmt       VARCHAR2(32767);
  l_sid			            NUMBER;


BEGIN

----------------------
-- Standard initialization tasks
----------------------

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version,
				    p_api_version,
				    l_api_name,
				    G_PKG_NAME   )
THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

IF p_init_msg_list IS NULL THEN
	l_init_msg_list := FND_API.G_FALSE;
END IF;

-- Initialize message list if L_init_msg_list is set to TRUE.
IF FND_API.to_Boolean(L_init_msg_list) THEN
	FND_MSG_PUB.initialize;
END IF;

-- Initialize API return status to success.
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Print debugging info.
IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.debug('IBE_CATALOG_PVT.Load_Sections(+)');
	IBE_UTIL.debug('IBE_CATALOG_PVT.p_msite_id = ' || p_msite_id);
END IF;


----------------------
-- Error checking
----------------------

-- Verify list of section IDs is not null.
IF p_sectid_tbl IS NULL THEN
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.Error p_sect_id_tbl is NULL');
	END IF;
	FND_MESSAGE.Set_Name('IBE', 'IBE_CT_INVALID_ID_OR_NAME');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
ELSE
   l_sectid_tbl := p_sectid_tbl;
END IF;


----------------------
-- Get supersection information
----------------------

-- Initialize final output arrays.
x_supersect_sect_tbl := JTF_NUMBER_TABLE();
x_supersect_supersect_tbl := JTF_NUMBER_TABLE();


-- Loop through our list of requested section IDs and retrieve supersection information.
l_table_index := 1;
l_processed_sectid_tbl := JTF_NUMBER_TABLE();
l_processed_sectid_index := 1;

FOR j IN 1..l_sectid_tbl.COUNT LOOP
   l_get_supersects := true;
   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.l_sectionid_tbl('||j ||')='||l_sectid_tbl(j));
	END IF;

   -- Check whether we already retrieved supersection information for the
   -- current section ID.
   FOR k IN 1..l_processed_sectid_tbl.COUNT LOOP
      IF l_processed_sectid_tbl(k) = l_sectid_tbl(j) THEN
         l_get_supersects := false;
         EXIT;
      END IF;
   END LOOP;


   IF l_get_supersects THEN
         IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.l_get_supersects is TRUE');
	END IF;
      -- Record the current section ID in our list of "already processed section IDs".
      l_processed_sectid_tbl.extend();
      l_processed_sectid_tbl(l_processed_sectid_index) := l_sectid_tbl(j);
      l_processed_sectid_index := l_processed_sectid_index + 1;

      -- Retrieve the supersection information for the current section ID.
      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	IBE_UTIL.debug('Start Calling IBE_CATALOG_PVT.GetSuperSectIDs ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
      END IF;
      GetSuperSectIDs(p_api_version => p_api_version,
		                x_return_status => x_return_status,
		                x_msg_count => x_msg_count,
		                x_msg_data => x_msg_data,
		                p_sectid => l_sectid_tbl(j),
		                p_msite_id => p_msite_id,
		                x_supersectid_csr => l_supersectid_csr);
      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	IBE_UTIL.debug('End Calling IBE_CATALOG_PVT.GetSuperSectIDs ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
      END IF;

      -- Extract the supersection information into our final output arrays.
      LOOP
         FETCH l_supersectid_csr INTO l_tmp_id;
         EXIT WHEN l_supersectid_csr%NOTFOUND;
         IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	  IBE_UTIL.debug('IBE_CATALOG_PVT:value of l_tmp_id= ' || l_tmp_id);
         END IF;
         x_supersect_sect_tbl.EXTEND;
         x_supersect_supersect_tbl.EXTEND;
         x_supersect_sect_tbl(l_table_index) := l_sectid_tbl(j);
         x_supersect_supersect_tbl(l_table_index) := l_tmp_id;
         l_table_index := l_table_index + 1;

      END LOOP;
      close l_supersectid_csr;
      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	  IBE_UTIL.debug('IBE_CATALOG_PVT:closing l_supersectid_csr');
         END IF;
   END IF;

END LOOP;

IF x_supersect_sect_tbl.COUNT = 0 THEN
   x_supersect_sect_tbl := NULL;
END IF;
IF x_supersect_supersect_tbl.COUNT = 0 THEN
   x_supersect_supersect_tbl := NULL;
END IF;

IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	IBE_UTIL.debug('IBE_CATALOG_PVT.Before get items per sections');
END IF;
----------------------
-- Get item information
----------------------

-- Initialize final output arrays.
x_sctitm_sectid_tbl := JTF_NUMBER_TABLE();
x_sctitm_itmid_tbl := JTF_NUMBER_TABLE();
x_sctitm_orgid_tbl := JTF_NUMBER_TABLE();
x_sctitm_usage_tbl := JTF_VARCHAR2_TABLE_300();
x_sctitm_flags_tbl := JTF_VARCHAR2_TABLE_300();
x_sctitm_startdt_tbl := JTF_DATE_TABLE();
x_sctitm_enddt_tbl := JTF_DATE_TABLE();
x_sctitm_assoc_startdt_tbl := JTF_DATE_TABLE();
x_sctitm_assoc_enddt_tbl := JTF_DATE_TABLE();


-- Get the number of items per section.
l_str_itms_per_sct := FND_PROFILE.value_specific('IBE_ITEMS_PER_SECTION', NULL, NULL, 671);
l_itms_per_sct := NULL;
IF (l_str_itms_per_sct IS NOT NULL) THEN

	l_itms_per_sct := TO_NUMBER(l_str_itms_per_sct);
END IF;
IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	  IBE_UTIL.debug('IBE_CATALOG_PVT.l_itms_per_sct'||l_itms_per_sct);
END IF;

-- Loop through our list of requested section IDs and retrieve item information.
l_table_index := 1;
FOR i IN 1..l_sectid_tbl.COUNT LOOP


   -- Get the order by clause from the database (if any).
   l_sid := l_sectid_tbl(i);
   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	  IBE_UTIL.debug('IBE_CATALOG_PVT.l_sid'||l_sid);
    END IF;
   OPEN l_orderby_csr(l_sid);
   FETCH l_orderby_csr INTO l_tmp_ord_by_clause;
   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	IBE_UTIL.debug('IBE_CATALOG_PVT.l_tmp_ord_by_clause'||l_tmp_ord_by_clause);
   END IF;
   CLOSE l_orderby_csr;
   Process_Order_By_Clause(l_tmp_ord_by_clause, l_ord_by_clause);

    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	IBE_UTIL.debug('IBE_CATALOG_PVT.After Process_order_by');
   END IF;

   -- Retrieve the item information for the current section ID.
   IF (l_itms_per_sct IS NULL) THEN
      IF (l_ord_by_clause IS NULL OR l_ord_by_clause = '') THEN
         l_stmt := L_MSIB_STMT || 'ORDER BY ' || L_SECT_MSIB_ORDER_STMT;
      ELSE
         l_stmt := L_MSIV_STMT || 'ORDER BY ' || l_ord_by_clause || ', '
	                || L_SECT_MSIV_ORDER_STMT;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	IBE_UTIL.debug('IBE_CATALOG_PVT.l_stmt First =' ||l_stmt);
     END IF;

      OPEN l_itmids_csr FOR l_stmt USING l_sid ;
   ELSE
      IF (l_ord_by_clause IS NULL OR l_ord_by_clause = '') THEN
         l_stmt := 'SELECT * FROM (' || L_MSIB_STMT || 'ORDER BY ' ||
	                L_SECT_MSIB_ORDER_STMT || ') WHERE rownum <= :itms_per_sct';
      ELSE
         l_stmt := 'SELECT * FROM (' || L_MSIV_STMT || 'ORDER BY ' ||
	                l_ord_by_clause || ', ' || L_SECT_MSIV_ORDER_STMT ||
	                ') WHERE rownum <= :itms_per_sct';
      END IF;
       IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	IBE_UTIL.debug('IBE_CATALOG_PVT.l_stmt Second =' ||l_stmt);
     END IF;
      OPEN l_itmids_csr FOR l_stmt USING l_sid, l_itms_per_sct;
   END IF;


   -- Extract the item information into our final output arrays.
   LOOP
      FETCH l_itmids_csr INTO l_tmp_itmid, l_tmp_orgid, l_tmp_usage, l_tmp_status_flag,
             l_tmp_assoc_startdt, l_tmp_assoc_enddt,l_tmp_startdt, l_tmp_enddt;
      EXIT WHEN l_itmids_csr%NOTFOUND;

      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	IBE_UTIL.debug('IBE_CATALOG_PVT.l_tmp_itmid =' ||l_tmp_itmid || ':l_tmp_orgid='||l_tmp_orgid ||
        ':l_tmp_usage='||l_tmp_usage || ':l_tmp_status_flag='||l_tmp_status_flag||':l_tmp_startdt='||l_tmp_startdt||
        ':l_tmp_enddt='||l_tmp_enddt|| ':l_tmp_assoc_startdt='||l_tmp_assoc_startdt||':l_tmp_assoc_enddt='||l_tmp_assoc_enddt);
     END IF;
      x_sctitm_sectid_tbl.EXTEND;
      x_sctitm_itmid_tbl.EXTEND;
	 x_sctitm_orgid_tbl.EXTEND;
      x_sctitm_usage_tbl.EXTEND;
      x_sctitm_flags_tbl.EXTEND;
      x_sctitm_startdt_tbl.EXTEND;
      x_sctitm_enddt_tbl.EXTEND;
      x_sctitm_assoc_startdt_tbl.EXTEND;
      x_sctitm_assoc_enddt_tbl.EXTEND;
      x_sctitm_sectid_tbl(l_table_index) := l_sectid_tbl(i);
      x_sctitm_itmid_tbl(l_table_index) := l_tmp_itmid;
      x_sctitm_orgid_tbl(l_table_index) := l_tmp_orgid;
      x_sctitm_usage_tbl(l_table_index) := l_tmp_usage;
      x_sctitm_flags_tbl(l_table_index) := l_tmp_status_flag;
      x_sctitm_startdt_tbl(l_table_index) := l_tmp_startdt;
      x_sctitm_enddt_tbl(l_table_index) := l_tmp_enddt;
      x_sctitm_assoc_startdt_tbl(l_table_index) := l_tmp_assoc_startdt;
      x_sctitm_assoc_enddt_tbl(l_table_index) := l_tmp_assoc_enddt;
      l_table_index := l_table_index + 1;
  END LOOP;
  CLOSE l_itmids_csr;

END LOOP;
IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.debug('IBE_CATALOG_PVT.After extracting info from output arrays');
END IF;
IF x_sctitm_itmid_tbl.COUNT = 0 THEN
     x_sctitm_itmid_tbl := NULL;
END IF;
IF x_sctitm_orgid_tbl.COUNT = 0 THEN
     x_sctitm_orgid_tbl := NULL;
END IF;

IF x_sctitm_sectid_tbl.COUNT = 0 THEN
    x_sctitm_sectid_tbl := NULL;
END IF;
IF x_sctitm_flags_tbl.COUNT = 0 THEN
   x_sctitm_flags_tbl := NULL;
END IF;
IF x_sctitm_startdt_tbl.COUNT = 0 THEN
   x_sctitm_startdt_tbl := NULL;
END IF;
IF x_sctitm_enddt_tbl.COUNT = 0 THEN
   x_sctitm_enddt_tbl := NULL;
END IF;
IF x_sctitm_assoc_startdt_tbl.COUNT = 0 THEN
   x_sctitm_assoc_startdt_tbl := NULL;
END IF;
IF x_sctitm_assoc_enddt_tbl.COUNT = 0 THEN
   x_sctitm_assoc_enddt_tbl := NULL;
END IF;


----------------------
-- Standard cleanup tasks
----------------------

IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.debug('IBE_CATALOG_PVT.Load_Sections(-)');
END IF;

-- standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get
	(	p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data  => x_msg_data
        );
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
END LOAD_SECTIONS;


-- Start of comments
--    API name   : GetLeafSubSectIDs
--    Type       : Private.
--    Function   : Given a section id, drills down to the
--		   leaf level and returns leaf level section ids.
--		   If p_preview_flag = 'T' returns sections
--		   whose status_code is 'PUBLISHED' or 'UNPUBLISHED'.
--		   Otherwise, returns information for sections whose
--		   status_code is 'PUBLISHED'
--
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        IN  NUMBER   Required
--                 p_init_msg_list      IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER   Optional
--                     Default = FND_API.G_VALID_LEVEL_FULL
--		   p_preview_flag	IN VARCHAR2  Optional
--                 p_msite_id 		IN NUMBER
--		   p_sectid 		IN NUMBER
--
--    OUT        : x_return_status      OUT VARCHAR2(1)
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2(2000)
--		   x_leafsubsectid_csr	OUT IBE_CATALOG_REFCURSOR_CSR_TYPE
--			Record Type = (leaf_section_id NUMBER, sort_order NUMBER)
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

  procedure GetLeafSubSectIDs
		(
		 p_api_version        	IN  NUMBER,
                 p_init_msg_list      	IN  VARCHAR2 := NULL,
                 p_validation_level   	IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		 x_return_status	OUT NOCOPY VARCHAR2,
		 x_msg_count		OUT NOCOPY NUMBER,
		 x_msg_data		OUT NOCOPY VARCHAR2,

                 p_preview_flag      	IN  VARCHAR2 := NULL,
		 p_sectid 		IN  NUMBER,
		 p_msite_id		IN  NUMBER,
		 x_leafsubsectid_csr 	OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE
		) IS
  	l_api_name		CONSTANT VARCHAR2(30) 	:= 'GetLeafSubSectIDs';
 	l_api_version		CONSTANT NUMBER		:= 1.0;
	l_leafsubsectid		NUMBER;
	l_table_index		NUMBER;
  	l_init_msg_list 	VARCHAR2(5);
  	l_preview_flag  	VARCHAR2(5);

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

	IF p_init_msg_list IS NULL THEN
		l_init_msg_list := FND_API.G_FALSE;
	END IF;

	IF p_preview_flag IS NULL THEN
		l_preview_flag := FND_API.G_FALSE;
	END IF;


	-- initialize message list if l_init_msg_list is set to TRUE
	IF FND_API.to_Boolean(l_init_msg_list) THEN
	   FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.GetLeafSubSectIDs(+)');
		IBE_UTIL.debug('p_sectid : p_msite_id =' || p_sectid || ' : ' || p_msite_id);
	END IF;

	-- API Body
	IF FND_API.to_Boolean(l_preview_flag) THEN
	   OPEN x_leafsubsectid_csr FOR
	      SELECT mss.child_section_id, mss.sort_order
	      FROM IBE_DSP_MSITE_SCT_SECTS mss, IBE_DSP_SECTIONS_B jdsb
	      WHERE mss.mini_site_id = p_msite_id
	      AND mss.child_section_id in
	      ( SELECT mss1.child_section_id
	        FROM IBE_DSP_MSITE_SCT_SECTS mss1
	        START WITH mss1.parent_section_id = p_sectid and mss1.mini_site_id = p_msite_id
	        CONNECT BY PRIOR mss1.child_section_id = mss1.parent_section_id
	        AND mss1.mini_site_id = p_msite_id
	      )
	      AND mss.child_section_id not in
	      (
	        SELECT mss2.parent_section_id
	        FROM IBE_DSP_MSITE_SCT_SECTS mss2
	        WHERE mss2.mini_site_id = p_msite_id
  	        AND mss2.parent_section_id is not null
	      )
	      AND jdsb.section_id = mss.child_section_id
	      AND (jdsb.status_code = 'PUBLISHED' OR jdsb.status_code = 'UNPUBLISHED')
	      AND NVL(jdsb.start_date_active, SYSDATE) <= SYSDATE
	      AND NVL(jdsb.end_date_active, SYSDATE) >= SYSDATE
	      ORDER BY mss.sort_order;
	ELSE
	   OPEN x_leafsubsectid_csr FOR
	      SELECT mss.child_section_id, mss.sort_order
	      FROM IBE_DSP_MSITE_SCT_SECTS mss, IBE_DSP_SECTIONS_B jdsb
	      WHERE mss.mini_site_id = p_msite_id
	      AND mss.child_section_id in
	      ( SELECT mss1.child_section_id
	        FROM IBE_DSP_MSITE_SCT_SECTS mss1
	        START WITH mss1.parent_section_id = p_sectid and mss1.mini_site_id = p_msite_id
	        CONNECT BY PRIOR mss1.child_section_id = mss1.parent_section_id
	        AND mss1.mini_site_id = p_msite_id
	      )
	      AND mss.child_section_id not in
	      (
	        SELECT mss2.parent_section_id
	        FROM IBE_DSP_MSITE_SCT_SECTS mss2
	        WHERE mss2.mini_site_id = p_msite_id
  	        AND mss2.parent_section_id is not null
	      )
	      AND jdsb.section_id = mss.child_section_id
	      AND jdsb.status_code = 'PUBLISHED'
	      AND NVL(jdsb.start_date_active, SYSDATE) <= SYSDATE
	      AND NVL(jdsb.end_date_active, SYSDATE) >= SYSDATE
	      ORDER BY mss.sort_order;
	END IF;

	-- End API Body
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.GetLeafSubSectIDs(-)');
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
	END GETLEAFSUBSECTIDS;



-- Start of comments
--    API name   : GetSuperSectIDs
--    Type       : Private.
--    Function   : Given a section ID, returns the super sections up to
--		             the root of the store, ordered from the section's immediate
--		             parent to the root.
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version       IN  NUMBER   Required
--                 p_init_msg_list     IN  VARCHAR2 Optional
--                      Default = FND_API.G_FALSE
--                 p_validation_level  IN  NUMBER   Optional
--                      Default = FND_API.G_VALID_LEVEL_FULL
--		             p_sectid 		      IN NUMBER    Required
--		             p_msite_id		      IN NUMBER    Required
--
--    OUT        : x_return_status     OUT VARCHAR2(1)
--                 x_msg_count         OUT NUMBER
--                 x_msg_data          OUT VARCHAR2(2000)
--		             x_supersectid_csr	OUT IBE_CATALOG_REFCURSOR_CSR_TYPE
--			               Record Type = IBE_ID_REC
--
--    Version    : Current version	1.0
--
--                 Previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments

  procedure GetSuperSectIDs
		(p_api_version        	IN  NUMBER,
       p_init_msg_list      	IN  VARCHAR2 := NULL,
       p_validation_level   	IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		 x_return_status	      OUT NOCOPY VARCHAR2,
		 x_msg_count		      OUT NOCOPY NUMBER,
		 x_msg_data		         OUT NOCOPY VARCHAR2,
		 p_sectid 		         IN  NUMBER,
		 p_msite_id		         IN  NUMBER,
		 x_supersectid_csr 	   OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE
		) IS

	l_api_name		   CONSTANT VARCHAR2(30) 	:= 'GetSuperSectIDs';
	l_api_version		CONSTANT NUMBER		   := 1.0;
	l_init_msg_list 	VARCHAR2(5);

	BEGIN

   ----------------------
   -- Standard initialization tasks
   ----------------------

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version,
				    p_api_version,
				    l_api_name,
				    G_PKG_NAME   )
	THEN
   	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF p_init_msg_list IS NULL THEN
		l_init_msg_list := FND_API.G_FALSE;
	END IF;

	-- Initialize message list if l_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean(l_init_msg_list) THEN
	   FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Print debugging info.
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.GetSuperSectIDs(+)');
		IBE_UTIL.debug('p_sectid : p_msite_id =' || p_sectid || ' : ' || p_msite_id);
	END IF;


   ----------------------
   -- Supersection query
   ----------------------

	OPEN x_supersectid_csr FOR
	   SELECT mss.parent_section_id
             FROM IBE_DSP_MSITE_SCT_SECTS mss
             START WITH mss.child_section_id = p_sectid AND mss.mini_site_id = p_msite_id
             CONNECT BY PRIOR mss.parent_section_id = mss.child_section_id
             AND mss.mini_site_id = p_msite_id;


   ----------------------
   -- Standard cleanup tasks
   ----------------------

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.GetSuperSectIDs(-)');
	END IF;

	-- standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
		);
	EXCEPTION
   		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			FND_MSG_PUB.Count_And_Get
				(	p_encoded => FND_API.G_FALSE,
					p_count => x_msg_count,
					p_data  => x_msg_data
				);
   		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			FND_MSG_PUB.Count_And_Get
				(	p_encoded => FND_API.G_FALSE,
					p_count => x_msg_count,
					p_data  => x_msg_data
				);
   		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

	END GetSuperSectIDs;



--    Start of comments
--    API name   : GetAvailableServices
--    Type       : Public
--    Function   : retrieve Service Items related to this Item.
--    After a service item is set up, it is generally available to all
--    serviceable products.  OKS provides functionalites to set up exclusion
--    between serviceable product and serivce item; exclusion between customer
--    and service item.  This API will take the exclusion rules into account
--    as well.
--
--    Pre-reqs   : None.
--    Parameters :
--    IN         :
--     p_api_version        IN  NUMBER   	 Required
--     p_init_msg_list      IN  VARCHAR2 	 Optional
--                     Default = FND_API.G_FALSE
--     p_validation_level   IN  NUMBER   	 Optional
--                     Default = FND_API.G_VALID_LEVEL_FULL
--		   p_preview_flag	IN  VARCHAR2       Optional
--                     Default = FND_API.G_FALSE
--		   p_originid 		IN  NUMBER         Required
--		   p_origintype		IN  VARCHAR2(240)  Required
--		   p_reltype_code	IN  VARCHAR2(30)   Required
--		   p_dest_type		IN  VARCHAR2(240)  Required
--     p_commit IN  VARCHAR2 := FND_API.G_FALSE Optional
--     p_product_item_id IN  NUMBER Required
--  	  p_customer_id     IN  NUMBER Optional,
--     p_product_revision  IN  VARCHAR2 Optional
--  	  p_request_date    IN  DATE Optional
--
--
--    OUT        :
--     x_return_status      OUT VARCHAR2(1)
--     x_msg_count          OUT NUMBER
--     x_msg_data           OUT VARCHAR2(2000)
--		   x_service_item_ids	OUT nocopy JTF_NUMBER_TABLE
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
	PROCEDURE GetAvailableServices(
	  p_api_version_number              IN  NUMBER := 1,
	  p_init_msg_list                   IN  VARCHAR2 := NULL,
	  p_commit                          IN  VARCHAR2 := NULL,
	  x_return_status                   OUT NOCOPY VARCHAR2,
	  x_msg_count                       OUT NOCOPY NUMBER,
	  x_msg_data                        OUT NOCOPY VARCHAR2,
	  p_product_item_id                 IN  NUMBER,
	  p_customer_id                     IN  NUMBER,
	  p_product_revision                IN  VARCHAR2,
	  p_request_date                    IN  DATE,
	  x_service_item_ids                OUT NOCOPY JTF_NUMBER_TABLE
	) IS
	  --l_avail_service_rec     ASO_SERVICE_CONTRACTS_INT.Avail_Service_Rec_Type;
	  --l_orderable_Service_tbl ASO_SERVICE_CONTRACTS_INT.order_service_tbl_type;
	  l_count                 NUMBER;
	  --new
	  l_api_version_number NUMBER := 1.0;
	  l_api_name CONSTANT  VARCHAR2(50) := 'GetAvailableServices';

	  l_avail_service_rec OKS_OMINT_PUB.AVAIL_SERVICE_REC_TYPE;
	  l_Orderable_Service_tbl  OKS_OMINT_PUB.order_service_tbl_type;
  	  l_init_msg_list 	VARCHAR2(5);
          L_commit  	        VARCHAR2(5);

--Bug 17177115
	tmpIdx                 NUMBER;
    l_pub_count                 NUMBER;
    l_service_items_pub_tbl		JTF_NUMBER_TABLE;

  Cursor c_publishedItem (p_itemid NUMBER) is
   Select count(MSIV.inventory_item_id)
      FROM MTL_SYSTEM_ITEMS_VL MSIV
      WHERE MSIV.INVENTORY_ITEM_ID = p_itemid
 -- bug 17734931      AND MSIV.organization_id = MO_GLOBAL.get_current_org_id()
      AND MSIV.organization_id = (select distinct master_organization_id from oe_system_parameters_all where org_id = MO_GLOBAL.GET_CURRENT_ORG_ID())
      AND MSIV.WEB_STATUS = 'PUBLISHED';

	  -- new
	BEGIN
	  SAVEPOINT AVAILABLE_SERVICES_PUB;
	  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	     IBE_UTIL.Debug('Start IBE_CATALOG_PVT.GetAvailableServices');
	     IBE_UTIL.Debug('     Parms: [p_product_item_id=' || p_product_item_id || ', ' ||
				  p_customer_id || ', ' || p_product_revision || ', ' ||
				  p_request_date || ']');
	  END IF;

	  IF p_init_msg_list IS NULL THEN
	       l_init_msg_list := FND_API.G_TRUE;
          END IF;

          IF p_commit IS NULL THEN
	       l_commit := FND_API.G_FALSE;
          END IF;

	  -- Setting Rec values to be passed to OKS API

	  IF p_product_item_id = FND_API.G_MISS_NUM THEN
	    l_avail_service_rec.PRODUCT_ITEM_ID := NULL;
	  ELSE
	    l_avail_service_rec.PRODUCT_ITEM_ID  := p_product_item_id;
		 END IF;
	  IF p_customer_id = FND_API.G_MISS_NUM THEN
	    l_avail_service_rec.CUSTOMER_ID := NULL;
	  ELSE
	    l_avail_service_rec.CUSTOMER_ID  := p_customer_id;
	  END IF;
	  IF p_product_revision = FND_API.G_MISS_CHAR THEN
	    l_avail_service_rec.PRODUCT_REVISION := NULL;
	  ELSE
	    l_avail_service_rec.PRODUCT_REVISION  := p_product_revision;
	  END IF;
	  IF p_request_date = FND_API.G_MISS_DATE THEN
	    l_avail_service_rec.request_date := NULL;
	  ELSE
	    l_avail_service_rec.request_date  := p_request_date;
	  END IF;


	  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    IBE_UTIL.Debug('OKS_OMINT_PUB.Available_Services Starts');
	  END IF;


	  OKS_OMINT_PUB.Available_Services(
	        P_Api_Version	=> 1.0 ,
	        P_init_msg_list	=> l_init_msg_list,
		       X_msg_Count     => X_msg_count ,
	        X_msg_Data	=> X_msg_data	 ,
	        X_Return_Status	=> X_return_status  ,
		       p_avail_service_rec => l_avail_service_rec,
		       X_Orderable_Service_tbl	 => l_Orderable_Service_tbl
	  	   );


	  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;
	  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

	  l_count := l_orderable_service_tbl.COUNT;
	  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	     IBE_UTIL.Debug('   OKS_OMINT_PUB.Available_Services Finishes ' || x_return_status || '  ' ||
				  'l_orderable_service_tbl.COUNT=' || l_count);
	  END IF;

	  x_service_item_ids   := JTF_NUMBER_TABLE();

    --Bug 17177115
        tmpIdx       :=1;
        l_service_items_pub_tbl	:= JTF_NUMBER_TABLE();
        l_pub_count :=0;

	  IF l_count > 0 THEN
	    x_service_item_ids.extend(l_count);
	    FOR i IN 1..l_count LOOP
	      x_service_item_ids(i) := l_orderable_service_tbl(i).service_item_id;
--Bug 17177115

      open c_publishedItem(l_orderable_service_tbl(i).service_item_id);
       fetch c_publishedItem into l_pub_count;
      CLOSE c_publishedItem;

	  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      	     IBE_UTIL.Debug(' Bug 17177115 l_pub_count is =' || l_pub_count);
	  END IF;
        if( l_pub_count > 0  ) then

              l_service_items_pub_tbl.EXTEND;
              l_service_items_pub_tbl(tmpIdx) := l_orderable_service_tbl(i).service_item_id;
              tmpIdx := tmpIdx+1;
	  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	     IBE_UTIL.Debug('   Bug 17177115 published item =' || l_orderable_service_tbl(i).service_item_id || ' l_service_items_pub_tbl.COUNT=' || l_service_items_pub_tbl.COUNT);
	  END IF;

        end if;

--end Bug 17177115
	    END LOOP;
	  END IF;

  --Bug 17177115
	  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	     IBE_UTIL.Debug('   Bug 17177115 Final l_service_items_pub_tbl.COUNT=' || l_service_items_pub_tbl.COUNT);
	  END IF;
  x_service_item_ids := l_service_items_pub_tbl;
	  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  	     IBE_UTIL.Debug('   Bug 17177115 Final x_service_item_ids.COUNT=' || x_service_item_ids.COUNT);
	  END IF;
	  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	     IBE_UTIL.Debug('End IBE_CATALOG_PVT.GetAvailableServices');
	  END IF;

	  EXCEPTION
	  WHEN FND_API.G_EXC_ERROR THEN
	   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	      IBE_Util.Debug('Expected error IBE_CATALOG_PVT.GetAvailableServices');
	   END IF;

	      ROLLBACK TO AVAILABLE_SERVICES_PUB;
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
	                                p_count   => x_msg_count,
	                                p_data    => x_msg_data);
	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	      IBE_Util.Debug('Expected error IBE_CATALOG_PVT.GetAvailableServices');
	   END IF;

	      ROLLBACK TO AVAILABLE_SERVICES_PUB;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
	                                p_count   => x_msg_count,
	                                p_data    => x_msg_data);
	   WHEN OTHERS THEN
	   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	      IBE_Util.Debug('unknown error IBE_CATALOG_PVT.GetAvailableServices');
	   END IF;

	      ROLLBACK TO AVAILABLE_SERVICES_PUB;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
	                                 l_api_name);
	      END IF;

	      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
	                                p_count   => x_msg_count,
	                                p_data    => x_msg_data);

	END GetAvailableServices;

-- Start of comments
--    API name   : GetRelatedCatOrSectIDs
--    Type       : Private.
--    Function   : Given an origin id, origin type, relationship type code,
--		   and destination object type, returns the ids
--		   of all objects of the given type related to the
--		   section by the given relationship code.  This API
--		   should only be used for destination types 'S' (section)
--		   and 'C' (category).  The p_preview_flag is only applicable
--		   when the destination object type is 'S' (section).  If
--		   p_preview_flag is true, returns sections whose
--		   web_status is 'PUBLISHED' or 'UNPUBLISHED'.
--		   Otherwise, returns sections whose web_status is
--		   'PUBLISHED'.
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        IN  NUMBER   	 Required
--                 p_init_msg_list      IN  VARCHAR2 	 Optional
--                     Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER   	 Optional
--                     Default = FND_API.G_VALID_LEVEL_FULL
--		   p_preview_flag	IN  VARCHAR2       Optional
--                     Default = FND_API.G_FALSE
--		   p_originid 		IN  NUMBER         Required
--		   p_origintype		IN  VARCHAR2(240)  Required
--		   p_reltype_code	IN  VARCHAR2(30)   Required
--		   p_dest_type		IN  VARCHAR2(240)  Required
--
--    OUT        : x_return_status      OUT VARCHAR2(1)
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2(2000)
--		   x_relatedid_tbl	OUT nocopy JTF_NUMBER_TABLE
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
  procedure GetRelatedCatOrSectIDs
		(
		 p_api_version 		IN  NUMBER,
                 p_init_msg_list      	IN  VARCHAR2 := NULL,
                 p_validation_level   	IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		 x_return_status	OUT NOCOPY VARCHAR2,
		 x_msg_count		OUT NOCOPY NUMBER,
		 x_msg_data		OUT NOCOPY VARCHAR2,

		 p_preview_flag		IN  VARCHAR2 := NULL,
		 p_originid		IN  NUMBER,
		 p_origintype		IN  VARCHAR2,
		 p_reltype_code		IN  VARCHAR2,
		 p_dest_type		IN  VARCHAR2,
		 x_relatedid_tbl 	OUT NOCOPY JTF_NUMBER_TABLE
		) IS
 	cursor l_reltype_csr IS
		SELECT start_date_active, end_date_active
		FROM FND_LOOKUPS
		WHERE lookup_type = 'IBE_RELATIONSHIP_TYPES'
		AND lookup_code = p_reltype_code
		AND enabled_flag = 'Y';

	l_relobj_stmt		VARCHAR2(4000);
	l_relobj_csr		IBE_CATALOG_REFCURSOR_CSR_TYPE;
	l_relobjid 		NUMBER;
 	l_api_name		CONSTANT VARCHAR2(30) 	:= 'GetRelatedCatOrSectIDs';
  	l_api_version		CONSTANT NUMBER		:= 1.0;
	l_table_index 		NUMBER;
	l_rel_start_date_active DATE;
	l_rel_end_date_active 	DATE;
  	l_init_msg_list 	VARCHAR2(5);
  	l_preview_flag  	VARCHAR2(5);


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

	IF p_init_msg_list IS NULL THEN
		l_init_msg_list := FND_API.G_FALSE;
	END IF;

	IF p_preview_flag IS NULL THEN
		l_preview_flag := FND_API.G_FALSE;
	END IF;

	-- initialize message list if l_init_msg_list is set to TRUE
	IF FND_API.to_Boolean(l_init_msg_list) THEN
	   FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.GETRELATEDCATORSECTIDS(+)');
		IBE_UTIL.debug('p_originid : p_origintype : p_reltype_code : p_dest_type ='
			|| p_originid || ' : ' || p_origintype || ' : ' || p_reltype_code ||
			' : ' || p_dest_type);
	END IF;
	-- API Body

	-- check if relationship exists and is active
	OPEN l_reltype_csr;
	FETCH l_reltype_csr INTO l_rel_start_date_active, l_rel_end_date_active;
	IF l_reltype_csr%NOTFOUND THEN
	   CLOSE l_reltype_csr;
	   FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_EXIST');
	   FND_MESSAGE.Set_Token('RELATIONSHIP_TYPE', p_reltype_code);
	   FND_MSG_PUB.Add;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE l_reltype_csr;

	-- if relationship type code is not active, return NULL table
	IF NVL(l_rel_start_date_active, SYSDATE) > SYSDATE
	   OR NVL(l_rel_end_date_active, SYSDATE) < SYSDATE THEN
		x_relatedid_tbl := NULL;
		RETURN;
	END IF;

	-- initialize return value x_relatedid_tbl
	x_relatedid_tbl := JTF_NUMBER_TABLE();

	-- initialize table index
	l_table_index := 1;

	IF p_dest_type = 'S' THEN
	   IF FND_API.to_Boolean(l_preview_flag) THEN
	      l_relobj_stmt := 	'SELECT rr.DEST_OBJECT_ID ' ||
				'FROM IBE_CT_RELATION_RULES rr, IBE_DSP_SECTIONS_B jdsb ' ||
				'WHERE rr.ORIGIN_OBJECT_TYPE = :p_origintype ' ||
				'AND rr.ORIGIN_OBJECT_ID = :p_originid ' ||
				'AND rr.RELATION_TYPE_CODE = :p_reltype_code ' ||
				'AND rr.DEST_OBJECT_TYPE = :p_dest_type ' ||
				'AND rr.DEST_OBJECT_ID = jdsb.SECTION_ID ' ||
				'AND (jdsb.status_code = ''PUBLISHED'' OR jdsb.status_code = ''UNPUBLISHED'') ' ||
				'AND NVL(jdsb.start_date_active, SYSDATE) <= SYSDATE ' ||
				'AND NVL(jdsb.end_date_active, SYSDATE) >= SYSDATE ';
	   ELSE
	      l_relobj_stmt := 	'SELECT rr.DEST_OBJECT_ID ' ||
				'FROM IBE_CT_RELATION_RULES rr, IBE_DSP_SECTIONS_B jdsb ' ||
				'WHERE rr.ORIGIN_OBJECT_TYPE = :p_origintype ' ||
				'AND rr.ORIGIN_OBJECT_ID = :p_originid ' ||
				'AND rr.RELATION_TYPE_CODE = :p_reltype_code ' ||
				'AND rr.DEST_OBJECT_TYPE = :p_dest_type ' ||
				'AND rr.DEST_OBJECT_ID = jdsb.SECTION_ID ' ||
				'AND jdsb.status_code = ''PUBLISHED'' ' ||
				'AND NVL(jdsb.start_date_active, SYSDATE) <= SYSDATE ' ||
				'AND NVL(jdsb.end_date_active, SYSDATE) >= SYSDATE ';
	   END IF;
	ELSE
	      l_relobj_stmt := 	'SELECT rr.DEST_OBJECT_ID ' ||
				'FROM IBE_CT_RELATION_RULES rr ' ||
				'WHERE rr.ORIGIN_OBJECT_TYPE = :p_origintype ' ||
				'AND rr.ORIGIN_OBJECT_ID = :p_originid ' ||
				'AND rr.RELATION_TYPE_CODE = :p_reltype_code ' ||
				'AND rr.DEST_OBJECT_TYPE = :p_dest_type ';
	END IF;

	OPEN l_relobj_csr FOR l_relobj_stmt
	USING p_origintype, p_originid, p_reltype_code, p_dest_type;

	LOOP

   	FETCH l_relobj_csr INTO l_relobjid;
   	EXIT WHEN l_relobj_csr%NOTFOUND;
	IF l_relobjid IS NOT NULL THEN
   	   x_relatedid_tbl.EXTEND;
   	   x_relatedid_tbl(l_table_index) := l_relobjid;
   	   l_table_index := l_table_index + 1;
	END IF;

	END LOOP;
	CLOSE l_relobj_csr;

	IF x_relatedid_tbl.COUNT = 0 THEN
	   x_relatedid_tbl := NULL;
	END IF;

	-- End API Body
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.GETRELATEDCATORSECTIDS(-)');
	END IF ;

	-- standard call to get messgae count and if count is 1, get message info.
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
	END GetRelatedCatOrSectIDs;

-- Start of comments
--    API name   : Get_Basic_Item_Load_Query
--    Type       : Private.
--    Function   : Returns select and from clauses for an item load query when given
--		   the load level and category set id.
--    Pre-reqs   : None.
--    Parameters :
--    IN  	 : p_load_level			IN NUMBER
--		 	Possible Values: G_ITEM_SHALLOW, G_ITEM_DEEP, G_ITEM_DEEP_ONLY
--		   p_category_set_id		IN NUMBER
--
--    OUT        : x_basic_query
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
  procedure Get_Basic_Item_Load_Query
  (
    p_load_level	IN	NUMBER,
    x_basic_query	OUT	NOCOPY VARCHAR2
  ) IS

     L_BASIC_SHALLOW_QUERY	CONSTANT VARCHAR2(1000) :=
		'SELECT MSIV.CONFIG_MODEL_TYPE, MSIV.BOM_ENABLED_FLAG, MSIV.ORDERABLE_ON_WEB_FLAG, MSIV.BACK_ORDERABLE_FLAG, ' ||
		'MSIV.PRIMARY_UNIT_OF_MEASURE, MSIV.PRIMARY_UOM_CODE, ' ||
		'MSIV.ITEM_TYPE,  MSIV.BOM_ITEM_TYPE, ' ||
		'MSIV.INDIVISIBLE_FLAG, MSIV.SERIAL_NUMBER_CONTROL_CODE, MSIV.WEB_STATUS, ' ||
		'MSIV.CONCATENATED_SEGMENTS, MSIV.INVENTORY_ITEM_ID, '||
		 --gzhang 10/24/2002, ER#2474216
		'MSIV.SERVICE_ITEM_FLAG,MSIV.SERVICEABLE_PRODUCT_FLAG,MSIV.SERVICE_DURATION_PERIOD_CODE,MSIV.SERVICE_DURATION, '||
		'MSIV.SHIPPABLE_ITEM_FLAG,MSIV.INVOICEABLE_ITEM_FLAG,MSIV.INVOICE_ENABLED_FLAG, MSIV.START_DATE_ACTIVE, MSIV.END_DATE_ACTIVE '||
		'FROM MTL_SYSTEM_ITEMS_VL MSIV ';


     L_BASIC_DEEP_QUERY		CONSTANT VARCHAR2(2100) :=
      		'SELECT MSIV.CONFIG_MODEL_TYPE, MSIV.BOM_ENABLED_FLAG, MSIV.ORDERABLE_ON_WEB_FLAG, MSIV.BACK_ORDERABLE_FLAG, ' ||
		'MSIV.PRIMARY_UNIT_OF_MEASURE, MSIV.PRIMARY_UOM_CODE, ' ||
		'MSIV.ITEM_TYPE,  MSIV.BOM_ITEM_TYPE, ' ||
		'MSIV.INDIVISIBLE_FLAG, MSIV.SERIAL_NUMBER_CONTROL_CODE, MSIV.WEB_STATUS, ' ||
		'MSIV.CONCATENATED_SEGMENTS, MSIV.INVENTORY_ITEM_ID, '||

		 --gzhang 10/24/2002, ER#2474216
		'MSIV.SERVICE_ITEM_FLAG,MSIV.SERVICEABLE_PRODUCT_FLAG,MSIV.SERVICE_DURATION_PERIOD_CODE,MSIV.SERVICE_DURATION, '||

		'MSIV.SHIPPABLE_ITEM_FLAG,MSIV.INVOICEABLE_ITEM_FLAG,MSIV.INVOICE_ENABLED_FLAG, MSIV.TAXABLE_FLAG, MSIV.ATP_FLAG, MSIV.RETURNABLE_FLAG, ' ||
		'MSIV.DOWNLOADABLE_FLAG, MSIV.MINIMUM_ORDER_QUANTITY, ' ||
		'MSIV.MAXIMUM_ORDER_QUANTITY, MSIV.FIXED_ORDER_QUANTITY, ' ||
		'MSIV.SERVICE_STARTING_DELAY, MSIV.SEGMENT1, MSIV.SEGMENT2, MSIV.SEGMENT3, MSIV.SEGMENT4, ' ||
		'MSIV.SEGMENT5, MSIV.SEGMENT6, MSIV.SEGMENT7, MSIV.SEGMENT8, MSIV.SEGMENT9, MSIV.SEGMENT10, ' ||
		'MSIV.SEGMENT11, MSIV.SEGMENT12, MSIV.SEGMENT13, MSIV.SEGMENT14, MSIV.SEGMENT15, MSIV.SEGMENT16, ' ||
		'MSIV.SEGMENT17, MSIV.SEGMENT18, MSIV.SEGMENT19, MSIV.SEGMENT20, MSIV.ATTRIBUTE1, ' ||
		'MSIV.ATTRIBUTE2, MSIV.ATTRIBUTE3, MSIV.ATTRIBUTE4, MSIV.ATTRIBUTE5, MSIV.ATTRIBUTE6, ' ||
		'MSIV.ATTRIBUTE7, MSIV.ATTRIBUTE8, MSIV.ATTRIBUTE9, MSIV.ATTRIBUTE10, MSIV.ATTRIBUTE11, ' ||
		'MSIV.ATTRIBUTE12, MSIV.ATTRIBUTE13, MSIV.ATTRIBUTE14, MSIV.ATTRIBUTE15, MSIV.ATTRIBUTE_CATEGORY, ' ||
		'MSIV.COUPON_EXEMPT_FLAG, MSIV.VOL_DISCOUNT_EXEMPT_FLAG, MSIV.ELECTRONIC_FLAG, ' ||
		'MSIV.GLOBAL_ATTRIBUTE_CATEGORY, ' ||
		'MSIV.GLOBAL_ATTRIBUTE1, MSIV.GLOBAL_ATTRIBUTE2, MSIV.GLOBAL_ATTRIBUTE3, MSIV.GLOBAL_ATTRIBUTE4, ' ||
		'MSIV.GLOBAL_ATTRIBUTE5, MSIV.GLOBAL_ATTRIBUTE6, MSIV.GLOBAL_ATTRIBUTE7, MSIV.GLOBAL_ATTRIBUTE8, ' ||
		'MSIV.GLOBAL_ATTRIBUTE9, MSIV.GLOBAL_ATTRIBUTE10 FROM MTL_SYSTEM_ITEMS_VL MSIV ';


     L_BASIC_DEEP_ONLY_QUERY	CONSTANT VARCHAR2(2000) := --gzhang 10/24/2002, ER#2474216
      		'SELECT MSIV.TAXABLE_FLAG, MSIV.ATP_FLAG, MSIV.RETURNABLE_FLAG, ' ||
		'MSIV.DOWNLOADABLE_FLAG, MSIV.MINIMUM_ORDER_QUANTITY, MSIV.MAXIMUM_ORDER_QUANTITY, MSIV.FIXED_ORDER_QUANTITY, ' ||
		'MSIV.SERVICE_STARTING_DELAY, MSIV.SEGMENT1, MSIV.SEGMENT2, MSIV.SEGMENT3, MSIV.SEGMENT4, ' ||
		'MSIV.SEGMENT5, MSIV.SEGMENT6, MSIV.SEGMENT7, MSIV.SEGMENT8, MSIV.SEGMENT9, MSIV.SEGMENT10, ' ||
		'MSIV.SEGMENT11, MSIV.SEGMENT12, MSIV.SEGMENT13, MSIV.SEGMENT14, MSIV.SEGMENT15, MSIV.SEGMENT16, ' ||
		'MSIV.SEGMENT17, MSIV.SEGMENT18, MSIV.SEGMENT19, MSIV.SEGMENT20, MSIV.ATTRIBUTE1, ' ||
		'MSIV.ATTRIBUTE2, MSIV.ATTRIBUTE3, MSIV.ATTRIBUTE4, MSIV.ATTRIBUTE5, MSIV.ATTRIBUTE6, ' ||
		'MSIV.ATTRIBUTE7, MSIV.ATTRIBUTE8, MSIV.ATTRIBUTE9, MSIV.ATTRIBUTE10, MSIV.ATTRIBUTE11, ' ||
		'MSIV.ATTRIBUTE12, MSIV.ATTRIBUTE13, MSIV.ATTRIBUTE14, MSIV.ATTRIBUTE15, MSIV.ATTRIBUTE_CATEGORY, ' ||
		'MSIV.COUPON_EXEMPT_FLAG, MSIV.VOL_DISCOUNT_EXEMPT_FLAG, MSIV.ELECTRONIC_FLAG, ' ||
		'MSIV.GLOBAL_ATTRIBUTE_CATEGORY, ' ||
		'MSIV.GLOBAL_ATTRIBUTE1, MSIV.GLOBAL_ATTRIBUTE2, MSIV.GLOBAL_ATTRIBUTE3, MSIV.GLOBAL_ATTRIBUTE4, ' ||
		'MSIV.GLOBAL_ATTRIBUTE5, MSIV.GLOBAL_ATTRIBUTE6, MSIV.GLOBAL_ATTRIBUTE7, MSIV.GLOBAL_ATTRIBUTE8, ' ||
		'MSIV.GLOBAL_ATTRIBUTE9, MSIV.GLOBAL_ATTRIBUTE10, MSIV.CONCATENATED_SEGMENTS, ' ||
		'MSIV.INVENTORY_ITEM_ID FROM MTL_SYSTEM_ITEMS_VL MSIV ';

	BEGIN
	   IF p_load_level = G_ITEM_SHALLOW THEN
		x_basic_query := L_BASIC_SHALLOW_QUERY;
	   ELSE
	      IF p_load_level = G_ITEM_DEEP THEN
		x_basic_query := L_BASIC_DEEP_QUERY;
	      ELSE
		x_basic_query := L_BASIC_DEEP_ONLY_QUERY;
	     END IF;
	   END IF;

	END GET_BASIC_ITEM_LOAD_QUERY;

-- Start of comments
--    API name   : Process_Order_By_Clause
--    Type       : Private.
--    Function   : Takes comma separated list of columns (with option asc or desc) of
--		   MTL_SYSTEM_ITEMS_VL and appends 'MSIV.' in front of each column name so
--                 it can be used in the order by clause of a query that joins with
--                 MTL_SYSTEM_ITEMS_VL.
--    Pre-reqs   : None.
--    Parameters :
--    IN  	 : p_order_by_clause			IN VARCHAR2
--
--
--    OUT        : x_order_by_clause			OUT VARCHAR2
--
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
procedure Process_Order_By_Clause
	(p_order_by_clause IN VARCHAR2,
	 x_order_by_clause OUT NOCOPY VARCHAR2
	) IS
  l_start    NUMBER := 1;
  l_position NUMBER := 1;
  l_token    VARCHAR2(2000) := NULL;
  l_counter  NUMBER := 1;

  begin
	x_order_by_clause := NULL;
	IF p_order_by_clause IS NULL THEN
	   return;
	END IF;

	WHILE l_position <> 0 LOOP
	  l_position := INSTR(p_order_by_clause, ',', 1, l_counter);
	  IF l_position <> 0 THEN
	    l_token := substr(p_order_by_clause, l_start, l_position - l_start + 1);
          ELSE
            l_token := substr(p_order_by_clause, l_start);
	  END IF;
	  l_token := LTRIM(l_token);

	  IF (l_token IS NULL OR l_token = '') THEN
	     NULL; --no-op if NULL or empty
	  ELSE
	     x_order_by_clause := x_order_by_clause || ' MSIV.' || l_token;
	  END IF;
          l_start := l_position + 1;
	  l_counter := l_counter + 1;
	END LOOP;
  end Process_Order_By_Clause;

-- Start of comments
--    API name   : Get_Format_Mask_and_Symbol
--    Type       : Private.
--    Function   : Given currency code and length, retrieves format mask and
--		   currency symbol.  Uses FND_CURRENCY.get_format_mask().
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        	IN  NUMBER   Required
--                 p_init_msg_list      	IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--                 p_validation_level   	IN  NUMBER   Optional
--                     Default = FND_API.G_VALID_LEVEL_FULL
--		   p_currency_code		IN NUMBER
--		   p_length			IN NUMBER
--
--    OUT        : x_return_status      	OUT VARCHAR2(1)
--                 x_msg_count          	OUT NUMBER
--                 x_msg_data           	OUT VARCHAR2(2000)
--		   x_format_mask		OUT nocopy VARCHAR2
--		   x_currency_symbol		OUT nocopy VARCHAR2
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
procedure Get_Format_Mask_and_Symbol
	(p_api_version        		IN  NUMBER,
         p_init_msg_list      		IN  VARCHAR2 := NULL,
         p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	 x_return_status      		OUT NOCOPY VARCHAR2,
         x_msg_count          		OUT NOCOPY NUMBER,
         x_msg_data           		OUT NOCOPY VARCHAR2,

	 p_currency_code		IN VARCHAR2,
	 p_length			IN NUMBER,
	 x_format_mask			OUT nocopy VARCHAR2,
	 x_currency_symbol		OUT nocopy VARCHAR2
	) IS

	cursor l_currency_symbol_csr(l_currency_code VARCHAR2) IS
	   SELECT fc.symbol FROM FND_CURRENCIES fc
	   WHERE fc.currency_code = l_currency_code;

  	l_api_name		CONSTANT VARCHAR2(30) 	:= 'Get_Format_Mask_and_Symbol';
  	l_api_version		CONSTANT NUMBER		:= 1.0;
  	l_init_msg_list 	VARCHAR2(5);

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
	IF p_init_msg_list IS NULL THEN
		l_init_msg_list := FND_API.G_FALSE;
	END IF;

	-- initialize message list if l_init_msg_list is set to TRUE
	IF FND_API.to_Boolean(l_init_msg_list) THEN
	   FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.Get_Format_Mask_and_Symbol(+)');
		IBE_UTIL.debug('p_currency_code : p_length = ' || p_currency_code ||
			' : ' || p_length);
	END IF;
	-- begin API body
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('Calling FND_CURRENCY.Get_Format_Mask ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
	END IF;
	x_format_mask := FND_CURRENCY.Get_Format_Mask(p_currency_code, p_length);
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('Return from FND_CURRENCY.Get_Format_Mask ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
	END IF;
	OPEN l_currency_symbol_csr(p_currency_code);
	FETCH l_currency_symbol_csr INTO x_currency_symbol;
	CLOSE l_currency_symbol_csr;

	-- end API body
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.Get_Format_Mask_and_Symbol(-)');
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
     		   FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     		   FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     		   FND_MESSAGE.Set_Token('REASON', SQLERRM);
     		   FND_MSG_PUB.Add;
		   IF FND_MSG_PUB.Check_Msg_Level
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
	end Get_Format_Mask_and_Symbol;

procedure validate_quantity
        (p_api_version        		IN  NUMBER,
         p_init_msg_list      		IN  VARCHAR2 := NULL,
         p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
         x_return_status      		OUT NOCOPY VARCHAR2,
         x_msg_count          		OUT NOCOPY NUMBER,
         x_msg_data           		OUT NOCOPY VARCHAR2,

         p_item_id_tbl			IN  JTF_NUMBER_TABLE,
         p_organization_id_tbl		IN  JTF_NUMBER_TABLE,
         p_qty_tbl			IN  JTF_NUMBER_TABLE,
         p_uom_code_tbl			IN  JTF_VARCHAR2_TABLE_100,
         x_valid_qty_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100
        ) is

l_api_name		CONSTANT VARCHAR2(30) 	:= 'validate_quantity';
l_api_version		CONSTANT NUMBER		:= 1.0;
l_output_qty            NUMBER;
l_primary_qty           NUMBER;
l_init_msg_list 	VARCHAR2(5);
begin

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

IF p_init_msg_list IS NULL THEN
	l_init_msg_list := FND_API.G_FALSE;
END IF;

-- initialize message list if L_init_msg_list is set to TRUE
IF FND_API.to_Boolean(l_init_msg_list) THEN
   FND_MSG_PUB.initialize;
END IF;

-- initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.debug('IBE_CATALOG_PVT.validate_quantity(+)');
END IF;
-- begin API body

x_valid_qty_tbl := JTF_VARCHAR2_TABLE_100();
x_valid_qty_tbl.extend(p_item_id_tbl.count);

for i in 1..p_item_id_tbl.count loop

   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   	IBE_UTIL.debug('Calling INV_DECIMALS_PUB.validate_quantity ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
   END IF;
   inv_decimals_pub.validate_quantity(p_item_id_tbl(i), p_organization_id_tbl(i), p_qty_tbl(i),
                                      p_uom_code_tbl(i), l_output_qty, l_primary_qty, x_valid_qty_tbl(i));
   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   	IBE_UTIL.debug('Return from INV_DECIMALS_PUB.validate_quantity ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
   END IF;
end loop;

-- end API body
IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.debug('IBE_CATALOG_PVT.validate_quantity(-)');
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
      FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
      FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
      FND_MESSAGE.Set_Token('REASON', SQLERRM);
      FND_MSG_PUB.Add;
      IF FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN FND_MSG_PUB.Add_Exc_Msg
	(G_PKG_NAME,
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
end validate_quantity;

--Bug 3063233
procedure validate_de_qty_msite_check
        (p_api_version        		IN  NUMBER,
         p_init_msg_list      		IN  VARCHAR2 := NULL,
	 p_reqd_validation              IN  JTF_VARCHAR2_TABLE_100,
	 p_msite_id                     IN NUMBER,
         x_return_status      		OUT NOCOPY VARCHAR2,
         x_msg_count          		OUT NOCOPY NUMBER,
         x_msg_data           		OUT NOCOPY VARCHAR2,
         p_item_id_tbl			IN  JTF_NUMBER_TABLE,
         p_organization_id_tbl		IN  JTF_NUMBER_TABLE,
         p_qty_tbl			IN  JTF_NUMBER_TABLE,
         p_uom_code_tbl			IN  JTF_VARCHAR2_TABLE_100,
         x_valid_qty_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100
        ) is

l_api_name		CONSTANT VARCHAR2(30) 	:= 'validate_de_qty_msite_check';
l_api_version		CONSTANT NUMBER		:= 1.0;
l_output_qty            NUMBER;
l_primary_qty           NUMBER;
l_item_exists			NUMBER;
l_init_msg_list 	VARCHAR2(5);

begin

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

IF p_init_msg_list IS NULL THEN
	l_init_msg_list := FND_API.G_FALSE;
END IF;

-- initialize message list if L_init_msg_list is set to TRUE
IF FND_API.to_Boolean(l_init_msg_list) THEN
   FND_MSG_PUB.initialize;
END IF;

-- initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.debug('IBE_CATALOG_PVT.validate_quantity(+)');
END IF;

-- begin API body

x_valid_qty_tbl := JTF_VARCHAR2_TABLE_100();
x_valid_qty_tbl.extend(p_item_id_tbl.count);

for i in 1..p_item_id_tbl.count loop

   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   	IBE_UTIL.debug('Calling INV_DECIMALS_PUB.validate_quantity ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
   END IF;
   inv_decimals_pub.validate_quantity(p_item_id_tbl(i), p_organization_id_tbl(i), p_qty_tbl(i),
                                      p_uom_code_tbl(i), l_output_qty, l_primary_qty, x_valid_qty_tbl(i));
   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   	IBE_UTIL.debug('Return from INV_DECIMALS_PUB.validate_quantity ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
   END IF;
end loop;

-- end API body
IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	IBE_UTIL.debug('IBE_CATALOG_PVT.validate_quantity(-)');
END IF;

for i in 1..x_valid_qty_tbl.count loop
  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  	IBE_UTIL.debug('checking the value in x_valid_qty_tbl');
  END IF;
  if (x_valid_qty_tbl(i) = 'S') then
    x_valid_qty_tbl(i) := '';
  else
    x_valid_qty_tbl(i) := 'IBE_PRMT_SC_DE_ITEM_QTY_INV';
  end if;
end loop;

-- standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get
(	p_encoded => FND_API.G_FALSE,
	p_count => x_msg_count,
	p_data  => x_msg_data
);
--gzhang 08/08/2002, bug#2488246
--ibe_util.disable_debug;

--do the check to see whether item belongs to a section in the minisite
FOR i in 1..p_item_id_tbl.count LOOP
  IF (x_valid_qty_tbl(i) IS null or
      x_valid_qty_tbl(i)= '') THEN
    BEGIN
      SELECT count(s.inventory_item_id)
      INTO l_item_exists
	  FROM ibe_dsp_section_items s, ibe_dsp_msite_sct_items b
 	  WHERE s.section_item_id = b.section_item_id
	  AND   b.mini_site_id = p_msite_id
	  AND   s.inventory_item_id = p_item_id_tbl(i)
	  AND   s.organization_id = p_organization_id_tbl(i) -- bug 10092967, scnagara
	  AND   (s.end_date_active > sysdate or s.end_date_active is null )
	  AND   s.start_date_active < sysdate;
    EXCEPTION
      WHEN OTHERS THEN
        x_valid_qty_tbl(i) := 'IBE_PRMT_SC_DE_ITEM_NSETUP';
    END;

    IF( l_item_exists <= 0  ) THEN
	  --item does not exist in some section
      x_valid_qty_tbl(i) := 'IBE_PRMT_SC_DE_ITEM_NSETUP';
	END IF;
  END IF;
END LOOP;
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
      IF FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN FND_MSG_PUB.Add_Exc_Msg
	(G_PKG_NAME,
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
end validate_de_qty_msite_check;

-- gzhang, 04/23/02, new APIs for Global Store Selection phase 2
procedure load_msite_languages
        (x_lang_code_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
         x_tran_lang_code_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
         x_desc_tbl			OUT NOCOPY JTF_VARCHAR2_TABLE_300 --gzhang 07/19/2002, bug#2469521
        )
IS
    CURSOR l_lang_csr IS
	SELECT language_code, language, description
	FROM fnd_languages_tl t
	WHERE EXISTS (SELECT NULL FROM ibe_msite_languages m WHERE m.language_code = t.language_code)
	ORDER BY language_code;

    l_index NUMBER := 1;

BEGIN
    --gzhang 08/08/2002, bug#2488246
    --ibe_util.enable_debug;
    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
    	IBE_UTIL.debug('In IBE_CATALOG_PVT.load_msite_languages...');
    END IF;

    x_lang_code_tbl := JTF_VARCHAR2_TABLE_100();
    x_tran_lang_code_tbl := JTF_VARCHAR2_TABLE_100();
    x_desc_tbl := JTF_VARCHAR2_TABLE_300(); --gzhang 07/19/2002, bug#2469521

    FOR l_lang_rec IN l_lang_csr LOOP

        x_lang_code_tbl.EXTEND;
        x_tran_lang_code_tbl.EXTEND;
        x_desc_tbl.EXTEND;

        x_lang_code_tbl(l_index) := l_lang_rec.language_code;
        x_tran_lang_code_tbl(l_index) := l_lang_rec.language;
        x_desc_tbl(l_index) := l_lang_rec.description;

       	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       		IBE_UTIL.debug('language code='||x_lang_code_tbl(l_index)||',translated language code='||x_tran_lang_code_tbl(l_index)||',desc='||x_desc_tbl(l_index));
       	END IF;

        l_index := l_index + 1;
    END LOOP;
    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
    	IBE_UTIL.debug('IBE_CATALOG_PVT.load_msite_languages:done');
    END IF;
    --gzhang 08/08/2002, bug#2488246
    --ibe_util.disable_debug;
EXCEPTION
   WHEN OTHERS THEN
       	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       		IBE_UTIL.debug('Exception in IBE_CATALOG_PVT.load_msite_languages');
       	END IF;
       	--gzhang 08/08/2002, bug#2488246
       	--ibe_util.disable_debug;

END load_msite_languages;

procedure load_language
        (p_lang_code			IN VARCHAR2,
         x_tran_lang_code_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
         x_desc_tbl			OUT NOCOPY JTF_VARCHAR2_TABLE_300, --gzhang 07/19/2002, bug#2469521
         x_nls_lang			OUT NOCOPY VARCHAR2  --jqu 1/19/2005
        )
IS
    CURSOR l_lang_csr (l_lang_code VARCHAR2) IS
        SELECT t.language, t.description
        FROM fnd_languages_tl t
        WHERE language_code = l_lang_code;
    CURSOR l_nls_lang_csr (l_lang_code VARCHAR2) IS
	SELECT nls_language
        FROM fnd_languages
 	WHERE language_code = l_lang_code;

    l_index NUMBER := 1;

BEGIN
    --gzhang 08/08/2002, bug#2488246
    --ibe_util.enable_debug;
    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
    	IBE_UTIL.debug('In IBE_CATALOG_PVT.LOAD_LANGUAGE...');
    	IBE_UTIL.debug('p_lang_code ='||p_lang_code);
    END IF;

    x_tran_lang_code_tbl := JTF_VARCHAR2_TABLE_100();
    x_desc_tbl := JTF_VARCHAR2_TABLE_300(); --gzhang 07/19/2002, bug#2469521

    FOR l_lang_rec IN l_lang_csr(p_lang_code) LOOP

        x_tran_lang_code_tbl.EXTEND;
        x_desc_tbl.EXTEND;

        x_tran_lang_code_tbl(l_index) := l_lang_rec.language;
        x_desc_tbl(l_index) := l_lang_rec.description;

       	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       		IBE_UTIL.debug('translated language code='||x_tran_lang_code_tbl(l_index)||',desc='||x_desc_tbl(l_index));
       	END IF;

        l_index := l_index + 1;
    END LOOP;

    OPEN l_nls_lang_csr(p_lang_code);
    FETCH l_nls_lang_csr INTO x_nls_lang;
    CLOSE l_nls_lang_csr;

    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
    	IBE_UTIL.debug('IBE_CATALOG_PVT.LOAD_LANGUAGE:done');
    END IF;
    --gzhang 08/08/2002, bug#2488246
    --ibe_util.disable_debug;
EXCEPTION
   WHEN OTHERS THEN
       	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       		IBE_UTIL.debug('Exception in IBE_CATALOG_PVT.load_language');
       	END IF ;
       --gzhang 08/08/2002, bug#2488246
       --ibe_util.disable_debug;

END load_language;
-- gzhang, 04/23/02, end of new APIs for Global Store Selection phase 2



--integration with QP_TEMP_TABLE
  procedure FETCH_ITEM
		(p_api_version        		IN  NUMBER,
                 p_init_msg_list      		IN  VARCHAR2 := NULL,
                 p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     		 x_return_status      		OUT NOCOPY VARCHAR2,
                 x_msg_count          		OUT NOCOPY NUMBER,
                 x_msg_data           		OUT NOCOPY VARCHAR2,

		 p_load_level			IN  NUMBER,
		 p_preview_flag			IN  VARCHAR2,
		 p_itmid 			IN  NUMBER,
		 p_partnum			IN  VARCHAR2,
		 p_model_id			IN  NUMBER    := FND_API.G_MISS_NUM,
		 p_organization_id		IN  NUMBER,
		 p_category_set_id		IN  NUMBER,
		 x_item_csr			OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE,
		 x_category_id_csr		OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE,
		 x_configurable			OUT NOCOPY VARCHAR2,
		 x_model_bundle_flag		OUT NOCOPY VARCHAR2,
		 x_uom_csr			OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE

		) IS

     l_api_name			CONSTANT VARCHAR2(30) 	:= 'FETCH_ITEM';
     l_api_version		CONSTANT NUMBER		:= 1.0;

     cursor l_itmid_csr(p_item_partnum VARCHAR2) IS
	select MSIV.inventory_item_id
 	from mtl_system_items_vl MSIV
	where MSIV.concatenated_segments = p_item_partnum;

     l_itmid			NUMBER;
     l_itm_stmt			VARCHAR2(32767);
     l_ui_def_id		NUMBER;
     l_resp_id			NUMBER;
     l_resp_appl_id		NUMBER;
     l_retrieve_all_uom		VARCHAR2(10);
     l_start_time		NUMBER;
     l_end_time			NUMBER;
     l_init_msg_list 	        VARCHAR2(5);

  BEGIN
     	IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
   	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	END IF;

	IF p_init_msg_list IS NULL THEN
		l_init_msg_list := FND_API.G_FALSE;
	END IF;

	-- initialize message list if L_init_msg_list is set to TRUE
	IF FND_API.to_Boolean(l_init_msg_list) THEN
	   FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;


	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.FETCH_ITEM(+)');
	END IF;
	l_start_time := DBMS_UTILITY.GET_TIME;

	-- get the select and from clauses of the query
	Get_Basic_Item_Load_Query(p_load_level, l_itm_stmt);

	IF p_itmid IS NULL THEN
   	   IF p_partnum IS NULL THEN
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('Error: p_itm_id and p_accessname are both NULL');
		END IF;
		FND_MESSAGE.Set_Name('IBE', 'IBE_CT_INVALID_ID_OR_NAME');
		FND_MESSAGE.Set_Token('ID_NAME', p_partnum);
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
   	   ELSE
	      --loading by part number

	      -- need to get item id
	      OPEN l_itmid_csr(p_partnum);
	      FETCH l_itmid_csr INTO l_itmid;
	      CLOSE l_itmid_csr;

   	  END IF;
	ELSE
	  -- loading by item_id
	  l_itmid := p_itmid;
	END IF;

	-- add check in where clause for organization id, active dates, web_status
	l_itm_stmt := l_itm_stmt || 'WHERE MSIV.INVENTORY_ITEM_ID = :p_itmid ' ||
		      ' AND MSIV.ORGANIZATION_ID = :p_organization_id ';

	IF NOT FND_API.to_Boolean(p_preview_flag) THEN
	   l_itm_stmt := l_itm_stmt || ' AND MSIV.WEB_STATUS = ''PUBLISHED'' ';
	END IF;

	l_itm_stmt := l_itm_stmt ||
		      ' AND NVL(MSIV.START_DATE_ACTIVE, SYSDATE) <= SYSDATE ' ||
		      ' AND NVL(MSIV.END_DATE_ACTIVE, SYSDATE) >= SYSDATE ';

       -- open the item cursor for return
       OPEN x_item_csr FOR l_itm_stmt USING l_itmid, p_organization_id;

	-- open category id cursor for return if category set id is not null
	IF (p_category_set_id IS NOT NULL) THEN
	   OPEN x_category_id_csr FOR
		SELECT MSIV.INVENTORY_ITEM_ID, mic.CATEGORY_ID
		FROM MTL_SYSTEM_ITEMS_VL MSIV, MTL_ITEM_CATEGORIES mic
		WHERE MSIV.INVENTORY_ITEM_ID = l_itmid
		AND MSIV.ORGANIZATION_ID = p_organization_id
		AND NVL(MSIV.START_DATE_ACTIVE, SYSDATE) <= SYSDATE
		AND NVL(MSIV.END_DATE_ACTIVE, SYSDATE) >= SYSDATE
		AND MSIV.INVENTORY_ITEM_ID = mic.INVENTORY_ITEM_ID
		AND MSIV.ORGANIZATION_ID = mic.ORGANIZATION_ID
		AND mic.CATEGORY_SET_ID = p_category_set_id;
	END IF;

       -- open uom cursor for return if SHALLOW or DEEP load
	l_retrieve_all_uom := fnd_profile.value_specific('IBE_RETRIEVE_ALL_ITEM_UOMS', NULL, NULL, 671);
	IF ((l_retrieve_all_uom IS NULL) OR (l_retrieve_all_uom = 'Y')) THEN
          IF ((p_load_level = G_ITEM_SHALLOW) OR (p_load_level = G_ITEM_DEEP)) THEN
	     OPEN x_uom_csr FOR
              SELECT miuv.INVENTORY_ITEM_ID, miuv.UOM_CODE
                FROM MTL_ITEM_UOMS_VIEW miuv
                WHERE miuv.INVENTORY_ITEM_ID = l_itmid
                AND miuv.ORGANIZATION_ID = p_organization_id
                ORDER BY miuv.UOM_CODE;
	  END IF;
	END IF;

       -- call configurator API
       l_resp_id := FND_PROFILE.value('RESP_ID');
       l_resp_appl_id := FND_PROFILE.value('RESP_APPL_ID');
       IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       	  IBE_UTIL.debug('Calling CZ_CF_API.UI_FOR_ITEM ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
       	  ibe_util.debug('item id=' || l_itmid);
       	  ibe_util.debug('organization id=' || p_organization_id);
       	  ibe_util.debug('responsibility id=' || l_resp_id);
       	  ibe_util.debug('application id=' || l_resp_appl_id);
       END IF;

       l_ui_def_id := CZ_CF_API.UI_FOR_ITEM (l_itmid, p_organization_id, SYSDATE,
   					     'DHTML', FND_API.G_MISS_NUM, l_resp_id, l_resp_appl_id);
       IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       	  IBE_UTIL.debug('Return from CZ_CF_API.UI_FOR_ITEM ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
       	  ibe_util.debug('ui_def_id=' || l_ui_def_id);
       END IF;
       IF l_ui_def_id IS NULL THEN
          x_configurable := FND_API.G_FALSE;
       ELSE
	  x_configurable := FND_API.G_TRUE;
       END IF;

       IF /*l_bom_item_type = 1 AND*/ x_configurable = FND_API.G_FALSE THEN
          x_model_bundle_flag := IBE_CCTBOM_PVT.Is_Model_Bundle(p_api_version =>1.0, p_model_id =>l_itmid, p_organization_id => p_organization_id);
       ELSE
          x_model_bundle_flag := FND_API.G_FALSE;
       END IF;

       l_end_time := DBMS_UTILITY.GET_TIME;
       IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       	  IBE_UTIL.debug('IBE_CATALOG_PVT.FETCH_ITEM(-), elapsed time (s) ='||(l_end_time-l_start_time)/100);
       END IF;
       --end API body

       -- standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );
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
	    THEN FND_MSG_PUB.Add_Exc_Msg
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
   END FETCH_ITEM;

Procedure FETCH_PRICE
		(p_itmid 			IN  NUMBER,
		 p_model_bundle_flag		IN  VARCHAR2,
		 p_model_id			IN  NUMBER    := FND_API.G_MISS_NUM,
		 p_organization_id		IN  NUMBER,
		 p_price_list_id		IN  NUMBER,
		 p_currency_code		IN  VARCHAR2,
		 p_price_request_type		IN  VARCHAR2,
		 p_price_event			IN  VARCHAR2,
	         p_minisite_id			IN  NUMBER := NULL,
		 x_price_csr			OUT NOCOPY IBE_PRICE_PVT.PRICE_REFCURSOR_TYPE,
	         x_line_index_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
     		 x_return_status      		OUT NOCOPY VARCHAR2,
     		 x_return_status_text  		OUT NOCOPY VARCHAR2
		)
IS

     l_api_name		CONSTANT VARCHAR2(30) 	:= 'FETCH_PRICE';
     l_api_version	CONSTANT NUMBER		:= 1.0;

     l_uom_code_tbl		QP_PREQ_GRP.VARCHAR_TYPE;
     l_itmid_tbl 		QP_PREQ_GRP.NUMBER_TYPE;
     l_model_id_tbl 		JTF_NUMBER_TABLE;
     l_model_id 		NUMBER;
     l_line_quantity_tbl 	QP_PREQ_GRP.NUMBER_TYPE;
     idx 			BINARY_INTEGER;
     l_parentIndex_tbl		QP_PREQ_GRP.NUMBER_TYPE;
     l_childIndex_tbl		QP_PREQ_GRP.NUMBER_TYPE;

     CURSOR l_item_uom_csr IS
     	SELECT miuv.INVENTORY_ITEM_ID, miuv.UOM_CODE
        FROM MTL_ITEM_UOMS_VIEW miuv
        WHERE miuv.INVENTORY_ITEM_ID = p_itmid
          AND miuv.ORGANIZATION_ID = p_organization_id
        ORDER BY miuv.UOM_CODE;

     CURSOR l_primary_uom_csr IS
	SELECT MSIV.primary_uom_code
	FROM mtl_system_items_vl MSIV
	WHERE MSIV.inventory_item_id = p_itmid;

     l_retrieve_all_uom		VARCHAR2(10);
     l_primary_uom		VARCHAR2(40);
     l_bom_item_csr IBE_CCTBOM_PVT.IBE_CCTBOM_REF_CSR_TYPE;
     l_bom_exp_rec IBE_CCTBOM_PVT.IBE_BOM_EXPLOSION_REC;
     l_msg_data VARCHAR2(100);
     l_msg_count NUMBER;
     l_return_status VARCHAR2(30);
     l_start_time		NUMBER;
     l_end_time			NUMBER;


  BEGIN
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug('IBE_CATALOG_PVT.FETCH_PRICE(+), item ='||p_itmid);
        END IF;
	l_start_time := DBMS_UTILITY.GET_TIME;

	--don't convert model_id=-1 here
	--IF p_model_id = -1 THEN
	    --l_model_id := FND_API.G_MISS_NUM;
	--ELSE
	l_model_id := p_model_id;
	--END IF;
  	l_model_id_tbl := JTF_NUMBER_TABLE();
       	idx := 1;
	l_retrieve_all_uom := fnd_profile.value_specific('IBE_RETRIEVE_ALL_ITEM_UOMS', NULL, NULL, 671);
  	IF p_model_bundle_flag = FND_API.G_TRUE OR l_retrieve_all_uom = 'N' THEN
	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    	IBE_UTIL.debug('pricing for primary uom only...');
	    END IF;
	    OPEN l_primary_uom_csr;
	    FETCH l_primary_uom_csr INTO l_primary_uom;
	    IF l_primary_uom_csr%FOUND THEN
	       l_uom_code_tbl(idx) := l_primary_uom;
	    ELSE
	       l_uom_code_tbl(idx) := FND_API.G_MISS_CHAR;
	       IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	       	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':no primary uom code found');
	       END IF;
	    END IF;
	    CLOSE l_primary_uom_csr;

	    l_itmid_tbl(idx) := p_itmid;
	    l_line_quantity_tbl(idx) := 1;
	    l_model_id_tbl.EXTEND;
	    l_model_id_tbl(idx) := l_model_id;
	    idx := idx + 1;
  	    IF p_model_bundle_flag = FND_API.G_TRUE THEN
	        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':loading component items...');
	        END IF;
	        IBE_CCTBOM_PVT.Load_Components(p_api_version =>1.0,
	       				x_return_status=>l_return_status,
	       				x_msg_data=>l_msg_data,
	       				x_msg_count =>l_msg_count,
	       				p_model_id =>p_itmid,
	       				p_organization_id =>p_organization_id,
	       				x_item_csr =>l_bom_item_csr);
		IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		   	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':adding component items..., idx='||idx);
		   END IF;
	           FETCH l_bom_item_csr INTO l_bom_exp_rec;
	           WHILE l_bom_item_csr%FOUND LOOP
	    	      l_itmid_tbl(idx) := l_bom_exp_rec.component_item_id;
	    	      l_uom_code_tbl(idx) := l_bom_exp_rec.primary_uom_code;
	    	      l_line_quantity_tbl(idx) := l_bom_exp_rec.component_quantity;
	      	      l_model_id_tbl.EXTEND;
	    	      l_model_id_tbl(idx) := p_itmid;
	    	      idx := idx + 1;
		      FETCH l_bom_item_csr INTO l_bom_exp_rec;
  	           END LOOP;
  	           CLOSE l_bom_item_csr;
		   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		   	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':component items added to request line, idx='||idx);
		   END IF;
  	        ELSE
		    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		    	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':Failed to load component items');
		    END IF;
	            RAISE FND_API.G_EXC_ERROR;
  	        END IF;
  	    END IF;
	ELSE
	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	    	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||': pricing for all uom codes...');
	    END IF;
	    FOR uom_rec IN l_item_uom_csr LOOP
	       l_uom_code_tbl(idx) := uom_rec.UOM_CODE;
	       l_itmid_tbl(idx) := uom_rec.INVENTORY_ITEM_ID;
	       l_line_quantity_tbl(idx) := 1;
	       l_model_id_tbl.extend;
	       l_model_id_tbl(idx) := l_model_id;
	       idx := idx + 1;
	    END LOOP;
	END IF;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('Calling IBE_PRICE_PVT.PRICE_REQUEST...');
	END IF;
        IBE_PRICE_PVT.PRICE_REQUEST(
        	p_price_list_id     => p_price_list_id,
           	p_currency_code     => p_currency_code,
           	p_item_tbl          => l_itmid_tbl,
           	p_uom_code_tbl      => l_uom_code_tbl,
           	p_model_id_tbl      => l_model_id_tbl,
           	p_line_quantity_tbl => l_line_quantity_tbl,
           	p_parentIndex_tbl   => l_parentIndex_tbl,
           	p_childIndex_tbl    => l_childIndex_tbl,
           	p_request_type_code => p_price_request_type,
                p_pricing_event     => p_price_event,
                p_minisite_id       => p_minisite_id,
                x_price_csr         => x_price_csr,
	        x_line_index_tbl    => x_line_index_tbl,
                x_return_status     => x_return_status,
                x_return_status_text=> x_return_status_text);

	l_end_time := DBMS_UTILITY.GET_TIME;
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug('Return from IBE_PRICE_PVT.PRICE_REQUEST');
        	IBE_UTIL.debug('IBE_CATALOG_PVT.FETCH_PRICE(-), elapsed time (s) ='||(l_end_time-l_start_time)/100);
        END IF;
        --end API body

EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
  	x_return_status_text :=SQLERRM;
END FETCH_PRICE;

Procedure LOAD_ITEM
		(p_api_version        		IN  NUMBER,
                 p_init_msg_list      		IN  VARCHAR2 := NULL,
                 p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     		 x_return_status      		OUT NOCOPY VARCHAR2,
                 x_msg_count          		OUT NOCOPY NUMBER,
                 x_msg_data           		OUT NOCOPY VARCHAR2,

		 p_load_level			IN  NUMBER,
		 p_preview_flag			IN  VARCHAR2,
		 p_itmid 			IN  NUMBER,
		 p_partnum			IN  VARCHAR2,
		 p_model_id			IN  NUMBER    := FND_API.G_MISS_NUM,
		 p_organization_id		IN  NUMBER,
		 p_category_set_id		IN  NUMBER,
		 p_retrieve_price		IN  VARCHAR2,

		 p_price_list_id		IN  NUMBER,
		 p_currency_code		IN  VARCHAR2,
		 p_price_request_type		IN  VARCHAR2,
		 p_price_event			IN  VARCHAR2,
	         p_minisite_id			IN  NUMBER := NULL,
		 x_item_csr			OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE,
		 x_category_id_csr		OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE,
		 x_configurable			OUT NOCOPY VARCHAR2,
		 x_model_bundle_flag		OUT NOCOPY VARCHAR2,
		 x_uom_csr			OUT NOCOPY IBE_CATALOG_REFCURSOR_CSR_TYPE,
		 x_price_csr			OUT NOCOPY IBE_PRICE_PVT.PRICE_REFCURSOR_TYPE,
	         x_line_index_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
	         x_price_status_code		OUT NOCOPY VARCHAR2,
		 x_price_status_text		OUT NOCOPY VARCHAR2

		)
IS

     l_api_name		CONSTANT VARCHAR2(30) 	:= 'LOAD_ITEM';
     l_api_version	CONSTANT NUMBER		:= 1.0;

     l_uom_code_tbl	JTF_VARCHAR2_TABLE_100;
     l_itmid_tbl 	JTF_NUMBER_TABLE;
     l_model_id_tbl 	JTF_NUMBER_TABLE;
     idx 		BINARY_INTEGER;
     l_start_time		NUMBER;
     l_end_time			NUMBER;
     l_init_msg_list 	VARCHAR2(5);

  BEGIN
     	-- standard call to check for call compatibility
     	IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
   	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	END IF;
	IF p_init_msg_list IS NULL THEN
		l_init_msg_list := FND_API.G_FALSE;
	END IF;

	-- initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.to_Boolean(p_init_msg_list) THEN
	   FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug('IBE_CATALOG_PVT.LOAD_ITEM(+)');
        END IF;
	l_start_time := DBMS_UTILITY.GET_TIME;
	-- load item inventory info
	FETCH_ITEM(
		 p_api_version,
                 p_init_msg_list,
                 p_validation_level,
     		 x_return_status,
                 x_msg_count,
                 x_msg_data,
		 p_load_level,
		 p_preview_flag,
		 p_itmid,
		 p_partnum,
		 p_model_id,
		 p_organization_id,
		 p_category_set_id,
		 x_item_csr,
		 x_category_id_csr,
		 x_configurable,
		 x_model_bundle_flag,
		 x_uom_csr
	);


       IF FND_API.to_Boolean(p_retrieve_price) THEN
          FETCH_PRICE(
                 p_itmid =>p_itmid,
                 p_model_bundle_flag => x_model_bundle_flag,
		 p_model_id =>p_model_id,
		 p_organization_id => p_organization_id,
		 p_price_list_id => p_price_list_id,
		 p_currency_code => p_currency_code,
		 p_price_request_type => p_price_request_type,
		 p_price_event => p_price_event,
		 p_minisite_id => p_minisite_id,
		 x_price_csr => x_price_csr,
	         x_line_index_tbl=> x_line_index_tbl,
     		 x_return_status => x_price_status_code,
     		 x_return_status_text => x_price_status_text);
       END IF;

       l_end_time := DBMS_UTILITY.GET_TIME;
       IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       	IBE_UTIL.debug('IBE_CATALOG_PVT.LOAD_ITEM(-), elapsed time (s) ='||(l_end_time-l_start_time)/100);
       END IF;
       --end API body

       -- standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );
EXCEPTION
   	  WHEN FND_API.G_EXC_ERROR THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );
   	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );
   	  WHEN OTHERS THEN
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     	    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     	    FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     	    FND_MESSAGE.Set_Token('REASON', SQLERRM);
     	    FND_MSG_PUB.Add;
	    IF	FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN FND_MSG_PUB.Add_Exc_Msg
			(	G_PKG_NAME,
				l_api_name
			);
	    END IF;
	    FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );
END LOAD_ITEM;



Procedure FETCH_ITEMS(
		 p_load_level			IN  NUMBER,
		 p_itmid_tbl 			IN  JTF_NUMBER_TABLE,
		 p_partnum_tbl			IN  JTF_VARCHAR2_TABLE_100,
		 p_organization_id		IN  NUMBER,
		 p_category_set_id		IN  NUMBER,
		 x_category_id_tbl		OUT NOCOPY JTF_NUMBER_TABLE,
		 x_configurable_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
		 x_model_bundle_flag_tbl	OUT NOCOPY JTF_VARCHAR2_TABLE_100,
     		 x_return_status      		OUT NOCOPY VARCHAR2,
     		 x_return_status_text      	OUT NOCOPY VARCHAR2
		)
IS
     l_api_name			CONSTANT VARCHAR2(30) 	:= 'FETCH_ITEMS';
     l_api_version		CONSTANT NUMBER		:= 1.0;
     l_ui_def_id		NUMBER;

     cursor l_itmid_csr(l_partnum VARCHAR2) IS
	select MSIV.inventory_item_id
 	from mtl_system_items_vl MSIV
	where MSIV.concatenated_segments = l_partnum;
  --added the below cursor for perf bug 20245594 fix
  cursor l_bom_item_type_csr(l_item_id NUMBER,l_organization_id NUMBER) IS
  select bom_item_type
  from MTL_SYSTEM_ITEMS_B MSIB
  where MSIB.inventory_item_id = l_item_id
  and   MSIB.organization_id = l_organization_id;

  l_bom_item_type NUMBER;

     cursor l_category_id_csr(l_itmid NUMBER,
     			      l_organization_id NUMBER,
     			      l_category_set_id NUMBER) IS
	select MIC.category_id
	FROM MTL_SYSTEM_ITEMS_B MSIB, MTL_ITEM_CATEGORIES MIC
	WHERE MSIB.inventory_item_id = l_itmid
	AND MSIB.organization_id = l_organization_id
	AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
	AND NVL(MSIB.end_date_active, SYSDATE) >= SYSDATE
	AND MSIB.inventory_item_id = MIC.inventory_item_id
	AND MSIB.organization_id = MIC.organization_id
	AND mic.CATEGORY_SET_ID = l_category_set_id;

     l_itmid			NUMBER;
     l_itmid_tbl		JTF_NUMBER_TABLE;
     l_table_index		NUMBER;
     l_partnum			VARCHAR2(40);
     l_category_id		NUMBER;
     l_resp_id			NUMBER;
     l_resp_appl_id		NUMBER;
     l_itmid_index		NUMBER;
     l_start_time		NUMBER;
     l_end_time			NUMBER;

BEGIN

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('IBE_CATALOG_PVT.FETCH_ITEMS(+)');
	END IF;
	l_start_time := DBMS_UTILITY.GET_TIME;

	-- get the select and from clauses of the query
	l_itmid_tbl := JTF_NUMBER_TABLE();

	IF p_itmid_tbl IS NULL THEN
   	   IF p_partnum_tbl IS NULL THEN
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('Error: p_itmid_tbl and p_partnum_tbl are both NULL');
		END IF;
		FND_MESSAGE.Set_Name('IBE', 'IBE_CT_INVALID_ID_OR_NAME');
		FND_MESSAGE.Set_Token('ID_NAME', 'NULL');
		FND_MSG_PUB.Add;
		RAISE FND_API.G_EXC_ERROR;
	      RETURN;
   	   ELSE
	      --loading by part number
	      l_itmid_index := 1;

	      FOR l_table_index IN 1..p_partnum_tbl.COUNT LOOP

		l_partnum := p_partnum_tbl(l_table_index);
		OPEN l_itmid_csr(l_partnum);
		FETCH l_itmid_csr INTO l_itmid;

		-- constuct item id tbl
		IF l_itmid_csr%FOUND THEN
		   l_itmid_tbl.EXTEND;
		   l_itmid_tbl(l_table_index) := l_itmid;

		ELSE
		   l_itmid_tbl.EXTEND;
		   l_itmid_tbl(l_table_index) := FND_API.G_MISS_NUM;
		END IF;
		CLOSE l_itmid_csr;

	      END LOOP;
   	  END IF;
	  --p_itmid_tbl := l_itmid_tbl;
	ELSE
	  -- loading by item_id
	  l_itmid_tbl := p_itmid_tbl;

	END IF;

	-- populate x_category_id_tbl
	x_category_id_tbl := NULL;
	IF (p_category_set_id IS NOT NULL) THEN
	   x_category_id_tbl := JTF_NUMBER_TABLE();
	   FOR j IN 1..l_itmid_tbl.COUNT LOOP
	      OPEN l_category_id_csr(l_itmid_tbl(j),
	                             p_organization_id,
	                             p_category_set_id);
	      FETCH l_category_id_csr INTO l_category_id;
	      x_category_id_tbl.extend;
	      IF l_category_id_csr%FOUND THEN
	         x_category_id_tbl(j) := l_category_id;
	      ELSE
	         x_category_id_tbl(j) := -1;
	      END IF;
	      CLOSE l_category_id_csr;
	   END LOOP;
	END IF;

	--gzhang 01/21/01, model bundle cache
	x_configurable_tbl := JTF_VARCHAR2_TABLE_100();
	x_model_bundle_flag_tbl := JTF_VARCHAR2_TABLE_100();
	IF (p_itmid_tbl IS NOT NULL) THEN
	   x_configurable_tbl.EXTEND(p_itmid_tbl.COUNT);
	   x_model_bundle_flag_tbl.EXTEND(p_itmid_tbl.COUNT);
	ELSE
	   x_configurable_tbl.EXTEND(p_partnum_tbl.COUNT);
	   x_model_bundle_flag_tbl.EXTEND(p_partnum_tbl.COUNT); -- bug fix#2234615
	END IF;

	l_resp_id := FND_PROFILE.value('RESP_ID');
	l_resp_appl_id := FND_PROFILE.value('RESP_APPL_ID');

	FOR l_table_index IN 1..x_configurable_tbl.COUNT LOOP
   --modified the below code for performance bug 20245594 fix

          OPEN l_bom_item_type_csr(l_itmid_tbl(l_table_index),p_organization_id);
         FETCH l_bom_item_type_csr INTO l_bom_item_type;
         CLOSE l_bom_item_type_csr;

         IF (l_bom_item_type = 1) THEN
          IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
          	IBE_UTIL.debug('20245594 Calling CZ_CF_API.UI_FOR_ITEM ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
          	ibe_util.debug('item id=' || l_itmid_tbl(l_table_index));
          	ibe_util.debug('organization id=' || p_organization_id);
          	ibe_util.debug('responsibility id=' || l_resp_id);
          	ibe_util.debug('application id=' || l_resp_appl_id);
          END IF;
	   l_ui_def_id := CZ_CF_API.UI_FOR_ITEM (l_itmid_tbl(l_table_index), p_organization_id,
					       SYSDATE, 'DHTML', FND_API.G_MISS_NUM,
					       l_resp_id, l_resp_appl_id);
           IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
           	IBE_UTIL.debug('Return from CZ_CF_API.UI_FOR_ITEM ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
           	ibe_util.debug('ui_def_id=' || l_ui_def_id);
           END IF;

        ELSE
       l_ui_def_id := NULL;
         IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
           	IBE_UTIL.debug('20245594*****Not Calling CZ_CF_API.UI_FOR_ITEM ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
             ibe_util.debug('ui_def_id=' || l_ui_def_id);
             END IF;
          END IF;
	   IF l_ui_def_id IS NULL THEN
	      x_configurable_tbl(l_table_index) := FND_API.G_FALSE;
	   ELSE
	      x_configurable_tbl(l_table_index) := FND_API.G_TRUE;
	   END IF;

	   IF x_configurable_tbl(l_table_index) = FND_API.G_FALSE THEN
	      x_model_bundle_flag_tbl(l_table_index) := IBE_CCTBOM_PVT.Is_Model_Bundle(p_api_version =>1.0, p_model_id =>l_itmid_tbl(l_table_index), p_organization_id => p_organization_id);
	   ELSE
	      x_model_bundle_flag_tbl(l_table_index) := FND_API.G_FALSE;
	   END IF;
	END LOOP;

	l_end_time := DBMS_UTILITY.GET_TIME;
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug('IBE_CATALOG_PVT.FETCH_ITEMS(-), elapsed time (s) ='||(l_end_time-l_start_time)/100);
        END IF;
        --end API body

       -- standard call to get message count and if count is 1, get message info.
EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
  	x_return_status_text :=SQLERRM;
END FETCH_ITEMS;

Procedure FETCH_PRICES(
		 p_itmid_tbl 			IN  JTF_NUMBER_TABLE,
		 p_model_bundle_flag_tbl	IN  JTF_VARCHAR2_TABLE_100,
		 p_model_id_tbl			IN  JTF_NUMBER_TABLE,
		 p_organization_id		IN  NUMBER,
		 p_price_list_id		IN  NUMBER,
		 p_currency_code		IN  VARCHAR2,
		 p_price_request_type		IN  VARCHAR2,
		 p_price_event			IN  VARCHAR2,
	         p_minisite_id			IN  NUMBER := NULL,
		 x_price_csr			OUT NOCOPY IBE_PRICE_PVT.PRICE_REFCURSOR_TYPE,
	         x_line_index_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
	 	 x_return_status		OUT NOCOPY VARCHAR2,
		 x_return_status_text		OUT NOCOPY VARCHAR2

		)
IS
     l_api_name			CONSTANT VARCHAR2(30) 	:= 'FETCH_PRICES';
     l_api_version		CONSTANT NUMBER		:= 1.0;

     l_itmid			NUMBER;
     l_primary_uom		VARCHAR2(40);
     l_itmid_tbl		QP_PREQ_GRP.NUMBER_TYPE;
     l_uom_code_tbl		QP_PREQ_GRP.VARCHAR_TYPE;
     l_model_id_tbl		JTF_NUMBER_TABLE;
     l_line_quantity_tbl       	QP_PREQ_GRP.NUMBER_TYPE;
     l_parentIndex_tbl		QP_PREQ_GRP.NUMBER_TYPE;
     l_childIndex_tbl		QP_PREQ_GRP.NUMBER_TYPE;
     l_table_index		NUMBER;
     idx 			BINARY_INTEGER;

     CURSOR l_primary_uom_csr(l_item_id NUMBER) IS
	SELECT MSIV.primary_uom_code
	FROM mtl_system_items_vl MSIV
	WHERE MSIV.inventory_item_id = l_item_id;

     CURSOR l_uom_csr(l_item_id NUMBER) IS
     	SELECT miuv.UOM_CODE
        FROM MTL_ITEM_UOMS_VIEW miuv
        WHERE miuv.INVENTORY_ITEM_ID = l_item_id
          AND miuv.ORGANIZATION_ID = p_organization_id
        ORDER BY miuv.UOM_CODE;

    l_bom_item_csr IBE_CCTBOM_PVT.IBE_CCTBOM_REF_CSR_TYPE;
    l_bom_exp_rec IBE_CCTBOM_PVT.IBE_BOM_EXPLOSION_REC;
    l_msg_data VARCHAR2(100);
    l_msg_count NUMBER;
    l_return_status VARCHAR2(30);

    l_retrieve_all_uom		VARCHAR2(10);
    l_start_time		NUMBER;
    l_end_time			NUMBER;

   BEGIN
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':BEGIN');
        END IF;
	l_start_time := DBMS_UTILITY.GET_TIME;
	l_retrieve_all_uom := fnd_profile.value_specific('IBE_RETRIEVE_ALL_ITEM_UOMS', NULL, NULL, 671);
	l_model_id_tbl := JTF_NUMBER_TABLE();
	idx := 1;
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':l_retrieve_all_uom='||l_retrieve_all_uom);
        END IF;
        FOR l_table_index IN 1..p_itmid_tbl.COUNT LOOP
      	    -- construct item id tbl, uomcode tbl to pass into pricing engine if retrieving price
	    l_itmid := p_itmid_tbl(l_table_index);
	    IF p_model_bundle_flag_tbl(l_table_index) = FND_API.G_TRUE OR l_retrieve_all_uom = 'N' THEN
	      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	      	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||': only pricing primary uom');
	      END IF;
	      OPEN l_primary_uom_csr(l_itmid);
	      FETCH l_primary_uom_csr INTO l_primary_uom;
	      IF l_primary_uom_csr%FOUND THEN
	        l_uom_code_tbl(idx) := l_primary_uom;
	      ELSE
	        l_uom_code_tbl(idx) := FND_API.G_MISS_CHAR;
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':item has no primary uom code, item='||l_itmid);
		END IF;
	      END IF;
	      CLOSE l_primary_uom_csr;
	      l_itmid_tbl(idx) := l_itmid;
	      l_line_quantity_tbl(idx) := 1;
	      l_model_id_tbl.EXTEND;
	      --don't covert model_id=-1 here
	      --IF p_model_id_tbl(l_table_index) <> -1 THEN
	      l_model_id_tbl(idx) := p_model_id_tbl(l_table_index);
	      --ELSE
	        --l_model_id_tbl(idx) := FND_API.G_MISS_NUM;
	      --END IF;
	      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	      	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||': item ='||l_itmid||', primary uom='||l_primary_uom);
	      END IF;
	      idx := idx + 1;

	      IF p_model_bundle_flag_tbl(l_table_index) = FND_API.G_TRUE THEN
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':loading component items...');
		END IF;
	        IBE_CCTBOM_PVT.Load_Components(p_api_version =>1.0,
	            x_return_status=>l_return_status,
	            x_msg_data=>l_msg_data,
	            x_msg_count =>l_msg_count,
	            p_model_id =>l_itmid,
	            p_organization_id =>p_organization_id,
	            x_item_csr =>l_bom_item_csr);
		IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
		    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		    	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':adding component items..., idx='||idx);
		    END IF;
	            FETCH l_bom_item_csr INTO l_bom_exp_rec;
	            WHILE l_bom_item_csr%FOUND LOOP
	    	        l_itmid_tbl(idx) := l_bom_exp_rec.component_item_id;
	    	        l_uom_code_tbl(idx) := l_bom_exp_rec.primary_uom_code;
	    	        l_line_quantity_tbl(idx) := l_bom_exp_rec.component_quantity;
	      		l_model_id_tbl.EXTEND;
	    	        l_model_id_tbl(idx) := l_itmid;
	    	        idx := idx + 1;
		        FETCH l_bom_item_csr INTO l_bom_exp_rec;
  	            END LOOP;
  	            CLOSE l_bom_item_csr;
		    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		    	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':component items added to request line, idx='||idx);
		    END IF;
  	        ELSE
		    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		    	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':failed to load component items');
		    END IF;
  	        END IF;
  	      END IF;
	    ELSE
	      FOR l_rec IN l_uom_csr(l_itmid) LOOP
	      l_uom_code_tbl(idx) := l_rec.uom_code;
	      l_itmid_tbl(idx) := l_itmid;
	      l_line_quantity_tbl(idx) := 1;
	      l_model_id_tbl.EXTEND;
	      --don't convert model_id=-1 here
	      --IF p_model_id_tbl(l_table_index) <> -1 THEN
	      l_model_id_tbl(idx) := p_model_id_tbl(l_table_index);
	      --ELSE
	        --l_model_id_tbl(idx) := FND_API.G_MISS_NUM;
	      --END IF;
	      --IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||': line '||idx||', item='||l_itmid_tbl(idx)||',uom='||l_uom_code_tbl(idx)||',model id='||l_model_id_tbl(idx));
	      idx := idx + 1;
	      END LOOP;
	    END IF;
	END LOOP;
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':uom codes loaded');
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':request pricing...');
        END IF;

	-- pricing

	IBE_PRICE_PVT.PRICE_REQUEST(
        	p_price_list_id     => p_price_list_id,
           	p_currency_code     => p_currency_code,
           	p_item_tbl          => l_itmid_tbl,
           	p_uom_code_tbl      => l_uom_code_tbl,
           	p_model_id_tbl      => l_model_id_tbl,
           	p_line_quantity_tbl => l_line_quantity_tbl,
           	p_parentIndex_tbl   => l_parentIndex_tbl,
           	p_childIndex_tbl    => l_childIndex_tbl,
           	p_request_type_code => p_price_request_type,
                p_pricing_event     => p_price_event,
		p_minisite_id       => p_minisite_id,
                x_price_csr         => x_price_csr,
	        x_line_index_tbl    => x_line_index_tbl,
                x_return_status     => x_return_status,
                x_return_status_text=> x_return_status_text);


	l_end_time := DBMS_UTILITY.GET_TIME;
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':pricing done');
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':END, elapsed time (s) ='||(l_end_time-l_start_time)/100);
        END IF;
        --end API body

EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
  	x_return_status_text :=SQLERRM;
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':'||SQLERRM);
        END IF;
END FETCH_PRICES;

Procedure LOAD_ITEMS
		(p_api_version        		IN  NUMBER,
                 p_init_msg_list      		IN  VARCHAR2 := NULL,
                 p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     		 x_return_status      		OUT NOCOPY VARCHAR2,
                 x_msg_count          		OUT NOCOPY NUMBER,
                 x_msg_data           		OUT NOCOPY VARCHAR2,

		 p_load_level			IN  NUMBER,
		 p_preview_flag			IN  VARCHAR2,
		 p_itmid_tbl 			IN  JTF_NUMBER_TABLE,
		 p_partnum_tbl			IN  JTF_VARCHAR2_TABLE_100,
		 p_model_id_tbl			IN  JTF_NUMBER_TABLE,
		 p_organization_id		IN  NUMBER,
		 p_category_set_id		IN  NUMBER,
		 p_retrieve_price		IN  VARCHAR2,
		 p_price_list_id		IN  NUMBER,
		 p_currency_code		IN  VARCHAR2,
		 p_price_request_type		IN  VARCHAR2,
		 p_price_event			IN  VARCHAR2,
	         p_minisite_id			IN  NUMBER := NULL,
		 x_category_id_tbl		OUT NOCOPY JTF_NUMBER_TABLE,
		 x_configurable_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
		 x_model_bundle_flag_tbl	OUT NOCOPY JTF_VARCHAR2_TABLE_100,
		 x_price_csr			OUT NOCOPY IBE_PRICE_PVT.PRICE_REFCURSOR_TYPE,
	         x_line_index_tbl		OUT NOCOPY JTF_VARCHAR2_TABLE_100,
	 	 x_price_status_code		OUT NOCOPY VARCHAR2,
		 x_price_status_text		OUT NOCOPY VARCHAR2

		) IS
     l_api_name			CONSTANT VARCHAR2(30) 	:= 'LOAD_ITEMS';
     l_api_version		CONSTANT NUMBER		:= 1.0;

     l_return_status_text 	VARCHAR2(300);
     l_start_time		NUMBER;
     l_end_time			NUMBER;
     l_init_msg_list 		VARCHAR2(5);
   BEGIN
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':BEGIN');
        END IF;
     	IF NOT FND_API.Compatible_API_Call (l_api_version,
				    	    p_api_version,
				    	    l_api_name,
				    	    G_PKG_NAME   )
     	THEN
   	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	END IF;
	IF p_init_msg_list IS NULL THEN
		l_init_msg_list := FND_API.G_FALSE;
	END IF;
	-- initialize message list if L_init_msg_list is set to TRUE
	IF FND_API.to_Boolean(l_init_msg_list) THEN
	   FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- load inv info
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||': Loading inventory info...');
	END IF;
	l_start_time := DBMS_UTILITY.GET_TIME;
	FETCH_ITEMS(p_load_level =>p_load_level,
		 p_itmid_tbl =>p_itmid_tbl,
		 p_partnum_tbl =>p_partnum_tbl,
		 p_organization_id =>p_organization_id,
		 p_category_set_id =>p_category_set_id,
		 x_category_id_tbl =>x_category_id_tbl,
		 x_configurable_tbl =>x_configurable_tbl,
		 x_model_bundle_flag_tbl =>x_model_bundle_flag_tbl,
     		 x_return_status =>x_return_status,
     		 x_return_status_text =>l_return_status_text);


	-- pricing
	IF FND_API.to_Boolean(p_retrieve_price) THEN
	   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	   	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||': Loading prices...');
	   END IF;
	   FETCH_PRICES(
                 p_itmid_tbl =>p_itmid_tbl,
                 p_model_bundle_flag_tbl => x_model_bundle_flag_tbl,
		 p_model_id_tbl =>p_model_id_tbl,
		 p_organization_id => p_organization_id,
		 p_price_list_id => p_price_list_id,
		 p_currency_code => p_currency_code,
		 p_price_request_type => p_price_request_type,
		 p_price_event => p_price_event,
		 p_minisite_id => p_minisite_id,
		 x_price_csr => x_price_csr,
	         x_line_index_tbl=> x_line_index_tbl,
     		 x_return_status => x_price_status_code,
     		 x_return_status_text => x_price_status_text);
	   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	   	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||': prices loaded');
	   END IF;
	END IF;
        --end API body

        -- standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,	p_count => x_msg_count,	p_data  => x_msg_data);
	l_end_time := DBMS_UTILITY.GET_TIME;
        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||':END, elapsed time (s) ='||(l_end_time-l_start_time)/100);
        END IF;

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
	    THEN FND_MSG_PUB.Add_Exc_Msg
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
   END LOAD_ITEMS;

   PROCEDURE GET_ITEM_TYPE
   (
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2 := NULL,
     p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     p_item_ids            IN  JTF_NUMBER_TABLE,
     p_organization_id     IN  NUMBER,
     x_item_type           OUT NOCOPY JTF_VARCHAR2_TABLE_100,
     x_return_status	   OUT NOCOPY VARCHAR2,
     x_msg_count  	   OUT NOCOPY NUMBER,
     x_msg_data   	   OUT NOCOPY VARCHAR2
   )
   IS
     l_api_name		   	CONSTANT VARCHAR2(30):= 'FETCH_ITEM';
     l_api_version	   	CONSTANT NUMBER	:= 1.0;
     l_status 			VARCHAR2(5);
     l_service_item_flag   	VARCHAR2(5);
     l_serviceable_product_flag VARCHAR2(5);
     l_configurable             VARCHAR2(5);
     l_model_bundle_flag   	VARCHAR2(5);
     x_query_string        	VARCHAR2(100);
     l_resp_id		   	NUMBER;
     l_resp_appl_id	   	NUMBER;
     l_ui_def_id           	NUMBER;
     l_start_time	   	NUMBER;
     l_end_time		   	NUMBER;
     l_table_index         	NUMBER := 1;
     l_temp_key            	CONSTANT VARCHAR2(20) := 'ITEMIDS_TYPECODE';
     l_init_msg_list 	        VARCHAR2(5);
     cursor l_itm_attr_csr(l_temp_key VARCHAR2, l_org_id NUMBER) IS
	select MSIV.SERVICE_ITEM_FLAG,MSIV.SERVICEABLE_PRODUCT_FLAG
 	from MTL_SYSTEM_ITEMS_VL MSIV
	where MSIV.INVENTORY_ITEM_ID IN (select NUM_VAL from IBE_TEMP_TABLE where key =
	l_temp_key ) and MSIV.ORGANIZATION_ID = l_org_id;

   BEGIN
     	IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	END IF;
	IF p_init_msg_list IS NULL THEN
		l_init_msg_list := FND_API.G_FALSE;
	END IF;
	-- initialize message list if p_init_msg_list is set to TRUE
	IF FND_API.to_Boolean(p_init_msg_list) THEN
	   FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
   	-- Populate the itemIds into a temporary table.
   	FOR  i in p_item_ids.FIRST .. p_item_ids.LAST
   	LOOP

    		IBE_UTIL.INSERT_INTO_TEMP_TABLE(p_item_ids(i), 'NUM',l_temp_key, x_query_string);
    	END LOOP;

	l_resp_id := FND_PROFILE.value('RESP_ID');
        l_resp_appl_id := FND_PROFILE.value('RESP_APPL_ID');

        x_item_type := JTF_VARCHAR2_TABLE_100();
        x_item_type.extend(p_item_ids.COUNT);

  	FOR l_table_index IN 1..p_item_ids.COUNT LOOP
	     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       	     	ibe_util.debug('Calling CZ_CF_API.UI_FOR_ITEM ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
             	ibe_util.debug('item id=' || p_item_ids(l_table_index));
             	ibe_util.debug('organization id=' || p_organization_id);
             	ibe_util.debug('responsibility id=' || l_resp_id);
             	ibe_util.debug('application id=' || l_resp_appl_id);
             END IF;
  	     l_ui_def_id := CZ_CF_API.UI_FOR_ITEM (p_item_ids(l_table_index), p_organization_id,
  					       SYSDATE, 'DHTML', FND_API.G_MISS_NUM,
  					       l_resp_id, l_resp_appl_id);
	     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       	     	ibe_util.debug('Return from CZ_CF_API.UI_FOR_ITEM ' ||
					TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
	     END IF;
	     IF l_ui_def_id IS NULL THEN
    		l_configurable := FND_API.G_FALSE;
	     ELSE
    		l_configurable := FND_API.G_TRUE;
	     END IF;

	     -- check if the item is a iStore bundle.
	     IF l_configurable = FND_API.G_FALSE THEN
    		l_model_bundle_flag := IBE_CCTBOM_PVT.Is_Model_Bundle(p_api_version =>1.0,
                        		p_model_id =>p_item_ids(l_table_index), p_organization_id => p_organization_id);
	     END IF;


	     IF (l_model_bundle_flag = FND_API.G_TRUE OR  l_configurable = FND_API.G_TRUE) THEN
		x_item_type(l_table_index) := IBE_CATALOG_PVT.G_ITEM_MODEL;
	     END IF;
	 END LOOP;

	 -- check if the item is a service/serviceable product.
	 l_table_index :=1;
	 OPEN l_itm_attr_csr(l_temp_key,p_organization_id);
          LOOP
    		FETCH l_itm_attr_csr INTO l_service_item_flag, l_serviceable_product_flag;
    		EXIT WHEN l_itm_attr_csr%NOTFOUND;
    		IF ( (  x_item_type(l_table_index) IS NULL ) AND
    			   ( l_service_item_flag = 'Y' )) THEN
    			x_item_type(l_table_index) := IBE_CATALOG_PVT.G_ITEM_SERVICE;
    		ELSIF ( ( x_item_type(l_table_index) IS NULL ) AND
    			   ( l_serviceable_product_flag = 'Y') ) THEN
    			x_item_type(l_table_index) := IBE_CATALOG_PVT.G_ITEM_SERVICEABLE;
    		ELSIF  ( x_item_type(l_table_index) IS NULL ) THEN
    			x_item_type(l_table_index) := IBE_CATALOG_PVT.G_ITEM_STANDARD;
    		END IF;
    	 	l_table_index := l_table_index + 1;
   	  END LOOP;
   	 l_status := IBE_UTIL.delete_from_temp_table(l_temp_key);
  	 CLOSE l_itm_attr_csr;
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
	    THEN FND_MSG_PUB.Add_Exc_Msg
			(	G_PKG_NAME,
				l_api_name
			);
	    END IF;
	    FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );

   END  GET_ITEM_TYPE;

   PROCEDURE IS_ITEM_IN_MINISITE
   (
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2 := NULL,
     p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     p_item_ids            IN  JTF_NUMBER_TABLE,
     p_minisite_id         IN  NUMBER,
     x_minisite_item_ids   OUT NOCOPY JTF_NUMBER_TABLE,
     x_return_status	   OUT NOCOPY VARCHAR2,
     x_msg_count  	   OUT NOCOPY NUMBER,
     x_msg_data   	   OUT NOCOPY VARCHAR2
   )
   IS
     l_api_name		   	CONSTANT VARCHAR2(30):= 'IS_ITEM_IN_MINISITE';
     l_api_version	   	CONSTANT NUMBER	:= 1.0;
     x_query_string        	VARCHAR2(100);
     l_temp_key            	CONSTANT VARCHAR2(20) := 'ITEMIDS_IN_MSITE';
     l_item_id                  NUMBER;
     l_item_index               NUMBER;
     l_status 			VARCHAR2(5);
     l_init_msg_list 	        VARCHAR2(5);
     cursor l_itms_msite_csr(l_temp_key VARCHAR2, l_minisite_id NUMBER) IS
	select b.inventory_item_id
	from ibe_dsp_msite_sct_items a, ibe_dsp_section_items b
	where   a.section_item_id = b.section_item_id
	and a.mini_site_id = l_minisite_id and b.inventory_item_id IN
		(select NUM_VAL from IBE_TEMP_TABLE where key =	l_temp_key );

   BEGIN

     	IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     	END IF;
	IF p_init_msg_list IS NULL THEN
		l_init_msg_list := FND_API.G_FALSE;
	END IF;
	-- initialize message list if l_init_msg_list is set to TRUE
	IF FND_API.to_Boolean(l_init_msg_list) THEN
	   FND_MSG_PUB.initialize;
	END IF;

	-- initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       	     ibe_util.debug('Calling IS_ITEM_IN_MINISITE ' );
       	END IF;

   	-- Populate the itemIds into a temporary table.
   	FOR  i in p_item_ids.FIRST .. p_item_ids.LAST
   	LOOP
    		IBE_UTIL.INSERT_INTO_TEMP_TABLE(p_item_ids(i), 'NUM',l_temp_key, x_query_string);
    	END LOOP;

        x_minisite_item_ids := JTF_NUMBER_TABLE();
        l_item_index :=1;

        OPEN l_itms_msite_csr(l_temp_key,p_minisite_id);
          LOOP
    		FETCH l_itms_msite_csr INTO l_item_id;
		EXIT WHEN l_itms_msite_csr%NOTFOUND;
		x_minisite_item_ids.extend();
		x_minisite_item_ids(l_item_index) := l_item_id;
		l_item_index := l_item_index + 1;
   	  END LOOP;
   	 l_status := IBE_UTIL.delete_from_temp_table(l_temp_key);
  	 CLOSE l_itms_msite_csr;
   EXCEPTION
   	  WHEN FND_API.G_EXC_ERROR THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );
   	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );
   	  WHEN OTHERS THEN
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     	    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     	    FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     	    FND_MESSAGE.Set_Token('REASON', SQLERRM);
     	    FND_MSG_PUB.Add;
	    IF	FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN FND_MSG_PUB.Add_Exc_Msg
			(	G_PKG_NAME,
				l_api_name
			);
	    END IF;
	    FND_MSG_PUB.Count_And_Get
		(	p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data
                );

   END IS_ITEM_IN_MINISITE;

   PROCEDURE IS_ITEM_CONFIGURABLE
   (
     p_item_id            IN  NUMBER,
     p_organization_id		IN  NUMBER,
     x_configurable		OUT NOCOPY VARCHAR2
   )
   IS
    	l_ui_def_id		NUMBER;
     	l_resp_id		NUMBER;
     	l_resp_appl_id		NUMBER;
   BEGIN
   	l_resp_id := FND_PROFILE.value('RESP_ID');
       	l_resp_appl_id := FND_PROFILE.value('RESP_APPL_ID');
       	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       	  IBE_UTIL.debug('Calling CZ_CF_API.UI_FOR_ITEM ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
       	  ibe_util.debug('item id=' || p_item_id);
       	  ibe_util.debug('organization id=' || p_organization_id);
       	  ibe_util.debug('responsibility id=' || l_resp_id);
       	  ibe_util.debug('application id=' || l_resp_appl_id);
        END IF;

    	l_ui_def_id := CZ_CF_API.UI_FOR_ITEM (p_item_id, p_organization_id, SYSDATE,
   					     'DHTML', FND_API.G_MISS_NUM, l_resp_id, l_resp_appl_id);
       	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       	  IBE_UTIL.debug('Return from CZ_CF_API.UI_FOR_ITEM ' || TO_CHAR(SYSDATE,'DD-MON-YYYY:HH24:MI:SS'));
       	  ibe_util.debug('ui_def_id=' || l_ui_def_id);
       	END IF;
       	IF l_ui_def_id IS NULL THEN
          x_configurable := FND_API.G_FALSE;
       	ELSE
	  x_configurable := FND_API.G_TRUE;
       	END IF;
   END IS_ITEM_CONFIGURABLE;

END IBE_CATALOG_PVT;

/
