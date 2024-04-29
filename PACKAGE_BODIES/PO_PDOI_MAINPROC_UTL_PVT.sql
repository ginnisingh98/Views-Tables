--------------------------------------------------------
--  DDL for Package Body PO_PDOI_MAINPROC_UTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_MAINPROC_UTL_PVT" AS
/* $Header: PO_PDOI_MAINPROC_UTL_PVT.plb 120.14.12010000.6 2013/10/15 11:45:20 inagdeo ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_MAINPROC_UTL_PVT');

-- max line number for each document
g_max_line_num_tbl DBMS_SQL.number_table;

-- max shipment number for each line
g_max_shipment_num_tbl DBMS_SQL.number_table;

-- max distribution number for each shipment
g_max_dist_num_tbl DBMS_SQL.number_table;

-- max price differential number for each entity_type plus entity_id combination
TYPE max_price_diff_num_type IS TABLE OF DBMS_SQL.number_table INDEX BY VARCHAR2(30);
g_max_price_diff_num_tbl max_price_diff_num_type;

-- cache for quotation_class_code based on document subtype
TYPE quotation_class_code_type IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
g_quotation_class_code_tbl quotation_class_code_type;

--------------------------------------------------------------------------
---------------------- PUBLIC PROCEDURES ---------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--Start of Comments
--Name: get_quotation_class_code
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  set up cache for quotation_class_code based on subtype;
--  the cache is set up on demand and will persist per group
--Parameters:
--IN:
--  p_subtype
--    the subtype of the document
--IN OUT: None
--OUT: None
--Returns:
--  the quotation_class_code value for a particular subtype
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE cleanup IS

  d_api_name CONSTANT VARCHAR2(30) := 'cleanup';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  g_max_line_num_tbl.DELETE;

  g_max_shipment_num_tbl.DELETE;

  g_max_dist_num_tbl.DELETE;

  g_max_price_diff_num_tbl.DELETE;

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
END cleanup;
--------------------------------------------------------------------------
--Start of Comments
--Name: get_quotation_class_code
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  set up cache for quotation_class_code based on subtype;
--  the cache is set up on demand and will persist per group
--Parameters:
--IN:
--  p_subtype
--    the subtype of the document
--IN OUT: None
--OUT: None
--Returns:
--  the quotation_class_code value for a particular subtype
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
FUNCTION get_quotation_class_code
(
  p_doc_subtype IN VARCHAR2
)RETURN VARCHAR2
IS

  d_api_name CONSTANT VARCHAR2(30) := 'get_quotation_class_code';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variable to hold query result
  l_quotation_class_code VARCHAR2(25);

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_doc_subtype', p_doc_subtype);
  END IF;

  IF (g_quotation_class_code_tbl.COUNT = 0 OR
      g_quotation_class_code_tbl.EXISTS(p_doc_subtype) = FALSE) THEN
    d_position := 10;

    -- query database if requested value is not cached
    SELECT quotation_class_code
    INTO   l_quotation_class_code
    FROM   po_document_types
    WHERE  document_type_code = PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION
    AND    document_subtype = p_doc_subtype;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'l_quotation_class_code',
                  l_quotation_class_code);
    END IF;

    d_position := 20;

    -- save the result in cache
    g_quotation_class_code_tbl(p_doc_subtype) := l_quotation_class_code;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return (d_module, g_quotation_class_code_tbl(p_doc_subtype));
  END IF;

  RETURN g_quotation_class_code_tbl(p_doc_subtype);

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END get_quotation_class_code;

--------------------------------------------------------------------------
--Start of Comments
--Name: calculate_max_line_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  calculate current maximal line number for each document;
--  the cache is set up in each batch and will persist per group
--Parameters:
--IN:
--  p_po_header_id_tbl
--    list of document header id for which max line number need
--    ro be calculated
--  p_draft_id_tbl
--    draft id value for each po_header_id in the p_po_header_id_tbl
--IN OUT: None
--OUT: None
--Returns: none
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE calculate_max_line_num
(
  p_po_header_id_tbl    IN PO_TBL_NUMBER,
  p_draft_id_tbl        IN PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'calculate_max_line_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key              po_session_gt.key%TYPE;
  l_po_header_id_tbl PO_TBL_NUMBER;
  l_max_line_num_tbl PO_TBL_NUMBER;

  l_processing_row_tbl      DBMS_SQL.number_table;
  l_po_header_id_no_dup_tbl DBMS_SQL.number_table;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_po_header_id_tbl', p_po_header_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_draft_id_tbl', p_draft_id_tbl);
  END IF;

  -- No need to calculate max line number for following two cases:
  -- 1. the max line number has already been cached before;
  -- 2. same po_header_id appears more than once, then the max line
  --    number only needs to be calculated once
  FOR i IN 1..p_po_header_id_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      PO_LOG.stmt(d_module, d_position, 'calculated already?',
                  g_max_line_num_tbl.EXISTS(p_po_header_id_tbl(i)));
      PO_LOG.stmt(d_module, d_position, 'duplicate id?',
                  l_po_header_id_no_dup_tbl.EXISTS(p_po_header_id_tbl(i)));
    END IF;

    IF (g_max_line_num_tbl.EXISTS(p_po_header_id_tbl(i))) THEN
      NULL;
    ELSIF (l_po_header_id_no_dup_tbl.EXISTS(p_po_header_id_tbl(i))) THEN
      NULL;
    ELSE
      -- register the po_header_id in hash table
      l_po_header_id_no_dup_tbl(p_po_header_id_tbl(i)) := i;

      -- need to calculate max line number for this po_header_id
      l_processing_row_tbl(i) := i;
    END IF;
  END LOOP;

  d_position := 10;

  -- pick a new key for temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- search in txn table
  FORALL i IN INDICES OF l_processing_row_tbl
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT l_key,
           p_po_header_id_tbl(i),
           v.max_line_num
    FROM   (SELECT max(line_num) AS max_line_num
            FROM   po_lines_all
            WHERE  po_header_id = p_po_header_id_tbl(i)) v
    WHERE   v.max_line_num IS NOT NULL;

  d_position := 20;

  -- search in draft table
  FORALL i IN INDICES OF l_processing_row_tbl
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT l_key,
           p_po_header_id_tbl(i),
           v.max_line_num
    FROM   (SELECT max(line_num) AS max_line_num
            FROM   po_lines_draft_all draft_lines
            WHERE  draft_id = p_draft_id_tbl(i)
            AND    po_header_id = p_po_header_id_tbl(i)) v
    WHERE   v.max_line_num IS NOT NULL;

  d_position := 30;

  -- search interface table
  FORALL i IN INDICES OF l_processing_row_tbl
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT l_key,
           p_po_header_id_tbl(i),
           v.max_line_num
    FROM   (SELECT /*+ INDEX(intf_headers PO_HEADERS_INTERFACE_N5) */   -- Added as 9799280 fix
	    max(intf_lines.line_num) AS max_line_num
            FROM   po_lines_interface intf_lines,
                   po_headers_interface intf_headers
            WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
            AND    intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
            AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
            AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
	    AND intf_headers.po_header_id IS NOT NULL AND p_po_header_id_tbl(i) IS NOT NULL   -- Added as part of 9799280 to handle & avoid NULL cases
            AND    intf_headers.po_header_id = p_po_header_id_tbl(i)) v
    WHERE   v.max_line_num IS NOT NULL;

  d_position := 40;

  -- set max_line_num in cache
  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, num2 BULK COLLECT INTO l_po_header_id_tbl, l_max_line_num_tbl;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_po_header_id_tbl', l_po_header_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_max_line_num_tbl', l_max_line_num_tbl);
  END IF;

  FOR i IN 1..l_po_header_id_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
    END IF;

    IF (g_max_line_num_tbl.EXISTS(l_po_header_id_tbl(i))) THEN
      IF (l_max_line_num_tbl(i) > g_max_line_num_tbl(l_po_header_id_tbl(i))) THEN
        g_max_line_num_tbl(l_po_header_id_tbl(i)) := l_max_line_num_tbl(i);
      END IF;
    ELSE
      g_max_line_num_tbl(l_po_header_id_tbl(i)) := l_max_line_num_tbl(i);
    END IF;
  END LOOP;

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
END calculate_max_line_num;

