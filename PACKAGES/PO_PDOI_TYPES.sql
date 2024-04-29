--------------------------------------------------------
--  DDL for Package PO_PDOI_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_TYPES" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_TYPES.pls 120.25.12010000.18 2014/12/15 17:19:44 sbontala ship $ */

-- type defined for header records

-- ATTENTION: Whenever a new attribute is added to this record type, make sure
--            that the procedure fill_all_headers_attr is also changed to init
--            the table
TYPE headers_rec_type IS RECORD
(
  -- attributes read from interface table
  intf_header_id_tbl             PO_TBL_NUMBER,
  draft_id_tbl                   PO_TBL_NUMBER,
  po_header_id_tbl               PO_TBL_NUMBER,
  action_tbl                     PO_TBL_VARCHAR30,
  document_num_tbl               PO_TBL_VARCHAR30,
  doc_type_tbl                   PO_TBL_VARCHAR30,
  doc_subtype_tbl                PO_TBL_VARCHAR30,
  rate_type_tbl                  PO_TBL_VARCHAR30,
  rate_type_code_tbl             PO_TBL_VARCHAR30,
  rate_date_tbl                  PO_TBL_DATE,
  rate_tbl                       PO_TBL_NUMBER,
  agent_id_tbl                   PO_TBL_NUMBER,
  agent_name_tbl                 PO_TBL_VARCHAR2000,
  ship_to_loc_id_tbl             PO_TBL_NUMBER,
  ship_to_loc_tbl                PO_TBL_VARCHAR100,
  bill_to_loc_id_tbl             PO_TBL_NUMBER,
  bill_to_loc_tbl                PO_TBL_VARCHAR100,
  payment_terms_tbl              PO_TBL_VARCHAR100,
  terms_id_tbl                   PO_TBL_NUMBER,
  vendor_name_tbl                PO_TBL_VARCHAR2000,
  vendor_num_tbl                 PO_TBL_VARCHAR30,
  vendor_id_tbl                  PO_TBL_NUMBER,
  vendor_site_code_tbl           PO_TBL_VARCHAR30,
  vendor_site_id_tbl             PO_TBL_NUMBER,
  vendor_contact_tbl             PO_TBL_VARCHAR2000,
  vendor_contact_id_tbl          PO_TBL_NUMBER,
  from_rfq_num_tbl               PO_TBL_VARCHAR30,
  from_header_id_tbl             PO_TBL_NUMBER,
  fob_tbl                        PO_TBL_VARCHAR30,
  freight_carrier_tbl            PO_TBL_VARCHAR30,
  freight_term_tbl               PO_TBL_VARCHAR30,
  pay_on_code_tbl                PO_TBL_VARCHAR30,
  shipping_control_tbl           PO_TBL_VARCHAR30,
  currency_code_tbl              PO_TBL_VARCHAR30,
  quote_warning_delay_tbl        PO_TBL_NUMBER,
  approval_required_flag_tbl     PO_TBL_VARCHAR1,
  reply_date_tbl                 PO_TBL_DATE,
  approval_status_tbl            PO_TBL_VARCHAR30,
  approved_date_tbl              PO_TBL_DATE,
  from_type_lookup_code_tbl      PO_TBL_VARCHAR30,
  revision_num_tbl               PO_TBL_NUMBER,
  confirming_order_flag_tbl      PO_TBL_VARCHAR1,
  acceptance_required_flag_tbl   PO_TBL_VARCHAR1,
  min_release_amount_tbl         PO_TBL_NUMBER,
  closed_code_tbl                PO_TBL_VARCHAR30,
  print_count_tbl                PO_TBL_NUMBER,
  frozen_flag_tbl                PO_TBL_VARCHAR1,
  encumbrance_required_flag_tbl  PO_TBL_VARCHAR1,
  vendor_doc_num_tbl             PO_TBL_VARCHAR30,
  org_id_tbl                     PO_TBL_NUMBER,
  acceptance_due_date_tbl        PO_TBL_DATE,
  amount_to_encumber_tbl         PO_TBL_NUMBER,
  effective_date_tbl             PO_TBL_DATE,
  expiration_date_tbl            PO_TBL_DATE,
  po_release_id_tbl              PO_TBL_NUMBER,
  release_num_tbl                PO_TBL_NUMBER,
  release_date_tbl               PO_TBL_DATE,
  revised_date_tbl               PO_TBL_DATE,
  printed_date_tbl               PO_TBL_DATE,
  closed_date_tbl                PO_TBL_DATE,
  amount_agreed_tbl              PO_TBL_NUMBER,
  amount_limit_tbl               PO_TBL_NUMBER, -- bug5352625
  firm_flag_tbl                  PO_TBL_VARCHAR30,
  gl_encumbered_date_tbl         PO_TBL_DATE,
  gl_encumbered_period_tbl       PO_TBL_VARCHAR30,
  budget_account_id_tbl          PO_TBL_NUMBER,
  budget_account_tbl             PO_TBL_VARCHAR2000,
  budget_account_segment1_tbl    PO_TBL_VARCHAR30,
  budget_account_segment2_tbl    PO_TBL_VARCHAR30,
  budget_account_segment3_tbl    PO_TBL_VARCHAR30,
  budget_account_segment4_tbl    PO_TBL_VARCHAR30,
  budget_account_segment5_tbl    PO_TBL_VARCHAR30,
  budget_account_segment6_tbl    PO_TBL_VARCHAR30,
  budget_account_segment7_tbl    PO_TBL_VARCHAR30,
  budget_account_segment8_tbl    PO_TBL_VARCHAR30,
  budget_account_segment9_tbl    PO_TBL_VARCHAR30,
  budget_account_segment10_tbl   PO_TBL_VARCHAR30,
  budget_account_segment11_tbl   PO_TBL_VARCHAR30,
  budget_account_segment12_tbl   PO_TBL_VARCHAR30,
  budget_account_segment13_tbl   PO_TBL_VARCHAR30,
  budget_account_segment14_tbl   PO_TBL_VARCHAR30,
  budget_account_segment15_tbl   PO_TBL_VARCHAR30,
  budget_account_segment16_tbl   PO_TBL_VARCHAR30,
  budget_account_segment17_tbl   PO_TBL_VARCHAR30,
  budget_account_segment18_tbl   PO_TBL_VARCHAR30,
  budget_account_segment19_tbl   PO_TBL_VARCHAR30,
  budget_account_segment20_tbl   PO_TBL_VARCHAR30,
  budget_account_segment21_tbl   PO_TBL_VARCHAR30,
  budget_account_segment22_tbl   PO_TBL_VARCHAR30,
  budget_account_segment23_tbl   PO_TBL_VARCHAR30,
  budget_account_segment24_tbl   PO_TBL_VARCHAR30,
  budget_account_segment25_tbl   PO_TBL_VARCHAR30,
  budget_account_segment26_tbl   PO_TBL_VARCHAR30,
  budget_account_segment27_tbl   PO_TBL_VARCHAR30,
  budget_account_segment28_tbl   PO_TBL_VARCHAR30,
  budget_account_segment29_tbl   PO_TBL_VARCHAR30,
  budget_account_segment30_tbl   PO_TBL_VARCHAR30,
  created_language_tbl           PO_TBL_VARCHAR5,
  style_id_tbl                   PO_TBL_NUMBER,
  style_display_name_tbl         PO_TBL_VARCHAR2000,
  global_agreement_flag_tbl      PO_TBL_VARCHAR1,
  --<PDOI Enhancement Bug#17063664 Start>
  consume_req_demand_flag_tbl    PO_TBL_VARCHAR1,
  pcard_id_tbl                   PO_TBL_NUMBER,
  --<PDOI Enhancement Bug#17063664 End>

  -- standard who columns
  last_update_date_tbl           PO_TBL_DATE,
  last_updated_by_tbl            PO_TBL_NUMBER,
  last_update_login_tbl          PO_TBL_NUMBER,
  creation_date_tbl              PO_TBL_DATE,
  created_by_tbl                 PO_TBL_NUMBER,
  request_id_tbl                 PO_TBL_NUMBER,
  program_application_id_tbl     PO_TBL_NUMBER,
  program_id_tbl                 PO_TBL_NUMBER,
  program_update_date_tbl        PO_TBL_DATE,

  -- attributes not read from interface table but exist in txn table
  status_lookup_code_tbl         PO_TBL_VARCHAR30,
  cancel_flag_tbl                PO_TBL_VARCHAR1,
  vendor_order_num_tbl           PO_TBL_VARCHAR30,
  quote_vendor_quote_num_tbl     PO_TBL_VARCHAR30,
  doc_creation_method_tbl        PO_TBL_VARCHAR30,
  quotation_class_code_tbl       PO_TBL_VARCHAR30,
  approved_flag_tbl              PO_TBL_VARCHAR1,
  tax_attribute_update_code_tbl  PO_TBL_VARCHAR30,
  po_dist_id_tbl                 PO_TBL_NUMBER,

  -- attributes added for processing purpose
  error_flag_tbl                 PO_TBL_VARCHAR1,
  rec_count                      NUMBER,
  intf_id_index_tbl              DBMS_SQL.NUMBER_TABLE,

  --bug17940049 add AME_APPROVAL_ID and AME_TRANSACTION_TYPE
  ame_approval_id_tbl            PO_TBL_NUMBER,
  ame_transaction_type_tbl       PO_TBL_VARCHAR30,
  consigned_consumption_flag_tbl PO_TBL_VARCHAR1, -- Bug 18891225

  -- Bug 20022541 PDOI Support for Supply_agreement_flag
  supply_agreement_flag_tbl 	 PO_TBL_VARCHAR1

  -- ATTENTION: If you are adding new attributes to this record type, see
  --            the message above first.
);


