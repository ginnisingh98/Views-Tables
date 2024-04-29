--------------------------------------------------------
--  DDL for Package PO_PDOI_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_PARAMS" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_PARAMS.pls 120.8.12010000.5 2013/10/25 12:13:09 inagdeo ship $ */


-- Record type to store request parameters
TYPE request_param_rec_type IS RECORD
( calling_module             VARCHAR2(30),
  validation_level           NUMBER,
  commit_work                VARCHAR2(1),
  batch_id                   NUMBER,
  batch_size                 NUMBER,
  buyer_id                   NUMBER,
  document_type              VARCHAR2(25),
  document_subtype           VARCHAR2(25),
  create_items               VARCHAR2(1),
  create_sourcing_rules_flag VARCHAR2(1),
  rel_gen_method             VARCHAR2(25),
  sourcing_level             VARCHAR2(25),
  sourcing_inv_org_id        NUMBER,
  approved_status            VARCHAR2(25),
  process_code               VARCHAR2(25),
  interface_header_id        NUMBER,
  org_id                     NUMBER,
  ga_flag                    VARCHAR2(1),
  submit_dft_flag            VARCHAR2(1),
  role                       VARCHAR2(10),
  catalog_to_expire          VARCHAR2(255),
  err_lines_tolerance        NUMBER,
    --PDOI Enhancement Bug#17063664
  group_lines            VARCHAR2(1),
  group_shipments            VARCHAR2(1)
);

