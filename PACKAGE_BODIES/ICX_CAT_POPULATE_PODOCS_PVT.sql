--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_PODOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_PODOCS_PVT" AS
/* $Header: ICXVPPDB.pls 120.14.12010000.5 2013/09/17 09:20:56 yyoliu ship $*/

--Will have the two cursors 1. BPA and Quote 2. GBPA
--for upgrade

--Will have the three cursors
--for online changes to BPA, Quote and GBPA.

-- Constants
G_PKG_NAME      CONSTANT VARCHAR2(30):='ICX_CAT_POPULATE_PODOCS_PVT';

g_upgrade_last_run_date         DATE;
g_key                           NUMBER;
g_current_cursor                VARCHAR2(20)    := 'GBPA_CSR';
g_start_rowid                   ROWID;
g_end_rowid                     ROWID;

----------------------------------------------------------------------
-----------------  Begin of BPA specific Code ------------------------
----------------------------------------------------------------------

PROCEDURE openBPACursor
(       p_key           IN      NUMBER  ,
        p_po_line_id    IN      NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'openBPACursor';
  l_err_loc     PLS_INTEGER;
  l_bpa_csr     ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', p_key:' || p_key ||
        ', p_po_line_id:' || p_po_line_id  );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_bpa_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_bpa_csr;
  END IF;

  l_err_loc := 300;
  --Comments on the cursor
  --Move the outside operation flag of a line type to the main cursor from the
  --status function due to the following reasons:
  --1. PO has confirmed that the outside operation flag
  --   of a line type cannot be changed once set
  --2. The main cursor anyways joins with po_line_types_b
  --   to eliminate the TEMP LABOR line
  -- 17076597 changes added un_number and hazard_class
    OPEN l_bpa_csr FOR
      SELECT /*+ LEADING(doc) */
             doc.*,
             ctx.inventory_item_id ctx_inventory_item_id,
             ctx.source_type ctx_source_type,
             ctx.item_type ctx_item_type,
             ctx.purchasing_org_id ctx_purchasing_org_id,
             ctx.supplier_id ctx_supplier_id,
             ctx.supplier_site_id ctx_supplier_site_id,
             ctx.supplier_part_num ctx_supplier_part_num,
             ctx.supplier_part_auxid ctx_supplier_part_auxid,
             ctx.ip_category_id ctx_ip_category_id,
             ctx.po_category_id ctx_po_category_id,
             ctx.item_revision ctx_item_revision,
             ctx.un_number ctx_un_number,
             ctx.hazard_class ctx_hazard_class,
             ROWIDTOCHAR(ctx.rowid) ctx_rowid
      FROM (
           SELECT NVL(pl.item_id, -2) inventory_item_id,
                  pl.po_line_id po_line_id,
                  NVL(pl.org_id, -2) org_id,
                  po_tlp.language language,
                  ph.type_lookup_code source_type,
                  DECODE(NVL(ph.global_agreement_flag, 'N'),
                         'Y', ga.purchasing_org_id, pl.org_id) purchasing_org_id,
                  pl.category_id po_category_id,
                  NVL(ph.vendor_id, -2) supplier_id,
                  NVL(pl.vendor_product_num, '##NULL##') supplier_part_num,
                  NVL(pl.supplier_part_auxid, '##NULL##') supplier_part_auxid,
                  DECODE(NVL(ph.global_agreement_flag, 'N'),
                         'Y', NVL(ga.vendor_site_id, -2),
                         NVL(ph.vendor_site_id, -2)) supplier_site_id,
                  pl.ip_category_id ip_category_id,
                  ic.category_name ip_category_name,
                  NVL(pl.item_revision, '-2') item_revision,
                  ph.po_header_id,
                  ph.segment1 document_number,
                  pl.line_num,
                  UPPER(NVL(pl.allow_price_override_flag, 'N')) allow_price_override_flag,
                  pl.not_to_exceed_price,
                  pl.line_type_id,
                  pl.unit_meas_lookup_code,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', pl.unit_price, to_number(null)) unit_price,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), pl.amount) amount,
                  ph.currency_code,
                  ph.rate_type,
                  ph.rate_date,
                  ph.rate,
                  ph.agent_id buyer_id,
                  ph.vendor_contact_id supplier_contact_id,
		  NVL(pl.negotiated_by_preparer_flag, 'N') negotiated_by_preparer_flag,
		  pltb.order_type_lookup_code,
                  pv.vendor_name supplier,
                  ph.global_agreement_flag,
                  ph.approved_date,
                  NVL(ph.authorization_status, 'INCOMPLETE') authorization_status,
                  NVL(ph.frozen_flag, 'N') frozen_flag,
                  NVL(ph.cancel_flag, 'N') hdr_cancel_flag,
                  NVL(pl.cancel_flag, 'N') line_cancel_flag,
                  NVL(ph.closed_code, 'OPEN') hdr_closed_code,
                  NVL(pl.closed_code, 'OPEN') line_closed_code,
                  NVL(TRUNC(ph.end_date), TRUNC(SYSDATE + 1)) end_date,
                  NVL(TRUNC(pl.expiration_date), TRUNC(SYSDATE + 1)) expiration_date,
                  TRUNC(SYSDATE) system_date,
                  ph.created_by,
                  pun.un_number,
                  phc.hazard_class,
                  ph.acceptance_required_flag  -- bug 17164050
           FROM po_headers_all ph,
                po_lines_all pl,
                po_ga_org_assignments ga,
                po_session_gt pogt,
                po_attribute_values_tlp po_tlp,
                po_line_types_b pltb,
                icx_cat_categories_tl ic,
                po_vendors pv,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE ph.po_header_id = pl.po_header_id
           AND ph.type_lookup_code = 'BLANKET'
           AND ph.po_header_id = ga.po_header_id (+)
           AND ph.org_id = ga.organization_id (+)
           AND pogt.key = p_key
           AND pl.po_line_id = pogt.index_num1
           AND ((pogt.char1 IS NULL)
                OR
                (pogt.char1 = 'Y' AND po_tlp.language = pogt.char2))
           AND pl.po_line_id = po_tlp.po_line_id
           AND pl.line_type_id = pltb.line_type_id
           AND NVL(pltb.purchase_basis, 'NULL') <> 'TEMP LABOR'
           AND NVL(pltb.outside_operation_flag, 'N') = 'N'
           AND po_tlp.ip_category_id = ic.rt_category_id (+)
           AND po_tlp.language = ic.language (+)
           AND ph.vendor_id = pv.vendor_id(+)
           AND pl.UN_NUMBER_ID = pun.un_number_id(+)
           AND pl.HAZARD_CLASS_ID = phc.hazard_class_id(+)
           AND pl.po_line_id >= p_po_line_id
           ) doc,
           icx_cat_items_ctx_hdrs_tlp ctx
      WHERE doc.po_line_id = ctx.po_line_id (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.language = ctx.language (+)
      ORDER BY doc.po_line_id;

  l_err_loc := 600;
  populateBPAs(l_bpa_csr, ICX_CAT_UTIL_PVT.g_online_const);

  l_err_loc := 700;
  CLOSE l_bpa_csr;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openBPACursor;

PROCEDURE openBPAOrgAssignmentCursor
(       p_key           IN      NUMBER  ,
        p_po_line_id    IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openBPAOrgAssignmentCursor';
  l_err_loc             PLS_INTEGER;
  l_bpa_csr     ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', p_key:' || p_key ||
        ', p_po_line_id:' || p_po_line_id  );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_bpa_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_bpa_csr;
  END IF;

  l_err_loc := 300;
  -- 17076597 changes added un_number and hazard_class
    OPEN l_bpa_csr FOR
      SELECT /*+ LEADING(doc) */
             doc.*,
             ctx.inventory_item_id ctx_inventory_item_id,
             ctx.source_type ctx_source_type,
             ctx.item_type ctx_item_type,
             ctx.purchasing_org_id ctx_purchasing_org_id,
             ctx.supplier_id ctx_supplier_id,
             ctx.supplier_site_id ctx_supplier_site_id,
             ctx.supplier_part_num ctx_supplier_part_num,
             ctx.supplier_part_auxid ctx_supplier_part_auxid,
             ctx.ip_category_id ctx_ip_category_id,
             ctx.po_category_id ctx_po_category_id,
             ctx.item_revision ctx_item_revision,
             ctx.un_number ctx_un_number,
             ctx.hazard_class ctx_hazard_class,
             ROWIDTOCHAR(ctx.rowid) ctx_rowid
      FROM (
           SELECT NVL(pl.item_id, -2) inventory_item_id,
                  pl.po_line_id po_line_id,
                  NVL(pl.org_id, -2) org_id,
                  po_tlp.language language,
                  ph.type_lookup_code source_type,
                  DECODE(NVL(ph.global_agreement_flag, 'N'),
                         'Y', ga.purchasing_org_id, pl.org_id) purchasing_org_id,
                  pl.category_id po_category_id,
                  NVL(ph.vendor_id, -2) supplier_id,
                  NVL(pl.vendor_product_num, '##NULL##') supplier_part_num,
                  NVL(pl.supplier_part_auxid, '##NULL##') supplier_part_auxid,
                  DECODE(NVL(ph.global_agreement_flag, 'N'),
                         'Y', NVL(ga.vendor_site_id, -2),
                         NVL(ph.vendor_site_id, -2)) supplier_site_id,
                  pl.ip_category_id ip_category_id,
                  ic.category_name ip_category_name,
                  NVL(pl.item_revision, '-2') item_revision,
                  ph.po_header_id,
                  ph.segment1 document_number,
                  pl.line_num,
                  UPPER(NVL(pl.allow_price_override_flag, 'N')) allow_price_override_flag,
                  pl.not_to_exceed_price,
                  pl.line_type_id,
                  pl.unit_meas_lookup_code,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', pl.unit_price, to_number(null)) unit_price,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), pl.amount) amount,
                  ph.currency_code,
                  ph.rate_type,
                  ph.rate_date,
                  ph.rate,
                  ph.agent_id buyer_id,
                  ph.vendor_contact_id supplier_contact_id,
		  NVL(pl.negotiated_by_preparer_flag, 'N') negotiated_by_preparer_flag,
		  pltb.order_type_lookup_code,
                  pv.vendor_name supplier,
                  ph.global_agreement_flag,
                  ph.approved_date,
                  NVL(ph.authorization_status, 'INCOMPLETE') authorization_status,
                  NVL(ph.frozen_flag, 'N') frozen_flag,
                  NVL(ph.cancel_flag, 'N') hdr_cancel_flag,
                  NVL(pl.cancel_flag, 'N') line_cancel_flag,
                  NVL(ph.closed_code, 'OPEN') hdr_closed_code,
                  NVL(pl.closed_code, 'OPEN') line_closed_code,
                  NVL(TRUNC(ph.end_date), TRUNC(SYSDATE + 1)) end_date,
                  NVL(TRUNC(pl.expiration_date), TRUNC(SYSDATE + 1)) expiration_date,
                  TRUNC(SYSDATE) system_date,
                  ph.created_by,
                  pun.un_number,
                  phc.hazard_class,
                  ph.acceptance_required_flag  -- bug 17164050
           FROM po_headers_all ph,
                po_lines_all pl,
                po_ga_org_assignments ga,
                po_session_gt pogt,
                po_attribute_values_tlp po_tlp,
                po_line_types_b pltb,
                icx_cat_categories_tl ic,
                po_vendors pv,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE ph.po_header_id = pl.po_header_id
           AND ph.type_lookup_code = 'BLANKET'
           AND ph.po_header_id = ga.po_header_id (+)
           AND ph.org_id = ga.organization_id (+)
           AND pogt.key = p_key
           AND ga.po_header_id = pogt.index_num1
           AND ga.org_assignment_id = pogt.index_num2
           AND pl.po_line_id = po_tlp.po_line_id
           AND pl.line_type_id = pltb.line_type_id
           AND NVL(pltb.purchase_basis, 'NULL') <> 'TEMP LABOR'
           AND NVL(pltb.outside_operation_flag, 'N') = 'N'
           AND po_tlp.ip_category_id = ic.rt_category_id (+)
           AND po_tlp.language = ic.language (+)
           AND ph.vendor_id = pv.vendor_id(+)
           AND pl.UN_NUMBER_ID = pun.un_number_id(+)
           AND pl.HAZARD_CLASS_ID = phc.hazard_class_id(+)
           AND pl.po_line_id >= p_po_line_id
           ) doc,
           icx_cat_items_ctx_hdrs_tlp ctx
      WHERE doc.po_line_id = ctx.po_line_id (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.language = ctx.language (+)
      ORDER BY doc.po_line_id;

  l_err_loc := 600;
  populateBPAs(l_bpa_csr, ICX_CAT_UTIL_PVT.g_online_const);

  l_err_loc := 700;
  CLOSE l_bpa_csr;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openBPAOrgAssignmentCursor;

--l_bpa_csr, ICX_CAT_UTIL_PVT.g_upgrade_const
PROCEDURE populateBPAs
(       p_podocs_csr            IN              ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN              VARCHAR2
)
IS
  l_api_name                            CONSTANT VARCHAR2(30)   := 'populateBPAs';
  l_err_loc                             PLS_INTEGER;
  l_start_po_line_id                    NUMBER;
  l_err_string                          VARCHAR2(4000);
  l_batch_count                         PLS_INTEGER;
  l_row_count                           PLS_INTEGER;
  l_count                               PLS_INTEGER;
  l_BPA_line_status_rec                 ICX_CAT_POPULATE_STATUS_PVT.g_BPA_line_status_rec_type;
  l_BPA_line_status                     PLS_INTEGER;
  l_current_ctx_item_rec                ICX_CAT_POPULATE_ITEM_PVT.g_ctx_item_rec_type;
  l_current_flag_rec                    ICX_CAT_POPULATE_ITEM_PVT.g_bpa_online_flag_rec_type;

  ----- Start of declaring columns selected in the cursor -----
  l_inv_item_id_tbl                     DBMS_SQL.NUMBER_TABLE;
  l_po_line_id_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                          DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                        DBMS_SQL.VARCHAR2_TABLE;
  l_source_type_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  l_purchasing_org_id_tbl               DBMS_SQL.NUMBER_TABLE;
  l_po_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_supplier_id_tbl                     DBMS_SQL.NUMBER_TABLE;
  l_supplier_part_num_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_part_auxid_tbl             DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_site_id_tbl                DBMS_SQL.NUMBER_TABLE;
  l_ip_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_ip_category_name_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_item_revision_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_po_header_id_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_document_number_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_line_num_tbl                        DBMS_SQL.NUMBER_TABLE;
  l_allow_prc_override_flag_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_not_to_exceed_price_tbl             DBMS_SQL.NUMBER_TABLE;
  l_line_type_id_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_unit_meas_lookup_code_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_unit_price_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_amount_tbl                          DBMS_SQL.NUMBER_TABLE;
  l_currency_code_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_rate_type_tbl                       DBMS_SQL.VARCHAR2_TABLE;
  l_rate_date_tbl                       DBMS_SQL.DATE_TABLE;
  l_rate_tbl                            DBMS_SQL.NUMBER_TABLE;
  l_buyer_id_tbl                        DBMS_SQL.NUMBER_TABLE;
  l_supplier_contact_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_negotiated_preparer_flag_tbl        DBMS_SQL.VARCHAR2_TABLE;
  l_order_type_lookup_code_tbl	        DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_tbl                        DBMS_SQL.VARCHAR2_TABLE;
  l_global_agreement_flag_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_approved_date_tbl                   DBMS_SQL.DATE_TABLE;
  l_authorization_status_tbl            DBMS_SQL.VARCHAR2_TABLE;
  l_frozen_flag_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  l_hdr_cancel_flag_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_line_cancel_flag_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_hdr_closed_code_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_line_closed_code_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_end_date_tbl                        DBMS_SQL.DATE_TABLE;
  l_expiration_date_tbl                 DBMS_SQL.DATE_TABLE;
  l_system_date_tbl                     DBMS_SQL.DATE_TABLE;
  l_created_by_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_ctx_inventory_item_id_tbl           DBMS_SQL.NUMBER_TABLE;
  l_ctx_source_type_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_item_type_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_purchasing_org_id_tbl           DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_id_tbl                 DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_site_id_tbl            DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_part_num_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_supplier_part_auxid_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_ip_category_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_ctx_po_category_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_ctx_item_revision_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_rowid_tbl                       DBMS_SQL.UROWID_TABLE;
  l_ctx_acceptance_flg_tbl              DBMS_SQL.VARCHAR2_TABLE;  --bug 17164050
  -- 17076597 changes starts
  l_ctx_un_number_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_un_number_tbl                       DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_hazard_class_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_hazard_class_tbl                    DBMS_SQL.VARCHAR2_TABLE;

  -- 17076597 changes ends
  ------ End of declaring columns selected in the cursor ------

BEGIN
  l_err_loc := 100;
  l_batch_count := 0;
  l_row_count := 0;
  l_count := 0;
  l_current_flag_rec := null;
  LOOP
    l_err_loc := 110;
    l_inv_item_id_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;
    l_source_type_tbl.DELETE;
    l_purchasing_org_id_tbl.DELETE;
    l_po_category_id_tbl.DELETE;
    l_supplier_id_tbl.DELETE;
    l_supplier_part_num_tbl.DELETE;
    l_supplier_part_auxid_tbl.DELETE;
    l_supplier_site_id_tbl.DELETE;
    l_ip_category_id_tbl.DELETE;
    l_ip_category_name_tbl.DELETE;
    l_item_revision_tbl.DELETE;
    l_po_header_id_tbl.DELETE;
    l_document_number_tbl.DELETE;
    l_line_num_tbl.DELETE;
    l_allow_prc_override_flag_tbl.DELETE;
    l_not_to_exceed_price_tbl.DELETE;
    l_line_type_id_tbl.DELETE;
    l_unit_meas_lookup_code_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_amount_tbl.DELETE;
    l_currency_code_tbl.DELETE;
    l_rate_type_tbl.DELETE;
    l_rate_date_tbl.DELETE;
    l_rate_tbl.DELETE;
    l_buyer_id_tbl.DELETE;
    l_supplier_contact_id_tbl.DELETE;
    l_negotiated_preparer_flag_tbl.DELETE;
    l_order_type_lookup_code_tbl.DELETE;
    l_supplier_tbl.DELETE;
    l_global_agreement_flag_tbl.DELETE;
    l_approved_date_tbl.DELETE;
    l_authorization_status_tbl.DELETE;
    l_frozen_flag_tbl.DELETE;
    l_hdr_cancel_flag_tbl.DELETE;
    l_line_cancel_flag_tbl.DELETE;
    l_hdr_closed_code_tbl.DELETE;
    l_line_closed_code_tbl.DELETE;
    l_end_date_tbl.DELETE;
    l_expiration_date_tbl.DELETE;
    l_system_date_tbl.DELETE;
    l_created_by_tbl.DELETE;
    l_ctx_inventory_item_id_tbl.DELETE;
    l_ctx_source_type_tbl.DELETE;
    l_ctx_item_type_tbl.DELETE;
    l_ctx_purchasing_org_id_tbl.DELETE;
    l_ctx_supplier_id_tbl.DELETE;
    l_ctx_supplier_site_id_tbl.DELETE;
    l_ctx_supplier_part_num_tbl.DELETE;
    l_ctx_supplier_part_auxid_tbl.DELETE;
    l_ctx_ip_category_id_tbl.DELETE;
    l_ctx_po_category_id_tbl.DELETE;
    l_ctx_item_revision_tbl.DELETE;
    l_ctx_rowid_tbl.DELETE;
    l_ctx_acceptance_flg_tbl.DELETE; -- bug 17164050
    -- 17076597 changes
    l_ctx_un_number_tbl.DELETE;
    l_un_number_tbl.DELETE;
    l_ctx_hazard_class_tbl.DELETE;
    l_hazard_class_tbl.DELETE;

    BEGIN
      l_err_loc := 200;
      FETCH p_podocs_csr BULK COLLECT INTO
          l_inv_item_id_tbl,
          l_po_line_id_tbl,
          l_org_id_tbl,
          l_language_tbl,
          l_source_type_tbl,
          l_purchasing_org_id_tbl,
          l_po_category_id_tbl,
          l_supplier_id_tbl,
          l_supplier_part_num_tbl,
          l_supplier_part_auxid_tbl,
          l_supplier_site_id_tbl,
          l_ip_category_id_tbl,
          l_ip_category_name_tbl,
          l_item_revision_tbl,
          l_po_header_id_tbl,
          l_document_number_tbl,
          l_line_num_tbl,
          l_allow_prc_override_flag_tbl,
          l_not_to_exceed_price_tbl,
          l_line_type_id_tbl,
          l_unit_meas_lookup_code_tbl,
          l_unit_price_tbl,
          l_amount_tbl,
          l_currency_code_tbl,
          l_rate_type_tbl,
          l_rate_date_tbl,
          l_rate_tbl,
          l_buyer_id_tbl,
          l_supplier_contact_id_tbl,
          l_negotiated_preparer_flag_tbl,
          l_order_type_lookup_code_tbl,
          l_supplier_tbl,
          l_global_agreement_flag_tbl,
          l_approved_date_tbl,
          l_authorization_status_tbl,
          l_frozen_flag_tbl,
          l_hdr_cancel_flag_tbl,
          l_line_cancel_flag_tbl,
          l_hdr_closed_code_tbl,
          l_line_closed_code_tbl,
          l_end_date_tbl,
          l_expiration_date_tbl,
          l_system_date_tbl,
          l_created_by_tbl,
          l_un_number_tbl,
          l_hazard_class_tbl,
          l_ctx_acceptance_flg_tbl,  -- bug 17164050
          l_ctx_inventory_item_id_tbl,
          l_ctx_source_type_tbl,
          l_ctx_item_type_tbl,
          l_ctx_purchasing_org_id_tbl,
          l_ctx_supplier_id_tbl,
          l_ctx_supplier_site_id_tbl,
          l_ctx_supplier_part_num_tbl,
          l_ctx_supplier_part_auxid_tbl,
          l_ctx_ip_category_id_tbl,
          l_ctx_po_category_id_tbl,
          l_ctx_item_revision_tbl,
          l_ctx_un_number_tbl,
          l_ctx_hazard_class_tbl,
          l_ctx_rowid_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 300;
      EXIT WHEN l_po_line_id_tbl.COUNT = 0;

      l_err_loc := 400;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 500;
      l_count := l_po_line_id_tbl.COUNT;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows returned from the cursor:' || l_count);
      END IF;

      --Save the last po_line_id processed, so that re-open of cursor will start from the saved id.
      l_start_po_line_id := l_po_line_id_tbl(l_count);

      l_row_count := l_row_count + l_count;

      FOR i in 1..l_po_line_id_tbl.COUNT LOOP
        l_err_loc := 600;
        --First get the status of the current BPA line
        IF (p_current_mode = ICX_CAT_UTIL_PVT.g_upgrade_const AND
            l_created_by_tbl(i) = ICX_CAT_UTIL_PVT.g_upgrade_user)
        THEN
          l_err_loc := 700;
          -- The GBPAs created for bulkload items will not be in approved
          -- status during upgrade, so treat them as valid during upgrade.
          l_BPA_line_status := ICX_CAT_POPULATE_STATUS_PVT.VALID_FOR_POPULATE;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'bpa status is hard-coded to valid for' ||
                ', p_current_mode:' || p_current_mode ||
                ', l_created_by_tbl(i):' || l_created_by_tbl(i) );
          END IF;
        ELSE
          l_err_loc := 800;
          l_BPA_line_status_rec.approved_date           := l_approved_date_tbl(i);
          l_BPA_line_status_rec.authorization_status    := l_authorization_status_tbl(i);
          l_BPA_line_status_rec.frozen_flag             := l_frozen_flag_tbl(i);
          l_BPA_line_status_rec.hdr_cancel_flag         := l_hdr_cancel_flag_tbl(i);
          l_BPA_line_status_rec.line_cancel_flag        := l_line_cancel_flag_tbl(i);
          l_BPA_line_status_rec.hdr_closed_code         := l_hdr_closed_code_tbl(i);
          l_BPA_line_status_rec.line_closed_code        := l_line_closed_code_tbl(i);
          l_BPA_line_status_rec.end_date                := l_end_date_tbl(i);
          l_BPA_line_status_rec.expiration_date         := l_expiration_date_tbl(i);
          l_BPA_line_status_rec.system_date             := l_system_date_tbl(i);
          l_BPA_line_status_rec.acceptance_flag         := l_ctx_acceptance_flg_tbl(i);  --bug 17164050

          l_err_loc := 900;
          l_BPA_line_status := ICX_CAT_POPULATE_STATUS_PVT.getBPALineStatus(l_BPA_line_status_rec);
        END IF;

        l_err_loc := 1000;
		--bug 16374319 begin
        IF ((l_authorization_status_tbl(i) = 'APPROVED'
	        OR (l_authorization_status_tbl(i) = 'PRE-APPROVED'  AND
                    l_ctx_acceptance_flg_tbl(i)='S'))  -- bug 17164050
             AND
		   (l_ctx_rowid_tbl(i) IS NOT NULL OR
            l_BPA_line_status = ICX_CAT_POPULATE_STATUS_PVT.VALID_FOR_POPULATE))
		--bug 16374319 end
        THEN
          l_err_loc := 1100;
          l_current_ctx_item_rec.inventory_item_id              := l_inv_item_id_tbl(i);
          l_current_ctx_item_rec.po_line_id                     := l_po_line_id_tbl(i);
          l_current_ctx_item_rec.req_template_name              := TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          l_current_ctx_item_rec.req_template_line_num          := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          l_current_ctx_item_rec.org_id                         := l_org_id_tbl(i);
          l_current_ctx_item_rec.language                       := l_language_tbl(i);
          l_current_ctx_item_rec.source_type                    := l_source_type_tbl(i);
          l_current_ctx_item_rec.item_type                      := ICX_CAT_UTIL_PVT.g_purchase_item_type;
          l_current_ctx_item_rec.purchasing_org_id              := l_purchasing_org_id_tbl(i);
          l_current_ctx_item_rec.owning_org_id                  := l_org_id_tbl(i);
          l_current_ctx_item_rec.po_category_id                 := l_po_category_id_tbl(i);
          l_current_ctx_item_rec.supplier_id                    := l_supplier_id_tbl(i);
          l_current_ctx_item_rec.supplier_part_num              := l_supplier_part_num_tbl(i);
          l_current_ctx_item_rec.supplier_part_auxid            := l_supplier_part_auxid_tbl(i);
          l_current_ctx_item_rec.supplier_site_id               := l_supplier_site_id_tbl(i);
          l_current_ctx_item_rec.status                         := l_BPA_line_status;
          l_current_ctx_item_rec.ip_category_id                 := l_ip_category_id_tbl(i);
          l_current_ctx_item_rec.ip_category_name               := l_ip_category_name_tbl(i);
          l_current_ctx_item_rec.req_template_po_line_id        := NULL;
          l_current_ctx_item_rec.item_revision                  := l_item_revision_tbl(i);
          l_current_ctx_item_rec.po_header_id                   := l_po_header_id_tbl(i);
          l_current_ctx_item_rec.document_number                := l_document_number_tbl(i);
          l_current_ctx_item_rec.line_num                       := l_line_num_tbl(i);
          l_current_ctx_item_rec.allow_price_override_flag      := l_allow_prc_override_flag_tbl(i);
          l_current_ctx_item_rec.not_to_exceed_price            := l_not_to_exceed_price_tbl(i);
          l_current_ctx_item_rec.line_type_id                   := l_line_type_id_tbl(i);
          l_current_ctx_item_rec.unit_meas_lookup_code          := l_unit_meas_lookup_code_tbl(i);
          l_current_ctx_item_rec.suggested_quantity             := NULL;
          l_current_ctx_item_rec.unit_price                     := l_unit_price_tbl(i);
          l_current_ctx_item_rec.amount                         := l_amount_tbl(i);
          l_current_ctx_item_rec.currency_code                  := l_currency_code_tbl(i);
          l_current_ctx_item_rec.rate_type                      := l_rate_type_tbl(i);
          l_current_ctx_item_rec.rate_date                      := l_rate_date_tbl(i);
          l_current_ctx_item_rec.rate                           := l_rate_tbl(i);
          l_current_ctx_item_rec.buyer_id                       := l_buyer_id_tbl(i);
          l_current_ctx_item_rec.supplier_contact_id            := l_supplier_contact_id_tbl(i);
          l_current_ctx_item_rec.rfq_required_flag              := 'N';
          l_current_ctx_item_rec.negotiated_by_preparer_flag    := l_negotiated_preparer_flag_tbl(i);
          l_current_ctx_item_rec.description                    := NULL;
          l_current_ctx_item_rec.order_type_lookup_code         := l_order_type_lookup_code_tbl(i);
          l_current_ctx_item_rec.supplier                       := l_supplier_tbl(i);
          l_current_ctx_item_rec.global_agreement_flag          := l_global_agreement_flag_tbl(i);
          l_current_ctx_item_rec.merged_source_type             := 'SRC_DOC';
          l_current_ctx_item_rec.ctx_inventory_item_id          := l_ctx_inventory_item_id_tbl(i);
          l_current_ctx_item_rec.ctx_source_type                := l_ctx_source_type_tbl(i);
          l_current_ctx_item_rec.ctx_item_type                  := l_ctx_item_type_tbl(i);
          l_current_ctx_item_rec.ctx_purchasing_org_id          := l_ctx_purchasing_org_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_id                := l_ctx_supplier_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_site_id           := l_ctx_supplier_site_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_part_num          := l_ctx_supplier_part_num_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_part_auxid        := l_ctx_supplier_part_auxid_tbl(i);
          l_current_ctx_item_rec.ctx_ip_category_id             := l_ctx_ip_category_id_tbl(i);
          l_current_ctx_item_rec.ctx_po_category_id             := l_ctx_po_category_id_tbl(i);
          l_current_ctx_item_rec.ctx_item_revision              := l_ctx_item_revision_tbl(i);
          l_current_ctx_item_rec.ctx_rowid                      := l_ctx_rowid_tbl(i);
          -- 17076597 changes
          l_current_ctx_item_rec.ctx_un_number                  := l_ctx_un_number_tbl(i);
          l_current_ctx_item_rec.un_number                      := l_un_number_tbl(i);
          l_current_ctx_item_rec.ctx_hazard_class               := l_ctx_hazard_class_tbl(i);
          l_current_ctx_item_rec.hazard_class                   := l_hazard_class_tbl(i);

          l_err_loc := 1300;
          ICX_CAT_POPULATE_ITEM_PVT.processCurrentCtxItemRow(l_current_ctx_item_rec, g_current_cursor, p_current_mode);

          l_err_loc := 1400;
          ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('INLOOP', ICX_CAT_UTIL_PVT.g_BPACsr_const);
        ELSE
          IF (p_current_mode = ICX_CAT_UTIL_PVT.g_upgrade_const) THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', with po_line_id:' || l_po_line_id_tbl(i) ||', not processed' ||
                  ', l_approved_date_tbl:' || l_approved_date_tbl(i) ||
                  ', l_authorization_status_tbl:' || l_authorization_status_tbl(i) ||
                  ', l_frozen_flag_tbl:' || l_frozen_flag_tbl(i) ||
                  ', l_hdr_cancel_flag_tbl:' || l_hdr_cancel_flag_tbl(i) ||
                  ', l_line_cancel_flag_tbl:' || l_line_cancel_flag_tbl(i) ||
                  ', l_hdr_closed_code_tbl:' || l_hdr_closed_code_tbl(i) ||
                  ', l_line_closed_code_tbl:' || l_line_closed_code_tbl(i) ||
                  ', l_end_date_tbl:' || l_end_date_tbl(i) ||
                  ', l_expiration_date_tbl:' || l_expiration_date_tbl(i) ||
                  ', l_system_date_tbl:' || l_system_date_tbl(i) ||
                  ', status: ' || l_BPA_line_status);
            END IF;
          ELSE
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', with po_line_id:' || l_po_line_id_tbl(i) ||', not processed' ||
                  ', l_approved_date_tbl:' || l_approved_date_tbl(i) ||
                  ', l_authorization_status_tbl:' || l_authorization_status_tbl(i) ||
                  ', l_frozen_flag_tbl:' || l_frozen_flag_tbl(i) ||
                  ', l_hdr_cancel_flag_tbl:' || l_hdr_cancel_flag_tbl(i) ||
                  ', l_line_cancel_flag_tbl:' || l_line_cancel_flag_tbl(i) ||
                  ', l_hdr_closed_code_tbl:' || l_hdr_closed_code_tbl(i) ||
                  ', l_line_closed_code_tbl:' || l_line_closed_code_tbl(i) ||
                  ', l_end_date_tbl:' || l_end_date_tbl(i) ||
                  ', l_expiration_date_tbl:' || l_expiration_date_tbl(i) ||
                  ', l_system_date_tbl:' || l_system_date_tbl(i) ||
                  ', status: ' || l_BPA_line_status);
            END IF;
          END IF;
        END IF;
      END LOOP;  --FOR LOOP of l_po_line_id_tbl

      l_err_loc := 1500;
      EXIT WHEN l_po_line_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := 'ICX_CAT_POPULATE_PODOCS_PVT.populateBPAs' ||l_err_loc
                        ||', Total processeded batches:' ||l_batch_count
                        ||', Cursor will be reopened with po_line_id:' ||l_start_po_line_id;
        IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
          ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
          --Closing and reopen of cursor will be done by called procedures
          l_err_loc := 1700;
          IF (g_current_cursor = 'ORG_ASSIGNMENT_CSR') THEN
            l_err_loc := 1720;
            openBPAOrgAssignmentCursor(g_key, l_start_po_line_id);
          ELSE
            l_err_loc := 1740;
            openBPACursor(g_key, l_start_po_line_id);
          END IF;
        ELSE
          RAISE;
        END IF;
    END;
  END LOOP; --Cursor loop

  l_err_loc := 1800;
  ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('OUTLOOP', ICX_CAT_UTIL_PVT.g_BPACsr_const);

  l_err_loc := 1900;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'populateBPAs in mode:'|| p_current_mode ||' done; '||
        'Total num. of batches processed:' ||l_batch_count ||
        ', Total num. of rows processed:' ||l_row_count);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateBPAs;

