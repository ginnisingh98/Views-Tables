--------------------------------------------------------
--  DDL for Package Body EDW_ITEMS_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_ITEMS_M_C" AS
/* $Header: ENICITMB.pls 120.3 2006/04/03 06:44:02 lparihar noship $ */

  l_collect_onetime         VARCHAR2(10) := NULL;
  l_push_date_range1        DATE := NULL;
  l_push_date_range2        DATE := NULL;
  l_item_catset1_name       VARCHAR2(40) := NULL;
  l_item_func_area1_id      NUMBER := 2;
  l_item_catset2_name       VARCHAR2(40) := NULL;
  l_item_func_area2_id      NUMBER := NULL;
  l_item_catset3_name       VARCHAR2(40) := NULL;
  l_item_func_area3_id      NUMBER := NULL;
  l_itemorg_catset1_name    VARCHAR2(40) := NULL;
  l_itemorg_func_area1_id   NUMBER := NULL;
  l_itm_hrchy3_coll_type    VARCHAR2(30) := NULL;
  l_itm_hrchy3_vbh_top_node VARCHAR2(30) := NULL;
  l_instance                VARCHAR2(240) := NULL;
  g_row_count               NUMBER := 0;
  g_EXCEPTION_message       VARCHAR2(10000) := NULL;
  g_error_message           VARCHAR2(2000) := NULL;
  l_column_exists           NUMBER;

PROCEDURE Set_Category_Sets IS
BEGIN
  SELECT DECODE(ITEM_CATEGORY_SET1, NULL, 'NA_EDW', ITEM_CATEGORY_SET1),
         DECODE(ITEM_CATEGORY_SET2, NULL, 'NA_EDW', ITEM_CATEGORY_SET2),
         DECODE(ITEM_CATEGORY_SET3, NULL, 'NA_EDW', ITEM_CATEGORY_SET3),
         DECODE(ITEM_ORG_CATEGORY_SET1, NULL, 'NA_EDW', ITEM_ORG_CATEGORY_SET1),
         DECODE(ITM_HRCHY3_COLL_TYPE, NULL, 'NA_EDW', ITM_HRCHY3_COLL_TYPE),
         DECODE(ITM_HRCHY3_VBH_TOP_NODE, NULL, 'NA_EDW', ITM_HRCHY3_VBH_TOP_NODE)
    INTO l_item_catset1_name,
         l_item_catset2_name,
         l_item_catset3_name,
         l_itemorg_catset1_name,
         l_itm_hrchy3_coll_type,
         l_itm_hrchy3_vbh_top_node
    FROM EDW_LOCAL_SYSTEM_PARAMETERS;

    -- If collection is using VBH then use the VBH Category Set Name
    -- for Category Set3
    IF l_itm_hrchy3_coll_type = 'V' THEN
      SELECT CATEGORY_SET_NAME
      INTO l_item_catset3_name
      FROM MTL_CATEGORY_SETS_VL
      WHERE CATEGORY_SET_ID = g_vbh_catset_id;
    END IF;

  EXCEPTION WHEN OTHERS THEN
    RAISE;
    COMMIT;
END;

FUNCTION Get_Functional_Area (p_category_set_name VARCHAR2)
                RETURN NUMBER IS
  l_functional_area_id NUMBER := NULL;
BEGIN
  edw_log.put_line('Getting functional area for ' || p_category_set_name);
  IF p_category_set_name <> 'NA_EDW' THEN
    SELECT mtd.functional_area_id
      INTO l_functional_area_id
    FROM mtl_category_sets mcs,
         mtl_default_category_sets mtd
    WHERE mcs.category_set_name = p_category_set_name
      AND mcs.category_set_id = mtd.category_set_id;
  END IF;
  RETURN l_functional_area_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    RAISE;
    COMMIT;
END;

PROCEDURE Push(Errbuf            out  NOCOPY VARCHAR2,
               Retcode           out  NOCOPY VARCHAR2,
               p_from_date       IN   VARCHAR2,
               p_to_date         IN   VARCHAR2) IS

  l_FROM_date              DATE;
  l_to_date                DATE;
  l_onetime_profile_option VARCHAR2(100);
  l_temp                   VARCHAR2(1);

  CURSOR l_instance_csr IS
    SELECT instance_code
    FROM EDW_LOCAL_INSTANCE;

  -- Cursor to figure out the items having same name with diff. ids
  CURSOR c_mult_item IS
  SELECT
    mti.concatenated_segments,
    mti.organization_id,
    COUNT(mti.inventory_item_id)
  FROM
    mtl_system_items_kfv mti
  GROUP BY
     mti.concatenated_segments,
     mti.organization_id
  HAVING COUNT(inventory_item_id) > 1;

  -- This cursor is dependent on cursor c_mult_item. This
  -- will only print out the item ids that have the same name
  CURSOR c_item_id(l_name varchar2, l_org_id number) IS
  SELECT
    inventory_item_id,
    organization_id
  FROM
    mtl_system_items_kfv
  WHERE concatenated_segments = l_name
    AND organization_id = l_org_id;

BEGIN
  Errbuf :=NULL;
  Retcode:=NULL;
  IF (Not EDW_COLLECTION_UTIL.setup('EDW_ITEMS_M')) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR(-20000,'Error in SETUP: ' || errbuf);
  END IF;

