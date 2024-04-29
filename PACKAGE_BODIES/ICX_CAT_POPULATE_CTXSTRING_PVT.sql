--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_CTXSTRING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_CTXSTRING_PVT" AS
/* $Header: ICXVPCSB.pls 120.7 2006/08/14 23:26:36 rwidjaja noship $*/

TYPE g_csr_type                 IS REF CURSOR;

-- Constants
G_PKG_NAME                      CONSTANT VARCHAR2(30) :='ICX_CAT_POPULATE_CTXSTRING_PVT';
g_metadataTblFormed             BOOLEAN := FALSE;
g_special_metadata_tbl          ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
g_regular_nontl_metadata_tbl    ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
g_regular_tl_metadata_tbl       ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;

-- populate Row with sequence: 1, 3, 6
-- Sequence 1 --> Mandatory Row
-- Sequence 3 --> Internal Item Number
-- Sequence 6 --> Shopping Category
-- The above are the only ones that will be populated for
-- all data sources including master items
-- Values of p_repopulate_at_seq will be one among(1, 3, 6)
PROCEDURE popCtxBaseSpecAttForAllSrc
(	p_repopulate_at_seq     IN      NUMBER						,
	p_special_ctx_sql_tbl   IN      ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'popCtxBaseSpecAttForAllSrc';
  l_err_loc             PLS_INTEGER;
  l_rowid_tbl           DBMS_SQL.UROWID_TABLE;
  l_csr_var             g_csr_type;
  l_ctx_sqlstring_rec   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_rec_type;
  l_ctx_sql_string      VARCHAR2(4000) := NULL;
  l_sequence		NUMBER;
  l_csr_handle          NUMBER;
  l_status              PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'p_repopulate_at_seq:' || p_repopulate_at_seq);
  END IF;

  l_err_loc := 200;
  OPEN l_csr_var FOR
    SELECT ROWID
    FROM   icx_cat_items_ctx_hdrs_tlp;

  LOOP
    l_err_loc := 300;
    l_rowid_tbl.DELETE;

    l_err_loc := 400;
    FETCH l_csr_var
    BULK COLLECT INTO l_rowid_tbl
    LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

    l_err_loc := 500;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'fetched from getItemRowsCsr rowcount:' ||l_rowid_tbl.COUNT);
    END IF;

    l_err_loc := 600;
    EXIT WHEN l_rowid_tbl.COUNT = 0;

    l_err_loc := 700;
    FOR i IN 1..p_special_ctx_sql_tbl.COUNT LOOP
      l_err_loc := 800;
      l_ctx_sqlstring_rec := p_special_ctx_sql_tbl(i);
      l_sequence := l_ctx_sqlstring_rec.bind_sequence;
      l_ctx_sql_string := null;
      l_err_loc := 900;
      IF (p_repopulate_at_seq = l_sequence) THEN
        l_err_loc := 1000;
	l_ctx_sql_string := l_ctx_sqlstring_rec.ctx_sql_string;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'l_sequence:' || l_sequence ||
              ', l_ctx_sql_string:' || l_ctx_sql_string);
        END IF;
	EXIT;
      END IF;
    END LOOP;

    l_err_loc := 1100;
    IF (l_ctx_sql_string IS NOT NULL) THEN
      l_err_loc := 1200;
      l_csr_handle:=DBMS_SQL.OPEN_CURSOR;
      l_err_loc := 1300;
      DBMS_SQL.PARSE(l_csr_handle, l_ctx_sql_string, DBMS_SQL.NATIVE);
      l_err_loc := 1400;
      DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
      DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_rowid', l_rowid_tbl);
      l_err_loc := 1500;
      l_status := DBMS_SQL.EXECUTE(l_csr_handle);
      l_err_loc := 1600;
      DBMS_SQL.CLOSE_CURSOR(l_csr_handle);
      l_err_loc := 1700;
      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        l_err_loc := 1800;
        COMMIT;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit done.');
        END IF;
      ELSE
        l_err_loc := 1900;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done.');
        END IF;
      END IF;
    END IF;

    l_err_loc := 2000;
    EXIT WHEN l_rowid_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
  END LOOP;
  l_err_loc := 2100;
  CLOSE l_csr_var;

  l_err_loc := 2200;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END popCtxBaseSpecAttForAllSrc;

-- populate Row with sequence: 2
-- Sequence 2 --> Supplier
-- No need to populate this row for Master items.
PROCEDURE popCtxBaseSpecSupplierAtt
(	p_special_ctx_sql_tbl   IN      ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'popCtxBaseSpecSupplierAtt';
  l_err_loc             PLS_INTEGER;
  l_rowid_tbl           DBMS_SQL.UROWID_TABLE;
  l_csr_var             g_csr_type;
  l_ctx_sqlstring_rec   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_rec_type;
  l_ctx_sql_string      VARCHAR2(4000) := NULL;
  l_sequence		NUMBER;
  l_csr_handle          NUMBER;
  l_status              PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Start');
  END IF;

  l_err_loc := 200;
  OPEN l_csr_var FOR
    SELECT ROWID
    FROM   icx_cat_items_ctx_hdrs_tlp
    WHERE  source_type <> 'MASTER_ITEM';

  LOOP
    l_err_loc := 300;
    l_rowid_tbl.DELETE;

    l_err_loc := 400;
    FETCH l_csr_var
    BULK COLLECT INTO l_rowid_tbl
    LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

    l_err_loc := 500;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'fetched from getItemRowsCsr rowcount:' ||l_rowid_tbl.COUNT);
    END IF;

    l_err_loc := 600;
    EXIT WHEN l_rowid_tbl.COUNT = 0;

    l_err_loc := 700;
    FOR i IN 1..p_special_ctx_sql_tbl.COUNT LOOP
      l_err_loc := 800;
      l_ctx_sqlstring_rec := p_special_ctx_sql_tbl(i);
      l_sequence := l_ctx_sqlstring_rec.bind_sequence;
      l_ctx_sql_string := null;
      l_err_loc := 900;
      IF (ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForSupplierRow = l_sequence) THEN
        l_err_loc := 1000;
	l_ctx_sql_string := l_ctx_sqlstring_rec.ctx_sql_string;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'l_sequence:' || l_sequence ||
              ', l_ctx_sql_string:' || l_ctx_sql_string);
        END IF;
	EXIT;
      END IF;
    END LOOP;

    l_err_loc := 1100;
    IF (l_ctx_sql_string IS NOT NULL) THEN
      l_err_loc := 1200;
      l_csr_handle:=DBMS_SQL.OPEN_CURSOR;
      l_err_loc := 1300;
      DBMS_SQL.PARSE(l_csr_handle, l_ctx_sql_string, DBMS_SQL.NATIVE);
      l_err_loc := 1400;
      DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
      DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_rowid', l_rowid_tbl);
      l_err_loc := 1500;
      l_status := DBMS_SQL.EXECUTE(l_csr_handle);
      l_err_loc := 1600;
      DBMS_SQL.CLOSE_CURSOR(l_csr_handle);
      l_err_loc := 1700;
      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        l_err_loc := 1800;
        COMMIT;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit done.');
        END IF;
      ELSE
        l_err_loc := 1900;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done.');
        END IF;
      END IF;
    END IF;

    l_err_loc := 2000;
    EXIT WHEN l_rowid_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
  END LOOP;
  l_err_loc := 2100;
  CLOSE l_csr_var;

  l_err_loc :=2200;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END popCtxBaseSpecSupplierAtt;

