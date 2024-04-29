--------------------------------------------------------
--  DDL for Package Body PO_PDOI_LINE_LOC_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_LINE_LOC_PROCESS_PVT" AS
/* $Header: PO_PDOI_LINE_LOC_PROCESS_PVT.plb 120.26.12010000.50 2015/02/04 14:06:20 sbontala ship $ */

 d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_LINE_LOC_PROCESS_PVT');

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------
PROCEDURE derive_line_loc_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_po_line_id_tbl       IN PO_TBL_NUMBER,
  p_shipment_num_tbl     IN PO_TBL_NUMBER,
  x_line_loc_id_tbl      IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_receiving_routing_id
(
  p_key                      IN po_session_gt.key%TYPE,
  p_index_tbl                IN DBMS_SQL.NUMBER_TABLE,
  p_receiving_routing_tbl    IN PO_TBL_VARCHAR30,
  x_receiving_routing_id_tbl IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_tax_name
(
  p_key                      IN po_session_gt.key%TYPE,
  p_index_tbl                IN DBMS_SQL.NUMBER_TABLE,
  p_tax_code_id_tbl          IN PO_TBL_NUMBER,
  x_tax_name_tbl             IN OUT NOCOPY PO_TBL_VARCHAR30
);

PROCEDURE default_locs_for_spo
(
  p_key        IN po_session_gt.key%TYPE,
  p_index_tbl  IN DBMS_SQL.NUMBER_TABLE,
  x_line_locs  IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE default_locs_for_blanket
(
  p_key        IN po_session_gt.key%TYPE,
  p_index_tbl  IN DBMS_SQL.NUMBER_TABLE,
  x_line_locs  IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE default_locs_for_quotation
(
  p_key        IN po_session_gt.key%TYPE,
  p_index_tbl  IN DBMS_SQL.NUMBER_TABLE,
  x_line_locs  IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE default_inspect_required_flag
(
  p_key                          IN po_session_gt.key%TYPE,
  p_index_tbl                    IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl                  IN PO_TBL_NUMBER,
  x_inspection_required_flag_tbl IN OUT NOCOPY PO_TBL_VARCHAR1
);

-- <<PDOI Enhancement Bug#17063664 Start>
PROCEDURE default_info_from_req
(
  p_key                       IN po_session_gt.key%TYPE,
  p_index_tbl                 IN DBMS_SQL.NUMBER_TABLE,
  p_ln_req_line_id_tbl        IN PO_TBL_NUMBER,
  x_need_by_date_tbl          IN OUT NOCOPY PO_TBL_DATE,
  x_vmi_flag_tbl              IN OUT NOCOPY PO_TBL_VARCHAR1,
  x_drop_ship_flag_tbl        IN OUT NOCOPY PO_TBL_VARCHAR1,
  x_note_to_receiver_tbl      IN OUT NOCOPY PO_TBL_VARCHAR2000,
  x_wip_entity_id_tbl         IN OUT NOCOPY PO_TBL_NUMBER
);

-- <<PDOI Enhancement Bug#17063664 End>

-- <<Bug#17998869 Start>>
PROCEDURE default_lead_time
(
  p_key                       IN po_session_gt.key%TYPE,
  p_index_tbl                 IN DBMS_SQL.NUMBER_TABLE,
  p_ln_from_line_id_tbl       IN PO_TBL_NUMBER,
  x_lead_time_tbl             OUT NOCOPY PO_TBL_NUMBER
);
-- <<Bug#17998869 End>>

PROCEDURE default_close_tolerances
(
  p_key                          IN po_session_gt.key%TYPE,
  p_index_tbl                    IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl                  IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl           IN PO_TBL_NUMBER,
  p_line_type_id_tbl             IN PO_TBL_NUMBER,
  p_consigned_flag_tbl           IN PO_TBL_VARCHAR1,
  x_invoice_close_tolerance_tbl  IN OUT NOCOPY PO_TBL_NUMBER,
  x_receive_close_tolerance_tbl  IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE default_invoice_match_options
(
  p_key                          IN po_session_gt.key%TYPE,
  p_index_tbl                    IN DBMS_SQL.NUMBER_TABLE,
  p_line_loc_id_tbl              IN PO_TBL_NUMBER,
  p_item_id_tbl                  IN PO_TBL_NUMBER,
  p_vendor_id_tbl                IN PO_TBL_NUMBER,
  p_vendor_site_id_tbl           IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl           IN PO_TBL_NUMBER,
  p_consigned_flag_tbl           IN PO_TBL_VARCHAR1,
  p_outsourced_assembly_tbl      IN PO_TBL_NUMBER,
  p_shipment_type_tbl            IN PO_TBL_VARCHAR30,  --Bug#17712442: FIX
  x_match_option_tbl             IN OUT NOCOPY PO_TBL_VARCHAR30
);

PROCEDURE default_accrue_on_receipt_flag
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl                IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl         IN PO_TBL_NUMBER,
  p_receipt_required_flag_tbl  IN PO_TBL_VARCHAR1,
  p_consigned_flag_tbl         IN PO_TBL_VARCHAR1,
  p_txn_flow_header_id_tbl     IN PO_TBL_NUMBER,
  p_pcard_id_tbl               IN PO_TBL_NUMBER,
  p_shipment_type_tbl          IN PO_TBL_VARCHAR30,
  p_intf_line_loc_id_tbl       IN PO_TBL_NUMBER,  --Bug 17604686
  p_ln_req_line_id_tbl         IN PO_TBL_NUMBER,  --Bug 18652325
  x_accrue_on_receipt_flag_tbl IN OUT NOCOPY PO_TBL_VARCHAR1
);

PROCEDURE default_outsourced_assembly
(
  p_item_id_tbl                 IN  PO_TBL_NUMBER,
  p_ship_to_organization_id_tbl IN  PO_TBL_NUMBER,
  x_outsourced_assembly_tbl     IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE default_secondary_unit_of_meas
(
  p_key                          IN po_session_gt.key%TYPE,
  p_index_tbl                    IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl                  IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl           IN PO_TBL_NUMBER,
  x_secondary_unit_of_meas_tbl   IN OUT NOCOPY PO_TBL_VARCHAR30
);

PROCEDURE populate_error_flag
(
  x_results           IN     po_validation_results_type,
  x_line_locs         IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

--<<PDOI Enhancement Bug#17063664 START>>--
PROCEDURE assign_shipment_num
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

PROCEDURE match_shipments_info
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

PROCEDURE   reject_linelocs_on_shpmt_num
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

PROCEDURE   match_shipments_on_draft
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

PROCEDURE   match_shipments_on_txn
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

PROCEDURE   match_shipments_on_interface
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

PROCEDURE   split_line_locs
(p_line_locs         IN  PO_PDOI_TYPES.line_locs_rec_type,
 x_create_line_locs  IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
 x_update_line_locs  IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
 x_match_line_locs   IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
 );

 PROCEDURE copy_line_locs
(
  p_source_line_locs   IN PO_PDOI_TYPES.line_locs_rec_type,
  p_source_index_tbl   IN DBMS_SQL.NUMBER_TABLE,
  x_target_line_locs   IN OUT NOCOPY  PO_PDOI_TYPES.line_locs_rec_type
);
--<<PDOI Enhancement Bug#17063664 END>>--

-- Bug 18534140
PROCEDURE default_shipment_type
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_payment_type_tbl           IN PO_TBL_VARCHAR30,
  p_style_id_tbl               IN PO_TBL_NUMBER,
  x_shipment_type_tbl          IN OUT NOCOPY PO_TBL_VARCHAR30
);

------------------------------------------------------------------------
---------------------- PUBLIC PROCEDURES -------------------------------
------------------------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: open_line_locs
--Function:
--  Open cursor for query.
--  This query retrieves the line location attributes and related header
--  and line attributes for processing
--Parameters:
--IN:
--  p_max_intf_line_loc_id
--    maximal interface_line_location_id processed so far
--    The query will only retrieve the location records which have
--    not been processed
--IN OUT:
--  x_line_locs_csr
--  cursor variable to hold pointer to current processing row in the result
--  set returned by the query
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE open_line_locs
(
  p_max_intf_line_loc_id IN NUMBER,
  x_line_locs_csr        OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'open_line_locs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_max_intf_line_loc_id', p_max_intf_line_loc_id);
  END IF;

  OPEN x_line_locs_csr FOR
  SELECT /*+ NO_INDEX(DRAFT_LINES PO_LINES_DRAFT_N0) */
         intf_locs.interface_line_location_id,
         intf_locs.interface_line_id,
         intf_locs.interface_header_id,
         intf_locs.shipment_num,
         intf_locs.shipment_type,
         intf_locs.line_location_id,
         intf_locs.ship_to_organization_code,
         -- <<PDOI Enhancement Bug#17063664>>
         NVL(intf_locs.ship_to_organization_id, intf_lines.ship_to_organization_id), --bug19264990
         intf_locs.ship_to_location,
         -- <<PDOI Enhancement Bug#17063664>>
         NVL(intf_locs.ship_to_location_id, intf_lines.ship_to_location_id), --bug19264990
         intf_locs.payment_terms,
         intf_locs.terms_id,
         intf_locs.receiving_routing,
         intf_locs.receiving_routing_id,
         intf_locs.inspection_required_flag,
         intf_locs.receipt_required_flag,
         intf_locs.price_override,
         intf_locs.qty_rcv_tolerance,
         intf_locs.qty_rcv_exception_code,
         intf_locs.enforce_ship_to_location_code,
         intf_locs.allow_substitute_receipts_flag,
         intf_locs.days_early_receipt_allowed,
         intf_locs.days_late_receipt_allowed,
         intf_locs.receipt_days_exception_code,
         intf_locs.invoice_close_tolerance,
         intf_locs.receive_close_tolerance,
         intf_locs.accrue_on_receipt_flag,
         intf_locs.firm_flag,
         intf_locs.fob,
         intf_locs.freight_carrier,
         intf_locs.freight_terms,
         intf_locs.need_by_date,
         intf_locs.promised_date,
         NVL(intf_locs.quantity, intf_lines.quantity),
         NVL(intf_locs.amount, intf_lines.amount),  -- PDOI for Complex PO Project
         intf_locs.start_date,
         intf_locs.end_date,
         -- <<Bug#17998869 Start>>
         intf_locs.lead_time,
         -- <<Bug#17998869 End>>
         intf_locs.note_to_receiver,
         intf_locs.price_discount,
         intf_locs.tax_code_id,
         intf_locs.tax_name,
         intf_locs.secondary_quantity,
         intf_locs.secondary_unit_of_measure,
         NVL(intf_locs.preferred_grade, draft_lines.preferred_grade),
         intf_locs.unit_of_measure,
         intf_locs.value_basis,
         intf_locs.matching_basis,
	 intf_locs.payment_type,  -- PDOI for Complex PO Project


         -- attributes in txn table but not in intf table
         NULL,     -- outsourced_assembly - no such column in intf table
         NULL,     -- invoice match option - no such column in intf table
         --< Shared Proc 14223789 Start >
         NVL(intf_lines.transaction_flow_header_id, intf_locs.transaction_flow_header_id),
         --< Shared Proc 14223789 End >
         NULL,     -- tax_attribute_update_code

         --PDOI Enhancement Bug#17063664
         intf_locs.action,
         -- standard who columns
         intf_locs.last_updated_by,
         intf_locs.last_update_date,
         intf_locs.last_update_login,
         intf_locs.creation_date,
         intf_locs.created_by,
         intf_locs.request_id,
         intf_locs.program_application_id,
         intf_locs.program_id,
         intf_locs.program_update_date,
         -- attributes read from the line record
         --<<PDOI Enhancement Bug#17063664 START>>-
         intf_lines.requisition_line_id,
         intf_lines.vmi_flag,
         intf_lines.drop_ship_flag,
         intf_lines.consigned_flag,
         --<<PDOI Enhancement Bug#17063664 END>>-
	  NVL(intf_lines.line_loc_populated_flag, 'N'),  -- Bug 19528138
         draft_lines.po_line_id,
         draft_lines.item_id,
         --< Shared Proc 14223789 Start >
         draft_lines.category_id,
         --< Shared Proc 14223789 End >
         Nvl(intf_locs.value_basis,draft_lines.order_type_lookup_code), -- PDOI for Complex PO Project
         intf_lines.action,
         draft_lines.unit_price,
         draft_lines.quantity,  -- PDOI for Complex PO Project
         draft_lines.amount,    -- PDOI for Complex PO Project
         draft_lines.line_type_id,
         draft_lines.unit_meas_lookup_code,
         draft_lines.closed_code,
         draft_lines.purchase_basis,
         draft_lines.matching_basis,
         draft_lines.item_revision,
         draft_lines.expiration_date,
         draft_lines.government_context,
         draft_lines.closed_reason,
         draft_lines.closed_date,
         draft_lines.closed_by,
         draft_lines.from_header_id,
         draft_lines.from_line_id,
         draft_lines.price_break_lookup_code,  -- bug5016163
         --NVL(intf_locs.description,draft_lines.item_description),  -- PDOI for Complex PO Project
         Decode(pdsh.progress_payment_flag, 'Y', nvl(intf_Locs.description,draft_lines.item_description), intf_locs.description),  -- Bug#16751944,PDOI for Complex PO Project

         -- attributes read from the header record
         intf_headers.draft_id,
         intf_headers.po_header_id,
         --< Shared Proc 14223789 Start >
         intf_headers.DOCUMENT_TYPE_CODE,
         --< Shared Proc 14223789 End>
         NVL(draft_headers.ship_to_location_id, txn_headers.ship_to_location_id),
         NVL(draft_headers.vendor_id, txn_headers.vendor_id),
         NVL(draft_headers.vendor_site_id, txn_headers.vendor_site_id),
         NVL(draft_headers.terms_id, txn_headers.terms_id),
         NVL(draft_headers.fob_lookup_code, txn_headers.fob_lookup_code),
         NVL(draft_headers.ship_via_lookup_code, txn_headers.ship_via_lookup_code),
         NVL(draft_headers.freight_terms_lookup_code, txn_headers.freight_terms_lookup_code),
         draft_headers.approved_flag,	--<<Bug#14771449>>
         NVL(draft_headers.start_date, txn_headers.start_date),
         NVL(draft_headers.end_date, txn_headers.end_date),
         NVL(draft_headers.style_id, txn_headers.style_id),
         NVL(draft_headers.currency_code,txn_headers.currency_code),-- Bug 9294987
         NVL(draft_headers.pcard_id, txn_headers.pcard_id), --<PDOI Enhancement Bug#17063664>
         --<Start Bug#19528138>--
	 NVL(draft_headers.org_id,txn_headers.org_id),
	 NVL(draft_headers.type_lookup_code,txn_headers.type_lookup_code),
	 NVL(draft_headers.global_agreement_flag,txn_headers.global_agreement_flag),
	 NVL(draft_headers.rate,txn_headers.rate),
	 NVL(draft_headers.rate_type,txn_headers.rate_type),
	 NVL(draft_headers.rate_date,txn_headers.rate_date),
         --<End Bug#19528138>--
         -- set initial value for error_flag
         FND_API.g_FALSE
  FROM   po_line_locations_interface intf_locs,
         po_lines_interface intf_lines,
         po_headers_interface intf_headers,
         po_lines_draft_all draft_lines,
         po_headers_draft_all draft_headers,
         po_headers_all txn_headers,
         po_doc_style_headers pdsh   -- Bug#16751944
  WHERE  intf_locs.interface_line_id = intf_lines.interface_line_id
  AND    intf_lines.interface_header_id = intf_headers.interface_header_id
  AND    intf_lines.po_line_id = draft_lines.po_line_id
  AND    intf_headers.draft_id = draft_lines.draft_id
  AND    draft_lines.po_header_id = draft_headers.po_header_id(+)
  AND    draft_lines.draft_id = draft_headers.draft_id(+)
  AND    draft_lines.po_header_id = txn_headers.po_header_id(+)
  AND    intf_locs.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
  AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    intf_locs.interface_line_location_id > p_max_intf_line_loc_id
  AND    NVL(intf_lines.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
           <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED
  AND    intf_headers.style_id = pdsh.style_id(+) -- Bug#16751944
  ORDER BY 1;

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
END open_line_locs;

-----------------------------------------------------------------------
--Start of Comments
--Name: fetch_line_locs
--Function:
--  fetch results in batch
--Parameters:
--IN:
--IN OUT:
--x_line_locs_csr
--  cursor variable that hold pointers to currently processing row
--x_line_locs
--  record variable to hold line location info within a batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fetch_line_locs
(
  x_line_locs_csr IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_line_locs     OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'fetch_line_locs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  FETCH x_line_locs_csr BULK COLLECT INTO
    x_line_locs.intf_line_loc_id_tbl,
    x_line_locs.intf_line_id_tbl,
    x_line_locs.intf_header_id_tbl,
    x_line_locs.shipment_num_tbl,
    x_line_locs.shipment_type_tbl,
    x_line_locs.line_loc_id_tbl,
    x_line_locs.ship_to_org_code_tbl,
    x_line_locs.ship_to_org_id_tbl,
    x_line_locs.ship_to_loc_tbl,
    x_line_locs.ship_to_loc_id_tbl,
    x_line_locs.payment_terms_tbl,
    x_line_locs.terms_id_tbl,
    x_line_locs.receiving_routing_tbl,
    x_line_locs.receiving_routing_id_tbl,
    x_line_locs.inspection_required_flag_tbl,
    x_line_locs.receipt_required_flag_tbl,
    x_line_locs.price_override_tbl,
    x_line_locs.qty_rcv_tolerance_tbl,
    x_line_locs.qty_rcv_exception_code_tbl,
    x_line_locs.enforce_ship_to_loc_code_tbl,
    x_line_locs.allow_sub_receipts_flag_tbl,
    x_line_locs.days_early_receipt_allowed_tbl,
    x_line_locs.days_late_receipt_allowed_tbl,
    x_line_locs.receipt_days_except_code_tbl,
    x_line_locs.invoice_close_tolerance_tbl,
    x_line_locs.receive_close_tolerance_tbl,
    x_line_locs.accrue_on_receipt_flag_tbl,
    x_line_locs.firm_flag_tbl,
    x_line_locs.fob_tbl,
    x_line_locs.freight_carrier_tbl,
    x_line_locs.freight_term_tbl,
    x_line_locs.need_by_date_tbl,
    x_line_locs.promised_date_tbl,
    x_line_locs.quantity_tbl,
    x_line_locs.amount_tbl,  -- PDOI for Complex PO Project
    x_line_locs.start_date_tbl,
    x_line_locs.end_date_tbl,
    -- <<Bug#17998869 Start>>
    x_line_locs.lead_time_tbl,
    -- <<Bug#17998869 End>>
    x_line_locs.note_to_receiver_tbl,
    x_line_locs.price_discount_tbl,
    x_line_locs.tax_code_id_tbl,
    x_line_locs.tax_name_tbl,
    x_line_locs.secondary_quantity_tbl,
    x_line_locs.secondary_unit_of_meas_tbl,
    x_line_locs.preferred_grade_tbl,
    x_line_locs.unit_of_measure_tbl,
    x_line_locs.value_basis_tbl,
    x_line_locs.matching_basis_tbl,
    x_line_locs.payment_type_tbl,  -- PDOI for Complex PO Project


    -- attributes exist in txn table but not in intf table
    x_line_locs.outsourced_assembly_tbl,
    x_line_locs.match_option_tbl,
    x_line_locs.txn_flow_header_id_tbl,
    x_line_locs.tax_attribute_update_code_tbl,
      -- PDOI Enhancement Bug#17063664
    x_line_locs.action_tbl,

    -- standard who columns
    x_line_locs.last_updated_by_tbl,
    x_line_locs.last_update_date_tbl,
    x_line_locs.last_update_login_tbl,
    x_line_locs.creation_date_tbl,
    x_line_locs.created_by_tbl,
    x_line_locs.request_id_tbl,
    x_line_locs.program_application_id_tbl,
    x_line_locs.program_id_tbl,
    x_line_locs.program_update_date_tbl,

    -- attributes read from the line record
   --<<PDOI Enhancement Bug#17063664 START>>-
    x_line_locs.ln_req_line_id_tbl,
    x_line_locs.vmi_flag_tbl,
    x_line_locs.drop_ship_flag_tbl,
    x_line_locs.consigned_flag_tbl,
   --<<PDOI Enhancement Bug#17063664 END>>-
    x_line_locs.ln_line_loc_pop_flag_tbl, --Bug#19528138
    x_line_locs.ln_po_line_id_tbl,
    x_line_locs.ln_item_id_tbl,

    --< Shared Proc 14223789 Start >
    x_line_locs.ln_item_category_id_tbl,
    --< Shared Proc 14223789 End >

    x_line_locs.ln_order_type_lookup_code_tbl,
    x_line_locs.ln_action_tbl,
    x_line_locs.ln_unit_price_tbl,
    x_line_locs.ln_quantity_tbl,  -- PDOI for Complex PO Project
    x_line_locs.ln_amount_tbl,    -- PDOI for Complex PO Project
    x_line_locs.ln_line_type_id_tbl,
    x_line_locs.ln_unit_of_measure_tbl,
    x_line_locs.ln_closed_code_tbl,
    x_line_locs.ln_purchase_basis_tbl,
    x_line_locs.ln_matching_basis_tbl,
    x_line_locs.ln_item_revision_tbl,
    x_line_locs.ln_expiration_date_tbl,
    x_line_locs.ln_government_context_tbl,
    x_line_locs.ln_closed_reason_tbl,
    x_line_locs.ln_closed_date_tbl,
    x_line_locs.ln_closed_by_tbl,
    x_line_locs.ln_from_header_id_tbl,
    x_line_locs.ln_from_line_id_tbl,
    x_line_locs.ln_price_break_lookup_code_tbl,
    x_line_locs.ln_item_desc_tbl,  -- PDOI for Complex PO Project

    -- attributes read from the header record
    x_line_locs.draft_id_tbl,
    x_line_locs.hd_po_header_id_tbl,
    --< Shared Proc 14223789 Start >
    x_line_locs.hd_doc_type_tbl,
    --< Shared Proc 14223789 End >
    x_line_locs.hd_ship_to_loc_id_tbl,
    x_line_locs.hd_vendor_id_tbl,
    x_line_locs.hd_vendor_site_id_tbl,
    x_line_locs.hd_terms_id_tbl,
    x_line_locs.hd_fob_tbl,
    x_line_locs.hd_freight_carrier_tbl,
    x_line_locs.hd_freight_term_tbl,
    x_line_locs.hd_approved_flag_tbl,
    x_line_locs.hd_effective_date_tbl,
    x_line_locs.hd_expiration_date_tbl,
    x_line_locs.hd_style_id_tbl,
    x_line_locs.hd_currency_code_tbl,	 -- Bug 9294987
    x_line_locs.hd_pcard_id_tbl,  --<PDOI Enhancement Bug#17063664>
   --<Start Bug#19528138>--
    x_line_locs.hd_org_id_tbl,
    x_line_locs.hd_type_lookup_code_tbl,
    x_line_locs.hd_global_agreement_flag_tbl,
    x_line_locs.hd_rate_tbl,
    x_line_locs.hd_rate_type_tbl,
    x_line_locs.hd_rate_date_tbl,
   --<End Bug#19528138>--
    -- set initial value for error_flag
    x_line_locs.error_flag_tbl
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
END fetch_line_locs;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_line_locs
--Function:
--  perform derive logic on line location records read in one batch;
--  derivation errors are handled all together after the
--  derivation logic
--  The derived attributes include:
--    line_location_id,  ship_to_organization_id,
--    ship_to_location_id,  terms_id
--    receiving_routing_id
--Parameters:
--IN:
--IN OUT:
--x_line_locs
--  variable to hold all the line location attribute values in one batch;
--  derivation source and result are both placed inside the variable
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_line_locs
(
  x_line_locs     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_line_locs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- key of temp table used to identify the derived result
  l_key po_session_gt.key%TYPE;

  -- table used to save the index of the each row
  l_index_tbl DBMS_SQL.NUMBER_TABLE;

  --< Shared Proc 14223789 Start >
  l_is_ship_to_org_valid     BOOLEAN;
  l_in_current_sob           BOOLEAN;
  l_check_txn_flow           BOOLEAN;
  l_return_status            VARCHAR2(1);
  --< Shared Proc 14223789 End >

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'count', x_line_locs.rec_count);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_DERIVE);

  -- assign a new key
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize table containing the row number
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size     => x_line_locs.rec_count,
    x_num_list => l_index_tbl
  );

  d_position := 10;

  -- derive line_location_id from shipment_num
  derive_line_loc_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_po_line_id_tbl       => x_line_locs.ln_po_line_id_tbl,
    p_shipment_num_tbl     => x_line_locs.shipment_num_tbl,
    x_line_loc_id_tbl      => x_line_locs.line_loc_id_tbl
  );

  d_position := 20;

  -- derive ship_to_organization_id from ship_to_organization_code
  derive_ship_to_org_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_ship_to_org_code_tbl => x_line_locs.ship_to_org_code_tbl,
    x_ship_to_org_id_tbl   => x_line_locs.ship_to_org_id_tbl
  );

  d_position := 30;

  -- derive ship_to_location_id from ship_to_location_code
  PO_PDOI_HEADER_PROCESS_PVT.derive_location_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_location_tbl         => x_line_locs.ship_to_loc_tbl,
    p_location_type        => 'SHIP_TO',   --bug6963861
    x_location_id_tbl      => x_line_locs.ship_to_loc_id_tbl
  );

  d_position := 40;

  -- derive terms_id from payment_terms
  PO_PDOI_HEADER_PROCESS_PVT.derive_terms_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_payment_terms_tbl    => x_line_locs.payment_terms_tbl,
    x_terms_id_tbl         => x_line_locs.terms_id_tbl
  );

  d_position := 50;

  -- derive receving_id from receiving_routing
  derive_receiving_routing_id
  (
    p_key                      => l_key,
    p_index_tbl                => l_index_tbl,
    p_receiving_routing_tbl    => x_line_locs.receiving_routing_tbl,
    x_receiving_routing_id_tbl => x_line_locs.receiving_routing_id_tbl
  );

  d_position := 60;

  -- derive tax_name from tax_code_id
  IF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
    derive_tax_name
    (
      p_key                      => l_key,
      p_index_tbl                => l_index_tbl,
      p_tax_code_id_tbl          => x_line_locs.tax_code_id_tbl,
      x_tax_name_tbl             => x_line_locs.tax_name_tbl
    );
  END IF;

  d_position := 70;

  -- handle derivation errors
  FOR i IN 1..x_line_locs.rec_count
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
    END IF;

    -- check derivation error on ship_to_organziation_id
    IF (x_line_locs.ship_to_org_code_tbl(i) IS NOT NULL AND
        x_line_locs.ship_to_org_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'ship_to org id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'ship_to org', x_line_locs.ship_to_org_code_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_line_locs.intf_header_id_tbl(i),
        p_interface_line_id    => x_line_locs.intf_line_id_tbl(i),
        p_interface_line_location_id => x_line_locs.intf_line_loc_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
        p_column_name          => 'SHIP_TO_ORGANIZATION_ID',
        p_column_value         => x_line_locs.ship_to_org_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'SHIP_TO_ORGANIZATION_CODE',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_line_locs.ship_to_org_code_tbl(i),
        p_validation_id        => PO_VAL_CONSTANTS.c_ship_to_org_code_derv,
        p_line_locs            => x_line_locs
      );

      x_line_locs.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- check derivation error for ship_to_location_id
    IF (x_line_locs.ship_to_loc_tbl(i) IS NOT NULL AND
        x_line_locs.ship_to_loc_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'ship_to loc id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'ship_to loc', x_line_locs.ship_to_loc_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_line_locs.intf_header_id_tbl(i),
        p_interface_line_id    => x_line_locs.intf_line_id_tbl(i),
        p_interface_line_location_id => x_line_locs.intf_line_loc_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
        p_column_name          => 'SHIP_TO_LOCATION_ID',
        p_column_value         => x_line_locs.ship_to_loc_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'SHIP_TO_LOCATION_CODE',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_line_locs.ship_to_loc_tbl(i),
        p_validation_id        => PO_VAL_CONSTANTS.c_ship_to_location_derv,
        p_line_locs            => x_line_locs
      );

      x_line_locs.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- check derivation error for terms_id
    IF (x_line_locs.payment_terms_tbl(i) IS NOT NULL AND
        x_line_locs.terms_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'terms id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'payment terms', x_line_locs.payment_terms_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_line_locs.intf_header_id_tbl(i),
        p_interface_line_id    => x_line_locs.intf_line_id_tbl(i),
        p_interface_line_location_id => x_line_locs.intf_line_loc_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
        p_column_name          => 'TERMS_ID',
        p_column_value         => x_line_locs.terms_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'PAYMENT_TERMS',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_line_locs.payment_terms_tbl(i)
      );

      x_line_locs.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- check derivation error for receiving_routing_id
    IF (x_line_locs.receiving_routing_tbl(i) IS NOT NULL AND
        x_line_locs.receiving_routing_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'routing id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'routing', x_line_locs.receiving_routing_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_line_locs.intf_header_id_tbl(i),
        p_interface_line_id    => x_line_locs.intf_line_id_tbl(i),
        p_interface_line_location_id => x_line_locs.intf_line_loc_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
        p_column_name          => 'RECEIVING_ROUTING_ID',
        p_column_value         => x_line_locs.receiving_routing_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'RECEIVING_ROUTING',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_line_locs.receiving_routing_tbl(i)
      );

      x_line_locs.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- check derivation error for tax_name
    IF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
      IF (x_line_locs.tax_code_id_tbl(i) IS NOT NULL AND
          x_line_locs.tax_name_tbl(i) IS NULL) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'tax name derivation failed');
          PO_LOG.stmt(d_module, d_position, 'tax code id',
		              x_line_locs.tax_code_id_tbl(i));
        END IF;

        PO_PDOI_ERR_UTL.add_fatal_error
        (
          p_interface_header_id  => x_line_locs.intf_header_id_tbl(i),
          p_interface_line_id    => x_line_locs.intf_line_id_tbl(i),
          p_interface_line_location_id => x_line_locs.intf_line_loc_id_tbl(i),
          p_error_message_name   => 'PO_PDOI_DERV_ERROR',
          p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
          p_column_name          => 'TAX_NAME',
          p_column_value         => x_line_locs.tax_name_tbl(i),
          p_token1_name          => 'COLUMN_NAME',
          p_token1_value         => 'TAX_CODE_ID',
          p_token2_name          => 'VALUE',
          p_token2_value         => x_line_locs.tax_code_id_tbl(i)
        );

        x_line_locs.error_flag_tbl(i) := FND_API.g_TRUE;
      END IF;
    END IF;
  END LOOP;

  --< Shared Proc 14223789 Start >
  d_position := 80;
  FOR i IN 1..x_line_locs.rec_count LOOP
    IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'x_line_locs.hd_doc_type_tbl(i)',
                    x_line_locs.hd_doc_type_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'x_line_locs.ship_to_org_id_tbl(i)',
                    x_line_locs.ship_to_org_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'x_line_locs.txn_flow_header_id_tbl(i)',
                    x_line_locs.txn_flow_header_id_tbl(i));
    END IF;

    IF (x_line_locs.hd_doc_type_tbl(i) = 'STANDARD') AND
       (x_line_locs.ship_to_org_id_tbl(i) IS NOT NULL) AND
       (x_line_locs.txn_flow_header_id_tbl(i) IS NULL)
    THEN
       -- Validate ship-to Org, which gets txn flow header if one exists
       PO_SHARED_PROC_PVT.validate_ship_to_org
            (p_init_msg_list              => FND_API.g_false,
             x_return_status              => l_return_status,
             p_ship_to_org_id             => x_line_locs.ship_to_org_id_tbl(i),
             p_item_category_id           => x_line_locs.ln_item_category_id_tbl(i),
             p_item_id                    => x_line_locs.ln_item_id_tbl(i),
             x_is_valid                   => l_is_ship_to_org_valid,
             x_in_current_sob             => l_in_current_sob,
             x_check_txn_flow             => l_check_txn_flow,
             x_transaction_flow_header_id => x_line_locs.txn_flow_header_id_tbl(i));
      IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'x_line_locs.txn_flow_header_id_tbl(i)',
                      x_line_locs.txn_flow_header_id_tbl(i));
      END IF;

       IF (l_return_status <> FND_API.g_ret_sts_success) OR
          (NOT l_is_ship_to_org_valid)
       THEN
           -- The ship-to org is not valid
           PO_PDOI_ERR_UTL.add_fatal_error
              (p_interface_header_id  => x_line_locs.intf_header_id_tbl(i),
               p_interface_line_id    => x_line_locs.intf_line_id_tbl(i),
               p_interface_line_location_id => x_line_locs.intf_line_loc_id_tbl(i),
               p_error_message_name   => 'PO_PDOI_TXN_FLOW_API_ERROR ',
               p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
               p_column_name          => 'SHIP_TO_ORGANIZATION_ID ',
               p_column_value         => x_line_locs.ship_to_org_id_tbl(i),
               p_token1_name          => 'COLUMN_NAME',
               p_token1_value         => 'SHIP_TO_ORGANIZATION_CODE ',
               p_token2_name          => 'VALUE',
               p_token2_value         => x_line_locs.ship_to_org_code_tbl(i),
               p_validation_id        => PO_VAL_CONSTANTS.c_transaction_flow_derv,
               p_line_locs            => x_line_locs);

          x_line_locs.error_flag_tbl(i) := FND_API.g_TRUE;
       END IF;

    END IF; --<if STANDARD and x_ship_to_org...>
  END LOOP;
  --< Shared Proc 14223789 End >

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_DERIVE);

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
END derive_line_locs;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_line_locs
--Function:
--  perform default logic on line location records read in one batch;
--Parameters:
--IN:
--IN OUT:
--x_line_locs
--  variable to hold all the line location attribute values in one batch;
--  default result are saved inside the variable
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_line_locs
(
  x_line_locs     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_line_locs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- key of temp table used to identify the derived result
  l_key po_session_gt.key%TYPE;

  -- table used to save the index of the each row
  l_index_tbl DBMS_SQL.NUMBER_TABLE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_DEFAULT);

  -- pick a new key from temp table which will be used in all default logic
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize table containing the row number
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size      => x_line_locs.rec_count,
    x_num_list  => l_index_tbl
  );

  -- handle default logic based on document types
  IF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN

    d_position := 10;

    default_locs_for_spo
    (
      p_key        => l_key,
      p_index_tbl  => l_index_tbl,
      x_line_locs  => x_line_locs
    );
  ELSIF (PO_PDOI_PARAMS.g_request.document_type =
         PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN

    d_position := 20;

    default_locs_for_blanket
    (
      p_key        => l_key,
      p_index_tbl  => l_index_tbl,
      x_line_locs  => x_line_locs
    );
  ELSIF (PO_PDOI_PARAMS.g_request.document_type =
         PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN

    d_position := 30;

    default_locs_for_quotation
    (
      p_key        => l_key,
      p_index_tbl  => l_index_tbl,
      x_line_locs  => x_line_locs
    );
  END IF;

  d_position := 40;

  -- call utility method to default standard who columns
  PO_PDOI_MAINPROC_UTL_PVT.default_who_columns
  (
    x_last_update_date_tbl       => x_line_locs.last_update_date_tbl,
    x_last_updated_by_tbl        => x_line_locs.last_updated_by_tbl,
    x_last_update_login_tbl      => x_line_locs.last_update_login_tbl,
    x_creation_date_tbl          => x_line_locs.creation_date_tbl,
    x_created_by_tbl             => x_line_locs.created_by_tbl,
    x_request_id_tbl             => x_line_locs.request_id_tbl,
    x_program_application_id_tbl => x_line_locs.program_application_id_tbl,
    x_program_id_tbl             => x_line_locs.program_id_tbl,
    x_program_update_date_tbl    => x_line_locs.program_update_date_tbl
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_DEFAULT);

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
END default_line_locs;

-- <<PDOI Enhancement Bug#17063664 Start>>

-----------------------------------------------------------------------
--Start of Comments
--Name: process_conversions
--Function:
--  perform quantity conversions and update the attributes;
--Parameters:
--IN:
--IN OUT:
--x_line_locs
--  variable to hold all the line location attribute values in one batch;
--  default result are saved inside the variable
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_conversions
(
  x_line_locs     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_conversions';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- key of temp table used to identify the derived result
  l_key po_session_gt.key%TYPE;

  -- table used to save the index of the each row
  l_index_tbl                  DBMS_SQL.NUMBER_TABLE;
  l_processed_index_tbl        PO_TBL_NUMBER;
  l_index                      NUMBER;

  l_intf_uom_tbl               PO_TBL_VARCHAR30;
  l_req_uom_tbl                PO_TBL_VARCHAR30;
  l_secondary_uom_tbl          PO_TBL_VARCHAR30;
  l_to_quantity_tbl            PO_TBL_NUMBER;
  l_secondary_quantity_tbl     PO_TBL_NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_DEFAULT);

  -- pick a new key from temp table which will be used in all default logic
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize table containing the row number
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size      => x_line_locs.rec_count,
    x_num_list  => l_index_tbl
  );

  d_position := 20;

  l_intf_uom_tbl            := PO_TBL_VARCHAR30();
  l_req_uom_tbl             := PO_TBL_VARCHAR30();
  l_secondary_uom_tbl       := PO_TBL_VARCHAR30();
  l_to_quantity_tbl         := PO_TBL_NUMBER();
  l_secondary_quantity_tbl  := PO_TBL_NUMBER();

  l_intf_uom_tbl.EXTEND(x_line_locs.rec_count);
  l_req_uom_tbl.EXTEND(x_line_locs.rec_count);
  l_secondary_uom_tbl.EXTEND(x_line_locs.rec_count);
  l_to_quantity_tbl.EXTEND(x_line_locs.rec_count);
  l_secondary_quantity_tbl.EXTEND(x_line_locs.rec_count);

  -- Intf UOM and Req UOM 's are diff
  -- retrieve the values from database
  FORALL i IN 1..x_line_locs.rec_count
  INSERT INTO po_session_gt(key, num1, char1, char2)
  SELECT l_key,
         l_index_tbl(i),
         x_line_locs.unit_of_measure_tbl(i),
         prl.unit_meas_lookup_code
  FROM po_requisition_lines_all prl
  WHERE x_line_locs.ln_req_line_id_tbl(i) IS NOT NULL
    AND prl.requisition_line_id = x_line_locs.ln_req_line_id_tbl(i)
    AND prl.unit_meas_lookup_code <> x_line_locs.unit_of_measure_tbl(i);

  IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'No of records identified: ', SQL%ROWCOUNT);
  END IF;

  -- get result from temp table
  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, char1, char2
  BULK COLLECT INTO l_processed_index_tbl, l_intf_uom_tbl, l_req_uom_tbl;

  d_position := 30;

  FOR i IN 1..l_processed_index_tbl.COUNT
  LOOP

    l_index := l_processed_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Interface UOM: ', l_intf_uom_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'Requisition UOM: ', l_req_uom_tbl(i));
    END IF;

    d_position := 40;

    BEGIN
      PO_UOM_S.uom_convert (x_line_locs.quantity_tbl(l_index),
                            l_req_uom_tbl(i),
                            x_line_locs.ln_item_id_tbl(l_index),
                            l_intf_uom_tbl(i),
                            l_to_quantity_tbl(l_index));

      EXCEPTION
        WHEN OTHERS THEN
        PO_PDOI_ERR_UTL.add_fatal_error
        (
          p_interface_header_id  => x_line_locs.intf_header_id_tbl(l_index),
          p_interface_line_id    => x_line_locs.intf_line_id_tbl(l_index),
          p_error_message_name   => 'PO_PDOI_UOM_CONVERSION_FAIL',
          p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
          p_column_name          => 'QUANTITY',
          p_column_value         => x_line_locs.quantity_tbl(l_index),
          p_token1_name          => 'REQ_UOM',
          p_token1_value         => l_req_uom_tbl(i),
          p_token2_name          => 'PO_UOM',
          p_token2_value         => l_intf_uom_tbl(i)
        );

    END;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Quantity after conversion: ', l_to_quantity_tbl(i));
    END IF;

    x_line_locs.quantity_tbl(l_index) :=
       NVL(l_to_quantity_tbl(l_index), x_line_locs.quantity_tbl(l_index));

  END LOOP;

  d_position := 50;

  -- Update the converted quantity in po_line_locations_interface table
  FORALL i IN 1..x_line_locs.rec_count
    UPDATE po_line_locations_interface
    SET quantity = x_line_locs.quantity_tbl(i)
    WHERE x_line_locs.ln_req_line_id_tbl(i) IS NOT NULL
      AND interface_line_location_id = x_line_locs.intf_line_loc_id_tbl(i);

  d_position := 60;

  -- derive secondary quantity if secondary UOM is not NULL
  -- delete the previous record in l_processed_index_tbl
  l_processed_index_tbl.DELETE;

  -- Fetch all the line loc attributes which are having secondary UOM and
  --  which is not equal to the primary UOM
  FORALL i IN 1..x_line_locs.rec_count
  INSERT INTO po_session_gt(key, num1, char1)
  SELECT l_key,
         l_index_tbl(i),
         x_line_locs.secondary_unit_of_meas_tbl(i)
  FROM DUAL
  WHERE x_line_locs.secondary_unit_of_meas_tbl(i) IS NOT NULL
    AND x_line_locs.unit_of_measure_tbl(i) <>
          x_line_locs.secondary_unit_of_meas_tbl(i);

  IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'No of records identified: ', SQL%ROWCOUNT);
  END IF;

  -- get result from temp table
  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, char1 BULK COLLECT INTO l_processed_index_tbl, l_secondary_uom_tbl;

  FOR i IN 1..l_processed_index_tbl.COUNT
  LOOP

    l_index := l_processed_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Secondary UOM: ', l_secondary_uom_tbl(i));
    END IF;

    d_position := 70;

    BEGIN

      PO_UOM_S.uom_convert (x_line_locs.quantity_tbl(l_index),
                            x_line_locs.unit_of_measure_tbl(l_index),
                            x_line_locs.ln_item_id_tbl(l_index),
                            l_secondary_uom_tbl(i),
                            l_secondary_quantity_tbl(l_index));

      EXCEPTION
        WHEN OTHERS THEN
        PO_PDOI_ERR_UTL.add_fatal_error
        (
          p_interface_header_id  => x_line_locs.intf_header_id_tbl(l_index),
          p_interface_line_id    => x_line_locs.intf_line_id_tbl(l_index),
          p_error_message_name   => 'PO_PDOI_UOM_CONVERSION_FAIL',
          p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
          p_column_name          => 'SECONDARY_QUANTITY',
          p_column_value         => x_line_locs.secondary_quantity_tbl(l_index),
          p_token1_name          => 'PO_UOM',
          p_token1_value         => x_line_locs.unit_of_measure_tbl(l_index),
          p_token2_name          => 'SECONDARY_UOM',
          p_token2_value         => l_secondary_uom_tbl(i)
        );

    END;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Secondary Quantity after conversion: ', l_secondary_quantity_tbl(i));
    END IF;

    -- bug 19286258, if secondary quantity is existing in interface table, then does not set the recalculated value.
    if (x_line_locs.secondary_quantity_tbl(l_index)) <= 0 then
      x_line_locs.secondary_quantity_tbl(l_index) :=
          NVL(l_secondary_quantity_tbl(l_index), x_line_locs.secondary_quantity_tbl(l_index));
    end if;

  END LOOP;

  d_position := 80;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_DEFAULT);

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
END process_conversions;

