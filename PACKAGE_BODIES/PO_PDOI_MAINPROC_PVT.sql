--------------------------------------------------------
--  DDL for Package Body PO_PDOI_MAINPROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_MAINPROC_PVT" AS
/* $Header: PO_PDOI_MAINPROC_PVT.plb 120.21.12010000.18 2015/01/16 06:42:03 sbontala ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_MAINPROC_PVT');

g_snap_shot_too_old       EXCEPTION;
PRAGMA EXCEPTION_INIT(g_snap_shot_too_old, -1555);

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------
PROCEDURE process_headers;

PROCEDURE process_lines;

PROCEDURE process_lines_add
(
  p_data_set_type IN NUMBER  -- choice on data set to be processed
);

PROCEDURE process_lines_sync
(
  p_data_set_type IN NUMBER  -- choice on data set to be processed
);

PROCEDURE process_create_lines_in_group
(
  p_group_num           IN NUMBER,
  p_expire_line_id_tbl  IN DBMS_SQL.NUMBER_TABLE,
  p_expire_line_index_tbl IN DBMS_SQL.NUMBER_TABLE, --bug19046588
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE process_update_lines_in_group
(
  p_group_num           IN NUMBER,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE process_line_locations;

PROCEDURE process_distributions;

PROCEDURE process_price_diffs;

PROCEDURE process_attributes;

PROCEDURE process_attr_values;

PROCEDURE process_attr_values_tlp;



--<<PDOI Enhancement bug#17063664 START>>--
PROCEDURE process_create_lines
(  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE process_update_lines
(  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE process_match_lines
(  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE process_create_line_locs
(  x_line_locs      IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

PROCEDURE process_update_line_locs
(  x_line_locs      IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
);

--<<PDOI Enhancement bug#17063664 END>>--
--Bug 13343886
PROCEDURE gather_stats(p_table_name IN VARCHAR2,p_api_name IN VARCHAR2,p_position IN VARCHAR2);
--Bug 13343886
--------------------------------------------------------------------------
---------------------- PUBLIC PROCEDURES ---------------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--Start of Comments
--Name: process
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  perform derive, default, validate and insert/update logic on all records
--  in interface tables
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns: None
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE process IS

  d_api_name CONSTANT VARCHAR2(30) := 'process';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'start main process for header group',
                      PO_PDOI_PARAMS.g_current_round_num);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_MAIN_PROCESSING);

  -- clean up cache before each group processing
  PO_PDOI_MAINPROC_UTL_PVT.cleanup;

  d_position := 10;

  -- process each entity from upper to lower level
  process_headers;

  -- return when document type is contract, because there is no need to process lines
  -- and shipments for CONTRACT type documents.
  IF (PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT) THEN
    d_position := 20;
    RETURN;
  END IF;

  d_position := 30;

  process_lines;

  d_position := 40;

  IF (PO_PDOI_PARAMS.g_request.document_type IN
       (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET, PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)) THEN
    process_attributes;
  END IF;

  d_position := 50;

  process_line_locations;

  d_position := 60;

  IF (PO_PDOI_PARAMS.g_request.document_type =
       PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
    process_distributions;
  END IF;

  d_position := 70;

  process_price_diffs;

  d_position := 80;

  -- Bug 5215781:
  -- Remove all unprocessed records if error threshold is hit for CATALOG UPLOAD
  IF (PO_PDOI_PARAMS.g_request.calling_module =
        PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD AND
      PO_PDOI_PARAMS.g_docs_info(PO_PDOI_PARAMS.g_request.interface_header_id)
        .err_tolerance_exceeded = FND_API.g_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Unprocessed records will be removed for header ',
                  PO_PDOI_PARAMS.g_request.interface_header_id);
    END IF;

    PO_PDOI_UTL.reject_unprocessed_intf
    (
      p_intf_header_id => PO_PDOI_PARAMS.g_request.interface_header_id
    );
  END IF;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_MAIN_PROCESSING);

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
END process;

-------------------------------------------------------------------------
--------------------- PRIVATE PROCEDURES --------------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--Start of Comments
--Name: process_headers
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive, default, validate and insert records
--  from po_headers_interface table
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_headers IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_headers';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- cursor variable to point to currently processing row
  l_headers_csr        PO_PDOI_TYPES.intf_cursor_type;

  -- all header attribute values within a batch
  l_headers PO_PDOI_TYPES.headers_rec_type;

  -- variable to track the largest intf_header_id processed so far
  l_max_intf_header_id NUMBER := -1;

  -- variables to track the records that need to be rejected due
  -- to errors in the processing
  l_count  NUMBER := 0;
  l_rej_intf_header_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_HEADER_PROCESS);

  -- open cursor for the query which retrieve the header info
  PO_PDOI_HEADER_PROCESS_PVT.open_headers
  (
    p_max_intf_header_id   => l_max_intf_header_id,
    x_headers_csr          => l_headers_csr
  );

  d_position := 10;

  -- fetch records from header interface table and process the records
  LOOP
    BEGIN
      -- fetch one batch of header records from query result
      PO_PDOI_HEADER_PROCESS_PVT.fetch_headers
      (
        x_headers_csr   => l_headers_csr,
        x_headers       => l_headers
      );

      d_position := 20;

      -- number of records read in current batch
      l_headers.rec_count := l_headers.intf_header_id_tbl.COUNT;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'header count within batch',
                    l_headers.rec_count);
      END IF;

      EXIT WHEN l_headers.rec_count = 0;

      -- set up hashtable between interface_header_id and index
      l_headers.intf_id_index_tbl.DELETE;

      FOR i IN 1..l_headers.rec_count
      LOOP
        l_headers.intf_id_index_tbl(l_headers.intf_header_id_tbl(i)) := i;
      END LOOP;

      --Derivation is not required if being called from autocreate code
      IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
       -- derive logic
         PO_PDOI_HEADER_PROCESS_PVT.derive_headers
        (
         x_headers     => l_headers
        );
      END IF;

      d_position := 30;

      -- default logic
      PO_PDOI_HEADER_PROCESS_PVT.default_headers
      (
        x_headers     => l_headers
      );

      d_position := 40;

      -- <PDOI Enhancement Bug#17063664>
      -- Skipping validations if called from autocreate flow
      IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                        PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                        PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
        -- validate logic
        PO_PDOI_HEADER_PROCESS_PVT.validate_headers
        (
          x_headers     => l_headers
        );
      END IF;
      d_position := 50;

      -- insert valid header records into draft tables
      PO_PDOI_MOVE_TO_DRAFT_TABS_PVT.insert_headers
      (
        p_headers     => l_headers
      );

      d_position := 60;

      -- Rejected header records with errors
      l_rej_intf_header_id_tbl.EXTEND(l_headers.rec_count);
      FOR i IN 1..l_headers.rec_count
      LOOP
        IF (l_headers.error_flag_tbl(i) = FND_API.g_TRUE) THEN
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'rejected intf header id',
                        l_headers.intf_header_id_tbl(i));
          END IF;

          l_count := l_count + 1;
          l_rej_intf_header_id_tbl(l_count) := l_headers.intf_header_id_tbl(i);
        END IF;
      END LOOP;
      PO_PDOI_UTL.reject_headers_intf
      (
        p_id_param_type    => PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID,
        p_id_tbl           => l_rej_intf_header_id_tbl,
        p_cascade          => FND_API.g_TRUE
      );
      l_rej_intf_header_id_tbl.DELETE;

      d_position := 70;

      -- conditional commit
      PO_PDOI_UTL.commit_work;

      -- set maximal intf_header_id read so far(used in next batch read)
      l_max_intf_header_id := l_headers.intf_header_id_tbl(l_headers.rec_count);

  -- exit if this is the last batch
      IF (l_headers.rec_count < PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE) THEN
        EXIT;
      END IF;
    EXCEPTION
      WHEN g_snap_shot_too_old THEN
        d_position := 80;

        PO_MESSAGE_S.add_exc_msg
        (
          p_pkg_name => d_pkg_name,
          p_procedure_name => d_api_name || '.' || d_position
        );

        -- commit changes
        PO_PDOI_UTL.commit_work;

        IF (l_headers_csr%ISOPEN) THEN
          CLOSE l_headers_csr;
          PO_PDOI_HEADER_PROCESS_PVT.open_headers
          (
            p_max_intf_header_id   => l_max_intf_header_id,
            x_headers_csr          => l_headers_csr
          );
        END IF;
    END;
  END LOOP;

  d_position := 90;

  -- close cursor
  IF (l_headers_csr%ISOPEN) THEN
    CLOSE l_headers_csr;
  END IF;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_HEADER_PROCESS);

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
END process_headers;

-------------------------------------------------------------------------
--Start of Comments
--Name: process_lines
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  process the records in po_lines_interface table;
--  the records in the interface table will be divided into four sets
--  according to their header and line level actions:
--  First set: all the lines with header action equal to 'ORIGINAL'or
--             'REPLACE'; If header action is 'UPDATE', the document
--             must be Standard PO
--  Second Set: Header level action is 'UPDATE' and document type is
--              'BLANKET' or 'QUOTATION'; And line level action is 'ADD'
--  Third Set: Header level action is 'UPDATE' and document type is
--             'BLANKET' or 'QUOTATION'; And line level action is 'SYNC'
--             or Null; And either of the following criteria is true:
--             1. one of attributes {item, vendor_product_num, job} is not null
--             2. if {item, vendor_product_num, job) are all null, then
--                description must be null
--  Fourth Set: Header level action is 'UPDATE' and document type is
--             'BLANKET' or 'QUOTATION'; And line level action is 'SYNC'
--             or Null; {item, vendor_product_num, job) are all null and
--             description is not null
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_lines IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_PROCESS);

  -- reject lines with existing line_num when updating standard PO
  IF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
    PO_PDOI_LINE_PROCESS_PVT.reject_dup_lines_for_spo;
  END IF;

  -- reject lines with invalid line level action.
  -- line level action can only be NULL or 'ADD';
  -- the only exception for this is when we re-process
  -- the notified lines, the system has set the line
  -- level action to either 'ADD' or 'UPADTE', we don't
  -- need to check line level action for NOTOFIED lines
  IF (PO_PDOI_PARAMS.g_request.process_code <>
       PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED) THEN
    PO_PDOI_LINE_PROCESS_PVT.reject_invalid_action_lines;
  END IF;

  d_position := 10;

  -- first data set
  process_lines_add
  (
    p_data_set_type     => PO_PDOI_CONSTANTS.g_LINE_CSR_ADD
  );

  d_position := 20;

  -- second data set
  process_lines_add
  (
    p_data_set_type     => PO_PDOI_CONSTANTS.g_LINE_CSR_FORCE_ADD
  );

  d_position := 30;

  -- third data set
  process_lines_sync
  (
    p_data_set_type     => PO_PDOI_CONSTANTS.g_LINE_CSR_SYNC
  );

  d_position := 40;

  -- Fourth data set
  process_lines_sync
  (
    p_data_set_type     => PO_PDOI_CONSTANTS.g_LINE_CSR_SYNC_ON_DESC
  );

  d_position := 50;

    --Bug13343886
	if PO_PDOI_CONSTANTS.g_GATHER_STATS = 'Y' THEN
			d_position := 55;
		gather_stats('PO_LINES_DRAFT_ALL',d_api_name,d_position);
	END IF;
	--Bug13343886

  -- delete all locations from po_line_locations_interface that are obsoleted
  DELETE FROM po_line_locations_interface
  WHERE process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_OBSOLETE
  AND   processing_id = PO_PDOI_PARAMS.g_processing_id;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_PROCESS);

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
END process_lines;

-----------------------------------------------------------------------
--Start of Comments
--Name: process_lines_add
--Function: This procedure will deal with two kinds of data set:
--  First set: all the lines with header action equal to 'ORIGINAL'or
--             'REPLACE'; If header action is 'UPDATE', the document
--             must be Standard PO
--  Second Set: Header level action is 'UPDATE' and document type is
--              'BLANKET' or 'QUOTATION'; And line level action is 'ADD'
--  The two data set share similiar processing logic except for the data
--  to be processed. There is also an extra matching logic for First Set.
--Parameters:
--IN:
--p_data_set_type
--  the value determines which data set is going to be processed:
--  PO_PDOI_CONSTANTS.g_LINE_CSR_ADD: first data set
--  PO_PDOI_CONSTANTS.g_LINE_CSR_FORCE_ADD: second data set
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_lines_add
(
  p_data_set_type IN NUMBER  -- choice on data set to be processed
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_lines_add';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- cursor variable defined for the query
  l_lines_csr PO_PDOI_TYPES.intf_cursor_type;

  -- all line attribute values within a batch
  l_lines PO_PDOI_TYPES.lines_rec_type;
  -- PDOI Enhancement Bug#17063664
  l_create_lines PO_PDOI_TYPES.lines_rec_type;
  l_update_lines PO_PDOI_TYPES.lines_rec_type;
  l_match_lines PO_PDOI_TYPES.lines_rec_type;

  -- variable to track the largest intf_line_id processed so far
  l_max_intf_line_id NUMBER := -1;

  -- bug#13367649- variable to track the number of records fetched
  -- for each loop iteration
  l_lines_count NUMBER;

  -- variables to track the records that need to be rejected due
  -- to errors in the processing
  l_rej_intf_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

  --<PDOI Enhancement Bug#17064664>
  l_key po_session_gt.key%TYPE;
  l_draft_id_tbl PO_TBL_NUMBER;
  l_line_id_tbl PO_TBL_NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_data_set_type', p_data_set_type);
  END IF;

  /*
  -- code added for debugging purpose
  select interface_header_id
  into PO_PDOI_PARAMS.g_request.interface_header_id
  from po_headers_interface
  where processing_id = PO_PDOI_PARAMS.g_processing_id
  and   processing_round_num = 1;
  */

  -- Bug 5215781:
  -- exit immediately if error threshold is hit for CATALOG UPLOAD
  IF (PO_PDOI_PARAMS.g_request.calling_module =
        PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD AND
      PO_PDOI_PARAMS.g_docs_info(PO_PDOI_PARAMS.g_request.interface_header_id)
        .err_tolerance_exceeded = FND_API.g_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Exit from process_lines_add since' ||
                  ' error threshold is hit for header ',
                  PO_PDOI_PARAMS.g_request.interface_header_id);
    END IF;

    RETURN;
  END IF;

  d_position := 5;

  -- open cursor for the correct query
  PO_PDOI_LINE_PROCESS_PVT.open_lines
  (
    p_data_set_type      => p_data_set_type,
    p_max_intf_line_id   => l_max_intf_line_id,
    x_lines_csr          => l_lines_csr
  );

  d_position := 10;

  --<PDOI Enhancement Bug#17064664>
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- fetch records from line interface table and process the records
  LOOP
    -- Bug 5215781:
    -- check whether num of error lines exceeds the error
    -- threshold for each batch
    IF (PO_PDOI_PARAMS.g_request.calling_module =
          PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD AND
        PO_PDOI_PARAMS.g_docs_info(PO_PDOI_PARAMS.g_request.interface_header_id)
          .err_tolerance_exceeded = FND_API.g_TRUE) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'error tolerance exceeded for',
                    PO_PDOI_PARAMS.g_request.interface_header_id);
      END IF;

      -- no need to process remaining lines if error threshold is reached
      EXIT;
    END IF;

    BEGIN
      -- fetch one batch of line records from query result
      PO_PDOI_LINE_PROCESS_PVT.fetch_lines
      (
        x_lines_csr   => l_lines_csr,
        x_lines       => l_lines
      );

      d_position := 20;

      -- number of records read in current batch
      l_lines.rec_count := l_lines.intf_line_id_tbl.COUNT;

      --
      -- bug#13367649- number of records fetched for
      -- this iteration
      --
      l_lines_count := l_lines.intf_line_id_tbl.COUNT;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'line count in batch',
                    l_lines.rec_count);
      END IF;

      EXIT WHEN l_lines.rec_count = 0;

      -- bug#13367649- set the maximal interface_line_id fetched in this batch
      l_max_intf_line_id := l_lines.intf_line_id_tbl(l_lines.rec_count);

      -- set up hashtable between interface_line_id and index
      l_lines.intf_id_index_tbl.DELETE;

      FOR i IN 1..l_lines.rec_count
      LOOP
        l_lines.intf_id_index_tbl(l_lines.intf_line_id_tbl(i)) := i;
      END LOOP;

      -- calculate max_line_num for all document in this batch
      -- the result is saved and used in line processing
      PO_PDOI_MAINPROC_UTL_PVT.calculate_max_line_num
      (
        p_po_header_id_tbl    => l_lines.hd_po_header_id_tbl,
        p_draft_id_tbl        => l_lines.draft_id_tbl
      );

      d_position := 30;

      -- <PDOI Enhancement Bug#17063664>
      -- Skipping the derivations during autocreate flow
     IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN

      -- derive logic
      PO_PDOI_LINE_PROCESS_PVT.derive_lines
      (
        x_lines               => l_lines
      );

     END IF ;

      d_position := 40;

      -- default logic
      PO_PDOI_LINE_PROCESS_PVT.default_lines
      (
        x_lines               => l_lines
      );

      d_position := 50;

     -- <PDOI Enhancement Bug#17063664>
      -- Skipping the validation during autocreate flow
      IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
      -- <PDOI Enhancement Bug#17063664>
      PO_PDOI_LINE_PROCESS_PVT.uniqueness_check
      (
         x_lines               => l_lines
       );

       END IF;

      -- match related lines based on line_num/item info
      -- PDOI Enhancement Bug# : Added new parameters
      -- to get create and update Lines
      PO_PDOI_LINE_PROCESS_PVT.match_lines
      (
        p_data_set_type    => p_data_set_type, -- bug5129752
        x_lines            => l_lines,
        x_create_lines     => l_create_lines,
        x_update_lines     => l_update_lines,
        x_match_lines      => l_match_lines
      );


      d_position := 60;

      --<<PDOI Enhancement Bug#17064664 START>>--
      process_create_lines
       (
        x_lines  => l_create_lines
       );

      d_position := 70;
      process_update_lines
       (
        x_lines => l_update_lines
        );

      d_position := 80;
      process_match_lines
      (
        x_lines => l_match_lines
      );

        FORALL i IN 1..l_lines.po_line_id_tbl.COUNT
          INSERT INTO po_session_gt(
          key,
          index_num1,
          index_num2
          )
          SELECT l_key,
                  l_lines.draft_id_tbl(i),
                  l_lines.po_line_id_tbl(i)
          FROM dual
          WHERE l_lines.error_flag_tbl(i) = FND_API.G_FALSE;


      -- commit changes
      PO_PDOI_UTL.commit_work;

      -- set the maximal interface_line_id processed in this batch
      -- bug#13367649-  move line to after fetch as l_lines.rec_count
      -- now is number of records to create, not the original number
      -- of records fetched for this iteration.  After match_lines,
      -- l_lines.rec_count contains number of po_lines to be created

      -- l_max_intf_line_id := l_lines.intf_line_id_tbl(l_lines.rec_count);

      --
      -- bug#13367649- use local variable l_lines_count instead as
      -- l_lines.rec_count now contains number of po_lines to be created
      -- for this fetch,  which can be less than the batch size

      -- IF (l_lines.rec_count < PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE) THEN

      IF (l_lines_count < PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE) THEN
        EXIT;
      END IF;
    EXCEPTION
      WHEN g_snap_shot_too_old THEN
        d_position := 120;

        -- log errors
        PO_MESSAGE_S.add_exc_msg
        (
          p_pkg_name => d_pkg_name,
          p_procedure_name => d_api_name || '.' || d_position
        );

        -- commit changes
        PO_PDOI_UTL.commit_work;

        IF (l_lines_csr%ISOPEN) THEN
          CLOSE l_lines_csr;
          PO_PDOI_LINE_PROCESS_PVT.open_lines
          (
            p_data_set_type      => p_data_set_type,
            p_max_intf_line_id   => l_max_intf_line_id,
            x_lines_csr          => l_lines_csr
          );
        END IF;
    END;
  END LOOP;

  d_position := 130;

  -- close the cursor
  IF (l_lines_csr%ISOPEN) THEN
    CLOSE l_lines_csr;
  END IF;

  d_position := 140;



  -- <PDOI Enhancement Bug#17063664>
  -- Group validations.
    DELETE FROM po_session_gt
          WHERE key = l_key
      RETURNING    index_num1,
                   index_num2
 BULK COLLECT INTO l_draft_id_tbl,
                   l_line_id_tbl;

  -- <PDOI Enhancement Bug#17063664>
  -- Skipping the validations during autocreate flow
  IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
  PO_PDOI_LINE_PROCESS_PVT.reject_after_grp_validate(l_draft_id_tbl,l_line_id_tbl);
  END IF ;

  -- reject lines that are price breaks if main po line failed
  SELECT interface_line_id
  BULK COLLECT INTO l_rej_intf_line_id_tbl
  FROM   po_lines_interface intf_line1
  WHERE  price_break_flag = 'Y'
  AND    processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    EXISTS(
           SELECT 'Y'
           FROM   po_lines_interface intf_line2
           WHERE  intf_line1.interface_header_id = intf_line2.interface_header_id
           AND    intf_line1.po_line_id = intf_line2.po_line_id
           AND    NVL(intf_line2.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
		            = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED
           AND    NVL(intf_line2.price_break_flag, 'N') = 'N');
  d_position := 150;
  PO_PDOI_UTL.reject_lines_intf
  (
    p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
    p_id_tbl          => l_rej_intf_line_id_tbl,
    p_cascade         => FND_API.g_TRUE
  );

  d_position := 160;

  -- set status to NOTIFIED for price break lines if main po line is NOTIFIED
  UPDATE po_lines_interface intf_line1
  SET    intf_line1.process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED
  WHERE  intf_line1.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    intf_line1.price_break_flag = 'Y'
  AND    EXISTS(
           SELECT 'Y'
           FROM   po_lines_interface intf_line2
           WHERE  intf_line2.interface_header_id = intf_line1.interface_header_id
           AND    intf_line2.po_line_id = intf_line1.po_line_id
           AND    NVL(intf_line2.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
		            = PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED
           AND    NVL(intf_line2.price_break_flag, 'N') = 'N');

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
END process_lines_add;

-----------------------------------------------------------------------
--Start of Comments
--Name: process_lines_sync
--Function: This procedure will deal with two kinds of data set from
--          calling procedure:
--  Third Set: Header level action is 'UPDATE' and document type is
--             'BLANKET' or 'QUOTATION'; And line level action is 'SYNC'
--             or Null; And either of the following criteria is true:
--             1. one of attributes {item, vendor_product_num, job} is not null
--             2. if {item, vendor_product_num, job) are all null, then
--                description must be null
--  Fourth Set: Header level action is 'UPDATE' and document type is
--             'BLANKET' or 'QUOTATION'; And line level action is 'SYNC'
--             or Null; {item, vendor_product_num, job) are all null and
--             description is not null
--
--Parameters:
--IN:
--  p_data_set_type
--  the value determines which data set is going to be processed:
--  PO_PDOI_CONSTANTS.g_LINE_CSR_SYNC: third data set
--  PO_PDOI_CONSTANTS.g_LINE_CSR_SYNC_ON_DESC: fourth data set
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_lines_sync
(
  p_data_set_type IN NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_lines_sync';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- cursor variable defined for the query
  l_lines_csr            PO_PDOI_TYPES.intf_cursor_type;

  -- all line attribute values within a batch
  l_lines                PO_PDOI_TYPES.lines_rec_type;

  -- variable to track the largest intf_line_id processed so far
  l_max_intf_line_id     NUMBER := -1;

  -- lines that are going to be created/updated
  l_create_lines         PO_PDOI_TYPES.lines_rec_type;
  l_update_lines         PO_PDOI_TYPES.lines_rec_type;
  -- PDOI Enhancement Bug#17063664
  l_match_lines         PO_PDOI_TYPES.lines_rec_type;

  /*  bug 6926550 Added the following variable to null the
  l_create_lines and l_update_lines inside the procedure*/
  l_null_lines         PO_PDOI_TYPES.lines_rec_type;

  -- line grouping num
  l_group_num            NUMBER := 0;

  -- variable to track records that have not been processed
  l_processing_row_tbl   DBMS_SQL.NUMBER_TABLE;

  -- variable to track lines that need to be expired
  l_expire_line_id_tbl   DBMS_SQL.NUMBER_TABLE;
  l_expire_line_index_tbl DBMS_SQL.NUMBER_TABLE; --bug19046588

  l_rej_intf_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_notified_intf_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_data_set_type', p_data_set_type);
  END IF;

  -- Bug 5215781:
  -- exit immediately if error threshold is hit for CATALOG UPLOAD
  IF (PO_PDOI_PARAMS.g_request.calling_module =
        PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD AND
      PO_PDOI_PARAMS.g_docs_info(PO_PDOI_PARAMS.g_request.interface_header_id)
        .err_tolerance_exceeded = FND_API.g_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Exit from process_lines_sync since' ||
                  ' error threshold is hit for header ',
                  PO_PDOI_PARAMS.g_request.interface_header_id);
    END IF;

    RETURN;
  END IF;

  d_position := 5;

  -- open cursor for the correct query
  PO_PDOI_LINE_PROCESS_PVT.open_lines
  (
    p_data_set_type      => p_data_set_type,
    p_max_intf_line_id   => l_max_intf_line_id,
    x_lines_csr          => l_lines_csr
  );

  d_position := 10;

  -- fetch records from line interface table and process the records
  LOOP
    -- Bug 5215781:
    -- check whether num of error lines exceeds the error
    -- threshold for the previous batch
    IF (PO_PDOI_PARAMS.g_request.calling_module =
          PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD AND
        PO_PDOI_PARAMS.g_docs_info(PO_PDOI_PARAMS.g_request.interface_header_id)
          .err_tolerance_exceeded = FND_API.g_TRUE) THEN
      d_position := 20;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'error tolerance exceeded for',
                    PO_PDOI_PARAMS.g_request.interface_header_id);
      END IF;

      EXIT;
    END IF;

    BEGIN
      -- fetch one batch of line records from query result
      PO_PDOI_LINE_PROCESS_PVT.fetch_lines
      (
        x_lines_csr   => l_lines_csr,
        x_lines       => l_lines
      );

      d_position := 30;

      -- number of records read in current batch
      l_lines.rec_count := l_lines.intf_line_id_tbl.COUNT;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'line count in batch',
                    l_lines.rec_count);
      END IF;

      EXIT WHEN l_lines.rec_count = 0;

      /* <bug 6926550> null the l_create_lines and l_update_lines
         before calling split lines procedure in the inner loop*/
          l_create_lines  := l_null_lines;
          l_update_lines  := l_null_lines;

      -- set up hashtable between interface_line_id and index
      l_lines.intf_id_index_tbl.DELETE;

      FOR i IN 1..l_lines.rec_count
      LOOP
        l_lines.intf_id_index_tbl(l_lines.intf_line_id_tbl(i)) := i;
      END LOOP;

      -- calculate max_line_num for all document in this batch
      -- the result is saved and used in line processing
      PO_PDOI_MAINPROC_UTL_PVT.calculate_max_line_num
      (
        p_po_header_id_tbl    => l_lines.hd_po_header_id_tbl,
        p_draft_id_tbl        => l_lines.draft_id_tbl
      );

      d_position := 40;

      -- check whether provided line_num is unique across interface,
      -- draft and txn tables
      PO_PDOI_MAINPROC_UTL_PVT.check_line_num_unique
      (
        p_po_header_id_tbl    => l_lines.hd_po_header_id_tbl,
        p_draft_id_tbl        => l_lines.draft_id_tbl,
        p_intf_line_id_tbl    => l_lines.intf_line_id_tbl,
        p_line_num_tbl        => l_lines.line_num_tbl,
        x_line_num_unique_tbl => l_lines.line_num_unique_tbl
      );

      d_position := 50;

      -- setup table to track rows that have not been processed
      PO_PDOI_UTL.generate_ordered_num_list
      (
        p_size      => l_lines.rec_count,
        x_num_list  => l_processing_row_tbl
      );

      -- inner loop to process line records in groups
      -- If same line is created and updated within the same batch,
      -- they must be processed in separate groups
      LOOP
        -- exit when all rows are processed
        IF (l_processing_row_tbl.COUNT = 0) THEN
          d_position := 60;

          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'exit after all lines are processed');
          END IF;

          EXIT;
        END IF;

        -- increment group number
        l_group_num := l_group_num + 1;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'group_num', l_group_num);
        END IF;

        -- perform uniqueness check on all the records and
        -- mark the group number on the records that can be processed
        -- within a group
        PO_PDOI_LINE_PROCESS_PVT.uniqueness_check
        (
          p_type                  => p_data_set_type,
          p_group_num             => l_group_num,
          x_processing_row_tbl    => l_processing_row_tbl,
          x_lines                 => l_lines,
          x_expire_line_id_tbl    => l_expire_line_id_tbl,
          x_expire_line_index_tbl => l_expire_line_index_tbl --bug19046588
        );

        d_position := 70;

        --Bug 18691247, initialize txn_flow_header_id_tbl before split lines
        l_lines.txn_flow_header_id_tbl := PO_TBL_NUMBER();
        l_lines.txn_flow_header_id_tbl.EXTEND(l_lines.rec_count);

        d_position := 71;

        -- separate data records into two set, one for create and one for update
        PO_PDOI_LINE_PROCESS_PVT.split_lines
        (
          p_group_num             => l_group_num,
          p_lines                 => l_lines,
          x_create_lines          => l_create_lines,
          x_update_lines          => l_update_lines,
	        x_match_lines           => l_match_lines
        );

        d_position := 80;

        -- process all rows that needs to be created
        process_create_lines_in_group
        (
          p_group_num             => l_group_num,
          p_expire_line_id_tbl    => l_expire_line_id_tbl,
          p_expire_line_index_tbl => l_expire_line_index_tbl, --bug19046588
          x_lines                 => l_create_lines
        );

        d_position := 90;

        -- process all the lines that need to be updated
        process_update_lines_in_group
        (
          p_group_num            => l_group_num,
          x_lines                => l_update_lines
        );
      END LOOP;

      PO_PDOI_UTL.commit_work;

      -- set the maximal interface_line_id processed in this batch
      l_max_intf_line_id := l_lines.intf_line_id_tbl(l_lines.rec_count);

      IF (l_lines.rec_count < PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE) THEN
        EXIT;
      END IF;
    EXCEPTION
      WHEN g_snap_shot_too_old THEN
        d_position := 100;

        -- log error
        PO_MESSAGE_S.add_exc_msg
        (
          p_pkg_name => d_pkg_name,
          p_procedure_name => d_api_name || '.' || d_position
        );

        -- commit changes
        PO_PDOI_UTL.commit_work;

        IF (l_lines_csr%ISOPEN) THEN
          CLOSE l_lines_csr;
          PO_PDOI_LINE_PROCESS_PVT.open_lines
          (
            p_data_set_type      => p_data_set_type,
            p_max_intf_line_id   => l_max_intf_line_id,
            x_lines_csr          => l_lines_csr
          );
        END IF;
    END;
  END LOOP;

  d_position := 110;

  -- close the cursor
  IF (l_lines_csr%ISOPEN) THEN
    CLOSE l_lines_csr;
  END IF;

  d_position := 120;

  -- reject lines that are price breaks if main po line failed
  SELECT v.interface_line_id
  BULK COLLECT INTO l_rej_intf_line_id_tbl
  FROM   po_lines_interface intf_line1,
         (SELECT intf_line2.interface_line_id, max(intf_line3.interface_line_id) AS match_intf_line_id
          FROM   po_lines_interface intf_line2, po_lines_interface intf_line3,
                 po_headers_interface intf_headers
          WHERE  intf_line2.interface_header_id = intf_headers.interface_header_id
          AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
          AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
          AND    intf_line2.price_break_flag = 'Y'
          AND    intf_line2.processing_id = PO_PDOI_PARAMS.g_processing_id
          AND    intf_line2.interface_header_id = intf_line3.interface_header_id
          AND    intf_line2.po_line_id = intf_line3.po_line_id
          AND    NVL(intf_line3.price_break_flag, 'N') = 'N'
          AND    intf_line3.interface_line_id < intf_line2.interface_line_id
          GROUP BY intf_line2.interface_line_id) v
  WHERE   intf_line1.interface_line_id = v.match_intf_line_id
  AND     NVL(intf_line1.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
            = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED;

  d_position := 130;

  PO_PDOI_UTL.reject_lines_intf
  (
    p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
    p_id_tbl          => l_rej_intf_line_id_tbl,
    p_cascade         => FND_API.g_TRUE
  );

  d_position := 140;

  -- set status to NOTIFIED for price break lines if main po line is NOTIFIED
  SELECT v.interface_line_id
  BULK COLLECT INTO l_notified_intf_line_id_tbl
  FROM   po_lines_interface intf_line1,
         (SELECT intf_line2.interface_line_id, max(intf_line3.interface_line_id) AS match_intf_line_id
          FROM   po_lines_interface intf_line2, po_lines_interface intf_line3,
                 po_headers_interface intf_headers
          WHERE  intf_line2.interface_header_id = intf_headers.interface_header_id
          AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
          AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
          AND    intf_line2.price_break_flag = 'Y'
          AND    intf_line2.processing_id = PO_PDOI_PARAMS.g_processing_id
          AND    intf_line2.interface_header_id = intf_line3.interface_header_id
          AND    intf_line2.po_line_id = intf_line3.po_line_id
          AND    NVL(intf_line3.price_break_flag, 'N') = 'N'
          AND    intf_line3.interface_line_id < intf_line2.interface_line_id
          GROUP BY intf_line2.interface_line_id) v
  WHERE   intf_line1.interface_line_id = v.match_intf_line_id
  AND     NVL(intf_line1.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
            = PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED;

  d_position := 150;

  FORALL i IN 1..l_notified_intf_line_id_tbl.COUNT
    UPDATE po_lines_interface
    SET    process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED
    WHERE  interface_line_id = l_notified_intf_line_id_tbl(i);

  d_position := 160;

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
END process_lines_sync;

-----------------------------------------------------------------------
--Start of Comments
--Name: process_create_lines_in_group
--Function: Data set 3 and 4 contains lines of mixed actions. After the
--          action is determined by uniqueness logic, lines with same
--          actions will be grouped together and processed separately
--          from lines with different actions.
--          This procedure is to deal with lines whose action is 'ADD'.
--Parameters:
--IN:
--  p_group_num
--    the current processing group number. Only lines belonging to
--    current group will be processed.
--  p_expire_line_id_tbl
--    The lines that need to be expired
--IN OUT:
--  x_lines
--    contains all lines within the batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_create_lines_in_group
(
  p_group_num          IN NUMBER,
  p_expire_line_id_tbl IN DBMS_SQL.NUMBER_TABLE,
  p_expire_line_index_tbl IN DBMS_SQL.NUMBER_TABLE, --bug19046588
  x_lines              IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_create_lines_in_group';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to track the records that need to be rejected due
  -- to errors in the processing
  l_count  NUMBER := 0;
  l_rej_intf_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_expire_line_count NUMBER := 1; --bug19046588

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_group_num', p_group_num);
    PO_LOG.proc_begin(d_module, 'count of lines', x_lines.rec_count);
  END IF;

  -- return if there is no line to be processed
  IF (x_lines.rec_count = 0) THEN
    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;
  END IF;

  -- derive logic
  PO_PDOI_LINE_PROCESS_PVT.derive_lines
  (
    x_lines    => x_lines
  );

  d_position := 10;

  -- default logic
  PO_PDOI_LINE_PROCESS_PVT.default_lines
  (
    x_lines    => x_lines
  );

  d_position := 20;

  -- validate lines
  PO_PDOI_LINE_PROCESS_PVT.validate_lines
  (
    x_lines    => x_lines
  );


  d_position := 30;

  -- check whether line location needs to be created for the line
  PO_PDOI_LINE_PROCESS_PVT.check_line_locations
  (
    x_lines    => x_lines
  );

  d_position := 40;

  -- create items if necessary
  IF (PO_PDOI_PARAMS.g_request.create_items = 'Y') THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'create items from line info');
    END IF;

    PO_PDOI_ITEM_PROCESS_PVT.create_items
    (
      x_lines         => x_lines
    );
  END IF;

  d_position := 50;

  -- insert lines into draft table
  PO_PDOI_MOVE_TO_DRAFT_TABS_PVT.insert_lines
  (
    x_lines    => x_lines
  );

  d_position := 60;

  -- update po_lines_interface with po_line_id and line level action
  PO_PDOI_LINE_PROCESS_PVT.update_line_intf_tbl
  (
    x_lines    => x_lines
  );

  d_position := 70;

  -- reject lines with errors
  l_rej_intf_line_id_tbl.EXTEND(x_lines.rec_count);
  FOR i IN 1..x_lines.rec_count
  LOOP
    IF (x_lines.error_flag_tbl(i) = FND_API.g_TRUE OR
        x_lines.need_to_reject_flag_tbl(i) = FND_API.g_TRUE) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'error flag',
                    x_lines.error_flag_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'reject flag',
                    x_lines.need_to_reject_flag_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'rejected intf line id',
                    x_lines.intf_line_id_tbl(i));
      END IF;

      l_count := l_count + 1;
      l_rej_intf_line_id_tbl(l_count) := x_lines.intf_line_id_tbl(i);

    --bug19046588 begin
      IF (p_expire_line_index_tbl.COUNT > 0) THEN  --bug19649688
        IF (p_expire_line_index_tbl(l_expire_line_count) = i) THEN
          l_expire_line_count := l_expire_line_count + 1;
        END IF;
      END IF;
    ELSIF (p_expire_line_index_tbl.COUNT > 0) THEN --bug19649688
      IF (p_expire_line_index_tbl(l_expire_line_count) = i) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'expired po_line_id', p_expire_line_id_tbl(l_expire_line_count));
        END IF;

        UPDATE po_lines_all
        SET expiration_date = TRUNC(sysdate - 1)
        WHERE po_line_id = p_expire_line_id_tbl(l_expire_line_count);
        l_expire_line_count := l_expire_line_count + 1;
      END IF;
    --bug19046588 end

    END IF;
  END LOOP;
  PO_PDOI_UTL.reject_lines_intf
  (
    p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
    p_id_tbl          => l_rej_intf_line_id_tbl,
    p_cascade         => FND_API.g_TRUE
  );
  l_rej_intf_line_id_tbl.DELETE;

  d_position := 80;

  -- expire blanket lines being replaced. They are replaced since it has
  -- release shipment and uom is changed in the new request

  --bug19046588 begin
  --FORALL i IN 1..p_expire_line_id_tbl.COUNT
  --UPDATE po_lines_all
  --SET expiration_date = TRUNC(sysdate - 1)
  --WHERE po_line_id = p_expire_line_id_tbl(i);
  --bug19046588 end

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
END process_create_lines_in_group;

