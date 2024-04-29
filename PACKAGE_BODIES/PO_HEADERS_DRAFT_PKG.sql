--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_DRAFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_DRAFT_PKG" AS
/* $Header: PO_HEADERS_DRAFT_PKG.plb 120.8.12010000.7 2013/01/31 07:33:07 xueche ship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_HEADERS_DRAFT_PKG');

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_rows
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Deletes drafts for headers based on the information given
--  If only draft_id is provided, then all headers for the draft will be
--  deleted
--  If po_header_id is also provided, then the one record that has such
--  primary key will be deleted
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_po_header_id
--  po header unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE delete_rows
( p_draft_id IN NUMBER,
  p_po_header_id IN NUMBER
) IS
d_api_name CONSTANT VARCHAR2(30) := 'delete_rows';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  DELETE FROM po_headers_draft_all
  WHERE draft_id = p_draft_id
  AND po_header_id = NVL(p_po_header_id, po_header_id);

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
--p_po_header_id_tbl
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
( p_po_header_id_tbl         IN PO_TBL_NUMBER,
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
    PO_HEADERS_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_po_header_id_tbl => p_po_header_id_tbl
    );

  -- bug5471513 START
  -- If there're duplicate entries in the id table,
  -- we do not want to insert multiple entries
  -- Created an associative array to store what id has appeared.
  l_duplicate_flag_tbl.EXTEND(p_po_header_id_tbl.COUNT);

  FOR i IN 1..p_po_header_id_tbl.COUNT LOOP
    IF (x_record_already_exist_tbl(i) = FND_API.G_FALSE) THEN

      IF (l_distinct_id_list.EXISTS(p_po_header_id_tbl(i))) THEN

        l_duplicate_flag_tbl(i) := FND_API.G_TRUE;
      ELSE
        l_duplicate_flag_tbl(i) := FND_API.G_FALSE;

        l_distinct_id_list(p_po_header_id_tbl(i)) := 1;
      END IF;

    ELSE

      l_duplicate_flag_tbl(i) := NULL;

    END IF;
  END LOOP;

  d_position := 10;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer records from txn to dft');
  END IF;

  FORALL i IN 1..p_po_header_id_tbl.COUNT
    INSERT INTO po_headers_draft_all
    ( draft_id,
      delete_flag,
      change_accepted_flag,
      po_header_id,
      agent_id,
      type_lookup_code,
      last_update_date,
      last_updated_by,
      segment1,
      summary_flag,
      enabled_flag,
      segment2,
      segment3,
      segment4,
      segment5,
      start_date_active,
      end_date_active,
      last_update_login,
      creation_date,
      created_by,
      vendor_id,
      vendor_site_id,
      vendor_contact_id,
      ship_to_location_id,
      bill_to_location_id,
      terms_id,
      ship_via_lookup_code,
      fob_lookup_code,
      freight_terms_lookup_code,
      status_lookup_code,
      currency_code,
      rate_type,
      rate_date,
      rate,
      from_header_id,
      from_type_lookup_code,
      start_date,
      end_date,
      blanket_total_amount,
      authorization_status,
      revision_num,
      revised_date,
      approved_flag,
      approved_date,
      amount_limit,
      min_release_amount,
      note_to_authorizer,
      note_to_vendor,
      note_to_receiver,
      print_count,
      printed_date,
      vendor_order_num,
      confirming_order_flag,
      comments,
      reply_date,
      reply_method_lookup_code,
      rfq_close_date,
      quote_type_lookup_code,
      quotation_class_code,
      quote_warning_delay_unit,
      quote_warning_delay,
      quote_vendor_quote_number,
      acceptance_required_flag,
      acceptance_due_date,
      closed_date,
      user_hold_flag,
      approval_required_flag,
      cancel_flag,
      firm_status_lookup_code,
      firm_date,
      frozen_flag,
      supply_agreement_flag,
      edi_processed_flag,
      edi_processed_status,
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
      closed_code,
      ussgl_transaction_code,
      government_context,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      org_id,
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
      interface_source_code,
      reference_num,
      wf_item_type,
      wf_item_key,
      mrc_rate_type,
      mrc_rate_date,
      mrc_rate,
      pcard_id,
      price_update_tolerance,
      pay_on_code,
      xml_flag,
      xml_send_date,
      xml_change_send_date,
      global_agreement_flag,
      consigned_consumption_flag,
      cbc_accounting_date,
      consume_req_demand_flag,
      change_requested_by,
      shipping_control,
      conterms_exist_flag,
      conterms_articles_upd_date,
      conterms_deliv_upd_date,
      encumbrance_required_flag,
      pending_signature_flag,
      change_summary,
      document_creation_method,
      submit_date,
      supplier_notif_method,
      fax,
      email_address,
      retro_price_comm_updates_flag,
      retro_price_apply_updates_flag,
      update_sourcing_rules_flag,
      auto_sourcing_flag,
      created_language,
      cpa_reference,
      style_id,
      tax_attribute_update_code, -- <ETAX INTEGRATION R12>
      supplier_auth_enabled_flag,  -- bug5022835
      cat_admin_auth_enabled_flag,  -- bug5022835
      pay_when_paid, -- E and C ER
	  ame_approval_id, -- PO AME Approval Workflow changes
      ame_transaction_type, -- PO AME Approval Workflow changes
      enable_all_sites --ER 9824167
    )
    SELECT
      p_draft_id_tbl(i),
      p_delete_flag_tbl(i),
      NULL,
      po_header_id,
      agent_id,
      type_lookup_code,
      last_update_date,
      last_updated_by,
      segment1,
      summary_flag,
      enabled_flag,
      segment2,
      segment3,
      segment4,
      segment5,
      start_date_active,
      end_date_active,
      last_update_login,
      creation_date,
      created_by,
      vendor_id,
      vendor_site_id,
      vendor_contact_id,
      ship_to_location_id,
      bill_to_location_id,
      terms_id,
      ship_via_lookup_code,
      fob_lookup_code,
      freight_terms_lookup_code,
      status_lookup_code,
      currency_code,
      rate_type,
      rate_date,
      rate,
      from_header_id,
      from_type_lookup_code,
      start_date,
      end_date,
      blanket_total_amount,
      authorization_status,
      revision_num,
      revised_date,
      approved_flag,
      approved_date,
      amount_limit,
      min_release_amount,
      note_to_authorizer,
      note_to_vendor,
      note_to_receiver,
      nvl(print_count, 0),  --bug 16225321
      printed_date,
      vendor_order_num,
      confirming_order_flag,
      comments,
      reply_date,
      reply_method_lookup_code,
      rfq_close_date,
      quote_type_lookup_code,
      quotation_class_code,
      quote_warning_delay_unit,
      quote_warning_delay,
      quote_vendor_quote_number,
      acceptance_required_flag,
      acceptance_due_date,
      closed_date,
      user_hold_flag,
      approval_required_flag,
      cancel_flag,
      firm_status_lookup_code,
      firm_date,
      frozen_flag,
      supply_agreement_flag,
      edi_processed_flag,
      edi_processed_status,
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
      closed_code,
      ussgl_transaction_code,
      government_context,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      org_id,
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
      interface_source_code,
      reference_num,
      wf_item_type,
      wf_item_key,
      mrc_rate_type,
      mrc_rate_date,
      mrc_rate,
      pcard_id,
      price_update_tolerance,
      pay_on_code,
      xml_flag,
      xml_send_date,
      xml_change_send_date,
      global_agreement_flag,
      consigned_consumption_flag,
      cbc_accounting_date,
      consume_req_demand_flag,
      change_requested_by,
      shipping_control,
      conterms_exist_flag,
      conterms_articles_upd_date,
      conterms_deliv_upd_date,
      encumbrance_required_flag,
      pending_signature_flag,
      change_summary,
      document_creation_method,
      submit_date,
      supplier_notif_method,
      fax,
      email_address,
      retro_price_comm_updates_flag,
      retro_price_apply_updates_flag,
      update_sourcing_rules_flag,
      auto_sourcing_flag,
      created_language,
      cpa_reference,
      style_id,
      tax_attribute_update_code, -- <ETAX INTEGRATION R12>
      supplier_auth_enabled_flag, -- bug5022835
      cat_admin_auth_enabled_flag, -- bug5022835
      pay_when_paid, -- E and C ER
	  ame_approval_id, -- PO AME Approval Workflow changes
      ame_transaction_type, -- PO AME Approval Workflow changes
      enable_all_sites --ER 9824167
    FROM po_headers_all
    WHERE po_header_id = p_po_header_id_tbl(i)
    AND x_record_already_exist_tbl(i) = FND_API.G_FALSE
    AND l_duplicate_flag_tbl(i) = FND_API.G_FALSE;

  d_position := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer count = ' || SQL%ROWCOUNT);
  END IF;

  FORALL i IN 1..p_po_header_id_tbl.COUNT
    UPDATE po_headers_draft_all
    SET    delete_flag = p_delete_flag_tbl(i)
    WHERE  po_header_id = p_po_header_id_tbl(i)
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
--p_po_header_id
--  po header unique identifier
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
( p_po_header_id IN NUMBER,
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
    PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
  END IF;

  sync_draft_from_txn
  ( p_po_header_id_tbl         => PO_TBL_NUMBER(p_po_header_id),
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
  -- Delete only lines that have not been rejected

  DELETE FROM po_headers_all PH
  WHERE PH.po_header_id IN
         ( SELECT PHD.po_header_id
           FROM   po_headers_draft_all PHD
           WHERE  PHD.draft_id = p_draft_id
           AND    PHD.delete_flag = 'Y'
           AND    NVL(PHD.change_accepted_flag, 'Y') = 'Y');

  -- Merge PO Header changes
  -- For update case, the following columns will be skipped:
  --      PH.po_header_id
  --      PH.creation_date
  --      PH.created_by
  --      PH.interface_source_code
  --      PH.reference_num
  --      PH.wf_item_type
  --      PH.wf_item_key
  --      PH.mrc_rate_type
  --      PH.mrc_rate_date
  --      PH.mrc_rate
  --      PH.xml_flag
  --      PH.xml_send_date
  --      PH.xml_change_send_date
  --      PH.global_agreement_flag
  --      PH.consigned_consumption_flag
  --      PH.cbc_accounting_date
  --      PH.consume_req_demand_flag
  --      PH.conterms_exist_flag
  --      PH.pending_signature_flag
  -- Bug 13628576
  -- Removing 'change_summary' from the list of columns to be skipped. When a customer
  -- updates a PO, is when 'change summary' makes sense.
  -- Added "PH.change_summary = PHDV.change_summary" in the UPDATE SET statment.
  --      PH.change_summary
  -- <end> Bug 13628576
  --      PH.document_creation_method
  --      PH.submit_date
  --      PH.edi_processed_flag
  --      PH.edi_processed_status,
  --      PH.created_language
  --      PH.cpa_reference
  --      PH.style_id
  --      PH.supplier_auth_enabled_flag
  --      PH.cat_admin_auth_enabled_flag
  MERGE INTO po_headers_all PH
  USING (
    SELECT
      PHD.draft_id,
      PHD.delete_flag,
      PHD.change_accepted_flag,
      PHD.po_header_id,
      PHD.agent_id,
      PHD.type_lookup_code,
      PHD.last_update_date,
      PHD.last_updated_by,
      PHD.segment1,
      PHD.summary_flag,
      PHD.enabled_flag,
      PHD.segment2,
      PHD.segment3,
      PHD.segment4,
      PHD.segment5,
      PHD.start_date_active,
      PHD.end_date_active,
      PHD.last_update_login,
      PHD.creation_date,
      PHD.created_by,
      PHD.vendor_id,
      PHD.vendor_site_id,
      PHD.vendor_contact_id,
      PHD.ship_to_location_id,
      PHD.bill_to_location_id,
      PHD.terms_id,
      PHD.ship_via_lookup_code,
      PHD.fob_lookup_code,
      PHD.freight_terms_lookup_code,
      PHD.status_lookup_code,
      PHD.currency_code,
      PHD.rate_type,
      PHD.rate_date,
      PHD.rate,
      PHD.from_header_id,
      PHD.from_type_lookup_code,
      PHD.start_date,
      PHD.end_date,
      PHD.blanket_total_amount,
      PHD.authorization_status,
      PHD.revision_num,
      PHD.revised_date,
      PHD.approved_flag,
      PHD.approved_date,
      PHD.amount_limit,
      PHD.min_release_amount,
      PHD.note_to_authorizer,
      PHD.note_to_vendor,
      PHD.note_to_receiver,
      nvl(PHD.print_count, 0) print_count,--bug 16225321
      PHD.printed_date,
      PHD.vendor_order_num,
      PHD.confirming_order_flag,
      PHD.comments,
      PHD.reply_date,
      PHD.reply_method_lookup_code,
      PHD.rfq_close_date,
      PHD.quote_type_lookup_code,
      PHD.quotation_class_code,
      PHD.quote_warning_delay_unit,
      PHD.quote_warning_delay,
      PHD.quote_vendor_quote_number,
      PHD.acceptance_required_flag,
      PHD.acceptance_due_date,
      PHD.closed_date,
      PHD.user_hold_flag,
      PHD.approval_required_flag,
      PHD.cancel_flag,
      PHD.firm_status_lookup_code,
      PHD.firm_date,
      PHD.frozen_flag,
      PHD.supply_agreement_flag,
      PHD.edi_processed_flag,
      PHD.edi_processed_status,
      PHD.attribute_category,
      PHD.attribute1,
      PHD.attribute2,
      PHD.attribute3,
      PHD.attribute4,
      PHD.attribute5,
      PHD.attribute6,
      PHD.attribute7,
      PHD.attribute8,
      PHD.attribute9,
      PHD.attribute10,
      PHD.attribute11,
      PHD.attribute12,
      PHD.attribute13,
      PHD.attribute14,
      PHD.attribute15,
      PHD.closed_code,
      PHD.ussgl_transaction_code,
      PHD.government_context,
      PHD.request_id,
      PHD.program_application_id,
      PHD.program_id,
      PHD.program_update_date,
      PHD.org_id,
      PHD.global_attribute_category,
      PHD.global_attribute1,
      PHD.global_attribute2,
      PHD.global_attribute3,
      PHD.global_attribute4,
      PHD.global_attribute5,
      PHD.global_attribute6,
      PHD.global_attribute7,
      PHD.global_attribute8,
      PHD.global_attribute9,
      PHD.global_attribute10,
      PHD.global_attribute11,
      PHD.global_attribute12,
      PHD.global_attribute13,
      PHD.global_attribute14,
      PHD.global_attribute15,
      PHD.global_attribute16,
      PHD.global_attribute17,
      PHD.global_attribute18,
      PHD.global_attribute19,
      PHD.global_attribute20,
      PHD.interface_source_code,
      PHD.reference_num,
      PHD.wf_item_type,
      PHD.wf_item_key,
      PHD.mrc_rate_type,
      PHD.mrc_rate_date,
      PHD.mrc_rate,
      PHD.pcard_id,
      PHD.price_update_tolerance,
      PHD.pay_on_code,
      PHD.xml_flag,
      PHD.xml_send_date,
      PHD.xml_change_send_date,
      PHD.global_agreement_flag,
      PHD.consigned_consumption_flag,
      PHD.cbc_accounting_date,
      PHD.consume_req_demand_flag,
      PHD.change_requested_by,
      PHD.shipping_control,
      PHD.conterms_exist_flag,
      PHD.conterms_articles_upd_date,
      PHD.conterms_deliv_upd_date,
      PHD.encumbrance_required_flag,
      PHD.pending_signature_flag,
      PHD.change_summary,
      PHD.document_creation_method,
      PHD.submit_date,
      PHD.supplier_notif_method,
      PHD.fax,
      PHD.email_address,
      PHD.retro_price_comm_updates_flag,
      PHD.retro_price_apply_updates_flag,
      PHD.update_sourcing_rules_flag,
      PHD.auto_sourcing_flag,
      PHD.created_language,
      PHD.cpa_reference,
      PHD.style_id,
      PHD.tax_attribute_update_code, -- <ETAX INTEGRATION R12>
      PHD.pay_when_paid, -- E and C ER
	  PHD.ame_approval_id, -- PO AME Approval Workflow changes
      PHD.ame_transaction_type, -- PO AME Approval Workflow changes
      PHD.enable_all_sites --ER 9824167
    FROM po_headers_draft_all PHD
    WHERE PHD.draft_id = p_draft_id
    AND NVL(PHD.change_accepted_flag, 'Y') = 'Y'
    ) PHDV
  ON (PH.po_header_id = PHDV.po_header_id)
  WHEN MATCHED THEN
    UPDATE
    SET
      PH.agent_id = PHDV.agent_id,
      PH.type_lookup_code = PHDV.type_lookup_code,
      PH.last_update_date = PHDV.last_update_date,
      PH.last_updated_by = PHDV.last_updated_by,
      PH.segment1 = PHDV.segment1,
      PH.summary_flag = PHDV.summary_flag,
      PH.enabled_flag = PHDV.enabled_flag,
      PH.segment2 = PHDV.segment2,
      PH.segment3 = PHDV.segment3,
      PH.segment4 = PHDV.segment4,
      PH.segment5 = PHDV.segment5,
      PH.start_date_active = PHDV.start_date_active,
      PH.end_date_active = PHDV.end_date_active,
      PH.last_update_login = PHDV.last_update_login,
      PH.vendor_id = PHDV.vendor_id,
      PH.vendor_site_id = PHDV.vendor_site_id,
      PH.vendor_contact_id = PHDV.vendor_contact_id,
      PH.ship_to_location_id = PHDV.ship_to_location_id,
      PH.bill_to_location_id = PHDV.bill_to_location_id,
      PH.terms_id = PHDV.terms_id,
      PH.ship_via_lookup_code = PHDV.ship_via_lookup_code,
      PH.fob_lookup_code = PHDV.fob_lookup_code,
      PH.freight_terms_lookup_code = PHDV.freight_terms_lookup_code,
      PH.status_lookup_code = PHDV.status_lookup_code,
      PH.currency_code = PHDV.currency_code,
      PH.rate_type = PHDV.rate_type,
      PH.rate_date = PHDV.rate_date,
      PH.rate = PHDV.rate,
      PH.from_header_id = PHDV.from_header_id,
      PH.from_type_lookup_code = PHDV.from_type_lookup_code,
      PH.start_date = PHDV.start_date,
      PH.end_date = PHDV.end_date,
      PH.blanket_total_amount = PHDV.blanket_total_amount,
      PH.authorization_status = PHDV.authorization_status,
      PH.revision_num = PHDV.revision_num,
      PH.revised_date = PHDV.revised_date,
      PH.approved_flag = PHDV.approved_flag,
      PH.approved_date = PHDV.approved_date,
      PH.amount_limit = PHDV.amount_limit,
      PH.min_release_amount = PHDV.min_release_amount,
      PH.note_to_authorizer = PHDV.note_to_authorizer,
      PH.note_to_vendor = PHDV.note_to_vendor,
      PH.note_to_receiver = PHDV.note_to_receiver,
      PH.print_count = PHDV.print_count,
      PH.printed_date = PHDV.printed_date,
      PH.vendor_order_num = PHDV.vendor_order_num,
      PH.confirming_order_flag = PHDV.confirming_order_flag,
      PH.comments = PHDV.comments,
      PH.reply_date = PHDV.reply_date,
      PH.reply_method_lookup_code = PHDV.reply_method_lookup_code,
      PH.rfq_close_date = PHDV.rfq_close_date,
      PH.quote_type_lookup_code = PHDV.quote_type_lookup_code,
      PH.quotation_class_code = PHDV.quotation_class_code,
      PH.quote_warning_delay_unit = PHDV.quote_warning_delay_unit,
      PH.quote_warning_delay = PHDV.quote_warning_delay,
      PH.quote_vendor_quote_number = PHDV.quote_vendor_quote_number,
      PH.acceptance_required_flag = PHDV.acceptance_required_flag,
      PH.acceptance_due_date = PHDV.acceptance_due_date,
      PH.closed_date = PHDV.closed_date,
      PH.user_hold_flag = PHDV.user_hold_flag,
      PH.approval_required_flag = PHDV.approval_required_flag,
      PH.cancel_flag = PHDV.cancel_flag,
      PH.firm_status_lookup_code = PHDV.firm_status_lookup_code,
      PH.firm_date = PHDV.firm_date,
      PH.frozen_flag = PHDV.frozen_flag,
      PH.supply_agreement_flag = PHDV.supply_agreement_flag,
      PH.attribute_category = PHDV.attribute_category,
      PH.attribute1 = PHDV.attribute1,
      PH.attribute2 = PHDV.attribute2,
      PH.attribute3 = PHDV.attribute3,
      PH.attribute4 = PHDV.attribute4,
      PH.attribute5 = PHDV.attribute5,
      PH.attribute6 = PHDV.attribute6,
      PH.attribute7 = PHDV.attribute7,
      PH.attribute8 = PHDV.attribute8,
      PH.attribute9 = PHDV.attribute9,
      PH.attribute10 = PHDV.attribute10,
      PH.attribute11 = PHDV.attribute11,
      PH.attribute12 = PHDV.attribute12,
      PH.attribute13 = PHDV.attribute13,
      PH.attribute14 = PHDV.attribute14,
      PH.attribute15 = PHDV.attribute15,
      PH.closed_code = PHDV.closed_code,
      PH.ussgl_transaction_code = PHDV.ussgl_transaction_code,
      PH.government_context = PHDV.government_context,
      PH.request_id = PHDV.request_id,
      PH.program_application_id = PHDV.program_application_id,
      PH.program_id = PHDV.program_id,
      PH.program_update_date = PHDV.program_update_date,
      PH.org_id = PHDV.org_id,
      PH.global_attribute_category = PHDV.global_attribute_category,
      PH.global_attribute1 = PHDV.global_attribute1,
      PH.global_attribute2 = PHDV.global_attribute2,
      PH.global_attribute3 = PHDV.global_attribute3,
      PH.global_attribute4 = PHDV.global_attribute4,
      PH.global_attribute5 = PHDV.global_attribute5,
      PH.global_attribute6 = PHDV.global_attribute6,
      PH.global_attribute7 = PHDV.global_attribute7,
      PH.global_attribute8 = PHDV.global_attribute8,
      PH.global_attribute9 = PHDV.global_attribute9,
      PH.global_attribute10 = PHDV.global_attribute10,
      PH.global_attribute11 = PHDV.global_attribute11,
      PH.global_attribute12 = PHDV.global_attribute12,
      PH.global_attribute13 = PHDV.global_attribute13,
      PH.global_attribute14 = PHDV.global_attribute14,
      PH.global_attribute15 = PHDV.global_attribute15,
      PH.global_attribute16 = PHDV.global_attribute16,
      PH.global_attribute17 = PHDV.global_attribute17,
      PH.global_attribute18 = PHDV.global_attribute18,
      PH.global_attribute19 = PHDV.global_attribute19,
      PH.global_attribute20 = PHDV.global_attribute20,
      PH.pcard_id = PHDV.pcard_id,
      PH.price_update_tolerance = PHDV.price_update_tolerance,
      PH.pay_on_code = PHDV.pay_on_code,
      PH.change_requested_by = PHDV.change_requested_by,
      PH.shipping_control = PHDV.shipping_control,
      PH.conterms_articles_upd_date = PHDV.conterms_articles_upd_date,
      PH.conterms_deliv_upd_date = PHDV.conterms_deliv_upd_date,
      PH.encumbrance_required_flag = PHDV.encumbrance_required_flag,
      PH.supplier_notif_method = PHDV.supplier_notif_method,
      PH.change_summary = PHDV.change_summary,                      -- Bug 13628576
      PH.fax = PHDV.fax,
      PH.email_address = PHDV.email_address,
      PH.retro_price_comm_updates_flag = PHDV.retro_price_comm_updates_flag,
      PH.retro_price_apply_updates_flag = PHDV.retro_price_apply_updates_flag,
      PH.update_sourcing_rules_flag = PHDV.update_sourcing_rules_flag,
      PH.auto_sourcing_flag = PHDV.auto_sourcing_flag,
      PH.tax_attribute_update_code = PHDV.tax_attribute_update_code, -- <ETAX INTEGRATION R12>
      PH.pay_when_paid = PHDV.pay_when_paid,
	  PH.ame_approval_id=PHDV.ame_approval_id , -- PO AME Approval Workflow changes
      PH.ame_transaction_type=PHDV.ame_transaction_type, -- PO AME Approval Workflow changes
      PH.enable_all_sites = PHDV.enable_all_sites --ER 9824167
  --  DELETE WHERE PHDV.delete_flag = 'Y'
  WHEN NOT MATCHED THEN
    INSERT
    (
      PH.po_header_id,
      PH.agent_id,
      PH.type_lookup_code,
      PH.last_update_date,
      PH.last_updated_by,
      PH.segment1,
      PH.summary_flag,
      PH.enabled_flag,
      PH.segment2,
      PH.segment3,
      PH.segment4,
      PH.segment5,
      PH.start_date_active,
      PH.end_date_active,
      PH.last_update_login,
      PH.creation_date,
      PH.created_by,
      PH.vendor_id,
      PH.vendor_site_id,
      PH.vendor_contact_id,
      PH.ship_to_location_id,
      PH.bill_to_location_id,
      PH.terms_id,
      PH.ship_via_lookup_code,
      PH.fob_lookup_code,
      PH.freight_terms_lookup_code,
      PH.status_lookup_code,
      PH.currency_code,
      PH.rate_type,
      PH.rate_date,
      PH.rate,
      PH.from_header_id,
      PH.from_type_lookup_code,
      PH.start_date,
      PH.end_date,
      PH.blanket_total_amount,
      PH.authorization_status,
      PH.revision_num,
      PH.revised_date,
      PH.approved_flag,
      PH.approved_date,
      PH.amount_limit,
      PH.min_release_amount,
      PH.note_to_authorizer,
      PH.note_to_vendor,
      PH.note_to_receiver,
      PH.print_count,
      PH.printed_date,
      PH.vendor_order_num,
      PH.confirming_order_flag,
      PH.comments,
      PH.reply_date,
      PH.reply_method_lookup_code,
      PH.rfq_close_date,
      PH.quote_type_lookup_code,
      PH.quotation_class_code,
      PH.quote_warning_delay_unit,
      PH.quote_warning_delay,
      PH.quote_vendor_quote_number,
      PH.acceptance_required_flag,
      PH.acceptance_due_date,
      PH.closed_date,
      PH.user_hold_flag,
      PH.approval_required_flag,
      PH.cancel_flag,
      PH.firm_status_lookup_code,
      PH.firm_date,
      PH.frozen_flag,
      PH.supply_agreement_flag,
      PH.edi_processed_flag,
      PH.edi_processed_status,
      PH.attribute_category,
      PH.attribute1,
      PH.attribute2,
      PH.attribute3,
      PH.attribute4,
      PH.attribute5,
      PH.attribute6,
      PH.attribute7,
      PH.attribute8,
      PH.attribute9,
      PH.attribute10,
      PH.attribute11,
      PH.attribute12,
      PH.attribute13,
      PH.attribute14,
      PH.attribute15,
      PH.closed_code,
      PH.ussgl_transaction_code,
      PH.government_context,
      PH.request_id,
      PH.program_application_id,
      PH.program_id,
      PH.program_update_date,
      PH.org_id,
      PH.global_attribute_category,
      PH.global_attribute1,
      PH.global_attribute2,
      PH.global_attribute3,
      PH.global_attribute4,
      PH.global_attribute5,
      PH.global_attribute6,
      PH.global_attribute7,
      PH.global_attribute8,
      PH.global_attribute9,
      PH.global_attribute10,
      PH.global_attribute11,
      PH.global_attribute12,
      PH.global_attribute13,
      PH.global_attribute14,
      PH.global_attribute15,
      PH.global_attribute16,
      PH.global_attribute17,
      PH.global_attribute18,
      PH.global_attribute19,
      PH.global_attribute20,
      PH.interface_source_code,
      PH.reference_num,
      PH.wf_item_type,
      PH.wf_item_key,
      PH.mrc_rate_type,
      PH.mrc_rate_date,
      PH.mrc_rate,
      PH.pcard_id,
      PH.price_update_tolerance,
      PH.pay_on_code,
      PH.xml_flag,
      PH.xml_send_date,
      PH.xml_change_send_date,
      PH.global_agreement_flag,
      PH.consigned_consumption_flag,
      PH.cbc_accounting_date,
      PH.consume_req_demand_flag,
      PH.change_requested_by,
      PH.shipping_control,
      PH.conterms_exist_flag,
      PH.conterms_articles_upd_date,
      PH.conterms_deliv_upd_date,
      PH.encumbrance_required_flag,
      PH.pending_signature_flag,
      PH.change_summary,
      PH.document_creation_method,
      PH.submit_date,
      PH.supplier_notif_method,
      PH.fax,
      PH.email_address,
      PH.retro_price_comm_updates_flag,
      PH.retro_price_apply_updates_flag,
      PH.update_sourcing_rules_flag,
      PH.auto_sourcing_flag,
      PH.created_language,
      PH.cpa_reference,
      PH.style_id,
      PH.tax_attribute_update_code, -- <ETAX INTEGRATION R12>
      PH.pay_when_paid, -- E and C ER
	    PH.ame_approval_id, -- PO AME Approval Workflow changes
      PH.ame_transaction_type, -- PO AME Approval Workflow changes
      PH.enable_all_sites --ER 9824167
    )
    VALUES
    (
      PHDV.po_header_id,
      PHDV.agent_id,
      PHDV.type_lookup_code,
      PHDV.last_update_date,
      PHDV.last_updated_by,
      PHDV.segment1,
      PHDV.summary_flag,
      PHDV.enabled_flag,
      PHDV.segment2,
      PHDV.segment3,
      PHDV.segment4,
      PHDV.segment5,
      PHDV.start_date_active,
      PHDV.end_date_active,
      PHDV.last_update_login,
      PHDV.creation_date,
      PHDV.created_by,
      PHDV.vendor_id,
      PHDV.vendor_site_id,
      PHDV.vendor_contact_id,
      PHDV.ship_to_location_id,
      PHDV.bill_to_location_id,
      PHDV.terms_id,
      PHDV.ship_via_lookup_code,
      PHDV.fob_lookup_code,
      PHDV.freight_terms_lookup_code,
      PHDV.status_lookup_code,
      PHDV.currency_code,
      PHDV.rate_type,
      PHDV.rate_date,
      PHDV.rate,
      PHDV.from_header_id,
      PHDV.from_type_lookup_code,
      PHDV.start_date,
      PHDV.end_date,
      PHDV.blanket_total_amount,
      PHDV.authorization_status,
      PHDV.revision_num,
      PHDV.revised_date,
      PHDV.approved_flag,
      PHDV.approved_date,
      PHDV.amount_limit,
      PHDV.min_release_amount,
      PHDV.note_to_authorizer,
      PHDV.note_to_vendor,
      PHDV.note_to_receiver,
      PHDV.print_count,
      PHDV.printed_date,
      PHDV.vendor_order_num,
      PHDV.confirming_order_flag,
      PHDV.comments,
      PHDV.reply_date,
      PHDV.reply_method_lookup_code,
      PHDV.rfq_close_date,
      PHDV.quote_type_lookup_code,
      PHDV.quotation_class_code,
      PHDV.quote_warning_delay_unit,
      PHDV.quote_warning_delay,
      PHDV.quote_vendor_quote_number,
      PHDV.acceptance_required_flag,
      PHDV.acceptance_due_date,
      PHDV.closed_date,
      PHDV.user_hold_flag,
      PHDV.approval_required_flag,
      PHDV.cancel_flag,
      PHDV.firm_status_lookup_code,
      PHDV.firm_date,
      PHDV.frozen_flag,
      PHDV.supply_agreement_flag,
      PHDV.edi_processed_flag,
      PHDV.edi_processed_status,
      PHDV.attribute_category,
      PHDV.attribute1,
      PHDV.attribute2,
      PHDV.attribute3,
      PHDV.attribute4,
      PHDV.attribute5,
      PHDV.attribute6,
      PHDV.attribute7,
      PHDV.attribute8,
      PHDV.attribute9,
      PHDV.attribute10,
      PHDV.attribute11,
      PHDV.attribute12,
      PHDV.attribute13,
      PHDV.attribute14,
      PHDV.attribute15,
      PHDV.closed_code,
      PHDV.ussgl_transaction_code,
      PHDV.government_context,
      PHDV.request_id,
      PHDV.program_application_id,
      PHDV.program_id,
      PHDV.program_update_date,
      PHDV.org_id,
      PHDV.global_attribute_category,
      PHDV.global_attribute1,
      PHDV.global_attribute2,
      PHDV.global_attribute3,
      PHDV.global_attribute4,
      PHDV.global_attribute5,
      PHDV.global_attribute6,
      PHDV.global_attribute7,
      PHDV.global_attribute8,
      PHDV.global_attribute9,
      PHDV.global_attribute10,
      PHDV.global_attribute11,
      PHDV.global_attribute12,
      PHDV.global_attribute13,
      PHDV.global_attribute14,
      PHDV.global_attribute15,
      PHDV.global_attribute16,
      PHDV.global_attribute17,
      PHDV.global_attribute18,
      PHDV.global_attribute19,
      PHDV.global_attribute20,
      PHDV.interface_source_code,
      PHDV.reference_num,
      PHDV.wf_item_type,
      PHDV.wf_item_key,
      PHDV.mrc_rate_type,
      PHDV.mrc_rate_date,
      PHDV.mrc_rate,
      PHDV.pcard_id,
      PHDV.price_update_tolerance,
      PHDV.pay_on_code,
      PHDV.xml_flag,
      PHDV.xml_send_date,
      PHDV.xml_change_send_date,
      PHDV.global_agreement_flag,
      PHDV.consigned_consumption_flag,
      PHDV.cbc_accounting_date,
      PHDV.consume_req_demand_flag,
      PHDV.change_requested_by,
      PHDV.shipping_control,
      PHDV.conterms_exist_flag,
      PHDV.conterms_articles_upd_date,
      PHDV.conterms_deliv_upd_date,
      PHDV.encumbrance_required_flag,
      PHDV.pending_signature_flag,
      PHDV.change_summary,
      PHDV.document_creation_method,
      PHDV.submit_date,
      PHDV.supplier_notif_method,
      PHDV.fax,
      PHDV.email_address,
      PHDV.retro_price_comm_updates_flag,
      PHDV.retro_price_apply_updates_flag,
      PHDV.update_sourcing_rules_flag,
      PHDV.auto_sourcing_flag,
      PHDV.created_language,
      PHDV.cpa_reference,
      PHDV.style_id,
      PHDV.tax_attribute_update_code, -- <ETAX INTEGRATION R12>
      PHDV.pay_when_paid, -- E and C ER
  	  PHDV.ame_approval_id, -- PO AME Approval Workflow changes
      PHDV.ame_transaction_type, -- PO AME Approval Workflow changes
      PHDV.enable_all_sites --ER 9824167
    ) WHERE NVL(PHDV.delete_flag, 'N') <> 'Y';

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
--p_po_header_id
--  id for po header record
--p_draft_id
--  draft unique identifier
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_draft_record
( p_po_header_id IN NUMBER,
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
  FROM po_headers_draft_all
  WHERE po_header_id = p_po_header_id
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
--p_po_header_id
--  id for po header record
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_transaction_record
( p_po_header_id IN NUMBER
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
  FROM po_headers_all
  WHERE po_header_id = p_po_header_id
  FOR UPDATE NOWAIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END lock_transaction_record;

END PO_HEADERS_DRAFT_PKG;

/
