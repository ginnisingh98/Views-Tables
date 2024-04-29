--------------------------------------------------------
--  DDL for Package Body PO_PDOI_HEADER_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_HEADER_PROCESS_PVT" AS
/* $Header: PO_PDOI_HEADER_PROCESS_PVT.plb 120.30.12010000.12 2014/11/13 08:05:47 shikapoo ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_HEADER_PROCESS_PVT');


--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------
PROCEDURE derive_rate_type_code
(
  p_key                IN po_session_gt.key%TYPE,
  p_index_tbl          IN DBMS_SQL.NUMBER_TABLE,
  p_rate_type_tbl      IN PO_TBL_VARCHAR30,
  x_rate_type_code_tbl IN OUT NOCOPY PO_TBL_VARCHAR30
);

PROCEDURE derive_agent_id
(
  p_key                IN po_session_gt.key%TYPE,
  p_index_tbl          IN DBMS_SQL.NUMBER_TABLE,
  p_agent_name_tbl     IN PO_TBL_VARCHAR2000,
  x_agent_id_tbl       IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_vendor_site_id
(
  p_key                   IN po_session_gt.key%TYPE,
  p_index_tbl             IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_id_tbl         IN PO_TBL_NUMBER,
  p_vendor_site_code_tbl  IN PO_TBL_VARCHAR30,
  x_vendor_site_id_tbl    IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_vendor_contact_id
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_site_id_tbl     IN PO_TBL_NUMBER,
  p_vendor_contact_tbl     IN PO_TBL_VARCHAR2000,
  x_vendor_contact_id_tbl  IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_from_header_id
(
  p_key                IN po_session_gt.key%TYPE,
  p_index_tbl          IN DBMS_SQL.NUMBER_TABLE,
  p_from_rfq_num_tbl   IN PO_TBL_VARCHAR30,
  x_from_header_id_tbl IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_style_id
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_style_display_name_tbl IN PO_TBL_VARCHAR2000,
  x_style_id_tbl           IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE default_info_from_vendor
(
  p_key                       IN po_session_gt.key%TYPE,
  p_index_tbl                 IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_id_tbl             IN PO_TBL_NUMBER,
  x_invoice_currency_code_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_terms_id_tbl              OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE default_info_from_vendor_site
(
  p_key                       IN po_session_gt.key%TYPE,
  p_index_tbl                 IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_id_tbl             IN PO_TBL_NUMBER,
  x_vendor_site_id_tbl        IN OUT NOCOPY PO_TBL_NUMBER,
  x_fob_tbl                   OUT NOCOPY PO_TBL_VARCHAR30,
  x_freight_carrier_tbl       OUT NOCOPY PO_TBL_VARCHAR30,
  x_freight_term_tbl          OUT NOCOPY PO_TBL_VARCHAR30,
  x_ship_to_loc_id_tbl        OUT NOCOPY PO_TBL_NUMBER,
  x_bill_to_loc_id_tbl        OUT NOCOPY PO_TBL_NUMBER,
  x_invoice_currency_code_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_terms_id_tbl              OUT NOCOPY PO_TBL_NUMBER,
  x_shipping_control_tbl      OUT NOCOPY PO_TBL_VARCHAR30,
  x_pay_on_code_tbl           OUT NOCOPY PO_TBL_VARCHAR30
);

PROCEDURE default_vendor_contact
(
  p_key                       IN po_session_gt.key%TYPE,
  p_index_tbl                 IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_site_id_tbl        IN PO_TBL_NUMBER,
  x_vendor_contact_id_tbl     IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE default_dist_attributes
(
  x_headers IN OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
);

PROCEDURE populate_error_flag
(
  x_results       IN     po_validation_results_type,
  x_headers       IN OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
);

--bug17940049
--Procedure to default AME_TRANSACTION_TYPE and AME_APPROVAL_ID
PROCEDURE default_ame_attributes
(
  x_style_id              IN NUMBER,
  x_ame_approval_id       OUT NOCOPY NUMBER,
  x_ame_transaction_type  OUT NOCOPY VARCHAR2
);
--------------------------------------------------------------------------
---------------------- PUBLIC PROCEDURES ---------------------------------
--------------------------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: open_headers
--Function:
--  Open cursor for query.
--  This query retrieves the header attributes for processing
--Parameters:
--IN:
--  p_max_intf_header_id
--    maximal interface_header_id processed so far
--    The query will only retrieve the header records which have
--    not been processed
--IN:
--  p_max_intf_header_id
--    maximal interface_header_id processed in previous batches
--IN OUT:
--  x_headers_csr
--    cursor variable to hold pointer to current processing row in the result
--    set returned by the query
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE open_headers
(
  p_max_intf_header_id   IN NUMBER,
  x_headers_csr          OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
) IS
  d_api_name CONSTANT VARCHAR2(30) := 'open_headers';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_max_intf_header_id', p_max_intf_header_id);
  END IF;

  OPEN x_headers_csr FOR
  SELECT interface_header_id,
         draft_id,
         po_header_id,
         action,
         document_num,
         document_type_code,
         document_subtype,
         rate_type,
         rate_type_code,
         rate_date,
         rate,
         agent_id,
         agent_name,
         ship_to_location_id,
         ship_to_location,
         bill_to_location_id,
         bill_to_location,
         payment_terms,
         terms_id,
         vendor_name,
         vendor_num,
         vendor_id,
         vendor_site_code,
         vendor_site_id,
         vendor_contact,
         vendor_contact_id,
         from_rfq_num,
         from_header_id,
         fob,
         freight_carrier,
         freight_terms,
         pay_on_code,
         shipping_control,
         currency_code,
         quote_warning_delay,
         approval_required_flag,
         reply_date,
         approval_status,
         approved_date,
         from_type_lookup_code,
         revision_num,
         confirming_order_flag,
         acceptance_required_flag,
         min_release_amount,
         closed_code,
         print_count,
         frozen_flag,
         encumbrance_required_flag,
         vendor_doc_num,
         org_id,
         acceptance_due_date,
         amount_to_encumber,
         effective_date,
         expiration_date,
         po_release_id,
         release_num,
         release_date,
         revised_date,
         printed_date,
         closed_date,
         amount_agreed,
         nvl(amount_limit,amount_agreed), -- bug5352625 bug19697519
         firm_flag,
         gl_encumbered_date,
         gl_encumbered_period_name,
         budget_account_id,
         budget_account,
         budget_account_segment1,
         budget_account_segment2,
         budget_account_segment3,
         budget_account_segment4,
         budget_account_segment5,
         budget_account_segment6,
         budget_account_segment7,
         budget_account_segment8,
         budget_account_segment9,
         budget_account_segment10,
         budget_account_segment11,
         budget_account_segment12,
         budget_account_segment13,
         budget_account_segment14,
         budget_account_segment15,
         budget_account_segment16,
         budget_account_segment17,
         budget_account_segment18,
         budget_account_segment19,
         budget_account_segment20,
         budget_account_segment21,
         budget_account_segment22,
         budget_account_segment23,
         budget_account_segment24,
         budget_account_segment25,
         budget_account_segment26,
         budget_account_segment27,
         budget_account_segment28,
         budget_account_segment29,
         budget_account_segment30,
         created_language,
         style_id,
         style_display_name,
         global_agreement_flag,
         -- <PDOI Enhancement Bug#17063664 Start>
         consume_req_demand_flag,
         pcard_id,
         -- <PDOI Enhancement Bug#17063664 End>
         -- standard who columns
         last_update_date,
         last_updated_by,
         last_update_login,
         creation_date,
         created_by,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         FND_API.g_FALSE, -- initial value for error_flag

         -- txn table columns
         NULL,            -- status_lookup_code
         NULL,            -- cancel_flag
         NULL,            -- vendor_order_num
         NULL,            -- quote_vendor_quote_num
         document_creation_method, -- doc_creation_method -- <PDOI Enhancement Bug#17063664>
         NULL,            -- quotation_class_code
         NULL,            -- approved_flag
         NULL,            -- tax_attribute_update_code_tbl

         -- blanket dist columns
         NULL,            -- po_dist_id -- bug5252250

         NULL,            -- ame_approval_id       bug17940049
         NULL,            -- ame_transaction_type  bug17940049
	 decode(PO_PDOI_PARAMS.g_request.calling_module,
	        PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE, 'Y',
		NULL) consigned_consumption_flag, -- Bug 18891225
        supply_agreement_flag -- Bug 20022541 PDOI Support for Supply_agreement_flag

  FROM   po_headers_interface
  WHERE  processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    processing_round_num = PO_PDOI_PARAMS.g_current_round_num
  AND    interface_header_id > p_max_intf_header_id
  AND    action IN (PO_PDOI_CONSTANTS.g_ACTION_ORIGINAL,
                    PO_PDOI_CONSTANTS.g_ACTION_REPLACE)
  ORDER by interface_header_id;

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
END open_headers;

-----------------------------------------------------------------------
--Start of Comments
--Name: fetch_headers
--Function:
--  fetch results in batch
--Parameters:
--IN:
--IN OUT:
--x_headers_csr
--  cursor variable that hold pointers to currently processing row
--x_headers
--  record variable to hold header info within a batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fetch_headers
(
  x_headers_csr IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_headers     OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'fetch_headers';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  FETCH x_headers_csr BULK COLLECT INTO
    x_headers.intf_header_id_tbl,
    x_headers.draft_id_tbl,
    x_headers.po_header_id_tbl,
    x_headers.action_tbl,
    x_headers.document_num_tbl,
    x_headers.doc_type_tbl,
    x_headers.doc_subtype_tbl,
    x_headers.rate_type_tbl,
    x_headers.rate_type_code_tbl,
    x_headers.rate_date_tbl,
    x_headers.rate_tbl,
    x_headers.agent_id_tbl,
    x_headers.agent_name_tbl,
    x_headers.ship_to_loc_id_tbl,
    x_headers.ship_to_loc_tbl,
    x_headers.bill_to_loc_id_tbl,
    x_headers.bill_to_loc_tbl,
    x_headers.payment_terms_tbl,
    x_headers.terms_id_tbl,
    x_headers.vendor_name_tbl,
    x_headers.vendor_num_tbl,
    x_headers.vendor_id_tbl,
    x_headers.vendor_site_code_tbl,
    x_headers.vendor_site_id_tbl,
    x_headers.vendor_contact_tbl,
    x_headers.vendor_contact_id_tbl,
    x_headers.from_rfq_num_tbl,
    x_headers.from_header_id_tbl,
    x_headers.fob_tbl,
    x_headers.freight_carrier_tbl,
    x_headers.freight_term_tbl,
    x_headers.pay_on_code_tbl,
    x_headers.shipping_control_tbl,
    x_headers.currency_code_tbl,
    x_headers.quote_warning_delay_tbl,
    x_headers.approval_required_flag_tbl,
    x_headers.reply_date_tbl,
    x_headers.approval_status_tbl,
    x_headers.approved_date_tbl,
    x_headers.from_type_lookup_code_tbl,
    x_headers.revision_num_tbl,
    x_headers.confirming_order_flag_tbl,
    x_headers.acceptance_required_flag_tbl,
    x_headers.min_release_amount_tbl,
    x_headers.closed_code_tbl,
    x_headers.print_count_tbl,
    x_headers.frozen_flag_tbl,
    x_headers.encumbrance_required_flag_tbl,
    x_headers.vendor_doc_num_tbl,
    x_headers.org_id_tbl,
    x_headers.acceptance_due_date_tbl,
    x_headers.amount_to_encumber_tbl,
    x_headers.effective_date_tbl,
    x_headers.expiration_date_tbl,
    x_headers.po_release_id_tbl,
    x_headers.release_num_tbl,
    x_headers.release_date_tbl,
    x_headers.revised_date_tbl,
    x_headers.printed_date_tbl,
    x_headers.closed_date_tbl,
    x_headers.amount_agreed_tbl,
    x_headers.amount_limit_tbl, -- bug5352625
    x_headers.firm_flag_tbl,
    x_headers.gl_encumbered_date_tbl,
    x_headers.gl_encumbered_period_tbl,
    x_headers.budget_account_id_tbl,
    x_headers.budget_account_tbl,
    x_headers.budget_account_segment1_tbl,
    x_headers.budget_account_segment2_tbl,
    x_headers.budget_account_segment3_tbl,
    x_headers.budget_account_segment4_tbl,
    x_headers.budget_account_segment5_tbl,
    x_headers.budget_account_segment6_tbl,
    x_headers.budget_account_segment7_tbl,
    x_headers.budget_account_segment8_tbl,
    x_headers.budget_account_segment9_tbl,
    x_headers.budget_account_segment10_tbl,
    x_headers.budget_account_segment11_tbl,
    x_headers.budget_account_segment12_tbl,
    x_headers.budget_account_segment13_tbl,
    x_headers.budget_account_segment14_tbl,
    x_headers.budget_account_segment15_tbl,
    x_headers.budget_account_segment16_tbl,
    x_headers.budget_account_segment17_tbl,
    x_headers.budget_account_segment18_tbl,
    x_headers.budget_account_segment19_tbl,
    x_headers.budget_account_segment20_tbl,
    x_headers.budget_account_segment21_tbl,
    x_headers.budget_account_segment22_tbl,
    x_headers.budget_account_segment23_tbl,
    x_headers.budget_account_segment24_tbl,
    x_headers.budget_account_segment25_tbl,
    x_headers.budget_account_segment26_tbl,
    x_headers.budget_account_segment27_tbl,
    x_headers.budget_account_segment28_tbl,
    x_headers.budget_account_segment29_tbl,
    x_headers.budget_account_segment30_tbl,
    x_headers.created_language_tbl,
    x_headers.style_id_tbl,
    x_headers.style_display_name_tbl,
    x_headers.global_agreement_flag_tbl,
    -- <PDOI Enhancement Bug#17063664 Start>
    x_headers.consume_req_demand_flag_tbl,
    x_headers.pcard_id_tbl,
    -- <PDOI Enhancement Bug#17063664 End>
    -- standard who columns
    x_headers.last_update_date_tbl,
    x_headers.last_updated_by_tbl,
    x_headers.last_update_login_tbl,
    x_headers.creation_date_tbl,
    x_headers.created_by_tbl,
    x_headers.request_id_tbl,
    x_headers.program_application_id_tbl,
    x_headers.program_id_tbl,
    x_headers.program_update_date_tbl,

    x_headers.error_flag_tbl,  -- set initial value on error_flag

    -- tan table columns
    x_headers.status_lookup_code_tbl,
    x_headers.cancel_flag_tbl,
    x_headers.vendor_order_num_tbl,
    x_headers.quote_vendor_quote_num_tbl,
    x_headers.doc_creation_method_tbl,
    x_headers.quotation_class_code_tbl,
    x_headers.approved_flag_tbl,
    x_headers.tax_attribute_update_code_tbl,

    -- blanket dist columns
    x_headers.po_dist_id_tbl, -- bug5252250

    x_headers.ame_approval_id_tbl,      --bug17940049
    x_headers.ame_transaction_type_tbl, --bug17940049
    x_headers.consigned_consumption_flag_tbl, -- Bug 18891225

    x_headers.supply_agreement_flag_tbl -- Bug 20022541 PDOI Support for Supply_agreement_flag

  LIMIT PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE;

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
END fetch_headers;
--------------------------------------------------------------------------
--Start of Comments
--Name: derive_headers
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  perform derive logic on header records read in one batch;
--  derivation errors are handled all together after the
--  derivation logic
--  The derived attributes include:
--    rate_type,            agent_id
--    ship_to_location_id,  bill_to_location_id
--    terms_id,             vendor_id
--    vendor_site_id,       vendor_contact_id
--Parameters:
--IN: None
--IN OUT:
--   x_headers
--     variable to hold all the header attribute values in one batch;
--     derivation source and result are both placed inside the variable
--OUT: None
--Returns: None
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE derive_headers
(
  x_headers IN OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_headers';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- key used when operating on temp table
  l_key po_session_gt.key%TYPE;

  -- table used to save the index of the each row
  l_index_tbl DBMS_SQL.NUMBER_TABLE;

  -- temp variable used in derivation error handling
  l_column_name VARCHAR2(11);
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'header_count', x_headers.rec_count);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_HEADER_DERIVE);

  -- pick a new key which will be used in all derive logic
  l_key := PO_CORE_S.get_session_gt_nextval;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'key', l_key);
  END IF;

  -- initialize table containing the row number
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size     => x_headers.rec_count,
    x_num_list => l_index_tbl
  );

  d_position := 10;

  -- derive rate_type_code from rate_type
  derive_rate_type_code
  (
    p_key                => l_key,
    p_index_tbl          => l_index_tbl,
    p_rate_type_tbl      => x_headers.rate_type_tbl,
    x_rate_type_code_tbl => x_headers.rate_type_code_tbl
  );

  d_position := 20;

  -- derive agent_id from agent_name
  derive_agent_id
  (
    p_key                => l_key,
    p_index_tbl          => l_index_tbl,
    p_agent_name_tbl     => x_headers.agent_name_tbl,
    x_agent_id_tbl       => x_headers.agent_id_tbl
  );

  d_position := 30;

  -- derive ship_to_location_id from ship_to_location
  derive_location_id
  (
    p_key                => l_key,
    p_index_tbl          => l_index_tbl,
    p_location_type      => 'SHIP_TO',
    p_location_tbl       => x_headers.ship_to_loc_tbl,
    x_location_id_tbl    => x_headers.ship_to_loc_id_tbl
  );

  d_position := 40;

  -- derive bill_to_location_id from bill_to_location
  derive_location_id
  (
    p_key                => l_key,
    p_index_tbl          => l_index_tbl,
    p_location_type      => 'BILL_TO',
    p_location_tbl       => x_headers.bill_to_loc_tbl,
    x_location_id_tbl    => x_headers.bill_to_loc_id_tbl
  );

  d_position := 50;

  -- derive terms_id from payment_terms
  derive_terms_id
  (
    p_key                => l_key,
    p_index_tbl          => l_index_tbl,
    p_payment_terms_tbl  => x_headers.payment_terms_tbl,
    x_terms_id_tbl       => x_headers.terms_id_tbl
  );

  d_position := 60;

  -- derive vendor_id from vendor_name/vendor_num
  derive_vendor_id
  (
    p_key                => l_key,
    p_index_tbl          => l_index_tbl,
    p_vendor_name_tbl    => x_headers.vendor_name_tbl,
    p_vendor_num_tbl     => x_headers.vendor_num_tbl,
    x_vendor_id_tbl      => x_headers.vendor_id_tbl
  );

  d_position := 70;

  -- derive vendor_site_id from vendor_site_code
  derive_vendor_site_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_vendor_id_tbl        => x_headers.vendor_id_tbl,
    p_vendor_site_code_tbl => x_headers.vendor_site_code_tbl,
    x_vendor_site_id_tbl   => x_headers.vendor_site_id_tbl
  );

  d_position := 80;

  -- derive vendor_contact_id from vendor_contact
  derive_vendor_contact_id
  (
    p_key                   => l_key,
    p_index_tbl             => l_index_tbl,
    p_vendor_site_id_tbl    => x_headers.vendor_site_id_tbl,
    p_vendor_contact_tbl    => x_headers.vendor_contact_tbl,
    x_vendor_contact_id_tbl => x_headers.vendor_contact_id_tbl
  );

  -- derive style_id from style_display_name
  derive_style_id
  (
    p_key                    => l_key,
    p_index_tbl              => l_index_tbl,
    p_style_display_name_tbl => x_headers.style_display_name_tbl,
    x_style_id_tbl           => x_headers.style_id_tbl
   );

  d_position := 90;

  -- derive from_header_id from from_rfq_num for QUOTATION
  IF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'derive from header id');
    END IF;

    derive_from_header_id
    (
      p_key                 => l_key,
      p_index_tbl           => l_index_tbl,
      p_from_rfq_num_tbl    => x_headers.from_rfq_num_tbl,
      x_from_header_id_tbl  => x_headers.from_header_id_tbl
    );
  END IF;

  d_position := 100;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'start processing derivation errors');
  END IF;

  -- handle derivation errors
  FOR i IN 1..x_headers.rec_count
  LOOP
    d_position := 110;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
    END IF;

    IF (x_headers.rate_type_tbl(i) IS NOT NULL AND
        x_headers.rate_type_code_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'rate type code derivation failed');
        PO_LOG.stmt(d_module, d_position, 'rate type', x_headers.rate_type_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_headers.intf_header_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_HEADERS_INTERFACE',
        p_column_name          => 'RATE_TYPE_CODE',
        p_column_value         => x_headers.rate_type_code_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'RATE_TYPE',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_headers.rate_type_tbl(i)
      );

      x_headers.rate_type_code_tbl(i) := NULL;

      x_headers.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    IF (x_headers.agent_name_tbl(i) IS NOT NULL AND
        x_headers.agent_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'agent id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'agent name', x_headers.agent_name_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_headers.intf_header_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_HEADERS_INTERFACE',
        p_column_name          => 'AGENT_ID',
        p_column_value         => x_headers.agent_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'AGENT_NAME',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_headers.agent_name_tbl(i)
      );

      x_headers.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    IF (x_headers.ship_to_loc_tbl(i) IS NOT NULL AND
        x_headers.ship_to_loc_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'ship_to loc id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'ship_to loc', x_headers.ship_to_loc_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_headers.intf_header_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_HEADERS_INTERFACE',
        p_column_name          => 'SHIP_TO_LOCATION_ID',
        p_column_value         => x_headers.ship_to_loc_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'SHIP_TO_LOCATION_CODE',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_headers.ship_to_loc_tbl(i)
      );

      x_headers.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    IF (x_headers.bill_to_loc_tbl(i) IS NOT NULL AND
        x_headers.bill_to_loc_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'bill_to loc id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'bill_to loc', x_headers.bill_to_loc_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_headers.intf_header_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_HEADERS_INTERFACE',
        p_column_name          => 'BILL_TO_LOCATION_ID',
        p_column_value         => x_headers.bill_to_loc_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'BILL_TO_LOCATION_CODE',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_headers.bill_to_loc_tbl(i)
      );

      x_headers.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    IF (x_headers.payment_terms_tbl(i) IS NOT NULL AND
        x_headers.terms_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'terms id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'payment terms', x_headers.payment_terms_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_headers.intf_header_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_HEADERS_INTERFACE',
        p_column_name          => 'TERMS_ID',
        p_column_value         => x_headers.terms_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'PAYMENT_TERMS',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_headers.payment_terms_tbl(i)
      );

      x_headers.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    IF ((x_headers.vendor_name_tbl(i) IS NOT NULL OR
         x_headers.vendor_num_tbl(i) IS NOT NULL) AND
        x_headers.vendor_id_tbl(i) IS NULL) THEN
      IF (x_headers.vendor_num_tbl(i) IS NULL) THEN
        l_column_name := 'VENDOR_NAME';
      ELSE
        l_column_name := 'VENDOR_NUM';
      END IF;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'vendor id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'vendor name', x_headers.vendor_name_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'vendor num', x_headers.vendor_num_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_headers.intf_header_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_HEADERS_INTERFACE',
        p_column_name          => 'VENDOR_ID',
        p_column_value         => x_headers.vendor_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => l_column_name,
        p_token2_name          => 'VALUE',
        p_token2_value         => NVL(x_headers.vendor_num_tbl(i),
                                      x_headers.vendor_name_tbl(i))
      );

      x_headers.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    IF (x_headers.vendor_site_code_tbl(i) IS NOT NULL AND
        x_headers.vendor_site_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'vendor site id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'vendor site', x_headers.vendor_site_code_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_headers.intf_header_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_HEADERS_INTERFACE',
        p_column_name          => 'VENDOR_SITE_ID',
        p_column_value         => x_headers.vendor_site_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'VENDOR_SITE_CODE',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_headers.vendor_site_code_tbl(i)
      );

      x_headers.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    IF (x_headers.vendor_contact_tbl(i) IS NOT NULL AND
        x_headers.vendor_contact_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'contact id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'contact', x_headers.vendor_contact_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_headers.intf_header_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_HEADERS_INTERFACE',
        p_column_name          => 'VENDOR_CONTACT_ID',
        p_column_value         => x_headers.vendor_contact_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'VENDOR_CONTACT',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_headers.vendor_contact_tbl(i)
      );

      x_headers.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    IF (x_headers.style_display_name_tbl(i) IS NOT NULL AND
        x_headers.style_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'style id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'style_display_name', x_headers.style_display_name_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_headers.intf_header_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_HEADERS_INTERFACE',
        p_column_name          => 'STYLE_ID',
        p_column_value         => x_headers.style_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'STYLE_DISPLAY_NAME',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_headers.style_display_name_tbl(i)
      );

      x_headers.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    IF (PO_PDOI_PARAMS.g_request.document_type =
        PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN
      IF (x_headers.from_rfq_num_tbl(i) IS NOT NULL AND
          x_headers.from_header_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'from header id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'rfq num', x_headers.from_rfq_num_tbl(i));
      END IF;

        PO_PDOI_ERR_UTL.add_fatal_error
        (
          p_interface_header_id  => x_headers.intf_header_id_tbl(i),
          p_error_message_name   => 'PO_PDOI_DERV_ERROR',
          p_table_name           => 'PO_HEADERS_INTERFACE',
          p_column_name          => 'FROM_HEADER_ID',
          p_column_value         => x_headers.from_header_id_tbl(i),
          p_token1_name          => 'COLUMN_NAME',
          p_token1_value         => 'FROM_RFQ_NUM',
          p_token2_name          => 'VALUE',
          p_token2_value         => x_headers.from_rfq_num_tbl(i)
        );

        x_headers.error_flag_tbl(i) := FND_API.g_TRUE;
      END IF;
    END IF;
  END LOOP;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'end of processing derivation errors');
  END IF;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_HEADER_DERIVE);

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
END derive_headers;

--------------------------------------------------------------------------
--Start of Comments
--Name: default_headers
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  perform default logic on header records read in one batch;
--Parameters:
--IN: None
--IN OUT:
--   x_headers
--     variable to hold all the header attribute values in one batch;
--     default result are saved inside the variable
--OUT: None
--Returns: None
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE default_headers
(
  x_headers IN OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_headers';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- key used when operating on temp table
  l_key po_session_gt.key%TYPE;

  -- table used to save the index of the each row
  l_index_tbl DBMS_SQL.NUMBER_TABLE;

  -- information defaulted from vendor

  -- <Bug 4546121: Supplier TCA conversion>
  -- The following columns are being obsoleted from PO_VENDORS level.
  --l_vendor_fob_tbl                     PO_TBL_VARCHAR30;
  --l_vendor_freight_carrier_tbl         PO_TBL_VARCHAR30;
  --l_vendor_freight_term_tbl            PO_TBL_VARCHAR30;
  --l_vendor_ship_to_loc_id_tbl          PO_TBL_NUMBER;
  --l_vendor_bill_to_loc_id_tbl          PO_TBL_NUMBER;

  l_vendor_invoice_curr_code_tbl       PO_TBL_VARCHAR30;
  l_vendor_terms_id_tbl                PO_TBL_NUMBER;

  -- information defaulted from vendor site
  l_site_fob_tbl                       PO_TBL_VARCHAR30;
  l_site_freight_carrier_tbl           PO_TBL_VARCHAR30;
  l_site_freight_term_tbl              PO_TBL_VARCHAR30;
  l_site_ship_to_loc_id_tbl            PO_TBL_NUMBER;
  l_site_bill_to_loc_id_tbl            PO_TBL_NUMBER;
  l_site_invoice_curr_code_tbl         PO_TBL_VARCHAR30;
  l_site_terms_id_tbl                  PO_TBL_NUMBER;
  l_site_shipping_control_tbl          PO_TBL_VARCHAR30;
  l_site_pay_on_code_tbl               PO_TBL_VARCHAR30;

  l_lang VARCHAR2(4);
  l_display_rate                       NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_HEADER_DEFAULT);

  -- pick a new key which will be used in all derive logic
  l_key := PO_CORE_S.get_session_gt_nextval;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'key', l_key);
  END IF;

  -- initialize table containing the row number
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size => x_headers.rec_count,
    x_num_list => l_index_tbl
   );

  d_position := 10;

  -- default information from vendor
  default_info_from_vendor
  (
    p_key                       => l_key,
    p_index_tbl                 => l_index_tbl,
    p_vendor_id_tbl             => x_headers.vendor_id_tbl,
    x_invoice_currency_code_tbl => l_vendor_invoice_curr_code_tbl,
    x_terms_id_tbl              => l_vendor_terms_id_tbl
  );

  d_position := 20;

  -- default information from vendor site
  default_info_from_vendor_site
  (
    p_key                       => l_key,
    p_index_tbl                 => l_index_tbl,
    p_vendor_id_tbl             => x_headers.vendor_id_tbl,
    x_vendor_site_id_tbl        => x_headers.vendor_site_id_tbl,
    x_fob_tbl                   => l_site_fob_tbl,
    x_freight_carrier_tbl       => l_site_freight_carrier_tbl,
    x_freight_term_tbl          => l_site_freight_term_tbl,
    x_ship_to_loc_id_tbl        => l_site_ship_to_loc_id_tbl,
    x_bill_to_loc_id_tbl        => l_site_bill_to_loc_id_tbl,
    x_invoice_currency_code_tbl => l_site_invoice_curr_code_tbl,
    x_terms_id_tbl              => l_site_terms_id_tbl,
    x_shipping_control_tbl      => l_site_shipping_control_tbl,
    x_pay_on_code_tbl           => l_site_pay_on_code_tbl
  );

  d_position := 30;

  -- default vendor contact from vendor site
  default_vendor_contact
  (
    p_key                       => l_key,
    p_index_tbl                 => l_index_tbl,
    p_vendor_site_id_tbl        => x_headers.vendor_site_id_tbl,
    x_vendor_contact_id_tbl     => x_headers.vendor_contact_id_tbl
  );

  d_position := 40;

  FOR i IN 1..x_headers.rec_count
  LOOP
    d_position := 50;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
    END IF;

    -- default created_language for Blanket and Quotation
    IF (PO_PDOI_PARAMS.g_request.document_type IN
       (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET, PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)) THEN
      x_headers.created_language_tbl(i) :=
        NVL(x_headers.created_language_tbl(i), USERENV('LANG'));
    END IF;

    -- default agent_id
    x_headers.agent_id_tbl(i) :=
      NVL(x_headers.agent_id_tbl(i), PO_PDOI_PARAMS.g_request.buyer_id);

    -- default document_type_code
    x_headers.doc_type_tbl(i) :=
      NVL(x_headers.doc_type_tbl(i), PO_PDOI_PARAMS.g_request.document_type);

    -- default fob_lookup_code
    x_headers.fob_tbl(i) :=
      COALESCE(x_headers.fob_tbl(i), l_site_fob_tbl(i),
               PO_PDOI_PARAMS.g_sys.fob_lookup_code);

    -- default freight_carrier(ship_via_lookup_code)
    x_headers.freight_carrier_tbl(i) :=
      COALESCE(x_headers.freight_carrier_tbl(i), l_site_freight_carrier_tbl(i),
               PO_PDOI_PARAMS.g_sys.ship_via_lookup_code);

    -- default freight_terms
    x_headers.freight_term_tbl(i) :=
      COALESCE(x_headers.freight_term_tbl(i), l_site_freight_term_tbl(i),
               PO_PDOI_PARAMS.g_sys.freight_terms_lookup_code);

    -- default terms_id
    x_headers.terms_id_tbl(i) :=
      COALESCE(x_headers.terms_id_tbl(i), l_site_terms_id_tbl(i),
               l_vendor_terms_id_tbl(i), PO_PDOI_PARAMS.g_sys.terms_id);

    -- default shipping_control
    x_headers.shipping_control_tbl(i) :=
      NVL(x_headers.shipping_control_tbl(i), l_site_shipping_control_tbl(i));

    -- default ship_to_location_id
    x_headers.ship_to_loc_id_tbl(i) :=
     COALESCE(x_headers.ship_to_loc_id_tbl(i), l_site_ship_to_loc_id_tbl(i),
              PO_PDOI_PARAMS.g_sys.ship_to_location_id);

    -- default bill_to_location_id
    x_headers.bill_to_loc_id_tbl(i) :=
      COALESCE(x_headers.bill_to_loc_id_tbl(i), l_site_bill_to_loc_id_tbl(i),
               PO_PDOI_PARAMS.g_sys.bill_to_location_id);

    x_headers.global_agreement_flag_tbl(i) :=
      NVL(x_headers.global_agreement_flag_tbl(i), PO_PDOI_PARAMS.g_request.ga_flag);

    -- default style_id
    IF (x_headers.doc_type_tbl(i) = 'QUOTATION' OR
         (x_headers.doc_type_tbl(i) = 'BLANKET' AND x_headers.global_agreement_flag_tbl(i) = 'N'))
    THEN
       x_headers.style_id_tbl(i) := PO_DOC_STYLE_GRP.get_standard_doc_style;
    ELSE
       x_headers.style_id_tbl(i) :=
         NVL(x_headers.style_id_tbl(i), PO_DOC_STYLE_GRP.get_standard_doc_style);
    END IF;

    -- set pay_on_code
    -- Bug 18891225
    x_headers.pay_on_code_tbl(i) := NVL(x_headers.pay_on_code_tbl(i), l_site_pay_on_code_tbl(i));


    -- default approval_status
    x_headers.approval_status_tbl(i) :=
      NVL(x_headers.approval_status_tbl(i), PO_PDOI_PARAMS.g_request.approved_status);

    -- bug4911383
    -- If intended approval status = 'APPROVED', it cannot require signature

    -- Bug 18636274
    -- Correcting defaulting logic of acceptance required flag
    -- For contracts, Document or Shipment not applicable.

    IF PO_PDOI_PARAMS.g_sys.acceptance_required_flag <> 'Y'
       OR PO_PDOI_PARAMS.g_request.document_type <> PO_PDOI_CONSTANTS.g_doc_type_CONTRACT THEN
     x_headers.acceptance_required_flag_tbl(i) :=
        NVL(x_headers.acceptance_required_flag_tbl(i), PO_PDOI_PARAMS.g_sys.acceptance_required_flag);    /* Bug 7518967 : Default Acceptance Required Check ER */
     ELSE
       x_headers.acceptance_required_flag_tbl(i) := NVL(x_headers.acceptance_required_flag_tbl(i), 'N');
     END IF;


    IF (x_headers.approval_status_tbl(i) = 'APPROVED' AND
        x_headers.acceptance_required_flag_tbl(i) = 'S') THEN

      x_headers.acceptance_required_flag_tbl(i) := 'N';


    END IF;

    -- bug4690880
    -- All document types will share same behavior in terms of currency code
    -- defaulting
    -- default currency_code
    x_headers.currency_code_tbl(i) :=
        COALESCE(x_headers.currency_code_tbl(i), l_site_invoice_curr_code_tbl(i),
                 l_vendor_invoice_curr_code_tbl(i), PO_PDOI_PARAMS.g_sys.currency_code);

    d_position := 60;

    -- default attributes for each document type
    IF (x_headers.doc_type_tbl(i) = PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN
      -- default document sub-type
      x_headers.doc_subtype_tbl(i) :=
        NVL(x_headers.doc_subtype_tbl(i), PO_PDOI_PARAMS.g_request.document_subtype);

      -- set quotation_class_code
      x_headers.quotation_class_code_tbl(i) :=
        PO_PDOI_MAINPROC_UTL_PVT.get_quotation_class_code
        (
          x_headers.doc_subtype_tbl(i)
        );

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'quote class code',
                    x_headers.quotation_class_code_tbl(i));
      END IF;

      -- set global agreement flag to NULL
      x_headers.global_agreement_flag_tbl(i) := NULL;

      -- default quote_warning_delay
      x_headers.quote_warning_delay_tbl(i) :=
        NVL(x_headers.quote_warning_delay_tbl(i),
            PO_PDOI_PARAMS.g_sys.def_quote_warning_delay);

      -- default approval_required_flag
      x_headers.approval_required_flag_tbl(i) :=
        NVL(x_headers.approval_required_flag_tbl(i), 'N');

      -- default reply_date
      x_headers.reply_date_tbl(i) := NVL(x_headers.reply_date_tbl(i), sysdate);

      -- set approved_flag
      x_headers.approved_flag_tbl(i) := NULL;

      -- set approved_date
      x_headers.approved_date_tbl(i) := NULL;

      d_position := 70;

      -- set status_lookup_code
      IF (x_headers.approval_status_tbl(i) = 'INCOMPLETE') THEN
        x_headers.status_lookup_code_tbl(i) := 'I';
      ELSE
        -- approval_status = 'APPROVED'
        x_headers.status_lookup_code_tbl(i) := 'A';
      END IF;

      -- default from_type_lookup_code
      IF (x_headers.from_type_lookup_code_tbl(i) IS NULL AND
          x_headers.from_header_id_tbl(i) IS NOT NULL) THEN
        x_headers.from_type_lookup_code_tbl(i) := 'RFQ';
      END IF;

      -- set cancel_flag
      x_headers.cancel_flag_tbl(i) := NULL;

      -- set vendor_order_num
      x_headers.vendor_order_num_tbl(i) := NULL;

      -- set quote_vendor_quote_num
      x_headers.quote_vendor_quote_num_tbl(i) := x_headers.vendor_doc_num_tbl(i);

      -- set document_creation_method
      x_headers.doc_creation_method_tbl(i) := NULL;

      -- default document_number
      -- this is not the final value for document_number,
      -- but a temp value used to insert record into draft table

      -- if document num assigning method is 'AUTOMATIC', always overwrite
      -- user's document num input
      IF (PO_PDOI_PARAMS.g_sys.user_defined_quote_num_code = 'AUTOMATIC') THEN

        d_position := 80;

        -- bug5028275
        -- assign document number only if the user has not provided any
        IF (x_headers.document_num_tbl(i) IS NULL) THEN
          x_headers.document_num_tbl(i) :=  -x_headers.po_header_id_tbl(i);
        END IF;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'temp doc num',
                      x_headers.document_num_tbl(i));
        END IF;

      END IF;
    ELSIF (x_headers.doc_type_tbl(i) = PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN

      d_position := 90;

      -- default revision_num
      x_headers.revision_num_tbl(i) := NVL(x_headers.revision_num_tbl(i), 0);

      d_position := 100;

      -- default confirming_order_flag
      x_headers.confirming_order_flag_tbl(i) :=
        NVL(x_headers.confirming_order_flag_tbl(i), 'N');

      -- default acceptance_required_flag
      x_headers.acceptance_required_flag_tbl(i) :=
        NVL(x_headers.acceptance_required_flag_tbl(i), PO_PDOI_PARAMS.g_sys.acceptance_required_flag);      /* Bug 7518967 : Default Acceptance Required Check ER */

      -- default min_release_amount
      x_headers.min_release_amount_tbl(i) :=
        NVL(x_headers.min_release_amount_tbl(i),
            PO_PDOI_PARAMS.g_sys.min_rel_amount);

      -- default closed_code
      x_headers.closed_code_tbl(i) := NVL(x_headers.closed_code_tbl(i), 'OPEN');

      -- default print_count
      x_headers.print_count_tbl(i) := NVL(x_headers.print_count_tbl(i), 0);

      -- default frozen_flag
      x_headers.frozen_flag_tbl(i) := NVL(x_headers.frozen_flag_tbl(i), 'N');

      d_position := 110;

      x_headers.approved_flag_tbl(i) := NULL;
      x_headers.approved_date_tbl(i) := NULL;

      -- set status_lookup_code
      x_headers.status_lookup_code_tbl(i) := NULL;

      -- set cancel_flag
      x_headers.cancel_flag_tbl(i) := 'N';

      -- set vendor_order_num
      x_headers.vendor_order_num_tbl(i) := x_headers.vendor_doc_num_tbl(i);

      -- set quote_vendor_quote_num
      x_headers.quote_vendor_quote_num_tbl(i) := NULL;

      -- <PDOI Enhancement Bug#17063664>
      IF(x_headers.doc_creation_method_tbl(i) IS NULL) THEN
          -- set document_creation_method
          x_headers.doc_creation_method_tbl(i) := 'PDOI';
      END IF;

      -- default document_number
      -- this is not the final value for document_number,
      -- but a temp value used to insert record into draft table

      -- if document num assigning method is 'AUTOMATIC', always overwrite
      -- user's document num input
      IF (PO_PDOI_PARAMS.g_sys.user_defined_po_num_code = 'AUTOMATIC') THEN

        d_position := 120;

        -- bug5028275
        -- assign document number only if the user has not provided any
        IF (x_headers.document_num_tbl(i) IS NULL) THEN
          x_headers.document_num_tbl(i) :=  -x_headers.po_header_id_tbl(i);
        END IF;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'temp doc num',
                      x_headers.document_num_tbl(i));
        END IF;
      END IF;

      --bug17940049
      --Default the ame_transaction_type and ame_approval_id
      default_ame_attributes(
          x_style_id => x_headers.style_id_tbl(i),
          x_ame_approval_id => x_headers.ame_approval_id_tbl(i),
          x_ame_transaction_type => x_headers.ame_transaction_type_tbl(i));

    -- <<PDOI Enhancement Bug#17063664 Start>>
    -- Defaulting header level attributes for CONTRACT type documents
    ELSIF (x_headers.doc_type_tbl(i) = PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT) THEN

      d_position := 130;

      -- default revision_num
      x_headers.revision_num_tbl(i) := NVL(x_headers.revision_num_tbl(i), 0);

      d_position := 140;

      -- default confirming_order_flag
      x_headers.confirming_order_flag_tbl(i) :=
        NVL(x_headers.confirming_order_flag_tbl(i), 'N');

      -- default acceptance_required_flag
      x_headers.acceptance_required_flag_tbl(i) :=
        NVL(x_headers.acceptance_required_flag_tbl(i), PO_PDOI_PARAMS.g_sys.acceptance_required_flag);      /* Bug 7518967 : Default Acceptance Required Check ER */

      -- default closed_code
      x_headers.closed_code_tbl(i) := NVL(x_headers.closed_code_tbl(i), 'OPEN');

      -- default print_count
      x_headers.print_count_tbl(i) := NVL(x_headers.print_count_tbl(i), 0);

      -- default frozen_flag
      x_headers.frozen_flag_tbl(i) := NVL(x_headers.frozen_flag_tbl(i), 'N');

      d_position := 150;

      x_headers.approved_flag_tbl(i) := NULL;
      x_headers.approved_date_tbl(i) := NULL;

      -- set status_lookup_code
      x_headers.status_lookup_code_tbl(i) := NULL;

      -- set cancel_flag
      x_headers.cancel_flag_tbl(i) := 'N';

      -- set vendor_order_num
      x_headers.vendor_order_num_tbl(i) := x_headers.vendor_doc_num_tbl(i);

      -- set quote_vendor_quote_num
      x_headers.quote_vendor_quote_num_tbl(i) := NULL;

      IF(x_headers.doc_creation_method_tbl(i) IS NULL) THEN
          -- set document_creation_method
          x_headers.doc_creation_method_tbl(i) := 'PDOI';
      END IF;

      -- default document_number
      -- this is not the final value for document_number,
      -- but a temp value used to insert record into draft table

      -- if document num assigning method is 'AUTOMATIC', always overwrite
      -- user's document num input
      IF (PO_PDOI_PARAMS.g_sys.user_defined_po_num_code = 'AUTOMATIC') THEN

        d_position := 160;

        -- bug5028275
        -- assign document number only if the user has not provided any
        IF (x_headers.document_num_tbl(i) IS NULL) THEN
          x_headers.document_num_tbl(i) :=  -x_headers.po_header_id_tbl(i);
        END IF;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'temp doc num',
                      x_headers.document_num_tbl(i));
        END IF;
      END IF;
    -- <PDOI Enhancement Bug#17063664 End>
    ELSIF (x_headers.doc_type_tbl(i) = PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN

      d_position := 170;

      -- default revision_num
      x_headers.revision_num_tbl(i) := NVL(x_headers.revision_num_tbl(i), 0);

      -- default confirming_order_flag
      x_headers.confirming_order_flag_tbl(i) :=
        NVL(x_headers.confirming_order_flag_tbl(i), 'N');

      -- default acceptance_required_flag
      x_headers.acceptance_required_flag_tbl(i) :=
        NVL(x_headers.acceptance_required_flag_tbl(i), PO_PDOI_PARAMS.g_sys.acceptance_required_flag);      /* Bug 7518967 : Default Acceptance Required Check ER */

      -- default closed_code
      x_headers.closed_code_tbl(i) := NVL(x_headers.closed_code_tbl(i), 'OPEN');

      -- default print_count
      x_headers.print_count_tbl(i) := NVL(x_headers.print_count_tbl(i), 0);

      -- default frozen_flag
      x_headers.frozen_flag_tbl(i) := NVL(x_headers.frozen_flag_tbl(i), 'N');

      d_position := 180;

      x_headers.approved_flag_tbl(i) := NULL;
      x_headers.approved_date_tbl(i) := NULL;

      d_position := 190;

      -- set status_lookup_code
      x_headers.status_lookup_code_tbl(i) := NULL;

      -- set cancel_flag
      x_headers.cancel_flag_tbl(i) := 'N';

      -- set vendor_order_num
      x_headers.vendor_order_num_tbl(i) := x_headers.vendor_doc_num_tbl(i);

      -- set quote_vendor_quote_num
      x_headers.quote_vendor_quote_num_tbl(i) := NULL;

      -- <PDOI Enhancement Bug#17063664>
      IF(x_headers.doc_creation_method_tbl(i) IS NULL) THEN
        -- set document_creation_method
        x_headers.doc_creation_method_tbl(i) := 'PDOI';
      END IF;

      -- set tax attribute update code
      x_headers.tax_attribute_update_code_tbl(i) := 'CREATE';

      -- default document_number
      -- this is not the final value for document_number,
      -- but a temp value used to insert record into draft table

      -- if document num assigning method is 'AUTOMATIC', always overwrite
      -- user's document num input
      IF (PO_PDOI_PARAMS.g_sys.user_defined_po_num_code = 'AUTOMATIC') THEN

        -- bug5028275
        -- assign document number only if the user has not provided any
        IF (x_headers.document_num_tbl(i) IS NULL) THEN
          x_headers.document_num_tbl(i) :=  -x_headers.po_header_id_tbl(i);
        END IF;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'temp doc num',
                      x_headers.document_num_tbl(i));
        END IF;

      END IF;

      --bug17940049
      --Default the ame_approval_id and ame_transaction_type
      default_ame_attributes(
          x_style_id => x_headers.style_id_tbl(i),
          x_ame_approval_id => x_headers.ame_approval_id_tbl(i),
          x_ame_transaction_type => x_headers.ame_transaction_type_tbl(i));

    END IF;

    d_position := 200;

    -- default rate info after currency is defaulted
    IF (x_headers.currency_code_tbl(i) <> PO_PDOI_PARAMS.g_sys.currency_code) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'default rate info');
        PO_LOG.stmt(d_module, d_position, 'currency_code',
                    x_headers.currency_code_tbl(i));
      END IF;

      -- default rate_date
      x_headers.rate_date_tbl(i) := NVL(x_headers.rate_date_tbl(i), sysdate);

      -- default rate_type

