--------------------------------------------------------
--  DDL for Package Body ICX_CAT_R12_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_R12_UPGRADE_PVT" AS
/* $Header: ICXV12UB.pls 120.24.12010000.3 2012/11/06 04:46:31 rparise ship $*/

-----------------------------------------------------------
                  -- Global variables --
-----------------------------------------------------------
-- Constants
G_PKG_NAME                      CONSTANT VARCHAR2(30) := 'ICX_CAT_R12_UPGRADE_PVT';
g_GBPA_hdr_count                PLS_INTEGER  := 0;
g_total_row_count               PLS_INTEGER := 0;
g_PDOI_batch_id		        NUMBER;
g_interface_source_code         po_headers_interface.interface_source_code%TYPE	:= 'CATALOG R12 UPGRADE';
g_process_code                  po_headers_interface.process_code%TYPE	:= 'NEW';
g_new_GBPA_description          CONSTANT VARCHAR2(35) := 'R12 Upgrade of Bulk-Loaded Content.';
g_total_bulkld_row_count        PLS_INTEGER := 0;
g_total_ext_row_count           PLS_INTEGER := 0;

-- Global constants for last successful completion dates
g_extract_last_run_date         DATE;
g_bulk_last_run_date            DATE;
g_bpa_last_run_date             DATE;
g_quote_last_run_date           DATE;
g_reqtmplt_last_run_date        DATE;
g_mi_last_run_date              DATE;
g_audsid                        NUMBER := USERENV('SESSIONID');

TYPE g_csr_type                 IS REF CURSOR;

TYPE g_po_hdrs_int_rec_type IS RECORD
(
  interface_header_id           NUMBER,
  action                        po_headers_interface.action%TYPE,
  org_id                        NUMBER,
  document_type_code            po_headers_interface.document_type_code%TYPE,
  budget_account_segment1       po_headers_interface.budget_account_segment1%TYPE,
  po_header_id                  NUMBER,
  approval_status               po_headers_interface.approval_status%TYPE,
  vendor_id                     NUMBER,
  vendor_site_id                NUMBER,
  currency_code                 po_headers_interface.currency_code%TYPE,
  cpa_reference                 NUMBER,
  created_language              po_headers_interface.created_language%TYPE,
  comments                      po_headers_interface.comments%TYPE
);

TYPE g_po_line_attrval_int_rec_type IS RECORD
(
  interface_line_id             NUMBER,
  interface_header_id           NUMBER,
  action                        po_lines_interface.action%TYPE,
  po_line_id                    NUMBER,
  po_header_id                  NUMBER,
  unit_price                    NUMBER,
  uom_code                      po_lines_interface.uom_code%TYPE,
  negotiated_by_preparer_flag   po_lines_interface.negotiated_by_preparer_flag%TYPE,
  ip_category_id                NUMBER,
  category_id                   NUMBER,
  category_name                 po_lines_interface.category%TYPE,
  vendor_product_num            po_lines_interface.vendor_product_num%TYPE,
  supplier_part_auxid           po_lines_interface.supplier_part_auxid%TYPE,
  item_description              po_lines_interface.item_description%TYPE,
  catalog_name                  po_lines_interface.catalog_name%TYPE,
  req_template_name             icx_cat_item_prices.template_id%TYPE,
  req_template_line_num         NUMBER,
  inventory_item_id             NUMBER,
  org_id                        NUMBER,
  rt_item_id                    NUMBER,
  language                      fnd_languages.language_code%TYPE
);

TYPE g_po_attrvalstlp_int_rec_type IS RECORD
(
  interface_header_id           NUMBER,
  interface_line_id             NUMBER,
  action                        po_attr_values_tlp_interface.action%TYPE,
  po_line_id                    NUMBER,
  req_template_name             po_attr_values_tlp_interface.req_template_name%TYPE,
  req_template_line_num         NUMBER,
  inventory_item_id             NUMBER,
  org_id                        NUMBER,
  language                      po_attr_values_tlp_interface.language%TYPE,
  check_desc_update             VARCHAR2(25),
  rt_item_id                    NUMBER
);

TYPE g_r12_upg_rec_type IS RECORD
(
  rt_item_id			NUMBER,
  supplier_site_id		NUMBER,
  currency			icx_cat_r12_upgrade.currency%TYPE,
  price_contract_id             NUMBER,
  src_contract_id               NUMBER,
  cpa_reference                 NUMBER,
  po_category_id                icx_cat_r12_upgrade.po_category_id%TYPE,
  po_interface_header_id	NUMBER,
  po_interface_line_id		NUMBER,
  po_header_id                  NUMBER,
  po_line_id                    NUMBER,
  created_language		icx_cat_r12_upgrade.created_language%TYPE,
  -- TBD extractor_updated_flag	icx_cat_r12_upgrade.extractor_updated_flag%TYPE,
  old_po_interface_line_id      NUMBER
);

g_po_hdrs_int_rec               g_po_hdrs_int_rec_type;
g_po_line_attrval_int_rec       g_po_line_attrval_int_rec_type;
g_po_attrvalstlp_int_rec        g_po_attrvalstlp_int_rec_type;
g_r12_upg_rec			g_r12_upg_rec_type;

TYPE g_current_gbpa_hdr_rec_type IS RECORD
(
  org_id                NUMBER,
  vendor_id             NUMBER,
  vendor_site_id        NUMBER,
  currency_code         po_headers_interface.currency_code%TYPE,
  cpa_reference         NUMBER,
  language              po_headers_interface.created_language%TYPE,
  interface_header_id   NUMBER,
  po_header_id          NUMBER,
  upg_created_language  po_headers_interface.created_language%TYPE,
  upg_cpa_reference     NUMBER
);

g_current_gbpa_hdr_rec  g_current_gbpa_hdr_rec_type;

----------------------------------------------------
        -- Global PL/SQL Tables --
----------------------------------------------------
--INSERT po_headers_interface
gIHInterfaceHeaderIdTbl         DBMS_SQL.NUMBER_TABLE;
gIHActionTbl                    DBMS_SQL.VARCHAR2_TABLE;
gIHOrgIdTbl                     DBMS_SQL.NUMBER_TABLE;
gIHDocumentTypeCodeTbl          DBMS_SQL.VARCHAR2_TABLE;
gIHBudgetAccountSegment1Tbl     DBMS_SQL.VARCHAR2_TABLE;
gIHPoHeaderIdTbl                DBMS_SQL.NUMBER_TABLE;
gIHApprovalStatusTbl            DBMS_SQL.VARCHAR2_TABLE;
gIHVendorIdTbl                  DBMS_SQL.NUMBER_TABLE;
gIHVendorSiteIdTbl              DBMS_SQL.NUMBER_TABLE;
gIHCurrencyCodeTbl              DBMS_SQL.VARCHAR2_TABLE;
gIHCpaReferenceTbl              DBMS_SQL.NUMBER_TABLE;
gIHCreatedLanguageTbl           DBMS_SQL.VARCHAR2_TABLE;
gIHCommentsTbl                  DBMS_SQL.VARCHAR2_TABLE;

--INSERT po_lines_interface
gILInterfaceLineIdTbl           DBMS_SQL.NUMBER_TABLE;
gILInterfaceHeaderIdTbl         DBMS_SQL.NUMBER_TABLE;
gILActionTbl                    DBMS_SQL.VARCHAR2_TABLE;
gILPoLineIdTbl                  DBMS_SQL.NUMBER_TABLE;
gILPoHeaderIdTbl                DBMS_SQL.NUMBER_TABLE;
gILUnitPriceTbl                 DBMS_SQL.NUMBER_TABLE;
gILUomCodeTbl                   DBMS_SQL.VARCHAR2_TABLE;
gILNegByPrepFlagTbl             DBMS_SQL.VARCHAR2_TABLE;
gILIpCategoryIdTbl              DBMS_SQL.NUMBER_TABLE;
gILCategoryIdTbl                DBMS_SQL.NUMBER_TABLE;
gILCategoryNameTbl              DBMS_SQL.VARCHAR2_TABLE;
gILVendorProductNumTbl          DBMS_SQL.VARCHAR2_TABLE;
gILSupplierPartAuxidTbl         DBMS_SQL.VARCHAR2_TABLE;
gILItemDescripionTbl            DBMS_SQL.VARCHAR2_TABLE;
gILCatalogNameTbl               DBMS_SQL.VARCHAR2_TABLE;

--INSERT po_attr_values_interface
gIAVInterfaceHeaderIdTbl        DBMS_SQL.NUMBER_TABLE;
gIAVInterfaceLineIdTbl          DBMS_SQL.NUMBER_TABLE;
gIAVActionTbl                   DBMS_SQL.VARCHAR2_TABLE;
gIAVPoLineIdTbl                 DBMS_SQL.NUMBER_TABLE;
gIAVReqTemplateNameTbl          DBMS_SQL.VARCHAR2_TABLE;
gIAVReqTemplateLineNumTbl       DBMS_SQL.NUMBER_TABLE;
gIAVInventoryItemIdTbl          DBMS_SQL.NUMBER_TABLE;
gIAVOrgIdTbl                    DBMS_SQL.NUMBER_TABLE;
gIAVRtItemIdTbl                 DBMS_SQL.NUMBER_TABLE;
gIAVLanguageTbl                 DBMS_SQL.VARCHAR2_TABLE;

--INSERT po_attr_values_tlp_interface
gIAVTInterfaceHeaderIdTbl       DBMS_SQL.NUMBER_TABLE;
gIAVTInterfaceLineIdTbl         DBMS_SQL.NUMBER_TABLE;
gIAVTActionTbl                  DBMS_SQL.VARCHAR2_TABLE;
gIAVTPoLineIdTbl                DBMS_SQL.NUMBER_TABLE;
gIAVTReqTemplateNameTbl         DBMS_SQL.VARCHAR2_TABLE;
gIAVTReqTemplateLineNumTbl      DBMS_SQL.NUMBER_TABLE;
gIAVTInventoryItemIdTbl         DBMS_SQL.NUMBER_TABLE;
gIAVTOrgIdTbl                   DBMS_SQL.NUMBER_TABLE;
gIAVTRtItemIdTbl                DBMS_SQL.NUMBER_TABLE;
gIAVTLanguageTbl                DBMS_SQL.VARCHAR2_TABLE;
gIAVTCheckDescUpdateTbl         DBMS_SQL.VARCHAR2_TABLE;

--INSERT icx_cat_r12_upgrade
gIRURtItemIdTbl			DBMS_SQL.NUMBER_TABLE;
gIRUSupplierSiteIdTbl		DBMS_SQL.NUMBER_TABLE;
gIRUCurrencyTbl			DBMS_SQL.VARCHAR2_TABLE;
gIRUCpaReferenceTbl             DBMS_SQL.NUMBER_TABLE;
gIRUPriceContractIdTbl		DBMS_SQL.NUMBER_TABLE;
gIRUSrcContractIdTbl            DBMS_SQL.NUMBER_TABLE;
gIRUPoCategoryIdTbl             DBMS_SQL.VARCHAR2_TABLE;
gIRUPoInterfaceHeaderIdTbl	DBMS_SQL.NUMBER_TABLE;
gIRUPoInterfaceLineIdTbl	DBMS_SQL.NUMBER_TABLE;
gIRUCreatedLanguageTbl		DBMS_SQL.VARCHAR2_TABLE;
-- TBD gIRUExtractorUpdatedFlagTbl	DBMS_SQL.VARCHAR2_TABLE;

--UPDATE icx_cat_r12_upgrade
gURURtItemIdTbl                 DBMS_SQL.NUMBER_TABLE;
gURUPoCategoryIdTbl             DBMS_SQL.NUMBER_TABLE;
gURUCpaReferenceTbl             DBMS_SQL.NUMBER_TABLE;
gURUPriceContractIdTbl          DBMS_SQL.NUMBER_TABLE;
gURUSrcContractIdTbl            DBMS_SQL.NUMBER_TABLE;
gURUOldPoInterfaceLineIdTbl	DBMS_SQL.NUMBER_TABLE;
gURUPoInterfaceHeaderIdTbl	DBMS_SQL.NUMBER_TABLE;
gURUPoInterfaceLineIdTbl	DBMS_SQL.NUMBER_TABLE;
gURUPoHeaderIdTbl               DBMS_SQL.NUMBER_TABLE;
gURUPoLineIdTbl                 DBMS_SQL.NUMBER_TABLE;
gURUCreatedLanguageTbl          DBMS_SQL.VARCHAR2_TABLE;

--DELETE icx_cat_r12_upgrade
gDRURtItemIdTbl                 DBMS_SQL.NUMBER_TABLE;
gDRUPoInterfaceHeaderIdTbl      DBMS_SQL.NUMBER_TABLE;
gDRUPoInterfaceLineIdTbl        DBMS_SQL.NUMBER_TABLE;

--INSERT icx_cat_fav_list_lines_tlp for catalog items
gIFLCFavoriteListIdTbl          DBMS_SQL.NUMBER_TABLE;
gIFLCNewFavoriteListLineIdTbl   DBMS_SQL.NUMBER_TABLE;
gIFLCOldFavoriteListLineIdTbl   DBMS_SQL.NUMBER_TABLE;
gIFLCRtItemIdTbl                DBMS_SQL.NUMBER_TABLE;
gIFLCSourceTypeTbl              DBMS_SQL.VARCHAR2_TABLE;
gIFLCOrgIdTbl                   DBMS_SQL.NUMBER_TABLE;
gIFLCLanguageTbl                DBMS_SQL.VARCHAR2_TABLE;

--INSERT icx_cat_fav_list_lines_tlp for other items
gIFLOFavoriteListIdTbl          DBMS_SQL.NUMBER_TABLE;
gIFLONewFavoriteListLineIdTbl   DBMS_SQL.NUMBER_TABLE;
gIFLOOldFavoriteListLineIdTbl   DBMS_SQL.NUMBER_TABLE;
gIFLOOrgIdTbl                   DBMS_SQL.NUMBER_TABLE;
gIFLOLanguageTbl                DBMS_SQL.VARCHAR2_TABLE;

PROCEDURE clearTables
(       p_action_mode   IN      VARCHAR2
)
IS
BEGIN
  IF (p_action_mode IN ('ALL', 'INSERT_INT_HDRS')) THEN
    --INSERT po_headers_interface
    gIHInterfaceHeaderIdTbl.DELETE;
    gIHActionTbl.DELETE;
    gIHOrgIdTbl.DELETE;
    gIHDocumentTypeCodeTbl.DELETE;
    gIHBudgetAccountSegment1Tbl.DELETE;
    gIHPoHeaderIdTbl.DELETE;
    gIHApprovalStatusTbl.DELETE;
    gIHVendorIdTbl.DELETE;
    gIHVendorSiteIdTbl.DELETE;
    gIHCurrencyCodeTbl.DELETE;
    gIHCpaReferenceTbl.DELETE;
    gIHCreatedLanguageTbl.DELETE;
    gIHCommentsTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'INSERT_INT_LINES')) THEN
    --INSERT po_lines_interface
    gILInterfaceLineIdTbl.DELETE;
    gILInterfaceHeaderIdTbl.DELETE;
    gILActionTbl.DELETE;
    gILPoLineIdTbl.DELETE;
    gILPoHeaderIdTbl.DELETE;
    gILUnitPriceTbl.DELETE;
    gILUomCodeTbl.DELETE;
    gILNegByPrepFlagTbl.DELETE;
    gILIpCategoryIdTbl.DELETE;
    gILCategoryIdTbl.DELETE;
    gILCategoryNameTbl.DELETE;
    gILVendorProductNumTbl.DELETE;
    gILSupplierPartAuxidTbl.DELETE;
    gILItemDescripionTbl.DELETE;
    gILCatalogNameTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'INSERT_INT_ATTR_VALS')) THEN
    --INSERT po_attr_values_interface
    gIAVInterfaceHeaderIdTbl.DELETE;
    gIAVInterfaceLineIdTbl.DELETE;
    gIAVActionTbl.DELETE;
    gIAVPoLineIdTbl.DELETE;
    gIAVReqTemplateNameTbl.DELETE;
    gIAVReqTemplateLineNumTbl.DELETE;
    gIAVInventoryItemIdTbl.DELETE;
    gIAVOrgIdTbl.DELETE;
    gIAVRtItemIdTbl.DELETE;
    gIAVLanguageTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'INSERT_INT_ATTR_VALS_TLP')) THEN
    --INSERT po_attr_values_tlp_interface
    gIAVTInterfaceHeaderIdTbl.DELETE;
    gIAVTInterfaceLineIdTbl.DELETE;
    gIAVTActionTbl.DELETE;
    gIAVTPoLineIdTbl.DELETE;
    gIAVTReqTemplateNameTbl.DELETE;
    gIAVTReqTemplateLineNumTbl.DELETE;
    gIAVTInventoryItemIdTbl.DELETE;
    gIAVTOrgIdTbl.DELETE;
    gIAVTRtItemIdTbl.DELETE;
    gIAVTLanguageTbl.DELETE;
    gIAVTCheckDescUpdateTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'INSERT_R12_UPGRADE')) THEN
    --INSERT icx_cat_r12_upgrade
    gIRURtItemIdTbl.DELETE;
    gIRUSupplierSiteIdTbl.DELETE;
    gIRUCurrencyTbl.DELETE;
    gIRUCpaReferenceTbl.DELETE;
    gIRUPriceContractIdTbl.DELETE;
    gIRUSrcContractIdTbl.DELETE;
    gIRUPoCategoryIdTbl.DELETE;
    gIRUPoInterfaceHeaderIdTbl.DELETE;
    gIRUPoInterfaceLineIdTbl.DELETE;
    gIRUCreatedLanguageTbl.DELETE;
    -- TBD gIRUExtractorUpdatedFlagTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'UPDATE_R12_UPGRADE')) THEN
    --UPDATE icx_cat_r12_upgrade
    gURURtItemIdTbl.DELETE;
    gURUPoCategoryIdTbl.DELETE;
    gURUCpaReferenceTbl.DELETE;
    gURUPriceContractIdTbl.DELETE;
    gURUSrcContractIdTbl.DELETE;
    gURUOldPoInterfaceLineIdTbl.DELETE;
    gURUPoInterfaceHeaderIdTbl.DELETE;
    gURUPoInterfaceLineIdTbl.DELETE;
    gURUPoHeaderIdTbl.DELETE;
    gURUPoLineIdTbl.DELETE;
    gURUCreatedLanguageTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'DELETE_R12_UPGRADE')) THEN
    --DELETE icx_cat_r12_upgrade
    gDRURtItemIdTbl.DELETE;
    gDRUPoInterfaceHeaderIdTbl.DELETE;
    gDRUPoInterfaceLineIdTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'INSERT_FAV_LINES_CATALOG')) THEN
    --INSERT icx_cat_fav_list_lines_tlp for catalog items
    gIFLCFavoriteListIdTbl.DELETE;
    gIFLCNewFavoriteListLineIdTbl.DELETE;
    gIFLCOldFavoriteListLineIdTbl.DELETE;
    gIFLCRtItemIdTbl.DELETE;
    gIFLCSourceTypeTbl.DELETE;
    gIFLCOrgIdTbl.DELETE;
    gIFLCLanguageTbl.DELETE;
  END IF;

  IF (p_action_mode IN ('ALL', 'INSERT_FAV_LINES_OTHER')) THEN
    --INSERT icx_cat_fav_list_lines_tlp for other items
    gIFLOFavoriteListIdTbl.DELETE;
    gIFLONewFavoriteListLineIdTbl.DELETE;
    gIFLOOldFavoriteListLineIdTbl.DELETE;
    gIFLOOrgIdTbl.DELETE;
    gIFLOLanguageTbl.DELETE;
  END IF;
END clearTables;

/*
FUNCTION logPLSQLTableRow(p_index       IN PLS_INTEGER,
                          p_action_mode IN VARCHAR2)
  RETURN VARCHAR2
IS
  l_string VARCHAR2(4000);
BEGIN
  l_string := 'logPLSQLTableRow('||p_action_mode||')['||p_index||']--';
  IF (p_action_mode = 'INSERT_INT_HDRS') THEN
    --INSERT po_headers_interface
    l_string := l_string || ' gIHInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHInterfaceHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHActionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHActionTbl, p_index) || ', ';
    l_string := l_string || ' gIHOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHDocumentTypeCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHDocumentTypeCodeTbl, p_index) || ', ';
    l_string := l_string || ' gIHBudgetAccountSegment1Tbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHBudgetAccountSegment1Tbl, p_index) || ', ';
    l_string := l_string || ' gIHPoHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHPoHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHApprovalStatusTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHApprovalStatusTbl, p_index) || ', ';
    l_string := l_string || ' gIHVendorIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHVendorIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHVendorSiteIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHVendorSiteIdTbl, p_index) || ', ';
    l_string := l_string || ' gIHCurrencyCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHCurrencyCodeTbl, p_index) || ', ';
    l_string := l_string || ' gIHCpaReferenceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHCpaReferenceTbl, p_index) || ', ';
    l_string := l_string || ' gIHCreatedLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHCreatedLanguageTbl, p_index) || ', ';
    l_string := l_string || ' gIHCommentsTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHCommentsTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'INSERT_INT_LINES') THEN
    --INSERT po_lines_interface
    l_string := l_string || ' gILInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILInterfaceLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gILInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILInterfaceHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gILActionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILActionTbl, p_index) || ', ';
    l_string := l_string || ' gILPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gILPoHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILPoHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gILUnitPriceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILUnitPriceTbl, p_index) || ', ';
    l_string := l_string || ' gILUomCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILUomCodeTbl, p_index) || ', ';
    l_string := l_string || ' gILNegByPrepFlagTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILNegByPrepFlagTbl, p_index) || ', ';
    l_string := l_string || ' gILIpCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILIpCategoryIdTbl, p_index) || ', ';
    l_string := l_string || ' gILCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILCategoryIdTbl, p_index) || ', ';
    l_string := l_string || ' gILCategoryNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILCategoryNameTbl, p_index) || ', ';
    l_string := l_string || ' gILVendorProductNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILVendorProductNumTbl, p_index) || ', ';
    l_string := l_string || ' gILSupplierPartAuxidTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILSupplierPartAuxidTbl, p_index) || ', ';
    l_string := l_string || ' gILItemDescripionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILItemDescripionTbl, p_index) || ', ';
    l_string := l_string || ' gILCatalogNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILCatalogNameTbl, p_index) || ', ';

  END IF;

  IF (p_action_mode = 'INSERT_INT_ATTR_VALS') THEN
    --INSERT po_attr_values_interface
    l_string := l_string || ' gIAVInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVInterfaceHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVInterfaceLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVActionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVActionTbl, p_index) || ', ';
    l_string := l_string || ' gIAVPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gIAVReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gIAVInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVRtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVRtItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVLanguageTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'INSERT_INT_ATTR_VALS_TLP') THEN
    --INSERT po_attr_values_tlp_interface
    l_string := l_string || ' gIAVTInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTInterfaceHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVTInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTInterfaceLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVTActionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTActionTbl, p_index) || ', ';
    l_string := l_string || ' gIAVTPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVTReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTReqTemplateNameTbl, p_index) || ', ';
    l_string := l_string || ' gIAVTReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTReqTemplateLineNumTbl, p_index) || ', ';
    l_string := l_string || ' gIAVTInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTInventoryItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVTOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVTRtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTRtItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gIAVTLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTLanguageTbl, p_index) || ', ';
    l_string := l_string || ' gIAVTCheckDescUpdateTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTCheckDescUpdateTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'INSERT_R12_UPGRADE') THEN
    --INSERT icx_cat_r12_upgrade
    l_string := l_string || ' gIRURtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRURtItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gIRUSupplierSiteIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUSupplierSiteIdTbl, p_index) || ', ';
    l_string := l_string || ' gIRUCurrencyTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUCurrencyTbl, p_index) || ', ';
    l_string := l_string || ' gIRUCpaReferenceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUCpaReferenceTbl, p_index) || ', ';
    l_string := l_string || ' gIRUPriceContractIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUPriceContractIdTbl, p_index) || ', ';
    l_string := l_string || ' gIRUSrcContractIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUSrcContractIdTbl, p_index) || ', ';
    l_string := l_string || ' gIRUPoCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUPoCategoryIdTbl, p_index) || ', ';
    l_string := l_string || ' gIRUPoInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUPoInterfaceHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gIRUPoInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUPoInterfaceLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIRUCreatedLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUCreatedLanguageTbl, p_index) || ', ';
    -- TBD l_string := l_string || ' gIRUExtractorUpdatedFlagTbl: ' ||
    -- TBD   ICX_CAT_UTIL_PVT.getTableElement(gIRUExtractorUpdatedFlagTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'UPDATE_R12_UPGRADE') THEN
    --UPDATE icx_cat_r12_upgrade
    l_string := l_string || ' gURURtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURURtItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gURUPoCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPoCategoryIdTbl, p_index) || ', ';
    l_string := l_string || ' gURUCpaReferenceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUCpaReferenceTbl, p_index) || ', ';
    l_string := l_string || ' gURUPriceContractIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPriceContractIdTbl, p_index) || ', ';
    l_string := l_string || ' gURUSrcContractIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUSrcContractIdTbl, p_index) || ', ';
    l_string := l_string || ' gURUOldPoInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUOldPoInterfaceLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gURUPoInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPoInterfaceHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gURUPoInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPoInterfaceLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gURUPoHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPoHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gURUPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPoLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gURUCreatedLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUCreatedLanguageTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'DELETE_R12_UPGRADE') THEN
    --DELETE icx_cat_r12_upgrade
    l_string := l_string || ' gDRURtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDRURtItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gDRUPoInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDRUPoInterfaceHeaderIdTbl, p_index) || ', ';
    l_string := l_string || ' gDRUPoInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDRUPoInterfaceLineIdTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'INSERT_FAV_LINES_CATALOG') THEN
    --INSERT icx_cat_fav_list_lines_tlp for catalog items
    l_string := l_string || ' gIFLCFavoriteListIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCFavoriteListIdTbl, p_index) || ', ';
    l_string := l_string || ' gIFLCNewFavoriteListLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCNewFavoriteListLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIFLCOldFavoriteListLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCOldFavoriteListLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIFLCRtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCRtItemIdTbl, p_index) || ', ';
    l_string := l_string || ' gIFLCSourceTypeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCSourceTypeTbl, p_index) || ', ';
    l_string := l_string || ' gIFLCOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gIFLCLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCLanguageTbl, p_index) || ', ';
  END IF;

  IF (p_action_mode = 'INSERT_FAV_LINES_OTHER') THEN
    --INSERT icx_cat_fav_list_lines_tlp for other items
    l_string := l_string || ' gIFLOFavoriteListIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLOFavoriteListIdTbl, p_index) || ', ';
    l_string := l_string || ' gIFLONewFavoriteListLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLONewFavoriteListLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIFLOOldFavoriteListLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLOOldFavoriteListLineIdTbl, p_index) || ', ';
    l_string := l_string || ' gIFLOOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLOOrgIdTbl, p_index) || ', ';
    l_string := l_string || ' gIFLOLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLOLanguageTbl, p_index) || ', ';
  END IF;

  RETURN l_string;

END logPLSQLTableRow;
*/

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

    IF (p_action_mode = 'INSERT_INT_HDRS') THEN
      l_err_loc := 500;
      -- INSERT po_headers_interface
      l_log_string := ' gIHInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHInterfaceHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHActionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHActionTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHDocumentTypeCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHDocumentTypeCodeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHBudgetAccountSegment1Tbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHBudgetAccountSegment1Tbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHPoHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHPoHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHApprovalStatusTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHApprovalStatusTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHVendorIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHVendorIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHVendorSiteIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHVendorSiteIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHCurrencyCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHCurrencyCodeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHCpaReferenceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHCpaReferenceTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHCreatedLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHCreatedLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIHCommentsTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIHCommentsTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 600;

    IF (p_action_mode = 'INSERT_INT_LINES') THEN
      l_err_loc := 700;
      -- INSERT po_lines_interface
      l_log_string := ' gILInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILInterfaceLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILInterfaceHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILActionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILActionTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILPoHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILPoHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILUnitPriceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILUnitPriceTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILUomCodeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILUomCodeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILNegByPrepFlagTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILNegByPrepFlagTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILIpCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILIpCategoryIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILCategoryIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILCategoryNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILCategoryNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILVendorProductNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILVendorProductNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILSupplierPartAuxidTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILSupplierPartAuxidTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILItemDescripionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILItemDescripionTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gILCatalogNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gILCatalogNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 800;

    IF (p_action_mode = 'INSERT_INT_ATTR_VALS') THEN
      l_err_loc := 900;
      -- INSERT po_attr_values_interface
      l_log_string := ' gIAVInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVInterfaceHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVInterfaceLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVActionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVActionTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVRtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVRtItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 1000;

    IF (p_action_mode = 'INSERT_INT_ATTR_VALS_TLP') THEN
      l_err_loc := 1100;
      -- INSERT po_attr_values_tlp_interface
      l_log_string := ' gIAVTInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTInterfaceHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVTInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTInterfaceLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVTActionTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTActionTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVTPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVTReqTemplateNameTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTReqTemplateNameTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVTReqTemplateLineNumTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTReqTemplateLineNumTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVTInventoryItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTInventoryItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVTOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVTRtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTRtItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVTLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIAVTCheckDescUpdateTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIAVTCheckDescUpdateTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 1200;

    IF (p_action_mode = 'INSERT_R12_UPGRADE') THEN
      l_err_loc := 1300;
      -- INSERT icx_cat_r12_upgrade
      l_log_string := ' gIRURtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRURtItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIRUSupplierSiteIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUSupplierSiteIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIRUCurrencyTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUCurrencyTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIRUCpaReferenceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUCpaReferenceTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIRUPriceContractIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUPriceContractIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIRUSrcContractIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUSrcContractIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIRUPoCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUPoCategoryIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIRUPoInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUPoInterfaceHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIRUPoInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUPoInterfaceLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIRUCreatedLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIRUCreatedLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 1400;

    IF (p_action_mode = 'UPDATE_R12_UPGRADE') THEN
      l_err_loc := 1500;
      -- UPDATE icx_cat_r12_upgrade
      l_log_string := ' gURURtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURURtItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gURUPoCategoryIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPoCategoryIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gURUCpaReferenceTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUCpaReferenceTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gURUPriceContractIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPriceContractIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gURUSrcContractIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUSrcContractIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gURUOldPoInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUOldPoInterfaceLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gURUPoInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPoInterfaceHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gURUPoInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPoInterfaceLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gURUPoHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPoHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gURUPoLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUPoLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gURUCreatedLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gURUCreatedLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 1600;

    IF (p_action_mode = 'DELETE_R12_UPGRADE') THEN
      l_err_loc := 1700;
      -- DELETE icx_cat_r12_upgrade
      l_log_string := ' gDRURtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDRURtItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDRUPoInterfaceHeaderIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDRUPoInterfaceHeaderIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gDRUPoInterfaceLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gDRUPoInterfaceLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 1800;

    IF (p_action_mode = 'INSERT_FAV_LINES_CATALOG') THEN
      l_err_loc := 1900;
      --INSERT icx_cat_fav_list_lines_tlp for catalog items
      l_log_string := ' gIFLCFavoriteListIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCFavoriteListIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIFLCNewFavoriteListLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCNewFavoriteListLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIFLCOldFavoriteListLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCOldFavoriteListLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIFLCRtItemIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCRtItemIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIFLCSourceTypeTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCSourceTypeTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIFLCOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIFLCLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLCLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 2000;

    IF (p_action_mode = 'INSERT_FAV_LINES_OTHER') THEN
      l_err_loc := 2100;
      --INSERT icx_cat_fav_list_lines_tlp for other items
      l_log_string := ' gIFLOFavoriteListIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLOFavoriteListIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIFLONewFavoriteListLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLONewFavoriteListLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIFLOOldFavoriteListLineIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLOOldFavoriteListLineIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIFLOOrgIdTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLOOrgIdTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

      l_log_string := ' gIFLOLanguageTbl: ' ||
      ICX_CAT_UTIL_PVT.getTableElement(gIFLOLanguageTbl, p_index) || '; ';
      FND_LOG.string(p_log_level, l_module_name, l_log_string);

    END IF;

    l_err_loc := 2200;

  END IF;

  l_err_loc := 2400;
END logPLSQLTableRow;

FUNCTION getNextInterfaceHdrIdFromSeq
  RETURN NUMBER
IS

  l_interface_header_id         NUMBER;
  l_api_name                    CONSTANT VARCHAR2(30)   := 'getNextInterfaceHdrIdFromSeq';
  l_err_loc                     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  SELECT po_headers_interface_s.NEXTVAL
  INTO   l_interface_header_id
  FROM DUAL;

  l_err_loc := 110;
  RETURN l_interface_header_id;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END getNextInterfaceHdrIdFromSeq;

FUNCTION getNextInterfaceLineIdFromSeq
  RETURN NUMBER
IS

  l_interface_line_id           NUMBER;
  l_api_name                    CONSTANT VARCHAR2(30)   := 'getNextInterfaceLineIdFromSeq';
  l_err_loc                     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  SELECT po_lines_interface_s.NEXTVAL
  INTO   l_interface_line_id
  FROM DUAL;

  l_err_loc := 110;
  RETURN l_interface_line_id;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END getNextInterfaceLineIdFromSeq;

FUNCTION getNextFavListLineIdFromSeq
  RETURN NUMBER
IS

  l_favorite_list_line_id       NUMBER;
  l_api_name                    CONSTANT VARCHAR2(30)   := 'getNextFavListLineIdFromSeq';
  l_err_loc                     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  SELECT por_favorite_list_lines_s.NEXTVAL
  INTO   l_favorite_list_line_id
  FROM DUAL;

  l_err_loc := 110;
  RETURN l_favorite_list_line_id;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END getNextFavListLineIdFromSeq;

FUNCTION getPOAttrValuesTLPAction
(       p_po_line_id            IN      NUMBER          ,
        p_req_template_name     IN      VARCHAR2        ,
        p_req_template_line_num IN      NUMBER          ,
        p_org_id                IN      NUMBER          ,
        p_language              IN      VARCHAR2
)
  RETURN VARCHAR2
IS

  l_action      po_attr_values_tlp_interface.action%TYPE;
  l_api_name    CONSTANT VARCHAR2(30)   := 'getPOAttrValuesTLPAction';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  SELECT 'UPDATE'
  INTO   l_action
  FROM   po_attribute_values_tlp
  WHERE  po_line_id = p_po_line_id
  AND    req_template_name = p_req_template_name
  AND    req_template_line_num = p_req_template_line_num
  AND    org_id = p_org_id
  AND    language = p_language;

  l_err_loc := 110;
  RETURN l_action;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'ADD';
END getPOAttrValuesTLPAction;

PROCEDURE insertPOHeadersInterface
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'insertPOHeadersInterface';
  l_err_loc     PLS_INTEGER;
  l_index       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_total_row_count     := g_total_row_count     + 1;
  l_index := gIHInterfaceHeaderIdTbl.COUNT + 1;

  l_err_loc := 110;
  gIHInterfaceHeaderIdTbl(l_index) := g_po_hdrs_int_rec.interface_header_id;
  gIHActionTbl(l_index) := g_po_hdrs_int_rec.action;
  gIHOrgIdTbl(l_index) := g_po_hdrs_int_rec.org_id;
  gIHDocumentTypeCodeTbl(l_index) := g_po_hdrs_int_rec.document_type_code;
  -- Only used when processing req templates during data migration
  l_err_loc := 120;
  gIHBudgetAccountSegment1Tbl(l_index) := g_po_hdrs_int_rec.budget_account_segment1;
  gIHPoHeaderIdTbl(l_index) := g_po_hdrs_int_rec.po_header_id;
  gIHApprovalStatusTbl(l_index) := g_po_hdrs_int_rec.approval_status;
  gIHVendorIdTbl(l_index) := g_po_hdrs_int_rec.vendor_id;
  gIHVendorSiteIdTbl(l_index) := g_po_hdrs_int_rec.vendor_site_id;
  l_err_loc := 140;
  gIHCurrencyCodeTbl(l_index) := g_po_hdrs_int_rec.currency_code;
  l_err_loc := 160;
  gIHCpaReferenceTbl(l_index) := g_po_hdrs_int_rec.cpa_reference;
  gIHCreatedLanguageTbl(l_index) := g_po_hdrs_int_rec.created_language;
  l_err_loc := 180;
  gIHCommentsTbl(l_index) := g_po_hdrs_int_rec.comments;

  l_err_loc := 200;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END insertPOHeadersInterface;

PROCEDURE insertPOLinesInterface
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'insertPOLinesInterface';
  l_err_loc                     PLS_INTEGER;
  l_index                       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_total_row_count     := g_total_row_count     + 1;
  l_index := gILInterfaceHeaderIdTbl.COUNT + 1;

  l_err_loc := 110;
  gILInterfaceHeaderIdTbl(l_index) := g_po_line_attrval_int_rec.interface_header_id;
  gILInterfaceLineIdTbl(l_index) := g_po_line_attrval_int_rec.interface_line_id;
  gILActionTbl(l_index) := g_po_line_attrval_int_rec.action;
  gILPoLineIdTbl(l_index) := g_po_line_attrval_int_rec.po_line_id;
  gILPoHeaderIdTbl(l_index) := g_po_line_attrval_int_rec.po_header_id;
  gILUnitPriceTbl(l_index) := g_po_line_attrval_int_rec.unit_price;
  l_err_loc := 120;
  gILUomCodeTbl(l_index) := g_po_line_attrval_int_rec.uom_code;
  gILNegByPrepFlagTbl(l_index) := g_po_line_attrval_int_rec.negotiated_by_preparer_flag;
  gILIpCategoryIdTbl(l_index) := g_po_line_attrval_int_rec.ip_category_id;
  gILCategoryIdTbl(l_index) := g_po_line_attrval_int_rec.category_id;
  l_err_loc := 140;
  gILCategoryNameTbl(l_index) := g_po_line_attrval_int_rec.category_name;
  l_err_loc := 160;
  gILVendorProductNumTbl(l_index) := g_po_line_attrval_int_rec.vendor_product_num;
  gILSupplierPartAuxidTbl(l_index) := g_po_line_attrval_int_rec.supplier_part_auxid;
  l_err_loc := 180;
  gILItemDescripionTbl(l_index) := g_po_line_attrval_int_rec.item_description;
  gILCatalogNameTbl(l_index) := g_po_line_attrval_int_rec.catalog_name;

  l_err_loc := 200;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END insertPOLinesInterface;

PROCEDURE insertPOAttrValsInterface
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'insertPOAttrValsInterface';
  l_err_loc                     PLS_INTEGER;
  l_index                       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_total_row_count     := g_total_row_count     + 1;
  l_index := gIAVInterfaceHeaderIdTbl.COUNT + 1;

  l_err_loc := 110;
  gIAVInterfaceHeaderIdTbl(l_index) := g_po_line_attrval_int_rec.interface_header_id;
  gIAVInterfaceLineIdTbl(l_index) := g_po_line_attrval_int_rec.interface_line_id;
  gIAVActionTbl(l_index) := g_po_line_attrval_int_rec.action;
  gIAVPoLineIdTbl(l_index) := g_po_line_attrval_int_rec.po_line_id;
  gIAVReqTemplateNameTbl(l_index) := g_po_line_attrval_int_rec.req_template_name;
  gIAVReqTemplateLineNumTbl(l_index) := g_po_line_attrval_int_rec.req_template_line_num;
  gIAVInventoryItemIdTbl(l_index) := g_po_line_attrval_int_rec.inventory_item_id;
  gIAVOrgIdTbl(l_index) := g_po_line_attrval_int_rec.org_id;
  gIAVRtItemIdTbl(l_index) := g_po_line_attrval_int_rec.rt_item_id;
  gIAVLanguageTbl(l_index) := g_po_line_attrval_int_rec.language;
  l_err_loc := 120;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END insertPOAttrValsInterface;

PROCEDURE insertPOAttrValsTLPInterface
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'insertPOAttrValsTLPInterface';
  l_err_loc                     PLS_INTEGER;
  l_index                       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_total_row_count     := g_total_row_count     + 1;
  l_index := gIAVTInterfaceHeaderIdTbl.COUNT + 1;

  l_err_loc := 110;
  gIAVTInterfaceHeaderIdTbl(l_index) := g_po_attrvalstlp_int_rec.interface_header_id;
  gIAVTInterfaceLineIdTbl(l_index) := g_po_attrvalstlp_int_rec.interface_line_id;
  gIAVTActionTbl(l_index) := g_po_attrvalstlp_int_rec.action;
  gIAVTPoLineIdTbl(l_index) := g_po_attrvalstlp_int_rec.po_line_id;
  gIAVTReqTemplateNameTbl(l_index) := g_po_attrvalstlp_int_rec.req_template_name;
  gIAVTReqTemplateLineNumTbl(l_index) := g_po_attrvalstlp_int_rec.req_template_line_num;
  gIAVTInventoryItemIdTbl(l_index) := g_po_attrvalstlp_int_rec.inventory_item_id;
  gIAVTOrgIdTbl(l_index) := g_po_attrvalstlp_int_rec.org_id;
  gIAVTRtItemIdTbl(l_index) := g_po_attrvalstlp_int_rec.rt_item_id;
  gIAVTLanguageTbl(l_index) := g_po_attrvalstlp_int_rec.language;
  gIAVTCheckDescUpdateTbl(l_index) := g_po_attrvalstlp_int_rec.check_desc_update;
  l_err_loc := 120;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END insertPOAttrValsTLPInterface;

PROCEDURE insertR12Upgrade
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'insertR12Upgrade';
  l_err_loc                     PLS_INTEGER;
  l_index                       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_total_row_count     := g_total_row_count     + 1;
  l_index := gIRURtItemIdTbl.COUNT + 1;

  l_err_loc := 110;
  gIRURtItemIdTbl(l_index) := g_r12_upg_rec.rt_item_id;
  gIRUSupplierSiteIdTbl(l_index) := g_r12_upg_rec.supplier_site_id;
  gIRUCurrencyTbl(l_index) := g_r12_upg_rec.currency;
  l_err_loc := 120;
  gIRUCpaReferenceTbl(l_index) := g_r12_upg_rec.cpa_reference;
  gIRUPriceContractIdTbl(l_index) := g_r12_upg_rec.price_contract_id;
  l_err_loc := 140;
  gIRUSrcContractIdTbl(l_index) := g_r12_upg_rec.src_contract_id;
  gIRUPoCategoryIdTbl(l_index) := g_r12_upg_rec.po_category_id;
  l_err_loc := 160;
  gIRUPoInterfaceHeaderIdTbl(l_index) := g_r12_upg_rec.po_interface_header_id;
  gIRUPoInterfaceLineIdTbl(l_index) := g_r12_upg_rec.po_interface_line_id;
  gIRUCreatedLanguageTbl(l_index) := g_r12_upg_rec.created_language;
  -- TBD gIRUExtractorUpdatedFlagTbl(l_index) := g_r12_upg_rec.extractor_updated_flag;
  l_err_loc := 200;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END insertR12Upgrade;

-- TBD
-- Also needs to take care of po_category_id changes during delta processing
-- po_category_id could have changed since pre-upgrade was run last time.
-- due to category changes or mapping changes (TBD).
PROCEDURE updateR12Upgrade
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'updateR12Upgrade';
  l_err_loc                     PLS_INTEGER;
  l_index                       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_total_row_count     := g_total_row_count     + 1;
  l_index := gURURtItemIdTbl.COUNT + 1;

  l_err_loc := 110;
  gURURtItemIdTbl(l_index) := g_r12_upg_rec.rt_item_id;
  gURUPoCategoryIdTbl(l_index) := g_r12_upg_rec.po_category_id;
  gURUCpaReferenceTbl(l_index) := g_r12_upg_rec.cpa_reference;
  gURUPriceContractIdTbl(l_index) := g_r12_upg_rec.price_contract_id;
  gURUSrcContractIdTbl(l_index) := g_r12_upg_rec.src_contract_id;
  gURUOldPoInterfaceLineIdTbl(l_index) := g_r12_upg_rec.old_po_interface_line_id;
  gURUPoInterfaceHeaderIdTbl(l_index) := g_r12_upg_rec.po_interface_header_id;
  gURUPoInterfaceLineIdTbl(l_index) := g_r12_upg_rec.po_interface_line_id;
  gURUPoHeaderIdTbl(l_index) := g_r12_upg_rec.po_header_id;
  gURUPoLineIdTbl(l_index) := g_r12_upg_rec.po_line_id;
  gURUCreatedLanguageTbl(l_index) := g_r12_upg_rec.created_language;
  l_err_loc := 120;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END updateR12Upgrade;

PROCEDURE deleteR12Upgrade
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'deleteR12Upgrade';
  l_err_loc                     PLS_INTEGER;
  l_index                       PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  g_total_row_count     := g_total_row_count     + 1;
  l_index := gDRURtItemIdTbl.COUNT + 1;

  l_err_loc := 110;
  gDRURtItemIdTbl(l_index) := g_r12_upg_rec.rt_item_id;
  gDRUPoInterfaceHeaderIdTbl(l_index) := g_r12_upg_rec.po_interface_header_id;
  gDRUPoInterfaceLineIdTbl(l_index) := g_r12_upg_rec.po_interface_line_id;
  l_err_loc := 120;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END deleteR12Upgrade;

PROCEDURE createGBPAHeader
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'createGBPAHeader';
  l_err_loc                     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END createGBPAHeader;

PROCEDURE populatePOInterfaceTables
(       p_mode          IN      VARCHAR2
)
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'populatePOInterfaceTables';
  l_err_loc                     PLS_INTEGER;
  l_action_mode                 VARCHAR2(80);
BEGIN
  l_err_loc := 100;

  l_err_loc := 110;
  IF (p_mode = 'OUTLOOP' OR g_total_row_count >= ICX_CAT_UTIL_PVT.g_batch_size) THEN
    l_err_loc := 120;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Enter populatePOInterfaceTables(' || p_mode || ')g_total_row_count    : ' ||
        g_total_row_count);
    END IF;

    g_total_row_count := 0;

    l_err_loc := 130;
    l_action_mode := 'INSERT_INT_HDRS';
    -- Note: Copy of CPA attributes to GBPA will be done by PO.
    FORALL i in 1..gIHInterfaceHeaderIdTbl.COUNT
      INSERT INTO po_headers_interface
      (interface_header_id, batch_id, interface_source_code, process_code,
       action, org_id, document_type_code, budget_account_segment1, po_header_id,
       approval_status, vendor_id, vendor_site_id, currency_code,
       cpa_reference, created_language, comments, vendor_name, vendor_site_code,
	     vendor_contact_id, ship_to_location_id, bill_to_location_id, fob,
	     freight_terms, terms_id, shipping_control)
      SELECT gIHInterfaceHeaderIdTbl(i), g_PDOI_batch_id, g_interface_source_code, g_process_code,
       gIHActionTbl(i), gIHOrgIdTbl(i), gIHDocumentTypeCodeTbl(i), gIHBudgetAccountSegment1Tbl(i), gIHPoHeaderIdTbl(i),
       gIHApprovalStatusTbl(i), doc.vendor_id, doc.vendor_site_id, gIHCurrencyCodeTbl(i),
       gIHCpaReferenceTbl(i), gIHCreatedLanguageTbl(i), gIHCommentsTbl(i),
       supp.vendor_name, site.vendor_site_code, poh.vendor_contact_id,
	     poh.ship_to_location_id, poh.bill_to_location_id, poh.fob_lookup_code,
	     poh.freight_terms_lookup_code, poh.terms_id, poh.shipping_control
      FROM (
             SELECT gIHVendorIdTbl(i) vendor_id, gIHVendorSiteIdTbl(i) vendor_site_id,
					   gIHCpaReferenceTbl(i) cpa_reference
             FROM DUAL
           ) doc,
           po_vendors supp, po_vendor_sites_all site, po_headers_all poh
      WHERE supp.vendor_id (+) = doc.vendor_id
      AND   site.vendor_site_id (+) = doc.vendor_site_id
	    AND 	poh.po_header_id = doc.cpa_reference;

    l_err_loc := 140;
    IF (gIHInterfaceHeaderIdTbl.COUNT > 0) THEN
      l_err_loc := 150;
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows inserted into po_headers_interface:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 160;
    clearTables(l_action_mode);

    l_err_loc := 170;
    l_action_mode := 'INSERT_INT_LINES';
    FORALL i in 1..gILInterfaceHeaderIdTbl.COUNT
      INSERT INTO po_lines_interface
      (interface_line_id, interface_header_id, process_code, action,
       po_line_id, po_header_id, unit_price,
       uom_code, negotiated_by_preparer_flag, ip_category_id, category_id, category,
       vendor_product_num, supplier_part_auxid, item_description, catalog_name)
      VALUES(gILInterfaceLineIdTbl(i), gILInterfaceHeaderIdTbl(i), g_process_code, gILActionTbl(i),
       gILPoLineIdTbl(i), gILPoHeaderIdTbl(i), gILUnitPriceTbl(i),
       gILUomCodeTbl(i), gILNegByPrepFlagTbl(i), gILIpCategoryIdTbl(i), gILCategoryIdTbl(i), gILCategoryNameTbl(i),
       gILVendorProductNumTbl(i), gILSupplierPartAuxidTbl(i), gILItemDescripionTbl(i), gILCatalogNameTbl(i));

    l_err_loc := 180;
    IF (gILInterfaceHeaderIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows inserted into po_lines_interface:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 190;
    clearTables(l_action_mode);

    l_err_loc := 200;
    l_action_mode := 'INSERT_INT_ATTR_VALS';
    FORALL i in 1..gIAVInterfaceHeaderIdTbl.COUNT
      INSERT INTO po_attr_values_interface
      (interface_attr_values_id, interface_header_id,
       interface_line_id, process_code, action,
       po_line_id, req_template_name, req_template_line_num,
       inventory_item_id, org_id,
       ip_category_id, manufacturer_part_num, thumbnail_image,
       supplier_url,manufacturer_url, attachment_url,
       unspsc, availability, lead_time, picture,
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
       text_base_attribute100, num_base_attribute1, num_base_attribute2,
       num_base_attribute3, num_base_attribute4, num_base_attribute5,
       num_base_attribute6, num_base_attribute7, num_base_attribute8,
       num_base_attribute9, num_base_attribute10, num_base_attribute11,
       num_base_attribute12, num_base_attribute13, num_base_attribute14,
       num_base_attribute15, num_base_attribute16, num_base_attribute17,
       num_base_attribute18, num_base_attribute19, num_base_attribute20,
       num_base_attribute21, num_base_attribute22, num_base_attribute23,
       num_base_attribute24, num_base_attribute25, num_base_attribute26,
       num_base_attribute27, num_base_attribute28, num_base_attribute29,
       num_base_attribute30, num_base_attribute31, num_base_attribute32,
       num_base_attribute33, num_base_attribute34, num_base_attribute35,
       num_base_attribute36, num_base_attribute37, num_base_attribute38,
       num_base_attribute39, num_base_attribute40, num_base_attribute41,
       num_base_attribute42, num_base_attribute43, num_base_attribute44,
       num_base_attribute45, num_base_attribute46, num_base_attribute47,
       num_base_attribute48, num_base_attribute49, num_base_attribute50,
       num_base_attribute51, num_base_attribute52, num_base_attribute53,
       num_base_attribute54, num_base_attribute55, num_base_attribute56,
       num_base_attribute57, num_base_attribute58, num_base_attribute59,
       num_base_attribute60, num_base_attribute61, num_base_attribute62,
       num_base_attribute63, num_base_attribute64, num_base_attribute65,
       num_base_attribute66, num_base_attribute67, num_base_attribute68,
       num_base_attribute69, num_base_attribute70, num_base_attribute71,
       num_base_attribute72, num_base_attribute73, num_base_attribute74,
       num_base_attribute75, num_base_attribute76, num_base_attribute77,
       num_base_attribute78, num_base_attribute79, num_base_attribute80,
       num_base_attribute81, num_base_attribute82, num_base_attribute83,
       num_base_attribute84, num_base_attribute85, num_base_attribute86,
       num_base_attribute87, num_base_attribute88, num_base_attribute89,
       num_base_attribute90, num_base_attribute91, num_base_attribute92,
       num_base_attribute93, num_base_attribute94, num_base_attribute95,
       num_base_attribute96, num_base_attribute97, num_base_attribute98,
       num_base_attribute99, num_base_attribute100, text_cat_attribute1,
       text_cat_attribute2, text_cat_attribute3, text_cat_attribute4,
       text_cat_attribute5, text_cat_attribute6, text_cat_attribute7,
       text_cat_attribute8, text_cat_attribute9, text_cat_attribute10,
       text_cat_attribute11, text_cat_attribute12, text_cat_attribute13,
       text_cat_attribute14, text_cat_attribute15, text_cat_attribute16,
       text_cat_attribute17, text_cat_attribute18, text_cat_attribute19,
       text_cat_attribute20, text_cat_attribute21, text_cat_attribute22,
       text_cat_attribute23, text_cat_attribute24, text_cat_attribute25,
       text_cat_attribute26, text_cat_attribute27, text_cat_attribute28,
       text_cat_attribute29, text_cat_attribute30, text_cat_attribute31,
       text_cat_attribute32, text_cat_attribute33, text_cat_attribute34,
       text_cat_attribute35, text_cat_attribute36, text_cat_attribute37,
       text_cat_attribute38, text_cat_attribute39, text_cat_attribute40,
       text_cat_attribute41, text_cat_attribute42, text_cat_attribute43,
       text_cat_attribute44, text_cat_attribute45, text_cat_attribute46,
       text_cat_attribute47, text_cat_attribute48, text_cat_attribute49,
       text_cat_attribute50, num_cat_attribute1, num_cat_attribute2,
       num_cat_attribute3, num_cat_attribute4, num_cat_attribute5,
       num_cat_attribute6, num_cat_attribute7, num_cat_attribute8,
       num_cat_attribute9, num_cat_attribute10, num_cat_attribute11,
       num_cat_attribute12, num_cat_attribute13, num_cat_attribute14,
       num_cat_attribute15, num_cat_attribute16, num_cat_attribute17,
       num_cat_attribute18, num_cat_attribute19, num_cat_attribute20,
       num_cat_attribute21, num_cat_attribute22, num_cat_attribute23,
       num_cat_attribute24, num_cat_attribute25, num_cat_attribute26,
       num_cat_attribute27, num_cat_attribute28, num_cat_attribute29,
       num_cat_attribute30, num_cat_attribute31, num_cat_attribute32,
       num_cat_attribute33, num_cat_attribute34, num_cat_attribute35,
       num_cat_attribute36, num_cat_attribute37, num_cat_attribute38,
       num_cat_attribute39, num_cat_attribute40, num_cat_attribute41,
       num_cat_attribute42, num_cat_attribute43, num_cat_attribute44,
       num_cat_attribute45, num_cat_attribute46, num_cat_attribute47,
       num_cat_attribute48, num_cat_attribute49, num_cat_attribute50)
      SELECT po_attr_values_interface_s.NEXTVAL, gIAVInterfaceHeaderIdTbl(i),
             gIAVInterfaceLineIdTbl(i), g_process_code, gIAVActionTbl(i),
             gIAVPoLineIdTbl(i), gIAVReqTemplateNameTbl(i), gIAVReqTemplateLineNumTbl(i),
             gIAVInventoryItemIdTbl(i), gIAVOrgIdTbl(i),
             baseAtt.primary_category_id, baseAtt.manufacturer_part_num, baseAtt.thumbnail_image,
             baseAtt.supplier_url, baseAtt.manufacturer_url, baseAtt.attachment_url,
             baseAtt.unspsc_code, baseAtt.availability, baseAtt.lead_time, baseAtt.picture,
             baseAtt.text_base_attribute1, baseAtt.text_base_attribute2, baseAtt.text_base_attribute3,
             baseAtt.text_base_attribute4, baseAtt.text_base_attribute5, baseAtt.text_base_attribute6,
             baseAtt.text_base_attribute7, baseAtt.text_base_attribute8, baseAtt.text_base_attribute9,
             baseAtt.text_base_attribute10, baseAtt.text_base_attribute11, baseAtt.text_base_attribute12,
             baseAtt.text_base_attribute13, baseAtt.text_base_attribute14, baseAtt.text_base_attribute15,
             baseAtt.text_base_attribute16, baseAtt.text_base_attribute17, baseAtt.text_base_attribute18,
             baseAtt.text_base_attribute19, baseAtt.text_base_attribute20, baseAtt.text_base_attribute21,
             baseAtt.text_base_attribute22, baseAtt.text_base_attribute23, baseAtt.text_base_attribute24,
             baseAtt.text_base_attribute25, baseAtt.text_base_attribute26, baseAtt.text_base_attribute27,
             baseAtt.text_base_attribute28, baseAtt.text_base_attribute29, baseAtt.text_base_attribute30,
             baseAtt.text_base_attribute31, baseAtt.text_base_attribute32, baseAtt.text_base_attribute33,
             baseAtt.text_base_attribute34, baseAtt.text_base_attribute35, baseAtt.text_base_attribute36,
             baseAtt.text_base_attribute37, baseAtt.text_base_attribute38, baseAtt.text_base_attribute39,
             baseAtt.text_base_attribute40, baseAtt.text_base_attribute41, baseAtt.text_base_attribute42,
             baseAtt.text_base_attribute43, baseAtt.text_base_attribute44, baseAtt.text_base_attribute45,
             baseAtt.text_base_attribute46, baseAtt.text_base_attribute47, baseAtt.text_base_attribute48,
             baseAtt.text_base_attribute49, baseAtt.text_base_attribute50, baseAtt.text_base_attribute51,
             baseAtt.text_base_attribute52, baseAtt.text_base_attribute53, baseAtt.text_base_attribute54,
             baseAtt.text_base_attribute55, baseAtt.text_base_attribute56, baseAtt.text_base_attribute57,
             baseAtt.text_base_attribute58, baseAtt.text_base_attribute59, baseAtt.text_base_attribute60,
             baseAtt.text_base_attribute61, baseAtt.text_base_attribute62, baseAtt.text_base_attribute63,
             baseAtt.text_base_attribute64, baseAtt.text_base_attribute65, baseAtt.text_base_attribute66,
             baseAtt.text_base_attribute67, baseAtt.text_base_attribute68, baseAtt.text_base_attribute69,
             baseAtt.text_base_attribute70, baseAtt.text_base_attribute71, baseAtt.text_base_attribute72,
             baseAtt.text_base_attribute73, baseAtt.text_base_attribute74, baseAtt.text_base_attribute75,
             baseAtt.text_base_attribute76, baseAtt.text_base_attribute77, baseAtt.text_base_attribute78,
             baseAtt.text_base_attribute79, baseAtt.text_base_attribute80, baseAtt.text_base_attribute81,
             baseAtt.text_base_attribute82, baseAtt.text_base_attribute83, baseAtt.text_base_attribute84,
             baseAtt.text_base_attribute85, baseAtt.text_base_attribute86, baseAtt.text_base_attribute87,
             baseAtt.text_base_attribute88, baseAtt.text_base_attribute89, baseAtt.text_base_attribute90,
             baseAtt.text_base_attribute91, baseAtt.text_base_attribute92, baseAtt.text_base_attribute93,
             baseAtt.text_base_attribute94, baseAtt.text_base_attribute95, baseAtt.text_base_attribute96,
             baseAtt.text_base_attribute97, baseAtt.text_base_attribute98, baseAtt.text_base_attribute99,
             baseAtt.text_base_attribute100, baseAtt.num_base_attribute1, baseAtt.num_base_attribute2,
             baseAtt.num_base_attribute3, baseAtt.num_base_attribute4, baseAtt.num_base_attribute5,
             baseAtt.num_base_attribute6, baseAtt.num_base_attribute7, baseAtt.num_base_attribute8,
             baseAtt.num_base_attribute9, baseAtt.num_base_attribute10, baseAtt.num_base_attribute11,
             baseAtt.num_base_attribute12, baseAtt.num_base_attribute13, baseAtt.num_base_attribute14,
             baseAtt.num_base_attribute15, baseAtt.num_base_attribute16, baseAtt.num_base_attribute17,
             baseAtt.num_base_attribute18, baseAtt.num_base_attribute19, baseAtt.num_base_attribute20,
             baseAtt.num_base_attribute21, baseAtt.num_base_attribute22, baseAtt.num_base_attribute23,
             baseAtt.num_base_attribute24, baseAtt.num_base_attribute25, baseAtt.num_base_attribute26,
             baseAtt.num_base_attribute27, baseAtt.num_base_attribute28, baseAtt.num_base_attribute29,
             baseAtt.num_base_attribute30, baseAtt.num_base_attribute31, baseAtt.num_base_attribute32,
             baseAtt.num_base_attribute33, baseAtt.num_base_attribute34, baseAtt.num_base_attribute35,
             baseAtt.num_base_attribute36, baseAtt.num_base_attribute37, baseAtt.num_base_attribute38,
             baseAtt.num_base_attribute39, baseAtt.num_base_attribute40, baseAtt.num_base_attribute41,
             baseAtt.num_base_attribute42, baseAtt.num_base_attribute43, baseAtt.num_base_attribute44,
             baseAtt.num_base_attribute45, baseAtt.num_base_attribute46, baseAtt.num_base_attribute47,
             baseAtt.num_base_attribute48, baseAtt.num_base_attribute49, baseAtt.num_base_attribute50,
             baseAtt.num_base_attribute51, baseAtt.num_base_attribute52, baseAtt.num_base_attribute53,
             baseAtt.num_base_attribute54, baseAtt.num_base_attribute55, baseAtt.num_base_attribute56,
             baseAtt.num_base_attribute57, baseAtt.num_base_attribute58, baseAtt.num_base_attribute59,
             baseAtt.num_base_attribute60, baseAtt.num_base_attribute61, baseAtt.num_base_attribute62,
             baseAtt.num_base_attribute63, baseAtt.num_base_attribute64, baseAtt.num_base_attribute65,
             baseAtt.num_base_attribute66, baseAtt.num_base_attribute67, baseAtt.num_base_attribute68,
             baseAtt.num_base_attribute69, baseAtt.num_base_attribute70, baseAtt.num_base_attribute71,
             baseAtt.num_base_attribute72, baseAtt.num_base_attribute73, baseAtt.num_base_attribute74,
             baseAtt.num_base_attribute75, baseAtt.num_base_attribute76, baseAtt.num_base_attribute77,
             baseAtt.num_base_attribute78, baseAtt.num_base_attribute79, baseAtt.num_base_attribute80,
             baseAtt.num_base_attribute81, baseAtt.num_base_attribute82, baseAtt.num_base_attribute83,
             baseAtt.num_base_attribute84, baseAtt.num_base_attribute85, baseAtt.num_base_attribute86,
             baseAtt.num_base_attribute87, baseAtt.num_base_attribute88, baseAtt.num_base_attribute89,
             baseAtt.num_base_attribute90, baseAtt.num_base_attribute91, baseAtt.num_base_attribute92,
             baseAtt.num_base_attribute93, baseAtt.num_base_attribute94, baseAtt.num_base_attribute95,
             baseAtt.num_base_attribute96, baseAtt.num_base_attribute97, baseAtt.num_base_attribute98,
             baseAtt.num_base_attribute99, baseAtt.num_base_attribute100, catAtt.text_cat_attribute1,
             catAtt.text_cat_attribute2, catAtt.text_cat_attribute3, catAtt.text_cat_attribute4,
             catAtt.text_cat_attribute5, catAtt.text_cat_attribute6, catAtt.text_cat_attribute7,
             catAtt.text_cat_attribute8, catAtt.text_cat_attribute9, catAtt.text_cat_attribute10,
             catAtt.text_cat_attribute11, catAtt.text_cat_attribute12, catAtt.text_cat_attribute13,
             catAtt.text_cat_attribute14, catAtt.text_cat_attribute15, catAtt.text_cat_attribute16,
             catAtt.text_cat_attribute17, catAtt.text_cat_attribute18, catAtt.text_cat_attribute19,
             catAtt.text_cat_attribute20, catAtt.text_cat_attribute21, catAtt.text_cat_attribute22,
             catAtt.text_cat_attribute23, catAtt.text_cat_attribute24, catAtt.text_cat_attribute25,
             catAtt.text_cat_attribute26, catAtt.text_cat_attribute27, catAtt.text_cat_attribute28,
             catAtt.text_cat_attribute29, catAtt.text_cat_attribute30, catAtt.text_cat_attribute31,
             catAtt.text_cat_attribute32, catAtt.text_cat_attribute33, catAtt.text_cat_attribute34,
             catAtt.text_cat_attribute35, catAtt.text_cat_attribute36, catAtt.text_cat_attribute37,
             catAtt.text_cat_attribute38, catAtt.text_cat_attribute39, catAtt.text_cat_attribute40,
             catAtt.text_cat_attribute41, catAtt.text_cat_attribute42, catAtt.text_cat_attribute43,
             catAtt.text_cat_attribute44, catAtt.text_cat_attribute45, catAtt.text_cat_attribute46,
             catAtt.text_cat_attribute47, catAtt.text_cat_attribute48, catAtt.text_cat_attribute49,
             catAtt.text_cat_attribute50, catAtt.num_cat_attribute1, catAtt.num_cat_attribute2,
             catAtt.num_cat_attribute3, catAtt.num_cat_attribute4, catAtt.num_cat_attribute5,
             catAtt.num_cat_attribute6, catAtt.num_cat_attribute7, catAtt.num_cat_attribute8,
             catAtt.num_cat_attribute9, catAtt.num_cat_attribute10, catAtt.num_cat_attribute11,
             catAtt.num_cat_attribute12, catAtt.num_cat_attribute13, catAtt.num_cat_attribute14,
             catAtt.num_cat_attribute15, catAtt.num_cat_attribute16, catAtt.num_cat_attribute17,
             catAtt.num_cat_attribute18, catAtt.num_cat_attribute19, catAtt.num_cat_attribute20,
             catAtt.num_cat_attribute21, catAtt.num_cat_attribute22, catAtt.num_cat_attribute23,
             catAtt.num_cat_attribute24, catAtt.num_cat_attribute25, catAtt.num_cat_attribute26,
             catAtt.num_cat_attribute27, catAtt.num_cat_attribute28, catAtt.num_cat_attribute29,
             catAtt.num_cat_attribute30, catAtt.num_cat_attribute31, catAtt.num_cat_attribute32,
             catAtt.num_cat_attribute33, catAtt.num_cat_attribute34, catAtt.num_cat_attribute35,
             catAtt.num_cat_attribute36, catAtt.num_cat_attribute37, catAtt.num_cat_attribute38,
             catAtt.num_cat_attribute39, catAtt.num_cat_attribute40, catAtt.num_cat_attribute41,
             catAtt.num_cat_attribute42, catAtt.num_cat_attribute43, catAtt.num_cat_attribute44,
             catAtt.num_cat_attribute45, catAtt.num_cat_attribute46, catAtt.num_cat_attribute47,
             catAtt.num_cat_attribute48, catAtt.num_cat_attribute49, catAtt.num_cat_attribute50
      FROM icx_cat_items_tlp baseAtt, icx_cat_ext_items_tlp catAtt
      WHERE baseAtt.rt_item_id = catAtt.rt_item_id
      AND baseAtt.language = catAtt.language
      AND baseAtt.rt_item_id = gIAVRtItemIdTbl(i)
      AND baseAtt.language = gIAVLanguageTbl(i);

    l_err_loc := 210;
    IF (gIAVInterfaceHeaderIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows inserted into po_attr_values_interface:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 220;
    clearTables(l_action_mode);

    l_err_loc := 230;
    l_action_mode := 'INSERT_INT_ATTR_VALS_TLP';
    FORALL i in 1..gIAVTInterfaceHeaderIdTbl.COUNT
      INSERT INTO po_attr_values_tlp_interface
      (interface_attr_values_tlp_id, interface_header_id,
       interface_line_id, action, process_code,
       po_line_id, req_template_name, req_template_line_num,
       inventory_item_id, org_id, language,
       ip_category_id,  description, manufacturer,
       comments, alias, long_description,
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
       tl_text_base_attribute100, tl_text_cat_attribute1, tl_text_cat_attribute2,
       tl_text_cat_attribute3, tl_text_cat_attribute4, tl_text_cat_attribute5,
       tl_text_cat_attribute6, tl_text_cat_attribute7, tl_text_cat_attribute8,
       tl_text_cat_attribute9, tl_text_cat_attribute10, tl_text_cat_attribute11,
       tl_text_cat_attribute12, tl_text_cat_attribute13, tl_text_cat_attribute14,
       tl_text_cat_attribute15, tl_text_cat_attribute16, tl_text_cat_attribute17,
       tl_text_cat_attribute18, tl_text_cat_attribute19, tl_text_cat_attribute20,
       tl_text_cat_attribute21, tl_text_cat_attribute22, tl_text_cat_attribute23,
       tl_text_cat_attribute24, tl_text_cat_attribute25, tl_text_cat_attribute26,
       tl_text_cat_attribute27, tl_text_cat_attribute28, tl_text_cat_attribute29,
       tl_text_cat_attribute30, tl_text_cat_attribute31, tl_text_cat_attribute32,
       tl_text_cat_attribute33, tl_text_cat_attribute34, tl_text_cat_attribute35,
       tl_text_cat_attribute36, tl_text_cat_attribute37, tl_text_cat_attribute38,
       tl_text_cat_attribute39, tl_text_cat_attribute40, tl_text_cat_attribute41,
       tl_text_cat_attribute42, tl_text_cat_attribute43, tl_text_cat_attribute44,
       tl_text_cat_attribute45, tl_text_cat_attribute46, tl_text_cat_attribute47,
       tl_text_cat_attribute48, tl_text_cat_attribute49, tl_text_cat_attribute50)
      SELECT po_attr_values_tlp_interface_s.NEXTVAL, gIAVTInterfaceHeaderIdTbl(i),
             gIAVTInterfaceLineIdTbl(i), gIAVTActionTbl(i), g_process_code,
             gIAVTPoLineIdTbl(i), gIAVTReqTemplateNameTbl(i), gIAVTReqTemplateLineNumTbl(i),
             gIAVTInventoryItemIdTbl(i), gIAVTOrgIdTbl(i), gIAVTLanguageTbl(i), baseAtt.primary_category_id,
      --       DECODE(gIAVTCheckDescUpdateTbl(i), ICX_CAT_UTIL_PVT.g_update_description, SUBSTRB(baseAtt.description, 1, 240), NULL),
             SUBSTRB(baseAtt.description, 1, 240),
             baseAtt.manufacturer, baseAtt.comments, baseAtt.alias, baseAtt.long_description,
             baseAtt.tl_text_base_attribute1, baseAtt.tl_text_base_attribute2, baseAtt.tl_text_base_attribute3,
             baseAtt.tl_text_base_attribute4, baseAtt.tl_text_base_attribute5, baseAtt.tl_text_base_attribute6,
             baseAtt.tl_text_base_attribute7, baseAtt.tl_text_base_attribute8, baseAtt.tl_text_base_attribute9,
             baseAtt.tl_text_base_attribute10, baseAtt.tl_text_base_attribute11, baseAtt.tl_text_base_attribute12,
             baseAtt.tl_text_base_attribute13, baseAtt.tl_text_base_attribute14, baseAtt.tl_text_base_attribute15,
             baseAtt.tl_text_base_attribute16, baseAtt.tl_text_base_attribute17, baseAtt.tl_text_base_attribute18,
             baseAtt.tl_text_base_attribute19, baseAtt.tl_text_base_attribute20, baseAtt.tl_text_base_attribute21,
             baseAtt.tl_text_base_attribute22, baseAtt.tl_text_base_attribute23, baseAtt.tl_text_base_attribute24,
             baseAtt.tl_text_base_attribute25, baseAtt.tl_text_base_attribute26, baseAtt.tl_text_base_attribute27,
             baseAtt.tl_text_base_attribute28, baseAtt.tl_text_base_attribute29, baseAtt.tl_text_base_attribute30,
             baseAtt.tl_text_base_attribute31, baseAtt.tl_text_base_attribute32, baseAtt.tl_text_base_attribute33,
             baseAtt.tl_text_base_attribute34, baseAtt.tl_text_base_attribute35, baseAtt.tl_text_base_attribute36,
             baseAtt.tl_text_base_attribute37, baseAtt.tl_text_base_attribute38, baseAtt.tl_text_base_attribute39,
             baseAtt.tl_text_base_attribute40, baseAtt.tl_text_base_attribute41, baseAtt.tl_text_base_attribute42,
             baseAtt.tl_text_base_attribute43, baseAtt.tl_text_base_attribute44, baseAtt.tl_text_base_attribute45,
             baseAtt.tl_text_base_attribute46, baseAtt.tl_text_base_attribute47, baseAtt.tl_text_base_attribute48,
             baseAtt.tl_text_base_attribute49, baseAtt.tl_text_base_attribute50, baseAtt.tl_text_base_attribute51,
             baseAtt.tl_text_base_attribute52, baseAtt.tl_text_base_attribute53, baseAtt.tl_text_base_attribute54,
             baseAtt.tl_text_base_attribute55, baseAtt.tl_text_base_attribute56, baseAtt.tl_text_base_attribute57,
             baseAtt.tl_text_base_attribute58, baseAtt.tl_text_base_attribute59, baseAtt.tl_text_base_attribute60,
             baseAtt.tl_text_base_attribute61, baseAtt.tl_text_base_attribute62, baseAtt.tl_text_base_attribute63,
             baseAtt.tl_text_base_attribute64, baseAtt.tl_text_base_attribute65, baseAtt.tl_text_base_attribute66,
             baseAtt.tl_text_base_attribute67, baseAtt.tl_text_base_attribute68, baseAtt.tl_text_base_attribute69,
             baseAtt.tl_text_base_attribute70, baseAtt.tl_text_base_attribute71, baseAtt.tl_text_base_attribute72,
             baseAtt.tl_text_base_attribute73, baseAtt.tl_text_base_attribute74, baseAtt.tl_text_base_attribute75,
             baseAtt.tl_text_base_attribute76, baseAtt.tl_text_base_attribute77, baseAtt.tl_text_base_attribute78,
             baseAtt.tl_text_base_attribute79, baseAtt.tl_text_base_attribute80, baseAtt.tl_text_base_attribute81,
             baseAtt.tl_text_base_attribute82, baseAtt.tl_text_base_attribute83, baseAtt.tl_text_base_attribute84,
             baseAtt.tl_text_base_attribute85, baseAtt.tl_text_base_attribute86, baseAtt.tl_text_base_attribute87,
             baseAtt.tl_text_base_attribute88, baseAtt.tl_text_base_attribute89, baseAtt.tl_text_base_attribute90,
             baseAtt.tl_text_base_attribute91, baseAtt.tl_text_base_attribute92, baseAtt.tl_text_base_attribute93,
             baseAtt.tl_text_base_attribute94, baseAtt.tl_text_base_attribute95, baseAtt.tl_text_base_attribute96,
             baseAtt.tl_text_base_attribute97, baseAtt.tl_text_base_attribute98, baseAtt.tl_text_base_attribute99,
             baseAtt.tl_text_base_attribute100, catAtt.tl_text_cat_attribute1, catAtt.tl_text_cat_attribute2,
             catAtt.tl_text_cat_attribute3, catAtt.tl_text_cat_attribute4, catAtt.tl_text_cat_attribute5,
             catAtt.tl_text_cat_attribute6, catAtt.tl_text_cat_attribute7, catAtt.tl_text_cat_attribute8,
             catAtt.tl_text_cat_attribute9, catAtt.tl_text_cat_attribute10, catAtt.tl_text_cat_attribute11,
             catAtt.tl_text_cat_attribute12, catAtt.tl_text_cat_attribute13, catAtt.tl_text_cat_attribute14,
             catAtt.tl_text_cat_attribute15, catAtt.tl_text_cat_attribute16, catAtt.tl_text_cat_attribute17,
             catAtt.tl_text_cat_attribute18, catAtt.tl_text_cat_attribute19, catAtt.tl_text_cat_attribute20,
             catAtt.tl_text_cat_attribute21, catAtt.tl_text_cat_attribute22, catAtt.tl_text_cat_attribute23,
             catAtt.tl_text_cat_attribute24, catAtt.tl_text_cat_attribute25, catAtt.tl_text_cat_attribute26,
             catAtt.tl_text_cat_attribute27, catAtt.tl_text_cat_attribute28, catAtt.tl_text_cat_attribute29,
             catAtt.tl_text_cat_attribute30, catAtt.tl_text_cat_attribute31, catAtt.tl_text_cat_attribute32,
             catAtt.tl_text_cat_attribute33, catAtt.tl_text_cat_attribute34, catAtt.tl_text_cat_attribute35,
             catAtt.tl_text_cat_attribute36, catAtt.tl_text_cat_attribute37, catAtt.tl_text_cat_attribute38,
             catAtt.tl_text_cat_attribute39, catAtt.tl_text_cat_attribute40, catAtt.tl_text_cat_attribute41,
             catAtt.tl_text_cat_attribute42, catAtt.tl_text_cat_attribute43, catAtt.tl_text_cat_attribute44,
             catAtt.tl_text_cat_attribute45, catAtt.tl_text_cat_attribute46, catAtt.tl_text_cat_attribute47,
             catAtt.tl_text_cat_attribute48, catAtt.tl_text_cat_attribute49, catAtt.tl_text_cat_attribute50
      FROM icx_cat_items_tlp baseAtt, icx_cat_ext_items_tlp catAtt
      WHERE baseAtt.rt_item_id = catAtt.rt_item_id
      AND baseAtt.language = catAtt.language
      AND baseAtt.rt_item_id = gIAVTRtItemIdTbl(i)
      AND baseAtt.language = gIAVTLanguageTbl(i);

    l_err_loc := 240;
    IF (gIAVTInterfaceHeaderIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows inserted into po_attr_values_tlp_interface:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 250;
    clearTables(l_action_mode);

    l_err_loc := 260;
    l_action_mode := 'INSERT_R12_UPGRADE';
    FORALL i in 1..gIRURtItemIdTbl.COUNT
      INSERT INTO icx_cat_r12_upgrade
      (supplier_site_id, currency, cpa_reference,
       price_contract_id, src_contract_id, po_category_id,
       rt_item_id, po_interface_header_id, po_interface_line_id,
       created_language,
       last_update_login, last_updated_by, last_update_date,
       created_by, creation_date, internal_request_id, request_id,
       program_application_id, program_id, program_login_id)
      VALUES
      (gIRUSupplierSiteIdTbl(i), gIRUCurrencyTbl(i), gIRUCpaReferenceTbl(i),
       gIRUPriceContractIdTbl(i), gIRUSrcContractIdTbl(i), gIRUPoCategoryIdTbl(i),
       gIRURtItemIdTbl(i), gIRUPoInterfaceHeaderIdTbl(i), gIRUPoInterfaceLineIdTbl(i),
       gIRUCreatedLanguageTbl(i),
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
       ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id);

    l_err_loc := 270;
    IF (gIRURtItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows inserted into icx_cat_r12_upgrade:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 280;
    clearTables(l_action_mode);

    l_err_loc := 290;
    l_action_mode := 'UPDATE_R12_UPGRADE';
    FORALL i in 1..gURURtItemIdTbl.COUNT
      UPDATE icx_cat_r12_upgrade
      SET po_interface_header_id = gURUPoInterfaceHeaderIdTbl(i),
          po_interface_line_id = gURUPoInterfaceLineIdTbl(i),
          po_category_id = gURUPoCategoryIdTbl(i),
          cpa_reference = gURUCpaReferenceTbl(i),
          price_contract_id = gURUPriceContractIdTbl(i),
          src_contract_id = gURUSrcContractIdTbl(i),
          po_header_id = gURUPoHeaderIdTbl(i),
          po_line_id = gURUPoLineIdTbl(i),
          created_language = gURUCreatedLanguageTbl(i),
          last_update_login = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
          last_updated_by = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
          last_update_date = sysdate,
          internal_request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
          request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
          program_application_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
          program_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
          program_login_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id
      WHERE po_interface_line_id = gURUOldPoInterfaceLineIdTbl(i)
      AND   rt_item_id = gURURtItemIdTbl(i);

    l_err_loc := 300;
    IF (gURURtItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows updated in icx_cat_r12_upgrade:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 310;
    clearTables(l_action_mode);

    l_err_loc := 320;
    l_action_mode := 'DELETE_R12_UPGRADE';
    FORALL i in 1..gDRURtItemIdTbl.COUNT
      DELETE FROM icx_cat_r12_upgrade
      WHERE rt_item_id = gDRURtItemIdTbl(i)
      AND   po_interface_header_id = gDRUPoInterfaceHeaderIdTbl(i)
      AND   po_interface_line_id = gDRUPoInterfaceLineIdTbl(i);

    l_err_loc := 330;
    IF (gDRURtItemIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows deleted from icx_cat_r12_upgrade:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 340;
    clearTables(l_action_mode);

    l_err_loc := 350;
    l_action_mode := 'INSERT_FAV_LINES_CATALOG';
    FORALL i in 1..gIFLCFavoriteListIdTbl.COUNT
      INSERT INTO icx_cat_fav_list_lines_tlp
      (
        favorite_list_line_id, favorite_list_id,
        last_update_date, last_updated_by, last_update_login,
        creation_date, created_by,
        po_line_id, inventory_item_id,
        item_description, rfq_required_flag,
        req_template_name, req_template_line_num,
        org_id, language, source_type
      )
      SELECT
        gIFLCNewFavoriteListLineIdTbl(i), gIFLCFavoriteListIdTbl(i),
        fav.last_update_date, fav.last_updated_by, fav.last_update_login,
        NVL(fav.creation_date, fav.last_update_date),
        NVL(fav.created_by, fav.last_updated_by),
        NVL(fav.source_doc_line_id, -2) po_line_id,
        NVL(fav.item_id, -2) inventory_item_id,
        fav.item_description, fav.rfq_required_flag,
        NVL(fav.template_name, '-2') req_template_name,
        NVL(fav.template_line_num, -2) req_template_line_num,
        gIFLCOrgIdTbl(i), gIFLCLanguageTbl(i),
        gIFLCSourceTypeTbl(i)
      FROM por_favorite_list_lines fav
      WHERE favorite_list_line_id = gIFLCOldFavoriteListLineIdTbl(i)
      AND   favorite_list_id = gIFLCFavoriteListIdTbl(i);

    l_err_loc := 360;
    IF (gIFLCFavoriteListIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows inserted into icx_cat_fav_list_lines_tlp for catalog items:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 370;
    clearTables(l_action_mode);

    l_err_loc := 380;
    l_action_mode := 'INSERT_FAV_LINES_OTHER';
    FORALL i in 1..gIFLOFavoriteListIdTbl.COUNT
      INSERT INTO icx_cat_fav_list_lines_tlp
      (
        favorite_list_line_id, favorite_list_id,
        last_update_date, last_updated_by, last_update_login,
        creation_date, created_by,
        po_header_id, po_line_id, inventory_item_id,
        item_description, line_type_id,
        item_revision, po_category_id, unit_meas_lookup_code,
        unit_price, suggested_vendor_id, suggested_vendor_name,
        suggested_vendor_site_id, suggested_vendor_site,
        suggested_vendor_contact_id, suggested_vendor_contact,
        supplier_url, suggested_buyer_id,
        suggested_buyer, supplier_item_num,
        manufacturer_id, manufacturer_name, manufacturer_part_number,
        rfq_required_flag, attribute_category,
        attribute1, attribute2, attribute3, attribute4, attribute5,
        attribute6, attribute7, attribute8, attribute9, attribute10,
        attribute11, attribute12, attribute13, attribute14, attribute15,
        po_category_name, suggested_vendor_contact_phone, new_supplier,
        req_template_name, req_template_line_num,
        currency, rate_type, rate, rate_date,
        noncat_template_id, suggested_vendor_contact_fax,
        suggested_vendor_contact_email,
        negotiated_by_preparer_flag, thumbnail_image,
        org_id, language, source_type, amount
      )
      SELECT
        gIFLONewFavoriteListLineIdTbl(i), gIFLOFavoriteListIdTbl(i),
        fav.last_update_date, fav.last_updated_by, fav.last_update_login,
        NVL(fav.creation_date, fav.last_update_date),
        NVL(fav.created_by, fav.last_updated_by),
        fav.source_doc_header_id po_header_id,
        fav.source_doc_line_id po_line_id,
        fav.item_id inventory_item_id,
        fav.item_description,
        NVL(fav.line_type_id, 1) line_type_id,
        fav.item_revision, fav.category_id, fav.unit_meas_lookup_code,
        DECODE(NVL(line_types.order_type_lookup_code, 'QUANTITY'),
               'QUANTITY', fav.unit_price, NULL) unit_price,
        fav.suggested_vendor_id, fav.suggested_vendor_name,
        fav.suggested_vendor_site_id, fav.suggested_vendor_site,
        fav.suggested_vendor_contact_id, fav.suggested_vendor_contact,
        fav.supplier_url, fav.suggested_buyer_id,
        fav.suggested_buyer, fav.supplier_item_num,
        fav.manufacturer_id, fav.manufacturer_name, fav.manufacturer_part_number,
        fav.rfq_required_flag, fav.attribute_category,
        fav.attribute1, fav.attribute2, fav.attribute3, fav.attribute4, fav.attribute5,
        fav.attribute6, fav.attribute7, fav.attribute8, fav.attribute9, fav.attribute10,
        fav.attribute11, fav.attribute12, fav.attribute13, fav.attribute14, fav.attribute15,
        fav.category, fav.suggested_vendor_contact_phone, fav.new_supplier,
        fav.template_name req_template_name,
        fav.template_line_num req_template_line_num,
        NVL(fav.currency, gsob.currency_code) currency,
        fav.rate_type, fav.rate, fav.rate_date,
        fav.noncat_template_id, fav.suggested_vendor_contact_fax,
        fav.suggested_vendor_contact_email,
        fav.negotiated_by_preparer_flag, fav.thumbnail_image,
        gIFLOOrgIdTbl(i), gIFLOLanguageTbl(i),
        NVL(fav.item_type, 'NONCATALOG') source_type,
        DECODE(NVL(line_types.order_type_lookup_code, 'QUANTITY'),
               'QUANTITY', NULL, fav.unit_price) amount
      FROM por_favorite_list_lines fav, po_line_types_b line_types,
           financials_system_params_all fsp, gl_sets_of_books gsob
      WHERE favorite_list_line_id = gIFLOOldFavoriteListLineIdTbl(i)
      AND   favorite_list_id = gIFLOFavoriteListIdTbl(i)
      AND   fav.line_type_id = line_types.line_type_id (+)
      AND   fsp.org_id = gIFLOOrgIdTbl(i)
      AND   fsp.set_of_books_id = gsob.set_of_books_id;

    l_err_loc := 390;
    IF (gIFLOFavoriteListIdTbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows inserted into icx_cat_fav_list_lines_tlp for other items:' ||SQL%ROWCOUNT);
      END IF;
    END IF;

    l_err_loc := 400;
    clearTables(l_action_mode);

    l_err_loc := 440;
    COMMIT;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Commit done.');
    END IF;

  END IF; --(p_mode = 'OUTLOOP' OR g_total_row_count     >= ICX_CAT_UTIL_PVT.g_batch_size)
EXCEPTION
  WHEN OTHERS THEN
    logPLSQLTableRow(l_api_name, FND_LOG.LEVEL_UNEXPECTED, SQL%ROWCOUNT+1, l_action_mode);
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END populatePOInterfaceTables;

PROCEDURE openBlanketsAndQuotesHdrsCsr
(       p_start_po_header_id            IN NUMBER                       ,
        p_blanketAndQuoteHdrs_csr       IN OUT NOCOPY g_csr_type
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openBlanketsAndQuotesHdrsCsr';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  --No need of getting Hdrs with price_type=GLOBAL_AGREEMENT because
  --these are only for enabled orgs.  For enabled orgs we don't need to
  --populate the attribute and attribute values tlp
  IF (g_extract_last_run_date IS NULL) THEN
    OPEN p_blanketAndQuoteHdrs_csr FOR
      SELECT distinct p.contract_id po_header_id, p.price_type, p.org_id
      FROM   icx_cat_item_prices p
      WHERE  p.price_type IN ('BLANKET', 'QUOTATION')
      AND    p.contract_id >= p_start_po_header_id
      ORDER BY p.contract_id;
  ELSE
    l_err_loc := 120;
    OPEN p_blanketAndQuoteHdrs_csr FOR
      SELECT distinct p.contract_id po_header_id, p.price_type, p.org_id
      FROM   icx_cat_item_prices p, icx_cat_items_tlp itemtlp,
             icx_cat_items_b itemsb, icx_cat_ext_items_tlp exttlp
      WHERE  p.price_type IN ('BLANKET', 'QUOTATION')
      AND    p.contract_id >= p_start_po_header_id
      AND    itemtlp.rt_item_id = p.rt_item_id
      AND    itemsb.rt_item_id = p.rt_item_id
      AND    itemtlp.rt_item_id = exttlp.rt_item_id
      AND    itemtlp.language = exttlp.language
      AND    (itemsb.last_update_date > g_extract_last_run_date
              OR itemtlp.last_update_date > g_extract_last_run_date
              OR exttlp.last_update_date > g_extract_last_run_date
              OR p.last_update_date > g_extract_last_run_date)
      ORDER BY p.contract_id;
  END IF;

  l_err_loc := 130;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openBlanketsAndQuotesHdrsCsr;

PROCEDURE openBlanketsAndQuotesLinesCsr
(       p_start_po_line_id              IN NUMBER                       ,
        p_blanketAndQuoteLines_csr      IN OUT NOCOPY g_csr_type
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openBlanketsAndQuotesLinesCsr';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  --No need of getting lines with price_type=GLOBAL_AGREEMENT because
  --these are only for enabled orgs.  For enabled orgs we don't need to
  --populate the attribute and attribute values tlp
  IF (g_extract_last_run_date IS NULL) THEN
    OPEN p_blanketAndQuoteLines_csr FOR
      SELECT p.rt_item_id, itemtlp.language, p.price_type,
             phi.interface_header_id, p.contract_id po_header_id, p.contract_line_id po_line_id,
             p.inventory_item_id, p.org_id,
             DECODE(itemtlp.supplier_part_auxid, '##NULL##', null, itemtlp.supplier_part_auxid),
             itemsb.catalog_name, itemtlp.primary_category_id,
             getPOAttrValuesTLPAction(p.contract_line_id, '-2' ,-2, p.org_id, itemtlp.language)
      FROM   icx_cat_item_prices p, icx_cat_items_tlp itemtlp,
             icx_cat_items_b itemsb, po_headers_interface phi
      WHERE  p.price_type IN ('BLANKET', 'QUOTATION')
      AND    p.contract_line_id >= p_start_po_line_id
      AND    itemtlp.rt_item_id = p.rt_item_id
      AND    itemsb.rt_item_id = p.rt_item_id
      AND    p.contract_id = phi.po_header_id
      AND    phi.batch_id = g_PDOI_batch_id
      ORDER BY p.contract_line_id, p.rt_item_id, itemtlp.language;
  ELSE
    l_err_loc := 120;
    OPEN p_blanketAndQuoteLines_csr FOR
      SELECT p.rt_item_id, itemtlp.language, p.price_type,
             phi.interface_header_id, p.contract_id po_header_id, p.contract_line_id po_line_id,
             p.inventory_item_id, p.org_id,
             DECODE(itemtlp.supplier_part_auxid, '##NULL##', null, itemtlp.supplier_part_auxid),
             itemsb.catalog_name, itemtlp.primary_category_id,
             getPOAttrValuesTLPAction(p.contract_line_id, '-2' ,-2, p.org_id, itemtlp.language)
      FROM   icx_cat_item_prices p, icx_cat_items_tlp itemtlp,
             icx_cat_items_b itemsb, icx_cat_ext_items_tlp exttlp, po_headers_interface phi
      WHERE  p.price_type IN ('BLANKET', 'QUOTATION')
      AND    p.contract_line_id >= p_start_po_line_id
      AND    itemtlp.rt_item_id = p.rt_item_id
      AND    itemsb.rt_item_id = p.rt_item_id
      AND    itemtlp.rt_item_id = exttlp.rt_item_id
      AND    itemtlp.language = exttlp.language
      AND    p.contract_id = phi.po_header_id
      AND    phi.batch_id = g_PDOI_batch_id
      AND    (itemsb.last_update_date > g_extract_last_run_date
              OR itemtlp.last_update_date > g_extract_last_run_date
              OR exttlp.last_update_date > g_extract_last_run_date
              OR p.last_update_date > g_extract_last_run_date)
      ORDER BY contract_line_id, p.rt_item_id, itemtlp.language;
  END IF;

  l_err_loc := 130;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openBlanketsAndQuotesLinesCsr;

PROCEDURE processBlanketsAndQuotes
IS

  ----- Start of declaring columns selected in the cursor -----

  l_po_header_id_tbl            DBMS_SQL.NUMBER_TABLE;
  l_price_type_tbl              DBMS_SQL.VARCHAR2_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_rt_item_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_interface_header_id_tbl     DBMS_SQL.NUMBER_TABLE;
  l_po_line_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_inventory_item_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_supplier_part_auxid_tbl     DBMS_SQL.VARCHAR2_TABLE;
  l_catalog_name_tbl            DBMS_SQL.VARCHAR2_TABLE;
  l_primary_category_id_tbl     DBMS_SQL.NUMBER_TABLE;
  l_attr_val_tlp_action_tbl     DBMS_SQL.VARCHAR2_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'processBlanketsAndQuotes';
  l_err_loc                     PLS_INTEGER;
  l_err_string                  VARCHAR2(4000);
  l_start_po_header_id	        NUMBER;
  l_start_po_line_id	        NUMBER;
  l_batch_count                 PLS_INTEGER;
  l_prev_po_line_id             NUMBER;
  l_interface_header_id         NUMBER;
  l_interface_line_id           NUMBER;
  l_ext_row_count               PLS_INTEGER;
  l_blanketAndQuoteHdr_csr      g_csr_type;
  l_blanketAndQuoteLine_csr     g_csr_type;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);

BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_start_po_header_id := 0;
  l_batch_count := 0;
  l_ext_row_count := 0;

  l_err_loc := 120;
  openBlanketsAndQuotesHdrsCsr(l_start_po_header_id, l_blanketAndQuoteHdr_csr);

  l_err_loc := 130;
  LOOP
    l_po_header_id_tbl.DELETE;
    l_price_type_tbl.DELETE;
    l_org_id_tbl.DELETE;

    BEGIN
      l_err_loc := 140;
      FETCH l_blanketAndQuoteHdr_csr BULK COLLECT INTO
            l_po_header_id_tbl, l_price_type_tbl, l_org_id_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Total no: of blankets and quotes headers fetched from the cursor:' ||
            l_po_header_id_tbl.COUNT);
      END IF;

      l_err_loc := 160;
      EXIT WHEN l_po_header_id_tbl.COUNT = 0;

      l_err_loc := 170;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 180;
      --Save the last po_header_id processed, so that re-open of cursor will start from the saved po_header_id.
      l_start_po_header_id := l_po_header_id_tbl(l_po_header_id_tbl.COUNT);

      l_err_loc := 190;
      l_ext_row_count := l_ext_row_count + l_po_header_id_tbl.COUNT;

      l_err_loc := 200;
      FOR i in 1..l_po_header_id_tbl.COUNT LOOP
        l_err_loc := 210;

        l_err_loc := 220;
        --Process and start assigning the current values in pl/sql table to global pl/sql table
        l_interface_header_id := getNextInterfaceHdrIdFromSeq;

        l_err_loc := 230;
        g_po_hdrs_int_rec.interface_header_id           := l_interface_header_id;
        g_po_hdrs_int_rec.action                        := 'UPDATE';
        g_po_hdrs_int_rec.org_id                        := l_org_id_tbl(i);
        g_po_hdrs_int_rec.document_type_code            := l_price_type_tbl(i);
        g_po_hdrs_int_rec.budget_account_segment1       := null;
        g_po_hdrs_int_rec.po_header_id                  := l_po_header_id_tbl(i);
        --Will have some value when moving bulk-loaded items
        --For moving the extracted item attributes, the following will be null in po_headers_interface
        --as these are already set in po_headers_all
        g_po_hdrs_int_rec.approval_status               := null;
        g_po_hdrs_int_rec.vendor_id                     := null;
        g_po_hdrs_int_rec.vendor_site_id                := null;
        g_po_hdrs_int_rec.currency_code                 := null;
        g_po_hdrs_int_rec.cpa_reference                 := null;
        g_po_hdrs_int_rec.created_language              := null;
        g_po_hdrs_int_rec.comments                      := null;

        l_err_loc := 240;
        insertPOHeadersInterface;

        l_err_loc := 320;
        populatePOInterfaceTables('INLOOP');
      END LOOP;  --FOR LOOP of l_po_header_id_tbl

      l_err_loc := 330;
      EXIT WHEN l_po_header_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 340;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
	                || ', Total processeded batches:' || l_batch_count
                        || ', Cursor will be reopened with l_po_header_id_tbl:' || l_start_po_header_id;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        CLOSE l_blanketAndQuoteHdr_csr;
        openBlanketsAndQuotesHdrsCsr(l_start_po_header_id, l_blanketAndQuoteHdr_csr);
    END;
  END LOOP; --CURSOR LOOP

  l_err_loc := 370;
  populatePOInterfaceTables('OUTLOOP');

  IF (l_blanketAndQuoteHdr_csr%ISOPEN) THEN
    CLOSE l_blanketAndQuoteHdr_csr;
  END IF;

  l_err_loc := 380;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'processBlanketsAndQuotes Headers done; '||
        'Total no: of batches processed:' || l_batch_count ||
        ', Total no: of blankets and quotes headers processed:' || l_ext_row_count);
  END IF;

  l_start_po_line_id := 0;
  l_batch_count := 0;
  l_ext_row_count := 0;
  --Assign the previous po_line_id to some dummy values
  l_prev_po_line_id := -1212;

  l_err_loc := 120;
  openBlanketsAndQuotesLinesCsr(l_start_po_line_id, l_blanketAndQuoteLine_csr);

  l_err_loc := 130;
  LOOP
    l_rt_item_id_tbl.DELETE;
    l_language_tbl.DELETE;
    l_price_type_tbl.DELETE;
    l_interface_header_id_tbl.DELETE;
    l_po_header_id_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_inventory_item_id_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_supplier_part_auxid_tbl.DELETE;
    l_catalog_name_tbl.DELETE;
    l_primary_category_id_tbl.DELETE;
    l_attr_val_tlp_action_tbl.DELETE;

    BEGIN
      l_err_loc := 140;
      FETCH l_blanketAndQuoteLine_csr BULK COLLECT INTO
              l_rt_item_id_tbl, l_language_tbl,  l_price_type_tbl,
              l_interface_header_id_tbl, l_po_header_id_tbl, l_po_line_id_tbl,
              l_inventory_item_id_tbl, l_org_id_tbl, l_supplier_part_auxid_tbl,
              l_catalog_name_tbl, l_primary_category_id_tbl,
              l_attr_val_tlp_action_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Total no: of blankets and quotes lines fetched from the cursor:' ||
            l_po_line_id_tbl.COUNT);
      END IF;

      l_err_loc := 160;
      EXIT WHEN l_po_line_id_tbl.COUNT = 0;

      l_err_loc := 170;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 180;
      --Save the last po_line_id processed, so that re-open of cursor will start from the saved po_line_id.
      l_start_po_line_id := l_po_line_id_tbl(l_po_line_id_tbl.COUNT);

      l_err_loc := 190;
      l_ext_row_count := l_ext_row_count + l_po_line_id_tbl.COUNT;

      l_err_loc := 200;
      FOR i in 1..l_po_line_id_tbl.COUNT LOOP
        l_err_loc := 250;
        IF (l_prev_po_line_id <> l_po_line_id_tbl(i)) THEN
          l_interface_line_id := getNextInterfaceLineIdFromSeq;
          l_err_loc := 260;

          g_po_line_attrval_int_rec.interface_line_id           := l_interface_line_id;
          g_po_line_attrval_int_rec.interface_header_id         := l_interface_header_id_tbl(i);
          g_po_line_attrval_int_rec.action                      := 'UPDATE';
          g_po_line_attrval_int_rec.po_line_id                  := l_po_line_id_tbl(i);
          g_po_line_attrval_int_rec.po_header_id                := l_po_header_id_tbl(i);
          g_po_line_attrval_int_rec.req_template_name           := TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          g_po_line_attrval_int_rec.req_template_line_num       := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          g_po_line_attrval_int_rec.inventory_item_id           := l_inventory_item_id_tbl(i);
          g_po_line_attrval_int_rec.org_id                      := l_org_id_tbl(i);
          g_po_line_attrval_int_rec.rt_item_id                  := l_rt_item_id_tbl(i);
          g_po_line_attrval_int_rec.language                    := l_language_tbl(i);
          g_po_line_attrval_int_rec.supplier_part_auxid         := l_supplier_part_auxid_tbl(i);
          g_po_line_attrval_int_rec.catalog_name                := l_catalog_name_tbl(i);
          g_po_line_attrval_int_rec.ip_category_id              := l_primary_category_id_tbl(i);
          --Put the following to null, because we cannot update these for
          --extracted items in po_lines_all and po_attribute_values
          g_po_line_attrval_int_rec.unit_price                  := null;
          g_po_line_attrval_int_rec.uom_code                    := null;
          g_po_line_attrval_int_rec.negotiated_by_preparer_flag := null;
          g_po_line_attrval_int_rec.category_id                 := null;
          g_po_line_attrval_int_rec.category_name               := null;
          g_po_line_attrval_int_rec.vendor_product_num          := null;
          g_po_line_attrval_int_rec.item_description            := null;

          l_err_loc := 270;
          insertPOLinesInterface;
          insertPOAttrValsInterface;
        END IF;

        l_err_loc := 280;
        g_po_attrvalstlp_int_rec.interface_header_id            := l_interface_header_id_tbl(i);
        g_po_attrvalstlp_int_rec.interface_line_id              := l_interface_line_id;
        g_po_attrvalstlp_int_rec.action                         := l_attr_val_tlp_action_tbl(i);
        g_po_attrvalstlp_int_rec.po_line_id                     := l_po_line_id_tbl(i);
        g_po_attrvalstlp_int_rec.req_template_name              := TO_CHAR(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
        g_po_attrvalstlp_int_rec.req_template_line_num          := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
        g_po_attrvalstlp_int_rec.inventory_item_id              := l_inventory_item_id_tbl(i);
        g_po_attrvalstlp_int_rec.org_id                         := l_org_id_tbl(i);
        g_po_attrvalstlp_int_rec.language                       := l_language_tbl(i);
        IF (l_language_tbl(i) = ICX_CAT_UTIL_PVT.g_base_language) THEN
          g_po_attrvalstlp_int_rec.check_desc_update            := ICX_CAT_UTIL_PVT.g_donot_update_description;
        ELSE
          g_po_attrvalstlp_int_rec.check_desc_update            := ICX_CAT_UTIL_PVT.g_update_description;
        END IF;
        g_po_attrvalstlp_int_rec.rt_item_id                     := l_rt_item_id_tbl(i);

        l_err_loc := 290;
        insertPOAttrValsTLPInterface;

        l_err_loc := 300;
        /*  TO BE WORKED ON
        -- Statement level log
          fnd_file.put_line(fnd_file.log, g_pkg_name || '.' || l_api_name || ';' ||  logCurrentRow);
        */

        l_err_loc := 310;
        l_prev_po_line_id := l_po_line_id_tbl(i);

        l_err_loc := 320;
        populatePOInterfaceTables('INLOOP');
      END LOOP;  --FOR LOOP of l_po_line_id_tbl

      l_err_loc := 330;
      EXIT WHEN l_po_line_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 340;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
	                || ', Total processeded batches:' || l_batch_count
                        || ', Cursor will be reopened with po_line_id:' || l_start_po_line_id;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        CLOSE l_blanketAndQuoteLine_csr;
        openBlanketsAndQuotesLinesCsr(l_start_po_line_id, l_blanketAndQuoteLine_csr);
    END;
  END LOOP; --CURSOR LOOP

  l_err_loc := 370;
  populatePOInterfaceTables('OUTLOOP');

  IF (l_blanketAndQuoteLine_csr%ISOPEN) THEN
    CLOSE l_blanketAndQuoteLine_csr;
  END IF;

  l_err_loc := 380;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done. '||
        'Total no: of batches processed:' || l_batch_count ||
        ', Total no: of blankets and quotes lines processed:' || l_ext_row_count);
  END IF;

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
    raise;
END processBlanketsAndQuotes;

PROCEDURE openReqTemplatesHdrsCsr
(       p_start_template_id     IN VARCHAR2             ,
        p_reqTemplateHdrs_csr   IN OUT NOCOPY g_csr_type
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openReqTemplatesHdrsCsr';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (g_extract_last_run_date IS NULL) THEN
    OPEN p_reqTemplateHdrs_csr FOR
      SELECT distinct p.template_id, p.org_id
      FROM   icx_cat_item_prices p
      WHERE  p.price_type IN ('TEMPLATE', 'INTERNAL_TEMPLATE')
      AND    p.template_id >= p_start_template_id
      ORDER BY p.template_id;
  ELSE
    l_err_loc := 200;
    OPEN p_reqTemplateHdrs_csr FOR
      SELECT distinct p.template_id, p.org_id
      FROM   icx_cat_item_prices p, icx_cat_items_tlp itemtlp,
             icx_cat_items_b itemsb, icx_cat_ext_items_tlp exttlp
      WHERE  p.price_type IN ('TEMPLATE', 'INTERNAL_TEMPLATE')
      AND    p.template_id >= p_start_template_id
      AND    itemtlp.rt_item_id = p.rt_item_id
      AND    itemsb.rt_item_id = p.rt_item_id
      AND    itemtlp.rt_item_id = exttlp.rt_item_id
      AND    itemtlp.language = exttlp.language
      AND    (itemsb.last_update_date > g_extract_last_run_date
              OR itemtlp.last_update_date > g_extract_last_run_date
              OR exttlp.last_update_date > g_extract_last_run_date
              OR p.last_update_date > g_extract_last_run_date)
      ORDER BY p.template_id;
  END IF;

  l_err_loc := 300;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openReqTemplatesHdrsCsr;

PROCEDURE openReqTemplatesLinesCsr
(       p_start_rt_item_id      IN NUMBER               ,
        p_reqTemplateLines_csr  IN OUT NOCOPY g_csr_type
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openReqTemplatesLinesCsr';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (g_extract_last_run_date IS NULL) THEN
    OPEN p_reqTemplateLines_csr FOR
      SELECT p.rt_item_id, itemtlp.language, phi.interface_header_id,
             p.template_id req_template_name, p.template_line_id req_template_line_num,
             p.inventory_item_id, p.org_id,
             DECODE(itemtlp.supplier_part_auxid, '##NULL##', null, itemtlp.supplier_part_auxid),
             itemsb.catalog_name, itemtlp.primary_category_id,
             getPOAttrValuesTLPAction(-2, p.template_id, p.template_line_id, p.org_id, itemtlp.language)
      FROM   icx_cat_item_prices p, icx_cat_items_tlp itemtlp,
             icx_cat_items_b itemsb, po_headers_interface phi
      WHERE  p.price_type IN ('TEMPLATE', 'INTERNAL_TEMPLATE')
      AND    p.rt_item_id >= p_start_rt_item_id
      AND    itemtlp.rt_item_id = p.rt_item_id
      AND    itemsb.rt_item_id = p.rt_item_id
      AND    p.template_id = phi.budget_account_segment1
      AND    p.org_id = phi.org_id
      AND    phi.batch_id = g_PDOI_batch_id
      ORDER BY p.rt_item_id, itemtlp.language;
  ELSE
    l_err_loc := 200;
    OPEN p_reqTemplateLines_csr FOR
      SELECT p.rt_item_id, itemtlp.language, phi.interface_header_id,
             p.template_id req_template_name, p.template_line_id req_template_line_num,
             p.inventory_item_id, p.org_id,
             DECODE(itemtlp.supplier_part_auxid, '##NULL##', null, itemtlp.supplier_part_auxid),
             itemsb.catalog_name, itemtlp.primary_category_id,
             getPOAttrValuesTLPAction(-2, p.template_id, p.template_line_id, p.org_id, itemtlp.language)
      FROM   icx_cat_item_prices p, icx_cat_items_tlp itemtlp,
             icx_cat_items_b itemsb, icx_cat_ext_items_tlp exttlp, po_headers_interface phi
      WHERE  p.price_type IN ('TEMPLATE', 'INTERNAL_TEMPLATE')
      AND    p.rt_item_id >= p_start_rt_item_id
      AND    itemtlp.rt_item_id = p.rt_item_id
      AND    itemsb.rt_item_id = p.rt_item_id
      AND    itemtlp.rt_item_id = exttlp.rt_item_id
      AND    itemtlp.language = exttlp.language
      AND    p.template_id = phi.budget_account_segment1
      AND    p.org_id = phi.org_id
      AND    phi.batch_id = g_PDOI_batch_id
      AND    (itemsb.last_update_date > g_extract_last_run_date
              OR itemtlp.last_update_date > g_extract_last_run_date
              OR exttlp.last_update_date > g_extract_last_run_date
              OR p.last_update_date > g_extract_last_run_date)
      ORDER BY p.rt_item_id, itemtlp.language;
  END IF;

  l_err_loc := 300;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openReqTemplatesLinesCsr;

PROCEDURE processReqTemplates
IS

  ----- Start of declaring columns selected in the cursor -----

  l_req_template_name_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_rt_item_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_interface_header_id_tbl     DBMS_SQL.NUMBER_TABLE;
  l_req_template_line_num_tbl   DBMS_SQL.NUMBER_TABLE;
  l_inventory_item_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_supplier_part_auxid_tbl     DBMS_SQL.VARCHAR2_TABLE;
  l_catalog_name_tbl            DBMS_SQL.VARCHAR2_TABLE;
  l_primary_category_id_tbl     DBMS_SQL.NUMBER_TABLE;
  l_attr_val_tlp_action_tbl     DBMS_SQL.VARCHAR2_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'processReqTemplates';
  l_err_loc                     PLS_INTEGER;
  l_err_string                  VARCHAR2(4000);
  l_start_template_id	        icx_cat_item_prices.template_id%TYPE;
  l_start_rt_item_id	        NUMBER;
  l_batch_count                 PLS_INTEGER;
  l_prev_rt_item_id             NUMBER;
  l_interface_header_id         NUMBER;
  l_interface_line_id           NUMBER;
  l_ext_row_count               PLS_INTEGER;
  l_reqTemplateHdr_csr          g_csr_type;
  l_reqTemplateLine_csr         g_csr_type;
  l_start_date          	DATE;
  l_end_date            	DATE;
  l_log_string			VARCHAR2(2000);

BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_start_template_id := '-2';
  l_batch_count := 0;
  l_ext_row_count := 0;

  l_err_loc := 200;
  openReqTemplatesHdrsCsr(l_start_template_id, l_reqTemplateHdr_csr);

  l_err_loc := 300;
  LOOP
    l_req_template_name_tbl.DELETE;
    l_org_id_tbl.DELETE;

    BEGIN
      l_err_loc := 400;
      FETCH l_reqTemplateHdr_csr BULK COLLECT INTO
            l_req_template_name_tbl, l_org_id_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      l_err_loc := 410;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Total no: of Req Templates headers fetched from the cursor:' ||
            l_req_template_name_tbl.COUNT);
      END IF;

      l_err_loc := 500;
      EXIT WHEN l_req_template_name_tbl.COUNT = 0;

      l_err_loc := 600;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 700;
      --Save the last template_id processed, so that re-open of cursor will start from the saved template_id.
      l_start_template_id := l_req_template_name_tbl(l_req_template_name_tbl.COUNT);

      l_err_loc := 800;
      l_ext_row_count := l_ext_row_count + l_req_template_name_tbl.COUNT;

      l_err_loc := 900;
      FOR i in 1..l_req_template_name_tbl.COUNT LOOP
        l_err_loc := 1000;
        --Process and start assigning the current values in pl/sql table to global pl/sql table
        l_interface_header_id := getNextInterfaceHdrIdFromSeq;

        l_err_loc := 1100;
        g_po_hdrs_int_rec.interface_header_id           := l_interface_header_id;
        g_po_hdrs_int_rec.action                        := 'REQTEMPLATE';
        g_po_hdrs_int_rec.org_id                        := l_org_id_tbl(i);
        -- Just used by data migration to get the interface header id from po_headers_interface
        g_po_hdrs_int_rec.budget_account_segment1       := l_req_template_name_tbl(i);
        g_po_hdrs_int_rec.document_type_code            := null;
        g_po_hdrs_int_rec.po_header_id                  := null;
        --Will have some value when moving bulk-loaded items
        --For moving the extracted item attributes, the following will be null in po_headers_interface
        --as these are already set in po_headers_all
        g_po_hdrs_int_rec.approval_status               := null;
        g_po_hdrs_int_rec.vendor_id                     := null;
        g_po_hdrs_int_rec.vendor_site_id                := null;
        g_po_hdrs_int_rec.currency_code                 := null;
        g_po_hdrs_int_rec.cpa_reference                 := null;
        g_po_hdrs_int_rec.created_language              := null;
        g_po_hdrs_int_rec.comments                      := null;

        l_err_loc := 1200;
        insertPOHeadersInterface;

        l_err_loc := 1300;
        populatePOInterfaceTables('INLOOP');
      END LOOP;  --FOR LOOP of l_req_template_name_tbl

      l_err_loc := 1400;
      EXIT WHEN l_req_template_name_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 1500;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
	                || ', Total processeded batches:' || l_batch_count
                        || ', Cursor will be reopened with l_req_template_name_tbl:' || l_start_template_id;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        CLOSE l_reqTemplateHdr_csr;
        openReqTemplatesHdrsCsr(l_start_template_id, l_reqTemplateHdr_csr);
    END;
  END LOOP; --CURSOR LOOP

  l_err_loc := 1600;
  populatePOInterfaceTables('OUTLOOP');

  l_err_loc := 1700;
  IF (l_reqTemplateHdr_csr%ISOPEN) THEN
    CLOSE l_reqTemplateHdr_csr;
  END IF;

  l_err_loc := 1800;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
      'processReqTemplates Headers done; ' ||
      'Total no: of batches processed:' || l_batch_count ||
      ', Total no: of Req Templates headers processed:' || l_ext_row_count);
  END IF;

  l_start_rt_item_id := 0;
  l_batch_count := 0;
  l_ext_row_count := 0;
  --Assign the previous po_line_id to some dummy values
  l_prev_rt_item_id := -1212;

  l_err_loc := 1900;
  openReqTemplatesLinesCsr(l_start_rt_item_id, l_reqTemplateLine_csr);

  l_err_loc := 2000;
  LOOP
    l_rt_item_id_tbl.DELETE;
    l_language_tbl.DELETE;
    l_interface_header_id_tbl.DELETE;
    l_req_template_name_tbl.DELETE;
    l_req_template_line_num_tbl.DELETE;
    l_inventory_item_id_tbl.DELETE;
    l_org_id_tbl.DELETE;
    l_supplier_part_auxid_tbl.DELETE;
    l_catalog_name_tbl.DELETE;
    l_primary_category_id_tbl.DELETE;
    l_attr_val_tlp_action_tbl.DELETE;

    BEGIN
      l_err_loc := 2100;
      FETCH l_reqTemplateLine_csr BULK COLLECT INTO
              l_rt_item_id_tbl, l_language_tbl,  l_interface_header_id_tbl,
              l_req_template_name_tbl, l_req_template_line_num_tbl,
              l_inventory_item_id_tbl, l_org_id_tbl, l_supplier_part_auxid_tbl,
              l_catalog_name_tbl, l_primary_category_id_tbl,
              l_attr_val_tlp_action_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Total no: of Req Templates lines fetched from the cursor:' ||
            l_rt_item_id_tbl.COUNT);
      END IF;

      l_err_loc := 2200;
      EXIT WHEN l_rt_item_id_tbl.COUNT = 0;

      l_err_loc := 2300;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 2400;
      --Save the last rt_item_id processed, so that re-open of cursor will start from the saved rt_item_id.
      l_start_rt_item_id := l_rt_item_id_tbl(l_rt_item_id_tbl.COUNT);

      l_err_loc := 2500;
      l_ext_row_count := l_ext_row_count + l_rt_item_id_tbl.COUNT;

      l_err_loc := 2600;
      FOR i in 1..l_rt_item_id_tbl.COUNT LOOP
        l_err_loc := 2700;
        IF (l_prev_rt_item_id <> l_rt_item_id_tbl(i)) THEN
          l_interface_line_id := getNextInterfaceLineIdFromSeq;

          l_err_loc := 2800;
          g_po_line_attrval_int_rec.interface_line_id           := l_interface_line_id;
          g_po_line_attrval_int_rec.interface_header_id         := l_interface_header_id_tbl(i);
          g_po_line_attrval_int_rec.req_template_name           := l_req_template_name_tbl(i);
          g_po_line_attrval_int_rec.req_template_line_num       := l_req_template_line_num_tbl(i);
          g_po_line_attrval_int_rec.inventory_item_id           := l_inventory_item_id_tbl(i);
          g_po_line_attrval_int_rec.org_id                      := l_org_id_tbl(i);
          g_po_line_attrval_int_rec.rt_item_id                  := l_rt_item_id_tbl(i);
          g_po_line_attrval_int_rec.language                    := l_language_tbl(i);
          g_po_line_attrval_int_rec.supplier_part_auxid         := l_supplier_part_auxid_tbl(i);
          g_po_line_attrval_int_rec.catalog_name                := l_catalog_name_tbl(i);
          g_po_line_attrval_int_rec.ip_category_id              := l_primary_category_id_tbl(i);
          --The following will be null in po_lines_interface
          --when moving item attributes for req templates
          g_po_line_attrval_int_rec.po_header_id                := null;
          g_po_line_attrval_int_rec.unit_price                  := null;
          g_po_line_attrval_int_rec.uom_code                    := null;
          g_po_line_attrval_int_rec.negotiated_by_preparer_flag := null;
          g_po_line_attrval_int_rec.category_id                 := null;
          g_po_line_attrval_int_rec.category_name               := null;
          g_po_line_attrval_int_rec.vendor_product_num          := null;
          g_po_line_attrval_int_rec.item_description            := null;

          l_err_loc := 2900;
          g_po_line_attrval_int_rec.po_line_id                  := null;
          g_po_line_attrval_int_rec.action                      := 'REQTEMPLATE';
          insertPOLinesInterface;

          g_po_line_attrval_int_rec.po_line_id                  := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
          g_po_line_attrval_int_rec.action                      := 'UPDATE';
          insertPOAttrValsInterface;
        END IF;

        l_err_loc := 3000;
        g_po_attrvalstlp_int_rec.interface_header_id            := l_interface_header_id_tbl(i);
        g_po_attrvalstlp_int_rec.interface_line_id              := l_interface_line_id;
        g_po_attrvalstlp_int_rec.action                         := l_attr_val_tlp_action_tbl(i);
        g_po_attrvalstlp_int_rec.po_line_id                     := TO_NUMBER(ICX_CAT_UTIL_PVT.g_NULL_NUMBER);
        g_po_attrvalstlp_int_rec.req_template_name              := l_req_template_name_tbl(i);
        g_po_attrvalstlp_int_rec.req_template_line_num          := l_req_template_line_num_tbl(i);
        g_po_attrvalstlp_int_rec.inventory_item_id              := l_inventory_item_id_tbl(i);
        g_po_attrvalstlp_int_rec.org_id                         := l_org_id_tbl(i);
        g_po_attrvalstlp_int_rec.language                       := l_language_tbl(i);
        IF (l_language_tbl(i) = ICX_CAT_UTIL_PVT.g_base_language) THEN
          g_po_attrvalstlp_int_rec.check_desc_update            := ICX_CAT_UTIL_PVT.g_donot_update_description;
        ELSE
          g_po_attrvalstlp_int_rec.check_desc_update            := ICX_CAT_UTIL_PVT.g_update_description;
        END IF;
        g_po_attrvalstlp_int_rec.rt_item_id                     := l_rt_item_id_tbl(i);

        l_err_loc := 3100;
        insertPOAttrValsTLPInterface;

        l_err_loc := 3200;
        /*  TO BE WORKED ON
        -- Statement level log
          fnd_file.put_line(fnd_file.log, g_pkg_name || '.' || l_api_name || ';' ||  logCurrentRow);
        */

        l_err_loc := 3300;
        l_prev_rt_item_id := l_rt_item_id_tbl(i);

        l_err_loc := 3400;
        populatePOInterfaceTables('INLOOP');
      END LOOP;  --FOR LOOP of l_rt_item_id_tbl

      l_err_loc := 3500;
      EXIT WHEN l_rt_item_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;

      l_err_loc := 3600;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
	                || ', Total processeded batches:' || l_batch_count
                        || ', Cursor will be reopened with po_line_id:' || l_start_rt_item_id;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        CLOSE l_reqTemplateLine_csr;
        openReqTemplatesLinesCsr(l_start_rt_item_id, l_reqTemplateLine_csr);
    END;
  END LOOP; --CURSOR LOOP

  l_err_loc := 3700;
  populatePOInterfaceTables('OUTLOOP');

  l_err_loc := 3800;
  IF (l_reqTemplateLine_csr%ISOPEN) THEN
    CLOSE l_reqTemplateLine_csr;
  END IF;

  l_err_loc := 3900;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done. ' ||
        'Total no: of batches processed:' || l_batch_count ||
        ', Total no: of Req Templates lines processed:' || l_ext_row_count);
  END IF;

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
    raise;
END processReqTemplates;

PROCEDURE moveExtItemsBaseAndLocalAttr
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'moveExtItemsBaseAndLocalAttr';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  --Comments: Three different procedures needed to:
  --1. Process Blankets and Quotations:
  --   Populate po headers, lines, attributes and attributes_tlp interface tables.
  --2. Process Requisition templates:
  --   populate po attributes and attributes_tlp interface tables
  --   and dummy lines in po headers interface for each express_name and org_id
  --   and dummy lines in po_lines interface for each line in a requisition template (express_name).
  processBlanketsAndQuotes;

  l_err_loc := 200;
  processReqTemplates;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    raise;
END moveExtItemsBaseAndLocalAttr;

PROCEDURE openContractAutoSourcingCsr
(       p_contractAutoSourcing_csr      IN OUT NOCOPY   g_csr_type
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'openContractAutoSourcingCsr';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (g_bulk_last_run_date IS NULL) THEN
    l_err_loc := 110;
    -- Added NVL to org_id, supplier, site and currency
    OPEN p_contractAutoSourcing_csr FOR
      SELECT NVL(price.org_id, -2), NVL(itemtlp.supplier_id, -2), NVL(price.supplier_site_id, -2),
             NVL(price.currency, '-2'), NVL(price.contract_id, -2) contract_id,
             NVL(map.external_source_key, '-2') po_category_id
      FROM   icx_cat_item_prices price,
             icx_cat_items_tlp itemtlp,
             icx_por_category_order_map map
      WHERE  price.price_type = 'BULKLOAD'
      AND    price.rt_item_id = itemtlp.rt_item_id
      AND    NOT EXISTS (SELECT 'extracted price'
                         FROM   icx_cat_item_prices priceIn
                         WHERE  priceIn.rt_item_id = price.rt_item_id
                         AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                       'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
      AND    itemtlp.primary_category_id = map.rt_category_id (+)
      GROUP BY price.org_id, itemtlp.supplier_id, price.supplier_site_id,
               price.currency, price.contract_id, map.external_source_key
      ORDER BY price.org_id;
  ELSE
    l_err_loc := 120;
    OPEN p_contractAutoSourcing_csr FOR
      SELECT NVL(price.org_id, -2), NVL(itemtlp.supplier_id, -2), NVL(price.supplier_site_id, -2),
             NVL(price.currency, '-2'), NVL(price.contract_id, -2) contract_id,
             NVL(map.external_source_key, '-2') po_category_id
      FROM   icx_cat_item_prices price,
             icx_cat_items_tlp itemtlp,
             icx_por_category_order_map map,
             icx_cat_items_b itemb,
             icx_cat_ext_items_tlp extitemtlp,
             icx_cat_r12_upgrade upg
      WHERE  price.price_type = 'BULKLOAD'
      AND    price.rt_item_id = itemtlp.rt_item_id
      AND    NOT EXISTS (SELECT 'extracted price'
                         FROM   icx_cat_item_prices priceIn
                         WHERE  priceIn.rt_item_id = price.rt_item_id
                         AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                       'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
      AND    itemtlp.primary_category_id = map.rt_category_id (+)
      AND    price.rt_item_id = itemb.rt_item_id
      AND    price.rt_item_id = extitemtlp.rt_item_id
      AND    itemtlp.language = extitemtlp.language
      AND    price.rt_item_id = upg.rt_item_id (+)
      AND    price.supplier_site_id = upg.supplier_site_id (+)
      AND    price.currency = upg.currency (+)
      AND    price.contract_id = upg.price_contract_id (+)
      AND    ( -- Last update changes in items / price tables
              (itemb.last_update_date > g_bulk_last_run_date
               OR itemtlp.last_update_date > g_bulk_last_run_date
               OR extitemtlp.last_update_date > g_bulk_last_run_date
               OR price.last_update_date > g_bulk_last_run_date)
              OR -- The items that errored out in the previous run
              (upg.po_header_id is null
               OR upg.po_line_id is null))
      GROUP BY price.org_id, itemtlp.supplier_id, price.supplier_site_id,
               price.currency, price.contract_id, map.external_source_key
      ORDER BY price.org_id;
  END IF;

  l_err_loc := 130;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END openContractAutoSourcingCsr;

PROCEDURE contractAutoSourcing
IS

  ----- Start of declaring columns selected in the cursor -----

  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_supplier_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_supplier_site_id_tbl        DBMS_SQL.NUMBER_TABLE;
  l_currency_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_contract_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_po_category_id_tbl          DBMS_SQL.VARCHAR2_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'contractAutoSourcing';
  l_err_loc                     PLS_INTEGER;
  l_prev_org_id                 NUMBER := -1212;

  l_supplier_site_id            NUMBER := NULL;
  l_supplier_contact_id         NUMBER := NULL;
  l_source_organization_id      NUMBER := NULL;
  l_source_subinventory         VARCHAR2(10) := '';
  l_document_header_id          NUMBER := NULL;
  l_document_line_id            NUMBER := NULL;
  l_document_type_code          po_headers_all.type_lookup_code%TYPE := '';
  l_document_line_num           NUMBER := NULL;
  l_buyer_id                    NUMBER := NULL;
  l_vendor_product_num          po_lines_all.vendor_product_num%TYPE := '';
  l_purchasing_uom              PO_LINES_ALL.unit_meas_lookup_code%TYPE := '';
  l_icx_schema_name             VARCHAR2(30) := NULL;

  l_as_index                    PLS_INTEGER := 0;
  l_as_org_id_tbl               DBMS_SQL.NUMBER_TABLE;
  l_as_supplier_id_tbl          DBMS_SQL.NUMBER_TABLE;
  l_as_supplier_site_id_tbl     DBMS_SQL.NUMBER_TABLE;
  l_as_currency_tbl             DBMS_SQL.VARCHAR2_TABLE;
  l_as_contract_id_tbl          DBMS_SQL.NUMBER_TABLE;
  l_as_po_category_id_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_contractAutoSourcing_csr    g_csr_type;
  l_start_date                  DATE;
  l_end_date                    DATE;
  l_log_string                  VARCHAR2(2000);

BEGIN
  l_err_loc := 100;

  l_err_loc := 110;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Start =======');
  END IF;

  l_err_loc := 120;
  openContractAutoSourcingCsr(l_contractAutoSourcing_csr);

  l_err_loc := 130;
  --Not expecting a huge number of GBPA header's that will be returned from the cursor.
  --Considering the fact that we are grouping by on supplier_id, org_id, supplier_site_id, currency and language
  FETCH l_contractAutoSourcing_csr BULK COLLECT INTO
           l_org_id_tbl, l_supplier_id_tbl, l_supplier_site_id_tbl,
           l_currency_tbl, l_contract_id_tbl, l_po_category_id_tbl;

  l_err_loc := 140;
  CLOSE l_contractAutoSourcing_csr;

  l_err_loc := 150;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Total no: of distinct contract auto source attributes found:' || l_org_id_tbl.COUNT);
  END IF;

  l_err_loc := 160;
  FOR i in 1..l_org_id_tbl.COUNT LOOP

    l_err_loc := 170;
    IF (l_org_id_tbl(i) <> ICX_CAT_UTIL_PVT.g_NULL_NUMBER AND
        l_supplier_site_id_tbl(i) <> ICX_CAT_UTIL_PVT.g_NULL_NUMBER AND
        l_po_category_id_tbl(i) <> ICX_CAT_UTIL_PVT.g_NULL_CHAR)
    THEN
      l_err_loc := 190;
      -- Set the org context if the org has changed
      IF (l_prev_org_id <> l_org_id_tbl(i)) THEN
        l_err_loc := 210;
        MO_GLOBAL.set_policy_context('S', l_org_id_tbl(i));
      END IF;

      l_err_loc := 220;
      -- Try to find a suitable source document for the given attributes
      l_supplier_site_id := l_supplier_site_id_tbl(i);

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_start_date := sysdate;
        l_log_string := 'About to call po_autosource_sv.autosource at:' ||
                        TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                        '; Parameter passed: l_currency_tbl:' || l_currency_tbl(i) ||
                        ', l_supplier_id_tbl:' || l_supplier_id_tbl(i) ||
                        ', l_supplier_site_id:' || l_supplier_site_id ||
                        ', l_org_id_tbl:' || l_org_id_tbl(i) ||
                        ', l_po_category_id_tbl:' || l_po_category_id_tbl(i) ;
        FND_LOG.string(FND_LOG.LEVEL_EVENT,
           ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
           l_log_string);
      END IF;

      po_autosource_sv.autosource
                (x_mode                   => 'DOCUMENT',
                 x_destination_doc_type   => 'REQ',
                 x_item_id                => NULL,
                 x_commodity_id           => l_po_category_id_tbl(i),
                 x_dest_organization_id   => TO_NUMBER(NULL),
                 x_dest_subinventory      => NULL,
                 x_autosource_date        => TO_DATE(NULL),
                 x_item_rev               => NULL,
                 x_currency_code          => l_currency_tbl(i),
                 x_vendor_id              => l_supplier_id_tbl(i),
                 x_vendor_site_id         => l_supplier_site_id,
                 x_vendor_contact_id      => l_supplier_contact_id,
                 x_source_organization_id => l_source_organization_id,
                 x_source_subinventory    => l_source_subinventory,
                 x_document_header_id     => l_document_header_id,
                 x_document_line_id       => l_document_line_id,
                 x_document_type_code     => l_document_type_code,
                 x_document_line_num      => l_document_line_num,
                 x_buyer_id               => l_buyer_id,
                 x_vendor_product_num     => l_vendor_product_num,
                 x_purchasing_uom         => l_purchasing_uom);

      l_err_loc := 230;

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        l_end_date := sysdate;
        l_log_string := ' done in:' ||
                        ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date) ||
                        '; Values returned: l_document_header_id:' || l_document_header_id ||
                        ', l_document_type_code:' || l_document_type_code ||
                        ', l_supplier_site_id:' || l_supplier_site_id ||
                        ', l_document_line_id:' || l_document_line_id  ||
                        ', l_document_line_num:' || l_document_line_num ||
                        ', l_vendor_product_num:' || l_vendor_product_num ||
                        ', l_purchasing_uom:' || l_purchasing_uom ;
        FND_LOG.string(FND_LOG.LEVEL_EVENT,
           ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
           l_log_string);
      END IF;

      IF (l_document_header_id IS NULL) THEN
         l_document_header_id := ICX_CAT_UTIL_PVT.g_NULL_NUMBER;
      END IF;
    ELSE
      l_err_loc := 240;
      -- Just insert into the icx_cat_r12_upgrade_autosource
      l_document_header_id := l_contract_id_tbl(i);
    END IF;

    l_err_loc := 270;
    l_as_index := l_as_index + 1;
    l_as_org_id_tbl(l_as_index)                 := l_org_id_tbl(i);
    l_as_supplier_id_tbl(l_as_index)            := l_supplier_id_tbl(i);
    l_as_supplier_site_id_tbl(l_as_index)       := l_supplier_site_id_tbl(i);
    l_as_currency_tbl(l_as_index)               := l_currency_tbl(i);
    l_as_contract_id_tbl(l_as_index)            := l_document_header_id;
    l_as_po_category_id_tbl(l_as_index)         := l_po_category_id_tbl(i);

    l_err_loc := 280;
    l_prev_org_id               := l_org_id_tbl(i);
  END LOOP; --FOR LOOP of l_org_id_tbl

  l_err_loc := 285;
  l_icx_schema_name := ICX_CAT_UTIL_PVT.getIcxSchemaName;

  l_err_loc := 290;
  EXECUTE IMMEDIATE
    'TRUNCATE TABLE '|| l_icx_schema_name ||'.icx_cat_r12_upg_autosource';

  l_err_loc := 295;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'truncate table icx_cat_r12_upg_autosource done:');
  END IF;

  l_err_loc := 300;
  FORALL i IN 1..l_as_org_id_tbl.COUNT
    INSERT INTO icx_cat_r12_upg_autosource
    (org_id, supplier_id, supplier_site_id, currency,
     contract_id, po_category_id,
     last_update_login, last_updated_by, last_update_date,
     created_by, creation_date, internal_request_id, request_id,
     program_application_id, program_id, program_login_id)
    VALUES
    (l_as_org_id_tbl(i), l_as_supplier_id_tbl(i),
     l_as_supplier_site_id_tbl(i), l_as_currency_tbl(i),
     l_as_contract_id_tbl(i), l_as_po_category_id_tbl(i),
     ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
     ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
     ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
     ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
     ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
     ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
     ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
     ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'No: of rows inserted in autosource:' || SQL%ROWCOUNT);
  END IF;

  l_err_loc := 305;
  COMMIT;

  l_err_loc := 310;
  l_as_org_id_tbl.DELETE;
  l_as_supplier_id_tbl.DELETE;
  l_as_supplier_site_id_tbl.DELETE;
  l_as_currency_tbl.DELETE;
  l_as_contract_id_tbl.DELETE;
  l_as_po_category_id_tbl.DELETE;

  l_err_loc := 320;
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
    raise;
END contractAutoSourcing;

PROCEDURE checkAndProcessGBPALines
IS
  -- outer join with icx_cat_r12_upgrade, on rt_item_id (i.e. org_id and supplier_id),
  -- supplier_site_id, currency and contract_id (pricing attributes)
  -- join with contract_id needed because the items with the same combination of the above
  -- could exist in two contracts.
  -- outer join needed: because we need to find the items that were already processed in
  -- processGBPALines and the rows in the current cursor are just translations.
  -- We need price_type, to getthe price_contract_id and src_contract_id
  -- because if autosource returned a contract_id
  -- then src.contract_id will not be same as price.contract_id.
  CURSOR checkAndProcessGBPALinesCsr(p_org_id NUMBER, p_supplier_id NUMBER,
                                     p_supplier_site_id NUMBER, p_currency VARCHAR2,
                                     p_cpa_reference NUMBER, p_language VARCHAR2,
                                     p_start_rt_item_id NUMBER) IS
    SELECT itemtlp.rt_item_id, price.unit_price, price.unit_of_measure,
           DECODE(NVL(price.negotiated_by_preparer_flag, '1'), '0', 'N', 'Y'),
           itemtlp.primary_category_id, NVL(map.external_source_key, '-2') po_category_id,
           SUBSTRB(itemtlp.supplier_part_num, 1, 25) supplier_part_num,
           DECODE(itemtlp.supplier_part_auxid, '##NULL##', null, itemtlp.supplier_part_auxid),
           SUBSTRB(itemtlp.description, 1, 240) description, itemsb.catalog_name,
           upg.po_interface_header_id, upg.created_language, upg.po_interface_line_id,
           price.price_type, itemtlp.primary_category_name
    FROM   icx_cat_item_prices price, icx_cat_items_tlp itemtlp, icx_cat_items_b itemsb,
           icx_por_category_order_map map, icx_cat_r12_upg_autosource src,
           icx_cat_r12_upgrade upg
    WHERE  price.price_type = 'BULKLOAD'
    AND    price.rt_item_id = itemtlp.rt_item_id
    AND    price.rt_item_id = itemsb.rt_item_id
    AND    NOT EXISTS (SELECT 'extracted price'
                       FROM   icx_cat_item_prices priceIn
                       WHERE  priceIn.rt_item_id = price.rt_item_id
                       AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                     'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
    AND    itemtlp.primary_category_id = map.rt_category_id (+)
    AND    itemtlp.org_id = src.org_id
    AND    itemtlp.supplier_id = src.supplier_id
    AND    price.supplier_site_id = src.supplier_site_id
    AND    price.currency = src.currency
    AND    NVL(map.external_source_key, '-2') = src.po_category_id
    AND    price.rt_item_id = upg.rt_item_id (+)
    AND    price.supplier_site_id = upg.supplier_site_id (+)
    AND    price.currency = upg.currency (+)
    AND    price.contract_id = upg.price_contract_id (+)
    AND    itemtlp.rt_item_id >= p_start_rt_item_id
    AND    itemtlp.language = p_language
    AND    src.org_id = p_org_id
    AND    src.supplier_id = p_supplier_id
    AND    src.supplier_site_id = p_supplier_site_id
    AND    src.currency = p_currency
    AND    src.contract_id = p_cpa_reference
    UNION ALL
    SELECT itemtlp.rt_item_id, price.unit_price, price.unit_of_measure,
           DECODE(NVL(price.negotiated_by_preparer_flag, '1'), '0', 'N', 'Y'),
           itemtlp.primary_category_id, NVL(map.external_source_key, '-2') po_category_id,
           SUBSTRB(itemtlp.supplier_part_num, 1, 25) supplier_part_num,
           DECODE(itemtlp.supplier_part_auxid, '##NULL##', null, itemtlp.supplier_part_auxid),
           SUBSTRB(itemtlp.description, 1, 240) description, itemsb.catalog_name,
           upg.po_interface_header_id, upg.created_language, upg.po_interface_line_id,
           price.price_type, itemtlp.primary_category_name
    FROM   icx_cat_item_prices price, icx_cat_items_tlp itemtlp, icx_cat_items_b itemsb,
           icx_por_category_order_map map, icx_cat_r12_upgrade upg
    WHERE  price.price_type = 'CONTRACT'
    AND    price.rt_item_id = itemtlp.rt_item_id
    AND    price.rt_item_id = itemsb.rt_item_id
    AND    NOT EXISTS (SELECT 'extracted price'
                       FROM   icx_cat_item_prices priceIn
                       WHERE  priceIn.rt_item_id = price.rt_item_id
                       AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                     'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
    AND    itemtlp.primary_category_id = map.rt_category_id (+)
    AND    price.rt_item_id = upg.rt_item_id (+)
    AND    price.supplier_site_id = upg.supplier_site_id (+)
    AND    price.currency = upg.currency (+)
    AND    price.contract_id = upg.price_contract_id (+)
    AND    itemtlp.rt_item_id >= p_start_rt_item_id
    AND    itemtlp.language = p_language
    AND    itemtlp.org_id = p_org_id
    AND    itemtlp.supplier_id = p_supplier_id
    AND    price.supplier_site_id = p_supplier_site_id
    AND    price.currency = p_currency
    AND    price.contract_id = p_cpa_reference
    ORDER BY 1;

  ----- Start of declaring columns selected in the cursor -----

  l_rt_item_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_unit_price_tbl              DBMS_SQL.NUMBER_TABLE;
  l_unit_of_measure_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_neg_by_prep_flag_tbl        DBMS_SQL.VARCHAR2_TABLE;
  l_primary_category_id_tbl     DBMS_SQL.NUMBER_TABLE;
  l_po_category_id_tbl          DBMS_SQL.VARCHAR2_TABLE;
  l_supp_part_num_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_supp_part_auxid_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_description_tbl             DBMS_SQL.VARCHAR2_TABLE;
  l_catalog_name_tbl            DBMS_SQL.VARCHAR2_TABLE;
  l_po_interface_header_id_tbl  DBMS_SQL.NUMBER_TABLE;
  l_upg_created_language_tbl    DBMS_SQL.VARCHAR2_TABLE;
  l_po_interface_line_id_tbl    DBMS_SQL.NUMBER_TABLE;
  l_price_type_tbl              DBMS_SQL.VARCHAR2_TABLE;
  l_primary_category_name_tbl   DBMS_SQL.VARCHAR2_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name            CONSTANT VARCHAR2(30)   := 'checkAndProcessGBPALines';
  l_err_loc             PLS_INTEGER;
  l_err_string          VARCHAR2(4000);
  l_start_rt_item_id    NUMBER;
  l_batch_count         PLS_INTEGER;
  l_item_row_count      PLS_INTEGER;
  l_interface_line_id   NUMBER;
  l_interface_header_id NUMBER;
  l_po_category_id      NUMBER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
  l_log_index           NUMBER := 1;
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 110;
  l_start_rt_item_id := 0;
  l_batch_count := 0;
  l_item_row_count := 0;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Current Values in g_current_gbpa_hdr_rec:'||
        ', org_id:' ||g_current_gbpa_hdr_rec.org_id ||
        ', supplier_id:' ||g_current_gbpa_hdr_rec.vendor_id ||
        ', supplier_site_id:' ||g_current_gbpa_hdr_rec.vendor_site_id ||
        ', currency:' ||g_current_gbpa_hdr_rec.currency_code ||
        ', gbpa_cpa_reference:' ||g_current_gbpa_hdr_rec.cpa_reference ||
        ', language:' ||g_current_gbpa_hdr_rec.language ||
        ', interface_header_id:' ||g_current_gbpa_hdr_rec.interface_header_id );
  END IF;

  -- line_type will be defaulted by PDOI.
  l_err_loc := 120;
  OPEN checkAndProcessGBPALinesCsr(g_current_gbpa_hdr_rec.org_id, g_current_gbpa_hdr_rec.vendor_id,
               g_current_gbpa_hdr_rec.vendor_site_id, g_current_gbpa_hdr_rec.currency_code,
               g_current_gbpa_hdr_rec.cpa_reference, g_current_gbpa_hdr_rec.language,
               l_start_rt_item_id);
  LOOP
    l_err_loc := 130;
    l_rt_item_id_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_unit_of_measure_tbl.DELETE;
    l_neg_by_prep_flag_tbl.DELETE;
    l_primary_category_id_tbl.DELETE;
    l_po_category_id_tbl.DELETE;
    l_supp_part_num_tbl.DELETE;
    l_supp_part_auxid_tbl.DELETE;
    l_description_tbl.DELETE;
    l_catalog_name_tbl.DELETE;
    l_po_interface_header_id_tbl.DELETE;
    l_upg_created_language_tbl.DELETE;
    l_po_interface_line_id_tbl.DELETE;
    l_price_type_tbl.DELETE;
    l_primary_category_name_tbl.DELETE;

    BEGIN
      l_err_loc := 140;
      FETCH checkAndProcessGBPALinesCsr BULK COLLECT INTO
            l_rt_item_id_tbl, l_unit_price_tbl, l_unit_of_measure_tbl,
            l_neg_by_prep_flag_tbl, l_primary_category_id_tbl, l_po_category_id_tbl,
            l_supp_part_num_tbl, l_supp_part_auxid_tbl, l_description_tbl, l_catalog_name_tbl,
            l_po_interface_header_id_tbl, l_upg_created_language_tbl, l_po_interface_line_id_tbl,
            l_price_type_tbl, l_primary_category_name_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      l_err_loc := 160;
      EXIT WHEN l_rt_item_id_tbl.COUNT = 0;

      l_err_loc := 170;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 180;
      --Save the last rt_item_id processed,
      --so that re-open of cursor will start from the saved rt_item_id.
      l_start_rt_item_id := l_rt_item_id_tbl(l_rt_item_id_tbl.COUNT);

      l_err_loc := 190;
      l_item_row_count := l_item_row_count + l_rt_item_id_tbl.COUNT;

      l_err_loc := 200;
      FOR i in 1..l_rt_item_id_tbl.COUNT LOOP
        l_log_index := i;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Values fetched from the cursor; '||
              'l_rt_item_id_tbl:' || l_rt_item_id_tbl(i) ||
              ', l_supp_part_num_tbl:' || l_supp_part_num_tbl(i) ||
              ', item language:' || g_current_gbpa_hdr_rec.language ||
              ', l_price_type_tbl:' || l_price_type_tbl(i) ||
              ', l_po_interface_header_id_tbl:' || l_po_interface_header_id_tbl(i) ||
              ', l_upg_created_language_tbl:' || l_upg_created_language_tbl(i) ||
              ', l_po_interface_line_id_tbl:' || l_po_interface_line_id_tbl(i));
        END IF;

        l_err_loc := 210;
        IF (l_po_interface_header_id_tbl(i) IS NULL) THEN
          IF (l_interface_header_id IS NULL) THEN
             --Create the header record only once for the
             --current combination of header attributes
             l_interface_header_id := getNextInterfaceHdrIdFromSeq;
             IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                   ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                   'about to create a new po_header_id with the following values' ||
                   '--> l_interface_header_id set to :' || l_interface_header_id ||
                   ', org_id:' || g_current_gbpa_hdr_rec.org_id ||
                   ', vendor_id:' || g_current_gbpa_hdr_rec.vendor_id ||
                   ', vendor_site_id:' || g_current_gbpa_hdr_rec.vendor_site_id ||
                   ', currency_code:' || g_current_gbpa_hdr_rec.currency_code ||
                   ', language:' || g_current_gbpa_hdr_rec.language);
             END IF;

             l_err_loc := 215;
             g_po_hdrs_int_rec.interface_header_id              := l_interface_header_id;
             g_po_hdrs_int_rec.action                           := 'ORIGINAL';
             g_po_hdrs_int_rec.org_id                           := g_current_gbpa_hdr_rec.org_id;
             g_po_hdrs_int_rec.document_type_code               := 'BLANKET';
             g_po_hdrs_int_rec.budget_account_segment1          := null;
             g_po_hdrs_int_rec.po_header_id                     := null;
             g_po_hdrs_int_rec.approval_status                  := 'IN PROCESS';
             g_po_hdrs_int_rec.vendor_id                        := g_current_gbpa_hdr_rec.vendor_id;
             g_po_hdrs_int_rec.vendor_site_id                   := g_current_gbpa_hdr_rec.vendor_site_id;
             l_err_loc := 220;
             g_po_hdrs_int_rec.currency_code                    := g_current_gbpa_hdr_rec.currency_code;
             g_po_hdrs_int_rec.created_language                 := g_current_gbpa_hdr_rec.language;
             g_po_hdrs_int_rec.comments                         := g_new_GBPA_description;

             l_err_loc := 230;
             IF (g_current_gbpa_hdr_rec.cpa_reference <> ICX_CAT_UTIL_PVT.g_NULL_NUMBER) THEN
               g_po_hdrs_int_rec.cpa_reference                  := g_current_gbpa_hdr_rec.cpa_reference;
             ELSE
               g_po_hdrs_int_rec.cpa_reference                  := null;
             END IF;

             l_err_loc := 240;
             g_GBPA_hdr_count := g_GBPA_hdr_count + 1;
             insertPOHeadersInterface;
          END IF;

          l_err_loc := 250;
          --Get the next interfaceLineId to be used in po_lines_interface,
          --po_attr_values_interface and po_attr_values_tlp_interface
          l_interface_line_id := getNextInterfaceLineIdFromSeq;

          l_err_loc := 260;
          l_po_category_id := TO_NUMBER(l_po_category_id_tbl(i));

          l_err_loc := 270;
          --Put the current values into g_po_line_attrval_int_rec for
          --po_lines_interface and po_attr_values_interface
          g_po_line_attrval_int_rec.interface_line_id           := l_interface_line_id;
          g_po_line_attrval_int_rec.interface_header_id         := l_interface_header_id;
          g_po_line_attrval_int_rec.action                      := 'ADD';
          g_po_line_attrval_int_rec.po_line_id                  := null;
          g_po_line_attrval_int_rec.po_header_id                := null;
          l_err_loc := 272;
          g_po_line_attrval_int_rec.unit_price                  := l_unit_price_tbl(i);
          g_po_line_attrval_int_rec.uom_code                    := l_unit_of_measure_tbl(i);
          g_po_line_attrval_int_rec.negotiated_by_preparer_flag := l_neg_by_prep_flag_tbl(i);
          g_po_line_attrval_int_rec.ip_category_id              := l_primary_category_id_tbl(i);
          g_po_line_attrval_int_rec.category_id                 := l_po_category_id;
          l_err_loc := 274;
          g_po_line_attrval_int_rec.category_name               := l_primary_category_name_tbl(i);
          l_err_loc := 276;
          g_po_line_attrval_int_rec.vendor_product_num          := l_supp_part_num_tbl(i);
          g_po_line_attrval_int_rec.supplier_part_auxid         := l_supp_part_auxid_tbl(i);
          l_err_loc := 278;
          g_po_line_attrval_int_rec.item_description            := l_description_tbl(i);
          l_err_loc := 280;
          g_po_line_attrval_int_rec.catalog_name                := l_catalog_name_tbl(i);
          g_po_line_attrval_int_rec.req_template_name           := '-2';
          g_po_line_attrval_int_rec.req_template_line_num       := -2;
          g_po_line_attrval_int_rec.inventory_item_id           := -2;
          g_po_line_attrval_int_rec.org_id                      := g_current_gbpa_hdr_rec.org_id;
          g_po_line_attrval_int_rec.rt_item_id                  := l_rt_item_id_tbl(i);
          g_po_line_attrval_int_rec.language                    := g_current_gbpa_hdr_rec.language;

          l_err_loc := 282;
          -- Put the current values into g_po_attrvalstlp_int_rec for
          -- po_attr_values_tlp_interface
          g_po_attrvalstlp_int_rec.interface_header_id          := l_interface_header_id;
          g_po_attrvalstlp_int_rec.interface_line_id            := l_interface_line_id;

          l_err_loc := 284;
          g_r12_upg_rec.rt_item_id                              := l_rt_item_id_tbl(i);
          g_r12_upg_rec.supplier_site_id                        := g_current_gbpa_hdr_rec.vendor_site_id;
          g_r12_upg_rec.currency                                := g_current_gbpa_hdr_rec.currency_code;
          -- icx_cat_r12_upgrade.price_contract_id is same as the contract_id in price table
          -- icx_cat_r12_upgrade.src_contract_id is same as the contract_id returned from autosource
          -- Need both contract_ids to figure out any changes in the source document during delta processing.
          l_err_loc := 285;
          IF (l_price_type_tbl(i) = 'BULKLOAD') THEN
            g_r12_upg_rec.price_contract_id                     := -2;
            g_r12_upg_rec.src_contract_id                       := g_current_gbpa_hdr_rec.cpa_reference;
          ELSE
            g_r12_upg_rec.price_contract_id                     := g_current_gbpa_hdr_rec.cpa_reference;
            g_r12_upg_rec.src_contract_id                       := -2;
          END IF;
          g_r12_upg_rec.cpa_reference                           := g_current_gbpa_hdr_rec.cpa_reference;
          l_err_loc := 287;
          g_r12_upg_rec.po_category_id                          := l_po_category_id_tbl(i);
          g_r12_upg_rec.po_interface_header_id                  := l_interface_header_id;
          g_r12_upg_rec.po_interface_line_id                    := l_interface_line_id;
          g_r12_upg_rec.created_language                        := g_current_gbpa_hdr_rec.language;
          -- TBD g_r12_upg_rec.extractor_updated_flag                   := 'N';

          l_err_loc := 289;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'inserting into lines, attr_values and r12 upgrade');
          END IF;
          l_err_loc := 290;
          --Add the current value to the global pl/sql tables
          insertPOLinesInterface;
          l_err_loc := 292;
          insertPOAttrValsInterface;
          l_err_loc := 294;
          insertR12Upgrade;
        ELSE  --l_po_interface_header_id_tbl(i) IS NOT NULL
          --i.e. upg.rt_item_id = price.rt_item_id and
          --upg.created_language <> g_current_gbpa_hdr_rec.language
          --i.e. this is a translation row of an item already inserted
          --into po_lines_interface and po_attr_values_interface in processGBPALines
          --Put the current values into g_po_attrvalstlp_int_rec for it to be inserted into
          --po_attr_values_tlp_interface
          l_err_loc := 296;
          g_po_attrvalstlp_int_rec.interface_header_id          := l_po_interface_header_id_tbl(i) ;
          g_po_attrvalstlp_int_rec.interface_line_id            := l_po_interface_line_id_tbl(i);
        END IF;

        g_po_attrvalstlp_int_rec.action                         := 'ADD';
        g_po_attrvalstlp_int_rec.po_line_id                     := null;
        g_po_attrvalstlp_int_rec.req_template_name              := '-2';
        g_po_attrvalstlp_int_rec.req_template_line_num          := -2;
        g_po_attrvalstlp_int_rec.inventory_item_id              := -2;
        g_po_attrvalstlp_int_rec.org_id                         := g_current_gbpa_hdr_rec.org_id;
        l_err_loc := 297;
        g_po_attrvalstlp_int_rec.language                       := g_current_gbpa_hdr_rec.language;
        g_po_attrvalstlp_int_rec.check_desc_update              := ICX_CAT_UTIL_PVT.g_update_description;
        g_po_attrvalstlp_int_rec.rt_item_id                     := l_rt_item_id_tbl(i);

        l_err_loc := 298;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'inserting only into attr_values_tlp');
        END IF;
        l_err_loc := 299;
        --Add the current value to the global pl/sql tables
        insertPOAttrValsTLPInterface;

        l_err_loc := 300;
        populatePOInterfaceTables('INLOOP');
      END LOOP;  --FOR LOOP of l_rt_item_id_tbl

      l_err_loc := 310;
      EXIT WHEN l_rt_item_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
                        || ', Total processeded batches:' || l_batch_count
                        || ', Cursor will be reopened with rt_item_id:' || l_start_rt_item_id;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 330;
        IF (checkAndProcessGBPALinesCsr%ISOPEN) THEN
          CLOSE checkAndProcessGBPALinesCsr;
          OPEN checkAndProcessGBPALinesCsr
               (g_current_gbpa_hdr_rec.org_id, g_current_gbpa_hdr_rec.vendor_id,
                g_current_gbpa_hdr_rec.vendor_site_id, g_current_gbpa_hdr_rec.currency_code,
                g_current_gbpa_hdr_rec.cpa_reference, g_current_gbpa_hdr_rec.language,
                l_start_rt_item_id);
        END IF;
    END;
  END LOOP; --CURSOR LOOP

  l_err_loc := 350;
  populatePOInterfaceTables('OUTLOOP');

  IF (checkAndProcessGBPALinesCsr%ISOPEN) THEN
    CLOSE checkAndProcessGBPALinesCsr;
  END IF;

  l_err_loc := 360;
  g_total_bulkld_row_count := g_total_bulkld_row_count + l_item_row_count;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done; '||
        'Total no: of batches processed:' || l_batch_count ||
        ', Total no: of bulkloaded items processed:' || l_item_row_count);
  END IF;

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

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Current Values in g_current_gbpa_hdr_rec:'||
          ', org_id:' ||g_current_gbpa_hdr_rec.org_id ||
          ', supplier_id:' ||g_current_gbpa_hdr_rec.vendor_id ||
          ', supplier_site_id:' ||g_current_gbpa_hdr_rec.vendor_site_id ||
          ', currency:' ||g_current_gbpa_hdr_rec.currency_code ||
          ', gbpa_cpa_reference:' ||g_current_gbpa_hdr_rec.cpa_reference ||
          ', language:' ||g_current_gbpa_hdr_rec.language ||
          ', interface_header_id:' ||g_current_gbpa_hdr_rec.interface_header_id  );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Values fetched from the cursor; '||
          'l_rt_item_id_tbl:' || l_rt_item_id_tbl(l_log_index) ||
          ', l_supp_part_num_tbl:' || l_supp_part_num_tbl(l_log_index) ||
          ', l_supp_part_auxid_tbl:' || l_supp_part_auxid_tbl(l_log_index) ||
          ', l_unit_price_tbl:' || l_unit_price_tbl(l_log_index) ||
          ', l_unit_of_measure_tbl:' || l_unit_of_measure_tbl(l_log_index) ||
          ', l_neg_by_prep_flag_tbl:' || l_neg_by_prep_flag_tbl(l_log_index) ||
          ', l_primary_category_id_tbl:' || l_primary_category_id_tbl(l_log_index) ||
          ', l_po_category_id_tbl:' || l_po_category_id_tbl(l_log_index) ||
          ', l_price_type_tbl:' || l_price_type_tbl(l_log_index) ||
          ', l_po_interface_header_id_tbl:' || l_po_interface_header_id_tbl(l_log_index) ||
          ', l_upg_created_language_tbl:' || l_upg_created_language_tbl(l_log_index) ||
          ', l_po_interface_line_id_tbl:' || l_po_interface_line_id_tbl(l_log_index));
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Values fetched from the cursor; '||
          'l_description_tbl:' || l_description_tbl(l_log_index) ||
          ', l_catalog_name_tbl:' || l_catalog_name_tbl(l_log_index) ||
          ', l_primary_category_name_tbl:' || l_primary_category_name_tbl(l_log_index));
    END IF;

    raise;
END checkAndProcessGBPALines;

PROCEDURE processGBPALines
IS
  -- We need price_type, to getthe price_contract_id and src_contract_id
  -- because if autosource returned a contract_id
  -- then src.contract_id will not be same as price.contract_id.
  CURSOR processGBPALinesCsr(p_org_id NUMBER, p_supplier_id NUMBER,
                             p_supplier_site_id NUMBER, p_currency VARCHAR2,
                             p_cpa_reference NUMBER, p_language VARCHAR2,
                             p_start_rt_item_id NUMBER) IS
    SELECT itemtlp.rt_item_id, price.unit_price, price.unit_of_measure,
           DECODE(NVL(price.negotiated_by_preparer_flag, '1'), '0', 'N', 'Y') negotiated_by_preparer_flag,
           itemtlp.primary_category_id, NVL(map.external_source_key, '-2') po_category_id,
           SUBSTRB(itemtlp.supplier_part_num, 1, 25) supplier_part_num,
           DECODE(itemtlp.supplier_part_auxid, '##NULL##', null, itemtlp.supplier_part_auxid),
           SUBSTRB(itemtlp.description, 1, 240) description,
           itemsb.catalog_name, price.price_type, itemtlp.primary_category_name
    FROM   icx_cat_item_prices price, icx_cat_items_tlp itemtlp, icx_cat_items_b itemsb,
           icx_por_category_order_map map, icx_cat_r12_upg_autosource src
    WHERE  price.price_type = 'BULKLOAD'
    AND    price.rt_item_id = itemtlp.rt_item_id
    AND    price.rt_item_id = itemsb.rt_item_id
    AND    NOT EXISTS (SELECT 'extracted price'
                       FROM   icx_cat_item_prices priceIn
                       WHERE  priceIn.rt_item_id = price.rt_item_id
                       AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                     'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
    AND    itemtlp.primary_category_id = map.rt_category_id (+)
    AND    itemtlp.org_id = src.org_id
    AND    itemtlp.supplier_id = src.supplier_id
    AND    price.supplier_site_id = src.supplier_site_id
    AND    price.currency = src.currency
    AND    NVL(map.external_source_key, '-2') = src.po_category_id
    AND    itemtlp.rt_item_id >= p_start_rt_item_id
    AND    itemtlp.language = p_language
    AND    src.org_id = p_org_id
    AND    src.supplier_id = p_supplier_id
    AND    src.supplier_site_id = p_supplier_site_id
    AND    src.currency = p_currency
    AND    src.contract_id = p_cpa_reference
    UNION ALL
    SELECT itemtlp.rt_item_id, price.unit_price, price.unit_of_measure,
           DECODE(NVL(price.negotiated_by_preparer_flag, '1'), '0', 'N', 'Y') negotiated_by_preparer_flag,
           itemtlp.primary_category_id, NVL(map.external_source_key, '-2') po_category_id,
           SUBSTRB(itemtlp.supplier_part_num, 1, 25) supplier_part_num,
           DECODE(itemtlp.supplier_part_auxid, '##NULL##', null, itemtlp.supplier_part_auxid),
           SUBSTRB(itemtlp.description, 1, 240) description,
           itemsb.catalog_name, price.price_type, itemtlp.primary_category_name
    FROM   icx_cat_item_prices price, icx_cat_items_tlp itemtlp, icx_cat_items_b itemsb,
           icx_por_category_order_map map
    WHERE  price.price_type = 'CONTRACT'
    AND    price.rt_item_id = itemtlp.rt_item_id
    AND    price.rt_item_id = itemsb.rt_item_id
    AND    NOT EXISTS (SELECT 'extracted price'
                       FROM   icx_cat_item_prices priceIn
                       WHERE  priceIn.rt_item_id = price.rt_item_id
                       AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                     'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
    AND    itemtlp.primary_category_id = map.rt_category_id (+)
    AND    itemtlp.rt_item_id >= p_start_rt_item_id
    AND    itemtlp.language = p_language
    AND    itemtlp.org_id = p_org_id
    AND    itemtlp.supplier_id = p_supplier_id
    AND    price.supplier_site_id = p_supplier_site_id
    AND    price.currency = p_currency
    AND    price.contract_id = p_cpa_reference
    ORDER BY 1;

  ----- Start of declaring columns selected in the cursor -----

  l_rt_item_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_unit_price_tbl              DBMS_SQL.NUMBER_TABLE;
  l_unit_of_measure_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_neg_by_prep_flag_tbl        DBMS_SQL.VARCHAR2_TABLE;
  l_primary_category_id_tbl     DBMS_SQL.NUMBER_TABLE;
  l_po_category_id_tbl          DBMS_SQL.VARCHAR2_TABLE;
  l_supp_part_num_tbl           DBMS_SQL.VARCHAR2_TABLE;
  l_supp_part_auxid_tbl         DBMS_SQL.VARCHAR2_TABLE;
  l_description_tbl             DBMS_SQL.VARCHAR2_TABLE;
  l_catalog_name_tbl            DBMS_SQL.VARCHAR2_TABLE;
  l_price_type_tbl              DBMS_SQL.VARCHAR2_TABLE;
  l_primary_category_name_tbl   DBMS_SQL.VARCHAR2_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name            CONSTANT VARCHAR2(30)   := 'processGBPALines';
  l_err_loc             PLS_INTEGER;
  l_err_string          VARCHAR2(4000);
  l_start_rt_item_id    NUMBER;
  l_batch_count         PLS_INTEGER;
  l_item_row_count      PLS_INTEGER;
  l_interface_line_id   NUMBER;
  l_po_category_id      NUMBER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
  l_log_index           NUMBER := 1;
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 110;
  l_start_rt_item_id := 0;
  l_batch_count := 0;
  l_item_row_count := 0;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Current Values in g_current_gbpa_hdr_rec:'||
        ', org_id:' ||g_current_gbpa_hdr_rec.org_id ||
        ', supplier_id:' ||g_current_gbpa_hdr_rec.vendor_id ||
        ', supplier_site_id:' ||g_current_gbpa_hdr_rec.vendor_site_id ||
        ', currency:' ||g_current_gbpa_hdr_rec.currency_code ||
        ', gbpa_cpa_reference:' ||g_current_gbpa_hdr_rec.cpa_reference ||
        ', language:' ||g_current_gbpa_hdr_rec.language ||
        ', interface_header_id:' ||g_current_gbpa_hdr_rec.interface_header_id );
  END IF;

  l_err_loc := 120;
  --line_type will be defaulted by PDOI.
  OPEN processGBPALinesCsr(g_current_gbpa_hdr_rec.org_id, g_current_gbpa_hdr_rec.vendor_id,
               g_current_gbpa_hdr_rec.vendor_site_id, g_current_gbpa_hdr_rec.currency_code,
               g_current_gbpa_hdr_rec.cpa_reference, g_current_gbpa_hdr_rec.language,
               l_start_rt_item_id);
  LOOP
    l_err_loc := 130;
    l_rt_item_id_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_unit_of_measure_tbl.DELETE;
    l_neg_by_prep_flag_tbl.DELETE;
    l_primary_category_id_tbl.DELETE;
    l_po_category_id_tbl.DELETE;
    l_supp_part_num_tbl.DELETE;
    l_supp_part_auxid_tbl.DELETE;
    l_description_tbl.DELETE;
    l_catalog_name_tbl.DELETE;
    l_price_type_tbl.DELETE;
    l_primary_category_name_tbl.DELETE;

    BEGIN
      l_err_loc := 140;
      FETCH processGBPALinesCsr BULK COLLECT INTO
            l_rt_item_id_tbl, l_unit_price_tbl, l_unit_of_measure_tbl,
            l_neg_by_prep_flag_tbl, l_primary_category_id_tbl,
            l_po_category_id_tbl, l_supp_part_num_tbl,
            l_supp_part_auxid_tbl, l_description_tbl,
            l_catalog_name_tbl, l_price_type_tbl,
            l_primary_category_name_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      l_err_loc := 160;
      EXIT WHEN l_rt_item_id_tbl.COUNT = 0;

      l_err_loc := 170;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 180;
      --Save the last rt_item_id processed,
      --so that re-open of cursor will start from the saved rt_item_id.
      l_start_rt_item_id := l_rt_item_id_tbl(l_rt_item_id_tbl.COUNT);

      l_err_loc := 190;
      l_item_row_count := l_item_row_count + l_rt_item_id_tbl.COUNT;

      l_err_loc := 200;
      FOR i in 1..l_rt_item_id_tbl.COUNT LOOP
        l_log_index := i;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Values fetched from the cursor; '||
              'l_rt_item_id_tbl:' || l_rt_item_id_tbl(i) ||
              ', l_supp_part_num_tbl:' || l_supp_part_num_tbl(i) ||
              ', item language:' || g_current_gbpa_hdr_rec.language ||
              ', l_price_type_tbl:' || l_price_type_tbl(i) );
        END IF;

        l_err_loc := 210;
        --Get the next interfaceLineId to be used in po_lines_interface,
        --po_attr_values_interface and po_attr_values_tlp_interface
        l_interface_line_id := getNextInterfaceLineIdFromSeq;

        l_err_loc := 220;
        l_po_category_id := TO_NUMBER(l_po_category_id_tbl(i));

        l_err_loc := 230;
        --Put the current values into g_po_line_attrval_int_rec for
        --po_lines_interface and po_attr_values_interface
        g_po_line_attrval_int_rec.interface_line_id             := l_interface_line_id;
        g_po_line_attrval_int_rec.interface_header_id           := g_current_gbpa_hdr_rec.interface_header_id ;
        g_po_line_attrval_int_rec.action                        := 'ADD';
        g_po_line_attrval_int_rec.po_line_id                    := null;
        g_po_line_attrval_int_rec.po_header_id                  := null;
        g_po_line_attrval_int_rec.unit_price                    := l_unit_price_tbl(i);
        l_err_loc := 232;
        g_po_line_attrval_int_rec.uom_code                      := l_unit_of_measure_tbl(i);
        g_po_line_attrval_int_rec.negotiated_by_preparer_flag   := l_neg_by_prep_flag_tbl(i);
        g_po_line_attrval_int_rec.ip_category_id                := l_primary_category_id_tbl(i);
        g_po_line_attrval_int_rec.category_id                   := l_po_category_id;
        l_err_loc := 234;
        g_po_line_attrval_int_rec.category_name                 := l_primary_category_name_tbl(i);
        l_err_loc := 236;
        g_po_line_attrval_int_rec.vendor_product_num            := l_supp_part_num_tbl(i);
        g_po_line_attrval_int_rec.supplier_part_auxid           := l_supp_part_auxid_tbl(i);
        l_err_loc := 238;
        g_po_line_attrval_int_rec.item_description              := l_description_tbl(i);
        g_po_line_attrval_int_rec.catalog_name                  := l_catalog_name_tbl(i);
        g_po_line_attrval_int_rec.req_template_name             := '-2';
        g_po_line_attrval_int_rec.req_template_line_num         := -2;
        g_po_line_attrval_int_rec.inventory_item_id             := -2;
        g_po_line_attrval_int_rec.org_id                        := g_current_gbpa_hdr_rec.org_id;
        g_po_line_attrval_int_rec.rt_item_id                    := l_rt_item_id_tbl(i);
        g_po_line_attrval_int_rec.language                      := g_current_gbpa_hdr_rec.language;

        l_err_loc := 240;
        --Put the current values into g_po_attrvalstlp_int_rec for
        --po_attr_values_tlp_interface
        g_po_attrvalstlp_int_rec.interface_header_id            := g_current_gbpa_hdr_rec.interface_header_id ;
        g_po_attrvalstlp_int_rec.interface_line_id              := l_interface_line_id;
        g_po_attrvalstlp_int_rec.action                         := 'ADD';
        g_po_attrvalstlp_int_rec.po_line_id                     := null;
        g_po_attrvalstlp_int_rec.req_template_name              := '-2';
        g_po_attrvalstlp_int_rec.req_template_line_num          := -2;
        g_po_attrvalstlp_int_rec.inventory_item_id              := -2;
        g_po_attrvalstlp_int_rec.org_id                         := g_current_gbpa_hdr_rec.org_id;
        l_err_loc := 242;
        g_po_attrvalstlp_int_rec.language                       := g_current_gbpa_hdr_rec.language;
        g_po_attrvalstlp_int_rec.check_desc_update              := ICX_CAT_UTIL_PVT.g_update_description;
        g_po_attrvalstlp_int_rec.rt_item_id                     := l_rt_item_id_tbl(i);

        l_err_loc := 244;
        g_r12_upg_rec.rt_item_id                                := l_rt_item_id_tbl(i);
        g_r12_upg_rec.supplier_site_id                          := g_current_gbpa_hdr_rec.vendor_site_id;
        g_r12_upg_rec.currency                                  := g_current_gbpa_hdr_rec.currency_code;
        -- icx_cat_r12_upgrade.price_contract_id is same as the contract_id in price table
        -- icx_cat_r12_upgrade.src_contract_id is same as the contract_id returned from autosource
        -- Need both contract_ids to figure out any changes in the source document during delta processing.
        l_err_loc := 246;
        IF (l_price_type_tbl(i) = 'BULKLOAD') THEN
          g_r12_upg_rec.price_contract_id                       := -2;
          g_r12_upg_rec.src_contract_id                         := g_current_gbpa_hdr_rec.cpa_reference;
        ELSE
          l_err_loc := 248;
          g_r12_upg_rec.price_contract_id                       := g_current_gbpa_hdr_rec.cpa_reference;
          g_r12_upg_rec.src_contract_id                         := -2;
        END IF;
        l_err_loc := 250;
        g_r12_upg_rec.cpa_reference                             := g_current_gbpa_hdr_rec.cpa_reference;
        g_r12_upg_rec.po_category_id                            := l_po_category_id_tbl(i);
        g_r12_upg_rec.po_interface_header_id                    := g_current_gbpa_hdr_rec.interface_header_id;
        g_r12_upg_rec.po_interface_line_id                      := l_interface_line_id;
        l_err_loc := 252;
        g_r12_upg_rec.created_language                          := g_current_gbpa_hdr_rec.language;
        -- TBD g_r12_upg_rec.extractor_updated_flag             := 'N';

        l_err_loc := 254;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'inserting into lines, attr_values, attr_values_tlp and r12 upgrade');
        END IF;
        --Add the current value to the global pl/sql tables
        l_err_loc := 256;
        insertPOLinesInterface;
        l_err_loc := 258;
        insertPOAttrValsInterface;
        l_err_loc := 260;
        insertPOAttrValsTLPInterface;
        l_err_loc := 262;
        insertR12Upgrade;

        l_err_loc := 300;
        populatePOInterfaceTables('INLOOP');
      END LOOP;  --FOR LOOP of l_rt_item_id_tbl

      l_err_loc := 310;
      EXIT WHEN l_rt_item_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
                        || ', Total processeded batches:' || l_batch_count
                        || ', Cursor will be reopened with rt_item_id:' || l_start_rt_item_id;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 330;
        IF (processGBPALinesCsr%ISOPEN) THEN
          CLOSE processGBPALinesCsr;
          OPEN processGBPALinesCsr
               (g_current_gbpa_hdr_rec.org_id, g_current_gbpa_hdr_rec.vendor_id,
                g_current_gbpa_hdr_rec.vendor_site_id, g_current_gbpa_hdr_rec.currency_code,
                g_current_gbpa_hdr_rec.cpa_reference, g_current_gbpa_hdr_rec.language,
                l_start_rt_item_id);
        END IF;
    END;
  END LOOP; --CURSOR LOOP

  l_err_loc := 350;
  populatePOInterfaceTables('OUTLOOP');

  IF (processGBPALinesCsr%ISOPEN) THEN
    CLOSE processGBPALinesCsr;
  END IF;

  l_err_loc := 360;
  g_total_bulkld_row_count := g_total_bulkld_row_count + l_item_row_count;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done; '||
        'Total no: of batches processed:' ||l_batch_count ||
        ', Total no: of bulkloaded items processed:' ||l_item_row_count);
  END IF;

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

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Current Values in g_current_gbpa_hdr_rec:'||
          ', org_id:' ||g_current_gbpa_hdr_rec.org_id ||
          ', supplier_id:' ||g_current_gbpa_hdr_rec.vendor_id ||
          ', supplier_site_id:' ||g_current_gbpa_hdr_rec.vendor_site_id ||
          ', currency:' ||g_current_gbpa_hdr_rec.currency_code ||
          ', gbpa_cpa_reference:' ||g_current_gbpa_hdr_rec.cpa_reference ||
          ', language:' ||g_current_gbpa_hdr_rec.language ||
          ', interface_header_id:' ||g_current_gbpa_hdr_rec.interface_header_id );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Values fetched from the cursor; '||
          'l_rt_item_id_tbl:' || l_rt_item_id_tbl(l_log_index) ||
          ', l_supp_part_num_tbl:' || l_supp_part_num_tbl(l_log_index) ||
          ', l_supp_part_auxid_tbl:' || l_supp_part_auxid_tbl(l_log_index) ||
          ', l_unit_price_tbl:' || l_unit_price_tbl(l_log_index) ||
          ', l_unit_of_measure_tbl:' || l_unit_of_measure_tbl(l_log_index) ||
          ', l_neg_by_prep_flag_tbl:' || l_neg_by_prep_flag_tbl(l_log_index) ||
          ', l_primary_category_id_tbl:' || l_primary_category_id_tbl(l_log_index) ||
          ', l_po_category_id_tbl:' || l_po_category_id_tbl(l_log_index) ||
          ', l_price_type_tbl:' || l_price_type_tbl(l_log_index) );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Values fetched from the cursor; '||
          'l_description_tbl:' || l_description_tbl(l_log_index) ||
          ', l_catalog_name_tbl:' || l_catalog_name_tbl(l_log_index) ||
          ', l_primary_category_name_tbl:' || l_primary_category_name_tbl(l_log_index));
    END IF;

    raise;
END processGBPALines;

PROCEDURE createGBPAsForBlkldItems
IS
  -- Join with icx_cat_r12_upg_autosource on org_id, supplier_id,
  -- supplier_site_id, currency and po_category_id
  -- Group on org_id, supplier_id, supplier_site_id, currency, contract_id and language.
  -- Cannot group on po_category_id because the number of GBPA to be created will increase
  -- depending on po_category_id.
  -- We need price_contract_id, because if autosource returned a contract_id
  -- then src.contract_id will not be same as price.contract_id.
  -- Added the decode for supplier and supplier_site_code, because of some corrupt data
  -- that exists on the internal envs (also on gevt11i).
  -- The details: supplier_site_id = -2 but supplier_site_code is not null
  -- supplier_id = -2 but supplier is not null
  CURSOR createGBPAHdrsForBlkldItemsCsr IS
    SELECT doc.*,
           COUNT(*) count
    FROM (
           SELECT src.org_id org_id, src.supplier_id supplier_id,
                  src.supplier_site_id supplier_site_id, src.currency currency,
                  src.contract_id gbpa_cpa_reference,
                  itemtlp.language language
           FROM   icx_cat_r12_upg_autosource src, icx_cat_item_prices price,
                  icx_cat_items_tlp itemtlp, icx_por_category_order_map map
           WHERE  price.price_type = 'BULKLOAD'
           AND    price.rt_item_id = itemtlp.rt_item_id
           AND    NOT EXISTS (SELECT 'extracted price'
                              FROM   icx_cat_item_prices priceIn
                              WHERE  priceIn.rt_item_id = price.rt_item_id
                              AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                            'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
           AND    itemtlp.primary_category_id = map.rt_category_id (+)
           AND    itemtlp.org_id = src.org_id
           AND    itemtlp.supplier_id = src.supplier_id
           AND    price.supplier_site_id = src.supplier_site_id
           AND    price.currency = src.currency
           AND    NVL(map.external_source_key, '-2') = src.po_category_id
           UNION ALL
           -- Added NVL to org_id, supplier, site and currency
           SELECT NVL(itemtlp.org_id, -2) org_id, NVL(itemtlp.supplier_id, -2) supplier_id,
                  NVL(price.supplier_site_id, -2) supplier_site_id, NVL(price.currency, '-2') currency,
                  price.contract_id gbpa_cpa_reference,
                  itemtlp.language language
           FROM   icx_cat_item_prices price, icx_cat_items_tlp itemtlp
           WHERE  price.price_type = 'CONTRACT'
           AND    price.rt_item_id = itemtlp.rt_item_id
           AND    NOT EXISTS (SELECT 'extracted price'
                              FROM   icx_cat_item_prices priceIn
                              WHERE  priceIn.rt_item_id = price.rt_item_id
                              AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                            'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
           ) doc
    GROUP BY doc.org_id, doc.supplier_id, doc.supplier_site_id,
             doc.currency, doc.gbpa_cpa_reference,
             doc.language
    ORDER BY doc.org_id, doc.supplier_id, doc.supplier_site_id,
             doc.currency, doc.gbpa_cpa_reference,
             count DESC, doc.language;

  ----- Start of declaring columns selected in the cursor -----
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_supplier_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_supplier_site_id_tbl        DBMS_SQL.NUMBER_TABLE;
  l_currency_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_gbpa_cpa_reference_tbl      DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_count_tbl                   DBMS_SQL.NUMBER_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'createGBPAsForBlkldItems';
  l_err_loc                     PLS_INTEGER;
  l_prev_org_id                 NUMBER;
  l_prev_supplier_id            NUMBER;
  l_prev_supplier_site_id       NUMBER;
  l_prev_currency               icx_cat_item_prices.currency%TYPE;
  l_prev_contract_id            NUMBER;
  l_interface_header_id         NUMBER;
  l_start_date          	DATE;
  l_end_date            	DATE;
  l_log_string			VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_err_loc := 110;
  -- Perform the contract auto sourcing
  contractAutoSourcing;

  l_err_loc := 115;
  --Assign the previous values to some dummy values
  l_prev_org_id := -1212;
  l_prev_supplier_id := -1212;
  l_prev_supplier_site_id := -1212;
  l_prev_currency := '-12';
  l_prev_contract_id := -1212;

  l_err_loc := 118;
  OPEN createGBPAHdrsForBlkldItemsCsr;

  l_err_loc := 120;
  --Not expecting a huge number of GBPA header's that will be returned from the cursor.
  --Considering the fact that we are grouping by on supplier_id, org_id, supplier_site_id, currency and language
  FETCH createGBPAHdrsForBlkldItemsCsr BULK COLLECT INTO
           l_org_id_tbl, l_supplier_id_tbl, l_supplier_site_id_tbl,
           l_currency_tbl, l_gbpa_cpa_reference_tbl,
           l_language_tbl, l_count_tbl;

  l_err_loc := 130;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Total no: of distinct GBPA headers attributes found:' || l_org_id_tbl.COUNT);
  END IF;

  l_err_loc := 140;
  FOR i in 1..l_org_id_tbl.COUNT LOOP
    l_err_loc := 150;
    g_current_gbpa_hdr_rec.org_id               := l_org_id_tbl(i);
    g_current_gbpa_hdr_rec.vendor_id            := l_supplier_id_tbl(i);
    g_current_gbpa_hdr_rec.vendor_site_id       := l_supplier_site_id_tbl(i);
    g_current_gbpa_hdr_rec.currency_code        := l_currency_tbl(i);
    -- g_current_gbpa_hdr_rec.price_contract_id    := l_price_contract_id_tbl(i);
    -- g_current_gbpa_hdr_rec.src_contract_id      := l_src_contract_id_tbl(i);
    g_current_gbpa_hdr_rec.language             := l_language_tbl(i);
    g_current_gbpa_hdr_rec.cpa_reference        := l_gbpa_cpa_reference_tbl(i);
    g_current_gbpa_hdr_rec.interface_header_id  := null;
    g_current_gbpa_hdr_rec.po_header_id         := null;
    g_current_gbpa_hdr_rec.upg_created_language := null;
    g_current_gbpa_hdr_rec.upg_cpa_reference    := null;

    l_err_loc := 154;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Previous Values:'||
          ', l_prev_org_id:' ||l_prev_org_id ||
          ', l_prev_supplier_id:' ||l_prev_supplier_id ||
          ', l_prev_supplier_site_id:' ||l_prev_supplier_site_id ||
          ', l_prev_currency:' ||l_prev_currency ||
          ', l_prev_contract_id:' ||l_prev_contract_id);
    END IF;

    l_err_loc := 160;
    IF (l_prev_org_id                   = l_org_id_tbl(i)               AND
        l_prev_supplier_id              = l_supplier_id_tbl(i)          AND
        l_prev_supplier_site_id         = l_supplier_site_id_tbl(i)     AND
        l_prev_currency                 = l_currency_tbl(i)             AND
        l_prev_contract_id              = l_gbpa_cpa_reference_tbl(i)         )
      THEN
      --All the GBPA header attributes are the same except the language
      --which means the lines in the current GBPA header needs to be checked
      --for the following two cases:
      --1> Some lines may be translations in the previous GBPA header
      --2> Some lines may need a new GBPA header to be created with the
      --   current language as the created language
      l_err_loc := 170;
      checkAndProcessGBPALines;
    ELSE
      l_err_loc := 180;
      l_interface_header_id := getNextInterfaceHdrIdFromSeq;

      l_err_loc := 190;
      g_po_hdrs_int_rec.interface_header_id     := l_interface_header_id;
      g_po_hdrs_int_rec.action                  := 'ORIGINAL';
      g_po_hdrs_int_rec.org_id                  := l_org_id_tbl(i);
      g_po_hdrs_int_rec.document_type_code      := 'BLANKET';
      g_po_hdrs_int_rec.budget_account_segment1 := null;
      g_po_hdrs_int_rec.po_header_id            := null;
      g_po_hdrs_int_rec.approval_status         := 'IN PROCESS';
      g_po_hdrs_int_rec.vendor_id               := l_supplier_id_tbl(i);
      g_po_hdrs_int_rec.vendor_site_id          := l_supplier_site_id_tbl(i);
      g_po_hdrs_int_rec.currency_code           := l_currency_tbl(i);
      g_po_hdrs_int_rec.created_language        := l_language_tbl(i);
      g_po_hdrs_int_rec.comments                := g_new_GBPA_description;

      l_err_loc := 200;
      IF (l_gbpa_cpa_reference_tbl(i) <> ICX_CAT_UTIL_PVT.g_NULL_NUMBER) THEN
        g_po_hdrs_int_rec.cpa_reference         := l_gbpa_cpa_reference_tbl(i);
      ELSE
        g_po_hdrs_int_rec.cpa_reference         := null;
      END IF;

      l_err_loc := 210;
      g_GBPA_hdr_count := g_GBPA_hdr_count + 1;
      insertPOHeadersInterface;

      l_err_loc := 220;
      g_current_gbpa_hdr_rec.interface_header_id := l_interface_header_id;
      processGBPALines;
    END IF;

    l_err_loc := 230;
    l_prev_org_id               := l_org_id_tbl(i);
    l_prev_supplier_id          := l_supplier_id_tbl(i);
    l_prev_supplier_site_id     := l_supplier_site_id_tbl(i);
    l_prev_currency             := l_currency_tbl(i);
    l_prev_contract_id          := l_gbpa_cpa_reference_tbl(i);
  END LOOP; --FOR LOOP of l_org_id_tbl

  l_err_loc := 240;
  CLOSE createGBPAHdrsForBlkldItemsCsr;

  l_err_loc := 250;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date) ||
        '; Total no: of GBPA headers created:' || g_GBPA_hdr_count ||
        ', Total no: of bulkload items processed:' || g_total_bulkld_row_count);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    raise;
END createGBPAsForBlkldItems;

FUNCTION getGBPAHeaderId(p_org_id              IN NUMBER,
                         p_supplier_id         IN NUMBER,
                         p_supplier_site_id    IN NUMBER,
                         p_currency            IN VARCHAR2,
                         p_cpa_reference       IN NUMBER,
                         p_created_language    IN VARCHAR2)
  RETURN NUMBER
IS
  l_po_interface_header_id      NUMBER;
  l_po_header_id                NUMBER;
BEGIN
  SELECT po_interface_header_id, po_header_id
  INTO   l_po_interface_header_id, l_po_header_id
  FROM   icx_cat_r12_upgrade upg, icx_cat_items_b b
  WHERE  b.rt_item_id = upg.rt_item_id
  AND    b.org_id = p_org_id
  AND    b.supplier_id = p_supplier_id
  AND    upg.supplier_site_id = p_supplier_site_id
  AND    upg.currency = p_currency
  AND    upg.cpa_reference = p_cpa_reference
  AND    upg.created_language = p_created_language
  AND    rownum < 2;

  RETURN l_po_header_id;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END getGBPAHeaderId;

PROCEDURE processGBPALinesForDelta
IS
  -- We need price_contract_id, because if autosource returned a contract_id
  -- then src.contract_id will not be same as price.contract_id.
  -- Added p_po_header_id to differentiate between two hdr groups which has
  -- everything the same, but one hdr row has null inteface_header_id and the
  -- other one has a value.  The data could be re-created if a hdr set has 4 items,
  -- that needs to be updated during delta and delta also 4 items that were added
  -- but fall into the same hdr group.
  CURSOR processGBPALinesForDeltaCsr(p_org_id NUMBER, p_supplier_id NUMBER,
                                     p_supplier_site_id NUMBER, p_currency VARCHAR2,
                                     p_cpa_reference NUMBER, p_language VARCHAR2,
                                     p_start_rt_item_id NUMBER, p_po_header_id NUMBER
                                     ) IS
    SELECT itemtlp.rt_item_id, price.unit_price, price.unit_of_measure,
           DECODE(NVL(price.negotiated_by_preparer_flag, '1'), '0', 'N', 'Y'),
           itemtlp.primary_category_id, NVL(map.external_source_key, '-2') po_category_id,
           SUBSTRB(itemtlp.supplier_part_num, 1, 25) supplier_part_num,
           DECODE(itemtlp.supplier_part_auxid, '##NULL##', null, itemtlp.supplier_part_auxid),
           SUBSTRB(itemtlp.description, 1, 240) description, itemb.catalog_name,
           upg.po_interface_header_id, upg.po_interface_line_id,
           upg.po_header_id, upg.po_line_id, upg.created_language,
           upg.po_category_id old_po_catgegory_id,
           DECODE(attr.ATTRIBUTE_VALUES_TLP_ID, NULL, 'ADD', 'UPDATE') attr_val_tlp_action,
           price.price_type, itemtlp.primary_category_name
    FROM   icx_cat_r12_upg_autosource src, icx_cat_item_prices price,
           icx_cat_items_tlp itemtlp, icx_por_category_order_map map,
           icx_cat_items_b itemb, icx_cat_ext_items_tlp extitemtlp,
           icx_cat_r12_upgrade upg, po_attribute_values_tlp attr
    WHERE  price.price_type = 'BULKLOAD'
    AND    price.rt_item_id = itemtlp.rt_item_id
    AND    NOT EXISTS (SELECT 'extracted price'
                       FROM   icx_cat_item_prices priceIn
                       WHERE  priceIn.rt_item_id = price.rt_item_id
                       AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                     'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
    AND    itemtlp.primary_category_id = map.rt_category_id (+)
    AND    itemtlp.org_id = src.org_id
    AND    itemtlp.supplier_id = src.supplier_id
    AND    price.supplier_site_id = src.supplier_site_id
    AND    price.currency = src.currency
    AND    NVL(map.external_source_key, '-2') = src.po_category_id
    AND    price.rt_item_id = itemb.rt_item_id
    AND    price.rt_item_id = extitemtlp.rt_item_id
    AND    itemtlp.language = extitemtlp.language
    AND    price.rt_item_id = upg.rt_item_id (+)
    AND    price.supplier_site_id = upg.supplier_site_id (+)
    AND    price.currency = upg.currency (+)
    AND    price.contract_id = upg.price_contract_id (+)
    AND    (upg.po_header_id IS NULL AND p_po_header_id IS NULL OR upg.po_header_id = p_po_header_id)
    AND    ( -- Last update changes in items / price tables
            (itemb.last_update_date > g_bulk_last_run_date
             OR itemtlp.last_update_date > g_bulk_last_run_date
             OR extitemtlp.last_update_date > g_bulk_last_run_date
             OR price.last_update_date > g_bulk_last_run_date)
            OR -- The items that errored out in the previous run
            (upg.po_header_id is null
             OR upg.po_line_id is null))
    AND    itemtlp.rt_item_id >= p_start_rt_item_id
    AND    itemtlp.language = p_language
    AND    src.org_id = p_org_id
    AND    src.supplier_id = p_supplier_id
    AND    src.supplier_site_id = p_supplier_site_id
    AND    src.currency = p_currency
    AND    src.contract_id = p_cpa_reference
    AND    attr.po_line_id (+) = upg.po_line_id
    AND    attr.req_template_name (+) = '-2'
    AND    attr.req_template_line_num (+) = -2
    AND    attr.org_id (+) = p_org_id
    AND    attr.language (+) = p_language
    UNION ALL
    SELECT itemtlp.rt_item_id, price.unit_price, price.unit_of_measure,
           DECODE(NVL(price.negotiated_by_preparer_flag, '1'), '0', 'N', 'Y'),
           itemtlp.primary_category_id, NVL(map.external_source_key, '-2') po_category_id,
           SUBSTRB(itemtlp.supplier_part_num, 1, 25) supplier_part_num,
           DECODE(itemtlp.supplier_part_auxid, '##NULL##', null, itemtlp.supplier_part_auxid),
           SUBSTRB(itemtlp.description, 1, 240) description, itemb.catalog_name,
           upg.po_interface_header_id, upg.po_interface_line_id,
           upg.po_header_id, upg.po_line_id, upg.created_language,
           upg.po_category_id old_po_catgegory_id,
           DECODE(attr.ATTRIBUTE_VALUES_TLP_ID, NULL, 'ADD', 'UPDATE') attr_val_tlp_action,
           price.price_type, itemtlp.primary_category_name
    FROM   icx_cat_item_prices price, icx_cat_items_tlp itemtlp,
           icx_por_category_order_map map,
           icx_cat_items_b itemb, icx_cat_ext_items_tlp extitemtlp,
           icx_cat_r12_upgrade upg, po_attribute_values_tlp attr
    WHERE  price.price_type = 'CONTRACT'
    AND    price.rt_item_id = itemtlp.rt_item_id
    AND    NOT EXISTS (SELECT 'extracted price'
                       FROM   icx_cat_item_prices priceIn
                       WHERE  priceIn.rt_item_id = price.rt_item_id
                       AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                     'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
    AND    itemtlp.primary_category_id = map.rt_category_id (+)
    AND    price.rt_item_id = itemb.rt_item_id
    AND    price.rt_item_id = extitemtlp.rt_item_id
    AND    itemtlp.language = extitemtlp.language
    AND    price.rt_item_id = upg.rt_item_id (+)
    AND    price.supplier_site_id = upg.supplier_site_id (+)
    AND    price.currency = upg.currency (+)
    AND    price.contract_id = upg.price_contract_id (+)
    AND    (upg.po_header_id IS NULL AND p_po_header_id IS NULL OR upg.po_header_id = p_po_header_id)
    AND    ( -- Last update changes in items / price tables
            (itemb.last_update_date > g_bulk_last_run_date
             OR itemtlp.last_update_date > g_bulk_last_run_date
             OR extitemtlp.last_update_date > g_bulk_last_run_date
             OR price.last_update_date > g_bulk_last_run_date)
            OR -- The items that errored out in the previous run
            (upg.po_header_id is null
             OR upg.po_line_id is null))
    AND    itemtlp.rt_item_id >= p_start_rt_item_id
    AND    itemtlp.language = p_language
    AND    itemtlp.org_id = p_org_id
    AND    itemtlp.supplier_id = p_supplier_id
    AND    price.supplier_site_id = p_supplier_site_id
    AND    price.currency = p_currency
    AND    price.contract_id = p_cpa_reference
    AND    attr.po_line_id (+) = upg.po_line_id
    AND    attr.req_template_name (+) = '-2'
    AND    attr.req_template_line_num (+) = -2
    AND    attr.org_id (+) = p_org_id
    AND    attr.language (+) = p_language
    ORDER BY 1;

  ----- Start of declaring columns selected in the cursor -----

  l_rt_item_id_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_unit_price_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_unit_of_measure_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_neg_by_prep_flag_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_primary_category_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_po_category_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_supp_part_num_tbl                   DBMS_SQL.VARCHAR2_TABLE;
  l_supp_part_auxid_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_description_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  l_catalog_name_tbl                    DBMS_SQL.VARCHAR2_TABLE;
  l_po_interface_header_id_tbl          DBMS_SQL.NUMBER_TABLE;
  l_po_interface_line_id_tbl            DBMS_SQL.NUMBER_TABLE;
  l_po_header_id_tbl                    DBMS_SQL.NUMBER_TABLE;
  l_po_line_id_tbl                      DBMS_SQL.NUMBER_TABLE;
  l_created_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_old_po_category_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_attr_val_tlp_action_tbl             DBMS_SQL.VARCHAR2_TABLE;
  l_price_type_tbl                      DBMS_SQL.VARCHAR2_TABLE;
  l_primary_category_name_tbl           DBMS_SQL.VARCHAR2_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'processGBPALinesForDelta';
  l_err_loc                     PLS_INTEGER;
  l_err_string                  VARCHAR2(4000);
  l_start_rt_item_id            NUMBER;
  l_batch_count                 PLS_INTEGER;
  l_item_row_count              PLS_INTEGER;
  l_interface_line_id           NUMBER;
  l_interface_header_id         NUMBER;
  l_po_header_id                NUMBER;
  l_lines_po_header_id          NUMBER;
  l_line_deleted                BOOLEAN := FALSE;
  l_dml_reqd_in_lines           BOOLEAN := TRUE;
  l_dml_reqd_in_r12Upgrade      BOOLEAN := TRUE;
  l_createR12UpgradeRow         BOOLEAN := TRUE;
  l_firstRow                    BOOLEAN := TRUE;
  l_del_interface_header_id     NUMBER;
  l_del_interface_line_id       NUMBER;
  l_start_date          	DATE;
  l_end_date            	DATE;
  l_log_string			VARCHAR2(2000);
  l_log_index                   NUMBER := 1;
BEGIN
  l_err_loc := 100;
  l_start_rt_item_id := 0;
  l_batch_count := 0;
  l_item_row_count := 0;
  l_start_date := sysdate;

  l_err_loc := 110;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ;
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, l_log_string);
  END IF;

  l_err_loc := 120;
  --line_type will be defaulted by PDOI.
  OPEN processGBPALinesForDeltaCsr
              (g_current_gbpa_hdr_rec.org_id, g_current_gbpa_hdr_rec.vendor_id,
               g_current_gbpa_hdr_rec.vendor_site_id, g_current_gbpa_hdr_rec.currency_code,
               g_current_gbpa_hdr_rec.cpa_reference, g_current_gbpa_hdr_rec.language,
               l_start_rt_item_id, g_current_gbpa_hdr_rec.po_header_id);
  LOOP
    l_err_loc := 130;
    l_rt_item_id_tbl.DELETE;
    l_unit_price_tbl.DELETE;
    l_unit_of_measure_tbl.DELETE;
    l_neg_by_prep_flag_tbl.DELETE;
    l_primary_category_id_tbl.DELETE;
    l_po_category_id_tbl.DELETE;
    l_supp_part_num_tbl.DELETE;
    l_supp_part_auxid_tbl.DELETE;
    l_description_tbl.DELETE;
    l_catalog_name_tbl.DELETE;
    l_po_interface_header_id_tbl.DELETE;
    l_po_interface_line_id_tbl.DELETE;
    l_po_header_id_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_created_language_tbl.DELETE;
    l_old_po_category_id_tbl.DELETE;
    l_attr_val_tlp_action_tbl.DELETE;
    l_price_type_tbl.DELETE;
    l_primary_category_name_tbl.DELETE;

    BEGIN
      l_err_loc := 140;
      FETCH processGBPALinesForDeltaCsr BULK COLLECT INTO
            l_rt_item_id_tbl, l_unit_price_tbl, l_unit_of_measure_tbl,
            l_neg_by_prep_flag_tbl, l_primary_category_id_tbl, l_po_category_id_tbl,
            l_supp_part_num_tbl, l_supp_part_auxid_tbl, l_description_tbl,
            l_catalog_name_tbl,
            l_po_interface_header_id_tbl, l_po_interface_line_id_tbl,
            l_po_header_id_tbl, l_po_line_id_tbl, l_created_language_tbl,
            l_old_po_category_id_tbl, l_attr_val_tlp_action_tbl, l_price_type_tbl,
            l_primary_category_name_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      l_err_loc := 150;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Total no: of records fetced from the cursor:' || l_rt_item_id_tbl.COUNT);
      END IF;

      l_err_loc := 160;
      EXIT WHEN l_rt_item_id_tbl.COUNT = 0;

      l_err_loc := 170;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 180;
      --Save the last rt_item_id processed,
      --so that re-open of cursor will start from the saved rt_item_id.
      l_start_rt_item_id := l_rt_item_id_tbl(l_rt_item_id_tbl.COUNT);

      l_err_loc := 190;
      l_item_row_count := l_item_row_count + l_rt_item_id_tbl.COUNT;

      l_err_loc := 200;
      FOR i in 1..l_rt_item_id_tbl.COUNT LOOP
        l_log_index := i;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Values fetched from the cursor; '||
              'l_rt_item_id_tbl:' || l_rt_item_id_tbl(i) ||
              ', l_supp_part_num_tbl:' || l_supp_part_num_tbl(i) ||
              ', l_price_type_tbl:' || l_price_type_tbl(i) ||
              ', l_po_interface_header_id_tbl:' || l_po_interface_header_id_tbl(i) ||
              ', l_po_interface_line_id_tbl:' || l_po_interface_line_id_tbl(i) ||
              ', l_po_header_id_tbl:' || l_po_header_id_tbl(i) ||
              ', l_po_line_id_tbl:' || l_po_line_id_tbl(i) ||
              ', l_created_language_tbl:' || l_created_language_tbl(i) ||
              ', l_po_category_id_tbl:' || l_po_category_id_tbl(i) ||
              ', l_old_po_category_id_tbl:' || l_old_po_category_id_tbl(i) ||
              ', new_source:' || g_current_gbpa_hdr_rec.cpa_reference ||
              ', old_source:' || g_current_gbpa_hdr_rec.upg_cpa_reference ||
              ', l_attr_val_tlp_action_tbl:' || l_attr_val_tlp_action_tbl(i) );
        END IF;

        -- Possible header rows to be processed during delta
        -- 1. Errored headers or lines during previous run of upgrade
        -- 2. New rows added after the upgrade
        -- 3. Changed rows after the upgrade.
        -- 4. Errored lines in the previous run of upgrade i.e. error happened during creation of lines
        -------------------------------------------------------------------------------------------------------------
        -- hdr.poInthdrId       |       hdr.poHdrId     |       curr_pointHdrId |       createdLang     |       Lang
        -------------------------------------------------------------------------------------------------------------
        -- 1. Errored headers and lines during previous run of upgrade
        -- 123                          _                       123                     US                      US
        -- 123                          _                       921                     US                      N
        -------------------------------------------------------------------------------------------------------------
        -- 2. New rows added after the upgrade
        -- _                            _                       _                       _                       US
        -- _                            _                       922                     US                      N
        -------------------------------------------------------------------------------------------------------------
        -- 3. Changed rows after the upgrade.
        -- 124                          321                     124                     US                      N
        -- 124                          321                     923                     US                      US
        -------------------------------------------------------------------------------------------------------------
        -- 4. Errored lines in the previous run of upgrade i.e. error happened during creation of lines
        -- 125                          322                     125                     US                      US
        -- 125                          322                     924                     US                      N
        -------------------------------------------------------------------------------------------------------------

        l_err_loc := 210;
        IF ( (g_current_gbpa_hdr_rec.interface_header_id IS NULL AND
              l_po_interface_header_id_tbl(i) IS NULL) OR
             (g_current_gbpa_hdr_rec.interface_header_id IS NOT NULL AND
              l_po_interface_header_id_tbl(i) IS NOT NULL AND
              g_current_gbpa_hdr_rec.interface_header_id = l_po_interface_header_id_tbl(i)))
        THEN
          -- i.e. both the interface_header_id from the lines cursor and from the headers cursors are the same
          -- We need to insert rows in po_headers_interface, po_lines_interface, po_attr_values_interface
          -- and po_attr_values_tlp_interface
          -- IF interface_header_id from the headers cursor is null then insert into icx_cat_r12_upgrade table
          -- IF interface_header_id from the headers cursor is not null then update icx_cat_r12_upgrade table
          IF (l_firstRow) THEN
            --Create the header record only once for the
            --current combination of header attributes
            l_err_loc := 212;
            l_interface_header_id := getNextInterfaceHdrIdFromSeq;
            g_po_hdrs_int_rec.interface_header_id     := l_interface_header_id;
            g_po_hdrs_int_rec.org_id                  := g_current_gbpa_hdr_rec.org_id;
            g_po_hdrs_int_rec.document_type_code      := 'BLANKET';
            g_po_hdrs_int_rec.budget_account_segment1 := null;
            g_po_hdrs_int_rec.approval_status         := 'IN PROCESS';
            g_po_hdrs_int_rec.vendor_id               := g_current_gbpa_hdr_rec.vendor_id;
            g_po_hdrs_int_rec.vendor_site_id          := g_current_gbpa_hdr_rec.vendor_site_id;
            g_po_hdrs_int_rec.currency_code           := g_current_gbpa_hdr_rec.currency_code;
            g_po_hdrs_int_rec.comments                := g_new_GBPA_description;

            l_err_loc := 216;
            IF (g_current_gbpa_hdr_rec.cpa_reference <> ICX_CAT_UTIL_PVT.g_NULL_NUMBER) THEN
              g_po_hdrs_int_rec.cpa_reference         := g_current_gbpa_hdr_rec.cpa_reference;
            ELSE
              g_po_hdrs_int_rec.cpa_reference         := null;
            END IF;

            IF (g_current_gbpa_hdr_rec.po_header_id IS NULL OR
                (g_current_gbpa_hdr_rec.po_header_id IS NOT NULL AND
                 g_current_gbpa_hdr_rec.cpa_reference <> g_current_gbpa_hdr_rec.upg_cpa_reference)) THEN
              -- If the po_header is null OR the source has changed then
              -- Create a new header i.e the action can be ORIGINAL
              -- Before creating a new header check if a header was already created for the same header attributes
              -- in the previous run of upgrade.
              l_err_loc := 218;
              l_po_header_id := getGBPAHeaderId(g_current_gbpa_hdr_rec.org_id,
                                                g_current_gbpa_hdr_rec.vendor_id,
                                                g_current_gbpa_hdr_rec.vendor_site_id,
                                                g_current_gbpa_hdr_rec.currency_code,
                                                g_current_gbpa_hdr_rec.cpa_reference,
                                                g_current_gbpa_hdr_rec.language);

              l_err_loc := 220;
              IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                    ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                    'l_po_header_id returned from ' ||
                    'getGBPAHeaderId(orgId=>' || g_current_gbpa_hdr_rec.org_id ||
                    ', suppId=>' || g_current_gbpa_hdr_rec.vendor_id ||
                    ', siteId=>' || g_current_gbpa_hdr_rec.vendor_site_id ||
                    ', curr=>' || g_current_gbpa_hdr_rec.currency_code ||
                    ', cpaReference=>' || g_current_gbpa_hdr_rec.cpa_reference ||
                    ', creatLang=>' || g_current_gbpa_hdr_rec.language ||
                    '):' ||l_po_header_id);
              END IF;

              l_err_loc := 222;
              IF (l_po_header_id IS NULL) THEN
                --A new GBPA header needs to be created.
                 g_po_hdrs_int_rec.action                 := 'ORIGINAL';
                 g_po_hdrs_int_rec.po_header_id           := null;
                 g_po_hdrs_int_rec.created_language       := g_current_gbpa_hdr_rec.language;
                 l_lines_po_header_id                     := null;
              ELSE
                 l_err_loc := 224;
                 g_po_hdrs_int_rec.action                 := 'UPDATE';
                 g_po_hdrs_int_rec.po_header_id           := l_po_header_id;
                 g_po_hdrs_int_rec.created_language       := g_current_gbpa_hdr_rec.language;
                 l_lines_po_header_id                     := l_po_header_id;
              END IF;
            ELSE
              -- i.e. g_current_gbpa_hdr_rec.po_header_id IS NOT NULL
              -- AND the source is also same as it was during the earlier run of upgrade.
              l_err_loc := 226;
              g_po_hdrs_int_rec.action                  := 'UPDATE';
              g_po_hdrs_int_rec.po_header_id            := g_current_gbpa_hdr_rec.po_header_id;
              g_po_hdrs_int_rec.created_language        := g_current_gbpa_hdr_rec.upg_created_language;
              l_lines_po_header_id                      := g_current_gbpa_hdr_rec.po_header_id;
            END IF; -- g_current_gbpa_hdr_rec.po_header_id IS NULL
            l_err_loc := 227;
            g_GBPA_hdr_count := g_GBPA_hdr_count + 1;

            l_err_loc := 228;
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'inserting into headers_interface; total_hdr_count:' ||g_GBPA_hdr_count ||
                  ', g_po_hdrs_int_rec.action:' || g_po_hdrs_int_rec.action ||
                  ', g_po_hdrs_int_rec.po_header_id:' || g_po_hdrs_int_rec.po_header_id ||
                  ', created_language:' || g_po_hdrs_int_rec.created_language  ||
                  ', comments:' || g_po_hdrs_int_rec.comments ||
                  ', l_interface_header_id:' ||l_interface_header_id  ||
                  ', g_po_hdrs_int_rec.cpa_reference:' || g_po_hdrs_int_rec.cpa_reference  ||
                  ', g_current_gbpa_hdr_rec.cpa_reference:' || g_current_gbpa_hdr_rec.cpa_reference ||
                  ', g_current_gbpa_hdr_rec.po_header_id:' ||g_current_gbpa_hdr_rec.po_header_id);
            END IF;
            l_err_loc := 230;
            insertPOHeadersInterface;
            l_firstRow := FALSE;
          END IF; -- IF (l_firstRow)

          l_line_deleted := FALSE;
          IF (l_po_header_id_tbl(i) IS NOT NULL AND l_po_line_id_tbl(i) IS NOT NULL) THEN
            -- If category changed but the source before and after is -2,
            -- then there is no need of deleting the line, So here we only check for the change in source
            -- before deleting the line.
            -- Check for auto source change
            -- due to category change / autosource api returned different source in the previous run of upgrade.
            IF (g_current_gbpa_hdr_rec.cpa_reference <> g_current_gbpa_hdr_rec.upg_cpa_reference) THEN
              -- The row needs to be deleted.
              -- so insert a header row with update action
              -- insert a line with delete action.

              IF (l_del_interface_header_id IS NULL) THEN
                l_del_interface_header_id := getNextInterfaceHdrIdFromSeq;

                l_err_loc := 232;
                g_po_hdrs_int_rec.interface_header_id     := l_del_interface_header_id;
                g_po_hdrs_int_rec.action                  := 'UPDATE';
                g_po_hdrs_int_rec.document_type_code      := 'BLANKET';
                g_po_hdrs_int_rec.budget_account_segment1 := null;
                g_po_hdrs_int_rec.po_header_id            := l_po_header_id_tbl(i);
                g_po_hdrs_int_rec.approval_status         := 'IN PROCESS';
                g_po_hdrs_int_rec.org_id                  := g_current_gbpa_hdr_rec.org_id;
                --The rest of the values can be inserted as null in po_headers_interface
                --i.e. we are not touching the values that are alreay present in po_headers_all
                g_po_hdrs_int_rec.vendor_id               := null;
                g_po_hdrs_int_rec.vendor_site_id          := null;
                g_po_hdrs_int_rec.currency_code           := null;
                g_po_hdrs_int_rec.cpa_reference           := null;
                g_po_hdrs_int_rec.created_language        := null;
                g_po_hdrs_int_rec.comments                := null;

                l_err_loc := 234;
                IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                      'inserting into headers interface for delete of lines'||
                      ', l_del_interface_header_id:' || l_del_interface_header_id  ||
                      ', g_po_hdrs_int_rec.action:' || g_po_hdrs_int_rec.action ||
                      ', g_po_hdrs_int_rec.po_header_id:' || g_po_hdrs_int_rec.po_header_id ||
                      ', created_language:' || g_po_hdrs_int_rec.created_language  ||
                      ', comments:' || g_po_hdrs_int_rec.comments ||
                      ', g_po_hdrs_int_rec.cpa_reference:' || g_po_hdrs_int_rec.cpa_reference  ||
                      ', g_current_gbpa_hdr_rec.upg_cpa_reference:' || g_current_gbpa_hdr_rec.upg_cpa_reference ||
                      ', g_current_gbpa_hdr_rec.cpa_reference:' || g_current_gbpa_hdr_rec.cpa_reference ||
                      ', g_current_gbpa_hdr_rec.po_header_id:' ||g_current_gbpa_hdr_rec.po_header_id ||
                      ', l_po_header_id_tbl:' || l_po_header_id_tbl(i) );
                END IF;
                l_err_loc := 236;
                insertPOHeadersInterface;
              END IF;  -- IF (l_del_interface_header_id IS NULL)

              l_del_interface_line_id := getNextInterfaceLineIdFromSeq;
              l_err_loc := 238;
              --Put the current values into g_po_line_attrval_int_rec for po_lines_interface
              g_po_line_attrval_int_rec.interface_header_id          := l_del_interface_header_id;
              g_po_line_attrval_int_rec.interface_line_id            := l_del_interface_line_id;
              g_po_line_attrval_int_rec.action                       := 'DELETE';
              g_po_line_attrval_int_rec.po_line_id                   := l_po_line_id_tbl(i);
              g_po_line_attrval_int_rec.po_header_id                 := l_po_header_id_tbl(i);
              --Put the rest as null
              g_po_line_attrval_int_rec.unit_price                   := null;
              g_po_line_attrval_int_rec.uom_code                     := null;
              g_po_line_attrval_int_rec.negotiated_by_preparer_flag  := null;
              g_po_line_attrval_int_rec.ip_category_id               := null;
              g_po_line_attrval_int_rec.category_id                  := null;
              g_po_line_attrval_int_rec.category_name                := null;
              g_po_line_attrval_int_rec.vendor_product_num           := null;
              g_po_line_attrval_int_rec.supplier_part_auxid          := null;
              g_po_line_attrval_int_rec.item_description             := null;
              g_po_line_attrval_int_rec.catalog_name                 := null;

              l_err_loc := 240;
              IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                    ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                    'inserting into lines interface with DELETE action' ||
                    ', l_del_interface_line_id:' || l_del_interface_line_id  ||
                    ', po_line_id: ' || g_po_line_attrval_int_rec.po_line_id ||
                    ', rt_item_id: ' || l_rt_item_id_tbl(i) ||
                    ', l_po_category_id_tbl:' || l_po_category_id_tbl(i) ||
                    ', l_old_po_category_id_tbl:' || l_old_po_category_id_tbl(i) );
              END IF;
              l_err_loc := 242;
              insertPOLinesInterface;
              l_line_deleted := TRUE;
            END IF; -- IF (g_current_gbpa_hdr_rec.cpa_reference <> g_current_gbpa_hdr_rec.upg_cpa_reference)
          END IF; -- IF (l_po_header_id_tbl(i) IS NOT NULL AND l_po_line_id_tbl(i) IS NOT NULL)

          -- For all the following cases we need to create the lines:
          -- 1. po_header_id is null
          -- 2. po_header_id is not null and created_language = language
          --    (This will also cover the case when po_line_id is null i.e the header got created
          --     but line was not created because of errors in line.
          -- 3. current line is a delete.
          IF (g_current_gbpa_hdr_rec.po_header_id IS NULL OR
              (g_current_gbpa_hdr_rec.po_header_id IS NOT NULL AND
               g_current_gbpa_hdr_rec.upg_created_language = g_current_gbpa_hdr_rec.language) OR
              l_line_deleted)
          THEN
            l_dml_reqd_in_lines := TRUE;
          ELSE
            l_dml_reqd_in_lines := FALSE;
          END IF;
          -- Figure out if the row needs to be inserted / updated in icx_cat_r12_upgrade table
          l_dml_reqd_in_r12Upgrade := TRUE;
          IF (l_po_interface_line_id_tbl(i) IS NULL) THEN
            l_createR12UpgradeRow := TRUE;
          ELSE
            l_createR12UpgradeRow := FALSE;
          END IF;
        ELSE
          -- g_current_gbpa_hdr_rec.interface_header_id <> l_po_interface_header_id_tbl(i)
          -- possible case:
          -- The lines in this cursor are translations of the earlier header lines
          --   (so only need to insert into po_attr_values_tlp_interface)
          --   l_dml_reqd_in_lines := FALSE;
          -- IF po_header_id is not null and created_language = the current row language, then
          -- insert into lines are attr values tables.
          l_dml_reqd_in_r12Upgrade := FALSE;
          IF (l_po_header_id_tbl(i) IS NOT NULL AND
              l_created_language_tbl(i) = g_current_gbpa_hdr_rec.language)
          THEN
            l_dml_reqd_in_lines := TRUE;
            l_lines_po_header_id := l_po_header_id_tbl(i);
          ELSE
            l_dml_reqd_in_lines := FALSE;
          END IF;
          l_line_deleted := FALSE;
        END IF;

        IF (l_dml_reqd_in_r12Upgrade) THEN
          l_interface_line_id := getNextInterfaceLineIdFromSeq;
          -- Put the current values into g_r12_upg_rec for
          -- icx_cat_r12_upgrade (insert/update will be depending on l_createR12UpgradeRow)
          l_err_loc := 244;
          g_r12_upg_rec.rt_item_id                              := l_rt_item_id_tbl(i);
          g_r12_upg_rec.supplier_site_id                        := g_current_gbpa_hdr_rec.vendor_site_id;
          g_r12_upg_rec.currency                                := g_current_gbpa_hdr_rec.currency_code;
          -- icx_cat_r12_upgrade.price_contract_id is same as the contract_id in price table
          -- icx_cat_r12_upgrade.src_contract_id is same as the contract_id returned from autosource
          -- Need both contract_ids to figure out any changes in the source document during delta processing.
          l_err_loc := 246;
          IF (l_price_type_tbl(i) = 'BULKLOAD') THEN
            g_r12_upg_rec.price_contract_id                     := -2;
            g_r12_upg_rec.src_contract_id                       := g_current_gbpa_hdr_rec.cpa_reference;
          ELSE
            g_r12_upg_rec.price_contract_id                     := g_current_gbpa_hdr_rec.cpa_reference;
            g_r12_upg_rec.src_contract_id                       := -2;
          END IF;
          l_err_loc := 248;
          g_r12_upg_rec.cpa_reference                           := g_current_gbpa_hdr_rec.cpa_reference;
          g_r12_upg_rec.po_category_id                          := l_po_category_id_tbl(i);
          g_r12_upg_rec.old_po_interface_line_id                := l_po_interface_line_id_tbl(i);
          g_r12_upg_rec.po_interface_header_id                  := l_interface_header_id;
          g_r12_upg_rec.po_interface_line_id                    := l_interface_line_id;
          l_err_loc := 250;
          IF (l_createR12UpgradeRow) THEN
            g_r12_upg_rec.created_language                      := g_current_gbpa_hdr_rec.language;
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'inserting into r12 upgrade');
            END IF;
            insertR12Upgrade;
          ELSE
            l_err_loc := 252;
            IF (l_line_deleted) THEN
              -- So that the po_line_id is null in po_attr_values_tlp_interface
              -- when translation is inserted for a deleted line
              -- (Note: the line was deleted due to source / category change)
              g_r12_upg_rec.po_line_id                 := null;
              g_r12_upg_rec.po_header_id               := null;
              g_r12_upg_rec.created_language           := null;
            ELSE
              l_err_loc := 254;
              g_r12_upg_rec.po_line_id                 := l_po_line_id_tbl(i);
              g_r12_upg_rec.po_header_id               := l_po_header_id_tbl(i);
              g_r12_upg_rec.created_language           := l_created_language_tbl(i);
            END IF;

            l_err_loc := 256;
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'updating r12 upgrade' ||
                  ', old interface_header_id:' || g_current_gbpa_hdr_rec.interface_header_id ||
                  ', old interface_line_id: ' || l_po_interface_line_id_tbl(i) ||
                  ', old_cpa_reference: ' || g_current_gbpa_hdr_rec.upg_cpa_reference ||
                  ', new_cpa_reference: ' || g_current_gbpa_hdr_rec.cpa_reference ||
                  ', old_po_category_id: ' || l_old_po_category_id_tbl(i) ||
                  ', new_po_category_id: ' || l_po_category_id_tbl(i) ||
                  ', g_r12_upg_rec.po_line_id:' || g_r12_upg_rec.po_line_id ||
                  ', g_r12_upg_rec.po_header_id: ' || g_r12_upg_rec.po_header_id ||
                  ', g_r12_upg_rec.created_language:' || g_r12_upg_rec.created_language ||
                  ', g_current_gbpa_hdr_rec.po_header_id:' || g_current_gbpa_hdr_rec.po_header_id ||
                  ', g_current_gbpa_hdr_rec.upg_created_language:' || g_current_gbpa_hdr_rec.upg_created_language  );
            END IF;
            --update the po_interface_header_id and po_interface_line_id
            --in icx_cat_r12_upgrade with the new ones.
            l_err_loc := 258;
            updateR12Upgrade;
          END IF;
        ELSE
          l_interface_header_id := l_po_interface_header_id_tbl(i) ;
          l_interface_line_id := l_po_interface_line_id_tbl(i);
        END IF;

        IF (l_dml_reqd_in_lines) THEN
          l_err_loc := 260;
          -- Put the current values into g_po_line_attrval_int_rec for
          -- po_lines_interface and po_attr_values_interface
          g_po_line_attrval_int_rec.interface_line_id            := l_interface_line_id;
          g_po_line_attrval_int_rec.interface_header_id          := l_interface_header_id;
          IF (l_po_line_id_tbl(i) IS NULL OR l_line_deleted) THEN
            g_po_line_attrval_int_rec.action                     := 'ADD';
            g_po_line_attrval_int_rec.po_line_id                 := null;
          ELSE
            g_po_line_attrval_int_rec.action                     := 'UPDATE';
            g_po_line_attrval_int_rec.po_line_id                 := l_po_line_id_tbl(i);
          END IF;
          g_po_line_attrval_int_rec.po_header_id                 := l_lines_po_header_id;
          l_err_loc := 262;
          g_po_line_attrval_int_rec.unit_price                   := l_unit_price_tbl(i);
          g_po_line_attrval_int_rec.uom_code                     := l_unit_of_measure_tbl(i);
          g_po_line_attrval_int_rec.negotiated_by_preparer_flag  := l_neg_by_prep_flag_tbl(i);
          g_po_line_attrval_int_rec.ip_category_id               := l_primary_category_id_tbl(i);
          -- TO BE CHECKED
          l_err_loc := 263;
          g_po_line_attrval_int_rec.category_id                  := l_po_category_id_tbl(i);
          l_err_loc := 264;
          g_po_line_attrval_int_rec.category_name                := l_primary_category_name_tbl(i);
          l_err_loc := 266;
          g_po_line_attrval_int_rec.vendor_product_num           := l_supp_part_num_tbl(i);
          g_po_line_attrval_int_rec.supplier_part_auxid          := l_supp_part_auxid_tbl(i);
          g_po_line_attrval_int_rec.req_template_name            := '-2';
          g_po_line_attrval_int_rec.req_template_line_num        := -2;
          g_po_line_attrval_int_rec.inventory_item_id            := -2;
          g_po_line_attrval_int_rec.org_id                       := g_current_gbpa_hdr_rec.org_id;
          g_po_line_attrval_int_rec.rt_item_id                   := l_rt_item_id_tbl(i);
          g_po_line_attrval_int_rec.language                     := g_current_gbpa_hdr_rec.language;
          l_err_loc := 268;
          g_po_line_attrval_int_rec.item_description             := l_description_tbl(i);
          g_po_line_attrval_int_rec.catalog_name                 := l_catalog_name_tbl(i);

          l_err_loc := 270;
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'inserting into lines and attr_values with action:' ||
                g_po_line_attrval_int_rec.action ||
                ', l_rt_item_id_tbl(i): ' || l_rt_item_id_tbl(i) ||
                ', interface_line_id: ' || g_po_line_attrval_int_rec.interface_line_id ||
                ', interface_header_id: ' || g_po_line_attrval_int_rec.interface_header_id );
          END IF;
          --Add the current value to the global pl/sql tables
          l_err_loc := 272;
          insertPOLinesInterface;
          l_err_loc := 274;
          insertPOAttrValsInterface;
        END IF; -- IF (l_dml_reqd_in_lines)

        -- Always need to insert into po_attr_values_tlp_interface
        -- Put the current values into g_po_attrvalstlp_int_rec for
        -- po_attr_values_tlp_interface
        l_err_loc := 276;
        g_po_attrvalstlp_int_rec.interface_header_id            := l_interface_header_id;
        g_po_attrvalstlp_int_rec.interface_line_id              := l_interface_line_id;
        l_err_loc := 278;
        IF (l_po_line_id_tbl(i) IS NULL OR l_line_deleted) THEN
          g_po_attrvalstlp_int_rec.action                       := 'ADD';
          g_po_attrvalstlp_int_rec.po_line_id                   := null;
        ELSE
          l_err_loc := 280;
          g_po_attrvalstlp_int_rec.action                       := l_attr_val_tlp_action_tbl(i);
          g_po_attrvalstlp_int_rec.po_line_id                   := l_po_line_id_tbl(i);
        END IF;
        l_err_loc := 282;
        g_po_attrvalstlp_int_rec.req_template_name              := '-2';
        g_po_attrvalstlp_int_rec.req_template_line_num          := -2;
        g_po_attrvalstlp_int_rec.inventory_item_id              := -2;
        g_po_attrvalstlp_int_rec.org_id                         := g_current_gbpa_hdr_rec.org_id;
        g_po_attrvalstlp_int_rec.language                       := g_current_gbpa_hdr_rec.language;
        g_po_attrvalstlp_int_rec.check_desc_update              := ICX_CAT_UTIL_PVT.g_update_description;
        g_po_attrvalstlp_int_rec.rt_item_id                     := l_rt_item_id_tbl(i);

        l_err_loc := 290;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'inserting into attr_values_tlp with action:' || g_po_attrvalstlp_int_rec.action ||
              ', g_po_attrvalstlp_int_rec.po_line_id: ' || g_po_attrvalstlp_int_rec.po_line_id ||
              ', g_current_gbpa_hdr_rec.language: ' || g_current_gbpa_hdr_rec.language ||
              ', g_current_gbpa_hdr_rec.upg_created_language: ' || g_current_gbpa_hdr_rec.upg_created_language ||
              ', l_rt_item_id_tbl(i): ' || l_rt_item_id_tbl(i) ||
              ', interface_line_id: ' || g_po_attrvalstlp_int_rec.interface_line_id ||
              ', interface_header_id: ' || g_po_attrvalstlp_int_rec.interface_header_id );
        END IF;
        l_err_loc := 292;
        --Add the current value to the global pl/sql tables
        insertPOAttrValsTLPInterface;

        l_err_loc := 300;
        populatePOInterfaceTables('INLOOP');
      END LOOP;  --FOR LOOP of l_rt_item_id_tbl

      l_err_loc := 310;
      EXIT WHEN l_rt_item_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
                        || ', Total processeded batches:' || l_batch_count
                        || ', Cursor will be reopened with rt_item_id:' || l_start_rt_item_id;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 330;
        IF (processGBPALinesForDeltaCsr%ISOPEN) THEN
          CLOSE processGBPALinesForDeltaCsr;
          OPEN processGBPALinesForDeltaCsr
               (g_current_gbpa_hdr_rec.org_id, g_current_gbpa_hdr_rec.vendor_id,
                g_current_gbpa_hdr_rec.vendor_site_id, g_current_gbpa_hdr_rec.currency_code,
                g_current_gbpa_hdr_rec.cpa_reference, g_current_gbpa_hdr_rec.language,
                l_start_rt_item_id, g_current_gbpa_hdr_rec.po_header_id);
        END IF;
    END;
  END LOOP; --CURSOR LOOP

  l_err_loc := 350;
  populatePOInterfaceTables('OUTLOOP');

  IF (processGBPALinesForDeltaCsr%ISOPEN) THEN
    CLOSE processGBPALinesForDeltaCsr;
  END IF;

  l_err_loc := 360;
  g_total_bulkld_row_count := g_total_bulkld_row_count + l_item_row_count;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'done; '||
        'Total no: of batches processed:' ||l_batch_count ||
        ', Total no: of bulkloaded items processed:' ||l_item_row_count);
  END IF;

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

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Current Values in g_current_gbpa_hdr_rec:'||
          ', org_id:' ||g_current_gbpa_hdr_rec.org_id ||
          ', supplier_id:' ||g_current_gbpa_hdr_rec.vendor_id ||
          ', supplier_site_id:' ||g_current_gbpa_hdr_rec.vendor_site_id ||
          ', currency:' ||g_current_gbpa_hdr_rec.currency_code ||
          ', gbpa_cpa_reference:' ||g_current_gbpa_hdr_rec.cpa_reference ||
          ', language:' ||g_current_gbpa_hdr_rec.language ||
          ', interface_header_id:' ||g_current_gbpa_hdr_rec.interface_header_id ||
          ', po_header_id:' ||g_current_gbpa_hdr_rec.po_header_id ||
          ', upg_created_language:' ||g_current_gbpa_hdr_rec.upg_created_language ||
          ', upg_cpa_reference:' ||g_current_gbpa_hdr_rec.upg_cpa_reference  );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Values fetched from the cursor; '||
          'l_rt_item_id_tbl:' || l_rt_item_id_tbl(l_log_index) ||
          ', l_supp_part_num_tbl:' || l_supp_part_num_tbl(l_log_index) ||
          ', l_supp_part_auxid_tbl:' || l_supp_part_auxid_tbl(l_log_index) ||
          ', l_unit_price_tbl:' || l_unit_price_tbl(l_log_index) ||
          ', l_unit_of_measure_tbl:' || l_unit_of_measure_tbl(l_log_index) ||
          ', l_neg_by_prep_flag_tbl:' || l_neg_by_prep_flag_tbl(l_log_index) ||
          ', l_primary_category_id_tbl:' || l_primary_category_id_tbl(l_log_index) ||
          ', l_po_category_id_tbl:' || l_po_category_id_tbl(l_log_index) ||
          ', l_old_po_category_id_tbl:' || l_old_po_category_id_tbl(l_log_index) ||
          ', l_price_type_tbl:' || l_price_type_tbl(l_log_index) );
    END IF;

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Values fetched from the cursor; '||
          'l_description_tbl:' || l_description_tbl(l_log_index) ||
          ', l_catalog_name_tbl:' || l_catalog_name_tbl(l_log_index) ||
          ', l_primary_category_name_tbl:' || l_primary_category_name_tbl(l_log_index) ||
          ', l_po_interface_header_id_tbl:' || l_po_interface_header_id_tbl(l_log_index) ||
          ', l_po_interface_line_id_tbl:' || l_po_interface_line_id_tbl(l_log_index) ||
          ', l_po_header_id_tbl:' || l_po_header_id_tbl(l_log_index) ||
          ', l_po_line_id_tbl:' || l_po_line_id_tbl(l_log_index) ||
          ', l_created_language_tbl:' || l_created_language_tbl(l_log_index) ||
          ', l_attr_val_tlp_action_tbl:' || l_attr_val_tlp_action_tbl(l_log_index));
    END IF;

    raise;
END processGBPALinesForDelta;

PROCEDURE checkUpdateInGBPAForDelta
IS

  -- Added the decode for supplier and supplier_site_code, because of some corrupt data
  -- that exists on the internal envs (also on gevt11i).
  -- The details: supplier_site_id = -2 but supplier_site_code is not null
  -- supplier_id = -2 but supplier is not null
  -- note that here we need to do nvl for upg.cpa_reference
  -- because for new lines the outer join to upg will not return any rows and hence upg.cpa_reference will be null
  -- for these guys. but in the table (upg) the cpa_reference is not null (it is actually -2) and since we are
  -- grouping these rows on upg.cpa_reference we need both to be -2
  CURSOR checkUpdateInGBPAForDeltaCsr IS
    SELECT doc.*,
           COUNT(*) count
    FROM (
           SELECT src.org_id org_id, src.supplier_id supplier_id,
                  src.supplier_site_id supplier_site_id, src.currency currency,
                  src.contract_id gbpa_cpa_reference,
                  itemtlp.language language,
                  upg.po_interface_header_id,
                  upg.po_header_id, upg.created_language,
                  nvl(upg.cpa_reference, -2) upg_cpa_reference
           FROM   icx_cat_r12_upg_autosource src, icx_cat_item_prices price,
                  icx_cat_items_tlp itemtlp, icx_por_category_order_map map,
                  icx_cat_items_b itemb, icx_cat_ext_items_tlp extitemtlp,
                  icx_cat_r12_upgrade upg
           WHERE  price.price_type = 'BULKLOAD'
           AND    price.rt_item_id = itemtlp.rt_item_id
           AND    NOT EXISTS (SELECT 'extracted price'
                              FROM   icx_cat_item_prices priceIn
                              WHERE  priceIn.rt_item_id = price.rt_item_id
                              AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                            'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
           AND    itemtlp.primary_category_id = map.rt_category_id (+)
           AND    itemtlp.org_id = src.org_id
           AND    itemtlp.supplier_id = src.supplier_id
           AND    price.supplier_site_id = src.supplier_site_id
           AND    price.currency = src.currency
           AND    NVL(map.external_source_key, '-2') = src.po_category_id
           AND    price.rt_item_id = itemb.rt_item_id
           AND    price.rt_item_id = extitemtlp.rt_item_id
           AND    itemtlp.language = extitemtlp.language
           AND    price.rt_item_id = upg.rt_item_id (+)
           AND    price.supplier_site_id = upg.supplier_site_id (+)
           AND    price.currency = upg.currency (+)
           AND    price.contract_id = upg.price_contract_id (+)
           AND    ( -- Last update changes in items / price tables
                   (itemb.last_update_date > g_bulk_last_run_date
                    OR itemtlp.last_update_date > g_bulk_last_run_date
                    OR extitemtlp.last_update_date > g_bulk_last_run_date
                    OR price.last_update_date > g_bulk_last_run_date)
                   OR -- The items that errored out in the previous run
                   (upg.po_header_id is null
                    OR upg.po_line_id is null))
           UNION ALL
           -- Added NVL to org_id, supplier, site and currency
           SELECT NVL(itemtlp.org_id, -2) org_id, NVL(itemtlp.supplier_id, -2) supplier_id,
                  NVL(price.supplier_site_id, -2) supplier_site_id, NVL(price.currency, '-2') currency,
                  price.contract_id gbpa_cpa_reference,
                  itemtlp.language language,
                  upg.po_interface_header_id,
                  upg.po_header_id, upg.created_language,
                  nvl(upg.cpa_reference, -2) upg_cpa_reference
           FROM   icx_cat_item_prices price, icx_cat_items_tlp itemtlp,
                  icx_cat_items_b itemb, icx_cat_ext_items_tlp extitemtlp,
                  icx_cat_r12_upgrade upg
           WHERE  price.price_type = 'CONTRACT'
           AND    price.rt_item_id = itemtlp.rt_item_id
           AND    NOT EXISTS (SELECT 'extracted price'
                              FROM   icx_cat_item_prices priceIn
                              WHERE  priceIn.rt_item_id = price.rt_item_id
                              AND    priceIn.price_type IN ('BLANKET', 'GLOBAL_AGREEMENT', 'QUOTATION',
                                                            'INTERNAL_TEMPLATE', 'TEMPLATE', 'ASL'))
           AND    price.rt_item_id = itemb.rt_item_id
           AND    price.rt_item_id = extitemtlp.rt_item_id
           AND    itemtlp.language = extitemtlp.language
           AND    price.rt_item_id = upg.rt_item_id (+)
           AND    price.supplier_site_id = upg.supplier_site_id (+)
           AND    price.currency = upg.currency (+)
           AND    price.contract_id = upg.price_contract_id (+)
           AND    ( -- Last update changes in items / price tables
                   (itemb.last_update_date > g_bulk_last_run_date
                    OR itemtlp.last_update_date > g_bulk_last_run_date
                    OR extitemtlp.last_update_date > g_bulk_last_run_date
                    OR price.last_update_date > g_bulk_last_run_date)
                   OR -- The items that errored out in the previous run
                   (upg.po_header_id is null
                    OR upg.po_line_id is null))
           ) doc
    GROUP BY doc.org_id, doc.supplier_id, doc.supplier_site_id,
             doc.currency, doc.gbpa_cpa_reference,
             doc.language,
             doc.po_interface_header_id, doc.po_header_id,
             doc.created_language, doc.upg_cpa_reference
    ORDER BY doc.org_id, doc.supplier_id, doc.supplier_site_id,
             doc.currency, doc.gbpa_cpa_reference,
             doc.po_interface_header_id, count DESC, doc.language;

  ----- Start of declaring columns selected in the cursor -----

  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_supplier_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_supplier_site_id_tbl        DBMS_SQL.NUMBER_TABLE;
  l_currency_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_gbpa_cpa_reference_tbl      DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_po_interface_header_id_tbl  DBMS_SQL.NUMBER_TABLE;
  l_po_header_id_tbl            DBMS_SQL.NUMBER_TABLE;
  l_upg_created_language_tbl    DBMS_SQL.VARCHAR2_TABLE;
  l_upg_cpa_reference_tbl       DBMS_SQL.NUMBER_TABLE;
  l_count_tbl                   DBMS_SQL.NUMBER_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'checkUpdateInGBPAForDelta';
  l_err_loc                     PLS_INTEGER;
  l_interface_header_id         NUMBER;
  l_start_date          	DATE;
  l_end_date            	DATE;
  l_log_string			VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;
  -- Perform the contract auto sourcing for delta
  contractAutoSourcing;

  l_err_loc := 110;
  OPEN checkUpdateInGBPAForDeltaCsr;

  l_err_loc := 120;
  --Not expecting a huge number of GBPA header's that will be returned from the cursor.
  --Considering the fact that we are grouping by on supplier_id, org_id, supplier_site_id, currency and language
  FETCH checkUpdateInGBPAForDeltaCsr BULK COLLECT INTO
           l_org_id_tbl, l_supplier_id_tbl, l_supplier_site_id_tbl, l_currency_tbl,
           l_gbpa_cpa_reference_tbl, l_language_tbl,
           l_po_interface_header_id_tbl, l_po_header_id_tbl, l_upg_created_language_tbl,
           l_upg_cpa_reference_tbl, l_count_tbl;


  l_err_loc := 130;
  CLOSE checkUpdateInGBPAForDeltaCsr;

  l_err_loc := 140;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Total no: of distinct GBPA headers attributes found:' || l_org_id_tbl.COUNT);
  END IF;

  l_err_loc := 150;
  FOR i in 1..l_org_id_tbl.COUNT LOOP
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          ' --> Values fetched from the cursor; '||
          'l_org_id_tbl:' || l_org_id_tbl(i) ||
          ', l_supplier_id_tbl:' || l_supplier_id_tbl(i) ||
          ', l_supplier_site_id_tbl:' || l_supplier_site_id_tbl(i) ||
          ', l_currency_tbl:' || l_currency_tbl(i) ||
          ', l_gbpa_cpa_reference_tbl:' || l_gbpa_cpa_reference_tbl(i) ||
          ', l_language_tbl:' || l_language_tbl(i) ||
          ', l_supplier_id_tbl:' || l_supplier_id_tbl(i) ||
          ', l_po_interface_header_id_tbl:' || l_po_interface_header_id_tbl(i) ||
          ', l_po_header_id_tbl:' || l_po_header_id_tbl(i) ||
          ', l_upg_created_language_tbl:' ||l_upg_created_language_tbl(i) ||
          ', l_upg_cpa_reference_tbl:' || l_upg_cpa_reference_tbl(i) ||
          ', l_count_tbl:' || l_count_tbl(i) );
    END IF;

    l_err_loc := 160;
    g_current_gbpa_hdr_rec.org_id               := l_org_id_tbl(i);
    g_current_gbpa_hdr_rec.vendor_id            := l_supplier_id_tbl(i);
    g_current_gbpa_hdr_rec.vendor_site_id       := l_supplier_site_id_tbl(i);
    g_current_gbpa_hdr_rec.currency_code        := l_currency_tbl(i);
    g_current_gbpa_hdr_rec.language             := l_language_tbl(i);
    g_current_gbpa_hdr_rec.cpa_reference        := l_gbpa_cpa_reference_tbl(i);
    g_current_gbpa_hdr_rec.interface_header_id  := l_po_interface_header_id_tbl(i);
    g_current_gbpa_hdr_rec.po_header_id         := l_po_header_id_tbl(i);
    g_current_gbpa_hdr_rec.upg_created_language := l_upg_created_language_tbl(i);
    g_current_gbpa_hdr_rec.upg_cpa_reference    := l_upg_cpa_reference_tbl(i);

    l_err_loc := 170;
    processGBPALinesForDelta;
  END LOOP; --FOR LOOP of l_org_id_tbl

  l_err_loc := 180;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date) ||
        '; Total no: of GBPA headers created:' || g_GBPA_hdr_count ||
        ', Total no: of bulkload items processed:' || g_total_bulkld_row_count);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    raise;
END checkUpdateInGBPAForDelta;

PROCEDURE checkDeleteInGBPAForDelta
IS
  -- Reason for joining back to po_headers_all is:
  -- pomigratecatalog code is dependant on the org_id being
  -- populated in po_headers_interface for its processing
  -- Reason for outer join with po_headers_all, because there may be items in
  -- catalog that was never migrated due to errors, so they will have po_header_id as null
  CURSOR getDeletedItemPricesInCatlgCsr IS
    SELECT rt_item_id, po_interface_header_id, po_interface_line_id,
           upg.po_header_id, po_line_id, ph.org_id
    FROM icx_cat_r12_upgrade upg, po_headers_all ph
    WHERE NOT EXISTS (SELECT 'x'
                      FROM icx_cat_items_b itemsB, icx_cat_item_prices prices
                      WHERE itemsB.rt_item_id = prices.rt_item_id
                      AND upg.rt_item_id = prices.rt_item_id
                      AND upg.supplier_site_id = prices.supplier_site_id
                      AND upg.currency = prices.currency
                      AND upg.price_contract_id = prices.contract_id)
                      /* NOT NEEDED IF WE UPDATE the prices table with contract_id = -2 for bulkload items.
                          (upg.contract_id IS NULL OR
                           prices.contract_id IS NULL OR
                           upg.contract_id = prices.contract_id) */
    AND upg.po_header_id = ph.po_header_id (+)
    -- Order by is done for inserting only one header into po_interface_headers
    -- for all the lines to be deleted in a particular header.
    ORDER BY upg.po_header_id;

  ----- Start of declaring columns selected in the cursor -----

  l_rt_item_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_po_interface_header_id_tbl  DBMS_SQL.NUMBER_TABLE;
  l_po_interface_line_id_tbl    DBMS_SQL.NUMBER_TABLE;
  l_po_header_id_tbl            DBMS_SQL.NUMBER_TABLE;
  l_po_line_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name            CONSTANT VARCHAR2(30)   := 'checkDeleteInGBPAForDelta';
  l_err_loc             PLS_INTEGER;
  l_err_string          VARCHAR2(4000);
  l_batch_count         PLS_INTEGER;
  l_item_row_count      PLS_INTEGER;
  l_prev_po_header_id   NUMBER;
  l_interface_header_id NUMBER;
  l_interface_line_id   NUMBER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;
  l_batch_count := 0;
  l_item_row_count := 0;
  --Assign the previous po_header_id to some dummy values
  l_prev_po_header_id := -1212;

  l_err_loc := 110;
  OPEN getDeletedItemPricesInCatlgCsr;

  LOOP
    l_err_loc := 120;
    l_rt_item_id_tbl.DELETE;
    l_po_interface_header_id_tbl.DELETE;
    l_po_interface_line_id_tbl.DELETE;
    l_po_header_id_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_org_id_tbl.DELETE;

    BEGIN
      l_err_loc := 130;
      FETCH getDeletedItemPricesInCatlgCsr BULK COLLECT INTO
            l_rt_item_id_tbl, l_po_interface_header_id_tbl,
            l_po_interface_line_id_tbl, l_po_header_id_tbl,
            l_po_line_id_tbl, l_org_id_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Total no: of records fetced from the cursor:' || l_rt_item_id_tbl.COUNT);
      END IF;

      l_err_loc := 160;
      EXIT WHEN l_rt_item_id_tbl.COUNT = 0;

      l_err_loc := 170;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 190;
      l_item_row_count := l_item_row_count + l_rt_item_id_tbl.COUNT;

      l_err_loc := 200;
      FOR i in 1..l_rt_item_id_tbl.COUNT LOOP
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              ' --> Values fetched from the cursor; '||
              'l_rt_item_id_tbl:' || l_rt_item_id_tbl(i) ||
              ', l_po_interface_header_id_tbl:' || l_po_interface_header_id_tbl(i) ||
              ', l_po_interface_line_id_tbl:' || l_po_interface_line_id_tbl(i) ||
              ', l_po_header_id_tbl:' || l_po_header_id_tbl(i) ||
              ', l_po_line_id_tbl:' || l_po_line_id_tbl(i) ||
              ', l_org_id_tbl:' || l_org_id_tbl(i) );
        END IF;

        IF (l_po_line_id_tbl(i) IS NOT NULL) THEN
          --Only if the line was created as a po_line, need to Insert a row
          --in po_lines_interface with DELETE action
          --And also delete the row from icx_cat_r12_upgrade.
          IF (l_prev_po_header_id <> l_po_header_id_tbl(i)) THEN
            --po_header_id has changed, so get the next interfaceHeaderId
            --and populate a line in po_headers_interface
            l_interface_header_id := getNextInterfaceHdrIdFromSeq;

            l_err_loc := 210;
            g_po_hdrs_int_rec.interface_header_id     := l_interface_header_id;
            g_po_hdrs_int_rec.action                  := 'UPDATE';
            g_po_hdrs_int_rec.document_type_code      := 'BLANKET';
            g_po_hdrs_int_rec.budget_account_segment1 := null;
            g_po_hdrs_int_rec.po_header_id            := l_po_header_id_tbl(i);
            g_po_hdrs_int_rec.approval_status         := 'IN PROCESS';
            g_po_hdrs_int_rec.org_id                  := l_org_id_tbl(i);
            --The rest of the values can be inserted as null in po_headers_interface
            --i.e. we are not touching the values that are alreay present in po_headers_all
            g_po_hdrs_int_rec.vendor_id               := null;
            g_po_hdrs_int_rec.vendor_site_id          := null;
            g_po_hdrs_int_rec.currency_code           := null;
            g_po_hdrs_int_rec.cpa_reference           := null;
            g_po_hdrs_int_rec.created_language        := null;
            g_po_hdrs_int_rec.comments                := null;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  ' --> inserting into headers interface' ||
                  ', g_po_hdrs_int_rec.po_header_id: ' || g_po_hdrs_int_rec.po_header_id ||
                  ', l_interface_header_id: ' || l_interface_header_id);
            END IF;
            insertPOHeadersInterface;
          END IF;

          --Get the next interfaceLineId to be used in po_lines_interface
          l_interface_line_id := getNextInterfaceLineIdFromSeq;
          l_err_loc := 220;
          --Put the current values into g_po_line_attrval_int_rec for po_lines_interface
          g_po_line_attrval_int_rec.interface_header_id          := l_interface_header_id;
          g_po_line_attrval_int_rec.interface_line_id            := l_interface_line_id;
          g_po_line_attrval_int_rec.action                       := 'DELETE';
          g_po_line_attrval_int_rec.po_line_id                   := l_po_line_id_tbl(i);
          g_po_line_attrval_int_rec.po_header_id                 := l_po_header_id_tbl(i);
          --Put the rest as null
          g_po_line_attrval_int_rec.unit_price                   := null;
          g_po_line_attrval_int_rec.uom_code                     := null;
          g_po_line_attrval_int_rec.negotiated_by_preparer_flag  := null;
          g_po_line_attrval_int_rec.ip_category_id               := null;
          g_po_line_attrval_int_rec.category_id                  := null;
          g_po_line_attrval_int_rec.category_name                := null;
          g_po_line_attrval_int_rec.vendor_product_num           := null;
          g_po_line_attrval_int_rec.supplier_part_auxid          := null;
          g_po_line_attrval_int_rec.item_description             := null;
          g_po_line_attrval_int_rec.catalog_name                 := null;

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                ' --> inserting into lines interface' ||
                ', g_po_line_attrval_int_rec.po_header_id: ' || g_po_line_attrval_int_rec.po_header_id ||
                ', g_po_line_attrval_int_rec.po_line_id: ' || g_po_line_attrval_int_rec.po_line_id ||
                ', l_interface_header_id: ' || l_interface_header_id ||
                ', l_interface_line_id: ' || l_interface_line_id);
          END IF;
          insertPOLinesInterface;
        END IF;

        l_err_loc := 230;
        g_r12_upg_rec.rt_item_id                               := l_rt_item_id_tbl(i);
        g_r12_upg_rec.po_interface_header_id                   := l_po_interface_header_id_tbl(i);
        g_r12_upg_rec.po_interface_line_id                     := l_po_interface_line_id_tbl(i);
        g_r12_upg_rec.po_header_id                             := l_po_header_id_tbl(i);
        g_r12_upg_rec.po_line_id                               := l_po_line_id_tbl(i);

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              ' --> deleting from r12 upgrade' ||
              ', l_rt_item_id_tbl: ' || l_rt_item_id_tbl(i) );
        END IF;
        deleteR12Upgrade;

        l_err_loc := 240;
        l_prev_po_header_id := l_po_header_id_tbl(i);

        l_err_loc := 300;
        populatePOInterfaceTables('INLOOP');
      END LOOP;  --FOR LOOP of l_rt_item_id_tbl

      l_err_loc := 310;
      EXIT WHEN l_rt_item_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
                        || ', Total processeded batches:' || l_batch_count
                        || ', Cursor will be reopened;';
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 330;
        IF (getDeletedItemPricesInCatlgCsr%ISOPEN) THEN
          CLOSE getDeletedItemPricesInCatlgCsr;
          OPEN getDeletedItemPricesInCatlgCsr;
        END IF;
    END;
  END LOOP; --CURSOR LOOP

  l_err_loc := 350;
  populatePOInterfaceTables('OUTLOOP');

  IF (getDeletedItemPricesInCatlgCsr%ISOPEN) THEN
    CLOSE getDeletedItemPricesInCatlgCsr;
  END IF;

  l_err_loc := 360;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date) ||
        ', Total no: of batches processed:' ||l_batch_count ||
        ', Total no: of bulkloaded items processed:' ||l_item_row_count);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    raise;
END checkDeleteInGBPAForDelta;

PROCEDURE syncPOIntHdrIdInR12UpgTbl
IS
  CURSOR syncPOIntHdrIdInR12UpgTblCsr IS
    SELECT doc.po_header_id, COUNT(*)
    FROM (SELECT po_interface_header_id, po_header_id
          FROM icx_cat_r12_upgrade
          WHERE po_header_id IS NOT NULL
          GROUP BY po_interface_header_id, po_header_id) doc
    GROUP BY po_header_id
    HAVING COUNT(*) > 1;

  CURSOR syncRowsInR12UpgTblCsr IS
    SELECT rowid
    FROM icx_cat_r12_upgrade
    WHERE po_header_id IS NULL
    AND po_interface_header_id IS NOT NULL;

  ----- Start of declaring columns selected in the cursor -----

  l_po_header_id_tbl    DBMS_SQL.NUMBER_TABLE;
  l_count_tbl           DBMS_SQL.NUMBER_TABLE;
  l_rowid_tbl           DBMS_SQL.UROWID_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name            CONSTANT VARCHAR2(30)   := 'syncPOIntHdrIdInR12UpgTbl';
  l_err_loc             PLS_INTEGER;
  l_batch_count         PLS_INTEGER;
  l_item_row_count      PLS_INTEGER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_upo_hdr_id_tbl      DBMS_SQL.NUMBER_TABLE;
  l_upo_int_hdr_id_tbl  DBMS_SQL.NUMBER_TABLE;
  l_upd_index           PLS_INTEGER;
  l_err_string          VARCHAR2(4000);

BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_err_loc := 200;
  OPEN syncPOIntHdrIdInR12UpgTblCsr;

  l_err_loc := 300;
  FETCH syncPOIntHdrIdInR12UpgTblCsr BULK COLLECT INTO
        l_po_header_id_tbl, l_count_tbl;

  l_err_loc := 400;
  CLOSE syncPOIntHdrIdInR12UpgTblCsr;

  l_err_loc := 500;
  FOR i in 1..l_po_header_id_tbl.COUNT LOOP
    l_upd_index := l_upo_hdr_id_tbl.COUNT + 1;
    l_err_loc := 600;
    l_upo_int_hdr_id_tbl(l_upd_index) := getNextInterfaceHdrIdFromSeq;
    l_upo_hdr_id_tbl(l_upd_index) := l_po_header_id_tbl(i);

    l_err_loc := 700;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          ' --> Values fetched from the cursor; '||
          'l_po_header_id_tbl:' || l_po_header_id_tbl(i) ||
          ', l_count_tbl:' || l_count_tbl(i) ||
          ', new_interface_header_id:' || l_upo_int_hdr_id_tbl(l_upd_index) );
    END IF;
  END LOOP;  --FOR LOOP of l_po_header_id_tbl

  l_err_loc := 800;
  FORALL i IN 1..l_upo_hdr_id_tbl.COUNT
    UPDATE icx_cat_r12_upgrade
    SET po_interface_header_id = l_upo_int_hdr_id_tbl(i)
    WHERE po_header_id = l_upo_hdr_id_tbl(i);

  l_err_loc := 900;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Number of rows updated in r12 upgrade with new interface_header_id ' || SQL%ROWCOUNT);
  END IF;

  l_err_loc := 1000;

  -- Set po_interface_header_id and created_language
  -- to null for all the rows which doesn't have a po_header_id
  l_batch_count := 0;
  l_item_row_count := 0;

  OPEN syncRowsInR12UpgTblCsr;

  LOOP
    l_err_loc := 1100;
    l_rowid_tbl.DELETE;

    BEGIN
      l_err_loc := 1200;
      FETCH syncRowsInR12UpgTblCsr BULK COLLECT INTO
            l_rowid_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size;

      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'Total no: of rows fetched from the cursor:' || l_rowid_tbl.COUNT);
      END IF;

      l_err_loc := 1300;
      EXIT WHEN l_rowid_tbl.COUNT = 0;

      l_err_loc := 1400;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 1500;
      l_item_row_count := l_item_row_count + l_rowid_tbl.COUNT;

      l_err_loc := 1600;
      FORALL i IN 1..l_rowid_tbl.COUNT
        UPDATE icx_cat_r12_upgrade
        SET po_interface_header_id = NULL,
            created_language = NULL
        WHERE rowid = l_rowid_tbl(i);

      l_err_loc := 1700;
      IF (l_rowid_tbl.COUNT > 0) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'No: of rows updated in icx_cat_r12_upgrade:' ||SQL%ROWCOUNT);
        END IF;
      END IF;

      l_err_loc := 1800;
      COMMIT;

      EXIT WHEN l_rowid_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
                        || ', Total processed batches:' || l_batch_count
                        || ', Cursor will be reopened.';
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 1900;
        IF (syncRowsInR12UpgTblCsr%ISOPEN) THEN
          CLOSE syncRowsInR12UpgTblCsr;
        END IF;
        OPEN syncRowsInR12UpgTblCsr;
    END;
  END LOOP; --CURSOR LOOP

  l_err_loc := 2000;
  IF (syncRowsInR12UpgTblCsr%ISOPEN) THEN
    CLOSE syncRowsInR12UpgTblCsr;
  END IF;

  l_err_loc := 2100;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date) ||
        ', Total no: of batches processed:' ||l_batch_count ||
        ', Total no: of bulkloaded items processed:' ||l_item_row_count);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    raise;
END syncPOIntHdrIdInR12UpgTbl;

PROCEDURE syncGBPAsForDeltaInBlkldItems
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'syncGBPAsForDeltaInBlkldItems';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start...');
  END IF;
  /*
  Possible changes after pre-upgrade and before another run of pre-upgrade/upgrade
  1. Check for items added i.e. rt_item_id not in icx_cat_r12_upgrade
  2. Check for price added i.e. price_rowid not in icx_cat_r12_upgrade
  3. Check for item updated/translation added
  Note: Steps 1, 2 and 3 will be done together using the following approach:
	a)	Outer join with icx_cat_r12_upgrade
	b)	Check for last_update_date > g_bulk_last_run_date in icx_cat_items_b, icx_cat_items_tlp,
		icx_cat_ext_items_tlp and icx_cat_item_prices
  4. Check for items deleted i.e. rt_item_id exists in icx_cat_r12_upgrade but not in icx_cat_items_b
  5. Check for price deleted i.e. price_rowid exists in icx_cat_r12_upgrade but not in icx_cat_items_b
  6. Check for any pricing hdr attribute (i.e. supplier_site_id, currency, contract_id) update after running pre-upgrade.
  Note: Steps 4, 5 and 6 will be done together using the following approach:
	a)	Get all the records from icx_cat_r12_upgrade that don't exist in icx_cat_items_b and icx_cat_item_prices
        based on rt_item_id, supplier_site_id, currency, contract_id
  7. Check for items that have errors i.e. the ones that were not migrated into po tables due to validation errors,
  These will have po_interface_header_id and po_interface_line_id populated but will have null po_header_id and po_line_id
  Assumptions: Translations cannot be deleted.
  */
  -- First we will sync up all the po_interface_header_ids
  -- in icx_cat_r12_upgrade which belongs to the same po_header_id but exists with
  -- different po_interface_header_id in icx_cat_r12_upgrade
  -- Reason being, lines belonging to the same po_header where processed at two different upgrade delta jobs.
  syncPOIntHdrIdInR12UpgTbl;

  -- call the delete
  checkDeleteInGBPAForDelta; --Checks for Steps 4, 5 and 6.
  checkUpdateInGBPAForDelta; --Checks for Steps 1, 2, 3 and 7.

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, ' done ;' );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    raise;
END syncGBPAsForDeltaInBlkldItems;

PROCEDURE migrateBulkloadItems
IS
  CURSOR cleanUpContractIdsCsr(p_rt_item_id     NUMBER) IS
    SELECT rowid, rt_item_id
    FROM icx_cat_item_prices
    WHERE rt_item_id >= p_rt_item_id
    AND price_type in ('BULKLOAD', 'CONTRACT')
    AND contract_id IS NULL;

  l_api_name            CONSTANT VARCHAR2(30)   := 'migrateBulkloadItems';
  l_err_loc             PLS_INTEGER;
  l_rowid_tbl           DBMS_SQL.UROWID_TABLE;
  l_rt_item_id_tbl      DBMS_SQL.NUMBER_TABLE;
  l_batch_count         PLS_INTEGER;
  l_start_rt_item_id    NUMBER;
  l_err_string          VARCHAR2(4000);
  l_icx_schema_name     VARCHAR2(30) := NULL;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start...');
  END IF;

  -- cleanup the contract_id for bulkload items
  l_err_loc := 110;
  OPEN cleanUpContractIdsCsr(0);
  LOOP
    l_err_loc := 120;
    l_rowid_tbl.DELETE;
    l_rt_item_id_tbl.DELETE;

    BEGIN
      l_err_loc := 130;
      FETCH cleanUpContractIdsCsr BULK COLLECT INTO
            l_rowid_tbl, l_rt_item_id_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      l_err_loc := 140;
      EXIT WHEN l_rt_item_id_tbl.COUNT = 0;

      l_err_loc := 150;
      l_batch_count := l_batch_count + 1;

      l_err_loc := 160;
      --Save the last rt_item_id processed,
      --so that re-open of cursor will start from the saved rt_item_id.
      l_start_rt_item_id := l_rt_item_id_tbl(l_rt_item_id_tbl.COUNT);

      l_err_loc := 180;
      FORALL i IN 1..l_rowid_tbl.COUNT
        UPDATE icx_cat_item_prices
        SET contract_id = -2
        WHERE rowid = l_rowid_tbl(i);

      l_err_loc := 185;
      IF (l_rowid_tbl.COUNT > 0) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'No: of rows updated in icx_cat_item_prices:' ||SQL%ROWCOUNT);
        END IF;
      END IF;

      l_err_loc := 190;
      COMMIT;

      l_err_loc := 200;
      EXIT WHEN l_rt_item_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
                        || ', Total processeded batches:' || l_batch_count
                        || ', Cursor will be reopened with rt_item_id:' || l_start_rt_item_id;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 210;
        IF (cleanUpContractIdsCsr%ISOPEN) THEN
          CLOSE cleanUpContractIdsCsr;
          OPEN cleanUpContractIdsCsr(l_start_rt_item_id);
        END IF;
    END;
  END LOOP; --CURSOR LOOP

  l_err_loc := 220;
  IF (cleanUpContractIdsCsr%ISOPEN) THEN
    CLOSE cleanUpContractIdsCsr;
  END IF;

  g_GBPA_hdr_count := 0;
  g_total_bulkld_row_count := 0;

  IF g_bulk_last_run_date IS NULL THEN
    l_err_loc := 230;
    -- Delete all the rows in icx_cat_r12_upgrade, because pre-upgrade was never run
    -- or never ran successfully.  But icx_cat_r12_upgrade could have data from the
    -- previous run of data exception jobs.
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'g_bulk_last_run_date:' || g_bulk_last_run_date ||
          '; about to truncate icx_cat_r12_upgrade...');
    END IF;

    l_err_loc := 240;
    l_icx_schema_name := ICX_CAT_UTIL_PVT.getIcxSchemaName;

    l_err_loc := 250;
    EXECUTE IMMEDIATE
      'TRUNCATE TABLE '|| l_icx_schema_name ||'.icx_cat_r12_upgrade';

    l_err_loc := 260;
    createGBPAsForBlkldItems;  --First time
  ELSE
    l_err_loc := 270;
    syncGBPAsForDeltaInBlkldItems;  --Pre-upgrade is already run
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    raise;
END migrateBulkloadItems;

-- End of bulk load items upgrade --

-- No need of this in the code to be source controlled.
PROCEDURE callPOMigrateCatalog
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'callPOMigrateCatalog';
  l_err_loc             PLS_INTEGER;
  l_return_status       VARCHAR2(20);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(4000);
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  ICX_CAT_UTIL_PVT.g_job_pdoi_update_date := NULL;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_string := 'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
                    ', g_current_program:' || ICX_CAT_UTIL_PVT.g_current_program ||
                    ', g_data_exception_program:' || ICX_CAT_UTIL_PVT.g_data_exception_program;
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        l_log_string);
  END IF;

  -- Call the PDOI API.
  IF (ICX_CAT_UTIL_PVT.g_current_program = ICX_CAT_UTIL_PVT.g_data_exception_program) THEN
    l_err_loc := 200;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Calling migrate catalog with FND_API.G_TRUE:' || FND_API.G_TRUE);
    END IF;
    -- Call it with 'FND_API.G_TRUE' for validate only and no commit done to transaction tables
    PO_R12_CAT_UPG_GRP.migrate_catalog
    (   1.0                             ,       -- P_API_VERSION
        FND_API.G_TRUE                  ,       -- P_COMMIT
        FND_API.G_FALSE                 ,       -- P_INIT_MSG_LIST
        FND_API.G_VALID_LEVEL_FULL      ,       -- P_VALIDATION_LEVEL
        1                               ,       -- P_LOG_LEVEL
        g_PDOI_batch_id                 ,       -- P_BATCH_ID
        ICX_CAT_UTIL_PVT.g_batch_size   ,       -- P_BATCH_SIZE
        FND_API.G_TRUE                  ,       -- P_VALIDATE_ONLY_MODE
        l_return_status                 ,       -- X_RETURN_STATUS
        l_msg_count                     ,       -- X_MSG_COUNT
        l_msg_data                              -- X_MSG_DATA
    );

    -- Remove all the rows that are created in icx_cat_r12_upgrade table in the current job.
  ELSE
    l_err_loc := 300;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Calling migrate catalog with FND_API.G_FALSE:' || FND_API.G_FALSE);
    END IF;
    -- Call it with 'FND_API.G_FALSE' for commit into transaction tables
    PO_R12_CAT_UPG_GRP.migrate_catalog
    (   1.0                             ,       -- P_API_VERSION
        FND_API.G_TRUE                  ,       -- P_COMMIT
        FND_API.G_FALSE                 ,       -- P_INIT_MSG_LIST
        FND_API.G_VALID_LEVEL_FULL      ,       -- P_VALIDATION_LEVEL
        1                               ,       -- P_LOG_LEVEL
        g_PDOI_batch_id                 ,       -- P_BATCH_ID
        ICX_CAT_UTIL_PVT.g_batch_size   ,       -- P_BATCH_SIZE
        FND_API.G_FALSE                 ,       -- P_VALIDATE_ONLY_MODE
        l_return_status                 ,       -- X_RETURN_STATUS
        l_msg_count                     ,       -- X_MSG_COUNT
        l_msg_data                              -- X_MSG_DATA
    );
  END IF;

  l_err_loc := 400;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

  l_err_loc := 500;
  ICX_CAT_UTIL_PVT.g_job_pdoi_complete_date := SYSDATE;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    ICX_CAT_UTIL_PVT.g_job_pdoi_complete_date := NULL;
    RAISE;
END callPOMigrateCatalog;

PROCEDURE callICXProcessDataExcptnRpt
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'callICXProcessDataExcptnRpt';
  l_err_loc             PLS_INTEGER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_err_loc := 200;
  -- Call the ICX API to process the data exception report for the
  -- lines rejected during poMigrateCatalog with errors.
  ICX_CAT_R12_DATA_EXCEP_RPT_PVT.process_data_exceptions_report(g_PDOI_batch_id);

  l_err_loc := 300;
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
    ICX_CAT_UTIL_PVT.g_job_current_status := ICX_CAT_UTIL_PVT.g_job_failed_status;
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
END callICXProcessDataExcptnRpt;

PROCEDURE updatePOHeaderId
(       p_interface_header_id   IN      DBMS_SQL.NUMBER_TABLE
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'updatePOHeaderId';
  l_err_loc     PLS_INTEGER;
  l_row_count   PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start...');
  END IF;

  FOR i IN 1..p_interface_header_id.COUNT LOOP
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'p_interface_header_id('||i||'):' || p_interface_header_id(i));
    END IF;
  END LOOP;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Count of p_interface_header_id:' || p_interface_header_id.COUNT);
  END IF;

  l_err_loc := 200;
  FORALL i IN 1..p_interface_header_id.COUNT
    UPDATE icx_cat_r12_upgrade upg
    SET    (po_header_id, created_language) =
           (SELECT po_header_id, created_language
            FROM po_headers_interface phi
            WHERE phi.interface_header_id = upg.po_interface_header_id)
    WHERE upg.po_interface_header_id = p_interface_header_id(i);

  l_err_loc := 300;
  l_row_count := SQL%ROWCOUNT;

  l_err_loc := 350;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'No: of header rows updated in icx_cat_r12_upgrade table:' || l_row_count ||
        ', g_job_pdoi_update_date:' || ICX_CAT_UTIL_PVT.g_job_pdoi_update_date);
  END IF;

  l_err_loc := 400;
  IF (l_row_count > 0 AND
      ICX_CAT_UTIL_PVT.g_job_pdoi_update_date IS NULL)
  THEN
    ICX_CAT_UTIL_PVT.g_job_pdoi_update_date := sysdate;
    -- Update the pdoi_update_date in the jobs table.
    updateR12UpgradeJob(ICX_CAT_UTIL_PVT.g_job_paused_status);
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          ', g_job_pdoi_update_date set to:' || ICX_CAT_UTIL_PVT.g_job_pdoi_update_date);
    END IF;
  END IF;

  l_err_loc := 500;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, ' done ;' );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END updatePOHeaderId;

PROCEDURE updatePOLineId
(       p_interface_line_id     IN      DBMS_SQL.NUMBER_TABLE
)
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'updatePOLineId';
  l_err_loc     PLS_INTEGER;
  l_row_count   PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcBegin(g_pkg_name, l_api_name, 'Start...');
  END IF;

  FOR i IN 1..p_interface_line_id.COUNT LOOP
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'p_interface_line_id('||i||'):' || p_interface_line_id(i));
    END IF;
  END LOOP;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Count of p_interface_line_id:' || p_interface_line_id.COUNT);
  END IF;

  l_err_loc := 200;
  FORALL i IN 1..p_interface_line_id.COUNT
    UPDATE icx_cat_r12_upgrade upg
    SET    po_line_id =
           (SELECT po_line_id
            FROM po_lines_interface pli
            WHERE pli.interface_line_id = upg.po_interface_line_id)
    WHERE upg.po_interface_line_id = p_interface_line_id(i);

  l_err_loc := 300;
  l_row_count := SQL%ROWCOUNT;

  l_err_loc := 350;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'No: of line rows updated in icx_cat_r12_upgrade table:' || l_row_count ||
        ', g_job_pdoi_update_date:' || ICX_CAT_UTIL_PVT.g_job_pdoi_update_date);
  END IF;

  l_err_loc := 400;
  -- This should never be run, because the updatePoHeaderid is always called
  -- by the pdoi first, which should have already updated a value for
  -- ICX_CAT_UTIL_PVT.g_job_pdoi_update_date
  IF (l_row_count > 0 AND
      ICX_CAT_UTIL_PVT.g_job_pdoi_update_date IS NULL)
  THEN
    ICX_CAT_UTIL_PVT.g_job_pdoi_update_date := sysdate;
    -- Update the pdoi_update_date in the jobs table.
    updateR12UpgradeJob(ICX_CAT_UTIL_PVT.g_job_paused_status);
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          ', g_job_pdoi_update_date set to:' || ICX_CAT_UTIL_PVT.g_job_pdoi_update_date);
    END IF;
  END IF;

  l_err_loc := 500;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    ICX_CAT_UTIL_PVT.logProcEnd(g_pkg_name, l_api_name, ' done ;' );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END updatePOLineId;

-- Call the purgeInvalidBlanketLines to make sure we dont have any invalid documents
-- in the r12 intermedia tables
PROCEDURE callPurgeInvalidBlanketLines
IS
  l_api_name    CONSTANT VARCHAR2(30)   := 'callPurgeInvalidBlanketLines';
  l_err_loc     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  ICX_CAT_POPULATE_ITEM_PVT.purgeInvalidBlanketLines;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    ICX_CAT_UTIL_PVT.g_job_current_status := ICX_CAT_UTIL_PVT.g_job_failed_status;
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
END callPurgeInvalidBlanketLines;

PROCEDURE upgradeFavoriteListHdrs
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'upgradeFavoriteListHdrs';
  l_err_loc             PLS_INTEGER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_continue            BOOLEAN;
  l_row_count           PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_err_loc := 150;
  INSERT INTO icx_cat_fav_list_headers
  (
    employee_id, favorite_list_id, favorite_list_name,
    last_update_date, last_updated_by, last_update_login,
    creation_date, created_by,
    description, inactive_date, attribute_category,
    attribute1, attribute2, attribute3, attribute4, attribute5,
    attribute6, attribute7, attribute8, attribute9, attribute10,
    attribute11, attribute12, attribute13, attribute14, attribute15,
    primary_flag
  )
  SELECT
    employee_id, favorite_list_id, favorite_list_name,
    last_update_date, last_updated_by, last_update_login,
    NVL(creation_date, last_update_date), NVL(created_by, last_updated_by),
    description, inactive_date, attribute_category,
    attribute1, attribute2, attribute3, attribute4, attribute5,
    attribute6, attribute7, attribute8, attribute9, attribute10,
    attribute11, attribute12, attribute13, attribute14, attribute15,
    primary_flag
  FROM por_favorite_list_headers old_fav_hdrs
  WHERE NOT EXISTS (SELECT NULL
                    FROM icx_cat_fav_list_headers new_fav_hdrs
                    WHERE new_fav_hdrs.employee_id = old_fav_hdrs.employee_id
                    AND   new_fav_hdrs.favorite_list_id = old_fav_hdrs.favorite_list_id);

  l_err_loc := 200;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'No: of rows inserted into icx_cat_fav_list_headers during upgrade:' || SQL%ROWCOUNT);
  END IF;

  l_err_loc := 250;
  COMMIT;

  l_err_loc := 300;
  -- Update the primary_flag in icx_cat_fav_list_headers
  l_continue := TRUE;
  WHILE l_continue LOOP
    l_err_loc := 400;
    UPDATE icx_cat_fav_list_headers favout
    SET    primary_flag = 'Y'
    WHERE  primary_flag is null
    AND    favorite_list_name = 'POR_FAVORITE_LIST'
    AND    NOT EXISTS (SELECT 'x' FROM icx_cat_fav_list_headers favin
                       WHERE  favin.employee_id = favout.employee_id
                       AND    favin.primary_flag = 'Y')
    AND    ROWNUM <= ICX_CAT_UTIL_PVT.g_batch_size;

    l_err_loc := 500;
    l_row_count := SQL%ROWCOUNT;
    IF (l_row_count < ICX_CAT_UTIL_PVT.g_batch_size OR
        l_row_count = 0)
    THEN
      l_continue := FALSE;
    END IF;

    l_err_loc := 550;
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows updated in icx_cat_fav_list_headers for primary_flag:' || l_row_count);
    END IF;

    l_err_loc := 600;
    COMMIT;
  END LOOP;

  l_err_loc := 700;
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
    ICX_CAT_UTIL_PVT.g_job_current_status := ICX_CAT_UTIL_PVT.g_job_failed_status;
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
END upgradeFavoriteListHdrs;

PROCEDURE upgradeFavoriteListLines
IS
  -- Update the source_doc_line_id in por_favorite_list_lines
  -- for items that were bulkloaded in prior releases.
  CURSOR updSrcDocIdsInOldFavLinesCsr IS
    SELECT fav.rowid, upg.po_line_id
    FROM   por_favorite_list_lines fav,
           icx_cat_item_prices price,
           icx_cat_r12_upgrade upg
    WHERE  fav.rt_item_id IS NOT NULL
    AND    fav.price_list_id IS NOT NULL
    AND    fav.source_doc_line_id IS NULL
    AND    fav.rt_item_id = price.rt_item_id
    AND    fav.price_list_id = price.price_list_id
    AND    fav.suggested_vendor_site_id = price.supplier_site_id
    AND    price.rt_item_id = upg.rt_item_id
    AND    price.supplier_site_id = upg.supplier_site_id
    AND    price.currency = upg.currency
    AND    price.contract_id = upg.price_contract_id
    AND    upg.po_line_id IS NOT NULL;

  -- Update ItemType in por_favorite_list_lines
  CURSOR updItemTypeInOldFavLinesCsr IS
    SELECT favorite_list_line_id, source_doc_line_id, template_name,
           template_line_num, item_id, asl_id, rt_item_id
    FROM por_favorite_list_lines
    WHERE duplicate_in_r12 IS NULL
    AND item_type IS NULL
    OR (item_type = 'CATALOG'
        AND (source_doc_line_id IS NULL
             OR template_name IS NULL
             OR item_id IS NULL
             OR asl_id IS NULL));

  -- Since ASL is no longer supported in iProcurement in R12
  -- Update the two asl records with the same inventory_item_id
  -- or an asl and an inventory_item_id existing in the same
  -- favorite list as duplicate.
  CURSOR checkForDuplicatesCsr IS
    SELECT fav.favorite_list_id, fav.item_id, fav.favorite_list_line_id
    FROM
    ( SELECT favorite_list_id, item_id, duplicate_in_r12, COUNT(*)
      FROM
        ( SELECT favorite_list_id, item_id, duplicate_in_r12
          FROM por_favorite_list_lines fav_out
          WHERE fav_out.item_type = 'CATALOG'
          AND asl_id <> -2
          UNION ALL
          SELECT favorite_list_id, item_id, duplicate_in_r12
          FROM por_favorite_list_lines fav_out
          WHERE item_type = 'CATALOG'
          AND asl_id = -2 AND source_doc_line_id = -2 AND template_name = '-2'
          AND EXISTS (SELECT 'x' FROM por_favorite_list_lines fav_in
                      WHERE asl_id <> -2 AND item_type = 'CATALOG'
                      AND fav_in.item_id = fav_out.item_id
                      AND fav_in.favorite_list_id = fav_out.favorite_list_id)
        )
      GROUP BY favorite_list_id, item_id, duplicate_in_r12
      HAVING COUNT(*) > 1
    ) dupe, por_favorite_list_lines fav
    WHERE fav.favorite_list_id = dupe.favorite_list_id
    AND fav.item_id = dupe.item_id
    ORDER BY fav.favorite_list_id, fav.item_id;

  -- Includes catalog items
  CURSOR catalogItemUpgradeCsr IS
    SELECT favorite_list_id, favorite_list_line_id,
           fav.source_doc_line_id, fav.template_name,
           fav.template_line_num, fav.item_id,
           items.source_type, items.language, items.org_id
    FROM por_favorite_list_lines fav, icx_cat_items_ctx_hdrs_tlp items
    WHERE fav.item_type = 'CATALOG'
    AND fav.duplicate_in_r12 IS NULL
    AND fav.source_doc_line_id = items.po_line_id
    AND fav.template_name = items.req_template_name
    AND fav.template_line_num = items.req_template_line_num
    AND fav.item_id = items.inventory_item_id
    AND NOT EXISTS ( SELECT NULL
                     FROM icx_cat_fav_list_lines_tlp new_fav
                     WHERE new_fav.favorite_list_id = fav.favorite_list_id
                     AND new_fav.favorite_list_line_id = fav.favorite_list_line_id)
    ORDER BY favorite_list_id, favorite_list_line_id, fav.source_doc_line_id,
             fav.template_name, fav.template_line_num, fav.item_id,
             items.source_type;

  -- Includes non-catalog and external (punchout/transparent punchout items
  CURSOR otherItemUpgradeCsr (p_profile_option_id       NUMBER) IS
    SELECT fav_hdrs.favorite_list_id, fav_hdrs.employee_id, users.user_id,
           prf_vals.profile_option_value, COUNT(*)
    FROM por_favorite_list_headers fav_hdrs, fnd_user users,
         fnd_profile_option_values prf_vals, por_favorite_list_lines fav_lines
    WHERE fav_hdrs.favorite_list_id = fav_lines.favorite_list_id
    AND fav_lines.item_type <> 'CATALOG'
    AND fav_hdrs.employee_id = users.employee_id (+)
    AND users.user_id = prf_vals.level_value (+)
    AND prf_vals.profile_option_id (+) = p_profile_option_id
    AND prf_vals.level_id (+) = 10004
    AND NOT EXISTS ( SELECT NULL
                     FROM icx_cat_fav_list_lines_tlp new_fav
                     WHERE new_fav.favorite_list_id = fav_lines.favorite_list_id
                     AND new_fav.favorite_list_line_id = fav_lines.favorite_list_line_id )
    GROUP BY fav_hdrs.favorite_list_id, fav_hdrs.employee_id, users.user_id,
             prf_vals.profile_option_value
    ORDER BY fav_hdrs.favorite_list_id, fav_hdrs.employee_id, users.user_id;

  CURSOR getOrgIdsAtRespAndAppLevelCsr (p_user_id             NUMBER,
                                        p_profile_option_id   NUMBER) IS
    SELECT DISTINCT NVL(resp_profile.profile_option_value,
                      NVL(app_profile.profile_option_value, -2)) org_id
    FROM fnd_responsibility resp,
         fnd_profile_option_values resp_profile,
         fnd_profile_option_values app_profile,
         fnd_user_resp_groups_all user_resp
    WHERE user_resp.user_id = p_user_id
    AND user_resp.responsibility_application_id IN (177, 178, 201, 396, 426)
    AND user_resp.responsibility_id = resp.responsibility_id
    AND user_resp.responsibility_application_id = resp.application_id
    AND app_profile.profile_option_id(+) = p_profile_option_id
    AND app_profile.level_id(+) = 10002
    AND app_profile.level_value(+) = resp.application_id
    AND resp_profile.profile_option_id(+) = p_profile_option_id
    AND resp_profile.level_id(+) = 10003
    AND resp_profile.level_value(+) = resp.responsibility_id
    ORDER BY 1;

  CURSOR getOtherFavLinesForHdrCsr (p_favorite_list_id  NUMBER) IS
    SELECT favorite_list_line_id
    FROM por_favorite_list_lines fav_lines
    WHERE fav_lines.favorite_list_id = p_favorite_list_id
    AND fav_lines.item_type <> 'CATALOG';

  ----- Start of declaring columns selected in the cursor -----

  l_rowid_tbl                   DBMS_SQL.UROWID_TABLE;
  l_favorite_list_id_tbl        DBMS_SQL.NUMBER_TABLE;
  l_favorite_list_line_id_tbl   DBMS_SQL.NUMBER_TABLE;
  l_po_line_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_req_template_name_tbl       DBMS_SQL.VARCHAR2_TABLE;
  l_req_template_line_num_tbl   DBMS_SQL.NUMBER_TABLE;
  l_inventory_item_id_tbl       DBMS_SQL.NUMBER_TABLE;
  l_asl_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_rt_item_id_tbl              DBMS_SQL.NUMBER_TABLE;
  l_language_tbl                DBMS_SQL.VARCHAR2_TABLE;
  l_employee_id_tbl             DBMS_SQL.NUMBER_TABLE;
  l_user_id_tbl                 DBMS_SQL.NUMBER_TABLE;
  l_profile_option_value_tbl    DBMS_SQL.VARCHAR2_TABLE;
  l_count_tbl                   DBMS_SQL.NUMBER_TABLE;
  l_org_id_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_source_type_tbl             DBMS_SQL.VARCHAR2_TABLE;
  l_item_type_tbl               DBMS_SQL.VARCHAR2_TABLE;
  l_dupe_fav_list_line_id_tbl   DBMS_SQL.NUMBER_TABLE;

  ------ End of declaring columns selected in the cursor ------

  l_api_name                    CONSTANT VARCHAR2(30)   := 'upgradeFavoriteListLines';
  l_err_loc                     PLS_INTEGER;
  l_start_date                  DATE;
  l_end_date                    DATE;
  l_err_string                  VARCHAR2(4000);
  l_continue                    BOOLEAN;
  l_row_count                   PLS_INTEGER;
  l_batch_count                 PLS_INTEGER;
  l_prev_favorite_list_id       NUMBER  := -1;
  l_prev_favorite_list_line_id  NUMBER  := -1;
  l_prev_rt_item_id             NUMBER  := -1;
  l_prev_po_line_id             NUMBER  := -1;
  l_prev_req_template_name      icx_cat_items_ctx_hdrs_tlp.req_template_name%TYPE := '-1';
  l_prev_req_template_line_num  NUMBER  := -1;
  l_prev_inventory_item_id      NUMBER  := -1;
  l_prev_source_type            icx_cat_items_ctx_hdrs_tlp.source_type%TYPE := '-1';
  l_dupe_fav_list_index         PLS_INTEGER := 0;
  l_fav_list_lines_index        PLS_INTEGER := 0;
  l_org_id_index                PLS_INTEGER := 0;
  l_profile_option_id           NUMBER;
  l_org_id_profile_value_exist  VARCHAR2(1) := 'N';
  l_org_already_exists          VARCHAR2(1) := 'N';
  l_site_level_prf_opt_val      fnd_profile_option_values.profile_option_value%TYPE;
  l_is_site_prf_val_in_org_tbl  VARCHAR2(1) := 'N';

BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_err_loc := 150;
  -- Update the source_doc_line_id in por_favorite_list_lines
  -- for items that were bulkloaded in prior releases.
  l_batch_count := 0;
  OPEN updSrcDocIdsInOldFavLinesCsr;

  LOOP
    l_err_loc := 200;
    l_rowid_tbl.DELETE;
    l_po_line_id_tbl.DELETE;

    BEGIN
      l_err_loc := 250;
      FETCH updSrcDocIdsInOldFavLinesCsr BULK COLLECT INTO
            l_rowid_tbl, l_po_line_id_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      l_err_loc := 300;
      EXIT WHEN l_rowid_tbl.COUNT = 0;

      l_batch_count := l_batch_count + 1;

      l_err_loc := 350;
      FORALL i in 1..l_rowid_tbl.COUNT
        UPDATE por_favorite_list_lines
        SET source_doc_line_id = l_po_line_id_tbl(i)
        WHERE rowid = l_rowid_tbl(i);

      l_err_loc := 400;
      IF (l_rowid_tbl.COUNT > 0) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'No: of rows updated in por_favorite_list_lines for bulk loaded items:' ||SQL%ROWCOUNT);
        END IF;
      END IF;

      l_err_loc := 450;
      COMMIT;

      l_err_loc := 500;
      EXIT WHEN l_rowid_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
                        || ', Total processeded batches:' || l_batch_count;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 550;
        CLOSE updSrcDocIdsInOldFavLinesCsr;
        OPEN updSrcDocIdsInOldFavLinesCsr;
    END;
  END LOOP; -- CURSOR LOOP updSrcDocIdsInOldFavLinesCsr

  l_err_loc := 580;
  IF (updSrcDocIdsInOldFavLinesCsr%ISOPEN) THEN
    CLOSE updSrcDocIdsInOldFavLinesCsr;
  END IF;

  l_err_loc := 600;
  -- Update ItemType in por_favorite_list_lines
  l_batch_count := 0;
  OPEN updItemTypeInOldFavLinesCsr;

  LOOP
    l_err_loc := 700;
    l_favorite_list_line_id_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_req_template_name_tbl.DELETE;
    l_req_template_line_num_tbl.DELETE;
    l_inventory_item_id_tbl.DELETE;
    l_asl_id_tbl.DELETE;
    l_rt_item_id_tbl.DELETE;
    l_item_type_tbl.DELETE;

    BEGIN
      l_err_loc := 800;
      FETCH updItemTypeInOldFavLinesCsr BULK COLLECT INTO
            l_favorite_list_line_id_tbl, l_po_line_id_tbl,
            l_req_template_name_tbl, l_req_template_line_num_tbl,
            l_inventory_item_id_tbl, l_asl_id_tbl, l_rt_item_id_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      l_err_loc := 900;
      EXIT WHEN l_favorite_list_line_id_tbl.COUNT = 0;

      l_batch_count := l_batch_count + 1;

      l_err_loc := 1000;
      FOR i in 1..l_favorite_list_line_id_tbl.COUNT LOOP
        IF (l_rt_item_id_tbl(i) IS NULL AND
            l_po_line_id_tbl(i) IS NULL AND
            l_req_template_name_tbl(i) IS NULL AND
            l_inventory_item_id_tbl(i) IS NULL AND
            l_asl_id_tbl(i) IS NULL)
        THEN
          l_item_type_tbl(i) := 'NONCATALOG';
        ELSE
          l_err_loc := 1100;
          l_item_type_tbl(i) := 'CATALOG';
          l_po_line_id_tbl(i) := NVL(l_po_line_id_tbl(i), -2);
          l_req_template_name_tbl(i) := NVL(l_req_template_name_tbl(i), '-2');
          l_req_template_line_num_tbl(i) := NVL(l_req_template_line_num_tbl(i), -2);
          l_inventory_item_id_tbl(i) := NVL(l_inventory_item_id_tbl(i), -2);
          l_asl_id_tbl(i) := NVL(l_asl_id_tbl(i), -2);
        END IF;
      END LOOP;

      l_err_loc := 1200;
      FORALL i in 1..l_favorite_list_line_id_tbl.COUNT
        UPDATE por_favorite_list_lines
        SET item_type = l_item_type_tbl(i),
            source_doc_line_id = l_po_line_id_tbl(i),
            template_name = l_req_template_name_tbl(i),
            template_line_num = l_req_template_line_num_tbl(i),
            item_id = l_inventory_item_id_tbl(i),
            asl_id = l_asl_id_tbl(i)
        WHERE favorite_list_line_id = l_favorite_list_line_id_tbl(i);

      l_err_loc := 1300;
      IF (l_favorite_list_line_id_tbl.COUNT > 0) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'No: of rows updated in por_favorite_list_lines for item_type:' ||SQL%ROWCOUNT);
        END IF;
      END IF;

      l_err_loc := 1400;
      COMMIT;

      l_err_loc := 1500;
      EXIT WHEN l_favorite_list_line_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
                        || ', Total processeded batches:' || l_batch_count;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 1600;
        CLOSE updItemTypeInOldFavLinesCsr;
        OPEN updItemTypeInOldFavLinesCsr;
    END;
  END LOOP; -- CURSOR LOOP updItemTypeInOldFavLinesCsr

  l_err_loc := 1700;
  IF (updItemTypeInOldFavLinesCsr%ISOPEN) THEN
    CLOSE updItemTypeInOldFavLinesCsr;
  END IF;

  l_err_loc := 1710;
  l_favorite_list_line_id_tbl.DELETE;
  l_po_line_id_tbl.DELETE;
  l_req_template_name_tbl.DELETE;
  l_req_template_line_num_tbl.DELETE;
  l_inventory_item_id_tbl.DELETE;
  l_asl_id_tbl.DELETE;
  l_rt_item_id_tbl.DELETE;
  l_item_type_tbl.DELETE;

  l_err_loc := 1800;
  l_prev_favorite_list_id       := -1;
  l_prev_inventory_item_id      := -1;

  -- Since ASL is no longer supported in iProcurement in R12
  -- Update the two asl records with the same inventory_item_id
  -- or an asl and an inventory_item_id existing in the same
  -- favorite list as duplicate.d
  l_batch_count := 0;
  l_err_loc := 1900;
  OPEN checkForDuplicatesCsr;

  LOOP
    l_err_loc := 2000;
    l_favorite_list_id_tbl.DELETE;
    l_inventory_item_id_tbl.DELETE;
    l_favorite_list_line_id_tbl.DELETE;

    BEGIN
      l_err_loc := 2100;
      FETCH checkForDuplicatesCsr BULK COLLECT INTO
            l_favorite_list_id_tbl,
            l_inventory_item_id_tbl,
            l_favorite_list_line_id_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      l_err_loc := 2200;
      EXIT WHEN l_favorite_list_line_id_tbl.COUNT = 0;

      l_batch_count := l_batch_count + 1;

      l_err_loc := 2300;
      FOR i in 1..l_favorite_list_line_id_tbl.COUNT LOOP
        IF (l_prev_favorite_list_id             = l_favorite_list_id_tbl(i)     AND
            l_prev_inventory_item_id            = l_inventory_item_id_tbl(i)    )
        THEN
          l_err_loc := 2400;
          -- Two lines exist with the same inventory_item_id,
          -- So mark this one as duplicate
          l_dupe_fav_list_index := l_dupe_fav_list_line_id_tbl.COUNT + 1;
          l_dupe_fav_list_line_id_tbl(l_dupe_fav_list_index) := l_favorite_list_line_id_tbl(i);

          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'fav list catalog lines marked as duplicate;' ||
                ', l_dupe_fav_list_line_id_tbl :' || l_dupe_fav_list_line_id_tbl(l_dupe_fav_list_index));
          END IF;
        END IF;

        l_err_loc := 2500;
        l_prev_favorite_list_id         := l_favorite_list_id_tbl(i);
        l_prev_inventory_item_id        := l_inventory_item_id_tbl(i);
      END LOOP;

      l_err_loc := 2600;
      FORALL i in 1..l_dupe_fav_list_line_id_tbl.COUNT
        UPDATE por_favorite_list_lines
        SET duplicate_in_r12 = 'Y'
        WHERE favorite_list_line_id = l_dupe_fav_list_line_id_tbl(i);

      l_err_loc := 2700;
      IF (l_favorite_list_line_id_tbl.COUNT > 0) THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'No: of rows updated in por_favorite_list_lines for duplicates:' ||SQL%ROWCOUNT);
        END IF;
      END IF;

      l_err_loc := 2800;
      l_dupe_fav_list_line_id_tbl.DELETE;

      l_err_loc := 2900;
      COMMIT;

      l_err_loc := 3000;
      EXIT WHEN l_favorite_list_line_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
                        || ', Total processeded batches:' || l_batch_count;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 3100;
        CLOSE checkForDuplicatesCsr;
        OPEN checkForDuplicatesCsr;
    END;
  END LOOP; -- CURSOR LOOP checkForDuplicatesCsr

  l_err_loc := 3200;
  IF (checkForDuplicatesCsr%ISOPEN) THEN
    CLOSE checkForDuplicatesCsr;
  END IF;

  l_err_loc := 3210;
  l_favorite_list_id_tbl.DELETE;
  l_inventory_item_id_tbl.DELETE;
  l_favorite_list_line_id_tbl.DELETE;

  l_err_loc := 3300;
  l_prev_favorite_list_id       := -1;
  l_prev_favorite_list_line_id  := -1;
  l_prev_po_line_id             := -1;
  l_prev_req_template_name      := '-1';
  l_prev_req_template_line_num  := -1;
  l_prev_inventory_item_id      := -1;
  l_prev_source_type            := '-1';

  -- Update the catalog items in favorite list lines
  l_batch_count := 0;
  l_err_loc := 3400;
  OPEN catalogItemUpgradeCsr;

  LOOP
    l_err_loc := 3500;
    l_favorite_list_id_tbl.DELETE;
    l_favorite_list_line_id_tbl.DELETE;
    l_po_line_id_tbl.DELETE;
    l_req_template_name_tbl.DELETE;
    l_req_template_line_num_tbl.DELETE;
    l_inventory_item_id_tbl.DELETE;
    l_source_type_tbl.DELETE;
    l_language_tbl.DELETE;
    l_org_id_tbl.DELETE;

    BEGIN
      l_err_loc := 3600;
      FETCH catalogItemUpgradeCsr BULK COLLECT INTO
            l_favorite_list_id_tbl, l_favorite_list_line_id_tbl,
            l_po_line_id_tbl, l_req_template_name_tbl,
            l_req_template_line_num_tbl, l_inventory_item_id_tbl,
            l_source_type_tbl, l_language_tbl, l_org_id_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      l_err_loc := 3700;
      EXIT WHEN l_favorite_list_id_tbl.COUNT = 0;

      l_batch_count := l_batch_count + 1;

      l_err_loc := 3800;
      FOR i IN 1..l_favorite_list_id_tbl.COUNT LOOP

        l_err_loc := 3900;
        g_total_row_count := g_total_row_count + 1;
        l_fav_list_lines_index := gIFLCFavoriteListIdTbl.COUNT + 1;
        gIFLCFavoriteListIdTbl(l_fav_list_lines_index) := l_favorite_list_id_tbl(i);
        gIFLCOldFavoriteListLineIdTbl(l_fav_list_lines_index) := l_favorite_list_line_id_tbl(i);
        gIFLCSourceTypeTbl(l_fav_list_lines_index) := l_source_type_tbl(i);
        gIFLCOrgIdTbl(l_fav_list_lines_index) := l_org_id_tbl(i);
        gIFLCLanguageTbl(l_fav_list_lines_index) := l_language_tbl(i);

        IF (l_prev_favorite_list_id             = l_favorite_list_id_tbl(i)             AND
            l_prev_favorite_list_line_id        = l_favorite_list_line_id_tbl(i)        AND
            l_prev_po_line_id                   = l_po_line_id_tbl(i)                   AND
            l_prev_req_template_name            = l_req_template_name_tbl(i)            AND
            l_prev_req_template_line_num        = l_req_template_line_num_tbl(i)        AND
            l_prev_inventory_item_id            = l_inventory_item_id_tbl(i)            AND
            l_prev_source_type                  = l_source_type_tbl(i)                  )
        THEN
          l_err_loc := 4000;
          -- Either language or org_id has changed, so get a new favorite_list_line_id
          gIFLCNewFavoriteListLineIdTbl(l_fav_list_lines_index) := getNextFavListLineIdFromSeq;
        ELSE
          l_err_loc := 4100;
          gIFLCNewFavoriteListLineIdTbl(l_fav_list_lines_index) := l_favorite_list_line_id_tbl(i);
        END IF;

        l_err_loc := 4200;
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'fav list catalog lines upgrade values at fav_lines_index :' || l_fav_list_lines_index ||
              ', gIFLCFavoriteListIdTbl :' || gIFLCFavoriteListIdTbl(l_fav_list_lines_index) ||
              ', gIFLCOldFavoriteListLineIdTbl :' || gIFLCOldFavoriteListLineIdTbl(l_fav_list_lines_index) ||
              ', gIFLCSourceTypeTbl :' || gIFLCSourceTypeTbl(l_fav_list_lines_index) ||
              ', gIFLCOrgIdTbl :' || gIFLCOrgIdTbl(l_fav_list_lines_index) ||
              ', gIFLCNewFavoriteListLineIdTbl :' || gIFLCNewFavoriteListLineIdTbl(l_fav_list_lines_index) ||
              ', gIFLCLanguageTbl :' || gIFLCLanguageTbl(l_fav_list_lines_index) );
        END IF;

        l_err_loc := 4300;
        l_prev_favorite_list_id         := l_favorite_list_id_tbl(i);
        l_prev_favorite_list_line_id    := l_favorite_list_line_id_tbl(i);
        l_prev_po_line_id               := l_po_line_id_tbl(i);
        l_prev_req_template_name        := l_req_template_name_tbl(i);
        l_prev_req_template_line_num    := l_req_template_line_num_tbl(i);
        l_prev_inventory_item_id        := l_inventory_item_id_tbl(i);
        l_prev_source_type              := l_source_type_tbl(i);

        l_err_loc := 4400;
        populatePOInterfaceTables('INLOOP');
      END LOOP; -- FOR LOOP of l_favorite_list_id_tbl

      l_err_loc := 4500;
      EXIT WHEN l_favorite_list_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
                        || ', Total processeded batches:' || l_batch_count;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 4600;
        CLOSE catalogItemUpgradeCsr;
        OPEN catalogItemUpgradeCsr;
    END;
  END LOOP; -- CURSOR LOOP catalogItemUpgradeCsr

  l_err_loc := 4700;
  populatePOInterfaceTables('OUTLOOP');

  l_err_loc := 4800;
  IF (catalogItemUpgradeCsr%ISOPEN) THEN
    CLOSE catalogItemUpgradeCsr;
  END IF;

  l_err_loc := 4810;
  l_favorite_list_id_tbl.DELETE;
  l_favorite_list_line_id_tbl.DELETE;
  l_po_line_id_tbl.DELETE;
  l_req_template_name_tbl.DELETE;
  l_req_template_line_num_tbl.DELETE;
  l_inventory_item_id_tbl.DELETE;
  l_source_type_tbl.DELETE;
  l_language_tbl.DELETE;
  l_org_id_tbl.DELETE;

  l_err_loc := 4900;
  l_language_tbl.DELETE;

  -- Get the installed and base languages
  l_err_loc := 5000;
  SELECT language_code
  BULK COLLECT INTO l_language_tbl
  FROM fnd_languages
  WHERE installed_flag IN ('B', 'I')
  ORDER BY installed_flag;

  l_err_loc := 5100;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'l_language_tbl.COUNT:' || l_language_tbl.COUNT);
  END IF;

  l_err_loc := 5200;
  SELECT profile_option_id
  INTO l_profile_option_id
  FROM fnd_profile_options
  WHERE profile_option_name = 'ORG_ID';

  l_err_loc := 5300;
  l_prev_favorite_list_id       := -1;

  l_batch_count := 0;
  -- Includes non-catalog and external (punchout/transparent punchout items
  l_err_loc := 5400;
  OPEN otherItemUpgradeCsr(l_profile_option_id);

  LOOP
    l_err_loc := 5500;
    l_favorite_list_id_tbl.DELETE;
    l_employee_id_tbl.DELETE;
    l_user_id_tbl.DELETE;
    l_profile_option_value_tbl.DELETE;
    l_count_tbl.DELETE;

    BEGIN
      l_err_loc := 5600;
      FETCH otherItemUpgradeCsr BULK COLLECT INTO
            l_favorite_list_id_tbl, l_employee_id_tbl,
            l_user_id_tbl, l_profile_option_value_tbl,
            l_count_tbl
      LIMIT ICX_CAT_UTIL_PVT.g_batch_size ;

      l_err_loc := 5700;
      EXIT WHEN l_favorite_list_id_tbl.COUNT = 0;

      l_batch_count := l_batch_count + 1;

      l_err_loc := 5800;
      FOR i IN 1..l_favorite_list_id_tbl.COUNT LOOP
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
              ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
              'Processing the favorite_list_id:' || l_favorite_list_id_tbl(i));
        END IF;

        l_err_loc := 5900;
        IF (l_prev_favorite_list_id <> l_favorite_list_id_tbl(i)) THEN
          l_is_site_prf_val_in_org_tbl := 'N';
        END IF;

        l_err_loc := 6000;
        IF ( l_prev_favorite_list_id <> -1                              AND
             l_prev_favorite_list_id <> l_favorite_list_id_tbl(i)       AND
             l_org_id_tbl.COUNT > 0 )
        THEN
          l_err_loc := 6100;
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Forming the gIFLO tables for favorite_list_id:' || l_prev_favorite_list_id ||
                '; l_org_id_tbl.COUNT:' || l_org_id_tbl.COUNT);
          END IF;

          l_err_loc := 6200;
          OPEN getOtherFavLinesForHdrCsr(l_prev_favorite_list_id);

          l_err_loc := 6300;
          FETCH getOtherFavLinesForHdrCsr BULK COLLECT INTO
                l_favorite_list_line_id_tbl;

          l_err_loc := 6400;
          CLOSE getOtherFavLinesForHdrCsr;

          l_err_loc := 6500;
          FOR j IN 1..l_favorite_list_line_id_tbl.COUNT LOOP
            l_err_loc := 6600;
            FOR k IN 1..l_org_id_tbl.COUNT LOOP
              l_err_loc := 6700;
              FOR l IN 1..l_language_tbl.COUNT LOOP
                l_err_loc := 6800;
                g_total_row_count := g_total_row_count + 1;
                l_fav_list_lines_index := gIFLOFavoriteListIdTbl.COUNT + 1;
                gIFLOFavoriteListIdTbl(l_fav_list_lines_index) := l_prev_favorite_list_id;
                gIFLOOldFavoriteListLineIdTbl(l_fav_list_lines_index) := l_favorite_list_line_id_tbl(j);
                IF (k=1 AND l=1) THEN
                  l_err_loc := 6900;
                  gIFLONewFavoriteListLineIdTbl(l_fav_list_lines_index) := l_favorite_list_line_id_tbl(j);
                ELSE
                  l_err_loc := 7000;
                  gIFLONewFavoriteListLineIdTbl(l_fav_list_lines_index) := getNextFavListLineIdFromSeq;
                END IF;
                l_err_loc := 7100;
                gIFLOOrgIdTbl(l_fav_list_lines_index) := l_org_id_tbl(k);
                gIFLOLanguageTbl(l_fav_list_lines_index) := l_language_tbl(l);
              END LOOP;
            END LOOP;
          END LOOP;

          l_err_loc := 7200;
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Formed the gIFLO tables for favorite_list_id:' || l_prev_favorite_list_id ||
                '; count of favorite_lines in the hdr:' || l_count_tbl(i) ||
                ', gIFLOFavoriteListIdTbl.COUNT:' || gIFLOFavoriteListIdTbl.COUNT);
          END IF;

          l_err_loc := 7300;
          l_org_id_tbl.DELETE;
          l_org_already_exists := 'N';
        END IF;

        l_err_loc := 7400;
        IF (l_user_id_tbl(i) IS NOT NULL) THEN
          IF (l_profile_option_value_tbl(i) IS NOT NULL) THEN
            l_err_loc := 7500;
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'User level profile option:ORG_ID value:' || l_profile_option_value_tbl(i));
            END IF;
            l_err_loc := 7600;
            l_org_already_exists := ICX_CAT_UTIL_PVT.checkValueExistsInTable(l_org_id_tbl, l_profile_option_value_tbl(i));
            IF ( l_org_already_exists = 'N' ) THEN
              l_err_loc := 7700;
              l_org_id_index := l_org_id_tbl.COUNT + 1;
              l_org_id_tbl(l_org_id_index) := l_profile_option_value_tbl(i);
              l_err_loc := 7800;
              IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                    ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                    'Added to the l_org_id_tbl for, l_user_id_tbl:' || l_user_id_tbl(i) ||
                    ', l_org_id_tbl.COUNT:' || l_org_id_tbl.COUNT ||
                    ', l_org_id_tbl:' || l_org_id_tbl(l_org_id_index));
              END IF;
            END IF; -- IF ( l_org_already_exists = 'N' ) THEN
          ELSE
            l_err_loc := 7900;
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                  ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                  'User level profile option:ORG_ID value:' || l_profile_option_value_tbl(i) ||
                  ', About to get the Resp level profile option:ORG_ID values');
            END IF;
            l_err_loc := 8000;
            l_org_id_profile_value_exist := 'N';

            l_err_loc := 8100;
            -- Get the profile option value at the responsibility/application for the user
            FOR l_prf_option_val IN getOrgIdsAtRespAndAppLevelCsr(l_user_id_tbl(i), l_profile_option_id) LOOP
              l_err_loc := 8200;
              l_org_id_profile_value_exist := 'Y';
              IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                    ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                    'Resp level profile option:ORG_ID value:' || l_prf_option_val.org_id);
              END IF;
              l_err_loc := 8300;
              IF (l_prf_option_val.org_id <> '-2') THEN
                l_org_already_exists := ICX_CAT_UTIL_PVT.checkValueExistsInTable(l_org_id_tbl, l_prf_option_val.org_id);
              ELSE
                l_err_loc := 8400;
                -- l_prf_option_val.org_id = -2
                -- The profile option: ORG_ID is not set at responsibility and application level,
                -- So get the profile option value at site level.
                -- Start from here ...
                IF ( l_site_level_prf_opt_val IS NULL ) THEN
                  l_err_loc := 8500;
                  SELECT profile_option_value
                  INTO l_site_level_prf_opt_val
                  FROM fnd_profile_option_values
                  WHERE profile_option_id = l_profile_option_id
                  AND level_id = 10001;

                  l_err_loc := 8600;
                  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                        'Site level profile option:ORG_ID value:' || l_site_level_prf_opt_val );
                  END IF;
                END IF;
                l_err_loc := 8700;
                IF (l_is_site_prf_val_in_org_tbl = 'N') THEN
                  l_err_loc := 8800;
                  l_org_already_exists := ICX_CAT_UTIL_PVT.checkValueExistsInTable(l_org_id_tbl, l_site_level_prf_opt_val);
                  l_is_site_prf_val_in_org_tbl := 'Y';
                ELSE
                  l_err_loc := 8900;
                  l_org_already_exists := 'Y';
                END IF;
              END IF;  -- IF (l_prf_option_val.org_id <> '-2') THEN

              IF ( l_org_already_exists = 'N' ) THEN
                l_err_loc := 9000;
                l_org_id_index := l_org_id_tbl.COUNT + 1;
                IF (l_prf_option_val.org_id <> '-2') THEN
                  l_err_loc := 9100;
                  l_org_id_tbl(l_org_id_index) := l_prf_option_val.org_id;
                ELSE
                  l_err_loc := 9200;
                  l_org_id_tbl(l_org_id_index) := l_site_level_prf_opt_val;
                END IF;

                l_err_loc := 9300;
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                      ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                      'Added to the l_org_id_tbl for, l_user_id_tbl:' || l_user_id_tbl(i) ||
                      ', l_org_id_tbl.COUNT:' || l_org_id_tbl.COUNT ||
                      ', l_org_id_tbl:' || l_org_id_tbl(l_org_id_index));
                END IF;
              END IF; -- IF ( l_org_already_exists = 'N' ) THEN
            END LOOP; -- l_prf_option_val IN getOrgIdsAtRespAndAppLevelCsr

            l_err_loc := 9400;
            IF (l_org_id_profile_value_exist = 'N') THEN
              -- Log the favorite list header info.
              -- This header will be probably removed if there are no lines in this one
              l_err_loc := 9500;
              IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                    ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                    'ALERT: The user attached to the favorite list header does not have' ||
                    ' profile option:ORG_ID value set at user level and responsibility level of' ||
                    '  those resps belong to the following applications: 177, 178, 201, 396, 426;' ||
                    ' Details: l_favorite_list_id_tbl:' || l_favorite_list_id_tbl(i) ||
                    ', l_employee_id_tbl:' || l_employee_id_tbl(i) ||
                    ', l_user_id_tbl:' || l_user_id_tbl(i) ||
                    ', l_profile_option_value_tbl:' || l_profile_option_value_tbl(i) ||
                    ', l_count_tbl:' || l_count_tbl(i) ||
                    ', l_org_id_profile_value_exist:' || l_org_id_profile_value_exist);
              END IF;
            END IF;
          END IF; -- IF (l_profile_option_value_tbl(i) IS NOT NULL) THEN
        ELSE -- IF (l_user_id_tbl(i) IS NOT NULL) THEN
          l_err_loc := 9600;
          -- Log the favorite list header info.
          -- This header will be probably removed if there are no lines in this one
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'ALERT: The employee attached to the favorite list header does not have a user;' ||
                ' Details: l_favorite_list_id_tbl:' || l_favorite_list_id_tbl(i) ||
                ', l_employee_id_tbl:' || l_employee_id_tbl(i) ||
                ', l_user_id_tbl:' || l_user_id_tbl(i) ||
                ', l_profile_option_value_tbl:' || l_profile_option_value_tbl(i) ||
                ', l_count_tbl:' || l_count_tbl(i));
          END IF;
        END IF; -- IF (l_user_id_tbl(i) IS NOT NULL) THEN

        l_err_loc := 9700;
        IF (i = l_favorite_list_id_tbl.COUNT AND
            l_org_id_tbl.COUNT > 0)
        THEN
          l_err_loc := 9800;
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Forming the gIFLO tables for favorite_list_id:' || l_favorite_list_id_tbl(i) ||
                '; l_org_id_tbl.COUNT:' || l_org_id_tbl.COUNT);
          END IF;

          l_err_loc := 9900;
          OPEN getOtherFavLinesForHdrCsr(l_favorite_list_id_tbl(i));

          l_err_loc := 10000;
          FETCH getOtherFavLinesForHdrCsr BULK COLLECT INTO
                l_favorite_list_line_id_tbl;

          l_err_loc := 10100;
          CLOSE getOtherFavLinesForHdrCsr;

          l_err_loc := 10200;
          FOR j IN 1..l_favorite_list_line_id_tbl.COUNT LOOP
            l_err_loc := 10300;
            FOR k IN 1..l_org_id_tbl.COUNT LOOP
              l_err_loc := 10400;
              FOR l IN 1..l_language_tbl.COUNT LOOP
                l_err_loc := 10500;
                g_total_row_count := g_total_row_count + 1;
                l_fav_list_lines_index := gIFLOFavoriteListIdTbl.COUNT + 1;
                gIFLOFavoriteListIdTbl(l_fav_list_lines_index) := l_favorite_list_id_tbl(i);
                gIFLOOldFavoriteListLineIdTbl(l_fav_list_lines_index) := l_favorite_list_line_id_tbl(j);
                IF (k=1 AND l=1) THEN
                  l_err_loc := 10600;
                  gIFLONewFavoriteListLineIdTbl(l_fav_list_lines_index) := l_favorite_list_line_id_tbl(j);
                ELSE
                  l_err_loc := 10700;
                  gIFLONewFavoriteListLineIdTbl(l_fav_list_lines_index) := getNextFavListLineIdFromSeq;
                END IF;
                l_err_loc := 10800;
                gIFLOOrgIdTbl(l_fav_list_lines_index) := l_org_id_tbl(k);
                gIFLOLanguageTbl(l_fav_list_lines_index) := l_language_tbl(l);
              END LOOP;
            END LOOP;
          END LOOP;

          l_err_loc := 10900;
          IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
                'Formed the gIFLO tables for favorite_list_id:' || l_favorite_list_id_tbl(i) ||
                '; count of favorite_lines in the hdr:' || l_count_tbl(i) ||
                ', gIFLOFavoriteListIdTbl.COUNT:' || gIFLOFavoriteListIdTbl.COUNT);
          END IF;

          l_err_loc := 11000;
          l_org_id_tbl.DELETE;
          l_org_already_exists := 'N';
        END IF;

        l_err_loc := 11100;
        l_prev_favorite_list_id := l_favorite_list_id_tbl(i);

        l_err_loc := 11200;
        populatePOInterfaceTables('INLOOP');
      END LOOP; -- FOR i IN 1..l_favorite_list_id_tbl.COUNT LOOP

      l_err_loc := 11300;
      EXIT WHEN l_favorite_list_id_tbl.COUNT < ICX_CAT_UTIL_PVT.g_batch_size;
    EXCEPTION
      WHEN ICX_CAT_UTIL_PVT.g_snap_shot_too_old THEN
        l_err_string := ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name)
                        || '-' || l_err_loc
                        || ', Total processeded batches:' || l_batch_count;
        ICX_CAT_UTIL_PVT.logAndCommitSnapShotTooOld(g_pkg_name, l_api_name, l_err_string);
        l_err_loc := 11400;
        CLOSE otherItemUpgradeCsr;
        OPEN otherItemUpgradeCsr(l_profile_option_id);
    END;
  END LOOP; -- CURSOR LOOP otherItemUpgradeCsr

  l_err_loc := 11500;
  FOR j IN 1..gIFLOFavoriteListIdTbl.COUNT LOOP
    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'fav list other lines upgrade values at j :' || j ||
          ', gIFLOFavoriteListIdTbl :' || gIFLOFavoriteListIdTbl(j) ||
          ', gIFLOOldFavoriteListLineIdTbl :' || gIFLOOldFavoriteListLineIdTbl(j) ||
          ', gIFLONewFavoriteListLineIdTbl :' || gIFLONewFavoriteListLineIdTbl(j) ||
          ', gIFLOOrgIdTbl :' || gIFLOOrgIdTbl(j) ||
          ', gIFLOLanguageTbl :' || gIFLOLanguageTbl(j) );
    END IF;
  END LOOP;

  l_err_loc := 11600;
  populatePOInterfaceTables('OUTLOOP');

  l_err_loc := 11700;
  IF (otherItemUpgradeCsr%ISOPEN) THEN
    CLOSE otherItemUpgradeCsr;
  END IF;

  l_err_loc := 11710;
  l_favorite_list_id_tbl.DELETE;
  l_employee_id_tbl.DELETE;
  l_user_id_tbl.DELETE;
  l_profile_option_value_tbl.DELETE;
  l_count_tbl.DELETE;

  l_err_loc := 11800;
  -- Clean up the favorite_list_headers for which there is no lines.
  l_continue := TRUE;
  WHILE l_continue LOOP
    l_err_loc := 11900;
    l_favorite_list_id_tbl.DELETE;
    l_employee_id_tbl.DELETE;

    l_err_loc := 12000;
    DELETE FROM icx_cat_fav_list_headers hdrs
    WHERE NOT EXISTS ( SELECT 'x' FROM icx_cat_fav_list_lines_tlp lines
                       WHERE lines.favorite_list_id = hdrs.favorite_list_id)
    AND ROWNUM <= ICX_CAT_UTIL_PVT.g_batch_size
    RETURNING favorite_list_id, employee_id
    BULK COLLECT INTO l_favorite_list_id_tbl, l_employee_id_tbl;

    l_err_loc := 12100;
    l_row_count := SQL%ROWCOUNT;

    l_err_loc := 12200;
    IF (l_row_count < ICX_CAT_UTIL_PVT.g_batch_size OR
        l_row_count = 0)
    THEN
      l_continue := FALSE;
    END IF;

    l_err_loc := 390;
    IF (l_favorite_list_id_tbl.COUNT > 0) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows deleted from icx_cat_fav_list_headers for which there are no lines:' || l_row_count);
        FOR i IN 1..l_favorite_list_id_tbl.COUNT LOOP
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'l_favorite_list_id_tbl(i):' || l_favorite_list_id_tbl(i) ||
            ', l_employee_id_tbl(i):' || l_employee_id_tbl(i));
        END LOOP;
      END IF;
    END IF;

    l_err_loc := 12300;
    COMMIT;
  END LOOP;

  l_err_loc := 12500;
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
    ICX_CAT_UTIL_PVT.g_job_current_status := ICX_CAT_UTIL_PVT.g_job_failed_status;
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
END upgradeFavoriteListLines;

PROCEDURE createCtxDomainIndex
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'createCtxDomainIndex';
  l_err_loc             PLS_INTEGER;
  l_icx_schema_name     VARCHAR2(30) := NULL;
  l_status              VARCHAR2(8);
  l_domidx_status       VARCHAR2(12);
  l_domidx_opstatus     VARCHAR2(6);
  l_index_exists        NUMBER;
  l_start_date          DATE;
  l_end_date            DATE;
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_err_loc := 200;
  l_icx_schema_name := ICX_CAT_UTIL_PVT.getIcxSchemaName;

  l_err_loc := 300;
  BEGIN
    SELECT 0, status, domidx_status, domidx_opstatus
    INTO   l_index_exists, l_status, l_domidx_status, l_domidx_opstatus
    FROM   all_indexes
    WHERE  index_name = 'ICX_CAT_ITEMSCTXDESC_HDRS'
    AND    owner = l_icx_schema_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_index_exists := -1;
  END;

  l_err_loc := 400;
  IF (l_index_exists = 0 AND
      (l_status <> 'VALID' OR
       l_domidx_status <> 'VALID' OR
       l_domidx_opstatus <> 'VALID'))
  THEN
    l_err_loc := 500;
    -- Call the drop index first
    ICX_CAT_INTERMEDIA_INDEX_PVT.drop_index;

    l_err_loc := 600;
    ICX_CAT_INTERMEDIA_INDEX_PVT.create_index;

    l_err_loc := 700;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Drop and Create indexes called ');
    END IF;
  ELSIF (l_index_exists = -1) THEN
    l_err_loc := 800;
    ICX_CAT_INTERMEDIA_INDEX_PVT.create_index;

    l_err_loc := 900;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'Create index called ');
    END IF;
  END IF;

  l_err_loc := 1000;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
       ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

  l_err_loc := 1100;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    ICX_CAT_UTIL_PVT.g_job_current_status := ICX_CAT_UTIL_PVT.g_job_failed_status;
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
    RAISE_APPLICATION_ERROR (-20000,
       'Exception at ' || G_PKG_NAME ||'.' || l_api_name ||
       '(' || l_err_loc || '), ' || SQLERRM);
END createCtxDomainIndex;

PROCEDURE callICXFinalSteps
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'callICXFinalSteps';
  l_err_loc             PLS_INTEGER;
  l_upgrade_job_number  PLS_INTEGER;
  l_start_date          DATE;
  l_end_date            DATE;
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_err_loc := 200;
  --Initialize the ICX_CAT_UTIL_PVT.g_COMMIT to true.
  --Deciding factor whether to commit or not in ICX_CAT_UTIL_PVT
  ICX_CAT_UTIL_PVT.setCommitParameter(FND_API.G_TRUE);

  l_err_loc := 300;
  -- Set batch_size/commit_size into ICX_CAT_UTIL_PVT.g_batch_size
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 400;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ', AUDSID:' || g_audsid);
  END IF;

  l_err_loc := 500;
  l_upgrade_job_number := ICX_CAT_UTIL_PVT.getR12UpgradeJobNumber;

  l_err_loc := 600;
  -- Set the userId etc..
  -- gUserId is used in created_by which should be -12 to identify the rows created by r12 upgrade
  ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id := ICX_CAT_UTIL_PVT.g_upgrade_user;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id := ICX_CAT_UTIL_PVT.getNextSequenceForWhoColumns;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id := l_upgrade_job_number;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id := l_upgrade_job_number;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id := l_upgrade_job_number;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id := l_upgrade_job_number;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id := l_upgrade_job_number;

  l_err_loc := 700;
  ICX_CAT_UTIL_PVT.g_job_type := ICX_CAT_UTIL_PVT.g_icx_final_upg_program;
  ICX_CAT_UTIL_PVT.g_job_number := l_upgrade_job_number;

  l_err_loc := 800;
  createR12UpgradeJob(g_audsid, null);

  l_err_loc := 900;
  -- Set the base language
  ICX_CAT_UTIL_PVT.setBaseLanguage;

  l_err_loc := 1000;
  callPurgeInvalidBlanketLines;

  l_err_loc := 1200;
  upgradeFavoriteListHdrs;

  l_err_loc := 1300;
  upgradeFavoriteListLines;

  l_err_loc := 1400;
  createCtxDomainIndex;

  l_err_loc := 1500;
  IF (ICX_CAT_UTIL_PVT.g_job_current_status IS NULL) THEN
    ICX_CAT_UTIL_PVT.g_job_current_status := ICX_CAT_UTIL_PVT.g_job_complete_status;
    ICX_CAT_UTIL_PVT.g_job_complete_date := sysdate;
  END IF;

  l_err_loc := 1600;
  updateR12UpgradeJob(ICX_CAT_UTIL_PVT.g_job_current_status);

  l_err_loc := 1700;
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
    ICX_CAT_UTIL_PVT.g_job_current_status := ICX_CAT_UTIL_PVT.g_job_failed_status;
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
    updateR12UpgradeJob(ICX_CAT_UTIL_PVT.g_job_failed_status);
    RAISE_APPLICATION_ERROR (-20000,
       'Exception at ' || G_PKG_NAME ||'.' || l_api_name ||
       '(' || l_err_loc || '), ' || SQLERRM);
END callICXFinalSteps;

-- Appends a number 1, 2, etc to p_key. to find a distinct descriptor key,
-- Returns a key value that is not present as a descriptor key
FUNCTION getDistinctDescKeyFromCAT
(       p_key                   IN      VARCHAR2
)
RETURN VARCHAR2 IS
  l_suffix      PLS_INTEGER := 1;
  l_newKey      VARCHAR2(250);
  l_temp        PLS_INTEGER;
BEGIN
  LOOP
    l_newKey := p_key || l_suffix;
    l_suffix := l_suffix + 1;
    BEGIN
      SELECT 1
      INTO l_temp
      FROM icx_cat_descriptors_tl
      WHERE UPPER(key) = l_newKey;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --The current l_newKey is distinct, return it
        return l_newKey;
    END;
  END LOOP;
END getDistinctDescKeyFromCAT;

PROCEDURE runAttributeUpgrade
IS
  -- Cursor to check if the new descriptors added in R12 already
  -- existed on the customer instance with the same key
  -- New descriptors added in R12:
  -- SOURCE
  -- SHOPPING_CATEGORY
  -- PURCHASING_CATEGORY
  -- ITEM_REVISION
  CURSOR checkIcxCatDescriptorsTlCsr IS
    SELECT rt_descriptor_id, UPPER(key)
    FROM   icx_cat_descriptors_tl
    WHERE  UPPER(key) IN ('SOURCE',
                          'SHOPPING_CATEGORY',
                          'PURCHASING_CATEGORY',
                          'ITEM_REVISION')
    AND    language = source_lang
    AND    rt_descriptor_id > 100;

  -- Cursor to check the searchable for some of the descritpors that can never be made
  -- searchable in R12.
  CURSOR checkSrchbleForSpecAttrsCsr IS
    SELECT attribute_id, key
    FROM   icx_cat_attributes_tl
    WHERE  key IN ('PURCHASING_CATEGORY',
                   'THUMBNAIL_IMAGE',
                   'SUPPLIER_SITE',
                   'PICTURE',
                   'UOM',
                   'PRICE',
                   'CURRENCY',
                   'FUNCTIONAL_PRICE',
                   'FUNCTIONAL_CURRENCY',
                   'ATTACHMENT_URL',
                   'SUPPLIER_URL',
                   'MANUFACTURER_URL')
    AND    searchable = 1
    AND    rt_category_id = 0
    AND    language = ICX_CAT_UTIL_PVT.g_base_language;

  ----- Start of declaring columns selected in the cursor -----
  l_rt_descriptor_id_tbl        DBMS_SQL.NUMBER_TABLE;
  l_attribute_id_tbl            DBMS_SQL.NUMBER_TABLE;
  l_key_tbl                     DBMS_SQL.VARCHAR2_TABLE;
  ------ End of declaring columns selected in the cursor ------

  -- variables for update
  l_upd_index                   PLS_INTEGER;
  l_upd_rt_descriptor_id_tbl    DBMS_SQL.NUMBER_TABLE;
  l_upd_key_tbl                 DBMS_SQL.VARCHAR2_TABLE;
  l_new_key                     VARCHAR2(250);

  l_api_name                    CONSTANT VARCHAR2(30)   := 'runAttributeUpgrade';
  l_err_loc                     PLS_INTEGER;
  l_is_attr_already_upgraded    NUMBER;
BEGIN
  l_err_loc := 100;
  BEGIN
    SELECT 1
    INTO   l_is_attr_already_upgraded
    FROM   dual
    WHERE  EXISTS (SELECT 'attribute records'
                   FROM   icx_cat_attributes_tl
                   WHERE  attribute_id > 100);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_is_attr_already_upgraded := -1;
  END;

  l_err_loc := 200;
  OPEN checkIcxCatDescriptorsTlCsr;

  l_err_loc := 1100;
  l_rt_descriptor_id_tbl.DELETE;
  l_key_tbl.DELETE;
  FETCH checkIcxCatDescriptorsTlCsr BULK COLLECT INTO l_rt_descriptor_id_tbl, l_key_tbl;

  l_err_loc := 1200;
  CLOSE checkIcxCatDescriptorsTlCsr;

  l_err_loc := 1300;
  FOR i IN 1..l_rt_descriptor_id_tbl.COUNT LOOP
    l_new_key := NULL;
    l_err_loc := 1400;
    l_new_key := getDistinctDescKeyFromCAT(l_key_tbl(i));
    IF (l_new_key IS NOT NULL) THEN
      l_err_loc := 1500;
      l_upd_index := l_upd_rt_descriptor_id_tbl.COUNT + 1;
      l_upd_rt_descriptor_id_tbl(l_upd_index) := l_rt_descriptor_id_tbl(i);
      l_upd_key_tbl(l_upd_index) := l_new_key;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            'changing descriptor key from:' || l_key_tbl(i) ||
            ', to :' || l_new_key || ' in icx_cat_descriptors_tl for rt_descriptor_id :' ||
            l_rt_descriptor_id_tbl(i));
      END IF;
    END IF;
  END LOOP;

  l_err_loc := 1600;
  FORALL i IN 1..l_upd_rt_descriptor_id_tbl.COUNT
    UPDATE icx_cat_descriptors_tl
    SET    key = l_upd_key_tbl(i)
    WHERE  rt_descriptor_id = l_upd_rt_descriptor_id_tbl(i);

  l_err_loc := 1700;
  COMMIT;

  INSERT INTO icx_cat_attributes_tl
  (
    attribute_id, language, source_lang,
    attribute_name, description, rt_category_id, type,
    sequence, key,
    searchable, search_results_visible, item_detail_visible,
    created_by, creation_date,
    last_updated_by, last_update_login, last_update_date,
    request_id, program_application_id, program_id,
    rebuild_flag, section_tag,
    stored_in_table, stored_in_column
  )
  (
  SELECT
    des1.rt_descriptor_id, des1.language, des1.source_lang,
    des1.descriptor_name, des1.description, des1.rt_category_id, des1.type,
    des1.sequence, des1.key,
    des1.searchable, des1.search_results_visible, des1.item_detail_visible,
    des1.created_by, des1.creation_date,
    des1.last_updated_by, des1.last_update_login, des1.last_update_date,
    des1.batch_job_num, des1.program_application_id, des1.program_id,
    des1.rebuild_flag, des1.section_tag,
    DECODE(des1.type, 2, 'PO_ATTRIBUTE_VALUES_TLP', 'PO_ATTRIBUTE_VALUES'),
    des1.stored_in_column
  FROM
    icx_cat_descriptors_tl des1
  WHERE des1.rt_descriptor_id > 100
  AND NOT EXISTS (SELECT NULL FROM icx_cat_attributes_tl des2
                  WHERE des1.rt_descriptor_id = des2.attribute_id
                  AND   des1.language = des2.language)
  );

  l_err_loc := 300;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'No: of rows inserted into icx_cat_attributes_tl during upgrade:' || SQL%ROWCOUNT);
  END IF;

  IF (l_is_attr_already_upgraded = -1) THEN
    l_err_loc := 400;
    OPEN checkSrchbleForSpecAttrsCsr;

    l_err_loc := 500;
    l_attribute_id_tbl.DELETE;
    l_key_tbl.DELETE;
    FETCH checkSrchbleForSpecAttrsCsr BULK COLLECT INTO l_attribute_id_tbl, l_key_tbl;

    l_err_loc := 600;
    CLOSE checkSrchbleForSpecAttrsCsr;

    l_err_loc := 700;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FOR i IN 1..l_attribute_id_tbl.COUNT LOOP
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            ' Attribute key:' || l_key_tbl(i) || ', will be made non-searchable');
      END LOOP;
    END IF;

    l_err_loc := 800;
    FORALL i IN 1..l_attribute_id_tbl.COUNT
      UPDATE icx_cat_attributes_tl
      SET    searchable = 0
      WHERE  attribute_id = l_attribute_id_tbl(i);

    l_err_loc := 850;
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
          ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
          'No: of rows updated with searchable=0 in icx_cat_attributes_tl during upgrade:' || SQL%ROWCOUNT);
    END IF;
  END IF;

  l_err_loc := 900;
  COMMIT;

  l_err_loc := 1000;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
END runAttributeUpgrade;

PROCEDURE initializeGlobalVariables
(       p_current_program       IN      VARCHAR2
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'initializeGlobalVariables';
  l_err_loc             PLS_INTEGER;
  l_upgrade_job_number  PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  --Initialize the ICX_CAT_UTIL_PVT.g_COMMIT to true.
  --Deciding factor whether to commit or not in ICX_CAT_UTIL_PVT
  ICX_CAT_UTIL_PVT.setCommitParameter(FND_API.G_TRUE);

  l_err_loc := 200;
  -- Set batch_size/commit_size into ICX_CAT_UTIL_PVT.g_batch_size
  ICX_CAT_UTIL_PVT.setBatchSize;

  l_err_loc := 300;
  -- Get the next batch_id for PDOI
  -- Get it from the po_headers_interface
  -- Cannot use the API PO_PDOI_UTL.get_next_batch_id because
  -- this is not available in 11.5.9 and 11.5.10
  SELECT NVL(MAX(batch_id), 0) + 1
  INTO g_PDOI_batch_id
  FROM po_headers_interface;

  l_err_loc := 400;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'PDOI Batch Id:' || g_PDOI_batch_id ||
        ', p_current_program:' || p_current_program ||
        ', AUDSID:' || g_audsid);
  END IF;

  l_err_loc := 500;
  -- Deciding factor to whether call callPOMigrateCatalog in validate_only_mode or not.
  ICX_CAT_UTIL_PVT.g_current_program := p_current_program;

  l_err_loc := 600;
  -- Set the userId etc..
  -- gUserId is used in created_by which should be -12 to identify the rows created by r12 upgrade
  ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id := ICX_CAT_UTIL_PVT.g_upgrade_user;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id := ICX_CAT_UTIL_PVT.getNextSequenceForWhoColumns;

  l_err_loc := 700;
  IF (p_current_program = ICX_CAT_UTIL_PVT.g_upgrade_program) THEN
    -- R12 upgrade call
    l_upgrade_job_number := ICX_CAT_UTIL_PVT.getR12UpgradeJobNumber;

    l_err_loc := 900;
    ICX_CAT_UTIL_PVT.g_job_type := ICX_CAT_UTIL_PVT.g_upgrade_program;
    ICX_CAT_UTIL_PVT.g_job_number := l_upgrade_job_number;

    l_err_loc := 1000;
    -- Set the who columns also
    ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id := l_upgrade_job_number;
    ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id := l_upgrade_job_number;
    ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id := l_upgrade_job_number;
    ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id := l_upgrade_job_number;
    ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id := l_upgrade_job_number;

    l_err_loc := 1100;
    createR12UpgradeJob(g_audsid, g_pdoi_batch_id);
  ELSE
    l_err_loc := 1200;
    -- Pre-upgrade / Data-exceptions call.
    ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id := fnd_global.login_id;
    ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id := fnd_global.conc_request_id;
    ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id := fnd_global.prog_appl_id;
    ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id := fnd_global.conc_program_id;
    ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id := fnd_global.conc_login_id;

    l_err_loc := 1300;
    IF (p_current_program = ICX_CAT_UTIL_PVT.g_pre_upgrade_program) THEN
      ICX_CAT_UTIL_PVT.g_job_type := ICX_CAT_UTIL_PVT.g_pre_upgrade_program;
      ICX_CAT_UTIL_PVT.g_job_number := fnd_global.conc_request_id;
    ELSIF (p_current_program = ICX_CAT_UTIL_PVT.g_data_exception_program) THEN
      l_err_loc := 1400;
      ICX_CAT_UTIL_PVT.g_job_type := ICX_CAT_UTIL_PVT.g_data_exception_program;
      ICX_CAT_UTIL_PVT.g_job_number := fnd_global.conc_request_id;
    END IF;
  END IF;

  l_err_loc := 1500;
  -- Get the last pre-upgrade completed dates
  SELECT NVL(MAX(PREUPG_PDOI_COMPLETE_DATE), NULL) extract_last_run_date,
         NVL(MAX(preupg_pdoi_update_date), NULL) bulk_last_run_date,
         NVL(MAX(preupg_bpa_complete_date), NULL) bpa_last_run_date,
         NVL(MAX(preupg_quote_complete_date), NULL) quote_last_run_date,
         NVL(MAX(preupg_reqtmplt_complete_date), NULL) reqtmplt_last_run_date,
         NVL(MAX(preupg_mi_complete_date), NULL) mi_last_run_date
  INTO   g_extract_last_run_date,
         g_bulk_last_run_date,
         g_bpa_last_run_date,
         g_quote_last_run_date,
         g_reqtmplt_last_run_date,
         g_mi_last_run_date
  FROM   icx_cat_r12_upgrade_jobs
  -- Check within jobs that are not data exception
  -- OR child data exception process ( which will be submitted from pre-upgrade program)
  WHERE  job_type NOT IN (ICX_CAT_UTIL_PVT.g_data_exception_program,
                          ICX_CAT_UTIL_PVT.g_child_data_excptn_program);

  l_err_loc := 1700;
  -- Update the current job to running status
  updateR12UpgradeJob(ICX_CAT_UTIL_PVT.g_job_running_status);

  l_err_loc := 1800;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Upgrade last successful completion dates:' ||
        ', g_extract_last_run_date: ' || g_extract_last_run_date ||
        ', g_bulk_last_run_date: ' || g_bulk_last_run_date ||
        ', g_bpa_last_run_date: ' || g_bpa_last_run_date ||
        ', g_quote_last_run_date: ' || g_quote_last_run_date ||
        ', g_reqtmplt_last_run_date: ' || g_reqtmplt_last_run_date ||
        ', g_mi_last_run_date: ' || g_mi_last_run_date  );
  END IF;

  l_err_loc := 1900;
  -- Set the base language
  ICX_CAT_UTIL_PVT.setBaseLanguage;

  l_err_loc := 2000;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    raise;
END initializeGlobalVariables;

PROCEDURE commonAPICallsFromUpgAndPreUpg
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'commonAPICallsFromUpgAndPreUpg';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  runAttributeUpgrade;

  l_err_loc := 300;
  moveExtItemsBaseAndLocalAttr;

  l_err_loc := 400;
  migrateBulkloadItems;

  l_err_loc := 500;
  -- Call the PDOI API.
  callPOMigrateCatalog;

  l_err_loc := 600;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE;
END commonAPICallsFromUpgAndPreUpg;

PROCEDURE submitDataExceptionsRequest
(       is_sub_request          IN              BOOLEAN ,
        p_data_exception_job    OUT NOCOPY      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'submitDataExceptionsRequest';
  l_err_loc             PLS_INTEGER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
  l_counter             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_err_loc := 150;
  l_counter := 0;
  WHILE (TRUE) LOOP
    l_counter := l_counter + 1;
    l_err_loc := 200;
    p_data_exception_job := fnd_request.submit_request
       (
        'ICX',                                                  -- application
        'ICXCUCDER',                                            -- program
        -- ICX_CAT_R12_UPGRADE_PVT.runDataExcptnRptChildProcess;
        null,                                                   -- description
        NULL,                                                   -- start_time
        is_sub_request,                                         -- sub_request (TRUE from pre-upgrade, FALSE from upgrade)
        ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id, -- p_parent_int_req_id
        ICX_CAT_UTIL_PVT.g_batch_size,                          -- p_batch_size
        FND_API.G_TRUE,                                         -- p_commit
        g_PDOI_batch_id                                         -- p_pdoi_batch_id
       );
    IF (p_data_exception_job > 0) THEN
      l_err_loc := 300;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            ', Child 1, Data Exceptions job submitted; request_id :' ||
            p_data_exception_job);
      END IF;
      EXIT;
    ELSIF (l_counter > 3) THEN
      l_err_loc := 400;
      p_data_exception_job := 0;
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
            ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
            ', Child 1, Data Exceptions job not submitted; So submitting' ||
            ' it as a serial process.  About to call callICXProcessDataExcptnRpt');
      END IF;
      l_err_loc := 450;
      callICXProcessDataExcptnRpt;
      EXIT;
    END IF;
  END LOOP;

  l_err_loc := 500;
  l_end_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

  l_err_loc := 600;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
END submitDataExceptionsRequest;

PROCEDURE upgradeDefaultSortProfiles
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'upgradeDefaultSortProfiles';
  l_relevance_profile_value     VARCHAR2(1) := 'N';
  l_application_id              NUMBER;
  l_profile_option_id           NUMBER;
  l_err_loc                     PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  BEGIN
    SELECT fpov.profile_option_value
    INTO l_relevance_profile_value
    FROM fnd_profile_options fpo, fnd_profile_option_values fpov
    WHERE fpo.profile_option_name = 'POR_SORT_BY_RELEVANCE'
    AND fpo.profile_option_id = fpov.profile_option_id
    AND fpov.level_id = 10001;

    l_err_loc := 200;
  EXCEPTION
    WHEN no_data_found THEN
    -- no row is found, that means the relevance profile value is not set
    null;

  END;

  l_err_loc := 250;
  -- insert rows to fnd_profile_option_values only if the relevance profile value is 'Y'
  IF (l_relevance_profile_value = 'Y') THEN
    l_err_loc := 300;
    SELECT application_id, profile_option_id
    INTO l_application_id, l_profile_option_id
    FROM fnd_profile_options
    WHERE profile_option_name = 'POR_DEFAULT_SHOPPING_SORT';

    l_err_loc := 350;
    -- insert only if row doesn't exist
    INSERT INTO fnd_profile_option_values
      (application_id, profile_option_id, level_id, level_value, last_update_date,
      last_updated_by, creation_date, created_by, last_update_login, profile_option_value)
    SELECT l_application_id, l_profile_option_id, 10001, 0, sysdate, fnd_global.user_id,
      sysdate, fnd_global.user_id, fnd_global.login_id, 'Relevance'
    FROM dual
    WHERE NOT EXISTS (SELECT 1
                      FROM fnd_profile_option_values
                      WHERE application_id = l_application_id
                      AND profile_option_id = l_profile_option_id
                      AND level_id = 10001
                      AND level_value = 0);

    l_err_loc := 400;
    SELECT application_id, profile_option_id
    INTO l_application_id, l_profile_option_id
    FROM fnd_profile_options
    WHERE profile_option_name = 'POR_DEFAULT_SHOPPING_SORT_ORDER';

    l_err_loc := 450;
    -- insert only if row doesn't exist
    INSERT INTO fnd_profile_option_values
      (application_id, profile_option_id, level_id, level_value, last_update_date,
      last_updated_by, creation_date, created_by, last_update_login, profile_option_value)
    SELECT l_application_id, l_profile_option_id, 10001, 0, sysdate, fnd_global.user_id,
      sysdate, fnd_global.user_id, fnd_global.login_id, 'DESC'
    FROM dual
    WHERE NOT EXISTS (SELECT 1
                      FROM fnd_profile_option_values
                      WHERE application_id = l_application_id
                      AND profile_option_id = l_profile_option_id
                      AND level_id = 10001
                      AND level_value = 0);

    l_err_loc := 500;
  END IF;

  l_err_loc := 550;
  COMMIT;

  l_err_loc := 600;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    RAISE_APPLICATION_ERROR (-20000,
       'Exception at ' || G_PKG_NAME ||'.' || l_api_name ||
       '(' || l_err_loc || '), ' || SQLERRM);
END upgradeDefaultSortProfiles;

PROCEDURE runR12Upgrade
(       x_errbuf        OUT NOCOPY      VARCHAR2                                ,
        x_retcode       OUT NOCOPY      NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'runR12Upgrade';
  l_err_loc             PLS_INTEGER;
  l_data_exception_job  NUMBER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
BEGIN
  l_err_loc := 100;
  x_retcode := 0;
  x_errbuf := '';

  l_err_loc := 200;
  l_start_date := sysdate;

  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') );
  END IF;

  l_err_loc := 300;
  initializeGlobalVariables(ICX_CAT_UTIL_PVT.g_upgrade_program);

  l_err_loc := 400;
  commonAPICallsFromUpgAndPreUpg;

  l_err_loc := 500;
  -- During upgrade running through adpatch, we are just submitting a concurrent program
  -- for data exceptions.  This job will be picked up when the system comes back up.
  -- During patching, before submitting the job,
  -- set the fnd_conc_maintain.apps_initialize_for_mgr
  fnd_conc_maintain.apps_initialize_for_mgr;

  l_err_loc := 600;
  submitDataExceptionsRequest(FALSE, l_data_exception_job);

  l_err_loc := 1200;
  IF (ICX_CAT_UTIL_PVT.g_job_current_status IS NULL) THEN
    ICX_CAT_UTIL_PVT.g_job_current_status := ICX_CAT_UTIL_PVT.g_job_complete_status;
    ICX_CAT_UTIL_PVT.g_job_complete_date := sysdate;
  END IF;

  l_err_loc := 1300;
  updateR12UpgradeJob(ICX_CAT_UTIL_PVT.g_job_current_status);

  l_err_loc := 1400;
  l_end_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' done in:' || ICX_CAT_UTIL_PVT.getTimeStats(l_start_date, l_end_date));
  END IF;

  l_err_loc := 1500;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    ROLLBACK;
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
    updateR12UpgradeJob(ICX_CAT_UTIL_PVT.g_job_failed_status);
    x_retcode := 2;
    x_errbuf := 'Exception at ' ||
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name) ||
                '(l_err_loc:' || l_err_loc || '), ' || SQLERRM;
    raise;
END runR12Upgrade;

PROCEDURE runDataExcptnRptChildProcess
(       x_errbuf                OUT NOCOPY      VARCHAR2        ,
        x_retcode               OUT NOCOPY      NUMBER          ,
        p_parent_int_req_id     IN              NUMBER          ,
        p_batch_size            IN              NUMBER          ,
        p_commit                IN              VARCHAR2        ,
        p_pdoi_batch_id         IN              NUMBER
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'runDataExcptnRptChildProcess';
  l_err_loc             PLS_INTEGER;
  l_start_date          DATE;
  l_end_date            DATE;
  l_log_string		VARCHAR2(2000);
  l_audsid              NUMBER                  := USERENV('SESSIONID');
BEGIN
  l_err_loc := 100;
  l_start_date := sysdate;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        'Started at:' || TO_CHAR(l_start_date, 'DD-MON-YYYY HH24:MI:SS') ||
        ', audsid:' || l_audsid ||
        'Parameters: p_parent_int_req_id:' || p_parent_int_req_id ||
        ' p_batch_size:' || p_batch_size ||
        ' p_commit:' || p_commit ||
        ' p_pdoi_batch_id:' || p_pdoi_batch_id);
  END IF;

  l_err_loc := 200;
  ICX_CAT_UTIL_PVT.g_batch_size := p_batch_size;

  l_err_loc := 300;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id := ICX_CAT_UTIL_PVT.g_upgrade_user;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id := p_parent_int_req_id;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id := fnd_global.login_id;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id := fnd_global.conc_request_id;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id := fnd_global.prog_appl_id;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id := fnd_global.conc_program_id;
  ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id := fnd_global.conc_login_id;

  l_err_loc := 400;
  -- Set the global commit parameter
  ICX_CAT_UTIL_PVT.setCommitParameter(p_commit);

  l_err_loc := 500;
  ICX_CAT_UTIL_PVT.g_job_type := ICX_CAT_UTIL_PVT.g_child_data_excptn_program;
  ICX_CAT_UTIL_PVT.g_job_number := ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id;

  l_err_loc := 600;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        ' g_job_type:' || ICX_CAT_UTIL_PVT.g_job_type ||
        ' g_job_number:' || ICX_CAT_UTIL_PVT.g_job_number);
  END IF;

  l_err_loc := 700;
  createR12UpgradeJob(l_audsid, p_pdoi_batch_id);

  -- Call the ICX API to process the data exception report for the
  -- lines rejected during poMigrateCatalog with errors.
  l_err_loc := 800;
  ICX_CAT_R12_DATA_EXCEP_RPT_PVT.process_data_exceptions_report(p_pdoi_batch_id);

  l_err_loc := 900;
  ICX_CAT_UTIL_PVT.g_job_complete_date := SYSDATE;
  ICX_CAT_R12_UPGRADE_PVT.updateR12UpgradeJob(ICX_CAT_UTIL_PVT.g_job_complete_status);

  l_err_loc := 1000;
  x_retcode := 0;
  x_errbuf := l_api_name ||' done';

  l_err_loc := 1100;
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
    ROLLBACK;
    ICX_CAT_UTIL_PVT.g_job_complete_date := NULL;
    updateR12UpgradeJob(ICX_CAT_UTIL_PVT.g_job_failed_status);
    x_retcode := 2;
    x_errbuf := 'Exception at ' ||
                ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name) ||
                '(l_err_loc:' || l_err_loc || '), ' || SQLERRM;
END runDataExcptnRptChildProcess;

PROCEDURE createR12UpgradeJob
(       p_audsid                IN      NUMBER                  ,
        p_pdoi_batch_id         IN      NUMBER DEFAULT NULL
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'createR12UpgradeJob';
  l_err_loc             PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  INSERT INTO icx_cat_r12_upgrade_jobs
   (job_type, job_number, status, run_date, audsid, pdoi_batch_id,
    last_update_login, last_updated_by, last_update_date,
    created_by, creation_date, internal_request_id, request_id,
    program_application_id, program_id, program_login_id)
   SELECT ICX_CAT_UTIL_PVT.g_job_type, ICX_CAT_UTIL_PVT.g_job_number,
          ICX_CAT_UTIL_PVT.g_job_running_status, sysdate, p_audsid, p_pdoi_batch_id,
          ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
          ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id, sysdate,
          ICX_CAT_UTIL_PVT.g_who_columns_rec.user_id, sysdate,
          ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
          ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
          ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
          ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
          ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id
   FROM DUAL
   WHERE NOT EXISTS (SELECT 'x' FROM icx_cat_r12_upgrade_jobs
                     WHERE  job_type = ICX_CAT_UTIL_PVT.g_job_type
                     AND    job_number = ICX_CAT_UTIL_PVT.g_job_number );

  l_err_loc := 200;
  COMMIT;

  l_err_loc := 300;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
    raise;
END createR12UpgradeJob;

PROCEDURE updateR12UpgradeJob
(       p_job_status    IN      VARCHAR2                ,
        p_audsid2       IN      NUMBER DEFAULT NULL
)
IS
  l_api_name            CONSTANT VARCHAR2(30)   := 'updateR12UpgradeJob';
  l_err_loc             PLS_INTEGER;
  l_row_count           PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  IF ( p_job_status = ICX_CAT_UTIL_PVT.g_job_running_status) THEN
    UPDATE icx_cat_r12_upgrade_jobs
    SET status = p_job_status,
        audsid = g_audsid,
        pdoi_batch_id = g_PDOI_batch_id,
        last_update_login = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
        last_updated_by = ICX_CAT_UTIL_PVT.g_who_columns_rec.login_id,
        last_update_date = sysdate,
        internal_request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.internal_request_id,
        request_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.request_id,
        program_application_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_application_id,
        program_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_id,
        program_login_id = ICX_CAT_UTIL_PVT.g_who_columns_rec.program_login_id
    WHERE job_type = ICX_CAT_UTIL_PVT.g_job_type
    AND job_number = ICX_CAT_UTIL_PVT.g_job_number;
  ELSIF ( p_job_status = ICX_CAT_UTIL_PVT.g_job_paused_status) THEN
    -- i.e. paused status, when run as parent
    -- we need to update the pdoi_update_date and pdoi_complete_date
    -- because when the parent is re-started, it is re-started in a
    -- new session and these global varaibles are lost
    l_err_loc := 200;
    UPDATE icx_cat_r12_upgrade_jobs
    SET preupg_pdoi_update_date = ICX_CAT_UTIL_PVT.g_job_pdoi_update_date,
        preupg_pdoi_complete_date = ICX_CAT_UTIL_PVT.g_job_pdoi_complete_date
    WHERE job_type = ICX_CAT_UTIL_PVT.g_job_type
    AND job_number = ICX_CAT_UTIL_PVT.g_job_number;
  ELSE
    -- i.e. completed / failed status
    l_err_loc := 300;
    UPDATE icx_cat_r12_upgrade_jobs
    SET status = p_job_status,
        audsid2 = p_audsid2,
        preupg_complete_date = ICX_CAT_UTIL_PVT.g_job_complete_date,
        preupg_pdoi_update_date = NVL(ICX_CAT_UTIL_PVT.g_job_pdoi_update_date, preupg_pdoi_update_date),
        preupg_pdoi_complete_date = NVL(ICX_CAT_UTIL_PVT.g_job_pdoi_complete_date, preupg_pdoi_complete_date),
        preupg_bpa_complete_date = ICX_CAT_UTIL_PVT.g_job_bpa_complete_date,
        preupg_quote_complete_date = ICX_CAT_UTIL_PVT.g_job_quote_complete_date,
        preupg_reqtmplt_complete_date = ICX_CAT_UTIL_PVT.g_job_reqtmplt_complete_date,
        preupg_mi_complete_date = ICX_CAT_UTIL_PVT.g_job_mi_complete_date
    WHERE job_type = ICX_CAT_UTIL_PVT.g_job_type
    AND job_number = ICX_CAT_UTIL_PVT.g_job_number;
  END IF;

  l_err_loc := 400;
  l_row_count := SQL%ROWCOUNT;

  l_err_loc := 500;
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED,
        ICX_CAT_UTIL_PVT.getModuleNameForDebug(g_pkg_name, l_api_name),
        '; No: of rows updated in icx_cat_r12_upgrade_jobs:' || l_row_count);
  END IF;

  l_err_loc := 600;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ICX_CAT_UTIL_PVT.logUnexpectedException(
      G_PKG_NAME, l_api_name,
      ' --> l_err_loc:' ||l_err_loc ||' '|| SQLERRM);
END updateR12UpgradeJob;

END ICX_CAT_R12_UPGRADE_PVT;

/
