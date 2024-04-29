--------------------------------------------------------
--  DDL for Package Body ICX_POR_CTX_SQL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_CTX_SQL_PKG" AS
-- $Header: ICXCTXB.pls 115.3 2004/03/31 21:56:26 vkartik ship $

/* Constructs the sql required to populate icx_por_ctx_tl
 - pCategoryId - Category Id, pass in 0 if constructing for the root attributes
 - pDescriptors - Table containing info about searchable descriptors
 - pWhereClause - Where clause to be appended to the end of the sql statements
 - pLanguage - Language to use
 - pMaxLength - The max length each ctx row should hold.  This is used in
                cases when we know each attribute is much shorter than it's
                max length and we want to pack more attributes into each row
 - pInsertSQL - Table containing SQL for processing new items for the loader
 - pUpdateSQL - Table containing SQL for processing existing items
   (Existing means it exists in icx_por_items_tl)
*/
PROCEDURE build_ctx_sql(pCategoryId IN NUMBER,
  pDescriptors IN DescriptorInfoTab, pWhereClause IN VARCHAR2,
  pLanguage IN VARCHAR2, pMaxLength IN NUMBER,
  pInsertSQL OUT NOCOPY SQLTab, pUpdateSQL OUT NOCOPY SQLTab) IS
  i PLS_INTEGER;
  v_insert_sql VARCHAR2(4000) := null;
  v_update_sql VARCHAR2(4000) := null;
  v_sql_count PLS_INTEGER := 0;
  v_insert_suffix VARCHAR2(4000) := null;
  v_update_suffix VARCHAR2(4000) := null;
  v_current_len PLS_INTEGER := 0;
  v_desc DescriptorInfo;
  v_insert_prefix VARCHAR2(4000) := null;
  v_update_prefix VARCHAR2(4000) := null;
  v_extra_update_suffix VARCHAR2(4000) := null;
  v_tbl_alias VARCHAR2(10) := null;
  v_stored_in_column VARCHAR2(2000) := null;
  v_upd_stored_in_column VARCHAR2(2000) := null;
  xErrLoc PLS_INTEGER := 100;