-----------------------------------------------------------------------
--Start of Comments
--Name: process_update_lines_in_group
--Function: Data set 3 and 4 contains lines of mixed actions. After the
--          action is determined by uniqueness logic, lines with same
--          actions will be grouped together and processed separately
--          from lines with different actions.
--          This procedure is to deal with lines whose action is 'UPDATE'
--Parameters:
--  p_group_num
--    the current processing group number. Only lines belonging to
--    current group will be processed.
--IN OUT:
--  x_lines
--    contains all lines within the batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_update_lines_in_group
(
  p_group_num           IN NUMBER,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_update_lines_in_group';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to track the records that need to be rejected due
  -- to errors in the processing
  l_count  NUMBER := 0;
  l_rej_intf_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_group_num', p_group_num);
    PO_LOG.proc_begin(d_module, 'count of lines', x_lines.rec_count);
  END IF;

  -- return if there is no line to be processed
  IF (x_lines.rec_count = 0) THEN
    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;
  END IF;

  -- derive internal identifier for updatable attributes
  PO_PDOI_LINE_PROCESS_PVT.derive_lines_for_update
  (
    x_lines    => x_lines
  );

  -- default certain attributes for processing purpose
  PO_PDOI_LINE_PROCESS_PVT.default_lines_for_update
  (
    x_lines    => x_lines
  );

  -- validate lines
  PO_PDOI_LINE_PROCESS_PVT.validate_lines
  (
    p_action   => 'UPDATE',
    x_lines    => x_lines
  );

  d_position := 10;

  -- check whether line location needs to be created for the line
  PO_PDOI_LINE_PROCESS_PVT.check_line_locations
  (
    x_lines    => x_lines
  );

  d_position := 20;

  -- update lines on draft table
  PO_PDOI_MOVE_TO_DRAFT_TABS_PVT.update_lines
  (
    x_lines    => x_lines
  );

  d_position := 30;

  -- update po_lines_interface with po_line_id and line level action
  PO_PDOI_LINE_PROCESS_PVT.update_line_intf_tbl
  (
    x_lines    => x_lines
  );

  d_position := 40;

  -- set rejected status to lines and lower levels
  l_rej_intf_line_id_tbl.EXTEND(x_lines.rec_count);
  FOR i IN 1..x_lines.rec_count
  LOOP
    IF (x_lines.error_flag_tbl(i) = FND_API.g_TRUE OR
        x_lines.need_to_reject_flag_tbl(i) = FND_API.g_TRUE) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'error flag',
                    x_lines.error_flag_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'reject flag',
                    x_lines.need_to_reject_flag_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'rejected intf line id',
                    x_lines.intf_line_id_tbl(i));
      END IF;

      l_count := l_count + 1;
      l_rej_intf_line_id_tbl(l_count) := x_lines.intf_line_id_tbl(i);
    END IF;
  END LOOP;
  PO_PDOI_UTL.reject_lines_intf
  (
    p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
    p_id_tbl          => l_rej_intf_line_id_tbl,
    p_cascade         => FND_API.g_TRUE
  );
  l_rej_intf_line_id_tbl.DELETE;

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
END process_update_lines_in_group;