-- populate Row with sequence: 4 and 5
-- Sequence 4 --> Source
-- Populate this row for each source differently for
-- 1. Blankets/Quotations and GBPA
-- 2. Requisition templates
-- Sequence 5 --> Item Revision
-- Populate this row for each source differently for
-- 1. Blankets/Quotations and GBPA
-- 2. Requisition templates
-- Will not be populated for Master Items
-- Note: Calling procedure should take care of not calling this one with MASTER_ITEM source and sequence  = 5
PROCEDURE popCtxBaseSpecSrcAndItemRevAtt
(	p_doc_source		IN	VARCHAR2					,
	p_special_ctx_sql_tbl   IN      ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type    ,
        p_repopulate_at_seq     IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'popCtxBaseSpecSrcAndItemRevAtt';
  l_err_loc             PLS_INTEGER;
  l_source_type1        icx_cat_items_ctx_hdrs_tlp.source_type%TYPE;
  l_source_type2        icx_cat_items_ctx_hdrs_tlp.source_type%TYPE;
  l_rowid_tbl           DBMS_SQL.UROWID_TABLE;
  l_csr_var             g_csr_type;
  l_ctx_sqlstring_rec   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_rec_type;
  l_ctx_sql_string      VARCHAR2(4000) := NULL;
  l_sequence		NUMBER;
  l_csr_handle          NUMBER;
  l_status              PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Start; p_doc_source:' || p_doc_source ||
        ', p_repopulate_at_seq:' || p_repopulate_at_seq);
  END IF;

  IF (p_doc_source = ICX_CAT_UTIL_PVT.g_PODoc_const) THEN
    l_err_loc := 200;
    l_source_type1 := 'BLANKET';
    l_source_type2 := 'QUOTATION';
  ELSIF (p_doc_source = ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const) THEN
    l_err_loc := 300;
    l_source_type1 := 'TEMPLATE';
    l_source_type2 := 'INTERNAL_TEMPLATE';
  END IF;

  l_err_loc := 500;
  OPEN l_csr_var FOR
    SELECT ROWID
    FROM   icx_cat_items_ctx_hdrs_tlp
    WHERE  source_type IN (l_source_type1, l_source_type2);

  l_err_loc := 600;

  LOOP
    l_err_loc := 700;
    l_rowid_tbl.DELETE;

    l_err_loc := 800;
    FETCH l_csr_var
    BULK COLLECT INTO l_rowid_tbl
    LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

    l_err_loc := 900;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'fetched from getItemRowsCsr rowcount:' ||l_rowid_tbl.COUNT);
    END IF;

    l_err_loc := 1000;
    EXIT WHEN l_rowid_tbl.COUNT = 0;

    l_err_loc := 1100;
    FOR i IN 1..p_special_ctx_sql_tbl.COUNT LOOP
      l_err_loc := 1200;
      l_ctx_sqlstring_rec := p_special_ctx_sql_tbl(i);
      l_sequence := l_ctx_sqlstring_rec.bind_sequence;
      l_ctx_sql_string := null;
      IF (p_repopulate_at_seq = l_sequence) THEN
        l_err_loc := 1300;
	l_ctx_sql_string := l_ctx_sqlstring_rec.ctx_sql_string;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'l_sequence:' || l_sequence ||
              ', l_ctx_sql_string:' || l_ctx_sql_string);
        END IF;
	EXIT;
      END IF;
    END LOOP;

    l_err_loc := 1400;
    IF (l_ctx_sql_string IS NOT NULL) THEN
      l_err_loc := 1500;
      l_csr_handle:=DBMS_SQL.OPEN_CURSOR;
      l_err_loc := 1600;
      DBMS_SQL.PARSE(l_csr_handle, l_ctx_sql_string, DBMS_SQL.NATIVE);
      l_err_loc := 1700;
      DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
      DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_rowid', l_rowid_tbl);
      l_err_loc := 1800;
      l_status := DBMS_SQL.EXECUTE(l_csr_handle);
      l_err_loc := 1900;
      DBMS_SQL.CLOSE_CURSOR(l_csr_handle);
      l_err_loc := 2000;
      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        l_err_loc := 2100;
        COMMIT;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit done.');
        END IF;
      ELSE
        l_err_loc := 2200;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done.');
        END IF;
      END IF;
    END IF;

    l_err_loc := 2300;
    EXIT WHEN l_rowid_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
  END LOOP;
  l_err_loc := 2400;
  CLOSE l_csr_var;

  l_err_loc := 2500;
  IF (p_doc_source = ICX_CAT_UTIL_PVT.g_PODoc_const) THEN
    l_err_loc := 2600;
    INSERT INTO icx_cat_items_ctx_dtls_tlp
      (inventory_item_id, po_line_id, req_template_name,
       req_template_line_num, org_id, language,
       last_update_login, last_updated_by, last_update_date,
       internal_request_id, request_id, created_by, creation_date,
       sequence, ctx_desc)
    SELECT dtls.inventory_item_id, dtls.po_line_id, dtls.req_template_name,
           dtls.req_template_line_num, hdrs.org_id, dtls.language,
           dtls.last_update_login, dtls.last_updated_by, dtls.last_update_date,
           dtls.internal_request_id, dtls.request_id, dtls.created_by, dtls.creation_date,
           dtls.sequence, dtls.ctx_desc
    FROM icx_cat_items_ctx_dtls_tlp dtls, icx_cat_items_ctx_hdrs_tlp hdrs
    WHERE hdrs.source_type = 'GLOBAL_BLANKET'
    AND   hdrs.inventory_item_id = dtls.inventory_item_id
    AND   hdrs.po_line_id = dtls.po_line_id
    AND   hdrs.req_template_name = dtls.req_template_name
    AND   hdrs.req_template_line_num = dtls.req_template_line_num
    AND   hdrs.language = dtls.language
    AND   hdrs.owning_org_id = dtls.org_id
    AND   dtls.sequence = p_repopulate_at_seq;

    l_err_loc := 2700;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Num. of rows inserted for ga:' || SQL%ROWCOUNT);
    END IF;

    l_err_loc := 2800;
    IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
      l_err_loc := 2900;
      COMMIT;
      -- Must log
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit done after populating ctx string for ga.');
      END IF;
    ELSE
      l_err_loc := 3000;
      -- Must log
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit not done after populating ctx string for ga.');
      END IF;
    END IF;
  END IF;

  l_err_loc := 3100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
      RAISE;
END popCtxBaseSpecSrcAndItemRevAtt;

