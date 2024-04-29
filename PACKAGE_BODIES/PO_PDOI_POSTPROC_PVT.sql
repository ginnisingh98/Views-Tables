--------------------------------------------------------
--  DDL for Package Body PO_PDOI_POSTPROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_POSTPROC_PVT" AS
/* $Header: PO_PDOI_POSTPROC_PVT.plb 120.26.12010000.31 2015/01/23 08:11:04 zhijfeng ship $ */

d_pkg_name CONSTANT VARCHAR2(30) :=
  PO_LOG.get_package_base('PO_PDOI_POSTPROC_PVT');

DOC_POSTPROC_EXC EXCEPTION;

-------------------------------------------------------
----------- PRIVATE PROCEDURES PROTOTYPE --------------
-------------------------------------------------------
PROCEDURE process_rejected_records;

PROCEDURE post_validate
( p_doc_rec IN doc_row_type,
  p_doc_info IN PO_PDOI_PARAMS.doc_info_rec_type,
  x_header_rejected OUT NOCOPY VARCHAR2,
  x_remove_draft OUT NOCOPY VARCHAR2  -- bug5129752
);


PROCEDURE transfer_document_check
( p_doc_rec                   IN doc_row_type,
  p_doc_info                  IN PO_PDOI_PARAMS.doc_info_rec_type,
  x_transfer_flag             OUT NOCOPY VARCHAR2,
  x_submit_for_buyer_acc_flag OUT NOCOPY VARCHAR2
);

-- bug5149827
PROCEDURE remove_notified_draft_lines
( p_draft_id IN NUMBER
);

PROCEDURE create_quotation
( p_doc_rec IN doc_row_type
);

PROCEDURE update_quotation
( p_doc_rec IN doc_row_type
);

PROCEDURE expire_document
( p_doc_rec IN doc_row_type
);

PROCEDURE assign_document_number
( p_doc_rec IN doc_row_type
);
  -- <<PDOI Enhancement Bug#17063664>>
  -- Initially we had procedures to
  -- arcihve po, submmistion_check, reserve fund, need_to_encumber.
  -- create_delivery_record, close_po, create_po_supply,
  -- Now a new workflow process PDOI Auto Approval process is launched.
  -- This takes care of all the above.
  -- We also had procedures to create_standard_po, update_standard_po
  -- create_blanket, update_blanket.
  -- Removed all this and created new procedure create_update_doc

PROCEDURE get_lines_for_src_rules
( p_doc_rec IN doc_row_type,
  x_lines OUT NOCOPY src_rule_lines_rec_type
);

PROCEDURE process_sourcing_rules
( p_doc_rec         IN doc_row_type,
  p_approval_status IN VARCHAR2,
  p_lines           IN src_rule_lines_rec_type
);

--<<PDOI Enhancement Bug#17063664>>
-- Added parameter p_doc_type
PROCEDURE transfer_draft_to_txn
(  p_doc_rec IN doc_row_type
 , p_doc_type IN VARCHAR2
);

PROCEDURE get_approval_method
( p_doc_rec         IN doc_row_type,
  x_approval_method OUT NOCOPY VARCHAR2
);

PROCEDURE update_document_status
( p_doc_rec            IN doc_row_type,
  p_auth_status    IN VARCHAR2,
  p_status_lookup_code IN VARCHAR2
);

FUNCTION need_to_create_sourcing_rules
( p_doc_rec IN doc_row_type
) RETURN VARCHAR2;

PROCEDURE start_po_approval_workflow
( p_doc_rec IN doc_row_type
);

PROCEDURE rebuild_catalog_index
( p_type         IN VARCHAR2,
  p_doc_rec      IN doc_row_type
);

PROCEDURE calculate_tax
( p_doc_rec       IN doc_row_type,
  x_return_status OUT NOCOPY VARCHAR2
);

--<<PDOI Enhancement Bug#17063664 START>>

PROCEDURE create_update_doc ( p_doc_rec      IN doc_row_type
                            , p_doc_type     IN VARCHAR2
                            , p_action       IN VARCHAR2
                            , x_process_code OUT NOCOPY VARCHAR2);

PROCEDURE get_req_details
(p_doc_rec        IN doc_row_type,
 p_line_dtls      OUT NOCOPY req_dtls_rec_type
);

PROCEDURE validate_lock_back_reqs
( p_doc_rec        IN doc_row_type
, p_req_dtls       IN req_dtls_rec_type
, x_header_rejected OUT NOCOPY VARCHAR2
);

PROCEDURE update_backing_req_dtls
(p_doc_rec        IN doc_row_type
);

PROCEDURE copy_req_attachments
(p_doc_rec        IN doc_row_type,
 p_line_dtls       IN req_dtls_rec_type
);

--bug 20378957
PROCEDURE sync_ga_attachments
(p_doc_rec        IN doc_row_type
);

PROCEDURE update_terms
(p_doc_rec        IN doc_row_type
);

PROCEDURE start_auto_approval_workflow
( p_doc_rec IN doc_row_type
);

PROCEDURE launch_wf_background;
--<<PDOI Enhancement Bug#17063664 END>>
-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: process
--Function:
--  Main procedure for post processing
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process IS

d_api_name CONSTANT VARCHAR2(30) := 'process';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

TYPE doc_tbl_type IS TABLE OF doc_row_type INDEX BY BINARY_INTEGER;
l_docs_tbl  doc_tbl_type;

l_doc_rec doc_row_type;

l_header_rejected VARCHAR2(1);

l_transfer_flag VARCHAR2(1);
l_submit_for_buyer_acc_flag VARCHAR2(1);

l_doc_info PO_PDOI_PARAMS.doc_info_rec_type;
l_process_code PO_HEADERS_INTERFACE.process_code%TYPE;

x_process_code VARCHAR2(1) := ''; -- bug 7277317
l_remove_draft VARCHAR2(1); -- bug5129752
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time (PO_PDOI_CONSTANTS.g_T_POSTPROCESSING);

  process_rejected_records;

  OPEN c_doc;

  LOOP

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'inside loop');
    END IF;

    FETCH c_doc
    BULK COLLECT
    INTO l_docs_tbl
    LIMIT PO_PDOI_PARAMS.g_request.batch_size;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'num of records fetched: '
                  || l_docs_tbl.COUNT);
    END IF;
    d_position := 10;

    EXIT WHEN l_docs_tbl.COUNT = 0;
    x_process_code := '';
    -- process one header at a time
    FOR i IN 1..l_docs_tbl.COUNT
    LOOP
      BEGIN
        -- set savepoint for each draft document processing
        SAVEPOINT po_pdoi_doc_postproc_sp;
        d_position := 20;

        l_doc_rec := l_docs_tbl(i);
        l_doc_info := PO_PDOI_PARAMS.g_docs_info(l_doc_rec.interface_header_id);

        IF (PO_PDOI_PARAMS.g_request.calling_module =
              PO_PDOI_CONSTANTS.g_call_mod_CATALOG_UPLOAD) THEN
          -- Copy processed lines info back to g_out structure. These values
          -- will get returned to the caller of PDOI
          PO_PDOI_PARAMS.g_out.processed_lines_count :=
            l_doc_info.number_of_processed_lines;
          PO_PDOI_PARAMS.g_out.rejected_lines_count :=
            l_doc_info.number_of_errored_lines;
          PO_PDOI_PARAMS.g_out.err_tolerance_exceeded :=
            l_doc_info.err_tolerance_exceeded;
        END IF;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'interface_header_id: ' ||
                      l_doc_rec.interface_header_id ||
                      ', processing header_id: ' || l_doc_rec.po_header_id ||
                      ', action: ' || l_doc_rec.action);
        END IF;

        -- post validation
        post_validate
        ( p_doc_rec => l_doc_rec,
          p_doc_info => l_doc_info,
          x_header_rejected => l_header_rejected,
          x_remove_draft => l_remove_draft  -- bug5129752
        );

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'l_header_rejected', l_header_rejected);
        END IF;

        IF (l_header_rejected = FND_API.G_FALSE) THEN
          d_position := 30;

          transfer_document_check
          ( p_doc_rec => l_doc_rec,
            p_doc_info => l_doc_info,
            x_transfer_flag => l_transfer_flag,
            x_submit_for_buyer_acc_flag => l_submit_for_buyer_acc_flag
          );

          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'l_transfer_flag', l_transfer_flag);
            PO_LOG.stmt(d_module, d_position, 'l_submit_for_buyer_acc_flag',
                        l_submit_for_buyer_acc_flag);
          END IF;

          d_position := 40;

          IF (l_transfer_flag = FND_API.G_FALSE) THEN

            d_position := 50;

            -- Change the draft status back to 'DRAFT' (it was set to
            -- 'PDOI PROCESSING' during header grouping)
            PO_DRAFTS_PVT.update_draft_status
            ( p_draft_id => l_doc_rec.draft_id,
              p_new_status => PO_DRAFTS_PVT.g_STATUS_DRAFT
            );

            -- If user is creating a draft without transferring, we need
            -- to get the functional lock of the document explicitly
            PO_DRAFTS_PVT.lock_document
            ( p_po_header_id   => l_doc_rec.po_header_id,
              p_role           => PO_PDOI_PARAMS.g_request.role,
              p_role_user_id   => FND_GLOBAL.user_id,
              p_unlock_current => FND_API.G_FALSE
            );

            IF (l_submit_for_buyer_acc_flag = FND_API.G_TRUE) THEN
              d_position := 60;

              IF (PO_LOG.d_stmt) THEN
                PO_LOG.stmt(d_module, d_position, 'launch buyer acceptance process');
              END IF;

              -- submit document for buyer acceptance
              PO_DIFF_SUMMARY_PKG.start_workflow
              ( p_po_header_id => l_doc_rec.po_header_id
              );

            END IF;

            l_process_code := PO_PDOI_CONSTANTS.g_PROCESS_CODE_ACCEPTED;
          ELSE
            d_position := 70;

            IF ( l_doc_info.has_lines_to_notify = FND_API.G_TRUE) THEN
              l_process_code := PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED;

              -- 5149827
              -- If the changes are to go over price tolerance acceptance
              -- process, they should be removed from the draft since
              -- we shouldn't transfer them to the trasnsaction table
              remove_notified_draft_lines
              ( p_draft_id => l_doc_rec.draft_id
              );
            ELSE
              l_process_code := PO_PDOI_CONSTANTS.g_PROCESS_CODE_ACCEPTED;
            END IF;

            -- Call different module for post processing according to document
            -- type and action
            IF PO_PDOI_PARAMS.g_request.document_type IN (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
                                                          PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD,
                                                          PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT) THEN

                  d_position := 80;
                  create_update_doc ( p_doc_rec      => l_doc_rec
                                    , p_doc_type     => PO_PDOI_PARAMS.g_request.document_type
                                    , p_action       => l_doc_rec.action
                                    , x_process_code => l_process_code);

            ELSIF (PO_PDOI_PARAMS.g_request.document_type =
                     PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN

              IF (l_doc_rec.action IN (PO_PDOI_CONSTANTS.g_ACTION_ADD,
                                       PO_PDOI_CONSTANTS.g_ACTION_ORIGINAL)) THEN

                d_position := 110;
                create_quotation(p_doc_rec => l_doc_rec);

              ELSIF (l_doc_rec.action = PO_PDOI_CONSTANTS.g_ACTION_REPLACE) THEN
                d_position := 120;
                expire_document(p_doc_rec => l_doc_rec);
                create_quotation(p_doc_rec => l_doc_rec);

              ELSIF (l_doc_rec.action = PO_PDOI_CONSTANTS.g_ACTION_UPDATE) THEN
                d_position := 130;
                update_quotation(p_doc_rec => l_doc_rec);

            END IF;

            d_position := 180;
           END IF;

          END IF;  -- if transfer_flag = FND_API.G_FALSE

          d_position := 190;
          UPDATE po_headers_interface
          SET    process_code = l_process_code
          WHERE  interface_header_id = l_doc_rec.interface_header_id;

          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'process_code', l_process_Code);
          END IF;

        ELSE
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'header gets rejected');
          END IF;

          -- bug5129752
          IF (l_remove_draft = FND_API.G_FALSE) THEN

            -- Change the draft status back to 'DRAFT' (it was set to
            -- 'PDOI PROCESSING' during header grouping)
            PO_DRAFTS_PVT.update_draft_status
            ( p_draft_id => l_doc_rec.draft_id,
              p_new_status => PO_DRAFTS_PVT.g_STATUS_DRAFT
            );

          END IF;
        END IF;

        PO_PDOI_UTL.commit_work;

      EXCEPTION
      WHEN OTHERS THEN
        PO_LOG.stmt(d_module, d_position, 'rollback to savepoint po_pdoi_doc_postproc_sp');

        ROLLBACK TO SAVEPOINT po_pdoi_doc_postproc_sp;
        RAISE;
      END;

    END LOOP;
  END LOOP;

  close c_doc;

