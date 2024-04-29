--------------------------------------------------------
--  DDL for Package Body PO_PDOI_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_TYPES" AS
/* $Header: PO_PDOI_TYPES.plb 120.7.12010000.17 2014/12/15 17:21:49 sbontala ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_TYPES');

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------

PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_DATE
);


PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR1
);

PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR5
);

PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR30
);

PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR100
);

PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR2000
);

PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR150
);


--------------------------------------------------------------------------
---------------------- PUBLIC PROCEDURES ---------------------------------
--------------------------------------------------------------------------


-----------------------------------------------------------------------
--Start of Comments
--Name: fill_all_headers_attr
--Function:
--  Initialize all the pl/sql tables in the record type. It also sets
--  the record count
--Parameters:
--IN:
--  p_num_records
--    Number of entries for each pl/sql tables in the record type
--IN OUT:
--  x_headers
--    Trecord of tables holding header information
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_all_headers_attr
( p_num_records IN NUMBER,
  x_headers     IN OUT NOCOPY headers_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'fill_all_headers_attr';
d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- set record count
  x_headers.rec_count := p_num_records;

  fill_tbl(p_num_records, x_headers.intf_header_id_tbl);
  fill_tbl(p_num_records, x_headers.draft_id_tbl);
  fill_tbl(p_num_records, x_headers.po_header_id_tbl);
  fill_tbl(p_num_records, x_headers.action_tbl);
  fill_tbl(p_num_records, x_headers.document_num_tbl);
  fill_tbl(p_num_records, x_headers.doc_type_tbl);
  fill_tbl(p_num_records, x_headers.doc_subtype_tbl);
  fill_tbl(p_num_records, x_headers.rate_type_tbl);
  fill_tbl(p_num_records, x_headers.rate_type_code_tbl);
  fill_tbl(p_num_records, x_headers.rate_date_tbl);
  fill_tbl(p_num_records, x_headers.rate_tbl);
  fill_tbl(p_num_records, x_headers.agent_id_tbl);
  fill_tbl(p_num_records, x_headers.agent_name_tbl);
  fill_tbl(p_num_records, x_headers.ship_to_loc_id_tbl);
  fill_tbl(p_num_records, x_headers.ship_to_loc_tbl);
  fill_tbl(p_num_records, x_headers.bill_to_loc_id_tbl);
  fill_tbl(p_num_records, x_headers.bill_to_loc_tbl);
  fill_tbl(p_num_records, x_headers.payment_terms_tbl);
  fill_tbl(p_num_records, x_headers.terms_id_tbl);
  fill_tbl(p_num_records, x_headers.vendor_name_tbl);
  fill_tbl(p_num_records, x_headers.vendor_num_tbl);
  fill_tbl(p_num_records, x_headers.vendor_id_tbl);
  fill_tbl(p_num_records, x_headers.vendor_site_code_tbl);
  fill_tbl(p_num_records, x_headers.vendor_site_id_tbl);
  fill_tbl(p_num_records, x_headers.vendor_contact_tbl);
  fill_tbl(p_num_records, x_headers.vendor_contact_id_tbl);
  fill_tbl(p_num_records, x_headers.from_rfq_num_tbl);
  fill_tbl(p_num_records, x_headers.from_header_id_tbl);
  fill_tbl(p_num_records, x_headers.fob_tbl);
  fill_tbl(p_num_records, x_headers.freight_carrier_tbl);
  fill_tbl(p_num_records, x_headers.freight_term_tbl);
  fill_tbl(p_num_records, x_headers.pay_on_code_tbl);
  fill_tbl(p_num_records, x_headers.shipping_control_tbl);
  fill_tbl(p_num_records, x_headers.currency_code_tbl);
  fill_tbl(p_num_records, x_headers.quote_warning_delay_tbl);
  fill_tbl(p_num_records, x_headers.approval_required_flag_tbl);
  fill_tbl(p_num_records, x_headers.reply_date_tbl);
  fill_tbl(p_num_records, x_headers.approval_status_tbl);
  fill_tbl(p_num_records, x_headers.approved_date_tbl);
  fill_tbl(p_num_records, x_headers.from_type_lookup_code_tbl);
  fill_tbl(p_num_records, x_headers.revision_num_tbl);
  fill_tbl(p_num_records, x_headers.confirming_order_flag_tbl);
  fill_tbl(p_num_records, x_headers.acceptance_required_flag_tbl);
  fill_tbl(p_num_records, x_headers.min_release_amount_tbl);
  fill_tbl(p_num_records, x_headers.closed_code_tbl);
  fill_tbl(p_num_records, x_headers.print_count_tbl);
  fill_tbl(p_num_records, x_headers.frozen_flag_tbl);
  fill_tbl(p_num_records, x_headers.encumbrance_required_flag_tbl);
  fill_tbl(p_num_records, x_headers.vendor_doc_num_tbl);
  fill_tbl(p_num_records, x_headers.org_id_tbl);
  fill_tbl(p_num_records, x_headers.acceptance_due_date_tbl);
  fill_tbl(p_num_records, x_headers.amount_to_encumber_tbl);
  fill_tbl(p_num_records, x_headers.effective_date_tbl);
  fill_tbl(p_num_records, x_headers.expiration_date_tbl);
  fill_tbl(p_num_records, x_headers.po_release_id_tbl);
  fill_tbl(p_num_records, x_headers.release_num_tbl);
  fill_tbl(p_num_records, x_headers.release_date_tbl);
  fill_tbl(p_num_records, x_headers.revised_date_tbl);
  fill_tbl(p_num_records, x_headers.printed_date_tbl);
  fill_tbl(p_num_records, x_headers.closed_date_tbl);
  fill_tbl(p_num_records, x_headers.amount_agreed_tbl);
  fill_tbl(p_num_records, x_headers.amount_limit_tbl);
  fill_tbl(p_num_records, x_headers.firm_flag_tbl);
  fill_tbl(p_num_records, x_headers.gl_encumbered_date_tbl);
  fill_tbl(p_num_records, x_headers.gl_encumbered_period_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_id_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment1_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment2_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment3_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment4_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment5_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment6_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment7_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment8_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment9_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment10_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment11_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment12_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment13_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment14_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment15_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment16_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment17_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment18_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment19_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment20_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment21_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment22_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment23_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment24_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment25_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment26_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment27_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment28_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment29_tbl);
  fill_tbl(p_num_records, x_headers.budget_account_segment30_tbl);
  fill_tbl(p_num_records, x_headers.created_language_tbl);
  fill_tbl(p_num_records, x_headers.style_id_tbl);
  fill_tbl(p_num_records, x_headers.style_display_name_tbl);
  fill_tbl(p_num_records, x_headers.global_agreement_flag_tbl);
  --<PDOI Enhancement Bug#17063664 Start>
  fill_tbl(p_num_records, x_headers.consume_req_demand_flag_tbl);
  fill_tbl(p_num_records, x_headers.pcard_id_tbl);
  --<PDOI Enhancement Bug#17063664 End>

  -- standard who columns
  fill_tbl(p_num_records, x_headers.last_update_date_tbl);
  fill_tbl(p_num_records, x_headers.last_updated_by_tbl);
  fill_tbl(p_num_records, x_headers.last_update_login_tbl);
  fill_tbl(p_num_records, x_headers.creation_date_tbl);
  fill_tbl(p_num_records, x_headers.created_by_tbl);
  fill_tbl(p_num_records, x_headers.request_id_tbl);
  fill_tbl(p_num_records, x_headers.program_application_id_tbl);
  fill_tbl(p_num_records, x_headers.program_id_tbl);
  fill_tbl(p_num_records, x_headers.program_update_date_tbl);

  -- attributes not read from interface table but exist in txn table
  fill_tbl(p_num_records, x_headers.status_lookup_code_tbl);
  fill_tbl(p_num_records, x_headers.cancel_flag_tbl);
  fill_tbl(p_num_records, x_headers.vendor_order_num_tbl);
  fill_tbl(p_num_records, x_headers.quote_vendor_quote_num_tbl);
  fill_tbl(p_num_records, x_headers.doc_creation_method_tbl);
  fill_tbl(p_num_records, x_headers.quotation_class_code_tbl);
  fill_tbl(p_num_records, x_headers.approved_flag_tbl);
  fill_tbl(p_num_records, x_headers.tax_attribute_update_code_tbl);
  fill_tbl(p_num_records, x_headers.po_dist_id_tbl);

  -- attributes added for processing purpose
  fill_tbl(p_num_records, x_headers.error_flag_tbl);

  --bug17940049
  fill_tbl(p_num_records, x_headers.ame_approval_id_tbl);
  fill_tbl(p_num_records, x_headers.ame_transaction_type_tbl);

  fill_tbl(p_num_records, x_headers.consigned_consumption_flag_tbl);-- Bug 18891225

  -- Bug 20022541 PDOI Support for Supply_agreement_flag
  fill_tbl(p_num_records, x_headers.supply_agreement_flag_tbl);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  (
    p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END fill_all_headers_attr;


-----------------------------------------------------------------------
--Start of Comments
--Name: fill_all_lines_attr
--Function:
--  Initialize all the pl/sql tables in the record type. It also sets
--  the record count
--Parameters:
--IN:
--  p_num_records
--    Number of entries for each pl/sql tables in the record type
--IN OUT:
--  x_headers
--    Trecord of tables holding line information
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_all_lines_attr
( p_num_records IN NUMBER,
  x_lines     IN OUT NOCOPY lines_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'fill_all_lines_attr';
d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- set record count
  x_lines.rec_count := p_num_records;

  -- attributes read from line interface records
  fill_tbl(p_num_records, x_lines.intf_line_id_tbl);
  fill_tbl(p_num_records, x_lines.intf_header_id_tbl);
  fill_tbl(p_num_records, x_lines.po_header_id_tbl);
  fill_tbl(p_num_records, x_lines.po_line_id_tbl);
  fill_tbl(p_num_records, x_lines.action_tbl);
  fill_tbl(p_num_records, x_lines.document_num_tbl);
  fill_tbl(p_num_records, x_lines.item_tbl);
  fill_tbl(p_num_records, x_lines.vendor_product_num_tbl);
  fill_tbl(p_num_records, x_lines.supplier_part_auxid_tbl);
  fill_tbl(p_num_records, x_lines.item_id_tbl);
  fill_tbl(p_num_records, x_lines.item_revision_tbl);
  fill_tbl(p_num_records, x_lines.job_business_group_name_tbl);
  fill_tbl(p_num_records, x_lines.job_business_group_id_tbl);
  fill_tbl(p_num_records, x_lines.job_name_tbl);
  fill_tbl(p_num_records, x_lines.job_id_tbl);
  fill_tbl(p_num_records, x_lines.category_tbl);
  fill_tbl(p_num_records, x_lines.category_id_tbl);
  fill_tbl(p_num_records, x_lines.ip_category_tbl);
  fill_tbl(p_num_records, x_lines.ip_category_id_tbl);
  fill_tbl(p_num_records, x_lines.uom_code_tbl);
  fill_tbl(p_num_records, x_lines.unit_of_measure_tbl);
  fill_tbl(p_num_records, x_lines.line_type_tbl);
  fill_tbl(p_num_records, x_lines.line_type_id_tbl);
  fill_tbl(p_num_records, x_lines.un_number_tbl);
  fill_tbl(p_num_records, x_lines.un_number_id_tbl);
  fill_tbl(p_num_records, x_lines.hazard_class_tbl);
  fill_tbl(p_num_records, x_lines.hazard_class_id_tbl);
  fill_tbl(p_num_records, x_lines.template_name_tbl);
  fill_tbl(p_num_records, x_lines.template_id_tbl);
  fill_tbl(p_num_records, x_lines.item_desc_tbl);
  fill_tbl(p_num_records, x_lines.unit_price_tbl);
  fill_tbl(p_num_records, x_lines.base_unit_price_tbl);
  fill_tbl(p_num_records, x_lines.from_header_id_tbl);
  fill_tbl(p_num_records, x_lines.from_line_id_tbl);
  fill_tbl(p_num_records, x_lines.list_price_per_unit_tbl);
  fill_tbl(p_num_records, x_lines.market_price_tbl);
  fill_tbl(p_num_records, x_lines.capital_expense_flag_tbl);
  fill_tbl(p_num_records, x_lines.min_release_amount_tbl);
  fill_tbl(p_num_records, x_lines.allow_price_override_flag_tbl);
  fill_tbl(p_num_records, x_lines.price_type_tbl);
  fill_tbl(p_num_records, x_lines.price_break_lookup_code_tbl);
  fill_tbl(p_num_records, x_lines.closed_code_tbl);
  fill_tbl(p_num_records, x_lines.quantity_tbl);
  fill_tbl(p_num_records, x_lines.line_num_tbl);
  fill_tbl(p_num_records, x_lines.shipment_num_tbl);
  fill_tbl(p_num_records, x_lines.price_chg_accept_flag_tbl);
  fill_tbl(p_num_records, x_lines.effective_date_tbl);
  fill_tbl(p_num_records, x_lines.expiration_date_tbl);
  fill_tbl(p_num_records, x_lines.attribute14_tbl);
  fill_tbl(p_num_records, x_lines.price_update_tolerance_tbl);
  fill_tbl(p_num_records, x_lines.line_loc_populated_flag_tbl);
   --<< PDOI Enhancement Bug#17063664 START >>--
  fill_tbl(p_num_records, x_lines.requisition_line_id_tbl);
  fill_tbl(p_num_records, x_lines.oke_contract_header_id_tbl);
  fill_tbl(p_num_records, x_lines.oke_contract_version_id_tbl);
  fill_tbl(p_num_records, x_lines.bid_number_tbl);
  fill_tbl(p_num_records, x_lines.bid_line_number_tbl);
  fill_tbl(p_num_records, x_lines.auction_header_id_tbl);
  fill_tbl(p_num_records, x_lines.auction_line_number_tbl);
  fill_tbl(p_num_records, x_lines.auction_display_number_tbl);
  fill_tbl(p_num_records, x_lines.txn_flow_header_id_tbl);
  fill_tbl(p_num_records, x_lines.transaction_reason_code_tbl);
  fill_tbl(p_num_records, x_lines.note_to_vendor_tbl);
  fill_tbl(p_num_records, x_lines.supplier_ref_number_tbl);
  fill_tbl(p_num_records, x_lines.orig_from_req_flag_tbl);
  fill_tbl(p_num_records, x_lines.consigned_flag_tbl);
  fill_tbl(p_num_records, x_lines.need_by_date_tbl);
  fill_tbl(p_num_records, x_lines.ship_to_loc_id_tbl);
  fill_tbl(p_num_records, x_lines.ship_to_org_id_tbl);
  fill_tbl(p_num_records, x_lines.ship_to_org_code_tbl);
  fill_tbl(p_num_records, x_lines.ship_to_loc_tbl);
  fill_tbl(p_num_records, x_lines.org_id_tbl);
  fill_tbl(p_num_records, x_lines.taxable_flag_tbl);
  fill_tbl(p_num_records, x_lines.project_id_tbl);
  fill_tbl(p_num_records, x_lines.task_id_tbl);
  --<< PDOI Enhancement Bug#17063664 END >>--
    -- PDOI for Complex PO Project
  fill_tbl(p_num_records, x_lines.retainage_rate_tbl);
  fill_tbl(p_num_records, x_lines.max_retainage_amount_tbl);
  fill_tbl(p_num_records, x_lines.progress_payment_rate_tbl);
  fill_tbl(p_num_records, x_lines.recoupment_rate_tbl);
  fill_tbl(p_num_records, x_lines.advance_amount_tbl);

  fill_tbl(p_num_records, x_lines.negotiated_flag_tbl);
  fill_tbl(p_num_records, x_lines.amount_tbl);
  fill_tbl(p_num_records, x_lines.contractor_last_name_tbl);
  fill_tbl(p_num_records, x_lines.contractor_first_name_tbl);
  fill_tbl(p_num_records, x_lines.over_tolerance_err_flag_tbl);
  fill_tbl(p_num_records, x_lines.not_to_exceed_price_tbl);
  fill_tbl(p_num_records, x_lines.po_release_id_tbl);
  fill_tbl(p_num_records, x_lines.release_num_tbl);
  fill_tbl(p_num_records, x_lines.source_shipment_id_tbl);
  fill_tbl(p_num_records, x_lines.contract_num_tbl);
  fill_tbl(p_num_records, x_lines.contract_id_tbl);
  fill_tbl(p_num_records, x_lines.type_1099_tbl);
  fill_tbl(p_num_records, x_lines.closed_by_tbl);
  fill_tbl(p_num_records, x_lines.closed_date_tbl);
  fill_tbl(p_num_records, x_lines.committed_amount_tbl);
  fill_tbl(p_num_records, x_lines.qty_rcv_exception_code_tbl);
  fill_tbl(p_num_records, x_lines.weight_uom_code_tbl);
  fill_tbl(p_num_records, x_lines.volume_uom_code_tbl);
  fill_tbl(p_num_records, x_lines.secondary_unit_of_meas_tbl);
  fill_tbl(p_num_records, x_lines.secondary_quantity_tbl);
  fill_tbl(p_num_records, x_lines.preferred_grade_tbl);
  fill_tbl(p_num_records, x_lines.process_code_tbl);
  fill_tbl(p_num_records, x_lines.parent_interface_line_id_tbl); -- bug5149827
  fill_tbl(p_num_records, x_lines.file_line_language_tbl); -- bug 5489942

  -- standard who columns
  fill_tbl(p_num_records, x_lines.last_updated_by_tbl);
  fill_tbl(p_num_records, x_lines.last_update_date_tbl);
  fill_tbl(p_num_records, x_lines.last_update_login_tbl);
  fill_tbl(p_num_records, x_lines.creation_date_tbl);
  fill_tbl(p_num_records, x_lines.created_by_tbl);
  fill_tbl(p_num_records, x_lines.request_id_tbl);
  fill_tbl(p_num_records, x_lines.program_application_id_tbl);
  fill_tbl(p_num_records, x_lines.program_id_tbl);
  fill_tbl(p_num_records, x_lines.program_update_date_tbl);

  -- attributes that are in line txn table but not in interface table
  fill_tbl(p_num_records, x_lines.order_type_lookup_code_tbl);
  fill_tbl(p_num_records, x_lines.purchase_basis_tbl);
  fill_tbl(p_num_records, x_lines.matching_basis_tbl);
  fill_tbl(p_num_records, x_lines.unordered_flag_tbl);
  fill_tbl(p_num_records, x_lines.cancel_flag_tbl);
  fill_tbl(p_num_records, x_lines.quantity_committed_tbl);
  fill_tbl(p_num_records, x_lines.tax_attribute_update_code_tbl);

  -- attributes read from the header interface record
  fill_tbl(p_num_records, x_lines.draft_id_tbl);
  fill_tbl(p_num_records, x_lines.hd_action_tbl);
  fill_tbl(p_num_records, x_lines.hd_po_header_id_tbl);
  fill_tbl(p_num_records, x_lines.hd_vendor_id_tbl);
  -- PDOI Enhancement Bug#17063664
  fill_tbl(p_num_records, x_lines.hd_ship_to_loc_id_tbl);
  fill_tbl(p_num_records, x_lines.hd_vendor_site_id_tbl);
  fill_tbl(p_num_records, x_lines.hd_min_release_amount_tbl);
  fill_tbl(p_num_records, x_lines.hd_start_date_tbl);
  fill_tbl(p_num_records, x_lines.hd_end_date_tbl);
  fill_tbl(p_num_records, x_lines.hd_global_agreement_flag_tbl);
  fill_tbl(p_num_records, x_lines.hd_currency_code_tbl);
  fill_tbl(p_num_records, x_lines.hd_created_language_tbl);
  fill_tbl(p_num_records, x_lines.hd_style_id_tbl);
  fill_tbl(p_num_records, x_lines.hd_rate_type_tbl);
  fill_tbl(p_num_records, x_lines.hd_rate_tbl);
  fill_tbl(p_num_records, x_lines.hd_rate_date_tbl); -- PDOI Enhancement Bug#17063664

  -- attributes added for location processing
  fill_tbl(p_num_records, x_lines.create_line_loc_tbl);

  -- attributes added for uniqueness checking
  fill_tbl(p_num_records, x_lines.origin_line_num_tbl);
  fill_tbl(p_num_records, x_lines.group_num_tbl);
  fill_tbl(p_num_records, x_lines.match_line_found_tbl);
  fill_tbl(p_num_records, x_lines.line_num_unique_tbl);

  -- attributes added for processing purpose
  fill_tbl(p_num_records, x_lines.error_flag_tbl);
  fill_tbl(p_num_records, x_lines.need_to_reject_flag_tbl);
  fill_tbl(p_num_records, x_lines.allow_desc_update_flag_tbl);
  fill_tbl(p_num_records, x_lines.qty_rcv_tolerance_tbl); -- Bug 18891225


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  (
    p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END fill_all_lines_attr;


-----------------------------------------------------------------------
--Start of Comments
--Name: fill_all_line_locs_attr
--Function:
--  Initialize all the pl/sql tables in the record type. It also sets
--  the record count
--Parameters:
--IN:
--  p_num_records
--    Number of entries for each pl/sql tables in the record type
--IN OUT:
--  x_headers
--    Trecord of tables holding line location information
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_all_line_locs_attr
( p_num_records IN NUMBER,
  x_line_locs   IN OUT NOCOPY line_locs_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'fill_all_line_locs_attr';
d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- set record count
  x_line_locs.rec_count := p_num_records;

  fill_tbl(p_num_records, x_line_locs.intf_line_loc_id_tbl);
  fill_tbl(p_num_records, x_line_locs.intf_line_id_tbl);
  fill_tbl(p_num_records, x_line_locs.intf_header_id_tbl);
  fill_tbl(p_num_records, x_line_locs.shipment_num_tbl);
  fill_tbl(p_num_records, x_line_locs.shipment_type_tbl);
  fill_tbl(p_num_records, x_line_locs.line_loc_id_tbl);
  fill_tbl(p_num_records, x_line_locs.ship_to_org_code_tbl);
  fill_tbl(p_num_records, x_line_locs.ship_to_org_id_tbl);
  fill_tbl(p_num_records, x_line_locs.ship_to_loc_tbl);
  fill_tbl(p_num_records, x_line_locs.ship_to_loc_id_tbl);
  fill_tbl(p_num_records, x_line_locs.payment_terms_tbl);
  fill_tbl(p_num_records, x_line_locs.terms_id_tbl);
  fill_tbl(p_num_records, x_line_locs.receiving_routing_tbl);
  fill_tbl(p_num_records, x_line_locs.receiving_routing_id_tbl);
  fill_tbl(p_num_records, x_line_locs.inspection_required_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.receipt_required_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.price_override_tbl);
  -- <<Bug#17998869 Start>>
  fill_tbl(p_num_records, x_line_locs.lead_time_tbl);
  -- <<Bug#17998869 End>>
  fill_tbl(p_num_records, x_line_locs.qty_rcv_tolerance_tbl);
  fill_tbl(p_num_records, x_line_locs.qty_rcv_exception_code_tbl);
  fill_tbl(p_num_records, x_line_locs.enforce_ship_to_loc_code_tbl);
  fill_tbl(p_num_records, x_line_locs.allow_sub_receipts_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.days_early_receipt_allowed_tbl);
  fill_tbl(p_num_records, x_line_locs.days_late_receipt_allowed_tbl);
  fill_tbl(p_num_records, x_line_locs.receipt_days_except_code_tbl);
  fill_tbl(p_num_records, x_line_locs.invoice_close_tolerance_tbl);
  fill_tbl(p_num_records, x_line_locs.receive_close_tolerance_tbl);
  fill_tbl(p_num_records, x_line_locs.accrue_on_receipt_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.firm_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.fob_tbl);
  fill_tbl(p_num_records, x_line_locs.freight_carrier_tbl);
  fill_tbl(p_num_records, x_line_locs.freight_term_tbl);
  fill_tbl(p_num_records, x_line_locs.need_by_date_tbl);
  fill_tbl(p_num_records, x_line_locs.promised_date_tbl);
  fill_tbl(p_num_records, x_line_locs.quantity_tbl);
  fill_tbl(p_num_records, x_line_locs.amount_tbl);  -- PDOI for Complex PO Project
  fill_tbl(p_num_records, x_line_locs.start_date_tbl);
  fill_tbl(p_num_records, x_line_locs.end_date_tbl);
  fill_tbl(p_num_records, x_line_locs.note_to_receiver_tbl);
  fill_tbl(p_num_records, x_line_locs.price_discount_tbl);
  fill_tbl(p_num_records, x_line_locs.secondary_unit_of_meas_tbl);
  fill_tbl(p_num_records, x_line_locs.secondary_quantity_tbl);
  fill_tbl(p_num_records, x_line_locs.preferred_grade_tbl);
  fill_tbl(p_num_records, x_line_locs.tax_code_id_tbl);
  fill_tbl(p_num_records, x_line_locs.tax_name_tbl);
  fill_tbl(p_num_records, x_line_locs.taxable_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.unit_of_measure_tbl);
  fill_tbl(p_num_records, x_line_locs.value_basis_tbl);
  fill_tbl(p_num_records, x_line_locs.matching_basis_tbl);
  fill_tbl(p_num_records, x_line_locs.payment_type_tbl);  -- PDOI for Complex PO Project


  -- attributes in txn table but not in interface table
  fill_tbl(p_num_records, x_line_locs.match_option_tbl);
  fill_tbl(p_num_records, x_line_locs.txn_flow_header_id_tbl);
  fill_tbl(p_num_records, x_line_locs.outsourced_assembly_tbl);
  fill_tbl(p_num_records, x_line_locs.tax_attribute_update_code_tbl);
  --<<PDOI Enhancement Bug#17063664 START>>--
  fill_tbl(p_num_records, x_line_locs.action_tbl);
  --<<PDOI Enhancement Bug#17063664 END>>--

  -- standard who columns
  fill_tbl(p_num_records, x_line_locs.last_updated_by_tbl);
  fill_tbl(p_num_records, x_line_locs.last_update_date_tbl);
  fill_tbl(p_num_records, x_line_locs.last_update_login_tbl);
  fill_tbl(p_num_records, x_line_locs.creation_date_tbl);
  fill_tbl(p_num_records, x_line_locs.created_by_tbl);
  fill_tbl(p_num_records, x_line_locs.request_id_tbl);
  fill_tbl(p_num_records, x_line_locs.program_application_id_tbl);
  fill_tbl(p_num_records, x_line_locs.program_id_tbl);
  fill_tbl(p_num_records, x_line_locs.program_update_date_tbl);

  -- attributes read from the line interface record
  --<<PDOI Enhancement Bug#17063664 START>>--
  fill_tbl(p_num_records, x_line_locs.ln_req_line_id_tbl);
  fill_tbl(p_num_records, x_line_locs.vmi_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.drop_ship_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.consigned_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.wip_entity_id_tbl);
  --<<PDOI Enhancement Bug#17063664 END>>--
  fill_tbl(p_num_records, x_line_locs.ln_po_line_id_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_id_tbl);

  --< Shared Proc 14223789 Start >
  fill_tbl(p_num_records, x_line_locs.ln_item_category_id_tbl);
  --< Shared Proc 14223789 End >

  fill_tbl(p_num_records, x_line_locs.ln_order_type_lookup_code_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_action_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_unit_price_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_quantity_tbl);  -- PDOI for Complex PO Project
  fill_tbl(p_num_records, x_line_locs.ln_amount_tbl);    -- PDOI for Complex PO Project

  fill_tbl(p_num_records, x_line_locs.ln_line_type_id_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_unit_of_measure_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_closed_code_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_purchase_basis_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_matching_basis_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_revision_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_expiration_date_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_government_context_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_closed_reason_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_closed_date_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_closed_by_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_from_header_id_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_from_line_id_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_price_break_lookup_code_tbl);

  -- attributes read from the header interface record
  fill_tbl(p_num_records, x_line_locs.draft_id_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_po_header_id_tbl);
  --< Shared Proc 14223789 Start >
  fill_tbl(p_num_records, x_line_locs.hd_doc_type_tbl);
  --< Shared Proc 14223789 End >
  fill_tbl(p_num_records, x_line_locs.hd_ship_to_loc_id_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_vendor_id_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_vendor_site_id_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_terms_id_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_fob_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_freight_carrier_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_freight_term_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_approved_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_effective_date_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_expiration_date_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_style_id_tbl);

  -- attributes added for item processing(read from line)
  --ln_qty_rcv_tolerance_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_unit_weight_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_unit_volume_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute_category_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute1_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute2_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute3_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute4_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute5_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute6_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute7_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute8_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute9_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute10_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute11_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute12_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute13_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute14_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_attribute15_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_item_desc_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_list_price_per_unit_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_market_price_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_un_number_id_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_hazard_class_id_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_qty_rcv_exception_code_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_weight_uom_code_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_volume_uom_code_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_template_id_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_category_id_tbl);
  fill_tbl(p_num_records, x_line_locs.line_ref_index_tbl);
  fill_tbl(p_num_records, x_line_locs.ln_line_loc_pop_flag_tbl);-- Bug 19528138
  -- attributes added for processing purpose
  fill_tbl(p_num_records, x_line_locs.shipment_num_unique_tbl);
  fill_tbl(p_num_records, x_line_locs.error_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_currency_code_tbl); --- Bug# 11834816
  --<PDOI Enhancement Bug#17063664>
  fill_tbl(p_num_records, x_line_locs.hd_pcard_id_tbl);
    --<Start Bug#19528138>--
  fill_tbl(p_num_records, x_line_locs.hd_org_id_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_type_lookup_code_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_global_agreement_flag_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_rate_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_rate_type_tbl);
  fill_tbl(p_num_records, x_line_locs.hd_rate_date_tbl);
 --<End Bug#19528138>--

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  (
    p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END fill_all_line_locs_attr;

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_all_dists_attr
--Function:
--  Initialize all the pl/sql tables in the record type. It also sets
--  the record count
--Parameters:
--IN:
--  p_num_records
--    Number of entries for each pl/sql tables in the record type
--IN OUT:
--  x_headers
--    Trecord of tables holding distribution information
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_all_dists_attr
( p_num_records IN NUMBER,
  x_dists       IN OUT NOCOPY distributions_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'fill_all_dists_attr';
d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- set record count
  x_dists.rec_count := p_num_records;

  fill_tbl(p_num_records, x_dists.intf_dist_id_tbl);
  fill_tbl(p_num_records, x_dists.intf_header_id_tbl);
  fill_tbl(p_num_records, x_dists.intf_line_id_tbl);
  fill_tbl(p_num_records, x_dists.intf_line_loc_id_tbl);
  fill_tbl(p_num_records, x_dists.po_dist_id_tbl);
  fill_tbl(p_num_records, x_dists.dist_num_tbl);
  fill_tbl(p_num_records, x_dists.deliver_to_loc_tbl);
  fill_tbl(p_num_records, x_dists.deliver_to_loc_id_tbl);
  fill_tbl(p_num_records, x_dists.deliver_to_person_name_tbl);
  fill_tbl(p_num_records, x_dists.deliver_to_person_id_tbl);
  fill_tbl(p_num_records, x_dists.dest_type_tbl);
  fill_tbl(p_num_records, x_dists.dest_type_code_tbl);
  fill_tbl(p_num_records, x_dists.dest_org_tbl);
  fill_tbl(p_num_records, x_dists.dest_org_id_tbl);
  fill_tbl(p_num_records, x_dists.wip_entity_tbl);
  fill_tbl(p_num_records, x_dists.wip_entity_id_tbl);
  fill_tbl(p_num_records, x_dists.wip_line_code_tbl);
  fill_tbl(p_num_records, x_dists.wip_line_id_tbl);
  fill_tbl(p_num_records, x_dists.bom_resource_code_tbl);
  fill_tbl(p_num_records, x_dists.bom_resource_id_tbl);
  fill_tbl(p_num_records, x_dists.charge_account_tbl);
  fill_tbl(p_num_records, x_dists.charge_account_id_tbl);
  fill_tbl(p_num_records, x_dists.dest_charge_account_id_tbl);
  fill_tbl(p_num_records, x_dists.project_accounting_context_tbl);
  fill_tbl(p_num_records, x_dists.award_num_tbl);
  fill_tbl(p_num_records, x_dists.award_id_tbl);
  fill_tbl(p_num_records, x_dists.project_tbl);
  fill_tbl(p_num_records, x_dists.project_id_tbl);
  fill_tbl(p_num_records, x_dists.task_tbl);
  fill_tbl(p_num_records, x_dists.task_id_tbl);
  fill_tbl(p_num_records, x_dists.expenditure_tbl);
  fill_tbl(p_num_records, x_dists.expenditure_type_tbl);
  fill_tbl(p_num_records, x_dists.expenditure_org_tbl);
  fill_tbl(p_num_records, x_dists.expenditure_org_id_tbl);
  fill_tbl(p_num_records, x_dists.expenditure_item_date_tbl);
  fill_tbl(p_num_records, x_dists.end_item_unit_number_tbl);
  fill_tbl(p_num_records, x_dists.dest_context_tbl);
  fill_tbl(p_num_records, x_dists.gl_encumbered_date_tbl);
  fill_tbl(p_num_records, x_dists.gl_encumbered_period_tbl);
  fill_tbl(p_num_records, x_dists.variance_account_id_tbl);
  fill_tbl(p_num_records, x_dists.accrual_account_id_tbl);
  fill_tbl(p_num_records, x_dists.budget_account_id_tbl);
  fill_tbl(p_num_records, x_dists.dest_variance_account_id_tbl);
  fill_tbl(p_num_records, x_dists.dest_subinventory_tbl);
  fill_tbl(p_num_records, x_dists.amount_ordered_tbl);
  fill_tbl(p_num_records, x_dists.quantity_ordered_tbl);
  fill_tbl(p_num_records, x_dists.wip_rep_schedule_id_tbl);
  fill_tbl(p_num_records, x_dists.wip_operation_seq_num_tbl);
  fill_tbl(p_num_records, x_dists.wip_resource_seq_num_tbl);
  fill_tbl(p_num_records, x_dists.prevent_encumbrance_flag_tbl);
  fill_tbl(p_num_records, x_dists.recovery_rate_tbl);
  fill_tbl(p_num_records, x_dists.tax_recovery_override_flag_tbl);
  --PDOI Enhancement bug#17063664
  fill_tbl(p_num_records, x_dists.req_distribution_id_tbl);
  fill_tbl(p_num_records, x_dists.account_segment1_tbl);
  fill_tbl(p_num_records, x_dists.account_segment2_tbl);
  fill_tbl(p_num_records, x_dists.account_segment3_tbl);
  fill_tbl(p_num_records, x_dists.account_segment4_tbl);
  fill_tbl(p_num_records, x_dists.account_segment5_tbl);
  fill_tbl(p_num_records, x_dists.account_segment6_tbl);
  fill_tbl(p_num_records, x_dists.account_segment7_tbl);
  fill_tbl(p_num_records, x_dists.account_segment8_tbl);
  fill_tbl(p_num_records, x_dists.account_segment9_tbl);
  fill_tbl(p_num_records, x_dists.account_segment10_tbl);
  fill_tbl(p_num_records, x_dists.account_segment11_tbl);
  fill_tbl(p_num_records, x_dists.account_segment12_tbl);
  fill_tbl(p_num_records, x_dists.account_segment13_tbl);
  fill_tbl(p_num_records, x_dists.account_segment14_tbl);
  fill_tbl(p_num_records, x_dists.account_segment15_tbl);
  fill_tbl(p_num_records, x_dists.account_segment16_tbl);
  fill_tbl(p_num_records, x_dists.account_segment17_tbl);
  fill_tbl(p_num_records, x_dists.account_segment18_tbl);
  fill_tbl(p_num_records, x_dists.account_segment19_tbl);
  fill_tbl(p_num_records, x_dists.account_segment20_tbl);
  fill_tbl(p_num_records, x_dists.account_segment21_tbl);
  fill_tbl(p_num_records, x_dists.account_segment22_tbl);
  fill_tbl(p_num_records, x_dists.account_segment23_tbl);
  fill_tbl(p_num_records, x_dists.account_segment24_tbl);
  fill_tbl(p_num_records, x_dists.account_segment25_tbl);
  fill_tbl(p_num_records, x_dists.account_segment26_tbl);
  fill_tbl(p_num_records, x_dists.account_segment27_tbl);
  fill_tbl(p_num_records, x_dists.account_segment28_tbl);
  fill_tbl(p_num_records, x_dists.account_segment29_tbl);
  fill_tbl(p_num_records, x_dists.account_segment30_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute1_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute2_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute3_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute4_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute5_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute6_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute7_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute8_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute9_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute10_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute11_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute12_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute13_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute14_tbl);
  fill_tbl(p_num_records, x_dists.dist_attribute15_tbl);
  -- <<PDOI Enhancement Bug#17063664 Start>>
  fill_tbl(p_num_records, x_dists.oke_contract_line_id_tbl);
  fill_tbl(p_num_records, x_dists.oke_contract_del_id_tbl);
  -- <<PDOI Enhancement Bug#17063664 End>>

  -- standard who columns
  fill_tbl(p_num_records, x_dists.last_updated_by_tbl);
  fill_tbl(p_num_records, x_dists.last_update_date_tbl);
  fill_tbl(p_num_records, x_dists.last_update_login_tbl);
  fill_tbl(p_num_records, x_dists.creation_date_tbl);
  fill_tbl(p_num_records, x_dists.created_by_tbl);
  fill_tbl(p_num_records, x_dists.request_id_tbl);
  fill_tbl(p_num_records, x_dists.program_application_id_tbl);
  fill_tbl(p_num_records, x_dists.program_id_tbl);
  fill_tbl(p_num_records, x_dists.program_update_date_tbl);

  -- attributes exist in txn table but not in interface table
  fill_tbl(p_num_records, x_dists.tax_attribute_update_code_tbl);
  fill_tbl(p_num_records, x_dists.award_set_id_tbl); -- bug5201306
  fill_tbl(p_num_records, x_dists.kanban_card_id_tbl); -- Bug 18599449

  -- attributes read from line location record
  fill_tbl(p_num_records, x_dists.loc_ship_to_org_id_tbl);
  fill_tbl(p_num_records, x_dists.loc_line_loc_id_tbl);
  fill_tbl(p_num_records, x_dists.loc_shipment_type_tbl);
  fill_tbl(p_num_records, x_dists.loc_txn_flow_header_id_tbl);
  fill_tbl(p_num_records, x_dists.loc_accrue_on_receipt_flag_tbl);
  fill_tbl(p_num_records, x_dists.loc_need_by_date_tbl);
  fill_tbl(p_num_records, x_dists.loc_promised_date_tbl);
  fill_tbl(p_num_records, x_dists.loc_price_override_tbl);
  fill_tbl(p_num_records, x_dists.loc_outsourced_assembly_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute1_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute2_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute3_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute4_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute5_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute6_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute7_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute8_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute9_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute10_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute11_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute12_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute13_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute14_tbl);
  fill_tbl(p_num_records, x_dists.loc_attribute15_tbl);
  fill_tbl(p_num_records, x_dists.loc_payment_type_tbl); -- Bug#19379838

  -- attributes read from line record
  fill_tbl(p_num_records, x_dists.ln_order_type_lookup_code_tbl);
  -- Bug#17998869
  fill_tbl(p_num_records, x_dists.ln_oke_contract_header_id_tbl);
  fill_tbl(p_num_records, x_dists.ln_purchase_basis_tbl);
  fill_tbl(p_num_records, x_dists.ln_item_id_tbl);
  fill_tbl(p_num_records, x_dists.ln_category_id_tbl);
  fill_tbl(p_num_records, x_dists.ln_line_type_id_tbl);
  fill_tbl(p_num_records, x_dists.ln_po_line_id_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute1_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute2_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute3_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute4_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute5_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute6_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute7_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute8_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute9_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute10_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute11_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute12_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute13_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute14_tbl);
  fill_tbl(p_num_records, x_dists.ln_attribute15_tbl);
  -- <<PDOI Enhancement Bug#17063664 Start>>
  fill_tbl(p_num_records, x_dists.ln_requisition_line_id_tbl);
  fill_tbl(p_num_records, x_dists.loc_consigned_flag_tbl);
  -- <<PDOI Enhancement Bug#17063664 End>>

  -- attributes read from header record
  fill_tbl(p_num_records, x_dists.draft_id_tbl);
  fill_tbl(p_num_records, x_dists.hd_agent_id_tbl);
  fill_tbl(p_num_records, x_dists.hd_po_header_id_tbl);
  -- <<PDOI Enhancement Bug#17063664>>
  fill_tbl(p_num_records, x_dists.hd_currency_code_tbl);
  fill_tbl(p_num_records, x_dists.hd_rate_type_tbl);
  fill_tbl(p_num_records, x_dists.hd_rate_date_tbl);
  fill_tbl(p_num_records, x_dists.hd_rate_tbl);
  fill_tbl(p_num_records, x_dists.hd_type_lookup_code_tbl);
  fill_tbl(p_num_records, x_dists.hd_vendor_id_tbl);
  -- << Bug #17319986 Start >>
  fill_tbl(p_num_records, x_dists.hd_vendor_site_id_tbl);
  -- << Bug #17319986 End >>
  fill_tbl(p_num_records, x_dists.hd_attribute1_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute2_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute3_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute4_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute5_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute6_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute7_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute8_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute9_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute10_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute11_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute12_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute13_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute14_tbl);
  fill_tbl(p_num_records, x_dists.hd_attribute15_tbl);

  -- attributes added for processing
  fill_tbl(p_num_records, x_dists.ship_to_ou_id_tbl);
  fill_tbl(p_num_records, x_dists.ship_to_ou_coa_id_tbl);
  fill_tbl(p_num_records, x_dists.item_status_tbl);
  fill_tbl(p_num_records, x_dists.gms_txn_required_flag_tbl);
  fill_tbl(p_num_records, x_dists.dist_num_unique_tbl);
  fill_tbl(p_num_records, x_dists.error_flag_tbl);

  --<Bug 14610858> GDF attributes
  fill_tbl(p_num_records, x_dists.global_attribute_category_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute1_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute2_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute3_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute4_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute5_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute6_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute7_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute8_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute9_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute10_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute11_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute12_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute13_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute14_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute15_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute16_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute17_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute18_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute19_tbl);
  fill_tbl(p_num_records, x_dists.global_attribute20_tbl);

  fill_tbl(p_num_records, x_dists.interface_distribution_ref_tbl); -- Bug 18891225

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;


EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  (
    p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END fill_all_dists_attr;

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_all_price_diffs_attr
--Function:
--  Initialize all the pl/sql tables in the record type. It also sets
--  the record count
--Parameters:
--IN:
--  p_num_records
--    Number of entries for each pl/sql tables in the record type
--IN OUT:
--  x_headers
--    Trecord of tables holding price differential information
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_all_price_diffs_attr
( p_num_records IN NUMBER,
  x_price_diffs IN OUT NOCOPY price_diffs_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'fill_all_price_diffs_attr';
d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- set record count
  x_price_diffs.rec_count := p_num_records;

  fill_tbl(p_num_records, x_price_diffs.intf_price_diff_id_tbl);
  fill_tbl(p_num_records, x_price_diffs.intf_line_id_tbl); -- bug 5215781
  fill_tbl(p_num_records, x_price_diffs.intf_header_id_tbl); -- bug 5215781
  fill_tbl(p_num_records, x_price_diffs.price_diff_num_tbl);
  fill_tbl(p_num_records, x_price_diffs.price_type_tbl);
  fill_tbl(p_num_records, x_price_diffs.entity_type_tbl);
  fill_tbl(p_num_records, x_price_diffs.entity_id_tbl);
  fill_tbl(p_num_records, x_price_diffs.multiplier_tbl);
  fill_tbl(p_num_records, x_price_diffs.min_multiplier_tbl);
  fill_tbl(p_num_records, x_price_diffs.max_multiplier_tbl);

  -- attribute read from line location
  fill_tbl(p_num_records, x_price_diffs.loc_line_loc_id_tbl);

  -- attributes read from line record
  fill_tbl(p_num_records, x_price_diffs.ln_po_line_id_tbl);

  -- attributes read from header record
  fill_tbl(p_num_records, x_price_diffs.draft_id_tbl);
  fill_tbl(p_num_records, x_price_diffs.hd_style_id_tbl);

  -- attributes added for processing
  fill_tbl(p_num_records, x_price_diffs.error_flag_tbl);
  fill_tbl(p_num_records, x_price_diffs.price_diff_num_unique_tbl);


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  (
    p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END fill_all_price_diffs_attr;

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_all_attr_values_attr
--Function:
--  Initialize all the pl/sql tables in the record type. It also sets
--  the record count
--Parameters:
--IN:
--  p_num_records
--    Number of entries for each pl/sql tables in the record type
--IN OUT:
--  x_headers
--    Trecord of tables holding attribute values information
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_all_attr_values_attr
( p_num_records IN NUMBER,
  x_attr_values IN OUT NOCOPY attr_values_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'fill_all_attr_values_attr';
d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- set record count
  x_attr_values.rec_count := p_num_records;

  -- attribute from attr_values table
  fill_tbl(p_num_records, x_attr_values.intf_attr_values_id_tbl);
  fill_tbl(p_num_records, x_attr_values.org_id_tbl);
  -- Bug#17998869
  fill_tbl(p_num_records, x_attr_values.lead_time_tbl);

  -- attributes from line record
  fill_tbl(p_num_records, x_attr_values.ln_po_line_id_tbl);
  fill_tbl(p_num_records, x_attr_values.ln_ip_category_id_tbl);
  fill_tbl(p_num_records, x_attr_values.ln_item_id_tbl);

  -- attribute from header record
  fill_tbl(p_num_records, x_attr_values.draft_id_tbl);

  -- attributes added for processing purpose
  fill_tbl(p_num_records, x_attr_values.attribute_values_id_tbl);
  fill_tbl(p_num_records, x_attr_values.error_flag_tbl);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  (
    p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END fill_all_attr_values_attr;

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_all_attr_values_tlp_attr
--Function:
--  Initialize all the pl/sql tables in the record type. It also sets
--  the record count
--Parameters:
--IN:
--  p_num_records
--    Number of entries for each pl/sql tables in the record type
--IN OUT:
--  x_headers
--    Trecord of tables holding attribute values tlp information
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_all_attr_values_tlp_attr
( p_num_records IN NUMBER,
  x_attr_values_tlp IN OUT NOCOPY attr_values_tlp_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'fill_all_attr_values_tlp_attr';
d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- set record count
  x_attr_values_tlp.rec_count := p_num_records;

  -- attribute from attr_values table
  fill_tbl(p_num_records, x_attr_values_tlp.intf_attr_values_tlp_id_tbl);
  fill_tbl(p_num_records, x_attr_values_tlp.language_tbl);
  fill_tbl(p_num_records, x_attr_values_tlp.org_id_tbl);

  -- attribute from line
  fill_tbl(p_num_records, x_attr_values_tlp.ln_po_line_id_tbl);
  fill_tbl(p_num_records, x_attr_values_tlp.ln_ip_category_id_tbl);
  fill_tbl(p_num_records, x_attr_values_tlp.ln_item_id_tbl);
  fill_tbl(p_num_records, x_attr_values_tlp.ln_item_desc_tbl);

  -- attribute from headers
  fill_tbl(p_num_records, x_attr_values_tlp.draft_id_tbl);

  -- attributes added for processing purpose
  fill_tbl(p_num_records, x_attr_values_tlp.error_flag_tbl);
  fill_tbl(p_num_records, x_attr_values_tlp.attribute_values_tlp_id_tbl);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  (
    p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END fill_all_attr_values_tlp_attr;

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES --------------------------------
--------------------------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_tbl
--Function:
--  Initialize the pl/sql structure if it is NULL, and allocating the memory
--  for the number of records specified. Otherwise, do nothing
--Parameters:
--IN:
--  p_num_records
--    Number of entries to be allocated for the pl/sql structure
--IN OUT:
--  x_tbl
--    Table to initialize
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_NUMBER
) IS
BEGIN
  IF (x_tbl IS NOT NULL AND x_tbl.COUNT > 0 AND x_tbl.COUNT = p_num_records) THEN  --8449373
    RETURN;
  END IF;

  x_tbl := PO_TBL_NUMBER();
  x_tbl.EXTEND(p_num_records);

END fill_tbl;

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_tbl
--Function:
--  Overload procedure
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_DATE
) IS
BEGIN
  IF (x_tbl IS NOT NULL AND x_tbl.COUNT > 0 AND x_tbl.COUNT = p_num_records) THEN  --8449373
    RETURN;
  END IF;

  x_tbl := PO_TBL_DATE();
  x_tbl.EXTEND(p_num_records);

END fill_tbl;

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_tbl
--Function:
--  Overload procedure
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR1
) IS
BEGIN
  IF (x_tbl IS NOT NULL AND x_tbl.COUNT > 0 AND x_tbl.COUNT = p_num_records) THEN  --8449373
    RETURN;
  END IF;

  x_tbl := PO_TBL_VARCHAR1();
  x_tbl.EXTEND(p_num_records);

END fill_tbl;

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_tbl
--Function:
--  Overload procedure
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR5
) IS
BEGIN
  IF (x_tbl IS NOT NULL AND x_tbl.COUNT > 0 AND x_tbl.COUNT = p_num_records) THEN  --8449373
    RETURN;
  END IF;

  x_tbl := PO_TBL_VARCHAR5();
  x_tbl.EXTEND(p_num_records);

END fill_tbl;

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_tbl
--Function:
--  Overload procedure
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR30
) IS
BEGIN
  IF (x_tbl IS NOT NULL AND x_tbl.COUNT > 0 AND x_tbl.COUNT = p_num_records) THEN  --8449373
    RETURN;
  END IF;

  x_tbl := PO_TBL_VARCHAR30();
  x_tbl.EXTEND(p_num_records);

END fill_tbl;

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_tbl
--Function:
--  Overload procedure
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR100
) IS
BEGIN
  IF (x_tbl IS NOT NULL AND x_tbl.COUNT > 0 AND x_tbl.COUNT = p_num_records) THEN  --8449373
    RETURN;
  END IF;

  x_tbl := PO_TBL_VARCHAR100();
  x_tbl.EXTEND(p_num_records);

END fill_tbl;

-----------------------------------------------------------------------
--Start of Comments
--Name: fill_tbl
--Function:
--  Overload procedure
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR2000
) IS
BEGIN
  IF (x_tbl IS NOT NULL AND x_tbl.COUNT > 0 AND x_tbl.COUNT = p_num_records) THEN  --8449373
    RETURN;
  END IF;

  x_tbl := PO_TBL_VARCHAR2000();
  x_tbl.EXTEND(p_num_records);

END fill_tbl;

-----------------------------------------------------------------------
--Bug 14610858
--Start of Comments
--Name: fill_tbl
--Function:
--  Overload procedure
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_tbl
( p_num_records IN NUMBER,
  x_tbl         IN OUT NOCOPY PO_TBL_VARCHAR150
) IS
BEGIN
  IF (x_tbl IS NOT NULL AND x_tbl.COUNT > 0 AND x_tbl.COUNT = p_num_records) THEN
    RETURN;
  END IF;

  x_tbl := PO_TBL_VARCHAR150();
  x_tbl.EXTEND(p_num_records);

END fill_tbl;

--<PDOI Enhancement Bug#17063664>
-----------------------------------------------------------------------
--<PDOI Enhancement Bug#17063664>
--Start of Comments
--Function:
--  Initialize all the pl/sql tables in the record type. It also sets
--  the record count
--Parameters:
--IN:
--  p_num_records
--    Number of entries for each pl/sql tables in the record type
--IN OUT:
--  x_pricing_rec
--    Pricing Attributes Record
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fill_all_pricing_attr
( p_num_records IN NUMBER,
  x_pricing_rec IN OUT NOCOPY pricing_attributes_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'fill_all_pricing_attr';
d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- set record count
  x_pricing_rec.rec_count := p_num_records;
   fill_tbl(p_num_records, x_pricing_rec.draft_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.po_header_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.po_vendor_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.po_vendor_site_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.org_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.order_type_tbl);
   fill_tbl(p_num_records, x_pricing_rec.doc_sub_type_tbl);
   fill_tbl(p_num_records, x_pricing_rec.enhanced_pricing_flag_tbl);
   fill_tbl(p_num_records, x_pricing_rec.progress_payment_flag_tbl);
   fill_tbl(p_num_records, x_pricing_rec.po_line_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.source_document_type_tbl);
   fill_tbl(p_num_records, x_pricing_rec.source_doc_hdr_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.source_doc_line_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.allow_price_override_flag_tbl);
   fill_tbl(p_num_records, x_pricing_rec.currency_code_tbl);
   fill_tbl(p_num_records, x_pricing_rec.quantity_tbl);
   fill_tbl(p_num_records, x_pricing_rec.base_unit_price_tbl);
   fill_tbl(p_num_records, x_pricing_rec.unit_price_tbl);
   fill_tbl(p_num_records, x_pricing_rec.price_break_lookup_code_tbl);
   fill_tbl(p_num_records, x_pricing_rec.creation_date_tbl);
   fill_tbl(p_num_records, x_pricing_rec.item_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.item_revision_tbl);
   fill_tbl(p_num_records, x_pricing_rec.category_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.supplier_item_num_tbl);
   fill_tbl(p_num_records, x_pricing_rec.rate_tbl);
   fill_tbl(p_num_records, x_pricing_rec.rate_type_tbl);
   fill_tbl(p_num_records, x_pricing_rec.uom_tbl);
   fill_tbl(p_num_records, x_pricing_rec.order_type_lookup_tbl);
   fill_tbl(p_num_records, x_pricing_rec.amount_changed_flag_tbl);
   fill_tbl(p_num_records, x_pricing_rec.existing_line_flag_tbl);
   fill_tbl(p_num_records, x_pricing_rec.price_break_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.need_by_date_tbl);
   fill_tbl(p_num_records, x_pricing_rec.pricing_date_tbl);
   fill_tbl(p_num_records, x_pricing_rec.ship_to_loc_tbl);
   fill_tbl(p_num_records, x_pricing_rec.ship_to_org_tbl);
   fill_tbl(p_num_records, x_pricing_rec.line_loc_id_tbl);
   fill_tbl(p_num_records, x_pricing_rec.processed_flag_tbl);
   fill_tbl(p_num_records, x_pricing_rec.min_req_line_price_tbl);
   fill_tbl(p_num_records, x_pricing_rec.pricing_src_tbl);
   fill_tbl(p_num_records, x_pricing_rec.return_status_tbl);
   fill_tbl(p_num_records, x_pricing_rec.return_mssg_tbl);

   x_pricing_rec.req_line_ids := REQ_LINE_ID_TBL();
   x_pricing_rec.req_line_ids.extend(p_num_records);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  (
    p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;

END fill_all_pricing_attr;


END PO_PDOI_TYPES;

/