-- Record type to store system parameters
TYPE sys_param_rec_type IS RECORD
( currency_code         GL_SETS_OF_BOOKS.currency_code%TYPE,
  coa_id                GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE,
  po_encumbrance_flag   FINANCIALS_SYSTEM_PARAMETERS.purch_encumbrance_flag%TYPE,
  req_encumbrance_flag  FINANCIALS_SYSTEM_PARAMETERS.req_encumbrance_flag%TYPE,
  sob_id                FINANCIALS_SYSTEM_PARAMETERS.set_of_books_id%TYPE,
  ship_to_location_id   FINANCIALS_SYSTEM_PARAMETERS.ship_to_location_id%TYPE,
  bill_to_location_id   FINANCIALS_SYSTEM_PARAMETERS.bill_to_location_id%TYPE,
  fob_lookup_code       FINANCIALS_SYSTEM_PARAMETERS.fob_lookup_code%TYPE,
  freight_terms_lookup_code FINANCIALS_SYSTEM_PARAMETERS.freight_terms_lookup_code%TYPE,
  terms_id              FINANCIALS_SYSTEM_PARAMETERS.terms_id%TYPE,
  default_rate_type     PO_SYSTEM_PARAMETERS.default_rate_type%TYPE,
  taxable_flag          PO_SYSTEM_PARAMETERS.taxable_flag%TYPE,
  receiving_flag        PO_SYSTEM_PARAMETERS.receiving_flag%TYPE,
  line_type_id          PO_SYSTEM_PARAMETERS.line_type_id%TYPE,
  manual_po_num_type    PO_SYSTEM_PARAMETERS.manual_po_num_type%TYPE,
  user_defined_po_num_code PO_SYSTEM_PARAMETERS.user_defined_po_num_code%TYPE,
  price_type_lookup_code PO_SYSTEM_PARAMETERS.price_type_lookup_code%TYPE,
  def_inv_org_id        FINANCIALS_SYSTEM_PARAMETERS.inventory_organization_id%TYPE,
  min_rel_amount        PO_SYSTEM_PARAMETERS.min_release_amount%TYPE,
  def_quote_warning_delay PO_SYSTEM_PARAMETERS.default_quote_warning_delay%TYPE,
  inspection_required_flag PO_SYSTEM_PARAMETERS.inspection_required_flag%TYPE,
  user_defined_quote_num_code PO_SYSTEM_PARAMETERS.user_defined_quote_num_code%TYPE,
  manual_quote_num_type PO_SYSTEM_PARAMETERS.manual_quote_num_type%TYPE,
  ship_via_lookup_code  FINANCIALS_SYSTEM_PARAMETERS.ship_via_lookup_code%TYPE,
  qty_rcv_tolerance     RCV_PARAMETERS.qty_rcv_tolerance%TYPE,
  price_break_lookup_code PO_SYSTEM_PARAMETERS.price_break_lookup_code%TYPE,
  invoice_close_tolerance PO_SYSTEM_PARAMETERS.invoice_close_tolerance%TYPE,
  receive_close_tolerance PO_SYSTEM_PARAMETERS.receive_close_tolerance%TYPE,
  expense_accrual_code  PO_SYSTEM_PARAMETERS.expense_accrual_code%TYPE,
  master_inv_org_id     MTL_PARAMETERS.organization_id%TYPE,
  enforce_ship_to_loc   RCV_PARAMETERS.enforce_ship_to_location_code%TYPE,
  allow_substitutes     RCV_PARAMETERS.allow_substitute_receipts_flag%TYPE,
  routing_id            RCV_PARAMETERS.receiving_routing_id%TYPE,
  qty_rcv_exception     RCV_PARAMETERS.qty_rcv_exception_code%TYPE,
  days_early_receipt    RCV_PARAMETERS.days_early_receipt_allowed%TYPE,
  days_late_receipt     RCV_PARAMETERS.days_late_receipt_allowed%TYPE,
  rcv_days_exception    RCV_PARAMETERS.receipt_days_exception_code%TYPE,
  supplier_auth_acc     PO_SYSTEM_PARAMETERS.supplier_authoring_acceptance%TYPE,
  cat_admin_auth_acc    PO_SYSTEM_PARAMETERS.cat_admin_authoring_acceptance%TYPE,
  invoice_match_option  FINANCIALS_SYSTEM_PARAMETERS.match_option%TYPE,
  when_to_archive_blanket PO_DOCUMENT_TYPES.archive_external_revision_code%TYPE,
  when_to_archive_std_po PO_DOCUMENT_TYPES.archive_external_revision_code%TYPE,
  def_business_group_id  FINANCIALS_SYSTEM_PARAMETERS.business_group_id%TYPE,
  def_structure_id       MTL_CATEGORY_SETS.structure_id%TYPE,
  def_cat_set_id         MTL_CATEGORY_SETS.category_set_id%TYPE,
  def_category_id        MTL_CATEGORY_SETS.default_category_id%TYPE,
  is_federal_instance   VARCHAR2(1),
  acceptance_required_flag PO_SYSTEM_PARAMETERS.acceptance_required_flag%TYPE,   /* Bug 7518967 : Default Acceptance Required Check ER */
  --PDOI Enhancement bug#17063664
  group_shipments_flag     PO_SYSTEM_PARAMETERS.group_shipments_flag%TYPE
);

-- Record type to store profile options
TYPE profile_param_rec_type IS RECORD
( pdoi_write_to_file        VARCHAR2(2000),
  service_uom_class         VARCHAR2(2000),
  pdoi_archive_on_approval  VARCHAR2(2000),
  override_funds            VARCHAR2(2000),
  xbg                       VARCHAR2(2000),
  po_price_update_tolerance VARCHAR2(2000),
  allow_tax_rate_override   VARCHAR2(2000),
  allow_tax_code_override   VARCHAR2(2000),
--<PDOI Enhancement Bug#17063664 START>--
  group_by_need_by_date     VARCHAR2(2000),
  group_by_ship_to_location VARCHAR2(2000),
  default_promised_date     VARCHAR2(2000),
  auto_create_date_option   VARCHAR2(2000),
  use_req_num_in_autocreate VARCHAR2(2000),
  pa_default_exp_org_id     NUMBER
--<PDOI Enhancement Bug#17063664 END>--
);

