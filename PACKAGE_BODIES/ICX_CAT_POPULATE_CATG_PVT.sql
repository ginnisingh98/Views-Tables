--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_CATG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_CATG_PVT" AS
/* $Header: ICXVPPCB.pls 120.3 2006/06/26 23:22:34 sbgeorge noship $*/

-- Constants
G_PKG_NAME              CONSTANT VARCHAR2(30) :='ICX_CAT_POPULATE_CATG_PVT';
TYPE g_item_csr_type    IS REF CURSOR;

gTotalRowCount          PLS_INTEGER:= 0;

-- Insert into icx_por_category_data_sources and icx_por_category_order_map
gInsMapRtCategoryIdTbl  DBMS_SQL.NUMBER_TABLE;
gInsMapCategoryKeyTbl   DBMS_SQL.VARCHAR2_TABLE;
gInsMapLanguageTbl      DBMS_SQL.VARCHAR2_TABLE;

-- Insert into icx_cat_categories_tl
gInsRtCategoryIdTbl     DBMS_SQL.NUMBER_TABLE;
gInsCategoryKeyTbl      DBMS_SQL.VARCHAR2_TABLE;
gInsCategoryNameTbl     DBMS_SQL.VARCHAR2_TABLE;
gInsLanguageTbl         DBMS_SQL.VARCHAR2_TABLE;
gInsSourceLangTbl       DBMS_SQL.VARCHAR2_TABLE;

-- Insert items into icx_cat_items_ctx_hdrs_tlp and icx_cat_items_ctx_dtls_tlp tables
gInsPOCategoryIdTbl     DBMS_SQL.NUMBER_TABLE;

-- Update icx_cat_categories_tl
gUpdRtCategoryIdTbl     DBMS_SQL.NUMBER_TABLE;
gUpdCategoryNameTbl     DBMS_SQL.VARCHAR2_TABLE;
gUpdLanguageTbl         DBMS_SQL.VARCHAR2_TABLE;
gUpdSourceLangTbl       DBMS_SQL.VARCHAR2_TABLE;

-- Delete from icx_cat_items_ctx_hdrs_tlp and icx_cat_items_ctx_dtls_tlp tables
gDelPoCategoryIdTbl     DBMS_SQL.NUMBER_TABLE;

PROCEDURE clearTables
(       p_action_mode   IN      VARCHAR2
)
IS
BEGIN
  IF (p_action_mode IN ('ALL', 'INSERT_MAPPING')) THEN
    -- Insert into icx_por_category_data_sources and icx_por_category_order_map
    gInsMapRtCategoryIdTbl.DELETE;
    gInsMapCategoryKeyTbl.DELETE;
    gInsMapLanguageTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'INSERT_CATEGORY')) THEN
    -- Insert into icx_cat_categories_tl
    gInsRtCategoryIdTbl.DELETE;
    gInsCategoryKeyTbl.DELETE;
    gInsCategoryNameTbl.DELETE;
    gInsLanguageTbl.DELETE;
    gInsSourceLangTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'INSERT_ITEM_CATEGORY')) THEN
    -- Insert items into icx_cat_items_ctx_hdrs_tlp and icx_cat_items_ctx_dtls_tlp tables
    gInsPOCategoryIdTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'UPDATE_CATEGORY')) THEN
    -- Update icx_cat_categories_tl
    gUpdRtCategoryIdTbl.DELETE;
    gUpdCategoryNameTbl.DELETE;
    gUpdLanguageTbl.DELETE;
    gUpdSourceLangTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'DELETE_CATEGORY')) THEN
    -- Delete from icx_cat_items_ctx_hdrs_tlp and icx_cat_items_ctx_dtls_tlp tables
    gDelPoCategoryIdTbl.DELETE;
  END IF;

END clearTables;

/* Function is for debugging only */
FUNCTION logPLSQLTableRow
(       p_index         IN      NUMBER          ,
        p_action_mode   IN      VARCHAR2
)
  RETURN VARCHAR2
IS
  l_string VARCHAR2(4000);
BEGIN
  l_string := 'logPLSQLTableRow('||p_action_mode||')['||p_index||']--';
  IF (p_action_mode = 'INSERT_MAPPING') THEN
    -- Insert into icx_por_category_data_sources and icx_por_category_order_map
    l_string := l_string || ' gInsMapRtCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsMapRtCategoryIdTbl, p_index) || ', ';
    l_string := l_string || ' gInsMapCategoryKeyTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsMapCategoryKeyTbl, p_index) || ', ';
    l_string := l_string || ' gInsMapLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsMapLanguageTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'INSERT_CATEGORY') THEN
    -- Insert into icx_cat_categories_tl
    l_string := l_string || ' gInsRtCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsRtCategoryIdTbl, p_index) || ', ';
    l_string := l_string || ' gInsCategoryKeyTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsCategoryKeyTbl, p_index) || ', ';
    l_string := l_string || ' gInsCategoryNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsCategoryNameTbl, p_index) || ', ';
    l_string := l_string || ' gInsLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsLanguageTbl, p_index) || ', ';
    l_string := l_string || ' gInsSourceLangTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsSourceLangTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode IN ('ALL', 'INSERT_ITEM_CATEGORY')) THEN
    -- Insert items into icx_cat_items_ctx_hdrs_tlp and icx_cat_items_ctx_dtls_tlp tables
    l_string := l_string || ' gInsPOCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsPOCategoryIdTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'UPDATE_CATEGORY') THEN
    -- Update icx_cat_categories_tl
    l_string := l_string || ' gUpdRtCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUpdRtCategoryIdTbl, p_index) || ', ';
    l_string := l_string || ' gUpdCategoryNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUpdCategoryNameTbl, p_index) || ', ';
    l_string := l_string || ' gUpdLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUpdLanguageTbl, p_index) || ', ';
    l_string := l_string || ' gUpdSourceLangTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUpdSourceLangTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'DELETE_CATEGORY') THEN
    -- Delete from icx_cat_items_ctx_hdrs_tlp and icx_cat_items_ctx_dtls_tlp tables
    l_string := l_string || ' gDelPoCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDelPoCategoryIdTbl, p_index) || ', ';
  END IF;

  RETURN l_string;