-- populate Row with sequence: between 100 and 5000
-- Will be same for BPAs, Quotes, GBPAs and Req Templates
-- Only for master items, this will populate only the description.
PROCEDURE popCtxBaseRegularAttributes
(	p_doc_source		IN	VARCHAR2					,
	p_regular_ctx_sql_tbl   IN      ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'popCtxBaseRegularAttributes';
  l_err_loc             PLS_INTEGER;
  l_rowid_tbl           DBMS_SQL.UROWID_TABLE;
  l_csr_var             g_csr_type;
  l_ctx_sqlstring_rec   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_rec_type;
  l_ctx_sql_string      VARCHAR2(4000) := NULL;
  l_sequence		NUMBER;
  l_csr_handle          NUMBER;
  l_status              PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Start; p_doc_source:' || p_doc_source);
  END IF;

  IF (p_doc_source = ICX_CAT_UTIL_PVT.g_PODoc_const) THEN
    l_err_loc := 200;
    OPEN l_csr_var FOR
      SELECT ROWID
      FROM   icx_cat_items_ctx_hdrs_tlp
      WHERE  source_type NOT IN ('MASTER_ITEM', 'GLOBAL_BLANKET');
  ELSE
    l_err_loc := 300;
    OPEN l_csr_var FOR
      SELECT ROWID
      FROM   icx_cat_items_ctx_hdrs_tlp
      WHERE  source_type = 'MASTER_ITEM';
  END IF;

  l_err_loc := 400;
  LOOP
    l_err_loc := 500;
    l_rowid_tbl.DELETE;

    l_err_loc := 600;
    FETCH l_csr_var
    BULK COLLECT INTO l_rowid_tbl
    LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

    l_err_loc := 700;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'fetched from getItemRowsCsr rowcount:' ||l_rowid_tbl.COUNT);
    END IF;

    l_err_loc := 800;
    EXIT WHEN l_rowid_tbl.COUNT = 0;

    l_err_loc := 900;
    FOR i IN 1..p_regular_ctx_sql_tbl.COUNT LOOP
      l_err_loc := 1000;
      l_ctx_sqlstring_rec := p_regular_ctx_sql_tbl(i);
      l_sequence := l_ctx_sqlstring_rec.bind_sequence;
      l_ctx_sql_string := l_ctx_sqlstring_rec.ctx_sql_string;
      l_err_loc := 1100;
      l_csr_handle :=DBMS_SQL.OPEN_CURSOR;
      l_err_loc := 1200;
      DBMS_SQL.PARSE(l_csr_handle, l_ctx_sql_string, DBMS_SQL.NATIVE);
      l_err_loc := 1300;
      DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_sequence);
      DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_rowid', l_rowid_tbl);
      l_err_loc := 1400;
      l_status := DBMS_SQL.EXECUTE(l_csr_handle);
      l_err_loc := 1500;
      DBMS_SQL.CLOSE_CURSOR(l_csr_handle);
    END LOOP;

    l_err_loc := 1600;
    IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
      l_err_loc := 1700;
      COMMIT;
      -- Must log
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit done.');
      END IF;
    ELSE
      l_err_loc := 1800;
      -- Must log
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit not done.');
      END IF;
    END IF;

    l_err_loc := 1900;
    EXIT WHEN l_rowid_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
  END LOOP;
  l_err_loc := 2000;
  CLOSE l_csr_var;

  l_err_loc := 2100;
  IF (p_doc_source = ICX_CAT_UTIL_PVT.g_PODoc_const) THEN
    l_err_loc := 2200;
    INSERT INTO icx_cat_items_ctx_dtls_tlp
      (inventory_item_id, po_line_id, req_template_name,
       req_template_line_num, org_id, language,
       last_update_login, last_updated_by, last_update_date,
       internal_request_id, request_id, created_by, creation_date,
       sequence, ctx_desc)
    SELECT dtls.inventory_item_id, dtls.po_line_id, dtls.req_template_name,
           dtls.req_template_line_num, hdrs.org_id, dtls.language,
           dtls.last_update_login, dtls.last_updated_by, dtls.last_update_date,
           dtls.internal_request_id, dtls.request_id, dtls.created_by, dtls.creation_date,
           dtls.sequence, dtls.ctx_desc
    FROM icx_cat_items_ctx_dtls_tlp dtls, icx_cat_items_ctx_hdrs_tlp hdrs
    WHERE hdrs.source_type = 'GLOBAL_BLANKET'
    AND   hdrs.inventory_item_id = dtls.inventory_item_id
    AND   hdrs.po_line_id = dtls.po_line_id
    AND   hdrs.req_template_name = dtls.req_template_name
    AND   hdrs.req_template_line_num = dtls.req_template_line_num
    AND   hdrs.language = dtls.language
    AND   hdrs.owning_org_id = dtls.org_id
    AND   dtls.sequence BETWEEN ICX_CAT_BUILD_CTX_SQL_PVT.g_seqStartReqularBaseRow
                        AND ICX_CAT_BUILD_CTX_SQL_PVT.g_seqEndReqularBaseRow;

    l_err_loc := 2300;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Num. of rows inserted for ga:' || SQL%ROWCOUNT);
    END IF;

    l_err_loc := 2400;
    IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
      l_err_loc := 2500;
      COMMIT;
      -- Must log
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit done after populating ctx string for ga.');
      END IF;
    ELSE
      l_err_loc := 2600;
      -- Must log
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit not done after populating ctx string for ga.');
      END IF;
    END IF;
  END IF;

  l_err_loc := 2700;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END popCtxBaseRegularAttributes;

PROCEDURE populateCtxBaseAtt
(       p_doc_source            IN      VARCHAR2                ,
        p_internal_request_id   IN      NUMBER
)
IS
  CURSOR getItemRowsCsr(p_source_type1 VARCHAR2,
                        p_source_type2 VARCHAR2,
                        p_internal_request_id NUMBER)  IS
    SELECT source_type, rowid
    FROM   icx_cat_items_ctx_hdrs_tlp
    WHERE  source_type IN (p_source_type1, p_source_type2)
    AND    internal_request_id = p_internal_request_id;

  l_rowid_tbl           DBMS_SQL.UROWID_TABLE;
  l_source_type_tbl     DBMS_SQL.VARCHAR2_TABLE;

  l_api_name            CONSTANT VARCHAR2(30)   := 'populateCtxBaseAtt';
  l_all_ctx_sql_tbl     ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_special_ctx_sql_tbl ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_regular_ctx_sql_tbl ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_ctx_sqlstring_rec   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_rec_type;
  l_err_loc             PLS_INTEGER;
  l_metadata_rec        ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_rec_type;
  l_csr_handle          NUMBER;
  l_status              PLS_INTEGER;
  l_source_type1        icx_cat_items_ctx_hdrs_tlp.source_type%TYPE;
  l_source_type2        icx_cat_items_ctx_hdrs_tlp.source_type%TYPE;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Start; p_doc_source:' || p_doc_source ||
        ', p_internal_request_id:' || p_internal_request_id);
  END IF;

  IF (NOT g_metadataTblFormed) THEN
    ICX_CAT_BUILD_CTX_SQL_PVT.buildMetadataInfo
           (0, g_special_metadata_tbl, g_regular_nontl_metadata_tbl, g_regular_tl_metadata_tbl);
    g_metadataTblFormed := TRUE;
  END IF;

  l_err_loc := 500;
  ICX_CAT_BUILD_CTX_SQL_PVT.buildCtxSql
           (0, p_doc_source, 'ROWID', g_special_metadata_tbl,
            g_regular_nontl_metadata_tbl, g_regular_tl_metadata_tbl,
            l_all_ctx_sql_tbl, l_special_ctx_sql_tbl, l_regular_ctx_sql_tbl);

  l_err_loc := 600;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i in 1..l_all_ctx_sql_tbl.COUNT LOOP
      l_ctx_sqlstring_rec := l_all_ctx_sql_tbl(i);
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'All ctx SQLs..Value at i:' || i ||
          ', sequence:' || l_ctx_sqlstring_rec.bind_sequence ||
          ', sql_string:' || l_ctx_sqlstring_rec.ctx_sql_string );

    END LOOP;
  END IF;

  l_err_loc := 700;
  IF (p_doc_source = ICX_CAT_UTIL_PVT.g_PODoc_const) THEN
    l_err_loc := 800;
    l_source_type1 := 'BLANKET';
    l_source_type2 := 'QUOTATION';
  ELSIF (p_doc_source = ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const) THEN
    l_err_loc := 900;
    l_source_type1 := 'TEMPLATE';
    l_source_type2 := 'INTERNAL_TEMPLATE';
  ELSE
    l_err_loc := 1100;
    l_source_type1 := 'MASTER_ITEM';
    l_source_type2 := l_source_type1;
  END IF;

  l_err_loc := 1200;
  OPEN getItemRowsCsr(l_source_type1, l_source_type2, p_internal_request_id);

  l_err_loc := 1300;
  LOOP
    l_err_loc := 1400;
    l_rowid_tbl.DELETE;
    l_source_type_tbl.DELETE;

    l_err_loc := 1500;
    FETCH getItemRowsCsr BULK COLLECT INTO
      l_source_type_tbl, l_rowid_tbl LIMIT ICX_CAT_UTIL_PVT.g_batch_size;
    l_err_loc := 1600;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'fetched from getItemRowsCsr rowcount:' ||l_rowid_tbl.COUNT);
    END IF;

    l_err_loc := 1700;
    EXIT WHEN l_rowid_tbl.COUNT = 0;

    l_err_loc := 1800;
    FOR i IN 1..l_all_ctx_sql_tbl.COUNT LOOP
      l_err_loc := 1900;
      l_ctx_sqlstring_rec := l_all_ctx_sql_tbl(i);
      l_err_loc := 2000;
      l_csr_handle:=DBMS_SQL.OPEN_CURSOR;
      l_err_loc := 2100;
      DBMS_SQL.PARSE(l_csr_handle, l_ctx_sqlstring_rec.ctx_sql_string, DBMS_SQL.NATIVE);
      l_err_loc := 2200;
      DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_ctx_sqlstring_rec.bind_sequence);
      DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_rowid', l_rowid_tbl);
      l_err_loc := 2300;
      l_status := DBMS_SQL.EXECUTE(l_csr_handle);
      l_err_loc := 2400;
      DBMS_SQL.CLOSE_CURSOR(l_csr_handle);
    END LOOP;

    l_err_loc := 2500;
    IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
      l_err_loc := 2600;
      COMMIT;
      -- Must log
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit done.');
      END IF;
    ELSE
      l_err_loc := 2700;
      -- Must log
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Commit not done.');
      END IF;
    END IF;

    l_err_loc := 2800;
    EXIT WHEN l_rowid_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
  END LOOP;
  l_err_loc := 2900;
  CLOSE getItemRowsCsr;

  l_err_loc := 3000;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done.');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateCtxBaseAtt;