-------------------------------------------------------------------------
--Start of Comments
--Name: process_line_locations
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive, default, validate and insert records
--  from po_line_locations_interface table
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_line_locations IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_line_locations';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- cursor variable defined for the query
  l_line_locs_csr PO_PDOI_TYPES.intf_cursor_type;

  -- all line location attribute values within a batch
  l_line_locs PO_PDOI_TYPES.line_locs_rec_type;

  l_create_line_locs PO_PDOI_TYPES.line_locs_rec_type;
  l_update_line_locs PO_PDOI_TYPES.line_locs_rec_type;

  -- variables to track the records that need to be rejected due
  -- to errors in the processing
  l_rej_intf_line_loc_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

  -- keep record of line locs processed in this request
  -- the record will be used in post line location processing
  l_processed_line_id_tbl  DBMS_SQL.number_table;
  l_processed_draft_id_tbl    DBMS_SQL.number_table;

  -- maximal interface_line_location_id_processed
  l_max_intf_line_loc_id   NUMBER := -1;

  l_key po_session_gt.key%TYPE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- Bug 5215781:
  -- exit immediately if error threshold is hit for CATALOG UPLOAD
  IF (PO_PDOI_PARAMS.g_request.calling_module =
        PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD AND
      PO_PDOI_PARAMS.g_docs_info(PO_PDOI_PARAMS.g_request.interface_header_id)
        .err_tolerance_exceeded = FND_API.g_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Exit from process_line_locations since' ||
                  ' error threshold is hit for header ',
                  PO_PDOI_PARAMS.g_request.interface_header_id);
    END IF;

    RETURN;
  END IF;

  d_position := 5;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_PROCESS);


  -- <<PDOI Enhancement Bug#17063664 Start>>
  d_position := 7;

  -- bug 18707457
  -- bug 19479583 remove conditions to call setup_line_locs_intf, calling it for every document type
    -- Insert the default line_locations info into po_line_locations_interface
    --   if not provided and when line_loc_populated_flag is not 'Y'.
    PO_PDOI_LINE_LOC_PROCESS_PVT.setup_line_locs_intf;

  -- <<PDOI Enhancement Bug#17063664 End>>

  -- open cursor for the correct query
  PO_PDOI_LINE_LOC_PROCESS_PVT.open_line_locs
  (
    p_max_intf_line_loc_id   => l_max_intf_line_loc_id,
    x_line_locs_csr          => l_line_locs_csr
  );

  d_position := 10;

  l_key := PO_CORE_S.get_session_gt_nextval;

  -- fetch records from line location interface table and process the records
  LOOP
    -- Bug 5215781:
    -- check whether num of error lines exceeds the error
    -- threshold for the previous batch
    IF (PO_PDOI_PARAMS.g_request.calling_module =
          PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD AND
        PO_PDOI_PARAMS.g_docs_info(PO_PDOI_PARAMS.g_request.interface_header_id)
          .err_tolerance_exceeded = FND_API.g_TRUE) THEN
      d_position := 20;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'error tolerance exceeded for',
                    PO_PDOI_PARAMS.g_request.interface_header_id);
      END IF;

      EXIT;
    END IF;

    BEGIN
      -- fetch one batch of line location records from query result
      PO_PDOI_LINE_LOC_PROCESS_PVT.fetch_line_locs
      (
        x_line_locs_csr   => l_line_locs_csr,
        x_line_locs       => l_line_locs
      );

      d_position := 20;

      -- number of records read in current batch
      l_line_locs.rec_count := l_line_locs.intf_line_loc_id_tbl.COUNT;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'loc count in batch',
                    l_line_locs.rec_count);
      END IF;

      EXIT WHEN l_line_locs.rec_count = 0;

      -- set up hashtable between interface_line_location_id and index
      l_line_locs.intf_id_index_tbl.DELETE;

      FOR i IN 1..l_line_locs.rec_count
      LOOP
        l_line_locs.intf_id_index_tbl(l_line_locs.intf_line_loc_id_tbl(i)) := i;
      END LOOP;

      -- calculate max_shipment_num for each line in this batch
      -- the result is saved and used in line location processing
      PO_PDOI_MAINPROC_UTL_PVT.calculate_max_shipment_num
      (
        p_po_line_id_tbl     => l_line_locs.ln_po_line_id_tbl,
        p_draft_id_tbl       => l_line_locs.draft_id_tbl
      );

      d_position := 30;

       --PDOI Enhancement Bug#17063664 : Removed the call
       -- to check uniqueness on shipment number. This
       --is not required now as shipments having same
       -- shipment number will be grouped

      d_position := 40;

      -- <PDOI Enhancement Bug#17063664>
      -- Skipping the derivations during autocreate flow
      IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
        -- derive logic
        PO_PDOI_LINE_LOC_PROCESS_PVT.derive_line_locs
        (
          x_line_locs               => l_line_locs
        );
      END IF ;

      d_position := 50;

      -- default logic
      PO_PDOI_LINE_LOC_PROCESS_PVT.default_line_locs
      (
        x_line_locs               => l_line_locs
      );

      d_position := 60;

      -- process quantity uom conversions
      PO_PDOI_LINE_LOC_PROCESS_PVT.process_conversions
      (
        x_line_locs               => l_line_locs
      );

      d_position := 70;

     d_position := 80;

      -- default logic
      PO_PDOI_LINE_LOC_PROCESS_PVT.match_line_locs
      (
        x_line_locs            => l_line_locs,
        x_create_line_locs     => l_create_line_locs,
        x_update_line_locs     => l_update_line_locs
      );

      d_position := 90;

      process_create_line_locs
      (
       x_line_locs      => l_create_line_locs
      );

      d_position := 100;

      process_update_line_locs
      (
       x_line_locs       => l_update_line_locs
      );

      d_position := 110;

      --<Bug#19528138 Start>--
      --Inserting header details into po_session_gt
      -- table which will be used in update_po_price_on_line
      -- api.
      FORALL i IN 1..l_line_locs.rec_count
      INSERT INTO po_session_gt
      (key,
       index_char1,
       num1, --po_header_id
       num2, --vendor_id
       num3, --vendor_site_id
       num4, --org_id
       char1,--type_lookup_code
       char2,--currency_code
       char3,--global_agreement_flag
       num5,--rate
       char4,--rate_type
       date1,--rate_date
       char5,--enhanced_pricing_flag
       char6--progress_payment_flag
       )
       SELECT DISTINCT l_key,
       'PO_HEADER_DTLS',
       l_line_locs.hd_po_header_id_tbl(i),
       l_line_locs.hd_vendor_id_tbl(i),
       l_line_locs.hd_vendor_site_id_tbl(i),
       l_line_locs.hd_org_id_tbl(i),
       l_line_locs.hd_type_lookup_code_tbl(i),
       l_line_locs.hd_currency_code_tbl(i),
       l_line_locs.hd_global_agreement_flag_tbl(i),
       l_line_locs.hd_rate_tbl(i),
       l_line_locs.hd_rate_type_tbl(i),
       l_line_locs.hd_rate_date_tbl(i),
       NVL(pds.enhanced_pricing_flag,'N'),
       NVL(pds.progress_payment_flag,'N')
       FROM po_doc_style_headers pds
       WHERE l_line_locs.error_flag_tbl(i) = FND_API.G_FALSE
       AND pds.style_id=l_line_locs.hd_style_id_tbl(i);
   --<Bug#19528138 End>--


     IF (PO_LOG.d_stmt) THEN
       PO_LOG.proc_begin(d_module, 'Number of Header Rows Inserted into GT table', sql%ROWCOUNT);
     END IF;


      -- Insert quantity,amount,secondary quantity into
      -- session gt table later used to sum the values
      FORALL i IN 1..l_line_locs.rec_count
      INSERT INTO po_session_gt(
      key,        -- key
      index_num1, -- Line_location_id
      index_num2, -- po_line_id
      num1,       -- draft_id
      num2,       -- quantity
      num3,       -- amount
      num4,       -- secondary_quantity
      num5,       -- ship_to_location_id
      num6,       -- ship_to_org_id
      num7,       -- shipment_num
      num8,       -- po_header_id
      date1,      -- need_by_date
      char1,      -- action
      char2,      -- payment_type -- Bug 17772630 Taking payment_type and shipment_type
      char3,       -- shipment_type
      char4       -- Line_loc_populated_flag  --Bug19528138
      )
      SELECT l_key,
             l_line_locs.line_loc_id_tbl(i),
             l_line_locs.ln_po_line_id_tbl(i),
             l_line_locs.draft_id_tbl(i),
             l_line_locs.quantity_tbl(i),
             l_line_locs.amount_tbl(i),
             l_line_locs.secondary_quantity_tbl(i),
             l_line_locs.ship_to_loc_id_tbl(i),
             l_line_locs.ship_to_org_id_tbl(i),
             l_line_locs.shipment_num_tbl(i),
             l_line_locs.hd_po_header_id_tbl(i),
             l_line_locs.need_by_date_tbl(i),
             l_line_locs.action_tbl(i),
	     l_line_locs.payment_type_tbl(i),
	     l_line_locs.shipment_type_tbl(i),
	     l_line_locs.ln_line_loc_pop_flag_tbl(i)--Bug19528138
      FROM  DUAL
      WHERE l_line_locs.error_flag_tbl(i) = FND_API.G_FALSE;


     IF (PO_LOG.d_stmt) THEN
       PO_LOG.proc_begin(d_module, 'Number of Rows Inserted into GT table', sql%ROWCOUNT);
     END IF;

      -- commit
      PO_PDOI_UTL.commit_work;

      IF (l_line_locs.rec_count < PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE) THEN
        EXIT;
      END IF;

      l_max_intf_line_loc_id := l_line_locs.intf_line_loc_id_tbl(l_line_locs.rec_count);
    EXCEPTION
      WHEN g_snap_shot_too_old THEN
        d_position := 110;

        -- log error
        PO_MESSAGE_S.add_exc_msg
        (
          p_pkg_name => d_pkg_name,
          p_procedure_name => d_api_name || '.' || d_position
        );

        -- commit changes
        PO_PDOI_UTL.commit_work;

        IF (l_line_locs_csr%ISOPEN) THEN
          CLOSE l_line_locs_csr;
          PO_PDOI_LINE_LOC_PROCESS_PVT.open_line_locs
          (
            p_max_intf_line_loc_id   => l_max_intf_line_loc_id,
            x_line_locs_csr          => l_line_locs_csr
          );
        END IF;
    END;
  END LOOP;

  d_position := 120;

  -- close the cursor
  IF (l_line_locs_csr%ISOPEN) THEN
    CLOSE l_line_locs_csr;
  END IF;

  SELECT DISTINCT index_num2, --po_line_id
                  num1-- draft_id
  BULK COLLECT INTO l_processed_line_id_tbl ,l_processed_draft_id_tbl
  FROM po_session_gt
  WHERE KEY = l_key
  AND index_char1 IS NULL ;--19528138

  -- line location post processing
  IF (PO_PDOI_PARAMS.g_request.document_type IN (PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD,
                                                 PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET)) THEN
    d_position := 130;

        -- Insert line locations from base table
        -- to consider values from transaction table
        -- for po lines which are being updated

        FORALL i IN 1..l_processed_line_id_tbl.COUNT
        INSERT INTO po_session_gt(
        key,        -- key
        index_num1, -- Line_location_id
        index_num2, -- po_line_id
        num1,       -- draft_id
        num2,       -- quantity
        num3,       -- amount
        num4,       -- secondary_quantity
        num5,       -- ship_to_location_id
        num6,       -- ship_to_org_id
        num7,       -- shipment_num
        num8,       -- po_header_id
        date1,      -- need_by_date
        char1,      -- action
	char2,      -- payment_type -- Bug 17772630 Taking payment_type and shipment_type
	char3,       -- Shipment_type
	char4       -- line_loc_populated_flag
        )
        SELECT l_key,
               line_location_id,
               po_line_id,
               l_processed_draft_id_tbl(i),
               quantity,
               amount,
               secondary_quantity,
               ship_to_location_id,
               ship_to_organization_id,
               shipment_num,
               po_header_id,
               need_by_date,
               'ADD',  -- action
	       payment_type,
	       shipment_type,
	       'S'  -- interface data is  matched to existing shipment only when flag is 'S'
        FROM po_line_locations_all
        WHERE po_line_id = l_processed_line_id_tbl(i);

      IF PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD THEN
          -- update amount or quantity value on po_lines_draft_all
          -- po_line_locations_draft_all
          PO_PDOI_LINE_LOC_PROCESS_PVT.update_amount_quantity
          (
            p_key                =>  l_key
          );
      END IF;

      --<PDOI Enhancement Bug#17063664>
      -- From sourcing and Consumption advice flow, price is already updated.
      -- So no need to call update_price_on_line.
      IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                      PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN

            -- Update Price on Line
            PO_PDOI_LINE_LOC_PROCESS_PVT.update_price_on_line
            (
              p_key                =>  l_key
            );
      END IF;

  ELSIF (PO_PDOI_PARAMS.g_request.document_type =
         PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN
    d_position := 140;

    -- delete all existing price breaks for quotation update
    PO_PDOI_LINE_LOC_PROCESS_PVT.delete_exist_price_breaks
    (
      p_po_line_id_tbl      => l_processed_line_id_tbl,
      p_draft_id_tbl        => l_processed_draft_id_tbl
    );
  ELSE -- document_type = blanket
    d_position := 150;

    -- In previous implementation, price discount is updated based
    -- on price and price break. The logic is removed in R12.
    NULL;
  END IF;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_LOC_PROCESS);

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
END process_line_locations;