--bug20368337, comment out following code, no need to launch workflow background process
--as the approval workflow has been changed to run with background flag = 'N'
  /*IF (PO_PDOI_PARAMS.g_request.document_type IN (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
                                              PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD,
                                              PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT))
    AND (PO_PDOI_PARAMS.g_request.approved_status IN (PO_PDOI_CONSTANTS.g_APPR_METHOD_INIT_APPROVAL ,
                                                      PO_PDOI_CONSTANTS.g_APPR_STATUS_APPROVED)) THEN
    launch_wf_background;
  END IF;*/


  PO_TIMING_UTL.stop_time (PO_PDOI_CONSTANTS.g_T_POSTPROCESSING);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF (c_doc%ISOPEN) THEN
    CLOSE c_doc;
  END IF;

  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END process;

-------------------------------------------------------
-------------- PRIVATE PROCEDURES ----------------------
-------------------------------------------------------

-- bug5149827 START
-----------------------------------------------------------------------
--Start of Comments
--Name: remove_notified_draft_lines
--Function:
--  Remove all lines that have notified status in the interface table.
--  These lines need to be removed because the acceptance process will be
--  based on top of the interface table.
--Parameters:
--IN:
--p_draft_id
--  Draft identifier
--IN OUT:
--OUT:
--x_header_rejected
--  Whether the document passed validation or not
--  FND_API.G_TRUE if passed
--  FND_API.G_FALSE otherwise
--End of Comments
------------------------------------------------------------------------
PROCEDURE remove_notified_draft_lines
( p_draft_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'remove_notified_draft_lines';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_po_line_id_tbl PO_TBL_NUMBER;
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  DELETE FROM po_lines_draft_all
  WHERE draft_id = p_draft_id
  AND   change_accepted_flag = PO_DRAFTS_PVT.g_chg_accepted_flag_NOTIFY
  RETURNING po_line_id
  BULK COLLECT
	INTO l_po_line_id_tbl;

  d_position := 10;

  FORALL i IN 1..l_po_line_id_tbl.COUNT
    DELETE FROM po_line_locations_draft_all
    WHERE draft_id = p_draft_id
    AND   po_line_id = l_po_line_id_tbl(i);

  d_position := 20;

  FORALL i IN 1..l_po_line_id_tbl.COUNT
    DELETE FROM po_attribute_values_draft
    WHERE draft_id = p_draft_id
    AND   po_line_id = l_po_line_id_tbl(i);

  d_position := 30;

  FORALL i IN 1..l_po_line_id_tbl.COUNT
    DELETE FROM po_attribute_values_tlp_draft
    WHERE draft_id = p_draft_id
    AND   po_line_id = l_po_line_id_tbl(i);

  d_position := 40;

  FORALL i IN 1..l_po_line_id_tbl.COUNT
    DELETE FROM po_price_diff_draft
    WHERE draft_id = p_draft_id
    AND   entity_id = l_po_line_id_tbl(i)
    AND   entity_type = 'BLANKET LINE';

  d_position := 50;

  FORALL i IN 1..l_po_line_id_tbl.COUNT
    DELETE FROM po_price_diff_draft PPDD
    WHERE draft_id = p_draft_id
    AND   entity_type = 'PRICE BREAK'
    AND   EXISTS (SELECT 1
                  FROM po_line_locations_draft_all PLLD
                  WHERE PLLD.draft_id = p_draft_id
                  AND PLLD.po_line_id = l_po_line_id_tbl(i)
                  AND PLLD.line_location_id = PPDD.entity_id
                  UNION ALL
                  SELECT 1
                  FROM po_line_locations_all PLLA
                  WHERE PLLA.po_line_id = l_po_line_id_tbl(i)
                  AND PLLA.line_location_id = PPDD.entity_id);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END remove_notified_draft_lines;

-- bug5149827 END

-----------------------------------------------------------------------
--Start of Comments
--Name: process_rejected_records
--Function:
--  For interface records that are rejected, we need to find out if we
--  need to clean up the draft of the document. Draft documents should be
--  deleted when:
--  1) Action is not update
--  2) Action = Update, and document type does not allow draft
--  3) Action = Update, and document type allows draft, but no changes have
--     been populated into PDOI for the draft (i.e. the draft was populated
--     by this PDOI run). Need to check this because there may already be
--     draft changes existing in the draft table before PDOI is called.
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--p_doc_info
--  Processing status values of the document
--IN OUT:
--OUT:
--x_header_rejected
--  Whether the document passed validation or not
--  FND_API.G_TRUE if passed
--  FND_API.G_FALSE otherwise
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_rejected_records IS

d_api_name CONSTANT VARCHAR2(30) := 'process_rejected_records';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_intf_header_id_tbl PO_TBL_NUMBER;
l_action_tbl PO_TBL_VARCHAR30;
l_dft_id_tbl PO_TBL_NUMBER;
l_po_header_id_tbl PO_TBL_NUMBER;

l_dft_to_delete_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

l_dft_exist_chg_check_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
l_chg_exist_tbl PO_TBL_VARCHAR1;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT PHI.interface_header_id,
         PHI.action,
         PHI.draft_id,
         PHI.po_header_id
  BULK COLLECT
  INTO   l_intf_header_id_tbl,
         l_action_tbl,
         l_dft_id_tbl,
         l_po_header_id_tbl
  FROM   po_headers_interface PHI
  WHERE  processing_id = -PO_PDOI_PARAMS.g_processing_id
  AND    processing_round_num = PO_PDOI_PARAMS.g_current_round_num;

  d_position := 10;

  FOR i IN 1..l_intf_header_id_tbl.COUNT LOOP
    -- If action is not 'UPDATE', remove draft
    IF ( l_action_tbl(i) <> PO_PDOI_CONSTANTS.g_action_UPDATE ) THEN
      d_position := 20;

      l_dft_to_delete_tbl.EXTEND;
      l_dft_to_delete_tbl(l_dft_to_delete_tbl.COUNT) := l_dft_id_tbl(i);

    ELSE
      d_position := 30;
      -- Update action

      IF (PO_DRAFTS_PVT.is_draft_applicable
          ( p_po_header_id => l_po_header_id_tbl(i),
            p_role => PO_PDOI_PARAMS.g_request.role
          ) = FND_API.G_FALSE ) THEN

        d_position := 40;

        l_dft_to_delete_tbl.EXTEND;
        l_dft_to_delete_tbl(l_dft_to_delete_tbl.COUNT) := l_dft_id_tbl(i);

      ELSE
        d_position := 50;

        -- If draft changes before PDOI runs is possible to exist,
        -- need to check if changes really exist. If so, do not remove
        -- draft control record
        l_dft_exist_chg_check_tbl.EXTEND;
        l_dft_exist_chg_check_tbl(l_dft_exist_chg_check_tbl.COUNT) :=
          l_dft_id_tbl(i);
      END IF;
    END IF;

  END LOOP;

  -- check whether the draft already contains changes
  l_chg_exist_tbl :=
    PO_DRAFTS_PVT.changes_exist_for_draft
    ( p_draft_id_tbl => l_dft_exist_chg_check_tbl
    );

  FOR i IN 1..l_dft_exist_chg_check_tbl.COUNT LOOP
    IF (l_chg_exist_tbl(i) = FND_API.G_FALSE) THEN
      l_dft_to_delete_tbl.EXTEND;
      l_dft_to_delete_tbl(l_dft_to_delete_tbl.COUNT) :=
        l_dft_exist_chg_check_tbl(i);
    END IF;
  END LOOP;

  FORALL i IN 1..l_dft_to_delete_tbl.COUNT
    DELETE po_drafts
    WHERE  draft_id = l_dft_to_delete_tbl(i);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END process_rejected_records;

-----------------------------------------------------------------------
--Start of Comments
--Name: post_validate
--Function:
--  Post validation for PDOI - Perform validations that have to be done
--  against the document as a whole
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--p_doc_info
--  Processing status values of the document
--IN OUT:
--OUT:
--x_header_rejected
--  Whether the document passed validation or not
--  FND_API.G_TRUE if passed
--  FND_API.G_FALSE otherwise
--x_remove_draft
--  Whether draft has been removed
--End of Comments
------------------------------------------------------------------------
PROCEDURE post_validate
( p_doc_rec IN doc_row_type,
  p_doc_info IN PO_PDOI_PARAMS.doc_info_rec_type,
  x_header_rejected OUT NOCOPY VARCHAR2,
  x_remove_draft OUT NOCOPY VARCHAR2  -- bug5129752
) IS

d_api_name CONSTANT VARCHAR2(30) := 'post_validate';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_is_quotation BOOLEAN := FALSE;
l_is_local_bpa BOOLEAN := FALSE;
l_is_std_po    BOOLEAN := FALSE;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_header_rejected := FND_API.G_FALSE;

  -- Check 1: If a document has errors, Reject the whole document in the
  --          following situations
  -- 1) Standard PO
  -- 2) Local blankets uploaded through catalog upload
  -- 3) Quotation upload through catalog upload (bug5461177)

  IF ( p_doc_info.has_errors = FND_API.G_TRUE ) THEN

    IF (PO_PDOI_PARAMS.g_request.document_type =
          PO_PDOI_CONSTANTS.g_doc_type_STANDARD) THEN

      l_is_std_po := TRUE;

    ELSIF (PO_PDOI_PARAMS.g_request.document_type =
             PO_PDOI_CONSTANTS.g_doc_type_BLANKET
           AND p_doc_rec.ga_flag <> 'Y') THEN

      l_is_local_bpa := TRUE;

    ELSIF (PO_PDOI_PARAMS.g_request.document_type =
             PO_PDOI_CONSTANTS.g_doc_type_QUOTATION) THEN

      l_is_quotation := TRUE;

    END IF;

    IF (l_is_std_po
        OR
        ( (l_is_local_bpa OR l_is_quotation)
          AND
          PO_PDOI_PARAMS.g_request.calling_module =
            PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD )) THEN

      d_position := 10;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'failed Check 1');
      END IF;

      x_header_rejected := FND_API.G_TRUE;

    END IF;
  END IF;

  d_position := 20;

  -- add more checks here
  -- Check 2: There should at least be one line that is valid
  IF (x_header_rejected = FND_API.G_FALSE) THEN
    IF ( PO_PDOI_PARAMS.g_request.document_type <> PO_PDOI_CONSTANTS.g_doc_type_CONTRACT
	     AND p_doc_info.number_of_valid_lines = 0 ) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'failed Check 2');
      END IF;

      IF ( p_doc_rec.action <> PO_PDOI_CONSTANTS.g_ACTION_UPDATE ) THEN
        -- If action <> update, we need to tell user that the document created
        -- has 0 line, and thus the failure

        PO_PDOI_ERR_UTL.add_fatal_error
        ( p_interface_header_id => p_doc_rec.interface_header_id,
          p_error_message_name  => 'PO_PDOI_INVALID_NUM_OF_LINES',
          p_table_name          => 'PO_HEADERS_INTERFACE',
          p_column_name         => 'PO_HEADER_ID',
          p_column_value        => p_doc_rec.po_header_id,
          p_token1_name         => 'COLUMN_NAME',
          p_token1_value        => 'PO_HEADER_ID'
        );

      END IF;

      x_header_rejected := FND_API.G_TRUE;
    END IF;
  END IF;

  x_remove_draft := FND_API.G_FALSE;

  IF (x_header_rejected = FND_API.G_TRUE) THEN

    -- bug5129752
    -- Calculate x_remove_draft flag

    IF ( PO_PDOI_PARAMS.g_docs_info(p_doc_rec.interface_header_id).new_draft =
           FND_API.G_TRUE) THEN
      x_remove_draft := FND_API.G_TRUE;
    END IF;

    -- If post validation fails, since records are already in draft tables,
    -- besides setting the interface record to 'REJECTED', we also need to
    -- remove the draft.
    PO_PDOI_UTL.post_reject_document
    ( p_interface_header_id => p_doc_rec.interface_header_id,
      p_po_header_id        => p_doc_rec.po_header_id,
      p_draft_id            => p_doc_rec.draft_id,
      p_remove_draft        => x_remove_draft  -- bug5129752
    );
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END post_validate;

