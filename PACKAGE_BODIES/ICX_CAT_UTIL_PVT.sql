--------------------------------------------------------
--  DDL for Package Body ICX_CAT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_UTIL_PVT" AS
/* $Header: ICXVUTLB.pls 120.18.12010000.14 2014/09/25 17:24:02 prilamur ship $*/

-- Constants
G_PKG_NAME              CONSTANT VARCHAR2(30) :='ICX_CAT_UTIL_PVT';

g_log_module_prefix     VARCHAR2(10)    := 'icx.plsql.';
g_log_module_seperator  VARCHAR2(1)     := '.';
g_log_module_begin      VARCHAR2(5)     := 'begin';
g_log_module_end        VARCHAR2(3)     := 'end';

-- function to get the apps schema name
FUNCTION getAppsSchemaName
  RETURN VARCHAR2
IS
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (g_apps_schema_name IS NULL)
  THEN
    l_err_loc := 200;
    SELECT oracle_username
    INTO g_apps_schema_name
    FROM fnd_oracle_userid
    WHERE read_only_flag = 'U';
  END IF;
  l_err_loc := 300;
  RETURN g_apps_schema_name;
EXCEPTION
  WHEN OTHERS THEN
  l_err_loc := 400;
  RETURN 'APPS';
END getAppsSchemaName;

-- function to get the icx schema name
FUNCTION getIcxSchemaName
  RETURN VARCHAR2
IS
  l_status  VARCHAR2(20);
  l_industry  VARCHAR2(20);
  l_icx_schema_name VARCHAR2(20) := 'ICX';
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (g_icx_schema_name IS NOT NULL OR
      FND_INSTALLATION.GET_APP_INFO('ICX', l_status,
        l_industry, g_icx_schema_name))
  THEN
    l_err_loc := 200;
    l_icx_schema_name := g_icx_schema_name;
  END IF;
  l_err_loc := 300;
  RETURN l_icx_schema_name;
END getIcxSchemaName;

FUNCTION getModuleNameForDebug
(       p_pkg_name      IN      VARCHAR2        ,
        p_proc_name     IN      VARCHAR2
)
  RETURN VARCHAR2
IS
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  RETURN g_log_module_prefix || UPPER(p_pkg_name) || g_log_module_seperator || p_proc_name;
END getModuleNameForDebug;

PROCEDURE logProcBegin
(       p_pkg_name      IN      VARCHAR2        ,
        p_proc_name     IN      VARCHAR2        ,
        p_log_string    IN      VARCHAR2
)
IS
  l_proc_begin_module   VARCHAR2(80);
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_err_loc := 200;
    l_proc_begin_module := getModuleNameForDebug(p_pkg_name, p_proc_name) || g_log_module_seperator || g_log_module_begin;
    l_err_loc := 300;
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_proc_begin_module, p_log_string);
    l_err_loc := 400;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 500;
    NULL;
END logProcBegin;

PROCEDURE logProcEnd
(       p_pkg_name      IN      VARCHAR2        ,
        p_proc_name     IN      VARCHAR2        ,
        p_log_string    IN      VARCHAR2
)
IS
  l_proc_end_module   VARCHAR2(80);
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_err_loc := 200;
    l_proc_end_module := getModuleNameForDebug(p_pkg_name, p_proc_name) || g_log_module_seperator || g_log_module_end;
    l_err_loc := 300;
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, l_proc_end_module, p_log_string);
    l_err_loc := 400;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 500;
    NULL;
END logProcEnd;

PROCEDURE logUnexpectedException
(       p_pkg_name      IN      VARCHAR2        ,
        p_proc_name     IN      VARCHAR2        ,
        p_log_string    IN      VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_err_loc := 200;
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, getModuleNameForDebug(p_pkg_name, p_proc_name), p_log_string);
    l_err_loc := 300;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 400;
    NULL;
END logUnexpectedException;

PROCEDURE logPOSessionGTData
(       p_key           IN      NUMBER
)
IS
  CURSOR poSessionGTCsr (p_key   NUMBER) IS
    SELECT key, index_num1, index_num2,
           index_char1, index_char2,
           char1, char2, char3
    FROM po_session_gt
    WHERE key = p_key;

  l_api_name            CONSTANT VARCHAR2(30)   := 'logPOSessionGTData';
  l_err_loc             PLS_INTEGER;

  ----- Start of declaring columns selected in the cursor -----

  l_key_tbl             DBMS_SQL.NUMBER_TABLE;
  l_index_num1_tbl      DBMS_SQL.NUMBER_TABLE;
  l_index_num2_tbl      DBMS_SQL.NUMBER_TABLE;
  l_index_char1_tbl     DBMS_SQL.VARCHAR2_TABLE;
  l_index_char2_tbl     DBMS_SQL.VARCHAR2_TABLE;
  l_char1_tbl           DBMS_SQL.NUMBER_TABLE;
  l_char2_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_char3_tbl           DBMS_SQL.VARCHAR2_TABLE;

  ------ End of declaring columns selected in the cursor ------
