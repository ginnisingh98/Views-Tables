--------------------------------------------------------
--  DDL for Package Body PO_PDOI_PREPROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_PREPROC_PVT" AS
/* $Header: PO_PDOI_PREPROC_PVT.plb 120.24.12010000.7 2013/12/04 16:54:56 srpantha ship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_PDOI_PREPROC_PVT');

-------------------------------------------------------
----------- PRIVATE PROCEDURES PROTOTYPE --------------
-------------------------------------------------------
PROCEDURE update_dependent_line_acc_flag; -- bug5149827

PROCEDURE assign_processing_id;

PROCEDURE get_processable_records
( x_intf_header_id_tbl IN OUT NOCOPY PO_TBL_NUMBER,
  p_process_code_tbl   IN PO_TBL_VARCHAR30,
  p_request_id_tbl     IN PO_TBL_NUMBER
);

PROCEDURE validate_interface_values;

PROCEDURE derive_vendor_id;

PROCEDURE verify_action_replace;

PROCEDURE verify_action_update;

PROCEDURE verify_action_original;

PROCEDURE assign_po_header_id;

PROCEDURE check_release_dates
( p_interface_header_id IN NUMBER,
  p_po_header_id        IN NUMBER,
  p_ga_flag             IN VARCHAR2,
  p_new_doc_start_date  IN DATE,
  x_valid               IN OUT NOCOPY VARCHAR2
);

-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: process
--Function:
--  Main procedure of PRE-PROCESSING in PDOI
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE process IS

d_api_name CONSTANT VARCHAR2(30) := 'process';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  PO_TIMING_UTL.start_time (PO_PDOI_CONSTANTS.g_T_PREPROCESSING);

  IF (PO_PDOI_PARAMS.g_request.document_type <>
        PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD
      AND
      PO_PDOI_PARAMS.g_request.process_code =
        PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED) THEN

    update_dependent_line_acc_flag;  -- bug5149827 - Renamed the procedure
  END IF;

  d_position := 10;
  assign_processing_id;

  d_position := 20;
  validate_interface_values;

  d_position := 30;

  --Derivation is not required if being called from autocreate code
  IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE) THEN
      derive_vendor_id;  -- have to prepopulate vendor info because catalog
                         -- existence check needs this
  END IF;

  -- For update and replace action, make sure that the document exists
  -- For ORIGINAL action, make sure that there should not be another document
  -- in the system with the same document identifiers (e.g. segment1,
  -- vendor_doc_num, etc.)

  d_position := 40;
  verify_action_replace;

  d_position := 50;
  verify_action_update;

  d_position := 60;
  verify_action_original;

  -- <<PDOI Enhancement Bug#17063664 Start>>
  -- Moving the logic to insert line locations and distribution interface at
  -- respective entity level
  -- d_position := 70;
  -- populate_line_loc_interface;
  -- <<PDOI Enhancement Bug#17063664 End>>

  d_position := 80;
  -- For documents that will get created, assign po_header_id
  assign_po_header_id;

  d_position := 90;
  PO_INTERFACE_ERRORS_UTL.flush_errors_tbl;

  d_position := 100;
  PO_PDOI_UTL.commit_work;

  PO_TIMING_UTL.stop_time (PO_PDOI_CONSTANTS.g_T_PREPROCESSING);

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

-- bug5149827
-- Renamed the procedure

-----------------------------------------------------------------------
--Start of Comments
--Name: update_dependent_line_acc_flag
--Function:
--  1. Update price break acceptance flag according to the acceptance status
--  of the parent line
--  2. Update lines that have parent interface lne id according to the
--  acceptance status of the parent line
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_dependent_line_acc_flag IS

d_api_name CONSTANT VARCHAR2(30) := 'update_dependent_line_acc_flag';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_intf_line_id_tbl PO_TBL_NUMBER;
l_price_chg_accept_flag_tbl PO_TBL_VARCHAR1;
l_price_break_flag_tbl PO_TBL_VARCHAR1;

l_current_flag VARCHAR2(1);

l_update_flag_value_idx_tbl PO_PDOI_UTL.pls_integer_tbl_type :=
                            PO_PDOI_UTL.pls_integer_tbl_type();

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (PO_PDOI_PARAMS.g_request.interface_header_id IS NOT NULL) THEN

    -- (1) Update price break acceptance flag according to the acceptance
		--     status of the parent line

    SELECT interface_line_id,
           price_chg_accept_flag,
           price_break_flag
    BULK COLLECT
    INTO l_intf_line_id_tbl,
         l_price_chg_accept_flag_tbl,
         l_price_break_flag_tbl
    FROM po_lines_interface
    WHERE interface_header_id = PO_PDOI_PARAMS.g_request.interface_header_id
    AND   NVL(process_code, PO_PDOI_CONSTANTS.g_process_code_PENDING) =
            PO_PDOI_CONSTANTS.g_process_code_NOTIFIED
    ORDER BY po_line_id, interface_line_id;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'number of lines with notified status ',
                  l_intf_line_id_tbl.COUNT);
    END IF;

    d_position := 10;

    FOR i IN 1..l_intf_line_id_tbl.COUNT LOOP
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position,  'i = ' || i || ', intf_line_id = ' ||
                    l_intf_line_id_tbl(i) || ' change accept flag = ' ||
                    l_price_chg_accept_flag_tbl(i));
      END IF;

      IF (NVL(l_price_break_flag_tbl(i), 'N') = 'N') THEN
        -- regular po line
        l_current_flag := l_price_chg_accept_flag_tbl(i);
      ELSE
        -- price break. Need to update
        l_price_chg_accept_flag_tbl(i) := l_current_flag;
        l_update_flag_value_idx_tbl.extend;
        l_update_flag_value_idx_tbl(l_update_flag_value_idx_tbl.COUNT) := i;
      END IF;
    END LOOP;

    d_position := 20;

    -- update price change accept flag for price break lines
    IF (l_update_flag_value_idx_tbl.COUNT > 0) THEN
      FORALL i IN VALUES OF l_update_flag_value_idx_tbl
        UPDATE po_lines_interface
        SET price_chg_accept_flag = l_price_chg_accept_flag_tbl(i)
        WHERE interface_line_id = l_intf_line_id_tbl(i);
    END IF;

    d_position := 30;

    --  (2) Update lines that have parent interface lne id according to the
    --      acceptance status of the parent line

    -- bug5149827
    -- Set the acceptance status of the child record to be the same as
    -- the parent
    UPDATE po_lines_interface lines
    SET    lines.price_chg_accept_flag =
             ( SELECT parent_lines.price_chg_accept_flag
               FROM   po_lines_interface parent_lines
               WHERE  lines.parent_interface_line_id =
                        parent_lines.interface_line_id )
    WHERE  lines.interface_header_id = PO_PDOI_PARAMS.g_request.interface_header_id
    AND  NVL(lines.process_code, PO_PDOI_CONSTANTS.g_process_code_PENDING) =
            PO_PDOI_CONSTANTS.g_process_code_NOTIFIED
    AND  lines.parent_interface_line_id IS NOT NULL;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, '# of lines updated based on parent_intf_line_id',
                  SQL%ROWCOUNT);
    END IF;

    d_position := 40;

    -- Reject all records that have not been accepted
    UPDATE po_lines_interface
    SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED
    WHERE interface_header_id = PO_PDOI_PARAMS.g_request.interface_header_id
    AND   process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED
    AND   price_chg_accept_flag = 'N';

    d_position := 30;
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
END update_dependent_line_acc_flag;

-- determine what records PDOI needs to process in this run and
-- assign all those records with a processing_id

-----------------------------------------------------------------------
--Start of Comments
--Name: assign_processing_id
--Function:
--  Assign an internally tracking processing id to identify all the records that
--  will be processed in this current PDOI run
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE assign_processing_id IS

d_api_name CONSTANT VARCHAR2(30) := 'assign_processing_id';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;


CURSOR c_interface_headers IS
SELECT PHI.interface_header_id,
       PHI.process_code,
       PHI.request_id
FROM po_headers_interface PHI
WHERE PHI.org_id = PO_PDOI_PARAMS.g_request.org_id
AND   NVL(PHI.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING) <>
        PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED
AND   (PHI.batch_id = PO_PDOI_PARAMS.g_request.batch_id
       OR
       PO_PDOI_PARAMS.g_request.batch_id IS NULL)
AND   (PHI.process_code = PO_PDOI_PARAMS.g_request.process_code
       OR
       ( NVL(PO_PDOI_PARAMS.g_request.process_code,
             PO_PDOI_CONSTANTS.g_process_code_PENDING) <>
           PO_PDOI_CONSTANTS.g_process_code_NOTIFIED
         AND
         PHI.process_code = PO_PDOI_CONSTANTS.g_process_code_IN_PROCESS)
       OR
       PHI.process_code IS NULL)
AND   (PHI.interface_header_id = PO_PDOI_PARAMS.g_request.interface_header_id
       OR
       PO_PDOI_PARAMS.g_request.interface_header_id IS NULL)
AND   (PHI.document_type_code = PO_PDOI_PARAMS.g_request.document_type
       OR
       PHI.document_type_code IS NULL)
AND   (PHI.processing_id IS NULL
       OR
       PHI.processing_id <> PO_PDOI_PARAMS.g_processing_id)
-- bug5471513
-- Catalog uploaded records should only be processed by catalog upload
-- request
-- bug5463188
-- Buyer acceptance process shouldn't worry about the calling module
AND   ( PO_PDOI_PARAMS.g_request.process_code =
          PO_PDOI_CONSTANTS.g_process_code_NOTIFIED
        OR
        DECODE (PHI.interface_source_code,
                PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD,
                1, 2) =
        DECODE (PO_PDOI_PARAMS.g_request.calling_module,
                PO_PDOI_CONSTANTS.g_CALL_MOD_CATALOG_UPLOAD,
                1, 2));


l_intf_header_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
l_process_code_tbl PO_TBL_VARCHAR30 := PO_TBL_VARCHAR30();
l_request_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

l_intf_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- <MOAC R12 START>
  -- ECO 4420269
  -- If batch id is specified, update the records that match the batch id but
  -- do not have org_id specified.
  IF (PO_PDOI_PARAMS.g_request.batch_id IS NOT NULL) THEN

    UPDATE po_headers_interface PHI
    SET    PHI.org_id = PO_PDOI_PARAMS.g_request.org_id
    WHERE  PHI.batch_id = PO_PDOI_PARAMS.g_request.batch_id
    AND    PHI.org_id IS NULL;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position,  'updatec org id for ' ||
                  SQL%ROWCOUNT || ' records.');
    END IF;
  END IF;

  d_position := 10;
  OPEN c_interface_headers;

  LOOP
    d_position := 20;
    FETCH c_interface_headers
    BULK COLLECT
    INTO l_intf_header_id_tbl,
         l_process_code_tbl,
         l_request_id_tbl
    LIMIT PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE;

    EXIT WHEN l_intf_header_id_tbl.COUNT = 0;

    -- Filter the list further more to only return records that are
    -- truly process-able
    get_processable_records
    ( x_intf_header_id_tbl => l_intf_header_id_tbl,
      p_process_code_tbl   => l_process_code_tbl,
      p_request_id_tbl     => l_request_id_tbl
    );

    d_position := 30;
    -- Header level assignment
    FORALL i IN 1..l_intf_header_id_tbl.COUNT
      UPDATE po_headers_interface
      SET processing_id = PO_PDOI_PARAMS.g_processing_id,
          process_code = PO_PDOI_CONSTANTS.g_process_code_IN_PROCESS,
          processing_round_num = NULL,  -- reset processing number
          request_id = FND_GLOBAL.conc_request_id,
          approval_status = NVL(approval_status,
                                PO_PDOI_PARAMS.g_request.approved_status)
      WHERE interface_header_id = l_intf_header_id_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position,  'after header assignment. Updated ' ||
                  SQL%ROWCOUNT || ' records');
    END IF;

    d_position := 40;
    -- Line level assignment
    FORALL i IN 1..l_intf_header_id_tbl.COUNT
      UPDATE po_lines_interface
      SET processing_id = PO_PDOI_PARAMS.g_processing_id,
          action = DECODE (action,
                           PO_PDOI_CONSTANTS.g_action_ADD, action,
                           NULL), -- null out process code unless it is force add
          process_code = DECODE (PO_PDOI_PARAMS.g_request.process_code,
                                 PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED,
                                 PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING,
                                 process_code) -- bug5149827
      WHERE interface_header_id = l_intf_header_id_tbl(i)
      AND   (PO_PDOI_PARAMS.g_request.process_code = process_code
             OR
             ( NVL(PO_PDOI_PARAMS.g_request.process_code,
                   PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING) <>
                 PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED AND
               NVL(process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
                 IN (PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING,
                     PO_PDOI_CONSTANTS.g_PROCESS_CODE_VAL_AND_REJECT)))
      AND   (NVL(process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
              IN (PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING,
                  PO_PDOI_CONSTANTS.g_PROCESS_CODE_VAL_AND_REJECT)
             OR
             (process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED AND
              NVL(price_chg_accept_flag, 'N') = 'Y'))
     RETURNING interface_line_id
     BULK COLLECT INTO l_intf_line_id_tbl;


    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position,  'after line assignment. Updated ' ||
                  SQL%ROWCOUNT || ' records');
    END IF;

    d_position := 50;
    FORALL i IN 1..l_intf_line_id_tbl.COUNT
      UPDATE po_line_locations_interface
      SET processing_id = PO_PDOI_PARAMS.g_processing_id
      WHERE interface_line_id = l_intf_line_id_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'after line location assignment. ' ||
                  ' Updated ' || SQL%ROWCOUNT || ' records');
    END IF;

    d_position := 60;
    FORALL i IN 1..l_intf_line_id_tbl.COUNT
      UPDATE po_price_diff_interface
      SET processing_id = PO_PDOI_PARAMS.g_processing_id
      WHERE interface_line_id = l_intf_line_id_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position,  'after price diff assignment. ' ||
                  'Updated ' || SQL%ROWCOUNT || ' records');
    END IF;

    d_position := 70;
    IF (PO_PDOI_PARAMS.g_request.document_type =
        PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
      FORALL i IN 1..l_intf_line_id_tbl.COUNT
        UPDATE po_distributions_interface
        SET processing_id = PO_PDOI_PARAMS.g_processing_id
        WHERE interface_line_id = l_intf_line_id_tbl(i);

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position,  'after distirbution assignment. ' ||
                    'Updated ' || SQL%ROWCOUNT || ' records');
      END IF;
    END IF;

    d_position := 80;
    IF (PO_PDOI_PARAMS.g_request.document_type <>
        PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN

      d_position := 90;
      FORALL i IN 1..l_intf_line_id_tbl.COUNT
        UPDATE po_attr_values_interface
        SET processing_id = PO_PDOI_PARAMS.g_processing_id
        WHERE interface_line_id = l_intf_line_id_tbl(i);

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'after attr value assignment. ' ||
                    'Updated ' || SQL%ROWCOUNT || ' records');
      END IF;

      d_position := 100;
      FORALL i IN 1..l_intf_line_id_tbl.COUNT
        UPDATE po_attr_values_tlp_interface
        SET processing_id = PO_PDOI_PARAMS.g_processing_id
        WHERE interface_line_id = l_intf_line_id_tbl(i);

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'after attr values tlp assignment.' ||
                    ' Updated ' || SQL%ROWCOUNT || ' records');
      END IF;
    END IF;

    d_position := 110;

  END LOOP;

  CLOSE c_interface_headers;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF (c_interface_headers%ISOPEN) THEN
    CLOSE c_interface_headers;
  END IF;

  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END assign_processing_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_processable_records
--Function:
--  Verify that the records are processable by current PDOI run. Records
--  that meet the filtering criteria may be unable to be processed if
--  there is another PDOI process working on the same interface record.
--Parameters:
--IN:
--p_process_code_tbl
--  table of process codes
--p_request_id_tbl
--  table of request ids that have processed / are processing the records
--IN OUT:
--x_intf_header_id_tbl
--  interface records to be evaluated
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_processable_records
( x_intf_header_id_tbl IN OUT NOCOPY PO_TBL_NUMBER,
  p_process_code_tbl IN PO_TBL_VARCHAR30,
  p_request_id_tbl IN PO_TBL_NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'get_processable_records';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_tmp_intf_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

l_old_request_complete VARCHAR2(1);

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, '# of records to eval', x_intf_header_id_tbl.COUNT);
  END IF;

  FOR i IN 1..x_intf_header_id_tbl.COUNT LOOP
    d_position := 10;

    IF (p_process_code_tbl(i) = PO_PDOI_CONSTANTS.g_process_code_IN_PROCESS) THEN

      l_old_request_complete := PO_PDOI_UTL.is_old_request_complete
                                ( p_old_request_id => p_request_id_tbl(i)
                                );

      d_position := 20;

      IF (l_old_request_complete = FND_API.G_TRUE) THEN
        l_tmp_intf_tbl.EXTEND;
        l_tmp_intf_tbl(l_tmp_intf_tbl.COUNT) := x_intf_header_id_tbl(i);
      END IF;

    ELSE
      d_position := 30;

      l_tmp_intf_tbl.EXTEND;
      l_tmp_intf_tbl(l_tmp_intf_tbl.COUNT) := x_intf_header_id_tbl(i);
    END IF;
  END LOOP;

  -- return the list with records that are still being processed filtered.
  x_intf_header_id_tbl := l_tmp_intf_tbl;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module, '# of processable rec', x_intf_header_id_tbl.COUNT);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END get_processable_records;

-- Check some of the general columns in the interface tables
-- and make sure that they follow the rules of PDOI
-----------------------------------------------------------------------
--Start of Comments
--Name: validate_interface_values
--Function:
--  Validate interface values that are required for PDOI to process the records
--  properly (e.g. ACTION column)
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE validate_interface_values IS

d_api_name CONSTANT VARCHAR2(30) := 'validate_interface_values';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_reject_tbl PO_TBL_NUMBER;
l_action_tbl PO_TBL_VARCHAR25;

l_message_name FND_NEW_MESSAGES.message_name%TYPE;
BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- Check action code
  SELECT interface_header_id, action
  BULK COLLECT
  INTO l_reject_tbl, l_action_tbl
  FROM po_headers_interface
  WHERE processing_id = PO_PDOI_PARAMS.g_processing_id
  AND  (action IS NULL
       OR
        (PO_PDOI_PARAMS.g_request.document_type IN
          (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
           PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) AND
         action NOT IN (PO_PDOI_CONSTANTS.g_ACTION_ORIGINAL,
                        PO_PDOI_CONSTANTS.g_ACTION_ADD,
                        PO_PDOI_CONSTANTS.g_ACTION_REPLACE,
                        PO_PDOI_CONSTANTS.g_ACTION_UPDATE))
       -- Bug#17864040: Adding condition for CONTRACT with actions allowed ORIGINAL and ADD
       OR
        (PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT AND
         action NOT IN (PO_PDOI_CONSTANTS.g_ACTION_ORIGINAL,
                        PO_PDOI_CONSTANTS.g_ACTION_ADD))
       OR
        (PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD AND
         action NOT IN (PO_PDOI_CONSTANTS.g_ACTION_ORIGINAL,
                        PO_PDOI_CONSTANTS.g_ACTION_ADD,
                        PO_PDOI_CONSTANTS.g_ACTION_UPDATE)));

  d_position := 10;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, '# of records to reject:',
                l_reject_tbl.COUNT);
  END IF;

  FOR i IN 1..l_reject_tbl.COUNT LOOP
    IF (PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD
        AND
        l_action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_REPLACE) THEN

      l_message_name := 'PO_PDOI_STD_ACTION';
    ELSE
      l_message_name := 'PO_PDOI_INVALID_ACTION';
    END IF;

    d_position := 20;
    PO_PDOI_ERR_UTL.add_fatal_error
    ( p_interface_header_id => l_reject_tbl(i),
      p_error_message_name  => l_message_name,
      p_table_name          => 'PO_HEADERS_INTERFACE',
      p_column_name         => 'ACTION',
      p_column_value        => l_action_tbl(i),
      p_token1_name         => 'VALUE',
      p_token1_value        => l_action_tbl(i));
  END LOOP;

  d_position := 30;
  PO_PDOI_UTL.reject_headers_intf
  ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID,
    p_id_tbl        => l_reject_tbl,
    p_cascade       => FND_API.G_TRUE);

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
END validate_interface_values;


-----------------------------------------------------------------------
--Start of Comments
--Name: derive_vendor_id
--Function:
--  Derive vendor id based on vendor name and vendor num, if necessary.
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_vendor_id IS

d_api_name CONSTANT VARCHAR2(30) := 'derive_vendor_id';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_key NUMBER;

l_intf_header_id_tbl PO_TBL_NUMBER;
l_vendor_name_tbl PO_TBL_VARCHAR2000;
l_vendor_num_tbl PO_TBL_VARCHAR30;
l_vendor_id_tbl PO_TBL_NUMBER;

l_reject_list PO_TBL_NUMBER := PO_TBL_NUMBER();

l_column_name VARCHAR2(30);
l_token_value VARCHAR2(200);

l_ordered_num_list DBMS_SQL.NUMBER_TABLE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  l_key := PO_CORE_S.get_session_gt_nextval;

  SELECT interface_header_id,
         vendor_name,
         vendor_num,
         vendor_id
  BULK COLLECT
  INTO l_intf_header_id_tbl,
       l_vendor_name_tbl,
       l_vendor_num_tbl,
       l_vendor_id_tbl
  FROM po_headers_interface PHI
  WHERE vendor_id IS NULL
  AND   po_header_id IS NULL      -- if po_header_id is already provided,
                                  -- skip vendor_id derivation as it is
                                  -- not needed
  AND processing_id = PO_PDOI_PARAMS.g_processing_id;

  d_position := 10;

  PO_PDOI_UTL.generate_ordered_num_list
  ( p_size => l_intf_header_id_tbl.COUNT,
    x_num_list => l_ordered_num_list
  );

  PO_PDOI_HEADER_PROCESS_PVT.derive_vendor_id
  ( p_key => l_key,
    p_index_tbl => l_ordered_num_list,
    p_vendor_name_tbl => l_vendor_name_tbl,
    p_vendor_num_tbl => l_vendor_num_tbl,
    x_vendor_id_tbl => l_vendor_id_tbl
  );

  d_position := 20;
  -- Update vendor_id to headers interface
  FORALL i IN 1..l_intf_header_id_tbl.COUNT
    UPDATE po_headers_interface
    SET vendor_id = l_vendor_id_tbl(i)
    WHERE interface_header_id = l_intf_header_id_tbl(i)
    AND l_vendor_id_tbl(i) IS NOT NULL;

  d_position := 30;
  FOR i IN 1..l_intf_header_id_tbl.COUNT LOOP
    IF (l_vendor_id_tbl(i) IS NULL) THEN

      IF (l_vendor_num_tbl(i) IS NULL) THEN
        l_column_name := 'VENDOR_NAME';
        l_token_value := l_vendor_name_tbl(i);
      ELSE
        l_column_name := 'VENDOR_NUM';
        l_token_value := l_vendor_num_tbl(i);
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      ( p_interface_header_id => l_intf_header_id_tbl(i),
        p_error_message_name => 'PO_PDOI_DERV_ERROR',
        p_table_name => 'PO_HEADERS_INTERFACE',
        p_column_name => 'VENDOR_ID',
        p_column_value => l_vendor_id_tbl(i),
        p_token1_name => 'COLUMN_NAME',
        p_token1_value => l_column_name,
        p_token2_name => 'VALUE',
        p_token2_value => l_token_value
      );

      l_reject_list.extend;
      l_reject_list(l_reject_list.COUNT) := l_intf_header_id_tbl(i);
    END IF;
  END LOOP;

  d_position := 40;
  -- For records that cannot derive vendor id, reject header and its children
  PO_PDOI_UTL.reject_headers_intf
  ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID,
    p_id_tbl        => l_reject_list,
    p_cascade       => FND_API.G_TRUE
  );

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
END derive_vendor_id;


-----------------------------------------------------------------------
--Start of Comments
--Name: verify_action_replace
--Function:
--  For records with action = 'REPLACE', verify that the action can be
--  performed
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE verify_action_replace
IS

d_api_name CONSTANT VARCHAR2(30) := 'verify_action_replace';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_interface_header_id_tbl PO_TBL_NUMBER;
l_vendor_id_tbl PO_TBL_NUMBER;
l_start_date_tbl PO_TBL_DATE;
l_end_date_tbl PO_TBL_DATE;
l_vendor_doc_num_tbl PO_TBL_VARCHAR25;

l_orig_po_header_id_tbl PO_TBL_NUMBER;
l_orig_closed_code_tbl PO_TBL_VARCHAR25;
l_orig_cancel_flag_tbl PO_TBL_VARCHAR1;
l_orig_ga_tbl PO_TBL_VARCHAR1;

l_doc_active BOOLEAN;

l_index_for_replacement NUMBER;

l_error_message_name FND_NEW_MESSAGES.message_name%TYPE;

l_valid VARCHAR2(1);

l_final_intf_header_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
l_final_orig_header_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
l_reject_list PO_TBL_NUMBER := PO_TBL_NUMBER();
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- For update and replace action, make sure that the document exists

  SELECT interface_header_id,
         vendor_id,
         effective_date,
         expiration_date,
         vendor_doc_num
  BULK COLLECT INTO l_interface_header_id_tbl, l_vendor_id_tbl,
      l_start_date_tbl, l_end_date_tbl, l_vendor_doc_num_tbl
  FROM po_headers_interface
  WHERE processing_id = PO_PDOI_PARAMS.g_processing_id
  AND action = PO_PDOI_CONSTANTS.g_ACTION_REPLACE;

  IF (l_interface_header_id_tbl IS NULL OR l_interface_header_id_tbl.COUNT = 0) THEN
    d_position := 10;
    RETURN;
  END IF;

  d_position := 20;
  FOR i IN 1..l_interface_header_id_tbl.COUNT LOOP
    l_valid := FND_API.G_TRUE;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'checking for ' ||
                  l_interface_header_id_tbl(i));
    END IF;

    -- start date has to be provided for replace
    IF l_start_date_tbl(i) IS NULL THEN
      d_position := 30;
      PO_PDOI_ERR_UTL.add_fatal_error
      ( p_interface_header_id => l_interface_header_id_tbl(i),
        p_error_message_name => 'PO_PDOI_COLUMN_NOT_NULL',
        p_table_name => 'PO_HEADERS_INTERFACE',
        p_column_name => 'START_DATE',
        p_column_value => l_start_date_tbl(i),
        p_token1_name => 'COLUMN_NAME',
        p_token1_value => 'START_DATE'
      );

      l_valid := FND_API.G_FALSE;
    END IF;

    d_position := 40;
    -- start date has to be greater than end date
    IF (TRUNC(l_start_date_tbl(i)) > TRUNC(NVL(l_end_date_tbl(i), l_start_date_tbl(i)))) THEN
      PO_PDOI_ERR_UTL.add_fatal_error
      ( p_interface_header_id => l_interface_header_id_tbl(i),
        p_error_message_name => 'PO_PDOI_INVALID_START_DATE',
        p_table_name => 'PO_HEADERS_INTERFACE',
        p_column_name => 'START_DATE',
        p_column_value => l_start_date_tbl(i),
        p_token1_name => 'VALUE',
        p_token1_value => l_start_date_tbl(i)
      );

      l_valid := FND_API.G_FALSE;
    END IF;

    d_position := 50;

    IF (l_valid = FND_API.G_TRUE) THEN

      IF (PO_PDOI_PARAMS.g_request.document_type =
        PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN

        d_position := 60;

        -- Quotation: Match vendor doc num with quote_vendor_quote_number
        SELECT po_header_id,
               NVL(closed_code, 'OPEN'),
               NVL(cancel_flag, 'N'),
               NULL
        BULK COLLECT
        INTO  l_orig_po_header_id_tbl,
              l_orig_closed_code_tbl,
              l_orig_cancel_flag_tbl,
              l_orig_ga_tbl
        FROM po_headers POH
        WHERE vendor_id = l_vendor_id_tbl(i)
        AND   quote_vendor_quote_number = l_vendor_doc_num_tbl(i)
        AND   TRUNC(l_start_date_tbl(i)) >= TRUNC(NVL(start_date, SYSDATE))
        AND   TRUNC(NVL(l_end_date_tbl(i), SYSDATE)) <= TRUNC(NVL(end_date, SYSDATE));

      ELSIF (PO_PDOI_PARAMS.g_request.document_type =
        PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN

        d_position := 70;
        -- Blanket: Match vendor doc num with vendor_order_num
        SELECT po_header_id,
               NVL(closed_code, 'OPEN'),
               NVL(cancel_flag, 'N'),
               NVL(global_agreement_flag, 'N')
        BULK COLLECT
        INTO  l_orig_po_header_id_tbl,
              l_orig_closed_code_tbl,
              l_orig_cancel_flag_tbl,
              l_orig_ga_tbl
        FROM po_headers POH
        WHERE vendor_id = l_vendor_id_tbl(i)
        AND   vendor_order_num = l_vendor_doc_num_tbl(i)
        AND   TRUNC(l_start_date_tbl(i)) >= TRUNC(NVL(start_date, SYSDATE));
		-- for issue 14458735
        --AND   TRUNC(NVL(l_end_date_tbl(i), SYSDATE)) <= TRUNC(NVL(end_date, SYSDATE));
      END IF;

      l_doc_active := FALSE;
      l_index_for_replacement := NULL;
      l_error_message_name := NULL;

      IF (l_orig_po_header_id_tbl.COUNT = 0) THEN
        d_position := 80;
        l_error_message_name := 'PO_PDOI_INVALID_ORIG_CATALOG';
      ELSE
        d_position := 90;
        -- If there are existing documents with the same vendor doc number info,
        -- then we take the active one if there is only one.

        FOR j IN 1..l_orig_po_header_id_tbl.COUNT LOOP
          IF (l_orig_closed_code_tbl(j) <> 'FINALLY CLOSED' AND
              l_orig_cancel_flag_tbl(j) <> 'Y')
          THEN
            IF (l_doc_active) THEN
              -- there is already an active doc. It's an error.
              l_error_message_name := 'PO_PDOI_INVAL_MULT_ORIG_CATG';
            ELSE
              l_doc_active := TRUE;
              l_index_for_replacement := j;
            END IF;
          ELSE
            -- inactive
            IF (NOT l_doc_active AND l_index_for_replacement IS NULL) THEN
              l_index_for_replacement := j;
            ELSIF (NOT l_doc_active) THEN
              -- matching multiple inactive documents is error as well
              l_error_message_name := 'PO_PDOI_INVALID_ORIG_CATALOG';
            END IF;
          END IF;
        END LOOP; -- FOR i in i..l_orig_po_header_id_tbl.COUNT
      END IF;

      d_position := 100;

      IF (l_error_message_name IS NOT NULL) THEN
        PO_PDOI_ERR_UTL.add_fatal_error
        ( p_interface_header_id => l_interface_header_id_tbl(i),
          p_error_message_name => l_error_message_name,
          p_table_name => 'PO_HEADERS_INTERFACE',
          p_column_name => 'VENDOR_DOC_NUM',
          p_column_value => l_vendor_doc_num_tbl(i),
          p_token1_name => 'DOC_NUMBER',
          p_token1_value => l_vendor_doc_num_tbl(i)
        );
        l_index_for_replacement := NULL; -- no id to replace
        l_valid := FND_API.G_FALSE;
      END IF;
    END IF;

    IF (l_index_for_replacement IS NOT NULL) THEN
      d_position := 110;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'Found doc for replacement: ' ||
                    l_orig_po_header_id_tbl(l_index_for_replacement));
      END IF;

      -- For blanket, make sure that all releases should not have release
      -- date greater than the start date of the newly replaced blanket, whcih
      -- is equivalent to the end date of the old blanket

      IF (PO_PDOI_PARAMS.g_request.document_type =
        PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN

        d_position := 120;
        check_release_dates
        ( p_interface_header_id => l_interface_header_id_tbl(i),
          p_po_header_id => l_orig_po_header_id_tbl(l_index_for_replacement),
          p_ga_flag => l_orig_ga_tbl(l_index_for_replacement),
          p_new_doc_start_date => l_start_date_tbl(i),
          x_valid => l_valid
        );
      END IF;
    END IF;

    IF (l_valid = FND_API.G_TRUE) THEN
      d_position := 130;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'Release date check passed');
      END IF;

      l_final_intf_header_id_tbl.extend;
      l_final_intf_header_id_tbl(l_final_intf_header_id_tbl.COUNT) :=
              l_interface_header_id_tbl(i);

      l_final_orig_header_id_tbl.extend;
      l_final_orig_header_id_tbl(l_final_orig_header_id_tbl.COUNT) :=
              l_orig_po_header_id_tbl(l_index_for_replacement);
    ELSE
      d_position := 140;
      l_reject_list.extend;
      l_reject_list(l_reject_list.COUNT) := l_interface_header_id_tbl(i);
    END IF;
  END LOOP;

  d_position := 150;

  -- Set original header id
  FORALL i IN 1..l_final_orig_header_id_tbl.COUNT
    UPDATE po_headers_interface
    SET original_po_header_id = l_final_orig_header_id_tbl(i)
    WHERE interface_header_id = l_final_intf_header_id_tbl(i);

  d_position := 160;
  -- propagate errors to lower level
  PO_PDOI_UTL.reject_headers_intf
  ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID,
    p_id_tbl        => l_reject_list,
    p_cascade       => FND_API.G_TRUE
  );

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
END verify_action_replace;


-----------------------------------------------------------------------
--Start of Comments
--Name: check_release_dates
--Function:
--  Given the blanket, check whether there is existing release for the blanket
--  that has release date earlier than the new start date of the blanket
--Parameters:
--IN:
--p_interface_header_id
--  interface header id
--p_po_header_id
--  document to check
--p_ga_flag
--  whether the document is a global agreement or not
--p_new_doc_start_date
--  proposed start date of the document
--IN OUT:
--x_valid
--  FND_API.G_TRUE if the this validation passes
--  FND_API.G_FALSE otherwise
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE check_release_dates
( p_interface_header_id IN NUMBER,
  p_po_header_id IN NUMBER,
  p_ga_flag IN VARCHAR2,
  p_new_doc_start_date IN DATE,
  x_valid IN OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'check_release_dates';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_rel_exists VARCHAR2(1);
l_exp_date DATE := p_new_doc_start_date - 1;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- if we are expiring a blanket, make sure that none of the releases falls
  -- outside of the effective dates of the blanket being expired
  IF (p_ga_flag = 'Y') THEN
    SELECT MAX('Y')
    INTO l_rel_exists
    FROM DUAL
    WHERE EXISTS (SELECT 'Exists std PO ref the orig GA'
                  FROM   po_lines_all POL,
                         po_headers_all POH
                  WHERE POL.from_header_id = p_po_header_id
                  AND POL.po_header_id = POH.po_header_id
                  AND POH.creation_date >= l_exp_date);

    d_position := 10;

    IF (l_rel_exists = 'Y') THEN
      PO_PDOI_ERR_UTL.add_fatal_error
      ( p_interface_header_id => p_interface_header_id,
        p_error_message_name => 'PO_PDOI_GA_ST_DATE_GT_PO_DATE',
        p_table_name => 'PO_HEADERS_INTERFACE',
        p_column_name => 'EFFECTIVE_DATE',
        p_column_value => p_new_doc_start_date
      );

      x_valid := FND_API.G_FALSE;
    END IF;

  ELSE
    d_position := 20;

    SELECT MAX('Y')
    INTO l_rel_exists
    FROM DUAL
    WHERE EXISTS (SELECT 'release exist after expiration date'
                 FROM   po_releases POR
                 WHERE  POR.po_header_id = p_po_header_id
                 AND    POR.release_date >= l_exp_date);

    IF (l_rel_exists = 'Y') THEN
      PO_PDOI_ERR_UTL.add_fatal_error
      ( p_interface_header_id => p_interface_header_id,
        p_error_message_name => 'PO_PDOI_ST_DATE_GT_REL_DATE',
        p_table_name => 'PO_HEADERS_INTERFACE',
        p_column_name => 'EFFECTIVE_DATE',
        p_column_value => p_new_doc_start_date
      );

      x_valid := FND_API.G_FALSE;
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
END check_release_dates;


-----------------------------------------------------------------------
--Start of Comments
--Name: verify_action_update
--Function:
--  For records with action = 'UPDATE', verify that the action can be
--  performed
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE verify_action_update IS

d_api_name CONSTANT VARCHAR2(30) := 'verify_action_update';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_existing_header VARCHAR2(1);

l_valid VARCHAR2(1);

l_doc_type PO_DOCUMENT_TYPES.document_type_code%TYPE;
l_doc_subtype PO_DOCUMENT_TYPES.document_subtype%TYPE;


l_interface_header_id_tbl PO_TBL_NUMBER;
l_vendor_id_tbl PO_TBL_NUMBER;
l_start_date_tbl PO_TBL_DATE;
l_end_date_tbl PO_TBL_DATE;
l_po_header_id_tbl PO_TBL_NUMBER;
l_vendor_doc_num_tbl PO_TBL_VARCHAR25;
l_document_num_tbl PO_TBL_VARCHAR25;

l_message_name FND_NEW_MESSAGES.message_name%TYPE;
l_col_name PO_INTERFACE_ERRORS.column_name%TYPE;
l_col_value PO_INTERFACE_ERRORS.column_value%TYPE;
l_token_name VARCHAR2(100);
l_token_value VARCHAR2(100);
l_doc_num_for_msg_dsp PO_HEADERS_ALL.segment1%TYPE;

l_skip_cat_upload_chk VARCHAR2(1);

l_status_rec PO_STATUS_REC_TYPE;
l_return_status VARCHAR2(1);

l_orig_po_header_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
l_orig_consumption_flag_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

l_consigned_consumption_flag PO_HEADERS_ALL.consigned_consumption_flag%TYPE;

l_final_intf_header_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
l_final_po_header_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

l_reject_list PO_TBL_NUMBER := PO_TBL_NUMBER();
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  SELECT interface_header_id,
         vendor_id,
         effective_date,
         expiration_date,
         po_header_id,
         vendor_doc_num,
         document_num
  BULK COLLECT
  INTO l_interface_header_id_tbl,
       l_vendor_id_tbl,
       l_start_date_tbl,
       l_end_date_tbl,
       l_po_header_id_tbl,
       l_vendor_doc_num_tbl,
       l_document_num_tbl
  FROM po_headers_interface
  WHERE processing_id = PO_PDOI_PARAMS.g_processing_id
  AND action = PO_PDOI_CONSTANTS.g_ACTION_UPDATE;

  IF (l_interface_header_id_tbl IS NULL OR l_interface_header_id_tbl.COUNT = 0) THEN
    d_position := 10;
    RETURN;
  END IF;

  IF (PO_PDOI_PARAMS.g_request.calling_module =
      PO_PDOI_CONSTANTS.g_call_mod_CATALOG_UPLOAD) THEN
    l_skip_cat_upload_chk := FND_API.G_TRUE;
  ELSE
    l_skip_cat_upload_chk := FND_API.G_FALSE;
  END IF;

  FOR i IN 1..l_interface_header_id_tbl.COUNT LOOP
    l_valid := FND_API.g_TRUE;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'checking for ' ||
                  l_interface_header_id_tbl(i));
    END IF;

    IF (l_po_header_id_tbl(i) IS NOT NULL) THEN
      d_position := 20;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'po_header_id ' ||
                    l_po_header_id_tbl(i) || 'is provided');
      END IF;

      -- Make sure that the po_header_id is still valid

      SELECT DECODE(MAX(POH.po_header_id), NULL, 'N', 'Y'),
             NVL(MAX(POH.consigned_consumption_flag), 'N')
      INTO l_existing_header,
           l_consigned_consumption_flag
      FROM po_headers POH
      WHERE POH.po_header_id = l_po_header_id_tbl(i)
      AND POH.type_lookup_code = PO_PDOI_PARAMS.g_request.document_type;

      IF (l_existing_header = 'N' OR l_consigned_consumption_flag = 'Y') THEN

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'po header id does not exist or' ||
                      ' document type does not match');
        END IF;

        l_valid := FND_API.g_FALSE;
      END IF;

      d_position := 30;

      IF (l_valid = FND_API.g_TRUE) THEN
        IF (PO_PDOI_PARAMS.g_request.document_type IN
             (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
              PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD)) THEN

          d_position := 40;

          PO_PDOI_UTL.get_processing_doctype_info
          ( x_doc_type => l_doc_type,
            x_doc_subtype => l_doc_subtype
          );

          PO_DOCUMENT_CHECKS_GRP.po_status_check
          ( p_api_version => 1.0,
            p_header_id => l_po_header_id_tbl(i),
            p_document_type => l_doc_type,
            p_document_subtype => l_doc_subtype,
            p_mode => 'CHECK_UPDATEABLE',
            p_calling_module => PO_DRAFTS_PVT.g_call_mod_PDOI,
            p_role => PO_PDOI_PARAMS.g_request.role,
            p_skip_cat_upload_chk => l_skip_cat_upload_chk,
            x_po_status_rec => l_status_rec,
            x_return_status => l_return_status
          );

          IF (l_return_status <> FND_API.g_RET_STS_SUCCESS) THEN
            d_position := 50;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSE
            d_position := 60;
            IF (l_status_rec.updatable_flag(1) = 'N') THEN
              l_valid := FND_API.g_FALSE;
            END IF;
          END IF;
        END IF;
      END IF;

      IF (l_valid <> FND_API.g_TRUE) THEN
        d_position := 70;

        IF (PO_PDOI_PARAMS.g_request.document_type =
            PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
          l_message_name := 'PO_PDOI_INVALID_ORIG_STD_PO';
        ELSE
          l_message_name := 'PO_PDOI_INVALID_ORIG_CATALOG';
        END IF;

        -- since the message takes in document number rather than
        -- po_header_id, we attempt to derive document number
        -- from po_header_id
        SELECT NVL(MIN(segment1), 'UNKNOWN')
        INTO   l_doc_num_for_msg_dsp
        FROM   po_headers_all
        WHERE  po_header_id = l_po_header_id_tbl(i);

        PO_PDOI_ERR_UTL.add_fatal_error
        ( p_interface_header_id => l_interface_header_id_tbl(i),
          p_error_message_name => l_message_name,
          p_table_name => 'PO_HEADERS_INTERFACE',
          p_column_name => 'PO_HEADER_ID',
          p_column_value => l_po_header_id_tbl(i),
          p_token1_name => 'DOC_NUMBER',
          p_token1_value => l_doc_num_for_msg_dsp
        );
        l_valid := FND_API.g_FALSE;

        l_reject_list.extend;
        l_reject_list(l_reject_list.COUNT) := l_interface_header_id_tbl(i);
      END IF;

    ELSE  -- po_header_id is not provided
      d_position := 80;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'po_header_id is not provided. ' ||
                    'vendor doc num = ' || l_vendor_doc_num_tbl(i) ||
                    ', document_num = ' || l_document_num_tbl(i));
      END IF;

      IF (l_vendor_doc_num_tbl(i) IS NOT NULL) THEN
        -- Definitely need to match vendor doc num. Matching document num
        -- will be performed, if provided
        IF (PO_PDOI_PARAMS.g_request.document_type IN
            (PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD,
             PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET)) THEN

          d_position := 90;
          SELECT POH.po_header_id,
                 NVL(POH.consigned_consumption_flag, 'N')
          BULK COLLECT
          INTO l_orig_po_header_id_tbl,
               l_orig_consumption_flag_tbl
          FROM po_headers POH
          WHERE POH.vendor_id = l_vendor_id_tbl(i)
          AND   POH.vendor_order_num = l_vendor_doc_num_tbl(i)
          AND   POH.segment1 = NVL(l_document_num_tbl(i), POH.segment1)
          AND   POH.type_lookup_code = PO_PDOI_PARAMS.g_request.document_type
          AND   (POH.type_lookup_code = 'STANDARD'
                 OR
                 (POH.type_lookup_code = 'BLANKET'
                  AND TRUNC(NVL(l_start_date_tbl(i), SYSDATE)) >=
                        TRUNC(NVL(POH.start_date, SYSDATE))
                  AND TRUNC(nvl(l_end_date_tbl(i), SYSDATE)) <=
                        TRUNC(nvl(POH.end_date, SYSDATE))))
          AND   NVL(POH.closed_code, 'OPEN') <> 'FINALLY CLOSED'
          AND   NVL(POH.cancel_flag, 'N') <> 'Y';

        ELSIF (PO_PDOI_PARAMS.g_request.document_type =
               PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN
          d_position := 100;
          SELECT POH.po_header_id,
                 NVL(POH.consigned_consumption_flag, 'N')
          BULK COLLECT
          INTO l_orig_po_header_id_tbl,
               l_orig_consumption_flag_tbl
          FROM po_headers POH
          WHERE POH.vendor_id = l_vendor_id_tbl(i)
          AND   POH.quote_vendor_quote_number = l_vendor_doc_num_tbl(i)
          AND   POH.segment1 = NVL(l_document_num_tbl(i), POH.segment1)
          AND   POH.type_lookup_code = PO_PDOI_PARAMS.g_request.document_type
          AND   POH.type_lookup_code = 'QUOTATION'
          AND   TRUNC(NVL(l_start_date_tbl(i), SYSDATE)) >=
                  TRUNC(NVL(POH.start_date, SYSDATE))
          AND   TRUNC(nvl(l_end_date_tbl(i), SYSDATE)) <=
                  TRUNC(nvl(POH.end_date, SYSDATE))
          AND   NVL(POH.closed_code, 'OPEN') <> 'FINALLY CLOSED'
          AND   NVL(POH.cancel_flag, 'N') <> 'Y';

        END IF;

      ELSIF (l_document_num_tbl(i) IS NOT NULL) THEN
        d_position := 110;
        -- Definitely need to match document num. Matching vendor doc num
        -- will be performed, if provided

        IF (PO_PDOI_PARAMS.g_request.document_type IN
            (PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD,
             PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET)) THEN

          SELECT POH.po_header_id,
                 NVL(POH.consigned_consumption_flag, 'N')
          BULK COLLECT
          INTO l_orig_po_header_id_tbl,
               l_orig_consumption_flag_tbl
          FROM po_headers POH
          WHERE POH.vendor_id = l_vendor_id_tbl(i)
          AND   NVL(POH.vendor_order_num, FND_API.G_MISS_CHAR) =
                  NVL(l_vendor_doc_num_tbl(i),
                      NVL(POH.vendor_order_num, FND_API.G_MISS_CHAR))
          AND   POH.segment1 = l_document_num_tbl(i)
          AND   POH.type_lookup_code = PO_PDOI_PARAMS.g_request.document_type
          AND   (POH.type_lookup_code = 'STANDARD'
                 OR
                 (POH.type_lookup_code = 'BLANKET'
                  AND TRUNC(NVL(l_start_date_tbl(i), SYSDATE)) >=
                        TRUNC(NVL(POH.start_date, SYSDATE))
                  AND TRUNC(nvl(l_end_date_tbl(i), SYSDATE)) <=
                        TRUNC(nvl(POH.end_date, SYSDATE))))
          AND   NVL(POH.closed_code, 'OPEN') <> 'FINALLY CLOSED'
          AND   NVL(POH.cancel_flag, 'N') <> 'Y';

        ELSIF (PO_PDOI_PARAMS.g_request.document_type =
               PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN

          SELECT POH.po_header_id,
                 NVL(POH.consigned_consumption_flag, 'N')
          BULK COLLECT
          INTO l_orig_po_header_id_tbl,
               l_orig_consumption_flag_tbl
          FROM po_headers POH
          WHERE POH.vendor_id = l_vendor_id_tbl(i)
          AND   NVL(POH.quote_vendor_quote_number, FND_API.G_MISS_CHAR) =
                  NVL(l_vendor_doc_num_tbl(i),
                      NVL(POH.quote_vendor_quote_number, FND_API.G_MISS_CHAR))
          AND   POH.segment1 = l_document_num_tbl(i)
          AND   POH.type_lookup_code = PO_PDOI_PARAMS.g_request.document_type
          AND   POH.type_lookup_code = 'QUOTATION'
          AND   TRUNC(NVL(l_start_date_tbl(i), SYSDATE)) >=
                  TRUNC(NVL(POH.start_date, SYSDATE))
          AND   TRUNC(nvl(l_end_date_tbl(i), SYSDATE)) <=
                  TRUNC(nvl(POH.end_date, SYSDATE))
          AND   NVL(POH.closed_code, 'OPEN') <> 'FINALLY CLOSED'
          AND   NVL(POH.cancel_flag, 'N') <> 'Y';

        END IF;

      END IF;

      d_position := 120;

      -- derive the following fields for error reporting
      l_token_name := 'DOC_NUMBER';
      IF (l_document_num_tbl(i) IS NOT NULL AND l_vendor_doc_num_tbl(i) IS NULL) THEN
        l_col_name := 'DOCUMENT_NUM';
        l_col_value := l_document_num_tbl(i);
        l_token_value := l_document_num_tbl(i);
      ELSE
        l_col_name := 'VENDOR_DOC_NUM';
        l_col_value := l_vendor_doc_num_tbl(i);
        l_token_value := l_vendor_doc_num_tbl(i);
      END IF;

      IF (l_orig_po_header_id_tbl.COUNT <> 1) THEN
        IF (l_orig_po_header_id_tbl.COUNT = 0) THEN
          IF (PO_PDOI_PARAMS.g_request.document_type =
              PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
            l_message_name := 'PO_PDOI_INVALID_ORIG_STD_PO';
          ELSE
            l_message_name := 'PO_PDOI_INVALID_ORIG_CATALOG';
          END IF;
        ELSE
          IF (PO_PDOI_PARAMS.g_request.document_type =
              PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
            l_message_name := 'PO_PDOI_MULTIPLE_STD_PO';
          ELSE
            l_message_name := 'PO_PDOI_INVALID_MULT_ORIG_CATG';
          END IF;
        END IF;

        d_position := 130;

        PO_PDOI_ERR_UTL.add_fatal_error
        ( p_interface_header_id => l_interface_header_id_tbl(i),
          p_error_message_name => l_message_name,
          p_table_name => 'PO_HEADERS_INTERFACE',
          p_column_name => l_col_name,
          p_column_value => l_col_value,
          p_token1_name => l_token_name,
          p_token1_value => l_token_value
        );
        l_valid := FND_API.g_FALSE;
      END IF;

      IF (l_valid = FND_API.g_TRUE) THEN
        IF (PO_PDOI_PARAMS.g_request.document_type IN
              (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
               PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD)) THEN

          d_position := 140;

          PO_PDOI_UTL.get_processing_doctype_info
          ( x_doc_type => l_doc_type,
            x_doc_subtype => l_doc_subtype
          );

          PO_DOCUMENT_CHECKS_GRP.po_status_check
          ( p_api_version => 1.0,
            p_header_id => l_orig_po_header_id_tbl(1),
            p_document_type => l_doc_type,
            p_document_subtype => l_doc_subtype,
            p_mode => 'CHECK_UPDATEABLE',
            p_calling_module => PO_DRAFTS_PVT.g_call_mod_PDOI,
            p_role => PO_PDOI_PARAMS.g_request.role,
            p_skip_cat_upload_chk => l_skip_cat_upload_chk,
            x_po_status_rec => l_status_rec,
            x_return_status => l_return_status
          );

          IF (l_return_status <> FND_API.g_RET_STS_SUCCESS) THEN
            d_position := 150;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSE
            IF (l_orig_consumption_flag_tbl(1) = 'Y' OR
                l_status_rec.updatable_flag(1) = 'N') THEN

              IF (PO_PDOI_PARAMS.g_request.document_type =
                PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
                l_message_name := 'PO_PDOI_STD_PO_INVALID_STATUS';
              ELSE
                l_message_name := 'PO_PDOI_INVALID_ORIG_CATALOG';
              END IF;

              d_position := 160;
              PO_PDOI_ERR_UTL.add_fatal_error
              ( p_interface_header_id => l_interface_header_id_tbl(i),
                p_error_message_name => l_message_name,
                p_table_name => 'PO_HEADERS_INTERFACE',
                p_column_name => l_col_name,
                p_column_value => l_col_value,
                p_token1_name => l_token_name,
                p_token1_value => l_token_value
              );

              l_valid := FND_API.g_FALSE;
            END IF;
          END IF;
        END IF;
      END IF;

      d_position := 170;
      IF (l_valid = FND_API.g_TRUE) THEN
        l_final_intf_header_id_tbl.extend;
        l_final_intf_header_id_tbl(l_final_intf_header_id_tbl.COUNT) :=
                l_interface_header_id_tbl(i);

        l_final_po_header_id_tbl.extend;
        l_final_po_header_id_tbl(l_final_po_header_id_tbl.COUNT) :=
                l_orig_po_header_id_tbl(1);
      ELSE
        l_reject_list.extend;
        l_reject_list(l_reject_list.COUNT) := l_interface_header_id_tbl(i);
      END IF;
    END IF; -- p_po_header_id_tbl(i) IS NOT NULL

  END LOOP;

  d_position := 180;
  -- Set po header id (document to update)
  FORALL i IN 1..l_final_intf_header_id_tbl.COUNT
    UPDATE po_headers_interface
    SET po_header_id = l_final_po_header_id_tbl(i)
    WHERE interface_header_id = l_final_intf_header_id_tbl(i);

  d_position := 190;
  -- propagate rejection status to lower level
  PO_PDOI_UTL.reject_headers_intf
  ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID,
    p_id_tbl        => l_reject_list,
    p_cascade       => FND_API.G_TRUE
  );

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
END verify_action_update;



-----------------------------------------------------------------------
--Start of Comments
--Name: verify_action_original
--Function:
--  For records with action = 'ORIGINAL' or 'ADD', verify that the action can be
--  performed
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE verify_action_original IS

d_api_name CONSTANT VARCHAR2(30) := 'verify_action_original';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;


l_po_header_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
l_reject_list PO_TBL_NUMBER := PO_TBL_NUMBER();
l_vendor_doc_num_tbl PO_TBL_VARCHAR25 := PO_TBL_VARCHAR25();
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN

    SELECT POH.po_header_id,
           PHI.interface_header_id,
           PHI.vendor_doc_num
    BULK COLLECT
    INTO   l_po_header_id_tbl,
           l_reject_list,
           l_vendor_doc_num_tbl
    FROM   po_headers POH,
           po_headers_interface PHI
    WHERE  POH.vendor_id = PHI.vendor_id
    AND    POH.quote_vendor_quote_number = PHI.vendor_doc_Num
    AND    TRUNC (NVL(PHI.effective_date, SYSDATE)) >=
             TRUNC (NVL(POH.start_date, SYSDATE))
    AND    TRUNC (NVL(PHI.expiration_date, SYSDATE)) <=
             TRUNC (NVL(POH.end_date, SYSDATE))
    AND    NVL(POH.closed_code, 'OPEN') <> 'FINALLY CLOSED'
    AND    NVL(POH.cancel_flag, 'N') <> 'Y'
    AND    PHI.processing_id = PO_PDOI_PARAMS.g_processing_id
    AND    PHI.action IN (PO_PDOI_CONSTANTS.g_ACTION_ORIGINAL,
                          PO_PDOI_CONSTANTS.g_ACTION_ADD);

  ELSIF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN

    SELECT POH.po_header_id,
           PHI.interface_header_id,
           PHI.vendor_doc_num
    BULK COLLECT
    INTO   l_po_header_id_tbl,
           l_reject_list,
           l_vendor_doc_num_tbl
    FROM   po_headers POH,
           po_headers_interface PHI
    WHERE  POH.vendor_id = PHI.vendor_id
    AND    POH.vendor_order_num = PHI.vendor_doc_Num
    AND    TRUNC (NVL(PHI.effective_date, SYSDATE)) >=
             TRUNC (NVL(POH.start_date, SYSDATE))
    AND    TRUNC (NVL(PHI.expiration_date, SYSDATE)) <=
             TRUNC (NVL(POH.end_date, SYSDATE))
    AND    NVL(POH.closed_code, 'OPEN') <> 'FINALLY CLOSED'
    AND    NVL(POH.cancel_flag, 'N') <> 'Y'
    AND    PHI.processing_id = PO_PDOI_PARAMS.g_processing_id
    AND    PHI.action IN (PO_PDOI_CONSTANTS.g_ACTION_ORIGINAL,
                          PO_PDOI_CONSTANTS.g_ACTION_ADD);

  END IF;

  d_position := 10;

  FOR i IN 1..l_reject_list.COUNT LOOP
    PO_PDOI_ERR_UTL.add_fatal_error
    ( p_interface_header_id => l_reject_list(i),
      p_error_message_name => 'PO_PDOI_CATG_ALREADY_EXISTS',
      p_table_name => 'PO_HEADERS_INTERFACE',
      p_column_name => 'VENDOR_DOC_NUM',
      p_column_value => l_vendor_doc_num_tbl(i),
      p_token1_name => 'DOC_NUMBER',
      p_token1_value => l_vendor_doc_num_tbl(i)
    );
  END LOOP;

  d_position := 20;

  -- propagate rejection status to lower level for each document getting
  -- rejected
  PO_PDOI_UTL.reject_headers_intf
  ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID,
    p_id_tbl        => l_reject_list,
    p_cascade       => FND_API.G_TRUE
  );

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
END verify_action_original;



-----------------------------------------------------------------------
--Start of Comments
--Name: assign_po_header_id
--Function:
--  For interface records that yield new documents to be created in the
--  system, assign po_header_id from sequence
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE assign_po_header_id IS

d_api_name CONSTANT VARCHAR2(30) := 'assign_po_header_id';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- For ORIGINAL, ADD or REPLACE action, new document will be created
  -- Need to assign a new po_header_id
  UPDATE po_headers_interface
  SET    po_header_id = PO_HEADERS_S.nextval
  WHERE  processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    po_header_id IS NULL
  AND    action IN (PO_PDOI_CONSTANTS.g_ACTION_ORIGINAL,
                    PO_PDOI_CONSTANTS.g_ACTION_ADD,
                    PO_PDOI_CONSTANTS.g_ACTION_REPLACE);

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
END assign_po_header_id;


END PO_PDOI_PREPROC_PVT;

/