-- Date processing

  SELECT TO_DATE(p_from_date, 'YYYY/MM/DD HH24:MI:SS'),
         TO_DATE(p_to_date,'YYYY/MM/DD HH24:MI:SS')
    INTO l_FROM_date, l_to_date FROM DUAL;
  --l_FROM_date :=

  --l_to_date := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

  -- Should onetime items be collected?
  IF fnd_profile.defined('ENI:COLLECT_ONETIME')
  THEN
    l_collect_onetime := fnd_profile.value('ENI:COLLECT_ONETIME');
  ELSE
    l_collect_onetime := 'Y';
  END IF;

  l_push_date_range1:= NVL(l_FROM_date,EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  l_push_date_range2:= NVL(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
  edw_log.put_line( 'The collection range is FROM '||
      TO_CHAR(l_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
      TO_CHAR(l_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
  edw_log.put_line(' ');

  Set_Category_Sets;
  edw_log.put_line( 'The category sets are ' ||
      l_item_catset1_name || ', ' ||
      l_item_catset2_name || ', ' ||
      l_item_catset3_name || ', ' ||
      l_itm_hrchy3_coll_type || ',' ||
      l_itm_hrchy3_vbh_top_node || ',' ||
      l_itemorg_catset1_name);
  edw_log.put_line(' ');


  -- Validation checks

   l_temp := 'N';
   edw_log.put_line('');
   edw_log.put_line('----------------------------------------------');
   edw_log.put_line('Checking for multiple items with the same name');
   edw_log.put_line('----------------------------------------------');

   FOR c4 in c_mult_item LOOP
    l_temp := 'Y';
    edw_log.put_line(c4.concatenated_segments);
    retcode := 1;
    errbuf := 'Items names need to be unique. Ensure that item names that failed the test are unique in the system';
    RAISE_APPLICATION_ERROR(-20000,'Error in VALIDATION: ' || errbuf);
   END LOOP;

   IF l_temp = 'N' then
    edw_log.put_line('----- None -----');
   END IF;

  -- fetching instance code into local variable

  FOR l_instance_rec IN l_instance_csr LOOP
   l_instance := l_instance_rec.instance_code;
  END LOOP;

/* -- May be supported in future release
  l_item_func_area1_id := Get_Functional_Area(l_item_catset1_name);
  l_item_func_area2_id := Get_Functional_Area(l_item_catset2_name);
  l_item_func_area3_id := Get_Functional_Area(l_item_catset3_name);
  l_itemorg_func_area1_id := Get_Functional_Area(l_itemorg_catset1_name);
*/
  edw_log.put_line('Pushing Data');
  /*
  Push_EDW_ITEM_ITEMREV(l_push_date_range1, l_push_date_range2);
  */
  Push_EDW_ITEM_PRDFAM(l_push_date_range1, l_push_date_range2);
  Push_EDW_ITEM_ITEMORG(l_push_date_range1, l_push_date_range2);
  Push_EDW_ITEM_ITEM(l_push_date_range1, l_push_date_range2);
  Push_EDW_ITEM_ITEMORG_CAT(l_push_date_range1, l_push_date_range2);
  Push_EDW_ITEM_ITEM_CAT(l_push_date_range1, l_push_date_range2);
  Push_EDW_ITEM_PROD_LINE(l_push_date_range1, l_push_date_range2);
  Push_EDW_ITEM_PROD_CATG(l_push_date_range1, l_push_date_range2);
  Push_EDW_ITEM_PROD_GRP(l_push_date_range1, l_push_date_range2);

  EDW_COLLECTION_UTIL.wrapup(TRUE, EDW_ITEMS_M_C.g_row_count,NULL, l_push_date_range1,l_push_date_range2);
  COMMIT;

EXCEPTION WHEN OTHERS THEN
  IF g_error_message IS NULL THEN
    Errbuf := sqlerrm;
    Retcode := sqlcode;
    EDW_ITEMS_M_C.g_EXCEPTION_message := EDW_ITEMS_M_C.g_EXCEPTION_message||' <> '||Retcode||' : '||Errbuf;
  ELSE
    Retcode := 2;
    g_error_message := 'ERROR: ' || g_error_message;
    EDW_ITEMS_M_C.g_EXCEPTION_message := EDW_ITEMS_M_C.g_EXCEPTION_message||
      ' <> 2 : '|| g_error_message;
    Errbuf := g_error_message;
  END IF;
  ROLLBACK;
  EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_ITEMS_M_C.g_EXCEPTION_message,l_push_date_range1, l_push_date_range2);
  COMMIT;

END Push;

PROCEDURE Push_EDW_ITEM_ITEMREV(
                p_from_date  IN   DATE,
                p_to_date    IN   DATE) IS
  l_staging_table_name    VARCHAR2(30) :='EDW_ITEM_ITEMREV_LSTG'  ;
  L_PUSH_DATE_RANGE1      DATE:=NULL;
  L_PUSH_DATE_RANGE2      DATE:=NULL;
  l_rows_inserted         NUMBER:=0;

BEGIN

  l_push_date_range1:=p_from_date;
  l_push_date_range2:=p_to_date;

  edw_log.put_line(' ');
  edw_log.put_line('Pushing EDW_ITEM_ITEMREV');

  INSERT INTO EDW_ITEM_ITEMREV_LSTG(
    CREATION_DATE,
    EFFECTIVE_DATE,
    ERROR_CODE,
    INSTANCE,
    ITEM_ORG_FK,
    ITEM_ORG_FK_KEY,
    ITEM_REVISION,
    ITEM_REVISION_DP,
    ITEM_REVISION_PK,
    LAST_UPDATE_DATE,
    LEVEL_NAME,
    NAME,
    REQUEST_ID,
    ROW_ID,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
  SELECT
    CREATION_DATE,
    EFFECTIVE_DATE,
    NULL, --ERROR_CODE,
    INSTANCE,
    ITEM_ORG_FK,
    NULL, --ITEM_ORG_FK_KEY,
    SUBSTRB(ITEM_REVISION, 1, 240),
    SUBSTRB(ITEM_REVISION_DP, 1, 240),
    ITEM_REVISION_PK,
    LAST_UPDATE_DATE,
    NULL, --LEVEL_NAME,
    SUBSTRB(NAME, 1, 320),
    NULL, --REQUEST_ID,
    NULL, --ROW_ID,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY'
  FROM EDW_ITEM_ITEMREV_LCV
  WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;

  l_rows_inserted := SQL%ROWCOUNT;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
       ' rows into the staging table');
  edw_log.put_line(' ');

  EDW_ITEMS_M_C.g_row_count:=EDW_ITEMS_M_C.g_row_count+l_rows_inserted;
  COMMIT;

EXCEPTION WHEN OTHERS THEN
  RAISE;
  COMMIT;
END Push_EDW_ITEM_ITEMREV;

PROCEDURE Push_EDW_ITEM_PRDFAM(
                p_from_date  IN   DATE,
                p_to_date    IN   DATE) IS
  l_staging_table_name      VARCHAR2(30) :='EDW_ITEM_PRDFAM_LSTG'  ;
  L_PUSH_DATE_RANGE1        DATE := NULL;
  L_PUSH_DATE_RANGE2        DATE := NULL;
  l_rows_inserted           NUMBER := 0;

BEGIN

  l_push_date_range1 := p_from_date;
  l_push_date_range2 := p_to_date;

  edw_log.put_line(' ');
  edw_log.put_line('Pushing EDW_ITEM_PRDFAM');

  INSERT INTO EDW_ITEM_PRDFAM_LSTG(
    ALL_FK,
    ALL_FK_KEY,
    DESCRIPTION,
    ERROR_CODE,
    INSTANCE,
    NAME,
    PRODUCT_FAMILY,
    PROD_FAMILY_DP,
    PROD_FAMILY_PK,
    REQUEST_ID,
    ROW_ID,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS,
    CREATION_DATE,
    LAST_UPDATE_DATE)
  SELECT
    ALL_FK,
    NULL, --ALL_FK_KEY,
    DESCRIPTION,
    NULL, --ERROR_CODE,
    l_instance, --INSTANCE, /* Bug# 2558245 */
    SUBSTRB(NAME, 1, 320),
    PRODUCT_FAMILY,
    PROD_FAMILY_DP,
    PROD_FAMILY_PK || '-' || l_instance, --     PROD_FAMILY_PK, /* Bug# 2558245 */
    NULL, --REQUEST_ID,
    NULL, --ROW_ID,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY',
    CREATION_DATE,
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PRDFAM_LCV
  WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;
  l_rows_inserted := SQL%ROWCOUNT;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
       ' rows into the staging table');
  edw_log.put_line(' ');

  COMMIT;

EXCEPTION WHEN OTHERS THEN
  RAISE;
  COMMIT;
END Push_EDW_ITEM_PRDFAM;

PROCEDURE Push_EDW_ITEM_ITEMORG(
                p_from_date  IN   DATE,
                p_to_date    IN   DATE) IS

 l_staging_table_name       VARCHAR2(30) :='EDW_ITEM_ITEMORG_LSTG'  ;
 L_PUSH_DATE_RANGE1         DATE := NULL;
 L_PUSH_DATE_RANGE2         DATE := NULL;
 l_rows_inserted            NUMBER := 0;
 l_commit_count             NUMBER := 0;
 l_item_revision_pk         VARCHAR2(320) :='NA_EDW';
 l_all_revisions            VARCHAR2(320) := NULL;
 number_of_records          NUMBER := 0;
 -- l_instance VARCHAR2(240) := NULL; /* Bug# 2558245 */
 l_all_item_revs            VARCHAR2(100);

 /*  Bug# 2558245
 CURSOR l_instance_csr is
   SELECT instance_code
   FROM edw_local_instance;
 */

  CURSOR category_assignments_cursor IS  /* Bug# 2197243 */
    SELECT
      MIC.INVENTORY_ITEM_ID,
      MIC.ORGANIZATION_ID
    FROM
      MTL_CATEGORIES CAT,
      MTL_ITEM_CATEGORIES MIC,
      MTL_CATEGORY_SETS SETS
    WHERE CAT.CATEGORY_ID = MIC.CATEGORY_ID
      AND MIC.CATEGORY_SET_ID = SETS.CATEGORY_SET_ID
      AND MIC.LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date
      AND SETS.CATEGORY_SET_NAME = l_itemorg_catset1_name;

  category_assignments_rec   category_assignments_cursor%ROWTYPE;

BEGIN

  l_all_item_revs := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_IREV');

  l_push_date_range1 := p_from_date;
  l_push_date_range2 := p_to_date;

  -- Added function call to -lookup- the ALL level based on
  -- EDW requirements. By AS on 05/22/00

/* Bug# 2558245
  for l_instance_rec in l_instance_csr loop
    l_instance := l_instance_rec.instance_code;
  end loop;
*/

  edw_log.put_line(' ');
  edw_log.put_line('Pushing EDW_ITEM_ITEMORG records in TEMP table');

  l_rows_inserted := 0;
  l_commit_count := 0;

   INSERT INTO EDW_ITEM_ITEMORG_TEMP(
     APPROVED_SUPPLIER,
     BUYER_FK,
     CREATION_DATE,
     CATSET_CATEGORY_FK,
     CATSET_CATEGORY_FK_KEY,
     DESCRIPTION,
     ERROR_CODE,
     EXPRS_DELIVERY,
     HAZARD_CLASS_ID,
     INSP_REQUIRED,
     INSTANCE,
     INTERNAL_ORD_FLAG,
     INV_PLANNING_CODE,
     ITEM_NUMBER,
     ITEM_NUMBER_FK,
     ITEM_NUMBER_FK_KEY,
     ITEM_ORG_DP,
     ITEM_ORG_PK,
     INVENTORY_ITEM_ID,
     ORGANIZATION_ID,
     LAST_UPDATE_DATE,
     LOCATOR_CONTROL,
     EFFECTIVITY_CONTROL,
     LOT_CONTROL,
     MAKE_OR_BUY_FLAG,
     MARKET_PRICE,
     MRP_PLN_METHOD,
     NAME,
     ONE_TIME_FLAG,
     OUTSIDE_OP_FLAG,
     PLANNER_FK,
     PRICE_TOL_PERCENT,
     PROD_FAMILY_FK,
     PROD_FAMILY_FK_KEY,
     PURCHASABLE_FLAG,
     RECEIPT_REQUIRED,
     REQUEST_ID,
     REVISION_CONTROL,
     RFQ_REQUIRED_FLAG,
     ROW_ID,
     SERIAL_CONTROL,
     SHELF_LIFE_CODE,
     SHELF_LIFE_DAYS,
     STOCKABLE_FLAG,
     SUBSTITUTE_RCPT,
     TAXABLE_FLAG,
     TAX_CODE,
     UNIT_LIST_PRICE,
     UNORDERED_RCPT,
     UN_NUMBER_ID,
     SEGMENT1,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     OPERATION_CODE,
     COLLECTION_STATUS,
     ITEM_TYPE) /* Enh# 2544906 */
   SELECT
     APPROVED_SUPPLIER,
     BUYER_FK,
     CREATION_DATE,
     CATSET_CATEGORY_FK,
     INVENTORY_ITEM_ID, --CATSET_CATEGORY_FK_KEY,
     DESCRIPTION,
     NULL, --ERROR_CODE,
     EXPRS_DELIVERY,
     HAZARD_CLASS_ID,
     INSP_REQUIRED,
     l_instance,
     INTERNAL_ORD_FLAG,
     SUBSTRB(INV_PLANNING_CODE, 1, 40),
     SUBSTRB(ITEM_NUMBER, 1, 240),
     ITEM_NUMBER_FK || '-' || l_instance, --  ITEM_NUMBER_FK, /* Bug# 2558245 */
     NULL, --ITEM_NUMBER_FK_KEY,
     SUBSTRB(ITEM_ORG_DP, 1, 240),
     ITEM_ORG_PK || '-' || l_instance, --     ITEM_ORG_PK, /* Bug# 2558245 */
     INVENTORY_ITEM_ID,
     ORGANIZATION_ID,
     LAST_UPDATE_DATE,
     LOCATOR_CONTROL,
     EFFECTIVITY_CONTROL,
     LOT_CONTROL,
     SUBSTRB(MAKE_OR_BUY_FLAG, 1, 40),
     MARKET_PRICE,
     MRP_PLN_METHOD,
     SUBSTRB(NAME, 1, 320),
     NULL, --ONE_TIME_FLAG,
     OUTSIDE_OP_FLAG,
     PLANNER_FK,
     PRICE_TOL_PERCENT,
     PROD_FAMILY_FK,
     ORGANIZATION_ID, --PROD_FAMILY_FK_KEY,
     PURCHASABLE_FLAG,
     RECEIPT_REQUIRED,
     NULL, --REQUEST_ID,
     REVISION_CONTROL,
     RFQ_REQUIRED_FLAG,
     NULL, --ROW_ID,
     SERIAL_CONTROL,
     SHELF_LIFE_CODE,
     SHELF_LIFE_DAYS,
     STOCKABLE_FLAG,
     SUBSTITUTE_RCPT,
     TAXABLE_FLAG,
     TAX_CODE,
     UNIT_LIST_PRICE,
     UNORDERED_RCPT,
     UN_NUMBER_ID,
     SEGMENT1,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     NULL, -- OPERATION_CODE
     'READY',
     ITEM_TYPE   /* Enh# 2544906 */
   FROM EDW_ITEM_ITEMORG_LCV
   WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;

   l_rows_inserted := SQL%ROWCOUNT;
   edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
         ' rows into the staging table');

   /* Bug 2197243 */
   /** Need to INSERT additional items for whom the category assignments
    ** have changed.
   */

   edw_log.put_line('Inserting additional items due to category changes ');

   OPEN category_assignments_cursor;
   LOOP
     FETCH category_assignments_cursor INTO category_assignments_rec;
     EXIT WHEN category_assignments_cursor%NOTFOUND;

     INSERT INTO EDW_ITEM_ITEMORG_TEMP(
       APPROVED_SUPPLIER,
       BUYER_FK,
       CREATION_DATE,
       CATSET_CATEGORY_FK,
       CATSET_CATEGORY_FK_KEY,
       DESCRIPTION,
       ERROR_CODE,
       EXPRS_DELIVERY,
       HAZARD_CLASS_ID,
       INSP_REQUIRED,
       INSTANCE,
       INTERNAL_ORD_FLAG,
       INV_PLANNING_CODE,
       ITEM_NUMBER,
       ITEM_NUMBER_FK,
       ITEM_NUMBER_FK_KEY,
       ITEM_ORG_DP,
       ITEM_ORG_PK,
       INVENTORY_ITEM_ID,
       ORGANIZATION_ID,
       LAST_UPDATE_DATE,
       LOCATOR_CONTROL,
       EFFECTIVITY_CONTROL,
       LOT_CONTROL,
       MAKE_OR_BUY_FLAG,
       MARKET_PRICE,
       MRP_PLN_METHOD,
       NAME,
       ONE_TIME_FLAG,
       OUTSIDE_OP_FLAG,
       PLANNER_FK,
       PRICE_TOL_PERCENT,
       PROD_FAMILY_FK,
       PROD_FAMILY_FK_KEY,
       PURCHASABLE_FLAG,
       RECEIPT_REQUIRED,
       REQUEST_ID,
       REVISION_CONTROL,
       RFQ_REQUIRED_FLAG,
       ROW_ID,
       SERIAL_CONTROL,
       SHELF_LIFE_CODE,
       SHELF_LIFE_DAYS,
       STOCKABLE_FLAG,
       SUBSTITUTE_RCPT,
       TAXABLE_FLAG,
       TAX_CODE,
       UNIT_LIST_PRICE,
       UNORDERED_RCPT,
       UN_NUMBER_ID,
       SEGMENT1,
       USER_ATTRIBUTE1,
       USER_ATTRIBUTE2,
       USER_ATTRIBUTE3,
       USER_ATTRIBUTE4,
       USER_ATTRIBUTE5,
       OPERATION_CODE,
       COLLECTION_STATUS,
       ITEM_TYPE)  /* Enh# 2544906 */
     SELECT
       APPROVED_SUPPLIER,
       BUYER_FK,
       CREATION_DATE,
       CATSET_CATEGORY_FK,
       INVENTORY_ITEM_ID, --CATSET_CATEGORY_FK_KEY,
       DESCRIPTION,
       NULL, --ERROR_CODE,
       EXPRS_DELIVERY,
       HAZARD_CLASS_ID,
       INSP_REQUIRED,
       l_instance,
       INTERNAL_ORD_FLAG,
       SUBSTRB(INV_PLANNING_CODE, 1, 40),
       SUBSTRB(ITEM_NUMBER, 1, 240),
       ITEM_NUMBER_FK || '-' || l_instance, --     ITEM_NUMBER_FK, /* Bug# 2558245 */
       NULL, --ITEM_NUMBER_FK_KEY,
       SUBSTRB(ITEM_ORG_DP, 1, 240),
       ITEM_ORG_PK || '-' || l_instance, --     ITEM_ORG_PK, /* Bug# 2558245 */
       INVENTORY_ITEM_ID,
       ORGANIZATION_ID,
       LAST_UPDATE_DATE,
       LOCATOR_CONTROL,
       EFFECTIVITY_CONTROL,
       LOT_CONTROL,
       SUBSTRB(MAKE_OR_BUY_FLAG, 1, 40),
       MARKET_PRICE,
       MRP_PLN_METHOD,
       SUBSTRB(NAME, 1, 320),
       NULL, --ONE_TIME_FLAG,
       OUTSIDE_OP_FLAG,
       PLANNER_FK,
       PRICE_TOL_PERCENT,
       PROD_FAMILY_FK,
       ORGANIZATION_ID, --PROD_FAMILY_FK_KEY,
       PURCHASABLE_FLAG,
       RECEIPT_REQUIRED,
       NULL, --REQUEST_ID,
       REVISION_CONTROL,
       RFQ_REQUIRED_FLAG,
       NULL, --ROW_ID,
       SERIAL_CONTROL,
       SHELF_LIFE_CODE,
       SHELF_LIFE_DAYS,
       STOCKABLE_FLAG,
       SUBSTITUTE_RCPT,
       TAXABLE_FLAG,
       TAX_CODE,
       UNIT_LIST_PRICE,
       UNORDERED_RCPT,
       UN_NUMBER_ID,
       SEGMENT1,
       USER_ATTRIBUTE1,
       USER_ATTRIBUTE2,
       USER_ATTRIBUTE3,
       USER_ATTRIBUTE4,
       USER_ATTRIBUTE5,
       NULL, -- OPERATION_CODE
       'READY',
       ITEM_TYPE   /* Enh# 2544906 */
     FROM EDW_ITEM_ITEMORG_LCV
     WHERE inventory_item_id = category_assignments_rec.inventory_item_id
       AND organization_id = category_assignments_rec.organization_id
       AND last_update_date NOT BETWEEN l_push_date_range1 AND l_push_date_range2; /* Bug# 2659263 */

   END LOOP;

   CLOSE category_assignments_cursor;
   edw_log.put_line('Done Inserting category changed items into item-org ');

   COMMIT;

   edw_log.put_line('Resolving category fks for staging table records');
   edw_log.put_line(' ');

/* Bug# 2631155 added DECODE by dsakalle */
/* Bug# 2559696 Removed the use of EDW_ITEMS_CATEGORY_FKV by dsakalle */

  UPDATE EDW_ITEM_ITEMORG_TEMP
  SET CATSET_CATEGORY_FK =
        (SELECT DECODE(COUNT(cat.category_id), 1, TO_CHAR(1)||'-'||MAX(cat.category_id) || '-' || l_instance, 'NA_EDW')
         FROM
           MTL_ITEM_CATEGORIES cat,
           MTL_CATEGORY_SETS_TL tl
         WHERE cat.organization_id = prod_family_fk_key
           AND cat.inventory_item_id = catset_category_fk_key
           AND tl.category_set_name = l_itemorg_catset1_name
           AND cat.category_set_id = tl.category_set_id
           AND tl.language = userenv('LANG')),
      PROD_FAMILY_FK =
          (SELECT DECODE(count(cat.category_id), 1, max(cat.category_id) || '-' || l_instance, 'NA_EDW')
           FROM
             MTL_ITEM_CATEGORIES cat,
             MTL_CATEGORY_SETS_TL tl
           WHERE cat.organization_id = prod_family_fk_key
             AND cat.inventory_item_id = catset_category_fk_key
             AND tl.category_set_name = 'Product Family'
             AND cat.category_set_id = tl.category_set_id
             AND tl.language = userenv('LANG'));

  COMMIT;

  edw_log.put_line('Resolving lookups for staging table records');
  edw_log.put_line(' ');

  UPDATE EDW_ITEM_ITEMORG_TEMP
  SET MAKE_OR_BUY_FLAG =
        (SELECT lkup.meaning
         FROM mfg_lookups lkup
         WHERE lkup.lookup_type = 'MTL_PLANNING_MAKE_BUY'
           AND lkup.lookup_code = TO_NUMBER(make_or_buy_flag)),
      LOCATOR_CONTROL =
        (SELECT lkup.meaning
         FROM mfg_lookups  lkup
         WHERE lkup.lookup_type = 'MTL_LOCATION_CONTROL'
           AND lkup.lookup_code = TO_NUMBER(locator_control)),
      EFFECTIVITY_CONTROL =
        (SELECT lkup.meaning
         FROM mfg_lookups  lkup
         WHERE lkup.lookup_type = 'MTL_EFFECTIVITY_CONTROL'
           AND lkup.lookup_code = TO_NUMBER(effectivity_control)),
      LOT_CONTROL =
        (SELECT lkup.meaning
         FROM mfg_lookups  lkup
         WHERE lkup.lookup_type = 'MTL_LOT_CONTROL'
           AND lkup.lookup_code = TO_NUMBER(lot_control)),
      INV_PLANNING_CODE =
        (SELECT lkup.meaning
         FROM mfg_lookups  lkup
         WHERE lkup.lookup_type = 'MTL_MATERIAL_PLANNING'
           AND lkup.lookup_code = TO_NUMBER(inv_planning_code)),
      MRP_PLN_METHOD =
        (SELECT lkup.meaning
         FROM mfg_lookups  lkup
         WHERE lkup.lookup_type = 'MRP_PLANNING_CODE'
           AND lkup.lookup_code = TO_NUMBER(mrp_pln_method)),
      REVISION_CONTROL =
        (SELECT lkup.meaning
         FROM mfg_lookups  lkup
         WHERE lkup.lookup_type = 'MTL_ENG_QUANTITY'
           AND lkup.lookup_code = TO_NUMBER(revision_control)),
      SHELF_LIFE_CODE =
        (SELECT lkup.meaning
         FROM mfg_lookups  lkup
         WHERE lkup.lookup_type = 'MTL_SHELF_LIFE'
           AND lkup.lookup_code = TO_NUMBER(shelf_life_code)),
      SERIAL_CONTROL =
        (SELECT lkup.meaning
         FROM mfg_lookups  lkup
         WHERE lkup.lookup_type = 'MTL_SERIAL_NUMBER'
           AND lkup.lookup_code = TO_NUMBER(serial_control)),
      CATSET_CATEGORY_FK_KEY = NULL,
      PROD_FAMILY_FK_KEY = NULL,
      CATSET_CATEGORY_FK = NVL(CATSET_CATEGORY_FK, 'NA_EDW'),
      PROD_FAMILY_FK = NVL(PROD_FAMILY_FK, 'NA_EDW');

  COMMIT;

  edw_log.put_line('Inserting TEMP table records into staging table');
  edw_log.put_line(' ');

  INSERT INTO EDW_ITEM_ITEMORG_LSTG(
    APPROVED_SUPPLIER,
    BUYER_FK,
    CREATION_DATE,
    CATSET_CATEGORY_FK,
    CATSET_CATEGORY_FK_KEY,
    DESCRIPTION,
    ERROR_CODE,
    EXPRS_DELIVERY,
    HAZARD_CLASS_ID,
    INSP_REQUIRED,
    INSTANCE,
    INTERNAL_ORD_FLAG,
    INV_PLANNING_CODE,
    ITEM_NUMBER,
    ITEM_NUMBER_FK,
    ITEM_NUMBER_FK_KEY,
    ITEM_ORG_DP,
    ITEM_ORG_PK,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    LAST_UPDATE_DATE,
    LOCATOR_CONTROL,
    EFFECTIVITY_CONTROL,
    LOT_CONTROL,
    MAKE_OR_BUY_FLAG,
    MARKET_PRICE,
    MRP_PLN_METHOD,
    NAME,
    ONE_TIME_FLAG,
    OUTSIDE_OP_FLAG,
    PLANNER_FK,
    PRICE_TOL_PERCENT,
    PROD_FAMILY_FK,
    PROD_FAMILY_FK_KEY,
    PURCHASABLE_FLAG,
    RECEIPT_REQUIRED,
    REQUEST_ID,
    REVISION_CONTROL,
    RFQ_REQUIRED_FLAG,
    ROW_ID,
    SERIAL_CONTROL,
    SHELF_LIFE_CODE,
    SHELF_LIFE_DAYS,
    STOCKABLE_FLAG,
    SUBSTITUTE_RCPT,
    TAXABLE_FLAG,
    TAX_CODE,
    UNIT_LIST_PRICE,
    UNORDERED_RCPT,
    UN_NUMBER_ID,
    SEGMENT1,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS,
    ITEM_TYPE)  /* Enh# 2544906 */
  SELECT
    APPROVED_SUPPLIER,
    BUYER_FK,
    CREATION_DATE,
    CATSET_CATEGORY_FK,
    CATSET_CATEGORY_FK_KEY, --CATSET_CATEGORY_FK_KEY,
    DESCRIPTION,
    NULL, --ERROR_CODE,
    EXPRS_DELIVERY,
    HAZARD_CLASS_ID,
    INSP_REQUIRED,
    INSTANCE,
    INTERNAL_ORD_FLAG,
    SUBSTRB(INV_PLANNING_CODE, 1, 40),
    SUBSTRB(ITEM_NUMBER, 1, 240),
    ITEM_NUMBER_FK,
    ITEM_NUMBER_FK_KEY, --ITEM_NUMBER_FK_KEY,
    SUBSTRB(ITEM_ORG_DP, 1, 240),
    ITEM_ORG_PK,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    LAST_UPDATE_DATE,
    LOCATOR_CONTROL,
    EFFECTIVITY_CONTROL,
    LOT_CONTROL,
    SUBSTRB(MAKE_OR_BUY_FLAG, 1, 40),
    MARKET_PRICE,
    MRP_PLN_METHOD,
    SUBSTRB(NAME, 1, 320),
    NULL, --ONE_TIME_FLAG,
    OUTSIDE_OP_FLAG,
    PLANNER_FK,
    PRICE_TOL_PERCENT,
    PROD_FAMILY_FK,
    PROD_FAMILY_FK_KEY, --PROD_FAMILY_FK_KEY,
    PURCHASABLE_FLAG,
    RECEIPT_REQUIRED,
    NULL, --REQUEST_ID,
    REVISION_CONTROL,
    RFQ_REQUIRED_FLAG,
    NULL, --ROW_ID,
    SERIAL_CONTROL,
    SHELF_LIFE_CODE,
    SHELF_LIFE_DAYS,
    STOCKABLE_FLAG,
    SUBSTITUTE_RCPT,
    TAXABLE_FLAG,
    TAX_CODE,
    UNIT_LIST_PRICE,
    UNORDERED_RCPT,
    UN_NUMBER_ID,
    SEGMENT1,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY',
    ITEM_TYPE   /* Enh# 2544906 */
  FROM EDW_ITEM_ITEMORG_TEMP;

  COMMIT;

  IF l_collect_onetime = 'Y' THEN

    edw_log.put_line(' ');
    edw_log.put_line('Pushing EDW_ITEM_ITEMORG for one time items');

    INSERT INTO EDW_ITEM_ITEMORG_LSTG(
      APPROVED_SUPPLIER,
      BUYER_FK,
      CREATION_DATE,
      CATSET_CATEGORY_FK,
      CATSET_CATEGORY_FK_KEY,
      DESCRIPTION,
      ERROR_CODE,
      EXPRS_DELIVERY,
      INSP_REQUIRED,
      INSTANCE,
      INTERNAL_ORD_FLAG,
      INV_PLANNING_CODE,
      ITEM_NUMBER,
      ITEM_NUMBER_FK,
      ITEM_NUMBER_FK_KEY,
      ITEM_ORG_DP,
      ITEM_ORG_PK,
      LAST_UPDATE_DATE,
      LOCATOR_CONTROL,
      EFFECTIVITY_CONTROL,
      LOT_CONTROL,
      MAKE_OR_BUY_FLAG,
      MARKET_PRICE,
      MRP_PLN_METHOD,
      NAME,
      ONE_TIME_FLAG,
      OUTSIDE_OP_FLAG,
      PLANNER_FK,
      PRICE_TOL_PERCENT,
      PROD_FAMILY_FK,
      PROD_FAMILY_FK_KEY,
      PURCHASABLE_FLAG,
      RECEIPT_REQUIRED,
      REQUEST_ID,
      REVISION_CONTROL,
      RFQ_REQUIRED_FLAG,
      ROW_ID,
      SERIAL_CONTROL,
      SHELF_LIFE_CODE,
      SHELF_LIFE_DAYS,
      STOCKABLE_FLAG,
      SUBSTITUTE_RCPT,
      TAXABLE_FLAG,
      TAX_CODE,
      UNIT_LIST_PRICE,
      UNORDERED_RCPT,
      USER_ATTRIBUTE1,
      USER_ATTRIBUTE2,
      USER_ATTRIBUTE3,
      USER_ATTRIBUTE4,
      USER_ATTRIBUTE5,
      OPERATION_CODE,
      COLLECTION_STATUS)
    SELECT
      APPROVED_SUPPLIER,
      BUYER_FK,
      CREATION_DATE,
      'NA_EDW', --CATSET_CATEGORY_FK
      NULL, --CATSET_CATEGORY_FK_KEY,
      DESCRIPTION,
      NULL, --ERROR_CODE,
      EXPRS_DELIVERY,
      INSP_REQUIRED,
      l_instance,
      INTERNAL_ORD_FLAG,
      SUBSTRB(INV_PLANNING_CODE, 1, 40),
      SUBSTRB(ITEM_NUMBER, 1, 240),
      ITEM_NUMBER_FK || '-' || l_instance || '-ONETIME', --      ITEM_NUMBER_FK, /* Bug# 2558245 */
      NULL, --ITEM_NUMBER_FK_KEY,
      SUBSTRB(ITEM_ORG_DP, 1, 240),
      ITEM_ORG_PK || '-' || l_instance || '-ONETIME', --      ITEM_ORG_PK, /* Bug# 2558245 */
      LAST_UPDATE_DATE,
      LOCATOR_CONTROL,
      EFFECTIVITY_CONTROL,
      LOT_CONTROL,
      SUBSTRB(MAKE_OR_BUY_FLAG, 1, 40),
      MARKET_PRICE,
      MRP_PLN_METHOD,
      SUBSTRB(NAME, 1, 320),
      ONE_TIME_FLAG,
      OUTSIDE_OP_FLAG,
      PLANNER_FK,
      PRICE_TOL_PERCENT,
      NVL(PROD_FAMILY_FK, 'NA_EDW'),
      NULL, --PROD_FAMILY_FK_KEY,
      PURCHASABLE_FLAG,
      RECEIPT_REQUIRED,
      NULL, --REQUEST_ID,
      REVISION_CONTROL,
      RFQ_REQUIRED_FLAG,
      NULL, --ROW_ID,
      SERIAL_CONTROL,
      SHELF_LIFE_CODE,
      SHELF_LIFE_DAYS,
      STOCKABLE_FLAG,
      SUBSTITUTE_RCPT,
      TAXABLE_FLAG,
      TAX_CODE,
      UNIT_LIST_PRICE,
      UNORDERED_RCPT,
      USER_ATTRIBUTE1,
      USER_ATTRIBUTE2,
      USER_ATTRIBUTE3,
      USER_ATTRIBUTE4,
      USER_ATTRIBUTE5,
      NULL, -- OPERATION_CODE
      'READY'
    FROM EDW_ITEM_ONETIME_ITEMORG_LCV
    WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;

    l_rows_inserted := SQL%ROWCOUNT;
    edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
          ' rows into the staging table');
    edw_log.put_line(' ');
    COMMIT;

  ELSE

    edw_log.put_line(' ');
    edw_log.put_line('EDW_ITEM_ITEMORG for one time items will not be pushed');

  END IF;

  edw_log.put_line(' ');
  edw_log.put_line('Pushing items to lower level EDW_ITEM_ITEMREV');
  l_rows_inserted := 0;
  l_commit_count := 0;

  INSERT INTO EDW_ITEM_ITEMREV_LSTG(
    ITEM_REVISION_PK,
    ITEM_ORG_FK,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    NAME,
    INSTANCE,
    COLLECTION_STATUS)
  SELECT
    SUBSTRB(ITEM_ORG_PK || '-' || l_instance, 1, 315)|| '-IORG', /* Bug# 2558245 */
    SUBSTRB(ITEM_ORG_PK || '-' || l_instance, 1, 320), /* Bug# 2558245 */
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    SUBSTRB(l_all_item_revs || ' (' || NAME || ')', 1, 320),
    l_instance,
    'READY'
  FROM EDW_ITEM_ITEMORG_LCV
  WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;

  l_rows_inserted := SQL%ROWCOUNT;
  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
       ' rows into the staging table');
  edw_log.put_line(' ');
  EDW_ITEMS_M_C.g_row_count:=EDW_ITEMS_M_C.g_row_count+l_rows_inserted;
  COMMIT;

  IF l_collect_onetime = 'Y' THEN

    l_rows_inserted := 0;
    edw_log.put_line('Pushing one time items to lower level EDW_ITEM_ITEMREV');

    INSERT INTO EDW_ITEM_ITEMREV_LSTG(
      ITEM_ORG_FK,
      ITEM_REVISION_PK,
      NAME,
      INSTANCE,
      COLLECTION_STATUS)
    SELECT
      SUBSTRB(ITEM_ORG_PK || '-' || l_instance,1,312) || '-ONETIME', /* Bug# 2558245 */
      SUBSTRB(ITEM_ORG_PK || '-' || l_instance,1,307) || '-ONETIME' || '-IORG',
      SUBSTRB(l_all_item_revs || '(' || NAME || ')',1,320),
      l_instance,
      'READY' --COLLECTION_STATUS
    FROM EDW_ITEM_ONETIME_ITEMORG_LCV
    WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;

    l_rows_inserted := SQL%ROWCOUNT;
    edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
          ' rows into the staging table');
    edw_log.put_line(' ');
    EDW_ITEMS_M_C.g_row_count:=EDW_ITEMS_M_C.g_row_count+l_rows_inserted;
    COMMIT;

  END IF;