-----------------------------------------------------------------------
--Start of Comments
--Name: transfer_document_check
--Function:
--  Determines whether document needs to be transferred to transaction table,
--  and if it does not get transferred, do we submit the document for buyer
--  acceptance
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--p_doc_info
--  Processing status values of the document
--IN OUT:
--OUT:
--x_transfer_flag
--  FND_API.G_TRUE if transfer needs to happen
--  FND_API.G_FALSE otherwise
--x_submit_for_buyer_acc_flag
--  FND_API.G_TRUE if the draft is submitted for buyer acceptance
--  FND_API.G_FALSE otherwise
--End of Comments
------------------------------------------------------------------------
PROCEDURE transfer_document_check
( p_doc_rec                   IN doc_row_type,
  p_doc_info                  IN PO_PDOI_PARAMS.doc_info_rec_type,
  x_transfer_flag             OUT NOCOPY VARCHAR2,
  x_submit_for_buyer_acc_flag OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'transfer_document_check';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_has_over_tolerance_lines VARCHAR2(1) := FND_API.G_FALSE;
l_role_auth_acceptance VARCHAR2(30);

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- transfer if
  -- 1) document is not a global agreement, OR
  -- 2) role of the user is BUYER

  IF (NOT (PO_PDOI_PARAMS.g_request.document_type =
             PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET
           AND
           p_doc_rec.ga_flag = 'Y')
      OR
      PO_PDOI_PARAMS.g_request.role = PO_GLOBAL.g_role_BUYER) THEN

    d_position := 10;
    x_transfer_flag := FND_API.G_TRUE;
  ELSE
    d_position := 20;

    x_transfer_flag := FND_API.G_FALSE;

    -- If there is any line erroring out, or user explicitly prevents the
    -- document to be submitted, then document will not be submitted for
    -- buyer acceptance
    IF (p_doc_info.number_of_errored_lines > 0
        OR NVL(PO_PDOI_PARAMS.g_request.submit_dft_flag, 'N') = 'N') THEN

      x_submit_for_buyer_acc_flag := FND_API.G_FALSE;
    ELSE
      x_submit_for_buyer_acc_flag := FND_API.G_TRUE;
    END IF;

  END IF;  -- if not ga or ...

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'x_transfer_flag', x_transfer_flag);
    PO_LOG.stmt(d_module, d_position, 'x_submit_for_buyer_acc_flag',
                x_submit_for_buyer_acc_flag);
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END transfer_document_check;

-----------------------------------------------------------------------
--Start of Comments
--Name: create_quotation
--Function:
--  Performs necessary post processing action to create a quotation
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE create_quotation
( p_doc_rec IN doc_row_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'create_quotation';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;


l_approval_method VARCHAR2(30);

l_need_to_create_src_rules VARCHAR2(1);
l_lines                    src_rule_lines_rec_type;
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  assign_document_number ( p_doc_rec => p_doc_rec );

  d_position := 10;
  l_need_to_create_src_rules := need_to_create_sourcing_rules
                                ( p_doc_rec => p_doc_rec
                                );

  IF (l_need_to_create_src_rules = FND_API.G_TRUE) THEN
    d_position := 20;
    get_lines_for_src_rules
    ( p_doc_rec => p_doc_rec,
      x_lines => l_lines
    );

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, '# lines requiring src rules: ' || l_lines.po_line_id_tbl.COUNT);
    END IF;
  END IF;

  d_position := 30;
  transfer_draft_to_txn( p_doc_rec => p_doc_rec
                       , p_doc_type => PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION);

  d_position := 40;
  get_approval_method
  ( p_doc_rec => p_doc_rec,
    x_approval_method => l_approval_method
  );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_approval_method', l_approval_method);
  END IF;

  IF (l_approval_method = PO_PDOI_CONSTANTS.g_appr_method_AUTO_APPROVE) THEN
    IF (l_need_to_create_src_rules = FND_API.G_TRUE) THEN
      d_position := 50;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'creating sourcing rules');
      END IF;

      process_sourcing_rules
      ( p_doc_rec => p_doc_rec,
        p_approval_status => 'APPROVED',
        p_lines => l_lines
      );
    END IF;

    d_position := 60;
    update_document_status
    ( p_doc_rec            => p_doc_rec,
      p_auth_status        => NULL,
      p_status_lookup_code => 'A'
    );
  END IF;

  -- <Unified Catalog R12 START>
  -- When importing quotation, we need to rebuild the index
  -- for the catalog
  d_position := 70;

  rebuild_catalog_index
  ( p_type => PO_PDOI_CONSTANTS.g_doc_type_QUOTATION,
    p_doc_rec => p_doc_rec
  );
  -- <Unified Catalog R12 END>

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END create_quotation;

-----------------------------------------------------------------------
--Start of Comments
--Name: update_quotation
--Function:
--  Performs necessary post processing action to update a quotation
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_quotation
( p_doc_rec IN doc_row_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'update_quotation';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;


l_approval_method VARCHAR2(30);

l_doc_info PO_PDOI_PARAMS.doc_info_rec_type;

l_need_to_create_src_rules VARCHAR2(1);
l_lines                    src_rule_lines_rec_type;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  l_doc_info := PO_PDOI_PARAMS.g_docs_info(p_doc_rec.interface_header_id);

  d_position := 20;
  l_need_to_create_src_rules := need_to_create_sourcing_rules
                                ( p_doc_rec => p_doc_rec
                                );

  IF (l_need_to_create_src_rules = FND_API.G_TRUE) THEN
    d_position := 30;
    get_lines_for_src_rules
    ( p_doc_rec => p_doc_rec,
      x_lines => l_lines
    );

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, '# lines requiring src rules: ' ||
                  l_lines.po_line_id_tbl.COUNT);
    END IF;
  END IF;

  d_position := 40;
  transfer_draft_to_txn(  p_doc_rec => p_doc_rec
                        , p_doc_type => PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION);

  IF (l_doc_info.has_lines_to_notify = FND_API.G_TRUE) THEN
    d_position := 10;

    -- set header level process code to NOTIFIED
    UPDATE po_headers_interface
    SET    process_code = 'NOTIFIED'
    WHERE  interface_header_id = p_doc_rec.interface_header_id;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'start price tolerance workflow');
    END IF;

    -- start workflow
    PO_PDOI_PRICE_TOLERANCE_PVT.start_price_tolerance_wf
    (
      p_intf_header_id    => p_doc_rec.interface_header_id,
      p_po_header_id      => p_doc_rec.po_header_id,
      p_document_num      => p_doc_rec.document_num,
      p_batch_id      => PO_PDOI_PARAMS.g_request.batch_id,
      p_document_type     => p_doc_rec.document_type,
      p_document_subtype  => p_doc_rec.document_subtype,
      p_commit_interval    => 1, -- parameter removed in R12
      p_any_line_updated  => l_doc_info.has_lines_updated,
      p_buyer_id      => PO_PDOI_PARAMS.g_request.buyer_id,
      p_agent_id          => p_doc_rec.agent_id,
      p_vendor_id         => p_doc_rec.vendor_id,
      p_vendor_name       => p_doc_rec.vendor_name
    );

  ELSE

    d_position := 50;
    get_approval_method
    ( p_doc_rec => p_doc_rec,
      x_approval_method => l_approval_method
    );

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'l_approval_method', l_approval_method);
    END IF;

    IF (l_approval_method = PO_PDOI_CONSTANTS.g_appr_method_AUTO_APPROVE) THEN
      IF (l_need_to_create_src_rules = FND_API.G_TRUE) THEN
        d_position := 60;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'Creating Sourcing rules');
        END IF;

        process_sourcing_rules
        ( p_doc_rec => p_doc_rec,
          p_approval_status => 'APPROVED',
          p_lines => l_lines
        );
      END IF;
    END IF;
  END IF;

  -- <Unified Catalog R12 START>
  -- When importing quotation, we need to rebuild the index
  -- for the catalog
  d_position := 70;

  rebuild_catalog_index
  ( p_type => PO_PDOI_CONSTANTS.g_doc_type_QUOTATION,
    p_doc_rec => p_doc_rec
  );
  -- <Unified Catalog R12 END>

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END update_quotation;

