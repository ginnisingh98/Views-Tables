--------------------------------------------------------
--  DDL for Package Body ICX_CAT_BUILD_CTX_SQL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_BUILD_CTX_SQL_PVT" AS
/* $Header: ICXVBCSB.pls 120.8.12010000.5 2013/11/18 09:09:10 jaxin ship $*/

-- Global Constants
G_PKG_NAME              CONSTANT VARCHAR2(30) :='ICX_CAT_BUILD_CTX_SQL_PVT';

-- Default max length for each row in icx_por_ctx_tl, set to 3600, leaving
-- 400 bytes for section tags
g_default_max_length    CONSTANT NUMBER := 3600;

PROCEDURE checkIfAttributeIsSrchble(p_attribute_key     IN VARCHAR2,
                                    p_searchable        OUT NOCOPY NUMBER,
                                    p_section_tag       OUT NOCOPY NUMBER)
IS
  l_api_name	CONSTANT VARCHAR2(30)   := 'checkIfAttributeIsSrchble';
  l_err_loc	PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  SELECT searchable, section_tag
  INTO   p_searchable, p_section_tag
  FROM   icx_cat_attributes_tl
  WHERE  key = p_attribute_key
  AND    rownum = 1;

  l_err_loc := 200;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'For p_attribute_key:' || p_attribute_key ||
        ', p_searchable:' || p_searchable ||
        ', p_section_tag:' || p_section_tag );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    p_searchable := 0;
    p_section_tag:= -1;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Exception caught, So for p_attribute_key:' || p_attribute_key ||
          ', p_searchable:' || p_searchable ||
          ', p_section_tag:' || p_section_tag );
    END IF;
END checkIfAttributeIsSrchble;

PROCEDURE buildMetadataInfo(p_category_id                       IN              NUMBER,
                            p_special_metadata_tbl              IN OUT NOCOPY   g_metadata_tbl_type,
                            p_regular_nontl_metadata_tbl        IN OUT NOCOPY   g_metadata_tbl_type,
                            p_regular_tl_metadata_tbl           IN OUT NOCOPY   g_metadata_tbl_type)
IS
  CURSOR getSearchableMetadataCsr(p_category_id NUMBER) IS
    SELECT attribute_id, key, type,
           section_tag, stored_in_table, stored_in_column
    FROM   icx_cat_attributes_tl
    WHERE  rt_category_id = p_category_id
    AND    language = ( SELECT language_code FROM fnd_languages WHERE installed_flag = 'B')
    AND    searchable = 1
    ORDER BY attribute_id;

  ----- Start of declaring columns selected in the cursor -----

  l_attribute_id_tbl            DBMS_SQL.NUMBER_TABLE;
  l_key_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  l_type_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_section_tag_tbl             DBMS_SQL.NUMBER_TABLE;
  l_stored_in_table_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_stored_in_column_tbl        DBMS_SQL.VARCHAR2_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'buildMetadataInfo';
  l_err_loc                     PLS_INTEGER     := 100;
  l_special_index               NUMBER          := 0;
  l_regular_nontl_index         NUMBER          := 0;
  l_regular_tl_index            NUMBER          := 0;
  l_category_index              NUMBER          := 0;
  l_metadata_rec                g_metadata_rec_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ', p_category_id:' || p_category_id);
  END IF;

  OPEN getSearchableMetadataCsr(p_category_id);

  l_err_loc := 200;
  l_attribute_id_tbl.DELETE;
  l_key_tbl.DELETE;
  l_type_tbl.DELETE;
  l_section_tag_tbl.DELETE;
  l_stored_in_table_tbl.DELETE;
  l_stored_in_column_tbl.DELETE;

  l_err_loc := 250;
  FETCH getSearchableMetadataCsr BULK COLLECT INTO
    l_attribute_id_tbl, l_key_tbl, l_type_tbl,
    l_section_tag_tbl, l_stored_in_table_tbl, l_stored_in_column_tbl;

  l_err_loc := 300;
  CLOSE getSearchableMetadataCsr;

  l_err_loc := 400;
  FOR i IN 1..l_attribute_id_tbl.COUNT LOOP

    l_err_loc := 500;
    l_metadata_rec.attribute_id := l_attribute_id_tbl(i);
    l_metadata_rec.key := l_key_tbl(i);
    l_metadata_rec.type := l_type_tbl(i);
    l_metadata_rec.section_tag := l_section_tag_tbl(i);
    l_metadata_rec.stored_in_table := l_stored_in_table_tbl(i);
    l_metadata_rec.stored_in_column := l_stored_in_column_tbl(i);

    l_err_loc := 600;
    IF (l_type_tbl(i) IN (0,2)) THEN
      l_err_loc := 700;
      IF (l_key_tbl(i) = 'LONG_DESCRIPTION' AND p_category_id = 0) THEN
        l_err_loc := 800;
        -- bug 17577010: change to 4000 as corresponding column changed in DB
        l_metadata_rec.attribute_length := 4000;
      ELSIF (l_key_tbl(i) = 'DESCRIPTION' AND p_category_id = 0) THEN
        l_err_loc := 900;
        l_metadata_rec.attribute_length := 240;
      ELSE
        l_err_loc := 1000;
        l_metadata_rec.attribute_length := 700;
      END IF;
    ELSE
      l_err_loc := 1100;
      l_metadata_rec.attribute_length := 100;
    END IF;

    l_err_loc := 1200;
    -- 17076597 changes added UN_NUMBER and HAZARD_CLASS
    IF (p_category_id = 0 AND
        l_key_tbl(i) IN ('SUPPLIER', 'INTERNAL_ITEM_NUM', 'SOURCE',
                         'ITEM_REVISION', 'SHOPPING_CATEGORY',
                         'SUPPLIER_PART_NUM', 'SUPPLIER_PART_AUXID' ,'UN_NUMBER', 'HAZARD_CLASS'))
    THEN
      l_err_loc := 1300;
      l_special_index := l_special_index + 1;
      p_special_metadata_tbl(l_special_index) := l_metadata_rec;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'specialIndex:' || l_special_index ||
            ', key:' || l_metadata_rec.key ||
            ', type:' || l_metadata_rec.type ||
            ', p_category_id:' || p_category_id);
      END IF;
    ELSIF (l_stored_in_table_tbl(i) IS NOT NULL AND
           l_stored_in_column_tbl(i) IS NOT NULL)
    THEN
      l_err_loc := 1400;
      IF (l_type_tbl(i) <> 2) THEN
        l_err_loc := 1500;
        l_regular_nontl_index := l_regular_nontl_index + 1;
        p_regular_nontl_metadata_tbl(l_regular_nontl_index) := l_metadata_rec;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'l_regular_nontl_index:' || l_regular_nontl_index ||
              ', key:' || l_metadata_rec.key ||
              ', type:' || l_metadata_rec.type ||
              ', length:' || l_metadata_rec.attribute_length ||
              ', p_category_id:' || p_category_id);
        END IF;
      ELSE
        l_err_loc := 1600;
        l_regular_tl_index := l_regular_tl_index + 1;
        p_regular_tl_metadata_tbl(l_regular_tl_index) := l_metadata_rec;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'l_regular_tl_index:' || l_regular_tl_index ||
              ', key:' || l_metadata_rec.key ||
              ', type:' || l_metadata_rec.type ||
              ', length:' || l_metadata_rec.attribute_length ||
              ', p_category_id:' || p_category_id);
        END IF;
      END IF;
    END IF;
  END LOOP;

  l_err_loc := 1700;
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
END buildMetadataInfo;