-- type defined for line records

-- ATTENTION: Whenever a new attribute is added to this record type, make sure
--            that the procedure fill_all_lines_attr is also changed to init
--            the table
TYPE lines_rec_type IS RECORD
(
  -- attributes read from line interface records
  intf_line_id_tbl               PO_TBL_NUMBER,
  intf_header_id_tbl             PO_TBL_NUMBER,
  po_header_id_tbl               PO_TBL_NUMBER,
  po_line_id_tbl                 PO_TBL_NUMBER,
  action_tbl                     PO_TBL_VARCHAR30,
  document_num_tbl               PO_TBL_VARCHAR30,
  item_tbl                       PO_TBL_VARCHAR2000,
  vendor_product_num_tbl         PO_TBL_VARCHAR30,
  supplier_part_auxid_tbl        PO_TBL_VARCHAR2000,
  item_id_tbl                    PO_TBL_NUMBER,
  item_revision_tbl              PO_TBL_VARCHAR5,
  job_business_group_name_tbl    PO_TBL_VARCHAR2000,
  job_business_group_id_tbl      PO_TBL_NUMBER,
  job_name_tbl                   PO_TBL_VARCHAR2000,
  job_id_tbl                     PO_TBL_NUMBER,
  category_tbl                   PO_TBL_VARCHAR2000,
  category_id_tbl                PO_TBL_NUMBER,
  ip_category_tbl                PO_TBL_VARCHAR2000,
  ip_category_id_tbl             PO_TBL_NUMBER,
  uom_code_tbl                   PO_TBL_VARCHAR5,
  unit_of_measure_tbl            PO_TBL_VARCHAR30,
  line_type_tbl                  PO_TBL_VARCHAR30,
  line_type_id_tbl               PO_TBL_NUMBER,
  un_number_tbl                  PO_TBL_VARCHAR30,
  un_number_id_tbl               PO_TBL_NUMBER,
  hazard_class_tbl               PO_TBL_VARCHAR100,
  hazard_class_id_tbl            PO_TBL_NUMBER,
  template_name_tbl              PO_TBL_VARCHAR30,
  template_id_tbl                PO_TBL_NUMBER,
  item_desc_tbl                  PO_TBL_VARCHAR2000,
  unit_price_tbl                 PO_TBL_NUMBER,
  base_unit_price_tbl            PO_TBL_NUMBER,
  from_header_id_tbl             PO_TBL_NUMBER,
  from_line_id_tbl               PO_TBL_NUMBER,
  list_price_per_unit_tbl        PO_TBL_NUMBER,
  market_price_tbl               PO_TBL_NUMBER,
  capital_expense_flag_tbl       PO_TBL_VARCHAR1,
  min_release_amount_tbl         PO_TBL_NUMBER,
  allow_price_override_flag_tbl  PO_TBL_VARCHAR1,
  price_type_tbl                 PO_TBL_VARCHAR30,
  price_break_lookup_code_tbl    PO_TBL_VARCHAR30,
  closed_code_tbl                PO_TBL_VARCHAR30,
  quantity_tbl                   PO_TBL_NUMBER,
  line_num_tbl                   PO_TBL_NUMBER,
  shipment_num_tbl               PO_TBL_NUMBER,
  price_chg_accept_flag_tbl      PO_TBL_VARCHAR1,
  effective_date_tbl             PO_TBL_DATE,
  expiration_date_tbl            PO_TBL_DATE,
  attribute14_tbl                PO_TBL_VARCHAR2000,
  price_update_tolerance_tbl     PO_TBL_NUMBER,
  line_loc_populated_flag_tbl    PO_TBL_VARCHAR1,

  --<< PDOI Enhancement Bug#17063664 START>--
  requisition_line_id_tbl        PO_TBL_NUMBER,
  oke_contract_header_id_tbl     PO_TBL_NUMBER,
  oke_contract_version_id_tbl    PO_TBL_NUMBER,
  bid_number_tbl                 PO_TBL_NUMBER,
  bid_line_number_tbl            PO_TBL_NUMBER,
  auction_header_id_tbl          PO_TBL_NUMBER,
  auction_line_number_tbl        PO_TBL_NUMBER,
  auction_display_number_tbl     PO_TBL_VARCHAR100,
  txn_flow_header_id_tbl         PO_TBL_NUMBER,
  transaction_reason_code_tbl    PO_TBL_VARCHAR30,
  note_to_vendor_tbl             PO_TBL_VARCHAR2000,
  supplier_ref_number_tbl        PO_TBL_VARCHAR2000,
  orig_from_req_flag_tbl         PO_TBL_VARCHAR1,
  consigned_flag_tbl             PO_TBL_VARCHAR1,
  need_by_date_tbl               PO_TBL_DATE,
  ship_to_loc_id_tbl             PO_TBL_NUMBER,
  ship_to_org_id_tbl             PO_TBL_NUMBER,
  ship_to_org_code_tbl           PO_TBL_VARCHAR5,
  ship_to_loc_tbl                PO_TBL_VARCHAR100,
  org_id_tbl                     PO_TBL_NUMBER,
  taxable_flag_tbl               PO_TBL_VARCHAR1,
  project_id_tbl                 PO_TBL_NUMBER,
  task_id_tbl                    PO_TBL_NUMBER,
  --<< PDOI Enhancement Bug#17063664 END>--
  -- PDOI for Complex PO Project
  retainage_rate_tbl             PO_TBL_NUMBER,
  max_retainage_amount_tbl       PO_TBL_NUMBER,
  progress_payment_rate_tbl      PO_TBL_NUMBER,
  recoupment_rate_tbl            PO_TBL_NUMBER,
  advance_amount_tbl             PO_TBL_NUMBER,

  negotiated_flag_tbl            PO_TBL_VARCHAR1,
  amount_tbl                     PO_TBL_NUMBER,
  contractor_last_name_tbl       PO_TBL_VARCHAR2000,
  contractor_first_name_tbl      PO_TBL_VARCHAR2000,
  over_tolerance_err_flag_tbl    PO_TBL_VARCHAR30,
  not_to_exceed_price_tbl        PO_TBL_NUMBER,
  po_release_id_tbl              PO_TBL_NUMBER,
  release_num_tbl                PO_TBL_NUMBER,
  source_shipment_id_tbl         PO_TBL_NUMBER,
  contract_num_tbl               PO_TBL_VARCHAR30,
  contract_id_tbl                PO_TBL_NUMBER,
  type_1099_tbl                  PO_TBL_VARCHAR30,
  closed_by_tbl                  PO_TBL_NUMBER,
  closed_date_tbl                PO_TBL_DATE,
  committed_amount_tbl           PO_TBL_NUMBER,
  qty_rcv_exception_code_tbl     PO_TBL_VARCHAR30,
  weight_uom_code_tbl            PO_TBL_VARCHAR5,
  volume_uom_code_tbl            PO_TBL_VARCHAR5,
  secondary_unit_of_meas_tbl     PO_TBL_VARCHAR30,
  secondary_quantity_tbl         PO_TBL_NUMBER,
  preferred_grade_tbl            PO_TBL_VARCHAR2000,
  process_code_tbl               PO_TBL_VARCHAR30,
  parent_interface_line_id_tbl   PO_TBL_NUMBER, -- bug5149827
  file_line_language_tbl         PO_TBL_VARCHAR5, -- bug 5489942

  -- standard who columns
  last_updated_by_tbl            PO_TBL_NUMBER,
  last_update_date_tbl           PO_TBL_DATE,
  last_update_login_tbl          PO_TBL_NUMBER,
  creation_date_tbl              PO_TBL_DATE,
  created_by_tbl                 PO_TBL_NUMBER,
  request_id_tbl                 PO_TBL_NUMBER,
  program_application_id_tbl     PO_TBL_NUMBER,
  program_id_tbl                 PO_TBL_NUMBER,
  program_update_date_tbl        PO_TBL_DATE,

  -- attributes that are in line txn table but not in interface table
  order_type_lookup_code_tbl     PO_TBL_VARCHAR30,
  purchase_basis_tbl             PO_TBL_VARCHAR30,
  matching_basis_tbl             PO_TBL_VARCHAR30,
  unordered_flag_tbl             PO_TBL_VARCHAR1,
  cancel_flag_tbl                PO_TBL_VARCHAR1,
  quantity_committed_tbl         PO_TBL_NUMBER,
  tax_attribute_update_code_tbl  PO_TBL_VARCHAR30,

  -- attributes read from the header interface record
  draft_id_tbl                   PO_TBL_NUMBER,
  hd_action_tbl                  PO_TBL_VARCHAR30,
  hd_po_header_id_tbl            PO_TBL_NUMBER,
  hd_vendor_id_tbl               PO_TBL_NUMBER,
  -- PDOI Enhancement Bug#17063664
  hd_ship_to_loc_id_tbl          PO_TBL_NUMBER,
  hd_vendor_site_id_tbl          PO_TBL_NUMBER,
  hd_min_release_amount_tbl      PO_TBL_NUMBER,
  hd_start_date_tbl              PO_TBL_DATE,
  hd_end_date_tbl                PO_TBL_DATE,
  hd_global_agreement_flag_tbl   PO_TBL_VARCHAR1,
  hd_currency_code_tbl           PO_TBL_VARCHAR30,
  hd_created_language_tbl        PO_TBL_VARCHAR5,
  hd_style_id_tbl                PO_TBL_NUMBER,
  hd_rate_type_tbl               PO_TBL_VARCHAR30,
  hd_rate_tbl                    PO_TBL_NUMBER,    -- bug 9194215
  hd_rate_date_tbl               PO_TBL_DATE,   --<PDOI Enhancement Bug#17063664>

  -- attributes added for location processing
  create_line_loc_tbl            PO_TBL_VARCHAR1,

  -- attributes added for uniqueness checking
  origin_line_num_tbl            PO_TBL_NUMBER,
  group_num_tbl                  PO_TBL_NUMBER,
  match_line_found_tbl           PO_TBL_VARCHAR1,
  line_num_unique_tbl            PO_TBL_VARCHAR1,

  -- attributes added for processing purpose
  error_flag_tbl                 PO_TBL_VARCHAR1,
  need_to_reject_flag_tbl        PO_TBL_VARCHAR1,
  allow_desc_update_flag_tbl     PO_TBL_VARCHAR1,
  rec_count                      NUMBER,
  intf_id_index_tbl              DBMS_SQL.NUMBER_TABLE,
  qty_rcv_tolerance_tbl          PO_TBL_NUMBER -- Bug 18891225

  -- ATTENTION: If you are adding new attributes to this record type, see
  --            the message above first.
);