BEGIN
  pInsertSQL.DELETE;
  pUpdateSQL.DELETE;

  v_insert_prefix := 'INSERT INTO icx_cat_items_ctx_tlp (rt_item_id, language, sequence, ctx_desc) SELECT :p_item_id, :p_language, :p_sequence, null';

  -- OEX_IP_PORTING
  v_insert_suffix := ' FROM icx_cat_items_gt WHERE rowid = :p_rowid' ||
    ' AND :action_name = :p_system_action ';

  IF pLanguage IS NOT NULL THEN
    -- The follow is to quickly identify the rows that need to be processed
    -- if the batch contains multiple languages
    v_insert_suffix := v_insert_suffix || 'AND :p_language = :language_array';
  END IF;

  v_insert_sql := v_insert_prefix;

  v_update_prefix := 'INSERT INTO icx_cat_items_ctx_tlp (rt_item_id, language, sequence, ctx_desc) SELECT tl.rt_item_id, tl.language, :p_sequence, null';

  IF (pCategoryId > 0) THEN
    v_insert_suffix := v_insert_suffix ||
      ' AND :current_category_id = :p_category_id';
    v_update_suffix := ' FROM icx_cat_ext_items_tlp tl WHERE ' ||
      -- The following two are for use during bulk loading
      -- For regular use just bind in the same values for current_category_id
      -- and p_category_id, as well as action_name and p_system_action
      ' :current_category_id = :p_category_id ' ||
      'AND :action_name = :p_system_action ';

    IF pLanguage IS NOT NULL THEN
      -- The follow is to quickly identify the rows that need to be processed
      -- if the batch contains multiple languages
      v_update_suffix := v_update_suffix ||
        ' AND tl.language = :p_language AND :p_language = :language_array';
    END IF;

    v_extra_update_suffix := v_update_suffix;
  ELSE
    v_update_suffix := ' FROM icx_cat_items_tlp tl ' ||
      -- The following is for use during bulk loading
      -- For regular use just bind in the same values for action_name
      -- and p_system_action
      'WHERE :action_name = :p_system_action ';

    IF pLanguage IS NOT NULL THEN
      -- The follow is to quickly identify the rows that need to be processed
      -- if the batch contains multiple languages
      v_update_suffix := v_update_suffix ||
      ' AND tl.language = :p_language AND :p_language = :language_array';
    END IF;

    -- This is for the first SQL which needs to get category id and name
    v_extra_update_suffix := ' FROM icx_cat_items_tlp tl ' ||
      -- The following is for use during bulk loading
      -- For regular use just bind in the same values for action_name
      -- and p_system_action
      'WHERE :action_name = :p_system_action ';

    IF pLanguage IS NOT NULL THEN
      -- The follow is to quickly identify the rows that need to be processed
      -- if the batch contains multiple languages
      v_extra_update_suffix := v_extra_update_suffix ||
      ' AND tl.language = :p_language AND :p_language = :language_array';
    END IF;

  END IF;

  IF (pWhereClause IS NOT NULL) THEN
    v_update_suffix := v_update_suffix || ' ' || pWhereClause;
    v_extra_update_suffix := v_extra_update_suffix || ' ' || pWhereClause;
  END IF;

  v_update_sql := v_update_prefix;

  xErrLoc := 200;

  v_insert_sql := v_insert_sql || ' || ''<language>'' || language || ''</language>''';
  v_update_sql := v_update_sql || ' || ''<language>'' || tl.language || ''</language>''';

  FOR i IN 1..pDescriptors.COUNT LOOP
    xErrLoc := 200 + i;
    v_desc := pDescriptors(i);

    if(v_desc.stored_in_table = 'ICX_CAT_EXT_ITEMS_TLP' OR v_desc.stored_in_table = 'ICX_CAT_ITEMS_TLP') then
      v_tbl_alias := ITEMS_TLP_PREFIX;
    elsif (v_desc.stored_in_table = 'ICX_CAT_ITEMS_B') then
      v_tbl_alias := ITEMS_B_PREFIX;
    else
      v_tbl_alias := null;
    end if;

    v_stored_in_column := v_desc.stored_in_column;
    v_upd_stored_in_column := v_tbl_alias||'.'||v_desc.stored_in_column;

    IF (i = 1) THEN

      IF (pCategoryId = 0) THEN
        -- First sql includes supid, catid and catnm
        v_insert_sql := v_insert_sql || ' || ''<supid>'' || to_char(:p_supplier_id) || ''</supid><search_type>SUPPLIER INTERNAL</search_type><catid>leaf'' || :p_category_id || ''</catid><catnm>'' || :p_category_name || ''</catnm>''';
        v_update_sql := v_update_sql || ' || ''<supid>'' || to_char(tl.supplier_id) || ''</supid><search_type>'' || ';
        v_update_sql := v_update_sql || ' decode(tl.item_source_type,''BOTH'', ''SUPPLIER INTERNAL'', tl.item_source_type)||''</search_type><catid>leaf'' || tl.primary_category_id || ''</catid><catnm>'' || tl.primary_category_name || ''</catnm>''';

      END IF;

    END IF;

    IF (v_current_len + v_desc.descriptor_length > pMaxLength) THEN
      -- The current statement is at it's max length
      v_sql_count := v_sql_count + 1;

      IF (v_sql_count = 1) THEN
        pInsertSQL(v_sql_count) := v_insert_sql || v_insert_suffix;
        v_insert_sql := v_insert_prefix;

        -- First SQL, need to include extra stuff to get category name
        pUpdateSQL(v_sql_count) := v_update_sql || v_extra_update_suffix;
        v_update_sql := v_update_prefix;
        v_current_len := 0;
      ELSE
        pInsertSQL(v_sql_count) := v_insert_sql || v_insert_suffix;
        v_insert_sql := v_insert_prefix;
        pUpdateSQL(v_sql_count) := v_update_sql || v_update_suffix;
        v_update_sql := v_update_prefix;
        v_current_len := 0;
      END IF;

    END IF;

    xErrLoc := 10000+i;

    -- sosingha bug# replaced < > with whitespace while populating ctx column
    v_insert_sql := v_insert_sql || ' || ''<' ||
    -- to_char(v_desc.section_tag) || '>'' || ' || v_stored_in_column ||
       to_char(v_desc.section_tag) || '>'' || ' || 'replace(replace('|| v_stored_in_column || ',' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
       ' || ''</' || to_char(v_desc.section_tag) || '>''';

    v_update_sql := v_update_sql || ' || ''<' ||
       -- to_char(v_desc.section_tag) || '>'' || ' || v_upd_stored_in_column ||
       to_char(v_desc.section_tag) || '>'' || ' || 'replace(replace('|| v_upd_stored_in_column || ',' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
       ' || ''</' || to_char(v_desc.section_tag) || '>''';

    v_current_len := v_current_len + v_desc.descriptor_length;

    xErrLoc := 20000+i;
    IF (i = pDescriptors.COUNT) THEN
      v_sql_count := v_sql_count + 1;
      pInsertSQL(v_sql_count) := v_insert_sql || v_insert_suffix;

      IF (v_sql_count = 1) THEN
        -- First SQL, need to include extra stuff to get category name
        pUpdateSQL(v_sql_count) := v_update_sql || v_extra_update_suffix;
      ELSE
        pUpdateSQL(v_sql_count) := v_update_sql || v_update_suffix;
      END IF;

    END IF;

  END LOOP;

    xErrLoc := 30000;
  IF (pDescriptors.COUNT = 0) THEN
    -- No searchable descriptors, just store supid,catid and catname
    IF (pCategoryId = 0) THEN
        v_insert_sql := v_insert_sql || ' || ''<supid>'' || to_char(:p_supplier_id) || ''</supid><search_type>SUPPLIER INTERNAL</search_type><catid>leaf'' || :p_category_id || ''</catid><catnm>'' || :p_category_name || ''</catnm>''';
        v_update_sql := v_update_sql || ' || ''<supid>'' || to_char(tl.supplier_id) || ''</supid><search_type>'' || ';
        v_update_sql := v_update_sql ||' decode(tl.item_source_type,''BOTH'', ''SUPPLIER INTERNAL'', tl.item_source_type)||''</search_type><catid>leaf'' || tl.primary_category_id || ''</catid><catnm>'' || tl.primary_category_name || ''</catnm>''';


      v_sql_count := 1;
      pInsertSQL(v_sql_count) := v_insert_sql || v_insert_suffix;
      pUpdateSQL(v_sql_count) := v_update_sql || v_update_suffix;
    END IF;
  xErrLoc := 40000;

  END IF;

  xErrLoc := 50000;

  IF (pCategoryId = 0) THEN
    -- sto 10/23/01: Also populate two rows for the orgid section
    v_sql_count := v_sql_count + 1;
    pInsertSQL(v_sql_count) := v_insert_prefix || ' || ''<orgid>'' ' ||
      v_insert_suffix;
    pUpdateSQL(v_sql_count) := v_update_prefix || ' || ''<orgid>'' ' ||
      v_update_suffix;
    v_sql_count := v_sql_count + 1;
    pInsertSQL(v_sql_count) := v_insert_prefix || ' || ''</orgid>'' ' ||
      v_insert_suffix;
    pUpdateSQL(v_sql_count) := v_update_prefix || ' || ''</orgid>'' ' ||
      v_update_suffix;
  END IF;
  xErrLoc := 60000;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR (-20000,
    'Exception at ICX_POR_CTX_SQL_PKG.build_ctx_sql1('||xErrLoc||'), '||SQLERRM);
