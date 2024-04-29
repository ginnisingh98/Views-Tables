--------------------------------------------------------
--  DDL for Package Body PO_PDOI_HEADER_GROUPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_HEADER_GROUPING_PVT" AS
/* $Header: PO_PDOI_HEADER_GROUPING_PVT.plb 120.10.12010000.3 2012/01/13 12:18:44 sbontala ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_HEADER_GROUPING_PVT');

-------------------------------------------------------
----------- PRIVATE PROCEDURES PROTOTYPE --------------
-------------------------------------------------------

PROCEDURE assign_round_num
( x_all_headers_processed OUT NOCOPY VARCHAR2
);

PROCEDURE assign_draft_id;

PROCEDURE expire_lines_by_catalog_name;

PROCEDURE init_doc_info_tbl
( p_intf_header_id_tbl PO_TBL_NUMBER
);

PROCEDURE check_new_draft_needed
( p_draft_id IN NUMBER,
  p_status   IN VARCHAR2,
  x_new_draft_needed OUT NOCOPY VARCHAR2
);

-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: process
--Function:
--  Main process for header grouping
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_all_headers_processed
--  FND_API.G_TRUE if all the headers are processed
--  FND_API.G_FALSE otherwise
--End of Comments
------------------------------------------------------------------------
PROCEDURE process
( x_all_headers_processed OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'process';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_HEADER_GROUPING);

  d_position := 10;

  -- set round number for interface records that will be processed in
  -- current round
  assign_round_num
  ( x_all_headers_processed => x_all_headers_processed );

  d_position := 20;

  -- create draft for records that will be processed in current round
  IF (x_all_headers_processed = FND_API.G_FALSE) THEN
    assign_draft_id;

    d_position := 30;

    -- If lines for a particular catalog name will get expired, move those
    -- records to draft table and set expiration date for those lines
    IF (PO_PDOI_PARAMS.g_request.calling_module =
          PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD
        AND
        PO_PDOI_PARAMS.g_request.catalog_to_expire IS NOT NULL) THEN

      expire_lines_by_catalog_name;
    END IF;
  END IF;

  d_position := 40;

  PO_INTERFACE_ERRORS_UTL.flush_errors_tbl;

  d_position := 50;

  PO_PDOI_UTL.commit_work;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_HEADER_GROUPING);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END process;


-------------------------------------------------------
-------------- PRIVATE PROCEDURES ---------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: assign_round_num
--Function:
--  For documents that can be processed in the same round, stamp those
--  record with processing_round_num = current_round_num so that they
--  will be processed later on
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_all_headers_processed
--  FND_API.G_TRUE if all the headers are processed
--  FND_API.G_FALSE otherwise
--End of Comments
------------------------------------------------------------------------
PROCEDURE assign_round_num
( x_all_headers_processed OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'assign_round_num';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_process_update_replace BOOLEAN := FALSE;

l_intf_header_id_tbl PO_TBL_NUMBER;
l_po_header_id_tbl PO_TBL_NUMBER;

l_process_list DBMS_SQL.NUMBER_TABLE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  x_all_headers_processed := FND_API.G_FALSE;

  -- Increment round number
  PO_PDOI_PARAMS.g_current_round_num := PO_PDOI_PARAMS.g_current_round_num + 1;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Current Round Number: ' ||
                PO_PDOI_PARAMS.g_current_round_num);
  END IF;

  IF (PO_PDOI_PARAMS.g_original_doc_processed = FND_API.G_FALSE) THEN
    d_position := 10;

    -- First, we need to process NEW documents

    SELECT interface_header_id
    BULK COLLECT
    INTO l_intf_header_id_tbl
    FROM (SELECT interface_header_id
          FROM   po_headers_interface
          WHERE  processing_round_num IS NULL
          AND    processing_id = PO_PDOI_PARAMS.g_processing_id
          AND    action IN (PO_PDOI_CONSTANTS.g_action_ORIGINAL,
                            PO_PDOI_CONSTANTS.g_action_ADD)
          ORDER BY interface_header_id)
    WHERE rownum <= PO_PDOI_PARAMS.g_request.batch_size;

    IF (SQL%ROWCOUNT = 0) THEN
      d_position := 20;

      -- mark g_original_doc_processed to TRUE so that we won't process
      -- NEW documents the next time we come here
      PO_PDOI_PARAMS.g_original_doc_processed := FND_API.G_TRUE;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'Finished progressing doc with ' ||
                    'action = original ');
      END IF;

      -- IF there is no new doucment to create, we can go ahead and look for
      -- documents to update/replace
      l_process_update_replace := TRUE;
    ELSE

      d_position := 30;

      FORALL i IN 1..l_intf_header_id_tbl.COUNT
        UPDATE po_headers_interface
        SET    processing_round_num = PO_PDOI_PARAMS.g_current_round_num
        WHERE  interface_header_id = l_intf_header_id_tbl(i);

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'updated ' || SQL%ROWCOUNT ||
                    'rows with current round number ');
      END IF;
    END IF;

  ELSE
    d_position := 40;

    l_process_update_replace := TRUE;
  END IF;


  IF (l_process_update_replace) THEN
    d_position := 50;

    -- if there are multiple records in headers interface, they can be processed
    -- together only if they are not acting on the same document.

    SELECT interface_header_id,
           po_header_id
    BULK COLLECT
    INTO l_intf_header_id_tbl,
         l_po_header_id_tbl
    FROM po_headers_interface
    WHERE processing_round_num IS NULL
    AND processing_id = PO_PDOI_PARAMS.g_processing_id
    AND po_header_id IS NOT NULL
    AND action IN (PO_PDOI_CONSTANTS.g_action_UPDATE,
                   PO_PDOI_CONSTANTS.g_action_REPLACE)
    ORDER BY interface_header_id;

    d_position := 60;

    FOR i IN 1..l_intf_header_id_tbl.COUNT LOOP
      -- Use an associative array to figure out whether there is already
      -- another header interface record in the same round that tries to
      -- update the same document. If so, defer the current update to the
      -- next round.

      IF (l_po_header_id_tbl IS NOT NULL AND
          NOT l_process_list.EXISTS(l_po_header_id_tbl(i))) THEN
        l_process_list(l_po_header_id_tbl(i)) := l_intf_header_id_tbl(i);
      END IF;

      IF (l_process_list.COUNT >= PO_PDOI_PARAMS.g_request.batch_size) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, '# of documents to process has ' ||
                      'reached the limit. Wait for the next round');
        END IF;

        -- exit the loop if the number of document to process exceeds
        -- the specified limit
        EXIT;
      END IF;
    END LOOP;

    d_position := 70;

    IF (l_process_list.COUNT > 0) THEN
      -- assign round number for those in process list
      FORALL i IN INDICES OF l_process_list
        UPDATE po_headers_interface
        SET    processing_round_num = PO_PDOI_PARAMS.g_current_round_num
        WHERE  interface_header_id = l_process_list(i);

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'updated ' || SQL%ROWCOUNT ||
                    'rows with current round number ');
      END IF;

    ELSE

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, '** No more doc to process ***');
      END IF;

      x_all_headers_processed := FND_API.G_TRUE;
    END IF;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END assign_round_num;



-----------------------------------------------------------------------
--Start of Comments
--Name: assign_draft_id
--Function:
--  Stamp header interface records with draft ids. If the document the
--  interface record tries to process already has a draft version, reuse
--  the draft; otherwise, create a new draft
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE assign_draft_id IS

d_api_name CONSTANT VARCHAR2(30) := 'assign_draft_id';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_draft_id_tbl         PO_TBL_NUMBER := PO_TBL_NUMBER();
l_reject_list          PO_TBL_NUMBER := PO_TBL_NUMBER();

l_new_dft_idx_tbl      PO_PDOI_UTL.pls_integer_tbl_type :=
                         PO_PDOI_UTL.pls_integer_tbl_type();
l_existing_dft_idx_tbl PO_PDOI_UTL.pls_integer_tbl_type :=
                         PO_PDOI_UTL.pls_integer_tbl_type();

l_intf_header_id_tbl   PO_TBL_NUMBER;
l_po_header_id_tbl     PO_TBL_NUMBER;
l_action_tbl           PO_TBL_VARCHAR30;
l_revision_num_tbl     PO_TBL_NUMBER;

l_tmp_draft_id         PO_DRAFTS.draft_id%TYPE;
l_tmp_draft_status     PO_DRAFTS.status%TYPE;
l_tmp_draft_owner_role PO_DRAFTS.owner_role%TYPE;
l_new_draft_needed     VARCHAR2(1);
l_return_status        VARCHAR2(1);

l_status      PO_DRAFTS.status%TYPE := PO_DRAFTS_PVT.g_status_PDOI_PROCESSING;

l_locking_allowed VARCHAR2(1);
l_message VARCHAR2(30);

l_intf_hdr_id          NUMBER; -- bug5129752
l_temp                 NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  --SQL What: get all records that will be processed in current round. It also
  --          locks the po_Headers of documents that are being updated
  --SQL Why:  For each of this record, we need to find out whether we can
  --          reuse an existing draft or have to create a new draft
  SELECT PHI.interface_header_id,
         PHI.po_header_id,
         PHI.action,
         NVL(PH.revision_num, 0)
  BULK COLLECT
  INTO   l_intf_header_id_tbl,
         l_po_header_id_tbl,
         l_action_tbl,
         l_revision_num_tbl
  FROM   po_headers_interface PHI,
         po_headers_all PH
  WHERE  PHI.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    PHI.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
  AND    PHI.po_header_id = PH.po_header_id(+);

  --For Bug: 11794764.Refer bug for reference.
  --FOR UPDATE OF PH.po_header_id;

   FOR i IN 1 .. l_po_header_id_tbl.count LOOP

      ---BEGIN BUG: 13588901 : Adding the no data found exception handler code
   BEGIN
      SELECT PO_HEADER_ID
      INTO   l_temp
      FROM   po_headers_all
      WHERE  po_header_id = l_po_header_id_tbl(i)
      FOR UPDATE OF po_header_id;


   EXCEPTION
   WHEN NO_DATA_FOUND THEN
   NULL;
   END;
   ---END BUG : 13588901

   END LOOP;

  d_position := 10;

  -- initialize structure that stores additional information for each
  -- interface header record

  init_doc_info_tbl
  ( p_intf_header_id_tbl => l_intf_header_id_tbl
  );

  -- allocate space to store draft ids
  l_draft_id_tbl.extend(l_intf_header_id_tbl.COUNT);

  FOR i IN 1..l_intf_header_id_tbl.COUNT LOOP
    IF (l_action_tbl(i) = PO_PDOI_CONSTANTS.g_action_UPDATE) THEN
      d_position := 20;

      -- If we are updating a document, a draft for the document may or may
      -- not exist. if the draft exists, reuse it; if not, create a new
      -- draft

      PO_DRAFTS_PVT.find_draft
      ( p_po_header_id     => l_po_header_id_tbl(i),
        x_draft_id         => l_tmp_draft_id,
        x_draft_status     => l_tmp_draft_status,
        x_draft_owner_role => l_tmp_draft_owner_role
      );

      d_position := 30;

      IF (l_tmp_draft_id IS NULL) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'draft id not found');
        END IF;

        d_position := 40;

        -- need to create a new draft
        l_new_dft_idx_tbl.extend;
        l_new_dft_idx_tbl(l_new_dft_idx_tbl.COUNT) := i;
        l_draft_id_tbl(i) := PO_DRAFTS_PVT.draft_id_nextval;

      ELSE
        IF (l_tmp_draft_status IN (PO_DRAFTS_PVT.g_status_PDOI_PROCESSING,
                                   PO_DRAFTS_PVT.g_status_PDOI_ERROR)) THEN

          d_position := 50;

          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'existing draft is processed ' ||
                        'by PDOI. check whether the previous PDOI is still ' ||
                        'working on it');
          END IF;

          -- check whether the existing draft is still valid, or it is just
          -- data corruption caused by incomplete execution of the previous
          -- PDOI run.
          check_new_draft_needed
          ( p_draft_id => l_tmp_draft_id,
            p_status   => l_tmp_draft_status,
            x_new_draft_needed => l_new_draft_needed
          );

          d_position := 60;


          IF (l_new_draft_needed = FND_API.G_TRUE) THEN
            d_position := 70;

            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module, d_position, 'old draft can be removed. ' ||
                          'Creating a new one');
            END IF;

            PO_DRAFTS_PVT.remove_draft_changes
            ( p_draft_id => l_tmp_draft_id,
              p_exclude_ctrl_tbl => FND_API.G_FALSE,
              x_return_status => l_return_status
            );

            -- new draft to be created
            l_new_dft_idx_tbl.EXTEND;
            l_new_dft_idx_tbl(l_new_dft_idx_tbl.COUNT) := i;
            l_draft_id_tbl(i) := PO_DRAFTS_PVT.draft_id_nextval;
          ELSE
            d_position := 80;

            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module, d_position, 'old draft is still being ' ||
                          'worked on. Fail the current intf record');
            END IF;

            PO_PDOI_ERR_UTL.add_fatal_error
            ( p_interface_header_id => l_intf_header_id_tbl(i),
              p_error_message_name => 'PO_LOCKED_OR_INVALID_STS',
              p_table_name => 'PO_HEADERS_INTERFACE',
              p_column_name => 'DRAFT_ID',
              p_column_value => l_tmp_draft_id
            );

            -- the existing draft is still running. Need to reject the interface
            -- record for the current run as it cannot be processed
            l_reject_list.EXTEND;
            l_reject_list(l_reject_list.COUNT) := l_intf_header_id_tbl(i);
          END IF;

        ELSE

          d_position := 90;

          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'draft with id ' ||
						            l_tmp_draft_id || ' can be reused.');
          END IF;

          -- other draft status -- reuse the draft
          l_draft_id_tbl(i) := l_tmp_draft_id;
          l_existing_dft_idx_tbl.extend;
          l_existing_dft_idx_tbl(l_existing_dft_idx_tbl.COUNT) := i;
        END IF;
      END IF;

    ELSE
      d_position := 100;

      -- actions that cause new documents to be created
      l_new_dft_idx_tbl.extend;
      l_new_dft_idx_tbl(l_new_dft_idx_tbl.COUNT) := i;
      l_draft_id_tbl(i) := PO_DRAFTS_PVT.draft_id_nextval;
    END IF;
  END LOOP;

  d_position := 110;

  PO_PDOI_UTL.reject_headers_intf
  ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID,
    p_id_tbl        => l_reject_list,
    p_cascade       => FND_API.G_TRUE
  );

  d_position := 120;

  -- stamp draft_id value to interface table
  FORALL i IN 1..l_intf_header_id_tbl.COUNT
    UPDATE po_headers_interface
    SET    draft_id = l_draft_id_tbl(i)
    WHERE  interface_header_id = l_intf_header_id_tbl(i)
    AND    processing_id = PO_PDOI_PARAMS.g_processing_id;

  d_position := 130;

  -- Since DB 10g (bug4340345) has probems using VALUES OF against EMPTY
  -- COLLECTION, Check the collection and call FORALL only if it's not empty

  IF (l_new_dft_idx_tbl.COUNT > 0) THEN
    d_position := 140;
    -- Create new drafts
    FORALL i IN VALUES OF l_new_dft_idx_tbl
      INSERT INTO po_drafts
      ( draft_id,
        document_id,
        revision_num,
        owner_user_id,
        owner_role,
        status,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by,
        request_id
      )
      VALUES
      ( l_draft_id_tbl(i),
        l_po_header_id_tbl(i),
        l_revision_num_tbl(i),
        FND_GLOBAL.user_id,
        PO_PDOI_PARAMS.g_request.role,
        l_status,
        SYSDATE,
        FND_GLOBAL.user_id,
        FND_GLOBAL.login_id,
        SYSDATE,
        FND_GLOBAL.user_id,
        FND_GLOBAL.conc_request_id
      );

  END IF;

  -- bug5129752
  -- Update new draft flag
  FOR i IN 1..l_new_dft_idx_tbl.COUNT LOOP
    -- get the interface header id that creates the new draft, and set
    -- the new draft flag
    l_intf_hdr_id := l_intf_header_id_tbl ( l_new_dft_idx_tbl(i) );
    PO_PDOI_PARAMS.g_docs_info(l_intf_hdr_id).new_draft := FND_API.G_TRUE;

  END LOOP;

  d_position := 150;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position,
                'Number of existing drafts: ' || l_existing_dft_idx_tbl.COUNT);
  END IF;

  -- Since DB 10g has probems using VALUES OF against EMPTYCOLLECTION,
  -- Check the collection and call FORALL only if it's not empty

  IF (l_existing_dft_idx_tbl.COUNT > 0) THEN
    d_position := 160;
    -- If we are updating an existing draft, we need to temporarily set the
    -- status to PDOI_PROCESSING
    FORALL i IN VALUES OF l_existing_dft_idx_tbl
      UPDATE po_drafts
      SET    status = l_status,
             request_id = FND_GLOBAL.conc_request_id,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id
      WHERE  draft_id = l_draft_id_tbl(i);
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END assign_draft_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: expire_lines_by_catalog_name
--Function:
--  Expire all the lines that match the catalog name specified in the parameter.
--  This involves bringing the lines to draft table.
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE expire_lines_by_catalog_name IS

d_api_name CONSTANT VARCHAR2(30) := 'expire_lines_by_catalog_name';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_draft_id_tbl PO_TBL_NUMBER;
l_line_id_tbl PO_TBL_NUMBER;
l_delete_flag_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

l_record_exist_tbl PO_TBL_VARCHAR1;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  --SQL What: Get all the existing lines that match the category name given
  --          Make sure that the lines are not cancelled, closed or expired
  --SQL Why: All those lines need to be expired.
  SELECT PHI.draft_id,
         POL.po_line_id
  BULK COLLECT
  INTO   l_draft_id_tbl,
         l_line_id_tbl
  FROM   po_headers_interface PHI,
         po_lines_all POL
  WHERE  PHI.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    PHI.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
  AND    PHI.po_header_id = POL.po_header_id
  AND    POL.catalog_name = PO_PDOI_PARAMS.g_request.catalog_to_expire
  AND    NVL(POL.cancel_flag, 'N') = 'N'
  AND    NVL(POL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
  AND    NVL(POL.expiration_date, SYSDATE+1) > SYSDATE;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of lines to expire',
                l_line_id_tbl.COUNT);
  END IF;

  IF (l_line_id_tbl.COUNT > 0) THEN
    d_position := 10;

    l_delete_flag_tbl.EXTEND(l_line_id_tbl.COUNT);

    -- Bring all lines with matching catalog name to draft table
    PO_LINES_DRAFT_PKG.sync_draft_from_txn
    ( p_po_line_id_tbl => l_line_id_tbl,
      p_draft_id_tbl => l_draft_id_tbl,
      p_delete_flag_tbl => l_delete_flag_tbl,
      x_record_already_exist_tbl => l_record_exist_tbl
    );

    d_position := 20;

    -- set expiration date of the lines
    FORALL i IN 1..l_line_id_tbl.COUNT
    UPDATE po_lines_draft_all
    SET    expiration_date = TRUNC(SYSDATE-1)
    WHERE  po_line_id = l_line_id_tbl(i)
    AND    draft_id = l_draft_id_tbl(i);

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END expire_lines_by_catalog_name;

-----------------------------------------------------------------------
--Start of Comments
--Name: init_doc_info_tbl
--Function:
--  initialize a structure that holds extra header interface record information
--  such has number of processed lines, whether there are lines to notify, etc.
--Parameters:
--IN:
--p_intf_header_id_tbl
--  list of interface header ids
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE init_doc_info_tbl
( p_intf_header_id_tbl PO_TBL_NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'init_doc_info_tbl';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_id PO_HEADERS_INTERFACE.interface_header_id%TYPE;


-- bug5215871 START
l_reject_count NUMBER;
-- bug5215871 END

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  PO_PDOI_PARAMS.g_docs_info.DELETE;

  d_position := 10;

  FOR i IN 1..p_intf_header_id_tbl.COUNT LOOP
    l_id := p_intf_header_id_tbl(i);

    -- bug5215871
    -- Count the number of the lines that are already rejected before
    -- PDOI processes them. We need to include them processed and errored
    -- out.
    SELECT count(*)
    INTO   l_reject_count
    FROM   po_lines_interface PLI
    WHERE  PLI.interface_header_id = p_intf_header_id_tbl(i)
    AND    PLI.process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED;

    PO_PDOI_PARAMS.g_docs_info(l_id).number_of_processed_lines :=
      l_reject_count;
    PO_PDOI_PARAMS.g_docs_info(l_id).number_of_errored_lines :=
      l_reject_count;
    PO_PDOI_PARAMS.g_docs_info(l_id).number_of_valid_lines := 0;
    PO_PDOI_PARAMS.g_docs_info(l_id).err_tolerance_exceeded := FND_API.G_FALSE;
    PO_PDOI_PARAMS.g_docs_info(l_id).has_errors := FND_API.G_FALSE;
    PO_PDOI_PARAMS.g_docs_info(l_id).has_lines_to_notify := FND_API.G_FALSE;
    PO_PDOI_PARAMS.g_docs_info(l_id).new_draft := FND_API.G_FALSE; -- bug5129752
  END LOOP;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END init_doc_info_tbl;


-----------------------------------------------------------------------
--Start of Comments
--Name: check_new_draft_needed
--Function:
--  Check whether the previous draft is still being processed by PDOI.
--  If not, then return a flag telling the caller to create a new draft,
--  as the existing one is no longer being processed.
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_status
--  status of the draft. (status will be PDOI related. Possible values:
--  PDOI_PROCESSING, PDOI_ERROR
--IN OUT:
--OUT:
--x_new_draft_needed
--  FND_API.G_TRUE if a new draft needs to be created
--  FND_API.G_FALSE if the old draft is still effective
--End of Comments
------------------------------------------------------------------------
PROCEDURE check_new_draft_needed
( p_draft_id IN NUMBER,
  p_status   IN VARCHAR2,
  x_new_draft_needed OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'check_new_draft_needed';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_dft_request_id PO_DRAFTS.request_id%TYPE;
l_cur_request_id NUMBER;


BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'p_draft_id', p_draft_id);
    PO_LOG.proc_begin (d_module, 'p_status', p_status);
  END IF;

  x_new_draft_needed := FND_API.G_FALSE;

  IF (p_status = PO_DRAFTS_PVT.g_status_PDOI_ERROR) THEN
    d_position := 10;

    x_new_draft_needed := FND_API.G_TRUE;

  ELSIF (p_status = PO_DRAFTS_PVT.g_status_PDOI_PROCESSING) THEN
    d_position := 20;

    l_cur_request_id := FND_GLOBAL.conc_request_id;

    PO_DRAFTS_PVT.get_request_id
    ( p_draft_id => p_draft_id,
      x_request_id => l_dft_request_id
    );

    x_new_draft_needed := PO_PDOI_UTL.is_old_request_complete
                          ( p_old_request_id => l_dft_request_id
                          );

  END IF;  -- if status = p_status = PO_DRAFTS_PVT.g_status_PDOI_ERROR

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module, 'x_new_draft_needed', x_new_draft_needed);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END check_new_draft_needed;




END PO_PDOI_HEADER_GROUPING_PVT;

/