-- type defined for line location records

-- ATTENTION: Whenever a new attribute is added to this record type, make sure
--            that the procedure fill_all_line_locs_attr is also changed to init
--            the table
TYPE line_locs_rec_type IS RECORD
(
  -- attributes read from line location interface records
  intf_line_loc_id_tbl               PO_TBL_NUMBER,
  intf_line_id_tbl                   PO_TBL_NUMBER,
  intf_header_id_tbl                 PO_TBL_NUMBER,
  shipment_num_tbl                   PO_TBL_NUMBER,
  shipment_type_tbl                  PO_TBL_VARCHAR30,
  line_loc_id_tbl                    PO_TBL_NUMBER,
  ship_to_org_code_tbl               PO_TBL_VARCHAR5,
  ship_to_org_id_tbl                 PO_TBL_NUMBER,
  ship_to_loc_tbl                    PO_TBL_VARCHAR100,
  ship_to_loc_id_tbl                 PO_TBL_NUMBER,
  payment_terms_tbl                  PO_TBL_VARCHAR100,
  terms_id_tbl                       PO_TBL_NUMBER,
  receiving_routing_tbl              PO_TBL_VARCHAR30,
  receiving_routing_id_tbl           PO_TBL_NUMBER,
  inspection_required_flag_tbl       PO_TBL_VARCHAR1,
  receipt_required_flag_tbl          PO_TBL_VARCHAR1,
  price_override_tbl                 PO_TBL_NUMBER,
  -- <<Bug#17998869 Start>>
  lead_time_tbl                      PO_TBL_NUMBER,
  -- <<Bug#17998869 End>>
  qty_rcv_tolerance_tbl              PO_TBL_NUMBER,
  qty_rcv_exception_code_tbl         PO_TBL_VARCHAR30,
  enforce_ship_to_loc_code_tbl       PO_TBL_VARCHAR30,
  allow_sub_receipts_flag_tbl        PO_TBL_VARCHAR1,
  days_early_receipt_allowed_tbl     PO_TBL_NUMBER,
  days_late_receipt_allowed_tbl      PO_TBL_NUMBER,
  receipt_days_except_code_tbl       PO_TBL_VARCHAR30,
  invoice_close_tolerance_tbl        PO_TBL_NUMBER,
  receive_close_tolerance_tbl        PO_TBL_NUMBER,
  accrue_on_receipt_flag_tbl         PO_TBL_VARCHAR1,
  firm_flag_tbl                      PO_TBL_VARCHAR30,
  fob_tbl                            PO_TBL_VARCHAR30,
  freight_carrier_tbl                PO_TBL_VARCHAR30,
  freight_term_tbl                   PO_TBL_VARCHAR30,
  need_by_date_tbl                   PO_TBL_DATE,
  promised_date_tbl                  PO_TBL_DATE,
  quantity_tbl                       PO_TBL_NUMBER,
  amount_tbl                         PO_TBL_NUMBER,  -- PDOI for Complex PO Project
  start_date_tbl                     PO_TBL_DATE,
  end_date_tbl                       PO_TBL_DATE,
  note_to_receiver_tbl               PO_TBL_VARCHAR2000,
  price_discount_tbl                 PO_TBL_NUMBER,
  secondary_unit_of_meas_tbl         PO_TBL_VARCHAR30,
  secondary_quantity_tbl             PO_TBL_NUMBER,
  preferred_grade_tbl                PO_TBL_VARCHAR2000,
  tax_code_id_tbl                    PO_TBL_NUMBER,
  tax_name_tbl                       PO_TBL_VARCHAR30,
  taxable_flag_tbl                   PO_TBL_VARCHAR1,
  unit_of_measure_tbl                PO_TBL_VARCHAR30,
  value_basis_tbl                    PO_TBL_VARCHAR30,
  matching_basis_tbl                 PO_TBL_VARCHAR30,
  payment_type_tbl                   PO_TBL_VARCHAR30,  -- PDOI for Complex PO Project

  -- attributes in txn table but not in interface table
  match_option_tbl                   PO_TBL_VARCHAR30,
  txn_flow_header_id_tbl             PO_TBL_NUMBER,
  outsourced_assembly_tbl            PO_TBL_NUMBER,
  tax_attribute_update_code_tbl      PO_TBL_VARCHAR30,
  -- <<PDOI Enhancement Bug#17063664 START>>--
  action_tbl                         PO_TBL_VARCHAR30,
  -- <<PDOI Enhancement Bug#17063664 END>>--

  -- standard who columns
  last_updated_by_tbl                PO_TBL_NUMBER,
  last_update_date_tbl               PO_TBL_DATE,
  last_update_login_tbl              PO_TBL_NUMBER,
  creation_date_tbl                  PO_TBL_DATE,
  created_by_tbl                     PO_TBL_NUMBER,
  request_id_tbl                     PO_TBL_NUMBER,
  program_application_id_tbl         PO_TBL_NUMBER,
  program_id_tbl                     PO_TBL_NUMBER,
  program_update_date_tbl            PO_TBL_DATE,

  -- attributes read from the line interface record
    --<<PDOI Enhancmennt Bug#17063664>>--
  --Attributes required from requisition from grouping
  ln_req_line_id_tbl                 PO_TBL_NUMBER,
  vmi_flag_tbl                       PO_TBL_VARCHAR1,
  drop_ship_flag_tbl                 PO_TBL_VARCHAR1,
  consigned_flag_tbl                 PO_TBL_VARCHAR1,
  wip_entity_id_tbl                  PO_TBL_NUMBER,
  -- <<PDOI Enhancement Bug#17063664 END>>--
  ln_po_line_id_tbl                  PO_TBL_NUMBER,
  ln_item_id_tbl                     PO_TBL_NUMBER,

--< Shared Proc 14223789 Start >
  ln_item_category_id_tbl             PO_TBL_NUMBER,
--< Shared Proc 14223789 End >

  ln_order_type_lookup_code_tbl      PO_TBL_VARCHAR30,
  ln_action_tbl                      PO_TBL_VARCHAR30,
  ln_unit_price_tbl                  PO_TBL_NUMBER,
  ln_quantity_tbl                    PO_TBL_NUMBER,  -- PDOI for Complex PO Project
  ln_amount_tbl                      PO_TBL_NUMBER,  -- PDOI for Complex PO Project
  ln_line_type_id_tbl                PO_TBL_NUMBER,
  ln_unit_of_measure_tbl             PO_TBL_VARCHAR30,
  ln_closed_code_tbl                 PO_TBL_VARCHAR30,
  ln_purchase_basis_tbl              PO_TBL_VARCHAR30,
  ln_matching_basis_tbl              PO_TBL_VARCHAR30,
  ln_item_revision_tbl               PO_TBL_VARCHAR5,
  ln_expiration_date_tbl             PO_TBL_DATE,
  ln_government_context_tbl          PO_TBL_VARCHAR30,
  ln_closed_reason_tbl               PO_TBL_VARCHAR2000,
  ln_closed_date_tbl                 PO_TBL_DATE,
  ln_closed_by_tbl                   PO_TBL_NUMBER,
  ln_from_header_id_tbl              PO_TBL_NUMBER,
  ln_from_line_id_tbl                PO_TBL_NUMBER,
  ln_price_break_lookup_code_tbl     PO_TBL_VARCHAR30,  -- bug5016163

  -- attributes read from the header interface record
  draft_id_tbl                       PO_TBL_NUMBER,
  hd_po_header_id_tbl                PO_TBL_NUMBER,
  --< Shared Proc 14223789 Start>
  hd_doc_type_tbl                   PO_TBL_VARCHAR30,
  --< Shared Proc 14223789 End>
  hd_ship_to_loc_id_tbl              PO_TBL_NUMBER,
  hd_vendor_id_tbl                   PO_TBL_NUMBER,
  hd_vendor_site_id_tbl              PO_TBL_NUMBER,
  hd_terms_id_tbl                    PO_TBL_NUMBER,
  hd_fob_tbl                         PO_TBL_VARCHAR30,
  hd_freight_carrier_tbl             PO_TBL_VARCHAR30,
  hd_freight_term_tbl                PO_TBL_VARCHAR30,
  hd_approved_flag_tbl               PO_TBL_VARCHAR1,
  hd_effective_date_tbl              PO_TBL_DATE,
  hd_expiration_date_tbl             PO_TBL_DATE,
  hd_style_id_tbl                    PO_TBL_NUMBER,
  hd_currency_code_tbl               PO_TBL_VARCHAR30, -- 9294987 bug
  hd_pcard_id_tbl                    PO_TBL_NUMBER, --<PDOI Enhancement Bug#17063664>
  --<Start Bug#19528138>--
  hd_org_id_tbl                      PO_TBL_NUMBER,
  hd_type_lookup_code_tbl            PO_TBL_VARCHAR30,
  hd_global_agreement_flag_tbl       PO_TBL_VARCHAR1,
  hd_rate_tbl                        PO_TBL_NUMBER,
  hd_rate_type_tbl                   PO_TBL_VARCHAR30,
  hd_rate_date_tbl                   PO_TBL_DATE,
  --<End Bug#19528138>--
  -- attributes added for item processing(read from line)
  --ln_qty_rcv_tolerance_tbl           PO_TBL_NUMBER,
  ln_unit_weight_tbl                 PO_TBL_NUMBER,
  ln_unit_volume_tbl                 PO_TBL_NUMBER,
  ln_item_attribute_category_tbl     PO_TBL_VARCHAR2000,
  ln_item_attribute1_tbl             PO_TBL_VARCHAR2000,
  ln_item_attribute2_tbl             PO_TBL_VARCHAR2000,
  ln_item_attribute3_tbl             PO_TBL_VARCHAR2000,
  ln_item_attribute4_tbl             PO_TBL_VARCHAR2000,
  ln_item_attribute5_tbl             PO_TBL_VARCHAR2000,
  ln_item_attribute6_tbl             PO_TBL_VARCHAR2000,
  ln_item_attribute7_tbl             PO_TBL_VARCHAR2000,
  ln_item_attribute8_tbl             PO_TBL_VARCHAR2000,
  ln_item_attribute9_tbl             PO_TBL_VARCHAR2000,
  ln_item_attribute10_tbl            PO_TBL_VARCHAR2000,
  ln_item_attribute11_tbl            PO_TBL_VARCHAR2000,
  ln_item_attribute12_tbl            PO_TBL_VARCHAR2000,
  ln_item_attribute13_tbl            PO_TBL_VARCHAR2000,
  ln_item_attribute14_tbl            PO_TBL_VARCHAR2000,
  ln_item_attribute15_tbl            PO_TBL_VARCHAR2000,
  ln_item_tbl                        PO_TBL_VARCHAR2000,
  ln_item_desc_tbl                   PO_TBL_VARCHAR2000,
  ln_list_price_per_unit_tbl         PO_TBL_NUMBER,
  ln_market_price_tbl                PO_TBL_NUMBER,
  ln_un_number_id_tbl                PO_TBL_NUMBER,
  ln_hazard_class_id_tbl             PO_TBL_NUMBER,
  ln_qty_rcv_exception_code_tbl      PO_TBL_VARCHAR30,
  ln_weight_uom_code_tbl             PO_TBL_VARCHAR5,
  ln_volume_uom_code_tbl             PO_TBL_VARCHAR5,
  ln_template_id_tbl                 PO_TBL_NUMBER,
  ln_category_id_tbl                 PO_TBL_NUMBER,
  line_ref_index_tbl                 PO_TBL_NUMBER,
  ln_line_loc_pop_flag_tbl           PO_TBL_VARCHAR1,-- Bug 19528138

  -- attributes added for processing purpose
  shipment_num_unique_tbl            PO_TBL_VARCHAR1,
  error_flag_tbl                     PO_TBL_VARCHAR1,
  rec_count                          NUMBER,
  intf_id_index_tbl                  DBMS_SQL.NUMBER_TABLE

  -- ATTENTION: If you are adding new attributes to this record type, see
  --            the message above first.
);