----------------------------------------------------------------------
-----------------  End of BPA specific Code    -----------------------
-----------------  Begin of GBPA specific Code -----------------------
----------------------------------------------------------------------

PROCEDURE openR12UpgradeGBPACursor
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openR12UpgradeGBPACursor';
  l_err_loc             PLS_INTEGER;
  l_gbpa_csr            ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', g_upgrade_last_run_date:' || g_upgrade_last_run_date ||
        ', g_start_rowid:' || g_start_rowid ||
        ', g_end_rowid:' || g_end_rowid );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_gbpa_csr%ISOPEN) THEN
    l_err_loc := 110;
    CLOSE l_gbpa_csr;
  END IF;

  l_err_loc := 200;
  --Open the GBPA cursor now
  IF (g_upgrade_last_run_date) IS NULL THEN
    l_err_loc := 300;
    -- 17076597 changes added un_number and hazard_class
    OPEN l_gbpa_csr FOR
      SELECT /*+ LEADING(doc) use_nl(ctx) index(ctxIn, ICX_CAT_ITEMS_CTX_HDRS_TLP_PK) */
             doc.*,
             ctx.inventory_item_id ctx_inventory_item_id,
             ctx.source_type ctx_source_type,
             ctx.item_type ctx_item_type,
             ctx.purchasing_org_id ctx_purchasing_org_id,
             ctx.supplier_id ctx_supplier_id,
             ctx.supplier_site_id ctx_supplier_site_id,
             ctx.supplier_part_num ctx_supplier_part_num,
             ctx.supplier_part_auxid ctx_supplier_part_auxid,
             ctx.ip_category_id ctx_ip_category_id,
             ctx.po_category_id ctx_po_category_id,
             ctx.item_revision ctx_item_revision,
             ctx.un_number ctx_un_number,
             ctx.hazard_class ctx_hazard_class,
             ROWIDTOCHAR(ctx.rowid) ctx_rowid
      FROM
            (
             SELECT /*+ ROWID(ph) leading(ph,pv,t,pl,pltb,ctxIn) use_nl(pl,ctxIn,t) index(t,PO_GA_ORG_ASSIGN_U1)
                        index(ctxIn,ICX_CAT_ITEMS_CTX_HDRS_TLP_PK) NO_MERGE */
                    NVL(pl.item_id, -2) inventory_item_id,
                    pl.po_line_id po_line_id,
                    NVL(t.organization_id, -2) org_id,
                    ctxIn.language language,
                    'GLOBAL_BLANKET' source_type,
                    t.purchasing_org_id purchasing_org_id,
                    ctxIn.org_id owning_org_id,
                    ctxIn.po_category_id po_category_id,
                    ctxIn.supplier_id supplier_id,
                    ctxIn.supplier_part_num supplier_part_num,
                    ctxIn.supplier_part_auxid supplier_part_auxid,
                    t.vendor_site_id supplier_site_id,
                    ctxIn.ip_category_id ip_category_id,
                    ctxIn.ip_category_name ip_category_name,
                    NVL(pl.item_revision, '-2') item_revision,
                    ph.po_header_id,
                    ph.segment1 document_number,
                    pl.line_num,
                    UPPER(NVL(pl.allow_price_override_flag, 'N')) allow_price_override_flag,
                    pl.not_to_exceed_price,
                    pl.line_type_id,
                    pl.unit_meas_lookup_code,
                    DECODE(pltb.order_type_lookup_code, 'QUANTITY', pl.unit_price, to_number(null)) unit_price,
                    DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), pl.amount) amount,
                    ph.currency_code,
                    ph.rate_type,
                    ph.rate_date,
                    ph.rate,
                    ph.agent_id buyer_id,
                    ph.vendor_contact_id supplier_contact_id,
                    NVL(pl.negotiated_by_preparer_flag, 'N') negotiated_by_preparer_flag,
                    pltb.order_type_lookup_code,
                    pv.vendor_name supplier,
                    ph.global_agreement_flag,
                    --For global agreement status
                    NVL(t.enabled_flag, 'N') enabled_flag,
                    pun.un_number,
                    phc.hazard_class,
                    ph.acceptance_required_flag  -- bug 17164050
             FROM po_ga_org_assignments t,
                  po_headers_all ph,
                  po_lines_all pl,
                  icx_cat_items_ctx_hdrs_tlp ctxIn,
                  po_vendors pv,
                  po_line_types_b pltb,
                  po_un_numbers pun,
                  po_hazard_classes phc
             WHERE ph.global_agreement_flag = 'Y'
             AND ph.po_header_id  = t.po_header_id
             AND ph.org_id <> t.organization_id
             AND t.po_header_id = pl.po_header_id
             AND pl.po_line_id = ctxIn.po_line_id
             AND pl.org_id = ctxIn.org_id
             AND pl.line_type_id = pltb.line_type_id
             AND ph.vendor_id = pv.vendor_id(+)
             AND pl.UN_NUMBER_ID = pun.un_number_id(+)
             AND pl.HAZARD_CLASS_ID = phc.hazard_class_id(+)
             AND ph.rowid BETWEEN g_start_rowid AND g_end_rowid
            ) doc,
            icx_cat_items_ctx_hdrs_tlp ctx
      WHERE doc.po_line_id = ctx.po_line_id (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.language = ctx.language (+);
  ELSE
    l_err_loc := 400;
    -- 17076597 changes added un_number and hazard_class
    OPEN l_gbpa_csr FOR
      SELECT /*+ LEADING(doc) use_nl(ctx) index(ctxIn, ICX_CAT_ITEMS_CTX_HDRS_TLP_PK) */
             doc.*,
             ctx.inventory_item_id ctx_inventory_item_id,
             ctx.source_type ctx_source_type,
             ctx.item_type ctx_item_type,
             ctx.purchasing_org_id ctx_purchasing_org_id,
             ctx.supplier_id ctx_supplier_id,
             ctx.supplier_site_id ctx_supplier_site_id,
             ctx.supplier_part_num ctx_supplier_part_num,
             ctx.supplier_part_auxid ctx_supplier_part_auxid,
             ctx.ip_category_id ctx_ip_category_id,
             ctx.po_category_id ctx_po_category_id,
             ctx.item_revision ctx_item_revision,
             ctx.un_number ctx_un_number,
             ctx.hazard_class ctx_hazard_class,
             ROWIDTOCHAR(ctx.rowid) ctx_rowid
      FROM
            (
             SELECT /*+ ROWID(ph) leading(ph,pv,t,pl,pltb,ctxIn) use_nl(pl,ctxIn,t) index(t,PO_GA_ORG_ASSIGN_U1)
                        index(ctxIn,ICX_CAT_ITEMS_CTX_HDRS_TLP_PK) NO_MERGE */
                    NVL(pl.item_id, -2) inventory_item_id,
                    pl.po_line_id po_line_id,
                    NVL(t.organization_id, -2) org_id,
                    ctxIn.language language,
                    'GLOBAL_BLANKET' source_type,
                    t.purchasing_org_id purchasing_org_id,
                    ctxIn.org_id owning_org_id,
                    ctxIn.po_category_id po_category_id,
                    ctxIn.supplier_id supplier_id,
                    ctxIn.supplier_part_num supplier_part_num,
                    ctxIn.supplier_part_auxid supplier_part_auxid,
                    t.vendor_site_id supplier_site_id,
                    ctxIn.ip_category_id ip_category_id,
                    ctxIn.ip_category_name ip_category_name,
                    NVL(pl.item_revision, '-2') item_revision,
                    ph.po_header_id,
                    ph.segment1 document_number,
                    pl.line_num,
                    UPPER(NVL(pl.allow_price_override_flag, 'N')) allow_price_override_flag,
                    pl.not_to_exceed_price,
                    pl.line_type_id,
                    pl.unit_meas_lookup_code,
                    DECODE(pltb.order_type_lookup_code, 'QUANTITY', pl.unit_price, to_number(null)) unit_price,
                    DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), pl.amount) amount,
                    ph.currency_code,
                    ph.rate_type,
                    ph.rate_date,
                    ph.rate,
                    ph.agent_id buyer_id,
                    ph.vendor_contact_id supplier_contact_id,
                    NVL(pl.negotiated_by_preparer_flag, 'N') negotiated_by_preparer_flag,
                    pltb.order_type_lookup_code,
                    pv.vendor_name supplier,
                    ph.global_agreement_flag,
                    --For global agreement status
                    NVL(t.enabled_flag, 'N') enabled_flag,
                    pun.un_number,
                    phc.hazard_class,
                    ph.acceptance_required_flag  -- bug 17164050
             FROM po_ga_org_assignments t,
                  po_headers_all ph,
                  po_lines_all pl,
                  icx_cat_items_ctx_hdrs_tlp ctxIn,
                  po_vendors pv,
                  po_line_types_b pltb,
                  po_un_numbers pun,
                  po_hazard_classes phc
             WHERE ph.global_agreement_flag = 'Y'
             AND ph.po_header_id  = t.po_header_id
             AND ph.org_id <> t.organization_id
             AND t.po_header_id = pl.po_header_id
             AND pl.po_line_id = ctxIn.po_line_id
             AND pl.org_id = ctxIn.org_id
             AND pl.line_type_id = pltb.line_type_id
             AND ph.vendor_id = pv.vendor_id(+)
             AND pl.UN_NUMBER_ID = pun.un_number_id(+)
             AND pl.HAZARD_CLASS_ID = phc.hazard_class_id(+)
             AND ph.rowid BETWEEN g_start_rowid AND g_end_rowid
             AND (ph.last_update_date > g_upgrade_last_run_date
                  OR pl.last_update_date > g_upgrade_last_run_date
                  OR t.last_update_date > g_upgrade_last_run_date)
            ) doc,
            icx_cat_items_ctx_hdrs_tlp ctx
      WHERE doc.po_line_id = ctx.po_line_id (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.language = ctx.language (+);
    END IF;

  l_err_loc := 600;
  populateGBPAs(l_gbpa_csr, ICX_CAT_UTIL_PVT.g_upgrade_const);

  l_err_loc := 700;
  CLOSE l_gbpa_csr;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openR12UpgradeGBPACursor;

PROCEDURE openGBPACursor
(       p_key           IN      NUMBER  ,
        p_po_line_id    IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openGBPACursor';
  l_err_loc             PLS_INTEGER;
  l_gbpa_csr            ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', p_key:' || p_key ||
        ', p_po_line_id:' || p_po_line_id  );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_gbpa_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_gbpa_csr;
  END IF;

  l_err_loc := 300;
  -- 17076597 changes added un_number and hazard_class
  --Open the GBPA cursor now
    OPEN l_gbpa_csr FOR
      SELECT /*+ LEADING(doc) */
             doc.*,
             ctx.inventory_item_id ctx_inventory_item_id,
             ctx.source_type ctx_source_type,
             ctx.item_type ctx_item_type,
             ctx.purchasing_org_id ctx_purchasing_org_id,
             ctx.supplier_id ctx_supplier_id,
             ctx.supplier_site_id ctx_supplier_site_id,
             ctx.supplier_part_num ctx_supplier_part_num,
             ctx.supplier_part_auxid ctx_supplier_part_auxid,
             ctx.ip_category_id ctx_ip_category_id,
             ctx.po_category_id ctx_po_category_id,
             ctx.item_revision ctx_item_revision,
             ctx.un_number ctx_un_number,
             ctx.hazard_class ctx_hazard_class,
             ROWIDTOCHAR(ctx.rowid) ctx_rowid
      FROM
            (
             SELECT NVL(pl.item_id, -2) inventory_item_id,
                    pl.po_line_id po_line_id,
                    NVL(t.organization_id, -2) org_id,
                    ctxIn.language language,
                    'GLOBAL_BLANKET' source_type,
                    t.purchasing_org_id purchasing_org_id,
                    ctxIn.org_id owning_org_id,
                    ctxIn.po_category_id po_category_id,
                    ctxIn.supplier_id supplier_id,
                    ctxIn.supplier_part_num supplier_part_num,
                    ctxIn.supplier_part_auxid supplier_part_auxid,
                    t.vendor_site_id supplier_site_id,
                    ctxIn.ip_category_id ip_category_id,
                    ctxIn.ip_category_name ip_category_name,
                    NVL(pl.item_revision, '-2') item_revision,
                    ph.po_header_id,
                    ph.segment1 document_number,
                    pl.line_num,
                    UPPER(NVL(pl.allow_price_override_flag, 'N')) allow_price_override_flag,
                    pl.not_to_exceed_price,
                    pl.line_type_id,
                    pl.unit_meas_lookup_code,
                    DECODE(pltb.order_type_lookup_code, 'QUANTITY', pl.unit_price, to_number(null)) unit_price,
                    DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), pl.amount) amount,
                    ph.currency_code,
                    ph.rate_type,
                    ph.rate_date,
                    ph.rate,
                    ph.agent_id buyer_id,
                    ph.vendor_contact_id supplier_contact_id,
                    NVL(pl.negotiated_by_preparer_flag, 'N') negotiated_by_preparer_flag,
                    pltb.order_type_lookup_code,
                    pv.vendor_name supplier,
                    ph.global_agreement_flag,
                    NVL(t.enabled_flag, 'N') enabled_flag,
                    pun.un_number,
                    phc.hazard_class,
                    ph.acceptance_required_flag  -- bug 17164050
             FROM po_ga_org_assignments t,
                  po_headers_all ph,
                  po_lines_all pl,
                  po_session_gt pogt,
                  icx_cat_items_ctx_hdrs_tlp ctxIn,
                  po_vendors pv,
                  po_line_types_b pltb,
                  po_un_numbers pun,
                  po_hazard_classes phc
             WHERE ph.global_agreement_flag = 'Y'
             AND ph.po_header_id  = t.po_header_id
             AND ph.org_id <> t.organization_id
             AND ph.po_header_id = pl.po_header_id
             AND pogt.key = p_key
             AND NVL(pogt.char3, 'N') = 'Y'
             AND pl.po_line_id = pogt.index_num1
             AND ((pogt.char1 IS NULL)
                  OR
                  (pogt.char1 = 'Y' AND ctxIn.language = pogt.char2))
             AND pl.po_line_id = ctxIn.po_line_id
             AND pl.org_id = ctxIn.org_id
             AND pl.line_type_id = pltb.line_type_id
             AND ph.vendor_id = pv.vendor_id(+)
             AND pl.UN_NUMBER_ID = pun.un_number_id(+)
             AND pl.HAZARD_CLASS_ID = phc.hazard_class_id(+)
             AND pl.po_line_id >= p_po_line_id
            ) doc,
            icx_cat_items_ctx_hdrs_tlp ctx
      WHERE doc.po_line_id = ctx.po_line_id (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.language = ctx.language (+)
      ORDER BY doc.po_line_id;

  l_err_loc := 500;
  populateGBPAs(l_gbpa_csr, ICX_CAT_UTIL_PVT.g_online_const);

  l_err_loc := 600;
  CLOSE l_gbpa_csr;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openGBPACursor;

PROCEDURE openGBPAOrgAssignmentCursor
(       p_key           IN      NUMBER  ,
        p_po_line_id    IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openGBPAOrgAssignmentCursor';
  l_err_loc             PLS_INTEGER;
  l_gbpa_csr            ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', p_key:' || p_key ||
        ', p_po_line_id:' || p_po_line_id  );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_gbpa_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_gbpa_csr;
  END IF;

  l_err_loc := 300;
  -- 17076597 changes added un_number and hazard_class
  --Open the GBPA cursor now
    OPEN l_gbpa_csr FOR
      SELECT /*+ LEADING(doc) */
             doc.*,
             ctx.inventory_item_id ctx_inventory_item_id,
             ctx.source_type ctx_source_type,
             ctx.item_type ctx_item_type,
             ctx.purchasing_org_id ctx_purchasing_org_id,
             ctx.supplier_id ctx_supplier_id,
             ctx.supplier_site_id ctx_supplier_site_id,
             ctx.supplier_part_num ctx_supplier_part_num,
             ctx.supplier_part_auxid ctx_supplier_part_auxid,
             ctx.ip_category_id ctx_ip_category_id,
             ctx.po_category_id ctx_po_category_id,
             ctx.item_revision ctx_item_revision,
             ctx.un_number ctx_un_number,
             ctx.hazard_class ctx_hazard_class,
             ROWIDTOCHAR(ctx.rowid) ctx_rowid
      FROM
            (
             SELECT NVL(pl.item_id, -2) inventory_item_id,
                    pl.po_line_id po_line_id,
                    NVL(t.organization_id, -2) org_id,
                    ctxIn.language language,
                    'GLOBAL_BLANKET' source_type,
                    t.purchasing_org_id purchasing_org_id,
                    ctxIn.org_id owning_org_id,
                    ctxIn.po_category_id po_category_id,
                    ctxIn.supplier_id supplier_id,
                    ctxIn.supplier_part_num supplier_part_num,
                    ctxIn.supplier_part_auxid supplier_part_auxid,
                    t.vendor_site_id supplier_site_id,
                    ctxIn.ip_category_id ip_category_id,
                    ctxIn.ip_category_name ip_category_name,
                    NVL(pl.item_revision, '-2') item_revision,
                    ph.po_header_id,
                    ph.segment1 document_number,
                    pl.line_num,
                    UPPER(NVL(pl.allow_price_override_flag, 'N')) allow_price_override_flag,
                    pl.not_to_exceed_price,
                    pl.line_type_id,
                    pl.unit_meas_lookup_code,
                    DECODE(pltb.order_type_lookup_code, 'QUANTITY', pl.unit_price, to_number(null)) unit_price,
                    DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), pl.amount) amount,
                    ph.currency_code,
                    ph.rate_type,
                    ph.rate_date,
                    ph.rate,
                    ph.agent_id buyer_id,
                    ph.vendor_contact_id supplier_contact_id,
                    NVL(pl.negotiated_by_preparer_flag, 'N') negotiated_by_preparer_flag,
                    pltb.order_type_lookup_code,
                    pv.vendor_name supplier,
                    ph.global_agreement_flag,
                    NVL(t.enabled_flag, 'N') enabled_flag,
                    pun.un_number,
                    phc.hazard_class,
                    ph.acceptance_required_flag  -- bug 17164050
             FROM po_ga_org_assignments t,
                  po_headers_all ph,
                  po_lines_all pl,
                  po_session_gt pogt,
                  icx_cat_items_ctx_hdrs_tlp ctxIn,
                  po_vendors pv,
                  po_line_types_b pltb,
                  po_un_numbers pun,
                  po_hazard_classes phc
             WHERE ph.global_agreement_flag = 'Y'
             AND ph.po_header_id  = t.po_header_id
             AND ph.org_id <> t.organization_id
             AND t.po_header_id = pl.po_header_id
             AND pogt.key = p_key
             AND t.po_header_id = pogt.index_num1
             AND t.org_assignment_id = pogt.index_num2
             AND pl.po_line_id = ctxIn.po_line_id
             AND pl.org_id = ctxIn.org_id
             ANd pl.line_type_id = pltb.line_type_id
             AND ph.vendor_id = pv.vendor_id(+)
             AND pl.UN_NUMBER_ID = pun.un_number_id(+)
             AND pl.HAZARD_CLASS_ID = phc.hazard_class_id(+)
             AND pl.po_line_id >= p_po_line_id
            ) doc,
            icx_cat_items_ctx_hdrs_tlp ctx
      WHERE doc.po_line_id = ctx.po_line_id (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.language = ctx.language (+)
      ORDER BY doc.po_line_id;

  l_err_loc := 500;
  populateGBPAs(l_gbpa_csr, ICX_CAT_UTIL_PVT.g_online_const);

  l_err_loc := 600;
  CLOSE l_gbpa_csr;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openGBPAOrgAssignmentCursor;

--l_gbpa_csr, ICX_CAT_UTIL_PVT.g_upgrade_const
PROCEDURE populateGBPAs
(       p_podocs_csr            IN              ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN              VARCHAR2
)
IS
  l_api_name                            CONSTANT VARCHAR2(30)   := 'populateGBPAs';
  l_err_loc                             PLS_INTEGER;
  l_start_po_line_id                    NUMBER;
  l_err_string                          VARCHAR2(4000);
  l_batch_count                         PLS_INTEGER;
  l_row_count                           PLS_INTEGER;
  l_count                               PLS_INTEGER;
  l_GBPA_line_status                    PLS_INTEGER;
  l_current_ctx_item_rec                ICX_CAT_POPULATE_ITEM_PVT.g_ctx_item_rec_type;
  l_current_flag_rec                    ICX_CAT_POPULATE_ITEM_PVT.g_bpa_online_flag_rec_type;
  l_authorization_status                VARCHAR(25);   --bug 16374319

  ----- Start of declaring columns selected in the cursor -----
  l_inv_item_id_tbl                     DBMS_SQL.NUMBER_TABLE;
  l_po_line_id_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                          DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                        DBMS_SQL.VARCHAR2_TABLE;
  l_source_type_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  l_purchasing_org_id_tbl               DBMS_SQL.NUMBER_TABLE;
  l_owning_org_id_tbl                   DBMS_SQL.NUMBER_TABLE;
  l_po_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_supplier_id_tbl                     DBMS_SQL.NUMBER_TABLE;
  l_supplier_part_num_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_part_auxid_tbl             DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_site_id_tbl                DBMS_SQL.NUMBER_TABLE;
  l_ip_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_ip_category_name_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_item_revision_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_po_header_id_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_document_number_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_line_num_tbl                        DBMS_SQL.NUMBER_TABLE;
  l_allow_prc_override_flag_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_not_to_exceed_price_tbl             DBMS_SQL.NUMBER_TABLE;
  l_line_type_id_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_unit_meas_lookup_code_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_unit_price_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_amount_tbl                          DBMS_SQL.NUMBER_TABLE;
  l_currency_code_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_rate_type_tbl                       DBMS_SQL.VARCHAR2_TABLE;
  l_rate_date_tbl                       DBMS_SQL.DATE_TABLE;
  l_rate_tbl                            DBMS_SQL.NUMBER_TABLE;
  l_buyer_id_tbl                        DBMS_SQL.NUMBER_TABLE;
  l_supplier_contact_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_negotiated_preparer_flag_tbl        DBMS_SQL.VARCHAR2_TABLE;
  l_order_type_lookup_code_tbl          DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_tbl                        DBMS_SQL.VARCHAR2_TABLE;
  l_global_agreement_flag_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_enabled_flag_tbl                    DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_inventory_item_id_tbl           DBMS_SQL.NUMBER_TABLE;
  l_ctx_source_type_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_item_type_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_purchasing_org_id_tbl           DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_id_tbl                 DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_site_id_tbl            DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_part_num_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_supplier_part_auxid_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_ip_category_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_ctx_po_category_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_ctx_item_revision_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_rowid_tbl                       DBMS_SQL.UROWID_TABLE;
  l_ctx_acceptance_flg_tbl              DBMS_SQL.VARCHAR2_TABLE;  --bug 17164050

  -- 17076597 changes starts
  l_ctx_un_number_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_un_number_tbl                       DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_hazard_class_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_hazard_class_tbl                    DBMS_SQL.VARCHAR2_TABLE;
  -- 17076597 changes ends
  ------ End of declaring columns selected in the cursor ------

BEGIN
  l_err_loc := 100;
  l_batch_count := 0;
  l_row_count := 0;
  l_count := 0;
  l_current_flag_rec := null;
  LOOP
    l_err_loc := 200;
    l_inv_item_id_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;
    l_source_type_tbl.DELETE;
    l_purchasing_org_id_tbl.DELETE;
    l_owning_org_id_tbl.DELETE;
    l_po_category_id_tbl.DELETE;
    l_supplier_id_tbl.DELETE;
    l_supplier_part_num_tbl.DELETE;
    l_supplier_part_auxid_tbl.DELETE;
    l_supplier_site_id_tbl.DELETE;
    l_ip_category_id_tbl.DELETE;
    l_ip_category_name_tbl.DELETE;
    l_item_revision_tbl.DELETE;
    l_po_header_id_tbl.DELETE;
    l_document_number_tbl.DELETE;
    l_line_num_tbl.DELETE;
    l_allow_prc_override_flag_tbl.DELETE;
    l_not_to_exceed_price_tbl.DELETE;
    l_line_type_id_tbl.DELETE;
    l_unit_meas_lookup_code_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_amount_tbl.DELETE;
    l_currency_code_tbl.DELETE;
    l_rate_type_tbl.DELETE;
    l_rate_date_tbl.DELETE;
    l_rate_tbl.DELETE;
    l_buyer_id_tbl.DELETE;
    l_supplier_contact_id_tbl.DELETE;
    l_negotiated_preparer_flag_tbl.DELETE;
    l_order_type_lookup_code_tbl.DELETE;
    l_supplier_tbl.DELETE;
    l_global_agreement_flag_tbl.DELETE;
    l_enabled_flag_tbl.DELETE;
    l_ctx_inventory_item_id_tbl.DELETE;
    l_ctx_source_type_tbl.DELETE;
    l_ctx_item_type_tbl.DELETE;
    l_ctx_purchasing_org_id_tbl.DELETE;
    l_ctx_supplier_id_tbl.DELETE;
    l_ctx_supplier_site_id_tbl.DELETE;
    l_ctx_supplier_part_num_tbl.DELETE;
    l_ctx_supplier_part_auxid_tbl.DELETE;
    l_ctx_ip_category_id_tbl.DELETE;
    l_ctx_po_category_id_tbl.DELETE;
    l_ctx_item_revision_tbl.DELETE;
    l_ctx_rowid_tbl.DELETE;
    l_ctx_acceptance_flg_tbl.DELETE;  -- bug 17164050
    -- 17076597 changes
    l_ctx_un_number_tbl.DELETE;
    l_un_number_tbl.DELETE;
    l_ctx_hazard_class_tbl.DELETE;
    l_hazard_class_tbl.DELETE;

    BEGIN
      l_err_loc := 300;
      FETCH p_podocs_csr BULK COLLECT INTO
          l_inv_item_id_tbl,
          l_po_line_id_tbl,
          l_org_id_tbl,
          l_language_tbl,
          l_source_type_tbl,
          l_purchasing_org_id_tbl,
          l_owning_org_id_tbl,
          l_po_category_id_tbl,
          l_supplier_id_tbl,
          l_supplier_part_num_tbl,
          l_supplier_part_auxid_tbl,
          l_supplier_site_id_tbl,
          l_ip_category_id_tbl,
          l_ip_category_name_tbl,
          l_item_revision_tbl,
          l_po_header_id_tbl,
          l_document_number_tbl,
          l_line_num_tbl,
          l_allow_prc_override_flag_tbl,
          l_not_to_exceed_price_tbl,
          l_line_type_id_tbl,
          l_unit_meas_lookup_code_tbl,
          l_unit_price_tbl,
          l_amount_tbl,
          l_currency_code_tbl,
          l_rate_type_tbl,
          l_rate_date_tbl,
          l_rate_tbl,
          l_buyer_id_tbl,
          l_supplier_contact_id_tbl,
          l_negotiated_preparer_flag_tbl,
          l_order_type_lookup_code_tbl,
          l_supplier_tbl,
          l_global_agreement_flag_tbl,
          l_enabled_flag_tbl,
          l_un_number_tbl,
          l_hazard_class_tbl,
          l_ctx_acceptance_flg_tbl,  -- bug 17164050
          l_ctx_inventory_item_id_tbl,
          l_ctx_source_type_tbl,
          l_ctx_item_type_tbl,
          l_ctx_purchasing_org_id_tbl,
          l_ctx_supplier_id_tbl,
          l_ctx_supplier_site_id_tbl,
          l_ctx_supplier_part_num_tbl,
          l_ctx_supplier_part_auxid_tbl,
          l_ctx_ip_category_id_tbl,
          l_ctx_po_category_id_tbl,
          l_ctx_item_revision_tbl,
          l_ctx_un_number_tbl,
          l_ctx_hazard_class_tbl,
          l_ctx_rowid_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 400;
      EXIT WHEN l_po_line_id_tbl.COUNT = 0;

      l_err_loc := 500;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 600;
      l_count := l_po_line_id_tbl.COUNT;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows returned from the cursor:' || l_count);
      END IF;
      --Save the last po_line_id processed, so that re-open of cursor will start from the saved id.
      l_start_po_line_id := l_po_line_id_tbl(l_count);

      l_row_count := l_row_count + l_count;

      FOR i in 1..l_po_line_id_tbl.COUNT LOOP
        l_err_loc := 700;
        --First get the status of the current GBPA line
        l_GBPA_line_status := ICX_CAT_POPULATE_STATUS_PVT.getGlobalAgreementStatus(l_enabled_flag_tbl(i));

		--bug 16374319 begin
	    SELECT NVL(authorization_status, 'INCOMPLETE')
	    INTO l_authorization_status
	    FROM po_headers_all
	    WHERE po_header_id = l_po_header_id_tbl(i);

        l_err_loc := 800;
        IF ((l_authorization_status = 'APPROVED'
              OR (l_authorization_status = 'PRE-APPROVED'  AND
                     l_ctx_acceptance_flg_tbl(i)='S'))  -- bug 17164050
	   AND
        	   (l_ctx_rowid_tbl(i) IS NOT NULL OR
            l_GBPA_line_status = ICX_CAT_POPULATE_STATUS_PVT.VALID_FOR_POPULATE))
        --bug 16374319 end
        THEN
          l_err_loc := 900;
          l_current_ctx_item_rec.inventory_item_id              := l_inv_item_id_tbl(i);
          l_current_ctx_item_rec.po_line_id                     := l_po_line_id_tbl(i);
          l_current_ctx_item_rec.req_template_name              := TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          l_current_ctx_item_rec.req_template_line_num          := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          l_current_ctx_item_rec.org_id                         := l_org_id_tbl(i);
          l_current_ctx_item_rec.language                       := l_language_tbl(i);
          l_current_ctx_item_rec.source_type                    := l_source_type_tbl(i);
          l_current_ctx_item_rec.item_type                      := ICX_CAT_UTIL_PVT.g_purchase_item_type;
          l_current_ctx_item_rec.purchasing_org_id              := l_purchasing_org_id_tbl(i);
          l_current_ctx_item_rec.owning_org_id                  := l_owning_org_id_tbl(i);
          l_current_ctx_item_rec.po_category_id                 := l_po_category_id_tbl(i);
          l_current_ctx_item_rec.supplier_id                    := l_supplier_id_tbl(i);
          l_current_ctx_item_rec.supplier_part_num              := l_supplier_part_num_tbl(i);
          l_current_ctx_item_rec.supplier_part_auxid            := l_supplier_part_auxid_tbl(i);
          l_current_ctx_item_rec.supplier_site_id               := l_supplier_site_id_tbl(i);
          l_current_ctx_item_rec.status                         := l_GBPA_line_status;
          l_current_ctx_item_rec.ip_category_id                 := l_ip_category_id_tbl(i);
          l_current_ctx_item_rec.ip_category_name               := l_ip_category_name_tbl(i);
          l_current_ctx_item_rec.req_template_po_line_id        := NULL;
          l_current_ctx_item_rec.item_revision                  := l_item_revision_tbl(i);
          l_current_ctx_item_rec.po_header_id                   := l_po_header_id_tbl(i);
          l_current_ctx_item_rec.document_number                := l_document_number_tbl(i);
          l_current_ctx_item_rec.line_num                       := l_line_num_tbl(i);
          l_current_ctx_item_rec.allow_price_override_flag      := l_allow_prc_override_flag_tbl(i);
          l_current_ctx_item_rec.not_to_exceed_price            := l_not_to_exceed_price_tbl(i);
          l_current_ctx_item_rec.line_type_id                   := l_line_type_id_tbl(i);
          l_current_ctx_item_rec.unit_meas_lookup_code          := l_unit_meas_lookup_code_tbl(i);
          l_current_ctx_item_rec.suggested_quantity             := NULL;
          l_current_ctx_item_rec.unit_price                     := l_unit_price_tbl(i);
          l_current_ctx_item_rec.amount                         := l_amount_tbl(i);
          l_current_ctx_item_rec.currency_code                  := l_currency_code_tbl(i);
          l_current_ctx_item_rec.rate_type                      := l_rate_type_tbl(i);
          l_current_ctx_item_rec.rate_date                      := l_rate_date_tbl(i);
          l_current_ctx_item_rec.rate                           := l_rate_tbl(i);
          l_current_ctx_item_rec.buyer_id                       := l_buyer_id_tbl(i);
          l_current_ctx_item_rec.supplier_contact_id            := l_supplier_contact_id_tbl(i);
          l_current_ctx_item_rec.rfq_required_flag              := 'N';
          l_current_ctx_item_rec.negotiated_by_preparer_flag    := l_negotiated_preparer_flag_tbl(i);
          l_current_ctx_item_rec.description                    := NULL;
          l_current_ctx_item_rec.order_type_lookup_code         := l_order_type_lookup_code_tbl(i);
          l_current_ctx_item_rec.supplier                       := l_supplier_tbl(i);
          l_current_ctx_item_rec.global_agreement_flag          := l_global_agreement_flag_tbl(i);
          l_current_ctx_item_rec.merged_source_type             := 'SRC_DOC';
          l_current_ctx_item_rec.ctx_inventory_item_id          := l_ctx_inventory_item_id_tbl(i);
          l_current_ctx_item_rec.ctx_source_type                := l_ctx_source_type_tbl(i);
          l_current_ctx_item_rec.ctx_item_type                  := l_ctx_item_type_tbl(i);
          l_current_ctx_item_rec.ctx_purchasing_org_id          := l_ctx_purchasing_org_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_id                := l_ctx_supplier_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_site_id           := l_ctx_supplier_site_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_part_num          := l_ctx_supplier_part_num_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_part_auxid        := l_ctx_supplier_part_auxid_tbl(i);
          l_current_ctx_item_rec.ctx_ip_category_id             := l_ctx_ip_category_id_tbl(i);
          l_current_ctx_item_rec.ctx_po_category_id             := l_ctx_po_category_id_tbl(i);
          l_current_ctx_item_rec.ctx_item_revision              := l_ctx_item_revision_tbl(i);
          l_current_ctx_item_rec.ctx_rowid                      := l_ctx_rowid_tbl(i);
          -- 17076597 changes
          l_current_ctx_item_rec.ctx_un_number                  := l_ctx_un_number_tbl(i);
          l_current_ctx_item_rec.un_number                      := l_un_number_tbl(i);
          l_current_ctx_item_rec.ctx_hazard_class               := l_ctx_hazard_class_tbl(i);
          l_current_ctx_item_rec.hazard_class                   := l_hazard_class_tbl(i);

          l_err_loc := 1300;
          ICX_CAT_POPULATE_ITEM_PVT.processCurrentCtxItemRow(l_current_ctx_item_rec, g_current_cursor, p_current_mode);

          l_err_loc := 1400;
          ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('INLOOP', ICX_CAT_UTIL_PVT.g_GBPACsr_const);
        ELSE
          IF (p_current_mode = ICX_CAT_UTIL_PVT.g_upgrade_const) THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', with po_line_id:' || l_po_line_id_tbl(i) ||', not processed' ||
                  ', l_enabled_flag_tbl:' || l_enabled_flag_tbl(i) ||
                  ', status: ' || l_GBPA_line_status);
            END IF;
          ELSE
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', with po_line_id:' || l_po_line_id_tbl(i) ||', not processed' ||
                  ', l_enabled_flag_tbl:' || l_enabled_flag_tbl(i) ||
                  ', status: ' || l_GBPA_line_status);
            END IF;
          END IF;
        END IF;
      END LOOP;  -- FOR LOOP of l_po_line_id_tbl

      l_err_loc := 1500;
      EXIT WHEN l_po_line_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := 'ICX_CAT_POPULATE_PODOCS_PVT.populateGBPAs' ||l_err_loc
                        ||', Total processed batches:' ||l_batch_count
                        ||', Cursor will be reopened with po_line_id:' ||l_start_po_line_id;
        IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
          ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
          -- Closing and reopen of cursor will be done by called procedures
          IF (p_current_mode = ICX_CAT_UTIL_PVT.g_upgrade_const) THEN
            l_err_loc := 1600;
            openR12UpgradeGBPACursor;
          ELSE
            l_err_loc := 1700;
            IF (g_current_cursor = 'ORG_ASSIGNMENT_CSR') THEN
              l_err_loc := 1800;
              openGBPAOrgAssignmentCursor(g_key, l_start_po_line_id);
            ELSE
              l_err_loc := 1900;
              openGBPACursor(g_key, l_start_po_line_id);
            END IF;
          END IF;
        ELSE
          RAISE;
        END IF;
    END;
  END LOOP; -- Cursor loop

  l_err_loc := 2000;
  ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('OUTLOOP', ICX_CAT_UTIL_PVT.g_GBPACsr_const);

  l_err_loc := 2100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'populateGBPAs in mode:'|| p_current_mode ||' done; '||
        'Total num. of batches processed:' ||l_batch_count ||
        ', Total num. of rows fetched:' ||l_row_count);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateGBPAs;

