--------------------------------------------------------
--  DDL for Package Body PO_R12_CAT_UPG_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_R12_CAT_UPG_UTL" AS
/* $Header: PO_R12_CAT_UPG_UTL.plb 120.8 2006/08/02 20:22:57 pthapliy noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'PO_R12_CAT_UPG_UTL';
g_module_prefix CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';

g_debug BOOLEAN := PO_R12_CAT_UPG_DEBUG.is_logging_enabled;
g_err_num NUMBER := PO_R12_CAT_UPG_PVT.g_application_err_num;

g_base_language FND_LANGUAGES.language_code%TYPE := NULL;

--------------------------------------------------------------------------------
--Start of Comments
--Name: add_fatal_error
--Pre-reqs:
--  None
--Modifies:
--  a) PO_INTERFACE_ERRORS table
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Inserts error message into PO_INTERFACE_ERRORS in an autonomous
--  transaction. As per ECO bug 4927349, all messages for catalog migration will
--  be provided by iProcurement (product code ICX).
--
--Parameters:
--  Same as the PO_INTERFACE_ERRORS_SV1.handle_interface_errors() procedure.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE add_fatal_error
(
  p_interface_header_id IN NUMBER default NULL,
  p_interface_line_id IN NUMBER default NULL,
  p_interface_line_location_id IN NUMBER default NULL,
  p_interface_distribution_id IN NUMBER default NULL,
  p_price_diff_interface_id IN NUMBER default NULL,
  p_interface_attr_values_id IN NUMBER default NULL,
  p_interface_attr_values_tlp_id IN NUMBER default NULL,
  p_error_message_name IN VARCHAR2 default NULL,
  p_table_name IN VARCHAR2 default NULL,
  p_column_name IN VARCHAR2 default NULL,
  p_column_value IN VARCHAR2 default NULL,
  p_token1_name IN VARCHAR2 default NULL,
  p_token1_value IN VARCHAR2 default NULL,
  p_token2_name IN VARCHAR2 default NULL,
  p_token2_value IN VARCHAR2 default NULL,
  p_token3_name IN VARCHAR2 default NULL,
  p_token3_value IN VARCHAR2 default NULL,
  p_token4_name IN VARCHAR2 default NULL,
  p_token4_value IN VARCHAR2 default NULL,
  p_token5_name IN VARCHAR2 default NULL,
  p_token5_value IN VARCHAR2 default NULL,
  p_token6_name IN VARCHAR2 default NULL,
  p_token6_value IN VARCHAR2 default NULL
)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_api_name      CONSTANT VARCHAR2(30) := 'add_fatal_error';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_hdr_proc_flag VARCHAR2(1) := 'N';
  l_original_message VARCHAR2(2000);
  l_error_message_text VARCHAR2(2000);

  -- ECO bug 4927349: All messages for catalog migration will be
  -- provided by iProcurement (product code ICX).
  l_product_code CONSTANT VARCHAR2(10) := 'ICX';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF g_debug THEN
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'interface_type='||'PO_DOCS_OPEN_INTERFACE');
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'error_type='||'FATAL');
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'batch_id='|| PO_R12_CAT_UPG_PVT.g_job.batch_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'interface_header_id='|| p_interface_header_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'interface_line_id='|| p_interface_line_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'error_message_name='|| p_error_message_name);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'table_name='|| p_table_name);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'column_name='|| p_column_name);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'column_value='|| p_column_value);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenname1='|| p_token1_name);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenname2='|| p_token2_name);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenname3='|| p_token3_name);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenname4='|| p_token4_name);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenname5='|| p_token5_name);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenname6='|| p_token6_name);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenvalue1='|| p_token1_value);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenvalue2='|| p_token2_value);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenvalue3='|| p_token3_value);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenvalue4='|| p_token4_value);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenvalue5='|| p_token5_value);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'tokenvalue6='|| p_token6_value);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'header_processable_flag='|| l_hdr_proc_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'interface_dist_id='|| p_interface_distribution_id);
  END IF;

  --PO_INTERFACE_ERRORS_UTL.add_to_tbl
/*
  PO_INTERFACE_ERRORS_SV1.handle_interface_errors
  (
    x_interface_type          => 'PO_DOCS_OPEN_INTERFACE',
    x_error_type              => 'FATAL',
    x_batch_id                => PO_R12_CAT_UPG_PVT.g_job.batch_id,
    x_interface_header_id     => p_interface_header_id,
    x_interface_line_id       => p_interface_line_id,
    x_error_message_name      => p_error_message_name,
    x_table_name              => p_table_name,
    x_column_name             => p_column_name,
    x_tokenname1              => p_token1_name,
    x_tokenname2              => p_token2_name,
    x_tokenname3              => p_token3_name,
    x_tokenname4              => p_token4_name,
    x_tokenname5              => p_token5_name,
    x_tokenname6              => p_token6_name,
    x_tokenvalue1             => p_token1_value,
    x_tokenvalue2             => p_token2_value,
    x_tokenvalue3             => p_token3_value,
    x_tokenvalue4             => p_token4_value,
    x_tokenvalue5             => p_token5_value,
    x_tokenvalue6             => p_token6_value,
    x_header_processable_flag => l_hdr_proc_flag,
    x_interface_dist_id       => p_interface_distribution_id
  );
*/

  FND_MESSAGE.set_name(l_product_code, p_error_message_name);

  IF (p_token1_name IS NOT NULL AND p_token1_value IS NOT NULL) THEN
    FND_MESSAGE.set_token(p_token1_name, p_token1_value);
  END IF;
  IF (p_token2_name IS NOT NULL AND p_token2_value IS NOT NULL) THEN
    FND_MESSAGE.set_token(p_token2_name, p_token2_value);
  END IF;
  IF (p_token3_name IS NOT NULL AND p_token3_value IS  NOT NULL) THEN
    FND_MESSAGE.set_token(p_token3_name, p_token3_value);
  END IF;
  IF (p_token4_name IS NOT NULL AND p_token4_value IS NOT NULL) THEN
    FND_MESSAGE.set_token(p_token4_name, p_token4_value);
  END IF;
  IF (p_token5_name IS NOT NULL AND p_token5_value IS NOT NULL) THEN
    FND_MESSAGE.set_token(p_token5_name, p_token5_value);
  END IF;
  IF (p_token6_name IS NOT NULL AND p_token6_value IS NOT NULL) THEN
    FND_MESSAGE.set_token(p_token6_name, p_token6_value);
  END IF;

  l_original_message := FND_MESSAGE.get;
  l_error_message_text := substrb(l_original_message, 1, 2000);

  l_progress := '020';
  INSERT INTO PO_INTERFACE_ERRORS
  (
    INTERFACE_TYPE,
    INTERFACE_TRANSACTION_ID,
    COLUMN_NAME,
    COLUMN_VALUE,
    TABLE_NAME,
    ERROR_MESSAGE,
    ERROR_MESSAGE_NAME,
    PROCESSING_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    INTERFACE_HEADER_ID,
    INTERFACE_LINE_ID,
    INTERFACE_DISTRIBUTION_ID,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    BATCH_ID

  ) VALUES (

    'PO_DOCS_OPEN_INTERFACE',
    PO_INTERFACE_ERRORS_S.nextval,
    p_column_name,
    substrb(p_column_value, 1, 4000),
    p_table_name,
    l_error_message_text,
    p_error_message_name,
    sysdate,
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
    FND_GLOBAL.login_id,
    p_interface_header_id,
    p_interface_line_id,
    p_interface_distribution_id,
    FND_GLOBAL.conc_request_id,
    FND_GLOBAL.prog_appl_id,
    FND_GLOBAL.conc_program_id,
    sysdate,
    PO_R12_CAT_UPG_PVT.g_job.batch_id
  );

  l_progress := '030';
  -- Have to commit at the end of a successful autonomous transaction
  COMMIT;

  l_progress := '040';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END add_fatal_error;