-- type defined for distribution record

-- ATTENTION: Whenever a new attribute is added to this record type, make sure
--            that the procedure fill_all_dists_attr is also changed to init
--            the table
TYPE distributions_rec_type IS RECORD
(
  intf_dist_id_tbl               PO_TBL_NUMBER,
  intf_header_id_tbl             PO_TBL_NUMBER,
  intf_line_id_tbl               PO_TBL_NUMBER,
  intf_line_loc_id_tbl           PO_TBL_NUMBER,
  po_dist_id_tbl                 PO_TBL_NUMBER,
  dist_num_tbl                   PO_TBL_NUMBER,
  deliver_to_loc_tbl             PO_TBL_VARCHAR100,
  deliver_to_loc_id_tbl          PO_TBL_NUMBER,
  deliver_to_person_name_tbl     PO_TBL_VARCHAR2000,
  deliver_to_person_id_tbl       PO_TBL_NUMBER,
  dest_type_tbl                  PO_TBL_VARCHAR30,
  dest_type_code_tbl             PO_TBL_VARCHAR30,
  dest_org_tbl                   PO_TBL_VARCHAR100,
  dest_org_id_tbl                PO_TBL_NUMBER,
  wip_entity_tbl                 PO_TBL_VARCHAR2000,
  wip_entity_id_tbl              PO_TBL_NUMBER,
  wip_line_code_tbl              PO_TBL_VARCHAR30,
  wip_line_id_tbl                PO_TBL_NUMBER,
  bom_resource_code_tbl          PO_TBL_VARCHAR30,
  bom_resource_id_tbl            PO_TBL_NUMBER,
  charge_account_tbl             PO_TBL_VARCHAR2000,
  charge_account_id_tbl          PO_TBL_NUMBER,
  dest_charge_account_id_tbl     PO_TBL_NUMBER,
  project_accounting_context_tbl PO_TBL_VARCHAR30,
  award_num_tbl                  PO_TBL_VARCHAR30,
  award_id_tbl                   PO_TBL_NUMBER,
  project_tbl                    PO_TBL_VARCHAR30,
  project_id_tbl                 PO_TBL_NUMBER,
  task_tbl                       PO_TBL_VARCHAR30,
  task_id_tbl                    PO_TBL_NUMBER,
  expenditure_tbl                PO_TBL_VARCHAR100,
  expenditure_type_tbl           PO_TBL_VARCHAR30,
  expenditure_org_tbl            PO_TBL_VARCHAR100,
  expenditure_org_id_tbl         PO_TBL_NUMBER,
  expenditure_item_date_tbl      PO_TBL_DATE,
  end_item_unit_number_tbl       PO_TBL_VARCHAR30,
  dest_context_tbl               PO_TBL_VARCHAR30,
  gl_encumbered_date_tbl         PO_TBL_DATE,
  gl_encumbered_period_tbl       PO_TBL_VARCHAR30,
  variance_account_id_tbl        PO_TBL_NUMBER,
  accrual_account_id_tbl         PO_TBL_NUMBER,
  budget_account_id_tbl          PO_TBL_NUMBER,
  dest_variance_account_id_tbl   PO_TBL_NUMBER,
  dest_subinventory_tbl          PO_TBL_VARCHAR30,
  amount_ordered_tbl             PO_TBL_NUMBER,
  quantity_ordered_tbl           PO_TBL_NUMBER,
  wip_rep_schedule_id_tbl        PO_TBL_NUMBER,
  wip_operation_seq_num_tbl      PO_TBL_NUMBER,
  wip_resource_seq_num_tbl       PO_TBL_NUMBER,
  prevent_encumbrance_flag_tbl   PO_TBL_VARCHAR1,
  recovery_rate_tbl              PO_TBL_NUMBER,
  tax_recovery_override_flag_tbl PO_TBL_VARCHAR1,
  --PDOI Enhancement Bug#17064664
  req_distribution_id_tbl        PO_TBL_NUMBER,
  account_segment1_tbl           PO_TBL_VARCHAR30,
  account_segment2_tbl           PO_TBL_VARCHAR30,
  account_segment3_tbl           PO_TBL_VARCHAR30,
  account_segment4_tbl           PO_TBL_VARCHAR30,
  account_segment5_tbl           PO_TBL_VARCHAR30,
  account_segment6_tbl           PO_TBL_VARCHAR30,
  account_segment7_tbl           PO_TBL_VARCHAR30,
  account_segment8_tbl           PO_TBL_VARCHAR30,
  account_segment9_tbl           PO_TBL_VARCHAR30,
  account_segment10_tbl          PO_TBL_VARCHAR30,
  account_segment11_tbl          PO_TBL_VARCHAR30,
  account_segment12_tbl          PO_TBL_VARCHAR30,
  account_segment13_tbl          PO_TBL_VARCHAR30,
  account_segment14_tbl          PO_TBL_VARCHAR30,
  account_segment15_tbl          PO_TBL_VARCHAR30,
  account_segment16_tbl          PO_TBL_VARCHAR30,
  account_segment17_tbl          PO_TBL_VARCHAR30,
  account_segment18_tbl          PO_TBL_VARCHAR30,
  account_segment19_tbl          PO_TBL_VARCHAR30,
  account_segment20_tbl          PO_TBL_VARCHAR30,
  account_segment21_tbl          PO_TBL_VARCHAR30,
  account_segment22_tbl          PO_TBL_VARCHAR30,
  account_segment23_tbl          PO_TBL_VARCHAR30,
  account_segment24_tbl          PO_TBL_VARCHAR30,
  account_segment25_tbl          PO_TBL_VARCHAR30,
  account_segment26_tbl          PO_TBL_VARCHAR30,
  account_segment27_tbl          PO_TBL_VARCHAR30,
  account_segment28_tbl          PO_TBL_VARCHAR30,
  account_segment29_tbl          PO_TBL_VARCHAR30,
  account_segment30_tbl          PO_TBL_VARCHAR30,
  dist_attribute1_tbl            PO_TBL_VARCHAR2000,
  dist_attribute2_tbl            PO_TBL_VARCHAR2000,
  dist_attribute3_tbl            PO_TBL_VARCHAR2000,
  dist_attribute4_tbl            PO_TBL_VARCHAR2000,
  dist_attribute5_tbl            PO_TBL_VARCHAR2000,
  dist_attribute6_tbl            PO_TBL_VARCHAR2000,
  dist_attribute7_tbl            PO_TBL_VARCHAR2000,
  dist_attribute8_tbl            PO_TBL_VARCHAR2000,
  dist_attribute9_tbl            PO_TBL_VARCHAR2000,
  dist_attribute10_tbl           PO_TBL_VARCHAR2000,
  dist_attribute11_tbl           PO_TBL_VARCHAR2000,
  dist_attribute12_tbl           PO_TBL_VARCHAR2000,
  dist_attribute13_tbl           PO_TBL_VARCHAR2000,
  dist_attribute14_tbl           PO_TBL_VARCHAR2000,
  dist_attribute15_tbl           PO_TBL_VARCHAR2000,
  -- <<PDOI Enhancement Bug#17063664 Start>>
  oke_contract_line_id_tbl       PO_TBL_NUMBER,
  oke_contract_del_id_tbl        PO_TBL_NUMBER,
  -- <<PDOI Enhancement Bug#17063664 End>>

  -- standard who columns
  last_updated_by_tbl            PO_TBL_NUMBER,
  last_update_date_tbl           PO_TBL_DATE,
  last_update_login_tbl          PO_TBL_NUMBER,
  creation_date_tbl              PO_TBL_DATE,
  created_by_tbl                 PO_TBL_NUMBER,
  request_id_tbl                 PO_TBL_NUMBER,
  program_application_id_tbl     PO_TBL_NUMBER,
  program_id_tbl                 PO_TBL_NUMBER,
  program_update_date_tbl        PO_TBL_DATE,

  -- attributes exist in txn table but not in interface table
  tax_attribute_update_code_tbl  PO_TBL_VARCHAR30,
  award_set_id_tbl               PO_TBL_NUMBER,  -- bug5201306
  kanban_card_id_tbl             PO_TBL_NUMBER, -- Bug 18599449

  -- attributes read from line location record
  loc_ship_to_org_id_tbl         PO_TBL_NUMBER,
  loc_line_loc_id_tbl            PO_TBL_NUMBER,
  loc_shipment_type_tbl          PO_TBL_VARCHAR30,
  loc_txn_flow_header_id_tbl     PO_TBL_NUMBER,
  loc_accrue_on_receipt_flag_tbl PO_TBL_VARCHAR1,
  loc_need_by_date_tbl           PO_TBL_DATE,
  loc_promised_date_tbl          PO_TBL_DATE,
  loc_price_override_tbl         PO_TBL_NUMBER,
  loc_outsourced_assembly_tbl    PO_TBL_NUMBER,
  loc_attribute1_tbl             PO_TBL_VARCHAR2000,
  loc_attribute2_tbl             PO_TBL_VARCHAR2000,
  loc_attribute3_tbl             PO_TBL_VARCHAR2000,
  loc_attribute4_tbl             PO_TBL_VARCHAR2000,
  loc_attribute5_tbl             PO_TBL_VARCHAR2000,
  loc_attribute6_tbl             PO_TBL_VARCHAR2000,
  loc_attribute7_tbl             PO_TBL_VARCHAR2000,
  loc_attribute8_tbl             PO_TBL_VARCHAR2000,
  loc_attribute9_tbl             PO_TBL_VARCHAR2000,
  loc_attribute10_tbl            PO_TBL_VARCHAR2000,
  loc_attribute11_tbl            PO_TBL_VARCHAR2000,
  loc_attribute12_tbl            PO_TBL_VARCHAR2000,
  loc_attribute13_tbl            PO_TBL_VARCHAR2000,
  loc_attribute14_tbl            PO_TBL_VARCHAR2000,
  loc_attribute15_tbl            PO_TBL_VARCHAR2000,
  loc_payment_type_tbl           PO_TBL_VARCHAR30, --Bug#19379838

  -- attributes read from line record
  ln_order_type_lookup_code_tbl  PO_TBL_VARCHAR30,
  -- Bug#17998869
  ln_oke_contract_header_id_tbl  PO_TBL_NUMBER,
  ln_purchase_basis_tbl          PO_TBL_VARCHAR30,
  ln_item_id_tbl                 PO_TBL_NUMBER,
  ln_category_id_tbl             PO_TBL_NUMBER,
  ln_line_type_id_tbl            PO_TBL_NUMBER,
  ln_po_line_id_tbl              PO_TBL_NUMBER,
  ln_attribute1_tbl              PO_TBL_VARCHAR2000,
  ln_attribute2_tbl              PO_TBL_VARCHAR2000,
  ln_attribute3_tbl              PO_TBL_VARCHAR2000,
  ln_attribute4_tbl              PO_TBL_VARCHAR2000,
  ln_attribute5_tbl              PO_TBL_VARCHAR2000,
  ln_attribute6_tbl              PO_TBL_VARCHAR2000,
  ln_attribute7_tbl              PO_TBL_VARCHAR2000,
  ln_attribute8_tbl              PO_TBL_VARCHAR2000,
  ln_attribute9_tbl              PO_TBL_VARCHAR2000,
  ln_attribute10_tbl             PO_TBL_VARCHAR2000,
  ln_attribute11_tbl             PO_TBL_VARCHAR2000,
  ln_attribute12_tbl             PO_TBL_VARCHAR2000,
  ln_attribute13_tbl             PO_TBL_VARCHAR2000,
  ln_attribute14_tbl             PO_TBL_VARCHAR2000,
  ln_attribute15_tbl             PO_TBL_VARCHAR2000,
  -- <<PDOI Enhancement Bug#17063664 Start>>
  ln_requisition_line_id_tbl     PO_TBL_NUMBER,
  loc_consigned_flag_tbl          PO_TBL_VARCHAR1,
  -- <<PDOI Enhancement Bug#17063664 End>>

  -- attributes read from header record
  draft_id_tbl                   PO_TBL_NUMBER,
  hd_agent_id_tbl                PO_TBL_NUMBER,
  hd_po_header_id_tbl            PO_TBL_NUMBER,
  -- <<PDOI Enhancement Bug#17063664>>
  hd_currency_code_tbl           PO_TBL_VARCHAR30,
  hd_rate_type_tbl               PO_TBL_VARCHAR30,
  hd_rate_date_tbl               PO_TBL_DATE,
  hd_rate_tbl                    PO_TBL_NUMBER,
  hd_type_lookup_code_tbl        PO_TBL_VARCHAR30,
  hd_vendor_id_tbl               PO_TBL_NUMBER,
  -- << Bug #17319986 Start >>
  hd_vendor_site_id_tbl          PO_TBL_NUMBER,
  -- << Bug #17319986 End >>
  hd_attribute1_tbl              PO_TBL_VARCHAR2000,
  hd_attribute2_tbl              PO_TBL_VARCHAR2000,
  hd_attribute3_tbl              PO_TBL_VARCHAR2000,
  hd_attribute4_tbl              PO_TBL_VARCHAR2000,
  hd_attribute5_tbl              PO_TBL_VARCHAR2000,
  hd_attribute6_tbl              PO_TBL_VARCHAR2000,
  hd_attribute7_tbl              PO_TBL_VARCHAR2000,
  hd_attribute8_tbl              PO_TBL_VARCHAR2000,
  hd_attribute9_tbl              PO_TBL_VARCHAR2000,
  hd_attribute10_tbl             PO_TBL_VARCHAR2000,
  hd_attribute11_tbl             PO_TBL_VARCHAR2000,
  hd_attribute12_tbl             PO_TBL_VARCHAR2000,
  hd_attribute13_tbl             PO_TBL_VARCHAR2000,
  hd_attribute14_tbl             PO_TBL_VARCHAR2000,
  hd_attribute15_tbl             PO_TBL_VARCHAR2000,

  -- attributes added for processing
  ship_to_ou_id_tbl              PO_TBL_NUMBER,
  ship_to_ou_coa_id_tbl          PO_TBL_NUMBER,
  item_status_tbl                PO_TBL_VARCHAR1,
  gms_txn_required_flag_tbl      PO_TBL_VARCHAR1,
  dist_num_unique_tbl            PO_TBL_VARCHAR1,
  error_flag_tbl                 PO_TBL_VARCHAR1,
  rec_count                      NUMBER,

  -- <Bug 14610858> Added GDF attributes
  global_attribute_category_tbl  PO_TBL_VARCHAR150,
  global_attribute1_tbl          PO_TBL_VARCHAR150,
  global_attribute2_tbl          PO_TBL_VARCHAR150,
  global_attribute3_tbl          PO_TBL_VARCHAR150,
  global_attribute4_tbl          PO_TBL_VARCHAR150,
  global_attribute5_tbl          PO_TBL_VARCHAR150,
  global_attribute6_tbl          PO_TBL_VARCHAR150,
  global_attribute7_tbl          PO_TBL_VARCHAR150,
  global_attribute8_tbl          PO_TBL_VARCHAR150,
  global_attribute9_tbl          PO_TBL_VARCHAR150,
  global_attribute10_tbl          PO_TBL_VARCHAR150,
  global_attribute11_tbl          PO_TBL_VARCHAR150,
  global_attribute12_tbl          PO_TBL_VARCHAR150,
  global_attribute13_tbl          PO_TBL_VARCHAR150,
  global_attribute14_tbl          PO_TBL_VARCHAR150,
  global_attribute15_tbl          PO_TBL_VARCHAR150,
  global_attribute16_tbl          PO_TBL_VARCHAR150,
  global_attribute17_tbl          PO_TBL_VARCHAR150,
  global_attribute18_tbl          PO_TBL_VARCHAR150,
  global_attribute19_tbl          PO_TBL_VARCHAR150,
  global_attribute20_tbl          PO_TBL_VARCHAR150,

  interface_distribution_ref_tbl  PO_TBL_VARCHAR2000 -- Bug 18891225

  -- ATTENTION: If you are adding new attributes to this record type, see
  --            the message above first.
);

