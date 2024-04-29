--------------------------------------------------------
--  DDL for Package Body PO_DISTRIBUTIONS_DRAFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DISTRIBUTIONS_DRAFT_PKG" AS
/* $Header: PO_DISTRIBUTIONS_DRAFT_PKG.plb 120.8.12010000.5 2014/06/06 09:50:33 inagdeo ship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_DISTRIBUTIONS_DRAFT_PKG');

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_rows
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Deletes drafts for distribution based on the information given
--  If only draft_id is provided, then all distributions for the draft will be
--  deleted
--  If po_distribution_id is also provided, then the one record that has such
--  primary key will be deleted
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_po_distribution_id
--  po distribution unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE delete_rows
( p_draft_id IN NUMBER,
  p_po_distribution_id IN NUMBER
) IS
d_api_name CONSTANT VARCHAR2(30) := 'delete_rows';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  DELETE FROM po_distributions_draft_all
  WHERE draft_id = p_draft_id
  AND po_distribution_id = NVL(p_po_distribution_id, po_distribution_id);

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
--p_po_distribution_id_tbl
--  table of po distribution unique identifier
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
( p_po_distribution_id_tbl   IN PO_TBL_NUMBER,
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
    PO_DISTRIBUTIONS_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_po_distribution_id_tbl => p_po_distribution_id_tbl
    );

  -- bug5471513 START
  -- If there're duplicate entries in the id table,
  -- we do not want to insert multiple entries
  -- Created an associative array to store what id has appeared.
  l_duplicate_flag_tbl.EXTEND(p_po_distribution_id_tbl.COUNT);

  FOR i IN 1..p_po_distribution_id_tbl.COUNT LOOP
    IF (x_record_already_exist_tbl(i) = FND_API.G_FALSE) THEN

      IF (l_distinct_id_list.EXISTS(p_po_distribution_id_tbl(i))) THEN

        l_duplicate_flag_tbl(i) := FND_API.G_TRUE;
      ELSE
        l_duplicate_flag_tbl(i) := FND_API.G_FALSE;

        l_distinct_id_list(p_po_distribution_id_tbl(i)) := 1;
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

  FORALL i IN 1..p_po_distribution_id_tbl.COUNT
    INSERT INTO po_distributions_draft_all
    (
      draft_id,
      delete_flag,
      change_accepted_flag,
      po_distribution_id,
      last_update_date,
      last_updated_by,
      po_header_id,
      po_line_id,
      line_location_id,
      set_of_books_id,
      code_combination_id,
      quantity_ordered,
      last_update_login,
      creation_date,
      created_by,
      po_release_id,
      quantity_delivered,
      quantity_billed,
      quantity_cancelled,
      req_header_reference_num,
      req_line_reference_num,
      req_distribution_id,
      deliver_to_location_id,
      deliver_to_person_id,
      rate_date,
      rate,
      amount_billed,
      accrued_flag,
      encumbered_flag,
      encumbered_amount,
      unencumbered_quantity,
      unencumbered_amount,
      failed_funds_lookup_code,
      gl_encumbered_date,
      gl_encumbered_period_name,
      gl_cancelled_date,
      destination_type_code,
      destination_organization_id,
      destination_subinventory,
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
      wip_entity_id,
      wip_operation_seq_num,
      wip_resource_seq_num,
      wip_repetitive_schedule_id,
      wip_line_id,
      bom_resource_id,
      budget_account_id,
      accrual_account_id,
      variance_account_id,
      prevent_encumbrance_flag,
      ussgl_transaction_code,
      government_context,
      destination_context,
      distribution_num,
      source_distribution_id,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      project_id,
      task_id,
      expenditure_type,
      project_accounting_context,
      expenditure_organization_id,
      gl_closed_date,
      accrue_on_receipt_flag,
      expenditure_item_date,
      org_id,
      kanban_card_id,
      award_id,
      mrc_rate_date,
      mrc_rate,
      mrc_encumbered_amount,
      mrc_unencumbered_amount,
      end_item_unit_number,
      tax_recovery_override_flag,
      recoverable_tax,
      nonrecoverable_tax,
      recovery_rate,
      oke_contract_line_id,
      oke_contract_deliverable_id,
      amount_ordered,
      amount_delivered,
      amount_cancelled,
      distribution_type,
      amount_to_encumber,
      invoice_adjustment_flag,
      dest_charge_account_id,
      dest_variance_account_id,
      -- <Complex Work R12 Start>
      quantity_financed,
      amount_financed,
      quantity_recouped,
      amount_recouped,
      retainage_withheld_amount,
      retainage_released_amount,
      -- <Complex Work R12 End>
      tax_attribute_update_code, -- <ETAX R12>
      global_attribute_category ,
      global_attribute1  ,
      global_attribute2  ,
      global_attribute3  ,
      global_attribute4  ,
      global_attribute5  ,
      global_attribute6  ,
      global_attribute7  ,
      global_attribute8  ,
      global_attribute9  ,
      global_attribute10 ,
      global_attribute11 ,
      global_attribute12 ,
      global_attribute13 ,
      global_attribute14 ,
      global_attribute15 ,
      global_attribute16 ,
      global_attribute17 ,
      global_attribute18 ,
      global_attribute19 ,
      global_attribute20 ,
      amount_changed_flag, --13503748 Encumbrance ER
      interface_distribution_ref -- Bug 18891225
    )
    SELECT
      p_draft_id_tbl(i),
      p_delete_flag_tbl(i),
      NULL,
      po_distribution_id,
      last_update_date,
      last_updated_by,
      po_header_id,
      po_line_id,
      line_location_id,
      set_of_books_id,
      code_combination_id,
      quantity_ordered,
      last_update_login,
      creation_date,
      created_by,
      po_release_id,
      quantity_delivered,
      quantity_billed,
      quantity_cancelled,
      req_header_reference_num,
      req_line_reference_num,
      req_distribution_id,
      deliver_to_location_id,
      deliver_to_person_id,
      rate_date,
      rate,
      amount_billed,
      accrued_flag,
      encumbered_flag,
      encumbered_amount,
      unencumbered_quantity,
      unencumbered_amount,
      failed_funds_lookup_code,
      gl_encumbered_date,
      gl_encumbered_period_name,
      gl_cancelled_date,
      destination_type_code,
      destination_organization_id,
      destination_subinventory,
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
      wip_entity_id,
      wip_operation_seq_num,
      wip_resource_seq_num,
      wip_repetitive_schedule_id,
      wip_line_id,
      bom_resource_id,
      budget_account_id,
      accrual_account_id,
      variance_account_id,
      prevent_encumbrance_flag,
      ussgl_transaction_code,
      government_context,
      destination_context,
      distribution_num,
      source_distribution_id,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      project_id,
      task_id,
      expenditure_type,
      project_accounting_context,
      expenditure_organization_id,
      gl_closed_date,
      accrue_on_receipt_flag,
      expenditure_item_date,
      org_id,
      kanban_card_id,
      award_id,
      mrc_rate_date,
      mrc_rate,
      mrc_encumbered_amount,
      mrc_unencumbered_amount,
      end_item_unit_number,
      tax_recovery_override_flag,
      recoverable_tax,
      nonrecoverable_tax,
      recovery_rate,
      oke_contract_line_id,
      oke_contract_deliverable_id,
      amount_ordered,
      amount_delivered,
      amount_cancelled,
      distribution_type,
      amount_to_encumber,
      invoice_adjustment_flag,
      dest_charge_account_id,
      dest_variance_account_id,
      -- <Complex Work R12 Start>
      quantity_financed,
      amount_financed,
      quantity_recouped,
      amount_recouped,
      retainage_withheld_amount,
      retainage_released_amount,
      -- <Complex Work R12 End>
      tax_attribute_update_code, -- <ETAX R12>
      global_attribute_category ,
      global_attribute1  ,
      global_attribute2  ,
      global_attribute3  ,
      global_attribute4  ,
      global_attribute5  ,
      global_attribute6  ,
      global_attribute7  ,
      global_attribute8  ,
      global_attribute9  ,
      global_attribute10 ,
      global_attribute11 ,
      global_attribute12 ,
      global_attribute13 ,
      global_attribute14 ,
      global_attribute15 ,
      global_attribute16 ,
      global_attribute17 ,
      global_attribute18 ,
      global_attribute19 ,
      global_attribute20 ,
      amount_changed_flag,  --13503748 Encumbrance ER
      interface_distribution_ref -- Bug 18891225
    FROM po_distributions_all
    WHERE po_distribution_id = p_po_distribution_id_tbl(i)
    AND x_record_already_exist_tbl(i) = FND_API.G_FALSE
    AND l_duplicate_flag_tbl(i) = FND_API.G_FALSE;

  d_position := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer count = ' || SQL%ROWCOUNT);
  END IF;

  FORALL i IN 1..p_po_distribution_id_tbl.COUNT
    UPDATE po_distributions_draft_all
    SET    delete_flag = p_delete_flag_tbl(i)
    WHERE  po_distribution_id = p_po_distribution_id_tbl(i)
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
--p_distribution_id
--  distribution unique identifier
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
( p_po_distribution_id IN NUMBER,
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
    PO_LOG.proc_begin(d_module, 'p_po_distribution_id', p_po_distribution_id);
  END IF;

  sync_draft_from_txn
  ( p_po_distribution_id_tbl   => PO_TBL_NUMBER(p_po_distribution_id),
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

  DELETE FROM po_distributions_all PD
  WHERE PD.po_distribution_id IN
         ( SELECT PDD.po_distribution_id -- Bug 5292573
           FROM   po_distributions_draft_all PDD
           WHERE  PDD.draft_id = p_draft_id
           AND    PDD.delete_flag = 'Y'
           AND    NVL(PDD.change_accepted_flag, 'Y') = 'Y' );

  -- Merge PO Distribution changes
  -- For update case, the following columns will be skipped:
  --PD.po_distribution_id
  --PD.creation_date
  --PD.created_by
  --PD.quantity_delivered
  --PD.quantity_billed
  --PD.quantity_cancelled
  --PD.request_id
  --PD.program_application_id
  --PD.program_id
  --PD.program_update_date
  --PD.mrc_rate_date
  --PD.mrc_rate
  --PD.mrc_encumbered_amount
  --PD.mrc_unencumbered_amount
  --PD.end_item_unit_number
  --PD.recoverable_tax
  --PD.nonrecoverable_tax
  --PD.amount_delivered
  --PD.amount_cancelled
  --PD.invoice_adjustment_flag
  -- <Complex Work R12 Start>
  --PD.quantity_financed
  --PD.amount_financed
  --PD.quantity_recouped
  --PD.amount_recouped
  --PD.retainage_withheld_amount
  --PD.retainage_released_amount
  -- <Complex Work R12 End>
  MERGE INTO po_distributions_all PD
  USING (
    SELECT
      PDD.draft_id,
      PDD.delete_flag,
      PDD.change_accepted_flag,
      PDD.po_distribution_id,
      PDD.last_update_date,
      PDD.last_updated_by,
      PDD.po_header_id,
      PDD.po_line_id,
      PDD.line_location_id,
      PDD.set_of_books_id,
      PDD.code_combination_id,
      PDD.quantity_ordered,
      PDD.last_update_login,
      PDD.creation_date,
      PDD.created_by,
      PDD.po_release_id,
      PDD.quantity_delivered,
      PDD.quantity_billed,
      PDD.quantity_cancelled,
      PDD.req_header_reference_num,
      PDD.req_line_reference_num,
      PDD.req_distribution_id,
      PDD.deliver_to_location_id,
      PDD.deliver_to_person_id,
      PDD.rate_date,
      PDD.rate,
      PDD.amount_billed,
      PDD.accrued_flag,
      PDD.encumbered_flag,
      PDD.encumbered_amount,
      PDD.unencumbered_quantity,
      PDD.unencumbered_amount,
      PDD.failed_funds_lookup_code,
      PDD.gl_encumbered_date,
      PDD.gl_encumbered_period_name,
      PDD.gl_cancelled_date,
      PDD.destination_type_code,
      PDD.destination_organization_id,
      PDD.destination_subinventory,
      PDD.attribute_category,
      PDD.attribute1,
      PDD.attribute2,
      PDD.attribute3,
      PDD.attribute4,
      PDD.attribute5,
      PDD.attribute6,
      PDD.attribute7,
      PDD.attribute8,
      PDD.attribute9,
      PDD.attribute10,
      PDD.attribute11,
      PDD.attribute12,
      PDD.attribute13,
      PDD.attribute14,
      PDD.attribute15,
      PDD.wip_entity_id,
      PDD.wip_operation_seq_num,
      PDD.wip_resource_seq_num,
      PDD.wip_repetitive_schedule_id,
      PDD.wip_line_id,
      PDD.bom_resource_id,
      PDD.budget_account_id,
      PDD.accrual_account_id,
      PDD.variance_account_id,
      PDD.prevent_encumbrance_flag,
      PDD.ussgl_transaction_code,
      PDD.government_context,
      PDD.destination_context,
      PDD.distribution_num,
      PDD.source_distribution_id,
      PDD.request_id,
      PDD.program_application_id,
      PDD.program_id,
      PDD.program_update_date,
      PDD.project_id,
      PDD.task_id,
      PDD.expenditure_type,
      PDD.project_accounting_context,
      PDD.expenditure_organization_id,
      PDD.gl_closed_date,
      PDD.accrue_on_receipt_flag,
      PDD.expenditure_item_date,
      PDD.org_id,
      PDD.kanban_card_id,
      PDD.award_id,
      PDD.mrc_rate_date,
      PDD.mrc_rate,
      PDD.mrc_encumbered_amount,
      PDD.mrc_unencumbered_amount,
      PDD.end_item_unit_number,
      PDD.tax_recovery_override_flag,
      PDD.recoverable_tax,
      PDD.nonrecoverable_tax,
      PDD.recovery_rate,
      PDD.oke_contract_line_id,
      PDD.oke_contract_deliverable_id,
      PDD.amount_ordered,
      PDD.amount_delivered,
      PDD.amount_cancelled,
      PDD.distribution_type,
      PDD.amount_to_encumber,
      PDD.invoice_adjustment_flag,
      PDD.dest_charge_account_id,
      PDD.dest_variance_account_id,
      -- <Complex Work R12 Start>
      PDD.quantity_financed,
      PDD.amount_financed,
      PDD.quantity_recouped,
      PDD.amount_recouped,
      PDD.retainage_withheld_amount,
      PDD.retainage_released_amount,
      -- <Complex Work R12 End>
      PDD.tax_attribute_update_code, -- <ETAX R12>
      pdd.global_attribute_category ,
      pdd.global_attribute1  ,
      pdd.global_attribute2  ,
      pdd.global_attribute3  ,
      pdd.global_attribute4  ,
      pdd.global_attribute5  ,
      pdd.global_attribute6  ,
      pdd.global_attribute7  ,
      pdd.global_attribute8  ,
      pdd.global_attribute9  ,
      pdd.global_attribute10 ,
      pdd.global_attribute11 ,
      pdd.global_attribute12 ,
      pdd.global_attribute13 ,
      pdd.global_attribute14 ,
      pdd.global_attribute15 ,
      pdd.global_attribute16 ,
      pdd.global_attribute17 ,
      pdd.global_attribute18 ,
      pdd.global_attribute19 ,
      pdd.global_attribute20 ,
      pdd.amount_changed_flag,  --Bug 13503748 Encumbrance ER
      pdd.interface_distribution_ref -- Bug 18891225
    FROM po_distributions_draft_all PDD
    WHERE PDD.draft_id = p_draft_id
    AND NVL(PDD.change_accepted_flag, 'Y') = 'Y'
    ) PDDV
  ON (PD.po_distribution_id = PDDV.po_distribution_id)
  WHEN MATCHED THEN
    UPDATE
    SET
      PD.last_update_date = PDDV.last_update_date,
      PD.last_updated_by = PDDV.last_updated_by,
      PD.po_header_id = PDDV.po_header_id,
      PD.po_line_id = PDDV.po_line_id,
      PD.line_location_id = PDDV.line_location_id,
      PD.set_of_books_id = PDDV.set_of_books_id,
      PD.code_combination_id = PDDV.code_combination_id,
      PD.quantity_ordered = PDDV.quantity_ordered,
      PD.last_update_login = PDDV.last_update_login,
      PD.po_release_id = PDDV.po_release_id,
      PD.req_header_reference_num = PDDV.req_header_reference_num,
      PD.req_line_reference_num = PDDV.req_line_reference_num,
      PD.req_distribution_id = PDDV.req_distribution_id,
      PD.deliver_to_location_id = PDDV.deliver_to_location_id,
      PD.deliver_to_person_id = PDDV.deliver_to_person_id,
      PD.rate_date = PDDV.rate_date,
      PD.rate = PDDV.rate,
      PD.amount_billed = PDDV.amount_billed,
      PD.accrued_flag = PDDV.accrued_flag,
      PD.encumbered_flag = PDDV.encumbered_flag,
      PD.encumbered_amount = PDDV.encumbered_amount,
      PD.unencumbered_quantity = PDDV.unencumbered_quantity,
      PD.unencumbered_amount = PDDV.unencumbered_amount,
      PD.failed_funds_lookup_code = PDDV.failed_funds_lookup_code,
      PD.gl_encumbered_date = PDDV.gl_encumbered_date,
      PD.gl_encumbered_period_name = PDDV.gl_encumbered_period_name,
      PD.gl_cancelled_date = PDDV.gl_cancelled_date,
      PD.destination_type_code = PDDV.destination_type_code,
      PD.destination_organization_id = PDDV.destination_organization_id,
      PD.destination_subinventory = PDDV.destination_subinventory,
      PD.attribute_category = PDDV.attribute_category,
      PD.attribute1 = PDDV.attribute1,
      PD.attribute2 = PDDV.attribute2,
      PD.attribute3 = PDDV.attribute3,
      PD.attribute4 = PDDV.attribute4,
      PD.attribute5 = PDDV.attribute5,
      PD.attribute6 = PDDV.attribute6,
      PD.attribute7 = PDDV.attribute7,
      PD.attribute8 = PDDV.attribute8,
      PD.attribute9 = PDDV.attribute9,
      PD.attribute10 = PDDV.attribute10,
      PD.attribute11 = PDDV.attribute11,
      PD.attribute12 = PDDV.attribute12,
      PD.attribute13 = PDDV.attribute13,
      PD.attribute14 = PDDV.attribute14,
      PD.attribute15 = PDDV.attribute15,
      PD.wip_entity_id = PDDV.wip_entity_id,
      PD.wip_operation_seq_num = PDDV.wip_operation_seq_num,
      PD.wip_resource_seq_num = PDDV.wip_resource_seq_num,
      PD.wip_repetitive_schedule_id = PDDV.wip_repetitive_schedule_id,
      PD.wip_line_id = PDDV.wip_line_id,
      PD.bom_resource_id = PDDV.bom_resource_id,
      PD.budget_account_id = PDDV.budget_account_id,
      PD.accrual_account_id = PDDV.accrual_account_id,
      PD.variance_account_id = PDDV.variance_account_id,
      PD.prevent_encumbrance_flag = PDDV.prevent_encumbrance_flag,
      PD.ussgl_transaction_code = PDDV.ussgl_transaction_code,
      PD.government_context = PDDV.government_context,
      PD.destination_context = PDDV.destination_context,
      PD.distribution_num = PDDV.distribution_num,
      PD.source_distribution_id = PDDV.source_distribution_id,
      PD.project_id = PDDV.project_id,
      PD.task_id = PDDV.task_id,
      PD.expenditure_type = PDDV.expenditure_type,
      PD.project_accounting_context = PDDV.project_accounting_context,
      PD.expenditure_organization_id = PDDV.expenditure_organization_id,
      PD.gl_closed_date = PDDV.gl_closed_date,
      PD.accrue_on_receipt_flag = PDDV.accrue_on_receipt_flag,
      PD.expenditure_item_date = PDDV.expenditure_item_date,
      PD.org_id = PDDV.org_id,
      PD.kanban_card_id = PDDV.kanban_card_id,
      PD.award_id = PDDV.award_id,
      PD.tax_recovery_override_flag = PDDV.tax_recovery_override_flag,
      PD.recovery_rate = PDDV.recovery_rate,
      PD.oke_contract_line_id = PDDV.oke_contract_line_id,
      PD.oke_contract_deliverable_id = PDDV.oke_contract_deliverable_id,
      PD.amount_ordered = PDDV.amount_ordered,
      PD.distribution_type = PDDV.distribution_type,
      PD.amount_to_encumber = PDDV.amount_to_encumber,
      PD.dest_charge_account_id = PDDV.dest_charge_account_id,
      PD.dest_variance_account_id = PDDV.dest_variance_account_id,
      PD.tax_attribute_update_code = PDDV.tax_attribute_update_code, -- <ETAX R12>
  --  DELETE WHERE PDDV.delete_flag = 'Y'
      pd.global_attribute_category = pddv.global_attribute_category ,
      pd.global_attribute1  = pddv.global_attribute1  ,
      pd.global_attribute2  = pddv.global_attribute2  ,
      pd.global_attribute3  = pddv.global_attribute3  ,
      pd.global_attribute4  = pddv.global_attribute4  ,
      pd.global_attribute5  = pddv.global_attribute5  ,
      pd.global_attribute6  = pddv.global_attribute6  ,
      pd.global_attribute7  = pddv.global_attribute7  ,
      pd.global_attribute8  = pddv.global_attribute8  ,
      pd.global_attribute9  = pddv.global_attribute9  ,
      pd.global_attribute10 = pddv.global_attribute10 ,
      pd.global_attribute11 = pddv.global_attribute11 ,
      pd.global_attribute12 = pddv.global_attribute12 ,
      pd.global_attribute13 = pddv.global_attribute13 ,
      pd.global_attribute14 = pddv.global_attribute14 ,
      pd.global_attribute15 = pddv.global_attribute15 ,
      pd.global_attribute16 = pddv.global_attribute16 ,
      pd.global_attribute17 = pddv.global_attribute17 ,
      pd.global_attribute18 = pddv.global_attribute18 ,
      pd.global_attribute19 = pddv.global_attribute19 ,
      pd.global_attribute20 = pddv.global_attribute20 ,
      pd.amount_changed_flag =pddv.amount_changed_flag,
      pd.interface_distribution_ref = pddv.interface_distribution_ref -- Bug 18891225
  WHEN NOT MATCHED THEN
    INSERT
    (
      PD.po_distribution_id,
      PD.last_update_date,
      PD.last_updated_by,
      PD.po_header_id,
      PD.po_line_id,
      PD.line_location_id,
      PD.set_of_books_id,
      PD.code_combination_id,
      PD.quantity_ordered,
      PD.last_update_login,
      PD.creation_date,
      PD.created_by,
      PD.po_release_id,
      PD.quantity_delivered,
      PD.quantity_billed,
      PD.quantity_cancelled,
      PD.req_header_reference_num,
      PD.req_line_reference_num,
      PD.req_distribution_id,
      PD.deliver_to_location_id,
      PD.deliver_to_person_id,
      PD.rate_date,
      PD.rate,
      PD.amount_billed,
      PD.accrued_flag,
      PD.encumbered_flag,
      PD.encumbered_amount,
      PD.unencumbered_quantity,
      PD.unencumbered_amount,
      PD.failed_funds_lookup_code,
      PD.gl_encumbered_date,
      PD.gl_encumbered_period_name,
      PD.gl_cancelled_date,
      PD.destination_type_code,
      PD.destination_organization_id,
      PD.destination_subinventory,
      PD.attribute_category,
      PD.attribute1,
      PD.attribute2,
      PD.attribute3,
      PD.attribute4,
      PD.attribute5,
      PD.attribute6,
      PD.attribute7,
      PD.attribute8,
      PD.attribute9,
      PD.attribute10,
      PD.attribute11,
      PD.attribute12,
      PD.attribute13,
      PD.attribute14,
      PD.attribute15,
      PD.wip_entity_id,
      PD.wip_operation_seq_num,
      PD.wip_resource_seq_num,
      PD.wip_repetitive_schedule_id,
      PD.wip_line_id,
      PD.bom_resource_id,
      PD.budget_account_id,
      PD.accrual_account_id,
      PD.variance_account_id,
      PD.prevent_encumbrance_flag,
      PD.ussgl_transaction_code,
      PD.government_context,
      PD.destination_context,
      PD.distribution_num,
      PD.source_distribution_id,
      PD.request_id,
      PD.program_application_id,
      PD.program_id,
      PD.program_update_date,
      PD.project_id,
      PD.task_id,
      PD.expenditure_type,
      PD.project_accounting_context,
      PD.expenditure_organization_id,
      PD.gl_closed_date,
      PD.accrue_on_receipt_flag,
      PD.expenditure_item_date,
      PD.org_id,
      PD.kanban_card_id,
      PD.award_id,
      PD.mrc_rate_date,
      PD.mrc_rate,
      PD.mrc_encumbered_amount,
      PD.mrc_unencumbered_amount,
      PD.end_item_unit_number,
      PD.tax_recovery_override_flag,
      PD.recoverable_tax,
      PD.nonrecoverable_tax,
      PD.recovery_rate,
      PD.oke_contract_line_id,
      PD.oke_contract_deliverable_id,
      PD.amount_ordered,
      PD.amount_delivered,
      PD.amount_cancelled,
      PD.distribution_type,
      PD.amount_to_encumber,
      PD.invoice_adjustment_flag,
      PD.dest_charge_account_id,
      PD.dest_variance_account_id,
      -- <Complex Work R12 Start>
      PD.quantity_financed,
      PD.amount_financed,
      PD.quantity_recouped,
      PD.amount_recouped,
      PD.retainage_withheld_amount,
      PD.retainage_released_amount,
      -- <Complex Work R12 End>
      PD.tax_attribute_update_code, -- <ETAX R12>
      pd.global_attribute_category ,
      pd.global_attribute1  ,
      pd.global_attribute2  ,
      pd.global_attribute3  ,
      pd.global_attribute4  ,
      pd.global_attribute5  ,
      pd.global_attribute6  ,
      pd.global_attribute7  ,
      pd.global_attribute8  ,
      pd.global_attribute9  ,
      pd.global_attribute10 ,
      pd.global_attribute11 ,
      pd.global_attribute12 ,
      pd.global_attribute13 ,
      pd.global_attribute14 ,
      pd.global_attribute15 ,
      pd.global_attribute16 ,
      pd.global_attribute17 ,
      pd.global_attribute18 ,
      pd.global_attribute19 ,
      pd.global_attribute20 ,
      pd.amount_changed_flag, --Bug 13503748 Encumbrance ER
      pd.interface_distribution_ref -- Bug 18891225
    )
    VALUES
    (
      PDDV.po_distribution_id,
      PDDV.last_update_date,
      PDDV.last_updated_by,
      PDDV.po_header_id,
      PDDV.po_line_id,
      PDDV.line_location_id,
      PDDV.set_of_books_id,
      PDDV.code_combination_id,
      PDDV.quantity_ordered,
      PDDV.last_update_login,
      PDDV.creation_date,
      PDDV.created_by,
      PDDV.po_release_id,
      PDDV.quantity_delivered,
      PDDV.quantity_billed,
      PDDV.quantity_cancelled,
      PDDV.req_header_reference_num,
      PDDV.req_line_reference_num,
      PDDV.req_distribution_id,
      PDDV.deliver_to_location_id,
      PDDV.deliver_to_person_id,
      PDDV.rate_date,
      PDDV.rate,
      PDDV.amount_billed,
      PDDV.accrued_flag,
      PDDV.encumbered_flag,
      PDDV.encumbered_amount,
      PDDV.unencumbered_quantity,
      PDDV.unencumbered_amount,
      PDDV.failed_funds_lookup_code,
      PDDV.gl_encumbered_date,
      PDDV.gl_encumbered_period_name,
      PDDV.gl_cancelled_date,
      PDDV.destination_type_code,
      PDDV.destination_organization_id,
      PDDV.destination_subinventory,
      PDDV.attribute_category,
      PDDV.attribute1,
      PDDV.attribute2,
      PDDV.attribute3,
      PDDV.attribute4,
      PDDV.attribute5,
      PDDV.attribute6,
      PDDV.attribute7,
      PDDV.attribute8,
      PDDV.attribute9,
      PDDV.attribute10,
      PDDV.attribute11,
      PDDV.attribute12,
      PDDV.attribute13,
      PDDV.attribute14,
      PDDV.attribute15,
      PDDV.wip_entity_id,
      PDDV.wip_operation_seq_num,
      PDDV.wip_resource_seq_num,
      PDDV.wip_repetitive_schedule_id,
      PDDV.wip_line_id,
      PDDV.bom_resource_id,
      PDDV.budget_account_id,
      PDDV.accrual_account_id,
      PDDV.variance_account_id,
      PDDV.prevent_encumbrance_flag,
      PDDV.ussgl_transaction_code,
      PDDV.government_context,
      PDDV.destination_context,
      PDDV.distribution_num,
      PDDV.source_distribution_id,
      PDDV.request_id,
      PDDV.program_application_id,
      PDDV.program_id,
      PDDV.program_update_date,
      PDDV.project_id,
      PDDV.task_id,
      PDDV.expenditure_type,
      PDDV.project_accounting_context,
      PDDV.expenditure_organization_id,
      PDDV.gl_closed_date,
      PDDV.accrue_on_receipt_flag,
      PDDV.expenditure_item_date,
      PDDV.org_id,
      PDDV.kanban_card_id,
      PDDV.award_id,
      PDDV.mrc_rate_date,
      PDDV.mrc_rate,
      PDDV.mrc_encumbered_amount,
      PDDV.mrc_unencumbered_amount,
      PDDV.end_item_unit_number,
      PDDV.tax_recovery_override_flag,
      PDDV.recoverable_tax,
      PDDV.nonrecoverable_tax,
      PDDV.recovery_rate,
      PDDV.oke_contract_line_id,
      PDDV.oke_contract_deliverable_id,
      PDDV.amount_ordered,
      PDDV.amount_delivered,
      PDDV.amount_cancelled,
      PDDV.distribution_type,
      PDDV.amount_to_encumber,
      PDDV.invoice_adjustment_flag,
      PDDV.dest_charge_account_id,
      PDDV.dest_variance_account_id,
      -- <Complex Work R12 Start>
      PDDV.quantity_financed,
      PDDV.amount_financed,
      PDDV.quantity_recouped,
      PDDV.amount_recouped,
      PDDV.retainage_withheld_amount,
      PDDV.retainage_released_amount,
      -- <Complex Work R12 End>
      PDDV.tax_attribute_update_code, -- <ETAX R12>
      pddv.global_attribute_category ,
       pddv.global_attribute1  ,
       pddv.global_attribute2  ,
       pddv.global_attribute3  ,
       pddv.global_attribute4  ,
       pddv.global_attribute5  ,
       pddv.global_attribute6  ,
       pddv.global_attribute7  ,
       pddv.global_attribute8  ,
       pddv.global_attribute9  ,
       pddv.global_attribute10 ,
       pddv.global_attribute11 ,
       pddv.global_attribute12 ,
       pddv.global_attribute13 ,
       pddv.global_attribute14 ,
       pddv.global_attribute15 ,
       pddv.global_attribute16 ,
       pddv.global_attribute17 ,
       pddv.global_attribute18 ,
       pddv.global_attribute19 ,
       pddv.global_attribute20 ,
       pddv.amount_changed_flag,
       pddv.interface_distribution_ref -- Bug 18891225

    ) WHERE NVL(PDDV.delete_flag, 'N') <> 'Y';

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
--p_po_distribution_id
--  id for po distribution record
--p_draft_id
--  draft unique identifier
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_draft_record
( p_po_distribution_id IN NUMBER,
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
  FROM po_distributions_draft_all
  WHERE po_distribution_id = p_po_distribution_id
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
--p_po_distribution_id
--  id for po distribution record
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_transaction_record
( p_po_distribution_id IN NUMBER
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
  FROM po_distributions_all
  WHERE po_distribution_id = p_po_distribution_id
  FOR UPDATE NOWAIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END lock_transaction_record;

END PO_DISTRIBUTIONS_DRAFT_PKG;

/