/* 8688769 BUG,Added Exception Block for GL API call */
BEGIN
      IF (GL_CURRENCY_API.is_fixed_rate
          (
            x_from_currency       => x_headers.currency_code_tbl(i),
            x_to_currency         => PO_PDOI_PARAMS.g_sys.currency_code,
            x_effective_date      => x_headers.rate_date_tbl(i)
          ) = 'Y') THEN
        x_headers.rate_type_code_tbl(i) := 'EMU FIXED';      --bug 7653758
      ELSE
        x_headers.rate_type_code_tbl(i) :=
          NVL(x_headers.rate_type_code_tbl(i), PO_PDOI_PARAMS.g_sys.default_rate_type);   --bug 7653758
      END IF;
  EXCEPTION
         WHEN OTHERS THEN
            IF (PO_LOG.d_stmt) THEN
        	  PO_LOG.stmt(d_module, d_position, 'Exception arised in GL_CURRENCY_API');
            END IF;
    END;


      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'rate type',
                    x_headers.rate_type_code_tbl(i));    --bug7653758
      END IF;

      d_position := 210;

      -- default rate
      IF (x_headers.rate_tbl(i) IS NULL OR
          x_headers.rate_type_code_tbl(i) = 'EMU FIXED') THEN     --bug 7653758
        po_currency_sv.get_rate
		(
          x_set_of_books_id => PO_PDOI_PARAMS.g_sys.sob_id,
          x_currency_code   => x_headers.currency_code_tbl(i),
          x_rate_type       => x_headers.rate_type_code_tbl(i),    --bug 7653758
          x_rate_date       => x_headers.rate_date_tbl(i),
          x_inverse_rate_display_flag => 'N',
          x_rate            => x_headers.rate_tbl(i),
          x_display_rate    => l_display_rate
        );

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'rate', x_headers.rate_tbl(i));
        END IF;
      END IF;
    END IF;
  END LOOP;

  d_position := 220;

  -- default the distribution related fields for a Blanket if
  -- encumbrance is required on this document
  IF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET AND
      PO_PDOI_PARAMS.g_sys.po_encumbrance_flag = 'Y' AND
      PO_PDOI_PARAMS.g_sys.req_encumbrance_flag = 'Y') THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'create distribution for blanket' ||
                  ' since encumbrance is required');
    END IF;

    default_dist_attributes
    (
      x_headers       => x_headers
    );
  END IF;

  d_position := 230;

  -- call utility method to default standard who columns
  PO_PDOI_MAINPROC_UTL_PVT.default_who_columns
  (
    x_last_update_date_tbl       => x_headers.last_update_date_tbl,
    x_last_updated_by_tbl        => x_headers.last_updated_by_tbl,
    x_last_update_login_tbl      => x_headers.last_update_login_tbl,
    x_creation_date_tbl          => x_headers.creation_date_tbl,
    x_created_by_tbl             => x_headers.created_by_tbl,
    x_request_id_tbl             => x_headers.request_id_tbl,
    x_program_application_id_tbl => x_headers.program_application_id_tbl,
    x_program_id_tbl             => x_headers.program_id_tbl,
    x_program_update_date_tbl    => x_headers.program_update_date_tbl
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_HEADER_DEFAULT);

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
END default_headers;