-------------------------------------------------------------------------
--Start of Comments
--Name: process_distributions
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to derive, default, validate and insert records
--  from po_distributions_interface table
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_distributions IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_distributions';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- record to hold distribution values read within a batch
  l_dists            PO_PDOI_TYPES.distributions_rec_type;

  -- cursor variable to point to currently processing row
  l_dists_csr         PO_PDOI_TYPES.intf_cursor_type;

  -- variables to track the records that need to be rejected due
  -- to errors in the processing
  l_rej_intf_dist_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

  -- maximal interface_line_location_id_processed
  l_max_intf_dist_id   NUMBER := -1;

  --<<PDOI Enhancment Bug#17063664 START>>
  l_processed_line_loc_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_processed_draft_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_line_loc_ref_tbl       DBMS_SQL.NUMBER_TABLE;
  l_count NUMBER := 0;
  --<<PDOI Enhancment Bug#17063664 END>>

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_DIST_PROCESS);

  -- <<PDOI Enhancement Bug#17063664 Start>>
  d_position := 5;

  IF PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD THEN

    -- Insert the default distributions info into po_distributions_interface
    --   if not provided and when backing req exists.
    PO_PDOI_DIST_PROCESS_PVT.setup_dists_intf;
  END IF;

  -- <<PDOI Enhancement Bug#17063664 End>>

  -- open cursor for the correct query
  PO_PDOI_DIST_PROCESS_PVT.open_dists
  (
    p_max_intf_dist_id   => l_max_intf_dist_id,
    x_dists_csr          => l_dists_csr
  );

  d_position := 10;

  -- fetch records from distribution interface table and process the records
  LOOP
    BEGIN
      -- fetch one batch of distribution records from query result
      PO_PDOI_DIST_PROCESS_PVT.fetch_dists
      (
        x_dists_csr   => l_dists_csr,
        x_dists       => l_dists
      );

      d_position := 20;

      -- number of records read in current batch
      l_dists.rec_count := l_dists.intf_dist_id_tbl.COUNT;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'dist count in batch',
                    l_dists.rec_count);
      END IF;

      EXIT WHEN l_dists.rec_count = 0;

      -- calculate max distribution num for each line location
      -- in this batch
      -- the result is saved and used in distribution processing
      PO_PDOI_MAINPROC_UTL_PVT.calculate_max_dist_num
      (
        p_line_loc_id_tbl     => l_dists.loc_line_loc_id_tbl,
        p_draft_id_tbl        => l_dists.draft_id_tbl
      );

      d_position := 30;

      -- check whether the distribution num is unique per line location
      PO_PDOI_MAINPROC_UTL_PVT.check_dist_num_unique
      (
        p_line_loc_id_tbl     => l_dists.loc_line_loc_id_tbl,
        p_draft_id_tbl        => l_dists.draft_id_tbl,
        p_intf_dist_id_tbl    => l_dists.intf_dist_id_tbl,
        p_dist_num_tbl        => l_dists.dist_num_tbl,
        x_dist_num_unique_tbl => l_dists.dist_num_unique_tbl
      );

      d_position := 40;

      -- <PDOI Enhancement Bug#17063664>
      -- Skipping the derivations during autocreate flow
      IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                 PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                 PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
        -- derive logic
        PO_PDOI_DIST_PROCESS_PVT.derive_dists
        (
          x_dists               => l_dists
        );
      END IF;
      d_position := 50;

      -- default logic
      PO_PDOI_DIST_PROCESS_PVT.default_dists
      (
        x_dists               => l_dists
      );

      d_position := 60;

      -- <PDOI Enhancement Bug#17063664>
      -- Skipping validations if called from autocreate flow
      IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                        PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                        PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
          -- validate logic
          PO_PDOI_DIST_PROCESS_PVT.validate_dists
          (
            x_dists               => l_dists
          );
      END IF;

      d_position := 70;

      -- <PDOI Enhancement Bug#17063664 Start>
      -- Calling API to process currency conversions when not calling
      --  from sourcing or consumption advice
      IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING ,
                    PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN

        PO_PDOI_DIST_PROCESS_PVT.process_currency_conversions
        (
          x_dists               => l_dists
        );

       END IF;
       -- <PDOI Enhancement Bug#17063664 End>

      -- insert distributions into draft table
      PO_PDOI_MOVE_TO_DRAFT_TABS_PVT.insert_dists
      (
        p_dists               => l_dists
      );

      d_position := 80;

      -- set rejected status to distributions
      FOR i IN 1..l_dists.rec_count
      LOOP
       --<<PDOI Enhancement Bug#17063664 START>>
        IF (NOT l_line_loc_ref_tbl.EXISTS(l_dists.loc_line_loc_id_tbl(i)) AND
		    l_dists.error_flag_tbl(i) = FND_API.g_FALSE) THEN

          l_count := l_count + 1;
          l_processed_line_loc_id_tbl.EXTEND;
          l_processed_draft_id_tbl.EXTEND;

	  l_processed_line_loc_id_tbl(l_count) := l_dists.loc_line_loc_id_tbl(i);
	  l_processed_draft_id_tbl(l_count) := l_dists.draft_id_tbl(i);
	  l_line_loc_ref_tbl(l_dists.loc_line_loc_id_tbl(i)) := i;

        END IF;
       --<<PDOI Enhancement Bug#17063664 END>>

        IF (l_dists.error_flag_tbl(i) = FND_API.G_TRUE) THEN
          l_rej_intf_dist_id_tbl.EXTEND;
          l_rej_intf_dist_id_tbl(l_rej_intf_dist_id_tbl.COUNT) := l_dists.intf_dist_id_tbl(i);
        END IF;
      END LOOP;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'to-be-rejected dists',
                    l_rej_intf_dist_id_tbl);
      END IF;

      d_position := 90;

      PO_PDOI_UTL.reject_distributions_intf
      (
        p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_DISTRIBUTION_ID,
        p_id_tbl          => l_rej_intf_dist_id_tbl
      );
      l_rej_intf_dist_id_tbl.DELETE;

      d_position := 100;

      -- set status to ACCEPTED for records without errors on intf table
      FORALL i IN 1..l_dists.intf_dist_id_tbl.COUNT
      UPDATE po_distributions_interface
      SET    process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_ACCEPTED
      WHERE  interface_distribution_id = l_dists.intf_dist_id_tbl(i)
      AND    l_dists.error_flag_tbl(i) = FND_API.g_FALSE;

      d_position := 110;

      PO_PDOI_UTL.commit_work;

      IF (l_dists.rec_count < PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE) THEN
        EXIT;
      END IF;

      l_max_intf_dist_id := l_dists.intf_dist_id_tbl(l_dists.rec_count);
    EXCEPTION
      WHEN g_snap_shot_too_old THEN
        d_position := 120;

        -- log error
        PO_MESSAGE_S.add_exc_msg
        (
          p_pkg_name => d_pkg_name,
          p_procedure_name => d_api_name || '.' || d_position
        );

        -- commit changes
        PO_PDOI_UTL.commit_work;

        IF (l_dists_csr%ISOPEN) THEN
          CLOSE l_dists_csr;
          PO_PDOI_DIST_PROCESS_PVT.open_dists
          (
            p_max_intf_dist_id   => l_max_intf_dist_id,
            x_dists_csr          => l_dists_csr
          );
        END IF;
    END;
  END LOOP;

  d_position := 130;

  --<<PDOI Enhancement Bug#17063664>>
  -- Calling api to calibrate the last
  PO_PDOI_DIST_PROCESS_PVT.process_qty_amt_rollups
   (
     p_line_loc_id_tbl   => l_processed_line_loc_id_tbl,
     p_draft_id_tbl      => l_processed_draft_id_tbl
   );

  d_position := 140;

  -- close the cursor
  IF (l_dists_csr%ISOPEN) THEN
    CLOSE l_dists_csr;
  END IF;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_DIST_PROCESS);

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
END process_distributions;