BEGIN
  l_err_loc := 100;
  OPEN poSessionGTCsr(p_key);

  l_err_loc := 200;
  IF (ICX_CAT_UTIL_PVT.g_batch_size IS NULL) THEN
    setBatchSize;
  END IF;

  LOOP
    l_err_loc := 300;
    l_key_tbl.DELETE;
    l_index_num1_tbl.DELETE;
    l_index_num2_tbl.DELETE;
    l_index_char1_tbl.DELETE;
    l_index_char2_tbl.DELETE;
    l_char1_tbl.DELETE;
    l_char2_tbl.DELETE;
    l_char3_tbl.DELETE;

    l_err_loc := 400;
    FETCH poSessionGTCsr BULK COLLECT INTO
        l_key_tbl, l_index_num1_tbl, l_index_num2_tbl,
        l_index_char1_tbl, l_index_char2_tbl,
        l_char1_tbl, l_char2_tbl, l_char3_tbl
    LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

    EXIT WHEN l_key_tbl.COUNT = 0;

    l_err_loc := 500;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'For p_key:' || p_key || ', PO_SESSION_GT rowcount:' || l_key_tbl.COUNT );
    END IF;

    l_err_loc := 600;
    FOR i IN 1..l_key_tbl.COUNT LOOP
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                        'PO_SESSION_GT Row # ' || i ||
                        '; l_key_tbl: ' || l_key_tbl(i) ||
                        ', l_index_num1_tbl: ' || l_index_num1_tbl(i) ||
                        ', l_index_num2_tbl: ' || l_index_num2_tbl(i) ||
                        ', l_index_char1_tbl: ' || l_index_char1_tbl(i) ||
                        ', l_index_char2_tbl: ' || l_index_char2_tbl(i) ||
                        ', l_char1_tbl: ' || l_char1_tbl(i) ||
                        ', l_char2_tbl: ' || l_char2_tbl(i) ||
                        ', l_char3_tbl: ' || l_char3_tbl(i) );
      END IF;
    END LOOP;

    EXIT WHEN l_key_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
  END LOOP;
  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
END logPOSessionGTData;

PROCEDURE logMtlItemBulkloadRecsData
(       p_request_id    IN      NUMBER
)
IS
  CURSOR mtlItemBulkloadRecsCsr (p_request_id   NUMBER) IS
    SELECT inventory_item_id, organization_id, revision_id,
           category_id, category_set_id
    FROM mtl_item_bulkload_recs
    WHERE request_id = p_request_id;

  l_api_name            CONSTANT VARCHAR2(30)   := 'logMtlItemBulkloadRecsData';
  l_err_loc             PLS_INTEGER;

  ----- Start of declaring columns selected in the cursor -----

  l_inventory_item_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_organization_id_tbl         DBMS_SQL.NUMBER_TABLE;
  l_revision_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_category_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_category_set_id_tbl         DBMS_SQL.NUMBER_TABLE;

  ------ End of declaring columns selected in the cursor ------
BEGIN
  l_err_loc := 100;
  OPEN mtlItemBulkloadRecsCsr(p_request_id);

  l_err_loc := 200;
  IF (ICX_CAT_UTIL_PVT.g_batch_size IS NULL) THEN
    setBatchSize;
  END IF;

  LOOP
    l_err_loc := 300;
    l_inventory_item_id_tbl.DELETE;
    l_organization_id_tbl.DELETE;
    l_revision_id_tbl.DELETE;
    l_category_id_tbl.DELETE;
    l_category_set_id_tbl.DELETE;

    l_err_loc := 400;
    FETCH mtlItemBulkloadRecsCsr BULK COLLECT INTO
        l_inventory_item_id_tbl, l_organization_id_tbl,
        l_revision_id_tbl, l_category_id_tbl, l_category_set_id_tbl
    LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

    EXIT WHEN l_inventory_item_id_tbl.COUNT = 0;

    l_err_loc := 500;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'For p_request_id:' || p_request_id ||
          ', MTL_ITEM_BULKLOAD_RECS rowcount:' || l_inventory_item_id_tbl.COUNT);
    END IF;

    l_err_loc := 600;
    FOR i IN 1..l_inventory_item_id_tbl.COUNT LOOP
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                        'MTL_ITEM_BULKLOAD_RECS Row # ' || i ||
                        '; l_inventory_item_id_tbl: ' || l_inventory_item_id_tbl(i) ||
                        ', l_organization_id_tbl: ' || l_organization_id_tbl(i) ||
                        ', l_revision_id_tbl: ' || l_revision_id_tbl(i) ||
                        ', l_category_id_tbl: ' || l_category_id_tbl(i) ||
                        ', l_category_set_id_tbl: ' || l_category_set_id_tbl(i) );
      END IF;
    END LOOP;

    EXIT WHEN l_inventory_item_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
  END LOOP;
  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
