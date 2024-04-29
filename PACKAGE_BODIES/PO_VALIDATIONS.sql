--------------------------------------------------------
--  DDL for Package Body PO_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VALIDATIONS" AS
-- $Header: PO_VALIDATIONS.plb 120.78.12010000.58 2014/12/02 13:58:04 gjyothi ship $

---------------------------------------------------------------------------
-- Modules for debugging.
---------------------------------------------------------------------------

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_VALIDATIONS');

-- The module base for the subprogram.
D_next_result_set_id CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'next_result_set_id');

-- The module base for the subprogram.
D_commit_validation_results_au CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'commit_validation_results_auto');

-- The module base for the subprogram.
D_update_result_set CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'update_result_set');

-- The module base for the subprogram.
D_commit_result_set CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'commit_result_set');

-- The module base for the subprogram.
D_validate_set CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'validate_set');

-- The module base for the subprogram.
D_result_type_rank CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'result_type_rank');

-- The module base for the subprogram.
D_delete_result_set_auto CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'delete_result_set_auto');

-- The module base for the subprogram.
D_delete_result_set CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'delete_result_set');

-- The module base for the subprogram.
D_replace_result_set_id CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'replace_result_set_id');

-- The module base for the subprogram.
D_insert_result CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'insert_result');

-- The module base for the subprogram.
D_validate_unit_price_change CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'validate_unit_price_change');

-- <<PDOI Enhancement Bug#17063664>>
-- The module base for the subprogram.
D_validate_cross_ou_purchasing CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'validate_cross_ou_purchasing');

-- The module base for the subprogram.
D_validate_html_order CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'validate_html_order');
D_validate_html_agreement CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'validate_html_agreement');
D_validate_pdoi CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'validate_pdoi');

D_check_encumbered_amount CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'check_encumbered_amount');

--<PDOI Enhancement Bug#17063664>
D_validate_source_doc CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'validate_source_doc');

D_validate_req_reference CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'validate_req_reference');

-- Indicates that the calling program is the OA HTML UI.
c_program_OA CONSTANT VARCHAR2(10) := 'OA';

-- Indicates that the calling program is PDOI.
c_program_PDOI CONSTANT VARCHAR2(10) := 'PDOI';

-- The application name of PO.
c_PO CONSTANT VARCHAR2(2) := 'PO';

c_parameter_YES CONSTANT VARCHAR2(1) := PO_CORE_S.g_parameter_YES;
c_parameter_NO CONSTANT VARCHAR2(1) := PO_CORE_S.g_parameter_NO;

c_doc_type_blanket   CONSTANT VARCHAR2(30) := 'BLANKET';
c_doc_type_standard  CONSTANT VARCHAR2(30) := 'STANDARD';
c_doc_type_quotation CONSTANT VARCHAR2(30) := 'QUOTATION';

--<PDOI Enhancement Bug#17063664>
c_doc_type_contract   CONSTANT VARCHAR2(30) := 'CONTRACT';



/**
  Used to rank result types, for summary results and other purposes.
  For example, if one result is WARNING and the other is FAILURE,
  then the overall result should be FAILURE.  This is indicated
  by the fact that FAILURE has a lower index in this list than WARNING.
*/
c_result_type_rank_tbl CONSTANT PO_TBL_VARCHAR30 :=
  PO_TBL_VARCHAR30(
    c_result_type_FATAL
  , c_result_type_FAILURE
  , c_result_type_WARNING
  , c_result_type_SUCCESS
  );

--------------------------------------------------------------
-- Validation Subroutine Constants
--------------------------------------------------------------

--------------------------------------------------------------------------
-- Header Validation Constants
--------------------------------------------------------------------------
-- Common
c_warn_supplier_on_hold CONSTANT VARCHAR2(30) := 'C_WARN_SUPPLIER_ON_HOLD';
c_rate_gt_zero CONSTANT VARCHAR2(30) := 'C_RATE_GT_ZERO';
c_fax_email_address_valid CONSTANT VARCHAR2(30) := 'C_FAX_EMAIL_ADDRESS_VALID';
c_rate_combination_valid CONSTANT VARCHAR2(30) := 'C_RATE_COMBINATION_VALID';
c_doc_num_chars_valid CONSTANT VARCHAR2(30) := 'C_DOC_NUM_CHARS_VALID';
c_doc_num_unique CONSTANT VARCHAR2(30) := 'C_DOC_NUM_UNIQUE';
c_agent_id_not_null CONSTANT VARCHAR2(30) := 'C_AGENT_ID_NOT_NULL';
c_hdr_ship_to_loc_not_null CONSTANT VARCHAR2(30) := 'C_HDR_SHIP_TO_LOC_NOT_NULL';
c_segment1_not_null CONSTANT VARCHAR2(30) := 'C_SEGMENT1_NOT_NULL';
c_ship_via_lookup_code_valid CONSTANT VARCHAR2(30) := 'C_SHIP_VIA_LOOKUP_CODE_VALID'; --Bug 9213424
-- Agreements
c_price_update_tol_ge_zero CONSTANT VARCHAR2(30) := 'C_PRICE_UPDATE_TOL_GE_ZERO';
c_amount_limit_ge_zero CONSTANT VARCHAR2(30) := 'C_AMOUNT_LIMIT_GE_ZERO';
c_amt_limit_ge_amt_agreed CONSTANT VARCHAR2(30) := 'C_AMT_LIMIT_GE_AMT_AGREED';
c_amount_agreed_ge_zero CONSTANT VARCHAR2(30) := 'C_AMOUNT_AGREED_GE_ZERO';
c_amount_agreed_not_null CONSTANT VARCHAR2(30) := 'C_AMOUNT_AGREED_NOT_NULL';
c_effective_le_expiration CONSTANT VARCHAR2(30) := 'C_EFFECTIVE_LE_EXPIRATION';
c_effective_from_le_order_date CONSTANT VARCHAR2(30) := 'C_EFFECTIVE_FROM_LE_ORDER_DATE';
c_effective_to_ge_order_date CONSTANT VARCHAR2(30) := 'C_EFFECTIVE_TO_GE_ORDER_DATE';
c_vendor_id_not_null CONSTANT VARCHAR2(30) := 'C_VENDOR_ID_NOT_NULL';
c_vendor_site_id_not_null CONSTANT VARCHAR2(30) := 'C_VENDOR_SITE_ID_NOT_NULL';
-- Contracts
c_contract_start_le_order_date CONSTANT VARCHAR2(30) := 'C_CONTRACT_START_LE_ORDER_DATE';
c_contract_end_ge_order_date CONSTANT VARCHAR2(30) := 'C_CONTRACT_END_GE_ORDER_DATE';

  --------------------------------------------------------------
  -- PDOI Header Validation Subroutine Constants
  --------------------------------------------------------------
  c_po_header_id CONSTANT VARCHAR2(30) := 'C_PO_HEADER_ID';
  c_end_date CONSTANT VARCHAR2(30) := 'C_END_DATE';
  c_type_lookup_code CONSTANT VARCHAR2(30) := 'C_TYPE_LOOKUP_CODE';
  c_revision_num CONSTANT VARCHAR2(30) := 'C_REVISION_NUM';
  c_document_num CONSTANT VARCHAR2(30) := 'C_DOCUMENT_NUM';
  c_currency_code CONSTANT VARCHAR2(30) := 'C_CURRENCY_CODE';
  c_rate_info CONSTANT VARCHAR2(30) := 'C_RATE_INFO';
  c_agent_id CONSTANT VARCHAR2(30) := 'C_AGENT_ID';
  c_vendor_info CONSTANT VARCHAR2(30) := 'C_VENDOR_INFO';
  c_ship_to_location_id CONSTANT VARCHAR2(30) := 'C_SHIP_TO_LOCATION_ID';
  c_bill_to_location_id CONSTANT VARCHAR2(30) := 'C_BILL_TO_LOCATION_ID';
  c_last_updated_by CONSTANT VARCHAR2(30) := 'C_LAST_UPDATED_BY';
  c_last_update_date CONSTANT VARCHAR2(30) := 'C_LAST_UPDATE_DATE';
  c_release_num CONSTANT VARCHAR2(30) := 'C_RELEASE_NUM';
  c_po_release_id CONSTANT VARCHAR2(30) := 'C_PO_RELEASE_ID';
  c_release_date CONSTANT VARCHAR2(30) := 'C_RELEASE_DATE';
  c_revised_date CONSTANT VARCHAR2(30) := 'C_REVISED_DATE';
  c_printed_date CONSTANT VARCHAR2(30) := 'C_PRINTED_DATE';
  c_closed_date CONSTANT VARCHAR2(30) := 'C_CLOSED_DATE';
  c_terms_id_header CONSTANT VARCHAR2(30) := 'C_TERMS_ID_HEADERS';
  c_ship_via_lookup_code CONSTANT VARCHAR2(30) := 'C_SHIP_VIA_LOOKUP_CODE';
  c_fob_lookup_code CONSTANT VARCHAR2(30) := 'C_FOB_LOOKUP_CODE';
  c_freight_terms_lookup_code CONSTANT VARCHAR2(30) := 'C_FREIGHT_TERMS_LOOKUP_CODE';
  c_shipping_control CONSTANT VARCHAR2(30) := 'C_SHIPPING_CONTROL';
  c_approval_status CONSTANT VARCHAR2(30) := 'C_APPROVAL_STATUS';
  c_acceptance_required_flag CONSTANT VARCHAR2(30) := 'C_ACCEPTANCE_REQUIRED_FLAG';
  c_confirming_order_flag CONSTANT VARCHAR2(30) := 'C_CONFIRMING_ORDER_FLAG';
  c_acceptance_due_date CONSTANT VARCHAR2(30) := 'C_ACCEPTANCE_DUE_DATE';
  c_amount_agreed CONSTANT VARCHAR2(30) := 'C_AMOUNT_AGREED';
  c_firm_status_lookup_header CONSTANT VARCHAR2(30) := 'C_FIRM_STATUS_LOOKUP_HEADER';
  c_cancel_flag CONSTANT VARCHAR2(30) := 'C_CANCEL_FLAG';
  c_closed_code CONSTANT VARCHAR2(30) := 'C_CLOSED_CODE';
  c_print_count CONSTANT VARCHAR2(30) := 'C_PRINT_COUNT';
  c_frozen_flag CONSTANT VARCHAR2(30) := 'C_FROZEN_FLAG';
  c_amount_to_encumber CONSTANT VARCHAR2(30) := 'C_AMOUNT_TO_ENCUMBER';
  c_quote_warning_delay CONSTANT VARCHAR2(30) := 'C_QUOTE_WARNING_DELAY';
  c_approval_required_flag CONSTANT VARCHAR2(30) := 'C_APPROVAL_REQUIRED_FLAG';
  c_style_id CONSTANT VARCHAR2(30) := 'C_STYLE_ID';
  c_amount_limit CONSTANT VARCHAR2(30) := 'C_AMOUNT_LIMIT';
  c_advance_amount CONSTANT VARCHAR2(30) := 'C_ADVANCE_AMOUNT';

--------------------------------------------------------------------------
-- Line Validation Constants
--------------------------------------------------------------------------
-- Common
c_src_doc_line_not_null CONSTANT VARCHAR2(30) := 'C_SRC_DOC_LINE_NOT_NULL';
c_validate_category CONSTANT VARCHAR2(30) := 'C_VALIDATE_CATEGORY';  --bug 8633959
c_validate_item CONSTANT VARCHAR2(30) := 'C_VALIDATE_ITEM';  --bug 14075368
-- Orders
c_amt_agreed_ge_zero CONSTANT VARCHAR2(30) := 'C_AMT_AGREED_GE_ZERO';
c_min_rel_amt_ge_zero CONSTANT VARCHAR2(30) := 'C_MIN_REL_AMT_GE_ZERO';
c_line_qty_gt_zero CONSTANT VARCHAR2(30) := 'C_LINE_QTY_GT_ZERO';
-- <Complex Work R12>: Consolidated qty billed/rcvd checks into exec check
c_line_qty_ge_qty_exec CONSTANT VARCHAR2(30) := 'C_LINE_QTY_GE_QTY_EXEC';
c_line_qty_ge_qty_enc CONSTANT VARCHAR2(30) := 'C_LINE_QTY_GE_QTY_ENC';
c_quantity_notif_change CONSTANT VARCHAR2(30) := 'C_QUANTITY_NOTIF_CHANGE';
c_line_amt_gt_zero CONSTANT VARCHAR2(30) := 'C_LINE_AMT_GT_ZERO';
-- <Complex Work R12>: Consolidated amt billed/rcvd checks into exec check
c_line_amt_ge_amt_exec CONSTANT VARCHAR2(30) := 'C_LINE_AMT_GE_AMT_EXEC';
c_line_amt_ge_timecard CONSTANT VARCHAR2(30) := 'C_LINE_AMT_GE_TIMECARD';
c_line_num_unique CONSTANT VARCHAR2(30) := 'C_LINE_NUM_UNIQUE';
c_line_num_gt_zero CONSTANT VARCHAR2(30) := 'C_LINE_NUM_GT_ZERO';
c_vmi_asl_exists CONSTANT VARCHAR2(30) := 'C_VMI_ASL_EXISTS';
c_start_date_le_end_date CONSTANT VARCHAR2(30) := 'C_START_DATE_LE_END_DATE';
c_otl_inv_start_date_change CONSTANT VARCHAR2(30) := 'C_OTL_INV_START_DATE_CHANGE';
c_otl_inv_end_date_change CONSTANT VARCHAR2(30) := 'C_OTL_INV_END_DATE_CHANGE';
c_unit_price_ge_zero CONSTANT VARCHAR2(30) := 'C_UNIT_PRICE_GE_ZERO';
c_list_price_ge_zero CONSTANT VARCHAR2(30) := 'C_LIST_PRICE_GE_ZERO';
c_market_price_ge_zero CONSTANT VARCHAR2(30) := 'C_MARKET_PRICE_GE_ZERO';
c_validate_unit_price_change CONSTANT VARCHAR2(30) := 'C_VALIDATE_UNIT_PRICE_CHANGE';
-- Agreements
c_expiration_ge_blanket_start CONSTANT VARCHAR2(30) := 'C_EXPIRATION_GE_BLANKET_START';
c_expiration_le_blanket_end CONSTANT VARCHAR2(30) := 'C_EXPIRATION_LE_BLANKET_END';
-- <Complex Work R12 Start>
c_qty_ge_qty_milestone_exec CONSTANT VARCHAR2(30) := 'C_QTY_GE_QTY_MILESTONE_EXEC';
c_price_ge_price_mstone_exec CONSTANT VARCHAR2(30) := 'C_PRICE_GE_PRICE_MSTONE_EXEC';
c_recoupment_rate_range_check CONSTANT VARCHAR2(30) := 'C_RECOUPMENT_RATE_RANGE_CHECK'; -- Bug 5072189
c_retainage_rate_range_check CONSTANT VARCHAR2(30) := 'C_RETAINAGE_RATE_RANGE_CHECK'; -- Bug 5072189
c_prog_pay_rate_range_check CONSTANT VARCHAR2(30) := 'C_PROG_PAY_RATE_RANGE_CHECK'; -- Bug 5072189
c_max_retain_amt_ge_zero CONSTANT VARCHAR2(30) := 'C_MAX_RETAIN_AMT_GE_ZERO'; -- Bug 5221843
c_max_retain_amt_ge_retained CONSTANT VARCHAR2(30) := 'C_MAX_RETAIN_AMT_LE_RETAINED'; -- Bug 5453079
-- <Complex Work R12 End>
c_unit_meas_not_null CONSTANT VARCHAR2(30) := 'C_UNIT_MEAS_NOT_NULL';
c_item_description_not_null CONSTANT VARCHAR2(30) := 'C_ITEM_DESCRIPTION_NOT_NULL';
c_category_id_not_null CONSTANT VARCHAR2(30) := 'C_CATEGORY_ID_NOT_NULL';
c_item_id_not_null CONSTANT VARCHAR2(30) := 'C_ITEM_ID_NOT_NULL';
c_temp_labor_job_id_not_null CONSTANT VARCHAR2(30) := 'C_TEMP_LABOR_JOB_ID_NOT_NULL';
c_line_type_id_not_null CONSTANT VARCHAR2(30) := 'C_LINE_TYPE_ID_NOT_NULL';
c_temp_lbr_start_date_not_null CONSTANT VARCHAR2(30) := 'C_TEMP_LBR_START_DATE_NOT_NULL';
-- OPM Integration R12
c_line_sec_qty_gt_zero   CONSTANT VARCHAR2(30) :=  'C_LINE_SEC_QTY_GT_ZERO';
c_line_qtys_within_deviation CONSTANT VARCHAR2(30) := 'C_LINE_QTYS_WITHIN_DEVIATION';
c_from_line_id_not_null CONSTANT VARCHAR2(30) := 'C_FROM_LINE_ID_NOT_NULL';
c_amt_ge_advance_amt CONSTANT VARCHAR2(30) := 'C_AMT_GE_ADVANCE_AMT'; -- Bug 5446881
  -------------------------------------------------------------------
  -- PDOI Line Validation constants
  -------------------------------------------------------------------
  c_over_tolerance_error_flag CONSTANT VARCHAR2(30) := 'C_OVER_TOLERANCE_ERROR_FLAG';
  c_expiration_date_blanket CONSTANT VARCHAR2(30) := 'C_EXPIRATION_DATE_BLANKET';
  c_global_agreement_flag CONSTANT VARCHAR2(30) := 'C_GLOBAL_AGREEMENT_FLAG';
  c_amount_blanket CONSTANT VARCHAR2(30) := 'C_AMOUNT_BLANKET';
  c_order_type_lookup_code CONSTANT VARCHAR2(30) := 'C_ORDER_TYPE_LOOKUP_CODE';
  c_contractor_name CONSTANT VARCHAR2(30) := 'C_CONTRACTOR_NAME';
  c_job_id CONSTANT VARCHAR2(30) := 'C_JOB_ID';
  c_job_business_group_id CONSTANT VARCHAR2(30) := 'C_JOB_BUSINESS_GROUP_ID';
  c_capital_expense_flag CONSTANT VARCHAR2(30) := 'C_CAPITAL_EXPENSE_FLAG';
  c_un_number_id CONSTANT VARCHAR2(30) := 'C_UN_NUMBER_ID';
  c_hazard_class_id CONSTANT VARCHAR2(30) := 'C_HAZARD_CLASS_ID';
  c_item_id CONSTANT VARCHAR2(30) := 'C_ITEM_ID';
  c_item_description CONSTANT VARCHAR2(30) := 'C_ITEM_DESCRIPTION';
  c_unit_meas_lookup_code CONSTANT VARCHAR2(30) := 'C_UNIT_MEAS_LOOKUP_CODE';
  c_item_revision CONSTANT VARCHAR2(30) := 'C_ITEM_REVISION';
  c_category_id CONSTANT VARCHAR2(30) := 'C_CATEGORY_ID';
  c_category_id_null CONSTANT VARCHAR2(30) := 'C_CATEGORY_ID_NULL';
  c_ip_category_id CONSTANT VARCHAR2(30) := 'C_IP_CATEGORY_ID';
  c_unit_price CONSTANT VARCHAR2(30) := 'C_UNIT_PRICE';
  c_quantity CONSTANT VARCHAR2(30) := 'C_QUANTITY';
  c_amount CONSTANT VARCHAR2(30) := 'C_AMOUNT';
  c_rate_type CONSTANT VARCHAR2(30) := 'C_RATE_TYPE';
  c_line_num CONSTANT VARCHAR2(30) := 'C_LINE_NUM';
  c_po_line_id CONSTANT VARCHAR2(30) := 'C_PO_LINE_ID';
  c_line_type_id CONSTANT VARCHAR2(30) := 'C_LINE_TYPE_ID';
  c_price_type_lookup_code CONSTANT VARCHAR2(30) := 'C_PRICE_TYPE_LOOKUP_CODE';
  c_start_date_standard CONSTANT VARCHAR2(30) := 'C_START_DATE_STANDARD';
  c_item_id_standard CONSTANT VARCHAR2(30) := 'C_ITEM_ID_STANDARD';
  c_quantity_standard CONSTANT VARCHAR2(30) := 'C_QUANTITY_STANDARD';
  c_amount_standard CONSTANT VARCHAR2(30) := 'C_AMOUNT_STANDARD';
  c_price_break_lookup_code CONSTANT VARCHAR2(30) := 'C_PRICE_BREAK_LOOKUP_CODE';
  c_not_to_exceed_price CONSTANT VARCHAR2(30) := 'C_NOT_TO_EXCEED_PRICE';
  c_release_num_null CONSTANT VARCHAR2(30) := 'C_RELEASE_NUM_NULL';
  c_po_release_id_null CONSTANT VARCHAR2(30) := 'C_PO_RELEASE_ID_NULL';
  c_source_shipment_id_null CONSTANT VARCHAR2(30) := 'C_SOURCE_SHIPMENT_ID_NULL';
  c_contract_num_null CONSTANT VARCHAR2(30) := 'C_CONTRACT_NUM_NULL';
  c_contract_id_null CONSTANT VARCHAR2(30) := 'C_CONTRACT_ID_NULL';
  c_type_1099_null CONSTANT VARCHAR2(30) := 'C_TYPE_1099_NULL';
  c_closed_code_null CONSTANT VARCHAR2(30) := 'C_CLOSED_CODE_NULL';
  c_closed_date_null CONSTANT VARCHAR2(30) := 'C_CLOSED_DATE_NULL';
  c_closed_by_null CONSTANT VARCHAR2(30) := 'C_CLOSED_BY_NULL';
  c_committed_amount_null CONSTANT VARCHAR2(30) := 'C_COMMITTED_AMOUNT_NULL';
  c_allow_price_override_null CONSTANT VARCHAR2(30) := 'C_ALLOW_PRICE_OVERRIDE_NULL';
  c_negotiated_by_preparer_null CONSTANT VARCHAR2(30) := 'C_NEGOTIATED_BY_PREPARER_NULL';
  c_capital_expense_flag_null CONSTANT VARCHAR2(30) := 'C_CAPTIAL_EXPENSE_FLAG_NULL';
  c_min_release_amount_null CONSTANT VARCHAR2(30) := 'C_MIN_RELEASE_AMOUNT_NULL';
  c_market_price_null CONSTANT VARCHAR2(30) := 'C_MARKET_PRICE_NULL';
  c_ip_category_id_null CONSTANT VARCHAR2(30) := 'C_IP_CATEGORY_ID_NULL';
  c_uom_update CONSTANT VARCHAR2(30) := 'C_UOM_UPDATE';
  c_item_desc_update CONSTANT VARCHAR2(30) := 'C_ITEM_DESC_UPDATE';
  c_ip_category_id_update CONSTANT VARCHAR2(30) := 'C_IP_CATEGORY_ID_UPDATE';
  c_line_secondary_uom CONSTANT VARCHAR2(30) := 'C_LINE_SECONDARY_UOM';
  c_line_secondary_quantity CONSTANT VARCHAR2(30) := 'C_LINE_SECONDARY_QUANTITY';
  c_line_preferred_grade CONSTANT VARCHAR2(30) := 'C_LINE_PREFERRED_GRADE';
  c_line_style_related_info CONSTANT VARCHAR2(30) := 'C_LINE_STYLE_RELATED_INFO';
  c_negotiated_by_preparer CONSTANT VARCHAR2(30) := 'C_NEGOTIATED_BY_PREPARER';
  c_negotiated_by_prep_update CONSTANT VARCHAR2(50) := 'C_NEGOTIATED_BY_PREPARER_UPDATE';
  c_category_id_update CONSTANT VARCHAR2(30) := 'C_CATEGORY_ID_UPDATE';
  c_unit_price_update CONSTANT VARCHAR2(30) := 'C_UNIT_PRICE_UPDATE';
  c_amount_update CONSTANT VARCHAR2(30) := 'C_AMOUNT_UPDATE';
    -- <PDOI for Complex PO Project: Start>
  c_pdoi_qty_ge_qty_mstone_exec CONSTANT VARCHAR2(30) := 'C_PDOI_QTY_GE_QTY_MSTONE_EXEC';
  c_pdoi_prc_ge_prc_mstone_exec CONSTANT VARCHAR2(30) := 'C_PDOI_PRC_GE_PRC_MSTONE_EXEC';
  c_pdoi_recoupment_range_check CONSTANT VARCHAR2(30) := 'C_PDOI_RECOUPMENT_RANGE_CHECK';
  c_pdoi_retainage_range_check CONSTANT VARCHAR2(30) := 'C_PDOI_RETAINAGE_RANGE_CHECK';
  c_pdoi_prog_pay_range_check CONSTANT VARCHAR2(30) := 'C_PDOI_PROG_PAY_RANGE_CHECK';
  c_pdoi_max_retain_amt_ge_zero CONSTANT VARCHAR2(30) := 'C_PDOI_MAX_RETAIN_AMT_GE_ZERO';
  c_pdoi_max_retain_amt_ge_retnd CONSTANT VARCHAR2(30) := 'C_PDOI_MAX_RETAIN_AMT_GE_RETND';
  c_pdoi_amt_ge_line_advance_amt CONSTANT VARCHAR2(30) := 'C_PDOI_AMT_GE_LINE_ADVANCE_AMT';
  c_pdoi_complex_po_att_check CONSTANT VARCHAR2(30) := 'C_PDOI_COMPLEX_PO_ATT_CHECK';
  -- <PDOI for Complex PO Project: End>

  -- PDOI Enhancement Bug#17063664
  c_validate_cross_ou CONSTANT VARCHAR2(30) := 'C_VALIDATE_CROSS_OU';
  c_validate_req_reference CONSTANT VARCHAR2(30) := 'C_VALIDATE_REQ_REFERENCE';
  c_validate_source_doc CONSTANT VARCHAR2(30) := 'C_VALIDATE_SOURCE_DOC';
  c_oke_contract_header CONSTANT VARCHAR2(30) := 'C_OKE_CONTRACT_HEADER';
  c_oke_contract_version CONSTANT VARCHAR2(30) := 'C_OKE_CONTRACT_VERSION';

--------------------------------------------------------------------------
-- Shipment Validation Constants
--------------------------------------------------------------------------
c_days_early_gte_zero CONSTANT VARCHAR2(30) := 'C_DAYS_EARLY_GTE_ZERO';
c_days_late_gte_zero CONSTANT VARCHAR2(30) := 'C_DAYS_LATE_GTE_ZERO';
c_rcv_close_tol_within_range CONSTANT VARCHAR2(30) := 'C_RCV_CLOSE_TOL_WITHIN_RANGE';
c_over_rcpt_tol_within_range CONSTANT VARCHAR2(30) := 'C_OVER_RCPT_TOL_WITHIN_RANGE';
c_match_4way_check CONSTANT VARCHAR2(30) := 'C_MATCH_4WAY_CHECK';
c_inv_close_tol_range_check CONSTANT VARCHAR2(30) := 'C_INV_CLOSE_TOL_RANGE_CHECK';
c_need_by_date_open_per_check CONSTANT VARCHAR2(30) := 'C_NEED_BY_DATE_OPEN_PER_CHECK';
c_promise_date_open_per_check CONSTANT VARCHAR2(30) := 'C_PROMISE_DATE_OPEN_PER_CHECK';
c_ship_to_org_null_check CONSTANT VARCHAR2(30) := 'C_SHIP_TO_ORG_NULL_CHECK';
c_ship_to_loc_null_check CONSTANT VARCHAR2(30) := 'C_SHIP_TO_LOC_NULL_CHECK';
c_ship_num_gt_zero CONSTANT VARCHAR2(30) := 'C_SHIP_NUM_GT_ZERO';
c_ship_num_unique_check CONSTANT VARCHAR2(30) := 'C_SHIP_NUM_UNIQUE_CHECK';
c_is_org_in_current_sob_check CONSTANT VARCHAR2(30) := 'C_IS_ORG_IN_CURRENT_SOB_CHECK';
c_ship_qty_gt_zero CONSTANT VARCHAR2(30) := 'C_SHIP_QTY_GT_ZERO';
-- <Complex Work R12>: Consolidated qty billed/rcvd checks into exec check
c_ship_qty_ge_qty_exec CONSTANT VARCHAR2(30) := 'C_SHIP_QTY_GE_QTY_EXEC';
c_ship_amt_gt_zero CONSTANT VARCHAR2(30) := 'C_SHIP_AMT_GT_ZERO';
-- <Complex Work R12>: Consolidated amt billed/rcvd checks into exec check
c_ship_amt_ge_amt_exec CONSTANT VARCHAR2(30) := 'C_SHIP_AMT_GE_AMT_EXEC';
-- OPM Integration R12
c_ship_sec_qty_gt_zero   CONSTANT VARCHAR2(30) :=  'C_SHIP_SEC_QTY_GT_ZERO';
c_ship_qtys_within_deviation CONSTANT VARCHAR2(30) := 'C_SHIP_QTYS_WITHIN_DEVIATION';
c_unit_of_measure_not_null CONSTANT VARCHAR2(30) := 'C_UNIT_OF_MEAS_NOT_NULL'; -- Bug 5385686
c_complex_price_or_gt_zero CONSTANT VARCHAR2(30) := 'C_COMPLEX_PRICE_OR_GT_ZERO'; --Bug 110704404

  ------------------------------------------------------------------
  -- PDOI Shipment Validation Subroutine Constants
  ------------------------------------------------------------------
  c_shipment_need_by_date CONSTANT VARCHAR2(30) := 'C_SHIPMENT_NEED_BY_DATE';
  c_shipment_promised_date CONSTANT VARCHAR2(30) := 'C_SHIPMENT_PROMISED_DATE';
  c_shipment_type_blanket CONSTANT VARCHAR2(30) := 'C_SHIPMENT_TYPE_BLANKET';
  c_shipment_type_standard CONSTANT VARCHAR2(30) := 'C_SHIPMENT_TYPE_STANDARD';
  c_shipment_type_quotation CONSTANT VARCHAR2(30) := 'C_SHIPMENT_TYPE_QUOTATION';
  c_shipment_num CONSTANT VARCHAR2(30) := 'C_SHIPMENT_NUM';
  c_shipment_quantity CONSTANT VARCHAR2(30) := 'C_SHIPMENT_QUANTITY';
  c_shipment_price_override CONSTANT VARCHAR2(30) := 'C_SHIPMENT_PRICE_OVERRIDE';
  c_shipment_price_discount CONSTANT VARCHAR2(30) := 'C_SHIPMENT_PRICE_DISCOUNT';
  c_ship_to_organization_id CONSTANT VARCHAR2(30) := 'C_SHIP_TO_ORGANIZATION_ID';
  c_shipment_effective_dates CONSTANT VARCHAR2(30) := 'C_SHIPMENT_EFFECTIVE_DATES';
  c_qty_rcv_exception_code CONSTANT VARCHAR2(30) := 'C_QTY_RCV_EXCEPTION_CODE';
  c_enforce_ship_to_loc_code CONSTANT VARCHAR2(30) := 'C_ENFORCE_SHIP_TO_LOC_CODE';
  c_allow_sub_receipts_flag CONSTANT VARCHAR2(30) := 'C_ALLOW_SUB_RECEIPTS_FLAG';
  c_days_early_receipt_allowed CONSTANT VARCHAR2(30) := 'C_DAYS_EARLY_RECEIPT_ALLOWD';
  c_receipt_days_exception_code CONSTANT VARCHAR2(30) := 'C_RECEIPT_DAYS_EXCEPTION_CODE';
  c_invoice_close_tolerance CONSTANT VARCHAR2(30) := 'C_INVOICE_CLOSE_TOLERANCE';
  c_receive_close_tolerance CONSTANT VARCHAR2(30) := 'C_RECEIVE_CLOSE_TOLERANCE';
  c_receiving_routing_id CONSTANT VARCHAR2(30) := 'C_RECEIVING_ROUTING_ID';
  c_accrue_on_receipt_flag CONSTANT VARCHAR2(30) := 'C_ACCRUE_ON_RECEIPT_FLAG';
  c_terms_id_line_loc CONSTANT VARCHAR2(30) := 'C_TERMS_ID_LINE_LOC';
  c_need_by_date_null CONSTANT VARCHAR2(30) := 'C_NEED_BY_DATE_NULL';
  c_firm_flag_null CONSTANT VARCHAR2(30) := 'C_FIRM_FLAG_NULL';
  c_promised_date_null CONSTANT VARCHAR2(30) := 'C_PROMISED_DATE_NULL';
  c_over_tolerance_err_flag_null CONSTANT VARCHAR2(30) := 'C_OVER_TOLERANCE_ERR_FLAG_NULL';
  c_qty_rcv_tolerance_null CONSTANT VARCHAR2(30) := 'C_QTY_RCV_TOLERANCE_NULL';
  c_qty_rcv_exception_code_null CONSTANT VARCHAR2(30) := 'C_QTY_RCV_EXCEPTION_CODE_NULL';
  c_receipt_required_flag_null CONSTANT VARCHAR2(30) := 'C_RECEIPT_REQUIRED_FLAG_NULL';
  c_inspection_reqd_flag_null CONSTANT VARCHAR2(30) := 'C_INSPECTION_REQD_FLAG_NULL';
  c_receipt_days_exception_null CONSTANT VARCHAR2(30) := 'C_RECEIPT_DATES_EXCEPTION_NULL';
  c_invoice_close_toler_null CONSTANT VARCHAR2(30) := 'C_INVOICE_CLOSE_TOLER_NULL';
  c_receive_close_toler_null CONSTANT VARCHAR2(30) := 'C_RECEIVE_CLOSE_TOLER_NULL';
  c_days_early_rcpt_allowed_null CONSTANT VARCHAR2(30) := 'C_DAYS_EARLY_RCPT_ALLOWED_NULL';
  c_days_late_rcpt_allowed_null CONSTANT VARCHAR2(30) := 'C_DAYS_LATE_RCPT_ALLOWED_NULL';
  c_enfrce_ship_to_loc_code_null CONSTANT VARCHAR2(30) := 'C_ENFRCE_SHIP_TO_LOC_CODE_NULL';
  c_allow_sub_receipts_flag_null CONSTANT VARCHAR2(30) := 'C_ALLOW_SUB_RECEIPTS_FLAG_NULL';
  c_receiving_routing_null CONSTANT VARCHAR2(30) := 'C_RECEIVING_ROUTING_NULL';
  c_line_loc_secondary_uom CONSTANT VARCHAR2(30) := 'C_LINE_LOC_SECONDARY_UOM';
  c_line_loc_secondary_quantity CONSTANT VARCHAR2(30) := 'C_LINE_LOC_SECONDARY_QUANTITY';
  c_line_loc_preferred_grade CONSTANT VARCHAR2(30) := 'C_LINE_LOC_PREFERRED_GRADE';
  c_line_loc_style_related_info CONSTANT VARCHAR2(30) := 'C_LINE_LOC_STYLE_RELATED_INFO';
  c_price_break CONSTANT VARCHAR2(30) := 'C_PRICE_BREAK';
  c_tax_name CONSTANT VARCHAR2(30) := 'C_TAX_NAME';
  c_fob_lookup_code_line_loc CONSTANT VARCHAR2(30) := 'C_FOB_LOOKUP_CODE_LINE_LOC';
  c_freight_terms_line_loc CONSTANT VARCHAR2(40) := 'C_FREIGHT_TERMS_LOOKUP_LINE_LOC';
  c_freight_carrier_line_loc CONSTANT VARCHAR2(30) := 'C_FREIGHT_CARRIER_LINE_LOC';
  c_freight_carrier_null CONSTANT VARCHAR2(30) := 'C_FREIGHT_CARRIER_NULL';
  c_fob_lookup_code_null CONSTANT VARCHAR2(30) := 'C_FOB_LOOKUP_CODE_NULL';
  c_freight_terms_lookup_null CONSTANT VARCHAR2(30) := 'C_FREIGHT_TERMS_LOOKUP_NULL';
  --<Bug 14610858> Added validation for GDF attributes
  c_gdf_attributes CONSTANT VARCHAR2(30) := 'C_GDF_ATTRIBUTES';
   -- <PDOI for Complex PO Project: Start>
  c_pdoi_amt_ge_ship_advance_amt CONSTANT VARCHAR2(30) := 'C_PDOI_AMT_GE_SHIP_ADVANCE_AMT';
  c_pdoi_shipment_amount CONSTANT VARCHAR2(30) := 'C_PDOI_SHIPMENT_AMOUNT';
  c_pdoi_payment_type CONSTANT VARCHAR2(30) := 'C_PDOI_PAYMENT_TYPE';
  -- <PDOI for Complex PO Project: End>

  -- <<PDOI Enhancement Bug#17063664 Start>
  c_inspection_reqd_flag CONSTANT VARCHAR2(30) := 'C_INSPECTION_REQD_FLAG';
  c_days_late_receipt_allowed CONSTANT VARCHAR2(30) := 'C_DAYS_LATE_RECEIPT_ALLOWED';
  -- <<PDOI Enhancement Bug#17063664 End>

--------------------------------------------------------------------------
-- Price Break Validation Constants
--------------------------------------------------------------------------
c_at_least_one_required_field CONSTANT VARCHAR2(30) := 'C_AT_LEAST_ONE_REQUIRED_FIELD';
c_price_discount_in_percent CONSTANT VARCHAR2(30) := 'C_PRICE_DISCOUNT_IN_PERCENT';
c_price_override_gt_zero CONSTANT VARCHAR2(30) := 'C_PRICE_OVERRIDE_GT_ZERO';
c_price_break_qty_ge_zero CONSTANT VARCHAR2(30) := 'C_PRICE_BREAK_QTY_GE_ZERO';
c_price_break_start_le_end CONSTANT VARCHAR2(30) := 'C_PRICE_BREAK_START_LE_END';
c_break_start_ge_blanket_start CONSTANT VARCHAR2(30) := 'C_BREAK_START_GE_BLANKET_START';
c_break_start_le_blanket_end CONSTANT VARCHAR2(30) := 'C_BREAK_START_LE_BLANKET_END';
c_break_start_le_expiration CONSTANT VARCHAR2(30) := 'C_BREAK_START_LE_EXPIRATION';
c_break_end_le_expiration CONSTANT VARCHAR2(30) := 'C_BREAK_END_LE_EXPIRATION';
c_break_end_ge_blanket_start CONSTANT VARCHAR2(30) := 'C_BREAK_END_GE_BLANKET_START';
c_break_end_le_blanket_end CONSTANT VARCHAR2(30) := 'C_BREAK_END_LE_BLANKET_END';