-------------------------------------------------------------------------
--Start of Comments
--Name: process_price_diffs
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to validate and insert records
--  from po_price_diffs_interface table
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_price_diffs IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_price_diffs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- record to hold price differential values read within a batch
  l_price_diffs            PO_PDOI_TYPES.price_diffs_rec_type;

  -- cursor variable to point to currently processing row
  l_price_diffs_csr        PO_PDOI_TYPES.intf_cursor_type;

  -- variables to track the records that need to be rejected due
  -- to errors in the processing
  l_rej_intf_price_diff_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

  -- maximal interface_price_diff_id_processed
  l_max_intf_price_diff_id   NUMBER := -1;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- Bug 5215781:
  -- exit immediately if error threshold is hit for CATALOG UPLOAD
  IF (PO_PDOI_PARAMS.g_request.calling_module =
        PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD AND
      PO_PDOI_PARAMS.g_docs_info(PO_PDOI_PARAMS.g_request.interface_header_id)
        .err_tolerance_exceeded = FND_API.g_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Exit from process_price_diffs since' ||
                  ' error threshold is hit for header ',
                  PO_PDOI_PARAMS.g_request.interface_header_id);
    END IF;

    RETURN;
  END IF;

  d_position := 5;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_PRICE_DIFF_PROCESS);

  -- <<PDOI Enhancement Bug#17063664 Start>>
  d_position := 10;

  -- Insert the default po_price_differentials info into
  -- po_price_diff_interface if not provided.
  PO_PDOI_PRICE_DIFF_PROCESS_PVT.setup_price_diffs_intf;

  -- <<PDOI Enhancement Bug#17063664 End>>

  -- open cursor for the correct query
  PO_PDOI_PRICE_DIFF_PROCESS_PVT.open_price_diffs
  (
    p_max_intf_price_diff_id   => l_max_intf_price_diff_id,
    x_price_diffs_csr          => l_price_diffs_csr
  );

  d_position := 20;

  -- fetch records from price differential interface table and process the records
  LOOP
    -- Bug 5215781:
    -- check whether num of error lines exceeds the error
    -- threshold for the previous batch
    IF (PO_PDOI_PARAMS.g_request.calling_module =
          PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD AND
        PO_PDOI_PARAMS.g_docs_info(PO_PDOI_PARAMS.g_request.interface_header_id)
          .err_tolerance_exceeded = FND_API.g_TRUE) THEN
      d_position := 30;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'error tolerance exceeded for',
                    PO_PDOI_PARAMS.g_request.interface_header_id);
      END IF;

      EXIT;
    END IF;

    BEGIN
      -- fetch one batch of records from query result
      PO_PDOI_PRICE_DIFF_PROCESS_PVT.fetch_price_diffs
      (
        x_price_diffs_csr   => l_price_diffs_csr,
        x_price_diffs       => l_price_diffs
      );

      d_position := 40;

      -- number of records read in current batch
      l_price_diffs.rec_count := l_price_diffs.intf_price_diff_id_tbl.COUNT;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'price diffs in batch',
                    l_price_diffs.rec_count);
      END IF;

      EXIT WHEN l_price_diffs.rec_count = 0;

      PO_PDOI_PRICE_DIFF_PROCESS_PVT.default_price_diffs
      (
        x_price_diffs         => l_price_diffs
      );

      d_position := 50;

      -- <PDOI Enhancement Bug#17063664>
      -- Skipping validations if called from autocreate flow
      IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                        PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                        PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
          -- validate logic
          PO_PDOI_PRICE_DIFF_PROCESS_PVT.validate_price_diffs
          (
            x_price_diffs         => l_price_diffs
          );
      END IF;

      d_position := 60;

      -- insert into draft table
      PO_PDOI_MOVE_TO_DRAFT_TABS_PVT.insert_price_diffs
      (
        p_price_diffs         => l_price_diffs
      );

      d_position := 70;

      -- set rejected status
      FOR i IN 1..l_price_diffs.rec_count
      LOOP
        IF (l_price_diffs.error_flag_tbl(i) = FND_API.G_TRUE) THEN
          l_rej_intf_price_diff_id_tbl.EXTEND;
          l_rej_intf_price_diff_id_tbl(l_rej_intf_price_diff_id_tbl.COUNT) := l_price_diffs.intf_price_diff_id_tbl(i);
        END IF;
      END LOOP;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'to-be-rejected price diffs',
                    l_rej_intf_price_diff_id_tbl);
      END IF;

      PO_PDOI_UTL.reject_price_diff_intf
      (
        p_id_param_type   => PO_PDOI_CONSTANTS.g_PRICE_DIFF_INTERFACE_ID,
        p_id_tbl          => l_rej_intf_price_diff_id_tbl
      );
      l_rej_intf_price_diff_id_tbl.DELETE;

      d_position := 80;

      -- set status to ACCEPTED for records without errors on intf table
      FORALL i IN 1..l_price_diffs.intf_price_diff_id_tbl.COUNT
      UPDATE po_price_diff_interface
      SET    process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_ACCEPTED
      WHERE  price_diff_interface_id = l_price_diffs.intf_price_diff_id_tbl(i)
      AND    l_price_diffs.error_flag_tbl(i) = FND_API.g_FALSE;

      PO_PDOI_UTL.commit_work;

      IF (l_price_diffs.rec_count < PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE) THEN
        EXIT;
      END IF;

      l_max_intf_price_diff_id := l_price_diffs.intf_price_diff_id_tbl(l_price_diffs.rec_count);
    EXCEPTION
      WHEN g_snap_shot_too_old THEN
        d_position := 90;

        -- log error
        PO_MESSAGE_S.add_exc_msg
        (
          p_pkg_name => d_pkg_name,
          p_procedure_name => d_api_name || '.' || d_position
        );

        -- commit changes
        PO_PDOI_UTL.commit_work;

        IF (l_price_diffs_csr%ISOPEN) THEN
          CLOSE l_price_diffs_csr;
          PO_PDOI_PRICE_DIFF_PROCESS_PVT.open_price_diffs
          (
            p_max_intf_price_diff_id   => l_max_intf_price_diff_id,
            x_price_diffs_csr          => l_price_diffs_csr
          );
        END IF;
    END;
  END LOOP;

  d_position := 100;

  -- close the cursor
  IF (l_price_diffs_csr%ISOPEN) THEN
    CLOSE l_price_diffs_csr;
  END IF;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_PRICE_DIFF_PROCESS);

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
END process_price_diffs;