----------------------------------------------------------------------
-----------------  End of GBPA specific Code    ----------------------
-----------------  Start of BPA and GBPA Online API calls ------------
----------------------------------------------------------------------

PROCEDURE populateOnlineBlankets
(       p_key                   IN              NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'populateOnlineBlankets';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  -- Set the batch_size
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 200;
  -- Set the who columns
  ICX_CAT_UTIL_PVT.setWhoColumns(null);

  l_err_loc := 250;
  g_current_cursor := 'GBPA_CSR';

  l_err_loc := 300;
  g_key := p_key;

  l_err_loc := 350;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logPOSessionGTData(p_key);
  END IF;

  l_err_loc := 400;
  openBPACursor(p_key, 0);

  l_err_loc := 500;
  openGBPACursor(p_key, 0);

  l_err_loc := 600;
  g_metadataTblFormed := FALSE;
  g_CtxSqlForPODocsFormed := FALSE;

  l_err_loc := 700;
  ICX_CAT_POPULATE_CTXSTRING_PVT.populateCtxCatgAtt(ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id);

  l_err_loc := 800;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateOnlineBlankets;

PROCEDURE populateOnlineOrgAssgnmnts
(       p_key                   IN              NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'populateOnlineOrgAssgnmnts';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  -- Set the batch_size
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 200;
  -- Set the who columns
  ICX_CAT_UTIL_PVT.setWhoColumns(null);

  l_err_loc := 300;
  g_current_cursor := 'ORG_ASSIGNMENT_CSR';
  g_key := p_key;

  l_err_loc := 350;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logPOSessionGTData(p_key);
  END IF;

  l_err_loc := 400;
  openBPAOrgAssignmentCursor(p_key, 0);

  l_err_loc := 450;
  openGBPAOrgAssignmentCursor(p_key, 0);

  l_err_loc := 500;
  g_metadataTblFormed := FALSE;
  g_CtxSqlForPODocsFormed := FALSE;

  l_err_loc := 600;
  -- No need of to re-populate category attributes
  -- i.e. call ICX_CAT_POPULATE_CTXSTRING_PVT.populateCtxCatgAtt
  -- because the changes are only in the org assignments.
  -- ICX_CAT_POPULATE_CTXSTRING_PVT.populateCtxCatgAtt(ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id);

  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateOnlineOrgAssgnmnts;

----------------------------------------------------------------------
--------------  End of BPA and GBPA Online API calls -----------------
--------------  Start of BPA and Quote specific Code -----------------
----------------------------------------------------------------------

PROCEDURE openR12UpgradeBPAQuoteCursor
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openR12UpgradeBPAQuoteCursor';
  l_err_loc             PLS_INTEGER;
  l_bpa_quote_csr       ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', g_upgrade_last_run_date:' || g_upgrade_last_run_date ||
        ', g_start_rowid:' || g_start_rowid ||
        ', g_end_rowid:' || g_end_rowid );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_bpa_quote_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_bpa_quote_csr;
  END IF;

  l_err_loc := 300;
  --Comments on the cursor
  --Move the outside operation flag of a line type to the main cursor from the
  --status function due to the following reasons:
  --1. PO has confirmed that the outside operation flag
  --   of a line type cannot be changed once set
  --2. The main cursor anyways joins with po_line_types_b
  --   to eliminate the TEMP LABOR line
  -- 17076597 changes added un_number and hazard_class
  IF (g_upgrade_last_run_date) IS NULL THEN
    l_err_loc := 400;
    OPEN l_bpa_quote_csr FOR
      SELECT /*+ LEADING(doc) use_nl_with_index(ctx,ICX_CAT_ITEMS_CTX_HDRS_TLP_PK) NO_EXPAND */
             doc.*,
             ctx.inventory_item_id ctx_inventory_item_id,
             ctx.source_type ctx_source_type,
             ctx.item_type ctx_item_type,
             ctx.purchasing_org_id ctx_purchasing_org_id,
             ctx.supplier_id ctx_supplier_id,
             ctx.supplier_site_id ctx_supplier_site_id,
             ctx.supplier_part_num ctx_supplier_part_num,
             ctx.supplier_part_auxid ctx_supplier_part_auxid,
             ctx.ip_category_id ctx_ip_category_id,
             ctx.po_category_id ctx_po_category_id,
             ctx.item_revision ctx_item_revision,
             ctx.un_number ctx_un_number,
             ctx.hazard_class ctx_hazard_class,
             ROWIDTOCHAR(ctx.rowid) ctx_rowid
      FROM (
           SELECT /*+ ROWID(poh) use_nl(pl,ga,po_tlp,ic) */
                  NVL(pl.item_id, -2) inventory_item_id,
                  pl.po_line_id po_line_id,
                  NVL(pl.org_id, -2) org_id,
                  po_tlp.language language,
                  ph.type_lookup_code source_type,
                  DECODE(NVL(ph.global_agreement_flag, 'N'),
                         'Y', NVL(ga.purchasing_org_id, pl.org_id),
                         NVL(pl.org_id, -2)) purchasing_org_id,
                  pl.category_id po_category_id,
                  NVL(ph.vendor_id, -2) supplier_id,
                  NVL(pl.vendor_product_num, '##NULL##') supplier_part_num,
                  NVL(pl.supplier_part_auxid, '##NULL##') supplier_part_auxid,
                  DECODE(NVL(ph.global_agreement_flag, 'N'),
                         'Y', NVL(ga.vendor_site_id, -2),
                         NVL(ph.vendor_site_id, -2)) supplier_site_id,
                  pl.ip_category_id ip_category_id,
                  ic.category_name ip_category_name,
                  NVL(pl.item_revision, '-2') item_revision,
                  ph.po_header_id,
                  ph.segment1 document_number,
                  pl.line_num,
                  UPPER(NVL(pl.allow_price_override_flag, 'N')) allow_price_override_flag,
                  pl.not_to_exceed_price,
                  pl.line_type_id,
                  pl.unit_meas_lookup_code,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', pl.unit_price, to_number(null)) unit_price,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), pl.amount) amount,
                  ph.currency_code,
                  ph.rate_type,
                  ph.rate_date,
                  ph.rate,
                  ph.agent_id buyer_id,
                  ph.vendor_contact_id supplier_contact_id,
                  DECODE(ph.type_lookup_code, 'QUOTATION', 'Y',
                         NVL(pl.negotiated_by_preparer_flag, 'N')) negotiated_by_preparer_flag,
                  pltb.order_type_lookup_code,
                  pv.vendor_name supplier,
                  ph.global_agreement_flag global_agreement_flag,
                  --For Quote line status
                  DECODE(ph.type_lookup_code, 'QUOTATION',
                         ICX_CAT_POPULATE_STATUS_PVT.getQuoteLineStatus(pl.po_line_id),
                         NULL) quote_status,
                  --For blanket line status
                  ph.approved_date,
                  NVL(ph.authorization_status, 'INCOMPLETE') authorization_status,
                  NVL(ph.frozen_flag, 'N') frozen_flag,
                  NVL(ph.cancel_flag, 'N') hdr_cancel_flag,
                  NVL(pl.cancel_flag, 'N') line_cancel_flag,
                  NVL(ph.closed_code, 'OPEN') hdr_closed_code,
                  NVL(pl.closed_code, 'OPEN') line_closed_code,
                  NVL(TRUNC(ph.end_date), TRUNC(SYSDATE + 1)) end_date,
                  NVL(TRUNC(pl.expiration_date), TRUNC(SYSDATE + 1)) expiration_date,
                  TRUNC(SYSDATE) system_date,
                  ph.created_by,
                  pun.un_number,
                  phc.hazard_class
           FROM po_headers_all ph,
                po_lines_all pl,
                po_ga_org_assignments ga,
                po_attribute_values_tlp po_tlp,
                po_line_types_b pltb,
                icx_cat_categories_tl ic,
                po_vendors pv,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE ph.po_header_id = pl.po_header_id
           AND ph.type_lookup_code IN ('BLANKET', 'QUOTATION')
           AND ph.po_header_id = ga.po_header_id (+)
           AND ph.org_id = ga.organization_id (+)
           AND pl.po_line_id = po_tlp.po_line_id
           AND pl.line_type_id = pltb.line_type_id
           AND NVL(pltb.purchase_basis, 'NULL') <> 'TEMP LABOR'
           AND NVL(pltb.outside_operation_flag, 'N') = 'N'
           AND po_tlp.ip_category_id = ic.rt_category_id (+)
           AND po_tlp.language = ic.language (+)
           AND ph.vendor_id = pv.vendor_id(+)
           AND pl.UN_NUMBER_ID = pun.un_number_id(+)
           AND pl.HAZARD_CLASS_ID = phc.hazard_class_id(+)
           AND ph.rowid BETWEEN g_start_rowid AND g_end_rowid
           ) doc,
           icx_cat_items_ctx_hdrs_tlp ctx
      WHERE doc.po_line_id = ctx.po_line_id (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.language = ctx.language (+)
      AND (doc.source_type = 'BLANKET'
           OR (ctx.rowid IS NOT NULL OR doc.quote_status = 0));
  ELSE
    l_err_loc := 500;
    OPEN l_bpa_quote_csr FOR
      SELECT /*+ LEADING(doc) use_nl_with_index(ctx,ICX_CAT_ITEMS_CTX_HDRS_TLP_PK) NO_EXPAND */
             doc.*,
             ctx.inventory_item_id ctx_inventory_item_id,
             ctx.source_type ctx_source_type,
             ctx.item_type ctx_item_type,
             ctx.purchasing_org_id ctx_purchasing_org_id,
             ctx.supplier_id ctx_supplier_id,
             ctx.supplier_site_id ctx_supplier_site_id,
             ctx.supplier_part_num ctx_supplier_part_num,
             ctx.supplier_part_auxid ctx_supplier_part_auxid,
             ctx.ip_category_id ctx_ip_category_id,
             ctx.po_category_id ctx_po_category_id,
             ctx.item_revision ctx_item_revision,
             ctx.un_number ctx_un_number,
             ctx.hazard_class ctx_hazard_class,
             ROWIDTOCHAR(ctx.rowid) ctx_rowid
      FROM (
           SELECT /*+ ROWID(poh) use_nl(pl,ga,po_tlp,ic) */
                  NVL(pl.item_id, -2) inventory_item_id,
                  pl.po_line_id po_line_id,
                  NVL(pl.org_id, -2) org_id,
                  po_tlp.language language,
                  ph.type_lookup_code source_type,
                  DECODE(NVL(ph.global_agreement_flag, 'N'),
                         'Y', NVL(ga.purchasing_org_id, pl.org_id),
                         NVL(pl.org_id, -2)) purchasing_org_id,
                  pl.category_id po_category_id,
                  NVL(ph.vendor_id, -2) supplier_id,
                  NVL(pl.vendor_product_num, '##NULL##') supplier_part_num,
                  NVL(pl.supplier_part_auxid, '##NULL##') supplier_part_auxid,
                  DECODE(NVL(ph.global_agreement_flag, 'N'),
                         'Y', NVL(ga.vendor_site_id, -2),
                         NVL(ph.vendor_site_id, -2)) supplier_site_id,
                  pl.ip_category_id ip_category_id,
                  ic.category_name ip_category_name,
                  NVL(pl.item_revision, '-2') item_revision,
                  ph.po_header_id,
                  ph.segment1 document_number,
                  pl.line_num,
                  UPPER(NVL(pl.allow_price_override_flag, 'N')) allow_price_override_flag,
                  pl.not_to_exceed_price,
                  pl.line_type_id,
                  pl.unit_meas_lookup_code,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', pl.unit_price, to_number(null)) unit_price,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), pl.amount) amount,
                  ph.currency_code,
                  ph.rate_type,
                  ph.rate_date,
                  ph.rate,
                  ph.agent_id buyer_id,
                  ph.vendor_contact_id supplier_contact_id,
                  DECODE(ph.type_lookup_code, 'QUOTATION', 'Y',
                         NVL(pl.negotiated_by_preparer_flag, 'N')) negotiated_by_preparer_flag,
                  pltb.order_type_lookup_code,
                  pv.vendor_name supplier,
                  ph.global_agreement_flag global_agreement_flag,
                  --For Quote line status
                  DECODE(ph.type_lookup_code, 'QUOTATION',
                         ICX_CAT_POPULATE_STATUS_PVT.getQuoteLineStatus(pl.po_line_id),
                         NULL) quote_status,
                  --For blanket line status
                  ph.approved_date,
                  NVL(ph.authorization_status, 'INCOMPLETE') authorization_status,
                  NVL(ph.frozen_flag, 'N') frozen_flag,
                  NVL(ph.cancel_flag, 'N') hdr_cancel_flag,
                  NVL(pl.cancel_flag, 'N') line_cancel_flag,
                  NVL(ph.closed_code, 'OPEN') hdr_closed_code,
                  NVL(pl.closed_code, 'OPEN') line_closed_code,
                  NVL(TRUNC(ph.end_date), TRUNC(SYSDATE + 1)) end_date,
                  NVL(TRUNC(pl.expiration_date), TRUNC(SYSDATE + 1)) expiration_date,
                  TRUNC(SYSDATE) system_date,
                  ph.created_by,
                  pun.un_number,
                  phc.hazard_class
           FROM po_headers_all ph,
                po_lines_all pl,
                po_ga_org_assignments ga,
                po_attribute_values_tlp po_tlp,
                po_line_types_b pltb,
                icx_cat_categories_tl ic,
                po_vendors pv,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE ph.po_header_id = pl.po_header_id
           AND ph.type_lookup_code IN ('BLANKET', 'QUOTATION')
           AND ph.po_header_id = ga.po_header_id (+)
           AND ph.org_id = ga.organization_id (+)
           AND pl.po_line_id = po_tlp.po_line_id
           AND pl.line_type_id = pltb.line_type_id
           AND NVL(pltb.purchase_basis, 'NULL') <> 'TEMP LABOR'
           AND NVL(pltb.outside_operation_flag, 'N') = 'N'
           AND po_tlp.ip_category_id = ic.rt_category_id (+)
           AND po_tlp.language = ic.language (+)
           AND ph.vendor_id = pv.vendor_id(+)
           AND pl.UN_NUMBER_ID = pun.un_number_id(+)
           AND pl.HAZARD_CLASS_ID = phc.hazard_class_id(+)
           AND ph.rowid BETWEEN g_start_rowid AND g_end_rowid
           AND (ph.last_update_date > g_upgrade_last_run_date
                OR pl.last_update_date > g_upgrade_last_run_date
                OR ga.last_update_date > g_upgrade_last_run_date
                OR po_tlp.last_update_date > g_upgrade_last_run_date)
           ) doc,
           icx_cat_items_ctx_hdrs_tlp ctx
      WHERE doc.po_line_id = ctx.po_line_id (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.language = ctx.language (+)
      AND (doc.source_type = 'BLANKET'
           OR (ctx.rowid IS NOT NULL OR doc.quote_status = 0));
  END IF;

  l_err_loc := 700;
  populateBPAandQuotes(l_bpa_quote_csr, ICX_CAT_UTIL_PVT.g_upgrade_const);

  l_err_loc := 800;
  CLOSE l_bpa_quote_csr;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openR12UpgradeBPAQuoteCursor;

PROCEDURE populateBPAandQuotes
(       p_podocs_csr            IN              ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN              VARCHAR2
)
IS
  l_api_name                            CONSTANT VARCHAR2(30)   := 'populateBPAandQuotes';
  l_err_loc                             PLS_INTEGER;
  l_err_string                          VARCHAR2(4000);
  l_batch_count                         PLS_INTEGER;
  l_row_count                           PLS_INTEGER;
  l_count                               PLS_INTEGER;
  l_BPA_line_status_rec                 ICX_CAT_POPULATE_STATUS_PVT.g_BPA_line_status_rec_type;
  l_podoc_status                        PLS_INTEGER;
  l_current_ctx_item_rec                ICX_CAT_POPULATE_ITEM_PVT.g_ctx_item_rec_type;

  ----- Start of declaring columns selected in the cursor -----
  l_inv_item_id_tbl                     DBMS_SQL.NUMBER_TABLE;
  l_po_line_id_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                          DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                        DBMS_SQL.VARCHAR2_TABLE;
  l_source_type_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  l_purchasing_org_id_tbl               DBMS_SQL.NUMBER_TABLE;
  l_po_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_supplier_id_tbl                     DBMS_SQL.NUMBER_TABLE;
  l_supplier_part_num_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_part_auxid_tbl             DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_site_id_tbl                DBMS_SQL.NUMBER_TABLE;
  l_ip_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_ip_category_name_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_item_revision_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_po_header_id_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_document_number_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_line_num_tbl                        DBMS_SQL.NUMBER_TABLE;
  l_allow_prc_override_flag_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_not_to_exceed_price_tbl             DBMS_SQL.NUMBER_TABLE;
  l_line_type_id_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_unit_meas_lookup_code_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_unit_price_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_amount_tbl                          DBMS_SQL.NUMBER_TABLE;
  l_currency_code_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_rate_type_tbl                       DBMS_SQL.VARCHAR2_TABLE;
  l_rate_date_tbl                       DBMS_SQL.DATE_TABLE;
  l_rate_tbl                            DBMS_SQL.NUMBER_TABLE;
  l_buyer_id_tbl                        DBMS_SQL.NUMBER_TABLE;
  l_supplier_contact_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_negotiated_preparer_flag_tbl        DBMS_SQL.VARCHAR2_TABLE;
  l_order_type_lookup_code_tbl          DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_tbl                        DBMS_SQL.VARCHAR2_TABLE;
  l_global_agreement_flag_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_quote_status_tbl                    DBMS_SQL.VARCHAR2_TABLE;
  l_approved_date_tbl                   DBMS_SQL.DATE_TABLE;
  l_authorization_status_tbl            DBMS_SQL.VARCHAR2_TABLE;
  l_frozen_flag_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  l_hdr_cancel_flag_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_line_cancel_flag_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_hdr_closed_code_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_line_closed_code_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_end_date_tbl                        DBMS_SQL.DATE_TABLE;
  l_expiration_date_tbl                 DBMS_SQL.DATE_TABLE;
  l_system_date_tbl                     DBMS_SQL.DATE_TABLE;
  l_created_by_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_ctx_inventory_item_id_tbl           DBMS_SQL.NUMBER_TABLE;
  l_ctx_source_type_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_item_type_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_purchasing_org_id_tbl           DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_id_tbl                 DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_site_id_tbl            DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_part_num_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_supplier_part_auxid_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_ip_category_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_ctx_po_category_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_ctx_item_revision_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_rowid_tbl                       DBMS_SQL.UROWID_TABLE;
  -- 17076597 changes starts
  l_ctx_un_number_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_un_number_tbl                       DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_hazard_class_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_hazard_class_tbl                    DBMS_SQL.VARCHAR2_TABLE;
  -- 17076597 changes ends

  ------ End of declaring columns selected in the cursor ------

BEGIN
  l_err_loc := 100;
  l_batch_count := 0;
  l_row_count := 0;
  l_count := 0;
  LOOP
    l_err_loc := 110;
    l_inv_item_id_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;
    l_source_type_tbl.DELETE;
    l_purchasing_org_id_tbl.DELETE;
    l_po_category_id_tbl.DELETE;
    l_supplier_id_tbl.DELETE;
    l_supplier_part_num_tbl.DELETE;
    l_supplier_part_auxid_tbl.DELETE;
    l_supplier_site_id_tbl.DELETE;
    l_ip_category_id_tbl.DELETE;
    l_ip_category_name_tbl.DELETE;
    l_item_revision_tbl.DELETE;
    l_po_header_id_tbl.DELETE;
    l_document_number_tbl.DELETE;
    l_line_num_tbl.DELETE;
    l_allow_prc_override_flag_tbl.DELETE;
    l_not_to_exceed_price_tbl.DELETE;
    l_line_type_id_tbl.DELETE;
    l_unit_meas_lookup_code_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_amount_tbl.DELETE;
    l_currency_code_tbl.DELETE;
    l_rate_type_tbl.DELETE;
    l_rate_date_tbl.DELETE;
    l_rate_tbl.DELETE;
    l_buyer_id_tbl.DELETE;
    l_supplier_contact_id_tbl.DELETE;
    l_negotiated_preparer_flag_tbl.DELETE;
    l_order_type_lookup_code_tbl.DELETE;
    l_supplier_tbl.DELETE;
    l_global_agreement_flag_tbl.DELETE;
    l_quote_status_tbl.DELETE;
    l_approved_date_tbl.DELETE;
    l_authorization_status_tbl.DELETE;
    l_frozen_flag_tbl.DELETE;
    l_hdr_cancel_flag_tbl.DELETE;
    l_line_cancel_flag_tbl.DELETE;
    l_hdr_closed_code_tbl.DELETE;
    l_line_closed_code_tbl.DELETE;
    l_end_date_tbl.DELETE;
    l_expiration_date_tbl.DELETE;
    l_system_date_tbl.DELETE;
    l_created_by_tbl.DELETE;
    l_ctx_inventory_item_id_tbl.DELETE;
    l_ctx_source_type_tbl.DELETE;
    l_ctx_item_type_tbl.DELETE;
    l_ctx_purchasing_org_id_tbl.DELETE;
    l_ctx_supplier_id_tbl.DELETE;
    l_ctx_supplier_site_id_tbl.DELETE;
    l_ctx_supplier_part_num_tbl.DELETE;
    l_ctx_supplier_part_auxid_tbl.DELETE;
    l_ctx_ip_category_id_tbl.DELETE;
    l_ctx_po_category_id_tbl.DELETE;
    l_ctx_item_revision_tbl.DELETE;
    l_ctx_rowid_tbl.DELETE;
    -- 17076597 changes
    l_ctx_un_number_tbl.DELETE;
    l_un_number_tbl.DELETE;
    l_ctx_hazard_class_tbl.DELETE;
    l_hazard_class_tbl.DELETE;


    BEGIN
      l_err_loc := 200;
      FETCH p_podocs_csr BULK COLLECT INTO
          l_inv_item_id_tbl,
          l_po_line_id_tbl,
          l_org_id_tbl,
          l_language_tbl,
          l_source_type_tbl,
          l_purchasing_org_id_tbl,
          l_po_category_id_tbl,
          l_supplier_id_tbl,
          l_supplier_part_num_tbl,
          l_supplier_part_auxid_tbl,
          l_supplier_site_id_tbl,
          l_ip_category_id_tbl,
          l_ip_category_name_tbl,
          l_item_revision_tbl,
          l_po_header_id_tbl,
          l_document_number_tbl,
          l_line_num_tbl,
          l_allow_prc_override_flag_tbl,
          l_not_to_exceed_price_tbl,
          l_line_type_id_tbl,
          l_unit_meas_lookup_code_tbl,
          l_unit_price_tbl,
          l_amount_tbl,
          l_currency_code_tbl,
          l_rate_type_tbl,
          l_rate_date_tbl,
          l_rate_tbl,
          l_buyer_id_tbl,
          l_supplier_contact_id_tbl,
          l_negotiated_preparer_flag_tbl,
          l_order_type_lookup_code_tbl,
          l_supplier_tbl,
          l_global_agreement_flag_tbl,
          l_quote_status_tbl,
          l_approved_date_tbl,
          l_authorization_status_tbl,
          l_frozen_flag_tbl,
          l_hdr_cancel_flag_tbl,
          l_line_cancel_flag_tbl,
          l_hdr_closed_code_tbl,
          l_line_closed_code_tbl,
          l_end_date_tbl,
          l_expiration_date_tbl,
          l_system_date_tbl,
          l_created_by_tbl,
          l_un_number_tbl,
          l_hazard_class_tbl,
          l_ctx_inventory_item_id_tbl,
          l_ctx_source_type_tbl,
          l_ctx_item_type_tbl,
          l_ctx_purchasing_org_id_tbl,
          l_ctx_supplier_id_tbl,
          l_ctx_supplier_site_id_tbl,
          l_ctx_supplier_part_num_tbl,
          l_ctx_supplier_part_auxid_tbl,
          l_ctx_ip_category_id_tbl,
          l_ctx_po_category_id_tbl,
          l_ctx_item_revision_tbl,
          l_ctx_un_number_tbl,
          l_ctx_hazard_class_tbl,
          l_ctx_rowid_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 300;
      EXIT WHEN l_po_line_id_tbl.COUNT = 0;

      l_err_loc := 400;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 500;
      l_count := l_po_line_id_tbl.COUNT;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows returned from the cursor:' || l_count);
      END IF;

      l_row_count := l_row_count + l_count;

      FOR i in 1..l_po_line_id_tbl.COUNT LOOP
        l_err_loc := 600;
        IF (l_source_type_tbl(i) = 'BLANKET') THEN
          --First get the status of the current BPA line
          IF (p_current_mode = ICX_CAT_UTIL_PVT.g_upgrade_const AND
              l_created_by_tbl(i) = ICX_CAT_UTIL_PVT.g_upgrade_user)
          THEN
            l_err_loc := 700;
            -- The GBPAs created for bulkload items will not be in approved
            -- status during upgrade, so treat them as valid during upgrade.
            l_podoc_status := ICX_CAT_POPULATE_STATUS_PVT.VALID_FOR_POPULATE;
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'bpa status is hard-coded to valid for' ||
                  ', p_current_mode:' || p_current_mode ||
                  ', l_created_by_tbl(i):' || l_created_by_tbl(i) );
            END IF;
          ELSE
            l_err_loc := 800;
            l_BPA_line_status_rec.approved_date           := l_approved_date_tbl(i);
            l_BPA_line_status_rec.authorization_status    := l_authorization_status_tbl(i);
            l_BPA_line_status_rec.frozen_flag             := l_frozen_flag_tbl(i);
            l_BPA_line_status_rec.hdr_cancel_flag         := l_hdr_cancel_flag_tbl(i);
            l_BPA_line_status_rec.line_cancel_flag        := l_line_cancel_flag_tbl(i);
            l_BPA_line_status_rec.hdr_closed_code         := l_hdr_closed_code_tbl(i);
            l_BPA_line_status_rec.line_closed_code        := l_line_closed_code_tbl(i);
            l_BPA_line_status_rec.end_date                := l_end_date_tbl(i);
            l_BPA_line_status_rec.expiration_date         := l_expiration_date_tbl(i);
            l_BPA_line_status_rec.system_date             := l_system_date_tbl(i);

            l_err_loc := 900;
            l_podoc_status := ICX_CAT_POPULATE_STATUS_PVT.getBPALineStatus(l_BPA_line_status_rec);
          END IF;
        ELSE
          l_podoc_status := l_quote_status_tbl(i);
        END IF;

        l_err_loc := 1000;
        IF (l_ctx_rowid_tbl(i) IS NOT NULL OR
            l_podoc_status = ICX_CAT_POPULATE_STATUS_PVT.VALID_FOR_POPULATE)
        THEN
          l_err_loc := 1100;
          l_current_ctx_item_rec.inventory_item_id              := l_inv_item_id_tbl(i);
          l_current_ctx_item_rec.po_line_id                     := l_po_line_id_tbl(i);
          l_current_ctx_item_rec.req_template_name              := TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          l_current_ctx_item_rec.req_template_line_num          := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          l_current_ctx_item_rec.org_id                         := l_org_id_tbl(i);
          l_current_ctx_item_rec.language                       := l_language_tbl(i);
          l_current_ctx_item_rec.source_type                    := l_source_type_tbl(i);
          l_current_ctx_item_rec.item_type                      := ICX_CAT_UTIL_PVT.g_purchase_item_type;
          l_current_ctx_item_rec.purchasing_org_id              := l_purchasing_org_id_tbl(i);
          l_current_ctx_item_rec.owning_org_id                  := l_org_id_tbl(i);
          l_current_ctx_item_rec.po_category_id                 := l_po_category_id_tbl(i);
          l_current_ctx_item_rec.supplier_id                    := l_supplier_id_tbl(i);
          l_current_ctx_item_rec.supplier_part_num              := l_supplier_part_num_tbl(i);
          l_current_ctx_item_rec.supplier_part_auxid            := l_supplier_part_auxid_tbl(i);
          l_current_ctx_item_rec.supplier_site_id               := l_supplier_site_id_tbl(i);
          l_current_ctx_item_rec.status                         := l_podoc_status;
          l_current_ctx_item_rec.ip_category_id                 := l_ip_category_id_tbl(i);
          l_current_ctx_item_rec.ip_category_name               := l_ip_category_name_tbl(i);
          l_current_ctx_item_rec.req_template_po_line_id        := NULL;
          l_current_ctx_item_rec.item_revision                  := l_item_revision_tbl(i);
          l_current_ctx_item_rec.po_header_id                   := l_po_header_id_tbl(i);
          l_current_ctx_item_rec.document_number                := l_document_number_tbl(i);
          l_current_ctx_item_rec.line_num                       := l_line_num_tbl(i);
          l_current_ctx_item_rec.allow_price_override_flag      := l_allow_prc_override_flag_tbl(i);
          l_current_ctx_item_rec.not_to_exceed_price            := l_not_to_exceed_price_tbl(i);
          l_current_ctx_item_rec.line_type_id                   := l_line_type_id_tbl(i);
          l_current_ctx_item_rec.unit_meas_lookup_code          := l_unit_meas_lookup_code_tbl(i);
          l_current_ctx_item_rec.suggested_quantity             := NULL;
          l_current_ctx_item_rec.unit_price                     := l_unit_price_tbl(i);
          l_current_ctx_item_rec.amount                         := l_amount_tbl(i);
          l_current_ctx_item_rec.currency_code                  := l_currency_code_tbl(i);
          l_current_ctx_item_rec.rate_type                      := l_rate_type_tbl(i);
          l_current_ctx_item_rec.rate_date                      := l_rate_date_tbl(i);
          l_current_ctx_item_rec.rate                           := l_rate_tbl(i);
          l_current_ctx_item_rec.buyer_id                       := l_buyer_id_tbl(i);
          l_current_ctx_item_rec.supplier_contact_id            := l_supplier_contact_id_tbl(i);
          l_current_ctx_item_rec.rfq_required_flag              := 'N';
          l_current_ctx_item_rec.negotiated_by_preparer_flag    := l_negotiated_preparer_flag_tbl(i);
          l_current_ctx_item_rec.description                    := NULL;
          l_current_ctx_item_rec.order_type_lookup_code         := l_order_type_lookup_code_tbl(i);
          l_current_ctx_item_rec.supplier                       := l_supplier_tbl(i);
          l_current_ctx_item_rec.global_agreement_flag          := l_global_agreement_flag_tbl(i);
          l_current_ctx_item_rec.merged_source_type             := 'SRC_DOC';
          l_current_ctx_item_rec.ctx_inventory_item_id          := l_ctx_inventory_item_id_tbl(i);
          l_current_ctx_item_rec.ctx_source_type                := l_ctx_source_type_tbl(i);
          l_current_ctx_item_rec.ctx_item_type                  := l_ctx_item_type_tbl(i);
          l_current_ctx_item_rec.ctx_purchasing_org_id          := l_ctx_purchasing_org_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_id                := l_ctx_supplier_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_site_id           := l_ctx_supplier_site_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_part_num          := l_ctx_supplier_part_num_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_part_auxid        := l_ctx_supplier_part_auxid_tbl(i);
          l_current_ctx_item_rec.ctx_ip_category_id             := l_ctx_ip_category_id_tbl(i);
          l_current_ctx_item_rec.ctx_po_category_id             := l_ctx_po_category_id_tbl(i);
          l_current_ctx_item_rec.ctx_rowid                      := l_ctx_rowid_tbl(i);
          -- 17076597 changes
          l_current_ctx_item_rec.ctx_un_number                  := l_ctx_un_number_tbl(i);
          l_current_ctx_item_rec.un_number                      := l_un_number_tbl(i);
          l_current_ctx_item_rec.ctx_hazard_class               := l_ctx_hazard_class_tbl(i);
          l_current_ctx_item_rec.hazard_class                   := l_hazard_class_tbl(i);

          l_err_loc := 1300;
          ICX_CAT_POPULATE_ITEM_PVT.processCurrentCtxItemRow(l_current_ctx_item_rec, null, p_current_mode);

          l_err_loc := 1400;
          ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('INLOOP', ICX_CAT_UTIL_PVT.g_BPACsr_const);
        ELSE
          IF (p_current_mode = ICX_CAT_UTIL_PVT.g_upgrade_const) THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', with po_line_id:' || l_po_line_id_tbl(i) ||', not processed' ||
                  ', l_source_type_tbl:' || l_source_type_tbl(i) ||
                  ', l_approved_date_tbl:' || l_approved_date_tbl(i) ||
                  ', l_authorization_status_tbl:' || l_authorization_status_tbl(i) ||
                  ', l_frozen_flag_tbl:' || l_frozen_flag_tbl(i) ||
                  ', l_hdr_cancel_flag_tbl:' || l_hdr_cancel_flag_tbl(i) ||
                  ', l_line_cancel_flag_tbl:' || l_line_cancel_flag_tbl(i) ||
                  ', l_hdr_closed_code_tbl:' || l_hdr_closed_code_tbl(i) ||
                  ', l_line_closed_code_tbl:' || l_line_closed_code_tbl(i) ||
                  ', l_end_date_tbl:' || l_end_date_tbl(i) ||
                  ', l_expiration_date_tbl:' || l_expiration_date_tbl(i) ||
                  ', l_system_date_tbl:' || l_system_date_tbl(i) ||
                  ', status: ' || l_podoc_status);
            END IF;
          END IF;
        END IF;
      END LOOP;  --FOR LOOP of l_po_line_id_tbl

      l_err_loc := 1500;
      EXIT WHEN l_po_line_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name) || l_err_loc
                        ||', Total processed batches:' ||l_batch_count
                        ||', Cursor will be reopened;';
        IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
          ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
          --Closing and reopen of cursor will be done by called procedures
          l_err_loc := 1600;
          openR12UpgradeBPAQuoteCursor;
        ELSE
          RAISE;
        END IF;
    END;
  END LOOP; --Cursor loop

  l_err_loc := 1800;
  ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('OUTLOOP', ICX_CAT_UTIL_PVT.g_BPACsr_const);

  l_err_loc := 1900;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'in mode:'|| p_current_mode ||' done; '||
        'Total num. of batches processed:' ||l_batch_count ||
        ', Total num. of rows processed:' ||l_row_count);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateBPAandQuotes;