-- <<PDOI Enhancement Bug#17063664 End>>

-----------------------------------------------------------------------
--Start of Comments
--Name: validate_line_locs
--Function:
--  validate line location attributes read within a batch
--Parameters:
--IN:
--IN OUT:
--x_line_locs
--  The record contains the values to be validated.
--  If there is error(s) on any attribute of the location row,
--  corresponding value in error_flag_tbl will be set with value
--  FND_API.g_TRUE.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE validate_line_locs
(
  x_line_locs     IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'validate_line_locs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_line_locations       PO_LINE_LOCATIONS_VAL_TYPE := PO_LINE_LOCATIONS_VAL_TYPE();
  l_parameter_name_tbl   PO_TBL_VARCHAR2000 := PO_TBL_VARCHAR2000();
  l_parameter_value_tbl  PO_TBL_VARCHAR2000 := PO_TBL_VARCHAR2000();
  l_result_type          VARCHAR2(30);
  l_results              po_validation_results_type;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_VALIDATE);

  l_line_locations.interface_id                    := x_line_locs.intf_line_loc_id_tbl;
  l_line_locations.purchase_basis                  := x_line_locs.ln_purchase_basis_tbl;
  l_line_locations.need_by_date                    := x_line_locs.need_by_date_tbl;
  l_line_locations.promised_date                   := x_line_locs.promised_date_tbl;
  l_line_locations.shipment_type                   := x_line_locs.shipment_type_tbl;
  l_line_locations.shipment_num                    := x_line_locs.shipment_num_tbl;
  l_line_locations.po_header_id                    := x_line_locs.hd_po_header_id_tbl;
  l_line_locations.po_line_id                      := x_line_locs.ln_po_line_id_tbl;
  l_line_locations.terms_id                        := x_line_locs.terms_id_tbl;
  l_line_locations.quantity                        := x_line_locs.quantity_tbl;
  l_line_locations.amount                          := x_line_locs.amount_tbl;  -- PDOI for Complex PO Project
  l_line_locations.order_type_lookup_code          := x_line_locs.ln_order_type_lookup_code_tbl;
  l_line_locations.price_override                  := x_line_locs.price_override_tbl;
  l_line_locations.price_discount                  := x_line_locs.price_discount_tbl;
  l_line_locations.ship_to_organization_id         := x_line_locs.ship_to_org_id_tbl;
  l_line_locations.item_id                         := x_line_locs.ln_item_id_tbl;
  l_line_locations.item_revision                   := x_line_locs.ln_item_revision_tbl;
  l_line_locations.ship_to_location_id             := x_line_locs.ship_to_loc_id_tbl;
  l_line_locations.line_expiration_date            := x_line_locs.ln_expiration_date_tbl;
  l_line_locations.to_date                         := x_line_locs.end_date_tbl;
  l_line_locations.from_date                       := x_line_locs.start_date_tbl;
  l_line_locations.hdr_start_date                  := x_line_locs.hd_effective_date_tbl;
  l_line_locations.hdr_end_date                    := x_line_locs.hd_expiration_date_tbl;
  l_line_locations.qty_rcv_exception_code          := x_line_locs.qty_rcv_exception_code_tbl;
  l_line_locations.enforce_ship_to_location_code   := x_line_locs.enforce_ship_to_loc_code_tbl;
  l_line_locations.allow_substitute_receipts_flag  := x_line_locs.allow_sub_receipts_flag_tbl;
  l_line_locations.days_early_receipt_allowed      := x_line_locs.days_early_receipt_allowed_tbl;
  l_line_locations.receipt_days_exception_code     := x_line_locs.receipt_days_except_code_tbl;
  l_line_locations.invoice_close_tolerance         := x_line_locs.invoice_close_tolerance_tbl;
  l_line_locations.receiving_routing_id            := x_line_locs.receiving_routing_id_tbl;
  l_line_locations.accrue_on_receipt_flag          := x_line_locs.accrue_on_receipt_flag_tbl;

  l_line_locations.freight_carrier                 := x_line_locs.freight_carrier_tbl;
  l_line_locations.fob_lookup_code                 := x_line_locs.fob_tbl;
  l_line_locations.freight_terms_lookup_code       := x_line_locs.freight_term_tbl;
  l_line_locations.qty_rcv_tolerance               := x_line_locs.qty_rcv_tolerance_tbl;
  l_line_locations.firm_status_lookup_code         := x_line_locs.firm_flag_tbl;
  l_line_locations.qty_rcv_exception_code          := x_line_locs.qty_rcv_exception_code_tbl;
  l_line_locations.receipt_required_flag           := x_line_locs.receipt_required_flag_tbl;
  l_line_locations.inspection_required_flag        := x_line_locs.inspection_required_flag_tbl;
  l_line_locations.receipt_days_exception_code     := x_line_locs.receipt_days_except_code_tbl;
  l_line_locations.invoice_close_tolerance         := x_line_locs.invoice_close_tolerance_tbl;
  l_line_locations.receive_close_tolerance         := x_line_locs.receive_close_tolerance_tbl;
  l_line_locations.days_late_receipt_allowed       := x_line_locs.days_late_receipt_allowed_tbl;
  l_line_locations.enforce_ship_to_location_code   := x_line_locs.enforce_ship_to_loc_code_tbl;
  l_line_locations.allow_substitute_receipts_flag  := x_line_locs.allow_sub_receipts_flag_tbl;
  l_line_locations.secondary_unit_of_measure       := x_line_locs.secondary_unit_of_meas_tbl;
  l_line_locations.secondary_quantity              := x_line_locs.secondary_quantity_tbl;
  l_line_locations.preferred_grade                 := x_line_locs.preferred_grade_tbl;
  l_line_locations.item                            := x_line_locs.ln_item_desc_tbl;    -- PDOI for Complex PO Project
  l_line_locations.hdr_style_id                    := x_line_locs.hd_style_id_tbl;
  l_line_locations.tax_name                        := x_line_locs.tax_name_tbl;
  l_line_locations.tax_code_id                     := x_line_locs.tax_code_id_tbl;
  l_line_locations.line_price_break_lookup_code    := x_line_locs.ln_price_break_lookup_code_tbl; -- bug5016163
  l_line_locations.line_unit_price                 := x_line_locs.ln_unit_price_tbl;   -- PDOI for Complex PO Project
  l_line_locations.line_quantity                   := x_line_locs.ln_quantity_tbl;     -- PDOI for Complex PO Project
  l_line_locations.line_amount                     := x_line_locs.ln_amount_tbl;       -- PDOI for Complex PO Project
  l_line_locations.payment_type                    := x_line_locs.payment_type_tbl;    -- PDOI for Complex PO Project
  l_line_locations.draft_id                        := x_line_locs.draft_id_tbl; -- bug 4642348
  d_position := 10;

  l_parameter_name_tbl.EXTEND(5);
  l_parameter_value_tbl.EXTEND(5);
  l_parameter_name_tbl(1)     := 'CREATE_OR_UPDATE_ITEM';
  l_parameter_value_tbl(1)    := PO_PDOI_PARAMS.g_request.create_items;
  l_parameter_name_tbl(2)     := 'DOC_TYPE';
  l_parameter_value_tbl(2)    := PO_PDOI_PARAMS.g_request.document_type;
  l_parameter_name_tbl(3)     := 'OPERATING_UNIT';
  l_parameter_value_tbl(3)    := PO_PDOI_PARAMS.g_request.org_id;
  l_parameter_name_tbl(4)     := 'ALLOW_TAX_CODE_OVERRIDE';
  l_parameter_value_tbl(4)    := PO_PDOI_PARAMS.g_profile.allow_tax_code_override;
  l_parameter_name_tbl(5)     := 'INVENTORY_ORG_ID';
  l_parameter_value_tbl(5)    := PO_PDOI_PARAMS.g_sys.def_inv_org_id; -- bug5601416

  PO_VALIDATIONS.validate_pdoi
  (
    p_line_locations      => l_line_locations,
    p_doc_type            => PO_PDOI_PARAMS.g_request.document_type,
    p_parameter_name_tbl  => l_parameter_name_tbl,
    p_parameter_value_tbl => l_parameter_value_tbl,
    x_result_type         => l_result_type,
    x_results             => l_results
  );

  d_position := 20;

  IF l_result_type = po_validations.c_result_type_failure THEN

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'vaidate line locs return failure');
    END IF;

    PO_PDOI_ERR_UTL.process_val_type_errors
    (
      x_results    => l_results,
      p_table_name => 'PO_LINE_LOCATIONS_INTERFACE',
      p_line_locs  => x_line_locs
    );

    d_position := 30;

    populate_error_flag
    (
      x_results     => l_results,
      x_line_locs   => x_line_locs
    );
  END IF;

  IF l_result_type = po_validations.c_result_type_fatal THEN
     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'vaidate line locs return fatal');
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_VALIDATE);

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
END validate_line_locs;

-----------------------------------------------------------------------
--Start of Comments
--Name: update_line_loc_interface
--Function:
--  Update line location interface table with the line_location_id.
--  This value may be used in distribution processing
--Parameters:
--IN:
--p_intf_line_loc_id_tbl
--  list of interface_line_location_ids. Used to identify the rows to
--  be updated in po_line_locations_interface table
--p_line_loc_id_tbl
--  list of the new line_location_ids which is going to be set in
--  po_line_locations_interface table
-- PDOI Enhancement bug#17063664
-- p_action_tbl
-- list of the action value which is going to be set in
-- po_line_locations_interface table determines
-- where shipment has been created , updated,matched
--p_error_flag_tbl
--  list of error_flags which indicates whether there is any error
--  found in the processing logic for the corresponding location record
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_line_loc_interface
(
  p_intf_line_loc_id_tbl   IN PO_TBL_NUMBER,
  p_line_loc_id_tbl        IN PO_TBL_NUMBER,
  p_action_tbl             IN PO_TBL_VARCHAR30,
  p_error_flag_tbl         IN PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'update_line_loc_interface';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_intf_line_loc_id_tbl', p_intf_line_loc_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_line_loc_id_tbl', p_line_loc_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_error_flag_tbl', p_error_flag_tbl);
  END IF;

  -- update line_location_interface table with the new line_location_id
  -- Process code will be set as ACCEPTED after all validations only
  -- for the line which is being created /updated.
  FORALL i IN 1..p_intf_line_loc_id_tbl.COUNT
    UPDATE po_line_locations_interface
    SET    line_location_id = p_line_loc_id_tbl(i),
           process_code = DECODE(p_action_tbl(i),PO_PDOI_CONSTANTS.g_ACTION_MATCH,NULL,
	                   PO_PDOI_CONSTANTS.g_PROCESS_CODE_ACCEPTED),
	   action = p_action_tbl(i)
    WHERE  interface_line_location_id = p_intf_line_loc_id_tbl(i)
    AND    p_error_flag_tbl(i) = FND_API.g_FALSE;

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
END update_line_loc_interface;

-----------------------------------------------------------------------
--Start of Comments
--Name: update_amount_quantity
--Function:
--  Called when document type is Standard PO
--  The procedure is to calculate the total of amount(quantity) of
--  shipment lines for each po line, then set the total value back to
--  po line record.
--Parameters:
-- IN :
-- p_key
-- Session gt key
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_amount_quantity
(
  p_key                  IN  po_session_gt.key%TYPE
)IS

  d_api_name CONSTANT VARCHAR2(30) := 'update_amount_quantity';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_line_locs     PO_PDOI_TYPES.line_locs_rec_type;
  l_lines         PO_PDOI_TYPES.lines_rec_type;

  l_po_line_id_tbl  PO_TBL_NUMBER;
  l_draft_id_tbl    PO_TBL_NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;
  -- Update the values on po_line_locations_draft_all
  SELECT index_num1,-- line_location_id
         num1,  -- draft_id
         SUM(num2), -- Sum of quantities
         SUM(num3), -- Sum of amount
	 SUM(num4) --  Sum of secondary quantity
  BULK COLLECT INTO
        l_line_locs.line_loc_id_tbl,
        l_line_locs.draft_id_tbl,
        l_line_locs.quantity_tbl,
        l_line_locs.amount_tbl,
        l_line_locs.secondary_quantity_tbl
  FROM po_session_gt
  WHERE KEY = p_key
  AND   index_char1 IS NULL --Bug 19528138
  -- Bug 17802425 Rollup only when User has not populated line locations interface.
  AND char4 = 'S'
  GROUP BY index_num1,num1;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'l_line_locs.line_loc_id_tbl', l_line_locs.line_loc_id_tbl);
    PO_LOG.proc_begin(d_module, 'l_line_locs.draft_id_tbl', l_line_locs.draft_id_tbl);
    PO_LOG.proc_begin(d_module, 'l_line_locs.quantity_tbl', l_line_locs.quantity_tbl);
    PO_LOG.proc_begin(d_module, 'l_line_locs.amount_tbl', l_line_locs.amount_tbl);
    PO_LOG.proc_begin(d_module, 'l_line_locs.secondary_quantity_tbl', l_line_locs.secondary_quantity_tbl);
  END IF;

  d_position := 20;
  FORALL i IN 1..l_line_locs.line_loc_id_tbl.COUNT
  UPDATE po_line_locations_draft_all
  SET quantity = l_line_locs.quantity_tbl(i),
      amount   = l_line_locs.amount_tbl(i),
      secondary_quantity = l_line_locs.secondary_quantity_tbl(i)
  WHERE line_location_id = l_line_locs.line_loc_id_tbl(i)
  AND draft_id = l_line_locs.draft_id_tbl(i)
  AND ( payment_type IS NULL
  OR payment_type NOT IN ('ADVANCE','DELIVERY'));

  d_position := 30;
  --Update values in po_lines_draft_all
    SELECT index_num2,-- po_line_id
         num1,  -- draft_id
         SUM(num2), -- Sum of quantities
         SUM(num3), -- Sum of amount
	 SUM(num4) --  Sum of secondary quantity
  BULK COLLECT INTO
        l_lines.po_line_id_tbl,
        l_lines.draft_id_tbl,
        l_lines.quantity_tbl,
        l_lines.amount_tbl,
        l_lines.secondary_quantity_tbl
  FROM po_session_gt
  WHERE KEY = p_key
  AND index_char1 IS NULL --Bug 19528138
  -- Bug 17772630 do not consider payment_type advance and delivery
  -- For rollup of quantity and amount
  AND (char2 IS NULL
       OR char2 NOT IN ('ADVANCE','DELIVERY'))
  -- Bug 17802425 Rollup only when User has not populated line locations interface.
  AND char4 = 'S'
  GROUP BY index_num2,num1;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'l_lines.po_line_id_tbl',  l_lines.po_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'l_lines.draft_id_tbl', l_lines.draft_id_tbl);
    PO_LOG.proc_begin(d_module, 'l_lines.quantity_tbl', l_lines.quantity_tbl);
    PO_LOG.proc_begin(d_module, 'l_lines.amount_tbl', l_lines.amount_tbl);
    PO_LOG.proc_begin(d_module, 'l_lines.secondary_quantity_tbl', l_lines.secondary_quantity_tbl);
  END IF;

  d_position := 40;
  FORALL i IN 1..l_lines.po_line_id_tbl.COUNT
  UPDATE po_lines_draft_all
  SET quantity = l_lines.quantity_tbl(i),
      amount   = l_lines.amount_tbl(i),
      secondary_quantity = l_lines.secondary_quantity_tbl(i)
  WHERE po_line_id = l_lines.po_line_id_tbl(i)
  AND draft_id = l_lines.draft_id_tbl(i);

  d_position := 50;

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
END update_amount_quantity;

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_exist_price_breaks
--Function:
--  Called when document type is Quotation
--  The procedure is to delete all the existing price breaks for a
--  quotation line if new price break(s) is loaded for this quotation
--Parameters:
--IN:
--p_po_line_id_tbl
--  List of po_line_ids for which we need to delete existing price breaks
--p_draft_id_tbl
--  corresponding draft_id list for p_po_line_id_tbl
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE delete_exist_price_breaks
(
  p_po_line_id_tbl         IN DBMS_SQL.NUMBER_TABLE,
  p_draft_id_tbl           IN DBMS_SQL.NUMBER_TABLE
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'delete_exist_price_breaks';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- key value used to identify rows in po_session_gt table
  l_key po_session_gt.key%TYPE;

  -- variables to hold results from po_session_gt table
  l_line_loc_id_tbl    PO_TBL_NUMBER;
  l_draft_id_tbl       PO_TBL_NUMBER;

  l_delete_flag_tbl          PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
  l_record_already_exist_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  l_key := PO_CORE_S.get_session_gt_nextval;

  FORALL i IN 1..p_po_line_id_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT l_key,
           line_location_id,
           p_draft_id_tbl(i)
    FROM   po_line_locations_all
    WHERE  po_line_id = p_po_line_id_tbl(i);

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1, num2 BULK COLLECT INTO l_line_loc_id_tbl, l_draft_id_tbl;

  d_position := 20;

  l_delete_flag_tbl.EXTEND(l_line_loc_id_tbl.COUNT);
  FOR i IN 1..l_line_loc_id_tbl.COUNT
  LOOP
    l_delete_flag_tbl(i) := 'Y';
  END LOOP;
  PO_LINE_LOCATIONS_DRAFT_PKG.sync_draft_from_txn
  (
    p_line_location_id_tbl      => l_line_loc_id_tbl,
    p_draft_id_tbl              => l_draft_id_tbl,
    p_delete_flag_tbl           => l_delete_flag_tbl,
    x_record_already_exist_tbl  => l_record_already_exist_tbl
  );

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
END delete_exist_price_breaks;

-------------------------------------------------------------------------
--------------------- PRIVATE PROCEDURES --------------------------------
-------------------------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_line_loc_id
--Function:
--  logic to derive line_location_id from shipment_num and po_line_id
--  in batch mode
--Parameters:
--IN:
--p_key
--  identifier in the temp table on the derived result
--p_index_tbl
--  indexes of the records
--p_po_line_id_tbl
--  list of po_line_ids within the batch
--p_shipment_num_tbl
--  list of shipment_nums within the batch
--IN OUT:
--x_line_loc_id_tbl
--  contains the derived result if original value is null;
--  original value will not be changed if it is not null
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_line_loc_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_po_line_id_tbl       IN PO_TBL_NUMBER,
  p_shipment_num_tbl     IN PO_TBL_NUMBER,
  x_line_loc_id_tbl      IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_line_loc_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_po_line_id_tbl', p_po_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_shipment_num_tbl', p_shipment_num_tbl);
    PO_LOG.proc_begin(d_module, 'x_line_loc_id_tbl', x_line_loc_id_tbl);
  END IF;

  -- run query to extract line_location_id
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           line_location_id
    FROM   po_line_locations
    WHERE  p_shipment_num_tbl(i) IS NOT NULL
    AND    x_line_loc_id_tbl(i) IS NULL
    AND    po_line_id = p_po_line_id_tbl(i)
    AND    shipment_num = p_shipment_num_tbl(i)
    AND    shipment_type = 'PRICE BREAK';

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- push the result back to x_line_loc_id_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new line loc id', l_result_tbl(i));
    END IF;

    x_line_loc_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
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
END derive_line_loc_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_ship_to_org_id
--Function:
--  logic to derive ship_to_organization_id from ship_to_organization_code
--  in batch mode
--Parameters:
--IN:
--p_key
--  identifier in the temp table on the derived result
--p_index_tbl
--  indexes of the records
--p_ship_to_org_code_tbl
--  ist of ship_to_organization_code values within the batch
--IN OUT:
--x_ship_to_org_id_tbl
--  contains the derived result if original value is null;
--  original value will not be changed if it is not null
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_ship_to_org_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_ship_to_org_code_tbl IN PO_TBL_VARCHAR5,
  x_ship_to_org_id_tbl   IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_ship_to_org_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_ship_to_org_code_tbl', p_ship_to_org_code_tbl);
    PO_LOG.proc_begin(d_module, 'x_ship_to_org_id_tbl', x_ship_to_org_id_tbl);
  END IF;

  -- execute query to extract org_id from org_code
  FORALL i IN 1.. p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           organization_id
    FROM   org_organization_definitions
    WHERE  p_ship_to_org_code_tbl(i) IS NOT NULL
    AND    x_ship_to_org_id_tbl(i) IS NULL
    AND    organization_code = p_ship_to_org_code_tbl(i)
    AND    TRUNC(sysdate) < nvl(disable_date, TRUNC(sysdate+1))
    AND    inventory_enabled_flag = 'Y';

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- set derived result in x_ship_to_org_id_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new ship_to org id', l_result_tbl(i));
    END IF;

    x_ship_to_org_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
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
END derive_ship_to_org_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_receiving_routing_id
--Function:
--  logic to derive receiving_routing_id from receiving_routing
--  in batch mode
--Parameters:
--IN:
--p_key
--  identifier in the temp table on the derived result
--p_index_tbl
--  indexes of the records
--p_receiving_routing_tbl
--  list of receiving_routing values within the batch
--IN OUT:
--x_receiving_routing_id_tbl
--  contains the derived result if original value is null;
--  original value will not be changed if it is not null
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_receiving_routing_id
(
  p_key                      IN po_session_gt.key%TYPE,
  p_index_tbl                IN DBMS_SQL.NUMBER_TABLE,
  p_receiving_routing_tbl    IN PO_TBL_VARCHAR30,
  x_receiving_routing_id_tbl IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_receiving_routing_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_receiving_routing_tbl',
                      p_receiving_routing_tbl);
    PO_LOG.proc_begin(d_module, 'x_receiving_routing_id_tbl',
                      x_receiving_routing_id_tbl);
  END IF;

  -- execute query to extract routing_id from receiving_routings
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           routing_header_id
    FROM   rcv_routing_headers
    WHERE  p_receiving_routing_tbl(i) IS NOT NULL
    AND    x_receiving_routing_id_tbl(i) IS NULL
    AND    routing_name = p_receiving_routing_tbl(i);

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- set derived result in x_receiving_routing_id_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new routing id', l_result_tbl(i));
    END IF;

    x_receiving_routing_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
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
END derive_receiving_routing_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_tax_name
--Function:
--  logic to derive tax_name from tax_code_id
--  in batch mode
--Parameters:
--IN:
--p_key
--  identifier in the temp table on the derived result
--p_index_tbl
--  indexes of the records
--p_tax_code_id_tbl
--  list of tax_code_id values within the batch
--IN OUT:
--x_tax_name_tbl
--  contains the derived result if original value is null;
--  original value will not be changed if it is not null
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_tax_name
(
  p_key                      IN po_session_gt.key%TYPE,
  p_index_tbl                IN DBMS_SQL.NUMBER_TABLE,
  p_tax_code_id_tbl          IN PO_TBL_NUMBER,
  x_tax_name_tbl             IN OUT NOCOPY PO_TBL_VARCHAR30
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_tax_name';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_VARCHAR30;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_tax_code_id_tbl',
                      p_tax_code_id_tbl);
    PO_LOG.proc_begin(d_module, 'x_tax_name_tbl',
                      x_tax_name_tbl);
  END IF;

  -- execute query to extract tax_name from tax_code_id
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, char1)
    SELECT p_key,
           p_index_tbl(i),
           tax_classification_code
    FROM   zx_id_tcc_mapping
    WHERE  p_tax_code_id_tbl(i) IS NOT NULL
    AND    x_tax_name_tbl(i) IS NULL
    AND    tax_rate_code_id = p_tax_code_id_tbl(i)
	AND    source = 'AP'
	AND    TRUNC(sysdate) BETWEEN TRUNC(NVL(effective_from, sysdate))
           AND TRUNC(NVL(effective_to, sysdate));

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- set derived result in x_receiving_routing_id_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new tax_name', l_result_tbl(i));
    END IF;

    x_tax_name_tbl(l_index_tbl(i)) := l_result_tbl(i);
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
END derive_tax_name;
-----------------------------------------------------------------------
--Start of Comments
--Name: default_outsourced_assembly
--Function:
--  logic to derive outsourced_assembly from mtl_system_items_b
--  in batch mode
--Parameters:
--IN:
--p_item_id_tbl
--  list of item_id values within the batch
--p_ship_to_organizatin_id_tbl
--  list of ship_to_organization_id values within the batch
--OUT:
--x_outsourced_assembly_tbl
--  contains the defaulted result;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_outsourced_assembly
(
  p_item_id_tbl                 IN  PO_TBL_NUMBER,
  p_ship_to_organization_id_tbl IN  PO_TBL_NUMBER,
  x_outsourced_assembly_tbl     IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_outsourced_assembly';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_item_id_tbl', p_item_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_ship_to_organization_id_tbl', p_ship_to_organization_id_tbl);
  END IF;

  FOR i IN 1..p_item_id_tbl.COUNT LOOP
    x_outsourced_assembly_tbl(i) :=
      PO_CORE_S.get_outsourced_assembly
      ( p_item_id => p_item_id_tbl(i),
        p_ship_to_org_id => p_ship_to_organization_id_tbl(i)
      );
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
END default_outsourced_assembly;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_locs_for_spo
--Function:
--  default logic on line location attributes for Standard PO
--Parameters:
--IN:
--p_key
--  identifier in the temp table on the derived result
--p_index_tbl
--  indexes of the records
--IN OUT:
--x_line_locs
--  variable to hold all the line location attribute values in one batch;
--  default result are saved inside the variable
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_locs_for_spo
(
  p_key        IN po_session_gt.key%TYPE,
  p_index_tbl  IN DBMS_SQL.NUMBER_TABLE,
  x_line_locs  IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_locs_for_spo';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- receiving control default values
  l_enforce_ship_to_loc_code     VARCHAR2(25);
  l_allow_sub_receipts_flag      VARCHAR2(1);
  l_receiving_routing_id         NUMBER;
  l_receiving_routing_name       rcv_routing_headers.routing_name%TYPE; -- Bug#17063664
  l_qty_rcv_tolerance            NUMBER;
  l_qty_rcv_exception            VARCHAR2(25);
  l_days_early_receipt_allowed   NUMBER;
  l_days_late_receipt_allowed    NUMBER;
  l_rct_days_exception_code      VARCHAR2(25);
  l_receipt_req_flag_temp        VARCHAR2(3):= NULL;
  l_insp_req_flag_temp           VARCHAR2(3):= NULL;

  -- <<PDOI Enhancement Bug#17063664 Start>>
  -- inventory organization_id from hr_locations_v
  l_inv_ship_to_org_id_tbl  PO_TBL_NUMBER;

  -- <<PDOI Enhancement Bug#17063664 End>>

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- <<PDOI Enhancement Bug#17063664 Start>>
  -- Extending the collection attribute wip_entity_id_tbl in line_locs
  --  record, as this is the line level attribute.
  x_line_locs.wip_entity_id_tbl := PO_TBL_NUMBER();
  x_line_locs.wip_entity_id_tbl.EXTEND(x_line_locs.rec_count);

  -- <<PDOI Enhancement Bug#17063664 End>>

  -- default inspection_required_flag from item_id
  /*default_inspect_required_flag
  (
    p_key                          => p_key,
    p_index_tbl                    => p_index_tbl,
    p_item_id_tbl                  => x_line_locs.ln_item_id_tbl,
    x_inspection_required_flag_tbl => x_line_locs.inspection_required_flag_tbl
  );*/

  -- <<PDOI Enhancement Bug#17063664 Start>>
  -- get default info from the requisition if backing req line id is provided,
  -- the below attributes we can default from requisition include:
  -- DESTINATION_ORGANIZATION_ID, DELIVER_TO_LOCATION_ID, NEED_BY_DATE, VMI_FLAG
  default_info_from_req
  (
    p_key                   => p_key,
    p_index_tbl             => p_index_tbl,
    p_ln_req_line_id_tbl    => x_line_locs.ln_req_line_id_tbl,
    x_need_by_date_tbl      => x_line_locs.need_by_date_tbl,
    x_vmi_flag_tbl          => x_line_locs.vmi_flag_tbl,
    x_drop_ship_flag_tbl    => x_line_locs.drop_ship_flag_tbl,
    x_note_to_receiver_tbl  => x_line_locs.note_to_receiver_tbl,
    x_wip_entity_id_tbl     => x_line_locs.wip_entity_id_tbl
  );

  -- <<PDOI Enhancement Bug#17063664 End>

  -- <<Bug#17998869 Start>>
  default_lead_time
  (
    p_key                   => p_key,
    p_index_tbl             => p_index_tbl,
    p_ln_from_line_id_tbl   => x_line_locs.ln_from_line_id_tbl,
    x_lead_time_tbl         => x_line_locs.lead_time_tbl
  );
  -- <<Bug#17998869 End>>

  -- Bug 18534140
  default_shipment_type
  (
    p_key                   => p_key,
    p_index_tbl             => p_index_tbl,
    p_payment_type_tbl      => x_line_locs.payment_type_tbl,
    p_style_id_tbl          => x_line_locs.hd_style_id_tbl,
    x_shipment_type_tbl     => x_line_locs.shipment_type_tbl
  );

  d_position := 10;

  -- default attribute on each record
  FOR i IN 1..x_line_locs.rec_count
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'default for spo index', i);
    END IF;

    -- Bug 18534140
    -- Removing the defaulting of shipment_type from here as added new procedure before loop.

    -- Bug#17063664
    -- default closed_reason
    IF x_line_locs.consigned_flag_tbl(i) = 'Y' THEN
      x_line_locs.ln_closed_reason_tbl(i) :=
        fnd_message.get_string('PO', 'PO_SUP_CONS_CLOSED_REASON');
    END IF;

    -- Bug#17063664
    -- Commenting the below code
    /*
    -- default shipment_num if it is not provided or not unique
    IF (x_line_locs.shipment_num_tbl(i) IS NULL OR
        x_line_locs.shipment_num_unique_tbl(i) = 'N') THEN
      x_line_locs.shipment_num_tbl(i) :=
        PO_PDOI_MAINPROC_UTL_PVT.get_next_shipment_num
        (
          p_po_line_id  => x_line_locs.ln_po_line_id_tbl(i)
        );

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'default shipment num',
                    x_line_locs.shipment_num_tbl(i));
      END IF;
    END IF;
    */

    -- <<PDOI Enhancement Bug#17063664 Start>>
    -- default with Need by date if PO_NEED_BY_PROMISE_DEFAULTING profile is set to Y
    IF PO_PDOI_PARAMS.g_profile.default_promised_date = 'Y' THEN
      x_line_locs.promised_date_tbl(i) :=
          NVL(x_line_locs.promised_date_tbl(i), x_line_locs.need_by_date_tbl(i));
    END IF;

    -- <<Bug#17998869 Start>>
    IF (PO_PDOI_PARAMS.g_request.approved_status = PO_PDOI_CONSTANTS.g_APPR_STATUS_APPROVED AND
      x_line_locs.lead_time_tbl(i) IS NOT NULL) THEN
        x_line_locs.promised_date_tbl(i) := SYSDATE + x_line_locs.lead_time_tbl(i);
    END IF;
    -- <<Bug#17998869 End>>

    -- <<PDOI Enhancement Bug#17063664 End>>

    -- default line_location_id if not provided or derived
    IF (x_line_locs.line_loc_id_tbl(i) IS NULL) THEN
      x_line_locs.line_loc_id_tbl(i) :=
        PO_PDOI_MAINPROC_UTL_PVT.get_next_line_loc_id;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'default line loc',
                    x_line_locs.line_loc_id_tbl(i));
      END IF;
    END IF;

    -- default price_override
    -- <PDOI Enhancement Bug#17063664>
    -- Defaulting price override only in case of QUOTATION.
    -- For Standard and Blanket it will be defaulted later on.
    IF (PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION AND
        x_line_locs.price_override_tbl(i) IS NULL AND
        x_line_locs.ln_order_type_lookup_code_tbl(i) <> 'FIXED PRICE' AND
        x_line_locs.ln_action_tbl(i) <> PO_PDOI_CONSTANTS.g_ACTION_UPDATE) THEN
      x_line_locs.price_override_tbl(i) := x_line_locs.ln_unit_price_tbl(i);
    END IF;

    -- default ship_to_location_id
    x_line_locs.ship_to_loc_id_tbl(i) :=
      COALESCE(x_line_locs.ship_to_loc_id_tbl(i), x_line_locs.hd_ship_to_loc_id_tbl(i));

    d_position := 20;

     -- Added below code for bug 13905609
