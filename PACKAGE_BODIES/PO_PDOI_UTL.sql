--------------------------------------------------------
--  DDL for Package Body PO_PDOI_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_UTL" AS
/* $Header: PO_PDOI_UTL.plb 120.9.12010000.3 2013/11/26 10:07:33 srpantha ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_UTL');

-------------------------------------------------------
----------- PRIVATE PROCEDURES PROTOTYPE --------------
-------------------------------------------------------

PROCEDURE set_doc_has_errors
( p_intf_header_id_tbl IN PO_TBL_NUMBER
);

-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: remove_session_gt_records
--Function:
--  Remove all records from PO_SESSION_GT based on key.
--Parameters:
--IN:
--p_key
--  Value of the key
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE remove_session_gt_records
( p_key IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'remove_session_gt_records';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  DELETE FROM PO_SESSION_GT
  WHERE key = p_key;

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
END remove_session_gt_records;

-----------------------------------------------------------------------
--Start of Comments
--Name: commit_work
--Function:
--  Issues a commit if PO_PDOI_PARAMS.g_request.commit_work is
--  FND_API.G_TRUE
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE commit_work IS

d_api_name CONSTANT VARCHAR2(30) := 'commit_work';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (PO_PDOI_PARAMS.g_request.commit_work = FND_API.G_TRUE) THEN
    COMMIT;
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
END commit_work;


-----------------------------------------------------------------------
--Start of Comments
--Name: get_next_batch_id
--Function:
--  Get the next batch id to be inserted into po_headers_interface.
--  It's done by getting max (batch_id) + 1 from po_headers_interface
--Parameters:
--IN:
--IN OUT:
--OUT:
--Returns:
--End of Comments
------------------------------------------------------------------------
FUNCTION get_next_batch_id RETURN NUMBER
IS

d_api_name CONSTANT VARCHAR2(30) := 'get_next_batch_id';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_batch_id PO_HEADERS_INTERFACE.batch_id%TYPE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  SELECT NVL(MAX(batch_id), 0) + 1
  INTO l_batch_id
  FROM po_headers_interface;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'batch_id', l_batch_id);
  END IF;

  RETURN l_batch_id;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END get_next_batch_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: reject_headers_intf
--Function:
--  For all ids passed in, reject the corresponding records in headers
--  interface
--Parameters:
--IN:
--p_id_param_type
--  Type of the id. Possible values:
--  PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID
--p_id_tbl
--  Table of ids
--p_cascade
--  FND_API.G_TRUE if rejection should be propagated to the lower level
--  FND_API.G_FALSE otherwise
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE reject_headers_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER,
  p_cascade IN VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'reject_headers_intf';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (p_id_tbl IS NULL OR p_id_tbl.COUNT = 0) THEN
    d_position := 10;
    RETURN;
  END IF;

  IF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID) THEN
    d_position := 20;
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_headers_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_header_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id;
  ELSE
    d_position := 30;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_cascade = FND_API.G_TRUE) THEN
    d_position := 40;
    reject_lines_intf
    ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID
    , p_id_tbl => p_id_tbl
    , p_cascade => FND_API.G_TRUE
    );
  END IF;

  set_doc_has_errors
  ( p_intf_header_id_tbl => p_id_tbl
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
END reject_headers_intf;


-----------------------------------------------------------------------
--Start of Comments
--Name: reject_lines_intf
--Function:
--  For all ids passed in, reject the corresponding records in lines
--  interface
--Parameters:
--IN:
--p_id_param_type
--  Type of the id. Possible values:
--  PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID
--  PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID
--p_id_tbl
--  Table of ids
--p_cascade
--  FND_API.G_TRUE if rejection should be propagated to the lower level
--  FND_API.G_FALSE otherwise
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE reject_lines_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER,
  p_cascade IN VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'reject_lines_intf';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_intf_line_id_tbl PO_TBL_NUMBER;
l_intf_header_id_tbl PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (p_id_tbl IS NULL OR p_id_tbl.COUNT = 0) THEN
    d_position := 10;
    RETURN;
  END IF;

  IF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID) THEN
    d_position := 20;

    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_lines_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_header_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
    RETURNING interface_line_id, interface_header_id
    BULK COLLECT INTO l_intf_line_id_tbl, l_intf_header_id_tbl;

  ELSIF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID) THEN
    d_position := 30;

    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_lines_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_line_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
    RETURNING interface_line_id, interface_header_id
    BULK COLLECT INTO l_intf_line_id_tbl, l_intf_header_id_tbl;
  ELSE

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  set_doc_has_errors
  ( p_intf_header_id_tbl => l_intf_header_id_tbl
  );

  IF (p_cascade = FND_API.G_TRUE) THEN
    d_position := 40;
    reject_line_locations_intf
    ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID
    , p_id_tbl => l_intf_line_id_tbl
    , p_cascade => FND_API.G_TRUE);

    d_position := 50;
    reject_price_diff_intf
    ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID
    , p_id_tbl => l_intf_line_id_tbl);

    IF (PO_PDOI_PARAMS.g_request.document_type <>
          PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN

      d_position := 60;
      reject_attr_values_intf
      ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID
      , p_id_tbl => l_intf_line_id_tbl);

      d_position := 70;
      reject_attr_values_tlp_intf
      ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID
      , p_id_tbl => l_intf_line_id_tbl);
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
END reject_lines_intf;


-----------------------------------------------------------------------
--Start of Comments
--Name: reject_line_locations_intf
--Function:
--  For all ids passed in, reject the corresponding records in line loc
--  interface
--Parameters:
--IN:
--p_id_param_type
--  Type of the id. Possible values:
--  PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID
--  PO_PDOI_CONSTANTS.g_INTERFACE_LINE_LOCATION_ID
--p_id_tbl
--  Table of ids
--p_cascade
--  FND_API.G_TRUE if rejection should be propagated to the lower level
--  FND_API.G_FALSE otherwise
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE reject_line_locations_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER,
  p_cascade IN VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'reject_line_locations_intf';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_intf_line_loc_id_tbl PO_TBL_NUMBER;
l_intf_header_id_tbl PO_TBL_NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (p_id_tbl IS NULL OR p_id_tbl.COUNT = 0) THEN
    d_position := 10;
    RETURN;
  END IF;

  IF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID) THEN
    d_position := 20;
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_line_locations_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_line_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
      AND NVL(process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
	        <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_OBSOLETE
    RETURNING interface_line_location_id, interface_header_id
    BULK COLLECT INTO l_intf_line_loc_id_tbl, l_intf_header_id_tbl;

  ELSIF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_LINE_LOCATION_ID) THEN
    d_position := 30;
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_line_locations_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_line_location_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
      AND NVL(process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
	        <> PO_PDOI_CONSTANTS.g_PROCESS_CODE_OBSOLETE
    RETURNING interface_line_location_id, interface_header_id
    BULK COLLECT INTO l_intf_line_loc_id_tbl, l_intf_header_id_tbl;
  ELSE
    d_position := 40;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  d_position := 50;

  set_doc_has_errors
  ( p_intf_header_id_tbl => l_intf_header_id_tbl
  );

  IF (p_cascade = FND_API.G_TRUE) THEN
    IF (PO_PDOI_PARAMS.g_request.document_type =
        PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN

      d_position := 60;
      reject_distributions_intf
      ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_LOCATION_ID
      , p_id_tbl => l_intf_line_loc_id_tbl);
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
END reject_line_locations_intf;


-----------------------------------------------------------------------
--Start of Comments
--Name: reject_distributions_intf
--Function:
--  For all ids passed in, reject the corresponding records in distributions
--  interface
--Parameters:
--IN:
--p_id_param_type
--  Type of the id. Possible values:
--  PO_PDOI_CONSTANTS.g_INTERFACE_LINE_LOCATION_ID
--  PO_PDOI_CONSTANTS.g_INTERFACE_DISTRIBUTION_ID
--p_id_tbl
--  Table of ids
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE reject_distributions_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'reject_distributions_intf';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_intf_header_id_tbl PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (p_id_tbl IS NULL OR p_id_tbl.COUNT = 0) THEN
    d_position := 10;
    RETURN;
  END IF;

  IF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_LINE_LOCATION_ID) THEN
    d_position := 20;
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_distributions_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_line_location_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
      RETURNING interface_header_id
      BULK COLLECT INTO l_intf_header_id_tbl;

  ELSIF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_DISTRIBUTION_ID) THEN
    d_position := 30;
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_distributions_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_distribution_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
      RETURNING interface_header_id
      BULK COLLECT INTO l_intf_header_id_tbl;

  ELSE
    d_position := 40;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  set_doc_has_errors
  ( p_intf_header_id_tbl => l_intf_header_id_tbl
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
END reject_distributions_intf;



-----------------------------------------------------------------------
--Start of Comments
--Name: reject_price_diff_intf
--Function:
--  For all ids passed in, reject the corresponding records in price diff
--  interface
--Parameters:
--IN:
--p_id_param_type
--  Type of the id. Possible values:
--  PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID
--  PO_PDOI_CONSTANTS.g_PRICE_DIFF_INTERFACE_ID
--p_id_tbl
--  Table of ids
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE reject_price_diff_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'reject_price_diff_intf';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_intf_header_id_tbl PO_TBL_NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (p_id_tbl IS NULL OR p_id_tbl.COUNT = 0) THEN
    d_position := 10;
    RETURN;
  END IF;

  IF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID) THEN
    d_position := 20;
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_price_diff_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_line_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
      RETURNING interface_header_id
      BULK COLLECT INTO l_intf_header_id_tbl;

  ELSIF (p_id_param_type = PO_PDOI_CONSTANTS.g_PRICE_DIFF_INTERFACE_ID) THEN
    d_position := 30;
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_price_diff_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE price_diff_interface_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
      RETURNING interface_header_id
      BULK COLLECT INTO l_intf_header_id_tbl;

  ELSE
    d_position := 40;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*
  -- bug 4700377
  -- do not set the error flag if price diff failed;
  -- so po lines won't be rejected due to errors
  -- on price diffs. This is to follow behavior
  -- in 11.5.10
  set_doc_has_errors
  ( p_intf_header_id_tbl => l_intf_header_id_tbl
  );
  */
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
END reject_price_diff_intf;