-----------------------------------------------------------------------
--Start of Comments
--Name: validate_headers
--Function:
--  validate header attributes;
--  If there is error(s) on any attribute of the header row,
--  corresponding value in error_flag_tbl will be set with value
--  FND_API.g_TRUE.
--Parameters:
--IN:
--x_headers
--  record containing header info within the batch;
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE validate_headers
(
  x_headers       IN OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'validate_headers';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_headers         PO_HEADERS_VAL_TYPE := PO_HEADERS_VAL_TYPE();
  l_result_type     VARCHAR2(30);
  l_results         po_validation_results_type;
  l_parameter_name_tbl    PO_TBL_VARCHAR2000 := PO_TBL_VARCHAR2000();
  l_parameter_value_tbl   PO_TBL_VARCHAR2000 := PO_TBL_VARCHAR2000();

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'x_headers', x_headers.intf_header_id_tbl);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_HEADER_VALIDATE);

  l_headers.interface_id              := x_headers.intf_header_id_tbl;
  l_headers.po_header_id              := x_headers.po_header_id_tbl;
  l_headers.start_date                := x_headers.effective_date_tbl;
  l_headers.end_date                  := x_headers.expiration_date_tbl;
  l_headers.type_lookup_code          := x_headers.doc_type_tbl;
  l_headers.acceptance_required_flag  := x_headers.acceptance_required_flag_tbl;
  l_headers.revision_num              := x_headers.revision_num_tbl;
  l_headers.document_num              := x_headers.document_num_tbl;
  l_headers.org_id                    := x_headers.org_id_tbl;
  l_headers.currency_code             := x_headers.currency_code_tbl;
  l_headers.rate_type                 := x_headers.rate_type_code_tbl;    --bug 7653758
  l_headers.rate                      := x_headers.rate_tbl;
  l_headers.rate_date                 := x_headers.rate_date_tbl;
  l_headers.agent_id                  := x_headers.agent_id_tbl;
  l_headers.vendor_id                 := x_headers.vendor_id_tbl;
  l_headers.vendor_site_id            := x_headers.vendor_site_id_tbl;
  l_headers.vendor_contact_id         := x_headers.vendor_contact_id_tbl;
  l_headers.ship_to_location_id       := x_headers.ship_to_loc_id_tbl;
  l_headers.bill_to_location_id       := x_headers.bill_to_loc_id_tbl;
  l_headers.last_update_date          := x_headers.last_update_date_tbl;
  l_headers.last_updated_by           := x_headers.last_updated_by_tbl;
  l_headers.po_release_id             := x_headers.po_release_id_tbl;
  l_headers.release_num               := x_headers.release_num_tbl;
  l_headers.release_date              := x_headers.release_date_tbl;
  l_headers.revised_date              := x_headers.revised_date_tbl;
  l_headers.printed_date              := x_headers.printed_date_tbl;
  l_headers.closed_date               := x_headers.closed_date_tbl;
  l_headers.terms_id                  := x_headers.terms_id_tbl;
  l_headers.ship_via_lookup_code      := x_headers.freight_carrier_tbl;
  l_headers.fob_lookup_code           := x_headers.fob_tbl;
  l_headers.freight_terms_lookup_code := x_headers.freight_term_tbl;
  l_headers.shipping_control          := x_headers.shipping_control_tbl;
  l_headers.confirming_order_flag     := x_headers.confirming_order_flag_tbl;
  l_headers.acceptance_due_date       := x_headers.acceptance_due_date_tbl;
  l_headers.amount_agreed             := x_headers.amount_agreed_tbl;
  l_headers.amount_limit              := x_headers.amount_limit_tbl; -- bug5352625
  l_headers.firm_status_lookup_code   := x_headers.firm_flag_tbl;
  l_headers.cancel_flag               := x_headers.cancel_flag_tbl;
  l_headers.closed_code               := x_headers.closed_code_tbl;
  l_headers.print_count               := x_headers.print_count_tbl;
  l_headers.frozen_flag               := x_headers.frozen_flag_tbl;
  l_headers.approval_status           := x_headers.approval_status_tbl;
  l_headers.amount_to_encumber        := x_headers.amount_to_encumber_tbl;
  l_headers.quote_warning_delay       := x_headers.quote_warning_delay_tbl;
  l_headers.approval_required_flag    := x_headers.approval_required_flag_tbl;
  l_headers.style_id                  := x_headers.style_id_tbl;

  l_parameter_name_tbl.EXTEND(6);
  l_parameter_value_tbl.EXTEND(6);
  l_parameter_name_tbl(1)             := 'INVENTORY_ORG_ID';
  l_parameter_value_tbl(1)            := PO_PDOI_PARAMS.g_sys.def_inv_org_id; -- bug5601416
  l_parameter_name_tbl(2)             := 'SET_OF_BOOKS_ID';
  l_parameter_value_tbl(2)            := PO_PDOI_PARAMS.g_sys.sob_id;
  l_parameter_name_tbl(3)             := 'FUNCTIONAL_CURRENCY_CODE';
  l_parameter_value_tbl(3)            := PO_PDOI_PARAMS.g_sys.currency_code;
  l_parameter_name_tbl(4)             := 'FEDERAL_INSTANCE';
  l_parameter_value_tbl(4)            := PO_PDOI_PARAMS.g_sys.is_federal_instance;
  l_parameter_name_tbl(5)             := 'MANUAL_PO_NUM_TYPE';
  l_parameter_value_tbl(5)            := PO_PDOI_PARAMS.g_sys.manual_po_num_type;
  l_parameter_name_tbl(6)             := 'MANUAL_QUOTE_NUM_TYPE';
  l_parameter_value_tbl(6)            := PO_PDOI_PARAMS.g_sys.manual_quote_num_type;

  d_position := 10;

  PO_VALIDATIONS.validate_pdoi(p_headers                 => l_headers,
                               p_doc_type                => PO_PDOI_PARAMS.g_request.document_type,
                               p_parameter_name_tbl      => l_parameter_name_tbl,
                               p_parameter_value_tbl     => l_parameter_value_tbl,
                               x_result_type             => l_result_type,
                               x_results                 => l_results);

  d_position := 20;

  IF l_result_type = po_validations.c_result_type_failure THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'vaidate headers return failure');
    END IF;

    PO_PDOI_ERR_UTL.process_val_type_errors
    (
      x_results    => l_results,
      p_table_name => 'PO_HEADERS_INTERFACE',
      p_headers    => x_headers
    );

    d_position := 30;

    populate_error_flag
    (
      x_results  => l_results,
      x_headers  => x_headers
    );
  END IF;

  d_position := 40;

  IF l_result_type = po_validations.c_result_type_fatal THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'vaidate headers return fatal');
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  d_position := 50;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_HEADER_VALIDATE);

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
END validate_headers;