EXCEPTION WHEN OTHERS THEN
   RAISE;

END Push_EDW_ITEM_ITEMORG;

PROCEDURE Push_EDW_ITEM_ITEM(
                p_from_date  IN   DATE,
                p_to_date    IN   DATE) IS
  l_staging_table_name       VARCHAR2(30) :='EDW_ITEM_ITEM_LSTG'  ;
  L_PUSH_DATE_RANGE1         DATE := NULL;
  L_PUSH_DATE_RANGE2         DATE := NULL;
  l_rows_inserted            NUMBER := 0;
  -- l_instance VARCHAR2(240) := NULL; /* Bug# 2558245 */

  /* Bug# 2558245
  CURSOR l_instance_csr is
   SELECT instance_code
   FROM edw_local_instance;
  */

  l_all_item_orgs VARCHAR2(100);
  l_all_item_revs VARCHAR2(100);

/**Bug: 5130137
  CURSOR category_assignments_cursor IS   Bug# 2197243
    SELECT
      MIC.INVENTORY_ITEM_ID,
      MIC.ORGANIZATION_ID
    FROM
      MTL_ITEM_CATEGORIES MIC,
      MTL_CATEGORY_SETS_TL SETS
    WHERE MIC.CATEGORY_SET_ID = SETS.CATEGORY_SET_ID
      AND MIC.LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date
      AND SETS.LANGUAGE = userenv('LANG')
      AND SETS.CATEGORY_SET_NAME IN (l_item_catset1_name,
                                     l_item_catset2_name,
                                     l_item_catset3_name);
      MTL_CATEGORIES CAT,
      MTL_ITEM_CATEGORIES MIC,
      MTL_CATEGORY_SETS SETS
    WHERE CAT.CATEGORY_ID = MIC.CATEGORY_ID
      AND MIC.CATEGORY_SET_ID = SETS.CATEGORY_SET_ID
      AND MIC.LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date
      AND SETS.CATEGORY_SET_NAME IN (l_item_catset1_name,
                                     l_item_catset2_name,
                                     l_item_catset3_name);

  category_assignments_rec   category_assignments_cursor%ROWTYPE;**/

BEGIN

  l_all_item_orgs := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_IORG');
  l_all_item_revs := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_IREV');

  l_push_date_range1 := p_from_date;
  l_push_date_range2:= p_to_date;

  /* Bug# 2558245
  for l_instance_rec in l_instance_csr loop
    l_instance := l_instance_rec.instance_code;
  end loop;
  */

  edw_log.put_line(' ');
  edw_log.put_line('Pushing EDW_ITEM_ITEM');

  INSERT INTO EDW_ITEM_ITEM_TEMP(
    CREATION_DATE,
    CATSET1_CATEGORY_FK,
    CATSET1_CATEGORY_FK_KEY,
    CATSET2_CATEGORY_FK,
    CATSET2_CATEGORY_FK_KEY,
    CATSET3_CATEGORY_FK,
    CATSET3_CATEGORY_FK_KEY,
    DESCRIPTION,
    ERROR_CODE,
    INSTANCE,
    ITEM_NAME,
    ITEM_NUMBER_DP,
    ITEM_NUMBER_PK,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    LAST_UPDATE_DATE,
    NAME,
    ONE_TIME_FLAG,
    PRODUCT_GROUP_FK,
    PRODUCT_GROUP_FK_KEY,
    REQUEST_ID,
    ROW_ID,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS,
    ITEM_TYPE)  /* Enh# 2544906 */
  SELECT
    CREATION_DATE,
    CATSET1_CATEGORY_FK,
    INVENTORY_ITEM_ID, -- CATSET1_CATEGORY_FK_KEY
    CATSET2_CATEGORY_FK,
    NULL, -- CATSET2_CATEGORY_FK_KEY,
    CATSET3_CATEGORY_FK,
    NULL, -- CATSET3_CATEGORY_FK_KEY,
    DESCRIPTION,
    NULL, --ERROR_CODE,
    l_instance, --INSTANCE, /* Bug# 2558245 */
    ITEM_NAME,
    ITEM_NUMBER_DP,
    ITEM_NUMBER_PK || '-' || l_instance, --     ITEM_NUMBER_PK, /* Bug# 2558245 */
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    LAST_UPDATE_DATE,
    SUBSTRB(NAME, 1, 320),
    NULL, --ONE_TIME_FLAG,
    PRODUCT_GROUP_FK,
    ORGANIZATION_ID, --PRODUCT_GROUP_FK_KEY,
    NULL, --REQUEST_ID,
    NULL, --ROW_ID,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY',
    ITEM_TYPE  /* Enh# 2544906 */
  FROM EDW_ITEM_ITEM_LCV
  WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;

  l_rows_inserted := l_rows_inserted + SQL%ROWCOUNT;
  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
       ' rows into the staging table');
  edw_log.put_line(' ');

  /* Bug# 2197243 */
  /** Need to INSERT additional items for whom the category assignments
   ** have changed.
  */
  edw_log.put_line('Inserting additional items due to category changes ');

/**5130137  OPEN category_assignments_cursor;
  LOOP
    FETCH category_assignments_cursor INTO category_assignments_rec;
    EXIT WHEN category_assignments_cursor%notfound;*/

    INSERT INTO EDW_ITEM_ITEM_TEMP(
      CREATION_DATE,
      CATSET1_CATEGORY_FK,
      CATSET1_CATEGORY_FK_KEY,
      CATSET2_CATEGORY_FK,
      CATSET2_CATEGORY_FK_KEY,
      CATSET3_CATEGORY_FK,
      CATSET3_CATEGORY_FK_KEY,
      DESCRIPTION,
      ERROR_CODE,
      INSTANCE,
      ITEM_NAME,
      ITEM_NUMBER_DP,
      ITEM_NUMBER_PK,
      INVENTORY_ITEM_ID,
      ORGANIZATION_ID,
      LAST_UPDATE_DATE,
      NAME,
      ONE_TIME_FLAG,
      PRODUCT_GROUP_FK,
      PRODUCT_GROUP_FK_KEY,
      REQUEST_ID,
      ROW_ID,
      USER_ATTRIBUTE1,
      USER_ATTRIBUTE2,
      USER_ATTRIBUTE3,
      USER_ATTRIBUTE4,
      USER_ATTRIBUTE5,
      OPERATION_CODE,
      COLLECTION_STATUS,
      ITEM_TYPE)  /* Enh# 2544906 */
    SELECT
      CREATION_DATE,
      CATSET1_CATEGORY_FK,
      eil.INVENTORY_ITEM_ID, -- CATSET1_CATEGORY_FK_KEY
      CATSET2_CATEGORY_FK,
      NULL, -- CATSET2_CATEGORY_FK_KEY,
      CATSET3_CATEGORY_FK,
      NULL, -- CATSET3_CATEGORY_FK_KEY,
      DESCRIPTION,
      NULL, --ERROR_CODE,
      l_instance, --INSTANCE, /* Bug# 2558245 */
      ITEM_NAME,
      ITEM_NUMBER_DP,
      ITEM_NUMBER_PK || '-' || l_instance, --     ITEM_NUMBER_PK, /* Bug# 2558245 */
      eil.INVENTORY_ITEM_ID,
      eil.ORGANIZATION_ID,
      LAST_UPDATE_DATE,
      SUBSTRB(NAME, 1, 320),
      NULL, --ONE_TIME_FLAG,
      PRODUCT_GROUP_FK,
      eil.ORGANIZATION_ID, --PRODUCT_GROUP_FK_KEY,
      NULL, --REQUEST_ID,
      NULL, --ROW_ID,
      USER_ATTRIBUTE1,
      USER_ATTRIBUTE2,
      USER_ATTRIBUTE3,
      USER_ATTRIBUTE4,
      USER_ATTRIBUTE5,
      NULL, -- OPERATION_CODE
      'READY',
      ITEM_TYPE  /* Enh# 2544906 */
    FROM EDW_ITEM_ITEM_LCV eil,
         (
	   SELECT
            MIC.INVENTORY_ITEM_ID,
            MIC.ORGANIZATION_ID
           FROM
             MTL_ITEM_CATEGORIES MIC,
             MTL_CATEGORY_SETS_TL SETS
           WHERE MIC.CATEGORY_SET_ID = SETS.CATEGORY_SET_ID
             AND MIC.LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date
             AND SETS.LANGUAGE = userenv('LANG')
             AND SETS.CATEGORY_SET_NAME IN (l_item_catset1_name,
                                     l_item_catset2_name,
                                     l_item_catset3_name)) category_assignments_rec
    WHERE eil.inventory_item_id = category_assignments_rec.inventory_item_id
      AND eil.organization_id = category_assignments_rec.organization_id
      AND last_update_date not BETWEEN l_push_date_range1 AND l_push_date_range2; /*  Bug# 2659263 */

--  END LOOP;

  edw_log.put_line('Done Inserting category changed items into item ');

  COMMIT;

  edw_log.put_line('Resolving category fks for staging table records');
  edw_log.put_line(' ');

  /* Bug# 2631155 added DECODE by dsakalle */
  /* Bug# 2559696 Removed the use of EDW_ITEMS_CATEGORY_FKV By dsakalle */

  IF (l_item_catset3_name = 'NA_EDW') THEN
    UPDATE EDW_ITEM_ITEM_TEMP
    SET CATSET1_CATEGORY_FK =
            (SELECT DECODE(COUNT(cat.category_id), 1, TO_CHAR(2)||'-'||MAX(cat.category_id) || '-' || l_instance, 'NA_EDW')
             FROM
               MTL_ITEM_CATEGORIES cat,
               MTL_CATEGORY_SETS sets
             WHERE cat.organization_id = product_group_fk_key
               AND cat.inventory_item_id = catset1_category_fk_key
               -- AND sets.control_level = 1  Bug : 3720586
               AND sets.category_set_name = l_item_catset1_name
               AND cat.category_set_id = sets.category_set_id),
        CATSET2_CATEGORY_FK =
            (SELECT DECODE(COUNT(cat.category_id), 1, TO_CHAR(2)||'-'||MAX(cat.category_id) || '-' || l_instance, 'NA_EDW')
             FROM
               MTL_ITEM_CATEGORIES cat,
               MTL_CATEGORY_SETS sets
             WHERE cat.organization_id = product_group_fk_key
               AND cat.inventory_item_id = catset1_category_fk_key
               AND sets.control_level = 1
               AND sets.category_set_name = l_item_catset2_name
               AND cat.category_set_id = sets.category_set_id),
        CATSET3_CATEGORY_FK = edw_itemcustom_m_c.get_product_category_set_fk(catset1_category_fk_key,
                                    product_group_fk_key, instance),
        PRODUCT_GROUP_FK = edw_items_pkg.get_prod_grp_fk(catset1_category_fk_key,
                                    product_group_fk_key, instance);

    COMMIT;
  ELSE
    UPDATE EDW_ITEM_ITEM_TEMP
    SET CATSET1_CATEGORY_FK =
            (SELECT DECODE(COUNT(cat.category_id), 1, TO_CHAR(2)||'-'||MAX(cat.category_id) || '-' || l_instance, 'NA_EDW')
             FROM
               MTL_ITEM_CATEGORIES cat,
               MTL_CATEGORY_SETS sets
             WHERE cat.organization_id = product_group_fk_key
               AND cat.inventory_item_id = catset1_category_fk_key
               -- AND sets.control_level = 1 Bug : 3720586
               AND sets.category_set_name = l_item_catset1_name
               AND cat.category_set_id = sets.category_set_id),
        CATSET2_CATEGORY_FK =
            (SELECT DECODE(COUNT(cat.category_id), 1, TO_CHAR(2)||'-'||MAX(cat.category_id) || '-' || l_instance, 'NA_EDW')
             FROM
               MTL_ITEM_CATEGORIES cat,
               MTL_CATEGORY_SETS sets
             WHERE cat.organization_id = product_group_fk_key
               AND cat.inventory_item_id = catset1_category_fk_key
               AND sets.control_level = 1
               AND sets.category_set_name = l_item_catset2_name
               AND cat.category_set_id = sets.category_set_id),
        CATSET3_CATEGORY_FK =
            (SELECT DECODE(COUNT(cat.category_id), 1, TO_CHAR(2)||'-'||MAX(cat.category_id) || '-' || l_instance, 'NA_EDW')
             FROM
               MTL_ITEM_CATEGORIES cat,
               MTL_CATEGORY_SETS sets
             WHERE cat.organization_id = product_group_fk_key
               AND cat.inventory_item_id = catset1_category_fk_key
               AND sets.control_level = 1
               AND sets.category_set_name = l_item_catset3_name
               AND cat.category_set_id = sets.category_set_id),
        PRODUCT_GROUP_FK = edw_items_pkg.get_prod_grp_fk(catset1_category_fk_key,
                product_group_fk_key, instance);

    COMMIT;
  END IF;

  UPDATE EDW_ITEM_ITEM_TEMP
  SET
    CATSET1_CATEGORY_FK = NVL(CATSET1_CATEGORY_FK, 'NA_EDW'),
    CATSET2_CATEGORY_FK = NVL(CATSET2_CATEGORY_FK, 'NA_EDW'),
    CATSET3_CATEGORY_FK = NVL(CATSET3_CATEGORY_FK, 'NA_EDW'),
    PRODUCT_GROUP_FK = NVL(PRODUCT_GROUP_FK, 'NA_EDW'),
    PRODUCT_GROUP_FK_KEY = NULL,
    CATSET1_CATEGORY_FK_KEY = NULL;

  COMMIT;

  INSERT INTO EDW_ITEM_ITEM_LSTG(
    CREATION_DATE,
    CATSET1_CATEGORY_FK,
    CATSET1_CATEGORY_FK_KEY,
    CATSET2_CATEGORY_FK,
    CATSET2_CATEGORY_FK_KEY,
    CATSET3_CATEGORY_FK,
    CATSET3_CATEGORY_FK_KEY,
    DESCRIPTION,
    ERROR_CODE,
    INSTANCE,
    ITEM_NAME,
    ITEM_NUMBER_DP,
    ITEM_NUMBER_PK,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    LAST_UPDATE_DATE,
    NAME,
    ONE_TIME_FLAG,
    PRODUCT_GROUP_FK,
    PRODUCT_GROUP_FK_KEY,
    REQUEST_ID,
    ROW_ID,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS,
    ITEM_TYPE)  /* Enh# 2544906 */
  SELECT
    CREATION_DATE,
    CATSET1_CATEGORY_FK,
    NULL, --CATSET1_CATEGORY_FK_KEY
    CATSET2_CATEGORY_FK,
    NULL, --CATSET2_CATEGORY_FK_KEY
    CATSET3_CATEGORY_FK,
    NULL, --CATSET3_CATEGORY_FK_KEY
    DESCRIPTION,
    NULL, --ERROR_CODE,
    INSTANCE,
    ITEM_NAME,
    ITEM_NUMBER_DP,
    ITEM_NUMBER_PK,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    LAST_UPDATE_DATE,
    SUBSTRB(NAME, 1, 320),
    NULL, --ONE_TIME_FLAG,
    PRODUCT_GROUP_FK, --PRODUCT_FAMILY_FK
    NULL, --PRODUCT_GROUP_FK_KEY,
    NULL, --REQUEST_ID,
    NULL, --ROW_ID,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    NULL, -- OPERATION_CODE
    'READY',
    ITEM_TYPE  /* Enh# 2544906 */
  FROM EDW_ITEM_ITEM_TEMP;
  COMMIT;

  edw_log.put_line('Pushing EDW_ITEM_ITEM records to Item Org level');

  INSERT INTO edw_item_itemorg_lstg(
    ITEM_ORG_PK,
    ITEM_NUMBER_FK,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    NAME,
    INSTANCE,
    COLLECTION_STATUS,
    CATSET_CATEGORY_FK,
    PROD_FAMILY_FK)
  SELECT
    SUBSTRB(ITEM_NUMBER_PK || '-' || l_instance ||'-ITEM', 1, 1000), /* Bug# 2558245 */
    ITEM_NUMBER_PK || '-' || l_instance, /* Bug# 2558245 */
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    SUBSTRB(l_all_item_orgs || '(' || NAME || ')', 1, 320),
    l_instance, --INSTANCE, /* Bug# 2558245 */
    'READY',
    'NA_EDW',
    'NA_EDW'
  FROM edw_item_item_lcv
  WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;

  l_rows_inserted := SQL%ROWCOUNT;
  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
       ' rows into the staging table');
  edw_log.put_line(' ');
  COMMIT;

  edw_log.put_line('Pushing EDW_ITEM_ITEM records to Item Rev level');

  INSERT INTO edw_item_itemrev_lstg(
    ITEM_REVISION_PK,
    ITEM_ORG_FK,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    NAME,
    INSTANCE,
    COLLECTION_STATUS)
  SELECT
    SUBSTRB(ITEM_NUMBER_PK || '-' || l_instance , 1, 315) || '-ITEM', /* Bug# 2558245 */
    SUBSTRB(ITEM_NUMBER_PK || '-' || l_instance , 1, 315) || '-ITEM', /* Bug# 2558245 */
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    SUBSTRB(l_all_item_revs || '(' || NAME || ')', 1, 320),
    l_instance, --INSTANCE, /* Bug# 2558245 */
    'READY'
  FROM edw_item_item_lcv
  WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;

  l_rows_inserted := SQL%ROWCOUNT;
  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
       ' rows into the staging table');
  edw_log.put_line(' ');
  EDW_ITEMS_M_C.g_row_count:=EDW_ITEMS_M_C.g_row_count+l_rows_inserted;
  COMMIT;

  IF l_collect_onetime = 'Y' THEN

    edw_log.put_line('Pushing EDW_ITEM_ITEM for one time items');

    INSERT INTO EDW_ITEM_ITEM_LSTG(
      CREATION_DATE,
      CATSET1_CATEGORY_FK,
      CATSET1_CATEGORY_FK_KEY,
      CATSET2_CATEGORY_FK,
      CATSET2_CATEGORY_FK_KEY,
      CATSET3_CATEGORY_FK,
      CATSET3_CATEGORY_FK_KEY,
      DESCRIPTION,
      ERROR_CODE,
      INSTANCE,
      ITEM_NAME,
      ITEM_NUMBER_DP,
      ITEM_NUMBER_PK,
      LAST_UPDATE_DATE,
      NAME,
      ONE_TIME_FLAG,
      PRODUCT_GROUP_FK,
      PRODUCT_GROUP_FK_KEY,
      REQUEST_ID,
      ROW_ID,
      USER_ATTRIBUTE1,
      USER_ATTRIBUTE2,
      USER_ATTRIBUTE3,
      USER_ATTRIBUTE4,
      USER_ATTRIBUTE5,
      OPERATION_CODE,
      COLLECTION_STATUS)
    SELECT
      CREATION_DATE,
      TO_CHAR(2)||'-'||CATSET_CATEGORY_FK||'-'||l_instance,  -- Bug# 2848291 added l_instance
      NULL, --CATSET1_CATEGORY_FK_KEY,
      'NA_EDW',
      NULL, --CATSET2_CATEGORY_FK_KEY,
      'NA_EDW',
      NULL, --CATSET3_CATEGORY_FK_KEY,
      DESCRIPTION,
      NULL, --ERROR_CODE,
      l_instance, --INSTANCE, /* Bug# 2558245 */
      SUBSTRB(ITEM_NAME, 1, 240),
      SUBSTRB(ITEM_NUMBER_DP, 1, 240),
      ITEM_NUMBER_PK || '-' || l_instance || '-ONETIME', -- ITEM_NUMBER_PK, /* Bug# 2558245 */
      LAST_UPDATE_DATE,
      SUBSTRB(NAME, 1, 320),
      ONE_TIME_FLAG,
      NVL(PRODUCT_GROUP_FK, 'NA_EDW'),
      NULL, --PRODUCT_GROUP_FK_KEY,
      NULL, --REQUEST_ID,
      NULL, --ROW_ID,
      USER_ATTRIBUTE1,
      USER_ATTRIBUTE2,
      USER_ATTRIBUTE3,
      USER_ATTRIBUTE4,
      USER_ATTRIBUTE5,
      OPERATION_CODE,
      'READY'
    FROM EDW_ITEM_ONETIME_ITEM_LCV
    WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;

    l_rows_inserted := SQL%ROWCOUNT;
    edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
         ' rows into the staging table');
    edw_log.put_line(' ');
    COMMIT;

    edw_log.put_line('Pushing one-time EDW_ITEM_ITEM records to Item Org level');

    INSERT INTO edw_item_itemorg_lstg(
      ITEM_ORG_PK,
      ITEM_NUMBER_FK,
      NAME,
      INSTANCE,
      COLLECTION_STATUS,
      CATSET_CATEGORY_FK,
      PROD_FAMILY_FK)
    SELECT
      SUBSTRB(ITEM_NUMBER_PK || '-' || l_instance,1,987)||'-ONETIME'||'-ITEM', /* Bug# 2558245 */
      ITEM_NUMBER_PK || '-' || l_instance || '-ONETIME', /* Bug# 2558245 */
      SUBSTRB(l_all_item_orgs || '(' || NAME || ')', 1, 320),
      l_instance, --INSTANCE, /* Bug# 2558245 */
      'READY',
      'NA_EDW',
      'NA_EDW'
    FROM edw_item_onetime_item_lcv
    WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;

    l_rows_inserted := SQL%ROWCOUNT;
    edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
          ' rows into the staging table');
    edw_log.put_line(' ');
    COMMIT;

    INSERT INTO edw_item_itemrev_lstg(
      ITEM_REVISION_PK,
      ITEM_ORG_FK,
      NAME,
      INSTANCE,
      COLLECTION_STATUS)
    SELECT
      SUBSTRB(ITEM_NUMBER_PK || '-' || l_instance,1,307) || '-ONETIME' || '-ITEM', /* Bug# 2558245 */
      SUBSTRB(ITEM_NUMBER_PK || '-' || l_instance,1,307) || '-ONETIME' || '-ITEM', /* Bug# 2558245 */
      SUBSTRB(l_all_item_revs || '(' || NAME || ')', 1, 320),
      l_instance, --INSTANCE, /* Bug# 2558245 */
      'READY'
    FROM edw_item_onetime_item_lcv
    WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2;

    l_rows_inserted := SQL%ROWCOUNT;
    edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
          ' rows into the staging table');
    edw_log.put_line(' ');
    EDW_ITEMS_M_C.g_row_count:=EDW_ITEMS_M_C.g_row_count+l_rows_inserted;
    COMMIT;

  ELSE

    edw_log.put_line(' ');
    edw_log.put_line('EDW_ITEM_ITEM for one time items will not be pushed');

  END IF;