END logMtlItemBulkloadRecsData;

-- IF commit depends on the p_commit passed to the API, then the
-- Calling procedure should make sure to call logAndCommitSnapShotTooOld only if p_commit is true.
PROCEDURE logAndCommitSnapShotTooOld
(       p_pkg_name      IN      VARCHAR2        ,
        p_api_name      IN      VARCHAR2        ,
        p_err_string    IN      VARCHAR2
)
IS
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  ICX_CAT_UTIL_PVT.logUnexpectedException(
    p_pkg_name, p_api_name,
    p_api_name || ' --> snap shot too old error caught at '|| p_err_string ||
    'Commit will be done in logAndCommitSnapShotTooOld');
  l_err_loc := 200;
  COMMIT;
END logAndCommitSnapShotTooOld;

FUNCTION getTimeDiff
(       p_start         IN      DATE            ,
        p_end           IN      DATE
)
  RETURN NUMBER
IS
  l_time_mult NUMBER := 60*24;
BEGIN
  RETURN ROUND((p_end - p_start) * l_time_mult,3);
END getTimeDiff;

FUNCTION getTimeStats
(       p_start         IN      DATE            ,
        p_end           IN      DATE
)
  RETURN VARCHAR2
IS
  l_space       VARCHAR2(1)     := ' ';
BEGIN
  RETURN l_space || 'time(m): ' || getTimeDiff(p_start,p_end)
   || l_space || 'start: ' || TO_CHAR(p_start,'HH24:MI:SS')
   || l_space || 'end: ' || TO_CHAR(p_end,'HH24:MI:SS');
END getTimeStats;

--------------------------------------------------------------
--               Get PL/SQL Table element Start             --
--------------------------------------------------------------
FUNCTION getTableElement
(       p_table         IN DBMS_SQL.NUMBER_TABLE        ,
        p_index         IN BINARY_INTEGER
)
  RETURN VARCHAR2
IS
  l_string VARCHAR2(2000) := '';
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF p_table.EXISTS(p_index) THEN
    l_err_loc := 200;
    l_string := l_string || p_table(p_index);
  ELSE
    l_err_loc := 300;
    l_string := l_string || '<Not Exists>';
  END IF;
  l_err_loc := 400;
  RETURN l_string;
END getTableElement;

FUNCTION getTableElement
(       p_table         IN DBMS_SQL.VARCHAR2_TABLE      ,
        p_index         IN BINARY_INTEGER
)
  RETURN VARCHAR2
IS
  l_string VARCHAR2(2000) := '';
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF p_table.EXISTS(p_index) THEN
    l_err_loc := 200;
    l_string := l_string || p_table(p_index);
  ELSE
    l_err_loc := 300;
    l_string := l_string || '<Not Exists>';
  END IF;
  RETURN l_string;
END getTableElement;

FUNCTION getTableElement
(       p_table         IN DBMS_SQL.UROWID_TABLE        ,
        p_index         IN BINARY_INTEGER
)
  RETURN VARCHAR2
IS
  l_string VARCHAR2(2000) := '';
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF p_table.EXISTS(p_index) THEN
    l_err_loc := 200;
    l_string := l_string || p_table(p_index);
  ELSE
    l_err_loc := 300;
    l_string := l_string || '<Not Exists>';
  END IF;
  l_err_loc := 400;
  RETURN l_string;
END getTableElement;

FUNCTION getTableElement
(       p_table         IN DBMS_SQL.DATE_TABLE          ,
        p_index         IN BINARY_INTEGER
)
  RETURN VARCHAR2
IS
  l_string VARCHAR2(2000) := '';
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF p_table.EXISTS(p_index) THEN
    l_err_loc := 200;
    l_string := l_string || TO_CHAR(p_table(p_index), 'MM/DD/YY HH24:MI:SS');
  ELSE
    l_err_loc := 300;
    l_string := l_string || '<Not Exists>';
  END IF;
  l_err_loc := 400;
  RETURN l_string;
END getTableElement;