-------------------------------------------------------------------------
--Start of Comments
--Name: derive_location_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive location_id from location code in batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_location_type
--    the value can be 'SHIP_TO'/'BILL_TO'
--  p_location_tbl
--    values of location code in current batch of records
--IN OUT:
--  x_location_id_tbl
--    contains the derived result if original value is null
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_location_id
(
  p_key                IN po_session_gt.key%TYPE,
  p_index_tbl          IN DBMS_SQL.NUMBER_TABLE,
  p_location_type      IN VARCHAR2,
  p_location_tbl       IN PO_TBL_VARCHAR100,
  x_location_id_tbl    IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_location_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'location type', p_location_type);
    PO_LOG.proc_begin(d_module, 'locations', p_location_tbl);
    PO_LOG.proc_begin(d_module, 'location ids', x_location_id_tbl);
  END IF;

  IF (p_location_type = 'SHIP_TO') THEN
    FORALL i IN 1..p_index_tbl.COUNT
      INSERT INTO po_session_gt(key, num1, num2)
      SELECT p_key,
             p_index_tbl(i),
             location_id
      FROM   po_locations_val_v
      WHERE  x_location_id_tbl(i) IS NULL
      AND    p_location_tbl(i) IS NOT NULL
      AND    location_code = p_location_tbl(i)
      AND    nvl(ship_to_site_flag, 'N') = 'Y';
  ELSE -- p_location_type = 'BILL_TO'
    FORALL i IN 1..p_index_tbl.COUNT
      INSERT INTO po_session_gt(key, num1, num2)
      SELECT p_key,
             p_index_tbl(i),
             location_id
      FROM   po_locations_val_v
      WHERE  x_location_id_tbl(i) IS NULL
      AND    p_location_tbl(i) IS NOT NULL
      AND    location_code = p_location_tbl(i)
      AND    nvl(bill_to_site_flag, 'N') = 'Y';
  END IF;

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new location id', l_result_tbl(i));
    END IF;

    x_location_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END derive_location_id;