PROCEDURE populateCtxCatgAtt
(       p_internal_request_id    IN      NUMBER
)
IS
  --Get all the categories that have atleast one searchable attributes
  --and has atleast one item loaded in the current internal_request_id
  CURSOR getCategoriesCsr(p_internal_request_id NUMBER) IS
    SELECT cat.rt_category_id
    FROM   icx_cat_categories_tl cat
    WHERE  cat.type = 2
    AND    cat.language = (SELECT language_code FROM fnd_languages WHERE installed_flag = 'B')
    AND    EXISTS (SELECT 'atleast one searchable descriptor'
                   FROM   icx_cat_attributes_tl att
                   where  att.rt_category_id = cat.rt_category_id
                   and    att.language = cat.language
                   and    att.searchable = 1)
    AND    EXISTS (SELECT 'atleast one item loaded in the current internal_request_id'
                   FROM   icx_cat_items_ctx_hdrs_tlp item
                   WHERE  item.ip_category_id = cat.rt_category_id
                   AND    item.internal_request_id = p_internal_request_id
                   AND    item.source_type NOT IN ('MASTER ITEM', 'GLOBAL_BLANKET'));

  CURSOR getItemRowsCsr(p_category_id NUMBER,
                        p_internal_request_id NUMBER)  IS
    SELECT rowid
    FROM   icx_cat_items_ctx_hdrs_tlp
    WHERE  ip_category_id = p_category_id
    AND    internal_request_id = p_internal_request_id
    AND    source_type NOT IN ('MASTER ITEM', 'GLOBAL_BLANKET');

  l_rowid_tbl                   DBMS_SQL.UROWID_TABLE;
  l_api_name                    CONSTANT VARCHAR2(30)   := 'populateCtxCatgAtt';
  l_all_ctx_sql_tbl             ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_special_ctx_sql_tbl         ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_regular_ctx_sql_tbl         ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_ctx_sqlstring_rec           ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_rec_type;
  l_metadata_rec                ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_rec_type;
  l_csr_handle                  NUMBER;
  l_status                      PLS_INTEGER;
  l_special_metadata_tbl        ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
  l_regular_nontl_metadata_tbl  ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
  l_regular_tl_metadata_tbl     ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
  l_start_catg_att_seq          NUMBER;
  l_end_catg_att_seq            NUMBER;
  l_err_loc                     PLS_INTEGER;
  l_start_date                  DATE;
  l_end_date                    DATE;
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
        ';(' || p_internal_request_id || ');');
  END IF;

  l_err_loc := 200;
  FOR catgRec IN getCategoriesCsr(p_internal_request_id) LOOP
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'for category:' || catgRec.rt_category_id);
    END IF;

    l_err_loc := 300;
    l_special_metadata_tbl.DELETE;
    l_regular_nontl_metadata_tbl.DELETE;
    l_regular_tl_metadata_tbl.DELETE;
    l_all_ctx_sql_tbl.DELETE;

    l_err_loc := 400;
    ICX_CAT_BUILD_CTX_SQL_PVT.buildMetadataInfo
           (catgRec.rt_category_id, l_special_metadata_tbl,
            l_regular_nontl_metadata_tbl, l_regular_tl_metadata_tbl);

    l_err_loc := 500;
    ICX_CAT_BUILD_CTX_SQL_PVT.buildCtxSql
           (catgRec.rt_category_id, NULL, 'ROWID', l_special_metadata_tbl,
            l_regular_nontl_metadata_tbl, l_regular_tl_metadata_tbl,
            l_all_ctx_sql_tbl, l_special_ctx_sql_tbl, l_regular_ctx_sql_tbl);

    l_err_loc := 1000;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FOR i in 1..l_all_ctx_sql_tbl.COUNT LOOP
        l_ctx_sqlstring_rec := l_all_ctx_sql_tbl(i);
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'All ctx SQLs..Value at i:' || i ||
            ', sequence:' || l_ctx_sqlstring_rec.bind_sequence ||
            ', sql_string:' || l_ctx_sqlstring_rec.ctx_sql_string );
      END LOOP;
    END IF;

    l_err_loc := 1200;
    OPEN getItemRowsCsr(catgRec.rt_category_id, p_internal_request_id);

    l_err_loc := 1300;
    LOOP
      l_err_loc := 1400;
      l_rowid_tbl.DELETE;
      l_err_loc := 1500;
      FETCH getItemRowsCsr BULK COLLECT INTO l_rowid_tbl LIMIT ICX_CAT_UTIL_PVT.g_batch_size;
      l_err_loc := 1600;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'fetched from getItemRowsCsr rowcount:' ||l_rowid_tbl.COUNT);
      END IF;

      l_err_loc := 1700;
      EXIT WHEN l_rowid_tbl.COUNT = 0;

      l_err_loc := 1800;
      FOR i IN 1..l_all_ctx_sql_tbl.COUNT LOOP
        l_err_loc := 1900;
        l_ctx_sqlstring_rec := l_all_ctx_sql_tbl(i);
        l_err_loc := 2000;
        l_csr_handle:=DBMS_SQL.OPEN_CURSOR;
        l_err_loc := 2100;
        DBMS_SQL.PARSE(l_csr_handle, l_ctx_sqlstring_rec.ctx_sql_string, DBMS_SQL.NATIVE);
        l_err_loc := 2200;
        DBMS_SQL.BIND_VARIABLE(l_csr_handle,':B_sequence', l_ctx_sqlstring_rec.bind_sequence);
        DBMS_SQL.BIND_ARRAY(l_csr_handle, ':B_rowid', l_rowid_tbl);
        l_err_loc := 2300;
        l_status := DBMS_SQL.EXECUTE(l_csr_handle);
        l_err_loc := 2400;
        DBMS_SQL.CLOSE_CURSOR(l_csr_handle);
      END LOOP; -- l_all_ctx_sql_tbl LOOP

      l_err_loc := 2500;
      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        l_err_loc := 2600;
        COMMIT;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit done.');
        END IF;
      ELSE
        l_err_loc := 2700;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done.');
        END IF;
      END IF;

      l_err_loc := 2800;
      EXIT WHEN l_rowid_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    END LOOP; -- getItemRowsCsr LOOP

    l_err_loc := 2900;
    CLOSE getItemRowsCsr;

  END LOOP; --catgRec LOOP

  l_err_loc := 3000;
  --populate category attributes For GLOBAL_BLANKET lines
  --rows with sequence between 5001 and 9999 will be done here for GBPA rows
  --loaded in the current internal_request_id
  l_start_catg_att_seq := ICX_CAT_BUILD_CTX_SQL_PVT.g_seqStartRegularCatgRow + 1;
  l_end_catg_att_seq := ICX_CAT_BUILD_CTX_SQL_PVT.g_seqEndRegularCatgRow;
  l_err_loc := 3100;
  INSERT INTO icx_cat_items_ctx_dtls_tlp
    (inventory_item_id, po_line_id, req_template_name,
     req_template_line_num, org_id, language,
     last_update_login, last_updated_by, last_update_date,
     internal_request_id, request_id, created_by, creation_date,
     sequence, ctx_desc)
  SELECT dtls.inventory_item_id, dtls.po_line_id, dtls.req_template_name,
         dtls.req_template_line_num, hdrs.org_id, dtls.language,
         dtls.last_update_login, dtls.last_updated_by, dtls.last_update_date,
         dtls.internal_request_id, dtls.request_id, dtls.created_by, dtls.creation_date,
         dtls.sequence, dtls.ctx_desc
  FROM icx_cat_items_ctx_dtls_tlp dtls, icx_cat_items_ctx_hdrs_tlp hdrs
  WHERE hdrs.source_type = 'GLOBAL_BLANKET'
  AND   hdrs.internal_request_id = p_internal_request_id
  AND   hdrs.inventory_item_id = dtls.inventory_item_id
  AND   hdrs.po_line_id = dtls.po_line_id
  AND   hdrs.req_template_name = dtls.req_template_name
  AND   hdrs.req_template_line_num = dtls.req_template_line_num
  AND   hdrs.owning_org_id = dtls.org_id
  AND   hdrs.language = dtls.language
  AND   dtls.sequence BETWEEN l_start_catg_att_seq AND l_end_catg_att_seq;

  l_err_loc := 3200;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Num. of rows inserted for ga:' || SQL%ROWCOUNT);
  END IF;

  l_err_loc := 3300;
  IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
    l_err_loc := 3400;
    COMMIT;
    -- Must log
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Commit done after populating ctx string for ga.');
    END IF;
  ELSE
    l_err_loc := 3500;
    -- Must log
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Commit not done after populating ctx string for ga.');
    END IF;
  END IF;

  l_err_loc := 3600;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateCtxCatgAtt;