--------------------------------------------------------------------------
--Start of Comments
--Name: get_next_line_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  this procedure is called when customer does not assign line number
--  or they assign duplicate line numbers to po lines;
--Parameters:
--IN:
--  p_po_header_id
--    document header id for which new line number needs to be assigned
--IN OUT: None
--OUT: None
--Returns:
--  unique line number that can be assigned to a new po line
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
FUNCTION get_next_line_num
(
  p_po_header_id IN NUMBER
)
RETURN NUMBER
IS

  d_api_name CONSTANT VARCHAR2(30) := 'get_next_line_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
  END IF;

  IF (g_max_line_num_tbl.EXISTS(p_po_header_id)) THEN
    g_max_line_num_tbl(p_po_header_id) := g_max_line_num_tbl(p_po_header_id) + 1;
  ELSE
    g_max_line_num_tbl(p_po_header_id) := 1;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return (d_module, g_max_line_num_tbl(p_po_header_id));
  END IF;

  RETURN g_max_line_num_tbl(p_po_header_id);
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END get_next_line_num;

--------------------------------------------------------------------------
--Start of Comments
--Name: get_next_po_line_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  get a new po line id from sequence
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--  unique po line id from sequence po_lines_s
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
FUNCTION get_next_po_line_id
RETURN NUMBER
IS

  d_api_name CONSTANT VARCHAR2(30) := 'get_next_po_line_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_next_po_line_id NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT po_lines_s.nextval
  INTO   l_next_po_line_id
  FROM DUAL;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_next_po_line_id);
  END IF;

  RETURN l_next_po_line_id;
END get_next_po_line_id;

--------------------------------------------------------------------------
--Start of Comments
--Name: check_line_num_unique
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  check whether the provided line numbers are unique accross the document
--Parameters:
--IN:
--  p_po_header_id_tbl
--    list of po_header_ids within the batch
--  p_draft_id_tbl
--    list of draft_ids within the batch
--  p_intf_line_id_tbl
--    list of interface line ids within the batch
--  p_line_num_tbl
--    list of line numbers within the batch
--IN OUT:
--  x_line_num_unique_tbl
--    boolean table to mark whether the provided line number is unique
--OUT: None
--Returns: None
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE check_line_num_unique
(
  p_po_header_id_tbl    IN PO_TBL_NUMBER,
  p_draft_id_tbl        IN PO_TBL_NUMBER,
  p_intf_line_id_tbl    IN PO_TBL_NUMBER,
  p_line_num_tbl        IN PO_TBL_NUMBER,
  x_line_num_unique_tbl OUT NOCOPY PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'check_line_num_unique';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index_tbl  DBMS_SQL.number_table;

  l_key       po_session_gt.key%TYPE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_po_header_id_tbl', p_po_header_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_draft_id_tbl', p_draft_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_intf_line_id_tbl', p_intf_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_line_num_tbl', p_line_num_tbl);
  END IF;

  x_line_num_unique_tbl := PO_TBL_VARCHAR1();
  x_line_num_unique_tbl.EXTEND(p_line_num_tbl.COUNT);

  -- pick a new key for temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize index table
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size      => p_po_header_id_tbl.COUNT,
    x_num_list  => l_index_tbl
  );

  -- check draft table
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT l_key,
           l_index_tbl(i)
    FROM   po_lines_draft_all
    WHERE  po_header_id = p_po_header_id_tbl(i)
    AND    draft_id = p_draft_id_tbl(i)
    AND    line_num = p_line_num_tbl(i);

  d_position := 10;

  -- check txn table
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT l_key,
           l_index_tbl(i)
    FROM   po_lines_all
    WHERE  po_header_id = p_po_header_id_tbl(i)
    AND    line_num = p_line_num_tbl(i);

  d_position := 20;

  -- check interface table records which is before current records
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT l_key,
           l_index_tbl(i)
    FROM   po_lines_interface intf_lines,
           po_headers_interface intf_headers
    WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
    AND    intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
    AND    intf_headers.processing_round_num =
             PO_PDOI_PARAMS.g_current_round_num
    AND    intf_headers.po_header_id = p_po_header_id_tbl(i)
    AND    intf_lines.interface_line_id < p_intf_line_id_tbl(i)
    AND    intf_lines.interface_line_id >= p_intf_line_id_tbl(1)
    AND    intf_lines.line_num = p_line_num_tbl(i)
    AND intf_headers.po_header_id IS NOT NULL AND p_po_header_id_tbl(i) IS NOT NULL; -- Added as 9799280 fix to handle & avoid NULL cases.

  d_position := 30;

  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'line num is not unique',
                  p_line_num_tbl(l_index_tbl(i)));
    END IF;

    x_line_num_unique_tbl(l_index_tbl(i)) := FND_API.g_FALSE;
  END LOOP;

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
END check_line_num_unique;