-- ATTENTION: Whenever a new attribute is added to this record type, make sure
--            that the procedure fill_all_price_diffs_attr is also changed to
--            init the table
TYPE price_diffs_rec_type IS RECORD
(
  intf_price_diff_id_tbl        PO_TBL_NUMBER,
  intf_line_id_tbl              PO_TBL_NUMBER,  -- bug 5215781
  intf_header_id_tbl            PO_TBL_NUMBER,  -- bug 5215781
  price_diff_num_tbl            PO_TBL_NUMBER,
  price_type_tbl                PO_TBL_VARCHAR30,
  entity_type_tbl               PO_TBL_VARCHAR30,
  entity_id_tbl                 PO_TBL_NUMBER,
  multiplier_tbl                PO_TBL_NUMBER,
  min_multiplier_tbl            PO_TBL_NUMBER,
  max_multiplier_tbl            PO_TBL_NUMBER,

  -- attribute read from line location
  loc_line_loc_id_tbl           PO_TBL_NUMBER,

  -- attributes read from line record
  ln_po_line_id_tbl             PO_TBL_NUMBER,

  -- attributes read from header record
  draft_id_tbl                  PO_TBL_NUMBER,
  hd_style_id_tbl               PO_TBL_NUMBER,

  -- attributes added for processing
  error_flag_tbl                PO_TBL_VARCHAR1,
  price_diff_num_unique_tbl     PO_TBL_VARCHAR1,
  rec_count                     NUMBER

  -- ATTENTION: If you are adding new attributes to this record type, see
  --            the message above first.
);