-- Before defaulting receipt required flag from purchasing options
-- checking at line type setup.
BEGIN

  po_shipments_sv8.get_matching_controls(
                       X_vendor_id     => x_line_locs.hd_vendor_id_tbl(i),
                       X_line_type_id  => x_line_locs.ln_line_type_id_tbl(i),
                       X_item_id       => x_line_locs.ln_item_id_tbl(i),
                       X_receipt_required_flag    => l_receipt_req_flag_temp,
                       X_inspection_required_flag => l_insp_req_flag_temp
                      );
   EXCEPTION
	    WHEN OTHERS THEN
	    l_receipt_req_flag_temp := NULL;
	    l_insp_req_flag_temp := NULL;
		 IF (PO_LOG.d_stmt) THEN
		    PO_LOG.stmt(d_module, d_position, 'Exception',
                    SQLERRM);
		 END IF;
	END;
--Ended code addition for bug 13905609

    -- default inspection_required_flag and receipt_required_flag with 'N'
    --  and closed_code with CLOSED_FOR_INVOICE for consigned
    IF x_line_locs.consigned_flag_tbl(i) = 'Y' THEN
      x_line_locs.inspection_required_flag_tbl(i) := 'N';
      x_line_locs.receipt_required_flag_tbl(i) := 'N';
      x_line_locs.ln_closed_code_tbl(i) := 'CLOSED FOR INVOICE';
    ELSE
      -- default inspection_required_flag from system if it cannot be
      -- be defaulted from item_id at the beginning of procedure
      x_line_locs.inspection_required_flag_tbl(i) :=
        NVL(x_line_locs.inspection_required_flag_tbl(i),  NVL(l_insp_req_flag_temp,
            PO_PDOI_PARAMS.g_sys.inspection_required_flag));

      -- default receipt_required_flag from system
      x_line_locs.receipt_required_flag_tbl(i) :=
        NVL(x_line_locs.receipt_required_flag_tbl(i),NVL(l_receipt_req_flag_temp,
            PO_PDOI_PARAMS.g_sys.receiving_flag));
    END IF;

    -- set tax_attribute_update_code to CREATE
	x_line_locs.tax_attribute_update_code_tbl(i) := 'CREATE';

	-- Bug 18526577 Start
	-- Setting value basis and matching basis as per payment type.
	IF NVL(x_line_locs.payment_type_tbl(i), 'NULL') = 'RATE' THEN
	   x_line_locs.value_basis_tbl(i) := Nvl(x_line_locs.value_basis_tbl(i),'QUANTITY');
	   x_line_locs.matching_basis_tbl(i) := Nvl(x_line_locs.matching_basis_tbl(i),'QUANTITY');
	ELSIF NVL(x_line_locs.payment_type_tbl(i), 'NULL') IN  ('LUMPSUM', 'ADVANCE') THEN
	   x_line_locs.value_basis_tbl(i) := Nvl(x_line_locs.value_basis_tbl(i),'FIXED PRICE');
	   x_line_locs.matching_basis_tbl(i) := Nvl(x_line_locs.matching_basis_tbl(i),'AMOUNT');
	ELSE
	   x_line_locs.value_basis_tbl(i) := Nvl(x_line_locs.value_basis_tbl(i),x_line_locs.ln_order_type_lookup_code_tbl(i));
	   x_line_locs.matching_basis_tbl(i) := Nvl(x_line_locs.matching_basis_tbl(i),x_line_locs.ln_matching_basis_tbl(i));
	END IF;
	-- Bug 18526577 End

       -- set shipment description for advance shipments in case of Complex work PO
	   --Bug#17712442 FIX:: For Advance Shipment the Receipt Required flag should set to NO
	IF Nvl(x_line_locs.payment_type_tbl(i),'DELIVERY') = 'ADVANCE' THEN
	  x_line_locs.ln_item_desc_tbl(i) := 'Advance - ' || x_line_locs.ln_item_desc_tbl(i);
	  x_line_locs.receipt_required_flag_tbl(i) := 'N';  --Bug#17712442 FIX
	END IF;
    -- PDOI for Complex PO Project

  -- set unit_of_measure from unit_meas_lookup_code on line level
    IF (Nvl(x_line_locs.payment_type_tbl(i),'DELIVERY') NOT IN ('ADVANCE','RATE')) THEN  -- PDOI for Complex PO Project
	    x_line_locs.unit_of_measure_tbl(i) := x_line_locs.ln_unit_of_measure_tbl(i);
    END IF;
  END LOOP;

  d_position := 30;

  -- default ship_to_organization_id from ship_to_location_id
  default_ship_to_org_id
  (
    p_key                   => p_key,
    p_index_tbl             => p_index_tbl,
    p_ship_to_loc_id_tbl    => x_line_locs.ship_to_loc_id_tbl,
    x_ship_to_org_id_tbl    => l_inv_ship_to_org_id_tbl
  );

  -- another loop to default based on defaulted ship_to_organization_id
  FOR i IN 1..x_line_locs.rec_count
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'second default index', i);
    END IF;

    -- default ship_to_organization_id
    x_line_locs.ship_to_org_id_tbl(i) :=
      COALESCE(x_line_locs.ship_to_org_id_tbl(i), l_inv_ship_to_org_id_tbl(i)
                , PO_PDOI_PARAMS.g_sys.def_inv_org_id);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'ship_to org id',
                  x_line_locs.ship_to_org_id_tbl(i));
    END IF;

    d_position := 40;

    -- <<PDOI Enhancement Bug#17063664>>
    -- Passing order_type_lookup_code and purchase_basis to the api
    --   RCV_CORE_S.get_receiving_controls
    -- default allow_sub_receipts_flag, qty_rcv_tolerance, and
    -- qty_rcv_exception_code
    RCV_CORE_S.get_receiving_controls
    (
      p_order_type_lookup_code      => x_line_locs.ln_order_type_lookup_code_tbl(i),
      p_purchase_basis              => x_line_locs.ln_purchase_basis_tbl(i),
      p_line_location_id            => x_line_locs.line_loc_id_tbl(i),
      p_item_id                     => x_line_locs.ln_item_id_tbl(i),
      p_org_id                      => x_line_locs.ship_to_org_id_tbl(i),
      p_vendor_id                   => x_line_locs.hd_vendor_id_tbl(i),
      x_enforce_ship_to_loc_code    => l_enforce_ship_to_loc_code,
      x_allow_substitute_receipts   => l_allow_sub_receipts_flag,
      x_routing_id                  => l_receiving_routing_id,
      x_routing_name                => l_receiving_routing_name,
      x_qty_rcv_tolerance           => l_qty_rcv_tolerance,
      x_qty_rcv_exception_code      => l_qty_rcv_exception,
      x_days_early_receipt_allowed  => l_days_early_receipt_allowed,
      x_days_late_receipt_allowed   => l_days_late_receipt_allowed,
      x_receipt_days_exception_code => l_rct_days_exception_code
    );

    d_position := 50;

    -- default qty_rcv_tolerance from receiving controls
    x_line_locs.qty_rcv_tolerance_tbl(i) :=
      NVL(x_line_locs.qty_rcv_tolerance_tbl(i), l_qty_rcv_tolerance);

    -- default qty_rcv_exception_code from receiving controls
    x_line_locs.qty_rcv_exception_code_tbl(i) :=
      NVL(x_line_locs.qty_rcv_exception_code_tbl(i), l_qty_rcv_exception);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'order type',
                  x_line_locs.ln_order_type_lookup_code_tbl(i));
    END IF;

    -- set the other attributes based on order_type
    IF (x_line_locs.ln_order_type_lookup_code_tbl(i) IN ('FIXED PRICE', 'RATE')) THEN
      x_line_locs.inspection_required_flag_tbl(i)   := NVL(x_line_locs.inspection_required_flag_tbl(i), 'N');
      x_line_locs.receiving_routing_id_tbl(i)       := NVL(x_line_locs.receiving_routing_id_tbl(i), 3);    --For DIRECT Delivery
    ELSE
      -- default receiving_routing_id, allow_sub_receipts_flag,
      -- enforce_ship_to_loc_code, days_early_receipt_allowed,
      -- days_late_receipt_allowed and receipt_days_exception_code
      -- from receiving controls
      x_line_locs.receiving_routing_id_tbl(i)       :=
        NVL(x_line_locs.receiving_routing_id_tbl(i),
            l_receiving_routing_id);
      x_line_locs.enforce_ship_to_loc_code_tbl(i)   :=
        NVL(x_line_locs.enforce_ship_to_loc_code_tbl(i),
            l_enforce_ship_to_loc_code);
      x_line_locs.allow_sub_receipts_flag_tbl(i)    :=
        NVL(x_line_locs.allow_sub_receipts_flag_tbl(i),
            l_allow_sub_receipts_flag);
      x_line_locs.days_early_receipt_allowed_tbl(i) :=
        NVL(x_line_locs.days_early_receipt_allowed_tbl(i),
            l_days_early_receipt_allowed);
      x_line_locs.days_late_receipt_allowed_tbl(i)  :=
        NVL(x_line_locs.days_late_receipt_allowed_tbl(i),
            l_days_late_receipt_allowed);
      x_line_locs.receipt_days_except_code_tbl(i):=
        NVL(x_line_locs.receipt_days_except_code_tbl(i),
            l_rct_days_exception_code);
    END IF;
  END LOOP;

  d_position := 60;

  -- default invoice_close_tolerance and receive_close_tolerance
  default_close_tolerances
  (
    p_key                         => p_key,
    p_index_tbl                   => p_index_tbl,
    p_item_id_tbl                 => x_line_locs.ln_item_id_tbl,
    p_ship_to_org_id_tbl          => x_line_locs.ship_to_org_id_tbl,
    p_line_type_id_tbl            => x_line_locs.ln_line_type_id_tbl,
    p_consigned_flag_tbl          => x_line_locs.consigned_flag_tbl,
    x_invoice_close_tolerance_tbl => x_line_locs.invoice_close_tolerance_tbl,
    x_receive_close_tolerance_tbl => x_line_locs.receive_close_tolerance_tbl
  );

  d_position := 70;

  -- default match options
  default_invoice_match_options
  (
    p_key                      => p_key,
    p_index_tbl                => p_index_tbl,
    p_line_loc_id_tbl          => x_line_locs.line_loc_id_tbl,
    p_item_id_tbl              => x_line_locs.ln_item_id_tbl,
    p_vendor_id_tbl            => x_line_locs.hd_vendor_id_tbl,
    p_vendor_site_id_tbl       => x_line_locs.hd_vendor_site_id_tbl,
    p_ship_to_org_id_tbl       => x_line_locs.ship_to_org_id_tbl,
    p_consigned_flag_tbl       => x_line_locs.consigned_flag_tbl,
    p_outsourced_assembly_tbl  => x_line_locs.outsourced_assembly_tbl,
	p_shipment_type_tbl        => x_line_locs.shipment_type_tbl,
    x_match_option_tbl         => x_line_locs.match_option_tbl
  );

  d_position := 80;

  -- default accrue_on_receipt_flag
  default_accrue_on_receipt_flag
  (
    p_key                        => p_key,
    p_index_tbl                  => p_index_tbl,
    p_item_id_tbl                => x_line_locs.ln_item_id_tbl,
    p_ship_to_org_id_tbl         => x_line_locs.ship_to_org_id_tbl,
    p_receipt_required_flag_tbl  => x_line_locs.receipt_required_flag_tbl,
    p_consigned_flag_tbl         => x_line_locs.consigned_flag_tbl,
    p_txn_flow_header_id_tbl     => x_line_locs.txn_flow_header_id_tbl,
    p_pcard_id_tbl               => x_line_locs.hd_pcard_id_tbl,
    p_shipment_type_tbl          => x_line_locs.shipment_type_tbl,
    p_intf_line_loc_id_tbl       => x_line_locs.intf_line_loc_id_tbl,  --Bug 17604686
    p_ln_req_line_id_tbl         => x_line_locs.ln_req_line_id_tbl,    --Bug 18652325
    x_accrue_on_receipt_flag_tbl => x_line_locs.accrue_on_receipt_flag_tbl
  );

  -- default outsourced_assembly from mtl_system_items_b
  default_outsourced_assembly
  (
     p_item_id_tbl                 => x_line_locs.ln_item_id_tbl,
     p_ship_to_organization_id_tbl => x_line_locs.ship_to_org_id_tbl,
     x_outsourced_assembly_tbl     => x_line_locs.outsourced_assembly_tbl
  );

  -- default secondary_unit_of_measure for dual-uom items
  -- Bug 4723323: add default logic for secondary_unit_of_measure
  default_secondary_unit_of_meas
  (
    p_key                          => p_key,
    p_index_tbl                    => p_index_tbl,
    p_item_id_tbl                  => x_line_locs.ln_item_id_tbl,
    p_ship_to_org_id_tbl           => x_line_locs.ship_to_org_id_tbl,
    x_secondary_unit_of_meas_tbl   => x_line_locs.secondary_unit_of_meas_tbl
  );

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
END default_locs_for_spo;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_locs_for_blanket
--Function:
--  default logic on line location attributes for Blanket
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--IN OUT:
--x_line_locs
--  variable to hold all the line location attribute values in one batch;
--  default result are saved inside the variable
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_locs_for_blanket
(
  p_key        IN po_session_gt.key%TYPE,
  p_index_tbl  IN DBMS_SQL.NUMBER_TABLE,
  x_line_locs  IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_locs_for_blanket';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;
 -- Bug 9294987
  x_precision             NUMBER  := null;
  x_ext_precision         NUMBER  := null;
  x_min_acct_unit         NUMBER  := null;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- default ship_to_organization_id from ship_to_location_id
  default_ship_to_org_id
  (
    p_key                   => p_key,
    p_index_tbl             => p_index_tbl,
    p_ship_to_loc_id_tbl    => x_line_locs.ship_to_loc_id_tbl,
    x_ship_to_org_id_tbl    => x_line_locs.ship_to_org_id_tbl
  );

  d_position := 10;

  -- default on row by row base
  FOR i IN 1..x_line_locs.rec_count
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'default for blanket index', i);
    END IF;

    -- bug5307208
    -- Truncate start/end date of the price breaks
    x_line_locs.start_date_tbl(i) := TRUNC(x_line_locs.start_date_tbl(i));
    x_line_locs.end_date_tbl(i) := TRUNC(x_line_locs.end_date_tbl(i));

    -- default shipment_type
    x_line_locs.shipment_type_tbl(i) :=
      NVL(x_line_locs.shipment_type_tbl(i), 'PRICE BREAK');

    -- default shipment_num
    x_line_locs.shipment_num_tbl(i) :=
      NVL(x_line_locs.shipment_num_tbl(i),
      PO_PDOI_MAINPROC_UTL_PVT.get_next_shipment_num(x_line_locs.ln_po_line_id_tbl(i)));

    -- default line_location_id
    x_line_locs.line_loc_id_tbl(i) :=
      NVL(x_line_locs.line_loc_id_tbl(i),
      PO_PDOI_MAINPROC_UTL_PVT.get_next_line_loc_id);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'shipment type',
                  x_line_locs.shipment_type_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'shipment num',
                  x_line_locs.shipment_num_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'line loc id',
                  x_line_locs.line_loc_id_tbl(i));
    END IF;

    -- set accrue_on_receipt_flag and firm_flag to NULL
    x_line_locs.accrue_on_receipt_flag_tbl(i) := NULL;
    x_line_locs.firm_flag_tbl(i) := NULL;

    -- ignore user's input of tax_name for blanket
    x_line_locs.tax_name_tbl(i) := NULL;

    -- set value_basis from order_type_lookup_code on line level
    x_line_locs.value_basis_tbl(i) := x_line_locs.ln_order_type_lookup_code_tbl(i);

    -- set matching_basis to NULL
    x_line_locs.matching_basis_tbl(i) := NULL;

    -- default price_discount and price_override

  --Bug # 6657206 Added the following If condition to bypass discount_price calculation when break price is 0

  -- Bug 9294987 Modified rounding number from 2 to  x_ext_precision which can be set by Ct .

    --<PDOI Enhancement Bug#17063664>
    -- Defaulting unit_price only in case of QUOTATION.
    -- For Standard and Blanket it will be defaulted later on.
    -- Bug 20205276 update price discount for blanket
    IF PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET THEN

        IF ( x_line_locs.ln_unit_price_tbl(i) <> 0  ) THEN

          fnd_currency.get_info (x_line_locs.hd_currency_code_tbl(i),
                                x_precision,
                                x_ext_precision,
                                x_min_acct_unit);
           IF (x_line_locs.price_override_tbl(i) IS NOT NULL) THEN
              x_line_locs.price_discount_tbl(i) :=
                ROUND(((x_line_locs.ln_unit_price_tbl(i) - x_line_locs.price_override_tbl(i))/x_line_locs.ln_unit_price_tbl(i)) * 100, x_ext_precision);
           ELSIF (x_line_locs.price_override_tbl(i) IS NULL AND
            x_line_locs.price_discount_tbl(i) IS NOT NULL) THEN
              x_line_locs.price_override_tbl(i) :=
                  ROUND((((100 - x_line_locs.price_discount_tbl(i))/100) * x_line_locs.ln_unit_price_tbl(i)), x_ext_precision);
           END IF;
        ELSE
               x_line_locs.price_override_tbl(i) :=0.0;
        END IF;

    END IF;
    -- set outsourced_assembly to 2 since it is a required field
    x_line_locs.outsourced_assembly_tbl(i) := 2;
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
END default_locs_for_blanket;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_locs_for_quotation
--Function:
--  default logic on line location attributes for Quotation
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--IN OUT:
--x_line_locs
--  variable to hold all the line location attribute values in one batch;
--  default result are saved inside the variable
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_locs_for_quotation
(
  p_key        IN po_session_gt.key%TYPE,
  p_index_tbl  IN DBMS_SQL.NUMBER_TABLE,
  x_line_locs  IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_locs_for_quotation';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- receiving control default values
  l_enforce_ship_to_loc_code     VARCHAR2(25);
  l_allow_sub_receipts_flag      VARCHAR2(1);
  l_receiving_routing_id         NUMBER;
  l_receiving_routing_name       rcv_routing_headers.routing_name%TYPE; -- Bug#17063664
  l_qty_rcv_tolerance            NUMBER;
  l_qty_rcv_exception            VARCHAR2(25);
  l_days_early_receipt_allowed   NUMBER;
  l_days_late_receipt_allowed    NUMBER;
  l_rct_days_exception_code      VARCHAR2(25);
  l_receipt_req_flag_temp       VARCHAR2(3):= NULL;
  l_insp_req_flag_temp	         VARCHAR2(3):= NULL;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;
 --for Bug 13905609
  -- default inspection_required_flag from item_id
 /* default_inspect_required_flag
  (
    p_key                          => p_key,
    p_index_tbl                    => p_index_tbl,
    p_item_id_tbl                  => x_line_locs.ln_item_id_tbl,
    x_inspection_required_flag_tbl => x_line_locs.inspection_required_flag_tbl
  );*/

  d_position := 10;

  -- default ship_to_organization_id from ship_to_location_id
  default_ship_to_org_id
  (
    p_key                 => p_key,
    p_index_tbl           => p_index_tbl,
    p_ship_to_loc_id_tbl  => x_line_locs.ship_to_loc_id_tbl,
    x_ship_to_org_id_tbl  => x_line_locs.ship_to_org_id_tbl
  );

  d_position := 20;

  -- default on row by row base
  FOR i IN 1..x_line_locs.rec_count
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'default for quotation index', i);
    END IF;

    -- bug5307208
    -- Truncate start/end date of the price breaks
    x_line_locs.start_date_tbl(i) := TRUNC(x_line_locs.start_date_tbl(i));
    x_line_locs.end_date_tbl(i) := TRUNC(x_line_locs.end_date_tbl(i));

    -- default shipment_type according to document type
    x_line_locs.shipment_type_tbl(i) :=
      NVL(x_line_locs.shipment_type_tbl(i), 'QUOTATION');

    -- default shipment_num to max_shipement_num+1
    x_line_locs.shipment_num_tbl(i) :=
      NVL(x_line_locs.shipment_num_tbl(i),
      PO_PDOI_MAINPROC_UTL_PVT.get_next_shipment_num(x_line_locs.ln_po_line_id_tbl(i)));

    -- default line_location_id from sequence
    x_line_locs.line_loc_id_tbl(i) :=
      NVL(x_line_locs.line_loc_id_tbl(i),
      PO_PDOI_MAINPROC_UTL_PVT.get_next_line_loc_id);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'shipment type',
                  x_line_locs.shipment_type_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'shipment num',
                  x_line_locs.shipment_num_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'line loc id',
                  x_line_locs.line_loc_id_tbl(i));
    END IF;

    -- default terms_id from header,
    x_line_locs.terms_id_tbl(i) :=
      NVL(x_line_locs.terms_id_tbl(i), x_line_locs.hd_terms_id_tbl(i));

    d_position := 30;

    -- default freight_carrier, fob and freight_term from header
    x_line_locs.fob_tbl(i) :=
      NVL(x_line_locs.fob_tbl(i), x_line_locs.hd_fob_tbl(i));
    x_line_locs.freight_carrier_tbl(i) :=
      NVL(x_line_locs.freight_carrier_tbl(i), x_line_locs.hd_freight_carrier_tbl(i));
    x_line_locs.freight_term_tbl(i) :=
      NVL(x_line_locs.freight_term_tbl(i), x_line_locs.hd_freight_term_tbl(i));

           -- Added below code for bug 13905609
-- Before defaulting receipt required flag from purchasing options
-- checking at line type setup.
BEGIN

  po_shipments_sv8.get_matching_controls(
                       X_vendor_id     => x_line_locs.hd_vendor_id_tbl(i),
                       X_line_type_id  => x_line_locs.ln_line_type_id_tbl(i),
                       X_item_id       => x_line_locs.ln_item_id_tbl(i),
                       X_receipt_required_flag    => l_receipt_req_flag_temp,
                       X_inspection_required_flag => l_insp_req_flag_temp
                      );
   EXCEPTION
	    WHEN OTHERS THEN
	    l_receipt_req_flag_temp := NULL;
	    l_insp_req_flag_temp := NULL;
		 IF (PO_LOG.d_stmt) THEN
		    PO_LOG.stmt(d_module, d_position, 'Exception',
                    SQLERRM);
		 END IF;
	END;
--Ended code addition for bug 13905609

    -- default inspection_required_flag from system
    x_line_locs.inspection_required_flag_tbl(i) :=
      NVL(x_line_locs.inspection_required_flag_tbl(i),NVL(l_insp_req_flag_temp,
      PO_PDOI_PARAMS.g_sys.inspection_required_flag));




    -- default receipt_required_flag from system
    x_line_locs.receipt_required_flag_tbl(i) :=
      NVL(x_line_locs.receipt_required_flag_tbl(i),NVL(l_receipt_req_flag_temp,
      PO_PDOI_PARAMS.g_sys.receiving_flag));