--------------------------------------------------------------------------
--Start of Comments
--Name: calculate_max_shipment_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  calculate maximal shipment number for each line and cache the result
--Parameters:
--IN:
--  p_po_line_id_tbl
--    list of po line ids for which maximal shipment number need to
--    be calculated
--  p_draft_id_tbl
--    draft id value for each po_line_id in p_po_line_id_tbl;
--    used to query draft table
--IN OUT: None
--OUT: None
--Returns: None
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE calculate_max_shipment_num
(
  p_po_line_id_tbl      IN PO_TBL_NUMBER,
  p_draft_id_tbl        IN PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'calculate_max_shipment_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key                  po_session_gt.key%TYPE;
  l_po_line_id_tbl       PO_TBL_NUMBER;
  l_max_shipment_num_tbl PO_TBL_NUMBER;

  l_processing_row_tbl      DBMS_SQL.number_table;
  l_po_line_id_no_dup_tbl   DBMS_SQL.number_table;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_po_line_id_tbl', p_po_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_draft_id_tbl', p_draft_id_tbl);
  END IF;

  -- No need to calculate max shipment number for following two cases:
  -- 1. the max shipment number has already been cached before;
  -- 2. same po_line_id appears more than once, then the max shipment
  --    number only needs to be calculated once
  FOR i IN 1..p_po_line_id_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      PO_LOG.stmt(d_module, d_position, 'already calculated?',
                  g_max_shipment_num_tbl.EXISTS(p_po_line_id_tbl(i)));
      PO_LOG.stmt(d_module, d_position, 'duplicate id?',
                  l_po_line_id_no_dup_tbl.EXISTS(p_po_line_id_tbl(i)));
    END IF;

    IF (g_max_shipment_num_tbl.EXISTS(p_po_line_id_tbl(i))) THEN
      NULL;
    ELSIF (l_po_line_id_no_dup_tbl.EXISTS(p_po_line_id_tbl(i))) THEN
      NULL;
    ELSE
      -- register the po_line_id in hash table
      l_po_line_id_no_dup_tbl(p_po_line_id_tbl(i)) := i;

      -- need to calculate max line number for this po_line_id
      l_processing_row_tbl(i) := i;
    END IF;
  END LOOP;

  -- pick a new key for temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- bug 4642348:
  --   if document type is QUOTATION, there is no need to
  --   search the txn table since existing price breaks
  --   will always be removed.
  --   Remove the QUOTATION constant from the following
  --   'IF' statement.

  -- search in txn table only for blanket
  -- for SPO, there is never existing shipments
  -- for quotation, existing price breaks will be removed

  -- <<PDOI Enhancement Bug#17063664 - Commenting the condition for BLANKET,
  --    so that max shipment number from transaction tables will be fetched
  --    for all the document types>>
  /*IF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN   */
    d_position := 10;

    FORALL i IN INDICES OF l_processing_row_tbl
      INSERT INTO po_session_gt(key, num1, num2)
      SELECT l_key,
             p_po_line_id_tbl(i),
             v.max_shipment_num
      FROM   (SELECT max(shipment_num) AS max_shipment_num
              FROM   po_line_locations_all
              WHERE  po_line_id = p_po_line_id_tbl(i)) v
      WHERE   v.max_shipment_num IS NOT NULL;
  /*END IF;*/

  d_position := 20;

  -- bug 4642348:
  --  add filter on delete_flag since records with flag
  --  equal to 'Y' would be deleted eventually and should
  --  not be counted here

  -- search in draft table
  FORALL i IN INDICES OF l_processing_row_tbl
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT l_key,
           p_po_line_id_tbl(i),
           v.max_shipment_num
    FROM   (SELECT max(shipment_num) AS max_shipment_num
            FROM   po_line_locations_draft_all
            WHERE  draft_id = p_draft_id_tbl(i)
            AND    po_line_id = p_po_line_id_tbl(i)
            AND    NVL(delete_flag, 'N') = 'N') v
    WHERE   v.max_shipment_num IS NOT NULL;

  d_position := 30;

  -- bug4703480
  -- Add optimizer hint to ensure execution sequence

  /* Bug 6940325 Added the clause "AND intf_lines.po_line_id IS ....."  to ensure the index PO_LINES_INTERFACE_N8 is picked.
      This fix is done as the CBO was starting from the po_line_locations_interface index.*/

        -- search interface table
  --<Bug 16885904>: added hints
  FORALL i IN INDICES OF l_processing_row_tbl
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT l_key,
           p_po_line_id_tbl(i),
           v.max_shipment_num
    FROM   (SELECT /*+ LEADING(intf_lines) USE_NL(intf_locs) USE_NL(intf_headers) INDEX(intf_lines PO_LINES_INTERFACE_N8) INDEX(intf_locs PO_LINE_LOCATIONS_INTERFACE_N2) INDEX(intf_headers PO_HEADERS_INTERFACE_U1) */
                   max(intf_locs.shipment_num) AS max_shipment_num
            FROM   po_line_locations_interface intf_locs,
                   po_lines_interface intf_lines,
                   po_headers_interface intf_headers
            WHERE  intf_locs.interface_line_id = intf_lines.interface_line_id
            AND    intf_lines.interface_header_id = intf_headers.interface_header_id
            AND    intf_locs.processing_id = PO_PDOI_PARAMS.g_processing_id
            AND    intf_headers.processing_round_num =
                     PO_PDOI_PARAMS.g_current_round_num
            AND    intf_lines.po_line_id = p_po_line_id_tbl(i)
            AND intf_lines.po_line_id IS NOT NULL AND p_po_line_id_tbl(i) IS NOT NULL  ) v
    WHERE   v.max_shipment_num IS NOT NULL;

  d_position := 40;

  -- set max_shipment_num in cache
  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, num2 BULK COLLECT INTO l_po_line_id_tbl, l_max_shipment_num_tbl;

  FOR i IN 1..l_po_line_id_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      IF (g_max_shipment_num_tbl.EXISTS(l_po_line_id_tbl(i))) THEN
        PO_LOG.stmt(d_module, d_position, 'current max shipment num',
                    g_max_shipment_num_tbl(l_po_line_id_tbl(i)));
      END IF;
      PO_LOG.stmt(d_module, d_position, 'max shipment num',
                  l_max_shipment_num_tbl(i));
    END IF;

    IF (g_max_shipment_num_tbl.EXISTS(l_po_line_id_tbl(i))) THEN
      IF (l_max_shipment_num_tbl(i) > g_max_shipment_num_tbl(l_po_line_id_tbl(i))) THEN
        g_max_shipment_num_tbl(l_po_line_id_tbl(i)) := l_max_shipment_num_tbl(i);
      END IF;
    ELSE
      g_max_shipment_num_tbl(l_po_line_id_tbl(i)) := l_max_shipment_num_tbl(i);
    END IF;
  END LOOP;

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
END calculate_max_shipment_num;

