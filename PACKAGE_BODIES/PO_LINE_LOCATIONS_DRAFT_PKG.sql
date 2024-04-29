--------------------------------------------------------
--  DDL for Package Body PO_LINE_LOCATIONS_DRAFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_LOCATIONS_DRAFT_PKG" AS
/* $Header: PO_LINE_LOCATIONS_DRAFT_PKG.plb 120.8.12010000.2 2010/04/22 06:13:11 sknandip ship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_LINE_LOCATIONS_DRAFT_PKG');

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_rows
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Deletes drafts for line locations based on the information given
--  If only draft_id is provided, then all line locs for the draft will be
--  deleted
--  If line_location_id is also provided, then the one record that has such
--  primary key will be deleted
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_line_location_id
--  po line location unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE delete_rows
( p_draft_id IN NUMBER,
  p_line_location_id IN NUMBER
) IS
d_api_name CONSTANT VARCHAR2(30) := 'delete_rows';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  DELETE FROM po_line_locations_draft_all
  WHERE draft_id = p_draft_id
  AND line_location_id = NVL(p_line_location_id, line_location_id);

  d_position := 10;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END delete_rows;


-----------------------------------------------------------------------
--Start of Comments
--Name: sync_draft_from_txn
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Copy data from transaction table to draft table, if the corresponding
--  record in draft table does not exist. It also sets the delete flag of
--  the draft record according to the parameter.
--Parameters:
--IN:
--p_line_location_id_tbl
--  table of po line location unique identifier
--p_draft_id_tbl
--  table of draft ids this sync up will be done for
--p_delete_flag_tbl
--  table fo flags to indicate whether the draft record should be maked as
--  "to be deleted"
--IN OUT:
--OUT:
--x_record_already_exist_tbl
--  Returns whether the record was already in draft table or not
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE sync_draft_from_txn
( p_line_location_id_tbl     IN PO_TBL_NUMBER,
  p_draft_id_tbl             IN PO_TBL_NUMBER,
  p_delete_flag_tbl          IN PO_TBL_VARCHAR1,
  x_record_already_exist_tbl OUT NOCOPY PO_TBL_VARCHAR1
) IS

d_api_name CONSTANT VARCHAR2(30) := 'sync_draft_from_txn';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_distinct_id_list DBMS_SQL.NUMBER_TABLE;
l_duplicate_flag_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_record_already_exist_tbl :=
    PO_LINE_LOCATIONS_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_line_location_id_tbl => p_line_location_id_tbl
    );

  -- bug5471513 START
  -- If there're duplicate entries in the id table,
  -- we do not want to insert multiple entries
  -- Created an associative array to store what id has appeared.
  l_duplicate_flag_tbl.EXTEND(p_line_location_id_tbl.COUNT);

  FOR i IN 1..p_line_location_id_tbl.COUNT LOOP
    IF (x_record_already_exist_tbl(i) = FND_API.G_FALSE) THEN

      IF (l_distinct_id_list.EXISTS(p_line_location_id_tbl(i))) THEN

        l_duplicate_flag_tbl(i) := FND_API.G_TRUE;
      ELSE
        l_duplicate_flag_tbl(i) := FND_API.G_FALSE;

        l_distinct_id_list(p_line_location_id_tbl(i)) := 1;
      END IF;

    ELSE

      l_duplicate_flag_tbl(i) := NULL;

    END IF;
  END LOOP;
  -- bug5471513 END

  d_position := 10;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer records from txn to dft');
  END IF;

  FORALL i IN 1..p_line_location_id_tbl.COUNT
    INSERT INTO po_line_locations_draft_all
    ( draft_id,
      delete_flag,
      change_accepted_flag,
      line_location_id,
      last_update_date,
      last_updated_by,
      po_header_id,
      po_line_id,
      last_update_login,
      creation_date,
      created_by,
      quantity,
      quantity_accepted,
      quantity_received,
      quantity_rejected,
      quantity_billed,
      quantity_cancelled,
      unit_meas_lookup_code,
      po_release_id,
      ship_to_location_id,
      ship_via_lookup_code,
      need_by_date,
      promised_date,
      last_accept_date,
      price_override,
      encumbered_flag,
      encumbered_date,
      unencumbered_quantity,
      fob_lookup_code,
      freight_terms_lookup_code,
      taxable_flag,
      tax_name,
      estimated_tax_amount,
      from_header_id,
      from_line_id,
      from_line_location_id,
      start_date,
      end_date,
      lead_time,
      lead_time_unit,
      price_discount,
      terms_id,
      approved_flag,
      approved_date,
      closed_flag,
      cancel_flag,
      cancelled_by,
      cancel_date,
      cancel_reason,
      firm_status_lookup_code,
      firm_date,
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
      unit_of_measure_class,
      encumber_now,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      inspection_required_flag,
      receipt_required_flag,
      qty_rcv_tolerance,
      qty_rcv_exception_code,
      enforce_ship_to_location_code,
      allow_substitute_receipts_flag,
      days_early_receipt_allowed,
      days_late_receipt_allowed,
      receipt_days_exception_code,
      invoice_close_tolerance,
      receive_close_tolerance,
      ship_to_organization_id,
      shipment_num,
      source_shipment_id,
      shipment_type,
      closed_code,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      ussgl_transaction_code,
      government_context,
      receiving_routing_id,
      accrue_on_receipt_flag,
      closed_reason,
      closed_date,
      closed_by,
      org_id,
      quantity_shipped,
      global_attribute_category,
      global_attribute1,
      global_attribute2,
      global_attribute3,
      global_attribute4,
      global_attribute5,
      global_attribute6,
      global_attribute7,
      global_attribute8,
      global_attribute9,
      global_attribute10,
      global_attribute11,
      global_attribute12,
      global_attribute13,
      global_attribute14,
      global_attribute15,
      global_attribute16,
      global_attribute17,
      global_attribute18,
      global_attribute19,
      global_attribute20,
      country_of_origin_code,
      tax_user_override_flag,
      match_option,
      tax_code_id,
      calculate_tax_flag,
      change_promised_date_reason,
      note_to_receiver,
      secondary_quantity,
      secondary_unit_of_measure,
      preferred_grade,
      secondary_quantity_received,
      secondary_quantity_accepted,
      secondary_quantity_rejected,
      secondary_quantity_cancelled,
      secondary_quantity_shipped,
      vmi_flag,
      consigned_flag,
      retroactive_date,
      supplier_order_line_number,
      amount,
      amount_received,
      amount_billed,
      amount_cancelled,
      amount_rejected,
      amount_accepted,
      drop_ship_flag,
      sales_order_update_date,
      transaction_flow_header_id,
      final_match_flag,
      manual_price_change_flag,
      shipment_closed_date,
      closed_for_receiving_date,
      closed_for_invoice_date,
      -- <Complex Work R12 Start>
      value_basis,
      matching_basis,
      payment_type,
      description,
      work_approver_id,
      bid_payment_id,
      quantity_financed,
      amount_financed,
      quantity_recouped,
      amount_recouped,
      retainage_withheld_amount,
      retainage_released_amount,
      -- <Complex Work R12 End>
      outsourced_assembly,
      tax_attribute_update_code -- <ETAX R12>
    )
    SELECT
      p_draft_id_tbl(i),
      p_delete_flag_tbl(i),
      NULL,
      line_location_id,
      last_update_date,
      last_updated_by,
      po_header_id,
      po_line_id,
      last_update_login,
      creation_date,
      created_by,
      quantity,
      quantity_accepted,
      quantity_received,
      quantity_rejected,
      quantity_billed,
      quantity_cancelled,
      unit_meas_lookup_code,
      po_release_id,
      ship_to_location_id,
      ship_via_lookup_code,
      need_by_date,
      promised_date,
      last_accept_date,
      price_override,
      encumbered_flag,
      encumbered_date,
      unencumbered_quantity,
      fob_lookup_code,
      freight_terms_lookup_code,
      taxable_flag,
      tax_name,
      estimated_tax_amount,
      from_header_id,
      from_line_id,
      from_line_location_id,
      start_date,
      end_date,
      lead_time,
      lead_time_unit,
      price_discount,
      terms_id,
      approved_flag,
      approved_date,
      closed_flag,
      cancel_flag,
      cancelled_by,
      cancel_date,
      cancel_reason,
      firm_status_lookup_code,
      firm_date,
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
      unit_of_measure_class,
      encumber_now,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      inspection_required_flag,
      receipt_required_flag,
      qty_rcv_tolerance,
      qty_rcv_exception_code,
      enforce_ship_to_location_code,
      allow_substitute_receipts_flag,
      days_early_receipt_allowed,
      days_late_receipt_allowed,
      receipt_days_exception_code,
      invoice_close_tolerance,
      receive_close_tolerance,
      ship_to_organization_id,
      shipment_num,
      source_shipment_id,
      shipment_type,
      closed_code,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      ussgl_transaction_code,
      government_context,
      receiving_routing_id,
      accrue_on_receipt_flag,
      closed_reason,
      closed_date,
      closed_by,
      org_id,
      quantity_shipped,
      global_attribute_category,
      global_attribute1,
      global_attribute2,
      global_attribute3,
      global_attribute4,
      global_attribute5,
      global_attribute6,
      global_attribute7,
      global_attribute8,
      global_attribute9,
      global_attribute10,
      global_attribute11,
      global_attribute12,
      global_attribute13,
      global_attribute14,
      global_attribute15,
      global_attribute16,
      global_attribute17,
      global_attribute18,
      global_attribute19,
      global_attribute20,
      country_of_origin_code,
      tax_user_override_flag,
      match_option,
      tax_code_id,
      calculate_tax_flag,
      change_promised_date_reason,
      note_to_receiver,
      secondary_quantity,
      secondary_unit_of_measure,
      preferred_grade,
      secondary_quantity_received,
      secondary_quantity_accepted,
      secondary_quantity_rejected,
      secondary_quantity_cancelled,
      secondary_quantity_shipped,
      vmi_flag,
      consigned_flag,
      retroactive_date,
      supplier_order_line_number,
      amount,
      amount_received,
      amount_billed,
      amount_cancelled,
      amount_rejected,
      amount_accepted,
      drop_ship_flag,
      sales_order_update_date,
      transaction_flow_header_id,
      final_match_flag,
      manual_price_change_flag,
      shipment_closed_date,
      closed_for_receiving_date,
      closed_for_invoice_date,
      -- <Complex Work R12 Start>
      value_basis,
      matching_basis,
      payment_type,
      description,
      work_approver_id,
      bid_payment_id,
      quantity_financed,
      amount_financed,
      quantity_recouped,
      amount_recouped,
      retainage_withheld_amount,
      retainage_released_amount,
      -- <Complex Work R12 End>
      outsourced_assembly,
      tax_attribute_update_code -- <ETAX R12>
    FROM po_line_locations_all
    WHERE line_location_id = p_line_location_id_tbl(i)
    AND x_record_already_exist_tbl(i) = FND_API.G_FALSE
    AND l_duplicate_flag_tbl(i) = FND_API.G_FALSE;

  d_position := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer count = ' || SQL%ROWCOUNT);
  END IF;

  FORALL i IN 1..p_line_location_id_tbl.COUNT
    UPDATE po_line_locations_draft_all
    SET    delete_flag = p_delete_flag_tbl(i)
    WHERE  line_location_id = p_line_location_id_tbl(i)
    AND    draft_id = p_draft_id_tbl(i)
    AND    NVL(delete_flag, 'N') <> 'Y'  -- bug5570989
    AND    x_record_already_exist_tbl(i) = FND_API.G_TRUE;

  d_position := 30;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'update draft records that are already' ||
                ' in draft table. Count = ' || SQL%ROWCOUNT);
  END IF;

  d_position := 40;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_draft_from_txn;


-----------------------------------------------------------------------
--Start of Comments
--Name: sync_draft_from_txn
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Same functionality as the bulk version of this procedure
--Parameters:
--IN:
--p_line_location_id
--  line location unique identifier
--p_draft_id
--  the draft this sync up will be done for
--p_delete_flag
--  flag to indicate whether the draft record should be maked as "to be
--  deleted"
--IN OUT:
--OUT:
--x_record_already_exist
--  Returns whether the record was already in draft table or not
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE sync_draft_from_txn
( p_line_location_id IN NUMBER,
  p_draft_id IN NUMBER,
  p_delete_flag IN VARCHAR2,
  x_record_already_exist OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'sync_draft_from_txn';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_record_already_exist_tbl PO_TBL_VARCHAR1;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_line_location_id', p_line_location_id);
  END IF;

  sync_draft_from_txn
  ( p_line_location_id_tbl     => PO_TBL_NUMBER(p_line_location_id),
    p_draft_id_tbl             => PO_TBL_NUMBER(p_draft_id),
    p_delete_flag_tbl          => PO_TBL_VARCHAR1(p_delete_flag),
    x_record_already_exist_tbl => l_record_already_exist_tbl
  );

  x_record_already_exist := l_record_already_exist_tbl(1);

  d_position := 10;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
    PO_LOG.proc_end(d_module, 'x_record_already_exist', x_record_already_exist);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_draft_from_txn;

-----------------------------------------------------------------------
--Start of Comments
--Name: merge_changes
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Merge the records in draft table to transaction table
--  Either insert, update or delete will be performed on top of transaction
--  table, depending on the delete_flag on the draft record and whether the
--  record already exists in transaction table
--
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE merge_changes
( p_draft_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'merge_changes';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  -- Since putting DELETE within MERGE statement is causing database
  -- to thrown internal error, for now we just separate the DELETE statement.
  -- Once this is fixed we'll move the delete statement back to the merge
  -- statement

  -- bug5187544
  -- Delete only records that have not been rejected

  DELETE FROM po_line_locations_all PLL
  WHERE PLL.line_location_id IN
         ( SELECT PLLD.line_location_id
           FROM   po_line_locations_draft_all PLLD
           WHERE  PLLD.draft_id = p_draft_id
           AND    PLLD.delete_flag = 'Y'
           AND    NVL(PLLD.change_accepted_flag, 'Y') = 'Y');

  d_position := 10;

  -- Merge PO Line Location changes
  -- For update case, the following columns will be skipped:
  --PLL.line_location_id
  --PLL.creation_date
  --PLL.created_by
  --PLL.quantity_accepted
  --PLL.quantity_received
  --PLL.quantity_rejected
  --PLL.quantity_billed
  --PLL.quantity_cancelled
  --PLL.tax_name
  --PLL.estimated_tax_amount
  --PLL.firm_date
  --PLL.unit_of_measure_class
  --PLL.encumber_now
  --PLL.request_id
  --PLL.program_application_id
  --PLL.program_id
  --PLL.program_update_date
  --PLL.quantity_shipped
  --PLL.change_promised_date_reason
  --PLL.secondary_quantity_received
  --PLL.secondary_quantity_accepted
  --PLL.secondary_quantity_rejected
  --PLL.secondary_quantity_cancelled
  --PLL.secondary_quantity_shipped
  --PLL.amount_received
  --PLL.amount_billed
  --PLL.amount_cancelled
  --PLL.amount_rejected
  --PLL.amount_accepted
  --PLL.drop_ship_flag
  --PLL.sales_order_update_date
  --PLL.final_match_flag
  --PLL.shipment_closed_date
  --PLL.closed_for_receiving_date
  --PLL.closed_for_invoice_date
  -- <Complex Work R12 Start>
  --PLL.bid_payment_id
  --PLL.quantity_financed
  --PLL.amount_financed
  --PLL.quantity_recouped
  --PLL.amount_recouped
  --PLL.retainage_withheld_amount
  --PLL.retainage_released_amount
  -- <Complex Work R12 End>
  MERGE INTO po_line_locations_all PLL
  USING (
    SELECT
      PLLD.line_location_id,
      PLLD.last_update_date,
      PLLD.last_updated_by,
      PLLD.po_header_id,
      PLLD.po_line_id,
      PLLD.last_update_login,
      PLLD.creation_date,
      PLLD.created_by,
      PLLD.quantity,
      PLLD.quantity_accepted,
      PLLD.quantity_received,
      PLLD.quantity_rejected,
      PLLD.quantity_billed,
      PLLD.quantity_cancelled,
      PLLD.unit_meas_lookup_code,
      PLLD.po_release_id,
      PLLD.ship_to_location_id,
      PLLD.ship_via_lookup_code,
      PLLD.need_by_date,
      PLLD.promised_date,
      PLLD.last_accept_date,
      PLLD.price_override,
      PLLD.encumbered_flag,
      PLLD.encumbered_date,
      PLLD.unencumbered_quantity,
      PLLD.fob_lookup_code,
      PLLD.freight_terms_lookup_code,
      PLLD.taxable_flag,
      PLLD.tax_name,
      PLLD.estimated_tax_amount,
      PLLD.from_header_id,
      PLLD.from_line_id,
      PLLD.from_line_location_id,
      PLLD.start_date,
      PLLD.end_date,
      PLLD.lead_time,
      PLLD.lead_time_unit,
      PLLD.price_discount,
      PLLD.terms_id,
      PLLD.approved_flag,
      PLLD.approved_date,
      PLLD.closed_flag,
      PLLD.cancel_flag,
      PLLD.cancelled_by,
      PLLD.cancel_date,
      PLLD.cancel_reason,
      PLLD.firm_status_lookup_code,
      PLLD.firm_date,
      PLLD.attribute_category,
      PLLD.attribute1,
      PLLD.attribute2,
      PLLD.attribute3,
      PLLD.attribute4,
      PLLD.attribute5,
      PLLD.attribute6,
      PLLD.attribute7,
      PLLD.attribute8,
      PLLD.attribute9,
      PLLD.attribute10,
      PLLD.unit_of_measure_class,
      PLLD.encumber_now,
      PLLD.attribute11,
      PLLD.attribute12,
      PLLD.attribute13,
      PLLD.attribute14,
      PLLD.attribute15,
      PLLD.inspection_required_flag,
      PLLD.receipt_required_flag,
      PLLD.qty_rcv_tolerance,
      PLLD.qty_rcv_exception_code,
      PLLD.enforce_ship_to_location_code,
      PLLD.allow_substitute_receipts_flag,
      PLLD.days_early_receipt_allowed,
      PLLD.days_late_receipt_allowed,
      PLLD.receipt_days_exception_code,
      PLLD.invoice_close_tolerance,
      PLLD.receive_close_tolerance,
      PLLD.ship_to_organization_id,
      PLLD.shipment_num,
      PLLD.source_shipment_id,
      PLLD.shipment_type,
      PLLD.closed_code,
      PLLD.request_id,
      PLLD.program_application_id,
      PLLD.program_id,
      PLLD.program_update_date,
      PLLD.ussgl_transaction_code,
      PLLD.government_context,
      PLLD.receiving_routing_id,
      PLLD.accrue_on_receipt_flag,
      PLLD.closed_reason,
      PLLD.closed_date,
      PLLD.closed_by,
      PLLD.org_id,
      PLLD.quantity_shipped,
      PLLD.global_attribute_category,
      PLLD.global_attribute1,
      PLLD.global_attribute2,
      PLLD.global_attribute3,
      PLLD.global_attribute4,
      PLLD.global_attribute5,
      PLLD.global_attribute6,
      PLLD.global_attribute7,
      PLLD.global_attribute8,
      PLLD.global_attribute9,
      PLLD.global_attribute10,
      PLLD.global_attribute11,
      PLLD.global_attribute12,
      PLLD.global_attribute13,
      PLLD.global_attribute14,
      PLLD.global_attribute15,
      PLLD.global_attribute16,
      PLLD.global_attribute17,
      PLLD.global_attribute18,
      PLLD.global_attribute19,
      PLLD.global_attribute20,
      PLLD.country_of_origin_code,
      PLLD.tax_user_override_flag,
      PLLD.match_option,
      PLLD.tax_code_id,
      PLLD.calculate_tax_flag,
      PLLD.change_promised_date_reason,
      PLLD.note_to_receiver,
      PLLD.secondary_quantity,
      PLLD.secondary_unit_of_measure,
      PLLD.preferred_grade,
      PLLD.secondary_quantity_received,
      PLLD.secondary_quantity_accepted,
      PLLD.secondary_quantity_rejected,
      PLLD.secondary_quantity_cancelled,
      PLLD.secondary_quantity_shipped,
      PLLD.vmi_flag,
      PLLD.consigned_flag,
      PLLD.retroactive_date,
      PLLD.supplier_order_line_number,
      PLLD.amount,
      PLLD.amount_received,
      PLLD.amount_billed,
      PLLD.amount_cancelled,
      PLLD.amount_rejected,
      PLLD.amount_accepted,
      PLLD.drop_ship_flag,
      PLLD.sales_order_update_date,
      PLLD.transaction_flow_header_id,
      PLLD.final_match_flag,
      PLLD.manual_price_change_flag,
      PLLD.shipment_closed_date,
      PLLD.closed_for_receiving_date,
      PLLD.closed_for_invoice_date,
      PLLD.draft_id,
      PLLD.delete_flag,
      PLLD.change_accepted_flag,
      -- <Complex Work R12 Start>
      PLLD.value_basis,
      PLLD.matching_basis,
      PLLD.payment_type,
      PLLD.description,
      PLLD.work_approver_id,
      PLLD.bid_payment_id,
      PLLD.quantity_financed,
      PLLD.amount_financed,
      PLLD.quantity_recouped,
      PLLD.amount_recouped,
      PLLD.retainage_withheld_amount,
      PLLD.retainage_released_amount,
      -- <Complex Work R12 End>
      PLLD.outsourced_assembly,
      PLLD.tax_attribute_update_code  -- <ETAX R12>
    FROM po_line_locations_draft_all PLLD
    WHERE PLLD.draft_id = p_draft_id
    AND NVL(PLLD.change_accepted_flag, 'Y') = 'Y'
    ) PLLDV
  ON (PLL.line_location_id = PLLDV.line_location_id)
  WHEN MATCHED THEN
    UPDATE
    SET
      PLL.last_update_date = PLLDV.last_update_date,
      PLL.last_updated_by = PLLDV.last_updated_by,
      PLL.po_header_id = PLLDV.po_header_id,
      PLL.po_line_id = PLLDV.po_line_id,
      PLL.last_update_login = PLLDV.last_update_login,
      PLL.quantity = PLLDV.quantity,
      PLL.unit_meas_lookup_code = PLLDV.unit_meas_lookup_code,
      PLL.po_release_id = PLLDV.po_release_id,
      PLL.ship_to_location_id = PLLDV.ship_to_location_id,
      PLL.ship_via_lookup_code = PLLDV.ship_via_lookup_code,
      PLL.need_by_date = PLLDV.need_by_date,
      PLL.promised_date = PLLDV.promised_date,
      PLL.last_accept_date = PLLDV.last_accept_date,
      PLL.price_override = PLLDV.price_override,
      PLL.encumbered_flag = PLLDV.encumbered_flag,
      PLL.encumbered_date = PLLDV.encumbered_date,
      PLL.unencumbered_quantity = PLLDV.unencumbered_quantity,
      PLL.fob_lookup_code = PLLDV.fob_lookup_code,
      PLL.freight_terms_lookup_code = PLLDV.freight_terms_lookup_code,
      PLL.taxable_flag = PLLDV.taxable_flag,
      PLL.from_header_id = PLLDV.from_header_id,
      PLL.from_line_id = PLLDV.from_line_id,
      PLL.from_line_location_id = PLLDV.from_line_location_id,
      PLL.start_date = PLLDV.start_date,
      PLL.end_date = PLLDV.end_date,
      PLL.lead_time = PLLDV.lead_time,
      PLL.lead_time_unit = PLLDV.lead_time_unit,
      PLL.price_discount = PLLDV.price_discount,
      PLL.terms_id = NULL, /* 9383947 FIX PLLDV.terms_id,*/
      PLL.approved_flag = PLLDV.approved_flag,
      PLL.approved_date = PLLDV.approved_date,
      PLL.closed_flag = PLLDV.closed_flag,
      PLL.cancel_flag = PLLDV.cancel_flag,
      PLL.cancelled_by = PLLDV.cancelled_by,
      PLL.cancel_date = PLLDV.cancel_date,
      PLL.cancel_reason = PLLDV.cancel_reason,
      PLL.firm_status_lookup_code = PLLDV.firm_status_lookup_code,
      PLL.attribute_category = PLLDV.attribute_category,
      PLL.attribute1 = PLLDV.attribute1,
      PLL.attribute2 = PLLDV.attribute2,
      PLL.attribute3 = PLLDV.attribute3,
      PLL.attribute4 = PLLDV.attribute4,
      PLL.attribute5 = PLLDV.attribute5,
      PLL.attribute6 = PLLDV.attribute6,
      PLL.attribute7 = PLLDV.attribute7,
      PLL.attribute8 = PLLDV.attribute8,
      PLL.attribute9 = PLLDV.attribute9,
      PLL.attribute10 = PLLDV.attribute10,
      PLL.attribute11 = PLLDV.attribute11,
      PLL.attribute12 = PLLDV.attribute12,
      PLL.attribute13 = PLLDV.attribute13,
      PLL.attribute14 = PLLDV.attribute14,
      PLL.attribute15 = PLLDV.attribute15,
      PLL.inspection_required_flag = PLLDV.inspection_required_flag,
      PLL.receipt_required_flag = PLLDV.receipt_required_flag,
      PLL.qty_rcv_tolerance = PLLDV.qty_rcv_tolerance,
      PLL.qty_rcv_exception_code = PLLDV.qty_rcv_exception_code,
      PLL.enforce_ship_to_location_code = PLLDV.enforce_ship_to_location_code,
      PLL.allow_substitute_receipts_flag = PLLDV.allow_substitute_receipts_flag,
      PLL.days_early_receipt_allowed = PLLDV.days_early_receipt_allowed,
      PLL.days_late_receipt_allowed = PLLDV.days_late_receipt_allowed,
      PLL.receipt_days_exception_code = PLLDV.receipt_days_exception_code,
      PLL.invoice_close_tolerance = PLLDV.invoice_close_tolerance,
      PLL.receive_close_tolerance = PLLDV.receive_close_tolerance,
      PLL.ship_to_organization_id = PLLDV.ship_to_organization_id,
      PLL.shipment_num = PLLDV.shipment_num,
      PLL.source_shipment_id = PLLDV.source_shipment_id,
      PLL.shipment_type = PLLDV.shipment_type,
      PLL.closed_code = PLLDV.closed_code,
      PLL.ussgl_transaction_code = PLLDV.ussgl_transaction_code,
      PLL.government_context = PLLDV.government_context,
      PLL.receiving_routing_id = PLLDV.receiving_routing_id,
      PLL.accrue_on_receipt_flag = PLLDV.accrue_on_receipt_flag,
      PLL.closed_reason = PLLDV.closed_reason,
      PLL.closed_date = PLLDV.closed_date,
      PLL.closed_by = PLLDV.closed_by,
      PLL.org_id = PLLDV.org_id,
      PLL.global_attribute_category = PLLDV.global_attribute_category,
      PLL.global_attribute1 = PLLDV.global_attribute1,
      PLL.global_attribute2 = PLLDV.global_attribute2,
      PLL.global_attribute3 = PLLDV.global_attribute3,
      PLL.global_attribute4 = PLLDV.global_attribute4,
      PLL.global_attribute5 = PLLDV.global_attribute5,
      PLL.global_attribute6 = PLLDV.global_attribute6,
      PLL.global_attribute7 = PLLDV.global_attribute7,
      PLL.global_attribute8 = PLLDV.global_attribute8,
      PLL.global_attribute9 = PLLDV.global_attribute9,
      PLL.global_attribute10 = PLLDV.global_attribute10,
      PLL.global_attribute11 = PLLDV.global_attribute11,
      PLL.global_attribute12 = PLLDV.global_attribute12,
      PLL.global_attribute13 = PLLDV.global_attribute13,
      PLL.global_attribute14 = PLLDV.global_attribute14,
      PLL.global_attribute15 = PLLDV.global_attribute15,
      PLL.global_attribute16 = PLLDV.global_attribute16,
      PLL.global_attribute17 = PLLDV.global_attribute17,
      PLL.global_attribute18 = PLLDV.global_attribute18,
      PLL.global_attribute19 = PLLDV.global_attribute19,
      PLL.global_attribute20 = PLLDV.global_attribute20,
      PLL.country_of_origin_code = PLLDV.country_of_origin_code,
      PLL.tax_user_override_flag = PLLDV.tax_user_override_flag,
      PLL.match_option = PLLDV.match_option,
      PLL.tax_code_id = PLLDV.tax_code_id,
      PLL.calculate_tax_flag = PLLDV.calculate_tax_flag,
      PLL.note_to_receiver = PLLDV.note_to_receiver,
      PLL.secondary_quantity = PLLDV.secondary_quantity,
      PLL.secondary_unit_of_measure = PLLDV.secondary_unit_of_measure,
      PLL.preferred_grade = PLLDV.preferred_grade,
      PLL.vmi_flag = PLLDV.vmi_flag,
      PLL.consigned_flag = PLLDV.consigned_flag,
      PLL.retroactive_date = PLLDV.retroactive_date,
      PLL.supplier_order_line_number = PLLDV.supplier_order_line_number,
      PLL.amount = PLLDV.amount,
      PLL.transaction_flow_header_id = PLLDV.transaction_flow_header_id,
      PLL.manual_price_change_flag = PLLDV.manual_price_change_flag,
      -- <Complex Work R12 Start>
      PLL.value_basis = PLLDV.value_basis,
      PLL.matching_basis = PLLDV.matching_basis,
      PLL.payment_type = PLLDV.payment_type,
      PLL.description = PLLDV.description,
      PLL.work_approver_id = PLLDV.work_approver_id,
      -- <Complex Work R12 End>
      PLL.outsourced_assembly = PLLDV.outsourced_assembly,
      PLL.tax_attribute_update_code = PLLDV.tax_attribute_update_code -- <ETAX R12>
  --  DELETE WHERE PLLDV.delete_flag = 'Y'
  WHEN NOT MATCHED THEN
    INSERT
    (
      PLL.line_location_id,
      PLL.last_update_date,
      PLL.last_updated_by,
      PLL.po_header_id,
      PLL.po_line_id,
      PLL.last_update_login,
      PLL.creation_date,
      PLL.created_by,
      PLL.quantity,
      PLL.quantity_accepted,
      PLL.quantity_received,
      PLL.quantity_rejected,
      PLL.quantity_billed,
      PLL.quantity_cancelled,
      PLL.unit_meas_lookup_code,
      PLL.po_release_id,
      PLL.ship_to_location_id,
      PLL.ship_via_lookup_code,
      PLL.need_by_date,
      PLL.promised_date,
      PLL.last_accept_date,
      PLL.price_override,
      PLL.encumbered_flag,
      PLL.encumbered_date,
      PLL.unencumbered_quantity,
      PLL.fob_lookup_code,
      PLL.freight_terms_lookup_code,
      PLL.taxable_flag,
      PLL.tax_name,
      PLL.estimated_tax_amount,
      PLL.from_header_id,
      PLL.from_line_id,
      PLL.from_line_location_id,
      PLL.start_date,
      PLL.end_date,
      PLL.lead_time,
      PLL.lead_time_unit,
      PLL.price_discount,
      PLL.terms_id,
      PLL.approved_flag,
      PLL.approved_date,
      PLL.closed_flag,
      PLL.cancel_flag,
      PLL.cancelled_by,
      PLL.cancel_date,
      PLL.cancel_reason,
      PLL.firm_status_lookup_code,
      PLL.firm_date,
      PLL.attribute_category,
      PLL.attribute1,
      PLL.attribute2,
      PLL.attribute3,
      PLL.attribute4,
      PLL.attribute5,
      PLL.attribute6,
      PLL.attribute7,
      PLL.attribute8,
      PLL.attribute9,
      PLL.attribute10,
      PLL.unit_of_measure_class,
      PLL.encumber_now,
      PLL.attribute11,
      PLL.attribute12,
      PLL.attribute13,
      PLL.attribute14,
      PLL.attribute15,
      PLL.inspection_required_flag,
      PLL.receipt_required_flag,
      PLL.qty_rcv_tolerance,
      PLL.qty_rcv_exception_code,
      PLL.enforce_ship_to_location_code,
      PLL.allow_substitute_receipts_flag,
      PLL.days_early_receipt_allowed,
      PLL.days_late_receipt_allowed,
      PLL.receipt_days_exception_code,
      PLL.invoice_close_tolerance,
      PLL.receive_close_tolerance,
      PLL.ship_to_organization_id,
      PLL.shipment_num,
      PLL.source_shipment_id,
      PLL.shipment_type,
      PLL.closed_code,
      PLL.request_id,
      PLL.program_application_id,
      PLL.program_id,
      PLL.program_update_date,
      PLL.ussgl_transaction_code,
      PLL.government_context,
      PLL.receiving_routing_id,
      PLL.accrue_on_receipt_flag,
      PLL.closed_reason,
      PLL.closed_date,
      PLL.closed_by,
      PLL.org_id,
      PLL.quantity_shipped,
      PLL.global_attribute_category,
      PLL.global_attribute1,
      PLL.global_attribute2,
      PLL.global_attribute3,
      PLL.global_attribute4,
      PLL.global_attribute5,
      PLL.global_attribute6,
      PLL.global_attribute7,
      PLL.global_attribute8,
      PLL.global_attribute9,
      PLL.global_attribute10,
      PLL.global_attribute11,
      PLL.global_attribute12,
      PLL.global_attribute13,
      PLL.global_attribute14,
      PLL.global_attribute15,
      PLL.global_attribute16,
      PLL.global_attribute17,
      PLL.global_attribute18,
      PLL.global_attribute19,
      PLL.global_attribute20,
      PLL.country_of_origin_code,
      PLL.tax_user_override_flag,
      PLL.match_option,
      PLL.tax_code_id,
      PLL.calculate_tax_flag,
      PLL.change_promised_date_reason,
      PLL.note_to_receiver,
      PLL.secondary_quantity,
      PLL.secondary_unit_of_measure,
      PLL.preferred_grade,
      PLL.secondary_quantity_received,
      PLL.secondary_quantity_accepted,
      PLL.secondary_quantity_rejected,
      PLL.secondary_quantity_cancelled,
      PLL.secondary_quantity_shipped,
      PLL.vmi_flag,
      PLL.consigned_flag,
      PLL.retroactive_date,
      PLL.supplier_order_line_number,
      PLL.amount,
      PLL.amount_received,
      PLL.amount_billed,
      PLL.amount_cancelled,
      PLL.amount_rejected,
      PLL.amount_accepted,
      PLL.drop_ship_flag,
      PLL.sales_order_update_date,
      PLL.transaction_flow_header_id,
      PLL.final_match_flag,
      PLL.manual_price_change_flag,
      PLL.shipment_closed_date,
      PLL.closed_for_receiving_date,
      PLL.closed_for_invoice_date,
      -- <Complex Work R12 Start>
      PLL.value_basis,
      PLL.matching_basis,
      PLL.payment_type,
      PLL.description,
      PLL.work_approver_id,
      PLL.bid_payment_id,
      PLL.quantity_financed,
      PLL.amount_financed,
      PLL.quantity_recouped,
      PLL.amount_recouped,
      PLL.retainage_withheld_amount,
      PLL.retainage_released_amount,
      -- <Complex Work R12 End>
      PLL.outsourced_assembly,
      PLL.tax_attribute_update_code -- <ETAX R12>
    )
    VALUES
    (
      PLLDV.line_location_id,
      PLLDV.last_update_date,
      PLLDV.last_updated_by,
      PLLDV.po_header_id,
      PLLDV.po_line_id,
      PLLDV.last_update_login,
      PLLDV.creation_date,
      PLLDV.created_by,
      PLLDV.quantity,
      PLLDV.quantity_accepted,
      PLLDV.quantity_received,
      PLLDV.quantity_rejected,
      PLLDV.quantity_billed,
      PLLDV.quantity_cancelled,
      PLLDV.unit_meas_lookup_code,
      PLLDV.po_release_id,
      PLLDV.ship_to_location_id,
      PLLDV.ship_via_lookup_code,
      PLLDV.need_by_date,
      PLLDV.promised_date,
      PLLDV.last_accept_date,
      PLLDV.price_override,
      PLLDV.encumbered_flag,
      PLLDV.encumbered_date,
      PLLDV.unencumbered_quantity,
      PLLDV.fob_lookup_code,
      PLLDV.freight_terms_lookup_code,
      PLLDV.taxable_flag,
      PLLDV.tax_name,
      PLLDV.estimated_tax_amount,
      PLLDV.from_header_id,
      PLLDV.from_line_id,
      PLLDV.from_line_location_id,
      PLLDV.start_date,
      PLLDV.end_date,
      PLLDV.lead_time,
      PLLDV.lead_time_unit,
      PLLDV.price_discount,
      NULL, /* PLLDV.terms_id, PART OF 9383947 FIX*/
      PLLDV.approved_flag,
      PLLDV.approved_date,
      PLLDV.closed_flag,
      PLLDV.cancel_flag,
      PLLDV.cancelled_by,
      PLLDV.cancel_date,
      PLLDV.cancel_reason,
      PLLDV.firm_status_lookup_code,
      PLLDV.firm_date,
      PLLDV.attribute_category,
      PLLDV.attribute1,
      PLLDV.attribute2,
      PLLDV.attribute3,
      PLLDV.attribute4,
      PLLDV.attribute5,
      PLLDV.attribute6,
      PLLDV.attribute7,
      PLLDV.attribute8,
      PLLDV.attribute9,
      PLLDV.attribute10,
      PLLDV.unit_of_measure_class,
      PLLDV.encumber_now,
      PLLDV.attribute11,
      PLLDV.attribute12,
      PLLDV.attribute13,
      PLLDV.attribute14,
      PLLDV.attribute15,
      PLLDV.inspection_required_flag,
      PLLDV.receipt_required_flag,
      PLLDV.qty_rcv_tolerance,
      PLLDV.qty_rcv_exception_code,
      PLLDV.enforce_ship_to_location_code,
      PLLDV.allow_substitute_receipts_flag,
      PLLDV.days_early_receipt_allowed,
      PLLDV.days_late_receipt_allowed,
      PLLDV.receipt_days_exception_code,
      PLLDV.invoice_close_tolerance,
      PLLDV.receive_close_tolerance,
      PLLDV.ship_to_organization_id,
      PLLDV.shipment_num,
      PLLDV.source_shipment_id,
      PLLDV.shipment_type,
      PLLDV.closed_code,
      PLLDV.request_id,
      PLLDV.program_application_id,
      PLLDV.program_id,
      PLLDV.program_update_date,
      PLLDV.ussgl_transaction_code,
      PLLDV.government_context,
      PLLDV.receiving_routing_id,
      PLLDV.accrue_on_receipt_flag,
      PLLDV.closed_reason,
      PLLDV.closed_date,
      PLLDV.closed_by,
      PLLDV.org_id,
      PLLDV.quantity_shipped,
      PLLDV.global_attribute_category,
      PLLDV.global_attribute1,
      PLLDV.global_attribute2,
      PLLDV.global_attribute3,
      PLLDV.global_attribute4,
      PLLDV.global_attribute5,
      PLLDV.global_attribute6,
      PLLDV.global_attribute7,
      PLLDV.global_attribute8,
      PLLDV.global_attribute9,
      PLLDV.global_attribute10,
      PLLDV.global_attribute11,
      PLLDV.global_attribute12,
      PLLDV.global_attribute13,
      PLLDV.global_attribute14,
      PLLDV.global_attribute15,
      PLLDV.global_attribute16,
      PLLDV.global_attribute17,
      PLLDV.global_attribute18,
      PLLDV.global_attribute19,
      PLLDV.global_attribute20,
      PLLDV.country_of_origin_code,
      PLLDV.tax_user_override_flag,
      PLLDV.match_option,
      PLLDV.tax_code_id,
      PLLDV.calculate_tax_flag,
      PLLDV.change_promised_date_reason,
      PLLDV.note_to_receiver,
      PLLDV.secondary_quantity,
      PLLDV.secondary_unit_of_measure,
      PLLDV.preferred_grade,
      PLLDV.secondary_quantity_received,
      PLLDV.secondary_quantity_accepted,
      PLLDV.secondary_quantity_rejected,
      PLLDV.secondary_quantity_cancelled,
      PLLDV.secondary_quantity_shipped,
      PLLDV.vmi_flag,
      PLLDV.consigned_flag,
      PLLDV.retroactive_date,
      PLLDV.supplier_order_line_number,
      PLLDV.amount,
      PLLDV.amount_received,
      PLLDV.amount_billed,
      PLLDV.amount_cancelled,
      PLLDV.amount_rejected,
      PLLDV.amount_accepted,
      PLLDV.drop_ship_flag,
      PLLDV.sales_order_update_date,
      PLLDV.transaction_flow_header_id,
      PLLDV.final_match_flag,
      PLLDV.manual_price_change_flag,
      PLLDV.shipment_closed_date,
      PLLDV.closed_for_receiving_date,
      PLLDV.closed_for_invoice_date,
      -- <Complex Work R12 Start>
      PLLDV.value_basis,
      PLLDV.matching_basis,
      PLLDV.payment_type,
      PLLDV.description,
      PLLDV.work_approver_id,
      PLLDV.bid_payment_id,
      PLLDV.quantity_financed,
      PLLDV.amount_financed,
      PLLDV.quantity_recouped,
      PLLDV.amount_recouped,
      PLLDV.retainage_withheld_amount,
      PLLDV.retainage_released_amount,
      -- <Complex Work R12 End>
      PLLDV.outsourced_assembly,
      PLLDV.tax_attribute_update_code -- <ETAX R12>
    ) WHERE NVL(PLLDV.delete_flag, 'N') <> 'Y';

  d_position := 10;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END merge_changes;

-----------------------------------------------------------------------
--Start of Comments
--Name: lock_draft_record
--Function:
--  Obtain database lock for the record in draft table
--Parameters:
--IN:
--p_line_location_id
--  id for po line location record
--p_draft_id
--  draft unique identifier
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_draft_record
( p_line_location_id IN NUMBER,
  p_draft_id        IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'lock_draft_record';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_dummy NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT 1
  INTO l_dummy
  FROM po_line_locations_draft_all
  WHERE line_location_id = p_line_location_id
  AND draft_id = p_draft_id
  FOR UPDATE NOWAIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END lock_draft_record;

-----------------------------------------------------------------------
--Start of Comments
--Name: lock_transaction_record
--Function:
--  Obtain database lock for the record in transaction table
--Parameters:
--IN:
--p_line_location_id
--  id for po line location record
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_transaction_record
( p_line_location_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'lock_transaction_record';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_dummy NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT 1
  INTO l_dummy
  FROM po_line_locations_all
  WHERE line_location_id = p_line_location_id
  FOR UPDATE NOWAIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END lock_transaction_record;

END PO_LINE_LOCATIONS_DRAFT_PKG;

/