--------------------------------------------------------------------------------
--Start of Comments
--Name: reject_headers_intf
--Pre-reqs:
--  None
--Modifies:
--  a) PO interface tables
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Sets the process_code as rejected and processing id as negative for the
--  given set of interface_header_id's
--
--Parameters:
--IN:
--p_id_param_type
--  Specifies if the id's are for the which level -- header/line, etc.
--p_id_tbl
--  The id's to the interface tables
--p_cascade IN VARCHAR2
--  Specifies if the errors should be cascaded down to the levels below.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE reject_headers_intf
(
  p_id_param_type IN VARCHAR2
, p_id_tbl        IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, p_cascade       IN VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'reject_headers_intf';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF (p_id_param_type = 'INTERFACE_HEADER_ID') THEN

    l_progress := '020';
    -- SQL What: Update the process_code and processing_id in the Headers
    --           Interface Table to mark error rows.
    -- SQL Why : So that they are not picked up from from processing in the
    --           downstream flows.
    -- SQL Join: interface_header_id
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_headers_interface
      SET process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
          --processing_id = -PO_R12_CAT_UPG_PVT.g_processing_id
      WHERE interface_header_id = p_id_tbl(i);
  ELSE
    l_progress := '030';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'param_type is not INTERFACE_HEADER_ID'); END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '040';
  IF (p_cascade = FND_API.G_TRUE) THEN
    l_progress := '050';

    reject_lines_intf
    ( p_id_param_type => 'INTERFACE_HEADER_ID'
    , p_id_tbl => p_id_tbl
    , p_cascade => FND_API.G_TRUE
    );
  END IF;

  l_progress := '060';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END reject_headers_intf;

--------------------------------------------------------------------------------
--Start of Comments
--Name: reject_lines_intf
--Pre-reqs:
--  None
--Modifies:
--  a) PO interface tables
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Sets the process_code as rejected and processing id as negative for the
--  given set of interface_line_id's
--
--Parameters:
--IN:
--p_id_param_type
--  Specifies if the id's are for the which level -- header/line, etc.
--p_id_tbl
--  The id's to the interface tables
--p_cascade IN VARCHAR2
--  Specifies if the errors should be cascaded down to the levels below.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE reject_lines_intf
(
  p_id_param_type IN VARCHAR2
, p_id_tbl        IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
, p_cascade       IN VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'reject_lines_intf';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_intf_line_id_tbl PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_processed_intf_hdr_id_tbl PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_id_param_type='||p_id_param_type); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_cascade='||p_cascade); END IF;
  IF (p_id_tbl IS NOT NULL) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_id_tbl.COUNT='||p_id_tbl.COUNT); END IF;
  ELSE
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_id_tbl.COUNT is NULL'); END IF;
  END IF;

  IF (p_id_param_type = 'INTERFACE_HEADER_ID') THEN
    l_progress := '020';
    -- SQL What: Update the process_code and processing_id in the Lines
    --           Interface Table to mark error rows.
    -- SQL Why : So that they are not picked up from from processing in the
    --           downstream flows.
    -- SQL Join: interface_header_id
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_lines_interface
      SET process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
          --processing_id = -PO_R12_CAT_UPG_PVT.g_processing_id
      WHERE interface_header_id = p_id_tbl(i)
    RETURNING interface_header_id, interface_line_id
    BULK COLLECT INTO l_processed_intf_hdr_id_tbl, l_intf_line_id_tbl;

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows REJECTED in PO_LINES_INTERFACE='||SQL%rowcount); END IF;
  ELSIF (p_id_param_type = 'INTERFACE_LINE_ID') THEN
    l_progress := '030';
    -- SQL What: Update the process_code and processing_id in the Lines
    --           Interface Table to mark error rows.
    -- SQL Why : So that they are not picked up from from processing in the
    --           downstream flows.
    -- SQL Join: interface_line_id
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_lines_interface
      SET process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED
          --processing_id = -PO_R12_CAT_UPG_PVT.g_processing_id
      WHERE interface_line_id = p_id_tbl(i)
    RETURNING interface_header_id, interface_line_id
    BULK COLLECT INTO l_processed_intf_hdr_id_tbl, l_intf_line_id_tbl;

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows REJECTED in PO_LINES_INTERFACE='||SQL%rowcount); END IF;
  ELSE
    l_progress := '040';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Invalid param_type'); END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '050';
  IF (p_cascade = FND_API.G_TRUE) THEN
    l_progress := '060';
    --reject_line_locations_intf
    --( p_id_param_type => 'INTERFACE_LINE_ID'
    --, p_id_tbl => l_intf_line_id_tbl
    --, p_cascade => FND_API.G_TRUE);
    --
    --reject_price_diff_intf
    --( p_id_param_type => 'INTERFACE_LINE_ID'
    --, p_id_tbl => l_intf_line_id_tbl);

    reject_attr_values_intf
    ( p_id_param_type => 'INTERFACE_LINE_ID'
    , p_id_tbl        => l_intf_line_id_tbl);

    l_progress := '070';
    reject_attr_values_tlp_intf
    ( p_id_param_type => 'INTERFACE_LINE_ID'
    , p_id_tbl        => l_intf_line_id_tbl);

    l_progress := '080';
  END IF;

  l_progress := '090';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END reject_lines_intf;