END logPLSQLTableRow;

PROCEDURE logPLSQLTableRow
(       p_api_name      IN      VARCHAR2        ,
        p_log_level     IN      NUMBER          ,
        p_index         IN      NUMBER          ,
        p_action_mode   IN      VARCHAR2
)
IS
  l_log_string  VARCHAR2(4000);
  l_err_loc     PLS_INTEGER;
  l_module_name VARCHAR2(80);
BEGIN
  l_err_loc := 100;
  IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_err_loc := 200;
    l_module_name := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, p_api_name);

    l_err_loc := 300;
    l_log_string := 'logPLSQLTableRow('||p_action_mode||')['||p_index||']--';
    FND_LOG.string(p_log_level, l_module_name, l_log_string);

    l_err_loc := 400;
    IF (p_action_mode = 'INSERT_MAPPING') THEN
      l_err_loc := 500;
      -- Insert into icx_por_category_data_sources and icx_por_category_order_map
      l_log_string := ' gInsMapRtCategoryIdTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsMapRtCategoryIdTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gInsMapCategoryKeyTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsMapCategoryKeyTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gInsMapLanguageTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsMapLanguageTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);
    END IF;

    l_err_loc := 600;

    IF (p_action_mode = 'INSERT_CATEGORY') THEN
      l_err_loc := 700;
      -- Insert into icx_cat_categories_tl
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gInsRtCategoryIdTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsRtCategoryIdTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gInsCategoryKeyTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsCategoryKeyTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gInsCategoryNameTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsCategoryNameTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gInsLanguageTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsLanguageTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gInsSourceLangTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsSourceLangTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);
    END IF;

    l_err_loc := 800;

    IF (p_action_mode = 'INSERT_ITEM_CATEGORY') THEN
      l_err_loc := 900;
      -- Insert items into icx_cat_items_ctx_hdrs_tlp and icx_cat_items_ctx_dtls_tlp tables
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gInsPOCategoryIdTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gInsPOCategoryIdTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);
    END IF;

    l_err_loc := 900;

    IF (p_action_mode = 'UPDATE_CATEGORY') THEN
      l_err_loc := 1000;
      -- Update icx_cat_categories_tl
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUpdRtCategoryIdTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUpdRtCategoryIdTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUpdCategoryNameTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUpdCategoryNameTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUpdLanguageTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUpdLanguageTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gUpdSourceLangTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gUpdSourceLangTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);
    END IF;

    l_err_loc := 1100;

    IF (p_action_mode = 'DELETE_CATEGORY') THEN
      l_err_loc := 1200;
      -- Delete from icx_cat_items_ctx_hdrs_tlp and icx_cat_items_ctx_dtls_tlp tables
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDelPoCategoryIdTbl['||p_index||']: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDelPoCategoryIdTbl, p_index) || ', ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);
    END IF;

    l_err_loc := 1300;
  END IF;

END logPLSQLTableRow;

PROCEDURE addCategories
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'addCategories';
  l_err_loc             PLS_INTEGER;
  l_action_mode         VARCHAR2(80);