-- Added for price discount to work as part of 9039292 bug
 IF ( x_line_locs.ln_unit_price_tbl(i) <> 0  ) THEN
 	IF (x_line_locs.price_override_tbl(i) IS NOT NULL) THEN
 		x_line_locs.price_discount_tbl(i) := ROUND(((x_line_locs.ln_unit_price_tbl(i) - x_line_locs.price_override_tbl(i))/x_line_locs.ln_unit_price_tbl(i)) * 100, 2);
 	ELSIF (x_line_locs.price_override_tbl(i) IS NULL AND x_line_locs.price_discount_tbl(i) IS NOT NULL) THEN
    		x_line_locs.price_override_tbl(i) := ROUND((((100 - x_line_locs.price_discount_tbl(i))/100) * x_line_locs.ln_unit_price_tbl(i)), 2);
    END IF;
   ELSE
          x_line_locs.price_override_tbl(i) :=0.0;
   END IF;


    -- default allow_sub_receipts_flag, qty_rcv_tolerance, and
    -- qty_rcv_exception_code
    -- only call the rcv procedure when necessary
    IF (x_line_locs.qty_rcv_tolerance_tbl(i) IS NULL OR
        x_line_locs.qty_rcv_exception_code_tbl(i) IS NULL) THEN

      d_position := 40;

    -- <<PDOI Enhancement Bug#17063664>>
    -- Passing order_type_lookup_code and purchase_basis to the api
    --   RCV_CORE_S.get_receiving_controls
    RCV_CORE_S.get_receiving_controls
    (
      p_order_type_lookup_code      => x_line_locs.ln_order_type_lookup_code_tbl(i),
      p_purchase_basis              => x_line_locs.ln_purchase_basis_tbl(i),
      p_line_location_id            => x_line_locs.line_loc_id_tbl(i),
      p_item_id                     => x_line_locs.ln_item_id_tbl(i),
      p_org_id                      => x_line_locs.ship_to_org_id_tbl(i),
      p_vendor_id                   => x_line_locs.hd_vendor_id_tbl(i),
      x_enforce_ship_to_loc_code    => l_enforce_ship_to_loc_code,
      x_allow_substitute_receipts   => l_allow_sub_receipts_flag,
      x_routing_id                  => l_receiving_routing_id,
      x_routing_name                => l_receiving_routing_name,
      x_qty_rcv_tolerance           => l_qty_rcv_tolerance,
      x_qty_rcv_exception_code      => l_qty_rcv_exception,
      x_days_early_receipt_allowed  => l_days_early_receipt_allowed,
      x_days_late_receipt_allowed   => l_days_late_receipt_allowed,
      x_receipt_days_exception_code => l_rct_days_exception_code
    );

      -- default qty_rcv_tolerance from receiving controls
      x_line_locs.qty_rcv_tolerance_tbl(i) :=
        NVL(x_line_locs.qty_rcv_tolerance_tbl(i), l_qty_rcv_tolerance);

      -- default qty_rcv_exception_code from receiving controls
      x_line_locs.qty_rcv_exception_code_tbl(i) :=
        NVL(x_line_locs.qty_rcv_exception_code_tbl(i), l_qty_rcv_exception);

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'qty_rcv_tolerance',
                    x_line_locs.qty_rcv_tolerance_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'qty_rcv_exception_code',
                    x_line_locs.qty_rcv_exception_code_tbl(i));
      END IF;
    END IF;

    -- set accrue_on_receipt_flag and firm_flag to NULL
    x_line_locs.accrue_on_receipt_flag_tbl(i) := NULL;
    x_line_locs.firm_flag_tbl(i) := NULL;

    -- ignore user's input of tax_name for quotation
    x_line_locs.tax_name_tbl(i) := NULL;

    -- set value_basis from order_type_lookup_code on line level
    x_line_locs.value_basis_tbl(i) := x_line_locs.ln_order_type_lookup_code_tbl(i);

    -- set matching_basis to NULL
    x_line_locs.matching_basis_tbl(i) := NULL;

    -- set outsourced_assembly to 2 since it is a required field
    x_line_locs.outsourced_assembly_tbl(i) := 2;
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
END default_locs_for_quotation;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_inspect_required_flag
--Function:
--  logic to default inspection_required_flag from item_id
--  in a batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_item_id_tbl
--    list of item_id values in current batch
--IN OUT:
--  x_inspection_required_flag_tbl
--    contains the default result if original value is null;
--    original value won't be changed if it is not null
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_inspect_required_flag
(
  p_key                          IN po_session_gt.key%TYPE,
  p_index_tbl                    IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl                  IN PO_TBL_NUMBER,
  x_inspection_required_flag_tbl IN OUT NOCOPY PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_inspect_required_flag';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variable to hold the default query result
  l_index_tbl                    PO_TBL_NUMBER;
  l_result_tbl                   PO_TBL_VARCHAR1;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- retrieve the default value from database
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key, num1, char1)
  SELECT p_key,
         p_index_tbl(i),
         inspection_required_flag
  FROM   mtl_system_items
  WHERE  p_item_id_tbl(i) IS NOT NULL
  AND    x_inspection_required_flag_tbl(i) IS NULL
  AND    inventory_item_id = p_item_id_tbl(i)
  AND    organization_id = PO_PDOI_PARAMS.g_sys.def_inv_org_id;

  d_position := 10;

  -- get result from temp table
  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, char1 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- set result back to x_inspection_required_flag_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'default inspection required flag',
                  l_result_tbl(i));
    END IF;

    x_inspection_required_flag_tbl(l_index_tbl(i)) := l_result_tbl(i);
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
END default_inspect_required_flag;

-- <<PDOI Enhancement Bug#17063664 Start>
-----------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_req
--Function:
--  default information from the requisition if backing req line id is provided;
--  the information can be defaulted from requisition include the below attributes:
--    DESTINATION_ORGANIZATION_ID, DELIVER_TO_LOCATION_ID, NEED_BY_DATE, VMI_FLAG
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_ln_req_line_id_tbl
--    list of requisition_line_id values in current batch
--IN OUT:
--  x_dest_org_id_tbl
--    contains destination_organization_id values of the requisition;
--  x_deliver_to_loc_id_tbl
--    contains deliver_to_location_id values of the requisition;
--  x_need_by_date_tbl
--    contains need_by_date values of the requisition;
--  x_vmi_flag_tbl
--    contains vmi_flag values of the requisition;
--OUT:
--IN OUT:
--  p_lines
--    record containing all line info within the batch
--IN OUT: None
--OUT: None
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_info_from_req
(
  p_key                       IN po_session_gt.key%TYPE,
  p_index_tbl                 IN DBMS_SQL.NUMBER_TABLE,
  p_ln_req_line_id_tbl        IN PO_TBL_NUMBER,
  x_need_by_date_tbl          IN OUT NOCOPY PO_TBL_DATE,
  x_vmi_flag_tbl              IN OUT NOCOPY PO_TBL_VARCHAR1,
  x_drop_ship_flag_tbl        IN OUT NOCOPY PO_TBL_VARCHAR1,
  x_note_to_receiver_tbl      IN OUT NOCOPY PO_TBL_VARCHAR2000,
  x_wip_entity_id_tbl         IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_info_from_req';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold result read from temp table
  local_index_tbl             PO_TBL_NUMBER;
  l_index_tbl                 PO_TBL_NUMBER;
  l_index                     NUMBER;

  l_need_by_date_tbl          PO_TBL_DATE;
  l_vmi_flag_tbl              PO_TBL_VARCHAR1;
  l_drop_ship_flag_tbl        PO_TBL_VARCHAR1;
  l_note_to_receiver_tbl      PO_TBL_VARCHAR2000;
  l_wip_entity_id_tbl         PO_TBL_NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT p_key,
           p_index_tbl(i)
    FROM   DUAL;

  d_position := 20;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  d_position := 30;

  -- retrieve the values based on requisition line id
  SELECT prl.need_by_date
       , prl.vmi_flag
       , prl.drop_ship_flag
       , prl.note_to_receiver
       , prl.wip_entity_id
       , index_tbl.val
  BULK COLLECT INTO l_need_by_date_tbl
     , l_vmi_flag_tbl
     , l_drop_ship_flag_tbl
     , l_note_to_receiver_tbl
     , l_wip_entity_id_tbl
     , local_index_tbl
  FROM po_requisition_lines_all prl
     , (SELECT column_value val, rownum rn
        FROM table(p_ln_req_line_id_tbl)) req_line_id_tbl
     , (SELECT column_value val, rownum rn
        FROM table(l_index_tbl)) index_tbl
  WHERE req_line_id_tbl.val IS NOT NULL
    AND prl.requisition_line_id = req_line_id_tbl.val
    AND index_tbl.rn            = req_line_id_tbl.rn;

  d_position := 40;

  -- set the result in OUT parameters
  FOR i IN 1..local_index_tbl.COUNT
  LOOP

    l_index := local_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', local_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'need_by_date', l_need_by_date_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'vmi_flag', l_vmi_flag_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'drop_ship_fla', l_drop_ship_flag_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'note_to_receiver', l_note_to_receiver_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'wip_entity_id', l_wip_entity_id_tbl(i));
    END IF;

    x_need_by_date_tbl(l_index)      := l_need_by_date_tbl(i);
    x_vmi_flag_tbl(l_index)          := l_vmi_flag_tbl(i);
    x_drop_ship_flag_tbl(l_index)    := l_drop_ship_flag_tbl(i);
    x_note_to_receiver_tbl(l_index)  := l_note_to_receiver_tbl(i);
    x_wip_entity_id_tbl(l_index)     := l_wip_entity_id_tbl(i);

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
END default_info_from_req;

-- <<PDOI Enhancement Bug#17063664 End>

-----------------------------------------------------------------------
--Start of Comments
--Name: default_ship_to_org_id
--Function:
--  logic to default ship_to_organziation_id from ship_to_location_id
--  in batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_ship_to_loc_id_tbl
--    list of ship_to_location_id values in current batch
--IN OUT:
--  x_ship_to_org_id_tbl
--    contains the default result if original value is null;
--    original value won't be changed if it is not null
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_ship_to_org_id
(
  p_key                          IN po_session_gt.key%TYPE,
  p_index_tbl                    IN DBMS_SQL.NUMBER_TABLE,
  p_ship_to_loc_id_tbl           IN PO_TBL_NUMBER,
  x_ship_to_org_id_tbl           IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_ship_to_org_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variable to hold the default query result
  l_index_tbl                    PO_TBL_NUMBER;
  l_result_tbl                   PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  --bug 19264990 begin
  --initialize out parameters if parameter is not initialize yet
  IF (x_ship_to_org_id_tbl IS NULL) THEN
    x_ship_to_org_id_tbl := PO_TBL_NUMBER();
    x_ship_to_org_id_tbl.EXTEND(p_index_tbl.COUNT);
  ELSE
    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module, 'x_ship_to_org_id_tbl',
                        x_ship_to_org_id_tbl);
    END IF;
  END IF;
  --bug 19264990 end

  -- default ship_to_organization_id from ship_to_location_id
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key, num1, num2)
  SELECT p_key,
         p_index_tbl(i),
         inventory_organization_id
  FROM   hr_locations_v
  WHERE  p_ship_to_loc_id_tbl(i) IS NOT NULL
  AND    x_ship_to_org_id_tbl(i) IS NULL
  AND    location_id = p_ship_to_loc_id_tbl(i)
  AND    ship_to_site_flag = 'Y';

  d_position := 10;

  -- get result from temp table
  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- set result in x_ship_to_org_id_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'default ship_to org id',
                  l_result_tbl(i));
    END IF;

    x_ship_to_org_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
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
END default_ship_to_org_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_close_tolerances
--Function:
--  logic to default invoice_close_tolerance and receive_close_tolerance
--  in batch mode. The default order is as follows:
--  1. default with 100 if consigned flag is 'Y'
--  2. default from item_id and ship_to_organziation_id
--  3. default from item_id and default inventory org id
--  4. default receive_close_tolerance from line_type_id
--  5. default from system parameters
--  6. default to 0
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_item_id
--    list of item_id values in current batch
--  p_ship_to_org_id_tbl
--    list of ship_to_organization_id values in current batch
--  p_line_type_id
--    list of line_type_id values in current batch
--  p_consigned_flag_tbl
--    list of consigned_flag values of lines in current batch
--IN OUT:
--  x_invoice_close_tolerance_tbl
--    contains the default result if original value is null;
--    original value won't be changed if it is not null
--  x_receive_close_tolerance_tbl
--    contains the default result if original value is null;
--    original value won't be changed if it is not null
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_close_tolerances
(
  p_key                          IN po_session_gt.key%TYPE,
  p_index_tbl                    IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl                  IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl           IN PO_TBL_NUMBER,
  p_line_type_id_tbl             IN PO_TBL_NUMBER,
  p_consigned_flag_tbl           IN PO_TBL_VARCHAR1,
  x_invoice_close_tolerance_tbl  IN OUT NOCOPY PO_TBL_NUMBER,
  x_receive_close_tolerance_tbl  IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_close_tolerances';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variable to hold the default query result
  l_index_tbl                    PO_TBL_NUMBER;
  l_invoice_tolerance_tbl        PO_TBL_NUMBER;
  l_receive_tolerance_tbl        PO_TBL_NUMBER;

  -- temp index value
  l_index                        NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- <<PDOI Enhancement Bug#17063664 Start>>
  -- default invoice_close_tolerance with 100 if consigned_flag is 'Y'
  --  and receive_close_tolerance with 100 when calling from consumption advice
  FOR i IN 1..p_index_tbl.COUNT
  LOOP
    IF p_consigned_flag_tbl(i) = 'Y' THEN
      x_invoice_close_tolerance_tbl(i) :=  NVL(x_invoice_close_tolerance_tbl(i), 100);
    END IF;

    IF (PO_PDOI_PARAMS.g_request.calling_module =
          PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
      x_receive_close_tolerance_tbl(i) :=  NVL(x_receive_close_tolerance_tbl(i), 100);
    END IF;
  END LOOP;
  -- <<PDOI Enhancement Bug#17063664 End>>

  -- first, default from item_id and ship_to_organization_id
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key, num1, num2, num3)
  SELECT p_key,
         p_index_tbl(i),
         invoice_close_tolerance,
         receive_close_tolerance
  FROM   mtl_system_items
  WHERE  p_item_id_tbl(i) IS NOT NULL
  AND    (x_invoice_close_tolerance_tbl(i) IS NULL OR
          x_receive_close_tolerance_tbl(i) IS NULL)
  AND    inventory_item_id = p_item_id_tbl(i)
  AND    organization_id   = p_ship_to_org_id_tbl(i);

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, num2, num3 BULK COLLECT INTO
    l_index_tbl, l_invoice_tolerance_tbl, l_receive_tolerance_tbl;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    x_invoice_close_tolerance_tbl(l_index) :=
      NVL(x_invoice_close_tolerance_tbl(l_index),
      l_invoice_tolerance_tbl(i));
    x_receive_close_tolerance_tbl(l_index) :=
      NVL(x_receive_close_tolerance_tbl(l_index),
      l_receive_tolerance_tbl(i));

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'invoice close tolerance',
                  x_invoice_close_tolerance_tbl(l_index));
      PO_LOG.stmt(d_module, d_position, 'receive close tolerance',
                  x_receive_close_tolerance_tbl(l_index));
    END IF;
  END LOOP;

  d_position := 30;

  -- Second, default from item_id and default inventory org id
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key, num1, num2, num3)
  SELECT p_key,
         p_index_tbl(i),
         invoice_close_tolerance,
         receive_close_tolerance
  FROM   mtl_system_items
  WHERE  p_item_id_tbl(i) IS NOT NULL
  AND    (x_invoice_close_tolerance_tbl(i) IS NULL OR
          x_receive_close_tolerance_tbl(i) IS NULL)
  AND    inventory_item_id = p_item_id_tbl(i)
  AND    organization_id   = PO_PDOI_PARAMS.g_sys.def_inv_org_id;

  d_position := 40;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, num2, num3 BULK COLLECT INTO
    l_index_tbl, l_invoice_tolerance_tbl, l_receive_tolerance_tbl;

  d_position := 50;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    x_invoice_close_tolerance_tbl(l_index) :=
      NVL(x_invoice_close_tolerance_tbl(l_index),
      l_invoice_tolerance_tbl(i));
    x_receive_close_tolerance_tbl(l_index) :=
      NVL(x_receive_close_tolerance_tbl(l_index),
      l_receive_tolerance_tbl(i));

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'invoice close tolerance',
                  x_invoice_close_tolerance_tbl(l_index));
      PO_LOG.stmt(d_module, d_position, 'receive close tolerance',
                  x_receive_close_tolerance_tbl(l_index));
    END IF;
  END LOOP;

  d_position := 60;

  -- Third, default receive_close_tolerance from line_type_id
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key, num1, num2)
  SELECT p_key,
         p_index_tbl(i),
         receipt_close
  FROM   po_line_types_v
  WHERE  p_line_type_id_tbl(i) IS NOT NULL
  AND    x_receive_close_tolerance_tbl(i) IS NULL
  AND    line_type_id = p_line_type_id_tbl(i);

  d_position := 70;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, num2 BULK COLLECT INTO
    l_index_tbl, l_receive_tolerance_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'receive close tolerance',
                  l_receive_tolerance_tbl(i));
    END IF;

    x_receive_close_tolerance_tbl(l_index_tbl(i)) := l_receive_tolerance_tbl(i);
  END LOOP;

  d_position := 80;

  -- Last, default from system parameters using loop
  FOR i IN 1..p_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      PO_LOG.stmt(d_module, d_position, 'invoice close tolerance',
                  x_invoice_close_tolerance_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'receive close tolerance',
                  x_receive_close_tolerance_tbl(i));
    END IF;

    x_invoice_close_tolerance_tbl(i) :=
      COALESCE(x_invoice_close_tolerance_tbl(i),
               PO_PDOI_PARAMS.g_sys.invoice_close_tolerance,
               0);
    x_receive_close_tolerance_tbl(i) :=
      COALESCE(x_receive_close_tolerance_tbl(i),
               PO_PDOI_PARAMS.g_sys.receive_close_tolerance,
               0);
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
END default_close_tolerances;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_invoice_match_options
--Function:
--  logic to default invoice_match_options
--  in batch mode. The default order is as follows:
--  1. default from vendor_site_id
--  2. default from vendor id
--  3. default from system parameters
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_line_loc_id_tbl
--    list of line_location_id values in current batch
--  p_item_id_tbl
--    list of item_id values in current batch
--  p_vendor_id_tbl
--    list of vendor_id values in current batch
--  p_vendor_site_id_tbl
--    list of vendor_site_id values in current batch
--  p_ship_to_org_id_tbl
--    list of ship_to_org_id values in current batch
--  p_consigned_flag_tbl
--    list of consigned_flag_tbl values in current batch
--  p_outsourced_assembly_tbl
--    list of outsourced_assembly values in current batch
--IN OUT:
--  x_match_option_tbl
--    contains the default result if original value is null;
--    original value won't be changed if it is not null
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_invoice_match_options
(
  p_key                          IN po_session_gt.key%TYPE,
  p_index_tbl                    IN DBMS_SQL.NUMBER_TABLE,
  p_line_loc_id_tbl              IN PO_TBL_NUMBER,
  p_item_id_tbl                  IN PO_TBL_NUMBER,
  p_vendor_id_tbl                IN PO_TBL_NUMBER,
  p_vendor_site_id_tbl           IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl           IN PO_TBL_NUMBER,
  p_consigned_flag_tbl           IN PO_TBL_VARCHAR1,
  p_outsourced_assembly_tbl      IN PO_TBL_NUMBER,
  p_shipment_type_tbl            IN PO_TBL_VARCHAR30, --Bug#17712442:: FIX
  x_match_option_tbl             IN OUT NOCOPY PO_TBL_VARCHAR30
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_invoice_match_options';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variable to hold the default query result
  l_index_tbl                    PO_TBL_NUMBER;
  l_result_tbl                   PO_TBL_VARCHAR30;

  -- variable to hold match option from ap setup
  l_ap_invoice_match_option      VARCHAR2(30);

  -- variable to hold the result of lcm check
  l_return_status                PO_TBL_VARCHAR30;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  -- <<PDOI Enhancement Bug#17063664 Start>>

  l_return_status := PO_TBL_VARCHAR30();
  l_return_status.EXTEND(p_index_tbl.COUNT);

  -- 1. default match option with 'P' when consigned
  FOR i IN 1..p_index_tbl.COUNT
  LOOP

    -- <<Incorporating the fix#16655207>>
    /* Added as part of bug 16655207 to verify LCM enabled flag. */
    IF (p_item_id_tbl(i) IS NOT NULL ) THEN
      d_position := 20;
      l_return_status(i) := inv_utilities.inv_check_lcm(p_item_id_tbl(i),
                                                        p_ship_to_org_id_tbl(i),
                                                        p_consigned_flag_tbl(i),
                                                        p_outsourced_assembly_tbl(i),
                                                        p_vendor_id_tbl(i),
                                                        p_vendor_site_id_tbl(i),
                                                        p_line_loc_id_tbl(i));

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'index', p_index_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'l_return_status', l_return_status(i));
      END IF;

      IF(l_return_status(i) = 'Y') then
        x_match_option_tbl(i) := 'R';
      END IF;
    END IF;
    --<<Bug#16655207 End>>

    d_position := 30;
     IF (p_consigned_flag_tbl(i) = 'Y') OR  --Bug#19501198
	     (PO_PDOI_PARAMS.g_request.calling_module =
              PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'index', p_index_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'new match option', 'P');
      END IF;

      x_match_option_tbl(i) := 'P';
    END IF;

	--Bug#17712442:: Fix Start
	IF Nvl(p_shipment_type_tbl(i),'STANDARD') = 'PREPAYMENT' THEN
	    IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'index', p_index_tbl(i));
		  PO_LOG.stmt(d_module, d_position, 'Shipment Type', p_shipment_type_tbl(i));
          PO_LOG.stmt(d_module, d_position, 'new match option', 'P');
        END IF;
          x_match_option_tbl(i) := 'P';
	END IF;
    --Bug#17712442:: Fix End

  END LOOP;
  -- <<PDOI Enhancement Bug#17063664 End>>

  d_position := 40;

  -- 2. get default value from vendor_site
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key, num1, char1)
  SELECT p_key,
         p_index_tbl(i),
         match_option
  FROM   po_vendor_sites
  WHERE  p_vendor_site_id_tbl(i) IS NOT NULL
  AND    x_match_option_tbl(i) IS NULL
  AND    vendor_site_id = p_vendor_site_id_tbl(i);

  d_position := 50;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, char1 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new match option', l_result_tbl(i));
    END IF;

    x_match_option_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

  d_position := 60;

  -- 3. default value from vendor, same as vendor_site
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key, num1, char1)
  SELECT p_key,
         p_index_tbl(i),
         match_option
  FROM   po_vendors
  WHERE  p_vendor_id_tbl(i) IS NOT NULL
  AND    x_match_option_tbl(i) IS NULL
  AND    vendor_id = p_vendor_id_tbl(i);

  d_position := 70;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, char1 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new match option', l_result_tbl(i));
    END IF;

    x_match_option_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

  d_position := 80;

  -- <<PDOI Enhancement Bug#17063664 Start>>
  -- 5. default match option from ap product setup

  SELECT aps.match_option
  INTO l_ap_invoice_match_option
  FROM ap_product_setup aps;

  FOR i IN 1..p_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      PO_LOG.stmt(d_module, d_position, 'curr match option', x_match_option_tbl(i));
    END IF;

    x_match_option_tbl(i) :=
      NVL(x_match_option_tbl(i), l_ap_invoice_match_option);
  END LOOP;
  -- <<PDOI Enhancement Bug#17063664 End>>

  d_position := 90;

  -- 5. get default value from financial system parameter using loop
  FOR i IN 1..p_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      PO_LOG.stmt(d_module, d_position, 'curr match option', x_match_option_tbl(i));
    END IF;

    x_match_option_tbl(i) :=
      NVL(x_match_option_tbl(i), PO_PDOI_PARAMS.g_sys.invoice_match_option);
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
END default_invoice_match_options;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_accrue_on_receipt_flag
--Function:
--  logic to default accrue_on_receipt_flag based on item info
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_itemid_tbl
--    list of item_id values in current batch
--  p_ship_to_org_id_tbl
--    list of ship_to_org_id values in current batch
--  p_receipt_required_flag_tbl
--    list of receipt_required_flag values in current batch
--  p_consigned_flag_tbl
--    list of consigned_flag values in current batch
--  p_txn_flow_header_id_tbl
--    list of txn_flow_header_id values in current batch
--  p_pcard_id_tbl
--    list of pcard_id values in current batch
--  p_shipment_type_tbl
--    list of shipment_type values in current batch
--IN OUT:
--  x_accrue_on_receipt_flag_tbl
--    contains the default result if original value is null;
--    original value won't be changed if it is not null
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_accrue_on_receipt_flag
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl                IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl         IN PO_TBL_NUMBER,
  p_receipt_required_flag_tbl  IN PO_TBL_VARCHAR1,
  p_consigned_flag_tbl         IN PO_TBL_VARCHAR1,
  p_txn_flow_header_id_tbl     IN PO_TBL_NUMBER,
  p_pcard_id_tbl               IN PO_TBL_NUMBER,
  p_shipment_type_tbl          IN PO_TBL_VARCHAR30,
  p_intf_line_loc_id_tbl       IN PO_TBL_NUMBER,  --Bug 17604686
  p_ln_req_line_id_tbl         IN PO_TBL_NUMBER,  --Bug 18652325
  x_accrue_on_receipt_flag_tbl IN OUT NOCOPY PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_accrue_on_receipt_flag';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

   -- variable to hold the default query result
  l_index_tbl                    PO_TBL_NUMBER;
  l_outside_op_flag_tbl          PO_TBL_VARCHAR1;
  l_stock_enabled_flag_tbl       PO_TBL_VARCHAR1;
  l_dest_type_code_tbl           PO_TBL_VARCHAR100;  --Bug 17604686

  l_item_status                  VARCHAR2(1);
  l_index                        NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_item_id_tbl', p_item_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_ship_to_org_id_tbl', p_ship_to_org_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_receipt_required_flag_tbl', p_receipt_required_flag_tbl);
    PO_LOG.proc_begin(d_module, 'p_consigned_flag_tbl', p_consigned_flag_tbl);
    PO_LOG.proc_begin(d_module, 'p_txn_flow_header_id_tbl', p_txn_flow_header_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_pcard_id_tbl', p_pcard_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_ln_req_line_id_tbl', p_ln_req_line_id_tbl);
  END IF;

  -- get default values from item
  -- first, default from item_id and ship_to_organization_id
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key, num1, char1, char2, char3)
  SELECT p_key,
         p_index_tbl(i),
         outside_operation_flag,
         nvl(stock_enabled_flag,'N'),
         (SELECT prl.destination_type_code
          FROM po_requisition_lines_all prl
          WHERE prl.requisition_line_id = p_ln_req_line_id_tbl(i)) --Bug 18652325
  FROM   mtl_system_items
  WHERE  p_item_id_tbl(i) IS NOT NULL
 -- AND    x_accrue_on_receipt_flag_tbl(i) IS NULL Bug#19598349 FIX
  AND    inventory_item_id = p_item_id_tbl(i)
  AND    organization_id   = p_ship_to_org_id_tbl(i);

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, char1, char2, char3 BULK COLLECT INTO
    l_index_tbl, l_outside_op_flag_tbl, l_stock_enabled_flag_tbl, l_dest_type_code_tbl;  --Bug 18652325

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    d_position := 20;

    l_index := l_index_tbl(i);

    -- Bug 18652325
    -- If backing requisition exists then take item status based on destination_type_code

    l_item_status := NULL;
    SELECT DECODE(l_dest_type_code_tbl(i),'INVENTORY','E','EXPENSE','D','SHOP FLOOR','O')
    INTO l_item_status
    FROM dual;

    IF l_item_status IS NULL THEN
      -- get item status
      IF (l_outside_op_flag_tbl(i) = 'Y') THEN
        l_item_status := 'O'; -- Outside Processing
      ELSE
        IF (l_stock_enabled_flag_tbl(i) = 'Y') THEN
          l_item_status := 'E'; -- Inventory
        ELSE
          l_item_status := 'D'; -- Expense
        END IF;
      END IF;
    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'item status', l_item_status);
    END IF;

    -- set default value
    IF (l_item_status = 'O') THEN
      x_accrue_on_receipt_flag_tbl(l_index) := 'Y';
    ELSIF (l_item_status = 'E') THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'INV installed',
                    PO_PDOI_PARAMS.g_product.inv_installed);
        PO_LOG.stmt(d_module, d_position, 'default expense accrual code',
                    PO_PDOI_PARAMS.g_sys.expense_accrual_code);
      END IF;

      IF (PO_PDOI_PARAMS.g_product.inv_installed = FND_API.g_TRUE) then
        x_accrue_on_receipt_flag_tbl(l_index) := 'Y';
      ELSE
        IF (PO_PDOI_PARAMS.g_sys.expense_accrual_code = 'PERIOD END') then
          x_accrue_on_receipt_flag_tbl(l_index) := 'N';
        ELSE
          x_accrue_on_receipt_flag_tbl(l_index) :=
            p_receipt_required_flag_tbl(l_index);
        END IF;
      END IF;
    ELSE    -- l_item_status := 'D'
      IF (PO_PDOI_PARAMS.g_sys.expense_accrual_code = 'PERIOD END') THEN
        x_accrue_on_receipt_flag_tbl(l_index) := 'N';
      ELSE
        x_accrue_on_receipt_flag_tbl(l_index) := NVL(x_accrue_on_receipt_flag_tbl(l_index), --Bug#19598349
	                                                 NVL(p_receipt_required_flag_tbl(l_index),'Y'));

      END IF;
    END IF;
  END LOOP;

  -- Bug 18652325 Deleting l_dest_type_code_tbl to reuser
  l_dest_type_code_tbl.DELETE;

  --Bug 17604686 begin
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key,char1)
  SELECT p_key,destination_type_code
  FROM po_distributions_interface
  WHERE interface_line_location_id = p_intf_line_loc_id_tbl(i)
  AND rownum = 1
  -- Bug 18652325 Taking from req_lines.
  UNION
  SELECT p_key, destination_type_code
  FROM po_requisition_lines_all
  WHERE requisition_line_id = p_ln_req_line_id_tbl(i)
  -- Bug 18702384 taking lines not found by above 2 sqls
  -- Since the loop below needs to be excuted for all p_index_tbl
  UNION
  SELECT p_key, NULL
  FROM dual
  WHERE p_ln_req_line_id_tbl(i) IS NULL
  AND NOT EXISTS (SELECT 1
                  FROM po_distributions_interface
                  WHERE interface_line_location_id = p_intf_line_loc_id_tbl(i));


  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING char1 BULK COLLECT INTO l_dest_type_code_tbl;
  --Bug 17604686 end

  /* Bug 10286564 Code handling for the case of Expense items when item_id is null */
  FOR i IN 1..p_index_tbl.COUNT
    LOOP

    IF p_item_id_tbl(i) IS NULL THEN
    d_position := 30;

    l_index := p_index_tbl(i);

	  --Bug 17604686
	  IF l_dest_type_code_tbl.EXISTS(i) AND -- Bug#17998114
         l_dest_type_code_tbl(i) = 'SHOP FLOOR' THEN
         x_accrue_on_receipt_flag_tbl(l_index)  := 'Y';
      ELSE

         l_item_status := 'D'; -- Expense

         IF (PO_LOG.d_stmt) THEN
           PO_LOG.stmt(d_module, d_position, 'l_index = ', l_index);
           PO_LOG.stmt(d_module, d_position, 'l_item_status = ', l_item_status );
         END IF;

         -- set default value
         IF (PO_PDOI_PARAMS.g_sys.expense_accrual_code = 'PERIOD END') THEN
           x_accrue_on_receipt_flag_tbl(l_index) := 'N';
         ELSE
           x_accrue_on_receipt_flag_tbl(l_index) :=  NVL(x_accrue_on_receipt_flag_tbl(l_index), --Bug#19598349
	                                                 NVL(p_receipt_required_flag_tbl(l_index),'Y'));
         END IF;
      END IF; --Bug 17604686
    END IF;

   -- <<PDOI Enhancement Bug#17063664 START>>
   -- Code handling for the case of PCard ID, Transaction Flow ID, Consigned Flag and shipment type

     IF (p_pcard_id_tbl(i) IS NOT NULL) THEN
       x_accrue_on_receipt_flag_tbl(i) := 'N';
     ELSIF (p_txn_flow_header_id_tbl(i) IS NOT NULL) THEN
       x_accrue_on_receipt_flag_tbl(i) := 'Y';
     ELSIF (p_consigned_flag_tbl(i) = 'Y') THEN
       x_accrue_on_receipt_flag_tbl(i) := 'N';
     ELSIF (p_shipment_type_tbl(i) = 'PREPAYMENT') THEN
       x_accrue_on_receipt_flag_tbl(i) := 'N';
     END IF;

    -- <<PDOI Enhancement Bug#17063664 END>>

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
END default_accrue_on_receipt_flag;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_secondary_unit_of_meas
--Function:
--  logic to default secondary_unit_of_measure from item_id and
--  ship_to_organization_id in a batch mode
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the defaulted result
--  p_index_tbl
--    indexes of the records
--  p_item_id_tbl
--    list of item_id values in current batch
--  p_ship_to_org_id_tbl
--    list of ship_to_organization_id values in current batch
--IN OUT:
--  x_secondary_unit_of_meas_tbl
--    contains the default result if original value is null;
--    original value won't be changed if it is not null
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_secondary_unit_of_meas
(
  p_key                          IN po_session_gt.key%TYPE,
  p_index_tbl                    IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl                  IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl           IN PO_TBL_NUMBER,
  x_secondary_unit_of_meas_tbl   IN OUT NOCOPY PO_TBL_VARCHAR30
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_secondary_unit_of_meas';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variable to hold the default query result
  l_index_tbl                    PO_TBL_NUMBER;
  l_result_tbl                   PO_TBL_VARCHAR30;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_item_id_tbl', p_item_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_ship_to_org_id_tbl', p_ship_to_org_id_tbl);
  END IF;

  -- retrieve the default value from database
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key, num1, char1)
  SELECT p_key,
         p_index_tbl(i),
         uom.unit_of_measure
  FROM   mtl_system_items item,
         mtl_units_of_measure uom
  WHERE  p_item_id_tbl(i) IS NOT NULL
  AND    p_ship_to_org_id_tbl(i) IS NOT NULL
  AND    x_secondary_unit_of_meas_tbl(i) IS NULL
  AND    item.inventory_item_id = p_item_id_tbl(i)
  AND    item.organization_id = p_ship_to_org_id_tbl(i)
  AND    item.tracking_quantity_ind = 'PS'
  AND    item.secondary_uom_code = uom.uom_code;

  d_position := 10;

  -- get result from temp table
  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, char1 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- set result back to x_inspection_required_flag_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'default secondary_unit_of_measure',
                  l_result_tbl(i));
    END IF;

    x_secondary_unit_of_meas_tbl(l_index_tbl(i)) := l_result_tbl(i);
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
END default_secondary_unit_of_meas;