--------------------------------------------------------------------------------
--Start of Comments
--Name: reject_attr_values_intf
--Pre-reqs:
--  None
--Modifies:
--  a) PO interface tables
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Sets the process_code as rejected and processing id as negative for the
--  given set of interface_line_id's.
--
--Parameters:
--IN:
--p_id_param_type
--  Specifies if the id's are for the which level -- attr/tlp, etc.
--p_id_tbl
--  The id's to the interface tables
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE reject_attr_values_intf
(
  p_id_param_type IN VARCHAR2
, p_id_tbl        IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'reject_attr_values_intf';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_id_param_type='||p_id_param_type); END IF;
  IF (p_id_tbl IS NOT NULL) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_id_tbl.COUNT='||p_id_tbl.COUNT); END IF;
  ELSE
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_id_tbl.COUNT is NULL'); END IF;
  END IF;

  IF (p_id_param_type = 'INTERFACE_LINE_ID') THEN
    l_progress := '020';

    -- SQL What: Update the process_code and processing_id in the Attr
    --           Interface Table to mark error rows.
    -- SQL Why : So that they are not picked up from from processing in the
    --           downstream flows.
    -- SQL Join: interface_line_id
    -- Bug 5417386: Added hint, removed join with hdr_id
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE /*+ INDEX(POATRI, PO_ATTR_VALUES_INT_N1) */
             PO_ATTR_VALUES_INTERFACE POATRI
      SET POATRI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED,
          POATRI.processing_id = -PO_R12_CAT_UPG_PVT.g_processing_id
      WHERE POATRI.interface_line_id = p_id_tbl(i);

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows REJECTED in PO_ATTR_VALUES_INTERFACE='||SQL%rowcount); END IF;
  ELSIF (p_id_param_type = 'INTERFACE_ATTR_VALUES_ID') THEN
    l_progress := '030';

    -- SQL What: Update the process_code and processing_id in the Attr
    --           Interface Table to mark error rows.
    -- SQL Why : So that they are not picked up from from processing in the
    --           downstream flows.
    -- SQL Join: interface_attr_values_id
    --
    -- No need of hint as the join is using the primary key interface_attr_values_id.
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE PO_ATTR_VALUES_INTERFACE POATRI
      SET POATRI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED,
          POATRI.processing_id = -PO_R12_CAT_UPG_PVT.g_processing_id
      WHERE POATRI.interface_attr_values_id = p_id_tbl(i);

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows REJECTED in PO_ATTR_VALUES_INTERFACE='||SQL%rowcount); END IF;
  ELSE
    l_progress := '040';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Invalid param_type'); END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END reject_attr_values_intf;

--------------------------------------------------------------------------------
--Start of Comments
--Name: reject_attr_values_tlp_intf
--Pre-reqs:
--  None
--Modifies:
--  a) PO interface tables
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Sets the process_code as rejected and processing id as negative for the
--  given set of interface_line_id's
--
--Parameters:
--IN:
--p_id_param_type
--  Specifies if the id's are for the which level -- attr/tlp, etc.
--p_id_tbl
--  The id's to the interface tables
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE reject_attr_values_tlp_intf
(
  p_id_param_type IN VARCHAR2
, p_id_tbl IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'reject_attr_values_tlp_intf';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_id_param_type='||p_id_param_type); END IF;
  IF (p_id_tbl IS NOT NULL) THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_id_tbl.COUNT='||p_id_tbl.COUNT); END IF;
  ELSE
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_id_tbl.COUNT is NULL'); END IF;
  END IF;

  IF (p_id_param_type = 'INTERFACE_LINE_ID') THEN
    l_progress := '020';

    -- SQL What: Update the process_code and processing_id in the Attr TLP
    --           Interface Table to mark error rows.
    -- SQL Why : So that they are not picked up from from processing in the
    --           downstream flows.
    -- SQL Join: interface_line_id
    -- Bug 5417386: Added hint, removed join with hdr_id
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE /*+ INDEX(POTLPI, PO_ATTR_VALUES_TLP_INT_N1) */
             PO_ATTR_VALUES_TLP_INTERFACE POTLPI
      SET POTLPI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED,
          POTLPI.processing_id = -PO_R12_CAT_UPG_PVT.g_processing_id
      WHERE POTLPI.interface_line_id = p_id_tbl(i);

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows REJECTED in PO_ATTR_VALUES_TLP_INTERFACE='||SQL%rowcount); END IF;
  ELSIF (p_id_param_type = 'INTERFACE_ATTR_VALUES_TLP_ID') THEN
    l_progress := '030';

    -- SQL What: Update the process_code and processing_id in the Attr TLP
    --           Interface Table to mark error rows.
    -- SQL Why : So that they are not picked up from from processing in the
    --           downstream flows.
    -- SQL Join: interface_attr_values_tlp_id
    --
    -- No need of hint as the join is using the primary key interface_attr_values_tlp_id.
    FORALL i IN 1..p_id_tbl.COUNT
      UPDATE po_attr_values_tlp_interface
      SET process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_R12_CAT_UPG_PVT.g_processing_id
      WHERE interface_attr_values_tlp_id = p_id_tbl(i);

    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows REJECTED in PO_ATTR_VALUES_TLP_INTERFACE='||SQL%rowcount); END IF;
  ELSE
    l_progress := '040';
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Invalid param_type'); END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END reject_attr_values_tlp_intf;

--------------------------------------------------------------------------------
--Start of Comments
--Name: construct_subscript_array
--Pre-reqs:
--  None
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Constructs a plsql table of numbers of the given size. This table will be
--  used in ceratin queries where a subscript needed to be inserted in a
--  FORALL construct.
--
--Parameters:
--IN:
--p_size
--  The size desired for the subscript array.
--End of Comments
--------------------------------------------------------------------------------
FUNCTION construct_subscript_array
(
  p_size IN NUMBER
)
RETURN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'construct_subscript_array';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_subscript_array PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  i NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'p_size='||p_size); END IF;

  FOR i IN 1 .. p_size
  LOOP
    l_progress := '020';
    l_subscript_array(i) := i;
  END LOOP;

  l_progress := '030';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;

  RETURN l_subscript_array;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END construct_subscript_array;