--------------------------------------------------------------------------
-- Distribution Validation Constants
--------------------------------------------------------------------------
c_dist_num_unique CONSTANT VARCHAR2(30) := 'C_DIST_NUM_UNIQUE';
c_dist_num_gt_zero CONSTANT VARCHAR2(30) := 'C_DIST_NUM_GT_ZERO';
c_dist_qty_gt_zero CONSTANT VARCHAR2(30) := 'C_DIST_QTY_GT_ZERO';
-- <Complex Work R12>: Combine del and billed into exec
c_dist_qty_ge_qty_exec CONSTANT VARCHAR2(30) := 'C_DIST_QTY_GE_QTY_EXEC';
c_dist_amt_gt_zero CONSTANT VARCHAR2(30) := 'C_DIST_AMT_GT_ZERO';
-- <Complex Work R12>: Combine del and billed into exec
c_dist_amt_ge_amt_exec CONSTANT VARCHAR2(30) := 'C_DIST_AMT_GE_AMT_EXEC';
c_pjm_unit_number_effective CONSTANT VARCHAR2(30) := 'C_PJM_UNIT_NUMBER_EFFECTIVE';
c_oop_enter_all_fields CONSTANT VARCHAR2(30) := 'C_OOP_ENTER_ALL_FIELDS';
-- Agreements
c_amount_to_encumber_ge_zero CONSTANT VARCHAR2(30) := 'C_AMOUNT_TO_ENCUMBER_GE_ZERO';
c_budget_account_id_not_null CONSTANT VARCHAR2(30) := 'C_BUDGET_ACCOUNT_ID_NOT_NULL';
c_gl_encumbered_date_not_null CONSTANT VARCHAR2(30) := 'C_GL_ENCUMBERED_DATE_NOT_NULL';
c_gl_enc_date_not_null_open CONSTANT VARCHAR2(30) := 'C_GL_ENC_DATE_NOT_NULL_OPEN';
c_gms_data_valid CONSTANT VARCHAR2(30) := 'C_GMS_DATA_VALID';
c_unencum_amt_le_amt_to_encum CONSTANT VARCHAR2(30) := 'C_UNENCUM_AMT_LE_AMT_TO_ENCUM';
-- Bug16208248
c_charge_account_id_null CONSTANT VARCHAR2(30) := 'C_CHARGE_ACCOUNT_ID_NULL';


  c_dist_amount_ordered CONSTANT VARCHAR2(30) := 'C_DIST_AMOUNT_ORDERED';
  c_dist_quantity_ordered CONSTANT VARCHAR2(30) := 'C_DIST_QUANTITY_ORDERED';
  c_dist_destination_org_id CONSTANT VARCHAR2(30) := 'C_DIST_DESTINATION_ORG_ID';
  c_dist_deliver_to_location_id CONSTANT VARCHAR2(30) := 'C_DIST_DELIVER_TO_LOCATION_ID';
  c_dist_deliver_to_person_id CONSTANT VARCHAR2(30) := 'C_DIST_DELIVER_TO_PERSON_ID';
  c_dist_destination_type_code CONSTANT VARCHAR2(30) := 'C_DIST_DESTINATION_TYPE_CODE';
  c_dist_destination_subinv CONSTANT VARCHAR2(30) := 'C_DIST_DESTINATION_SUBINV';
  c_dist_wip_entity_id CONSTANT VARCHAR2(30) := 'C_DIST_WIP_ENTITY_ID';
  c_prevent_encumberance_flag CONSTANT VARCHAR2(30) := 'C_PREVENT_ENCUMBERANCE_FLAG';
  c_gl_encumbered_date CONSTANT VARCHAR2(30) := 'C_GL_ENCUMBERED_DATE'; --Bug 18907904
  c_charge_account_id CONSTANT VARCHAR2(30) := 'C_CHARGE_ACCOUNT_ID';
  c_budget_account_id CONSTANT VARCHAR2(30) := 'C_BUDGET_ACCOUNT_ID';
  c_accrual_account_id CONSTANT VARCHAR2(30) := 'C_ACCRUAL_ACCOUNT_ID';
  c_variance_account_id CONSTANT VARCHAR2(30) := 'C_VARIANCE_ACCOUNT_ID';
  c_project_acct_context CONSTANT VARCHAR2(30) := 'C_PROJECT_ACCT_CONTEXT';
  c_project_info CONSTANT VARCHAR2(30) := 'C_PROJECT_INFO';
  c_tax_recovery_override_flag CONSTANT VARCHAR2(30) := 'C_TAX_RECOVERY_OVERRIDE_FLAG';
  c_check_fv_validations CONSTANT VARCHAR2(30) := 'C_CHECK_FV_VALIDATIONS';
  c_check_proj_rel_validations CONSTANT VARCHAR2(30) := 'C_CHECK_PROJ_REL_VALIDATIONS'; -- Bug 5442682

  --Bug 16856753
  c_charge_account_id_full CONSTANT VARCHAR2(30) := 'C_CHARGE_ACCOUNT_ID_FULL';

  -- <PDOI Enhancement Bug#17063664 Sart>
  c_oke_contract_line CONSTANT VARCHAR2(30) := 'C_OKE_CONTRACT_LINE';
  c_oke_contract_del CONSTANT VARCHAR2(30) := 'C_OKE_CONTRACT_DEL';
  -- <PDOI Enhancement Bug#17063664 End>

--------------------------------------------------------------------------
-- Notification Control Validation Constants
--------------------------------------------------------------------------
c_notif_start_date_le_end_date CONSTANT VARCHAR2(30) := 'C_NOTIF_START_DATE_LE_END_DATE';
c_notif_percent_le_one_hundred CONSTANT VARCHAR2(30) := 'C_NOTIF_PERCENT_LE_ONE_HUNDRED';
c_notif_amount_gt_zero CONSTANT VARCHAR2(30) := 'C_NOTIF_AMOUNT_GT_ZERO';
c_notif_amount_not_null CONSTANT VARCHAR2(30) := 'C_NOTIF_AMOUNT_NOT_NULL';
c_notif_start_date_not_null CONSTANT VARCHAR2(30) := 'C_NOTIF_START_DATE_NOT_NULL';


--------------------------------------------------------------------------
-- GA Org Assignment Validation Constants
--------------------------------------------------------------------------
c_assign_purch_org_not_null CONSTANT VARCHAR2(30) := 'C_ASSIGN_PURCH_ORG_NOT_NULL';
c_assign_vendor_site_not_null CONSTANT VARCHAR2(30) := 'C_ASSIGN_VENDOR_SITE_NOT_NULL';


--------------------------------------------------------------------------
-- Price Differential Validation Constants
--------------------------------------------------------------------------
-- Common
c_unique_price_diff_num CONSTANT VARCHAR2(30) := 'C_UNIQUE_PRICE_DIFF_NUM';
c_price_diff_num_gt_zero CONSTANT VARCHAR2(30) := 'C_PRICE_DIFF_NUM_GT_ZERO';
c_unique_price_type CONSTANT VARCHAR2(30) := 'C_UNIQUE_PRICE_TYPE';
-- Agreements
c_max_mul_ge_zero CONSTANT VARCHAR2(30) := 'C_MAX_MUL_GE_ZERO';
c_max_mul_ge_min_mul CONSTANT VARCHAR2(30) := 'C_MAX_MUL_GE_MIN_MUL';
c_min_mul_ge_zero CONSTANT VARCHAR2(30) := 'C_MIN_MUL_GE_ZERO';
-- Orders
c_mul_ge_zero CONSTANT VARCHAR2(30) := 'C_MUL_GE_ZERO';
c_spo_price_type_on_src_doc CONSTANT VARCHAR2(30) := 'C_SPO_PRICE_TYPE_ON_SRC_DOC';
c_spo_mul_btwn_min_max CONSTANT VARCHAR2(30) := 'C_SPO_MUL_BTWN_MIN_MAX';
c_spo_mul_ge_min CONSTANT VARCHAR2(30) := 'C_SPO_MUL_GE_MIN';

  -------------------------------------------------------------
  -- PDOI Price Differential Validation constants
  -------------------------------------------------------------
  c_price_type CONSTANT VARCHAR2(30) := 'C_PRICE_TYPE';
  c_multiple_price_diff CONSTANT VARCHAR2(30) := 'C_MULTIPLE_PRICE_DIFF';
  c_entity_type CONSTANT VARCHAR2(30) := 'C_ENTITY_TYPE';
  c_multiplier CONSTANT VARCHAR2(30) := 'C_MULTIPLIER';
  c_min_multiplier CONSTANT VARCHAR2(30) := 'C_MIN_MULTIPLIER';
  c_max_multiplier CONSTANT VARCHAR2(30) := 'C_MAX_MULTIPLIER';
  c_price_diff_style_info CONSTANT VARCHAR2(30) := 'C_PRICE_DIFF_STYLE_INFO';



--------------------------------------------------------------------------
-- Used to validate that a change to the unit price is allowed.
--------------------------------------------------------------------------
c_no_dists_reserved CONSTANT VARCHAR2(30) := 'C_NO_DISTS_RESERVED';
c_accruals_allow_update CONSTANT VARCHAR2(30) := 'C_ACCRUALS_ALLOW_UPDATE';
c_no_timecards_exist CONSTANT VARCHAR2(30) := 'C_NO_TIMECARDS_EXIST';
c_no_pending_receipts CONSTANT VARCHAR2(30) := 'C_NO_PENDING_RECEIPTS';
c_retro_account_allows_update CONSTANT VARCHAR2(30) := 'C_RETRO_ACCOUNT_ALLOWS_UPDATE';
c_warn_amt_based_notif_ctrls CONSTANT VARCHAR2(30) := 'C_WARN_AMT_BASED_NOTIF_CTRLS';
c_no_unvalidated_debit_memo CONSTANT VARCHAR2(30) := 'C_NO_UNVALIDATED_DEBIT_MEMO'; --<Bug 18372756>

--------------------------------------------------------------------------
-- Line Price Adjustments Validation Constants
--------------------------------------------------------------------------
c_change_reason_code_not_null CONSTANT VARCHAR2(30) := 'C_CHANGE_REASON_CODE_NOT_NULL';
c_change_reason_text_not_null CONSTANT VARCHAR2(30) := 'C_CHANGE_REASON_TEXT_NOT_NULL';

-- <<PDOI Enhancement Bug#17063664 Start>>
--------------------------------------------------------------------------
-- Cross OU Validation Constants
--------------------------------------------------------------------------
c_cross_ou_vmi_check CONSTANT VARCHAR2(30) := 'C_CROSS_OU_VMI_CHECK';
c_cross_ou_consigned_check CONSTANT VARCHAR2(30) := 'C_CROSS_OU_CONSIGNED_CHECK';
c_cross_ou_item_validity_check CONSTANT VARCHAR2(30) := 'C_CROSS_OU_ITEM_VALIDITY_CHECK';
c_cross_ou_pa_project_check CONSTANT VARCHAR2(30) := 'C_CROSS_OU_PA_PROJECT_CHECK';
c_cross_ou_dest_ou_check CONSTANT VARCHAR2(30) := 'C_CROSS_OU_DEST_OU_CHECK';
c_cross_ou_txn_flow_check CONSTANT VARCHAR2(30) := 'C_CROSS_OU_TXN_FLOW_CHECK';
c_cross_ou_services_check CONSTANT VARCHAR2(30) := 'C_CROSS_OU_SERVICES_CHECK';
c_cross_ou_cust_loc_check CONSTANT VARCHAR2(30) := 'C_CROSS_OU_CUST_LOC_CHECK';
c_cross_ou_ga_enc_check CONSTANT VARCHAR2(30) := 'C_CROSS_OU_GA_ENC_CHECK';

--------------------------------------------------------------------------
-- Source Doc Validations
--------------------------------------------------------------------------
c_src_blanket_exists CONSTANT VARCHAR2(30) := 'C_SRC_BLANKET_EXISTS';
c_src_contract_exists CONSTANT VARCHAR2(30) := 'C_SRC_CONTRACT_EXISTS';
c_src_only_one CONSTANT VARCHAR2(30) := 'C_SRC_ONLY_ONE';
c_src_doc_global CONSTANT VARCHAR2(30) := 'C_SRC_DOC_GLOBAL';
c_src_doc_vendor CONSTANT VARCHAR2(30) := 'C_SRC_DOC_VENDOR';
c_src_doc_vendor_site CONSTANT VARCHAR2(30) := 'C_SRC_DOC_VENDOR_SITE';
c_src_doc_approved CONSTANT VARCHAR2(30) := 'C_SRC_DOC_APPROVED';
c_src_doc_hold CONSTANT VARCHAR2(30) := 'C_SRC_DOC_HOLD';
c_src_doc_currency CONSTANT VARCHAR2(30) := 'C_SRC_DOC_CURRENCY';
c_src_doc_closed_code CONSTANT VARCHAR2(30) := 'C_SRC_DOC_CLOSED_CODE';
c_src_doc_cancel CONSTANT VARCHAR2(30) := 'C_SRC_DOC_CANCEL';
c_src_doc_frozen CONSTANT VARCHAR2(30) := 'C_SRC_DOC_FROZEN';
c_src_bpa_expiry_date CONSTANT VARCHAR2(30) := 'C_SRC_BPA_EXPIRY_DATE';
c_src_cpa_expiry_date CONSTANT VARCHAR2(30) := 'C_SRC_CPA_EXPIRY_DATE';
c_src_doc_style CONSTANT VARCHAR2(30) := 'C_SRC_DOC_STYLE';
c_src_line_not_null CONSTANT VARCHAR2(30) := 'C_SRC_DOC_LINE_NOT_NULL';
c_src_line_item CONSTANT VARCHAR2(30) := 'C_SRC_DOC_LINE_ITEM';
c_src_line_item_rev CONSTANT VARCHAR2(30) := 'C_SRC_DOC_LINE_ITEM_REV';
c_src_line_job CONSTANT VARCHAR2(30) := 'C_SRC_DOC_LINE_JOB';
c_src_line_cancel CONSTANT VARCHAR2(30) := 'C_SRC_DOC_LINE_CANCEL';
c_src_line_closed	CONSTANT VARCHAR2(30) := 'C_SRC_DOC_LINE_CLOSED';
c_src_line_order_type CONSTANT VARCHAR2(30) := 'C_SRC_DOC_LINE_ORDER_TYPE';
c_src_line_purchase_basis CONSTANT VARCHAR2(30) := 'C_SRC_DOC_LINE_PURCHASE_BASIS';
c_src_line_matching_basis CONSTANT VARCHAR2(30) := 'C_SRC_DOC_LINE_MATCHING_BASIS';
c_src_line_uom CONSTANT VARCHAR2(30) := 'C_SRC_DOC_LINE_UOM';
c_src_allow_price_ovr CONSTANT VARCHAR2(30) := 'C_SRC_ALLOW_PRICE_OVR';

c_req_exists CONSTANT VARCHAR2(30) := 'C_REQ_EXISTS';
c_validate_no_ship_dist CONSTANT VARCHAR2(30) := 'C_VALIDATE_NO_SHIP_DIST';
c_validate_req_status CONSTANT VARCHAR2(30) := 'C_VALIDATE_REQ_STATUS';
c_reqs_in_pool_flag CONSTANT VARCHAR2(30) := 'C_REQS_IN_POOL_FLAG';
c_reqs_cancel_flag CONSTANT VARCHAR2(30) := 'C_REQS_CANCEL_FLAG';
c_reqs_closed_code CONSTANT VARCHAR2(30) := 'C_REQS_CLOSED_CODE';
c_reqs_mdfd_by_agt CONSTANT VARCHAR2(30) := 'C_REQS_MDFD_BY_AGNT';
c_reqs_at_srcng_flg CONSTANT VARCHAR2(30) := 'C_REQS_AT_SRCNG_FLAG';
c_reqs_line_loc CONSTANT VARCHAR2(30) := 'C_REQS_LINE_LOC';
c_validate_req_item CONSTANT VARCHAR2(30) := 'C_VALIDATE_REQ_ITEM';
c_validate_req_job CONSTANT VARCHAR2(30) := 'C_VALIDATE_REQ_JOB';
c_validate_req_pur_bas CONSTANT VARCHAR2(30) := 'C_VALIDATE_REQ_PUR_BAS';
c_validate_req_mat_bas CONSTANT VARCHAR2(30) := 'C_VALIDATE_REQ_MAT_BAS';
c_validate_pcard CONSTANT VARCHAR2(30) := 'C_VALIDATE_PCARD';
c_validate_reqorg_srcdoc CONSTANT VARCHAR2(30) := 'C_VALIDATE_REQORG_SRCDOC';
c_validate_style_dest CONSTANT VARCHAR2(30) := 'C_VALIDATE_STYLE_DEST_PROGRESS';
c_validate_style_line CONSTANT VARCHAR2(30) := 'C_VALIDATE_STYLE_LINE';
c_validate_style_pcard CONSTANT VARCHAR2(30) := 'C_VALIDATE_STYLE_PCARD';
c_validate_req_vmi_bpa CONSTANT VARCHAR2(30) := 'C_VALIDATE_REQ_VMI_BPA';
c_validate_req_vmi_sup CONSTANT VARCHAR2(30) := 'C_VALIDATE_REQ_VMI_SUP';
c_validate_req_on_spo CONSTANT VARCHAR2(30) := 'C_VALIDATE_REQ_ON_SPO';
c_validate_req_pcard_sup CONSTANT VARCHAR2(30) := 'C_VALIDATE_REQ_PCARD_SUP';
-- <<PDOI Enhancement Bug#17063664 End>>
---------------------------------------------------------------
-- Validation Sets.
---------------------------------------------------------------

-- Validation set for HTML Orders headers.
c_html_order_header_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
  -- Bug# 4779226 remove c_warn_supplier_on_hold from header check
    c_rate_gt_zero
  , c_rate_combination_valid
  , c_doc_num_chars_valid
  , c_doc_num_unique
  , c_agent_id_not_null
  , c_hdr_ship_to_loc_not_null
  , c_fax_email_address_valid
  , c_segment1_not_null
  , c_ship_via_lookup_code_valid -- bug 9213424

  );

-- Validation set for HTML Orders lines.
c_html_order_line_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_amt_agreed_ge_zero
  , c_min_rel_amt_ge_zero
  , c_line_qty_gt_zero
  , c_line_qty_ge_qty_exec  -- <Complex Work R12>: Consolidate rcvd/billed
  -- < Bug:13503748 : Encumbrance ER Edit without unreserve>--
  --, c_line_qty_ge_qty_enc
  -- ECO# 4708990/4586199: Obsoleting some messages
  --, c_quantity_notif_change
  , c_line_amt_gt_zero
  , c_line_amt_ge_amt_exec  -- <Complex Work R12>: Consolidate rcvd/billed
  , c_line_amt_ge_timecard
  , c_line_num_gt_zero
  , c_line_num_unique
  , c_validate_category  -- bug 8633959
  , c_validate_item  -- bug 14075368
  -- Bug# 4634769: Do not do the vmi check any more, it is done in
  -- submission check.
  --, c_vmi_asl_exists
  , c_start_date_le_end_date
  , c_otl_inv_start_date_change
  , c_otl_inv_end_date_change
  , c_unit_price_ge_zero
  , c_list_price_ge_zero
  , c_market_price_ge_zero
  , c_validate_unit_price_change
  -- <Complex Work R12 Start>
  , c_qty_ge_qty_milestone_exec
  , c_price_ge_price_mstone_exec
  , c_recoupment_rate_range_check   -- Bug 5072189
  , c_retainage_rate_range_check   -- Bug 5072189
  , c_prog_pay_rate_range_check   -- Bug 5072189
  , c_max_retain_amt_ge_zero      --Bug 5221843
  , c_max_retain_amt_ge_retained  --Bug 5453079
  -- <Complex Work R12 End>
  , c_item_id_not_null
  , c_temp_labor_job_id_not_null
  , c_category_id_not_null
  , c_item_description_not_null
  , c_unit_meas_not_null
  , c_line_type_id_not_null
  , c_temp_lbr_start_date_not_null
  , c_line_sec_qty_gt_zero          -- OPM Integration R12
  , c_line_qtys_within_deviation    -- OPM Integration R12
  , c_from_line_id_not_null
  , c_src_doc_line_not_null
  , c_amt_ge_advance_amt   -- Bug 5070210
  );

-- Validation set for HTML Order price differentials.
c_html_order_price_diff_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_unique_price_diff_num
  , c_price_diff_num_gt_zero
  , c_unique_price_type
  , c_mul_ge_zero
  , c_spo_price_type_on_src_doc
  , c_spo_mul_btwn_min_max
  , c_spo_mul_ge_min
  );

-- Validation set for HTML Orders shipments.
-- ECO 4503425: Removed the planned item null date check as this
-- has been moved to submission checks
c_html_order_shipment_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_days_early_gte_zero
  , c_days_late_gte_zero
  , c_rcv_close_tol_within_range
  , c_over_rcpt_tol_within_range
  -- ECO# 4708990/4586199: Obsoleting some messages
  --, c_match_4way_check
  , c_inv_close_tol_range_check
  , c_need_by_date_open_per_check
  , c_promise_date_open_per_check
  , c_ship_to_org_null_check
  , c_ship_to_loc_null_check
  , c_ship_num_gt_zero
  , c_ship_num_unique_check
  , c_is_org_in_current_sob_check
  , c_ship_qty_gt_zero
  , c_ship_qty_ge_qty_exec    -- <Complex Work R12>: Combined billed/rcvd
  , c_ship_amt_gt_zero
  , c_ship_amt_ge_amt_exec    -- <Complex Work R12>: Combined billed/rcvd
  , c_ship_sec_qty_gt_zero       -- OPM Integration R12
  , c_ship_qtys_within_deviation -- OPM Integration R12
  , c_unit_of_measure_not_null -- Bug 5385686
  , c_complex_price_or_gt_zero  -- Bug 110704404
  );

-- Validation set for HTML Orders distributions.
c_html_order_distribution_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_dist_num_unique
  , c_dist_num_gt_zero
  -- < Bug:13503748 : Encumbrance ER Edit without unreserve>--
  , c_dist_qty_gt_zero --<Bug 18883269>: add back the validation for non-encumbrance case
  , c_dist_qty_ge_qty_exec    -- <Complex Work R12>: Combined billed/rcvd
  -- < Bug:13503748 : Encumbrance ER Edit without unreserve>--
  , c_dist_amt_gt_zero --<Bug 18883269>: add back the validation for non-encumbrance case
  , c_dist_amt_ge_amt_exec    -- <Complex Work R12>: Combined billed/rcvd
  , c_pjm_unit_number_effective
  , c_project_info            -- PBWC Order Phase 3: Project Validations
  , c_gl_enc_date_not_null_open
  , c_oop_enter_all_fields
  , c_check_proj_rel_validations -- Bug 5442682 : Validate project required fields. Need to validate before award data is validated.
  , c_gms_data_valid
  , c_check_fv_validations    -- ECO 4059111 : FV Validations
  --Bug 17211828 Commenting the ccid null validation as its getting called before account generation
  --if the project details are given in distributions tab
  --, c_charge_account_id_null --Bug 16208248 Need to validate charge account
  --Bug 16856753 : Need to do a full validation of the charge account except for the null case as it
  --is handled in Bug 16208248. Also, null validation and full validation occur at different times in the flow.
  --So, its better to have two separate functions rather than trying to figure out from which point in the flow,
  --a call to null+full function is made.
  , c_charge_account_id_full

  --Fix for 17642274 and 17609241
  --, c_gdf_attributes  <Bug 18900534>:Moved this validation to Submit
  );

-- Validation set for HTML Agreement headers.
c_html_agmt_header_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    -- Bug# 4779226 remove c_warn_supplier_on_hold from header check
    c_rate_gt_zero
  , c_rate_combination_valid
  , c_fax_email_address_valid
  , c_doc_num_chars_valid
  , c_doc_num_unique
  , c_price_update_tol_ge_zero
  , c_amount_limit_ge_zero
  , c_amt_limit_ge_amt_agreed
  , c_amount_agreed_ge_zero
  , c_amount_agreed_not_null
  , c_effective_le_expiration
  -- Bug # 13037340, c_effective_from_le_order_date
  , c_effective_to_ge_order_date
  -- Bug # 13037340, c_contract_start_le_order_date
  , c_contract_end_ge_order_date
  , c_agent_id_not_null
  , c_hdr_ship_to_loc_not_null
  , c_vendor_id_not_null
  , c_vendor_site_id_not_null
  , c_segment1_not_null
  , c_ship_via_lookup_code_valid -- bug 9213424
  );

-- Validation set for HTML Agreement lines.
c_html_agmt_line_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_line_num_gt_zero
  , c_line_num_unique
  , c_item_id_not_null
  , c_unit_price_ge_zero
  , c_temp_labor_job_id_not_null
  , c_category_id_not_null
  , c_validate_category  -- bug 8633959
  , c_validate_item  -- bug 14075368
  , c_item_description_not_null
  , c_unit_meas_not_null
  , c_expiration_ge_blanket_start
  , c_expiration_le_blanket_end
  , c_line_type_id_not_null
  , c_from_line_id_not_null
  , c_src_doc_line_not_null
  );

-- Validation set for HTML Agreement GA org assignments.
c_html_agmt_ga_org_assign_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_assign_purch_org_not_null
  , c_assign_vendor_site_not_null
  );

-- Validation set for HTML Agreement notification controls.
c_html_agmt_notif_ctrl_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_notif_start_date_le_end_date
  , c_notif_percent_le_one_hundred
  , c_notif_amount_gt_zero
  , c_notif_amount_not_null
  , c_notif_start_date_not_null
  );

-- Validation set for HTML Agreement price differentials.
c_html_agmt_price_diff_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_unique_price_diff_num
  , c_price_diff_num_gt_zero
  , c_unique_price_type
  , c_max_mul_ge_zero
  , c_max_mul_ge_min_mul
  , c_min_mul_ge_zero
  );

-- Validation set for HTML Agreement price breaks.
c_html_agmt_price_break_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_ship_num_gt_zero
  , c_ship_num_unique_check
  , c_at_least_one_required_field
  , c_price_discount_in_percent
  , c_price_override_gt_zero
  , c_price_break_qty_ge_zero
  , c_price_break_start_le_end
  , c_break_start_ge_blanket_start
  , c_break_start_le_blanket_end
  , c_break_start_le_expiration
  , c_break_end_le_expiration
  , c_break_end_ge_blanket_start
  , c_break_end_le_blanket_end
  );

-- Validation set for HTML Agreement distributions.
c_html_agmt_distribution_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_amount_to_encumber_ge_zero
  , c_budget_account_id_not_null
  , c_gl_enc_date_not_null_open
  , c_unencum_amt_le_amt_to_encum
  );

-- Used to validate that a change to the unit price is allowed.
c_allow_unit_price_change_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_no_dists_reserved
  , c_accruals_allow_update
  , c_no_timecards_exist
  , c_no_pending_receipts
  , c_retro_account_allows_update
  , c_no_unvalidated_debit_memo --<Bug 18372756>
  -- ECO# 4708990/4586199: Obsoleting some messages
  --, c_warn_amt_based_notif_ctrls
  );

-- Validation set for HTML Price Adjustments
c_html_price_adjustments_vs CONSTANT PO_TBL_VARCHAR2000 :=
  PO_TBL_VARCHAR2000(
    c_change_reason_code_not_null
  , c_change_reason_text_not_null
  );

----------------------------------------------------------------------------
-- PDOI Validation Common Set Definitions
----------------------------------------------------------------------------
  c_pdoi_header_common_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_po_header_id,
                          c_end_date,
                          c_type_lookup_code,
                          c_revision_num,
                          c_document_num,
                          c_currency_code,
                          c_rate_info,
                          c_agent_id,
                          c_vendor_info,
                          c_ship_to_location_id,
                          c_bill_to_location_id,
                          c_last_updated_by,
                          c_last_update_date,
                          c_release_num,
                          c_po_release_id,
                          c_release_date,
                          c_revised_date,
                          c_printed_date,
                          c_closed_date,
                          c_terms_id_header,
                          c_ship_via_lookup_code,
                          c_fob_lookup_code,
                          c_freight_terms_lookup_code,
                          c_shipping_control,
                          c_approval_status,
                          c_acceptance_required_flag);

  c_pdoi_line_common_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_release_num_null,
                          c_po_release_id_null,
                          c_closed_date_null,
                          c_contractor_name,
                          c_order_type_lookup_code,
                          c_job_id,
                          c_job_business_group_id,
                          c_item_description,
                          c_category_id,
                          c_category_id_null,
                          c_hazard_class_id,
                          c_un_number_id,
                          c_unit_meas_lookup_code,
                          c_item_id_not_null,
                          c_item_id,
                          c_item_revision,
                          c_line_type_id,
                          c_quantity,
                          c_amount,
                          c_rate_type,
                          c_line_num,
                          c_po_line_id,
                          c_price_type_lookup_code,
                          c_line_secondary_quantity);

  c_pdoi_line_update_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_uom_update,
                          c_unit_price_update,
                          c_amount_update,  -- bug 5258790
                          c_item_desc_update,
                          c_ip_category_id_update,
                          c_category_id_update);


  c_pdoi_line_loc_common_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_shipment_need_by_date,
                          c_shipment_quantity,
                          c_ship_to_organization_id,
                          c_terms_id_line_loc,
                          c_shipment_num,
                          c_line_loc_secondary_quantity,
                          c_tax_name);

  c_pdoi_dist_common_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_dist_amount_ordered,
                          c_dist_quantity_ordered,
                          c_dist_destination_org_id,
                          c_dist_deliver_to_location_id,
                          c_dist_deliver_to_person_id,
                          c_dist_destination_type_code,
                          c_dist_destination_subinv,
                          c_dist_wip_entity_id,
                          c_prevent_encumberance_flag,
                          c_gl_encumbered_date, --Bug 18907904
                          c_charge_account_id,
                          c_budget_account_id,
                          c_accrual_account_id,
                          c_variance_account_id,
                          c_project_acct_context,
                          c_project_info,
                          c_tax_recovery_override_flag,
                          c_gdf_attributes,  -- Bug 14610858 Bug 19576779 :Reverted changes done in bug 18900534
                          c_oke_contract_line, -- <PDOI Enhancement Bug#17063664>
                          c_oke_contract_del); -- <PDOI Enhancement Bug#17063664>

  c_pdoi_price_diff_common_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_price_type,
                          c_multiple_price_diff,
                          c_entity_type,
                          c_multiplier,
                          c_min_multiplier,
                          c_max_multiplier,
                          c_price_diff_style_info);

----------------------------------------------------------------------------
-- PDOI Set Definitions for Blanket PO
----------------------------------------------------------------------------
  c_pdoi_header_blanket_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_confirming_order_flag,
                          c_acceptance_due_date,
                          c_amount_agreed,
                          c_amount_limit,
                          c_firm_status_lookup_header,
                          c_cancel_flag,
                          c_closed_code,
                          c_print_count,
                          c_frozen_flag,
                          c_amount_to_encumber,
                          c_style_id);


  c_pdoi_line_blanket_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_global_agreement_flag,
                          c_capital_expense_flag,
                          c_price_break_lookup_code,
                          c_not_to_exceed_price,
                          c_amount_blanket,
                          c_expiration_date_blanket,
                          c_over_tolerance_err_flag_null,
                          c_ip_category_id,
                          c_line_secondary_uom,
                          c_line_preferred_grade,
                          c_line_style_related_info,
                          c_negotiated_by_preparer);

  c_pdoi_line_blanket_update_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_negotiated_by_prep_update);


  c_pdoi_line_loc_blanket_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_shipment_effective_dates,
                          c_shipment_type_blanket,
                          c_at_least_one_required_field,
                          c_need_by_date_null,
                          c_firm_flag_null,
                          c_freight_carrier_null,
                          c_fob_lookup_code_null,
                          c_freight_terms_lookup_null,
                          c_qty_rcv_tolerance_null,
                          c_receipt_required_flag_null,
                          c_inspection_reqd_flag_null,
                          c_receipt_days_exception_null,
                          c_invoice_close_toler_null,
                          c_receive_close_toler_null,
                          c_days_early_rcpt_allowed_null,
                          c_days_late_rcpt_allowed_null,
                          c_enfrce_ship_to_loc_code_null,
                          c_allow_sub_receipts_flag_null,
                          c_promised_date_null,
                          c_receiving_routing_null,
                          c_line_loc_secondary_uom,
                          c_line_loc_preferred_grade,
                          c_line_loc_style_related_info,
						  c_price_break);

----------------------------------------------------------------------------
--<PDOI Enhancement Bug#17063664>
-- PDOI Set Definitions for Contract
----------------------------------------------------------------------------
  c_pdoi_header_contract_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_confirming_order_flag,
                          c_acceptance_due_date,
                          c_amount_agreed,
                          c_amount_limit,
                          c_firm_status_lookup_header,
                          c_cancel_flag,
                          c_closed_code,
                          c_print_count,
                          c_frozen_flag,
                          c_style_id);

----------------------------------------------------------------------------
-- PDOI Set Definitions for Standard PO
----------------------------------------------------------------------------
  c_pdoi_header_standard_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_confirming_order_flag,
                          c_acceptance_due_date,
                          c_firm_status_lookup_header,
                          c_cancel_flag,
                          c_closed_code,
                          c_print_count,
                          c_frozen_flag,
                          c_style_id);

  c_pdoi_line_standard_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_over_tolerance_error_flag,
                          c_capital_expense_flag,
                          c_not_to_exceed_price,
                          c_start_date_standard,
                          c_item_id_standard,
                          c_quantity_standard,
                          c_amount_standard,
                          c_ip_category_id_null,
                          c_line_secondary_uom,
                          c_line_preferred_grade,
                          c_line_style_related_info,
                          c_negotiated_by_preparer,
                          -- <PDOI for Complex PO Project: Start>
                          c_pdoi_qty_ge_qty_mstone_exec,
                          c_pdoi_prc_ge_prc_mstone_exec,
                          c_pdoi_recoupment_range_check,
                          c_pdoi_retainage_range_check,
                          c_pdoi_prog_pay_range_check,
                          c_pdoi_max_retain_amt_ge_zero,
                          c_pdoi_max_retain_amt_ge_retnd,
                          c_pdoi_amt_ge_line_advance_amt,
                          c_pdoi_complex_po_att_check,
                          -- <PDOI for Complex PO Project: End>
                          -- <PDOI Enhancement Bug#17063664 Start>
                          c_src_blanket_exists,
                          c_src_contract_exists,
                          c_src_only_one,
                          c_src_line_not_null,
                          c_req_exists,
                          c_validate_req_reference,
                          c_validate_source_doc,
                          c_oke_contract_header,
                          c_oke_contract_version
                          -- <PDOI Enhancement Bug#17063664 End>
			  );


  c_pdoi_line_loc_standard_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_enforce_ship_to_loc_code,
                          c_shipment_type_standard,
                          c_allow_sub_receipts_flag,
                          c_days_early_receipt_allowed,
                          c_receipt_days_exception_code,
                          c_invoice_close_tolerance,
                          c_receive_close_tolerance,
                          c_receiving_routing_id,
                          c_accrue_on_receipt_flag,
                          c_shipment_promised_date,
                          c_line_loc_secondary_uom,
                          c_line_loc_preferred_grade,
			     -- <PDOI for Complex PO Project: Start>
                          c_pdoi_amt_ge_ship_advance_amt,
                          c_pdoi_shipment_amount,
                          c_pdoi_payment_type,
                          -- <PDOI for Complex PO Project: End>
                          --<PDOI Enhancement Bug#17063664>
                          c_inspection_reqd_flag,
                          c_days_late_receipt_allowed
                         );

-- <<PDOI Enhancement Bug#17063664 Start>>
  -- Cross OU Validation Set
  c_cross_ou_validations CONSTANT PO_TBL_VARCHAR2000
    := PO_TBL_VARCHAR2000(c_cross_ou_vmi_check,
                          c_cross_ou_consigned_check,
                          c_cross_ou_item_validity_check,
                          c_cross_ou_pa_project_check,
                          c_cross_ou_dest_ou_check,
                          c_cross_ou_txn_flow_check,
                          c_cross_ou_services_check,
                          c_cross_ou_cust_loc_check,
                          c_cross_ou_ga_enc_check);

  c_source_doc_bpa_validations CONSTANT PO_TBL_VARCHAR2000
    := PO_TBL_VARCHAR2000 ( c_src_doc_global
                          , c_src_doc_vendor
                          , c_src_doc_vendor_site
                          , c_src_doc_approved
                          , c_src_doc_hold
                          , c_src_doc_currency
                          , c_src_doc_closed_code
                          , c_src_doc_cancel
                          , c_src_doc_frozen
                          , c_src_bpa_expiry_date
                          , c_src_doc_style
                          , c_src_line_item
                          , c_src_line_item_rev
                          , c_src_line_cancel
                          , c_src_line_closed
                          , c_src_line_order_type
                          , c_src_line_purchase_basis
                          , c_src_line_matching_basis
                          , c_src_line_uom
                          , c_src_line_job
                          , c_src_allow_price_ovr);

  c_source_doc_cpa_validations CONSTANT PO_TBL_VARCHAR2000
    := PO_TBL_VARCHAR2000 ( c_src_doc_global
                          , c_src_doc_vendor
                          , c_src_doc_vendor_site
                          , c_src_doc_approved
                          , c_src_doc_hold
                          , c_src_doc_currency
                          , c_src_doc_closed_code
                          , c_src_doc_cancel
                          , c_src_doc_frozen
                          , c_src_cpa_expiry_date
                          , c_src_doc_style);

  c_req_reference_validations  CONSTANT PO_TBL_VARCHAR2000
    := PO_TBL_VARCHAR2000 ( c_validate_no_ship_dist
                          , c_validate_req_status
                          , c_reqs_in_pool_flag
                          , c_reqs_cancel_flag
                          , c_reqs_closed_code
                          , c_reqs_mdfd_by_agt
                          , c_reqs_at_srcng_flg
                          , c_reqs_line_loc
                          , c_validate_req_item
                          , c_validate_req_job
                          , c_validate_req_pur_bas
                          , c_validate_req_mat_bas
                          , c_validate_pcard
                          , c_validate_reqorg_srcdoc
                          , c_validate_style_dest
                          , c_validate_style_line
                          , c_validate_style_pcard
                          , c_validate_req_vmi_bpa
                          , c_validate_req_vmi_sup
                          , c_validate_req_on_spo
                          , c_validate_req_pcard_sup
                          , c_validate_cross_ou);

  c_pdoi_line_standard_update_vs CONSTANT PO_TBL_VARCHAR2000
    := PO_TBL_VARCHAR2000 ( c_src_blanket_exists,
                            c_src_contract_exists,
                            c_src_only_one,
                            c_src_line_not_null,
                            c_req_exists,
                            c_validate_req_reference,
                            c_validate_source_doc);

  c_pdoi_line_standard_match_vs CONSTANT PO_TBL_VARCHAR2000
    := PO_TBL_VARCHAR2000 (c_req_exists,
                           c_validate_req_reference);

-- <<PDOI Enhancement Bug#17063664 End>>