PROCEDURE populateCtxOrgInfo(p_internal_request_id        IN NUMBER)
IS
  CURSOR getItemRowsCsr(p_internal_request_id NUMBER)  IS
    SELECT rowid
    FROM   icx_cat_items_ctx_hdrs_tlp
    WHERE  internal_request_id = p_internal_request_id;

  l_rowid_tbl           DBMS_SQL.UROWID_TABLE;
  l_api_name            CONSTANT VARCHAR2(30)   := 'populateCtxOrgInfo';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Start; p_internal_request_id:' || p_internal_request_id);
  END IF;

  l_err_loc := 150;
  OPEN getItemRowsCsr(p_internal_request_id);
  LOOP
    l_err_loc := 200;
    l_rowid_tbl.DELETE;

    l_err_loc := 300;
    FETCH getItemRowsCsr BULK COLLECT INTO l_rowid_tbl LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

    l_err_loc := 400;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'fetched from getItemRowsCsr rowcount:' ||l_rowid_tbl.COUNT);
    END IF;

    l_err_loc := 500;
    EXIT WHEN l_rowid_tbl.COUNT = 0;

    l_err_loc := 600;
    FORALL i IN 1..l_rowid_tbl.COUNT
      INSERT INTO icx_cat_items_ctx_dtls_tlp
      (inventory_item_id, po_line_id, req_template_name, req_template_line_num, org_id, language,
       last_update_login, last_updated_by, last_update_date, created_by, creation_date, sequence, ctx_desc)
      SELECT inventory_item_id, po_line_id, req_template_name, req_template_line_num, org_id, language,
             last_update_login, last_updated_by, last_update_date, created_by, creation_date, 10000, '<orgid>'
      FROM icx_cat_items_ctx_hdrs_tlp hdrs
      WHERE hdrs.rowid = l_rowid_tbl(i);

    l_err_loc := 700;
    FORALL i IN 1..l_rowid_tbl.COUNT
      INSERT INTO icx_cat_items_ctx_dtls_tlp
      (inventory_item_id, po_line_id, req_template_name, req_template_line_num, org_id, language,
       last_update_login, last_updated_by, last_update_date, created_by, creation_date, sequence, ctx_desc)
      SELECT inventory_item_id, po_line_id, req_template_name, req_template_line_num, org_id, language,
             last_update_login, last_updated_by, last_update_date, created_by, creation_date, 10001, to_char(org_id)
      FROM icx_cat_items_ctx_hdrs_tlp hdrs
      WHERE hdrs.rowid = l_rowid_tbl(i);

    l_err_loc := 800;
    FORALL i IN 1..l_rowid_tbl.COUNT
      INSERT INTO icx_cat_items_ctx_dtls_tlp
      (inventory_item_id, po_line_id, req_template_name, req_template_line_num, org_id, language,
       last_update_login, last_updated_by, last_update_date, created_by, creation_date, sequence, ctx_desc)
      SELECT inventory_item_id, po_line_id, req_template_name, req_template_line_num, org_id, language,
             last_update_login, last_updated_by, last_update_date, created_by, creation_date, 15000, '</orgid>'
      FROM icx_cat_items_ctx_hdrs_tlp hdrs
      WHERE hdrs.rowid = l_rowid_tbl(i);

    l_err_loc := 900;
    FORALL i IN 1..l_rowid_tbl.COUNT
      INSERT INTO icx_cat_items_ctx_dtls_tlp
      (inventory_item_id, po_line_id, req_template_name, req_template_line_num, org_id, language,
       last_update_login, last_updated_by, last_update_date, created_by, creation_date, sequence, ctx_desc)
      SELECT inventory_item_id, po_line_id, req_template_name, req_template_line_num, org_id, language,
             last_update_login, last_updated_by, last_update_date, created_by, creation_date, 15001,
             '<purchorgid>' || to_char(purchasing_org_id) || '</purchorgid>'
      FROM icx_cat_items_ctx_hdrs_tlp hdrs
      WHERE hdrs.rowid = l_rowid_tbl(i);

    l_err_loc := 1000;
    EXIT WHEN l_rowid_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
  END LOOP;

  l_err_loc := 1100;
  CLOSE getItemRowsCsr;

  l_err_loc := 1200;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done.');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateCtxOrgInfo;

/*
Procedure to re-populate the dtls for a particular source and internal_request_id,
The calling procedure should make sure to remove all the dtls for the source and internal_request_id
Commenting out for the moment

Values of p_doc_source:
   ICX_CAT_UTIL_PVT.g_PODoc_const           VARCHAR2(15)    := 'PO_DOCUMENTS';
   ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const  VARCHAR2(15)    := 'ReqTemplate';
   ICX_CAT_UTIL_PVT.g_MasterItemCsr_const   VARCHAR2(15)    := 'MASTER_ITEM';
Values of p_mode:
   ICX_CAT_UTIL_PVT.g_upgrade_const         VARCHAR2(15)    := 'UPGRADE';
   ICX_CAT_UTIL_PVT.g_online_const          VARCHAR2(15)    := 'ONLINE';
exec ICX_CAT_POPULATE_CTXSTRING_PVT.populateCtxString(ICX_CAT_UTIL_PVT.g_PODoc_const, -12, 'UPG', 2500)
PROCEDURE populateCtxString
(       p_doc_source    	IN      VARCHAR2                ,
        p_internal_request_id	IN      NUMBER                  ,
        p_mode          	IN      VARCHAR2                ,
        p_batch_size    	IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'populateCtxString';
  l_err_loc             PLS_INTEGER;
  l_all_ctx_sql_tbl     ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_special_ctx_sql_tbl ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_regular_ctx_sql_tbl ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 200;
  ICX_CAT_UTIL_PVT.setBatchSize(p_batch_size);

  l_err_loc := 300;
  populateCtxBaseAtt(p_doc_source, p_internal_request_id);

  l_err_loc := 400;
  populateCtxOrgInfo(p_internal_request_id);

  --Since there is no way to load the category attributes for a master item
  --So, call populateCtxCatgAtt when doc source <> ICX_CAT_UTIL_PVT.g_MasterItem_const
  l_err_loc := 500;
  IF (p_doc_source <> ICX_CAT_UTIL_PVT.g_MasterItemCsr_const) THEN
    populateCtxCatgAtt(p_internal_request_id);
  END IF;
  l_err_loc := 600;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    ROLLBACK;
    RAISE;
END populateCtxString;
*/

PROCEDURE updateItemsCtxHdrsTlp
(       p_category_id   	IN              NUMBER          ,
        p_internal_request_id	IN OUT NOCOPY   NUMBER          ,
        p_attribute_key		IN              VARCHAR2
)
IS

  l_api_name                    CONSTANT VARCHAR2(30)   := 'updateItemsCtxHdrsTlp';
  l_err_loc                     PLS_INTEGER;
  l_internal_request_id         NUMBER;
  l_csr_var                     g_csr_type;
  l_rowid_tbl                   DBMS_SQL.UROWID_TABLE;
  l_po_line_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_inventory_item_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_req_template_name_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_req_template_line_num_tbl   DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_start_sequence              NUMBER;
  l_end_sequence                NUMBER;
  l_err_string                  VARCHAR2(4000);

BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Start; (' || p_category_id ||', ' || p_attribute_key ||', ' || ');');
  END IF;
  -- Update ctx_desc and internal_request_id for all items if ip_category_id = 0 in hdrs tlp
  -- otherwise only update row with ip_category_id = p_category_id
  -- Return internal_request_id
  l_internal_request_id := ICX_CAT_UTIL_PVT.getNextSequenceForWhoColumns;
  p_internal_request_id := l_internal_request_id;
  l_err_loc := 200;
  OPEN l_csr_var FOR
    SELECT ROWID, po_line_id, inventory_item_id,
           req_template_name, req_template_line_num,
           org_id, language
    FROM   icx_cat_items_ctx_hdrs_tlp
    WHERE  (p_category_id = 0 OR ip_category_id = p_category_id);

  LOOP
    l_err_loc := 300;
    l_rowid_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_inventory_item_id_tbl.DELETE;
    l_req_template_name_tbl.DELETE;
    l_req_template_line_num_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;

    BEGIN
      l_err_loc := 400;
      FETCH l_csr_var
      BULK COLLECT INTO l_rowid_tbl, l_po_line_id_tbl, l_inventory_item_id_tbl,
          l_req_template_name_tbl, l_req_template_line_num_tbl,
          l_org_id_tbl, l_language_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 500;
      EXIT WHEN l_rowid_tbl.COUNT = 0;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows returned from the cursor:' || l_rowid_tbl.COUNT);
      END IF;

      l_err_loc := 600;
      IF (p_category_id > 0) THEN
        l_err_loc := 700;
        l_start_sequence := ICX_CAT_BUILD_CTX_SQL_PVT.g_seqStartRegularCatgRow + 1;
        l_end_sequence := ICX_CAT_BUILD_CTX_SQL_PVT.g_seqEndRegularCatgRow;
        l_err_loc := 800;
        FORALL i IN 1..l_rowid_tbl.COUNT
          DELETE FROM icx_cat_items_ctx_dtls_tlp
          WHERE po_line_id = l_po_line_id_tbl(i)
          AND   inventory_item_id = l_inventory_item_id_tbl(i)
          AND   req_template_name = l_req_template_name_tbl(i)
          AND   req_template_line_num = l_req_template_line_num_tbl(i)
          AND   org_id = l_org_id_tbl(i)
          AND   language = l_language_tbl(i)
          AND   sequence BETWEEN l_start_sequence AND l_end_sequence;

        l_err_loc := 900;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              ' Num. of rows deleted from dtls for category_id:' || SQL%ROWCOUNT);
        END IF;
      ELSE
        l_err_loc := 1000;
        IF p_attribute_key IN ('SUPPLIER_PART_NUM', 'SUPPLIER_PART_AUXID') THEN
          l_err_loc := 1100;
          -- Delete the row with sequence 1 for re-populate
          FORALL i IN 1..l_rowid_tbl.COUNT
            DELETE FROM icx_cat_items_ctx_dtls_tlp
            WHERE po_line_id = l_po_line_id_tbl(i)
            AND   inventory_item_id = l_inventory_item_id_tbl(i)
            AND   req_template_name = l_req_template_name_tbl(i)
            AND   req_template_line_num = l_req_template_line_num_tbl(i)
            AND   org_id = l_org_id_tbl(i)
            AND   language = l_language_tbl(i)
            AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqMandatoryBaseRow;

          l_err_loc := 1200;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Num. of rows deleted from dtls for partNum, auxid:' || SQL%ROWCOUNT);
          END IF;
        ELSIF (p_attribute_key = 'SUPPLIER') THEN
          l_err_loc := 1300;
          -- Delete the row with sequence 2 for re-populate
          FORALL i IN 1..l_rowid_tbl.COUNT
            DELETE FROM icx_cat_items_ctx_dtls_tlp
            WHERE po_line_id = l_po_line_id_tbl(i)
            AND   inventory_item_id = l_inventory_item_id_tbl(i)
            AND   req_template_name = l_req_template_name_tbl(i)
            AND   req_template_line_num = l_req_template_line_num_tbl(i)
            AND   org_id = l_org_id_tbl(i)
            AND   language = l_language_tbl(i)
            AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForSupplierRow;

          l_err_loc := 1400;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Num. of rows deleted from dtls for supp:' || SQL%ROWCOUNT);
          END IF;
        ELSIF (p_attribute_key = 'INTERNAL_ITEM_NUM') THEN
          l_err_loc := 1500;
          -- Delete the row with sequence 3 for re-populate
          FORALL i IN 1..l_rowid_tbl.COUNT
            DELETE FROM icx_cat_items_ctx_dtls_tlp
            WHERE po_line_id = l_po_line_id_tbl(i)
            AND   inventory_item_id = l_inventory_item_id_tbl(i)
            AND   req_template_name = l_req_template_name_tbl(i)
            AND   req_template_line_num = l_req_template_line_num_tbl(i)
            AND   org_id = l_org_id_tbl(i)
            AND   language = l_language_tbl(i)
            AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForInternalItemNumRow;

          l_err_loc := 1600;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Num. of rows deleted from dtls for intItemNum:' || SQL%ROWCOUNT);
          END IF;
        ELSIF (p_attribute_key = 'SOURCE') THEN
          l_err_loc := 1700;
          -- Delete the row with sequence 4 for re-populate
          FORALL i IN 1..l_rowid_tbl.COUNT
            DELETE FROM icx_cat_items_ctx_dtls_tlp
            WHERE po_line_id = l_po_line_id_tbl(i)
            AND   inventory_item_id = l_inventory_item_id_tbl(i)
            AND   req_template_name = l_req_template_name_tbl(i)
            AND   req_template_line_num = l_req_template_line_num_tbl(i)
            AND   org_id = l_org_id_tbl(i)
            AND   language = l_language_tbl(i)
            AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForSourceRow;

          l_err_loc := 1800;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Num. of rows deleted from dtls for source:' || SQL%ROWCOUNT);
          END IF;
        ELSIF (p_attribute_key = 'ITEM_REVISION') THEN
          l_err_loc := 1900;
          -- Delete the row with sequence 5 for re-populate
          FORALL i IN 1..l_rowid_tbl.COUNT
            DELETE FROM icx_cat_items_ctx_dtls_tlp
            WHERE po_line_id = l_po_line_id_tbl(i)
            AND   inventory_item_id = l_inventory_item_id_tbl(i)
            AND   req_template_name = l_req_template_name_tbl(i)
            AND   req_template_line_num = l_req_template_line_num_tbl(i)
            AND   org_id = l_org_id_tbl(i)
            AND   language = l_language_tbl(i)
            AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForItemRevisionRow;

          l_err_loc := 2000;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Num. of rows deleted from dtls for itemrev:' || SQL%ROWCOUNT);
          END IF;
        ELSIF (p_attribute_key = 'SHOPPING_CATEGORY') THEN
          l_err_loc := 2100;
          -- Delete the row with sequence 6 for re-populate
          FORALL i IN 1..l_rowid_tbl.COUNT
            DELETE FROM icx_cat_items_ctx_dtls_tlp
            WHERE po_line_id = l_po_line_id_tbl(i)
            AND   inventory_item_id = l_inventory_item_id_tbl(i)
            AND   req_template_name = l_req_template_name_tbl(i)
            AND   req_template_line_num = l_req_template_line_num_tbl(i)
            AND   org_id = l_org_id_tbl(i)
            AND   language = l_language_tbl(i)
            AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForShoppingCategoryRow;

          l_err_loc := 2200;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Num. of rows deleted from dtls for shopCatg:' || SQL%ROWCOUNT);
          END IF;
        ELSE
          l_err_loc := 2300;
          -- Delete the row with sequence between 100 and 5000 for re-populate
          l_start_sequence := ICX_CAT_BUILD_CTX_SQL_PVT.g_seqStartReqularBaseRow + 1;
          l_end_sequence := ICX_CAT_BUILD_CTX_SQL_PVT.g_seqEndReqularBaseRow;
          l_err_loc := 2400;
          FORALL i IN 1..l_rowid_tbl.COUNT
            DELETE FROM icx_cat_items_ctx_dtls_tlp
            WHERE po_line_id = l_po_line_id_tbl(i)
            AND   inventory_item_id = l_inventory_item_id_tbl(i)
            AND   req_template_name = l_req_template_name_tbl(i)
            AND   req_template_line_num = l_req_template_line_num_tbl(i)
            AND   org_id = l_org_id_tbl(i)
            AND   language = l_language_tbl(i)
            AND   sequence BETWEEN l_start_sequence AND l_end_sequence;

          l_err_loc := 2500;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Num. of rows deleted from dtls for regular base attrs:' || SQL%ROWCOUNT);
          END IF;
        END IF;
      END IF;

      l_err_loc := 2600;
      FORALL i IN 1..l_rowid_tbl.COUNT
        UPDATE icx_cat_items_ctx_hdrs_tlp
        SET ctx_desc = NULL,
            last_update_login = l_internal_request_id,
            last_updated_by = l_internal_request_id,
            last_update_date = sysdate,
            internal_request_id = l_internal_request_id
        WHERE rowid = l_rowid_tbl(i);

      l_err_loc := 2800;
      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        l_err_loc := 2900;
        COMMIT;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit done.');
        END IF;
      ELSE
        l_err_loc := 3000;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done.');
        END IF;
      END IF;

      l_err_loc := 3100;
      EXIT WHEN l_rowid_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := 'ICX_CAT_POPULATE_CTXSTRING_PVT.updateItemsCtxHdrsTlp' ||l_err_loc;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 3200;
        CLOSE l_csr_var;
        l_err_loc := 3300;
        OPEN l_csr_var FOR
          SELECT ROWID, po_line_id, inventory_item_id,
                 req_template_name, req_template_line_num,
                 org_id, language
          FROM   icx_cat_items_ctx_hdrs_tlp
          WHERE  (p_category_id = 0 OR ip_category_id = p_category_id)
          AND    internal_request_id <> l_internal_request_id;
    END;
  END LOOP;

  l_err_loc := 3400;
  IF (l_csr_var%ISOPEN) THEN
    l_err_loc := 3500;
    CLOSE l_csr_var;
  END IF;

  l_err_loc := 3600;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    IF (l_csr_var%ISOPEN) THEN
      CLOSE l_csr_var;
    END IF;
    RAISE;