--------------------------------------------------------------------------
--Start of Comments
--Name: get_next_shipment_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  this procedure is called when customer does not assign shipment number
--  or they assign duplicate shipment numbers to po lines;
--Parameters:
--IN:
--  p_po_line_id
--    line identifier for which new shipment number needs to be assigned
--IN OUT: None
--OUT: None
--Returns:
--  a new shipment number which is unique for the po line
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
FUNCTION get_next_shipment_num
(
  p_po_line_id IN NUMBER
)
RETURN NUMBER
IS

  d_api_name CONSTANT VARCHAR2(30) := 'get_next_shipment_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_po_line_id', p_po_line_id);
  END IF;

  IF (g_max_shipment_num_tbl.EXISTS(p_po_line_id)) THEN
    g_max_shipment_num_tbl(p_po_line_id) := g_max_shipment_num_tbl(p_po_line_id) + 1;
  ELSE
    g_max_shipment_num_tbl(p_po_line_id) := 1;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, g_max_shipment_num_tbl(p_po_line_id));
  END IF;

  RETURN g_max_shipment_num_tbl(p_po_line_id);

END get_next_shipment_num;

--------------------------------------------------------------------------
--Start of Comments
--Name: get_next_line_loc_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  get new line location id from sequence
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--  new line location id from sequence po_line_locations_s
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
FUNCTION get_next_line_loc_id
RETURN NUMBER
IS

  d_api_name CONSTANT VARCHAR2(30) := 'get_next_line_loc_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_next_line_loc_id NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT po_line_locations_s.nextval
  INTO   l_next_line_loc_id
  FROM   DUAL;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_next_line_loc_id);
  END IF;

  RETURN l_next_line_loc_id;
END get_next_line_loc_id;

--------------------------------------------------------------------------
--Start of Comments
--Name: check_shipment_num_unique
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  check whether the provided shipment numbers are unique accross the line
--Parameters:
--IN:
--  p_po_line_id_tbl
--    list of po_line_ids within the batch
--  p_intf_line_loc_id_tbl
--    list of interface line location ids within the batch
--  p_shipment_num_tbl
--    list of shipment numbers within the batch
--IN OUT:
--  x_shipment_num_unique_tbl
--    boolean table to mark whether the provided shipment number is unique
--OUT: None
--Returns: None
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE check_shipment_num_unique
(
  p_po_line_id_tbl          IN PO_TBL_NUMBER,
  p_draft_id_tbl            IN PO_TBL_NUMBER,
  p_intf_line_loc_id_tbl    IN PO_TBL_NUMBER,
  p_shipment_num_tbl        IN PO_TBL_NUMBER,
  x_shipment_num_unique_tbl OUT NOCOPY PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'check_shipment_num_unique';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index_tbl  DBMS_SQL.number_table;

  l_key       po_session_gt.key%TYPE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_po_line_id_tbl', p_po_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_draft_id_tbl', p_draft_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_intf_line_loc_id_tbl', p_intf_line_loc_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_shipment_num_tbl', p_shipment_num_tbl);
  END IF;

  x_shipment_num_unique_tbl := PO_TBL_VARCHAR1();
  x_shipment_num_unique_tbl.EXTEND(p_shipment_num_tbl.COUNT);

  -- pick a new key for temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize index table
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size      => p_po_line_id_tbl.COUNT,
    x_num_list  => l_index_tbl
  );

  -- check draft table
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT l_key,
           l_index_tbl(i)
    FROM   po_line_locations_draft_all
    WHERE  po_line_id = p_po_line_id_tbl(i)
    AND    draft_id = p_draft_id_tbl(i)
    AND    shipment_type = 'STANDARD'
    AND    shipment_num = p_shipment_num_tbl(i);

  d_position := 10;

  -- check txn table
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT l_key,
           l_index_tbl(i)
    FROM   po_line_locations_all
    WHERE  po_line_id = p_po_line_id_tbl(i)
    AND    shipment_type = 'STANDARD'
    AND    shipment_num = p_shipment_num_tbl(i);

  d_position := 20;

  /* Bug 6940325 Added the clause "AND intf_lines.po_line_id IS ....."  to improve the performance.
      This fix is done as the CBO was starting from the po_line_locations_interface index.
      Ideally search should start from po_lines_interface.*/

  -- check interface table records which is before current records
  --<Bug 16885904>: added hints
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT /*+ LEADING(intf_lines) USE_NL(intf_locs) USE_NL(intf_headers) INDEX(intf_lines PO_LINES_INTERFACE_N8) INDEX(intf_locs PO_LINE_LOCATIONS_INTERFACE_N2) INDEX(intf_headers PO_HEADERS_INTERFACE_U1) */ l_key,
           l_index_tbl(i)
    FROM   po_line_locations_interface intf_locs,
           po_lines_interface intf_lines,
           po_headers_interface intf_headers
    WHERE  intf_locs.interface_line_id = intf_lines.interface_line_id
    AND    intf_lines.interface_header_id = intf_headers.interface_header_id
    AND    intf_locs.processing_id = PO_PDOI_PARAMS.g_processing_id
    AND    intf_headers.processing_round_num =
             PO_PDOI_PARAMS.g_current_round_num
    AND    intf_lines.po_line_id = p_po_line_id_tbl(i)
    AND    intf_locs.interface_line_location_id < p_intf_line_loc_id_tbl(i)
    AND    intf_locs.interface_line_location_id >=  p_intf_line_loc_id_tbl(1)
    AND    intf_locs.shipment_num = p_shipment_num_tbl(i)
    AND    NVL(intf_locs.shipment_type, 'STANDARD') = 'STANDARD'
    AND    intf_lines.po_line_id IS NOT NULL AND p_po_line_id_tbl(i) IS NOT NULL;

  d_position := 30;

  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'shipment num is not unique',
                  p_shipment_num_tbl(l_index_tbl(i)));
    END IF;

    x_shipment_num_unique_tbl(l_index_tbl(i)) := FND_API.g_FALSE;
  END LOOP;

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
END check_shipment_num_unique;

