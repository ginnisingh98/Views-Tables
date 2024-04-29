--------------------------------------------------------
--  DDL for Package Body PO_R12_CAT_UPG_FINAL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_R12_CAT_UPG_FINAL_GRP" AS
/* $Header: PO_R12_CAT_UPG_FINAL_GRP.plb 120.13 2006/08/18 22:32:19 pthapliy noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_R12_CAT_UPG_FINAL_GRP';
g_module_prefix CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';

g_debug BOOLEAN := PO_R12_CAT_UPG_DEBUG.is_logging_enabled;
g_err_num NUMBER := PO_R12_CAT_UPG_PVT.g_application_err_num;

-- BEGIN: Forward function declarations

PROCEDURE create_action_history_batch
(
  p_po_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  p_agent_ids     PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
);

PROCEDURE archive_gbpa_bulk
(
  p_batch_size NUMBER,
  p_po_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
);

-- END: Forward function declarations

--------------------------------------------------------------------------------
--Start of Comments
--Name: R12_upgrade_processing
--Pre-reqs:
--  The iP catalog data has been migrated to PO Transaction tables.
--Modifies:
--  a) PO Transaction and Archive Tables
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  * An entry in Action History is created.
--  * Document is encumbered if the Org has encumbrance enabled.
--  * Archival
--  * Document Numbers are assigned to the Transaction and Archive tables.
--  * Finally, document status is changed from 'IN PROCESS' to 'APPROVED'.
--
--  This API would commit data per document. The reason why we need this is
--  because in cae of exceptions, we want to rollback the transaction for just
--  that one document that is being processed, not all the documents.
--
--  This API should be called after the upgrade phase and during the final upgrade only.
--Parameters:
--p_api_version
--  Apps API Std  - To control correct version in use
--p_commit
--  Apps API Std - Should data be committed?
--p_init_msg_list
--  Apps API Std - Initialize the message list?
--p_validation_level
--  Apps API Std - Level of validations to be done
--p_log_level
--  Specifies the level for which logging is enabled.
--p_batch_size
--  The maximum number of rows that should be processed at a time, to avoid
--  exceeding rollback segment. The transaction would be committed after
--  processing each batch.
--OUT:
--x_return_status
-- Apps API Std
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_error - if an error occurred
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_msg_count
-- Apps API Std
-- The number of error messages returned in the FND error stack in case
-- x_return_status returned FND_API.G_RET_STS_ERROR or
-- FND_API.G_RET_STS_UNEXP_ERROR
--x_msg_data
-- Apps API Std
--  Contains error msg in case x_return_status returned FND_API.G_RET_STS_ERROR
--  or FND_API.G_RET_STS_UNEXP_ERROR
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE R12_upgrade_processing
(
   p_api_version      IN NUMBER
,  p_commit           IN VARCHAR2 default FND_API.G_FALSE
,  p_init_msg_list    IN VARCHAR2 default FND_API.G_FALSE
,  p_validation_level IN NUMBER default FND_API.G_VALID_LEVEL_FULL
,  p_log_level        IN NUMBER default 1
,  p_start_rowid      IN rowid default NULL --Bug#5156673
,  p_end_rowid        IN rowid default NULL --Bug#5156673
,  p_batch_size       IN NUMBER default 2500
,  x_return_status    OUT NOCOPY VARCHAR2
,  x_msg_count        OUT NOCOPY NUMBER
,  x_msg_data         OUT NOCOPY VARCHAR2
,  x_rows_processed   OUT NOCOPY NUMBER      --Bug#5156673
)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'R12_upgrade_processing';
  l_api_version CONSTANT NUMBER := 1.0;
  l_module      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress    VARCHAR2(3) := '000';

  -- SQL What: Cursor to fetch all the GBPA's created by the migration program.
  -- SQL Why : To perform post upgrade processing on these GBPA's
  -- SQL Join: created_by, authorization_status
  CURSOR transferred_gbpas_csr(l_start_rowid rowid, l_end_rowid rowid) IS
    SELECT POH.po_header_id
         , POH.agent_id
         , POH.org_id
      FROM PO_HEADERS_ALL POH
     WHERE POH.created_by = PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER
       AND POH.authorization_status = 'IN PROCESS'
       AND POH.rowid between l_start_rowid and l_end_rowid; --Bug#5156673

  l_po_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_org_ids       PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_agent_ids     PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_key           PO_SESSION_GT.key%TYPE;
  l_current_batch NUMBER; -- Bug 5468308: Track the progress of the script
BEGIN
  l_progress := '010';

  -- Set logging options
  PO_R12_CAT_UPG_DEBUG.set_logging_options(p_log_level => p_log_level);
  g_debug := PO_R12_CAT_UPG_DEBUG.is_logging_enabled;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'START'); END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.compatible_API_call(
                        p_current_version_number => l_api_version,
                        p_caller_version_number  => p_api_version,
                        p_api_name               => l_api_name,
                        p_pkg_name               => g_pkg_name)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '020';
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  l_progress := '030';
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;

  l_progress := '020';

  OPEN transferred_gbpas_csr(p_start_rowid, p_end_rowid); --Bug#5156673

  l_progress := '020';
  l_current_batch := 0;
  LOOP
    l_current_batch := l_current_batch + 1;
    BEGIN -- block to handle SNAPSHOT_TOO_OLD exception
      l_progress := '025';
      -- Bug 5468308: Adding FND log messages at Unexpected level.
      IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_module||'.'||l_progress,
        'current_batch='||l_current_batch);
      END IF;

      FETCH transferred_gbpas_csr
      BULK COLLECT INTO l_po_header_ids, l_agent_ids, l_org_ids;
--      LIMIT p_batch_size; --Bug#5156673: no need of batchsize

      l_progress := '030';

      EXIT WHEN l_po_header_ids.COUNT = 0;

      l_progress := '050';
      -- Create the Action History for the headers
      create_action_history_batch
      (
        p_po_header_ids => l_po_header_ids,
        p_agent_ids     => l_agent_ids
      );

      l_progress := '060';
      -- Call the procedure to archive the newly created GBPA's
      -- The batch_size is required in this procedure because each header could
      -- have multiple lines and so when archivung the lines, we need to loop
      -- with the same batch_size.
      archive_gbpa_bulk
      (
        p_batch_size    => p_batch_size,
        p_po_header_ids => l_po_header_ids
      );

      l_progress := '090';
      -- SQL What: Update status of GBPA Headers.
      -- SQL Why : Bulk update the status to APPROVED for the new GBPA's created
      --           by the migration program.
      -- SQL Join: po_header_id
      FORALL i IN 1.. l_po_header_ids.COUNT
        UPDATE PO_HEADERS_ALL GBPA
        SET
                  -- Set it to APPROVED if there is no CPA_REFERENCE,
                  -- Else, if the status on the CPA is APPROVED, then
                  -- set it to APPROVED. If the status on CPA is anything
                  -- other than APPROVED, then set the status of the new
                  -- GBAP as INCOMPLETE.
            authorization_status =
                  DECODE
                  (GBPA.cpa_reference,
                   NULL, 'APPROVED',
                   -- else
                   (SELECT DECODE
                            (CPA.authorization_status,
                             'APPROVED', 'APPROVED',
                             -- else
                             'INCOMPLETE')
                       FROM PO_HEADERS_ALL CPA
                      WHERE CPA.po_header_id = GBPA.cpa_reference)),
            GBPA.approved_flag = 'Y',
            GBPA.approved_date = sysdate,
            GBPA.last_update_date = sysdate,
            GBPA.last_updated_by = FND_GLOBAL.user_id,
            GBPA.last_update_login = FND_GLOBAL.login_id,
            GBPA.cat_admin_auth_enabled_flag = 'Y' -- Part of ECO bug 4554461
        WHERE po_header_id = l_po_header_ids(i);

      x_rows_processed := SQL%rowcount; --Bug#5156673 --TBD: What is the impact due to the loop ; mutiple loops doing multiple updates; x_rows_processed will not be the total rows proecssed by this worked then ?

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'Number of rows of PO_HEADERS_ALL updated='||SQL%rowcount); END IF;

      l_progress := '110';
      -- SQL What: Bulk update the PO Number on the Archive table (there would
      --           be only 1 revision = 0, for the newly created GBPA's)
      -- SQL Why : PO Number on Archive table and Txn table should be same.
      -- SQL Join: po_header_id, revision_num
      FORALL i IN 1.. l_po_header_ids.COUNT
        UPDATE PO_HEADERS_ARCHIVE_ALL
        SET authorization_status = 'APPROVED',
            approved_flag = 'Y',
            approved_date = sysdate,
            last_update_date = sysdate,
            last_updated_by = FND_GLOBAL.user_id,
            last_update_login = FND_GLOBAL.login_id
        WHERE po_header_id = l_po_header_ids(i)
          AND revision_num = 0;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'Number of rows of PO_HEADERS_ARCHIVE_ALL updated='||SQL%rowcount); END IF;

      l_progress := '110';
      IF (l_po_header_ids.COUNT < p_batch_size) THEN
        EXIT;
      END IF;

      l_progress := '120';
      COMMIT;
    EXCEPTION
      WHEN g_SNAPSHOT_TOO_OLD THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'EXCEPTION: SNAPSHOT_TOO_OLD. Now commiting and re-opening the transferred_gbpas_csr'); END IF;

        -- Commit and re-open the cursor
        l_progress := '080';
        COMMIT;

        l_progress := '090';
        CLOSE transferred_gbpas_csr;

        l_progress := '100';
        OPEN transferred_gbpas_csr(p_start_rowid, p_end_rowid); --Bug#5156673
        l_progress := '110';
      END; -- block to handle SNAPSHOT_TOO_OLD exception
  END LOOP; -- Main cursor batch loop

  l_progress := '140';
  IF (transferred_gbpas_csr%ISOPEN) THEN
    CLOSE transferred_gbpas_csr;
  END IF;

  -- Insert GBPA numbers in the referenced CPA's as a long text attachment
  -- Bug#5156673 : Not ad_parallelizing the rest of the code - as it
  -- has a sort of group by logic for the attachments: order by and checks for current vs previous value.

--  attach_gbpa_numbers_in_cpa;

  l_progress := '150';
  -- Standard check of p_commit.
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  l_progress := '160';
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data );

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
  BEGIN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'OTHERS Start'); END IF;
    IF (transferred_gbpas_csr%ISOPEN) THEN
      CLOSE transferred_gbpas_csr;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'x_return_status='||x_return_status); END IF;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name,SQLERRM);
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data );

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'OTHERS End'); END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL; -- If exception occurs inside the outer exception handling block, ignore it.
    END;
END R12_upgrade_processing;

--------------------------------------------------------------------------------
--Start of Comments
--Name: create_action_history_batch
--Pre-reqs:
--  The iP catalog data has been migrated to PO Transaction tables.
--Modifies:
--  a) PO Archive Tables for Action History
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  This procedure create the Action History of the GBPA's created as part of
--  the unified catalog migration.
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_po_header_ids
--  A pl/sql table of po_header_id's that need to be archived.
--p_po_header_ids
--  A pl/sql table of agent_id's correspong to each header.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE create_action_history_batch
(
  p_po_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  p_agent_ids     PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'create_action_history_batch';
  l_log_head CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF (p_po_header_ids.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_po_header_ids(1)='||p_po_header_ids(1)); END IF;
  END IF;

  IF (p_agent_ids.COUNT > 0) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_agent_ids(1)='||p_agent_ids(1)); END IF;
  END IF;

  -- SQL What: Bulk insert into Action History
  -- SQL Why : To create action history for the new GBPA's
  -- SQL Join: object_id, object_type_code
  FORALL i IN 1.. p_po_header_ids.COUNT
    INSERT INTO PO_ACTION_HISTORY
         (object_id,
          object_type_code,
          object_sub_type_code,
          sequence_num,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          action_code,
          action_date,
          employee_id,
          approval_path_id,
          note,
          object_revision_num,
          offline_code,
          last_update_login,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          program_date
         )
    SELECT
          p_po_header_ids(i),                    -- object_id
          'PA',                                  -- object_type_code
          'BLANKET',                             -- object_sub_type_code
          1,                                     -- sequence_num
          sysdate,                               -- last_update_date
          FND_GLOBAL.user_id,                    -- last_updated_by
          sysdate,                               -- creation_date
          PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER, -- created_by = -12
          'APPROVE',                             -- action_code
          sysdate,                               -- action_date
          p_agent_ids(i),                        -- employee_id
          NULL,                                  -- approval_path_id
          NULL,                                  -- note
          0,                                     -- object_revision_num
          NULL,                                  -- offline_code
          FND_GLOBAL.login_id,                   -- last_update_login
          FND_GLOBAL.conc_request_id,            -- request_id
          NULL,                                  -- program_application_id
          NULL,                                  -- program_id
          NULL,                                  -- program_update_date
          NULL                                   -- program_date
    FROM DUAL
    WHERE NOT EXISTS
           (SELECT 'Action History Record alreday exists'
            FROM PO_ACTION_HISTORY POAH
            WHERE POAH.object_id = p_po_header_ids(i)
            AND   POAH.object_type_code = 'PA'
            AND   POAH.object_sub_type_code = 'BLANKET');

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of action history records inserted='||SQL%rowcount); END IF;

  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END create_action_history_batch;

--------------------------------------------------------------------------------
--Start of Comments
--Name: archive_gbpa_bulk
--Pre-reqs:
--  The iP catalog data has been migrated to PO Transaction tables.
--Modifies:
--  a) PO Archive Tables
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  This procedure archives the GBPA's created as part of the unified catalog
--  migration. It archives the PO Header, Line, Attribute, TLP and
--  Org Assignment tables.
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_batch_size
--  The maximum number of rows that should be processed at a time, to avoid
--  exceeding rollback segment. The transaction would be committed after
--  processing each batch.
--p_po_header_ids
--  A pl/sql table of po_header_id's that need to be archived.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE archive_gbpa_bulk
(
  p_batch_size NUMBER,
  p_po_header_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'archive_gbpa_bulk';
  l_log_head CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress VARCHAR2(3) := '000';

  l_po_line_ids PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_start_index NUMBER;
  l_end_index NUMBER;
  l_end_index_tmp NUMBER;
  l_last_batch_flag VARCHAR2(1);

  l_key PO_SESSION_GT.key%TYPE;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- SQL What: Insert into headers archive
  -- SQL Why : To archive the headers of the new GBPA's
  -- SQL Join: po_header_id
  FORALL i IN 1.. p_po_header_ids.COUNT
    INSERT INTO PO_HEADERS_ARCHIVE_ALL
     (
      acceptance_due_date,
      acceptance_required_flag,
      agent_id,
      amount_limit,
      approval_required_flag,
      approved_date,
      approved_flag,
      attribute1,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute_category,
      authorization_status,
      auto_sourcing_flag,
      bill_to_location_id,
      blanket_total_amount,
      cancel_flag,
      cbc_accounting_date,
      change_requested_by,
      change_summary,
      closed_code,
      closed_date,
      comments,
      confirming_order_flag,
      consigned_consumption_flag,
      consume_req_demand_flag,
      conterms_articles_upd_date,
      conterms_deliv_upd_date,
      conterms_exist_flag,
      cpa_reference,
      created_by,
      created_language,
      creation_date,
      currency_code,
      document_creation_method,
      edi_processed_flag,
      edi_processed_status,
      email_address,
      enabled_flag,
      encumbrance_required_flag,
      end_date,
      end_date_active,
      fax,
      firm_date,
      firm_status_lookup_code,
      fob_lookup_code,
      freight_terms_lookup_code,
      from_header_id,
      from_type_lookup_code,
      frozen_flag,
      global_agreement_flag,
      global_attribute1,
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
      global_attribute2,
      global_attribute20,
      global_attribute3,
      global_attribute4,
      global_attribute5,
      global_attribute6,
      global_attribute7,
      global_attribute8,
      global_attribute9,
      global_attribute_category,
      government_context,
      interface_source_code,
      last_update_date,
      last_update_login,
      last_updated_by,
      last_updated_program,
      min_release_amount,
      mrc_rate,
      mrc_rate_date,
      mrc_rate_type,
      note_to_authorizer,
      note_to_receiver,
      note_to_vendor,
      org_id,
      pay_on_code,
      pcard_id,
      pending_signature_flag,
      po_header_id,
      price_update_tolerance,
      print_count,
      printed_date,
      program_application_id,
      program_id,
      program_update_date,
      quotation_class_code,
      quote_type_lookup_code,
      quote_vendor_quote_number,
      quote_warning_delay,
      quote_warning_delay_unit,
      rate,
      rate_date,
      rate_type,
      reference_num,
      reply_date,
      reply_method_lookup_code,
      request_id,
      retro_price_apply_updates_flag,
      retro_price_comm_updates_flag,
      revised_date,
      revision_num,
      rfq_close_date,
      segment1,
      segment2,
      segment3,
      segment4,
      segment5,
      ship_to_location_id,
      ship_via_lookup_code,
      shipping_control,
      start_date,
      start_date_active,
      status_lookup_code,
      style_id,
      submit_date,
      summary_flag,
      supplier_auth_enabled_flag,
      supplier_notif_method,
      supply_agreement_flag,
      terms_id,
      type_lookup_code,
      update_sourcing_rules_flag,
      user_hold_flag,
      ussgl_transaction_code,
      vendor_contact_id,
      vendor_id,
      vendor_order_num,
      vendor_site_id,
      wf_item_key,
      wf_item_type,
      xml_change_send_date,
      xml_flag,
      xml_send_date,
      ever_approved_flag,    -- Not present in txn table
      latest_external_flag,  -- Not present in txn table
      standard_comment_code  -- Not present in txn table
     )
    SELECT
      acceptance_due_date,
      acceptance_required_flag,
      agent_id,
      amount_limit,
      approval_required_flag,
      approved_date,
      approved_flag,
      attribute1,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute_category,
      authorization_status,
      auto_sourcing_flag,
      bill_to_location_id,
      blanket_total_amount,
      cancel_flag,
      cbc_accounting_date,
      change_requested_by,
      change_summary,
      closed_code,
      closed_date,
      comments,
      confirming_order_flag,
      consigned_consumption_flag,
      consume_req_demand_flag,
      conterms_articles_upd_date,
      conterms_deliv_upd_date,
      conterms_exist_flag,
      cpa_reference,
      created_by,
      created_language,
      creation_date,
      currency_code,
      document_creation_method,
      edi_processed_flag,
      edi_processed_status,
      email_address,
      enabled_flag,
      encumbrance_required_flag,
      end_date,
      end_date_active,
      fax,
      firm_date,
      firm_status_lookup_code,
      fob_lookup_code,
      freight_terms_lookup_code,
      from_header_id,
      from_type_lookup_code,
      frozen_flag,
      global_agreement_flag,
      global_attribute1,
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
      global_attribute2,
      global_attribute20,
      global_attribute3,
      global_attribute4,
      global_attribute5,
      global_attribute6,
      global_attribute7,
      global_attribute8,
      global_attribute9,
      global_attribute_category,
      government_context,
      interface_source_code,
      last_update_date,
      last_update_login,
      last_updated_by,
      last_updated_program,
      min_release_amount,
      mrc_rate,
      mrc_rate_date,
      mrc_rate_type,
      note_to_authorizer,
      note_to_receiver,
      note_to_vendor,
      org_id,
      pay_on_code,
      pcard_id,
      pending_signature_flag,
      po_header_id,
      price_update_tolerance,
      print_count,
      printed_date,
      program_application_id,
      program_id,
      program_update_date,
      quotation_class_code,
      quote_type_lookup_code,
      quote_vendor_quote_number,
      quote_warning_delay,
      quote_warning_delay_unit,
      rate,
      rate_date,
      rate_type,
      reference_num,
      reply_date,
      reply_method_lookup_code,
      request_id,
      retro_price_apply_updates_flag,
      retro_price_comm_updates_flag,
      revised_date,
      revision_num,
      rfq_close_date,
      segment1,
      segment2,
      segment3,
      segment4,
      segment5,
      ship_to_location_id,
      ship_via_lookup_code,
      shipping_control,
      start_date,
      start_date_active,
      status_lookup_code,
      style_id,
      submit_date,
      summary_flag,
      supplier_auth_enabled_flag,
      supplier_notif_method,
      supply_agreement_flag,
      terms_id,
      type_lookup_code,
      update_sourcing_rules_flag,
      user_hold_flag,
      ussgl_transaction_code,
      vendor_contact_id,
      vendor_id,
      vendor_order_num,
      vendor_site_id,
      wf_item_key,
      wf_item_type,
      xml_change_send_date,
      xml_flag,
      xml_send_date,
      'Y', -- ever_approved_flag,    -- Not present in txn table
      'Y', -- latest_external_flag,  -- Not present in txn table
      NULL -- standard_comment_code  -- Not present in txn table
    FROM PO_HEADERS_ALL
    WHERE po_header_id = p_po_header_ids(i)
      AND NOT EXISTS
               (SELECT 'Archive record for Header already exists'
                FROM PO_HEADERS_ARCHIVE_ALL POHA2
                WHERE POHA2.po_header_id = p_po_header_ids(i));

  l_progress := '020';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of header archive records inserted='||SQL%rowcount); END IF;

  -- Similarly, bulk insert into lines, attributes, TLP and org_assignment archives

  -- SQL What: Pick a new key from session GT sequence .
  -- SQL Why : To get po_line_id's
  -- SQL Join: none
  SELECT PO_SESSION_GT_S.nextval
  INTO l_key
  FROM DUAL;

  l_progress := '030';
  -- SQL What: Get all the line id's for the given set of header id's
  -- SQL Why : To archive the GBPA lines.
  -- SQL Join: po_header_id
  FORALL i IN 1 .. p_po_header_ids.COUNT
    INSERT INTO PO_SESSION_GT(key, num1)
    SELECT l_key,
           po_line_id
    FROM PO_LINES_ALL
    WHERE po_header_id = p_po_header_ids(i);

  l_progress := '040';
  -- SQL What: Transfer from session GT table to local array
  -- SQL Why : The po_lie_id's are requied for archival of lines
  -- SQL Join: key
  DELETE FROM PO_SESSION_GT
  WHERE  key = l_key
  RETURNING num1
  BULK COLLECT INTO l_po_line_ids;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of lines='||l_po_line_ids.COUNT); END IF;

  -- Archive the lines in batches
  l_start_index := 1;
  l_end_index := p_batch_size;
  l_last_batch_flag := 'N';

  l_progress := '060';
  IF (l_po_line_ids.COUNT <= p_batch_size) THEN
    l_end_index := l_po_line_ids.COUNT;
    l_last_batch_flag := 'Y';
  END IF;

  l_progress := '070';
  -- Archive lines
  LOOP
    l_progress := '080';

    -- SQL What: Insert data into PO_LINES_ARCHIVE_ALL
    -- SQL Why : To archive GBPA lines
    -- SQL Join: po_line_id
    FORALL i IN l_start_index .. l_end_index
      INSERT INTO PO_LINES_ARCHIVE_ALL
       (
         allow_price_override_flag,
         attribute1,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute_category,
         auction_display_number,
         auction_header_id,
         auction_line_number,
         base_qty,
         base_uom,
         bid_line_number,
         bid_number,
         cancel_date,
         cancel_flag,
         cancel_reason,
         cancelled_by,
         capital_expense_flag,
         catalog_name,
         category_id,
         closed_by,
         closed_code,
         closed_date,
         closed_flag,
         closed_reason,
         committed_amount,
         contract_num,
         created_by,
         creation_date,
         expiration_date,
         firm_date,
         firm_status_lookup_code,
         from_header_id,
         from_line_id,
         global_attribute1,
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
         global_attribute2,
         global_attribute20,
         global_attribute3,
         global_attribute4,
         global_attribute5,
         global_attribute6,
         global_attribute7,
         global_attribute8,
         global_attribute9,
         global_attribute_category,
         government_context,
         hazard_class_id,
         ip_category_id,
         item_description,
         item_id,
         item_revision,
         last_update_date,
         last_update_login,
         last_updated_by,
         last_updated_program,
         line_num,
         line_reference_num,
         line_type_id,
         list_price_per_unit,
         --manual_price_change_flag, Not present in archive table
         market_price,
         max_order_quantity,
         min_order_quantity,
         min_release_amount,
         negotiated_by_preparer_flag,
         not_to_exceed_price,
         note_to_vendor,
         --oke_contract_header_id, Not present in archive table
         --oke_contract_version_id, Not present in archive table
         org_id,
         over_tolerance_error_flag,
         po_header_id,
         po_line_id,
         preferred_grade,
         price_break_lookup_code,
         price_type_lookup_code,
         program_application_id,
         program_id,
         program_update_date,
         project_id,
         qc_grade,
         qty_rcv_tolerance,
         quantity,
         quantity_committed,
         reference_num,
         request_id,
         --retroactive_date, Not present in archive table
         secondary_qty,
         secondary_quantity,
         secondary_unit_of_measure,
         secondary_uom,
         supplier_part_auxid,
         task_id,
         tax_code_id,
         tax_name,
         taxable_flag,
         transaction_reason_code,
         type_1099,
         un_number_id,
         unit_meas_lookup_code,
         unit_price,
         unordered_flag,
         user_hold_flag,
         ussgl_transaction_code,
         vendor_product_num,
         --advance_amount, Not present in archive table
         amount,
         base_unit_price,
         contract_id,
         contractor_first_name,
         contractor_last_name,
         --from_line_location_id, Not present in archive table
         job_id,
         matching_basis,
         max_retainage_amount,
         order_type_lookup_code,
         progress_payment_rate,
         purchase_basis,
         recoupment_rate,
         retainage_rate,
         start_date,
         supplier_ref_number,
         svc_amount_notif_sent,
         svc_completion_notif_sent,
         latest_external_flag,
         revision_num
       )
      SELECT
         allow_price_override_flag,
         attribute1,
         attribute10,
         attribute11,
         attribute12,
         attribute13,
         attribute14,
         attribute15,
         attribute2,
         attribute3,
         attribute4,
         attribute5,
         attribute6,
         attribute7,
         attribute8,
         attribute9,
         attribute_category,
         auction_display_number,
         auction_header_id,
         auction_line_number,
         base_qty,
         base_uom,
         bid_line_number,
         bid_number,
         cancel_date,
         cancel_flag,
         cancel_reason,
         cancelled_by,
         capital_expense_flag,
         catalog_name,
         category_id,
         closed_by,
         closed_code,
         closed_date,
         closed_flag,
         closed_reason,
         committed_amount,
         contract_num,
         created_by,
         creation_date,
         expiration_date,
         firm_date,
         firm_status_lookup_code,
         from_header_id,
         from_line_id,
         global_attribute1,
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
         global_attribute2,
         global_attribute20,
         global_attribute3,
         global_attribute4,
         global_attribute5,
         global_attribute6,
         global_attribute7,
         global_attribute8,
         global_attribute9,
         global_attribute_category,
         government_context,
         hazard_class_id,
         ip_category_id,
         item_description,
         item_id,
         item_revision,
         last_update_date,
         last_update_login,
         last_updated_by,
         last_updated_program,
         line_num,
         line_reference_num,
         line_type_id,
         list_price_per_unit,
         --manual_price_change_flag, Not present in archive table
         market_price,
         max_order_quantity,
         min_order_quantity,
         min_release_amount,
         negotiated_by_preparer_flag,
         not_to_exceed_price,
         note_to_vendor,
         --oke_contract_header_id, Not present in archive table
         --oke_contract_version_id, Not present in archive table
         org_id,
         over_tolerance_error_flag,
         po_header_id,
         po_line_id,
         preferred_grade,
         price_break_lookup_code,
         price_type_lookup_code,
         program_application_id,
         program_id,
         program_update_date,
         project_id,
         qc_grade,
         qty_rcv_tolerance,
         quantity,
         quantity_committed,
         reference_num,
         request_id,
         -- retroactive_date, Not present in archive table
         secondary_qty,
         secondary_quantity,
         secondary_unit_of_measure,
         secondary_uom,
         supplier_part_auxid,
         task_id,
         tax_code_id,
         tax_name,
         taxable_flag,
         transaction_reason_code,
         type_1099,
         un_number_id,
         unit_meas_lookup_code,
         unit_price,
         unordered_flag,
         user_hold_flag,
         ussgl_transaction_code,
         vendor_product_num,
         --advance_amount, Not present in archive table
         amount,
         base_unit_price,
         contract_id,
         contractor_first_name,
         contractor_last_name,
         --from_line_location_id, Not present in archive table
         job_id,
         matching_basis,
         max_retainage_amount,
         order_type_lookup_code,
         progress_payment_rate,
         purchase_basis,
         recoupment_rate,
         retainage_rate,
         start_date,
         supplier_ref_number,
         svc_amount_notif_sent,
         svc_completion_notif_sent,
         'Y', -- latest_external_flag
         0 -- revision_num
      FROM PO_LINES_ALL POL
      WHERE POL.po_line_id = l_po_line_ids(i)
        AND NOT EXISTS
               (SELECT 'Archive record for Line already exists'
                FROM PO_LINES_ARCHIVE_ALL POLA2
                WHERE POLA2.po_line_id = l_po_line_ids(i));

    l_progress := '090';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of line archive records inserted='||SQL%rowcount); END IF;

    EXIT WHEN (l_last_batch_flag = 'Y');

    l_start_index := l_start_index + p_batch_size;
    l_end_index_tmp := l_end_index + p_batch_size;

    l_progress := '100';
    IF (l_end_index_tmp >= l_po_line_ids.COUNT) THEN
      l_end_index_tmp := l_po_line_ids.COUNT;
      l_last_batch_flag := 'Y';
    END IF;

    l_end_index := l_end_index_tmp;

    l_progress := '110';
  END LOOP; -- archive lines

  l_progress := '120';
  -- Archive the attribute_values in batches
  l_start_index := 1;
  l_end_index := p_batch_size;
  l_last_batch_flag := 'N';

  IF (l_po_line_ids.COUNT <= p_batch_size) THEN
    l_end_index := l_po_line_ids.COUNT;
    l_last_batch_flag := 'Y';
  END IF;

  l_progress := '130';
  -- Archive attribute_values
  LOOP
    l_progress := '140';

    -- SQL What: Insert data into PO_ATTR_VALUES_ARCHIVE
    -- SQL Why : To archive Attr values
    -- SQL Join: po_line_id
    FORALL i IN l_start_index .. l_end_index
      INSERT INTO PO_ATTR_VALUES_ARCHIVE
       (
         attribute_values_id,
         revision_num,
         po_line_id,
         req_template_name,
         req_template_line_num,
         ip_category_id,
         inventory_item_id,
         org_id,
         manufacturer_part_num,
         thumbnail_image,
         supplier_url,
         manufacturer_url,
         attachment_url,
         unspsc,
         availability,
         lead_time,
         text_base_attribute1,
         text_base_attribute2,
         text_base_attribute3,
         text_base_attribute4,
         text_base_attribute5,
         text_base_attribute6,
         text_base_attribute7,
         text_base_attribute8,
         text_base_attribute9,
         text_base_attribute10,
         text_base_attribute11,
         text_base_attribute12,
         text_base_attribute13,
         text_base_attribute14,
         text_base_attribute15,
         text_base_attribute16,
         text_base_attribute17,
         text_base_attribute18,
         text_base_attribute19,
         text_base_attribute20,
         text_base_attribute21,
         text_base_attribute22,
         text_base_attribute23,
         text_base_attribute24,
         text_base_attribute25,
         text_base_attribute26,
         text_base_attribute27,
         text_base_attribute28,
         text_base_attribute29,
         text_base_attribute30,
         text_base_attribute31,
         text_base_attribute32,
         text_base_attribute33,
         text_base_attribute34,
         text_base_attribute35,
         text_base_attribute36,
         text_base_attribute37,
         text_base_attribute38,
         text_base_attribute39,
         text_base_attribute40,
         text_base_attribute41,
         text_base_attribute42,
         text_base_attribute43,
         text_base_attribute44,
         text_base_attribute45,
         text_base_attribute46,
         text_base_attribute47,
         text_base_attribute48,
         text_base_attribute49,
         text_base_attribute50,
         text_base_attribute51,
         text_base_attribute52,
         text_base_attribute53,
         text_base_attribute54,
         text_base_attribute55,
         text_base_attribute56,
         text_base_attribute57,
         text_base_attribute58,
         text_base_attribute59,
         text_base_attribute60,
         text_base_attribute61,
         text_base_attribute62,
         text_base_attribute63,
         text_base_attribute64,
         text_base_attribute65,
         text_base_attribute66,
         text_base_attribute67,
         text_base_attribute68,
         text_base_attribute69,
         text_base_attribute70,
         text_base_attribute71,
         text_base_attribute72,
         text_base_attribute73,
         text_base_attribute74,
         text_base_attribute75,
         text_base_attribute76,
         text_base_attribute77,
         text_base_attribute78,
         text_base_attribute79,
         text_base_attribute80,
         text_base_attribute81,
         text_base_attribute82,
         text_base_attribute83,
         text_base_attribute84,
         text_base_attribute85,
         text_base_attribute86,
         text_base_attribute87,
         text_base_attribute88,
         text_base_attribute89,
         text_base_attribute90,
         text_base_attribute91,
         text_base_attribute92,
         text_base_attribute93,
         text_base_attribute94,
         text_base_attribute95,
         text_base_attribute96,
         text_base_attribute97,
         text_base_attribute98,
         text_base_attribute99,
         text_base_attribute100,
         num_base_attribute1,
         num_base_attribute2,
         num_base_attribute3,
         num_base_attribute4,
         num_base_attribute5,
         num_base_attribute6,
         num_base_attribute7,
         num_base_attribute8,
         num_base_attribute9,
         num_base_attribute10,
         num_base_attribute11,
         num_base_attribute12,
         num_base_attribute13,
         num_base_attribute14,
         num_base_attribute15,
         num_base_attribute16,
         num_base_attribute17,
         num_base_attribute18,
         num_base_attribute19,
         num_base_attribute20,
         num_base_attribute21,
         num_base_attribute22,
         num_base_attribute23,
         num_base_attribute24,
         num_base_attribute25,
         num_base_attribute26,
         num_base_attribute27,
         num_base_attribute28,
         num_base_attribute29,
         num_base_attribute30,
         num_base_attribute31,
         num_base_attribute32,
         num_base_attribute33,
         num_base_attribute34,
         num_base_attribute35,
         num_base_attribute36,
         num_base_attribute37,
         num_base_attribute38,
         num_base_attribute39,
         num_base_attribute40,
         num_base_attribute41,
         num_base_attribute42,
         num_base_attribute43,
         num_base_attribute44,
         num_base_attribute45,
         num_base_attribute46,
         num_base_attribute47,
         num_base_attribute48,
         num_base_attribute49,
         num_base_attribute50,
         num_base_attribute51,
         num_base_attribute52,
         num_base_attribute53,
         num_base_attribute54,
         num_base_attribute55,
         num_base_attribute56,
         num_base_attribute57,
         num_base_attribute58,
         num_base_attribute59,
         num_base_attribute60,
         num_base_attribute61,
         num_base_attribute62,
         num_base_attribute63,
         num_base_attribute64,
         num_base_attribute65,
         num_base_attribute66,
         num_base_attribute67,
         num_base_attribute68,
         num_base_attribute69,
         num_base_attribute70,
         num_base_attribute71,
         num_base_attribute72,
         num_base_attribute73,
         num_base_attribute74,
         num_base_attribute75,
         num_base_attribute76,
         num_base_attribute77,
         num_base_attribute78,
         num_base_attribute79,
         num_base_attribute80,
         num_base_attribute81,
         num_base_attribute82,
         num_base_attribute83,
         num_base_attribute84,
         num_base_attribute85,
         num_base_attribute86,
         num_base_attribute87,
         num_base_attribute88,
         num_base_attribute89,
         num_base_attribute90,
         num_base_attribute91,
         num_base_attribute92,
         num_base_attribute93,
         num_base_attribute94,
         num_base_attribute95,
         num_base_attribute96,
         num_base_attribute97,
         num_base_attribute98,
         num_base_attribute99,
         num_base_attribute100,
         text_cat_attribute1,
         text_cat_attribute2,
         text_cat_attribute3,
         text_cat_attribute4,
         text_cat_attribute5,
         text_cat_attribute6,
         text_cat_attribute7,
         text_cat_attribute8,
         text_cat_attribute9,
         text_cat_attribute10,
         text_cat_attribute11,
         text_cat_attribute12,
         text_cat_attribute13,
         text_cat_attribute14,
         text_cat_attribute15,
         text_cat_attribute16,
         text_cat_attribute17,
         text_cat_attribute18,
         text_cat_attribute19,
         text_cat_attribute20,
         text_cat_attribute21,
         text_cat_attribute22,
         text_cat_attribute23,
         text_cat_attribute24,
         text_cat_attribute25,
         text_cat_attribute26,
         text_cat_attribute27,
         text_cat_attribute28,
         text_cat_attribute29,
         text_cat_attribute30,
         text_cat_attribute31,
         text_cat_attribute32,
         text_cat_attribute33,
         text_cat_attribute34,
         text_cat_attribute35,
         text_cat_attribute36,
         text_cat_attribute37,
         text_cat_attribute38,
         text_cat_attribute39,
         text_cat_attribute40,
         text_cat_attribute41,
         text_cat_attribute42,
         text_cat_attribute43,
         text_cat_attribute44,
         text_cat_attribute45,
         text_cat_attribute46,
         text_cat_attribute47,
         text_cat_attribute48,
         text_cat_attribute49,
         text_cat_attribute50,
         num_cat_attribute1,
         num_cat_attribute2,
         num_cat_attribute3,
         num_cat_attribute4,
         num_cat_attribute5,
         num_cat_attribute6,
         num_cat_attribute7,
         num_cat_attribute8,
         num_cat_attribute9,
         num_cat_attribute10,
         num_cat_attribute11,
         num_cat_attribute12,
         num_cat_attribute13,
         num_cat_attribute14,
         num_cat_attribute15,
         num_cat_attribute16,
         num_cat_attribute17,
         num_cat_attribute18,
         num_cat_attribute19,
         num_cat_attribute20,
         num_cat_attribute21,
         num_cat_attribute22,
         num_cat_attribute23,
         num_cat_attribute24,
         num_cat_attribute25,
         num_cat_attribute26,
         num_cat_attribute27,
         num_cat_attribute28,
         num_cat_attribute29,
         num_cat_attribute30,
         num_cat_attribute31,
         num_cat_attribute32,
         num_cat_attribute33,
         num_cat_attribute34,
         num_cat_attribute35,
         num_cat_attribute36,
         num_cat_attribute37,
         num_cat_attribute38,
         num_cat_attribute39,
         num_cat_attribute40,
         num_cat_attribute41,
         num_cat_attribute42,
         num_cat_attribute43,
         num_cat_attribute44,
         num_cat_attribute45,
         num_cat_attribute46,
         num_cat_attribute47,
         num_cat_attribute48,
         num_cat_attribute49,
         num_cat_attribute50,
         last_update_login,
         last_updated_by,
         last_update_date,
         created_by,
         creation_date,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         last_updated_program,
         latest_external_flag
       )
      SELECT
         attribute_values_id,
         0, -- revision_num
         po_line_id,
         req_template_name,
         req_template_line_num,
         ip_category_id,
         inventory_item_id,
         org_id,
         manufacturer_part_num,
         thumbnail_image,
         supplier_url,
         manufacturer_url,
         attachment_url,
         unspsc,
         availability,
         lead_time,
         text_base_attribute1,
         text_base_attribute2,
         text_base_attribute3,
         text_base_attribute4,
         text_base_attribute5,
         text_base_attribute6,
         text_base_attribute7,
         text_base_attribute8,
         text_base_attribute9,
         text_base_attribute10,
         text_base_attribute11,
         text_base_attribute12,
         text_base_attribute13,
         text_base_attribute14,
         text_base_attribute15,
         text_base_attribute16,
         text_base_attribute17,
         text_base_attribute18,
         text_base_attribute19,
         text_base_attribute20,
         text_base_attribute21,
         text_base_attribute22,
         text_base_attribute23,
         text_base_attribute24,
         text_base_attribute25,
         text_base_attribute26,
         text_base_attribute27,
         text_base_attribute28,
         text_base_attribute29,
         text_base_attribute30,
         text_base_attribute31,
         text_base_attribute32,
         text_base_attribute33,
         text_base_attribute34,
         text_base_attribute35,
         text_base_attribute36,
         text_base_attribute37,
         text_base_attribute38,
         text_base_attribute39,
         text_base_attribute40,
         text_base_attribute41,
         text_base_attribute42,
         text_base_attribute43,
         text_base_attribute44,
         text_base_attribute45,
         text_base_attribute46,
         text_base_attribute47,
         text_base_attribute48,
         text_base_attribute49,
         text_base_attribute50,
         text_base_attribute51,
         text_base_attribute52,
         text_base_attribute53,
         text_base_attribute54,
         text_base_attribute55,
         text_base_attribute56,
         text_base_attribute57,
         text_base_attribute58,
         text_base_attribute59,
         text_base_attribute60,
         text_base_attribute61,
         text_base_attribute62,
         text_base_attribute63,
         text_base_attribute64,
         text_base_attribute65,
         text_base_attribute66,
         text_base_attribute67,
         text_base_attribute68,
         text_base_attribute69,
         text_base_attribute70,
         text_base_attribute71,
         text_base_attribute72,
         text_base_attribute73,
         text_base_attribute74,
         text_base_attribute75,
         text_base_attribute76,
         text_base_attribute77,
         text_base_attribute78,
         text_base_attribute79,
         text_base_attribute80,
         text_base_attribute81,
         text_base_attribute82,
         text_base_attribute83,
         text_base_attribute84,
         text_base_attribute85,
         text_base_attribute86,
         text_base_attribute87,
         text_base_attribute88,
         text_base_attribute89,
         text_base_attribute90,
         text_base_attribute91,
         text_base_attribute92,
         text_base_attribute93,
         text_base_attribute94,
         text_base_attribute95,
         text_base_attribute96,
         text_base_attribute97,
         text_base_attribute98,
         text_base_attribute99,
         text_base_attribute100,
         num_base_attribute1,
         num_base_attribute2,
         num_base_attribute3,
         num_base_attribute4,
         num_base_attribute5,
         num_base_attribute6,
         num_base_attribute7,
         num_base_attribute8,
         num_base_attribute9,
         num_base_attribute10,
         num_base_attribute11,
         num_base_attribute12,
         num_base_attribute13,
         num_base_attribute14,
         num_base_attribute15,
         num_base_attribute16,
         num_base_attribute17,
         num_base_attribute18,
         num_base_attribute19,
         num_base_attribute20,
         num_base_attribute21,
         num_base_attribute22,
         num_base_attribute23,
         num_base_attribute24,
         num_base_attribute25,
         num_base_attribute26,
         num_base_attribute27,
         num_base_attribute28,
         num_base_attribute29,
         num_base_attribute30,
         num_base_attribute31,
         num_base_attribute32,
         num_base_attribute33,
         num_base_attribute34,
         num_base_attribute35,
         num_base_attribute36,
         num_base_attribute37,
         num_base_attribute38,
         num_base_attribute39,
         num_base_attribute40,
         num_base_attribute41,
         num_base_attribute42,
         num_base_attribute43,
         num_base_attribute44,
         num_base_attribute45,
         num_base_attribute46,
         num_base_attribute47,
         num_base_attribute48,
         num_base_attribute49,
         num_base_attribute50,
         num_base_attribute51,
         num_base_attribute52,
         num_base_attribute53,
         num_base_attribute54,
         num_base_attribute55,
         num_base_attribute56,
         num_base_attribute57,
         num_base_attribute58,
         num_base_attribute59,
         num_base_attribute60,
         num_base_attribute61,
         num_base_attribute62,
         num_base_attribute63,
         num_base_attribute64,
         num_base_attribute65,
         num_base_attribute66,
         num_base_attribute67,
         num_base_attribute68,
         num_base_attribute69,
         num_base_attribute70,
         num_base_attribute71,
         num_base_attribute72,
         num_base_attribute73,
         num_base_attribute74,
         num_base_attribute75,
         num_base_attribute76,
         num_base_attribute77,
         num_base_attribute78,
         num_base_attribute79,
         num_base_attribute80,
         num_base_attribute81,
         num_base_attribute82,
         num_base_attribute83,
         num_base_attribute84,
         num_base_attribute85,
         num_base_attribute86,
         num_base_attribute87,
         num_base_attribute88,
         num_base_attribute89,
         num_base_attribute90,
         num_base_attribute91,
         num_base_attribute92,
         num_base_attribute93,
         num_base_attribute94,
         num_base_attribute95,
         num_base_attribute96,
         num_base_attribute97,
         num_base_attribute98,
         num_base_attribute99,
         num_base_attribute100,
         text_cat_attribute1,
         text_cat_attribute2,
         text_cat_attribute3,
         text_cat_attribute4,
         text_cat_attribute5,
         text_cat_attribute6,
         text_cat_attribute7,
         text_cat_attribute8,
         text_cat_attribute9,
         text_cat_attribute10,
         text_cat_attribute11,
         text_cat_attribute12,
         text_cat_attribute13,
         text_cat_attribute14,
         text_cat_attribute15,
         text_cat_attribute16,
         text_cat_attribute17,
         text_cat_attribute18,
         text_cat_attribute19,
         text_cat_attribute20,
         text_cat_attribute21,
         text_cat_attribute22,
         text_cat_attribute23,
         text_cat_attribute24,
         text_cat_attribute25,
         text_cat_attribute26,
         text_cat_attribute27,
         text_cat_attribute28,
         text_cat_attribute29,
         text_cat_attribute30,
         text_cat_attribute31,
         text_cat_attribute32,
         text_cat_attribute33,
         text_cat_attribute34,
         text_cat_attribute35,
         text_cat_attribute36,
         text_cat_attribute37,
         text_cat_attribute38,
         text_cat_attribute39,
         text_cat_attribute40,
         text_cat_attribute41,
         text_cat_attribute42,
         text_cat_attribute43,
         text_cat_attribute44,
         text_cat_attribute45,
         text_cat_attribute46,
         text_cat_attribute47,
         text_cat_attribute48,
         text_cat_attribute49,
         text_cat_attribute50,
         num_cat_attribute1,
         num_cat_attribute2,
         num_cat_attribute3,
         num_cat_attribute4,
         num_cat_attribute5,
         num_cat_attribute6,
         num_cat_attribute7,
         num_cat_attribute8,
         num_cat_attribute9,
         num_cat_attribute10,
         num_cat_attribute11,
         num_cat_attribute12,
         num_cat_attribute13,
         num_cat_attribute14,
         num_cat_attribute15,
         num_cat_attribute16,
         num_cat_attribute17,
         num_cat_attribute18,
         num_cat_attribute19,
         num_cat_attribute20,
         num_cat_attribute21,
         num_cat_attribute22,
         num_cat_attribute23,
         num_cat_attribute24,
         num_cat_attribute25,
         num_cat_attribute26,
         num_cat_attribute27,
         num_cat_attribute28,
         num_cat_attribute29,
         num_cat_attribute30,
         num_cat_attribute31,
         num_cat_attribute32,
         num_cat_attribute33,
         num_cat_attribute34,
         num_cat_attribute35,
         num_cat_attribute36,
         num_cat_attribute37,
         num_cat_attribute38,
         num_cat_attribute39,
         num_cat_attribute40,
         num_cat_attribute41,
         num_cat_attribute42,
         num_cat_attribute43,
         num_cat_attribute44,
         num_cat_attribute45,
         num_cat_attribute46,
         num_cat_attribute47,
         num_cat_attribute48,
         num_cat_attribute49,
         num_cat_attribute50,
         last_update_login,
         last_updated_by,
         last_update_date,
         created_by,
         creation_date,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         last_updated_program,
         'Y' -- latest_external_flag
      FROM PO_ATTRIBUTE_VALUES
      WHERE po_line_id = l_po_line_ids(i)
        AND NOT EXISTS
               (SELECT 'Archive record for Attr already exists'
                FROM PO_ATTR_VALUES_ARCHIVE POAVA2
                WHERE POAVA2.po_line_id = l_po_line_ids(i));

    l_progress := '150';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of attr archive records inserted='||SQL%rowcount); END IF;

    EXIT WHEN (l_last_batch_flag = 'Y');

    l_start_index := l_start_index + p_batch_size;
    l_end_index_tmp := l_end_index + p_batch_size;

    IF (l_end_index_tmp >= l_po_line_ids.COUNT) THEN
      l_end_index_tmp := l_po_line_ids.COUNT;
      l_last_batch_flag := 'Y';
    END IF;

    l_end_index := l_end_index_tmp;

    l_progress := '160';
  END LOOP; -- archive attribute_values

  l_progress := '170';
  -- Archive the attribute_values_tlp in batches
  l_start_index := 1;
  l_end_index := p_batch_size;
  l_last_batch_flag := 'N';

  IF (l_po_line_ids.COUNT <= p_batch_size) THEN
    l_end_index := l_po_line_ids.COUNT;
    l_last_batch_flag := 'Y';
  END IF;

  l_progress := '180';
  -- Archive attribute_values_tlp
  LOOP
    l_progress := '190';

    -- SQL What: Insert data into PO_ATTR_VALUES_TLP_ARCHIVE
    -- SQL Why : To archive Attr TLP values
    -- SQL Join: po_line_id
    FORALL i IN l_start_index .. l_end_index
      INSERT INTO PO_ATTR_VALUES_TLP_ARCHIVE
       (
         attribute_values_tlp_id,
         revision_num,
         latest_external_flag,
         po_line_id,
         req_template_name,
         req_template_line_num,
         ip_category_id,
         inventory_item_id,
         org_id,
         language,
         description,
         manufacturer,
         comments,
         alias,
         long_description,
         tl_text_base_attribute1,
         tl_text_base_attribute2,
         tl_text_base_attribute3,
         tl_text_base_attribute4,
         tl_text_base_attribute5,
         tl_text_base_attribute6,
         tl_text_base_attribute7,
         tl_text_base_attribute8,
         tl_text_base_attribute9,
         tl_text_base_attribute10,
         tl_text_base_attribute11,
         tl_text_base_attribute12,
         tl_text_base_attribute13,
         tl_text_base_attribute14,
         tl_text_base_attribute15,
         tl_text_base_attribute16,
         tl_text_base_attribute17,
         tl_text_base_attribute18,
         tl_text_base_attribute19,
         tl_text_base_attribute20,
         tl_text_base_attribute21,
         tl_text_base_attribute22,
         tl_text_base_attribute23,
         tl_text_base_attribute24,
         tl_text_base_attribute25,
         tl_text_base_attribute26,
         tl_text_base_attribute27,
         tl_text_base_attribute28,
         tl_text_base_attribute29,
         tl_text_base_attribute30,
         tl_text_base_attribute31,
         tl_text_base_attribute32,
         tl_text_base_attribute33,
         tl_text_base_attribute34,
         tl_text_base_attribute35,
         tl_text_base_attribute36,
         tl_text_base_attribute37,
         tl_text_base_attribute38,
         tl_text_base_attribute39,
         tl_text_base_attribute40,
         tl_text_base_attribute41,
         tl_text_base_attribute42,
         tl_text_base_attribute43,
         tl_text_base_attribute44,
         tl_text_base_attribute45,
         tl_text_base_attribute46,
         tl_text_base_attribute47,
         tl_text_base_attribute48,
         tl_text_base_attribute49,
         tl_text_base_attribute50,
         tl_text_base_attribute51,
         tl_text_base_attribute52,
         tl_text_base_attribute53,
         tl_text_base_attribute54,
         tl_text_base_attribute55,
         tl_text_base_attribute56,
         tl_text_base_attribute57,
         tl_text_base_attribute58,
         tl_text_base_attribute59,
         tl_text_base_attribute60,
         tl_text_base_attribute61,
         tl_text_base_attribute62,
         tl_text_base_attribute63,
         tl_text_base_attribute64,
         tl_text_base_attribute65,
         tl_text_base_attribute66,
         tl_text_base_attribute67,
         tl_text_base_attribute68,
         tl_text_base_attribute69,
         tl_text_base_attribute70,
         tl_text_base_attribute71,
         tl_text_base_attribute72,
         tl_text_base_attribute73,
         tl_text_base_attribute74,
         tl_text_base_attribute75,
         tl_text_base_attribute76,
         tl_text_base_attribute77,
         tl_text_base_attribute78,
         tl_text_base_attribute79,
         tl_text_base_attribute80,
         tl_text_base_attribute81,
         tl_text_base_attribute82,
         tl_text_base_attribute83,
         tl_text_base_attribute84,
         tl_text_base_attribute85,
         tl_text_base_attribute86,
         tl_text_base_attribute87,
         tl_text_base_attribute88,
         tl_text_base_attribute89,
         tl_text_base_attribute90,
         tl_text_base_attribute91,
         tl_text_base_attribute92,
         tl_text_base_attribute93,
         tl_text_base_attribute94,
         tl_text_base_attribute95,
         tl_text_base_attribute96,
         tl_text_base_attribute97,
         tl_text_base_attribute98,
         tl_text_base_attribute99,
         tl_text_base_attribute100,
         tl_text_cat_attribute1,
         tl_text_cat_attribute2,
         tl_text_cat_attribute3,
         tl_text_cat_attribute4,
         tl_text_cat_attribute5,
         tl_text_cat_attribute6,
         tl_text_cat_attribute7,
         tl_text_cat_attribute8,
         tl_text_cat_attribute9,
         tl_text_cat_attribute10,
         tl_text_cat_attribute11,
         tl_text_cat_attribute12,
         tl_text_cat_attribute13,
         tl_text_cat_attribute14,
         tl_text_cat_attribute15,
         tl_text_cat_attribute16,
         tl_text_cat_attribute17,
         tl_text_cat_attribute18,
         tl_text_cat_attribute19,
         tl_text_cat_attribute20,
         tl_text_cat_attribute21,
         tl_text_cat_attribute22,
         tl_text_cat_attribute23,
         tl_text_cat_attribute24,
         tl_text_cat_attribute25,
         tl_text_cat_attribute26,
         tl_text_cat_attribute27,
         tl_text_cat_attribute28,
         tl_text_cat_attribute29,
         tl_text_cat_attribute30,
         tl_text_cat_attribute31,
         tl_text_cat_attribute32,
         tl_text_cat_attribute33,
         tl_text_cat_attribute34,
         tl_text_cat_attribute35,
         tl_text_cat_attribute36,
         tl_text_cat_attribute37,
         tl_text_cat_attribute38,
         tl_text_cat_attribute39,
         tl_text_cat_attribute40,
         tl_text_cat_attribute41,
         tl_text_cat_attribute42,
         tl_text_cat_attribute43,
         tl_text_cat_attribute44,
         tl_text_cat_attribute45,
         tl_text_cat_attribute46,
         tl_text_cat_attribute47,
         tl_text_cat_attribute48,
         tl_text_cat_attribute49,
         tl_text_cat_attribute50,
         last_update_login,
         last_updated_by,
         last_update_date,
         created_by,
         creation_date,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         last_updated_program
       )
      SELECT
         attribute_values_tlp_id,
         0, -- revision_num
         'Y', -- latest_external_flag,
         po_line_id,
         req_template_name,
         req_template_line_num,
         ip_category_id,
         inventory_item_id,
         org_id,
         language,
         description,
         manufacturer,
         comments,
         alias,
         long_description,
         tl_text_base_attribute1,
         tl_text_base_attribute2,
         tl_text_base_attribute3,
         tl_text_base_attribute4,
         tl_text_base_attribute5,
         tl_text_base_attribute6,
         tl_text_base_attribute7,
         tl_text_base_attribute8,
         tl_text_base_attribute9,
         tl_text_base_attribute10,
         tl_text_base_attribute11,
         tl_text_base_attribute12,
         tl_text_base_attribute13,
         tl_text_base_attribute14,
         tl_text_base_attribute15,
         tl_text_base_attribute16,
         tl_text_base_attribute17,
         tl_text_base_attribute18,
         tl_text_base_attribute19,
         tl_text_base_attribute20,
         tl_text_base_attribute21,
         tl_text_base_attribute22,
         tl_text_base_attribute23,
         tl_text_base_attribute24,
         tl_text_base_attribute25,
         tl_text_base_attribute26,
         tl_text_base_attribute27,
         tl_text_base_attribute28,
         tl_text_base_attribute29,
         tl_text_base_attribute30,
         tl_text_base_attribute31,
         tl_text_base_attribute32,
         tl_text_base_attribute33,
         tl_text_base_attribute34,
         tl_text_base_attribute35,
         tl_text_base_attribute36,
         tl_text_base_attribute37,
         tl_text_base_attribute38,
         tl_text_base_attribute39,
         tl_text_base_attribute40,
         tl_text_base_attribute41,
         tl_text_base_attribute42,
         tl_text_base_attribute43,
         tl_text_base_attribute44,
         tl_text_base_attribute45,
         tl_text_base_attribute46,
         tl_text_base_attribute47,
         tl_text_base_attribute48,
         tl_text_base_attribute49,
         tl_text_base_attribute50,
         tl_text_base_attribute51,
         tl_text_base_attribute52,
         tl_text_base_attribute53,
         tl_text_base_attribute54,
         tl_text_base_attribute55,
         tl_text_base_attribute56,
         tl_text_base_attribute57,
         tl_text_base_attribute58,
         tl_text_base_attribute59,
         tl_text_base_attribute60,
         tl_text_base_attribute61,
         tl_text_base_attribute62,
         tl_text_base_attribute63,
         tl_text_base_attribute64,
         tl_text_base_attribute65,
         tl_text_base_attribute66,
         tl_text_base_attribute67,
         tl_text_base_attribute68,
         tl_text_base_attribute69,
         tl_text_base_attribute70,
         tl_text_base_attribute71,
         tl_text_base_attribute72,
         tl_text_base_attribute73,
         tl_text_base_attribute74,
         tl_text_base_attribute75,
         tl_text_base_attribute76,
         tl_text_base_attribute77,
         tl_text_base_attribute78,
         tl_text_base_attribute79,
         tl_text_base_attribute80,
         tl_text_base_attribute81,
         tl_text_base_attribute82,
         tl_text_base_attribute83,
         tl_text_base_attribute84,
         tl_text_base_attribute85,
         tl_text_base_attribute86,
         tl_text_base_attribute87,
         tl_text_base_attribute88,
         tl_text_base_attribute89,
         tl_text_base_attribute90,
         tl_text_base_attribute91,
         tl_text_base_attribute92,
         tl_text_base_attribute93,
         tl_text_base_attribute94,
         tl_text_base_attribute95,
         tl_text_base_attribute96,
         tl_text_base_attribute97,
         tl_text_base_attribute98,
         tl_text_base_attribute99,
         tl_text_base_attribute100,
         tl_text_cat_attribute1,
         tl_text_cat_attribute2,
         tl_text_cat_attribute3,
         tl_text_cat_attribute4,
         tl_text_cat_attribute5,
         tl_text_cat_attribute6,
         tl_text_cat_attribute7,
         tl_text_cat_attribute8,
         tl_text_cat_attribute9,
         tl_text_cat_attribute10,
         tl_text_cat_attribute11,
         tl_text_cat_attribute12,
         tl_text_cat_attribute13,
         tl_text_cat_attribute14,
         tl_text_cat_attribute15,
         tl_text_cat_attribute16,
         tl_text_cat_attribute17,
         tl_text_cat_attribute18,
         tl_text_cat_attribute19,
         tl_text_cat_attribute20,
         tl_text_cat_attribute21,
         tl_text_cat_attribute22,
         tl_text_cat_attribute23,
         tl_text_cat_attribute24,
         tl_text_cat_attribute25,
         tl_text_cat_attribute26,
         tl_text_cat_attribute27,
         tl_text_cat_attribute28,
         tl_text_cat_attribute29,
         tl_text_cat_attribute30,
         tl_text_cat_attribute31,
         tl_text_cat_attribute32,
         tl_text_cat_attribute33,
         tl_text_cat_attribute34,
         tl_text_cat_attribute35,
         tl_text_cat_attribute36,
         tl_text_cat_attribute37,
         tl_text_cat_attribute38,
         tl_text_cat_attribute39,
         tl_text_cat_attribute40,
         tl_text_cat_attribute41,
         tl_text_cat_attribute42,
         tl_text_cat_attribute43,
         tl_text_cat_attribute44,
         tl_text_cat_attribute45,
         tl_text_cat_attribute46,
         tl_text_cat_attribute47,
         tl_text_cat_attribute48,
         tl_text_cat_attribute49,
         tl_text_cat_attribute50,
         last_update_login,
         last_updated_by,
         last_update_date,
         created_by,
         creation_date,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         last_updated_program
      FROM PO_ATTRIBUTE_VALUES_TLP POTLP
      WHERE po_line_id = l_po_line_ids(i)
        AND NOT EXISTS
               (SELECT 'Archive record for TLP already exists'
                FROM PO_ATTR_VALUES_TLP_ARCHIVE POAVTA2
                WHERE POAVTA2.po_line_id = POTLP.po_line_id
                  AND POAVTA2.language = POTLP.language);

    l_progress := '200';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of TLP archive records inserted='||SQL%rowcount); END IF;

    EXIT WHEN (l_last_batch_flag = 'Y');

    l_start_index := l_start_index + p_batch_size;
    l_end_index_tmp := l_end_index + p_batch_size;

    IF (l_end_index_tmp >= l_po_line_ids.COUNT) THEN
      l_end_index_tmp := l_po_line_ids.COUNT;
      l_last_batch_flag := 'Y';
    END IF;

    l_end_index := l_end_index_tmp;

    l_progress := '210';
  END LOOP; -- archive attribute_tlp_values

  l_progress := '210';
  -- Archive the org_assignments table
  -- SQL What: Insert data into PO_GA_ORG_ASSIGNMENTS_ARCHIVE
  -- SQL Why : To archive org assignments
  -- SQL Join: po_header_id
  FORALL i IN 1.. p_po_header_ids.COUNT
    INSERT INTO PO_GA_ORG_ASSIGNMENTS_ARCHIVE
     (
         po_header_id,
         organization_id,
         enabled_flag,
         vendor_site_id,
         last_update_date,
         last_updated_by,
         creation_date,
         revision_num,
         created_by,
         last_update_login,
         purchasing_org_id,
         latest_external_flag,
         org_assignment_id
     )
    SELECT
         po_header_id,
         organization_id,
         enabled_flag,
         vendor_site_id,
         last_update_date,
         last_updated_by,
         creation_date,
         0, -- revision_num
         created_by,
         last_update_login,
         purchasing_org_id,
         'Y', -- latest_external_flag
         org_assignment_id
    FROM PO_GA_ORG_ASSIGNMENTS POGA
    WHERE po_header_id = p_po_header_ids(i)
     AND NOT EXISTS
           (SELECT 'Archive record for Org Assignement already exists'
              FROM PO_GA_ORG_ASSIGNMENTS_ARCHIVE POGAA2
             WHERE POGAA2.org_assignment_id = POGA.org_assignment_id);

  l_progress := '220';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of org assignment archive records inserted='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END archive_gbpa_bulk;

FUNCTION get_next_po_number
(
  p_org_id IN NUMBER
)
RETURN VARCHAR2
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'get_next_po_number';
  l_api_version CONSTANT NUMBER := 1.0;
  l_module      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress    VARCHAR2(3) := '000';

  l_new_po_number PO_HEADERS_ALL.segment1%TYPE;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'START'); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'p_org_id='||p_org_id); END IF;

  l_progress := '020';
  -- Set the org context because the fuction default_po_unique_identifier
  -- depends on the org context. It uses the org-striped view
  -- PO_UNIQUE_IDENTIFIER_CONTROL to get the next PO Number.
  --FND_CLIENT_ INFO.set_org_context(p_org_id);
  PO_MOAC_UTILS_PVT.set_policy_context('S', p_org_id); -- Bug#5259328

  l_progress := '030';
  l_new_po_number := PO_CORE_SV1.default_po_unique_identifier('PO_HEADERS');

  l_progress := '040';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'l_new_po_number='||l_new_po_number); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_module,l_progress,'END'); END IF;
  RETURN l_new_po_number;
END get_next_po_number;

--------------------------------------------------------------------------------
--Start of Comments
--Name: prepare_long_text
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  This procedure creates a long text containing a list of GBPA numbers and
--  their corresponding Operating Units. These GBPA are those that were created
--  during catalog migration and refer the given CPA.
--
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_cpa_header_id
--  The PO_HEADER_ID of the Contract for which the attachment needs to be
--  created.
--p_gbpa_header_id_list
--  A list of PO_HEADER_ID's of GBPA's that have the given CPA in the
--  CPA_REFERENCE column.
--OUT:
--x_long_text
--  The long text containing the GBPA numbers and OU names.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE prepare_long_text
(
  p_cpa_header_id       IN NUMBER
, p_gbpa_header_id_list IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, x_long_text           IN OUT NOCOPY LONG
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'prepare_long_text';
  l_log_head CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress VARCHAR2(3) := '000';

  l_long_text   LONG := NULL;
  l_gbpa_number PO_HEADERS_ALL.segment1%TYPE;
  l_ou_name     HR_ALL_ORGANIZATION_UNITS_TL.name%TYPE;
  l_gbpa_info   LONG;

  -- Bug 4941073:
  -- GSCC Error: File.SQL.10: Do not use CHR character function in sql scripts
  -- Instead, use FND_GLOBAL.local_chr(x)
  --l_eoln_char CONSTANT VARCHAR2(1) := chr(10);
  --l_tab_char  CONSTANT VARCHAR2(1) := chr(09);
  l_eoln_char CONSTANT VARCHAR2(1) := FND_GLOBAL.local_chr(10);
  l_tab_char  CONSTANT VARCHAR2(1) := FND_GLOBAL.local_chr(09);

  l_heading_global_blanket FND_NEW_MESSAGES.message_text%TYPE;
  l_heading_ou_name FND_NEW_MESSAGES.message_text%TYPE;

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  FND_MESSAGE.set_name('PO','PO_GA_TYPE'); -- 'Global Agreement'
  l_heading_global_blanket := FND_MESSAGE.get;

  FND_MESSAGE.set_name('PO','PO_R12_CAT_UPG_ATTACH_OU_NAME'); -- 'Operating Unit Name'
  l_heading_ou_name := FND_MESSAGE.get;

  -- TODO: Get this message from PM. Also check issue of formatting.
  l_long_text := l_tab_char || l_heading_global_blanket|| l_tab_char || l_tab_char ||
                 l_heading_ou_name || l_eoln_char || l_eoln_char;

  FOR i IN 1 .. p_gbpa_header_id_list.COUNT LOOP
    -- SQL What: Get the PO Number for the GBPA and the OU Name
    -- SQL Why : It will be inserted as long text attachment in CPA
    -- SQL Join: po_header_id, organization_id, language
    SELECT POH.segment1,
           HROUTL.name
      INTO l_gbpa_number,
           l_ou_name
      FROM PO_HEADERS_ALL POH,
           HR_ALL_ORGANIZATION_UNITS_TL HROUTL
     WHERE POH.po_header_id = p_gbpa_header_id_list(i)
       AND HROUTL.organization_id = POH.org_id
       AND HROUTL.language = userenv('LANG');

    l_gbpa_info := '' || i || '.' || l_tab_char || l_tab_char ||
                   l_gbpa_number ||
                   l_tab_char || l_tab_char || l_tab_char || l_tab_char ||
                   l_ou_name ||
                   l_eoln_char;

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'gbpa_info='||to_char(l_gbpa_info)); END IF;

    l_long_text := l_long_text || l_gbpa_info;
  END LOOP;

  x_long_text := l_long_text; -- OUT value

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'x_long_text='||to_char(x_long_text)); END IF;

  l_progress := '060';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END prepare_long_text;

--------------------------------------------------------------------------------
--Start of Comments
--Name: create_attachment
--Pre-reqs:
--  None
--Modifies:
--  FND_DOCUMENTS, FND_DOCUMENTS_LONG_TEXT, FND_ATTACHED_DOCUMENTS
--Locks:
--  None.
--Function:
--  This procedure creates a long text attachment at the header level of the
--  given CPA. The attachment contains a list of GBPA numbers and their
--  corresponding Operating Units. These GBPA are those that were created
-- during catalog migration and refer the given CPA.
--
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--p_cpa_header_id
--  The PO_HEADER_ID of the Contract for which the attachment needs to be
--  created.
--p_cpa_org_id
--  The ORG_ID of the CPA. This is used as the security_id while creating
--  the attachment.
--p_gbpa_header_id_list
--  A list of PO_HEADER_ID's of GBPA's that have the given CPA in the
--  CPA_REFERENCE column.
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE create_attachment
(
  p_cpa_header_id       IN NUMBER
, p_cpa_org_id          IN NUMBER
, p_gbpa_header_id_list IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'create_attachment';
  l_log_head CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress VARCHAR2(3) := '000';

  l_rowid            VARCHAR2(30);
  l_document_id      NUMBER;
  l_security_id      NUMBER;
  l_media_id         NUMBER;
  l_seq_num          NUMBER;
  l_description      VARCHAR2(200);
  l_long_text        LONG;
  l_to_pk1_value     FND_ATTACHED_DOCUMENTS.pk1_value%TYPE;
  l_to_entity_name   FND_ATTACHED_DOCUMENTS.entity_name%TYPE;

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_cpa_header_id='||p_cpa_header_id); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_cpa_org_id='||p_cpa_org_id); END IF;
  IF (p_gbpa_header_id_list IS NOT NULL) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_gbpa_header_id_list.COUNT='||p_gbpa_header_id_list.COUNT); END IF;
  ELSE
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_gbpa_header_id_list is NULL'); END IF;
  END IF;

  FND_MESSAGE.set_name('PO','PO_R12_CAT_UPG_ATTACH_REF_GBPA'); -- 'Referencing Global Agreements'
  l_description := FND_MESSAGE.get;

  l_to_entity_name := 'PO_HEADERS';
  l_to_pk1_value   := p_cpa_header_id;
  --l_security_id    := PO_MOAC_UTILS_PVT.get_current_org_id;
  l_security_id    := p_cpa_header_id;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'security_id(org_id)='||l_security_id); END IF;
--  IF g_debug THEN
--    IF (l_security_id IS NULL) THEN
--      l_security_id := 204;
--      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'DEBUG: security_id(org_id) was NULL. Now hardcoded to:'||l_security_id); END IF;
--    END IF;
--  END IF;

  l_progress := '020';
  -- Prepare long text
  prepare_long_text
  (
    p_cpa_header_id       => p_cpa_header_id
  , p_gbpa_header_id_list => p_gbpa_header_id_list
  , x_long_text           => l_long_text            -- IN/OUT
  );

  l_progress := '030';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Calling FND_DOCUMENTS_PKG.insert_row()'); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Parameter: userenv(LANG)='||userenv('LANG')); END IF;

  -- Insert into FND_DOCUMENTS
  FND_DOCUMENTS_PKG.insert_row
  (
    x_rowid               => l_rowid                -- IN/OUT
  , x_document_id         => l_document_id          -- IN/OUT
  , x_creation_date       => sysdate
  , x_created_by          => FND_GLOBAL.user_id
  , x_last_update_date    => sysdate
  , x_last_updated_by     => FND_GLOBAL.user_id
  , x_last_update_login   => FND_GLOBAL.login_id
  , x_datatype_id         => 2 -- Long Text
  , x_category_id         => 1 -- Miscellaneous
  , x_security_type       => 1
  , x_security_id         => l_security_id
  , x_publish_flag        => 'Y'
  , x_usage_type          => 'O' -- 'One-time'. Other options include 'Std'.
  , x_program_update_date => sysdate
  , x_language            => userenv('LANG')
  , x_description         => l_description
  , x_media_id            => l_media_id             -- IN/OUT
  );

  l_progress := '040';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'FND_DOCUMENTS_PKG.insert_row() returns media_id='||l_media_id||', document_id='||l_document_id||', row_id='||l_rowid); END IF;

  -- SQL What: Insert long text into FND_DOCUMENTS_LONG_TEXT
  -- SQL Why : This long text will be attached to the CPA
  -- SQL Join: none
  INSERT INTO FND_DOCUMENTS_LONG_TEXT
  (
    media_id
  , long_text
  )
  VALUES
  (
    l_media_id
  , l_long_text
  );

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows inserted in FND_DOCUMENTS_LONG_TEXT='||SQL%rowcount); END IF;

  -- SQL What: Get maximum sequence number for the CPA header attachments
  -- SQL Why : To get the next sequence number for the new attachment
  -- SQL Join: pk1_value, entity_name
  SELECT max(seq_num)
    INTO l_seq_num
    FROM FND_ATTACHED_DOCUMENTS
   WHERE pk1_value = l_to_pk1_value
     AND entity_name = l_to_entity_name;

  l_seq_num := nvl(l_seq_num, 0) + 10;

  l_progress := '060';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Next seq_num='||l_seq_num); END IF;

  -- SQL What: Insert document into FND_ATTACHED_DOCUMENTS
  -- SQL Why : This long text document will be attached to the CPA
  -- SQL Join: none
  INSERT INTO FND_ATTACHED_DOCUMENTS
  (
    attached_document_id
  , document_id
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , seq_num
  , entity_name
  , pk1_value
  , automatically_added_flag
  , program_update_date
  )
  VALUES
  (
    FND_ATTACHED_DOCUMENTS_S.nextval
  , l_document_id
  , sysdate
  , FND_GLOBAL.user_id
  , sysdate
  , FND_GLOBAL.user_id
  , FND_GLOBAL.login_id
  , l_seq_num
  , l_to_entity_name
  , l_to_pk1_value
  , 'N'
  , sysdate
  );

  l_progress := '070';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows inserted in FND_ATTACHED_DOCUMENTS='||SQL%rowcount); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END create_attachment;

--------------------------------------------------------------------------------
--Start of Comments
--Name: attach_gbpa_numbers_in_cpa
--Pre-reqs:
--  None
--Modifies:
--  a) PO_HEADERS_ALL: updated CPA_REFERENCE column
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  This procedure gathers the GBPA numbers that refer a CPA and then
--  creates a long text attachment in the CPA header, with the list
--  of the GBPA numbers and their owning Operating Units.
--
--  This API should be called during the upgrade phase only.
--Parameters:
--IN:
--  None
--OUT:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE attach_gbpa_numbers_in_cpa
IS
  l_api_name CONSTANT VARCHAR2(30) := 'attach_gbpa_numbers_in_cpa';
  l_log_head CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress VARCHAR2(3) := '000';

  -- SQL What: Cursor to fetch all the CPA's that have at least one GBPA
  --           referring to it.
  -- SQL Why : It will be used to create a long text attachment in the CPA
  -- SQL Join: type_lookup_code, created_by, authorization_status, cpa_reference
  CURSOR cpa_references_csr IS
    SELECT GBPA.cpa_reference,
           CPA.org_id cpa_org_id,
           GBPA.po_header_id
      FROM PO_HEADERS_ALL GBPA,
           PO_HEADERS_ALL CPA
     WHERE GBPA.type_lookup_code = 'BLANKET'
       AND GBPA.created_by = PO_R12_CAT_UPG_PVT.g_R12_UPGRADE_USER
       AND GBPA.authorization_status = 'IN PROCESS'
       AND GBPA.cpa_reference IS NOT NULL
       AND CPA.po_header_id = GBPA.cpa_reference
    ORDER BY GBPA.cpa_reference, GBPA.org_id, GBPA.po_header_id;

  l_cpa_reference NUMBER;
  l_cpa_org_id NUMBER;
  l_po_header_id  NUMBER;
  l_cpa_reference_list PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_po_header_id_list  PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_prev_cpa_reference NUMBER;
  l_count NUMBER;
  l_current_batch NUMBER; -- Bug 5468308: Track the progress of the script
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  OPEN cpa_references_csr;

  l_progress := '020';
  l_count := 0;
  l_prev_cpa_reference := NULL;
  l_current_batch := 0;
  LOOP
    l_current_batch := l_current_batch + 1;

    l_progress := '025';
    -- Bug 5468308: Adding FND log messages at Unexpected level.
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED, l_log_head||'.'||l_progress,
      'current_batch='||l_current_batch);
    END IF;

    FETCH cpa_references_csr
    INTO l_cpa_reference, l_cpa_org_id, l_po_header_id;

    l_progress := '030';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'cpa_reference='||l_cpa_reference||', cpa_org_id='||l_cpa_org_id||', po_header_id='||l_po_header_id); END IF;

    EXIT WHEN CPA_REFERENCES_CSR%NOTFOUND;

    IF (l_prev_cpa_reference IS NOT NULL AND
        l_cpa_reference <> l_prev_cpa_reference) THEN

      -- Create the attachment
      create_attachment
      (
        p_cpa_header_id       => l_prev_cpa_reference
      , p_cpa_org_id          => l_cpa_org_id
      , p_gbpa_header_id_list => l_po_header_id_list
      );

      -- Reset the l_po_header_id_list and the counter
      l_po_header_id_list.DELETE;
      l_count := 0;
    END IF;

    l_count := l_count + 1;
    l_po_header_id_list(l_count) := l_po_header_id;

    -- Mark the previous CPA_REFERENCE in the list
    l_prev_cpa_reference := l_cpa_reference;

  END LOOP; -- Main cursor loop

  -- Create the attachment for the last batch of the loop above
  IF (l_prev_cpa_reference IS NOT NULL) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Calling create_attchment() outside the loop'); END IF;
    create_attachment
    (
      p_cpa_header_id       => l_prev_cpa_reference
    , p_cpa_org_id          => l_cpa_org_id
    , p_gbpa_header_id_list => l_po_header_id_list
    );
  END IF;

  l_progress := '140';
  CLOSE cpa_references_csr;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of CPAs updated='||SQL%rowcount); END IF;

  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END attach_gbpa_numbers_in_cpa;

END PO_R12_CAT_UPG_FINAL_GRP;

/
