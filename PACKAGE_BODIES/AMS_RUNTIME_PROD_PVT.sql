--------------------------------------------------------
--  DDL for Package Body AMS_RUNTIME_PROD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_RUNTIME_PROD_PVT" as
/* $Header: amsvrpdb.pls 115.20 2004/07/27 14:06:48 sikalyan ship $*/

AMS_DEBUG_HIGH_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON constant boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

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
    SELECT COUNT(B.SECTION_ITEM_ID) INTO rowsReturned FROM JTF_DSP_SECTION_ITEMS s, JTF_DSP_MSITE_SCT_ITEMS b
    WHERE S.SECTION_ITEM_ID = B.SECTION_ITEM_ID AND B.MINI_SITE_ID = p_msite_id
    AND S.INVENTORY_ITEM_ID = p_item_id
    AND NVL(S.START_DATE_ACTIVE,SYSDATE) < SYSDATE
    AND NVL(S.END_DATE_ACTIVE,SYSDATE) > SYSDATE;
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
--    Function   :
--    Pre-reqs   : None.
--    Parameters :
--    OUT        :
--
--    Notes      : Note text
--
-- End of comments
PROCEDURE getRelatedItems(
   p_api_version_number      IN         NUMBER               ,
   p_init_msg_list    IN         VARCHAR2 := FND_API.G_FALSE ,
   p_application_id   IN         NUMBER                      ,
   p_msite_id         IN         NUMBER                      ,
   p_top_section_id   IN         NUMBER                      ,
   p_incl_section     IN         VARCHAR2 := NULL ,
   p_prod_lst         IN         JTF_NUMBER_TABLE            ,
   p_rel_type_code    IN         VARCHAR2                    ,
   p_org_id           IN         NUMBER                      ,
   p_max_ret_num      IN         NUMBER   := NULL           ,
   p_order_by_clause  IN         VARCHAR2 := NULL           ,
   x_items_tbl        OUT NOCOPY JTF_Number_Table            ,
   x_return_status    OUT NOCOPY VARCHAR2                    ,
   x_msg_count        OUT NOCOPY NUMBER                      ,
   x_msg_data         OUT NOCOPY VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30) := 'getRelatedItems';
   l_api_version   CONSTANT NUMBER       := 1.0;

   l_minisite_stmt VARCHAR2(2000) :=
   ' AND ICRI.related_item_id IN (SELECT D.item_id FROM AMS_IBA_MS_ITEMS_DENORM D
        WHERE D.MINISITE_ID = :msite_id
              AND NVL(D.START_DATE_ACTIVE,SYSDATE) <= SYSDATE
              AND NVL(D.END_DATE_ACTIVE,SYSDATE) >= SYSDATE )';

   l_minisite_section_stmt VARCHAR2(2000) :=
   ' AND ICRI.related_item_id IN (SELECT D.item_id FROM AMS_IBA_MS_ITEMS_DENORM D
        WHERE D.MINISITE_ID = :msite_id
              AND D.TOP_SECTION_ID = :top_section_id
              AND NVL(D.START_DATE_ACTIVE,SYSDATE) <= SYSDATE
              AND NVL(D.END_DATE_ACTIVE,SYSDATE) >= SYSDATE )';

   l_minisite_not_in_section_stmt VARCHAR2(2000) :=
   ' AND ICRI.related_item_id NOT IN (SELECT D.item_id FROM AMS_IBA_MS_ITEMS_DENORM D
        WHERE D.MINISITE_ID = :msite_id
              AND D.TOP_SECTION_ID = :top_section_id
              AND D.ITEM_ID = ICRI.related_item_id
              AND NVL(D.START_DATE_ACTIVE,SYSDATE) <= SYSDATE
              AND NVL(D.END_DATE_ACTIVE,SYSDATE) >= SYSDATE )';

   l_without_mtl_stmt VARCHAR2(4000) :=
'SELECT DISTINCT ICRI.related_item_id
 FROM ibe_ct_related_items ICRI,
      mtl_system_items_b   MSIB
 WHERE ICRI.relation_type_code = :rel_type_code1
   AND NOT EXISTS( SELECT NULL
                   FROM ibe_ct_rel_exclusions ICRE
                   WHERE ICRE.relation_type_code = ICRI.relation_type_code
                     AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                     AND ICRE.related_item_id    = ICRI.related_item_id )
   AND MSIB.organization_id   = :org_id3
   AND MSIB.inventory_item_id = ICRI.related_item_id
   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
   AND MSIB.web_status        = ''PUBLISHED''
   AND ICRI.inventory_item_id IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_with_mtl_stmt1 VARCHAR2(4000) :=
' SELECT DISTINCT ICRI.related_item_id
  FROM ibe_ct_related_items ICRI,
      mtl_system_items_b   MSIB
  WHERE ICRI.relation_type_code = :rel_type_code1
   AND MSIB.organization_id    = :org_id2
   AND MSIB.inventory_item_id  = ICRI.related_item_id
   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
   AND MSIB.web_status         = ''PUBLISHED''
   AND ICRI.inventory_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_with_mtl_stmt4 VARCHAR2(2000) :=
' AND ICRI.related_item_id NOT IN (
  SELECT ICRE.related_item_id
  FROM ibe_ct_rel_exclusions ICRE
  WHERE ICRE.relation_type_code = :rel_type_code1
   AND ICRE.inventory_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_without_mtl_bulk_stmt VARCHAR2(4000) :=
'BEGIN
    SELECT DISTINCT ICRI.related_item_id
    BULK COLLECT INTO :items_tbl1
    FROM ibe_ct_related_items ICRI,
         mtl_system_items_b   MSIB
    WHERE ICRI.relation_type_code = :rel_type_code2
      AND NOT EXISTS( SELECT NULL
                      FROM ibe_ct_rel_exclusions ICRE
                      WHERE ICRE.relation_type_code = ICRI.relation_type_code
                        AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                        AND ICRE.related_item_id    = ICRI.related_item_id )
      AND MSIB.organization_id   = :org_id4
      AND MSIB.inventory_item_id = ICRI.related_item_id
      AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
      AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
      AND MSIB.web_status        = ''PUBLISHED''
      AND ICRI.inventory_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_stmt          VARCHAR2(2000);
   l_rel_items_csr prod_cursor;
   l_rel_item_id   NUMBER;
   l_sql_stmt      VARCHAR2(2000);
   l_bind_arg_num  PLS_INTEGER;
   l_dummy         VARCHAR2(30);
   i               PLS_INTEGER        := 1;
   include_mtl     BOOLEAN;
   p_index  BINARY_INTEGER;
   l_items_in_clause  VARCHAR2(32760);


BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelatedItems starts');

   END IF;

   --  Initialize the return value table
   x_items_tbl := JTF_Number_Table();

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('p_org_id : p_rel_type_code  '
                  || p_org_id || ' : '
                  || p_rel_type_code);

   END IF;

-- Commented IN Clause BugFix 3776065

--  p_Index := p_prod_lst.FIRST;
--  FOR pNum IN 1..( p_prod_lst.COUNT - 1 ) LOOP
--    l_items_in_clause := l_items_in_clause || TO_CHAR( p_prod_lst( p_Index ) ) || ', ';
--    p_Index := p_prod_lst.NEXT( p_Index );
--  END LOOP;

--  p_Index := p_prod_lst.LAST;
--  l_items_in_clause := l_items_in_clause || TO_CHAR( p_prod_lst( p_Index ) ) || ')';