-------------------------------------------------------------------------
--Start of Comments
--Name: process_attributes
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to validate and insert records
--  from po_attr_values_interface table and
--  po_attr_values_tlp_interface table
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_attributes IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_attributes';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- Bug 5215781:
  -- exit immediately if error threshold is hit for CATALOG UPLOAD
  IF (PO_PDOI_PARAMS.g_request.calling_module =
        PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD AND
      PO_PDOI_PARAMS.g_docs_info(PO_PDOI_PARAMS.g_request.interface_header_id)
        .err_tolerance_exceeded = FND_API.g_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Exit from process_attributes since' ||
                  ' error threshold is hit for header ',
                  PO_PDOI_PARAMS.g_request.interface_header_id);
    END IF;

    RETURN;
  END IF;

  d_position := 10;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_ATTR_PROCESS);

  -- process all lines in po_attr_values_interface table
  process_attr_values;

  d_position := 20;

  -- process all lines in po_attr_values_tlp_interface table
  process_attr_values_tlp;

  d_position := 30;

  -- add default attr_values and attr_values_tlp if not provided
  PO_PDOI_ATTR_PROCESS_PVT.add_default_attrs;

  d_position := 40;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_ATTR_PROCESS);

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
END process_attributes;

-------------------------------------------------------------------------
--Start of Comments
--Name: process_attr_values
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  process records in po_attr_values_interface table;
--  currently, there is only validation logic, no
--  derivation and defaulting logic
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_attr_values IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_attr_values';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- record to hold attribute values read within a batch
  l_attr_values            PO_PDOI_TYPES.attr_values_rec_type;

  -- cursor variable to point to currently processing row
  l_attr_values_csr        PO_PDOI_TYPES.intf_cursor_type;

  -- pl/sql table to track rows that needs to be created or updated
  l_merge_row_tbl          DBMS_SQL.NUMBER_TABLE;

  -- pl/sql table to track rows that need to be synced from txn
  -- table to draft table
  l_sync_attr_id_tbl       PO_TBL_NUMBER;
  l_sync_draft_id_tbl      PO_TBL_NUMBER;

  -- maximal interface_attr_values_id_processed
  l_max_intf_attr_values_id     NUMBER := -1;

  -- index for the loop
  l_index NUMBER;

  l_processing_row_tbl          DBMS_SQL.NUMBER_TABLE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- open cursor for query to retrieve attr value records
  PO_PDOI_ATTR_PROCESS_PVT.open_attr_values
  (
    p_max_intf_attr_values_id   => l_max_intf_attr_values_id,
    x_attr_values_csr           => l_attr_values_csr
  );

  d_position := 10;

  -- fetch records from attr values interface table and process the records
  LOOP
    BEGIN
      -- fetch one batch of records from query result
      PO_PDOI_ATTR_PROCESS_PVT.fetch_attr_values
      (
        x_attr_values_csr   => l_attr_values_csr,
        x_attr_values       => l_attr_values
      );

      d_position := 20;

      -- number of records read in current batch
      l_attr_values.rec_count := l_attr_values.intf_attr_values_id_tbl.COUNT;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'attr values in batch',
                    l_attr_values.rec_count);
      END IF;

      EXIT WHEN l_attr_values.rec_count = 0;

      -- process each record to determine the action;
      -- if multiple records are pointing to same
      -- po_line_id, the record will be processed
      -- in different groups

      -- first setup table to track rows that have not been processed
      PO_PDOI_UTL.generate_ordered_num_list
      (
        p_size      => l_attr_values.rec_count,
        x_num_list  => l_processing_row_tbl
      );

      -- second, process records in groups
      LOOP
        d_position := 30;

        -- exit when all rows are processed
        IF (l_processing_row_tbl.COUNT = 0) THEN
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'exit after all rows are processed');
          END IF;

          EXIT;
        END IF;

        -- determine the action for each attr value record
        PO_PDOI_ATTR_PROCESS_PVT.check_attr_actions
        (
          x_processing_row_tbl => l_processing_row_tbl,
          x_attr_values        => l_attr_values,
          x_merge_row_tbl      => l_merge_row_tbl,
          x_sync_attr_id_tbl   => l_sync_attr_id_tbl,
          x_sync_draft_id_tbl  => l_sync_draft_id_tbl
        );

        d_position := 40;

        -- insert records into draft table
        PO_PDOI_MOVE_TO_DRAFT_TABS_PVT.merge_attr_values
        (
          p_processing_row_tbl => l_merge_row_tbl,
          p_sync_attr_id_tbl   => l_sync_attr_id_tbl,
          p_sync_draft_id_tbl  => l_sync_draft_id_tbl,
          p_attr_values        => l_attr_values
        );
      END LOOP;

      d_position := 50;

      -- set status to ACCEPTED for all records
      FORALL i IN 1..l_attr_values.intf_attr_values_id_tbl.COUNT
      UPDATE po_attr_values_interface
      SET    process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_ACCEPTED
      WHERE  interface_attr_values_id = l_attr_values.intf_attr_values_id_tbl(i)
      AND    l_attr_values.error_flag_tbl(i) = FND_API.g_FALSE;


    --Bug13343886
		if PO_PDOI_CONSTANTS.g_GATHER_STATS = 'Y' THEN
				d_position := 55;
			gather_stats('PO_ATTRIBUTE_VALUES_DRAFT',d_api_name,d_position);
		END IF;
		--Bug13343886
      PO_PDOI_UTL.commit_work;

      IF (l_attr_values.rec_count < PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE) THEN
        EXIT;
      END IF;

      l_max_intf_attr_values_id := l_attr_values.intf_attr_values_id_tbl(l_attr_values.rec_count);
    EXCEPTION
      WHEN g_snap_shot_too_old THEN
        d_position := 60;

        -- log error
        PO_MESSAGE_S.add_exc_msg
        (
          p_pkg_name => d_pkg_name,
          p_procedure_name => d_api_name || '.' || d_position
        );

        -- commit changes
        PO_PDOI_UTL.commit_work;

        IF (l_attr_values_csr%ISOPEN) THEN
          CLOSE l_attr_values_csr;
          PO_PDOI_ATTR_PROCESS_PVT.open_attr_values
          (
            p_max_intf_attr_values_id   => l_max_intf_attr_values_id,
            x_attr_values_csr           => l_attr_values_csr
          );
        END IF;
    END;
  END LOOP;

  d_position := 70;

  -- close the cursor
  IF (l_attr_values_csr%ISOPEN) THEN
    CLOSE l_attr_values_csr;
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
END process_attr_values;