-----------------------------------------------------------------------
--Start of Comments
--Name: populate_error_flag
--Function:
--  corresponding value in error_flag_tbl will be set with value FND_API.G_FALSE.
--Parameters:
--IN:
--p_results
--  The validation results that contains the errored line information.
--IN OUT:
--p_line_locs
--  The record contains the values to be validated.
--  If there is error(s) on any attribute of the price differential row,
--  corresponding value in error_flag_tbl will be set with value
--  FND_API.g_TRUE.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE populate_error_flag
(
  x_results           IN     po_validation_results_type,
  x_line_locs         IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'populate_error_flag';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index_tbl      DBMS_SQL.number_table;
  l_index          NUMBER;
  l_intf_header_id NUMBER;
  l_remove_err_line_loc_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_remove_err_line_tbl     PO_TBL_NUMBER := PO_TBL_NUMBER();
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  FOR i IN 1 .. x_line_locs.intf_line_loc_id_tbl.COUNT LOOP
      l_index_tbl(x_line_locs.intf_line_loc_id_tbl(i)) := i;
  END LOOP;

  d_position := 10;

  FOR i IN 1 .. x_results.entity_id.COUNT LOOP
     l_index := l_index_tbl(x_results.entity_id(i));

     -- Bug 5215781:
     -- set error_flag to TRUE for all remaining records if error threshold is
     -- hit for CATALOG UPLOAD
     IF (PO_PDOI_PARAMS.g_request.calling_module =
           PO_PDOI_CONSTANTS.g_call_mod_CATALOG_UPLOAD AND
         PO_PDOI_PARAMS.g_docs_info(PO_PDOI_PARAMS.g_request.interface_header_id)
           .err_tolerance_exceeded = FND_API.g_TRUE) THEN
       d_position := 20;

       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module, d_position, 'after error tolerance exceeded, collect error on index', l_index);
       END IF;

       -- collect intf_line_loc_ids to remove the errors from error intf table
       IF (NOT PO_PDOI_PARAMS.g_errored_lines.EXISTS(x_line_locs.intf_line_id_tbl(l_index))) THEN
         d_position := 30;

         l_remove_err_line_tbl.EXTEND;
         l_remove_err_line_loc_tbl.EXTEND;
         l_remove_err_line_tbl(l_remove_err_line_tbl.COUNT) := x_line_locs.intf_line_id_tbl(l_index);
         l_remove_err_line_loc_tbl(l_remove_err_line_loc_tbl.COUNT) := x_line_locs.intf_line_loc_id_tbl(l_index);
       END IF;
     ELSIF (x_results.result_type(i) = po_validations.c_result_type_failure) THEN
        d_position := 40;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'set error on index', l_index);
        END IF;

        x_line_locs.error_flag_tbl(l_index) := FND_API.g_TRUE;

        -- Bug 5215781:
        -- price break level errors will be counted in line errors and threshold will be
        -- checked; If threshold is hit, reject all price break records that are processed
        -- after the current record and remove the errors from interface table for those
        -- records
        IF (NOT PO_PDOI_PARAMS.g_errored_lines.EXISTS(x_line_locs.intf_line_id_tbl(l_index))) THEN
          d_position := 50;

          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'set error on line',
                        x_line_locs.intf_line_id_tbl(l_index));
          END IF;

          -- set corresponding line to ERROR
          PO_PDOI_PARAMS.g_errored_lines(x_line_locs.intf_line_id_tbl(l_index)) := 'Y';

          l_intf_header_id := x_line_locs.intf_header_id_tbl(l_index);
          PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_errored_lines
            := PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_errored_lines +1;

          -- check threshold
          IF (PO_PDOI_PARAMS.g_request.calling_module =
                PO_PDOI_CONSTANTS.g_call_mod_CATALOG_UPLOAD AND
              PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_errored_lines
                = PO_PDOI_PARAMS.g_request.err_lines_tolerance) THEN
            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module, d_position, 'threshold hit on line',
                          x_line_locs.intf_line_id_tbl(l_index));
            END IF;

            PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).err_tolerance_exceeded := FND_API.g_TRUE;

            -- reject all rows after this row
            FOR j IN l_index+1..x_line_locs.rec_count LOOP
              x_line_locs.error_flag_tbl(j) := FND_API.g_TRUE;
            END LOOP;
          END IF;
        END IF;
     END IF;
  END LOOP;

  d_position := 60;

  -- Bug 5215781:
  -- remove the errors for price breaks from po_interface_errors if those records are supposed to be processed
  -- after the price break where we hit the error tolerance; And they do not belong to any line that has
  -- already been counted in g_errored_lines. That means, we want to rollback some changes on po_interface_errors
  -- if error tolerance is reached at some point
  PO_INTERFACE_ERRORS_UTL.flush_errors_tbl;

  FORALL i IN 1..l_remove_err_line_loc_tbl.COUNT
    DELETE FROM PO_INTERFACE_ERRORS
    WHERE interface_line_location_id = l_remove_err_line_loc_tbl(i)
    AND   interface_line_id = l_remove_err_line_tbl(i);

  d_position := 70;

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

-----------------------------------------------------------------------
--Start of Comments
--Name: process_pricing_rejected_rec
--Function:
--<PDOI Enhancement Bug#17063664>
--Bug#19528138 : Revamped all the queries by removing plsql table types
-- from the from clause
-- Error is thrown for all the record from the interface tables
-- This procedure rejects records which errored out during pricing call.
-- Also performs price validations after pricing call.
-- And rejects records which have NULL price.
-- It deletes data from draft tables and rejects the interface.
--Parameters:
--IN:
-- pricing_attributes_rec
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_pricing_rejected_rec(pricing_attributes_rec  IN PO_PDOI_TYPES.pricing_attributes_rec_type)
IS
  d_api_name CONSTANT VARCHAR2(30)  := 'process_pricing_rejected_rec';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_reject_line_id_tbl  PO_TBL_NUMBER;
  l_reject_draft_id_tbl PO_TBL_NUMBER;
  l_reject_mssg         PO_TBL_VARCHAR30;
  l_reject_int_line_tbl PO_TBL_NUMBER;
  l_reject_int_hdr_tbl  PO_TBL_NUMBER;
  l_reject_int_loc_tbl  PO_TBL_NUMBER;
  l_price_tbl           PO_TBL_NUMBER;
  l_key NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position:=10;

  l_key := PO_CORE_S.get_session_gt_nextval;
  -- Identify lines with  error status from pricing call

  FORALL i IN indices OF pricing_attributes_rec.po_line_id_tbl
  INSERT INTO po_session_gt
              (key,
               num1,  -- po_line_id
               num2,  -- draft_id
               char1, -- Return Message
               num3,  -- interface line id
               num4,  -- interface header id
               num5,  -- interface line loc id
               num6)  -- price
        SELECT l_key,
               pricing_attributes_rec.po_line_id_tbl(i),
               pricing_attributes_rec.draft_id_tbl(i),
               pricing_attributes_rec.return_mssg_tbl(i),
               PLI.interface_line_id,
               PLI.interface_header_id,
               NULL, -- interface line loc id
               PLI.unit_price
        FROM   po_lines_interface PLI
        WHERE  pricing_attributes_rec.return_status_tbl(i) <> fnd_api.g_ret_sts_success
          AND PLI.po_line_id = pricing_attributes_rec.po_line_id_tbl(i)
          AND PLI.processing_id = PO_PDOI_PARAMS.g_processing_id
          AND PLI.process_code <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED;

  d_position:=20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'No of records with error status from pricing ', SQL%ROWCOUNT);
  END IF;

  -- Identify lines with NULL Unit Price.
  INSERT INTO po_session_gt
              (key,
               num1,  -- po_line_id
               num2,  -- draft_id
               char1, -- Return Message
               num3,  -- interface line id
               num4,  -- interface header id
               num5,  -- interface line loc id
               num6)  -- unit_price
        SELECT l_key,
               pld.po_line_id,
               pld.draft_id,
               'PO_PDOI_COLUMN_NOT_NULL',
               PLI.interface_line_id,
               PLI.interface_header_id,
               NULL, -- interface line loc id
               NULL -- unit_price
        FROM  po_lines_draft_all pld,
              po_lines_interface PLI,
	      po_headers_interface phi
        WHERE phi.interface_header_id = pli.interface_header_id
	  AND pld.po_line_id = pli.po_line_id
	  AND pld.draft_id = phi.draft_id
          AND pld.order_type_lookup_code <> 'FIXED PRICE'
          AND pld.unit_price IS NULL
          AND PLI.processing_id = PO_PDOI_PARAMS.g_processing_id
          AND PLI.process_code <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED;

  d_position:=30;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'No of records with NULL Price ', SQL%ROWCOUNT);
  END IF;

  -- Identify lines with Price < 0
  INSERT INTO po_session_gt
              (key,
               num1,  -- po_line_id
               num2,  -- draft_id
               char1, -- Return Message
               num3,  -- interface line id
               num4,  -- interface header id
               num5,  -- interface line loc id
               num6)  -- price
        SELECT l_key,
               pld.po_line_id,
               pld.draft_id,
               'PO_PDOI_LT_ZERO',
               PLI.interface_line_id,
               PLI.interface_header_id,
               NULL, -- interface line loc id
               pld.unit_price
        FROM  po_lines_draft_all pld,
              po_lines_interface PLI,
	      po_headers_interface phi
        WHERE phi.interface_header_id = pli.interface_header_id
	  AND pld.po_line_id = pli.po_line_id
	  AND pld.draft_id = phi.draft_id
          AND pld.order_type_lookup_code <> 'FIXED PRICE'
          AND pld.unit_price < 0
          AND PLI.processing_id = PO_PDOI_PARAMS.g_processing_id
          AND PLI.process_code <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED;

  d_position:=40;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'No of records with price less than 0 ', SQL%ROWCOUNT);
  END IF;

  -- Identify Fixed price lines with price not null
  INSERT INTO po_session_gt
              (key,
               num1,  -- po_line_id
               num2,  -- draft_id
               char1, -- Return Message
               num3,  -- interface line id
               num4,  -- interface header id
               num5,  -- interface line loc id
               num6)  -- unit_price
        SELECT l_key,
               pld.po_line_id,
               pld.draft_id,
               'PO_PDOI_SVC_NO_PRICE',
               PLI.interface_line_id,
               PLI.interface_header_id,
               NULL, -- interface line loc id
               pld.unit_price
        FROM  po_lines_draft_all pld,
              po_lines_interface PLI,
	      po_headers_interface phi
        WHERE phi.interface_header_id = pli.interface_header_id
	  AND pld.po_line_id = pli.po_line_id
	  AND pld.draft_id = phi.draft_id
          AND pld.order_type_lookup_code = 'FIXED PRICE'
          AND pld.unit_price IS NOT NULL
          AND PLI.processing_id = PO_PDOI_PARAMS.g_processing_id
          AND PLI.process_code <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED;

  d_position:=50;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'No of fixed price line with price not null ', SQL%ROWCOUNT);
  END IF;

  -- Identify line locations with NULL priceoverride
  INSERT INTO po_session_gt
              (key,
               num1,  -- po_line_id
               num2,  -- draft_id
               char1, -- Return Message
               num3,  -- interface line id
               num4,  -- interface header id
               num5,  -- interface line loc id
               num6)  -- price
        SELECT l_key,
               pld.po_line_id,
               pld.draft_id,
               'PO_PDOI_COLUMN_NOT_NULL',
               plli.interface_line_id,
               plli.interface_header_id,
               plli.interface_line_location_id,
               NULL --price
        FROM   po_lines_draft_all pld,
                po_line_locations_draft_all plld,
                po_line_locations_interface plli,
		po_headers_interface phi
        WHERE phi.interface_header_id = plli.interface_header_id
          AND plld.draft_id = phi.draft_id
          AND plld.po_line_id = pld.po_line_id
          AND plli.line_location_id = plld.line_location_id
          AND (pld.order_type_lookup_code <> 'FIXED PRICE'
                OR (pld.order_type_lookup_code = 'FIXED PRICE'
                    AND plld.payment_type = 'RATE'))
          AND plld.price_override IS NULL
          AND plli.processing_id = PO_PDOI_PARAMS.g_processing_id
	  and NVL(plld.payment_type,'DELIVERY') <> 'ADVANCE'   --Bug#19379838
          AND plli.process_code <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED;

  d_position:=60;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'No of line locations with NULL Price override ', SQL%ROWCOUNT);
  END IF;

  -- Identify line locations with  priceoverride < 0
  INSERT INTO po_session_gt
              (key,
               num1,  -- po_line_id
               num2,  -- draft_id
               char1, -- Return Message
               num3,  -- interface line id
               num4,  -- interface header id
               num5,  -- interface line loc id
               num6)  -- price
        SELECT l_key,
               pld.po_line_id,
               pld.draft_id,
               'PO_PDOI_LT_ZERO',
               plli.interface_line_id,
               plli.interface_header_id,
               plli.interface_line_location_id,
               plld.price_override
        FROM  po_lines_draft_all pld,
               po_line_locations_draft_all plld,
               po_line_locations_interface plli,
	       po_headers_interface phi
        WHERE phi.interface_header_id = plli.interface_header_id
          AND plld.draft_id = phi.draft_id
          AND plld.po_line_id = pld.po_line_id
          AND plli.line_location_id = plld.line_location_id
          AND (pld.order_type_lookup_code <> 'FIXED PRICE'
              OR (pld.order_type_lookup_code = 'FIXED PRICE'
                  AND plld.payment_type = 'RATE'))
          AND plld.price_override < 0
          AND plli.processing_id = PO_PDOI_PARAMS.g_processing_id
          AND plli.process_code <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED;

  d_position:=70;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'No of line locations with price override < 0 ', SQL%ROWCOUNT);
  END IF;

  -- Identify line locations with  priceoverride <> unit price on line
  INSERT INTO po_session_gt
              (key,
               num1,  -- po_line_id
               num2,  -- draft_id
               char1, -- Return Message
               num3,  -- interface line id
               num4,  -- interface header id
               num5,  -- interface line loc id
               num6)  -- price
        SELECT l_key,
               pld.po_line_id,
               pld.draft_id,
               'PO_PDOI_DEL_SHIP_LINE_MISMATCH',
               plli.interface_line_id,
               plli.interface_header_id,
               plli.interface_line_location_id,
               plld.price_override
        FROM  po_lines_draft_all pld,
               po_line_locations_draft_all plld,
               po_line_locations_interface plli,
	       po_headers_interface phi
        WHERE phi.interface_header_id = plli.interface_header_id
          AND plld.draft_id = phi.draft_id
          AND plld.po_line_id = pld.po_line_id
          AND plli.line_location_id = plld.line_location_id
          AND pld.order_type_lookup_code <> 'FIXED PRICE'
	  AND NVL(plld.payment_type,'DELIVERY') <> 'ADVANCE' -- Bug 17772630
	  AND plld.shipment_type = 'STANDARD'
          AND plld.price_override <> pld.unit_price
          AND plli.processing_id = PO_PDOI_PARAMS.g_processing_id
          AND plli.process_code <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED;

   d_position:=80;
   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'No of line locations with price override <> price on line ', SQL%ROWCOUNT);
   END IF;

   SELECT DISTINCT num1,  -- po_line_id
                   num2,  -- draft_id
                   char1, -- Return Message
                   num3,  -- interface line id
                   num4,  -- interface header id
                   num5,  -- inrterface line loc id
                   num6  -- price
    BULK COLLECT INTO l_reject_line_id_tbl,
                      l_reject_draft_id_tbl,
                      l_reject_mssg,
                      l_reject_int_line_tbl,
                      l_reject_int_hdr_tbl,
                      l_reject_int_loc_tbl,
                      l_price_tbl
   FROM po_session_gt
   WHERE key = l_key;

  d_position:=90;

  FOR i IN 1..l_reject_line_id_tbl.COUNT
  LOOP
    d_position:=100;
     IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'Error occurred for interface_header_id ', l_reject_int_hdr_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'interface_line_id ',  l_reject_int_line_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'interface line loc id ',  l_reject_int_loc_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'Error message ', l_reject_mssg(i));
      END IF;
      IF l_reject_int_loc_tbl(i) IS NULL THEN
         PO_PDOI_ERR_UTL.add_fatal_error
          (
            p_interface_header_id  => l_reject_int_hdr_tbl(i),
            p_interface_line_id    => l_reject_int_line_tbl(i),
            p_error_message_name   => l_reject_mssg(i),
            p_table_name           => 'PO_LINES_INTERFACE',
            p_column_name          => 'UNIT_PRICE',
            p_column_value         => l_price_tbl(i),
            p_token1_name          => 'COLUMN_NAME',
            p_token1_value         => 'UNIT_PRICE',
            p_token2_name          => 'VALUE',
            p_token2_value         => l_price_tbl(i)
          );
      ELSE
         PO_PDOI_ERR_UTL.add_fatal_error
          (
            p_interface_header_id        => l_reject_int_hdr_tbl(i),
            p_interface_line_id          => l_reject_int_line_tbl(i),
            p_interface_line_location_id => l_reject_int_loc_tbl(i),
            p_error_message_name         => l_reject_mssg(i),
            p_table_name                 => 'PO_LINE_LOCATIONS_INTERFACE',
            p_column_name                => 'PRICE_OVVERRIDE',
            p_column_value               => l_price_tbl(i),
            p_token1_name                => 'COLUMN_NAME',
            p_token1_value               => 'PRICE_OVVERRIDE',
            p_token2_name                => 'VALUE',
            p_token2_value               => l_price_tbl(i),
            p_token3_name                => 'COLUMN',
            p_token3_value               => 'PRICE_OVVERRIDE'
          );
      END IF;
  END LOOP;

  d_position:=110;

  FORALL i IN 1..l_reject_line_id_tbl.COUNT
    DELETE FROM po_lines_draft_all
    WHERE po_line_id = l_reject_line_id_tbl(i)
    AND draft_id = l_reject_draft_id_tbl(i);

  d_position:=120;

  FORALL i IN 1..l_reject_line_id_tbl.COUNT
    DELETE FROM po_line_locations_draft_all
    WHERE po_line_id = l_reject_line_id_tbl(i)
    AND draft_id = l_reject_draft_id_tbl(i);

  d_position:=130;

  PO_PDOI_UTL.reject_lines_intf(
    p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
    p_id_tbl          => l_reject_int_line_tbl, -- Bug 17772630 Passing interface line id.
    p_cascade         => FND_API.g_TRUE
  );

  d_position:=140;

  DELETE FROM po_session_gt
  WHERE key = l_key;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg ( p_pkg_name => d_pkg_name, p_procedure_name => d_api_name || '.' || d_position );
  RAISE;

END process_pricing_rejected_rec;

-----------------------------------------------------------------------
--Start of Comments
--Name: update_price_on_line
--Function:
--<PDOI Enhancement Bug#17063664>
-- The procedure is used to update price on line based on
-- Price break and QP.
--Parameters:
--IN:
-- p_key - Key of po_session_gt
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_price_on_line(
    p_key                  IN  po_session_gt.key%TYPE )
IS

  d_api_name CONSTANT VARCHAR2(30)  := 'update_price_on_line';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  l_line_id_tbl          PO_TBL_NUMBER;
  l_draft_id_tbl         PO_TBL_NUMBER;
  d_position NUMBER;

  pricing_attributes_rec PO_PDOI_TYPES.pricing_attributes_rec_type;

  CURSOR pricing_attributes IS
    SELECT pld.draft_id,
           pld.po_header_id,
           pld.po_line_id,
           (SELECT ph.type_lookup_code
              FROM po_headers_all ph
             WHERE ph.po_header_id = NVL(pld.from_header_id,pld.contract_id)) source_document_type,
           NVL(pld.from_header_id,pld.contract_id) source_doc_hdr_id,
           pld.from_line_id source_doc_line_id,
           NVL((SELECT allow_price_override_flag
                  FROM po_lines_all pl
                 WHERE pl.po_line_id = pld.from_line_id),'Y') allow_price_override_flag,
           (SELECT ph.currency_code
                  FROM po_headers_all ph
                 WHERE ph.po_header_id = NVL(pld.from_header_id,pld.contract_id)) currency_code,
           pld.quantity,
           pld.base_unit_price,
           NULL unit_price,
           pld.price_break_lookup_code,
           pld.creation_date,
           pld.item_id,
           pld.item_revision,
           pld.category_id,
           pld.vendor_product_num supplier_item_num,
           pld.unit_meas_lookup_code uom,
           pld.order_type_lookup_code,
           NVL((SELECT 'N'
                 FROM dual
                 WHERE EXISTS (SELECT 'N'
                               FROM po_distributions_all pda
                               WHERE pld.po_line_id = pda.po_line_id
                               AND pld.po_header_id = pda.po_header_id
                               AND NVL(pda.amount_changed_flag,'N') = 'N')),
                'Y') amount_changed_flag,
           NVL((SELECT 'Y'
                 FROM dual
                 WHERE EXISTS (SELECT 'Y'
                               FROM po_lines_all pla
                               WHERE pla.po_line_id = pld.po_line_id
                               )),
                'N') existing_line_flag,
           NULL price_break_id,
           gt.date1 need_by_date,
           NULL pricing_date,
           gt.num5 ship_to_location_id,
           gt.num6 ship_to_organization_id,
           gt.index_num1 line_location_id,
           'N' processed_flag,
           NULL min_req_line_price,
           gt.char1 req_contractor_status,
           'DEFAULT' pricing_src,
           FND_API.G_RET_STS_SUCCESS return_status,
           NULL return_message,
	   --Bug 19528138 :Selecting dummy value
	   -- to intialize the tables
	   0,--vendor_id
	   0,--vendor_site_id
	   0,--org_id
	   'X'order_type,
	   'X' doc_sub_type,
	   'X' enhanced_pricing_flag,
	   'X' progress_payment_flag,
	    0,--rate
	   'X',--rate_type
	    sysdate--rate_date
	    --End 19528138
    FROM po_lines_draft_all pld,
         po_session_gt gt
    WHERE gt.key = p_key
    AND  gt.index_char1 IS NULL
    AND pld.draft_id = gt.num1
    AND pld.po_line_id = gt.index_num2
    ORDER BY pld.po_header_id;


    l_return_status       VARCHAR2(1);
    l_count               NUMBER;

 CURSOR c_hdr_dtls(p_header_id NUMBER) IS
 SELECT num1 po_header_id,
       num2 vendor_id,
       num3 vendor_site_id,
       num4 org_id,
       char1 doc_sub_type,
       --Columns used in below decode hchar1:order_type_lookup_code
       --and char3:global_agreement_flag
       decode(char1,
                   'STANDARD', 'PO',
                   'BLANKET', decode(nvl(char3,'N'),'Y','GBPA'),
                   'PO') order_type,
       char2 currency_code,
       num5 rate,
       char4 rate_type,
       date1 rate_date,
       char5 enhanced_pricing_flag,
       char6 progress_payment_flag
 FROM po_session_gt
 WHERE KEY = p_key
 AND index_char1 = 'PO_HEADER_DTLS'
 AND num1=p_header_id;

 c_hdr_dtls_rec c_hdr_dtls%rowtype;

 l_po_header_id NUMBER := NULL;

 l_req_contr_status_tbl PO_TBL_VARCHAR30;
 l_min_unit_price_tbl PO_TBL_NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position:=10;
  -- Algorithm
  -- 1) Update the po_lines_draft_all unit price with
  -- minimum unit price after the lines have been grouped
  -- 2) Query to get all pricing attributes.
  -- 3) Call PO_PRICE_HELPER.get_line_price
  -- 4) Update base_unit_price for all lines
  -- 5) Update unit_price for lines whose unit_price is NULL.
  --    (As we should not override price populated by user)
  -- 6) Update price override.

  -- If there are no records in session_gt it means there are no line locations
  -- This will be the case for blankets without price breaks.
  -- For this insert records in session_gt from po_lines_draft_all
    SELECT count(*)
    INTO l_count
    FROM po_session_gt
    WHERE KEY = p_key;

    IF l_count = 0 THEN

        INSERT INTO po_session_gt(
        key,        -- key
        index_num2, -- po_line_id
        num1,       -- draft_id
        num8,       -- po_header_id
        num7,       -- shipment_num
        char1       -- action
        )
        SELECT p_key,
               pld.po_line_id,
               pld.draft_id,
               pld.po_header_id,
               1,
               'ADD'  -- action
        FROM po_lines_draft_all pld, po_lines_interface pli, po_headers_interface phi
        WHERE phi.processing_id = PO_PDOI_PARAMS.g_processing_id
        AND   phi.process_code <> po_pdoi_constants.g_process_code_rejected
        AND   phi.interface_header_id = pli.interface_header_id
        AND   pli.process_code <> po_pdoi_constants.g_process_code_rejected
        AND   pld.po_line_id = pli.po_line_id
        AND   pld.po_header_id = phi.po_header_id
        AND   pld.draft_id = phi.draft_id;

   END IF;

   --<< Bug#19528138 Start>>--
   --Deleting all the shipment details excluding the minimum shipment
   --details for each line

   DELETE FROM po_session_gt
   WHERE KEY = p_key
   AND index_char1 IS NULL
   AND ROWID NOT IN (
   SELECT DISTINCT min_row_id
   FROM ( SELECT first_value(ROWID)
            over(PARTITION BY num1,index_num2 ORDER BY num7) min_row_id
	  FROM po_session_gt
          WHERE KEY = p_key
	  AND index_char1 IS NULL
          AND char3 = 'STANDARD'
	  ));


  IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'Number of Records Deleted ',SQL%ROWCOUNT);
   END IF;


    -- Populate req contractor status for each line.
    -- If atleast one req has contractor status as ASSIGNED then set the
    -- req_contractor_status as ASSIGNED.

   SELECT PLI.po_line_id,psg.num1,MAX(DECODE(prl.contractor_status,'ASSIGNED','ASSIGNED',NULL)),
          MIN(PLI.unit_price)
   BULK COLLECT INTO l_line_id_tbl,l_draft_id_tbl,l_req_contr_status_tbl,l_min_unit_price_tbl
   FROM po_requisItion_lines_all prl,
        po_lines_interface pli,
        po_session_gt psg
   WHERE psg.KEY = p_key
   AND   psg.index_char1 IS NULL
   AND psg.index_num2 = PLI.po_line_id
   AND PLI.requisition_line_id = prl.requisition_line_id(+)
   AND pli.processing_id = po_pdoi_params.g_processing_id
   AND NVL(pli.process_code, 'NULL') <> po_pdoi_constants.g_process_code_rejected
   GROUP BY PLI.po_line_id,psg.num1;


   IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_line_id_tbl', l_line_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_draft_id_tbl', l_draft_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_req_contr_status_tbl', l_req_contr_status_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_min_unit_price_tbl', l_min_unit_price_tbl);
  END IF;


   FORALL i IN 1..l_line_id_tbl.COUNT
   UPDATE po_session_gt psg
   SET psg.char1=l_req_contr_status_tbl(i)
   WHERE psg.KEY = p_key
   AND   psg.index_char1 IS NULL
   AND psg.index_num2 = l_line_id_tbl(i);


   --<< Bug#19528138 End>>--

  d_position:=20;

  --Updating the po_lines_draft_all unit price with
  -- minimum unit price after the lines have been grouped
  FORALL i IN 1..l_line_id_tbl.COUNT
    UPDATE po_lines_draft_all pld
    SET    pld.unit_price = l_min_unit_price_tbl(i)
    WHERE pld.po_line_id = l_line_id_tbl(i)
      AND pld.draft_id = l_draft_id_tbl(i)
      AND NOT EXISTS (SELECT 'Y'
                      FROM   po_lines_all pl
                      WHERE  pl.po_line_id = pld.po_line_id
                      AND    pl.po_header_id = pld.po_header_id) ;

  d_position:=30;

  OPEN pricing_attributes;

  FETCH pricing_attributes
  BULK COLLECT INTO
      pricing_attributes_rec.draft_id_tbl,
      pricing_attributes_rec.po_header_id_tbl,
      pricing_attributes_rec.po_line_id_tbl,
      pricing_attributes_rec.source_document_type_tbl,
      pricing_attributes_rec.source_doc_hdr_id_tbl,
      pricing_attributes_rec.source_doc_line_id_tbl,
      pricing_attributes_rec.allow_price_override_flag_tbl,
      pricing_attributes_rec.currency_code_tbl,
      pricing_attributes_rec.quantity_tbl,
      pricing_attributes_rec.base_unit_price_tbl,
      pricing_attributes_rec.unit_price_tbl,
      pricing_attributes_rec.price_break_lookup_code_tbl,
      pricing_attributes_rec.creation_date_tbl,
      pricing_attributes_rec.item_id_tbl,
      pricing_attributes_rec.item_revision_tbl,
      pricing_attributes_rec.category_id_tbl,
      pricing_attributes_rec.supplier_item_num_tbl,
      pricing_attributes_rec.uom_tbl,
      pricing_attributes_rec.order_type_lookup_tbl,
      pricing_attributes_rec.amount_changed_flag_tbl,
      pricing_attributes_rec.existing_line_flag_tbl,
      pricing_attributes_rec.price_break_id_tbl,
      pricing_attributes_rec.need_by_date_tbl,
      pricing_attributes_rec.pricing_date_tbl,
      pricing_attributes_rec.ship_to_loc_tbl,
      pricing_attributes_rec.ship_to_org_tbl,
      pricing_attributes_rec.line_loc_id_tbl,
      pricing_attributes_rec.processed_flag_tbl,
      pricing_attributes_rec.min_req_line_price_tbl,
      pricing_attributes_rec.req_contractor_status,
      pricing_attributes_rec.pricing_src_tbl,
      pricing_attributes_rec.return_status_tbl,
      pricing_attributes_rec.return_mssg_tbl,
      --Header attributes  --<< Bug#19528138 Start>>--
      pricing_attributes_rec.po_vendor_id_tbl,
      pricing_attributes_rec.po_vendor_site_id_tbl,
      pricing_attributes_rec.org_id_tbl,
      pricing_attributes_rec.order_type_tbl,
      pricing_attributes_rec.doc_sub_type_tbl,
      pricing_attributes_rec.enhanced_pricing_flag_tbl,
      pricing_attributes_rec.progress_payment_flag_tbl,
      pricing_attributes_rec.rate_tbl,
      pricing_attributes_rec.rate_type_tbl,
      pricing_attributes_rec.rate_date_tbl;
   --<< Bug#19528138 End>>--
  pricing_attributes_rec.rec_count := pricing_attributes_rec.po_line_id_tbl.COUNT;

  IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'Number of Records Inserted ',pricing_attributes_rec.po_line_id_tbl.COUNT);
   END IF;

  CLOSE pricing_attributes;

  d_position:=40;

  IF (pricing_attributes_rec.rec_count > 0) THEN

    -- Populate Req line ids for each line.
    pricing_attributes_rec.req_line_ids := PO_PDOI_TYPES.REQ_LINE_ID_TBL();
    pricing_attributes_rec.req_line_ids.EXTEND(pricing_attributes_rec.po_line_id_tbl.COUNT);

    FOR i IN 1..pricing_attributes_rec.po_line_id_tbl.COUNT
    LOOP

      IF l_po_header_id IS NULL OR l_po_header_id <> pricing_attributes_rec.po_header_id_tbl(i)
      THEN

	 l_po_header_id:=pricing_attributes_rec.po_header_id_tbl(i);

         OPEN c_hdr_dtls(l_po_header_id);
	 FETCH c_hdr_dtls INTO c_hdr_dtls_rec;
	 CLOSE  c_hdr_dtls;

      END IF;
        --<< Bug#19528138 Start>>--
      pricing_attributes_rec.po_vendor_id_tbl(i):= c_hdr_dtls_rec.vendor_id;
      pricing_attributes_rec.po_vendor_site_id_tbl(i):= c_hdr_dtls_rec.vendor_site_id;
      pricing_attributes_rec.org_id_tbl(i) := c_hdr_dtls_rec.org_id;
      pricing_attributes_rec.order_type_tbl(i) := c_hdr_dtls_rec.order_type;
      pricing_attributes_rec.doc_sub_type_tbl(i) := c_hdr_dtls_rec.doc_sub_type;
      pricing_attributes_rec.enhanced_pricing_flag_tbl(i) := c_hdr_dtls_rec.enhanced_pricing_flag;
      pricing_attributes_rec.progress_payment_flag_tbl(i) := c_hdr_dtls_rec.progress_payment_flag;
      pricing_attributes_rec.rate_tbl(i) := c_hdr_dtls_rec.rate;
      pricing_attributes_rec.rate_type_tbl(i)  := c_hdr_dtls_rec.rate_type;
      pricing_attributes_rec.rate_date_tbl(i) := c_hdr_dtls_rec.rate_date;
      pricing_attributes_rec.currency_code_tbl(i) := NVL( pricing_attributes_rec.currency_code_tbl(i),
                                                      c_hdr_dtls_rec.currency_code);
       --<< Bug#19528138 End>>--

       SELECT pli.requisition_line_id
       BULK COLLECT INTO pricing_attributes_rec.req_line_ids(i)
       FROM  po_lines_interface pli
       WHERE pli.requisition_line_id IS NOT NULL
         AND pli.po_line_id = pricing_attributes_rec.po_line_id_tbl(i)
         AND pli.processing_id = po_pdoi_params.g_processing_id
         AND NVL(pli.process_code, 'NULL') <> po_pdoi_constants.g_process_code_rejected ;
    END LOOP;


    d_position:=50;

    -- Call the pricer helper API.
    PO_PRICE_HELPER.get_line_price(  x_pricing_attributes_rec => pricing_attributes_rec
                                   , x_return_status          => l_return_status
                                  );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        d_position:=60;
        -- Update Base Unit Price
        FORALL i IN INDICES OF pricing_attributes_rec.po_line_id_tbl
            UPDATE po_lines_draft_all
            SET base_unit_price = pricing_attributes_rec.base_unit_price_tbl(i),
                from_line_location_id = pricing_attributes_rec.price_break_id_tbl(i),
		negotiated_by_preparer_flag = DECODE(pricing_attributes_rec.pricing_src_tbl(i),
		                              'QP', 'Y',
					      negotiated_by_preparer_flag)  -- Bug 18891225
            WHERE po_line_id = pricing_attributes_rec.po_line_id_tbl(i)
            AND po_header_id = pricing_attributes_rec.po_header_id_tbl(i)
            AND draft_id = pricing_attributes_rec.draft_id_tbl(i)
            AND pricing_attributes_rec.return_status_tbl(i) = fnd_api.g_ret_sts_success;

        d_position:=70;
        -- Update Unit Price
        FORALL i IN INDICES OF pricing_attributes_rec.po_line_id_tbl
            UPDATE po_lines_draft_all
            SET unit_price = NVL(pricing_attributes_rec.unit_price_tbl(i), pricing_attributes_rec.base_unit_price_tbl(i))
            WHERE po_line_id = pricing_attributes_rec.po_line_id_tbl(i)
            AND po_header_id = pricing_attributes_rec.po_header_id_tbl(i)
            AND draft_id = pricing_attributes_rec.draft_id_tbl(i)
            AND unit_price IS NULL
            AND pricing_attributes_rec.return_status_tbl(i) = fnd_api.g_ret_sts_success;

        d_position:=80;
        -- Update price override
        FORALL i IN INDICES OF pricing_attributes_rec.po_line_id_tbl
              UPDATE po_line_locations_draft_all plld
              SET   plld.price_override = (SELECT unit_price
                                           FROM   po_lines_draft_all pld
                                           WHERE pld.draft_id = plld.draft_id
                                           AND   pld.po_line_id = plld.po_line_id
                                           AND   pld.order_type_lookup_code <> 'FIXED PRICE')
              WHERE plld.po_line_id = pricing_attributes_rec.po_line_id_tbl(i)
              AND   plld.po_header_id = pricing_attributes_rec.po_header_id_tbl(i)
              AND   plld.draft_id = pricing_attributes_rec.draft_id_tbl(i)
              AND   plld.price_override IS NULL
	      AND   NVL(plld.payment_type,'DELIVERY') <> 'ADVANCE' -- Bug 17772630
              AND   pricing_attributes_rec.return_status_tbl(i) = fnd_api.g_ret_sts_success;

        d_position:=90;
        -- Update amount for rate based lines.
         FORALL i IN INDICES OF pricing_attributes_rec.po_line_id_tbl
            UPDATE po_lines_draft_all draft_lines
               SET amount =(SELECT sum(Decode(Nvl(payment_type,'DELIVERY'),
                                      'RATE',Nvl(quantity,0)*Nvl(price_override,0),
                                      amount))
                            FROM   po_line_locations_draft_all
                            WHERE  po_line_id = draft_lines.po_line_id
                            AND    draft_id = draft_lines.draft_id
                            AND    (payment_type IS NULL OR payment_type NOT IN ('ADVANCE','DELIVERY')))
            WHERE  po_line_id = pricing_attributes_rec.po_line_id_tbl(i)
            AND    po_header_id = pricing_attributes_rec.po_header_id_tbl(i)
            AND    draft_id = pricing_attributes_rec.draft_id_tbl(i)
            AND    pricing_attributes_rec.return_status_tbl(i) = fnd_api.g_ret_sts_success;

            process_pricing_rejected_rec(pricing_attributes_rec => pricing_attributes_rec);
     ELSE
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  d_position:=100;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg ( p_pkg_name => d_pkg_name, p_procedure_name => d_api_name || '.' || d_position );
  RAISE;