-------------------------------------------------------------------------
--Start of Comments
--Name: derive_terms_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive terms_id from payment_terms in batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_payment_terms_tbl
--    values of payment terms in current batch of records
--IN OUT:
--  x_terms_id_tbl
--    contains the derived result if original value is null
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_terms_id
(
  p_key                IN po_session_gt.key%TYPE,
  p_index_tbl          IN DBMS_SQL.NUMBER_TABLE,
  p_payment_terms_tbl  IN PO_TBL_VARCHAR100,
  x_terms_id_tbl       IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_terms_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'payment terms', p_payment_terms_tbl);
    PO_LOG.proc_begin(d_module, 'terms ids', x_terms_id_tbl);
  END IF;

  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           term_id
    FROM   ap_terms
    WHERE  x_terms_id_tbl(i) IS NULL
    AND    p_payment_terms_tbl(i) IS NOT NULL
    AND    name = p_payment_terms_tbl(i)
    AND    enabled_flag = 'Y'
    AND    TRUNC(sysdate) between TRUNC(nvl(start_date_active, sysdate))
           AND TRUNC(nvl(end_date_active, sysdate));

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new terms id', l_result_tbl(i));
    END IF;

    x_terms_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_terms_id;

-------------------------------------------------------------------------
--Start of Comments
--Name: derive_vendor_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive vendor_id from vendor_name or vendor_num
--  in batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_vendor_name_tbl
--    values of vendor name in current batch of records
--  p_vendor_num_tbl
--    values of vendor num in current batch of records
--IN OUT:
--  x_vendor_id_tbl
--    contains the derived result if original value is null
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_vendor_id
(
  p_key              IN po_session_gt.key%TYPE,
  p_index_tbl        IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_name_tbl  IN PO_TBL_VARCHAR2000,
  p_vendor_num_tbl   IN PO_TBL_VARCHAR30,
  x_vendor_id_tbl    IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_vendor_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;

  -- variable to hold the current index of the row processed
  l_index            NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'vendor names', p_vendor_name_tbl);
    PO_LOG.proc_begin(d_module, 'vendor nums', p_vendor_num_tbl);
    PO_LOG.proc_begin(d_module, 'vendor ids', x_vendor_id_tbl);
  END IF;

  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           vendor_id
    FROM   po_vendors
    WHERE  x_vendor_id_tbl(i) IS NULL
    AND    (p_vendor_name_tbl(i) IS NOT NULL OR p_vendor_num_tbl(i) IS NOT NULL)
    AND    (vendor_name = p_vendor_name_tbl(i) OR
            segment1 = p_vendor_num_tbl(i));

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- There can be 3 types of result from above derivation logic:
  -- 1. No vendor_id can be derived: fine, we leave the vendor_id as NULL;
  -- 2. One vendor_id can be derived: the value will be set back
  -- 3. Two vendor_ids are derived from vendor_name and vendor_num: we
  --    should leave vendor_id as null
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'new vendor id', l_result_tbl(i));
    END IF;

    IF (x_vendor_id_tbl(l_index) IS NULL) THEN
      x_vendor_id_tbl(l_index) := l_result_tbl(i);
    ELSE
      x_vendor_id_tbl(l_index) := NULL;
    END IF;
  END LOOP;

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
END derive_vendor_id;