PROCEDURE upgradeR12PODocs
(       p_upgrade_last_run_date IN      DATE    ,
        p_start_rowid           IN      ROWID   ,
        p_end_rowid             IN      ROWID
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'upgradeR12PODocs';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_upgrade_last_run_date := p_upgrade_last_run_date;

  l_err_loc := 200;
  g_start_rowid := p_start_rowid;
  g_end_rowid := p_end_rowid;

  l_err_loc := 300;
  openR12UpgradeBPAQuoteCursor;

  l_err_loc := 400;
  openR12UpgradeGBPACursor;

  l_err_loc := 500;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
    ICX_CAT_UTIL_PVT.g_job_bpa_complete_date := NULL;
    ICX_CAT_UTIL_PVT.g_job_quote_complete_date := NULL;
    ICX_CAT_UTIL_PVT.g_job_current_status := ICX_CAT_UTIL_PVT.g_job_failed_status;
    RAISE;
END upgradeR12PODocs;

----------------------------------------------------------------------
--------------  End of BPA and Quote specific Code -------------------
--------------  Begin of Quotation specific Code ---------------------
----------------------------------------------------------------------

PROCEDURE openQuotesCursor
(       p_key           IN      NUMBER  ,
        p_po_line_id    IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openQuotesCursor';
  l_err_loc             PLS_INTEGER;
  l_quote_csr           ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', p_key:' || p_key ||
        ', p_po_line_id:' || p_po_line_id  );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_quote_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_quote_csr;
  END IF;

  l_err_loc := 300;
  --Comments on the cursor
  --Move the outside operation flag of a line type to the main cursor from the
  --status function due to the following reasons:
  --1. PO has confirmed that the outside operation flag
  --   of a line type cannot be changed once set
  --2. The main cursor anyways joins with po_line_types_b
  --   to eliminate the TEMP LABOR line
  --3. Quote query uses an inline function because we check the existence of a price break at line level
  --   if header level approval_required_flag is Y.
  -- 17076597 changes added un_number and hazard_class
  OPEN l_quote_csr FOR
      SELECT /*+ LEADING(doc) */
             doc.*,
             ctx.inventory_item_id ctx_inventory_item_id,
             ctx.source_type ctx_source_type,
             ctx.item_type ctx_item_type,
             ctx.purchasing_org_id ctx_purchasing_org_id,
             ctx.supplier_id ctx_supplier_id,
             ctx.supplier_site_id ctx_supplier_site_id,
             ctx.supplier_part_num ctx_supplier_part_num,
             ctx.supplier_part_auxid ctx_supplier_part_auxid,
             ctx.ip_category_id ctx_ip_category_id,
             ctx.po_category_id ctx_po_category_id,
             ctx.item_revision ctx_item_revision,
             ctx.un_number ctx_un_number,
             ctx.hazard_class ctx_hazard_class,
             ROWIDTOCHAR(ctx.rowid) ctx_rowid
      FROM (
           SELECT NVL(pl.item_id, -2) inventory_item_id,
                  pl.po_line_id po_line_id,
                  NVL(pl.org_id, -2) org_id,
                  po_tlp.language language,
                  ph.type_lookup_code source_type,
                  NVL(pl.org_id, -2)  purchasing_org_id,
                  pl.category_id po_category_id,
                  NVL(ph.vendor_id, -2) supplier_id,
                  NVL(pl.vendor_product_num, '##NULL##') supplier_part_num,
                  NVL(pl.supplier_part_auxid, '##NULL##') supplier_part_auxid,
                  NVL(ph.vendor_site_id, -2) supplier_site_id,
                  ICX_CAT_POPULATE_STATUS_PVT.getQuoteLineStatus(pl.po_line_id) status,
                  pl.ip_category_id ip_category_id,
                  ic.category_name ip_category_name,
                  NVL(pl.item_revision, '-2') item_revision,
                  ph.po_header_id,
                  ph.segment1 document_number,
                  pl.line_num,
                  UPPER(NVL(pl.allow_price_override_flag, 'N')) allow_price_override_flag,
                  pl.not_to_exceed_price,
                  pl.line_type_id,
                  pl.unit_meas_lookup_code,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', pl.unit_price, to_number(null)) unit_price,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), pl.amount) amount,
                  ph.currency_code,
                  ph.rate_type,
                  ph.rate_date,
                  ph.rate,
                  ph.agent_id buyer_id,
                  ph.vendor_contact_id supplier_contact_id,
                  pltb.order_type_lookup_code,
                  pv.vendor_name supplier,
                  pun.un_number,
                  phc.hazard_class
           FROM po_headers_all ph,
                po_lines_all pl,
                po_session_gt pogt,
                po_attribute_values_tlp po_tlp,
                po_line_types_b pltb,
                icx_cat_categories_tl ic,
                po_vendors pv,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE ph.po_header_id = pl.po_header_id
           AND ph.type_lookup_code = 'QUOTATION'
           AND pogt.key = p_key
           AND pl.po_line_id = pogt.index_num1
           AND pl.po_line_id = po_tlp.po_line_id
           AND pl.line_type_id = pltb.line_type_id
           AND NVL(pltb.purchase_basis, 'NULL') <> 'TEMP LABOR'
           AND NVL(pltb.outside_operation_flag, 'N') = 'N'
           AND po_tlp.ip_category_id = ic.rt_category_id (+)
           AND po_tlp.language = ic.language (+)
           AND ph.vendor_id = pv.vendor_id(+)
           AND pl.UN_NUMBER_ID = pun.un_number_id(+)
           AND pl.HAZARD_CLASS_ID = phc.hazard_class_id(+)
           AND pl.po_line_id >= p_po_line_id
           ) doc,
           icx_cat_items_ctx_hdrs_tlp ctx
      WHERE doc.po_line_id = ctx.po_line_id (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.language = ctx.language (+)
      -- AND (ctx.rowid IS NOT NULL OR doc.status = 0)
      ORDER BY doc.po_line_id;

  l_err_loc := 500;
  populateQuotes(l_quote_csr, ICX_CAT_UTIL_PVT.g_online_const);

  l_err_loc := 600;
  CLOSE l_quote_csr;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openQuotesCursor;

-- l_quote_csr, ICX_CAT_UTIL_PVT.g_upgrade_const
PROCEDURE populateQuotes
(       p_podocs_csr            IN              ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN              VARCHAR2
)
IS
  l_api_name                            CONSTANT VARCHAR2(30)   := 'populateQuotes';
  l_err_loc                             PLS_INTEGER;
  l_start_po_line_id                    NUMBER;
  l_err_string                          VARCHAR2(4000);
  l_batch_count                         PLS_INTEGER;
  l_row_count                           PLS_INTEGER;
  l_count                               PLS_INTEGER;
  l_GBPA_line_status                    PLS_INTEGER;
  l_current_ctx_item_rec                ICX_CAT_POPULATE_ITEM_PVT.g_ctx_item_rec_type;

  ----- Start of declaring columns selected in the cursor -----
  l_inv_item_id_tbl                     DBMS_SQL.NUMBER_TABLE;
  l_po_line_id_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                          DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                        DBMS_SQL.VARCHAR2_TABLE;
  l_source_type_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  l_purchasing_org_id_tbl               DBMS_SQL.NUMBER_TABLE;
  l_po_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_supplier_id_tbl                     DBMS_SQL.NUMBER_TABLE;
  l_supplier_part_num_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_part_auxid_tbl             DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_site_id_tbl                DBMS_SQL.NUMBER_TABLE;
  l_status_tbl                          DBMS_SQL.VARCHAR2_TABLE;
  l_ip_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_ip_category_name_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_item_revision_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_po_header_id_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_document_number_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_line_num_tbl                        DBMS_SQL.NUMBER_TABLE;
  l_allow_prc_override_flag_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_not_to_exceed_price_tbl             DBMS_SQL.NUMBER_TABLE;
  l_line_type_id_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_unit_meas_lookup_code_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_unit_price_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_amount_tbl                          DBMS_SQL.NUMBER_TABLE;
  l_currency_code_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_rate_type_tbl                       DBMS_SQL.VARCHAR2_TABLE;
  l_rate_date_tbl                       DBMS_SQL.DATE_TABLE;
  l_rate_tbl                            DBMS_SQL.NUMBER_TABLE;
  l_buyer_id_tbl                        DBMS_SQL.NUMBER_TABLE;
  l_supplier_contact_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_order_type_lookup_code_tbl          DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_tbl                        DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_inventory_item_id_tbl           DBMS_SQL.NUMBER_TABLE;
  l_ctx_source_type_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_item_type_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_purchasing_org_id_tbl           DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_id_tbl                 DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_site_id_tbl            DBMS_SQL.NUMBER_TABLE;
  l_ctx_supplier_part_num_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_supplier_part_auxid_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_ip_category_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_ctx_po_category_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_ctx_item_revision_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_rowid_tbl                       DBMS_SQL.UROWID_TABLE;
  -- 17076597 changes starts
  l_ctx_un_number_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_un_number_tbl                       DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_hazard_class_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_hazard_class_tbl                    DBMS_SQL.VARCHAR2_TABLE;

  -- 17076597 changes ends
  ------ End of declaring columns selected in the cursor ------

BEGIN
  l_err_loc := 100;
  l_batch_count := 0;
  l_row_count := 0;
  l_count := 0;
  LOOP
    l_err_loc := 200;
    l_inv_item_id_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;
    l_source_type_tbl.DELETE;
    l_purchasing_org_id_tbl.DELETE;
    l_po_category_id_tbl.DELETE;
    l_supplier_id_tbl.DELETE;
    l_supplier_part_num_tbl.DELETE;
    l_supplier_part_auxid_tbl.DELETE;
    l_supplier_site_id_tbl.DELETE;
    l_status_tbl.DELETE;
    l_ip_category_id_tbl.DELETE;
    l_ip_category_name_tbl.DELETE;
    l_item_revision_tbl.DELETE;
    l_po_header_id_tbl.DELETE;
    l_document_number_tbl.DELETE;
    l_line_num_tbl.DELETE;
    l_allow_prc_override_flag_tbl.DELETE;
    l_not_to_exceed_price_tbl.DELETE;
    l_line_type_id_tbl.DELETE;
    l_unit_meas_lookup_code_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_amount_tbl.DELETE;
    l_currency_code_tbl.DELETE;
    l_rate_type_tbl.DELETE;
    l_rate_date_tbl.DELETE;
    l_rate_tbl.DELETE;
    l_buyer_id_tbl.DELETE;
    l_supplier_contact_id_tbl.DELETE;
    l_order_type_lookup_code_tbl.DELETE;
    l_supplier_tbl.DELETE;
    l_ctx_inventory_item_id_tbl.DELETE;
    l_ctx_source_type_tbl.DELETE;
    l_ctx_item_type_tbl.DELETE;
    l_ctx_purchasing_org_id_tbl.DELETE;
    l_ctx_supplier_id_tbl.DELETE;
    l_ctx_supplier_site_id_tbl.DELETE;
    l_ctx_supplier_part_num_tbl.DELETE;
    l_ctx_supplier_part_auxid_tbl.DELETE;
    l_ctx_ip_category_id_tbl.DELETE;
    l_ctx_po_category_id_tbl.DELETE;
    l_ctx_item_revision_tbl.DELETE;
    l_ctx_rowid_tbl.DELETE;
    -- 17076597 changes
    l_ctx_un_number_tbl.DELETE;
    l_un_number_tbl.DELETE;
    l_ctx_hazard_class_tbl.DELETE;
    l_hazard_class_tbl.DELETE;


    BEGIN
      l_err_loc := 300;
      FETCH p_podocs_csr BULK COLLECT INTO
          l_inv_item_id_tbl,
          l_po_line_id_tbl,
          l_org_id_tbl,
          l_language_tbl,
          l_source_type_tbl,
          l_purchasing_org_id_tbl,
          l_po_category_id_tbl,
          l_supplier_id_tbl,
          l_supplier_part_num_tbl,
          l_supplier_part_auxid_tbl,
          l_supplier_site_id_tbl,
          l_status_tbl,
          l_ip_category_id_tbl,
          l_ip_category_name_tbl,
          l_item_revision_tbl,
          l_po_header_id_tbl,
          l_document_number_tbl,
          l_line_num_tbl,
          l_allow_prc_override_flag_tbl,
          l_not_to_exceed_price_tbl,
          l_line_type_id_tbl,
          l_unit_meas_lookup_code_tbl,
          l_unit_price_tbl,
          l_amount_tbl,
          l_currency_code_tbl,
          l_rate_type_tbl,
          l_rate_date_tbl,
          l_rate_tbl,
          l_buyer_id_tbl,
          l_supplier_contact_id_tbl,
          l_order_type_lookup_code_tbl,
          l_supplier_tbl,
          l_un_number_tbl,
          l_hazard_class_tbl,
          l_ctx_inventory_item_id_tbl,
          l_ctx_source_type_tbl,
          l_ctx_item_type_tbl,
          l_ctx_purchasing_org_id_tbl,
          l_ctx_supplier_id_tbl,
          l_ctx_supplier_site_id_tbl,
          l_ctx_supplier_part_num_tbl,
          l_ctx_supplier_part_auxid_tbl,
          l_ctx_ip_category_id_tbl,
          l_ctx_po_category_id_tbl,
          l_ctx_item_revision_tbl,
          l_ctx_un_number_tbl,
          l_ctx_hazard_class_tbl,
          l_ctx_rowid_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size;
      l_err_loc := 400;

      EXIT WHEN l_po_line_id_tbl.COUNT = 0;

      l_err_loc := 500;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 600;
      l_count := l_po_line_id_tbl.COUNT;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows returned from the cursor:' || l_count);
      END IF;

      --Save the last po_line_id processed, so that re-open of cursor will start from the saved id.
      l_start_po_line_id := l_po_line_id_tbl(l_count);

      l_row_count := l_row_count + l_count;

      FOR i in 1..l_po_line_id_tbl.COUNT LOOP
        l_err_loc := 700;
        IF (l_ctx_rowid_tbl(i) IS NOT NULL OR
            l_status_tbl(i) = ICX_CAT_POPULATE_STATUS_PVT.VALID_FOR_POPULATE)
        THEN
          l_err_loc := 800;
          l_current_ctx_item_rec.inventory_item_id              := l_inv_item_id_tbl(i);
          l_current_ctx_item_rec.po_line_id                     := l_po_line_id_tbl(i);
          l_current_ctx_item_rec.req_template_name              := TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          l_current_ctx_item_rec.req_template_line_num          := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          l_current_ctx_item_rec.org_id                         := l_org_id_tbl(i);
          l_current_ctx_item_rec.language                       := l_language_tbl(i);
          l_current_ctx_item_rec.source_type                    := l_source_type_tbl(i);
          l_current_ctx_item_rec.item_type                      := ICX_CAT_UTIL_PVT.g_purchase_item_type;
          l_current_ctx_item_rec.purchasing_org_id              := l_purchasing_org_id_tbl(i);
          l_current_ctx_item_rec.owning_org_id                  := l_org_id_tbl(i);
          l_current_ctx_item_rec.po_category_id                 := l_po_category_id_tbl(i);
          l_current_ctx_item_rec.supplier_id                    := l_supplier_id_tbl(i);
          l_current_ctx_item_rec.supplier_part_num              := l_supplier_part_num_tbl(i);
          l_current_ctx_item_rec.supplier_part_auxid            := l_supplier_part_auxid_tbl(i);
          l_current_ctx_item_rec.supplier_site_id               := l_supplier_site_id_tbl(i);
          l_current_ctx_item_rec.status                         := l_status_tbl(i);
          l_current_ctx_item_rec.ip_category_id                 := l_ip_category_id_tbl(i);
          l_current_ctx_item_rec.ip_category_name               := l_ip_category_name_tbl(i);
          l_current_ctx_item_rec.req_template_po_line_id        := NULL;
          l_current_ctx_item_rec.item_revision                  := l_item_revision_tbl(i);
          l_current_ctx_item_rec.po_header_id                   := l_po_header_id_tbl(i);
          l_current_ctx_item_rec.document_number                := l_document_number_tbl(i);
          l_current_ctx_item_rec.line_num                       := l_line_num_tbl(i);
          l_current_ctx_item_rec.allow_price_override_flag      := l_allow_prc_override_flag_tbl(i);
          l_current_ctx_item_rec.not_to_exceed_price            := l_not_to_exceed_price_tbl(i);
          l_current_ctx_item_rec.line_type_id                   := l_line_type_id_tbl(i);
          l_current_ctx_item_rec.unit_meas_lookup_code          := l_unit_meas_lookup_code_tbl(i);
          l_current_ctx_item_rec.suggested_quantity             := NULL;
          l_current_ctx_item_rec.unit_price                     := l_unit_price_tbl(i);
          l_current_ctx_item_rec.amount                         := l_amount_tbl(i);
          l_current_ctx_item_rec.currency_code                  := l_currency_code_tbl(i);
          l_current_ctx_item_rec.rate_type                      := l_rate_type_tbl(i);
          l_current_ctx_item_rec.rate_date                      := l_rate_date_tbl(i);
          l_current_ctx_item_rec.rate                           := l_rate_tbl(i);
          l_current_ctx_item_rec.buyer_id                       := l_buyer_id_tbl(i);
          l_current_ctx_item_rec.supplier_contact_id            := l_supplier_contact_id_tbl(i);
          l_current_ctx_item_rec.rfq_required_flag              := 'N';
          l_current_ctx_item_rec.negotiated_by_preparer_flag    := 'Y';
          l_current_ctx_item_rec.description                    := NULL;
          l_current_ctx_item_rec.order_type_lookup_code         := l_order_type_lookup_code_tbl(i);
          l_current_ctx_item_rec.supplier                       := l_supplier_tbl(i);
          l_current_ctx_item_rec.global_agreement_flag          := 'N';
          l_current_ctx_item_rec.merged_source_type             := 'SRC_DOC';
          l_current_ctx_item_rec.ctx_inventory_item_id          := l_ctx_inventory_item_id_tbl(i);
          l_current_ctx_item_rec.ctx_source_type                := l_ctx_source_type_tbl(i);
          l_current_ctx_item_rec.ctx_item_type                  := l_ctx_item_type_tbl(i);
          l_current_ctx_item_rec.ctx_purchasing_org_id          := l_ctx_purchasing_org_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_id                := l_ctx_supplier_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_site_id           := l_ctx_supplier_site_id_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_part_num          := l_ctx_supplier_part_num_tbl(i);
          l_current_ctx_item_rec.ctx_supplier_part_auxid        := l_ctx_supplier_part_auxid_tbl(i);
          l_current_ctx_item_rec.ctx_ip_category_id             := l_ctx_ip_category_id_tbl(i);
          l_current_ctx_item_rec.ctx_po_category_id             := l_ctx_po_category_id_tbl(i);
          l_current_ctx_item_rec.ctx_item_revision              := l_ctx_item_revision_tbl(i);
          l_current_ctx_item_rec.ctx_rowid                      := l_ctx_rowid_tbl(i);
          -- 17076597 changes
          l_current_ctx_item_rec.ctx_un_number                  := l_ctx_un_number_tbl(i);
          l_current_ctx_item_rec.un_number                      := l_un_number_tbl(i);
          l_current_ctx_item_rec.ctx_hazard_class               := l_ctx_hazard_class_tbl(i);
          l_current_ctx_item_rec.hazard_class                   := l_hazard_class_tbl(i);

          l_err_loc := 900;
          ICX_CAT_POPULATE_ITEM_PVT.processCurrentCtxItemRow(l_current_ctx_item_rec, null, p_current_mode);

          l_err_loc := 1000;
          ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('INLOOP', ICX_CAT_UTIL_PVT.g_QuoteCsr_const);
        ELSE
          l_err_loc := 1100;
          IF (p_current_mode = ICX_CAT_UTIL_PVT.g_upgrade_const) THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', with po_line_id:' || l_po_line_id_tbl(i) ||', not processed' ||
                  ', status: ' || l_status_tbl(i));
            END IF;
          ELSE
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', with po_line_id:' || l_po_line_id_tbl(i) ||', not processed' ||
                  ', status: ' || l_status_tbl(i));
            END IF;
          END IF;
        END IF;
      END LOOP;  --FOR LOOP of l_po_line_id_tbl

      l_err_loc := 1200;
      EXIT WHEN l_po_line_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := 'ICX_CAT_POPULATE_PODOCS_PVT.populateQuotes' ||l_err_loc
                        ||', Total processed batches:' ||l_batch_count
                        ||', Cursor will be reopened with po_line_id:' ||l_start_po_line_id;
        IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
          ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
          --Closing and reopen of cursor will be done by called procedures
          openQuotesCursor(g_key, l_start_po_line_id);
        ELSE
          RAISE;
        END IF;
    END;
  END LOOP; --Cursor loop

  l_err_loc := 1500;
  ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('OUTLOOP', ICX_CAT_UTIL_PVT.g_QuoteCsr_const);

  l_err_loc := 1600;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'populateQuotes in mode:'|| p_current_mode ||' done; '||
        'Total num. of batches processed:' ||l_batch_count ||
        ', Total num. of rows processed:' ||l_row_count);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateQuotes;