BEGIN
    l_err_loc := 100;
    l_action_mode := 'INSERT_CATEGORY';
    -- Insert into icx_cat_categories_tl
    FORALL i IN 1..gInsRtCategoryIdTbl.COUNT
      INSERT INTO icx_cat_categories_tl(
        rt_category_id, category_name, key, title, type, language,
        source_lang, upper_category_name, upper_key, section_map,
        last_update_login, last_updated_by, last_update_date,
        created_by, creation_date, request_id,
        program_application_id, program_id, program_login_id)
      VALUES(gInsRtCategoryIdTbl(i), gInsCategoryNameTbl(i),
             gInsCategoryKeyTbl(i), 'Oracle', 2,
             gInsLanguageTbl(i), gInsSourceLangTbl(i),
             upper(gInsCategoryNameTbl(i)), upper(gInsCategoryKeyTbl(i)),
             rpad('0', 300, 0),
             ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
             ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate, ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
             ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id, ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id, ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id);

    l_err_loc := 200;
    IF (gInsRtCategoryIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows inserted into categories_tl:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 300;
    clearTables(l_action_mode);

    l_err_loc := 400;
    l_action_mode := 'INSERT_MAPPING';
    -- Insert into icx_por_category_data_sources
    FORALL i in 1..gInsMapRtCategoryIdTbl.COUNT
      INSERT INTO icx_por_category_data_sources (
        rt_category_id, category_key, external_source, external_source_key,
        last_update_login, last_updated_by, last_update_date,
        created_by, creation_date, request_id,
        program_application_id, program_id)
      SELECT rt_category_id, key, 'Oracle', key,
             ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
             ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate, ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
             ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id, ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id
      FROM   icx_cat_categories_tl
      WHERE  rt_category_id = gInsMapRtCategoryIdTbl(i)
      AND    language = gInsMapLanguageTbl(i)
      AND    NOT EXISTS (SELECT 1
                         FROM   icx_por_category_data_sources
                         WHERE  external_source = 'Oracle'
                         AND    external_source_key = key);

    l_err_loc := 500;
    IF (gInsMapRtCategoryIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows inserted into category_data_sources:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 600;
    -- Insert into icx_por_category_order_map
    FORALL i IN 1..gInsMapRtCategoryIdTbl.COUNT
      INSERT INTO icx_por_category_order_map (
        rt_category_id, external_source, external_source_key,
        last_update_login, last_updated_by, last_update_date,
        created_by, creation_date)
      VALUES(gInsMapRtCategoryIdTbl(i), 'Oracle', gInsMapCategoryKeyTbl(i),
             ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
             ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate);

    l_err_loc := 700;
    IF (gInsMapRtCategoryIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows inserted into category_order_map:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 800;
    clearTables(l_action_mode);

    l_err_loc := 900;
EXCEPTION
  WHEN OTHERS THEN
    logPLSQLTableRow(l_api_name, FND_LOG.LEVEL_UNEXPECTED, SQL%ROWCOUNT+1, l_action_mode);
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END addCategories;

PROCEDURE addItemCategories
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'addItemCategories';
  l_err_loc             PLS_INTEGER;
  l_action_mode         VARCHAR2(80);
BEGIN
    l_err_loc := 100;
    l_action_mode := 'INSERT_ITEM_CATEGORY';
    -- If the category was added to the valid cats after assigning master items to the category
    -- Or if the category was re-activated
    -- then addItemCategories should also take care of populating the master items for the category.
    IF ( gInsPOCategoryIdTbl.COUNT > 0 ) THEN
      l_err_loc := 200;
      ICX_CAT_POPULATE_MI_PVT.populateCategoryItems(gInsPOCategoryIdTbl);
    END IF;

    l_err_loc := 300;
    clearTables(l_action_mode);

    l_err_loc := 400;
EXCEPTION
  WHEN OTHERS THEN
    logPLSQLTableRow(l_api_name, FND_LOG.LEVEL_UNEXPECTED, SQL%ROWCOUNT+1, l_action_mode);
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END addItemCategories;

-- Call this one when category name is updated from ECM UI.
PROCEDURE updateCategories
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'updateCategories';
  l_continue            BOOLEAN := TRUE;
  l_rowid_tbl           DBMS_SQL.UROWID_TABLE;
  l_err_loc             PLS_INTEGER;
  l_action_mode         VARCHAR2(80);
  l_searchable          NUMBER;
  l_section_tag         NUMBER;
  l_row_count           PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_action_mode := 'UPDATE_CATEGORY';

  l_err_loc := 200;
  FOR i IN 1..gUpdRtCategoryIdTbl.COUNT LOOP
    l_continue := TRUE;
    l_err_loc := 300;
    WHILE l_continue LOOP
      l_err_loc := 400;
      l_rowid_tbl.DELETE;

      l_err_loc := 500;
      UPDATE icx_cat_items_ctx_hdrs_tlp
      SET ctx_desc = null,
          ip_category_name = gUpdCategoryNameTbl(i),
          last_update_login = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
          last_updated_by = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
          last_update_date = sysdate,
          internal_request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
          request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
          program_application_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
          program_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
          program_login_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id
      WHERE ip_category_id = gUpdRtCategoryIdTbl(i)
      AND   language = gUpdLanguageTbl(i)
      AND   ip_category_name <> gUpdCategoryNameTbl(i)
      AND   rownum <= ICX_CAT_UTIL_PVT.g_batch_size
      RETURNING rowid BULK COLLECT INTO l_rowid_tbl;

      l_err_loc := 600;
      l_row_count := SQL%ROWCOUNT;
      IF (l_row_count = 0) THEN
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'No rows updated in icx_cat_ctx_hdrs_tlp for category rename');
        END IF;
        EXIT;
      ELSIF (l_row_count < ICX_CAT_UTIL_PVT.g_batch_size) THEN
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Num. of rows updated in icx_cat_ctx_hdrs_tlp for category rename:' ||
              l_row_count);
        END IF;
        l_err_loc := 700;
        l_continue := FALSE;
      END IF;

      l_err_loc := 800;
      IF (l_searchable IS NULL) THEN
        l_err_loc := 900;
        ICX_CAT_BUILD_CTX_SQL_PVT.checkIfAttributeIsSrchble
            ('SHOPPING_CATEGORY', l_searchable, l_section_tag);
      END IF;

      l_err_loc := 1000;
      IF (l_searchable = 1) THEN
        FORALL j IN 1..l_rowid_tbl.COUNT
          UPDATE icx_cat_items_ctx_dtls_tlp dtls
          SET ctx_desc = (SELECT '<' ||to_char(l_section_tag) ||'>' ||
                                 gUpdCategoryNameTbl(i) || '</' ||to_char(l_section_tag) ||'>'
                          FROM icx_cat_items_ctx_hdrs_tlp hdrs
                          WHERE hdrs.rowid = l_rowid_tbl(j)
                          AND hdrs.po_line_id = dtls.po_line_id
                          AND hdrs.req_template_name = dtls.req_template_name
                          AND hdrs.req_template_line_num = dtls.req_template_line_num
                          AND hdrs.inventory_item_id = dtls.inventory_item_id
                          AND hdrs.org_id = dtls.org_id
                          AND hdrs.language = dtls.language)
          WHERE sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForShoppingCategoryRow
          AND EXISTS ( SELECT 'x' FROM icx_cat_items_ctx_hdrs_tlp hdrs
                       WHERE hdrs.po_line_id = dtls.po_line_id
                       AND hdrs.req_template_name = dtls.req_template_name
                       AND hdrs.req_template_line_num = dtls.req_template_line_num
                       AND hdrs.inventory_item_id = dtls.inventory_item_id
                       AND hdrs.org_id = dtls.org_id
                       AND hdrs.language = dtls.language
                       AND hdrs.rowid = l_rowid_tbl(j) );

        IF (l_rowid_tbl.COUNT > 0) THEN
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Num. of rows updated in icx_cat_ctx_dtls_tlp for category rename:' ||
                SQL%ROWCOUNT);
          END IF;
        END IF;
      ELSE
        l_err_loc := 1200;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Shopping Category attribute is not searchable, ' ||
              'so no changes needed in icx_cat_items_ctx_dtls_tlp; ' ||
              'l_searchable:' || l_searchable || ', l_section_tag:' || l_section_tag );
        END IF;
      END IF; -- IF (l_searchable = 1) THEN

      l_err_loc := 1100;
      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        COMMIT;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
               ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Commit done.');
        END IF;
      ELSE
        l_err_loc := 1200;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done.');
        END IF;
      END IF;
    END LOOP;
    l_err_loc := 1300;
  END LOOP;

  l_err_loc := 1400;
  -- Update icx_cat_categories_tl
  FORALL i IN 1..gUpdRtCategoryIdTbl.COUNT
    UPDATE icx_cat_categories_tl
      SET  category_name = gUpdCategoryNameTbl(i),
           upper_category_name = upper(gUpdCategoryNameTbl(i)),
           source_lang = gUpdSourceLangTbl(i),
           last_update_login = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
           last_updated_by = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
           last_update_date = sysdate,
           request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
           program_application_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
           program_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
           program_login_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id
     WHERE rt_category_id = gUpdRtCategoryIdTbl(i)
       AND language = gUpdLanguageTbl(i);

  l_err_loc := 1500;
  IF (gUpdRtCategoryIdTbl.COUNT > 0) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Num. of rows updated in icx_cat_categories_tl:' ||SQL%ROWCOUNT);
    END IF;
  END IF;

  l_err_loc := 1600;
  clearTables(l_action_mode);