-------------------------------------------------------------------------
--Start of Comments
--Name: process_attr_values_tlp
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic on records from po_attr_values_tlp_interface table
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_attr_values_tlp IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_attr_values_tlp';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- record to hold attribute tlp values read within a batch
  l_attr_values_tlp            PO_PDOI_TYPES.attr_values_tlp_rec_type;

  -- cursor variable to point to currently processing row
  l_attr_values_tlp_csr        PO_PDOI_TYPES.intf_cursor_type;

  -- pl/sql table to track rows that needs to be created or updated
  l_merge_row_tbl          DBMS_SQL.NUMBER_TABLE;

  -- pl/sql table to track rows that need to be synced from txn
  -- table to draft table
  l_sync_attr_tlp_id_tbl   PO_TBL_NUMBER;
  l_sync_draft_id_tbl      PO_TBL_NUMBER;

  -- maximal interface_attr_values_tlp_id_processed
  l_max_intf_attr_values_tlp_id   NUMBER := -1;

  l_processing_row_tbl            DBMS_SQL.NUMBER_TABLE;
  l_index                         NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- open cursor for query to retrieve attr value records
  PO_PDOI_ATTR_PROCESS_PVT.open_attr_values_tlp
  (
    p_max_intf_attr_values_tlp_id   => l_max_intf_attr_values_tlp_id,
    x_attr_values_tlp_csr           => l_attr_values_tlp_csr
  );

  d_position := 10;

  -- fetch records from attr values tlp interface table and process the records
  LOOP
    BEGIN
      -- fetch one batch of records from query result
      PO_PDOI_ATTR_PROCESS_PVT.fetch_attr_values_tlp
      (
        x_attr_values_tlp_csr   => l_attr_values_tlp_csr,
        x_attr_values_tlp       => l_attr_values_tlp
      );

      d_position := 20;

      -- number of records read in current batch
      l_attr_values_tlp.rec_count := l_attr_values_tlp.intf_attr_values_tlp_id_tbl.COUNT;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'attr values tlp in batch',
                    l_attr_values_tlp.rec_count);
      END IF;

      EXIT WHEN l_attr_values_tlp.rec_count = 0;

      -- process each record to determine the action;
      -- if multiple records are pointing to same
      -- po_line_id and language, the record will be processed
      -- in different groups

      -- first setup table to track rows that have not been processed
      PO_PDOI_UTL.generate_ordered_num_list
      (
        p_size      => l_attr_values_tlp.rec_count,
        x_num_list  => l_processing_row_tbl
      );

      -- second, process records in groups
      LOOP
        d_position := 20;

        -- exit when all rows are processed
        IF (l_processing_row_tbl.COUNT = 0) THEN
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'exit after all rows are processed');
          END IF;

          EXIT;
        END IF;

        -- determine the action for each attr value tlp record
        PO_PDOI_ATTR_PROCESS_PVT.check_attr_tlp_actions
        (
          x_processing_row_tbl     => l_processing_row_tbl,
          x_attr_values_tlp        => l_attr_values_tlp,
          x_merge_row_tbl          => l_merge_row_tbl,
          x_sync_attr_tlp_id_tbl   => l_sync_attr_tlp_id_tbl,
          x_sync_draft_id_tbl      => l_sync_draft_id_tbl
        );

        d_position := 30;

        -- merge records into draft table
        PO_PDOI_MOVE_TO_DRAFT_TABS_PVT.merge_attr_values_tlp
        (
          p_processing_row_tbl     => l_merge_row_tbl,
          p_sync_attr_tlp_id_tbl   => l_sync_attr_tlp_id_tbl,
          p_sync_draft_id_tbl      => l_sync_draft_id_tbl,
          p_attr_values_tlp        => l_attr_values_tlp
        );
      END LOOP;

      d_position := 40;

      -- set status to ACCEPTED for all records
      FORALL i IN 1..l_attr_values_tlp.intf_attr_values_tlp_id_tbl.COUNT
      UPDATE po_attr_values_tlp_interface
      SET    process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_ACCEPTED
      WHERE  interface_attr_values_tlp_id = l_attr_values_tlp.intf_attr_values_tlp_id_tbl(i)
      AND    l_attr_values_tlp.error_flag_tbl(i) = FND_API.g_FALSE;


    --Bug13343886
		if PO_PDOI_CONSTANTS.g_GATHER_STATS = 'Y' THEN
			d_position := 45;
			gather_stats('PO_ATTRIBUTE_VALUES_TLP_DRAFT',d_api_name,d_position);
		END IF;
		--Bug13343886

      PO_PDOI_UTL.commit_work;

      IF (l_attr_values_tlp.rec_count < PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE) THEN
        EXIT;
      END IF;

      l_max_intf_attr_values_tlp_id := l_attr_values_tlp.intf_attr_values_tlp_id_tbl(l_attr_values_tlp.rec_count);
    EXCEPTION
      WHEN g_snap_shot_too_old THEN
        d_position := 50;

        -- log error
        PO_MESSAGE_S.add_exc_msg
        (
          p_pkg_name => d_pkg_name,
          p_procedure_name => d_api_name || '.' || d_position
        );

        -- commit changes
        PO_PDOI_UTL.commit_work;

        IF (l_attr_values_tlp_csr%ISOPEN) THEN
          CLOSE l_attr_values_tlp_csr;
          PO_PDOI_ATTR_PROCESS_PVT.open_attr_values_tlp
          (
            p_max_intf_attr_values_tlp_id   => l_max_intf_attr_values_tlp_id,
            x_attr_values_tlp_csr           => l_attr_values_tlp_csr
          );
        END IF;
    END;
  END LOOP;

  d_position := 60;

  -- close the cursor
  IF (l_attr_values_tlp_csr%ISOPEN) THEN
    CLOSE l_attr_values_tlp_csr;
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
END process_attr_values_tlp;
--<<PDOI Enhancement bug#17063664 START>>--
-------------------------------------------------------------------------
--Start of Comments
--Name: process_create_lines
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to process lines to be created
--Parameters:
--IN: None
--IN OUT:
-- x_lines
--  record containing lines to be created
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_create_lines
(x_lines     IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
)
IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_create_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to track the records that need to be rejected due
  -- to errors in the processing
  l_rej_intf_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();


 BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

    -- <PDOI Enhancement Bug#17063664>
    -- Skipping validations if called from autocreate flow
    IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                      PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                      PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
      -- bug5129752
      -- After doing match line action, l_lines may become empty (this is the
      -- case if all the lines can be matched to lines in the draft table
      -- validate create lines
      PO_PDOI_LINE_PROCESS_PVT.validate_lines
       (
        x_lines               => x_lines
       );
     ELSE
       PO_PDOI_LINE_PROCESS_PVT.handle_err_tolerance
        (
          x_lines => x_lines
        );
   END IF;

  d_position := 10;

  -- create items if necessary
  IF (PO_PDOI_PARAMS.g_request.create_items = 'Y') THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'create items for lines');
    END IF;

   PO_PDOI_ITEM_PROCESS_PVT.create_items
     (
      x_lines               => x_lines
     );
   END IF;

   d_position := 20;

   -- insert lines into line draft table
   PO_PDOI_MOVE_TO_DRAFT_TABS_PVT.insert_lines
   (
     x_lines              => x_lines
    );

   d_position := 30;

   -- update po_lines_interface with po_line_id and line level action
   PO_PDOI_LINE_PROCESS_PVT.update_line_intf_tbl
    (
     x_lines               => x_lines
    );


   -- reject lines with errors
   FOR i IN 1..x_lines.rec_count
   LOOP
     IF (x_lines.error_flag_tbl(i) = FND_API.g_TRUE OR
         x_lines.need_to_reject_flag_tbl(i) = FND_API.g_TRUE) THEN
       IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'error flag',
                     x_lines.error_flag_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'reject flag',
                     x_lines.need_to_reject_flag_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'rejected intf line id',
                     x_lines.intf_line_id_tbl(i));
      END IF;

      l_rej_intf_line_id_tbl.EXTEND;
      l_rej_intf_line_id_tbl(l_rej_intf_line_id_tbl.COUNT) := x_lines.intf_line_id_tbl(i);
    END IF;
  END LOOP;

  d_position := 40;


  PO_PDOI_UTL.reject_lines_intf
   (
    p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
    p_id_tbl          => l_rej_intf_line_id_tbl,
    p_cascade         => FND_API.g_TRUE
  );
 l_rej_intf_line_id_tbl.DELETE;



  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
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
END process_create_lines;
-------------------------------------------------------------------------
--Start of Comments
--Name: process_update_lines
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to process lines to be update
--Parameters:
--IN: None
--IN OUT:
-- x_lines
--  record containing lines to be updated
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_update_lines
( x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
)
IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_update_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to track the records that need to be rejected due
  -- to errors in the processing
  l_rej_intf_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

  -- table to save distinct po_line_ids within the batch
  l_po_line_id_tbl            PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_draft_id_tbl              PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_delete_flag_tbl           PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
  l_record_already_exist_tbl  PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();


 BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF x_lines.rec_count = 0 THEN
    RETURN;
  END IF;

  -- <PDOI Enhancement Bug#17063664>
  -- Skipping validations if called from autocreate flow
  IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
       PO_PDOI_LINE_PROCESS_PVT.validate_lines
       (
        p_action              => 'UPDATE',
        x_lines               => x_lines
       );
  ELSE
        PO_PDOI_LINE_PROCESS_PVT.handle_err_tolerance
        (
          x_lines => x_lines
        );

  END IF;

  FOR i IN 1..x_lines.rec_count
  LOOP

    IF x_lines.error_flag_tbl(i) = FND_API.g_FALSE THEN
      l_po_line_id_tbl.EXTEND;
      l_draft_id_tbl.EXTEND;
      l_delete_flag_tbl.EXTEND;
      l_po_line_id_tbl(i):= x_lines.po_line_id_tbl(i);
      l_draft_id_tbl(i) := x_lines.draft_id_tbl(i);
      l_delete_flag_tbl(i) := 'N';
    END IF;
  END LOOP;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'po line ids', l_po_line_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'draft ids', l_draft_id_tbl);
  END IF;

   d_position := 10;

   -- read from txn table to draft table; if there is already a draft change
   -- in the draft table, the line won't be read
  PO_LINES_DRAFT_PKG.sync_draft_from_txn
  (
    p_po_line_id_tbl           => l_po_line_id_tbl,
    p_draft_id_tbl             => l_draft_id_tbl,
    p_delete_flag_tbl          => l_delete_flag_tbl,
    x_record_already_exist_tbl => l_record_already_exist_tbl
  );

  -- update po_lines_interface with po_line_id and line level action
  PO_PDOI_LINE_PROCESS_PVT.update_line_intf_tbl
  (
    x_lines               => x_lines
   );

   -- reject lines with errors
  FOR i IN 1..x_lines.rec_count
  LOOP
    IF (x_lines.error_flag_tbl(i) = FND_API.g_TRUE OR
       x_lines.need_to_reject_flag_tbl(i) = FND_API.g_TRUE) THEN

       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module, d_position, 'error flag',
                      x_lines.error_flag_tbl(i));
         PO_LOG.stmt(d_module, d_position, 'reject flag',
                     x_lines.need_to_reject_flag_tbl(i));
         PO_LOG.stmt(d_module, d_position, 'rejected intf line id',
                      x_lines.intf_line_id_tbl(i));
       END IF;

       l_rej_intf_line_id_tbl.EXTEND;
       l_rej_intf_line_id_tbl(l_rej_intf_line_id_tbl.COUNT) := x_lines.intf_line_id_tbl(i);
     END IF;
   END LOOP;

   d_position := 40;

   PO_PDOI_UTL.reject_lines_intf
   (
    p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
    p_id_tbl          => l_rej_intf_line_id_tbl,
    p_cascade         => FND_API.g_TRUE
   );
   l_rej_intf_line_id_tbl.DELETE;

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
END process_update_lines;

