--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_REQTMPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_REQTMPL_PVT" AS
/* $Header: ICXVPPRB.pls 120.10.12010000.6 2014/06/06 02:33:55 beyi ship $*/

-- Constants
G_PKG_NAME                      CONSTANT VARCHAR2(30) :='ICX_CAT_POPULATE_REQTMPL_PVT';
g_upgrade_last_run_date         DATE;
g_key                           NUMBER;
g_start_rowid                   ROWID;
g_end_rowid                     ROWID;

PROCEDURE openR12UpgradeReqTmpltsCursor
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openR12UpgradeReqTmpltsCursor';
  l_err_loc             PLS_INTEGER;
  l_reqTemplate_csr     ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
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
  IF (l_reqTemplate_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_reqTemplate_csr;
  END IF;

  --options: 1. Do a not exists (only work the first time and not during delta)
  --2. (Have a internal_request_id check in ctx_hdrs) Will work for both first time and delta.  Current extractor process.
  --Changes would be to add the internal_request_id clause only after seeing the snaphot too old error.

  l_err_loc := 300;
  -- 17076597 changes added un_number and hazard_class
  -- 18660604 Add condition 'AND prl.org_id = msi.organization_id'
  IF (g_upgrade_last_run_date) IS NULL THEN
    l_err_loc := 400;
    OPEN l_reqTemplate_csr FOR
      SELECT /*+ LEADING(doc) use_nl(ctx) */
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
           SELECT /*+ ROWID(prl) use_nl(prh,ph,pl,po_tlp,ic) */
                  NVL(prl.item_id, -2) inventory_item_id,
                  prl.express_name req_template_name,
                  prl.sequence_num req_template_line_num,
                  NVL(prl.org_id, -2) org_id,
    	          po_tlp.language language,
                  DECODE(prl.source_type_code, 'VENDOR', 'TEMPLATE', 'INTERNAL_TEMPLATE') source_type,
                  DECODE(prl.source_type_code, 'VENDOR', 'PURCHASE', 'INTERNAL') item_type,
                  NVL(prl.org_id, -2) purchasing_org_id,
                  prl.category_id po_category_id,
                  NVL(prl.suggested_vendor_id, -2) supplier_id,
                  NVL(prl.suggested_vendor_product_code, '##NULL##') supplier_part_num,
                  NVL(prl.suggested_vendor_site_id, -2) supplier_site_id,
       	          prl.ip_category_id,
                  ic.category_name ip_category_name,
                  -- For template line status
                  prh.inactive_date,
                  --For blanket line status
                  prl.po_line_id,
                  prl.po_line_id req_template_po_line_id,
                  NVL(prl.item_revision, '-2'),
                  prl.po_header_id,
                  ph.segment1 document_number,
                  pl.line_num,
                  prl.line_type_id,
                  prl.unit_meas_lookup_code,
                  prl.suggested_quantity,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', prl.unit_price, 'AMOUNT', prl.unit_price, to_number(null)) unit_price,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), prl.amount) amount,
                  ph.currency_code,
                  ph.rate_type,
                  ph.rate_date,
                  ph.rate rate,
                  prl.suggested_buyer_id buyer_id,
                  prl.suggested_vendor_contact_id supplier_contact_id,
                  prl.rfq_required_flag,
                  NVL(prl.negotiated_by_preparer_flag, 'N') negotiated_by_preparer_flag,
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
                  NVL(TRUNC(pl.expiration_date), TRUNC(SYSDATE+1)) expiration_date,
                  TRUNC(SYSDATE) system_date,
                  pun.un_number,
                  phc.hazard_class
           FROM po_reqexpress_headers_all prh,
                po_reqexpress_lines_all prl,
                po_headers_all ph,
                po_lines_all pl,
                po_attribute_values_tlp po_tlp,
                po_line_types_b pltb,
                icx_cat_categories_tl ic,
		po_vendors pv,
                mtl_system_items_b msi,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE prl.express_name = prh.express_name
           AND prl.org_id = prh.org_id
           AND prl.po_line_id = pl.po_line_id (+)
           AND prl.po_header_id = pl.po_header_id (+)
           AND prl.po_header_id = ph.po_header_id (+)
           AND -2 = po_tlp.po_line_id
           AND prl.express_name = po_tlp.req_template_name
           AND prl.sequence_num = po_tlp.req_template_line_num
           AND prl.org_id = po_tlp.org_id
           AND prl.line_type_id = pltb.line_type_id
           AND NVL(pltb.purchase_basis, 'NULL') <> 'TEMP LABOR'
           AND po_tlp.ip_category_id = ic.rt_category_id (+)
           AND po_tlp.language = ic.language (+)
           AND prl.suggested_vendor_id = pv.vendor_id(+)
           AND prl.ITEM_ID = msi.INVENTORY_ITEM_ID(+)
           AND prl.org_id = msi.organization_id(+)
           AND msi.UN_NUMBER_ID = pun.UN_NUMBER_ID (+)
           AND msi.HAZARD_CLASS_ID = phc.HAZARD_CLASS_ID (+)
           AND prl.rowid BETWEEN g_start_rowid and g_end_rowid
           ) doc,
           icx_cat_items_ctx_hdrs_tlp ctx
      WHERE -2 = ctx.po_line_id (+)
      AND doc.inventory_item_id=ctx.inventory_item_id(+)
      AND doc.req_template_name = ctx.req_template_name (+)
      AND doc.req_template_line_num = ctx.req_template_line_num (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.language = ctx.language (+);
  ELSE
    l_err_loc := 500;
    -- 17076597 changes added un_number and hazard_class
    OPEN l_reqTemplate_csr FOR
      SELECT /*+ LEADING(doc) use_nl(ctx) */
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
           SELECT /*+ ROWID(prl) use_nl(prh,ph,pl,po_tlp,ic) */
                  NVL(prl.item_id, -2) inventory_item_id,
                  prl.express_name req_template_name,
                  prl.sequence_num req_template_line_num,
                  NVL(prl.org_id, -2) org_id,
    	          po_tlp.language language,
                  DECODE(prl.source_type_code, 'VENDOR', 'TEMPLATE', 'INTERNAL_TEMPLATE') source_type,
                  DECODE(prl.source_type_code, 'VENDOR', 'PURCHASE', 'INTERNAL') item_type,
                  NVL(prl.org_id, -2) purchasing_org_id,
                  prl.category_id po_category_id,
                  NVL(prl.suggested_vendor_id, -2) supplier_id,
                  NVL(prl.suggested_vendor_product_code, '##NULL##') supplier_part_num,
                  NVL(prl.suggested_vendor_site_id, -2) supplier_site_id,
       	          prl.ip_category_id,
                  ic.category_name ip_category_name,
                  -- For template line status
                  prh.inactive_date,
                  --For blanket line status
                  prl.po_line_id,
                  prl.po_line_id req_template_po_line_id,
                  NVL(prl.item_revision, '-2'),
                  prl.po_header_id,
                  ph.segment1 document_number,
                  pl.line_num,
                  prl.line_type_id,
                  prl.unit_meas_lookup_code,
                  prl.suggested_quantity,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', prl.unit_price, 'AMOUNT', prl.unit_price, to_number(null)) unit_price,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), prl.amount) amount,
                  ph.currency_code,
                  ph.rate_type,
                  ph.rate_date,
                  ph.rate rate,
                  prl.suggested_buyer_id buyer_id,
                  prl.suggested_vendor_contact_id supplier_contact_id,
                  prl.rfq_required_flag,
                  NVL(prl.negotiated_by_preparer_flag, 'N') negotiated_by_preparer_flag,
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
                  NVL(TRUNC(pl.expiration_date), TRUNC(SYSDATE+1)) expiration_date,
                  TRUNC(SYSDATE) system_date,
                  pun.un_number,
                  phc.hazard_class
           FROM po_reqexpress_headers_all prh,
                po_reqexpress_lines_all prl,
                po_headers_all ph,
                po_lines_all pl,
                po_attribute_values_tlp po_tlp,
                po_line_types_b pltb,
                icx_cat_categories_tl ic,
                po_vendors pv,
                mtl_system_items_b msi,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE prl.express_name = prh.express_name
           AND prl.org_id = prh.org_id
           AND prl.po_line_id = pl.po_line_id (+)
           AND prl.po_header_id = pl.po_header_id (+)
           AND prl.po_header_id = ph.po_header_id (+)
           AND -2 = po_tlp.po_line_id
           AND prl.express_name = po_tlp.req_template_name
           AND prl.sequence_num = po_tlp.req_template_line_num
           AND prl.org_id = po_tlp.org_id
           AND prl.line_type_id = pltb.line_type_id
           AND NVL(pltb.purchase_basis, 'NULL') <> 'TEMP LABOR'
           AND po_tlp.ip_category_id = ic.rt_category_id (+)
           AND po_tlp.language = ic.language (+)
           AND prl.suggested_vendor_id = pv.vendor_id(+)
            AND prl.ITEM_ID = msi.INVENTORY_ITEM_ID(+)
            AND prl.org_id = msi.organization_id(+)
            AND msi.UN_NUMBER_ID = pun.UN_NUMBER_ID (+)
            AND msi.HAZARD_CLASS_ID = phc.HAZARD_CLASS_ID (+)
           AND prl.rowid BETWEEN g_start_rowid and g_end_rowid
           AND (ph.last_update_date > g_upgrade_last_run_date
                OR pl.last_update_date > g_upgrade_last_run_date
                OR prh.last_update_date > g_upgrade_last_run_date
                OR prl.last_update_date > g_upgrade_last_run_date
                OR po_tlp.last_update_date > g_upgrade_last_run_date)
           ) doc,
           icx_cat_items_ctx_hdrs_tlp ctx
      WHERE -2 = ctx.po_line_id (+)
      AND doc.inventory_item_id=ctx.inventory_item_id(+)
      AND doc.req_template_name = ctx.req_template_name (+)
      AND doc.req_template_line_num = ctx.req_template_line_num (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.language = ctx.language (+);
  END IF;

  l_err_loc := 700;
  populateReqTemplates(l_reqTemplate_csr, ICX_CAT_UTIL_PVT.g_upgrade_const);

  l_err_loc := 800;
  CLOSE l_reqTemplate_csr;

  l_err_loc := 900;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openR12UpgradeReqTmpltsCursor;

PROCEDURE openReqTmpltsCursor
(       p_key           IN      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openReqTmpltsCursor';
  l_err_loc             PLS_INTEGER;
  l_reqTemplate_csr     ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Processing cursor:' || l_api_name ||
        ', p_key:' || p_key );
  END IF;

  l_err_loc := 150;
  --First close the cursor
  IF (l_reqTemplate_csr%ISOPEN) THEN
    l_err_loc := 200;
    CLOSE l_reqTemplate_csr;
  END IF;

  l_err_loc := 300;
  -- 17076597 changes added un_number and hazard_class
  -- 18660604 Add condition 'AND prl.org_id = msi.organization_id'
  OPEN l_reqTemplate_csr FOR
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
           SELECT NVL(prl.item_id, -2) inventory_item_id,
                  prl.express_name req_template_name,
                  prl.sequence_num req_template_line_num,
                  NVL(prl.org_id, -2) org_id,
    	          po_tlp.language language,
                  DECODE(prl.source_type_code, 'VENDOR', 'TEMPLATE', 'INTERNAL_TEMPLATE') source_type,
                  DECODE(prl.source_type_code, 'VENDOR', 'PURCHASE', 'INTERNAL') item_type,
                  NVL(prl.org_id, -2) purchasing_org_id,
                  prl.category_id po_category_id,
                  NVL(prl.suggested_vendor_id, -2) supplier_id,
                  NVL(prl.suggested_vendor_product_code, '##NULL##') supplier_part_num,
                  NVL(prl.suggested_vendor_site_id, -2) supplier_site_id,
       	          prl.ip_category_id,
                  ic.category_name ip_category_name,
                  prh.inactive_date,
                  prl.po_line_id,
                  prl.po_line_id req_template_po_line_id,
                  NVL(prl.item_revision, '-2'),
                  prl.po_header_id,
                  ph.segment1 document_number,
                  pl.line_num,
                  prl.line_type_id,
                  prl.unit_meas_lookup_code,
                  prl.suggested_quantity,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', prl.unit_price, 'AMOUNT', prl.unit_price, to_number(null)) unit_price,
                  DECODE(pltb.order_type_lookup_code, 'QUANTITY', to_number(null), prl.amount) amount,
                  ph.currency_code,
                  ph.rate_type,
                  ph.rate_date,
                  ph.rate rate,
                  prl.suggested_buyer_id buyer_id,
                  prl.suggested_vendor_contact_id supplier_contact_id,
                  prl.rfq_required_flag,
                  NVL(prl.negotiated_by_preparer_flag, 'N') negotiated_by_preparer_flag,
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
                  NVL(TRUNC(pl.expiration_date), TRUNC(SYSDATE+1)) expiration_date,
                  TRUNC(SYSDATE) system_date,
                  pun.un_number,
                  phc.hazard_class
           FROM po_reqexpress_headers_all prh,
                po_reqexpress_lines_all prl,
                po_session_gt pogt,
                po_headers_all ph,
                po_lines_all pl,
                po_attribute_values_tlp po_tlp,
                po_line_types_b pltb,
                icx_cat_categories_tl ic,
                po_vendors pv,
                mtl_system_items_b msi,
                po_un_numbers pun,
                po_hazard_classes phc
           WHERE prl.express_name = prh.express_name
           AND prl.org_id = prh.org_id
           AND pogt.key = p_key
           AND prl.express_name = pogt.index_char1
           AND prl.sequence_num = pogt.index_num1
           AND prl.org_id = pogt.index_num2
           AND prl.po_line_id = pl.po_line_id (+)
           AND prl.po_header_id = pl.po_header_id (+)
           AND prl.po_header_id = ph.po_header_id (+)
           AND prl.express_name = po_tlp.req_template_name
           AND prl.sequence_num = po_tlp.req_template_line_num
           AND prl.org_id = po_tlp.org_id
           AND prl.line_type_id = pltb.line_type_id
           AND NVL(pltb.purchase_basis, 'NULL') <> 'TEMP LABOR'
           AND po_tlp.ip_category_id = ic.rt_category_id (+)
           AND po_tlp.language = ic.language (+)
           AND prl.suggested_vendor_id = pv.vendor_id(+)
           AND prl.ITEM_ID = msi.INVENTORY_ITEM_ID(+)
           AND prl.org_id = msi.organization_id(+)
          AND msi.UN_NUMBER_ID = pun.UN_NUMBER_ID (+)
          AND msi.HAZARD_CLASS_ID = phc.HAZARD_CLASS_ID (+)
           ) doc,
           icx_cat_items_ctx_hdrs_tlp ctx
      WHERE -2 = ctx.po_line_id (+)
      AND doc.inventory_item_id=ctx.inventory_item_id(+)
      AND doc.req_template_name = ctx.req_template_name (+)
      AND doc.req_template_line_num = ctx.req_template_line_num (+)
      AND doc.source_type = ctx.source_type (+)
      AND doc.org_id = ctx.org_id (+)
      AND doc.language = ctx.language (+);

  l_err_loc := 500;
  populateReqTemplates(l_reqTemplate_csr, ICX_CAT_UTIL_PVT.g_online_const);

  l_err_loc := 600;
  CLOSE l_reqTemplate_csr;

  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openReqTmpltsCursor;