EXCEPTION
  WHEN OTHERS THEN
    logPLSQLTableRow(l_api_name, FND_LOG.LEVEL_UNEXPECTED, SQL%ROWCOUNT+1, l_action_mode);
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END updateCategories;

-- Call this one when category is deleted from ECM UI.
PROCEDURE deleteCategories
IS

  l_api_name                    CONSTANT VARCHAR2(30)   := 'deleteCategories';
  l_continue                    BOOLEAN := TRUE;
  l_po_line_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_req_template_name_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_req_template_line_num_tbl   DBMS_SQL.NUMBER_TABLE;
  l_inventory_item_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_err_loc                     PLS_INTEGER;
  l_action_mode                 VARCHAR2(80);
  l_row_count                   PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_action_mode := 'DELETE_CATEGORY';
  -- When a category is deleted / is no longer active,
  -- then we only delete the master items that are under the po category
  -- and not delete the ip category, mappings and from hierarchy
  -- because we should still be able to update the existing document lines
  -- that existed in the category using pdoi.
  -- The user cannot create new lines in the
  -- category, which will be validated during pdoi and online doc creation.

  FOR i IN 1..gDelPoCategoryIdTbl.COUNT LOOP
    l_err_loc := 200;
    l_continue := TRUE;
    WHILE l_continue LOOP
      l_err_loc := 300;
      l_po_line_id_tbl.DELETE;
      l_req_template_name_tbl.DELETE;
      l_req_template_line_num_tbl.DELETE;
      l_inventory_item_id_tbl.DELETE;
      l_org_id_tbl.DELETE;
      l_language_tbl.DELETE;

      l_err_loc := 400;
      -- Category deletion, in R12 we only delete the master items
      DELETE FROM icx_cat_items_ctx_hdrs_tlp
      WHERE  po_category_id = gDelPoCategoryIdTbl(i)
      AND    source_type = 'MASTER_ITEM'
      AND    rownum <= ICX_CAT_UTIL_PVT.g_batch_size
      RETURNING po_line_id, req_template_name, req_template_line_num,
                inventory_item_id, org_id, language
      BULK COLLECT INTO l_po_line_id_tbl, l_req_template_name_tbl, l_req_template_line_num_tbl,
                l_inventory_item_id_tbl, l_org_id_tbl, l_language_tbl;

      l_err_loc := 500;
      l_row_count := SQL%ROWCOUNT;
      IF (l_row_count < ICX_CAT_UTIL_PVT.g_batch_size) THEN
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Num. of rows deleted from icx_cat_ctx_hdrs_tlp for category delete:' ||
              l_row_count);
        END IF;
        l_continue := FALSE;
      END IF;

      l_err_loc := 600;
      FORALL j IN 1..l_po_line_id_tbl.COUNT
        DELETE FROM icx_cat_items_ctx_dtls_tlp
        WHERE po_line_id = l_po_line_id_tbl(j)
        AND req_template_name = l_req_template_name_tbl(j)
        AND req_template_line_num = l_req_template_line_num_tbl(j)
        AND inventory_item_id = l_inventory_item_id_tbl(j)
        AND org_id = l_org_id_tbl(j)
        AND language = l_language_tbl(j);

      IF (l_po_line_id_tbl.COUNT > 0) THEN
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Num. of rows delete from icx_cat_ctx_dtls_tlp for category delete:' ||
              SQL%ROWCOUNT);
        END IF;
      END IF;

      l_err_loc := 700;
      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        COMMIT;
        l_err_loc := 800;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit done. after deleting items for the category');
        END IF;
      ELSE
        l_err_loc := 900;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done. after deleting items for the category');
        END IF;
      END IF;
    END LOOP;
  END LOOP;

  l_err_loc := 1000;
  clearTables(l_action_mode);