--
---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

EXCEPTION WHEN OTHERS THEN
  RAISE;
  COMMIT;

END Push_EDW_ITEM_ITEM;

PROCEDURE Insert_Category(
               p_from_date          DATE ,
               p_to_date            DATE ,
               p_staging_table_name VARCHAR2,
               p_view_name          VARCHAR2,
               p_category_set_name  VARCHAR2,
               p_control_level      NUMBER) IS

  l_stmt               VARCHAR2(5000) := NULL;
  l_cursor             NUMBER;
  l_rows_inserted      NUMBER := 0;
  l_fk_name            VARCHAR2(40);
  l_fk_value           VARCHAR2(40);
  l_fk_key             VARCHAR2(40);
  l_pk_value           VARCHAR2(40);
  l_view_name          VARCHAR2(1000);
  l_where_clause       VARCHAR2(1000);
  l_row_cnt            NUMBER; /* Bug# 2504279 */
BEGIN
   /* Bug# 2504279, tempoary workaround begin*/

  l_cursor:=dbms_sql.open_cursor;

  -- Bug# 3296641
  IF SUBSTRB(p_view_name,1,15) = 'EDW_ITEM_CATSET' then
    l_where_clause := ' WHERE category_set_name = :l_category_set_name';
    l_where_clause := l_where_clause || ' AND COLLECTION_STATUS = ''READY''';
  ELSE
    l_where_clause := ' WHERE last_update_date BETWEEN :l_push_date_range1 AND :l_push_date_range2 AND category_set_name = :l_category_set_name';
  END IF;

  l_stmt := 'SELECT count(*) row_cnt FROM '||p_view_name||l_where_clause;

  dbms_sql.parse(l_cursor,l_stmt,dbms_sql.native);
  dbms_sql.bind_variable(l_cursor, ':l_category_set_name', p_category_set_name);

  -- Bug# 3296641
  IF SUBSTRB(p_view_name,1,15) = 'EDW_ITEM_CATSET' then
    null;
  ELSE
    dbms_sql.bind_variable(l_cursor, ':l_push_date_range1', p_from_date);
    dbms_sql.bind_variable(l_cursor, ':l_push_date_range2', p_to_date);
  END IF;

  dbms_sql.define_column(l_cursor, 1, l_row_cnt);

  l_rows_inserted:=dbms_sql.execute_and_fetch(l_cursor, true);

  dbms_sql.column_value(l_cursor, 1, l_row_cnt);

  dbms_sql.close_cursor(l_cursor);

  IF l_row_cnt = 0 THEN
    edw_log.put_line(' ');
    edw_log.put_line('No rows fetched for insert into '||p_staging_table_name);
    RETURN;
  END IF;

  l_where_clause := null; -- Bug# 3296641

  l_rows_inserted := 0;
  /* Bug# 2504279, tempoary workaround end*/

  edw_log.debug_line(' ');
  edw_log.debug_line('Constructing the sql statement for ' || p_staging_table_name || ' and pushing category set ' || p_category_set_name);

  l_cursor:=dbms_sql.OPEN_CURSOR;

  edw_log.debug_line('Constructing PKs and FKs');

  IF (p_staging_table_name IN ( 'EDW_ITEM_CATSET1_C6_LSTG',
                                'EDW_ITEM_CATSETI1_C6_LSTG',
                                'EDW_ITEM_CATSETI2_C6_LSTG',
                                'EDW_ITEM_CATSETI3_C10_LSTG')) THEN
    l_fk_name := ' ALL_FK';
    l_fk_key := ' ALL_FK_KEY';
    l_fk_value := ' ALL_FK';
--    l_pk_value := ''''||TO_CHAR(p_control_level)||'-'||''''||'||'|| 'CATEGORY_PK'; /* Bug# 2558245 */
    l_pk_value := ''''||TO_CHAR(p_control_level)||'-'||''''||'||'|| 'CATEGORY_PK' ||'||' ||''''||'-'||l_instance||'''';
  ELSE
    l_fk_name := ' CATEGORY_FK';
    l_fk_key := ' CATEGORY_FK_KEY';
--    l_fk_value := ''''||TO_CHAR(p_control_level)||'-'||''''||'||'|| 'CATEGORY_PK'; /* Bug# 2558245 */
    l_fk_value := ''''||TO_CHAR(p_control_level)||'-'||''''||'||'|| 'CATEGORY_PK' ||'||' ||''''||'-'||l_instance||'''';
--    l_pk_value := ''''||TO_CHAR(p_control_level)||'-'||''''||'||'|| 'CATEGORY_PK'; /* Bug# 2558245 */
    l_pk_value := ''''||TO_CHAR(p_control_level)||'-'||''''||'||'|| 'CATEGORY_PK' ||'||' ||''''||'-'||l_instance||'''';
  END IF;


  -- If VBH insert then need to pull from prior level staging table rather than _LCV view
  IF SUBSTRB(p_view_name,1,15) = 'EDW_ITEM_CATSET' then

    edw_log.debug_line('VBH insert - Pulling from prior level staging table');

    -- append staging table database link to view
    l_view_name := p_view_name;
    l_where_clause := ' WHERE category_set_name = :l_category_set_name'; -- Bug# 3296641
    l_where_clause := l_where_clause || ' AND COLLECTION_STATUS = ''READY'''; -- Bug# 3296641

    edw_log.debug_line('Assigning PKs and FKs based on level');

    IF p_staging_table_name = 'EDW_ITEM_CATSETI3_C9_LSTG' THEN
      -- Selecting from level 10, hence take PK for FK rather than ALL_FK

      l_fk_value := 'CATEGORY_PK';
      l_pk_value := 'CATEGORY_PK';

    ELSE -- Selecting from level other than 10, hence take FK itself

      l_fk_value := 'CATEGORY_FK';
      l_pk_value := 'CATEGORY_PK';

    END IF;

  ELSE -- not VBH so append _LCV view database link to view

    l_view_name := p_view_name;
    -- Bug# 3296641
    l_where_clause := ' WHERE last_update_date BETWEEN :l_push_date_range1 AND :l_push_date_range2 ' ||
                      ' AND category_set_name = :l_category_set_name';

  END IF;

  edw_log.debug_line('Constructing insert stmt');

  l_stmt:= 'INSERT INTO '||p_staging_table_name||' ('||
              l_fk_name || ','||
              l_fk_key || ','||
              ' CATEGORY_NAME,'||
              ' CATEGORY_SET_NAME,'||
              ' CREATION_DATE,' ||
              ' DESCRIPTION,'||
              ' ERROR_CODE,' ||
              ' INSTANCE,' ||
              ' CATEGORY_DP,'||
              ' CATEGORY_PK,'||
              ' CATEGORY_ID,'||
              ' CATEGORY_SET_ID,'||
              ' LAST_UPDATE_DATE,' ||
              ' NAME,' ||
              ' REQUEST_ID,' ||
              ' ROW_ID,' ||
              ' USER_ATTRIBUTE1,' ||
              ' USER_ATTRIBUTE2,' ||
              ' USER_ATTRIBUTE3,' ||
              ' USER_ATTRIBUTE4,' ||
              ' USER_ATTRIBUTE5,' ||
              ' OPERATION_CODE,' ||
              ' COLLECTION_STATUS ) '||
              ' SELECT '||
              l_fk_value || ','||
              ' NULL,' ||
              ' NULL,' ||
              ' CATEGORY_SET_NAME,'||
              ' CREATION_DATE,' ||
              ' DESCRIPTION,'||
              ' NULL,' ||
              '''' || l_instance || '''' || ',' || /* Bug# 2558245 */
              ' CATEGORY_DP,' ||
              l_pk_value || ','||
              ' CATEGORY_ID,'||
              ' CATEGORY_SET_ID,'||
              ' LAST_UPDATE_DATE,' ||
              ' SUBSTRB(NAME, 1, 320),' ||
              ' NULL,' ||
              ' NULL,' ||
              ' USER_ATTRIBUTE1,' ||
              ' USER_ATTRIBUTE2,' ||
              ' USER_ATTRIBUTE3,' ||
              ' USER_ATTRIBUTE4,' ||
              ' USER_ATTRIBUTE5,' ||
              ' NULL,' ||
              '''READY'''||
          ' FROM '||l_view_name||l_where_clause; -- Bug# 3296641

  edw_log.put_line(l_stmt);

  l_rows_inserted := SQL%ROWCOUNT ;
  edw_log.debug_line('Parse the cursor');
  dbms_sql.parse(l_cursor,l_stmt,dbms_sql.native);

  edw_log.debug_line('Bind l_category_set_name variable, and last_update dates');
  dbms_sql.bind_variable(l_cursor,':l_category_set_name',p_category_set_name);

  -- Bug# 3296641
  IF SUBSTRB(p_view_name,1,15) = 'EDW_ITEM_CATSET' then
    null;
  ELSE
    dbms_sql.bind_variable(l_cursor,':l_push_date_range1',p_from_date);
    dbms_sql.bind_variable(l_cursor,':l_push_date_range2',p_to_date);
  END IF;

  edw_log.debug_line('Pushing data, Executing the cursor');
  l_rows_inserted:=dbms_sql.execute(l_cursor);

  edw_log.debug_line('Close the cursor');
  dbms_sql.close_cursor(l_cursor);
  edw_log.debug_line(' ');

  edw_log.put_line('Inserted '||TO_CHAR(l_rows_inserted)||
           ' rows into the staging table');
  edw_log.put_line(' ');

END Insert_Category;


PROCEDURE Insert_VBH_Category(
               p_from_date              DATE,
               p_to_date                DATE,
               p_view_name              VARCHAR2,
               p_category_set_name      VARCHAR2,
               p_no_of_catset_lvls      NUMBER,
               p_hrchy_top_node         VARCHAR2,
               p_control_level          NUMBER) IS

  l_stmt                      VARCHAR2(7000) := NULL;
  l_cursor                    NUMBER;
  l_rows_inserted             NUMBER := 0;
  l_fk_name                   VARCHAR2(40);
  l_fk_value                  VARCHAR2(40);
  l_fk_key                    VARCHAR2(40);
  l_from_clause               VARCHAR2(2000) := NULL;
  l_where_clause              VARCHAR2(2000) := NULL;
  l_not_exists_clause         VARCHAR2(1000) := NULL;
  l_vbh_value_set_id          NUMBER;
  l_catset_control_level      NUMBER;
  l_mult_item_flag            VARCHAR2(1);
  l_segment_num               VARCHAR2(30) := NULL;
  l_lower_lvl_exists          BOOLEAN := TRUE;
  l_staging_table_name        VARCHAR2(30);
  l_prior_staging_table_name  VARCHAR2(30); -- as per staging table but for prior level
  l_prior_lvl_no              NUMBER := 0;
  l_catset_lvl                NUMBER := 0;
  l_catset_lvl1_flag          VARCHAR2(1):= 'N';
  l_struct_code               VARCHAR2(1);
  l_structure_id              NUMBER;

  INCORRECT_CTRL_LVL          EXCEPTION;
  VBH_VALUE_SET_NOT_FOUND     EXCEPTION;
  NOT_SEGMENT1                EXCEPTION;
  MULTIPLE_CAT_ALLOWED        EXCEPTION;

  -- CURSOR to get Segment NUMBER AND Value Set assigned to segment

  CURSOR l_vbh_flex_segment_csr (c_category_set_id NUMBER) IS
    SELECT FLEX_VALUE_SET_ID, APPLICATION_COLUMN_NAME
    FROM FND_ID_FLEX_SEGMENTS
    WHERE APPLICATION_ID = '401'
      AND ID_FLEX_CODE = 'MCAT'
      AND ID_FLEX_NUM =
                 (SELECT STRUCTURE_ID
                  FROM MTL_CATEGORY_SETS_VL
                  WHERE CATEGORY_SET_ID = c_category_set_id)
      AND ENABLED_FLAG = 'Y';

  -- CURSOR to check that the VBH Category is still assigned at the Item Level

  CURSOR l_vbh_chk_ctrl_lvl_csr (c_category_set_id VARCHAR2) is
    SELECT CONTROL_LEVEL, MULT_ITEM_CAT_ASSIGN_FLAG, STRUCTURE_ID
    FROM   MTL_CATEGORY_SETS_VL
    WHERE  CATEGORY_SET_ID = c_category_set_id;