-- 1. Get the related items from ibe_ct_related_items table

   include_mtl := Exists_In_MTL(p_rel_type_code);

   IF (p_max_ret_num IS NULL) AND (NOT include_mtl) THEN -- Can use bulk fetching

     IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('p_max_ret_num is NULL: relationship NOT in MTL. Top Section Id ' || To_CHAR(p_top_section_id));

     END IF;

     IF (p_top_section_id IS NULL OR p_incl_section IS NULL) THEN
       --no Section Filtering, only Minisite Filtering
       EXECUTE IMMEDIATE l_without_mtl_bulk_stmt  ||
                         l_minisite_stmt          ||
                         '; END;'
       USING OUT x_items_tbl, p_rel_type_code, p_org_id, p_prod_lst, p_msite_id;
     ELSIF (p_incl_section = FND_API.G_TRUE) THEN
       --Include Items in top Section and Minisite
       EXECUTE IMMEDIATE l_without_mtl_bulk_stmt  ||
                         l_minisite_section_stmt  ||
                         '; END;'
       USING OUT x_items_tbl, p_rel_type_code, p_org_id, p_prod_lst, p_msite_id, p_top_section_id;
     ELSE
       --Include Items in Minisite but not in top section
       EXECUTE IMMEDIATE l_without_mtl_bulk_stmt       ||
                         l_minisite_stmt               ||
                         l_minisite_not_in_section_stmt||
                         '; END;'
       USING OUT x_items_tbl, p_rel_type_code, p_org_id, p_prod_lst, p_msite_id, p_msite_id, p_top_section_id;
     END IF;

   ELSE -- Cannot use bulk fetching

      IF include_mtl THEN
                IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('relationship in MTL. Top Section Id ' || To_CHAR(p_top_section_id));
                END IF;
                IF (p_top_section_id IS NULL OR p_incl_section IS NULL) THEN
                    --no Section Filtering, only Minisite Filtering
                   OPEN l_rel_items_csr FOR
                                           l_with_mtl_stmt1  ||
                                           l_minisite_stmt   ||
                                           l_with_mtl_stmt4  ||
                                           ')'
                   USING p_rel_type_code, p_org_id, p_prod_lst, p_msite_id, p_rel_type_code, p_prod_lst;
               ELSIF (p_incl_section = FND_API.G_TRUE) THEN
                   --Include Items in top Section and Minisite
                   OPEN l_rel_items_csr FOR
                                           l_with_mtl_stmt1        ||
                                           l_minisite_section_stmt ||
                                           l_with_mtl_stmt4        ||
                                             ')'
                   USING p_rel_type_code, p_org_id, p_prod_lst, p_msite_id, p_top_section_id, p_rel_type_code, p_prod_lst;
               ELSE
                   --Include Items in Minisite but not in top section
                   OPEN l_rel_items_csr FOR
                                           l_with_mtl_stmt1               ||
                                           l_minisite_stmt                ||
                                           l_minisite_not_in_section_stmt ||
                                           l_with_mtl_stmt4               ||
                                           ')'
                   USING p_rel_type_code, p_org_id, p_prod_lst, p_msite_id, p_msite_id, p_top_section_id, p_rel_type_code, p_prod_lst;
               END IF;

       ELSE -- don't need to do union with mtl_related_items
         IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('p_max_ret_num is not NULL: relationship in MTL. Top Section Id ' || To_CHAR(p_top_section_id));
         END IF;

         IF (p_top_section_id IS NULL OR p_incl_section IS NULL) THEN
             --no Section Filtering, only Minisite Filtering
             OPEN l_rel_items_csr FOR
                                    l_without_mtl_stmt ||
                                    l_minisite_stmt
             USING p_rel_type_code, p_org_id, p_prod_lst, p_msite_id;
         ELSIF (p_incl_section = FND_API.G_TRUE) THEN
             --Include Items in top Section and Minisite
             OPEN l_rel_items_csr FOR
                                    l_without_mtl_stmt     ||
                                    l_minisite_section_stmt
             USING p_rel_type_code, p_org_id, p_prod_lst, p_msite_id, p_top_section_id;
         ELSE
             --Include Items in Minisite but not in top section
             OPEN l_rel_items_csr FOR
                                    l_without_mtl_stmt             ||
                                    l_minisite_stmt                ||
                                    l_minisite_not_in_section_stmt
             USING p_rel_type_code, p_org_id, p_prod_lst, p_msite_id, p_msite_id, p_top_section_id;
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

    IF (AMS_DEBUG_HIGH_ON) THEN



    AMS_UTILITY_PVT.debug_message('No of items collected ' || To_CHAR(x_items_tbl.COUNT));

    END IF;

   -- End of API body.

   IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelatedItems ends');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END getRelatedItems;

-- Start of comments
--    API name   : Get_Related_Items
--    Type       : Public or Group or Private.
--    Function   :
--    Pre-reqs   : None.
--    Parameters :
--    Notes      : Note text
--
-- End of comments
PROCEDURE getRelatedItems(
   p_api_version_number      IN         NUMBER                      ,
   p_init_msg_list    IN         VARCHAR2  := FND_API.G_FALSE,
   p_application_id   IN         NUMBER                      ,
   p_prod_lst         IN         JTF_NUMBER_TABLE            ,
   p_rel_type_code    IN         VARCHAR2                    ,
   p_org_id           IN         NUMBER                      ,
   p_max_ret_num      IN         NUMBER    := NULL           ,
   p_order_by_clause  IN         VARCHAR2  := NULL           ,
   x_items_tbl        OUT NOCOPY JTF_Number_Table            ,
   x_return_status    OUT NOCOPY VARCHAR2                    ,
   x_msg_count        OUT NOCOPY NUMBER                      ,
   x_msg_data         OUT NOCOPY VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)   := 'getRelatedItems';
   l_api_version   CONSTANT NUMBER         := 1.0;

   l_without_mtl_stmt VARCHAR2(3000) :=
' SELECT DISTINCT ICRI.related_item_id
  FROM ibe_ct_related_items ICRI,
      mtl_system_items_b   MSIB
  WHERE ICRI.relation_type_code = :rel_type_code1
   AND NOT EXISTS( SELECT NULL
                   FROM ibe_ct_rel_exclusions ICRE
                   WHERE ICRE.relation_type_code = ICRI.relation_type_code
                     AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                     AND ICRE.related_item_id    = ICRI.related_item_id )
   AND MSIB.organization_id   = :org_id2
   AND MSIB.inventory_item_id = ICRI.related_item_id
   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
   AND MSIB.web_status        = ''PUBLISHED''
   AND ICRI.inventory_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_with_mtl_stmt1 VARCHAR2(2500) :=

' SELECT DISTINCT ICRI.related_item_id
  FROM ibe_ct_related_items ICRI,
      mtl_system_items_b   MSIB
  WHERE ICRI.relation_type_code = :rel_type_code1
   AND MSIB.organization_id    = :org_id2
   AND MSIB.inventory_item_id  = ICRI.related_item_id
   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
   AND MSIB.web_status         = ''PUBLISHED''
   AND ICRI.inventory_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';


   l_with_mtl_stmt2 VARCHAR2(3000) :=
