--------------------------------------------------------
--  DDL for Package Body PO_PDOI_PRICE_DIFF_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_PRICE_DIFF_PROCESS_PVT" AS
/* $Header: PO_PDOI_PRICE_DIFF_PROCESS_PVT.plb 120.13.12010000.4 2015/01/16 10:16:41 linlilin ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_PRICE_DIFF_PROCESS_PVT');

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------

PROCEDURE populate_error_flag
(
  x_results             IN     po_validation_results_type,
  x_price_diffs         IN OUT NOCOPY PO_PDOI_TYPES.price_diffs_rec_type
);

--------------------------------------------------------------------------
---------------------- PUBLIC PROCEDURES ---------------------------------
--------------------------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: open_price_diffs
--Function:
--  Open cursor for query.
--  This query retrieves the price differential attributes and related header,
--  line and location attributes for processing
--Parameters:
--IN:
--  p_max_intf_price_diff_id
--    maximal interface_price_diff_id processed so far
--    The query will only retrieve the price_differential records which have
--    not been processed
--IN OUT:
--  x_price_diffs_csr
--  cursor variable to hold pointer to current processing row in the result
--  set returned by the query
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE open_price_diffs
(
  p_max_intf_price_diff_id   IN NUMBER,
  x_price_diffs_csr          OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'open_price_diffs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_max_intf_price_diff_id',
                      p_max_intf_price_diff_id);
  END IF;

  OPEN x_price_diffs_csr FOR
  SELECT intf_price_diffs.price_diff_interface_id,
         intf_price_diffs.interface_line_id,
         intf_price_diffs.interface_header_id,
         intf_price_diffs.price_differential_num,
         intf_price_diffs.price_type,
         intf_price_diffs.entity_type,
         intf_price_diffs.entity_id,
         intf_price_diffs.multiplier,
         intf_price_diffs.min_multiplier,
         intf_price_diffs.max_multiplier,

         -- attributes read from line location record
         intf_locs.line_location_id,

         -- attributes read from line record
         intf_lines.po_line_id,

         -- attributes read from header record
         intf_headers.draft_id,
         NVL(draft_headers.style_id, txn_headers.style_id),

         -- set initial value for error_flag
         FND_API.g_FALSE
  FROM   PO_PRICE_DIFF_INTERFACE intf_price_diffs,
         PO_LINE_LOCATIONS_INTERFACE intf_locs,
         PO_LINES_INTERFACE intf_lines,
         PO_HEADERS_INTERFACE intf_headers,
         PO_LINES_DRAFT_ALL draft_lines,
         PO_HEADERS_DRAFT_ALL draft_headers,
         PO_HEADERS_ALL txn_headers
  WHERE  intf_price_diffs.interface_line_id = intf_lines.interface_line_id
  AND    intf_lines.interface_header_id = intf_headers.interface_header_id
  AND    intf_lines.po_line_id = draft_lines.po_line_id
  AND    intf_headers.draft_id = draft_lines.draft_id
  AND    intf_headers.po_header_id = draft_headers.po_header_id(+)
  AND    intf_headers.draft_id = draft_headers.draft_id(+)
  AND    intf_headers.po_header_id = txn_headers.po_header_id(+)
  AND    draft_lines.order_type_lookup_code = 'RATE'
  AND    intf_price_diffs.interface_line_location_id = intf_locs.interface_line_location_id(+)
  AND    intf_price_diffs.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
  AND    intf_price_diffs.price_diff_interface_id > p_max_intf_price_diff_id
  AND    NVL(intf_lines.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
           <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED
  ORDER BY intf_price_diffs.price_diff_interface_id;

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
END open_price_diffs;

-----------------------------------------------------------------------
--Start of Comments
--Name: fetch_price_diffs
--Function:
--  fetch results in batch
--Parameters:
--IN:
--IN OUT:
--x_price_diffs_csr
--  cursor variable that hold pointers to currently processing row
--x_price_diffs
--  record variable to hold price differential info within a batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fetch_price_diffs
(
  x_price_diffs_csr   IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_price_diffs       OUT NOCOPY PO_PDOI_TYPES.price_diffs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'fetch_price_diffs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  FETCH x_price_diffs_csr BULK COLLECT INTO
    x_price_diffs.intf_price_diff_id_tbl,
    x_price_diffs.intf_line_id_tbl,
    x_price_diffs.intf_header_id_tbl,
    x_price_diffs.price_diff_num_tbl,
    x_price_diffs.price_type_tbl,
    x_price_diffs.entity_type_tbl,
    x_price_diffs.entity_id_tbl,
    x_price_diffs.multiplier_tbl,
    x_price_diffs.min_multiplier_tbl,
    x_price_diffs.max_multiplier_tbl,

    -- attributes read from line location record
    x_price_diffs.loc_line_loc_id_tbl,

    -- attributes read from line record
    x_price_diffs.ln_po_line_id_tbl,

    -- attributes read from header record
    x_price_diffs.draft_id_tbl,
    x_price_diffs.hd_style_id_tbl,

    -- set initial value for error_flag
    x_price_diffs.error_flag_tbl
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
END fetch_price_diffs;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_price_diffs
--Function: perform defaulting logic on price diff attributes
--Parameters:
--IN:
--IN OUT:
--  x_price_diffs
--    record to store all the price diff rows within the batch;
--    defaulting are performed for certain attributes only
--    if their value is empty.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_price_diffs
(
  x_price_diffs       IN OUT NOCOPY PO_PDOI_TYPES.price_diffs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_price_diffs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_PRICE_DIFF_DEFAULT);

  d_position := 10;

  FOR i IN 1..x_price_diffs.rec_count
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      PO_LOG.stmt(d_module, d_position, 'line loc id',
                  x_price_diffs.loc_line_loc_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'po line id',
                  x_price_diffs.ln_po_line_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'entity type',
                  x_price_diffs.entity_type_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'entity id',
                  x_price_diffs.entity_id_tbl(i));
    END IF;

    d_position := 20;

    -- default entity_type
    IF (x_price_diffs.entity_type_tbl(i) IS NULL) THEN
      IF (x_price_diffs.loc_line_loc_id_tbl(i) IS NOT NULL AND
	      PO_PDOI_PARAMS.g_request.document_type =
		    PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN
        x_price_diffs.entity_type_tbl(i) := 'PRICE BREAK';
      ELSE
        IF (PO_PDOI_PARAMS.g_request.document_type =
              PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN
          x_price_diffs.entity_type_tbl(i) := 'BLANKET LINE';
        ELSE
          x_price_diffs.entity_type_tbl(i) := 'PO LINE';
        END IF;
      END IF;
    END IF;

    d_position := 30;
    -- set entity_id according to the entity_type
    IF (x_price_diffs.entity_type_tbl(i) = 'PRICE BREAK') THEN
      x_price_diffs.entity_id_tbl(i) := x_price_diffs.loc_line_loc_id_tbl(i);
    ELSIF (x_price_diffs.entity_type_tbl(i) IN ('BLANKET LINE', 'PO LINE')) THEN
      x_price_diffs.entity_id_tbl(i) := x_price_diffs.ln_po_line_id_tbl(i);
    ELSE
      NULL; -- invalid entity_type
    END IF;
  END LOOP;

  d_position := 40;

  -- default price_differential_num if not provided or not unique
  PO_PDOI_MAINPROC_UTL_PVT.check_price_diff_num_unique
  (
    p_entity_type_tbl           => x_price_diffs.entity_type_tbl,
    p_entity_id_tbl             => x_price_diffs.entity_id_tbl,
    p_draft_id_tbl              => x_price_diffs.draft_id_tbl,
    p_intf_price_diff_id_tbl    => x_price_diffs.intf_price_diff_id_tbl,
    p_price_diff_num_tbl        => x_price_diffs.price_diff_num_tbl,
    x_price_diff_num_unique_tbl => x_price_diffs.price_diff_num_unique_tbl
  );

  d_position := 50;

  PO_PDOI_MAINPROC_UTL_PVT.calculate_max_price_diff_num
  (
    p_entity_type_tbl           => x_price_diffs.entity_type_tbl,
    p_entity_id_tbl             => x_price_diffs.entity_id_tbl,
    p_draft_id_tbl              => x_price_diffs.draft_id_tbl,
    p_price_diff_num_tbl        => x_price_diffs.price_diff_num_tbl
  );

  d_position := 60;

  FOR i IN 1..x_price_diffs.rec_count
  LOOP
    IF (x_price_diffs.price_diff_num_tbl(i) IS NULL OR
        x_price_diffs.price_diff_num_unique_tbl(i) = FND_API.g_FALSE) THEN
      x_price_diffs.price_diff_num_tbl(i) :=
        PO_PDOI_MAINPROC_UTL_PVT.get_next_price_diff_num
        (
          p_entity_type => x_price_diffs.entity_type_tbl(i),
          p_entity_id   => x_price_diffs.entity_id_tbl(i)
        );
    END IF;
  END LOOP;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_PRICE_DIFF_DEFAULT);

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
END default_price_diffs;

-----------------------------------------------------------------------
--Start of Comments
--Name: validate_price_diffs
--Function:
--  validate price differential attributes read within a batch
--Parameters:
--IN:
--IN OUT:
--x_dists
--  The record contains the values to be validated.
--  If there is error(s) on any attribute of the price differential row,
--  corresponding value in error_flag_tbl will be set with value
--  FND_API.G_TRUE.
--OUT:
--End of Comments
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE validate_price_diffs
(
  x_price_diffs         IN OUT NOCOPY PO_PDOI_TYPES.price_diffs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'validate_price_diffs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_price_differentials  PO_PRICE_DIFF_VAL_TYPE := PO_PRICE_DIFF_VAL_TYPE();
  l_parameter_name_tbl   PO_TBL_VARCHAR2000 := PO_TBL_VARCHAR2000();
  l_parameter_value_tbl  PO_TBL_VARCHAR2000 := PO_TBL_VARCHAR2000();
  l_result_type          VARCHAR2(30);
  l_results              po_validation_results_type;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_PRICE_DIFF_VALIDATE);

  l_price_differentials.interface_id   := x_price_diffs.intf_price_diff_id_tbl;
  l_price_differentials.price_type     := x_price_diffs.price_type_tbl;
  l_price_differentials.entity_type    := x_price_diffs.entity_type_tbl;
  l_price_differentials.entity_id      := x_price_diffs.entity_id_tbl;
  l_price_differentials.multiplier     := x_price_diffs.multiplier_tbl;
  l_price_differentials.min_multiplier := x_price_diffs.min_multiplier_tbl;
  l_price_differentials.max_multiplier := x_price_diffs.max_multiplier_tbl;
  l_price_differentials.hdr_style_id   := x_price_diffs.hd_style_id_tbl;

  d_position := 10;

  l_parameter_name_tbl.EXTEND(1);
  l_parameter_value_tbl.EXTEND(1);
  l_parameter_name_tbl(1)     := 'DOC_TYPE';
  l_parameter_value_tbl(1)    := PO_PDOI_PARAMS.g_request.document_type;

  PO_VALIDATIONS.validate_pdoi(p_price_differentials   => l_price_differentials,
                               p_parameter_name_tbl    => l_parameter_name_tbl,
                               p_parameter_value_tbl   => l_parameter_value_tbl,
                               x_result_type           => l_result_type,
                               x_results               => l_results);

  d_position := 20;

  IF (l_result_type = po_validations.c_result_type_failure) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'vaidate price diffs return failure');
    END IF;

    PO_PDOI_ERR_UTL.process_val_type_errors
    (
      x_results   => l_results,
      p_table_name => 'PO_PRICE_DIFF_INTERFACE',
      p_price_diffs => x_price_diffs
    );

    d_position := 30;

    populate_error_flag
    (
      x_results     => l_results,
      x_price_diffs => x_price_diffs
    );
  END IF;

  IF l_result_type = po_validations.c_result_type_fatal THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'vaidate price diffs return fatal');
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_PRICE_DIFF_VALIDATE);

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
END validate_price_diffs;

-------------------------------------------------------------------------
--------------------- PRIVATE PROCEDURES --------------------------------
-------------------------------------------------------------------------

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
--p_price_diffs
--  The record contains the values to be validated.
--  If there is error(s) on any attribute of the price differential row,
--  corresponding value in error_flag_tbl will be set with value
--  FND_API.G_TRUE.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE populate_error_flag
(
  x_results             IN     po_validation_results_type,
  x_price_diffs         IN OUT NOCOPY PO_PDOI_TYPES.price_diffs_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'populate_error_flag';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index_tbl  DBMS_SQL.number_table;
  l_index      NUMBER;
  l_remove_err_price_diff_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_remove_err_line_tbl       PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_intf_header_id NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  FOR i IN 1 .. x_price_diffs.intf_price_diff_id_tbl.COUNT LOOP
      l_index_tbl(x_price_diffs.intf_price_diff_id_tbl(i)) := i;
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

      -- collect price_diff_interface_ids to remove the errors from error intf table
      IF (NOT PO_PDOI_PARAMS.g_errored_lines.EXISTS(x_price_diffs.intf_line_id_tbl(l_index))) THEN
        d_position := 30;

        l_remove_err_line_tbl.EXTEND;
        l_remove_err_price_diff_tbl.EXTEND;
        l_remove_err_line_tbl(l_remove_err_line_tbl.COUNT) := x_price_diffs.intf_line_id_tbl(l_index);
        l_remove_err_price_diff_tbl(l_remove_err_price_diff_tbl.COUNT) := x_price_diffs.intf_price_diff_id_tbl(l_index);
      END IF;
    ELSIF (x_results.result_type(i) = po_validations.c_result_type_failure) THEN
        d_position := 40;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'error on index', l_index);
        END IF;

        x_price_diffs.error_flag_tbl(l_index) := FND_API.g_TRUE;

        -- Bug 5215781:
        -- price diff level errors will be counted in line errors and threshold will be
        -- checked; If threshold is hit, reject all price diff records that are processed
        -- after the current record and remove the errors from interface table for those
        -- records
        IF (NOT PO_PDOI_PARAMS.g_errored_lines.EXISTS(x_price_diffs.intf_line_id_tbl(l_index))) THEN
          d_position := 50;

          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'set error on line',
                        x_price_diffs.intf_line_id_tbl(l_index));
          END IF;

          -- set corresponding line to ERROR
          PO_PDOI_PARAMS.g_errored_lines(x_price_diffs.intf_line_id_tbl(l_index)) := 'Y';

          l_intf_header_id := x_price_diffs.intf_header_id_tbl(l_index);
          PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_errored_lines
            := PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_errored_lines +1;

          -- check threshold
          IF (PO_PDOI_PARAMS.g_request.calling_module =
                PO_PDOI_CONSTANTS.g_call_mod_CATALOG_UPLOAD AND
              PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_errored_lines
                = PO_PDOI_PARAMS.g_request.err_lines_tolerance) THEN
            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module, d_position, 'threshold hit on line',
                          x_price_diffs.intf_line_id_tbl(l_index));
            END IF;

            PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).err_tolerance_exceeded := FND_API.g_TRUE;

            -- reject all rows after this row
            FOR j IN l_index+1..x_price_diffs.rec_count LOOP
              x_price_diffs.error_flag_tbl(j) := FND_API.g_TRUE;
            END LOOP;
          END IF;
        END IF;
     END IF;
  END LOOP;

  d_position := 60;

  -- Bug 5215781:
  -- remove the errors for price diffs from po_interface_errors if those records are supposed to be processed
  -- after the price diff where we hit the error tolerance; And they do not belong to any line that has been
  -- counted in g_errored_lines. That means, we want to rollback some changes made on po_interface_errors if
  -- error tolerance is reached at some point
  PO_INTERFACE_ERRORS_UTL.flush_errors_tbl;

  FORALL i IN 1..l_remove_err_price_diff_tbl.COUNT
    DELETE FROM PO_INTERFACE_ERRORS
    WHERE price_diff_interface_id = l_remove_err_price_diff_tbl(i)
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

-- <<PDOI Enhancement Bug#17063664 Start>>
-----------------------------------------------------------------------
--Start of Comments
--Name: setup_price_diffs_intf
--Function:
--  Insert the default po_price_differentials info into the
--  po_price_diff_interface if not provided.
--Parameters:
--IN: None
--IN OUT: None
--OUT:  None
--End of Comments
------------------------------------------------------------------------
PROCEDURE setup_price_diffs_intf
IS

  d_api_name CONSTANT VARCHAR2(30) := 'setup_price_diffs_intf';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_draft_id_tbl                 PO_TBL_NUMBER;
  l_po_line_id_tbl               PO_TBL_NUMBER;
  l_intf_header_id_tbl           PO_TBL_NUMBER;
  l_intf_line_id_tbl             PO_TBL_NUMBER;
  l_req_line_id_tbl              PO_TBL_NUMBER;
  l_from_line_id_tbl             PO_TBL_NUMBER;
  l_from_line_loc_id_tbl         PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  SELECT draft_lines.draft_id,
         draft_lines.po_line_id,
         intf_lines.interface_header_id,
         intf_lines.interface_line_id,
         intf_lines.requisition_line_id,
         draft_lines.from_line_id,
         draft_lines.from_line_location_id
  BULK COLLECT INTO
         l_draft_id_tbl,
         l_po_line_id_tbl,
         l_intf_header_id_tbl,
         l_intf_line_id_tbl,
         l_req_line_id_tbl,
         l_from_line_id_tbl,
         l_from_line_loc_id_tbl
  FROM   po_headers_interface intf_headers,
         po_lines_interface intf_lines,
         po_lines_draft_all draft_lines
  WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
  AND    intf_lines.po_line_id          = draft_lines.po_line_id
  AND    intf_headers.draft_id          = draft_lines.draft_id
  --Bug 20368337
  AND    intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num;

  d_position := 20;

  -- SQL What: Insert a new row for price diff values
  -- SQL Why : To create a default price diff row
  FORALL i IN 1..l_draft_id_tbl.COUNT
  INSERT INTO po_price_diff_interface
  (price_diff_interface_id
    , price_differential_num
    , interface_header_id
    , interface_line_id
    , entity_type
    , price_type
    , min_multiplier
    , max_multiplier
    , multiplier
    , enabled_flag
    , process_status
    , last_update_date
    , last_updated_by
    , last_update_login
    , creation_date
    , created_by
    , processing_id -- Bug 18891225
  )
  SELECT PO_PRICE_DIFF_INTERFACE_S.nextval
    , price_diffs.price_differential_num
    , l_intf_header_id_tbl(i)
    , l_intf_line_id_tbl(i)
    , 'PO LINE'
    , price_diffs.price_type
    , NULL
    , NULL
    , decode ( price_diffs.entity_type
        , 'REQ LINE'     , price_diffs.multiplier
        , 'PO LINE'      , price_diffs.multiplier
        , 'PRICE BREAK'  , price_diffs.min_multiplier
        , 'BLANKET LINE' , price_diffs.min_multiplier
        )
    , price_diffs.enabled_flag
    , 'PENDING'
    , sysdate
    , FND_GLOBAL.user_id
    , FND_GLOBAL.login_id
    , sysdate
    , FND_GLOBAL.user_id
    , PO_PDOI_PARAMS.g_processing_id -- Bug 18891225
	FROM po_requisition_lines_all prl
	  , po_price_differentials price_diffs
	WHERE prl.requisition_line_id = l_req_line_id_tbl(i)
	AND price_diffs.entity_type = DECODE(prl.contractor_status, 'ASSIGNED', 'REQ LINE',
									DECODE(prl.overtime_allowed_flag, 'Y',
										NVL2(l_from_line_loc_id_tbl(i), 'PRICE BREAK',
											NVL2(l_from_line_id_tbl(i), 'BLANKET LINE', NULL))))
  AND price_diffs.entity_id   = DECODE(prl.contractor_status, 'ASSIGNED', prl.requisition_line_id,
									DECODE(prl.overtime_allowed_flag, 'Y',
										NVL2(l_from_line_loc_id_tbl(i), l_from_line_loc_id_tbl(i),
											NVL2(l_from_line_id_tbl(i), l_from_line_id_tbl(i), NULL))))
  AND nvl(price_diffs.enabled_flag,'N') = 'Y'
	AND PO_PDOI_PARAMS.g_request.document_type = 'STANDARD'
	AND PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING
		, PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE)
  AND NOT EXISTS
      (SELECT 1
       FROM po_price_diff_interface
       WHERE interface_line_id = l_intf_line_id_tbl(i));

  d_position := 30;

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
END setup_price_diffs_intf;
-- <<PDOI Enhancement Bug#17063664 End>>

END PO_PDOI_PRICE_DIFF_PROCESS_PVT;

/