-- l_reqTemplate_csr, ICX_CAT_UTIL_PVT.g_upgrade_const
PROCEDURE populateReqTemplates
(       p_reqTemplate_csr       IN              ICX_CAT_POPULATE_ITEM_PVT.g_item_csr_type       ,
        p_current_mode          IN              VARCHAR2
)
IS

  l_api_name                            CONSTANT VARCHAR2(30)   := 'populateReqTemplates';
  l_err_loc                             PLS_INTEGER;
  l_err_string                          VARCHAR2(4000);
  l_batch_count                         PLS_INTEGER;
  l_row_count                           PLS_INTEGER;
  l_count                               PLS_INTEGER;
  l_BPA_line_status_rec                 ICX_CAT_POPULATE_STATUS_PVT.g_BPA_line_status_rec_type;
  l_ReqTmplt_line_status                PLS_INTEGER;
  l_current_ctx_item_rec                ICX_CAT_POPULATE_ITEM_PVT.g_ctx_item_rec_type;

  ----- Start of declaring columns selected in the cursor -----
  l_inv_item_id_tbl                     DBMS_SQL.NUMBER_TABLE;
  l_req_template_name_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_req_template_line_num_tbl           DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                          DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                        DBMS_SQL.VARCHAR2_TABLE;
  l_source_type_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  l_item_type_tbl                       DBMS_SQL.VARCHAR2_TABLE;
  l_purchasing_org_id_tbl               DBMS_SQL.NUMBER_TABLE;
  l_po_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_supplier_id_tbl                     DBMS_SQL.NUMBER_TABLE;
  l_supplier_part_num_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_supplier_site_id_tbl                DBMS_SQL.NUMBER_TABLE;
  l_ip_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_ip_category_name_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_inactive_date_tbl                   DBMS_SQL.DATE_TABLE;
  l_po_line_id_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_req_template_po_line_id_tbl         DBMS_SQL.NUMBER_TABLE;
  l_item_revision_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_po_header_id_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_document_number_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_line_num_tbl                        DBMS_SQL.NUMBER_TABLE;
  l_line_type_id_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_unit_meas_lookup_code_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_suggested_quantity_tbl              DBMS_SQL.NUMBER_TABLE;
  l_unit_price_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_amount_tbl                          DBMS_SQL.NUMBER_TABLE;
  l_currency_code_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_rate_type_tbl                       DBMS_SQL.VARCHAR2_TABLE;
  l_rate_date_tbl                       DBMS_SQL.DATE_TABLE;
  l_rate_tbl                            DBMS_SQL.NUMBER_TABLE;
  l_buyer_id_tbl                        DBMS_SQL.NUMBER_TABLE;
  l_supplier_contact_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_rfq_required_flag_tbl               DBMS_SQL.VARCHAR2_TABLE;
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
  l_ctx_un_number_tbl              DBMS_SQL.VARCHAR2_TABLE;
  l_un_number_tbl                  DBMS_SQL.VARCHAR2_TABLE;
  l_ctx_hazard_class_tbl              DBMS_SQL.VARCHAR2_TABLE;
  l_hazard_class_tbl                  DBMS_SQL.VARCHAR2_TABLE;
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
    l_req_template_name_tbl.DELETE;
    l_req_template_line_num_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_language_tbl.DELETE;
    l_source_type_tbl.DELETE;
    l_item_type_tbl.DELETE;
    l_purchasing_org_id_tbl.DELETE;
    l_po_category_id_tbl.DELETE;
    l_supplier_id_tbl.DELETE;
    l_supplier_part_num_tbl.DELETE;
    l_supplier_site_id_tbl.DELETE;
    l_ip_category_id_tbl.DELETE;
    l_ip_category_name_tbl.DELETE;
    l_inactive_date_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_req_template_po_line_id_tbl.DELETE;
    l_item_revision_tbl.DELETE;
    l_po_header_id_tbl.DELETE;
    l_document_number_tbl.DELETE;
    l_line_num_tbl.DELETE;
    l_line_type_id_tbl.DELETE;
    l_unit_meas_lookup_code_tbl.DELETE;
    l_suggested_quantity_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_amount_tbl.DELETE;
    l_currency_code_tbl.DELETE;
    l_rate_type_tbl.DELETE;
    l_rate_date_tbl.DELETE;
    l_rate_tbl.DELETE;
    l_buyer_id_tbl.DELETE;
    l_supplier_contact_id_tbl.DELETE;
    l_rfq_required_flag_tbl.DELETE;
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

    -- 17076597 changes starts
    l_ctx_un_number_tbl.DELETE;
    l_un_number_tbl.DELETE;
    l_ctx_hazard_class_tbl.DELETE;
    l_hazard_class_tbl.DELETE;

    -- 17076597 changes ends
    BEGIN
      l_err_loc := 300;
      FETCH p_reqTemplate_csr BULK COLLECT INTO
          l_inv_item_id_tbl,
          l_req_template_name_tbl,
          l_req_template_line_num_tbl,
          l_org_id_tbl,
          l_language_tbl,
          l_source_type_tbl,
          l_item_type_tbl,
          l_purchasing_org_id_tbl,
          l_po_category_id_tbl,
          l_supplier_id_tbl,
          l_supplier_part_num_tbl,
          l_supplier_site_id_tbl,
          l_ip_category_id_tbl,
          l_ip_category_name_tbl,
          l_inactive_date_tbl,
          l_po_line_id_tbl,
          l_req_template_po_line_id_tbl,
          l_item_revision_tbl,
          l_po_header_id_tbl,
          l_document_number_tbl,
          l_line_num_tbl,
          l_line_type_id_tbl,
          l_unit_meas_lookup_code_tbl,
          l_suggested_quantity_tbl,
          l_unit_price_tbl,
          l_amount_tbl,
          l_currency_code_tbl,
          l_rate_type_tbl,
          l_rate_date_tbl,
          l_rate_tbl,
          l_buyer_id_tbl,
          l_supplier_contact_id_tbl,
          l_rfq_required_flag_tbl,
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
      EXIT WHEN l_inv_item_id_tbl.COUNT = 0;

      l_err_loc := 500;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 600;
      l_count := l_inv_item_id_tbl.COUNT;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Num. of rows returned from the cursor:' || l_count);
      END IF;
      l_row_count := l_row_count + l_count;

      l_err_loc := 700;
      FOR i in 1..l_inv_item_id_tbl.COUNT LOOP
        l_err_loc := 800;
        --First get the status of the current BPA line
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
        l_ReqTmplt_line_status := ICX_CAT_POPULATE_STATUS_PVT.getTemplateLineStatus
                     (l_inactive_date_tbl(i), l_po_line_id_tbl(i), l_BPA_line_status_rec);

        l_err_loc := 1000;
        IF (l_ctx_rowid_tbl(i) IS NOT NULL OR
            l_ReqTmplt_line_status = ICX_CAT_POPULATE_STATUS_PVT.VALID_FOR_POPULATE)
        THEN
          l_err_loc := 1100;
          l_current_ctx_item_rec.inventory_item_id              := l_inv_item_id_tbl(i);
          l_current_ctx_item_rec.po_line_id                     := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          l_current_ctx_item_rec.req_template_name              := l_req_template_name_tbl(i);
          l_current_ctx_item_rec.req_template_line_num          := l_req_template_line_num_tbl(i);
          l_current_ctx_item_rec.org_id                         := l_org_id_tbl(i);
          l_current_ctx_item_rec.language                       := l_language_tbl(i);
          l_current_ctx_item_rec.source_type                    := l_source_type_tbl(i);
          l_current_ctx_item_rec.item_type                      := l_item_type_tbl(i);
          l_current_ctx_item_rec.purchasing_org_id              := l_purchasing_org_id_tbl(i);
          l_current_ctx_item_rec.owning_org_id                  := l_org_id_tbl(i);
          l_current_ctx_item_rec.po_category_id                 := l_po_category_id_tbl(i);
          l_current_ctx_item_rec.supplier_id                    := l_supplier_id_tbl(i);
          l_current_ctx_item_rec.supplier_part_num              := l_supplier_part_num_tbl(i);
          l_current_ctx_item_rec.supplier_part_auxid            := '##NULL##';
          l_current_ctx_item_rec.supplier_site_id               := l_supplier_site_id_tbl(i);
          l_current_ctx_item_rec.status                         := l_ReqTmplt_line_status;
          l_current_ctx_item_rec.ip_category_id                 := l_ip_category_id_tbl(i);
          l_current_ctx_item_rec.ip_category_name               := l_ip_category_name_tbl(i);
          l_current_ctx_item_rec.req_template_po_line_id        := l_req_template_po_line_id_tbl(i);
          l_current_ctx_item_rec.item_revision                  := l_item_revision_tbl(i);
          l_current_ctx_item_rec.po_header_id                   := l_po_header_id_tbl(i);
          l_current_ctx_item_rec.document_number                := l_document_number_tbl(i);
          l_current_ctx_item_rec.line_num                       := l_line_num_tbl(i);
          l_current_ctx_item_rec.allow_price_override_flag      := 'N';
          l_current_ctx_item_rec.not_to_exceed_price            := NULL;
          l_current_ctx_item_rec.line_type_id                   := l_line_type_id_tbl(i);
          l_current_ctx_item_rec.unit_meas_lookup_code          := l_unit_meas_lookup_code_tbl(i);
          l_current_ctx_item_rec.suggested_quantity             := l_suggested_quantity_tbl(i);
          l_current_ctx_item_rec.unit_price                     := l_unit_price_tbl(i);
          l_current_ctx_item_rec.amount                         := l_amount_tbl(i);
          l_current_ctx_item_rec.currency_code                  := l_currency_code_tbl(i);
          l_current_ctx_item_rec.rate_type                      := l_rate_type_tbl(i);
          l_current_ctx_item_rec.rate_date                      := l_rate_date_tbl(i);
          l_current_ctx_item_rec.rate                           := l_rate_tbl(i);
          l_current_ctx_item_rec.buyer_id                       := l_buyer_id_tbl(i);
          l_current_ctx_item_rec.supplier_contact_id            := l_supplier_contact_id_tbl(i);
          l_current_ctx_item_rec.rfq_required_flag              := l_rfq_required_flag_tbl(i);
          l_current_ctx_item_rec.negotiated_by_preparer_flag    := l_negotiated_preparer_flag_tbl(i);
          l_current_ctx_item_rec.description                    := NULL;
          l_current_ctx_item_rec.order_type_lookup_code         := l_order_type_lookup_code_tbl(i);
          l_current_ctx_item_rec.supplier                       := l_supplier_tbl(i);
          l_current_ctx_item_rec.global_agreement_flag          := l_global_agreement_flag_tbl(i);
          l_current_ctx_item_rec.merged_source_type             := 'REQ_TEMPLATE';
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
          l_current_ctx_item_rec.ctx_un_number                 := l_ctx_un_number_tbl(i);
          l_current_ctx_item_rec.un_number                 := l_un_number_tbl(i);
          l_current_ctx_item_rec.ctx_hazard_class                 := l_ctx_hazard_class_tbl(i);
          l_current_ctx_item_rec.hazard_class                 := l_hazard_class_tbl(i);

          l_err_loc := 1200;
          ICX_CAT_POPULATE_ITEM_PVT.processCurrentCtxItemRow(l_current_ctx_item_rec, null, p_current_mode);

          l_err_loc := 1300;
          ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('INLOOP', ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const);
        ELSE
          IF (p_current_mode = ICX_CAT_UTIL_PVT.g_upgrade_const) THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', with req_template_line:(' || l_req_template_name_tbl(i) ||
                  ', ' || l_req_template_line_num_tbl(i) ||
                  ', ' || l_org_id_tbl(i) ||'), not processed' ||
                  ', l_inactive_date_tbl:' || l_inactive_date_tbl(i) ||
                  ', l_po_line_id_tbl:' || l_po_line_id_tbl(i) ||
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
                  ', status: ' || l_ReqTmplt_line_status);
            END IF;
          ELSE
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'Row #:' || i ||
                  ', with req_template_line:(' || l_req_template_name_tbl(i) ||
                  ', ' || l_req_template_line_num_tbl(i) ||
                  ', ' || l_org_id_tbl(i) ||'), not processed' ||
                  ', l_inactive_date_tbl:' || l_inactive_date_tbl(i) ||
                  ', l_po_line_id_tbl:' || l_po_line_id_tbl(i) ||
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
                  ', status: ' || l_ReqTmplt_line_status);
            END IF;
          END IF;
        END IF;
      END LOOP;  --FOR LOOP of l_inv_item_id_tbl

      l_err_loc := 1400;
      EXIT WHEN l_inv_item_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := 'ICX_CAT_POPULATE_REQTMPL_PVT.populateReqTemplates' ||l_err_loc
	                ||', Total processeded batches:' ||l_batch_count
                        ||', Cursor will be reopened with TBD TBD:' ;
        IF (FND_API.To_Boolean(ICX_CAT_UTIL_PVT.g_COMMIT)) THEN
          ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
          --Closing and reopen of cursor will be done by called procedures
          IF (p_current_mode = ICX_CAT_UTIL_PVT.g_upgrade_const) THEN
            l_err_loc := 1500;
            openR12UpgradeReqTmpltsCursor;
          ELSE
            l_err_loc := 1600;
            openReqTmpltsCursor(g_key);
          END IF;
        ELSE
          RAISE;
        END IF;
    END;
  END LOOP; --Cursor loop

  l_err_loc := 1700;
  ICX_CAT_POPULATE_ITEM_PVT.populateItemCtxTables('OUTLOOP', ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const);

  l_err_loc := 1800;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'populateReqTemplates done; '||
        'Total num. of batches processed:' ||l_batch_count ||
        ', Total num. of rows processed:' ||l_row_count);
  END IF;
  l_err_loc := 1900;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateReqTemplates;