' UNION ALL
 SELECT MRI.related_item_id
 FROM mtl_related_items  MRI,
      mtl_system_items_b MSIB
 WHERE MRI.relationship_type_id = DECODE(:rel_type_code5, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                                  3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                                  7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                                  11, ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
   AND MSIB.organization_id     = :org_id7
   AND MSIB.inventory_item_id   = MRI.related_item_id
   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
   AND MSIB.web_status          = ''PUBLISHED''
   AND MRI.inventory_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_with_mtl_stmt3 VARCHAR2(3000) :=
' UNION ALL
  SELECT MRI.inventory_item_id
  FROM mtl_related_items MRI,
      mtl_system_items_b MSIB
  WHERE MRI.relationship_type_id = DECODE(:rel_type_code9, ''RELATED'', 1, ''SUBSTITUTE'', 2, ''CROSS_SELL'',
                                  3, ''UP_SELL'', 4, ''SERVICE'', 5, ''PREREQUISITE'', 6, ''COLLATERAL'',
                                  7, ''SUPERSEDED'', 8, ''COMPLIMENTARY'', 9, ''IMPACT'', 10, ''CONFLICT'',
                                  11, ''MANDATORY_CHARGE'', 12, ''OPTIONAL_CHARGE'', 13, ''PROMOTIONAL_UPGRADE'' ,14)
   AND MSIB.organization_id     = :org_id11
   AND MSIB.inventory_item_id   = MRI.inventory_item_id
   AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
   AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
   AND MSIB.web_status          = ''PUBLISHED''
   AND MRI.reciprocal_flag      = ''Y''
   AND MRI.related_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_with_mtl_stmt4 VARCHAR2(2000) :=
' MINUS
  SELECT ICRE.related_item_id
  FROM ibe_ct_rel_exclusions ICRE
  WHERE ICRE.relation_type_code = :rel_type_code13
   AND ICRE.inventory_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_without_mtl_bulk_stmt VARCHAR2(2500) :=
'BEGIN
    SELECT DISTINCT ICRI.related_item_id
    BULK COLLECT INTO :items_tbl1
    FROM ibe_ct_related_items ICRI,
         mtl_system_items_b   MSIB
    WHERE ICRI.relation_type_code = :rel_type_code2
      AND NOT EXISTS( SELECT NULL
                      FROM ibe_ct_rel_exclusions ICRE
                      WHERE ICRE.relation_type_code = ICRI.relation_type_code
                        AND ICRE.inventory_item_id  = ICRI.inventory_item_id
                        AND ICRE.related_item_id    = ICRI.related_item_id )
      AND MSIB.organization_id   = :org_id4
      AND MSIB.inventory_item_id = ICRI.related_item_id
      AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
      AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
      AND MSIB.web_status        = ''PUBLISHED''
      AND ICRI.inventory_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_stmt          VARCHAR2(2000);
   l_rel_items_csr prod_cursor;
   l_rel_item_id   NUMBER;
   l_sql_stmt      VARCHAR2(2000);
   l_bind_arg_num  PLS_INTEGER;
   l_dummy         VARCHAR2(30);
   i               PLS_INTEGER        := 1;
   include_mtl     BOOLEAN;
   p_index  BINARY_INTEGER;
   l_items_in_clause  VARCHAR2(32760);


BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelatedItems starts');

   END IF;

   --  Initialize the return value table
   x_items_tbl := JTF_Number_Table();

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('p_org_id : p_rel_type_code = '
                  || TO_CHAR(p_org_id) || ' : ' || p_rel_type_code);
   END IF;
-- Commented IN Clause BugFix 3776065
 -- p_Index := p_prod_lst.FIRST;
 -- FOR pNum IN 1..( p_prod_lst.COUNT - 1 ) LOOP
 --   l_items_in_clause := l_items_in_clause || TO_CHAR( p_prod_lst( p_Index ) ) || ', ';
 --   p_Index := p_prod_lst.NEXT( p_Index );
 -- END LOOP;

 -- p_Index := p_prod_lst.LAST;
 -- l_items_in_clause := l_items_in_clause || TO_CHAR( p_prod_lst( p_Index ) ) || ')';

   -- API body

  -- 1. Get the related items from ibe_ct_related_items table

  include_mtl := Exists_In_MTL(p_rel_type_code);

  IF (p_max_ret_num IS NULL) AND (NOT include_mtl) THEN -- Can use bulk fetching
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message(' p_max_ret_num is NULL: relationship NOT in MTL.', FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR);
      END IF;

       EXECUTE IMMEDIATE l_without_mtl_bulk_stmt  ||
                         '; END;'
      USING OUT x_items_tbl, p_rel_type_code, p_org_id ,p_prod_lst;

  ELSE -- Cannot use bulk fetching
     IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message(' relationship in MTL.');
     END IF;

     IF include_mtl THEN -- must do union with mtl_related_items
         IF (AMS_DEBUG_HIGH_ON) THEN
           AMS_UTILITY_PVT.debug_message('Mapping rule: relationship in MTL.'||l_items_in_clause);
         END IF;

         OPEN l_rel_items_csr FOR l_with_mtl_stmt1  ||
                                  l_with_mtl_stmt2  ||
                                  l_with_mtl_stmt3  ||
                                  l_with_mtl_stmt4

               USING p_rel_type_code, p_org_id, p_prod_lst,
                     p_rel_type_code, p_org_id, p_prod_lst,
                     p_rel_type_code, p_org_id, p_prod_lst,
                     p_rel_type_code, p_prod_lst;

     ELSE -- don't need to do union with mtl_related_items
         IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_UTILITY_PVT.debug_message('p_max_ret_num is NOT NULL: relationship in MTL.');
         END IF;

               OPEN l_rel_items_csr FOR l_without_mtl_stmt
                                        USING p_rel_type_code, p_org_id, p_prod_lst;
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
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_UTILITY_PVT.debug_message('Loop ');
   END IF;
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

   -- End of API body.

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('Max ' || To_CHAR(p_max_ret_num));
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('No of items collected ' || To_CHAR(x_items_tbl.COUNT));
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelatedItems ends');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count => x_msg_count,
                             p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END getRelatedItems;


PROCEDURE sortRandom
(
   p_input_lst    IN    JTF_NUMBER_TABLE,
   p_max_ret_num  IN    NUMBER := NULL,
   x_output_lst   OUT NOCOPY JTF_Number_Table
)
IS
   l_input_lst  JTF_NUMBER_TABLE;
   l_randoms    JTF_NUMBER_TABLE;
   i            PLS_INTEGER  := 1;
   j            PLS_INTEGER  := 1;
   limit        PLS_INTEGER;
   temp         NUMBER;
BEGIN

  IF (AMS_DEBUG_HIGH_ON) THEN



  AMS_UTILITY_PVT.debug_message('random sorting starts');

  END IF;
  l_input_lst := JTF_NUMBER_TABLE();
  x_output_lst := JTF_NUMBER_TABLE();
  for i in 1..p_input_lst.COUNT
  loop
    l_input_lst.EXTEND;
    l_input_lst(i) := p_input_lst(i);
  end loop;

  l_randoms := JTF_NUMBER_TABLE();
  IF(p_input_lst.COUNT > 1) THEN

    --first generate all random numbers
    for i in 1..p_input_lst.COUNT
    loop
      l_randoms.EXTEND;
      l_randoms(i) := dbms_random.value;
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('random value '||to_char(l_randoms(i))||' for '||p_input_lst(i));
     END IF;
    end loop;

    -- then , do bubble sort the ids based on random numbers values
    -- outer loop
    for i in 1..p_input_lst.COUNT
    loop
      --inner loop
      limit := p_input_lst.COUNT-i+1;
      for j in 1..limit-1
      loop
        --exchange positions if greater
        IF(l_randoms(j) > l_randoms(j+1)) THEN
          temp := l_randoms(j);
          l_randoms(j) := l_randoms(j+1);
          l_randoms(j+1) := temp;

          temp := l_input_lst(j);
          l_input_lst(j) := l_input_lst(j+1);
          l_input_lst(j+1) := temp;
        END IF;
      end loop;
    end loop;
  ELSE
    null;
  END IF;

  --collect max no elements for random prioritization now
  IF(p_max_ret_num IS NULL) THEN
      x_output_lst := l_input_lst;
    ELSE
      IF(p_max_ret_num < l_input_lst.COUNT) THEN
        limit := p_max_ret_num;
      ELSE
        limit := l_input_lst.COUNT;
      END IF;
      for i in 1..limit
      loop
        x_output_lst.EXTEND;
        x_output_lst(i) := l_input_lst(i);
      end loop;
    END IF;
  IF (AMS_DEBUG_HIGH_ON) THEN

  AMS_UTILITY_PVT.debug_message('random sorting ends');
  END IF;
END sortRandom;


PROCEDURE getFilteredProdsFromList
        (p_api_version_number IN  NUMBER,
         p_init_msg_list      IN  VARCHAR2,
         p_application_id     IN  NUMBER,
         p_party_id           IN  NUMBER,
   	 p_cust_account_id	IN  NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	IN  VARCHAR2 := NULL,
         p_prod_lst             IN  JTF_NUMBER_TABLE,
         p_msite_id             IN  NUMBER := NULL,
         p_top_section_id       IN  NUMBER := NULL,
         p_org_id               IN  NUMBER,
         p_bus_prior            IN  VARCHAR2 := NULL,
         p_bus_prior_order      IN  VARCHAR2 := NULL,
         p_filter_ref_code      IN  VARCHAR2 := NULL,
         p_price_list_id        IN  NUMBER   := NULL,
         p_max_ret_num          IN  NUMBER := NULL,
         x_prod_lst             OUT NOCOPY JTF_Number_Table,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_count            OUT NOCOPY NUMBER,
         x_msg_data             OUT NOCOPY VARCHAR2
        )
IS
   l_api_name      CONSTANT VARCHAR2(30) := 'getFilteredProdsFromList';
   l_api_version   CONSTANT NUMBER := 1.0;

   l_minisite_bulk_stmt VARCHAR2(2500) :=
   'BEGIN  SELECT MSIB.inventory_item_id
     BULK COLLECT INTO :items_tbl1
        FROM mtl_system_items_b   MSIB,
             ams_iba_ms_items_denorm D
        WHERE MSIB.organization_id   = :org_id2
              AND MSIB.inventory_item_id = D.item_id
              AND D.MINISITE_ID = :msite_id3
              AND NVL(D.START_DATE_ACTIVE,SYSDATE) <= SYSDATE
              AND NVL(D.END_DATE_ACTIVE,SYSDATE) >= SYSDATE
              AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
              AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
              AND MSIB.web_status  = ''PUBLISHED''
              AND MSIB.inventory_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_minisite_stmt VARCHAR2(2500) :=
   'SELECT MSIB.inventory_item_id
        FROM mtl_system_items_b   MSIB,
             ams_iba_ms_items_denorm D
        WHERE MSIB.organization_id   = :org_id2
              AND MSIB.inventory_item_id = D.item_id
              AND D.MINISITE_ID = :msite_id3
              AND NVL(D.START_DATE_ACTIVE,SYSDATE) <= SYSDATE
              AND NVL(D.END_DATE_ACTIVE,SYSDATE) >= SYSDATE
              AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
              AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
              AND MSIB.web_status  = ''PUBLISHED''
              AND MSIB.inventory_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_minisite_section_stmt VARCHAR2(2000) :=
            ' AND D.top_section_id = :top_section_id3';

   l_minisite_not_in_section_stmt VARCHAR2(2000) :=
   ' AND MSIB.inventory_item_id NOT IN (
        SELECT D.item_id
        FROM ams_iba_ms_items_denorm D
        WHERE D.MINISITE_ID = :msite_id
        AND D.top_section_id = :top_section_id)';

   l_mtl_bulk_stmt VARCHAR2(2500) :=
   'BEGIN SELECT MSIB.inventory_item_id
        BULK COLLECT INTO :items_tbl1
        FROM  mtl_system_items_b   MSIB
        WHERE MSIB.organization_id   = :org_id2
              AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
              AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
              AND MSIB.web_status  = ''PUBLISHED''
              AND MSIB.inventory_item_id  IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_mtl_stmt VARCHAR2(2500) :=
   'SELECT MSIB.inventory_item_id
        FROM  mtl_system_items_b   MSIB
        WHERE MSIB.organization_id   = :org_id2
              AND NVL(MSIB.start_date_active, SYSDATE) <= SYSDATE
              AND NVL(MSIB.end_date_active, SYSDATE)   >= SYSDATE
              AND MSIB.web_status  = ''PUBLISHED''
              AND MSIB.inventory_item_id IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_prod_lst AS JTF_NUMBER_TABLE)) t)';

   l_stmt          VARCHAR2(2000);
   l_rel_items_csr prod_cursor;
   l_rel_item_id   NUMBER;
   l_items_in_clause  VARCHAR2(32760);
   l_prod_lst           JTF_NUMBER_TABLE;
   l_item_id   NUMBER;
   l_limit     NUMBER;
   p_index  BINARY_INTEGER;
   i        PLS_INTEGER := 1;
   l_random  NUMBER;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getFilteredProdsFromList starts');
   END IF;

   --  Initialize the return value table
   x_prod_lst := JTF_Number_Table();
   l_prod_lst := JTF_NUMBER_TABLE();
 -- Commented IN Clause BugFix 3776065
  -- p_Index := p_prod_lst.FIRST;
  -- FOR pNum IN 1..( p_prod_lst.COUNT - 1 ) LOOP
  --  l_items_in_clause := l_items_in_clause || TO_CHAR( p_prod_lst( p_Index ) ) || ', ';
  --  p_Index := p_prod_lst.NEXT( p_Index );
  -- END LOOP;

  -- p_Index := p_prod_lst.LAST;
  -- l_items_in_clause := l_items_in_clause || TO_CHAR( p_prod_lst( p_Index ) ) || ')';

  -- IF (AMS_DEBUG_HIGH_ON) THEN
   -- AMS_UTILITY_PVT.debug_message('items in clause '||l_items_in_clause);
  -- END IF;

  IF(p_max_ret_num IS NULL) THEN
      --max return no is null

      IF(p_msite_id IS NOT NULL) THEN
          IF(p_top_section_id IS NOT NULL) THEN
              IF(p_filter_ref_code IS NULL ) THEN
                  --only Minisite filtering, no top section filtering

                  EXECUTE IMMEDIATE l_minisite_bulk_stmt  ||
                                    '; END;'
                  USING OUT l_prod_lst, p_org_id, p_msite_id, p_prod_lst;
              ELSIF (p_filter_ref_code = 'INCL_PROD_SECTION') THEN
                  --Both Minisite and include top section  filtering

                  EXECUTE IMMEDIATE l_minisite_bulk_stmt  ||
                                    l_minisite_section_stmt  ||
                                    '; END;'
                  USING OUT l_prod_lst, p_org_id, p_msite_id, p_prod_lst, p_top_section_id;
              ELSIF(p_filter_ref_code = 'EXCL_PROD_SECTION') THEN
              --exclude top section in filtering

                  EXECUTE IMMEDIATE l_minisite_bulk_stmt           ||
                                    l_minisite_section_stmt        ||
                                    l_minisite_not_in_section_stmt ||
                                    '; END;'
                  USING OUT l_prod_lst, p_org_id, p_msite_id,p_prod_lst, p_top_section_id, p_msite_id, p_top_section_id;
              END IF;
         ELSE
            --only minisite filtering
            EXECUTE IMMEDIATE l_minisite_bulk_stmt  ||
                              '; END;'
            USING OUT l_prod_lst, p_org_id, p_msite_id ,p_prod_lst;
         END IF;
      ELSE
         --no minisite filtering

         EXECUTE IMMEDIATE l_mtl_bulk_stmt        ||
                           '; END;'
         USING OUT l_prod_lst, p_org_id ,p_prod_lst;
      END IF;

  ELSE
      --max return no is non-null

      IF(p_msite_id IS NOT NULL) THEN
          IF(p_top_section_id IS NOT NULL) THEN
              IF(p_filter_ref_code IS NULL) THEN
                  --only Minisite filtering, no top section filtering

               OPEN l_rel_items_csr FOR l_minisite_stmt
               USING p_org_id, p_msite_id ,p_prod_lst;

              ELSIF(p_filter_ref_code = 'INCL_PROD_SECTION') THEN
                  --include top section in filering

               OPEN l_rel_items_csr FOR l_minisite_stmt   ||
                                        l_minisite_section_stmt
               USING p_org_id, p_msite_id,p_prod_lst, p_top_section_id;
              ELSIF(p_filter_ref_code = 'EXCL_PROD_SECTION') THEN
                --exclude top section in filtering

                 OPEN l_rel_items_csr FOR l_minisite_stmt   ||
                                        l_minisite_section_stmt ||
                                        l_minisite_not_in_section_stmt
                 USING p_org_id, p_msite_id, p_prod_lst, p_top_section_id, p_msite_id, p_top_section_id;
              END IF;
         ELSE
            --only minisite filtering
               OPEN l_rel_items_csr FOR l_minisite_stmt
                  USING p_org_id, p_msite_id ,p_prod_lst;
         END IF;
      ELSE
         --no minisite filtering

         OPEN l_rel_items_csr FOR l_mtl_stmt
         USING p_org_id,p_prod_lst;
      END IF;

      IF (p_max_ret_num IS NULL OR p_bus_prior = 'RANDOM'
           OR (p_bus_prior = 'PROD_LIST_PRICE' AND p_price_list_id IS NOT NULL)) THEN
        IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_UTILITY_PVT.debug_message('random');
        END IF;
        LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               l_prod_lst.EXTEND;
               l_prod_lst(i) := l_rel_item_id;
               i := i + 1;
         END LOOP;
     ELSE
         LOOP
               FETCH l_rel_items_csr INTO l_rel_item_id;
               EXIT WHEN l_rel_items_csr%NOTFOUND;
               l_prod_lst.EXTEND;
               l_prod_lst(i) := l_rel_item_id;
               i := i + 1;

               IF i > p_max_ret_num THEN
                  EXIT;
               END IF;
         END LOOP;
     END IF;

   CLOSE l_rel_items_csr;
  END IF;

   -- 4. Get Prioritized Products if any Product Priority is given
   IF(p_bus_prior = 'PROD_LIST_PRICE' AND p_price_list_id IS NOT NULL) THEN
    getPrioritizedProds(
        p_api_version_number
        , FND_API.G_FALSE
        , p_application_id
        , p_party_id
   	, p_cust_account_id
	, p_currency_code
        , l_prod_lst
        , p_org_id
        , p_bus_prior
        , p_bus_prior_order
        , p_price_list_id
        , p_max_ret_num
        , x_prod_lst
        , x_return_status
        , x_msg_count
        , x_msg_data
      );
   ELSIF(p_bus_prior = 'RANDOM') THEN
     sortRandom(
            l_prod_lst,
            p_max_ret_num,
            x_prod_lst
          );
   ELSE
     x_prod_lst := l_prod_lst;
  END IF;

  -- End of API body.

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getFilteredProdsFromList ends');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count => x_msg_count,
                             p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END getFilteredProdsFromList;