BEGIN
  BEGIN
    -- Bug# 2765111 - moved the cursor opening and added structure id in select list
    OPEN l_vbh_chk_ctrl_lvl_csr (g_vbh_catset_id);
    FETCH l_vbh_chk_ctrl_lvl_csr INTO l_catset_control_level, l_mult_item_flag, l_structure_id;
    CLOSE l_vbh_chk_ctrl_lvl_csr;

    -- Check to see if the structure asscoicated with the category set is PRODUCT_CATEGORIES
    BEGIN
      SELECT 'X' INTO l_struct_code
      FROM FND_ID_FLEX_STRUCTURES_VL
      WHERE ID_FLEX_NUM = l_structure_id
        AND ID_FLEX_STRUCTURE_CODE = 'PRODUCT_CATEGORIES'
        AND APPLICATION_ID = '401'
        AND ID_FLEX_CODE = 'MCAT';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      g_error_message := 'Error: The flex structure associated with this category set is not PRODUCT_CATEGORIES';
      RAISE;
    END;

    -- Get Value Set id AND active Segment for VBH Segment
    edw_log.debug_line(' ');
    edw_log.debug_line('Get Value Set id and active Segment for VBH Segment');

    OPEN l_vbh_flex_segment_csr (g_vbh_catset_id);
    LOOP
      FETCH l_vbh_flex_segment_csr INTO l_vbh_value_set_id, l_segment_num;
      EXIT WHEN l_vbh_flex_segment_csr%NOTFOUND;
    END LOOP;

    -- Check that VBH Structure has only one segment enabled
    edw_log.debug_line(' ');
    edw_log.debug_line('Check that VBH Structure has only one segment enabled');

    IF l_vbh_flex_segment_csr%ROWCOUNT > 1 THEN
      RAISE TOO_MANY_ROWS;
    END IF;

    -- Check that VBH Structure is using Segment1
    edw_log.debug_line(' ');
    edw_log.debug_line('Check that VBH Structure is using Segment1');

    IF l_segment_num <> 'SEGMENT1' THEN
      RAISE NOT_SEGMENT1;
    END IF;

    CLOSE l_vbh_flex_segment_csr;

    -- Check that Value Set has been assigned to VBH Category Set
    edw_log.debug_line(' ');
    edw_log.debug_line('Check that Value Set has been assigned to VBH Category Set');

    IF l_vbh_value_set_id IS NULL THEN
      RAISE VBH_VALUE_SET_NOT_FOUND;
    END IF;

  EXCEPTION
    WHEN VBH_VALUE_SET_NOT_FOUND THEN
      g_error_message := 'Value Set not assigned to structure '||p_category_set_name;
      RAISE;
    WHEN NOT_SEGMENT1 THEN
      g_error_message := 'Only Segment1 can be enabled for structure '||p_category_set_name;
      RAISE;
    WHEN TOO_MANY_ROWS THEN
      g_error_message := 'Should only enable Segment1 for structure '||p_category_set_name;
      RAISE;
    WHEN OTHERS THEN
      RAISE;

  END;

  BEGIN

    -- Check that the Category is still assigned at the Item Level
    edw_log.debug_line(' ');
    edw_log.debug_line('Check that the Category is still assigned at the Item Level');

    IF l_catset_control_level <> 1 THEN
      RAISE INCORRECT_CTRL_LVL;
    END IF;

    -- Check that the Category Set does not allow multiple assignments
    -- of items to categories
    edw_log.debug_line(' ');
    edw_log.debug_line('Check that the Category Set does not allow multiple assignments of items to categories');

    IF l_mult_item_flag = 'Y' THEN
      RAISE MULTIPLE_CAT_ALLOWED;
    END IF;

  EXCEPTION
    WHEN INCORRECT_CTRL_LVL THEN
      g_error_message := 'Category is controlled at the Organization Level for '||p_category_set_name;
      RAISE;
    WHEN MULTIPLE_CAT_ALLOWED THEN
      g_error_message := 'Multiple assignments of items to categories is allowed for '||p_category_set_name;
      RAISE;
    WHEN OTHERS THEN
      RAISE;
  END;

  --
  -- Loop to insert categories FROM Value Based Hierarchy
  -- into number of levels available. On each loop all children of
  -- the categories Inserted into the prior level table
  -- are Inserted into the current staging table
  --

  -- Start at top level and work down the category set table hierarchy
  l_catset_lvl := p_no_of_catset_lvls;

  -- Loop until there are no lower levels in the VBH hierarchy
  WHILE l_lower_lvl_exists LOOP

    l_cursor:=dbms_sql.OPEN_CURSOR;

    --
    -- Build staging table name
    --
    l_staging_table_name := 'EDW_ITEM_CATSETI3_C' || l_catset_lvl || '_LSTG';

    edw_log.debug_line(' ');
    edw_log.debug_line('Constructing the sql statement for ' || l_staging_table_name || ' AND pushing category set ' || p_category_set_name);

    IF l_catset_lvl = p_no_of_catset_lvls THEN /* top level */

      l_fk_name := ' ALL_FK';
      l_fk_key := ' ALL_FK_KEY';
      l_fk_value := ' ALL_FK';

      -- Construct the FROM clause for top level

      /* Bug 2234621

      l_from_clause := ' FROM '||' FND_FLEX_VALUE_CHILDREN_V FFVC'
                        ||','||p_view_name||' LCV_VIEW'
                        ||',MTL_CATEGORIES_VL MTC';

      */
      l_from_clause := ' from ' || 'FND_FLEX_VALUE_CHILDREN_V FFVC'
                       || ',' || p_view_name || ' LCV_VIEW';

      -- Construct the WHERE clause for top level

      /* Bug 2234621

      l_where_clause := ' WHERE LCV_VIEW.LAST_UPDATE_DATE BETWEEN :l_push_date_range1'||
                        ' AND   :l_push_date_range2'||
                        ' AND   LCV_VIEW.CATEGORY_SET_NAME = :l_category_set_name'||
                        ' AND   LCV_VIEW.CATEGORY_ID = MTC.CATEGORY_ID'||
                        ' AND   MTC.'||l_segment_num||' = FFVC.FLEX_VALUE'||
                        ' AND   FFVC.FLEX_VALUE_SET_ID = :l_value_set_id'||
                        ' AND   FFVC.PARENT_FLEX_VALUE = :l_hrchy_top_node';
      */
      /* Bug# 3296641
      l_where_clause := ' where LCV_VIEW.LAST_UPDATE_DATE between :l_push_date_range1' ||
                        ' and :l_push_date_range2' ||
                        ' and LCV_VIEW.CATEGORY_SET_NAME = :l_category_set_name' ||
                        ' and LCV_VIEW.NAME = FFVC.FLEX_VALUE' ||
                        ' and FFVC.FLEX_VALUE_SET_ID = :l_value_set_id' ||
                        ' and FFVC.PARENT_FLEX_VALUE = :l_hrchy_top_node';
      */

      l_where_clause := ' where LCV_VIEW.CATEGORY_SET_NAME = :l_category_set_name' ||
                        ' and LCV_VIEW.NAME = FFVC.FLEX_VALUE' ||
                        ' and FFVC.FLEX_VALUE_SET_ID = :l_value_set_id' ||
                        ' and FFVC.PARENT_FLEX_VALUE = :l_hrchy_top_node';

    ELSE /* Not top level */

      --
      -- Build prior level staging table name
      --
      IF l_catset_lvl1_flag = 'Y' /* vbh greater than catset lvls, */
      THEN                        /* hence SELECT FROM AND INSERT INTO lowest lvl table */
        l_prior_staging_table_name := l_staging_table_name;
      ELSE
        l_prior_lvl_no := l_catset_lvl + 1;
        l_prior_staging_table_name := 'EDW_ITEM_CATSETI3_C' ||l_prior_lvl_no|| '_LSTG';
      END IF;

      l_fk_name := ' CATEGORY_FK';
      l_fk_key := ' CATEGORY_FK_KEY';

      IF l_catset_lvl1_flag = 'Y' /* vbh greater than catset lvls */
      THEN                        /* need fk on parent record rather than actual parent pk */
        l_fk_value := 'PARENT_STAGING.CATEGORY_FK';
      ELSE
        l_fk_value := 'PARENT_STAGING.CATEGORY_PK';
      END IF;

      -- Construct the FROM clause for levels other than the top
      /* Bug 2234621

      l_from_clause := ' FROM '||l_prior_staging_table_name||' PARENT_STAGING'
                       ||','||p_view_name||' PARENT_LCV_VIEW'
                       ||',MTL_CATEGORIES_VL PARENT_MTC'
                       ||',FND_FLEX_VALUE_CHILDREN_V FFVC'
                       ||','||p_view_name||' LCV_VIEW'
                       ||',MTL_CATEGORIES_VL MTC';
      */

      l_from_clause := ' from ' || l_prior_staging_table_name || ' PARENT_STAGING, '
                       || ' FND_FLEX_VALUE_CHILDREN_V FFVC'
                       || ',' || p_view_name || ' LCV_VIEW';

      -- Construct the WHERE clause levels other than the top

      /* Bug 2234621

      l_where_clause :=  ' WHERE LCV_VIEW.LAST_UPDATE_DATE BETWEEN :l_push_date_range1'||
                         ' AND   :l_push_date_range2'||
                         ' AND   LCV_VIEW.CATEGORY_SET_NAME = :l_category_set_name'||
                         ' AND   LCV_VIEW.CATEGORY_ID = MTC.CATEGORY_ID'||
                         ' AND   MTC.'||l_segment_num||' = FFVC.FLEX_VALUE'||
                         ' AND   FFVC.FLEX_VALUE_SET_ID = :l_value_set_id'||
                         ' AND   FFVC.PARENT_FLEX_VALUE = PARENT_MTC.'||l_segment_num||
                         ' AND   PARENT_MTC.CATEGORY_ID = PARENT_LCV_VIEW.CATEGORY_ID'||
                         ' AND   PARENT_LCV_VIEW.CATEGORY_SET_NAME = :l_category_set_name'||
                         ' AND   PARENT_LCV_VIEW.CATEGORY_PK || '||''''||'-'||l_instance||'''' ||
                         '= SUBSTRB(PARENT_STAGING.CATEGORY_PK,3)'||
                         ' AND   PARENT_STAGING.COLLECTION_STATUS = ''READY''';
  */
   /* Bug# 3296641
   l_where_clause := ' where LCV_VIEW.LAST_UPDATE_DATE between :l_push_date_range1' ||
                     ' and :l_push_date_range2' ||
                     ' and LCV_VIEW.CATEGORY_SET_NAME = :l_category_set_name' ||
                     ' and LCV_VIEW.NAME = FFVC.FLEX_VALUE' ||
                     ' and FFVC.FLEX_VALUE_SET_ID = :l_value_set_id' ||
                     ' and FFVC.PARENT_FLEX_VALUE = PARENT_STAGING.NAME' ||
                     ' and PARENT_STAGING.COLLECTION_STATUS = ''READY''';
   */

   l_where_clause := ' where LCV_VIEW.CATEGORY_SET_NAME = :l_category_set_name' ||
                     ' and LCV_VIEW.NAME = FFVC.FLEX_VALUE' ||
                     ' and FFVC.FLEX_VALUE_SET_ID = :l_value_set_id' ||
                     ' and FFVC.PARENT_FLEX_VALUE = PARENT_STAGING.NAME' ||
                     ' and PARENT_STAGING.COLLECTION_STATUS = ''READY''';


      IF l_catset_lvl1_flag = 'Y' /* vbh greater than catset lvls */
      THEN                        /* don't SELECT children that already exist in staging table */
        l_not_exists_clause := ' AND not exists '||
                               ' (SELECT NULL '||
                               ' FROM '||l_staging_table_name||' STAGING'||
                               ' WHERE SUBSTRB(STAGING.CATEGORY_PK,3) = LCV_VIEW.CATEGORY_PK ||'||''''||'-'||l_instance||'''' ||  /* Bug# 2558245 */
                               ' AND   STAGING.COLLECTION_STATUS = ''READY'')';

        l_where_clause := l_where_clause||l_not_exists_clause;

      END IF; /* vbh greater than catset levels */

    END IF; /* top level */

    -- Construct INSERT INTO staging table

    l_stmt:=  'INSERT INTO '||l_staging_table_name||' ('||
              l_fk_name || ','||
              l_fk_key || ','||
              ' CATEGORY_NAME,'||
              ' CATEGORY_SET_NAME,'||
              ' CREATION_DATE,' ||
              ' DESCRIPTION,'||
              ' ERROR_CODE,' ||
              ' INSTANCE,' ||
              ' CATEGORY_DP,'||
              ' CATEGORY_PK,'||
              ' CATEGORY_ID,'||
              ' CATEGORY_SET_ID,'||
              ' LAST_UPDATE_DATE,' ||
              ' NAME,' ||
              ' REQUEST_ID,' ||
              ' ROW_ID,' ||
              ' USER_ATTRIBUTE1,' ||
              ' USER_ATTRIBUTE2,' ||
              ' USER_ATTRIBUTE3,' ||
              ' USER_ATTRIBUTE4,' ||
              ' USER_ATTRIBUTE5,' ||
              ' OPERATION_CODE,' ||
              ' COLLECTION_STATUS ) '||
              ' SELECT '||
              l_fk_value || ','||
              ' NULL,' ||
              ' NULL,' ||
              ' LCV_VIEW.CATEGORY_SET_NAME,'||
              ' LCV_VIEW.CREATION_DATE,' ||
              ' FFVC.DESCRIPTION,'||
              ' NULL,' ||
              '''' || l_instance || '''' || ',' ||  /* Bug# 2558245 */
              ' LCV_VIEW.CATEGORY_DP,' ||
              ''''||TO_CHAR(p_control_level)||'-'||''''||'||'|| 'LCV_VIEW.CATEGORY_PK' ||'||' ||''''||'-'||l_instance||''',' ||  /* Bug# 2558245 */
              ' LCV_VIEW.CATEGORY_ID,'||
              ' LCV_VIEW.CATEGORY_SET_ID,'||
              ' LCV_VIEW.LAST_UPDATE_DATE,' ||
              ' SUBSTRB(LCV_VIEW.NAME, 1, 320),' ||
              ' NULL,' ||
              ' NULL,' ||
              ' LCV_VIEW.USER_ATTRIBUTE1,' ||
              ' LCV_VIEW.USER_ATTRIBUTE2,' ||
              ' LCV_VIEW.USER_ATTRIBUTE3,' ||
              ' LCV_VIEW.USER_ATTRIBUTE4,' ||
              ' LCV_VIEW.USER_ATTRIBUTE5,' ||
              ' NULL,' ||
              '''READY'''||
              l_from_clause||
              l_where_clause;

    edw_log.put_line(l_stmt);
  --  edw_log.put_line(l_from_clause);
  --  edw_log.put_line(l_where_clause);
    l_rows_inserted := SQL%ROWCOUNT ;
    edw_log.debug_line('Parse the cursor');
    dbms_sql.parse(l_cursor,l_stmt,dbms_sql.native);

    edw_log.debug_line('Bind l_category_set_name variable, and last_update dates');
    dbms_sql.bind_variable(l_cursor,':l_category_set_name',p_category_set_name);
    -- Bug# 3296641 dbms_sql.bind_variable(l_cursor,':l_push_date_range1',p_from_date);
    -- Bug# 3296641 dbms_sql.bind_variable(l_cursor,':l_push_date_range2',p_to_date);
    dbms_sql.bind_variable(l_cursor,':l_value_set_id',l_vbh_value_set_id);

    IF l_catset_lvl = p_no_of_catset_lvls THEN
      dbms_sql.bind_variable(l_cursor,':l_hrchy_top_node',p_hrchy_top_node);
    END IF;

    edw_log.debug_line('Pushing data, Executing the cursor');
    l_rows_inserted:=dbms_sql.execute(l_cursor);

    edw_log.debug_line('Close the cursor');
    dbms_sql.close_CURSOR(l_cursor);
    edw_log.debug_line(' ');

    edw_log.put_line('Inserted '||TO_CHAR(l_rows_inserted)||
         ' rows into the staging table');
    edw_log.put_line(' ');

    -- if there were no children found then end loop
    IF l_rows_inserted = 0 THEN
      l_lower_lvl_exists := FALSE;
    ELSE

      -- if already at level 1 then do not decrement counter, continue
      -- to INSERT hierarchy INTO level 1
      IF l_catset_lvl <> 1 THEN
        l_catset_lvl := l_catset_lvl - 1;
      ELSE /* level 1 has already been processed, hence we know that vbh levels > catset levels */
        l_catset_lvl1_flag := 'Y';
      END IF; /* check if already at level 1 */

    END IF; /* check if children exist in hierarchy */

  END LOOP;
END Insert_VBH_Category;

-- New procedure for supporting Product Hierarchy re-architechture (11.5.9)
PROCEDURE INSERT_CATEGORY_HIERARCHY(
               p_from_date              DATE,
               p_to_date                DATE,
               p_view_name              VARCHAR2,
               p_category_set_name      VARCHAR2,
               p_category_set_id        NUMBER,
               p_no_of_catset_lvls      NUMBER,
               p_control_level          NUMBER) IS

  l_stmt                      VARCHAR2(7000) := NULL;
  l_cursor                    NUMBER;
  l_rows_inserted             NUMBER := 0;
  l_fk_name                   VARCHAR2(40);
  l_fk_value                  VARCHAR2(40);
  l_fk_key                    VARCHAR2(40);
  l_from_clause               VARCHAR2(2000) := NULL;
  l_where_clause              VARCHAR2(2000) := NULL;
  l_not_exists_clause         VARCHAR2(1000) := NULL;
  l_catset_control_level      NUMBER;
  l_mult_item_flag            VARCHAR2(1);
  l_lower_lvl_exists          BOOLEAN := TRUE;
  l_staging_table_name        VARCHAR2(30);
  l_prior_staging_table_name  VARCHAR2(30); -- as per staging table but for prior level
  l_prior_lvl_no              NUMBER := 0;
  l_catset_lvl                NUMBER := 0;
  l_catset_lvl1_flag          VARCHAR2(1):= 'N';
  l_validate_flag             VARCHAR2(1);

  INCORRECT_CTRL_LVL          EXCEPTION;
  MULTIPLE_CAT_ALLOWED        EXCEPTION;

  CURSOR l_chk_ctrl_lvl_csr (c_category_set_id VARCHAR2) is
    SELECT CONTROL_LEVEL, MULT_ITEM_CAT_ASSIGN_FLAG, VALIDATE_FLAG
    FROM   MTL_CATEGORY_SETS_VL
    WHERE  CATEGORY_SET_ID = c_category_set_id;