--------------------------------------------------------------------------------
--Start of Comments
--Name: assign_processing_id
--Pre-reqs:
--  The PO_R12_CAT_UPG_PVT.g_job structure is populated with valid
--  data.
--Modifies:
--  a) PO interface tables
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Populates the processing_id column on the interface table for a given
--  batch_id, org_id, process_code and document_type combination.
--
--Parameters:
--IN:
--  None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE assign_processing_id
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'assign_processing_id';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  -- SQL What: Cursor to pick up rows from the headers interface table based
  --           on batch_id, org_id, process_code and document_type combination.
  --           Does not pick up those rows that have been processed already
  --           (where processing_id is NOT NULL).
  -- SQL Why : To populate the processing_id column so that these rows are
  --           picked up for processing.
  -- SQL Join: batch_id, org_id, process_code, document_type.
  CURSOR interface_headers_csr IS
  SELECT PHI.interface_header_id
  FROM po_headers_interface PHI
  WHERE PHI.batch_id = PO_R12_CAT_UPG_PVT.g_job.batch_id
  AND   (PHI.org_id = PO_R12_CAT_UPG_PVT.g_job.org_id OR
         PO_R12_CAT_UPG_PVT.g_job.org_id IS NULL)
  AND   PHI.processing_id IS NULL
  AND   PHI.process_code = PO_R12_CAT_UPG_PVT.g_PROCESS_CODE_NEW;

  l_intf_header_id_tbl PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
  l_intf_line_id_tbl PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

  l_processed_intf_hdr_id_tbl PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  OPEN interface_headers_csr;

  l_progress := '020';
  LOOP
    BEGIN -- block to handle SNAPSHOT_TOO_OLD exception
      l_progress := '030';

      FETCH interface_headers_csr
      BULK COLLECT INTO l_intf_header_id_tbl
      LIMIT PO_R12_CAT_UPG_PVT.g_job.batch_size;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'PO_R12_CAT_UPG_PVT.g_processing_id='||PO_R12_CAT_UPG_PVT.g_processing_id); END IF;
      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'l_intf_header_id_tbl.COUNT='||l_intf_header_id_tbl.COUNT); END IF;

      l_progress := '040';
      EXIT WHEN l_intf_header_id_tbl.COUNT = 0;

      l_progress := '050';
      -- SQL What: Assign processing_id to Headers Interface table rows.
      -- SQL Why : So that these rows are picked up for processing.
      -- SQL Join: interface_header_id
      FORALL i IN 1..l_intf_header_id_tbl.COUNT
       UPDATE po_headers_interface
       SET processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
       WHERE interface_header_id = l_intf_header_id_tbl(i)
         AND processing_id IS NULL;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows updated in Headers Interface='||SQL%rowcount); END IF;

      l_progress := '060';
      -- SQL What: Assign processing_id to Lines Interface table rows.
      -- SQL Why : So that these rows are picked up for processing.
      -- SQL Join: interface_header_id
      FORALL i IN 1..l_intf_header_id_tbl.COUNT
        UPDATE po_lines_interface
        SET processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
        WHERE interface_header_id = l_intf_header_id_tbl(i)
          AND processing_id IS NULL
      RETURNING interface_header_id, interface_line_id
      BULK COLLECT INTO l_processed_intf_hdr_id_tbl, l_intf_line_id_tbl;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows updated in Lines Interface='||SQL%rowcount); END IF;

      l_progress := '070';
      --FORALL i IN 1..l_intf_line_id_tbl.COUNT
      -- UPDATE po_line_locations_interface
      -- SET processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
      -- WHERE interface_line_id = l_intf_line_id_tbl(i);

      --FORALL i IN 1..l_intf_line_id_tbl.COUNT
      -- UPDATE po_price_diff_interface
      -- SET processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
      -- WHERE interface_line_id = l_intf_line_id_tbl(i);

      --IF (PO_R12_CAT_UPG_PVT.g_job.document_type =
      --    PO_R12_CAT_UPG_PVT.g_DOC_TYPE_STANDARD) THEN
      --  FORALL i IN 1..l_intf_line_id_tbl.COUNT
      --   UPDATE po_distributions_interface
      --   SET processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
      --   WHERE interface_line_id = l_intf_line_id_tbl(i);
      --END IF;

      l_progress := '080';
      -- SQL What: Assign processing_id to Attr Interface table rows.
      -- SQL Why : So that these rows are picked up for processing.
      -- SQL Join: interface_line_id
      FORALL i IN 1..l_intf_line_id_tbl.COUNT
       UPDATE /*+ INDEX(POATRI, PO_ATTR_VALUES_INT_N1) */
              PO_ATTR_VALUES_INTERFACE POATRI
       SET POATRI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
       WHERE POATRI.interface_line_id = l_intf_line_id_tbl(i)
         -- Bug 5345544: Start
         -- Bug 5417386: Not required after index column re-ordering
         --AND POATRI.interface_header_id = l_processed_intf_hdr_id_tbl(i)
         -- Bug 5345544: End
         AND POATRI.processing_id IS NULL;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows updated in Attr Interface='||SQL%rowcount); END IF;

      l_progress := '090';
      -- SQL What: Assign processing_id to Attr TLP Interface table rows.
      -- SQL Why : So that these rows are picked up for processing.
      -- SQL Join: interface_line_id
      -- Bug 5417386: Added hint
      FORALL i IN 1..l_intf_line_id_tbl.COUNT
       UPDATE /*+ INDEX(POTLPI, PO_ATTR_VALUES_TLP_INT_N1) */
              PO_ATTR_VALUES_TLP_INTERFACE POTLPI
       SET POTLPI.processing_id = PO_R12_CAT_UPG_PVT.g_processing_id
       WHERE POTLPI.interface_line_id = l_intf_line_id_tbl(i)
         -- Bug 5345544: Start
         -- Bug 5417386: Not required after index column re-ordering
         --AND POTLPI.interface_header_id = l_processed_intf_hdr_id_tbl(i)
         -- Bug 5345544: End
         AND POTLPI.processing_id IS NULL;

      IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Number of rows updated in TLP Interface='||SQL%rowcount); END IF;

      COMMIT;
    EXCEPTION
      WHEN g_SNAPSHOT_TOO_OLD THEN
        IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'EXCEPTION: SNAPSHOT_TOO_OLD. Now commiting and re-opening the interface_headers_csr'); END IF;

        -- Commit and re-open the cursor
        l_progress := '080';
        COMMIT;

        l_progress := '090';
        CLOSE interface_headers_csr;

        l_progress := '100';
        OPEN interface_headers_csr;
        l_progress := '110';
     END; -- block to handle SNAPSHOT_TOO_OLD exception
  END LOOP;

  l_progress := '100';
  IF (interface_headers_csr%ISOPEN) THEN
    CLOSE interface_headers_csr;
  END IF;

  l_progress := '110';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    IF (interface_headers_csr%ISOPEN) THEN
      CLOSE interface_headers_csr;
    END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END assign_processing_id;