END update_price_on_line;

-- <<PDOI Enhancement Bug#17063664 Start>>
-----------------------------------------------------------------------
--Start of Comments
--Name: setup_line_locs_intf
--Function:
--  For line interface records that require line location to be populated
--  (indicated by line_loc_populated_flag <> 'Y'), populate a record into
--  line locations interface, using the attribute values from lines
--  interface
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--End of Comments
------------------------------------------------------------------------
PROCEDURE setup_line_locs_intf
IS

  d_api_name CONSTANT VARCHAR2(30) := 'setup_line_locs_intf';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;
  l_data_key NUMBER;
  l_intf_header_id_tbl               PO_TBL_NUMBER;
  l_intf_line_id_tbl                 PO_TBL_NUMBER;
  l_intf_line_loc_id_tbl             PO_TBL_NUMBER;
  l_draft_id_tbl                     PO_TBL_NUMBER;
  l_style_id_tbl                     PO_TBL_NUMBER;
  l_complex_style_flag_tbl           PO_TBL_VARCHAR1;
  l_financing_style_flag_tbl         PO_TBL_VARCHAR1;
  l_advances_flag_tbl                PO_TBL_VARCHAR1;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  --SQL WHAT: Fetch all the lines for which to derive the line locations.
  --SQL WHY:  These attributes will be needed to populate line locations.
  SELECT temp_tbl.interface_header_id
    , temp_tbl.interface_line_id
    , temp_tbl.draft_id
    , temp_tbl.style_id
  BULK COLLECT INTO
         l_intf_header_id_tbl
       , l_intf_line_id_tbl
       , l_draft_id_tbl
       , l_style_id_tbl
  FROM
  (SELECT intf_lines.interface_header_id
    , intf_lines.interface_line_id
    , draft_lines.draft_id
    , draft_headers.style_id
  FROM   po_lines_interface intf_lines,
         po_headers_draft_all draft_headers,
         po_lines_draft_all draft_lines
  WHERE  intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    NVL(intf_lines.line_loc_populated_flag, 'N') = 'N'
  AND    draft_headers.po_header_id     = draft_lines.po_header_id
  AND    intf_lines.po_line_id          = draft_lines.po_line_id
  UNION
  SELECT intf_lines.interface_header_id
    , intf_lines.interface_line_id
    , draft_lines.draft_id
    , txn_headers.style_id
  FROM   po_lines_interface intf_lines,
         po_headers_all txn_headers,
         po_lines_draft_all draft_lines
  WHERE  intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    NVL(intf_lines.line_loc_populated_flag, 'N') = 'N'
  AND    txn_headers.po_header_id     	= draft_lines.po_header_id
  AND    intf_lines.po_line_id          = draft_lines.po_line_id) temp_tbl;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'interface header id', l_intf_header_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'interface line id', l_intf_line_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'draft id', l_draft_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'style id', l_style_id_tbl);
  END IF;

  d_position := 20;

  --Bug 18526620
  IF (l_intf_line_id_tbl.COUNT > 0) THEN

	d_position := 30;

	IF (PO_LOG.d_stmt) THEN
	PO_LOG.stmt(d_module, d_position, 'No lines to process');
	END IF;

	d_position := 40;
	l_data_key := PO_CORE_S.get_session_gt_nextval();

	--SQL WHAT: Insert the required attributes into po_session_gt table.
	--SQL WHY:  These attributes will be needed to populate line locations.
	FORALL i IN 1..l_intf_line_id_tbl.COUNT
	INSERT INTO PO_SESSION_GT
	(KEY
	, num1   -- interface_header_id
	, num2   -- interface_line_id
	, num3   -- draft_id
	, num4   -- style_id
	, char1  -- complex_style_flag
	, char2  -- financing_style_flag
	, char3  -- advances_flag
	)
	SELECT l_data_key
	, l_intf_header_id_tbl(i)
	, l_intf_line_id_tbl(i)
	, l_draft_id_tbl(i)
	, pdsh.style_id
	, pdsh.progress_payment_flag
	, pdsh.contract_financing_flag
	, pdsh.advances_flag
	FROM  po_doc_style_headers pdsh
	WHERE pdsh.style_id = l_style_id_tbl(i);

	IF (PO_LOG.d_stmt) THEN
	PO_LOG.stmt(d_module, d_position, 'No of rows inserted in session table: ', SQL%ROWCOUNT);
	END IF;

	d_position := 50;

	--Inserts the default attributes into po_line_locations_interface table
	--from po_lines
	FORALL i IN 1..l_intf_line_id_tbl.COUNT
	INSERT INTO po_line_locations_interface
	(interface_line_location_id,
	interface_header_id,
	interface_line_id,
	processing_id,
	process_code,
	line_location_id,
	shipment_type,
	shipment_num,
	ship_to_organization_id,
	ship_to_organization_code,
	ship_to_location_id,
	ship_to_location,
	terms_id,
	payment_terms,
	qty_rcv_exception_code,
	freight_carrier,
	fob,
	freight_terms,
	enforce_ship_to_location_code,
	allow_substitute_receipts_flag,
	days_early_receipt_allowed,
	days_late_receipt_allowed,
	receipt_days_exception_code,
	invoice_close_tolerance,
	receive_close_tolerance,
	receiving_routing_id,
	receiving_routing,
	accrue_on_receipt_flag,
	firm_flag,
	need_by_date,
	promised_date,
	from_line_location_id,
	inspection_required_flag,
	receipt_required_flag,
	source_shipment_id,
	note_to_receiver,
	transaction_flow_header_id,
	quantity,
	price_discount,
	start_date,
	end_date,
	price_override, --Bug19528138 --Bug20406561 Reverting the fix
	lead_time,
	lead_time_unit,
	amount,
	secondary_quantity,
	secondary_unit_of_measure,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	unit_of_measure,
	preferred_grade,
	taxable_flag,
	tax_code_id,
	tax_name,
	qty_rcv_tolerance
	)
	SELECT po_line_locations_interface_s.nextval,
	PLI.interface_header_id,
	PLI.interface_line_id,
	PLI.processing_id,
	PLI.process_code,
	PLI.line_location_id,
	PLI.shipment_type,
	PLI.shipment_num,
	PLI.ship_to_organization_id,
	PLI.ship_to_organization_code,
	PLI.ship_to_location_id,
	PLI.ship_to_location,
	PLI.terms_id,
	PLI.payment_terms,
	PLI.qty_rcv_exception_code,
	PLI.freight_carrier,
	PLI.fob,
	PLI.freight_terms,
	PLI.enforce_ship_to_location_code,
	PLI.allow_substitute_receipts_flag,
	PLI.days_early_receipt_allowed,
	PLI.days_late_receipt_allowed,
	PLI.receipt_days_exception_code,
	PLI.invoice_close_tolerance,
	PLI.receive_close_tolerance,
	PLI.receiving_routing_id,
	PLI.receiving_routing,
	PLI.accrue_on_receipt_flag,
	PLI.firm_flag,
	PLI.need_by_date,
	PLI.promised_date,
	PLI.from_line_location_id,
	PLI.inspection_required_flag,
	PLI.receipt_required_flag,
	PLI.source_shipment_id,
	PLI.note_to_receiver,
	PLI.transaction_flow_header_id,
	PLI.quantity,
	PLI.price_discount,
	PLI.effective_date,
	PLI.expiration_date,
	--Bug20406561 : Should default only when called from sourcing and consumption advice
	decode(PO_PDOI_PARAMS.g_request.calling_module,PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,PLI.unit_price,
        PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE,pli.unit_price,null),
	PLI.lead_time,
	PLI.lead_time_unit,
	PLI.amount,
	PLI.secondary_quantity,
	PLI.secondary_unit_of_measure,
	PLI.shipment_attribute_category,
	PLI.shipment_attribute1,
	PLI.shipment_attribute2,
	PLI.shipment_attribute3,
	PLI.shipment_attribute4,
	PLI.shipment_attribute5,
	PLI.shipment_attribute6,
	PLI.shipment_attribute7,
	PLI.shipment_attribute8,
	PLI.shipment_attribute9,
	PLI.shipment_attribute10,
	PLI.shipment_attribute11,
	PLI.shipment_attribute12,
	PLI.shipment_attribute13,
	PLI.shipment_attribute14,
	PLI.shipment_attribute15,
	PLI.creation_date,
	PLI.created_by,
	PLI.last_update_date,
	PLI.last_updated_by,
	PLI.last_update_login,
	PLI.request_id,
	PLI.program_application_id,
	PLI.program_id,
	PLI.program_update_date,
	PLI.unit_of_measure,
	PLI.preferred_grade,
	PLI.taxable_flag,
	PLI.tax_code_id,
	PLI.tax_name,
	PLI.qty_rcv_tolerance
	FROM po_lines_interface PLI
	, po_lines_draft_all PLD
	WHERE PLI.interface_line_id   = l_intf_line_id_tbl(i)
	AND   PLI.po_line_id          = PLD.po_line_id
	AND   PLD.draft_id            = l_draft_id_tbl(i);

	IF (PO_LOG.d_stmt) THEN
	PO_LOG.stmt(d_module, d_position, 'No of rows inserted in shipments table: ', SQL%ROWCOUNT);
	END IF;

	d_position := 60;

	-- Update corresponding line location id for each line in po_session_gt table.
	FORALL i IN 1 .. l_intf_line_id_tbl.COUNT
	UPDATE PO_SESSION_GT pst
	SET pst.num5 =        -- interface_line_location_id
	(SELECT plli.interface_line_location_id
	FROM   po_line_locations_interface plli
	WHERE  plli.interface_line_id = l_intf_line_id_tbl(i))
	WHERE pst.num2 = l_intf_line_id_tbl(i);

	d_position := 70;

	l_intf_line_id_tbl.DELETE;

	-- Collect all the attributes stored in po_session_gt into plsql tables.
	DELETE FROM po_session_gt
	WHERE  key = l_data_key
	RETURNING num2, num5, char1, char2, char3
	BULK COLLECT INTO
	l_intf_line_id_tbl,
	l_intf_line_loc_id_tbl,
	l_complex_style_flag_tbl,
	l_financing_style_flag_tbl,
	l_advances_flag_tbl;

	d_position := 80;

	-- Default payment_type and price_override for complex type shipments.
	FORALL i IN 1 .. l_intf_line_id_tbl.COUNT
	UPDATE po_line_locations_interface plli
	SET plli.payment_type   = DECODE(plli.quantity,NULL,'LUMPSUM','MILESTONE')
	WHERE plli.interface_line_location_id = 	l_intf_line_loc_id_tbl(i)
	AND l_complex_style_flag_tbl(i) = 'Y';

	d_position := 90;

	-- Default shipment_type and shipment_num for complex and finance style shipments.
	FORALL i IN 1 .. l_intf_line_id_tbl.COUNT
	UPDATE po_line_locations_interface plli
	SET plli.shipment_type = 'PREPAYMENT',
		plli.shipment_num = DECODE(plli.shipment_num,NULL,1,shipment_num)
	WHERE plli.interface_line_location_id = 	l_intf_line_loc_id_tbl(i)
	AND l_complex_style_flag_tbl(i) = 'Y'
	AND l_financing_style_flag_tbl(i) = 'Y';

	d_position := 100;

	-- Default prevent_encumbrance_flag in po_distributions_interface for
	-- complex finance style documents.
	FORALL i IN 1 .. l_intf_line_id_tbl.COUNT
	UPDATE po_distributions_interface pdi
	SET pdi.prevent_encumbrance_flag = 'Y'
	WHERE pdi.interface_line_id = 	l_intf_line_id_tbl(i)
	AND l_complex_style_flag_tbl(i) = 'Y'
	AND l_financing_style_flag_tbl(i) = 'Y';

	d_position := 110;
	-- Call the procedure to create Advance pay items for the given interface line record.
	populate_advance_payitem(l_intf_line_id_tbl, l_complex_style_flag_tbl, l_advances_flag_tbl);

	d_position := 120;
	-- Call the procedure to create progress pay items for the given interface line record.
	populate_progress_payitem(l_intf_line_id_tbl, l_complex_style_flag_tbl, l_financing_style_flag_tbl);

	d_position := 130;

	-- Update interface_line_location_id in po_distributions_interface
	FORALL i IN 1 .. l_intf_line_id_tbl.COUNT
	UPDATE po_distributions_interface pdi
	SET pdi.interface_line_location_id = l_intf_line_loc_id_tbl(i)
	WHERE pdi.interface_line_id        = l_intf_line_id_tbl(i)
	AND pdi.interface_line_location_id IS NULL;

	d_position := 140;

	-- Update interface_line_location_id in po_price_diff_interface
	FORALL i IN 1 .. l_intf_line_id_tbl.COUNT
	UPDATE po_price_diff_interface ppdi
	SET ppdi.interface_line_location_id = l_intf_line_loc_id_tbl(i)
	WHERE ppdi.interface_line_id        = l_intf_line_id_tbl(i);

	d_position := 150;

	--Bug#19303861 : Modified the sql to update Line loc populated flag
	-- for the lines process in this batch.

	FORALL i IN 1..l_intf_line_id_tbl.COUNT
	UPDATE po_lines_interface pli
	SET pli.line_loc_populated_flag = 'S'
	WHERE pli.interface_line_id = l_intf_line_id_tbl(i);

	-- Bug 18526620  Deleting all required tables to reuse.
	l_intf_line_id_tbl.delete;
	l_advances_flag_tbl.delete;
	l_complex_style_flag_tbl.delete;
	l_financing_style_flag_tbl.delete;

  END IF; -- End If l_intf_line_id_tbl.COUNT > 0

   -- <Bug 18526620 Start>
   -- Advance Shipment is not created from RFQ having payitems
   -- This is because from Sourcing line_loc_populated_flag comes as Y
   -- and so it is not picked up in the above cursor.
   -- Same will be the issue with Delivery shipment in Financing PO.

   d_position := 160;

   -- Selecting all lines having line_loc_populated_flag - Y , advance given in po_lines_interface
   -- but corresponding advance shipment not existing.
   SELECT temp_tbl.interface_line_id
        , temp_tbl.advances_flag
	, temp_tbl.progress_payment_flag
   BULK COLLECT INTO
          l_intf_line_id_tbl
        , l_advances_flag_tbl
	, l_complex_style_flag_tbl
   FROM
   (SELECT intf_lines.interface_line_id,
           pds.advances_flag,
	   pds.progress_payment_flag
   FROM   po_lines_interface intf_lines,
          po_headers_draft_all draft_headers,
          po_lines_draft_all draft_lines,
          po_doc_style_headers pds
   WHERE  intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
   AND    NVL(intf_lines.line_loc_populated_flag, 'N') = 'Y'
   AND    intf_lines.advance_amount IS NOT NULL
   AND    NOT EXISTS (SELECT 'advance_shipment'
                      FROM    po_line_locations_interface intf_loc
                      WHERE   intf_loc.interface_line_id = intf_lines.interface_line_id
                      AND     intf_loc.interface_header_id = intf_lines.interface_header_id
                      AND     intf_loc.payment_type = 'ADVANCE'
                      AND     intf_loc.shipment_type = 'PREPAYMENT')
   AND    draft_headers.po_header_id     = draft_lines.po_header_id
   AND    intf_lines.po_line_id          = draft_lines.po_line_id
   AND    draft_headers.style_id = pds.style_id
   AND    NVL(pds.advances_flag, 'N') = 'Y'
   UNION
   SELECT intf_lines.interface_line_id,
          pds.advances_flag,
	  pds.progress_payment_flag
   FROM   po_lines_interface intf_lines,
          po_headers_all txn_headers,
          po_lines_draft_all draft_lines,
          po_doc_style_headers pds
   WHERE  intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
   AND    NVL(intf_lines.line_loc_populated_flag, 'N') = 'Y'
   AND    intf_lines.advance_amount IS NOT NULL
   AND    NOT EXISTS (SELECT 'advance_shipment'
                      FROM    po_line_locations_interface intf_loc
                      WHERE   intf_loc.interface_line_id = intf_lines.interface_line_id
                      AND     intf_loc.interface_header_id = intf_lines.interface_header_id
                      AND     intf_loc.payment_type = 'ADVANCE'
                      AND     intf_loc.shipment_type = 'PREPAYMENT')
   AND    txn_headers.po_header_id       = draft_lines.po_header_id
   AND    intf_lines.po_line_id          = draft_lines.po_line_id
   AND    txn_headers.style_id = pds.style_id
   AND    NVL(pds.advances_flag, 'N') = 'Y') temp_tbl;

  d_position := 170;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'interface line id', l_intf_line_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_advances_flag_tbl', l_advances_flag_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_complex_style_flag_tbl', l_complex_style_flag_tbl);
  END IF;

  IF (l_intf_line_id_tbl.COUNT > 0) THEN
	d_position := 180;
	-- Call the procedure to create Advance pay items for the given interface line record.
	populate_advance_payitem(l_intf_line_id_tbl,
				l_complex_style_flag_tbl,
				l_advances_flag_tbl);

	d_position := 190;

	-- Deleting all required tables to reuse.
	l_intf_line_id_tbl.delete;
	l_complex_style_flag_tbl.delete;
   END IF;

   -- Selecting all Financing PO lines having line_loc_populated_flag - Y
   -- but DELIVERY shipment not existing in line_locations.
   SELECT temp_tbl.interface_line_id
        , temp_tbl.progress_payment_flag
        , temp_tbl.contract_financing_flag
   BULK COLLECT INTO
          l_intf_line_id_tbl
        , l_complex_style_flag_tbl
        , l_financing_style_flag_tbl
   FROM
   (SELECT intf_lines.interface_line_id
         , pds.progress_payment_flag
         , pds.contract_financing_flag
   FROM   po_lines_interface intf_lines,
          po_lines_draft_all draft_lines,
          po_headers_draft_all draft_headers,
          po_doc_style_headers pds
   WHERE  intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
   AND    NVL(intf_lines.line_loc_populated_flag, 'N') = 'Y'
   AND    NOT EXISTS (SELECT 'delivery_shipment'
                      FROM    po_line_locations_interface intf_loc
                      WHERE   intf_loc.interface_line_id = intf_lines.interface_line_id
                      AND     intf_loc.interface_header_id = intf_lines.interface_header_id
                      AND     intf_loc.payment_type = 'DELIVERY'
                      AND     intf_loc.shipment_type = 'STANDARD')
   AND    draft_headers.po_header_id     = draft_lines.po_header_id
   AND    intf_lines.po_line_id          = draft_lines.po_line_id
   AND    draft_headers.style_id = pds.style_id
   AND    NVL(pds.progress_payment_flag, 'N') = 'Y'
   AND    NVL(pds.contract_financing_flag, 'N') = 'Y'
   UNION
   SELECT intf_lines.interface_line_id
         , pds.progress_payment_flag
         , pds.contract_financing_flag
   FROM   po_lines_interface intf_lines,
          po_lines_draft_all draft_lines,
          po_headers_all txn_headers,
          po_doc_style_headers pds
   WHERE  intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
   AND    NVL(intf_lines.line_loc_populated_flag, 'N') = 'Y'
   AND    NOT EXISTS (SELECT 'delivery_shipment'
                      FROM    po_line_locations_interface intf_loc
                      WHERE   intf_loc.interface_line_id = intf_lines.interface_line_id
                      AND     intf_loc.interface_header_id = intf_lines.interface_header_id
                      AND     intf_loc.payment_type = 'DELIVERY'
                      AND     intf_loc.shipment_type = 'STANDARD')
   AND    txn_headers.po_header_id       = draft_lines.po_header_id
   AND    intf_lines.po_line_id          = draft_lines.po_line_id
   AND    txn_headers.style_id = pds.style_id
   AND    NVL(pds.progress_payment_flag, 'N') = 'Y'
   AND    NVL(pds.contract_financing_flag, 'N') = 'Y') temp_tbl;

  d_position := 200;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'interface line id', l_intf_line_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_financing_style_flag_tbl', l_financing_style_flag_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_complex_style_flag_tbl', l_complex_style_flag_tbl);
  END IF;

  IF (l_intf_line_id_tbl.COUNT > 0) THEN
	-- Call the procedure to create progress pay items for the given interface line record.
	populate_progress_payitem(l_intf_line_id_tbl,
				l_complex_style_flag_tbl,
				l_financing_style_flag_tbl
				);
	d_position := 210;
   END IF;

   -- <Bug 18526620 End>

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

END setup_line_locs_intf;

-----------------------------------------------------------------------
--Start of Comments
--Name: populate_advance_payitem
--Pre-requisites:
--  This Procedure needs to be called for only those interface line records,
--  which belong to complex style and have the option Advance enabled. When
--  line_loc_populated_flag = 'Y', this procedure will not be called.
--Function:
--  This Procedure will create Advance  pay items for the given interface
--  line record.
--Parameters:
--IN:
--p_interface_line_id_tbl
--  Nested table of Interface Line IDs
--IN OUT: None
--OUT: None
--End of Comments
------------------------------------------------------------------------
PROCEDURE populate_advance_payitem
(
  p_intf_line_id_tbl       IN PO_TBL_NUMBER,
  p_complex_style_flag_tbl IN PO_TBL_VARCHAR1,
  p_advances_flag_tbl      IN PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'populate_advance_payitem';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_intf_line_id_tbl', p_intf_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_complex_style_flag_tbl', p_complex_style_flag_tbl);
    PO_LOG.proc_begin(d_module, 'p_advances_flag_tbl', p_advances_flag_tbl);
  END IF;

  d_position := 10;

  --Inserts the advance pay item info into po_line_locations_interface table
  --from po_lines
  FORALL i IN 1..p_intf_line_id_tbl.COUNT
  INSERT INTO po_line_locations_interface
  (
    interface_line_location_id,
    interface_header_id,
    interface_line_id,
    processing_id,
    process_code,
    line_location_id,
    shipment_type,
    shipment_num,
    ship_to_organization_id,
    ship_to_organization_code,
    ship_to_location_id,
    ship_to_location,
    terms_id,
    payment_terms,
    qty_rcv_exception_code,
    freight_carrier,
    fob,
    freight_terms,
    enforce_ship_to_location_code,
    allow_substitute_receipts_flag,
    days_early_receipt_allowed,
    days_late_receipt_allowed,
    receipt_days_exception_code,
    invoice_close_tolerance,
    receive_close_tolerance,
    receiving_routing_id,
    receiving_routing,
    accrue_on_receipt_flag,
    firm_flag,
    need_by_date,
    promised_date,
    from_line_location_id,
    inspection_required_flag,
    receipt_required_flag,
    source_shipment_id,
    note_to_receiver,
    transaction_flow_header_id,
    quantity,
    price_discount,
    start_date,
    end_date,
    price_override,
    lead_time,
    lead_time_unit,
    amount,
    secondary_quantity,
    secondary_unit_of_measure,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    unit_of_measure,
    payment_type,
    value_basis,
    matching_basis,
    preferred_grade,
    taxable_flag,
    tax_code_id,
    tax_name,
    qty_rcv_tolerance
  )
  SELECT po_line_locations_interface_s.nextval,
         PLI.interface_header_id,
         PLI.interface_line_id,
         PLI.processing_id,
         PLI.process_code,
         PLI.line_location_id,
         'PREPAYMENT', -- shipment_type
         0,            -- shipment_num
         PLI.ship_to_organization_id,
         PLI.ship_to_organization_code,
         PLI.ship_to_location_id,
         PLI.ship_to_location,
         PLI.terms_id,
         PLI.payment_terms,
         PLI.qty_rcv_exception_code,
         PLI.freight_carrier,
         PLI.fob,
         PLI.freight_terms,
         PLI.enforce_ship_to_location_code,
         PLI.allow_substitute_receipts_flag,
         PLI.days_early_receipt_allowed,
         PLI.days_late_receipt_allowed,
         PLI.receipt_days_exception_code,
         PLI.invoice_close_tolerance,
         PLI.receive_close_tolerance,
         PLI.receiving_routing_id,
         PLI.receiving_routing,
         PLI.accrue_on_receipt_flag,
         PLI.firm_flag,
         NULL,  -- need_by_date
         NULL,  -- promised_date
         PLI.from_line_location_id,
         PLI.inspection_required_flag,
         'N',  -- receipt_required_flag
         PLI.source_shipment_id,
         PLI.note_to_receiver,
         PLI.transaction_flow_header_id,
         NULL,  -- quantity
         NULL,  -- price_discount
         PLI.effective_date,
         PLI.expiration_date,
         NULL,  -- unit_price
         PLI.lead_time,
         PLI.lead_time_unit,
         PLI.advance_amount,  -- amount
         NULL,  -- secondary_quantity
         NULL,  -- secondary_unit_of_measure
         PLI.shipment_attribute_category,
         PLI.shipment_attribute1,
         PLI.shipment_attribute2,
         PLI.shipment_attribute3,
         PLI.shipment_attribute4,
         PLI.shipment_attribute5,
         PLI.shipment_attribute6,
         PLI.shipment_attribute7,
         PLI.shipment_attribute8,
         PLI.shipment_attribute9,
         PLI.shipment_attribute10,
         PLI.shipment_attribute11,
         PLI.shipment_attribute12,
         PLI.shipment_attribute13,
         PLI.shipment_attribute14,
         PLI.shipment_attribute15,
         PLI.creation_date,
         PLI.created_by,
         PLI.last_update_date,
         PLI.last_updated_by,
         PLI.last_update_login,
         PLI.request_id,
         PLI.program_application_id,
         PLI.program_id,
         PLI.program_update_date,
         NULL,           -- unit_of_measure
         'ADVANCE',      -- payment_type
         'FIXED PRICE',  -- value_basis
         'AMOUNT',       -- matching_basis
         PLI.preferred_grade,
         PLI.taxable_flag,
         PLI.tax_code_id,
         PLI.tax_name,
         PLI.qty_rcv_tolerance
  FROM po_lines_interface PLI
  WHERE PLI.interface_line_id       = p_intf_line_id_tbl(i)
    AND p_complex_style_flag_tbl(i) = 'Y'
    AND p_advances_flag_tbl(i)      = 'Y'
    AND Nvl(PLI.advance_amount,0)   > 0;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.proc_begin(d_module, 'Number of Rows Inserted into line locations table'
                        , sql%ROWCOUNT);
  END IF;

  d_position := 20;

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
END populate_advance_payitem;