-------------------------------------------------------------------------
--------------------- PRIVATE PROCEDURES --------------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--Start of Comments
--Name: derive_rate_type_code
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive rate_type_code from rate_type in batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_rate_type_tbl
--    values of rate type in current batch of records
--IN OUT:
--  x_rate_type_code_tbl
--    contains the derived result if original value is null
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_rate_type_code
(
  p_key                IN po_session_gt.key%TYPE,
  p_index_tbl          IN DBMS_SQL.NUMBER_TABLE,
  p_rate_type_tbl      IN PO_TBL_VARCHAR30,
  x_rate_type_code_tbl IN OUT NOCOPY PO_TBL_VARCHAR30
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_rate_type_code';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_VARCHAR30;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'rate type', p_rate_type_tbl);
    PO_LOG.proc_begin(d_module, 'rate type code', x_rate_type_code_tbl);
  END IF;

  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, char1)
    SELECT p_key,
           p_index_tbl(i),
           conversion_type
    FROM   gl_daily_conversion_types
    WHERE  x_rate_type_code_tbl(i) IS NULL
    AND    p_rate_type_tbl(i) IS NOT NULL
    AND    user_conversion_type = p_rate_type_tbl(i);

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new rate type code', l_result_tbl(i));
    END IF;

    x_rate_type_code_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_rate_type_code;

-------------------------------------------------------------------------
--Start of Comments
--Name: derive_agent_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive agent_id from agent_name in batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_agent_name_tbl
--    values of agent name in current batch of records
--IN OUT:
--  x_agent_id_tbl
--    contains the derived result if original value is null
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_agent_id
(
  p_key                IN po_session_gt.key%TYPE,
  p_index_tbl          IN DBMS_SQL.NUMBER_TABLE,
  p_agent_name_tbl     IN PO_TBL_VARCHAR2000,
  x_agent_id_tbl       IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_agent_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'agent name', p_agent_name_tbl);
    PO_LOG.proc_begin(d_module, 'agent id', x_agent_id_tbl);
  END IF;

  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           employee_id
    FROM   po_buyers_val_v
    WHERE  x_agent_id_tbl(i) IS NULL
    AND    p_agent_name_tbl(i) IS NOT NULL
    AND    full_name = p_agent_name_tbl(i);

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new agent id', l_result_tbl(i));
    END IF;

    x_agent_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_agent_id;

-------------------------------------------------------------------------
--Start of Comments
--Name: derive_vendor_site_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive vendor_site_id from vendor_site_code
--  and vendor_id in batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_vendor_id_tbl
--    values of vendor id in current batch of records
--  p_vendor_site_code_tbl
--    values of vendor site codes in current batch of records
--IN OUT:
--  x_vendor_site_id_tbl
--    contains the derived result if original value is null
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_vendor_site_id
(
  p_key                   IN po_session_gt.key%TYPE,
  p_index_tbl             IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_id_tbl         IN PO_TBL_NUMBER,
  p_vendor_site_code_tbl  IN PO_TBL_VARCHAR30,
  x_vendor_site_id_tbl    IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_vendor_site_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'vendor id', p_vendor_id_tbl);
    PO_LOG.proc_begin(d_module, 'site code', p_vendor_site_code_tbl);
    PO_LOG.proc_begin(d_module, 'site id', x_vendor_site_id_tbl);
  END IF;

  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           vendor_site_id
    FROM   po_supplier_sites_val_v
    WHERE  x_vendor_site_id_tbl(i) IS NULL
    AND    p_vendor_site_code_tbl(i) IS NOT NULL
    AND    p_vendor_id_tbl(i) IS NOT NULL
    AND    vendor_id = p_vendor_id_tbl(i)
    AND    vendor_site_code = p_vendor_site_code_tbl(i);

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new site id', l_result_tbl(i));
    END IF;

    x_vendor_site_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_vendor_site_id;