PROCEDURE getRelProdsForQuoteAndCust
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	 p_cust_account_id	IN    NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	IN   VARCHAR2 := NULL,
         p_quote_id             IN    NUMBER,
         p_msite_id             IN    NUMBER,
         p_top_section_id       IN    NUMBER,
         p_org_id               IN    NUMBER,
         p_rel_type_code        IN    VARCHAR2,
         p_bus_prior            IN    VARCHAR2,
         p_bus_prior_order      IN    VARCHAR2,
         p_filter_ref_code      IN    VARCHAR2,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER := NULL,
         x_prod_lst             OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        )
IS
   l_api_name      CONSTANT VARCHAR2(30) := 'getRelProdsForQuoteAndCust';
   l_api_version   CONSTANT NUMBER       := 1.0;

   l_return_status      VARCHAR2( 10 );
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2( 1000 );
   l_quote_prod_lst     JTF_NUMBER_TABLE;
   l_prod_lst           JTF_NUMBER_TABLE;
   l_null      CHAR(1);
   l_incl_top_section VARCHAR2(1) := NULL;
   l_item_id NUMBER;
   l_random  NUMBER;
   l_max     NUMBER;
   l_limit   NUMBER;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelProdsForQuoteAndCust starts');
   END IF;

   -- API body
   -- 1. Check if the relationship exists and is active
   IF NOT Is_Relationship_Valid(p_rel_type_code) THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Relationship is not valid.');
      END IF;
      FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_VALID');
      FND_MESSAGE.Set_Token('RELATIONSHIP', p_rel_type_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_filter_ref_code = 'INCL_PROD_SECTION') THEN
     l_incl_top_section := FND_API.G_TRUE;
   ELSIF(p_filter_ref_code = 'EXCL_PROD_SECTION') THEN
     l_incl_top_section := FND_API.G_FALSE;
   END IF;

   IF(p_bus_prior = 'RANDOM'
      OR (p_bus_prior = 'PROD_LIST_PRICE' AND p_price_list_id IS NOT NULL)) THEN
     l_max := NULL;
   ELSE
     l_max := p_max_ret_num;
   END IF;

   -- 2. Collect Shopping Cart items
  -- GetXSellForQuote Start
  l_quote_prod_lst := JTF_NUMBER_TABLE();

  select inventory_item_id
    bulk collect into l_quote_prod_lst
    from aso_quote_lines_all_v
   where quote_header_id = p_quote_id;

  IF SQL%ROWCOUNT = 0 THEN
    x_prod_lst := JTF_Number_Table();
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('No Items found for Quote Id : '||TO_CHAR(p_quote_id));
    END IF;
  ELSIF l_quote_prod_lst.COUNT = 0 THEN
    x_prod_lst := JTF_Number_Table();
    IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('No Items found for Quote Id : '||TO_CHAR(p_quote_id));
    END IF;
  ELSE
    -- 3. Collect related items
    IF (p_msite_id IS NULL) THEN
        EXECUTE IMMEDIATE 'BEGIN AMS_RUNTIME_PROD_PVT.getRelatedItems( :1, :2, :3, :4, :5,
         :6, :7, :8, :9, :10, :11, :12 ); END;'
        USING IN l_api_version, IN FND_API.G_FALSE,
              IN p_application_id, IN l_quote_prod_lst,
              IN p_rel_type_code, IN p_org_id,
              IN l_max, IN l_null,
              OUT l_prod_lst,
              OUT l_return_status, OUT l_msg_count, OUT l_msg_data;
    ELSE
       EXECUTE IMMEDIATE 'BEGIN AMS_RUNTIME_PROD_PVT.getRelatedItems( :1, :2, :3, :4, :5,
         :6, :7, :8, :9, :10, :11, :12, :13, :14, :15 ); END;'
        USING IN l_api_version, IN FND_API.G_FALSE,
              IN p_application_id, IN p_msite_id,
              IN p_top_section_id, IN l_incl_top_section,
              IN l_quote_prod_lst, IN p_rel_type_code,
              IN p_org_id, IN l_max,
              IN l_null, OUT l_prod_lst,
              OUT l_return_status, OUT l_msg_count, OUT l_msg_data;
    END IF;

    -- 4. Get Prioritized Products if any Product Priority is given
    IF(p_bus_prior = 'PROD_LIST_PRICE' AND p_price_list_id IS NOT NULL) THEN
      getPrioritizedProds(
        p_api_version_number
        , FND_API.G_FALSE
        , p_application_id
        , p_party_id
   	, p_cust_account_id
	, p_currency_code
        , l_prod_lst
        , p_org_id
        , p_bus_prior
        , p_bus_prior_order
        , p_price_list_id
        , p_max_ret_num
        , x_prod_lst
        , x_return_status
        , x_msg_count
        , x_msg_data
      );
   ELSIF(p_bus_prior = 'RANDOM') THEN
     sortRandom(
            l_prod_lst,
            p_max_ret_num,
            x_prod_lst
          );
   ELSE
     x_prod_lst := l_prod_lst;
   END IF;

 END IF;

  -- End of API body.

 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelProdsForQuoteAndCust ends');
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                           p_count => x_msg_count,
                           p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