-----------------------------------------------------------------------
--Start of Comments
--Name: populate_progress_payitem
--Pre-requisites:
--  This Procedure needs to be called for only those interface line records,
--  which belong to complex style and have the option "Treat Progress
--  Payments as Contract Financing" is checked. When the
--  line_loc_populated_flag = 'Y', this procedure will not be called.
--Function:
--  This procedure will create the progress pay items for the corresponding
--  interface line.
--Parameters:
--IN:
--p_interface_line_id_tbl
--  Nested table of Interface Line IDs
--IN OUT: None
--OUT: None
--End of Comments
------------------------------------------------------------------------
PROCEDURE populate_progress_payitem
(
  p_intf_line_id_tbl              IN PO_TBL_NUMBER,
  p_complex_style_flag_tbl        IN PO_TBL_VARCHAR1,
  p_financing_style_flag_tbl      IN PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'populate_progress_payitem';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_intf_line_id_tbl', p_intf_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_complex_style_flag_tbl', p_complex_style_flag_tbl);
    PO_LOG.proc_begin(d_module, 'p_financing_style_flag_tbl', p_financing_style_flag_tbl);
  END IF;

  d_position := 10;

  --Inserts the progress pay item info into po_line_locations_interface table
  --from po_lines
  FORALL i IN 1..p_intf_line_id_tbl.COUNT
  INSERT INTO po_line_locations_interface
  (
    interface_line_location_id,
    interface_header_id,
    interface_line_id,
    processing_id,
    process_code,
    line_location_id,
    shipment_type,
    shipment_num,
    ship_to_organization_id,
    ship_to_organization_code,
    ship_to_location_id,
    ship_to_location,
    terms_id,
    payment_terms,
    qty_rcv_exception_code,
    freight_carrier,
    fob,
    freight_terms,
    enforce_ship_to_location_code,
    allow_substitute_receipts_flag,
    days_early_receipt_allowed,
    days_late_receipt_allowed,
    receipt_days_exception_code,
    invoice_close_tolerance,
    receive_close_tolerance,
    receiving_routing_id,
    receiving_routing,
    accrue_on_receipt_flag,
    firm_flag,
    need_by_date,
    promised_date,
    from_line_location_id,
    inspection_required_flag,
    receipt_required_flag,
    source_shipment_id,
    note_to_receiver,
    transaction_flow_header_id,
    quantity,
    price_discount,
    start_date,
    end_date,
    price_override,
    lead_time,
    lead_time_unit,
    amount,
    secondary_quantity,
    secondary_unit_of_measure,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    unit_of_measure,
    payment_type,
    preferred_grade,
    taxable_flag,
    tax_code_id,
    tax_name,
    qty_rcv_tolerance
  )
  SELECT po_line_locations_interface_s.nextval,
         PLI.interface_header_id,
         PLI.interface_line_id,
         PLI.processing_id,
         PLI.process_code,
         PLI.line_location_id,
         'STANDARD', -- shipment_type
         1,          -- shipment_num
         PLI.ship_to_organization_id,
         PLI.ship_to_organization_code,
         PLI.ship_to_location_id,
         PLI.ship_to_location,
         PLI.terms_id,
         PLI.payment_terms,
         PLI.qty_rcv_exception_code,
         PLI.freight_carrier,
         PLI.fob,
         PLI.freight_terms,
         PLI.enforce_ship_to_location_code,
         PLI.allow_substitute_receipts_flag,
         PLI.days_early_receipt_allowed,
         PLI.days_late_receipt_allowed,
         PLI.receipt_days_exception_code,
         PLI.invoice_close_tolerance,
         PLI.receive_close_tolerance,
         PLI.receiving_routing_id,
         PLI.receiving_routing,
         PLI.accrue_on_receipt_flag,
         PLI.firm_flag,
         PLI.need_by_date,
         PLI.promised_date,
         PLI.from_line_location_id,
         PLI.inspection_required_flag,
         PLI.receipt_required_flag,
         PLI.source_shipment_id,
         PLI.note_to_receiver,
         PLI.transaction_flow_header_id,
         PLI.quantity,
         PLI.price_discount,
         PLI.effective_date,
         PLI.expiration_date,
         PLI.unit_price,
         PLI.lead_time,
         PLI.lead_time_unit,
         PLI.amount,
         PLI.secondary_quantity,
         PLI.secondary_unit_of_measure,
         PLI.shipment_attribute_category,
         PLI.shipment_attribute1,
         PLI.shipment_attribute2,
         PLI.shipment_attribute3,
         PLI.shipment_attribute4,
         PLI.shipment_attribute5,
         PLI.shipment_attribute6,
         PLI.shipment_attribute7,
         PLI.shipment_attribute8,
         PLI.shipment_attribute9,
         PLI.shipment_attribute10,
         PLI.shipment_attribute11,
         PLI.shipment_attribute12,
         PLI.shipment_attribute13,
         PLI.shipment_attribute14,
         PLI.shipment_attribute15,
         PLI.creation_date,
         PLI.created_by,
         PLI.last_update_date,
         PLI.last_updated_by,
         PLI.last_update_login,
         PLI.request_id,
         PLI.program_application_id,
         PLI.program_id,
         PLI.program_update_date,
         PLI.unit_of_measure,
         'DELIVERY', -- payment_type
         PLI.preferred_grade,
         PLI.taxable_flag,
         PLI.tax_code_id,
         PLI.tax_name,
         PLI.qty_rcv_tolerance
  FROM po_lines_interface PLI
  WHERE PLI.interface_line_id         = p_intf_line_id_tbl(i)
    AND p_complex_style_flag_tbl(i)   = 'Y'
    AND p_financing_style_flag_tbl(i) = 'Y';

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.proc_begin(d_module, 'Number of Rows Inserted into line locations table'
                        , sql%ROWCOUNT);
  END IF;

  d_position := 20;

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
END populate_progress_payitem;
-----------------------------------------------------------------------
--Start of Comments
--Name: match_line_locs
--Pre-requisites:
--Function:
--  This procedure will match the shipments based on the matching
--  attributes criteria
--Parameters:
--IN:
--IN OUT: None
--  x_line_locs
--  Record having line locations within a batch
--OUT: None
-- x_create_line_locs
--   Shipments which will be created
-- x_update_line_locs
--   shipments which will be updated
--End of Comments
------------------------------------------------------------------------
PROCEDURE match_line_locs
(
 x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
 x_create_line_locs   IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
 x_update_line_locs   IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
)IS

  d_api_name CONSTANT VARCHAR2(30) := 'match_line_locs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_processing_row_tbl     DBMS_SQL.NUMBER_TABLE;

  l_match_line_locs   PO_PDOI_TYPES.line_locs_rec_type;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_MATCH);

  d_position := 10;
  -- initialize table containing the row number
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size     => x_line_locs.rec_count,
    x_num_list => l_processing_row_tbl
  );

  d_position := 20;
  -- Assign shipment numbers for all the shipments
  -- which cannot be grouped
  assign_shipment_num
  (
   x_line_locs          => x_line_locs,
   x_processing_row_tbl =>  l_processing_row_tbl
   );

   d_position := 30;

  --Match shipments based on shipment
  -- informations
  match_shipments_info
  (
   x_line_locs          => x_line_locs,
   x_processing_row_tbl =>  l_processing_row_tbl
   );

  d_position := 40;

  split_line_locs
  (
   p_line_locs         => x_line_locs,
   x_create_line_locs  => x_create_line_locs,
   x_update_line_locs  => x_update_line_locs,
   x_match_line_locs   => l_match_line_locs
   );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'num of created shipments', x_create_line_locs.rec_count);
    PO_LOG.stmt(d_module, d_position, 'num of updated shipments', x_update_line_locs.rec_count);
    PO_LOG.stmt(d_module, d_position, 'num of matched shipments', l_match_line_locs.rec_count);
  END IF;

  d_position := 50;

  update_line_loc_interface
  (
   p_intf_line_loc_id_tbl   => l_match_line_locs.intf_line_loc_id_tbl,
   p_line_loc_id_tbl        => l_match_line_locs.line_loc_id_tbl,
   p_action_tbl             => l_match_line_locs.action_tbl,
   p_error_flag_tbl         => l_match_line_locs.error_flag_tbl
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_MATCH);

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
END match_line_locs;
-----------------------------------------------------------------------
--Start of Comments
--Name: assign_shipment_num
--Pre-requisites:
--Function:
--  This procedure will update shipment number and
--  shipment line for the shipments which cannot be grouped
--Parameters:
--IN:
--IN OUT: None
--  x_line_locs
--  Record having line locations within a batch
--  x_processing_row_tbl
--  Table where shipments have been processed or not
--OUT: None
--End of Comments
------------------------------------------------------------------------
PROCEDURE assign_shipment_num
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'assign_shipment_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key                    po_session_gt.key%TYPE;
  l_index                  NUMBER;
  l_po_line_id             po_lines_all.po_line_id%TYPE;
  l_shipment_num           po_line_locations_all.shipment_num%TYPE;

  -- counter variable
  l_count                  NUMBER := 1;	-- Bug#17998114

  l_processing_row_tbl     DBMS_SQL.NUMBER_TABLE;
  l_complex_flag_tbl       PO_TBL_VARCHAR1;
  l_one_time_loc_tbl       PO_TBL_VARCHAR1;

   -- hash table  based on po_line_id and shipment number
 TYPE line_loc_ref_internal_type IS TABLE OF NUMBER INDEX BY VARCHAR2(32);
 TYPE line_loc_ref_type IS TABLE OF line_loc_ref_internal_type INDEX BY PLS_INTEGER;

 l_shipment_num_ref_tbl line_loc_ref_type;


BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- get key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;


   d_position := 20;
   -- Determine whether the PO is complex PO or not
  FORALL i IN 1..x_line_locs.rec_count
  INSERT INTO po_session_gt(key,char1)
  SELECT l_key,progress_payment_flag
  FROM   po_doc_style_headers
  WHERE  style_id= x_line_locs.hd_style_id_tbl(i);


  DELETE FROM po_session_gt
  WHERE  KEY = l_key
  RETURNING char1 BULK COLLECT INTO l_complex_flag_tbl;

  --Get the one time location attachment flag
  FORALL i IN 1..x_line_locs.rec_count
  INSERT INTO po_session_gt(key,char1)
  SELECT l_key,'Y'
  FROM dual
  WHERE x_line_locs.ln_req_line_id_tbl(i) IS NOT NULL
  AND EXISTS ( SELECT 'Y'
               FROM  fnd_attached_documents
               WHERE entity_name = 'REQ_LINES'
               AND   pk1_value = to_char(x_line_locs.ln_req_line_id_tbl(i))
               AND   pk2_value = 'ONE_TIME_LOCATION'
              );
  DELETE FROM po_session_gt
  WHERE KEY = l_key
  RETURNING char1 BULK COLLECT INTO l_one_time_loc_tbl;


  d_position := 30;

  -- Identify the shipments which are eligible to process
  -- All lines which have satisfy below conditions
  -- will be processed
  -- 1. Group Lines is 'N'
  -- 2. Group shipments flag is 'N'. This is passed
  --    only in autocreate case.
  --    Group shipments flag from purchasing options
  --    should be considered if being called from
  --    concurrent program
  -- 3. Complex PO style = 'Y'
  -- 4. order type lookup code is 'FIXED PRICE' and
  --   'RATE' Service line types should not be grouped.
  -- 5. Shipment type is not STANDARD
  -- 6. Dropship shipments should not be grouped
  -- 7. Requisition having one time location
  -- 8. Wip enabled shipments cannot be grouped
  -- 9. Error flag should be 'N'
  FOR i IN 1..x_line_locs.rec_count
  LOOP

    IF ( PO_PDOI_PARAMS.g_request.group_lines = 'N' OR
         ( PO_PDOI_PARAMS.g_request.group_shipments = 'N' AND
	   PO_PDOI_PARAMS.g_request.calling_module in(
	     PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
             PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING
          ))OR
	 PO_PDOI_PARAMS.g_sys.group_shipments_flag = 'N' OR
	 l_complex_flag_tbl(i) = 'Y' OR
         x_line_locs.ln_order_type_lookup_code_tbl(i)  IN ('FIXED PRICE' ,'RATE') OR
	 x_line_locs.shipment_type_tbl(i) <> 'STANDARD' OR
	 x_line_locs.drop_ship_flag_tbl(i) = 'Y' OR
	 x_line_locs.wip_entity_id_tbl(i) IS NOT NULL
        )AND
        x_line_locs.error_flag_tbl(i) = FND_API.g_FALSE THEN

      IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module, d_position, 'processing index', i);
         PO_LOG.stmt(d_module, d_position, 'processing line', x_line_locs.intf_line_loc_id_tbl(i));
      END IF;

	  -- <<Bug#17998114 Start>>
      l_processing_row_tbl(l_count) := x_processing_row_tbl(i);
      l_count := l_count + 1;
	  -- <<Bug#17998114 End>>

    END IF;
  END LOOP;

   IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Number of shipments processed',
                  l_processing_row_tbl.COUNT);
      PO_LOG.stmt(d_module, d_position, 'l_count', l_count); -- Bug#17998114
   END IF;


   d_position := 40;

   -- Bug 17786584
   -- Index will not always start from 1.

   IF l_processing_row_tbl.COUNT = 0 THEN
     RETURN;
   END IF;

   FOR i IN l_processing_row_tbl.FIRST..l_processing_row_tbl.LAST
   LOOP

     l_index := l_processing_row_tbl(i);
     l_po_line_id := x_line_locs.ln_po_line_id_tbl(l_index);
     l_shipment_num := x_line_locs.shipment_num_tbl(l_index);

     IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'po line id', l_po_line_id);
      PO_LOG.stmt(d_module, d_position, 'shipment num', l_shipment_num);
     END IF;

     IF l_shipment_num IS NOT NULL THEN
        IF (l_shipment_num_ref_tbl.EXISTS(l_po_line_id) AND
          l_shipment_num_ref_tbl(l_po_line_id).EXISTS(l_shipment_num)) THEN

          IF NOT (l_complex_flag_tbl(l_index) = 'Y'
                  AND x_line_locs.payment_type_tbl(l_index) = 'DELIVERY') THEN

            --Shipment number is not unique within the PO Line
            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module, d_position, 'index', l_index);
              PO_LOG.stmt(d_module, d_position, 'po line id', l_po_line_id);
              PO_LOG.stmt(d_module, d_position, 'shipment num', l_shipment_num);
            END IF;

           PO_PDOI_ERR_UTL.add_fatal_error
           (
            p_interface_header_id  => x_line_locs.intf_header_id_tbl(l_index),
            p_interface_line_id    => x_line_locs.intf_line_id_tbl(l_index),
            p_interface_line_location_id => x_line_locs.intf_line_loc_id_tbl(l_index),
            p_error_message_name   => 'PO_PDOI_SHIPMENT_NO_GROUP',
            p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
            p_column_name          => 'SHIPMENT_NUM',
            p_column_value         => l_shipment_num,
            p_token2_name          => 'VALUE',
            p_token2_value         => l_shipment_num,
            p_line_locs            => x_line_locs
           );
           x_line_locs.error_flag_tbl(i) := FND_API.g_TRUE;

          END IF;

        ELSE
          -- Shipment number is unique
          IF NOT (l_complex_flag_tbl(l_index) = 'Y'
                  AND x_line_locs.payment_type_tbl(l_index) = 'DELIVERY') THEN
            l_shipment_num_ref_tbl(l_po_line_id)(l_shipment_num) := l_index;
          END IF;

          x_line_locs.line_loc_id_tbl(l_index):= PO_PDOI_MAINPROC_UTL_PVT.get_next_line_loc_id;
          x_line_locs.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_ADD;

	  IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'Shipemnt number is unique for po line',
 	               l_po_line_id);
            PO_LOG.stmt(d_module, d_position, 'Shipment number',l_shipment_num);
            PO_LOG.stmt(d_module, d_position, 'new shipment id',
                       x_line_locs.line_loc_id_tbl(l_index));
          END IF;
	  x_processing_row_tbl.DELETE(l_index);
        END IF;
     ELSE --Shipment number is null

       x_line_locs.line_loc_id_tbl(l_index):= PO_PDOI_MAINPROC_UTL_PVT.get_next_line_loc_id;
       x_line_locs.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_ADD;
       x_line_locs.shipment_num_tbl(l_index) := PO_PDOI_MAINPROC_UTL_PVT.get_next_shipment_num(l_po_line_id);

       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module, d_position, 'Shipment number',x_line_locs.shipment_num_tbl(l_index));
         PO_LOG.stmt(d_module, d_position, 'new shipment id',
                       x_line_locs.line_loc_id_tbl(l_index));
       END IF;
       x_processing_row_tbl.DELETE(l_index);
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
END assign_shipment_num;
-----------------------------------------------------------------------
--Start of Comments
--Name: match_shipments_info
--Pre-requisites:
--Function:
--  This procedure group the shipments based on the
--  shipment attributes grouping criteria
--Parameters:
--IN:
--IN OUT: None
--  x_line_locs
--  Record having line locations within a batch
--  x_processing_row_tbl
--  Table where shipments have been processed or not
--OUT: None
--End of Comments
------------------------------------------------------------------------
PROCEDURE match_shipments_info
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'match_shipments_info';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- hold the key value which is used to identify rows in temp table
  l_key           po_session_gt.key%TYPE;
  l_index_key     po_session_gt.key%TYPE;
  l_index         NUMBER;
  l_po_line_id             po_lines_all.po_line_id%TYPE;
  l_shipment_num           po_line_locations_all.shipment_num%TYPE;

  l_processing_row_tbl DBMS_SQL.NUMBER_TABLE;
  l_index_tbl PO_TBL_NUMBER;

  -- has table  based on po_line_id and shipment number
  TYPE line_loc_ref_internal_type IS TABLE OF NUMBER INDEX BY VARCHAR2(32);
  TYPE line_loc_ref_type IS TABLE OF line_loc_ref_internal_type INDEX BY PLS_INTEGER;

  l_shipment_num_ref_tbl line_loc_ref_type;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of shipments to be processed',
        x_processing_row_tbl.COUNT);
  END IF;


  -- get new key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  d_position := 10;
  --Identify the shipments that needs to be processed
  FORALL  i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key,num1)
  SELECT l_key,
         x_processing_row_tbl(i)
  FROM   dual
  WHERE  x_line_locs.error_flag_tbl(i) = FND_API.g_FALSE;

  --<< Bug#18021672 START : Fetching the Values
  -- into l_index_tbl instead of l_processing_row_tbl
  -- to retain the indices  >>

  DELETE FROM po_session_gt
  WHERE KEY = l_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Processing index',l_index_tbl(i));
    END IF;

    l_processing_row_tbl(l_index_tbl(i)) := l_index_tbl(i);

  END LOOP;

  --<<Bug#18021672 END >>

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of records identified',
        l_processing_row_tbl.COUNT);
  END IF;

    d_position := 20;
  --Get all the matching attributes in temp table
  FORALL i IN INDICES OF l_processing_row_tbl
  INSERT INTO po_line_locations_gt
  (line_location_id,
   po_line_id,
   po_header_id,
   shipment_num,
   ship_to_organization_id,
   ship_to_location_id,
   need_by_date,
   vmi_flag,
   consigned_flag,
   preferred_grade,
   note_to_receiver,
   accrue_on_receipt_flag,
   source_shipment_id --storing processing index
  )
  VALUES
  (
  x_line_locs.intf_line_loc_id_tbl(i),
  x_line_locs.ln_po_line_id_tbl(i),
  x_line_locs.hd_po_header_id_tbl(i),
  x_line_locs.shipment_num_tbl(i),
  x_line_locs.ship_to_org_id_tbl(i),
  x_line_locs.ship_to_loc_id_tbl(i),
  x_line_locs.need_by_date_tbl(i),
  x_line_locs.vmi_flag_tbl(i),
  x_line_locs.consigned_flag_tbl(i),
  x_line_locs.preferred_grade_tbl(i),
  x_line_locs.note_to_receiver_tbl(i),
  x_line_locs.accrue_on_receipt_flag_tbl(i),
  l_processing_row_tbl(i)
  );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of records inserted in line_locations_gt table',
         SQL%ROWCOUNT);
  END IF;

  d_position := 30;
  --Reject all the shipments having same line number
  -- but matching criteria does not match
  reject_linelocs_on_shpmt_num
  (
    x_line_locs  => x_line_locs,
    x_processing_row_tbl => l_processing_row_tbl
  );

  d_position := 40;
  --Match shipments on draft
  match_shipments_on_draft
  (
    x_line_locs  => x_line_locs,
    x_processing_row_tbl => l_processing_row_tbl
  );

  d_position := 50;
  -- Match shipments on txn table
  match_shipments_on_txn
  (
   x_line_locs  => x_line_locs,
   x_processing_row_tbl => l_processing_row_tbl
  );

  d_position := 60;
  --Match shipments on current batch
  match_shipments_on_interface
  (
   x_line_locs  => x_line_locs,
   x_processing_row_tbl => l_processing_row_tbl
  );

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END match_shipments_info;
-----------------------------------------------------------------------
--Start of Comments
--Name:  reject_linelocs_on_shpmt_num
--Pre-requisites:
--Function:
-- The procedure will reject all the shipments
-- having same shipment number but the matching criteria is not
-- satisfied
--Parameters:
--IN:
--IN OUT: None
--  x_line_locs
--  Record having line locations within a batch
--  x_processing_row_tbl
--  Table where shipments have been processed or not
--OUT: None
--End of Comments
------------------------------------------------------------------------
PROCEDURE   reject_linelocs_on_shpmt_num
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'reject_linelocs_on_shpmt_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index         NUMBER;
  l_count         NUMBER;

  l_po_line_id_tbl     PO_TBL_NUMBER;
  l_shipment_num_tbl   PO_TBL_NUMBER;
  l_cnt_tbl            PO_TBL_NUMBER;
  l_index_tbl          PO_TBL_NUMBER;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT COUNT(*)
  INTO l_count
  FROM  (SELECT column_value val
         FROM TABLE(x_line_locs.shipment_num_tbl)
	 ) shipment_num
  WHERE shipment_num.val IS NOT NULL;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of shipments having Shipments num',l_count);
  END IF;

  IF l_count = 0 THEN
    RETURN;
  END IF;

  --SQL What: Getting all the shipments for each po line
  --          which have same shipment number on multiple
  --          shipments  but grouping criteria is not matched
  --SQL Why: Need to reject all the shipments identifed


  SELECT po_line_id,
         shipment_num,
	 COUNT(*)
  BULK COLLECT INTO
        l_po_line_id_tbl,
	l_shipment_num_tbl,
       	l_cnt_tbl
  FROM (
        SELECT pllg.po_header_id,
	       pllg.po_line_id,
	       pllg.shipment_num,
	       pllg.ship_to_organization_id,
	       pllg.ship_to_location_id,
	       TRUNC(pllg.need_by_date),
	       pllg.vmi_flag,
	       pllg.consigned_flag,
	       pllg.preferred_grade, -- Bug#18007765
	       pllg.note_to_receiver,
	       pllg.accrue_on_receipt_flag,
	       COUNT(*)
         FROM po_line_locations_gt pllg
	 GROUP BY pllg.po_header_id,
	          pllg.po_line_id,
	          pllg.shipment_num,
	          pllg.ship_to_organization_id,
	          pllg.ship_to_location_id,
	          TRUNC(pllg.need_by_date),
	          pllg.vmi_flag,
	          pllg.consigned_flag,
	          pllg.preferred_grade, -- Bug#18007765
	          pllg.note_to_receiver,
	          pllg.accrue_on_receipt_flag
       )
   GROUP BY po_line_id,shipment_num
   HAVING COUNT(*) > 1;


  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_po_line_id_tbl', l_po_line_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_shipment_num_tbl', l_shipment_num_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_cnt_tbl', l_cnt_tbl);
  END IF;

  --SQL What: Getting all the index values for
  --          all the shipments identified above
  --SQL Why: Need to reject all the shipments identifed

  SELECT pllg.source_shipment_id  --processing index
  BULK COLLECT INTO   l_index_tbl
  FROM(SELECT column_value val ,ROWNUM rn
       FROM  TABLE(l_po_line_id_tbl)) po_line,
       (SELECT column_value val, ROWNUM rn
       FROM  TABLE(l_shipment_num_tbl)) shipment_num,
       po_line_locations_gt pllg
  WHERE po_line.rn = shipment_num.rn
  AND   pllg.po_line_id = po_line.val
  AND   pllg.shipment_num = shipment_num.val;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_index_tbl',l_index_tbl);
  END IF;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP

   l_index := l_index_tbl(i);

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Error on index', l_index);
     PO_LOG.stmt(d_module, d_position, 'Po Line Id', x_line_locs.ln_po_line_id_tbl(l_index));
     PO_LOG.stmt(d_module, d_position, 'Shipment num',x_line_locs.shipment_num_tbl(l_index));
   END IF;

    PO_PDOI_ERR_UTL.add_fatal_error
     (
       p_interface_header_id  => x_line_locs.intf_header_id_tbl(l_index),
       p_interface_line_id    => x_line_locs.intf_line_id_tbl(l_index),
       p_interface_line_location_id => x_line_locs.intf_line_loc_id_tbl(l_index),
       p_error_message_name   => 'PO_PDOI_GRP_SHIP_NUM_UNIQUE',
       p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
       p_column_name          => 'SHIPMENT_NUM',
       p_column_value         => x_line_locs.shipment_num_tbl(l_index),
       p_token2_name          => 'VALUE',
       p_token2_value         => x_line_locs.shipment_num_tbl(l_index),
       p_line_locs            => x_line_locs
      );

    x_line_locs.error_flag_tbl(l_index) := FND_API.g_TRUE;
    x_processing_row_tbl.DELETE(l_index);
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
END reject_linelocs_on_shpmt_num;
-----------------------------------------------------------------------
--Start of Comments
--Name: match_shipments_on_draft
--Pre-requisites:
--Function:
-- The procedure will match the shipments on
-- draft table
-- satisfied
--Parameters:
--IN:
--IN OUT: None
--  x_line_locs
--  Record having line locations within a batch
--  x_processing_row_tbl
--  Table where shipments have been processed or not
--OUT: None
--End of Comments
------------------------------------------------------------------------
PROCEDURE   match_shipments_on_draft
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'match_shipments_on_draft';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

    -- hold the key value which is used to identify rows in temp table
  l_key           po_session_gt.key%TYPE;

  l_index_tbl             PO_TBL_NUMBER;
  l_match_num_tbl         PO_TBL_NUMBER;
  l_match_id_tbl          PO_TBL_NUMBER;
  l_index                 NUMBER;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of Records to be processed', x_processing_row_tbl.COUNT);
  END IF;

  -- get new key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  d_position := 10;

  FORALL i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key, num1, num2, num3)
  SELECT l_key,
         x_processing_row_tbl(i),
         line_location_id,
         shipment_num
  FROM   po_line_locations_draft_all plld
  WHERE  plld.draft_id = x_line_locs.draft_id_tbl(i)
  AND    plld.po_header_id = x_line_locs.hd_po_header_id_tbl(i)
  AND    plld.po_line_id = x_line_locs.ln_po_line_id_tbl(i)
  AND    NVL(plld.delete_flag, 'N') <> 'Y'
  AND   ((x_line_locs.shipment_num_tbl(i) IS NULL
         ) OR
	 plld.shipment_num = x_line_locs.shipment_num_tbl(i)
	)
  AND   ((plld.ship_to_organization_id IS NULL AND
	   x_line_locs.ship_to_org_id_tbl(i) IS NULL
         ) OR
	  plld.ship_to_organization_id = x_line_locs.ship_to_org_id_tbl(i)
	)
  AND   ((plld.ship_to_location_id IS NULL AND
    	  x_line_locs.ship_to_loc_id_tbl(i) IS NULL
	  ) OR
	  plld.ship_to_location_id = x_line_locs.ship_to_loc_id_tbl(i)
	 )
  AND   ((plld.need_by_date IS NULL AND
       	  x_line_locs.need_by_date_tbl(i) IS NULL
	 ) OR
	  plld.need_by_date = x_line_locs.need_by_date_tbl(i)
	)
  AND   ((plld.vmi_flag IS NULL AND
    	  x_line_locs.vmi_flag_tbl(i) IS NULL
	  ) OR
	  plld.vmi_flag = x_line_locs.vmi_flag_tbl(i)
	 )
  AND   ((plld.consigned_flag IS NULL AND
          x_line_locs.consigned_flag_tbl(i) IS NULL
	  ) OR
	  plld.consigned_flag = x_line_locs.consigned_flag_tbl(i)
	 )
  AND   ((plld.note_to_receiver IS NULL AND
   	  x_line_locs.note_to_receiver_tbl(i) IS NULL
	  ) OR
	  plld.note_to_receiver = x_line_locs.note_to_receiver_tbl(i)
	)
  AND   ((plld.accrue_on_receipt_flag IS NULL AND
          x_line_locs.accrue_on_receipt_flag_tbl(i) IS NULL
	  ) OR
	  plld.accrue_on_receipt_flag = x_line_locs.accrue_on_receipt_flag_tbl(i)
	 );

  d_position := 20;

  --Get the matched result from temp table
  DELETE FROM po_session_gt
  WHERE KEY = l_key
  RETURNING num1,num2,num3
  BULK COLLECT INTO l_index_tbl,l_match_id_tbl,l_match_num_tbl;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_index_tbl', l_index_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_match_num_tbl', l_match_num_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_match_id_tbl', l_match_id_tbl);
  END IF;

    -- set the po_line_id and line_num from matching line
  -- so there is no new line created from this row
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'matched po Shipment id', l_match_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'matched shipment num', l_match_num_tbl(i));
    END IF;

    x_line_locs.line_loc_id_tbl(l_index) := l_match_id_tbl(i);
    x_line_locs.shipment_num_tbl(l_index) := l_match_num_tbl(i);
    x_line_locs.action_tbl(l_index)   := PO_PDOI_CONSTANTS.g_ACTION_MATCH;
    -- delete the corresponding node so the line won't be processed again
    x_processing_row_tbl.DELETE(l_index);
  END LOOP;

   d_position:= 30;
  -- If  Line number provided in the batch exists in draft and line grouping criteria does not match
  -- the line should be errored out.
  -- If matching criteria is not matched the action in x_line_locs will still be ADD

  l_index_tbl.delete;

  FORALL i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key,num1)
  SELECT l_key,
         x_processing_row_tbl(i)
  FROM   po_line_locations_draft_all plld
  WHERE  draft_id = x_line_locs.draft_id_tbl(i)
  AND    plld.po_header_id = x_line_locs.hd_po_header_id_tbl(i)
  AND    plld.po_line_id   = x_line_locs.ln_po_line_id_tbl(i)
  AND    NVL(delete_flag, 'N') <> 'Y'
  AND    plld.shipment_num = x_line_locs.shipment_num_tbl(i)
  AND    x_line_locs.action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_ADD;

  DELETE FROM po_session_gt
  WHERE KEY = l_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP

   l_index := l_index_tbl(i);

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Error on index', l_index);
     PO_LOG.stmt(d_module, d_position, 'Po line Id', x_line_locs.ln_po_line_id_tbl(l_index));
     PO_LOG.stmt(d_module, d_position, 'Shipment num',x_line_locs.shipment_num_tbl(l_index));
   END IF;

    PO_PDOI_ERR_UTL.add_fatal_error
     (
       p_interface_header_id  => x_line_locs.intf_header_id_tbl(l_index),
       p_interface_line_id    => x_line_locs.intf_line_id_tbl(l_index),
       p_interface_line_location_id => x_line_locs.intf_line_loc_id_tbl(l_index),
       p_error_message_name   => 'PO_PDOI_GRP_SHIP_NUM_UNIQUE',
       p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
       p_column_name          => 'SHIPMENT_NUM',
       p_column_value         => x_line_locs.shipment_num_tbl(l_index),
       p_token2_name          => 'VALUE',
       p_token2_value         => x_line_locs.shipment_num_tbl(l_index),
       p_line_locs            => x_line_locs
      );

    x_line_locs.error_flag_tbl(l_index) := FND_API.g_TRUE;
    x_processing_row_tbl.DELETE(l_index);
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
END match_shipments_on_draft;
-----------------------------------------------------------------------
--Start of Comments
--Name: match_shipments_on_txn
--Pre-requisites:
--Function:
-- The procedure will match on the draft table
--Parameters:
--IN:
--IN OUT: None
--  x_line_locs
--  Record having line locations within a batch
--  x_processing_row_tbl
--  Table where shipments have been processed or not
--OUT: None
--End of Comments
------------------------------------------------------------------------
PROCEDURE   match_shipments_on_txn
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'match_shipments_on_txn';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

    -- hold the key value which is used to identify rows in temp table
  l_key           po_session_gt.key%TYPE;
  l_po_line_id    po_lines_all.po_line_id%TYPE;
  l_shipment_num  po_line_locations_all.shipment_num%TYPE;
  l_index         NUMBER;


  l_index_tbl             PO_TBL_NUMBER;
  l_match_num_tbl         PO_TBL_NUMBER;
  l_match_id_tbl          PO_TBL_NUMBER;
  l_po_line_id_tbl        PO_TBL_NUMBER;

  -- hash table  based on po_line_id and shipment number
  TYPE line_loc_ref_internal_type IS TABLE OF NUMBER INDEX BY VARCHAR2(32);
  TYPE line_loc_ref_type IS TABLE OF line_loc_ref_internal_type INDEX BY PLS_INTEGER;

  l_shipment_num_ref_tbl line_loc_ref_type;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;


  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of Records to be processed', x_processing_row_tbl.COUNT);
  END IF;

  IF x_processing_row_tbl.COUNT = 0 THEN
    RETURN;
  END IF;

  -- get new key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  FORALL i IN INDICES OF  x_processing_row_tbl
  INSERT INTO po_session_gt(key,num1,num2,num3,num4)
  SELECT l_key,
         x_processing_row_tbl(i),
	 shipment_num,
	 line_location_id,
	 po_line_id
  FROM  po_line_locations_all poll
  WHERE poll.po_header_id = x_line_locs.hd_po_header_id_tbl(i)
  AND   poll.po_line_id =   x_line_locs.ln_po_line_id_tbl(i)
  AND   NVL(poll.cancel_flag,'N') = 'N'
  AND   NVL(poll.closed_code,'OPEN') <> 'FINALLY CLOSED'
  AND   x_line_locs.ln_action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_UPDATE
  AND   x_line_locs.ln_req_line_id_tbl(i) IS NOT NULL
  AND   shipment_num =
       (SELECT  MIN(shipment_num)
        FROM  po_line_locations_all poll
	WHERE poll.po_header_id = x_line_locs.hd_po_header_id_tbl(i)
        AND   poll.po_line_id =   x_line_locs.ln_po_line_id_tbl(i)
        AND   NVL(poll.cancel_flag,'N') = 'N'
        AND   NVL(poll.closed_code,'OPEN') <> 'FINALLY CLOSED'
	AND   NVL(poll.ENCUMBERED_FLAG,'N') = 'N'
	AND   NVL(poll.drop_ship_flag, 'N') <> 'Y'
	AND   ((x_line_locs.shipment_num_tbl(i) IS NULL
                ) OR
	        poll.shipment_num = x_line_locs.shipment_num_tbl(i)
	       )
        AND   ((poll.ship_to_organization_id IS NULL AND
	        x_line_locs.ship_to_org_id_tbl(i) IS NULL
	        ) OR
		poll.ship_to_organization_id = x_line_locs.ship_to_org_id_tbl(i)
	       )
	AND   ((poll.ship_to_location_id IS NULL AND
		 x_line_locs.ship_to_loc_id_tbl(i) IS NULL
		) OR
		 poll.ship_to_location_id = x_line_locs.ship_to_loc_id_tbl(i)
	       )
        AND   ((poll.need_by_date IS NULL AND
	         x_line_locs.need_by_date_tbl(i) IS NULL
		) OR
		poll.need_by_date = x_line_locs.need_by_date_tbl(i)
	       )
        AND   ((poll.vmi_flag IS NULL AND
	         x_line_locs.vmi_flag_tbl(i) IS NULL
		) OR
		 poll.vmi_flag = x_line_locs.vmi_flag_tbl(i)
	       )
        AND   ((poll.consigned_flag IS NULL AND
		  x_line_locs.consigned_flag_tbl(i) IS NULL
	        ) OR
		poll.consigned_flag = x_line_locs.consigned_flag_tbl(i)
	      )
        AND   ((poll.note_to_receiver IS NULL AND
	         x_line_locs.note_to_receiver_tbl(i) IS NULL
	        ) OR
		poll.note_to_receiver = x_line_locs.note_to_receiver_tbl(i)
	       )
        AND   ((poll.accrue_on_receipt_flag IS NULL AND
		  x_line_locs.accrue_on_receipt_flag_tbl(i) IS NULL
	        ) OR
	       poll.accrue_on_receipt_flag = x_line_locs.accrue_on_receipt_flag_tbl(i)
	      )
       );

  d_position := 10;

  --Get the matched result from temp table
  DELETE FROM po_session_gt
  WHERE KEY = l_key
  RETURNING num1,num2,num3,num4
  BULK COLLECT INTO l_index_tbl,l_match_num_tbl,l_match_id_tbl,l_po_line_id_tbl;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_index_tbl', l_index_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_match_num_tbl', l_match_num_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_match_id_tbl', l_match_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_po_line_id_tbl', l_po_line_id_tbl);
  END IF;

  --set the matched shipment num and line_location_id

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);
    l_po_line_id := l_po_line_id_tbl(i);
    l_shipment_num := l_match_num_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'matched po shipment id id', l_match_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'matched Shipment num', l_match_num_tbl(i));
    END IF;

    d_position := 20;

     --More than one req reference shipment is matched to same PO shipment
     -- Only one line should have action as UPDATE
     IF (l_shipment_num_ref_tbl.EXISTS(l_po_line_id) AND
          l_shipment_num_ref_tbl(l_po_line_id).EXISTS(l_shipment_num)) THEN

        x_line_locs.line_loc_id_tbl(l_index) :=
          l_shipment_num_ref_tbl(l_po_line_id)(l_shipment_num);
        x_line_locs.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_MATCH;
        x_line_locs.shipment_num_tbl(l_index) := l_match_num_tbl(i);

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'match found for update shipment');
          PO_LOG.stmt(d_module, d_position, 'new po lineloc id',
                      x_line_locs.line_loc_id_tbl(l_index));
        END IF;
    ELSE

    d_position := 30;

      x_line_locs.shipment_num_tbl(l_index) := l_match_num_tbl(i);
      x_line_locs.line_loc_id_tbl(l_index) := l_match_id_tbl(i);
      x_line_locs.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_UPDATE;
      x_line_locs.tax_attribute_update_code_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_UPDATE;

      l_shipment_num_ref_tbl(l_po_line_id)(l_shipment_num) :=
         l_match_id_tbl(i);

    END IF;
    -- delete the corresponding node so the line won't be processed again
    x_processing_row_tbl.DELETE(l_index);
  END LOOP;

  l_index_tbl.DELETE ;

  d_position:= 40;

  --Error all the shipment which could not find match
  --from above query if shipment num is not null
  -- and match cannot be found in the current batch

  FORALL i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key,num1)
  SELECT l_key,
         x_processing_row_tbl(i)
  FROM po_line_locations_all poll
  WHERE x_line_locs.ln_action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_UPDATE
  AND   poll.shipment_num = x_line_locs.shipment_num_tbl(i)
  AND   poll.po_line_id = x_line_locs.ln_po_line_id_tbl(i)
  AND   x_line_locs.ln_req_line_id_tbl(i) IS NOT NULL
  AND   x_line_locs.shipment_num_tbl(i) IS NOT NULL
  AND   x_line_locs.action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_ADD
  AND   NOT EXISTS (SELECT 1
                    FROM  po_line_locations_gt
		    WHERE shipment_num = x_line_locs.shipment_num_tbl(i)
                    );

  DELETE po_session_gt
  WHERE KEY = l_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP

  d_position := 50;

    l_index := l_index_tbl(i);

    -- check if match does not exists in current batch and then throw an error

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Error on index', l_index);
     PO_LOG.stmt(d_module, d_position, 'Po line Id', x_line_locs.ln_po_line_id_tbl(l_index));
     PO_LOG.stmt(d_module, d_position, 'Shipment num',x_line_locs.shipment_num_tbl(l_index));
   END IF;

    PO_PDOI_ERR_UTL.add_fatal_error
     (
       p_interface_header_id  => x_line_locs.intf_header_id_tbl(l_index),
       p_interface_line_id    => x_line_locs.intf_line_id_tbl(l_index),
       p_interface_line_location_id => x_line_locs.intf_line_loc_id_tbl(l_index),
       p_error_message_name   => 'PO_PDOI_REQ_SHIPMENT_MISMATCH',
       p_table_name           => 'PO_LINE_LOCATIONS_INTERFACE',
       p_column_name          => 'SHIPMENT_NUM',
       p_column_value         => x_line_locs.shipment_num_tbl(l_index),
       p_token2_name          => 'VALUE',
       p_token2_value         => x_line_locs.shipment_num_tbl(l_index),
       p_line_locs            => x_line_locs
      );

    x_line_locs.error_flag_tbl(l_index) := FND_API.g_TRUE;
    x_processing_row_tbl.DELETE(l_index);
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
END match_shipments_on_txn;
-----------------------------------------------------------------------
--Start of Comments
--Name: match_shipments_on_interface
--Pre-requisites:
--Function:
-- The procedure will match shipments within current batch
--Parameters:
--IN:
--IN OUT: None
--  x_line_locs
--  Record having line locations within a batch
--  x_processing_row_tbl
--  Table where shipments have been processed or not
--OUT: None
--End of Comments
------------------------------------------------------------------------
PROCEDURE   match_shipments_on_interface
( x_line_locs          IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'match_shipments_on_interface';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key           po_session_gt.key%TYPE;
  l_po_line_id    po_lines_all.po_line_id%TYPE;
  l_shipment_num  po_line_locations_all.shipment_num%TYPE;
  l_index         NUMBER;
  l_match_index   NUMBER;

  l_index_tbl             PO_TBL_NUMBER;
  l_match_index_tbl       PO_TBL_NUMBER;
  l_processed_index_tbl   PO_TBL_NUMBER;
  l_shipment_num_tbl      PO_TBL_NUMBER;


  -- hash table  based on po_line_id and shipment number
  TYPE line_loc_ref_internal_type IS TABLE OF NUMBER INDEX BY VARCHAR2(32);
  TYPE line_loc_ref_type IS TABLE OF line_loc_ref_internal_type INDEX BY PLS_INTEGER;

  l_shipment_num_ref_tbl line_loc_ref_type;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of rows to be processed ', x_processing_row_tbl.COUNT);
  END IF;

  d_position := 10;
  -- get new key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  FORALL i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key,num1)
  SELECT l_key,
         x_processing_row_tbl(i)
  FROM   DUAL;

  DELETE FROM po_session_gt
  WHERE KEY = l_key
  RETURNING num1 BULK COLLECT INTO l_processed_index_tbl;

  SELECT pllg.source_shipment_id, --processing index
         pllg.shipment_num,
         first_value(pllg.source_shipment_id)
	 OVER(PARTITION BY
	        pllg.po_header_id,
	        pllg.po_line_id,
	        pllg.shipment_num,
	        pllg.ship_to_organization_id,
	        pllg.ship_to_location_id,
	        TRUNC(pllg.need_by_date),
	        pllg.vmi_flag,
	        pllg.consigned_flag,
	        pllg.preferred_grade, -- Bug#18007765
	        pllg.note_to_receiver,
	        pllg.accrue_on_receipt_flag
              ORDER BY pllg.source_shipment_id
	      )match_index
   BULK COLLECT INTO
        l_index_tbl,
	l_shipment_num_tbl,
	l_match_index_tbl
   FROM po_line_locations_gt pllg,
         (SELECT column_value val
	    FROM TABLE(l_processed_index_tbl)) index_tbl
   WHERE pllg.source_shipment_id = index_tbl.val;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_index_tbl', l_index_tbl);
     PO_LOG.stmt(d_module, d_position, 'l_match_index_tbl', l_match_index_tbl);
   END IF;

   FOR i IN 1..l_index_tbl.COUNT
   LOOP
     l_index := l_index_tbl(i);
     l_match_index := l_match_index_tbl(i);

     IF l_index = l_match_index THEN

       x_line_locs.line_loc_id_tbl(l_index) :=  PO_PDOI_MAINPROC_UTL_PVT.get_next_line_loc_id;
       x_line_locs.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_ADD;
       -- Line number can have value for record req reference and not matched
       -- with existing PO and matches with current batch
       IF x_line_locs.shipment_num_tbl(l_index) IS NULL THEN
         x_line_locs.shipment_num_tbl(l_index) :=
          NVL(l_shipment_num_tbl(i),
	  PO_PDOI_MAINPROC_UTL_PVT.get_next_shipment_num(x_line_locs.ln_po_line_id_tbl(l_index)));
       END IF;
       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module, d_position, 'index', l_index);
         PO_LOG.stmt(d_module, d_position, 'assigned po shipment id',
                      x_line_locs.line_loc_id_tbl(l_index));
         PO_LOG.stmt(d_module, d_position, 'assigned shipment num', x_line_locs.shipment_num_tbl(l_index));
       END IF;
     ELSE

       x_line_locs.line_loc_id_tbl(l_index) := x_line_locs.line_loc_id_tbl(l_match_index);
       x_line_locs.shipment_num_tbl(l_index) := x_line_locs.shipment_num_tbl(l_match_index);
       x_line_locs.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_MATCH;

       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module, d_position, 'index', l_index);
         PO_LOG.stmt(d_module, d_position, 'match index', l_match_index);
         PO_LOG.stmt(d_module, d_position, 'matched po shipment id',
                    x_line_locs.line_loc_id_tbl(l_index));
         PO_LOG.stmt(d_module, d_position, 'matched shipment num', x_line_locs.shipment_num_tbl(l_index));
       END IF;
     END IF;
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