END build_ctx_sql;

/* Constructs the sql required to populate icx_por_ctx_tl
 - pCategoryId - Category Id, pass in 0 if constructing for the root attributes
 - pWhereClause - Where clause to be appended to the end of the sql statements
 - pLanguage - Language to use
 - pMaxLength - The max length each ctx row should hold.  This is used in
                cases when we know each attribute is much shorter than it's
                max length and we want to pack more attributes into each row
 - pInsertSQL - Table containing SQL for processing new items for the loader
 - pUpdateSQL - Table containing SQL for processing existing items
   (Existing means it exists in icx_por_items_tl)
*/
PROCEDURE build_ctx_sql(pCategoryId IN NUMBER, pWhereClause IN VARCHAR2,
  pLanguage IN VARCHAR2, pMaxLength IN NUMBER,
  pInsertSQL OUT NOCOPY SQLTab, pUpdateSQL OUT NOCOPY SQLTab) IS
  vDescInfoTab DescriptorInfoTab;
  vDesc DescriptorInfo;
  vCount PLS_INTEGER := 0;
  vSearchableCount PLS_INTEGER := 0;
  CURSOR get_descriptors(p_category_id IN NUMBER, p_language IN VARCHAR2) IS
    -- OEX_IP_PORTING: Only non pricing attributes are part of ctx.
    SELECT rt_descriptor_id, key, type, section_tag, searchable,
           stored_in_table, stored_in_column
    FROM icx_cat_descriptors_tl
    WHERE rt_category_id = p_category_id
    AND language = p_language
    AND stored_in_table <> 'ICX_CAT_ITEM_PRICES'
    order by rt_descriptor_id;
  xErrLoc PLS_INTEGER := 100;
  vLanguage FND_LANGUAGES.LANGUAGE_CODE%TYPE;