END getRelProdsForQuoteAndCust;



PROCEDURE getRelProdsForProdAndCust
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	   p_cust_account_id	  IN    NUMBER := FND_API.G_MISS_NUM,
	   p_currency_code	  IN 	  VARCHAR2 := NULL,
         p_prod_lst             IN    JTF_NUMBER_TABLE,
         p_msite_id             IN    NUMBER,
         p_top_section_id       IN    NUMBER,
         p_org_id               IN    NUMBER,
         p_rel_type_code        IN    VARCHAR2,
         p_bus_prior            IN    VARCHAR2,
         p_bus_prior_order      IN    VARCHAR2,
         p_filter_ref_code      IN    VARCHAR2,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER := NULL,
         x_prod_lst             OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        )
IS
   l_api_name      CONSTANT VARCHAR2(30)   := 'getRelProdsForProdAndCust';
   l_api_version   CONSTANT NUMBER         := 1.0;

   l_return_status      VARCHAR2( 10 );
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2( 1000 );
   l_prod_lst           JTF_NUMBER_TABLE;
   l_null      CHAR(1);
   l_incl_top_section VARCHAR2(1)          := NULL;
   l_item_id NUMBER;
   l_random  NUMBER;
   l_max     NUMBER;
   l_limit   NUMBER;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelProdsForProdAndCust starts');
   END IF;

   -- API body
   -- 1. Check if the relationship exists and is active
   IF NOT Is_Relationship_Valid(p_rel_type_code) THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_UTILITY_PVT.debug_message('Relationship is not valid.');
      END IF;
      FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_VALID');
      FND_MESSAGE.Set_Token('RELATIONSHIP', p_rel_type_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_filter_ref_code = 'INCL_PROD_SECTION') THEN
     l_incl_top_section := FND_API.G_TRUE;
   ELSIF(p_filter_ref_code = 'EXCL_PROD_SECTION') THEN
     l_incl_top_section := FND_API.G_FALSE;
   END IF;

   IF(p_bus_prior = 'RANDOM'
      OR (p_bus_prior = 'PROD_LIST_PRICE' AND p_price_list_id IS NOT NULL)) THEN
     l_max := NULL;
   ELSE
     l_max := p_max_ret_num;
   END IF;

   -- 2. Collect related items
   IF (p_msite_id IS NULL) THEN
       EXECUTE IMMEDIATE 'BEGIN AMS_RUNTIME_PROD_PVT.getRelatedItems( :1, :2, :3, :4, :5,
         :6, :7, :8, :9, :10, :11, :12 ); END;'
        USING IN l_api_version, IN FND_API.G_FALSE,
              IN p_application_id, IN p_prod_lst,
              IN p_rel_type_code, IN p_org_id,
              IN l_max, IN l_null,
              OUT l_prod_lst,
              OUT l_return_status, OUT l_msg_count, OUT l_msg_data;
   ELSE
       EXECUTE IMMEDIATE 'BEGIN AMS_RUNTIME_PROD_PVT.getRelatedItems( :1, :2, :3, :4, :5,
         :6, :7, :8, :9, :10, :11, :12, :13, :14, :15 ); END;'
        USING IN l_api_version, IN FND_API.G_FALSE,
              IN p_application_id, IN p_msite_id,
              IN p_top_section_id, IN l_incl_top_section,
              IN p_prod_lst, IN p_rel_type_code,
              IN p_org_id, IN l_max,
              IN l_null, OUT l_prod_lst,
              OUT l_return_status, OUT l_msg_count, OUT l_msg_data;
   END IF;

   -- 3. Get Prioritized Products if any Product Priority is given
   IF(p_bus_prior = 'PROD_LIST_PRICE' AND p_price_list_id IS NOT NULL) THEN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('Calling Price priority');
     END IF;
     getPrioritizedProds(
       p_api_version_number
       , FND_API.G_FALSE
       , p_application_id
       , p_party_id
       , p_cust_account_id
       , p_currency_code
       , l_prod_lst
       , p_org_id
       , p_bus_prior
       , p_bus_prior_order
       , p_price_list_id
       , p_max_ret_num
       , x_prod_lst
       , x_return_status
       , x_msg_count
       , x_msg_data
     );
   ELSIF(p_bus_prior = 'RANDOM') THEN
     sortRandom(
            l_prod_lst,
            p_max_ret_num,
            x_prod_lst
          );
    ELSE
      x_prod_lst := l_prod_lst;
    END IF;

  -- End of API body.


   IF (AMS_DEBUG_HIGH_ON) THEN





   AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelProdsForProdAndCust ends');


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