--------------------------------------------------------------------------
--Start of Comments
--Name: calculate_max_dist_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  calculate maximal distribution number for each line location
--Parameters:
--IN:
--  p_line_loc_id_tbl
--    list of line location id for which maximal shipment number
--    needs to be calculated
--  p_draft_id_tbl
--    list of corresponding draft id value for each line location
--    id in p_line_loc_id_tbl
--IN OUT: None
--OUT: None
--Returns: None
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE calculate_max_dist_num
(
  p_line_loc_id_tbl      IN PO_TBL_NUMBER,
  p_draft_id_tbl         IN PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'calculate_max_dist_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key                  po_session_gt.key%TYPE;
  l_line_loc_id_tbl      PO_TBL_NUMBER;
  l_max_dist_num_tbl     PO_TBL_NUMBER;

  l_processing_row_tbl      DBMS_SQL.number_table;
  l_line_loc_id_no_dup_tbl  DBMS_SQL.number_table;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_line_loc_id_tbl', p_line_loc_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_draft_id_tbl', p_draft_id_tbl);
  END IF;

  -- No need to calculate max dist number for following two cases:
  -- 1. the max dist number has already been cached before;
  -- 2. same line_loc_id appears more than once, then the max dist
  --    number only needs to be calculated once
  FOR i IN 1..p_line_loc_id_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      PO_LOG.stmt(d_module, d_position, 'already calculated?',
                  g_max_dist_num_tbl.EXISTS(p_line_loc_id_tbl(i)));
      PO_LOG.stmt(d_module, d_position, 'duplicate id?',
                  l_line_loc_id_no_dup_tbl.EXISTS(p_line_loc_id_tbl(i)));
    END IF;

    IF (g_max_dist_num_tbl.EXISTS(p_line_loc_id_tbl(i))) THEN
      NULL;
    ELSIF (l_line_loc_id_no_dup_tbl.EXISTS(p_line_loc_id_tbl(i))) THEN
      NULL;
    ELSE
      -- register the po_line_id in hash table
      l_line_loc_id_no_dup_tbl(p_line_loc_id_tbl(i)) := i;

      -- need to calculate max dist number for this line_loc_id
      l_processing_row_tbl(i) := i;
    END IF;
  END LOOP;

  -- pick a new key for temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  d_position := 10;

  -- search in txn table
  FORALL i IN INDICES OF l_processing_row_tbl
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT l_key,
           p_line_loc_id_tbl(i),
           v.max_dist_num
    FROM   (SELECT max(distribution_num) AS max_dist_num
            FROM   po_distributions_all
            WHERE  line_location_id = p_line_loc_id_tbl(i)) v
    WHERE   v.max_dist_num IS NOT NULL;

  d_position := 20;

  -- search in draft table
  FORALL i IN INDICES OF l_processing_row_tbl
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT l_key,
           p_line_loc_id_tbl(i),
           v.max_dist_num
    FROM   (SELECT max(distribution_num) AS max_dist_num
            FROM   po_distributions_draft_all
            WHERE  draft_id = p_draft_id_tbl(i)
            AND    line_location_id = p_line_loc_id_tbl(i)) v
    WHERE   v.max_dist_num IS NOT NULL;

  d_position := 30;

  -- bug4703480
  -- Add optimizer hint to ensure execution sequence

  -- Bug6009113
  -- Adding the Leading Hint as per Apps Performance Team Suggestion

  -- search interface table
  -- <bug 16885904>: added hints
  FORALL i IN INDICES OF l_processing_row_tbl
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT l_key,
           p_line_loc_id_tbl(i),
           v.max_dist_num
    FROM   (SELECT /*+ LEADING(intf_locs) USE_NL(intf_dists) USE_NL(intf_headers) INDEX(intf_locs PO_LINE_LOCATIONS_INTERFACE_N4) INDEX(intf_dists PO_DISTRIBUTIONS_INTERFACE_N3) INDEX(intf_headers PO_HEADERS_INTERFACE_U1)
 */
                   max(intf_dists.distribution_num) AS max_dist_num
            FROM   po_distributions_interface intf_dists,
                   po_line_locations_interface intf_locs,
                   po_headers_interface intf_headers
            WHERE  intf_dists.interface_line_location_id =
                     intf_locs.interface_line_location_id
            AND    intf_locs.interface_header_id = intf_headers.interface_header_id
            AND    intf_dists.processing_id = PO_PDOI_PARAMS.g_processing_id
            AND    intf_headers.processing_round_num =
                     PO_PDOI_PARAMS.g_current_round_num
            AND    intf_locs.line_location_id = p_line_loc_id_tbl(i)) v
    WHERE   v.max_dist_num IS NOT NULL;

  d_position := 40;

  -- set max_distribution_num in cache
  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, num2 BULK COLLECT INTO l_line_loc_id_tbl, l_max_dist_num_tbl;

  FOR i IN 1..l_line_loc_id_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      IF (g_max_dist_num_tbl.EXISTS(l_line_loc_id_tbl(i))) THEN
        PO_LOG.stmt(d_module, d_position, 'current max dist num',
                    g_max_dist_num_tbl(l_line_loc_id_tbl(i)));
      END IF;
      PO_LOG.stmt(d_module, d_position, 'max dist num',
                  l_max_dist_num_tbl(i));
    END IF;

    IF (g_max_dist_num_tbl.EXISTS(l_line_loc_id_tbl(i))) THEN
      IF (l_max_dist_num_tbl(i) > g_max_dist_num_tbl(l_line_loc_id_tbl(i))) THEN
        g_max_dist_num_tbl(l_line_loc_id_tbl(i)) := l_max_dist_num_tbl(i);
      END IF;
    ELSE
      g_max_dist_num_tbl(l_line_loc_id_tbl(i)) := l_max_dist_num_tbl(i);
    END IF;
  END LOOP;

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
END calculate_max_dist_num;

--------------------------------------------------------------------------
--Start of Comments
--Name: get_next_dist_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  This procedure is to get a unique distribution number if
--  customer does not assign distribution number or assign
--  duplicate distribution number for the line location
--Parameters:
--IN:
--  p_line_loc_id
--    line location id for which a new dist number needs
--    to be assigned
--IN OUT: None
--OUT: None
--Returns:
--  unique distribution number across the line location
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
FUNCTION get_next_dist_num
(
  p_line_loc_id IN NUMBER
)
RETURN NUMBER
IS

  d_api_name CONSTANT VARCHAR2(30) := 'get_next_dist_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_line_loc_id', p_line_loc_id);
  END IF;

  IF (g_max_dist_num_tbl.EXISTS(p_line_loc_id)) THEN
    g_max_dist_num_tbl(p_line_loc_id) := g_max_dist_num_tbl(p_line_loc_id) + 1;
  ELSE
    g_max_dist_num_tbl(p_line_loc_id) := 1;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, g_max_dist_num_tbl(p_line_loc_id));
  END IF;

  RETURN g_max_dist_num_tbl(p_line_loc_id);
END get_next_dist_num;

--------------------------------------------------------------------------
--Start of Comments
--Name: get_next_dist_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  get next distribution id from sequence
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--  new distribution id from sequence po_distributions_s
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
FUNCTION get_next_dist_id
RETURN NUMBER
IS

  d_api_name CONSTANT VARCHAR2(30) := 'get_next_dist_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_next_dist_id NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT po_distributions_s.nextval
  INTO   l_next_dist_id
  FROM   DUAL;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_next_dist_id);
  END IF;

  RETURN l_next_dist_id;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END get_next_dist_id;