BEGIN
  IF pLanguage IS NULL THEN
    SELECT language_code INTO vLanguage
    FROM fnd_languages WHERE installed_flag = 'B';
  ELSE
    vLanguage := pLanguage;
  END IF;

  FOR rec IN get_descriptors(pCategoryId, vLanguage) LOOP
    vCount := vCount + 1;

    IF (rec.searchable = 1 OR rec.key = 'SELLABLE_ITEM') THEN
      vSearchableCount := vSearchableCount + 1;
      vDesc.descriptor_id := rec.rt_descriptor_id;
      vDesc.descriptor_key := rec.key;
      vDesc.descriptor_index := vCount;
      vDesc.descriptor_type := rec.type;
      vDesc.section_tag := rec.section_tag;
      vDesc.stored_in_table := rec.stored_in_table;
      vDesc.stored_in_column := rec.stored_in_column;

      IF (rec.type IN (0,2)) THEN
        IF ((rec.key IN ('DESCRIPTION', 'LONG_DESCRIPTION', 'ALIAS', 'SUPPLIER', 'MANUFACTURER')) AND pCategoryId = 0) THEN
          vDesc.descriptor_length := 2000;
        ELSIF (rec.key = 'SELLABLE_ITEM') THEN
          vDesc.descriptor_length := 20;
        ELSE
          vDesc.descriptor_length := 700;
        END IF;
      ELSE
        vDesc.descriptor_length := 100;
      END IF;

      vDescInfoTab(vSearchableCount) := vDesc;
    END IF;

  END LOOP;

--  IF (vDescInfoTab.COUNT > 0) THEN
    xErrLoc := 200;
    build_ctx_sql(pCategoryId, vDescInfoTab, pWhereClause, pLanguage,
      pMaxLength, pInsertSQL, pUpdateSQL);
--  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR (-20000,
    'Exception at ICX_POR_CTX_SQL_PKG.build_ctx_sql2('||xErrLoc||'), '||SQLERRM );
END build_ctx_sql;

/* Constructs the sql required to populate icx_por_ctx_tl
 - pCategoryId - Category Id, pass in 0 if constructing for the root attributes
 - pWhereClause - Where clause to be appended to the end of the sql statements
 - pLanguage - Language to use
 - pInsertSQL - Table containing SQL for processing new items for the loader
 - pUpdateSQL - Table containing SQL for processing existing items
   (Existing means it exists in icx_por_items_tl)
*/
PROCEDURE build_ctx_sql(pCategoryId IN NUMBER, pWhereClause IN VARCHAR2,
  pLanguage IN VARCHAR2, pInsertSQL OUT NOCOPY SQLTab, pUpdateSQL OUT NOCOPY SQLTab) IS
BEGIN
  build_ctx_sql(pCategoryId, pWhereClause, pLanguage, DEFAULT_MAX_LENGTH,
    pInsertSQL, pUpdateSQL);

END build_ctx_sql;

/* Constructs the sql required to populate icx_por_ctx_tl
 - pCategoryId - Category Id, pass in 0 if constructing for the root attributes
 - pWhereClause - Where clause to be appended to the end of the sql statements
 - pLanguage - Language to use
 - pInsertSQL - Table containing SQL for processing new items for the loader
 - pUpdateSQL - Table containing SQL for processing existing items
   (Existing means it exists in icx_por_items_tl)
*/
PROCEDURE build_ctx_sql(pCategoryId IN NUMBER, pWhereClause IN VARCHAR2,
  pInsertSQL OUT NOCOPY SQLTab, pUpdateSQL OUT NOCOPY SQLTab) IS
BEGIN
  build_ctx_sql(pCategoryId, pWhereClause, null, DEFAULT_MAX_LENGTH,
    pInsertSQL, pUpdateSQL);
END build_ctx_sql;

END ICX_POR_CTX_SQL_PKG;

/