END getRelProdsForProdAndCust;


PROCEDURE getPrioritizedProds
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	 p_cust_account_id	IN    NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	IN 	VARCHAR2 := NULL,
         p_prod_lst             IN    JTF_NUMBER_TABLE,
         p_org_id               IN    NUMBER,
         p_bus_prior            IN    VARCHAR2,
         p_bus_prior_order      IN    VARCHAR2,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER := NULL,
         x_prod_lst             OUT NOCOPY JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_count            OUT NOCOPY NUMBER,
         x_msg_data             OUT NOCOPY VARCHAR2
        )
IS
   l_api_name      CONSTANT VARCHAR2(30) := 'getPrioritizedProds';
   l_api_version   CONSTANT NUMBER       := 1.0;

   l_price_stmt VARCHAR2(2500) :=
   'SELECT TO_NUMBER(PA.product_attr_value)
        FROM  qp_list_lines PL,
              qp_pricing_attributes PA
        WHERE PA.list_header_id = :price_list_id
              AND PL.list_line_id = PA.list_line_id
              AND PA.product_attr_value IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_in_prod_lst AS JTF_VARCHAR2_TABLE_100)) t)';


   l_return_status      VARCHAR2( 10 );
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2( 1000 );
   l_items_csr          prod_cursor;
   l_item_id            NUMBER;
   l_order              VARCHAR2(10);
   l_items_in_clause    VARCHAR2(32760);
   l_index              BINARY_INTEGER;
   ll_index             BINARY_INTEGER;
   i                    PLS_INTEGER := 1;
   j                    PLS_INTEGER := 1;
   found                BOOLEAN;
   p_in_prod_lst        JTF_VARCHAR2_TABLE_100;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getPrioritizedProds starts');
   END IF;

   IF(p_bus_prior_order IS NULL OR p_bus_prior_order = 'ASC' OR p_bus_prior_order <> 'DESC') THEN
     l_order := 'ASC';
   ELSE
     l_order := 'DESC';
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('Order of Sorting is : '||l_order);
   END IF;

   x_prod_lst := JTF_Number_Table();
   p_in_prod_lst := JTF_VARCHAR2_TABLE_100();

   IF(p_bus_prior = 'PROD_LIST_PRICE' AND p_price_list_id IS NOT NULL AND p_prod_lst.COUNT > 1) THEN
     IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('sort Products by Product List Price in order '||l_order);
     END IF;
    -- Commented IN Clause BugFix 3776065
    -- l_Index := p_prod_lst.FIRST;
    -- FOR pNum IN 1..( p_prod_lst.COUNT - 1 ) LOOP
    --   l_items_in_clause := l_items_in_clause  || '''' || TO_CHAR( p_prod_lst( l_index ) ) || '''' || ', ';
    --   l_Index := p_prod_lst.NEXT( l_index );
    -- END LOOP;

    -- l_Index := p_prod_lst.LAST;
    -- l_items_in_clause := l_items_in_clause || '''' || TO_CHAR( p_prod_lst( l_index ) ) || '''' || ')';


      FOR j IN 1..p_prod_lst.COUNT LOOP
	    p_in_prod_lst(j) := p_prod_lst(j);
      END LOOP;

      OPEN l_items_csr FOR l_price_stmt               ||
                        ' order by PL.list_price ' ||
                          l_order
     USING p_price_list_id , p_in_prod_lst;

     -- IF (AMS_DEBUG_HIGH_ON) THEN
       -- AMS_UTILITY_PVT.debug_message('item list '||l_items_in_clause);
     -- END IF;

      i := 1;
      IF p_max_ret_num IS NULL THEN
        -- take all returned items in output prod list
        LOOP
               FETCH l_items_csr INTO l_item_id;
               EXIT WHEN l_items_csr%NOTFOUND;
               x_prod_lst.EXTEND;
               x_prod_lst(i) := l_item_id;
               i := i + 1;
         END LOOP;
      ELSE
         -- takes only required no. of items in output list
         LOOP
               FETCH l_items_csr INTO l_item_id;
               EXIT WHEN l_items_csr%NOTFOUND;
               x_prod_lst.EXTEND;
               x_prod_lst(i) := l_item_id;
               i := i + 1;

               IF i > p_max_ret_num THEN
                  EXIT;
               END IF;
         END LOOP;
     END IF;

     CLOSE l_items_csr;

   END IF;

   -- in the output list we might have fewer items than max
   -- because either
   -- 1. No Sorting was done
   -- 2. There is no Price for some items - hence we received
   --    fewer items than passed in.

   i := 1;
   j := x_prod_lst.COUNT;
   IF (x_prod_lst.COUNT <> p_prod_lst.COUNT) THEN
     IF p_max_ret_num IS NULL THEN
       -- there is no max
       l_index := p_prod_lst.FIRST;
       FOR pNum IN 1..( p_prod_lst.COUNT ) LOOP
         l_item_id := p_prod_lst(l_index);
         found := FALSE;

         ll_index := x_prod_lst.FIRST;
         FOR ppNum IN 1..(x_prod_lst.COUNT) LOOP
           IF (l_item_id = x_prod_lst(ll_index)) THEN
             -- item found in output list
             found := TRUE;
             EXIT;
           END IF;
           ll_Index := x_prod_lst.NEXT( ll_Index );
         END LOOP;

         IF(found = FALSE) THEN
           -- item missing in output list, so put it there
           x_prod_lst.EXTEND;
           x_prod_lst(i) := l_item_id;
           i := i + 1;
         END IF;

         l_index := p_prod_lst.NEXT( l_index );
       END LOOP;
     ELSIF (j < p_max_ret_num) THEN
       -- there is max
       l_index := p_prod_lst.FIRST;
       FOR pNum IN 1..( p_prod_lst.COUNT ) LOOP
         l_item_id := p_prod_lst(l_index);
         found := FALSE;

         ll_index := x_prod_lst.FIRST;
         FOR ppNum IN 1..(x_prod_lst.COUNT) LOOP
           IF (l_item_id = x_prod_lst(ll_index)) THEN
             -- item foun din output list
             found := TRUE;
             EXIT;
           END IF;
           ll_Index := x_prod_lst.NEXT( ll_Index );
         END LOOP;

         IF(found = FALSE) THEN
           -- item missing in output list, so put it there
           x_prod_lst.EXTEND;
           x_prod_lst(i) := l_item_id;
           i := i + 1;
         END IF;

         IF i > p_max_ret_num THEN
           EXIT;
         END IF;

         l_index := p_prod_lst.NEXT( l_index );
       END LOOP;

     END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getPrioritizedProds ends');
   END IF;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count => x_msg_count,
                             p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END getPrioritizedProds;


