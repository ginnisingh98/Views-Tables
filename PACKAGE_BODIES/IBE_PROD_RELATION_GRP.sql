--------------------------------------------------------
--  DDL for Package Body IBE_PROD_RELATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_PROD_RELATION_GRP" AS
/* $Header: IBEGCRLB.pls 120.0.12010000.2 2011/01/07 06:26:58 scnagara ship $ */
FUNCTION Is_Relationship_Valid(
   p_relation_type_code VARCHAR2) RETURN BOOLEAN
IS
   l_start_date DATE;
   l_end_date   DATE;
BEGIN
   SELECT start_date_active, end_date_active
   INTO l_start_date, l_end_date
   FROM FND_LOOKUPS
   WHERE lookup_type = 'IBE_RELATIONSHIP_TYPES'
     AND lookup_code = p_relation_type_code
     AND enabled_flag = 'Y';
   -- if relationship type code is inactive, return false
   IF NVL(l_start_date, SYSDATE) > SYSDATE
   OR NVL(l_end_date, SYSDATE) < SYSDATE THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN  -- Error: relationship type does not exist
      RETURN FALSE;
END Is_Relationship_Valid;
FUNCTION Get_Bind_Arg_Num(
   p_sql_stmt IN VARCHAR2) RETURN NUMBER
IS
   l_length  PLS_INTEGER;
   i         PLS_INTEGER := 0;
   l_arg_num PLS_INTEGER := 0;
BEGIN
   l_length := length(p_sql_stmt);
   WHILE i < l_length LOOP
      i := INSTR(p_sql_stmt, ':', i + 1, 1);
      IF i = 0 THEN
         EXIT;
      END IF;
      l_arg_num := l_arg_num + 1;
   END LOOP;
   RETURN l_arg_num;