-----------------------------------------------------------------------
--Start of Comments
--Name: expire_document
--Function:
--  Expires a document, identified by orig_po_header_id column
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE expire_document
( p_doc_rec IN doc_row_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'expire_document';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_expiration_date DATE;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  l_expiration_date := p_doc_rec.intf_start_date - 1;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_expiration_date', l_expiration_date);
  END IF;

  UPDATE po_headers_all
  SET    start_date = NVL(start_date, l_expiration_date),
         end_date = l_expiration_date,
         last_updated_by = FND_GLOBAL.user_id,
         last_update_date = SYSDATE
  WHERE po_header_id = p_doc_rec.orig_po_header_id;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END expire_document;



-----------------------------------------------------------------------
--Start of Comments
--Name: assign_document_number
--Function:
--  Assign document number for document being imported
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE assign_document_number
( p_doc_rec IN doc_row_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'assign_document_number';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_document_num PO_HEADERS_ALL.segment1%TYPE;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- bug5024833
  -- Do not generate the po number from the system if number generation
  -- method is Manual
  IF (  (PO_PDOI_PARAMS.g_request.document_type =
           PO_PDOI_CONSTANTS.g_doc_type_QUOTATION AND
         PO_PDOI_PARAMS.g_sys.user_defined_quote_num_code = 'MANUAL')
      OR
        (PO_PDOI_PARAMS.g_request.document_type IN
           (PO_PDOI_CONSTANTS.g_doc_type_BLANKET,
            PO_PDOI_CONSTANTS.g_doc_type_CONTRACT, --PDOI Enhancement Bug#17063664
            PO_PDOI_CONSTANTS.g_doc_type_STANDARD) AND
         PO_PDOI_PARAMS.g_sys.user_defined_po_num_code = 'MANUAL')) THEN

    d_position := 10;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Manual numbering. No need to generate new number');
    END IF;

  ELSIF (p_doc_rec.doc_num_provided = 'Y') THEN
    -- bug5028275
    -- If user provides their own document number, use the one they provide
    d_position := 20;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'User provides document number. No need to generate new number');
    END IF;

  ELSE
    d_position := 30;

    IF (PO_PDOI_PARAMS.g_request.document_type =
          PO_PDOI_CONSTANTS.g_doc_type_QUOTATION) THEN

      l_document_num := PO_CORE_SV1.default_po_unique_identifier
                        ( x_table_name => 'PO_HEADERS_QUOTE'
                        );
    ELSIF (PO_PDOI_PARAMS.g_request.document_type IN
             ( PO_PDOI_CONSTANTS.g_doc_type_BLANKET,
               PO_PDOI_CONSTANTS.g_doc_type_CONTRACT, --PDOI Enhancement Bug#17063664
               PO_PDOI_CONSTANTS.g_doc_type_STANDARD)) THEN

      l_document_num := PO_CORE_SV1.default_po_unique_identifier
                        ( x_table_name => 'PO_HEADERS'
                        );
    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Get new document number');
      PO_LOG.stmt(d_module, d_position, 'l_document_num', l_document_num);
    END IF;

    d_position := 40;

    UPDATE po_headers_draft_all
    SET segment1 = l_document_num
    WHERE po_header_id = p_doc_rec.po_header_id;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END assign_document_number;

-----------------------------------------------------------------------
--Start of Comments
--Name: need_to_create_sourcing_rules
--Function:
--  Check whether sourcing rules need to be created
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--Returns:
--End of Comments
------------------------------------------------------------------------
FUNCTION need_to_create_sourcing_rules
( p_doc_rec IN doc_row_type
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'need_to_create_sourcing_rules';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF ( NVL(p_doc_rec.load_sourcing_rules_flag,
           PO_PDOI_PARAMS.g_request.create_sourcing_rules_flag) = 'Y') THEN
    RETURN FND_API.G_TRUE;
  ELSE
    RETURN FND_API.G_FALSE;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END need_to_create_sourcing_rules;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_lines_for_src_rules
--Function:
--  Find out all the lines that may require sourcing rules to be created for
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--x_lines
--  Lines that require sourcing rules creation
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_lines_for_src_rules
( p_doc_rec IN doc_row_type,
  x_lines OUT NOCOPY src_rule_lines_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'get_lines_for_src_rules';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  --SQL What: Select columns needed for calling sourcing rule/asl creation
  --          API. Lines that are in draft but not transaction table will
  --          be candidates for sourcing rules creation.
  --SQL Why: Need to find out what lines are new lines being created so
  --         that sourcing rules and ASLs are updated accordingly

  -- bug4181354: Do not send lines for sourcing rules creation if
  --             it's a price break line.

  SELECT PLD.po_line_id,
         PLD.item_id,
         PLD.category_id,
         PLI.interface_line_id,
         PLI.sourcing_rule_name,
         PLI.effective_date,
         PLI.expiration_date
  BULK COLLECT
  INTO x_lines.po_line_id_tbl,
       x_lines.item_id_tbl,
       x_lines.category_id_tbl,
       x_lines.interface_line_id_tbl,
       x_lines.sourcing_rule_name_tbl,
       x_lines.effective_date_tbl,
       x_lines.expiration_date_tbl
  FROM po_headers_interface PHI,
       po_lines_interface PLI,
       po_lines_draft_all PLD
  WHERE PHI.interface_header_id = p_doc_rec.interface_header_id
  AND   PHI.interface_header_id = PLI.interface_header_id
  AND   PHI.draft_id = PLD.draft_id
  AND   PLI.po_line_id = PLD.po_line_id
  AND   NVL(PLI.price_break_flag, 'N') <> 'Y'
  AND   PLD.item_id IS NOT NULL
  AND   PLD.order_type_lookup_code = 'QUANTITY'
  AND   NOT EXISTS
          (SELECT 1
           FROM   po_lines_all PLA
           WHERE  PLD.po_line_id = PLA.po_line_id);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END get_lines_for_src_rules;


-----------------------------------------------------------------------
--Start of Comments
--Name: process_sourcing_rules
--Function:
--  Call an API to create sourcing rules and ASL
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--p_approval_status
--  Approval status of the document
--p_lines
--  Lines that require sourcing rules creation
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_sourcing_rules
( p_doc_rec IN doc_row_type,
  p_approval_status IN VARCHAR2,
  p_lines IN src_rule_lines_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'process_sourcing_rules';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_vendor_id PO_VENDORS.vendor_id%TYPE;
l_vendor_site_id PO_VENDOR_SITES_ALL.vendor_site_id%TYPE;

l_header_processable_flag VARCHAR2(1) := 'Y';

l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_lines.po_line_id_tbl IS NULL) THEN
    d_position := 10;
    RETURN;
  ELSE
    d_position := 20;
    SELECT vendor_id,
           vendor_site_id
    INTO   l_vendor_id,
           l_vendor_site_id
    FROM   po_headers_all
    WHERE  po_header_id = p_doc_rec.po_header_id;

    FOR i IN 1..p_lines.po_line_id_tbl.COUNT LOOP
      d_position := 30;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'processing po_line_id: ' ||
                    p_lines.po_line_id_tbl(i));
      END IF;

      PO_CREATE_SR_ASL.create_sourcing_rules_asl
      ( p_api_version => 1.0,
        p_init_msg_list => FND_API.G_FALSE,
        p_commit => FND_API.G_FALSE,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data,
        p_interface_header_id => p_doc_rec.interface_header_id,
        p_interface_line_id => p_lines.interface_line_id_tbl(i),
        p_document_id => p_doc_rec.po_header_id,
        p_po_line_id => p_lines.po_line_id_tbl(i),
        p_document_type => PO_PDOI_PARAMS.g_request.document_type,
        p_approval_status => p_approval_status,
        p_vendor_id => l_vendor_id,
        p_vendor_site_id => l_vendor_site_id,
        p_inv_org_id => PO_PDOI_PARAMS.g_request.sourcing_inv_org_id,
        p_sourcing_level => PO_PDOI_PARAMS.g_request.sourcing_level,
        p_item_id => p_lines.item_id_tbl(i),
        p_category_id => p_lines.category_id_tbl(i),
        p_rel_gen_method => PO_PDOI_PARAMS.g_request.rel_gen_method,
        p_rule_name => p_lines.sourcing_rule_name_tbl(i),
        p_rule_name_prefix => 'PURCH_OPEN_INTERFACE',
        p_start_date => p_lines.effective_date_tbl(i),
        p_end_date => p_lines.expiration_date_tbl(i),
        p_assignment_set_id => NULL,
        p_create_update_code => 'CREATE_UPDATE',
        p_interface_error_code => 'PO_DOCS_OPEN_INTERFACE',
        x_header_processable_flag => l_header_processable_flag
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        d_position := 40;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'Sourcing rule creation failed' ||
                      ' with status: ' || l_return_status || '. Continue to ' ||
                      'process.' );
        END IF;

      END IF;
    END LOOP;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END process_sourcing_rules;

-----------------------------------------------------------------------
--Start of Comments
--Name: transfer_draft_to_txn
--Function:
--  Call transfer API to move data from draft to transaction
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
-- p_doc_type
-- document type
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE transfer_draft_to_txn
(  p_doc_rec  IN doc_row_type
 , p_doc_type IN VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'transfer_draft_to_txn';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_delete_processed_draft VARCHAR2(1);
l_return_status VARCHAR2(1);

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- bug5149827
  -- Delete draft if buyer initiates PDOI or document is not GA
  IF (PO_PDOI_PARAMS.g_request.role = PO_GLOBAL.g_role_BUYER
	    OR
      p_doc_rec.ga_flag <> 'Y') THEN
    l_delete_processed_draft := FND_API.G_TRUE;
  ELSE
    l_delete_processed_draft := FND_API.G_FALSE;
  END IF;

  d_position := 10;

  PO_DRAFTS_PVT.transfer_draft_to_txn
  ( p_api_version => 1.0,
    p_init_msg_list => FND_API.G_FALSE,
    p_draft_id => p_doc_rec.draft_id,
    p_po_header_id => p_doc_rec.po_header_id,
    p_delete_processed_draft => l_delete_processed_draft,
    p_acceptance_action => NULL,
    x_return_status => l_return_status
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- bug4907624
  -- Commit txn table changes once transfer is done

  -- <PDOI Enhancement Bug#17063664>
  -- Commit only for quotation
  -- Commit for Standard/Blanket/Contract is moved outside.
  IF p_doc_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION THEN
      PO_PDOI_UTL.commit_work;
      SAVEPOINT po_pdoi_doc_postproc_sp;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END transfer_draft_to_txn;



-----------------------------------------------------------------------
--Start of Comments
--Name: get_approval_method
--Function:
--  Get the method that will be used for approval
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--x_approval_method
--   PO_PDOI_CONSTANTS.g_appr_method_NONE: No approval
--   PO_PDOI_CONSTANTS.g_appr_method_AUTO_APPROVE: Approve within PDOI
--   PO_PDOI_CONSTANTS.g_appr_method_INIT_APPROVAL: Launch approval wf
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_approval_method
( p_doc_rec IN doc_row_type,
  x_approval_method OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'get_approval_method';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_intended_approval_status PO_HEADERS_INTERFACE.approval_status%TYPE;
BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_approval_method := PO_PDOI_CONSTANTS.g_appr_method_NONE;
  -- 8597275 commenting the following statement and added the if logic to determine the approval status
  /*l_intended_approval_status :=
    NVL(p_doc_rec.intf_auth_status, PO_PDOI_PARAMS.g_request.approved_status);*/

    --<<start of fix 8597275 >> ----
 	      IF p_doc_rec.intf_auth_status IS NULL THEN
 	         l_intended_approval_status := PO_PDOI_PARAMS.g_request.approved_status;

           -- <<PDOI Enhancement Bug#17063664> >
           -- Removed the condition of Approved from the below If condition
           -- INITIATE APPROVAL should be honoured only for NULL/INCOMPLETE status.
 	     ELSIF p_doc_rec.intf_auth_status = 'INCOMPLETE'
 	          AND  PO_PDOI_PARAMS.g_request.approved_status = 'INITIATE APPROVAL' THEN
 	         l_intended_approval_status := 'INITIATE APPROVAL';
 	     ELSE
 	         l_intended_approval_status := p_doc_rec.intf_auth_status;
 	     END IF;
   --<<end of fix 8597275 >> ----

  --------- Blanket or Standard PO -----------
  IF (PO_PDOI_PARAMS.g_request.document_type IN
        (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
         PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD,
	 PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT)) THEN

    IF ( l_intended_approval_status = 'INCOMPLETE' OR
         p_doc_rec.orig_user_hold_flag = 'Y') THEN

      -- Do not approve the document. The authorization status will be set
      -- properly by the transfer program.
      x_approval_method := PO_PDOI_CONSTANTS.g_appr_method_NONE;

    ELSIF ( l_intended_approval_status = 'APPROVED') THEN

      x_approval_method := PO_PDOI_CONSTANTS.g_appr_method_AUTO_APPROVE;

    ELSIF ( l_intended_approval_status = 'INITIATE APPROVAL') THEN

      x_approval_method := PO_PDOI_CONSTANTS.g_appr_method_INIT_APPROVAL;
    END IF;

  --------- Quotation -----------
  ELSIF (PO_PDOI_PARAMS.g_request.document_type =
           PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN

    IF ( p_doc_rec.orig_auth_status = 'A' OR
         l_intended_approval_status IN ('APPROVED', 'INITIATE APPROVAL')) THEN

      x_approval_method := PO_PDOI_CONSTANTS.g_appr_method_AUTO_APPROVE;
    END IF;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END get_approval_method;

----------------------------------------------------------------------
--Start of Comments
--Name: update_document_status
--Function:
--  Update document authorization status
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--p_auth_status
--  New authorization status. Used by Standard PO and Blanket
--p_status_lookup_code
--  New status of quotation
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_document_status
( p_doc_rec            IN doc_row_type,
  p_auth_status        IN VARCHAR2,
  p_status_lookup_code IN VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'update_document_status';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_approved_flag PO_HEADERS_ALL.approved_flag%TYPE;
l_approved_date PO_HEADERS_ALL.approved_date%TYPE;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_PDOI_PARAMS.g_request.document_type IN
        (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
         PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT,
         PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD)) THEN

    IF (p_auth_status = 'INCOMPLETE') THEN
      l_approved_flag := NULL;
      l_approved_date := NULL;
    /*Bug 8490582 The following code cause the status to update wrongly and document not visible on form/page so commenting the line
      ELSIF (p_auth_status = 'REQUIRES_REAPPROVAL') THEN    */
    ELSIF (p_auth_status = 'REQUIRES REAPPROVAL') THEN
      l_approved_flag := 'R';
      l_approved_date := FND_API.G_MISS_DATE;
    ELSIF (p_auth_status = 'REJECTED') THEN         --8597275
      l_approved_flag := 'F';
      l_approved_date := FND_API.G_MISS_DATE;
    ELSIF (p_auth_status = 'PRE-APPROVED') THEN
      l_approved_flag := 'N';
      l_approved_date := FND_API.G_MISS_DATE;
    ELSIF (p_auth_status = 'APPROVED') THEN
      l_approved_flag := 'Y';
      l_approved_date := SYSDATE;
    ELSE
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSIF (PO_PDOI_PARAMS.g_request.document_type =
          PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN

    l_approved_flag := NULL;
    l_approved_date := NULL;
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'p_auth_status', p_auth_status);
    PO_LOG.stmt(d_module, d_position, 'l_approved_flag', l_approved_flag);
    PO_LOG.stmt(d_module, d_position, 'l_approved_date', l_approved_date);
  END IF;

  d_position := 10;
  UPDATE po_headers_all
  SET    authorization_status = p_auth_status,
         approved_flag = l_approved_flag,
         approved_date = DECODE(l_approved_date,
                                FND_API.G_MISS_DATE, approved_date,
                                l_approved_date),
         last_update_date = SYSDATE,
         last_updated_by = FND_GLOBAL.user_id,
         last_update_login = FND_GLOBAL.login_id
  WHERE  po_header_id = p_doc_rec.po_header_id;

  IF (p_auth_status = 'APPROVED') THEN
    d_position := 20;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Update shipment approval status');
    END IF;

    -- Shipments/Price Breaks should be marked as APPROVED if the document
    -- is imported as approved
    UPDATE po_line_locations_all
    SET    approved_flag = 'Y',
           approved_date = l_approved_date,
           last_update_date = SYSDATE,
           last_updated_by = FND_GLOBAL.user_id,
           last_update_login = FND_GLOBAL.login_id
    WHERE  po_header_id = p_doc_rec.po_header_id
    AND    shipment_type IN ('STANDARD', 'PRICE BREAK')
    AND    NVL(approved_flag, 'N') <> 'Y';

    d_position := 30;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Update action history');
    END IF;
    -- need to update action history when we approve
    PO_FORWARD_SV1.update_action_history
    ( x_object_id => p_doc_rec.po_header_id,
      x_object_type_code => PO_PDOI_PARAMS.g_request.document_type,
      x_old_employee_id => p_doc_rec.agent_id,
      x_action_code => 'APPROVE',
      x_note => NULL,
      x_user_id => FND_GLOBAL.user_id,
      x_login_id => FND_GLOBAL.login_id
    );

    -- Approved document should not have functional lock
    PO_DRAFTS_PVT.unlock_document
    ( p_po_header_id => p_doc_rec.po_header_id
    );
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END update_document_status;

-----------------------------------------------------------------------
--Start of Comments
--Name: start_po_approval_workflow
--Function:
--  Launch approval workflow
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE start_po_approval_workflow
( p_doc_rec IN doc_row_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'start_po_approval_workflow';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_doc_type       VARCHAR2(30);
l_doc_subtype    VARCHAR2(30);

l_agent_id       PO_HEADERS_ALL.agent_id%TYPE;
l_default_method VARCHAR2(30);
l_email_address  PO_VENDOR_SITES_ALL.email_address%TYPE;
l_fax_number     VARCHAR2(100);
l_document_num   PO_HEADERS_ALL.segment1%TYPE;

l_email_flag     VARCHAR2(1) := 'N';
l_fax_flag       VARCHAR2(1) := 'N';
l_print_flag     VARCHAR2(1) := 'N';

l_current_employee_id  per_workforce_current_x.person_id%TYPE :=NULL; --Bug 13627272
BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_PDOI_UTL.get_processing_doctype_info
  ( x_doc_type => l_doc_type,
    x_doc_subtype => l_doc_subtype
  );

  l_agent_id := p_doc_rec.agent_id;

  d_position := 10;
  PO_VENDOR_SITES_SV.get_transmission_defaults
  ( p_document_id => p_doc_rec.po_header_id,
    p_document_type => l_doc_type,
    p_document_subtype => l_doc_subtype,
    p_preparer_id => l_agent_id,
    x_default_method => l_default_method,
    x_email_address => l_email_address,
    x_fax_number => l_fax_number,
    x_document_num => l_document_num
  );

  IF (l_default_method = 'EMAIL' AND l_email_address IS NOT NULL) THEN
    l_email_flag := 'Y';
    l_fax_number := NULL;
  ELSIF (l_default_method = 'FAX' AND l_fax_number IS NOT NULL) THEN
    l_fax_flag := 'Y';
    l_email_address := NULL;
  ELSE
    l_email_flag := NULL;
    l_fax_number := NULL;

    IF (l_default_method = 'PRINT') THEN
      l_print_flag := 'Y';
    END IF;
  END IF;
  --<<8686214 start>>
       begin
             update po_headers_all
             set SUPPLIER_NOTIF_METHOD = nvl(l_default_method,'NONE'),
                 EMAIL_ADDRESS         = l_email_address,
                 FAX                   = l_fax_number
             where po_header_id        =  p_doc_rec.po_header_id;
       EXCEPTION
           WHEN OTHERS THEN
           NULL;
       END;
 --<<8686214 end>>

 --Bug 13627272

  IF(PO_PDOI_PARAMS.g_request.calling_module = PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD) THEN

        BEGIN
            SELECT emp.person_id
            INTO   l_current_employee_id
            FROM   fnd_user fu,
                   per_workforce_current_x emp,
                   po_agents poa
            WHERE  fu.user_id = fnd_global.user_id
                   AND fu.employee_id = emp.person_id (+)
                   AND emp.person_id = poa.agent_id (+)
                   AND SYSDATE BETWEEN Nvl(poa.start_date_active (+), SYSDATE - 1) AND
                                           Nvl(poa.end_date_active (+), SYSDATE + 1);
        EXCEPTION
            WHEN OTHERS THEN
              l_current_employee_id := NULL;
        END;

 END IF;

  d_position := 20;

  -- Call Approval Workflow
  -- ItemTYpe, ItemKey and WorkflowProcess will be filled in by
  -- the approval workflow
  PO_REQAPPROVAL_INIT1.start_wf_process
  ( ItemType => NULL,
    ItemKey => NULL,
    WorkflowProcess => NULL,
    ActionOriginatedFrom => 'PDOI',
    DocumentId => p_doc_rec.po_header_id,
    DocumentNumber => NULL,  -- Obsolete parameter
    PreparerId =>Nvl(l_current_employee_id,p_doc_rec.agent_id), --Bug 13627272
    DocumentTypeCode => l_doc_type,
    DocumentSubtype => l_doc_subtype,
    SubmitterAction => 'APPROVE',
    ForwardToId => NULL,
    ForwardFromId => NULL,
    DefaultApprovalPathId => NULL,
    Note => NULL,
    PrintFlag => l_print_flag,
    FaxFlag => l_fax_flag,
    FaxNumber => l_fax_number,
    EmailFlag => l_email_flag,
    EmailAddress => l_email_address,
    CreateSourcingRule => PO_PDOI_PARAMS.g_request.create_sourcing_rules_flag,
    ReleaseGenMethod => PO_PDOI_PARAMS.g_request.rel_gen_method,
    UpdateSourcingRule => PO_PDOI_PARAMS.g_request.create_sourcing_rules_flag,
    p_Background_Flag => 'N', --<PDOI Enhancement Bug#17063664> --change to N for bug 20368337
    p_sourcing_level => PO_PDOI_PARAMS.g_request.sourcing_level, /*BUG19701485*/
    p_sourcing_inv_org_id => PO_PDOI_PARAMS.g_request.sourcing_inv_org_id /*BUG19701485*/
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END start_po_approval_workflow;

-----------------------------------------------------------------------
--Start of Comments
--Name: rebuild_catalog_index
--Function:
--  Call a PO API that rebuilds the catalog index for document currently
--  being processed
--Parameters:
--IN:
--p_type
--  Type of the document to rebuild index on
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE rebuild_catalog_index
( p_type         IN VARCHAR2,
  p_doc_rec      IN doc_row_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'rebuild_catalog_index';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- bug5027915
  -- populate parameter p_po_header_id rather than p_po_header_ids,
  -- which is used only when type is 'BLANKET_BULK'
  PO_CATALOG_INDEX_PVT.rebuild_index
  ( p_type          => p_type,
    p_po_header_id  => p_doc_rec.po_header_id
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END rebuild_catalog_index;


-----------------------------------------------------------------------
--Start of Comments
--Name: calculate_tax
--Function:
--  Calculate tax by integrating with eTax module.
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--x_return_status
--  status of the eTax API call
--End of Comments
------------------------------------------------------------------------
PROCEDURE calculate_tax
( p_doc_rec       IN doc_row_type,
  x_return_status OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'calculate_tax';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

--<<PDOI Enhancement Bug#170636664 START>>
l_line_loc_id_tbl    PO_TBL_NUMBER;
l_tax_name_tbl       PO_TBL_VARCHAR30;
p_calling_program    VARCHAR2(30);
--<<PDOI Enhancement Bug#170636664 END>>

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  --<<PDOI Enhancement Bug#170636664 START>>

  IF PO_PDOI_PARAMS.g_request.calling_module IN
   ( PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
     PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
     PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN

    p_calling_program := PO_PDOI_CONSTANTS.g_TAX_CALL_MOD_AUTOCREATE;
  ELSE
    p_calling_program := PO_PDOI_CONSTANTS.g_TAX_CALL_MOD_PDOI;
  END IF;

  IF p_calling_program = PO_PDOI_CONSTANTS.g_TAX_CALL_MOD_PDOI THEN
    -- SQL What: Select line location id and tax name
    --           for all the shipments which are being
    --           updated
    -- SQL Why: Need the value to restore back
    --          on the po_line_locations_all
    --          after tax calculation
    -- SQL Join: line_location_id

    SELECT poll.line_location_id,plli.tax_name
    BULK COLLECT  INTO l_line_loc_id_tbl,l_tax_name_tbl
    FROM po_line_locations_all poll,
         po_line_locations_interface plli
    WHERE poll.line_location_id = plli.line_location_id
    AND   plli.interface_header_id = p_doc_rec.interface_header_id
    AND   plli.action=PO_PDOI_CONSTANTS.g_ACTION_UPDATE
    AND   poll.tax_name IS NOT NULL;

    -- Updating the tax name on po_line_locations_all
    -- as tax name on txn table should not
    -- be considered during tax calculation for shipment
    -- being updated.This is required as caluclate tax api
    -- always considers tax name from the txn table
    -- in case called from PDOI

    FORALL i IN 1..l_line_loc_id_tbl.COUNT
    UPDATE po_line_locations_all
    SET tax_name = NULL
    WHERE line_location_id = l_line_loc_id_tbl(i);
  END IF;
  --<<PDOI Enhancement Bug#170636664 END>>

  PO_TAX_INTERFACE_PVT.calculate_tax
  ( p_po_header_id    => p_doc_rec.po_header_id,
    p_po_release_id   => NULL,
    p_calling_program => p_calling_program,
    x_return_status   => x_return_status
  );

  --<<PDOI Enhancement Bug#170636664 START>>
  --Restoring back the tax name
  IF p_calling_program = PO_PDOI_CONSTANTS.g_TAX_CALL_MOD_PDOI THEN
    FORALL i IN 1..l_line_loc_id_tbl.COUNT
    UPDATE po_line_locations_all
    SET tax_name = l_tax_name_tbl(i)
    WHERE line_location_id = l_line_loc_id_tbl(i);
  END IF;
  --<<PDOI Enhancement Bug#170636664 END>>

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    -- handle tax calculation error
    -- 1. insert warning to error interface table
    PO_PDOI_ERR_UTL.add_warning
    (
      p_interface_header_id   => p_doc_rec.interface_header_id,
      p_error_message_name    => 'PO_PDOI_TAX_CALCULATION_ERR',
      p_table_name            => 'PO_HEADERS_INTERFACE',
      p_column_name           => NULL
    );
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
  END IF;


EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END calculate_tax;

--<< PDOI Enhancement Bug#17063664 START>>
-----------------------------------------------------------------------
--Start of Comments
--Name: get_req_details
--Procedure:
--  This procedure fetched all the requisition details required
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
-- req_dtls_rec_type
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_req_details
( p_doc_rec       IN  doc_row_type,
  p_line_dtls     OUT NOCOPY req_dtls_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'get_req_details';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

--Bug 18949737 - The line location ids are null at this point in po_req_lines_all table.
--Fetching the line location ids from distributions table to fix one time attachment bug.

SELECT distinct PLD.po_line_id,
        pdd.line_location_id,
         PRL.requisition_header_id,
         PLI.requisition_line_id,
         PLD.purchase_basis,
         PRL.job_long_description,
         NVL(PRL.cancel_flag,'N'),
         NVL(PRL.closed_code,'OPEN'),
         NVL(PRL.modified_by_agent_flag,'N'),
         NVL(PRL.at_sourcing_flag,'N'),
         NVL(PRL.reqs_in_pool_flag,'N'),
         PRL.line_num,
         PRH.segment1,
         PLI.interface_line_id
  BULK COLLECT
  INTO p_line_dtls.po_line_id_tbl,
       p_line_dtls.line_loc_id_tbl,
       p_line_dtls.req_header_id_tbl,
       p_line_dtls.req_line_id_tbl,
       p_line_dtls.purchase_basis_tbl,
       p_line_dtls.job_long_desc_tbl,
       p_line_dtls.cancel_flag_tbl,
       p_line_dtls.closed_code_tbl,
       p_line_dtls.modfd_by_agent_tbl,
       p_line_dtls.at_sourcing_tbl,
       p_line_dtls.reqs_in_pool_tbl,
       p_line_dtls.req_line_num_tbl,
       p_line_dtls.req_num_tbl,
       p_line_dtls.interface_line_tbl
  FROM po_lines_draft_all PLD,
       po_lines_interface PLI,
       po_requisition_lines_all PRL,
      po_requisition_headers_all PRH,
      po_req_distributions_all prd ,
      po_distributions_draft_all pdd
  WHERE PLI.interface_header_id = p_doc_rec.interface_header_id
  AND   PLI.po_line_id = PLD.po_line_id
  AND   PLD.draft_id  = p_doc_rec.draft_id
  AND   PLI.requisition_line_id = PRL.requisition_line_id
  AND   PLI.requisition_line_id IS NOT NULL
  AND   PRL.requisition_header_id = PRH.requisition_header_id
 AND   pdd.req_distribution_id is not null
 and   pdd.req_distribution_id = prd.distribution_id
 AND   prl.requisition_line_id = prd.requisition_line_id
 and   pdd.po_line_id = pld.po_line_id
 and   pdd.draft_id = p_doc_rec.draft_id
 ORDER BY PLD.po_line_id,PDD.line_location_id;

  IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'After fetching req details');
       PO_LOG.stmt(d_module, d_position, 'The po line ids table ' ,p_line_dtls.po_line_id_tbl);
       PO_LOG.stmt(d_module, d_position, 'The po line loc ids table ' ,p_line_dtls.line_loc_id_tbl);
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END get_req_details;
-----------------------------------------------------------------------
--Start of Comments
--Name: update_backing_req_dtls
--Procedure:
--  This procedure updates the line location id
-- req_in_pool_flag on the backing requisition
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_backing_req_dtls
( p_doc_rec       IN doc_row_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'update_backing_req_dtls';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_lineloc_id_tbl PO_TBL_NUMBER;
l_reqline_id_tbl    PO_TBL_NUMBER;

CURSOR c_lineloc_ids IS
SELECT DISTINCT prd.requisition_line_id,pod.line_location_id
  FROM po_distributions_all pod,po_req_distributions_all prd
 WHERE pod.po_header_id = p_doc_rec.po_header_id
   AND pod.req_distribution_id IS NOT NULL
   AND pod.req_distribution_id = prd.distribution_id;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  OPEN c_lineloc_ids;

  FETCH c_lineloc_ids
  BULK COLLECT
  INTO  l_reqline_id_tbl,l_lineloc_id_tbl;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'l_reqline_id_tbl', l_reqline_id_tbl);
    PO_LOG.proc_begin(d_module, 'l_lineloc_id_tbl', l_lineloc_id_tbl);
  END IF;

  CLOSE c_lineloc_ids;

  d_position := 20;

  FORALL i IN 1..l_reqline_id_tbl.COUNT
  UPDATE po_requisition_lines_all
     SET line_location_id = l_lineloc_id_tbl(i),
         reqs_in_pool_flag = NULL,
         last_update_date  = SYSDATE,
         last_updated_by   = FND_GLOBAL.user_id,
         last_update_login = FND_GLOBAL.login_id
  WHERE requisition_line_id = l_reqline_id_tbl(i)
    AND line_location_id IS NULL;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'Number of Rows Updated', sql%ROWCOUNT);
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
   END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END update_backing_req_dtls;

-----------------------------------------------------------------------
--Start of Comments
--Name: copy_req_attachments
--Procedure:
--  This procedure copies all the attachments from
-- requisition to PO
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE copy_req_attachments
( p_doc_rec       IN doc_row_type,
  p_line_dtls      IN req_dtls_rec_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'copy_req_attachments';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position  NUMBER;

l_who_rec  PO_NEGOTIATIONS_SV2.who_rec_type;
l_key      po_session_gt.key%TYPE;
l_line_loc_id_tbl PO_TBL_NUMBER;
l_attached_document_id_tbl PO_TBL_NUMBER;
l_std_shipment_id_tbl PO_TBL_NUMBER;
l_is_complex_work_po  BOOLEAN:= FALSE;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  l_who_rec.created_by := FND_GLOBAL.user_id;
  l_who_rec.creation_date := SYSDATE;
  l_who_rec.last_update_login := FND_GLOBAL.login_id;
  l_who_rec.last_updated_by := FND_GLOBAL.user_id;
  l_who_rec.last_update_date := SYSDATE;

  -- Converting Req Line(Text) to PO Line (Attachment)
  --"Temp Labor" Lines have a Job Long Description, which resides on the
  -- Requisition Line as a LONG Text column, but needs to be copied over
  -- as an attachment on the PO Line.
  -- Category id 33  means to supplier

  FOR i IN 1..p_line_dtls.po_line_id_tbl.COUNT
  LOOP

    IF p_line_dtls.purchase_basis_tbl(i) = 'TEMP LABOUR' AND
       p_line_dtls.job_long_desc_tbl(i) IS NOT NULL THEN

       PO_NEGOTIATIONS_SV2.convert_text_to_attachment
       ( p_long_text      => p_line_dtls.job_long_desc_tbl(i),
         p_description    => NULL,
         p_category_id    => 33,
         p_to_entity_name => 'PO_LINES',
         p_to_pk1_value   => p_line_dtls.po_line_id_tbl(i),
         p_who_rec        => l_who_rec
       );

    END IF;


    d_position := 20;

    IF PO_PDOI_PARAMS.g_request.calling_module <>
       PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE
    THEN

     --Copying Attachments from Requisition Line to PO line

     fnd_attached_documents2_pkg.copy_attachments
     ( X_from_entity_name   => 'REQ_LINES',
       X_from_pk1_value     => p_line_dtls.req_line_id_tbl(i),
       X_to_entity_name     => 'PO_LINES',
       X_to_pk1_value       => p_line_dtls.po_line_id_tbl(i),
       X_created_by         => FND_GLOBAL.user_id,
       X_last_update_login  =>FND_GLOBAL.login_id
      );

      d_position := 30;

      --Copy Attachments from Requisition Header to PO Line
      IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Copy Attachments from Requisition Header to PO Line');
      END IF;

      fnd_attached_documents2_pkg.copy_attachments
     ( X_from_entity_name   => 'REQ_HEADERS',
       X_from_pk1_value     => p_line_dtls.req_header_id_tbl(i),
       X_to_entity_name     => 'PO_LINES',
       X_to_pk1_value       => p_line_dtls.po_line_id_tbl(i),
       X_created_by         => FND_GLOBAL.user_id,
       X_last_update_login  =>FND_GLOBAL.login_id
      );

    END IF;

  END LOOP;

  d_position := 40;

  -- If autocreating a SPO and the requisition line has a one-time
  -- location, move the attachment from the PO line to the PO shipment

   IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'If autocreating a SPO and the requisition line has a one-time
                                         location, move the attachment from the PO line to the PO shipment');
   END IF;

  l_key := PO_CORE_S.get_session_gt_nextval;

   IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position,'l_key: ' ||l_key );
      PO_LOG.stmt(d_module, d_position,'Identifying the Requisition Lines which have one-tiem location:');
      PO_LOG.stmt(d_module, d_position,'The po line ids table ', p_line_dtls.po_line_id_tbl);
      PO_LOG.stmt(d_module, d_position,'The po line loc ids table ', p_line_dtls.line_loc_id_tbl);
   END IF;


  --Identifying the Requisition Lines which have one-tiem
  -- location.
  FORALL i IN 1..p_line_dtls.po_line_id_tbl.COUNT
  INSERT INTO po_session_gt(key,num1,num2,num3)
     SELECT DISTINCT l_key,
            p_line_dtls.po_line_id_tbl(i),
            p_line_dtls.req_line_id_tbl(i),
	    p_line_dtls.line_loc_id_tbl(i)
       FROM fnd_attached_documents
      WHERE entity_name = 'REQ_LINES'
        AND pk1_value = TO_CHAR(p_line_dtls.req_line_id_tbl(i))
	AND pk2_value = 'ONE_TIME_LOCATION';

   --SQL What: Locate the one-time location attachment currently under
   --          the PO_LINES entity by it's unique iP identifier prefix
   --SQL Why: Need the attached_document_id to move the attachment

   --Bug 18949737 num4 - Removed the condition pk2_value = 'ONE_TIME_LOCATION' coz for PO_LINES entity,
   --               pk2_value will be null. Updated the ffdt.description clause to look for entire text
   --              'POR:One Time Address', as the customer can eter manual line attachment starting with 'POR'.
   -- num5 - fetching the line location ids from interface as no data exists in drafts_all table at this point.
   --        This will ensure proper copy of one time attachments in complex PO.

    UPDATE po_session_gt psg
       SET num4 = (SELECT fad.attached_document_id
                     FROM fnd_attached_documents fad,
		          fnd_documents_tl fdt
                    WHERE fad.entity_name = 'PO_LINES'
		      AND fad.pk1_value = TO_CHAR(psg.num1)
		      AND fad.document_id = fdt.document_id
		      AND fdt.LANGUAGE = USERENV('LANG')
		      AND fdt.description = 'POR:One Time Address'   --Bug 18949737
                    ),
           num5 = (SELECT MIN(PLLI.line_location_id)     --Bug 18949737
	             FROM po_line_locations_interface PLLI,
                    po_lines_interface PLI
		    WHERE  PLI.interface_header_id = p_doc_rec.interface_header_id
               AND PLI.interface_line_id = PLLI.interface_line_id
               AND PLI.po_line_id = psg.num1
                   )
      WHERE KEY = l_key
      RETURNING num3, num4, num5  BULK COLLECT INTO
      l_line_loc_id_tbl,
      l_attached_document_id_tbl,
      l_std_shipment_id_tbl;

   d_position := 50;

   IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position,'l_key: ' ||l_key );
      PO_LOG.stmt(d_module, d_position,'After fetching the line loc id and attached doc ids');
      PO_LOG.stmt(d_module, d_position,'l_line_loc_id_tbl: ' , l_line_loc_id_tbl);
      PO_LOG.stmt(d_module, d_position,'l_attached_document_id_tbl : ' ,l_attached_document_id_tbl);
      PO_LOG.stmt(d_module, d_position,'l_std_shipment_id_tbl : ' , l_std_shipment_id_tbl);
   END IF;

   l_is_complex_work_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(p_doc_rec.po_header_id);

   IF l_is_complex_work_po
   THEN

     --Move the attachments to actual standard shipment for complex PO

        FORALL i IN 1.. l_std_shipment_id_tbl.COUNT
         UPDATE fnd_attached_documents
           SET entity_name = 'PO_SHIPMENTS',
                 pk1_value = TO_CHAR(l_std_shipment_id_tbl(i)),
	         pk2_value = 'ONE_TIME_LOCATION'
         WHERE attached_document_id = l_attached_document_id_tbl(i)
	   AND l_attached_document_id_tbl(i) IS NOT NULL;

        -- Fox complex PO need to copy the attachments from
	-- first actual standard shipment to all the payitems

	FOR i IN 1..l_line_loc_id_tbl.COUNT
	LOOP

	  IF l_line_loc_id_tbl(i) <> l_std_shipment_id_tbl(i) AND
	     l_attached_document_id_tbl(i) IS NOT NULL
	  THEN

 	    fnd_attached_documents2_pkg.copy_attachments
	    ( X_from_entity_name  => 'PO_SHIPMENTS',
	      X_from_pk1_value    => l_attached_document_id_tbl(i),
	      X_from_pk2_value    => 'ONE_TIME_LOCATION',
	      X_to_entity_name    => 'PO_SHIPMENTS',
	      X_to_pk1_value      => l_line_loc_id_tbl(i),
	      X_to_pk2_value      => 'ONE_TIME_LOCATION',
	      X_created_by        => FND_GLOBAL.user_id,
	      X_last_update_login => FND_GLOBAL.login_id
	    );

	  END IF;

	END LOOP;

   ELSE --- If not complex PO

    --Move the attachmnents from PO LINE to PO SHIPMENT

    FORALL i IN 1.. l_line_loc_id_tbl.COUNT
     UPDATE fnd_attached_documents
        SET entity_name = 'PO_SHIPMENTS',
            pk1_value = TO_CHAR(l_line_loc_id_tbl(i)),
            pk2_value = 'ONE_TIME_LOCATION'
      WHERE attached_document_id = l_attached_document_id_tbl(i);

   END IF; --End of Complex PO condition


    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module);
    END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END copy_req_attachments;

-----------------------------------------------------------------------
--Start of Comments
--Bug: 19288967 20378957
--Name: sync_ga_attachments
--Procedure:
--This procedure sync the GA attachments for PO lines
--Parameters:
--IN:p_doc_rec
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------

PROCEDURE sync_ga_attachments
( p_doc_rec       IN doc_row_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'sync_ga_attachments';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position  NUMBER;

x_return_status VARCHAR2(1);
x_msg_data   VARCHAR2(2000);
l_from_header_id po_lines_interface.from_header_id%TYPE;
l_from_line_id po_lines_interface.from_line_id%TYPE;

--bug 20378957
cursor c_ga_rec is
select distinct pla.from_header_id, pla.from_line_id
from po_lines_all pla, po_lines_interface pli
where pla.po_header_id = p_doc_rec.po_header_id
and pli.interface_header_id = p_doc_rec.interface_header_id
and pla.po_header_id = pli.po_header_id
and pla.po_line_id = pli.po_line_id
and pla.from_header_id is not null
and pla.from_line_id is not null;

l_ga_rec c_ga_rec%ROWTYPE;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.stmt(d_module, d_position, 'Sync Attachments from GA to PO Line');
  END IF;

  --bug 20378957
  IF  c_ga_rec%ISOPEN THEN
      CLOSE c_ga_rec;
  END IF;

  OPEN c_ga_rec;
  LOOP
  FETCH c_ga_rec INTO l_ga_rec;
  exit when c_ga_rec%NOTFOUND;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.stmt(d_module, d_position, 'from_header_id = '||l_ga_rec.from_header_id
	                                ||', from_line_id = '||l_ga_rec.from_line_id);
  END IF;

  PO_GA_PVT.SYNC_GA_LINE_ATTACHMENTS(
    p_po_header_id => l_ga_rec.from_header_id,
    p_po_line_id => l_ga_rec.from_line_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data);

    IF (x_return_status <> 'S') THEN
          PO_PDOI_ERR_UTL.add_warning
        (
          p_interface_header_id   => p_doc_rec.interface_header_id,
          p_error_message         => x_msg_data,
          p_table_name            => 'PO_LINES_INTERFACE',
          p_column_name           => NULL
        );
    END IF;

  d_position := 20;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.stmt(d_module, d_position, 'x_return_status = '||x_return_status
	                                ||', x_msg_data = '|| x_msg_data);
  END IF;

  END LOOP;
  CLOSE c_ga_rec;

  d_position := 30;
  IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_end(d_module);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;

  END sync_ga_attachments;

-----------------------------------------------------------------------
--Start of Comments
--Name: update_terms
--Procedure:
--  This procedure call update the terms on the document based on the
--  source document information
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_terms
( p_doc_rec       IN doc_row_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'update_terms';
  d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;


   IF PO_PDOI_PARAMS.g_request.calling_module <>
        PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE  THEN

     po_interface_s2.update_terms(p_doc_rec.po_header_id);

   END IF;


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END update_terms;

-----------------------------------------------------------------------
--Start of Comments
-- <PDOI Enhancement Bug#17063664>
--Name: validate_lock_back_reqs
--Function:
-- This procedure validates baking req and locks it for update.
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
-- p_req_dtls
--  Req details
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE validate_lock_back_reqs
( p_doc_rec         IN doc_row_type
, p_req_dtls        IN req_dtls_rec_type
, x_header_rejected OUT NOCOPY VARCHAR2
)
IS

  d_api_name CONSTANT VARCHAR2(30) := 'validate_lock_back_reqs';
  d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;
  l_can_lock_req_line VARCHAR2(1) := 'N';
  l_remove_draft VARCHAR2(1);
  l_line_location_id NUMBER ;
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_header_rejected := FND_API.G_FALSE;
  l_remove_draft := FND_API.G_FALSE;

  FOR i IN 1..p_req_dtls.po_line_id_tbl.COUNT
  LOOP
     IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'Checking for po_line_id ' || p_req_dtls.po_line_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'requisition_line_id ' || p_req_dtls.req_line_id_tbl(i));
     END IF;

     BEGIN

        --Bug 18949737 - using local line_location_id variable as the get_req_details procedure code is
        --modified to fetch line location ids from distribution drafts table.
        l_line_location_id :=NULL ;

        SELECT 'Y',line_location_id
        INTO   l_can_lock_req_line, l_line_location_id
        FROM   po_requisition_lines_all
        WHERE requisition_line_id = p_req_dtls.req_line_id_tbl(i)
        AND   requisition_header_id = p_req_dtls.req_header_id_tbl(i)
        FOR UPDATE NOWAIT;

        IF p_req_dtls.cancel_flag_tbl(i) = 'Y' THEN

          PO_PDOI_ERR_UTL.add_fatal_error
          ( p_interface_header_id => p_doc_rec.interface_header_id,
            p_interface_line_id   => p_req_dtls.interface_line_tbl(i),
            p_error_message_name  => 'PO_ALL_RQ_LINE_CNCLD_CANT_AC',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'REQUISITION_LINE_ID',
            p_column_value        => p_req_dtls.req_line_id_tbl(i),
            p_token1_name         => 'REQ_LINE_NUM',
            p_token1_value        => p_req_dtls.req_line_num_tbl(i),
            p_token2_name         => 'REQ_NUM',
            p_token2_value        => p_req_dtls.req_num_tbl(i)
          );
          x_header_rejected := FND_API.G_TRUE;

        ELSIF p_req_dtls.closed_code_tbl(i) = 'FINALLY CLOSED' THEN

           PO_PDOI_ERR_UTL.add_fatal_error
          ( p_interface_header_id => p_doc_rec.interface_header_id,
            p_interface_line_id   => p_req_dtls.interface_line_tbl(i),
            p_error_message_name  => 'PO_ALL_REQ_LINE_DLTD_CANT_AC',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'REQUISITION_LINE_ID',
            p_column_value        => p_req_dtls.req_line_id_tbl(i),
            p_token1_name         => 'REQ_LINE_NUM',
            p_token1_value        => p_req_dtls.req_line_num_tbl(i),
            p_token2_name         => 'REQ_NUM',
            p_token2_value        => p_req_dtls.req_num_tbl(i)
          );
          x_header_rejected := FND_API.G_TRUE;

        ELSIF p_req_dtls.reqs_in_pool_tbl(i) = 'N'
              OR p_req_dtls.modfd_by_agent_tbl(i) = 'Y' THEN

           PO_PDOI_ERR_UTL.add_fatal_error
          ( p_interface_header_id => p_doc_rec.interface_header_id,
            p_interface_line_id   => p_req_dtls.interface_line_tbl(i),
            p_error_message_name  => 'PO_ALL_RQ_LINE_MDFD_CANT_AC',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'REQUISITION_LINE_ID',
            p_column_value        => p_req_dtls.req_line_id_tbl(i),
            p_token1_name         => 'REQ_LINE_NUM',
            p_token1_value        => p_req_dtls.req_line_num_tbl(i),
            p_token2_name         => 'REQ_NUM',
            p_token2_value        => p_req_dtls.req_num_tbl(i)
          );
          x_header_rejected := FND_API.G_TRUE;

        ELSIF l_line_location_id IS NOT NULL
              OR p_req_dtls.at_sourcing_tbl(i) = 'Y' THEN

           PO_PDOI_ERR_UTL.add_fatal_error
          ( p_interface_header_id => p_doc_rec.interface_header_id,
            p_interface_line_id   => p_req_dtls.interface_line_tbl(i),
            p_error_message_name  => 'PO_ALL_RQ_LINE_ALREADY_AC',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'REQUISITION_LINE_ID',
            p_column_value        => p_req_dtls.req_line_id_tbl(i),
            p_token1_name         => 'REQ_LINE_NUM',
            p_token1_value        => p_req_dtls.req_line_num_tbl(i),
            p_token2_name         => 'REQ_NUM',
            p_token2_value        => p_req_dtls.req_num_tbl(i)
          );
          x_header_rejected := FND_API.G_TRUE;
        END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
           PO_PDOI_ERR_UTL.add_fatal_error
          ( p_interface_header_id => p_doc_rec.interface_header_id,
            p_interface_line_id   => p_req_dtls.interface_line_tbl(i),
            p_error_message_name  => 'PO_ALL_REQ_LINE_DLTD_CANT_AC',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'REQUISITION_LINE_ID',
            p_column_value        => p_req_dtls.req_line_id_tbl(i),
            p_token1_name         => 'REQ_LINE_NUM',
            p_token1_value        => p_req_dtls.req_line_num_tbl(i),
            p_token2_name         => 'REQ_NUM',
            p_token2_value        => p_req_dtls.req_num_tbl(i)
          );
          x_header_rejected := FND_API.G_TRUE;
       WHEN OTHERS THEN
          PO_PDOI_ERR_UTL.add_fatal_error
          ( p_interface_header_id => p_doc_rec.interface_header_id,
            p_interface_line_id   => p_req_dtls.interface_line_tbl(i),
            p_error_message_name  => 'PO_ALL_RQ_LINE_LOCKED_CANT_AC',
            p_table_name          => 'PO_LINES_INTERFACE',
            p_column_name         => 'REQUISITION_LINE_ID',
            p_column_value        => p_req_dtls.req_line_id_tbl(i),
            p_token1_name         => 'REQ_LINE_NUM',
            p_token1_value        => p_req_dtls.req_line_num_tbl(i),
            p_token2_name         => 'REQ_NUM',
            p_token2_value        => p_req_dtls.req_num_tbl(i)
          );
          x_header_rejected := FND_API.G_TRUE;
     END;
  END LOOP;

  IF x_header_rejected = FND_API.G_TRUE THEN

    IF ( PO_PDOI_PARAMS.g_docs_info(p_doc_rec.interface_header_id).new_draft =
           FND_API.G_TRUE) THEN
      l_remove_draft := FND_API.G_TRUE;
    END IF;

    PO_PDOI_UTL.post_reject_document
    ( p_interface_header_id => p_doc_rec.interface_header_id,
      p_po_header_id        => p_doc_rec.po_header_id,
      p_draft_id            => p_doc_rec.draft_id,
      p_remove_draft        => l_remove_draft
    );

    IF (l_remove_draft = FND_API.G_FALSE) THEN
        -- Change the draft status back to 'DRAFT' (it was set to
        -- 'PDOI PROCESSING' during header grouping)
        PO_DRAFTS_PVT.update_draft_status
        ( p_draft_id => p_doc_rec.draft_id,
          p_new_status => PO_DRAFTS_PVT.g_STATUS_DRAFT
        );
    END IF;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
END validate_lock_back_reqs;

-----------------------------------------------------------------------
--Start of Comments
-- <PDOI Enhancement Bug#17063664>
--Name: start_auto_approval_workflow
--Function:
--  Launch the PDOI auto approval process
-- This new process will take care of submission checks,
-- reserve, approve, create SR ASL.
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE start_auto_approval_workflow
( p_doc_rec IN doc_row_type
) IS

d_api_name CONSTANT VARCHAR2(30) := 'start_auto_approval_workflow';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_doc_type       VARCHAR2(30);
l_doc_subtype    VARCHAR2(30);
l_agent_id       PO_HEADERS_ALL.agent_id%TYPE;
l_document_num   PO_HEADERS_ALL.segment1%TYPE;
l_current_employee_id  per_workforce_current_x.person_id%TYPE :=NULL;
l_seq_for_item_key varchar2(25)  := null;
l_itemkey varchar2(60);

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_PDOI_UTL.get_processing_doctype_info
  ( x_doc_type => l_doc_type,
    x_doc_subtype => l_doc_subtype
  );

  l_agent_id := p_doc_rec.agent_id;

  IF(PO_PDOI_PARAMS.g_request.calling_module = PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD) THEN

        BEGIN
            SELECT emp.person_id
            INTO   l_current_employee_id
            FROM   fnd_user fu,
                   per_workforce_current_x emp,
                   po_agents poa
            WHERE  fu.user_id = fnd_global.user_id
                   AND fu.employee_id = emp.person_id (+)
                   AND emp.person_id = poa.agent_id (+)
                   AND SYSDATE BETWEEN Nvl(poa.start_date_active (+), SYSDATE - 1) AND
                                           Nvl(poa.end_date_active (+), SYSDATE + 1);
        EXCEPTION
            WHEN OTHERS THEN
              l_current_employee_id := NULL;
        END;

 END IF;

  d_position := 20;

  --Generate the Item Key
  select to_char(PO_WF_ITEMKEY_S.NEXTVAL)
  into l_seq_for_item_key
  from sys.dual;

  l_itemkey := to_char(p_doc_rec.po_header_id) || '-' ||  l_seq_for_item_key;

  IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Starting PDOI Auto approval process item_key = ', l_itemkey);
  END IF;

  -- bug 19264583, update ActionOriginatedFrom = PDOI_AUTO_APPROVE, to identify the wf lunched by PDOI auto-approve.
  -- Call Approval Workflow
  PO_REQAPPROVAL_INIT1.start_wf_process
  ( ItemType => 'POAPPRV',
    ItemKey => l_itemkey,
    WorkflowProcess => 'PDOI_AUTO_APPROVE',
    ActionOriginatedFrom => 'PDOI_AUTO_APPROVE',
    DocumentId => p_doc_rec.po_header_id,
    DocumentNumber => NULL,  -- Obsolete parameter
    PreparerId =>Nvl(l_current_employee_id,p_doc_rec.agent_id),
    DocumentTypeCode => l_doc_type,
    DocumentSubtype => l_doc_subtype,
    SubmitterAction => 'APPROVE',
    ForwardToId => NULL,
    ForwardFromId => NULL,
    DefaultApprovalPathId => NULL,
    Note => NULL,
    PrintFlag => NULL,
    FaxFlag => NULL,
    FaxNumber => NULL,
    EmailFlag => NULL,
    EmailAddress => NULL,
    CreateSourcingRule => NVL(p_doc_rec.load_sourcing_rules_flag, PO_PDOI_PARAMS.g_request.create_sourcing_rules_flag),
    ReleaseGenMethod => PO_PDOI_PARAMS.g_request.rel_gen_method,
    UpdateSourcingRule => PO_PDOI_PARAMS.g_request.create_sourcing_rules_flag,
    p_Background_Flag => 'N', --change to N for bug 20368337
    p_sourcing_level => PO_PDOI_PARAMS.g_request.sourcing_level, /*BUG19701485*/
    p_sourcing_inv_org_id => PO_PDOI_PARAMS.g_request.sourcing_inv_org_id /*BUG19701485*/
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END start_auto_approval_workflow;

------------------------------------------------------------------------
--Start of Comments
-- <PDOI Enhancement Bug#17063664>
--Name: create_update_doc
--Function:
-- Creates/Updates Standard/Blanket.
-- Based on doc_type and action
--Parameters:
--IN:
--p_doc_rec
--  Some attribute values of the document
-- p_doc_type
-- p_action
--IN OUT:
--OUT:
-- x_process_code
--End of Comments
------------------------------------------------------------------------
PROCEDURE create_update_doc ( p_doc_rec      IN doc_row_type
                            , p_doc_type     IN VARCHAR2
                            , p_action       IN VARCHAR2
                            , x_process_code OUT NOCOPY VARCHAR2)
IS

d_api_name CONSTANT VARCHAR2(30) := 'create_update_doc';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_approval_method VARCHAR2(30);
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_line_dtls req_dtls_rec_type;
l_header_rejected VARCHAR2(1) := FND_API.G_FALSE;
l_doc_info PO_PDOI_PARAMS.doc_info_rec_type;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_process_code := 'ACCEPTED';

   d_position := 10;
   IF (p_action = PO_PDOI_CONSTANTS.g_ACTION_REPLACE
       AND p_doc_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN
      d_position := 20;
      expire_document(p_doc_rec => p_doc_rec);
   END IF;

   IF (p_action <> PO_PDOI_CONSTANTS.g_ACTION_UPDATE) THEN
       d_position := 30;
       IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'Assigning document number');
        END IF;
       assign_document_number ( p_doc_rec => p_doc_rec );
   END IF;

   IF p_doc_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD THEN

         d_position := 40;
         IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'Getting req line info');
         END IF;
         get_req_details( p_doc_rec  => p_doc_rec,
                          p_line_dtls => l_line_dtls);

          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, '# of lines having attachments',
                        l_line_dtls.po_line_id_tbl.COUNT);
          END IF;

        IF l_line_dtls.po_line_id_tbl.COUNT > 0
           AND PO_PDOI_PARAMS.g_request.calling_module <> PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE THEN
            d_position := 50;
            IF (PO_LOG.d_stmt) THEN
               PO_LOG.stmt(d_module, d_position, 'Lock Backing requisition');
            END IF;
            validate_lock_back_reqs( p_doc_rec        => p_doc_rec
                                   , p_req_dtls       => l_line_dtls
                                   , x_header_rejected => l_header_rejected);

            IF l_header_rejected = FND_API.G_TRUE THEN
                ROLLBACK TO po_pdoi_doc_postproc_sp;
                x_process_code := 'REJECTED';
                RETURN;
            END IF;

        END IF;
  END IF;

  IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Transferring draft records to txn table');
  END IF;

  d_position := 60;
  transfer_draft_to_txn (p_doc_rec => p_doc_rec,
                         p_doc_type => p_doc_type);

  IF p_doc_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD THEN

     IF l_line_dtls.po_line_id_tbl.COUNT > 0 THEN
          d_position := 70;
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'Update backing requisition details');
          END IF;
          -- Update the line_location_id and reqs_in_pool_flag
          -- on po_requisition_lines_all table
          update_backing_req_dtls(p_doc_rec => p_doc_rec);

          d_position := 80;
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'copying requisition attachments');
          END IF;
          copy_req_attachments
          ( p_doc_rec => p_doc_rec,
            p_line_dtls => l_line_dtls
          );

	  --bug 19288967
	  d_position := 81;
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'syncing GA attachments');
          END IF;
          --bug 20378957
          sync_ga_attachments
          ( p_doc_rec => p_doc_rec);
     END IF;

     d_position := 90;
     -- Call update_terms api
     update_terms
     ( p_doc_rec => p_doc_rec
     );

  END IF;

  d_position := 100;
  IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'committing work and creating savepoint');
  END IF;

  PO_PDOI_UTL.commit_work;
  SAVEPOINT po_pdoi_doc_postproc_sp;

  IF p_doc_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD THEN

     d_position := 100;
      IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module, d_position, 'calculate tax for the standard PO');
      END IF;

     calculate_tax
     ( p_doc_rec => p_doc_rec,
       x_return_status => l_return_status
     );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          d_position := 90;
          IF (PO_LOG.d_stmt) THEN
             PO_LOG.stmt(d_module, d_position, 'failed in tax calculation.');
          END IF;

          RETURN;
     END IF;

  ELSIF (p_doc_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET
        AND p_action = PO_PDOI_CONSTANTS.g_ACTION_UPDATE) THEN

    l_doc_info := PO_PDOI_PARAMS.g_docs_info(p_doc_rec.interface_header_id);
    IF (l_doc_info.has_lines_to_notify = FND_API.G_TRUE) THEN

        d_position := 100;
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'start price tolerance workflow');
        END IF;
        PO_PDOI_PRICE_TOLERANCE_PVT.start_price_tolerance_wf
        (
          p_intf_header_id    => p_doc_rec.interface_header_id,
          p_po_header_id      => p_doc_rec.po_header_id,
          p_document_num      => p_doc_rec.document_num,
          p_batch_id      => PO_PDOI_PARAMS.g_request.batch_id,
          p_document_type     => p_doc_rec.document_type,
          p_document_subtype  => p_doc_rec.document_subtype,
          p_commit_interval    => 1, -- parameter removed in R12
          p_any_line_updated  => l_doc_info.has_lines_updated,
          p_buyer_id      => PO_PDOI_PARAMS.g_request.buyer_id,
          p_agent_id          => p_doc_rec.agent_id,
          p_vendor_id         => p_doc_rec.vendor_id,
          p_vendor_name       => p_doc_rec.vendor_name
        );
        x_process_code := 'NOTIFIED';
        RETURN;
    END IF;
  END IF;



    d_position := 110;
    get_approval_method
    ( p_doc_rec => p_doc_rec,
      x_approval_method => l_approval_method
    );

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'l_approval_method', l_approval_method);
    END IF;

    IF ( l_approval_method = PO_PDOI_CONSTANTS.g_appr_method_INIT_APPROVAL) THEN
      d_position := 120;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'launching approval workflow');
      END IF;

      start_po_approval_workflow
      ( p_doc_rec => p_doc_rec
      );

    ELSIF ( l_approval_method = PO_PDOI_CONSTANTS.g_appr_method_AUTO_APPROVE) THEN

      IF p_action <> PO_PDOI_CONSTANTS.g_ACTION_UPDATE
          OR nvl(p_doc_rec.ORIG_AUTH_STATUS,'INCOMPLETE') = 'APPROVED' THEN

              d_position := 130;
              IF (PO_LOG.d_stmt) THEN
                PO_LOG.stmt(d_module, d_position, 'launching PDOI Auto approval workflow');
              END IF;
              start_auto_approval_workflow
              ( p_doc_rec => p_doc_rec
              );
      END IF;

    END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END create_update_doc;

------------------------------------------------------------------------
--Start of Comments
-- <PDOI Enhancement Bug#17063664>
--Name: launch_wf_background
--Function:
-- Launches the workflow background process
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE launch_wf_background
IS
  d_api_name CONSTANT VARCHAR2(30) := 'launch_wf_background';
  d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  wf_item_type po_document_types.wf_approval_itemtype%TYPE;
  request_id   NUMBER;
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF PO_PDOI_PARAMS.g_request.approved_status = PO_PDOI_CONSTANTS.g_APPR_METHOD_INIT_APPROVAL THEN

      SELECT wf_approval_itemtype
      INTO   wf_item_type
      FROM   po_document_types
      WHERE document_type_code = DECODE(PO_PDOI_PARAMS.g_request.document_type,
                                       PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD, 'PO',
                                       PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,  'PA',
                                       PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT, 'PA')
      AND document_subtype = PO_PDOI_PARAMS.g_request.document_type;

  ELSIF PO_PDOI_PARAMS.g_request.approved_status = PO_PDOI_CONSTANTS.g_APPR_STATUS_APPROVED THEN
      wf_item_type := 'POAPPRV';
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Item type :' || wf_item_type);
  END IF;

  request_id := FND_REQUEST.Submit_Request(APPLICATION=>'FND',
                                           PROGRAM=>'FNDWFBG',
                                           start_time => to_char(sysdate + 5/24/60/60, FND_CONC_DATE.get_date_format('DD-MON-RR HH24:MI:SS')),-- bug19627524 delay for 5 seconds
                                           argument1 => wf_item_type,
                                           argument2 => NULL,
                                           argument3 => NULL,
                                           argument4 => 'Y',
                                           DESCRIPTION=> 'Submitted by PDOI');

  PO_PDOI_UTL.commit_work;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Submitted request id :' || request_id);
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END launch_wf_background;

--<< PDOI Enhancement Bug#17063664 END>>

END PO_PDOI_POSTPROC_PVT;

/