EXCEPTION
  WHEN OTHERS THEN
    logPLSQLTableRow(l_api_name, FND_LOG.LEVEL_UNEXPECTED, SQL%ROWCOUNT+1, l_action_mode);
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END deleteCategories;

PROCEDURE populateCategoryTables
(       p_mode          IN      VARCHAR2
)
IS
  l_err_loc             PLS_INTEGER;
  l_api_name            CONSTANT VARCHAR2(30)   := 'populateCategoryTables';
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Enter populateCategoryTables(' || p_mode ||')gTotalRowCount: ' || gTotalRowCount);
  END IF;

  l_err_loc := 200;
  IF (p_mode = 'OUTLOOP' OR gTotalRowCount >= ICX_CAT_UTIL_PVT.g_batch_size) THEN
    l_err_loc := 300;
    gTotalRowCount := 0;

    l_err_loc := 400;
    IF (gInsRtCategoryIdTbl.COUNT > 0) THEN
      addCategories;
    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            ' No category insert done.');
      END IF;
    END IF;

    l_err_loc := 400;
    IF (gInsPOCategoryIdTbl.COUNT > 0) THEN
      addItemCategories;
    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            ' addItemCategories not called.');
      END IF;
    END IF;

    l_err_loc := 500;
    IF (gUpdRtCategoryIdTbl.COUNT > 0) THEN
      updateCategories;
    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            ' No category update done.');
      END IF;
    END IF;

    l_err_loc := 600;
    IF (gDelPoCategoryIdTbl.COUNT > 0) THEN
      deleteCategories;
    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            ' No category delete done.');
      END IF;
    END IF;

    l_err_loc := 700;
    IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
      COMMIT;
      l_err_loc := 800;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit done.');
      END IF;
    ELSE
      l_err_loc := 900;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit not done.');
      END IF;
    END IF;
    l_err_loc := 1100;

  END IF; --(p_mode = 'OUTLOOP' OR gTotalRowCount >= ICX_CAT_UTIL_PVT.g_batch_size)
  l_err_loc := 1200;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateCategoryTables;

FUNCTION validateCategoryName
(       p_rt_category_id        IN      NUMBER  ,
        p_category_name         IN      VARCHAR2
)
  RETURN BOOLEAN
IS
  l_category_name_is_valid      BOOLEAN;
  l_num_val                     PLS_INTEGER;
BEGIN
  IF (p_rt_category_id IS NULL) THEN
    SELECT count(1)
    INTO l_num_val
    FROM icx_cat_categories_tl
    WHERE upper_category_name = UPPER(p_category_name);
  ELSE
    SELECT count(1)
    INTO l_num_val
    FROM icx_cat_categories_tl
    WHERE upper_category_name = UPPER(p_category_name)
    AND rt_category_id <> p_rt_category_id;
  END IF;

  IF (l_num_val > 0) THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END validateCategoryName;

PROCEDURE processCategory
(       p_catg_csr      IN      g_item_csr_type
)
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'processCategory';
  l_err_loc                     PLS_INTEGER;
  l_batch_count                 PLS_INTEGER;
  l_row_count                   PLS_INTEGER;
  l_category_status             PLS_INTEGER;
  l_rt_category_id              NUMBER;
  l_prev_category_key           NUMBER := -1;
  l_prev_rt_category_id         NUMBER := -1;
  l_prev_category_name          mtl_categories_tl.description%TYPE := '-1';
  l_index                       PLS_INTEGER;
  l_category_name_is_valid      BOOLEAN := FALSE;

  ----- Start of declaring columns selected in the cursor -----
  l_mtl_category_id_tbl         DBMS_SQL.NUMBER_TABLE;
  l_mtl_category_name_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_mtl_language_tbl            DBMS_SQL.VARCHAR2_TABLE;
  l_mtl_source_lang_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_rt_category_id_tbl          DBMS_SQL.NUMBER_TABLE;
  l_old_category_name_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_end_date_active_tbl         DBMS_SQL.DATE_TABLE;
  l_disable_date_tbl            DBMS_SQL.DATE_TABLE;
  l_system_date_tbl             DBMS_SQL.DATE_TABLE;

  ------ End of declaring columns selected in the cursor ------