----------------------------------------------------------------------------
-- PDOI Set Definitions for Quotation
----------------------------------------------------------------------------
  c_pdoi_header_quotation_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_quote_warning_delay,
                          c_approval_required_flag);

  c_pdoi_line_quotation_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_over_tolerance_error_flag,
                          c_allow_price_override_null ,
                          c_negotiated_by_preparer_null,
                          c_capital_expense_flag_null,
                          c_min_release_amount_null,
                          c_market_price_null,
                          c_committed_amount_null,
                          c_ip_category_id,
                          c_negotiated_by_preparer_null,
                          c_unit_price); -- <PDOI Enhancement Bug#17063664> Removed this validation from the common set.
                                         --  and adding for quotation. As for standard/blanket price is defaulted later on.

  c_pdoi_line_loc_quotation_vs CONSTANT po_tbl_varchar2000
    := po_tbl_varchar2000(c_qty_rcv_exception_code,
                          c_shipment_type_quotation,
                          c_fob_lookup_code_line_loc,
                          c_freight_terms_line_loc,
                          c_freight_carrier_line_loc,
                          c_firm_flag_null,
                          c_promised_date_null,
                          c_receipt_days_exception_null,
                          c_invoice_close_toler_null,
                          c_receive_close_toler_null,
                          c_days_early_rcpt_allowed_null,
                          c_days_late_rcpt_allowed_null,
                          c_enfrce_ship_to_loc_code_null,
                          c_allow_sub_receipts_flag_null,
                          c_receiving_routing_null,
                          c_need_by_date_null,
                          c_shipment_price_override,  -- <PDOI Enhancement Bug#17063664> Removed these validations from the common set.
                          c_shipment_price_discount); -- and adding for quotation. As for standard/blanket price is defaulted later on.


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULT_SET_ID_S
--Locks: None.
--Function:
--  Retrieves the next value from the sequence PO_VALIDATION_RESULT_SET_ID_S.
--Returns:
--  The next sequence value.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION next_result_set_id
RETURN NUMBER
IS
d_mod CONSTANT VARCHAR2(100) := D_next_result_set_id;
l_nextval NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod);
END IF;

SELECT PO_VALIDATION_RESULT_SET_ID_S.NEXTVAL
INTO l_nextval
FROM DUAL
;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_return(d_mod,l_nextval);
END IF;

RETURN l_nextval;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END next_result_set_id;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS
--Locks: None.
--Function:
--  Deletes the specified result set from the
--  PO_VALIDATION_RESULTS table.
--Parameters:
--IN:
--p_result_set_id
--  The result_set_id identifier into PO_VALIDATION_RESULTS.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE delete_result_set(
  p_result_set_id IN NUMBER
)
IS
d_mod CONSTANT VARCHAR2(100) := D_delete_result_set;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_result_set_id',p_result_set_id);
END IF;

DELETE FROM PO_VALIDATION_RESULTS_GT
WHERE result_set_id = p_result_set_id
;

IF PO_LOG.d_proc THEN
  PO_LOG.stmt(d_mod,100,'Deleted result set.  SQL%ROWCOUNT',SQL%ROWCOUNT);
  PO_LOG.proc_end(d_mod);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END delete_result_set;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS
--Locks: None.
--Function:
--  Autonomously deletes the specified result set from the
--  PO_VALIDATION_RESULTS table.
--Parameters:
--IN:
--p_result_set_id
--  The result_set_id identifier into PO_VALIDATION_RESULTS.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE delete_result_set_auto(
  p_result_set_id IN NUMBER
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
d_mod CONSTANT VARCHAR2(100) := D_delete_result_set_auto;
d_position NUMBER := 0;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_result_set_id',p_result_set_id);
END IF;

d_position := 1;

delete_result_set(p_result_set_id => p_result_set_id);

d_position := 100;

COMMIT;

d_position := 200;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;

END delete_result_set_auto;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS
--Locks: None.
--Function:
--  Autonomously inserts and commits the input data into the
--  PO_VALIDATION_RESULTS table.
--Parameters:
--IN:
--  The data to insert into the table.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE commit_validation_results_auto(
  p_result_id_tbl                 IN PO_TBL_NUMBER
, p_result_set_id_tbl             IN PO_TBL_NUMBER
, p_result_type_tbl               IN PO_TBL_VARCHAR30
, p_table_name_tbl                IN PO_TBL_VARCHAR30
, p_table_id_tbl                 IN PO_TBL_NUMBER
, p_message_application_tbl       IN PO_TBL_VARCHAR30
, p_message_name_tbl              IN PO_TBL_VARCHAR30
, p_column_name_tbl               IN PO_TBL_VARCHAR30
, p_token1_name_tbl               IN PO_TBL_VARCHAR30
, p_token1_value_tbl              IN PO_TBL_VARCHAR2000
, p_token2_name_tbl               IN PO_TBL_VARCHAR30
, p_token2_value_tbl              IN PO_TBL_VARCHAR2000
, p_token3_name_tbl               IN PO_TBL_VARCHAR30
, p_token3_value_tbl              IN PO_TBL_VARCHAR2000
, p_token4_name_tbl               IN PO_TBL_VARCHAR30
, p_token4_value_tbl              IN PO_TBL_VARCHAR2000
, p_token5_name_tbl               IN PO_TBL_VARCHAR30
, p_token5_value_tbl              IN PO_TBL_VARCHAR2000
, p_token6_name_tbl               IN PO_TBL_VARCHAR30
, p_token6_value_tbl              IN PO_TBL_VARCHAR2000
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
d_mod CONSTANT VARCHAR2(100) := D_commit_validation_results_au;
d_position NUMBER := 0;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_result_id_tbl',p_result_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_result_set_id_tbl',p_result_set_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_result_type_tbl',p_result_type_tbl);
  PO_LOG.proc_begin(d_mod,'p_table_name_tbl',p_table_name_tbl);
  PO_LOG.proc_begin(d_mod,'p_table_id_tbl',p_table_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_message_application_tbl',p_message_application_tbl);
  PO_LOG.proc_begin(d_mod,'p_message_name_tbl',p_message_name_tbl);
  PO_LOG.proc_begin(d_mod,'p_column_name_tbl',p_column_name_tbl);
  PO_LOG.proc_begin(d_mod,'p_token1_name_tbl',p_token1_name_tbl);
  PO_LOG.proc_begin(d_mod,'p_token1_value_tbl',p_token1_value_tbl);
  PO_LOG.proc_begin(d_mod,'p_token2_name_tbl',p_token2_name_tbl);
  PO_LOG.proc_begin(d_mod,'p_token2_value_tbl',p_token2_value_tbl);
  PO_LOG.proc_begin(d_mod,'p_token3_name_tbl',p_token3_name_tbl);
  PO_LOG.proc_begin(d_mod,'p_token3_value_tbl',p_token3_value_tbl);
  PO_LOG.proc_begin(d_mod,'p_token4_name_tbl',p_token4_name_tbl);
  PO_LOG.proc_begin(d_mod,'p_token4_value_tbl',p_token4_value_tbl);
  PO_LOG.proc_begin(d_mod,'p_token5_name_tbl',p_token5_name_tbl);
  PO_LOG.proc_begin(d_mod,'p_token5_value_tbl',p_token5_value_tbl);
  PO_LOG.proc_begin(d_mod,'p_token6_name_tbl',p_token6_name_tbl);
  PO_LOG.proc_begin(d_mod,'p_token6_value_tbl',p_token6_value_tbl);
END IF;

d_position := 1;

FORALL i IN 1 .. p_result_set_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, result_type
, entity_type
, entity_id
, message_application
, message_name
, column_name
, token1_name
, token1_value
, token2_name
, token2_value
, token3_name
, token3_value
, token4_name
, token4_value
, token5_name
, token5_value
, token6_name
, token6_value
)
VALUES
( p_result_set_id_tbl(i)
, p_result_type_tbl(i)
, p_table_name_tbl(i)
, p_table_id_tbl(i)
, p_message_application_tbl(i)
, p_message_name_tbl(i)
, p_column_name_tbl(i)
, p_token1_name_tbl(i)
, p_token1_value_tbl(i)
, p_token2_name_tbl(i)
, p_token2_value_tbl(i)
, p_token3_name_tbl(i)
, p_token3_value_tbl(i)
, p_token4_name_tbl(i)
, p_token4_value_tbl(i)
, p_token5_name_tbl(i)
, p_token5_value_tbl(i)
, p_token6_name_tbl(i)
, p_token6_value_tbl(i)
);

d_position := 100;

IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'Inserted data. SQL%ROWCOUNT',SQL%ROWCOUNT);
END IF;

COMMIT WORK;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;

END commit_validation_results_auto;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS
--Locks: PO_VALIDATION_RESULTS
--Function:
--  Replaces the old result_set_id with the new one.
--Parameters:
--IN:
--p_old_result_set_id
--  The result_set_id of the rows that should be updated.
--p_new_result_set_id
--  The id with which to replace the rows' result_set_id.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE replace_result_set_id(
  p_old_result_set_id   IN NUMBER
, p_new_result_set_id   IN NUMBER
)
IS
d_mod CONSTANT VARCHAR2(100) := D_replace_result_set_id;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_old_result_set_id',p_old_result_set_id);
  PO_LOG.proc_begin(d_mod,'p_new_result_set_id',p_new_result_set_id);
END IF;

-- Fix the result_set_id, message_application, and message_name.

UPDATE PO_VALIDATION_RESULTS_GT
SET
  result_set_id = p_new_result_set_id
WHERE
    result_set_id = p_old_result_set_id
;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END replace_result_set_id;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS
--Locks: PO_VALIDATION_RESULTS
--Function:
--  Extracts records from PO_VALIDATION_RESULTS, deletes them, and then
--  inserts them again in an autonomous transaction.
--  Also provides default values to some columns.
--Parameters:
--IN:
--p_result_set_id
--  Identifies the rows to operate on.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE commit_result_set(
  p_result_set_id   IN NUMBER
)
IS
d_mod CONSTANT VARCHAR2(100) := D_commit_result_set;
d_position NUMBER := 0;

l_result_id_tbl PO_TBL_NUMBER;
l_result_set_id_tbl PO_TBL_NUMBER;
l_result_type_tbl PO_TBL_VARCHAR30;
l_table_name_tbl PO_TBL_VARCHAR30;
l_table_id_tbl PO_TBL_NUMBER;
l_message_application_tbl PO_TBL_VARCHAR30;
l_message_name_tbl PO_TBL_VARCHAR30;
l_column_name_tbl PO_TBL_VARCHAR30;
l_token1_name_tbl PO_TBL_VARCHAR30;
l_token1_value_tbl PO_TBL_VARCHAR2000;
l_token2_name_tbl PO_TBL_VARCHAR30;
l_token2_value_tbl PO_TBL_VARCHAR2000;
l_token3_name_tbl PO_TBL_VARCHAR30;
l_token3_value_tbl PO_TBL_VARCHAR2000;
l_token4_name_tbl PO_TBL_VARCHAR30;
l_token4_value_tbl PO_TBL_VARCHAR2000;
l_token5_name_tbl PO_TBL_VARCHAR30;
l_token5_value_tbl PO_TBL_VARCHAR2000;
l_token6_name_tbl PO_TBL_VARCHAR30;
l_token6_value_tbl PO_TBL_VARCHAR2000;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_result_set_id',p_result_set_id);
END IF;

d_position := 1;

-- Retrieve the data from the validation results table
-- and commit it back, autonomously.

SELECT
  result_set_id
, NVL(result_type,c_result_type_FAILURE)
, entity_type
, entity_id
, NVL(message_application,c_PO)
, message_name
, column_name
, token1_name
, token1_value
, token2_name
, token2_value
, token3_name
, token3_value
, token4_name
, token4_value
, token5_name
, token5_value
, token6_name
, token6_value
BULK COLLECT INTO
  l_result_set_id_tbl
, l_result_type_tbl
, l_table_name_tbl
, l_table_id_tbl
, l_message_application_tbl
, l_message_name_tbl
, l_column_name_tbl
, l_token1_name_tbl
, l_token1_value_tbl
, l_token2_name_tbl
, l_token2_value_tbl
, l_token3_name_tbl
, l_token3_value_tbl
, l_token4_name_tbl
, l_token4_value_tbl
, l_token5_name_tbl
, l_token5_value_tbl
, l_token6_name_tbl
, l_token6_value_tbl
FROM
  PO_VALIDATION_RESULTS_GT
WHERE
    result_set_id = p_result_set_id
;

d_position := 100;
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'Retrieved data.');
END IF;

delete_result_set(p_result_set_id => p_result_set_id);

d_position := 200;

commit_validation_results_auto(
  p_result_id_tbl => l_result_id_tbl
, p_result_set_id_tbl => l_result_set_id_tbl
, p_result_type_tbl => l_result_type_tbl
, p_table_name_tbl => l_table_name_tbl
, p_table_id_tbl => l_table_id_tbl
, p_message_application_tbl => l_message_application_tbl
, p_message_name_tbl => l_message_name_tbl
, p_column_name_tbl => l_column_name_tbl
, p_token1_name_tbl => l_token1_name_tbl
, p_token1_value_tbl => l_token1_value_tbl
, p_token2_name_tbl => l_token2_name_tbl
, p_token2_value_tbl => l_token2_value_tbl
, p_token3_name_tbl => l_token3_name_tbl
, p_token3_value_tbl => l_token3_value_tbl
, p_token4_name_tbl => l_token4_name_tbl
, p_token4_value_tbl => l_token4_value_tbl
, p_token5_name_tbl => l_token5_name_tbl
, p_token5_value_tbl => l_token5_value_tbl
, p_token6_name_tbl => l_token6_name_tbl
, p_token6_value_tbl => l_token6_value_tbl
);

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;

END commit_result_set;



/**

-------------------------------------------
General contract for validation subroutines
-------------------------------------------

Each validation subroutine must have a signature
containing the following output parameters:

x_result_set_id IN OUT NOCOPY NUMBER
x_result_type   OUT NOCOPY    VARCHAR2

The validation subroutine may take in any parameters
from the available input to validate_set.
Most subroutines will only require a small set of parameters,
and can be coded as such.

Example subroutine call:

CASE l_val
  ...

  WHEN c_unit_price_ge_zero THEN
    PO_PRICE_HELPER.unit_price_ge_zero(
      p_line_id_tbl => p_lines.po_line_id
    , p_draft_id_tbl => p_lines.draft_id
    , p_unit_price_tbl => p_lines.unit_price
    , x_result_set_id => l_result_set_id
    , x_result_type => l_result_type
    );

  WHEN ...

END CASE;


The validation subroutine will perform the required validation
on the data and insert results into the PO_VALIDATION_RESULTS table.

Parameter descriptions:

x_result_set_id
  This parameter identifies rows in PO_VALIDATION_RESULTS
  that have been generated by the validation procedure.
  The following columns must be populated
  by the validation procedure:

    result_id
      PO_VALIDATION_RESULT_ID_S.nextval

    result_set_id
      x_result_set_id

    table_name
    table_id
      The name of the table on which the validation is acting,
      and the primary key of the table row.

    column_name
      The name of the column of the pending table to which
      this validation result corresponds.

    result_type
      This should be populated with the default interpretation
      of this result (WARNING, ERROR, FATAL, etc.).
      If this column is not populated, ERROR should be assumed.

    message_application
    message_name
      The dictionary message for this result.
      If message_application is not populated, PO should be assumed.

  Additionally, the validation procedure must populate the columns
  token1_name, token1_value, token2_name, token2_value, ...
  if any tokens are used in the dictionary message.

x_result_type
  This parameter contains a summary of the results.
  If all validations are successful and no results have been
  generated, it will be SUCCESS.  Otherwise, it will be
  equal to the most serious result_type of the validation
  results.


*/



----------------------------------------------------------------------------
--Pre-reqs: None.
--Modifies:
--  PO_VALIDATION_RESULTS
--Locks: None.
--Function:
--  Executes a set of validations in the order determined
--  by the validation set list.
--  Validation results will be stored in PO_VALIDATION_RESULTS.
--
--  Calls to validate_set may be chained together,
--  as the x_result_set_id and x_result_type parameters
--  are IN OUT.
--
--  Example:
--
--  <<DISTRIBUTION_VALIDATIONS>>
--  BEGIN
--
--    -- Common validations
--
--    validate_set(
--      p_validation_set => c_dist_common_val_set
--    , p_distributions => l_dist_id_tbl
--    , x_result_set_id => l_result_set_id
--    , x_result_type => l_result_type
--    );
--
--    IF (    l_result_type <> c_RESULT_TYPE_SUCCESS
--        AND l_projects_enabled_flag )
--    THEN
--
--      -- Projects-specific validations
--
--      validate_set(
--        p_validation_set => c_dist_projects_val_set
--      , p_distributions => l_dist_id_tbl
--      , x_result_set_id => l_result_set_id
--      , x_result_type => l_result_type
--      );
--
--    END IF;
--
--  END DISTRIBUTION_VALIDATIONS;
--
--Parameters:
--IN:
--p_validation_set
--  Specifies the validations to perform.
--p_headers
--p_lines
--p_line_locations
--p_distributions
--p_price_differentials
--p_ga_org_assignments
--p_notification_controls
--  The data that needs to be validated.
--  Only the data that is required for the incoming validation set
--  is necessary.
-- p_source_doc -- Source doc info
-- p_req_reference  -- Req reference info
--p_autocommit_results_flag
--  Indicates whether or not the results need to be autonomously committed.
--    g_parameter_NO  - There is no need to commit the results.
--    g_parameter_YES - The results need to be committed.
--p_calling_program
--  Identifier of the program that is invoking the validation set.
--  This can be used by validation subroutines to perform differently
--  for different flows.  For example, this can be used to substitute
--  different messages or tokens for OA vs. PDOI, or to interpret
--  warnings as errors in different cases, etc.
--  Use one of the c_program_XXX constants.
--p_stopping_result_type
--  Indicates that if this result type is encountered,
--  processing should stop and return.
--  Use one of the c_result_type_XXX variables.
--  For no stopping, use NULL.
--p_parameter_name_tbl
--p_parameter_value_tbl
--  Contain additional parameters that may be passed to individual
--  validation subroutines.
--  The parameter names and associated value should be located
--  at identical indexes in the input tables.
--IN OUT:
--x_result_set_id
--  Identifier for the output results in PO_VALIDATION_RESULTS.
--  If a value is passed in, it will be used and unchanged.
--  If NULL, a distinct value will be retrieved.
--x_result_type
--  Provides a summary of the validation results.
--  An input code will never be turned into a better result,
--  but may be turned into a worse result
--  (ERROR will not become SUCCESS, but WARNING may become ERROR).
----------------------------------------------------------------------------
PROCEDURE validate_set(
  p_validation_set        IN PO_TBL_VARCHAR2000
, p_headers               IN PO_HEADERS_VAL_TYPE DEFAULT NULL
, p_lines                 IN PO_LINES_VAL_TYPE DEFAULT NULL
, p_line_locations        IN PO_LINE_LOCATIONS_VAL_TYPE DEFAULT NULL
, p_distributions         IN PO_DISTRIBUTIONS_VAL_TYPE DEFAULT NULL
, p_price_differentials   IN PO_PRICE_DIFF_VAL_TYPE DEFAULT NULL
, p_ga_org_assignments    IN PO_GA_ORG_ASSIGN_VAL_TYPE DEFAULT NULL
, p_notification_controls IN PO_NOTIFICATION_CTRL_VAL_TYPE DEFAULT NULL
, p_price_adjustments     IN PO_PRICE_ADJS_VAL_TYPE DEFAULT NULL --Enhanced Pricing
, p_source_doc            IN PO_SOURCE_DOC_VAL_TYPE DEFAULT NULL -- <PDOI Enhancement Bug#17063664>
, p_req_reference         IN PO_REQ_REF_VAL_TYPE DEFAULT NULL -- <PDOI Enhancement Bug#17063664>
, p_autocommit_results_flag IN VARCHAR2 DEFAULT NULL
, p_calling_program       IN VARCHAR2 DEFAULT NULL
, p_stopping_result_type  IN VARCHAR2 DEFAULT NULL
, p_parameter_name_tbl    IN PO_TBL_VARCHAR2000 DEFAULT NULL
, p_parameter_value_tbl   IN PO_TBL_VARCHAR2000 DEFAULT NULL
, x_result_type           IN OUT NOCOPY VARCHAR2
, x_result_set_id         IN OUT NOCOPY NUMBER
, x_results               IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
)
IS
d_mod CONSTANT VARCHAR2(100) := D_validate_set;
d_position NUMBER := 0;
d_stmt CONSTANT BOOLEAN := PO_LOG.d_stmt;

l_result_set_id NUMBER;
l_result_type VARCHAR2(30);
l_val VARCHAR2(2000);

l_result_rank NUMBER;
l_new_rank NUMBER;
l_stop_rank NUMBER;

l_create_or_update_item     VARCHAR2(1);
l_chart_of_account_id       NUMBER;
l_po_encumbrance_flag       VARCHAR2(1);
l_operating_unit            NUMBER;
l_expense_accrual_code      PO_SYSTEM_PARAMETERS.expense_accrual_code%TYPE;
l_inventory_org_id          NUMBER;
l_doc_type                  VARCHAR2(25);
l_set_of_books_id           NUMBER;
l_func_currency_code        GL_SETS_OF_BOOKS.currency_code%TYPE;
l_federal_instance          VARCHAR2(1);
l_allow_tax_code_override   VARCHAR2(1);
l_allow_tax_rate_override   VARCHAR2(1);
l_manual_po_num_type        PO_SYSTEM_PARAMETERS.manual_po_num_type%TYPE;
l_manual_quote_num_type     PO_SYSTEM_PARAMETERS.manual_quote_num_type%TYPE;
l_name_value_pair po_name_value_pair_tab;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_validation_set',p_validation_set);
  PO_LOG.proc_begin(d_mod,'p_headers.org_id',p_headers.org_id);
  PO_LOG.proc_begin(d_mod,'p_headers.ship_to_location_id',p_headers.ship_to_location_id);
  PO_LOG.proc_begin(d_mod,'p_autocommit_results_flag',p_autocommit_results_flag);
  PO_LOG.proc_begin(d_mod,'p_calling_program',p_calling_program);
  PO_LOG.proc_begin(d_mod,'p_stopping_result_type',p_stopping_result_type);
  PO_LOG.proc_begin(d_mod,'p_parameter_name_tbl',p_parameter_name_tbl);
  PO_LOG.proc_begin(d_mod,'p_parameter_value_tbl',p_parameter_value_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
  PO_LOG.proc_begin(d_mod,'x_result_type',x_result_type);
END IF;
d_position := 1;

IF (p_parameter_name_tbl IS NOT NULL) THEN

  d_position := 2;

  FOR i IN 1 .. p_parameter_name_tbl.COUNT LOOP

    CASE p_parameter_name_tbl(i)
    WHEN 'CREATE_OR_UPDATE_ITEM' THEN
       l_create_or_update_item := p_parameter_value_tbl(i);
    WHEN 'CHART_OF_ACCOUNT_ID' THEN
       l_chart_of_account_id := TO_NUMBER(p_parameter_value_tbl(i));
    WHEN 'PO_ENCUMBRANCE_FLAG' THEN
       l_po_encumbrance_flag := p_parameter_value_tbl(i);
    WHEN 'OPERATING_UNIT' THEN
       l_operating_unit := TO_NUMBER(p_parameter_value_tbl(i));
    WHEN 'EXPENSE_ACCRUAL_CODE' THEN
       l_expense_accrual_code := p_parameter_value_tbl(i);
    WHEN 'INVENTORY_ORG_ID' THEN
       l_inventory_org_id := p_parameter_value_tbl(i);
    WHEN 'DOC_TYPE' THEN
       l_doc_type := p_parameter_value_tbl(i);
    WHEN 'SET_OF_BOOKS_ID' THEN
       l_set_of_books_id := p_parameter_value_tbl(i);
    WHEN 'FUNCTIONAL_CURRENCY_CODE' THEN
       l_func_currency_code := p_parameter_value_tbl(i);
    WHEN 'FEDERAL_INSTANCE' THEN
       l_federal_instance := p_parameter_value_tbl(i);
    WHEN 'ALLOW_TAX_CODE_OVERRIDE' THEN
       l_allow_tax_code_override := p_parameter_value_tbl(i);
    WHEN 'ALLOW_TAX_RATE_OVERRIDE' THEN
       l_allow_tax_rate_override := p_parameter_value_tbl(i);
    WHEN 'MANUAL_PO_NUM_TYPE' THEN
       l_manual_po_num_type := p_parameter_value_tbl(i);
    WHEN 'MANUAL_QUOTE_NUM_TYPE' THEN
       l_manual_quote_num_type := p_parameter_value_tbl(i);
    END CASE;

  END LOOP;

END IF;

d_position := 5;

-- Initialize the IN OUT parameters, to enable chaining of validations.

IF x_result_set_id IS NULL THEN
  x_result_set_id := next_result_set_id();
END IF;

d_position := 10;

IF (x_result_type IS NULL) THEN
  x_result_type := c_result_type_SUCCESS;
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

d_position := 20;

l_result_rank := result_type_rank(x_result_type);

d_position := 30;

l_stop_rank := result_type_rank(p_stopping_result_type);

d_position := 40;
IF d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'x_result_set_id',x_result_set_id);
  PO_LOG.stmt(d_mod,d_position,'x_result_type',x_result_type);
  PO_LOG.stmt(d_mod,d_position,'l_result_rank',l_result_rank);
  PO_LOG.stmt(d_mod,d_position,'l_stop_rank',l_stop_rank);
END IF;

-- Loop through the validation set, executing each validation in turn.