procedure loadItemDetails
(p_api_version    IN  NUMBER,
    p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE,
    p_application_id  IN  NUMBER,
    p_party_id         IN  NUMBER,
    p_cust_account_id	 IN  NUMBER := FND_API.G_MISS_NUM,
	p_currency_code	     IN  VARCHAR2 := NULL,
	p_itmid_tbl 		IN  JTF_NUMBER_TABLE,
	p_organization_id	IN  NUMBER,
	p_category_set_id	IN  NUMBER,
	p_retrieve_price      IN  VARCHAR2 := FND_API.G_FALSE,
	p_price_list_id	      IN  NUMBER := NULL,
	p_price_request_type  IN  VARCHAR2 := NULL,
 	p_price_event	      IN  VARCHAR2 := NULL,
	x_item_csr	OUT NOCOPY prod_cursor,
	x_category_id_csr	OUT NOCOPY prod_cursor,
	x_listprice_tbl	      OUT nocopy JTF_NUMBER_TABLE,
	x_bestprice_tbl	      OUT nocopy JTF_NUMBER_TABLE,
	x_price_status_code_tbl	OUT nocopy JTF_VARCHAR2_TABLE_100,
	x_price_status_text_tbl	OUT nocopy JTF_VARCHAR2_TABLE_300,
	x_price_return_status	 OUT NOCOPY VARCHAR2,
	x_price_return_status_text OUT NOCOPY VARCHAR2,
     	x_item_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2
)
IS
   l_api_name      CONSTANT VARCHAR2(30)   := 'loadItemDetails';
   l_api_version   CONSTANT NUMBER         := 1.0;

   cursor l_uom_csr(l_itmid NUMBER) IS
     select MSIV.primary_uom_code
     from mtl_system_items_vl MSIV
     where MSIV.inventory_item_id = l_itmid;

   l_item_stmt VARCHAR2(4000) :=
   'SELECT MSIV.INVENTORY_ITEM_ID, MSIV.CONCATENATED_SEGMENTS,' ||
    ' MSIV.ORDERABLE_ON_WEB_FLAG, MSIV.PRIMARY_UNIT_OF_MEASURE,' ||
    ' MSIV.PRIMARY_UOM_CODE, MSIV.DESCRIPTION, MSIV.LONG_DESCRIPTION,' ||
    ' MSIV.MINIMUM_ORDER_QUANTITY, MSIV.MAXIMUM_ORDER_QUANTITY' ||
    ' FROM MTL_SYSTEM_ITEMS_VL MSIV ' ||
    ' WHERE MSIV.ORGANIZATION_ID = :org_id' ||
    ' AND MSIV.WEB_STATUS = ''PUBLISHED'''||
    ' AND NVL(MSIV.START_DATE_ACTIVE, SYSDATE) <= SYSDATE ' ||
    ' AND NVL(MSIV.END_DATE_ACTIVE, SYSDATE) >= SYSDATE '   ||
    ' AND MSIV.INVENTORY_ITEM_ID IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_itmid_tbl AS JTF_NUMBER_TABLE)) t)';

   l_category_stmt VARCHAR2(4000) :=
   'SELECT MSIV.INVENTORY_ITEM_ID, MIC.CATEGORY_ID' ||
   ' FROM MTL_SYSTEM_ITEMS_VL MSIV, MTL_ITEM_CATEGORIES MIC' ||
   ' WHERE MSIV.ORGANIZATION_ID = :org_id' ||
   ' AND NVL(MSIV.START_DATE_ACTIVE, SYSDATE) <= SYSDATE' ||
   ' AND NVL(MSIV.END_DATE_ACTIVE, SYSDATE) >= SYSDATE' ||
   ' AND MSIV.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID' ||
   ' AND MSIV.ORGANIZATION_ID = MIC.ORGANIZATION_ID' ||
   ' AND MIC.CATEGORY_SET_ID = :category_set' ||
   ' AND MSIV.INVENTORY_ITEM_ID IN (SELECT t.COLUMN_VALUE FROM TABLE(CAST(:p_itmid_tbl AS JTF_NUMBER_TABLE)) t)';

   i      PLS_INTEGER := 1;
   found  BOOLEAN;
   l_items_in_clause    VARCHAR2(32760);
   l_itmid_tbl		JTF_NUMBER_TABLE;
   l_index              BINARY_INTEGER;
   l_itmid		NUMBER;
   l_uomcode		VARCHAR2(3);
   l_uomcode_tbl	JTF_VARCHAR2_TABLE_100;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_item_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.loadItemDetails starts');
   END IF;


   IF p_itmid_tbl.COUNT = 0 THEN
     IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_UTILITY_PVT.debug_message('No Products returned');
    END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.loadItemDetails ends');
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data     );
    return;
   END IF;
-- Commented IN Clause BugFix 3776065
  -- l_Index := p_itmid_tbl.FIRST;
  -- FOR pNum IN 1..( p_itmid_tbl.COUNT - 1 ) LOOP
  --   l_items_in_clause := l_items_in_clause || TO_CHAR( p_itmid_tbl( l_index ) ) || ', ';
  --   l_Index := p_itmid_tbl.NEXT( l_index );
  -- END LOOP;

  -- l_Index := p_itmid_tbl.LAST;
  -- l_items_in_clause := l_items_in_clause || TO_CHAR( p_itmid_tbl( l_index ) ) || ')';

    -- open the item cursor for return
    OPEN x_item_csr FOR l_item_stmt
                 USING p_organization_id,p_itmid_tbl;

    -- open category id cursor for return if category set id is not null
    IF (p_category_set_id IS NOT NULL) THEN
	OPEN x_category_id_csr FOR l_category_stmt
           USING p_organization_id, p_category_set_id,p_itmid_tbl;
    END IF;

    -- calls pricing engine APIs if retrieve price is true
    IF FND_API.to_Boolean(p_retrieve_price) THEN

	l_uomcode_tbl := JTF_VARCHAR2_TABLE_100();

      FOR l_Index IN 1..p_itmid_tbl.COUNT LOOP

        --opens uom cursor to build uom table
        l_itmid := p_itmid_tbl(l_Index);
    	  OPEN l_uom_csr(l_itmid);
	  FETCH l_uom_csr INTO l_uomcode;
	  l_uomcode_tbl.EXTEND;
	  IF l_uom_csr%FOUND THEN
	    l_uomcode_tbl(l_Index) := l_uomcode;
  	  ELSE
	    l_uomcode_tbl(l_Index) := FND_API.G_MISS_CHAR;
	  END IF;
	  CLOSE l_uom_csr;

      END LOOP;

      l_itmid_tbl := p_itmid_tbl;

	-- now prepare for the pricing call
	x_listprice_tbl := NULL;
	x_bestprice_tbl := NULL;
	x_price_status_code_tbl := NULL;
	x_price_status_text_tbl := NULL;

      -- call to Get Prices from qp
      AMS_PRICE_PVT.GetPrices
		(p_price_list_id, p_party_id, p_cust_account_id, p_currency_code, l_itmid_tbl,
             l_uomcode_tbl, p_price_request_type,
		 p_price_event, x_listprice_tbl, x_bestprice_tbl, x_price_status_code_tbl,
                 x_price_status_text_tbl, x_price_return_status, x_price_return_status_text);

    END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.loadItemDetails ends');
   END IF;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count => x_msg_count,
                             p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_item_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_item_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


   WHEN OTHERS THEN
      x_item_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END loadItemDetails;