-------------------------------------------------------------------------
--Start of Comments
--Name: process_match_lines
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to process lines that are matched.
--Parameters:
--IN: None
--IN OUT:
-- x_lines
--  record containing lines to be updated
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_match_lines
( x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
)
IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_match_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

 BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
       PO_PDOI_LINE_PROCESS_PVT.validate_lines
       (
        p_action              => 'MATCH',
        x_lines               => x_lines
       );
  ELSE
        PO_PDOI_LINE_PROCESS_PVT.handle_err_tolerance
        (
          x_lines => x_lines
        );

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
END process_match_lines;


-------------------------------------------------------------------------
--Start of Comments
--Name: process_create_line_locs
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to process line locations to be created
--Parameters:
--IN: None
--IN OUT:
-- x_line_locs
--  record containing line locations to be created
-- x_processed_line_id_tbl
--  Table of processed lines
-- x_processed_draft_id_tbl
-- Table of draft ids for processed lines
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_create_line_locs
(  x_line_locs      IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_create_line_locs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to track the records that need to be rejected due
  -- to errors in the processing
  l_rej_intf_line_loc_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

 BEGIN
   d_position := 0;

   IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_begin(d_module);
   END IF;

   d_position := 10;
  -- <PDOI Enhancement Bug#17063664>
  -- Skipping validations if called from autocreate flow
   IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
       -- validate logic
       PO_PDOI_LINE_LOC_PROCESS_PVT.validate_line_locs
       (
         x_line_locs               => x_line_locs
       );
   END IF;

   d_position := 20;

   -- insert line locations into line location draft table
   PO_PDOI_MOVE_TO_DRAFT_TABS_PVT.insert_line_locs
   (
     p_line_locs              => x_line_locs
   );

   d_position := 30;

    -- update po_line_locations_interface with line_location_id
   PO_PDOI_LINE_LOC_PROCESS_PVT.update_line_loc_interface
   (
     p_intf_line_loc_id_tbl   => x_line_locs.intf_line_loc_id_tbl,
     p_line_loc_id_tbl        => x_line_locs.line_loc_id_tbl,
     p_action_tbl             => x_line_locs.action_tbl,
     p_error_flag_tbl         => x_line_locs.error_flag_tbl
    );

    d_position := 40;

    -- set rejected status to line locations and lower levels
    FOR i IN 1..x_line_locs.rec_count
    LOOP
      IF (x_line_locs.error_flag_tbl(i) = FND_API.G_TRUE) THEN
        l_rej_intf_line_loc_id_tbl.EXTEND;
        l_rej_intf_line_loc_id_tbl(l_rej_intf_line_loc_id_tbl.COUNT) := x_line_locs.intf_line_loc_id_tbl(i);
      END IF;
    END LOOP;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'to-be-rejected locs',
                  l_rej_intf_line_loc_id_tbl);
    END IF;

    PO_PDOI_UTL.reject_line_locations_intf
    (
      p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_LOCATION_ID,
      p_id_tbl          => l_rej_intf_line_loc_id_tbl,
      p_cascade         => FND_API.g_TRUE
     );
    l_rej_intf_line_loc_id_tbl.DELETE;

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
END process_create_line_locs;

-------------------------------------------------------------------------
--Start of Comments
--Name: process_update_line_locs
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  handle the logic to process line locations to be updated
--Parameters:
--IN: None
--IN OUT :
-- x_line_locs
--  record containing line locations to be created
-- x_processed_line_id_tbl
--  Table of processed lines
-- x_processed_draft_id_tbl
-- Table of draft ids for processed lines
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process_update_line_locs
(  x_line_locs              IN OUT NOCOPY PO_PDOI_TYPES.line_locs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'process_update_line_locs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to track the records that need to be rejected due
  -- to errors in the processing
  l_rej_intf_line_loc_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

    -- table to save distinct po_line_ids within the batch
  l_line_location_id_tbl      PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_draft_id_tbl              PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_delete_flag_tbl           PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
  l_record_already_exist_tbl  PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

 BEGIN
   d_position := 0;

   IF (PO_LOG.d_proc) THEN
     PO_LOG.proc_begin(d_module);
   END IF;

   IF x_line_locs.rec_count = 0 THEN
     RETURN;
   END IF ;

   d_position := 10;

   FOR i IN 1..x_line_locs.rec_count
   LOOP

      IF x_line_locs.error_flag_tbl(i) = FND_API.g_FALSE THEN

	l_line_location_id_tbl.EXTEND;
        l_draft_id_tbl.EXTEND;
        l_delete_flag_tbl.EXTEND;
        l_line_location_id_tbl(i):= x_line_locs.line_loc_id_tbl(i);
	l_draft_id_tbl(i) := x_line_locs.draft_id_tbl(i);
        l_delete_flag_tbl(i) := 'N';
     END IF;
   END LOOP;

   IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'po line location ids', l_line_location_id_tbl);
      PO_LOG.stmt(d_module, d_position, 'draft ids', l_draft_id_tbl);
   END IF;

   d_position := 20;

    -- read from txn table to draft table; if there is already a draft change
    -- in the draft table, the line location won't be read
  PO_LINE_LOCATIONS_DRAFT_PKG.sync_draft_from_txn
   (
    p_line_location_id_tbl      => l_line_location_id_tbl,
    p_draft_id_tbl                => l_draft_id_tbl,
    p_delete_flag_tbl             => l_delete_flag_tbl,
    x_record_already_exist_tbl    => l_record_already_exist_tbl
   );

    d_position := 30;

     -- update po_line_locations_interface with line_location_id
   PO_PDOI_LINE_LOC_PROCESS_PVT.update_line_loc_interface
   (
     p_intf_line_loc_id_tbl   => x_line_locs.intf_line_loc_id_tbl,
     p_line_loc_id_tbl        => x_line_locs.line_loc_id_tbl,
     p_action_tbl             => x_line_locs.action_tbl,
     p_error_flag_tbl         => x_line_locs.error_flag_tbl
    );

    d_position := 40;

    -- set rejected status to line locations and lower levels
   FOR i IN 1..x_line_locs.rec_count
   LOOP
     IF (x_line_locs.error_flag_tbl(i) = FND_API.G_TRUE) THEN
       l_rej_intf_line_loc_id_tbl.EXTEND;
       l_rej_intf_line_loc_id_tbl(l_rej_intf_line_loc_id_tbl.COUNT) := x_line_locs.intf_line_loc_id_tbl(i);
     END IF;
   END LOOP;

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'to-be-rejected locs',
                  l_rej_intf_line_loc_id_tbl);
   END IF;

   PO_PDOI_UTL.reject_line_locations_intf
   (
     p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_LOCATION_ID,
     p_id_tbl          => l_rej_intf_line_loc_id_tbl,
     p_cascade         => FND_API.g_TRUE
    );
   l_rej_intf_line_loc_id_tbl.DELETE;


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
END process_update_line_locs;
--<<PDOI Enhancement bug#17063664 END>>--
--Bug 13343886
PROCEDURE gather_stats(p_table_name IN VARCHAR2,p_api_name IN VARCHAR2,p_position IN VARCHAR2)
IS
l_status     VARCHAR2(1);
l_industry   VARCHAR2(1);
l_schema     VARCHAR2(30);
l_return_status BOOLEAN;
	BEGIN
			  l_return_status := FND_INSTALLATION.get_app_info('PO', l_status,
			                                                   l_industry, l_schema);
			  IF (l_return_status) THEN
			    FND_STATS.gather_table_stats ( ownname => l_schema, tabname => p_table_name);
			  END IF;
			EXCEPTION
			  WHEN OTHERS THEN
			    PO_MESSAGE_S.add_exc_msg
			      ( p_pkg_name => d_pkg_name,
			        p_procedure_name => p_api_name || '.' || p_position
			      );
			  RAISE;
	END GATHER_STATS;
	--Bug 13343886

END PO_PDOI_MAINPROC_PVT;

/