TYPE product_param_rec_type IS RECORD
( wip_installed           VARCHAR2(1),
  inv_installed           VARCHAR2(1),
  project_11510_installed VARCHAR2(1),
  pa_installed            VARCHAR2(1),
  --<PDOI Enhancement Bug#17063664>
  pjm_installed           VARCHAR2(1),
  gms_enabled             VARCHAR2(1),
  project_cwk_installed   VARCHAR2(1)
);

-- Record type to store out paramters
TYPE out_param_rec_type IS RECORD
( processed_lines_count NUMBER,
  rejected_lines_count NUMBER,
  err_tolerance_exceeded VARCHAR2(1)
);

-- Record type to store additional document information
TYPE doc_info_rec_type IS RECORD
( number_of_processed_lines NUMBER,
  number_of_errored_lines NUMBER,
  -- number_of_valid_lines will only be maintained on line level, as long as the line itself is valid,
  -- we increment the value by 1. Price break and price diff level errors will not affect this value.
  number_of_valid_lines NUMBER,
  err_tolerance_exceeded VARCHAR2(1),
  has_errors VARCHAR2(1),
  has_lines_to_notify VARCHAR2(1),
  has_lines_updated VARCHAR2(1),
  new_draft VARCHAR2(1) -- bug5129752 - Indicates whether the draft is created by this request
);

TYPE doc_info_tbl_type IS TABLE OF doc_info_rec_type INDEX BY BINARY_INTEGER;

-- instances of the record structures defined above
g_request request_param_rec_type;
g_sys     sys_param_rec_type;
g_profile profile_param_rec_type;
g_product product_param_rec_type;
g_out     out_param_rec_type;

-- Associative array to store extra information for a document. The information
-- will be populated through PDOI processing and are used to drive logic,
-- especially during post processing. Each record is associated to a record
-- in po_headers_interface by interface_header_id.
g_docs_info doc_info_tbl_type;

-- bug4662687 START

TYPE errored_lines_tbl_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

-- This associative arry tracks the lines that have errors at price break level.
-- In catalog upload scenario, if user tries to upload a price break and it
-- has error, the error does not cause the line to be rejected; however, we
-- still need to report the error as line error. So we need to track the
-- lines that have errors and add the numbers to the number of errored lines
-- at the header level
g_errored_lines errored_lines_tbl_type;

-- bug4662687 END



-- parameters that do not belong to any structure.

-- Usage of Processing ID:
-- This id is used to identify the records in the interface table that will
-- be processed in this current PDOI run. Each PDOI run has its own processing
-- id, and this id is stamped to the records in interface table at all levels,
-- if the record is expected to be processed sometime during the current PDOI
-- run.
-- In case the record gets rejected, processing_id on the interface record
-- will be negated so that it won't be processed further down.
g_processing_id NUMBER;

-- Usage of Original Doc Processed Flag:
-- This flag is to indicate whether there are new documents to be imported as
-- new documents (identified by action = 'ORIGINAL' in headers interface).
-- During header grouping we are separating records with action
-- 'ORIGINAL' from records with some other actions, and we first process all
-- records with action = 'ORIGINAL'. Once all the records with action
-- 'ORIGINAL' are processed, this flag will be set to FND_API.G_TRUE to
-- indicate that PDOI can process records with other actions in the coming
-- round
g_original_doc_processed VARCHAR2(1);


-- Usage of current round num:
-- Current Round Num indicates how many iterations this current PDOI run has
-- gone through to process records. We separate header records to be processed
-- in multiple rounds, mainly to resolve conflicts between them. For records
-- that can be processed in the current round, they will be stamped to have
-- processing_round_num = current_round_num, meaning that they will be processed
-- in the current round. At each round this number will be incremented by 1,
-- and unprocessed records will be re-evaluated and see if they can be included
-- in the new round.
g_current_round_num NUMBER;

-- Usage of g_sourcing_error_code  :
-- This is required to be tracked as part of sourcing flow where error number
-- is tracked in case the document creation method has failed .
-- error_code is '2' denotes duplicate document being created.
g_sourcing_error_code  NUMBER;

-- <PDOI Enhancement Bug#17063664 END>--


END PO_PDOI_PARAMS;

/