-------------------------------------------------------------------------
--Start of Comments
--Name: derive_vendor_contact_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive vendor_contac_id from vendor_contact
--  and vendor_site_id in batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_vendor_site_id_tbl
--    value of vendor site id in current batch mode
--  p_vendor_contact_tbl
--    values of vendor contact in current batch of records
--IN OUT:
--  x_vendor_contact_id_tbl
--    contains the derived result if original value is null
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_vendor_contact_id
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_site_id_tbl     IN PO_TBL_NUMBER,
  p_vendor_contact_tbl     IN PO_TBL_VARCHAR2000,
  x_vendor_contact_id_tbl  IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_vendor_contact_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'site id', p_vendor_site_id_tbl);
    PO_LOG.proc_begin(d_module, 'contact', p_vendor_contact_tbl);
    PO_LOG.proc_begin(d_module, 'contact id', x_vendor_contact_id_tbl);
  END IF;

  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           vendor_contact_id
    FROM   po_vendor_contacts
    WHERE  x_vendor_contact_id_tbl(i) IS NULL
    AND    p_vendor_contact_tbl(i) IS NOT NULL
    AND    p_vendor_site_id_tbl(i) IS NOT NULL
    AND    last_name||' '||first_name = p_vendor_contact_tbl(i)
    AND    vendor_site_id = p_vendor_site_id_tbl(i);

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new contact id', l_result_tbl(i));
    END IF;

    x_vendor_contact_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_vendor_contact_id;


-------------------------------------------------------------------------
--Start of Comments
--Name: derive_vendor_contact_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive vendor_contac_id from vendor_contact
--  and vendor_site_id in batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_vendor_site_id_tbl
--    value of vendor site id in current batch mode
--  p_vendor_contact_tbl
--    values of vendor contact in current batch of records
--IN OUT:
--  x_vendor_contact_id_tbl
--    contains the derived result if original value is null
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_style_id
(
  p_key                     IN po_session_gt.key%TYPE,
  p_index_tbl               IN DBMS_SQL.NUMBER_TABLE,
  p_style_display_name_tbl  IN PO_TBL_VARCHAR2000,
  x_style_id_tbl            IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_style_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'x_style_id_tbl', x_style_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_style_display_name_tbl', p_style_display_name_tbl);
  END IF;

  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           style_id
    FROM   po_doc_style_lines_tl pds
    WHERE  x_style_id_tbl(i) IS NULL AND
           pds.display_name = p_style_display_name_tbl(i) AND
           pds.LANGUAGE = USERENV('LANG');

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new style id', l_result_tbl(i));
    END IF;

    x_style_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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

END derive_style_id;

-------------------------------------------------------------------------
--Start of Comments
--Name: derive_from_header_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive from_header_id from from_rfq_num in batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_from_rfq_num_tbl
--    values of from quotation document number in current batch of records
--IN OUT:
--  x_from_header_id_tbl
--    contains the derived result if original value is null
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_from_header_id
(
  p_key                IN po_session_gt.key%TYPE,
  p_index_tbl          IN DBMS_SQL.NUMBER_TABLE,
  p_from_rfq_num_tbl   IN PO_TBL_VARCHAR30,
  x_from_header_id_tbl IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_from_header_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'from rfq num', p_from_rfq_num_tbl);
    PO_LOG.proc_begin(d_module, 'from header id', x_from_header_id_tbl);
  END IF;

  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           po_header_id
    FROM   po_headers
    WHERE  x_from_header_id_tbl(i) IS NULL
    AND    p_from_rfq_num_tbl(i) IS NOT NULL
    AND    segment1 = p_from_rfq_num_tbl(i)
    AND    type_lookup_code = 'RFQ'; -- PO_PDOI_CONSTANTS.g_DOC_TYPE_RFQ;

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new from header id', l_result_tbl(i));
    END IF;

    x_from_header_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_from_header_id;

-------------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_vendor
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to default attribute values from vendor specification
--  in a batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_vendor_id_tbl
--    values of vendor id in current batch of records
--IN OUT: None
--OUT:
--  x_invoice_currency_code_tbl
--    values of invoice currency code defined on vendor level
--  x_terms_id_tbl
--    values of terms id defined on vendor level
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_info_from_vendor
(
  p_key                       IN po_session_gt.key%TYPE,
  p_index_tbl                 IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_id_tbl             IN PO_TBL_NUMBER,
  x_invoice_currency_code_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_terms_id_tbl              OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_info_from_vendor';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold values read from vendor definition
  l_index_tbl             PO_TBL_NUMBER;
  l_currency_code_tbl     PO_TBL_VARCHAR30;
  l_terms_id_tbl          PO_TBL_NUMBER;

  -- variable to hold index of the current processing row
  l_index                 NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'vendor ids', p_vendor_id_tbl);
  END IF;

  -- Initialize OUT parameters

  -- <Bug 4546121: Supplier TCA conversion>
  -- The following columns are being obsoleted from PO_VENDORS level
  --x_fob_tbl                   := PO_TBL_VARCHAR30();
  --x_freight_carrier_tbl       := PO_TBL_VARCHAR30();
  --x_freight_term_tbl          := PO_TBL_VARCHAR30();
  --x_ship_to_loc_id_tbl        := PO_TBL_NUMBER();
  --x_bill_to_loc_id_tbl        := PO_TBL_NUMBER();

  x_invoice_currency_code_tbl := PO_TBL_VARCHAR30();
  x_terms_id_tbl              := PO_TBL_NUMBER();

  x_invoice_currency_code_tbl.EXTEND(p_index_tbl.COUNT);
  x_terms_id_tbl.EXTEND(p_index_tbl.COUNT);

  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(
      key, num1, char1, num2)
    SELECT p_key,
           p_index_tbl(i),
           invoice_currency_code,
           terms_id
    FROM   po_vendors
    WHERE  vendor_id = p_vendor_id_tbl(i);

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1, num2
  BULK COLLECT INTO
    l_index_tbl,
    l_currency_code_tbl,
    l_terms_id_tbl;

  d_position := 20;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_index_tbl.COUNT', l_index_tbl.COUNT);
  END IF;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new currency', l_currency_code_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new terms id', l_terms_id_tbl(i));
    END IF;

    x_invoice_currency_code_tbl(l_index) := l_currency_code_tbl(i);
    x_terms_id_tbl(l_index) := l_terms_id_tbl(i);
  END LOOP;

  d_position := 30;

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
END default_info_from_vendor;

-------------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_vendor_site
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to default attribute values from vendor site
--  specification in a batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_vendor_id_tbl
--    values of vendor id in current batch of records
--IN OUT:
--  x_vendor_site_id_tbl
--    if original value is empty, we try to default vendor site id
--    from vendor id first; then perform the default logic of other
--    attributes based on new value of vendor site id--
--OUT:
--  x_fob_tbl
--    values of fob defined on vendor site level
--  x_freight_carrier_tbl
--    values of freight carrier defined on site level
--  x_freight_term_tbl
--    values of freight term defined on site level
--  x_ship_to_loc_id_tbl
--    values of ship to location id defined on site level
--  x_bill_to_loc_id_tbl
--    values of bill to location id defined on site level
--  x_invoice_currency_code_tbl
--    values of invoice currency code defined on site level
--  x_terms_id_tbl
--    values of terms id defined on site level
--  x_shipping_control_tbl
--    values of shipping control defined on site level
--  x_pay_on_code_tbl
--    values of pay on code defined on site level
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_info_from_vendor_site
(
  p_key                       IN po_session_gt.key%TYPE,
  p_index_tbl                 IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_id_tbl             IN PO_TBL_NUMBER,
  x_vendor_site_id_tbl        IN OUT NOCOPY PO_TBL_NUMBER,
  x_fob_tbl                   OUT NOCOPY PO_TBL_VARCHAR30,
  x_freight_carrier_tbl       OUT NOCOPY PO_TBL_VARCHAR30,
  x_freight_term_tbl          OUT NOCOPY PO_TBL_VARCHAR30,
  x_ship_to_loc_id_tbl        OUT NOCOPY PO_TBL_NUMBER,
  x_bill_to_loc_id_tbl        OUT NOCOPY PO_TBL_NUMBER,
  x_invoice_currency_code_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_terms_id_tbl              OUT NOCOPY PO_TBL_NUMBER,
  x_shipping_control_tbl      OUT NOCOPY PO_TBL_VARCHAR30,
  x_pay_on_code_tbl           OUT NOCOPY PO_TBL_VARCHAR30
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_info_from_vendor_site';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold values read from vendor definition
  l_index_tbl             PO_TBL_NUMBER;
  l_vendor_site_id_tbl    PO_TBL_NUMBER;
  l_fob_tbl               PO_TBL_VARCHAR30;
  l_freight_carrier_tbl   PO_TBL_VARCHAR30;
  l_freight_term_tbl      PO_TBL_VARCHAR30;
  l_ship_to_loc_id_tbl    PO_TBL_NUMBER;
  l_bill_to_loc_id_tbl    PO_TBL_NUMBER;
  l_currency_code_tbl     PO_TBL_VARCHAR30;
  l_terms_id_tbl          PO_TBL_NUMBER;
  l_shipping_control_tbl  PO_TBL_VARCHAR30;
  l_pay_on_code_tbl       PO_TBL_VARCHAR30;

  -- variable to hold index of the current processing row
  l_index                 NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'vendor ids', p_vendor_id_tbl);
    PO_LOG.proc_begin(d_module, 'vendor site ids', x_vendor_site_id_tbl);
  END IF;

  x_fob_tbl                   := PO_TBL_VARCHAR30();
  x_freight_carrier_tbl       := PO_TBL_VARCHAR30();
  x_freight_term_tbl          := PO_TBL_VARCHAR30();
  x_ship_to_loc_id_tbl        := PO_TBL_NUMBER();
  x_bill_to_loc_id_tbl        := PO_TBL_NUMBER();
  x_invoice_currency_code_tbl := PO_TBL_VARCHAR30();
  x_terms_id_tbl              := PO_TBL_NUMBER();
  x_shipping_control_tbl      := PO_TBL_VARCHAR30();
  x_pay_on_code_tbl           := PO_TBL_VARCHAR30();

  x_fob_tbl.EXTEND(p_index_tbl.COUNT);
  x_freight_carrier_tbl.EXTEND(p_index_tbl.COUNT);
  x_freight_term_tbl.EXTEND(p_index_tbl.COUNT);
  x_ship_to_loc_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_bill_to_loc_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_invoice_currency_code_tbl.EXTEND(p_index_tbl.COUNT);
  x_terms_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_shipping_control_tbl.EXTEND(p_index_tbl.COUNT);
  x_pay_on_code_tbl.EXTEND(p_index_tbl.COUNT);

  d_position := 10;

  -- default vendor_site_id if it is empty
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2, num3)
    SELECT p_key,
           p_index_tbl(i),
           min(vendor_site_id),
           vendor_id
    FROM   po_vendor_sites
    WHERE  p_vendor_id_tbl(i) IS NOT NULL
    AND    x_vendor_site_id_tbl(i) IS NULL
    AND    vendor_id = p_vendor_id_tbl(i)
    AND    purchasing_site_flag = 'Y'
    AND    (sysdate) < nvl(inactive_date, TRUNC(sysdate + 1))
    AND    DECODE(PO_PDOI_PARAMS.g_request.document_type,
           PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION, 'N',
           NVL(rfq_only_site_flag, 'N')) <> 'Y'
    GROUP BY vendor_id
    HAVING count(vendor_site_id) = 1;

  d_position := 20;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_vendor_site_id_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new site id', l_vendor_site_id_tbl(i));
    END IF;

    x_vendor_site_id_tbl(l_index_tbl(i)) := l_vendor_site_id_tbl(i);
  END LOOP;

  d_position := 30;

  -- default other attributes from site definition
  -- to do (add char6 to gt table?)
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(
      key, num1, char1, char2, char3, num2, num3, char4, num4, char5, char6)
    SELECT p_key,
           p_index_tbl(i),
           fob_lookup_code,
           ship_via_lookup_code,
           freight_terms_lookup_code,
           ship_to_location_id,
           bill_to_location_id,
           invoice_currency_code,
           terms_id,
           shipping_control,
           Decode(pay_on_code,   --Bug 13461573
                 'RECEIPT','RECEIPT',
                 'RECEIPT_AND_USE','RECEIPT',
                  NULL ) pay_on_code
    FROM   po_vendor_sites_all
    WHERE  vendor_site_id = x_vendor_site_id_tbl(i);

  d_position := 40;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1, char2, char3, num2, num3, char4, num4, char5, char6
  BULK COLLECT INTO
    l_index_tbl,
    l_fob_tbl,
    l_freight_carrier_tbl,
    l_freight_term_tbl,
    l_ship_to_loc_id_tbl,
    l_bill_to_loc_id_tbl,
    l_currency_code_tbl,
    l_terms_id_tbl,
    l_shipping_control_tbl,
    l_pay_on_code_tbl;

  d_position := 50;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new fob', l_fob_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new freight carrier', l_freight_carrier_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new freight term', l_freight_term_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new ship_to loc id', l_ship_to_loc_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new bill_to loc id', l_bill_to_loc_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new currency', l_currency_code_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new terms id', l_terms_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new shipping control', l_shipping_control_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new pay on code', l_pay_on_code_tbl(i));
    END IF;

    x_fob_tbl(l_index) := l_fob_tbl(i);
    x_freight_carrier_tbl(l_index) := l_freight_carrier_tbl(i);
    x_freight_term_tbl(l_index) := l_freight_term_tbl(i);
    x_ship_to_loc_id_tbl(l_index) := l_ship_to_loc_id_tbl(i);
    x_bill_to_loc_id_tbl(l_index) := l_bill_to_loc_id_tbl(i);
    x_invoice_currency_code_tbl(l_index) := l_currency_code_tbl(i);
    x_terms_id_tbl(l_index) := l_terms_id_tbl(i);
    x_shipping_control_tbl(l_index) := l_shipping_control_tbl(i);
    x_pay_on_code_tbl(l_index) := l_pay_on_code_tbl(i);
  END LOOP;

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
END default_info_from_vendor_site;

