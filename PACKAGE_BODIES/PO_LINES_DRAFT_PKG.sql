--------------------------------------------------------
--  DDL for Package Body PO_LINES_DRAFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_DRAFT_PKG" AS
/* $Header: PO_LINES_DRAFT_PKG.plb 120.8 2006/09/28 23:04:15 bao noship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_LINES_DRAFT_PKG');

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_rows
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Deletes drafts for lines based on the information given
--  If only draft_id is provided, then all lines for the draft will be
--  deleted
--  If po_line_id is also provided, then the one record that has such
--  primary key will be deleted
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_po_line_id
--  po line unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE delete_rows
( p_draft_id IN NUMBER,
  p_po_line_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'delete_rows';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  DELETE FROM po_lines_draft_all
  WHERE draft_id = p_draft_id
  AND po_line_id = NVL(p_po_line_id, po_line_id);

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
--p_po_line_id_tbl
--  table of po header unique identifier
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
( p_po_line_id_tbl         IN PO_TBL_NUMBER,
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
    PO_LINES_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_po_line_id_tbl => p_po_line_id_tbl
    );

  -- bug5471513 START
  -- If there're duplicate entries in the id table,
  -- we do not want to insert multiple entries
  -- Created an associative array to store what id has appeared.
  l_duplicate_flag_tbl.EXTEND(p_po_line_id_tbl.COUNT);

  FOR i IN 1..p_po_line_id_tbl.COUNT LOOP
    IF (x_record_already_exist_tbl(i) = FND_API.G_FALSE) THEN

      IF (l_distinct_id_list.EXISTS(p_po_line_id_tbl(i))) THEN

        l_duplicate_flag_tbl(i) := FND_API.G_TRUE;
      ELSE
        l_duplicate_flag_tbl(i) := FND_API.G_FALSE;

        l_distinct_id_list(p_po_line_id_tbl(i)) := 1;
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

  FORALL i IN 1..p_po_line_id_tbl.COUNT
    INSERT INTO po_lines_draft_all
    (
      draft_id,
      delete_flag,
      change_accepted_flag,
      po_line_id,
      last_update_date,
      last_updated_by,
      po_header_id,
      line_type_id,
      line_num,
      last_update_login,
      creation_date,
      created_by,
      item_id,
      item_revision,
      category_id,
      item_description,
      unit_meas_lookup_code,
      quantity_committed,
      committed_amount,
      allow_price_override_flag,
      not_to_exceed_price,
      list_price_per_unit,
      unit_price,
      quantity,
      un_number_id,
      hazard_class_id,
      note_to_vendor,
      from_header_id,
      from_line_id,
      from_line_location_id,
      min_order_quantity,
      max_order_quantity,
      qty_rcv_tolerance,
      over_tolerance_error_flag,
      market_price,
      unordered_flag,
      closed_flag,
      user_hold_flag,
      cancel_flag,
      cancelled_by,
      cancel_date,
      cancel_reason,
      firm_status_lookup_code,
      firm_date,
      vendor_product_num,
      contract_num,
      taxable_flag,
      tax_name,
      type_1099,
      capital_expense_flag,
      negotiated_by_preparer_flag,
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
      reference_num,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      min_release_amount,
      price_type_lookup_code,
      closed_code,
      price_break_lookup_code,
      ussgl_transaction_code,
      government_context,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      closed_date,
      closed_reason,
      closed_by,
      transaction_reason_code,
      org_id,
      qc_grade,
      base_uom,
      base_qty,
      secondary_uom,
      secondary_qty,
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
      line_reference_num,
      project_id,
      task_id,
      expiration_date,
      tax_code_id,
      oke_contract_header_id,
      oke_contract_version_id,
      secondary_quantity,
      secondary_unit_of_measure,
      preferred_grade,
      auction_header_id,
      auction_display_number,
      auction_line_number,
      bid_number,
      bid_line_number,
      retroactive_date,
      supplier_ref_number,
      contract_id,
      start_date,
      amount,
      job_id,
      contractor_first_name,
      contractor_last_name,
      order_type_lookup_code,
      purchase_basis,
      matching_basis,
      svc_amount_notif_sent,
      svc_completion_notif_sent,
      base_unit_price,
      manual_price_change_flag,
      -- <Complex Work R12 Start>
      retainage_rate,
      max_retainage_amount,
      progress_payment_rate,
      recoupment_rate,
      -- <Complex Work R12 End>
      catalog_name,
      supplier_part_auxid,
      ip_category_id,
      tax_attribute_update_code  -- <ETAX R12>
    )
    SELECT
      p_draft_id_tbl(i),
      p_delete_flag_tbl(i),
      NULL,
      po_line_id,
      last_update_date,
      last_updated_by,
      po_header_id,
      line_type_id,
      line_num,
      last_update_login,
      creation_date,
      created_by,
      item_id,
      item_revision,
      category_id,
      item_description,
      unit_meas_lookup_code,
      quantity_committed,
      committed_amount,
      allow_price_override_flag,
      not_to_exceed_price,
      list_price_per_unit,
      unit_price,
      quantity,
      un_number_id,
      hazard_class_id,
      note_to_vendor,
      from_header_id,
      from_line_id,
      from_line_location_id,
      min_order_quantity,
      max_order_quantity,
      qty_rcv_tolerance,
      over_tolerance_error_flag,
      market_price,
      unordered_flag,
      closed_flag,
      user_hold_flag,
      cancel_flag,
      cancelled_by,
      cancel_date,
      cancel_reason,
      firm_status_lookup_code,
      firm_date,
      vendor_product_num,
      contract_num,
      taxable_flag,
      tax_name,
      type_1099,
      capital_expense_flag,
      negotiated_by_preparer_flag,
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
      reference_num,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      min_release_amount,
      price_type_lookup_code,
      closed_code,
      price_break_lookup_code,
      ussgl_transaction_code,
      government_context,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      closed_date,
      closed_reason,
      closed_by,
      transaction_reason_code,
      org_id,
      qc_grade,
      base_uom,
      base_qty,
      secondary_uom,
      secondary_qty,
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
      line_reference_num,
      project_id,
      task_id,
      expiration_date,
      tax_code_id,
      oke_contract_header_id,
      oke_contract_version_id,
      secondary_quantity,
      secondary_unit_of_measure,
      preferred_grade,
      auction_header_id,
      auction_display_number,
      auction_line_number,
      bid_number,
      bid_line_number,
      retroactive_date,
      supplier_ref_number,
      contract_id,
      start_date,
      amount,
      job_id,
      contractor_first_name,
      contractor_last_name,
      order_type_lookup_code,
      purchase_basis,
      matching_basis,
      svc_amount_notif_sent,
      svc_completion_notif_sent,
      base_unit_price,
      manual_price_change_flag,
      -- <Complex Work R12 Start>
      retainage_rate,
      max_retainage_amount,
      progress_payment_rate,
      recoupment_rate,
      -- <Complex Work R12 End>
      catalog_name,
      supplier_part_auxid,
      ip_category_id,
      tax_attribute_update_code  -- <ETAX R12>
    FROM po_lines_all
    WHERE po_line_id = p_po_line_id_tbl(i)
    AND x_record_already_exist_tbl(i) = FND_API.G_FALSE
    AND l_duplicate_flag_tbl(i) = FND_API.G_FALSE;

  d_position := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer count = ' || SQL%ROWCOUNT);
  END IF;

  FORALL i IN 1..p_po_line_id_tbl.COUNT
    UPDATE po_lines_draft_all
    SET    delete_flag = p_delete_flag_tbl(i)
    WHERE  po_line_id = p_po_line_id_tbl(i)
    AND    draft_id = p_draft_id_tbl(i)
    AND    NVL(delete_flag, 'N') <> 'Y' -- bug5570989
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
--p_po_line_id
--  po line unique identifier
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
( p_po_line_id IN NUMBER,
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
    PO_LOG.proc_begin(d_module, 'p_po_line_id', p_po_line_id);
  END IF;

  sync_draft_from_txn
  ( p_po_line_id_tbl           => PO_TBL_NUMBER(p_po_line_id),
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
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- Since putting DELETE within MERGE statement is causing database
  -- to thrown internal error, for now we just separate the DELETE statement.
  -- Once this is fixed we'll move the delete statement back to the merge
  -- statement

  -- bug5187544
  -- Delete only records that have not been rejected

  DELETE FROM po_lines_all PL
  WHERE PL.po_line_id IN
         ( SELECT PLD.po_line_id
           FROM   po_lines_draft_all PLD
           WHERE  PLD.draft_id = p_draft_id
           AND    PLD.delete_flag = 'Y'
           AND    NVL(PLD.change_accepted_flag, 'Y') = 'Y' );

  d_position := 10;

  -- Merge PO Line changes
  -- For update case, the following columns will be skipped:
  --PL.po_line_id
  --PL.creation_date
  --PL.created_by
  --PL.tax_name
  --PL.request_id
  --PL.program_application_id
  --PL.program_id
  --PL.program_update_date
  --PL.base_uom
  --PL.base_qty
  --PL.project_id
  --PL.task_id
  --PL.auction_header_id
  --PL.auction_display_number
  --PL.auction_line_number
  --PL.bid_number
  --PL.bid_line_number
  --PL.svc_amount_notif_sent
  --PL.svc_completion_notif_sent
  MERGE INTO po_lines_all PL
  USING (
    SELECT
      PLD.draft_id,
      PLD.delete_flag,
      PLD.change_accepted_flag,
      PLD.po_line_id,
      PLD.last_update_date,
      PLD.last_updated_by,
      PLD.po_header_id,
      PLD.line_type_id,
      PLD.line_num,
      PLD.last_update_login,
      PLD.creation_date,
      PLD.created_by,
      PLD.item_id,
      PLD.item_revision,
      PLD.category_id,
      PLD.item_description,
      PLD.unit_meas_lookup_code,
      PLD.quantity_committed,
      PLD.committed_amount,
      PLD.allow_price_override_flag,
      PLD.not_to_exceed_price,
      PLD.list_price_per_unit,
      PLD.unit_price,
      PLD.quantity,
      PLD.un_number_id,
      PLD.hazard_class_id,
      PLD.note_to_vendor,
      PLD.from_header_id,
      PLD.from_line_id,
      PLD.from_line_location_id,
      PLD.min_order_quantity,
      PLD.max_order_quantity,
      PLD.qty_rcv_tolerance,
      PLD.over_tolerance_error_flag,
      PLD.market_price,
      PLD.unordered_flag,
      PLD.closed_flag,
      PLD.user_hold_flag,
      PLD.cancel_flag,
      PLD.cancelled_by,
      PLD.cancel_date,
      PLD.cancel_reason,
      PLD.firm_status_lookup_code,
      PLD.firm_date,
      PLD.vendor_product_num,
      PLD.contract_num,
      PLD.taxable_flag,
      PLD.tax_name,
      PLD.type_1099,
      PLD.capital_expense_flag,
      PLD.negotiated_by_preparer_flag,
      PLD.attribute_category,
      PLD.attribute1,
      PLD.attribute2,
      PLD.attribute3,
      PLD.attribute4,
      PLD.attribute5,
      PLD.attribute6,
      PLD.attribute7,
      PLD.attribute8,
      PLD.attribute9,
      PLD.attribute10,
      PLD.reference_num,
      PLD.attribute11,
      PLD.attribute12,
      PLD.attribute13,
      PLD.attribute14,
      PLD.attribute15,
      PLD.min_release_amount,
      PLD.price_type_lookup_code,
      PLD.closed_code,
      PLD.price_break_lookup_code,
      PLD.ussgl_transaction_code,
      PLD.government_context,
      PLD.request_id,
      PLD.program_application_id,
      PLD.program_id,
      PLD.program_update_date,
      PLD.closed_date,
      PLD.closed_reason,
      PLD.closed_by,
      PLD.transaction_reason_code,
      PLD.org_id,
      PLD.qc_grade,
      PLD.base_uom,
      PLD.base_qty,
      PLD.secondary_uom,
      PLD.secondary_qty,
      PLD.global_attribute_category,
      PLD.global_attribute1,
      PLD.global_attribute2,
      PLD.global_attribute3,
      PLD.global_attribute4,
      PLD.global_attribute5,
      PLD.global_attribute6,
      PLD.global_attribute7,
      PLD.global_attribute8,
      PLD.global_attribute9,
      PLD.global_attribute10,
      PLD.global_attribute11,
      PLD.global_attribute12,
      PLD.global_attribute13,
      PLD.global_attribute14,
      PLD.global_attribute15,
      PLD.global_attribute16,
      PLD.global_attribute17,
      PLD.global_attribute18,
      PLD.global_attribute19,
      PLD.global_attribute20,
      PLD.line_reference_num,
      PLD.project_id,
      PLD.task_id,
      PLD.expiration_date,
      PLD.tax_code_id,
      PLD.oke_contract_header_id,
      PLD.oke_contract_version_id,
      PLD.secondary_quantity,
      PLD.secondary_unit_of_measure,
      PLD.preferred_grade,
      PLD.auction_header_id,
      PLD.auction_display_number,
      PLD.auction_line_number,
      PLD.bid_number,
      PLD.bid_line_number,
      PLD.retroactive_date,
      PLD.supplier_ref_number,
      PLD.contract_id,
      PLD.start_date,
      PLD.amount,
      PLD.job_id,
      PLD.contractor_first_name,
      PLD.contractor_last_name,
      PLD.order_type_lookup_code,
      PLD.purchase_basis,
      PLD.matching_basis,
      PLD.svc_amount_notif_sent,
      PLD.svc_completion_notif_sent,
      PLD.base_unit_price,
      PLD.manual_price_change_flag,
      -- <Complex Work R12 Start>
      PLD.retainage_rate,
      PLD.max_retainage_amount,
      PLD.progress_payment_rate,
      PLD.recoupment_rate,
      -- <Complex Work R12 End>
      PLD.catalog_name,
      PLD.supplier_part_auxid,
      PLD.ip_category_id,
      PLD.tax_attribute_update_code  -- <ETAX R12>
    FROM po_lines_draft_all PLD
    WHERE PLD.draft_id = p_draft_id
    AND NVL(PLD.change_accepted_flag, 'Y') = 'Y'
    ) PLDV
  ON (PL.po_line_id = PLDV.po_line_id)
  WHEN MATCHED THEN
    UPDATE
    SET
      PL.last_update_date = PLDV.last_update_date,
      PL.last_updated_by = PLDV.last_updated_by,
      PL.po_header_id = PLDV.po_header_id,
      PL.line_type_id = PLDV.line_type_id,
      PL.line_num = PLDV.line_num,
      PL.last_update_login = PLDV.last_update_login,
      PL.item_id = PLDV.item_id,
      PL.item_revision = PLDV.item_revision,
      PL.category_id = PLDV.category_id,
      PL.item_description = PLDV.item_description,
      PL.unit_meas_lookup_code = PLDV.unit_meas_lookup_code,
      PL.quantity_committed = PLDV.quantity_committed,
      PL.committed_amount = PLDV.committed_amount,
      PL.allow_price_override_flag = PLDV.allow_price_override_flag,
      PL.not_to_exceed_price = PLDV.not_to_exceed_price,
      PL.list_price_per_unit = PLDV.list_price_per_unit,
      PL.unit_price = PLDV.unit_price,
      PL.quantity = PLDV.quantity,
      PL.un_number_id = PLDV.un_number_id,
      PL.hazard_class_id = PLDV.hazard_class_id,
      PL.note_to_vendor = PLDV.note_to_vendor,
      PL.from_header_id = PLDV.from_header_id,
      PL.from_line_id = PLDV.from_line_id,
      PL.from_line_location_id = PLDV.from_line_location_id,
      PL.min_order_quantity = PLDV.min_order_quantity,
      PL.max_order_quantity = PLDV.max_order_quantity,
      PL.qty_rcv_tolerance = PLDV.qty_rcv_tolerance,
      PL.over_tolerance_error_flag = PLDV.over_tolerance_error_flag,
      PL.market_price = PLDV.market_price,
      PL.unordered_flag = PLDV.unordered_flag,
      PL.closed_flag = PLDV.closed_flag,
      PL.user_hold_flag = PLDV.user_hold_flag,
      PL.cancel_flag = PLDV.cancel_flag,
      PL.cancelled_by = PLDV.cancelled_by,
      PL.cancel_date = PLDV.cancel_date,
      PL.cancel_reason = PLDV.cancel_reason,
      PL.firm_status_lookup_code = PLDV.firm_status_lookup_code,
      PL.firm_date = PLDV.firm_date,
      PL.vendor_product_num = PLDV.vendor_product_num,
      PL.contract_num = PLDV.contract_num,
      PL.taxable_flag = PLDV.taxable_flag,
      PL.type_1099 = PLDV.type_1099,
      PL.capital_expense_flag = PLDV.capital_expense_flag,
      PL.negotiated_by_preparer_flag = PLDV.negotiated_by_preparer_flag,
      PL.attribute_category = PLDV.attribute_category,
      PL.attribute1 = PLDV.attribute1,
      PL.attribute2 = PLDV.attribute2,
      PL.attribute3 = PLDV.attribute3,
      PL.attribute4 = PLDV.attribute4,
      PL.attribute5 = PLDV.attribute5,
      PL.attribute6 = PLDV.attribute6,
      PL.attribute7 = PLDV.attribute7,
      PL.attribute8 = PLDV.attribute8,
      PL.attribute9 = PLDV.attribute9,
      PL.attribute10 = PLDV.attribute10,
      PL.reference_num = PLDV.reference_num,
      PL.attribute11 = PLDV.attribute11,
      PL.attribute12 = PLDV.attribute12,
      PL.attribute13 = PLDV.attribute13,
      PL.attribute14 = PLDV.attribute14,
      PL.attribute15 = PLDV.attribute15,
      PL.min_release_amount = PLDV.min_release_amount,
      PL.price_type_lookup_code = PLDV.price_type_lookup_code,
      PL.closed_code = PLDV.closed_code,
      PL.price_break_lookup_code = PLDV.price_break_lookup_code,
      PL.ussgl_transaction_code = PLDV.ussgl_transaction_code,
      PL.government_context = PLDV.government_context,
      PL.closed_date = PLDV.closed_date,
      PL.closed_reason = PLDV.closed_reason,
      PL.closed_by = PLDV.closed_by,
      PL.transaction_reason_code = PLDV.transaction_reason_code,
      PL.org_id = PLDV.org_id,
      PL.qc_grade = PLDV.qc_grade,
      PL.secondary_uom = PLDV.secondary_uom,
      PL.secondary_qty = PLDV.secondary_qty,
      PL.global_attribute_category = PLDV.global_attribute_category,
      PL.global_attribute1 = PLDV.global_attribute1,
      PL.global_attribute2 = PLDV.global_attribute2,
      PL.global_attribute3 = PLDV.global_attribute3,
      PL.global_attribute4 = PLDV.global_attribute4,
      PL.global_attribute5 = PLDV.global_attribute5,
      PL.global_attribute6 = PLDV.global_attribute6,
      PL.global_attribute7 = PLDV.global_attribute7,
      PL.global_attribute8 = PLDV.global_attribute8,
      PL.global_attribute9 = PLDV.global_attribute9,
      PL.global_attribute10 = PLDV.global_attribute10,
      PL.global_attribute11 = PLDV.global_attribute11,
      PL.global_attribute12 = PLDV.global_attribute12,
      PL.global_attribute13 = PLDV.global_attribute13,
      PL.global_attribute14 = PLDV.global_attribute14,
      PL.global_attribute15 = PLDV.global_attribute15,
      PL.global_attribute16 = PLDV.global_attribute16,
      PL.global_attribute17 = PLDV.global_attribute17,
      PL.global_attribute18 = PLDV.global_attribute18,
      PL.global_attribute19 = PLDV.global_attribute19,
      PL.global_attribute20 = PLDV.global_attribute20,
      PL.line_reference_num = PLDV.line_reference_num,
      PL.expiration_date = PLDV.expiration_date,
      PL.tax_code_id = PLDV.tax_code_id,
      PL.oke_contract_header_id = PLDV.oke_contract_header_id,
      PL.oke_contract_version_id = PLDV.oke_contract_version_id,
      PL.secondary_quantity = PLDV.secondary_quantity,
      PL.secondary_unit_of_measure = PLDV.secondary_unit_of_measure,
      PL.preferred_grade = PLDV.preferred_grade,
      PL.retroactive_date = PLDV.retroactive_date,
      PL.supplier_ref_number = PLDV.supplier_ref_number,
      PL.contract_id = PLDV.contract_id,
      PL.start_date = PLDV.start_date,
      PL.amount = PLDV.amount,
      PL.job_id = PLDV.job_id,
      PL.contractor_first_name = PLDV.contractor_first_name,
      PL.contractor_last_name = PLDV.contractor_last_name,
      PL.order_type_lookup_code = PLDV.order_type_lookup_code,
      PL.purchase_basis = PLDV.purchase_basis,
      PL.matching_basis = PLDV.matching_basis,
      PL.base_unit_price = PLDV.base_unit_price,
      PL.manual_price_change_flag = PLDV.manual_price_change_flag,
      -- <Complex Work R12 Start>
      PL.retainage_rate = PLDV.retainage_rate,
      PL.max_retainage_amount = PLDV.max_retainage_amount,
      PL.progress_payment_rate = PLDV.progress_payment_rate,
      PL.recoupment_rate = PLDV.recoupment_rate,
      -- <Complex Work R12 End>
      PL.catalog_name = PLDV.catalog_name,
      PL.supplier_part_auxid = PLDV.supplier_part_auxid,
      PL.ip_category_id = PLDV.ip_category_id,
      PL.tax_attribute_update_code = PLDV.tax_attribute_update_code -- <ETAX R12>
  --  DELETE WHERE PLDV.delete_flag = 'Y'
  WHEN NOT MATCHED THEN
    INSERT
    (
      PL.po_line_id,
      PL.last_update_date,
      PL.last_updated_by,
      PL.po_header_id,
      PL.line_type_id,
      PL.line_num,
      PL.last_update_login,
      PL.creation_date,
      PL.created_by,
      PL.item_id,
      PL.item_revision,
      PL.category_id,
      PL.item_description,
      PL.unit_meas_lookup_code,
      PL.quantity_committed,
      PL.committed_amount,
      PL.allow_price_override_flag,
      PL.not_to_exceed_price,
      PL.list_price_per_unit,
      PL.unit_price,
      PL.quantity,
      PL.un_number_id,
      PL.hazard_class_id,
      PL.note_to_vendor,
      PL.from_header_id,
      PL.from_line_id,
      PL.from_line_location_id,
      PL.min_order_quantity,
      PL.max_order_quantity,
      PL.qty_rcv_tolerance,
      PL.over_tolerance_error_flag,
      PL.market_price,
      PL.unordered_flag,
      PL.closed_flag,
      PL.user_hold_flag,
      PL.cancel_flag,
      PL.cancelled_by,
      PL.cancel_date,
      PL.cancel_reason,
      PL.firm_status_lookup_code,
      PL.firm_date,
      PL.vendor_product_num,
      PL.contract_num,
      PL.taxable_flag,
      PL.tax_name,
      PL.type_1099,
      PL.capital_expense_flag,
      PL.negotiated_by_preparer_flag,
      PL.attribute_category,
      PL.attribute1,
      PL.attribute2,
      PL.attribute3,
      PL.attribute4,
      PL.attribute5,
      PL.attribute6,
      PL.attribute7,
      PL.attribute8,
      PL.attribute9,
      PL.attribute10,
      PL.reference_num,
      PL.attribute11,
      PL.attribute12,
      PL.attribute13,
      PL.attribute14,
      PL.attribute15,
      PL.min_release_amount,
      PL.price_type_lookup_code,
      PL.closed_code,
      PL.price_break_lookup_code,
      PL.ussgl_transaction_code,
      PL.government_context,
      PL.request_id,
      PL.program_application_id,
      PL.program_id,
      PL.program_update_date,
      PL.closed_date,
      PL.closed_reason,
      PL.closed_by,
      PL.transaction_reason_code,
      PL.org_id,
      PL.qc_grade,
      PL.base_uom,
      PL.base_qty,
      PL.secondary_uom,
      PL.secondary_qty,
      PL.global_attribute_category,
      PL.global_attribute1,
      PL.global_attribute2,
      PL.global_attribute3,
      PL.global_attribute4,
      PL.global_attribute5,
      PL.global_attribute6,
      PL.global_attribute7,
      PL.global_attribute8,
      PL.global_attribute9,
      PL.global_attribute10,
      PL.global_attribute11,
      PL.global_attribute12,
      PL.global_attribute13,
      PL.global_attribute14,
      PL.global_attribute15,
      PL.global_attribute16,
      PL.global_attribute17,
      PL.global_attribute18,
      PL.global_attribute19,
      PL.global_attribute20,
      PL.line_reference_num,
      PL.project_id,
      PL.task_id,
      PL.expiration_date,
      PL.tax_code_id,
      PL.oke_contract_header_id,
      PL.oke_contract_version_id,
      PL.secondary_quantity,
      PL.secondary_unit_of_measure,
      PL.preferred_grade,
      PL.auction_header_id,
      PL.auction_display_number,
      PL.auction_line_number,
      PL.bid_number,
      PL.bid_line_number,
      PL.retroactive_date,
      PL.supplier_ref_number,
      PL.contract_id,
      PL.start_date,
      PL.amount,
      PL.job_id,
      PL.contractor_first_name,
      PL.contractor_last_name,
      PL.order_type_lookup_code,
      PL.purchase_basis,
      PL.matching_basis,
      PL.svc_amount_notif_sent,
      PL.svc_completion_notif_sent,
      PL.base_unit_price,
      PL.manual_price_change_flag,
      -- <Complex Work R12 Start>
      PL.retainage_rate,
      PL.max_retainage_amount,
      PL.progress_payment_rate,
      PL.recoupment_rate,
      -- <Complex Work R12 End>
      PL.catalog_name,
      PL.supplier_part_auxid,
      PL.ip_category_id,
      PL.tax_attribute_update_code -- <ETAX R12>
    )
    VALUES
    (
      PLDV.po_line_id,
      PLDV.last_update_date,
      PLDV.last_updated_by,
      PLDV.po_header_id,
      PLDV.line_type_id,
      PLDV.line_num,
      PLDV.last_update_login,
      PLDV.creation_date,
      PLDV.created_by,
      PLDV.item_id,
      PLDV.item_revision,
      PLDV.category_id,
      PLDV.item_description,
      PLDV.unit_meas_lookup_code,
      PLDV.quantity_committed,
      PLDV.committed_amount,
      PLDV.allow_price_override_flag,
      PLDV.not_to_exceed_price,
      PLDV.list_price_per_unit,
      PLDV.unit_price,
      PLDV.quantity,
      PLDV.un_number_id,
      PLDV.hazard_class_id,
      PLDV.note_to_vendor,
      PLDV.from_header_id,
      PLDV.from_line_id,
      PLDV.from_line_location_id,
      PLDV.min_order_quantity,
      PLDV.max_order_quantity,
      PLDV.qty_rcv_tolerance,
      PLDV.over_tolerance_error_flag,
      PLDV.market_price,
      PLDV.unordered_flag,
      PLDV.closed_flag,
      PLDV.user_hold_flag,
      PLDV.cancel_flag,
      PLDV.cancelled_by,
      PLDV.cancel_date,
      PLDV.cancel_reason,
      PLDV.firm_status_lookup_code,
      PLDV.firm_date,
      PLDV.vendor_product_num,
      PLDV.contract_num,
      PLDV.taxable_flag,
      PLDV.tax_name,
      PLDV.type_1099,
      PLDV.capital_expense_flag,
      PLDV.negotiated_by_preparer_flag,
      PLDV.attribute_category,
      PLDV.attribute1,
      PLDV.attribute2,
      PLDV.attribute3,
      PLDV.attribute4,
      PLDV.attribute5,
      PLDV.attribute6,
      PLDV.attribute7,
      PLDV.attribute8,
      PLDV.attribute9,
      PLDV.attribute10,
      PLDV.reference_num,
      PLDV.attribute11,
      PLDV.attribute12,
      PLDV.attribute13,
      PLDV.attribute14,
      PLDV.attribute15,
      PLDV.min_release_amount,
      PLDV.price_type_lookup_code,
      PLDV.closed_code,
      PLDV.price_break_lookup_code,
      PLDV.ussgl_transaction_code,
      PLDV.government_context,
      PLDV.request_id,
      PLDV.program_application_id,
      PLDV.program_id,
      PLDV.program_update_date,
      PLDV.closed_date,
      PLDV.closed_reason,
      PLDV.closed_by,
      PLDV.transaction_reason_code,
      PLDV.org_id,
      PLDV.qc_grade,
      PLDV.base_uom,
      PLDV.base_qty,
      PLDV.secondary_uom,
      PLDV.secondary_qty,
      PLDV.global_attribute_category,
      PLDV.global_attribute1,
      PLDV.global_attribute2,
      PLDV.global_attribute3,
      PLDV.global_attribute4,
      PLDV.global_attribute5,
      PLDV.global_attribute6,
      PLDV.global_attribute7,
      PLDV.global_attribute8,
      PLDV.global_attribute9,
      PLDV.global_attribute10,
      PLDV.global_attribute11,
      PLDV.global_attribute12,
      PLDV.global_attribute13,
      PLDV.global_attribute14,
      PLDV.global_attribute15,
      PLDV.global_attribute16,
      PLDV.global_attribute17,
      PLDV.global_attribute18,
      PLDV.global_attribute19,
      PLDV.global_attribute20,
      PLDV.line_reference_num,
      PLDV.project_id,
      PLDV.task_id,
      PLDV.expiration_date,
      PLDV.tax_code_id,
      PLDV.oke_contract_header_id,
      PLDV.oke_contract_version_id,
      PLDV.secondary_quantity,
      PLDV.secondary_unit_of_measure,
      PLDV.preferred_grade,
      PLDV.auction_header_id,
      PLDV.auction_display_number,
      PLDV.auction_line_number,
      PLDV.bid_number,
      PLDV.bid_line_number,
      PLDV.retroactive_date,
      PLDV.supplier_ref_number,
      PLDV.contract_id,
      PLDV.start_date,
      PLDV.amount,
      PLDV.job_id,
      PLDV.contractor_first_name,
      PLDV.contractor_last_name,
      PLDV.order_type_lookup_code,
      PLDV.purchase_basis,
      PLDV.matching_basis,
      PLDV.svc_amount_notif_sent,
      PLDV.svc_completion_notif_sent,
      PLDV.base_unit_price,
      PLDV.manual_price_change_flag,
      -- <Complex Work R12 Start>
      PLDV.retainage_rate,
      PLDV.max_retainage_amount,
      PLDV.progress_payment_rate,
      PLDV.recoupment_rate,
      -- <Complex Work R12 End>
      PLDV.catalog_name,
      PLDV.supplier_part_auxid,
      PLDV.ip_category_id,
      PLDV.tax_attribute_update_code -- <ETAX R12>
    ) WHERE NVL(PLDV.delete_flag, 'N') <> 'Y';


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
--p_po_line_id
--  id for po line record
--p_draft_id
--  draft unique identifier
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_draft_record
( p_po_line_id IN NUMBER,
  p_draft_id     IN NUMBER
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
  FROM po_lines_draft_all
  WHERE po_line_id = p_po_line_id
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
--p_po_line_id
--  id for po line record
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_transaction_record
( p_po_line_id IN NUMBER
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
  FROM po_lines_all
  WHERE po_line_id = p_po_line_id
  FOR UPDATE NOWAIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END lock_transaction_record;

END PO_LINES_DRAFT_PKG;

/