END updateItemsCtxHdrsTlp;

PROCEDURE rePopulateCategoryAttributes
(       p_category_id   IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'rePopulateCategoryAttributes';
  l_err_loc             PLS_INTEGER;
  l_internal_request_id NUMBER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ';(' || p_category_id ||');' ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  -- Update ctx_desc and internal_request_id for all items with ip_category_id = p_category_id in hdrs tlp
  -- Delete all rows between 5001 and 9999 for items that has ip_category_id = p_category_id
  -- Call the populateCtxCatgAtt with the requestId
  updateItemsCtxHdrsTlp(p_category_id, l_internal_request_id, null);
  l_err_loc := 200;
  populateCtxCatgAtt(l_internal_request_id);

  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END rePopulateCategoryAttributes;

PROCEDURE rePopulateBaseAttributes
(       p_attribute_key IN      VARCHAR2        ,
        p_searchable    IN      NUMBER
)
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'rePopulateBaseAttributes';
  l_err_loc                     PLS_INTEGER;
  l_special_metadata_tbl        ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
  l_regular_nontl_metadata_tbl  ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
  l_regular_tl_metadata_tbl     ICX_CAT_BUILD_CTX_SQL_PVT.g_metadata_tbl_type;
  l_all_ctx_sql_tbl             ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_special_ctx_sql_tbl         ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_regular_ctx_sql_tbl         ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type;
  l_internal_request_id         NUMBER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  -- Update ctx_desc and internal_request_id for all items in hdrs tlp
  -- Call the buildMetaDataInfo for the ip_category_id = 0
  -- IF p_attribute_key is a special attribute then
  -- Re-populate only special attribute rows i.e. sequence between 1 and 100
  -- Else re-populate all rows between 100 and 5000
  -- Call the buildCtxSql for each source

  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
        ';(' || p_attribute_key ||', ' || p_searchable || ');' ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  -- If the changed descriptor is one of the following, then just return no processing is needed
  l_err_loc := 200;
  IF ( p_attribute_key IN ('UOM', 'PRICE', 'CURRENCY',
                           'FUNCTIONAL_PRICE', 'FUNCTIONAL_CURRENCY',
                           'SUPPLIER_SITE', 'PURCHASING_CATEGORY',
                           'THUMBNAIL_IMAGE', 'PICTURE', 'ATTACHMENT_URL',
                           'SUPPLIER_URL', 'MANUFACTURER_URL'))
  THEN
    l_err_loc := 300;
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'returning; for p_attribute_key:' || p_attribute_key);
    END IF;
    RETURN;
  END IF;

  l_err_loc := 400;
  -- update the ctx_desc in icx_cat_items_ctx_hdrs_tlp and
  -- delete the appropriate row/rows from icx_cat_items_ctx_dtls_tlp
  updateItemsCtxHdrsTlp(0, l_internal_request_id, p_attribute_key);

  l_err_loc := 500;
  -- Need to insert the appropriate row/rows back into
  -- icx_cat_items_ctx_dtls_tlp depending upon the source and p_attribute_key
  ICX_CAT_BUILD_CTX_SQL_PVT.buildMetadataInfo
    (0, l_special_metadata_tbl, l_regular_nontl_metadata_tbl, l_regular_tl_metadata_tbl);

  l_err_loc := 600;
  ICX_CAT_BUILD_CTX_SQL_PVT.buildCtxSql
    (0, ICX_CAT_UTIL_PVT.g_PODoc_const, 'ROWID', l_special_metadata_tbl,
     l_regular_nontl_metadata_tbl, l_regular_tl_metadata_tbl,
     l_all_ctx_sql_tbl, l_special_ctx_sql_tbl, l_regular_ctx_sql_tbl);

  l_err_loc := 700;

  IF (p_attribute_key IN ('SUPPLIER_PART_NUM', 'SUPPLIER_PART_AUXID')) THEN
    l_err_loc := 800;
    -- Row with sequence 1
    popCtxBaseSpecAttForAllSrc(ICX_CAT_BUILD_CTX_SQL_PVT.g_seqMandatoryBaseRow,
                               l_special_ctx_sql_tbl);
  END IF;

  IF (p_searchable = 1 AND
      p_attribute_key IN ('SUPPLIER_PART_NUM', 'SUPPLIER_PART_AUXID', 'SUPPLIER',
                          'INTERNAL_ITEM_NUM', 'SOURCE', 'ITEM_REVISION',
                          'SHOPPING_CATEGORY'))
  THEN
    l_err_loc := 900;
    IF (p_attribute_key = 'SUPPLIER') THEN
      l_err_loc := 1000;
      -- Row with sequence 2
      popCtxBaseSpecSupplierAtt(l_special_ctx_sql_tbl);
    ELSIF (p_attribute_key = 'INTERNAL_ITEM_NUM') THEN
      l_err_loc := 1100;
      -- Row with sequence 3
      popCtxBaseSpecAttForAllSrc(ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForInternalItemNumRow,
                                 l_special_ctx_sql_tbl);
    ELSIF (p_attribute_key IN ('SOURCE', 'ITEM_REVISION')) THEN
      l_err_loc := 1200;
      -- Row  with sequence 4 (source) and 5 (Item Revision)
      IF (p_attribute_key = 'SOURCE') THEN
        l_err_loc := 1300;
        popCtxBaseSpecSrcAndItemRevAtt(ICX_CAT_UTIL_PVT.g_PODoc_const,
                                       l_special_ctx_sql_tbl,
                                       ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForSourceRow);
      ELSE
        l_err_loc := 1400;
        popCtxBaseSpecSrcAndItemRevAtt(ICX_CAT_UTIL_PVT.g_PODoc_const,
                                       l_special_ctx_sql_tbl,
                                       ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForItemRevisionRow);
      END IF;

      l_err_loc := 1500;
      l_all_ctx_sql_tbl.DELETE;
      l_special_ctx_sql_tbl.DELETE;
      l_regular_ctx_sql_tbl.DELETE;

      l_err_loc := 1600;
      -- Build the ctx sqls for Req templates.
      ICX_CAT_BUILD_CTX_SQL_PVT.buildCtxSql
        (0, ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const, 'ROWID', l_special_metadata_tbl,
         l_regular_nontl_metadata_tbl, l_regular_tl_metadata_tbl,
         l_all_ctx_sql_tbl, l_special_ctx_sql_tbl, l_regular_ctx_sql_tbl);
      l_err_loc := 1700;
      IF (p_attribute_key = 'SOURCE') THEN
        l_err_loc := 1800;
        popCtxBaseSpecSrcAndItemRevAtt(ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const,
                                       l_special_ctx_sql_tbl,
                                       ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForSourceRow);
      ELSE
        l_err_loc := 1900;
        popCtxBaseSpecSrcAndItemRevAtt(ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const,
                                       l_special_ctx_sql_tbl,
                                       ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForItemRevisionRow);
      END IF;

      l_err_loc := 2000;
    ELSIF (p_attribute_key = 'SHOPPING_CATEGORY') THEN
      l_err_loc := 2400;
      -- Row with sequence 6
      popCtxBaseSpecAttForAllSrc(ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForShoppingCategoryRow,
                                 l_special_ctx_sql_tbl);
    END IF;
  ELSE
    l_err_loc := 2500;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'In else loop for p_attribute_key:' || p_attribute_key);
    END IF;
    -- Row with sequence between 101 - 5000
    l_err_loc := 2600;
    popCtxBaseRegularAttributes(ICX_CAT_UTIL_PVT.g_PODoc_const,
                                l_regular_ctx_sql_tbl);

    l_err_loc := 2700;
    l_all_ctx_sql_tbl.DELETE;
    l_special_ctx_sql_tbl.DELETE;
    l_regular_ctx_sql_tbl.DELETE;

    l_err_loc := 2800;
    -- Build the ctx_sql_table for Master Items
    ICX_CAT_BUILD_CTX_SQL_PVT.buildCtxSql
      (0, ICX_CAT_UTIL_PVT.g_MasterItemCsr_const, 'ROWID', l_special_metadata_tbl,
       l_regular_nontl_metadata_tbl, l_regular_tl_metadata_tbl,
       l_all_ctx_sql_tbl, l_special_ctx_sql_tbl, l_regular_ctx_sql_tbl);
    l_err_loc := 2900;
    popCtxBaseRegularAttributes(ICX_CAT_UTIL_PVT.g_MasterItemCsr_const,
                                l_regular_ctx_sql_tbl);
  END IF;

  l_err_loc := 3000;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END rePopulateBaseAttributes;