-- ATTENTION: Whenever a new attribute is added to this record type, make sure
--            that the procedure fill_all_attr_values_attr is also changed to
--            init the table
TYPE attr_values_rec_type IS RECORD
(
  -- attribute from attr_values table
  intf_attr_values_id_tbl        PO_TBL_NUMBER,
  org_id_tbl                     PO_TBL_NUMBER,
  -- Bug#17998869
  lead_time_tbl                  PO_TBL_NUMBER,

  -- attributes from line record
  ln_po_line_id_tbl              PO_TBL_NUMBER,
  ln_ip_category_id_tbl          PO_TBL_NUMBER,
  ln_item_id_tbl                 PO_TBL_NUMBER,

  -- attribute from header record
  draft_id_tbl                   PO_TBL_NUMBER,

  -- attributes added for processing purpose
  attribute_values_id_tbl        PO_TBL_NUMBER,
  source_tbl                     DBMS_SQL.VARCHAR2_TABLE,
  error_flag_tbl                 PO_TBL_VARCHAR1,

  rec_count                      NUMBER

  -- ATTENTION: If you are adding new attributes to this record type, see
  --            the message above first.
);

-- ATTENTION: Whenever a new attribute is added to this record type, make sure
--            that the procedure fill_all_attr_values_tlp_attr is also changed
--            to init the table
TYPE attr_values_tlp_rec_type IS RECORD
(
  -- attribute from attr_values table
  intf_attr_values_tlp_id_tbl    PO_TBL_NUMBER,
  language_tbl                   PO_TBL_VARCHAR5,
  org_id_tbl                     PO_TBL_NUMBER,

  -- attribute from line
  ln_po_line_id_tbl              PO_TBL_NUMBER,
  ln_ip_category_id_tbl          PO_TBL_NUMBER,
  ln_item_id_tbl                 PO_TBL_NUMBER,
  ln_item_desc_tbl               PO_TBL_VARCHAR2000,
  ln_item_long_desc_tbl          PO_TBL_VARCHAR2000,       -- Bug7722053

  -- attribute from headers
  draft_id_tbl                   PO_TBL_NUMBER,

  -- attributes added for processing purpose
  error_flag_tbl                 PO_TBL_VARCHAR1,
  attribute_values_tlp_id_tbl    PO_TBL_NUMBER,
  source_tbl                     DBMS_SQL.VARCHAR2_TABLE,

  rec_count                      NUMBER

  -- ATTENTION: If you are adding new attributes to this record type, see
  --            the message above first.
);