PROCEDURE init_sys_parameters;

--------------------------------------------------------------------------------
--Start of Comments
--Name: init_startup_values
--Pre-reqs:
--  None
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Populates the PO_R12_CAT_UPG_PVT.g_job structure using the
--  input parameters. Also fetches the next processing_id from the sequence.
--
--Parameters:
--IN:
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE init_startup_values
(
  p_commit IN VARCHAR2,
  p_selected_batch_id IN NUMBER,
  p_batch_size IN NUMBER,
  p_buyer_id IN NUMBER,
  p_document_type IN VARCHAR2,
  p_document_subtype IN VARCHAR2,
  p_create_items IN VARCHAR2,
  p_create_sourcing_rules_flag IN VARCHAR2,
  p_rel_gen_method IN VARCHAR2,
  p_approved_status IN VARCHAR2,
  p_process_code IN VARCHAR2,
  p_interface_header_id IN NUMBER,
  p_org_id IN NUMBER,
  p_ga_flag IN VARCHAR2,
  p_role IN VARCHAR2,
  p_error_threshold IN NUMBER,
  p_validate_only_mode IN VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'init_startup_values';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '020';
  -- Setup g_job param
  PO_R12_CAT_UPG_PVT.g_job.commit_work := p_commit;
  PO_R12_CAT_UPG_PVT.g_job.batch_id := p_selected_batch_id;
  PO_R12_CAT_UPG_PVT.g_job.batch_size := p_batch_size;
  PO_R12_CAT_UPG_PVT.g_job.buyer_id := p_buyer_id;
  PO_R12_CAT_UPG_PVT.g_job.document_type := p_document_type;
  PO_R12_CAT_UPG_PVT.g_job.document_subtype := p_document_subtype;
  PO_R12_CAT_UPG_PVT.g_job.error_threshold := p_error_threshold;
  PO_R12_CAT_UPG_PVT.g_job.validate_only_mode := p_validate_only_mode;

  IF g_debug THEN
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Job param commit_work='||PO_R12_CAT_UPG_PVT.g_job.commit_work);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Job param batch_id='||PO_R12_CAT_UPG_PVT.g_job.batch_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Job param batch_size='||PO_R12_CAT_UPG_PVT.g_job.batch_size);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Job param buyer_id='||PO_R12_CAT_UPG_PVT.g_job.buyer_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Job param document_type='||PO_R12_CAT_UPG_PVT.g_job.document_type);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Job param document_subtype='||PO_R12_CAT_UPG_PVT.g_job.document_subtype);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Job param error_threshold='||PO_R12_CAT_UPG_PVT.g_job.error_threshold);
  END IF;

  l_progress := '030';
  -- Setup g_sys param
  init_sys_parameters;

  -- Setup profile param
  --init_profile_parameters;

  -- setup g_out param
  --PO_R12_CAT_UPG_PVT.g_out.processed_rec_count := 0;
  --PO_R12_CAT_UPG_PVT.g_out.rejected_rec_count := 0;
  --PO_R12_CAT_UPG_PVT.g_out.error_tolerance_exceeded := FND_API.G_FALSE;

  l_progress := '040';
  -- SQL What: Default processing_id from sequence
  -- SQL Why : To assign processing id's to the interface table rows.
  -- SQL Join: none
  SELECT PO_PDOI_PROCESSING_ID_S.nextval
  INTO PO_R12_CAT_UPG_PVT.g_processing_id
  FROM DUAL;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'processing_id='||PO_R12_CAT_UPG_PVT.g_processing_id); END IF;

  l_progress := '050';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END init_startup_values;