-----------------------------------------------------------------------
--Start of Comments
--Name: reject_attr_values_intf
--Function:
--  For all ids passed in, reject the corresponding records in attr values
--  interface
--Parameters:
--IN:
--p_id_param_type
--  Type of the id. Possible values:
--  PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID
--  PO_PDOI_CONSTANTS.g_INTERFACE_ATTR_VALUES_ID
--p_id_tbl
--  Table of ids
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE reject_attr_values_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'reject_attr_values_intf';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_intf_header_id_tbl PO_TBL_NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (p_id_tbl IS NULL OR p_id_tbl.COUNT = 0) THEN
    d_position := 10;
    RETURN;
  END IF;

  IF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID) THEN
    d_position := 20;
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_attr_values_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_line_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
      RETURNING interface_header_id
      BULK COLLECT INTO l_intf_header_id_tbl;

  ELSIF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_ATTR_VALUES_ID) THEN
    d_position := 30;
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_attr_values_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_attr_values_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
      RETURNING interface_header_id
      BULK COLLECT INTO l_intf_header_id_tbl;

  ELSE
    d_position := 40;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  set_doc_has_errors
  ( p_intf_header_id_tbl => l_intf_header_id_tbl
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
END reject_attr_values_intf;


-----------------------------------------------------------------------
--Start of Comments
--Name: reject_attr_values_tlp_intf
--Function:
--  For all ids passed in, reject the corresponding records in attr values
--  tlp interface
--Parameters:
--IN:
--p_id_param_type
--  Type of the id. Possible values:
--  PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID
--  PO_PDOI_CONSTANTS.g_INTERFACE_ATTR_VALUES_TLP_ID
--p_id_tbl
--  Table of ids
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE reject_attr_values_tlp_intf
( p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_TBL_NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'reject_attr_values_tlp_intf';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_intf_header_id_tbl PO_TBL_NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  IF (p_id_tbl IS NULL OR p_id_tbl.COUNT = 0) THEN
    d_position := 10;
    RETURN;
  END IF;

  IF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID) THEN
    d_position := 20;
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_attr_values_tlp_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_line_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
       RETURNING interface_header_id
      BULK COLLECT INTO l_intf_header_id_tbl;

  ELSIF (p_id_param_type = PO_PDOI_CONSTANTS.g_INTERFACE_ATTR_VALUES_TLP_ID) THEN
    d_position := 30;

    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_attr_values_tlp_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_attr_values_tlp_id = p_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id
      RETURNING interface_header_id
      BULK COLLECT INTO l_intf_header_id_tbl;

  ELSE
    d_position := 40;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  set_doc_has_errors
  ( p_intf_header_id_tbl => l_intf_header_id_tbl
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
END reject_attr_values_tlp_intf;


-----------------------------------------------------------------------
--Start of Comments
--Name: post_reject_document
--Function:
--  Document rejection during post processing. This procedure is
--  different in that it removes draft changes as well.
--Parameters:
--IN:
--p_interface_header_id
--  interface header id
--p_po_header_id
--  po header id
--p_draft_id
--  draft id
--p_remove_draft
--  Flag to indicate whether draft should be removed or not
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE post_reject_document
( p_interface_header_id IN NUMBER,
  p_po_header_id IN NUMBER,
  p_draft_id IN NUMBER,
  p_remove_draft IN VARCHAR2  -- bug5129752
) IS

d_api_name CONSTANT VARCHAR2(30) := 'post_reject_document';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_return_status VARCHAR2(1);

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- reject interface records
  reject_headers_intf
  ( p_id_param_type => PO_PDOI_CONSTANTS.g_INTERFACE_HEADER_ID,
    p_id_tbl        => PO_TBL_NUMBER(p_interface_header_id),
    p_cascade        => FND_API.G_TRUE
  );

  d_position := 10;

  -- bug5129752
  -- Use p_remove_draft to determine whether draft should be removed or not

  IF ( p_remove_draft = FND_API.G_TRUE ) THEN
    -- remove draft changes
    PO_DRAFTS_PVT.remove_draft_changes
    ( p_draft_id => p_draft_id,
      p_exclude_ctrl_tbl => FND_API.G_FALSE,
      x_return_status => l_return_status
    );
  END IF;

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    d_position := 20;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
END post_reject_document;

-----------------------------------------------------------------------
--Start of Comments
--Name: generate_ordered_num_list
--Function:
--  generate an array with the following characteristics
--  arr[i] = i
--  where i from 1..p_size
--  This procedure is mainly used for bulk insert, where we want to
--  keep the records in certain order after insertion
--Parameters:
--IN:
--p_size
--  size of the array
--IN OUT:
--OUT:
--x_num_list
--
--End of Comments
------------------------------------------------------------------------
PROCEDURE generate_ordered_num_list
( p_size IN NUMBER,
  x_num_list OUT NOCOPY DBMS_SQL.NUMBER_TABLE
) IS

d_api_name CONSTANT VARCHAR2(30) := 'generate_ordered_num_list';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  FOR i IN 1..p_size LOOP
    x_num_list(i) := i;
  END LOOP;
END generate_ordered_num_list;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_processing_doctype_info
--Function:
--  Derive document type and subtype current PDOI is parocessing
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_doc_type
--  Document Type
--x_doc_subtype
--  Document Subtype
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_processing_doctype_info
( x_doc_type    OUT NOCOPY VARCHAR2,
  x_doc_subtype OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'get_processing_doctype_info';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_PDOI_PARAMS.g_request.document_type =
        PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN
    x_doc_type := 'PA';
    x_doc_subtype := PO_PDOI_PARAMS.g_request.document_type;

  ELSIF (PO_PDOI_PARAMS.g_request.document_type =
           PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
    x_doc_type := 'PO';
    x_doc_subtype := PO_PDOI_PARAMS.g_request.document_type;

  ELSIF (PO_PDOI_PARAMS.g_request.document_type =
           PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN
    x_doc_type := 'QUOTATION';
    x_doc_subtype := PO_PDOI_PARAMS.g_request.document_subtype;

  --<<Bug#17840030 Start>>
  ELSIF (PO_PDOI_PARAMS.g_request.document_type =
           PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT) THEN
    x_doc_type := 'PA';
    x_doc_subtype := PO_PDOI_PARAMS.g_request.document_type;
  --<<Bug#17840030 End>>
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
END get_processing_doctype_info;


-----------------------------------------------------------------------
--Start of Comments
--Name: is_old_request_complete
--Function:
--  Check whether the previous request (p_old_request_id) is complete and
--  won't process records anymore
--Parameters:
--IN:
--p_old_request_id
--  request id in question
--RETURN:
--  FND_API.G_TRUE if the request is still processing
--  FND_API.G_FALSE otherwise
--End of Comments
------------------------------------------------------------------------
FUNCTION is_old_request_complete
( p_old_request_id IN NUMBER
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'is_old_request_complete';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_old_request_id NUMBER;

l_complete VARCHAR2(1);

l_call_status    BOOLEAN;

l_phase VARCHAR2(240);
l_status VARCHAR2(240);
l_dev_phase VARCHAR2(30);
l_dev_status VARCHAR2(30);
l_message VARCHAR2(4000);

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'p_old_request_id', p_old_request_id);
  END IF;

  l_old_request_id := p_old_request_id;
  l_complete := FND_API.G_FALSE;

  IF ( NVL(l_old_request_id, -1) = -1) THEN
    -- If record does not come from concurrent request, we cannot figure
    -- out whether the other process has finished processing this record or
    -- not, so we just assume that this record cannot be processed anymore

    d_position := 10;

    l_complete := FND_API.G_FALSE;
  ELSE
    IF (l_old_request_id = FND_GLOBAL.conc_request_id) THEN
      d_position := 20;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt (d_module, d_position, 'Restart case.');
      END IF;

      -- restart case. The old one must have been completed.
      l_complete := FND_API.G_TRUE;

    ELSE
      d_position := 30;

      -- check request status. If it is complete, then we can safely assume
      -- that that request will no longer process the records

      l_call_status :=
        FND_CONCURRENT.get_request_status
        ( request_id => l_old_request_id,
          phase      => l_phase,
          status     => l_status,
          dev_phase  => l_dev_phase,
          dev_status => l_dev_status,
          message    => l_message
        );

      IF (l_call_status = FALSE OR l_dev_phase = 'COMPLETE') THEN
        d_position := 40;
        l_complete := FND_API.G_TRUE;
      ELSE
        d_position := 50;
        l_complete := FND_API.G_FALSE;
      END IF;

    END IF;  -- if l_dft_request_id = FND_GLOBAL.conc_request_id

  END IF; -- if l_dft_request_id = -1;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'l_complete', l_complete);
  END IF;

  RETURN l_complete;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END is_old_request_complete;

-------------------------------------------------------
-------------- PRIVATE PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: set_doc_has_errors
--Function:
--  For all header intf ids passed in, record that the document has errors.
--  This will be looked at during post processing
--Parameters:
--IN:
--p_intf_header_id_tbl
--  Table of interface header ids
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE set_doc_has_errors
( p_intf_header_id_tbl IN PO_TBL_NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'set_doc_has_errors';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'p_intf_header_id_tbl', p_intf_header_id_tbl);
  END IF;

  IF (p_intf_header_id_tbl IS NULL OR p_intf_header_id_tbl.COUNT = 0) THEN
    RETURN;
  END IF;

  -- Mark doc info to indicate that an error has occurred.
  FOR i IN 1..p_intf_header_id_tbl.COUNT LOOP
    IF (p_intf_header_id_tbl(i) IS NOT NULL) THEN
      PO_PDOI_PARAMS.g_docs_info(p_intf_header_id_tbl(i)).has_errors := FND_API.G_TRUE;
    END IF;
  END LOOP;

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
END set_doc_has_errors;

-----------------------------------------------------------------------
--Start of Comments
--Name: reject_unprocessed_intf
--Function:
--  For intf header id passed in, reject the unprocessed records on all
--  lower levels, including line, line location, attribute and price
--  differential
--  This is used in CATALOG UPLOAD error tolerance processing
--Parameters:
--IN:
--p_intf_header_id
--  document id for which all unprocessed lower level records should be
--  rejected
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE reject_unprocessed_intf
(
  p_intf_header_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'reject_unprocessed_intf';
d_module CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'p_intf_header_id', p_intf_header_id);
  END IF;

  IF (p_intf_header_id IS NULL) THEN
    d_position := 10;
    RETURN;
  END IF;

  d_position := 20;

  -- reject line level records
  UPDATE po_lines_interface
  SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
      processing_id = -PO_PDOI_PARAMS.g_processing_id
  WHERE interface_header_id = p_intf_header_id
  AND processing_id = PO_PDOI_PARAMS.g_processing_id
  AND NVL(process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
        IN (PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING,
            PO_PDOI_CONSTANTS.g_PROCESS_CODE_VAL_AND_REJECT);

  d_position := 30;

  -- reject line location level records
  UPDATE po_line_locations_interface
  SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
      processing_id = -PO_PDOI_PARAMS.g_processing_id
  WHERE interface_header_id = p_intf_header_id
  AND processing_id = PO_PDOI_PARAMS.g_processing_id
  AND NVL(process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
        = PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING;

  d_position := 40;

  -- reject price diff level records
  UPDATE po_price_diff_interface
  SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
      processing_id = -PO_PDOI_PARAMS.g_processing_id
  WHERE interface_header_id = p_intf_header_id
  AND processing_id = PO_PDOI_PARAMS.g_processing_id
  AND NVL(process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
        = PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING;

  d_position := 50;

  -- reject attr level records
  UPDATE po_attr_values_interface
  SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
      processing_id = -PO_PDOI_PARAMS.g_processing_id
  WHERE interface_header_id = p_intf_header_id
  AND processing_id = PO_PDOI_PARAMS.g_processing_id
  AND NVL(process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
        = PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING;

  d_position := 60;
  UPDATE po_attr_values_tlp_interface
  SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
      processing_id = -PO_PDOI_PARAMS.g_processing_id
  WHERE interface_header_id = p_intf_header_id
  AND processing_id = PO_PDOI_PARAMS.g_processing_id
  AND NVL(process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
        = PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING;

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
END reject_unprocessed_intf;

END PO_PDOI_UTL;

/