FUNCTION checkValueExistsInTable
(       p_table         IN      DBMS_SQL.NUMBER_TABLE   ,
        p_value         IN      NUMBER
)
  RETURN VARCHAR2
IS
  l_ret_value                   VARCHAR2(1) := 'N';
  l_api_name                    CONSTANT VARCHAR2(30)   := 'checkValueExistsInTable';
  l_err_loc                     PLS_INTEGER;
BEGIN
  FOR j IN 1..p_table.COUNT LOOP
    l_ret_value := 'N';
    IF (p_value = p_table(j)) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            ' p_value:' || p_value ||
            ', already exists in the p_table at index:' || j ||
            '; about to exit from table check');
      END IF;
      l_ret_value := 'Y';
      EXIT;
    END IF;
  END LOOP;

  RETURN l_ret_value;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END checkValueExistsInTable;

--------------------------------------------------------------
--                 Get PL/SQL Table element End             --
--------------------------------------------------------------

FUNCTION getPOCategoryIdFromIp(p_category_id IN NUMBER)
  RETURN NUMBER
IS
  l_po_category_id      NUMBER;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  SELECT to_number(external_source_key)
  INTO l_po_category_id
  FROM icx_por_category_order_map
  WHERE rt_category_id = p_category_id;

  l_err_loc := 200;

  RETURN l_po_category_id;
EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 300;
    RETURN TO_NUMBER(NULL);
END getPOCategoryIdFromIp;

FUNCTION getNextSequenceForWhoColumns
  RETURN NUMBER
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'getNextSequenceForWhoColumns';
  l_internal_request_id  NUMBER;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  SELECT icx_cat_items_ctx_requestid_s.nextval
  INTO   l_internal_request_id
  FROM   dual;

  l_err_loc := 200;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Next Seq from icx_cat_items_ctx_requestid_s:' || l_internal_request_id);
  END IF;

  RETURN l_internal_request_id;
EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 300;
    RETURN TO_NUMBER(NULL);
END getNextSequenceForWhoColumns;

PROCEDURE setBatchSize
(       p_batch_size    IN      NUMBER DEFAULT NULL
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'setBatchSize';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (p_batch_size IS NOT NULL) THEN
    l_err_loc := 200;
    g_batch_size := p_batch_size;
  ELSE
    l_err_loc := 300;
    fnd_profile.get('POR_LOAD_PURGE_COMMIT_SIZE', ICX_CAT_UTIL_PVT.g_batch_size);
    IF (g_batch_size IS NULL) THEN
      l_err_loc := 400;
      g_batch_size := 2500;
    END IF;
  END IF;

  l_err_loc := 500;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Batch Size set to:' || ICX_CAT_UTIL_PVT.g_batch_size);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 600;
    g_batch_size := 2500;
END setBatchSize;

PROCEDURE setCommitParameter
(       p_commit        IN      VARCHAR2 := FND_API.G_FALSE
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'setCommitParameter';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_COMMIT := p_commit;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'g_COMMIT set to:' || g_COMMIT);
  END IF;
END setCommitParameter;

PROCEDURE setWhoColumns
(       p_request_id    IN      NUMBER
)
IS
  l_api_name    		CONSTANT VARCHAR2(30)   := 'setWhoColumns';
  l_err_loc     		PLS_INTEGER;
  l_internal_request_id		NUMBER;
BEGIN
  l_err_loc := 100;
  l_internal_request_id := ICX_CAT_UTIL_PVT.getNextSequenceForWhoColumns;
  g_who_columns_rec.user_id := fnd_global.user_id;
  g_who_columns_rec.login_id := fnd_global.login_id;
  g_who_columns_rec.internal_request_id := l_internal_request_id;

  IF (p_request_id IS NULL) THEN
    l_err_loc := 200;
    g_who_columns_rec.request_id := null;
    g_who_columns_rec.program_application_id := null;
    g_who_columns_rec.program_id := null;
    g_who_columns_rec.program_login_id := null;
  ELSE
    l_err_loc := 300;
    g_who_columns_rec.request_id := p_request_id;
    g_who_columns_rec.program_application_id := fnd_global.prog_appl_id;
    g_who_columns_rec.program_id := fnd_global.conc_program_id;
    g_who_columns_rec.program_login_id := fnd_global.conc_login_id;
  END IF;
  l_err_loc := 400;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Who columns; internal_request_id:' || l_internal_request_id ||
        ', request_id:' || p_request_id ||
        ', user_id:' || g_who_columns_rec.user_id ||
        ', login_id:' || g_who_columns_rec.login_id);
  END IF;
END setWhoColumns;