--------------------------------------------------------------------------
--Start of Comments
--Name: check_dist_num_unique
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  procedure to check whether the provided distribution number is
--  unique within the shipment
--Parameters:
--IN:
--  p_line_loc_id_tbl
--    list of line location id within the batch
--  p_draft_id_tbl
--    list of draft ids within the batch
--  p_intf_dist_id_tbl
--    list of interface distribution id within the batch
--  p_dist_num_tbl
--    list of distribution number within the batch
--IN OUT:
--  x_dist_num_unique_tbl
--    boolean table to mark whether the provided distribution
--    number is unique within the shipment
--OUT: None
--Returns: None
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE check_dist_num_unique
(
  p_line_loc_id_tbl     IN PO_TBL_NUMBER,
  p_draft_id_tbl        IN PO_TBL_NUMBER,
  p_intf_dist_id_tbl    IN PO_TBL_NUMBER,
  p_dist_num_tbl        IN PO_TBL_NUMBER,
  x_dist_num_unique_tbl OUT NOCOPY PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'check_dist_num_unique';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key po_session_gt.key%TYPE;

  l_index_tbl DBMS_SQL.NUMBER_TABLE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_line_loc_id_tbl', p_line_loc_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_draft_id_tbl', p_draft_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_intf_dist_id_tbl', p_intf_dist_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_dist_num_tbl', p_dist_num_tbl);
  END IF;

  x_dist_num_unique_tbl := PO_TBL_VARCHAR1();
  x_dist_num_unique_tbl.EXTEND(p_dist_num_tbl.COUNT);

  -- pick a new key from temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize index table
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size      => p_line_loc_id_tbl.COUNT,
    x_num_list  => l_index_tbl
  );

  -- check draft table
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT l_key,
           l_index_tbl(i)
    FROM   po_distributions_draft_all
    WHERE  line_location_id = p_line_loc_id_tbl(i)
    AND    draft_id = p_draft_id_tbl(i)
    AND    distribution_num = p_dist_num_tbl(i);

  d_position := 10;

  -- check txn table
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT l_key,
           l_index_tbl(i)
    FROM   po_distributions_all
    WHERE  line_location_id = p_line_loc_id_tbl(i)
    AND    distribution_num = p_dist_num_tbl(i);

  d_position := 20;

  -- Bug6009113
  -- Adding the Leading Hint as per Apps Performance Team Suggestion

  -- check interface table records which is before current records
  -- <bug 16885904>: added hints
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT /*+ LEADING(intf_locs) USE_NL(intf_dists) USE_NL(intf_headers) INDEX(intf_locs PO_LINE_LOCATIONS_INTERFACE_N4) INDEX(intf_dists PO_DISTRIBUTIONS_INTERFACE_N3) INDEX(intf_headers PO_HEADERS_INTERFACE_U1) */ l_key,
           l_index_tbl(i)
    FROM   po_distributions_interface intf_dists,
           po_line_locations_interface intf_locs,
           po_headers_interface intf_headers
    WHERE  intf_dists.interface_line_location_id =
             intf_locs.interface_line_location_id
    AND    intf_locs.interface_header_id = intf_headers.interface_header_id
    AND    intf_dists.processing_id = PO_PDOI_PARAMS.g_processing_id
    AND    intf_headers.processing_round_num =
             PO_PDOI_PARAMS.g_current_round_num
    AND    intf_locs.line_location_id = p_line_loc_id_tbl(i)
    AND    intf_dists.interface_distribution_id < p_intf_dist_id_tbl(i)
    AND    intf_dists.interface_distribution_id >= p_intf_dist_id_tbl(1)
    AND    intf_dists.distribution_num = p_dist_num_tbl(i);

  d_position := 30;

  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'dist number is not unique',
                  p_dist_num_tbl(l_index_tbl(i)));
    END IF;

    x_dist_num_unique_tbl(l_index_tbl(i)) := FND_API.g_FALSE;
  END LOOP;

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
END check_dist_num_unique;