FOR i IN 1 .. p_validation_set.COUNT LOOP
  d_position := 100;

  l_val := p_validation_set(i);

  IF d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'p_validation_set('||i||')',l_val);
  END IF;

  d_position := 110;

  BEGIN

    CASE l_val

    ---------------------------------------------------------------
    -- Header Validations
    ---------------------------------------------------------------

    WHEN c_warn_supplier_on_hold THEN
      PO_VAL_HEADERS.warn_supplier_on_hold(
        p_header_id_tbl => p_headers.po_header_id
      , p_vendor_id_tbl => p_headers.vendor_id
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_rate_gt_zero THEN
      PO_VAL_HEADERS.rate_gt_zero(
        p_header_id_tbl => p_headers.po_header_id
      , p_rate_tbl => p_headers.rate
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_fax_email_address_valid THEN
      PO_VAL_HEADERS.fax_email_address_valid(
        p_header_id_tbl => p_headers.po_header_id
      , p_supplier_notif_method_tbl => p_headers.supplier_notif_method
      , p_fax_tbl => p_headers.fax
      , p_email_address_tbl => p_headers.email_address
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_rate_combination_valid THEN
      PO_VAL_HEADERS.rate_combination_valid(
        p_header_id_tbl => p_headers.po_header_id
      , p_org_id_tbl => p_headers.org_id
      , p_currency_code_tbl => p_headers.currency_code
      , p_rate_type_tbl => p_headers.rate_type
      , p_rate_date_tbl => p_headers.rate_date
      , p_rate_tbl => p_headers.rate
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_doc_num_chars_valid THEN
      PO_VAL_HEADERS.doc_num_chars_valid(
        p_header_id_tbl => p_headers.po_header_id
      , p_org_id_tbl => p_headers.org_id
      , p_segment1_tbl => p_headers.segment1
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_doc_num_unique THEN
      PO_VAL_HEADERS.doc_num_unique(
        p_header_id_tbl => p_headers.po_header_id
      , p_org_id_tbl => p_headers.org_id
      , p_segment1_tbl => p_headers.segment1
      , p_type_lookup_code_tbl => p_headers.type_lookup_code
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_price_update_tol_ge_zero THEN
      PO_VAL_HEADERS.price_update_tol_ge_zero(
        p_header_id_tbl => p_headers.po_header_id
      , p_price_update_tol_tbl => p_headers.price_update_tolerance
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_amount_limit_ge_zero THEN
      PO_VAL_HEADERS.amount_limit_ge_zero(
        p_header_id_tbl => p_headers.po_header_id
      , p_amount_limit_tbl => p_headers.amount_limit
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_amt_limit_ge_amt_agreed THEN
      PO_VAL_HEADERS.amt_limit_ge_amt_agreed(
        p_header_id_tbl => p_headers.po_header_id
      , p_blanket_total_amount_tbl => p_headers.blanket_total_amount
      , p_amount_limit_tbl => p_headers.amount_limit
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_amount_agreed_ge_zero THEN
      PO_VAL_HEADERS.amount_agreed_ge_zero(
        p_header_id_tbl => p_headers.po_header_id
      , p_blanket_total_amount_tbl => p_headers.blanket_total_amount
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_amount_agreed_not_null THEN
      PO_VAL_HEADERS.amount_agreed_not_null(
        p_header_id_tbl => p_headers.po_header_id
      , p_blanket_total_amount_tbl => p_headers.blanket_total_amount
      , p_amount_limit_tbl => p_headers.amount_limit
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_effective_le_expiration THEN
      PO_VAL_HEADERS.effective_le_expiration(
        p_header_id_tbl => p_headers.po_header_id
      , p_start_date_tbl => p_headers.start_date
      , p_end_date_tbl => p_headers.end_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_effective_from_le_order_date THEN
      PO_VAL_HEADERS.effective_from_le_order_date(
        p_header_id_tbl => p_headers.po_header_id
      , p_type_lookup_code_tbl => p_headers.type_lookup_code
      , p_start_date_tbl => p_headers.start_date
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_effective_to_ge_order_date THEN
      PO_VAL_HEADERS.effective_to_ge_order_date(
        p_header_id_tbl => p_headers.po_header_id
      , p_type_lookup_code_tbl => p_headers.type_lookup_code
      , p_end_date_tbl => p_headers.end_date
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_contract_start_le_order_date THEN
      PO_VAL_HEADERS.contract_start_le_order_date(
        p_header_id_tbl => p_headers.po_header_id
      , p_type_lookup_code_tbl => p_headers.type_lookup_code
      , p_start_date_tbl => p_headers.start_date
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_contract_end_ge_order_date THEN
      PO_VAL_HEADERS.contract_end_ge_order_date(
        p_header_id_tbl => p_headers.po_header_id
      , p_type_lookup_code_tbl => p_headers.type_lookup_code
      , p_end_date_tbl => p_headers.end_date
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_agent_id_not_null THEN
      PO_VAL_HEADERS.agent_id_not_null(
        p_header_id_tbl => p_headers.po_header_id
      , p_agent_id_tbl => p_headers.agent_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_hdr_ship_to_loc_not_null THEN
      PO_VAL_HEADERS.ship_to_loc_not_null(
        p_header_id_tbl => p_headers.po_header_id
      , p_ship_to_loc_id_tbl => p_headers.ship_to_location_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_vendor_id_not_null THEN
      PO_VAL_HEADERS.vendor_id_not_null(
        p_header_id_tbl => p_headers.po_header_id
      , p_vendor_id_tbl => p_headers.vendor_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_vendor_site_id_not_null THEN
      PO_VAL_HEADERS.vendor_site_id_not_null(
        p_header_id_tbl => p_headers.po_header_id
      , p_vendor_site_id_tbl => p_headers.vendor_site_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    --<Begin Bug# 5372769> EXCEPTION WHEN SAVE PO WO/ NUMBER IF DOCUMENT NUMBERING IS SET TO MANUAL
    WHEN c_segment1_not_null THEN
      PO_VAL_HEADERS.segment1_not_null(
        p_header_id_tbl => p_headers.po_header_id
      , p_segment1_tbl => p_headers.segment1
      , p_org_id_tbl => p_headers.org_id
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );
    --<End 5372769>
 --<Start Bug 9213424> Error when the ship_via field has an invalid value.
    WHEN c_ship_via_lookup_code_valid THEN
     PO_VAL_HEADERS.ship_via_lookup_code_valid(
        p_header_id_tbl=> p_headers.po_header_id,
        p_ship_via_lookup_code_tbl     => p_headers.ship_via_lookup_code,
		--Bug 12409257 begin. Bug 13771850 Revert the Bug 12409257 back
		p_org_id_tbl => p_headers.org_id,
		--p_ship_to_location_id_tbl => p_headers.ship_to_location_id,
		--Bug 12409257 end. Bug 13771850 end
        x_result_set_id                => l_result_set_id,
        x_result_type                  => l_result_type);
--<End Bug 9213424>

        -------------------------------------------------------------------------
        --  PDOI Header Validation Subroutines
        -------------------------------------------------------------------------
          WHEN c_po_header_id THEN
            -- validate that the PO Header Id is not null and
            -- does not already exist in the Transaction table (for create case).
            PO_VAL_HEADERS2.po_header_id(p_id_tbl               => p_headers.interface_id,
                                         p_po_header_id_tbl     => p_headers.po_header_id,
                                         x_result_set_id        => l_result_set_id,
                                         x_result_type          => l_result_type);
          WHEN c_end_date THEN
            -- validate end date not earlier than start date.
            PO_VALIDATION_HELPER.start_date_le_end_date(p_calling_module          => p_calling_program,
                                                        p_start_date_tbl          => p_headers.start_date,
                                                        p_end_date_tbl            => p_headers.end_date,
                                                        p_entity_id_tbl           => p_headers.interface_id,
                                                        p_entity_type             => c_entity_type_header,
                                                        p_column_name             => 'END DATE',
                                                        p_column_val_selector     => 'END_DATE',
                                                        p_message_name            => 'PO_PDOI_INVALID_END_DATE',
                                                        p_validation_id           => PO_VAL_CONSTANTS.c_end_date,
                                                        x_results                 => x_results,
                                                        x_result_type             => l_result_type);

          WHEN c_type_lookup_code THEN
            -- validate type_lookup_code not null and equal to BLANKET, STANDARD or QUOTATION.
            PO_VAL_HEADERS2.type_lookup_code(p_id_tbl                   => p_headers.interface_id,
                                             p_type_lookup_code_tbl     => p_headers.type_lookup_code,
                                             x_results                  => x_results,
                                             x_result_type              => l_result_type);
          WHEN c_document_num THEN
            -- document_num must not be null, must be unique, greater than or equal to zero and be of the correct type.
            PO_VAL_HEADERS2.document_num(p_id_tbl                   => p_headers.interface_id,
                                         p_po_header_id_tbl         => p_headers.po_header_id,
                                         p_document_num_tbl         => p_headers.document_num,
                                         p_type_lookup_code_tbl     => p_headers.type_lookup_code,
                                         p_manual_po_num_type       => l_manual_po_num_type,
                                         p_manual_quote_num_type    => l_manual_quote_num_type,
                                         x_results                  => x_results,
                                         x_result_set_id            => l_result_set_id,
                                         x_result_type              => l_result_type);

          WHEN c_acceptance_required_flag THEN
            -- bug4911383
            PO_VAL_HEADERS2.acceptance_required_flag
            ( p_id_tbl                       => p_headers.interface_id,
              p_type_lookup_code_tbl         => p_headers.type_lookup_code,
              p_acceptance_required_flag_tbl => p_headers.acceptance_required_flag,
              x_results                      => x_results,
              x_result_type                  => l_result_type
            );


          WHEN c_revision_num THEN
            -- validate revision_num is zero.
            PO_VALIDATION_HELPER.zero(p_calling_module     => p_calling_program,
                                      p_value_tbl          => p_headers.revision_num,
                                      p_entity_id_tbl      => p_headers.interface_id,
                                      p_entity_type        => c_entity_type_header,
                                      p_column_name        => 'REVISION_NUM',
                                      p_message_name       => 'PO_PDOI_COLUMN_ZERO',
                                      p_validation_id      => PO_VAL_CONSTANTS.c_revision_num,
                                      x_results            => x_results,
                                      x_result_type        => l_result_type);
          WHEN c_currency_code THEN
            -- validate currency_code is not null and valid in FND_CURRENCIES.
            PO_VAL_HEADERS2.currency_code(p_id_tbl                => p_headers.interface_id,
                                          p_currency_code_tbl     => p_headers.currency_code,
                                          x_result_set_id         => l_result_set_id,
                                          x_result_type           => l_result_type);
          WHEN c_rate_info THEN
            -- validate rate information
            PO_VAL_HEADERS2.rate_info(p_id_tbl                => p_headers.interface_id,
                                      p_currency_code_tbl     => p_headers.currency_code,
                                      p_rate_type_tbl         => p_headers.rate_type,
                                      p_rate_tbl              => p_headers.rate,
                                      p_rate_date_tbl         => p_headers.rate_date,
                                      p_func_currency_code    => l_func_currency_code,
                                      p_set_of_books_id       => l_set_of_books_id,
                                      x_result_set_id         => l_result_set_id,
                                      x_results               => x_results,
                                      x_result_type           => l_result_type);
          WHEN c_agent_id THEN
            -- validate agent_id is not null and valid in PO_AGENTS.
            PO_VAL_HEADERS2.agent_id(p_id_tbl            => p_headers.interface_id,
                                     p_agent_id_tbl      => p_headers.agent_id,
                                     x_result_set_id     => l_result_set_id,
                                     x_result_type       => l_result_type);
          WHEN c_vendor_info THEN
            -- validate vendor information
            PO_VAL_HEADERS2.vendor_info(p_id_tbl                    => p_headers.interface_id,
                                        p_vendor_id_tbl             => p_headers.vendor_id,
                                        p_vendor_site_id_tbl        => p_headers.vendor_site_id,
                                        p_vendor_contact_id_tbl     => p_headers.vendor_contact_id,
 					p_type_lookup_code_tbl      => p_headers.type_lookup_code, -- 8913559 bug
                                        p_federal_instance          => l_federal_instance,
                                        x_result_set_id             => l_result_set_id,
                                        x_results                   => x_results,
                                        x_result_type               => l_result_type);
          WHEN c_ship_to_location_id THEN
            PO_VAL_HEADERS2.ship_to_location_id(p_id_tbl                      => p_headers.interface_id,
                                                p_ship_to_location_id_tbl     => p_headers.ship_to_location_id,
                                                -- Bug 7007502: Added new param p_type_lookup_code_tbl
                                                p_type_lookup_code_tbl        => p_headers.type_lookup_code,
                                                x_result_set_id               => l_result_set_id,
                                                x_result_type                 => l_result_type);
          WHEN c_bill_to_location_id THEN
            PO_VAL_HEADERS2.bill_to_location_id(p_id_tbl                      => p_headers.interface_id,
                                                p_bill_to_location_id_tbl     => p_headers.bill_to_location_id,
                                                -- Bug 7007502: Added new param p_type_lookup_code_tbl
                                                p_type_lookup_code_tbl        => p_headers.type_lookup_code,
                                                x_result_set_id               => l_result_set_id,
                                                x_result_type                 => l_result_type);
          WHEN c_style_id THEN
            PO_VAL_HEADERS2.style_id(p_id_tbl                      => p_headers.interface_id,
                                     p_style_id_tbl                => p_headers.style_id,
                                     x_result_set_id               => l_result_set_id,
                                     x_result_type                 => l_result_type);
          WHEN c_last_update_date THEN
            PO_VALIDATION_HELPER.not_null(p_calling_module     => p_calling_program,
                                          p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.last_update_date),
                                          p_entity_id_tbl      => p_headers.interface_id,
                                          p_entity_type        => c_entity_type_header,
                                          p_column_name        => 'LAST_UPDATE_DATE',
                                          p_message_name       => 'PO_PDOI_COLUMN_NOT_NULL',
                                          p_validation_id      => PO_VAL_CONSTANTS.c_last_update_date,
                                          x_results            => x_results,
                                          x_result_type        => l_result_type);
          WHEN c_last_updated_by THEN
            PO_VALIDATION_HELPER.not_null(p_calling_module     => p_calling_program,
                                          p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.last_updated_by),
                                          p_entity_id_tbl      => p_headers.interface_id,
                                          p_entity_type        => c_entity_type_header,
                                          p_column_name        => 'LAST_UPDATED_BY',
                                          p_message_name       => 'PO_PDOI_COLUMN_NOT_NULL',
                                          p_validation_id      => PO_VAL_CONSTANTS.c_last_updated_by,
                                          x_results            => x_results,
                                          x_result_type        => l_result_type);
          WHEN c_po_release_id THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.po_release_id),
                                             p_entity_id_tbl      => p_headers.interface_id,
                                             p_entity_type        => c_entity_type_header,
                                             p_column_name        => 'PO_RELEASE_ID',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'PO_RELEASE_ID',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.po_release_id),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_po_release_id,
											 x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_release_num THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.release_num),
                                             p_entity_id_tbl      => p_headers.interface_id,
                                             p_entity_type        => c_entity_type_header,
                                             p_column_name        => 'RELEASE_NUM',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'RELEASE_NUM',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.release_num),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_release_num,
											 x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_release_date THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.release_date),
                                             p_entity_id_tbl      => p_headers.interface_id,
                                             p_entity_type        => c_entity_type_header,
                                             p_column_name        => 'RELEASE_DATE',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'RELEASE_DATE',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.release_date),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_release_date,
											 x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_revised_date THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.revised_date),
                                             p_entity_id_tbl      => p_headers.interface_id,
                                             p_entity_type        => c_entity_type_header,
                                             p_column_name        => 'REVISED_DATE',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'REVISED_DATE',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.revised_date),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_revised_date,
											 x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_printed_date THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.printed_date),
                                             p_entity_id_tbl      => p_headers.interface_id,
                                             p_entity_type        => c_entity_type_header,
                                             p_column_name        => 'PRINTED_DATE',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'PRINTED_DATE',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.printed_date),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_printed_date,
											 x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_closed_date THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.closed_date),
                                             p_entity_id_tbl      => p_headers.interface_id,
                                             p_entity_type        => c_entity_type_header,
                                             p_column_name        => 'CLOSED_DATE',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'CLOSED_DATE',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.closed_date),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_closed_date,
											 x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_terms_id_header THEN
            PO_VALIDATION_HELPER.terms_id(p_calling_module     => p_calling_program,
                                          p_terms_id_tbl       => p_headers.terms_id,
                                          p_entity_id_tbl      => p_headers.interface_id,
                                          p_entity_type        => c_entity_type_header,
                                          p_validation_id      => PO_VAL_CONSTANTS.c_terms_id_header,
                                          x_result_set_id      => l_result_set_id,
                                          x_result_type        => l_result_type);
          WHEN c_ship_via_lookup_code THEN
            PO_VAL_HEADERS2.ship_via_lookup_code(p_id_tbl                       => p_headers.interface_id,
                                                 p_ship_via_lookup_code_tbl     => p_headers.ship_via_lookup_code,
                                                 p_inventory_org_id             => l_inventory_org_id,
                                                 x_result_set_id                => l_result_set_id,
                                                 x_result_type                  => l_result_type);
          WHEN c_fob_lookup_code THEN
            PO_VAL_HEADERS2.fob_lookup_code(p_id_tbl                  => p_headers.interface_id,
                                            p_fob_lookup_code_tbl     => p_headers.fob_lookup_code,
                                            x_result_set_id           => l_result_set_id,
                                            x_result_type             => l_result_type);
          WHEN c_freight_terms_lookup_code THEN
            PO_VAL_HEADERS2.freight_terms_lookup_code(p_id_tbl                       => p_headers.interface_id,
                                                      p_freight_terms_lookup_tbl     => p_headers.freight_terms_lookup_code,
                                                      x_result_set_id                => l_result_set_id,
                                                      x_result_type                  => l_result_type);
          WHEN c_shipping_control THEN
            PO_VAL_HEADERS2.shipping_control(p_id_tbl                   => p_headers.interface_id,
                                             p_shipping_control_tbl     => p_headers.shipping_control,
                                             x_result_set_id            => l_result_set_id,
                                             x_result_type              => l_result_type);
          WHEN c_confirming_order_flag THEN
            PO_VALIDATION_HELPER.flag_value_y_n(p_calling_module     => p_calling_program,
                                                p_flag_value_tbl     => p_headers.confirming_order_flag,
                                                p_entity_id_tbl      => p_headers.interface_id,
                                                p_entity_type        => c_entity_type_header,
                                                p_column_name        => 'CONFIRMING_ORDER_FLAG',
                                                p_message_name       => 'PO_PDOI_INVALID_FLAG_VALUE',
                                                p_token1_name        => 'COLUMN_NAME',
                                                p_token1_value       => 'CONFIRMING_ORDER_FLAG',
                                                p_token2_name        => 'VALUE',
                                                p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.confirming_order_flag),
                                                p_validation_id      => PO_VAL_CONSTANTS.c_confirming_order_flag,
												x_results            => x_results,
                                                x_result_type        => l_result_type);
          WHEN c_acceptance_due_date THEN
            PO_VAL_HEADERS2.acceptance_due_date(p_id_tbl                       => p_headers.interface_id,
                                                p_acceptance_reqd_flag_tbl     => p_headers.acceptance_required_flag,
                                                p_acceptance_due_date_tbl      => p_headers.acceptance_due_date,
                                                x_results                      => x_results,
                                                x_result_type                  => l_result_type);
          WHEN c_amount_agreed THEN
            PO_VALIDATION_HELPER.greater_or_equal_zero(p_calling_module     => p_calling_program,
                                                       p_null_allowed_flag  => PO_CORE_S.g_parameter_YES, -- bug5008206
                                                       p_value_tbl          => p_headers.amount_agreed,
                                                       p_entity_id_tbl      => p_headers.interface_id,
                                                       p_entity_type        => c_entity_type_header,
                                                       p_column_name        => c_amount_agreed,
                                                       p_message_name       => 'PO_PDOI_LT_ZERO',
                                                       p_token1_name        => 'COLUMN_NAME',
                                                       p_token1_value       => 'AMOUNT_AGREED',
                                                       p_token2_name        => 'VALUE',
                                                       p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.amount_agreed),
                                                       p_validation_id      => PO_VAL_CONSTANTS.c_amount_agreed,
                             x_results            => x_results,
                                                       x_result_type        => l_result_type);
          WHEN c_amount_limit THEN
            -- bug 5352625
            PO_VAL_HEADERS2.amount_limit
            ( p_id_tbl => p_headers.interface_id,
              p_amount_limit_tbl => p_headers.amount_limit,
              p_amount_agreed_tbl => p_headers.amount_agreed,
              x_results => x_results,
              x_result_type => l_result_type
            );

          WHEN c_firm_status_lookup_header THEN
            PO_VALIDATION_HELPER.flag_value_y_n(p_calling_module     => p_calling_program,
                                                p_flag_value_tbl     => PO_TYPE_CONVERTER.to_po_tbl_varchar1(p_headers.firm_status_lookup_code),
                                                p_entity_id_tbl      => p_headers.interface_id,
                                                p_entity_type        => c_entity_type_header,
                                                p_column_name        => 'FIRM_STATUS_LOOKUP_CODE',
                                                p_message_name       => 'PO_PDOI_INVALID_FLAG_VALUE',
                                                p_token1_name        => 'COLUMN_NAME',
                                                p_token1_value       => 'FIRM_STATUS_LOOKUP_CODE',
                                                p_token2_name        => 'VALUE',
                                                p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.firm_status_lookup_code),
                                                p_validation_id      => PO_VAL_CONSTANTS.c_firm_status_lookup_header,
                        x_results            => x_results,
                                                x_result_type        => l_result_type);
          WHEN c_cancel_flag THEN
            PO_VAL_HEADERS2.cancel_flag(p_id_tbl              => p_headers.interface_id,
                                        p_cancel_flag_tbl     => p_headers.cancel_flag,
                                        x_results             => x_results,
                                        x_result_type         => l_result_type);
          WHEN c_closed_code THEN
            PO_VAL_HEADERS2.closed_code(p_id_tbl                       => p_headers.interface_id,
                                        p_closed_code_tbl              => p_headers.closed_code,
                                        p_acceptance_reqd_flag_tbl     => p_headers.acceptance_required_flag,
                                        x_results                      => x_results,
                                        x_result_type                  => l_result_type);
          WHEN c_print_count THEN
            PO_VAL_HEADERS2.print_count(p_id_tbl                  => p_headers.interface_id,
                                        p_print_count_tbl         => p_headers.print_count,
                                        p_approval_status_tbl     => p_headers.approval_status,
                                        x_results                 => x_results,
                                        x_result_type             => l_result_type);
          WHEN c_frozen_flag THEN
            PO_VALIDATION_HELPER.flag_value_y_n(p_calling_module     => p_calling_program,
                                                p_flag_value_tbl     => p_headers.frozen_flag,
                                                p_entity_id_tbl      => p_headers.interface_id,
                                                p_entity_type        => c_entity_type_header,
                                                p_column_name        => 'FROZEN_FLAG',
                                                p_message_name       => 'PO_PDOI_INVALID_FLAG_VALUE',
                                                p_token1_name        => 'COLUMN_NAME',
                                                p_token1_value       => 'FROZEN_FLAG',
                                                p_token2_name        => 'VALUE',
                                                p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.frozen_flag),
                                                p_validation_id      => PO_VAL_CONSTANTS.c_frozen_flag,
                        x_results            => x_results,
                                                x_result_type        => l_result_type);
          WHEN c_approval_status THEN
            PO_VAL_HEADERS2.approval_status(p_id_tbl                  => p_headers.interface_id,
                                            p_approval_status_tbl     => p_headers.approval_status,
                                            x_results                 => x_results,
                                            x_result_type             => l_result_type);
          WHEN c_amount_to_encumber THEN
            PO_VAL_HEADERS2.amount_to_encumber(p_id_tbl                     => p_headers.interface_id,
                                               p_amount_to_encumber_tbl     => p_headers.amount_to_encumber,
                                               x_results                    => x_results,
                                               x_result_type                => l_result_type);
          WHEN c_quote_warning_delay THEN
            PO_VALIDATION_HELPER.not_null(p_calling_module     => p_calling_program,
                                          p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.quote_warning_delay),
                                          p_entity_id_tbl      => p_headers.interface_id,
                                          p_entity_type        => c_entity_type_header,
                                          p_column_name        => 'QUOTE_WARNING_DELAY',
                                          p_message_name       => 'PO_PDOI_COLUMN_NOT_NULL',
                                          p_token1_name        => 'COLUMN_NAME',
                                          p_token1_value       => 'QUOTE_WARNING_DELAY',
                                          p_token2_name        => 'VALUE',
                                          p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.quote_warning_delay),
                                          p_validation_id      => PO_VAL_CONSTANTS.c_quote_warning_delay,
                      x_results            => x_results,
                                          x_result_type        => l_result_type);
          WHEN c_approval_required_flag THEN
            PO_VALIDATION_HELPER.not_null(p_calling_module     => p_calling_program,
                                          p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.approval_required_flag),
                                          p_entity_id_tbl      => p_headers.interface_id,
                                          p_entity_type        => c_entity_type_header,
                                          p_column_name        => 'APPROVAL_REQUIRED_FLAG',
                                          p_message_name       => 'PO_PDOI_COLUMN_NOT_NULL',
                                          p_token1_name        => 'COLUMN_NAME',
                                          p_token1_value       => 'APPROVAL_REQUIRED_FLAG',
                                          p_token2_name        => 'VALUE',
                                          p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_headers.approval_required_flag),
                                          p_validation_id      => PO_VAL_CONSTANTS.c_approval_required_flag,
                      x_results            => x_results,
                                          x_result_type        => l_result_type);

    ---------------------------------------------------------------
    -- Line Validations
    ---------------------------------------------------------------

    WHEN c_amt_agreed_ge_zero THEN
      PO_VAL_LINES.amt_agreed_ge_zero(
        p_line_id_tbl => p_lines.po_line_id
      , p_committed_amount_tbl => p_lines.committed_amount
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_min_rel_amt_ge_zero THEN
      PO_VAL_LINES.min_rel_amt_ge_zero(
        p_line_id_tbl => p_lines.po_line_id
      , p_min_release_amount_tbl => p_lines.min_release_amount
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_line_qty_gt_zero THEN
      PO_VAL_LINES.quantity_gt_zero(
        p_line_id_tbl => p_lines.po_line_id
      , p_quantity_tbl => p_lines.quantity
      , p_order_type_lookup_code_tbl => p_lines.order_type_lookup_code
      , x_results => x_results
      , x_result_type => l_result_type
      );

   -- bug 8633959 start
    WHEN c_validate_category THEN
       PO_VAL_LINES2.category_combination_valid(
          p_po_line_id_tbl => p_lines.po_line_id
        , p_category_id_tbl => p_lines.category_id
        , x_results => x_results
        , x_result_type => l_result_type
        );
    -- bug 8633959 end

    -- bug 14075368 start
    WHEN c_validate_item THEN
       PO_VAL_LINES2.item_combination_valid(
          p_po_line_id_tbl => p_lines.po_line_id
        , p_item_id_tbl => p_lines.item_id
        , x_results => x_results
        , x_result_type => l_result_type
        );
    -- bug 14075368 end

    -- <Complex Work R12 Start>: Consolidate qty rcvd/billed check
    WHEN c_line_qty_ge_qty_exec THEN
      PO_VAL_LINES.quantity_ge_quantity_exec(
        p_line_id_tbl => p_lines.po_line_id
      , p_quantity_tbl => p_lines.quantity
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );
    -- <Complex Work R12 End>

    WHEN c_line_qty_ge_qty_enc THEN
      PO_VAL_LINES.quantity_ge_quantity_enc(
        p_line_id_tbl => p_lines.po_line_id
      , p_quantity_tbl => p_lines.quantity
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_quantity_notif_change THEN
      PO_VAL_LINES.quantity_notif_change(
        p_line_id_tbl => p_lines.po_line_id
      , p_quantity_tbl => p_lines.quantity
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_line_amt_gt_zero THEN
      PO_VAL_LINES.amount_gt_zero(
        p_line_id_tbl => p_lines.po_line_id
      , p_amount_tbl => p_lines.amount
      , p_order_type_lookup_code_tbl => p_lines.order_type_lookup_code
      , x_results => x_results
      , x_result_type => l_result_type
      );

    -- <Complex Work R12 Start>: Consolidate amt rcvd/billed check
    WHEN c_line_amt_ge_amt_exec THEN
      PO_VAL_LINES.amount_ge_amount_exec(
        p_line_id_tbl => p_lines.po_line_id
      , p_amount_tbl => p_lines.amount
      , p_currency_code_tbl => p_lines.hdr_currency_code
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );
    -- <Complex Work R12 End>

    WHEN c_line_amt_ge_timecard THEN
      PO_VAL_LINES.amount_ge_timecard(
        p_line_id_tbl => p_lines.po_line_id
      , p_amount_tbl => p_lines.amount
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_line_num_unique THEN
      PO_VAL_LINES.line_num_unique(
        p_line_id_tbl => p_lines.po_line_id
      , p_header_id_tbl => p_lines.po_header_id
      , p_line_num_tbl => p_lines.line_num
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_line_num_gt_zero THEN
      PO_VAL_LINES.line_num_gt_zero(
        p_line_id_tbl => p_lines.po_line_id
      , p_line_num_tbl => p_lines.line_num
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_vmi_asl_exists THEN
      PO_VAL_LINES.vmi_asl_exists(
        p_line_id_tbl => p_lines.po_line_id
      , p_type_lookup_code_tbl => p_lines.hdr_type_lookup_code
      , p_item_id_tbl => p_lines.item_id
      -- Bug# 4634769: Pass in the inventory org id
      , p_org_id_tbl => p_lines.inventory_org_id
      , p_vendor_id_tbl => p_lines.hdr_vendor_id
      , p_vendor_site_id_tbl => p_lines.hdr_vendor_site_id
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_start_date_le_end_date THEN
      PO_VAL_LINES.start_date_le_end_date(
        p_line_id_tbl => p_lines.po_line_id
      , p_start_date_tbl => p_lines.start_date
      , p_expiration_date_tbl => p_lines.expiration_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_otl_inv_start_date_change THEN
      PO_VAL_LINES.otl_invalid_start_date_change(
        p_line_id_tbl => p_lines.po_line_id
      , p_start_date_tbl => p_lines.start_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_otl_inv_end_date_change THEN
      PO_VAL_LINES.otl_invalid_end_date_change(
        p_line_id_tbl => p_lines.po_line_id
      , p_expiration_date_tbl => p_lines.expiration_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_unit_price_ge_zero THEN
      PO_VAL_LINES.unit_price_ge_zero(
        p_line_id_tbl => p_lines.po_line_id
      , p_unit_price_tbl => p_lines.unit_price
      , p_order_type_lookup_code_tbl => p_lines.order_type_lookup_code
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_list_price_ge_zero THEN
      PO_VAL_LINES.list_price_ge_zero(
        p_line_id_tbl => p_lines.po_line_id
      , p_list_price_per_unit_tbl => p_lines.list_price_per_unit
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_market_price_ge_zero THEN
      PO_VAL_LINES.market_price_ge_zero(
        p_line_id_tbl => p_lines.po_line_id
      , p_market_price_tbl => p_lines.market_price
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_validate_unit_price_change THEN
      PO_VAL_LINES.validate_unit_price_change(
        p_line_id_tbl => p_lines.po_line_id
      , p_unit_price_tbl => p_lines.unit_price
      , p_price_break_lookup_code_tbl => p_lines.price_break_lookup_code
      , p_amt_changed_flag_tbl => p_lines.amount_changed_flag -- <Bug 13503748: Encumbrance ER >--
      , x_result_set_id => l_result_set_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_expiration_ge_blanket_start THEN
      PO_VAL_LINES.expiration_ge_blanket_start(
        p_line_id_tbl => p_lines.po_line_id
      , p_blanket_start_date_tbl => p_lines.hdr_start_date
      , p_expiration_date_tbl => p_lines.expiration_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_expiration_le_blanket_end THEN
      PO_VAL_LINES.expiration_le_blanket_end(
        p_line_id_tbl => p_lines.po_line_id
      , p_blanket_end_date_tbl => p_lines.hdr_end_date
      , p_expiration_date_tbl => p_lines.expiration_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    -- <Complex Work R12 Start>
    WHEN c_qty_ge_qty_milestone_exec THEN
      PO_VAL_LINES.qty_ge_qty_milestone_exec(
        p_line_id_tbl => p_lines.po_line_id
      , p_quantity_tbl => p_lines.quantity
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_price_ge_price_mstone_exec THEN
      PO_VAL_LINES.price_ge_price_milestone_exec(
        p_line_id_tbl => p_lines.po_line_id
      , p_price_tbl => p_lines.unit_price
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    -- Bug 5072189 START
    WHEN c_recoupment_rate_range_check THEN
      PO_VAL_LINES.recoupment_rate_range_check(
        p_line_id_tbl  => p_lines.po_line_id
      , p_recoupment_rate_tbl => p_lines.recoupment_rate
      , x_results     => x_results
      , x_result_type => l_result_type
    );

    WHEN c_retainage_rate_range_check THEN
      PO_VAL_LINES.retainage_rate_range_check(
        p_line_id_tbl  => p_lines.po_line_id
      , p_retainage_rate_tbl => p_lines.retainage_rate
      , x_results     => x_results
      , x_result_type => l_result_type
    );

    WHEN c_prog_pay_rate_range_check THEN
      PO_VAL_LINES.prog_pay_rate_range_check(
        p_line_id_tbl  => p_lines.po_line_id
      , p_prog_pay_rate_tbl => p_lines.progress_payment_rate
      , x_results     => x_results
      , x_result_type => l_result_type
    );
    -- Bug 5072189 END

   -- Bug 5221843 START
    WHEN c_max_retain_amt_ge_zero THEN
      PO_VAL_LINES.max_retain_amt_ge_zero (
        p_line_id_tbl  => p_lines.po_line_id
      , p_max_retain_amt_tbl => p_lines.max_retainage_amount
      , x_results     => x_results
      , x_result_type => l_result_type
    );
    -- Bug 5221843 END

   -- Bug 5453079 START
    WHEN c_max_retain_amt_ge_retained THEN
      PO_VAL_LINES.max_retain_amt_ge_retained (
        p_line_id_tbl  => p_lines.po_line_id
      , p_max_retain_amt_tbl => p_lines.max_retainage_amount
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
    );
    -- Bug 5453079 END

    -- <Complex Work R12 End>

    WHEN c_unit_meas_not_null THEN
      PO_VAL_LINES.unit_meas_not_null(
        p_line_id_tbl => p_lines.po_line_id
      , p_unit_meas_lookup_code_tbl => p_lines.unit_meas_lookup_code
      , p_order_type_lookup_code_tbl => p_lines.order_type_lookup_code
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_item_description_not_null THEN
      PO_VAL_LINES.item_description_not_null(
        p_line_id_tbl => p_lines.po_line_id
      , p_item_description_tbl => p_lines.item_description
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_category_id_not_null THEN
      PO_VAL_LINES.category_id_not_null(
        p_line_id_tbl => p_lines.po_line_id
      , p_category_id_tbl => p_lines.category_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_item_id_not_null THEN
      IF (p_calling_program = c_program_PDOI) THEN
        PO_VAL_LINES.item_id_not_null(
          p_id_tbl => p_lines.interface_id
        , p_item_id_tbl => p_lines.item_id
        , p_order_type_lookup_code_tbl => p_lines.order_type_lookup_code
        , p_line_type_id_tbl => p_lines.line_type_id
        , p_message_name => PO_MESSAGE_S.PO_PDOI_ITEM_NOT_NULL
        , x_result_set_id => l_result_set_id
        , x_result_type => l_result_type
        );
      ELSE
        PO_VAL_LINES.item_id_not_null(
          p_id_tbl => p_lines.po_line_id
        , p_item_id_tbl => p_lines.item_id
        , p_order_type_lookup_code_tbl => p_lines.order_type_lookup_code
        , p_line_type_id_tbl => p_lines.line_type_id
        , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
        , x_result_set_id => l_result_set_id
        , x_result_type => l_result_type
        );
      END IF;

    WHEN c_temp_labor_job_id_not_null THEN
      PO_VAL_LINES.temp_labor_job_id_not_null(
        p_line_id_tbl => p_lines.po_line_id
      , p_job_id_tbl => p_lines.job_id
      , p_purchase_basis_tbl => p_lines.purchase_basis
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_line_type_id_not_null THEN
      PO_VAL_LINES.line_type_id_not_null(
        p_line_id_tbl => p_lines.po_line_id
      , p_line_type_id_tbl => p_lines.line_type_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_temp_lbr_start_date_not_null THEN
      PO_VAL_LINES.temp_lbr_start_date_not_null(
        p_line_id_tbl => p_lines.po_line_id
      , p_start_date_tbl => p_lines.start_date
      , p_purchase_basis_tbl => p_lines.purchase_basis
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_src_doc_line_not_null THEN
      PO_VAL_LINES.src_doc_line_not_null(
        p_line_id_tbl => p_lines.po_line_id
      , p_from_header_id_tbl => p_lines.from_header_id
      , p_from_line_id_tbl => p_lines.from_line_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    -- Opm related validation : OPM Integration R12 Start
    WHEN c_line_sec_qty_gt_zero THEN
      PO_VAL_LINES.line_sec_quantity_gt_zero(
        p_line_id_tbl => p_lines.po_line_id
      , p_item_id_tbl  => p_lines.item_id
      , p_sec_quantity_tbl => p_lines.secondary_quantity
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_line_qtys_within_deviation THEN
      PO_VAL_LINES.line_qtys_within_deviation(
        p_line_id_tbl => p_lines.po_line_id
      , p_item_id_tbl  => p_lines.item_id
      , p_quantity_tbl    => p_lines.quantity
      , p_primary_uom_tbl  => p_lines.unit_meas_lookup_code
      , p_sec_quantity_tbl => p_lines.secondary_quantity
      , p_secondary_uom_tbl => p_lines.secondary_unit_of_measure
      , x_results => x_results
      , x_result_type => l_result_type
      );
     -- Opm related validation : OPM Integration R12 End

     WHEN c_from_line_id_not_null THEN
       PO_VAL_LINES.from_line_id_not_null(
         p_line_id_tbl => p_lines.po_line_id
       , p_from_header_id_tbl => p_lines.from_header_id
       , p_from_line_id_tbl => p_lines.from_line_id
       , x_results => x_results
       , x_result_type => l_result_type
       );

    -- Bug 5070210 Start
    WHEN c_amt_ge_advance_amt THEN
      PO_VAL_LINES.advance_amt_le_amt(
        p_line_id_tbl  => p_lines.po_line_id,
        p_advance_tbl  => p_lines.advance_amount,
        p_amount_tbl   => p_lines.amount,
        p_quantity_tbl => p_lines.quantity,
        p_price_tbl    => p_lines.unit_price,
        x_results      => x_results,
        x_result_type  => l_result_type
      );
    -- Bug 5070210 End

     -------------------------------------------------------------------------
        -- Line Validation Subroutines
        -------------------------------------------------------------------------
        WHEN c_over_tolerance_error_flag THEN
            -- The lookup code specified in over_tolerance_error_flag with the lookup type
            -- 'RECEIVING CONTROL LEVEL' has to exist in po_lookup_codes and still active.
            -- This method is called only for Standard PO and quotation documents
            PO_VAL_LINES2.over_tolerance_err_flag(p_id_tbl                          => p_lines.interface_id,
                                                  p_over_tolerance_err_flag_tbl     => p_lines.over_tolerance_error_flag,
                                                  x_result_set_id                   => l_result_set_id,
                                                  x_result_type                     => l_result_type);
          WHEN c_expiration_date_blanket THEN
            -- Expiration date on the line cannot be earlier than the header effective start date and cannot be later than header effective end date
            PO_VAL_LINES2.expiration_date_blanket(p_id_tbl                    => p_lines.interface_id,
                                                  p_expiration_date_tbl       => p_lines.expiration_date,
                                                  p_header_start_date_tbl     => p_lines.hdr_start_date,
                                                  p_header_end_date_tbl       => p_lines.hdr_end_date,
                                                  x_results                   => x_results,
                                                  x_result_type               => l_result_type);
          WHEN c_global_agreement_flag THEN
            -- For blanket document with purchase type 'TEMP LABOR', the global agreement
            -- flag has to be 'Y'.  Global_agreement_flag and outside operation flag cannot both be 'Y'
            PO_VAL_LINES2.global_agreement_flag(p_id_tbl                        => p_lines.interface_id,
                                                p_global_agreement_flag_tbl     => p_lines.global_agreement_flag,
                                                p_purchase_basis_tbl            => p_lines.purchase_basis,
                                                p_line_type_id_tbl              => p_lines.line_type_id,
                                                x_result_set_id                 => l_result_set_id,
                                                x_results                       => x_results,
                                                x_result_type                   => l_result_type);
          WHEN c_amount_blanket THEN
            -- If order_type_lookup_code is 'RATE', amount has to be null
            PO_VAL_LINES2.amount_blanket(p_id_tbl                         => p_lines.interface_id,
                                         p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                         p_amount_tbl                     => p_lines.amount,
                                         x_results                        => x_results,
                                         x_result_type                    => l_result_type);
          WHEN c_order_type_lookup_code THEN
            -- If services procurement is not enabled, the order_type_lookup_code cannot
            -- be  'FIXED PRICE' or 'RATE'.
            PO_VAL_LINES2.order_type_lookup_code(p_id_tbl                         => p_lines.interface_id,
                                                 p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                                 x_results                        => x_results,
                                                 x_result_type                    => l_result_type);
          WHEN c_contractor_name THEN
            -- If purchase basis is not 'TEMP LABOR' or document type is not STANDARD,
            -- contractor first name and last name fields should be empty
            PO_VAL_LINES2.contractor_name(p_id_tbl                        => p_lines.interface_id,
                                          p_doc_type                      => l_doc_type,
                                          p_purchase_basis_tbl            => p_lines.purchase_basis,
                                          p_contractor_last_name_tbl      => p_lines.contractor_last_name,
                                          p_contractor_first_name_tbl     => p_lines.contractor_first_name,
                                          x_results                       => x_results,
                                          x_result_type                   => l_result_type);
          WHEN c_job_id THEN
            -- If purchase basis is TEMP LABOR, then job id must be null
            PO_VAL_LINES2.job_id(p_id_tbl                        => p_lines.interface_id,
                                 p_job_id_tbl                    => p_lines.job_id,
                                 p_job_business_group_id_tbl     => p_lines.job_business_group_id,
                                 p_purchase_basis_tbl            => p_lines.purchase_basis,
                                 p_category_id_tbl               => p_lines.category_id,
                                 x_result_set_id                 => l_result_set_id,
                                 x_results                       => x_results,
                                 x_result_type                   => l_result_type);
          WHEN c_job_business_group_id THEN
            -- If services procurement not enabled, order_type_lookup_code cannot be
            -- 'FIXED PRICE' or 'RATE'
            PO_VAL_LINES2.job_business_group_id(p_id_tbl                        => p_lines.interface_id,
                                                p_job_id_tbl                    => p_lines.job_id,
                                                p_job_business_group_id_tbl     => p_lines.job_business_group_id,
                                                p_purchase_basis_tbl            => p_lines.purchase_basis,
                                                x_result_set_id                 => l_result_set_id,
                                                x_result_type                   => l_result_type);
          WHEN c_capital_expense_flag THEN
            -- If purchase_basis = 'TEMP LABOR', then capital_expense_flag cannot = 'Y'
            PO_VAL_LINES2.capital_expense_flag(p_id_tbl                       => p_lines.interface_id,
                                               p_purchase_basis_tbl           => p_lines.purchase_basis,
                                               p_capital_expense_flag_tbl     => p_lines.capital_expense_flag,
                                               x_results                      => x_results,
                                               x_result_type                  => l_result_type);
          WHEN c_un_number_id THEN
            -- If purchase_basis = 'TEMP LABOR', then un_number must be null
            PO_VAL_LINES2.un_number_id(p_id_tbl                 => p_lines.interface_id,
                                       p_purchase_basis_tbl     => p_lines.purchase_basis,
                                       p_un_number_id_tbl       => p_lines.un_number_id,
                                       x_result_set_id          => l_result_set_id,
                                       x_results                => x_results,
                                       x_result_type            => l_result_type);
          WHEN c_hazard_class_id THEN
            -- If purchase_basis = 'TEMP LABOR', then un_number must be null
            PO_VAL_LINES2.hazard_class_id(p_id_tbl                  => p_lines.interface_id,
                                          p_purchase_basis_tbl      => p_lines.purchase_basis,
                                          p_hazard_class_id_tbl     => p_lines.hazard_class_id,
                                          x_result_set_id           => l_result_set_id,
                                          x_results                 => x_results,
                                          x_result_type             => l_result_type);
          WHEN c_item_id THEN
            -- If order_type_lookup_code is 'FIXED PRICE', 'RATE', or 'AMOUNT', item_id has to be null
            PO_VAL_LINES2.item_id(p_id_tbl                         => p_lines.interface_id,
                                  p_item_id_tbl                    => p_lines.item_id,
                                  p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                  p_line_type_id_tbl               => p_lines.line_type_id,
                                  p_inventory_org_id               => l_inventory_org_id,
                                  x_result_set_id                  => l_result_set_id,
                                  x_results                        => x_results,
                                  x_result_type                    => l_result_type);
          WHEN c_item_description THEN
            -- Make sure that the item_description is populated, and also need to find out if it is different from
            -- what is setup for the item. Would not allow item_description update if item attribute
            -- allow_item_desc_update_flag is N.
            PO_VAL_LINES2.item_description(p_id_tbl                         => p_lines.interface_id,
                                           p_item_description_tbl           => p_lines.item_description,
                                           p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                           p_item_id_tbl                    => p_lines.item_id,
                                           p_create_or_update_item          => l_create_or_update_item,
                                           p_inventory_org_id               => l_inventory_org_id,
                                           x_result_set_id                  => l_result_set_id,
                                           x_result_type                    => l_result_type);
          WHEN c_unit_meas_lookup_code THEN
            -- check to see if x_item_unit_of_measure is valid
            PO_VAL_LINES2.unit_meas_lookup_code(p_id_tbl                         => p_lines.interface_id,
                                                p_unit_meas_lookup_code_tbl      => p_lines.unit_meas_lookup_code,
                                                p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                                p_item_id_tbl                    => p_lines.item_id,
                                                p_line_type_id_tbl               => p_lines.line_type_id,
                                                p_inventory_org_id               => l_inventory_org_id,
                                                x_result_set_id                  => l_result_set_id,
                                                x_results                        => x_results,
                                                x_result_type                    => l_result_type);
          WHEN c_item_revision THEN
            --  if order_type_lookup_code is FIXED PRICE or RATE, or item id is null, then item revision has to
            --  be NULL. Check to see if there are x_item_revision exists in mtl_item_revisions table
            PO_VAL_LINES2.item_revision(p_id_tbl                         => p_lines.interface_id,
                                        p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                        p_item_revision_tbl              => p_lines.item_revision,
                                        p_item_id_tbl                    => p_lines.item_id,
                                        x_result_set_id                  => l_result_set_id,
                                        x_results                        => x_results,
                                        x_result_type                    => l_result_type);
          WHEN c_category_id THEN
            -- Validate and make sure category_id is a valid category within the default category set for Purchasing.
            -- Validate if X_category_id belong to the X_item.  Check if the Purchasing Category set has
            -- 'Validate flag' ON. If Yes, we will validate the Category to exist in the 'Valid Category List'.
            -- If No, we will just validate if the category is Enable and Active.
            PO_VAL_LINES2.category_id(p_id_tbl                         => p_lines.interface_id,
                                      p_category_id_tbl                => p_lines.category_id,
                                      p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                      p_item_id_tbl                    => p_lines.item_id,
                                      p_inventory_org_id               => l_inventory_org_id,
                                      x_result_set_id                  => l_result_set_id,
                                      x_results                        => x_results,
                                      x_result_type                    => l_result_type);
          WHEN c_ip_category_id THEN
            -- Validate ip_category_id is not empty
            -- Validate ip_category_id is valid if not empty.
            PO_VAL_LINES2.ip_category_id(p_id_tbl                      => p_lines.interface_id,
                                         p_ip_category_id_tbl          => p_lines.ip_category_id,
                                         x_result_set_id               => l_result_set_id,
                                         x_results                     => x_results,
                                         x_result_type                 => l_result_type);
          WHEN c_unit_price THEN
            --If order_type_lookup_code is not  'FIXED PRICE', unit_price cannot be null and cannot be less than zero.
            --If line_type_id is not null and order_type_lookup_code is 'AMOUNT', unit_price should be the same as the one defined in the line_type.
            --If order_type_lookup_code is 'FIXED PRICE', unit_price has to be null.
            PO_VAL_LINES2.unit_price(p_id_tbl                         => p_lines.interface_id,
                                     p_unit_price_tbl                 => p_lines.unit_price,
                                     p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                     p_line_type_id_tbl               => p_lines.line_type_id,
                                     x_result_set_id                  => l_result_set_id,
                                     x_results                        => x_results,
                                     x_result_type                    => l_result_type);
          WHEN c_quantity THEN
            -- If order_type_lookup_code is not 'FIXED PRICE' or 'RATE', quantity cannot be less than zero
            -- If order_type_lookup_code is 'FIXED PRICE' or 'RATE', quantity has to be null.
            PO_VAL_LINES2.quantity(p_id_tbl                         => p_lines.interface_id,
                                   p_quantity_tbl                   => p_lines.quantity,
                                   p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                   x_results                        => x_results,
                                   x_result_type                    => l_result_type);
          WHEN c_amount THEN
            -- If order_type_lookup_code is not 'FIXED PRICE' or 'RATE', amount has to be null
            PO_VAL_LINES2.amount(p_id_tbl                         => p_lines.interface_id,
                                 p_amount_tbl                     => p_lines.amount,
                                 p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                 x_results                        => x_results,
                                 x_result_type                    => l_result_type);
          WHEN c_rate_type THEN
            -- For rate based temp labor line, the currency rate_type cannot be 'user'
            PO_VAL_LINES2.rate_type(p_id_tbl                         => p_lines.interface_id,
                                    p_rate_type_tbl                  => p_lines.hdr_rate_type,
                                    p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                    x_results                        => x_results,
                                    x_result_type                    => l_result_type);
          WHEN c_line_num THEN
            -- Line num must be populated and cannot be <= 0.
            -- Line num has to be unique in a requisition.
            PO_VAL_LINES2.line_num(p_id_tbl                         => p_lines.interface_id,
                                   p_po_header_id_tbl               => p_lines.po_header_id,
                                   p_line_num_tbl                   => p_lines.line_num,
                                   p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                   p_draft_id_tbl                   => p_lines.draft_id, -- bug5129752
                                   x_result_set_id                  => l_result_set_id,
                                   x_results                        => x_results,
                                   x_result_type                    => l_result_type);
          WHEN c_po_line_id THEN
            -- Po_line_id must be populated and unique.
            PO_VAL_LINES2.po_line_id(p_id_tbl               => p_lines.interface_id,
                                     p_po_line_id_tbl       => p_lines.po_line_id,
                                     p_po_header_id_tbl     => p_lines.po_header_id,
                                     x_result_set_id        => l_result_set_id,
                                     x_result_type          => l_result_type);
          WHEN c_line_type_id THEN
            -- Line type id must be populated and exist in po_line_types_val_v
            PO_VAL_LINES2.line_type_id(p_id_tbl               => p_lines.interface_id,
                                       p_line_type_id_tbl     => p_lines.line_type_id,
                                       x_result_set_id        => l_result_set_id,
                                       x_result_type          => l_result_type);
          WHEN c_line_style_related_info THEN
            PO_VAL_LINES2.style_related_info(p_id_tbl                      => p_lines.interface_id,
                                             p_style_id_tbl                => p_lines.hdr_style_id,
                                             p_line_type_id_tbl            => p_lines.line_type_id,
                                             p_purchase_basis_tbl          => p_lines.purchase_basis,
                                             x_result_set_id               => l_result_set_id,
                                             x_result_type                 => l_result_type);
          WHEN c_price_type_lookup_code THEN
            -- If price_type_lookup_code is not null, it has to be a valid price type in po_lookup_codes
            PO_VAL_LINES2.price_type_lookup_code(p_id_tbl                         => p_lines.interface_id,
                                                 p_price_type_lookup_code_tbl     => p_lines.price_type_lookup_code,
                                                 x_result_set_id                  => l_result_set_id,
                                                 x_result_type                    => l_result_type);
          WHEN c_start_date_standard THEN
            -- Start date is required for Standard PO with purchase basis 'TEMP LABOR'
            -- Expiration date if provided should be later than the start date
            -- If purchase basis is not 'TEMP LABOR', start_date and expiration_date have to be null
            PO_VAL_LINES2.start_date_standard(p_id_tbl                  => p_lines.interface_id,
                                              p_start_date_tbl          => p_lines.start_date,
                                              p_expiration_date_tbl     => p_lines.expiration_date,
                                              p_purchase_basis_tbl      => p_lines.purchase_basis,
                                              x_results                 => x_results,
                                              x_result_type             => l_result_type);
          WHEN c_item_id_standard THEN
            -- If order_type_lookup_code is not 'RATE' or 'FIXED PRICE', and item_id is not null, then bom_item_type cannot be 1 or 2.
            PO_VAL_LINES2.item_id_standard(p_id_tbl                         => p_lines.interface_id,
                                           p_item_id_tbl                    => p_lines.item_id,
                                           p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                           p_inventory_org_id               => l_inventory_org_id,
                                           x_result_set_id                  => l_result_set_id,
                                           x_result_type                    => l_result_type);
          WHEN c_quantity_standard THEN
            -- Quantity cannot be zero for SPO
            -- And qiantity cannot be empty for SPO if order type is QUANTITY/AMOUNT
            PO_VAL_LINES2.quantity_standard(p_id_tbl                         => p_lines.interface_id,
                                            p_quantity_tbl                   => p_lines.quantity,
                                            p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                            x_results                        => x_results,
                                            x_result_type                    => l_result_type);
          WHEN c_amount_standard THEN
            -- If order_type_lookup_code is 'FIXED PRICE' or 'RATE', amount cannot be null
            PO_VAL_LINES2.amount_standard(p_id_tbl                         => p_lines.interface_id,
                                          p_amount_tbl                     => p_lines.amount,
                                          p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                          x_results                        => x_results,
                                          x_result_type                    => l_result_type);
          WHEN c_price_break_lookup_code THEN
            -- bug5016163
            PO_VAL_LINES2.price_break_lookup_code(p_id_tbl                  => p_lines.interface_id,
                                           p_price_break_lookup_code_tbl     => p_lines.price_break_lookup_code,
                                           p_global_agreement_flag_tbl      => p_lines.global_agreement_flag,
                                           p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                           p_purchase_basis_tbl             => p_lines.purchase_basis,
                                           x_result_set_id                  => l_result_set_id,
                                           x_results                        => x_results,
                                           x_result_type                    => l_result_type);
          WHEN c_not_to_exceed_price THEN
            -- If allow_price_override_flag is 'N', then not_to_exceed_price has to be null.
            -- If not_to_exceed_price is not null, then it cannot be less than unit_price.
            PO_VAL_LINES2.not_to_exceed_price(p_id_tbl                       => p_lines.interface_id,
                                              p_not_to_exceed_price_tbl      => p_lines.not_to_exceed_price,
                                              p_allow_price_override_tbl     => p_lines.allow_price_override_flag,
                                              p_unit_price_tbl               => p_lines.unit_price,
                                              x_results                      => x_results,
                                              x_result_type                  => l_result_type);
          WHEN c_uom_update THEN
            -- validate unit_meas_lookup_code against po_lines_all and po_units_of_measure_val_v
            -- for the Update case
            PO_VAL_LINES2.uom_update(p_id_tbl                         => p_lines.interface_id,
                                     p_unit_meas_lookup_code_tbl      => p_lines.unit_meas_lookup_code,
                                     p_order_type_lookup_code_tbl     => p_lines.order_type_lookup_code,
                                     p_po_header_id_tbl               => p_lines.po_header_id,
                                     p_po_line_id_tbl                 => p_lines.po_line_id,
                                     x_results                        => x_results,
                                     x_result_set_id                  => l_result_set_id,
                                     x_result_type                    => l_result_type);
          WHEN c_unit_price_update THEN
            -- In the UPDATE case, unit_price cannot be negative.  Also handle #DEL.
            PO_VAL_LINES2.unit_price_update
            ( p_id_tbl                  => p_lines.interface_id,
              p_po_line_id_tbl          => p_lines.po_line_id, -- bug5008206
              p_draft_id_tbl            => p_lines.draft_id, -- bug5258790
              p_unit_price_tbl          => p_lines.unit_price,
              x_results                 => x_results,
              x_result_set_id           => l_result_set_id, -- bug5008206
              x_result_type             => l_result_type
            );

          WHEN c_amount_update THEN
            -- In the UPDATE case, unit_price cannot be negative.  Also handle #DEL.
            PO_VAL_LINES2.amount_update
            ( p_id_tbl                  => p_lines.interface_id,
              p_po_line_id_tbl          => p_lines.po_line_id, -- bug5008206
              p_draft_id_tbl            => p_lines.draft_id, -- bug5258790
              p_amount_tbl              => p_lines.amount,
              x_results                 => x_results,
              x_result_set_id           => l_result_set_id, -- bug5008206
              x_result_type             => l_result_type
            );

          WHEN c_item_desc_update THEN
            PO_VAL_LINES2.item_desc_update(p_id_tbl                    => p_lines.interface_id,
                                           p_item_description_tbl      => p_lines.item_description,
                                           p_item_id_tbl               => p_lines.item_id,
                                           p_inventory_org_id          => l_inventory_org_id,
                                           p_po_header_id_tbl          => p_lines.po_header_id,
                                           p_po_line_id_tbl            => p_lines.po_line_id,
                                           x_results                   => x_results,
                                           x_result_set_id             => l_result_set_id,
                                           x_result_type               => l_result_type);
          WHEN c_ip_category_id_update THEN
            -- Validate ip_category_id is valid if not empty.
            PO_VAL_LINES2.ip_category_id_update(p_id_tbl             => p_lines.interface_id,
                                                p_ip_category_id_tbl => p_lines.ip_category_id,
                                                x_result_set_id      => l_result_set_id,
                                                x_results            => x_results,
                                                x_result_type        => l_result_type);
          WHEN c_negotiated_by_preparer THEN
            ----------------------------------------------------------------------------------------
            -- Called in create case for Blanket AND SPO, negotiated_by_preparer must be 'Y' or 'N'.
            ----------------------------------------------------------------------------------------
            PO_VAL_LINES2.negotiated_by_preparer(p_id_tbl                      => p_lines.interface_id,
                                                 p_negotiated_by_preparer_tbl  => p_lines.negotiated_by_preparer_flag,
                                                 x_results                     => x_results,
                                                 x_result_type                 => l_result_type);
          WHEN c_negotiated_by_prep_update THEN
            --------------------------------------------------------------------------------------
            -- Called in update case for Blanket, negotiated_by_preparer must be NULL, 'Y' or 'N'.
            --------------------------------------------------------------------------------------
            PO_VAL_LINES2.negotiated_by_prep_update(p_id_tbl                      => p_lines.interface_id,
                                                    p_negotiated_by_preparer_tbl  => p_lines.negotiated_by_preparer_flag,
                                                    x_results                     => x_results,
                                                    x_result_type                 => l_result_type);
          WHEN c_category_id_update THEN
            -------------------------------------------------------------------------
            -- If either item_id or job_id are populated, then you are not allowed to change the po_category_id
            -- If change is allowed, the new category_id must be valid.
            -------------------------------------------------------------------------
            PO_VAL_LINES2.category_id_update(p_id_tbl                      => p_lines.interface_id,
                                             p_category_id_tbl             => p_lines.category_id,
                                             p_po_line_id_tbl              => p_lines.po_line_id,
                                             p_order_type_lookup_code_tbl  => p_lines.order_type_lookup_code,
                                             p_item_id_tbl                 => p_lines.item_id,
                                             p_job_id_tbl                  => p_lines.job_id,
                                             p_inventory_org_id            => l_inventory_org_id,
                                             x_result_set_id               => l_result_set_id,
                                             x_results                     => x_results,
                                             x_result_type                 => l_result_type);

          WHEN c_negotiated_by_preparer_null THEN
            --------------------------------------------------------------------------------------
            -- Negotiated by preparer flag must be Null for Quotation.
            --------------------------------------------------------------------------------------
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.negotiated_by_preparer_flag),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'NEGOTIATED_BY_PREPARER',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'NEGOTIATED_BY_PREPARER',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.negotiated_by_preparer_flag),
                                             x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_category_id_null THEN
            -- Validate category_id cannot be Null
            PO_VALIDATION_HELPER.not_null(p_calling_module     => p_calling_program,
                                          p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.category_id),
                                          p_entity_id_tbl      => p_lines.interface_id,
                                          p_entity_type        => c_entity_type_line,
                                          p_column_name        => 'CATEGORY_ID',
                                          p_message_name       => 'PO_PDOI_COLUMN_NOT_NULL',
                                          p_token1_name        => 'COLUMN_NAME',
                                          p_token1_value       => 'CATEGORY_ID',
                                          p_token2_name        => 'VALUE',
                                          p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.category_id),
                                          p_validation_id      => PO_VAL_CONSTANTS.c_category_id_not_null,
                      x_results            => x_results,
                                          x_result_type        => l_result_type);
          WHEN c_ip_category_id_null THEN
            -- Validate ip_category_id is empty
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.ip_category_id),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'IP_CATEGORY_ID',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'IP_CATEGORY_ID',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.ip_category_id),
                                             x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_line_secondary_uom THEN
            PO_VALIDATION_HELPER.secondary_unit_of_measure(p_id_tbl                      => p_lines.interface_id,
                                                           p_entity_type                 => c_entity_type_line,
                                                           p_secondary_unit_of_meas_tbl  => p_lines.secondary_unit_of_measure,
                                                           p_item_id_tbl                 => p_lines.item_id,
                                                           p_item_tbl                    => p_lines.item,
                                                           p_organization_id_tbl         => p_lines.inventory_org_id,
                                                           p_doc_type                    => l_doc_type,
                                                           p_create_or_update_item_flag  => l_create_or_update_item,
                                                           x_results                     => x_results,
                                                           x_result_type                 => l_result_type);
          WHEN c_line_secondary_quantity THEN
            PO_VALIDATION_HELPER.secondary_quantity(p_id_tbl                      => p_lines.interface_id,
                                                    p_entity_type                 => c_entity_type_line,
                                                    p_secondary_quantity_tbl      => p_lines.secondary_quantity,
                                                    p_order_type_lookup_code_tbl  => p_lines.order_type_lookup_code,
                                                    p_item_id_tbl                 => p_lines.item_id,
                                                    p_item_tbl                    => p_lines.item,
                                                    p_organization_id_tbl         => p_lines.inventory_org_id,
                                                    p_doc_type                    => l_doc_type,
                                                    p_create_or_update_item_flag  => l_create_or_update_item,
                                                    x_results                     => x_results,
                                                    x_result_type                 => l_result_type);
          WHEN c_line_preferred_grade THEN
            PO_VALIDATION_HELPER.preferred_grade(p_id_tbl                      => p_lines.interface_id,
                                                 p_entity_type                 => c_entity_type_line,
                                                 p_preferred_grade_tbl         => p_lines.preferred_grade,
                                                 p_item_id_tbl                 => p_lines.item_id,
                                                 p_item_tbl                    => p_lines.item,
                                                 p_organization_id_tbl         => p_lines.inventory_org_id,
                                                 p_create_or_update_item_flag  => l_create_or_update_item,
                                               p_validation_id               => PO_VAL_CONSTANTS.c_line_preferred_grade,
                           x_results                     => x_results,
                                                 x_result_set_id               => l_result_set_id,
                                                 x_result_type                 => l_result_type);
          WHEN c_release_num_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.release_num),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'RELEASE_NUM',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'RELEASE_NUM',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.release_num),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_release_num_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_po_release_id_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.po_release_id),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'PO_RELEASE_ID',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'PO_RELEASE_ID',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.po_release_id),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_po_release_id_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_source_shipment_id_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.source_shipment_id),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'SOURCE_SHIPMENT_ID',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'SOURCE_SHIPMENT_ID',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.source_shipment_id),
                                             x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_contract_num_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.contract_num),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'CONTRACT_NUM',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'CONTRACT_NUM',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.contract_num),
                                             x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_contract_id_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.contract_id),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'CONTRACT_ID',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'CONTRACT_ID',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.contract_id),
                                             x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_type_1099_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.type_1099),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'TYPE_1099',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'TYPE_1099',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.type_1099),
                                             x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_closed_code_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.closed_code),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'CLOSED_CODE',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'CLOSED_CODE',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.closed_code),
                                             x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_closed_date_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.closed_date),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'CLOSED_DATE',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'CLOSED_DATE',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.closed_date),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_closed_date_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_closed_by_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.closed_by),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'CLOSED_BY',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'CLOSED_BY',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.closed_by),
                                             x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_over_tolerance_err_flag_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.over_tolerance_error_flag),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'OVER_TOLERANCE_ERROR_FLAG',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'OVER_TOLERANCE_ERROR_FLAG',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.over_tolerance_error_flag),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_over_tolerance_err_flag_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_committed_amount_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.committed_amount),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'COMMITTED_AMOUNT',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'COMMITTED_AMOUNT',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.committed_amount),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_committed_amount_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_allow_price_override_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.allow_price_override_flag),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'ALLOW_PRICE_OVERRIDE_FLAG',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'ALLOW_PRICE_OVERRIDE_FLAG',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.allow_price_override_flag),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_allow_price_override_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_negotiated_by_preparer_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.negotiated_by_preparer_flag),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'NEGOTIATED_BY_PREPARER_FLAG',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'NEGOTIATED_BY_PREPARER_FLAG',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.negotiated_by_preparer_flag),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_negotiated_by_preparer_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_capital_expense_flag_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.capital_expense_flag),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'CAPITAL_EXPENSE_FLAG',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'CAPITAL_EXPENSE_FLAG',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.capital_expense_flag),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_capital_expense_flag_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_min_release_amount_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.min_release_amount),
                                             p_entity_id_tbl      => p_lines.interface_id,
                                             p_entity_type        => c_entity_type_line,
                                             p_column_name        => 'MIN_RELEASE_AMOUNT',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'MIN_RELEASE_AMOUNT',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.min_release_amount),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_min_release_amount_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
           -- <PDOI for Complex PO Project: Start>
          WHEN c_pdoi_qty_ge_qty_mstone_exec THEN
            PO_VAL_LINES.qty_ge_qty_milestone_exec(
              p_line_id_tbl => p_lines.po_line_id	-- Bug#18225635: po_line_id should be passed
            , p_quantity_tbl => p_lines.quantity
            , x_result_set_id => l_result_set_id
            , x_result_type => l_result_type
            );
          WHEN c_pdoi_prc_ge_prc_mstone_exec THEN
            PO_VAL_LINES.price_ge_price_milestone_exec(
              p_line_id_tbl => p_lines.po_line_id	-- Bug#18225635: po_line_id should be passed
            , p_price_tbl => p_lines.unit_price
            , x_result_set_id => l_result_set_id
            , x_result_type => l_result_type
            );
          WHEN c_pdoi_recoupment_range_check THEN
            PO_VAL_LINES.recoupment_rate_range_check(
              p_line_id_tbl  => p_lines.interface_id
            , p_recoupment_rate_tbl => p_lines.recoupment_rate
            , x_results     => x_results
            , x_result_type => l_result_type
            );
          WHEN c_pdoi_retainage_range_check THEN
            PO_VAL_LINES.retainage_rate_range_check(
              p_line_id_tbl  => p_lines.interface_id
            , p_retainage_rate_tbl => p_lines.retainage_rate
            , x_results     => x_results
            , x_result_type => l_result_type
            );
          WHEN c_pdoi_prog_pay_range_check THEN
            PO_VAL_LINES.prog_pay_rate_range_check(
              p_line_id_tbl  => p_lines.interface_id
            , p_prog_pay_rate_tbl => p_lines.progress_payment_rate
            , x_results     => x_results
            , x_result_type => l_result_type
            );
          WHEN c_pdoi_max_retain_amt_ge_zero THEN
            PO_VAL_LINES.max_retain_amt_ge_zero (
              p_line_id_tbl  => p_lines.interface_id
            , p_max_retain_amt_tbl => p_lines.max_retainage_amount
            , x_results     => x_results
            , x_result_type => l_result_type
            );
          WHEN c_pdoi_max_retain_amt_ge_retnd THEN
            PO_VAL_LINES.max_retain_amt_ge_retained (
              p_line_id_tbl  => p_lines.interface_id
            , p_max_retain_amt_tbl => p_lines.max_retainage_amount
            , x_result_set_id => l_result_set_id
            , x_result_type => l_result_type
            );
          WHEN c_pdoi_amt_ge_line_advance_amt THEN
            PO_VAL_LINES.advance_amt_le_amt(
              p_line_id_tbl  => p_lines.interface_id
            , p_advance_tbl  => p_lines.advance_amount
            , p_amount_tbl   => p_lines.amount
            , p_quantity_tbl => p_lines.quantity
            , p_price_tbl    => p_lines.unit_price
            , x_results      => x_results
            , x_result_type  => l_result_type
            );
          WHEN c_pdoi_complex_po_att_check THEN
            PO_VAL_LINES.complex_po_attributes_check(
              p_line_id_tbl         => p_lines.interface_id
            , p_style_id_tbl        => p_lines.hdr_style_id
            , p_retainage_rate_tbl  => p_lines.retainage_rate
            , p_max_retain_amt_tbl  => p_lines.max_retainage_amount
            , p_prog_pay_rate_tbl   => p_lines.progress_payment_rate
            , p_recoupment_rate_tbl => p_lines.recoupment_rate
            , p_advance_tbl         => p_lines.advance_amount
            , x_results             => x_results
            , x_result_type         => l_result_type
            );
          -- <PDOI for Complex PO Project: End>
          WHEN c_qty_rcv_exception_code_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.qty_rcv_exception_code),
                                               p_entity_id_tbl      => p_lines.interface_id,
                                               p_entity_type        => c_entity_type_line,
                                               p_column_name        => 'QTY_RCV_EXCEPTION_CODE',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'QTY_RCV_EXCEPTION_CODE',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.qty_rcv_exception_code),
                                               x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_market_price_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.market_price),
                                               p_entity_id_tbl      => p_lines.interface_id,
                                               p_entity_type        => c_entity_type_line,
                                               p_column_name        => 'MARKET_PRICE',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'MARKET_PRICE',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_lines.market_price),
                                               p_validation_id      => PO_VAL_CONSTANTS.c_market_price_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;

          WHEN c_validate_source_doc THEN
             PO_VAL_LINES2.validate_source_doc(
                       p_id_tbl                       => p_lines.interface_id,
                       p_from_header_id_tbl           => p_lines.from_header_id,
                       p_from_line_id_tbl             => p_lines.from_line_id,
                       p_contract_id_tbl              => p_lines.contract_id,
                       p_org_id_tbl                   => p_lines.org_id,
                       p_item_id_tbl                  => p_lines.item_id,
                       p_item_rev_tbl                 => p_lines.item_revision,
                       p_item_descp_tbl               => p_lines.item_description,
                       p_job_id_tbl                   => p_lines.job_id,
                       p_order_type_lookup_tbl        => p_lines.order_type_lookup_code,
                       p_purchase_basis_tbl           => p_lines.purchase_basis,
                       p_matching_basis_tbl           => p_lines.matching_basis,
                       p_category_id                  => p_lines.category_id,
                       p_uom_tbl                      => p_lines.unit_meas_lookup_code,
                       p_vendor_id_tbl                => p_lines.hdr_vendor_id,
                       p_vendor_site_id_tbl           => p_lines.hdr_vendor_site_id,
                       p_currency_code_tbl            => p_lines.hdr_currency_code,
                       p_style_id_tbl                 => p_lines.hdr_style_id,
                       p_unit_price_tbl               => p_lines.unit_price,
                       x_results                      => x_results,
                       x_result_set_id                => l_result_set_id,
                       x_result_type                  => l_result_type);

          WHEN c_validate_req_reference THEN
             PO_VAL_LINES2.validate_req_reference(
                       p_id_tbl                       => p_lines.interface_id,
                       p_po_line_id_tbl               => p_lines.po_line_id,
                       p_req_line_id_tbl              => p_lines.requisition_line_id,
                       p_from_header_id_tbl           => p_lines.from_header_id,
                       p_contract_id_tbl              => p_lines.contract_id,
                       p_style_id_tbl                 => p_lines.hdr_style_id,
                       p_purchasing_org_id_tbl        => p_lines.org_id,
                       p_item_id_tbl                  => p_lines.item_id,
                       p_job_id_tbl                   => p_lines.job_id,
                       p_purchase_basis_tbl           => p_lines.purchase_basis,
                       p_matching_basis_tbl           => p_lines.matching_basis,
                       p_document_type_tbl            => p_lines.hdr_type_lookup_code,
                       p_cons_from_supp_flag_tbl      => p_lines.cons_from_supp_flag,
                       p_txn_flow_header_id_tbl       => p_lines.txn_flow_header_id,
                       p_vendor_id_tbl                => p_lines.hdr_vendor_id,
                       p_vendor_site_id_tbl           => p_lines.hdr_vendor_site_id,
                       x_results                      => x_results,
                       x_result_set_id                => l_result_set_id,
                       x_result_type                  => l_result_type);

          WHEN c_oke_contract_header THEN
              PO_VAL_LINES2.validate_oke_contract_hdr(
                   p_line_id_tbl          => p_lines.interface_id
                 , p_oke_contract_hdr_tbl => p_lines.oke_contract_header_id
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

          WHEN c_oke_contract_version THEN
              PO_VAL_LINES2.validate_oke_contract_ver(
                   p_line_id_tbl          => p_lines.interface_id
                 , p_oke_contract_hdr_tbl => p_lines.oke_contract_header_id
                 , p_oke_contract_ver_tbl => p_lines.oke_contract_version_id
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

    ---------------------------------------------------------------
    -- Shipment Validations
    ---------------------------------------------------------------
    -- ECO 4503425: Removed the planned item null date check as this
    -- has been moved to submission checks

    WHEN c_days_early_gte_zero THEN
      PO_VAL_SHIPMENTS.days_early_gte_zero(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_days_early_rcpt_allowed_tbl => p_line_locations.days_early_receipt_allowed
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_days_late_gte_zero THEN
      PO_VAL_SHIPMENTS.days_late_gte_zero(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_days_late_rcpt_allowed_tbl => p_line_locations.days_late_receipt_allowed
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_rcv_close_tol_within_range THEN
      PO_VAL_SHIPMENTS.rcv_close_tol_within_range(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_receive_close_tolerance_tbl => p_line_locations.receive_close_tolerance
      , x_results     => x_results
      , x_result_type => l_result_type
      );

    WHEN c_over_rcpt_tol_within_range THEN
      PO_VAL_SHIPMENTS.over_rcpt_tol_within_range(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_qty_rcv_tolerance_tbl => p_line_locations.qty_rcv_tolerance
      , x_results     => x_results
      , x_result_type => l_result_type
      );

    WHEN c_match_4way_check THEN
      PO_VAL_SHIPMENTS.match_4way_check(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_value_basis_tbl => p_line_locations.value_basis -- <Complex Work R12>
      , p_receipt_required_flag_tbl => p_line_locations.receipt_required_flag
      , p_inspection_required_flag_tbl => p_line_locations.inspection_required_flag
      -- <Complex Work R12>: Pass payment_type
      , p_payment_type_tbl => p_line_locations.payment_type
      , x_results     => x_results
      , x_result_type => l_result_type
      );

    WHEN c_inv_close_tol_range_check THEN
      PO_VAL_SHIPMENTS.inv_close_tol_range_check(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_invoice_close_tolerance_tbl => p_line_locations.invoice_close_tolerance
      , x_results     => x_results
      , x_result_type => l_result_type
      );

    WHEN c_need_by_date_open_per_check THEN
      PO_VAL_SHIPMENTS.need_by_date_open_period_check(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      --PBWC Message Change Impact: Adding a token
      , p_line_id_tbl => p_line_locations.po_line_id
      , p_need_by_date_tbl => p_line_locations.need_by_date
      , p_org_id_tbl => p_line_locations.org_id
      , x_result_set_id => l_result_set_id
      , x_result_type   => l_result_type
      );

    WHEN c_promise_date_open_per_check THEN
      PO_VAL_SHIPMENTS.promise_date_open_period_check(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      --PBWC Message Change Impact: Adding a token
      , p_line_id_tbl => p_line_locations.po_line_id
      , p_promised_date_tbl => p_line_locations.promised_date
      , p_org_id_tbl => p_line_locations.org_id
      , x_result_set_id => l_result_set_id
      , x_result_type   => l_result_type
      );

    WHEN c_ship_to_org_null_check THEN
      PO_VAL_SHIPMENTS.ship_to_org_null_check(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_ship_to_org_id_tbl => p_line_locations.ship_to_organization_id
      , p_shipment_type_tbl => p_line_locations.shipment_type
      , x_results     => x_results
      , x_result_type => l_result_type
      );

    WHEN c_ship_to_loc_null_check THEN
      PO_VAL_SHIPMENTS.ship_to_loc_null_check(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_ship_to_loc_id_tbl => p_line_locations.ship_to_location_id
      , p_shipment_type_tbl => p_line_locations.shipment_type
      , x_results     => x_results
      , x_result_type => l_result_type
      );

    WHEN c_ship_num_gt_zero THEN
      PO_VAL_SHIPMENTS.ship_num_gt_zero(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_shipment_num_tbl => p_line_locations.shipment_num
      -- <Complex Work R12>: Pass payment_type
      , p_payment_type_tbl => p_line_locations.payment_type
      , x_results     => x_results
      , x_result_type => l_result_type
      );

    WHEN c_ship_num_unique_check THEN
      PO_VAL_SHIPMENTS.ship_num_unique_check(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_line_id_tbl => p_line_locations.po_line_id
      , p_shipment_num_tbl => p_line_locations.shipment_num
      -- <Complex Work R12>: Pass in shipment_type
      , p_shipment_type_tbl => p_line_locations.shipment_type
      , x_result_set_id => l_result_set_id
      , x_result_type   => l_result_type
      );

    WHEN c_is_org_in_current_sob_check THEN
      PO_VAL_SHIPMENTS.is_org_in_current_sob_check(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      --PBWC Message Change Impact: Adding a token
      , p_line_id_tbl => p_line_locations.po_line_id
      , p_org_id_tbl => p_line_locations.org_id
      , p_ship_to_org_id_tbl => p_line_locations.ship_to_organization_id
      , p_consigned_flag_tbl => p_line_locations.consigned_flag
      , x_results     => x_results
      , x_result_type => l_result_type
      );

    WHEN c_ship_qty_gt_zero THEN
      PO_VAL_SHIPMENTS.quantity_gt_zero(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_quantity_tbl => p_line_locations.quantity
      , p_shipment_type_tbl => p_line_locations.shipment_type
      , p_value_basis_tbl => p_line_locations.value_basis -- <Complex Work R12>
      , x_results => x_results
      , x_result_type => l_result_type
      );

    -- <Complex Work R12 Start>: Combine qty billed and rcvd into qty exec
    WHEN c_ship_qty_ge_qty_exec THEN
      PO_VAL_SHIPMENTS.quantity_ge_quantity_exec(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_quantity_tbl => p_line_locations.quantity
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );
    -- <Complex Work R12 End>

    WHEN c_ship_amt_gt_zero THEN
      PO_VAL_SHIPMENTS.amount_gt_zero(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_amount_tbl => p_line_locations.amount
      , p_shipment_type_tbl => p_line_locations.shipment_type
      , p_value_basis_tbl => p_line_locations.value_basis -- <Complex Work R12>
      , x_results => x_results
      , x_result_type => l_result_type
      );

    -- <Complex Work R12 Start>: Combine amt billed and rcvd into amt exec
    WHEN c_ship_amt_ge_amt_exec THEN
      PO_VAL_SHIPMENTS.amount_ge_amount_exec(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_amount_tbl => p_line_locations.amount
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );
    -- <Complex Work R12 End>

    -- Opm related validation : OPM Integration R12 Start
    WHEN c_ship_sec_qty_gt_zero THEN
      PO_VAL_SHIPMENTS.ship_sec_quantity_gt_zero(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_item_id_tbl  => p_line_locations.line_item_id
      , p_ship_to_org_id_tbl  => p_line_locations.ship_to_organization_id
      , p_sec_quantity_tbl => p_line_locations.secondary_quantity
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_ship_qtys_within_deviation THEN
      PO_VAL_SHIPMENTS.ship_qtys_within_deviation(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_item_id_tbl  => p_line_locations.line_item_id
      , p_ship_to_org_id_tbl  => p_line_locations.ship_to_organization_id
      , p_quantity_tbl    => p_line_locations.quantity
      , p_primary_uom_tbl  => p_line_locations.unit_meas_lookup_code
      , p_sec_quantity_tbl => p_line_locations.secondary_quantity
      , p_secondary_uom_tbl => p_line_locations.secondary_unit_of_measure
      , x_results => x_results
      , x_result_type => l_result_type
      );
     -- Opm related validation : OPM Integration R12 End

     -- Bug 5385686 : Enforce not null check on UOM
     WHEN c_unit_of_measure_not_null THEN
      PO_VAL_SHIPMENTS.unit_of_measure_not_null(
           p_line_loc_id_tbl  => p_line_locations.line_location_id
	 , p_value_basis_tbl   => p_line_locations.value_basis
         , p_payment_type_tbl  => p_line_locations.payment_type
         , p_unit_meas_lookup_code_tbl => p_line_locations.unit_meas_lookup_code
         , x_results => x_results
         , x_result_type => l_result_type
      );

      -- Bug 110704404
       WHEN c_complex_price_or_gt_zero THEN
      PO_VAL_SHIPMENTS.complex_price_or_gt_zero(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_price_override_tbl => p_line_locations.price_override
      , p_value_basis_tbl   => p_line_locations.value_basis
      , p_payment_type_tbl  => p_line_locations.payment_type
      , x_results => x_results
      , x_result_type => l_result_type
      );
              --------------------------------------------------------------------------
          -- PDOI Shipment Validation Subroutines
          --------------------------------------------------------------------------
          WHEN c_shipment_need_by_date THEN
            -- if purchase_basis is 'TEMP LABOR', the need_by_date column must be null
            PO_VAL_SHIPMENTS2.need_by_date(p_id_tbl                 => p_line_locations.interface_id,
                                           p_purchase_basis_tbl     => p_line_locations.purchase_basis,
                                           p_need_by_date_tbl       => p_line_locations.need_by_date,
                                           x_results                => x_results,
                                           x_result_type            => l_result_type);
          WHEN c_shipment_promised_date THEN
            -- if purchase_basis is 'TEMP LABOR', the promised_date must be null
            PO_VAL_SHIPMENTS2.promised_date(p_id_tbl                 => p_line_locations.interface_id,
                                            p_purchase_basis_tbl     => p_line_locations.purchase_basis,
                                            p_promised_date_tbl      => p_line_locations.promised_date,
                                            x_results                => x_results,
                                            x_result_type            => l_result_type);
          WHEN c_shipment_type_blanket THEN
            -- validate shipment type
            PO_VAL_SHIPMENTS2.shipment_type(p_id_tbl                => p_line_locations.interface_id,
                                            p_shipment_type_tbl     => p_line_locations.shipment_type,
					    p_style_id_tbl          => p_line_locations.hdr_style_id, -- PDOI for Complex PO Project
                                            p_doc_type              => c_doc_type_blanket,
                                            x_results               => x_results,
                                            x_result_type           => l_result_type);
          WHEN c_shipment_type_standard THEN
            -- validate shipment type
            PO_VAL_SHIPMENTS2.shipment_type(p_id_tbl                => p_line_locations.interface_id,
                                            p_shipment_type_tbl     => p_line_locations.shipment_type,
					    p_style_id_tbl          => p_line_locations.hdr_style_id, -- PDOI for Complex PO Project
                                            p_doc_type              => c_doc_type_standard,
                                            x_results               => x_results,
                                            x_result_type           => l_result_type);
          WHEN c_shipment_type_quotation THEN
            -- validate shipment type
            PO_VAL_SHIPMENTS2.shipment_type(p_id_tbl                => p_line_locations.interface_id,
                                            p_shipment_type_tbl     => p_line_locations.shipment_type,
					     p_style_id_tbl          => p_line_locations.hdr_style_id, -- PDOI for Complex PO Project
                                            p_doc_type              => c_doc_type_quotation,
                                            x_results               => x_results,
                                            x_result_type           => l_result_type);
          WHEN c_shipment_num THEN
            -- validate shipment num is not null, greater than zero and unique
            -- bug 4642348: add two parameters - p_draft_id_tbl, p_doc_type
            PO_VAL_SHIPMENTS2.shipment_num(p_id_tbl                => p_line_locations.interface_id,
                                           p_shipment_num_tbl      => p_line_locations.shipment_num,
                                           p_shipment_type_tbl     => p_line_locations.shipment_type,
                                           p_po_header_id_tbl      => p_line_locations.po_header_id,
                                           p_po_line_id_tbl        => p_line_locations.po_line_id,
                                           p_draft_id_tbl          => p_line_locations.draft_id,
					   p_style_id_tbl          => p_line_locations.hdr_style_id, -- PDOI for Complex PO Project
                                           p_doc_type              => l_doc_type,
                                           x_result_set_id         => l_result_set_id,
                                           x_results               => x_results,
                                           x_result_type           => l_result_type);
          WHEN c_terms_id_line_loc THEN
            PO_VALIDATION_HELPER.terms_id(p_calling_module     => p_calling_program,
                                          p_terms_id_tbl       => p_line_locations.terms_id,
                                          p_entity_id_tbl      => p_line_locations.interface_id,
                                          p_entity_type        => c_entity_type_line_location,
                                          p_validation_id      => PO_VAL_CONSTANTS.c_terms_id_line_loc,
                                          x_result_set_id      => l_result_set_id,
                                          x_result_type        => l_result_type);
          WHEN c_shipment_quantity THEN
            -- If order_type_lookup_code is RATE or FIXED PRICE, validate quantity is not null
            PO_VAL_SHIPMENTS2.quantity(p_id_tbl                         => p_line_locations.interface_id,
                                       p_quantity_tbl                   => p_line_locations.quantity,
                                       p_order_type_lookup_code_tbl     => p_line_locations.order_type_lookup_code,
				       p_shipment_type_tbl              => p_line_locations.shipment_type, -- PDOI for Complex PO Project
                                       p_style_id_tbl                   => p_line_locations.hdr_style_id,  -- PDOI for Complex PO Project
                                       p_payment_type_tbl               => p_line_locations.payment_type,  -- PDOI for Complex PO Project
                                       p_line_quantity_tbl              => p_line_locations.line_quantity, -- PDOI for Complex PO Project
                                       x_results                        => x_results,
                                       x_result_type                    => l_result_type);
          WHEN c_shipment_price_override THEN
            -- If order_type_lookup_code is not FIXED PRICE, price_override cannot be null
            PO_VAL_SHIPMENTS2.price_override(p_id_tbl                         => p_line_locations.interface_id,
                                             p_price_override_tbl             => p_line_locations.price_override,
                                             p_order_type_lookup_code_tbl     => p_line_locations.order_type_lookup_code,
  				             p_shipment_type_tbl              => p_line_locations.shipment_type, -- PDOI for Complex PO Project
                                             p_style_id_tbl                   => p_line_locations.hdr_style_id,  -- PDOI for Complex PO Project
                                             p_payment_type_tbl               => p_line_locations.payment_type,  -- PDOI for Complex PO Project
                                             p_line_unit_price_tbl            => p_line_locations.line_unit_price, -- PDOI for Complex PO Project
                                             x_results                        => x_results,
                                             x_result_type                    => l_result_type);
          WHEN c_shipment_price_discount THEN
            -- If order_type_lookup_code is not FIXED PRICE, price_discount/price_override cannot both be null
            -- and price discount cannot be less than zero or greater than 100
            PO_VAL_SHIPMENTS2.price_discount(p_id_tbl                         => p_line_locations.interface_id,
                                             p_price_discount_tbl             => p_line_locations.price_discount,
                                             p_price_override_tbl             => p_line_locations.price_override,
                                             p_order_type_lookup_code_tbl     => p_line_locations.order_type_lookup_code,
                                             x_results                        => x_results,
                                             x_result_type                    => l_result_type);
          WHEN c_ship_to_organization_id THEN
            -- validate ship_to_organization_id
            PO_VAL_SHIPMENTS2.ship_to_organization_id(p_id_tbl                          => p_line_locations.interface_id,
                                                      p_ship_to_organization_id_tbl     => p_line_locations.ship_to_organization_id,
                                                      p_item_id_tbl                     => p_line_locations.item_id,
                                                      p_item_revision_tbl               => p_line_locations.item_revision,
                                                      p_ship_to_location_id_tbl         => p_line_locations.ship_to_location_id,
                                                      x_result_set_id                   => l_result_set_id,
                                                      x_result_type                     => l_result_type);
          WHEN c_shipment_effective_dates THEN
            -- validate_effective_dates
            -- bug5016163
            -- Added price break look up code as parameter
            PO_VAL_SHIPMENTS2.effective_dates(p_id_tbl                       => p_line_locations.interface_id,
                                              p_line_expiration_date_tbl     => p_line_locations.line_expiration_date,
                                              p_to_date_tbl                  => p_line_locations.to_date,
                                              p_from_date_tbl                => p_line_locations.from_date,
                                              p_header_start_date_tbl        => p_line_locations.hdr_start_date,
                                              p_header_end_date_tbl          => p_line_locations.hdr_end_date,
                                              p_price_break_lookup_code_tbl  => p_line_locations.line_price_break_lookup_code,
                                              x_results                      => x_results,
                                              x_result_type                  => l_result_type);
          WHEN c_qty_rcv_exception_code THEN
            -- validate qty_rcv_exception_code against PO_LOOKUP_CODES
            PO_VAL_SHIPMENTS2.qty_rcv_exception_code(p_id_tbl                         => p_line_locations.interface_id,
                                                     p_qty_rcv_exception_code_tbl     => p_line_locations.qty_rcv_exception_code,
                                                     x_result_set_id                  => l_result_set_id,
                                                     x_result_type                    => l_result_type);
          WHEN c_enforce_ship_to_loc_code THEN
            -- If shipment_type is STANDARD and enforce_ship_to_loc_code is not equal
            -- to NONE, REJECT or WARNING
            PO_VAL_SHIPMENTS2.enforce_ship_to_loc_code(p_id_tbl                           => p_line_locations.interface_id,
                                                       p_enforce_ship_to_loc_code_tbl     => p_line_locations.enforce_ship_to_location_code,
                                                       p_shipment_type_tbl                => p_line_locations.shipment_type,
                                                       p_order_type_lookup_tbl            => p_line_locations.order_type_lookup_code, -- <<PDOI Enhancement Bug#17063664>>
                                                       x_results                          => x_results,
                                                       x_result_type                      => l_result_type);
          WHEN c_allow_sub_receipts_flag THEN
            -- If shipment_type is STANDARD and allow_sub_receipts_flag is not equal
            -- to NONE, REJECT or WARNING
            PO_VAL_SHIPMENTS2.allow_sub_receipts_flag(p_id_tbl                          => p_line_locations.interface_id,
                                                      p_shipment_type_tbl               => p_line_locations.shipment_type,
                                                      p_allow_sub_receipts_flag_tbl     => p_line_locations.allow_substitute_receipts_flag,
                                                      p_order_type_lookup_tbl           => p_line_locations.order_type_lookup_code, -- <<PDOI Enhancement Bug#17063664>>
                                                      x_results                         => x_results,
                                                      x_result_type                     => l_result_type);
          WHEN c_days_early_receipt_allowed THEN
            -- If shipment_type is STANDARD and days_early_receipt_allowed is not null
            -- and less than zero.
            PO_VAL_SHIPMENTS2.days_early_receipt_allowed(p_id_tbl                          => p_line_locations.interface_id,
                                                         p_shipment_type_tbl               => p_line_locations.shipment_type,
                                                         p_days_early_rcpt_allowed_tbl     => p_line_locations.days_early_receipt_allowed,
                                                         p_order_type_lookup_tbl           => p_line_locations.order_type_lookup_code, -- <<PDOI Enhancement Bug#17063664>>
                                                         x_results                         => x_results,
                                                         x_result_type                     => l_result_type);
          WHEN c_receipt_days_exception_code THEN
            -- If shipment_type is STANDARD and receipt_days_expection_code is not null
            -- and not 'NONE', 'REJECT' not 'WARNING'
            PO_VAL_SHIPMENTS2.receipt_days_exception_code(p_id_tbl                           => p_line_locations.interface_id,
                                                          p_shipment_type_tbl                => p_line_locations.shipment_type,
                                                          p_rcpt_days_exception_code_tbl     => p_line_locations.receipt_days_exception_code,
                                                          p_order_type_lookup_tbl            => p_line_locations.order_type_lookup_code, -- <<PDOI Enhancement Bug#17063664>>
                                                          x_results                          => x_results,
                                                          x_result_type                      => l_result_type);
          WHEN c_invoice_close_tolerance THEN
            -- If shipment_type is STANDARD and invoice_close_tolerance is not null
            -- and less than or equal to zero or greater than or equal to 100.
            PO_VAL_SHIPMENTS2.invoice_close_tolerance(p_id_tbl                          => p_line_locations.interface_id,
                                                      p_shipment_type_tbl               => p_line_locations.shipment_type,
                                                      p_invoice_close_tolerance_tbl     => p_line_locations.invoice_close_tolerance,
                                                      x_results                         => x_results,
                                                      x_result_type                     => l_result_type);
          WHEN c_receive_close_tolerance THEN
            -- If shipment_type is STANDARD and receive_close_tolerance is not null
            -- and less than or equal to zero or greater than or equal to 100.
            PO_VAL_SHIPMENTS2.receive_close_tolerance(p_id_tbl                          => p_line_locations.interface_id,
                                                      p_shipment_type_tbl               => p_line_locations.shipment_type,
                                                      p_receive_close_tolerance_tbl     => p_line_locations.receive_close_tolerance,
                                                      x_results                         => x_results,
                                                      x_result_type                     => l_result_type);
          WHEN c_receiving_routing_id THEN
            -- Validate that receiving routing id exists in rcv_routing_headers
            PO_VAL_SHIPMENTS2.receiving_routing_id(p_id_tbl                       => p_line_locations.interface_id,
                                                   p_shipment_type_tbl            => p_line_locations.shipment_type,
                                                   p_receiving_routing_id_tbl     => p_line_locations.receiving_routing_id,
                                                   p_order_type_lookup_tbl        => p_line_locations.order_type_lookup_code, -- <<PDOI Enhancement Bug#17063664>>
                                                   x_result_set_id                => l_result_set_id,
                                                   x_result_type                  => l_result_type);
          WHEN c_accrue_on_receipt_flag THEN
            -- Validate accrue_on_receipt_flag is Y or N, if not null.
            PO_VAL_SHIPMENTS2.accrue_on_receipt_flag(p_id_tbl                         => p_line_locations.interface_id,
                                                     p_accrue_on_receipt_flag_tbl     => p_line_locations.accrue_on_receipt_flag,
                                                     x_results                        => x_results,
                                                     x_result_type                    => l_result_type);
          -- <PDOI for Complex PO Project: Start>
          WHEN c_pdoi_amt_ge_ship_advance_amt THEN
            -- Validate advance amount at shipment.
            PO_VAL_SHIPMENTS2.advance_amt_le_amt(p_id_tbl           => p_line_locations.interface_id,
                                                 p_payment_type_tbl => p_line_locations.payment_type,
                                                 p_advance_tbl      => p_line_locations.amount,
                                                 p_amount_tbl       => p_line_locations.line_amount,
                                                 p_quantity_tbl     => p_line_locations.line_quantity,
                                                 p_price_tbl        => p_line_locations.line_unit_price,
                                                 x_results          => x_results,
                                                 x_result_type      => l_result_type);
          WHEN c_pdoi_shipment_amount THEN
            -- Validate amount at shipment.
            PO_VAL_SHIPMENTS2.amount(p_id_tbl                         => p_line_locations.interface_id,
                                     p_amount_tbl                     => p_line_locations.amount,
                                     p_shipment_type_tbl              => p_line_locations.shipment_type,
                                     p_style_id_tbl                   => p_line_locations.hdr_style_id,
                                     p_payment_type_tbl               => p_line_locations.payment_type,
                                     p_line_amount_tbl                => p_line_locations.line_amount,
                                     x_results                        => x_results,
                                     x_result_type                    => l_result_type);
          WHEN c_pdoi_payment_type THEN
            -- Validate payment type.
            PO_VAL_SHIPMENTS2.payment_type(p_id_tbl                   => p_line_locations.interface_id,
                                           po_line_id_tbl             => p_line_locations.po_line_id,
                                           p_style_id_tbl             => p_line_locations.hdr_style_id,
                                           p_payment_type_tbl         => p_line_locations.payment_type,
                                           p_shipment_type_tbl        => p_line_locations.shipment_type,
                                           x_results                  => x_results,
                                           x_result_type              => l_result_type);
	  -- <PDOI for Complex PO Project: End>

         --<PDOI Enhancement Bug#17063664 Start>
         WHEN c_inspection_reqd_flag THEN
           PO_VAL_SHIPMENTS2.inspection_reqd_flag(p_id_tbl                     => p_line_locations.interface_id,
                                                  p_shipment_type_tbl          => p_line_locations.shipment_type,
                                                  p_inspection_reqd_flag_tbl   => p_line_locations.inspection_required_flag,
                                                  p_order_type_lookup_tbl      => p_line_locations.order_type_lookup_code,
                                                  x_result_set_id              => l_result_set_id,
                                                  x_result_type                => l_result_type);

         WHEN c_days_late_receipt_allowed THEN
           PO_VAL_SHIPMENTS2.days_late_rcpt_allowed(p_id_tbl                     => p_line_locations.interface_id,
                                            p_shipment_type_tbl          => p_line_locations.shipment_type,
                                            p_days_late_rcpt_allowed_tbl => p_line_locations.days_late_receipt_allowed,
                                            p_order_type_lookup_tbl      => p_line_locations.order_type_lookup_code,
                                            x_result_set_id              => l_result_set_id,
                                            x_result_type                => l_result_type);

         --<PDOI Enhancement Bug#17063664 End>

          WHEN c_fob_lookup_code_line_loc THEN
            PO_VAL_SHIPMENTS2.fob_lookup_code(p_id_tbl                  => p_line_locations.interface_id,
                                              p_fob_lookup_code_tbl     => p_line_locations.fob_lookup_code,
                                              x_result_set_id           => l_result_set_id,
                                              x_result_type             => l_result_type);
          WHEN c_freight_terms_line_loc THEN
            PO_VAL_SHIPMENTS2.freight_terms(p_id_tbl                  => p_line_locations.interface_id,
                                            p_freight_terms_tbl       => p_line_locations.freight_terms_lookup_code,
                                            x_result_set_id           => l_result_set_id,
                                            x_result_type             => l_result_type);
          WHEN c_freight_carrier_line_loc THEN
            PO_VAL_SHIPMENTS2.freight_carrier(p_id_tbl                => p_line_locations.interface_id,
                                              p_freight_carrier_tbl   => p_line_locations.freight_carrier,
                                              p_inventory_org_id      => l_inventory_org_id,
                                              x_result_set_id         => l_result_set_id,
                                              x_result_type           => l_result_type);
          WHEN c_line_loc_style_related_info THEN
            PO_VAL_SHIPMENTS2.style_related_info(p_id_tbl                => p_line_locations.interface_id,
                                                 p_style_id_tbl          => p_line_locations.hdr_style_id,
                                                 x_result_set_id         => l_result_set_id,
                                                 x_result_type           => l_result_type);
          WHEN c_price_break THEN
            -- Cannot create price breaks for Amount-Based or Fixed Price lines in a Blanket
            -- Purchase Agreement.
            PO_VAL_SHIPMENTS2.price_break(p_id_tbl                         => p_line_locations.interface_id,
                                          p_order_type_lookup_code_tbl     => p_line_locations.order_type_lookup_code,
                                          x_results                        => x_results,
                                          x_result_type                    => l_result_type);
          WHEN c_tax_name THEN
            PO_VAL_SHIPMENTS2.tax_name(p_id_tbl                   => p_line_locations.interface_id,
                                       p_tax_name_tbl             => p_line_locations.tax_name,
                                       p_tax_code_id_tbl          => p_line_locations.tax_code_id,
                                       p_need_by_date_tbl         => p_line_locations.need_by_date,
                                       p_allow_tax_code_override  => l_allow_tax_code_override,
                                       p_operating_unit           => l_operating_unit,
                                       x_result_set_id            => l_result_set_id,
                                       x_result_type              => l_result_type);
          WHEN c_line_loc_secondary_uom THEN
            PO_VALIDATION_HELPER.secondary_unit_of_measure(p_id_tbl                      => p_line_locations.interface_id,
                                                           p_entity_type                 => c_entity_type_line_location,
                                                           p_secondary_unit_of_meas_tbl  => p_line_locations.secondary_unit_of_measure,
                                                           p_item_id_tbl                 => p_line_locations.item_id,
                                                           p_item_tbl                    => p_line_locations.item,
                                                           p_organization_id_tbl         => p_line_locations.ship_to_organization_id,
                                                           p_doc_type                    => l_doc_type,
                                                           p_create_or_update_item_flag  => l_create_or_update_item,
                                                           x_results                     => x_results,
                                                           x_result_type                 => l_result_type);
          WHEN c_line_loc_secondary_quantity THEN
            PO_VALIDATION_HELPER.secondary_quantity(p_id_tbl                      => p_line_locations.interface_id,
                                                    p_entity_type                 => c_entity_type_line_location,
                                                    p_secondary_quantity_tbl      => p_line_locations.secondary_quantity,
                                                    p_order_type_lookup_code_tbl  => p_line_locations.order_type_lookup_code,
                                                    p_item_id_tbl                 => p_line_locations.item_id,
                                                    p_item_tbl                    => p_line_locations.item,
                                                    p_organization_id_tbl         => p_line_locations.ship_to_organization_id,
                                                    p_doc_type                    => l_doc_type,
                                                    p_create_or_update_item_flag  => l_create_or_update_item,
                                                    x_results                     => x_results,
                                                    x_result_type                 => l_result_type);
          WHEN c_line_loc_preferred_grade THEN
            PO_VALIDATION_HELPER.preferred_grade(p_id_tbl                      => p_line_locations.interface_id,
                                                 p_entity_type                 => c_entity_type_line_location,
                                                 p_preferred_grade_tbl         => p_line_locations.preferred_grade,
                                                 p_item_id_tbl                 => p_line_locations.item_id,
                                                 p_item_tbl                    => p_line_locations.item,
                                                 p_organization_id_tbl         => p_line_locations.ship_to_organization_id,
                                                 p_create_or_update_item_flag  => l_create_or_update_item,
                                                 p_validation_id               => PO_VAL_CONSTANTS.c_loc_preferred_grade,
                         x_results                     => x_results,
                                                 x_result_set_id               => l_result_set_id,
                                                 x_result_type                 => l_result_type);
          WHEN c_firm_flag_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.firm_status_lookup_code),
                                             p_entity_id_tbl      => p_line_locations.interface_id,
                                             p_entity_type        => c_entity_type_line_location,
                                             p_column_name        => 'FIRM_FLAG',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'FIRM_FLAG',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.firm_status_lookup_code),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_firm_flag_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_freight_carrier_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.freight_carrier),
                                             p_entity_id_tbl      => p_line_locations.interface_id,
                                             p_entity_type        => c_entity_type_line_location,
                                             p_column_name        => 'FREIGHT_CARRIER',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'FREIGHT_CARRIER',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.freight_carrier),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_freight_carrier_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_fob_lookup_code_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.fob_lookup_code),
                                             p_entity_id_tbl      => p_line_locations.interface_id,
                                             p_entity_type        => c_entity_type_line_location,
                                             p_column_name        => 'FOB_LOOKUP_CODE',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'FOB_LOOKUP_CODE',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.fob_lookup_code),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_fob_lookup_code_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_freight_terms_lookup_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.freight_terms_lookup_code),
                                             p_entity_id_tbl      => p_line_locations.interface_id,
                                             p_entity_type        => c_entity_type_line_location,
                                             p_column_name        => 'FREIGHT_TERMS_LOOKUP_CODE',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'FREIGHT_TERMS_LOOKUP_CODE',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.freight_terms_lookup_code),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_freight_terms_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_qty_rcv_tolerance_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.qty_rcv_tolerance),
                                               p_entity_id_tbl      => p_line_locations.interface_id,
                                               p_entity_type        => c_entity_type_line_location,
                                               p_column_name        => 'QTY_RCV_TOLERANCE',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'QTY_RCV_TOLERANCE',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.qty_rcv_tolerance),
                                               p_validation_id      => PO_VAL_CONSTANTS.c_qty_rcv_tolerance_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_receipt_required_flag_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.receipt_required_flag),
                                               p_entity_id_tbl      => p_line_locations.interface_id,
                                               p_entity_type        => c_entity_type_line_location,
                                               p_column_name        => 'RECEIPT_REQUIRED_FLAG',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'RECEIPT_REQUIRED_FLAG',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.receipt_required_flag),
                                               p_validation_id      => PO_VAL_CONSTANTS.c_receipt_reqd_flag_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_inspection_reqd_flag_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.inspection_required_flag),
                                               p_entity_id_tbl      => p_line_locations.interface_id,
                                               p_entity_type        => c_entity_type_line_location,
                                               p_column_name        => 'INSPECTION_REQUIRED_FLAG',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_validation_id      => PO_VAL_CONSTANTS.c_inspection_reqd_flag_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_receipt_days_exception_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.receipt_days_exception_code),
                                               p_entity_id_tbl      => p_line_locations.interface_id,
                                               p_entity_type        => c_entity_type_line_location,
                                               p_column_name        => 'RECEIPT_DAYS_EXCEPTION_CODE',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'RECEIPT_DAYS_EXCEPTION_CODE',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.receipt_days_exception_code),
                                               p_validation_id      => PO_VAL_CONSTANTS.c_receipt_days_except_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_invoice_close_toler_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.invoice_close_tolerance),
                                               p_entity_id_tbl      => p_line_locations.interface_id,
                                               p_entity_type        => c_entity_type_line_location,
                                               p_column_name        => 'INVOICE_CLOSE_TOLERANCE',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'INVOICE_CLOSE_TOLERANCE',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.invoice_close_tolerance),
                                               p_validation_id      => PO_VAL_CONSTANTS.c_invoice_close_toler_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_receive_close_toler_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.receive_close_tolerance),
                                               p_entity_id_tbl      => p_line_locations.interface_id,
                                               p_entity_type        => c_entity_type_line_location,
                                               p_column_name        => 'RECEIVE_CLOSE_TOLERANCE',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'RECEIVE_CLOSE_TOLERANCE',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.receive_close_tolerance),
                                               p_validation_id      => PO_VAL_CONSTANTS.c_receive_close_toler_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_days_early_rcpt_allowed_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.days_early_receipt_allowed),
                                               p_entity_id_tbl      => p_line_locations.interface_id,
                                               p_entity_type        => c_entity_type_line_location,
                                               p_column_name        => 'DAYS_EARLY_RECEIPT_ALLOWED',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'DAYS_EARLY_RECEIPT_ALLOWED',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.days_early_receipt_allowed),
                                               p_validation_id      => PO_VAL_CONSTANTS.c_days_early_rcpt_allowed_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_days_late_rcpt_allowed_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.days_late_receipt_allowed),
                                               p_entity_id_tbl      => p_line_locations.interface_id,
                                               p_entity_type        => c_entity_type_line_location,
                                               p_column_name        => 'DAYS_LATE_RECEIPT_ALLOWED',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'DAYS_LATE_RECEIPT_ALLOWED',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.days_late_receipt_allowed),
                                               p_validation_id      => PO_VAL_CONSTANTS.c_days_late_rcpt_allowed_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_enfrce_ship_to_loc_code_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.enforce_ship_to_location_code),
                                               p_entity_id_tbl      => p_line_locations.interface_id,
                                               p_entity_type        => c_entity_type_line_location,
                                               p_column_name        => 'ENFORCE_SHIP_TO_LOCATION_CODE',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'ENFORCE_SHIP_TO_LOCATION_CODE',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.enforce_ship_to_location_code),
                                               p_validation_id      => PO_VAL_CONSTANTS.c_enforce_shipto_loc_code_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_allow_sub_receipts_flag_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.allow_substitute_receipts_flag),
                                               p_entity_id_tbl      => p_line_locations.interface_id,
                                               p_entity_type        => c_entity_type_line_location,
                                               p_column_name        => 'ALLOW_SUBSTITUTE_RECEIPTS_FLAG',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'ALLOW_SUBSTITUTE_RECEIPTS_FLAG',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.allow_substitute_receipts_flag),
                                               p_validation_id      => PO_VAL_CONSTANTS.c_allow_sub_receipts_flag_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_receiving_routing_null THEN
            IF l_create_or_update_item <> 'Y' THEN
              PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                               p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.receiving_routing_id),
                                               p_entity_id_tbl      => p_line_locations.interface_id,
                                               p_entity_type        => c_entity_type_line_location,
                                               p_column_name        => 'RECEIVING_ROUTING_ID',
                                               p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                               p_token1_name        => 'COLUMN_NAME',
                                               p_token1_value       => 'RECEIVING_ROUTING_ID',
                                               p_token2_name        => 'VALUE',
                                               p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.receiving_routing_id),
                                               p_validation_id      => PO_VAL_CONSTANTS.c_receiving_routing_null,
                         x_results            => x_results,
                                               x_result_type        => l_result_type);
            END IF;
          WHEN c_need_by_date_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.need_by_date),
                                             p_entity_id_tbl      => p_line_locations.interface_id,
                                             p_entity_type        => c_entity_type_line_location,
                                             p_column_name        => 'NEED_BY_DATE',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'NEED_BY_DATE',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.need_by_date),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_need_by_date_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);
          WHEN c_promised_date_null THEN
            PO_VALIDATION_HELPER.ensure_null(p_calling_module     => p_calling_program,
                                             p_value_tbl          => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.promised_date),
                                             p_entity_id_tbl      => p_line_locations.interface_id,
                                             p_entity_type        => c_entity_type_line_location,
                                             p_column_name        => 'PROMISED_DATE',
                                             p_message_name       => 'PO_PDOI_COLUMN_NULL',
                                             p_token1_name        => 'COLUMN_NAME',
                                             p_token1_value       => 'PROMISED_DATE',
                                             p_token2_name        => 'VALUE',
                                             p_token2_value_tbl   => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_line_locations.promised_date),
                                             p_validation_id      => PO_VAL_CONSTANTS.c_promised_date_null,
                       x_results            => x_results,
                                             x_result_type        => l_result_type);


    ---------------------------------------------------------------
    -- Price Break Validations
    ---------------------------------------------------------------

    WHEN c_at_least_one_required_field THEN
      IF (p_calling_program = c_program_PDOI) THEN
        PO_VAL_PRICE_BREAKS.at_least_one_required_field(
          p_line_loc_id_tbl => p_line_locations.interface_id
        , p_start_date_tbl => p_line_locations.from_date
        , p_end_date_tbl => p_line_locations.to_date
        , p_quantity_tbl => p_line_locations.quantity
        , p_ship_to_org_id_tbl => p_line_locations.ship_to_organization_id
        , p_ship_to_loc_id_tbl => p_line_locations.ship_to_location_id
        , x_results => x_results
        , x_result_type => l_result_type
        );
      ELSE
        PO_VAL_PRICE_BREAKS.at_least_one_required_field(
          p_line_loc_id_tbl => p_line_locations.line_location_id
        , p_start_date_tbl => p_line_locations.start_date
        , p_end_date_tbl => p_line_locations.end_date
        , p_quantity_tbl => p_line_locations.quantity
        , p_ship_to_org_id_tbl => p_line_locations.ship_to_organization_id
        , p_ship_to_loc_id_tbl => p_line_locations.ship_to_location_id
        , x_results => x_results
        , x_result_type => l_result_type
        );
      END IF;

    WHEN c_price_discount_in_percent THEN
      PO_VAL_PRICE_BREAKS.price_discount_in_percent(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_price_discount_tbl => p_line_locations.price_discount
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_price_override_gt_zero THEN
      PO_VAL_PRICE_BREAKS.price_override_gt_zero(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_price_override_tbl => p_line_locations.price_override
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_price_break_qty_ge_zero THEN
      PO_VAL_PRICE_BREAKS.quantity_ge_zero(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_quantity_tbl => p_line_locations.quantity
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_price_break_start_le_end THEN
      PO_VAL_PRICE_BREAKS.start_date_le_end_date(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_start_date_tbl => p_line_locations.start_date
      , p_end_date_tbl => p_line_locations.end_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_break_start_ge_blanket_start THEN
      PO_VAL_PRICE_BREAKS.break_start_ge_blanket_start(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_blanket_start_date_tbl => p_line_locations.hdr_start_date
      , p_price_break_start_date_tbl => p_line_locations.start_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_break_start_le_blanket_end THEN
      PO_VAL_PRICE_BREAKS.break_start_le_blanket_end(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_blanket_end_date_tbl => p_line_locations.hdr_end_date
      , p_price_break_start_date_tbl => p_line_locations.start_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_break_start_le_expiration THEN
      PO_VAL_PRICE_BREAKS.break_start_le_expiration(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_expiration_date_tbl => p_line_locations.line_expiration_date
      , p_price_break_start_date_tbl => p_line_locations.start_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_break_end_le_expiration THEN
      PO_VAL_PRICE_BREAKS.break_end_le_expiration(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_expiration_date_tbl => p_line_locations.line_expiration_date
      , p_price_break_end_date_tbl => p_line_locations.end_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_break_end_ge_blanket_start THEN
      PO_VAL_PRICE_BREAKS.break_end_ge_blanket_start(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_blanket_start_date_tbl => p_line_locations.hdr_start_date
      , p_price_break_end_date_tbl => p_line_locations.end_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_break_end_le_blanket_end THEN
      PO_VAL_PRICE_BREAKS.break_end_le_blanket_end(
        p_line_loc_id_tbl => p_line_locations.line_location_id
      , p_blanket_end_date_tbl => p_line_locations.hdr_end_date
      , p_price_break_end_date_tbl => p_line_locations.end_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    ---------------------------------------------------------------
    -- Distribution Validations
    ---------------------------------------------------------------

    WHEN c_dist_num_unique THEN
      PO_VAL_DISTRIBUTIONS.dist_num_unique(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_line_loc_id_tbl => p_distributions.line_location_id
      , p_dist_num_tbl => p_distributions.distribution_num
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_dist_num_gt_zero THEN
      PO_VAL_DISTRIBUTIONS.dist_num_gt_zero(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_dist_num_tbl => p_distributions.distribution_num
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_dist_qty_gt_zero THEN
     --<Bug 18883269>
     --<Bug 18898767>
     -- Validating for encumbered distribution also
     --IF l_po_encumbrance_flag <> 'Y' THEN
      PO_VAL_DISTRIBUTIONS.quantity_gt_zero(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_qty_ordered_tbl => p_distributions.quantity_ordered
      -- <Complex Work R12>: Use value_basis instead of order_type_lookup_code
      , p_value_basis_tbl => p_distributions.ship_value_basis
      , x_results => x_results
      , x_result_type => l_result_type
      );
    --END IF;--<End bug 18883269>

    -- <Complex Work R12 Start>: Combined billed and del into exec
    WHEN c_dist_qty_ge_qty_exec THEN
      PO_VAL_DISTRIBUTIONS.quantity_ge_quantity_exec(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_dist_type_tbl => p_distributions.distribution_type
      , p_qty_ordered_tbl => p_distributions.quantity_ordered
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );
    -- <Complex Work R12 End>

    WHEN c_dist_amt_gt_zero THEN
      --<Bug 18883269>
      --<Bug 18898767>
     -- Validating for encumbered distribution also
     --IF l_po_encumbrance_flag <> 'Y' THEN
      PO_VAL_DISTRIBUTIONS.amount_gt_zero(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_amt_ordered_tbl => p_distributions.amount_ordered
      -- <Complex Work R12>: Use value_basis instead of order_type_lookup_code
      , p_value_basis_tbl => p_distributions.ship_value_basis
      , x_results => x_results
      , x_result_type => l_result_type
      );
     --END IF;--<End bug 18883269>

    -- <Complex Work R12 Start>: Combined billed and del into exec
    WHEN c_dist_amt_ge_amt_exec THEN
      PO_VAL_DISTRIBUTIONS.amount_ge_amount_exec(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_dist_type_tbl => p_distributions.distribution_type
      , p_amt_ordered_tbl => p_distributions.amount_ordered
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );
    -- <Complex Work R12 End>

    WHEN c_pjm_unit_number_effective THEN
      PO_VAL_DISTRIBUTIONS.pjm_unit_number_effective(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_end_item_unit_number_tbl => p_distributions.end_item_unit_number
      , p_item_id_tbl => p_distributions.line_item_id
      , p_ship_to_org_id_tbl => p_distributions.ship_to_organization_id
      -- Bug# 4338241: Adding destination type
      , p_destination_type_code_tbl => p_distributions.destination_type_code
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_amount_to_encumber_ge_zero THEN
      PO_VAL_DISTRIBUTIONS.amount_to_encumber_ge_zero(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_amount_to_encumber_tbl => p_distributions.amount_to_encumber
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_budget_account_id_not_null THEN
      PO_VAL_DISTRIBUTIONS.budget_account_id_not_null(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_budget_account_id_tbl => p_distributions.budget_account_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_gl_encumbered_date_not_null THEN
      PO_VAL_DISTRIBUTIONS.gl_encumbered_date_not_null(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_gl_encumbered_date_tbl => p_distributions.gl_encumbered_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_gl_enc_date_not_null_open THEN
      PO_VAL_DISTRIBUTIONS.gl_enc_date_not_null_open(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_org_id_tbl => p_distributions.org_id
      , p_gl_encumbered_date_tbl => p_distributions.gl_encumbered_date
      , p_dist_type_tbl => p_distributions.distribution_type   --Bug14664343, 14671902
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_unencum_amt_le_amt_to_encum THEN
      PO_VAL_DISTRIBUTIONS.unencum_amt_le_amt_to_encum(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_amount_to_encumber_tbl => p_distributions.amount_to_encumber
      , p_unencumbered_amount_tbl => p_distributions.unencumbered_amount
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_oop_enter_all_fields THEN
      PO_VAL_DISTRIBUTIONS.oop_enter_all_fields(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_line_line_type_id_tbl => p_distributions.line_line_type_id
      , p_wip_entity_id_tbl => p_distributions.wip_entity_id
      , p_wip_line_id_tbl => p_distributions.wip_line_id
      , p_wip_operation_seq_num_tbl => p_distributions.wip_operation_seq_num
      , p_destination_type_code_tbl => p_distributions.destination_type_code
      , p_wip_resource_seq_num_tbl => p_distributions.wip_resource_seq_num
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_gms_data_valid THEN
      PO_VAL_DISTRIBUTIONS.gms_data_valid(
        p_dist_id_tbl => p_distributions.po_distribution_id
      , p_project_id_tbl => p_distributions.project_id
      , p_task_id_tbl => p_distributions.task_id
      , p_award_number_tbl => p_distributions.award_number
      , p_expenditure_type_tbl => p_distributions.expenditure_type
      , p_expenditure_item_date_tbl => p_distributions.expenditure_item_date
      , x_results => x_results
      , x_result_type => l_result_type
      );

    -- ECO 4059111 : FV Validation
     WHEN c_check_fv_validations THEN
       PO_VAL_DISTRIBUTIONS.check_fv_validations(
         p_dist_id_tbl     => p_distributions.po_distribution_id
       , p_ccid_tbl        => p_distributions.code_combination_id
       , p_org_id_tbl      => p_distributions.org_id
       , p_attribute1_tbl  => p_distributions.attribute1
       , p_attribute2_tbl  => p_distributions.attribute2
       , p_attribute3_tbl  => p_distributions.attribute3
       , p_attribute4_tbl  => p_distributions.attribute4
       , p_attribute5_tbl  => p_distributions.attribute5
       , p_attribute6_tbl  => p_distributions.attribute6
       , p_attribute7_tbl  => p_distributions.attribute7
       , p_attribute8_tbl  => p_distributions.attribute8
       , p_attribute9_tbl  => p_distributions.attribute9
       , p_attribute10_tbl => p_distributions.attribute10
       , p_attribute11_tbl => p_distributions.attribute11
       , p_attribute12_tbl => p_distributions.attribute12
       , p_attribute13_tbl => p_distributions.attribute13
       , p_attribute14_tbl => p_distributions.attribute14
       , p_attribute15_tbl => p_distributions.attribute15
       , x_results         => x_results
       , x_result_type     => l_result_type
       );

     -- Bug 5442682 : Validate project related fields
     -- Bug 7558385
     -- Need to check for PJM Parameters before making Task as mandatory.
     -- For fetching the PJM paramters passing ship to org id.

     WHEN c_check_proj_rel_validations THEN
       PO_VAL_DISTRIBUTIONS.check_proj_related_validations(
         p_dist_id_tbl     => p_distributions.po_distribution_id
       , p_dest_type_code_tbl      => p_distributions.destination_type_code
       , p_project_id_tbl               => p_distributions.project_id
       , p_task_id_tbl                   => p_distributions.task_id
       , p_award_id_tbl                => p_distributions.award_id
       , p_expenditure_type_tbl    => p_distributions.expenditure_type
       , p_expenditure_org_id_tbl       => p_distributions.expenditure_organization_id
       , p_expenditure_item_date_tbl  => p_distributions.expenditure_item_date
       , p_ship_to_org_id_tbl     =>  p_distributions.ship_to_organization_id
       , x_results                               => x_results
       , x_result_type                        => l_result_type
       );

            -------------------------------------------------------------------------
        -- PDOI Distributions Validation Subroutines
        -------------------------------------------------------------------------
          WHEN c_dist_amount_ordered THEN
            PO_VAL_DISTRIBUTIONS2.amount_ordered(p_id_tbl                  => p_distributions.interface_id,
                                                 p_amount_ordered_tbl      => p_distributions.amount_ordered,
                                                 p_order_type_code_tbl     => p_distributions.line_order_type_lookup_code,
						  p_distribution_type_tbl   => p_distributions.distribution_type,  -- PDOI for Complex PO Project
                                                 x_results                 => x_results,
                                                 x_result_type             => l_result_type);
          WHEN c_dist_quantity_ordered THEN
            PO_VAL_DISTRIBUTIONS2.quantity_ordered(p_id_tbl                   => p_distributions.interface_id,
                                                   p_quantity_ordered_tbl     => p_distributions.quantity_ordered,
                                                   p_order_type_code_tbl      => p_distributions.line_order_type_lookup_code,
						   p_distribution_type_tbl    => p_distributions.distribution_type,  -- PDOI for Complex PO Project
                                                   x_results                  => x_results,
                                                   x_result_type              => l_result_type);
          WHEN c_dist_destination_org_id THEN
            PO_VAL_DISTRIBUTIONS2.destination_org_id(p_id_tbl                 => p_distributions.interface_id,
                                                     p_dest_org_id_tbl        => p_distributions.destination_organization_id,
                                                     p_ship_to_org_id_tbl     => p_distributions.ship_to_organization_id,
                                                     x_results                => x_results,
                                                     x_result_type            => l_result_type);
          WHEN c_dist_deliver_to_location_id THEN
            PO_VAL_DISTRIBUTIONS2.deliver_to_location_id(p_id_tbl                         => p_distributions.interface_id,
                                                         p_deliver_to_location_id_tbl     => p_distributions.deliver_to_location_id,
                                                         p_ship_to_org_id_tbl             => p_distributions.ship_to_organization_id,
                                                         x_result_set_id                  => l_result_set_id,
                                                         x_result_type                    => l_result_type);
          WHEN c_dist_deliver_to_person_id THEN
            PO_VAL_DISTRIBUTIONS2.deliver_to_person_id(p_id_tbl                       => p_distributions.interface_id,
                                                       p_deliver_to_person_id_tbl     => p_distributions.deliver_to_person_id,
                                                       x_result_set_id                => l_result_set_id,
                                                       x_result_type                  => l_result_type);
          WHEN c_dist_destination_type_code THEN
            PO_VAL_DISTRIBUTIONS2.destination_type_code(p_id_tbl                         => p_distributions.interface_id,
                                                        p_dest_type_code_tbl             => p_distributions.destination_type_code,
                                                        p_ship_to_org_id_tbl             => p_distributions.ship_to_organization_id,
                                                        p_item_id_tbl                    => p_distributions.line_item_id,
                                                        p_txn_flow_header_id_tbl         => p_distributions.transaction_flow_header_id,
                                                        p_accrue_on_receipt_flag_tbl     => p_distributions.accrue_on_receipt_flag,
                                                        p_value_basis_tbl                => p_distributions.line_order_type_lookup_code,
                                                        p_purchase_basis_tbl             => p_distributions.line_purchase_basis,      --bug7644072
                                                        p_expense_accrual_code           => l_expense_accrual_code,
                                                        p_loc_outsourced_assembly_tbl    => p_distributions.loc_outsourced_assembly,
							p_consigned_flag_tbl             => p_distributions.consigned_flag,   --<<Bug#19379838 >>
                                                        x_result_set_id                  => l_result_set_id,
                                                        x_results                        => x_results,
                                                        x_result_type                    => l_result_type);
          WHEN c_dist_destination_subinv THEN
            PO_VAL_DISTRIBUTIONS2.destination_subinv(p_id_tbl                     => p_distributions.interface_id,
                                                     p_destination_subinv_tbl     => p_distributions.destination_subinventory,
                                                     p_dest_type_code_tbl         => p_distributions.destination_type_code,
                                                     p_item_id_tbl                => p_distributions.line_item_id,
                                                     p_ship_to_org_id_tbl         => p_distributions.ship_to_organization_id,
                                                     p_loc_outsourced_assembly_tbl => p_distributions.loc_outsourced_assembly,
                                                     x_result_set_id              => l_result_set_id,
                                                     x_results                    => x_results,
                                                     x_result_type                => l_result_type);
          WHEN c_dist_wip_entity_id THEN
            PO_VAL_DISTRIBUTIONS2.wip_entity_id(p_id_tbl                      => p_distributions.interface_id,
                                                p_wip_entity_id_tbl           => p_distributions.wip_entity_id,
                                                p_wip_rep_schedule_id_tbl     => p_distributions.wip_repetitive_schedule_id,
                                                p_dest_type_code_tbl          => p_distributions.destination_type_code,
                                                p_destination_org_id_tbl      => p_distributions.destination_organization_id,
                                                x_result_set_id               => l_result_set_id,
                                                x_results                     => x_results,
                                                x_result_type                 => l_result_type);
          WHEN c_prevent_encumberance_flag THEN
            PO_VAL_DISTRIBUTIONS2.prevent_encumbrance_flag(p_id_tbl                     => p_distributions.interface_id,
                                                           p_prevent_encum_flag_tbl     => p_distributions.prevent_encumbrance_flag,
                                                           p_dest_type_code_tbl         => p_distributions.destination_type_code,
 						           p_distribution_type_tbl      => p_distributions.distribution_type, -- PDOI for Complex PO Project
				/* Encumbrance Project */  p_wip_entity_id_tbl          => p_distributions.wip_entity_id,
                                                           x_results                    => x_results,
                                                           x_result_type                => l_result_type);
          --Bug 18907904
          WHEN c_gl_encumbered_date THEN
             PO_VAL_DISTRIBUTIONS2.gl_encumbered_date(p_id_tbl                     => p_distributions.interface_id,
                                                      p_gl_date_tbl                => p_distributions.gl_encumbered_date,
                                                      p_set_of_books_id            => l_set_of_books_id,
                                                      p_po_encumberance_flag       => l_po_encumbrance_flag,
                                                      x_results                    => x_results,
                                                      x_result_type                => l_result_type
                                                     );

          WHEN c_charge_account_id THEN
            PO_VAL_DISTRIBUTIONS2.charge_account_id(p_id_tbl                    => p_distributions.interface_id,
                                                    p_charge_account_id_tbl     => p_distributions.code_combination_id,
                                                    p_gl_date_tbl               => p_distributions.gl_encumbered_date,
                                                    p_chart_of_account_id       => l_chart_of_account_id,
                                                    x_result_set_id             => l_result_set_id,
                                                    x_result_type               => l_result_type);
          --16208248
          WHEN c_charge_account_id_null THEN
	  --Bug16591708 To skip the validation
	  --being called at distributions details level
	   IF (p_headers IS NOT NULL) THEN
            PO_VAL_DISTRIBUTIONS2.charge_account_id_null(p_id_tbl                    => p_distributions.po_distribution_id,
                                                         p_charge_account_id_tbl     => p_distributions.code_combination_id,
                                                         x_results                    => x_results,
                                                         x_result_type               => l_result_type);
           END IF;

		 --Bug 16856753. This function validates the charge account id except for null cases.
		 WHEN c_charge_account_id_full THEN
            PO_VAL_DISTRIBUTIONS2.charge_account_id_full(
                                                         p_id_tbl                 => p_distributions.po_distribution_id,
                                                         p_charge_account_id_tbl  => p_distributions.code_combination_id,
	                                                     p_sob_id_tbl             => p_distributions.SET_OF_BOOKS_ID,
                                                         x_results                => x_results,
                                                         x_result_type            => l_result_type);

          WHEN c_budget_account_id THEN
            PO_VAL_DISTRIBUTIONS2.budget_account_id(p_id_tbl                    => p_distributions.interface_id,
                                                    p_budget_account_id_tbl     => p_distributions.budget_account_id,
                                                    p_gl_date_tbl               => p_distributions.gl_encumbered_date,
                                                    p_dest_type_code_tbl        => p_distributions.destination_type_code,
						    p_distribution_type_tbl     => p_distributions.distribution_type, -- PDOI for Complex PO Project
                                                    p_chart_of_account_id       => l_chart_of_account_id,
                                                    p_po_encumberance_flag      => l_po_encumbrance_flag,
		     /* Encumbrance Project */      p_wip_entity_id_tbl          => p_distributions.wip_entity_id,
                                                    x_result_set_id             => l_result_set_id,
                                                    x_result_type               => l_result_type);
          WHEN c_accrual_account_id THEN
            PO_VAL_DISTRIBUTIONS2.account_id(p_id_tbl                  => p_distributions.interface_id,
                                             p_account_id_tbl          => p_distributions.accrual_account_id,
                                             p_gl_date_tbl             => p_distributions.gl_encumbered_date,
                                             p_chart_of_account_id     => l_chart_of_account_id,
                                             p_message_name            => 'PO_PDOI_INVALID_ACCRUAL_ACCT',
                                             p_column_name             => 'ACCRUAL_ACCOUNT_ID',
                                             p_token_name              => 'ACCRUAL_ACCOUNT',
                                             x_result_set_id           => l_result_set_id,
                                             x_result_type             => l_result_type);
          WHEN c_variance_account_id THEN
            PO_VAL_DISTRIBUTIONS2.account_id(p_id_tbl                  => p_distributions.interface_id,
                                             p_account_id_tbl          => p_distributions.variance_account_id,
                                             p_gl_date_tbl             => p_distributions.gl_encumbered_date,
                                             p_chart_of_account_id     => l_chart_of_account_id,
                                             p_message_name            => 'PO_PDOI_INVALID_VAR_ACCT',
                                             p_column_name             => 'VARIANCE_ACCOUNT_ID',
                                             p_token_name              => 'VARIANCE_ACCOUNT',
                                             x_result_set_id           => l_result_set_id,
                                             x_result_type             => l_result_type);
          WHEN c_project_acct_context THEN
            PO_VAL_DISTRIBUTIONS2.project_acct_context(p_id_tbl                   => p_distributions.interface_id,
                                                       p_project_acct_ctx_tbl     => p_distributions.project_accounting_context,
                                                       p_project_id_tbl           => p_distributions.project_id,
                                                       p_task_id_tbl              => p_distributions.task_id,
                                                       p_exp_type_tbl             => p_distributions.expenditure_type,
                                                       p_exp_org_id_tbl           => p_distributions.expenditure_organization_id,
                                                       x_results                  => x_results,
                                                       x_result_type              => l_result_type);
          WHEN c_project_info THEN
            PO_VAL_DISTRIBUTIONS2.project_info(p_id_tbl                        => p_distributions.interface_id,
                                               p_project_acct_ctx_tbl          => p_distributions.project_accounting_context,
                                               p_dest_type_code_tbl            => p_distributions.destination_type_code,
                                               p_project_id_tbl                => p_distributions.project_id,
                                               p_task_id_tbl                   => p_distributions.task_id,
                                               p_expenditure_type_tbl          => p_distributions.expenditure_type,
                                               p_expenditure_org_id_tbl        => p_distributions.expenditure_organization_id,
                                               p_ship_to_org_id_tbl            => p_distributions.ship_to_organization_id,
                                               p_need_by_date_tbl              => p_distributions.header_need_by_date,
                                               p_promised_date_tbl             => p_distributions.promised_date,
                                               p_expenditure_item_date_tbl     => p_distributions.expenditure_item_date,
                                               p_ship_to_ou_id                 => l_operating_unit,
                                               p_deliver_to_person_id_tbl      => p_distributions.deliver_to_person_id,
                                               p_agent_id_tbl                  => p_distributions.hdr_agent_id,
                                               p_txn_flow_header_id_tbl        => p_distributions.transaction_flow_header_id,
                                               p_org_id_tbl                    => p_distributions.org_id,
                                               x_results                       => x_results,
                                               x_result_type                   => l_result_type);

          WHEN c_tax_recovery_override_flag THEN
           PO_VAL_DISTRIBUTIONS2.tax_recovery_override_flag(p_id_tbl                     => p_distributions.interface_id,
                                                                p_recovery_override_flag_tbl => p_distributions.tax_recovery_override_flag,
                                                                p_allow_tax_rate_override    => l_allow_tax_rate_override,
                                                                x_results                    => x_results,
                                                                x_result_type                => l_result_type);
		       WHEN c_gdf_attributes THEN
             PO_VAL_DISTRIBUTIONS.check_gdf_attr_validations(p_distributions              => p_distributions,
                                                             p_other_params_tbl           => l_name_value_pair,
                                                             x_results                    => x_results,
                                                             x_result_type                => l_result_type);

          -- <PDOI Enhancement Bug#17063664 start>
          WHEN c_oke_contract_line THEN
                PO_VAL_DISTRIBUTIONS2.oke_contract_line_id( p_id_tbl                => p_distributions.interface_id,
                                                            p_oke_con_line_id       => p_distributions.oke_contract_line_id,
                                                            p_oke_con_hdr_id        => p_distributions.oke_contract_header_id,
                                                            x_result_set_id         => l_result_set_id,
                                                            x_result_type           => l_result_type);

          WHEN c_oke_contract_del THEN
                PO_VAL_DISTRIBUTIONS2.oke_contract_del_id(p_id_tbl                => p_distributions.interface_id ,
                                                          p_oke_con_del_id        => p_distributions.oke_contract_deliverable_id,
                                                          p_oke_con_line_id       => p_distributions.oke_contract_line_id,
                                                          x_result_set_id         => l_result_set_id,
                                                          x_result_type           => l_result_type);
          -- <PDOI Enhancement Bug#17063664 end>

    ---------------------------------------------------------------
    -- GA Org Assignment Validations
    ---------------------------------------------------------------

    WHEN c_assign_purch_org_not_null THEN
      PO_VAL_GA_ORG_ASSIGNMENTS.purchasing_org_id_not_null(
        p_org_assignment_id_tbl => p_ga_org_assignments.org_assignment_id
      , p_purchasing_org_id_tbl => p_ga_org_assignments.purchasing_org_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_assign_vendor_site_not_null THEN
      PO_VAL_GA_ORG_ASSIGNMENTS.vendor_site_id_not_null(
        p_org_assignment_id_tbl => p_ga_org_assignments.org_assignment_id
      , p_vendor_site_id_tbl => p_ga_org_assignments.vendor_site_id
      , x_results => x_results
      , x_result_type => l_result_type
      );


    ---------------------------------------------------------------
    -- Notification Control Validations
    ---------------------------------------------------------------

    WHEN c_notif_start_date_le_end_date THEN
      PO_VAL_NOTIFICATION_CONTROLS.start_date_le_end_date(
        p_notification_id_tbl => p_notification_controls.notification_id
      , p_start_date_active_tbl => p_notification_controls.start_date_active
      , p_end_date_active_tbl => p_notification_controls.end_date_active
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_notif_percent_le_one_hundred THEN
      PO_VAL_NOTIFICATION_CONTROLS.percent_le_one_hundred(
        p_notification_id_tbl => p_notification_controls.notification_id
      , p_notif_qty_percentage_tbl => p_notification_controls.notification_qty_percentage
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_notif_amount_gt_zero THEN
      PO_VAL_NOTIFICATION_CONTROLS.amount_gt_zero(
        p_notification_id_tbl => p_notification_controls.notification_id
      , p_notification_amount_tbl => p_notification_controls.notification_amount
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_notif_amount_not_null THEN
      PO_VAL_NOTIFICATION_CONTROLS.amount_not_null(
        p_notif_id_tbl => p_notification_controls.notification_id
      , p_notif_amount_tbl => p_notification_controls.notification_amount
      , p_notif_condition_code_tbl => p_notification_controls.notification_condition_code
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_notif_start_date_not_null THEN
      PO_VAL_NOTIFICATION_CONTROLS.start_date_active_not_null(
        p_notif_id_tbl => p_notification_controls.notification_id
      , p_start_date_active_tbl => p_notification_controls.start_date_active
      , p_notif_condition_code_tbl => p_notification_controls.notification_condition_code
      , x_results => x_results
      , x_result_type => l_result_type
      );


    ---------------------------------------------------------------
    -- Price Differential Validations
    ---------------------------------------------------------------

    WHEN c_unique_price_diff_num THEN
      PO_VAL_PRICE_DIFFS.unique_price_diff_num(
        p_price_differential_id_tbl => p_price_differentials.price_differential_id
      , p_entity_id_tbl => p_price_differentials.entity_id
      , p_entity_type_tbl => p_price_differentials.entity_type
      , p_price_differential_num_tbl => p_price_differentials.price_differential_num
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_price_diff_num_gt_zero THEN
      PO_VAL_PRICE_DIFFS.price_diff_num_gt_zero(
        p_price_differential_id_tbl => p_price_differentials.price_differential_id
      , p_price_differential_num_tbl => p_price_differentials.price_differential_num
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_unique_price_type THEN
      PO_VAL_PRICE_DIFFS.unique_price_type(
        p_price_differential_id_tbl => p_price_differentials.price_differential_id
      , p_entity_id_tbl => p_price_differentials.entity_id
      , p_entity_type_tbl => p_price_differentials.entity_type
      , p_price_type_tbl => p_price_differentials.price_type
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_max_mul_ge_zero THEN
      PO_VAL_PRICE_DIFFS.max_mul_ge_zero(
        p_price_differential_id_tbl => p_price_differentials.price_differential_id
      , p_max_multiplier_tbl => p_price_differentials.max_multiplier
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_max_mul_ge_min_mul THEN
      PO_VAL_PRICE_DIFFS.max_mul_ge_min_mul(
        p_price_differential_id_tbl => p_price_differentials.price_differential_id
      , p_min_multiplier_tbl => p_price_differentials.min_multiplier
      , p_max_multiplier_tbl => p_price_differentials.max_multiplier
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_min_mul_ge_zero THEN
      PO_VAL_PRICE_DIFFS.min_mul_ge_zero(
        p_price_differential_id_tbl => p_price_differentials.price_differential_id
      , p_min_multiplier_tbl => p_price_differentials.min_multiplier
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_mul_ge_zero THEN
      PO_VAL_PRICE_DIFFS.mul_ge_zero(
        p_price_differential_id_tbl => p_price_differentials.price_differential_id
      , p_multiplier_tbl => p_price_differentials.multiplier
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_spo_price_type_on_src_doc THEN
      PO_VAL_PRICE_DIFFS.spo_price_type_on_src_doc(
        p_price_differential_id_tbl => p_price_differentials.price_differential_id
      , p_entity_type_tbl => p_price_differentials.entity_type
      , p_from_line_location_id_tbl => p_price_differentials.line_from_line_location_id
      , p_from_line_id_tbl => p_price_differentials.line_from_line_id
      , p_price_type_tbl => p_price_differentials.price_type
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_spo_mul_btwn_min_max THEN
      PO_VAL_PRICE_DIFFS.spo_mul_btwn_min_max(
        p_price_differential_id_tbl => p_price_differentials.price_differential_id
      , p_entity_type_tbl => p_price_differentials.entity_type
      , p_from_line_location_id_tbl => p_price_differentials.line_from_line_location_id
      , p_from_line_id_tbl => p_price_differentials.line_from_line_id
      , p_multiplier_tbl => p_price_differentials.multiplier
      , p_price_type_tbl => p_price_differentials.price_type  --Bug 5415284
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_spo_mul_ge_min THEN
      PO_VAL_PRICE_DIFFS.spo_mul_ge_min(
        p_price_differential_id_tbl => p_price_differentials.price_differential_id
      , p_entity_type_tbl => p_price_differentials.entity_type
      , p_from_line_location_id_tbl => p_price_differentials.line_from_line_location_id
      , p_from_line_id_tbl => p_price_differentials.line_from_line_id
      , p_multiplier_tbl => p_price_differentials.multiplier
      , p_price_type_tbl => p_price_differentials.price_type  --Bug 5415284
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

          --------------------------------------------------------------------------
          -- Price Differentials Validation Subroutines
          --------------------------------------------------------------------------
          WHEN c_price_type THEN
            PO_VAL_PRICE_DIFFS2.price_type(p_id_tbl             => p_price_differentials.interface_id,
                                           p_price_type_tbl     => p_price_differentials.price_type,
                                           x_result_set_id      => l_result_set_id,
                                           x_result_type        => l_result_type);
          WHEN c_multiple_price_diff THEN
            PO_VAL_PRICE_DIFFS2.multiple_price_diff(p_id_tbl              => p_price_differentials.interface_id,
                                                    p_price_type_tbl      => p_price_differentials.price_type,
                                                    p_entity_type_tbl     => p_price_differentials.entity_type,
                                                    p_entity_id_tbl       => p_price_differentials.entity_id,
                                                    x_result_set_id       => l_result_set_id,
                                                    x_result_type         => l_result_type);
          WHEN c_entity_type THEN
            PO_VAL_PRICE_DIFFS2.entity_type(p_id_tbl              => p_price_differentials.interface_id,
                                            p_entity_type_tbl     => p_price_differentials.entity_type,
                                            p_doc_type            => l_doc_type,
                                            x_results             => x_results,
                                            x_result_type         => l_result_type);
          WHEN c_multiplier THEN
            PO_VAL_PRICE_DIFFS2.multiplier(p_id_tbl              => p_price_differentials.interface_id,
                                           p_entity_type_tbl     => p_price_differentials.entity_type,
                                           p_multiplier_tbl      => p_price_differentials.multiplier,
                                           x_results             => x_results,
                                           x_result_type         => l_result_type);
          WHEN c_min_multiplier THEN
            PO_VAL_PRICE_DIFFS2.min_multiplier(p_id_tbl                 => p_price_differentials.interface_id,
                                               p_entity_type_tbl        => p_price_differentials.entity_type,
                                               p_min_multiplier_tbl     => p_price_differentials.min_multiplier,
                                               x_results                => x_results,
                                               x_result_type            => l_result_type);
          WHEN c_max_multiplier THEN
            PO_VAL_PRICE_DIFFS2.max_multiplier(p_id_tbl                 => p_price_differentials.interface_id,
                                               p_entity_type_tbl        => p_price_differentials.entity_type,
                                               p_max_multiplier_tbl     => p_price_differentials.max_multiplier,
                                               x_results                => x_results,
                                               x_result_type            => l_result_type);
          WHEN c_price_diff_style_info THEN
            PO_VAL_PRICE_DIFFS2.style_related_info(p_id_tbl          => p_price_differentials.interface_id,
                                                   p_style_id_tbl    => p_price_differentials.hdr_style_id,
                                                   x_result_set_id   => l_result_set_id,
                                                   x_result_type     => l_result_type);



    ---------------------------------------------------------------
    -- Price Update Allowed Validations
    ---------------------------------------------------------------

    WHEN c_no_dists_reserved THEN
      PO_PRICE_HELPER.no_dists_reserved(
        p_line_id_tbl => p_lines.po_line_id
      , p_amt_changed_flag_tbl => p_lines.amount_changed_flag --<Bug 13503748 :Encumbrance ER>--
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_accruals_allow_update THEN
      PO_PRICE_HELPER.accruals_allow_update(
        p_line_id_tbl => p_lines.po_line_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_no_timecards_exist THEN
      PO_PRICE_HELPER.no_timecards_exist(
        p_line_id_tbl => p_lines.po_line_id
      , x_results => x_results
      , x_result_type => l_result_type
      );

    WHEN c_no_pending_receipts THEN
      PO_PRICE_HELPER.no_pending_receipts(
        p_line_id_tbl => p_lines.po_line_id
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    WHEN c_retro_account_allows_update THEN
      PO_PRICE_HELPER.retro_account_allows_update(
        p_line_id_tbl => p_lines.po_line_id
      , p_price_break_lookup_code_tbl => p_lines.price_break_lookup_code
      , x_results => x_results
      , x_result_type => l_result_type
      );

    --<Bug 18372756>
     WHEN c_no_unvalidated_debit_memo THEN
       PO_PRICE_HELPER.check_unvalidated_debit_memo(
             p_line_id_tbl => p_lines.po_line_id
           , x_result_set_id => l_result_set_id
           , x_result_type => l_result_type
           );
    --<End Bug 18372756>

    WHEN c_warn_amt_based_notif_ctrls THEN
      PO_PRICE_HELPER.warn_amt_based_notif_ctrls(
        p_line_id_tbl => p_lines.po_line_id
      , x_result_set_id => l_result_set_id
      , x_result_type => l_result_type
      );

    --Enhanced Pricing Start:
    ---------------------------------------------------------------
    -- Price Adjustments Validations
    ---------------------------------------------------------------
    --When price adjustment line is updated, change reason code should not be NULL
    WHEN c_change_reason_code_not_null THEN
      PO_VAL_PRICE_ADJS.ovr_chng_reas_code_not_null(
        p_price_adj_id_tbl => p_price_adjustments.price_adjustment_id
      , p_updated_flag_tbl => p_price_adjustments.updated_flag
      , p_change_reason_code_tbl => p_price_adjustments.change_reason_code
      , x_results => x_results
      , x_result_type => l_result_type
      );

    --When price adjustment line is updated, change reason text should not be NULL
    WHEN c_change_reason_text_not_null THEN
      PO_VAL_PRICE_ADJS.ovr_chng_reas_text_not_null(
        p_price_adj_id_tbl => p_price_adjustments.price_adjustment_id
      , p_updated_flag_tbl => p_price_adjustments.updated_flag
      , p_change_reason_text_tbl => p_price_adjustments.change_reason_text
      , x_results => x_results
      , x_result_type => l_result_type
      );
    --Enhanced Pricing End:

    -- <<PDOI Enhancement Bug#17063664 Start>>
    ---------------------------------------------------------------
    -- Cross OU Validations
    ---------------------------------------------------------------

    WHEN c_validate_cross_ou THEN
      PO_SHARED_PROC_PVT.validate_cross_ou_purchasing(
        p_line_id_tbl                  => p_req_reference.interface_id,
        p_requisition_line_id_tbl      => p_req_reference.requisition_line_id,
        p_item_id_tbl                  => p_req_reference.item_id,
        p_vmi_flag_tbl                 => p_req_reference.vmi_flag,
        p_cons_from_supp_flag_tbl      => p_req_reference.cons_from_supp_flag,
        p_txn_flow_header_id_tbl       => p_req_reference.txn_flow_header_id,
        p_source_doc_id_tbl            => p_req_reference.source_doc_id,
        p_purchasing_org_id_tbl        => p_req_reference.org_id,
        p_requesting_org_id_tbl        => p_req_reference.requesting_org_id,
        p_dest_inv_org_ou_id_tbl       => p_req_reference.dest_inv_org_ou_id,
        p_deliver_to_location_id_tbl   => p_req_reference.deliver_to_location_id,
        p_destination_org_id_tbl       => p_req_reference.destination_org_id,
        p_destination_type_code_tbl    => p_req_reference.destination_type_code,
        p_document_type_tbl            => p_req_reference.hdr_type_lookup_code,
        x_result_set_id                => l_result_set_id,
        x_results                      => x_results,
        x_result_type                  => l_result_type);

    -- When purchasing and requisition OU's are different,
    --    then VMI should not be enabled
    WHEN c_cross_ou_vmi_check THEN
      PO_SHARED_PROC_PVT.cross_ou_vmi_check(
        p_line_id_tbl             => p_req_reference.interface_id
      , p_requisition_line_id_tbl => p_req_reference.requisition_line_id
      , p_vmi_flag_tbl            => p_req_reference.vmi_flag
      , p_document_type_tbl       => p_req_reference.hdr_type_lookup_code
      , x_result_set_id           => l_result_set_id
      , x_result_type             => l_result_type
      );

    -- When purchasing and requisition OU's are different,
    --    then Consigned relationship should not exists
    WHEN c_cross_ou_consigned_check THEN
      PO_SHARED_PROC_PVT.cross_ou_consigned_check(
        p_line_id_tbl             => p_req_reference.interface_id
      , p_requisition_line_id_tbl => p_req_reference.requisition_line_id
      , p_cons_from_supp_flag_tbl => p_req_reference.cons_from_supp_flag
      , p_document_type_tbl       => p_req_reference.hdr_type_lookup_code
      , x_result_set_id           => l_result_set_id
      , x_result_type             => l_result_type
      );

    -- When purchasing and requisition OU's are different,
    --    then Item should be valid in following  OUs -
    --      For Lines with GA reference: Requesting, Owning and Purchasing
    --      For lines with no source doc info: Requesting and Purchasing
    WHEN c_cross_ou_item_validity_check THEN
      PO_SHARED_PROC_PVT.cross_ou_item_validity_check(
        p_line_id_tbl                 => p_req_reference.interface_id
      , p_requisition_line_id_tbl     => p_req_reference.requisition_line_id
      , p_item_id_tbl                 => p_req_reference.item_id
      , p_global_agreement_flag_tbl   => p_req_reference.global_agreement_flag
      , p_purchasing_org_id_tbl       => p_req_reference.org_id
      , p_requesting_org_id_tbl       => p_req_reference.requesting_org_id
      , p_owning_org_id_tbl           => p_req_reference.owning_org_id
      , p_document_type_tbl           => p_req_reference.hdr_type_lookup_code
      , x_result_set_id           => l_result_set_id
      , x_result_type             => l_result_type
      );


    -- Procurement across OUs is not supported for PA Projects
    WHEN c_cross_ou_pa_project_check THEN
      PO_SHARED_PROC_PVT.cross_ou_pa_project_check(
        p_line_id_tbl                 => p_req_reference.interface_id
      , p_requisition_line_id_tbl     => p_req_reference.requisition_line_id
      , p_project_referenced_flag_tbl => p_req_reference.project_referenced_flag
      , p_document_type_tbl           => p_req_reference.hdr_type_lookup_code
      , x_result_set_id               => l_result_set_id
      , x_result_type                 => l_result_type
      );

    -- When purchasing and requisition OU's are different,
    --    then the below condition should not be true
    --        (DOU=POU) AND (DOU<>ROU)
    WHEN c_cross_ou_dest_ou_check THEN
      PO_SHARED_PROC_PVT.cross_ou_dest_ou_check(
        p_line_id_tbl             => p_req_reference.interface_id
      , p_requisition_line_id_tbl => p_req_reference.requisition_line_id
      , p_dest_inv_org_ou_id_tbl  => p_req_reference.dest_inv_org_ou_id
      , p_purchasing_org_id_tbl   => p_req_reference.org_id
      , p_requesting_org_id_tbl   => p_req_reference.requesting_org_id
      , p_document_type_tbl       => p_req_reference.hdr_type_lookup_code
      , x_result_set_id           => l_result_set_id
      , x_result_type             => l_result_type
      );

    -- Procurement across OUs is allowed only when a valid
    --    transaction flow exists between Purchasing OU and Destination OU.
    WHEN c_cross_ou_txn_flow_check THEN
      PO_SHARED_PROC_PVT.cross_ou_txn_flow_check(
        p_line_id_tbl             => p_req_reference.interface_id
      , p_requisition_line_id_tbl => p_req_reference.requisition_line_id
      , p_txn_flow_header_id_tbl  => p_req_reference.txn_flow_header_id
      , p_item_id_tbl             => p_req_reference.item_id
      , p_document_type_tbl       => p_req_reference.hdr_type_lookup_code
      , x_result_set_id           => l_result_set_id
      , x_result_type             => l_result_type
      );

    -- If 'HR: Cross Business Groups' is NO
    --    then ROU and POU should rollup to the same Business Group
    WHEN c_cross_ou_services_check THEN
      PO_SHARED_PROC_PVT.cross_ou_services_check(
        p_line_id_tbl             => p_req_reference.interface_id
      , p_requisition_line_id_tbl => p_req_reference.requisition_line_id
      , p_purchasing_org_id_tbl   => p_req_reference.org_id
      , p_requesting_org_id_tbl   => p_req_reference.requesting_org_id
      , p_document_type_tbl       => p_req_reference.hdr_type_lookup_code
      , x_result_set_id           => l_result_set_id
      , x_result_type             => l_result_type
      );

    -- If the deliver-to-location on req Line is customer location then
    --    OM family pack should be installed to handle cross OU purchasing in
    --    international drop ship scenerio.
    WHEN c_cross_ou_cust_loc_check THEN
      PO_SHARED_PROC_PVT.cross_ou_cust_loc_check(
        p_line_id_tbl                => p_req_reference.interface_id
      , p_requisition_line_id_tbl    => p_req_reference.requisition_line_id
      , p_deliver_to_location_id_tbl => p_req_reference.deliver_to_location_id
      , p_document_type_tbl          => p_req_reference.hdr_type_lookup_code
      , x_result_set_id           => l_result_set_id
      , x_result_type                => l_result_type
      );

   -- When purchasing and requisition OU's are different,
    --    then Encumbrance should not be enabled
    WHEN c_cross_ou_ga_enc_check THEN
      PO_SHARED_PROC_PVT.cross_ou_ga_encumbrance_check(
        p_line_id_tbl             => p_req_reference.interface_id
      , p_requisition_line_id_tbl => p_req_reference.requisition_line_id
      , p_requesting_org_id_tbl   => p_req_reference.requesting_org_id
      , p_purchasing_org_id_tbl   => p_req_reference.org_id
      , p_document_type_tbl       => p_req_reference.hdr_type_lookup_code
      , x_result_set_id           => l_result_set_id
      , x_result_type             => l_result_type
      );

    --Source Doc Validations
    WHEN c_src_blanket_exists THEN
       PO_VAL_LINES2.validate_src_blanket_exists(
                    p_line_id_tbl        => p_lines.INTERFACE_ID
                  , p_src_doc_hdr_id_tbl => p_lines.FROM_HEADER_ID
                  , x_result_set_id      => l_result_set_id
                  , x_result_type        => l_result_type);

    WHEN c_src_contract_exists THEN
       PO_VAL_LINES2.validate_src_contract_exists(
                    p_line_id_tbl        => p_lines.INTERFACE_ID
                  , p_src_doc_hdr_id_tbl => p_lines.CONTRACT_ID
                  , x_result_set_id      => l_result_set_id
                  , x_result_type        => l_result_type);

    WHEN c_src_only_one THEN
       PO_VAL_LINES2.validate_src_only_one(
                    p_line_id_tbl        => p_lines.INTERFACE_ID
                  , p_from_hdr_id_tbl    => p_lines.FROM_HEADER_ID
                  , p_contract_id_tbl    => p_lines.CONTRACT_ID
                  , x_result_set_id      => l_result_set_id
                  , x_result_type        => l_result_type);


    WHEN c_src_doc_global THEN
       PO_VAL_LINES2.validate_src_doc_global(
                    p_line_id_tbl        => p_source_doc.INTERFACE_ID
                  , p_src_doc_type_tbl   => p_source_doc.SRC_DOC_TYPE
                  , p_src_doc_hdr_id_tbl => p_source_doc.SRC_HEADER_ID
                  , p_src_doc_ga_flg_tbl => p_source_doc.SRC_GLOBAL_AGREEMENT_FLAG
                  , x_result_set_id      => l_result_set_id
                  , x_result_type        => l_result_type);

    WHEN c_src_doc_vendor THEN
      PO_VAL_LINES2.validate_src_doc_vendor(
                    p_line_id_tbl           => p_source_doc.INTERFACE_ID
                  , p_vendor_id_tbl         => p_source_doc.HDR_VENDOR_ID
                  , p_src_doc_type_tbl      => p_source_doc.SRC_DOC_TYPE
                  , p_src_doc_hdr_id_tbl    => p_source_doc.SRC_HEADER_ID
                  , p_src_doc_vendor_id_tbl => p_source_doc.SRC_VENDOR_ID
                  , x_result_set_id         => l_result_set_id
                  , x_result_type           => l_result_type) ;

    WHEN c_src_doc_vendor_site THEN
      PO_VAL_LINES2.validate_src_doc_vendor_site(
                    p_line_id_tbl          => p_source_doc.INTERFACE_ID
                  , p_vendor_site_id_tbl   => p_source_doc.HDR_VENDOR_SITE_ID
                  , p_org_id_tbl           => p_source_doc.ORG_ID
                  , p_src_doc_type_tbl     => p_source_doc.SRC_DOC_TYPE
                  , p_src_doc_hdr_id_tbl   => p_source_doc.SRC_HEADER_ID
                  , p_src_enable_all_sites => p_source_doc.SRC_ENABLE_ALL_SITES
                  , x_result_set_id        => l_result_set_id
                  , x_result_type          => l_result_type);

    WHEN c_src_doc_approved THEN
      PO_VAL_LINES2.validate_src_doc_approved(
                    p_line_id_tbl           => p_source_doc.INTERFACE_ID
                  , p_src_doc_type_tbl      => p_source_doc.SRC_DOC_TYPE
                  , p_src_doc_hdr_id_tbl    => p_source_doc.SRC_HEADER_ID
                  , p_src_auth_status_tbl   => p_source_doc.SRC_AUTH_STATUS
                  , p_src_approved_date_tbl => p_source_doc.SRC_APPROVED_DATE
                  , p_src_approved_flag_tbl => p_source_doc.SRC_APPROVED_FLAG
                  , x_result_set_id         => l_result_set_id
                  , x_result_type           => l_result_type);

    WHEN c_src_doc_hold THEN
      PO_VAL_LINES2.validate_src_doc_hold(
                    p_line_id_tbl          => p_source_doc.INTERFACE_ID
                  , p_src_doc_type_tbl     => p_source_doc.SRC_DOC_TYPE
                  , p_src_doc_hdr_id_tbl   => p_source_doc.SRC_HEADER_ID
                  , p_src_doc_hold_flg_tbl => p_source_doc.SRC_USER_HOLD_FLAG
                  , x_result_set_id        => l_result_set_id
                  , x_result_type          => l_result_type);

    WHEN c_src_doc_currency THEN
      PO_VAL_LINES2.validate_src_doc_currency(
                    p_line_id_tbl          => p_source_doc.INTERFACE_ID
                  , p_currency_tbl         => p_source_doc.HDR_CURRENCY_CODE
                  , p_org_id_tbl           => p_source_doc.ORG_ID
                  , p_src_doc_type_tbl     => p_source_doc.SRC_DOC_TYPE
                  , p_src_doc_hdr_id_tbl   => p_source_doc.SRC_HEADER_ID
                  , p_src_doc_currency_tbl => p_source_doc.SRC_CURRENCY_CODE
                  , p_src_doc_org_id_tbl   => p_source_doc.SRC_ORG_ID
                  , x_result_set_id        => l_result_set_id
                  , x_result_type          => l_result_type);

    WHEN c_src_doc_closed_code THEN
      PO_VAL_LINES2.validate_src_doc_closed_code(
                    p_line_id_tbl             => p_source_doc.INTERFACE_ID
                  , p_src_doc_type_tbl        => p_source_doc.SRC_DOC_TYPE
                  , p_src_doc_hdr_id_tbl      => p_source_doc.SRC_HEADER_ID
                  , p_src_doc_closed_code_tbl => p_source_doc.SRC_CLOSED_CODE
                  , x_result_set_id           => l_result_set_id
                  , x_result_type             => l_result_type);

    WHEN c_src_doc_cancel THEN
       PO_VAL_LINES2.validate_src_doc_cancel(
                    p_line_id_tbl            => p_source_doc.INTERFACE_ID
                  , p_src_doc_type_tbl       => p_source_doc.SRC_DOC_TYPE
                  , p_src_doc_hdr_id_tbl     => p_source_doc.SRC_HEADER_ID
                  , p_src_doc_cancel_flg_tbl => p_source_doc.SRC_CANCEL_FLAG
                  , x_result_set_id          => l_result_set_id
                  , x_result_type            => l_result_type);

     WHEN c_src_doc_frozen THEN
       PO_VAL_LINES2.validate_src_doc_frozen(
                    p_line_id_tbl            => p_source_doc.INTERFACE_ID
                  , p_src_doc_type_tbl       => p_source_doc.SRC_DOC_TYPE
                  , p_src_doc_hdr_id_tbl     => p_source_doc.SRC_HEADER_ID
                  , p_src_doc_frozen_flg_tbl => p_source_doc.SRC_FROZEN_FLAG
                  , x_result_set_id          => l_result_set_id
                  , x_result_type            => l_result_type);

     WHEN c_src_bpa_expiry_date THEN
       PO_VAL_LINES2.validate_src_bpa_expiry_date(
                    p_line_id_tbl            => p_source_doc.INTERFACE_ID
                  , p_src_doc_hdr_id_tbl     => p_source_doc.SRC_HEADER_ID
                  , p_src_doc_end_date_tbl   => p_source_doc.SRC_END_DATE
                  , p_src_doc_expiration_tbl => p_source_doc.SRC_LINE_EXPIRATION_DATE
                  , x_result_set_id          => l_result_set_id
                  , x_result_type            => l_result_type);

     WHEN c_src_cpa_expiry_date THEN
       PO_VAL_LINES2.validate_src_cpa_expiry_date(
                    p_line_id_tbl            => p_source_doc.INTERFACE_ID
                  , p_src_doc_hdr_id_tbl     => p_source_doc.SRC_HEADER_ID
                  , p_src_doc_end_date_tbl   => p_source_doc.SRC_END_DATE
                  , x_result_set_id          => l_result_set_id
                  , x_result_type            => l_result_type);

     WHEN c_src_doc_style THEN
          PO_VAL_LINES2.validate_src_doc_style(
                    p_line_id_tbl            => p_source_doc.INTERFACE_ID
                  , p_style_id_tbl           => p_source_doc.HDR_STYLE_ID
                  , p_src_doc_type_tbl       => p_source_doc.SRC_DOC_TYPE
                  , p_src_doc_hdr_id_tbl     => p_source_doc.SRC_HEADER_ID
                  , p_src_doc_style_id_tbl   => p_source_doc.SRC_STYLE_ID
                  , x_result_set_id          => l_result_set_id
                  , x_result_type            => l_result_type);

     WHEN c_src_line_item THEN
       PO_VAL_LINES2.validate_src_line_item(
                    p_line_id_tbl         => p_source_doc.INTERFACE_ID
                  , p_item_id_tbl         => p_source_doc.ITEM_ID
                  , p_item_descp_tbl      => p_source_doc.ITEM_DESCRIPTION
                  , p_category_id_tbl     => p_source_doc.CATEGORY_ID
                  , p_src_doc_line_id_tbl => p_source_doc.SRC_LINE_ID
                  , p_src_item_id_tbl     => p_source_doc.SRC_LINE_ITEM_ID
                  , p_src_item_descp_tbl  => p_source_doc.SRC_LINE_ITEM_DESCRIPTION
                  , p_src_category_id_tbl => p_source_doc.SRC_LINE_CATEGORY_ID
                  , x_result_set_id       => l_result_set_id
                  , x_result_type         => l_result_type);

     WHEN c_src_line_not_null THEN
       PO_VAL_LINES2.validate_src_line_not_null(
                   p_line_id_tbl         => p_lines.INTERFACE_ID
                 , p_src_doc_hdr_id_tbl  => p_lines.FROM_HEADER_ID
                 , p_src_doc_line_id_tbl => p_lines.FROM_LINE_ID
                 , x_result_set_id       => l_result_set_id
                 , x_result_type         => l_result_type);


      WHEN c_src_line_item_rev THEN
         PO_VAL_LINES2.validate_src_line_item_rev(
                    p_line_id_tbl        => p_source_doc.INTERFACE_ID
                  , p_item_rev_tbl       => p_source_doc.ITEM_REVISION
                  , p_src_doc_line_id_tbl => p_source_doc.SRC_LINE_ID
                  , p_src_item_rev_tbl   => p_source_doc.SRC_LINE_ITEM_REVISION
                  , x_result_set_id      => l_result_set_id
                  , x_result_type        => l_result_type);

       WHEN c_src_line_job THEN
          PO_VAL_LINES2.validate_src_line_job(
                    p_line_id_tbl        => p_source_doc.INTERFACE_ID
                  , p_job_id_tbl         => p_source_doc.JOB_ID
                  , p_src_doc_line_id_tbl => p_source_doc.SRC_LINE_ID
                  , p_src_job_id_tbl     => p_source_doc.SRC_JOB_ID
                  , x_result_set_id      => l_result_set_id
                  , x_result_type        => l_result_type);

        WHEN c_src_line_cancel THEN
           PO_VAL_LINES2.validate_src_line_cancel_flag(
                    p_line_id_tbl         => p_source_doc.INTERFACE_ID
                  , p_src_doc_line_id_tbl => p_source_doc.SRC_LINE_ID
                  , p_src_line_cancel_tbl => p_source_doc.SRC_LINE_CANCEL_FLAG
                  , x_result_set_id       => l_result_set_id
                  , x_result_type         => l_result_type)  ;

        WHEN c_src_line_closed THEN
           PO_VAL_LINES2.validate_src_line_closed_code(
                    p_line_id_tbl         => p_source_doc.INTERFACE_ID
                  , p_src_doc_line_id_tbl => p_source_doc.SRC_LINE_ID
                  , p_src_line_closed_tbl => p_source_doc.SRC_LINE_CLOSED_CODE
                  , x_result_set_id       => l_result_set_id
                  , x_result_type         => l_result_type)  ;

        WHEN c_src_line_order_type THEN
           PO_VAL_LINES2.validate_src_line_order_type(
                    p_line_id_tbl             => p_source_doc.INTERFACE_ID
                  , p_order_type_lookup_tbl   => p_source_doc.ORDER_TYPE_LOOKUP_CODE
                  , p_src_doc_line_id_tbl     => p_source_doc.SRC_LINE_ID
                  , p_src_line_order_type_tbl => p_source_doc.SRC_LINE_TYPE_LOOKUP_CODE
                  , x_result_set_id           => l_result_set_id
                  , x_result_type             => l_result_type)  ;

        WHEN c_src_line_purchase_basis THEN
           PO_VAL_LINES2.validate_src_line_pur_basis(
                    p_line_id_tbl           => p_source_doc.INTERFACE_ID
                  , p_purchase_basis_tbl    => p_source_doc.PURCHASE_BASIS
                  , p_src_doc_line_id_tbl   => p_source_doc.SRC_LINE_ID
                  , p_src_line_purchase_tbl => p_source_doc.SRC_LINE_PURCHASE_BASIS
                  , x_result_set_id         => l_result_set_id
                  , x_result_type           => l_result_type)  ;

        WHEN c_src_line_matching_basis THEN
           PO_VAL_LINES2.validate_src_line_match_basis(
                    p_line_id_tbl           => p_source_doc.INTERFACE_ID
                  , p_matching_basis_tbl    => p_source_doc.MATCHING_BASIS
                  , p_src_doc_line_id_tbl   => p_source_doc.SRC_LINE_ID
                  , p_src_line_matching_tbl => p_source_doc.SRC_LINE_MATCHING_BASIS
                  , x_result_set_id         => l_result_set_id
                  , x_result_type           => l_result_type)  ;

        WHEN c_src_line_uom THEN
           PO_VAL_LINES2.validate_src_line_uom(
                    p_line_id_tbl           => p_source_doc.INTERFACE_ID
                  , p_uom_tbl               => p_source_doc.UNIT_MEAS_LOOKUP_CODE
                  , p_src_doc_line_id_tbl   => p_source_doc.SRC_LINE_ID
                  , p_src_line_uom_tbl      => p_source_doc.SRC_LINE_UOM
                  , x_result_set_id         => l_result_set_id
                  , x_result_type           => l_result_type)  ;

       WHEN c_src_allow_price_ovr THEN
              PO_VAL_LINES2.validate_src_allow_price_ovr(
                    p_line_id_tbl           => p_source_doc.INTERFACE_ID
                  , p_unit_price_tbl        => p_source_doc.UNIT_PRICE
                  , p_src_allow_price_tbl   => p_source_doc.SRC_LINE_ALLOW_PRICE_OVR
                  , x_result_set_id         => l_result_set_id
                  , x_result_type           => l_result_type);

       -- Req Reference Validations
       WHEN c_req_exists THEN
          PO_VAL_LINES2.validate_req_exists(
                   p_line_id_tbl          => p_lines.INTERFACE_ID
                 , p_req_line_id_tbl      => p_lines.REQUISITION_LINE_ID
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

      WHEN c_validate_no_ship_dist THEN
            PO_VAL_LINES2.validate_no_ship_dist(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

      WHEN c_validate_req_status THEN
          PO_VAL_LINES2.validate_req_status(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_req_status_tbl       => p_req_reference.AUTHORIZATION_STATUS
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

       WHEN c_reqs_in_pool_flag THEN
           PO_VAL_LINES2.validate_reqs_in_pool_flag(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_reqs_in_pool_flg_tbl => p_req_reference.REQS_IN_POOL_FLAG
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

       WHEN c_reqs_cancel_flag THEN
           PO_VAL_LINES2.validate_reqs_cancel_flag(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_reqs_cancel_flag_tbl => p_req_reference.CANCEL_FLAG
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

       WHEN c_reqs_closed_code THEN
           PO_VAL_LINES2.validate_reqs_closed_code(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_reqs_closed_code_tbl => p_req_reference.CLOSED_CODE
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

       WHEN c_reqs_mdfd_by_agt THEN
           PO_VAL_LINES2.validate_reqs_modfd_by_agt(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_reqs_mod_by_agnt_tbl => p_req_reference.MODIFIED_BY_AGENT_FLAG
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

       WHEN c_reqs_at_srcng_flg THEN
           PO_VAL_LINES2.validate_reqs_at_srcing_flg(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_reqs_at_src_flag_tbl => p_req_reference.AT_SOURCING_FLAG
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

       WHEN c_reqs_line_loc THEN
           PO_VAL_LINES2.validate_reqs_line_loc(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_reqs_line_loc_tbl    => p_req_reference.LINE_LOCATION_ID
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

       WHEN c_validate_req_item THEN
             PO_VAL_LINES2.validate_req_item(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_item_id_tbl          => p_req_reference.ITEM_ID
                 , p_req_item_id_tbl      => p_req_reference.REQ_ITEM_ID
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type) ;

       WHEN c_validate_req_job THEN
             PO_VAL_LINES2.validate_req_job(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_job_id_tbl           => p_req_reference.JOB_ID
                 , p_req_job_id_tbl       => p_req_reference.REQ_JOB_ID
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type) ;

       WHEN c_validate_req_pur_bas THEN
             PO_VAL_LINES2.validate_req_pur_basis(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_pur_basis_tbl        => p_req_reference.PURCHASE_BASIS
                 , p_req_pur_bas_tbl      => p_req_reference.REQ_PURCHASE_BASIS
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type) ;

       WHEN c_validate_req_mat_bas THEN
             PO_VAL_LINES2.validate_req_match_basis(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_match_basis_tbl      => p_req_reference.MATCHING_BASIS
                 , p_req_match_bas_tbl    => p_req_reference.REQ_MATCHING_BASIS
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type) ;

       WHEN c_validate_pcard THEN
           PO_VAL_LINES2.validate_pcard(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_req_pcard_id_tbl     => p_req_reference.REQ_PCARD_ID
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

        WHEN c_validate_reqorg_srcdoc THEN
           PO_VAL_LINES2.validate_reqorg_srcdoc(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_source_doc_id_tbl    => p_req_reference.SOURCE_DOC_ID
                 , p_req_org_id_tbl       => p_req_reference.REQUESTING_ORG_ID
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

        WHEN c_validate_style_dest THEN
           PO_VAL_LINES2.validate_style_dest_progress(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_hdr_style_id_tbl     => p_req_reference.HDR_STYLE_ID
                 , p_hdr_type_tbl         => p_req_reference.HDR_TYPE_LOOKUP_CODE
                 , p_req_dest_code_tbl    => p_req_reference.DESTINATION_TYPE_CODE
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

      WHEN c_validate_style_line THEN
            PO_VAL_LINES2.validate_style_line_progress(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_hdr_style_id_tbl     => p_req_reference.HDR_STYLE_ID
                 , p_hdr_type_tbl         => p_req_reference.HDR_TYPE_LOOKUP_CODE
                 , p_req_pur_basis_tbl    => p_req_reference.REQ_PURCHASE_BASIS
                 , p_req_order_type_tbl   => p_req_reference.ORDER_TYPE_LOOKUP_CODE
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

      WHEN c_validate_style_pcard THEN
            PO_VAL_LINES2.validate_style_pcard(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_hdr_style_id_tbl     => p_req_reference.HDR_STYLE_ID
                 , p_hdr_type_tbl         => p_req_reference.HDR_TYPE_LOOKUP_CODE
                 , p_req_pcard_id_tbl    => p_req_reference.REQ_PCARD_ID
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);


      WHEN c_validate_req_vmi_bpa THEN
        PO_VAL_LINES2.validate_req_vmi_bpa(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_req_vmi_flag_tbl     => p_req_reference.VMI_FLAG
                 , p_source_doc_id_tbl    => p_req_reference.SOURCE_DOC_ID
                 , p_source_doc_type_tbl  => p_req_reference.SOURCE_DOC_TYPE
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

      WHEN c_validate_req_vmi_sup THEN
        PO_VAL_LINES2.validate_req_vmi_supplier(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_vendor_id_tbl        => p_req_reference.HDR_VENDOR_ID
                 , p_vendor_site_tbl      => p_req_reference.HDR_VENDOR_SITE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_req_vmi_flag_tbl     => p_req_reference.VMI_FLAG
                 , p_sugstd_vend_id_tbl   => p_req_reference.SUGGESTED_VENDOR_ID
                 , p_sugstd_vend_site_tbl => p_req_reference.SUGGESTED_VENDOR_SITE_ID
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

      WHEN c_validate_req_on_spo THEN
          PO_VAL_LINES2.validate_req_on_spo(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_hdr_type_lookup_tbl  => p_req_reference.HDR_TYPE_LOOKUP_CODE
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

      WHEN c_validate_req_pcard_sup THEN
          PO_VAL_LINES2.validate_req_pcard_supp(
                   p_line_id_tbl          => p_req_reference.INTERFACE_ID
                 , p_vendor_id_tbl        => p_req_reference.HDR_VENDOR_ID
                 , p_vendor_site_tbl      => p_req_reference.HDR_VENDOR_SITE_ID
                 , p_req_line_id_tbl      => p_req_reference.REQUISITION_LINE_ID
                 , p_req_pcard_id_tbl     => p_req_reference.REQ_PCARD_ID
                 , p_sugstd_vend_id_tbl   => p_req_reference.SUGGESTED_VENDOR_ID
                 , p_sugstd_vend_site_tbl => p_req_reference.SUGGESTED_VENDOR_SITE_ID
                 , x_result_set_id        => l_result_set_id
                 , x_result_type          => l_result_type);

        -- <<PDOI Enhancement Bug#17063664 End>>

    ELSE
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod,d_position,'Invalid identifier in validation set: '||l_val);
      END IF;
      RAISE CASE_NOT_FOUND;

    END CASE;

  EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,d_position,
        'Validation subroutine '||l_val||' threw exception');
    END IF;

    l_result_type := c_result_type_FATAL;

    x_results.add_result(
      p_result_type => c_result_type_FATAL
    , p_entity_type => NULL
    , p_entity_id => NULL
    , p_column_name => NULL
    , p_message_name => PO_MESSAGE_S.PO_ALL_SQL_ERROR
    , p_token1_name => PO_MESSAGE_S.c_ROUTINE_token
    , p_token1_value => d_mod
    , p_token2_name => PO_MESSAGE_S.c_ERR_NUMBER_token
    , p_token2_value => TO_CHAR(d_position)
    , p_token3_name => PO_MESSAGE_S.c_SQL_ERR_token
    , p_token3_value => l_val
    , p_token4_name => PO_MESSAGE_S.c_LSQL_ERR_token
    , p_token4_value => SQLERRM
    );

  END;

  d_position := 200;
  IF d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_result_type',l_result_type);
    PO_LOG.stmt(d_mod,d_position,'l_result_set_id',l_result_set_id);
  END IF;

  -- Fix the result set id.
  IF (l_result_set_id <> x_result_set_id) THEN
    d_position := 210;
    replace_result_set_id(
      p_old_result_set_id  => l_result_set_id
    , p_new_result_set_id  => x_result_set_id
    );
  END IF;

  d_position := 300;

  -- Update the result type if the new result takes priority
  -- over the old rank.

  l_new_rank := result_type_rank(l_result_type);

  IF (l_new_rank < l_result_rank) THEN
    d_position := 310;

    x_result_type := l_result_type;
    l_result_rank := l_new_rank;

    IF d_stmt THEN
      PO_LOG.stmt(d_mod,d_position,'x_result_type',x_result_type);
      PO_LOG.stmt(d_mod,d_position,'l_result_rank',l_result_rank);
    END IF;

    -- If the validation has encountered a serious problem
    -- or the stopping result, stop processing.
    IF (l_result_rank <= g_result_type_rank_FATAL
        OR l_result_rank <= l_stop_rank
        )
    THEN
      d_position := 400;
      IF d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'Stopping loop.  x_result_type',x_result_type);
      END IF;

      EXIT;
    END IF;

  END IF;

END LOOP;

d_position := 500;

-- Commit the result set autonomously.

IF (p_autocommit_results_flag = c_parameter_YES) THEN
  d_position := 600;
  commit_result_set(p_result_set_id => x_result_set_id);
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
    PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  END IF;
  RAISE;

END validate_set;


----------------------------------------------------------------------------
--Pre-reqs: None.
--Modifies:
--  PO_VALIDATION_RESULTS
--Locks: None.
--Function:
--  See the description for validate_set above.
--  This procedure performs the validations as above.
--  Additionally, it removes the data from PO_VALIDATION_RESULTS
--  and extracts it into the output parameter.
--Parameters:
--OUT:
--x_results
--  The results of the validation cycle.
----------------------------------------------------------------------------
PROCEDURE validate_set(
  p_validation_set        IN PO_TBL_VARCHAR2000
, p_headers               IN PO_HEADERS_VAL_TYPE DEFAULT NULL
, p_lines                 IN PO_LINES_VAL_TYPE DEFAULT NULL
, p_line_locations        IN PO_LINE_LOCATIONS_VAL_TYPE DEFAULT NULL
, p_distributions         IN PO_DISTRIBUTIONS_VAL_TYPE DEFAULT NULL
, p_price_differentials   IN PO_PRICE_DIFF_VAL_TYPE DEFAULT NULL
, p_ga_org_assignments    IN PO_GA_ORG_ASSIGN_VAL_TYPE DEFAULT NULL
, p_notification_controls IN PO_NOTIFICATION_CTRL_VAL_TYPE DEFAULT NULL
, p_price_adjustments     IN PO_PRICE_ADJS_VAL_TYPE DEFAULT NULL --Enhanced Pricing
, p_calling_program       IN VARCHAR2 DEFAULT NULL
, p_stopping_result_type  IN VARCHAR2 DEFAULT NULL
, p_parameter_name_tbl    IN PO_TBL_VARCHAR2000 DEFAULT NULL
, p_parameter_value_tbl   IN PO_TBL_VARCHAR2000 DEFAULT NULL
, x_result_type           IN OUT NOCOPY VARCHAR2
, x_results               OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
)
IS
d_mod CONSTANT VARCHAR2(100) := D_validate_set;
d_position NUMBER := 0;
l_result_set_id NUMBER;
l_table_results PO_VALIDATION_RESULTS_TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod);
END IF;

d_position := 100;

SAVEPOINT PO_VALIDATIONS_VALIDATE_SET_SP;

validate_set(
  p_validation_set => p_validation_set
, p_headers => p_headers
, p_lines => p_lines
, p_line_locations => p_line_locations
, p_distributions => p_distributions
, p_price_differentials => p_price_differentials
, p_ga_org_assignments => p_ga_org_assignments
, p_notification_controls => p_notification_controls
, p_price_adjustments => p_price_adjustments --Enhanced Pricing
, p_autocommit_results_flag => c_parameter_NO
, p_calling_program => p_calling_program
, p_stopping_result_type => p_stopping_result_type
, p_parameter_name_tbl => p_parameter_name_tbl
, p_parameter_value_tbl => p_parameter_value_tbl
, x_result_type => x_result_type
, x_result_set_id => l_result_set_id
, x_results => x_results
);

d_position := 200;

l_table_results :=
  PO_VALIDATION_RESULTS_TYPE.get_result_set_from_gt(
    p_result_set_id => l_result_set_id
  );

d_position := 300;

ROLLBACK TO SAVEPOINT PO_VALIDATIONS_VALIDATE_SET_SP;

d_position := 400;

x_results.append( p_results => l_table_results );

d_position := 500;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'l_result_set_id',l_result_set_id);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
    PO_LOG.proc_end(d_mod,'l_result_set_id',l_result_set_id);
    PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  END IF;
  RAISE;

END validate_set;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: None.
--Locks: None.
--Function:
--  Ranks the result types in ascending order from
--  most severe error (FATAL) to least severe (SUCCESS).
--Parameters:
--IN:
--p_result_type
--  The result type whose value should be ranked.
--Returns:
--  The rank of the result type.
--  If the input result type cannot be ranked (or is NULL),
--  -1 is returned.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION result_type_rank(p_result_type IN VARCHAR2)
RETURN NUMBER
IS
d_mod CONSTANT VARCHAR2(100) := D_result_type_rank;
l_rank NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_result_type',p_result_type);
END IF;

FOR i IN 1 .. c_result_type_rank_tbl.COUNT LOOP
  IF (c_result_type_rank_tbl(i) = p_result_type) THEN
    l_rank := i;
    EXIT;
  END IF;
END LOOP;

IF (l_rank IS NULL) THEN
  l_rank := -1;
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_return(d_mod,l_rank);
END IF;

RETURN l_rank;

END result_type_rank;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS, sequences.
--Locks: None.
--Function:
--  Determines whether or not the unit price of a line is allowed
--  to be updated based on external data.
--Parameters:
--IN:
--p_line_id_tbl
--  Identifies the lines to be validated.
--p_draft_id_tbl
--  Further identifies the lines, used in result messages.
--p_stopping_result_type
--  Indicates that if this result type is encountered,
--  processing should stop and return.
--  Use one of the c_result_type_XXX variables.
--  For no stopping, use NULL.
--OUT:
--x_result_set_id
--  Identifier for the output results in PO_VALIDATION_RESULTS.
--x_result_type
--  Provides a summary of the validation results.
--  VARCHAR2(30)
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_unit_price_change(
  p_line_id_tbl   IN PO_TBL_NUMBER
, p_price_break_lookup_code_tbl IN PO_TBL_VARCHAR30
 -- <Bug 13503748 : Encumbrance ER : Parameter p_amount_changed_flag_tbl
 -- identify if the amount on the distributions of the line has been changed
, p_amount_changed_flag_tbl  IN PO_TBL_VARCHAR1
, p_stopping_result_type IN VARCHAR2 DEFAULT NULL
, x_result_type   OUT NOCOPY VARCHAR2
, x_result_set_id IN OUT NOCOPY NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
)
IS
d_mod CONSTANT VARCHAR2(100) := D_validate_unit_price_change;
l_lines PO_LINES_VAL_TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id_tbl',p_line_id_tbl);
   PO_LOG.proc_begin(d_mod,'p_amount_changed_flag_tbl',p_amount_changed_flag_tbl);--<Bug 13503748 :Encumbrance ER>--
  PO_LOG.proc_begin(d_mod,'p_stopping_result_type',p_stopping_result_type);
END IF;

l_lines := PO_LINES_VAL_TYPE();
l_lines.po_line_id := p_line_id_tbl;
l_lines.price_break_lookup_code := p_price_break_lookup_code_tbl;
l_lines.amount_changed_flag := p_amount_changed_flag_tbl;--<Bug 13503748 :Encumbrance ER>--

validate_set(
  p_validation_set => c_allow_unit_price_change_vs
, p_lines => l_lines
, p_autocommit_results_flag => c_parameter_NO
, p_stopping_result_type => p_stopping_result_type
, x_result_type => x_result_type
, x_result_set_id => x_result_set_id
, x_results => x_results
);

IF PO_LOG.d_proc THEN
  PO_LOG.stmt(d_mod,0,'x_result_set_id',x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END validate_unit_price_change;

-- <<PDOI Enhancement Bug#17063664 Start>>
-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS sequences.
--Locks: None.
--Function:
--  Performs the necessary validations for OA flows on the entities provided.
--  The results are removed from the table, as they are collected into the
--  output object.
--Parameters:
--IN:
--p_req_reference
--  The data that needs to be validated.
--  Pass NULL if nothing of a particular entity type needs to be validated.
--OUT:
--x_result_type
--  Provides a summary of the validation results.
--  VARCHAR2(30)
--x_results
--  The results of the validations.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_cross_ou_purchasing(
  p_req_reference         IN PO_REQ_REF_VAL_TYPE DEFAULT NULL
, x_result_set_id         IN OUT NOCOPY NUMBER
, x_result_type           OUT NOCOPY VARCHAR2
, x_results               IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
)
IS
d_mod CONSTANT VARCHAR2(100) := D_validate_cross_ou_purchasing;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod);
END IF;

validate_set(
  p_validation_set => c_cross_ou_validations
, p_req_reference => p_req_reference
, x_result_type => x_result_type
, x_result_set_id => x_result_set_id
, x_results => x_results
);

IF PO_LOG.d_proc THEN
  PO_LOG.stmt(d_mod,0,'x_result_set_id',x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END validate_cross_ou_purchasing;
-- <<PDOI Enhancement Bug#17063664 End>>

-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS sequences.
--Locks: None.
--Function:
--  Performs the necessary validations for OA flows on the entities provided.
--  The results are removed from the table, as they are collected into the
--  output object.
--Parameters:
--IN:
--p_headers
--p_lines
--p_line_locations
--p_distributions
--p_price_differentials
--  The data that needs to be validated.
--  Pass NULL if nothing of a particular entity type needs to be validated.
--OUT:
--x_result_type
--  Provides a summary of the validation results.
--  VARCHAR2(30)
--x_results
--  The results of the validations.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_html_order(
  p_headers               IN PO_HEADERS_VAL_TYPE DEFAULT NULL
, p_lines                 IN PO_LINES_VAL_TYPE DEFAULT NULL
, p_line_locations        IN PO_LINE_LOCATIONS_VAL_TYPE DEFAULT NULL
, p_distributions         IN PO_DISTRIBUTIONS_VAL_TYPE DEFAULT NULL
, p_price_differentials   IN PO_PRICE_DIFF_VAL_TYPE DEFAULT NULL
, p_price_adjustments     IN PO_PRICE_ADJS_VAL_TYPE DEFAULT NULL --Enhanced Pricing
, x_result_type           OUT NOCOPY VARCHAR2
, x_results               OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
)
IS
d_mod CONSTANT VARCHAR2(100) := D_validate_html_order;
d_position NUMBER := 0;
l_validation_set PO_TBL_VARCHAR2000;
--<Bug 18883269>
  l_parameter_name_tbl   PO_TBL_VARCHAR2000 := PO_TBL_VARCHAR2000();
  l_parameter_value_tbl  PO_TBL_VARCHAR2000 := PO_TBL_VARCHAR2000();
  l_po_encumbrance_flag       VARCHAR2(1);
--<End Bug 18883269>
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod);
END IF;

d_position := 1;

l_validation_set := PO_TBL_VARCHAR2000();

--<Bug 18883269>
l_parameter_name_tbl.EXTEND(1);
l_parameter_value_tbl.EXTEND(1);

--init sys parameters
select nvl(fsp.purch_encumbrance_flag,'N')
into l_po_encumbrance_flag
from FINANCIALS_SYSTEM_PARAMETERS fsp;

IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'l_po_encumbrance_flag',l_po_encumbrance_flag);
END IF;

l_parameter_name_tbl(1) := 'PO_ENCUMBRANCE_FLAG';
l_parameter_value_tbl(1) := l_po_encumbrance_flag;
--<End bug 18883269>

IF (p_headers IS NOT NULL) THEN
  d_position := 10;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_order_header_vs;
END IF;

IF (p_lines IS NOT NULL) THEN
  d_position := 20;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_order_line_vs;
END IF;

IF (p_line_locations IS NOT NULL) THEN
  d_position := 30;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_order_shipment_vs;
END IF;

IF (p_distributions IS NOT NULL) THEN
  d_position := 40;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_order_distribution_vs;
END IF;

IF (p_price_differentials IS NOT NULL) THEN
  d_position := 50;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_order_price_diff_vs;
END IF;

--Enhanced Pricing Start:
IF (p_price_adjustments IS NOT NULL) THEN
  d_position := 60;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_price_adjustments_vs;
END IF;
--Enhanced Pricing End:

IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'l_validation_set',l_validation_set);
END IF;

d_position := 100;

validate_set(
  p_validation_set => l_validation_set
, p_headers => p_headers
, p_lines => p_lines
, p_line_locations => p_line_locations
, p_distributions => p_distributions
, p_price_differentials => p_price_differentials
, p_price_adjustments => p_price_adjustments  --Enhanced Pricing
, p_calling_program => c_program_OA
--<Bug 18883269>
, p_parameter_name_tbl => l_parameter_name_tbl
, p_parameter_value_tbl => l_parameter_value_tbl
--<End Bug 18883269>
, x_result_type => x_result_type
, x_results => x_results
);

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;

END validate_html_order;


PROCEDURE validate_html_agreement(
  p_headers               IN PO_HEADERS_VAL_TYPE DEFAULT NULL
, p_lines                 IN PO_LINES_VAL_TYPE DEFAULT NULL
, p_line_locations        IN PO_LINE_LOCATIONS_VAL_TYPE DEFAULT NULL
, p_distributions         IN PO_DISTRIBUTIONS_VAL_TYPE DEFAULT NULL
, p_price_differentials   IN PO_PRICE_DIFF_VAL_TYPE DEFAULT NULL
, p_ga_org_assignments    IN PO_GA_ORG_ASSIGN_VAL_TYPE DEFAULT NULL
, p_notification_controls IN PO_NOTIFICATION_CTRL_VAL_TYPE DEFAULT NULL
, p_price_adjustments     IN PO_PRICE_ADJS_VAL_TYPE DEFAULT NULL --Enhanced Pricing
, x_result_type           OUT NOCOPY VARCHAR2
, x_results               OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
)
IS
d_mod CONSTANT VARCHAR2(100) := D_validate_html_agreement;
d_position NUMBER := 0;
l_validation_set PO_TBL_VARCHAR2000;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod);
END IF;

d_position := 1;

l_validation_set := PO_TBL_VARCHAR2000();

IF (p_headers IS NOT NULL) THEN
  d_position := 10;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_agmt_header_vs;
END IF;

IF (p_lines IS NOT NULL) THEN
  d_position := 20;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_agmt_line_vs;
END IF;

IF (p_line_locations IS NOT NULL) THEN
  d_position := 30;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_agmt_price_break_vs;
END IF;

IF (p_ga_org_assignments IS NOT NULL) THEN
  d_position := 40;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_agmt_ga_org_assign_vs;
END IF;

IF (p_price_differentials IS NOT NULL) THEN
  d_position := 50;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_agmt_price_diff_vs;
END IF;

IF (p_notification_controls IS NOT NULL) THEN
  d_position := 60;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_agmt_notif_ctrl_vs;
END IF;

IF (p_distributions IS NOT NULL) THEN
  d_position := 70;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_agmt_distribution_vs;
END IF;

--Enhanced Pricing Start:
IF (p_price_adjustments IS NOT NULL) THEN
  d_position := 80;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_html_price_adjustments_vs;
END IF;
--Enhanced Pricing End:

IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'l_validation_set',l_validation_set);
END IF;

d_position := 100;

validate_set(
  p_validation_set => l_validation_set
, p_headers => p_headers
, p_lines => p_lines
, p_line_locations => p_line_locations
, p_distributions => p_distributions
, p_price_differentials => p_price_differentials
, p_ga_org_assignments => p_ga_org_assignments
, p_notification_controls => p_notification_controls
, p_price_adjustments => p_price_adjustments --Enhanced Pricing
, p_calling_program => c_program_OA
, x_result_type => x_result_type
, x_results => x_results
);

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;

END validate_html_agreement;


-------------------------------------------------------------------------------
--Start of Comments
--Pre-reqs: None.
--Modifies: PO_VALIDATION_RESULTS sequences.
--Locks: None.
--Function:
--  Performs the necessary validations for PDOI on the entities provided.
--  The results are removed from the table, as they are collected into the
--  output object.
--Parameters:
--IN:
--p_headers
--p_lines
--p_line_locations
--p_distributions
--p_price_differentials
--  The data that needs to be validated.
--  Pass NULL if nothing of a particular entity type needs to be validated.
--OUT:
--x_result_type
--  Provides a summary of the validation results.
--  VARCHAR2(30)
--x_results
--  The results of the validations.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_pdoi(
   p_headers               IN PO_HEADERS_VAL_TYPE DEFAULT NULL,
   p_lines                 IN PO_LINES_VAL_TYPE DEFAULT NULL,
   p_line_locations        IN PO_LINE_LOCATIONS_VAL_TYPE DEFAULT NULL,
   p_distributions         IN PO_DISTRIBUTIONS_VAL_TYPE DEFAULT NULL,
   p_price_differentials   IN PO_PRICE_DIFF_VAL_TYPE DEFAULT NULL,
   p_doc_type              IN VARCHAR2 DEFAULT NULL,
   p_action                IN VARCHAR2 DEFAULT 'CREATE',
   p_parameter_name_tbl    IN PO_TBL_VARCHAR2000 DEFAULT NULL,
   p_parameter_value_tbl   IN PO_TBL_VARCHAR2000 DEFAULT NULL,
   x_result_type           OUT NOCOPY VARCHAR2,
   x_results               OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
)
IS

  d_mod CONSTANT VARCHAR2(100) := D_validate_pdoi;
  d_position NUMBER := 0;
  l_validation_set PO_TBL_VARCHAR2000;

BEGIN

  IF PO_LOG.d_proc THEN
     po_log.proc_begin(d_mod, 'p_doc_type', p_doc_type);
     po_log.proc_begin(d_mod, 'p_action', p_action);
  END IF;

  d_position := 1;

  l_validation_set := PO_TBL_VARCHAR2000();

IF (p_headers IS NOT NULL AND p_lines IS NULL AND p_line_locations IS NULL AND
    p_distributions IS NULL AND p_price_differentials IS NULL) THEN
  d_position := 10;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_pdoi_header_common_vs;

  CASE p_doc_type
    WHEN c_doc_type_blanket THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_header_blanket_vs;
    WHEN c_doc_type_standard THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_header_standard_vs;
    WHEN c_doc_type_quotation THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_header_quotation_vs;
    --<PDOI Enhancement Bug#17063664>
    WHEN c_doc_type_contract THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_header_contract_vs;
    ELSE
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod,d_position,'Invalid doc_type in validation_pdoi: '||p_doc_type);
      END IF;
  END CASE;

ELSIF (p_lines IS NOT NULL AND p_action='CREATE' AND p_headers IS NULL AND p_line_locations IS NULL AND
       p_distributions IS NULL AND p_price_differentials IS NULL) THEN
  d_position := 20;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_pdoi_line_common_vs;

  CASE p_doc_type
    WHEN c_doc_type_blanket THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_line_blanket_vs;
    WHEN c_doc_type_standard THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_line_standard_vs;
    WHEN c_doc_type_quotation THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_line_quotation_vs;
    ELSE
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod,d_position,'Invalid doc_type in validation_pdoi: '||p_doc_type);
      END IF;
  END CASE;

ELSIF (p_lines IS NOT NULL AND p_action='UPDATE' AND p_headers IS NULL AND p_line_locations IS NULL AND
       p_distributions IS NULL AND p_price_differentials IS NULL) THEN

  d_position := 20;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_pdoi_line_update_vs;

  CASE p_doc_type
    WHEN c_doc_type_blanket THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_line_blanket_update_vs;

    -- <PDOI Enhancement Bug#17063664>
    WHEN c_doc_type_standard THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_line_standard_update_vs;
    ELSE
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod,d_position,'Invalid doc_type in validation_pdoi: '||p_doc_type);
      END IF;
  END CASE;

  -- <PDOI Enhancement Bug#17063664>
ELSIF (p_lines IS NOT NULL AND p_action='MATCH' AND p_headers IS NULL AND p_line_locations IS NULL AND
       p_distributions IS NULL AND p_price_differentials IS NULL) THEN

  d_position := 20;

  CASE p_doc_type

    WHEN c_doc_type_standard THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_line_standard_match_vs;
    ELSE
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod,d_position,'Invalid doc_type in validation_pdoi: '||p_doc_type);
      END IF;
  END CASE;

ELSIF (p_line_locations IS NOT NULL AND p_headers IS NULL AND p_lines IS NULL AND
       p_distributions IS NULL AND p_price_differentials IS NULL) THEN

  d_position := 30;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_pdoi_line_loc_common_vs;

  CASE p_doc_type
    WHEN c_doc_type_blanket THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_line_loc_blanket_vs;
    WHEN c_doc_type_standard THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_line_loc_standard_vs;
    WHEN c_doc_type_quotation THEN
         l_validation_set :=
           l_validation_set MULTISET UNION DISTINCT c_pdoi_line_loc_quotation_vs;
    ELSE
      IF PO_LOG.d_exc THEN
        PO_LOG.exc(d_mod,d_position,'Invalid doc_type in validation_pdoi: '||p_doc_type);
      END IF;
  END CASE;

ELSIF (p_distributions IS NOT NULL AND p_headers IS NULL AND p_lines IS NULL AND
       p_line_locations IS NULL AND p_price_differentials IS NULL) THEN

  d_position := 40;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_pdoi_dist_common_vs;

ELSIF(p_price_differentials IS NOT NULL AND p_headers IS NULL AND p_lines IS NULL AND
      p_line_locations IS NULL AND p_distributions IS NULL) THEN

  d_position := 50;
  l_validation_set :=
    l_validation_set MULTISET UNION DISTINCT c_pdoi_price_diff_common_vs;

ELSE

  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,'Call to validate_pdoi was incorrectly called.');
  END IF;

END IF;

IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'l_validation_set',l_validation_set);
END IF;

d_position := 100;

validate_set(p_validation_set      => l_validation_set,
             p_headers             => p_headers,
             p_lines               => p_lines,
             p_line_locations      => p_line_locations,
             p_distributions       => p_distributions,
             p_price_differentials => p_price_differentials,
             p_calling_program     => c_program_pdoi,
             p_parameter_name_tbl  => p_parameter_name_tbl,
             p_parameter_value_tbl => p_parameter_value_tbl,
             x_result_type         => x_result_type,
             x_results             => x_results
);

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;

END validate_pdoi;

----------------------------------------------------------------------
-- Logs the result set in the results table at the statement level.
----------------------------------------------------------------------
PROCEDURE log_validation_results_gt(
  p_module_base   IN VARCHAR2
, p_position      IN NUMBER
, p_result_set_id IN NUMBER
)
IS
l_rowid_tbl PO_TBL_VARCHAR2000;
BEGIN
IF PO_LOG.d_stmt THEN
  SELECT VR.rowid
  BULK COLLECT INTO l_rowid_tbl
  FROM PO_VALIDATION_RESULTS_GT VR
  WHERE VR.result_set_id = p_result_set_id
  ;
  PO_LOG.stmt_table(p_module_base,p_position,'PO_VALIDATION_RESULTS_GT',l_rowid_tbl);
END IF;
END log_validation_results_gt;

 -- <Bug 13503748: Edit without unreserve ER>
-- Added a function which checks whether the encumbered amount is correct or
-- not before modifying a fully reserved standard PO.
-------------------------------------------------------------------------------
--Start of Comments
--Name: check_encumbered_amount
--Pre-reqs:
--  data is populated in the base PO tables
--Modifies:
--  None.
--Locks:
--  None
--Procedure:
--  For a particular SPO and the level checks whether the
--  encumbered amount is correct or not. It checks on ly for the
--  completely reserved line.
--Parameters:
--IN:
--p_po_header_id
--  Header id of the document
--OUT
-- x_return_status
--x_return_message
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE check_encumbered_amount
(
 p_po_header_id   IN  NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2,
 x_return_message OUT NOCOPY VARCHAR2
) IS

       d_position NUMBER := 0;
       d_mod CONSTANT VARCHAR2(100) := D_check_encumbered_amount;
       l_log_head  CONSTANT VARCHAR2(100) := D_PACKAGE_BASE || d_mod;

BEGIN

  d_position := 100;

  IF PO_LOG.d_proc THEN
     po_log.proc_begin(d_mod, 'p_po_header_id', p_po_header_id);
  END IF;

  SELECT 'N','PO_INVALID_ENC_AMT' INTO x_return_status,x_return_message from dual
       WHERE EXISTS
       (SELECT po_distribution_id
       FROM po_lines_all pl,
            po_line_locations_all pll,
            po_distributions_all pod
       WHERE pod.line_location_id = pll.line_location_id
       AND pll.po_line_id = pl.po_line_id
       AND pod.encumbered_flag = 'Y'
       --Bug#17819623 : Rounding the value including the rate for amount based lines
       --Bug#18488695 : matching_basis from pll should be used, change from pl to pll
       AND Decode( pll.matching_basis, 'AMOUNT', Round ((Nvl(pod.amount_ordered,0)+NVL(pod.NONRECOVERABLE_TAX,0)) * NVL(pod.RATE,1)),
			      ROUND(pll.PRICE_OVERRIDE * pod.QUANTITY_ORDERED * NVL(pod.RATE,1) +(NVL(pod.NONRECOVERABLE_TAX,0)*NVL(pod.rate,1)))
			      ) <> ROUND(pod.encumbered_amount)
       AND pod.amount_changed_flag IS NULL
       AND pod.prevent_encumbrance_flag ='N'
       AND pod.distribution_type = 'STANDARD'
       AND pod.po_header_id= p_po_header_id);

 IF PO_LOG.d_stmt THEN
   PO_LOG.proc_end(d_mod,'x_return_status',x_return_status);
 END IF;

EXCEPTION

    WHEN No_Data_Found THEN

       x_return_status := 'Y';
       x_return_message := 'PO_VALID_ENC_AMT';
      IF PO_LOG.d_exc THEN
       PO_LOG.exc(d_mod,d_position,NULL);
      END IF;
END check_encumbered_amount;

-------------------------------------------------------------------------
-- <PDOI Enhancement Bug#17063664>
-- Validate Source Doc Reference
-------------------------------------------------------------------------
PROCEDURE validate_source_doc(
  p_source_doc        IN PO_SOURCE_DOC_VAL_TYPE DEFAULT NULL,
  p_source_doc_type   IN VARCHAR2,
  x_result_type       OUT NOCOPY VARCHAR2,
  x_result_set_id     IN OUT NOCOPY NUMBER,
  x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
)
IS

d_mod CONSTANT VARCHAR2(100) := D_validate_source_doc;
l_validation_set PO_TBL_VARCHAR2000;

BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod,'p_source_doc_type',p_source_doc_type);
    END IF;

    IF p_source_doc_type = 'BLANKET' THEN
      l_validation_set := c_source_doc_bpa_validations;
    ELSIF p_source_doc_type = 'CONTRACT' THEN
      l_validation_set := c_source_doc_cpa_validations;
    END IF;


    validate_set(
      p_validation_set => l_validation_set
    , p_source_doc => p_source_doc
    , x_result_type => x_result_type
    , x_result_set_id => x_result_set_id
    , x_results => x_results
    );

    IF PO_LOG.d_proc THEN
      PO_LOG.stmt(d_mod,0,'x_result_set_id',x_result_set_id);
      PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END validate_source_doc;

-------------------------------------------------------------------------
-- <PDOI Enhancement Bug#17063664>
-- Validate Source Doc Reference
-------------------------------------------------------------------------

PROCEDURE validate_req_reference(
  p_req_reference     IN PO_REQ_REF_VAL_TYPE DEFAULT NULL,
  x_result_type       OUT NOCOPY VARCHAR2,
  x_result_set_id     IN OUT NOCOPY NUMBER,
  x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
)
IS
d_mod CONSTANT VARCHAR2(100) := D_validate_req_reference;
l_validation_set PO_TBL_VARCHAR2000;

BEGIN

    IF PO_LOG.d_proc THEN
      PO_LOG.proc_begin(d_mod);
    END IF;

    l_validation_set := c_req_reference_validations;

    validate_set(
      p_validation_set => l_validation_set
    , p_req_reference => p_req_reference
    , x_result_type => x_result_type
    , x_result_set_id => x_result_set_id
    , x_results => x_results
    );

    IF PO_LOG.d_proc THEN
      PO_LOG.stmt(d_mod,0,'x_result_set_id',x_result_set_id);
      PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
    END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END validate_req_reference;

-- Initialize package variables.
BEGIN
  g_result_type_rank_SUCCESS := result_type_rank(c_result_type_SUCCESS);
  g_result_type_rank_FATAL := result_type_rank(c_result_type_FATAL);

END PO_VALIDATIONS;

/