BEGIN

  OPEN l_chk_ctrl_lvl_csr (p_category_set_id);
  FETCH l_chk_ctrl_lvl_csr INTO l_catset_control_level, l_mult_item_flag, l_validate_flag;
  CLOSE l_chk_ctrl_lvl_csr;

  BEGIN
    -- Check that the Category Set is still assigned at the Item Level
    edw_log.debug_line(' ');
    edw_log.debug_line('Check that the Category Set is still assigned at the Item Level');

    IF l_catset_control_level <> 1 THEN
      RAISE INCORRECT_CTRL_LVL;
    END IF;

    -- Check that the Category Set does not allow multiple assignments
    -- of items to categories
    edw_log.debug_line(' ');
    edw_log.debug_line('Check that the Category Set does not allow multiple assignments of items to categories');

    IF l_mult_item_flag = 'Y' THEN
      RAISE MULTIPLE_CAT_ALLOWED;
    END IF;

    IF NVL(l_validate_flag, 'N') = 'Y' THEN
      edw_log.put_line('WARNING! : Enforce List of Valid categories is FALSE for Hierarchy Enabled Category set - '||p_category_set_name);
    END IF;
  EXCEPTION
    WHEN INCORRECT_CTRL_LVL THEN
      g_error_message := 'Category Set is controlled at the Organization Level for '||p_category_set_name;
      RAISE;
    WHEN MULTIPLE_CAT_ALLOWED THEN
      g_error_message := 'Multiple assignments of items to categories is allowed for '||p_category_set_name;
      RAISE;
    WHEN OTHERS THEN
      RAISE;
  END;

  --
  -- Loop to insert categories FROM Value Based Hierarchy
  -- into number of levels available. On each loop all children of
  -- the categories Inserted into the prior level table
  -- are Inserted into the current staging table
  --

  -- Start at top level and work down the category set table hierarchy
  l_catset_lvl := p_no_of_catset_lvls;

  -- Loop until there are no lower levels in the VBH hierarchy
  WHILE l_lower_lvl_exists LOOP
    l_cursor:=dbms_sql.OPEN_CURSOR;
    --
    -- Build staging table name
    --
    l_staging_table_name := 'EDW_ITEM_CATSETI3_C' || l_catset_lvl || '_LSTG';

    edw_log.debug_line(' ');
    edw_log.debug_line('In Loading Category Set Hierarchy ');
    edw_log.debug_line('Constructing the sql statement for ' || l_staging_table_name || ' AND pushing category set ' || p_category_set_name);

    IF l_catset_lvl = p_no_of_catset_lvls THEN /* top level */
      l_fk_name := ' ALL_FK';
      l_fk_key := ' ALL_FK_KEY';
      l_fk_value := ' ALL_FK';

      -- Construct the FROM clause for top level

      l_from_clause := ' from ' || 'MTL_CATEGORY_SET_VALID_CATS CATH'
                       || ',' || p_view_name || ' LCV_VIEW';

      -- Construct the WHERE clause for top level

      l_where_clause := ' where LCV_VIEW.CATEGORY_SET_NAME = :l_category_set_name' ||
                        ' and LCV_VIEW.CATEGORY_ID = CATH.CATEGORY_ID' ||
                        ' and CATH.CATEGORY_SET_ID = :l_cat_set_id' ||
                        ' and CATH.PARENT_CATEGORY_ID IS NULL';

    ELSE /* Not top level */
      --
      -- Build prior level staging table name
      --
      IF l_catset_lvl1_flag = 'Y' /* hierarchy greater than catset lvls, */
      THEN                        /* hence SELECT FROM AND INSERT INTO lowest lvl table */
        l_prior_staging_table_name := l_staging_table_name;
      ELSE
        l_prior_lvl_no := l_catset_lvl + 1;
        l_prior_staging_table_name := 'EDW_ITEM_CATSETI3_C' ||l_prior_lvl_no|| '_LSTG';
      END IF;

      l_fk_name := ' CATEGORY_FK';
      l_fk_key := ' CATEGORY_FK_KEY';

      IF l_catset_lvl1_flag = 'Y' /* hierarchy greater than catset lvls */
      THEN                        /* need fk on parent record rather than actual parent pk */
        l_fk_value := 'PARENT_STAGING.CATEGORY_FK';
      ELSE
        l_fk_value := 'PARENT_STAGING.CATEGORY_PK';
      END IF;

      -- Construct the FROM clause for levels other than the top

      l_from_clause := ' from ' || l_prior_staging_table_name || ' PARENT_STAGING, '
                       || ' MTL_CATEGORY_SET_VALID_CATS CATH'
                       || ',' || p_view_name || ' LCV_VIEW';

      -- Construct the WHERE clause levels other than the top

      l_where_clause :=  ' where LCV_VIEW.CATEGORY_SET_NAME = :l_category_set_name' ||
                         ' and LCV_VIEW.CATEGORY_ID = CATH.CATEGORY_ID' ||
                         ' and CATH.CATEGORY_SET_ID = :l_cat_set_id' ||
                         ' and CATH.PARENT_CATEGORY_ID = PARENT_STAGING.CATEGORY_ID' ||
                         ' and PARENT_STAGING.COLLECTION_STATUS = ''READY''';


      IF l_catset_lvl1_flag = 'Y' /* hierarchy greater than catset lvls */
      THEN                        /* don't SELECT children that already exist in staging table */
        l_not_exists_clause := ' AND not exists '||
                               ' (SELECT NULL '||
                               ' FROM '||l_staging_table_name||' STAGING'||
                               ' WHERE SUBSTRB(STAGING.CATEGORY_PK,3) = LCV_VIEW.CATEGORY_PK ||'||''''||'-'||l_instance||'''' ||  /* Bug# 2558245 */
                               ' AND   STAGING.COLLECTION_STATUS = ''READY'')';

        l_where_clause := l_where_clause||l_not_exists_clause;

      END IF; /* vbh greater than catset levels */
    END IF; /* top level */

    -- Construct INSERT INTO staging table

    l_stmt:=  'INSERT INTO '||l_staging_table_name||' ('||
              l_fk_name || ','||
              l_fk_key || ','||
              ' CATEGORY_NAME,'||
              ' CATEGORY_SET_NAME,'||
              ' CREATION_DATE,' ||
              ' DESCRIPTION,'||
              ' ERROR_CODE,' ||
              ' INSTANCE,' ||
              ' CATEGORY_DP,'||
              ' CATEGORY_PK,'||
              ' CATEGORY_ID,'||
              ' CATEGORY_SET_ID,'||
              ' LAST_UPDATE_DATE,' ||
              ' NAME,' ||
              ' REQUEST_ID,' ||
              ' ROW_ID,' ||
              ' USER_ATTRIBUTE1,' ||
              ' USER_ATTRIBUTE2,' ||
              ' USER_ATTRIBUTE3,' ||
              ' USER_ATTRIBUTE4,' ||
              ' USER_ATTRIBUTE5,' ||
              ' OPERATION_CODE,' ||
              ' COLLECTION_STATUS ) '||
              ' SELECT '||
              l_fk_value || ','||
              ' NULL,' ||
              ' NULL,' ||
              ' LCV_VIEW.CATEGORY_SET_NAME,'||
              ' LCV_VIEW.CREATION_DATE,' ||
              ' LCV_VIEW.DESCRIPTION,'||
              ' NULL,' ||
              '''' || l_instance || '''' || ',' ||  /* Bug# 2558245 */
              ' LCV_VIEW.CATEGORY_DP,' ||
              ''''||TO_CHAR(p_control_level)||'-'||''''||'||'|| 'LCV_VIEW.CATEGORY_PK' ||'||' ||''''||'-'||l_instance||''',' ||  /* Bug# 2558245 */
              ' LCV_VIEW.CATEGORY_ID,'||
              ' LCV_VIEW.CATEGORY_SET_ID,'||
              ' LCV_VIEW.LAST_UPDATE_DATE,' ||
              ' SUBSTRB(LCV_VIEW.NAME, 1, 320),' ||
              ' NULL,' ||
              ' NULL,' ||
              ' LCV_VIEW.USER_ATTRIBUTE1,' ||
              ' LCV_VIEW.USER_ATTRIBUTE2,' ||
              ' LCV_VIEW.USER_ATTRIBUTE3,' ||
              ' LCV_VIEW.USER_ATTRIBUTE4,' ||
              ' LCV_VIEW.USER_ATTRIBUTE5,' ||
              ' NULL,' ||
              '''READY'''||
              l_from_clause||
              l_where_clause;

    edw_log.put_line(l_stmt);
  --  edw_log.put_line(l_from_clause);
  --  edw_log.put_line(l_where_clause);
    l_rows_inserted := SQL%ROWCOUNT ;
    edw_log.debug_line('Parse the cursor');
    dbms_sql.parse(l_cursor,l_stmt,dbms_sql.native);

    edw_log.debug_line('Bind l_category_set_name variable, and last_update dates');
    dbms_sql.bind_variable(l_cursor,':l_category_set_name',p_category_set_name);
    dbms_sql.bind_variable(l_cursor,':l_cat_set_id',p_category_set_id);

/*    IF l_catset_lvl = p_no_of_catset_lvls THEN
      dbms_sql.bind_variable(l_cursor,':l_hrchy_top_node',p_hrchy_top_node);
    END IF;
*/
    edw_log.debug_line('Pushing data, Executing the cursor');
    l_rows_inserted:=dbms_sql.execute(l_cursor);

    edw_log.debug_line('Close the cursor');
    dbms_sql.close_CURSOR(l_cursor);
    edw_log.debug_line(' ');

    edw_log.put_line('Inserted '||TO_CHAR(l_rows_inserted)||
         ' rows into the staging table');
    edw_log.put_line(' ');

    -- if there were no children found then end loop
    IF l_rows_inserted = 0 THEN
      l_lower_lvl_exists := FALSE;
    ELSE
      -- if already at level 1 then do not decrement counter, continue
      -- to INSERT hierarchy INTO level 1
      IF l_catset_lvl <> 1 THEN
        l_catset_lvl := l_catset_lvl - 1;
      ELSE /* level 1 has already been processed, hence we know that vbh levels > catset levels */
        l_catset_lvl1_flag := 'Y';
      END IF; /* check if already at level 1 */
    END IF; /* check if children exist in hierarchy */

  END LOOP;
END INSERT_CATEGORY_HIERARCHY;


PROCEDURE Push_Category(
               p_from_date          DATE ,
               p_to_date            DATE ,
               p_item_item_org      NUMBER) IS

  --p_item_item_org=0 is for items and p_item_item_org=1 is for item/org

  l_staging_table_name        VARCHAR2(30); -- have to concat the rest depending
                                            -- on the staging table
  l_view_name                 VARCHAR2(40);
  l_pk_name                   VARCHAR2(40);
  l_dp                        VARCHAR2(40);
  l_functional_area           NUMBER;
  l_control_level             NUMBER;
  l_push_date_range1          DATE := NULL;
  l_push_date_range2          DATE := NULL;
  l_rows_inserted             NUMBER := 0;
  l_stmt                      VARCHAR2(5000) := NULL;
  l_cursor                    NUMBER;
  l_item_revision_pk          VARCHAR2(320) := 'NA_EDW';
  i2                          NUMBER := 0;
  l_catset1_category_fk       VARCHAR2(40) := NULL;
  l_catset2_category_fk       VARCHAR2(40) := NULL;
  l_catset3_category_fk       VARCHAR2(40) := NULL;
  l_catset_category_fk        VARCHAR2(40) := NULL;
  l_item_catset_name          VARCHAR2(40) := NULL;
  l_level_name                VARCHAR2(5) := NULL;
  l_all_items                 VARCHAR2(100);
  l_all_item_orgs             VARCHAR2(100);
  l_all_item_revs             VARCHAR2(100);
  l_catset3_id                NUMBER;
  l_hrchy_enabled             VARCHAR2(1);

  -- Local VBH variables
  l_prior_staging_table_name  VARCHAR2(30); -- as per staging table but for prior level
  l_prior_level_no            NUMBER := 0;
  l_hierarchy_stmt            VARCHAR2(2000);
  l_inv_schema                VARCHAR2(100) :='INV';
  --
  -- CURSOR to push categories down to lower levels
  -- Accepts user-assigned category set name for each category hierarchy push-down
  --
  CURSOR l_itemrev_csr(c_category_set_name VARCHAR2) is
    SELECT
      CATEGORY_PK || '-' || l_instance CATEGORY_PK, /* Bug# 2558245 */
      CREATION_DATE,
      l_instance INSTANCE, -- INSTANCE /* Bug# 2558245 */
      'NA_EDW' ITEM_ORG_FK,
      NULL ITEM_ORG_FK_KEY,
      NULL ITEM_REVISION,
      CATEGORY_ID,
      CATEGORY_SET_ID,
      LAST_UPDATE_DATE,
      SUBSTRB('(' || NAME || ')', 1, 320) NAME,
      'READY' COLLECTION_STATUS
      FROM edw_item_item_org_cat_lcv
      WHERE last_update_date BETWEEN l_push_date_range1 AND l_push_date_range2 AND category_set_name = c_category_set_name;

  -- 3296641
  -- CURSOR to push VBH categories down to lower levels
  --
  CURSOR l_itemrev_vbh_csr(c_category_set_name VARCHAR2) is
    SELECT
      CATEGORY_PK || '-' || l_instance CATEGORY_PK, /* Bug# 2558245 */
      CREATION_DATE,
      l_instance INSTANCE, -- INSTANCE /* Bug# 2558245 */
      'NA_EDW' ITEM_ORG_FK,
      NULL ITEM_ORG_FK_KEY,
      NULL ITEM_REVISION,
      CATEGORY_ID,
      CATEGORY_SET_ID,
      LAST_UPDATE_DATE,
      SUBSTRB('(' || NAME || ')', 1, 320) NAME,
      'READY' COLLECTION_STATUS
      FROM edw_item_item_org_cat_lcv
      WHERE category_set_name = c_category_set_name;

