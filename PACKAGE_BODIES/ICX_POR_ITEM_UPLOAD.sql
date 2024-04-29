--------------------------------------------------------
--  DDL for Package Body ICX_POR_ITEM_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_ITEM_UPLOAD" AS
/* $Header: ICXIULDB.pls 115.72 2004/08/03 00:58:30 kaholee ship $ */

-- Interface table row
type tRootDescriptors is table of Varchar2(700) index by binary_integer;
type tLocalDescriptors is table of Varchar2(700) index by binary_integer;

/* Debug Handling */
g_error_message varchar2(4000) := '';

/* Used for saving price errors */
type tITPriceRecord IS RECORD (
  line_number NUMBER,
  system_action VARCHAR2(20),
  supplier_name VARCHAR2(2000),
  supplier_part_num VARCHAR2(2000),
  supplier_part_auxid VARCHAR2(255),--Bug#2611529
  supplier_site_code VARCHAR2(255),--Bug#2709997
  unit_price VARCHAR2(60),
  currency VARCHAR2(30),
  unit_of_measure VARCHAR2(30),
  buyer_name VARCHAR2(255),
  price_list_name VARCHAR2(250),
  error_message VARCHAR2(4000),
  error_flag VARCHAR2(1)
);

/* Used for saving item errors */
type tITRowRecord is record (
  line_number			NUMBER ,
  row_type			VARCHAR2(20) ,
  processed_flag		VARCHAR2(1) ,
  language			VARCHAR2(4) ,
  action			VARCHAR2(20),
  system_action			VARCHAR2(20),
  error_flag			VARCHAR2(1),
  error_message			VARCHAR2(2000),
  required_descriptors		VARCHAR2(4000),
  required_tl_descriptors	VARCHAR2(4000),
  has_cat_attribute_flag	VARCHAR2(1),
  rt_category_id		NUMBER,
  category_name			VARCHAR2(250),
  org_id			NUMBER,
  supplier_id			NUMBER,
  supplier			VARCHAR2(700),
  supplier_part_num		VARCHAR2(700),
  supplier_part_auxid		VARCHAR2(255),
  manufacturer			VARCHAR2(700),
  manufacturer_part_num		VARCHAR2(700),
  description			VARCHAR2(2000),
  comments			VARCHAR2(700),
  alias				VARCHAR2(700),
  picture			VARCHAR2(700),
  picture_url			VARCHAR2(700),
  thumbnail_image		VARCHAR2(700),
  attachment_url		VARCHAR2(700),
  supplier_url			VARCHAR2(700),
  manufacturer_url 		VARCHAR2(700),
  long_description		VARCHAR2(2000),
  unspsc_code			VARCHAR2(700),
  availability			VARCHAR2(700),
  lead_time			NUMBER,
  item_type			VARCHAR2(700),
  contract_num			VARCHAR2(700),
  contract_id			NUMBER,
  roots				tRootDescriptors,
  locals			tLocalDescriptors,
  unit_price			NUMBER,
  currency			VARCHAR2(15),
  unit_of_measure		VARCHAR2(30),
  supplier_site_id		NUMBER,
  supplier_site_code		VARCHAR2(100),
  price_list_name		VARCHAR2(250),
  price_list_id			NUMBER,
  buyer_name			VARCHAR2(255),
  LAST_UPDATE_LOGIN		NUMBER,
  LAST_UPDATED_BY		NUMBER,
  LAST_UPDATE_DATE		DATE,
  CREATED_BY			NUMBER,
  CREATION_DATE			DATE
 );

/* Holds information about a category
- updateTLSQL is for updating/deleting translateable attributes of an existing items
- updateNonTLSQL is for updating/deleting Non-translateable attributes of an existing items
- translateSQL is for add an existing item in a new language
- for translate,  the updateNonTLSQL takes care of updating the non-translatable attributes
  and creating the correct number of rows in the languages the item already
  exists in
*/
TYPE CategoryInfo IS RECORD (
  category_name icx_cat_categories_tl.category_name%TYPE,
  descriptor_count PLS_INTEGER := 0,
  searchable_desc_count PLS_INTEGER := 0,
  updateTLSQL VARCHAR2(32767),
  updateNonTLSQL VARCHAR2(32767),
  translateSQL VARCHAR2(32767)
);

TYPE CategoryInfoTab IS TABLE OF CategoryInfo INDEX BY BINARY_INTEGER;
--Bug#2827814
TYPE ShortVarchar2Tab IS TABLE OF VARCHAR2(100) INDEX BY
  BINARY_INTEGER;
TYPE KeyTab IS TABLE OF VARCHAR2(250) INDEX BY
  BINARY_INTEGER;
gCategoryInfo CategoryInfoTab;

BATCH_SIZE PLS_INTEGER := 2500;
CACHE_SIZE PLS_INTEGER := 5000;

BLANK_DATE_STRING VARCHAR2(30) := '1799/12/31 00:00:00';
DEFAULT_DATE_FORMAT VARCHAR2(30) := 'YYYY/MM/DD HH24:MI:SS';

/* Global tables to store information needed for bulk binding
   Whenever a new global table is added, make sure it's also cleared in
   the clear_tables procedure */
gRowids dbms_sql.urowid_table;
gSystemActions dbms_sql.varchar2_table;
gRowTypes ShortVarchar2Tab;
gItemIds dbms_sql.number_table;
gCurrentItemIds dbms_sql.number_table;
gCategoryIds dbms_sql.number_table;
gCategoryNames dbms_sql.varchar2_table;
gOldCategoryIds dbms_sql.number_table;
gDistinctCategoryIds dbms_sql.number_table;
gOrgIds dbms_sql.number_table;
gPricelistIds dbms_sql.number_table;
gSupplierSiteIds dbms_sql.number_table;
gExtractorUpdatedFlags dbms_sql.varchar2_table;
gActiveFlags dbms_sql.varchar2_table;
-- added by bluk, to be used in move_prices_no_validation, process_batch_addupdate_prices
gSupplierIds dbms_sql.number_table;
gPriceTypes dbms_sql.varchar2_table;
gUoms dbms_sql.varchar2_table;

-- Category_Change
gChangedCatItemIds dbms_sql.number_table;
gChangedOldCatIds dbms_sql.number_table;
gChangedNewCatIds dbms_sql.number_table;
gChangedCatActions dbms_sql.varchar2_table;

-- BUYER NORMALIZATION
gDistinctItemIds dbms_sql.number_table;
gDistinctBuyerIds dbms_sql.number_table;

--Bug#3396442
--gRootDescKeys is only used in save_failed_item to insert into failed lines
--This is not needed.  save_failed_item has a new  cursor to get the non-seeded
--root descriptors
--gRootDescKeys KeyTab;

gErrorRowids dbms_sql.urowid_table;
gErrorCatId NUMBER;
gErrorCatDescKeys KeyTab;

gTranslateItemsSQL VARCHAR2(32767);
gUpdateItemsTLSQL VARCHAR2(32767);
gUpdateItemsNonTLSQL VARCHAR2(32767);
gAddRootCtxSQL ICX_POR_CTX_SQL_PKG.SQLTab;
gUpdateRootCtxSQL ICX_POR_CTX_SQL_PKG.SQLTab;

gBaseLanguage fnd_languages.language_code%TYPE;
gJobLanguage fnd_languages.language_code%TYPE;
--Bug#2611529 gSupplierId NUMBER;
gJobNumber NUMBER;
gUserId NUMBER;
gUserLogin NUMBER;
--Bug#2611529
gCatalogName  varchar2(255);

--Bug#3107596
gNegotiatedPrice varchar2(5);

-- Bug# 3366614 sosingha: global variable to make a conditional call to move_items with processed_flag 'D'
gDuplicatesExists BOOLEAN := false;

/* These are used for populating ICX_POR_CTX_TL
   We can't store these in gCategoryInfo since PL/SQL would not
   allow PL/SQL tables inside PL/SQL tables, so we can only store
   info about the most recently used category */
gCurrentCatId NUMBER;
gAddCatCtxSQL ICX_POR_CTX_SQL_PKG.SQLTab;
gUpdateCatCtxSQL ICX_POR_CTX_SQL_PKG.SQLTab;

/* Debug Handling */
procedure Debug(p_message in varchar2) is
begin
  g_error_message := substr(g_error_message || p_message, 4000);
end;

/* Clears the error table */
PROCEDURE clear_error_tables IS
BEGIN
  gErrorRowids.DELETE;
END;

/* Clears the pl/sql tables before processing another batch */
PROCEDURE clear_tables IS
BEGIN
  gRowids.DELETE;
  gRowTypes.DELETE;
  gSystemActions.DELETE;
  gItemIds.DELETE;
  gPriceTypes.DELETE;
  gCurrentItemIds.DELETE;
  gCategoryIds.DELETE;
  gCategoryNames.DELETE;
  gOldCategoryIds.DELETE;
  gDistinctCategoryIds.DELETE;
  -- Category_Change
  gChangedCatItemIds.DELETE;
  gChangedOldCatIds.DELETE;
  gChangedNewCatIds.DELETE;
  gChangedCatActions.DELETE;

  gOrgIds.DELETE;
  gPricelistIds.DELETE;
  gSupplierSiteIds.DELETE;
  gSupplierIds.DELETE;
  gExtractorUpdatedFlags.DELETE;
  gActiveFlags.DELETE;

  -- BUYER NORMALIZATION
  gDistinctItemIds.DELETE;
  gDistinctBuyerIds.DELETE;
END clear_tables;

/* Clears all the global variables before processing a job */
PROCEDURE clear_all IS
BEGIN
  gUpdateItemsNonTLSQL := null;
  gUpdateItemsTLSQL := null;
  gTranslateItemsSQL := null;
  gCategoryInfo.DELETE;
  gAddRootCtxSQL.DELETE;
  gUpdateRootCtxSQL.DELETE;
  gCurrentCatId := -1;
  gAddCatCtxSQL.DELETE;
  gUpdateCatCtxSQL.DELETE;
  --Bug#3396442
  --gRootDescKeys is only used in save_failed_item to insert into failed lines
  --This is not needed.  save_failed_item has a new  cursor to get the non-seeded
  --root descriptors
  --gRootDescKeys.DELETE;
  gErrorCatId := -1;
  gErrorCatDescKeys.DELETE;
  clear_tables;
  clear_error_tables;
END clear_all;

/**
 ** Proc : get_distinct
 ** Desc : Gets the distinct values from a pl/sql number table
 **/
PROCEDURE get_distinct(pNumbers IN dbms_sql.number_table,
  pDistinctNumbers OUT NOCOPY dbms_sql.number_table) IS
i NUMBER;
j NUMBER;
v_current_num NUMBER;
v_found BOOLEAN;
v_temp_num dbms_sql.number_table;
v_empty_tab dbms_sql.number_table;
xErrLoc PLS_INTEGER := 100;
BEGIN
  -- Initialize
  pDistinctNumbers := v_empty_tab;
  v_current_num := NULL;

  IF (pNumbers.COUNT = 0) THEN
    RETURN;
  ELSE

    xErrLoc := 200;
    IF (pNumbers(1) IS NOT NULL) THEN
      v_current_num := pNumbers(1);
      v_temp_num(v_current_num) := 1;
    END IF;
  END IF;
  xErrLoc := 300;

  FOR i IN pNumbers.FIRST..pNumbers.LAST LOOP

     -- No need to check if same as last entry or if null
     IF (pNumbers(i) IS NOT NULL AND
       (pNumbers(i) <> v_current_num OR v_current_num IS NULL)) THEN
       v_current_num := pNumbers(i);

       -- Value does not appear in the distinct array yet
       IF NOT v_temp_num.EXISTS(v_current_num) THEN
         v_temp_num(v_current_num) := 1;
       END IF;

     END IF;
    xErrLoc := 300+i;

  END LOOP;
  xErrLoc := 10000;

  IF (v_temp_num.COUNT = 0) THEN
    -- All entries in the incoming table are null
    RETURN;
  END IF;
  xErrLoc := 10010;

  v_current_num := v_temp_num.FIRST;
  pDistinctNumbers(1) := v_current_num;
  j := v_temp_num.FIRST;

  xErrLoc := 10020;
  FOR i IN 2..v_temp_num.COUNT LOOP
    j := v_temp_num.NEXT(j);
    pDistinctNumbers(i) := j;
  END LOOP;
  xErrLoc := 10030;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.get_distinct('
      || xErrLoc || '): ' || SQLERRM);
END get_distinct;

/* Constructs the SQL statements used to populate ICX_POR_CTX_TL
   for a given category */
PROCEDURE build_category_ctx_sql(p_category_id IN NUMBER) IS
  vSQLTab ICX_POR_CTX_SQL_PKG.SQLTab;
  xErrLoc PLS_INTEGER := 100;
BEGIN

  IF (p_category_id <> gCurrentCatId) THEN
    gCurrentCatId := p_category_id;

    -- For Add CTX SQL we want to use rowid where clause
    xErrLoc := 200;
    ICX_POR_CTX_SQL_PKG.build_ctx_sql(p_category_id,
      ICX_POR_CTX_SQL_PKG.ROWID_WHERE_CLAUSE, null,
      ICX_POR_CTX_SQL_PKG.DEFAULT_MAX_LENGTH,
      gAddCatCtxSQL, vSQLTab);

    -- For Update CTX SQL we need to use itemid where clause
    xErrLoc := 300;
    ICX_POR_CTX_SQL_PKG.build_ctx_sql(p_category_id,
      ICX_POR_CTX_SQL_PKG.ITEMID_WHERE_CLAUSE, null,
      ICX_POR_CTX_SQL_PKG.DEFAULT_MAX_LENGTH, vSQLTab, gUpdateCatCtxSQL);

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.build_category_ctx_sql('
      || xErrLoc || '): ' || SQLERRM);
END build_category_ctx_sql;

/* Constructs the SQL statements used to populate ICX_POR_C######_TL for
   a given category */
PROCEDURE build_category_sql(p_category_id IN NUMBER,
  p_category_info IN OUT NOCOPY CategoryInfo,
  p_table_name IN VARCHAR2) IS

  vUpdateItemsNonTLSQL1 VARCHAR2(32767) := null;
  vUpdateItemsNonTLSQL2 VARCHAR2(32767) := null;
  vUpdateItemsTLSQL1 VARCHAR2(32767) := null;
  vUpdateItemsTLSQL2 VARCHAR2(32767) := null;

  vTranslateItemsSQL1 VARCHAR2(32767) := null;
  vTranslateItemsSQL2 VARCHAR2(32767) := null;
  vCategoryInfo CategoryInfo;
  i pls_integer;
  CURSOR local_descriptors_cr(v_category_id NUMBER) IS
    select d.rt_descriptor_id,
           d.type,
           d.key,
           d.section_tag,
           d.stored_in_column,
           d.stored_in_table,
           d.searchable
    from   icx_cat_descriptors_tl d
    where  d.rt_category_id = v_category_id
    and    d.language = gJobLanguage
    order  by d.rt_descriptor_id;
  vColName   VARCHAR2(30);
  xErrLoc    PLS_INTEGER := 100;
  vDescCount PLS_INTEGER := 0;
  vAllDescCount PLS_INTEGER := 0;
  vTLDescCount PLS_INTEGER := 0;
  vTableName VARCHAR2(30);
  vDescInfo ICX_POR_CTX_SQL_PKG.DescriptorInfo;
  vDescInfoTab ICX_POR_CTX_SQL_PKG.DescriptorInfoTab;
  vSearchableDescCount PLS_INTEGER := 0;
  vSQLTab ICX_POR_CTX_SQL_PKG.SQLTab;
BEGIN

  vTableName := 'ICX_CAT_EXT_ITEMS_TLP';

  -- Category_Change
  vUpdateItemsNonTLSQL1 := 'update ' || vTableName ||
    ' set (last_update_login, last_updated_by, last_update_date ';
  vUpdateItemsTLSQL1 := 'update ' || vTableName ||
    ' set (request_id, last_update_login, last_updated_by, last_update_date ';

  vTranslateItemsSQL1 := 'insert into ' || vTableName ||
    ' (rt_item_id, language, org_id,  '||
    ' rt_category_id, primary_flag, '||
    ' created_by, creation_date, ' ||
    ' last_updated_by, last_update_date, last_update_login ';

  FOR local_desc IN local_descriptors_cr(p_category_id) LOOP
    vDescInfo := null;
    vAllDescCount := vAllDescCount + 1;

    vColName := local_desc.stored_in_column;

    xErrLoc := 200;

    IF (local_desc.searchable = 1) THEN
      p_category_info.searchable_desc_count :=
        p_category_info.searchable_desc_count + 1;
    END IF;

    -- The decode...#DEL part is used to set the attribute value to null
    -- if the user specifies #DEL in their file
    IF (local_desc.type = 2) THEN
      -- This is a translated text attribute.  The decode on the language
      -- makes sure the attribute value is updated only in the job language
      vTLDescCount := vTLDescCount + 1;
      vUpdateItemsTLSQL1 := vUpdateItemsTLSQL1 || ', ' || vColName;
      vUpdateItemsTLSQL2 := vUpdateItemsTLSQL2 ||
        ', decode(i.language, :p_language, decode(it.' ||
        vColName || ',''#DEL'',null,null,i.' ||
        vColName || ',it.' || vColName ||
        '),i.' || vColName || ') ';
      vTranslateItemsSQL1 := vTranslateItemsSQL1 || ', ' || vColName;
      vTranslateItemsSQL2 := vTranslateItemsSQL2 || ', decode(it.' ||
        vColName || ', ''#DEL'', null, null, i.' || vColName ||
        ', it.' || vColName || ') ';
    ELSIF (local_desc.type IN (1,5)) THEN
      vDescCount := vDescCount + 1;
      vUpdateItemsNonTLSQL1 := vUpdateItemsNonTLSQL1 || ', ' || vColName;
      vUpdateItemsNonTLSQL2 := vUpdateItemsNonTLSQL2 || ', decode(it.' ||
        vColName || ',''#DEL'',to_number(null),null,i.' ||
        vColName || ',to_number(it.' || vColName || ')) ';
      vTranslateItemsSQL1 := vTranslateItemsSQL1 || ', ' || vColName;
      vTranslateItemsSQL2 := vTranslateItemsSQL2 || ', decode(it.' ||
        vColName || ',''#DEL'',to_number(null),null,i.' ||
        vColName || ',to_number(it.' || vColName || ')) ';
    ELSIF (local_desc.type in (0,4)) THEN
      vDescCount := vDescCount + 1;
      vUpdateItemsNonTLSQL1 := vUpdateItemsNonTLSQL1 || ', ' || vColName;
      vUpdateItemsNonTLSQL2 := vUpdateItemsNonTLSQL2 || ', decode(it.' ||
      vColName || ', ''#DEL'', null, null, i.' || vColName ||
        ', it.' || vColName || ') ';
      vTranslateItemsSQL1 := vTranslateItemsSQL1 || ', ' || vColName;
      vTranslateItemsSQL2 := vTranslateItemsSQL2 || ', decode(it.' ||
      vColName || ', ''#DEL'', null, null, i.' || vColName ||
        ', it.' || vColName || ') ';
    END IF;

  END LOOP;

  IF (vAllDescCount > 0) THEN
    xErrLoc := 300;

    p_category_info.descriptor_count := vAllDescCount;
    xErrLoc := 301;
    -- Assumption is that all the non tl descriptors will
    -- hold the same value for an item across language, so pick
    -- the first matching row(rownum=1);
    p_category_info.updateNonTLSQL := vUpdateItemsNonTLSQL1 ||
      ') = (SELECT :p_user_login, :p_user_id, sysdate' ||
      vUpdateItemsNonTLSQL2 ||
      ' FROM ' || p_table_name || ' it, icx_cat_ext_items_tlp i ' ||
      ' WHERE i.rt_item_id = :old_item_id' ||
      ' AND it.rowid = :p_rowid AND ' || to_char(p_category_id) ||
      ' = :p_category_id AND :update_action = :p_action and rownum=1)' ||
      ' WHERE rt_item_id = :old_item_id' ||
      ' AND   rt_category_id = '|| to_char(p_category_id); --Category_Change
    xErrLoc := 302;
    -- Category_Change
    p_category_info.updateTLSQL := vUpdateItemsTLSQL1 ||
      ') = (SELECT :p_request_id, :p_user_login, :p_user_id, sysdate' ||
      vUpdateItemsTLSQL2 ||
      ' FROM ' || p_table_name || ' it, icx_cat_ext_items_tlp i ' ||
      ' WHERE i.rt_item_id = :old_item_id' ||
      ' AND it.rowid = :p_rowid AND ' || to_char(p_category_id) ||
      ' = :p_category_id AND :update_action = :p_action' ||
      ' AND it.language = i.language)' ||
      ' WHERE rt_item_id = :old_item_id' ||
      ' AND   rt_category_id = '|| to_char(p_category_id) || --Category_Change
      ' AND language = :p_language';
    xErrLoc := 303;
  ELSE
    xErrLoc := 306;
    p_category_info.descriptor_count := 0;
    p_category_info.updateTLSQL := null;
    p_category_info.updateNonTLSQL := null;
    --Bug#3657792
    --Insert into icx_cat_ext_items_tlp should be done even if there are no local descriptors
    --vTranslateItemsSQL1 and vTranslateItemsSQL2 will be null, if there are no local descriptors,
    --so, insert into icx_cat_ext_items_tlp will only insert the required columns
    --like rt_item_id, language etc
    --p_category_info.translateSQL := null;
  END IF;

    --Bug#3657792
    --Insert into icx_cat_ext_items_tlp should be done even if there are no local descriptors
    --vTranslateItemsSQL1 and vTranslateItemsSQL2 will be null, if there are no local descriptors,
    --so, insert into icx_cat_ext_items_tlp will only insert the required columns
    --like rt_item_id, language etc
    xErrLoc := 305;
    p_category_info.translateSQL := vTranslateItemsSQL1 || ') SELECT ' ||
    'i.rt_item_id, it.language, it.org_id,'||
    'it.rt_category_id, ''Y'',' ||
    ':p_user_id, sysdate, ' ||
    ':p_user_id, sysdate, :p_user_login ' ||
    vTranslateItemsSQL2 || ' FROM icx_cat_ext_items_tlp i, ' || p_table_name ||
    ' it WHERE i.rt_item_id = :old_item_id AND it.rowid = :p_rowid AND ' ||
    to_char(p_category_id) || ' = :p_category_id AND '||
    ' :update_action = :p_action  and it.language<>i.language ' ||
    ' AND rownum = 1  ';

    xErrLoc := 304;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.build_category_sql('
      || xErrLoc || '): ' || SQLERRM);
END build_category_sql;

/* Loads information about the categories in the current batch */
PROCEDURE load_distinct_categories IS
  v_distinct_catids dbms_sql.number_table;
  v_category_info CategoryInfo;
  i PLS_INTEGER;
  CURSOR get_category_name(p_category_id NUMBER) IS
    SELECT category_name FROM icx_cat_categories_tl
    WHERE rt_category_id = p_category_id
    AND language = gJobLanguage;
  v_current_catid NUMBER;
  xErrLoc PLS_INTEGER := 100;
BEGIN
  IF (gCategoryInfo.COUNT >= CACHE_SIZE) THEN
    -- Flush the cache
    gCategoryInfo.DELETE;
  END IF;

  get_distinct(gCategoryIds, gDistinctCategoryIds);

  xErrLoc := 200;

  FOR i IN 1..gDistinctCategoryIds.COUNT LOOP
    v_current_catid := gDistinctCategoryIds(i);

    IF (NOT gCategoryInfo.EXISTS(v_current_catid)) THEN
      xErrLoc := 300;

      OPEN get_category_name(v_current_catid);
      FETCH get_category_name INTO v_category_info.category_name;

      IF (NOT get_category_name%NOTFOUND) THEN
        xErrLoc := 400;

        build_category_sql(v_current_catid, v_category_info,
          'ICX_CAT_ITEMS_GT');
        gCategoryInfo(v_current_catid) := v_category_info;
      END IF;

      CLOSE get_category_name;
    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.load_distinct_categories('
      || xErrLoc || '): ' || SQLERRM);
END load_distinct_categories;

/* Constructs the SQL used to populate ICX_POR_ITEMS and ICX_POR_ITEMS_TL */
PROCEDURE build_root_sql(pTableName IN VARCHAR2) IS
  vUpdateItemsTLSQL1 VARCHAR2(32767) := null;
  vUpdateItemsTLSQL2 VARCHAR2(32767) := null;
  vUpdateItemsNonTLSQL1 VARCHAR2(32767) := null;
  vUpdateItemsNonTLSQL2 VARCHAR2(32767) := null;
  vTranslateItemsSQL1 VARCHAR2(32767) := null;
  vTranslateItemsSQL2 VARCHAR2(32767) := null;
  vDescInfo ICX_POR_CTX_SQL_PKG.DescriptorInfo;
  vDescInfoTab ICX_POR_CTX_SQL_PKG.DescriptorInfoTab;
  vSQLTab ICX_POR_CTX_SQL_PKG.SQLTab;
  i pls_integer;
  CURSOR non_price_root_descriptors_cr(p_category_id NUMBER) IS
    select rt_descriptor_id,
           type,
           key,
           section_tag,
           stored_in_column,
           stored_in_table,
           searchable
    from   icx_cat_descriptors_tl
    where  rt_category_id = p_category_id
    and    language = gJobLanguage
    and    stored_in_table = 'ICX_CAT_ITEMS_TLP'
    order  by rt_descriptor_id;
  vColName   VARCHAR2(30);
  xErrLoc    PLS_INTEGER := 100;
  vRootDescCount PLS_INTEGER := 0;
  vRootAllDescCount PLS_INTEGER := 0;
  vRootTLDescCount PLS_INTEGER := 0;
  vSearchableDescCount PLS_INTEGER := 0;