PROCEDURE handleSearchableFlagChange
(       p_attribute_id  IN      NUMBER          ,
        p_attribute_key IN      VARCHAR2        ,
        p_category_id   IN      NUMBER          ,
        p_searchable    IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'handleSearchableFlagChange';
  l_err_loc             PLS_INTEGER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 200;
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 300;
  ICX_CAT_UTIL_PVT.setCommitParameter(FND_API.G_TRUE);

  l_err_loc := 400;
  IF (p_category_id = 0) THEN
    l_err_loc := 500;
    rePopulateBaseAttributes(p_attribute_key, p_searchable);
  ELSE
    l_err_loc := 600;
    -- Update ctx_desc and internal_request_id for all items with ip_category_id = p_category_id in hdrs tlp
    -- Delete all rows between 5001 and 9999 for items that has ip_category_id = p_category_id
    -- Call the populateCtxCatgAtt with the requestId
    rePopulateCategoryAttributes(p_category_id);
  END IF;

  l_err_loc := 700;
  -- Call the rebuild index
  ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;

  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    ROLLBACK;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
    RAISE;
END handleSearchableFlagChange;

PROCEDURE handleCategoryRename
(       p_category_id   IN      NUMBER          ,
        p_category_name IN      VARCHAR2        ,
        p_language      IN      VARCHAR2
)
IS

  l_api_name                    CONSTANT VARCHAR2(30)   := 'handleCategoryRename';
  l_err_loc                     PLS_INTEGER;
  l_internal_request_id         NUMBER;
  l_searchable                  NUMBER;
  l_section_tag                 NUMBER;
  l_csr_var                     g_csr_type;
  l_rowid_tbl                   DBMS_SQL.UROWID_TABLE;
  l_po_line_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_inventory_item_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_req_template_name_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_req_template_line_num_tbl   DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_err_string                  VARCHAR2(4000);
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 200;
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 300;
  ICX_CAT_UTIL_PVT.setCommitParameter(FND_API.G_TRUE);

  l_err_loc := 400;
  -- Update ctx_desc and internal_request_id for all items belonging to p_category_id and p_language in hdrs tlp
  l_internal_request_id := ICX_CAT_UTIL_PVT.getNextSequenceForWhoColumns;

  l_err_loc := 500;
  ICX_CAT_BUILD_CTX_SQL_PVT.checkIfAttributeIsSrchble
                ('SHOPPING_CATEGORY', l_searchable, l_section_tag);

  l_err_loc := 600;
  OPEN l_csr_var FOR
    SELECT ROWID, po_line_id, inventory_item_id,
           req_template_name, req_template_line_num,
           org_id, language
    FROM   icx_cat_items_ctx_hdrs_tlp
    WHERE  ip_category_id = p_category_id
    AND    language = p_language;

  LOOP
    l_err_loc := 700;
    l_rowid_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_inventory_item_id_tbl.DELETE;
    l_req_template_name_tbl.DELETE;
    l_req_template_line_num_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;

    BEGIN
      l_err_loc := 800;
      FETCH l_csr_var
      BULK COLLECT INTO l_rowid_tbl, l_po_line_id_tbl, l_inventory_item_id_tbl,
          l_req_template_name_tbl, l_req_template_line_num_tbl,
          l_org_id_tbl, l_language_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 900;
      EXIT WHEN l_rowid_tbl.COUNT = 0;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num of rows from ctx_hdrs for category rename:' || l_rowid_tbl.COUNT);
      END IF;

      l_err_loc := 1000;
      IF (l_searchable = 1) THEN
        l_err_loc := 1100;
        FORALL i IN 1..l_rowid_tbl.COUNT
          UPDATE icx_cat_items_ctx_dtls_tlp
          SET    ctx_desc = '<' || l_section_tag || '>' ||
                            replace(replace(p_category_name, '<', ' '), '>', ' ') ||
                            '</' || l_section_tag || '>'
          WHERE po_line_id = l_po_line_id_tbl(i)
          AND   inventory_item_id = l_inventory_item_id_tbl(i)
          AND   req_template_name = l_req_template_name_tbl(i)
          AND   req_template_line_num = l_req_template_line_num_tbl(i)
          AND   org_id = l_org_id_tbl(i)
          AND   language = l_language_tbl(i)
          AND   sequence = ICX_CAT_BUILD_CTX_SQL_PVT.g_seqForShoppingCategoryRow;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Num of rows updated in ctx_dtls for category rename:' || SQL%ROWCOUNT);
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

      l_err_loc := 1300;
      FORALL i IN 1..l_rowid_tbl.COUNT
        UPDATE icx_cat_items_ctx_hdrs_tlp
        SET ctx_desc = NULL,
            ip_category_name = p_category_name,
            last_update_login = l_internal_request_id,
            last_updated_by = l_internal_request_id,
            last_update_date = sysdate,
            internal_request_id = l_internal_request_id
        WHERE rowid = l_rowid_tbl(i);

      l_err_loc := 1400;
      IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
        l_err_loc := 1500;
        COMMIT;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit done.');
        END IF;
      ELSE
        l_err_loc := 1600;
        -- Must log
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Commit not done.');
        END IF;
      END IF;

      l_err_loc := 1700;
      EXIT WHEN l_rowid_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := 'ICX_CAT_POPULATE_CTXSTRING_PVT.handleCategoryRename' ||l_err_loc;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 1800;
        CLOSE l_csr_var;
        l_err_loc := 1900;
        OPEN l_csr_var FOR
          SELECT ROWID, po_line_id, inventory_item_id,
                 req_template_name, req_template_line_num,
                 org_id, language
          FROM   icx_cat_items_ctx_hdrs_tlp
          WHERE  ip_category_id = p_category_id
          AND    language = p_language
          AND    internal_request_id <> l_internal_request_id;
    END;
  END LOOP;

  l_err_loc := 2000;
  IF (l_csr_var%ISOPEN) THEN
    l_err_loc := 2100;
    CLOSE l_csr_var;
  END IF;

  l_err_loc := 2200;
  -- Call the rebuild index
  ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;

  l_err_loc := 2300;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name,
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    ROLLBACK;
    -- Call the rebuild index
    ICX_CAT_INTERMEDIA_INDEX_PVT.rebuild_index;
    RAISE;
END handleCategoryRename;

END ICX_CAT_POPULATE_CTXSTRING_PVT;

/