END match_shipments_on_interface;
-----------------------------------------------------------------------
--Start of Comments
--Name: split_line_locs
--Pre-requisites:
--Function:
-- The procedure will split shipments based on action
-- within current batch
--Parameters:
--IN:
--  p_line_locs
--  Record having line locations within a batch
--IN OUT:
--  x_create_line_locs
--  Shipments records which will be created
--  x_update_line_locs
--  Shipments records which will be udpated
--  x_match_line_locs
--  Shipments records which will be matched
--OUT: None
--End of Comments
------------------------------------------------------------------------

PROCEDURE   split_line_locs
(p_line_locs         IN  PO_PDOI_TYPES.line_locs_rec_type,
 x_create_line_locs  IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
 x_update_line_locs  IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type,
 x_match_line_locs   IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'split_line_locs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- store index of rows to be copied to different records
  l_create_index_tbl   DBMS_SQL.NUMBER_TABLE;
  l_update_index_tbl   DBMS_SQL.NUMBER_TABLE;
  l_match_index_tbl    DBMS_SQL.NUMBER_TABLE;

 BEGIN

   d_position := 0;

   IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
   END IF;

   d_position := 10;
   FOR i IN 1..p_line_locs.rec_count
   LOOP

     IF p_line_locs.error_flag_tbl(i) = FND_API.g_FALSE THEN
       IF p_line_locs.action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_ADD THEN

  	 IF (PO_LOG.d_stmt) THEN
           PO_LOG.stmt(d_module, d_position, 'Shipment to create',
 	   p_line_locs.intf_line_loc_id_tbl(i));
         END IF;

 	 l_create_index_tbl(i) := i;
       ELSIF p_line_locs.action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_UPDATE THEN

	 IF (PO_LOG.d_stmt) THEN
           PO_LOG.stmt(d_module, d_position, 'Shipment to update',
	    p_line_locs.intf_line_loc_id_tbl(i));
         END IF;

	 l_update_index_tbl(i) := i;
       ELSIF p_line_locs.action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_MATCH THEN

	 IF (PO_LOG.d_stmt) THEN
           PO_LOG.stmt(d_module, d_position, 'Shipment matched',
	    p_line_locs.intf_line_loc_id_tbl(i));
          END IF;

	  l_match_index_tbl(i) := i;

       END IF;
     END IF;
   END LOOP;

   d_position := 20;

     -- copy rows to insert record
  copy_line_locs
  (
    p_source_line_locs  => p_line_locs,
    p_source_index_tbl  => l_create_index_tbl,
    x_target_line_locs  => x_create_line_locs
  );

  d_position := 30;

  -- copy rows to update record
  copy_line_locs
  (
    p_source_line_locs => p_line_locs,
    p_source_index_tbl => l_update_index_tbl,
    x_target_line_locs => x_update_line_locs
  );

  d_position := 40;

 -- copy rows to match record
  copy_line_locs
  (
    p_source_line_locs => p_line_locs,
    p_source_index_tbl => l_match_index_tbl,
    x_target_line_locs => x_match_line_locs
  );
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
 END split_line_locs;
-----------------------------------------------------------------------
--Start of Comments
--Name: copy_line_locs
--Function:
--  copy all the attribute values from one po_line_loc to another
--Parameters:
--IN:
--  p_source_line_locs
--    source of copy action
--  p_source_index_tbl
--    the indexes of line to be copied
--IN OUT:
--  x_target_line_locs
--    record containing lines copied from source line
--OUT:
--End of Comments
------------------------------------------------------------------------
 PROCEDURE copy_line_locs
(
  p_source_line_locs   IN PO_PDOI_TYPES.line_locs_rec_type,
  p_source_index_tbl   IN DBMS_SQL.NUMBER_TABLE,
  x_target_line_locs   IN OUT NOCOPY  PO_PDOI_TYPES.line_locs_rec_type
) IS


  d_api_name CONSTANT VARCHAR2(30) := 'copy_line_locs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_source_index NUMBER;
  l_target_index NUMBER :=0;

BEGIN

   d_position := 0;

   IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
   END IF;

   -- initialize the tables
   PO_PDOI_TYPES.fill_all_line_locs_attr
   ( p_num_records => p_source_index_tbl.COUNT,
     x_line_locs   => x_target_line_locs
   );

   IF (p_source_index_tbl.COUNT = 0) THEN

     IF (PO_LOG.d_proc) THEN
       PO_LOG.proc_end(d_module, 'no line is copied', p_source_index_tbl.COUNT);
     END IF;
     RETURN;
   END IF;

   l_source_index := p_source_index_tbl.FIRST;
   WHILE (l_source_index IS NOT NULL)
   LOOP
     -- increase target index
     l_target_index := l_target_index + 1;

     x_target_line_locs.intf_line_loc_id_tbl(l_target_index)             := p_source_line_locs.intf_line_loc_id_tbl(l_source_index);
     x_target_line_locs.intf_line_id_tbl(l_target_index)  		           := p_source_line_locs.intf_line_id_tbl(l_source_index);
     x_target_line_locs.intf_header_id_tbl(l_target_index)  		         := p_source_line_locs.intf_header_id_tbl(l_source_index);
     x_target_line_locs.shipment_num_tbl(l_target_index)                 := p_source_line_locs.shipment_num_tbl(l_source_index);
     x_target_line_locs.shipment_type_tbl(l_target_index)                := p_source_line_locs.shipment_type_tbl(l_source_index);
     x_target_line_locs.line_loc_id_tbl(l_target_index)                  := p_source_line_locs.line_loc_id_tbl(l_source_index);
     x_target_line_locs.ship_to_org_code_tbl(l_target_index)             := p_source_line_locs.ship_to_org_code_tbl(l_source_index);
     x_target_line_locs.ship_to_org_id_tbl(l_target_index)               := p_source_line_locs.ship_to_org_id_tbl(l_source_index);
     x_target_line_locs.ship_to_loc_tbl(l_target_index)                  := p_source_line_locs.ship_to_loc_tbl(l_source_index);
     x_target_line_locs.ship_to_loc_id_tbl(l_target_index)               := p_source_line_locs.ship_to_loc_id_tbl(l_source_index);
     x_target_line_locs.payment_terms_tbl(l_target_index)                := p_source_line_locs.payment_terms_tbl(l_source_index);
     x_target_line_locs.terms_id_tbl(l_target_index)                     := p_source_line_locs.terms_id_tbl(l_source_index);
     x_target_line_locs.receiving_routing_tbl(l_target_index)            := p_source_line_locs.receiving_routing_tbl(l_source_index);
     x_target_line_locs.receiving_routing_id_tbl(l_target_index)         := p_source_line_locs.receiving_routing_id_tbl(l_source_index);
     x_target_line_locs.inspection_required_flag_tbl(l_target_index)     := p_source_line_locs.inspection_required_flag_tbl(l_source_index);
     x_target_line_locs.receipt_required_flag_tbl(l_target_index)        := p_source_line_locs.receipt_required_flag_tbl(l_source_index);
     x_target_line_locs.price_override_tbl(l_target_index)               := p_source_line_locs.price_override_tbl(l_source_index);
     -- <<Bug#17998869 Start>>
     x_target_line_locs.lead_time_tbl(l_target_index)                    := p_source_line_locs.lead_time_tbl(l_source_index);
     -- <<Bug#17998869 End>>
     x_target_line_locs.qty_rcv_tolerance_tbl(l_target_index)            := p_source_line_locs.qty_rcv_tolerance_tbl(l_source_index);
     x_target_line_locs.qty_rcv_exception_code_tbl(l_target_index)       := p_source_line_locs.qty_rcv_exception_code_tbl(l_source_index);
     x_target_line_locs.enforce_ship_to_loc_code_tbl(l_target_index)     := p_source_line_locs.enforce_ship_to_loc_code_tbl(l_source_index);
     x_target_line_locs.allow_sub_receipts_flag_tbl(l_target_index)      := p_source_line_locs.allow_sub_receipts_flag_tbl(l_source_index);
     x_target_line_locs.days_early_receipt_allowed_tbl(l_target_index)   := p_source_line_locs.days_early_receipt_allowed_tbl(l_source_index);
     x_target_line_locs.days_late_receipt_allowed_tbl(l_target_index)    := p_source_line_locs.days_late_receipt_allowed_tbl(l_source_index);
     x_target_line_locs.receipt_days_except_code_tbl(l_target_index)     := p_source_line_locs.receipt_days_except_code_tbl(l_source_index);
     x_target_line_locs.invoice_close_tolerance_tbl(l_target_index)      := p_source_line_locs.invoice_close_tolerance_tbl(l_source_index);
     x_target_line_locs.receive_close_tolerance_tbl(l_target_index)      := p_source_line_locs.receive_close_tolerance_tbl(l_source_index);
     x_target_line_locs.accrue_on_receipt_flag_tbl(l_target_index)       := p_source_line_locs.accrue_on_receipt_flag_tbl(l_source_index);
     x_target_line_locs.firm_flag_tbl(l_target_index)                    := p_source_line_locs.firm_flag_tbl(l_source_index);
     x_target_line_locs.fob_tbl(l_target_index)                          := p_source_line_locs.fob_tbl(l_source_index);
     x_target_line_locs.freight_carrier_tbl(l_target_index)              := p_source_line_locs.freight_carrier_tbl(l_source_index);
     x_target_line_locs.freight_term_tbl(l_target_index)                 := p_source_line_locs.freight_term_tbl(l_source_index);
     x_target_line_locs.need_by_date_tbl(l_target_index)                 := p_source_line_locs.need_by_date_tbl(l_source_index);
     x_target_line_locs.promised_date_tbl(l_target_index)                := p_source_line_locs.promised_date_tbl(l_source_index);
     x_target_line_locs.quantity_tbl(l_target_index)                     := p_source_line_locs.quantity_tbl(l_source_index);
     x_target_line_locs.amount_tbl(l_target_index)                       := p_source_line_locs.amount_tbl(l_source_index);
     x_target_line_locs.start_date_tbl(l_target_index)                   := p_source_line_locs.start_date_tbl(l_source_index);
     x_target_line_locs.end_date_tbl(l_target_index)                     := p_source_line_locs.end_date_tbl(l_source_index);
     x_target_line_locs.note_to_receiver_tbl(l_target_index)             := p_source_line_locs.note_to_receiver_tbl(l_source_index);
     x_target_line_locs.price_discount_tbl(l_target_index)               := p_source_line_locs.price_discount_tbl(l_source_index);
     x_target_line_locs.secondary_unit_of_meas_tbl(l_target_index)       := p_source_line_locs.secondary_unit_of_meas_tbl(l_source_index);
     x_target_line_locs.secondary_quantity_tbl(l_target_index)           := p_source_line_locs.secondary_quantity_tbl(l_source_index);
     x_target_line_locs.preferred_grade_tbl(l_target_index)              := p_source_line_locs.preferred_grade_tbl(l_source_index);
     x_target_line_locs.tax_code_id_tbl(l_target_index)                  := p_source_line_locs.tax_code_id_tbl(l_source_index);
     x_target_line_locs.tax_name_tbl(l_target_index)                     := p_source_line_locs.tax_name_tbl(l_source_index);
     x_target_line_locs.unit_of_measure_tbl(l_target_index)              := p_source_line_locs.unit_of_measure_tbl(l_source_index);
     x_target_line_locs.value_basis_tbl(l_target_index)                  := p_source_line_locs.value_basis_tbl(l_source_index);
     x_target_line_locs.matching_basis_tbl(l_target_index)               := p_source_line_locs.matching_basis_tbl(l_source_index);
     x_target_line_locs.payment_type_tbl(l_target_index)                 := p_source_line_locs.payment_type_tbl(l_source_index);
     x_target_line_locs.match_option_tbl(l_target_index)                 := p_source_line_locs.match_option_tbl(l_source_index);
     x_target_line_locs.txn_flow_header_id_tbl(l_target_index)           := p_source_line_locs.txn_flow_header_id_tbl(l_source_index);
     x_target_line_locs.outsourced_assembly_tbl(l_target_index)          := p_source_line_locs.outsourced_assembly_tbl(l_source_index);
     x_target_line_locs.tax_attribute_update_code_tbl(l_target_index)  	 := p_source_line_locs.tax_attribute_update_code_tbl(l_source_index);
     x_target_line_locs.action_tbl(l_target_index)  			 := p_source_line_locs.action_tbl(l_source_index);

     -- copy standard who columns
     x_target_line_locs.last_updated_by_tbl(l_target_index)              := p_source_line_locs.last_updated_by_tbl(l_source_index);
     x_target_line_locs.last_update_date_tbl(l_target_index)             := p_source_line_locs.last_update_date_tbl(l_source_index);
     x_target_line_locs.last_update_login_tbl(l_target_index)            := p_source_line_locs.last_update_login_tbl(l_source_index);
     x_target_line_locs.creation_date_tbl(l_target_index)                := p_source_line_locs.creation_date_tbl(l_source_index);
     x_target_line_locs.created_by_tbl(l_target_index)                   := p_source_line_locs.created_by_tbl(l_source_index);
     x_target_line_locs.request_id_tbl(l_target_index)                   := p_source_line_locs.request_id_tbl(l_source_index);
     x_target_line_locs.program_application_id_tbl(l_target_index)       := p_source_line_locs.program_application_id_tbl(l_source_index);
     x_target_line_locs.program_id_tbl(l_target_index)                   := p_source_line_locs.program_id_tbl(l_source_index);
     x_target_line_locs.program_update_date_tbl(l_target_index)          := p_source_line_locs.program_update_date_tbl(l_source_index);

     --copy attributes read from the line interface record

     x_target_line_locs.ln_req_line_id_tbl(l_target_index)               := p_source_line_locs.ln_req_line_id_tbl(l_source_index);
     x_target_line_locs.vmi_flag_tbl(l_target_index)                     := p_source_line_locs.vmi_flag_tbl(l_source_index);
     x_target_line_locs.drop_ship_flag_tbl(l_target_index)               := p_source_line_locs.drop_ship_flag_tbl(l_source_index);
     x_target_line_locs.consigned_flag_tbl(l_target_index)     	         := p_source_line_locs.consigned_flag_tbl(l_source_index);

     x_target_line_locs.ln_po_line_id_tbl(l_target_index)                := p_source_line_locs.ln_po_line_id_tbl(l_source_index);
     x_target_line_locs.ln_item_id_tbl(l_target_index)                   := p_source_line_locs.ln_item_id_tbl(l_source_index);
     x_target_line_locs.ln_item_category_id_tbl(l_target_index)          := p_source_line_locs.ln_item_category_id_tbl(l_source_index);
     x_target_line_locs.ln_order_type_lookup_code_tbl(l_target_index)    := p_source_line_locs.ln_order_type_lookup_code_tbl(l_source_index);
     x_target_line_locs.ln_action_tbl(l_target_index)                    := p_source_line_locs.ln_action_tbl(l_source_index);
     x_target_line_locs.ln_unit_price_tbl(l_target_index)                := p_source_line_locs.ln_unit_price_tbl(l_source_index);
     x_target_line_locs.ln_quantity_tbl(l_target_index)                  := p_source_line_locs.ln_quantity_tbl(l_source_index);
     x_target_line_locs.ln_amount_tbl(l_target_index)                    := p_source_line_locs.ln_amount_tbl(l_source_index);
     x_target_line_locs.ln_line_type_id_tbl(l_target_index)              := p_source_line_locs.ln_line_type_id_tbl(l_source_index);
     x_target_line_locs.ln_unit_of_measure_tbl(l_target_index)           := p_source_line_locs.ln_unit_of_measure_tbl(l_source_index);
     x_target_line_locs.ln_closed_code_tbl(l_target_index)               := p_source_line_locs.ln_closed_code_tbl(l_source_index);
     x_target_line_locs.ln_purchase_basis_tbl(l_target_index)            := p_source_line_locs.ln_purchase_basis_tbl(l_source_index);
     x_target_line_locs.ln_matching_basis_tbl(l_target_index)            := p_source_line_locs.ln_matching_basis_tbl(l_source_index);
     x_target_line_locs.ln_item_revision_tbl(l_target_index)             := p_source_line_locs.ln_item_revision_tbl(l_source_index);
     x_target_line_locs.ln_expiration_date_tbl(l_target_index)           := p_source_line_locs.ln_expiration_date_tbl(l_source_index);
     x_target_line_locs.ln_government_context_tbl(l_target_index)        := p_source_line_locs.ln_government_context_tbl(l_source_index);
     x_target_line_locs.ln_closed_reason_tbl(l_target_index)             := p_source_line_locs.ln_closed_reason_tbl(l_source_index);
     x_target_line_locs.ln_closed_date_tbl(l_target_index)               := p_source_line_locs.ln_closed_date_tbl(l_source_index);
     x_target_line_locs.ln_closed_by_tbl(l_target_index)                 := p_source_line_locs.ln_closed_by_tbl(l_source_index);
     x_target_line_locs.ln_from_header_id_tbl(l_target_index)            := p_source_line_locs.ln_from_header_id_tbl(l_source_index);
     x_target_line_locs.ln_from_line_id_tbl(l_target_index)              := p_source_line_locs.ln_from_line_id_tbl(l_source_index);
     x_target_line_locs.ln_price_break_lookup_code_tbl(l_target_index)   := p_source_line_locs.ln_price_break_lookup_code_tbl(l_source_index);
     x_target_line_locs.ln_item_desc_tbl(l_target_index)  		 := p_source_line_locs.ln_item_desc_tbl(l_source_index);

     -- copy attributes read from the header interface record
     x_target_line_locs.draft_id_tbl(l_target_index)                     := p_source_line_locs.draft_id_tbl(l_source_index);
     x_target_line_locs.hd_po_header_id_tbl(l_target_index)              := p_source_line_locs.hd_po_header_id_tbl(l_source_index);
     x_target_line_locs.hd_doc_type_tbl(l_target_index)                  := p_source_line_locs.hd_doc_type_tbl(l_source_index);
     x_target_line_locs.hd_ship_to_loc_id_tbl(l_target_index)            := p_source_line_locs.hd_ship_to_loc_id_tbl(l_source_index);
     x_target_line_locs.hd_vendor_id_tbl(l_target_index)                 := p_source_line_locs.hd_vendor_id_tbl(l_source_index);
     x_target_line_locs.hd_vendor_site_id_tbl(l_target_index)            := p_source_line_locs.hd_vendor_site_id_tbl(l_source_index);
     x_target_line_locs.hd_terms_id_tbl(l_target_index)                  := p_source_line_locs.hd_terms_id_tbl(l_source_index);
     x_target_line_locs.hd_fob_tbl(l_target_index)                       := p_source_line_locs.hd_fob_tbl(l_source_index);
     x_target_line_locs.hd_freight_carrier_tbl(l_target_index)           := p_source_line_locs.hd_freight_carrier_tbl(l_source_index);
     x_target_line_locs.hd_freight_term_tbl(l_target_index)              := p_source_line_locs.hd_freight_term_tbl(l_source_index);
     x_target_line_locs.hd_approved_flag_tbl(l_target_index)             := p_source_line_locs.hd_approved_flag_tbl(l_source_index);
     x_target_line_locs.hd_effective_date_tbl(l_target_index)            := p_source_line_locs.hd_effective_date_tbl(l_source_index);
     x_target_line_locs.hd_expiration_date_tbl(l_target_index)           := p_source_line_locs.hd_expiration_date_tbl(l_source_index);
     x_target_line_locs.hd_style_id_tbl(l_target_index)                  := p_source_line_locs.hd_style_id_tbl(l_source_index);
     x_target_line_locs.hd_currency_code_tbl(l_target_index)             := p_source_line_locs.hd_currency_code_tbl(l_source_index);

     -- copy  attributes added for processing purpose
     --x_target_line_locs.shipment_num_unique_tbl(l_target_index)          := p_source_line_locs.shipment_num_unique_tbl(l_source_index);
     x_target_line_locs.error_flag_tbl(l_target_index)       		 := p_source_line_locs.error_flag_tbl(l_source_index);

     -- get next index
     l_source_index := p_source_index_tbl.NEXT(l_source_index);
   END LOOP;

     -- rebuild index table
   FOR i IN 1..x_target_line_locs.rec_count
   LOOP
     x_target_line_locs.intf_id_index_tbl(x_target_line_locs.intf_line_loc_id_tbl(i)) := i;
   END LOOP;

   IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_end(d_module, 'number of copied line locs', l_target_index);
   END IF;

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
END copy_line_locs;
-- <<PDOI Enhancement Bug#17063664 End>>
-- <<Bug#17998869 Start>>
-----------------------------------------------------------------------
--Start of Comments
--Name: default_lead_time
--Function:
--  default the attribute lead_time po_attribute_values
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_ln_from_line_id_tbl
--    list of from_line_ids read within the batch
--IN OUT:
--OUT:
--  x_lead_time_tbl
--    list of default values from lead_time

--End of Comments
------------------------------------------------------------------------
PROCEDURE default_lead_time
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_ln_from_line_id_tbl        IN PO_TBL_NUMBER,
  x_lead_time_tbl              OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_lead_time';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold result read from temp table
  local_index_tbl              PO_TBL_NUMBER;
  l_index_tbl                  PO_TBL_NUMBER;
  l_lead_time_tbl              PO_TBL_NUMBER;

  -- current accessing index in the loop
  l_index                      NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module,'p_ln_from_line_id_tbl',p_ln_from_line_id_tbl);
  END IF;

  local_index_tbl := PO_TBL_NUMBER();
  local_index_tbl.EXTEND(p_index_tbl.COUNT);

  -- initialize index table which is used by all derivation logic
  FOR i IN 1..p_index_tbl.COUNT LOOP
    local_index_tbl(i) := i;
  END LOOP;

  x_lead_time_tbl := PO_TBL_NUMBER();
  x_lead_time_tbl.EXTEND(p_index_tbl.COUNT);

  --Fetch the lead time value based on the order line id
  SELECT pav.lead_time
       , index_tbl.val
  BULK COLLECT INTO l_lead_time_tbl
     , l_index_tbl
  FROM po_attribute_values pav
     , (SELECT column_value val, rownum rn
        FROM table(p_ln_from_line_id_tbl)) from_line_id_tbl
     , (SELECT column_value val, rownum rn
        FROM table(local_index_tbl)) index_tbl
  WHERE pav.po_line_id  = from_line_id_tbl.val
    AND index_tbl.rn    = from_line_id_tbl.rn;

  d_position := 10;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new lead time',
                  l_lead_time_tbl(i));
    END IF;

    x_lead_time_tbl(l_index) := l_lead_time_tbl(i);
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
END default_lead_time;
-- <<Bug#17998869 End>>


-----------------------------------------------------------------------
--Start of Comments
-- Bug 18534140
--Name: default_shipment_type
--Function:
--  default shipment_type based on style and payment_type.
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
-- p_payment_type_tbl
--  table containing payment_type of all rows
-- p_style_id_tbl
-- table containing style_id of all rows
--IN OUT:
--x_shipment_type_tbl
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_shipment_type
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_payment_type_tbl           IN PO_TBL_VARCHAR30,
  p_style_id_tbl               IN PO_TBL_NUMBER,
  x_shipment_type_tbl          IN OUT NOCOPY PO_TBL_VARCHAR30
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_shipment_type';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index_tbl PO_TBL_NUMBER;
  l_result_tbl PO_TBL_VARCHAR30;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module,'p_payment_type_tbl',p_payment_type_tbl);
    PO_LOG.proc_begin(d_module,'p_style_id_tbl',p_style_id_tbl);
  END IF;

  -- calclualte shipment_type based on style and payment_type.
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key, num1, char1)
  SELECT p_key,
         p_index_tbl(i),
         DECODE(NVL(pds.CONTRACT_FINANCING_FLAG, 'N'),
	          'Y', DECODE(NVL(p_payment_type_tbl(i), 'NULL'),
		                'DELIVERY', 'STANDARD',
				'NULL', 'STANDARD',
				'PREPAYMENT'),
		  'STANDARD')
  FROM   po_doc_style_headers pds
  WHERE  x_shipment_type_tbl(i) IS NULL
  AND    pds.style_id = p_style_id_tbl(i);

  d_position := 10;

  -- get result from temp table
  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, char1 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- set result back to x_shipment_type_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'shipment_type ',
                  l_result_tbl(i));
    END IF;
    d_position := 30;
    x_shipment_type_tbl(l_index_tbl(i)) := l_result_tbl(i);
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
END default_shipment_type;

END PO_PDOI_LINE_LOC_PROCESS_PVT;

/