--------------------------------------------------------------------------------
--Start of Comments
--Name: init_sys_parameters
--Pre-reqs:
--  None
--Modifies:
--  a) PO_R12_CAT_UPG_PVT.g_sys structure.
--  b) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Populates the PO_R12_CAT_UPG_PVT.g_sys structure by calling
--  PO_CORE_S.get_po_parameters() procedure.
--
--Parameters:
--IN:
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE init_sys_parameters
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'init_sys_parameters';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '020';

  -- SQL What: Get the OU specific PO and Financials setup parameters
  -- SQL Why : These values will be used in defaulting/validations
  -- SQL Join: org_id, set_of_books_id, inventory_organization_id

  -- NOTE: We are not using PO_CORE_S.get_po_parameters() because it depends on
  --        the org context.
  SELECT
    sob.currency_code,
    sob.chart_of_accounts_id,
    nvl(FSPA.purch_encumbrance_flag,'N'),
    nvl(FSPA.req_encumbrance_flag,'N'),
    sob.set_of_books_id,
    FSPA.ship_to_location_id,
    FSPA.bill_to_location_id,
    FSPA.fob_lookup_code,
    FSPA.freight_terms_lookup_code,
    FSPA.terms_id,
    PSPA.default_rate_type,
    null,--PSPA.taxable_flag,
    PSPA.receiving_flag,
    nvl(PSPA.enforce_buyer_name_flag, 'N'),
    nvl(PSPA.enforce_buyer_authority_flag,'N'),
    PSPA.line_type_id,
    PSPA.manual_po_num_type,
    PSPA.user_defined_po_num_code,
    PSPA.price_type_lookup_code,
    PSPA.invoice_close_tolerance,
    PSPA.receive_close_tolerance,
    PSPA.security_position_structure_id,
    PSPA.expense_accrual_code,
    FSPA.inventory_organization_id,
    FSPA.revision_sort_ordering,
    PSPA.min_release_amount,
    nvl(PSPA.notify_if_blanket_flag,'N'),
    nvl(sob.enable_budgetary_control_flag,'N'),
    PSPA.user_defined_req_num_code,
    nvl(PSPA.rfq_required_flag,'N'),
    PSPA.manual_req_num_type,
    PSPA.enforce_full_lot_quantities,
    PSPA.disposition_warning_flag,
    nvl(FSPA.reserve_at_completion_flag,'N'),
    PSPA.user_defined_receipt_num_code,
    PSPA.manual_receipt_num_type,
    FSPA.use_positions_flag,
    PSPA.default_quote_warning_delay,
    PSPA.inspection_required_flag,
    PSPA.user_defined_quote_num_code,
    PSPA.manual_quote_num_type,
    PSPA.user_defined_rfq_num_code,
    PSPA.manual_rfq_num_type,
    FSPA.ship_via_lookup_code,
    rcv.qty_rcv_tolerance
  INTO
    PO_R12_CAT_UPG_PVT.g_sys.currency_code,
    PO_R12_CAT_UPG_PVT.g_sys.coa_id,
    PO_R12_CAT_UPG_PVT.g_sys.po_encumberance_flag,
    PO_R12_CAT_UPG_PVT.g_sys.req_encumberance_flag,
    PO_R12_CAT_UPG_PVT.g_sys.sob_id,
    PO_R12_CAT_UPG_PVT.g_sys.ship_to_location_id,
    PO_R12_CAT_UPG_PVT.g_sys.bill_to_location_id,
    PO_R12_CAT_UPG_PVT.g_sys.fob_lookup_code,
    PO_R12_CAT_UPG_PVT.g_sys.freight_terms_lookup_code,
    PO_R12_CAT_UPG_PVT.g_sys.terms_id,
    PO_R12_CAT_UPG_PVT.g_sys.default_rate_type,
    PO_R12_CAT_UPG_PVT.g_sys.taxable_flag,
    PO_R12_CAT_UPG_PVT.g_sys.receiving_flag,
    PO_R12_CAT_UPG_PVT.g_sys.enforce_buyer_name_flag,
    PO_R12_CAT_UPG_PVT.g_sys.enforce_buyer_auth_flag,
    PO_R12_CAT_UPG_PVT.g_sys.line_type_id,
    PO_R12_CAT_UPG_PVT.g_sys.manual_po_num_type,
    PO_R12_CAT_UPG_PVT.g_sys.po_num_code,
    PO_R12_CAT_UPG_PVT.g_sys.price_lookup_code,
    PO_R12_CAT_UPG_PVT.g_sys.invoice_close_tolerance,
    PO_R12_CAT_UPG_PVT.g_sys.receive_close_tolerance,
    PO_R12_CAT_UPG_PVT.g_sys.security_structure_id,
    PO_R12_CAT_UPG_PVT.g_sys.expense_accrual_code,
    PO_R12_CAT_UPG_PVT.g_sys.inv_org_id,
    PO_R12_CAT_UPG_PVT.g_sys.rev_sort_ordering,
    PO_R12_CAT_UPG_PVT.g_sys.min_rel_amount,
    PO_R12_CAT_UPG_PVT.g_sys.notify_blanket_flag,
    PO_R12_CAT_UPG_PVT.g_sys.budgetary_control_flag,
    PO_R12_CAT_UPG_PVT.g_sys.user_defined_req_num_code,
    PO_R12_CAT_UPG_PVT.g_sys.rfq_required_flag,
    PO_R12_CAT_UPG_PVT.g_sys.manual_req_num_type,
    PO_R12_CAT_UPG_PVT.g_sys.enforce_full_lot_qty,
    PO_R12_CAT_UPG_PVT.g_sys.disposition_warning_flag,
    PO_R12_CAT_UPG_PVT.g_sys.reserve_at_completion_flag,
    PO_R12_CAT_UPG_PVT.g_sys.user_defined_rcpt_num_code,
    PO_R12_CAT_UPG_PVT.g_sys.manual_rcpt_num_type,
    PO_R12_CAT_UPG_PVT.g_sys.use_positions_flag,
    PO_R12_CAT_UPG_PVT.g_sys.default_quote_warning_delay,
    PO_R12_CAT_UPG_PVT.g_sys.inspection_required_flag,
    PO_R12_CAT_UPG_PVT.g_sys.user_defined_quote_num_code,
    PO_R12_CAT_UPG_PVT.g_sys.manual_quote_num_type,
    PO_R12_CAT_UPG_PVT.g_sys.user_defined_rfq_num_code,
    PO_R12_CAT_UPG_PVT.g_sys.manual_rfq_num_type,
    PO_R12_CAT_UPG_PVT.g_sys.ship_via_lookup_code,
    PO_R12_CAT_UPG_PVT.g_sys.qty_rcv_tolerance
  FROM  FINANCIALS_SYSTEM_PARAMS_ALL FSPA,
        GL_SETS_OF_BOOKS             SOB,
        PO_SYSTEM_PARAMETERS_ALL     PSPA,
        RCV_PARAMETERS               RCV
  WHERE FSPA.set_of_books_id = SOB.set_of_books_id
    AND RCV.organization_id (+) = FSPA.inventory_organization_id
    AND PSPA.org_id = PO_R12_CAT_UPG_PVT.g_job.org_id
    AND FSPA.org_id = PO_R12_CAT_UPG_PVT.g_job.org_id;

  SELECT master_organization_id
  INTO PO_R12_CAT_UPG_PVT.g_sys.master_inv_org_id
  FROM MTL_PARAMETERS
  WHERE organization_id = PO_R12_CAT_UPG_PVT.g_sys.inv_org_id;

  IF g_debug THEN
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default currency_code='||PO_R12_CAT_UPG_PVT.g_sys.currency_code);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default coa_id='||PO_R12_CAT_UPG_PVT.g_sys.coa_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default po_encumberance_flag='||PO_R12_CAT_UPG_PVT.g_sys.po_encumberance_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default req_encumberance_flag='||PO_R12_CAT_UPG_PVT.g_sys.req_encumberance_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default sob_id='||PO_R12_CAT_UPG_PVT.g_sys.sob_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default ship_to_location_id='||PO_R12_CAT_UPG_PVT.g_sys.ship_to_location_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default bill_to_location_id='||PO_R12_CAT_UPG_PVT.g_sys.bill_to_location_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default fob_lookup_code='||PO_R12_CAT_UPG_PVT.g_sys.fob_lookup_code);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default freight_terms_lookup_code='||PO_R12_CAT_UPG_PVT.g_sys.freight_terms_lookup_code);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default terms_id='||PO_R12_CAT_UPG_PVT.g_sys.terms_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default default_rate_type='||PO_R12_CAT_UPG_PVT.g_sys.default_rate_type);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default taxable_flag='||PO_R12_CAT_UPG_PVT.g_sys.taxable_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default receiving_flag='||PO_R12_CAT_UPG_PVT.g_sys.receiving_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default enforce_buyer_name_flag='||PO_R12_CAT_UPG_PVT.g_sys.enforce_buyer_name_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default enforce_buyer_auth_flag='||PO_R12_CAT_UPG_PVT.g_sys.enforce_buyer_auth_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default line_type_id='||PO_R12_CAT_UPG_PVT.g_sys.line_type_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default manual_po_num_type='||PO_R12_CAT_UPG_PVT.g_sys.manual_po_num_type);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default po_num_code='||PO_R12_CAT_UPG_PVT.g_sys.po_num_code);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default price_lookup_code='||PO_R12_CAT_UPG_PVT.g_sys.price_lookup_code);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default invoice_close_tolerance='||PO_R12_CAT_UPG_PVT.g_sys.invoice_close_tolerance);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default receive_close_tolerance='||PO_R12_CAT_UPG_PVT.g_sys.receive_close_tolerance);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default security_structure_id='||PO_R12_CAT_UPG_PVT.g_sys.security_structure_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default expense_accrual_code='||PO_R12_CAT_UPG_PVT.g_sys.expense_accrual_code);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default inv_org_id='||PO_R12_CAT_UPG_PVT.g_sys.inv_org_id);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default rev_sort_ordering='||PO_R12_CAT_UPG_PVT.g_sys.rev_sort_ordering);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default min_rel_amount='||PO_R12_CAT_UPG_PVT.g_sys.min_rel_amount);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default notify_blanket_flag='||PO_R12_CAT_UPG_PVT.g_sys.notify_blanket_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default budgetary_control_flag='||PO_R12_CAT_UPG_PVT.g_sys.budgetary_control_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default user_defined_req_num_code='||PO_R12_CAT_UPG_PVT.g_sys.user_defined_req_num_code);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default rfq_required_flag='||PO_R12_CAT_UPG_PVT.g_sys.rfq_required_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default manual_req_num_type='||PO_R12_CAT_UPG_PVT.g_sys.manual_req_num_type);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default enforce_full_lot_qty='||PO_R12_CAT_UPG_PVT.g_sys.enforce_full_lot_qty);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default disposition_warning_flag='||PO_R12_CAT_UPG_PVT.g_sys.disposition_warning_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default reserve_at_completion_flag='||PO_R12_CAT_UPG_PVT.g_sys.reserve_at_completion_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default user_defined_rcpt_num_code='||PO_R12_CAT_UPG_PVT.g_sys.user_defined_rcpt_num_code);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default manual_rcpt_num_type='||PO_R12_CAT_UPG_PVT.g_sys.manual_rcpt_num_type);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default use_positions_flag='||PO_R12_CAT_UPG_PVT.g_sys.use_positions_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default default_quote_warning_delay='||PO_R12_CAT_UPG_PVT.g_sys.default_quote_warning_delay);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default inspection_required_flag='||PO_R12_CAT_UPG_PVT.g_sys.inspection_required_flag);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default user_defined_quote_num_code='||PO_R12_CAT_UPG_PVT.g_sys.user_defined_quote_num_code);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default manual_quote_num_type='||PO_R12_CAT_UPG_PVT.g_sys.manual_quote_num_type);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default user_defined_rfq_num_code='||PO_R12_CAT_UPG_PVT.g_sys.user_defined_rfq_num_code);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default manual_rfq_num_type='||PO_R12_CAT_UPG_PVT.g_sys.manual_rfq_num_type);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default ship_via_lookup_code='||PO_R12_CAT_UPG_PVT.g_sys.ship_via_lookup_code);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default qty_rcv_tolerance='||PO_R12_CAT_UPG_PVT.g_sys.qty_rcv_tolerance);
    PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Default master_inv_org_id='||PO_R12_CAT_UPG_PVT.g_sys.master_inv_org_id);
  END IF;

  -- We do not need the Receiving parameters in Catalog Migration.
  -- So commenting out the following code

  --SELECT master_organization_id
  --INTO PO_R12_CAT_UPG_PVT.g_sys_param.master_inv_org_id
  --FROM mtl_system_parameters
  --WHERE organization_id = PO_R12_CAT_UPG_PVT.g_sys.def_inv_org_id;

  -- receiving parameters for defaulting org
  --RCV_CORE_S.get_receiving_controls
  --( x_line_loc_id => NULL,
  --  x_item_id     => NULL,
  --  x_vendor_id   => NULL,
  --  x_org_id      => PO_R12_CAT_UPG_PVT.g_sys.def_inv_org_id,
  --  x_enforce_ship_to_loc => PO_R12_CAT_UPG_PVT.g_sys.enforce_ship_to_loc,
  --  x_allow_substitutes => PO_R12_CAT_UPG_PVT.g_sys.allow_substitutes,
  --  x_routing_id => PO_R12_CAT_UPG_PVT.g_sys.routing_id,
  --  x_qty_rcv_tolerance => PO_R12_CAT_UPG_PVT.g_sys.qty_rcv_tolerance,
  --  x_qty_rcv_exception => PO_R12_CAT_UPG_PVT.g_sys.qty_rcv_exception,
  --  x_days_early_receipt => PO_R12_CAT_UPG_PVT.g_sys.days_early_receipt,
  --  x_days_late_receipt => PO_R12_CAT_UPG_PVT.g_sys.days_late_receipt,
  --  x_rcv_date_exception => PO_R12_CAT_UPG_PVT.g_sys.rcv_date_exception
  --);

  l_progress := '030';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END init_sys_parameters;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_base_lang