-------------------------------------------------------------------------
--Start of Comments
--Name: default_vendor_contact
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to default vendor contact from vendor site
--  in a batch mode; Vendor contact can be defaulted only when
--  there is exactly one contact defined for the specific site
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_vendor_site_id_tbl
--    values of vendor site id in current batch of records
--IN OUT:
--  x_vendor_contact_id_tbl
--    values of vendor contact id in current batch of records;
--    defaulted results will be saved here
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_vendor_contact
(
  p_key                       IN po_session_gt.key%TYPE,
  p_index_tbl                 IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_site_id_tbl        IN PO_TBL_NUMBER,
  x_vendor_contact_id_tbl     IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_vendor_contact';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold defaulted results
  l_index_tbl               PO_TBL_NUMBER;
  l_result_tbl              PO_TBL_NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'site ids', p_vendor_site_id_tbl);
    PO_LOG.proc_begin(d_module, 'contact ids', x_vendor_contact_id_tbl);
  END IF;

  -- select contact id from vendor_site table if there is only
  -- one contact defined on that site
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2, num3)
    SELECT p_key,
           p_index_tbl(i),
           max(vendor_contact_id),
           vendor_site_id
    FROM   po_vendor_contacts
    WHERE  p_vendor_site_id_tbl(i) IS NOT NULL
    AND    x_vendor_contact_id_tbl(i) IS NULL
    AND    vendor_site_id = p_vendor_site_id_tbl(i)
    AND    TRUNC(sysdate) < NVL(inactive_date, TRUNC(sysdate + 1))
    GROUP BY vendor_site_id
    HAVING count(vendor_contact_id) = 1;

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new contact id', l_result_tbl(i));
    END IF;

    x_vendor_contact_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END default_vendor_contact;

-------------------------------------------------------------------------
--Start of Comments
--Name: default_dist_attributes
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to default distribution attributes for Blanket
--  if encumbrance is required for the document;
--  that is, x_headers.encumbrance_required_flag = 'Y'
--Parameters:
--IN: None
--IN OUT:
--  x_headers
--    variable to hold all the header attribute values in one batch;
--    derivation source and result are both placed inside the variable
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_dist_attributes
(
  x_headers IN OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_dist_attributes';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;


  FOR i IN 1..x_headers.rec_count
  LOOP
    d_position := 10;

    IF (x_headers.encumbrance_required_flag_tbl(i) = 'Y') THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'distribution row created for encumbrance');
        PO_LOG.stmt(d_module, d_position, 'index', i);
      END IF;

      -- default po_distribution_id
      x_headers.po_dist_id_tbl(i) := PO_PDOI_MAINPROC_UTL_PVT.get_next_dist_id;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'new dist id', x_headers.po_dist_id_tbl(i));
      END IF;

      -- default gl_encumbered_date and gl_encumbered_period
      IF (x_headers.gl_encumbered_date_tbl(i) IS NULL) THEN
        x_headers.gl_encumbered_date_tbl(i) := sysdate;
      END IF;

      d_position := 20;

      PO_PERIODS_SV.get_period_name
      (
        x_sob_id      => PO_PDOI_PARAMS.g_sys.sob_id,
        x_gl_date     => x_headers.gl_encumbered_date_tbl(i),
        x_gl_period   => x_headers.gl_encumbered_period_tbl(i)
      );

      d_position := 30;

      -- default budget account id
      IF (x_headers.budget_account_id_tbl(i) IS NULL) THEN
        PO_PDOI_DIST_PROCESS_PVT.derive_account_id
        ( p_account_number => x_headers.budget_account_tbl(i),
          p_chart_of_accounts_id => PO_PDOI_PARAMS.g_sys.coa_id,
          p_account_segment1 => x_headers.budget_account_segment1_tbl(i),
          p_account_segment2 => x_headers.budget_account_segment2_tbl(i),
          p_account_segment3 => x_headers.budget_account_segment3_tbl(i),
          p_account_segment4 => x_headers.budget_account_segment4_tbl(i),
          p_account_segment5 => x_headers.budget_account_segment5_tbl(i),
          p_account_segment6 => x_headers.budget_account_segment6_tbl(i),
          p_account_segment7 => x_headers.budget_account_segment7_tbl(i),
          p_account_segment8 => x_headers.budget_account_segment8_tbl(i),
          p_account_segment9 => x_headers.budget_account_segment9_tbl(i),
          p_account_segment10 => x_headers.budget_account_segment10_tbl(i),
          p_account_segment11 => x_headers.budget_account_segment11_tbl(i),
          p_account_segment12 => x_headers.budget_account_segment12_tbl(i),
          p_account_segment13 => x_headers.budget_account_segment13_tbl(i),
          p_account_segment14 => x_headers.budget_account_segment14_tbl(i),
          p_account_segment15 => x_headers.budget_account_segment15_tbl(i),
          p_account_segment16 => x_headers.budget_account_segment16_tbl(i),
          p_account_segment17 => x_headers.budget_account_segment17_tbl(i),
          p_account_segment18 => x_headers.budget_account_segment18_tbl(i),
          p_account_segment19 => x_headers.budget_account_segment19_tbl(i),
          p_account_segment20 => x_headers.budget_account_segment20_tbl(i),
          p_account_segment21 => x_headers.budget_account_segment21_tbl(i),
          p_account_segment22 => x_headers.budget_account_segment22_tbl(i),
          p_account_segment23 => x_headers.budget_account_segment23_tbl(i),
          p_account_segment24 => x_headers.budget_account_segment24_tbl(i),
          p_account_segment25 => x_headers.budget_account_segment25_tbl(i),
          p_account_segment26 => x_headers.budget_account_segment26_tbl(i),
          p_account_segment27 => x_headers.budget_account_segment27_tbl(i),
          p_account_segment28 => x_headers.budget_account_segment28_tbl(i),
          p_account_segment29 => x_headers.budget_account_segment29_tbl(i),
          p_account_segment30 => x_headers.budget_account_segment30_tbl(i),
          x_account_id => x_headers.budget_account_id_tbl(i)
        );

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'default budget account id',
                      x_headers.budget_account_id_tbl(i));
        END IF;
      END IF;
    END IF;
  END LOOP;

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
END default_dist_attributes;

-----------------------------------------------------------------------
--Start of Comments
--Name: populate_error_flag
--Function:
--  corresponding value in error_flag_tbl will be set with value FND_API.G_FALSE.
--Parameters:
--IN:
--x_results
--  The validation results that contains the errored line information.
--IN OUT:
--x_headers
--  The record contains the values to be validated.
--  If there is error(s) on any attribute of the price differential row,
--  corresponding value in error_flag_tbl will be set with value
--  FND_API.g_TRUE.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE populate_error_flag
(
  x_results       IN     po_validation_results_type,
  x_headers       IN OUT NOCOPY PO_PDOI_TYPES.headers_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'populate_error_flag';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index_tbl  DBMS_SQL.number_table;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  FOR i IN 1 .. x_headers.rec_count LOOP
      l_index_tbl(x_headers.intf_header_id_tbl(i)) := i;
  END LOOP;

  d_position := 10;

  FOR i IN 1 .. x_results.entity_id.COUNT LOOP
     IF x_results.result_type(i) = po_validations.c_result_type_failure THEN
        x_headers.error_flag_tbl(l_index_tbl(x_results.entity_id(i))) := FND_API.g_TRUE;
     END IF;
  END LOOP;

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
END populate_error_flag;

--bug17940049
--Procedure to default AME_TRANSACTION_TYPE and AME_APPROVAL_ID
PROCEDURE default_ame_attributes
(
  x_style_id             IN NUMBER,
  x_ame_approval_id      OUT NOCOPY NUMBER,
  x_ame_transaction_type OUT NOCOPY VARCHAR2
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_ame_attributes';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
	PO_LOG.stmt(d_module, d_position, 'AME_APPROVAL_ID: ', x_ame_approval_id);
	PO_LOG.stmt(d_module, d_position, 'AME_TRANSACTION_TYPE: ', x_ame_transaction_type);
  END IF;

  SELECT ame_transaction_type
  INTO 	x_ame_transaction_type
  FROM  po_doc_style_headers
  WHERE style_id = x_style_id;

  IF x_ame_transaction_type IS NOT NULL THEN

	select po_ame_approvals_s.nextval
	into x_ame_approval_id
	from dual;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.stmt(d_module, d_position, 'AME_APPROVAL_ID: ', x_ame_approval_id);
	PO_LOG.stmt(d_module, d_position, 'AME_TRANSACTION_TYPE: ', x_ame_transaction_type);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
	(
	  p_pkg_name => d_pkg_name,
	  p_procedure_name => d_api_name || '.' || d_position
	);
    RAISE;
END default_ame_attributes;

END PO_PDOI_HEADER_PROCESS_PVT;

/