BEGIN
  l_err_loc := 100;
  l_batch_count := 0;
  l_row_count := 0;
  LOOP
    l_err_loc := 200;
    l_mtl_category_id_tbl.DELETE;
    l_mtl_category_name_tbl.DELETE;
    l_mtl_language_tbl.DELETE;
    l_mtl_source_lang_tbl.DELETE;
    l_rt_category_id_tbl.DELETE;
    l_old_category_name_tbl.DELETE;
    l_end_date_active_tbl.DELETE;
    l_disable_date_tbl.DELETE;
    l_system_date_tbl.DELETE;

      l_err_loc := 300;
      FETCH p_catg_csr BULK COLLECT INTO
          l_mtl_category_id_tbl, l_mtl_category_name_tbl, l_mtl_language_tbl,
          l_mtl_source_lang_tbl, l_rt_category_id_tbl, l_old_category_name_tbl,
          l_end_date_active_tbl, l_disable_date_tbl, l_system_date_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 400;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows fetched: ' || to_char(l_mtl_category_id_tbl.COUNT));
      END IF;

      l_err_loc := 500;
      EXIT WHEN l_mtl_category_id_tbl.COUNT = 0;

      l_err_loc := 600;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 700;
      l_row_count := l_row_count + l_mtl_category_id_tbl.COUNT;

      FOR i in 1..l_mtl_category_id_tbl.COUNT LOOP
        l_err_loc := 800;
        -- First get the status of the current Category line
        l_category_status := ICX_CAT_POPULATE_STATUS_PVT.getCategoryStatus
                              (l_end_date_active_tbl(i), l_disable_date_tbl(i), l_system_date_tbl(i));

        l_err_loc := 900;
        IF (l_category_status = ICX_CAT_POPULATE_STATUS_PVT.VALID_FOR_POPULATE) THEN
          l_err_loc := 1000;
          -- Check for the category name uniqueness in ip
          IF (l_prev_category_key <> l_mtl_category_id_tbl(i) OR
              l_prev_category_name <> l_mtl_category_name_tbl(i))
          THEN
            l_category_name_is_valid :=
            validateCategoryName(l_rt_category_id_tbl(i), l_mtl_category_name_tbl(i));

            IF (NOT l_category_name_is_valid) THEN
              IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                    ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                    'Row, with l_mtl_category_id_tbl:' || l_mtl_category_id_tbl(i) ||
                    ', l_rt_category_id_tbl:' || l_rt_category_id_tbl(i) ||
                    ', l_mtl_category_name_tbl:' || l_mtl_category_name_tbl(i) ||
                    ', l_old_category_name_tbl:' || l_old_category_name_tbl(i) ||
                    '; will not be processed as Category name already exists in IP');
              END IF;
            END IF;
          END IF;

          IF (l_rt_category_id_tbl(i) IS NULL) THEN
            -- Get the next rt_category_id from the sequence only once for all the language rows of a category
            IF (l_prev_category_key = l_mtl_category_id_tbl(i)) THEN
              l_err_loc := 1100;
              l_rt_category_id := l_prev_rt_category_id;
            ELSE
              l_err_loc := 1200;
              SELECT icx_por_categoryid.nextval
              INTO l_rt_category_id
              FROM dual;

              l_err_loc := 1300;
              -- The pl/sql table used to create mappings.  Need only one row for a language
              -- the mapping rows will be populated only if this was a create category action
              IF (g_DML_TYPE = ICX_CAT_POPULATE_CATG_PVT.g_DML_INSERT_TYPE AND
                  g_auto_create_shop_catg = 'Y' AND
                  l_category_name_is_valid)
              THEN
                l_err_loc := 1400;
                gTotalRowCount := gTotalRowCount + 2;
                l_index := gInsMapRtCategoryIdTbl.COUNT + 1;
                gInsMapRtCategoryIdTbl(l_index) := l_rt_category_id;
                gInsMapCategoryKeyTbl(l_index) := to_char(l_mtl_category_id_tbl(i));
                gInsMapLanguageTbl(l_index) := l_mtl_language_tbl(i);
              END IF;

              gTotalRowCount := gTotalRowCount + 1;
              l_index := gInsPOCategoryIdTbl.COUNT + 1;
              gInsPOCategoryIdTbl(l_index) := l_mtl_category_id_tbl(i);
            END IF;
            IF (g_auto_create_shop_catg = 'Y' AND
                l_category_name_is_valid)
            THEN
              l_err_loc := 1600;
              -- Add new category only if the profile is set to Yes
              gTotalRowCount := gTotalRowCount + 1;
              l_index := gInsRtCategoryIdTbl.COUNT + 1;
              gInsRtCategoryIdTbl(l_index) := l_rt_category_id;
              gInsCategoryKeyTbl(l_index) := to_char(l_mtl_category_id_tbl(i));
              gInsCategoryNameTbl(l_index) := l_mtl_category_name_tbl(i);
              gInsLanguageTbl(l_index) := l_mtl_language_tbl(i);
              gInsSourceLangTbl(l_index) := l_mtl_source_lang_tbl(i);
            END IF;
          ELSE  -- IF (l_rt_category_id_tbl(i) IS NULL) THEN
            l_err_loc := 1700;
            IF (l_old_category_name_tbl(i) IS NULL) THEN
              IF (g_auto_create_shop_catg = 'Y' AND
                  l_category_name_is_valid)
              THEN
                l_err_loc := 1800;
                -- Translation row added for the category
                gTotalRowCount := gTotalRowCount + 1;
                l_index := gInsRtCategoryIdTbl.COUNT + 1;
                gInsRtCategoryIdTbl(l_index) := l_rt_category_id_tbl(i);
                gInsCategoryKeyTbl(l_index) := to_char(l_mtl_category_id_tbl(i));
                gInsCategoryNameTbl(l_index) := l_mtl_category_name_tbl(i);
                gInsLanguageTbl(l_index) := l_mtl_language_tbl(i);
                gInsSourceLangTbl(l_index) := l_mtl_source_lang_tbl(i);
              END IF;
            ELSE
              l_err_loc := 1900;
              -- Update of the category
              IF (l_mtl_category_name_tbl(i) <> l_old_category_name_tbl(i) AND
                  l_category_name_is_valid)
              THEN
                l_err_loc := 2000;
                gTotalRowCount := gTotalRowCount + 1;
                l_index := gUpdRtCategoryIdTbl.COUNT + 1;
                gUpdRtCategoryIdTbl(l_index) := l_rt_category_id_tbl(i);
                gUpdCategoryNameTbl(l_index) := l_mtl_category_name_tbl(i);
                gUpdLanguageTbl(l_index) := l_mtl_language_tbl(i);
                gUpdSourceLangTbl(l_index) := l_mtl_source_lang_tbl(i);
              ELSE
                l_err_loc := 2100;
                IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                      'Row #:' || i ||
                      ', with l_mtl_category_id_tbl:' || l_mtl_category_id_tbl(i) ||
                      ', l_rt_category_id_tbl:' || l_rt_category_id_tbl(i) ||
                      ', l_mtl_category_name_tbl:' || l_mtl_category_name_tbl(i) ||
                      ', l_old_category_name_tbl:' || l_old_category_name_tbl(i) ||
                      '; Category name is the same, no action needed');
                END IF;
              END IF; -- IF (l_mtl_category_name_tbl(i) <> l_old_category_name_tbl(i)) THEN
            END IF;  -- IF (l_old_category_name_tbl(i) IS NULL) THEN
          END IF;  -- IF (l_rt_category_id_tbl(i) IS NULL) THEN
        ELSE -- l_category_status IS NOT VALID
          l_err_loc := 2200;
          IF (l_prev_category_key <> l_mtl_category_id_tbl(i)) THEN
            -- Category is not valid any more and needs to be deleted
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', with l_mtl_category_id_tbl:' || l_mtl_category_id_tbl(i) ||
                  ', l_rt_category_id_tbl:' || l_rt_category_id_tbl(i) ||
                  ', l_end_date_active_tbl:' || l_end_date_active_tbl(i) ||
                  ', l_disable_date_tbl:' || l_disable_date_tbl(i) ||
                  ', l_system_date_tbl:' || l_system_date_tbl(i) ||
                  '; is invalid and has to be deleted');
            END IF;
            gTotalRowCount := gTotalRowCount + 1;
            l_index := gDelPoCategoryIdTbl.COUNT + 1;
            gDelPoCategoryIdTbl(l_index) := l_mtl_category_id_tbl(i);
          END IF;
        END IF;  -- IF (l_category_status = ICX_CAT_POPULATE_STATUS_PVT.VALID_FOR_POPULATE) THEN

        l_err_loc := 1500;
        l_prev_category_key := l_mtl_category_id_tbl(i);
        l_prev_rt_category_id := l_rt_category_id;
        l_prev_category_name := l_mtl_category_name_tbl(i);

        l_err_loc := 2300;
        populateCategoryTables('INLOOP');
      END LOOP;  --FOR LOOP of l_mtl_category_id_tbl

      l_err_loc := 2400;
      EXIT WHEN l_mtl_category_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
  END LOOP; --Cursor loop

  l_err_loc := 2500;
  populateCategoryTables('OUTLOOP');

  l_err_loc := 2600;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' done; '||
        'Total num. of batches processed:' ||l_batch_count ||
        ', Total num. of rows processed:' ||l_row_count);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END processCategory;