PROCEDURE populateOnlineQuotes
(       p_key                   IN              NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'populateOnlineQuotes';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  -- Set the batch_size
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 200;
  -- Set the who columns
  ICX_CAT_UTIL_PVT.setWhoColumns(null);

  l_err_loc := 300;
  g_key := p_key;

  l_err_loc := 350;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logPOSessionGTData(p_key);
  END IF;

  l_err_loc := 400;
  openQuotesCursor(p_key, 0);

  l_err_loc := 500;
  g_metadataTblFormed := FALSE;
  g_CtxSqlForPODocsFormed := FALSE;

  l_err_loc := 600;
  ICX_CAT_POPULATE_CTXSTRING_PVT.populateCtxCatgAtt(ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id);

  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateOnlineQuotes;

----------------------------------------------------------------------
--------------  End of Quotation specific Code -----------------------
----------------------------------------------------------------------

PROCEDURE buildCtxSqlForPODocs
(       p_special_ctx_sql_tbl   IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type    ,
        p_regular_ctx_sql_tbl   IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type
)
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'buildCtxSqlForPODocs';
  l_err_loc                     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (NOT ICX_CAT_POPULATE_PODOCS_PVT.g_metadataTblFormed) THEN
    l_err_loc := 200;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'about to call buildmetadatinfo');
    END IF;

    l_err_loc := 200;
    ICX_CAT_BUILD_CTX_SQL_PVT.buildMetadataInfo
           (0, g_special_metadata_tbl, g_regular_nontl_metadata_tbl, g_regular_tl_metadata_tbl);

    l_err_loc := 300;
    ICX_CAT_POPULATE_PODOCS_PVT.g_metadataTblFormed := TRUE;
  END IF;

  l_err_loc := 400;
  IF (NOT ICX_CAT_POPULATE_PODOCS_PVT.g_CtxSqlForPODocsFormed) THEN
    l_err_loc := 500;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'about to call buildctxsql');
    END IF;

    l_err_loc := 600;
    ICX_CAT_BUILD_CTX_SQL_PVT.buildCtxSql
           (0, ICX_CAT_UTIL_PVT.g_PODoc_const, 'NOTROWID', g_special_metadata_tbl,
            g_regular_nontl_metadata_tbl, g_regular_tl_metadata_tbl,
            g_all_ctx_sql_tbl, g_special_ctx_sql_tbl, g_regular_ctx_sql_tbl);
    ICX_CAT_POPULATE_PODOCS_PVT.g_CtxSqlForPODocsFormed := TRUE;
  END IF;

  l_err_loc := 700;
  p_special_ctx_sql_tbl := g_special_ctx_sql_tbl;
  p_regular_ctx_sql_tbl := g_regular_ctx_sql_tbl;

  l_err_loc := 800;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END buildCtxSqlForPODocs;


END ICX_CAT_POPULATE_PODOCS_PVT;

/