-- type defined for cursor variable
TYPE intf_cursor_type IS REF CURSOR;
TYPE varchar_index_tbl_type IS TABLE OF NUMBER INDEX BY VARCHAR2(30);


--<PDOI Enhancement Bug#17063664>
--
TYPE REQ_LINE_ID_TBL IS TABLE OF PO_TBL_NUMBER;
-- Record type - passed as parameter to PO_PRICE_HELPER.
TYPE pricing_attributes_rec_type IS RECORD
  (
    draft_id_tbl                  PO_TBL_NUMBER,
    po_header_id_tbl              PO_TBL_NUMBER,
    po_vendor_id_tbl              PO_TBL_NUMBER,
    po_vendor_site_id_tbl         PO_TBL_NUMBER,
    org_id_tbl                    PO_TBL_NUMBER,
    order_type_tbl                PO_TBL_VARCHAR30,
    doc_sub_type_tbl              PO_TBL_VARCHAR30,
    enhanced_pricing_flag_tbl     PO_TBL_VARCHAR1,
    progress_payment_flag_tbl     PO_TBL_VARCHAR1,
    rate_tbl                      PO_TBL_NUMBER,
    rate_type_tbl                 PO_TBL_VARCHAR30,
    rate_date_tbl                 PO_TBL_DATE,

    po_line_id_tbl                PO_TBL_NUMBER,
    source_document_type_tbl      PO_TBL_VARCHAR30,
    source_doc_hdr_id_tbl         PO_TBL_NUMBER,
    source_doc_line_id_tbl        PO_TBL_NUMBER,
    allow_price_override_flag_tbl PO_TBL_VARCHAR1,
    currency_code_tbl             PO_TBL_VARCHAR30,
    quantity_tbl                  PO_TBL_NUMBER,
    base_unit_price_tbl           PO_TBL_NUMBER,
    unit_price_tbl                PO_TBL_NUMBER,
    price_break_lookup_code_tbl   PO_TBL_VARCHAR30,
    creation_date_tbl             PO_TBL_DATE,
    item_id_tbl                   PO_TBL_NUMBER,
    item_revision_tbl             PO_TBL_VARCHAR30,
    category_id_tbl               PO_TBL_NUMBER,
    supplier_item_num_tbl         PO_TBL_VARCHAR30,
    uom_tbl                       PO_TBL_VARCHAR30,
    order_type_lookup_tbl         PO_TBL_VARCHAR30,

    amount_changed_flag_tbl       PO_TBL_VARCHAR1,
    existing_line_flag_tbl        PO_TBL_VARCHAR1,
    price_break_id_tbl            PO_TBL_NUMBER,
    need_by_date_tbl              PO_TBL_DATE,
    pricing_date_tbl              PO_TBL_DATE,
    ship_to_loc_tbl               PO_TBL_NUMBER,
    ship_to_org_tbl               PO_TBL_NUMBER,
    line_loc_id_tbl               PO_TBL_NUMBER,

    processed_flag_tbl            PO_TBL_VARCHAR1,

    req_line_ids                  REQ_LINE_ID_TBL,
    min_req_line_price_tbl        PO_TBL_NUMBER,
    req_contractor_status         PO_TBL_VARCHAR30,

    pricing_src_tbl               PO_TBL_VARCHAR30,
    return_status_tbl             PO_TBL_VARCHAR30,
    return_mssg_tbl               PO_TBL_VARCHAR30,
    rec_count NUMBER
  );