--------------------------------------------------------------------------
--Start of Comments
--Name: calculate_max_price_diff_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  calculate maximal price differential number for each entity_type plus
--  entity_id combination
--Parameters:
--IN:
--  p_entity_type_tbl
--    list of entity types on which max price diff num needs to be
--    calculated
--  p_entity_id_tbl
--    list of entity ids on which maximal price diff number
--    needs to be calculated
--  p_draft_id_tbl
--    list of corresponding draft id value for each price differential
--    line
--  p_price_diff_num_tbl
--    list of original price diff nums provided by user
--IN OUT: None
--OUT: None
--Returns: None
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE calculate_max_price_diff_num
(
  p_entity_type_tbl      IN PO_TBL_VARCHAR30,
  p_entity_id_tbl        IN PO_TBL_NUMBER,
  p_draft_id_tbl         IN PO_TBL_NUMBER,
  p_price_diff_num_tbl   IN PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'calculate_max_price_diff_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key                        po_session_gt.key%TYPE;
  l_entity_type_tbl            PO_TBL_VARCHAR30;
  l_entity_id_tbl              PO_TBL_NUMBER;
  l_max_price_diff_num_tbl     PO_TBL_NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_entity_type_tbl', p_entity_type_tbl);
    PO_LOG.proc_begin(d_module, 'p_entity_id_tbl', p_entity_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_draft_id_tbl', p_draft_id_tbl);
  END IF;

  -- pick a new key for temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  d_position := 10;

  -- first, search in draft table for max price diff num
  FORALL i IN 1..p_entity_id_tbl.COUNT
    INSERT INTO po_session_gt(key, char1, num1, num2)
    SELECT l_key,
           p_entity_type_tbl(i),
           p_entity_id_tbl(i),
           v.max_price_diff_num
    FROM   (SELECT max(price_differential_num) AS max_price_diff_num
            FROM   po_price_diff_draft
            WHERE  draft_id = p_draft_id_tbl(i)
            AND    entity_type = p_entity_type_tbl(i)
            AND    entity_id = p_entity_id_tbl(i)) v
    WHERE   v.max_price_diff_num IS NOT NULL;

  d_position := 20;

  -- second, search in txn table for max price diff num
  FORALL i IN 1..p_entity_id_tbl.COUNT
    INSERT INTO po_session_gt(key, char1, num1, num2)
    SELECT l_key,
           p_entity_type_tbl(i),
           p_entity_id_tbl(i),
           v.max_price_diff_num
    FROM   (SELECT max(price_differential_num) AS max_price_diff_num
            FROM   po_price_differentials
            WHERE  entity_type = p_entity_type_tbl(i)
            AND    entity_id = p_entity_id_tbl(i)) v
    WHERE   v.max_price_diff_num IS NOT NULL;

  d_position := 30;

  -- set max price diff num in cache
  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING char1, num1, num2 BULK COLLECT INTO
    l_entity_type_tbl, l_entity_id_tbl, l_max_price_diff_num_tbl;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_entity_type_tbl', l_entity_type_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_entity_id_tbl', l_entity_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_max_price_diff_num_tbl',
	            l_max_price_diff_num_tbl);
  END IF;

  d_position := 40;

  FOR i IN 1..l_entity_type_tbl.COUNT
  LOOP
    IF (g_max_price_diff_num_tbl.EXISTS(l_entity_type_tbl(i)) AND
	    g_max_price_diff_num_tbl(l_entity_type_tbl(i)).EXISTS(l_entity_id_tbl(i))) THEN
      IF (l_max_price_diff_num_tbl(i) >
	        g_max_price_diff_num_tbl(l_entity_type_tbl(i))(l_entity_id_tbl(i))) THEN
        g_max_price_diff_num_tbl(l_entity_type_tbl(i))(l_entity_id_tbl(i)) :=
		  l_max_price_diff_num_tbl(i);
      END IF;
    ELSE
      g_max_price_diff_num_tbl(l_entity_type_tbl(i))(l_entity_id_tbl(i)) :=
	    l_max_price_diff_num_tbl(i);
    END IF;
  END LOOP;

  d_position := 50;

  -- last, search inside current batch
  FOR i IN 1..p_entity_type_tbl.COUNT
  LOOP
    IF (p_price_diff_num_tbl(i) IS NOT NULL AND
       p_entity_type_tbl(i) IS NOT NULL AND
       p_entity_id_tbl(i) IS NOT NULL) THEN
      IF (g_max_price_diff_num_tbl.EXISTS(p_entity_type_tbl(i)) AND
	      g_max_price_diff_num_tbl(p_entity_type_tbl(i)).EXISTS(p_entity_id_tbl(i))) THEN
        IF (p_price_diff_num_tbl(i) >
	          g_max_price_diff_num_tbl(p_entity_type_tbl(i))(p_entity_id_tbl(i))) THEN
          g_max_price_diff_num_tbl(p_entity_type_tbl(i))(p_entity_id_tbl(i)) :=
		    p_price_diff_num_tbl(i);
        END IF;
      ELSE
        g_max_price_diff_num_tbl(p_entity_type_tbl(i))(p_entity_id_tbl(i)) :=
	      p_price_diff_num_tbl(i);
      END IF;
    END IF;
  END LOOP;

  d_position := 60;

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
END calculate_max_price_diff_num;

--------------------------------------------------------------------------
--Start of Comments
--Name: get_next_price_diff_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  This procedure is to get a unique price differential number if
--  customer does not assign price differential number or assign
--  duplicate price differential number for the entity_type plus
--  entity_id combination
--Parameters:
--IN:
--  p_entity_id
--    entity id for which a new price differential number needs
--    to be assigned; This id can be either a po_line_id or
--    line_location_id depending on entity_type
--  p_entity_type
--    The value can be 'PO LINE', 'BLANKET LINE' or 'PRICE BREAK'
--IN OUT: None
--OUT: None
--Returns:
--  unique price differential number across the entity_type plus entity_id
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
FUNCTION get_next_price_diff_num
(
  p_entity_type IN VARCHAR2,
  p_entity_id   IN NUMBER
)
RETURN NUMBER
IS

  d_api_name CONSTANT VARCHAR2(30) := 'get_next_price_diff_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_entity_id', p_entity_id);
    PO_LOG.proc_begin(d_module, 'p_entity_type', p_entity_type);
  END IF;

  IF (p_entity_type IS NOT NULL AND p_entity_id IS NOT NULL) THEN
    IF (g_max_price_diff_num_tbl.EXISTS(p_entity_type) AND
        g_max_price_diff_num_tbl(p_entity_type).EXISTS(p_entity_id)) THEN
      g_max_price_diff_num_tbl(p_entity_type)(p_entity_id) :=
	    g_max_price_diff_num_tbl(p_entity_type)(p_entity_id) + 1;
    ELSE
      g_max_price_diff_num_tbl(p_entity_type)(p_entity_id) := 1;
    END IF;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_return(d_module, g_max_price_diff_num_tbl(p_entity_type)(p_entity_id));
    END IF;

    RETURN g_max_price_diff_num_tbl(p_entity_type)(p_entity_id);
  ELSE
    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_return(d_module, 'NULL');
    END IF;

    RETURN NULL;
  END IF;
END get_next_price_diff_num;