-- web lite code starts here


PROCEDURE getRelProdsForCart
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	 p_cust_account_id	IN    NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	IN   VARCHAR2 := NULL,
         p_quote_id             IN    NUMBER,
         p_msite_id             IN    NUMBER,
         p_top_section_id       IN    NUMBER,
         p_org_id               IN    NUMBER,
         p_rel_type_code        IN    VARCHAR2,
         p_max_ret_num          IN    NUMBER := NULL,
         x_prod_lst             OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        )
IS
   l_api_name      CONSTANT VARCHAR2(30) := 'getRelProdsForQuoteAndCust';
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_return_status      VARCHAR2( 10 );
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2( 1000 );
   l_quote_prod_lst     JTF_NUMBER_TABLE;
   l_prod_lst           JTF_NUMBER_TABLE;
   l_null      CHAR(1);
   l_incl_top_section VARCHAR2(1) := NULL;
   l_item_id NUMBER;
   l_random  NUMBER;
   l_max     NUMBER;
   l_limit   NUMBER;
   l_index   BINARY_INTEGER;


BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelProdsForCart starts');
   END IF;


   -- API body

   -- 1. Check if the relationship exists and is active

   IF NOT Is_Relationship_Valid(p_rel_type_code) THEN

      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Relationship is not valid.');
      END IF;
	      FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_VALID');
	      FND_MESSAGE.Set_Token('RELATIONSHIP', p_rel_type_code);
	      FND_MSG_PUB.Add;
	      RAISE FND_API.G_EXC_ERROR;
   END IF;

     l_max := p_max_ret_num;

   -- 2. Collect Shopping Cart items

   -- GetXSellForQuote Start

	  l_quote_prod_lst := JTF_NUMBER_TABLE();
	   select inventory_item_id
	    bulk collect into l_quote_prod_lst
	    from aso_quote_lines_all_v
	   where quote_header_id = p_quote_id;

      IF (SQL%ROWCOUNT = 0) THEN
	    x_prod_lst := JTF_Number_Table();
	    IF (AMS_DEBUG_HIGH_ON) THEN
		    AMS_UTILITY_PVT.debug_message('No Items found for Quote Id : '||TO_CHAR(p_quote_id));
	    END IF;

      ELSIF (l_quote_prod_lst.COUNT = 0) THEN
	    x_prod_lst := JTF_Number_Table();
	    IF (AMS_DEBUG_HIGH_ON) THEN
		    AMS_UTILITY_PVT.debug_message('No Items found for Quote Id : '||TO_CHAR(p_quote_id));
	    END IF;
      ELSE
    -- 3. Collect related items
	IF (p_msite_id IS NULL) THEN
        EXECUTE IMMEDIATE 'BEGIN AMS_RUNTIME_PROD_PVT.getRelatedItems( :1, :2, :3, :4, :5,
         :6, :7, :8, :9, :10, :11, :12 ); END;'
        USING IN l_api_version, IN FND_API.G_FALSE,
              IN p_application_id, IN l_quote_prod_lst,
              IN p_rel_type_code, IN p_org_id,
              IN l_max, IN l_null,
              OUT l_prod_lst,
              OUT l_return_status, OUT l_msg_count, OUT l_msg_data;
      ELSE
       EXECUTE IMMEDIATE 'BEGIN AMS_RUNTIME_PROD_PVT.getRelatedItems( :1, :2, :3, :4, :5,
         :6, :7, :8, :9, :10, :11, :12, :13, :14, :15 ); END;'
        USING IN l_api_version, IN FND_API.G_FALSE,
              IN p_application_id, IN p_msite_id,
              IN p_top_section_id, IN l_incl_top_section,
              IN l_quote_prod_lst, IN p_rel_type_code,
              IN p_org_id, IN l_max,
              IN l_null, OUT l_prod_lst,
              OUT l_return_status, OUT l_msg_count, OUT l_msg_data;
       END IF;


      -- l_index := l_prod_lst.FIRST;
      -- FOR pNum IN 1..l_max LOOP
        --    x_prod_lst := l_prod_lst( l_index );
	  --  l_index := l_prod_lst.NEXT( l_index );
      -- END LOOP;

      x_prod_lst := l_prod_lst;

       END IF;

   -- End of API body.


 IF (AMS_DEBUG_HIGH_ON) THEN
   AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelProdsForQuoteAndCust ends');
 END IF;

 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                           p_count => x_msg_count,
                           p_data  => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                  l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data     );

END getRelProdsForCart;



PROCEDURE getRelProdsForProd
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	 p_cust_account_id	  IN    NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	  IN 	  VARCHAR2 := NULL,
         p_prod_lst             IN    JTF_NUMBER_TABLE,
         p_msite_id             IN    NUMBER,
         p_top_section_id       IN    NUMBER,
         p_org_id               IN    NUMBER,
         p_rel_type_code        IN    VARCHAR2,
         p_max_ret_num          IN    NUMBER := NULL,
         x_prod_lst             OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        )
IS
   l_api_name      CONSTANT VARCHAR2(30)   := 'getRelProdsForProd';
   l_api_version   CONSTANT NUMBER         := 1.0;

   l_return_status      VARCHAR2( 10 );
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2( 1000 );
   l_prod_lst           JTF_NUMBER_TABLE;
   l_null      CHAR(1);
   l_incl_top_section VARCHAR2(1)          := NULL;
   l_item_id NUMBER;
   l_random  NUMBER;
   l_max     NUMBER;
   l_limit   NUMBER;
   l_index   BINARY_INTEGER;

BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
  -- x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (AMS_DEBUG_HIGH_ON) THEN
     AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelProdsForProd starts');
   END IF;

   -- API body
   -- 1. Check if the relationship exists and is active
   IF NOT Is_Relationship_Valid(p_rel_type_code) THEN
      IF (AMS_DEBUG_HIGH_ON) THEN
            AMS_UTILITY_PVT.debug_message('Relationship is not valid.');
      END IF;

      FND_MESSAGE.Set_Name('IBE', 'IBE_CT_REL_NOT_VALID');
      FND_MESSAGE.Set_Token('RELATIONSHIP', p_rel_type_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;

   END IF;

    l_max := p_max_ret_num;

   -- 2. Collect related items

   IF (p_msite_id IS NULL) THEN

  EXECUTE IMMEDIATE 'BEGIN AMS_RUNTIME_PROD_PVT.getRelatedItems( :1, :2, :3, :4, :5,:6, :7, :8, :9, :10, :11, :12 ); END;'
        USING IN l_api_version, IN FND_API.G_FALSE,
             IN p_application_id, IN p_prod_lst,
            IN p_rel_type_code, IN p_org_id,
            IN l_max, IN l_null,
            OUT l_prod_lst,
            OUT l_return_status, OUT l_msg_count, OUT l_msg_data;

     ELSE

  EXECUTE IMMEDIATE 'BEGIN AMS_RUNTIME_PROD_PVT.getRelatedItems( :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15 ); END;'
        USING IN l_api_version, IN FND_API.G_FALSE,
             IN p_application_id, IN p_msite_id,
              IN p_top_section_id, IN l_incl_top_section,
              IN p_prod_lst, IN p_rel_type_code,
              IN p_org_id, IN l_max,
              IN l_null, OUT l_prod_lst,
              OUT l_return_status, OUT l_msg_count, OUT l_msg_data;
  END IF;

      -- l_index := l_prod_lst.FIRST;
      -- FOR pNum IN 1..l_max LOOP
        --    x_prod_lst := l_prod_lst( l_index );
	   --l_index := l_prod_lst.NEXT( l_index );
      -- END LOOP;

   x_prod_lst := l_prod_lst;

  -- End of API body.


   IF (AMS_DEBUG_HIGH_ON) THEN
      AMS_UTILITY_PVT.debug_message('AMS_RUNTIME_PROD_PVT.getRelProdsForProdAndCust ends');
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



END getRelProdsForProd;


-- web lite code Ends here

END AMS_RUNTIME_PROD_PVT;

/
