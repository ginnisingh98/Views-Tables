--------------------------------------------------------
--  DDL for Package Body PO_PDOI_ATTR_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_ATTR_PROCESS_PVT" AS
/* $Header: PO_PDOI_ATTR_PROCESS_PVT.plb 120.12.12010000.5 2014/01/06 20:13:24 srpantha ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_ATTR_PROCESS_PVT');

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
---------------------- PUBLIC PROCEDURES ---------------------------------
--------------------------------------------------------------------------

-------------------------------------------------------------------------
--Start of Comments
--Name: open_attr_values
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  open cursor which reads the attr values record in batch
--Parameters:
--IN:
--  p_max_intf_attr_values_id
--    maximal intf_attr_values_id processed in previous batches
--IN OUT:
--  x_attr_values_csr
--    cursor variable which points to next to-be-processed record
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE open_attr_values
(
  p_max_intf_attr_values_id   IN NUMBER,
  x_attr_values_csr           OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'open_attr_values';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_max_intf_attr_values_id',
                      p_max_intf_attr_values_id);
  END IF;

  OPEN x_attr_values_csr FOR
    SELECT intf_attrs.interface_attr_values_id,
           intf_attrs.org_id,
           -- Bug#17998869
           intf_attrs.lead_time,

           -- attributes read from line
           draft_lines.po_line_id,
           draft_lines.ip_category_id,
           draft_lines.item_id,

           -- attributes read from header
           intf_headers.draft_id,
           -- attribute values id
           NULL,
           -- initial value for error_flag
           FND_API.g_FALSE
    FROM   po_attr_values_interface intf_attrs,
           po_lines_interface intf_lines,
           po_headers_interface intf_headers,
           po_lines_draft_all draft_lines
    WHERE  intf_attrs.interface_line_id = intf_lines.interface_line_id
    AND    intf_lines.interface_header_id = intf_headers.interface_header_id
    AND    intf_headers.draft_id = draft_lines.draft_id
    AND    intf_lines.po_line_id = draft_lines.po_line_id
    AND    intf_attrs.processing_id = PO_PDOI_PARAMS.g_processing_id
    AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
    AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
    AND    intf_attrs.interface_attr_values_id > p_max_intf_attr_values_id
    AND    NVL(intf_lines.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
             <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED
    ORDER BY intf_attrs.interface_attr_values_id;

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
END open_attr_values;

-------------------------------------------------------------------------
--Start of Comments
--Name: fetch_attr_values
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  fetch attr values records based on batch size
--Parameters:
--IN:
--IN OUT:
--  x_attr_values_csr
--    cursor variable which points to next to-be-processed record
--  x_attr_values
--    record containing all attr values info within the batch
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fetch_attr_values
(
  x_attr_values_csr          IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_attr_values              OUT NOCOPY PO_PDOI_TYPES.attr_values_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'fetch_attr_values';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  FETCH x_attr_values_csr BULK COLLECT INTO
    x_attr_values.intf_attr_values_id_tbl,
    x_attr_values.org_id_tbl,
    -- Bug#17998869
    x_attr_values.lead_time_tbl,

    -- attributes read from line
    x_attr_values.ln_po_line_id_tbl,
    x_attr_values.ln_ip_category_id_tbl,
    x_attr_values.ln_item_id_tbl,

    -- attributes read from header
    x_attr_values.draft_id_tbl,

    -- attribute values id
    x_attr_values.attribute_values_id_tbl,

    -- initial value for error_flag
    x_attr_values.error_flag_tbl
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
END fetch_attr_values;

-------------------------------------------------------------------------
--Start of Comments
--Name: check_attr_actions
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  check whether the action on each attr values row is CREATE/UPDATE;
--  If multiple rows are pointing to same po line, these rows will be
--  processed in separate groups.
--Parameters:
--IN:
--IN OUT:
--  x_processing_row_tbl
--    the procedure will only process rows which have non-empty
--    values in this pl/sql table
--  x_attr_values
--    record containing all attr values info within the batch
--OUT:
--  x_create_row_tbl
--    index of rows to be created in current group
--  x_update_row_tbl
--    index of rows to be updated in cuurent group
--  x_sync_attr_id_tbl
--    list of attr_value_ids of rows that need to be read from txn table
--    into draft table
--  x_sync_draft_id_tbl
--    corresponding draft_ids of rows that will be read from txn table
--    into draft table
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE check_attr_actions
(
  x_processing_row_tbl       IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_attr_values              IN OUT NOCOPY PO_PDOI_TYPES.attr_values_rec_type,
  x_merge_row_tbl            OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_sync_attr_id_tbl         OUT NOCOPY PO_TBL_NUMBER,
  x_sync_draft_id_tbl        OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'check_attr_actions';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- ket value used to identify records in po_session_gt table
  l_key          PO_SESSION_GT.key%TYPE;

  -- variables to save result read from po_session_gt
  l_index_tbl    PO_TBL_NUMBER;
  l_result_tbl   PO_TBL_NUMBER;
  l_source_tbl   PO_TBL_VARCHAR5; -- values can be 'draft' or 'txn'

  l_index        NUMBER;
  l_counter      NUMBER;

  -- hash table to track whether same po_line_id exist within batch
  l_attr_ref_tbl DBMS_SQL.NUMBER_TABLE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'x_processing_row_tbl.COUNT',
                      x_processing_row_tbl.COUNT);
    l_index := x_processing_row_tbl.FIRST;
    WHILE (l_index IS NOT NULL)
    LOOP
      PO_LOG.proc_begin(d_module, 'to be processed row num', l_index);
      l_index := x_processing_row_tbl.NEXT(l_index);
    END LOOP;
  END IF;

  x_sync_attr_id_tbl  := PO_TBL_NUMBER();
  x_sync_draft_id_tbl := PO_TBL_NUMBER();

  l_key := PO_CORE_S.get_session_gt_nextval;

  -- first check whether record exists in draft table
  FORALL i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key, num1, num2, char1)
  SELECT l_key,
         x_processing_row_tbl(i),
         attribute_values_id,
         'DRAFT'
  FROM   po_attribute_values_draft
  WHERE  draft_id = x_attr_values.draft_id_tbl(i)
  AND    po_line_id = x_attr_values.ln_po_line_id_tbl(i)
  AND    org_id = x_attr_values.org_id_tbl(i);

  d_position := 10;

  -- second check whether record exists in txn table
  -- it needs only to be done once since it won't change within batch processing
  IF (x_processing_row_tbl.COUNT = x_attr_values.rec_count) THEN

    d_position := 20;

    FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt(key, num1, num2, char1)
    SELECT l_key,
           x_processing_row_tbl(i),
           attribute_values_id,
           'TXN'
    FROM   po_attribute_values
    WHERE  po_line_id = x_attr_values.ln_po_line_id_tbl(i)
    AND    org_id = x_attr_values.org_id_tbl(i);
  END IF;

  -- retrieve result from po_session_gt table
  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1, num2, char1 BULK COLLECT INTO
    l_index_tbl, l_result_tbl, l_source_tbl;

  -- set attr_values_id in x_attr_values
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'current source exist?',
                  x_attr_values.source_tbl.EXISTS(l_index));
      IF (x_attr_values.source_tbl.EXISTS(l_index)) THEN
        PO_LOG.stmt(d_module, d_position, 'current source',
                    x_attr_values.source_tbl(l_index));
      END IF;
      PO_LOG.stmt(d_module, d_position, 'attr values id',
                  l_result_tbl(i));
      PO_LOG.stmt(d_module, d_position, ' new source',
                  l_source_tbl(i));
    END IF;

    -- draft record will override txn record
    IF (NOT x_attr_values.source_tbl.EXISTS(l_index) OR
      x_attr_values.source_tbl(l_index) <> 'DRAFT') THEN
      x_attr_values.attribute_values_id_tbl(l_index) := l_result_tbl(i);
      x_attr_values.source_tbl(l_index) := l_source_tbl(i);
    END IF;
  END LOOP;

  d_position := 30;

  -- next, set actions on each record, if records with same po_line_id
  -- exist, process them in separate groups
  l_index := 0;
  l_counter := x_processing_row_tbl.FIRST;
  WHILE (l_counter IS NOT NULL)
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'counter', l_counter);
    END IF;


    -- check whether there is row existing in hashtable
    IF (NOT l_attr_ref_tbl.EXISTS(x_attr_values.ln_po_line_id_tbl(l_counter))) THEN
    -- register it in the hashtbale
      l_attr_ref_tbl(x_attr_values.ln_po_line_id_tbl(l_counter)) := l_counter;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'row is handled in current loop');
        PO_LOG.stmt(d_module, d_position, 'attr values id',
                    x_attr_values.attribute_values_id_tbl(l_counter));
      END IF;

      -- set actions
      IF (x_attr_values.attribute_values_id_tbl(l_counter) IS NOT NULL) THEN
        -- row existing in draft or txn tables
        x_merge_row_tbl(l_counter) := l_counter;

        -- for UPDATE action, track the rows that need to be synced from
        -- txn table
        IF (x_attr_values.source_tbl(l_counter) = 'TXN') THEN

          l_index := l_index + 1;
          x_sync_attr_id_tbl.EXTEND;
          x_sync_draft_id_tbl.EXTEND;
          x_sync_attr_id_tbl(l_index) := x_attr_values.attribute_values_id_tbl(l_counter);
          x_sync_draft_id_tbl(l_index) := x_attr_values.draft_id_tbl(l_counter);
        END IF;
      ELSE
        -- it is a new row
        x_merge_row_tbl(l_counter) := l_counter;
      END IF;

      --mark rows as processed
      x_processing_row_tbl.DELETE(l_counter);
    END IF; -- IF (l_attr_ref_tbl(x_attr_values.po_line_id_tbl(i)) IS NULL)

    l_counter := x_processing_row_tbl.NEXT(l_counter);
  END LOOP;

     --Bug 12980629
   x_attr_values.source_tbl.DELETE;

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
END check_attr_actions;

-------------------------------------------------------------------------
--Start of Comments
--Name: open_attr_values_tlp
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  open cursor which reads the attr values tlp record in batch
--Parameters:
--IN:
--  p_max_intf_attr_values_tlp_id
--    maximal intf_attr_values_tlp_id processed in previous batches
--IN OUT:
--  x_attr_values_tlp_csr
--    cursor variable which points to next to-be-processed record
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE open_attr_values_tlp
(
  p_max_intf_attr_values_tlp_id   IN NUMBER,
  x_attr_values_tlp_csr           IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'open_attr_values_tlp';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  OPEN x_attr_values_tlp_csr FOR
    SELECT intf_attrs_tlp.interface_attr_values_tlp_id,
           intf_attrs_tlp.language,
           intf_attrs_tlp.org_id,
           intf_attrs_tlp.long_description,      -- Bug7722053
           -- attributes read from line
           draft_lines.po_line_id,
           draft_lines.ip_category_id,
           draft_lines.item_id,
           draft_lines.item_description,

           -- attributes read from header
           intf_headers.draft_id,

           -- attr values tlp id
           NULL,

           -- initial value for error_flag
           FND_API.g_FALSE
    FROM   po_attr_values_tlp_interface intf_attrs_tlp,
           po_lines_interface intf_lines,
           po_headers_interface intf_headers,
           po_lines_draft_all draft_lines
    WHERE  intf_attrs_tlp.interface_line_id = intf_lines.interface_line_id
    AND    intf_lines.interface_header_id = intf_headers.interface_header_id
    AND    intf_headers.draft_id = draft_lines.draft_id
    AND    intf_lines.po_line_id = draft_lines.po_line_id
    AND    intf_attrs_tlp.processing_id = PO_PDOI_PARAMS.g_processing_id
    AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
    AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
    AND    intf_attrs_tlp.interface_attr_values_tlp_id > p_max_intf_attr_values_tlp_id
    AND    NVL(intf_lines.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
             <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED
    ORDER BY intf_attrs_tlp.interface_attr_values_tlp_id;

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
END open_attr_values_tlp;

-------------------------------------------------------------------------
--Start of Comments
--Name: fetch_attr_values_tlp
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  fetch attr values tlp records based on batch size
--Parameters:
--IN:
--IN OUT:
--  x_attr_values_tlp_csr
--    cursor variable which points to next to-be-processed record
--  x_attr_values_tlp
--    record containing all attr values tlp info within the batch
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fetch_attr_values_tlp
(
  x_attr_values_tlp_csr          IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_attr_values_tlp              IN OUT NOCOPY PO_PDOI_TYPES.attr_values_tlp_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'fetch_attr_values_tlp';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  FETCH x_attr_values_tlp_csr BULK COLLECT INTO
    x_attr_values_tlp.intf_attr_values_tlp_id_tbl,
    x_attr_values_tlp.language_tbl,
    x_attr_values_tlp.org_id_tbl,
    x_attr_values_tlp.ln_item_long_desc_tbl,     -- Bug7722053

    -- attributes read from line
    x_attr_values_tlp.ln_po_line_id_tbl,
    x_attr_values_tlp.ln_ip_category_id_tbl,
    x_attr_values_tlp.ln_item_id_tbl,
    x_attr_values_tlp.ln_item_desc_tbl,

    -- attributes read from header
    x_attr_values_tlp.draft_id_tbl,

    -- attr values tlp id
    x_attr_values_tlp.attribute_values_tlp_id_tbl,

    -- initial value for error_flag
    x_attr_values_tlp.error_flag_tbl
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
END fetch_attr_values_tlp;

-------------------------------------------------------------------------
--Start of Comments
--Name: check_attr_tlp_actions
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  check whether the action on each attr values tlp row is CREATE/UPDATE;
--  If multiple rows are pointing to same po line and language, these rows
--  will be processed in separate groups.
--Parameters:
--IN:
--IN OUT:
--  x_processing_row_tbl
--    the procedure will only process rows which have non-empty
--    values in this pl/sql table
--  x_attr_values_tlp
--    record containing all attr values tlp info within the batch
--OUT:
--  x_create_row_tbl
--    index of rows to be created in current group
--  x_update_row_tbl
--    index of rows to be updated in cuurent group
--  x_sync_attr_tlp_id_tbl
--    list of attr_value_tlp_ids of rows that need to be read from txn table
--    into draft table
--  x_sync_draft_id_tbl
--    corresponding draft_ids of rows that will be read from txn table
--    into draft table
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE check_attr_tlp_actions
(
  x_processing_row_tbl       IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_attr_values_tlp          IN OUT NOCOPY PO_PDOI_TYPES.attr_values_tlp_rec_type,
  x_merge_row_tbl            OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_sync_attr_tlp_id_tbl     OUT NOCOPY PO_TBL_NUMBER,
  x_sync_draft_id_tbl        OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'check_attr_tlp_actions';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- ket value used to identify records in po_session_gt table
  l_key          PO_SESSION_GT.key%TYPE;

  -- variables to save result read from po_session_gt
  l_index_tbl    PO_TBL_NUMBER;
  l_result_tbl   PO_TBL_NUMBER;
  l_source_tbl   PO_TBL_VARCHAR5; -- values can be 'draft' or 'txn'

  l_index        NUMBER;
  l_counter      NUMBER;

  l_po_line_id   NUMBER;
  l_lang         VARCHAR2(4);

  -- hash table to track whether rows with same po_line_id and language exist within batch
  TYPE attr_tlp_ref_type IS TABLE OF DBMS_SQL.NUMBER_TABLE INDEX BY VARCHAR2(4);
  l_attr_tlp_ref_tbl attr_tlp_ref_type;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'x_processing_row_tbl.COUNT',
                      x_processing_row_tbl.COUNT);
    l_index := x_processing_row_tbl.FIRST;
    WHILE (l_index IS NOT NULL)
    LOOP
      PO_LOG.proc_begin(d_module, 'to be processed row num', l_index);
      l_index := x_processing_row_tbl.NEXT(l_index);
    END LOOP;
  END IF;

  x_sync_attr_tlp_id_tbl  := PO_TBL_NUMBER();
  x_sync_draft_id_tbl     := PO_TBL_NUMBER();

  l_key := PO_CORE_S.get_session_gt_nextval;

  -- first check whether record exists in draft table
  FORALL i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key, num1, num2, char1)
  SELECT l_key,
         x_processing_row_tbl(i),
         attribute_values_tlp_id,
         'DRAFT'
  FROM   po_attribute_values_tlp_draft
  WHERE  draft_id = x_attr_values_tlp.draft_id_tbl(i)
  AND    po_line_id = x_attr_values_tlp.ln_po_line_id_tbl(i)
  AND    language = x_attr_values_tlp.language_tbl(i)
  AND    org_id = x_attr_values_tlp.org_id_tbl(i);

  d_position := 10;

  -- second check whether record exists in txn table
  -- it needs only to be done once since it won't change within batch processing
  IF (x_processing_row_tbl.COUNT = x_attr_values_tlp.rec_count) THEN

    d_position := 20;

    FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt(key, num1, num2, char1)
    SELECT l_key,
           x_processing_row_tbl(i),
           attribute_values_tlp_id,
           'TXN'
    FROM   po_attribute_values_tlp
    WHERE  po_line_id = x_attr_values_tlp.ln_po_line_id_tbl(i)
    AND    language = x_attr_values_tlp.language_tbl(i)
    AND    org_id = x_attr_values_tlp.org_id_tbl(i);
  END IF;

  -- retrieve result from po_session_gt table
  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1, num2, char1 BULK COLLECT INTO
    l_index_tbl, l_result_tbl, l_source_tbl;

  -- set attr_values_id in x_attr_values
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'current source exist?',
                  x_attr_values_tlp.source_tbl.EXISTS(l_index));
      IF (x_attr_values_tlp.source_tbl.EXISTS(l_index)) THEN
        PO_LOG.stmt(d_module, d_position, 'current source',
                    x_attr_values_tlp.source_tbl(l_index));
      END IF;
      PO_LOG.stmt(d_module, d_position, 'attr values id',
                  l_result_tbl(i));
      PO_LOG.stmt(d_module, d_position, ' new source',
                  l_source_tbl(i));
    END IF;

    -- draft record will override txn record
    IF ( NOT x_attr_values_tlp.source_tbl.EXISTS(l_index) OR
       x_attr_values_tlp.source_tbl(l_index) <> 'DRAFT') THEN
      x_attr_values_tlp.attribute_values_tlp_id_tbl(l_index) := l_result_tbl(i);
      x_attr_values_tlp.source_tbl(l_index) := l_source_tbl(i);
    END IF;
  END LOOP;

  d_position := 30;

  -- next, set actions on each record, if records with same po_line_id
  -- and language exist, process them in separate groups
  l_index := 0;
  l_counter := x_processing_row_tbl.FIRST;
  WHILE (l_counter IS NOT NULL)
  LOOP
    l_po_line_id := x_attr_values_tlp.ln_po_line_id_tbl(l_counter);
    l_lang := x_attr_values_tlp.language_tbl(l_counter);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'l_counter', l_counter);
      PO_LOG.stmt(d_module, d_position, 'l_po_line_id', l_po_line_id);
      PO_LOG.stmt(d_module, d_position, 'l_lang',l_lang);
    END IF;

    -- check whether there is row existing in hashtable
    IF (NOT l_attr_tlp_ref_tbl.EXISTS(l_lang) OR
        NOT l_attr_tlp_ref_tbl(l_lang).EXISTS(l_po_line_id)) THEN

--    IF (l_attr_tlp_ref_tbl(l_lang)(l_po_line_id) IS NULL) THEN
      -- register it in the hashtbale
      l_attr_tlp_ref_tbl(l_lang)(l_po_line_id) := l_counter;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'row is handled in current loop');
        PO_LOG.stmt(d_module, d_position, 'attr values tlp id',
                    x_attr_values_tlp.attribute_values_tlp_id_tbl(l_counter));
      END IF;

      -- set actions
      IF (x_attr_values_tlp.attribute_values_tlp_id_tbl(l_counter) IS NOT NULL) THEN
        -- row existing in draft or txn tables
        x_merge_row_tbl(l_counter) := l_counter;

        -- for UPDATE action, track the rows that need to be synced from
        -- txn table
        IF (x_attr_values_tlp.source_tbl(l_counter) = 'TXN') THEN
          l_index := l_index + 1;
          x_sync_attr_tlp_id_tbl.EXTEND;
          x_sync_draft_id_tbl.EXTEND;
          x_sync_attr_tlp_id_tbl(l_index) := x_attr_values_tlp.attribute_values_tlp_id_tbl(l_counter);
          x_sync_draft_id_tbl(l_index) := x_attr_values_tlp.draft_id_tbl(l_counter);
        END IF;
      ELSE
        -- it is a new row
        x_merge_row_tbl(l_counter) := l_counter;
      END IF;

      -- mark rows as processed
      x_processing_row_tbl.DELETE(l_counter);
    END IF; -- IF (l_attr_tlp_ref_tbl(l_lang)(l_po_line_id) IS NULL)

    l_counter := x_processing_row_tbl.NEXT(l_counter);
  END LOOP;

  --Bug12980629
  x_attr_values_tlp.source_tbl.DELETE;

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
END check_attr_tlp_actions;

-------------------------------------------------------------------------
--Start of Comments
--Name: add_default_attrs
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  add default attr_values and attr_values_tlp rows if not provided;
--  the procedure is only called when line is created
--Parameters:
--IN:
--IN OUT:
--OUT: None
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE add_default_attrs
IS

  d_api_name CONSTANT VARCHAR2(30) := 'add_default_attrs';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_draft_id_tbl       PO_TBL_NUMBER;
  l_po_line_id_tbl     PO_TBL_NUMBER;
  l_item_id_tbl        PO_TBL_NUMBER;
  l_ip_category_id_tbl PO_TBL_NUMBER;
  l_item_desc_tbl      PO_TBL_VARCHAR2000;
  l_created_lang_tbl   PO_TBL_VARCHAR5;

  -- Bug7039409: Declared new variables
  l_master_org_id      PO_ATTRIBUTE_VALUES.org_id%TYPE;
  l_inv_org_id         PO_ATTRIBUTE_VALUES.org_id%TYPE;
  l_item_id_tbl2       PO_TBL_NUMBER; -- Different from l_item_id_tbl
  l_lead_time_tbl      PO_TBL_NUMBER;
  l_mfg_part_num_tbl   PO_TBL_VARCHAR2000;
  l_mfg_name_tbl       PO_TBL_VARCHAR2000;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- Bug7039409: Get master_org_id and inv_org_id
  -- Use master org to get mfg_part_num, manufacturer_name and long_description
  -- as these are Master level attributes.
  -- Use inventory org to get full_lead_time as this is Org level attribute.
  SELECT mtl.master_organization_id,
         fsp.inventory_organization_id
  INTO   l_master_org_id,
         l_inv_org_id
  FROM   mtl_parameters mtl,
         financials_system_parameters fsp
  WHERE  fsp.inventory_organization_id = mtl.organization_id;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_master_org_id', l_master_org_id);
    PO_LOG.stmt(d_module, d_position, 'l_inv_org_id', l_inv_org_id);
  END IF;

  -- get lines for which default attr and attr_tlp rows need to be created
  SELECT draft_lines.draft_id,
         draft_lines.po_line_id,
         draft_lines.item_id,
         draft_lines.ip_category_id,
         draft_lines.item_description,
         NVL(draft_headers.created_language, txn_headers.created_language),
         msi.full_lead_time                 -- Bug7039409: Get the lead time also
  BULK COLLECT INTO
         l_draft_id_tbl,
         l_po_line_id_tbl,
         l_item_id_tbl,
         l_ip_category_id_tbl,
         l_item_desc_tbl,
         l_created_lang_tbl,
         l_lead_time_tbl -- Bug7039409: Get lead time into l_lead_time_tbl
  FROM   po_lines_interface intf_lines,
         po_headers_interface intf_headers,
         po_lines_draft_all draft_lines,
         po_headers_draft_all draft_headers,
         po_headers_all txn_headers,
         mtl_system_items_b msi             -- Bug7039409: Added to get lead time
  WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
  AND    intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
  AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
  AND    intf_lines.action = PO_PDOI_CONSTANTS.g_ACTION_ADD
  AND    intf_lines.po_line_id = draft_lines.po_line_id
  AND    intf_headers.draft_id = draft_lines.draft_id
  AND    draft_lines.po_header_id = draft_headers.po_header_id(+)
  AND    draft_lines.draft_id = draft_headers.draft_id(+)
  AND    draft_lines.po_header_id = txn_headers.po_header_id(+)
  -- Added for Bug 6503535 -- Start --
  -- Exclude the entries for shipments and price-breaks
  AND    intf_lines.shipment_num IS NULL
  AND    intf_lines.shipment_type IS NULL
  -- Added for Bug 6503535 --  End  --
  AND    msi.inventory_item_id (+)= draft_lines.item_id    -- Bug7039409: Join msi
  AND    msi.organization_id (+)= l_inv_org_id             -- Bug7039409: Join msi
  AND    NOT EXISTS
             (SELECT 1
              FROM   po_attribute_values_draft
              WHERE  po_line_id = draft_lines.po_line_id
              AND    draft_id = draft_lines.draft_id);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_draft_id_tbl', l_draft_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_po_line_id_tbl', l_po_line_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_item_id_tbl', l_item_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_ip_category_id_tbl',
                l_ip_category_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_item_desc_tbl', l_item_desc_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_lead_time_tbl', l_lead_time_tbl);
  END IF;
  d_position := 10;

  -- create default attr rows
  FORALL i IN 1..l_draft_id_tbl.COUNT
    INSERT INTO po_attribute_values_draft
    (
      ATTRIBUTE_VALUES_ID,
      DRAFT_ID,
      PO_LINE_ID,
      REQ_TEMPLATE_NAME,
      REQ_TEMPLATE_LINE_NUM,
      IP_CATEGORY_ID,
      INVENTORY_ITEM_ID,
      ORG_ID,
      LEAD_TIME,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
    )
    VALUES
    (
      PO_ATTRIBUTE_VALUES_S.nextval,
      l_draft_id_tbl(i),
      l_po_line_id_tbl(i),
      '-2', -- REQ_TEMPLATE_NAME
      -2,   --REQ_TEMPLATE_LINE_NUM
      NVL(l_ip_category_id_tbl(i), -2),
      NVL(l_item_id_tbl(i), -2),
      PO_PDOI_PARAMS.g_request.org_id,
      l_lead_time_tbl(i),               -- Bug7039409: LEAD_TIME
      FND_GLOBAL.login_id,
      FND_GLOBAL.user_id,
      sysdate,
      FND_GLOBAL.user_id,
      sysdate,
      FND_GLOBAL.conc_request_id,
      FND_GLOBAL.prog_appl_id,
      FND_GLOBAL.conc_program_id,
      sysdate
    );

  d_position := 20;

  -- create default attr_tlp rows in document created languages
  FORALL i IN 1..l_draft_id_tbl.COUNT
    INSERT INTO po_attribute_values_tlp_draft
    (
      ATTRIBUTE_VALUES_TLP_ID,
      DRAFT_ID,
      PO_LINE_ID,
      REQ_TEMPLATE_NAME,
      REQ_TEMPLATE_LINE_NUM,
      IP_CATEGORY_ID,
      INVENTORY_ITEM_ID,
      ORG_ID,
      LANGUAGE,
      DESCRIPTION,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE
    )
    VALUES
    (
      PO_ATTRIBUTE_VALUES_TLP_S.nextval,
      l_draft_id_tbl(i),
      l_po_line_id_tbl(i),
      '-2', -- REQ_TEMPLATE_NAME
      -2,   --REQ_TEMPLATE_LINE_NUM
      NVL(l_ip_category_id_tbl(i), -2),
      NVL(l_item_id_tbl(i), -2),
      PO_PDOI_PARAMS.g_request.org_id,
      l_created_lang_tbl(i),
      l_item_desc_tbl(i),
      FND_GLOBAL.login_id,
      FND_GLOBAL.user_id,
      sysdate,
      FND_GLOBAL.user_id,
      sysdate,
      FND_GLOBAL.conc_request_id,
      FND_GLOBAL.prog_appl_id,
      FND_GLOBAL.conc_program_id,
      sysdate
    );

  d_position := 30;

  -- Bug7039409: get mfg_part_num and mfg_name values where exists
  SELECT mmpn.inventory_item_id,
         mmpn.mfg_part_num,
         mmpn.manufacturer_name
  BULK COLLECT INTO l_item_id_tbl2,
         l_mfg_part_num_tbl,
         l_mfg_name_tbl
  FROM   mtl_mfg_part_numbers_all_v mmpn
  WHERE  row_id IN (SELECT   MIN(mmpn2.row_id)
                    FROM     mtl_mfg_part_numbers_all_v mmpn2,
                             po_attribute_values_draft pavd
                    WHERE    pavd.inventory_item_id = mmpn2.inventory_item_id
                             AND mmpn2.organization_id = l_master_org_id
                             AND pavd.request_id = fnd_global.conc_request_id
                             AND pavd.program_application_id = fnd_global.prog_appl_id
                             AND pavd.program_id = fnd_global.conc_program_id
                    GROUP BY pavd.inventory_item_id);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_item_id_tbl2', l_item_id_tbl2);
    PO_LOG.stmt(d_module, d_position, 'l_mfg_part_num_tbl', l_mfg_part_num_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_mfg_name_tbl', l_mfg_name_tbl);
  END IF;

  -- Bug7039409: update po_attribute_values_draft.manufacturer_part_num
  FORALL i IN 1..l_item_id_tbl2.COUNT
      UPDATE po_attribute_values_draft
      SET    manufacturer_part_num = l_mfg_part_num_tbl(i)
      WHERE  inventory_item_id = l_item_id_tbl2(i)
             AND org_id = l_master_org_id
             AND request_id = fnd_global.conc_request_id
             AND program_application_id = fnd_global.prog_appl_id
             AND program_id = fnd_global.conc_program_id;

  -- Bug7039409: update po_attribute_values_tlp_draft.manufacturer
  FORALL i IN 1..l_item_id_tbl2.COUNT
      UPDATE po_attribute_values_tlp_draft
      SET    manufacturer = l_mfg_name_tbl(i)
      WHERE  inventory_item_id = l_item_id_tbl2(i)
             AND org_id = l_master_org_id
             AND request_id = fnd_global.conc_request_id
             AND program_application_id = fnd_global.prog_appl_id
             AND program_id = fnd_global.conc_program_id;

  -- Bug7039409: update po_attribute_values_tlp_draft.long_description
  -- Bug7722053: Added the condition to check the long desc value
  UPDATE po_attribute_values_tlp_draft pavd_tlp
  SET    long_description = (SELECT long_description
                             FROM   mtl_system_items_tl msi_tl,
                                    fnd_languages lang
                             WHERE  msi_tl.inventory_item_id = pavd_tlp.inventory_item_id
                                    AND msi_tl.organization_id = l_master_org_id
                                    AND msi_tl.language = NVL(pavd_tlp.language,lang.language_code)
                                    AND lang.installed_flag = 'B')
  WHERE  pavd_tlp.request_id = fnd_global.conc_request_id
         AND pavd_tlp.program_application_id = fnd_global.prog_appl_id
         AND pavd_tlp.program_id = fnd_global.conc_program_id
         AND pavd_tlp.long_description IS NULL;

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
END add_default_attrs;

END PO_PDOI_ATTR_PROCESS_PVT;

/
