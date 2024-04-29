--------------------------------------------------------
--  DDL for Package Body PO_PDOI_LINE_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PDOI_LINE_PROCESS_PVT" AS
/* $Header: PO_PDOI_LINE_PROCESS_PVT.plb 120.46.12010000.44 2015/01/23 08:51:53 linlilin ship $ */

d_pkg_name CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_PDOI_LINE_PROCESS_PVT');

--------------------------------------------------------------------------
---------------------- PRIVATE PROCEDURES PROTOTYPE ----------------------
--------------------------------------------------------------------------

-- bug5684695
-- removed derive_po_header_id procedure

-- bug 16674612
PROCEDURE default_info_from_vendor
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_id_tbl              IN PO_TBL_NUMBER,
  x_type_1099_tbl              OUT NOCOPY PO_TBL_VARCHAR15
);

-- <<PDOI Enhancement Bug#17063664 Start>>
PROCEDURE default_info_from_vendor_site
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_site_id_tbl         IN PO_TBL_NUMBER,
  x_retainage_rate_tbl         OUT NOCOPY PO_TBL_NUMBER
);

-- <<PDOI Enhancement Bug#17063664 End>>

PROCEDURE derive_item_id
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_id_tbl          IN PO_TBL_NUMBER,
  p_intf_header_id_tbl     IN PO_TBL_NUMBER,
  p_intf_line_id_tbl       IN PO_TBL_NUMBER,
  p_vendor_product_num_tbl IN PO_TBL_VARCHAR30,
  p_category_id_tbl        IN PO_TBL_NUMBER,            --bug 7374337
  p_item_tbl               IN PO_TBL_VARCHAR2000,
  x_item_id_tbl            IN OUT NOCOPY PO_TBL_NUMBER,
  x_error_flag_tbl         IN OUT NOCOPY PO_TBL_VARCHAR1
);

PROCEDURE derive_item_revision
(
  p_key                    IN po_session_gt.key%TYPE,
  p_item_id_tbl            IN PO_TBL_NUMBER,
  x_item_revision_tbl      IN OUT NOCOPY PO_TBL_VARCHAR5
);

PROCEDURE derive_job_business_group_id
(
  p_key                            IN po_session_gt.key%TYPE,
  p_index_tbl                      IN DBMS_SQL.NUMBER_TABLE,
  p_job_business_group_name_tbl    IN PO_TBL_VARCHAR2000,
  x_job_business_group_id_tbl      IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_job_id
(
  p_key                            IN po_session_gt.key%TYPE,
  p_index_tbl                      IN DBMS_SQL.NUMBER_TABLE,
  p_file_line_language_tbl         IN PO_TBL_VARCHAR5,
  p_job_business_group_name_tbl    IN PO_TBL_VARCHAR2000,
  p_job_name_tbl                   IN PO_TBL_VARCHAR2000,
  x_job_business_group_id_tbl      IN OUT NOCOPY PO_TBL_NUMBER,
  x_job_id_tbl                     IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_category_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_category_tbl         IN PO_TBL_VARCHAR2000,
  x_category_id_tbl      IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_ip_category_id
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_file_line_language_tbl IN PO_TBL_VARCHAR5,
  p_ip_category_tbl        IN PO_TBL_VARCHAR2000,
  x_ip_category_id_tbl     IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_unit_of_measure
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_uom_code_tbl         IN PO_TBL_VARCHAR5,
  x_unit_of_measure_tbl  IN OUT NOCOPY PO_TBL_VARCHAR30
);

PROCEDURE derive_line_type_id
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_file_line_language_tbl IN PO_TBL_VARCHAR5,
  p_line_type_tbl          IN PO_TBL_VARCHAR30,
  x_line_type_id_tbl       IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_un_number_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_un_number_tbl        IN PO_TBL_VARCHAR30,
  x_un_number_id_tbl     IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_hazard_class_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_hazard_class_tbl     IN PO_TBL_VARCHAR100,
  x_hazard_class_id_tbl  IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE derive_template_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_template_name_tbl    IN PO_TBL_VARCHAR30,
  x_template_id_tbl      IN OUT NOCOPY PO_TBL_NUMBER
);

-- <<PDOI Enhancement Bug#17063664 Start>>
PROCEDURE default_info_from_source_ref
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_from_header_id_tbl     IN PO_TBL_NUMBER,
  p_from_line_id_tbl       IN PO_TBL_NUMBER,
  p_contract_id_tbl        IN PO_TBL_NUMBER, --Bug 18891225
  x_unit_of_measure_tbl    OUT NOCOPY PO_TBL_VARCHAR30,
  x_un_number_id_tbl       OUT NOCOPY PO_TBL_NUMBER,
  x_hazard_class_id_tbl    OUT NOCOPY PO_TBL_NUMBER,
  x_vendor_product_num_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_negotiated_flag_tbl    OUT NOCOPY PO_TBL_VARCHAR1
);

PROCEDURE default_info_from_req
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_lines                  IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_unit_of_measure_tbl    OUT NOCOPY PO_TBL_VARCHAR30,
  x_ship_to_org_id_tbl     OUT NOCOPY PO_TBL_NUMBER,
  x_ship_to_loc_id_tbl     OUT NOCOPY PO_TBL_NUMBER,
  x_un_number_id_tbl       OUT NOCOPY PO_TBL_NUMBER,
  x_hazard_class_id_tbl    OUT NOCOPY PO_TBL_NUMBER,
  x_preferred_grade_tbl    OUT NOCOPY PO_TBL_VARCHAR2000,
  x_negotiated_flag_tbl    OUT NOCOPY PO_TBL_VARCHAR1,
  x_vendor_product_num_tbl OUT NOCOPY PO_TBL_VARCHAR30
);

PROCEDURE default_info_from_asl
(
  p_key                     IN po_session_gt.key%TYPE,
  p_index_tbl               IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl             IN PO_TBL_NUMBER,
  p_vendor_id_tbl           IN PO_TBL_NUMBER,
  p_vendor_site_id_tbl      IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl      IN PO_TBL_NUMBER,
  x_vendor_product_num_tbl  IN OUT NOCOPY PO_TBL_VARCHAR30,
  x_consigned_flag_tbl      IN OUT NOCOPY PO_TBL_VARCHAR1
);

PROCEDURE default_txn_header_id
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_start_ou_id_tbl            IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl         IN PO_TBL_NUMBER,
  p_item_category_id_tbl       IN PO_TBL_NUMBER,
  x_txn_flow_header_id_tbl     OUT NOCOPY PO_TBL_NUMBER
);

-- <<PDOI Enhancement Bug#17063664 End>>

PROCEDURE default_info_from_line_type
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_line_type_id_tbl           IN PO_TBL_NUMBER,
  x_order_type_lookup_code_tbl IN OUT NOCOPY PO_TBL_VARCHAR30,
  x_purchase_basis_tbl         IN OUT NOCOPY PO_TBL_VARCHAR30,
  x_matching_basis_tbl         IN OUT NOCOPY PO_TBL_VARCHAR30,
  x_category_id_tbl            OUT NOCOPY PO_TBL_NUMBER,
  x_unit_of_measure_tbl        OUT NOCOPY PO_TBL_VARCHAR30,
  x_unit_price_tbl             OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE default_info_from_item
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl                IN PO_TBL_NUMBER,
  x_item_desc_tbl              OUT NOCOPY PO_TBL_VARCHAR2000,
  x_unit_of_measure_tbl        OUT NOCOPY PO_TBL_VARCHAR30,
  x_unit_price_tbl             OUT NOCOPY PO_TBL_NUMBER,
  x_category_id_tbl            OUT NOCOPY PO_TBL_NUMBER,
  x_un_number_id_tbl           OUT NOCOPY PO_TBL_NUMBER,
  x_hazard_class_id_tbl        OUT NOCOPY PO_TBL_NUMBER,
  x_market_price_tbl           OUT NOCOPY PO_TBL_NUMBER,
  x_secondary_unit_of_meas_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_grade_control_flag_tbl     OUT NOCOPY PO_TBL_VARCHAR1
);

PROCEDURE default_info_from_job
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_job_id_tbl                 IN PO_TBL_NUMBER,
  x_item_desc_tbl              OUT NOCOPY PO_TBL_VARCHAR2000,
  x_category_id_tbl            OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE default_po_cat_id_from_ip
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_ip_category_id_tbl         IN PO_TBL_NUMBER,
  x_po_category_id_tbl         IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE default_ip_cat_id_from_po
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_po_category_id_tbl         IN PO_TBL_NUMBER,
  x_ip_category_id_tbl         IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE default_hc_id_from_un_number
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_un_number_tbl              IN PO_TBL_VARCHAR30,
  x_hazard_class_id_tbl        IN OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE match_lines_on_item_info
(
  x_lines         IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE copy_lines
(
  p_source_lines     IN PO_PDOI_TYPES.lines_rec_type,
  p_source_index_tbl IN DBMS_SQL.NUMBER_TABLE,
  x_target_lines     IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE uniqueness_check_on_desc
(
  p_key                 IN po_session_gt.key%TYPE,
  p_group_num           IN NUMBER,
  x_processing_row_tbl  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE uniqueness_check_on_item
(
  p_key                 IN po_session_gt.key%TYPE,
  p_group_num           IN NUMBER,
  x_processing_row_tbl  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE uniqueness_check_on_vpn
(
  p_key                 IN po_session_gt.key%TYPE,
  p_group_num           IN NUMBER,
  x_processing_row_tbl  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE uniqueness_check_on_job
(
  p_key                 IN po_session_gt.key%TYPE,
  p_group_num           IN NUMBER,
  x_processing_row_tbl  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE uniqueness_check_on_line_num
(
  p_key                 IN po_session_gt.key%TYPE,
  p_group_num           IN NUMBER,
  x_processing_row_tbl  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);


PROCEDURE set_action_add
(
  p_key                   IN po_session_gt.key%TYPE,
  p_group_num             IN NUMBER,
  p_target_lines_index_tbl IN PO_TBL_NUMBER,
  p_check_line_num_assign IN VARCHAR2,
  x_processing_row_tbl    IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines                 IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);


PROCEDURE validate_attr_tlp
(
  x_lines IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE populate_error_flag
(
  x_results           IN     po_validation_results_type,
  x_lines             IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

--<< PDOI Enhancement Bug#17063664 START>--
PROCEDURE assign_line_num
( x_lines         IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE check_req_line_uniqueness
( x_lines         IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

PROCEDURE  reject_lines_on_line_num
( p_key                IN po_session_gt.key%TYPE,
  x_lines              IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

PROCEDURE  match_lines_on_draft
( p_key                IN po_session_gt.key%TYPE,
  x_lines              IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

PROCEDURE  match_lines_on_txn
( x_lines              IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

PROCEDURE  match_lines_on_interface
( p_key                IN po_session_gt.key%TYPE,
  x_lines              IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
);

--<< PDOI Enhancement Bug#17063664 END>--

--------------------------------------------------------------------------
---------------------- PUBLIC PROCEDURES ---------------------------------
--------------------------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: reject_dup_lines_for_spo
--Function: standard po lines cannot be updated. So if the new line in
--          interface table has the same line num as existing lines in
--          same document, these new lines will be regarded as intention
--          to update existing standard po records thus rejected.
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE reject_dup_lines_for_spo IS

  d_api_name CONSTANT VARCHAR2(30) := 'reject_dup_lines_for_spo';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- select lines which have same line num as lines in txn table
  -- PDOI Enhancement Bug#17063664 : Adding the condition of
  -- Requisition line id should be NULL
  -- In case of having requisition reference , when adding to an
  -- existing line, line no# can be same
  CURSOR c_dup_lines_in_txn(p_request_processing_id NUMBER,
                            p_request_processing_round_num NUMBER) IS
  SELECT intf_headers.interface_header_id,
         intf_lines.interface_line_id,
         intf_lines.line_num
  FROM   po_lines_interface intf_lines,
         po_headers_interface intf_headers,
         po_lines txn_lines
  WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
  AND    intf_headers.po_header_id = txn_lines.po_header_id
  AND    intf_lines.processing_id = p_request_processing_id
  AND    intf_headers.processing_round_num = p_request_processing_round_num
  AND    intf_headers.processing_id = p_request_processing_id
  AND    intf_lines.line_num = txn_lines.line_num
  AND    intf_headers.action = PO_PDOI_CONSTANTS.g_ACTION_UPDATE
  AND    intf_lines.requisition_line_id IS NULL; -- Bug#17063664

  -- select lines which have same line num as lines in draft table
  CURSOR c_dup_lines_in_draft(p_request_processing_id NUMBER,
                              p_request_processing_round_num NUMBER) IS
  SELECT intf_headers.interface_header_id,
         intf_lines.interface_line_id,
         intf_lines.line_num
  FROM   po_headers_interface intf_headers,
         po_lines_interface intf_lines,
         po_lines_draft_all draft_lines
  WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
  AND    intf_headers.draft_id = draft_lines.draft_id
  AND    intf_headers.po_header_id = draft_lines.po_header_id
  AND    intf_lines.processing_id = p_request_processing_id
  AND    intf_headers.processing_round_num = p_request_processing_round_num
  AND    intf_headers.processing_id = p_request_processing_id
  AND    intf_lines.line_num = draft_lines.line_num
  AND    intf_headers.action = PO_PDOI_CONSTANTS.g_ACTION_UPDATE
  AND    intf_lines.requisition_line_id IS NULL; -- Bug#17063664;

  -- duplicate lines in interface table
  l_dup_intf_header_id_tbl PO_TBL_NUMBER;
  l_dup_intf_line_id_tbl   PO_TBL_NUMBER;
  l_dup_intf_line_num_tbl  PO_TBL_NUMBER;

  -- number of duplicate lines retrieved in each batch
  l_count NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- first reject lines which are duplicate in txn table
  OPEN c_dup_lines_in_txn(PO_PDOI_PARAMS.g_processing_id,
                        PO_PDOI_PARAMS.g_current_round_num);

  d_position := 10;

  LOOP
    -- retrieve identifiers of duplicate lines
    FETCH c_dup_lines_in_txn
    BULK COLLECT INTO
      l_dup_intf_header_id_tbl,
      l_dup_intf_line_id_tbl,
      l_dup_intf_line_num_tbl
    LIMIT PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE;

    d_position := 20;

    l_count := l_dup_intf_line_id_tbl.COUNT;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'duplicate count against txn table', l_count);
    END IF;

    EXIT WHEN l_count = 0;

    -- add error if a duplicate line is found
    FOR i IN 1..l_count
    LOOP
      d_position := 30;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'duplicate interface line id(txn)',
                    l_dup_intf_line_id_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => l_dup_intf_header_id_tbl(i),
        p_interface_line_id    => l_dup_intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_STD_PO_LINE_NUM_EXISTS',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'LINE_NUM',
        p_column_value         => l_dup_intf_line_num_tbl(i),
        p_token1_name          => 'VALUE',
        p_token1_value         => l_dup_intf_line_num_tbl(i)
      );
    END LOOP;

    d_position := 40;

    -- reject the lines and the lower level entities associated with it
    PO_PDOI_UTL.reject_lines_intf
    (
      p_id_param_type           => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
      p_id_tbl                  => l_dup_intf_line_id_tbl,
      p_cascade                 => FND_API.g_TRUE
    );

    d_position := 50;

    IF (l_count < PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE) THEN
      EXIT;
    END IF;
  END LOOP;

  CLOSE c_dup_lines_in_txn;

  d_position := 60;

  -- next, reject lines which are duplicate of lines in draft table
  OPEN c_dup_lines_in_draft(PO_PDOI_PARAMS.g_processing_id,
                          PO_PDOI_PARAMS.g_current_round_num);

  d_position := 70;

  LOOP
    -- check duplicate lines in draft table
    FETCH c_dup_lines_in_draft
    BULK COLLECT INTO
      l_dup_intf_header_id_tbl,
      l_dup_intf_line_id_tbl,
      l_dup_intf_line_num_tbl
    LIMIT PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE;

    d_position := 80;

    l_count := l_dup_intf_line_id_tbl.COUNT;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'duplicate count against draft table ', l_count);
    END IF;

    EXIT WHEN l_count = 0;

    -- add error if a duplicate line is found
    FOR i IN 1..l_count
    LOOP
      d_position := 90;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'duplicate interface line id(draft)',
                    l_dup_intf_line_id_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => l_dup_intf_header_id_tbl(i),
        p_interface_line_id    => l_dup_intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_STD_PO_LINE_NUM_EXISTS',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'LINE_NUM',
        p_column_value         => l_dup_intf_line_num_tbl(i),
        p_token1_name          => 'VALUE',
        p_token1_value         => l_dup_intf_line_num_tbl(i)
      );
    END LOOP;

    d_position := 100;

    -- reject the lines and the lower level entities associated with it
    PO_PDOI_UTL.reject_lines_intf
    (
      p_id_param_type           => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
      p_id_tbl                  => l_dup_intf_line_id_tbl,
      p_cascade                 => FND_API.g_TRUE
    );

    d_position := 110;

    IF (l_count < PO_PDOI_CONSTANTS.g_DEF_BATCH_SIZE) THEN
      EXIT;
    END IF;
  END LOOP;

  CLOSE c_dup_lines_in_draft;

  d_position := 120;

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
END reject_dup_lines_for_spo;

-----------------------------------------------------------------------
--Start of Comments
--Name: reject_invalid_action_lines
--Function: The valid value of line level action is NULL or 'ADD' when
--          user issues a PDOI request. System will reject lines with
--          invalid action values.
--Parameters:
--IN:
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE reject_invalid_action_lines IS

  d_api_name CONSTANT VARCHAR2(30) := 'reject_invalid_action_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- select lines with invalid line level action value
  CURSOR c_invalid_action_lines(p_request_processing_id NUMBER,
                                p_request_processing_round_num NUMBER) IS
  SELECT intf_lines.interface_line_id,
         intf_headers.interface_header_id,
         intf_lines.action
  FROM   po_lines_interface intf_lines,
         po_headers_interface intf_headers
  WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
  AND    intf_lines.processing_id = p_request_processing_id
  AND    intf_headers.processing_round_num = p_request_processing_round_num
  AND    intf_headers.processing_id = p_request_processing_id
  AND    NVL(intf_lines.action, PO_PDOI_CONSTANTS.g_ACTION_ADD) <>
         PO_PDOI_CONSTANTS.g_ACTION_ADD;

  -- interface line id of lines that need to be rejected
  l_rej_intf_line_id_tbl   PO_TBL_NUMBER;
  l_rej_intf_header_id_tbl PO_TBL_NUMBER;
  l_rej_line_action_tbl    PO_TBL_VARCHAR30;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- get all invalid lines from cursor
  OPEN c_invalid_action_lines(PO_PDOI_PARAMS.g_processing_id,
                              PO_PDOI_PARAMS.g_current_round_num);

  d_position := 10;

  FETCH c_invalid_action_lines
  BULK COLLECT INTO
    l_rej_intf_line_id_tbl, l_rej_intf_header_id_tbl, l_rej_line_action_tbl;

  d_position := 20;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'count of lines with invalid actions',
              l_rej_intf_line_id_tbl.COUNT);
  END IF;

  -- add error if an invalid line is found
  FOR i IN 1..l_rej_intf_line_id_tbl.COUNT
  LOOP
    d_position := 30;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'rejected interface line id',
                  l_rej_intf_line_id_tbl(i));
    END IF;

    PO_PDOI_ERR_UTL.add_fatal_error
    (
      p_interface_header_id  => l_rej_intf_header_id_tbl(i),
      p_interface_line_id    => l_rej_intf_line_id_tbl(i),
      p_error_message_name   => 'PO_PDOI_INVALID_ACTION',
      p_table_name           => 'PO_LINES_INTERFACE',
      p_column_name          => 'ACTION',
      p_column_value         => l_rej_line_action_tbl(i),
      p_token1_name          => 'VALUE',
      p_token1_value         => l_rej_line_action_tbl(i)
    );
  END LOOP;

  d_position := 40;

  -- reject the lines and the lower level entities associated with it
  PO_PDOI_UTL.reject_lines_intf
  (
    p_id_param_type           => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
    p_id_tbl                  => l_rej_intf_line_id_tbl,
    p_cascade                 => FND_API.g_TRUE
  );

  d_position := 50;

  CLOSE c_invalid_action_lines;

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
END reject_invalid_action_lines;

-----------------------------------------------------------------------
--Start of Comments
--Name: open_lines
--Function: open the correct cursor to retrieve line records
--Parameters:
--IN:
--  p_data_set_type
--    flag to indicate what kind of lines should be retrieved
--  p_max_intf_line_id
--    maximal interface_line_id processed in previous batches
--IN OUT:
--  x_lines_csr
--    cursor to point to the first record in the result batch
--OUT:
--End of Comments
-----------------------------------------------------------------------
PROCEDURE open_lines
(
  p_data_set_type      IN NUMBER,
  p_max_intf_line_id   IN NUMBER,
  x_lines_csr          OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'open_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_data_set_type', p_data_set_type);
    PO_LOG.proc_begin(d_module, 'p_max_intf_line_id', p_max_intf_line_id);
  END IF;

  -- bug5107324
  -- cursor now selects NULL into allow_desc_update_flag_tbl as well

  IF (p_data_set_type = PO_PDOI_CONSTANTS.g_LINE_CSR_ADD) THEN
    d_position := 10;

    OPEN x_lines_csr FOR
      SELECT intf_lines.interface_line_id,
             intf_lines.interface_header_id,
             NULL, -- intf_lines.po_line_id,
             intf_lines.action,
             intf_lines.document_num,
             intf_lines.item,
             intf_lines.vendor_product_num,
             intf_lines.supplier_part_auxid,
             intf_lines.item_id,
             intf_lines.item_revision,
             intf_lines.job_business_group_name,
             intf_lines.job_business_group_id,
             intf_lines.job_name,
             intf_lines.job_id,
             intf_lines.category,
             intf_lines.category_id,
             intf_lines.ip_category_name,
             intf_lines.ip_category_id,
             intf_lines.uom_code,
             intf_lines.unit_of_measure,
             intf_lines.line_type,
             intf_lines.line_type_id,
             intf_lines.un_number,
             intf_lines.un_number_id,
             intf_lines.hazard_class,
             intf_lines.hazard_class_id,
             intf_lines.template_name,
             intf_lines.template_id,
             intf_lines.item_description,
             intf_lines.unit_price,
             intf_lines.base_unit_price,
             intf_lines.from_header_id,
             intf_lines.from_line_id,
             intf_lines.list_price_per_unit,
             intf_lines.market_price,
             intf_lines.capital_expense_flag,
             intf_lines.min_release_amount,
             intf_lines.allow_price_override_flag,
             intf_lines.price_type,
             intf_lines.price_break_lookup_code,
             intf_lines.closed_code,
             intf_lines.quantity,
             intf_lines.line_num,
             intf_lines.shipment_num,
             intf_lines.price_chg_accept_flag,
             intf_lines.effective_date,
             intf_lines.expiration_date,
             intf_lines.line_attribute14,
             intf_lines.price_update_tolerance,
             NVL(intf_lines.line_loc_populated_flag, 'N'), -- Bug 18828164
             --<< PDOI Enhancement Bug#17063664 START>>--
             intf_lines.requisition_line_id,
             intf_lines.oke_contract_header_id,
             intf_lines.oke_contract_version_id,
             intf_lines.bid_number,
             intf_lines.bid_line_number,
             intf_lines.auction_header_id,
             intf_lines.auction_line_number,
             intf_lines.auction_display_number,
             intf_lines.transaction_reason_code,
             intf_lines.note_to_vendor,
             intf_lines.supplier_ref_number,
             intf_lines.orig_from_req_flag,
             intf_lines.consigned_flag,
             intf_lines.need_by_date,
             intf_lines.ship_to_location_id,
             intf_lines.ship_to_organization_id,
             intf_lines.ship_to_organization_code,
             intf_lines.ship_to_location,
             intf_lines.taxable_flag,
             --<< PDOI Enhancement Bug#17063664 END>>--

             -- << PDOI for Complex PO Project: Start >>
             intf_lines.retainage_rate,
             intf_lines.max_retainage_amount,
             intf_lines.progress_payment_rate,
             intf_lines.recoupment_rate,
             intf_lines.advance_amount,
             -- << PDOI for Complex PO Project: End >>
             intf_lines.negotiated_by_preparer_flag,
             intf_lines.amount,
             intf_lines.contractor_last_name,
             intf_lines.contractor_first_name,
             intf_lines.over_tolerance_error_flag,
             intf_lines.not_to_exceed_price,
             intf_lines.po_release_id,
             intf_lines.release_num,
             intf_lines.source_shipment_id,
             intf_lines.contract_num,
             intf_lines.contract_id,
             intf_lines.type_1099,
             intf_lines.closed_by,
             intf_lines.closed_date,
             intf_lines.committed_amount,
             intf_lines.qty_rcv_exception_code,
             intf_lines.weight_uom_code,
             intf_lines.volume_uom_code,
             intf_lines.secondary_unit_of_measure,
             intf_lines.secondary_quantity,
             intf_lines.preferred_grade,
             intf_lines.process_code,
             NULL, -- parent_interface_line_id -- bug5149827
             intf_lines.file_line_language, -- bug 5489942

             -- standard who columns
             intf_lines.last_updated_by,
             intf_lines.last_update_date,
             intf_lines.last_update_login,
             intf_lines.creation_date,
             intf_lines.created_by,
             intf_lines.request_id,
             intf_lines.program_application_id,
             intf_lines.program_id,
             intf_lines.program_update_date,

             -- attributes read from headers
             intf_headers.draft_id,
             intf_headers.action,
             intf_headers.po_header_id,
             draft_headers.vendor_id,
             draft_headers.vendor_site_id,
             draft_headers.min_release_amount,
             draft_headers.start_date,
             draft_headers.end_date,
             draft_headers.global_agreement_flag,
             draft_headers.currency_code,
             draft_headers.created_language,
             draft_headers.style_id,
             draft_headers.rate_type,
             draft_headers.rate,   -- bug 9194215
             --<< PDOI Enhancement Bug#17063664 START>>--
             draft_headers.org_id,
             draft_headers.ship_to_location_id,
             draft_headers.rate_date,
             --<< PDOI Enhancement Bug#17063664 END>>--
             -- txn table columns
             NULL, -- order_type_lookup_code
             NULL, -- purchase_basis
             NULL, -- matching_basis
             NULL, -- unordered_flag
             NULL, -- cancel_flag
             NULL, -- quantity_committed
             NULL, -- tax_attribute_update_code

             DECODE(intf_lines.process_code,
                    PO_PDOI_CONSTANTS.g_PROCESS_CODE_VAL_AND_REJECT,
                    FND_API.g_TRUE, FND_API.g_FALSE), -- error_flag_tbl
             FND_API.g_FALSE,                    -- need_to_reject_flag_tbl
             FND_API.g_FALSE,                    -- create_line_loc_tbl
             -1,                                 -- group_num
             NULL,                               -- origin_line_num
             FND_API.g_FALSE,                    -- match_line_found
             NULL,                                -- allow_desc_update_flag_tbl
             intf_lines.transaction_flow_header_id, -- Bug 18766237
	     intf_lines.qty_rcv_tolerance -- Bug 18891225
      FROM   po_lines_interface intf_lines,
             po_headers_interface intf_headers,
             po_headers_draft_all draft_headers
      WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
      AND    intf_headers.draft_id = draft_headers.draft_id
      AND    intf_headers.po_header_id = draft_headers.po_header_id
      AND    intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
      AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
      AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
      AND    intf_lines.interface_line_id > p_max_intf_line_id
      AND    intf_headers.action IN (PO_PDOI_CONSTANTS.g_ACTION_ORIGINAL,
                                     PO_PDOI_CONSTANTS.g_ACTION_REPLACE)

      UNION ALL

      SELECT intf_lines.interface_line_id,
             intf_lines.interface_header_id,
             NULL, -- intf_lines.po_line_id,
             intf_lines.action,
             intf_lines.document_num,
             intf_lines.item,
             intf_lines.vendor_product_num,
             intf_lines.supplier_part_auxid,
             intf_lines.item_id,
             intf_lines.item_revision,
             intf_lines.job_business_group_name,
             intf_lines.job_business_group_id,
             intf_lines.job_name,
             intf_lines.job_id,
             intf_lines.category,
             intf_lines.category_id,
             intf_lines.ip_category_name,
             intf_lines.ip_category_id,
             intf_lines.uom_code,
             intf_lines.unit_of_measure,
             intf_lines.line_type,
             intf_lines.line_type_id,
             intf_lines.un_number,
             intf_lines.un_number_id,
             intf_lines.hazard_class,
             intf_lines.hazard_class_id,
             intf_lines.template_name,
             intf_lines.template_id,
             intf_lines.item_description,
             intf_lines.unit_price,
             intf_lines.base_unit_price,
             intf_lines.from_header_id,
             intf_lines.from_line_id,
             intf_lines.list_price_per_unit,
             intf_lines.market_price,
             intf_lines.capital_expense_flag,
             intf_lines.min_release_amount,
             intf_lines.allow_price_override_flag,
             intf_lines.price_type,
             intf_lines.price_break_lookup_code,
             intf_lines.closed_code,
             intf_lines.quantity,
             intf_lines.line_num,
             intf_lines.shipment_num,
             intf_lines.price_chg_accept_flag,
             intf_lines.effective_date,
             intf_lines.expiration_date,
             intf_lines.line_attribute14,
             intf_lines.price_update_tolerance,
             NVL(intf_lines.line_loc_populated_flag, 'N'), -- Bug 18828164
             --<< PDOI Enhancement Bug#17063664 START>>--
             intf_lines.requisition_line_id,
             intf_lines.oke_contract_header_id,
             intf_lines.oke_contract_version_id,
             intf_lines.bid_number,
             intf_lines.bid_line_number,
             intf_lines.auction_header_id,
             intf_lines.auction_line_number,
             intf_lines.auction_display_number,
             intf_lines.transaction_reason_code,
             intf_lines.note_to_vendor,
             intf_lines.supplier_ref_number,
             intf_lines.orig_from_req_flag,
             intf_lines.consigned_flag,
             intf_lines.need_by_date,
             intf_lines.ship_to_location_id,
             intf_lines.ship_to_organization_id,
             intf_lines.ship_to_organization_code,
             intf_lines.ship_to_location,
             intf_lines.taxable_flag,
             --<< PDOI Enhancement Bug#17063664 END>>--
             -- << PDOI for Complex PO Project: Start >>
             intf_lines.retainage_rate,
             intf_lines.max_retainage_amount,
             intf_lines.progress_payment_rate,
             intf_lines.recoupment_rate,
             intf_lines.advance_amount,
             -- << PDOI for Complex PO Project: End >>
             intf_lines.negotiated_by_preparer_flag,
             intf_lines.amount,
             intf_lines.contractor_last_name,
             intf_lines.contractor_first_name,
             intf_lines.over_tolerance_error_flag,
             intf_lines.not_to_exceed_price,
             intf_lines.po_release_id,
             intf_lines.release_num,
             intf_lines.source_shipment_id,
             intf_lines.contract_num,
             intf_lines.contract_id,
             intf_lines.type_1099,
             intf_lines.closed_by,
             intf_lines.closed_date,
             intf_lines.committed_amount,
             intf_lines.qty_rcv_exception_code,
             intf_lines.weight_uom_code,
             intf_lines.volume_uom_code,
             intf_lines.secondary_unit_of_measure,
             intf_lines.secondary_quantity,
             intf_lines.preferred_grade,
             intf_lines.process_code,
             NULL, -- parent_interface_line_id -- bug5149827
             intf_lines.file_line_language, -- bug 5489942

             -- standard who columns
             intf_lines.last_updated_by,
             intf_lines.last_update_date,
             intf_lines.last_update_login,
             intf_lines.creation_date,
             intf_lines.created_by,
             intf_lines.request_id,
             intf_lines.program_application_id,
             intf_lines.program_id,
             intf_lines.program_update_date,

             -- attributes read from header
             intf_headers.draft_id,
             intf_headers.action,
             intf_headers.po_header_id,
             txn_headers.vendor_id,
             txn_headers.vendor_site_id,
             txn_headers.min_release_amount,
             txn_headers.start_date,
             txn_headers.end_date,
             txn_headers.global_agreement_flag,
             txn_headers.currency_code,
             txn_headers.created_language,
             txn_headers.style_id,
             txn_headers.rate_type,
             txn_headers.rate,  -- bug 9194215
             --<< PDOI Enhancement Bug#17063664 START>>--
             txn_headers.org_id,
             txn_headers.ship_to_location_id,
             txn_headers.rate_date,
             --<< PDOI Enhancement Bug#17063664 END>>--
             -- txn table columns
             NULL, -- order_type_lookup_code
             NULL, -- purchase_basis
             NULL, -- matching_basis
             NULL, -- unordered_flag
             NULL, -- cancel_flag
             NULL, -- quantity_committed
             NULL, -- tax_attribute_update_code

             DECODE(intf_lines.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_VAL_AND_REJECT,
               FND_API.g_TRUE, FND_API.g_FALSE),  -- error_flag_tbl
             FND_API.G_FALSE,                     -- need_to_reject_flag_tbl
       FND_API.g_FALSE,                     -- create_line_loc_tbl
             -1,                                  -- group_num
             NULL,                               -- origin_line_num
             FND_API.g_FALSE,                    -- match_line_found
             NULL,                                -- allow_desc_update_flag_tbl
             intf_lines.transaction_flow_header_id, -- Bug 18766237
	     intf_lines.qty_rcv_tolerance -- Bug 18891225
      FROM   po_lines_interface intf_lines,
             po_headers_interface intf_headers,
             po_headers txn_headers
      WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
      AND    intf_headers.po_header_id = txn_headers.po_header_id
      AND    intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
      AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
      AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
      AND    intf_lines.interface_line_id > p_max_intf_line_id
      AND    intf_headers.action = PO_PDOI_CONSTANTS.g_ACTION_UPDATE
      AND    PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD
      ORDER BY 1;
  ELSIF (p_data_set_type = PO_PDOI_CONSTANTS.g_LINE_CSR_FORCE_ADD) THEN
    d_position := 20;

    OPEN x_lines_csr FOR
      SELECT intf_lines.interface_line_id,
             intf_lines.interface_header_id,
             NULL, -- intf_lines.po_line_id,
             intf_lines.action,
             intf_lines.document_num,
             intf_lines.item,
             intf_lines.vendor_product_num,
             intf_lines.supplier_part_auxid,
             intf_lines.item_id,
             intf_lines.item_revision,
             intf_lines.job_business_group_name,
             intf_lines.job_business_group_id,
             intf_lines.job_name,
             intf_lines.job_id,
             intf_lines.category,
             intf_lines.category_id,
             intf_lines.ip_category_name,
             intf_lines.ip_category_id,
             intf_lines.uom_code,
             intf_lines.unit_of_measure,
             intf_lines.line_type,
             intf_lines.line_type_id,
             intf_lines.un_number,
             intf_lines.un_number_id,
             intf_lines.hazard_class,
             intf_lines.hazard_class_id,
             intf_lines.template_name,
             intf_lines.template_id,
             intf_lines.item_description,
             intf_lines.unit_price,
             intf_lines.base_unit_price,
             intf_lines.from_header_id,
             intf_lines.from_line_id,
             intf_lines.list_price_per_unit,
             intf_lines.market_price,
             intf_lines.capital_expense_flag,
             intf_lines.min_release_amount,
             intf_lines.allow_price_override_flag,
             intf_lines.price_type,
             intf_lines.price_break_lookup_code,
             intf_lines.closed_code,
             intf_lines.quantity,
             intf_lines.line_num,
             intf_lines.shipment_num,
             intf_lines.price_chg_accept_flag,
             intf_lines.effective_date,
             intf_lines.expiration_date,
             intf_lines.line_attribute14,
             intf_lines.price_update_tolerance,
             NVL(intf_lines.line_loc_populated_flag, 'N'), -- Bug 18828164
             --<< PDOI Enhancement Bug#17063664 START>>--
             intf_lines.requisition_line_id,
             intf_lines.oke_contract_header_id,
             intf_lines.oke_contract_version_id,
             intf_lines.bid_number,
             intf_lines.bid_line_number,
             intf_lines.auction_header_id,
             intf_lines.auction_line_number,
             intf_lines.auction_display_number,
             intf_lines.transaction_reason_code,
             intf_lines.note_to_vendor,
             intf_lines.supplier_ref_number,
             intf_lines.orig_from_req_flag,
             intf_lines.consigned_flag,
             intf_lines.need_by_date,
             intf_lines.ship_to_location_id,
             intf_lines.ship_to_organization_id,
             intf_lines.ship_to_organization_code,
             intf_lines.ship_to_location,
             intf_lines.taxable_flag,
             --<< PDOI Enhancement Bug#17063664 END>>--

             -- << PDOI for Complex PO Project: Start >>
             intf_lines.retainage_rate,
             intf_lines.max_retainage_amount,
             intf_lines.progress_payment_rate,
             intf_lines.recoupment_rate,
             intf_lines.advance_amount,
             -- << PDOI for Complex PO Project: End >>
             intf_lines.negotiated_by_preparer_flag,
             intf_lines.amount,
             intf_lines.contractor_last_name,
             intf_lines.contractor_first_name,
             intf_lines.over_tolerance_error_flag,
             intf_lines.not_to_exceed_price,
             intf_lines.po_release_id,
             intf_lines.release_num,
             intf_lines.source_shipment_id,
             intf_lines.contract_num,
             intf_lines.contract_id,
             intf_lines.type_1099,
             intf_lines.closed_by,
             intf_lines.closed_date,
             intf_lines.committed_amount,
             intf_lines.qty_rcv_exception_code,
             intf_lines.weight_uom_code,
             intf_lines.volume_uom_code,
             intf_lines.secondary_unit_of_measure,
             intf_lines.secondary_quantity,
             intf_lines.preferred_grade,
             intf_lines.process_code,
             NULL, -- parent_interface_line_id -- bug5149827
             intf_lines.file_line_language, -- bug 5489942

             -- standard who columns
             intf_lines.last_updated_by,
             intf_lines.last_update_date,
             intf_lines.last_update_login,
             intf_lines.creation_date,
             intf_lines.created_by,
             intf_lines.request_id,
             intf_lines.program_application_id,
             intf_lines.program_id,
             intf_lines.program_update_date,

             -- attributes read from header
             intf_headers.draft_id,
             intf_headers.action,
             intf_headers.po_header_id,
             txn_headers.vendor_id,
             txn_headers.vendor_site_id,
             txn_headers.min_release_amount,
             txn_headers.start_date,
             txn_headers.end_date,
             txn_headers.global_agreement_flag,
             txn_headers.currency_code,
             txn_headers.created_language,
             txn_headers.style_id,
             txn_headers.rate_type,
             txn_headers.rate,  -- bug 9194215
             --<< PDOI Enhancement Bug#17063664 START>>--
             txn_headers.org_id,
             txn_headers.ship_to_location_id,
             txn_headers.rate_date,
             --<< PDOI Enhancement Bug#17063664 END>>--
             -- txn table columns
             NULL, -- order_type_lookup_code
             NULL, -- purchase_basis
             NULL, -- matching_basis
             NULL, -- unordered_flag
             NULL, -- cancel_flag
             NULL, -- quantity_committed
             NULL, -- tax_attribute_update_code

             DECODE(intf_lines.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_VAL_AND_REJECT,
               FND_API.g_TRUE, FND_API.g_FALSE),   -- error_flag_tbl
             FND_API.G_FALSE,                      -- need_to_reject_flag_tbl
       FND_API.g_FALSE,                      -- create_line_loc_tbl
             -1,                                   -- group_num
             NULL,                                 -- origin_line_num
             FND_API.g_FALSE,                      -- match_line_found
             NULL,                                 -- allow_desc_update_flag_tbl
             intf_lines.transaction_flow_header_id, -- Bug 18766237
	     intf_lines.qty_rcv_tolerance -- Bug 18891225
      FROM   po_lines_interface intf_lines,
             po_headers_interface intf_headers,
             po_headers txn_headers
      WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
      AND    intf_headers.po_header_id = txn_headers.po_header_id
      AND    intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
      AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
      AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
      AND    intf_lines.interface_line_id > p_max_intf_line_id
      AND    intf_headers.action = PO_PDOI_CONSTANTS.g_ACTION_UPDATE
      AND    PO_PDOI_PARAMS.g_request.document_type IN
               (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
                PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)
      AND    intf_lines.action = PO_PDOI_CONSTANTS.g_ACTION_ADD
      ORDER BY intf_lines.interface_line_id;
  ELSIF (p_data_set_type = PO_PDOI_CONSTANTS.g_LINE_CSR_SYNC) THEN
    d_position := 30;

    OPEN x_lines_csr FOR
      SELECT intf_lines.interface_line_id,
             intf_lines.interface_header_id,
             NULL, -- intf_lines.po_line_id,
             intf_lines.action,
             intf_lines.document_num,
             intf_lines.item,
             intf_lines.vendor_product_num,
             intf_lines.supplier_part_auxid,
             intf_lines.item_id,
             intf_lines.item_revision,
             intf_lines.job_business_group_name,
             intf_lines.job_business_group_id,
             intf_lines.job_name,
             intf_lines.job_id,
             intf_lines.category,
             intf_lines.category_id,
             intf_lines.ip_category_name,
             intf_lines.ip_category_id,
             intf_lines.uom_code,
             intf_lines.unit_of_measure,
             intf_lines.line_type,
             intf_lines.line_type_id,
             intf_lines.un_number,
             intf_lines.un_number_id,
             intf_lines.hazard_class,
             intf_lines.hazard_class_id,
             intf_lines.template_name,
             intf_lines.template_id,
             intf_lines.item_description,
             intf_lines.unit_price,
             intf_lines.base_unit_price,
             intf_lines.from_header_id,
             intf_lines.from_line_id,
             intf_lines.list_price_per_unit,
             intf_lines.market_price,
             intf_lines.capital_expense_flag,
             intf_lines.min_release_amount,
             intf_lines.allow_price_override_flag,
             intf_lines.price_type,
             intf_lines.price_break_lookup_code,
             intf_lines.closed_code,
             intf_lines.quantity,
             intf_lines.line_num,
             intf_lines.shipment_num,
             intf_lines.price_chg_accept_flag,
             intf_lines.effective_date,
             intf_lines.expiration_date,
             intf_lines.line_attribute14,
             intf_lines.price_update_tolerance,
             NVL(intf_lines.line_loc_populated_flag, 'N'), -- Bug 18828164
             --<< PDOI Enhancement Bug#17063664 START>>--
             intf_lines.requisition_line_id,
             intf_lines.oke_contract_header_id,
             intf_lines.oke_contract_version_id,
             intf_lines.bid_number,
             intf_lines.bid_line_number,
             intf_lines.auction_header_id,
             intf_lines.auction_line_number,
             intf_lines.auction_display_number,
             intf_lines.transaction_reason_code,
             intf_lines.note_to_vendor,
             intf_lines.supplier_ref_number,
             intf_lines.orig_from_req_flag,
             intf_lines.consigned_flag,
             intf_lines.need_by_date,
             intf_lines.ship_to_location_id,
             intf_lines.ship_to_organization_id,
             intf_lines.ship_to_organization_code,
             intf_lines.ship_to_location,
             intf_lines.taxable_flag,
             --<< PDOI Enhancement Bug#17063664 END>>--

             -- << PDOI for Complex PO Project: Start >>
             intf_lines.retainage_rate,
             intf_lines.max_retainage_amount,
             intf_lines.progress_payment_rate,
             intf_lines.recoupment_rate,
             intf_lines.advance_amount,
             -- << PDOI for Complex PO Project: End >>
             intf_lines.negotiated_by_preparer_flag,
             intf_lines.amount,
             intf_lines.contractor_last_name,
             intf_lines.contractor_first_name,
             intf_lines.over_tolerance_error_flag,
             intf_lines.not_to_exceed_price,
             intf_lines.po_release_id,
             intf_lines.release_num,
             intf_lines.source_shipment_id,
             intf_lines.contract_num,
             intf_lines.contract_id,
             intf_lines.type_1099,
             intf_lines.closed_by,
             intf_lines.closed_date,
             intf_lines.committed_amount,
             intf_lines.qty_rcv_exception_code,
             intf_lines.weight_uom_code,
             intf_lines.volume_uom_code,
             intf_lines.secondary_unit_of_measure,
             intf_lines.secondary_quantity,
             intf_lines.preferred_grade,
             intf_lines.process_code,
             NULL, -- parent_interface_line_id -- bug5149827
             intf_lines.file_line_language, -- bug 5489942

             -- standard who columns
             intf_lines.last_updated_by,
             intf_lines.last_update_date,
             intf_lines.last_update_login,
             intf_lines.creation_date,
             intf_lines.created_by,
             intf_lines.request_id,
             intf_lines.program_application_id,
             intf_lines.program_id,
             intf_lines.program_update_date,

             -- attributes read from header
             intf_headers.draft_id,
             intf_headers.action,
             intf_headers.po_header_id,
             txn_headers.vendor_id,
             txn_headers.vendor_site_id,
             txn_headers.min_release_amount,
             txn_headers.start_date,
             txn_headers.end_date,
             txn_headers.global_agreement_flag,
             txn_headers.currency_code,
             txn_headers.created_language,
             txn_headers.style_id,
             txn_headers.rate_type,
             txn_headers.rate,  -- bug 9194215
             --<< PDOI Enhancement Bug#17063664 START>>--
             txn_headers.org_id,
             txn_headers.ship_to_location_id,
             txn_headers.rate_date,
             --<< PDOI Enhancement Bug#17063664 END>>--
             -- txn table columns
             NULL, -- order_type_lookup_code
             NULL, -- purchase_basis
             NULL, -- matching_basis
             NULL, -- unordered_flag
             NULL, -- cancel_flag
             NULL, -- quantity_committed
             NULL, -- tax_attribute_update_code

             DECODE(intf_lines.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_VAL_AND_REJECT,
               FND_API.g_TRUE, FND_API.g_FALSE),   -- error_flag_tbl
             FND_API.G_FALSE,                      -- need_to_reject_flag_tbl
             FND_API.g_FALSE,                      -- create_line_loc_tbl
             -1,                                   -- group_num
             NULL,                                 -- origin_line_num
             FND_API.g_FALSE,                      -- match_line_found
             NULL,                                -- allow_desc_update_flag_tbl
             intf_lines.transaction_flow_header_id, -- Bug 18766237
	     intf_lines.qty_rcv_tolerance -- Bug 18891225
      FROM   po_lines_interface intf_lines,
             po_headers_interface intf_headers,
             po_headers txn_headers
      WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
      AND    intf_headers.po_header_id = txn_headers.po_header_id
      AND    intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
      AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
      AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
      AND    intf_lines.interface_line_id > p_max_intf_line_id
      AND    intf_headers.action = PO_PDOI_CONSTANTS.g_ACTION_UPDATE
      AND    PO_PDOI_PARAMS.g_request.document_type IN
               (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
                PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)
      AND    intf_lines.action IS NULL
      AND    NOT (intf_lines.item IS NULL AND
                  intf_lines.vendor_product_num IS NULL AND
                  intf_lines.job_name IS NULL AND
                  intf_lines.item_description IS NOT NULL)
      ORDER BY intf_lines.interface_line_id;
  ELSIF (p_data_set_type = PO_PDOI_CONSTANTS.g_LINE_CSR_SYNC_ON_DESC) THEN
    d_position := 40;

    OPEN x_lines_csr FOR
      SELECT intf_lines.interface_line_id,
             intf_lines.interface_header_id,
             NULL, -- intf_lines.po_line_id,
             intf_lines.action,
             intf_lines.document_num,
             intf_lines.item,
             intf_lines.vendor_product_num,
             intf_lines.supplier_part_auxid,
             intf_lines.item_id,
             intf_lines.item_revision,
             intf_lines.job_business_group_name,
             intf_lines.job_business_group_id,
             intf_lines.job_name,
             intf_lines.job_id,
             intf_lines.category,
             intf_lines.category_id,
             intf_lines.ip_category_name,
             intf_lines.ip_category_id,
             intf_lines.uom_code,
             intf_lines.unit_of_measure,
             intf_lines.line_type,
             intf_lines.line_type_id,
             intf_lines.un_number,
             intf_lines.un_number_id,
             intf_lines.hazard_class,
             intf_lines.hazard_class_id,
             intf_lines.template_name,
             intf_lines.template_id,
             intf_lines.item_description,
             intf_lines.unit_price,
             intf_lines.base_unit_price,
             intf_lines.from_header_id,
             intf_lines.from_line_id,
             intf_lines.list_price_per_unit,
             intf_lines.market_price,
             intf_lines.capital_expense_flag,
             intf_lines.min_release_amount,
             intf_lines.allow_price_override_flag,
             intf_lines.price_type,
             intf_lines.price_break_lookup_code,
             intf_lines.closed_code,
             intf_lines.quantity,
             intf_lines.line_num,
             intf_lines.shipment_num,
             intf_lines.price_chg_accept_flag,
             intf_lines.effective_date,
             intf_lines.expiration_date,
             intf_lines.line_attribute14,
             intf_lines.price_update_tolerance,
             NVL(intf_lines.line_loc_populated_flag, 'N'), -- Bug 18828164
             --<< PDOI Enhancement Bug#17063664 START>>--
             intf_lines.requisition_line_id,
             intf_lines.oke_contract_header_id,
             intf_lines.oke_contract_version_id,
             intf_lines.bid_number,
             intf_lines.bid_line_number,
             intf_lines.auction_header_id,
             intf_lines.auction_line_number,
             intf_lines.auction_display_number,
             intf_lines.transaction_reason_code,
             intf_lines.note_to_vendor,
             intf_lines.supplier_ref_number,
             intf_lines.orig_from_req_flag,
             intf_lines.consigned_flag,
             intf_lines.need_by_date,
             intf_lines.ship_to_location_id,
             intf_lines.ship_to_organization_id,
             intf_lines.ship_to_organization_code,
             intf_lines.ship_to_location,
             intf_lines.taxable_flag,
             --<< PDOI Enhancement Bug#17063664 END>>--
             -- << PDOI for Complex PO Project: Start >>
             intf_lines.retainage_rate,
             intf_lines.max_retainage_amount,
             intf_lines.progress_payment_rate,
             intf_lines.recoupment_rate,
             intf_lines.advance_amount,
             -- << PDOI for Complex PO Project: End >>
             intf_lines.negotiated_by_preparer_flag,
             intf_lines.amount,
             intf_lines.contractor_last_name,
             intf_lines.contractor_first_name,
             intf_lines.over_tolerance_error_flag,
             intf_lines.not_to_exceed_price,
             intf_lines.po_release_id,
             intf_lines.release_num,
             intf_lines.source_shipment_id,
             intf_lines.contract_num,
             intf_lines.contract_id,
             intf_lines.type_1099,
             intf_lines.closed_by,
             intf_lines.closed_date,
             intf_lines.committed_amount,
             intf_lines.qty_rcv_exception_code,
             intf_lines.weight_uom_code,
             intf_lines.volume_uom_code,
             intf_lines.secondary_unit_of_measure,
             intf_lines.secondary_quantity,
             intf_lines.preferred_grade,
             intf_lines.process_code,
             NULL, -- parent_interface_line_id -- bug5149827
             intf_lines.file_line_language, -- bug 5489942

             -- standard who columns
             intf_lines.last_updated_by,
             intf_lines.last_update_date,
             intf_lines.last_update_login,
             intf_lines.creation_date,
             intf_lines.created_by,
             intf_lines.request_id,
             intf_lines.program_application_id,
             intf_lines.program_id,
             intf_lines.program_update_date,

             -- attributes read from header
             intf_headers.draft_id,
             intf_headers.action,
             intf_headers.po_header_id,
             txn_headers.vendor_id,
             txn_headers.vendor_site_id,
             txn_headers.min_release_amount,
             txn_headers.start_date,
             txn_headers.end_date,
             txn_headers.global_agreement_flag,
             txn_headers.currency_code,
             txn_headers.created_language,
             txn_headers.style_id,
             txn_headers.rate_type,
             txn_headers.rate,  -- bug 9194215
             --<< PDOI Enhancement Bug#17063664 START>>--
             txn_headers.org_id,
             txn_headers.ship_to_location_id,
             txn_headers.rate_date,
             --<< PDOI Enhancement Bug#17063664 END>>--
             -- txn table columns
             NULL, -- order_type_lookup_code
             NULL, -- purchase_basis
             NULL, -- matching_basis
             NULL, -- unordered_flag
             NULL, -- cancel_flag
             NULL, -- quantity_committed
             NULL, -- tax_attribute_update_code

             DECODE(intf_lines.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_VAL_AND_REJECT,
               FND_API.g_TRUE, FND_API.g_FALSE),   -- error_flag_tbl
             FND_API.G_FALSE,                      -- need_to_reject_flag_tbl
             FND_API.g_FALSE,                      -- create_line_loc_tbl
             -1,                                   -- group_num
             NULL,                                 -- origin_line_num
             FND_API.g_FALSE,                      -- match_line_found
             NULL,                                -- allow_desc_update_flag_tbl
             intf_lines.transaction_flow_header_id, -- Bug 18766237
	     intf_lines.qty_rcv_tolerance -- Bug 18891225
      FROM   po_lines_interface intf_lines,
             po_headers_interface intf_headers,
             po_headers txn_headers
      WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
      AND    intf_headers.po_header_id = txn_headers.po_header_id
      AND    intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
      AND    intf_headers.processing_round_num = PO_PDOI_PARAMS.g_current_round_num
      AND    intf_headers.processing_id = PO_PDOI_PARAMS.g_processing_id
      AND    intf_lines.interface_line_id > p_max_intf_line_id
      AND    intf_headers.action = PO_PDOI_CONSTANTS.g_ACTION_UPDATE
      AND    PO_PDOI_PARAMS.g_request.document_type IN
               (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
                PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)
      AND    intf_lines.action IS NULL
      AND    intf_lines.item IS NULL
      AND    intf_lines.vendor_product_num IS NULL
      AND    intf_lines.job_name IS NULL
      AND    intf_lines.item_description IS NOT NULL
      ORDER BY intf_lines.interface_line_id;
  ELSE
    d_position := 50;

    NULL;
  END IF;

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
END open_lines;

-----------------------------------------------------------------------
--Start of Comments
--Name: fetch_lines
--Function: fetch the line records based on batch size
--Parameters:
--IN:
--IN OUT:
--  x_lines_csr
--    cursor to point to the first record in the result batch
--  x_lines
--    record to store all the line rows within the batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE fetch_lines
(
  x_lines_csr   IN OUT NOCOPY PO_PDOI_TYPES.intf_cursor_type,
  x_lines       OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'fetch_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  FETCH x_lines_csr BULK COLLECT INTO
    x_lines.intf_line_id_tbl,
    x_lines.intf_header_id_tbl,
    x_lines.po_line_id_tbl,
    x_lines.action_tbl,
    x_lines.document_num_tbl,
    x_lines.item_tbl,
    x_lines.vendor_product_num_tbl,
    x_lines.supplier_part_auxid_tbl,
    x_lines.item_id_tbl,
    x_lines.item_revision_tbl,
    x_lines.job_business_group_name_tbl,
    x_lines.job_business_group_id_tbl,
    x_lines.job_name_tbl,
    x_lines.job_id_tbl,
    x_lines.category_tbl,
    x_lines.category_id_tbl,
    x_lines.ip_category_tbl,
    x_lines.ip_category_id_tbl,
    x_lines.uom_code_tbl,
    x_lines.unit_of_measure_tbl,
    x_lines.line_type_tbl,
    x_lines.line_type_id_tbl,
    x_lines.un_number_tbl,
    x_lines.un_number_id_tbl,
    x_lines.hazard_class_tbl,
    x_lines.hazard_class_id_tbl,
    x_lines.template_name_tbl,
    x_lines.template_id_tbl,
    x_lines.item_desc_tbl,
    x_lines.unit_price_tbl,
    x_lines.base_unit_price_tbl,
    x_lines.from_header_id_tbl,
    x_lines.from_line_id_tbl,
    x_lines.list_price_per_unit_tbl,
    x_lines.market_price_tbl,
    x_lines.capital_expense_flag_tbl,
    x_lines.min_release_amount_tbl,
    x_lines.allow_price_override_flag_tbl,
    x_lines.price_type_tbl,
    x_lines.price_break_lookup_code_tbl,
    x_lines.closed_code_tbl,
    x_lines.quantity_tbl,
    x_lines.line_num_tbl,
    x_lines.shipment_num_tbl,
    x_lines.price_chg_accept_flag_tbl,
    x_lines.effective_date_tbl,
    x_lines.expiration_date_tbl,
    x_lines.attribute14_tbl,
    x_lines.price_update_tolerance_tbl,
    x_lines.line_loc_populated_flag_tbl,
    -- << PDOI for Complex PO Project: Start >>
    --<< PDOI Enhancement Bug#17063664 START>--
    x_lines.requisition_line_id_tbl,
    x_lines.oke_contract_header_id_tbl,
    x_lines.oke_contract_version_id_tbl,
    x_lines.bid_number_tbl,
    x_lines.bid_line_number_tbl,
    x_lines.auction_header_id_tbl,
    x_lines.auction_line_number_tbl,
    x_lines.auction_display_number_tbl,
    x_lines.transaction_reason_code_tbl,
    x_lines.note_to_vendor_tbl,
    x_lines.supplier_ref_number_tbl,
    x_lines.orig_from_req_flag_tbl,
    x_lines.consigned_flag_tbl,
    x_lines.need_by_date_tbl,
    x_lines.ship_to_loc_id_tbl,
    x_lines.ship_to_org_id_tbl,
    x_lines.ship_to_org_code_tbl,
    x_lines.ship_to_loc_tbl,
    x_lines.taxable_flag_tbl,
    --<< PDOI Enhancement Bug#17063664 END>--
    -- << PDOI for Complex PO Project: Start >>
    x_lines.retainage_rate_tbl,
    x_lines.max_retainage_amount_tbl,
    x_lines.progress_payment_rate_tbl,
    x_lines.recoupment_rate_tbl,
    x_lines.advance_amount_tbl,
    -- << PDOI for Complex PO Project: End >>
    x_lines.negotiated_flag_tbl,
    x_lines.amount_tbl,
    x_lines.contractor_last_name_tbl,
    x_lines.contractor_first_name_tbl,
    x_lines.over_tolerance_err_flag_tbl,
    x_lines.not_to_exceed_price_tbl,
    x_lines.po_release_id_tbl,
    x_lines.release_num_tbl,
    x_lines.source_shipment_id_tbl,
    x_lines.contract_num_tbl,
    x_lines.contract_id_tbl,
    x_lines.type_1099_tbl,
    x_lines.closed_by_tbl,
    x_lines.closed_date_tbl,
    x_lines.committed_amount_tbl,
    x_lines.qty_rcv_exception_code_tbl,
    x_lines.weight_uom_code_tbl,
    x_lines.volume_uom_code_tbl,
    x_lines.secondary_unit_of_meas_tbl,
    x_lines.secondary_quantity_tbl,
    x_lines.preferred_grade_tbl,
    x_lines.process_code_tbl,
    x_lines.parent_interface_line_id_tbl, -- bug5149827
    x_lines.file_line_language_tbl, -- bug 5489942

    -- standard who columns
    x_lines.last_updated_by_tbl,
    x_lines.last_update_date_tbl,
    x_lines.last_update_login_tbl,
    x_lines.creation_date_tbl,
    x_lines.created_by_tbl,
    x_lines.request_id_tbl,
    x_lines.program_application_id_tbl,
    x_lines.program_id_tbl,
    x_lines.program_update_date_tbl,

    -- attributes read from headers
    x_lines.draft_id_tbl,
    x_lines.hd_action_tbl,
    x_lines.hd_po_header_id_tbl,
    x_lines.hd_vendor_id_tbl,
    x_lines.hd_vendor_site_id_tbl,
    x_lines.hd_min_release_amount_tbl,
    x_lines.hd_start_date_tbl,
    x_lines.hd_end_date_tbl,
    x_lines.hd_global_agreement_flag_tbl,
    x_lines.hd_currency_code_tbl,
    x_lines.hd_created_language_tbl,
    x_lines.hd_style_id_tbl,
    x_lines.hd_rate_type_tbl,
    x_lines.hd_rate_tbl,     -- bug 9194215
    --<< PDOI Enhancement Bug#17063664 START>>--
    x_lines.org_id_tbl,
    x_lines.hd_ship_to_loc_id_tbl,
    x_lines.hd_rate_date_tbl,
    --<< PDOI Enhancement Bug#17063664 END>>--

    -- txn table columns
    x_lines.order_type_lookup_code_tbl,
    x_lines.purchase_basis_tbl,
    x_lines.matching_basis_tbl,
    x_lines.unordered_flag_tbl,
    x_lines.cancel_flag_tbl,
    x_lines.quantity_committed_tbl,
    x_lines.tax_attribute_update_code_tbl,

    x_lines.error_flag_tbl,
    x_lines.need_to_reject_flag_tbl,
    x_lines.create_line_loc_tbl,
    x_lines.group_num_tbl,
    x_lines.origin_line_num_tbl,
    x_lines.match_line_found_tbl,
    x_lines.allow_desc_update_flag_tbl,   -- bug5107324
    x_lines.txn_flow_header_id_tbl,  -- Bug 18766237
    x_lines.qty_rcv_tolerance_tbl -- Bug 18891225
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
END fetch_lines;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_lines
--Function: peform derivation logic on line attributes
--Parameters:
--IN:
--IN OUT:
--  x_lines
--    record to store all the line rows within the batch;
--    Derivation are performed for certain attributes only
--    if their name value is populated but id value is not.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_lines
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- key of temp table used to identify the derived result
  l_key po_session_gt.key%TYPE;

  -- table used to save the index of the each row
  l_index_tbl DBMS_SQL.NUMBER_TABLE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'line counts', x_lines.rec_count);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_DERIVE);

  -- assign a new key used in temporary table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize table containing the row number(index)
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size     => x_lines.rec_count,
    x_num_list => l_index_tbl
  );

  d_position := 10;

  -- bug5684695
  -- The call to derive_po_header_id has been removed

  -- bug 7374337
  -- The call to derive category id has been moved from
  -- bottom to top so that it can be used in deriving item id
  -- when vendor_product_num is passed.
  -- derive PO category_id from PO category_name
  derive_category_id
  (
    p_key                  => l_key,
    p_category_tbl         => x_lines.category_tbl,
    x_category_id_tbl      => x_lines.category_id_tbl
  );

  d_position := 20;

  -- derive item_id from item_num
  derive_item_id
  (
    p_key                    => l_key,
    p_index_tbl              => l_index_tbl,
    p_vendor_id_tbl          => x_lines.hd_vendor_id_tbl,
    p_intf_header_id_tbl     => x_lines.intf_header_id_tbl,
    p_intf_line_id_tbl       => x_lines.intf_line_id_tbl,
    p_vendor_product_num_tbl => x_lines.vendor_product_num_tbl,
    p_category_id_tbl        => x_lines.category_id_tbl,
    p_item_tbl               => x_lines.item_tbl,
    x_item_id_tbl            => x_lines.item_id_tbl,
    x_error_flag_tbl         => x_lines.error_flag_tbl
  );

  d_position := 30;

  -- derive item_revision from item_id
  derive_item_revision
  (
    p_key                    => l_key,
    p_item_id_tbl            => x_lines.item_id_tbl,
    x_item_revision_tbl      => x_lines.item_revision_tbl
  );

  d_position := 40;

  -- derive job_business_group_id from job_business_group_name
  derive_job_business_group_id
  (
    p_key                            => l_key,
    p_index_tbl                      => l_index_tbl,
    p_job_business_group_name_tbl    => x_lines.job_business_group_name_tbl,
    x_job_business_group_id_tbl      => x_lines.job_business_group_id_tbl
  );

  d_position := 50;

  -- derive job_id from job_name
  derive_job_id
  (
    p_key                            => l_key,
    p_index_tbl                      => l_index_tbl,
    p_file_line_language_tbl         => x_lines.file_line_language_tbl,
    p_job_business_group_name_tbl    => x_lines.job_business_group_name_tbl,
    p_job_name_tbl                   => x_lines.job_name_tbl,
    x_job_business_group_id_tbl      => x_lines.job_business_group_id_tbl,
    x_job_id_tbl                     => x_lines.job_id_tbl
  );

  d_position := 60;

  -- derive PO category_id from PO category_name
  -- bug 7374337 moved above to derive item id call


  d_position := 70;

  IF (PO_PDOI_PARAMS.g_request.document_type IN
      (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
       PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)) THEN
    -- derive IP category_id from IP category_name
    derive_ip_category_id
    (
      p_key                    => l_key,
      p_index_tbl              => l_index_tbl,
      p_file_line_language_tbl => x_lines.file_line_language_tbl,
      p_ip_category_tbl        => x_lines.ip_category_tbl,
      x_ip_category_id_tbl     => x_lines.ip_category_id_tbl
    );
  END IF;

  d_position := 80;

  -- derive unit_of_measure from uom_code
  derive_unit_of_measure
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_uom_code_tbl         => x_lines.uom_code_tbl,
    x_unit_of_measure_tbl  => x_lines.unit_of_measure_tbl
  );

  -- <<PDOI Enhancement Bug#17063664 Start>>

  d_position := 90;

  -- derive ship_to_organization_id from ship_to_organization_code
  PO_PDOI_LINE_LOC_PROCESS_PVT.derive_ship_to_org_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_ship_to_org_code_tbl => x_lines.ship_to_org_code_tbl,
    x_ship_to_org_id_tbl   => x_lines.ship_to_org_id_tbl
  );

  d_position := 100;

  -- derive ship_to_location_id from ship_to_location_code
  PO_PDOI_HEADER_PROCESS_PVT.derive_location_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_location_tbl         => x_lines.ship_to_loc_tbl,
    p_location_type        => 'SHIP_TO',
    x_location_id_tbl      => x_lines.ship_to_loc_id_tbl
  );

  -- <<PDOI Enhancement Bug#17063664 End>>

  d_position := 110;

  -- derive line_type_id from line_type
  derive_line_type_id
  (
    p_key                    => l_key,
    p_index_tbl              => l_index_tbl,
    p_file_line_language_tbl => x_lines.file_line_language_tbl,
    p_line_type_tbl          => x_lines.line_type_tbl,
    x_line_type_id_tbl       => x_lines.line_type_id_tbl
  );

  d_position := 120;

  -- derive un_number_id from un_number
  derive_un_number_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_un_number_tbl        => x_lines.un_number_tbl,
    x_un_number_id_tbl     => x_lines.un_number_id_tbl
  );

  d_position := 130;

  -- derive hazard_calss_id from hazard_class
  derive_hazard_class_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_hazard_class_tbl     => x_lines.hazard_class_tbl,
    x_hazard_class_id_tbl  => x_lines.hazard_class_id_tbl
  );

  d_position := 140;

  -- derive template_id from template_name
  derive_template_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_template_name_tbl    => x_lines.template_name_tbl,
    x_template_id_tbl      => x_lines.template_id_tbl
  );

  d_position := 150;

  -- handle all derivation errors
  FOR i IN 1..x_lines.rec_count
  LOOP
    d_position := 160;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
    END IF;

    -- derivation error for item_id
    IF (x_lines.item_tbl(i) IS NOT NULL AND
        x_lines.item_id_tbl(i) IS NULL AND
        PO_PDOI_PARAMS.g_request.create_items = 'N') THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'item id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'item', x_lines.item_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_PART_NUM_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => NULL,
        p_column_value         => NULL,
        p_validation_id        => PO_VAL_CONSTANTS.c_part_num_derv,
        p_lines                => x_lines
      );

        x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- <<PDOI Enhancement Bug#17063664 Start>>
    -- check derivation error on ship_to_organziation_id
    IF (x_lines.ship_to_org_code_tbl(i) IS NOT NULL AND
        x_lines.ship_to_org_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'ship_to org id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'ship_to org', x_lines.ship_to_org_code_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => NULL,
        p_column_value         => NULL,
        p_validation_id        => PO_VAL_CONSTANTS.c_ship_to_org_code_derv,
        p_lines                => x_lines
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- check derivation error for ship_to_location_id
    IF (x_lines.ship_to_loc_tbl(i) IS NOT NULL AND
        x_lines.ship_to_loc_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'ship_to loc id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'ship_to loc', x_lines.ship_to_loc_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => NULL,
        p_column_value         => NULL,
        p_validation_id        => PO_VAL_CONSTANTS.c_ship_to_location_derv,
        p_lines                => x_lines
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- <<PDOI Enhancement Bug#17063664 End>>

    -- derivation error for job_business_group_id
    IF (x_lines.job_business_group_name_tbl(i) IS NOT NULL AND
        x_lines.job_business_group_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'job business group id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'job business group name',
                    x_lines.job_business_group_name_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'JOB_BUSINESS_GROUP_ID',
        p_column_value         => x_lines.job_business_group_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'JOB_BUSINESS_GROUP_NAME',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_lines.job_business_group_name_tbl(i)
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    ELSIF (x_lines.job_name_tbl(i) IS NOT NULL AND  -- derivation error for job_id
           x_lines.job_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'job id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'job name',
                    x_lines.job_name_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'JOB_ID',
        p_column_value         => x_lines.job_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'JOB_NAME',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_lines.job_name_tbl(i),
        p_validation_id        => PO_VAL_CONSTANTS.c_job_name_derv,
        p_lines                => x_lines
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- derivation error for category_id
    IF (x_lines.category_tbl(i) IS NOT NULL AND
        x_lines.category_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'category id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'category name',
                    x_lines.category_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'CATEGORY_ID',
        p_column_value         => x_lines.category_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'CATEGORY',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_lines.category_tbl(i),
        p_validation_id        => PO_VAL_CONSTANTS.c_category_derv,
        p_lines                => x_lines
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- derivation error for ip_category_id
    IF (PO_PDOI_PARAMS.g_request.document_type IN
        (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
         PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)) THEN
      IF (x_lines.ip_category_tbl(i) IS NOT NULL AND
          x_lines.ip_category_id_tbl(i) IS NULL) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'ip category id derivation failed');
          PO_LOG.stmt(d_module, d_position, 'ip category name',
                      x_lines.ip_category_tbl(i));
        END IF;

        PO_PDOI_ERR_UTL.add_fatal_error
        (
          p_interface_header_id  => x_lines.intf_header_id_tbl(i),
          p_interface_line_id    => x_lines.intf_line_id_tbl(i),
          p_error_message_name   => 'PO_PDOI_DERV_ERROR',
          p_table_name           => 'PO_LINES_INTERFACE',
          p_column_name          => 'IP_CATEGORY_ID',
          p_column_value         => x_lines.ip_category_id_tbl(i),
          p_token1_name          => 'COLUMN_NAME',
          p_token1_value         => 'IP_CATEGORY',
          p_token2_name          => 'VALUE',
          p_token2_value         => x_lines.ip_category_tbl(i),
          p_validation_id        => PO_VAL_CONSTANTS.c_ip_category_derv,
          p_lines                => x_lines
        );

        x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
      END IF;
    END IF;

    -- derivation error for unit_of_measure
    IF (x_lines.uom_code_tbl(i) IS NOT NULL AND
        x_lines.unit_of_measure_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'unit of measure derivation failed');
        PO_LOG.stmt(d_module, d_position, 'uom code',
                    x_lines.uom_code_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'UNIT_OF_MEASURE',
        p_column_value         => x_lines.unit_of_measure_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'UOM_CODE',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_lines.uom_code_tbl(i),
        p_validation_id        => PO_VAL_CONSTANTS.c_uom_code_derv,
        p_lines                => x_lines
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- derivation error for line_type_id
    IF (x_lines.line_type_tbl(i) IS NOT NULL AND
        x_lines.line_type_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'line type id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'line type',
                    x_lines.line_type_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'LINE_TYPE_ID',
        p_column_value         => x_lines.line_type_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'LINE_TYPE',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_lines.line_type_tbl(i),
        p_validation_id        => PO_VAL_CONSTANTS.c_line_type_derv,
        p_lines                => x_lines
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- derivation error for un_number_id
    IF (x_lines.un_number_tbl(i) IS NOT NULL AND
        x_lines.un_number_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'un number id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'un number',
                    x_lines.un_number_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'UN_NUMBER_ID',
        p_column_value         => x_lines.un_number_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'UN_NUMBER',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_lines.un_number_tbl(i)
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- derivation error for hazard_class_id
    IF (x_lines.hazard_class_tbl(i) IS NOT NULL AND
        x_lines.hazard_class_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'hazard class id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'hazard class',
                    x_lines.hazard_class_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'HAZARD_CLASS_ID',
        p_column_value         => x_lines.hazard_class_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'HAZARD_CLASS',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_lines.hazard_class_tbl(i)
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- derivation error for template_id
    IF (x_lines.template_name_tbl(i) IS NOT NULL AND
        x_lines.template_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'template id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'template name',
                    x_lines.template_name_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'TEMPLATE_ID',
        p_column_value         => x_lines.template_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'TEMPLATE_NAME',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_lines.template_name_tbl(i)
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

  END LOOP;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_DERIVE);

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
END derive_lines;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_lines_for_update
--Function: peform derivation logic on line attributes when the
--          line level action is 'UPDATE'. The attributes include
--          unit_of_measure, po_category_id and ip_category_id
--Parameters:
--IN:
--IN OUT:
--  x_lines
--    record to store all the line rows within the batch;
--    Derivation are performed for certain attributes only
--    if their name value is populated but id value is not.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_lines_for_update
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_lines_for_update';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- key of temp table used to identify the derived result
  l_key po_session_gt.key%TYPE;

  -- table used to save the index of the each row
  l_index_tbl DBMS_SQL.NUMBER_TABLE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'line counts', x_lines.rec_count);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_DERIVE);

  -- assign a new key used in temporary table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize table containing the row number(index)
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size     => x_lines.rec_count,
    x_num_list => l_index_tbl
  );

  d_position := 10;

  -- derive PO category_id from PO category_name
  derive_category_id
  (
    p_key                  => l_key,
    p_category_tbl         => x_lines.category_tbl,
    x_category_id_tbl      => x_lines.category_id_tbl
  );

  /* Bug 13506679: un number id and hazard class id were not derived when the
                   action is update for updatable attributes */

    -- derive un_number_id from un_number
  derive_un_number_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_un_number_tbl        => x_lines.un_number_tbl,
    x_un_number_id_tbl     => x_lines.un_number_id_tbl
  );


  -- derive hazard_calss_id from hazard_class
  derive_hazard_class_id
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_hazard_class_tbl     => x_lines.hazard_class_tbl,
    x_hazard_class_id_tbl  => x_lines.hazard_class_id_tbl
  );

-- End Bug 13506679

  d_position := 20;

  IF (PO_PDOI_PARAMS.g_request.document_type IN
      (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
       PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)) THEN
    -- derive IP category_id from IP category_name
    derive_ip_category_id
    (
      p_key                    => l_key,
      p_index_tbl              => l_index_tbl,
      p_file_line_language_tbl => x_lines.file_line_language_tbl,
      p_ip_category_tbl        => x_lines.ip_category_tbl,
      x_ip_category_id_tbl     => x_lines.ip_category_id_tbl
    );

    d_position := 22;

    -- Bug 7577670: Derive ip_category_id from po_category_id
    -- if ip_category_id is null and po_category_id is not null
    default_ip_cat_id_from_po(p_key                 => l_key,
                              p_index_tbl           => l_index_tbl,
                              p_po_category_id_tbl  => x_lines.category_id_tbl,
                              x_ip_category_id_tbl  => x_lines.ip_category_id_tbl);

    d_position := 25;

    -- Bug 7577670: Derive po_category_id from ip_category_id
    -- if po_category_id is null and ip_category_id is not null
    default_po_cat_id_from_ip(p_key                 => l_key,
                              p_index_tbl           => l_index_tbl,
                              p_ip_category_id_tbl  => x_lines.ip_category_id_tbl,
                              x_po_category_id_tbl  => x_lines.category_id_tbl);
  END IF;

  d_position := 30;

  -- derive unit_of_measure from uom_code
  derive_unit_of_measure
  (
    p_key                  => l_key,
    p_index_tbl            => l_index_tbl,
    p_uom_code_tbl         => x_lines.uom_code_tbl,
    x_unit_of_measure_tbl  => x_lines.unit_of_measure_tbl
  );

  d_position := 40;

  -- handle all derivation errors
  FOR i IN 1..x_lines.rec_count
  LOOP
    d_position := 50;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
    END IF;

    -- derivation error for category_id
    IF (x_lines.category_tbl(i) IS NOT NULL AND
        x_lines.category_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'category id derivation failed');
        PO_LOG.stmt(d_module, d_position, 'category name',
                    x_lines.category_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'CATEGORY_ID',
        p_column_value         => x_lines.category_id_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'CATEGORY',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_lines.category_tbl(i)
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;

    -- derivation error for ip_category_id
    IF (PO_PDOI_PARAMS.g_request.document_type IN
        (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
         PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)) THEN
      IF (x_lines.ip_category_tbl(i) IS NOT NULL AND
          x_lines.ip_category_id_tbl(i) IS NULL) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'ip category id derivation failed');
          PO_LOG.stmt(d_module, d_position, 'ip category name',
                      x_lines.ip_category_tbl(i));
        END IF;

        PO_PDOI_ERR_UTL.add_fatal_error
        (
          p_interface_header_id  => x_lines.intf_header_id_tbl(i),
          p_interface_line_id    => x_lines.intf_line_id_tbl(i),
          p_error_message_name   => 'PO_PDOI_DERV_ERROR',
          p_table_name           => 'PO_LINES_INTERFACE',
          p_column_name          => 'IP_CATEGORY_ID',
          p_column_value         => x_lines.ip_category_id_tbl(i),
          p_token1_name          => 'COLUMN_NAME',
          p_token1_value         => 'IP_CATEGORY',
          p_token2_name          => 'VALUE',
          p_token2_value         => x_lines.ip_category_tbl(i)
        );

        x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
      END IF;
    END IF;

    -- derivation error for unit_of_measure
    IF (x_lines.uom_code_tbl(i) IS NOT NULL AND
        x_lines.unit_of_measure_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'unit of measure derivation failed');
        PO_LOG.stmt(d_module, d_position, 'uom code',
                    x_lines.uom_code_tbl(i));
      END IF;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => x_lines.intf_header_id_tbl(i),
        p_interface_line_id    => x_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_DERV_ERROR',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'UNIT_OF_MEASURE',
        p_column_value         => x_lines.unit_of_measure_tbl(i),
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'UOM_CODE',
        p_token2_name          => 'VALUE',
        p_token2_value         => x_lines.uom_code_tbl(i)
      );

      x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
    END IF;
  END LOOP;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_DERIVE);

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
END derive_lines_for_update;
-----------------------------------------------------------------------
--Start of Comments
--Name: default_lines
--Function: perform defaulting logic on line attributes
--Parameters:
--IN:
--IN OUT:
--  x_lines
--    record to store all the line rows within the batch;
--    defaulting are performed for certain attributes only
--    if their value is empty.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_lines
(
  x_lines IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- key of temp table used to identify the derived result
  l_key po_session_gt.key%TYPE;

  -- table used to save the index of the each row
  l_index_tbl DBMS_SQL.NUMBER_TABLE;

  -- information defaulted from line type
  l_li_category_id_tbl         PO_TBL_NUMBER;
  l_li_unit_of_measure_tbl     PO_TBL_VARCHAR30;
  l_li_unit_price_tbl          PO_TBL_NUMBER;

  -- information defaulted from item
  l_it_item_desc_tbl           PO_TBL_VARCHAR2000;
  l_it_unit_of_measure_tbl     PO_TBL_VARCHAR30;
  l_it_unit_price_tbl          PO_TBL_NUMBER;
  l_it_category_id_tbl         PO_TBL_NUMBER;
  l_it_un_number_id_tbl        PO_TBL_NUMBER;
  l_it_hazard_class_id_tbl     PO_TBL_NUMBER;
  l_it_market_price_tbl        PO_TBL_NUMBER;
  l_it_secondary_uom_tbl       PO_TBL_VARCHAR30;

  -- <<PDOI Enhancement Bug#17063664 Start>>
  -- information defaulted from requisition
  l_req_unit_of_measure_tbl    PO_TBL_VARCHAR30;
  l_req_ship_to_org_id_tbl     PO_TBL_NUMBER;
  l_req_ship_to_loc_id_tbl     PO_TBL_NUMBER;
  l_req_un_number_id_tbl       PO_TBL_NUMBER;
  l_req_hazard_class_id_tbl    PO_TBL_NUMBER;
  l_req_preferred_grade_tbl    PO_TBL_VARCHAR2000;
  l_req_negotiated_flag_tbl    PO_TBL_VARCHAR1;
  l_req_vendor_product_num_tbl PO_TBL_VARCHAR30;  -- Bug#17864040

  -- inventory organization_id from hr_locations_v
  l_inv_ship_to_org_id_tbl     PO_TBL_NUMBER;

  -- information defaulted from source document reference
  l_src_unit_of_measure_tbl    PO_TBL_VARCHAR30;
  l_src_negotiated_flag_tbl    PO_TBL_VARCHAR1;
  -- <<Bug#17864040 Start>>
  l_src_un_number_id_tbl       PO_TBL_NUMBER;
  l_src_hazard_class_id_tbl    PO_TBL_NUMBER;
  l_src_vendor_product_num_tbl PO_TBL_VARCHAR30;
  -- <<Bug#17864040 End>>

  -- <<PDOI Enhancement Bug#17063664 End>>

  -- Bug#17063664
  l_it_grade_cntl_flag_tbl     PO_TBL_VARCHAR1;

  -- Bug 16674612
  -- information defaulted from vendor
  l_it_type_1099_tbl           PO_TBL_VARCHAR15;

  -- Bug#17063664
  -- information defaulted from vendor site
  l_retainage_rate_tbl         PO_TBL_NUMBER;

  -- information defaulted from job
  l_job_item_desc_tbl          PO_TBL_VARCHAR2000;
  l_job_category_id_tbl        PO_TBL_NUMBER;

  -- information defaulted from ip category
  l_ic_category_id_tbl         PO_TBL_NUMBER; -- bug5130037

  -- bug 9194215 <start>
  x_currency_unit_price   NUMBER  := null;
  x_precision             NUMBER  := null;
  x_ext_precision         NUMBER  := null;
  x_min_acct_unit         NUMBER  := null;
  -- bug 9194215 <end>

  -- Bug 18891225 -- receiving control default values
  l_enforce_ship_to_loc_code     VARCHAR2(25);
  l_allow_sub_receipts_flag      VARCHAR2(1);
  l_receiving_routing_id         NUMBER;
  l_receiving_routing_name       rcv_routing_headers.routing_name%TYPE; -- Bug#17063664
  l_qty_rcv_tolerance            NUMBER;
  l_qty_rcv_exception            VARCHAR2(25);
  l_days_early_receipt_allowed   NUMBER;
  l_days_late_receipt_allowed    NUMBER;
  l_rct_days_exception_code      VARCHAR2(25);

  l_retainage_flag_tbl      PO_TBL_VARCHAR1; --bug19855072

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_DEFAULT);

  -- get key value to identify rows in po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize l_index_tbl
  FOR i IN 1..x_lines.rec_count
  LOOP
    l_index_tbl(i) := i;
    --bug19855072
    INSERT INTO po_session_gt (key,char1)
    SELECT l_key, retainage_flag
    FROM po_doc_style_headers
    WHERE style_id = x_lines.hd_style_id_tbl(i);
    --bug19855072
  END LOOP;

  --bug19855072
  DELETE FROM po_session_gt
  WHERE KEY = l_key
  RETURNING char1 BULK COLLECT INTO l_retainage_flag_tbl;
  --bug19855072

  -- <<PDOI Enhancement Bug#17063664 Start>>

  -- get default info from the requisition if backing req line id is provided,
  -- the attributes we can default from requisition include:
  -- line_type_id, item_id, item_revision, item_description, category_id, job_id,
  -- unit_price, unit_meas_lookup_code, negotiated_by_preparer_flag,
  -- oke_contract_header_id, oke_contract_version_id, preferred_grade,
  -- base_unit_price, hazard_class_id, price_break_lookup_code, quantity_committed,
  -- un_number_id  , need by_date
  default_info_from_req
  (
    p_key                    => l_key,
    p_index_tbl              => l_index_tbl,
    p_lines                  => x_lines,
    x_unit_of_measure_tbl    => l_req_unit_of_measure_tbl,
    x_ship_to_org_id_tbl     => l_req_ship_to_org_id_tbl,
    x_ship_to_loc_id_tbl     => l_req_ship_to_loc_id_tbl,
    x_un_number_id_tbl       => l_req_un_number_id_tbl,
    x_hazard_class_id_tbl    => l_req_hazard_class_id_tbl,
    x_preferred_grade_tbl    => l_req_preferred_grade_tbl,
    x_negotiated_flag_tbl    => l_req_negotiated_flag_tbl,
    x_vendor_product_num_tbl => l_req_vendor_product_num_tbl
  );

  -- get default info from the source document reference
  -- the attributes uom code and negotiated_flag can be defaulted
  -- from source document reference
  -- Bug#17864040: Added new parameters to fetch un number and
  --  hazard class id.
  default_info_from_source_ref
  (
    p_key                    => l_key,
    p_index_tbl              => l_index_tbl,
    p_from_header_id_tbl     => x_lines.from_header_id_tbl,
    p_from_line_id_tbl       => x_lines.from_line_id_tbl,
    p_contract_id_tbl        => x_lines.contract_id_tbl, --Bug 18891225
    x_unit_of_measure_tbl    => l_src_unit_of_measure_tbl,
    x_un_number_id_tbl       => l_src_un_number_id_tbl,
    x_hazard_class_id_tbl    => l_src_hazard_class_id_tbl,
    x_negotiated_flag_tbl    => l_src_negotiated_flag_tbl,
    x_vendor_product_num_tbl => l_src_vendor_product_num_tbl
  );

  -- <<PDOI Enhancement Bug#17063664 End>

 -- default line_type_id that will be used in other defaulting logic;
  FOR i IN 1..x_lines.rec_count
  LOOP
    d_position := 10;

    -- set default value for line_type_id
    IF (x_lines.line_type_id_tbl(i) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'set default line type id on line index', i);
      END IF;

      x_lines.line_type_id_tbl(i) := NVL( x_lines.line_type_id_tbl(i),
                                          PO_PDOI_PARAMS.g_sys.line_type_id);
    END IF;

  END LOOP;

  -- get default info from line type definition,
  -- the attributes we can default from line type include:
  -- order_type_lookup_code, purchasing_basis, matching_basis, category_id,
  -- unit_of_measure, unit_price
  default_info_from_line_type
  (
    p_key                        => l_key,
    p_index_tbl                  => l_index_tbl,
    p_line_type_id_tbl           => x_lines.line_type_id_tbl,
    x_order_type_lookup_code_tbl => x_lines.order_type_lookup_code_tbl,
    x_purchase_basis_tbl         => x_lines.purchase_basis_tbl,
    x_matching_basis_tbl         => x_lines.matching_basis_tbl,
    x_category_id_tbl            => l_li_category_id_tbl,
    x_unit_of_measure_tbl        => l_li_unit_of_measure_tbl,
    x_unit_price_tbl             => l_li_unit_price_tbl
  );

  d_position := 20;

  -- get default info from item definition
  -- the attributes we can default from item include:
  -- item_description, unit_of_measure, unit_price, category_id,
  -- un_number_id, hazard_class_id, market_price, secondary_unit_of_measure
  default_info_from_item
  (
    p_key                        => l_key,
    p_index_tbl                  => l_index_tbl,
    p_item_id_tbl                => x_lines.item_id_tbl,
    x_item_desc_tbl              => l_it_item_desc_tbl,
    x_unit_of_measure_tbl        => l_it_unit_of_measure_tbl,
    x_unit_price_tbl             => l_it_unit_price_tbl,
    x_category_id_tbl            => l_it_category_id_tbl,
    x_un_number_id_tbl           => l_it_un_number_id_tbl,
    x_hazard_class_id_tbl        => l_it_hazard_class_id_tbl,
    x_market_price_tbl           => l_it_market_price_tbl,
    x_secondary_unit_of_meas_tbl => l_it_secondary_uom_tbl,
    x_grade_control_flag_tbl     => l_it_grade_cntl_flag_tbl
  );

  -- Bug 16674612
  default_info_from_vendor
  (
    p_key                        => l_key,
    p_index_tbl                  => l_index_tbl,
    p_vendor_id_tbl              => x_lines.hd_vendor_id_tbl,
    x_type_1099_tbl              => l_it_type_1099_tbl
  );

  -- <<PDOI Enhancement Bug#17063664 Start>>
  default_info_from_vendor_site
  (
    p_key                        => l_key,
    p_index_tbl                  => l_index_tbl,
    p_vendor_site_id_tbl         => x_lines.hd_vendor_site_id_tbl,
    x_retainage_rate_tbl         => l_retainage_rate_tbl
  );

  -- <<PDOI Enhancement Bug#17063664 End>>

  d_position := 30;

  -- get default info from job
  -- the attributes we can default from job include:
  -- item_description, and category_id
  default_info_from_job
  (
    p_key                        => l_key,
    p_index_tbl                  => l_index_tbl,
    p_job_id_tbl                 => x_lines.job_id_tbl,
    x_item_desc_tbl              => l_job_item_desc_tbl,
    x_category_id_tbl            => l_job_category_id_tbl
  );

  d_position := 40;

  l_ic_category_id_tbl := PO_TBL_NUMBER();
  l_ic_category_id_tbl.EXTEND(x_lines.rec_count);

  IF (PO_PDOI_PARAMS.g_request.document_type IN
      (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
       PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)) THEN

    d_position := 50;

    -- get default po category ids from ip category ids
    default_po_cat_id_from_ip
    (
      p_key                        => l_key,
      p_index_tbl                  => l_index_tbl,
      p_ip_category_id_tbl         => x_lines.ip_category_id_tbl,
      x_po_category_id_tbl         => l_ic_category_id_tbl -- bug5130037
    );
  END IF;


  -- default attributes for each line
  FOR i IN 1..x_lines.rec_count
  LOOP
    d_position := 60;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
    END IF;

    -- bug5307208
    -- Effective and Expiration date should get truncated.
    x_lines.effective_date_tbl(i) := TRUNC(x_lines.effective_date_tbl(i));
    x_lines.expiration_date_tbl(i) := TRUNC(x_lines.expiration_date_tbl(i));

    -- bug 16674612
    -- default type_1099
    x_lines.type_1099_tbl(i) := l_it_type_1099_tbl(i);

    -- default preferred_grade
    IF l_it_grade_cntl_flag_tbl(i) = 'Y' THEN
      x_lines.preferred_grade_tbl(i) := NVL(x_lines.preferred_grade_tbl(i),
                                              l_req_preferred_grade_tbl(i));
    END IF;

    -- default retainage_rate
    -- bug19855072
    IF NVL(l_retainage_flag_tbl(i), 'N') = 'Y' THEN
      x_lines.retainage_rate_tbl(i) := NVL(x_lines.retainage_rate_tbl(i), l_retainage_rate_tbl(i));
    END IF;
    -- bug19855072
    -- <<PDOI Enhancement Bug#17063664 End>>

    -- default item_description
    x_lines.item_desc_tbl(i) :=
      COALESCE(x_lines.item_desc_tbl(i), l_it_item_desc_tbl(i),
               l_job_item_desc_tbl(i));

    -- default unit_of_measure
    x_lines.unit_of_measure_tbl(i) :=
      COALESCE(x_lines.unit_of_measure_tbl(i), l_src_unit_of_measure_tbl(i), l_req_unit_of_measure_tbl(i),
               l_it_unit_of_measure_tbl(i), l_li_unit_of_measure_tbl(i));

    -- default ship_to_location_id
    -- Bug#19663699 - default ship_to_location_id only if it is SPO
    IF (PO_PDOI_PARAMS.g_request.document_type =  PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
      x_lines.ship_to_loc_id_tbl(i) :=
        COALESCE(x_lines.ship_to_loc_id_tbl(i), l_req_ship_to_loc_id_tbl(i), x_lines.hd_ship_to_loc_id_tbl(i));
    END IF;      -- Bug#19663699

   --<PDOI Enhancement Bug#17063664>
   -- Not defaulting unit_price here.
   -- unit_price is updated later on after calling price break and Pricing API.
   -- Defaulting base_unit_price.
   -- Validation - base_unit_price cannot be populated
   -- as it is calucalated field.
   -- This has to be done only in standalone PDOI.
   -- From sourcing, consumption advice base unit price may be populated.
    IF PO_PDOI_PARAMS.g_request.calling_module NOT IN (PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING,
                                                    PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE)
         AND x_lines.base_unit_price_tbl(i) IS NOT NULL  THEN

            PO_PDOI_ERR_UTL.add_fatal_error
            (
              p_interface_header_id  => x_lines.intf_header_id_tbl(i),
              p_interface_line_id    => x_lines.intf_line_id_tbl(i),
              p_error_message_name   => 'PO_PDOI_BASE_PRICE_NULL',
              p_table_name           => 'PO_LINES_INTERFACE',
              p_column_name          => 'BASE_UNIT_PRICE',
              p_column_value         => x_lines.base_unit_price_tbl(i),
              p_lines                => x_lines
            );
            x_lines.error_flag_tbl(i) := FND_API.g_TRUE;
     END IF;

    IF ( x_lines.base_unit_price_tbl(i) IS NULL
        AND x_lines.order_type_lookup_code_tbl(i) <> 'FIXED PRICE') THEN

      IF (x_lines.order_type_lookup_code_tbl(i) = 'AMOUNT') THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'set price when order type is AMOUNT',
                      l_li_unit_price_tbl(i));
        END IF;

        x_lines.base_unit_price_tbl(i) := l_li_unit_price_tbl(i);
      ELSE
        IF (x_lines.item_id_tbl(i) IS NOT NULL) THEN
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'set price when item id is not empty',
                        l_it_unit_price_tbl(i));
          END IF;

          x_lines.base_unit_price_tbl(i) := l_it_unit_price_tbl(i);
        ELSE
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'set price when item id is empty',
                        NVL(l_li_unit_price_tbl(i), 0));
          END IF;

          x_lines.base_unit_price_tbl(i) := NVL(l_li_unit_price_tbl(i), 0);
        END IF;

        -- bug 9194215 <start>
        If x_lines.hd_currency_code_tbl(i) is not null and (x_lines.base_unit_price_tbl(i) is not null and x_lines.base_unit_price_tbl(i) <> 0) THEN
           fnd_currency.get_info (x_lines.hd_currency_code_tbl(i),
                            x_precision,
          x_ext_precision,
          x_min_acct_unit);
          x_currency_unit_price := round(x_lines.base_unit_price_tbl(i) / nvl(x_lines.hd_rate_tbl(i),1),x_ext_precision);
          x_lines.base_unit_price_tbl(i)      := x_currency_unit_price;

        END IF;
        -- bug 9194215 <end>
      END IF;

     END IF;

     --<PDOI Enhancement Bug#17063664>
     -- Defaulting unit_price only in case of QUOTATION.
     -- For Standard and Blanket it will be defaulted later on.
     IF PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION
        AND x_lines.unit_price_tbl(i) IS NULL THEN
        x_lines.unit_price_tbl(i) := x_lines.base_unit_price_tbl(i);
     END IF;

    -- default po category_id
    x_lines.category_id_tbl(i) :=
        COALESCE(x_lines.category_id_tbl(i), l_it_category_id_tbl(i),
                 l_job_category_id_tbl(i), l_ic_category_id_tbl(i),
                 l_li_category_id_tbl(i),
                 PO_PDOI_PARAMS.g_sys.def_category_id);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'default category id',
                  x_lines.category_id_tbl(i));
    END IF;

    -- default un_number_id and hazard_class_id from src doc/req/item
    -- Bug#17864040: Added logic to default un_number and hazard_class_id
    --  from source document
    x_lines.un_number_id_tbl(i) :=
        COALESCE(x_lines.un_number_id_tbl(i), l_src_un_number_id_tbl(i)
                  , l_req_un_number_id_tbl(i), l_it_un_number_id_tbl(i));
    x_lines.hazard_class_id_tbl(i) :=
        COALESCE(x_lines.hazard_class_id_tbl(i), l_src_hazard_class_id_tbl(i)
                  , l_req_hazard_class_id_tbl(i), l_it_hazard_class_id_tbl(i));

    --<PDOI Enhancement Bug#17063664>
    -- Should not set from_header_id and from_line_id as NULL

    -- set from_header_id and from_line_id to NULL
    --x_lines.from_header_id_tbl(i) := NULL;
    --x_lines.from_line_id_tbl(i) := NULL;

    d_position := 70;

    -- the following default logic is for BLANKET/STANDARD only
    IF (PO_PDOI_PARAMS.g_request.document_type IN
        (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
         PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD)) THEN
      d_position := 80;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'set default value for blanket/spo');
      END IF;

    -- <Bug#17063664  : PDOI source document reference ER>
    -- Using base_unit_price instead of unit_price.

      IF (x_lines.list_price_per_unit_tbl(i) IS NULL) THEN
        IF (x_lines.item_id_tbl(i) IS NULL) THEN
          x_lines.list_price_per_unit_tbl(i) := x_lines.base_unit_price_tbl(i);
 	  IF (PO_PDOI_PARAMS.g_request.document_type =
           PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN -- bug 9374205
	    -- bug 9194215 <start>
	    If x_lines.hd_currency_code_tbl(i) is not null and (x_lines.list_price_per_unit_tbl(i) is not null and x_lines.list_price_per_unit_tbl(i) <> 0) THEN
             fnd_currency.get_info (x_lines.hd_currency_code_tbl(i),
		                    x_precision,
				    x_ext_precision,
				    x_min_acct_unit);
				    x_currency_unit_price := round(x_lines.list_price_per_unit_tbl(i) * nvl(x_lines.hd_rate_tbl(i),1),x_ext_precision);
				    x_lines.list_price_per_unit_tbl(i)      := x_currency_unit_price;
            END IF;
            -- bug 9194215 <end>
           END IF;
        ELSE
          x_lines.list_price_per_unit_tbl(i) := l_it_unit_price_tbl(i);
        END IF;
      END IF;

      -- default market_price
      -- Bug#16834685: market price should have the value
      -- defined in mtl_system_items
      --
      IF (x_lines.market_price_tbl(i) IS NULL AND
          x_lines.item_id_tbl(i) IS NOT NULL) THEN
          --Bug#17063664 : Removed defaulting of market price with
          --    items unit price
        x_lines.market_price_tbl(i) := NVL(x_lines.market_price_tbl(i)
                                          , l_it_market_price_tbl(i));
      END IF;

      -- default capital_expense_flag,
      x_lines.capital_expense_flag_tbl(i) :=
          NVL(x_lines.capital_expense_flag_tbl(i), 'N');

      -- default min_release_amount, negotiated_flag and
      -- price_break_lookup_code for blanket
      IF (PO_PDOI_PARAMS.g_request.document_type =
          PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN
        d_position := 90;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'set default value for blanket');
        END IF;

        -- min_release_amount
        x_lines.min_release_amount_tbl(i) :=
            NVL(x_lines.min_release_amount_tbl(i),
            x_lines.hd_min_release_amount_tbl(i));

        -- negotiated_by_preparer_flag
        x_lines.negotiated_flag_tbl(i) :=
          NVL(x_lines.negotiated_flag_tbl(i), 'Y');

        -- price_break_lookup_code

        -- bug5129112
        -- Do not default price break lookup code for global agreements
        IF (x_lines.price_break_lookup_code_tbl(i) IS NULL) THEN
          IF (x_lines.hd_global_agreement_flag_tbl(i) = 'Y'
              OR
              ( x_lines.order_type_lookup_code_tbl(i) = 'FIXED PRICE' AND
                x_lines.purchase_basis_tbl(i) = 'SERVICES')) THEN
            x_lines.price_break_lookup_code_tbl(i) := NULL;
          ELSE
            x_lines.price_break_lookup_code_tbl(i) :=
              PO_PDOI_PARAMS.g_sys.price_break_lookup_code;
          END IF;
        END IF;
      ELSIF (PO_PDOI_PARAMS.g_request.document_type =
          PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN

        -- negotiated_by_preparer_flag
        x_lines.negotiated_flag_tbl(i) :=
          NVL(x_lines.negotiated_flag_tbl(i), 'Y');

      ELSE
        -- default tax_attribute_update_code for SPO
        x_lines.tax_attribute_update_code_tbl(i) := 'CREATE';

        -- negotiated_by_preparer_flag
        x_lines.negotiated_flag_tbl(i) :=
          NVL(x_lines.negotiated_flag_tbl(i), 'N');
      END IF;

      d_position := 100;

      -- default negotiated_by_preparer_flag
      -- Bug 18891225
      IF PO_PDOI_PARAMS.g_request.calling_module = PO_PDOI_CONSTANTS.g_CALL_MOD_SOURCING THEN
        x_lines.negotiated_flag_tbl(i) :='Y';
      ELSIF x_lines.from_header_id_tbl(i) IS NOT NULL
            OR x_lines.contract_id_tbl(i) IS NOT NULL
	    OR x_lines.requisition_line_id_tbl(i) IS NOT NULL THEN
        x_lines.negotiated_flag_tbl(i) := NVL(l_src_negotiated_flag_tbl(i)
                                            , l_req_negotiated_flag_tbl(i));
      END IF;

      -- default vendor_product_num
      x_lines.vendor_product_num_tbl(i) :=
          COALESCE(x_lines.vendor_product_num_tbl(i), l_src_vendor_product_num_tbl(i)
                    , l_req_vendor_product_num_tbl(i));

      -- default allow_price_override_flag
      x_lines.allow_price_override_flag_tbl(i) :=
          NVL(x_lines.allow_price_override_flag_tbl(i), 'N');

      -- default price_type
      x_lines.price_type_tbl(i) :=
          NVL(x_lines.price_type_tbl(i), PO_PDOI_PARAMS.g_sys.price_type_lookup_code);

      -- default closed_code
      x_lines.closed_code_tbl(i) :=
          NVL(x_lines.closed_code_tbl(i), 'OPEN');

      -- set unordered_flag, cancel_flag
      x_lines.unordered_flag_tbl(i) := 'N';
      x_lines.cancel_flag_tbl(i) := 'N';

      -- set quantity_committed from quantity
      -- Bug#19879160 : Quantity committed should be defaulted only for Blanket document
      IF PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET
      THEN
        x_lines.quantity_committed_tbl(i) := NVL(x_lines.quantity_committed_tbl(i)
                                                , x_lines.quantity_tbl(i));
      END IF;
      -- default secondary_unit_of_measure from item definition
      x_lines.secondary_unit_of_meas_tbl(i) :=
        NVL(x_lines.secondary_unit_of_meas_tbl(i), l_it_secondary_uom_tbl(i));

      -- Bug 18891225

      IF (PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD AND
          (x_lines.qty_rcv_tolerance_tbl(i) IS NULL OR
           x_lines.over_tolerance_err_flag_tbl(i) IS NULL)) THEN

	RCV_CORE_S.get_receiving_controls
	(
		p_order_type_lookup_code      => x_lines.order_type_lookup_code_tbl(i),
		p_purchase_basis              => x_lines.purchase_basis_tbl(i),
		p_line_location_id            => NULL,
		p_item_id                     => x_lines.item_id_tbl(i),
		p_org_id                      => x_lines.org_id_tbl(i),
		p_vendor_id                   => x_lines.hd_vendor_id_tbl(i),
		x_enforce_ship_to_loc_code    => l_enforce_ship_to_loc_code,
		x_allow_substitute_receipts   => l_allow_sub_receipts_flag,
		x_routing_id                  => l_receiving_routing_id,
		x_routing_name                => l_receiving_routing_name,
		x_qty_rcv_tolerance           => l_qty_rcv_tolerance,
		x_qty_rcv_exception_code      => l_qty_rcv_exception,
		x_days_early_receipt_allowed  => l_days_early_receipt_allowed,
		x_days_late_receipt_allowed   => l_days_late_receipt_allowed,
		x_receipt_days_exception_code => l_rct_days_exception_code
	);

	-- default qty_rcv_tolerance from receiving controls
	x_lines.qty_rcv_tolerance_tbl(i) :=
		NVL(x_lines.qty_rcv_tolerance_tbl(i), l_qty_rcv_tolerance);

	-- default qty_rcv_exception_code from receiving controls
	x_lines.over_tolerance_err_flag_tbl(i) :=
		NVL(x_lines.over_tolerance_err_flag_tbl(i), l_qty_rcv_exception);

      END IF;



    END IF;
  END LOOP;

  -- Bug#19663699 - default ship_to_organization_id from ship_to_location_id
  -- only if it is SPO
  --
  IF (PO_PDOI_PARAMS.g_request.document_type =  PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
    PO_PDOI_LINE_LOC_PROCESS_PVT.default_ship_to_org_id
    (
      p_key                   => l_key,
      p_index_tbl             => l_index_tbl,
      p_ship_to_loc_id_tbl    => x_lines.ship_to_loc_id_tbl,
      x_ship_to_org_id_tbl    => l_inv_ship_to_org_id_tbl
    );

    -- another loop to default ship_to_organization_id based on ship_to_location_id;
    FOR i IN 1..x_lines.rec_count
    LOOP
      -- default ship_to_organization_id
      x_lines.ship_to_org_id_tbl(i) :=
        COALESCE(x_lines.ship_to_org_id_tbl(i), l_req_ship_to_org_id_tbl(i)
                  , l_inv_ship_to_org_id_tbl(i), PO_PDOI_PARAMS.g_sys.def_inv_org_id);
    END LOOP;
  END IF;       -- Bug#19663699

  -- <<PDOI Enhancement Bug#17063664 Start>>

  -- default vendor_product_num and consigned_flag based on
  --  item, vendor, vendor_site and ship_to_org
  default_info_from_asl
  (
    p_key                     => l_key,
    p_index_tbl               => l_index_tbl,
    p_item_id_tbl             => x_lines.item_id_tbl,
    p_vendor_id_tbl           => x_lines.hd_vendor_id_tbl,
    p_vendor_site_id_tbl      => x_lines.hd_vendor_site_id_tbl,
    p_ship_to_org_id_tbl      => x_lines.ship_to_org_id_tbl,
    x_vendor_product_num_tbl  => x_lines.vendor_product_num_tbl,
    x_consigned_flag_tbl      => x_lines.consigned_flag_tbl
  );

  -- Update the attributes oke_contract_header_id and oke_contract_version_id
  -- with NULL when consigned
  FOR i IN 1..x_lines.rec_count
  LOOP
    IF (x_lines.consigned_flag_tbl(i) = 'Y') THEN
      x_lines.oke_contract_header_id_tbl(i) := NULL;
      x_lines.oke_contract_version_id_tbl(i) := NULL;
    END IF;
  END LOOP;

 --Bug#18707457
 x_lines.txn_flow_header_id_tbl := PO_TBL_NUMBER();
 x_lines.txn_flow_header_id_tbl.EXTEND(l_index_tbl.COUNT);

  -- Bug#18643508 The cross ou transaction flow header id
  -- should be defaulted only for standard Orders
  IF PO_PDOI_PARAMS.g_request.document_type =
         PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD  THEN
   -- default transaction header id
   default_txn_header_id
   (
     p_key                        => l_key,
     p_index_tbl                  => l_index_tbl,
     p_start_ou_id_tbl            => x_lines.org_id_tbl,
     p_ship_to_org_id_tbl         => x_lines.ship_to_org_id_tbl,
     p_item_category_id_tbl       => x_lines.category_id_tbl,
     x_txn_flow_header_id_tbl     => x_lines.txn_flow_header_id_tbl
    );

  END IF;
  -- Update ship to location ,ship to org, transaction id and consigned flag
  --  in po_lines_interface table
  FORALL i IN 1..x_lines.rec_count
    UPDATE po_lines_interface
    SET ship_to_location_id        = NVL(ship_to_location_id,x_lines.ship_to_loc_id_tbl(i))
      , ship_to_organization_id    = NVL(ship_to_organization_id,x_lines.ship_to_org_id_tbl(i))
      , consigned_flag             = x_lines.consigned_flag_tbl(i)
      , transaction_flow_header_id = x_lines.txn_flow_header_id_tbl(i)
      , quantity                   = NVL(quantity,x_lines.quantity_tbl(i))
      , amount                     = NVL(amount,x_lines.amount_tbl(i))
      , expiration_date            = NVL(expiration_date,x_lines.expiration_date_tbl(i))
      , secondary_unit_of_measure  = NVL(secondary_unit_of_measure,x_lines.secondary_unit_of_meas_tbl(i))
      , unit_of_measure            = NVL(unit_of_measure,x_lines.unit_of_measure_tbl(i))
      , need_by_date               = NVL(need_by_date,x_lines.need_by_date_tbl(i))
    WHERE interface_line_id        = x_lines.intf_line_id_tbl(i);

  -- <<PDOI Enhancement Bug#17063664 End>>

  IF (PO_PDOI_PARAMS.g_request.document_type IN
      (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
       PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION)) THEN

    -- default ip category id from po category ids after all other defaulting
    -- for po category ids have happened

    d_position := 105;

    -- get default ip category ids from po category ids
    default_ip_cat_id_from_po
    (
      p_key                        => l_key,
      p_index_tbl                  => l_index_tbl,
      p_po_category_id_tbl         => x_lines.category_id_tbl,
      x_ip_category_id_tbl         => x_lines.ip_category_id_tbl
    );


    -- If ip category id cannot be defaulted, set the value to -2.
    FOR i IN 1..x_lines.rec_count LOOP

      x_lines.ip_category_id_tbl(i) := NVL(x_lines.ip_category_id_tbl(i), -2);

    END LOOP;

  END IF;

  -- default hazard_class_id from un_number
  default_hc_id_from_un_number
  (
    p_key                      => l_key,
    p_index_tbl                => l_index_tbl,
    p_un_number_tbl            => x_lines.un_number_tbl,
    x_hazard_class_id_tbl      => x_lines.hazard_class_id_tbl
  );

  d_position := 110;

  -- call utility method to default standard who columns
  PO_PDOI_MAINPROC_UTL_PVT.default_who_columns
  (
    x_last_update_date_tbl       => x_lines.last_update_date_tbl,
    x_last_updated_by_tbl        => x_lines.last_updated_by_tbl,
    x_last_update_login_tbl      => x_lines.last_update_login_tbl,
    x_creation_date_tbl          => x_lines.creation_date_tbl,
    x_created_by_tbl             => x_lines.created_by_tbl,
    x_request_id_tbl             => x_lines.request_id_tbl,
    x_program_application_id_tbl => x_lines.program_application_id_tbl,
    x_program_id_tbl             => x_lines.program_id_tbl,
    x_program_update_date_tbl    => x_lines.program_update_date_tbl
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_DEFAULT);

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
END default_lines;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_lines_for_update
--Function: default certain attribute values from draft or txn tables;
--          These attributes are used in internal processing;
--          The attributes include:
--          order_type_lookup_code, item_id, job_id
--Parameters:
--IN:
--IN OUT:
--  x_lines
--    record to store all the line rows within the batch;
--    Defaulting is performed for certain attributes only.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_lines_for_update
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_lines_for_update';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- key of temp table used to identify the derived result
  l_key                    po_session_gt.key%TYPE;

  -- table used to save the index of the each row
  l_num_list               DBMS_SQL.NUMBER_TABLE;

  -- information defaulted from existing po line
  l_index_tbl              PO_TBL_NUMBER;
  l_order_type_tbl         PO_TBL_VARCHAR30;
  l_item_id_tbl            PO_TBL_NUMBER;
  l_job_id_tbl             PO_TBL_NUMBER;

  l_index                  NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'po_line_id', x_lines.po_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'draft_id', x_lines.draft_id_tbl);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_DERIVE);

  -- assign a new key used in temporary table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize table containing the row number(index)
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size     => x_lines.rec_count,
    x_num_list => l_num_list
  );

  d_position := 10;

  -- get values from draft tables
  FORALL i IN 1..l_num_list.COUNT
    INSERT INTO po_session_gt(key, num1, char1, num2, num3)
    SELECT l_key,
           l_num_list(i),
           order_type_lookup_code,
           item_id,
           job_id
    FROM   po_lines_draft_all
    WHERE  po_line_id = x_lines.po_line_id_tbl(i)
    AND    draft_id = x_lines.draft_id_tbl(i);

  d_position := 20;

  -- get values from txn table if no draft line exist
  FORALL i IN 1..l_num_list.COUNT
     INSERT INTO po_session_gt(key, num1, char1, num2, num3)
    SELECT l_key,
           l_num_list(i),
           order_type_lookup_code,
           item_id,
           job_id
    FROM   po_lines_all
    WHERE  po_line_id = x_lines.po_line_id_tbl(i)
    AND    NOT EXISTS (SELECT 1
                       FROM   po_lines_draft_all
                       WHERE  po_line_id = x_lines.po_line_id_tbl(i)
                       AND    draft_id = x_lines.draft_id_tbl(i));

  d_position := 30;

  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, char1, num2, num3 BULK COLLECT INTO
   l_index_tbl, l_order_type_tbl, l_item_id_tbl, l_job_id_tbl;

  d_position := 40;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_index_tbl', l_index_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_order_type_tbl', l_order_type_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_item_id_tbl', l_item_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_job_id_tbl', l_job_id_tbl);
  END IF;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);
    x_lines.order_type_lookup_code_tbl(l_index) := l_order_type_tbl(i);
    x_lines.item_id_tbl(l_index) := l_item_id_tbl(i);
    x_lines.job_id_tbl(l_index) := l_job_id_tbl(i);
  END LOOP;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_DERIVE);

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
END default_lines_for_update;

-----------------------------------------------------------------------
--Start of Comments
--Name: match_lines
--Function: perform matching logic on line num and item related info;
--          This procedure is called only when the document action is
--          'ORIGINAL' or 'REPLACE' or 'UPDATE Standard PO'
--Parameters:
--IN:
-- p_data_set_type
--IN OUT:
--  x_lines
--    record to store all the line rows within the batch;
--OUT:
-- PDOI Enhancement Bug#17063664 Added two out
-- parameters
--  x_create_lines
--   record to store all the lines to be created
--  x_update_lines
--   record to Store all the lines to be updated
--End of Comments
------------------------------------------------------------------------
PROCEDURE match_lines
(
  p_data_set_type  IN NUMBER,  -- bug5129752
  x_lines          IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_create_lines   OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_update_lines   OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_match_lines    OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'match_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index_tbl   DBMS_SQL.NUMBER_TABLE;


  -- PDOI Enhancement Bug#17063664
  l_match_lines  PO_PDOI_TYPES.lines_rec_type;
  l_create_lines PO_PDOI_TYPES.lines_rec_type;
  l_update_lines PO_PDOI_TYPES.lines_rec_type;

  l_rej_intf_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_MATCH);

  -- initialize index table
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size     => x_lines.rec_count,
    x_num_list => l_index_tbl
  );

  d_position := 10;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'start to match lines based on line num');
  END IF;

  -- bug5129752
  -- For FORCE ALL, simply set all line action to 'ADD'

  IF (p_data_set_type = PO_PDOI_CONSTANTS.g_LINE_CSR_FORCE_ADD AND
      PO_PDOI_PARAMS.g_request.calling_module <> PO_PDOI_CONSTANTS.g_CALL_MOD_CONCURRENT_PRGM ) THEN -- bug19479583
    d_position := 15;

    FOR i IN 1..x_lines.rec_count LOOP
      x_lines.po_line_id_tbl(i) :=
        PO_PDOI_MAINPROC_UTL_PVT.get_next_po_line_id;

      IF (x_lines.line_num_tbl(i) IS NULL) THEN
        x_lines.line_num_tbl(i) :=
          PO_PDOI_MAINPROC_UTL_PVT.get_next_line_num
          (x_lines.hd_po_header_id_tbl(i));
      END IF;

      x_lines.action_tbl(i) := PO_PDOI_CONSTANTS.g_ACTION_ADD;

    END LOOP;

  ELSE

    --<<PDOI Enhancement Bug#17063664 START>--
    d_position := 20;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'start to process lines to assign line number');
    END IF;
    -- This procedure is called to assign line number and po line id
    -- when lines should not be grouped
    -- 1. Grouping flag is 'N'
    -- 2. Complex PO
    assign_line_num
    (
       x_lines       => x_lines
    );
    --<<PDOI Enhancement Bug#17063664 END>--

    d_position := 30;
     -- match lines based on item related info
    match_lines_on_item_info
    (
      x_lines       => x_lines
    );

    DELETE FROM po_lines_gt;

  END IF;

  d_position := 40;
  -- check whether line location needs to be created for the line
  check_line_locations
  (
    x_lines       => x_lines
  );

  d_position := 50;

  --<<PDOI Enhancement Bug#17063664 START>--
  -- split lines based on action
  -- Added new parameter match lines.
  --  Create_lines - Lines to be created
  --  Update lines - Lines to be updated
  --    This will be case only having req reference and header
  --    action is update
  --  Match lines - Lines which are matched.
  --     all lines with action = 'MATCH' are location lines
  split_lines
  (
    p_group_num      => NULL,
    p_lines          => x_lines,
    x_create_lines   => l_create_lines,
    x_update_lines   => l_update_lines,
    x_match_lines    => l_match_lines
  );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'num of created lines', l_create_lines.rec_count);
    PO_LOG.stmt(d_module, d_position, 'num of updated lines', l_update_lines.rec_count);
    PO_LOG.stmt(d_module, d_position, 'num of matched lines', l_match_lines.rec_count);
  END IF;

  x_create_lines := l_create_lines;
  x_update_lines := l_update_lines;
  x_match_lines := l_match_lines;

  d_position := 60;

  -- update location only lines with new po_line_id and price_break_flag
  -- PDOI Enhancement Bug#17063664  : Added update for action column
  FORALL i IN 1..l_match_lines.rec_count
    UPDATE po_lines_interface
    SET    po_line_id = l_match_lines.po_line_id_tbl(i),
           action = l_match_lines.action_tbl(i),
           price_break_flag = 'Y'
    WHERE  interface_line_id = l_match_lines.intf_line_id_tbl(i);

  d_position := 70;

  -- reject lines that has action=MATCH and create_line_loc=N
  -- insert error message if the line is neither a po line or location
  FOR i IN 1..l_match_lines.rec_count
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      PO_LOG.stmt(d_module, d_position, 'create location flag',
                  l_match_lines.create_line_loc_tbl(i));

    END IF;

    IF (l_match_lines.create_line_loc_tbl(i) = FND_API.g_FALSE) THEN
      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => l_match_lines.intf_header_id_tbl(i),
        p_interface_line_id    => l_match_lines.intf_line_id_tbl(i),
        p_error_message_name   => 'PO_PDOI_INVALID_INTER_LINE_REC',
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'CREATE_PO_LINES_FLAG',
        p_column_value         => 'N',
        p_token1_name          => 'COLUMN_NAME',
        p_token1_value         => 'CREATE_PO_LINES_FLAG',
        p_token2_name          => 'VALUE',
        p_token2_value         => 'N'
      );

      l_rej_intf_line_id_tbl.EXTEND;
      l_rej_intf_line_id_tbl(l_rej_intf_line_id_tbl.COUNT) := l_match_lines.intf_line_id_tbl(i);
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'to be rejected intf line id',
                    l_match_lines.intf_line_id_tbl(i));

      END IF;
    END IF;
  END LOOP;
  --<<PDOI Enhancement Bug#17063664 END>--

  d_position := 80;

  PO_PDOI_UTL.reject_lines_intf
  (
    p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
    p_id_tbl          => l_rej_intf_line_id_tbl,
    p_cascade         => FND_API.g_TRUE
  );

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_MATCH);

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
END match_lines;

-----------------------------------------------------------------------
--Start of Comments
--Name: check_line_locations
--Function: In this procedure, we will check the if line locations
--          should be derived or not if they are not populated by user.
--Parameters:
--IN:
--IN OUT:
--  x_lines
--    record to store all the line rows within the batch;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE check_line_locations
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'check_line_locations';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key                           po_session_gt.key%TYPE;

  -- table storing the index of records within the batch
  l_index_tbl                     DBMS_SQL.NUMBER_TABLE;

  l_temp_index_tbl                PO_TBL_NUMBER;
  l_intf_header_id_tbl            PO_TBL_NUMBER;
  l_intf_line_id_tbl              PO_TBL_NUMBER;
  l_line_loc_populated_flag_tbl   PO_TBL_VARCHAR1;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- get key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- derive unit_of_measure from uom_code
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size     => x_lines.rec_count,
    x_num_list => l_index_tbl
  );

  d_position := 10;

  -- Bug#18643508 : The below validations should
  -- be done only for Standard Order
  IF PO_PDOI_PARAMS.g_request.document_type =
         PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD  THEN

    --SQL What: Insert line_id's into po_session_gt for which line_loc_populated_flag
    --  is 'Y' but line locations are not populated in the interface.
    --SQL Why: Need to reject all the lines for which line_loc_populated_flag
    --  is 'Y' but line locations are not populated in the interface.
    FORALL i IN 1..l_index_tbl.count
      INSERT INTO PO_SESSION_GT
      (KEY
       , num1   -- l_index_tbl
       , num2   -- interface_header_id
       , num3   -- interface_line_id
       , char1  -- line_loc_populated_flag
      )
      SELECT l_key
        , l_index_tbl(i)
        , x_lines.intf_header_id_tbl(i)
        , x_lines.intf_line_id_tbl(i)
        , x_lines.line_loc_populated_flag_tbl(i)
      FROM  DUAL
      WHERE x_lines.line_loc_populated_flag_tbl(i) = 'Y'
      AND x_lines.error_flag_tbl(i) = FND_API.g_FALSE
      AND NOT EXISTS
         (SELECT 'Line locations populated for the line'
          FROM po_line_locations_interface intf_line_locs
          WHERE intf_line_locs.interface_line_id = x_lines.intf_line_id_tbl(i));

     IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'Number of rows inserted into po_session_gt',
                    SQL%ROWCOUNT);
     END IF;

    d_position := 20;

    --SQL What: Insert line_id's into po_session_gt for which line_loc_populated_flag
    --  is 'N' but line locations are populated in the interface.
    --SQL Why: Need to reject all the lines for which line_loc_populated_flag
    --  is 'N' but line locations are populated in the interface.
    FORALL i IN 1..l_index_tbl.count
      INSERT INTO PO_SESSION_GT
      (KEY
       , num1   -- l_index_tbl
       , num2   -- interface_header_id
       , num3   -- interface_line_id
       , char1  -- line_loc_populated_flag
      )
      SELECT l_key
         , l_index_tbl(i)
         , x_lines.intf_header_id_tbl(i)
         , x_lines.intf_line_id_tbl(i)
         , x_lines.line_loc_populated_flag_tbl(i)
      FROM  DUAL
      WHERE x_lines.line_loc_populated_flag_tbl(i) = 'N'
      AND x_lines.error_flag_tbl(i) = FND_API.g_FALSE
      AND EXISTS
        (SELECT 'Line locations populated for the line'
         FROM po_line_locations_interface intf_line_locs
         WHERE intf_line_locs.interface_line_id = x_lines.intf_line_id_tbl(i));

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Number of rows inserted into po_session_gt',
                    SQL%ROWCOUNT);
    END IF;

    d_position := 30;

    -- Fetch the data and insert into temp tables
    DELETE FROM po_session_gt
    WHERE KEY = l_key
    RETURNING num1, num2, num3, char1 BULK COLLECT INTO l_temp_index_tbl, l_intf_header_id_tbl
      , l_intf_line_id_tbl, l_line_loc_populated_flag_tbl;

    d_position := 40;

    -- Check whether line locations are populated based on the line_loc_populated_flag.
    FOR i IN 1..l_intf_line_id_tbl.COUNT
    LOOP
      IF (l_line_loc_populated_flag_tbl(i) = 'Y') THEN

        d_position := 50;

        -- Add an error when line having line_loc_populated_flag as 'Y'
        --  but line locations are not populated in the interface.
        PO_PDOI_ERR_UTL.add_fatal_error
        (
          p_interface_header_id  => l_intf_header_id_tbl(i),
          p_interface_line_id    => l_intf_line_id_tbl(i),
          p_error_message_name   => 'PO_PDOI_LINE_LOCS_NOT_POPL',
          p_table_name           => 'PO_LINES_INTERFACE',
          p_column_name          => 'INTERFACE_LINE_ID',
          p_column_value         => l_intf_line_id_tbl(i)
        );

      ELSE
        d_position := 60;

        -- Add an error when line having line_loc_populated_flag as 'N'
        --  but line locations are populated in the interface.
        PO_PDOI_ERR_UTL.add_fatal_error
        (
         p_interface_header_id  => l_intf_header_id_tbl(i),
         p_interface_line_id    => l_intf_line_id_tbl(i),
         p_error_message_name   => 'PO_PDOI_LINE_LOCS_POPL',
         p_table_name           => 'PO_LINES_INTERFACE',
         p_column_name          => 'INTERFACE_LINE_ID',
         p_column_value         => l_intf_line_id_tbl(i)
        );

      END IF;

      d_position := 70;

      x_lines.error_flag_tbl(l_temp_index_tbl(i)) := 'Y';

    END LOOP;

  END IF; -- End of condition to check the document type

  d_position := 80;

  -- check whether location should be created on each line
  FOR i IN 1..x_lines.rec_count
  LOOP
    d_position := 90;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      PO_LOG.stmt(d_module, d_position, 'loc populated flag',
                  x_lines.line_loc_populated_flag_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'error flag',
                  x_lines.error_flag_tbl(i));
    END IF;

    -- PDOI Enhancement Bug#17063664
    -- Changed the flag check from 'S' to  'N' since
    -- the line location population logic has been
    -- moved to process_line_locs
    IF (x_lines.line_loc_populated_flag_tbl(i) = 'N')
      AND x_lines.error_flag_tbl(i) = FND_API.g_FALSE THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'document type',
                    PO_PDOI_PARAMS.g_request.document_type);
        PO_LOG.stmt(d_module, d_position, 'order_type_lookup_code',
                    x_lines.order_type_lookup_code_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'action',
                    x_lines.action_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'quantity',
                    x_lines.quantity_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'shipment_num',
                    x_lines.shipment_num_tbl(i));
      END IF;
      -- set to TRUE in certain conditions
      IF (PO_PDOI_PARAMS.g_request.document_type =
          PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN
        IF (x_lines.order_type_lookup_code_tbl(i) IN ('QUANTITY', 'RATE') AND
            --bug19479583 x_lines.action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_UPDATE AND
            (x_lines.quantity_tbl(i) > 0 OR x_lines.shipment_num_tbl(i) IS NOT NULL)) THEN
          x_lines.create_line_loc_tbl(i) := FND_API.g_TRUE;
        END IF;
      ELSIF (PO_PDOI_PARAMS.g_request.document_type =
             PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD) THEN
        IF (x_lines.order_type_lookup_code_tbl(i) IN ('FIXED PRICE', 'RATE') OR
            x_lines.quantity_tbl(i) > 0) THEN
          x_lines.create_line_loc_tbl(i) := FND_API.g_TRUE;
        END IF;
      ELSIF (PO_PDOI_PARAMS.g_request.document_type =
             PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) THEN
        IF (x_lines.order_type_lookup_code_tbl(i) = 'QUANTITY' AND
            (x_lines.quantity_tbl(i) > 0 OR x_lines.shipment_num_tbl(i) IS NOT NULL)) THEN
          x_lines.create_line_loc_tbl(i) := FND_API.g_TRUE;
        END IF;
      END IF;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'create_line_loc',
                    x_lines.create_line_loc_tbl(i));
      END IF;

      d_position := 100;

      -- update line locations populated flag to 'R' when create_line_loc is FALSE
      IF (x_lines.create_line_loc_tbl(i) = FND_API.g_FALSE) THEN
        x_lines.line_loc_populated_flag_tbl(i) := 'R';
      END IF;

    ELSIF x_lines.line_loc_populated_flag_tbl(i) ='Y' THEN
       x_lines.create_line_loc_tbl(i) := FND_API.g_TRUE;
    END IF;
  END LOOP;

  d_position := 110;

  -- update line locations populated flag to 'R' in interface table
  FORALL i IN 1..x_lines.rec_count
    UPDATE po_lines_interface pli
    SET    pli.line_loc_populated_flag = 'R'
    WHERE interface_line_id = x_lines.intf_line_id_tbl(i)
    AND   x_lines.line_loc_populated_flag_tbl(i) = 'R';

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
END check_line_locations;

-----------------------------------------------------------------------
--Start of Comments
--Name: update_line_intf_tbl
--Function: After line processing, set po_line_id, extracted line
--          level action and price tolerance back to interface table
--Parameters:
--IN:
--IN OUT:
--  x_lines
--    record which stores all the line rows within the batch;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_line_intf_tbl
(
  x_lines    IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'update_line_intf_tbl';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  FOR i IN 1..x_lines.rec_count
  LOOP
    IF (NVL(x_lines.process_code_tbl(i), PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
          = PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING AND
        NVL(PO_PDOI_PARAMS.g_request.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING) =
          PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
       OR
       (NVL(x_lines.process_code_tbl(i), PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING)
          = PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING AND
        NVL(PO_PDOI_PARAMS.g_request.process_code, PO_PDOI_CONSTANTS.g_PROCESS_CODE_PENDING) =
          PO_PDOI_CONSTANTS.g_PROCESS_CODE_NOTIFIED) THEN

      IF (x_lines.error_flag_tbl(i) = FND_API.g_FALSE AND
          x_lines.need_to_reject_flag_tbl(i) = FND_API.g_FALSE) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'update line process code to ACCEPTED. Index = ', i);
        END IF;

        x_lines.process_code_tbl(i) := PO_PDOI_CONSTANTS.g_PROCESS_CODE_ACCEPTED;
      END IF;
    END IF;
  END LOOP;

  d_position := 20;

  --PDOI Enhancement Bug#17063664 : Changed the logic to update price break flag
  --to handle new action 'MATCH'
  FORALL i IN 1.. x_lines.rec_count
    UPDATE po_lines_interface
    SET    po_line_id = x_lines.po_line_id_tbl(i),
	   po_header_id = x_lines.hd_po_header_id_tbl(i),
           price_update_tolerance = x_lines.price_update_tolerance_tbl(i),
           action = x_lines.action_tbl(i),
           price_break_flag = DECODE(x_lines.action_tbl(i),PO_PDOI_CONSTANTS.g_ACTION_ORIGINAL,NULL,
	                                                   PO_PDOI_CONSTANTS.g_ACTION_ADD,NULL,
				      DECODE(x_lines.create_line_loc_tbl(i),FND_API.g_TRUE,'Y', NULL)),
           process_code = x_lines.process_code_tbl(i),
           parent_interface_line_id = x_lines.parent_interface_line_id_tbl(i) -- bug5149827
    WHERE  interface_line_id = x_lines.intf_line_id_tbl(i);
    --AND    x_lines.error_flag_tbl(i) = FND_API.g_FALSE
    --AND    x_lines.need_to_reject_flag_tbl(i) = FND_API.g_FALSE;

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
END update_line_intf_tbl;

-----------------------------------------------------------------------
--Start of Comments
--Name: uniqueness_check
--Function: If document level action is 'UPDATE' on Blanket and Quotation,
--          uniqueness check needs to be performed on each line to
--          determine the line level action if it is not specified as
--          'ADD' by the customer.
--Parameters:
--IN:
--  p_type
--    flag to determine on which attributes the check will be performed
--  p_group_num
--    current group number in the batch
--IN OUT:
--  x_processing_row_tbl
--    table to indicate whether action has been determined for each row
--    within the batch
--  x_lines
--    record which stores all the line rows within the batch
--  x_expire_line_id_tbl
--    table to store list of lines that are going to be expired
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE uniqueness_check
(
  p_type                  IN NUMBER,
  p_group_num             IN NUMBER,
  x_processing_row_tbl    IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines                 IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_expire_line_id_tbl    OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_expire_line_index_tbl OUT NOCOPY DBMS_SQL.NUMBER_TABLE --bug19046588
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'uniqueness_check';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- key of temp table used to identify the records
  l_key                   po_session_gt.key%TYPE;

  -- table storing the index of records within the batch
  l_index_tbl             DBMS_SQL.NUMBER_TABLE;
  l_index                 NUMBER;

  -- store the index of lines that need to be expired
  --l_expire_line_index_tbl PO_TBL_NUMBER; bug19046588

  -- counter
  l_count                 NUMBER := 0;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_type', p_type);
    PO_LOG.proc_begin(d_module, 'p_group_num', p_group_num);

    l_index := x_processing_row_tbl.FIRST;
    WHILE (l_index IS NOT NULL)
    LOOP
      PO_LOG.proc_begin(d_module, 'to be processed index', l_index);
      l_index := x_processing_row_tbl.NEXT(l_index);
    END LOOP;
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_UNIQUENESS_CHECK);

  -- get key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- call individual uniqueness check procedure for each unique criteria
  IF (p_type = PO_PDOI_CONSTANTS.g_LINE_CSR_SYNC_ON_DESC) THEN
    d_position := 10;

    uniqueness_check_on_desc
    (
      p_key                 => l_key,
      p_group_num           => p_group_num,
      x_processing_row_tbl  => x_processing_row_tbl,
      x_lines               => x_lines
    );
  ELSE
    d_position := 20;

    -- uniqueness check on item + revision + vendor_product_num +
    -- supplier_part_auxid if item is not null
    uniqueness_check_on_item
    (
      p_key                 => l_key,
      p_group_num           => p_group_num,
      x_processing_row_tbl  => x_processing_row_tbl,
      x_lines               => x_lines
    );

    d_position := 30;

    -- uniquess check on vendor_product_num + supplier_part_auxid if item
    -- is null but vendor_product_num is not null
    uniqueness_check_on_vpn
    (
      p_key                 => l_key,
      p_group_num           => p_group_num,
      x_processing_row_tbl  => x_processing_row_tbl,
      x_lines               => x_lines
    );

    d_position := 40;

    -- uniquess check on job_name if both item and vendor_product_num are null
    uniqueness_check_on_job
    (
      p_key                 => l_key,
      p_group_num           => p_group_num,
      x_processing_row_tbl  => x_processing_row_tbl,
      x_lines               => x_lines
    );

    d_position := 50;

    -- uniquess check on line_num if item, vendor_product_num and job_name
    -- are all null
    uniqueness_check_on_line_num
    (
      p_key                 => l_key,
      p_group_num           => p_group_num,
      x_processing_row_tbl  => x_processing_row_tbl,
      x_lines               => x_lines
    );

    -- set action to ADD for lines that does not have any
    -- matching attributes specified
    FOR i IN 1..x_lines.rec_count
    LOOP
      d_position := 60;

      IF (x_lines.item_tbl(i) IS NULL AND
          x_lines.vendor_product_num_tbl(i) IS NULL AND
      x_lines.job_name_tbl(i) IS NULL AND
          x_lines.line_num_tbl(i) IS NULL) THEN

        x_lines.action_tbl(i) := PO_PDOI_CONSTANTS.g_ACTION_ADD;
        x_lines.group_num_tbl(i) := p_group_num;
        x_lines.po_line_id_tbl(i) := PO_PDOI_MAINPROC_UTL_PVT.get_next_po_line_id;
        x_lines.line_num_tbl(i) :=
          PO_PDOI_MAINPROC_UTL_PVT.get_next_line_num
          (
            p_po_header_id  => x_lines.hd_po_header_id_tbl(i)
          );
        x_processing_row_tbl.DELETE(i);

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'set action to ADD '||
                      'since all uniqueness criteria are empty');
          PO_LOG.stmt(d_module, d_position, 'index', i);
          PO_LOG.stmt(d_module, d_position, 'new po line id',
                      x_lines.po_line_id_tbl(i));
          PO_LOG.stmt(d_module, d_position, 'new line num',
                      x_lines.line_num_tbl(i));
        END IF;
      END IF;
    END LOOP;
  END IF;

  d_position := 70;

  -- If there is release shipment for a blanket line, and uom is changed,
  -- the existing matching line will be expired and the new line's action
  --  will be ADD instead of UPDATE
  IF (PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) THEN
    d_position := 80;

    -- derive unit_of_measure from uom_code
    PO_PDOI_UTL.generate_ordered_num_list
    (
      p_size     => x_lines.rec_count,
      x_num_list => l_index_tbl
    );

    derive_unit_of_measure
    (
      p_key                  => l_key,
      p_index_tbl            => l_index_tbl,
      p_uom_code_tbl         => x_lines.uom_code_tbl,
      x_unit_of_measure_tbl  => x_lines.unit_of_measure_tbl
    );

    d_position := 90;

    -- check whether uom changed for a line that has a release shipment
    FORALL i IN 1..x_lines.rec_count
      INSERT INTO po_session_gt(key, num1)
      SELECT l_key,
             l_index_tbl(i)
      FROM   po_lines txn_lines
      WHERE  txn_lines.po_line_id = x_lines.po_line_id_tbl(i)
      AND    x_lines.unit_of_measure_tbl(i) IS NOT NULL
      AND    txn_lines.unit_meas_lookup_code IS NOT NULL
      AND    txn_lines.unit_meas_lookup_code <>
             x_lines.unit_of_measure_tbl(i)
      AND    (EXISTS (SELECT 1
                      FROM   po_line_locations
                      WHERE  po_line_id = txn_lines.po_line_id
                      AND    shipment_type = 'BLANKET')
              OR
              EXISTS (SELECT 1
                      FROM   po_lines_all
                      WHERE  from_line_id = txn_lines.po_line_id)
             );

    DELETE FROM po_session_gt
    WHERE key = l_key
    RETURNING num1 BULK COLLECT INTO x_expire_line_index_tbl; --bug19046588

    FOR i IN 1..x_expire_line_index_tbl.COUNT --bug19046588
    LOOP
      l_index := x_expire_line_index_tbl(i); --bug19046588

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'expire index', i);
        PO_LOG.stmt(d_module, d_position, 'expired line id',
                    x_lines.po_line_id_tbl(l_index));
      END IF;

      x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_ADD;
      l_count := l_count + 1;
      x_expire_line_id_tbl(l_count) := x_lines.po_line_id_tbl(l_index);
      x_lines.po_line_id_tbl(l_index) :=
        PO_PDOI_MAINPROC_UTL_PVT.get_next_po_line_id;
      IF (x_lines.origin_line_num_tbl(l_index) IS NULL OR
          x_lines.line_num_unique_tbl(l_index) = FND_API.g_FALSE) THEN
        x_lines.line_num_tbl(l_index) :=
          PO_PDOI_MAINPROC_UTL_PVT.get_next_line_num
          (
            p_po_header_id => x_lines.hd_po_header_id_tbl(i)
          );

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'original line num',
                      x_lines.origin_line_num_tbl(l_index));
          PO_LOG.stmt(d_module, d_position, 'if line num unique',
                      x_lines.line_num_unique_tbl(l_index));
          PO_LOG.stmt(d_module, d_position, 'new line num',
                      x_lines.line_num_tbl(l_index));
        END IF;
      END IF;
    END LOOP;
  END IF;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_UNIQUENESS_CHECK);

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
END uniqueness_check;

-----------------------------------------------------------------------
--Start of Comments
--Name: split_lines
--Function: separate the lines within a group depending on action
--Parameters:
--IN:
--  p_group_num
--    current group number
--  p_lines
--    record containing all line info within the batch
--IN OUT:
--  x_create_lines
--    record containging lines that are going to be created
--  x_update_lines
--    record containing lines that are going to be updated
--  x_match_lines
--    record containing lines that are matched
--  PDOI Enhancement Bug#17063664 : Add logic to get match records
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE split_lines
(
  p_group_num             IN NUMBER,
  p_lines                 IN PO_PDOI_TYPES.lines_rec_type,
  x_create_lines          IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_update_lines          IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_match_lines           IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'split_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- store index of rows to be copied to different records
  l_create_index_tbl   DBMS_SQL.NUMBER_TABLE;
  l_update_index_tbl   DBMS_SQL.NUMBER_TABLE;
  l_match_index_tbl    DBMS_SQL.NUMBER_TABLE;
  l_error_index_tbl DBMS_SQL.NUMBER_TABLE;     -- Bug 19365210
  l_error_lines PO_PDOI_TYPES.lines_rec_type;  -- Bug 19365210

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_group_num', p_group_num);
    PO_LOG.proc_begin(d_module, 'group_num_tbl', p_lines.group_num_tbl);
    PO_LOG.proc_begin(d_module, 'action_tbl', p_lines.action_tbl);
    PO_LOG.proc_begin(d_module, 'error_flag_tbl', p_lines.error_flag_tbl);
  END IF;

  FOR i IN 1..p_lines.rec_count
  LOOP
    d_position := 10;

    IF (p_group_num IS NULL OR p_lines.group_num_tbl(i) = p_group_num) AND
        p_lines.error_flag_tbl(i) = FND_API.g_FALSE THEN
      IF (p_lines.action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_ADD) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'lines to create', p_lines.po_line_id_tbl(i));
        END IF;

        l_create_index_tbl(i) := i;
      ELSIF (p_lines.action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_UPDATE) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'lines to update', p_lines.po_line_id_tbl(i));
        END IF;

        l_update_index_tbl(i) := i;
      ELSIF (p_lines.action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_MATCH) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'lines to match', p_lines.po_line_id_tbl(i));
        END IF;

        l_match_index_tbl(i) := i;
      END IF;
    --bug19365210 begin
    ELSE
      l_error_index_tbl(i) := i;
    --bug19365210 end
    --bug20379771 begin
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'lines to reject', p_lines.po_line_id_tbl(i));
      END IF;
      UPDATE po_lines_interface
      SET process_code = PO_PDOI_CONSTANTS.g_PROCESS_CODE_REJECTED,
          processing_id = -PO_PDOI_PARAMS.g_processing_id
      WHERE interface_line_id = p_lines.intf_line_id_tbl(i)
      AND processing_id = PO_PDOI_PARAMS.g_processing_id;
    --bug20379771 end
    END IF;
  END LOOP;

  d_position := 20;

  -- copy rows to insert record
  copy_lines
  (
    p_source_lines     => p_lines,
    p_source_index_tbl => l_create_index_tbl,
    x_target_lines     => x_create_lines
  );

  d_position := 30;

  -- copy rows to update record
  copy_lines
  (
    p_source_lines     => p_lines,
    p_source_index_tbl => l_update_index_tbl,
    x_target_lines     => x_update_lines
  );

  d_position := 40;
  -- copy rows to match record
  copy_lines
  (
    p_source_lines     => p_lines,
    p_source_index_tbl => l_match_index_tbl,
    x_target_lines     => x_match_lines
  );

  -- Bug 19365210 begin
  -- copy error lines to be processed in handle_err_tolerance
  copy_lines
  (
    p_source_lines     => p_lines,
    p_source_index_tbl => l_error_index_tbl,
    x_target_lines     => l_error_lines
  );

  handle_err_tolerance
  (
    x_lines => l_error_lines
  );
  -- Bug 19365210 end

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
END split_lines;

-----------------------------------------------------------------------
--Start of Comments
--Name: validate_lines
--Function: validate line attributes; the validation of attribute values
--          tlp table will be called here as well in order to track the
--          number of error lines.
--Parameters:
--IN:
--  p_action
--    indicate whether the po lines are going to be created or updated;
--    the values can be 'CREATE' or 'UPDATE'
--IN OUT:
--  x_lines
--    record which stores all the line rows within the batch;
--    If there is error(s) on any attribute of the location row,
--    corresponding value in error_flag_tbl will be set with value
--    FND_API.g_TRUE.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE validate_lines
(
  p_action      IN VARCHAR2 DEFAULT 'CREATE',
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'validate_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_lines                 PO_LINES_VAL_TYPE := PO_LINES_VAL_TYPE();
  l_result_type           VARCHAR2(30);
  l_results               po_validation_results_type;
  l_parameter_name_tbl    PO_TBL_VARCHAR2000 := PO_TBL_VARCHAR2000();
  l_parameter_value_tbl   PO_TBL_VARCHAR2000 := PO_TBL_VARCHAR2000();
  l_inventory_org_id_tbl  PO_TBL_NUMBER := PO_TBL_NUMBER();
  -- PDOI Enhancement Bug#17063664
  l_org_id_tbl  PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_hdr_type_lookup_code_tbl  PO_TBL_VARCHAR30 := PO_TBL_VARCHAR30();

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'action', p_action);
  END IF;

  PO_TIMING_UTL.start_time(PO_PDOI_CONSTANTS.g_T_LINE_VALIDATE);

  l_lines.interface_id                    := x_lines.intf_line_id_tbl;
  l_lines.over_tolerance_error_flag       := x_lines.over_tolerance_err_flag_tbl;
  l_lines.expiration_date                 := x_lines.expiration_date_tbl;
  l_lines.hdr_start_date                  := x_lines.hd_start_date_tbl;
  l_lines.hdr_end_date                    := x_lines.hd_end_date_tbl;
  l_lines.global_agreement_flag           := x_lines.hd_global_agreement_flag_tbl;
  l_lines.purchase_basis                  := x_lines.purchase_basis_tbl;
  l_lines.line_type_id                    := x_lines.line_type_id_tbl;
  l_lines.amount                          := x_lines.amount_tbl;
  l_lines.contractor_last_name            := x_lines.contractor_last_name_tbl;
  l_lines.contractor_first_name           := x_lines.contractor_first_name_tbl;
  l_lines.job_id                          := x_lines.job_id_tbl;
  l_lines.job_business_group_id           := x_lines.job_business_group_id_tbl;
  l_lines.capital_expense_flag            := x_lines.capital_expense_flag_tbl;
  l_lines.un_number_id                    := x_lines.un_number_id_tbl;
  l_lines.hazard_class_id                 := x_lines.hazard_class_id_tbl;
  l_lines.item_id                         := x_lines.item_id_tbl;
  l_lines.order_type_lookup_code          := x_lines.order_type_lookup_code_tbl;
  l_lines.item_description                := x_lines.item_desc_tbl;
  l_lines.unit_meas_lookup_code           := x_lines.unit_of_measure_tbl;
  l_lines.item_revision                   := x_lines.item_revision_tbl;
  l_lines.category_id                     := x_lines.category_id_tbl;
  l_lines.ip_category_id                  := x_lines.ip_category_id_tbl;
  l_lines.unit_price                      := x_lines.unit_price_tbl;
  l_lines.quantity                        := x_lines.quantity_tbl;
  l_lines.po_header_id                    := x_lines.hd_po_header_id_tbl;
  l_lines.po_line_id                      := x_lines.po_line_id_tbl;
  l_lines.line_num                        := x_lines.line_num_tbl;
  l_lines.price_type_lookup_code          := x_lines.price_type_tbl;
  l_lines.start_date                      := x_lines.effective_date_tbl;
  l_lines.expiration_date                 := x_lines.expiration_date_tbl;
  l_lines.not_to_exceed_price             := x_lines.not_to_exceed_price_tbl;
  l_lines.release_num                     := x_lines.release_num_tbl;
  l_lines.po_release_id                   := x_lines.po_release_id_tbl;
  l_lines.source_shipment_id              := x_lines.source_shipment_id_tbl;
  l_lines.contract_num                    := x_lines.contract_num_tbl;
  l_lines.contract_id                     := x_lines.contract_id_tbl;
  l_lines.type_1099                       := x_lines.type_1099_tbl;
  l_lines.closed_code                     := x_lines.closed_code_tbl;
  l_lines.closed_date                     := x_lines.closed_date_tbl;
  l_lines.closed_by                       := x_lines.closed_by_tbl;
  l_lines.market_price                    := x_lines.market_price_tbl;
  l_lines.committed_amount                := x_lines.committed_amount_tbl;
  l_lines.shipment_num                    := x_lines.shipment_num_tbl;
  l_lines.capital_expense_flag            := x_lines.capital_expense_flag_tbl;
  l_lines.min_release_amount              := x_lines.min_release_amount_tbl;
  l_lines.allow_price_override_flag       := x_lines.allow_price_override_flag_tbl;
  l_lines.negotiated_by_preparer_flag     := x_lines.negotiated_flag_tbl;
  l_lines.secondary_unit_of_measure       := x_lines.secondary_unit_of_meas_tbl;
  l_lines.secondary_quantity              := x_lines.secondary_quantity_tbl;
  l_lines.preferred_grade                 := x_lines.preferred_grade_tbl;
  l_lines.item                            := x_lines.item_tbl;
  l_lines.hdr_style_id                    := x_lines.hd_style_id_tbl;
  l_lines.price_break_lookup_code         := x_lines.price_break_lookup_code_tbl; -- bug5016163
  l_lines.draft_id                        := x_lines.draft_id_tbl; -- bug5258790
  l_lines.hdr_rate_type                   := x_lines.hd_rate_type_tbl; -- bug 5451908
    -- << PDOI for Complex PO Project: Start >>
  l_lines.retainage_rate                  := x_lines.retainage_rate_tbl;
  l_lines.max_retainage_amount            := x_lines.max_retainage_amount_tbl;
  l_lines.progress_payment_rate           := x_lines.progress_payment_rate_tbl;
  l_lines.recoupment_rate                 := x_lines.recoupment_rate_tbl;
  l_lines.advance_amount                  := x_lines.advance_amount_tbl;
  -- << PDOI for Complex PO Project: End >>
  -- <<PDOI Enhancement Bug#17063664 Start>>
  l_lines.requisition_line_id             := x_lines.requisition_line_id_tbl;
  l_lines.from_header_id                  := x_lines.from_header_id_tbl;
  l_lines.from_line_id                    := x_lines.from_line_id_tbl;
  l_lines.hdr_vendor_id                   := x_lines.hd_vendor_id_tbl;
  l_lines.hdr_vendor_site_id              := x_lines.hd_vendor_site_id_tbl;
  l_lines.hdr_currency_code               := x_lines.hd_currency_code_tbl;
  l_lines.matching_basis                  := x_lines.matching_basis_tbl;
  l_lines.cons_from_supp_flag             := x_lines.consigned_flag_tbl;
  l_lines.txn_flow_header_id              := x_lines.txn_flow_header_id_tbl;
  l_lines.oke_contract_header_id          := x_lines.oke_contract_header_id_tbl;
  l_lines.oke_contract_version_id         := x_lines.oke_contract_version_id_tbl;
  -- <<PDOI Enhancement Bug#17063664 End>>

  d_position := 10;

  l_inventory_org_id_tbl.EXTEND(x_lines.intf_line_id_tbl.COUNT);
  -- <<PDOI Enhancement Bug#17063664 Start>>
  l_org_id_tbl.EXTEND(x_lines.intf_line_id_tbl.COUNT);
  l_hdr_type_lookup_code_tbl.EXTEND(x_lines.intf_line_id_tbl.COUNT);
  -- <<PDOI Enhancement Bug#17063664 End>>
  FOR i IN 1..x_lines.intf_line_id_tbl.COUNT LOOP
     l_inventory_org_id_tbl(i) := PO_PDOI_PARAMS.g_sys.master_inv_org_id;
     -- <<PDOI Enhancement Bug#17063664 Start>>
     l_org_id_tbl(i)               := PO_PDOI_PARAMS.g_request.org_id;
     l_hdr_type_lookup_code_tbl(i) := PO_PDOI_PARAMS.g_request.document_type;
     -- <<PDOI Enhancement Bug#17063664 End>>
  END LOOP;
  l_lines.inventory_org_id   := l_inventory_org_id_tbl;
  -- <<PDOI Enhancement Bug#17063664 Start>>
  l_lines.org_id                := l_org_id_tbl;
  l_lines.hdr_type_lookup_code  := l_hdr_type_lookup_code_tbl;
  -- <<PDOI Enhancement Bug#17063664 End>>

  d_position := 20;

  l_parameter_name_tbl.EXTEND(3);
  l_parameter_value_tbl.EXTEND(3);
  l_parameter_name_tbl(1)                 := 'CREATE_OR_UPDATE_ITEM';
  l_parameter_value_tbl(1)                := PO_PDOI_PARAMS.g_request.create_items;
  l_parameter_name_tbl(2)                 := 'INVENTORY_ORG_ID';
  l_parameter_value_tbl(2)                := PO_PDOI_PARAMS.g_sys.def_inv_org_id; -- bug5601416
  l_parameter_name_tbl(3)                 := 'DOC_TYPE';
  l_parameter_value_tbl(3)                := PO_PDOI_PARAMS.g_request.document_type;

  d_position := 30;

  PO_VALIDATIONS.validate_pdoi
  (
    p_lines                => l_lines,
    p_doc_type             => PO_PDOI_PARAMS.g_request.document_type,
    p_action               => p_action,
    p_parameter_name_tbl   => l_parameter_name_tbl,
    p_parameter_value_tbl  => l_parameter_value_tbl,
    x_result_type          => l_result_type,
    x_results              => l_results
  );

  d_position := 40;

  IF (l_result_type = po_validations.c_result_type_failure) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'vaidate lines return failure');
    END IF;

    PO_PDOI_ERR_UTL.process_val_type_errors
    (
      x_results    => l_results,
      p_table_name => 'PO_LINES_INTERFACE',
      p_lines      => x_lines
    );

    d_position := 50;

    populate_error_flag
    (
      x_results  => l_results,
      x_lines    => x_lines
    );
  END IF;

  d_position := 60;

  IF l_result_type = po_validations.c_result_type_fatal THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'vaidate lines return fatal');
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  d_position := 70;

  -- validate tlp table in advance for tracking of num of error lines.
  IF (p_action = 'CREATE') THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'start to validate attribute tlp table');
    END IF;

    d_position := 80;

    validate_attr_tlp
    (
      x_lines => x_lines
    );
  END IF;

  d_position := 90;

  handle_err_tolerance
  (
    x_lines => x_lines
  );

  d_position := 100;

  PO_TIMING_UTL.stop_time(PO_PDOI_CONSTANTS.g_T_LINE_VALIDATE);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'result_type', l_result_type);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END validate_lines;

------------------------------------------------------------------------
-------------------- PRIVATE PROCEDURES --------------------------------
------------------------------------------------------------------------

-- bug5684695
-- removed the content for procedure derive_po_header_id

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_item_id
--Function: derive item_id from item or vendor_product_num
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_vendor_id_tbl
--    list of vendor_ids read from the header
--  p_intf_header_id_tbl
--    identifiers of interface headers
--  p_intf_line_id_tbl
--    identifiers of interface lines
--  p_vendor_product_num_tbl
--    list of vendor_product_nums read within the batch
--  p_category_id_tbl
--    list of category_ids read within the batch
--  p_item_tbl
--    list of items read within the batch
--IN OUT:
--  x_item_id_tbl
--    list of item_ids read within the batch;
--    derived result will be saved here as well;
--  x_error_flag_tbl
--    table to mark whether there is error on each row
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_item_id
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_id_tbl          IN PO_TBL_NUMBER,
  p_intf_header_id_tbl     IN PO_TBL_NUMBER,
  p_intf_line_id_tbl       IN PO_TBL_NUMBER,
  p_vendor_product_num_tbl IN PO_TBL_VARCHAR30,
  p_category_id_tbl        IN PO_TBL_NUMBER,            --bug 7374337
  p_item_tbl               IN PO_TBL_VARCHAR2000,
  x_item_id_tbl            IN OUT NOCOPY PO_TBL_NUMBER,
  x_error_flag_tbl         IN OUT NOCOPY PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_item_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;

  -- variable to hold index of the current processing row
  l_index            NUMBER;

  -- variables to indicate whether multiple_buyer_part error is already inserted
  l_error_exist_tbl  DBMS_SQL.NUMBER_TABLE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_vendor_id_tbl', p_vendor_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_intf_header_id_tbl', p_intf_header_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_intf_line_id_tbl', p_intf_line_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_vendor_product_num_tbl', p_vendor_product_num_tbl);
    PO_LOG.proc_begin(d_module, 'p_category_id_tbl', p_category_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_item_tbl', p_item_tbl);
    PO_LOG.proc_begin(d_module, 'x_item_id_tbl', x_item_id_tbl);
    PO_LOG.proc_begin(d_module, 'x_error_flag_tbl', x_error_flag_tbl);
  END IF;

  -- derive based on item_num
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           inventory_item_id
    FROM   mtl_system_items_kfv
    WHERE  p_item_tbl(i) IS NOT NULL
    AND    x_item_id_tbl(i) IS NULL
    AND    concatenated_segments = p_item_tbl(i)
    AND    organization_id = PO_PDOI_PARAMS.g_sys.def_inv_org_id;

  d_position := 10;

  -- derive based on vendor_product_num
  -- bug 7374337 Added an AND condidtion in the below
  -- sql so that matched category for the vendor product number
  -- item id will be derived.

  -- Bug 17173053 Added AND conditions in the below sql so that
  -- only Active item will be derived.

  FORALL i IN 1.. p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT DISTINCT
           p_key,
           p_index_tbl(i),
           txn_lines.item_id
     FROM   po_headers txn_headers, po_lines txn_lines,
           financials_system_parameters fsp,   --Bug 17173053
           mtl_system_items msi                --Bug 17173053
    WHERE  txn_headers.po_header_id = txn_lines.po_header_id
    AND    p_item_tbl(i) IS NULL
    AND    x_item_id_tbl(i) IS NULL
    AND    p_vendor_product_num_tbl(i) IS NOT NULL
    AND    txn_lines.vendor_product_num = p_vendor_product_num_tbl(i)
    AND    txn_headers.vendor_id = p_vendor_id_tbl(i)
    AND    txn_lines.item_id IS NOT NULL
    AND    msi.inventory_item_id = txn_lines.item_id             --Bug 17173053 <S>
    AND    msi.inventory_item_status_code = 'Active'
    AND    msi.organization_id = fsp.inventory_organization_id   --Bug 17173053 <E>
    AND    ( (p_category_id_tbl(i) IS NOT NULL                   --bug 7374337 <S>
            AND txn_lines.category_id = p_category_id_tbl(i))
            OR (p_category_id_tbl(i) IS NULL )                   --bug 7374337 <E>
           );

  d_position := 20;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 30;

  -- push the result back to x_item_ids
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'result item id',
                  l_result_tbl(i));
    END IF;

    IF (NOT l_error_exist_tbl.EXISTS(l_index)) THEN
      IF (x_item_id_tbl(l_index) IS NULL) THEN
        x_item_id_tbl(l_index) := l_result_tbl(i);
      ELSE
        x_item_id_tbl(l_index) := NULL;
        x_error_flag_tbl(l_index) := FND_API.G_TRUE;
        l_error_exist_tbl(l_index) := l_index;
        -- insert error
        PO_PDOI_ERR_UTL.add_fatal_error
        (
          p_interface_header_id  => p_intf_header_id_tbl(l_index),
          p_interface_line_id    => p_intf_line_id_tbl(l_index),
          p_error_message_name   => 'PO_PDOI_MULT_BUYER_PART',
          p_table_name           => 'PO_LINES_INTERFACE',
          p_column_name          => 'VENDOR_PRODUCT_NUM',
          p_column_value         => p_vendor_product_num_tbl(l_index),
          p_token2_name          => 'VALUE',
          p_token2_value         => p_vendor_product_num_tbl(l_index)
        );
      END IF;
    END IF;
  END LOOP;

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
END derive_item_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_item_revision
--Function: reset item_revision based on item_id
--          and create_item parameter value
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_item_id_tbl
--    list of item_ids read within the batch
--IN OUT:
--  x_item_revision_tbl
--    list of item_revisions read within the batch;
--    derived result will be saved here as well;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_item_revision
(
  p_key                    IN po_session_gt.key%TYPE,
  p_item_id_tbl            IN PO_TBL_NUMBER,
  x_item_revision_tbl      IN OUT NOCOPY PO_TBL_VARCHAR5
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_item_revision';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_item_id_tbl', p_item_id_tbl);
    PO_LOG.proc_begin(d_module, 'x_item_revision_tbl', x_item_revision_tbl);
  END IF;

  FOR i IN 1..p_item_id_tbl.COUNT
  LOOP
    IF (p_item_id_tbl(i) IS NULL AND
        X_item_revision_tbl(i) IS NOT NULL AND
        PO_PDOI_PARAMS.g_request.create_items = 'Y') THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'index', i);
        PO_LOG.stmt(d_module, d_position, 'new item revision set to empty');
      END IF;

      x_item_revision_tbl(i) := NULL;
    END IF;
  END LOOP;

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
END derive_item_revision;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_job_business_group_id
--Function: derive job_business_group_id from
--          job_business_group_name
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_job_business_group_name_tbl
--    list of job_business_group_names read within the batch
--IN OUT:
--  x_job_business_group_id_tbl
--    list of job_business_group_ids read within the batch;
--    derived result will be saved here as well;
--    derivation will only occur when job_business_group_name
--    is provided but job_business_group_id is not;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_job_business_group_id
(
  p_key                            IN po_session_gt.key%TYPE,
  p_index_tbl                      IN DBMS_SQL.NUMBER_TABLE,
  p_job_business_group_name_tbl    IN PO_TBL_VARCHAR2000,
  x_job_business_group_id_tbl      IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_job_business_group_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_job_business_group_name_tbl',
                      p_job_business_group_name_tbl);
    PO_LOG.proc_begin(d_module, 'x_job_business_group_id_tbl',
                      x_job_business_group_id_tbl);
  END IF;

  -- derive id from name
  FORALL i IN 1.. p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           business_group_id
    FROM   per_business_groups_perf
    WHERE  p_job_business_group_name_tbl(i) IS NOT NULL
    AND    x_job_business_group_id_tbl(i) IS NULL
    AND    name = p_job_business_group_name_tbl(i)
    AND    TRUNC(sysdate) BETWEEN TRUNC(NVL(date_from, sysdate))
           AND TRUNC(NVL(date_to, sysdate));

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- push the result back to x_job_business_group_id_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'new business group id',
                  l_result_tbl(i));
    END IF;

    x_job_business_group_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_job_business_group_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_job_id
--Function: derive job_id from job_business_group_name and job_name
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_file_line_language_tbl
--    list of line level languages
--  p_job_business_group_name_tbl
--    list of job_business_group_names read within the batch
--  p_job_name_tbl
--    list of job_names read within the batch
--IN OUT:
--  x_job_business_group_id_tbl
--    list of job_business_group_ids read within the batch;
--    derived result will be saved here as well;
--  x_job_id_tbl
--    list of job_ids read within the batch;
--    derived result will be saved here as well;
--    derivation will only occur when job_name
--    is provided but job_id is not;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_job_id
(
  p_key                            IN po_session_gt.key%TYPE,
  p_index_tbl                      IN DBMS_SQL.NUMBER_TABLE,
  p_file_line_language_tbl         IN PO_TBL_VARCHAR5,
  p_job_business_group_name_tbl    IN PO_TBL_VARCHAR2000,
  p_job_name_tbl                   IN PO_TBL_VARCHAR2000,
  x_job_business_group_id_tbl      IN OUT NOCOPY PO_TBL_NUMBER,
  x_job_id_tbl                     IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_job_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;

  -- debug variables
  d_group_id         NUMBER;
  d_job_id_tbl       PO_TBL_NUMBER;
  d_job_name_tbl     PO_TBL_VARCHAR2000;
  d_bg_id_tbl        PO_TBL_NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_file_line_language_tbl',
                      p_file_line_language_tbl);
    PO_LOG.proc_begin(d_module, 'p_job_business_group_name_tbl',
                      p_job_business_group_name_tbl);
    PO_LOG.proc_begin(d_module, 'p_job_name_tbl', p_job_name_tbl);
    PO_LOG.proc_begin(d_module, 'x_job_business_group_id_tbl',
                      x_job_business_group_id_tbl);
    PO_LOG.proc_begin(d_module, 'x_job_id_tbl', x_job_id_tbl);
  END IF;

  -- execute different queries to derive job_id depending on profile and
  -- value of job_business_group_id
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'business group profile value',
                PO_PDOI_PARAMS.g_profile.xbg);
    PO_LOG.stmt(d_module, d_position, 'fsp business_group_id',
                PO_PDOI_PARAMS.g_sys.def_business_group_id);
  END IF;

  -- bug 5489942: derive job_id from job_name based on
  --              line level language
  IF (NVL(PO_PDOI_PARAMS.g_profile.xbg, 'N') = 'N') THEN
    d_position := 10;

    -- derive job_id from job_name
    FORALL i IN 1..p_index_tbl.COUNT
      INSERT INTO po_session_gt(key, num1, num2)
      SELECT p_key,
             p_index_tbl(i),
             jobs_b.job_id
      FROM   per_jobs jobs_b,
             per_jobs_tl jobs_tl
      WHERE  p_job_name_tbl(i) IS NOT NULL
      AND    x_job_id_tbl(i) IS NULL
      AND    jobs_b.job_id = jobs_tl.job_id
      AND    jobs_tl.language = NVL(p_file_line_language_tbl(i), userenv('LANG'))
      AND    jobs_tl.name = p_job_name_tbl(i)
      AND    jobs_b.business_group_id = PO_PDOI_PARAMS.g_sys.def_business_group_id
      AND    PO_PDOI_PARAMS.g_sys.def_business_group_id =
               DECODE(p_job_business_group_name_tbl(i), NULL,
               DECODE(x_job_business_group_id_tbl(i), NULL,
               PO_PDOI_PARAMS.g_sys.def_business_group_id,
               x_job_business_group_id_tbl(i)), x_job_business_group_id_tbl(i))
      AND    TRUNC(sysdate) BETWEEN TRUNC(NVL(jobs_b.date_from, sysdate))
             AND TRUNC(NVL(jobs_b.date_to, sysdate));
  ELSE
    d_position := 20;

    /*  -- START OF info added for debugging purpose

    select job_id, name, business_group_id
    bulk collect into d_job_id_tbl, d_job_name_tbl, d_bg_id_tbl
    from per_jobs_vl
    where TRUNC(sysdate) BETWEEN TRUNC(NVL(date_from, sysdate))
             AND TRUNC(NVL(date_to, sysdate));

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'debug: d_job_id_tbl',
                  d_job_id_tbl);
      PO_LOG.stmt(d_module, d_position, 'debug: d_job_name_tbl',
                  d_job_name_tbl);
      PO_LOG.stmt(d_module, d_position, 'debug: d_bg_id_tbl',
                  d_bg_id_tbl);
      PO_LOG.stmt(d_module, d_position, 'debug: default bg id',
                  PO_PDOI_PARAMS.g_sys.def_business_group_id);
    END IF;

    -- END OF info added for debugging purpose */

    -- derive job_id for lines with job_business_group_id = null
    FORALL i IN 1..p_index_tbl.COUNT
      INSERT INTO po_session_gt(key, num1, num2)
      SELECT p_key,
             p_index_tbl(i),
             jobs_b.job_id
      FROM   per_jobs jobs_b,
             per_jobs_tl jobs_tl
      WHERE  p_job_name_tbl(i) IS NOT NULL
      AND    x_job_id_tbl(i) IS NULL
      AND    x_job_business_group_id_tbl(i) IS NULL
      AND    jobs_b.job_id = jobs_tl.job_id
      AND    jobs_tl.language = NVL(p_file_line_language_tbl(i), userenv('LANG'))
      AND    jobs_tl.name = p_job_name_tbl(i)
      AND    jobs_b.business_group_id = PO_PDOI_PARAMS.g_sys.def_business_group_id
      AND    PO_PDOI_PARAMS.g_sys.def_business_group_id =
               DECODE(p_job_business_group_name_tbl(i), NULL,
               PO_PDOI_PARAMS.g_sys.def_business_group_id,
               x_job_business_group_id_tbl(i))
      AND    TRUNC(sysdate) BETWEEN TRUNC(NVL(jobs_b.date_from, sysdate))
             AND TRUNC(NVL(jobs_b.date_to, sysdate));

    d_position := 30;

    -- derive job_id for lines with job_business_group_id <> null
    FORALL i IN 1..p_index_tbl.COUNT
      INSERT INTO po_session_gt(key, num1, num2)
      SELECT p_key,
             p_index_tbl(i),
             jobs_b.job_id
      FROM   per_jobs jobs_b,
             per_jobs_tl jobs_tl,
             per_business_groups_perf groups
      WHERE  p_job_name_tbl(i) IS NOT NULL
      AND    x_job_id_tbl(i) IS NULL
      AND    x_job_business_group_id_tbl(i) IS NOT NULL
      AND    jobs_b.job_id = jobs_tl.job_id
      AND    jobs_tl.language = NVL(p_file_line_language_tbl(i), userenv('LANG'))
      AND    jobs_tl.name = p_job_name_tbl(i)
      AND    jobs_b.business_group_id = x_job_business_group_id_tbl(i)
      AND    jobs_b.business_group_id = groups.business_group_id
      AND    TRUNC(sysdate) BETWEEN NVL(jobs_b.date_from, TRUNC(sysdate))
             AND NVL(jobs_b.date_to, TRUNC(sysdate))
      AND    TRUNC(sysdate) BETWEEN NVL(groups.date_from, TRUNC(sysdate))
             AND NVL(groups.date_to, TRUNC(sysdate));
  END IF;

  d_position := 40;

  -- retrive result from temp table and delete the records in temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 50;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'derived result: l_index_tbl',
                l_index_tbl);
    PO_LOG.stmt(d_module, d_position, 'derived result: l_result_tbl',
                l_result_tbl);
  END IF;

  -- set job_business_group_id if both job_business_group_id
  -- and job_business_group_name is empty
  FOR i IN 1..p_index_tbl.COUNT
  LOOP
    IF (p_job_name_tbl(i) IS NOT NULL AND
        X_job_id_tbl(i) IS NULL AND
        p_job_business_group_name_tbl(i) IS NULL AND
        x_job_business_group_id_tbl(i) IS NULL) THEN
      x_job_business_group_id_tbl(i) :=
             PO_PDOI_PARAMS.g_sys.def_business_group_id;
    END IF;
  END LOOP;

  d_position := 60;

  -- set job_id from derived values
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new job id', l_result_tbl(i));
    END IF;

    x_job_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_job_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_category_id
--Function: derive po category_id from po category name
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_category_tbl
--    list of categories read within the batch
--IN OUT:
--  x_category_id_tbl
--    list of category_ids read within the batch;
--    derived result will be saved here as well;
--    derivation will only occur when category
--    is provided but category_id is not;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_category_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_category_tbl         IN PO_TBL_VARCHAR2000,
  x_category_id_tbl      IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_category_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_result NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_category_tbl', p_category_tbl);
    PO_LOG.proc_begin(d_module, 'x_category_id_tbl', x_category_id_tbl);
  END IF;

  -- category id is derived by an API provided by FND.
  -- so we have to call the APPI multiple times
  FOR i IN 1.. p_category_tbl.COUNT
  LOOP
    IF (p_category_tbl(i) IS NOT NULL AND
        x_category_id_tbl(i) IS NULL) THEN
      d_position := 10;

      l_result :=
           FND_FLEX_EXT.GET_CCID('INV', 'MCAT',
                        PO_PDOI_PARAMS.g_sys.def_structure_id,
                        to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'),
                        p_category_tbl(i));

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'index', i);
        PO_LOG.stmt(d_module, d_position, 'result', l_result);
      END IF;

      IF (l_result IS NOT NULL AND l_result <> 0) THEN
        x_category_id_tbl(i) := l_result;
      END IF;
    END IF;
  END LOOP;

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
END derive_category_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_ip_category_id
--Function: derive po category_id from po category name
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_file_line_language_tbl
--    list of line level languages
--  p_ip_category_tbl
--    list of ip_categories read within the batch
--IN OUT:
--  x_ip_category_id_tbl
--    list of ip_category_ids read within the batch;
--    derived result will be saved here as well;
--    derivation will only occur when ip_category
--    is provided but ip_category_id is not;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_ip_category_id
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_file_line_language_tbl IN PO_TBL_VARCHAR5,
  p_ip_category_tbl        IN PO_TBL_VARCHAR2000,
  x_ip_category_id_tbl     IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_ip_category_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_ip_category_tbl', p_ip_category_tbl);
    PO_LOG.proc_begin(d_module, 'p_file_line_language_tbl', p_file_line_language_tbl);
    PO_LOG.proc_begin(d_module, 'x_ip_category_id_tbl', x_ip_category_id_tbl);
  END IF;

  -- 1. derive ip_category_id based on category key
  FORALL i IN 1.. p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, char1)
    SELECT p_key,
           p_index_tbl(i),
           cat.rt_category_id
    FROM   icx_cat_categories_v cat
    WHERE  p_ip_category_tbl(i) IS NOT NULL
    AND    x_ip_category_id_tbl(i) IS NULL
    AND    cat.key = p_ip_category_tbl(i);

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- push the result back to x_unit_of_measure_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new ip category id',
                  l_result_tbl(i));
    END IF;

    x_ip_category_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

  d_position := 30;

  -- bug 5489942: derivation is based on line level language
  -- 2. derive ip_category_id based on category name,
  --    name is language specific
  FORALL i IN 1.. p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, char1)
    SELECT p_key,
           p_index_tbl(i),
           rt_category_id
    FROM   icx_cat_categories_v
    WHERE  p_ip_category_tbl(i) IS NOT NULL
    AND    x_ip_category_id_tbl(i) IS NULL
    AND    category_name = p_ip_category_tbl(i)
    AND    language = NVL(p_file_line_language_tbl(i),
                          userenv('LANG'));

  d_position := 40;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 50;

  -- push the result back to x_unit_of_measure_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new ip category id',
                  l_result_tbl(i));
    END IF;

    x_ip_category_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_ip_category_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_unit_of_measure
--Function: derive unit_of_measure from uom_code
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_uom_code_tbl
--    list of uom_codes read within the batch
--IN OUT:
--  x_unit_of_measure_tbl
--    list of unit_of_measures read within the batch;
--    derived result will be saved here as well;
--    derivation will only occur when uom_code
--    is provided but unit_of_measure is not;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_unit_of_measure
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_uom_code_tbl         IN PO_TBL_VARCHAR5,
  x_unit_of_measure_tbl  IN OUT NOCOPY PO_TBL_VARCHAR30
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_unit_of_measure';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_VARCHAR30;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_uom_code_tbl', p_uom_code_tbl);
    PO_LOG.proc_begin(d_module, 'x_unit_of_measure_tbl', x_unit_of_measure_tbl);
  END IF;

  -- derive unit_of_measure from uom_code
  FORALL i IN 1.. p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, char1)
    SELECT p_key,
           p_index_tbl(i),
           unit_of_measure
    FROM   po_units_of_measure_val_v
    WHERE  p_uom_code_tbl(i) IS NOT NULL
    AND    x_unit_of_measure_tbl(i) IS NULL
    AND    uom_code = p_uom_code_tbl(i);

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- push the result back to x_unit_of_measure_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new unit of measure',
                  l_result_tbl(i));
    END IF;

    x_unit_of_measure_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_unit_of_measure;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_line_type_id
--Function: derive line_type_id from line_type
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_file_line_language_tbl
--    list of line level languages
--  p_line_type_tbl
--    list of line_types read within the batch
--IN OUT:
--  x_line_type_id_tbl
--    list of line_type_ids read within the batch;
--    derived result will be saved here as well;
--    derivation will only occur when line_type
--    is provided but line_type_id is not;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_line_type_id
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_file_line_language_tbl IN PO_TBL_VARCHAR5,
  p_line_type_tbl          IN PO_TBL_VARCHAR30,
  x_line_type_id_tbl       IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_line_type_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_line_type_tbl', p_line_type_tbl);
    PO_LOG.proc_begin(d_module, 'p_file_line_language_tbl', p_file_line_language_tbl);
    PO_LOG.proc_begin(d_module, 'x_line_type_id_tbl', x_line_type_id_tbl);
  END IF;

  -- bug 5489942: derivation is based on line level language
  -- derive line_type_id from line_type
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           b.line_type_id
    FROM   po_line_types_b b,
           po_line_types_tl tl
    WHERE  p_line_type_tbl(i) IS NOT NULL
    AND    x_line_type_id_tbl(i) IS NULL
    AND    b.line_type_id = tl.line_type_id
    AND    tl.language = NVL(p_file_line_language_tbl(i),
                             userenv('LANG'))
    AND    SYSDATE < NVL(b.inactive_date, SYSDATE +1)
    AND    tl.line_type = p_line_type_tbl(i);

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- push the result back to x_line_type_ids
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new line type id', l_result_tbl(i));
    END IF;

    x_line_type_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_line_type_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_un_number_id
--Function: derive un_number_id from un_number
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_un_number_tbl
--    list of un_numbers read within the batch
--IN OUT:
--  x_un_number_id_tbl
--    list of un_number_ids read within the batch;
--    derived result will be saved here as well;
--    derivation will only occur when un_number
--    is provided but un_number_id is not;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_un_number_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_un_number_tbl        IN PO_TBL_VARCHAR30,
  x_un_number_id_tbl     IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_un_number_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_un_number_tbl', p_un_number_tbl);
    PO_LOG.proc_begin(d_module, 'x_un_number_id_tbl', x_un_number_id_tbl);
  END IF;

  -- derive un_number_id from un_number
  FORALL i IN 1.. p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           un_number_id
    FROM   po_un_numbers_vl
    WHERE  p_un_number_tbl(i) IS NOT NULL
    AND    x_un_number_id_tbl(i) IS NULL
    AND    sysdate < nvl(inactive_date, sysdate +1)
    AND    un_number = p_un_number_tbl(i);

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- push the result back to x_lines
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new un number id', l_result_tbl(i));
    END IF;

    x_un_number_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_un_number_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_hazard_class_id
--Function: derive hazard_class_id from hazard_class
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_hazard_class_tbl
--    list of hazard_classes read within the batch
--IN OUT:
--  x_hazard_class_id_tbl
--    list of hazard_class_ids read within the batch;
--    derived result will be saved here as well;
--    derivation will only occur when hazard_class
--    is provided but hazard_class_id is not;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_hazard_class_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_hazard_class_tbl     IN PO_TBL_VARCHAR100,
  x_hazard_class_id_tbl  IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_hazard_class_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_hazard_class_tbl', p_hazard_class_tbl);
    PO_LOG.proc_begin(d_module, 'x_hazard_class_id_tbl', x_hazard_class_id_tbl);
  END IF;

  -- derive hazard_class_id from hazard_class
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           hazard_class_id
    FROM   po_hazard_classes_val_v
    WHERE  p_hazard_class_tbl(i) IS NOT NULL
    AND    x_hazard_class_id_tbl(i) IS NULL
    AND    hazard_class = p_hazard_class_tbl(i);

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- push the result back to x_hazard_class_ids
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new hazard class id', l_result_tbl(i));
    END IF;

    x_hazard_class_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_hazard_class_id;

-- <<PDOI Enhancement Bug#17063664 Start>>
-----------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_asl
--Function: default vendor_product_num and consigned_flag from ASL
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_item_id_tbl
--    list of item_id read within the batch
--  p_vendor_id_tbl
--    list of vendor_id values read within the batch
--  p_vendor_site_id_tbl
--    list of vendor_site_id values read within the batch
--  p_ship_to_org_id_tbl
--    list of ship_to_org_id values read within the batch
--IN OUT:
--  x_vendor_product_num_tbl
--    list of vendor_product_num values read within the batch;
--  x_consigned_flag_tbl
--    list of consigned_flag values read within the batch;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_info_from_asl
(
  p_key                     IN po_session_gt.key%TYPE,
  p_index_tbl               IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl             IN PO_TBL_NUMBER,
  p_vendor_id_tbl           IN PO_TBL_NUMBER,
  p_vendor_site_id_tbl      IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl      IN PO_TBL_NUMBER,
  x_vendor_product_num_tbl  IN OUT NOCOPY PO_TBL_VARCHAR30,
  x_consigned_flag_tbl      IN OUT NOCOPY PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_info_from_asl';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the result
  l_index_tbl                    PO_TBL_NUMBER;
  l_vendor_product_num_tbl       PO_TBL_VARCHAR30;
  l_consigned_flag_tbl           PO_TBL_VARCHAR1;

  l_index            NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_item_id_tbl', p_item_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_vendor_id_tbl', p_vendor_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_vendor_site_id_tbl', p_vendor_site_id_tbl);
    PO_LOG.proc_begin(d_module, 'p_ship_to_org_id_tbl', p_ship_to_org_id_tbl);
  END IF;

  --initialize out parameters
  x_consigned_flag_tbl := PO_TBL_VARCHAR1();
  x_consigned_flag_tbl.EXTEND(p_index_tbl.COUNT);

  -- derive hazard_class_id from hazard_class
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, char1, char2)
    SELECT p_key,
           p_index_tbl(i),
           pasl.primary_vendor_item,
           paa.consigned_from_supplier_flag
    FROM   po_approved_supplier_lis_val_v pasl,
           po_asl_attributes paa,
           po_asl_status_rules_v pasr
    WHERE  pasl.item_id = p_item_id_tbl(i)
       AND pasl.vendor_id                = p_vendor_id_tbl(i)
       AND (NVL(pasl.vendor_site_id, -1) = NVL(p_vendor_site_id_tbl(i), -1)
       OR pasl.vendor_site_id           IS NULL)
       AND pasl.using_organization_id =
           (SELECT MAX(pasl2.using_organization_id)
           FROM po_approved_supplier_lis_val_v pasl2
           WHERE pasl2.item_id                = p_item_id_tbl(i)
           AND pasl2.vendor_id                = p_vendor_id_tbl(i)
           AND (NVL(pasl2.vendor_site_id, -1) = NVL(p_vendor_site_id_tbl(i), -1)
           OR pasl2.vendor_site_id           IS NULL)
           AND pasl2.using_organization_id IN (-1, p_ship_to_org_id_tbl(i)))  -- destination_org_id
       AND pasl.asl_id                   = paa.asl_id
       AND pasr.business_rule LIKE '2_SOURCING'
       AND pasr.allow_action_flag LIKE 'Y'
       AND pasr.status_id            = pasl.asl_status_id
       AND paa.using_organization_id =
           (SELECT MAX(paa2.using_organization_id)
           FROM po_asl_attributes paa2
           WHERE paa2.asl_id               = pasl.asl_id
           AND paa2.using_organization_id IN (-1, p_ship_to_org_id_tbl(i)));

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1, char2 BULK COLLECT INTO l_index_tbl, l_vendor_product_num_tbl, l_consigned_flag_tbl;

  d_position := 20;

  -- fetch the resulted consigned flag into output variable x_consigned_flag_tbl
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'vendor product num', l_vendor_product_num_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'consigned flag', l_consigned_flag_tbl(i));
    END IF;

    x_vendor_product_num_tbl(l_index) := NVL(x_vendor_product_num_tbl(l_index), l_vendor_product_num_tbl(i));

    -- Bug 18891225
    -- Consigned flag should be NULL for consumption advice.
    IF PO_PDOI_PARAMS.g_request.calling_module <> PO_PDOI_CONSTANTS.g_CALL_MOD_CONSUMPTION_ADVICE THEN
      x_consigned_flag_tbl(l_index)     := NVL(x_consigned_flag_tbl(l_index), l_consigned_flag_tbl(i));
    END IF;

  END LOOP;

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
END default_info_from_asl;

--------------------------------------------------------------------------------
--Start of Comments
--Name: default_txn_header_id
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB on error.
--Locks:
--  None.
--Function:
--  Check if an inventory transaction flow exists for input parameters given.
--  Appends to the API message list upon error.
--Parameters:
--IN:
--p_init_msg_list
--p_start_ou_id
--  Start OU of the transaction flow.
--p_end_ou_id
--  End OU of the transaction flow. Defaults to OU of p_ship_to_org_id if this
--  is NULL.
--p_ship_to_org_id
--  The ship-to organization of the transaction flow.
--p_item_category_id
--  Item category ID of the transaction flow, if one exists.
--p_transaction_date
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_error - if an error occurred
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_transaction_flow_header_id
--  The unique header ID of the transaction flow, if any valid inter-company
--  relationship exists.  If not flow was found, then this is NULL.
--  (MTL_TRANSACTION_FLOW_HEADERS.header_id%TYPE)
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE default_txn_header_id
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_start_ou_id_tbl            IN PO_TBL_NUMBER,
  p_ship_to_org_id_tbl         IN PO_TBL_NUMBER,
  p_item_category_id_tbl       IN PO_TBL_NUMBER,
  x_txn_flow_header_id_tbl     OUT NOCOPY PO_TBL_NUMBER
)
IS

d_api_name CONSTANT VARCHAR2(30) := 'default_txn_header_id';
d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_is_txn_flow_supported BOOLEAN;
l_inv_qualifier_code NUMBER;
l_index_tbl PO_TBL_NUMBER;
l_end_ou_id_tbl PO_TBL_NUMBER;
l_result_tbl PO_TBL_NUMBER;

l_qual_code_tbl  INV_TRANSACTION_FLOW_PUB.number_tbl;
l_qual_val_tbl   INV_TRANSACTION_FLOW_PUB.number_tbl;

l_new_accounting_flag MTL_TRANSACTION_FLOW_HEADERS.new_accounting_flag%TYPE;
l_txn_flow_exists VARCHAR2(1);

l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);

BEGIN
    d_position := 0;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_begin(d_module);
    END IF;

    d_position := 10;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Startou ID: ', p_start_ou_id_tbl);
      PO_LOG.stmt(d_module, d_position, 'Shipto Org: ', p_ship_to_org_id_tbl);
      PO_LOG.stmt(d_module, d_position, 'Category ID: ', p_item_category_id_tbl);
    END IF;

    d_position := 20;

    --initialize out parameters
    x_txn_flow_header_id_tbl := PO_TBL_NUMBER();
    l_end_ou_id_tbl          := PO_TBL_NUMBER();

    x_txn_flow_header_id_tbl.EXTEND(p_index_tbl.COUNT);
    l_end_ou_id_tbl.EXTEND(p_index_tbl.COUNT);

    -- Transaction flows are supported if INV FPJ or higher is installed
    l_is_txn_flow_supported :=
      (INV_CONTROL.get_current_release_level >= INV_RELEASE.get_j_release_level);

    l_inv_qualifier_code := INV_TRANSACTION_FLOW_PUB.g_qualifier_code;

    d_position := 30;

    -- Default the End operating unit if it is NULL
    FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           TO_NUMBER(hoi.org_information3)
    FROM   hr_organization_information hoi,
           mtl_parameters mp
    WHERE  p_ship_to_org_id_tbl(i) IS NOT NULL
       AND mp.organization_id = p_ship_to_org_id_tbl(i)
       AND mp.organization_id = hoi.organization_id
       AND hoi.org_information_context = 'Accounting Information';

    d_position := 40;

    -- get result from temp table
    DELETE FROM po_session_gt
    WHERE key = p_key
    RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

    d_position := 50;

    -- set result in x_ship_to_org_id_tbl
    FOR i IN 1..l_index_tbl.COUNT
    LOOP
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'default end ou id',
                    l_result_tbl(i));
      END IF;

      l_end_ou_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
    END LOOP;

    d_position := 60;

    -- retrieve the values
    FOR i IN 1..p_index_tbl.COUNT
    LOOP

      -- Make sure that transaction flows are supported
      IF (NOT l_is_txn_flow_supported) THEN
          -- Transaction flows not supported, so return immediately
          x_txn_flow_header_id_tbl(i) := NULL;
          IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module, d_position, 'Transaction flows not supported');
          END IF;
          RETURN;
      END IF;

      d_position := 70;

      -- Never use a transaction flow if the start and end OU's are equal
   IF (p_start_ou_id_tbl(i) = l_end_ou_id_tbl(i)) THEN
          x_txn_flow_header_id_tbl(i) := NULL;
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_position, 'Start OU and End OU are same');
          END IF;
    -- Bug#19528138 : No need to call the transaction flow api if start OU and end OU are
    -- same
    ELSE

      d_position := 80;

      -- Initialize tables if have item_category_id
      IF (p_item_category_id_tbl(i) IS NOT NULL) THEN
          l_qual_code_tbl(1) := l_inv_qualifier_code;
          l_qual_val_tbl(1) := p_item_category_id_tbl(i);
      END IF;

      d_position := 90;

      -- Try to get a valid transaction flow
      INV_TRANSACTION_FLOW_PUB.check_transaction_flow
        (p_api_version          => 1.0,
         x_return_status        => l_return_status,
         x_msg_count            => l_msg_count,
         x_msg_data             => l_msg_data,
         p_start_operating_unit => p_start_ou_id_tbl(i),
         p_end_operating_unit   => l_end_ou_id_tbl(i),
         p_flow_type            => INV_TRANSACTION_FLOW_PUB.g_procuring_flow_type,
         p_organization_id      => p_ship_to_org_id_tbl(i),
         p_qualifier_code_tbl   => l_qual_code_tbl,
         p_qualifier_value_tbl  => l_qual_val_tbl,
         p_transaction_date     => SYSDATE,
         x_header_id            => x_txn_flow_header_id_tbl(i),
         x_new_accounting_flag  => l_new_accounting_flag,
         x_transaction_flow_exists => l_txn_flow_exists);

      IF (l_return_status = FND_API.g_ret_sts_error) THEN
          d_position := 100;
          RAISE FND_API.g_exc_error;
      ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
          d_position := 110;
           RAISE FND_API.g_exc_unexpected_error;
      END IF;

      d_position := 120;

      -- Null out the header ID if the txn flow does not exist
      IF (l_txn_flow_exists IS NULL) OR
         (l_txn_flow_exists <> INV_TRANSACTION_FLOW_PUB.g_transaction_flow_found)
      THEN
          x_txn_flow_header_id_tbl(i) := NULL;
      END IF;

    END IF;  -- Bug#19528138

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'transaction flow header id: ', x_txn_flow_header_id_tbl(i));
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
END default_txn_header_id;

-- <<PDOI Enhancement Bug#17063664 End>>

-----------------------------------------------------------------------
--Start of Comments
--Name: derive_template_id
--Function: derive template_id from template_name
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_template_name_tbl
--    list of template_names read within the batch
--IN OUT:
--  x_template_id_tbl
--    list of template_ids read within the batch;
--    derived result will be saved here as well;
--    derivation will only occur when template_name
--    is provided but template_id is not;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE derive_template_id
(
  p_key                  IN po_session_gt.key%TYPE,
  p_index_tbl            IN DBMS_SQL.NUMBER_TABLE,
  p_template_name_tbl    IN PO_TBL_VARCHAR30,
  x_template_id_tbl      IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'derive_template_id';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- tables to store the derived result
  l_index_tbl        PO_TBL_NUMBER;
  l_result_tbl       PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_template_name_tbl', p_template_name_tbl);
    PO_LOG.proc_begin(d_module, 'x_template_id_tbl', x_template_id_tbl);
  END IF;

  -- derive template_id from template_name
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           template_id
    FROM   mtl_item_templates
    WHERE  p_template_name_tbl(i) IS NOT NULL
    AND    x_template_id_tbl(i) IS NULL
    AND    template_name = p_template_name_tbl(i)
    AND    NVL(context_organization_id,
           PO_PDOI_PARAMS.g_sys.def_inv_org_id) =
           PO_PDOI_PARAMS.g_sys.def_inv_org_id;

  d_position := 10;

  -- read result from temp table, and delete the records from temp table
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2 BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- push the result back to x_lines
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new template id', l_result_tbl(i));
    END IF;

    x_template_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END derive_template_id;

-- <<PDOI Enhancement Bug#17063664 Start>>


-----------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_source_ref
--Function:
--  default information from the source document reference
--  the information can be defaulted from requisition include the below attributes:
--    unit_meas_lookup_code
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--  p_from_header_id_tbl
--    list of from_header_id_tbl values in current batch
--  p_from_line_id_tbl
--    list of from_line_id_tbl values in current batch
-- p_contract_id_tbl
--    list of p_contract_id_tbl in current batch
--IN OUT: None
--OUT: None
--  x_unit_of_measure_tbl
--    contains uom_code values of the source reference;
--  x_un_number_id_tbl
--    contains un_number_id values of the source reference;
--  x_hazard_class_id_tbl
--    contains hazard_class_id values of the source reference;
--  x_vendor_product_num_tbl
--    contains vendor_product_num values of the source reference;
--  x_negotiated_flag_tbl
--    contains negotiated_flag values of the source reference;
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_info_from_source_ref
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_from_header_id_tbl     IN PO_TBL_NUMBER,
  p_from_line_id_tbl       IN PO_TBL_NUMBER,
  p_contract_id_tbl        IN PO_TBL_NUMBER, --Bug 18891225
  x_unit_of_measure_tbl    OUT NOCOPY PO_TBL_VARCHAR30,
  -- <<Bug#17864040 Start>>
  -- Added new parameters to fetch un number and
  --  hazard class id from source reference.
  x_un_number_id_tbl       OUT NOCOPY PO_TBL_NUMBER,
  x_hazard_class_id_tbl    OUT NOCOPY PO_TBL_NUMBER,
  x_vendor_product_num_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  -- <<Bug#17864040 End>>
  x_negotiated_flag_tbl    OUT NOCOPY PO_TBL_VARCHAR1

) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_info_from_source_ref';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold result read from temp table
  l_index_tbl                 DBMS_SQL.NUMBER_TABLE;
  l_unit_of_measure_tbl       PO_TBL_VARCHAR30;
  -- <<Bug#17864040 Start>>
  l_un_number_id_tbl          PO_TBL_NUMBER;
  l_hazard_class_id_tbl       PO_TBL_NUMBER;
  l_vendor_product_num_tbl    PO_TBL_VARCHAR30;
  -- <<Bug#17864040 End>>
  l_negotiated_flag_tbl       PO_TBL_VARCHAR1;
  l_index                     NUMBER;

  l_source_doc_type_tbl       PO_TBL_VARCHAR30;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  -- initialize the parameter
  x_unit_of_measure_tbl := PO_TBL_VARCHAR30();
  -- <<Bug#17864040 Start>>
  x_un_number_id_tbl       := PO_TBL_NUMBER();
  x_hazard_class_id_tbl    := PO_TBL_NUMBER();
  x_vendor_product_num_tbl := PO_TBL_VARCHAR30();
  -- <<Bug#17864040 End>>
  x_negotiated_flag_tbl := PO_TBL_VARCHAR1();

  x_unit_of_measure_tbl.EXTEND(p_index_tbl.COUNT);
  -- <<Bug#17864040 Start>>
  x_un_number_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_hazard_class_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_vendor_product_num_tbl.EXTEND(p_index_tbl.COUNT);
  -- <<Bug#17864040 End>>
  x_negotiated_flag_tbl.EXTEND(p_index_tbl.COUNT);

  -- retrieve the values based on source doc ref
  -- Bug#17864040: Fetching un number and hazard class id from source reference
  FORALL i IN 1..p_index_tbl.COUNT
  INSERT INTO po_session_gt(key, num1, char1, num2, num3, char2, char3, char4)
  SELECT p_key,
         p_index_tbl(i),
         pol.unit_meas_lookup_code,
         pol.un_number_id,
         pol.hazard_class_id,
         pol.vendor_product_num,
         pol.negotiated_by_preparer_flag,
	 poh.type_lookup_code -- Bug 18891225
  FROM po_lines_all pol,po_headers_all poh
  WHERE (poh.po_header_id = p_contract_id_tbl(i)
         OR (poh.po_header_id = p_from_header_id_tbl(i)
	      AND pol.po_line_id = p_from_line_id_tbl(i)))
      AND poh.po_header_id = pol.po_header_id (+);

  d_position := 20;

  DELETE FROM po_session_gt
  where  key = p_key
  RETURNING num1, char1, num2, num3, char2, char3, char4 BULK COLLECT INTO l_index_tbl
        , l_unit_of_measure_tbl, l_un_number_id_tbl, l_hazard_class_id_tbl
        , l_vendor_product_num_tbl, l_negotiated_flag_tbl, l_source_doc_type_tbl;

  d_position := 30;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'Unit of measure', l_unit_of_measure_tbl(i));
      -- <<Bug#17864040 Start>>
      PO_LOG.stmt(d_module, d_position, 'UN Number', l_un_number_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'Hazard Class ID', l_hazard_class_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'Vendor Product Number', l_vendor_product_num_tbl(i));
      -- <<Bug#17864040 End>>
      PO_LOG.stmt(d_module, d_position, 'Negotiated by preparer flag', l_negotiated_flag_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'Source doc type ', l_source_doc_type_tbl(i));
    END IF;

    x_unit_of_measure_tbl(l_index)    := l_unit_of_measure_tbl(i);
    -- <<Bug#17864040 Start>>
    x_un_number_id_tbl(l_index)       := l_un_number_id_tbl(i);
    x_hazard_class_id_tbl(l_index)    := l_hazard_class_id_tbl(i);
    x_vendor_product_num_tbl(l_index) := l_vendor_product_num_tbl(i);
    -- <<Bug#17864040 Start>>

    --Bug 18891225
    if (l_source_doc_type_tbl(i) = PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET) then
      x_negotiated_flag_tbl(l_index)    := l_negotiated_flag_tbl(i);
    elsif (l_source_doc_type_tbl(i) = PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION) then
      x_negotiated_flag_tbl(l_index)    := 'Y';
    elsif (l_source_doc_type_tbl(i) = PO_PDOI_CONSTANTS.g_DOC_TYPE_CONTRACT) then
      x_negotiated_flag_tbl(l_index)    := 'N';
    end if;

  END LOOP;

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
END default_info_from_source_ref;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_req
--Function:
--  default information from the requisition if backing req line id is provided;
--  the information can be defaulted from requisition include the below attributes:
--    line_type_id, item_id, item_revision, item_description, quantity, amount, category_id,
--    job_id, ship_to_org_id, ship_to_loc_id, from_header_id, from_line_id, unit_of_measure,
--    vendor_product_num, transaction_reason_code, note_to_vendor, start_date, end_date,
--	  oke_contract_header_id, oke_contract_version_id, quantity_committed, un_number_id,
--    hazard_class_id, supplier_ref_number, contractor_first_name, contractor_last_name,
--    preferred_grade, negotiated_by_preparer_flag
--Parameters:
--IN:
--  p_key
--    identifier in the temp table on the derived result
--  p_index_tbl
--    indexes of the records
--IN OUT:
--  p_lines
--    record containing all line info within the batch
--OUT:
--  x_unit_of_measure_tbl
--    list of default values from unit_of_measure
--  x_ship_to_org_id_tbl
--    list of default values from ship_to_org_id
--  x_ship_to_loc_id_tbl
--    list of default values from ship_to_loc_id
--  x_un_number_id_tbl
--    list of default values from un_number_id
--  x_hazard_class_id_tbl
--    list of default values from hazard_class_id
--  x_preferred_grade_tbl
--    list of default values from preferred_grade
--  x_negotiated_flag_tbl
--    list of default values from negotiated_flag
--  x_vendor_product_num_tbl
--    list of default values from vendor_product_num
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_info_from_req
(
  p_key                    IN po_session_gt.key%TYPE,
  p_index_tbl              IN DBMS_SQL.NUMBER_TABLE,
  p_lines                  IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_unit_of_measure_tbl    OUT NOCOPY PO_TBL_VARCHAR30,
  x_ship_to_org_id_tbl     OUT NOCOPY PO_TBL_NUMBER,
  x_ship_to_loc_id_tbl     OUT NOCOPY PO_TBL_NUMBER,
  x_un_number_id_tbl       OUT NOCOPY PO_TBL_NUMBER,
  x_hazard_class_id_tbl    OUT NOCOPY PO_TBL_NUMBER,
  x_preferred_grade_tbl    OUT NOCOPY PO_TBL_VARCHAR2000,
  x_negotiated_flag_tbl    OUT NOCOPY PO_TBL_VARCHAR1,
  x_vendor_product_num_tbl OUT NOCOPY PO_TBL_VARCHAR30
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_info_from_req';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold result read from temp table
  l_index_tbl1                  DBMS_SQL.NUMBER_TABLE;
  l_index_tbl2                  DBMS_SQL.NUMBER_TABLE;
  l_index1                      NUMBER;
  l_index2                      NUMBER;
  l_line_type_id_tbl            PO_TBL_NUMBER;
  l_quantity_tbl                PO_TBL_NUMBER;
  l_amount_tbl                  PO_TBL_NUMBER;
  l_item_id_tbl                 PO_TBL_NUMBER;
  l_category_id_tbl             PO_TBL_NUMBER;
  l_job_id_tbl                  PO_TBL_NUMBER;
  l_ship_to_org_id_tbl          PO_TBL_NUMBER;
  l_ship_to_loc_id_tbl          PO_TBL_NUMBER;
  l_from_header_id_tbl          PO_TBL_NUMBER;
  l_from_line_id_tbl            PO_TBL_NUMBER;
  l_oke_contract_header_id_tbl  PO_TBL_NUMBER;
  l_oke_contract_version_id_tbl PO_TBL_NUMBER;
  l_quantity_committed_tbl      PO_TBL_NUMBER;
  l_un_number_id_tbl            PO_TBL_NUMBER;
  l_hazard_class_id_tbl         PO_TBL_NUMBER;
  l_contract_id_tbl             PO_TBL_NUMBER;
  l_secondary_quantity_tbl      PO_TBL_NUMBER; -- bug 19286258, default the secondary quantity from Req to interfaces table.
  l_vendor_product_num_tbl      PO_TBL_VARCHAR30;
  l_item_desc_tbl               PO_TBL_VARCHAR2000;
  l_item_revision_tbl           PO_TBL_VARCHAR5;
  l_unit_of_measure_tbl         PO_TBL_VARCHAR30;
  l_transaction_reason_code_tbl PO_TBL_VARCHAR30;
  l_note_to_vendor_tbl          PO_TBL_VARCHAR2000;
  l_supplier_ref_number_tbl     PO_TBL_VARCHAR2000;
  l_contractor_first_name_tbl   PO_TBL_VARCHAR2000;
  l_contractor_last_name_tbl    PO_TBL_VARCHAR2000;
  l_preferred_grade_tbl         PO_TBL_VARCHAR2000;
  l_negotiated_flag_tbl         PO_TBL_VARCHAR1;
  l_effective_date_tbl          PO_TBL_DATE;
  l_expiration_date_tbl         PO_TBL_DATE;
  l_need_by_date_tbl            PO_TBL_DATE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  --intitalize the collection variables which are used to store output params
  x_unit_of_measure_tbl         := PO_TBL_VARCHAR30();
  x_ship_to_org_id_tbl          := PO_TBL_NUMBER();
  x_ship_to_loc_id_tbl          := PO_TBL_NUMBER();
  x_un_number_id_tbl            := PO_TBL_NUMBER();
  x_hazard_class_id_tbl         := PO_TBL_NUMBER();
  x_preferred_grade_tbl         := PO_TBL_VARCHAR2000();
  x_negotiated_flag_tbl         := PO_TBL_VARCHAR1();
  x_vendor_product_num_tbl      := PO_TBL_VARCHAR30();

  --intitalize the collection variables which are used to store the temp values
  l_line_type_id_tbl            :=	PO_TBL_NUMBER();
  l_quantity_tbl                :=	PO_TBL_NUMBER();
  l_amount_tbl                  :=	PO_TBL_NUMBER();
  l_item_id_tbl                 :=	PO_TBL_NUMBER();
  l_category_id_tbl             :=	PO_TBL_NUMBER();
  l_job_id_tbl                  :=	PO_TBL_NUMBER();
  l_ship_to_org_id_tbl          :=	PO_TBL_NUMBER();
  l_ship_to_loc_id_tbl          :=	PO_TBL_NUMBER();
  l_from_header_id_tbl          :=	PO_TBL_NUMBER();
  l_from_line_id_tbl            :=	PO_TBL_NUMBER();
  l_oke_contract_header_id_tbl  :=	PO_TBL_NUMBER();
  l_oke_contract_version_id_tbl :=	PO_TBL_NUMBER();
  l_quantity_committed_tbl      :=	PO_TBL_NUMBER();
  l_un_number_id_tbl            :=  PO_TBL_NUMBER();
  l_hazard_class_id_tbl         :=	PO_TBL_NUMBER();
  l_contract_id_tbl             :=	PO_TBL_NUMBER();
  l_secondary_quantity_tbl      :=	PO_TBL_NUMBER(); -- bug 19286258, default the secondary quantity from Req to interfaces table.
  l_vendor_product_num_tbl      :=	PO_TBL_VARCHAR30();
  l_item_desc_tbl               :=	PO_TBL_VARCHAR2000();
  l_item_revision_tbl           :=	PO_TBL_VARCHAR5();
  l_unit_of_measure_tbl         :=	PO_TBL_VARCHAR30();
  l_transaction_reason_code_tbl :=	PO_TBL_VARCHAR30();
  l_note_to_vendor_tbl          :=	PO_TBL_VARCHAR2000();
  l_supplier_ref_number_tbl     :=	PO_TBL_VARCHAR2000();
  l_contractor_first_name_tbl   :=	PO_TBL_VARCHAR2000();
  l_contractor_last_name_tbl    :=	PO_TBL_VARCHAR2000();
  l_preferred_grade_tbl         :=	PO_TBL_VARCHAR2000();
  l_negotiated_flag_tbl         :=	PO_TBL_VARCHAR1();
  l_effective_date_tbl          :=	PO_TBL_DATE();
  l_expiration_date_tbl         :=	PO_TBL_DATE();
  l_need_by_date_tbl            :=  PO_TBL_DATE();

  x_unit_of_measure_tbl.EXTEND(p_index_tbl.COUNT);
  x_ship_to_org_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_ship_to_loc_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_un_number_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_hazard_class_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_preferred_grade_tbl.EXTEND(p_index_tbl.COUNT);
  x_negotiated_flag_tbl.EXTEND(p_index_tbl.COUNT);
  x_vendor_product_num_tbl.EXTEND(p_index_tbl.COUNT);

  l_line_type_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_quantity_tbl.EXTEND(p_index_tbl.COUNT);
  l_amount_tbl.EXTEND(p_index_tbl.COUNT);
  l_item_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_category_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_job_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_ship_to_org_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_ship_to_loc_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_from_header_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_from_line_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_oke_contract_header_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_oke_contract_version_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_quantity_committed_tbl.EXTEND(p_index_tbl.COUNT);
  l_un_number_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_hazard_class_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_contract_id_tbl.EXTEND(p_index_tbl.COUNT);
  l_secondary_quantity_tbl.EXTEND(p_index_tbl.COUNT);
  l_vendor_product_num_tbl.EXTEND(p_index_tbl.COUNT);
  l_item_desc_tbl.EXTEND(p_index_tbl.COUNT);
  l_item_revision_tbl.EXTEND(p_index_tbl.COUNT);
  l_unit_of_measure_tbl.EXTEND(p_index_tbl.COUNT);
  l_transaction_reason_code_tbl.EXTEND(p_index_tbl.COUNT);
  l_note_to_vendor_tbl.EXTEND(p_index_tbl.COUNT);
  l_supplier_ref_number_tbl.EXTEND(p_index_tbl.COUNT);
  l_contractor_first_name_tbl.EXTEND(p_index_tbl.COUNT);
  l_contractor_last_name_tbl.EXTEND(p_index_tbl.COUNT);
  l_preferred_grade_tbl.EXTEND(p_index_tbl.COUNT);
  l_negotiated_flag_tbl.EXTEND(p_index_tbl.COUNT);
  l_effective_date_tbl.EXTEND(p_index_tbl.COUNT);
  l_expiration_date_tbl.EXTEND(p_index_tbl.COUNT);
  l_need_by_date_tbl.EXTEND(p_index_tbl.COUNT);

  d_position := 20;

  -- retrieve the values based on requisition line id
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(
      key            -- p_key
    , index_num1     -- p_index_tbl
    , num1           -- line_type_id_tbl
    , num2           -- quantity_tbl
    , num3           -- amount_tbl
    , num4           -- item_id_tbl
    , num5           -- category_id_tbl
    , num6           -- job_id_tbl
    , num7           -- ship_to_org_id_tbl
    , num8           -- ship_to_loc_id_tbl
    , num9           -- from_header_id_tbl
    , num10          -- from_line_id_tbl
    , char1          -- vendor_product_num_tbl
    , char2          -- item_desc_tbl
    , char3          -- item_revision_tbl
    , char4          -- unit_of_measure_tbl
    , char5          -- transaction_reason_code_tbl
    , char6          -- note_to_vendor_tbl
    , date1          -- hd_start_date_tbl
    , date2)         -- expiration_date_tbl
    SELECT p_key,
      p_index_tbl(i)
    , prl.line_type_id
    , DECODE(prl.order_type_lookup_code, 'FIXED PRICE', NULL
                ,'RATE', NULL, prl.quantity)
    , prl.amount
    , prl.item_id
    , prl.category_id
    , prl.job_id
    , prl.destination_organization_id
    , NVL(hrl.ship_to_location_id,prl.deliver_to_location_id)  -- bug 18888329
    , DECODE(prl.document_type_code, 'CONTRACT', NULL, prl.blanket_po_header_id)
    , DECODE(prl.document_type_code
           , 'CONTRACT', NULL,
             (SELECT po_line_id
              FROM po_lines_all
              WHERE po_header_id = prl.blanket_po_header_id
               AND line_num = prl.blanket_po_line_num))
    , prl.suggested_vendor_product_code
    , prl.item_description
    , prl.item_revision
    , prl.unit_meas_lookup_code
    , prl.transaction_reason_code
    , prl.note_to_vendor
    , prl.assignment_start_date
    , prl.assignment_end_date
    FROM po_requisition_lines_all prl
       , po_req_distributions_all prd
       , hr_locations_all hrl    -- bug 18888329
    WHERE p_lines.requisition_line_id_tbl(i) IS NOT NULL
      AND prl.requisition_line_id = p_lines.requisition_line_id_tbl(i)
      AND prd.requisition_line_id = prl.requisition_line_id
      AND hrl.location_id(+) = prl.deliver_to_location_id;  -- bug 18888329

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING index_num1, num1, num2, num3, num4, num5, num6, num7, num8, num9, num10,
            char1, char2, char3, char4, char5, char6, date1, date2
  BULK COLLECT INTO
    l_index_tbl1
  , l_line_type_id_tbl
  , l_quantity_tbl
  , l_amount_tbl
  , l_item_id_tbl
  , l_category_id_tbl
  , l_job_id_tbl
  , l_ship_to_org_id_tbl
  , l_ship_to_loc_id_tbl
  , l_from_header_id_tbl
  , l_from_line_id_tbl
  , l_vendor_product_num_tbl
  , l_item_desc_tbl
  , l_item_revision_tbl
  , l_unit_of_measure_tbl
  , l_transaction_reason_code_tbl
  , l_note_to_vendor_tbl
  , l_effective_date_tbl
  , l_expiration_date_tbl;

  d_position := 30;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl1.COUNT
  LOOP

    l_index1 := l_index_tbl1(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl1(i));
      PO_LOG.stmt(d_module, d_position, 'line_type_id_tbl', l_line_type_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'quantity_tbl', l_quantity_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'amount_tbl', l_amount_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'item_id_tbl', l_item_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'category_id_tbl', l_category_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'job_id_tbl', l_job_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'ship_to_org_id_tbl', l_ship_to_org_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'ship_to_loc_id_tbl', l_ship_to_loc_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'from_header_id_tbl', l_from_header_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'from_line_id_tbl', l_from_line_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'vendor_product_num_tbl', l_vendor_product_num_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'item_desc_tbl', l_item_desc_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'item_revision_tbl', l_item_revision_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'unit_of_measure_tbl', l_unit_of_measure_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'transaction_reason_code_tbl', l_transaction_reason_code_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'note_to_vendor_tbl', l_note_to_vendor_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'effective_date_tbl', l_effective_date_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'expiration_date_tbl', l_expiration_date_tbl(i));
    END IF;

      p_lines.line_type_id_tbl(l_index1)             := NVL(p_lines.line_type_id_tbl(l_index1), l_line_type_id_tbl(i));
      p_lines.quantity_tbl(l_index1)                 := NVL(p_lines.quantity_tbl(l_index1), l_quantity_tbl(i));
      p_lines.amount_tbl(l_index1)                   := NVL(p_lines.amount_tbl(l_index1), l_amount_tbl(i));
      p_lines.item_id_tbl(l_index1)                  := NVL(p_lines.item_id_tbl(l_index1), l_item_id_tbl(i));
      p_lines.category_id_tbl(l_index1)              := NVL(p_lines.category_id_tbl(l_index1), l_category_id_tbl(i));
      p_lines.job_id_tbl(l_index1)                   := NVL(p_lines.job_id_tbl(l_index1), l_job_id_tbl(i));
      x_ship_to_org_id_tbl(l_index1)                 := l_ship_to_org_id_tbl(i);
      x_ship_to_loc_id_tbl(l_index1)                 := l_ship_to_loc_id_tbl(i);
      x_vendor_product_num_tbl(l_index1)             := NVL(p_lines.vendor_product_num_tbl(l_index1), l_vendor_product_num_tbl(i));
      p_lines.item_desc_tbl(l_index1)                := NVL(p_lines.item_desc_tbl(l_index1), l_item_desc_tbl(i));
      p_lines.item_revision_tbl(l_index1)            := NVL(p_lines.item_revision_tbl(l_index1), l_item_revision_tbl(i));
      x_unit_of_measure_tbl(l_index1)                := l_unit_of_measure_tbl(i);
      p_lines.transaction_reason_code_tbl(l_index1)  := NVL(p_lines.transaction_reason_code_tbl(l_index1), l_transaction_reason_code_tbl(i));
      p_lines.note_to_vendor_tbl(l_index1)           := NVL(p_lines.note_to_vendor_tbl(l_index1), l_note_to_vendor_tbl(i));
      p_lines.effective_date_tbl(l_index1)           := NVL(p_lines.effective_date_tbl(l_index1), l_effective_date_tbl(i));
      p_lines.expiration_date_tbl(l_index1)          := NVL(p_lines.expiration_date_tbl(l_index1), l_expiration_date_tbl(i));

      IF PO_PDOI_PARAMS.g_request.calling_module = PO_PDOI_CONSTANTS.g_CALL_MOD_CONCURRENT_PRGM THEN
        -- If interface has contract id populated then from_header_id and
        --   from_line_id should be null.
        IF p_lines.contract_id_tbl(l_index1) IS NOT NULL THEN
          p_lines.from_header_id_tbl(l_index1)         := NULL;
          p_lines.from_line_id_tbl(l_index1)           := NULL;
       ELSE
         p_lines.from_header_id_tbl(l_index1)         := NVL(p_lines.from_header_id_tbl(l_index1), l_from_header_id_tbl(i));
         p_lines.from_line_id_tbl(l_index1)           := NVL(p_lines.from_line_id_tbl(l_index1), l_from_line_id_tbl(i));
        END IF;
      END IF;

  END LOOP;

  d_position := 40;

  -- retrieve the values based on requisition line id
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(
      key            -- p_key
    , index_num1     -- p_index_tbl
    , num1           -- oke_contract_header_id_tbl
    , num2           -- oke_contract_version_id_tbl
    , num3           -- quantity_committed_tbl
    , num4           -- un_number_id_tbl
    , num5           -- hazard_class_id_tbl
    , num6           -- contract_id_tbl
    , num7           -- secondary_quantity_tbl
    , char1          -- supplier_ref_number_tbl
    , char2          -- contractor_first_name_tbl
    , char3          -- contractor_last_name_tbl
    , char4          -- preferred_grade_tbl
    , char5          -- negotiated_flag_tbl
    , date1)         -- need_by_date_tbl
    SELECT p_key,
      p_index_tbl(i)
    , prl.oke_contract_header_id
    , prl.oke_contract_version_id
    , prl.quantity
    , prl.un_number_id
    , prl.hazard_class_id
    , DECODE(prl.document_type_code, 'CONTRACT', prl.blanket_po_header_id, NULL)
    , prl.secondary_quantity
    , prl.supplier_ref_number
    , prl.candidate_first_name
    , prl.candidate_last_name
    , prl.preferred_grade
    , prl.negotiated_by_preparer_flag
    , prl.need_by_date
    FROM po_requisition_lines_all prl
       , po_req_distributions_all prd
    WHERE p_lines.requisition_line_id_tbl(i) IS NOT NULL
      AND prl.requisition_line_id = p_lines.requisition_line_id_tbl(i)
      AND prd.requisition_line_id = prl.requisition_line_id;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING index_num1, num1, num2, num3, num4, num5, num6, num7,
            char1, char2, char3, char4, char5,date1
  BULK COLLECT INTO
    l_index_tbl2
  , l_oke_contract_header_id_tbl
  , l_oke_contract_version_id_tbl
  , l_quantity_committed_tbl
  , l_un_number_id_tbl
  , l_hazard_class_id_tbl
  , l_contract_id_tbl
  , l_secondary_quantity_tbl
  , l_supplier_ref_number_tbl
  , l_contractor_first_name_tbl
  , l_contractor_last_name_tbl
  , l_preferred_grade_tbl
  , l_negotiated_flag_tbl
  , l_need_by_date_tbl;

  d_position := 50;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl2.COUNT
  LOOP

    l_index2 := l_index_tbl2(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl2(i));
      PO_LOG.stmt(d_module, d_position, 'oke_contract_header_id_tbl', l_oke_contract_header_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'oke_contract_version_id_tbl', l_oke_contract_version_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'quantity_committed_tbl', l_quantity_committed_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'un_number_id_tbl', l_un_number_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'hazard_class_id_tbl', l_hazard_class_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'contract_id_tbl', l_contract_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'secondary_quantity_tbl', l_secondary_quantity_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'supplier_ref_number_tbl', l_supplier_ref_number_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'contractor_first_name_tbl', l_contractor_first_name_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'contractor_last_name_tbl', l_contractor_last_name_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'preferred_grade_tbl', l_preferred_grade_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'negotiated_flag_tbl', l_negotiated_flag_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'l_need_by_date_tbl', l_need_by_date_tbl(i));
    END IF;

      p_lines.oke_contract_header_id_tbl(l_index2)   := NVL(p_lines.oke_contract_header_id_tbl(l_index2), l_oke_contract_header_id_tbl(i));
      p_lines.oke_contract_version_id_tbl(l_index2)  := NVL(p_lines.oke_contract_version_id_tbl(l_index2), l_oke_contract_version_id_tbl(i));
      -- Bug#19879160 : Quantity committed should be defaulted only for Blanket document
      IF PO_PDOI_PARAMS.g_request.document_type = PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET
      THEN
        p_lines.quantity_committed_tbl(l_index2)     := NVL(p_lines.quantity_committed_tbl(l_index2), l_quantity_committed_tbl(i));
      END IF;
      x_un_number_id_tbl(l_index2)                   := l_un_number_id_tbl(i);
      x_hazard_class_id_tbl(l_index2)                := l_hazard_class_id_tbl(i);
      p_lines.secondary_quantity_tbl(l_index2)       := NVL(p_lines.secondary_quantity_tbl(l_index2), l_secondary_quantity_tbl(i));
      p_lines.supplier_ref_number_tbl(l_index2)      := NVL(p_lines.supplier_ref_number_tbl(l_index2), l_supplier_ref_number_tbl(i));
      p_lines.contractor_first_name_tbl(l_index2)    := NVL(p_lines.contractor_first_name_tbl(l_index2), l_contractor_first_name_tbl(i));
      p_lines.contractor_last_name_tbl(l_index2)     := NVL(p_lines.contractor_last_name_tbl(l_index2), l_contractor_last_name_tbl(i));
      x_preferred_grade_tbl(l_index2)                := l_preferred_grade_tbl(i);
      x_negotiated_flag_tbl(l_index2)                := l_negotiated_flag_tbl(i);
      p_lines.need_by_date_tbl(l_index2)             := NVL(p_lines.need_by_date_tbl(l_index2), l_need_by_date_tbl(i));

      IF PO_PDOI_PARAMS.g_request.calling_module = PO_PDOI_CONSTANTS.g_CALL_MOD_CONCURRENT_PRGM THEN
          -- If interface has from_doc details populated then contract id should be null.
        IF p_lines.from_header_id_tbl(l_index2) IS NOT NULL
          AND p_lines.from_line_id_tbl(l_index2) IS NOT NULL THEN
          p_lines.contract_id_tbl(l_index2)            := NULL;
        ELSE
         p_lines.contract_id_tbl(l_index2)            := NVL(p_lines.contract_id_tbl(l_index2), l_contract_id_tbl(i));
        END IF;
      END IF;

  END LOOP;

  d_position := 60;

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
END default_info_from_req;

-- <<PDOI Enhancement Bug#17063664 End>>

-----------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_line_type
--Function:
--  default information from line types;
--  the information can be defaulted from line type include:
--  1. order_type_lookup_code
--  2. purchase_basis
--  3. matching_basis
--  4. category_id
--  5. unit_of_measure
--  6. unit_price
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_line_type_id_tbl
--    list of line_type_ids read within the batch
--IN OUT:
--  x_order_type_lookup_code_tbl
--    list of default values from line_type_ids
--  x_purchase_basis_tbl
--    list of default values from line_type_ids
--  x_matching_basis_tbl
--    list of default values from line_type_ids
--OUT:
--  x_category_id_tbl
--    list of default values from line_type_ids
--  x_unit_of_measure_tbl
--    list of default values from line_type_ids
--  x_unit_price_tbl
--    list of default values from line_type_ids
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_info_from_line_type
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_line_type_id_tbl           IN PO_TBL_NUMBER,
  x_order_type_lookup_code_tbl IN OUT NOCOPY PO_TBL_VARCHAR30,
  x_purchase_basis_tbl         IN OUT NOCOPY PO_TBL_VARCHAR30,
  x_matching_basis_tbl         IN OUT NOCOPY PO_TBL_VARCHAR30,
  x_category_id_tbl            OUT NOCOPY PO_TBL_NUMBER,
  x_unit_of_measure_tbl        OUT NOCOPY PO_TBL_VARCHAR30,
  x_unit_price_tbl             OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_info_from_line_type';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold result read from temp table
  l_index_tbl                  PO_TBL_NUMBER;
  l_order_type_lookup_code_tbl PO_TBL_VARCHAR30;
  l_purchase_basis_tbl         PO_TBL_VARCHAR30;
  l_matching_basis_tbl         PO_TBL_VARCHAR30;
  l_category_id_tbl            PO_TBL_NUMBER;
  l_unit_of_measure_tbl        PO_TBL_VARCHAR30;
  l_unit_price_tbl             PO_TBL_NUMBER;

  -- current accessing index in the loop
  l_index                      NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_category_id_tbl     := PO_TBL_NUMBER();
  x_unit_of_measure_tbl := PO_TBL_VARCHAR30();
  x_unit_price_tbl      := PO_TBL_NUMBER();

  x_category_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_unit_of_measure_tbl.EXTEND(p_index_tbl.COUNT);
  x_unit_price_tbl.EXTEND(p_index_tbl.COUNT);

  -- retrieve the values based on line type id
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, char1, char2, char3, num2, char4, num3)
    SELECT p_key,
           p_index_tbl(i),
           order_type_lookup_code,
           purchase_basis,
           matching_basis,
           category_id,
           unit_of_measure,
           unit_price
    FROM   po_line_types_b
    WHERE  line_type_id = p_line_type_id_tbl(i);

  d_position := 10;

  -- read result from temp table and delete the records at the same time
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1, char2, char3, num2, char4, num3
  BULK COLLECT INTO
    l_index_tbl,
    l_order_type_lookup_code_tbl,
    l_purchase_basis_tbl,
    l_matching_basis_tbl,
    l_category_id_tbl,
    l_unit_of_measure_tbl,
    l_unit_price_tbl;

  d_position := 20;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'new order type',
                  l_order_type_lookup_code_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new purchase basis',
                  l_purchase_basis_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new matching basis',
                  l_matching_basis_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new category id',
                  l_category_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new unit of measure',
                  l_unit_of_measure_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new unit price',
                  l_unit_price_tbl(i));
    END IF;

    x_order_type_lookup_code_tbl(l_index) := l_order_type_lookup_code_tbl(i);
    x_purchase_basis_tbl(l_index) := l_purchase_basis_tbl(i);
    x_matching_basis_tbl(l_index) := l_matching_basis_tbl(i);
    x_category_id_tbl(l_index) := l_category_id_tbl(i);
    x_unit_of_measure_tbl(l_index) := l_unit_of_measure_tbl(i);
    x_unit_price_tbl(l_index) := l_unit_price_tbl(i);
  END LOOP;

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
END default_info_from_line_type;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_item
--Function:
--  default information from item;
--  the information can be defaulted from item include:
--  1. item_description
--  2. unit_of_measure
--  3. unit_price
--  4. category_id
--  5. un_number_id
--  6. hazard_class_id
--  7. market_price
--  8. secondary_unit_of_measure
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_item_id_tbl
--    list of item_ids read within the batch
--IN OUT:
--OUT:
--  x_item_desc_tbl
--    list of default values from item_desc
--  x_unit_of_measure_tbl
--    list of default values from unit_of_measure
--  x_unit_price_tbl
--    list of default values from unit_price
--  x_category_id_tbl
--    list of default values from category_id
--  x_un_number_id_tbl
--    list of default values from un_number_id
--  x_hazard_class_id_tbl
--    list of default values from hazard_class_id
--  x_market_price_tbl
--    list of default values from market_price
--  x_secondary_unit_of_meas_tbl
--    list of default values from secondary_unit_of_measure
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_info_from_item
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_item_id_tbl                IN PO_TBL_NUMBER,
  x_item_desc_tbl              OUT NOCOPY PO_TBL_VARCHAR2000,
  x_unit_of_measure_tbl        OUT NOCOPY PO_TBL_VARCHAR30,
  x_unit_price_tbl             OUT NOCOPY PO_TBL_NUMBER,
  x_category_id_tbl            OUT NOCOPY PO_TBL_NUMBER,
  x_un_number_id_tbl           OUT NOCOPY PO_TBL_NUMBER,
  x_hazard_class_id_tbl        OUT NOCOPY PO_TBL_NUMBER,
  x_market_price_tbl           OUT NOCOPY PO_TBL_NUMBER,
  x_secondary_unit_of_meas_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_grade_control_flag_tbl     OUT NOCOPY PO_TBL_VARCHAR1
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_info_from_item';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold result read from temp table
  l_index_tbl                  PO_TBL_NUMBER;
  l_item_desc_tbl              PO_TBL_VARCHAR2000;
  l_unit_of_measure_tbl        PO_TBL_VARCHAR30;
  l_unit_price_tbl             PO_TBL_NUMBER;
  l_category_id_tbl            PO_TBL_NUMBER;
  l_un_number_id_tbl           PO_TBL_NUMBER;
  l_hazard_class_id_tbl        PO_TBL_NUMBER;
  l_market_price_tbl           PO_TBL_NUMBER;
  l_secondary_unit_of_meas_tbl PO_TBL_VARCHAR30;
  l_it_grade_cntl_flag_tbl     PO_TBL_VARCHAR1;

  -- current accessing index in the loop
  l_index                      NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_item_desc_tbl              := PO_TBL_VARCHAR2000();
  x_unit_of_measure_tbl        := PO_TBL_VARCHAR30();
  x_unit_price_tbl             := PO_TBL_NUMBER();
  x_category_id_tbl            := PO_TBL_NUMBER();
  x_un_number_id_tbl           := PO_TBL_NUMBER();
  x_hazard_class_id_tbl        := PO_TBL_NUMBER();
  x_market_price_tbl           := PO_TBL_NUMBER();
  x_secondary_unit_of_meas_tbl := PO_TBL_VARCHAR30();
  x_grade_control_flag_tbl     := PO_TBL_VARCHAR1();

  x_item_desc_tbl.EXTEND(p_index_tbl.COUNT);
  x_unit_of_measure_tbl.EXTEND(p_index_tbl.COUNT);
  x_unit_price_tbl.EXTEND(p_index_tbl.COUNT);
  x_category_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_un_number_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_hazard_class_id_tbl.EXTEND(p_index_tbl.COUNT);
  x_market_price_tbl.EXTEND(p_index_tbl.COUNT);
  x_secondary_unit_of_meas_tbl.EXTEND(p_index_tbl.COUNT);
  x_grade_control_flag_tbl.EXTEND(p_index_tbl.COUNT);

  -- retrieve the values based on item id and default inv org id
  -- bug 4723323: get secondary_unit_of_measure value for dual-um
  --              control item, used in default logic
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, char1, char2, num2, num3,
                              num4, num5, num6, char3, char4)
    SELECT p_key,
           p_index_tbl(i),
           item_tl.description,
           item.primary_unit_of_measure,
           item.list_price_per_unit,
           item_cat.category_id,
           item.un_number_id,
           item.hazard_class_id,
           item.market_price,
           decode(item.tracking_quantity_ind, 'PS', uom.unit_of_measure, NULL),
           item.grade_control_flag
    FROM   mtl_item_categories item_cat,
           mtl_system_items item,
           mtl_system_items_tl item_tl,
           mtl_units_of_measure uom
    WHERE  item.inventory_item_id = p_item_id_tbl(i)
    AND    item_tl.inventory_item_id = item.inventory_item_id
    AND    item_cat.inventory_item_id = item.inventory_item_id
    AND    item.organization_id = PO_PDOI_PARAMS.g_sys.def_inv_org_id
    AND    item_tl.language = USERENV('LANG')
    AND    item_tl.organization_id = PO_PDOI_PARAMS.g_sys.def_inv_org_id
    AND    item_cat.category_set_id = PO_PDOI_PARAMS.g_sys.def_cat_set_id
    AND    item_cat.organization_id = PO_PDOI_PARAMS.g_sys.def_inv_org_id
    AND    item.secondary_uom_code = uom.uom_code(+);

  d_position := 10;

  -- read result from temp table and delete the records at the same time
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1, char2, num2, num3, num4, num5, num6, char3, char4
  BULK COLLECT INTO
    l_index_tbl,
    l_item_desc_tbl,
    l_unit_of_measure_tbl,
    l_unit_price_tbl,
    l_category_id_tbl,
    l_un_number_id_tbl,
    l_hazard_class_id_tbl,
    l_market_price_tbl,
    l_secondary_unit_of_meas_tbl,
    l_it_grade_cntl_flag_tbl;

  d_position := 20;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new item desc',
                  l_item_desc_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new unit of measure',
                  l_unit_of_measure_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new unit price',
                  l_unit_price_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new category id',
                  l_category_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new un number id',
                  l_un_number_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new hazard class id',
                  l_hazard_class_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new market price',
                  l_market_price_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new secondary unit of measure',
                  l_secondary_unit_of_meas_tbl(i));
    END IF;

    x_item_desc_tbl(l_index) := l_item_desc_tbl(i);
    x_unit_of_measure_tbl(l_index) := l_unit_of_measure_tbl(i);
    x_unit_price_tbl(l_index) := l_unit_price_tbl(i);
    x_category_id_tbl(l_index) := l_category_id_tbl(i);
    x_un_number_id_tbl(l_index) := l_un_number_id_tbl(i);
    x_hazard_class_id_tbl(l_index) := l_hazard_class_id_tbl(i);
    x_market_price_tbl(l_index) := l_market_price_tbl(i);
    x_secondary_unit_of_meas_tbl(l_index) := l_secondary_unit_of_meas_tbl(i);
    x_grade_control_flag_tbl(l_index) := l_it_grade_cntl_flag_tbl(i);

  END LOOP;

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
END default_info_from_item;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_job
--Function:
--  default information from job;
--  the information can be defaulted from job include:
--  1. item_description
--  2. category_id
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_job_id_tbl
--    list of job_ids read within the batch
--IN OUT:
--OUT:
--  x_item_desc_tbl
--    list of default values from job_ids
--  x_category_id_tbl
--    list of default values from job_ids
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_info_from_job
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_job_id_tbl                 IN PO_TBL_NUMBER,
  x_item_desc_tbl              OUT NOCOPY PO_TBL_VARCHAR2000,
  x_category_id_tbl            OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_info_from_job';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index                      NUMBER;

  -- variables to hold result read from temp table
  l_index_tbl                  PO_TBL_NUMBER;
  l_item_desc_tbl              PO_TBL_VARCHAR2000;
  l_category_id_tbl            PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_item_desc_tbl              := PO_TBL_VARCHAR2000();
  x_category_id_tbl            := PO_TBL_NUMBER();

  x_item_desc_tbl.EXTEND(p_index_tbl.COUNT);
  x_category_id_tbl.EXTEND(p_index_tbl.COUNT);

  -- retrieve the values based on line type id
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, char1, num2)
    SELECT p_key,
           p_index_tbl(i),
           association.job_description,
           association.category_id
    FROM   po_job_associations association,
           per_jobs_vl job
    WHERE  job.job_id = p_job_id_tbl(i)
    AND    association.job_id = job.job_id
    AND    TRUNC(sysdate) < TRUNC(NVL(association.inactive_date, sysdate+1))
    AND    TRUNC(sysdate) BETWEEN TRUNC(NVL(job.date_from, sysdate))
           AND TRUNC(NVL(job.date_to, sysdate+1));

  d_position := 10;

  -- read result from temp table and delete the records at the same time
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, char1, num2
  BULK COLLECT INTO
    l_index_tbl,
    l_item_desc_tbl,
    l_category_id_tbl;

  d_position := 20;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new item desc', l_item_desc_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new category id', l_category_id_tbl(i));
    END IF;

    x_item_desc_tbl(l_index) := l_item_desc_tbl(i);
    x_category_id_tbl(l_index) := l_category_id_tbl(i);
  END LOOP;

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
END default_info_from_job;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_po_cat_id_from_ip
--Function: default po category_id from ip_category_id
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_ip_category_id_tbl
--    list of ip_category_ids read within the batch
--IN OUT:
--  x_po_category_id_tbl
--    list of po_category_ids defaulted from ip_category_ids
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_po_cat_id_from_ip
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_ip_category_id_tbl         IN PO_TBL_NUMBER,
  x_po_category_id_tbl         IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_po_cat_id_from_ip';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold result read from temp table
  l_index_tbl                  PO_TBL_NUMBER;
  l_result_tbl                 PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_ip_category_id_tbl', p_ip_category_id_tbl);
    PO_LOG.proc_begin(d_module, 'x_po_category_id_tbl',
                      x_po_category_id_tbl);
  END IF;

  -- retrieve the values based on ip category id
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           po_category_id
    FROM   icx_cat_shopping_cat_map_v
    WHERE  p_ip_category_id_tbl(i) IS NOT NULL
    AND    x_po_category_id_tbl(i) IS NULL
    AND    shopping_category_id = p_ip_category_id_tbl(i);

  d_position := 10;

  -- read result from temp table and delete the records at the same time
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2
  BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new po category id', l_result_tbl(i));
    END IF;

    x_po_category_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END default_po_cat_id_from_ip;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_ip_cat_id_from_po
--Function: default ip_category_id from po category_id
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_po_category_id_tbl
--    list of po_category_ids read within the batch
--IN OUT:
--  x_ip_category_id_tbl
--    list of ip_category_ids defaulted from po_category_ids
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_ip_cat_id_from_po
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_po_category_id_tbl         IN PO_TBL_NUMBER,
  x_ip_category_id_tbl         IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_ip_cat_id_from_po';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold result read from temp table
  l_index_tbl                  PO_TBL_NUMBER;
  l_result_tbl                 PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_po_category_id_tbl', p_po_category_id_tbl);
    PO_LOG.proc_begin(d_module, 'x_ip_category_id_tbl',
                      x_ip_category_id_tbl);
  END IF;

  -- retrieve the values based on po category id
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           shopping_category_id
    FROM   icx_cat_purchasing_cat_map_v
    WHERE  p_po_category_id_tbl(i) IS NOT NULL
    AND    x_ip_category_id_tbl(i) IS NULL
    AND    po_category_id = p_po_category_id_tbl(i);

  d_position := 10;

  -- read result from temp table and delete the records at the same time
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2
  BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new ip category id', l_result_tbl(i));
    END IF;

    x_ip_category_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END default_ip_cat_id_from_po;

-----------------------------------------------------------------------
--Start of Comments
--Name: default_hc_id_from_un_number
--Function: default hazard_class_id from un_number
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_un_number_tbl
--    list of un_numbers read within the batch
--IN OUT:
--  x_hazard_class_id_tbl
--    list of hazard_class_ids defaulted from un_numbers
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE default_hc_id_from_un_number
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_un_number_tbl              IN PO_TBL_VARCHAR30,
  x_hazard_class_id_tbl        IN OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_hc_id_from_un_number';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold result read from temp table
  l_index_tbl                  PO_TBL_NUMBER;
  l_result_tbl                 PO_TBL_NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'p_un_number_tbl', p_un_number_tbl);
    PO_LOG.proc_begin(d_module, 'x_hazard_class_id_tbl',
                      x_hazard_class_id_tbl);
  END IF;

  -- retrieve the values based on line type id
  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           hazard_class_id
    FROM   po_un_numbers_vl
    WHERE  p_un_number_tbl(i) IS NOT NULL
    AND    x_hazard_class_id_tbl(i) IS NULL
    AND    sysdate < nvl(inactive_date, sysdate +1)
    AND    un_number = p_un_number_tbl(i);

  d_position := 10;

  -- read result from temp table and delete the records at the same time
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2
  BULK COLLECT INTO l_index_tbl, l_result_tbl;

  d_position := 20;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new hazard class id', l_result_tbl(i));
    END IF;

    x_hazard_class_id_tbl(l_index_tbl(i)) := l_result_tbl(i);
  END LOOP;

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
END default_hc_id_from_un_number;


-- bug 16674612
-----------------------------------------------------------------------
--Start of Comments
--Name: default_info_from_vendor
--Function:
--  default information from item;
--  the type_1099 can be defaulted from vendor_id
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_vendor_id_tbl
--    list of vendor_ids read within the batch
--IN OUT:
--OUT:
--  x_type_1099_tbl
--    list of default values from type_1099

--End of Comments
------------------------------------------------------------------------
PROCEDURE default_info_from_vendor
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_id_tbl              IN PO_TBL_NUMBER,
  x_type_1099_tbl              OUT NOCOPY PO_TBL_VARCHAR15
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_info_from_vendor';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold result read from temp table
  l_index_tbl                  PO_TBL_NUMBER;
  l_type_1099_tbl              PO_TBL_VARCHAR15;

  -- current accessing index in the loop
  l_index                      NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_type_1099_tbl := PO_TBL_VARCHAR15();

  x_type_1099_tbl.EXTEND(p_index_tbl.COUNT);


  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, char1)
    SELECT p_key,
           p_index_tbl(i),
           type_1099
    FROM   po_vendors
    WHERE  vendor_id = p_vendor_id_tbl(i);

  d_position := 10;

  -- read result from temp table and delete the records at the same time
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1,char1
  BULK COLLECT INTO
    l_index_tbl,
    l_type_1099_tbl;

  d_position := 20;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new type 1099',
                  l_type_1099_tbl(i));
    END IF;

    x_type_1099_tbl(l_index) := l_type_1099_tbl(i);
  END LOOP;

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
END default_info_from_vendor;

-----------------------------------------------------------------------
-- <<PDOI Enhancement Bug#17063664 Start>>

--Start of Comments
--Name: default_info_from_vendor_site
--Function:
--  default information from item;
--  the retaiinage_rate can be defaulted from vendor_site_id
--Parameters:
--IN:
--  p_key
--    key used to identify rows in po_session_gt
--  p_index_tbl
--    table containging the indexes of all rows
--  p_vendor_site_id_tbl
--    list of vendor_site_ids read within the batch
--IN OUT:
--OUT:
--  x_retainage_rate_tbl
--    list of default values from retaiinage_rate

--End of Comments
------------------------------------------------------------------------
PROCEDURE default_info_from_vendor_site
(
  p_key                        IN po_session_gt.key%TYPE,
  p_index_tbl                  IN DBMS_SQL.NUMBER_TABLE,
  p_vendor_site_id_tbl         IN PO_TBL_NUMBER,
  x_retainage_rate_tbl         OUT NOCOPY PO_TBL_NUMBER
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'default_info_from_vendor_site';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold result read from temp table
  l_index_tbl                  PO_TBL_NUMBER;
  l_retainage_rate_tbl         PO_TBL_NUMBER;

  -- current accessing index in the loop
  l_index                      NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_retainage_rate_tbl := PO_TBL_NUMBER();
  x_retainage_rate_tbl.EXTEND(p_index_tbl.COUNT);


  FORALL i IN 1..p_index_tbl.COUNT
    INSERT INTO po_session_gt(key, num1, num2)
    SELECT p_key,
           p_index_tbl(i),
           retainage_rate
    FROM   po_vendor_sites_all
    WHERE  vendor_site_id = p_vendor_site_id_tbl(i);

  d_position := 10;

  -- read result from temp table and delete the records at the same time
  DELETE FROM po_session_gt
  WHERE  key = p_key
  RETURNING num1, num2
  BULK COLLECT INTO
    l_index_tbl,
    l_retainage_rate_tbl;

  d_position := 20;

  -- set the result in OUT parameters
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'new retainage rate',
                  l_retainage_rate_tbl(i));
    END IF;

    x_retainage_rate_tbl(l_index) := l_retainage_rate_tbl(i);
  END LOOP;

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
END default_info_from_vendor_site;

-- <<PDOI Enhancement Bug#17063664 End>>

-----------------------------------------------------------------------
--Start of Comments
--Name: match_lines_on_item_info
--Function:
-- This function will process all lines to match lines based on
-- line number and item info
--Parameters:
--IN OUT:
--  x_lines
--    record containing line info within the batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE match_lines_on_item_info
(
  x_lines         IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'match_lines_on_item_info';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- hold the key value which is used to identify rows in temp table
  l_key           po_session_gt.key%TYPE;
  l_index_key     po_session_gt.key%TYPE;

  l_index_tbl          PO_TBL_NUMBER;

  -- identify lines that are going to be processed
  l_processing_line_tbl DBMS_SQL.NUMBER_TABLE;

  -- hash table of po_line_id based on po_header_id and line num
  --TYPE line_ref_type IS TABLE OF DBMS_SQL.NUMBER_TABLE INDEX BY PLS_INTEGER;
-- Added as part of bug 8836290 to handle line_num's decimals also without grouping
  TYPE line_ref_internal_type IS TABLE OF NUMBER INDEX BY VARCHAR2(32);
  TYPE line_ref_type IS TABLE OF line_ref_internal_type INDEX BY PLS_INTEGER;
  l_line_reference_tbl line_ref_type;
  l_po_header_id   NUMBER;
  l_line_num       NUMBER;

  -- temp variable used in processing
  l_index          NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- get new key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  --Identify the lines which needs to be processed
  --1. x_lines.match_line_found_tbl(i) is false
  -- This flag indicates lines are already processed
  -- in assign line num procedure.
  --2. x_lines.error_flag_tbl(i) = FND_API.G_FALSE

  FOR i IN 1..x_lines.rec_count
  LOOP
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'index', i);
        PO_LOG.stmt(d_module, d_position, 'Match Line Found flag ', x_lines.match_line_found_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'Error Flag ', x_lines.error_flag_tbl(i));
      END IF;
    IF x_lines.match_line_found_tbl(i) = FND_API.g_FALSE AND
       x_lines.error_flag_tbl(i) = FND_API.g_FALSE THEN

      l_processing_line_tbl(i) := i;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'processing index', i);
        PO_LOG.stmt(d_module, d_position, 'Interface line Id  ', x_lines.intf_line_id_tbl(i));
      END IF;
    END IF;
  END LOOP;

  d_position := 10;

  --Get all the matching criteria attributes
  FORALL i IN INDICES OF l_processing_line_tbl
  INSERT INTO po_lines_gt
    (po_header_id,
     po_line_id,
     line_num,
     line_type_id,
     item_id,
     item_revision,
     unit_meas_lookup_code,
     from_header_id,
     from_line_id,
     oke_contract_header_id,
     oke_contract_version_id,
     bid_number,
     bid_line_number,
     contract_id,
     category_id,
     item_description,
     preferred_grade,
     transaction_reason_code,
     vendor_product_num,
     expiration_date,
     purchase_basis,  --Bug#17788591
     matching_basis   --Bug#17788591
    )
  VALUES(x_lines.hd_po_header_id_tbl(i),
         x_lines.intf_line_id_tbl(i),
  	 x_lines.line_num_tbl(i),
	 x_lines.line_type_id_tbl(i),
	 x_lines.item_id_tbl(i),
	 x_lines.item_revision_tbl(i),
	 x_lines.unit_of_measure_tbl(i),
	 x_lines.from_header_id_tbl(i),
	 x_lines.from_line_id_tbl(i),
	 x_lines.oke_contract_header_id_tbl(i),
	 x_lines.oke_contract_version_id_tbl(i),
	 x_lines.bid_number_tbl(i),
	 x_lines.bid_line_number_tbl(i),
	 x_lines.contract_id_tbl(i),
	 x_lines.category_id_tbl(i),
	 x_lines.item_desc_tbl(i),
	 x_lines.preferred_grade_tbl(i),
	 x_lines.transaction_reason_code_tbl(i),
	 x_lines.vendor_product_num_tbl(i),
	 x_lines.expiration_date_tbl(i),
	 x_lines.purchase_basis_tbl(i),--Bug#17788591
	 x_lines.matching_basis_tbl(i) --Bug#17788591
       );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of rows inserted in po_lines_gt', SQL%ROWCOUNT);
  END IF;

  d_position := 20;

  FORALL i IN INDICES OF l_processing_line_tbl
  INSERT INTO po_session_gt
    (key,
     index_num1, -- processing_line_index
     num1,       --interface_line_id
     num2,       --ship_to_organization_id
     num3,       --ship_to_location_id
     num4,       --requisition_line_id
     num5,       --po_header_id
     num6,       --line_num
     char1, 	 --supplier_ref_number
     char3,      --consigned_flag
     date1       --need_by_date
    )
  VALUES(l_key,
         l_processing_line_tbl(i),
         x_lines.intf_line_id_tbl(i),
	 x_lines.ship_to_org_id_tbl(i),
         x_lines.ship_to_loc_id_tbl(i),
	 x_lines.requisition_line_id_tbl(i),
   	 x_lines.hd_po_header_id_tbl(i),
    	 x_lines.line_num_tbl(i),
	 x_lines.supplier_ref_number_tbl(i),
         x_lines.consigned_flag_tbl(i),
	 x_lines.need_by_date_tbl(i)
	);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of rows inserted in po_session_gt', SQL%ROWCOUNT);
  END IF;

  d_position := 30;

  --Bug#17788591 : Validation is done when only when executed from
  --concurrent program
  IF PO_PDOI_PARAMS.g_request.calling_module = PO_PDOI_CONSTANTS.g_CALL_MOD_CONCURRENT_PRGM
  THEN
    -- Reject lines in the interface tables where same Line number
    -- is provided on multiple lines and the matching
    -- criteria conditions do not match
    reject_lines_on_line_num
    (
      p_key                 => l_key,
      x_lines               => x_lines,
      x_processing_row_tbl  => l_processing_line_tbl
     );
  END IF;

  d_position := 40;
  --Match lines in draft table
  match_lines_on_draft
  (
    p_key                 => l_key,
    x_lines               => x_lines,
    x_processing_row_tbl  => l_processing_line_tbl
  );

 IF PO_PDOI_PARAMS.g_request.document_type =
      PO_PDOI_CONSTANTS.g_DOC_TYPE_STANDARD  THEN

   d_position:= 50;
   --Match with the existing line id on header
   --for all lines having backing requisition
   match_lines_on_txn
   (
     x_lines    => x_lines,
     x_processing_row_tbl => l_processing_line_tbl
   );
 END IF ;

  d_position := 60;
  --Match lines in the interface tables
  match_lines_on_interface
  (
    p_key                 => l_key,
    x_lines               => x_lines,
    x_processing_row_tbl  => l_processing_line_tbl
  );


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
END match_lines_on_item_info;

-----------------------------------------------------------------------
--Start of Comments
--Name: copy_lines
--Function:
--  copy all the attribute values from one po_line to another
--Parameters:
--IN:
--  p_source_lines
--    source of copy action
--  p_source_index_tbl
--    the indexes of line to be copied
--IN OUT:
--  x_target_lines
--    record containing lines copied from source line
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE copy_lines
(
  p_source_lines     IN PO_PDOI_TYPES.lines_rec_type,
  p_source_index_tbl IN DBMS_SQL.NUMBER_TABLE,
  x_target_lines     IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'copy_lines';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_source_index NUMBER;
  l_target_index NUMBER :=0;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- bug5107324
  -- Refactored the code as PO_PDOI_TYPES.fill_all_lines_attr already does
  -- all the initialization work for all attributes in lines

  -- bug5129752
  -- Move the initialization up front

  -- initialize the tables
  PO_PDOI_TYPES.fill_all_lines_attr
  ( p_num_records => p_source_index_tbl.COUNT,
    x_lines       => x_target_lines
  );

  IF (p_source_index_tbl.COUNT = 0) THEN

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_module, 'no line is copied', p_source_index_tbl.COUNT);
    END IF;

    RETURN;
  END IF;

  l_source_index := p_source_index_tbl.FIRST;
  WHILE (l_source_index IS NOT NULL)
  LOOP
    -- increase target index
    l_target_index := l_target_index + 1;

    d_position := 20;

    -- copy line interface attributes
    x_target_lines.intf_line_id_tbl(l_target_index) := p_source_lines.intf_line_id_tbl(l_source_index);
    x_target_lines.intf_header_id_tbl(l_target_index) := p_source_lines.intf_header_id_tbl(l_source_index);
    x_target_lines.hd_po_header_id_tbl(l_target_index) := p_source_lines.hd_po_header_id_tbl(l_source_index);
    x_target_lines.po_line_id_tbl(l_target_index) := p_source_lines.po_line_id_tbl(l_source_index);
    x_target_lines.action_tbl(l_target_index) := p_source_lines.action_tbl(l_source_index);
    x_target_lines.document_num_tbl(l_target_index) := p_source_lines.document_num_tbl(l_source_index);
    x_target_lines.item_tbl(l_target_index) := p_source_lines.item_tbl(l_source_index);
    x_target_lines.vendor_product_num_tbl(l_target_index) := p_source_lines.vendor_product_num_tbl(l_source_index);
    x_target_lines.supplier_part_auxid_tbl(l_target_index) := p_source_lines.supplier_part_auxid_tbl(l_source_index);
    x_target_lines.item_id_tbl(l_target_index) := p_source_lines.item_id_tbl(l_source_index);
    x_target_lines.item_revision_tbl(l_target_index) := p_source_lines.item_revision_tbl(l_source_index);
    x_target_lines.job_business_group_name_tbl(l_target_index) := p_source_lines.job_business_group_name_tbl(l_source_index);
    x_target_lines.job_business_group_id_tbl(l_target_index) := p_source_lines.job_business_group_id_tbl(l_source_index);
    x_target_lines.job_name_tbl(l_target_index) := p_source_lines.job_name_tbl(l_source_index);
    x_target_lines.job_id_tbl(l_target_index) := p_source_lines.job_id_tbl(l_source_index);
    x_target_lines.category_tbl(l_target_index) := p_source_lines.category_tbl(l_source_index);
    x_target_lines.category_id_tbl(l_target_index) := p_source_lines.category_id_tbl(l_source_index);
    x_target_lines.ip_category_tbl(l_target_index) := p_source_lines.ip_category_tbl(l_source_index);
    x_target_lines.ip_category_id_tbl(l_target_index) := p_source_lines.ip_category_id_tbl(l_source_index);
    x_target_lines.uom_code_tbl(l_target_index) := p_source_lines.uom_code_tbl(l_source_index);
    x_target_lines.unit_of_measure_tbl(l_target_index) := p_source_lines.unit_of_measure_tbl(l_source_index);
    x_target_lines.line_type_tbl(l_target_index) := p_source_lines.line_type_tbl(l_source_index);
    x_target_lines.line_type_id_tbl(l_target_index) := p_source_lines.line_type_id_tbl(l_source_index);
    x_target_lines.un_number_tbl(l_target_index) := p_source_lines.un_number_tbl(l_source_index);
    x_target_lines.un_number_id_tbl(l_target_index) := p_source_lines.un_number_id_tbl(l_source_index);
    x_target_lines.hazard_class_tbl(l_target_index) := p_source_lines.hazard_class_tbl(l_source_index);
    x_target_lines.hazard_class_id_tbl(l_target_index) := p_source_lines.hazard_class_id_tbl(l_source_index);
    x_target_lines.template_name_tbl(l_target_index) := p_source_lines.template_name_tbl(l_source_index);
    x_target_lines.template_id_tbl(l_target_index) := p_source_lines.template_id_tbl(l_source_index);
    x_target_lines.item_desc_tbl(l_target_index) := p_source_lines.item_desc_tbl(l_source_index);
    x_target_lines.unit_price_tbl(l_target_index) := p_source_lines.unit_price_tbl(l_source_index);
    x_target_lines.base_unit_price_tbl(l_target_index) := p_source_lines.base_unit_price_tbl(l_source_index);
    x_target_lines.from_header_id_tbl(l_target_index) := p_source_lines.from_header_id_tbl(l_source_index);
    x_target_lines.from_line_id_tbl(l_target_index) := p_source_lines.from_line_id_tbl(l_source_index);
    x_target_lines.list_price_per_unit_tbl(l_target_index) := p_source_lines.list_price_per_unit_tbl(l_source_index);
    x_target_lines.market_price_tbl(l_target_index) := p_source_lines.market_price_tbl(l_source_index);
    x_target_lines.capital_expense_flag_tbl(l_target_index) := p_source_lines.capital_expense_flag_tbl(l_source_index);
    x_target_lines.min_release_amount_tbl(l_target_index) := p_source_lines.min_release_amount_tbl(l_source_index);
    x_target_lines.allow_price_override_flag_tbl(l_target_index) := p_source_lines.allow_price_override_flag_tbl(l_source_index);
    x_target_lines.price_type_tbl(l_target_index) := p_source_lines.price_type_tbl(l_source_index);
    x_target_lines.price_break_lookup_code_tbl(l_target_index) := p_source_lines.price_break_lookup_code_tbl(l_source_index);
    x_target_lines.closed_code_tbl(l_target_index) := p_source_lines.closed_code_tbl(l_source_index);
    x_target_lines.quantity_tbl(l_target_index) := p_source_lines.quantity_tbl(l_source_index);
    x_target_lines.line_num_tbl(l_target_index) := p_source_lines.line_num_tbl(l_source_index);
    x_target_lines.shipment_num_tbl(l_target_index) := p_source_lines.shipment_num_tbl(l_source_index);
    x_target_lines.price_chg_accept_flag_tbl(l_target_index) := p_source_lines.price_chg_accept_flag_tbl(l_source_index);
    x_target_lines.effective_date_tbl(l_target_index) := p_source_lines.effective_date_tbl(l_source_index);
    x_target_lines.expiration_date_tbl(l_target_index) := p_source_lines.expiration_date_tbl(l_source_index);
    x_target_lines.attribute14_tbl(l_target_index) := p_source_lines.attribute14_tbl(l_source_index);
    x_target_lines.price_update_tolerance_tbl(l_target_index) := p_source_lines.price_update_tolerance_tbl(l_source_index);
    x_target_lines.error_flag_tbl(l_target_index) := p_source_lines.error_flag_tbl(l_source_index);
    x_target_lines.need_to_reject_flag_tbl(l_target_index) := p_source_lines.need_to_reject_flag_tbl(l_source_index);
    x_target_lines.line_loc_populated_flag_tbl(l_target_index) := p_source_lines.line_loc_populated_flag_tbl(l_source_index);
    --<<PDOI Enhancement Bug#17063664 START>>--
    x_target_lines.requisition_line_id_tbl(l_target_index)     := p_source_lines.requisition_line_id_tbl(l_source_index);
    x_target_lines.org_id_tbl(l_target_index)                  := p_source_lines.org_id_tbl(l_source_index);
    x_target_lines.oke_contract_header_id_tbl(l_target_index)  := p_source_lines.oke_contract_header_id_tbl(l_source_index);
    x_target_lines.oke_contract_version_id_tbl(l_target_index) := p_source_lines.oke_contract_version_id_tbl(l_source_index);
    x_target_lines.bid_number_tbl(l_target_index)              := p_source_lines.bid_number_tbl(l_source_index);
    x_target_lines.bid_line_number_tbl(l_target_index)         := p_source_lines.bid_line_number_tbl(l_source_index);
    x_target_lines.auction_header_id_tbl(l_target_index)       := p_source_lines.auction_header_id_tbl(l_source_index);
    x_target_lines.auction_line_number_tbl(l_target_index)     := p_source_lines.auction_line_number_tbl(l_source_index);
    x_target_lines.auction_display_number_tbl(l_target_index)  := p_source_lines.auction_display_number_tbl(l_source_index);
    x_target_lines.transaction_reason_code_tbl(l_target_index) := p_source_lines.transaction_reason_code_tbl(l_source_index);
    x_target_lines.note_to_vendor_tbl(l_target_index)          := p_source_lines.note_to_vendor_tbl(l_source_index);
    x_target_lines.supplier_ref_number_tbl(l_target_index)     := p_source_lines.supplier_ref_number_tbl(l_source_index);
    x_target_lines.orig_from_req_flag_tbl(l_target_index)      := p_source_lines.orig_from_req_flag_tbl(l_source_index);
    x_target_lines.consigned_flag_tbl(l_target_index)          := p_source_lines.consigned_flag_tbl(l_source_index);
    x_target_lines.need_by_date_tbl(l_target_index)            := p_source_lines.need_by_date_tbl(l_source_index);
    x_target_lines.ship_to_loc_id_tbl(l_target_index)          := p_source_lines.ship_to_loc_id_tbl(l_source_index);
    x_target_lines.ship_to_org_id_tbl(l_target_index)          := p_source_lines.ship_to_org_id_tbl(l_source_index);
    x_target_lines.ship_to_org_code_tbl(l_target_index)        := p_source_lines.ship_to_org_code_tbl(l_source_index);
    x_target_lines.ship_to_loc_tbl(l_target_index)             := p_source_lines.ship_to_loc_tbl(l_source_index);
    x_target_lines.taxable_flag_tbl(l_target_index)            := p_source_lines.taxable_flag_tbl(l_source_index);
     --<<PDOI Enhancement Bug#17063664 END>>--

      -- << PDOI for Complex PO Project: Start >>
    x_target_lines.retainage_rate_tbl(l_target_index) := p_source_lines.retainage_rate_tbl(l_source_index);
    x_target_lines.max_retainage_amount_tbl(l_target_index) := p_source_lines.max_retainage_amount_tbl(l_source_index);
    x_target_lines.progress_payment_rate_tbl(l_target_index) := p_source_lines.progress_payment_rate_tbl(l_source_index);
    x_target_lines.recoupment_rate_tbl(l_target_index) := p_source_lines.recoupment_rate_tbl(l_source_index);
    x_target_lines.advance_amount_tbl(l_target_index) := p_source_lines.advance_amount_tbl(l_source_index);
    -- << PDOI for Complex PO Project: End >>
    x_target_lines.negotiated_flag_tbl(l_target_index) := p_source_lines.negotiated_flag_tbl(l_source_index);
    x_target_lines.amount_tbl(l_target_index) := p_source_lines.amount_tbl(l_source_index);
    x_target_lines.contractor_last_name_tbl(l_target_index) := p_source_lines.contractor_last_name_tbl(l_source_index);
    x_target_lines.contractor_first_name_tbl(l_target_index) := p_source_lines.contractor_first_name_tbl(l_source_index);
    x_target_lines.over_tolerance_err_flag_tbl(l_target_index) := p_source_lines.over_tolerance_err_flag_tbl(l_source_index);
    x_target_lines.not_to_exceed_price_tbl(l_target_index) := p_source_lines.not_to_exceed_price_tbl(l_source_index);
    x_target_lines.po_release_id_tbl(l_target_index) := p_source_lines.po_release_id_tbl(l_source_index);
    x_target_lines.release_num_tbl(l_target_index) := p_source_lines.release_num_tbl(l_source_index);
    x_target_lines.source_shipment_id_tbl(l_target_index) := p_source_lines.source_shipment_id_tbl(l_source_index);
    x_target_lines.contract_num_tbl(l_target_index) := p_source_lines.contract_num_tbl(l_source_index);
    x_target_lines.contract_id_tbl(l_target_index) := p_source_lines.contract_id_tbl(l_source_index);
    x_target_lines.type_1099_tbl(l_target_index) := p_source_lines.type_1099_tbl(l_source_index);
    x_target_lines.closed_by_tbl(l_target_index) := p_source_lines.closed_by_tbl(l_source_index);
    x_target_lines.closed_date_tbl(l_target_index) := p_source_lines.closed_date_tbl(l_source_index);
    x_target_lines.committed_amount_tbl(l_target_index) := p_source_lines.committed_amount_tbl(l_source_index);
    x_target_lines.qty_rcv_exception_code_tbl(l_target_index) := p_source_lines.qty_rcv_exception_code_tbl(l_source_index);
    x_target_lines.weight_uom_code_tbl(l_target_index) := p_source_lines.weight_uom_code_tbl(l_source_index);
    x_target_lines.volume_uom_code_tbl(l_target_index) := p_source_lines.volume_uom_code_tbl(l_source_index);
    x_target_lines.secondary_unit_of_meas_tbl(l_target_index) := p_source_lines.secondary_unit_of_meas_tbl(l_source_index);
    x_target_lines.secondary_quantity_tbl(l_target_index) := p_source_lines.secondary_quantity_tbl(l_source_index);
    x_target_lines.preferred_grade_tbl(l_target_index) := p_source_lines.preferred_grade_tbl(l_source_index);
    x_target_lines.process_code_tbl(l_target_index) := p_source_lines.process_code_tbl(l_source_index);
    x_target_lines.parent_interface_line_id_tbl(l_target_index) := p_source_lines.parent_interface_line_id_tbl(l_source_index); -- bug5149827

    d_position := 30;

    -- copy standard who columns
    x_target_lines.last_updated_by_tbl(l_target_index) := p_source_lines.last_updated_by_tbl(l_source_index);
    x_target_lines.last_update_date_tbl(l_target_index) := p_source_lines.last_update_date_tbl(l_source_index);
    x_target_lines.last_update_login_tbl(l_target_index) := p_source_lines.last_update_login_tbl(l_source_index);
    x_target_lines.creation_date_tbl(l_target_index) := p_source_lines.creation_date_tbl(l_source_index);
    x_target_lines.created_by_tbl(l_target_index) := p_source_lines.created_by_tbl(l_source_index);
    x_target_lines.request_id_tbl(l_target_index) := p_source_lines.request_id_tbl(l_source_index);
    x_target_lines.program_application_id_tbl(l_target_index) := p_source_lines.program_application_id_tbl(l_source_index);
    x_target_lines.program_id_tbl(l_target_index) := p_source_lines.program_id_tbl(l_source_index);
    x_target_lines.program_update_date_tbl(l_target_index) := p_source_lines.program_update_date_tbl(l_source_index);

    d_position := 40;

    -- copy attributes from header
    x_target_lines.draft_id_tbl(l_target_index) := p_source_lines.draft_id_tbl(l_source_index);
    x_target_lines.hd_action_tbl(l_target_index) := p_source_lines.hd_action_tbl(l_source_index);
    x_target_lines.hd_po_header_id_tbl(l_target_index) := p_source_lines.hd_po_header_id_tbl(l_source_index);
    x_target_lines.hd_vendor_id_tbl(l_target_index) := p_source_lines.hd_vendor_id_tbl(l_source_index);
    --PDOI Enhancement Bug#17063664
    x_target_lines.hd_vendor_site_id_tbl(l_target_index) := p_source_lines.hd_vendor_site_id_tbl(l_source_index);
    x_target_lines.hd_min_release_amount_tbl(l_target_index) := p_source_lines.hd_min_release_amount_tbl(l_source_index);
    x_target_lines.hd_start_date_tbl(l_target_index) := p_source_lines.hd_start_date_tbl(l_source_index);
    x_target_lines.hd_end_date_tbl(l_target_index) := p_source_lines.hd_end_date_tbl(l_source_index);
    x_target_lines.hd_global_agreement_flag_tbl(l_target_index) := p_source_lines.hd_global_agreement_flag_tbl(l_source_index);
    x_target_lines.hd_currency_code_tbl(l_target_index) := p_source_lines.hd_currency_code_tbl(l_source_index);
    x_target_lines.hd_created_language_tbl(l_target_index) := p_source_lines.hd_created_language_tbl(l_source_index);
    x_target_lines.hd_style_id_tbl(l_target_index) := p_source_lines.hd_style_id_tbl(l_source_index);
    x_target_lines.hd_rate_type_tbl(l_target_index) := p_source_lines.hd_rate_type_tbl(l_source_index);
    x_target_lines.hd_rate_tbl(l_target_index) := p_source_lines.hd_rate_tbl(l_source_index);
    x_target_lines.hd_rate_date_tbl(l_target_index) := p_source_lines.hd_rate_date_tbl(l_source_index); --<PDOI Enhancement Bug#17063664>

    -- copy processing attributes
    x_target_lines.create_line_loc_tbl(l_target_index) := p_source_lines.create_line_loc_tbl(l_source_index);
    x_target_lines.order_type_lookup_code_tbl(l_target_index) := p_source_lines.order_type_lookup_code_tbl(l_source_index);
    x_target_lines.purchase_basis_tbl(l_target_index) := p_source_lines.purchase_basis_tbl(l_source_index);
    x_target_lines.matching_basis_tbl(l_target_index) := p_source_lines.matching_basis_tbl(l_source_index);
    x_target_lines.unordered_flag_tbl(l_target_index) := p_source_lines.unordered_flag_tbl(l_source_index);
    x_target_lines.cancel_flag_tbl(l_target_index) := p_source_lines.cancel_flag_tbl(l_source_index);
    x_target_lines.quantity_committed_tbl(l_target_index) := p_source_lines.quantity_committed_tbl(l_source_index);
    x_target_lines.tax_attribute_update_code_tbl(l_target_index) := p_source_lines.tax_attribute_update_code_tbl(l_source_index);
    x_target_lines.allow_desc_update_flag_tbl(l_target_index) := p_source_lines.allow_desc_update_flag_tbl(l_source_index); -- bug5107324
	x_target_lines.txn_flow_header_id_tbl(l_target_index) := p_source_lines.txn_flow_header_id_tbl(l_source_index);--bug 18438881

     x_target_lines.qty_rcv_tolerance_tbl(l_target_index) := p_source_lines.qty_rcv_tolerance_tbl(l_source_index);--bug 18891225

    -- get next index
    l_source_index := p_source_index_tbl.NEXT(l_source_index);
  END LOOP;

  d_position := 50;

  -- rebuild index table
  FOR i IN 1..x_target_lines.rec_count
  LOOP
    x_target_lines.intf_id_index_tbl(x_target_lines.intf_line_id_tbl(i)) := i;
  END LOOP;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'number of copied lines', l_target_index);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END copy_lines;

-----------------------------------------------------------------------
--Start of Comments
--Name: uniqueness_check_on_desc
--Function:
--  check item uniqueness based on description + category name
--Parameters:
--IN:
--  p_key
--    key value used to identify rows in temp table
--  p_group_num
--    the new group number that is going to be assigned to rows
--    whose action can be decided in this procedure
--IN OUT:
--  x_processing_row_tbl
--    index table of rows that are going to be processed
--  x_lines
--    record of line information read within the batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE uniqueness_check_on_desc
(
  p_key                 IN po_session_gt.key%TYPE,
  p_group_num           IN NUMBER,
  x_processing_row_tbl  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'uniqueness_check_on_desc';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold matching result read from po_session_gt table
  l_index_tbl           PO_TBL_NUMBER;
  l_po_line_id_tbl      PO_TBL_NUMBER;
  l_line_num_tbl        PO_TBL_NUMBER;

  l_index               NUMBER;
  l_data_key            po_session_gt.key%TYPE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- check matchings on draft table
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
    SELECT
      p_key,
      x_processing_row_tbl(i),
      draft_lines.po_line_id,
      draft_lines.line_num
    FROM  po_lines_draft_all draft_lines
    WHERE draft_lines.po_header_id = x_lines.hd_po_header_id_tbl(i)
    AND   draft_lines.draft_id = x_lines.draft_id_tbl(i)
    AND   NVL(draft_lines.expiration_date, TRUNC(sysdate)) >= TRUNC(sysdate)
    AND   draft_lines.item_description = x_lines.item_desc_tbl(i)
    AND   (x_lines.category_tbl(i) IS NULL OR
           EXISTS ( SELECT 1
                    FROM   mtl_categories_kfv mck
                    WHERE  mck.concatenated_segments = x_lines.category_tbl(i)
                    AND    mck.category_id = draft_lines.category_id));

  d_position := 10;

  -- check matching on txn table
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
    SELECT
      p_key,
      x_processing_row_tbl(i),
      txn_lines.po_line_id,
      txn_lines.line_num
    FROM  po_lines txn_lines
    WHERE txn_lines.po_header_id = x_lines.hd_po_header_id_tbl(i)
    AND   NOT EXISTS ( SELECT 1
                       FROM   po_lines_draft_all draft_lines
                       WHERE  draft_lines.po_line_id = txn_lines.po_line_id
                       AND    draft_lines.draft_id = x_lines.draft_id_tbl(i))
    AND   txn_lines.item_description = x_lines.item_desc_tbl(i)
    AND   (x_lines.category_tbl(i) IS NULL OR
           EXISTS ( SELECT 1
                    FROM   mtl_categories_kfv mck
                    WHERE  mck.concatenated_segments = x_lines.category_tbl(i)
                    AND    mck.category_id = txn_lines.category_id))
    AND   NVL(txn_lines.expiration_date, TRUNC(sysdate)) >= TRUNC(sysdate)
    AND   NVL(txn_lines.closed_code, 'OPEN') <> 'FINALLY CLOSED'
    AND   NVL(txn_lines.cancel_flag, 'N') <> 'Y';

  d_position := 20;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, num2, num3 BULK COLLECT INTO
    l_index_tbl, l_po_line_id_tbl, l_line_num_tbl;

  -- set po_line_id, and line_num from matching record
  -- If there is only one matching -- OK
  -- If there are multiple matching records, update the line that has same
  -- line_num as in interface table; otherwise, update line with maximum
  -- line_num
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (x_lines.po_line_id_tbl(l_index) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'first match index', l_index);
        PO_LOG.stmt(d_module, d_position, 'po line id', l_po_line_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'line num', l_line_num_tbl(i));
      END IF;

      -- first match found
      x_lines.origin_line_num_tbl(l_index) := x_lines.line_num_tbl(l_index);
      x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_UPDATE;
      x_lines.group_num_tbl(l_index) := p_group_num;
      x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
      x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
      x_processing_row_tbl.DELETE(l_index);
      IF (l_line_num_tbl(i) = x_lines.origin_line_num_tbl(l_index)) THEN
        x_lines.match_line_found_tbl(l_index) := FND_API.g_TRUE;
      END IF;
    ELSE
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'multi match index', l_index);
        PO_LOG.stmt(d_module, d_position, 'po line id', l_po_line_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'line num', l_line_num_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'original line num',
                    x_lines.origin_line_num_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'match line found',
                    x_lines.match_line_found_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'current line num',
                    x_lines.line_num_tbl(l_index));
      END IF;

      -- multiple matches found
      IF (l_line_num_tbl(i) = x_lines.origin_line_num_tbl(l_index)) THEN
        -- record matching line_num is found
        x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
        x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
        x_lines.match_line_found_tbl(l_index) := FND_API.g_TRUE;
      ELSIF (x_lines.match_line_found_tbl(l_index) = FND_API.g_TRUE) THEN
        -- need to do nothing, record with matching line num is found before
        NULL;
      ELSIF (x_lines.line_num_tbl(l_index) < l_line_num_tbl(i)) THEN
        -- try to update line with maximum line num if exact match can not be found
        x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
        x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
      ELSE
        -- do nothing since the new coming record has smaller line num
        -- than current matching record
        NULL;
      END IF;
    END IF;
  END LOOP;

  d_position := 30;

  -- search within the batch
  -- find out all lines that cannot find a match
  -- and set their action to ADD
  l_data_key := PO_CORE_S.get_session_gt_nextval;
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      char1,
      char2
    )
  SELECT
    l_data_key,
    x_lines.intf_line_id_tbl(i),       -- num1
    x_lines.hd_po_header_id_tbl(i),    -- num2
    x_lines.item_desc_tbl(i),          -- char1
    x_lines.category_tbl(i)            -- char2
  FROM DUAL;

  d_position := 40;

  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1
    )
    SELECT p_key,
           x_processing_row_tbl(i)
    FROM   DUAL
    WHERE  NOT EXISTS(
           SELECT 1
           FROM   po_session_gt gt
           WHERE  key = l_data_key
           AND    gt.num1 < x_lines.intf_line_id_tbl(i)
           AND    gt.num2 = x_lines.hd_po_header_id_tbl(i)
           AND    gt.char1 = x_lines.item_desc_tbl(i)
           AND    NVL(x_lines.category_tbl(i), NVL(gt.char2, -99))=
                    NVL(gt.char2, -99));

  d_position := 50;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  -- bug5093465
  -- For the records in l_index_tbl, assign action 'ADD'
  set_action_add
  ( p_key                    => p_key,
    p_group_num              => p_group_num,
    p_target_lines_index_tbl => l_index_tbl,
    p_check_line_num_assign  => FND_API.G_TRUE,
    x_processing_row_tbl     => x_processing_row_tbl,
    x_lines                  => x_lines
  );

  d_position := 60;

  -- clean up po_session_gt
  PO_PDOI_UTL.remove_session_gt_records
  ( p_key => l_data_key
  );

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
END uniqueness_check_on_desc;

-----------------------------------------------------------------------
--Start of Comments
--Name: uniqueness_check_on_item
--Function:
--  check item uniqueness based on item + revision + vendor_product_num
--  + supplier_part_aux_id
--Parameters:
--IN:
--  p_key
--    key value used to identify rows in temp table
--  p_group_num
--    the new group number that is going to be assigned to rows
--    whose action can be decided in this procedure
--IN OUT:
--  x_processing_row_tbl
--    index table of rows that are going to be processed
--  x_lines
--    record of line information read within the batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE uniqueness_check_on_item
(
  p_key                 IN po_session_gt.key%TYPE,
  p_group_num           IN NUMBER,
  x_processing_row_tbl  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'uniqueness_check_on_item';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_def_master_org_id   NUMBER;

  -- variables to hold matching result read from po_session_gt table
  l_index_tbl           PO_TBL_NUMBER;
  l_po_line_id_tbl      PO_TBL_NUMBER;
  l_line_num_tbl        PO_TBL_NUMBER;

  l_index               NUMBER;
  l_data_key            po_session_gt.key%TYPE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- get default master org id
  l_def_master_org_id := PO_PDOI_PARAMS.g_sys.master_inv_org_id;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_def_master_org_id',
                l_def_master_org_id);
    PO_LOG.stmt(d_module, d_position, 'item_tbl', x_lines.item_tbl);
    PO_LOG.stmt(d_module, d_position, 'hd_po_header_id_tbl',
                x_lines.hd_po_header_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'draft_id_tbl', x_lines.draft_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'item_revision_tbl',
                x_lines.item_revision_tbl);
    PO_LOG.stmt(d_module, d_position, 'vendor_product_num_tbl',
                x_lines.vendor_product_num_tbl);
    PO_LOG.stmt(d_module, d_position, 'supplier_part_auxid_tbl',
                x_lines.supplier_part_auxid_tbl);
  END IF;

  -- check matching on draft table
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
    SELECT
      p_key,
      x_processing_row_tbl(i),
      draft_lines.po_line_id,
      draft_lines.line_num
    FROM  po_lines_draft_all draft_lines
    WHERE x_lines.item_tbl(i) IS NOT NULL
    AND   draft_lines.po_header_id = x_lines.hd_po_header_id_tbl(i)
    AND   draft_lines.draft_id = x_lines.draft_id_tbl(i)
    AND   NVL(draft_lines.expiration_date, TRUNC(sysdate)) >= TRUNC(sysdate)
    AND   EXISTS (SELECT 1
                  FROM   mtl_system_items items
                  WHERE  items.inventory_item_id = draft_lines.item_id
                  AND    items.segment1 = x_lines.item_tbl(i)
                  AND    items.organization_id =
                           NVL(l_def_master_org_id, items.organization_id))
    AND    NVL(x_lines.item_revision_tbl(i), NVL(draft_lines.item_revision, -99)) =
             NVL(draft_lines.item_revision, -99)
    AND    NVL(x_lines.vendor_product_num_tbl(i), NVL(draft_lines.vendor_product_num, -99)) =
             NVL(draft_lines.vendor_product_num, -99)
    AND    NVL(x_lines.supplier_part_auxid_tbl(i),
               NVL(draft_lines.supplier_part_auxid, FND_API.g_NULL_CHAR))=
           NVL(draft_lines.supplier_part_auxid, FND_API.g_NULL_CHAR);

  d_position := 10;

  -- check matching on txn table
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
    SELECT
      p_key,
      x_processing_row_tbl(i),
      txn_lines.po_line_id,
      txn_lines.line_num
    FROM  po_lines txn_lines
    WHERE x_lines.item_tbl(i) IS NOT NULL
    AND   txn_lines.po_header_id = x_lines.hd_po_header_id_tbl(i)
    AND   NOT EXISTS ( SELECT 1
                       FROM   po_lines_draft_all draft_lines
                       WHERE  draft_lines.po_line_id = txn_lines.po_line_id
                       AND    draft_lines.draft_id = x_lines.draft_id_tbl(i))
    AND   EXISTS (SELECT 1
                  FROM   mtl_system_items items
                  WHERE  items.inventory_item_id = txn_lines.item_id
                  AND    items.segment1 = x_lines.item_tbl(i)
                  AND    items.organization_id =
                           NVL(l_def_master_org_id, items.organization_id))
    AND   NVL(x_lines.item_revision_tbl(i), NVL(txn_lines.item_revision, -99)) =
            NVL(txn_lines.item_revision, -99)
    AND   NVL(x_lines.vendor_product_num_tbl(i), NVL(txn_lines.vendor_product_num, -99)) =
            NVL(txn_lines.vendor_product_num, -99)
    AND   NVL(x_lines.supplier_part_auxid_tbl(i),
              NVL(txn_lines.supplier_part_auxid, FND_API.g_NULL_CHAR)) =
          NVL(txn_lines.supplier_part_auxid, FND_API.g_NULL_CHAR)
    AND   NVL(txn_lines.expiration_date, TRUNC(sysdate)) >= TRUNC(sysdate)
    AND   NVL(txn_lines.closed_code, 'OPEN') <> 'FINALLY CLOSED'
    AND   NVL(txn_lines.cancel_flag, 'N') <> 'Y';

  d_position := 20;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, num2, num3 BULK COLLECT INTO
    l_index_tbl, l_po_line_id_tbl, l_line_num_tbl;

  -- set po_line_id, and line_num from matching record
  -- If there is only one matching -- OK
  -- If there are multiple matching records, update the line that has same
  -- line_num as in interface table; otherwise, update line with maximum
  -- line_num
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (x_lines.po_line_id_tbl(l_index) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'first match index', l_index);
        PO_LOG.stmt(d_module, d_position, 'po line id', l_po_line_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'line num', l_line_num_tbl(i));
      END IF;

      -- first match found
      x_lines.origin_line_num_tbl(l_index) := x_lines.line_num_tbl(l_index);
      x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_UPDATE;
      x_lines.group_num_tbl(l_index) := p_group_num;
      x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
      x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
      x_processing_row_tbl.DELETE(l_index);
      IF (l_line_num_tbl(i) = x_lines.origin_line_num_tbl(l_index)) THEN
        x_lines.match_line_found_tbl(l_index) := FND_API.g_TRUE;
      END IF;
    ELSE
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'multi match index', l_index);
        PO_LOG.stmt(d_module, d_position, 'po line id', l_po_line_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'line num', l_line_num_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'original line num',
                    x_lines.origin_line_num_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'match line found',
                    x_lines.match_line_found_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'current line num',
                    x_lines.line_num_tbl(l_index));
      END IF;

      -- multiple matches found
      IF (l_line_num_tbl(i) = x_lines.origin_line_num_tbl(l_index)) THEN
        -- record matching line_num is found
        x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
        x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
        x_lines.match_line_found_tbl(l_index) := FND_API.g_TRUE;
      ELSIF (x_lines.match_line_found_tbl(l_index) = FND_API.g_TRUE) THEN
        -- need to do nothing, record with matching line num is found before
        NULL;
      ELSIF (x_lines.line_num_tbl(l_index) < l_line_num_tbl(i)) THEN
        -- try to update line with maximum line num if exact match can not be found
        x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
        x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
      ELSE
        -- do nothing since the new coming record has smaller line num
        -- than current matching record
        NULL;
      END IF;
    END IF;
  END LOOP;

  d_position := 30;

  -- search within the batch
  -- find out all lines that cannot find a match
  -- and set their action to ADD
  l_data_key := PO_CORE_S.get_session_gt_nextval;
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      char1,
      char2,
      char3,
      char4
    )
  SELECT
    l_data_key,
    x_lines.intf_line_id_tbl(i),       -- num1
    x_lines.hd_po_header_id_tbl(i),    -- num2
    x_lines.item_tbl(i),               -- char1
    x_lines.item_revision_tbl(i),      -- char2
    x_lines.vendor_product_num_tbl(i), -- char3
    x_lines.supplier_part_auxid_tbl(i) -- char4
  FROM DUAL;

  d_position := 40;

  -- bug4930510
  -- Take away the table mtl_system_items from the query since it's
  -- never used.
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1
    )
    SELECT p_key,
           x_processing_row_tbl(i)
    FROM   DUAL
    WHERE  x_lines.item_tbl(i) IS NOT NULL
    AND    NOT EXISTS(
           SELECT 1
           FROM   po_session_gt gt
           WHERE  key = l_data_key
           AND    gt.num1 < x_lines.intf_line_id_tbl(i)
           AND    gt.num2 = x_lines.hd_po_header_id_tbl(i)
           AND    gt.char1 = x_lines.item_tbl(i)
           AND    NVL(x_lines.item_revision_tbl(i), NVL(gt.char2, -99)) =
                    NVL(gt.char2, -99)
           AND    NVL(x_lines.vendor_product_num_tbl(i), NVL(gt.char3, -99)) =
                    NVL(gt.char3, -99)
           AND    NVL(x_lines.supplier_part_auxid_tbl(i),
                      NVL(gt.char4, FND_API.g_NULL_CHAR))=
                  NVL(gt.char4, FND_API.g_NULL_CHAR));

  d_position := 50;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  -- bug5093465
  -- For the records in l_index_tbl, assign action 'ADD'
  set_action_add
  ( p_key                    => p_key,
    p_group_num              => p_group_num,
    p_target_lines_index_tbl => l_index_tbl,
    p_check_line_num_assign  => FND_API.G_TRUE,
    x_processing_row_tbl     => x_processing_row_tbl,
    x_lines                  => x_lines
  );

  d_position := 60;

  -- clean up po_session_gt
  PO_PDOI_UTL.remove_session_gt_records
  ( p_key => l_data_key
  );

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
END uniqueness_check_on_item;

-----------------------------------------------------------------------
--Start of Comments
--Name: uniqueness_check_on_vpn
--Function:
--  check item uniqueness based on vendor_product_num + aux id
--Parameters:
--IN:
--  p_key
--    key value used to identify rows in temp table
--  p_group_num
--    the new group number that is going to be assigned to rows
--    whose action can be decided in this procedure
--IN OUT:
--  x_processing_row_tbl
--    index table of rows that are going to be processed
--  x_lines
--    record of line information read within the batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE uniqueness_check_on_vpn
(
  p_key                 IN po_session_gt.key%TYPE,
  p_group_num           IN NUMBER,
  x_processing_row_tbl  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'uniqueness_check_on_vpn';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold matching result read from po_session_gt table
  l_index_tbl           PO_TBL_NUMBER;
  l_po_line_id_tbl      PO_TBL_NUMBER;
  l_line_num_tbl        PO_TBL_NUMBER;

  l_index               NUMBER;
  l_data_key            po_session_gt.key%TYPE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- check matchings on draft table
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
    SELECT
      p_key,
      x_processing_row_tbl(i),
      draft_lines.po_line_id,
      draft_lines.line_num
    FROM  po_lines_draft_all draft_lines
    WHERE x_lines.item_tbl(i) IS NULL
    AND   x_lines.vendor_product_num_tbl(i) IS NOT NULL
    AND   draft_lines.po_header_id = x_lines.hd_po_header_id_tbl(i)
    AND   draft_lines.draft_id = x_lines.draft_id_tbl(i)
    AND   NVL(draft_lines.expiration_date, TRUNC(sysdate)) >= TRUNC(sysdate)
    AND   draft_lines.vendor_product_num = x_lines.vendor_product_num_tbl(i)
    AND   NVL(x_lines.supplier_part_auxid_tbl(i),
              NVL(draft_lines.supplier_part_auxid, FND_API.g_NULL_CHAR))=
          NVL(draft_lines.supplier_part_auxid, FND_API.g_NULL_CHAR);

  d_position := 10;

  -- check matching on txn table
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
    SELECT
      p_key,
      x_processing_row_tbl(i),
      txn_lines.po_line_id,
      txn_lines.line_num
    FROM  po_lines txn_lines
    WHERE x_lines.item_tbl(i) IS NULL
    AND   x_lines.vendor_product_num_tbl(i) IS NOT NULL
    AND   txn_lines.po_header_id = x_lines.hd_po_header_id_tbl(i)
    AND   NOT EXISTS ( SELECT 1
                       FROM   po_lines_draft_all draft_lines
                       WHERE  draft_lines.po_line_id = txn_lines.po_line_id
                       AND    draft_lines.draft_id = x_lines.draft_id_tbl(i))
    AND   txn_lines.vendor_product_num = x_lines.vendor_product_num_tbl(i)
    AND   NVL(x_lines.supplier_part_auxid_tbl(i),
              NVL(txn_lines.supplier_part_auxid, FND_API.g_NULL_CHAR))=
          NVL(txn_lines.supplier_part_auxid, FND_API.g_NULL_CHAR)
    AND   NVL(txn_lines.expiration_date, TRUNC(sysdate)) >= TRUNC(sysdate)
    AND   NVL(txn_lines.closed_code, 'OPEN') <> 'FINALLY CLOSED'
    AND   NVL(txn_lines.cancel_flag, 'N') <> 'Y';

  d_position := 20;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, num2, num3 BULK COLLECT INTO
    l_index_tbl, l_po_line_id_tbl, l_line_num_tbl;

  -- set po_line_id, and line_num from matching record
  -- If there is only one matching -- OK
  -- If there are multiple matching records, update the line that has same
  -- line_num as in interface table; otherwise, update line with maximum
  -- line_num
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (x_lines.po_line_id_tbl(l_index) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'first match index', l_index);
        PO_LOG.stmt(d_module, d_position, 'po line id', l_po_line_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'line num', l_line_num_tbl(i));
      END IF;

      -- first match found
      x_lines.origin_line_num_tbl(l_index) := x_lines.line_num_tbl(l_index);
      x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_UPDATE;
      x_lines.group_num_tbl(l_index) := p_group_num;
      x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
      x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
      x_processing_row_tbl.DELETE(l_index);
      IF (l_line_num_tbl(i) = x_lines.origin_line_num_tbl(l_index)) THEN
        x_lines.match_line_found_tbl(l_index) := FND_API.g_TRUE;
      END IF;
    ELSE
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'multi match index', l_index);
        PO_LOG.stmt(d_module, d_position, 'po line id', l_po_line_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'line num', l_line_num_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'original line num',
                    x_lines.origin_line_num_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'match line found',
                    x_lines.match_line_found_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'current line num',
                    x_lines.line_num_tbl(l_index));
      END IF;

      -- multiple matches found
      IF (l_line_num_tbl(i) = x_lines.origin_line_num_tbl(l_index)) THEN
        -- record matching line_num is found
        x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
        x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
        x_lines.match_line_found_tbl(l_index) := FND_API.g_TRUE;
      ELSIF (x_lines.match_line_found_tbl(l_index) = FND_API.g_TRUE) THEN
        -- need to do nothing, record with matching line num is found before
        NULL;
      ELSIF (x_lines.line_num_tbl(l_index) < l_line_num_tbl(i)) THEN
        -- try to update line with maximum line num if exact match can not be found
        x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
        x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
      ELSE
        -- do nothing since the new coming record has smaller line num
        -- than current matching record
        NULL;
      END IF;
    END IF;
  END LOOP;

  d_position := 30;

  -- search within the batch
  -- find out all lines that cannot find a match
  -- and set their action to ADD
  l_data_key := PO_CORE_S.get_session_gt_nextval;
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      char1,
      char2
    )
  SELECT
    l_data_key,
    x_lines.intf_line_id_tbl(i),       -- num1
    x_lines.hd_po_header_id_tbl(i),    -- num2
    x_lines.vendor_product_num_tbl(i), -- char1
    x_lines.supplier_part_auxid_tbl(i) -- char2
  FROM DUAL;

  d_position := 40;

  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1
    )
    SELECT p_key,
           x_processing_row_tbl(i)
    FROM   DUAL
    WHERE  x_lines.item_tbl(i) IS NULL
    AND    x_lines.vendor_product_num_tbl(i) IS NOT NULL
    AND    NOT EXISTS(
           SELECT 1
           FROM   po_session_gt gt
           WHERE  key = l_data_key
           AND    gt.num1 < x_lines.intf_line_id_tbl(i)
           AND    gt.num2 = x_lines.hd_po_header_id_tbl(i)
           AND    gt.char1 = x_lines.vendor_product_num_tbl(i)
           AND    NVL(x_lines.supplier_part_auxid_tbl(i),
                      NVL(gt.char2, FND_API.g_NULL_CHAR))=
                  NVL(gt.char2, FND_API.g_NULL_CHAR));

  d_position := 50;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  d_position := 60;

  -- bug5093465
  -- For the records in l_index_tbl, assign action 'ADD'
  set_action_add
  ( p_key                    => p_key,
    p_group_num              => p_group_num,
    p_target_lines_index_tbl => l_index_tbl,
    p_check_line_num_assign  => FND_API.G_TRUE,
    x_processing_row_tbl     => x_processing_row_tbl,
    x_lines                  => x_lines
  );

  d_position := 70;

  -- clean up po_session_gt
  PO_PDOI_UTL.remove_session_gt_records
  ( p_key => l_data_key
  );

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
END uniqueness_check_on_vpn;

-----------------------------------------------------------------------
--Start of Comments
--Name: uniqueness_check_on_job
--Function:
--  check item uniqueness based on job name
--Parameters:
--IN:
--  p_key
--    key value used to identify rows in temp table
--  p_group_num
--    the new group number that is going to be assigned to rows
--    whose action can be decided in this procedure
--IN OUT:
--  x_processing_row_tbl
--    index table of rows that are going to be processed
--  x_lines
--    record of line information read within the batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE uniqueness_check_on_job
(
  p_key                 IN po_session_gt.key%TYPE,
  p_group_num           IN NUMBER,
  x_processing_row_tbl  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'uniqueness_check_on_job';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold matching result read from po_session_gt table
  l_index_tbl           PO_TBL_NUMBER;
  l_po_line_id_tbl      PO_TBL_NUMBER;
  l_line_num_tbl        PO_TBL_NUMBER;

  l_index               NUMBER;
  l_data_key            po_session_gt.key%TYPE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- check matchings on draft table
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
    SELECT
      p_key,
      x_processing_row_tbl(i),
      draft_lines.po_line_id,
      draft_lines.line_num
    FROM  po_lines_draft_all draft_lines
    WHERE x_lines.item_tbl(i) IS NULL
    AND   x_lines.vendor_product_num_tbl(i) IS NULL
    AND   x_lines.job_name_tbl(i) IS NOT NULL
    AND   draft_lines.po_header_id = x_lines.hd_po_header_id_tbl(i)
    AND   draft_lines.draft_id = x_lines.draft_id_tbl(i)
    AND   NVL(draft_lines.expiration_date, TRUNC(sysdate)) >= TRUNC(sysdate)
    AND   EXISTS (SELECT 1
                  FROM   per_jobs_vl
                  WHERE  name = x_lines.job_name_tbl(i)
                  AND    job_id = draft_lines.job_id)
    AND   NVL(draft_lines.expiration_date, TRUNC(sysdate)) >= TRUNC(sysdate);

  d_position := 10;

  -- check matching on txn table
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
    SELECT
      p_key,
      x_processing_row_tbl(i),
      txn_lines.po_line_id,
      txn_lines.line_num
    FROM  po_lines txn_lines
    WHERE x_lines.item_tbl(i) IS NULL
    AND   x_lines.vendor_product_num_tbl(i) IS NULL
    AND   x_lines.job_name_tbl(i) IS NOT NULL
    AND   txn_lines.po_header_id = x_lines.hd_po_header_id_tbl(i)
    AND   NOT EXISTS ( SELECT 1
                       FROM   po_lines_draft_all draft_lines
                       WHERE  draft_lines.po_line_id = txn_lines.po_line_id
                       AND    draft_lines.draft_id = x_lines.draft_id_tbl(i))
    AND   EXISTS (SELECT 1
                  FROM   per_jobs_vl
                  WHERE  name = x_lines.job_name_tbl(i)
                  AND    job_id = txn_lines.job_id)
    AND   NVL(txn_lines.expiration_date, TRUNC(sysdate)) >= TRUNC(sysdate)
    AND   NVL(txn_lines.closed_code, 'OPEN') <> 'FINALLY CLOSED'
    AND   NVL(txn_lines.cancel_flag, 'N') <> 'Y';

  d_position := 20;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, num2, num3 BULK COLLECT INTO
    l_index_tbl, l_po_line_id_tbl, l_line_num_tbl;

  -- set po_line_id, and line_num from matching record
  -- If there is only one matching -- OK
  -- If there are multiple matching records, update the line that has same
  -- line_num as in interface table; otherwise, update line with maximum
  -- line_num
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (x_lines.po_line_id_tbl(l_index) IS NULL) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'first match index', l_index);
        PO_LOG.stmt(d_module, d_position, 'po line id', l_po_line_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'line num', l_line_num_tbl(i));
      END IF;

      -- first match found
      x_lines.origin_line_num_tbl(l_index) := x_lines.line_num_tbl(l_index);
      x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_UPDATE;
      x_lines.group_num_tbl(l_index) := p_group_num;
      x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
      x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
      x_processing_row_tbl.DELETE(l_index);
      IF (l_line_num_tbl(i) = x_lines.origin_line_num_tbl(l_index)) THEN
        x_lines.match_line_found_tbl(l_index) := FND_API.g_TRUE;
      END IF;
    ELSE
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'multi match index', l_index);
        PO_LOG.stmt(d_module, d_position, 'po line id', l_po_line_id_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'line num', l_line_num_tbl(i));
        PO_LOG.stmt(d_module, d_position, 'original line num',
                    x_lines.origin_line_num_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'match line found',
                    x_lines.match_line_found_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'current line num',
                    x_lines.line_num_tbl(l_index));
      END IF;

      -- multiple matches found
      IF (l_line_num_tbl(i) = x_lines.origin_line_num_tbl(l_index)) THEN
        -- record matching line_num is found
        x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
        x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
        x_lines.match_line_found_tbl(l_index) := FND_API.g_TRUE;
      ELSIF (x_lines.match_line_found_tbl(l_index) = FND_API.g_TRUE) THEN
        -- need to do nothing, record with matching line num is found before
        NULL;
      ELSIF (x_lines.line_num_tbl(l_index) < l_line_num_tbl(i)) THEN
        -- try to update line with maximum line num if exact match can not be found
        x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
        x_lines.line_num_tbl(l_index) := l_line_num_tbl(i);
      ELSE
        -- do nothing since the new coming record has smaller line num
        -- than current matching record
        NULL;
      END IF;
    END IF;
  END LOOP;

  d_position := 30;

  -- search within the batch
  -- find out all lines that cannot find a match
  -- and set their action to ADD
  l_data_key := PO_CORE_S.get_session_gt_nextval;
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      char1
    )
  SELECT
    l_data_key,
    x_lines.intf_line_id_tbl(i),       -- num1
    x_lines.hd_po_header_id_tbl(i),    -- num2
    x_lines.job_name_tbl(i)            -- char1
  FROM DUAL;

  d_position := 40;

  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1
    )
    SELECT p_key,
           x_processing_row_tbl(i)
    FROM   DUAL
    WHERE  x_lines.item_tbl(i) IS NULL
    AND    x_lines.vendor_product_num_tbl(i) IS NULL
    AND    x_lines.job_name_tbl(i) IS NOT NULL
    AND    NOT EXISTS(
           SELECT 1
           FROM   po_session_gt gt
           WHERE  key = l_data_key
           AND    gt.num1 < x_lines.intf_line_id_tbl(i)
           AND    gt.num2 = x_lines.hd_po_header_id_tbl(i)
           AND    gt.char1 = x_lines.job_name_tbl(i));

  d_position := 50;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  -- bug5093465
  -- For the records in l_index_tbl, assign action 'ADD'
  set_action_add
  ( p_key                    => p_key,
    p_group_num              => p_group_num,
    p_target_lines_index_tbl => l_index_tbl,
    p_check_line_num_assign  => FND_API.G_TRUE,
    x_processing_row_tbl     => x_processing_row_tbl,
    x_lines                  => x_lines
  );

  d_position := 60;

  -- clean up po_session_gt
  PO_PDOI_UTL.remove_session_gt_records
  ( p_key => l_data_key
  );

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
END uniqueness_check_on_job;

-----------------------------------------------------------------------
--Start of Comments
--Name: uniqueness_check_on_line_num
--Function:
--  check item uniqueness based on line number
--Parameters:
--IN:
--  p_key
--    key value used to identify rows in temp table
--  p_group_num
--    the new group number that is going to be assigned to rows
--    whose action can be decided in this procedure
--IN OUT:
--  x_processing_row_tbl
--    index table of rows that are going to be processed
--  x_lines
--    record of line information read within the batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE uniqueness_check_on_line_num
(
  p_key                 IN po_session_gt.key%TYPE,
  p_group_num           IN NUMBER,
  x_processing_row_tbl  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines               IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'uniqueness_check_on_line_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- variables to hold matching result read from po_session_gt table
  l_index_tbl           PO_TBL_NUMBER;
  l_po_line_id_tbl      PO_TBL_NUMBER;
  l_line_num_tbl        PO_TBL_NUMBER;

  l_index               NUMBER;
  l_data_key            po_session_gt.key%TYPE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- check matchings on draft table
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
    SELECT
      p_key,
      x_processing_row_tbl(i),
      draft_lines.po_line_id,
      draft_lines.line_num
    FROM  po_lines_draft_all draft_lines
    WHERE x_lines.item_tbl(i) IS NULL
    AND   x_lines.vendor_product_num_tbl(i) IS NULL
    AND   x_lines.job_name_tbl(i) IS NULL
    AND   x_lines.line_num_tbl(i) IS NOT NULL
    AND   draft_lines.po_header_id = x_lines.hd_po_header_id_tbl(i)
    AND   draft_lines.draft_id = x_lines.draft_id_tbl(i)
    AND   NVL(draft_lines.expiration_date, TRUNC(sysdate)) >= TRUNC(sysdate)
    AND   draft_lines.line_num = x_lines.line_num_tbl(i);

  d_position := 10;

  -- check matching on txn table
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
    SELECT
      p_key,
      x_processing_row_tbl(i),
      txn_lines.po_line_id,
      txn_lines.line_num
    FROM  po_lines txn_lines
    WHERE x_lines.item_tbl(i) IS NULL
    AND   x_lines.vendor_product_num_tbl(i) IS NULL
    AND   x_lines.job_name_tbl(i) IS NULL
    AND   x_lines.line_num_tbl(i) IS NOT NULL
    AND   txn_lines.po_header_id = x_lines.hd_po_header_id_tbl(i)
    AND   NOT EXISTS ( SELECT 1
                       FROM   po_lines_draft_all draft_lines
                       WHERE  draft_lines.po_line_id = txn_lines.po_line_id
                       AND    draft_lines.draft_id = x_lines.draft_id_tbl(i))
    AND   txn_lines.line_num = x_lines.line_num_tbl(i)
    AND   NVL(txn_lines.expiration_date, TRUNC(sysdate)) >= TRUNC(sysdate)
    AND   NVL(txn_lines.closed_code, 'OPEN') <> 'FINALLY CLOSED'
    AND   NVL(txn_lines.cancel_flag, 'N') <> 'Y';

  d_position := 20;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1, num2, num3 BULK COLLECT INTO
    l_index_tbl, l_po_line_id_tbl, l_line_num_tbl;

  -- set po_line_id, and line_num from matching record
  -- There can be at most 1 matching record since we match on line num
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    x_lines.origin_line_num_tbl(l_index) := x_lines.line_num_tbl(l_index);
    x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_UPDATE;
    x_lines.group_num_tbl(l_index) := p_group_num;
    x_lines.po_line_id_tbl(l_index) := l_po_line_id_tbl(i);
    x_processing_row_tbl.DELETE(l_index);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'match index', l_index);
      PO_LOG.stmt(d_module, d_position, 'po line id', l_po_line_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'current line num',
                  x_lines.line_num_tbl(l_index));
    END IF;
  END LOOP;

  d_position := 30;

  -- search within the batch
  -- find out all lines that cannot find a match
  -- and set their action to ADD
  l_data_key := PO_CORE_S.get_session_gt_nextval;
  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1,
      num2,
      num3
    )
  SELECT
    l_data_key,
    x_lines.intf_line_id_tbl(i),       -- num1
    x_lines.hd_po_header_id_tbl(i),    -- num2
    x_lines.line_num_tbl(i)            -- num3
  FROM DUAL;

  d_position := 40;

  FORALL i IN INDICES OF x_processing_row_tbl
    INSERT INTO po_session_gt
    (
      key,
      num1
    )
    SELECT p_key,
           x_processing_row_tbl(i)
    FROM   DUAL
    WHERE  x_lines.item_tbl(i) IS NULL
    AND    x_lines.vendor_product_num_tbl(i) IS NULL
    AND    x_lines.job_name_tbl(i) IS NULL
    AND    x_lines.line_num_tbl(i) IS NOT NULL
    AND    NOT EXISTS(
           SELECT 1
           FROM   po_session_gt gt
           WHERE  key = l_data_key
           AND    gt.num1 < x_lines.intf_line_id_tbl(i)
           AND    gt.num2 = x_lines.hd_po_header_id_tbl(i)
           AND    gt.num3 = x_lines.line_num_tbl(i));

  d_position := 50;

  DELETE FROM po_session_gt
  WHERE key = p_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  -- bug5093465
  -- For the records in l_index_tbl, assign action 'ADD'
  set_action_add
  ( p_key                    => p_key,
    p_group_num              => p_group_num,
    p_target_lines_index_tbl => l_index_tbl,
    p_check_line_num_assign  => FND_API.G_FALSE,
    x_processing_row_tbl     => x_processing_row_tbl,
    x_lines                  => x_lines
  );

  d_position := 60;

  PO_PDOI_UTL.remove_session_gt_records
  ( p_key => l_data_key
  );

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
END uniqueness_check_on_line_num;


-- bug5093465 START
-----------------------------------------------------------------------
--Start of Comments
--Name: set_action_add
--Function:
--  Assign ADD as the action for the line. If needed, assign new line number
--  for the line
--Parameters:
--IN:
--  p_key
--    key value used to identify rows in temp table
--  p_group_num
--    the new group number that is going to be assigned to rows
--    whose action can be decided in this procedure
--  p_target_line_index_tbl
--    Table containing indexes for the lines to be assigned with action
--    'ADD'
--  p_check_line_num_assign
--    If FND_API.G_TRUE, then it checks whether a new line number needs
--    to be assigned to the record. FND_API.G_FALSE otherwise.
--IN OUT:
--  x_processing_row_tbl
--    index table of rows that are going to be processed
--  x_lines
--    record of line information read within the batch
--OUT:
--End of Comments
------------------------------------------------------------------------

PROCEDURE set_action_add
(
  p_key                   IN po_session_gt.key%TYPE,
  p_group_num             IN NUMBER,
  p_target_lines_index_tbl IN PO_TBL_NUMBER,
  p_check_line_num_assign IN VARCHAR2,
  x_processing_row_tbl    IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE,
  x_lines                 IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS


d_api_name CONSTANT VARCHAR2(30) := 'set_action_add';
d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_index NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- mark all lines as to be created
  FOR i IN 1..p_target_lines_index_tbl.COUNT
  LOOP

    d_position := 10;
    l_index := p_target_lines_index_tbl(i);

    x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_ADD;
    x_lines.group_num_tbl(l_index) := p_group_num;
    x_lines.po_line_id_tbl(l_index) := PO_PDOI_MAINPROC_UTL_PVT.get_next_po_line_id;

    IF (p_check_line_num_assign = FND_API.G_TRUE) THEN


      IF (x_lines.line_num_tbl(l_index) IS NULL OR
          x_lines.line_num_unique_tbl(l_index) = FND_API.g_FALSE) THEN

        d_position := 20;

        x_lines.line_num_tbl(l_index) :=
          PO_PDOI_MAINPROC_UTL_PVT.get_next_line_num
          (
            p_po_header_id => x_lines.hd_po_header_id_tbl(l_index)
          );

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'assign new line num', x_lines.line_num_tbl(l_index));
        END IF;

      END IF;

    END IF;

    d_position := 30;

    -- action is determined. No longer need to process it
    x_processing_row_tbl.DELETE(l_index);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'match index', l_index);
      PO_LOG.stmt(d_module, d_position, 'po line id',
                  x_lines.po_line_id_tbl(l_index));
    END IF;

  END LOOP;

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
END set_action_add;

-- bug5093465 END

-----------------------------------------------------------------------
--Start of Comments
--Name: validate_attr_tlp
--Function:
--  validate whether there is a line with creation language existing
--  in po_attr_values_tlp_interface table; If rows with creation lang
--  does not exist but rows in other langs exist, insert error in
--  error interface table
--  The procedure is called only when line action = 'CREATE'
--Parameters:
--IN:
--IN OUT:
--  x_lines
--    record of line information read within the batch
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE validate_attr_tlp
(
  x_lines IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'validate_attr_tlp';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key po_session_gt.key%TYPE;

  -- table used to save the index of the each row
  l_index_tbl DBMS_SQL.NUMBER_TABLE;
  l_index     NUMBER;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- assign a new key used in temporary table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize table containing the row number(index)
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size     => x_lines.rec_count,
    x_num_list => l_index_tbl
  );

  FORALL i IN 1..x_lines.rec_count
    INSERT INTO po_session_gt
    (
      key,
      num1
    )
    SELECT
      l_key,
      l_index_tbl(i)
    FROM   DUAL
    WHERE  NOT EXISTS
           (
             SELECT 1
             FROM   po_attr_values_tlp_interface
             WHERE  interface_line_id = x_lines.intf_line_id_tbl(i)
             AND    language = x_lines.hd_created_language_tbl(i)
           )
    AND    EXISTS
           (
             SELECT 1
             FROM   po_attr_values_tlp_interface
             WHERE  interface_line_id = x_lines.intf_line_id_tbl(i)
             AND    language <> x_lines.hd_created_language_tbl(i)
           );

  d_position := 10;

  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  d_position := 20;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'error on index', l_index);
    END IF;

    PO_PDOI_ERR_UTL.add_fatal_error
    (
      p_interface_header_id  => x_lines.intf_header_id_tbl(l_index),
      p_interface_line_id    => x_lines.intf_line_id_tbl(l_index),
      p_error_message_name   => 'PO_PDOI_NO_TLP_IN_CREATE_LANG',
      p_table_name           => 'PO_LINES_INTERFACE',
      p_column_name          => NULL,
      p_column_value         => NULL,
      p_validation_id        => PO_VAL_CONSTANTS.c_language,
      p_lines                => x_lines
    );

    x_lines.error_flag_tbl(l_index) := FND_API.g_TRUE;
  END LOOP;

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
END validate_attr_tlp;

-----------------------------------------------------------------------
--Start of Comments
--Name: populate_error_flag
--Function:
--  corresponding value in error_flag_tbl will be set with value FND_API.G_FALSE.
--Parameters:
--IN:
--x_results
--  The validation results that contains the errored line information.
--IN OUT:
--x_lines
--  The record contains the values to be validated.
--  If there is error(s) on any attribute of the price differential row,
--  corresponding value in error_flag_tbl will be set with value
--  FND_API.G_FALSE.
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE populate_error_flag
(
  x_results           IN     po_validation_results_type,
  x_lines             IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'populate_error_flag';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_index_tbl DBMS_SQL.number_table;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;

  FOR i IN 1 .. x_lines.intf_line_id_tbl.COUNT LOOP
      l_index_tbl(x_lines.intf_line_id_tbl(i)) := i;
  END LOOP;

  d_position := 20;

  FOR i IN 1 .. x_results.entity_id.COUNT LOOP
     IF x_results.result_type(i) = po_validations.c_result_type_failure THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'error on index',
                      l_index_tbl(x_results.entity_id(i)));
        END IF;

        x_lines.error_flag_tbl(l_index_tbl(x_results.entity_id(i))) := FND_API.g_TRUE;
     END IF;
  END LOOP;

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
END populate_error_flag;

-----------------------------------------------------------------------
--Start of Comments
--Name: handle_err_tolerance
--Function:  This procedure maintains line processing information for each
--           document. It also handles the error tolerance for Catalog Upload.
--           Update PO_PDOI_PARAMS.g_docs_info(intf_header_id).number_of_processed_lines
--           for each line.
--
--           If line contains error, increment
--           PO_PDOI_PARAMS.g_docs_info(intf_header_id).number_of_errored_lines
--
--           If the number of errored lines exceeds the error tolerance, then set
--           PO_PDOI_PARAMS.g_docs_info(intf_header_id).err_tolerance_exceeded to TRUE and
--           set x_lines.need_to_reject_flag_tbl to TRUE.
--
--           If the line does not have error, increment
--           PO_PDOI_PARAMS.g_docs_info(intf_header_id).number_of_valid_lines
--Parameters:
--IN OUT:
--  x_lines
--    record which stores all the line rows within the batch;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE handle_err_tolerance
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'handle_err_tolerance';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_err_lines_tolerance  NUMBER := PO_PDOI_PARAMS.g_request.err_lines_tolerance;
  l_intf_header_id       NUMBER;
  l_num_errored_lines    NUMBER;
  l_num_processed_lines  NUMBER;
  l_num_valid_lines      NUMBER;
  l_remove_err_line_tbl  PO_TBL_NUMBER := PO_TBL_NUMBER();

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module, 'err_lines_tolerance', l_err_lines_tolerance);
  END IF;

  FOR i IN 1 .. x_lines.rec_count
  LOOP
    l_intf_header_id := x_lines.intf_header_id_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      PO_LOG.stmt(d_module, d_position, 'intf header id', l_intf_header_id);
    END IF;

    d_position := 10;

    IF (PO_PDOI_PARAMS.g_request.calling_module = PO_PDOI_CONSTANTS.g_call_mod_CATALOG_UPLOAD AND
        PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).err_tolerance_exceeded = FND_API.G_TRUE ) THEN
       x_lines.need_to_reject_flag_tbl(i) := FND_API.g_TRUE;

       -- bug 5215781:
       -- collect ids of lines for which errors on them would be removed from error interface
       -- table since error tolerance threshold is hit before them
       l_remove_err_line_tbl.EXTEND;
       l_remove_err_line_tbl(l_remove_err_line_tbl.COUNT) := x_lines.intf_line_id_tbl(i);
    ELSE
      l_num_processed_lines := PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_processed_lines + 1;
      PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_processed_lines := l_num_processed_lines;

      IF (PO_LOG.d_stmt) THEN
       PO_LOG.stmt(d_module, d_position, 'num_processed_lines', l_num_processed_lines);
      END IF;

      d_position := 20;

      IF x_lines.error_flag_tbl(i) = FND_API.g_TRUE THEN
        l_num_errored_lines := PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_errored_lines + 1;
        PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_errored_lines := l_num_errored_lines;

        -- set corresponding line to ERROR
        PO_PDOI_PARAMS.g_errored_lines(x_lines.intf_line_id_tbl(i)) := 'Y';

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'num_errored_lines', l_num_errored_lines);
        END IF;

        d_position := 30;

/*bug 9213156 : Setting the err_tolerance_exceeded flag when l_num_errored_lines is greater than l_err_lines_tolerance*/
IF (PO_PDOI_PARAMS.g_request.calling_module =
              PO_PDOI_CONSTANTS.g_call_mod_CATALOG_UPLOAD AND
            l_num_errored_lines > l_err_lines_tolerance) THEN

           PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).err_tolerance_exceeded := FND_API.g_TRUE;
        END IF;

        d_position := 40;
      ELSE
        d_position := 50;

        -- maintain number of valid lines
        l_num_valid_lines := PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_valid_lines + 1;
        PO_PDOI_PARAMS.g_docs_info(l_intf_header_id).number_of_valid_lines := l_num_valid_lines;

      END IF;
    END IF;
  END LOOP;

  d_position := 60;

  -- Bug 5215781:
  -- remove the errors for lines from po_interface_errors if those lines are supposed to be processed
  -- after the line where we hit the error tolerance; That means, we want to rollback the changes if
  -- error tolerance is reached at some point
  PO_INTERFACE_ERRORS_UTL.flush_errors_tbl;

  FORALL i IN 1..l_remove_err_line_tbl.COUNT
    DELETE FROM PO_INTERFACE_ERRORS
    WHERE interface_line_id = l_remove_err_line_tbl(i);

  d_position := 70;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'num_processed_lines', l_num_processed_lines);
    PO_LOG.proc_end(d_module, 'num_errored_lines', l_num_errored_lines);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    (
      p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE;
END handle_err_tolerance;
--<PDOI Enhancement Bug#17063664 START>--
-----------------------------------------------------------------------
--Start of Comments
--Name: assign_line_num
--Function: The procedure will assign line number and po line id.
--          The grouping flag is selected to 'N' , so lines will not be
--           grouped
--
--Parameters:
--IN OUT:
--  x_lines
--    record which stores all the line rows within the batch;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE assign_line_num
(  x_lines         IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'Assign_line_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- hold the key value which is used to identify rows in temp table
  l_key           po_session_gt.key%TYPE;

  l_po_header_id  po_headers_all.po_header_id%TYPE;
  l_line_num   po_lines_all.line_num%TYPE;
  l_index         NUMBER;

  --Identify the lines which will be processed
  l_processing_line_tbl DBMS_SQL.NUMBER_TABLE;

  --Index table
  l_index_tbl           PO_TBL_NUMBER;


  l_req_line_num_tbl    PO_TBL_NUMBER;
  l_req_num_tbl         PO_TBL_NUMBER;
  l_complex_flag_tbl    PO_TBL_VARCHAR1;

 -- hash table o based on po_header_id and line number
 TYPE line_ref_internal_type IS TABLE OF NUMBER INDEX BY VARCHAR2(32);
 TYPE line_ref_type IS TABLE OF line_ref_internal_type INDEX BY PLS_INTEGER;

 l_line_num_ref_tbl line_ref_type;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- get key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  d_position := 10;
  -- Determine whether the PO is complex PO or not
  FORALL i IN 1..x_lines.rec_count
  INSERT INTO po_session_gt(key,char1)
  SELECT l_key,progress_payment_flag
  FROM   po_doc_style_headers
  WHERE  style_id= x_lines.hd_style_id_tbl(i);

  DELETE FROM po_session_gt
  WHERE  KEY = l_key
  RETURNING char1 BULK COLLECT INTO l_complex_flag_tbl;

  -- Identify the lines which are eligible to process
  -- All lines which have satisfy below conditions
  -- will be processed
  -- 1. Group lines flag is 'N'
  -- 2. Complex PO style = 'Y'
  --    Complex PO should not be considered for grouping
  -- 3. Line loc populated flag is 'Y'
  --    If line locations interface data is populated
  --    the lines will not be grouped
  -- 4. order type lookup code is 'FIXED PRICE' and
  --    'RATE'. Service line types should not be grouped.
  -- 5. Blanket PO and Amount based line
  -- 6. orig_from_req_flag is 'N'
  --   lines that are soft linked cannot be grouped
  -- 7. Error flag is False

  FOR i IN 1..x_lines.rec_count
  LOOP
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', i);
      PO_LOG.stmt(d_module, d_position, 'Complex flag ', l_complex_flag_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'order_type_lookup_code ', x_lines.order_type_lookup_code_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'orig_from_req_flag ',x_lines.orig_from_req_flag_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'Error Flag ',x_lines.error_flag_tbl(i));
    END IF;

    IF ( PO_PDOI_PARAMS.g_request.group_lines = 'N' OR
         l_complex_flag_tbl(i) = 'Y' OR
	 x_lines.line_loc_populated_flag_tbl(i) = 'Y' OR
	 x_lines.order_type_lookup_code_tbl(i) IN ('FIXED PRICE' ,'RATE') OR
	 ( x_lines.order_type_lookup_code_tbl(i) = 'AMOUNT' AND
           PO_PDOI_PARAMS.g_request.document_type =
	     PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET
	 )OR
         NVL (x_lines.orig_from_req_flag_tbl(i), 'Y') = 'N'
       ) AND
       x_lines.error_flag_tbl(i) = FND_API.g_FALSE  THEN
      IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module, d_position, 'processing index', i);
         PO_LOG.stmt(d_module, d_position, 'processing line', x_lines.intf_line_id_tbl(i));
      END IF;
      l_processing_line_tbl(i) := i;
    END IF;
  END LOOP;

  IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Number of lines processed',
                  l_processing_line_tbl.COUNT);
  END IF;

  d_position := 20;
  -- Fetching the requisition header and req line number
  -- details.
  FORALL i IN INDICES OF l_processing_line_tbl
  INSERT INTO po_session_gt(key,num1,num2)
  SELECT l_key,
         l_processing_line_tbl(i),
	 prl.line_num
  FROM   po_requisition_lines_all prl
  WHERE  prl.requisition_line_id = x_lines.requisition_line_id_tbl(i)
  AND    x_lines.requisition_line_id_tbl(i) IS NOT NULL;


  FORALL i IN INDICES OF l_processing_line_tbl
  INSERT INTO po_session_gt(key,num1,num2)
  SELECT l_key,
         l_processing_line_tbl(i),
         NULL
  FROM   DUAL
  WHERE  x_lines.requisition_line_id_tbl(i) IS NULL;


  DELETE FROM po_session_gt
  WHERE  KEY = l_key
  RETURNING num1,num2 BULK COLLECT INTO
            l_index_tbl,l_req_num_tbl;

  IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'l_index_tbl',l_index_tbl);
      PO_LOG.stmt(d_module, d_position, 'l_req_num_tbl',l_req_num_tbl);
  END IF;

  d_position := 30;
  --Loop through lines to assign po line id and po line number.
  FOR i IN 1..l_index_tbl.COUNT
  LOOP

    l_index := l_index_tbl(i);
    l_po_header_id := x_lines.hd_po_header_id_tbl(l_index);
    l_line_num := x_lines.line_num_tbl(l_index);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'po header id', l_po_header_id);
      PO_LOG.stmt(d_module, d_position, 'line num', l_line_num);
    END IF;

    -- check if Line number is unique within one Purchase order as
    -- the lines cannot be grouped
    IF l_line_num IS NOT NULL THEN
      IF (l_line_num_ref_tbl.EXISTS(l_po_header_id) AND
          l_line_num_ref_tbl(l_po_header_id).EXISTS(l_line_num)) THEN

        --Line number is not unique within the PO
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'Error on index', l_index);
          PO_LOG.stmt(d_module, d_position, 'po header id', l_po_header_id);
          PO_LOG.stmt(d_module, d_position, 'po line number',l_line_num);
        END IF;

        PO_PDOI_ERR_UTL.add_fatal_error
        (
         p_interface_header_id  => x_lines.intf_header_id_tbl(l_index),
         p_interface_line_id    => x_lines.intf_line_id_tbl(l_index),
  	 p_error_message_name   => 'PO_PDOI_LINE_NO_GROUP',
  	 p_table_name           => 'PO_LINES_INTERFACE',
  	 p_column_name          => 'LINE_NUM',
  	 p_column_value         =>  l_line_num,
  	 p_token2_name          => 'VALUE',
  	 p_token2_value         =>  l_line_num
        );
        x_lines.error_flag_tbl(l_index) := FND_API.g_TRUE;
      ELSE   -- else for l_line_num_ref_tbl
        -- Line number is unique
        l_line_num_ref_tbl(l_po_header_id)(l_line_num) := l_index;
	x_lines.po_line_id_tbl(l_index):= PO_PDOI_MAINPROC_UTL_PVT.get_next_po_line_id;
	x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_ADD;
	--Marking the match line found to TRUE indicating the line
	-- has been processed
        x_lines.match_line_found_tbl(l_index) := FND_API.g_TRUE;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'Line number is unique for po header',
	              l_po_header_id);
          PO_LOG.stmt(d_module, d_position, 'Line number',l_line_num);
          PO_LOG.stmt(d_module, d_position, 'new po line id',
                      x_lines.po_line_id_tbl(l_index));
        END IF;
      END IF; -- End condition for unique line number condition
    ELSE -- l_line_num is null
      -- Line number is null
      x_lines.po_line_id_tbl(l_index):=  PO_PDOI_MAINPROC_UTL_PVT.get_next_po_line_id;
      x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_ADD;
      --Marking the match line found to TRUE indicating the line
      -- has been processed
      x_lines.match_line_found_tbl(l_index) := FND_API.g_TRUE;

      -- Line number will be same a req line number only if
      -- 1. Header action is 'ORIGINAL' or 'ADD'
      -- 2. use_req_num_in_autocreate profile is 'Y'
      -- 3. The api is called from autocreate
      IF PO_PDOI_PARAMS.g_request.group_lines = 'N' AND -- Bug#17998114
        x_lines.hd_action_tbl(l_index) <> PO_PDOI_CONSTANTS.g_ACTION_UPDATE AND
        PO_PDOI_PARAMS.g_profile.use_req_num_in_autocreate = 'Y' AND
        PO_PDOI_PARAMS.g_request.calling_module = PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE
      THEN
        x_lines.line_num_tbl(l_index) := l_req_num_tbl(i);
      ELSE
        x_lines.line_num_tbl(l_index) :=
        PO_PDOI_MAINPROC_UTL_PVT.get_next_line_num(l_po_header_id);
      END IF;

       IF (PO_LOG.d_stmt) THEN
         PO_LOG.stmt(d_module, d_position, 'new Line number',x_lines.line_num_tbl(l_index));
         PO_LOG.stmt(d_module, d_position, 'new po line id',
                     x_lines.po_line_id_tbl(l_index));
       END IF;
     END IF; -- End for l_line_num condition
   END LOOP ;

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
END assign_line_num;
-----------------------------------------------------------------------
--Start of Comments
--Name: check_req_line_uniqueness
--Function: The procedure will check the requisition line id
--          provided as a refence is lines is unique accross
--          draft and interface tables.
--          Same requisition line cannot be used on two
--          lines
--Parameters:
--IN OUT:
--  x_lines
--    record which stores all the line rows within the batch;
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE check_req_line_uniqueness
( x_lines         IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
) IS

  d_api_name CONSTANT VARCHAR2(30) := 'check_req_line_uniqueness';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key       po_session_gt.key%TYPE;
  l_index     NUMBER;

  --Index table
  l_index_tbl           DBMS_SQL.NUMBER_TABLE;


BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- pick a new key for temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize index table
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size      => x_lines.rec_count,
    x_num_list  => l_index_tbl
  );

  d_position := 10;

  -- Check if requisition line id exists
  -- in the draft table table .
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key,num1)
    SELECT DISTINCT l_key,
           l_index_tbl(i)
    FROM   po_lines_draft_all pld,
           po_lines_interface pli
    WHERE  draft_id = x_lines.draft_id_tbl(i)
    AND    pld.po_line_id = PLI.po_line_id
    AND    x_lines.requisition_line_id_tbl(i) IS NOT NULL
    AND    pli.po_line_id IS NOT NULL
    AND    pli.processing_id = PO_PDOI_PARAMS.g_processing_id
    AND    pli.requisition_line_id = x_lines.requisition_line_id_tbl(i)
    AND    pli.requisition_line_id IS NOT NULL;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Number of rows inserted from draft',
	             SQL%ROWCOUNT);
    END IF;

  d_position := 20;

  -- Check in the interface table records which is before current records
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key,num1)
    SELECT l_key,l_index_tbl(i)
    FROM   po_lines_interface intf_lines,
           po_headers_interface intf_headers
    WHERE  intf_lines.interface_header_id = intf_headers.interface_header_id
    AND    intf_lines.processing_id = PO_PDOI_PARAMS.g_processing_id
    AND    intf_headers.processing_round_num =
            PO_PDOI_PARAMS.g_current_round_num
    AND    intf_lines.interface_line_id < x_lines.intf_line_id_tbl(i)
    AND    intf_lines.interface_line_id >= x_lines.intf_line_id_tbl(1)
    AND    x_lines.requisition_line_id_tbl(i) IS NOT NULL
    AND    intf_lines.requisition_line_id = x_lines.requisition_line_id_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Number of rows inserted from interface',
	             SQL%ROWCOUNT);
    END IF;

  l_index_tbl.DELETE;

  SELECT DISTINCT num1
  BULK COLLECT INTO l_index_tbl
  FROM po_session_gt
  WHERE KEY = l_key;

  DELETE FROM po_session_gt
  WHERE KEY = l_key;

  d_position := 30;

 --Mark error flag for all the lines as true identified
 -- in above two queries
  FOR i IN 1..l_index_tbl.COUNT
  LOOP

    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Error on index', l_index);
      PO_LOG.stmt(d_module, d_position, 'requisition line num',x_lines.requisition_line_id_tbl(l_index));
    END IF;

    PO_PDOI_ERR_UTL.add_fatal_error
     (
      p_interface_header_id  => x_lines.intf_header_id_tbl(l_index),
      p_interface_line_id    => x_lines.intf_line_id_tbl(l_index),
      p_error_message_name   => 'PO_PDOI_REQ_LINE_NUM_UNIQUE',
      p_table_name           => 'PO_LINES_INTERFACE',
      p_column_name          => 'REQUISITION_LINE_ID',
      p_column_value         =>  x_lines.requisition_line_id_tbl(l_index),
      p_token2_name          => 'VALUE',
      p_token2_value         =>  x_lines.requisition_line_id_tbl(l_index)
    );

    x_lines.error_flag_tbl(i) := FND_API.g_TRUE;

  END LOOP;

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
END check_req_line_uniqueness;
-----------------------------------------------------------------------
--Start of Comments
--Name: reject_lines_on_line_num
--Function: The procedure will reject all the lines
--          having same line number but the matching criteria is not
--          satisfied
--Parameters:
--IN:
-- p_key
--   Session key to get the matching attributes from po_session_gt table
--IN OUT:
--  x_lines
--    record which stores all the line rows within the batch;
--  x_processing_row_tbl
--    Table to indicate the lines has been processed or not
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE  reject_lines_on_line_num
( p_key                IN po_session_gt.key%TYPE,
  x_lines              IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
)IS

  d_api_name CONSTANT VARCHAR2(30) := 'reject_lines_on_line_num';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;


  l_index         NUMBER;
  l_count         NUMBER;

  l_index_tbl        PO_TBL_NUMBER;
  l_po_header_id_tbl PO_TBL_NUMBER;
  l_line_num_tbl     PO_TBL_NUMBER;
  l_cnt_tbl          PO_TBL_NUMBER;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of rows to be processed', x_processing_row_tbl.COUNT);
  END IF;

  d_position := 10;

  SELECT COUNT(*)
  INTO l_count
  FROM  (SELECT column_value val
         FROM TABLE(x_lines.line_num_tbl)
	 ) line_num
  WHERE line_num.val IS NOT NULL;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of lines having Line num',l_count);
  END IF;

  IF l_count = 0 THEN
    RETURN;
  END IF;

  --SQL What: Getting all the line number for each po
  --          which have same line number on multiple lines
  --          but grouping criteria is not matched
  --SQL Why: Need to reject all the lines identifed

  SELECT po_header_id,
         line_num,
	 COUNT(line_num)
  BULK COLLECT INTO
        l_po_header_id_tbl,
	l_line_num_tbl,
	l_cnt_tbl
  FROM (
  SELECT plg.po_header_id,
         plg.line_num,
      --<Bug#17788591 START: Matching basis and
      -- purchase basis should be compared
      -- instead of line type>
	-- plg.line_type_id,
	 plg.purchase_basis,
	 plg.matching_basis,
      --<Bug#17788591 END>
	 plg.item_id,
         plg.item_description,
         plg.item_revision,
	 plg.category_id,
         plg.unit_meas_lookup_code,
	 plg.from_header_id,
	 plg.from_line_id,
	 DECODE(PO_PDOI_PARAMS.g_profile.group_by_need_by_date,'N',
	        NULL ,TRUNC(psg.date1)), --need_by_date
         DECODE(PO_PDOI_PARAMS.g_profile.group_by_ship_to_location,'N',
	        NULL,psg.num3), --ship_to_loc_id
         DECODE(PO_PDOI_PARAMS.g_profile.group_by_ship_to_location,'N',
	        NULL,psg.num2 ), --ship_to_org_id
         psg.char3, --consigned_flag
         plg.transaction_reason_code,
         plg.contract_id,
         psg.char1,--supplier_ref_number
	 plg.oke_contract_header_id,
         plg.oke_contract_version_id,
         plg.vendor_product_num,
	 plg.bid_number,
	 plg.bid_line_number,
	 plg.preferred_grade, -- Bug#18007765
	 COUNT(*)
   FROM  po_lines_gt plg,
         po_session_gt psg
   WHERE plg.po_line_id = psg.num1 --Joining the intf_line_id
   AND   plg.line_num IS NOT NULL
   AND   psg.KEY = p_key
   GROUP BY
        plg.po_header_id,
         plg.line_num,
      --<Bug#17788591 START: Matching basis and
      -- purchase basis should be compared
      -- instead of line type>
	-- plg.line_type_id,
	 plg.purchase_basis,
	 plg.matching_basis,
      --<Bug#17788591 END>
	 plg.item_id,
         plg.item_description,
         plg.item_revision,
	 plg.category_id,
         plg.unit_meas_lookup_code,
	 plg.from_header_id,
	 plg.from_line_id,
	 DECODE(PO_PDOI_PARAMS.g_profile.group_by_need_by_date,'N',
	        NULL ,  TRUNC(psg.date1)), --need_by_date
         DECODE(PO_PDOI_PARAMS.g_profile.group_by_ship_to_location,'N',
	        NULL,psg.num3), --ship_to_loc_id
         DECODE(PO_PDOI_PARAMS.g_profile.group_by_ship_to_location,'N',
	        NULL,psg.num2 ), --ship_to_org_id
         psg.char3, --consigned_flag
         plg.transaction_reason_code,
         plg.contract_id,
         psg.char1,--supplier_ref_number
	 plg.oke_contract_header_id,
         plg.oke_contract_version_id,
         plg.vendor_product_num,
	 plg.bid_number,
	 plg.bid_line_number,
	 plg.preferred_grade -- Bug#18007765
    )
    GROUP BY po_header_id,line_num
    HAVING COUNT(line_num) > 1;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_po_header_id_tbl', l_po_header_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_line_num_tbl', l_line_num_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_cnt_tbl', l_cnt_tbl);
  END IF;

  --SQL What: Getting all the index values for
  --          all the lines identified above
  --SQL Why: Need to reject all the lines identifed

  SELECT psg.index_num1
  BULK COLLECT INTO   l_index_tbl
  FROM(SELECT column_value val ,ROWNUM rn
       FROM  TABLE(l_po_header_id_tbl)) po_hdr,
       (SELECT column_value val, ROWNUM rn
       FROM  TABLE(l_line_num_tbl)) line_num,
       po_session_gt psg
  WHERE  psg.KEY = p_key
  AND   po_hdr.rn = line_num.rn
  AND   psg.num5 = po_hdr.val --- po_header_id join
  AND   psg.num6 = line_num.val; -- line_num join


  IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_index_tbl', l_index_tbl);
  END IF;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP

    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Error on index', l_index);
      PO_LOG.stmt(d_module, d_position, 'Po Header Id', x_lines.hd_po_header_id_tbl(l_index));
      PO_LOG.stmt(d_module, d_position, 'line num',x_lines.line_num_tbl(l_index));
    END IF;

    PO_PDOI_ERR_UTL.add_fatal_error
    (
      p_interface_header_id  => x_lines.intf_header_id_tbl(l_index),
      p_interface_line_id    => x_lines.intf_line_id_tbl(l_index),
      p_error_message_name   => 'PO_PDOI_GRP_LINE_NUM_UNIQUE',
      p_table_name           => 'PO_LINES_INTERFACE',
      p_column_name          => 'LINE_NUM',
      p_column_value         =>  x_lines.line_num_tbl(l_index),
      p_token2_name          => 'VALUE',
      p_token2_value         =>  x_lines.line_num_tbl(l_index)
     );

     x_lines.error_flag_tbl(l_index) := FND_API.g_TRUE;
     x_processing_row_tbl.DELETE(l_index);
  END LOOP;

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
END reject_lines_on_line_num;
-----------------------------------------------------------------------
--Start of Comments
--Name: match_lines_on_draft
--Function: The procedure will match all the lines
--          in the draft table
--Parameters:
--IN OUT:
--  x_lines
--    record which stores all the line rows within the batch;
--  x_processing_row_tbl
--    Table to indicate the lines has been processed or not
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE  match_lines_on_draft
( p_key                IN po_session_gt.key%TYPE,
  x_lines              IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
)IS

  d_api_name CONSTANT VARCHAR2(30) := 'match_lines_on_draft';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- hold the key value which is used to identify rows in temp table
  l_key           po_session_gt.key%TYPE;

  l_index_tbl             PO_TBL_NUMBER;
  l_match_line_num_tbl    PO_TBL_NUMBER;
  l_match_line_id_tbl     PO_TBL_NUMBER;

  l_index                 NUMBER;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 10;
  -- get new key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of rows to be processed', x_processing_row_tbl.COUNT);
  END IF;


  FORALL i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key, num1, num2, num3)
    SELECT DISTINCT l_key,
           x_processing_row_tbl(i),
           pld.line_num,
           pld.po_line_id
    FROM   po_lines_draft_all pld,
           po_lines_interface pli
    WHERE  draft_id = x_lines.draft_id_tbl(i)
    AND    pli.processing_id = po_pdoi_params.g_processing_id
    AND    pli.po_line_id = pld.po_line_id
    AND    pli.po_line_id IS NOT null
    AND    pld.po_header_id = x_lines.hd_po_header_id_tbl(i)
    AND    NVL(delete_flag, 'N') <> 'Y'
    --<Bug#17788591 START: Matching basis and
    -- purchase basis should be compared
    -- instead of line type>
    -- AND    pld.line_type_id = x_lines.line_type_id_tbl(i)
    AND    pld.purchase_basis = x_lines.purchase_basis_tbl(i)
    AND    pld.matching_basis = x_lines.matching_basis_tbl(i)
    --<Bug#17788591 END>
    AND    ((x_lines.line_num_tbl(i) IS NULL
             ) OR
	    pld.line_num = x_lines.line_num_tbl(i)
           )
    AND    ((pld.item_id IS NULL AND
               x_lines.item_id_tbl(i) IS NULL
             ) OR
	    pld.item_id = x_lines.item_id_tbl(i)
           )
    AND    ((pld.item_description IS NULL AND
   	       x_lines.item_desc_tbl(i) IS NULL
	     ) OR
	     pld.item_description = x_lines.item_desc_tbl(i)
	   )
    AND    ((pld.category_id IS NULL AND
   	       x_lines.category_id_tbl(i) IS NULL
	     ) OR
	     pld.category_id = x_lines.category_id_tbl(i)
	   )
    AND   ((pld.item_revision IS NULL AND
	     x_lines.item_revision_tbl(i) IS NULL
	    ) OR
	   pld.item_revision = x_lines.item_revision_tbl(i)
	   )
    AND    pld.unit_meas_lookup_code = x_lines.unit_of_measure_tbl(i)
    AND    ((pld.preferred_grade IS NULL AND
	     x_lines.preferred_grade_tbl(i) IS NULL
	     ) OR
	     pld.preferred_grade = x_lines.preferred_grade_tbl(i)
	    )
    AND    ((pld.from_header_id IS NULL AND
     	     x_lines.from_header_id_tbl(i) IS NULL
	     ) OR
	     pld.from_header_id =  x_lines.from_header_id_tbl(i)
	    )
    AND    ((pld.from_line_id IS NULL AND
 	      x_lines.from_line_id_tbl(i) IS NULL
	     ) OR
	     pld.from_line_id =  x_lines.from_line_id_tbl(i)
	    )
    AND   (PO_PDOI_PARAMS.g_profile.group_by_need_by_date = 'N'
           OR
	   ( (pli.need_by_date IS NULL AND
	        x_lines.need_by_date_tbl(i) IS NULL
	      ) OR
              TRUNC(pli.need_by_date)= TRUNC(x_lines.need_by_date_tbl(i))
            )
           )
     AND   ( PO_PDOI_PARAMS.g_profile.group_by_ship_to_location = 'N'
 	     OR
             ( ( pli.ship_to_organization_id IS NULL AND
	           x_lines.ship_to_org_id_tbl(i) IS NULL
               )OR
	       pli.ship_to_organization_id = x_lines.ship_to_org_id_tbl(i)
             )
	   )
     AND   ( PO_PDOI_PARAMS.g_profile.group_by_ship_to_location = 'N'
             OR
             ( ( pli.ship_to_location_id IS NULL AND
	           x_lines.ship_to_loc_id_tbl(i) IS NULL
               )OR
	       pli.ship_to_location_id = x_lines.ship_to_loc_id_tbl(i)
             )
	   )
      AND  ( ( pli.consigned_flag IS NULL AND
	           x_lines.consigned_flag_tbl(i) IS NULL
               )OR
	       pli.consigned_flag = x_lines.consigned_flag_tbl(i)
             )
      AND   ( ( pld.transaction_reason_code IS NULL AND
 	      x_lines.transaction_reason_code_tbl(i) IS NULL
	      ) OR
	       pld.transaction_reason_code = x_lines.transaction_reason_code_tbl(i)
	    )
      AND  ( ( pld.contract_id IS NULL AND
   	      x_lines.contract_id_tbl(i) IS NULL
 	     ) OR
	      pld.contract_id = x_lines.contract_id_tbl(i)
	    )
      AND   ( ( pld.supplier_ref_number IS NULL AND
  	        x_lines.supplier_ref_number_tbl(i) IS NULL
	      ) OR
	      pld.supplier_ref_number= x_lines.supplier_ref_number_tbl(i)
	    )
      AND  ( ( pld.oke_contract_header_id IS NULL AND
 	       x_lines.oke_contract_header_id_tbl(i) IS NULL
	      ) OR
	      pld.oke_contract_header_id = x_lines.oke_contract_header_id_tbl(i)
	   )
      AND  ( ( pld.oke_contract_version_id IS NULL AND
 	       x_lines.oke_contract_version_id_tbl(i) IS NULL
	     ) OR
	     pld.oke_contract_version_id = x_lines.oke_contract_version_id_tbl(i)
	    )
      AND  ( ( pld.vendor_product_num IS NULL AND
  	      x_lines.vendor_product_num_tbl(i) IS NULL
	     ) OR
	     pld.vendor_product_num = x_lines.vendor_product_num_tbl(i)
	    )
      AND  ( ( pld.bid_number IS NULL AND
   	      x_lines.bid_number_tbl(i) IS NULL
	     ) OR
	     pld.bid_number = x_lines.bid_number_tbl(i)
	    )
      AND  ( ( pld.bid_line_number IS NULL AND
   	      x_lines.bid_line_number_tbl(i) IS NULL
	     ) OR
	     pld.bid_line_number = x_lines.bid_line_number_tbl(i)
	    );

  d_position := 20;


  --Get the matched result from temp table
  DELETE FROM po_session_gt
  WHERE KEY = l_key
  RETURNING num1,num2,num3
  BULK COLLECT INTO l_index_tbl,l_match_line_num_tbl,l_match_line_id_tbl;

  IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_index_tbl', l_index_tbl);
     PO_LOG.stmt(d_module, d_position, 'l_match_line_num_tbl', l_match_line_num_tbl);
     PO_LOG.stmt(d_module, d_position, 'l_match_line_id_tbl', l_match_line_id_tbl);
  END IF;

  -- set the po_line_id and line_num from matching line
  -- so there is no new line created from this row
  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'matched po line id', l_match_line_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'matched line num', l_match_line_num_tbl(i));
    END IF;

    x_lines.po_line_id_tbl(l_index) := l_match_line_id_tbl(i);
    x_lines.line_num_tbl(l_index) := l_match_line_num_tbl(i);
    x_lines.action_tbl(l_index)   := PO_PDOI_CONSTANTS.g_ACTION_MATCH;
    -- delete the corresponding node so the line won't be processed again
    x_processing_row_tbl.DELETE(l_index);
  END LOOP;

  d_position:= 30;
  -- If  Line number provided in the batch exists in draft and line grouping criteria does not match
  -- the line should be errored out.
  -- If matching criteria is not matched the action in x_lines will still be ADD

  l_index_tbl.delete;

  FORALL i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key,num1)
  SELECT l_key,
         x_processing_row_tbl(i)
  FROM   po_lines_draft_all pld
  WHERE  draft_id = x_lines.draft_id_tbl(i)
  AND    pld.po_header_id = x_lines.hd_po_header_id_tbl(i)
  AND    NVL(delete_flag, 'N') <> 'Y'
  AND    pld.line_num = x_lines.line_num_tbl(i)
  AND    x_lines.action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_ADD;

  DELETE FROM po_session_gt
  WHERE KEY = l_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

  FOR i IN 1..l_index_tbl.COUNT
  LOOP

   l_index := l_index_tbl(i);

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Error on index', l_index);
     PO_LOG.stmt(d_module, d_position, 'Po Header Id', x_lines.hd_po_header_id_tbl(l_index));
     PO_LOG.stmt(d_module, d_position, 'line num',x_lines.line_num_tbl(l_index));
   END IF;

    PO_PDOI_ERR_UTL.add_fatal_error
    (
      p_interface_header_id  => x_lines.intf_header_id_tbl(l_index),
      p_interface_line_id    => x_lines.intf_line_id_tbl(l_index),
      p_error_message_name   => 'PO_PDOI_GRP_LINE_NUM_UNIQUE',
      p_table_name           => 'PO_LINES_INTERFACE',
      p_column_name          => 'LINE_NUM',
      p_column_value         =>  x_lines.line_num_tbl(l_index),
      p_token2_name          => 'VALUE',
      p_token2_value         =>  x_lines.line_num_tbl(l_index)
     );

     x_lines.error_flag_tbl(l_index) := FND_API.g_TRUE;
     x_processing_row_tbl.DELETE(l_index);
  END LOOP;

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
END match_lines_on_draft;
-----------------------------------------------------------------------
--Start of Comments
--Name: match_lines_on_txn
--Function: The procedure will match all the lines having requisition
--          reference with existing PO header
--Parameters:
--IN OUT:
--  x_lines
--    record which stores all the line rows within the batch;
--  x_processing_row_tbl
--    Table to indicate the lines has been processed or not
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE  match_lines_on_txn
( x_lines              IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
)IS

  d_api_name CONSTANT VARCHAR2(30) := 'match_lines_on_txn';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  -- hold the key value which is used to identify rows in temp table
  l_key           po_session_gt.key%TYPE;
  l_po_header_id  po_headers_all.po_header_id%TYPE;
  l_line_num      po_lines_all.line_num%TYPE;
  l_index         NUMBER;

  l_match_line_num_tbl     PO_TBL_NUMBER;
  l_match_line_id_tbl      PO_TBL_NUMBER;
  l_index_tbl              PO_TBL_NUMBER;
  l_po_header_id_tbl       PO_TBL_NUMBER;

   -- hash table of po_line_id based on po_header_id and line num
  TYPE line_ref_internal_type IS TABLE OF NUMBER INDEX BY VARCHAR2(32);
  TYPE line_ref_type IS TABLE OF line_ref_internal_type INDEX BY PLS_INTEGER;
  l_line_reference_tbl line_ref_type;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of rows to be processed', x_processing_row_tbl.COUNT);
  END IF;

  IF x_processing_row_tbl.COUNT = 0 THEN
    RETURN;
  END IF;

  d_position := 10;
  -- get new key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  FORALL i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key,num1,num2,num3,num4)
  SELECT l_key,
         x_processing_row_tbl(i),
	 line_num,
	 po_line_id,
	 po_header_id
  FROM  po_lines pol1
  WHERE pol1.po_header_id = x_lines.hd_po_header_id_tbl(i)
  AND   NVL(pol1.CANCEL_FLAG,'N') = 'N'
  AND   NVL(pol1.closed_code,'OPEN') <> 'FINALLY CLOSED'
  AND   x_lines.hd_action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_UPDATE
  AND   x_lines.requisition_line_id_tbl(i) IS NOT NULL
  AND   line_num =
   (SELECT /*+ NO_UNNEST */  MIN(line_num)
          FROM   po_lines pol
	  WHERE  pol.po_header_id = x_lines.hd_po_header_id_tbl(i)
	  AND    NVL(pol.CANCEL_FLAG,'N') = 'N'
	  AND    NVL(pol.closed_code,'OPEN') <> 'FINALLY CLOSED'
         --<Bug#17788591 START: Matching basis and
         -- purchase basis should be compared
         -- instead of line type>
         -- AND  pol.line_type_id = x_lines.line_type_id_tbl(i)
          AND  pol.purchase_basis = x_lines.purchase_basis_tbl(i)
          AND  pol.matching_basis = x_lines.matching_basis_tbl(i)
         --<Bug#17788591 END>
	  AND   (( x_lines.line_num_tbl(i) IS NULL
		  ) OR
		    pol.line_num = x_lines.line_num_tbl(i)
		)
          AND   ((pol.item_id IS NULL AND
		       x_lines.item_id_tbl(i) IS NULL
		     ) OR
		    pol.item_id = x_lines.item_id_tbl(i)
		)
   	--<Bug#17788591 : Ignore the item description when being called
	-- from autocreate manual mode
	  AND   ( ( PO_PDOI_PARAMS.g_request.calling_module  =
	            PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE
		    AND pol.line_num = x_lines.line_num_tbl(i)
                   )
		   OR
	          (pol.item_description IS NULL AND
	            x_lines.item_desc_tbl(i) IS NULL
		  ) OR
		   ( pol.item_description = x_lines.item_desc_tbl(i)
                    )
		)
	  AND   ((pol.category_id IS NULL AND
	            x_lines.category_id_tbl(i) IS NULL
		  ) OR
		   pol.category_id = x_lines.category_id_tbl(i)
		)
          AND   ((pol.item_revision IS NULL AND
		   x_lines.item_revision_tbl(i) IS NULL
		  ) OR
		 pol.item_revision = x_lines.item_revision_tbl(i)
		)
          AND    pol.unit_meas_lookup_code = x_lines.unit_of_measure_tbl(i)
	  AND   ((pol.preferred_grade IS NULL AND
	           x_lines.preferred_grade_tbl(i) IS NULL
		  ) OR
		  pol.preferred_grade = x_lines.preferred_grade_tbl(i)
		)
          AND  ((pol.from_header_id IS NULL AND
		     x_lines.from_header_id_tbl(i) IS NULL
		     ) OR
		     pol.from_header_id =  x_lines.from_header_id_tbl(i)
		    )
          AND    ((pol.from_line_id IS NULL AND
	             x_lines.from_line_id_tbl(i) IS NULL
		   ) OR
		   pol.from_line_id =  x_lines.from_line_id_tbl(i)
		  )
          AND   TRUNC(NVL(pol.expiration_date,SYSDATE+1)) >= TRUNC(SYSDATE)
          AND   (PO_PDOI_PARAMS.g_profile.group_by_need_by_date = 'N'
	           OR
		   ( ( x_lines.need_by_date_tbl(i) IS NULL  AND
                       EXISTS
		        (SELECT 1
		         FROM  po_line_locations poll
                         WHERE need_by_date IS NULL
		         AND poll.po_line_id = pol.po_line_id
		         )
	              )
		      OR  EXISTS
		        (SELECT 1
		         FROM   po_line_locations poll
		         WHERE  poll.po_line_id = pol.po_line_id
  		         AND   TRUNC(NVL(poll.need_by_date,SYSDATE)) =
				   TRUNC(x_lines.need_by_date_tbl(i))
		        )
		    )
                 )
	   AND   ( PO_PDOI_PARAMS.g_profile.group_by_ship_to_location = 'N'
		      OR EXISTS
		     ( SELECT 1
		       FROM   po_line_locations poll
		       WHERE  poll.po_line_id = pol.po_line_id
		       AND    NVL(poll.ship_to_organization_id,-99) = NVL(x_lines.ship_to_org_id_tbl(i),-99)
		     )
	          )
	   AND   ( PO_PDOI_PARAMS.g_profile.group_by_ship_to_location = 'N'
		      OR EXISTS
		     ( SELECT 1
		       FROM   po_line_locations poll
		       WHERE  poll.po_line_id = pol.po_line_id
		       AND    NVL(poll.ship_to_location_id,-99) = NVL(x_lines.ship_to_loc_id_tbl(i),-99)
		     )
		   )
	    AND  EXISTS
		      ( SELECT 1
			FROM   po_line_locations poll
			WHERE  poll.po_line_id = pol.po_line_id
			AND    NVL(poll.consigned_flag,'N') = NVL(x_lines.consigned_flag_tbl(i),'N')
		      )
	    AND   ( ( pol.transaction_reason_code IS NULL AND
		      x_lines.transaction_reason_code_tbl(i) IS NULL
		      ) OR
		       pol.transaction_reason_code = x_lines.transaction_reason_code_tbl(i)
		    )
	    AND  ( ( pol.contract_id IS NULL AND
		      x_lines.contract_id_tbl(i) IS NULL
		    ) OR
		     pol.contract_id = x_lines.contract_id_tbl(i)
		 )
	    AND   ( ( pol.supplier_ref_number IS NULL AND
			x_lines.supplier_ref_number_tbl(i) IS NULL
		      ) OR
		      pol.supplier_ref_number= x_lines.supplier_ref_number_tbl(i)
		    )
	    AND  ( ( pol.oke_contract_header_id IS NULL AND
		       x_lines.oke_contract_header_id_tbl(i) IS NULL
		      ) OR
		      pol.oke_contract_header_id = x_lines.oke_contract_header_id_tbl(i)
		 )
	    AND  ( ( pol.oke_contract_version_id IS NULL AND
		       x_lines.oke_contract_version_id_tbl(i) IS NULL
		     ) OR
		     pol.oke_contract_version_id = x_lines.oke_contract_version_id_tbl(i)
	         )
	    AND  ( ( pol.vendor_product_num IS NULL AND
		      x_lines.vendor_product_num_tbl(i) IS NULL
		     ) OR
		     pol.vendor_product_num = x_lines.vendor_product_num_tbl(i)
		  )
            AND  ( ( pol.bid_number IS NULL AND
		      x_lines.bid_number_tbl(i) IS NULL
		     ) OR
		     pol.bid_number = x_lines.bid_number_tbl(i)
		 )
            AND  ( ( pol.bid_line_number IS NULL AND
		      x_lines.bid_line_number_tbl(i) IS NULL
		     ) OR
		     pol.bid_line_number = x_lines.bid_line_number_tbl(i)
		 )
         );

  --Get the matched result from temp table
  DELETE FROM po_session_gt
  WHERE KEY = l_key
  RETURNING num1,num2,num3,num4
  BULK COLLECT INTO l_index_tbl,l_match_line_num_tbl,l_match_line_id_tbl,l_po_header_id_tbl;

  IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_index_tbl', l_index_tbl);
     PO_LOG.stmt(d_module, d_position, 'l_match_line_num_tbl', l_match_line_num_tbl);
     PO_LOG.stmt(d_module, d_position, 'l_match_line_id_tbl', l_match_line_id_tbl);
     PO_LOG.stmt(d_module, d_position, 'l_po_header_id_tbl', l_po_header_id_tbl);
  END IF;

  -- set the po_line_id and line_num from matching line

  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);
    l_po_header_id := l_po_header_id_tbl(i);
    l_line_num := l_match_line_num_tbl(i);

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'index', l_index);
      PO_LOG.stmt(d_module, d_position, 'matched po line id', l_match_line_id_tbl(i));
      PO_LOG.stmt(d_module, d_position, 'matched line num', l_match_line_num_tbl(i));
    END IF;

     --More than one req reference line is matched to same PO line
     -- Only one line should have action as UPDATE
     IF (l_line_reference_tbl.EXISTS(l_po_header_id) AND
          l_line_reference_tbl(l_po_header_id).EXISTS(l_line_num)) THEN

        d_position := 20;

        x_lines.po_line_id_tbl(l_index) :=
          l_line_reference_tbl(l_po_header_id)(l_line_num);
        x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_MATCH;
        x_lines.line_num_tbl(l_index) := l_match_line_num_tbl(i);

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'match found for update line');
          PO_LOG.stmt(d_module, d_position, 'new po line id',
                      x_lines.po_line_id_tbl(l_index));
        END IF;
    ELSE

      d_position := 30;

      x_lines.line_num_tbl(l_index) := l_match_line_num_tbl(i);
      x_lines.po_line_id_tbl(l_index) := l_match_line_id_tbl(i);
      x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_UPDATE;

      l_line_reference_tbl(l_po_header_id)(l_line_num) :=
         l_match_line_id_tbl(i);

    END IF;
    -- delete the corresponding node so the line won't be processed again
    x_processing_row_tbl.DELETE(l_index);
  END LOOP;

  l_index_tbl.DELETE ;

  d_position := 40;

  --Error all the lines which could not find match
  --from above query if line num is not null
  -- and match cannot be found in the current batch

  IF x_processing_row_tbl.COUNT = 0 THEN
    RETURN;
  END IF;

  FORALL i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key,num1)
  SELECT l_key,
         x_processing_row_tbl(i)
  FROM po_lines pol
  WHERE x_lines.hd_action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_UPDATE
  AND   pol.po_header_id = x_lines.hd_po_header_id_tbl(i)
  AND   pol.line_num =  x_lines.line_num_tbl(i)
  AND   x_lines.requisition_line_id_tbl(i) IS NOT NULL
  AND   x_lines.line_num_tbl(i) IS NOT NULL
  AND   x_lines.action_tbl(i) = PO_PDOI_CONSTANTS.g_ACTION_ADD
  AND   NOT EXISTS (SELECT 1
                    FROM  po_lines_gt
		    WHERE line_num = x_lines.line_num_tbl(i)
                    );

  d_position := 50;

  DELETE po_session_gt
  WHERE KEY = l_key
  RETURNING num1 BULK COLLECT INTO l_index_tbl;

 IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'l_index_tbl', l_index_tbl);
  END IF;


  FOR i IN 1..l_index_tbl.COUNT
  LOOP

    l_index := l_index_tbl(i);

    -- check if match does not exists in current batch and then throw an error

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Error on index', l_index);
     PO_LOG.stmt(d_module, d_position, 'Po Header Id', x_lines.hd_po_header_id_tbl(l_index));
     PO_LOG.stmt(d_module, d_position, 'line num',x_lines.line_num_tbl(l_index));
   END IF;

    PO_PDOI_ERR_UTL.add_fatal_error
    (
      p_interface_header_id  => x_lines.intf_header_id_tbl(l_index),
      p_interface_line_id    => x_lines.intf_line_id_tbl(l_index),
      p_error_message_name   => 'PO_PDOI_REQ_LINE_MISMATCH',
      p_table_name           => 'PO_LINES_INTERFACE',
      p_column_name          => 'LINE_NUM',
      p_column_value         =>  x_lines.line_num_tbl(l_index),
      p_token2_name          => 'VALUE',
      p_token2_value         =>  x_lines.line_num_tbl(l_index)
     );

    x_lines.error_flag_tbl(l_index) := FND_API.g_TRUE;
    x_processing_row_tbl.DELETE(l_index);
  END LOOP;

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
END match_lines_on_txn;
-----------------------------------------------------------------------
--Start of Comments
--Name: match_lines_on_interface
--Function: The procedure will match all the lines within the batch in the
--         in the interface tables
--Parameters:
--IN:
-- p_key : Session key to fetch records from po_session_gt table
--IN OUT:
--  x_lines
--    record which stores all the line rows within the batch;
--  x_processing_row_tbl
--    Table to indicate the lines has been processed or not
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE  match_lines_on_interface
( p_key                IN po_session_gt.key%TYPE,
  x_lines              IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type,
  x_processing_row_tbl IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
)IS

  d_api_name CONSTANT VARCHAR2(30) := 'match_lines_on_interface';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

   -- hold the key value which is used to identify rows in temp table
  l_key           po_session_gt.key%TYPE;
  l_po_header_id  po_headers_all.po_header_id%TYPE;
  l_line_num      po_lines_all.line_num%TYPE;
  l_index         NUMBER;
  l_match_index   NUMBER;

  l_index_tbl              PO_TBL_NUMBER;
  l_match_index_tbl        PO_TBL_NUMBER;
  l_processed_index_tbl    PO_TBL_NUMBER;
  l_line_num_tbl           PO_TBL_NUMBER;

   -- hash table of po_line_id based on po_header_id and line num
  TYPE line_ref_internal_type IS TABLE OF NUMBER INDEX BY VARCHAR2(32);
  TYPE line_ref_type IS TABLE OF line_ref_internal_type INDEX BY PLS_INTEGER;
  l_line_reference_tbl line_ref_type;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;


  d_position := 10;
  -- get new key value for po_session_gt table
  l_key := PO_CORE_S.get_session_gt_nextval;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'Number of rows to be processed', x_processing_row_tbl.COUNT);
  END IF;

  FORALL i IN INDICES OF x_processing_row_tbl
  INSERT INTO po_session_gt(key,num1)
  SELECT l_key,
         x_processing_row_tbl(i)
  FROM   DUAL;

  DELETE FROM po_session_gt
  WHERE KEY = l_key
  RETURNING num1 BULK COLLECT INTO l_processed_index_tbl;

  SELECT psg.index_num1,
         plg.line_num,
         first_value(psg.index_num1)
	 OVER(PARTITION BY
	        plg.po_header_id,
		plg.line_num,
              --<Bug#17788591 START: Matching basis and
              -- purchase basis should be compared
              -- instead of line type>
	      -- plg.line_type_id,
        	plg.purchase_basis,
	        plg.matching_basis,
              --<Bug#17788591 END>
                plg.item_id,
                DECODE( PO_PDOI_PARAMS.g_request.calling_module,
		       PO_PDOI_CONSTANTS.g_CALL_MOD_AUTOCREATE ,
		       DECODE(plg.line_num,NULL,plg.item_description,NULL),
		     plg.item_description),
                plg.item_revision,
                plg.category_id,
                plg.unit_meas_lookup_code,
                plg.from_header_id,
                plg.from_line_id,
                DECODE(PO_PDOI_PARAMS.g_profile.group_by_need_by_date,'N',
	               NULL ,TRUNC(psg.date1)), --need_by_date
                DECODE(PO_PDOI_PARAMS.g_profile.group_by_ship_to_location,'N',
                       NULL,psg.num3), --ship_to_loc_id
                DECODE(PO_PDOI_PARAMS.g_profile.group_by_ship_to_location,'N',
	               NULL,psg.num2 ), --ship_to_org_id
                psg.char3, --consigned_flag
                plg.transaction_reason_code,
                plg.contract_id,
                psg.char1,--supplier_ref_number
                plg.oke_contract_header_id,
                plg.oke_contract_version_id,
                plg.vendor_product_num,
                plg.bid_number,
                plg.bid_line_number,
                plg.preferred_grade -- Bug#18007765
   	     ORDER BY psg.index_num1
	     )match_index
    BULK  COLLECT INTO
     l_index_tbl,
     l_line_num_tbl,
     l_match_index_tbl
    FROM po_lines_gt plg , po_session_gt psg,
          (SELECT column_value val
	    FROM TABLE(l_processed_index_tbl)) index_tbl
    WHERE  plg.po_line_id = psg.num1 --Joining the intf_line_id
    AND    psg.KEY = p_key
    AND    psg.index_num1 = index_tbl.val;


   IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'l_index_tbl', l_index_tbl);
      PO_LOG.stmt(d_module, d_position, 'l_match_index_tbl', l_match_index_tbl);
   END IF;


  FOR i IN 1..l_index_tbl.COUNT
  LOOP
    l_index := l_index_tbl(i);
    l_match_index := l_match_index_tbl(i);

    IF l_index = l_match_index THEN

       x_lines.po_line_id_tbl(l_index) := PO_PDOI_MAINPROC_UTL_PVT.get_next_po_line_id;
       x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_ADD;
         x_lines.line_num_tbl(l_index) :=
           NVL(l_line_num_tbl(i),
	   PO_PDOI_MAINPROC_UTL_PVT.get_next_line_num(x_lines.hd_po_header_id_tbl(l_index)));
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'index', l_index);
        PO_LOG.stmt(d_module, d_position, 'assigned po line id',
                    x_lines.po_line_id_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'assigned line num', x_lines.line_num_tbl(l_index));
      END IF;
    ELSE

      x_lines.po_line_id_tbl(l_index) := x_lines.po_line_id_tbl(l_match_index);
      x_lines.line_num_tbl(l_index) := x_lines.line_num_tbl(l_match_index);
      x_lines.action_tbl(l_index) := PO_PDOI_CONSTANTS.g_ACTION_MATCH;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'index', l_index);
        PO_LOG.stmt(d_module, d_position, 'match index', l_match_index);
        PO_LOG.stmt(d_module, d_position, 'matched po line id',
                  x_lines.po_line_id_tbl(l_index));
        PO_LOG.stmt(d_module, d_position, 'matched line num', x_lines.line_num_tbl(l_index));
      END IF;
    END IF;
  END LOOP;

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
END match_lines_on_interface;
-----------------------------------------------------------------------
--Start of Comments
-- <PDOI Enhancement Bug#17063664>
--Name: check_pcard_same
--Function: This function checks if p_card is same for all lines in a PO.
--
--Parameters:
--IN OUT: x_lines
--End of Comments
------------------------------------------------------------------------
PROCEDURE check_pcard_same
               (x_lines         IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type)
IS
  d_api_name CONSTANT VARCHAR2(30) := 'check_pcard_same';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key       po_session_gt.key%TYPE;
  l_index     NUMBER;

  --Index table
  l_index_tbl           DBMS_SQL.NUMBER_TABLE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

    -- pick a new key for temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize index table
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size      => x_lines.rec_count,
    x_num_list  => l_index_tbl
  );

  d_position := 10;

  -- Insert records where header is already existing in draft
  -- and p_card is different from p_card on req line
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key,num1)
    SELECT DISTINCT l_key,
           l_index_tbl(i)
    FROM po_headers_draft_all phd,
         po_requisition_lines_all prl,
         po_requisition_headers_all prh
    WHERE phd.draft_id = x_lines.draft_id_tbl(i)
      AND phd.po_header_id = x_lines.hd_po_header_id_tbl(i)
      AND x_lines.requisition_line_id_tbl(i) IS NOT NULL
      AND prl.requisition_line_id =  x_lines.requisition_line_id_tbl(i)
      AND prh.requisition_header_id = prl.requisition_header_id
      AND ((prh.pcard_id IS NULL
           AND phd.pcard_id IS NOT NULL)
          OR
           (prh.pcard_id IS NOT NULL
            AND phd.pcard_id IS NULL)
          OR
           (prh.pcard_id = -9999 --<Supplier pcard compare with pcard on supplier>
            AND NOT EXISTS (SELECT acs.card_id
                            FROM   ap_card_suppliers acs
                            WHERE  acs.vendor_id = phd.vendor_id
                            AND    acs.vendor_site_id = phd.vendor_site_id
                            AND acs.card_id = phd.pcard_id))
          OR
          (prh.pcard_id <> -9999
           AND prh.pcard_id IS NOT NULL
           AND phd.pcard_id IS NOT NULL
           AND prh.pcard_id <> phd.pcard_id));

  -- Insert records where header is already existing in transaction table
  -- and p_card is different from p_card on req line
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key,num1)
    SELECT DISTINCT l_key,
           l_index_tbl(i)
    FROM po_headers_all ph,
         po_requisition_lines_all prl,
         po_requisition_headers_all prh
    WHERE ph.po_header_id = x_lines.hd_po_header_id_tbl(i)
      AND x_lines.requisition_line_id_tbl(i) IS NOT NULL
      AND prl.requisition_line_id =  x_lines.requisition_line_id_tbl(i)
      AND prh.requisition_header_id = prl.requisition_header_id
      AND ((prh.pcard_id IS NULL
           AND ph.pcard_id IS NOT NULL)
          OR
           (prh.pcard_id IS NOT NULL
            AND ph.pcard_id IS NULL)
          OR
           (prh.pcard_id = -9999 --<Supplier pcard compare with pcard on supplier>
            AND NOT EXISTS (SELECT acs.card_id
                            FROM   ap_card_suppliers acs
                            WHERE  acs.vendor_id = ph.vendor_id
                            AND    acs.vendor_site_id = ph.vendor_site_id
                            AND    acs.card_id =  ph.pcard_id))
          OR
          (prh.pcard_id <> -9999
           AND prh.pcard_id IS NOT NULL
           AND ph.pcard_id IS NOT NULL
           AND prh.pcard_id <> ph.pcard_id));

  l_index_tbl.DELETE;

   SELECT DISTINCT num1
   BULK COLLECT INTO l_index_tbl
   FROM po_session_gt
   WHERE KEY = l_key;

   DELETE FROM po_session_gt
    WHERE KEY = l_key;

 --Mark error flag for all the lines as true identified
 -- in above queries
 FOR i IN 1..l_index_tbl.count
 LOOP

   l_index := l_index_tbl(i);

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Error on index', l_index);
     PO_LOG.stmt(d_module, d_position, 'requisition line num',x_lines.requisition_line_id_tbl(l_index));
   END IF;

   PO_PDOI_ERR_UTL.add_fatal_error
    (
      p_interface_header_id  => x_lines.intf_header_id_tbl(l_index),
      p_interface_line_id    => x_lines.intf_line_id_tbl(l_index),
      p_error_message_name   => 'PO_PDOI_REQ_PCARD_MIS',
      p_table_name           => 'PO_LINES_INTERFACE',
      p_column_name          => 'REQUISITION_LINE_ID',
      p_column_value         =>  x_lines.requisition_line_id_tbl(l_index),
      p_token2_name          => 'VALUE',
      p_token2_value         =>  x_lines.requisition_line_id_tbl(l_index)
    );

    x_lines.error_flag_tbl(i) := FND_API.g_TRUE;

  END LOOP;

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
END check_pcard_same;

-----------------------------------------------------------------------
--Start of Comments
-- <PDOI Enhancement Bug#17063664>
--Name: check_emergency_po_same
--Function: This function checks if emergency_po_num is same for all lines in a PO.
--
--Parameters:
--IN OUT: x_lines
--End of Comments
------------------------------------------------------------------------
PROCEDURE check_emergency_po_same
               (x_lines         IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type)
IS
  d_api_name CONSTANT VARCHAR2(30) := 'check_emergency_po_same';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_key       po_session_gt.key%TYPE;
  l_index     NUMBER;

  --Index table
  l_index_tbl           DBMS_SQL.NUMBER_TABLE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

    -- pick a new key for temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- initialize index table
  PO_PDOI_UTL.generate_ordered_num_list
  (
    p_size      => x_lines.rec_count,
    x_num_list  => l_index_tbl
  );

  d_position := 10;

  -- Insert records where header is already existing in draft
  -- and segment1 is different from emergency_po_num on req line
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key,num1)
    SELECT DISTINCT l_key,
           l_index_tbl(i)
    FROM po_headers_draft_all phd,
         po_requisition_lines_all prl,
         po_requisition_headers_all prh
    WHERE phd.draft_id = x_lines.draft_id_tbl(i)
      AND phd.po_header_id = x_lines.hd_po_header_id_tbl(i)
      AND prl.requisition_line_id =  x_lines.requisition_line_id_tbl(i)
      AND prh.requisition_header_id = prl.requisition_header_id
      AND prh.emergency_po_num IS NOT NULL
      AND prh.emergency_po_num <> phd.segment1;

  -- Insert records where header is already existing in transaction table
  -- and segment1 is different from emergency_po_num on req line
  FORALL i IN 1..l_index_tbl.COUNT
    INSERT INTO po_session_gt(key,num1)
    SELECT DISTINCT l_key,
           l_index_tbl(i)
    FROM po_headers_all ph,
         po_requisition_lines_all prl,
         po_requisition_headers_all prh
    WHERE ph.po_header_id = x_lines.hd_po_header_id_tbl(i)
      AND prl.requisition_line_id =  x_lines.requisition_line_id_tbl(i)
      AND prh.requisition_header_id = prl.requisition_header_id
      AND prh.emergency_po_num IS NOT NULL
      AND prh.emergency_po_num <> ph.segment1;

  l_index_tbl.DELETE;

   SELECT DISTINCT num1
   BULK COLLECT INTO l_index_tbl
   FROM po_session_gt
   WHERE KEY = l_key;

   DELETE FROM po_session_gt
    WHERE KEY = l_key;

 --Mark error flag for all the lines as true identified
 -- in above queries
 FOR i IN 1..l_index_tbl.count
 LOOP

   l_index := l_index_tbl(i);

   IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Error on index', l_index);
     PO_LOG.stmt(d_module, d_position, 'requisition line num',x_lines.requisition_line_id_tbl(l_index));
   END IF;

   PO_PDOI_ERR_UTL.add_fatal_error
    (
      p_interface_header_id  => x_lines.intf_header_id_tbl(l_index),
      p_interface_line_id    => x_lines.intf_line_id_tbl(l_index),
      p_error_message_name   => 'PO_PDOI_REQ_EMR_MISMATCH',
      p_table_name           => 'PO_LINES_INTERFACE',
      p_column_name          => 'REQUISITION_LINE_ID',
      p_column_value         =>  x_lines.requisition_line_id_tbl(l_index)
    );

    x_lines.error_flag_tbl(i) := FND_API.g_TRUE;

  END LOOP;

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
END check_emergency_po_same;

-----------------------------------------------------------------------
--Start of Comments
-- <PDOI Enhancement Bug#17063664>
--Name: uniqueness_check
--Function: This function is for checking attributes
--  which should be unique across all lines in a PO.
--Parameters:
--IN OUT: x_lines
--End of Comments
------------------------------------------------------------------------

PROCEDURE uniqueness_check
(
  x_lines                 IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
)
IS
  d_api_name CONSTANT VARCHAR2(30) := 'uniqueness_check';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  check_req_line_uniqueness(x_lines => x_lines);
  d_position := 10;

  check_pcard_same(x_lines => x_lines);
  d_position := 20;

  check_emergency_po_same(x_lines => x_lines);
  d_position := 30;

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
END uniqueness_check;

-----------------------------------------------------------------------
--Start of Comments
-- <PDOI Enhancement Bug#17063664>
--Name: temp_labor_group_validate
--Function: This function checks lines which have req reference
--  and temp labor and corresponding expense line both are selected or not.
-- Reject lines which have req reference and
-- 1) purchase basis - temp labor and corresponding expense line is not selected.
-- 2) purchase basis - services and corresponding Labor line is not selected.
-- Bug#19528138 : Revamped the code to fix the performance issue
--Parameters:
--End of Comments
------------------------------------------------------------------------

PROCEDURE temp_labor_group_validate
( p_draft_id_tbl PO_TBL_NUMBER
  , p_line_id_tbl  PO_TBL_NUMBER)
IS

  l_key       po_session_gt.key%TYPE;
  l_po_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_int_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_int_hdr_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_req_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_message_tbl PO_TBL_VARCHAR30 := PO_TBL_VARCHAR30();

  d_api_name CONSTANT VARCHAR2(30) := 'temp_labor_group_validate';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_count number;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

    -- pick a new key for temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  d_position := 10;

  FORALL i IN 1..p_line_id_tbl.COUNT
   INSERT INTO po_session_gt
               (KEY,
                index_num1, -- interface_id
                index_num2, -- interface_header_id
                num1, -- po_line_id
		num2, -- intf_labour_line_id
		num3, -- orig_expense_line_id
		num4, -- intf_expense_line_id
		num5 -- orig_labour_line_id
		)
       SELECT l_key,
           pli.interface_line_id,
           pli.interface_header_id,
           pli.po_line_id,
           pli.requisition_line_id,
           prl.requisition_line_id,
	   NULL,  -- intf_expense_line_id
	   NULL -- orig_labour_line_id
      FROM po_lines_interface pli,
           po_lines_draft_all pld,
	   po_requisition_lines_all prl
       WHERE pld.draft_id = p_draft_id_tbl(i)
       AND pld.po_line_id = p_line_id_tbl(i)
       AND pld.po_line_id = pli.po_line_id
       AND pli.processing_id = po_pdoi_params.g_processing_id
       AND pli.process_code <> po_pdoi_constants.g_process_code_rejected
       AND pli.requisition_line_id IS NOT NULL
       AND pld.order_type_lookup_code = 'RATE'
       AND pld.purchase_basis = 'TEMP LABOR'
       AND pli.requisition_line_id = prl.labor_req_line_id
       UNION ALL
        SELECT l_key,
           pli.interface_line_id,
           pli.interface_header_id,
           pli.po_line_id,
           NULL,-- intf_labour_line_id
           NULL,-- orig_expense_line_id
	   pli.requisition_line_id,  -- intf_expense_line_id
	   prl.labor_req_line_id -- orig_labour_line_id
      FROM po_lines_interface pli,
           po_lines_draft_all pld,
	   po_requisition_lines_all prl
       WHERE pld.draft_id = p_draft_id_tbl(i)
       AND pld.po_line_id = p_line_id_tbl(i)
       AND pld.po_line_id = pli.po_line_id
       AND pli.processing_id = po_pdoi_params.g_processing_id
       AND pli.process_code <> po_pdoi_constants.g_process_code_rejected
       AND pli.requisition_line_id IS NOT NULL
       AND pld.order_type_lookup_code = 'FIXED PRICE'
       AND pld.purchase_basis = 'SERVICES'
       AND pli.requisition_line_id = prl.requisition_line_id;

    d_position := 20;

    SELECT COUNT(*) INTO l_count
     FROM po_session_gt
    WHERE KEY = l_key;

    IF (PO_LOG.d_stmt) THEN
     PO_LOG.stmt(d_module, d_position, 'Number of records inserted', l_count);
    END IF;

    IF l_count > 0 THEN

      SELECT interface_line_id,
             interface_header_id,
	     po_line_id,
	     requisition_line_id,
	     error_message
      BULK COLLECT INTO
             l_int_line_id_tbl,
             l_int_hdr_id_tbl,
	     l_po_line_id_tbl,
             l_req_line_id_tbl,
             l_message_tbl
      FROM (
            SELECT  psg1.index_num1 interface_line_id,
                    psg1.index_num2 interface_header_id,
                    psg1.num1 po_line_id,
                    psg1.num2 requisition_line_id,
                    'PO_PDOI_NO_REQ_EXPENSE' error_message
              FROM po_session_gt psg1
	      WHERE KEY = l_key
	      AND num2 IS NOT NULL -- intf_labour_line_id
	      AND num3 IS NOT NULL -- orig_expense_line_id
	      AND NOT EXISTS(SELECT 'No Expense Line'
	                       FROM  po_session_gt psg2
			      WHERE KEY = l_key
			        AND psg1.index_num2 = psg2.index_num2
				AND psg1.num3 = psg2.num4
				)
              UNION ALL
	      SELECT  psg1.index_num1 interface_line_id,
                      psg1.index_num2 interface_header_id,
                      psg1.num1 po_line_id,
                      psg1.num4 requisition_line_id,
                      'PO_PDOI_NO_REQ_LABOR' error_message
              FROM po_session_gt psg1
              WHERE psg1.KEY = l_key
	      AND psg1.num4 IS NOT NULL  -- intf_expense_line_id
	      AND psg1.num5 IS NOT NULL -- orig_labour_line_id
	      AND NOT EXISTS(SELECT 'No Temp Labour Line'
	                      FROM  po_session_gt psg2
                             WHERE KEY = l_key
	                       AND psg1.index_num2 = psg2.index_num2
                               AND psg1.num5 = psg2.num2
                             )
           );

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'l_int_line_id_tbl', l_int_line_id_tbl);
      PO_LOG.stmt(d_module, d_position, 'l_int_hdr_id_tbl', l_int_hdr_id_tbl);
      PO_LOG.stmt(d_module, d_position, 'l_po_line_id_tbl', l_po_line_id_tbl);
      PO_LOG.stmt(d_module, d_position, 'l_req_line_id_tbl', l_req_line_id_tbl);
      PO_LOG.stmt(d_module, d_position, 'l_message_tbl', l_message_tbl);
    END IF;


    FOR i IN 1..l_int_line_id_tbl.count
    LOOP
      d_position := 30;

      PO_PDOI_ERR_UTL.add_fatal_error
      (
        p_interface_header_id  => l_int_hdr_id_tbl(i),
        p_interface_line_id    => l_int_line_id_tbl(i),
        p_error_message_name   => l_message_tbl(i),
        p_table_name           => 'PO_LINES_INTERFACE',
        p_column_name          => 'REQUISITION_LINE_ID',
        p_column_value         => l_req_line_id_tbl(i)
      );
    END LOOP;

   FORALL i IN 1..l_po_line_id_tbl.COUNT
   DELETE FROM po_lines_draft_all
   WHERE po_line_id = l_po_line_id_tbl(i);

   d_position := 40;
   PO_PDOI_UTL.reject_lines_intf
  (
    p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
    p_id_tbl          => l_int_line_id_tbl,
    p_cascade         => FND_API.g_TRUE
  );
   d_position := 50;

   DELETE FROM po_session_gt
   WHERE key = l_key;

  END IF; --lcount > 0

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

END temp_labor_group_validate;

-----------------------------------------------------------------------
--Start of Comments
-- <PDOI Enhancement Bug#17063664>
--Name: emrgncy_pcard_group_validate
--Function: This function rejects lines which have req reference
--  and both pcard and emergency PO Number.
-- Bug#19528138 : Revamped the code to fix the performance issue
--Parameters:
--End of Comments
------------------------------------------------------------------------

PROCEDURE emrgncy_pcard_group_validate( p_draft_id_tbl PO_TBL_NUMBER
                                      , p_line_id_tbl  PO_TBL_NUMBER)
IS
  l_key       po_session_gt.key%TYPE;
  l_po_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_int_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_int_hdr_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_req_line_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
  l_message_tbl PO_TBL_VARCHAR30 := PO_TBL_VARCHAR30();

  d_api_name CONSTANT VARCHAR2(30) := 'emrgncy_pcard_group_validate';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;

  l_pcard_cnt_tbl PO_TBL_NUMBER;
  l_emergency_cnt_tbl PO_TBL_NUMBER;
  l_reject_line_id_tbl PO_TBL_NUMBER:= PO_TBL_NUMBER();
  l_intf_hdr_id_tbl PO_TBL_NUMBER;
  l_count NUMBER:= 0;

BEGIN

  d_position:= 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

    -- pick a new key for temp table
  l_key := PO_CORE_S.get_session_gt_nextval;

  d_position := 10;

  FORALL i IN 1..p_line_id_tbl.COUNT
   INSERT INTO po_session_gt
                (KEY,
                 num1, -- po_line_id
                 num2, -- interface_id
                 num3, -- interface_header_id
                 num4, -- req_line_id
                 num5, --pcard_id
		 char1)--emergency_po_num
     SELECT l_key,
            pli.po_line_id,
            pli.interface_line_id,
            pli.interface_header_id,
            pli.requisition_line_id,
            prh.pcard_id,
            prh.emergency_po_num
     FROM   po_lines_interface pli,
            po_requisition_lines_all prl,
            po_requisition_headers_all prh,
            po_lines_draft_all pld
      WHERE pld.draft_id = p_draft_id_tbl(i)
        AND pld.po_line_id = p_line_id_tbl(i)
        AND pld.po_line_id = pli.po_line_id
        AND pli.processing_id = po_pdoi_params.g_processing_id
        AND pli.process_code <> po_pdoi_constants.g_process_code_rejected
        AND pli.requisition_line_id IS NOT NULL
        AND pli.requisition_line_id = prl.requisition_line_id
        AND prl.requisition_header_id = prh.requisition_header_id
        AND (prh.pcard_id IS NOT NULL OR prh.emergency_po_num IS NOT null) ;

  d_position := 20;

  SELECT num3,SUM(DECODE(num5,null,0,1)),
          SUM(DECODE(char1,null,0,1))
  BULK COLLECT INTO  l_intf_hdr_id_tbl,l_pcard_cnt_tbl,
        l_emergency_cnt_tbl
  FROM po_session_gt
  WHERE KEY = l_key
  GROUP BY num3;--interface_header_id

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'l_intf_hdr_id_tbl', l_intf_hdr_id_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_pcard_cnt_tbl', l_pcard_cnt_tbl);
    PO_LOG.stmt(d_module, d_position, 'l_emergency_cnt_tbl', l_emergency_cnt_tbl);
  END IF;

  d_position := 30;

  FOR i IN 1..l_intf_hdr_id_tbl.COUNT
  LOOP

    IF l_pcard_cnt_tbl(i) > 0 AND l_emergency_cnt_tbl(i) > 0 THEN

      SELECT DISTINCT num1,
                      num2,
                      num3,
                      num4,
	              DECODE(num5,NULL,DECODE(char1,NULL,NULL,'PO_PDOI_NO_EMER_PCARD')
		                 ,'PO_PDOI_NO_PCARD_EMER')
       BULK COLLECT INTO l_po_line_id_tbl,
                         l_int_line_id_tbl,
                         l_int_hdr_id_tbl,
                         l_req_line_id_tbl,
                         l_message_tbl
       FROM po_session_gt
       WHERE key = l_key
       AND num3=l_intf_hdr_id_tbl(i);

      FOR i IN 1..l_int_line_id_tbl.count
      LOOP
        d_position := 40;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_position, 'Po Line id ', l_po_line_id_tbl(i));
          PO_LOG.stmt(d_module, d_position, 'Message ', l_message_tbl(i));
        END IF;

        PO_PDOI_ERR_UTL.add_fatal_error
       (
         p_interface_header_id  => l_int_hdr_id_tbl(i),
         p_interface_line_id    => l_int_line_id_tbl(i),
         p_error_message_name   => l_message_tbl(i),
         p_table_name           => 'PO_LINES_INTERFACE',
         p_column_name          => 'REQUISITION_LINE_ID',
         p_column_value         => l_req_line_id_tbl(i)
        );
         l_count := l_count + 1;
         l_reject_line_id_tbl(l_count):= l_po_line_id_tbl(i);
      END LOOP;
      l_po_line_id_tbl.DELETE;
      l_int_line_id_tbl.DELETE;
      l_int_hdr_id_tbl.DELETE;
      l_req_line_id_tbl.DELETE;
      l_message_tbl.DELETE;
    END IF;
  END LOOP;


  d_position := 60;

  FORALL i IN 1..l_reject_line_id_tbl.COUNT
  DELETE FROM po_lines_draft_all
  WHERE po_line_id = l_reject_line_id_tbl(i);

  d_position := 70;
  PO_PDOI_UTL.reject_lines_intf
  (
    p_id_param_type   => PO_PDOI_CONSTANTS.g_INTERFACE_LINE_ID,
    p_id_tbl          => l_reject_line_id_tbl,
    p_cascade         => FND_API.g_TRUE
  );

  d_position := 80;

  DELETE FROM po_session_gt
  WHERE key = l_key;

  d_position := 90;

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

END emrgncy_pcard_group_validate;


PROCEDURE reject_after_grp_validate( p_draft_id_tbl PO_TBL_NUMBER
                                    , p_line_id_tbl  PO_TBL_NUMBER)

IS
  d_api_name CONSTANT VARCHAR2(30) := 'reject_after_grp_validate';
  d_module   CONSTANT VARCHAR2(255) := d_pkg_name || d_api_name || '.';
  d_position NUMBER;
BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- Reject lines which have req reference and
  -- 1) purchase basis - temp labor and corresponding expense line is not selected.
  -- 2) purchase basis - services and corresponding Labor line is not selected.
  temp_labor_group_validate( p_draft_id_tbl => p_draft_id_tbl
                           , p_line_id_tbl  => p_line_id_tbl);
  d_position := 10;

  -- Reject lines which have lines which have req reference
  -- and both pcard and emergency PO Number.
  emrgncy_pcard_group_validate( p_draft_id_tbl => p_draft_id_tbl
                              , p_line_id_tbl  => p_line_id_tbl);
  d_position := 20;

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

END reject_after_grp_validate;

--<PDOI Enhancement Bug#17063664 END>--

END PO_PDOI_LINE_PROCESS_PVT;

/