BEGIN

  -- No need to put any value in the ctx_<lang> column, so it's not
  -- included
  vUpdateItemsTLSQL1 := 'update icx_cat_items_tlp set ( ' ||
    'request_id, last_updated_by, last_update_date, last_update_login, primary_category_name ';
  --Bug#2729038
  vUpdateItemsNonTLSQL1 := 'update icx_cat_items_tlp set ( ctx_desc, ' ||
    'primary_category_id, last_updated_by, last_update_date, last_update_login ';
  vTranslateItemsSQL1 := 'insert into icx_cat_items_tlp ( ctx_desc, ' ||
    ' rt_item_id, language, org_id, supplier_id, '||
    ' item_source_type, search_type, primary_category_id, primary_category_name, '||
    ' created_by, creation_date, ' ||
    ' last_updated_by, last_update_date, last_update_login ';

  xErrLoc := 200;

  FOR root_desc IN non_price_root_descriptors_cr(0) LOOP
    vDescInfo := null;
    vRootAllDescCount := vRootAllDescCount + 1;
    vColName := root_desc.stored_in_column;

    --Bug#3396442
    --gRootDescKeys is only used in save_failed_item to insert into failed lines
    --This is not needed.  save_failed_item has a new  cursor to get the non-seeded
    --root descriptors
    --gRootDescKeys(vRootAllDescCount) := root_desc.key;

    IF (root_desc.searchable = 1 OR root_desc.key = 'SELLABLE_ITEM') THEN
      vDescInfo.descriptor_id := root_desc.rt_descriptor_id;
      vDescInfo.descriptor_key := root_desc.key;
      vDescInfo.descriptor_index := vRootAllDescCount;
      vDescInfo.descriptor_type := root_desc.type;
      vDescInfo.section_tag := root_desc.section_tag;
      -- OEX_IP_PORTING
      vDescInfo.stored_in_column := root_desc.stored_in_column;
      vDescInfo.stored_in_table := root_desc.stored_in_table;

      IF (root_desc.type IN (0,2)) THEN

        IF (root_desc.key = 'DESCRIPTION') THEN
        vDescInfo.descriptor_length := 2000;
        ELSIF (root_desc.key = 'SELLABLE_ITEM') THEN
        vDescInfo.descriptor_length := 20;
        ELSE
        vDescInfo.descriptor_length := 700;
        END IF;

      ELSE
        vDescInfo.descriptor_length := 100;
      END IF;

      vSearchableDescCount := vSearchableDescCount + 1;
      vDescInfoTab(vSearchableDescCount) := vDescInfo;
    END IF;

    -- For all root descriptors that are updateable and
    -- are stored in icx_cat_items_tlp, formulate the update sql...
    -- Some of the descriptors are not updateable. check can_update() function
    IF (can_update(root_desc.key) AND (root_desc.stored_in_table = 'ICX_CAT_ITEMS_TLP')) then

      IF (root_desc.type = 2) THEN
        vRootTLDescCount := vRootTLDescCount + 1;
        vUpdateItemsTLSQL1 := vUpdateItemsTLSQL1 || ', ' || vColName;
        vUpdateItemsTLSQL2 := vUpdateItemsTLSQL2 ||
        ', decode(i.language, :p_language, decode(it.'||vColName ||
        ',''#DEL'',null,null,i.' || vColName ||
        ',it.' || vColName || '),i.' || vColName || ')';

        vTranslateItemsSQL1 := vTranslateItemsSQL1 || ', ' || vColName;
        vTranslateItemsSQL2 := vTranslateItemsSQL2 ||
        ', decode(it.'||vColName ||
        ',''#DEL'',null, it.' || vColName ||  ')';
      ELSE
        vUpdateItemsNonTLSQL1 := vUpdateItemsNonTLSQL1 || ', ' || vColName;
        vUpdateItemsNonTLSQL2 := vUpdateItemsNonTLSQL2 ||
        ', decode(it.'||vColName ||
        ',''#DEL'',null,null,i.' || vColName ||
        ',it.' || vColName || ')';

        vTranslateItemsSQL1 := vTranslateItemsSQL1 || ', ' || vColName;
        vTranslateItemsSQL2 := vTranslateItemsSQL2 ||
        ', decode(it.'||vColName ||
        ',''#DEL'',null,null,i.' || vColName ||
        ',it.' || vColName || ')';
      END IF; -- if (root_desc.type = 2)

    END IF; -- if(root_desc.stored_in_table = 'ICX_CAT_ITEMS_TLP')

  END LOOP; -- FOR root_desc IN ....

  xErrLoc := 300;

  -- Update only non-translated descriptors
  -- Assumption is that all the non tl descriptors will hold the same value for
  -- an item across language, so pick the first matching row(rownum=1);
  -- update the ctx_desc to '1'
  --Bug#2729038
  gUpdateItemsNonTLSQL := vUpdateItemsNonTLSQL1 || ') = (SELECT ' ||
    '''1'''||
    ', it.rt_category_id, :p_user_id, sysdate, :p_user_login ' ||
    vUpdateItemsNonTLSQL2 || ' FROM icx_cat_items_tlp i, ' || pTableName ||
    ' it WHERE i.rt_item_id = :old_item_id AND it.rowid = :p_rowid AND' ||
    ' :update_action = :p_action and rownum=1) WHERE rt_item_id = :old_item_id';

  -- Update only translated descriptors
  gUpdateItemsTLSQL := vUpdateItemsTLSQL1 || ') = (SELECT ' ||
    ':p_request_id, :p_user_id, sysdate, :p_user_login, it.category_name ' ||
    vUpdateItemsTLSQL2 || ' FROM icx_cat_items_tlp i, ' || pTableName ||
    ' it WHERE i.rt_item_id = :old_item_id AND it.rowid = :p_rowid AND' ||
    ' :update_action = :p_action  and it.language=i.language)' ||
    ' WHERE language = :p_language' ||
    ' AND rt_item_id = :old_item_id';

  -- Update only translated descriptors
  gTranslateItemsSQL := vTranslateItemsSQL1 || ') SELECT ' ||
    '''1'''||
    ', i.rt_item_id, it.language, it.org_id, it.supplier_id,'||
    '''SUPPLIER'', ''SUPPLIER'', '||
    'it.rt_category_id, it.category_name,' ||
    'i.created_by, i.creation_date, ' ||
    ':p_user_id, sysdate, :p_user_login ' ||
    vTranslateItemsSQL2 || ' FROM icx_cat_items_tlp i, ' || pTableName ||
    ' it WHERE i.rt_item_id = :old_item_id AND it.rowid = :p_rowid AND' ||
    ' :update_action = :p_action  and it.language<>i.language ' ||
    ' AND rownum = 1 ' ;

  -- For Add CTX SQL we want to use rowid where clause
  xErrLoc := 400;
  ICX_POR_CTX_SQL_PKG.build_ctx_sql(0, vDescInfoTab,
    ICX_POR_CTX_SQL_PKG.ROWID_WHERE_CLAUSE, null,
    ICX_POR_CTX_SQL_PKG.DEFAULT_MAX_LENGTH, gAddRootCtxSQL,
    vSQLTab);

  -- For Update CTX SQL we need to use itemid where clause
  xErrLoc := 500;
  ICX_POR_CTX_SQL_PKG.build_ctx_sql(0, vDescInfoTab,
    ICX_POR_CTX_SQL_PKG.ITEMID_WHERE_CLAUSE, null,
    ICX_POR_CTX_SQL_PKG.DEFAULT_MAX_LENGTH, vSQLTab,
    gUpdateRootCtxSQL);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.build_root_sql('
      || xErrLoc || '): ' || SQLERRM);
END build_root_sql;

/* Processes the new prices in the current batch */
PROCEDURE process_batch_add_prices(p_batch_type IN VARCHAR2) IS
  i PLS_INTEGER;
  v_action VARCHAR2(10) := 'ADD';
  xErrLoc PLS_INTEGER := 100;
  v_sequence PLS_INTEGER := 10001;
  v_buyer_ids dbms_sql.number_table;
  v_item_ids dbms_sql.number_table;
  v_count PLS_INTEGER := 0;
BEGIN
  -- This is used only for ITEM_PRICES.  New prices or updates in the PRICE
  -- section is handled by process_batch_addupdate_prices

  IF (p_batch_type = 'PRICE') THEN
    RETURN;
  ELSE

    xErrLoc := 150;
    FORALL i IN 1..gRowids.COUNT
      INSERT into icx_cat_item_prices(rt_item_id, price_type, supplier_site_id, org_id,
        active_flag, search_type, unit_price, currency, unit_of_measure,
        supplier_site_code, price_list_id, request_id, created_by, creation_date,
        last_updated_by, last_update_login, last_update_date, object_version_number, contract_num, contract_id,
        negotiated_by_preparer_flag) --Bug#3107596
      SELECT gItemIds(i), gPriceTypes(i), it.supplier_site_id, it.org_id,
        'Y', 'SUPPLIER',
        it.unit_price, it.currency, it.unit_of_measure,
        it.supplier_site_code, it.price_list_id, gJobNumber, gUserId, sysdate, gUserId,
        gUserLogin, sysdate , 1,
        it.contract_num, it.contract_id, -- OEX_IP_PORTING
        gNegotiatedPrice --Bug#3107596
      FROM ICX_CAT_ITEMS_GT it
      WHERE rowid = gRowIds(i)
      AND gRowTypes(i) = p_batch_type
      AND gSystemActions(i) = v_action;

    -- BUYER NORMALIZATION
    -- This is a new item, so no need to check existing entries
    xErrLoc := 300;
    -- We want to only process the rows that are applicable
    FOR i IN 1..gRowids.COUNT LOOP

      IF (gRowTypes(i) = p_batch_type AND gSystemActions(i) = v_action AND
        gOrgIds(i) IS NOT NULL) THEN
        v_count := v_count + 1;
        v_item_ids(v_count) := gItemIds(i);
        v_buyer_ids(v_count) := gOrgIds(i);
      END IF;

    END LOOP;

    xErrLoc := 400;

    FORALL i IN 1..v_count
      INSERT INTO icx_cat_items_ctx_tlp
        (rt_item_id, language, sequence, ctx_desc, org_id)
      VALUES
        (v_item_ids(i), gJobLanguage, v_sequence,
         to_char(v_buyer_ids(i)), v_buyer_ids(i));

    xErrLoc := 500;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.process_batch_add_prices('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_add_prices;

/* Processes the price updates in the current batch */
-- icx_por_ext_item.getBulkLoadActiveFlag() returns,
-- 'A' if the bulkloaded price is active and there is an ASL
-- 'Y' if the bulkloaded price is active and there is No ASL
-- 'N' if the bulkloaded price is inactive
PROCEDURE process_batch_addupdate_prices(p_batch_type IN VARCHAR2,
                                      p_action IN VARCHAR2 DEFAULT 'UPDATE',
                                      p_num_failed_lines OUT NOCOPY NUMBER) IS
  i PLS_INTEGER;
  v_price_updated dbms_sql.number_table;
  xErrLoc PLS_INTEGER := 100;
  v_sequence PLS_INTEGER := 10001;
  numErrors NUMBER := 0;
BEGIN
  p_num_failed_lines := 0; -- initialize

  -- Get the number of errors already logged.
  -- We need to add the error rows from this procedure into gErrorRowids
  -- from the correct location without erasing the
  -- previous errors(like say duplicate error)
  numErrors := gErrorRowids.COUNT;

  -- When updating existing items with prices specified, there are
  -- two possibilities: updating existing price or adding new price
  -- This SQL takes care of both cases

  -- This SQL also works for both new and exsiting prices if we are
  -- processing the price section

  -- First move over the existing price if any to the price history table

  --Bug#2719434: price type of "BULKLOAD" and "CONTRACT" are of both bulkloader
  --             price type. Verified that there cannot be any extracted price
  --             of type CONTRACT
  FORALL i in 1..gRowIds.COUNT
    INSERT into icx_cat_price_history(rt_item_id, status, price_type, asl_id, supplier_site_id,
      contract_id, contract_line_id, template_id, template_line_id, mtl_category_id, org_id,
      active_flag, search_type, unit_price, currency, unit_of_measure, functional_price,
      supplier_site_code, contract_num, contract_line_num, price_list_id, archived_date,
      last_update_login, last_updated_by, last_update_date, created_by, creation_date,
      request_id, program_application_id, program_id, program_update_date, object_version_number)
    SELECT  rt_item_id, 'OUTDATED', price_type, asl_id, supplier_site_id,
      contract_id, contract_line_id, template_id, template_line_id, mtl_category_id, org_id,
      active_flag, search_type, unit_price, currency, unit_of_measure, functional_price,
      supplier_site_code, contract_num, contract_line_num, price_list_id, sysdate,
      last_update_login, last_updated_by, last_update_date, created_by, creation_date,
      request_id, program_application_id, program_id, program_update_date,object_version_number
    FROM icx_cat_item_prices
    WHERE rt_item_id = gItemIds(i)
    AND price_list_id = gPricelistIds(i)
    AND org_id = gOrgIds(i)
    AND supplier_site_id = gSupplierSiteIds(i)
    AND gRowTypes(i) = p_batch_type
    AND price_type in ('BULKLOAD', 'CONTRACT') --Bug#2719434
    AND gSystemActions(i) = p_action;

  xErrLoc := 200;

  -- Figure out which rows need to be update and which insert

  FOR i in 1..gRowIds.COUNT LOOP
    v_price_updated(i) := SQL%BULK_ROWCOUNT(i);

    if (gUoms(i) is null AND v_price_updated(i) = 0) then
      -- For add operation you need the UOM,
      -- For add, if UOM is not specified then reject the line
      reject_line(gRowids(i), 'PRICE', '.UOM:ICX_POR_CAT_FIELD_REQUIRED');

      p_num_failed_lines := p_num_failed_lines + 1;
      gErrorRowids(numErrors+p_num_failed_lines) := gRowids(i);

      -- Also set the v_price_updated(i) to -1 so that the insert operation
      -- for rejected prices does not happen
      v_price_updated(i) := -1;
    end if;

  END LOOP;

  xErrLoc := 300;

  IF (p_batch_type = 'PRICE') THEN
  -- insert the new prices
    FORALL i in 1..gRowIds.COUNT
      INSERT into icx_cat_item_prices(rt_item_id, price_type, supplier_site_id, org_id,
        active_flag, search_type, unit_price, currency, unit_of_measure,
        supplier_site_code, price_list_id, request_id, created_by, creation_date,
        last_updated_by, last_update_login, last_update_date, contract_num, contract_id, object_version_number,
        negotiated_by_preparer_flag) --Bug#3107596
      SELECT gItemIds(i), gPriceTypes(i), it.supplier_site_id, it.org_id,
        gActiveFlags(i),
        'SUPPLIER', it.unit_price, it.currency, it.unit_of_measure,
        it.supplier_site_code, it.price_list_id, gJobNumber, gUserId, sysdate, gUserId,
        gUserLogin, sysdate, it.contract_num, it.contract_id , 1,
        gNegotiatedPrice --Bug#3107596
      FROM ICX_CAT_PRICES_GT it
      WHERE rowid = gRowIds(i)
      AND gRowTypes(i) = p_batch_type
      AND gSystemActions(i) = p_action
      AND v_price_updated(i) = 0;

    xErrLoc := 400;

    -- update the existing prices
    FORALL i in 1..gRowIds.COUNT
      UPDATE icx_cat_item_prices ip
      SET (ip.unit_price, ip.currency,
        ip.unit_of_measure,
        ip.supplier_site_code, ip.request_id, ip.last_updated_by,
        ip.last_update_login, ip.last_update_date, ip.contract_num,
        ip.contract_id, ip.object_version_number,
        ip.price_type, --Bug#3503280
        negotiated_by_preparer_flag) --Bug#3107596
      = (SELECT it.unit_price, it.currency,
          nvl(it.unit_of_measure, ip.unit_of_measure),
          it.supplier_site_code, gJobNumber, gUserId, gUserLogin, sysdate,
          it.contract_num, it.contract_id, 1,
          gPriceTypes(i), --Bug#3503280
          gNegotiatedPrice --Bug#3107596
        FROM ICX_CAT_PRICES_GT it
        WHERE rowid = gRowIds(i)
        AND gRowTypes(i) = p_batch_type
        AND gSystemActions(i) = p_action
        AND v_price_updated(i) = 1)
      WHERE ip.rt_item_id = gItemIds(i)
      AND ip.price_list_id = gPricelistIds(i)
      AND ip.org_id = gOrgIds(i)
      AND ip.supplier_site_id = gSupplierSiteIds(i)
      AND gRowTypes(i) = p_batch_type
      AND v_price_updated(i) > 0
      AND ip.price_type in ( 'BULKLOAD', 'CONTRACT') --Bug#2719434
      AND gSystemActions(i) = p_action;
  ELSE

  -- insert the new prices
    FORALL i in 1..gRowIds.COUNT
      INSERT into icx_cat_item_prices(rt_item_id, price_type, supplier_site_id, org_id,
        active_flag, search_type, unit_price, currency, unit_of_measure,
        supplier_site_code, price_list_id, request_id, created_by, creation_date,
        last_updated_by, last_update_login, last_update_date, contract_num, contract_id, object_version_number,
        negotiated_by_preparer_flag) --Bug#3107596
      SELECT gItemIds(i), gPriceTypes(i), it.supplier_site_id, it.org_id, gActiveFlags(i), 'SUPPLIER',
        it.unit_price, it.currency, it.unit_of_measure,
        it.supplier_site_code, it.price_list_id, gJobNumber, gUserId, sysdate, gUserId,
        gUserLogin, sysdate, it.contract_num, it.contract_id , 1,
        gNegotiatedPrice --Bug#3107596
      FROM ICX_CAT_ITEMS_GT it
      WHERE rowid = gRowIds(i)
      AND gRowTypes(i) = p_batch_type
      AND gSystemActions(i) = p_action
      AND v_price_updated(i) = 0;

    xErrLoc := 400;

    -- update the existing prices
    FORALL i in 1..gRowIds.COUNT
      UPDATE icx_cat_item_prices ip
      SET (ip.unit_price, ip.currency, ip.unit_of_measure, ip.supplier_site_id,
        ip.supplier_site_code, ip.request_id, ip.last_updated_by, ip.last_update_login, ip.last_update_date, ip.contract_num, ip.contract_id, ip.object_version_number,
        ip.price_type, --Bug#3503280
        negotiated_by_preparer_flag) --Bug#3107596
      = (SELECT it.unit_price, it.currency, nvl(it.unit_of_measure, ip.unit_of_measure), it.supplier_site_id,
          it.supplier_site_code, gJobNumber, gUserId, gUserLogin, sysdate,
          it.contract_num, it.contract_id, 1,
          gPriceTypes(i), --Bug#3503280
          gNegotiatedPrice --Bug#3107596
        FROM ICX_CAT_ITEMS_GT it
        WHERE rowid = gRowIds(i)
        AND gRowTypes(i) = p_batch_type
        AND gSystemActions(i) = p_action
        AND v_price_updated(i) = 1)
      WHERE ip.rt_item_id = gItemIds(i)
      AND ip.price_list_id = gPricelistIds(i)
      AND ip.org_id = gOrgIds(i)
      AND ip.supplier_site_id = gSupplierSiteIds(i)
      AND gRowTypes(i) = p_batch_type
      AND v_price_updated(i) > 0
      AND ip.price_type in ( 'BULKLOAD', 'CONTRACT') --Bug#2719434
      AND gSystemActions(i) = p_action;
  END IF; -- end of if p_batch_type = PRICE

  -- OEX_IP_PORTING
  -- ASL rows for which new bulkloaded price has been added should be set
  -- to active_flag = 'N'
  FORALL i in 1..gRowIds.COUNT
    UPDATE icx_cat_item_prices
    SET active_flag = 'N'
    WHERE
    rt_item_id = gItemIds(i)
    AND gSystemActions(i) = p_action
    AND price_type = 'ASL'
    AND v_price_updated(i) = 0;

  -- BUYER NORMALIZATION
  -- No need to check gRowTpye and gSystemActions, this is only called
  -- with 'PRICE','ADD'
  -- If gSystemActions(i) is DELETE, then it will not be in gDistinctItemIds
  xErrLoc := 150;

  FORALL i IN 1..gDistinctItemIds.COUNT
    INSERT INTO icx_cat_items_ctx_tlp
      (rt_item_id, language, sequence, ctx_desc, org_id)
    SELECT gDistinctItemIds(i), tl.language, v_sequence,
      to_char(gDistinctBuyerIds(i)), gDistinctBuyerIds(i)
    FROM icx_cat_items_tlp tl
    WHERE tl.rt_item_id = gDistinctItemIds(i)
    AND NOT EXISTS
      (SELECT 1 FROM icx_cat_items_ctx_tlp
       WHERE rt_item_id = gDistinctItemIds(i)
       AND org_id = gDistinctBuyerIds(i));

  xErrLoc := 160;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
     'Exception at ICX_POR_ITEM_UPLOAD.process_batch_addupdate_prices('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_addupdate_prices;

PROCEDURE process_batch_addupdate_prices(p_batch_type IN VARCHAR2,
                                      p_action IN VARCHAR2 DEFAULT 'UPDATE') IS
  xErrLoc PLS_INTEGER := 100;
  -- process_batch_addupdate_prices is capable of returning
  -- number of failed lines (vNumFailedLines) while processing.
  -- But for item handling there will not be any failed lines
  -- in process_batch_addupdate_prices, so we are ignoring
  -- this value. May be useful in future..This parameter
  -- is useful only when calling from process_batch_prices
  vNumFailedLines NUMBER := 0;

BEGIN
  -- process_batch_prices needs vNumFailedLines, so it should call the
  -- 3 parameter implementation of this method
  process_batch_addupdate_prices(p_batch_type, p_action, vNumFailedLines);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
     'Exception at ICX_POR_ITEM_UPLOAD.process_batch_addupdate_prices('
      || xErrLoc || ') 2 arg: ' || SQLERRM);
END process_batch_addupdate_prices;

/* Processes the price deletes in the current batch */
-- icx_por_ext_item.getBulkLoadActiveFlag() returns,
-- 'A' if the bulkloaded price is active and there is an ASL
-- 'Y' if the bulkloaded price is active and there is No ASL
-- 'N' if the bulkloaded price is inactive
PROCEDURE process_batch_delete_prices(p_batch_type IN VARCHAR2) IS
  i PLS_INTEGER;
  v_action VARCHAR2(10) := 'DELETE';
  xErrLoc PLS_INTEGER := 100;
BEGIN

  -- First move over the existing price line to the price history table
  -- only for batch_type = PRICE
  -- for ITEM PRICE we clean everything up

  IF (p_batch_type  = 'PRICE') THEN
    FORALL i in 1..gRowIds.COUNT
      INSERT into icx_cat_price_history(rt_item_id, status, price_type, asl_id, supplier_site_id,
        contract_id, contract_line_id, template_id, template_line_id, mtl_category_id, org_id,
        active_flag, search_type, unit_price, currency, unit_of_measure,
        supplier_site_code, contract_num, contract_line_num, price_list_id, archived_date,
        last_update_login, last_updated_by, last_update_date, created_by, creation_date,
        request_id, program_application_id, program_id, program_update_date, object_version_number)
      SELECT  rt_item_id, 'DELETED', price_type, asl_id, supplier_site_id,
        contract_id, contract_line_id, template_id, template_line_id, mtl_category_id, org_id,
        active_flag, search_type, unit_price, currency, unit_of_measure,
        supplier_site_code, contract_num, contract_line_num, price_list_id, sysdate,
        last_update_login, last_updated_by, last_update_date, created_by, creation_date,
        request_id, program_application_id, program_id, program_update_date, object_version_number
      FROM icx_cat_item_prices
      WHERE rt_item_id = gItemIds(i)
      AND price_list_id = gPricelistIds(i)
      AND org_id = gOrgIds(i)
      AND supplier_site_id = gSupplierSiteIds(i)
      AND gRowTypes(i) = p_batch_type
      AND gSystemActions(i) = v_action;
  END IF;

  xErrLoc := 150;
  -- If it was a delete operation then the ASL active flag
  -- will be set to "Y", if it did not have contracts/templates..
  -- If the icx_por_ext_item.getBulkLoadActiveFlag returns 'A' or 'Y' then it means that
  -- there are no contract, templates and this bulkloaded item was the last
  -- active price. So after deletion of this price, active flag of ASL price
  -- will be set to 'Y'. If the icx_por_ext_item.getBulkLoadActiveFlag returned 'N', the
  -- there is a contract/template, So set the active_flag to 'N'
  -- (Active flag constraint used to pick the right index.)
  FORALL i in 1..gRowIds.COUNT
    update icx_cat_item_prices
    set    active_flag = gActiveFlags(i)
    where  rt_item_id = gItemIds(i)
    and    active_flag = 'N'
    and    org_id = gOrgIds(i)
    and    supplier_site_id = gSupplierSiteIds(i)
    and    price_type = 'ASL'
    and    gRowTypes(i) = p_batch_type
    and    gSystemActions(i) = v_action;

  xErrLoc := 200;

  -- Now delete the lines from the item_prices table
  FORALL i in 1..gRowIds.COUNT
    DELETE from icx_cat_item_prices
    WHERE rt_item_id = gItemIds(i)
    AND price_list_id = gPricelistIds(i)
    AND org_id = gOrgIds(i)
    AND supplier_site_id = gSupplierSiteIds(i)
    AND gRowTypes(i) = p_batch_type
    AND gSystemActions(i) = v_action;

  xErrLoc := 300;

  -- If batch type is ITEM PRICE this means we are deleting the item
  -- so we not only delete the lines from item prices we also clean up the history table
  IF (p_batch_type = 'ITEM_PRICE') THEN
    FORALL i in 1..gRowIds.COUNT
      DELETE from icx_cat_price_history
      WHERE rt_item_id = gItemIds(i)
      AND price_list_id = gPricelistIds(i)
      AND org_id = gOrgIds(i)
      AND supplier_site_id = gSupplierSiteIds(i)
      AND gRowTypes(i) = p_batch_type
      AND gSystemActions(i) = v_action;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.process_batch_delete_prices('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_delete_prices;

/* Populates ICX_POR_CATEGORY_ITEMS for items in the current batch
   Also updates the category information in icx_cat_items_tlp
   when category is changed for an item
*/
PROCEDURE process_batch_common IS
  i PLS_INTEGER;
  vCount PLS_INTEGER;
  vItemIds dbms_sql.number_table;
  vCategoryIds dbms_sql.number_table;
  xErrLoc PLS_INTEGER := 100;

BEGIN

  vCount := 0;

  xErrLoc := 100;

  -- For add we insert into category items
  FOR i in 1..gRowIds.COUNT LOOP
    IF (gSystemActions(i) = 'ADD') THEN
      vCount := vCount + 1;
      vItemIds(vCount) := gItemIds(i);
      vCategoryIds(vCount) := gCategoryIds(i);
    END IF;
  END LOOP;

  xErrLoc := 200;

  FORALL i in 1..vCount
   INSERT into icx_cat_category_items(rt_category_id, rt_item_id, last_update_login, last_updated_by, last_update_date, created_by, creation_date)
   VALUES (vCategoryIds(i), vItemIds(i), gUserLogin, gUserId, sysdate, gUserId, sysdate);

  xErrLoc := 300;

  --For update/translate we update category items
  -- There could be template reference in the category items table, so just
  -- update only for the genus category specified in the catalog file.
  FORALL i in 1..gItemIds.COUNT
    UPDATE icx_cat_category_items
    SET rt_category_id = gCategoryIds(i)
    WHERE gSystemActions(i) in ('UPDATE', 'TRANSLATE')
    and rt_item_id = gItemIds(i)
    and rt_category_id = gOldCategoryIds(i); --Bug#2714487
  xErrLoc := 350;

  -- For delete we delete from icx_cat_category_items
  FORALL i in 1..gItemIds.COUNT
    DELETE from icx_cat_category_items
    WHERE gSystemActions(i) = 'DELETE'
    and rt_category_id = gCategoryIds(i)
    and rt_item_id = gItemIds(i);

  xErrLoc := 400;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.process_batch_common('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_common;

/* Processes the new items in the current batch */
PROCEDURE process_batch_add IS
  i PLS_INTEGER;
  xErrLoc PLS_INTEGER := 100;
  v_action VARCHAR2(10) := 'ADD';
  v_cursor_id NUMBER;
  v_catid PLS_INTEGER;
  v_count  NUMBER;
BEGIN

  -- ICX_CAT_ITEMS_B
  FORALL i in 1..gRowIds.COUNT
    INSERT into icx_cat_items_b(rt_item_id, org_id, supplier_id,supplier,
      supplier_part_num, supplier_part_auxid, catalog_name, --Bug#2611529
      extractor_updated_flag, request_id, created_by,
      creation_date, last_updated_by, last_update_login, last_update_date, OBJECT_VERSION_NUMBER)
    SELECT gItemIds(i), it.org_id, it.supplier_id, it.supplier,
      it.supplier_part_num, it.supplier_part_auxid, gCatalogName, --Bug#2611529
      'N', gJobNumber, gUserId, sysdate, gUserId,
      gUserLogin, sysdate, 1
    FROM ICX_CAT_ITEMS_GT it
    WHERE it.rowid = gRowids(i)
    AND v_action = gSystemActions(i);

  xErrLoc := 200;

  -- ICX_CAT_ITEMS_TLP
  FORALL i in 1..gRowIds.COUNT
    INSERT into icx_cat_items_tlp(rt_item_id, language, org_id, supplier_id,
      item_source_type, search_type, primary_category_id,
      primary_category_name, supplier, supplier_part_num,
      supplier_part_auxid, manufacturer,--Bug#2611529
      manufacturer_url, supplier_url, --Bug#2611529
      manufacturer_part_num, description, comments, alias, picture,
      picture_url, attachment_url, long_description,  unspsc_code,
      thumbnail_image, availability, lead_time, item_type,
      text_base_attribute1, text_base_attribute2, text_base_attribute3,
      text_base_attribute4, text_base_attribute5, text_base_attribute6,
      text_base_attribute7, text_base_attribute8, text_base_attribute9,
      text_base_attribute10, text_base_attribute11, text_base_attribute12,
      text_base_attribute13, text_base_attribute14, text_base_attribute15,
      text_base_attribute16, text_base_attribute17, text_base_attribute18,
      text_base_attribute19, text_base_attribute20, text_base_attribute21,
      text_base_attribute22, text_base_attribute23, text_base_attribute24,
      text_base_attribute25, text_base_attribute26, text_base_attribute27,
      text_base_attribute28, text_base_attribute29, text_base_attribute30,
      text_base_attribute31, text_base_attribute32, text_base_attribute33,
      text_base_attribute34, text_base_attribute35, text_base_attribute36,
      text_base_attribute37, text_base_attribute38, text_base_attribute39,
      text_base_attribute40, text_base_attribute41, text_base_attribute42,
      text_base_attribute43, text_base_attribute44, text_base_attribute45,
      text_base_attribute46, text_base_attribute47, text_base_attribute48,
      text_base_attribute49, text_base_attribute50, text_base_attribute51,
      text_base_attribute52, text_base_attribute53, text_base_attribute54,
      text_base_attribute55, text_base_attribute56, text_base_attribute57,
      text_base_attribute58, text_base_attribute59, text_base_attribute60,
      text_base_attribute61, text_base_attribute62, text_base_attribute63,
      text_base_attribute64, text_base_attribute65, text_base_attribute66,
      text_base_attribute67, text_base_attribute68, text_base_attribute69,
      text_base_attribute70, text_base_attribute71, text_base_attribute72,
      text_base_attribute73, text_base_attribute74, text_base_attribute75,
      text_base_attribute76, text_base_attribute77, text_base_attribute78,
      text_base_attribute79, text_base_attribute80, text_base_attribute81,
      text_base_attribute82, text_base_attribute83, text_base_attribute84,
      text_base_attribute85, text_base_attribute86, text_base_attribute87,
      text_base_attribute88, text_base_attribute89, text_base_attribute90,
      text_base_attribute91, text_base_attribute92, text_base_attribute93,
      text_base_attribute94, text_base_attribute95, text_base_attribute96,
      text_base_attribute97, text_base_attribute98, text_base_attribute99,
      text_base_attribute100,
      num_base_attribute1, num_base_attribute2, num_base_attribute3,
      num_base_attribute4, num_base_attribute5, num_base_attribute6,
      num_base_attribute7, num_base_attribute8, num_base_attribute9,
      num_base_attribute10, num_base_attribute11, num_base_attribute12,
      num_base_attribute13, num_base_attribute14, num_base_attribute15,
      num_base_attribute16, num_base_attribute17, num_base_attribute18,
      num_base_attribute19, num_base_attribute20, num_base_attribute21,
      num_base_attribute22, num_base_attribute23, num_base_attribute24,
      num_base_attribute25, num_base_attribute26, num_base_attribute27,
      num_base_attribute28, num_base_attribute29, num_base_attribute30,
      num_base_attribute31, num_base_attribute32, num_base_attribute33,
      num_base_attribute34, num_base_attribute35, num_base_attribute36,
      num_base_attribute37, num_base_attribute38, num_base_attribute39,
      num_base_attribute40, num_base_attribute41, num_base_attribute42,
      num_base_attribute43, num_base_attribute44, num_base_attribute45,
      num_base_attribute46, num_base_attribute47, num_base_attribute48,
      num_base_attribute49, num_base_attribute50, num_base_attribute51,
      num_base_attribute52, num_base_attribute53, num_base_attribute54,
      num_base_attribute55, num_base_attribute56, num_base_attribute57,
      num_base_attribute58, num_base_attribute59, num_base_attribute60,
      num_base_attribute61, num_base_attribute62, num_base_attribute63,
      num_base_attribute64, num_base_attribute65, num_base_attribute66,
      num_base_attribute67, num_base_attribute68, num_base_attribute69,
      num_base_attribute70, num_base_attribute71, num_base_attribute72,
      num_base_attribute73, num_base_attribute74, num_base_attribute75,
      num_base_attribute76, num_base_attribute77, num_base_attribute78,
      num_base_attribute79, num_base_attribute80, num_base_attribute81,
      num_base_attribute82, num_base_attribute83, num_base_attribute84,
      num_base_attribute85, num_base_attribute86, num_base_attribute87,
      num_base_attribute88, num_base_attribute89, num_base_attribute90,
      num_base_attribute91, num_base_attribute92, num_base_attribute93,
      num_base_attribute94, num_base_attribute95, num_base_attribute96,
      num_base_attribute97, num_base_attribute98, num_base_attribute99,
      num_base_attribute100,
      tl_text_base_attribute1, tl_text_base_attribute2, tl_text_base_attribute3,
      tl_text_base_attribute4, tl_text_base_attribute5, tl_text_base_attribute6,
      tl_text_base_attribute7, tl_text_base_attribute8, tl_text_base_attribute9,
      tl_text_base_attribute10, tl_text_base_attribute11, tl_text_base_attribute12,
      tl_text_base_attribute13, tl_text_base_attribute14, tl_text_base_attribute15,
      tl_text_base_attribute16, tl_text_base_attribute17, tl_text_base_attribute18,
      tl_text_base_attribute19, tl_text_base_attribute20, tl_text_base_attribute21,
      tl_text_base_attribute22, tl_text_base_attribute23, tl_text_base_attribute24,
      tl_text_base_attribute25, tl_text_base_attribute26, tl_text_base_attribute27,
      tl_text_base_attribute28, tl_text_base_attribute29, tl_text_base_attribute30,
      tl_text_base_attribute31, tl_text_base_attribute32, tl_text_base_attribute33,
      tl_text_base_attribute34, tl_text_base_attribute35, tl_text_base_attribute36,
      tl_text_base_attribute37, tl_text_base_attribute38, tl_text_base_attribute39,
      tl_text_base_attribute40, tl_text_base_attribute41, tl_text_base_attribute42,
      tl_text_base_attribute43, tl_text_base_attribute44, tl_text_base_attribute45,
      tl_text_base_attribute46, tl_text_base_attribute47, tl_text_base_attribute48,
      tl_text_base_attribute49, tl_text_base_attribute50, tl_text_base_attribute51,
      tl_text_base_attribute52, tl_text_base_attribute53, tl_text_base_attribute54,
      tl_text_base_attribute55, tl_text_base_attribute56, tl_text_base_attribute57,
      tl_text_base_attribute58, tl_text_base_attribute59, tl_text_base_attribute60,
      tl_text_base_attribute61, tl_text_base_attribute62, tl_text_base_attribute63,
      tl_text_base_attribute64, tl_text_base_attribute65, tl_text_base_attribute66,
      tl_text_base_attribute67, tl_text_base_attribute68, tl_text_base_attribute69,
      tl_text_base_attribute70, tl_text_base_attribute71, tl_text_base_attribute72,
      tl_text_base_attribute73, tl_text_base_attribute74, tl_text_base_attribute75,
      tl_text_base_attribute76, tl_text_base_attribute77, tl_text_base_attribute78,
      tl_text_base_attribute79, tl_text_base_attribute80, tl_text_base_attribute81,
      tl_text_base_attribute82, tl_text_base_attribute83, tl_text_base_attribute84,
      tl_text_base_attribute85, tl_text_base_attribute86, tl_text_base_attribute87,
      tl_text_base_attribute88, tl_text_base_attribute89, tl_text_base_attribute90,
      tl_text_base_attribute91, tl_text_base_attribute92, tl_text_base_attribute93,
      tl_text_base_attribute94, tl_text_base_attribute95, tl_text_base_attribute96,
      tl_text_base_attribute97, tl_text_base_attribute98, tl_text_base_attribute99,
      tl_text_base_attribute100,
      ctx_desc, request_id, created_by, creation_date, last_updated_by,
      last_update_login, last_update_date)
    SELECT gItemIds(i), gJobLanguage, it.org_id,
      it.supplier_id, 'SUPPLIER', 'SUPPLIER',
      it.rt_category_id, it.category_name,
      it.supplier, it.supplier_part_num,
      it.supplier_part_auxid, it.manufacturer, --Bug#2611529
      it.manufacturer_url, it.supplier_url, --Bug#2611529
      it.manufacturer_part_num, it.description, it.comments, it.alias, it.picture,
      it.picture_url, it.attachment_url, it.long_description, it. unspsc_code,
      it.thumbnail_image, it.availability, it.lead_time, it.item_type,
      it.text_base_attribute1, it.text_base_attribute2, it.text_base_attribute3,
      it.text_base_attribute4, it.text_base_attribute5, it.text_base_attribute6,
      it.text_base_attribute7, it.text_base_attribute8, it.text_base_attribute9,
      it.text_base_attribute10, it.text_base_attribute11, it.text_base_attribute12,
      it.text_base_attribute13, it.text_base_attribute14, it.text_base_attribute15,
      it.text_base_attribute16, it.text_base_attribute17, it.text_base_attribute18,
      it.text_base_attribute19, it.text_base_attribute20, it.text_base_attribute21,
      it.text_base_attribute22, it.text_base_attribute23, it.text_base_attribute24,
      it.text_base_attribute25, it.text_base_attribute26, it.text_base_attribute27,
      it.text_base_attribute28, it.text_base_attribute29, it.text_base_attribute30,
      it.text_base_attribute31, it.text_base_attribute32, it.text_base_attribute33,
      it.text_base_attribute34, it.text_base_attribute35, it.text_base_attribute36,
      it.text_base_attribute37, it.text_base_attribute38, it.text_base_attribute39,
      it.text_base_attribute40, it.text_base_attribute41, it.text_base_attribute42,
      it.text_base_attribute43, it.text_base_attribute44, it.text_base_attribute45,
      it.text_base_attribute46, it.text_base_attribute47, it.text_base_attribute48,
      it.text_base_attribute49, it.text_base_attribute50, it.text_base_attribute51,
      it.text_base_attribute52, it.text_base_attribute53, it.text_base_attribute54,
      it.text_base_attribute55, it.text_base_attribute56, it.text_base_attribute57,
      it.text_base_attribute58, it.text_base_attribute59, it.text_base_attribute60,
      it.text_base_attribute61, it.text_base_attribute62, it.text_base_attribute63,
      it.text_base_attribute64, it.text_base_attribute65, it.text_base_attribute66,
      it.text_base_attribute67, it.text_base_attribute68, it.text_base_attribute69,
      it.text_base_attribute70, it.text_base_attribute71, it.text_base_attribute72,
      it.text_base_attribute73, it.text_base_attribute74, it.text_base_attribute75,
      it.text_base_attribute76, it.text_base_attribute77, it.text_base_attribute78,
      it.text_base_attribute79, it.text_base_attribute80, it.text_base_attribute81,
      it.text_base_attribute82, it.text_base_attribute83, it.text_base_attribute84,
      it.text_base_attribute85, it.text_base_attribute86, it.text_base_attribute87,
      it.text_base_attribute88, it.text_base_attribute89, it.text_base_attribute90,
      it.text_base_attribute91, it.text_base_attribute92, it.text_base_attribute93,
      it.text_base_attribute94, it.text_base_attribute95, it.text_base_attribute96,
      it.text_base_attribute97, it.text_base_attribute98, it.text_base_attribute99,
      it.text_base_attribute100,
      it.num_base_attribute1, it.num_base_attribute2, it.num_base_attribute3,
      it.num_base_attribute4, it.num_base_attribute5, it.num_base_attribute6,
      it.num_base_attribute7, it.num_base_attribute8, it.num_base_attribute9,
      it.num_base_attribute10, it.num_base_attribute11, it.num_base_attribute12,
      it.num_base_attribute13, it.num_base_attribute14, it.num_base_attribute15,
      it.num_base_attribute16, it.num_base_attribute17, it.num_base_attribute18,
      it.num_base_attribute19, it.num_base_attribute20, it.num_base_attribute21,
      it.num_base_attribute22, it.num_base_attribute23, it.num_base_attribute24,
      it.num_base_attribute25, it.num_base_attribute26, it.num_base_attribute27,
      it.num_base_attribute28, it.num_base_attribute29, it.num_base_attribute30,
      it.num_base_attribute31, it.num_base_attribute32, it.num_base_attribute33,
      it.num_base_attribute34, it.num_base_attribute35, it.num_base_attribute36,
      it.num_base_attribute37, it.num_base_attribute38, it.num_base_attribute39,
      it.num_base_attribute40, it.num_base_attribute41, it.num_base_attribute42,
      it.num_base_attribute43, it.num_base_attribute44, it.num_base_attribute45,
      it.num_base_attribute46, it.num_base_attribute47, it.num_base_attribute48,
      it.num_base_attribute49, it.num_base_attribute50, it.num_base_attribute51,
      it.num_base_attribute52, it.num_base_attribute53, it.num_base_attribute54,
      it.num_base_attribute55, it.num_base_attribute56, it.num_base_attribute57,
      it.num_base_attribute58, it.num_base_attribute59, it.num_base_attribute60,
      it.num_base_attribute61, it.num_base_attribute62, it.num_base_attribute63,
      it.num_base_attribute64, it.num_base_attribute65, it.num_base_attribute66,
      it.num_base_attribute67, it.num_base_attribute68, it.num_base_attribute69,
      it.num_base_attribute70, it.num_base_attribute71, it.num_base_attribute72,
      it.num_base_attribute73, it.num_base_attribute74, it.num_base_attribute75,
      it.num_base_attribute76, it.num_base_attribute77, it.num_base_attribute78,
      it.num_base_attribute79, it.num_base_attribute80, it.num_base_attribute81,
      it.num_base_attribute82, it.num_base_attribute83, it.num_base_attribute84,
      it.num_base_attribute85, it.num_base_attribute86, it.num_base_attribute87,
      it.num_base_attribute88, it.num_base_attribute89, it.num_base_attribute90,
      it.num_base_attribute91, it.num_base_attribute92, it.num_base_attribute93,
      it.num_base_attribute94, it.num_base_attribute95, it.num_base_attribute96,
      it.num_base_attribute97, it.num_base_attribute98, it.num_base_attribute99,
      it.num_base_attribute100,
      it.tl_text_base_attribute1, it.tl_text_base_attribute2, it.tl_text_base_attribute3,
      it.tl_text_base_attribute4, it.tl_text_base_attribute5, it.tl_text_base_attribute6,
      it.tl_text_base_attribute7, it.tl_text_base_attribute8, it.tl_text_base_attribute9,
      it.tl_text_base_attribute10, it.tl_text_base_attribute11, it.tl_text_base_attribute12,
      it.tl_text_base_attribute13, it.tl_text_base_attribute14, it.tl_text_base_attribute15,
      it.tl_text_base_attribute16, it.tl_text_base_attribute17, it.tl_text_base_attribute18,
      it.tl_text_base_attribute19, it.tl_text_base_attribute20, it.tl_text_base_attribute21,
      it.tl_text_base_attribute22, it.tl_text_base_attribute23, it.tl_text_base_attribute24,
      it.tl_text_base_attribute25, it.tl_text_base_attribute26, it.tl_text_base_attribute27,
      it.tl_text_base_attribute28, it.tl_text_base_attribute29, it.tl_text_base_attribute30,
      it.tl_text_base_attribute31, it.tl_text_base_attribute32, it.tl_text_base_attribute33,
      it.tl_text_base_attribute34, it.tl_text_base_attribute35, it.tl_text_base_attribute36,
      it.tl_text_base_attribute37, it.tl_text_base_attribute38, it.tl_text_base_attribute39,
      it.tl_text_base_attribute40, it.tl_text_base_attribute41, it.tl_text_base_attribute42,
      it.tl_text_base_attribute43, it.tl_text_base_attribute44, it.tl_text_base_attribute45,
      it.tl_text_base_attribute46, it.tl_text_base_attribute47, it.tl_text_base_attribute48,
      it.tl_text_base_attribute49, it.tl_text_base_attribute50, it.tl_text_base_attribute51,
      it.tl_text_base_attribute52, it.tl_text_base_attribute53, it.tl_text_base_attribute54,
      it.tl_text_base_attribute55, it.tl_text_base_attribute56, it.tl_text_base_attribute57,
      it.tl_text_base_attribute58, it.tl_text_base_attribute59, it.tl_text_base_attribute60,
      it.tl_text_base_attribute61, it.tl_text_base_attribute62, it.tl_text_base_attribute63,
      it.tl_text_base_attribute64, it.tl_text_base_attribute65, it.tl_text_base_attribute66,
      it.tl_text_base_attribute67, it.tl_text_base_attribute68, it.tl_text_base_attribute69,
      it.tl_text_base_attribute70, it.tl_text_base_attribute71, it.tl_text_base_attribute72,
      it.tl_text_base_attribute73, it.tl_text_base_attribute74, it.tl_text_base_attribute75,
      it.tl_text_base_attribute76, it.tl_text_base_attribute77, it.tl_text_base_attribute78,
      it.tl_text_base_attribute79, it.tl_text_base_attribute80, it.tl_text_base_attribute81,
      it.tl_text_base_attribute82, it.tl_text_base_attribute83, it.tl_text_base_attribute84,
      it.tl_text_base_attribute85, it.tl_text_base_attribute86, it.tl_text_base_attribute87,
      it.tl_text_base_attribute88, it.tl_text_base_attribute89, it.tl_text_base_attribute90,
      it.tl_text_base_attribute91, it.tl_text_base_attribute92, it.tl_text_base_attribute93,
      it.tl_text_base_attribute94, it.tl_text_base_attribute95, it.tl_text_base_attribute96,
      it.tl_text_base_attribute97, it.tl_text_base_attribute98, it.tl_text_base_attribute99,
      it.tl_text_base_attribute100,
      null, gJobNumber, gUserId, sysdate, gUserId, gUserLogin, sysdate
    FROM ICX_CAT_ITEMS_GT it
    WHERE it.rowid = gRowids(i)
    AND v_action = gSystemActions(i);

  xErrLoc := 300;

  -- ICX_CAT_EXT_ITEMS_TLP
  -- Category_Change
  FORALL i in 1..gRowIds.COUNT
    INSERT into icx_cat_ext_items_tlp(rt_item_id, language, org_id, request_id,
      rt_category_id, primary_flag,
      text_cat_attribute1, text_cat_attribute2, text_cat_attribute3,
      text_cat_attribute4, text_cat_attribute5, text_cat_attribute6,
      text_cat_attribute7, text_cat_attribute8, text_cat_attribute9,
      text_cat_attribute10, text_cat_attribute11, text_cat_attribute12,
      text_cat_attribute13, text_cat_attribute14, text_cat_attribute15,
      text_cat_attribute16, text_cat_attribute17, text_cat_attribute18,
      text_cat_attribute19, text_cat_attribute20, text_cat_attribute21,
      text_cat_attribute22, text_cat_attribute23, text_cat_attribute24,
      text_cat_attribute25, text_cat_attribute26, text_cat_attribute27,
      text_cat_attribute28, text_cat_attribute29, text_cat_attribute30,
      text_cat_attribute31, text_cat_attribute32, text_cat_attribute33,
      text_cat_attribute34, text_cat_attribute35, text_cat_attribute36,
      text_cat_attribute37, text_cat_attribute38, text_cat_attribute39,
      text_cat_attribute40, text_cat_attribute41, text_cat_attribute42,
      text_cat_attribute43, text_cat_attribute44, text_cat_attribute45,
      text_cat_attribute46, text_cat_attribute47, text_cat_attribute48,
      text_cat_attribute49, text_cat_attribute50,
      num_cat_attribute1, num_cat_attribute2, num_cat_attribute3,
      num_cat_attribute4, num_cat_attribute5, num_cat_attribute6,
      num_cat_attribute7, num_cat_attribute8, num_cat_attribute9,
      num_cat_attribute10, num_cat_attribute11, num_cat_attribute12,
      num_cat_attribute13, num_cat_attribute14, num_cat_attribute15,
      num_cat_attribute16, num_cat_attribute17, num_cat_attribute18,
      num_cat_attribute19, num_cat_attribute20, num_cat_attribute21,
      num_cat_attribute22, num_cat_attribute23, num_cat_attribute24,
      num_cat_attribute25, num_cat_attribute26, num_cat_attribute27,
      num_cat_attribute28, num_cat_attribute29, num_cat_attribute30,
      num_cat_attribute31, num_cat_attribute32, num_cat_attribute33,
      num_cat_attribute34, num_cat_attribute35, num_cat_attribute36,
      num_cat_attribute37, num_cat_attribute38, num_cat_attribute39,
      num_cat_attribute40, num_cat_attribute41, num_cat_attribute42,
      num_cat_attribute43, num_cat_attribute44, num_cat_attribute45,
      num_cat_attribute46, num_cat_attribute47, num_cat_attribute48,
      num_cat_attribute49, num_cat_attribute50,
      tl_text_cat_attribute1, tl_text_cat_attribute2, tl_text_cat_attribute3,
      tl_text_cat_attribute4, tl_text_cat_attribute5, tl_text_cat_attribute6,
      tl_text_cat_attribute7, tl_text_cat_attribute8, tl_text_cat_attribute9,
      tl_text_cat_attribute10, tl_text_cat_attribute11, tl_text_cat_attribute12,
      tl_text_cat_attribute13, tl_text_cat_attribute14, tl_text_cat_attribute15,
      tl_text_cat_attribute16, tl_text_cat_attribute17, tl_text_cat_attribute18,
      tl_text_cat_attribute19, tl_text_cat_attribute20, tl_text_cat_attribute21,
      tl_text_cat_attribute22, tl_text_cat_attribute23, tl_text_cat_attribute24,
      tl_text_cat_attribute25, tl_text_cat_attribute26, tl_text_cat_attribute27,
      tl_text_cat_attribute28, tl_text_cat_attribute29, tl_text_cat_attribute30,
      tl_text_cat_attribute31, tl_text_cat_attribute32, tl_text_cat_attribute33,
      tl_text_cat_attribute34, tl_text_cat_attribute35, tl_text_cat_attribute36,
      tl_text_cat_attribute37, tl_text_cat_attribute38, tl_text_cat_attribute39,
      tl_text_cat_attribute40, tl_text_cat_attribute41, tl_text_cat_attribute42,
      tl_text_cat_attribute43, tl_text_cat_attribute44, tl_text_cat_attribute45,
      tl_text_cat_attribute46, tl_text_cat_attribute47, tl_text_cat_attribute48,
      tl_text_cat_attribute49, tl_text_cat_attribute50,
      created_by, creation_date, last_updated_by,
      last_update_login, last_update_date)
    SELECT gItemIds(i), gJobLanguage, it.org_id, gJobNumber,
      it.rt_category_id, 'Y',
      it.text_cat_attribute1, it.text_cat_attribute2, it.text_cat_attribute3,
      it.text_cat_attribute4, it.text_cat_attribute5, it.text_cat_attribute6,
      it.text_cat_attribute7, it.text_cat_attribute8, it.text_cat_attribute9,
      it.text_cat_attribute10, it.text_cat_attribute11, it.text_cat_attribute12,
      it.text_cat_attribute13, it.text_cat_attribute14, it.text_cat_attribute15,
      it.text_cat_attribute16, it.text_cat_attribute17, it.text_cat_attribute18,
      it.text_cat_attribute19, it.text_cat_attribute20, it.text_cat_attribute21,
      it.text_cat_attribute22, it.text_cat_attribute23, it.text_cat_attribute24,
      it.text_cat_attribute25, it.text_cat_attribute26, it.text_cat_attribute27,
      it.text_cat_attribute28, it.text_cat_attribute29, it.text_cat_attribute30,
      it.text_cat_attribute31, it.text_cat_attribute32, it.text_cat_attribute33,
      it.text_cat_attribute34, it.text_cat_attribute35, it.text_cat_attribute36,
      it.text_cat_attribute37, it.text_cat_attribute38, it.text_cat_attribute39,
      it.text_cat_attribute40, it.text_cat_attribute41, it.text_cat_attribute42,
      it.text_cat_attribute43, it.text_cat_attribute44, it.text_cat_attribute45,
      it.text_cat_attribute46, it.text_cat_attribute47, it.text_cat_attribute48,
      it.text_cat_attribute49, it.text_cat_attribute50,
      it.num_cat_attribute1, it.num_cat_attribute2, it.num_cat_attribute3,
      it.num_cat_attribute4, it.num_cat_attribute5, it.num_cat_attribute6,
      it.num_cat_attribute7, it.num_cat_attribute8, it.num_cat_attribute9,
      it.num_cat_attribute10, it.num_cat_attribute11, it.num_cat_attribute12,
      it.num_cat_attribute13, it.num_cat_attribute14, it.num_cat_attribute15,
      it.num_cat_attribute16, it.num_cat_attribute17, it.num_cat_attribute18,
      it.num_cat_attribute19, it.num_cat_attribute20, it.num_cat_attribute21,
      it.num_cat_attribute22, it.num_cat_attribute23, it.num_cat_attribute24,
      it.num_cat_attribute25, it.num_cat_attribute26, it.num_cat_attribute27,
      it.num_cat_attribute28, it.num_cat_attribute29, it.num_cat_attribute30,
      it.num_cat_attribute31, it.num_cat_attribute32, it.num_cat_attribute33,
      it.num_cat_attribute34, it.num_cat_attribute35, it.num_cat_attribute36,
      it.num_cat_attribute37, it.num_cat_attribute38, it.num_cat_attribute39,
      it.num_cat_attribute40, it.num_cat_attribute41, it.num_cat_attribute42,
      it.num_cat_attribute43, it.num_cat_attribute44, it.num_cat_attribute45,
      it.num_cat_attribute46, it.num_cat_attribute47, it.num_cat_attribute48,
      it.num_cat_attribute49, it.num_cat_attribute50,
      it.tl_text_cat_attribute1, it.tl_text_cat_attribute2, it.tl_text_cat_attribute3,
      it.tl_text_cat_attribute4, it.tl_text_cat_attribute5, it.tl_text_cat_attribute6,
      it.tl_text_cat_attribute7, it.tl_text_cat_attribute8, it.tl_text_cat_attribute9,
      it.tl_text_cat_attribute10, it.tl_text_cat_attribute11, it.tl_text_cat_attribute12,
      it.tl_text_cat_attribute13, it.tl_text_cat_attribute14, it.tl_text_cat_attribute15,
      it.tl_text_cat_attribute16, it.tl_text_cat_attribute17, it.tl_text_cat_attribute18,
      it.tl_text_cat_attribute19, it.tl_text_cat_attribute20, it.tl_text_cat_attribute21,
      it.tl_text_cat_attribute22, it.tl_text_cat_attribute23, it.tl_text_cat_attribute24,
      it.tl_text_cat_attribute25, it.tl_text_cat_attribute26, it.tl_text_cat_attribute27,
      it.tl_text_cat_attribute28, it.tl_text_cat_attribute29, it.tl_text_cat_attribute30,
      it.tl_text_cat_attribute31, it.tl_text_cat_attribute32, it.tl_text_cat_attribute33,
      it.tl_text_cat_attribute34, it.tl_text_cat_attribute35, it.tl_text_cat_attribute36,
      it.tl_text_cat_attribute37, it.tl_text_cat_attribute38, it.tl_text_cat_attribute39,
      it.tl_text_cat_attribute40, it.tl_text_cat_attribute41, it.tl_text_cat_attribute42,
      it.tl_text_cat_attribute43, it.tl_text_cat_attribute44, it.tl_text_cat_attribute45,
      it.tl_text_cat_attribute46, it.tl_text_cat_attribute47, it.tl_text_cat_attribute48,
      it.tl_text_cat_attribute49, it.tl_text_cat_attribute50,
      gUserId, sysdate, gUserId, gUserLogin, sysdate
    FROM ICX_CAT_ITEMS_GT it
    WHERE it.rowid = gRowids(i)
    AND v_action = gSystemActions(i);

  xErrLoc := 500;

  FOR i IN 1..gDistinctCategoryIds.COUNT LOOP
    v_catid := gDistinctCategoryIds(i);

    xErrLoc := 600;
    IF (gCategoryInfo(v_catid).searchable_desc_count > 0) THEN
      xErrLoc := 650;
      build_category_ctx_sql(v_catid);
      xErrLoc := 700;

      FOR j IN 1..gAddCatCtxSQL.COUNT LOOP
        xErrLoc := 800;
        v_cursor_id := DBMS_SQL.open_cursor;
        DBMS_SQL.parse(v_cursor_id, gAddCatCtxSQL(j), dbms_sql.native);
        DBMS_SQL.bind_array(v_cursor_id, ':p_item_id', gItemIds);
        DBMS_SQL.bind_variable(v_cursor_id, ':p_language',
          gJobLanguage);
        DBMS_SQL.bind_variable(v_cursor_id, ':p_sequence', 5000 + j);
        DBMS_SQL.bind_array(v_cursor_id, ':p_rowid', gRowids);
        DBMS_SQL.bind_variable(v_cursor_id, ':current_category_id', v_catid);
        DBMS_SQL.bind_array(v_cursor_id, ':p_category_id', gCategoryIds);
        DBMS_SQL.bind_variable(v_cursor_id, ':action_name', v_action);
        DBMS_SQL.bind_array(v_cursor_id, ':p_system_action', gSystemActions);
        v_count := DBMS_SQL.execute(v_cursor_id);
        DBMS_SQL.close_cursor(v_cursor_id);
      END LOOP;

    END IF;


  END LOOP;

  -- ICX_POR_ITEMS_CTX_TLP

  FOR i IN 1..gAddRootCtxSQL.COUNT LOOP
    xErrLoc := 900 + i;
    v_cursor_id := DBMS_SQL.open_cursor;

    DBMS_SQL.parse(v_cursor_id, gAddRootCtxSQL(i), dbms_sql.native);
    DBMS_SQL.bind_array(v_cursor_id, ':p_item_id', gItemIds);
    DBMS_SQL.bind_variable(v_cursor_id, ':p_language', gJobLanguage);

    IF (i = gAddRootCtxSQL.COUNT - 1) THEN
      -- This is the <buyid> line
      DBMS_SQL.bind_variable(v_cursor_id, ':p_sequence',10000);
    ELSIF (i = gAddRootCtxSQL.COUNT) THEN
      -- This is the </buyid> line
      DBMS_SQL.BIND_VARIABLE(v_cursor_id, ':p_sequence',15000);
    ELSE
      DBMS_SQL.bind_variable(v_cursor_id, ':p_sequence', i);
    END IF;

    IF (i = 1) THEN
      -- The first SQL contains category id and name
      DBMS_SQL.bind_array(v_cursor_id, ':p_supplier_id', gSupplierIds);
      DBMS_SQL.bind_array(v_cursor_id, ':p_category_id', gCategoryIds);
      DBMS_SQL.bind_array(v_cursor_id, ':p_category_name', gCategoryNames);
    END IF;

    DBMS_SQL.bind_variable(v_cursor_id, ':action_name', v_action);
    DBMS_SQL.bind_array(v_cursor_id, ':p_system_action', gSystemActions);
    DBMS_SQL.bind_array(v_cursor_id, ':p_rowid', gRowids);
    v_count := DBMS_SQL.execute(v_cursor_id);
    DBMS_SQL.close_cursor(v_cursor_id);
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.process_batch_add('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_add;

/* Processes the item updates in the current batch */
PROCEDURE process_batch_update IS
  i PLS_INTEGER;
  j PLS_INTEGER;
  v_cursor_id PLS_INTEGER;
  v_count  PLS_INTEGER;
  v_catid PLS_INTEGER;
  v_action VARCHAR2(10) := 'UPDATE';
  v_delete_ctx_sql VARCHAR2(255);
  vUpdateItemsBSQL VARCHAR2(1000);
  v_sequence PLS_INTEGER := 10001;
  xErrLoc PLS_INTEGER := 100;
BEGIN

  -- ICX_CAT_ITEMS_B
  -- Update the catalog name, job#, object version#, last_update_date
  xErrLoc := 10;
  FORALL i in 1..gCurrentItemIds.COUNT
    UPDATE icx_cat_items_b
    SET    catalog_name = gCatalogName,
           last_updated_by = gUserId,
           last_update_login = gUserLogin,
           last_update_date = sysdate,
           request_id = gJobNumber,
           object_version_number = object_version_number+1
    WHERE rt_item_id = gCurrentItemIds(i) ;


  -- gUpdateItemsNonTLSQL: SQL to update the non-translated portion
  -- of the ICX_CAT_ITEMS_TLP
  -- gUpdateItemsTLSQL: SQL to update the translated portion
  -- of the ICX_CAT_ITEMS_TLP

  -- ICX_CAT_ITEMS_TLP: Update the Non-Translated Root descriptors
  xErrLoc := 100;
  v_cursor_id := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(v_cursor_id, gUpdateItemsNonTLSQL, DBMS_SQL.NATIVE);
  DBMS_SQL.bind_variable(v_cursor_id, ':p_user_id', gUserId);
  DBMS_SQL.bind_variable(v_cursor_id, ':p_user_login', gUserLogin);
  DBMS_SQL.bind_array(v_cursor_id, ':old_item_id', gCurrentItemIds);
  DBMS_SQL.bind_array(v_cursor_id, ':p_rowid', gRowids);
  DBMS_SQL.bind_variable(v_cursor_id, ':update_action', 'UPDATE', 10);
  DBMS_SQL.bind_array(v_cursor_id, ':p_action', gSystemActions);
  v_count := DBMS_SQL.execute(v_cursor_id);
  DBMS_SQL.close_cursor(v_cursor_id);

  -- ICX_CAT_ITEMS_TLP: Update the Translated Root descriptors
  xErrLoc := 200;
  v_cursor_id := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(v_cursor_id, gUpdateItemsTLSQL, DBMS_SQL.NATIVE);
  DBMS_SQL.bind_variable(v_cursor_id, ':p_language', gJobLanguage, 4);
  DBMS_SQL.bind_variable(v_cursor_id, ':p_user_id', gUserId);
  DBMS_SQL.bind_variable(v_cursor_id, ':p_user_login', gUserLogin);
  DBMS_SQL.bind_array(v_cursor_id, ':old_item_id', gCurrentItemIds);
  DBMS_SQL.bind_array(v_cursor_id, ':p_rowid', gRowids);
  DBMS_SQL.bind_variable(v_cursor_id, ':update_action', 'UPDATE', 10);
  DBMS_SQL.bind_array(v_cursor_id, ':p_action', gSystemActions);
  DBMS_SQL.bind_variable(v_cursor_id, ':p_request_id', gJobNumber);
  v_count := DBMS_SQL.execute(v_cursor_id);
  DBMS_SQL.close_cursor(v_cursor_id);

  xErrLoc := 300;

  -- Delete the ctx entries for the items that we update now.
  FORALL i in 1..gItemIds.COUNT
    DELETE FROM icx_cat_items_ctx_tlp
    WHERE  rt_item_id = gItemIds(i)
    AND    gSystemActions(i) = 'UPDATE';

  -- When there is a category Change, update all the descriptor values
  -- with the one from the interface table. The update is for ALL languages.
  -- The following sql will clear out all existing descriptor values
  -- for that item


  xErrLoc := 400;

  -- Erase out the existing local descriptor values when category is changed.
  -- do it only when there is atleast one local descriptor for
  -- the old category
  handle_category_change('UPDATE');

  xErrLoc := 420;

  FOR i in 1..gDistinctCategoryIds.COUNT LOOP
    v_catid := gDistinctCategoryIds(i);

    -- If Local descriptors exist for the given category
    IF (gCategoryInfo(v_catid).descriptor_count > 0) THEN
      xErrLoc := 500;

        -- Update the Non-Translateable local descriptors  for the given category
        v_cursor_id := DBMS_SQL.open_cursor;
        DBMS_SQL.parse(v_cursor_id, gCategoryInfo(v_catid).updateNonTLSQL,
          DBMS_SQL.NATIVE);
        DBMS_SQL.bind_array(v_cursor_id, ':old_item_id', gCurrentItemIds);
        DBMS_SQL.bind_array(v_cursor_id, ':p_rowid', gRowids);
        DBMS_SQL.bind_array(v_cursor_id, ':p_category_id', gCategoryIds);
        DBMS_SQL.bind_variable(v_cursor_id, ':update_action',
          'UPDATE', 10);
        DBMS_SQL.bind_array(v_cursor_id, ':p_action', gSystemActions);
        DBMS_SQL.bind_variable(v_cursor_id, ':p_user_id', gUserId);
        DBMS_SQL.bind_variable(v_cursor_id, ':p_user_login', gUserLogin);
        v_count := DBMS_SQL.execute(v_cursor_id);
        DBMS_SQL.close_cursor(v_cursor_id);

        xErrLoc := 600;

        -- Update the Translateable local descriptors  for the given category
        v_cursor_id := DBMS_SQL.open_cursor;
        DBMS_SQL.parse(v_cursor_id, gCategoryInfo(v_catid).updateTLSQL,
          DBMS_SQL.NATIVE);
        DBMS_SQL.bind_variable(v_cursor_id, ':p_request_id', gJobNumber);
        DBMS_SQL.bind_variable(v_cursor_id, ':p_language',
          gJobLanguage, 4);
        DBMS_SQL.bind_array(v_cursor_id, ':old_item_id', gCurrentItemIds);
        DBMS_SQL.bind_array(v_cursor_id, ':p_rowid', gRowids);
        DBMS_SQL.bind_array(v_cursor_id, ':p_category_id', gCategoryIds);
        DBMS_SQL.bind_variable(v_cursor_id, ':update_action',
          'UPDATE', 10);
        DBMS_SQL.bind_array(v_cursor_id, ':p_action', gSystemActions);
        DBMS_SQL.bind_variable(v_cursor_id, ':p_user_id', gUserId);
        DBMS_SQL.bind_variable(v_cursor_id, ':p_user_login', gUserLogin);
        v_count := DBMS_SQL.execute(v_cursor_id);
        DBMS_SQL.close_cursor(v_cursor_id);

        xErrLoc := 700;

    END IF; -- end of if local descriptors exist

  -- CTX_DESC Update

    IF (gCategoryInfo(v_catid).searchable_desc_count > 0) THEN
        xErrLoc := 800;
        build_category_ctx_sql(v_catid);
        xErrLoc := 900;

        FOR j IN 1..gUpdateCatCtxSQL.COUNT LOOP
          v_cursor_id := DBMS_SQL.open_cursor;
          DBMS_SQL.parse(v_cursor_id, gUpdateCatCtxSQL(j),
            dbms_sql.native);
          DBMS_SQL.bind_variable(v_cursor_id, ':p_sequence', 5000 + j);
          DBMS_SQL.bind_array(v_cursor_id, ':p_item_id', gItemIds);
          DBMS_SQL.bind_variable(v_cursor_id, ':current_category_id', v_catid);
          DBMS_SQL.bind_array(v_cursor_id, ':p_category_id', gCategoryIds);
          DBMS_SQL.bind_variable(v_cursor_id, ':action_name', v_action);
          DBMS_SQL.bind_array(v_cursor_id, ':p_system_action', gSystemActions);
          v_count := DBMS_SQL.execute(v_cursor_id);
          DBMS_SQL.close_cursor(v_cursor_id);
        END LOOP;
    END IF;

  END LOOP;

  -- ICX_POR_CTX_TL
  xErrLoc := 1100;

  FOR i IN 1..gUpdateRootCtxSQL.COUNT LOOP
    v_cursor_id := DBMS_SQL.open_cursor;

    DBMS_SQL.parse(v_cursor_id, gUpdateRootCtxSQL(i), dbms_sql.native);

    IF (i = gUpdateRootCtxSQL.COUNT - 1) THEN
      -- This is the <buyid> line
      DBMS_SQL.bind_variable(v_cursor_id, ':p_sequence',10000);
    ELSIF (i = gUpdateRootCtxSQL.COUNT) THEN
      -- This is the </buyid> line
      DBMS_SQL.BIND_VARIABLE(v_cursor_id, ':p_sequence',15000);
    ELSE
      DBMS_SQL.bind_variable(v_cursor_id, ':p_sequence', i);
    END IF;

    DBMS_SQL.bind_variable(v_cursor_id, ':action_name', v_action);
    DBMS_SQL.bind_array(v_cursor_id, ':p_system_action', gSystemActions);
    DBMS_SQL.bind_array(v_cursor_id, ':p_item_id', gItemIds);
    v_count := DBMS_SQL.execute(v_cursor_id);
    DBMS_SQL.close_cursor(v_cursor_id);
  END LOOP;

  -- BUYER ID NORMALIZATION
  -- Inserts the buyer ids for the items
  -- This should work for both UPDATE and TRANSLATE
  xErrLoc := 1200;

  FORALL i IN 1..gRowids.COUNT
    INSERT INTO icx_cat_items_ctx_tlp
      (rt_item_id, language, sequence, ctx_desc, org_id,
       LAST_UPDATE_LOGIN, LAST_UPDATED_BY, LAST_UPDATE_DATE,
       CREATED_BY, CREATION_DATE)
    SELECT gItemIds(i), tl.language, v_sequence,
      to_char(pll.org_id), pll.org_id,
      gUserLogin, gUserId, sysdate,
      gUserId, sysdate
    FROM icx_cat_items_tlp tl,
    (SELECT DISTINCT org_id
     FROM icx_cat_item_prices pll
     WHERE rt_item_id = gCurrentItemIds(i)
     ) pll
    WHERE tl.rt_item_id = gItemIds(i)
    AND gSystemActions(i) = v_action;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    IF (DBMS_SQL.is_open(v_cursor_id)) THEN
      DBMS_SQL.close_cursor(v_cursor_id);
    END IF;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.process_batch_update('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_update;

/* Processes the item deletions in the current batch */
PROCEDURE process_batch_delete IS
  i PLS_INTEGER;
  v_action VARCHAR2(10) := 'DELETE';
  xErrLoc PLS_INTEGER := 100;
BEGIN

  -- ICX_CAT_ITEMS_B
  FORALL i in 1..gRowIds.COUNT
    DELETE from icx_cat_items_b
    WHERE rt_item_id = gItemIds(i)
    AND v_action = gSystemActions(i);

  xErrLoc := 200;

  -- ICX_CAT_ITEMS_TLP
  FORALL i in 1..gRowIds.COUNT
    DELETE from icx_cat_items_tlp
    WHERE rt_item_id = gItemIds(i)
    AND v_action = gSystemActions(i);

  xErrLoc := 250;
  -- ICX_CAT_ITEMS_CTX_TLP
  FORALL i in 1..gRowIds.COUNT
    DELETE from icx_cat_items_ctx_tlp
    WHERE rt_item_id = gItemIds(i)
    AND v_action = gSystemActions(i);

  xErrLoc := 300;

  -- ICX_CAT_EXT_ITEMS_TLP
  FORALL i in 1..gRowIds.COUNT
    DELETE from icx_cat_ext_items_tlp
    WHERE rt_item_id = gItemIds(i)
    AND v_action = gSystemActions(i);

  xErrLoc := 400;

  -- ICX_CAT_CATEGORY_ITEMS
  FORALL i in 1..gRowIds.COUNT
    DELETE from icx_cat_category_items
    WHERE rt_item_id = gItemIds(i)
    AND v_action = gSystemActions(i);

  xErrLoc := 450;

  -- Favorite Lists: POR_FAVORITE_LIST_LINES
  FORALL i in 1..gRowIds.COUNT
    delete from por_favorite_list_lines
    where  rt_item_id = gItemIds(i)
    AND v_action = gSystemActions(i);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.process_batch_delete('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_delete;

/* Processes the item translations in the current batch */
PROCEDURE process_batch_translate IS
  i PLS_INTEGER;
  j PLS_INTEGER;
  k PLS_INTEGER;
  v_orig_ctx VARCHAR2(10);
  v_new_ctx VARCHAR2(10);
  v_cursor_id NUMBER;
  v_count  NUMBER;
  v_catid NUMBER;
  v_action VARCHAR2(10) :=  'TRANSLATE';
  v_sequence PLS_INTEGER := 10001;
  xErrLoc PLS_INTEGER := 100;
  v_delete_ctx_sql VARCHAR2(255);
BEGIN
  -- ICX_CAT_ITEMS_TLP: Insert new Row
  xErrLoc := 100;
  v_cursor_id := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(v_cursor_id, gTranslateItemsSQL, DBMS_SQL.NATIVE);
  DBMS_SQL.bind_variable(v_cursor_id, ':p_user_id', gUserId);
  DBMS_SQL.bind_variable(v_cursor_id, ':p_user_login', gUserLogin);
  DBMS_SQL.bind_array(v_cursor_id, ':old_item_id', gCurrentItemIds);
  DBMS_SQL.bind_array(v_cursor_id, ':p_rowid', gRowids);
  DBMS_SQL.bind_variable(v_cursor_id, ':update_action', 'TRANSLATE', 10);
  DBMS_SQL.bind_array(v_cursor_id, ':p_action', gSystemActions);
--  DBMS_SQL.bind_variable(v_cursor_id, ':p_language', gJobLanguage);
  v_count := DBMS_SQL.execute(v_cursor_id);
  DBMS_SQL.close_cursor(v_cursor_id);

  xErrLoc := 200;
  -- ICX_CAT_ITEMS_TLP: Update the Non-Translated Root descriptors
  v_cursor_id := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(v_cursor_id, gUpdateItemsNonTLSQL, DBMS_SQL.NATIVE);
  DBMS_SQL.bind_variable(v_cursor_id, ':p_user_id', gUserId);
  DBMS_SQL.bind_variable(v_cursor_id, ':p_user_login', gUserLogin);
  DBMS_SQL.bind_array(v_cursor_id, ':old_item_id', gCurrentItemIds);
  DBMS_SQL.bind_array(v_cursor_id, ':p_rowid', gRowids);
  DBMS_SQL.bind_variable(v_cursor_id, ':update_action', 'TRANSLATE', 10);
  DBMS_SQL.bind_array(v_cursor_id, ':p_action', gSystemActions);
  v_count := DBMS_SQL.execute(v_cursor_id);
  DBMS_SQL.close_cursor(v_cursor_id);

  -- Delete the ctx entries for the items that we translate now.
  v_delete_ctx_sql := 'delete from icx_cat_items_ctx_tlp where rt_item_id = :rt_item_id and :p_action=:update_action';
  v_cursor_id := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(v_cursor_id, v_delete_ctx_sql, dbms_sql.native);
  DBMS_SQL.bind_array(v_cursor_id, ':rt_item_id', gItemIds);
  DBMS_SQL.bind_array(v_cursor_id, ':p_action', gSystemActions);
  DBMS_SQL.bind_variable(v_cursor_id, ':update_action', 'TRANSLATE');
  v_count := DBMS_SQL.execute(v_cursor_id);
  DBMS_SQL.close_cursor(v_cursor_id);
  xErrLoc := 300;

  xErrLoc := 600;
  -- Erase out the existing local descriptor values when category is changed.
  -- do it only when there is atleast one local descriptor for the old category
  handle_category_change('TRANSLATE');

  FOR i IN 1..gDistinctCategoryIds.COUNT LOOP
    xErrLoc := 300+i;
    v_catid := gDistinctCategoryIds(i);

    --Bug#3657792
    --Insert into icx_cat_ext_items_tlp should be done even if there are no local descriptors
    --So put the cursor gCategoryInfo(v_catid).translateSQL to insert into icx_cat_ext_items_tlp
    --outside of the if check (gCategoryInfo(v_catid).descriptor_count > 0)
      -- Insert into ICX_CAT_EXT_ITEMS_TLP for the new language
      xErrLoc := 500;
      v_cursor_id := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor_id, gCategoryInfo(v_catid).translateSQL,
        DBMS_SQL.NATIVE);
      DBMS_SQL.bind_array(v_cursor_id, ':old_item_id', gCurrentItemIds);
      DBMS_SQL.bind_array(v_cursor_id, ':p_rowid', gRowids);
      DBMS_SQL.bind_array(v_cursor_id, ':p_category_id', gCategoryIds);
      DBMS_SQL.bind_array(v_cursor_id, ':p_action', gSystemActions);
      DBMS_SQL.bind_variable(v_cursor_id, ':update_action', 'TRANSLATE', 10);
      DBMS_SQL.bind_variable(v_cursor_id, ':p_user_id', gUserId);
      DBMS_SQL.bind_variable(v_cursor_id, ':p_user_login', gUserLogin);
      v_count := DBMS_SQL.execute(v_cursor_id);
      DBMS_SQL.close_cursor(v_cursor_id);

    IF (gCategoryInfo(v_catid).descriptor_count > 0) THEN
      -- Handle category changes
      xErrLoc := 400;

      -- Update the Non-Translateable local descriptors  for the given category
      -- updateNonTLSQL is reused for Translate here
      v_cursor_id := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor_id, gCategoryInfo(v_catid).updateNonTLSQL,
        DBMS_SQL.NATIVE);
      DBMS_SQL.bind_array(v_cursor_id, ':old_item_id', gCurrentItemIds);
      DBMS_SQL.bind_array(v_cursor_id, ':p_rowid', gRowids);
      DBMS_SQL.bind_array(v_cursor_id, ':p_category_id', gCategoryIds);
      DBMS_SQL.bind_variable(v_cursor_id, ':update_action',
        'TRANSLATE', 10);
      DBMS_SQL.bind_array(v_cursor_id, ':p_action', gSystemActions);
      DBMS_SQL.bind_variable(v_cursor_id, ':p_user_id', gUserId);
      DBMS_SQL.bind_variable(v_cursor_id, ':p_user_login', gUserLogin);
      v_count := DBMS_SQL.execute(v_cursor_id);
      DBMS_SQL.close_cursor(v_cursor_id);

      IF (gCategoryInfo(v_catid).searchable_desc_count > 0) THEN
        xErrLoc := 700;
        build_category_ctx_sql(v_catid);

        FOR j IN 1..gUpdateCatCtxSQL.COUNT LOOP
          v_cursor_id := DBMS_SQL.open_cursor;
          DBMS_SQL.parse(v_cursor_id, gUpdateCatCtxSQL(j),
            dbms_sql.native);
          DBMS_SQL.bind_variable(v_cursor_id, ':p_sequence', 5000 + j);
          DBMS_SQL.bind_variable(v_cursor_id, ':current_category_id', v_catid);
          DBMS_SQL.bind_array(v_cursor_id, ':p_category_id', gCategoryIds);
          DBMS_SQL.bind_variable(v_cursor_id, ':action_name', v_action);
          DBMS_SQL.bind_array(v_cursor_id, ':p_system_action', gSystemActions);
          DBMS_SQL.bind_array(v_cursor_id, ':p_item_id', gItemIds);
          v_count := DBMS_SQL.execute(v_cursor_id);
          DBMS_SQL.close_cursor(v_cursor_id);
        END LOOP;

      END IF;

    END IF;

  END LOOP;

  -- ICX_POR_CTX_TL
  xErrLoc := 800;

  FOR i IN 1..gUpdateRootCtxSQL.COUNT LOOP
    v_cursor_id := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(v_cursor_id, gUpdateRootCtxSQL(i), dbms_sql.native);

    IF (i = gUpdateRootCtxSQL.COUNT - 1) THEN
      -- This is the <buyid> line
      DBMS_SQL.bind_variable(v_cursor_id, ':p_sequence',10000);
    ELSIF (i = gUpdateRootCtxSQL.COUNT) THEN
      -- This is the </buyid> line
      DBMS_SQL.bind_variable(v_cursor_id, ':p_sequence',15000);
    ELSE
      DBMS_SQL.bind_variable(v_cursor_id, ':p_sequence', i);
    END IF;

    DBMS_SQL.bind_variable(v_cursor_id, ':action_name', v_action);
    DBMS_SQL.bind_array(v_cursor_id, ':p_system_action', gSystemActions);
    DBMS_SQL.bind_array(v_cursor_id, ':p_item_id', gItemIds);
    v_count := DBMS_SQL.execute(v_cursor_id);
    DBMS_SQL.close_cursor(v_cursor_id);
  END LOOP;

  -- BUYER ID NORMALIZATION
  -- Inserts the buyer ids for the items
  -- This should work for both UPDATE and TRANSLATE
  xErrLoc := 900;

  FORALL i IN 1..gRowids.COUNT
    INSERT INTO icx_cat_items_ctx_tlp
      (rt_item_id, language, sequence, ctx_desc, org_id)
    SELECT gItemIds(i), tl.language, v_sequence,
      to_char(pll.org_id), pll.org_id
    FROM icx_cat_items_tlp tl,
    (SELECT DISTINCT org_id
     FROM icx_cat_item_prices pll
     WHERE rt_item_id = gCurrentItemIds(i)
    ) pll
    WHERE tl.rt_item_id = gItemIds(i)
    AND gSystemActions(i) = v_action;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    IF (DBMS_SQL.is_open(v_cursor_id)) THEN
      DBMS_SQL.close_cursor(v_cursor_id);
    END IF;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.process_batch_translate('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_translate;

/* Processes the current price batch*/
PROCEDURE process_batch_prices(pHasAdd IN BOOLEAN, pHasDelete IN BOOLEAN, pNumFailedLines IN OUT NOCOPY NUMBER) IS
  xErrLoc PLS_INTEGER := 100;
BEGIN

  xErrLoc := 200;
  IF (pHasAdd) THEN
    xErrLoc := 300;
    process_batch_addupdate_prices('PRICE', 'ADD', pNumFailedLines);
  END IF;

  IF (pHasDelete) THEN
    xErrLoc := 500;
    process_batch_delete_prices('PRICE');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.process_batch_prices('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_prices;

/* Processes the current item batch */
PROCEDURE process_batch_items(pHasAdd IN BOOLEAN,
  pHasUpdate IN BOOLEAN, pHasDelete IN BOOLEAN,
  pHasTranslate IN BOOLEAN, pHasPrices IN BOOLEAN) IS
  xErrLoc PLS_INTEGER := 100;

BEGIN

  xErrLoc := 100;
  load_distinct_categories;

  xErrLoc := 200;

  process_batch_common;

  IF (pHasAdd) THEN
    xErrLoc := 600;
    process_batch_add;

    IF (pHasPrices) THEN
      xErrLoc := 700;
      process_batch_add_prices('ITEM_PRICE');
    END IF;

  END IF;

  IF (pHasUpdate) THEN
    xErrLoc := 800;
    process_batch_update;

    IF (pHasPrices) THEN
      xErrLoc := 900;
      process_batch_addupdate_prices('ITEM_PRICE','UPDATE');
    END IF;

  END IF;
commit;

  IF (pHasTranslate) THEN
    xErrLoc := 1000;
    process_batch_translate;

    IF (pHasPrices) THEN
      xErrLoc := 1100;
      process_batch_addupdate_prices('ITEM_PRICE','TRANSLATE');
    END IF;

  END IF;

  IF (pHasDelete) THEN
    xErrLoc := 1200;
    process_batch_delete;

    IF (pHasPrices) THEN
      xErrLoc := 1300;
      process_batch_delete_prices('ITEM_PRICE');
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.process_batch_items('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_items;

/**
 ** Proc : save_failed_line_message
 ** Desc : Parse the error_message of Interface table, the format
 **        is '.KEY1:MESSAGE1.KEY2:MESSAGE2.KEY3:MESSAGE3......',
 **        insert these pairs of error messages into table
 **        icx_por_failed_line_messages.
 **/
PROCEDURE save_failed_line_message (p_request_id NUMBER,
  p_line_number NUMBER, p_error_message VARCHAR2) IS
  xErrLoc   INTEGER := 0;
  xLocation number := 0;
  xStart    number := 1;
  xString   varchar2(200) := '';
  xIndex    number := 0;
  xKey      varchar2(100) := '';
  xMessage  varchar2(100) := '';
BEGIN
  xErrLoc := 100;

  if (p_error_message is null) then
    return;
  end if;

  LOOP
    xLocation := instr(p_error_message, '.', xStart);

    xErrLoc := 150;

    if (xLocation = 0) then
      xString := substr(p_error_message, xStart);
    else
      xString := substr(p_error_message, xStart, xLocation-xStart);
    end if;
    if (xString is null) then
      xIndex := 0;
    else
      xIndex := instr(xString, ':');
    end if;

    xErrLoc := 200;

    if (xIndex <> 0) then
      xErrLoc := 300;

      xKey := substr(xString, 1, xIndex-1);
      xMessage := substr(xString, xIndex+1);
      xErrLoc := 350;

      insert into icx_por_failed_line_messages
      (job_number, line_number, descriptor_key, message_name)
      values
      (p_request_id, p_line_number, xKey, xMessage);

    end if;

    xStart := xLocation + 1;

    if (xLocation = 0) then
      EXIT;
    end if;

  END LOOP;
commit;

  xErrLoc := 400;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_ITEM_UPLOAD.save_failed_line_message('
        || xErrLoc || '): ' || SQLERRM);

END save_failed_line_message;

/* Retrieves attributes for a given category */
PROCEDURE fetch_local_descriptors(pCategoryId IN NUMBER) IS
  i pls_integer := 0;
  CURSOR local_descriptors_cr(v_category_id NUMBER) IS
    select d.key
    from   icx_cat_descriptors_tl d
    where  d.rt_category_id = v_category_id
--    and    d.class in ('POM_CAT_ATTR')
    and    d.language = gJobLanguage
    order  by d.rt_descriptor_id;
  xErrLoc PLS_INTEGER := 100;
BEGIN

  IF (gErrorCatId <> pCategoryId) THEN
    gErrorCatId := pCategoryId;
    gErrorCatDescKeys.DELETE;

    FOR rec IN local_descriptors_cr(pCategoryId) LOOP
      i := i + 1;
      gErrorCatDescKeys(i) := rec.key;
    END LOOP;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.fetch_local_descriptors('
      || xErrLoc || '): ' || SQLERRM);
END fetch_local_descriptors;

/* Saves a failed item */
PROCEDURE save_failed_item(pJobNumber IN NUMBER,
  p_failed_item IN ICX_CAT_ITEMS_GT%ROWTYPE) IS
  v_rec tITRowRecord;
  i PLS_INTEGER;
  xErrLoc PLS_INTEGER;
  vDescKey ICX_POR_FAILED_LINES.DESCRIPTOR_KEY%TYPE;
  --Bug#3396442
  v_section_tag PLS_INTEGER;
  CURSOR custom_non_price_desc_cr(p_category_id NUMBER) IS
    select rt_descriptor_id, type, key,
           section_tag, stored_in_column, stored_in_table,
           searchable
    from   icx_cat_descriptors_tl
    where  rt_category_id = p_category_id
    and    language = gJobLanguage
    and    stored_in_table = 'ICX_CAT_ITEMS_TLP'
    and    rt_descriptor_id >= 100000
    order  by rt_descriptor_id;
BEGIN
  xErrLoc := 100;
  -- First convert p_failed_item into v_rec for easier manipulation
  v_rec.line_number             := p_failed_item.line_number;
  v_rec.row_type                := p_failed_item.row_type;
  v_rec.processed_flag          := p_failed_item.processed_flag;
  v_rec.language                := p_failed_item.language;
  v_rec.action                  := p_failed_item.action;
  v_rec.system_action           := p_failed_item.system_action;
  --bug#3593728
  --In some cases if system_action is null then replace it with action
  --this system_action is only used to insert into icx_por_failed_lines table
  IF ( v_rec.system_action IS NULL ) THEN
    xErrLoc := 110;
    icx_por_ext_utl.debug(icx_por_ext_utl.MUST_LEVEL,
        'system_action is null in save_failed_item;' ||
        ' v_rec.action:' ||v_rec.action||
        ', v_rec.system_action:' ||v_rec.system_action||
        ', v_rec.error_flag:' ||v_rec.error_flag||
        ', v_rec.supplier_part_num:' ||v_rec.supplier_part_num||
        ', v_rec.error_message:' ||v_rec.error_message);
    xErrLoc := 120;
    v_rec.system_action := v_rec.action;
  END IF;
  v_rec.error_flag              := p_failed_item.error_flag;
  v_rec.error_message           := p_failed_item.error_message;
  v_rec.required_descriptors    := p_failed_item.required_descriptors;
  v_rec.required_tl_descriptors := p_failed_item.required_tl_descriptors;
  v_rec.has_cat_attribute_flag  := p_failed_item.has_cat_attribute_flag;
  v_rec.rt_category_id          := p_failed_item.rt_category_id;
  v_rec.category_name           := p_failed_item.category_name;
  v_rec.org_id                  := p_failed_item.org_id;
  v_rec.supplier_id             := p_failed_item.supplier_id;
  v_rec.supplier                := p_failed_item.supplier;
  v_rec.supplier_part_num       := p_failed_item.supplier_part_num;
  v_rec.supplier_part_auxid     := p_failed_item.supplier_part_auxid;
  v_rec.manufacturer            := p_failed_item.manufacturer;
  v_rec.manufacturer_part_num   := p_failed_item.manufacturer_part_num;
  v_rec.description             := p_failed_item.description;
  v_rec.comments                := p_failed_item.comments;
  v_rec.alias                   := p_failed_item.alias;
  v_rec.picture                 := p_failed_item.picture;
  v_rec.picture_url             := p_failed_item.picture_url;
  v_rec.thumbnail_image         := p_failed_item.thumbnail_image;
  v_rec.attachment_url          := p_failed_item.attachment_url;
  v_rec.supplier_url            := p_failed_item.supplier_url;
  v_rec.manufacturer_url        := p_failed_item.manufacturer_url;
  v_rec.long_description        := p_failed_item.long_description;
  v_rec.unspsc_code             := p_failed_item.unspsc_code;
  v_rec.availability            := p_failed_item.availability;
  v_rec.lead_time               := p_failed_item.lead_time;
  v_rec.item_type               := p_failed_item.item_type;
  v_rec.contract_num            := p_failed_item.contract_num;
  v_rec.contract_id             := p_failed_item.contract_id;
  v_rec.roots(1) := p_failed_item.text_base_attribute1;
  v_rec.roots(2) := p_failed_item.text_base_attribute2;
  v_rec.roots(3) := p_failed_item.text_base_attribute3;
  v_rec.roots(4) := p_failed_item.text_base_attribute4;
  v_rec.roots(5) := p_failed_item.text_base_attribute5;
  v_rec.roots(6) := p_failed_item.text_base_attribute6;
  v_rec.roots(7) := p_failed_item.text_base_attribute7;
  v_rec.roots(8) := p_failed_item.text_base_attribute8;
  v_rec.roots(9) := p_failed_item.text_base_attribute9;
  v_rec.roots(10) := p_failed_item.text_base_attribute10;
  v_rec.roots(11) := p_failed_item.text_base_attribute11;
  v_rec.roots(12) := p_failed_item.text_base_attribute12;
  v_rec.roots(13) := p_failed_item.text_base_attribute13;
  v_rec.roots(14) := p_failed_item.text_base_attribute14;
  v_rec.roots(15) := p_failed_item.text_base_attribute15;
  v_rec.roots(16) := p_failed_item.text_base_attribute16;
  v_rec.roots(17) := p_failed_item.text_base_attribute17;
  v_rec.roots(18) := p_failed_item.text_base_attribute18;
  v_rec.roots(19) := p_failed_item.text_base_attribute19;
  v_rec.roots(20) := p_failed_item.text_base_attribute20;
  v_rec.roots(21) := p_failed_item.text_base_attribute21;
  v_rec.roots(22) := p_failed_item.text_base_attribute22;
  v_rec.roots(23) := p_failed_item.text_base_attribute23;
  v_rec.roots(24) := p_failed_item.text_base_attribute24;
  v_rec.roots(25) := p_failed_item.text_base_attribute25;
  v_rec.roots(26) := p_failed_item.text_base_attribute26;
  v_rec.roots(27) := p_failed_item.text_base_attribute27;
  v_rec.roots(28) := p_failed_item.text_base_attribute28;
  v_rec.roots(29) := p_failed_item.text_base_attribute29;
  v_rec.roots(30) := p_failed_item.text_base_attribute30;
  v_rec.roots(31) := p_failed_item.text_base_attribute31;
  v_rec.roots(32) := p_failed_item.text_base_attribute32;
  v_rec.roots(33) := p_failed_item.text_base_attribute33;
  v_rec.roots(34) := p_failed_item.text_base_attribute34;
  v_rec.roots(35) := p_failed_item.text_base_attribute35;
  v_rec.roots(36) := p_failed_item.text_base_attribute36;
  v_rec.roots(37) := p_failed_item.text_base_attribute37;
  v_rec.roots(38) := p_failed_item.text_base_attribute38;
  v_rec.roots(39) := p_failed_item.text_base_attribute39;
  v_rec.roots(40) := p_failed_item.text_base_attribute40;
  v_rec.roots(41) := p_failed_item.text_base_attribute41;
  v_rec.roots(42) := p_failed_item.text_base_attribute42;
  v_rec.roots(43) := p_failed_item.text_base_attribute43;
  v_rec.roots(44) := p_failed_item.text_base_attribute44;
  v_rec.roots(45) := p_failed_item.text_base_attribute45;
  v_rec.roots(46) := p_failed_item.text_base_attribute46;
  v_rec.roots(47) := p_failed_item.text_base_attribute47;
  v_rec.roots(48) := p_failed_item.text_base_attribute48;
  v_rec.roots(49) := p_failed_item.text_base_attribute49;
  v_rec.roots(50) := p_failed_item.text_base_attribute50;
  v_rec.roots(51) := p_failed_item.text_base_attribute51;
  v_rec.roots(52) := p_failed_item.text_base_attribute52;
  v_rec.roots(53) := p_failed_item.text_base_attribute53;
  v_rec.roots(54) := p_failed_item.text_base_attribute54;
  v_rec.roots(55) := p_failed_item.text_base_attribute55;
  v_rec.roots(56) := p_failed_item.text_base_attribute56;
  v_rec.roots(57) := p_failed_item.text_base_attribute57;
  v_rec.roots(58) := p_failed_item.text_base_attribute58;
  v_rec.roots(59) := p_failed_item.text_base_attribute59;
  v_rec.roots(60) := p_failed_item.text_base_attribute60;
  v_rec.roots(61) := p_failed_item.text_base_attribute61;
  v_rec.roots(62) := p_failed_item.text_base_attribute62;
  v_rec.roots(63) := p_failed_item.text_base_attribute63;
  v_rec.roots(64) := p_failed_item.text_base_attribute64;
  v_rec.roots(65) := p_failed_item.text_base_attribute65;
  v_rec.roots(66) := p_failed_item.text_base_attribute66;
  v_rec.roots(67) := p_failed_item.text_base_attribute67;
  v_rec.roots(68) := p_failed_item.text_base_attribute68;
  v_rec.roots(69) := p_failed_item.text_base_attribute69;
  v_rec.roots(70) := p_failed_item.text_base_attribute70;
  v_rec.roots(71) := p_failed_item.text_base_attribute71;
  v_rec.roots(72) := p_failed_item.text_base_attribute72;
  v_rec.roots(73) := p_failed_item.text_base_attribute73;
  v_rec.roots(74) := p_failed_item.text_base_attribute74;
  v_rec.roots(75) := p_failed_item.text_base_attribute75;
  v_rec.roots(76) := p_failed_item.text_base_attribute76;
  v_rec.roots(77) := p_failed_item.text_base_attribute77;
  v_rec.roots(78) := p_failed_item.text_base_attribute78;
  v_rec.roots(79) := p_failed_item.text_base_attribute79;
  v_rec.roots(80) := p_failed_item.text_base_attribute80;
  v_rec.roots(81) := p_failed_item.text_base_attribute81;
  v_rec.roots(82) := p_failed_item.text_base_attribute82;
  v_rec.roots(83) := p_failed_item.text_base_attribute83;
  v_rec.roots(84) := p_failed_item.text_base_attribute84;
  v_rec.roots(85) := p_failed_item.text_base_attribute85;
  v_rec.roots(86) := p_failed_item.text_base_attribute86;
  v_rec.roots(87) := p_failed_item.text_base_attribute87;
  v_rec.roots(88) := p_failed_item.text_base_attribute88;
  v_rec.roots(89) := p_failed_item.text_base_attribute89;
  v_rec.roots(90) := p_failed_item.text_base_attribute90;
  v_rec.roots(91) := p_failed_item.text_base_attribute91;
  v_rec.roots(92) := p_failed_item.text_base_attribute92;
  v_rec.roots(93) := p_failed_item.text_base_attribute93;
  v_rec.roots(94) := p_failed_item.text_base_attribute94;
  v_rec.roots(95) := p_failed_item.text_base_attribute95;
  v_rec.roots(96) := p_failed_item.text_base_attribute96;
  v_rec.roots(97) := p_failed_item.text_base_attribute97;
  v_rec.roots(98) := p_failed_item.text_base_attribute98;
  v_rec.roots(99) := p_failed_item.text_base_attribute99;
  v_rec.roots(100) := p_failed_item.text_base_attribute100;
  --Bug#2785949
  --Removed the to_char function as
  --p_failed_item.num_base_attribute1..p_failed_item.num_base_attribute100
  --is already VARCHAR type
  v_rec.roots(101) := p_failed_item.num_base_attribute1;
  v_rec.roots(102) := p_failed_item.num_base_attribute2;
  v_rec.roots(103) := p_failed_item.num_base_attribute3;
  v_rec.roots(104) := p_failed_item.num_base_attribute4;
  v_rec.roots(105) := p_failed_item.num_base_attribute5;
  v_rec.roots(106) := p_failed_item.num_base_attribute6;
  v_rec.roots(107) := p_failed_item.num_base_attribute7;
  v_rec.roots(108) := p_failed_item.num_base_attribute8;
  v_rec.roots(109) := p_failed_item.num_base_attribute9;
  v_rec.roots(110) := p_failed_item.num_base_attribute10;
  v_rec.roots(111) := p_failed_item.num_base_attribute11;
  v_rec.roots(112) := p_failed_item.num_base_attribute12;
  v_rec.roots(113) := p_failed_item.num_base_attribute13;
  v_rec.roots(114) := p_failed_item.num_base_attribute14;
  v_rec.roots(115) := p_failed_item.num_base_attribute15;
  v_rec.roots(116) := p_failed_item.num_base_attribute16;
  v_rec.roots(117) := p_failed_item.num_base_attribute17;
  v_rec.roots(118) := p_failed_item.num_base_attribute18;
  v_rec.roots(119) := p_failed_item.num_base_attribute19;
  v_rec.roots(120) := p_failed_item.num_base_attribute20;
  v_rec.roots(121) := p_failed_item.num_base_attribute21;
  v_rec.roots(122) := p_failed_item.num_base_attribute22;
  v_rec.roots(123) := p_failed_item.num_base_attribute23;
  v_rec.roots(124) := p_failed_item.num_base_attribute24;
  v_rec.roots(125) := p_failed_item.num_base_attribute25;
  v_rec.roots(126) := p_failed_item.num_base_attribute26;
  v_rec.roots(127) := p_failed_item.num_base_attribute27;
  v_rec.roots(128) := p_failed_item.num_base_attribute28;
  v_rec.roots(129) := p_failed_item.num_base_attribute29;
  v_rec.roots(130) := p_failed_item.num_base_attribute30;
  v_rec.roots(131) := p_failed_item.num_base_attribute31;
  v_rec.roots(132) := p_failed_item.num_base_attribute32;
  v_rec.roots(133) := p_failed_item.num_base_attribute33;
  v_rec.roots(134) := p_failed_item.num_base_attribute34;
  v_rec.roots(135) := p_failed_item.num_base_attribute35;
  v_rec.roots(136) := p_failed_item.num_base_attribute36;
  v_rec.roots(137) := p_failed_item.num_base_attribute37;
  v_rec.roots(138) := p_failed_item.num_base_attribute38;
  v_rec.roots(139) := p_failed_item.num_base_attribute39;
  v_rec.roots(140) := p_failed_item.num_base_attribute40;
  v_rec.roots(141) := p_failed_item.num_base_attribute41;
  v_rec.roots(142) := p_failed_item.num_base_attribute42;
  v_rec.roots(143) := p_failed_item.num_base_attribute43;
  v_rec.roots(144) := p_failed_item.num_base_attribute44;
  v_rec.roots(145) := p_failed_item.num_base_attribute45;
  v_rec.roots(146) := p_failed_item.num_base_attribute46;
  v_rec.roots(147) := p_failed_item.num_base_attribute47;
  v_rec.roots(148) := p_failed_item.num_base_attribute48;
  v_rec.roots(149) := p_failed_item.num_base_attribute49;
  v_rec.roots(150) := p_failed_item.num_base_attribute50;
  v_rec.roots(151) := p_failed_item.num_base_attribute51;
  v_rec.roots(152) := p_failed_item.num_base_attribute52;
  v_rec.roots(153) := p_failed_item.num_base_attribute53;
  v_rec.roots(154) := p_failed_item.num_base_attribute54;
  v_rec.roots(155) := p_failed_item.num_base_attribute55;
  v_rec.roots(156) := p_failed_item.num_base_attribute56;
  v_rec.roots(157) := p_failed_item.num_base_attribute57;
  v_rec.roots(158) := p_failed_item.num_base_attribute58;
  v_rec.roots(159) := p_failed_item.num_base_attribute59;
  v_rec.roots(160) := p_failed_item.num_base_attribute60;
  v_rec.roots(161) := p_failed_item.num_base_attribute61;
  v_rec.roots(162) := p_failed_item.num_base_attribute62;
  v_rec.roots(163) := p_failed_item.num_base_attribute63;
  v_rec.roots(164) := p_failed_item.num_base_attribute64;
  v_rec.roots(165) := p_failed_item.num_base_attribute65;
  v_rec.roots(166) := p_failed_item.num_base_attribute66;
  v_rec.roots(167) := p_failed_item.num_base_attribute67;
  v_rec.roots(168) := p_failed_item.num_base_attribute68;
  v_rec.roots(169) := p_failed_item.num_base_attribute69;
  v_rec.roots(170) := p_failed_item.num_base_attribute70;
  v_rec.roots(171) := p_failed_item.num_base_attribute71;
  v_rec.roots(172) := p_failed_item.num_base_attribute72;
  v_rec.roots(173) := p_failed_item.num_base_attribute73;
  v_rec.roots(174) := p_failed_item.num_base_attribute74;
  v_rec.roots(175) := p_failed_item.num_base_attribute75;
  v_rec.roots(176) := p_failed_item.num_base_attribute76;
  v_rec.roots(177) := p_failed_item.num_base_attribute77;
  v_rec.roots(178) := p_failed_item.num_base_attribute78;
  v_rec.roots(179) := p_failed_item.num_base_attribute79;
  v_rec.roots(180) := p_failed_item.num_base_attribute80;
  v_rec.roots(181) := p_failed_item.num_base_attribute81;
  v_rec.roots(182) := p_failed_item.num_base_attribute82;
  v_rec.roots(183) := p_failed_item.num_base_attribute83;
  v_rec.roots(184) := p_failed_item.num_base_attribute84;
  v_rec.roots(185) := p_failed_item.num_base_attribute85;
  v_rec.roots(186) := p_failed_item.num_base_attribute86;
  v_rec.roots(187) := p_failed_item.num_base_attribute87;
  v_rec.roots(188) := p_failed_item.num_base_attribute88;
  v_rec.roots(189) := p_failed_item.num_base_attribute89;
  v_rec.roots(190) := p_failed_item.num_base_attribute90;
  v_rec.roots(191) := p_failed_item.num_base_attribute91;
  v_rec.roots(192) := p_failed_item.num_base_attribute92;
  v_rec.roots(193) := p_failed_item.num_base_attribute93;
  v_rec.roots(194) := p_failed_item.num_base_attribute94;
  v_rec.roots(195) := p_failed_item.num_base_attribute95;
  v_rec.roots(196) := p_failed_item.num_base_attribute96;
  v_rec.roots(197) := p_failed_item.num_base_attribute97;
  v_rec.roots(198) := p_failed_item.num_base_attribute98;
  v_rec.roots(199) := p_failed_item.num_base_attribute99;
  v_rec.roots(200) := p_failed_item.num_base_attribute100;
  v_rec.roots(201) := p_failed_item.tl_text_base_attribute1;
  v_rec.roots(202) := p_failed_item.tl_text_base_attribute2;
  v_rec.roots(203) := p_failed_item.tl_text_base_attribute3;
  v_rec.roots(204) := p_failed_item.tl_text_base_attribute4;
  v_rec.roots(205) := p_failed_item.tl_text_base_attribute5;
  v_rec.roots(206) := p_failed_item.tl_text_base_attribute6;
  v_rec.roots(207) := p_failed_item.tl_text_base_attribute7;
  v_rec.roots(208) := p_failed_item.tl_text_base_attribute8;
  v_rec.roots(209) := p_failed_item.tl_text_base_attribute9;
  v_rec.roots(210) := p_failed_item.tl_text_base_attribute10;
  v_rec.roots(211) := p_failed_item.tl_text_base_attribute11;
  v_rec.roots(212) := p_failed_item.tl_text_base_attribute12;
  v_rec.roots(213) := p_failed_item.tl_text_base_attribute13;
  v_rec.roots(214) := p_failed_item.tl_text_base_attribute14;
  v_rec.roots(215) := p_failed_item.tl_text_base_attribute15;
  v_rec.roots(216) := p_failed_item.tl_text_base_attribute16;
  v_rec.roots(217) := p_failed_item.tl_text_base_attribute17;
  v_rec.roots(218) := p_failed_item.tl_text_base_attribute18;
  v_rec.roots(219) := p_failed_item.tl_text_base_attribute19;
  v_rec.roots(220) := p_failed_item.tl_text_base_attribute20;
  v_rec.roots(221) := p_failed_item.tl_text_base_attribute21;
  v_rec.roots(222) := p_failed_item.tl_text_base_attribute22;
  v_rec.roots(223) := p_failed_item.tl_text_base_attribute23;
  v_rec.roots(224) := p_failed_item.tl_text_base_attribute24;
  v_rec.roots(225) := p_failed_item.tl_text_base_attribute25;
  v_rec.roots(226) := p_failed_item.tl_text_base_attribute26;
  v_rec.roots(227) := p_failed_item.tl_text_base_attribute27;
  v_rec.roots(228) := p_failed_item.tl_text_base_attribute28;
  v_rec.roots(229) := p_failed_item.tl_text_base_attribute29;
  v_rec.roots(230) := p_failed_item.tl_text_base_attribute30;
  v_rec.roots(231) := p_failed_item.tl_text_base_attribute31;
  v_rec.roots(232) := p_failed_item.tl_text_base_attribute32;
  v_rec.roots(233) := p_failed_item.tl_text_base_attribute33;
  v_rec.roots(234) := p_failed_item.tl_text_base_attribute34;
  v_rec.roots(235) := p_failed_item.tl_text_base_attribute35;
  v_rec.roots(236) := p_failed_item.tl_text_base_attribute36;
  v_rec.roots(237) := p_failed_item.tl_text_base_attribute37;
  v_rec.roots(238) := p_failed_item.tl_text_base_attribute38;
  v_rec.roots(239) := p_failed_item.tl_text_base_attribute39;
  v_rec.roots(240) := p_failed_item.tl_text_base_attribute40;
  v_rec.roots(241) := p_failed_item.tl_text_base_attribute41;
  v_rec.roots(242) := p_failed_item.tl_text_base_attribute42;
  v_rec.roots(243) := p_failed_item.tl_text_base_attribute43;
  v_rec.roots(244) := p_failed_item.tl_text_base_attribute44;
  v_rec.roots(245) := p_failed_item.tl_text_base_attribute45;
  v_rec.roots(246) := p_failed_item.tl_text_base_attribute46;
  v_rec.roots(247) := p_failed_item.tl_text_base_attribute47;
  v_rec.roots(248) := p_failed_item.tl_text_base_attribute48;
  v_rec.roots(249) := p_failed_item.tl_text_base_attribute49;
  v_rec.roots(250) := p_failed_item.tl_text_base_attribute50;
  v_rec.roots(251) := p_failed_item.tl_text_base_attribute51;
  v_rec.roots(252) := p_failed_item.tl_text_base_attribute52;
  v_rec.roots(253) := p_failed_item.tl_text_base_attribute53;
  v_rec.roots(254) := p_failed_item.tl_text_base_attribute54;
  v_rec.roots(255) := p_failed_item.tl_text_base_attribute55;
  v_rec.roots(256) := p_failed_item.tl_text_base_attribute56;
  v_rec.roots(257) := p_failed_item.tl_text_base_attribute57;
  v_rec.roots(258) := p_failed_item.tl_text_base_attribute58;
  v_rec.roots(259) := p_failed_item.tl_text_base_attribute59;
  v_rec.roots(260) := p_failed_item.tl_text_base_attribute60;
  v_rec.roots(261) := p_failed_item.tl_text_base_attribute61;
  v_rec.roots(262) := p_failed_item.tl_text_base_attribute62;
  v_rec.roots(263) := p_failed_item.tl_text_base_attribute63;
  v_rec.roots(264) := p_failed_item.tl_text_base_attribute64;
  v_rec.roots(265) := p_failed_item.tl_text_base_attribute65;
  v_rec.roots(266) := p_failed_item.tl_text_base_attribute66;
  v_rec.roots(267) := p_failed_item.tl_text_base_attribute67;
  v_rec.roots(268) := p_failed_item.tl_text_base_attribute68;
  v_rec.roots(269) := p_failed_item.tl_text_base_attribute69;
  v_rec.roots(270) := p_failed_item.tl_text_base_attribute70;
  v_rec.roots(271) := p_failed_item.tl_text_base_attribute71;
  v_rec.roots(272) := p_failed_item.tl_text_base_attribute72;
  v_rec.roots(273) := p_failed_item.tl_text_base_attribute73;
  v_rec.roots(274) := p_failed_item.tl_text_base_attribute74;
  v_rec.roots(275) := p_failed_item.tl_text_base_attribute75;
  v_rec.roots(276) := p_failed_item.tl_text_base_attribute76;
  v_rec.roots(277) := p_failed_item.tl_text_base_attribute77;
  v_rec.roots(278) := p_failed_item.tl_text_base_attribute78;
  v_rec.roots(279) := p_failed_item.tl_text_base_attribute79;
  v_rec.roots(280) := p_failed_item.tl_text_base_attribute80;
  v_rec.roots(281) := p_failed_item.tl_text_base_attribute81;
  v_rec.roots(282) := p_failed_item.tl_text_base_attribute82;
  v_rec.roots(283) := p_failed_item.tl_text_base_attribute83;
  v_rec.roots(284) := p_failed_item.tl_text_base_attribute84;
  v_rec.roots(285) := p_failed_item.tl_text_base_attribute85;
  v_rec.roots(286) := p_failed_item.tl_text_base_attribute86;
  v_rec.roots(287) := p_failed_item.tl_text_base_attribute87;
  v_rec.roots(288) := p_failed_item.tl_text_base_attribute88;
  v_rec.roots(289) := p_failed_item.tl_text_base_attribute89;
  v_rec.roots(290) := p_failed_item.tl_text_base_attribute90;
  v_rec.roots(291) := p_failed_item.tl_text_base_attribute91;
  v_rec.roots(292) := p_failed_item.tl_text_base_attribute92;
  v_rec.roots(293) := p_failed_item.tl_text_base_attribute93;
  v_rec.roots(294) := p_failed_item.tl_text_base_attribute94;
  v_rec.roots(295) := p_failed_item.tl_text_base_attribute95;
  v_rec.roots(296) := p_failed_item.tl_text_base_attribute96;
  v_rec.roots(297) := p_failed_item.tl_text_base_attribute97;
  v_rec.roots(298) := p_failed_item.tl_text_base_attribute98;
  v_rec.roots(299) := p_failed_item.tl_text_base_attribute99;
  v_rec.roots(300) := p_failed_item.tl_text_base_attribute100;
  v_rec.locals(1) := p_failed_item.text_cat_attribute1;
  v_rec.locals(2) := p_failed_item.text_cat_attribute2;
  v_rec.locals(3) := p_failed_item.text_cat_attribute3;
  v_rec.locals(4) := p_failed_item.text_cat_attribute4;
  v_rec.locals(5) := p_failed_item.text_cat_attribute5;
  v_rec.locals(6) := p_failed_item.text_cat_attribute6;
  v_rec.locals(7) := p_failed_item.text_cat_attribute7;
  v_rec.locals(8) := p_failed_item.text_cat_attribute8;
  v_rec.locals(9) := p_failed_item.text_cat_attribute9;
  v_rec.locals(10) := p_failed_item.text_cat_attribute10;
  v_rec.locals(11) := p_failed_item.text_cat_attribute11;
  v_rec.locals(12) := p_failed_item.text_cat_attribute12;
  v_rec.locals(13) := p_failed_item.text_cat_attribute13;
  v_rec.locals(14) := p_failed_item.text_cat_attribute14;
  v_rec.locals(15) := p_failed_item.text_cat_attribute15;
  v_rec.locals(16) := p_failed_item.text_cat_attribute16;
  v_rec.locals(17) := p_failed_item.text_cat_attribute17;
  v_rec.locals(18) := p_failed_item.text_cat_attribute18;
  v_rec.locals(19) := p_failed_item.text_cat_attribute19;
  v_rec.locals(20) := p_failed_item.text_cat_attribute20;
  v_rec.locals(21) := p_failed_item.text_cat_attribute21;
  v_rec.locals(22) := p_failed_item.text_cat_attribute22;
  v_rec.locals(23) := p_failed_item.text_cat_attribute23;
  v_rec.locals(24) := p_failed_item.text_cat_attribute24;
  v_rec.locals(25) := p_failed_item.text_cat_attribute25;
  v_rec.locals(26) := p_failed_item.text_cat_attribute26;
  v_rec.locals(27) := p_failed_item.text_cat_attribute27;
  v_rec.locals(28) := p_failed_item.text_cat_attribute28;
  v_rec.locals(29) := p_failed_item.text_cat_attribute29;
  v_rec.locals(30) := p_failed_item.text_cat_attribute30;
  v_rec.locals(31) := p_failed_item.text_cat_attribute31;
  v_rec.locals(32) := p_failed_item.text_cat_attribute32;
  v_rec.locals(33) := p_failed_item.text_cat_attribute33;
  v_rec.locals(34) := p_failed_item.text_cat_attribute34;
  v_rec.locals(35) := p_failed_item.text_cat_attribute35;
  v_rec.locals(36) := p_failed_item.text_cat_attribute36;
  v_rec.locals(37) := p_failed_item.text_cat_attribute37;
  v_rec.locals(38) := p_failed_item.text_cat_attribute38;
  v_rec.locals(39) := p_failed_item.text_cat_attribute39;
  v_rec.locals(40) := p_failed_item.text_cat_attribute40;
  v_rec.locals(41) := p_failed_item.text_cat_attribute41;
  v_rec.locals(42) := p_failed_item.text_cat_attribute42;
  v_rec.locals(43) := p_failed_item.text_cat_attribute43;
  v_rec.locals(44) := p_failed_item.text_cat_attribute44;
  v_rec.locals(45) := p_failed_item.text_cat_attribute45;
  v_rec.locals(46) := p_failed_item.text_cat_attribute46;
  v_rec.locals(47) := p_failed_item.text_cat_attribute47;
  v_rec.locals(48) := p_failed_item.text_cat_attribute48;
  v_rec.locals(49) := p_failed_item.text_cat_attribute49;
  v_rec.locals(50) := p_failed_item.text_cat_attribute50;
  --Bug#2785949
  --Removed the to_char function as
  --p_failed_item.num_cat_attribute1..p_failed_item.num_cat_attribute50
  --is already VARCHAR type
  v_rec.locals(51) := p_failed_item.num_cat_attribute1;
  v_rec.locals(52) := p_failed_item.num_cat_attribute2;
  v_rec.locals(53) := p_failed_item.num_cat_attribute3;
  v_rec.locals(54) := p_failed_item.num_cat_attribute4;
  v_rec.locals(55) := p_failed_item.num_cat_attribute5;
  v_rec.locals(56) := p_failed_item.num_cat_attribute6;
  v_rec.locals(57) := p_failed_item.num_cat_attribute7;
  v_rec.locals(58) := p_failed_item.num_cat_attribute8;
  v_rec.locals(59) := p_failed_item.num_cat_attribute9;
  v_rec.locals(60) := p_failed_item.num_cat_attribute10;
  v_rec.locals(61) := p_failed_item.num_cat_attribute11;
  v_rec.locals(62) := p_failed_item.num_cat_attribute12;
  v_rec.locals(63) := p_failed_item.num_cat_attribute13;
  v_rec.locals(64) := p_failed_item.num_cat_attribute14;
  v_rec.locals(65) := p_failed_item.num_cat_attribute15;
  v_rec.locals(66) := p_failed_item.num_cat_attribute16;
  v_rec.locals(67) := p_failed_item.num_cat_attribute17;
  v_rec.locals(68) := p_failed_item.num_cat_attribute18;
  v_rec.locals(69) := p_failed_item.num_cat_attribute19;
  v_rec.locals(70) := p_failed_item.num_cat_attribute20;
  v_rec.locals(71) := p_failed_item.num_cat_attribute21;
  v_rec.locals(72) := p_failed_item.num_cat_attribute22;
  v_rec.locals(73) := p_failed_item.num_cat_attribute23;
  v_rec.locals(74) := p_failed_item.num_cat_attribute24;
  v_rec.locals(75) := p_failed_item.num_cat_attribute25;
  v_rec.locals(76) := p_failed_item.num_cat_attribute26;
  v_rec.locals(77) := p_failed_item.num_cat_attribute27;
  v_rec.locals(78) := p_failed_item.num_cat_attribute28;
  v_rec.locals(79) := p_failed_item.num_cat_attribute29;
  v_rec.locals(80) := p_failed_item.num_cat_attribute30;
  v_rec.locals(81) := p_failed_item.num_cat_attribute31;
  v_rec.locals(82) := p_failed_item.num_cat_attribute32;
  v_rec.locals(83) := p_failed_item.num_cat_attribute33;
  v_rec.locals(84) := p_failed_item.num_cat_attribute34;
  v_rec.locals(85) := p_failed_item.num_cat_attribute35;
  v_rec.locals(86) := p_failed_item.num_cat_attribute36;
  v_rec.locals(87) := p_failed_item.num_cat_attribute37;
  v_rec.locals(88) := p_failed_item.num_cat_attribute38;
  v_rec.locals(89) := p_failed_item.num_cat_attribute39;
  v_rec.locals(90) := p_failed_item.num_cat_attribute40;
  v_rec.locals(91) := p_failed_item.num_cat_attribute41;
  v_rec.locals(92) := p_failed_item.num_cat_attribute42;
  v_rec.locals(93) := p_failed_item.num_cat_attribute43;
  v_rec.locals(94) := p_failed_item.num_cat_attribute44;
  v_rec.locals(95) := p_failed_item.num_cat_attribute45;
  v_rec.locals(96) := p_failed_item.num_cat_attribute46;
  v_rec.locals(97) := p_failed_item.num_cat_attribute47;
  v_rec.locals(98) := p_failed_item.num_cat_attribute48;
  v_rec.locals(99) := p_failed_item.num_cat_attribute49;
  v_rec.locals(100) := p_failed_item.num_cat_attribute50;
  v_rec.locals(101) := p_failed_item.tl_text_cat_attribute1;
  v_rec.locals(102) := p_failed_item.tl_text_cat_attribute2;
  v_rec.locals(103) := p_failed_item.tl_text_cat_attribute3;
  v_rec.locals(104) := p_failed_item.tl_text_cat_attribute4;
  v_rec.locals(105) := p_failed_item.tl_text_cat_attribute5;
  v_rec.locals(106) := p_failed_item.tl_text_cat_attribute6;
  v_rec.locals(107) := p_failed_item.tl_text_cat_attribute7;
  v_rec.locals(108) := p_failed_item.tl_text_cat_attribute8;
  v_rec.locals(109) := p_failed_item.tl_text_cat_attribute9;
  v_rec.locals(110) := p_failed_item.tl_text_cat_attribute10;
  v_rec.locals(111) := p_failed_item.tl_text_cat_attribute11;
  v_rec.locals(112) := p_failed_item.tl_text_cat_attribute12;
  v_rec.locals(113) := p_failed_item.tl_text_cat_attribute13;
  v_rec.locals(114) := p_failed_item.tl_text_cat_attribute14;
  v_rec.locals(115) := p_failed_item.tl_text_cat_attribute15;
  v_rec.locals(116) := p_failed_item.tl_text_cat_attribute16;
  v_rec.locals(117) := p_failed_item.tl_text_cat_attribute17;
  v_rec.locals(118) := p_failed_item.tl_text_cat_attribute18;
  v_rec.locals(119) := p_failed_item.tl_text_cat_attribute19;
  v_rec.locals(120) := p_failed_item.tl_text_cat_attribute20;
  v_rec.locals(121) := p_failed_item.tl_text_cat_attribute21;
  v_rec.locals(122) := p_failed_item.tl_text_cat_attribute22;
  v_rec.locals(123) := p_failed_item.tl_text_cat_attribute23;
  v_rec.locals(124) := p_failed_item.tl_text_cat_attribute24;
  v_rec.locals(125) := p_failed_item.tl_text_cat_attribute25;
  v_rec.locals(126) := p_failed_item.tl_text_cat_attribute26;
  v_rec.locals(127) := p_failed_item.tl_text_cat_attribute27;
  v_rec.locals(128) := p_failed_item.tl_text_cat_attribute28;
  v_rec.locals(129) := p_failed_item.tl_text_cat_attribute29;
  v_rec.locals(130) := p_failed_item.tl_text_cat_attribute30;
  v_rec.locals(131) := p_failed_item.tl_text_cat_attribute31;
  v_rec.locals(132) := p_failed_item.tl_text_cat_attribute32;
  v_rec.locals(133) := p_failed_item.tl_text_cat_attribute33;
  v_rec.locals(134) := p_failed_item.tl_text_cat_attribute34;
  v_rec.locals(135) := p_failed_item.tl_text_cat_attribute35;
  v_rec.locals(136) := p_failed_item.tl_text_cat_attribute36;
  v_rec.locals(137) := p_failed_item.tl_text_cat_attribute37;
  v_rec.locals(138) := p_failed_item.tl_text_cat_attribute38;
  v_rec.locals(139) := p_failed_item.tl_text_cat_attribute39;
  v_rec.locals(140) := p_failed_item.tl_text_cat_attribute40;
  v_rec.locals(141) := p_failed_item.tl_text_cat_attribute41;
  v_rec.locals(142) := p_failed_item.tl_text_cat_attribute42;
  v_rec.locals(143) := p_failed_item.tl_text_cat_attribute43;
  v_rec.locals(144) := p_failed_item.tl_text_cat_attribute44;
  v_rec.locals(145) := p_failed_item.tl_text_cat_attribute45;
  v_rec.locals(146) := p_failed_item.tl_text_cat_attribute46;
  v_rec.locals(147) := p_failed_item.tl_text_cat_attribute47;
  v_rec.locals(148) := p_failed_item.tl_text_cat_attribute48;
  v_rec.locals(149) := p_failed_item.tl_text_cat_attribute49;
  v_rec.locals(150) := p_failed_item.tl_text_cat_attribute50;
  v_rec.unit_price              := p_failed_item.unit_price;
  v_rec.currency                := p_failed_item.currency;
  v_rec.unit_of_measure         := p_failed_item.unit_of_measure;
  v_rec.supplier_site_id        := p_failed_item.supplier_site_id;
  v_rec.supplier_site_code      := p_failed_item.supplier_site_code;
  v_rec.price_list_name         := p_failed_item.price_list_name;
  v_rec.price_list_id           := p_failed_item.price_list_id;
  v_rec.buyer_name              := p_failed_item.buyer_name;
  v_rec.LAST_UPDATE_LOGIN       := p_failed_item.LAST_UPDATE_LOGIN;
  v_rec.LAST_UPDATED_BY         := p_failed_item.LAST_UPDATED_BY;
  v_rec.LAST_UPDATE_DATE        := p_failed_item.LAST_UPDATE_DATE;
  v_rec.CREATED_BY              := p_failed_item.CREATED_BY;
  v_rec.CREATION_DATE           := p_failed_item.CREATION_DATE;

  -- Insert root descriptors
  xErrLoc := 200;

  --Bug#3396442
  FOR root_desc IN custom_non_price_desc_cr(0) LOOP
    --Check section_tag - 1000 to find the value of that particular descriptor value
    v_section_tag := root_desc.section_tag-1000;
    IF (v_rec.roots(v_section_tag) IS NOT NULL) THEN
      xErrLoc := 200;

      insert into icx_por_failed_lines
      (job_number, line_number, action,
       row_type, descriptor_key, descriptor_value)
      values
      (gJobNumber, v_rec.line_number, v_rec.system_action,
       v_rec.row_type, root_desc.key, v_rec.roots(v_section_tag));
    END IF;
  END LOOP;

  -- Insert category key
  xErrLoc := 300;

  IF (v_rec.category_name IS NOT NULL) THEN
    vDescKey := 'CATEGORY_NAME';

    insert into icx_por_failed_lines
    (job_number, line_number, action,
     row_type, descriptor_key, descriptor_value)
    values
    (gJobNumber, v_rec.line_number, v_rec.system_action,
     v_rec.row_type, vDescKey, v_rec.category_name);
  END IF;

  -- Process category attributes
  IF (v_rec.rt_category_id IS NOT NULL) THEN
    xErrLoc := 400;

    fetch_local_descriptors(v_rec.rt_category_id);

    xErrLoc := 410;

    FOR i IN 1..gErrorCatDescKeys.COUNT loop

      IF (v_rec.locals(i) IS NOT NULL) THEN
        insert into icx_por_failed_lines
        (job_number, line_number, action,
         row_type, descriptor_key, descriptor_value)
        values
        (gJobNumber, v_rec.line_number, v_rec.system_action,
         v_rec.row_type, gErrorCatDescKeys(i), v_rec.locals(i));
      END IF;

    END LOOP;

  END IF;

  --Bug#2729328
  -- Insert price columns
  IF ( v_rec.row_type in ('ITEM_PRICE')  OR
     ( v_rec.row_type in ('ITEM') AND v_rec.system_action = 'ADD')) THEN
    xErrLoc := 500;

    -- can only have price (numeric) or price code
    -- so either this code sets the price(numeric)
    -- or the code at the end sets the price code
--    IF (v_rec.unit_price IS NOT NULL) THEN
      vDescKey := 'PRICE';

      insert into icx_por_failed_lines
      (job_number, line_number, action,
       row_type, descriptor_key, descriptor_value)
      values
      (gJobNumber, v_rec.line_number, v_rec.system_action,
       v_rec.row_type, vDescKey, v_rec.unit_price);
--    END IF;

    xErrLoc := 510;

--    IF (v_rec.currency IS NOT NULL) THEN
      vDescKey := 'CURRENCY';

      insert into icx_por_failed_lines
      (job_number, line_number, action,
       row_type, descriptor_key, descriptor_value)
      values
      (gJobNumber, v_rec.line_number, v_rec.system_action,
       v_rec.row_type, vDescKey, v_rec.currency);
--    END IF;

    xErrLoc := 520;

--    IF (v_rec.unit_of_measure IS NOT NULL) THEN
      vDescKey := 'UOM';

      insert into icx_por_failed_lines
      (job_number, line_number, action,
       row_type, descriptor_key, descriptor_value)
      values
      (gJobNumber, v_rec.line_number, v_rec.system_action,
       v_rec.row_type, vDescKey, v_rec.unit_of_measure);
--    END IF;

    xErrLoc := 530;
--    IF (v_rec.buyer_name IS NOT NULL) THEN
      vDescKey := 'BUYER';

      insert into icx_por_failed_lines
      (job_number, line_number, action,
       row_type, descriptor_key, descriptor_value)
      values
      (gJobNumber, v_rec.line_number, v_rec.system_action,
       v_rec.row_type, vDescKey, v_rec.buyer_name);
--    END IF;

    xErrLoc := 540;

--    IF (v_rec.price_list_name IS NOT NULL) THEN
      vDescKey := 'PRICELIST';

      insert into icx_por_failed_lines
      (job_number, line_number, action,
       row_type, descriptor_key, descriptor_value)
      values
      (gJobNumber, v_rec.line_number, v_rec.system_action,
       v_rec.row_type, vDescKey, v_rec.price_list_name);
--    END IF;

    xErrLoc := 550;

    --Bug#2729328
--    IF (v_rec.supplier IS NOT NULL) THEN
      vDescKey := 'SUPPLIER';

      insert into icx_por_failed_lines
      (job_number, line_number, action,
       row_type, descriptor_key, descriptor_value)
      values
      (gJobNumber, v_rec.line_number, v_rec.system_action,
       v_rec.row_type, vDescKey, v_rec.supplier);
--    END IF;

    xErrLoc := 560;

--    IF (v_rec.supplier_part_num IS NOT NULL) THEN
      vDescKey := 'SUPPLIER_PART_NUM';

      insert into icx_por_failed_lines
      (job_number, line_number, action,
       row_type, descriptor_key, descriptor_value)
      values
      (gJobNumber, v_rec.line_number, v_rec.system_action,
       v_rec.row_type, vDescKey, v_rec.supplier_part_num);
--    END IF;

    xErrLoc := 570;

    --Bug#2709997
--    IF (v_rec.supplier_site_code IS NOT NULL) THEN
      vDescKey := 'SUPPLIER_SITE';

      insert into icx_por_failed_lines
      (job_number, line_number, action,
       row_type, descriptor_key, descriptor_value)
      values
      (gJobNumber, v_rec.line_number, v_rec.system_action,
       v_rec.row_type, vDescKey, v_rec.supplier_site_code);
--    END IF;

    xErrLoc := 580;

--    IF (v_rec.supplier_part_auxid IS NOT NULL) THEN
      vDescKey := 'SUPPLIER_PART_AUXID';

      insert into icx_por_failed_lines
      (job_number, line_number, action,
       row_type, descriptor_key, descriptor_value)
      values
      (gJobNumber, v_rec.line_number, v_rec.system_action,
       v_rec.row_type, vDescKey, v_rec.supplier_part_auxid);
--    END IF;

    xErrLoc := 590;

    --Bug#2729328
    --For an item txt file with no supplier_part_num specified,
    --description not getting logged into icx_por_failed_lines
    IF (v_rec.description IS NOT NULL) THEN
      vDescKey := 'DESCRIPTION';

      insert into icx_por_failed_lines
      (job_number, line_number, action,
       row_type, descriptor_key, descriptor_value)
      values
      (gJobNumber, v_rec.line_number, v_rec.system_action,
       v_rec.row_type, vDescKey, v_rec.description);
    END IF;

    xErrLoc := 600;
/*
    save_failed_price_break(gJobNumber, v_rec.line_number,
      v_rec.system_action, v_rec.row_type, v_rec.price_break_count);
*/
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.save_failed_item('
      || xErrLoc || '): ' || SQLERRM);
END save_failed_item;

/* Saves a failed price */
PROCEDURE save_failed_price(pJobNumber IN NUMBER,
  p_line IN tITPriceRecord) IS
  xErrLoc PLS_INTEGER;
  vDescKey ICX_POR_FAILED_LINES.DESCRIPTOR_KEY%TYPE;
  vRowType VARCHAR2(30) := 'PRICE';
BEGIN
  xErrLoc := 100;

  --if (p_line.supplier_name is not null) then
    vDescKey := 'SUPPLIER';

    insert into icx_por_failed_lines
    (job_number, line_number, action,
     row_type, descriptor_key, descriptor_value)
    values
    (gJobNumber, p_line.line_number, p_line.system_action,
     vRowType, vDescKey, p_line.supplier_name);
  --end if;

  xErrLoc := 110;

  --if (p_line.supplier_part_num is not null) then
    vDescKey := 'SUPPLIER_PART_NUM';

    insert into icx_por_failed_lines
    (job_number, line_number, action,
     row_type, descriptor_key, descriptor_value)
    values
    (gJobNumber, p_line.line_number, p_line.system_action,
     vRowType, vDescKey, p_line.supplier_part_num);
  --end if;

  xErrLoc := 115;

  --Bug#2611529
  --if (p_line.supplier_part_auxid is not null) then
    vDescKey := 'SUPPLIER_PART_AUXID';

    insert into icx_por_failed_lines
    (job_number, line_number, action,
     row_type, descriptor_key, descriptor_value)
    values
    (gJobNumber, p_line.line_number, p_line.system_action,
     vRowType, vDescKey, p_line.supplier_part_auxid);
  --end if;

  xErrLoc := 120;

  --Bug#2709997
  --if (p_line.supplier_site_code is not null) then
    vDescKey := 'SUPPLIER_SITE';

    insert into icx_por_failed_lines
    (job_number, line_number, action,
     row_type, descriptor_key, descriptor_value)
    values
    (gJobNumber, p_line.line_number, p_line.system_action,
     vRowType, vDescKey, p_line.supplier_site_code);
  --end if;

  xErrLoc := 125;

  -- can only have price (numeric) or price code
  -- so either this code sets the price(numeric)
  -- or the code at the end sets the price code
  --if (p_line.unit_price is not null) then
    vDescKey := 'PRICE';

    insert into icx_por_failed_lines
    (job_number, line_number, action,
     row_type, descriptor_key, descriptor_value)
    values
    (gJobNumber, p_line.line_number, p_line.system_action,
     vRowType, vDescKey, p_line.unit_price);
  --end if;

  xErrLoc := 130;

  --if (p_line.currency is not null) then
    vDescKey := 'CURRENCY';

    insert into icx_por_failed_lines
    (job_number, line_number, action,
     row_type, descriptor_key, descriptor_value)
    values
    (gJobNumber, p_line.line_number, p_line.system_action,
     vRowType, vDescKey, p_line.currency);
  --end if;

  xErrLoc := 140;

  --if (p_line.unit_of_measure is not null) then
    vDescKey := 'UOM';

    insert into icx_por_failed_lines
    (job_number, line_number, action,
     row_type, descriptor_key, descriptor_value)
    values
    (gJobNumber, p_line.line_number, p_line.system_action,
     vRowType, vDescKey, p_line.unit_of_measure);
  --end if;

  xErrLoc := 150;

  --if (p_line.buyer_name is not null) then
    vDescKey := 'BUYER';

    insert into icx_por_failed_lines
    (job_number, line_number, action,
     row_type, descriptor_key, descriptor_value)
    values
    (gJobNumber, p_line.line_number, p_line.system_action,
     vRowType, vDescKey, p_line.buyer_name);
  --end if;

  xErrLoc := 160;

  --if (p_line.price_list_name is not null) then
    vDescKey := 'PRICELIST';

    insert into icx_por_failed_lines
    (job_number, line_number, action,
     row_type, descriptor_key, descriptor_value)
    values
    (gJobNumber, p_line.line_number, p_line.system_action,
     vRowType, vDescKey, p_line.price_list_name);
  --end if;

  xErrLoc := 170;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20000,
        'Exception at ICX_POR_ITEM_UPLOAD.save_failed_price('
        || xErrLoc || '): ' || SQLERRM);
END save_failed_price;

/** Proc : save_required_descriptor_errors
 ** Desc : Saves the error messages related to missing values for
 **        required descriptors
 **/
PROCEDURE save_required_desc_errors(p_request_id IN NUMBER,
p_line_number IN NUMBER, p_desc_names IN VARCHAR2) IS
vBreakPos PLS_INTEGER := 1;
vStartPos PLS_INTEGER := 1;
vDescName ICX_CAT_DESCRIPTORS_TL.KEY%TYPE;
BEGIN
  IF (p_desc_names IS NULL) THEN
    RETURN;
  END IF;

  LOOP
    vBreakPos := INSTR(p_desc_names, '`', vStartPos);

    IF (vBreakPos = 0) THEN
      EXIT;
    END IF;

    vDescName := SUBSTR(p_desc_names, vStartPos, vBreakPos - vStartPos);

    INSERT INTO icx_por_failed_line_messages
      (job_number, line_number, descriptor_key, message_name)
    VALUES
      (p_request_id, p_line_number, vDescName, 'ICX_POR_CAT_FIELD_REQUIRED');

    vStartPos := vBreakPos + 1;
  END LOOP;

END save_required_desc_errors;

/* Processes failed prices in the current batch */
PROCEDURE process_batch_price_errors(pErrorRowids IN
  dbms_sql.urowid_table) IS
  i PLS_INTEGER;
  CURSOR get_failed_price(p_rowid IN VARCHAR2) IS
    SELECT line_number, decode(action, 'SYNC','ADD',action) system_action,
    supplier, supplier_part_num, supplier_part_auxid, --Bug#2611529
    supplier_site_code, --Bug#
    --Bug#2785949
    --Removed the to_char function as
    --unit_price in ICX_CAT_PRICES_GT is already VARCHAR type
    unit_price, currency, unit_of_measure,
    buyer_name, price_list_name,
    error_message, error_flag
    FROM ICX_CAT_PRICES_GT
    WHERE rowid = p_rowid;
  v_rec tITPriceRecord;
  xErrLoc PLS_INTEGER := 100;
BEGIN

  FOR i IN 1..pErrorRowids.COUNT LOOP
    xErrLoc := 200;

    OPEN get_failed_price(pErrorRowids(i));
    FETCH get_failed_price INTO v_rec;

    IF (NOT get_failed_price%NOTFOUND) THEN
      xErrLoc := 300;

      IF (v_rec.error_message IS NOT NULL) THEN
        xErrLoc := 400;
        save_failed_line_message(gJobNumber, v_rec.line_number,
          v_rec.error_message);
      END IF;

      IF (v_rec.error_flag IS NULL) THEN
        xErrLoc := 500;
        save_failed_price(gJobNumber, v_rec);
      ELSIF (v_rec.error_flag = 'Y') THEN
        xErrLoc := 510;

        UPDATE icx_por_failed_lines SET action = v_rec.system_action
        WHERE job_number = gJobNumber
        AND line_number = v_rec.line_number;
      END IF;

    END IF;

    CLOSE get_failed_price;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.process_batch_price_errors('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_price_errors;

/* Processes failed items in the current batch */
PROCEDURE process_batch_item_errors(pErrorRowids IN
  dbms_sql.urowid_table) IS
  i PLS_INTEGER;
  CURSOR get_failed_line(p_rowid IN VARCHAR2) IS
    SELECT * FROM ICX_CAT_ITEMS_GT
    WHERE rowid = p_rowid;
  v_rec ICX_CAT_ITEMS_GT%ROWTYPE;
  xErrLoc PLS_INTEGER := 100;
BEGIN

  FOR i IN 1..pErrorRowids.COUNT LOOP
    xErrLoc := 200;

    OPEN get_failed_line(pErrorRowids(i));
    FETCH get_failed_line INTO v_rec;

    IF (NOT get_failed_line%NOTFOUND) THEN

      IF (v_rec.system_action = 'ADD') THEN
        save_required_desc_errors(gJobNumber, v_rec.line_number,
          v_rec.required_descriptors);
        save_required_desc_errors(gJobNumber, v_rec.line_number,
          v_rec.required_tl_descriptors);
      ELSIF (v_rec.system_action = 'TRANSLATE') THEN
        save_required_desc_errors(gJobNumber, v_rec.line_number,
          v_rec.required_tl_descriptors);
      END IF;

      IF (v_rec.error_message IS NOT NULL) THEN
        xErrLoc := 300;
        save_failed_line_message(gJobNumber, v_rec.line_number,
          v_rec.error_message);
      END IF;

      IF (v_rec.error_flag IS NULL) THEN
        xErrLoc := 400;
        save_failed_item(gJobNumber, v_rec);
      ELSIF (v_rec.error_flag = 'Y') THEN
        xErrLoc := 410;

        UPDATE icx_por_failed_lines SET action = v_rec.system_action
        WHERE job_number = gJobNumber
        AND line_number = v_rec.line_number;
      END IF;

    END IF;

    CLOSE get_failed_line;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.process_batch_item_errors('
      || xErrLoc || '): ' || SQLERRM);
END process_batch_item_errors;

/* Saves the error message for duplicate lines */
PROCEDURE reject_line(p_row_id IN UROWID, p_row_type IN VARCHAR2,
  p_error_message IN VARCHAR2) IS

BEGIN
  IF (p_row_type = 'ITEM') THEN
    UPDATE ICX_CAT_ITEMS_GT SET error_message = error_message ||
      p_error_message
    WHERE rowid = p_row_id;
  ELSE
    UPDATE ICX_CAT_PRICES_GT SET error_message = error_message ||
      p_error_message
    WHERE rowid = p_row_id;
  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.reject_line: ' || SQLERRM);
END reject_line;

/* Fail the duplicate prices.  This needs to be done before processing
   prices since we want to avoid sorting every time. */
PROCEDURE reject_duplicate_prices IS
--Bug#2611529
  CURSOR it_table_csr IS
     SELECT it.rowid, it.supplier,
       it.supplier_part_num, it.supplier_part_auxid, it.org_id,
       it.supplier_site_id, it.currency
     FROM ICX_CAT_PRICES_GT it
     ORDER BY it.supplier asc, it.supplier_part_num asc,
       it.supplier_part_auxid asc,
       it.org_id asc, it.currency asc, it.supplier_site_id asc,
       it.line_number desc;

  vRowids dbms_sql.urowid_table;
  vSupplierPartNums dbms_sql.varchar2_table;
  vSupplierPartAuxids dbms_sql.varchar2_table; --Bug#2611529
  vSupplierNames dbms_sql.varchar2_table; --Bug#2611529
  vCurrencies dbms_sql.varchar2_table;
  vOrgIds dbms_sql.number_table;
  vSupplierSiteIds dbms_sql.number_table;

  vPrevPartNum VARCHAR2(2000) := null;
  vPrevPartAuxid VARCHAR2(2000) := null; --Bug#2611529
  vPrevSupplierName VARCHAR2(2000) := null; --Bug#2611529
  vPrevOrgId NUMBER := -1;
  vPrevCurrency VARCHAR2(30);
  vPrevSupplierSiteId NUMBER := -1;

  xErrLoc PLS_INTEGER := 100;
BEGIN
  OPEN it_table_csr;

  LOOP
    vRowids.DELETE;
    vSupplierPartNums.DELETE;
    vSupplierNames.DELETE; -- Bug#2611529
    vOrgIds.DELETE;
    vSupplierSiteIds.DELETE;
    vCurrencies.DELETE;

    --Bug#2611529
    FETCH it_table_csr BULK COLLECT INTO
      vRowids, vSupplierNames, vSupplierPartNums,
      vSupplierPartAuxids, vOrgIds, vSupplierSiteIds, vCurrencies
    LIMIT BATCH_SIZE;

    EXIT WHEN vRowids.COUNT = 0;

    FOR i IN 1..vRowids.COUNT LOOP

      IF (vSupplierPartNums(i) IS NOT NULL AND
        vSupplierPartAuxids(i) IS NOT NULL AND --Bug#2611529
	vSupplierNames(i) IS NOT NULL AND --Bug#2611529
        vOrgIds(i) IS NOT NULL AND
        vCurrencies(i) IS NOT NULL AND
        vSupplierSiteIds(i) IS NOT NULL) THEN

        IF (vSupplierPartNums(i) = vPrevPartNum AND
          vSupplierPartAuxids(i) = vPrevPartAuxid AND --Bug#2611529
          vSupplierNames(i) = vPrevSupplierName AND --Bug#2611529
          vOrgIds(i) = vPrevOrgId AND
          vCurrencies(i) = vPrevCurrency AND
          vSupplierSiteIds(i) = vPrevSupplierSiteId) THEN
          reject_line(vRowids(i), 'PRICE',
            --ErrMsg'.SUPPLIER_PART_NUM:POM_CATALOG_DUP_PRICE_IN_FILE');
            '.BUYER:ICX_POR_DUP_PRICE_LIST1');
        ELSE
          vPrevPartNum := vSupplierPartNums(i);
          vPrevPartAuxid := vSupplierPartAuxids(i); --Bug#2611529
          vPrevSupplierName := vSupplierNames(i);	 --Bug#2611529
          vPrevOrgId := vOrgIds(i);
          vPrevCurrency := vCurrencies(i);
          vPrevSupplierSiteId := vSupplierSiteIds(i);
        END IF;

      ELSE

        IF (vSupplierPartNums(i) IS NULL) THEN
          reject_line(vRowids(i), 'PRICE',
            '.SUPPLIER_PART_NUM:ICX_POR_CAT_FIELD_REQUIRED');
        END IF;

      END IF;

    END LOOP;

    IF (vRowids.COUNT < BATCH_SIZE) THEN
      EXIT;
    END IF;

  END LOOP;

  CLOSE it_table_csr;

EXCEPTION
  WHEN OTHERS THEN
    IF (it_table_csr%ISOPEN) THEN
      CLOSE it_table_csr;
    END IF;

    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.reject_duplicate_prices('
      || xErrLoc || '): ' || SQLERRM);
END reject_duplicate_prices;


/* Processes the valid prices */
PROCEDURE move_prices(p_succ_line OUT NOCOPY NUMBER, p_failed_line OUT NOCOPY NUMBER,
  p_max_failed_line IN NUMBER) IS
  -- ItemUniqueness: Changes in any Pricing related uniqueness rules
  --                should be implemented in the below sql
  --                make sure the g_ plsql table is populated fine
  CURSOR it_table_csr IS
    SELECT /*+ USE_NL(it i ui) LEADING(it) */ it.rowid,
      --DUPE FAILED LINES Contract Auto Sourcing
      it.line_number,
      it.supplier_id,
      decode(it.contract_num, null, 'BULKLOAD', 'CONTRACT'),
      it.supplier_part_num,
      i.rt_item_id,
      decode(i.extractor_updated_flag, 'N', 'Y', 'Y', decode(icx_por_ext_item.getBulkLoadActiveFlag(it.action, i.rt_item_id), 'N', 'N', 'Y')),
      decode(it.action, 'SYNC', 'ADD', it.action),
      decode(it.error_flag, 'Y', 'Y',
        decode(it.error_message, NULL, 'N', 'Y')),
      it.row_type,
      it.org_id,
      it.price_list_id,
      it.supplier_site_id,
      it.unit_of_measure
    FROM ICX_CAT_PRICES_GT it,
      icx_cat_items_b i
    WHERE it.supplier = i.supplier (+)
    AND it.supplier_part_num = i.supplier_part_num (+)
    AND it.supplier_part_auxid = i.supplier_part_auxid (+) -- Bug#2611529
    AND it.org_id = i.org_id(+)
    AND it.processed_flag = 'N';

  vRowids dbms_sql.urowid_table;
  --DUPE FAILED LINES Contract Auto Sourcing
  vLineNums dbms_sql.number_table;
  vSupplierPartNums dbms_sql.varchar2_table;
  vCurrentItemIds dbms_sql.number_table;
  vSystemActions dbms_sql.varchar2_table;
  vActiveFlags dbms_sql.varchar2_table;
  vHasErrors dbms_sql.varchar2_table;
  vRowTypes dbms_sql.varchar2_table;
  vPriceTypes dbms_sql.varchar2_table;
  vOrgIds dbms_sql.number_table;
  vPricelistIds dbms_sql.number_table;
  vSupplierSiteIds dbms_sql.number_table;
  vSupplierIds dbms_sql.number_table; --Bug#2611529
  vUoms dbms_sql.varchar2_table;

  -- BUYER NORMALIZATION
  vItemJobNums dbms_sql.number_table;
  vPrevItemId NUMBER := -1;
  vPrevOrgId NUMBER := -1;
  vDistinctBuyerCount NUMBER := 0;

  vCount PLS_INTEGER := 0;
  vASLCount PLS_INTEGER := 0;
  vHasAdd BOOLEAN := FALSE;
  vHasDelete BOOLEAN := FALSE;
  vErrorCount PLS_INTEGER := 0;
  vNumFailedLines NUMBER := 0;

  vPrevPriceListId NUMBER := null;
  vAbort BOOLEAN := FALSE;
  xErrLoc PLS_INTEGER := 100;
  --DUPE FAILED LINES Contract Auto Sourcing
  vPrevLineNum NUMBER := -1;
  vCurLineNum NUMBER := -1;

BEGIN
  clear_all;
  p_succ_line := 0;
  p_failed_line := 0;

  -- Reject all the duplicates first
  reject_duplicate_prices;

  xErrLoc := 200;
  -- Loop thru the interface table and divide the prices into the prices batch
  -- and the error batch.

  LOOP
    OPEN it_table_csr;

    xErrLoc := 210;
    --DUPE FAILED LINES Contract Auto Sourcing
    FETCH it_table_csr BULK COLLECT INTO
      vRowids, vLineNums, vSupplierIds, vPriceTypes, vSupplierPartNums,
      vCurrentItemIds, vActiveFlags,
      vSystemActions, vHasErrors, vRowTypes, vOrgIds, vPricelistIds,
      vSupplierSiteIds, vUoms
    LIMIT BATCH_SIZE;

    -- 01/31/02 - STO Bug 2209191 Added close cursor here
    CLOSE it_table_csr;

    EXIT WHEN vRowids.COUNT = 0;

    FOR i IN 1..vRowids.COUNT LOOP
      xErrLoc := 220;
      --DUPE FAILED LINES Contract Auto Sourcing
      vCurLineNum := vLineNums(i);
      xErrLoc := 221;
      IF (vSupplierPartNums(i) IS NOT NULL AND
        vCurrentItemIds(i) IS NULL) THEN
        vHasErrors(i) := 'Y';
        xErrLoc := 222;
        --DUPE FAILED LINES Contract Auto Sourcing
        IF ( vPrevLineNum <> vCurLineNum ) THEN
          reject_line(vRowids(i), 'PRICE',
            --ErrMsg'.SUPPLIER_PART_NUM:ICX_POR_PRC_INVALID_SUP_PART');
            '.BUYER:ICX_POR_PRC_INVALID_SUP_PART');
        END IF;
      END IF;

      xErrLoc := 223;
      IF (vHasErrors(i) = 'Y') THEN
        --DUPE FAILED LINES Contract Auto Sourcing
        IF( vPrevLineNum <> vCurLineNum) THEN
          p_failed_line := p_failed_line + 1;
          vErrorCount := vErrorCount + 1;
          gErrorRowids(vErrorCount) := vRowids(i);
        END IF;

        IF (p_max_failed_line >= 0 AND p_failed_line > p_max_failed_line) THEN
        -- Exceeded max failed lines.  Save all the failed lines and return
          vAbort := TRUE;
          EXIT;
        END IF;
      ELSE
        xErrLoc := 270;
        p_succ_line := p_succ_line + 1;
        vCount := vCount + 1;
        gRowids(vCount) := vRowids(i);
        gCurrentItemIds(vCount) := vCurrentItemIds(i);
        -- For price item ids are same as current item ids
        gItemIds(vCount) := vCurrentItemIds(i);
        gSystemActions(vCount) := vSystemActions(i);
        gRowTypes(vCount) := vRowTypes(i);
        gPriceTypes(vCount) := vPriceTypes(i);
        gOrgIds(vCount) := vOrgIds(i);
        gPricelistIds(vCount) := vPricelistIds(i);
        gSupplierSiteIds(vCount) := vSupplierSiteIds(i);
        gActiveFlags(vCount) := vActiveFlags(i);
        gUoms(vCount) := vUoms(i);
        gSupplierIds(vCount) := vSupplierIds(i); --Bug#2611529

        xErrLoc := 271;
        -- New or existing prices are processed in the same procedure
        IF (vSystemActions(i) = 'ADD') THEN
          vHasAdd := TRUE;

          -- BUYER NORMALIZATION
          -- These pl/sql tables may not be distinct, since we don't
          -- retrieve rows ordered by item and buyer anymore
          -- However, the logic in process_batch_addupdate_prices can handle
          -- dupliate item/buyer pairs and will not insert duplicate into
          -- icx_cat_items_ctx_tlp
          IF (vPrevItemId <> vCurrentItemIds(i) OR
              vPrevOrgId <> vOrgIds(i)) THEN
            vDistinctBuyerCount := vDistinctBuyerCount + 1;
            gDistinctItemIds(vDistinctBuyerCount) := vCurrentItemIds(i);
            gDistinctBuyerIds(vDistinctBuyerCount) := vOrgIds(i);
            vPrevItemId := vCurrentItemIds(i);
            vPrevOrgId := vOrgIds(i);
          END IF;

        ELSIF (vSystemActions(i) = 'DELETE') THEN
          vHasDelete := TRUE;
        END IF;

      END IF;

      --DUPE FAILED LINES Contract Auto Sourcing
      vPrevLineNum := vCurLineNum;
    END LOOP;

    IF (vCount > 0 AND NOT vAbort) THEN
      xErrLoc := 300;
      process_batch_prices(vHasAdd,  vHasDelete, vNumFailedLines);
      -- If there are some errors while processing the price lines, then
      -- update your successful/failed lines as per the
      -- value in vNumFailedLines.
      -- vNumFailedLines stores the failed lines while
      -- doing process_batch_prices
      p_failed_line := p_failed_line + vNumFailedLines;
      p_succ_line := p_succ_line - vNumFailedLines;
      vErrorCount := vErrorCount + vNumFailedLines;
      vNumFailedLines := 0; -- reset

      commit;
      clear_tables;
      vCount := 0;
      vHasAdd := FALSE;
      vHasDelete := FALSE;

    END IF;

    IF (vErrorCount > 0) THEN
      xErrLoc := 400;
      process_batch_price_errors(gErrorRowids);
      commit;
      clear_error_tables;
      vErrorCount := 0;
    END IF;

    IF (vRowids.COUNT < BATCH_SIZE OR vAbort) THEN
      EXIT;
    -- Update the processed_flag to null
    ELSE
      FORALL i IN 1..vRowids.COUNT
        UPDATE ICX_CAT_PRICES_GT
        SET processed_flag = 'Y' --Bug#2587763: set to "Y" instead of null.
        WHERE rowid = vRowids(i);

      COMMIT;

    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF (it_table_csr%ISOPEN) THEN
      CLOSE it_table_csr;
    END IF;

    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.move_prices('
      || xErrLoc || '): ' || SQLERRM);
END move_prices;

PROCEDURE reject_duplicates IS
  -- Bug#2611529
  CURSOR it_table_csr(p_language IN VARCHAR2) IS
     -- Bug# 3366614 sosingha: include supplier_site_id also for Item Uniqueness check
     SELECT it.rowid, it.supplier, it.supplier_part_num, it.supplier_part_auxid, it.org_id, row_type, it.supplier_site_id, it.currency
       FROM ICX_CAT_ITEMS_GT it
       WHERE language = p_language
    ORDER BY supplier asc, supplier_part_num asc, supplier_part_auxid asc, org_id asc, supplier_site_id asc, currency asc, line_number desc;

  vRowids dbms_sql.urowid_table;
  vSupplierPartNums dbms_sql.varchar2_table;
  vSupplierPartAuxids dbms_sql.varchar2_table; --Bug#2611529
  vSupplierNames dbms_sql.varchar2_table; --Bug#2611529
  vRowTypes dbms_sql.varchar2_table;
  vPrevPartNum VARCHAR2(2000) := null;
  vPrevPartAuxid VARCHAR2(2000) := null; --Bug#2611529
  vPrevSupplierName VARCHAR2(2000) := null; --Bug#2611529
  vOrgIds dbms_sql.varchar2_table;
  vCurrencies dbms_sql.varchar2_table;
  vSupplierSiteIds dbms_sql.number_table; -- Bug# 3366614 sosingha: for supp site ids
  vDupeRowIds dbms_sql.urowid_table; -- Bug# 3366614 sosingha: for row ids of duplicates
  vPrevCurrency VARCHAR2(30);
  vPrevSupplierSiteId NUMBER := -1; -- Bug# 3366614 sosingha: previous supp site ids
  vPrevOrgId NUMBER;
  xErrLoc PLS_INTEGER := 100;
BEGIN
  OPEN it_table_csr(gJobLanguage);

  LOOP
    vRowids.DELETE;
    vOrgIds.DELETE;
    vSupplierPartNums.DELETE;
    vSupplierPartAuxids.DELETE; -- Bug#2611529
    vSupplierNames.DELETE; -- Bug#2611529
    vCurrencies.DELETE;
    vRowTypes.DELETE;
    vSupplierSiteIds.DELETE;
    vDupeRowIds.DELETE;

    xErrLoc := 200;

    --Bug#2611529
    FETCH it_table_csr BULK COLLECT INTO
    -- Bug# 3366614 sosingha: fetch supplier_site_id also into the the table
      vRowids, vSupplierNames, vSupplierPartNums, vSupplierPartAuxids, vOrgIds, vRowTypes, vSupplierSiteIds, vCurrencies
    LIMIT BATCH_SIZE;

    EXIT WHEN vRowids.COUNT = 0;

    xErrLoc := 300;

    FOR i IN 1..vRowids.COUNT LOOP
      IF (vSupplierPartNums(i) IS NOT NULL
	  AND vSupplierNames(i) IS NOT NULL --Bug#2611529
	  AND vSupplierPartAuxids(i) IS NOT NULL --Bug#2611529
          AND vCurrencies(i) IS NOT NULL
          AND vOrgIds(i) IS NOT NULL) THEN

        IF (vSupplierPartNums(i) = vPrevPartNum
            AND vSupplierNames(i) = vPrevSupplierName --Bug#2611529
            AND vSupplierPartAuxids(i) = vPrevPartAuxid --Bug#2611529
            AND vCurrencies(i) = vPrevCurrency
	    AND vOrgIds(i) = vPrevOrgId
            -- Bug# 3366614 sosingha: Check for supplier_site_id also
            AND vSupplierSiteIds(i) = vPrevSupplierSiteId) THEN
              -- Duplicate item, reject this
              reject_line(vRowids(i), 'ITEM',
              --ErrMsg'.SUPPLIER_PART_NUM:POM_CATALOG_DUP_ITEM_IN_FILE');
              '.BUYER:ICX_POR_DUP_SUPPLIER_PART');
        /* if 4 primary attributes are same and either Currency or Supplier Site are different
        store these rowIds cwwhich we need to mark it as 'D' to insert into item_prices by
        calling move_items with processed_flag as 'D' for these rows */
        ELSIF (vSupplierPartNums(i) = vPrevPartNum
            AND vSupplierNames(i) = vPrevSupplierName
            AND vSupplierPartAuxids(i) = vPrevPartAuxid
            AND vOrgIds(i) = vPrevOrgId) THEN
              vDupeRowIds(vDupeRowIds.COUNT + 1) := vRowids(i);
              gDuplicatesExists := true;
        ELSE
          vPrevPartNum := vSupplierPartNums(i);
          vPrevPartAuxid := vSupplierPartAuxids(i);	 --Bug#2611529
          vPrevSupplierName := vSupplierNames(i);	 --Bug#2611529
	  vPrevOrgId := vOrgIds(i);
          vPrevCurrency := vCurrencies(i);
          vPrevSupplierSiteId := vSupplierSiteIds(i);
        END IF;

      ELSE
        IF ( vSupplierPartNums(i) IS NULL ) THEN
          reject_line(vRowids(i), 'ITEM',
            '.SUPPLIER_PART_NUM:ICX_POR_CAT_FIELD_REQUIRED');
        END IF;
        /* Currenccy required error not needed to be thrown here,
           since for ITEM_PRICE or PRICE it is already caught in
           PriceListElementValidator.java
        IF ( vCurrencies(i) IS NULL AND vRowTypes(i) <> 'ITEM') THEN
          reject_line(vRowids(i), 'ITEM',
            '.CURRENCY:ICX_POR_CAT_FIELD_REQUIRED');
        END IF;
        */

      END IF;

    END LOOP;

    xErrLoc := 400;
    -- Bug# 3366614 sosingha: Update rows with duplicates values for 4 primary item uniqueness attributes with processed flag as 'D'
    FOR i in 1..vDupeRowIds.COUNT LOOP
      UPDATE ICX_CAT_ITEMS_GT
      SET    PROCESSED_FLAG = 'D'
      WHERE  ROWID = vDupeRowIds(i);
      COMMIT;
    END LOOP;

    xErrLoc := 500;
    IF (vRowids.COUNT < BATCH_SIZE) THEN
      EXIT;
    END IF;

  END LOOP;

  CLOSE it_table_csr;

EXCEPTION
  WHEN OTHERS THEN
    IF (it_table_csr%ISOPEN) THEN
      CLOSE it_table_csr;
    END IF;

    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.reject_duplicates('
      || xErrLoc || '): ' || SQLERRM);
END reject_duplicates;

/*Processes the valid items*/
/* Bug# 3366614 sosingha: add an additional parameter p_processed_flag to differentiate
   Duplicate 4 primary attributes for item uniqueness with 'D' */
PROCEDURE move_items( p_succ_line OUT NOCOPY NUMBER, p_failed_line OUT NOCOPY NUMBER,
  p_max_failed_line IN NUMBER, p_processed_flag VARCHAR2) IS

  -- ItemUniqueness: Changes in any Item related uniqueness rules
  --                should be implemented in the below sql
  --                Make sure the g_ plsql table is populated
  -- also get the system_action populated for Item template file
  -- to UPDATE/DELETE, system_action is used to check if the item exists
  -- and throw the error BUYER:ICX_POR_PRC_INVALID_SUP_PART
  CURSOR it_table_csr IS
    SELECT /*+ USE_NL(it i tl) LEADING(it) */
      it.rowid,
      it.supplier,  --Bug#2729328
      it.supplier_id,  --Bug#2611529
      it.supplier_part_num,
      it.supplier_part_auxid, --Bug#2611529
      i.rt_item_id,
      decode(it.action, 'SYNC',
        decode(i.rt_item_id, NULL, 'ADD',
          decode(tl.rt_item_id, NULL, 'TRANSLATE', 'UPDATE')), it.action),
      decode(it.error_flag, 'Y', 'Y',
	     decode(it.error_message, NULL, 'N', 'Y')),
      decode(it.error_flag, 'Y', i.rt_item_id,
	     decode(it.action, 'SYNC',
		    decode(i.rt_item_id, NULL, icx_por_itemid.NEXTVAL,
			   i.rt_item_id), i.rt_item_id)),
      it.row_type,
      decode(it.contract_num, null, 'BULKLOAD', 'CONTRACT'),
      it.rt_category_id,
      tl.primary_category_id,
      it.category_name,
      it.org_id,
      it.price_list_id,
      it.supplier_site_id,
      i.extractor_updated_flag,
      decode(i.extractor_updated_flag, 'N', 'Y', 'Y', decode(icx_por_ext_item.getBulkLoadActiveFlag(it.action, i.rt_item_id), 'N', 'N', 'Y')),
      decode(it.required_descriptors, NULL, 'N', 'Y'),
      decode(it.required_tl_descriptors, NULL, 'N', 'Y'),
      it.unit_price,
      it.unit_of_measure
      ,it.system_action
    FROM ICX_CAT_ITEMS_GT it,
      icx_cat_items_b i, --Bug#2714487: dont join with category_items
      icx_cat_items_tlp tl
    WHERE it.supplier = i.supplier (+)
    AND it.supplier_part_num = i.supplier_part_num (+)
    AND it.supplier_part_auxid = i.supplier_part_auxid (+) --Bug#2611529
    AND it.org_id = i.org_id(+)
    AND i.rt_item_id = tl.rt_item_id (+)
    AND gJobLanguage = tl.language (+)
    AND gJobLanguage = it.language
    -- Bug# 3366614 sosingha: p_processed_flag willl have a value 'N' first and then 'D' if duplicates exists
    -- AND it.processed_flag = 'N';
    AND it.processed_flag = p_processed_flag;

  vRowids dbms_sql.urowid_table;
  vSupplierPartNums dbms_sql.varchar2_table;
  vSuppliers dbms_sql.varchar2_table;  --Bug#2729328
  vSupplierPartAuxids dbms_sql.varchar2_table; --Bug#2611529
  vCurrentItemIds dbms_sql.number_table;
  vSystemActions dbms_sql.varchar2_table;
  vHasErrors dbms_sql.varchar2_table;
  vItemIds dbms_sql.number_table;
  vRowTypes dbms_sql.varchar2_table;
  vPriceTypes dbms_sql.varchar2_table;
  vCategoryIds dbms_sql.number_table;
  vOldCategoryIds dbms_sql.number_table;
  vCategoryNames dbms_sql.varchar2_table;
  vOrgIds dbms_sql.number_table;
  vPricelistIds dbms_sql.number_table;
  vSupplierSiteIds dbms_sql.number_table;
  vExtractorUpdatedFlags dbms_sql.varchar2_table;
  vActiveFlags dbms_sql.varchar2_table;
  vMissingRequired dbms_sql.varchar2_table;
  vMissingTLRequired dbms_sql.varchar2_table;
  vUnitPrices dbms_sql.varchar2_table; --Bug#2733716
  vSupplierIds dbms_sql.number_table; --Bug#2611529
  vUoms dbms_sql.varchar2_table; --Bug#2611529
  vGTSystemAction dbms_sql.varchar2_table;

  vCount PLS_INTEGER := 0;
  vASLCount PLS_INTEGER := 0;
  vHasAdd BOOLEAN := FALSE;
  vHasUpdate BOOLEAN := FALSE;
  vHasDelete BOOLEAN := FALSE;
  vHasTranslate BOOLEAN := FALSE;
  vErrorCount PLS_INTEGER := 0;
  vHasPrices BOOLEAN := FALSE;

  vAbort BOOLEAN := FALSE;
  --Category_Change
  vChangedCatItemIndex PLS_INTEGER := 0;
  vCurrentBatch PLS_INTEGER := 0;
  xErrLoc PLS_INTEGER := 100;
BEGIN
  clear_all;
  p_succ_line := 0;
  p_failed_line := 0;

  xErrLoc := 200;
  build_root_sql('ICX_CAT_ITEMS_GT');
  xErrLoc := 300;

  /* Bug# 3366614 sosingha: move this call to move_data as we have to always call this before calling move_items
  -- Reject all the duplicates first
  reject_duplicates;
  */
  xErrLoc := 400;

  -- Loop thru the interface table and divide the items into the items batch
  -- and the error batch.

  LOOP
    OPEN it_table_csr;
    xErrLoc := 500;
    --Bug#3570709
    --Before each batch instantiate the vChangedCatItemIndex to 0
    vChangedCatItemIndex := 0;
    vCurrentBatch := vCurrentBatch+1;
    --Add the Debug info for the current batch
    icx_por_ext_utl.debug(icx_por_ext_utl.MUST_LEVEL,
                          'Currently processing batch number:'||to_char(vCurrentBatch) );

    FETCH it_table_csr BULK COLLECT INTO
      --Bug#2729328
      vRowids, vSuppliers, vSupplierIds, vSupplierPartNums, vSupplierPartAuxids, --Bug#2611529
      vCurrentItemIds, vSystemActions, vHasErrors,
      vItemIds, vRowTypes, vPriceTypes, vCategoryIds, vOldCategoryIds,
      vCategoryNames, vOrgIds, vPricelistIds,
      vSupplierSiteIds, vExtractorUpdatedFlags, vActiveFlags,
      vMissingRequired, vMissingTLRequired, vUnitPrices, vUoms
      , vGTSystemAction
    LIMIT BATCH_SIZE;
    xErrLoc := 600;

    CLOSE it_table_csr;

    EXIT WHEN vRowids.COUNT = 0;

    xErrLoc := 700;
    FOR i IN 1..vRowids.COUNT LOOP

      -- deleting supplier part number that does not exist
      IF (vSystemActions(i) = 'DELETE' AND
        vSupplierPartNums(i) IS NOT NULL AND
        vCurrentItemIds(i) IS NULL) THEN
        vHasErrors(i) := 'Y';
        reject_line(vRowids(i), 'ITEM',
          --ErrMsg'.SUPPLIER_PART_NUM:ICX_POR_PRC_INVALID_SUP_PART');
          '.BUYER:ICX_POR_PRC_INVALID_SUP_PART');
      END IF;
      xErrLoc := 800;

      -- Cannot delete extractor updated items.
      IF (vSystemActions(i) = 'DELETE' AND
        vSupplierPartNums(i) IS NOT NULL AND
        vCurrentItemIds(i) IS NOT NULL AND vExtractorUpdatedFlags(i) = 'Y') THEN
        vHasErrors(i) := 'Y';
        reject_line(vRowids(i), 'ITEM',
          '.SUPPLIER_PART_NUM:ICX_POR_DELETE_EXTRACTED_ITEM');
      END IF;
      xErrLoc := 900;

      IF (vSystemActions(i) = 'ADD' AND
         (vMissingRequired(i) = 'Y' OR vMissingTLRequired(i) = 'Y')) OR
         (vSystemActions(i) = 'TRANSLATE' AND vMissingTLRequired(i) = 'Y') THEN
        vHasErrors(i) := 'Y';
      END IF;

      xErrLoc := 1000;
      IF ( vGTSystemAction(i) IN ('UPDATE', 'DELETE') AND
           vCurrentItemIds(i) IS NULL ) THEN
        --This will happen only when item template files is used to update
        --an item that does not exists
        xErrLoc := 1005;
        vHasErrors(i) := 'Y';
        reject_line(vRowids(i), 'ITEM','BUYER:ICX_POR_PRC_INVALID_SUP_PART');
      -- Trying to add a new item without a price ? Reject the line !
      -- Item add without price is not allowed in IP.
      -- Bug#2729328
      -- Added the severity level when to log PRICE REQD Error
      ELSIF ( vSystemActions(i) = 'ADD' AND vUnitPrices(i) is null AND
           vSuppliers(i) IS NOT NULL AND vSupplierPartNums(i) IS NOT NULL AND
           vCategoryNames(i) IS NOT NULL ) THEN
        xErrLoc := 1010;
        vHasErrors(i) := 'Y';
        reject_line(vRowids(i), 'ITEM','.PRICE:ICX_POR_CAT_FIELD_REQUIRED');
      END IF;

      xErrLoc := 1100;
      IF (vHasErrors(i) = 'Y') THEN
        p_failed_line := p_failed_line + 1;
        vErrorCount := vErrorCount + 1;
        gErrorRowids(vErrorCount) := vRowids(i);

        xErrLoc := 1200;
        IF (p_max_failed_line >= 0 AND p_failed_line > p_max_failed_line) THEN
          -- Exceeded max failed lines.  Save all the failed lines and return
          vAbort := TRUE;
          EXIT;
        END IF;

      ELSE
        p_succ_line := p_succ_line + 1;
        vCount := vCount + 1;
        gRowids(vCount) := vRowids(i);
        gCurrentItemIds(vCount) := vCurrentItemIds(i);
        gSystemActions(vCount) := vSystemActions(i);
	gItemIds(vCount) := vItemIds(i);
        gPriceTypes(vCount) := vPriceTypes(i);
        gRowTypes(vCount) := vRowTypes(i);
        gCategoryIds(vCount) := vCategoryIds(i);
        gCategoryNames(vCount) := vCategoryNames(i);
        gOldCategoryIds(vCount) := vOldCategoryIds(i);
        gOrgIds(vCount) := vOrgIds(i);
        gPricelistIds(vCount) := vPricelistIds(i);
        gSupplierSiteIds(vCount) := vSupplierSiteIds(i);
	gExtractorUpdatedFlags(vCount) := vExtractorUpdatedFlags(i);
        gActiveFlags(vCount) := vActiveFlags(i);
        gUoms(vCount) := vUoms(i);
        gSupplierIds(vCount) := vSupplierIds(i);
        -- Category has changed ?
        -- Category_Change
        if(vOldCategoryIds(i) <> vCategoryIds(i)) then
          --Index of all gChanged.. plssql_tables should start with 1
          --instead of i
          vChangedCatItemIndex := vChangedCatItemIndex +1;
          --Debugging
          icx_por_ext_utl.debug(icx_por_ext_utl.MUST_LEVEL,
                                'Category Change seen; vChangedCatItemIndex:' ||to_char(vChangedCatItemIndex)
                                ||', variables at position i:'||to_char(i)
                                ||': vOldCategoryIds:'||to_char(vOldCategoryIds(i))
                                ||', vCategoryIds:' ||to_char(vCategoryIds(i))
                                ||', gItemIds:' ||to_char(gItemIds(i))
                                ||', vSystemActions:' ||vSystemActions(i) );
          gChangedCatItemIds(vChangedCatItemIndex) := gItemIds(i);
          gChangedOldCatIds(vChangedCatItemIndex) := vOldCategoryIds(i);
          gChangedNewCatIds(vChangedCatItemIndex) := vCategoryIds(i);
          gChangedCatActions(vChangedCatItemIndex) := vSystemActions(i);
        end if;

        xErrLoc := 1300;
        IF (vSystemActions(i) = 'ADD') THEN
          vHasAdd := TRUE;
        ELSIF (vSystemActions(i) = 'UPDATE') THEN
          vHasUpdate := TRUE;
        ELSIF (vSystemActions(i) = 'DELETE') THEN
          vHasDelete := TRUE;
        ELSIF (vSystemActions(i) = 'TRANSLATE') THEN
          vHasTranslate := TRUE;
        END IF;

        xErrLoc := 1300;
        IF (vRowTypes(i) IN ('ITEM_PRICE')) THEN
          vHasPrices := TRUE;
        END IF;

      END IF;

    END LOOP;
    xErrLoc := 1400;

    IF (vCount > 0 AND NOT vAbort) THEN
      xErrLoc := 1500;
      process_batch_items(vHasAdd, vHasUpdate, vHasDelete,
        vHasTranslate, vHasPrices);
      xErrLoc := 1600;
      commit;
      clear_tables;
      vCount := 0;
      vHasAdd := FALSE;
      vHasUpdate := FALSE;
      vHasDelete := FALSE;
      vHasTranslate := FALSE;
      vHasPrices := FALSE;
    END IF;

    xErrLoc := 1700;
    IF (vErrorCount > 0) THEN
      xErrLoc := 1800;
    -- Need to first populate the system action column in the it table
      FORALL i IN 1..vRowids.COUNT
        UPDATE ICX_CAT_ITEMS_GT
        SET system_action = vSystemActions(i)
        WHERE rowid = vRowids(i)
        AND vHasErrors(i) = 'Y';

      xErrLoc := 1900;
      process_batch_item_errors(gErrorRowids);
      commit;
      clear_error_tables;
      vErrorCount := 0;
    END IF;

    xErrLoc := 2000;
    IF (vRowids.COUNT < BATCH_SIZE OR vAbort) THEN
      EXIT;
    -- Update the processed_flag to null
    ELSE
      xErrLoc := 2100;
      FORALL i IN 1..vRowids.COUNT
        UPDATE ICX_CAT_ITEMS_GT
        SET processed_flag = 'Y' --Bug#2958208: set to "Y" instead of null.
        WHERE rowid = vRowids(i);

      COMMIT;
    END IF;

  END LOOP;
  xErrLoc := 2200;

EXCEPTION
  WHEN OTHERS THEN
    IF (it_table_csr%ISOPEN) THEN
      CLOSE it_table_csr;
    END IF;

    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.move_items('
      || xErrLoc || '): ' || SQLERRM);
END move_items;

/* Processes the lines for a given job */
--Bug#2611529: Added another parameter for catalog name
PROCEDURE move_data(p_app_name IN VARCHAR2, p_request_id IN NUMBER,
  p_data_type IN VARCHAR2, p_supplier_id IN NUMBER, p_langs IN LANG_ARRAY,
  p_user_id IN NUMBER, p_user_login IN NUMBER, p_batch_size IN NUMBER,
  p_succ_line OUT NOCOPY NUMBER, p_failed_line OUT NOCOPY NUMBER,
  p_max_failed_line IN NUMBER DEFAULT -1,
  p_catalog_name IN VARCHAR2, --Bug#2611529
  p_negotiated_price IN VARCHAR2 --Bug#2611529
  ) IS
  xErrLoc PLS_INTEGER := 100;
  l_cursor INTEGER;
  l_ret INTEGER;

  --Bug#2611529
  succ_line PLS_INTEGER := 0;
  failed_line PLS_INTEGER := 0;

BEGIN
  -- For any PRICE/ITEM_PRICE, org_id, price_list_id, and supplier_site_id should be populated
  -- if they are valid.

  IF (p_batch_size > 0) THEN
    BATCH_SIZE := p_batch_size;
  ELSE
    BATCH_SIZE := 1000;
  END IF;

  --Add the Debug info for the current batch
  icx_por_ext_utl.debug(icx_por_ext_utl.MUST_LEVEL,
                        'BATCH_SIZE set to:'||to_char(BATCH_SIZE) );

  CACHE_SIZE := 2*BATCH_SIZE;

  gJobNumber := p_request_id;
--Bug#2611529  gSupplierId := p_supplier_id;

  SELECT language_code INTO gBaseLanguage
  FROM fnd_languages
  WHERE installed_flag = 'B';

--Bug#2611529  gJobLanguage := p_language;
  gUserId := p_user_id;
  gUserLogin := p_user_login;
  gCatalogName := p_catalog_name; -- Bug#2611529

  -- a Yes/No lookup already exists with Y/N(instead of 1/0)
  if(p_negotiated_price = 'Y') then -- Bug#3107596
    gNegotiatedPrice := 1;
  else
    gNegotiatedPrice := 0;
  end if;

  p_succ_line := 0;
  p_failed_line := 0;

  FOR i IN 1..p_langs.COUNT loop
    gJobLanguage := p_langs(i);

    IF (p_data_type = 'ITEM') THEN
      xErrLoc := 200;
      -- Bug# 3366614 sosingha: Reject all the duplicates first then call move_items with processed_flag 'N' and then with processed_flag 'D'
      reject_duplicates;
      move_items(succ_line, failed_line, p_max_failed_line, 'N');
      p_succ_line := p_succ_line + succ_line;
      p_failed_line := p_failed_line + failed_line;
      IF(gDuplicatesExists = true) THEN
        move_items(succ_line, failed_line, p_max_failed_line, 'D');
        p_succ_line := p_succ_line + succ_line;
        p_failed_line := p_failed_line + failed_line;
      END IF;
    ELSIF (p_data_type = 'PRICE') THEN
      xErrLoc := 300;
      move_prices(p_succ_line, p_failed_line, p_max_failed_line);
    END IF;
  END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.move_data('
      || xErrLoc || '): ' || SQLERRM);
END move_data;

PROCEDURE move_unsaved_failed_lines(p_request_id IN NUMBER,
p_data_type IN VARCHAR2, p_supplier_id IN NUMBER,
p_user_id IN NUMBER, p_user_login IN NUMBER,
p_language IN VARCHAR2, p_lines_to_save_count IN NUMBER,
p_failed_lines_saved_count OUT NOCOPY NUMBER) IS
  TYPE FailedLinesCsrTyp IS REF CURSOR;
  vFailedLinesCsr FailedLinesCsrTyp;
  vTableName VARCHAR2(30);
  vSQL VARCHAR2(2000);
  vRowId UROWID;
  vErrorCount NUMBER := 0;
  xErrLoc PLS_INTEGER := 100;
  v_lines_to_save_count NUMBER := p_lines_to_save_count;
BEGIN
  BATCH_SIZE := 2500;

  gJobNumber := p_request_id;
--Bug#2611529  gSupplierId := p_supplier_id;

  SELECT language_code INTO gBaseLanguage
  FROM fnd_languages
  WHERE installed_flag = 'B';

  gJobLanguage := p_language;
  gUserId := p_user_id;
  gUserLogin := p_user_login;

  clear_all;

  IF (p_data_type = 'ITEM') THEN
    vTableName := 'ICX_CAT_ITEMS_GT';
  ELSIF (p_data_type = 'PRICE') THEN
    vTableName := 'ICX_CAT_PRICES_GT';
  ELSE
    p_failed_lines_saved_count := 0;
    RETURN;
  END IF;

  vSQL := 'SELECT rowid FROM ' || vTableName ||
    ' WHERE error_flag IS NULL and (error_message IS NOT NULL OR ' ||
    ' (system_action IN (''ADD'') and required_descriptors IS NOT NULL) OR ' ||
    ' (system_action IN (''ADD'', ''TRANSLATE'') ' ||
    ' and required_tl_descriptors IS NOT NULL))';

  OPEN vFailedLinesCsr FOR vSQL;

  LOOP
    FETCH vFailedLinesCsr INTO vRowId;
    EXIT WHEN vFailedLinesCsr%NOTFOUND OR vErrorCount = v_lines_to_save_count;

    vErrorCount := vErrorCount + 1;
    gErrorRowids(vErrorCount) := vRowid;

    IF (vErrorCount >= BATCH_SIZE) THEN

      IF (p_data_type = 'ITEM') THEN
        process_batch_item_errors(gErrorRowids);
      ELSE
        process_batch_price_errors(gErrorRowids);
      END IF;

      commit;
      clear_error_tables;
      p_failed_lines_saved_count := p_failed_lines_saved_count + vErrorCount;
      v_lines_to_save_count := v_lines_to_save_count - vErrorCount;
      vErrorCount := 0;
    END IF;

  END LOOP;

  IF (vErrorCount > 0) THEN

    IF (p_data_type = 'ITEM') THEN
      process_batch_item_errors(gErrorRowids);
    ELSE
      process_batch_price_errors(gErrorRowids);
    END IF;

    commit;
    clear_error_tables;
    p_failed_lines_saved_count := p_failed_lines_saved_count + vErrorCount;
    vErrorCount := 0;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.move_unsaved_failed_lines('
      || xErrLoc || '): ' || SQLERRM);
END move_unsaved_failed_lines;

PROCEDURE create_price_list(p_price_list_name IN VARCHAR2,
                            p_buyer_id in NUMBER,
                            p_supplier_id IN NUMBER,
                            p_currency IN VARCHAR2,
                            p_begindate IN VARCHAR2,
                            p_enddate IN VARCHAR2,
                            p_user_id IN NUMBER,
                            p_request_id IN NUMBER,
                            p_header_id OUT NOCOPY NUMBER,
                            p_type OUT NOCOPY VARCHAR2) IS
xErrLoc INTEGER;
l_type VARCHAR2(1);
invalid_buyer EXCEPTION;
BEGIN
  xErrLoc := 100;

  p_type := 'B';

  xErrLoc := 200;

  INSERT INTO icx_cat_price_lists (price_list_id, name, supplier_id,
    buyer_id, description, currency, begindate, enddate, action, status,
    type, parent_header_id, creation_date, published_date, approval_date,
    created_by, last_update_date, last_updated_by,
    last_update_login, request_id) values
   (icx_por_price_lists_s.nextval, p_price_list_name,
    p_supplier_id, p_buyer_id,null,p_currency,
    to_date(p_begindate, DEFAULT_DATE_FORMAT),
    to_date(p_enddate, DEFAULT_DATE_FORMAT),
    'ADD', 'APPROVED', p_type, null, sysdate, sysdate, sysdate,
    p_user_id, sysdate, p_user_id, p_user_id, p_request_id)
  RETURNING price_list_id INTO p_header_id;

  xErrLoc := 300;
  commit;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.create_price_list('
      || xErrLoc || '): ' || SQLERRM);
END create_price_list;

PROCEDURE update_price_list( p_header_id IN NUMBER,
                            p_begindate IN VARCHAR2,
                            p_enddate IN VARCHAR2,
                            p_user_id IN NUMBER,
                            p_request_id IN NUMBER) IS
xErrLoc INTEGER;
p_type  icx_por_price_lists.type%TYPE;
BEGIN
  xErrLoc := 100;
  -- Delete unapproved price lists first
  DELETE FROM icx_cat_price_lists
  WHERE price_list_id = p_header_id
  AND status IN ('UNPUBLISHED', 'PUBLISHED');

  xErrLoc := 200;

  INSERT INTO icx_cat_price_lists (price_list_id, name, supplier_id,
    buyer_id, description, currency, begindate, enddate, action, status,
    type, parent_header_id,
    creation_date, created_by, last_update_date, last_updated_by,
    last_update_login, request_id)
  SELECT pl.price_list_id , pl.name,
    pl.supplier_id, pl.buyer_id, pl.description, pl.currency,
    decode(p_begindate, null, pl.begindate,
      to_date(p_begindate, DEFAULT_DATE_FORMAT)),
    decode(p_enddate, null, pl.enddate,
      to_date(p_enddate, DEFAULT_DATE_FORMAT)) ,
    'UPDATE', 'UNPUBLISHED',
    pl.type, pl.parent_header_id, pl.creation_date,
    pl.created_by, sysdate, p_user_id, p_user_id, p_request_id
    FROM icx_cat_price_lists pl
    WHERE pl.price_list_id = p_header_id
    AND pl.status = 'APPROVED';

  -- added by bluk for group pricing project
  -- propagate changes for child lists
  xErrLoc := 300;

  SELECT type INTO p_type FROM icx_cat_price_lists
  WHERE price_list_id = p_header_id
  AND status = 'APPROVED';

  xErrLoc := 310;
  commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.update_price_list('
      || xErrLoc || '): ' || SQLERRM);
END update_price_list;

PROCEDURE delete_price_list( p_header_id IN NUMBER ) IS
xErrLoc INTEGER;
p_type  icx_cat_price_lists.type%TYPE;
BEGIN
  xErrLoc := 100;
  DELETE FROM icx_cat_price_lists
  WHERE price_list_id = p_header_id;
  commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000,
      'Exception at ICX_POR_ITEM_UPLOAD.delete_price_list('
      || xErrLoc || '): ' || SQLERRM);
END delete_price_list;

--Bug#2709997: Pass in supplier site code also
PROCEDURE save_failed_price(p_request_id IN NUMBER,
			    p_line_number IN NUMBER,
			    p_action IN VARCHAR2,
			    p_amount IN VARCHAR2,
			    p_currency IN VARCHAR2,
			    p_uom IN VARCHAR2,
			    p_buyer_name IN VARCHAR2,
			    p_supplier_name IN VARCHAR2,
			    p_supplier_part_num IN VARCHAR2,
			    p_price_list_name IN VARCHAR2,
			    p_price_code IN VARCHAR2,
			    p_supplier_comments IN VARCHAR2,
          p_begin_date IN VARCHAR2,
          p_end_date IN VARCHAR2,
          p_supplier_part_auxid IN VARCHAR2,
          p_supplier_site_code IN VARCHAR2) IS
l_progress VARCHAR2(5) := '100';
BEGIN

  --IF p_amount IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'PRICE', p_amount);
  --END IF;

  l_progress := '110';

  --IF p_currency IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'CURRENCY', p_currency);
  --END IF;

  --IF p_uom IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'UOM', p_uom);
  --END IF;

  --IF p_buyer_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'BUYER', p_buyer_name);
  --END IF;

  --IF p_supplier_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'SUPPLIER', p_supplier_name);
  --END IF;

  --IF p_supplier_part_num IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'SUPPLIER_PART_NUM', p_supplier_part_num);
  --END IF;

  --Bug#2611529
  --IF p_supplier_part_auxid IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'SUPPLIER_PART_AUXID', p_supplier_part_auxid);
  --END IF;

  --Bug#2709997
  --IF p_supplier_site_code IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'SUPPLIER_SITE', p_supplier_site_code);
  --END IF;

  --IF p_price_list_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'PRICELIST', p_price_list_name);
  --END IF;

  /* Bug#2729328
  IF p_price_code IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'PRICE', p_price_code);
  END IF;

  IF p_supplier_comments IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'SUPPLIERCOMMENTS', p_price_list_name);
  END IF;

  IF p_begin_date IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'BEGINDATE', p_begin_date);
  END IF;

  IF p_end_date IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICE', 'ENDDATE', p_end_date);
  END IF;
  */

END save_failed_price;

PROCEDURE save_failed_price_list(p_request_id IN NUMBER,
			    p_line_number IN NUMBER,
			    p_action IN VARCHAR2,
          p_price_list_name IN VARCHAR2,
			    p_currency IN VARCHAR2,
			    p_buyer_name IN VARCHAR2,
			    p_supplier_name IN VARCHAR2,
			    p_begin_date IN VARCHAR2,
			    p_end_date IN VARCHAR2) IS
l_progress VARCHAR2(5) := '100';
BEGIN
  IF p_price_list_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICELISTHEADER', 'PRICELIST', p_price_list_name);
  END IF;

  l_progress := '110';

  IF p_currency IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICELISTHEADER', 'CURRENCY', p_currency);
  END IF;

  IF p_buyer_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICELISTHEADER', 'BUYER', p_buyer_name);
  END IF;

  IF p_supplier_name IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICELISTHEADER', 'SUPPLIER', p_supplier_name);
  END IF;

  IF p_begin_date IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICELISTHEADER', 'BEGINDATE', p_begin_date);
  END IF;

  IF p_end_date IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines (job_number, line_number, action,
    row_type, descriptor_key, descriptor_value) VALUES (p_request_id,
    p_line_number, p_action, 'PRICELISTHEADER', 'ENDDATE', p_end_date);
  END IF;

END save_failed_price_list;

--
-- Move the error message from ICX_POR_CONTRACT_REFERENCE table
-- into ICX_POR_FAILED_LINES and ICX_POR_FAILED_LINE_MESSAGES table
--
-- bug#1968033
PROCEDURE save_failed_admin_data (p_request_id in number)
IS
  --sbgeorge
  --changed to have a cursor instead of dynamic sql
  cursor c_contract_references is
    select request_id, line_number, buyer_id, buyer_name,
           contract_reference_id, contract_reference_num, supplier_id,
           supplier_site, pricelist_id, currency_code, error_message
      from icx_por_contract_references
     where request_id = p_request_id;

  l_progress varchar2(10) := '100';
BEGIN
  FOR l_contracts in c_contract_references LOOP
    l_progress := '200';
    if (l_contracts.error_message is not null) then
      save_failed_admin( l_contracts.request_id,
                         l_contracts.line_number,
                         l_contracts.buyer_name,
                         l_contracts.contract_reference_num);

      l_progress := '300';
      ICX_POR_ITEM_UPLOAD.save_failed_line_message(l_contracts.request_id,
                                                   l_contracts.line_number,
                                                   l_contracts.error_message);
    end if;
 END LOOP;

EXCEPTION
  WHEN OTHERS then
      RAISE_APPLICATION_ERROR (-20000, 'Exception at '||
                     'ICX_POR_ITEM_UPLOAD.save_failed_admin_data '||
                     '(ErrLoc = ' || l_progress ||') ' ||
                     'SQL Error : ' || SQLERRM);

END save_failed_admin_data;

-- Check if the descriptor value is updateable.
-- Certain descriptors like internal item number, CONTRACT_PRICE
-- are non updateable
FUNCTION can_update(descriptor_key IN VARCHAR2) return boolean
is
BEGIN
  if (descriptor_key in
         (
          'UOM', 'PRICE',
          'CURRENCY', 'INTERNAL_ITEM_NUM', 'CONTRACT_NUM',
          'CONTRACT_LINE', 'CONTRACT_PRICE', 'CONTRACT_CURRENCY',
          'CONTRACT_RATE_TYPE', 'CONTRACT_RATE_DATE', 'CONTRACT_RATE',
          'FUNCTIONAL_PRICE', 'FUNCTIONAL_CURRENCY', 'SUPPLIER_SITE',
          'BUYER', 'PRICELIST'))
  then
    return false;
  else
    return true;
  end if;
END can_update;

--
-- Validate the Contract Reference section
-- Validate if all the contract references have the same supplier
-- and currency
--
PROCEDURE validate_contracts(p_request_id in number, p_line_number in number,
              p_buyer in varchar2, p_contract in varchar2,
              p_supplier OUT NOCOPY varchar2, p_currency OUT NOCOPY varchar2,
              p_error_message OUT NOCOPY varchar2)
IS

l_progress INTEGER := 0;
l_count INTEGER := 0;
l_valid boolean := true;

BEGIN
  l_progress := 110;
  p_error_message := null;
  p_supplier := null;
  p_currency := null;

  select count(distinct supplier_id)
    into l_count
    from icx_por_contract_references
   where supplier_id is not null
     and request_id=p_request_id;

  l_progress := 120;
  -- Are there multiple Suppliers ?
  -- Error out..Dont even check for other errors(like multiple currencies)
  if l_count > 1 then
      --ErrMsg p_error_message := '.SUPPLIER:ICX_POR_DUPE_SUPPLIER';
      p_error_message := '.CONTRACT_NUM:ICX_POR_DUPE_SUPPLIER';
      l_progress := 130;
      l_valid := false;
  else
        -- Are there multiple currencies ?
        -- Error out..
	select count(distinct currency_code)
          into l_count
          from icx_por_contract_references
         where currency_code is not null
           and request_id=p_request_id;
        l_progress := 140;

        if l_count > 1 then
            -- Bug#2075574
            --ErrMsg p_error_message := '.CURRENCY:ICX_POR_DUPE_CURRENCY';
            p_error_message := '.CONTRACT_NUM:ICX_POR_DUPE_CURRENCY';
            l_progress := 150;
            l_valid := false;
        end if;
  end if;
  -- Bug#2075574
  -- Dont add failed lines here. Will be added in the Admin validator!
  l_progress := 150;
  if l_valid = true then
      -- Get the Supplier Name and Currency
      get_global_supplier_currency(p_request_id, p_supplier, p_currency);

  end if;


exception
  when others then
    Debug('[validate_contracts-'||l_progress||'] '||SQLERRM);
      RAISE_APPLICATION_ERROR (-20000, 'Exception at ' ||
                     'ICX_POR_ITEM_UPLOAD.validate_contracts' ||
                     '(ErrLoc = ' || l_progress ||') ' ||
                     'SQL Error : ' || SQLERRM);

end ;

--
-- Get the Global Supplier and currency that is used by ALL the
-- Contract references in the contract section
--
PROCEDURE get_global_supplier_currency( p_request_id IN NUMBER,
                             p_supplier OUT NOCOPY VARCHAR,
                             p_currency OUT NOCOPY VARCHAR)
IS
  l_progress INTEGER := 0;
BEGIN

      -- Get the Globally used Supplier in the Contract
      -- Reference Section: Get for Valid contracts only

      select distinct vendor_name into p_supplier
      from po_vendors poV, icx_por_contract_references icxC
      where poV.vendor_id = icxC.supplier_id
      and icxC.request_id=p_request_id
      and icxC.supplier_id is not null;

      l_progress := 220;

      -- Get the Globally used Currency in the Contract
      -- Reference Section: Get for Valid contracts only

      select distinct currency_code into p_currency
      from icx_por_contract_references icxC
      where icxC.request_id=p_request_id
      and icxC.currency_code is not null;

      l_progress := 230;

exception
  when others then
    Debug('[get_global_supplier_currency-'||l_progress||'] '||SQLERRM);
--  Bug#2025348
    p_supplier := null;
    p_currency := null;
END;

--
-- Get the Number of Contract references that have passed/failed
-- during Validation
--
PROCEDURE get_contracts_pass_failed( p_request_id IN NUMBER,
                             p_succ_count OUT NOCOPY number,
                             p_failed_count OUT NOCOPY number)
IS
l_progress VARCHAR2(5) := '100';
BEGIN

    p_succ_count := 0;
    p_failed_count := 0;

    -- Get the Number of successful Contract references
    select count(0) into p_succ_count
    from icx_por_contract_references
    where error_message is null
    and request_id = p_request_id;

    l_progress := '110';

    -- Get the Number of Failed Contract references
    select count(0) into p_failed_count
    from icx_por_contract_references
    where error_message is not null
    and request_id = p_request_id;

    l_progress := '120';

EXCEPTION
  WHEN OTHERS then
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at ICX_POR_ITEM_UPLOAD.get_contracts_pass_failed(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
END;

--
-- Save the Failed Line for Contract reference section errors.
--
PROCEDURE save_failed_admin(p_request_id IN NUMBER,
                           p_line_number IN NUMBER,
                           p_buyer IN VARCHAR2,
                           p_contract_ref_num IN VARCHAR2
                           ) IS
l_progress VARCHAR2(5) := '100';
BEGIN

  IF p_buyer IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines
    (job_number, line_number, action, row_type, descriptor_key, descriptor_value)
    VALUES
    (p_request_id, p_line_number, 'SYNC', 'ADMIN', 'BUYER', p_buyer);
  END IF;

  l_progress := '110';

  IF p_contract_ref_num IS NOT NULL THEN
    INSERT INTO icx_por_failed_lines
    (job_number, line_number, action, row_type, descriptor_key, descriptor_value)
    VALUES
    (p_request_id, p_line_number, 'SYNC', 'ADMIN', 'CONTRACT_NUM', p_contract_ref_num);
  END IF;

  l_progress := '120';

EXCEPTION
  WHEN OTHERS then
      RAISE_APPLICATION_ERROR (-20000, 'Exception at ' ||
                     'ICX_POR_ITEM_UPLOAD.save_failed_admin' ||
                     '(ErrLoc = ' || l_progress ||') ' ||
                     'SQL Error : ' || SQLERRM);
END save_failed_admin;

-- Reject the Catalog
--   This is used only for Contract reference sections
--   When the Contract supplier/currency does not match with items section
--   the Catalog is rejected
--
PROCEDURE reject_catalog(p_request_id IN NUMBER,
                           p_line_type IN VARCHAR2,
                           p_descriptor_key IN VARCHAR2,
                           p_descriptor_val IN VARCHAR2,
                           p_error_message IN VARCHAR2
                           )
IS
l_progress VARCHAR2(5) := '100';
BEGIN
    l_progress  := '110';
    -- When a catalog is rejected, Dont show any other Failed Lines
    DELETE FROM icx_por_failed_lines where job_number = p_request_id;

    l_progress  := '120';
    -- Insert Buyer Reference
    INSERT INTO icx_por_failed_lines
       (job_number, line_number, action, row_type, descriptor_key, descriptor_value)
       --Bug#2729328
       --VALUES (p_request_id, 1, 'SYNC', p_line_type, p_descriptor_key, p_descriptor_key);
       VALUES (p_request_id, 1, 'SYNC', p_line_type, p_descriptor_key, p_descriptor_val);

    -- Delete all the Messages for the request_id#
    delete from icx_por_failed_line_messages
    where job_number = p_request_id;

    -- Save the Failed Line message now
    ICX_POR_ITEM_UPLOAD.save_failed_line_message(p_request_id,
                                                    1,
                                                    p_error_message);

EXCEPTION
  WHEN OTHERS then
      RAISE_APPLICATION_ERROR (-20000, 'Exception at ' ||
                     'ICX_POR_ITEM_UPLOAD.reject_catalog' ||
                     '(ErrLoc = ' || l_progress ||') ' ||
                     'SQL Error : ' || SQLERRM);
END reject_catalog;


-- Category_Change
PROCEDURE handle_category_change (p_action IN VARCHAR2) IS
  l_progress VARCHAR2(5) := '100';

  xLangArray   DBMS_SQL.VARCHAR2_TABLE;
  CURSOR langCsr IS
    SELECT language_code
    FROM fnd_languages
    WHERE installed_flag in ('B', 'I')
    AND language_code <> gJobLanguage;

BEGIN

  l_progress := '100';

  -- Fetch all the distinct category ids that have changed for the items
  -- in this batch.

  if ( gChangedCatItemIds.COUNT > 0 ) then
    icx_por_ext_utl.debug(icx_por_ext_utl.MUST_LEVEL, 'handle_category_change called with action:'||p_action
                          ||', gChangedCatItemIds.COUNT:'||to_char(gChangedCatItemIds.COUNT)
                          ||', gChangedOldCatIds.COUNT:'||to_char(gChangedOldCatIds.COUNT)
                          ||', gChangedNewCatIds.COUNT:'||to_char(gChangedNewCatIds.COUNT)
                          ||', gChangedCatActions.COUNT:'||to_char(gChangedCatActions.COUNT));
  end if;

  FORALL i in 1..gChangedCatItemIds.COUNT
    update icx_cat_ext_items_tlp set rt_category_id=gChangedNewCatIds(i),
        text_cat_attribute1 = null, text_cat_attribute2 = null, text_cat_attribute3 = null,
        text_cat_attribute4 = null, text_cat_attribute5 = null, text_cat_attribute6 = null,
        text_cat_attribute7 = null, text_cat_attribute8 = null, text_cat_attribute9 = null,
        text_cat_attribute10 = null, text_cat_attribute11 = null, text_cat_attribute12 = null,
        text_cat_attribute13 = null, text_cat_attribute14 = null, text_cat_attribute15 = null,
        text_cat_attribute16 = null, text_cat_attribute17 = null, text_cat_attribute18 = null,
        text_cat_attribute19 = null, text_cat_attribute20 = null, text_cat_attribute21 = null,
        text_cat_attribute22 = null, text_cat_attribute23 = null, text_cat_attribute24 = null,
        text_cat_attribute25 = null, text_cat_attribute26 = null, text_cat_attribute27 = null,
        text_cat_attribute28 = null, text_cat_attribute29 = null, text_cat_attribute30 = null,
        text_cat_attribute31 = null, text_cat_attribute32 = null, text_cat_attribute33 = null,
        text_cat_attribute34 = null, text_cat_attribute35 = null, text_cat_attribute36 = null,
        text_cat_attribute37 = null, text_cat_attribute38 = null, text_cat_attribute39 = null,
        text_cat_attribute40 = null, text_cat_attribute41 = null, text_cat_attribute42 = null,
        text_cat_attribute43 = null, text_cat_attribute44 = null, text_cat_attribute45 = null,
        text_cat_attribute46 = null, text_cat_attribute47 = null, text_cat_attribute48 = null,
        text_cat_attribute49 = null, text_cat_attribute50 = null,
        num_cat_attribute1 = null, num_cat_attribute2 = null, num_cat_attribute3 = null,
        num_cat_attribute4 = null, num_cat_attribute5 = null, num_cat_attribute6 = null,
        num_cat_attribute7 = null, num_cat_attribute8 = null, num_cat_attribute9 = null,
        num_cat_attribute10 = null, num_cat_attribute11 = null, num_cat_attribute12 = null,
        num_cat_attribute13 = null, num_cat_attribute14 = null, num_cat_attribute15 = null,
        num_cat_attribute16 = null, num_cat_attribute17 = null, num_cat_attribute18 = null,
        num_cat_attribute19 = null, num_cat_attribute20 = null, num_cat_attribute21 = null,
        num_cat_attribute22 = null, num_cat_attribute23 = null, num_cat_attribute24 = null,
        num_cat_attribute25 = null, num_cat_attribute26 = null, num_cat_attribute27 = null,
        num_cat_attribute28 = null, num_cat_attribute29 = null, num_cat_attribute30 = null,
        num_cat_attribute31 = null, num_cat_attribute32 = null, num_cat_attribute33 = null,
        num_cat_attribute34 = null, num_cat_attribute35 = null, num_cat_attribute36 = null,
        num_cat_attribute37 = null, num_cat_attribute38 = null, num_cat_attribute39 = null,
        num_cat_attribute40 = null, num_cat_attribute41 = null, num_cat_attribute42 = null,
        num_cat_attribute43 = null, num_cat_attribute44 = null, num_cat_attribute45 = null,
        num_cat_attribute46 = null, num_cat_attribute47 = null, num_cat_attribute48 = null,
        num_cat_attribute49 = null, num_cat_attribute50 = null,
        tl_text_cat_attribute1 = null, tl_text_cat_attribute2 = null, tl_text_cat_attribute3 = null,
        tl_text_cat_attribute4 = null, tl_text_cat_attribute5 = null, tl_text_cat_attribute6 = null,
        tl_text_cat_attribute7 = null, tl_text_cat_attribute8 = null, tl_text_cat_attribute9 = null,
        tl_text_cat_attribute10 = null, tl_text_cat_attribute11 = null, tl_text_cat_attribute12 = null,
        tl_text_cat_attribute13 = null, tl_text_cat_attribute14 = null, tl_text_cat_attribute15 = null,
        tl_text_cat_attribute16 = null, tl_text_cat_attribute17 = null, tl_text_cat_attribute18 = null,
        tl_text_cat_attribute19 = null, tl_text_cat_attribute20 = null, tl_text_cat_attribute21 = null,
        tl_text_cat_attribute22 = null, tl_text_cat_attribute23 = null, tl_text_cat_attribute24 = null,
        tl_text_cat_attribute25 = null, tl_text_cat_attribute26 = null, tl_text_cat_attribute27 = null,
        tl_text_cat_attribute28 = null, tl_text_cat_attribute29 = null, tl_text_cat_attribute30 = null,
        tl_text_cat_attribute31 = null, tl_text_cat_attribute32 = null, tl_text_cat_attribute33 = null,
        tl_text_cat_attribute34 = null, tl_text_cat_attribute35 = null, tl_text_cat_attribute36 = null,
        tl_text_cat_attribute37 = null, tl_text_cat_attribute38 = null, tl_text_cat_attribute39 = null,
        tl_text_cat_attribute40 = null, tl_text_cat_attribute41 = null, tl_text_cat_attribute42 = null,
        tl_text_cat_attribute43 = null, tl_text_cat_attribute44 = null, tl_text_cat_attribute45 = null,
        tl_text_cat_attribute46 = null, tl_text_cat_attribute47 = null, tl_text_cat_attribute48 = null,
        tl_text_cat_attribute49 = null, tl_text_cat_attribute50 = null
      where rt_category_id=gChangedOldCatIds(i)
      and rt_item_id=gChangedCatItemIds(i)
      and p_action=gChangedCatActions(i);

  OPEN langCsr;
  FETCH langCsr BULK COLLECT into xLangArray;
  CLOSE langCsr;

  l_progress := '150';

  -- When the category of an item is changed, we need to update the
  -- primary_category_name of the translated rows. We need to do this here
  -- since primary_category_name is not updated for the translated rows in
  -- build_root_sql() as primary_category_name is a translated attribute.
  FOR i in 1..xLangArray.COUNT LOOP
    FORALL j in 1..gChangedCatItemIds.COUNT
      update icx_cat_items_tlp
      set primary_category_name = (select category_name from icx_cat_categories_tl
                                   where rt_category_id = gChangedNewCatIds(j)
                                   and language = xLangArray(i))
      where rt_item_id = gChangedCatItemIds(j) and language = xLangArray(i);
  END LOOP;

  l_progress := '200';

EXCEPTION
  WHEN OTHERS then
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at ICX_POR_ITEM_UPLOAD.handle_category_change(ErrLoc = ' || l_progress ||') ' ||
            'SQL Error : ' || SQLERRM);
END handle_category_change;

END ICX_POR_ITEM_UPLOAD;

/