BEGIN

  -- Getting lookup values for Push Down rows

  l_all_items := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_ITEM');
  l_all_item_orgs := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_IORG');
  l_all_item_revs := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_IREV');

  l_push_date_range1:=p_from_date;
  l_push_date_range2:=p_to_date;

  -- dynamic sql necessary for all the 16 staging tables
  edw_log.put_line('Determining the collection view to SELECT FROM');

  IF p_item_item_org=0 THEN
    l_view_name:='edw_item_item_cat_lcv';
  ELSE
    l_view_name:='edw_item_item_org_cat_lcv';
  END IF;

  edw_log.put_line('Determining the control level');

  IF p_item_item_org = 0 THEN
   l_control_level := 2;
  ELSE
   l_control_level := 1;
  END IF;

  l_cursor:=dbms_sql.OPEN_CURSOR;

  edw_log.put_line('Pushing Categories');

  IF p_item_item_org=1 THEN
    --
    -- Pushing Item Org Categories
    --

    IF (l_itemorg_catset1_name <> 'NA_EDW') THEN

      --
      -- Loop to INSERT categories INTO 6 level tables
      --
      FOR i2 IN 1..6 LOOP

        --
        -- Build staging table name
        --
        l_staging_table_name := 'EDW_ITEM_CATSET1_C' || i2 || '_LSTG';

        --
        -- Calling function to Push Categories
        --
        Insert_Category(
                    p_from_date => l_push_date_range1,
                    p_to_date   => l_push_date_range2,
                    p_staging_table_name => l_staging_table_name,
                    p_view_name => l_view_name,
                    p_category_set_name => l_itemorg_catset1_name,
                    p_control_level => l_control_level);
      END LOOP;
    END IF;
  ELSE
    --
    -- Pushing Item Categories
    --
    IF (l_item_catset1_name <> 'NA_EDW') THEN

      --
      -- Loop to INSERT categories INTO 6 level tables
      --
      FOR i2 IN 1..6 LOOP

        --
        -- Build staging table name
        --
        l_staging_table_name := 'EDW_ITEM_CATSETI1_C' || i2 || '_LSTG';

        --
        -- Calling function to Push Categories
        --
        Insert_Category(
                  p_from_date => l_push_date_range1,
                  p_to_date   => l_push_date_range2,
                  p_staging_table_name => l_staging_table_name,
                  p_view_name => l_view_name,
                  p_category_set_name => l_item_catset1_name,
                  p_control_level => l_control_level);

      END LOOP;
    END IF;

    IF (l_item_catset2_name <> 'NA_EDW') THEN

      --
      -- Loop to INSERT categories INTO 6 level tables
      --
      FOR i2 IN 1..6 LOOP

        --
        -- Build staging table name
        --
        l_staging_table_name := 'EDW_ITEM_CATSETI2_C' || i2 || '_LSTG';

        --
        -- Calling function to Push Categories
        --
        Insert_Category(
                  p_from_date => l_push_date_range1,
                  p_to_date   => l_push_date_range2,
                  p_staging_table_name => l_staging_table_name,
                  p_view_name => l_view_name,
                  p_category_set_name => l_item_catset2_name,
                  p_control_level => l_control_level);

      END LOOP;
    END IF;

    -- For Category Set Hierarchy 3, check whether the collection type
    -- is FROM a category set or value based hierarchy

    IF (l_itm_hrchy3_coll_type = 'V') THEN

      --
      -- Processing for Value Based Hierarchy Collection
      --

      --
      -- Calling function to Push Child Categories
      --
      Insert_VBH_Category(
                  p_from_date => l_push_date_range1,
                  p_to_date   => l_push_date_range2,
                  p_view_name => 'EDW_ITEM_VBH_CAT_LCV',
                  p_category_set_name => l_item_catset3_name,
                  p_no_of_catset_lvls => 10,
                  p_hrchy_top_node => l_itm_hrchy3_vbh_top_node,
                  p_control_level => l_control_level);

      --
      -- Loop to INSERT VBH categories FROM prior level tables
      --
      FOR i2 IN reverse 1..9 LOOP

        --
        -- Build staging table names
        --
        l_staging_table_name := 'EDW_ITEM_CATSETI3_C' || i2 || '_LSTG';

        --
        -- Build parent staging table name
        --
        l_prior_level_no := i2+1;
        l_prior_staging_table_name := 'EDW_ITEM_CATSETI3_C' ||l_prior_level_no|| '_LSTG';

        --
        -- Calling function to Push Categories
        --
        Insert_Category(
                  p_from_date => l_push_date_range1,
                  p_to_date   => l_push_date_range2,
                  p_staging_table_name => l_staging_table_name,
                  p_view_name => l_prior_staging_table_name,
                  p_category_set_name => l_item_catset3_name,
                  p_control_level => l_control_level);

      END LOOP;

      -- If any category exists in the category assignment but is
      -- not part of the hierarchy need to INSERT this category
      -- with an FK of NA_EDW

      BEGIN

        INSERT INTO EDW_ITEM_CATSETI3_C1_LSTG
          (CATEGORY_FK,
          CATEGORY_FK_KEY,
          CATEGORY_NAME,
          CATEGORY_SET_NAME,
          CREATION_DATE,
          DESCRIPTION,
          ERROR_CODE,
          INSTANCE,
          CATEGORY_DP,
          CATEGORY_PK,
          CATEGORY_ID,
          CATEGORY_SET_ID,
          LAST_UPDATE_DATE,
          NAME,
          REQUEST_ID,
          ROW_ID,
          USER_ATTRIBUTE1,
          USER_ATTRIBUTE2,
          USER_ATTRIBUTE3,
          USER_ATTRIBUTE4,
          USER_ATTRIBUTE5,
          OPERATION_CODE,
          COLLECTION_STATUS )
        SELECT
          'NA_EDW',
          NULL,
          NULL,
          CATEGORY_SET_NAME,
          CREATION_DATE,
          DESCRIPTION,
          NULL,
          l_instance,  /* Bug# 2558245 */
          CATEGORY_DP,
          TO_CHAR(l_control_level) || '-' || CATEGORY_PK || '-' || l_instance, /* Bug# 2558245 */
          CATEGORY_ID,
          CATEGORY_SET_ID,
          LAST_UPDATE_DATE,
          SUBSTRB(NAME, 1, 320),
          NULL,
          NULL,
          USER_ATTRIBUTE1,
          USER_ATTRIBUTE2,
          USER_ATTRIBUTE3,
          USER_ATTRIBUTE4,
          USER_ATTRIBUTE5,
          NULL,
          'READY'
        FROM  EDW_ITEM_ITEM_CAT_LCV LCV
        WHERE LCV.LAST_UPDATE_DATE BETWEEN l_push_date_range1 AND l_push_date_range2
          AND LCV.CATEGORY_SET_NAME = l_item_catset3_name
          AND NOT EXISTS
                        (SELECT NULL
                         FROM EDW_ITEM_CATSETI3_C1_LSTG LSTG
                         WHERE SUBSTRB(LSTG.CATEGORY_PK, 3) = LCV.CATEGORY_PK || '-' || l_instance  /* Bug 2558245 */
                           AND LSTG.CATEGORY_SET_NAME = l_item_catset3_name
                           AND LSTG.COLLECTION_STATUS = 'READY')
          AND EXISTS /* Bug# 2559696 Removed the use of EDW_ITEMS_CATEGORY_FKV by dsakalle */
                    (SELECT NULL
                     FROM
                       MTL_ITEM_CATEGORIES cat,
                       MTL_CATEGORY_SETS_TL tl
                     WHERE tl.CATEGORY_SET_NAME = l_item_catset3_name
                       AND cat.CATEGORY_ID = LCV.CATEGORY_ID
                       AND cat.CATEGORY_SET_ID = tl.CATEGORY_SET_ID);

      EXCEPTION
        WHEN OTHERS THEN RAISE;
      END;

    ELSIF (l_itm_hrchy3_coll_type = 'C') THEN
    -- Supporting Product Hierarchy Re-Architecture in 11.5.9

     BEGIN   -- Bug 3514304

       SELECT 1 into l_column_exists
         FROM all_tab_columns
        WHERE table_name = 'MTL_CATEGORY_SETS_B'
          AND column_name = 'HIERARCHY_ENABLED'
          AND owner = l_inv_schema;

       edw_log.put_line(' Hierarchy enabled column exists');

       BEGIN


        -- edw_log.put_line('in hrchy col type = C' );

        -- Bug 3424451
        -- Changing the static sql to dynamic sql to make the package
        -- backward compatible.
        l_rows_inserted := 0;
        l_cursor := dbms_sql.open_cursor;

        l_hierarchy_stmt := 'SELECT HIERARCHY_ENABLED, CATEGORY_SET_ID'||
                            ' FROM MTL_CATEGORY_SETS ' ||
                            ' WHERE CATEGORY_SET_NAME = :l_catset3_name';

       edw_log.put_line('Constructing the SQL statement: ' || l_hierarchy_stmt);

        dbms_sql.parse(l_cursor,l_hierarchy_stmt,dbms_sql.native);
        dbms_sql.bind_variable(l_cursor,':l_catset3_name', l_item_catset3_name);
        dbms_sql.define_column(l_cursor, 1, l_hrchy_enabled, 1);
        dbms_sql.define_column(l_cursor, 2, l_catset3_id);

        l_rows_inserted := dbms_sql.execute_and_fetch(l_cursor, true);

        edw_log.put_line('rows inserted ' || l_rows_inserted);

        if l_rows_inserted > 0 then
           dbms_sql.column_value(l_cursor, 1, l_hrchy_enabled);
           dbms_sql.column_value(l_cursor, 2, l_catset3_id);
          --  edw_log.put_line('l_hrchy_enabled ' || l_hrchy_enabled);
        end if;

        dbms_sql.close_cursor(l_cursor);

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- edw_log.put_line('in exception ');
            null;
        END;

      EXCEPTION
       WHEN NO_DATA_FOUND THEN
          edw_log.put_line(' Hierarchy enabled column does not exist');
          l_hrchy_enabled := 'N';
      END;

      IF NVL(l_hrchy_enabled, 'N') = 'Y' THEN
        -- If hierarchy is enabled then pushing hierarchical records
        --
        -- Calling function to Push Child Categories
        --
        INSERT_CATEGORY_HIERARCHY(
                    p_from_date => l_push_date_range1,
                    p_to_date   => l_push_date_range2,
                    p_view_name => l_view_name,
                    p_category_set_name => l_item_catset3_name,
                    p_category_set_id => l_catset3_id,
                    p_no_of_catset_lvls => 10,
                    p_control_level => l_control_level);

        --
        -- Loop to INSERT VBH categories FROM prior level tables
        --
        FOR i2 IN reverse 1..9 LOOP

          --
          -- Build staging table names
          --
          l_staging_table_name := 'EDW_ITEM_CATSETI3_C' || i2 || '_LSTG';

          --
          -- Build parent staging table name
          --
          l_prior_level_no := i2+1;
          l_prior_staging_table_name := 'EDW_ITEM_CATSETI3_C' ||l_prior_level_no|| '_LSTG';

          --
          -- Calling function to Push Categories
          --
          Insert_Category(
                    p_from_date => l_push_date_range1,
                    p_to_date   => l_push_date_range2,
                    p_staging_table_name => l_staging_table_name,
                    p_view_name => l_prior_staging_table_name,
                    p_category_set_name => l_item_catset3_name,
                    p_control_level => l_control_level);

        END LOOP;

        -- If any category exists in the category assignment but is
        -- not part of the hierarchy need to INSERT this category
        -- with an FK of NA_EDW

        BEGIN

          INSERT INTO EDW_ITEM_CATSETI3_C1_LSTG
            (CATEGORY_FK,
            CATEGORY_FK_KEY,
            CATEGORY_NAME,
            CATEGORY_SET_NAME,
            CREATION_DATE,
            DESCRIPTION,
            ERROR_CODE,
            INSTANCE,
            CATEGORY_DP,
            CATEGORY_PK,
            CATEGORY_ID,
            CATEGORY_SET_ID,
            LAST_UPDATE_DATE,
            NAME,
            REQUEST_ID,
            ROW_ID,
            USER_ATTRIBUTE1,
            USER_ATTRIBUTE2,
            USER_ATTRIBUTE3,
            USER_ATTRIBUTE4,
            USER_ATTRIBUTE5,
            OPERATION_CODE,
            COLLECTION_STATUS )
          SELECT
            'NA_EDW',
            NULL,
            NULL,
            CATEGORY_SET_NAME,
            CREATION_DATE,
            DESCRIPTION,
            NULL,
            l_instance,  /* Bug# 2558245 */
            CATEGORY_DP,
            TO_CHAR(l_control_level) || '-' || CATEGORY_PK || '-' || l_instance, /* Bug# 2558245 */
            CATEGORY_ID,
            CATEGORY_SET_ID,
            LAST_UPDATE_DATE,
            SUBSTRB(NAME, 1, 320),
            NULL,
            NULL,
            USER_ATTRIBUTE1,
            USER_ATTRIBUTE2,
            USER_ATTRIBUTE3,
            USER_ATTRIBUTE4,
            USER_ATTRIBUTE5,
            NULL,
            'READY'
          FROM  EDW_ITEM_ITEM_CAT_LCV LCV
          WHERE LCV.LAST_UPDATE_DATE BETWEEN l_push_date_range1 AND l_push_date_range2
            AND LCV.CATEGORY_SET_NAME = l_item_catset3_name
            AND NOT EXISTS
                          (SELECT NULL
                           FROM EDW_ITEM_CATSETI3_C1_LSTG LSTG
                           WHERE SUBSTRB(LSTG.CATEGORY_PK, 3) = LCV.CATEGORY_PK || '-' || l_instance  /* Bug 2558245 */
                             AND LSTG.CATEGORY_SET_NAME = l_item_catset3_name
                             AND LSTG.COLLECTION_STATUS = 'READY')
            AND EXISTS /* Bug# 2559696 Removed the use of EDW_ITEMS_CATEGORY_FKV by dsakalle */
                      (SELECT NULL
                       FROM
                         MTL_ITEM_CATEGORIES cat,
                         MTL_CATEGORY_SETS_TL tl
                       WHERE tl.CATEGORY_SET_NAME = l_item_catset3_name
                         AND cat.CATEGORY_ID = LCV.CATEGORY_ID
                         AND cat.CATEGORY_SET_ID = tl.CATEGORY_SET_ID);

        EXCEPTION
          WHEN OTHERS THEN RAISE;
        END;
      ELSE
      -- when Hierarchy is not enabled
        --
        -- Processing for Category Set Collection
        --

        --
        -- Loop to INSERT categories INTO 10 level tables
        --
        FOR i2 IN 1..10 LOOP

          --
          -- Build staging table name
          --
          l_staging_table_name := 'EDW_ITEM_CATSETI3_C' || i2 || '_LSTG';

          --
          -- Calling function to Push Categories
          --
          Insert_Category(
                    p_from_date => l_push_date_range1,
                    p_to_date   => l_push_date_range2,
                    p_staging_table_name => l_staging_table_name,
                    p_view_name => l_view_name,
                    p_category_set_name => l_item_catset3_name,
                    p_control_level => l_control_level);
        END LOOP;
      END IF; -- hierarchy enabled
    END IF; /* Check Collection Type */
    -- Supporting Product Hierarchy Re-Architecture in 11.5.9 END
  END IF;

  IF (p_item_item_org=1) AND (l_itemorg_catset1_name <> 'NA_EDW') THEN

    edw_log.put_line(' ');
    edw_log.put_line('Pushing categories to lower levels (EDW_ITEM_ITEMREV, EDW_ITEM_ITEMORG)');
    l_rows_inserted := 0;

    --
    -- Pushing down rows for each hierarchy FROM CURSOR
    --

    FOR l_itemrev_rec IN l_itemrev_csr(l_itemorg_catset1_name) LOOP
      l_catset_category_fk := TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK;
      l_level_name := '-COCT';

      INSERT INTO EDW_ITEM_ITEMORG_LSTG(
        ITEM_ORG_PK,
        CATSET_CATEGORY_FK,
        NAME,
        INSTANCE,
        COLLECTION_STATUS,
        ITEM_NUMBER_FK,
        PROD_FAMILY_FK,
        CATEGORY_ID,
        CATEGORY_SET_ID,
        LAST_UPDATE_DATE)
      VALUES (
        SUBSTRB(l_catset_category_fk || l_level_name, 1, 1000),
        l_catset_category_fk,
        SUBSTRB(l_all_item_orgs||'('||l_itemrev_rec.NAME||')', 1, 320),
        SUBSTRB(l_itemrev_rec.INSTANCE, 1, 30),
        'READY',
        'NA_EDW',
        'NA_EDW',
        l_itemrev_rec.CATEGORY_ID,
        l_itemrev_rec.CATEGORY_SET_ID,
        l_itemrev_rec.last_update_date
        );

      l_rows_inserted := l_rows_inserted + 1;

      INSERT INTO EDW_ITEM_ITEMREV_LSTG(
        ITEM_REVISION_PK,
        ITEM_ORG_FK,
        INSTANCE,
        NAME,
        CATEGORY_ID,
        CATEGORY_SET_ID,
        COLLECTION_STATUS,
        LAST_UPDATE_DATE)
      VALUES (
        SUBSTRB(l_catset_category_fk || l_level_name, 1, 320),
        SUBSTRB(l_catset_category_fk || l_level_name, 1, 320),
        SUBSTRB(l_itemrev_rec.INSTANCE, 1, 30),
        SUBSTRB(l_all_item_revs||'('||l_itemrev_rec.Name||')', 1, 320),
        l_itemrev_rec.CATEGORY_ID,
        l_itemrev_rec.CATEGORY_SET_ID,
        'READY',
        l_itemrev_rec.last_update_date);

      l_rows_inserted := l_rows_inserted + 1;
    END LOOP;

    edw_log.put_line('Inserted '||TO_CHAR(NVL(l_rows_inserted,0))||
          ' rows into the lower level staging tables');
    edw_log.put_line(' ');
    EDW_ITEMS_M_C.g_row_count:=EDW_ITEMS_M_C.g_row_count+l_rows_inserted;

  ELSIF (p_item_item_org=0) THEN

    edw_log.put_line(' ');
    edw_log.put_line('Pushing categories to lower levels '
        ||'(EDW_ITEM_ITEMREV, EDW_ITEM_ITEMORG, EDW_ITEM_ITEM)');
    l_rows_inserted := 0;

    -- Bug# 3296641
    -- separated the push down of VBH i.e. item catset 3
    FOR i2 IN 1..2 LOOP
      IF (i2 = 1) THEN
        l_item_catset_name := l_item_catset1_name;
      ELSIF (i2 = 2) THEN
        l_item_catset_name := l_item_catset2_name;
      END IF;

      IF (l_item_catset_name <> 'NA_EDW') THEN
        FOR l_itemrev_rec IN l_itemrev_csr(l_item_catset_name) LOOP
          IF (i2 = 1) THEN
            edw_log.put_line(' ');
            edw_log.put_line('Pushing CATSET1 to lower levels ');
            l_catset1_category_fk := TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK;
            l_level_name := '-PCAT';
            l_catset2_category_fk := 'NA_EDW';
            l_catset3_category_fk := 'NA_EDW';
          ELSIF (i2 = 2) THEN
            edw_log.put_line(' ');
            edw_log.put_line('Pushing CATSET2 to lower levels ');
            l_catset1_category_fk := 'NA_EDW';
            l_catset2_category_fk := TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK;
            l_catset3_category_fk := 'NA_EDW';
            l_level_name := '-C2CT';
          END IF;

          INSERT INTO EDW_ITEM_ITEM_LSTG(
            ITEM_NUMBER_PK,
            INSTANCE,
            NAME,
            COLLECTION_STATUS,
            CATSET1_CATEGORY_FK,
            CATSET2_CATEGORY_FK,
            CATSET3_CATEGORY_FK,
            PRODUCT_GROUP_FK,
            CATEGORY_ID,
            CATEGORY_SET_ID,
            LAST_UPDATE_DATE)
          VALUES (
            TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK || l_level_name,
            l_itemrev_rec.INSTANCE,
            SUBSTRB(l_all_items||'('||l_itemrev_rec.NAME||')', 1, 320),
            'READY',
            l_catset1_category_fk,
            l_catset2_category_fk,
            l_catset3_category_fk,
            'NA_EDW',
            l_itemrev_rec.CATEGORY_ID,
            l_itemrev_rec.CATEGORY_SET_ID,
            l_itemrev_rec.last_update_date
            );

          INSERT INTO EDW_ITEM_ITEMORG_LSTG(
            ITEM_ORG_PK,
            ITEM_NUMBER_FK,
            INSTANCE,
            NAME,
            COLLECTION_STATUS,
            CATSET_CATEGORY_FK,
            PROD_FAMILY_FK,
            CATEGORY_ID,
            CATEGORY_SET_ID,
            LAST_UPDATE_DATE)
          VALUES (
            TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK || l_level_name,
            TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK || l_level_name,
            l_itemrev_rec.INSTANCE,
            SUBSTRB(l_all_item_orgs||'('||l_itemrev_rec.NAME||')', 1, 320),
            'READY',
            'NA_EDW',
            'NA_EDW',
            l_itemrev_rec.CATEGORY_ID,
            l_itemrev_rec.CATEGORY_SET_ID,
            l_itemrev_rec.last_update_date
            );

          INSERT INTO EDW_ITEM_ITEMREV_LSTG(
            ITEM_REVISION_PK,
            ITEM_ORG_FK,
            NAME,
            CATEGORY_ID,
            CATEGORY_SET_ID,
            INSTANCE,
            COLLECTION_STATUS,
            LAST_UPDATE_DATE)
          VALUES (
            SUBSTRB(TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK || l_level_name, 1, 320),
            SUBSTRB(TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK || l_level_name, 1, 320),
            SUBSTRB(l_all_item_revs||'('||l_itemrev_rec.NAME||')', 1, 320),
            l_itemrev_rec.CATEGORY_ID,
            l_itemrev_rec.CATEGORY_SET_ID,
            l_itemrev_rec.INSTANCE,
            'READY',
            l_itemrev_rec.last_update_date);

          l_rows_inserted := l_rows_inserted + 1;

        END LOOP;
      END IF;
    END LOOP;

    -- Bug# 3296641
    l_item_catset_name := l_item_catset3_name;

    IF (l_item_catset_name <> 'NA_EDW') THEN
      FOR l_itemrev_rec IN l_itemrev_vbh_csr(l_item_catset_name) LOOP
        edw_log.put_line(' ');
        edw_log.put_line('Pushing CATSET3 to lower levels ');
        l_catset1_category_fk := 'NA_EDW';
        l_catset2_category_fk := 'NA_EDW';
        l_catset3_category_fk := TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK;
        l_level_name := '-C3CT';

        INSERT INTO EDW_ITEM_ITEM_LSTG(
          ITEM_NUMBER_PK,
          INSTANCE,
          NAME,
          COLLECTION_STATUS,
          CATSET1_CATEGORY_FK,
          CATSET2_CATEGORY_FK,
          CATSET3_CATEGORY_FK,
          PRODUCT_GROUP_FK,
          CATEGORY_ID,
          CATEGORY_SET_ID,
          LAST_UPDATE_DATE)
        VALUES (
          TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK || l_level_name,
          l_itemrev_rec.INSTANCE,
          SUBSTRB(l_all_items||'('||l_itemrev_rec.NAME||')', 1, 320),
          'READY',
          l_catset1_category_fk,
          l_catset2_category_fk,
          l_catset3_category_fk,
          'NA_EDW',
          l_itemrev_rec.CATEGORY_ID,
          l_itemrev_rec.CATEGORY_SET_ID,
          l_itemrev_rec.last_update_date
          );

        INSERT INTO EDW_ITEM_ITEMORG_LSTG(
          ITEM_ORG_PK,
          ITEM_NUMBER_FK,
          INSTANCE,
          NAME,
          COLLECTION_STATUS,
          CATSET_CATEGORY_FK,
          PROD_FAMILY_FK,
          CATEGORY_ID,
          CATEGORY_SET_ID,
          LAST_UPDATE_DATE)
        VALUES (
          TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK || l_level_name,
          TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK || l_level_name,
          l_itemrev_rec.INSTANCE,
          SUBSTRB(l_all_item_orgs||'('||l_itemrev_rec.NAME||')', 1, 320),
          'READY',
          'NA_EDW',
          'NA_EDW',
          l_itemrev_rec.CATEGORY_ID,
          l_itemrev_rec.CATEGORY_SET_ID,
          l_itemrev_rec.last_update_date
          );

        INSERT INTO EDW_ITEM_ITEMREV_LSTG(
          ITEM_REVISION_PK,
          ITEM_ORG_FK,
          NAME,
          CATEGORY_ID,
          CATEGORY_SET_ID,
          INSTANCE,
          COLLECTION_STATUS,
          LAST_UPDATE_DATE)
        VALUES (
          SUBSTRB(TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK || l_level_name, 1, 320),
          SUBSTRB(TO_CHAR(l_control_level)||'-'||l_itemrev_rec.CATEGORY_PK || l_level_name, 1, 320),
          SUBSTRB(l_all_item_revs||'('||l_itemrev_rec.NAME||')', 1, 320),
          l_itemrev_rec.CATEGORY_ID,
          l_itemrev_rec.CATEGORY_SET_ID,
          l_itemrev_rec.INSTANCE,
          'READY',
          l_itemrev_rec.last_update_date);

        l_rows_inserted := l_rows_inserted + 1;

      END LOOP; -- Bug# 3296641
    END IF;

    edw_log.put_line(' ');
    edw_log.put_line('Inserted '||TO_CHAR(NVL(l_rows_inserted,0))||
          ' rows into the lower level staging tables');
    edw_log.put_line(' ');
    EDW_ITEMS_M_C.g_row_count:=EDW_ITEMS_M_C.g_row_count+l_rows_inserted;

  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    edw_log.debug_line(SUBSTRB(l_stmt,1,2000));
    RAISE;

END Push_Category;

PROCEDURE Push_EDW_ITEM_ITEMORG_CAT(
               p_from_date          DATE,
               p_to_date            DATE) IS
BEGIN
  edw_log.put_line('Pushing ItemOrg Categories');
  Push_Category(p_from_date, p_to_date,1); -- item/org cats
  edw_log.put_line('Completed Pushing ItemOrg Categories');

END Push_EDW_ITEM_ITEMORG_CAT;

PROCEDURE Push_EDW_ITEM_ITEM_CAT(
               p_from_date          DATE,
               p_to_date            DATE) IS
BEGIN
  edw_log.put_line('Pushing Item Categories');
  Push_Category(p_from_date, p_to_date, 0); -- item cats
  edw_log.put_line('Completed Pushing Item Categories');

END Push_EDW_ITEM_ITEM_CAT;

PROCEDURE Push_EDW_ITEM_PROD_LINE(
               p_from_date          DATE,
               p_to_date            DATE) IS

  l_all_prod_cats     VARCHAR2(100);
  l_all_prod_grps     VARCHAR2(100);
  l_all_items         VARCHAR2(100);
  l_all_item_orgs     VARCHAR2(100);
  l_all_item_revs     VARCHAR2(100);