END Get_Bind_Arg_Num;
FUNCTION Exists_In_MTL(
   p_relation_type_code IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
  IF p_relation_type_code = 'RELATED'             OR
     p_relation_type_code = 'SUBSTITUTE'          OR
     p_relation_type_code = 'CROSS_SELL'          OR
     p_relation_type_code = 'UP_SELL'             OR
     p_relation_type_code = 'SERVICE'             OR
     p_relation_type_code = 'PREREQUISITE'        OR
     p_relation_type_code = 'COLLATERAL'          OR
     p_relation_type_code = 'SUPERSEDED'          OR
     p_relation_type_code = 'COMPLIMENTARY'       OR
     p_relation_type_code = 'IMPACT'              OR
     p_relation_type_code = 'CONFLICT'            OR
     p_relation_type_code = 'MANDATORY_CHARGE'    OR
     p_relation_type_code = 'OPTIONAL_CHARGE'     OR
     p_relation_type_code = 'PROMOTIONAL_UPGRADE' THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;
END Exists_In_MTL;
FUNCTION isBelongToMinisite(p_item_id IN NUMBER, p_msite_id IN NUMBER) RETURN BOOLEAN
IS
rowsReturned NUMBER :=0;
BEGIN
    SELECT COUNT(B.SECTION_ITEM_ID) INTO rowsReturned FROM IBE_DSP_SECTION_ITEMS s, IBE_DSP_MSITE_SCT_ITEMS b
    WHERE S.SECTION_ITEM_ID = B.SECTION_ITEM_ID AND B.MINI_SITE_ID = p_msite_id
    AND S.INVENTORY_ITEM_ID = p_item_id
    AND NVL(S.START_DATE_ACTIVE,SYSDATE) <= SYSDATE
    AND NVL(S.END_DATE_ACTIVE,SYSDATE) >= SYSDATE;
    IF rowsReturned > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END isBelongToMinisite;
-- Start of comments
--    API name   : Get_Related_Items
--    Type       : Public or Group or Private.
--    Function   : If p_preview_flag = 'T' returns items whose
--                 web_status is 'PUBLISHED' or 'UNPUBLISHED'.
--                 Otherwise, only returns items whose web_status
--                 is 'PUBLISHED'.
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        IN  NUMBER   Required
--                 p_init_msg_list      IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--                 p_msite_id           IN  NUMBER
--                 p_preview_flag       IN  VARCHAR2
--                 p_item_id            IN  NUMBER
--                 p_rel_type_code      IN  VARCHAR2
--                 p_max_ret_num        IN  NUMBER
--                     Default = NULL  (Return all)
--                 p_order_by_col       IN  VARCHAR2
--                     Default = NULL  (No order)
--                 p_order_by_order     IN  VARCHAR2
--                     Default = G_ASCEND_ORDER  (Ascending order)
--                 p_include_self_ref   IN  VARCHAR2
--                     Default = FND_API.G_FALSE (Don't include self-referrals)
--                 p_bind_varN          IN  VARCHAR2
--                     Default = NULL  (Bind variables for relationship rule defined by manual SQL)
--    OUT        : x_return_status      OUT VARCHAR2(1)
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2(2000)
--                 x_items_tbl          OUT JTF_Number_Table
--    Version    : Current version  1.0
--
--                 previous version None
--
--                 Initial version  1.0
--
--    Notes      : Note text
--
-- End of comments
PROCEDURE Get_Related_Items
(
   p_api_version      IN         NUMBER                      ,
   p_init_msg_list    IN         VARCHAR2  := NULL           ,
   x_return_status    OUT NOCOPY VARCHAR2                    ,
   x_msg_count        OUT NOCOPY NUMBER                      ,
   x_msg_data         OUT NOCOPY VARCHAR2                    ,
   p_msite_id         IN         NUMBER                      ,
   p_preview_flag     IN         VARCHAR2  := NULL           ,
   p_item_id          IN         NUMBER                      ,
   p_rel_type_code    IN         VARCHAR2                    ,
   p_org_id           IN         NUMBER                      ,
   p_max_ret_num      IN         NUMBER    := NULL           ,
   p_order_by_clause  IN         VARCHAR2  := NULL           ,
   p_include_self_ref IN         VARCHAR2  := NULL           ,
   p_rule_type        IN         VARCHAR2  := NULL           ,
   p_bind_arg1        IN         VARCHAR2  := NULL           ,
   p_bind_arg2        IN         VARCHAR2  := NULL           ,
   p_bind_arg3        IN         VARCHAR2  := NULL           ,
   p_bind_arg4        IN         VARCHAR2  := NULL           ,
   p_bind_arg5        IN         VARCHAR2  := NULL           ,
   p_bind_arg6        IN         VARCHAR2  := NULL           ,
   p_bind_arg7        IN         VARCHAR2  := NULL           ,
   p_bind_arg8        IN         VARCHAR2  := NULL           ,
   p_bind_arg9        IN         VARCHAR2  := NULL           ,
   p_bind_arg10       IN         VARCHAR2  := NULL           ,
   x_items_tbl        OUT NOCOPY JTF_Number_Table
)
IS
   TYPE rel_items_csr_type IS REF CURSOR;
   l_api_name      CONSTANT VARCHAR2(30)   := 'Get_Related_Items';
   l_api_version   CONSTANT NUMBER         := 1.0;
   l_stmt          VARCHAR2(2000);
   l_rel_items_csr rel_items_csr_type;
   l_rel_item_id   NUMBER;
   l_sql_stmt      VARCHAR2(2000);
   l_bind_arg_num  PLS_INTEGER;
   l_dummy         VARCHAR2(30);
   i               PLS_INTEGER        := 1;
   include_mtl     BOOLEAN;
   l_items_tbl     JTF_Number_Table;
   l_debug VARCHAR2(1);
   l_init_msg_list VARCHAR2(5);
   l_preview_flag  VARCHAR2(5);
   l_include_self_ref  VARCHAR2(5);
   l_rule_type  VARCHAR2(10);

BEGIN
   l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_init_msg_list IS NULL THEN
   	l_init_msg_list := FND_API.G_FALSE;
   END IF;

   IF p_preview_flag IS NULL THEN
   	l_preview_flag := FND_API.G_FALSE;
   END IF;

   IF p_include_self_ref IS NULL THEN
   	l_include_self_ref := FND_API.G_FALSE;
   END IF;

   IF p_rule_type IS NULL THEN
   	l_rule_type := 'MAPPING';
   END IF;

   -- Initialize message list if l_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( l_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --  Initialize the return value table
   x_items_tbl := JTF_Number_Table();
   l_items_tbl.extend();
   l_items_tbl(1) := p_item_id;
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_GRP.Get_Related_Items(+)');
      IBE_UTIL.debug('p_org_id : p_item_id : p_rel_type_code : l_rule_type = '
                  || p_org_id || ' : ' || p_item_id || ' : '
                  || p_rel_type_code || ' : ' || l_rule_type);
   END IF;

   Get_Related_Items(p_api_version,l_init_msg_list,x_return_status,x_msg_count,
                     x_msg_data,p_msite_id,l_preview_flag, l_items_tbl, p_rel_type_code,
                     p_org_id, p_max_ret_num, p_order_by_clause, l_include_self_ref,
                     l_rule_type,p_bind_arg1, p_bind_arg2, p_bind_arg3, p_bind_arg4,
                     p_bind_arg5, p_bind_arg6, p_bind_arg7, p_bind_arg8, p_bind_arg9,
                     p_bind_arg10, x_items_tbl);

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_GRP.Get_Related_Items(-)');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Get_Related_Items;
-- Start of comments
--    API name   : Get_Related_Items
--    Type       : Public or Group or Private.
--    Function   :
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        IN  NUMBER   Required
--                 p_init_msg_list      IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--                 p_item_id            IN  NUMBER
--                 p_rel_type_code      IN  VARCHAR2
--                 p_max_ret_num        IN  NUMBER
--                     Default = NULL  (Return all)
--                 p_order_by_clause    IN  VARCHAR2
--                     Default = NULL  (No order)
--                 l_include_self_ref   IN  VARCHAR2
--                     Default = FND_API.G_FALSE (Don't include self-referrals)
--                 p_bind_argN          IN  VARCHAR2
--                     Default = NULL  (Bind arguments for relationship rule defined by manual SQL)
--    OUT        : x_return_status      OUT VARCHAR2(1)
--                 x_msg_count          OUT NUMBER
--                 x_msg_data           OUT VARCHAR2(2000)
--                 x_items_tbl          OUT JTF_Number_Table
--    Version    : Current version  1.0
--
--                 previous version None
--
--                 Initial version  1.0
--
--    Notes      : Note text
--
-- End of comments
PROCEDURE Get_Related_Items(
   p_api_version      IN         NUMBER                      ,
   p_init_msg_list    IN         VARCHAR2  := NULL           ,
   x_return_status    OUT NOCOPY VARCHAR2                    ,
   x_msg_count        OUT NOCOPY NUMBER                      ,
   x_msg_data         OUT NOCOPY VARCHAR2                    ,
   p_item_id          IN         NUMBER                      ,
   p_rel_type_code    IN         VARCHAR2                    ,
   p_org_id           IN         NUMBER                      ,
   p_max_ret_num      IN         NUMBER    := NULL           ,
   p_order_by_clause  IN         VARCHAR2  := NULL           ,
   p_include_self_ref IN         VARCHAR2  := NULL           ,
   p_rule_type        IN         VARCHAR2  := NULL           ,
   p_bind_arg1        IN         VARCHAR2  := NULL           ,
   p_bind_arg2        IN         VARCHAR2  := NULL           ,
   p_bind_arg3        IN         VARCHAR2  := NULL           ,
   p_bind_arg4        IN         VARCHAR2  := NULL           ,
   p_bind_arg5        IN         VARCHAR2  := NULL           ,
   p_bind_arg6        IN         VARCHAR2  := NULL           ,
   p_bind_arg7        IN         VARCHAR2  := NULL           ,
   p_bind_arg8        IN         VARCHAR2  := NULL           ,
   p_bind_arg9        IN         VARCHAR2  := NULL           ,
   p_bind_arg10       IN         VARCHAR2  := NULL           ,
   x_items_tbl        OUT NOCOPY JTF_Number_Table
)
IS
   TYPE rel_items_csr_type IS REF CURSOR;
   l_api_name      CONSTANT VARCHAR2(30)   := 'Get_Related_Items';
   l_api_version   CONSTANT NUMBER         := 1.0;
   l_without_mtl_stmt CONSTANT VARCHAR2(2000) :=
'SELECT DISTINCT ICRI.related_item_id
 FROM ibe_ct_related_items ICRI,
      mtl_system_items_b   MSIB
 WHERE ICRI.relation_type_code = :rel_type_code1
   AND ICRI.inventory_item_id  = :item_id2
   AND NOT EXISTS( SELECT NULL
                   FROM ibe_ct_rel_exclusions ICRE
                   WHERE ICRE.relation_type_code = ICRI.relation_type_code
                     AND ICRE.inventory_item_id  = ICRI.inventory_item_id
/*Bug 2922902*/  AND ICRE.organization_id    = ICRI.organization_id
                     AND ICRE.related_item_id    = ICRI.related_item_id )
   AND MSIB.organization_id   = :org_id3
   AND MSIB.organization_id   = ICRI.organization_id --Bug 2922902
   AND MSIB.inventory_item_id = ICRI.related_item_id
   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
   AND MSIB.web_status        = ''PUBLISHED'' ';
   l_with_mtl_stmt1 CONSTANT VARCHAR2(2000) :=
'SELECT DISTINCT ICRI.related_item_id
 FROM ibe_ct_related_items ICRI,
      mtl_system_items_b   MSIB
 WHERE ICRI.relation_type_code = :rel_type_code1
   AND ICRI.inventory_item_id  = :item_id2
   AND MSIB.organization_id    = :org_id3
   AND MSIB.organization_id    = ICRI.organization_id --Bug 2922902
   AND MSIB.inventory_item_id  = ICRI.related_item_id
   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
   AND MSIB.web_status         = ''PUBLISHED'' ';
   l_with_mtl_stmt2 CONSTANT VARCHAR2(2500) :=
'UNION ALL
 SELECT MRI.related_item_id
 FROM mtl_related_items  MRI,
      mtl_system_items_b MSIB
 WHERE MRI.relationship_type_id = DECODE(:rel_type_code5, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                                  3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                                  7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                                  11, ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
   AND MRI.inventory_item_id    = :item_id6
   AND MSIB.organization_id     = :org_id7
   AND MSIB.organization_id     = MRI.organization_id --Bug 2922902
   AND MSIB.inventory_item_id   = MRI.related_item_id
   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
   AND MSIB.web_status          = ''PUBLISHED'' ';
   l_with_mtl_stmt3 CONSTANT VARCHAR2(2500) :=
'UNION ALL
 SELECT MRI.inventory_item_id
 FROM mtl_related_items MRI,
      mtl_system_items_b MSIB
 WHERE MRI.relationship_type_id = DECODE(:rel_type_code9, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                                  3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                                  7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                                  11, ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
   AND MRI.related_item_id      = :item_id10
   AND MSIB.organization_id     = :org_id11
   AND MSIB.organization_id     = MRI.organization_id  --Bug 2922902
   AND MSIB.inventory_item_id   = MRI.inventory_item_id
   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
   AND MSIB.web_status          = ''PUBLISHED''
   AND MRI.reciprocal_flag      = ''Y'' ';
   l_with_mtl_stmt4 CONSTANT VARCHAR2(2000) :=
'MINUS
 SELECT ICRE.related_item_id
 FROM ibe_ct_rel_exclusions ICRE
 WHERE ICRE.relation_type_code = :rel_type_code13
   AND ICRE.inventory_item_id  = :item_id14
   AND ICRE.organization_id    = :org_id15 ';  --Bug 2922902
   l_without_mtl_bulk_stmt CONSTANT VARCHAR2(2000) :=
'BEGIN
    SELECT DISTINCT ICRI.related_item_id
    BULK COLLECT INTO :items_tbl1
    FROM ibe_ct_related_items ICRI,
         mtl_system_items_b   MSIB
    WHERE ICRI.relation_type_code = :rel_type_code2
      AND ICRI.inventory_item_id  = :item_id3
      AND NOT EXISTS( SELECT NULL
                      FROM ibe_ct_rel_exclusions ICRE
                      WHERE ICRE.relation_type_code = ICRI.relation_type_code
                        AND ICRE.inventory_item_id  = ICRI.inventory_item_id
/*Bug 2922902*/     AND ICRE.organization_id    = ICRI.organization_id
                        AND ICRE.related_item_id    = ICRI.related_item_id )
      AND MSIB.organization_id   = :org_id4
   AND MSIB.organization_id = ICRI.organization_id --Bug 2922902
      AND MSIB.inventory_item_id = ICRI.related_item_id
      AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
      AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
      AND MSIB.web_status        = ''PUBLISHED'' ';
   l_stmt          VARCHAR2(2000);
   l_rel_items_csr rel_items_csr_type;
   l_rel_item_id   NUMBER;
   l_sql_stmt      VARCHAR2(2000);
   l_bind_arg_num  PLS_INTEGER;
   l_dummy         VARCHAR2(30);
   i               PLS_INTEGER        := 1;
   include_mtl     BOOLEAN;
   l_debug VARCHAR2(1);
   l_init_msg_list VARCHAR2(5);
   l_include_self_ref  VARCHAR2(5);
   l_rule_type  VARCHAR2(10);

BEGIN
        l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_init_msg_list IS NULL THEN
   	l_init_msg_list := FND_API.G_FALSE;
   END IF;

   IF p_include_self_ref IS NULL THEN
   	l_include_self_ref := FND_API.G_FALSE;
   END IF;

   IF p_rule_type IS NULL THEN
   	l_rule_type := 'MAPPING';
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --  Initialize the return value table
   x_items_tbl := JTF_Number_Table();
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_GRP.Get_Related_Items(+)');
      IBE_UTIL.debug('p_org_id : p_item_id : p_rel_type_code : l_rule_type = '
                  || p_org_id || ' : ' || p_item_id || ' : '
                  || p_rel_type_code || ' : ' || l_rule_type);
   END IF;
   -- API body
   -- 1. Check if the relationship exists and is active
   IF NOT Is_Relationship_Valid(p_rel_type_code) THEN
      IF (l_debug = 'Y') THEN
         IBE_UTIL.debug('Relationship is not valid.');
      END IF;
      FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_VALID');
      FND_MESSAGE.Set_Token('RELATIONSHIP', p_rel_type_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF l_rule_type = 'SQL' THEN
      -- 2. Get the related items using the manual SQL.
      BEGIN  -- begin sub-block to handle the SELECT statement's exception
         SELECT ICRR.sql_statement
         INTO l_sql_stmt
         FROM ibe_ct_relation_rules ICRR
         WHERE ICRR.relation_type_code = p_rel_type_code
           AND ICRR.origin_object_type = 'N'
           AND ICRR.dest_object_type = 'N';
         l_bind_arg_num := Get_Bind_Arg_Num( l_sql_stmt );
         IF l_bind_arg_num = 0 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt;
         ELSIF l_bind_arg_num = 1 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1;
         ELSIF l_bind_arg_num = 2 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2;
         ELSIF l_bind_arg_num = 3 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3;
         ELSIF l_bind_arg_num = 4 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4;
         ELSIF l_bind_arg_num = 5 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5;
         ELSIF l_bind_arg_num = 6 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5, p_bind_arg6;
         ELSIF l_bind_arg_num = 7 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5, p_bind_arg6,
                                       p_bind_arg7;
         ELSIF l_bind_arg_num = 8 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5, p_bind_arg6,
                                       p_bind_arg7, p_bind_arg8;
         ELSIF l_bind_arg_num = 9 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5, p_bind_arg6,
                                       p_bind_arg7, p_bind_arg8, p_bind_arg9;
         ELSIF l_bind_arg_num = 10 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5, p_bind_arg6,
                                       p_bind_arg7, p_bind_arg8, p_bind_arg9,
                                       p_bind_arg10;
         END IF;
/*
-- BULK FETCH does not work in 8.1.6.  When supported in 8.2,
-- we should enable for performance; replace the next IF block
-- the following.
         IF p_max_ret_num IS NULL THEN
            FETCH l_rel_items_csr BULK COLLECT INTO x_items_tbl;
         ELSE
            LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               x_items_tbl.EXTEND;
               x_items_tbl(i) := l_rel_item_id;
               i := i + 1;
               IF i > p_max_ret_num THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
*/
         IF p_max_ret_num IS NULL THEN
            LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               x_items_tbl.EXTEND;
               x_items_tbl(i) := l_rel_item_id;
               i := i + 1;
            END LOOP;
         ELSE
            LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               x_items_tbl.EXTEND;
               x_items_tbl(i) := l_rel_item_id;
               i := i + 1;
               IF i > p_max_ret_num THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         CLOSE l_rel_items_csr;
         RETURN;
      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 'Y') THEN
               IBE_UTIL.debug('SQL execution caused an error.');
            END IF;
            FND_MESSAGE.Set_Name('IBE', 'IBE_CT_SQL_RULE_ERROR');
            FND_MESSAGE.Set_Token('RELATIONSHIP', p_rel_type_code);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
      END;  -- end sub-block to handle the SELECT statement's exception
   ELSE -- l_rule_type = 'MAPPING'
      -- 3. Get the related items from ibe_ct_related_items table
      include_mtl := Exists_In_MTL(p_rel_type_code);
      IF (p_max_ret_num IS NULL) AND (NOT include_mtl) THEN -- Can use bulk fetching
         IF FND_API.to_Boolean( l_include_self_ref ) THEN -- include self referral
            IF (l_debug = 'Y') THEN
               IBE_UTIL.debug('Mapping rule: p_max_ret_num is NULL: relationship NOT in MTL: l_include_self_ref is TRUE.');
            END IF;
            EXECUTE IMMEDIATE l_without_mtl_bulk_stmt ||
                              '; END;'
            USING OUT x_items_tbl, p_rel_type_code, p_item_id, p_org_id;
         ELSE -- exclude self referral
            IF (l_debug = 'Y') THEN
               IBE_UTIL.debug('Mapping rule: p_max_ret_num is NULL: relationship NOT in MTL: l_include_self_ref is FALSE.');
            END IF;
            EXECUTE IMMEDIATE l_without_mtl_bulk_stmt ||
                              ' AND ICRI.related_item_id <> :item_id5 ' ||
                              '; END;'
            USING OUT x_items_tbl, p_rel_type_code, p_item_id, p_org_id, p_item_id;
         END IF;
      ELSE -- Cannot use bulk fetching
         IF include_mtl THEN -- must do union with mtl_related_items
            IF FND_API.to_Boolean( l_include_self_ref ) THEN -- include self referral
               IF (l_debug = 'Y') THEN
                  IBE_UTIL.debug('Mapping rule: relationship in MTL: l_include_self_ref is TRUE.');
               END IF;
               OPEN l_rel_items_csr FOR l_with_mtl_stmt1 ||
                                        l_with_mtl_stmt2 ||
                                        l_with_mtl_stmt3 ||
                                        l_with_mtl_stmt4
               USING p_rel_type_code, p_item_id, p_org_id,
                     p_rel_type_code, p_item_id, p_org_id,
                     p_rel_type_code, p_item_id, p_org_id,
                     p_rel_type_code, p_item_id, p_org_id; --Bug 2922902
            ELSE -- exclude self referral
               IF (l_debug = 'Y') THEN
                  IBE_UTIL.debug('Mapping rule: relationship in MTL: l_include_self_ref is FALSE.');
               END IF;
               OPEN l_rel_items_csr FOR l_with_mtl_stmt1 ||
                                        ' AND ICRI.related_item_id <> :item_id4 ' ||
                                        l_with_mtl_stmt2 ||
                                        ' AND MRI.related_item_id <> :item_id8 ' ||
                                        l_with_mtl_stmt3 ||
                                        ' AND MRI.inventory_item_id <> :item_id12 ' ||
                                        l_with_mtl_stmt4
               USING p_rel_type_code, p_item_id, p_org_id, p_item_id,
                     p_rel_type_code, p_item_id, p_org_id, p_item_id,
                     p_rel_type_code, p_item_id, p_org_id, p_item_id,
                     p_rel_type_code, p_item_id, p_org_id; --Bug 2922902
            END IF;
         ELSE -- don't need to do union with mtl_related_items
            IF FND_API.to_Boolean( l_include_self_ref ) THEN -- include self referral
               IF (l_debug = 'Y') THEN
                  IBE_UTIL.debug('Mapping rule: p_max_ret_num is NOT NULL: relationship NOT in MTL: l_include_self_ref is TRUE.');
               END IF;
               OPEN l_rel_items_csr FOR l_without_mtl_stmt
               USING p_rel_type_code, p_item_id, p_org_id;
            ELSE -- exclude self referral
               IF (l_debug = 'Y') THEN
                  IBE_UTIL.debug('Mapping rule: p_max_ret_num is NOT NULL: relationship NOT in MTL: l_include_self_ref is FALSE.');
               END IF;
               OPEN l_rel_items_csr FOR l_without_mtl_stmt ||
                                        ' AND ICRI.related_item_id <> :item_id4 '
               USING p_org_id, p_rel_type_code, p_item_id, p_item_id;
            END IF;
         END IF;
         IF p_max_ret_num IS NULL THEN
            LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               x_items_tbl.EXTEND;
               x_items_tbl(i) := l_rel_item_id;
               i := i + 1;
            END LOOP;
         ELSE
            LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               x_items_tbl.EXTEND;
               x_items_tbl(i) := l_rel_item_id;
               i := i + 1;
               IF i > p_max_ret_num THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         CLOSE l_rel_items_csr;
      END IF;
   END IF;
   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_GRP.Get_Related_Items(-)');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Get_Related_Items;
PROCEDURE Get_Related_Items
(
   p_api_version      IN         NUMBER                      ,
   p_init_msg_list    IN         VARCHAR2  := NULL           ,
   x_return_status    OUT NOCOPY VARCHAR2                    ,
   x_msg_count        OUT NOCOPY NUMBER                      ,
   x_msg_data         OUT NOCOPY VARCHAR2                    ,
   p_msite_id         IN         NUMBER                      ,
   p_preview_flag     IN         VARCHAR2  := NULL           ,
   p_item_ids         IN         JTF_Number_Table            ,
   p_rel_type_code    IN         VARCHAR2                    ,
   p_org_id           IN         NUMBER                      ,
   p_max_ret_num      IN         NUMBER    := NULL           ,
   p_order_by_clause  IN         VARCHAR2  := NULL           ,
   p_include_self_ref IN         VARCHAR2  := NULL           ,
   p_rule_type        IN         VARCHAR2  := NULL           ,
   p_bind_arg1        IN         VARCHAR2  := NULL           ,
   p_bind_arg2        IN         VARCHAR2  := NULL           ,
   p_bind_arg3        IN         VARCHAR2  := NULL           ,
   p_bind_arg4        IN         VARCHAR2  := NULL           ,
   p_bind_arg5        IN         VARCHAR2  := NULL           ,
   p_bind_arg6        IN         VARCHAR2  := NULL           ,
   p_bind_arg7        IN         VARCHAR2  := NULL           ,
   p_bind_arg8        IN         VARCHAR2  := NULL           ,
   p_bind_arg9        IN         VARCHAR2  := NULL           ,
   p_bind_arg10       IN         VARCHAR2  := NULL           ,
   x_items_tbl        OUT NOCOPY JTF_Number_Table
)
IS
   TYPE rel_items_csr_type IS REF CURSOR;
   l_api_name      CONSTANT VARCHAR2(30)   := 'Get_Related_Items';
   l_api_version   CONSTANT NUMBER         := 1.0;
   l_status VARCHAR2(5);
   l_temp VARCHAR(20000);
   l_temp_itemids_query CONSTANT VARCHAR2(200)      := ' IN (select NUM_VAL from IBE_TEMP_TABLE where key =  :l_temp_key)';
   l_minisite_stmt CONSTANT VARCHAR2(2000)          :=' AND EXISTS (SELECT 1 FROM IBE_DSP_SECTION_ITEMS s, IBE_DSP_MSITE_SCT_ITEMS b
                                               WHERE S.SECTION_ITEM_ID = B.SECTION_ITEM_ID
                                               AND B.MINI_SITE_ID = :msite_id
                                               AND S.INVENTORY_ITEM_ID = ICRI.related_item_id
                                               AND NVL(S.START_DATE_ACTIVE,SYSDATE) <= SYSDATE
                                               AND NVL(S.END_DATE_ACTIVE,SYSDATE) >= SYSDATE )';
   l_wout_mtl_mult_stmt CONSTANT VARCHAR2(2000)     :=
                                              ' SELECT DISTINCT ICRI.related_item_id FROM ibe_ct_related_items ICRI, mtl_system_items_b   MSIB
                                               WHERE ICRI.relation_type_code = :rel_type_code1
                                               AND ICRI.inventory_item_id  IN
                                               ( select NUM_VAL from IBE_TEMP_TABLE where key =  :l_temp_key)
                                               AND NOT EXISTS( SELECT NULL
                                               FROM ibe_ct_rel_exclusions ICRE
                                               WHERE ICRE.relation_type_code = ICRI.relation_type_code
                                               AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                                               /*Bug 2922902 */
                                               AND ICRE.organization_id    = ICRI.organization_id
                                               AND ICRE.related_item_id    = ICRI.related_item_id )
                                               AND MSIB.organization_id   = :org_id3
                                               AND MSIB.organization_id = ICRI.organization_id --Bug 2922902
                                               AND MSIB.inventory_item_id = ICRI.related_item_id
                                               AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                               AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                               AND MSIB.web_status        = ''PUBLISHED'' ';
   l_with_mtl_mult_stmt1 CONSTANT VARCHAR2(2000) :=
                                    'SELECT DISTINCT ICRI.related_item_id  FROM ibe_ct_related_items ICRI,
                                     mtl_system_items_b   MSIB
                                     WHERE ICRI.relation_type_code = :rel_type_code1
                                     AND ICRI.inventory_item_id
                                     IN ( select NUM_VAL from IBE_TEMP_TABLE where key =  :l_temp_key)
                                     AND MSIB.organization_id    = :org_id3
                                     AND MSIB.organization_id = ICRI.organization_id --Bug 2922902
                                     AND MSIB.inventory_item_id  = ICRI.related_item_id
                                     AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                     AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                     AND MSIB.web_status         = ''PUBLISHED'' ';


   l_with_mtl_mult_stmt2 CONSTANT VARCHAR2(2500) :=
                                 'UNION ALL
                                 SELECT MRI.related_item_id
                                 FROM mtl_related_items  MRI,
                                 mtl_system_items_b MSIB
                                 WHERE MRI.relationship_type_id = DECODE(:rel_type_code5, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                                 3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                                 7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                                 ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
                                 AND MRI.inventory_item_id
                             	  IN ( select NUM_VAL from IBE_TEMP_TABLE where key =  :l_temp_key)
                                 AND MSIB.organization_id     = :org_id7
                                 AND MSIB.organization_id     = MRI.organization_id --Bug 2922902
                                 AND MSIB.inventory_item_id   = MRI.related_item_id
                                 AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                 AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                 AND MSIB.web_status          = ''PUBLISHED'' ';



   l_with_mtl_mult_stmt3 CONSTANT VARCHAR2(2500) :=
                               'UNION ALL
                                SELECT MRI.inventory_item_id
                                FROM mtl_related_items MRI,
                                mtl_system_items_b MSIB
                             	WHERE MRI.relationship_type_id = DECODE(:rel_type_code9, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                             	3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                             	7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                             	11, ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
                                AND MRI.related_item_id       IN ( select NUM_VAL from IBE_TEMP_TABLE where key =  :l_temp_key)
                                AND MSIB.organization_id     = :org_id11
                                AND MSIB.organization_id     = MRI.organization_id --Bug 2922902
                                AND MSIB.inventory_item_id   = MRI.inventory_item_id
                                AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                AND MSIB.web_status          = ''PUBLISHED''
                                AND MRI.reciprocal_flag      = ''Y'' ';

   l_with_mtl_mult_stmt4 CONSTANT VARCHAR2(2000) :=
                                'MINUS
                                SELECT ICRE.related_item_id
                                FROM ibe_ct_rel_exclusions ICRE
                                WHERE ICRE.relation_type_code = :rel_type_code13
                                AND ICRE.inventory_item_id
                                IN ( select NUM_VAL from IBE_TEMP_TABLE where key =  :l_temp_key)
                            	AND ICRE.organization_id = :org_id15 '; --Bug 2922902
   l_wout_mtl_bulk_mult_stmt CONSTANT VARCHAR2(2000)  :=
                                                ' BEGIN
                                                SELECT DISTINCT ICRI.related_item_id
                                                     BULK COLLECT INTO :items_tbl1
                                                FROM ibe_ct_related_items ICRI,
                                                     mtl_system_items_b MSIB
                                                WHERE ICRI.relation_type_code = :rel_type_code2
                                                AND ICRI.inventory_item_id  IN (
                                                    select NUM_VAL from IBE_TEMP_TABLE where key =  :l_temp_key )
                                                AND NOT EXISTS( SELECT NULL
                                                    FROM ibe_ct_rel_exclusions ICRE
                                                    WHERE ICRE.relation_type_code = ICRI.relation_type_code
                                                    AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                                                    /*Bug 2922902*/
                                                    AND ICRE.organization_id    = ICRI.organization_id
                                                    AND ICRE.related_item_id    = ICRI.related_item_id )
                                                AND MSIB.organization_id   = :org_id4
                                                AND MSIB.organization_id   = ICRI.organization_id --Bug 2922902
                                                AND MSIB.inventory_item_id = ICRI.related_item_id
                                                AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                AND MSIB.web_status        = ''PUBLISHED'' ';
  l_pv_wout_mtl_mult_stmt CONSTANT VARCHAR2(2000)     :=
                                                ' SELECT DISTINCT ICRI.related_item_id
                                                 FROM ibe_ct_related_items ICRI,
                                                      mtl_system_items_b   MSIB
                                                 WHERE ICRI.relation_type_code = :rel_type_code1
                                                 AND ICRI.inventory_item_id  IN (
                                                     select NUM_VAL from IBE_TEMP_TABLE where key =  :l_temp_key)
                                                     AND NOT EXISTS( SELECT NULL
                                                     FROM ibe_ct_rel_exclusions ICRE
                                                     WHERE ICRE.relation_type_code = ICRI.relation_type_code
                                                     AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                                                     /*Bug 2922902*/   AND ICRE.organization_id    = ICRI.organization_id
                                                     AND ICRE.related_item_id    = ICRI.related_item_id )
                                                  AND MSIB.organization_id   = :org_id3
                                                  AND MSIB.organization_id   = ICRI.organization_id --Bug 2922902
                                                  AND MSIB.inventory_item_id = ICRI.related_item_id
                                                  AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                  AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                  AND (MSIB.web_status        = ''PUBLISHED'' OR MSIB.web_status = ''UNPUBLISHED'') ';
   l_pv_with_mtl_mult_stmt1 CONSTANT VARCHAR2(2000)   :=
                                                ' SELECT DISTINCT ICRI.related_item_id
                                                FROM ibe_ct_related_items ICRI,
                                                     mtl_system_items_b   MSIB
                                                WHERE ICRI.relation_type_code = :rel_type_code1
                                                AND ICRI.inventory_item_id  = :item_id2
                                                AND MSIB.organization_id    = :org_id3
                                                AND MSIB.organization_id    = ICRI.organization_id --Bug 2922902
                                                AND MSIB.inventory_item_id  = ICRI.related_item_id
                                                AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                AND (MSIB.web_status         = ''PUBLISHED'' OR MSIB.web_status = ''UNPUBLISHED'') ';
   l_pv_with_mtl_mult_stmt2 CONSTANT VARCHAR2(2500)   :=
                                                ' UNION ALL
                                                SELECT MRI.related_item_id
                                                FROM mtl_related_items  MRI,
                                                    mtl_system_items_b MSIB
                                                WHERE MRI.relationship_type_id = DECODE(:rel_type_code5, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                                                  3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                                                  7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                                                  11, ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
                                                AND MRI.inventory_item_id    = :item_id6
                                                AND MSIB.organization_id     = :org_id7
                                                AND MSIB.organization_id     = MRI.organization_id  --Bug 2922902
                                                AND MSIB.inventory_item_id   = MRI.related_item_id
                                                AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                AND (MSIB.web_status          = ''PUBLISHED'' OR MSIB.web_status = ''UNPUBLISHED'') ';
  l_pv_with_mtl_mult_stmt3 CONSTANT VARCHAR2(2500)    :=
                                                ' UNION ALL
                                                SELECT MRI.inventory_item_id
                                                FROM mtl_related_items MRI,  mtl_system_items_b MSIB
                                                WHERE MRI.relationship_type_id = DECODE(:rel_type_code9, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                                                 3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                                                 7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                                                 11, ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
                                                AND MRI.related_item_id      = :item_id10
                                                AND MSIB.organization_id     = :org_id11
                                                AND MSIB.organization_id     = MRI.organization_id --Bug 2922902
                                                AND MSIB.inventory_item_id   = MRI.inventory_item_id
                                                AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                AND (MSIB.web_status          = ''PUBLISHED'' OR MSIB.web_status = ''UNPUBLISHED'')
                                                AND MRI.reciprocal_flag      = ''Y'' ';
  l_pv_wout_mtl_bulk_mult_stmt CONSTANT VARCHAR2(2000) :=
                                                ' BEGIN
                                                SELECT DISTINCT ICRI.related_item_id
                                                BULK COLLECT INTO :items_tbl1
                                                FROM ibe_ct_related_items ICRI,
                                                  mtl_system_items_b   MSIB
                                                WHERE ICRI.relation_type_code = :rel_type_code2
                                                AND ICRI.inventory_item_id  = :item_id3
                                                AND NOT EXISTS( SELECT NULL
                                                    FROM ibe_ct_rel_exclusions ICRE
                                                    WHERE ICRE.relation_type_code = ICRI.relation_type_code
                                                    AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                                                    /*Bug 2922902*/AND ICRE.organization_id    = ICRI.organization_id
                                                    AND ICRE.related_item_id    = ICRI.related_item_id )
                                                AND MSIB.organization_id   = :org_id4
                                                AND MSIB.organization_id   = ICRI.organization_id  --Bug 2922902
                                                AND MSIB.inventory_item_id = ICRI.related_item_id
                                                AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                AND (MSIB.web_status        = ''PUBLISHED'' OR MSIB.web_status = ''UNPUBLISHED'') ';
 l_wout_mtl_stmt CONSTANT VARCHAR2(2000)              :=
                                                ' SELECT DISTINCT ICRI.related_item_id
                                                 FROM ibe_ct_related_items ICRI,
                                                      mtl_system_items_b   MSIB
                                                 WHERE ICRI.relation_type_code = :rel_type_code1
                                                 AND ICRI.inventory_item_id  = :item_id2
                                                 AND NOT EXISTS( SELECT NULL
                                                                   FROM ibe_ct_rel_exclusions ICRE
                                                                   WHERE ICRE.relation_type_code = ICRI.relation_type_code
                                                                   AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                                                                   AND ICRE.organization_id    = ICRI.organization_id /*Bug 2922902 */
                                                                   AND ICRE.related_item_id    = ICRI.related_item_id )
                                                 AND MSIB.organization_id   = :org_id3
                                                 AND MSIB.organization_id = ICRI.organization_id --Bug 2922902
                                                 AND MSIB.inventory_item_id = ICRI.related_item_id
                                                 AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                 AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                 AND MSIB.web_status        = ''PUBLISHED'' ';
 l_with_mtl_stmt1 CONSTANT VARCHAR2(2000)             :=
                                                ' SELECT DISTINCT ICRI.related_item_id
                                                 FROM ibe_ct_related_items ICRI,
                                                      mtl_system_items_b   MSIB
                                                 WHERE ICRI.relation_type_code = :rel_type_code1
                                                   AND ICRI.inventory_item_id  = :item_id2
                                                   AND MSIB.organization_id    = :org_id3
                                                   AND MSIB.organization_id = ICRI.organization_id --Bug 2922902
                                                   AND MSIB.inventory_item_id  = ICRI.related_item_id
                                                   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                   AND MSIB.web_status         = ''PUBLISHED'' ';

 l_with_mtl_stmt2 CONSTANT VARCHAR2(2500)             :=
                                                ' UNION ALL
                                                 SELECT MRI.related_item_id
                                                 FROM mtl_related_items  MRI,
                                                      mtl_system_items_b MSIB
                                                 WHERE MRI.relationship_type_id = DECODE(:rel_type_code5, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                                                                                  3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                                                                                  7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                                                                                  11, ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
                                                  AND MRI.inventory_item_id    = :item_id6
                                                  AND MSIB.organization_id     = :org_id7
                                                  AND MSIB.organization_id     = MRI.organization_id --Bug 2922902
                                                  AND MSIB.inventory_item_id   = MRI.related_item_id
                                                  AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                  AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                  AND MSIB.web_status          = ''PUBLISHED'' ';

 l_with_mtl_stmt3 CONSTANT VARCHAR2(2500)             :=
                                                ' UNION ALL
                                                 SELECT MRI.inventory_item_id
                                                 FROM mtl_related_items MRI,
                                                      mtl_system_items_b MSIB
                                                 WHERE MRI.relationship_type_id = DECODE(:rel_type_code9, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                                                                                  3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                                                                                  7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                                                                                  11, ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
                                                  AND MRI.related_item_id      = :item_id10
                                                  AND MSIB.organization_id     = :org_id11
                                                  AND MSIB.organization_id     = MRI.organization_id --Bug 2922902
                                                  AND MSIB.inventory_item_id   = MRI.inventory_item_id
                                                  AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                  AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                  AND MSIB.web_status          = ''PUBLISHED''
                                                  AND MRI.reciprocal_flag      = ''Y'' ';

 l_with_mtl_stmt4 CONSTANT VARCHAR2(2000)             :=
                                                ' MINUS
                                                 SELECT ICRE.related_item_id
                                                 FROM ibe_ct_rel_exclusions ICRE
                                                 WHERE ICRE.relation_type_code = :rel_type_code13
                                                   AND ICRE.inventory_item_id  = :item_id14
                                                   AND ICRE.organization_id = :org_id15 '; --Bug 2922902

 l_wout_mtl_bulk_stmt CONSTANT VARCHAR2(2000)         :=
                                                ' BEGIN
                                                  SELECT DISTINCT ICRI.related_item_id
                                                  BULK COLLECT INTO :items_tbl1
                                                  FROM ibe_ct_related_items ICRI,
                                                       mtl_system_items_b   MSIB
                                                  WHERE ICRI.relation_type_code = :rel_type_code2
                                                    AND ICRI.inventory_item_id  = :item_id3
                                                    AND NOT EXISTS( SELECT NULL
                                                                  FROM ibe_ct_rel_exclusions ICRE
                                                                  WHERE ICRE.relation_type_code = ICRI.relation_type_code
                                                                  AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                                                                  AND ICRE.organization_id    = ICRI.organization_id /*Bug 2922902*/
                                                                  AND ICRE.related_item_id    = ICRI.related_item_id )
                                                    AND MSIB.organization_id   = :org_id4
                                                    AND MSIB.organization_id   = ICRI.organization_id --Bug 2922902
                                                    AND MSIB.inventory_item_id = ICRI.related_item_id
                                                    AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                    AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                    AND MSIB.web_status        = ''PUBLISHED'' ';

 l_pv_wout_mtl_stmt CONSTANT VARCHAR2(2000)           :=
                                                ' SELECT DISTINCT ICRI.related_item_id
                                                 FROM ibe_ct_related_items ICRI,
                                                      mtl_system_items_b   MSIB
                                                 WHERE ICRI.relation_type_code = :rel_type_code1
                                                   AND ICRI.inventory_item_id  = :item_id2
                                                   AND NOT EXISTS( SELECT NULL
                                                                   FROM ibe_ct_rel_exclusions ICRE
                                                                   WHERE ICRE.relation_type_code = ICRI.relation_type_code
                                                                    AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                                                                    AND ICRE.organization_id    = ICRI.organization_id /*Bug 2922902*/
                                                                    AND ICRE.related_item_id    = ICRI.related_item_id )
                                                   AND MSIB.organization_id   = :org_id3
                                                   AND MSIB.organization_id   = ICRI.organization_id --Bug 2922902
                                                   AND MSIB.inventory_item_id = ICRI.related_item_id
                                                   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                   AND (MSIB.web_status        = ''PUBLISHED'' OR MSIB.web_status = ''UNPUBLISHED'') ';

 l_pv_with_mtl_stmt1 CONSTANT VARCHAR2(2000)          :=
                                                ' SELECT DISTINCT ICRI.related_item_id
                                                 FROM ibe_ct_related_items ICRI,
                                                      mtl_system_items_b   MSIB
                                                 WHERE ICRI.relation_type_code = :rel_type_code1
                                                   AND ICRI.inventory_item_id  = :item_id2
                                                   AND MSIB.organization_id    = :org_id3
                                                   AND MSIB.organization_id    = ICRI.organization_id --Bug 2922902
                                                   AND MSIB.inventory_item_id  = ICRI.related_item_id
                                                   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                   AND (MSIB.web_status         = ''PUBLISHED'' OR MSIB.web_status = ''UNPUBLISHED'') ';

   l_pv_with_mtl_stmt2 CONSTANT VARCHAR2(2500)        :=
                                                ' UNION ALL
                                                 SELECT MRI.related_item_id
                                                 FROM mtl_related_items  MRI,
                                                      mtl_system_items_b MSIB
                                                 WHERE MRI.relationship_type_id = DECODE(:rel_type_code5, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                                                                                  3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                                                                                  7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                                                                                  11, ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
                                                   AND MRI.inventory_item_id    = :item_id6
                                                   AND MSIB.organization_id     = :org_id7
                                                   AND MSIB.organization_id     = MRI.organization_id  --Bug 2922902
                                                   AND MSIB.inventory_item_id   = MRI.related_item_id
                                                   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                   AND (MSIB.web_status          = ''PUBLISHED'' OR MSIB.web_status = ''UNPUBLISHED'') ';

   l_pv_with_mtl_stmt3 CONSTANT VARCHAR2(2500)        :=
                                                ' UNION ALL
                                                 SELECT MRI.inventory_item_id
                                                 FROM mtl_related_items MRI,
                                                      mtl_system_items_b MSIB
                                                 WHERE MRI.relationship_type_id = DECODE(:rel_type_code9, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                                                                                  3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                                                                                  7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                                                                                  11, ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
                                                   AND MRI.related_item_id      = :item_id10
                                                   AND MSIB.organization_id     = :org_id11
                                                   AND MSIB.organization_id     = MRI.organization_id --Bug 2922902
                                                   AND MSIB.inventory_item_id   = MRI.inventory_item_id
                                                   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                   AND (MSIB.web_status          = ''PUBLISHED'' OR MSIB.web_status = ''UNPUBLISHED'')
                                                   AND MRI.reciprocal_flag      = ''Y'' ';

   l_pv_wout_mtl_bulk_stmt CONSTANT VARCHAR2(2000)    :=
                                                 ' BEGIN
                                                  SELECT DISTINCT ICRI.related_item_id
                                                  BULK COLLECT INTO :items_tbl1
                                                  FROM ibe_ct_related_items ICRI,
                                                       mtl_system_items_b   MSIB
                                                  WHERE ICRI.relation_type_code = :rel_type_code2
                                                    AND ICRI.inventory_item_id  = :item_id3
                                                    AND NOT EXISTS( SELECT NULL
                                                                    FROM ibe_ct_rel_exclusions ICRE
                                                                    WHERE ICRE.relation_type_code = ICRI.relation_type_code
                                                                      AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                                                                      AND ICRE.organization_id    = ICRI.organization_id /*Bug 2922902*/
                                                                      AND ICRE.related_item_id    = ICRI.related_item_id )
                                                    AND MSIB.organization_id   = :org_id4
                                                    AND MSIB.organization_id   = ICRI.organization_id  --Bug 2922902
                                                    AND MSIB.inventory_item_id = ICRI.related_item_id
                                                    AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
                                                    AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
                                                    AND (MSIB.web_status        = ''PUBLISHED'' OR MSIB.web_status = ''UNPUBLISHED'') ';
   l_rel_items_csr rel_items_csr_type;
   l_stmt          VARCHAR2(2000);
   l_rel_item_id   NUMBER;
   l_sql_stmt      VARCHAR2(2000);
   l_temp_key      CONSTANT VARCHAR2(20) := 'ITEMIDS_RELATED';
   l_bind_arg_num  PLS_INTEGER;
   l_dummy         number;
   i               PLS_INTEGER := 1;
   include_mtl     BOOLEAN;
   l_debug         VARCHAR2(1);
   l_item_ids      VARCHAR2(2000) ;
   x_query_string  VARCHAR2(2000);
   rowcount        NUMBER :=0;
   l_init_msg_list VARCHAR2(5);
   l_preview_flag  VARCHAR2(5);
   l_include_self_ref  VARCHAR2(5);
   l_rule_type     VARCHAR2(10);

BEGIN
   l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
   l_item_ids := ' ';

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF p_init_msg_list IS NULL THEN
   	l_init_msg_list := FND_API.G_FALSE;
   END IF;

   IF p_preview_flag IS NULL THEN
   	l_preview_flag := FND_API.G_FALSE;
   END IF;

   IF p_include_self_ref IS NULL THEN
   	l_include_self_ref := FND_API.G_FALSE;
   END IF;

   IF p_rule_type IS NULL THEN
   	l_rule_type := 'MAPPING';
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --  Initialize the return value table
   x_items_tbl := JTF_Number_Table();

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_GRP.Get_Related_Items(+)');
      IBE_UTIL.debug('p_org_id : p_rel_type_code : l_rule_type = '
                  || p_org_id || ' : '
                  || p_rel_type_code || ' : ' || l_rule_type);
   END IF;

   -- API body
   -- 1. Check if the relationship exists and is active
   IF NOT Is_Relationship_Valid(p_rel_type_code) THEN
      IF (l_debug = 'Y') THEN
         IBE_UTIL.debug('Relationship is not valid.');
      END IF;
      FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_VALID');
      FND_MESSAGE.Set_Token('RELATIONSHIP', p_rel_type_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Populate the itemIds into a temporary table.
    IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Inserting to ibe_temp_table.');
    END IF;

   FOR  i in p_item_ids.FIRST .. p_item_ids.LAST
    LOOP
    IBE_UTIL.INSERT_INTO_TEMP_TABLE(p_item_ids(i), 'NUM',l_temp_key, x_query_string);
    END LOOP;

   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_GRP.Get_Related_Items(+)');
      IBE_UTIL.debug('l_item_ids : ' || l_item_ids );
   END IF;
   IF l_rule_type = 'SQL' THEN
      -- 2. Get the related items using the manual SQL.
      BEGIN  -- begin sub-block to handle the SELECT statement's exception
         SELECT ICRR.sql_statement
         INTO l_sql_stmt
         FROM ibe_ct_relation_rules ICRR
         WHERE ICRR.relation_type_code = p_rel_type_code
           AND ICRR.origin_object_type = 'N'
           AND ICRR.dest_object_type = 'N';
         l_bind_arg_num := Get_Bind_Arg_Num( l_sql_stmt );
         IF l_bind_arg_num = 0 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt;
         ELSIF l_bind_arg_num = 1 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1;
         ELSIF l_bind_arg_num = 2 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2;
         ELSIF l_bind_arg_num = 3 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3;
         ELSIF l_bind_arg_num = 4 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4;
         ELSIF l_bind_arg_num = 5 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5;
         ELSIF l_bind_arg_num = 6 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5, p_bind_arg6;
         ELSIF l_bind_arg_num = 7 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5, p_bind_arg6,
                                       p_bind_arg7;
         ELSIF l_bind_arg_num = 8 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5, p_bind_arg6,
                                       p_bind_arg7, p_bind_arg8;
         ELSIF l_bind_arg_num = 9 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5, p_bind_arg6,
                                       p_bind_arg7, p_bind_arg8, p_bind_arg9;
         ELSIF l_bind_arg_num = 10 THEN
            OPEN l_rel_items_csr FOR l_sql_stmt
                                 USING p_bind_arg1, p_bind_arg2, p_bind_arg3,
                                       p_bind_arg4, p_bind_arg5, p_bind_arg6,
                                       p_bind_arg7, p_bind_arg8, p_bind_arg9,
                                       p_bind_arg10;
         END IF;
/*
-- BULK FETCH does not work in 8.1.6.  When supported in 8.2,
-- we should enable for performance; replace the next IF block
-- the following.
         IF p_max_ret_num IS NULL THEN
            FETCH l_rel_items_csr BULK COLLECT INTO x_items_tbl;
         ELSE
            LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               x_items_tbl.EXTEND;
               x_items_tbl(i) := l_rel_item_id;
               i := i + 1;
               IF i > p_max_ret_num THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
*/
         IF p_max_ret_num IS NULL THEN
            LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               IF isBelongToMinisite(l_rel_item_id,p_msite_id) THEN
                  x_items_tbl.EXTEND;
                  x_items_tbl(i) := l_rel_item_id;
                  i := i + 1;
               END IF;
            END LOOP;
         ELSE
            LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               IF isBelongToMinisite(l_rel_item_id,p_msite_id) THEN
                  x_items_tbl.EXTEND;
                  x_items_tbl(i) := l_rel_item_id;
                  i := i + 1;
               END IF;
               IF i > p_max_ret_num THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         CLOSE l_rel_items_csr;
         RETURN;
      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 'Y') THEN
               IBE_UTIL.debug('SQL execution caused an error.');
            END IF;
            FND_MESSAGE.Set_Name('IBE', 'IBE_CT_SQL_RULE_ERROR');
            FND_MESSAGE.Set_Token('RELATIONSHIP', p_rel_type_code);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
      END;  -- end sub-block to handle the SELECT statement's exception
   ELSE -- l_rule_type = 'MAPPING'
      -- 3. Get the related items from ibe_ct_related_items table
        include_mtl := Exists_In_MTL(p_rel_type_code);

        IF (p_max_ret_num IS NULL) AND (NOT include_mtl) THEN -- Can use bulk fetching

          IF FND_API.to_Boolean( l_include_self_ref ) THEN -- include self referral
            IF (l_debug = 'Y') THEN
               IBE_UTIL.debug('Mapping rule: p_max_ret_num is NULL: relationship NOT in MTL: l_include_self_ref is TRUE.');
            END IF;
            IF FND_API.to_Boolean(l_preview_flag) THEN --preview mode
               IF (p_item_ids.LAST > 1) THEN  -- multiple items as input
                  EXECUTE IMMEDIATE l_pv_wout_mtl_bulk_mult_stmt || l_minisite_stmt || '; END;'
                  USING OUT x_items_tbl, p_rel_type_code, l_temp_key, p_org_id, p_msite_id;
               ELSE
                  EXECUTE IMMEDIATE l_pv_wout_mtl_bulk_stmt || l_minisite_stmt || '; END;'
                  USING OUT x_items_tbl, p_rel_type_code, p_item_ids(1), p_org_id, p_msite_id;
               END IF ;
            ELSE --Customer UI mode
               IF (p_item_ids.LAST > 1) THEN  -- multiple items as input
                  EXECUTE IMMEDIATE l_wout_mtl_bulk_mult_stmt || l_minisite_stmt || '; END;'
                  USING OUT x_items_tbl, p_rel_type_code, l_temp_key, p_org_id, p_msite_id;
               ELSE
                  EXECUTE IMMEDIATE l_wout_mtl_bulk_stmt || l_minisite_stmt ||  '; END;'
                  USING OUT x_items_tbl, p_rel_type_code, p_item_ids(1), p_org_id, p_msite_id;
               END IF;
            END IF;
          ELSE -- exclude self referral
            IF (l_debug = 'Y') THEN
               IBE_UTIL.debug('Mapping rule: p_max_ret_num is NULL: relationship NOT in MTL: l_include_self_ref is FALSE.');
            END IF;
            IF FND_API.to_Boolean(l_preview_flag) THEN --preview mode
               IF (p_item_ids.LAST > 1) THEN  -- multiple items
                  EXECUTE IMMEDIATE l_pv_wout_mtl_bulk_mult_stmt || l_minisite_stmt ||
                                 ' AND ICRI.related_item_id NOT ' || l_temp_itemids_query ||
                                 '; END;'
                  USING OUT x_items_tbl, p_rel_type_code, l_temp_key, p_org_id, p_msite_id, l_temp_key;
               ELSE -- single item
                  EXECUTE IMMEDIATE l_pv_wout_mtl_bulk_stmt || l_minisite_stmt ||
                                 ' AND ICRI.related_item_id <> :item_id5 ' ||
                                 '; END;'
                  USING OUT x_items_tbl, p_rel_type_code, p_item_ids(1), p_org_id, p_msite_id, p_item_ids(1);
               END IF;
             ELSE -- Cust UI mode
                IF (p_item_ids.LAST > 1) THEN --multiple items
                  EXECUTE IMMEDIATE l_wout_mtl_bulk_mult_stmt ||
                                 ' AND ICRI.related_item_id NOT ' || l_temp_itemids_query ||
                                   l_minisite_stmt ||
                                 '; END;'
                  USING OUT x_items_tbl, p_rel_type_code, l_temp_key, p_org_id, p_msite_id;
                ELSE -- single item
                  EXECUTE IMMEDIATE l_wout_mtl_bulk_stmt ||
                                 ' AND ICRI.related_item_id <> :item_id5 ' ||
                                   l_minisite_stmt ||
                                 '; END;'
                  USING OUT x_items_tbl, p_rel_type_code, p_item_ids(1), p_org_id, p_item_ids(1), p_msite_id;
                END IF;
             END IF;
          END IF; -- exclude self referral
        ELSE -- Cannot use bulk fetching

          IF include_mtl THEN -- must do union with mtl_related_items

            IF FND_API.to_Boolean( l_include_self_ref ) THEN -- include self referral

               IF (l_debug = 'Y') THEN
                  IBE_UTIL.debug('Mapping rule: relationship in MTL: l_include_self_ref is TRUE.');

               END IF;
               IF FND_API.to_Boolean(l_preview_flag) THEN -- preview mode
                  IF (p_item_ids.LAST > 1) THEN --multiple items
                    OPEN l_rel_items_csr FOR l_pv_with_mtl_mult_stmt1 ||
                                           l_minisite_stmt ||
                                           l_pv_with_mtl_mult_stmt2 ||
                                           l_pv_with_mtl_mult_stmt3 ||
                                           l_with_mtl_mult_stmt4
                    USING p_rel_type_code, l_temp_key, p_org_id,
                          p_msite_id,
                          p_rel_type_code, l_temp_key, p_org_id,
                          p_rel_type_code, l_temp_key, p_org_id,
                          p_rel_type_code, l_temp_key, p_org_id; --Bug 2922902
                  ELSE --single item
                    OPEN l_rel_items_csr FOR l_pv_with_mtl_stmt1 ||
                                           l_minisite_stmt ||
                                           l_pv_with_mtl_stmt2 ||
                                           l_pv_with_mtl_stmt3 ||
                                           l_with_mtl_stmt4
                    USING p_rel_type_code, p_item_ids(1), p_org_id,
                          p_msite_id,
                          p_rel_type_code, p_item_ids(1), p_org_id,
                          p_rel_type_code, p_item_ids(1), p_org_id,
                          p_rel_type_code, p_item_ids(1), p_org_id; --Bug 2922902
                  END IF;
               ELSE -- Cust UI Mode
                  IF (p_item_ids.LAST > 1) THEN --multiple items

                    OPEN l_rel_items_csr FOR l_with_mtl_mult_stmt1 ||
                                           l_minisite_stmt ||
                                           l_with_mtl_mult_stmt2 ||
                                           l_with_mtl_mult_stmt3 ||
                                           l_with_mtl_mult_stmt4
                    USING p_rel_type_code, l_temp_key, p_org_id,
                          p_msite_id,
                          p_rel_type_code, l_temp_key, p_org_id,
                          p_rel_type_code, l_temp_key, p_org_id,
                          p_rel_type_code, l_temp_key, p_org_id; --Bug 2922902
                  ELSE --single item
                    OPEN l_rel_items_csr FOR l_with_mtl_stmt1 ||
                                           l_minisite_stmt ||
                                           l_with_mtl_stmt2 ||
                                           l_with_mtl_stmt3 ||
                                           l_with_mtl_stmt4
                    USING p_rel_type_code, p_item_ids(1), p_org_id,
                          p_msite_id,
                          p_rel_type_code, p_item_ids(1), p_org_id,
                          p_rel_type_code, p_item_ids(1), p_org_id,
                          p_rel_type_code, p_item_ids(1), p_org_id; --Bug 2922902
                  END IF;
               END IF;
            ELSE -- exclude self referral

               IF (l_debug = 'Y') THEN
                  IBE_UTIL.debug('Mapping rule: relationship in MTL: l_include_self_ref is FALSE.');
               END IF;

               IF FND_API.to_Boolean(l_preview_flag) THEN -- preview mode
                  IF (p_item_ids.LAST > 1) THEN --multiple items
                    OPEN l_rel_items_csr FOR l_pv_with_mtl_mult_stmt1 ||
                                           ' AND ICRI.related_item_id NOT ' || l_temp_itemids_query ||
                                           l_minisite_stmt ||
                                           l_pv_with_mtl_mult_stmt2 ||
                                           ' AND MRI.related_item_id NOT ' || l_temp_itemids_query ||
                                           l_pv_with_mtl_mult_stmt3 ||
                                           ' AND MRI.inventory_item_id NOT ' || l_temp_itemids_query ||
                                           l_with_mtl_mult_stmt4
                    USING p_rel_type_code, l_temp_key, p_org_id, l_temp_key,
                          p_msite_id,
                          p_rel_type_code, l_temp_key, p_org_id, l_temp_key,
                          p_rel_type_code, l_temp_key, p_org_id, l_temp_key ,
                          p_rel_type_code, l_temp_key, p_org_id;  --Bug 2922902
                  ELSE --single item
                    OPEN l_rel_items_csr FOR l_pv_with_mtl_stmt1 ||
                                           ' AND ICRI.related_item_id <> :item_id4 ' ||
                                           l_minisite_stmt ||
                                           l_pv_with_mtl_stmt2 ||
                                           ' AND MRI.related_item_id <> :item_id8 ' ||
                                           l_pv_with_mtl_stmt3 ||
                                           ' AND MRI.inventory_item_id <> :item_id12 ' ||
                                           l_with_mtl_stmt4
                    USING p_rel_type_code, p_item_ids(1), p_org_id, p_item_ids(1),
                          p_msite_id,
                          p_rel_type_code, p_item_ids(1), p_org_id, p_item_ids(1),
                          p_rel_type_code, p_item_ids(1), p_org_id, p_item_ids(1) ,
                          p_rel_type_code, p_item_ids(1), p_org_id;  --Bug 2922902
                  END IF;
               ELSE -- Cust UI Mode
                    SELECT COUNT(*) INTO l_dummy from ibe_temp_table;
                    IF (l_debug = 'Y') THEN
                      IBE_UTIL.debug('B4 QUERY '||l_dummy||'type code '||p_rel_type_code ||'key '||l_temp_key||'org id '||p_org_id||'msite id' ||p_msite_id);
                    END IF;

                  IF (p_item_ids.LAST > 1) THEN --multiple items
                    OPEN l_rel_items_csr FOR l_with_mtl_mult_stmt1 ||
                                           ' AND ICRI.related_item_id NOT ' || l_temp_itemids_query ||
                                           l_minisite_stmt ||
                                           l_with_mtl_mult_stmt2 ||
                                           ' AND MRI.related_item_id NOT ' || l_temp_itemids_query ||
                                           l_with_mtl_mult_stmt3 ||
                                           ' AND MRI.inventory_item_id NOT ' || l_temp_itemids_query ||
                                           l_with_mtl_mult_stmt4
                    USING p_rel_type_code, l_temp_key, p_org_id, l_temp_key,
                          p_msite_id ,
                          p_rel_type_code, l_temp_key, p_org_id, l_temp_key,
                          p_rel_type_code, l_temp_key, p_org_id, l_temp_key ,
                          p_rel_type_code, l_temp_key, p_org_id; --Bug 2922902
                    IF (l_debug = 'Y') THEN
                      IBE_UTIL.debug('Mapping rule: relationship in MTL: l_include_self_ref is FALSE. finished query'|| l_rel_items_csr%ROWCOUNT);
                    END IF;

                   ELSE --single item
                    OPEN l_rel_items_csr FOR l_with_mtl_stmt1 ||
                                           ' AND ICRI.related_item_id <> :item_id4 ' ||
                                           l_minisite_stmt ||
                                           l_with_mtl_stmt2 ||
                                           ' AND MRI.related_item_id <> :item_id8 ' ||
                                           l_with_mtl_stmt3 ||
                                           ' AND MRI.inventory_item_id <> :item_id12 '||
                                           l_with_mtl_stmt4
                    USING p_rel_type_code, p_item_ids(1), p_org_id, p_item_ids(1),
                          p_msite_id ,
                          p_rel_type_code, p_item_ids(1), p_org_id, p_item_ids(1),
                          p_rel_type_code, p_item_ids(1), p_org_id, p_item_ids(1) ,
                          p_rel_type_code, p_item_ids(1), p_org_id; --Bug 2922902
                   END IF;
               END IF;
            END IF; --exclude self- referral
         ELSE -- don't need to do union with mtl_related_items
            IF FND_API.to_Boolean( l_include_self_ref ) THEN -- include self referral
               IF (l_debug = 'Y') THEN
                  IBE_UTIL.debug('Mapping rule: p_max_ret_num is NOT NULL: relationship NOT in MTL: l_include_self_ref is TRUE.');
               END IF;

               IF FND_API.to_Boolean(l_preview_flag) THEN -- preview mode
                  IF (p_item_ids.LAST > 1) THEN --multiple items
                    OPEN l_rel_items_csr FOR l_pv_wout_mtl_mult_stmt || l_minisite_stmt
                    USING p_rel_type_code, p_item_ids, p_org_id, p_msite_id;
                  ELSE --single item
                    OPEN l_rel_items_csr FOR l_pv_wout_mtl_stmt || l_minisite_stmt
                    USING p_rel_type_code, p_item_ids(1), p_org_id, p_msite_id;
                  END IF;
               ELSE -- Cust UI mode
                  IF (p_item_ids.LAST > 1) THEN --multiple items
                    OPEN l_rel_items_csr FOR l_wout_mtl_mult_stmt || l_minisite_stmt
                    USING p_rel_type_code, p_item_ids, p_org_id, p_msite_id;
                  ELSE --single item
                    OPEN l_rel_items_csr FOR l_wout_mtl_stmt || l_minisite_stmt
                    USING p_rel_type_code, p_item_ids(1), p_org_id, p_msite_id;
                  END IF;
               END IF;
             ELSE -- exclude self referral
               IF (l_debug = 'Y') THEN
                  IBE_UTIL.debug('Mapping rule: p_max_ret_num is NOT NULL: relationship NOT in MTL: l_include_self_ref is FALSE.');
               END IF;

               IF FND_API.to_Boolean(l_preview_flag) THEN -- preview mode
                  IF (p_item_ids.LAST > 1) THEN --multiple items
                    OPEN l_rel_items_csr FOR l_pv_wout_mtl_mult_stmt ||
                                             ' AND ICRI.related_item_id <> :item_id4 ' || l_minisite_stmt
                    USING p_rel_type_code, p_item_ids, p_org_id, p_item_ids, p_msite_id;
                  ELSE --single item
                    OPEN l_rel_items_csr FOR l_pv_wout_mtl_stmt ||
                                             ' AND ICRI.related_item_id <> :item_id4 ' || l_minisite_stmt
                    USING p_rel_type_code, p_item_ids(1), p_org_id, p_item_ids(1), p_msite_id;
                  END IF;
                ELSE -- Cust UI mod
                  IF (p_item_ids.LAST > 1) THEN --multiple items
                    OPEN l_rel_items_csr FOR l_wout_mtl_mult_stmt ||
                                           ' AND ICRI.related_item_id <> :item_id4 ' || l_minisite_stmt
                    USING p_rel_type_code, p_item_ids, p_org_id, p_item_ids, p_msite_id;
                  ELSE --single item
                    OPEN l_rel_items_csr FOR l_wout_mtl_stmt ||
                                           ' AND ICRI.related_item_id <> :item_id4 ' || l_minisite_stmt
                    USING p_rel_type_code, p_item_ids(1), p_org_id, p_item_ids(1), p_msite_id;
                  END IF;
                END IF;
              END IF; -- end exclude self referral
         END IF; --end don't need to do union with mtl_related_items

         IF p_max_ret_num IS NULL THEN
            LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               x_items_tbl.EXTEND;
               x_items_tbl(i) := l_rel_item_id;
               i := i + 1;
            END LOOP;
         ELSE
            LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               x_items_tbl.EXTEND;
               x_items_tbl(i) := l_rel_item_id;
               i := i + 1;
               IF i > p_max_ret_num THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
         CLOSE l_rel_items_csr;
      END IF;
   END IF;

   --Remove the inserted ids from the temp table;
   l_status := IBE_UTIL.delete_from_temp_table(l_temp_key);
   -- End of API body.
   IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('IBE_Prod_Relation_GRP.Get_Related_Items(-)');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );
END Get_Related_Items;
END IBE_Prod_Relation_GRP;

/