--------------------------------------------------------------------------
--Start of Comments
--Name: check_price_diff_num_unique
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  procedure to check whether the provided price differential number is
--  unique across entity_type plus entity_id
--Parameters:
--IN:
--  p_entity_type_tbl
--    list of entity_type values within the batch
--  p_entity_id_tbl
--    list of entity ids(po_line_id or line_location_id) within the batch
--  p_draft_id_tbl
--    list of draft ids within the batch
--  p_intf_price_diff_id_tbl
--    list of interface price differential id within the batch
--  p_price_diff_num_tbl
--    list of price differential number within the batch
--IN OUT:
--  x_price_diff_num_unique_tbl
--    boolean table to mark whether the provided price differential
--    number is unique within the shipment
--OUT: None
--Returns: None
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE check_price_diff_num_unique
(
  p_entity_type_tbl            IN PO_TBL_VARCHAR30,
  p_entity_id_tbl              IN PO_TBL_NUMBER,
  p_draft_id_tbl               IN PO_TBL_NUMBER,
  p_intf_price_diff_id_tbl     IN PO_TBL_NUMBER,
  p_price_diff_num_tbl         IN PO_TBL_NUMBER,
  x_price_diff_num_unique_tbl  OUT NOCOPY PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'check_price_diff_num_unique';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key po_session_gt.key%TYPE;

  l_index_tbl DBMS_SQL.NUMBER_TABLE;

  TYPE two_dimension_table_type   IS TABLE OF DBMS_SQL.VARCHAR2_TABLE INDEX BY PLS_INTEGER;
  TYPE three_dimension_table_type IS TABLE OF two_dimension_table_type INDEX BY VARCHAR2(30);
  l_price_diff_num_exist_tbl      three_dimension_table_type;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_entity_type_tbl', p_entity_type_tbl);
    PO_LOG.proc_begin(d_module, 'p_entity_id_tbl', p_entity_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_draft_id_tbl', p_draft_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_intf_price_diff_id_tbl',
	                  p_intf_price_diff_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_price_diff_num_tbl', p_price_diff_num_tbl);
  END IF;

  x_price_diff_num_unique_tbl := PO_TBL_VARCHAR1();
  x_price_diff_num_unique_tbl.EXTEND(p_price_diff_num_tbl.COUNT);

  -- pick a new key from temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize index table
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size      => p_entity_id_tbl.COUNT,
    x_num_list  => l_index_tbl
  );

  -- first, check draft table to see whether the provided price diff nums exist
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT l_key,
           l_index_tbl(i)
    FROM   po_price_diff_draft
    WHERE  entity_type = p_entity_type_tbl(i)
    AND    entity_id = p_entity_id_tbl(i)
    AND    draft_id = p_draft_id_tbl(i)
    AND    price_differential_num = p_price_diff_num_tbl(i);

  d_position := 10;

  -- second, check txn table to see whether the provided price diff nums exist
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1)
    SELECT l_key,
           l_index_tbl(i)
    FROM   po_price_differentials
    WHERE  entity_type = p_entity_type_tbl(i)
    AND    entity_id = p_entity_id_tbl(i)
    AND    price_differential_num = p_price_diff_num_tbl(i);

  d_position := 20;

  DELETE FROM po_session_gt
  WHERE  key = l_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  d_position := 30;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'price diff number is not unique',
                  p_price_diff_num_tbl(l_index_tbl(i)));
    END IF;

    x_price_diff_num_unique_tbl(l_index_tbl(i)) := FND_API.g_FALSE;
  END LOOP;

  d_position := 40;

  -- last, check interface table records that are before current records
  FOR i IN 1..p_price_diff_num_tbl.COUNT
  LOOP
    IF (p_price_diff_num_tbl(i) IS NOT NULL AND p_entity_type_tbl(i) IS NOT NULL AND
        p_entity_id_tbl(i) IS NOT NULL) THEN
      -- check whether same combination of entity_type, entity_id and
      -- price_diff_num appears in previous records
      IF (l_price_diff_num_exist_tbl.EXISTS(p_entity_type_tbl(i)) AND
          l_price_diff_num_exist_tbl(p_entity_type_tbl(i)).EXISTS(p_entity_id_tbl(i)) AND
          l_price_diff_num_exist_tbl(p_entity_type_tbl(i))(p_entity_id_tbl(i)).EXISTS
	        (p_price_diff_num_tbl(i))) THEN
	  IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'index', i);
          PO_LOG.stmt(d_module, d_position, 'price diff number is not unique',
                      p_price_diff_num_tbl(i));
        END IF;

	  x_price_diff_num_unique_tbl(i) := FND_API.g_FALSE;
      END IF;

      -- set current combination in the hashtable
      l_price_diff_num_exist_tbl(p_entity_type_tbl(i))
	    (p_entity_id_tbl(i))(p_price_diff_num_tbl(i)) := FND_API.g_TRUE;
    END IF;
  END LOOP;

  d_position := 50;

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
END check_price_diff_num_unique;
--------------------------------------------------------------------------
--Start of Comments
--Name: default_who_columns
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  default standard who columns;
--  this procedure is shared by all entities
--Parameters:
--IN: None
--IN OUT:
--  x_last_update_date_tbl
--    list of last_update_date values within the batch
--  x_last_updated_by_tbl
--    list of last_updated_by values within the batch
--  x_last_update_login_tbl
--    list of last_update_login values within the batch
--  x_creation_date_tbl
--    list of creation_date values within the batch
--  x_created_by_tbl
--    list of created_by values within the batch
--  x_request_id_tbl
--    list of request_id values within the batch
--  x_program_application_id_tbl
--    list of program_application_id values within the batch
--  x_program_id_tbl
--    list of program_id values within the batch
--  x_program_update_date_tbl
--    list of program_update_date values within the batch
--OUT: None
--Returns: None
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
PROCEDURE default_who_columns(
  x_last_update_date_tbl       IN OUT NOCOPY PO_TBL_DATE,
  x_last_updated_by_tbl        IN OUT NOCOPY PO_TBL_NUMBER,
  x_last_update_login_tbl      IN OUT NOCOPY PO_TBL_NUMBER,
  x_creation_date_tbl          IN OUT NOCOPY PO_TBL_DATE,
  x_created_by_tbl             IN OUT NOCOPY PO_TBL_NUMBER,
  x_request_id_tbl             IN OUT NOCOPY PO_TBL_NUMBER,
  x_program_application_id_tbl IN OUT NOCOPY PO_TBL_NUMBER,
  x_program_id_tbl             IN OUT NOCOPY PO_TBL_NUMBER,
  x_program_update_date_tbl    IN OUT NOCOPY PO_TBL_DATE
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_who_columns';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  FOR i IN 1..x_last_update_date_tbl.COUNT
  LOOP
    x_last_update_date_tbl(i) := NVL(x_last_update_date_tbl(i), sysdate);
    x_last_updated_by_tbl(i) := NVL(x_last_updated_by_tbl(i), FND_GLOBAL.user_id);
    x_last_update_login_tbl(i) := NVL(x_last_update_login_tbl(i), FND_GLOBAL.login_id);
    x_creation_date_tbl(i) := NVL(x_creation_date_tbl(i), sysdate);
    x_created_by_tbl(i) := NVL(x_created_by_tbl(i), FND_GLOBAL.user_id);
    x_request_id_tbl(i) := NVL(x_request_id_tbl(i), FND_GLOBAL.conc_request_id);
    x_program_application_id_tbl(i) := NVL(x_program_application_id_tbl(i), FND_GLOBAL.prog_appl_id);
    x_program_id_tbl(i) := NVL(x_program_id_tbl(i), FND_GLOBAL.conc_program_id);
    x_program_update_date_tbl(i) := NVL(x_program_update_date_tbl(i), sysdate);
  END LOOP;

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
END default_who_columns;

--------------------------------------------------------------------------
--Start of Comments
--Name: get_next_set_process_id
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Get new set process id to insert records into item interface table;
--  This is called in item creation
--Parameters:
--IN: None
--IN OUT: None
--OUT: None
--Returns:
--  new set process id from sequence po_items_interface_sets_s
--Notes:
--Testing:
--End of Comments
--------------------------------------------------------------------------
FUNCTION get_next_set_process_id
RETURN NUMBER
IS

  d_api_name CONSTANT VARCHAR2(30) := 'get_next_set_process_idd';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_next_set_process_id NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT po_items_interface_sets_s.nextval
  INTO   l_next_set_process_id
  FROM   DUAL;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_next_set_process_id);
  END IF;

  RETURN l_next_set_process_id;
END get_next_set_process_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_currency_precision
--Function: get precision of the currency code
--Parameters:
--IN:
--  p_currency_code
--    currency for which we get the precision value
--IN OUT:
--  x_precision_tbl
--    hashtable of precisions based on currency code
--OUT:
--End of Comments
------------------------------------------------------------------------
FUNCTION get_currency_precision
(
  p_currency_code         IN VARCHAR2,
  x_precision_tbl         IN OUT NOCOPY PO_PDOI_TYPES.varchar_index_tbl_type
) RETURN NUMBER
IS

  d_api_name CONSTANT VARCHAR2(30) := 'get_currency_precision';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_precision NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_currency_code', p_currency_code);
  END IF;

  IF (x_precision_tbl.EXISTS(p_currency_code)) THEN
    d_position := 10;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_return(d_module, x_precision_tbl(p_currency_code));
    END IF;

    return x_precision_tbl(p_currency_code);
  ELSE
    d_position := 20;

    SELECT precision
    INTO   l_precision
    FROM   fnd_currencies
    WHERE  currency_code = p_currency_code;

    -- set new value in hashtable
    x_precision_tbl(p_currency_code) := l_precision;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_return(d_module, l_precision);
    END IF;

    return l_precision;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return 0;
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END get_currency_precision;

END PO_PDOI_MAINPROC_UTL_PVT;

/