BEGIN

  l_all_prod_cats := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_PCAT');
  l_all_prod_grps := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_PGRP');
  l_all_items := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_ITEM');
  l_all_item_orgs := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_IORG');
  l_all_item_orgs := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_IREV');

  edw_log.put_line(' ');
  edw_log.put_line('Pushing EDW_ITEM_ITEM_PROD_LINE');

  INSERT INTO EDW_ITEM_PROD_LINE_LSTG(
    ALL_FK_KEY,
    INTEREST_TYPE_ID,
    REQUEST_ID,
    ALL_FK,
    COLLECTION_STATUS,
    DESCRIPTION,
    ENABLED_FLAG,
    ERROR_CODE,
    INSTANCE_CODE,
    NAME,
    OPERATION_CODE,
    PRODUCT_LINE_DP,
    PRODUCT_LINE_PK,
    ROW_ID,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    CREATION_DATE,
    DELETION_DATE,
    LAST_UPDATE_DATE)
  SELECT
    NULL ALL_FK_KEY,
    INTEREST_TYPE_ID INTEREST_TYPE_ID,
    NULL REQUEST_ID,
    ALL_FK ALL_FK,
    'READY' COLLECTION_STATUS,
    DESCRIPTION DESCRIPTION,
    ENABLED_FLAG ENABLED_FLAG,
    NULL ERROR_CODE,
    l_instance INSTANCE_CODE, --    INSTANCE_CODE INSTANCE_CODE, /* Bug# 2558245 */
    NAME NAME,
    NULL OPERATION_CODE,
    PRODUCT_LINE_DP PRODUCT_LINE_DP,
    PRODUCT_LINE_PK || '-' || l_instance || '-INTR_TYPE' PRODUCT_LINE_PK,-- PRODUCT_LINE_PK PRODUCT_LINE_PK,/* Bug# 2558245 */
    NULL ROW_ID,
    USER_ATTRIBUTE1 USER_ATTRIBUTE1,
    USER_ATTRIBUTE2 USER_ATTRIBUTE2,
    USER_ATTRIBUTE3 USER_ATTRIBUTE3,
    USER_ATTRIBUTE4 USER_ATTRIBUTE4,
    USER_ATTRIBUTE5 USER_ATTRIBUTE5,
    CREATION_DATE CREATION_DATE,
    DELETION_DATE DELETION_DATE,
    LAST_UPDATE_DATE LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_LINE_LCV
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0)) ||' rows into the staging table');
  edw_log.put_line('');

  edw_log.put_line('Pushing Product Line to lower level EDW_ITEM_PROD_CATG');

  INSERT INTO EDW_ITEM_PROD_CATG_LSTG(
    PRODUCT_CATEG_PK,
    PRODUCT_LINE_FK,
    NAME,
    INSTANCE_CODE,
    COLLECTION_STATUS,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_LINE_PK || '-' || l_instance || '-INTR_TYPE' ||'-PLIN' PRODUCT_CATEG_PK, /* Bug# 2558245 */
    PRODUCT_LINE_PK || '-' || l_instance || '-INTR_TYPE' PRODUCT_LINE_FK, /* Bug# 2558245 */
    SUBSTRB(l_all_prod_cats||'('||NAME||')', 1, 320) NAME,
    l_instance, -- INSTANCE_CODE, /* Bug# 2558245 */
    'READY',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_LINE_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Pushing Product Line to lower level EDW_ITEM_PROD_GRP');

  INSERT INTO EDW_ITEM_PROD_GRP_LSTG(
    PRODUCT_GROUP_PK,
    PRODUCT_CATEG_FK,
    NAME,
    INSTANCE_CODE,
    COLLECTION_STATUS,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_LINE_PK || '-' || l_instance || '-INTR_TYPE' ||'-PLIN' PRODUCT_GROUP_PK, /* Bug# 2558245 */
    PRODUCT_LINE_PK || '-' || l_instance || '-INTR_TYPE' ||'-PLIN' PRODUCT_CATEG_FK, /* Bug# 2558245 */
    SUBSTRB(l_all_prod_grps||'('||NAME||')', 1, 320) NAME,
    l_instance, -- INSTANCE_CODE, /* Bug# 2558245 */
    'READY',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_LINE_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Pushing Product Line to lower level EDW_ITEM_ITEM');

  INSERT INTO EDW_ITEM_ITEM_LSTG(
    ITEM_NUMBER_PK,
    PRODUCT_GROUP_FK,
    NAME,
    INSTANCE,
    COLLECTION_STATUS,
    CATSET1_CATEGORY_FK,
    CATSET2_CATEGORY_FK,
    CATSET3_CATEGORY_FK,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_LINE_PK || '-' || l_instance || '-INTR_TYPE' ||'-PLIN' ITEM_NUMBER_PK, /* Bug# 2558245 */
    PRODUCT_LINE_PK || '-' || l_instance || '-INTR_TYPE' ||'-PLIN' PRODUCT_GROUP_FK, /* Bug# 2558245 */
    SUBSTRB(l_all_items||'('||NAME||')', 1, 320) NAME,
    l_instance, -- INSTANCE_CODE, /* Bug# 2558245 */
    'READY',
    'NA_EDW',
    'NA_EDW',
    'NA_EDW',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_LINE_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
       ' rows into the staging table');
  edw_log.put_line(' ');

  edw_log.put_line('Pushing Product Line to lower level EDW_ITEM_ITEMORG');

  INSERT INTO EDW_ITEM_ITEMORG_LSTG(
    ITEM_ORG_PK,
    ITEM_NUMBER_FK,
    NAME,
    INSTANCE,
    COLLECTION_STATUS,
    CATSET_CATEGORY_FK,
    PROD_FAMILY_FK,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_LINE_PK || '-' || l_instance || '-INTR_TYPE' ||'-PLIN' ITEM_ORG_PK, /* Bug# 2558245 */
    PRODUCT_LINE_PK || '-' || l_instance || '-INTR_TYPE' ||'-PLIN' ITEM_NUMBER_FK, /* Bug# 2558245 */
    SUBSTRB(l_all_item_orgs||'('||NAME||')', 1, 320) NAME,
    l_instance, -- INSTANCE_CODE, /* Bug# 2558245 */
    'READY',
    'NA_EDW',
    'NA_EDW',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_LINE_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT, 0)) ||
       'rows into the staging table');
  edw_log.put_line(' ');

  edw_log.put_line('Pushing Product Category to lower level EDW_ITEM_ITEMREV');

  INSERT INTO EDW_ITEM_ITEMREV_LSTG(
    ITEM_REVISION_PK,
    ITEM_ORG_FK,
    NAME,
    INSTANCE,
    COLLECTION_STATUS,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_LINE_PK || '-' || l_instance || '-INTR_TYPE' ||'-PLIN' ITEM_REVISION_PK, /* Bug# 2558245 */
    PRODUCT_LINE_PK || '-' || l_instance || '-INTR_TYPE' ||'-PLIN' ITEM_ORG_FK, /* Bug# 2558245 */
    SUBSTRB(l_all_item_revs||'('||NAME||')', 1, 320) NAME,
    l_instance, -- INSTANCE_CODE, /* Bug# 2558245 */
    'READY',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_LINE_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT, 0)) ||
        ' rows into the staging table');
  edw_log.put_line(' ');

END Push_EDW_ITEM_PROD_LINE;

PROCEDURE Push_EDW_ITEM_PROD_CATG(
               p_from_date          DATE,
               p_to_date            DATE) IS

  l_all_prod_grps   VARCHAR2(100);
  l_all_items       VARCHAR2(100);
  l_all_item_orgs   VARCHAR2(100);
  l_all_item_revs   VARCHAR2(100);

BEGIN

  l_all_prod_grps := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_PGRP');
  l_all_items := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_ITEM');
  l_all_item_orgs := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_IORG');
  l_all_item_revs := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_IREV');

  edw_log.put_line(' ');
  edw_log.put_line('Pushing EDW_ITEM_PROD_CATG');

  INSERT INTO EDW_ITEM_PROD_CATG_LSTG(
    PRIMARY_CODE_ID,
    PRODUCT_LINE_FK_KEY,
    REQUEST_ID,
    COLLECTION_STATUS,
    DESCRIPTION,
    ENABLED_FLAG,
    ERROR_CODE,
    INSTANCE_CODE,
    NAME,
    OPERATION_CODE,
    PRODUCT_CATEG_DP,
    PRODUCT_CATEG_PK,
    PRODUCT_LINE_FK,
    ROW_ID,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    CREATION_DATE,
    DELETION_DATE,
    LAST_UPDATE_DATE)
  SELECT
    primary_code_id PRIMARY_CODE_ID,
    NULL PRODUCT_LINE_FK_KEY,
    NULL REQUEST_ID,
    'READY' COLLECTION_STATUS,
    description DESCRIPTION,
    enabled_flag ENABLED_FLAG,
    NULL ERROR_CODE,
    l_instance INSTANCE_CODE, -- instance_code INSTANCE_CODE, /* Bug# 2558245 */
    name NAME,
    NULL OPERATION_CODE,
    product_categ_dp PRODUCT_CATEG_DP,
    product_categ_pk || '-' || l_instance || '-PRIM_CODE' PRODUCT_CATEG_PK, -- product_categ_pk PRODUCT_CATEG_PK, /* Bug# 2558245 */
    product_line_fk || '-' || l_instance || '-INTR_TYPE' PRODUCT_LINE_FK, -- product_line_fk PRODUCT_LINE_FK, /* Bug# 2558245 */
    NULL ROW_ID,
    user_attribute1 USER_ATTRIBUTE1,
    user_attribute2 USER_ATTRIBUTE2,
    user_attribute3 USER_ATTRIBUTE3,
    user_attribute4 USER_ATTRIBUTE4,
    user_attribute5 USER_ATTRIBUTE5,
    creation_date CREATION_DATE,
    deletion_date DELETION_DATE,
    last_update_date LAST_UPDATE_DATE
  FROM edw_item_prod_catg_lcv
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Pushing Product Category to lower level EDW_ITEM_PROD_GRP');

  INSERT INTO EDW_ITEM_PROD_GRP_LSTG(
    PRODUCT_GROUP_PK,
    PRODUCT_CATEG_FK,
    NAME,
    INSTANCE_CODE,
    COLLECTION_STATUS,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_CATEG_PK || '-' || l_instance || '-PRIM_CODE' ||'-PCTG' PRODUCT_GROUP_PK, /* Bug# 2558245 */
    PRODUCT_CATEG_PK || '-' || l_instance || '-PRIM_CODE'  PRODUCT_CATEG_FK, /* Bug# 2558245 */
    SUBSTRB(l_all_prod_grps||'('||NAME||')', 1, 320) NAME,
    l_instance, --   INSTANCE_CODE, /* Bug# 2558245 */
    'READY',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_CATG_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Pushing Product Category to lower level EDW_ITEM_ITEM');

  INSERT INTO EDW_ITEM_ITEM_LSTG(
    ITEM_NUMBER_PK,
    PRODUCT_GROUP_FK,
    NAME,
    INSTANCE,
    COLLECTION_STATUS,
    CATSET1_CATEGORY_FK,
    CATSET2_CATEGORY_FK,
    CATSET3_CATEGORY_FK,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_CATEG_PK || '-' || l_instance || '-PRIM_CODE' ||'-PCTG' ITEM_NUMBER_PK, /* Bug# 2558245 */
    PRODUCT_CATEG_PK || '-' || l_instance || '-PRIM_CODE' ||'-PCTG' PRODUCT_GROUP_FK, /* Bug# 2558245 */
    SUBSTRB(l_all_items||'('||NAME||')', 1, 320) NAME,
    l_instance, -- INSTANCE_CODE, /* Bug# 2558245 */
    'READY',
    'NA_EDW',
    'NA_EDW',
    'NA_EDW',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_CATG_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0))||
       ' rows into the staging table');
  edw_log.put_line(' ');

  edw_log.put_line('Pushing Product Category to lower level EDW_ITEM_ITEMORG');

  INSERT INTO EDW_ITEM_ITEMORG_LSTG(
    ITEM_ORG_PK,
    ITEM_NUMBER_FK,
    NAME,
    INSTANCE,
    COLLECTION_STATUS,
    CATSET_CATEGORY_FK,
    PROD_FAMILY_FK,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_CATEG_PK || '-' || l_instance || '-PRIM_CODE' ||'-PCTG' ITEM_ORG_PK, /* Bug# 2558245 */
    PRODUCT_CATEG_PK || '-' || l_instance || '-PRIM_CODE' ||'-PCTG' ITEM_NUMBER_FK, /* Bug# 2558245 */
    SUBSTRB(l_all_item_orgs||'('||NAME||')', 1, 320) NAME,
    l_instance, -- INSTANCE_CODE, /* Bug# 2558245 */
    'READY',
    'NA_EDW',
    'NA_EDW',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_CATG_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT, 0)) ||
       'rows into the staging table');
  edw_log.put_line(' ');

  edw_log.put_line('Pushing Product Category to lower level EDW_ITEM_ITEMREV');

  INSERT INTO EDW_ITEM_ITEMREV_LSTG(
    ITEM_REVISION_PK,
    ITEM_ORG_FK,
    INSTANCE,
    NAME,
    COLLECTION_STATUS,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_CATEG_PK || '-' || l_instance || '-PRIM_CODE' ||'-PCTG' ITEM_REVISION_PK, /* Bug# 2558245 */
    PRODUCT_CATEG_PK || '-' || l_instance || '-PRIM_CODE' ||'-PCTG' ITEM_ORG_FK, /* Bug# 2558245 */
    l_instance, -- INSTANCE_CODE, /* Bug# 2558245 */
    SUBSTRB(l_all_item_revs||'('||NAME||')', 1, 320) NAME,
    'READY',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_CATG_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT, 0)) ||
        ' rows into the staging table');
  edw_log.put_line(' ');

END Push_EDW_ITEM_PROD_CATG;

PROCEDURE Push_EDW_ITEM_PROD_GRP(
               p_from_date          DATE,
               p_to_date            DATE) IS

  l_all_items     VARCHAR2(100);
  l_all_item_orgs VARCHAR2(100);
  l_all_item_revs VARCHAR2(100);

BEGIN

  l_all_items := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_ITEM');
  l_all_item_orgs := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_IORG');
  l_all_item_revs := edw_collection_util.get_lookup_value('EDW_LEVEL_PUSH_DOWN', 'EDW_ITEMS_M_IREV');

  edw_log.put_line(' ');
  edw_log.put_line('Pushing EDW_ITEM_PROD_GRP');

  INSERT INTO EDW_ITEM_PROD_GRP_LSTG(
    PRODUCT_CATEG_FK_KEY,
    REQUEST_ID,
    SECONDARY_CODE_ID,
    COLLECTION_STATUS,
    DESCRIPTION,
    ENABLED_FLAG,
    ERROR_CODE,
    INSTANCE_CODE,
    NAME,
    OPERATION_CODE,
    PRODUCT_CATEG_FK,
    PRODUCT_GROUP_DP,
    PRODUCT_GROUP_PK,
    ROW_ID,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    CREATION_DATE,
    DELETION_DATE,
    LAST_UPDATE_DATE)
  SELECT
    NULL PRODUCT_CATEG_FK_KEY,
    NULL REQUEST_ID,
    SECONDARY_CODE_ID SECONDARY_CODE_ID,
    'READY' COLLECTION_STATUS,
    DESCRIPTION DESCRIPTION,
    ENABLED_FLAG ENABLED_FLAG,
    NULL ERROR_CODE,
    l_instance INSTANCE_CODE, -- INSTANCE_CODE INSTANCE_CODE, /* Bug# 2558245 */
    NAME NAME,
    NULL OPERATION_CODE,
    PRODUCT_CATEG_FK || '-' || l_instance || '-PRIM_CODE' PRODUCT_CATEG_FK, -- PRODUCT_CATEG_FK PRODUCT_CATEG_FK, /* Bug# 2558245 */
    PRODUCT_GROUP_DP PRODUCT_GROUP_DP,
    PRODUCT_GROUP_PK || '-' || l_instance || '-SECN_CODE' PRODUCT_GROUP_PK, -- PRODUCT_GROUP_PK PRODUCT_GROUP_PK, /* Bug# 2558245 */
    NULL ROW_ID,
    USER_ATTRIBUTE1 USER_ATTRIBUTE1,
    USER_ATTRIBUTE2 USER_ATTRIBUTE2,
    USER_ATTRIBUTE3 USER_ATTRIBUTE3,
    USER_ATTRIBUTE4 USER_ATTRIBUTE4,
    USER_ATTRIBUTE5 USER_ATTRIBUTE5,
    CREATION_DATE CREATION_DATE,
    DELETION_DATE DELETION_DATE,
    LAST_UPDATE_DATE LAST_UPDATE_DATE
  FROM edw_item_prod_grp_lcv
  WHERE last_update_date BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT, 0)) ||
         ' rows into the staging table');
  edw_log.put_line(' ');

  edw_log.put_line('Pushing Product Group to lower level EDW_ITEM_ITEMREV');

  INSERT INTO EDW_ITEM_ITEMREV_LSTG(
    ITEM_REVISION_PK,
    ITEM_ORG_FK,
    NAME,
    INSTANCE,
    COLLECTION_STATUS,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_GROUP_PK || '-' || l_instance || '-SECN_CODE'||'-PGRP' ITEM_REVISION_PK, /* Bug# 2558245 */
    PRODUCT_GROUP_PK || '-' || l_instance || '-SECN_CODE'||'-PGRP' ITEM_ORG_FK, /* Bug# 2558245 */
    SUBSTRB(l_all_item_revs||'('||NAME||')', 1, 320) NAME,
    l_instance, -- INSTANCE_CODE, /* Bug# 2558245 */
    'READY',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_GRP_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT, 0)) ||
        ' rows into the staging table');
  edw_log.put_line(' ');

  edw_log.put_line('Pushing Product Group to lower level EDW_ITEM_ITEMORG');

  INSERT INTO EDW_ITEM_ITEMORG_LSTG(
    ITEM_ORG_PK,
    ITEM_NUMBER_FK,
    NAME,
    INSTANCE,
    COLLECTION_STATUS,
    CATSET_CATEGORY_FK,
    PROD_FAMILY_FK,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_GROUP_PK || '-' || l_instance || '-SECN_CODE' ||'-PGRP' ITEM_ORG_PK, /* Bug# 2558245 */
    PRODUCT_GROUP_PK || '-' || l_instance || '-SECN_CODE' ||'-PGRP' ITEM_NUMBER_FK, /* Bug# 2558245 */
    SUBSTRB(l_all_item_orgs||'('||NAME||')', 1, 320) NAME,
    l_instance, -- INSTANCE_CODE, /* Bug# 2558245 */
    'READY',
    'NA_EDW',
    'NA_EDW',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_GRP_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT, 0)) ||
       'rows into the staging table');
  edw_log.put_line(' ');

  edw_log.put_line('Pushing Product Group to lower level EDW_ITEM_ITEM');

  INSERT INTO EDW_ITEM_ITEM_LSTG(
    ITEM_NUMBER_PK,
    PRODUCT_GROUP_FK,
    NAME,
    INSTANCE,
    COLLECTION_STATUS,
    CATSET1_CATEGORY_FK,
    CATSET2_CATEGORY_FK,
    CATSET3_CATEGORY_FK,
    LAST_UPDATE_DATE)
  SELECT
    PRODUCT_GROUP_PK || '-' || l_instance || '-SECN_CODE' ||'-PGRP' ITEM_NUMBER_PK, /* Bug# 2558245 */
    PRODUCT_GROUP_PK || '-' || l_instance || '-SECN_CODE' PRODUCT_GROUP_FK, /* Bug# 2558245 */
    SUBSTRB(l_all_items||'('||NAME||')', 1, 320) NAME,
    l_instance, -- INSTANCE_CODE, /* Bug# 2558245 */
    'READY',
    'NA_EDW',
    'NA_EDW',
    'NA_EDW',
    LAST_UPDATE_DATE
  FROM EDW_ITEM_PROD_GRP_LCV
  WHERE LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;

  edw_log.put_line('Inserted '||TO_CHAR(NVL(SQL%ROWCOUNT,0)) ||
        ' rows into the stagint table');
  edw_log.put_line(' ');

END Push_EDW_ITEM_PROD_GRP;

END EDW_ITEMS_M_C;

/