--Pre-reqs:
--  None
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Gets the Base Language of the installed system.
--Parameters:
--IN:
-- None
--RETURN:
-- VARCHAR2 -- the base languages of the system.
--End of Comments
--------------------------------------------------------------------------------
FUNCTION get_base_lang
RETURN VARCHAR2
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'get_base_lang';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  l_progress := '020';
  IF (g_base_language IS NULL) THEN
    -- SQL What: Get the base language of the system installation.
    -- SQL Why : Will be used to populate the created_language column
    -- SQL Join: installed_flag
    SELECT language_code
    INTO g_base_language
    FROM FND_LANGUAGES
    WHERE installed_flag='B';
  END IF;

  l_progress := '030';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'base_lang=<'||g_base_language||'>'); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
  RETURN g_base_language;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END get_base_lang;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_num_languages
--Pre-reqs:
--  None
--Modifies:
--  a) FND_MSG_PUB on unhandled exceptions.
--Locks:
--  None.
--Function:
--  Gets the number of installed languages(+base lang)
--Parameters:
--IN:
-- None
--RETURN:
-- NUMBER -- the number of installed languages.
--End of Comments
--------------------------------------------------------------------------------
FUNCTION get_num_languages
RETURN NUMBER
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'get_num_languages';
  l_log_head      CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;
  l_progress      VARCHAR2(3) := '000';

  l_num_languages NUMBER := 1;
BEGIN
  l_progress := '010';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'START'); END IF;

  -- SQL What: Get the number of installed languages in the system.
  -- SQL Why : Will be used to populate TLP records.
  -- SQL Join: installed_flag
  SELECT count(*)
  INTO l_num_languages
  FROM FND_LANGUAGES
  WHERE installed_flag IN ('B', 'I');

  l_progress := '020';
  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'num_languages='||l_num_languages); END IF;

  IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'END'); END IF;
  RETURN l_num_languages;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN PO_R12_CAT_UPG_DEBUG.log_stmt(l_log_head,l_progress,'Unexpected exception'); END IF;
    RAISE_APPLICATION_ERROR(g_err_num,l_log_head||','||l_progress || ','|| SQLERRM);
END get_num_languages;

END PO_R12_CAT_UPG_UTL;

/