-- PROCEDURES that initialize the pl/sql tables within the record, allocating
-- memory for the tables indicated by the parameter that specifies
-- the number of records the structure will hold

-- bug5106386 START
PROCEDURE fill_all_headers_attr
( p_num_records IN NUMBER,
  x_headers     IN OUT NOCOPY headers_rec_type
);

PROCEDURE fill_all_lines_attr
( p_num_records IN NUMBER,
  x_lines     IN OUT NOCOPY lines_rec_type
);

PROCEDURE fill_all_line_locs_attr
( p_num_records IN NUMBER,
  x_line_locs   IN OUT NOCOPY line_locs_rec_type
);

PROCEDURE fill_all_dists_attr
( p_num_records IN NUMBER,
  x_dists       IN OUT NOCOPY distributions_rec_type
);

PROCEDURE fill_all_price_diffs_attr
( p_num_records IN NUMBER,
  x_price_diffs IN OUT NOCOPY price_diffs_rec_type
);

PROCEDURE fill_all_attr_values_attr
( p_num_records IN NUMBER,
  x_attr_values IN OUT NOCOPY attr_values_rec_type
);

PROCEDURE fill_all_attr_values_tlp_attr
( p_num_records IN NUMBER,
  x_attr_values_tlp IN OUT NOCOPY attr_values_tlp_rec_type
);

-- bug5106386 END

--<PDOI Enhancement Bug#17063664>
PROCEDURE fill_all_pricing_attr
( p_num_records IN NUMBER,
  x_pricing_rec IN OUT NOCOPY pricing_attributes_rec_type
);


END PO_PDOI_TYPES;

/