PROCEDURE setBaseLanguage
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'setBaseLanguage';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  SELECT language_code
  INTO   g_base_language
  FROM   fnd_languages
  WHERE  installed_flag='B';

  l_err_loc := 200;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Base language:' || g_base_language);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    g_base_language := 'US';
END setBaseLanguage;

PROCEDURE getPurchasingCategorySetInfo
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'getPurchasingCategorySetInfo';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  SELECT category_set_id,
         validate_flag,
         structure_id
  INTO   g_category_set_id,
         g_validate_flag,
         g_structure_id
  FROM   mtl_default_sets_view
  WHERE  functional_area_id = 2;

  l_err_loc := 200;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Purchasing category set info: g_category_set_id:' || g_category_set_id ||
        ', g_validate_flag:' || g_validate_flag ||
        ', g_structure_id:' || g_structure_id);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END getPurchasingCategorySetInfo;

PROCEDURE getMIConcatSegmentClause
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'getMIConcatSegmentClause';
  l_err_loc                     PLS_INTEGER;
  l_appl_column_name_tbl        DBMS_SQL.VARCHAR2_TABLE;
  l_delimiter                   VARCHAR2(1);
BEGIN
  l_err_loc := 100;
  SELECT application_column_name
  BULK COLLECT INTO l_appl_column_name_tbl
  FROM fnd_id_flex_segments
  WHERE application_id = 401
  AND id_flex_code   = 'MSTK'
  AND id_flex_num    = 101
  AND enabled_flag   = 'Y'
  ORDER BY segment_num;

  l_err_loc := 200;
  SELECT concatenated_segment_delimiter
  INTO   l_delimiter
  FROM   fnd_id_flex_structures
  WHERE  application_id = 401
  AND    id_flex_code   = 'MSTK'
  AND    id_flex_num    = 101
  AND    enabled_flag   = 'Y';

  l_err_loc := 300;
  FOR i IN 1..l_appl_column_name_tbl.COUNT LOOP
    IF ( g_mi_concat_seg_clause IS NOT NULL ) THEN
      l_err_loc := 400;
      g_mi_concat_seg_clause := g_mi_concat_seg_clause || ' || ''' || l_delimiter || ''' || ' || l_appl_column_name_tbl(i);
    ELSE
      l_err_loc := 500;
      g_mi_concat_seg_clause := l_appl_column_name_tbl(i);
    END IF;
  END LOOP;

  l_err_loc := 600;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Concatenated Segment Clause for master items: ' || g_mi_concat_seg_clause);
  END IF;

  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END getMIConcatSegmentClause;

FUNCTION getR12UpgradeJobNumber
  RETURN NUMBER
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'getR12UpgradeJobNumber';
  l_err_loc             PLS_INTEGER;
  l_upgrade_job_number  PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  SELECT NVL(MIN(job_number), 1)
  INTO   l_upgrade_job_number
  FROM   icx_cat_r12_upgrade_jobs;

  l_err_loc := 200;
  IF (l_upgrade_job_number > 0) THEN
    l_upgrade_job_number := ICX_CAT_UTIL_PVT.g_upgrade_user;
  ELSE
    l_upgrade_job_number := l_upgrade_job_number - 1;
  END IF;

  RETURN l_upgrade_job_number;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END getR12UpgradeJobNumber;

 --
 -- Function
 --        get_message
 -- Purpose
 --	   Returns the corresponding value of the mesage name after   --
 --	   substituting it with the token

  FUNCTION get_message(p_message_name in VARCHAR2,
                        p_token_name in VARCHAR2,
                        p_token_value in VARCHAR2) return VARCHAR2 is
  l_message       fnd_new_messages.message_text%TYPE;
  BEGIN
    fnd_message.set_name('ICX',p_message_name);
    fnd_message.set_token(p_token_name,p_token_value);
    l_message := fnd_message.get;
    return l_message;
  END;

-- function to check if the item is valid to be shown in the search results page
FUNCTION is_item_valid_for_search
(
  p_source_type IN VARCHAR2,
  p_po_line_id IN NUMBER,
  p_req_template_name IN VARCHAR2,
  p_req_template_line_num IN NUMBER,
  p_category_id IN NUMBER,
  p_org_id IN NUMBER
)
RETURN NUMBER
IS
  l_status NUMBER;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;

  l_status := 1;
  IF (p_source_type = 'MASTER_ITEM') THEN
    l_err_loc := 150;
    IF (is_category_valid(p_category_id) = 0) THEN
      l_err_loc := 200;
      l_status := 0;
    END IF;
  ELSIF (p_source_type in ('TEMPLATE', 'INTERNAL_TEMPLATE')) THEN
    l_err_loc := 250;
    IF (is_req_template_line_valid(p_org_id, p_req_template_name, p_req_template_line_num) = 0) THEN
      l_err_loc := 350;
      l_status := 0;
    END IF;
  ELSIF (p_source_type in ('BLANKET', 'GLOBAL_BLANKET')) THEN
    l_err_loc := 400;
    IF (is_blanket_valid(p_po_line_id,p_org_id) = 0) THEN
      l_err_loc := 450;
      l_status := 0;
    END IF;
  ELSIF (p_source_type = 'QUOTATION') THEN
    l_err_loc := 500;
    IF (is_quotation_valid(p_po_line_id) = 0) THEN
      l_err_loc := 550;
      l_status := 0;
    END IF;
  END IF;

  l_err_loc := 600;

  RETURN l_status;

EXCEPTION
  WHEN OTHERS THEN
     l_err_loc := 650;
     l_status := 0;
     RETURN l_status;

END is_item_valid_for_search;

-- function to check if the category is valid
FUNCTION is_category_valid
(
  p_category_id IN NUMBER
)
RETURN NUMBER
IS
  l_start_date DATE;
  l_end_date DATE;
  l_disable_date DATE;
  l_status NUMBER;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;

  l_status := 1;

  BEGIN
    SELECT start_date_active, end_date_active, disable_date
    INTO l_start_date, l_end_date, l_disable_date
    FROM mtl_categories_kfv
    WHERE category_id = p_category_id;
  EXCEPTION
    WHEN OTHERS THEN
      l_err_loc := 200;
      l_status := 0;
  END;

  l_err_loc := 300;

  IF (l_status = 1) THEN
    IF (NVL(l_start_date, SYSDATE) > SYSDATE OR
        NVL(l_end_date, SYSDATE+1) <= SYSDATE OR
        NVL(l_disable_date, SYSDATE+1) <= SYSDATE) THEN
      l_err_loc := 400;
      l_status := 0;
    END IF;
  END IF;

  l_err_loc := 500;

  RETURN l_status;

EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 600;
    l_status := 0;
    RETURN l_status;

END is_category_valid;

-- function to check if the req template line is valid
FUNCTION is_req_template_line_valid
(
  p_org_id IN NUMBER,
  p_req_template_name	IN VARCHAR2,
  p_req_template_line_num IN NUMBER
)
RETURN NUMBER
IS
  l_status NUMBER;
  l_inactive_date DATE;
  l_po_line_id NUMBER;
  l_err_loc PLS_INTEGER;
  l_item_id NUMBER;     --bug 15978590
BEGIN
  l_err_loc := 100;

  l_status := 1;
  SELECT prh.inactive_date, prl.po_line_id, prl.item_id
  INTO l_inactive_date, l_po_line_id, l_item_id
  FROM po_reqexpress_headers_all prh, po_reqexpress_lines_all prl
  WHERE prh.express_name = p_req_template_name
  AND prh.org_id = p_org_id
  AND prl.express_name = prh.express_name
  AND prl.org_id = prh.org_id
  AND prl.sequence_num = TO_NUMBER(p_req_template_line_num);

  l_err_loc := 200;

  IF (NVL(l_inactive_date, SYSDATE+1) <= SYSDATE) THEN
    l_status := 0;
  ELSIF (l_po_line_id IS NOT NULL AND l_po_line_id <> -2) THEN
    l_status := is_blanket_valid(l_po_line_id,p_org_id);
  --bug 15978590: add to check whether the item can be purchased or not
  ELSIF (l_item_id IS NOT NULL) THEN
    SELECT COUNT(*)
    INTO l_status
    FROM mtl_system_items_b msi, financials_system_params_all fsp
    WHERE msi.INVENTORY_ITEM_ID        = l_item_id
    AND msi.ORGANIZATION_ID            = fsp.INVENTORY_ORGANIZATION_ID
    AND fsp.ORG_ID                     = p_org_id
    AND (msi.purchasing_enabled_flag   = 'Y'
    OR msi.internal_order_enabled_flag = 'Y' );
  --end bug 15978590
  END IF;

  l_err_loc := 300;

  RETURN l_status;

EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 400;
    l_status := 0;
    RETURN l_status;

END is_req_template_line_valid;

-- function to check if the blanket is valid
FUNCTION is_blanket_valid
(
  p_po_line_id IN NUMBER,  p_org_id   IN NUMBER

)
RETURN NUMBER
IS
  l_status NUMBER;
  l_err_loc PLS_INTEGER;
  l_auth_status po_headers_all.authorization_status%type;
  l_revision po_lines_archive_all.REVISION_NUM%type;
BEGIN
  l_err_loc := 100;

  l_status := 0;

--- bug 12792244 start

  SELECT ph.authorization_status
  INTO l_auth_status
  FROM PO_HEADERS_ALL ph,PO_LINES_ALL pl
  WHERE pl.po_line_id=p_po_line_id
  AND ph.po_header_id = pl.po_header_id;


   If l_auth_status <> 'APPROVED' THEN    --bug 16374319

  l_err_loc := 200;

  select max(REVISION_NUM)
  into l_revision
  from po_lines_archive_all
  where po_line_id=p_po_line_id;

  SELECT 1
  INTO l_status
  FROM po_headers_archive_all ph, po_lines_archive_all pl
  WHERE pl.po_line_id = p_po_line_id
  AND ph.LATEST_EXTERNAL_FLAG = 'Y'
  AND pl.REVISION_NUM = l_revision
  AND ph.po_header_id = pl.po_header_id
  AND ph.approved_date IS NOT NULL
  AND ph.authorization_status NOT IN ('REJECTED', 'INCOMPLETE')
  AND NVL(ph.user_hold_flag, 'N') <> 'Y'
  AND NVL(ph.cancel_flag, 'N') <> 'Y'
  AND NVL(ph.frozen_flag, 'N') <> 'Y'
  AND NVL(ph.closed_code, 'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED')
  AND NVL(pl.closed_code, 'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED')
  AND NVL(pl.cancel_flag, 'N') <> 'Y'
  AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(ph.start_date), TRUNC( SYSDATE - 1))
      AND NVL(TRUNC(ph.end_date), TRUNC( SYSDATE + 1))
  AND TRUNC(SYSDATE) <= NVL(TRUNC(pl.expiration_date), TRUNC( SYSDATE+1))
--Bug:#14370992 begin
  AND Decode (pl.item_id, NULL, 1,
                              (SELECT Count(*)
                               FROM   mtl_system_items_b msi,
                                      financials_system_params_all fsp
                               WHERE  msi.INVENTORY_ITEM_ID = pl.ITEM_ID
                               AND    msi.ORGANIZATION_ID = fsp.INVENTORY_ORGANIZATION_ID
                               AND    p_org_id = fsp.ORG_ID
                               AND    (msi.purchasing_enabled_flag     = 'Y'
                               OR      msi.internal_order_enabled_flag = 'Y'))) = 1;
--Bug:#14370992 end
  ELSE

--- bug 12792244 end

  l_err_loc := 300;

  SELECT 1
  INTO l_status
  FROM po_headers_all ph, po_lines_all pl
  WHERE pl.po_line_id = p_po_line_id
  AND ph.po_header_id = pl.po_header_id
  AND ph.approved_date IS NOT NULL
  AND ph.authorization_status NOT IN ('REJECTED', 'INCOMPLETE')
  AND NVL(ph.user_hold_flag, 'N') <> 'Y'
  AND NVL(ph.cancel_flag, 'N') <> 'Y'
  AND NVL(ph.frozen_flag, 'N') <> 'Y'
  AND NVL(ph.closed_code, 'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED')
  AND NVL(pl.closed_code, 'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED')
  AND NVL(pl.cancel_flag, 'N') <> 'Y'
  AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(ph.start_date), TRUNC( SYSDATE - 1))
      AND NVL(TRUNC(ph.end_date), TRUNC( SYSDATE + 1))
  AND TRUNC(SYSDATE) <= NVL(TRUNC(pl.expiration_date), TRUNC( SYSDATE+1))
  AND Decode (pl.item_id, NULL, 1,
                              (SELECT Count(*)
                               FROM   mtl_system_items_b msi,
                                      financials_system_params_all fsp
                               WHERE  msi.INVENTORY_ITEM_ID = pl.ITEM_ID
                               AND    msi.ORGANIZATION_ID = fsp.INVENTORY_ORGANIZATION_ID
                               AND    p_org_id = fsp.ORG_ID --Bug:#14370992
                               AND    (msi.purchasing_enabled_flag     = 'Y'
                               OR      msi.internal_order_enabled_flag = 'Y'))) = 1;

  END IF;
  l_err_loc := 400;

  RETURN l_status;

EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 500;
    l_status := 0;
    RETURN l_status;

END is_blanket_valid;

-- function to check if the quotation is valid
FUNCTION is_quotation_valid
(
  p_po_line_id IN NUMBER
)
RETURN NUMBER
IS
  l_status NUMBER;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;

  l_status := 0;

  SELECT 1
  INTO l_status
  FROM po_headers_all ph, po_lines_all pl
  WHERE pl.po_line_id = p_po_line_id
  AND ph.po_header_id = pl.po_header_id
  AND ph.status_lookup_code = 'A'
  AND ph.quotation_class_code = 'CATALOG'
  AND TRUNC(SYSDATE) BETWEEN NVL(TRUNC(ph.start_date), TRUNC( SYSDATE - 1))
      AND NVL(TRUNC(ph.end_date), TRUNC( SYSDATE + 1))
  AND (NVL(ph.approval_required_flag, 'N') = 'N'
       OR
       (ph.approval_required_flag = 'Y' AND
        EXISTS (SELECT 'current approved effective price break'
                FROM po_line_locations_all pll, po_quotation_approvals_all pqa
                WHERE pl.po_line_id = pll.po_line_id
                AND SYSDATE BETWEEN NVL(pll.start_date, SYSDATE-1) AND
                                    NVL(pll.end_date, SYSDATE+1)
                AND pqa.line_location_id = pll.line_location_id
                AND pqa.approval_type IS NOT NULL
                AND SYSDATE BETWEEN NVL(pqa.start_date_active, SYSDATE-1)
                AND NVL(pqa.end_date_active, SYSDATE+1))))
                AND TRUNC(SYSDATE) < NVL(TRUNC(pl.expiration_date), TRUNC( SYSDATE+1))
                AND 1 = CASE WHEN pl.item_id IS NOT NULL THEN (SELECT Count(*)
          		 					 FROM mtl_system_items_b msi,
							              financials_system_params_all fsp
							        WHERE msi.INVENTORY_ITEM_ID           = pl.ITEM_ID
							          AND msi.ORGANIZATION_ID             = fsp.INVENTORY_ORGANIZATION_ID
							          AND pl.ORG_ID                       = fsp.ORG_ID
							          AND (msi.purchasing_enabled_flag    = 'Y'
							           OR msi.internal_order_enabled_flag = 'Y'))
			     WHEN pl.item_id IS NULL THEN 1 END;

  l_err_loc := 200;

  RETURN l_status;

EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 300;
    l_status := 0;
    RETURN l_status;

END is_quotation_valid;

-- function to get the conversion rate from the from_currency to the to_currency
FUNCTION get_rate
(
  p_from_currency VARCHAR2,
  p_to_currency VARCHAR2,
  p_rate_date DATE,
  p_rate_type VARCHAR2
)
RETURN NUMBER
IS
  l_rate NUMBER;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;

  l_rate := GL_CURRENCY_API.get_rate(p_from_currency, p_to_currency, p_rate_date, p_rate_type);

  l_err_loc := 300;

  RETURN l_rate;

-- the GL_CURRENCY_API.get_rate API above will throw an exception if no rate
-- is found. In this case, we will return null. We will also return null
-- if there is any other errors from the API.
EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 400;
    RETURN null;

END get_rate;

-- function to convert the amount from the from_currency to the to_currency
FUNCTION convert_amount
(
  p_from_currency VARCHAR2,
  p_to_currency	VARCHAR2,
  p_conversion_date DATE,
  p_conversion_type VARCHAR2,
  p_conversion_rate NUMBER,
  p_amount NUMBER
)
RETURN NUMBER
IS
  l_converted_amount NUMBER;
  l_rate NUMBER;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;

  -- return p_amount if p_from_currency is the same as p_to_currency
  IF (p_from_currency = p_to_currency OR p_amount IS null) THEN
    l_err_loc := 150;
    l_converted_amount := p_amount;
  ELSE
    l_err_loc := 200;
    -- use user rate if conversion type is USER
    IF (p_conversion_type = 'User') THEN
      l_err_loc := 250;
      l_rate := p_conversion_rate;
    ELSE
      l_err_loc := 300;
      l_rate := get_rate(p_from_currency, p_to_currency, p_conversion_date, p_conversion_type);
    END IF;

    l_err_loc := 350;

    IF (l_rate IS NOT null) THEN
      l_err_loc := 400;
      l_converted_amount := p_amount * l_rate;
    ELSE
      l_err_loc := 450;
      l_converted_amount := null;
    END IF;
    l_err_loc := 500;
  END IF;

  l_err_loc := 550;

  RETURN l_converted_amount;

END convert_amount;

--bug 19289104
PROCEDURE delete_action_history(p_object_id  IN NUMBER) is
begin
  if (p_object_id is null) then
      return;
  end if;
  DELETE from po_action_history Where OBJECT_TYPE_CODE = 'REQUISITION' and
OBJECT_ID = p_object_id;
end delete_action_history;

END ICX_CAT_UTIL_PVT;

/