PROCEDURE upgradeR12ReqTemplates
(       p_upgrade_last_run_date IN      DATE    ,
        p_start_rowid           IN      ROWID   ,
        p_end_rowid             IN      ROWID
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'upgradeR12ReqTemplates';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_upgrade_last_run_date := p_upgrade_last_run_date;

  l_err_loc := 200;
  g_start_rowid := p_start_rowid;
  g_end_rowid := p_end_rowid;

  l_err_loc := 300;
  openR12UpgradeReqTmpltsCursor;

  l_err_loc := 400;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    ICX_CAT_UTIL_PVT.g_job_reqtmplt_complete_date := NULL;
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
    ICX_CAT_UTIL_PVT.g_job_current_status := ICX_CAT_UTIL_PVT.g_job_failed_status;
    RAISE;
END upgradeR12ReqTemplates;

PROCEDURE populateOnlineReqTemplates
(       p_key                   IN              NUMBER
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'populateOnlineReqTemplates';
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
  openReqTmpltsCursor(p_key);

  l_err_loc := 500;
  ICX_CAT_POPULATE_CTXSTRING_PVT.populateCtxCatgAtt(ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id);

  l_err_loc := 600;
  g_metadataTblFormed := FALSE;
  g_CtxSqlForPODocsFormed := FALSE;

  l_err_loc := 700;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populateOnlineReqTemplates;

PROCEDURE buildCtxSqlForRTs
(       p_special_ctx_sql_tbl   IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type    ,
        p_regular_ctx_sql_tbl   IN OUT NOCOPY   ICX_CAT_BUILD_CTX_SQL_PVT.g_ctx_sql_tbl_type
)
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'buildCtxSqlForRTs';
  l_err_loc                     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (NOT ICX_CAT_POPULATE_REQTMPL_PVT.g_metadataTblFormed) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'about to call buildmetadatinfo');
    END IF;

    l_err_loc := 200;
    ICX_CAT_BUILD_CTX_SQL_PVT.buildMetadataInfo
           (0, g_special_metadata_tbl, g_regular_nontl_metadata_tbl, g_regular_tl_metadata_tbl);

    l_err_loc := 300;
    ICX_CAT_POPULATE_REQTMPL_PVT.g_metadataTblFormed := TRUE;
  END IF;

  l_err_loc := 400;
  IF (NOT ICX_CAT_POPULATE_REQTMPL_PVT.g_CtxSqlForPODocsFormed) THEN
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'about to call buildctxsql');
    END IF;

    l_err_loc := 500;
    ICX_CAT_BUILD_CTX_SQL_PVT.buildCtxSql
           (0, ICX_CAT_UTIL_PVT.g_ReqTemplateCsr_const, 'NOTROWID', g_special_metadata_tbl,
            g_regular_nontl_metadata_tbl, g_regular_tl_metadata_tbl,
            g_all_ctx_sql_tbl, g_special_ctx_sql_tbl, g_regular_ctx_sql_tbl);

    l_err_loc := 600;
    ICX_CAT_POPULATE_REQTMPL_PVT.g_CtxSqlForPODocsFormed := TRUE;
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
END buildCtxSqlForRTs;


END ICX_CAT_POPULATE_REQTMPL_PVT;

/