PROCEDURE getAttributeDetails(p_special_metadata_tbl    IN              g_metadata_tbl_type,
                              p_attribute_key           IN              VARCHAR2,
                              p_attribute_searchable    IN OUT NOCOPY   VARCHAR2,
                              p_metadata_rec            IN OUT NOCOPY   g_metadata_rec_type)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'getAttributeDetails';
  l_err_loc             PLS_INTEGER;
  l_metadata_rec        g_metadata_rec_type;
BEGIN
  l_err_loc := 100;
  p_attribute_searchable := 'N';
  FOR i IN 1..p_special_metadata_tbl.COUNT LOOP
    l_err_loc := 200;
    l_metadata_rec := p_special_metadata_tbl(i);
    IF (l_metadata_rec.key = p_attribute_key) THEN
      l_err_loc := 300;
      p_attribute_searchable := 'Y';
      p_metadata_rec := l_metadata_rec;
      EXIT;
    END IF;
  END LOOP;

  l_err_loc := 400;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'For p_attribute_key:' || p_attribute_key ||
        ', p_attribute_searchable:' || p_attribute_searchable ||
        ', p_metadata_rec.section_tag:' || p_metadata_rec.section_tag );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END getAttributeDetails;

/*
Values of p_doc_source:

   ICX_CAT_UTIL_PVT.g_PODoc_const           VARCHAR2(15)    := 'PO_DOCUMENTS';
   ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const  VARCHAR2(15)    := 'ReqTemplate';
   ICX_CAT_UTIL_PVT.g_MasterItemCsr_const   VARCHAR2(15)    := 'MASTER_ITEM';
Values of p_where_clause:
   ROWID / NOTROWID
   p_where_clause = NOTROWID; when we are dealing with only one source i.e. BLANKETS, GBPAs, Quotes,
                    ReqTemplates and Master Items
                    Because these are the only cases when we need to create the records
                    in icx_cat_items_ctx_dtls_tlp for a certain set of records.
                    For all other cases we need to create the dtls records for all the rows,
                    so it is better to passp_where_clause as ROWID
                    these include vendor changes, online changes to descriptors etc.
*/
PROCEDURE buildCtxSql(p_category_id                     IN              NUMBER,
                      p_doc_source                      IN              VARCHAR2,
                      p_where_clause                    IN              VARCHAR2 DEFAULT 'ROWID',
                      p_special_metadata_tbl            IN              g_metadata_tbl_type,
                      p_regular_nontl_metadata_tbl      IN              g_metadata_tbl_type,
                      p_regular_tl_metadata_tbl         IN              g_metadata_tbl_type,
                      p_all_ctx_sql_tbl                 IN OUT NOCOPY   g_ctx_sql_tbl_type,
                      p_special_ctx_sql_tbl             IN OUT NOCOPY   g_ctx_sql_tbl_type,
                      p_regular_ctx_sql_tbl             IN OUT NOCOPY   g_ctx_sql_tbl_type)
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'buildCtxSql';
  l_err_loc                     PLS_INTEGER;
  l_ctxsql_prefixStr            VARCHAR2(4000) := NULL;
  l_ctxfspsql_prefixStr         VARCHAR2(4000) := NULL;
  l_ctxsql_mandatoryBaseRowStr  VARCHAR2(4000) := NULL;
  l_ctxsql_suffixStr            VARCHAR2(4000) := NULL;
  l_ctxsql_string               VARCHAR2(32000) := NULL;
  l_searchable                  VARCHAR2(1) := NULL;
  l_metadata_rec                g_metadata_rec_type;
  l_ctx_sql_rec                 g_ctx_sql_rec_type;
  l_all_ctx_sql_index           NUMBER := 0;
  l_special_ctx_sql_index       NUMBER := 0;
  l_regular_ctx_sql_index       NUMBER := 0;
  l_ctx_sql_next_sequence       NUMBER := 0;
  l_current_length              NUMBER := 0;
  l_ctxsql_column		VARCHAR2(4000) := NULL;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' In parameters; categoryId:' || p_category_id ||
        ', p_doc_source:' || p_doc_source ||
        ', p_where_clause:' || p_where_clause ||
        ', p_special_metadata_tbl.COUNT:' || p_special_metadata_tbl.COUNT ||
        ', p_regular_nontl_metadata_tbl.COUNT:' || p_regular_nontl_metadata_tbl.COUNT ||
        ', p_regular_tl_metadata_tbl.COUNT:' || p_regular_tl_metadata_tbl.COUNT || ';');
  END IF;

  l_err_loc := 150;
  l_ctxsql_prefixStr :=
    'INSERT INTO icx_cat_items_ctx_dtls_tlp ' ||
    '(inventory_item_id, po_line_id, req_template_name, ' ||
    'req_template_line_num, org_id, language, ' ||
    'last_update_login, last_updated_by, last_update_date, ' ||
    'internal_request_id, request_id, created_by, creation_date, ' ||
    'sequence, ctx_desc) ' ||
    'SELECT hdrs.inventory_item_id, hdrs.po_line_id, hdrs.req_template_name, ' ||
    'hdrs.req_template_line_num, hdrs.org_id, hdrs.language, ' ||
    'hdrs.last_update_login, hdrs.last_updated_by, hdrs.last_update_date, ' ||
    'hdrs.internal_request_id, hdrs.request_id, hdrs.created_by, hdrs.creation_date, ' ||
    ':B_sequence, null ';

  l_err_loc := 160;
  l_ctxfspsql_prefixStr :=
    'INSERT INTO icx_cat_items_ctx_dtls_tlp ' ||
    '(inventory_item_id, po_line_id, req_template_name, ' ||
    'req_template_line_num, org_id, language, ' ||
    'last_update_login, last_updated_by, last_update_date, ' ||
    'internal_request_id, request_id, created_by, creation_date, ' ||
    'sequence, ctx_desc) ' ||
    'SELECT /*+ LEADING(doc) */ doc.inventory_item_id, doc.po_line_id, doc.req_template_name, ' ||
    'doc.req_template_line_num, doc.org_id, doc.language, ' ||
    'doc.last_update_login, doc.last_updated_by, doc.last_update_date, ' ||
    'doc.internal_request_id, doc.request_id, doc.created_by, doc.creation_date, ' ||
    ':B_sequence, null ';

  IF (p_where_clause = 'ROWID') THEN
    l_err_loc := 200;
    l_ctxsql_suffixStr := ' hdrs.rowid = :B_ROWID ';
  ELSE
    l_err_loc := 300;
    l_ctxsql_suffixStr := ' hdrs.inventory_item_id = :B_INVENTORY_ITEM_ID ' ||
                          ' AND   hdrs.po_line_id = :B_PO_LINE_ID ' ||
                          ' AND   hdrs.req_template_name = :B_REQ_TEMPLATE_NAME ' ||
                          ' AND   hdrs.req_template_line_num = :B_REQ_TEMPLATE_LINE_NUM ' ||
                          ' AND   hdrs.org_id = :B_ORG_ID ' ||
                          ' AND   hdrs.language = :B_LANGUAGE ';
  END IF;

  l_err_loc := 400;
  IF (p_category_id = 0) THEN

    l_err_loc := 500;
    l_ctxsql_mandatoryBaseRowStr :=
      ' || ''<language>'' || hdrs.language  || ''</language><source_type>'' || hdrs.source_type ||
      ''</source_type><supid>'' || hdrs.supplier_id || ''</supid><siteid>'' || hdrs.supplier_site_id ||
      ''</siteid><ipcatid>'' || hdrs.ip_category_id || ''</ipcatid><pocatid>'' || hdrs.po_category_id ||
      ''</pocatid><item_type>'' || hdrs.item_type || ''</item_type>''';

    -- Check the special attributes in special metadata table, to form the special sqls.
    -- First check if supplier_part_auxid is searchable

    l_err_loc := 600;
    l_ctxsql_string := l_ctxsql_prefixStr || l_ctxsql_mandatoryBaseRowStr;
    l_searchable := NULL;
    l_metadata_rec := NULL;
    l_err_loc := 620;
    getAttributeDetails(p_special_metadata_tbl, 'SUPPLIER_PART_AUXID', l_searchable, l_metadata_rec);
    IF (l_searchable = 'Y') THEN
      l_err_loc := 640;
      l_ctxsql_string := l_ctxsql_string ||
        ' || ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
        ' || 'replace(replace(SUPPLIER_PART_AUXID,' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
        ' || ''</' || to_char(l_metadata_rec.section_tag) || '>''';
    END IF;

    l_err_loc := 700;
    l_searchable := NULL;
    l_metadata_rec := NULL;
    getAttributeDetails(p_special_metadata_tbl, 'SUPPLIER_PART_NUM', l_searchable, l_metadata_rec);
    IF (l_searchable = 'Y') THEN
      l_err_loc := 800;
      l_ctxsql_string := l_ctxsql_string ||
        ' || ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
        ' || 'replace(replace(SUPPLIER_PART_NUM,' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
        ' || ''</' || to_char(l_metadata_rec.section_tag) || '>''';
    END IF;

    l_err_loc := 850;
    l_ctxsql_string := l_ctxsql_string ||
      ' FROM icx_cat_items_ctx_hdrs_tlp hdrs WHERE ' || l_ctxsql_suffixStr;

    l_err_loc := 900;
    l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;
    l_ctx_sql_rec.bind_sequence := g_seqMandatoryBaseRow;
    l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
    p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
    l_special_ctx_sql_index := l_special_ctx_sql_index + 1;
    p_special_ctx_sql_tbl(l_special_ctx_sql_index) := l_ctx_sql_rec;

    l_err_loc := 1000;
    IF (p_doc_source <> ICX_CAT_UTIL_PVT.g_MasterItemCsr_const) THEN
      l_err_loc := 1100;
      l_searchable := NULL;
      l_metadata_rec := NULL;
      getAttributeDetails(p_special_metadata_tbl, 'SUPPLIER', l_searchable, l_metadata_rec);
      IF (l_searchable = 'Y') THEN
        l_err_loc := 1200;
        l_ctxsql_string := l_ctxsql_prefixStr;
        l_ctxsql_string := l_ctxsql_string ||
          ' || ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
          ' || 'replace(replace(aps.vendor_name,' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
          ' || ''</' || to_char(l_metadata_rec.section_tag) || '>''';
        l_ctxsql_string := l_ctxsql_string ||
          ' FROM icx_cat_items_ctx_hdrs_tlp hdrs, AP_SUPPLIERS aps ' ||
          ' WHERE hdrs.supplier_id = aps.vendor_id (+) AND ' || l_ctxsql_suffixStr;

        l_err_loc := 1300;
        l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;
        l_ctx_sql_rec.bind_sequence := g_seqForSupplierRow;
        l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
        p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
        l_special_ctx_sql_index := l_special_ctx_sql_index + 1;
        p_special_ctx_sql_tbl(l_special_ctx_sql_index) := l_ctx_sql_rec;
      END IF;
    END IF;

    l_err_loc := 1400;
    l_searchable := NULL;
    l_metadata_rec := NULL;
    getAttributeDetails(p_special_metadata_tbl, 'INTERNAL_ITEM_NUM', l_searchable, l_metadata_rec);
    IF (l_searchable = 'Y') THEN
      l_err_loc := 1500;
      IF ( ICX_CAT_UTIL_PVT.g_mi_concat_seg_clause IS NULL) THEN
        ICX_CAT_UTIL_PVT.getMIConcatSegmentClause;
      END IF;
      l_ctxsql_string := l_ctxfspsql_prefixStr;
      l_ctxsql_string := l_ctxsql_string ||
        ' || ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
        ' || 'replace(replace(' || ICX_CAT_UTIL_PVT.g_mi_concat_seg_clause || ',' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
        ' || ''</' || to_char(l_metadata_rec.section_tag) || '>''';
      l_ctxsql_string := l_ctxsql_string ||
        ' FROM (SELECT hdrs.inventory_item_id, hdrs.po_line_id, hdrs.req_template_name, ' ||
        '              hdrs.req_template_line_num, hdrs.org_id, hdrs.language, ' ||
        '              hdrs.last_update_login, hdrs.last_updated_by, hdrs.last_update_date, ' ||
        '              hdrs.internal_request_id, hdrs.request_id, hdrs.created_by, ' ||
        '              hdrs.creation_date, fsp.inventory_organization_id ' ||
        '       FROM icx_cat_items_ctx_hdrs_tlp hdrs, financials_system_params_all fsp ' ||
        '       WHERE hdrs.org_id = fsp.org_id (+) ' ||
        '       AND  ' || l_ctxsql_suffixStr ||
        '       ) doc, mtl_system_items_b mi ' ||
        ' WHERE doc.inventory_item_id = mi.inventory_item_id (+) ' ||
        ' AND doc.inventory_organization_id = mi.organization_id (+) ';

      l_err_loc := 1600;
      l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;
      l_ctx_sql_rec.bind_sequence := g_seqForInternalItemNumRow;
      l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
      p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
      l_special_ctx_sql_index := l_special_ctx_sql_index + 1;
      p_special_ctx_sql_tbl(l_special_ctx_sql_index) := l_ctx_sql_rec;
    END IF;

    l_err_loc := 1700;
    IF (p_doc_source <> ICX_CAT_UTIL_PVT.g_MasterItemCsr_const) THEN
      l_err_loc := 1800;
      l_searchable := NULL;
      l_metadata_rec := NULL;
      getAttributeDetails(p_special_metadata_tbl, 'SOURCE', l_searchable, l_metadata_rec);
      IF (l_searchable = 'Y') THEN
        l_err_loc := 1900;
        l_ctxsql_string := l_ctxsql_prefixStr;
        IF (p_doc_source = ICX_CAT_UTIL_PVT.g_PODoc_const) THEN
          l_err_loc := 2000;
          l_ctxsql_string := l_ctxsql_string ||
            ' || ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
            ' || 'replace(replace(ph.segment1, ''<'', '' ''), ''>'', '' '')' ||
            ' || ''</' || to_char(l_metadata_rec.section_tag) || '>''';
          l_ctxsql_string := l_ctxsql_string ||
            ' FROM icx_cat_items_ctx_hdrs_tlp hdrs, po_headers_all ph, po_lines_all pl ' ||
            ' WHERE hdrs.po_line_id = pl.po_line_id ' ||
            ' AND   hdrs.org_id = pl.org_id ' ||
            ' AND   pl.po_header_id = ph.po_header_id ' ||
            ' AND ' || l_ctxsql_suffixStr;
        ELSIF (p_doc_source = ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const) THEN
          l_err_loc := 2100;
          l_ctxsql_string := l_ctxsql_string ||
            ' || ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
            ' || 'replace(replace(hdrs.req_template_name, ''<'', '' ''), ''>'', '' '')' ||
            ' || ''</' || to_char(l_metadata_rec.section_tag) || '>''';
          l_ctxsql_string := l_ctxsql_string ||
            ' FROM icx_cat_items_ctx_hdrs_tlp hdrs ' ||
            ' WHERE ' || l_ctxsql_suffixStr;
        ELSE
          l_err_loc := 2200;
          -- do nothing
        END IF;
        l_err_loc := 2300;
        l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;
        l_ctx_sql_rec.bind_sequence := g_seqForSourceRow;
        l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
        p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
        l_special_ctx_sql_index := l_special_ctx_sql_index + 1;
        p_special_ctx_sql_tbl(l_special_ctx_sql_index) := l_ctx_sql_rec;
      END IF;
    END IF;

    l_err_loc := 2400;
    IF (p_doc_source IN (ICX_CAT_UTIL_PVT.g_PODoc_const,
                         ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const))
    THEN
      l_err_loc := 2500;
      l_searchable := NULL;
      l_metadata_rec := NULL;
      getAttributeDetails(p_special_metadata_tbl, 'ITEM_REVISION', l_searchable, l_metadata_rec);
      IF (l_searchable = 'Y') THEN
        l_err_loc := 2600;
        l_ctxsql_string := l_ctxsql_prefixStr;
        l_ctxsql_string := l_ctxsql_string ||
          ' || ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
          ' || 'replace(replace(pl.item_revision,' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
          ' || ''</' || to_char(l_metadata_rec.section_tag) || '>''';
        IF (p_doc_source = ICX_CAT_UTIL_PVT.g_PODoc_const) THEN
          l_err_loc := 2700;
          l_ctxsql_string := l_ctxsql_string ||
            ' FROM icx_cat_items_ctx_hdrs_tlp hdrs, po_headers_all ph, po_lines_all pl ' ||
            ' WHERE hdrs.po_line_id = pl.po_line_id ' ||
            ' AND   pl.po_header_id = ph.po_header_id ';
        ELSE
          l_err_loc := 2800;
          l_ctxsql_string := l_ctxsql_string ||
            ' FROM icx_cat_items_ctx_hdrs_tlp hdrs, po_reqexpress_lines_all pl ' ||
            ' WHERE hdrs.req_template_name = pl.express_name ' ||
            ' AND   hdrs.req_template_line_num = pl.sequence_num ' ||
            ' AND   hdrs.org_id = pl.org_id ';
        END IF;
        l_ctxsql_string := l_ctxsql_string ||
          ' AND ' || l_ctxsql_suffixStr ;

        l_err_loc := 2900;
        l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;
        l_ctx_sql_rec.bind_sequence := g_seqForItemRevisionRow;
        l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
        p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
        l_special_ctx_sql_index := l_special_ctx_sql_index + 1;
        p_special_ctx_sql_tbl(l_special_ctx_sql_index) := l_ctx_sql_rec;
      END IF;
    END IF;

    l_err_loc := 3000;
    l_searchable := NULL;
    l_metadata_rec := NULL;
    getAttributeDetails(p_special_metadata_tbl, 'SHOPPING_CATEGORY', l_searchable, l_metadata_rec);
    IF (l_searchable = 'Y') THEN
      l_err_loc := 3100;
      l_ctxsql_string := l_ctxsql_prefixStr;
      l_ctxsql_string := l_ctxsql_string ||
        ' || ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
        ' || 'replace(replace(ip_category_name,' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
        ' || ''</' || to_char(l_metadata_rec.section_tag) || '>''';
      l_ctxsql_string := l_ctxsql_string ||
        ' FROM icx_cat_items_ctx_hdrs_tlp hdrs WHERE ' || l_ctxsql_suffixStr;

      l_err_loc := 3200;
      l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;
      l_ctx_sql_rec.bind_sequence := g_seqForShoppingCategoryRow;
      l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
      p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
      l_special_ctx_sql_index := l_special_ctx_sql_index + 1;
      p_special_ctx_sql_tbl(l_special_ctx_sql_index) := l_ctx_sql_rec;
    END IF;

    -- 17076597 changes starts
    -- UN_NUMBER
    l_err_loc := 3210;
    l_searchable := NULL;
    l_metadata_rec := NULL;
    getAttributeDetails(p_special_metadata_tbl, 'UN_NUMBER', l_searchable, l_metadata_rec);
    IF (l_searchable = 'Y') THEN
      l_err_loc := 3220;
      l_ctxsql_string := l_ctxsql_prefixStr;
      l_ctxsql_string := l_ctxsql_string ||
        ' || ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
        ' || 'replace(replace(un_number,' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
        ' || ''</' || to_char(l_metadata_rec.section_tag) || '>''';
      l_ctxsql_string := l_ctxsql_string ||
        ' FROM icx_cat_items_ctx_hdrs_tlp hdrs WHERE ' || l_ctxsql_suffixStr;

      l_err_loc := 3230;
      l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;

      l_ctx_sql_rec.bind_sequence := g_seqForUnNumberRow;
      l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
      p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
      l_special_ctx_sql_index := l_special_ctx_sql_index + 1;
      p_special_ctx_sql_tbl(l_special_ctx_sql_index) := l_ctx_sql_rec;
    END IF;

    -- HAZARD_CLASS
    l_err_loc := 3240;
    l_searchable := NULL;
    l_metadata_rec := NULL;
    getAttributeDetails(p_special_metadata_tbl, 'HAZARD_CLASS', l_searchable, l_metadata_rec);
    IF (l_searchable = 'Y') THEN
      l_err_loc := 3250;
      l_ctxsql_string := l_ctxsql_prefixStr;
      l_ctxsql_string := l_ctxsql_string ||
        ' || ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
        ' || 'replace(replace(hazard_class,' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
        ' || ''</' || to_char(l_metadata_rec.section_tag) || '>''';
      l_ctxsql_string := l_ctxsql_string ||
        ' FROM icx_cat_items_ctx_hdrs_tlp hdrs WHERE ' || l_ctxsql_suffixStr;

      l_err_loc := 3260;
      l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;

      l_ctx_sql_rec.bind_sequence := g_seqForHazardClassRow;
      l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
      p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
      l_special_ctx_sql_index := l_special_ctx_sql_index + 1;
      p_special_ctx_sql_tbl(l_special_ctx_sql_index) := l_ctx_sql_rec;
    END IF;
    -- 17076597 changes ends


  END IF; -- IF (p_category_id = 0) THEN

  l_err_loc := 3300;
  IF (p_category_id = 0) THEN
    l_err_loc := 3400;
    l_ctx_sql_next_sequence := g_seqStartReqularBaseRow;
  ELSE
    l_err_loc := 3500;
    l_ctx_sql_next_sequence := g_seqStartRegularCatgRow;
  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'l_ctx_sql_next_sequence:' ||l_ctx_sql_next_sequence);
  END IF;

  l_err_loc := 3600;
  -- For master items we only have to create the ctx sql for description.  The rest of the base and
  -- local descriptors are not available for master item.  So we differentiate between master items
  -- and the rest of the sources.  First, take care of all other sources in the IF statement and take
  -- care of the master items source in the ELSE statement.
  -- For category attributes, the ctx sqls are only created for all sources except Master Items.
  -- While online populate of master items, we donot call the buildCtxSQl for category attributes
  -- For all other sources, to build ctx sqls for category attributes, the p_doc_source is passed as null.
  /*BUG 6599217: commented the if clause to by pass the check on master item cursor constant
IF (p_doc_source IS NULL OR p_doc_source <> ICX_CAT_UTIL_PVT.g_MasterItemCsr_const) THEN*/

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'For mi also :not done earlier' );
    END IF;

    -- Loop thru the regular non-tl metadata table and form the sqls
    -- p_regular_nontl_metadata_tbl
    l_err_loc := 3700;
    l_ctxsql_string := l_ctxsql_prefixStr;
    l_current_length := 0;
    /* bug 17577010: rewrite loop logic: when current length + attribute length
       exeeds max length, will end current SQL and start a new SQL for the current
       attribute. Also, put the ending (i = count) part outside of the loop. */
    FOR i in 1..p_regular_nontl_metadata_tbl.COUNT LOOP
      l_err_loc := 3800;
      l_metadata_rec := p_regular_nontl_metadata_tbl(i);
      IF (l_current_length + l_metadata_rec.attribute_length >= g_default_max_length) THEN
        l_err_loc := 3900;
        l_ctxsql_string := l_ctxsql_string ||
          ' FROM icx_cat_items_ctx_hdrs_tlp hdrs, po_attribute_values po_attr ' ||
          ' WHERE hdrs.po_line_id = po_attr.po_line_id ' ||
          ' AND   hdrs.req_template_name = po_attr.req_template_name ' ||
          ' AND   hdrs.req_template_line_num = po_attr.req_template_line_num ' ||
          ' AND   hdrs.inventory_item_id = po_attr.inventory_item_id ' ||
          ' AND   hdrs.org_id = po_attr.org_id AND ' || l_ctxsql_suffixStr;

        l_err_loc := 4000;
        l_ctx_sql_next_sequence := l_ctx_sql_next_sequence + 1;
        l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;
        l_ctx_sql_rec.bind_sequence := l_ctx_sql_next_sequence;
        l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
        p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
        l_regular_ctx_sql_index := l_regular_ctx_sql_index + 1;
        p_regular_ctx_sql_tbl(l_regular_ctx_sql_index) := l_ctx_sql_rec;
        l_ctxsql_string := l_ctxsql_prefixStr;
        l_current_length := 0;
      END IF;
      l_err_loc := 4100;
      -- bug 17577010: trim the column content if it is lager than max length
      l_ctxsql_column := 'po_attr.' || l_metadata_rec.stored_in_column;
      IF (l_metadata_rec.attribute_length > g_default_max_length) THEN
        l_ctxsql_column := 'substr(po_attr.' || l_metadata_rec.stored_in_column || ', 1, ' || g_default_max_length ||')';
      END IF;
      l_ctxsql_string := l_ctxsql_string ||
        ' || decode('|| l_ctxsql_column || ', NULL, NULL, ' ||
        ' ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
        ' || 'replace(replace('|| l_ctxsql_column || ',' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
        ' || ''</' || to_char(l_metadata_rec.section_tag) || '>'')';
      l_current_length := l_current_length + l_metadata_rec.attribute_length;
    END LOOP; -- p_regular_nontl_metadata_tbl.COUNT
    -- bug 17577010: append SQL suffix after loop
    l_err_loc := 4200;
    l_ctxsql_string := l_ctxsql_string ||
      ' FROM icx_cat_items_ctx_hdrs_tlp hdrs, po_attribute_values po_attr ' ||
      ' WHERE hdrs.po_line_id = po_attr.po_line_id ' ||
      ' AND   hdrs.req_template_name = po_attr.req_template_name ' ||
      ' AND   hdrs.req_template_line_num = po_attr.req_template_line_num ' ||
      ' AND   hdrs.inventory_item_id = po_attr.inventory_item_id ' ||
      ' AND   hdrs.org_id = po_attr.org_id AND ' || l_ctxsql_suffixStr;
    l_ctx_sql_next_sequence := l_ctx_sql_next_sequence + 1;
    l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;
    l_ctx_sql_rec.bind_sequence := l_ctx_sql_next_sequence;
    l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
    p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
    l_regular_ctx_sql_index := l_regular_ctx_sql_index + 1;
    p_regular_ctx_sql_tbl(l_regular_ctx_sql_index) := l_ctx_sql_rec;
    l_ctxsql_string := l_ctxsql_prefixStr;
    l_current_length := 0;

    -- Loop thru the regular tl metadata table and form the sqls
    -- p_regular_tl_metadata_tbl
    l_err_loc := 4300;
    l_ctxsql_string := l_ctxsql_prefixStr;
    l_current_length := 0;
    /* bug 17577010: rewrite loop logic: when current length + attribute length
       exeeds max length, will end current SQL and start a new SQL for the current
       attribute. Also, put the ending (i = count) part outside of the loop. */
    FOR i in 1..p_regular_tl_metadata_tbl.COUNT LOOP
      l_err_loc := 4400;
      l_metadata_rec := p_regular_tl_metadata_tbl(i);
      IF (l_current_length + l_metadata_rec.attribute_length >= g_default_max_length) THEN
        l_err_loc := 4500;
        l_ctxsql_string := l_ctxsql_string ||
          ' FROM icx_cat_items_ctx_hdrs_tlp hdrs, po_attribute_values_tlp po_attr ' ||
          ' WHERE hdrs.po_line_id = po_attr.po_line_id ' ||
          ' AND   hdrs.req_template_name = po_attr.req_template_name ' ||
          ' AND   hdrs.req_template_line_num = po_attr.req_template_line_num ' ||
          ' AND   hdrs.inventory_item_id = po_attr.inventory_item_id ' ||
          ' AND   hdrs.org_id = po_attr.org_id ' ||
          ' AND   hdrs.language = po_attr.language AND ' || l_ctxsql_suffixStr ;

        l_err_loc := 4600;
        l_ctx_sql_next_sequence := l_ctx_sql_next_sequence + 1;
        l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;
        l_ctx_sql_rec.bind_sequence := l_ctx_sql_next_sequence;
        l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
        p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
        l_regular_ctx_sql_index := l_regular_ctx_sql_index + 1;
        p_regular_ctx_sql_tbl(l_regular_ctx_sql_index) := l_ctx_sql_rec;
        l_ctxsql_string := l_ctxsql_prefixStr;
        l_current_length := 0;
      END IF;
      l_err_loc := 4700;
      -- bug 17577010: trim the column content if it is lager than max length
      l_ctxsql_column := 'po_attr.' || l_metadata_rec.stored_in_column;
      IF (l_metadata_rec.attribute_length > g_default_max_length) THEN
        l_ctxsql_column := 'substr(po_attr.' || l_metadata_rec.stored_in_column || ', 1, ' || g_default_max_length ||')';
      END IF;
      l_ctxsql_string := l_ctxsql_string ||
        ' || decode('|| l_ctxsql_column || ', NULL, NULL, ' ||
        ' ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
        ' || 'replace(replace('|| l_ctxsql_column || ',' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
        ' || ''</' || to_char(l_metadata_rec.section_tag) || '>'')';
      l_current_length := l_current_length + l_metadata_rec.attribute_length;
    END LOOP; -- p_regular_tl_metadata_tbl.COUNT
    -- bug 17577010: append SQL suffix after loop
    l_err_loc := 4800;
    l_ctxsql_string := l_ctxsql_string ||
      ' FROM icx_cat_items_ctx_hdrs_tlp hdrs, po_attribute_values_tlp po_attr ' ||
      ' WHERE hdrs.po_line_id = po_attr.po_line_id ' ||
      ' AND   hdrs.req_template_name = po_attr.req_template_name ' ||
      ' AND   hdrs.req_template_line_num = po_attr.req_template_line_num ' ||
      ' AND   hdrs.inventory_item_id = po_attr.inventory_item_id ' ||
      ' AND   hdrs.org_id = po_attr.org_id ' ||
      ' AND   hdrs.language = po_attr.language AND ' || l_ctxsql_suffixStr ;
    l_err_loc := 4900;
    l_ctx_sql_next_sequence := l_ctx_sql_next_sequence + 1;
    l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;
    l_ctx_sql_rec.bind_sequence := l_ctx_sql_next_sequence;
    l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
    p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
    l_regular_ctx_sql_index := l_regular_ctx_sql_index + 1;
    p_regular_ctx_sql_tbl(l_regular_ctx_sql_index) := l_ctx_sql_rec;
    l_ctxsql_string := l_ctxsql_prefixStr;
    l_current_length := 0;
/*  ELSE  Bug 6599217 : commented if clauseand hence the else block
    l_err_loc := 4900;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'continue for MI case ' );
    END IF;
    -- i.e. (p_doc_source = ICX_CAT_UTIL_PVT.g_MasterItemCsr_const)
    -- Only need to populate description if it is searchable.
    -- Other attributes are not available for master items
    IF (p_category_id = 0) THEN
      l_err_loc := 5000;
      l_searchable := NULL;
      l_metadata_rec := NULL;
      getAttributeDetails(p_regular_tl_metadata_tbl, 'DESCRIPTION', l_searchable, l_metadata_rec);
      IF (l_searchable = 'Y') THEN
        l_err_loc := 5100;
        l_ctxsql_string := l_ctxfspsql_prefixStr;
        l_ctxsql_string := l_ctxsql_string ||
          ' || ''<' || to_char(l_metadata_rec.section_tag) || '>'' ||
          ' || 'replace(replace(mitl.description,' || '''<''' ||  ',' || ''' ''' || ')' || ',' || '''>''' || ',' || ''' ''' || ')' ||
          ' || ''</' || to_char(l_metadata_rec.section_tag) || '>''';
        l_ctxsql_string := l_ctxsql_string ||
          ' FROM (SELECT hdrs.inventory_item_id, hdrs.po_line_id, hdrs.req_template_name, ' ||
          '              hdrs.req_template_line_num, hdrs.org_id, hdrs.language, ' ||
          '              hdrs.last_update_login, hdrs.last_updated_by, hdrs.last_update_date, ' ||
          '              hdrs.internal_request_id, hdrs.request_id, hdrs.created_by, ' ||
          '              hdrs.creation_date, fsp.inventory_organization_id ' ||
          '       FROM icx_cat_items_ctx_hdrs_tlp hdrs, financials_system_params_all fsp ' ||
          '       WHERE hdrs.org_id = fsp.org_id (+) ' ||
          '       AND  ' || l_ctxsql_suffixStr ||
          '       ) doc, mtl_system_items_tl mitl ' ||
          ' WHERE doc.inventory_item_id = mitl.inventory_item_id (+) ' ||
          ' AND doc.language = mitl.language (+) ' ||
          ' AND doc.inventory_organization_id = mitl.organization_id (+) ';

        l_err_loc := 5200;
        l_ctx_sql_next_sequence := l_ctx_sql_next_sequence + 1;
        l_ctx_sql_rec.ctx_sql_string := l_ctxsql_string;
        l_ctx_sql_rec.bind_sequence := l_ctx_sql_next_sequence;
        l_all_ctx_sql_index := l_all_ctx_sql_index + 1;
        p_all_ctx_sql_tbl(l_all_ctx_sql_index) := l_ctx_sql_rec;
        l_regular_ctx_sql_index := l_regular_ctx_sql_index + 1;
        p_regular_ctx_sql_tbl(l_regular_ctx_sql_index) := l_ctx_sql_rec;
        l_ctxsql_string := l_ctxsql_prefixStr;
        l_current_length := 0;
      END IF;
    END IF;
--bug 6599217 : if clause commented  END IF;  -- IF (p_doc_source <> ICX_CAT_UTIL_PVT.g_MasterItemCsr_const)*/
  l_err_loc := 5300;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FOR i IN 1..p_special_ctx_sql_tbl.COUNT LOOP
      l_ctx_sql_rec := p_special_ctx_sql_tbl(i);
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Special ctx SQLs..Value at i:' || i ||
          ', sequence:' || l_ctx_sql_rec.bind_sequence ||
          ', sql_string:' || substr(l_ctx_sql_rec.ctx_sql_string, 1, 3600) );
    END LOOP;

    FOR i IN 1..p_regular_ctx_sql_tbl.COUNT LOOP
      l_ctx_sql_rec := p_regular_ctx_sql_tbl(i);
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Regular ctx SQLs..Value at i:' || i ||
          ', sequence:' || l_ctx_sql_rec.bind_sequence ||
          ', sql_string:' || substr(l_ctx_sql_rec.ctx_sql_string, 1, 3600) );
    END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END;

END ICX_CAT_BUILD_CTX_SQL_PVT;

/