PROCEDURE openCategoryCursor
(       P_CATEGORY_ID   IN      NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'openCategoryCursor';
  l_err_loc     PLS_INTEGER;
  l_catg_csr    g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        '; p_category_id:' || p_category_id ||
        ', g_structure_id:' || ICX_CAT_UTIL_PVT.g_structure_id);
  END IF;

  l_err_loc := 200;
  --First close the cursor
  IF (l_catg_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_catg_csr;
  END IF;

  l_err_loc := 300;
  OPEN l_catg_csr FOR
    SELECT DISTINCT mck.category_id category_id,
           nvl(mctl.description, mck.concatenated_segments) category_name,
           mctl.language language,  mctl.source_lang source_lang,
           icat.rt_category_id rt_category_id,  icat2.category_name old_category_name,
           nvl(mck.end_date_active, SYSDATE+1), nvl(mck.disable_date, SYSDATE+1),
           SYSDATE system_date
    FROM mtl_categories_kfv mck,
         mtl_categories_tl mctl,
         icx_cat_categories_tl icat,
         icx_cat_categories_tl icat2
    WHERE mck.category_id = P_CATEGORY_ID
    AND mck.structure_id = ICX_CAT_UTIL_PVT.g_structure_id
    AND mctl.category_id = mck.category_id
    AND mctl.language IN (SELECT language_code FROM fnd_languages WHERE installed_flag IN ('B', 'I'))
    AND to_char(mctl.category_id) = icat.key (+)
    AND to_char(mctl.category_id) = icat2.key (+)
    AND mctl.language = icat2.language (+)
    ORDER BY 1;

  l_err_loc := 400;
  processCategory(l_catg_csr);

  l_err_loc := 500;
  CLOSE l_catg_csr;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openCategoryCursor;

PROCEDURE openValidCategorySetCursor
(       P_CATEGORY_ID   IN      NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'openValidCategorySetCursor';
  l_err_loc     PLS_INTEGER;
  l_catg_csr    g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        '; p_category_id:' || p_category_id ||
        ', g_structure_id:' || ICX_CAT_UTIL_PVT.g_structure_id ||
        ', g_category_set_id:' || ICX_CAT_UTIL_PVT.g_category_set_id);
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_catg_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_catg_csr;
  END IF;

  l_err_loc := 300;
  OPEN l_catg_csr FOR
    SELECT DISTINCT mck.category_id category_id,
           nvl(mctl.description, mck.concatenated_segments) category_name,
           mctl.language language,  mctl.source_lang source_lang,
           icat.rt_category_id rt_category_id,  icat2.category_name old_category_name,
           nvl(mck.end_date_active, SYSDATE+1), nvl(mck.disable_date, SYSDATE+1),
           SYSDATE system_date
    FROM mtl_categories_kfv mck,
         mtl_categories_tl mctl,
         mtl_category_set_valid_cats mcsvc,
         icx_cat_categories_tl icat,
         icx_cat_categories_tl icat2
    WHERE mck.category_id = P_CATEGORY_ID
    AND mck.structure_id = ICX_CAT_UTIL_PVT.g_structure_id
    AND mctl.category_id = mck.category_id
    AND mctl.language IN (SELECT language_code FROM fnd_languages WHERE installed_flag IN ('B', 'I'))
    AND to_char(mctl.category_id) = icat.key (+)
    AND to_char(mctl.category_id) = icat2.key (+)
    AND mctl.language = icat2.language (+)
    AND mcsvc.category_set_id = ICX_CAT_UTIL_PVT.g_category_set_id
    AND mcsvc.category_id = mck.category_id
    ORDER BY 1;

  l_err_loc := 400;
  processCategory(l_catg_csr);

  l_err_loc := 500;
  CLOSE l_catg_csr;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openValidCategorySetCursor;

PROCEDURE populateCategoryChange
(       P_CATEGORY_NAME         IN      VARCHAR2        ,
        P_CATEGORY_ID           IN      NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'populateCategoryChange';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 300;
  ICX_CAT_UTIL_PVT.setWhoColumns(null);

  l_err_loc := 400;
  setAutoCreateShopCatg;

  -- TODO: Check this comment
  -- Don't need to process items in the category, due to the following reasons:
  -- 1. Category may have just been created, so no item assignment is done so far.
  -- 2. If the category is updated, even if the category was not present in iProcurement
  --    we donot create mapping for the category, so items cannot be processed.

  IF (ICX_CAT_UTIL_PVT.g_validate_flag = 'N') THEN
    l_err_loc := 500;
    openCategoryCursor(P_CATEGORY_ID);
  ELSE
    l_err_loc := 600;
    openValidCategorySetCursor(P_CATEGORY_ID);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateCategoryChange;

PROCEDURE populateValidCategorySetInsert
(       P_CATEGORY_ID	        IN	NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'populateValidCategorySetInsert';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 300;
  ICX_CAT_UTIL_PVT.setWhoColumns(null);

  l_err_loc := 400;
  setAutoCreateShopCatg;

  l_err_loc := 600;
  openValidCategorySetCursor(P_CATEGORY_ID);

  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateValidCategorySetInsert;

PROCEDURE populateValidCategorySetUpdate
(       P_OLD_CATEGORY_ID	IN	NUMBER          ,
        P_NEW_CATEGORY_ID	IN	NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'populateValidCategorySetUpdate';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 300;
  ICX_CAT_UTIL_PVT.setWhoColumns(null);

  l_err_loc := 400;
  setAutoCreateShopCatg;

  l_err_loc := 500;
  populateValidCategorySetDelete(P_OLD_CATEGORY_ID);

  l_err_loc := 600;
  -- TODO: Check this comment
  -- ICX_CAT_POPULATE_CATG_PVT.g_DML_TYPE is used to decide whether to create the mapping or not
  -- So when a validate category set is updated with a new category it is really a
  -- valid category set insert.
  ICX_CAT_POPULATE_CATG_PVT.g_DML_TYPE := ICX_CAT_POPULATE_CATG_PVT.g_DML_INSERT_TYPE;

  l_err_loc := 700;
  openValidCategorySetCursor(P_NEW_CATEGORY_ID);

  l_err_loc := 800;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateValidCategorySetUpdate;

PROCEDURE populateValidCategorySetDelete
(       P_CATEGORY_ID	        IN	NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'populateValidCategorySetDelete';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 200;
  ICX_CAT_UTIL_PVT.setWhoColumns(null);

  l_err_loc := 300;
  gDelPoCategoryIdTbl.DELETE;

  l_err_loc := 400;
  l_index := gDelPoCategoryIdTbl.COUNT + 1;
  gDelPoCategoryIdTbl(l_index) := P_CATEGORY_ID;

  l_err_loc := 500;
  deleteCategories;

  l_err_loc := 600;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateValidCategorySetDelete;

PROCEDURE setAutoCreateShopCatg
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'setAutoCreateShopCatg';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  fnd_profile.get('POR_AUTO_CREATE_SHOPPING_CAT', g_auto_create_shop_catg);
  IF (g_auto_create_shop_catg IS NULL) THEN
    l_err_loc := 200;
    g_auto_create_shop_catg := 'N';
  END IF;

  l_err_loc := 300;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Auto create shop category set to:' || g_auto_create_shop_catg);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    g_auto_create_shop_catg := 'N';
END setAutoCreateShopCatg;

END ICX_CAT_POPULATE_CATG_PVT;

/
