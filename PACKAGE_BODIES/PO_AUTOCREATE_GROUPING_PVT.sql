--------------------------------------------------------
--  DDL for Package Body PO_AUTOCREATE_GROUPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AUTOCREATE_GROUPING_PVT" AS
/* $Header: PO_AUTOCREATE_GROUPING_PVT.plb 120.11.12010000.8 2014/01/07 11:02:04 jemishra ship $ */

--=============================================
-- GLOBAL VARIABLES
--=============================================

D_PACKAGE_BASE CONSTANT VARCHAR2(50) := PO_LOG.get_package_base('PO_AUTOCREATE_GROUPING_PVT');

D_get_line_action_tbl CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_line_action_tbl');
D_check_po_line_numbers CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'check_po_line_numbers');
D_lines_match CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'lines_match');
D_group_req_lines CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'group_req_lines');
D_get_req_line_delivery_info CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_req_line_delivery_info');
D_check_delivery_info CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'check_delivery_info');
D_lines_info_match CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'lines_info_match');
D_get_req_line_info CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_req_line_info');
D_get_po_line_info CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_po_line_info');
D_check_line_info CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'check_line_info');
D_lines_delivery_info_match CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'lines_delivery_info_match');
D_group_by_requisition_line CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'group_by_requisition_line_num');
D_group_by_requisition_seq_num CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'group_by_requisition_seq_num');
D_group_by_default CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'group_by_default');
D_has_same_req_header CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'has_same_req_header');
D_match_add_to_po_lines CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'match_add_to_po_lines');
D_find_matching_builder_index CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'find_matching_builder_index');
D_find_matching_builder_line CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'find_matching_builder_line_num');
D_req_lines_match CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'req_lines_match');
D_get_max_po_line_num CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_max_po_line_num');
D_get_consigned_flag_tbl CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_consigned_flag_tbl');
D_find_matching_po_line_num CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'find_matching_po_line_num');
-- bug#16097884
D_check_item_description CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'check_item_description');

--Bug#18007864:: FIX Varible used to check weather item description check needs to be fired or not
--      for one time item based lines. When user click on Add line on document builder the check is
--      fired and Requisiton lines with diffrent description not grouped togather.
--      But check is not fired when user click on create button as warning needs to be raised.
G_check_item_desc_match CHAR(1) := 'N';

/*=========================================================================*/
/*===================== SPECIFICATIONS (PRIVATE) ==========================*/
/*=========================================================================*/

CURSOR po_delivery_info_csr(p_po_line_id_to_compare IN NUMBER)
IS
  SELECT need_by_date,
         ship_to_location_id,
         ship_to_organization_id,
         consigned_flag
  FROM   po_line_locations_all
  WHERE  po_line_id = p_po_line_id_to_compare;

FUNCTION get_req_line_delivery_info(
  p_req_line_id IN NUMBER,
  p_supplier_id IN NUMBER,
  p_site_id IN NUMBER
) RETURN PO_DELIVERY_INFO_CSR%ROWTYPE;

PROCEDURE check_delivery_info(
  p_need_by_grouping_profile IN VARCHAR2,
  p_ship_to_grouping_profile IN VARCHAR2,
  p_delivery_one IN PO_DELIVERY_INFO_CSR%ROWTYPE,
  p_delivery_two IN PO_DELIVERY_INFO_CSR%ROWTYPE,
  x_message_code OUT NOCOPY VARCHAR2,
  x_token_name OUT NOCOPY VARCHAR2,
  x_token_value OUT NOCOPY VARCHAR2
);

PROCEDURE lines_info_match(
  p_agreement_id IN NUMBER,
  p_req_line_id IN NUMBER,
  p_req_line_id_to_compare IN NUMBER,
  p_po_line_id_to_compare IN NUMBER,
  x_message_code OUT NOCOPY VARCHAR2,
  x_token_name OUT NOCOPY VARCHAR2,
  x_token_value OUT NOCOPY VARCHAR2
);

TYPE line_info IS RECORD(
  item_id PO_REQUISITION_LINES_ALL.item_id%TYPE,
  item_description PO_REQUISITION_LINES_ALL.item_description%TYPE,
  item_revision PO_REQUISITION_LINES_ALL.item_revision%TYPE,
  order_type_lookup_code PO_REQUISITION_LINES_ALL.order_type_lookup_code%TYPE,
  purchase_basis PO_REQUISITION_LINES_ALL.purchase_basis%TYPE,
  matching_basis PO_REQUISITION_LINES_ALL.matching_basis%TYPE,
  preferred_grade PO_REQUISITION_LINES_ALL.preferred_grade%TYPE,
  unit_meas_lookup_code PO_REQUISITION_LINES_ALL.unit_meas_lookup_code%TYPE,
  transaction_reason PO_REQUISITION_LINES_ALL.transaction_reason_code%TYPE,
  contract_id PO_REQUISITION_LINES_ALL.blanket_po_header_id%TYPE,
  source_document_id PO_REQUISITION_LINES_ALL.blanket_po_header_id%TYPE,
  source_document_line_id PO_LINES_ALL.po_line_id%TYPE,
  cancel_flag PO_LINES_ALL.cancel_flag%TYPE,
  closed_code PO_LINES_ALL.closed_code%TYPE,
  supplier_ref_number PO_REQUISITION_LINES_ALL.supplier_ref_number%TYPE,
  category_id PO_REQUISITION_LINES_ALL.category_id%TYPE, --bugfix#16097884
  --bug 16819236
  SUGGESTED_VENDOR_PRODUCT_CODE PO_REQUISITION_LINES_ALL.SUGGESTED_VENDOR_PRODUCT_CODE%TYPE
);

FUNCTION get_req_line_info(p_req_line_id IN NUMBER) RETURN LINE_INFO;

FUNCTION get_po_line_info(p_po_line_id IN NUMBER) RETURN LINE_INFO;

PROCEDURE check_line_info(
  p_agreement_id IN NUMBER,
  p_line_one IN LINE_INFO,
  p_line_two IN LINE_INFO,
  x_message_code OUT NOCOPY VARCHAR2,
  x_token_name OUT NOCOPY VARCHAR2,
  x_token_value OUT NOCOPY VARCHAR2
);

PROCEDURE lines_delivery_info_match(
  p_supplier_id IN NUMBER,
  p_site_id IN NUMBER,
  p_req_line_id IN NUMBER,
  p_req_line_id_to_compare IN NUMBER,
  p_po_line_id_to_compare IN NUMBER,
  x_message_code OUT NOCOPY VARCHAR2,
  x_token_name OUT NOCOPY VARCHAR2,
  x_token_value OUT NOCOPY VARCHAR2
);

FUNCTION group_by_requisition_line_num
(   p_req_line_num_tbl       IN   PO_TBL_NUMBER
,   p_po_line_num_tbl        IN   PO_TBL_NUMBER
,   p_start_index            IN   NUMBER
,   p_end_index              IN   NUMBER
) RETURN PO_TBL_NUMBER;

FUNCTION group_by_requisition_seq_num
(   p_po_line_num_tbl        IN   PO_TBL_NUMBER
,   p_add_to_po_header_id    IN   NUMBER
,   p_start_index            IN   NUMBER
,   p_end_index              IN   NUMBER
) RETURN PO_TBL_NUMBER;

FUNCTION group_by_default
(   p_req_line_id_tbl        IN   PO_TBL_NUMBER
,   p_po_line_num_tbl        IN   PO_TBL_NUMBER
,   p_consigned_flag_tbl     IN   PO_TBL_VARCHAR1
,   p_add_to_po_header_id    IN   NUMBER
,   p_builder_agreement_id   IN   NUMBER
,   p_start_index            IN   NUMBER
,   p_end_index              IN   NUMBER
) RETURN PO_TBL_NUMBER;

FUNCTION has_same_req_header
(   p_req_line_id_tbl        IN   PO_TBL_NUMBER
) RETURN BOOLEAN;

PROCEDURE match_add_to_po_lines
(   p_req_line_id_tbl        IN         PO_TBL_NUMBER
,   p_consigned_flag_tbl     IN         PO_TBL_VARCHAR1
,   p_add_to_po_header_id    IN         NUMBER
,   p_builder_agreement_id   IN         NUMBER
,   p_start_index            IN         NUMBER
,   p_end_index              IN         NUMBER
,   x_req_line_id_tbl        OUT NOCOPY PO_TBL_NUMBER
,   x_po_line_num_tbl        OUT NOCOPY PO_TBL_NUMBER
);

FUNCTION find_matching_builder_line_num
(   p_current_index          IN   NUMBER
,   p_req_line_id_tbl        IN   PO_TBL_NUMBER
,   p_po_line_num_tbl        IN   PO_TBL_NUMBER
,   p_builder_agreement_id   IN   NUMBER
) RETURN NUMBER;

FUNCTION req_lines_match
(   p_agreement_id           IN   NUMBER
,   p_req_line_id_1          IN   NUMBER
,   p_req_line_id_2          IN   NUMBER
) RETURN BOOLEAN;

FUNCTION get_max_po_line_num
(   p_po_line_num_tbl        IN   PO_TBL_NUMBER
,   p_po_header_id           IN   NUMBER := NULL
) RETURN NUMBER;

FUNCTION get_consigned_flag_tbl
(   p_req_line_id_tbl        IN   PO_TBL_NUMBER
,   p_builder_org_id         IN   NUMBER
,   p_builder_supplier_id    IN   NUMBER
,   p_builder_site_id        IN   NUMBER
) RETURN PO_TBL_VARCHAR1;

FUNCTION find_matching_po_line_num
(   p_req_line_id            IN   NUMBER
,   p_comparison_tbl         IN   PO_TBL_NUMBER
,   p_po_line_num_tbl        IN   PO_TBL_NUMBER
) RETURN NUMBER;

/*=========================================================================*/
/*========================== BODY (PUBLIC) ================================*/
/*=========================================================================*/

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_line_action_tbl
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Gets a table with corresponding 'NEW' or 'ADD' actions for each requisition
-- line in the document builder. Action is 'NEW' if autocreating a new line and
-- 'ADD' if adding to an existing PO line. For the latter to be true, the
-- line's PO line number has to be the same as one of the PO's line numbers.
--Parameters:
--IN:
--p_po_line_number_tbl
--  The table of PO line numbers for all the requistion lines in the document
--  builder.
--p_add_to_po_header_id
--  The header ID of the PO for the Add To PO case. If New PO, this parameter
--  will be null and the table passed out will have 'NEW' for each requisition
--  line in the document builder.
--Returns:
--  Table of 'NEW' or 'ADD' actions corresponding to each of the input
--  requisition lines.
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_line_action_tbl(
  p_po_line_number_tbl IN PO_TBL_NUMBER,
  p_add_to_po_header_id IN NUMBER
) RETURN PO_TBL_VARCHAR5
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_line_action_tbl;
  d_position NUMBER := 0;

  l_num_lines              NUMBER;
  l_line_action_tbl        PO_TBL_VARCHAR5;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
    PO_LOG.proc_begin(d_mod,'p_add_to_po_header_id',p_add_to_po_header_id);
  END IF;

  -- Get the number of lines being passed in.
  l_num_lines := p_po_line_number_tbl.COUNT;

  -- Initialize table indicating whether lines are being added to existing PO
  -- lines.
  l_line_action_tbl := PO_TBL_VARCHAR5();
  l_line_action_tbl.EXTEND(l_num_lines);

  -- For each line in the doc builder, set the line action to 'ADD' if adding
  -- to an existing PO line and 'NEW' if creating a new PO line.
  FOR i IN 1..l_num_lines
  LOOP
    BEGIN
      SELECT 'ADD'
      INTO l_line_action_tbl(i)
      FROM po_lines_all
      WHERE po_header_id = p_add_to_po_header_id
      AND line_num = p_po_line_number_tbl(i);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_line_action_tbl(i) := 'NEW';
    END;
  END LOOP;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_mod, l_line_action_tbl);
  END IF;

  RETURN l_line_action_tbl;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in get_line_action_tbl');
    END IF;

    RAISE;
END get_line_action_tbl;

-------------------------------------------------------------------------------
--Start of Comments
--Name:  check_po_line_numbers
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Checks all requisition lines in the document builder to see if their PO line
-- numbers are valid. Returns tables with error messages corresponding to each
-- line in the doc builder, null if there are no error messages.
--Parameters:
--IN:
--p_style_id
--  The ID of the style specified in the document builder.
--p_agreement_id
--  The ID of the agreement specified in the document builder.
--p_supplier_id
--  The ID of the supplier specified in the document builder.
--p_site_id
--  The ID of the site specified in the document builder.
--p_req_line_id_tbl
--  The table of req line IDs for all the requistion lines in the document
--  builder.
--p_po_line_number_tbl
--  The table of PO line numbers for all the requistion lines in the document
--  builder.
--p_add_to_po_header_id
--  The header ID of the PO for the Add To PO case. If New PO, this parameter
--  will be null.
--OUT:
--x_message_code_tbl
--  Table of error message codes corresponding to each of the input requisition
--  lines.
--x_token_name_tbl
--  Table of error message token names corresponding to each of the input
--  requisition lines.
--x_token_value_tbl
--  Table of error message token values corresponding to each of the input
--  requisition lines.
--Notes:
--   None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_po_line_numbers(
  p_style_id IN NUMBER,
  p_agreement_id IN NUMBER,
  p_supplier_id IN NUMBER,
  p_site_id IN NUMBER,
  p_req_line_id_tbl IN PO_TBL_NUMBER,
  p_po_line_number_tbl IN PO_TBL_NUMBER,
  p_add_to_po_header_id IN NUMBER,
  x_message_code_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_token_name_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_token_value_tbl OUT NOCOPY PO_TBL_VARCHAR2000
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_check_po_line_numbers;
  d_position NUMBER := 0;

  l_num_lines                NUMBER;
  l_key                      NUMBER;
  l_req_line_id              PO_REQUISITION_LINES_ALL.requisition_line_id%TYPE;
  l_po_line_num              PO_LINES_ALL.line_num%TYPE;
  l_req_line_id_to_compare   PO_REQUISITION_LINES_ALL.requisition_line_id%TYPE;
  l_po_line_id_to_compare    PO_LINES_ALL.po_line_id%TYPE;
  l_progress_payment_flag    PO_DOC_STYLE_HEADERS.progress_payment_flag%TYPE;
  l_message_code             VARCHAR2(30) := NULL;
  l_token_name               VARCHAR2(30) := NULL;
  l_token_value              VARCHAR2(2000) := NULL;
  l_line_combined_flag_tbl PO_TBL_VARCHAR1;
  l_line_combined_flag     VARCHAR2(1);

  CURSOR req_line_ids_csr(
    c_key IN NUMBER,
    c_po_line_num IN varchar2,
    c_current_req_line_id IN NUMBER
  ) IS
    SELECT index_num1 -- requisition line ID
    FROM po_session_gt
    WHERE key = c_key
    AND index_num2 = c_po_line_num
    AND index_num1 <> c_current_req_line_id;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
    PO_LOG.proc_begin(d_mod,'p_style_id',p_style_id);
    PO_LOG.proc_begin(d_mod,'p_agreement_id',p_agreement_id);
    PO_LOG.proc_begin(d_mod,'p_supplier_id',p_supplier_id);
    PO_LOG.proc_begin(d_mod,'p_site_id',p_site_id);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
    PO_LOG.proc_begin(d_mod,'p_po_line_number_tbl',p_po_line_number_tbl);
    PO_LOG.proc_begin(d_mod,'p_add_to_po_header_id',p_add_to_po_header_id);
  END IF;

  -- Get the number of lines being passed in.
  l_num_lines := p_req_line_id_tbl.COUNT;

  --Bug#18007864:: FIX
  -- Item description check needs not to fired for one time item based requisiton lines,
  -- it should be raised as warning so skipping this check.
  G_check_item_desc_match := 'N';

  -- Initialize error message values to be returned.
  x_message_code_tbl := PO_TBL_VARCHAR30();
  x_message_code_tbl.EXTEND(l_num_lines);
  x_token_name_tbl := PO_TBL_VARCHAR30();
  x_token_name_tbl.EXTEND(l_num_lines);
  x_token_value_tbl := PO_TBL_VARCHAR2000();
  x_token_value_tbl.EXTEND(l_num_lines);

  -- Initialize table of flags indicating whether lines are combined.
  l_line_combined_flag_tbl := PO_TBL_VARCHAR1();
  l_line_combined_flag_tbl.EXTEND(l_num_lines);

  -- Get a new session key for use with the temp table.
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- Insert req line ID and PO line num of all lines into temp table.
  FORALL i IN 1..l_num_lines
    INSERT INTO po_session_gt(
      key, -- unique key
      index_num1, -- req line ID
      index_num2 -- PO line num
    )
    VALUES (l_key, p_req_line_id_tbl(i), p_po_line_number_tbl(i));

  -- <BUG 4922298 START>
  -- Wrap SQL statement with exception block to handle null style ID.
  -- Determine whether progress payment is enabled.
  BEGIN
    SELECT progress_payment_flag
    INTO   l_progress_payment_flag
    FROM   po_doc_style_headers
    WHERE  style_id = p_style_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_progress_payment_flag := null;
  END;
  -- <BUG 4922298 END>

  -- If progress payment is enabled, update l_line_combined_flag_tbl with flag
  -- indicating whether each line is combined with another req or PO line.
  IF (NVL(l_progress_payment_flag, 'N') = 'Y')
  THEN
    -- If req line is being combined with another req or PO line, set flag to
    -- 'Y'. Else, set flag to 'N'.
    SELECT NVL(
      (SELECT 'Y'
       FROM dual
       WHERE EXISTS(
         -- Select all doc builder requisition lines that have the same PO line
         -- number as the current line in the loop.
         SELECT 'doc builder lines with same PO line number'
         FROM po_session_gt POSGT2
         WHERE POSGT2.index_num1 <> POSGT.index_num1 -- Not the current line
         AND POSGT2.index_num2 = POSGT.index_num2 -- Same PO line number
       )
       OR EXISTS(
         -- Select all PO lines that have the same PO line number as the
         -- current line in the loop.
         SELECT 'PO lines with same PO line number'
         FROM po_lines_all
         WHERE po_header_id = p_add_to_po_header_id
         AND line_num = POSGT.index_num2 -- Same PO line number
       )),
      'N' -- NVL to 'N' if no other req/PO lines with same PO line number
    )
    BULK COLLECT INTO l_line_combined_flag_tbl
    FROM po_session_gt POSGT
    WHERE key = l_key;
  END IF;

  FOR i IN 1..l_num_lines -- Loop through all doc builder req lines
  LOOP
    -- Initialize the message code to NULL for each iteration
    l_message_code := NULL;

    l_req_line_id := p_req_line_id_tbl(i);
    l_po_line_num := p_po_line_number_tbl(i);
    l_line_combined_flag := l_line_combined_flag_tbl(i);

    -- If there is no error yet, check if the PO line number is NULL.
    IF (l_message_code IS NULL AND l_po_line_num IS NULL)
    THEN
      l_message_code := 'PO_ALL_NOT_NULL';
      l_token_name := NULL;
      l_token_value := NULL;
    END IF;

    -- If there is no error yet, check if the PO line number is less than or
    -- equal to 0.
    IF (l_message_code IS NULL AND l_po_line_num <= 0)
    THEN
      l_message_code := 'PO_ALL_ENTER_VALUE_GT_ZERO';
      l_token_name := NULL;
      l_token_value := NULL;
    END IF;

    -- If there is no error yet, check if progress payment is enabled and if
    -- lines are being combined.
    IF (l_message_code IS NULL
        AND l_progress_payment_flag = 'Y'
        AND l_line_combined_flag = 'Y')
    THEN
      l_message_code := 'PO_ALL_CANT_COMB_PROGRESSPAY';
      l_token_name := NULL;
      l_token_value := NULL;
    END IF;

    IF (l_message_code IS NULL) -- If there is no error yet
    THEN
      -- Check if all req lines with the same PO line number match.
      OPEN req_line_ids_csr(l_key, l_po_line_num, l_req_line_id);
      LOOP
        FETCH req_line_ids_csr INTO l_req_line_id_to_compare;
        EXIT WHEN req_line_ids_csr%NOTFOUND;
        lines_match(
          p_agreement_id,
          p_supplier_id,
          p_site_id,
          l_req_line_id,
          l_req_line_id_to_compare,
          NULL, -- No PO line ID to compare
          l_message_code,
           l_token_name,
         l_token_value
        );

        -- If any req lines with the same PO line number don't match, no need
        -- to check other req lines since only show one error message.
        EXIT WHEN l_message_code IS NOT NULL;
      END LOOP;
      CLOSE req_line_ids_csr;

      -- Check for PO line mismatch if all req lines match
      IF (l_message_code IS NULL)
      THEN
        -- If PO line with the same PO line number exists, check if matches
        BEGIN
          SELECT po_line_id
          INTO l_po_line_id_to_compare
          FROM po_lines_all
          WHERE po_header_id = p_add_to_po_header_id
          AND line_num = l_po_line_num;

          lines_match(
            p_agreement_id,
            p_supplier_id,
            p_site_id,
            l_req_line_id,
            NULL, -- No req line ID to compare
            l_po_line_id_to_compare,
            l_message_code,
            l_token_name,
            l_token_value
          );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL; -- No need to check if no PO line with same PO line number
        END;
      END IF; -- Check for PO line mismatch if all req lines match
    END IF; -- If there is no error yet

    -- If there is a mismatch, set error message
    IF (l_message_code IS NOT NULL)
    THEN
      x_message_code_tbl(i) := l_message_code;
      x_token_name_tbl(i) := l_token_name;
      x_token_value_tbl(i) := l_token_value;
    END IF; -- If there is a mismatch, set error message
  END LOOP; -- Loop through all doc builder req lines

  -- Clean up temp table
  DELETE FROM po_session_gt
  WHERE key = l_key;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_mod, 'x_message_code_tbl', x_message_code_tbl);
    PO_LOG.proc_end(d_mod, 'x_token_name_tbl', x_token_name_tbl);
    PO_LOG.proc_end(d_mod, 'x_token_value_tbl', x_token_value_tbl);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- Clean up temp table
    DELETE FROM po_session_gt
    WHERE key = l_key;

    -- Close cursor if open
    IF (req_line_ids_csr%ISOPEN)
    THEN
      CLOSE req_line_ids_csr;
    END IF;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in check_po_line_numbers');
    END IF;

    RAISE;
END check_po_line_numbers;

-------------------------------------------------------------------------------
--Start of Comments
--Name:  lines_match
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Checks whether a requisition line and a requisition/PO line match and
-- returns an error message indicating the result.
--Parameters:
--IN:
--p_agreement_id
--  The ID of the agreement specified in the document builder.
--p_supplier_id
--  The ID of the supplier specified in the document builder.
--p_site_id
--  The ID of the site specified in the document builder.
--p_req_line_id
--  The ID of the first requisition line to compare with.
--p_req_line_id_to_compare
--  If the second line to compare with is a requisition line, this variable
--  holds the ID of that requisition line. The second line is either a
--  requisition or PO line, so this variable may or may not be null.
--p_po_line_id_to_compare
--  If the second line to compare with is a PO line, this variable holds the ID
--  of that PO line. The second line is either a requisition or PO line, so
--  this variable may or may not be null.
--OUT:
--x_message_code
--  The error message code corresponding to whether the two lines match or not.
--x_token_name
--  The error message token name corresponding to whether the two lines match
--  or not.
--x_token_value
--  The error message token value corresponding to whether the two lines match
--  or not.
--Notes:
--  Between the input parameters p_req_line_id_to_compare and
--  p_po_line_id_to_compare, one of them has to be null and one of them has to
--  have a value.
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE lines_match(
  p_agreement_id IN NUMBER,
  p_supplier_id IN NUMBER,
  p_site_id IN NUMBER,
  p_req_line_id IN NUMBER,
  p_req_line_id_to_compare IN NUMBER,
  p_po_line_id_to_compare IN NUMBER,
  x_message_code OUT NOCOPY VARCHAR2,
  x_token_name OUT NOCOPY VARCHAR2,
  x_token_value OUT NOCOPY VARCHAR2
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_lines_match;
  d_position NUMBER := 0;

  l_token_value                 VARCHAR2(2000);
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
    PO_LOG.proc_begin(d_mod,'p_agreement_id',p_agreement_id);
    PO_LOG.proc_begin(d_mod,'p_supplier_id',p_supplier_id);
    PO_LOG.proc_begin(d_mod,'p_site_id',p_site_id);
    PO_LOG.proc_begin(d_mod,'p_req_line_id',p_req_line_id);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_to_compare',p_req_line_id_to_compare);
    PO_LOG.proc_begin(d_mod,'p_po_line_id_to_compare',p_po_line_id_to_compare);
  END IF;

  lines_info_match(
    p_agreement_id,
    p_req_line_id,
    p_req_line_id_to_compare,
    p_po_line_id_to_compare,
    x_message_code,
    x_token_name,
    x_token_value
  );

  -- If there is a line-level error, no need to check shipment-level attributes
  IF x_message_code IS NOT NULL THEN
    RETURN;
  END IF;

  lines_delivery_info_match(
    p_supplier_id,
    p_site_id,
    p_req_line_id,
    p_req_line_id_to_compare,
    p_po_line_id_to_compare,
    x_message_code,
    x_token_name,
    x_token_value
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
    PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
    PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in lines_match');
    END IF;

    RAISE;
END lines_match;

-------------------------------------------------------------------------------
--Start of Comments
--Name: group_req_lines
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Defaults the PO line numbers for requisition lines in the Autocreate
--  Document Builder based on either the 'Requisition' or 'Default' grouping
--  method.
--Parameters:
--IN:
--p_req_line_id_tbl
--  Table of requisition line IDs representing the Autocreate Document Builder.
--p_req_line_num_tbl
--  Table of requisition line numbers for the req lines in the Doc Builder.
--p_po_line_num_tbl
--  Table of PO line numbers currently assigned to the Document Builder
--  requisition lines.
--p_add_to_po_header_id
--  The ID of the PO to which the requisition lines are being added
--  (will be null when creating a new PO).
--p_builder_agreement_id
--  The ID of the Global Agreement for which the PO will be created.
--p_builder_supplier_id
--  The ID of the Supplier for which the PO will be created.
--p_builder_site_id
--  The ID of the Site for which the PO will be created.
--p_builder_org_id
--  The ID of the Operating Unit for which the PO will be created.
--p_start_index
--  The index of the first requisition line in the input table which
--  should have a PO line number calculated (default value of 1
--  if not specified).
--p_end_index
--  The index of the last requisition line in the input table which
--  should have a PO line number calculated (default value of last
--  index in the table if not specified).
--p_grouping_method
--  Grouping method; possible values are 'DEFAULT' or 'REQUISITION'.
--Returns:
--  Table of PO line numbers corresponding to each of the input requisition
--  lines.
--Notes:
--  N/A
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
FUNCTION group_req_lines
(
    p_req_line_id_tbl      IN  PO_TBL_NUMBER
,   p_req_line_num_tbl     IN  PO_TBL_NUMBER
,   p_po_line_num_tbl      IN  PO_TBL_NUMBER
,   p_add_to_po_header_id  IN  NUMBER
,   p_builder_agreement_id IN  NUMBER
,   p_builder_supplier_id  IN  NUMBER
,   p_builder_site_id      IN  NUMBER
,   p_builder_org_id       IN  NUMBER
,   p_start_index          IN  NUMBER
,   p_end_index            IN  NUMBER
,   p_grouping_method      IN  VARCHAR2
)
RETURN PO_TBL_NUMBER
IS
    l_start_index          NUMBER;
    l_end_index            NUMBER;

    l_consigned_flag_tbl   PO_TBL_VARCHAR1;
    l_po_line_num_tbl      PO_TBL_NUMBER := p_po_line_num_tbl;
    x_po_line_num_tbl      PO_TBL_NUMBER := PO_TBL_NUMBER();

    d_mod CONSTANT VARCHAR2(100) := D_group_req_lines;
    d_position NUMBER := 0;

BEGIN

    IF PO_LOG.d_proc THEN PO_LOG.proc_begin(d_mod); END IF;

    -- Initialize start and end indices to be first and last
    -- indices in the input req line table (if they were not
    -- specified in the input parameters).
    --
    l_start_index := nvl(p_start_index, 1);
    l_end_index := nvl(p_end_index, p_req_line_id_tbl.COUNT);

    d_position := 5;

    IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'l_start_index',l_start_index);
        PO_LOG.stmt(d_mod,d_position,'l_end_index',l_end_index);
        PO_LOG.stmt(d_mod,d_position,'p_grouping_method',p_grouping_method);
    END IF;

    -- Clear PO line numbers from input table for those indices
    -- which will be defaulted.
    --
    FOR i IN l_start_index..l_end_index LOOP
        l_po_line_num_tbl(i) := NULL;
    END LOOP;

    d_position := 10;

    -- Call separate grouping procedures depending on grouping method.
    --
    IF ( p_grouping_method = 'REQUISITION' ) THEN

        d_position := 20;

        -- Use req line numbers for the PO line numbers iff...
        -- (a) "PO: Use Requisition Line Numbers for Autocreate" is set, and
        -- (b) we are creating a new PO, and
        -- (c) all req lines in the Doc Builder come from the same req.
        --
        IF  (   ( FND_PROFILE.value('PO_USE_REQ_NUM_IN_AUTOCREATE') = 'Y' )
            AND ( p_add_to_po_header_id IS NULL )
            AND ( has_same_req_header(p_req_line_id_tbl) ) )
        THEN
            d_position := 30;

            x_po_line_num_tbl := group_by_requisition_line_num
                                 ( p_req_line_num_tbl
                                 , l_po_line_num_tbl
                                 , l_start_index
                                 , l_end_index
                                 );
        -- Else, just sequentially number the req lines starting from
        -- the max line number currently in the Doc Builder or on the
        -- PO being added to.
        --
        ELSE
            d_position := 40;

            x_po_line_num_tbl := group_by_requisition_seq_num
                                 ( l_po_line_num_tbl
                                 , p_add_to_po_header_id
                                 , l_start_index
                                 , l_end_index
                                 );
        END IF;

    ELSE -- ( p_grouping_method = 'DEFAULT' )

        d_position := 50;

        -- Derive the Consigned Flag for each requisition line. It is too
        -- difficult to derive the flag in the query, so we will get it
        -- here by calling an API for each req line.
        --
        l_consigned_flag_tbl := get_consigned_flag_tbl ( p_req_line_id_tbl
                                                       , p_builder_org_id
                                                       , p_builder_supplier_id
                                                       , p_builder_site_id
                                                       );
        x_po_line_num_tbl := group_by_default ( p_req_line_id_tbl
                                              , l_po_line_num_tbl
                                              , l_consigned_flag_tbl
                                              , p_add_to_po_header_id
                                              , p_builder_agreement_id
                                              , l_start_index
                                              , l_end_index
                                              );
    END IF;

    d_position := 60;

    IF PO_LOG.d_proc THEN PO_LOG.proc_return(d_mod,x_po_line_num_tbl); END IF;

    return (x_po_line_num_tbl);

EXCEPTION

    WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,d_position); END IF;
        RAISE;

END group_req_lines;

/*=========================================================================*/
/*========================== BODY (PRIVATE) ===============================*/
/*=========================================================================*/

-------------------------------------------------------------------------------
--Start of Comments
--Name:  lines_delivery_info_match
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Gets the delivery info for a requisition line and a requisition/PO line and
-- checks whether they match at the delivery info level. Returns an error
-- message indicating the result.
--Parameters:
--IN:
--p_supplier_id
--  The ID of the supplier specified in the document builder.
--p_site_id
--  The ID of the site specified in the document builder.
--p_req_line_id
--  The ID of the first requisition line to compare with.
--p_req_line_id_to_compare
--  If the second line to compare with is a requisition line, this variable
--  holds the ID of that requisition line. The second line is either a
--  requisition or PO line, so this variable may or may not be null.
--p_po_line_id_to_compare
--  If the second line to compare with is a PO line, this variable holds the ID
--  of that PO line. The second line is either a requisition or PO line, so
--  this variable may or may not be null.
--OUT:
--x_message_code
--  The error message code corresponding to whether the two lines match at the
--  delivery info level or not.
--x_token_name
--  The error message token name corresponding to whether the two lines match
--  at the delivery info level or not.
--x_token_value
--  The error message token value corresponding to whether the two lines match
--  at the delivery info level or not.
--Notes:
--  Between the input parameters p_req_line_id_to_compare and
--  p_po_line_id_to_compare, one of them has to be null and one of them has to
--  have a value.
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE lines_delivery_info_match(
  p_supplier_id IN NUMBER,
  p_site_id IN NUMBER,
  p_req_line_id IN NUMBER,
  p_req_line_id_to_compare IN NUMBER,
  p_po_line_id_to_compare IN NUMBER,
  x_message_code OUT NOCOPY VARCHAR2,
  x_token_name OUT NOCOPY VARCHAR2,
  x_token_value OUT NOCOPY VARCHAR2
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_lines_delivery_info_match;
  d_position NUMBER := 0;

  l_token_value                 VARCHAR2(2000);

  -- Shipment-level attributes
  l_need_by_grouping_profile    VARCHAR2(1);
  l_ship_to_grouping_profile    VARCHAR2(1);
  delivery_one                  PO_DELIVERY_INFO_CSR%ROWTYPE;
  delivery_two                  PO_DELIVERY_INFO_CSR%ROWTYPE;

BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
    PO_LOG.proc_begin(d_mod,'p_supplier_id',p_supplier_id);
    PO_LOG.proc_begin(d_mod,'p_site_id',p_site_id);
    PO_LOG.proc_begin(d_mod,'p_req_line_id',p_req_line_id);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_to_compare',p_req_line_id_to_compare);
    PO_LOG.proc_begin(d_mod,'p_po_line_id_to_compare',p_po_line_id_to_compare);
  END IF;

  -- Get shipment-level profiles
  l_need_by_grouping_profile := fnd_profile.value('PO_NEED_BY_GROUPING');
  l_ship_to_grouping_profile := fnd_profile.value('PO_SHIPTO_GROUPING');

  -- Retrieve all shipment-level attributes for p_req_line_id
  delivery_one := get_req_line_delivery_info(
    p_req_line_id,
    p_supplier_id,
    p_site_id
  );

  IF (p_req_line_id_to_compare IS NOT NULL) -- if second line is a req line
  THEN
    -- Retrieve all shipment-level attributes for p_req_line_id_to_compare
    delivery_two := get_req_line_delivery_info(
      p_req_line_id_to_compare,
      p_supplier_id,
      p_site_id
    );

    -- Check shipment-level attributes for mismatch
    check_delivery_info(
      l_need_by_grouping_profile,
      l_ship_to_grouping_profile,
      delivery_one,
      delivery_two,
      x_message_code,
      x_token_name,
      x_token_value
    );
  ELSE -- if second line is a PO line
    -- Retrieve all shipment-level attributes for p_po_line_id_to_compare
    OPEN po_delivery_info_csr(p_po_line_id_to_compare);
    LOOP
      FETCH po_delivery_info_csr INTO
        delivery_two;
      EXIT WHEN po_delivery_info_csr%NOTFOUND;

      -- Check shipment-level attributes for mismatch
      check_delivery_info(
        l_need_by_grouping_profile,
        l_ship_to_grouping_profile,
        delivery_one,
        delivery_two,
        x_message_code,
        x_token_name,
        x_token_value
      );

      -- Exit the for loop if a matching shipment is found.
      IF (x_message_code IS NULL)
      THEN
        EXIT;
      END IF;
    END LOOP;
    CLOSE po_delivery_info_csr;
  END IF; -- if second line is a PO line

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
    PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
    PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- Close cursor if open
    IF (po_delivery_info_csr%ISOPEN)
    THEN
      CLOSE po_delivery_info_csr;
    END IF;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in lines_delivery_info_match');
    END IF;

    RAISE;
END lines_delivery_info_match;

-------------------------------------------------------------------------------
--Start of Comments
--Name:  check_delivery_info
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Checks whether a requisition line and a requisition/PO line match at the
-- delivery info level and returns an error message indicating the result.
--Parameters:
--IN:
--p_need_by_grouping_profile
--  The profile indicating whether need-by-date should be considered when
--  checking if two lines match.
--p_ship_to_grouping_profile
--  The profile indicating whether shipping information should be considered
--  when checking if two lines match.
--p_delivery_one
--  The delivery information for the first line.
--p_delivery_two
--  The delivery information for the second line.
--OUT:
--x_message_code
--  The error message code corresponding to whether the two lines match at the
--  delivery info level or not.
--x_token_name
--  The error message token name corresponding to whether the two lines match
--  at the delivery info level or not.
--x_token_value
--  The error message token value corresponding to whether the two lines match
--  at the delivery info level or not.
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_delivery_info(
  p_need_by_grouping_profile IN VARCHAR2,
  p_ship_to_grouping_profile IN VARCHAR2,
  p_delivery_one IN PO_DELIVERY_INFO_CSR%ROWTYPE,
  p_delivery_two IN PO_DELIVERY_INFO_CSR%ROWTYPE,
  x_message_code OUT NOCOPY VARCHAR2,
  x_token_name OUT NOCOPY VARCHAR2,
  x_token_value OUT NOCOPY VARCHAR2
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_check_delivery_info;
  d_position NUMBER := 0;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
    PO_LOG.proc_begin(d_mod,'p_need_by_grouping_profile',p_need_by_grouping_profile);
    PO_LOG.proc_begin(d_mod,'p_ship_to_grouping_profile',p_ship_to_grouping_profile);
  END IF;

  -- Initialize message code, token name, and token value to NULL
  x_message_code := NULL;
  x_token_name := NULL;
  x_token_value := NULL;

  -- Check need-by date attributes
  IF ((NVL(p_need_by_grouping_profile, 'Y') = 'Y')
      AND NOT PO_CORE_S.is_equal_minutes(
        p_delivery_one.need_by_date,
        p_delivery_two.need_by_date))
  THEN
    x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
    x_token_name := 'REASON_FOR_DIFF';
    x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_NEED_BY');

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  -- Check ship-to attributes
  IF (NVL(p_ship_to_grouping_profile, 'Y') = 'Y')
  THEN
    -- Check ship-to organization ID attributes
    IF (NOT PO_CORE_S.is_equal(
          p_delivery_one.ship_to_organization_id,
          p_delivery_two.ship_to_organization_id))
    THEN
      x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
      x_token_name := 'REASON_FOR_DIFF';
      x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_DEL_ORG');

      IF (PO_LOG.d_proc) THEN
        PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
        PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
        PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
      END IF;

      RETURN;
    END IF;

    -- Check ship-to location ID attributes
    IF (NOT PO_CORE_S.is_equal(
          p_delivery_one.ship_to_location_id,
          p_delivery_two.ship_to_location_id))
    THEN
      x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
      x_token_name := 'REASON_FOR_DIFF';
      x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_DEL_LOC');

      IF (PO_LOG.d_proc) THEN
        PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
        PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
        PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
      END IF;

      RETURN;
    END IF;
  END IF;

  -- Check consigned flag attributes which are set to 'N' if NULL
  IF (NOT PO_CORE_S.is_equal(
        NVL(p_delivery_one.consigned_flag, 'N'),
        NVL(p_delivery_two.consigned_flag, 'N')))
  THEN
    x_message_code := 'PO_ALL_CANT_COMB_CONSIGNED';
    x_token_name := NULL;
    x_token_value := NULL;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
    PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
    PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in check_delivery_info');
    END IF;

    RAISE;
END check_delivery_info;

-------------------------------------------------------------------------------
--Start of Comments
--Name:  get_req_line_delivery_info
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Gets the delivery info for a requisition line.
--Parameters:
--IN:
--p_req_line_id
--  The ID of the requisition line to get the delivery info of.
--p_supplier_id
--  The ID of the supplier specified in the document builder.
--p_site_id
--  The ID of the site specified in the document builder.
--RETURNS:
--  The delivery info for the req line.
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_req_line_delivery_info(
  p_req_line_id IN NUMBER,
  p_supplier_id IN NUMBER,
  p_site_id IN NUMBER
) RETURN PO_DELIVERY_INFO_CSR%ROWTYPE
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_req_line_delivery_info;
  d_position NUMBER := 0;

  l_req_line_delivery_info      PO_DELIVERY_INFO_CSR%ROWTYPE;
  l_item_id                     PO_REQUISITION_LINES_ALL.item_id%TYPE;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
    PO_LOG.proc_begin(d_mod,'p_req_line_id',p_req_line_id);
    PO_LOG.proc_begin(d_mod,'p_supplier_id',p_supplier_id);
    PO_LOG.proc_begin(d_mod,'p_site_id',p_site_id);
  END IF;

  SELECT PRL.item_id,
         PRL.need_by_date,
         PRL.destination_organization_id,
         PRL.deliver_to_location_id
  INTO   l_item_id,
         l_req_line_delivery_info.need_by_date,
         l_req_line_delivery_info.ship_to_organization_id,
         l_req_line_delivery_info.ship_to_location_id
  FROM   po_requisition_lines_all PRL
  WHERE  PRL.requisition_line_id = p_req_line_id;

  l_req_line_delivery_info.consigned_flag :=
    PO_THIRD_PARTY_STOCK_GRP.get_consigned_flag(
      NULL,  --bug 5976612
      l_item_id, -- p_item_id
      p_supplier_id, -- p_supplier_id
      p_site_id, -- p_site_id
      l_req_line_delivery_info.ship_to_organization_id -- p_inv_org_id   --bug 5976612
    );

   /* Bug 5976612
      Added the 'NULL' parameter in the beginning in the place of org id.
      Moved the l_req_line_delivery_info.ship_to_organization_id parameter to end. This is inventory org id.
      These changes are driven by the changes done to the function PO_THIRD_PARTY_STOCK_GRP.get_consigned_flag. */

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_mod);
  END IF;

  RETURN l_req_line_delivery_info;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in get_req_line_delivery_info');
    END IF;

    RAISE;
END get_req_line_delivery_info;

-------------------------------------------------------------------------------
--Start of Comments
--Name:  lines_info_match
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Checks whether a requisition line and a requisition/PO line match at the
-- line info level and returns an error message indicating the result.
--Parameters:
--IN:
--p_agreement_id
--  The ID of the agreement specified in the document builder.
--p_req_line_id
--  The ID of the first requisition line to compare with.
--p_req_line_id_to_compare
--  If the second line to compare with is a requisition line, this variable
--  holds the ID of that requisition line. The second line is either a
--  requisition or PO line, so this variable may or may not be null.
--p_po_line_id_to_compare
--  If the second line to compare with is a PO line, this variable holds the ID
--  of that PO line. The second line is either a requisition or PO line, so
--  this variable may or may not be null.
--OUT:
--x_message_code
--  The error message code corresponding to whether the two lines match at the
--  line info level or not.
--x_token_name
--  The error message token name corresponding to whether the two lines match
--  at the line info level or not.
--x_token_value
--  The error message token value corresponding to whether the two lines match
--  at the line info level or not.
--Notes:
--  Between the input parameters p_req_line_id_to_compare and
--  p_po_line_id_to_compare, one of them has to be null and one of them has to
--  have a value.
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE lines_info_match(
  p_agreement_id IN NUMBER,
  p_req_line_id IN NUMBER,
  p_req_line_id_to_compare IN NUMBER,
  p_po_line_id_to_compare IN NUMBER,
  x_message_code OUT NOCOPY VARCHAR2,
  x_token_name OUT NOCOPY VARCHAR2,
  x_token_value OUT NOCOPY VARCHAR2
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_lines_info_match;
  d_position NUMBER := 0;

  l_token_value                 VARCHAR2(2000);

  l_line_one                    LINE_INFO;
  l_line_two                    LINE_INFO;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
    PO_LOG.proc_begin(d_mod,'p_agreement_id',p_agreement_id);
    PO_LOG.proc_begin(d_mod,'p_req_line_id',p_req_line_id);
    PO_LOG.proc_begin(d_mod,'p_req_line_id_to_compare',p_req_line_id_to_compare);
    PO_LOG.proc_begin(d_mod,'p_po_line_id_to_compare',p_po_line_id_to_compare);
  END IF;

  -- Retrieve all lines matching attributes for p_req_line_id
  l_line_one := get_req_line_info(p_req_line_id);

  -- Retrieve lines matching attributes for second line
  IF (p_req_line_id_to_compare IS NOT NULL) -- if second line is a req line
  THEN
    -- Retrieve all lines matching attributes for p_req_line_id_to_compare
    l_line_two := get_req_line_info(p_req_line_id_to_compare);
  ELSE -- if second line is a PO line
    -- Retrieve all line-level attributes for p_po_line_id_to_compare
    l_line_two := get_po_line_info(p_po_line_id_to_compare);
  END IF;

  -- Check line-level attributes
  check_line_info(
    p_agreement_id,
    l_line_one,
    l_line_two,
    x_message_code,
    x_token_name,
    x_token_value
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
    PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
    PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in lines_info_match');
    END IF;

    RAISE;
END lines_info_match;

-------------------------------------------------------------------------------
--Start of Comments
--Name:  get_req_line_info
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Gets the line info for a requisition line.
--Parameters:
--IN:
--p_req_line_id
--  The ID of the requisition line to get the line info of.
--RETURNS:
--  The line info for the req line.
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_req_line_info(p_req_line_id IN NUMBER) RETURN LINE_INFO
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_req_line_info;
  d_position NUMBER := 0;

  l_req_line_info LINE_INFO;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
    PO_LOG.proc_begin(d_mod,'p_req_line_id',p_req_line_id);
  END IF;

  SELECT PRL.item_id,
         PRL.item_description,
         PRL.item_revision,
         PRL.order_type_lookup_code,
         PRL.purchase_basis,
         PRL.matching_basis,
         PRL.preferred_grade,
         PRL.unit_meas_lookup_code,
         PRL.transaction_reason_code,
         DECODE(
           PRL.document_type_code,
           'CONTRACT',
           PRL.blanket_po_header_id,
           NULL
         ), -- contract ID
         DECODE(
           PRL.document_type_code,
           'CONTRACT',
           NULL,
           PRL.blanket_po_header_id
         ), -- source document ID
         DECODE(
           PRL.document_type_code,
           'CONTRACT',
           NULL,
           SRC_DOC_LINE.po_line_id
         ), -- source document line ID
         NULL, -- cancel flag N/A for req line
         NULL, -- closed code N/A for req line
         PRL.supplier_ref_number,
	 PRL.category_id,  --bugfix#16097884
	 PRL.SUGGESTED_VENDOR_PRODUCT_CODE --bug 16819236
  INTO   l_req_line_info
  FROM   po_requisition_lines_all PRL,
         po_lines_all SRC_DOC_LINE
  WHERE  PRL.requisition_line_id = p_req_line_id
  AND    SRC_DOC_LINE.po_header_id(+) = PRL.blanket_po_header_id
  AND    SRC_DOC_LINE.line_num(+) = PRL.blanket_po_line_num;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_mod);
  END IF;

  RETURN l_req_line_info;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in lines_info_match');
    END IF;

    RAISE;
END get_req_line_info;

-------------------------------------------------------------------------------
--Start of Comments
--Name:  get_po_line_info
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Gets the line info for a PO line.
--Parameters:
--IN:
--p_po_line_id
--  The ID of the PO line to get the line info of.
--RETURNS:
--  The line info for the PO line.
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_po_line_info(p_po_line_id IN NUMBER) RETURN LINE_INFO
IS
  d_mod CONSTANT VARCHAR2(100) := D_get_po_line_info;
  d_position NUMBER := 0;

  l_po_line_info LINE_INFO;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
    PO_LOG.proc_begin(d_mod,'p_po_line_id',p_po_line_id);
  END IF;

  SELECT item_id,
         item_description,
         item_revision,
         order_type_lookup_code,
         purchase_basis,
         matching_basis,
         preferred_grade,
         unit_meas_lookup_code,
         transaction_reason_code,
         contract_id,
         from_header_id, -- source document ID
         from_line_id, -- source document line ID
         cancel_flag,
         closed_code,
         supplier_ref_number,
	 category_id,  --bugfix#16097884
	 VENDOR_PRODUCT_NUM --bug 16819236
  INTO   l_po_line_info
  FROM   po_lines_all
  WHERE  po_line_id = p_po_line_id;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_mod);
  END IF;

  RETURN l_po_line_info;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in lines_info_match');
    END IF;

    RAISE;
END get_po_line_info;

-------------------------------------------------------------------------------
--Start of Comments
--Name:  check_line_info
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Checks whether a requisition line and a requisition/PO line match at the
-- line info level and returns an error message indicating the result.
--Parameters:
--IN:
--p_agreement_id
--  The ID of the agreement specified in the document builder.
--p_line_one
--  The line information for the first line.
--p_line_two
--  The line information for the second line.
--OUT:
--x_message_code
--  The error message code corresponding to whether the two lines match at the
--  line info level or not.
--x_token_name
--  The error message token name corresponding to whether the two lines match
--  at the line info level or not.
--x_token_value
--  The error message token value corresponding to whether the two lines match
--  at the line info level or not.
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE check_line_info(
  p_agreement_id IN NUMBER,
  p_line_one IN LINE_INFO,
  p_line_two IN LINE_INFO,
  x_message_code OUT NOCOPY VARCHAR2,
  x_token_name OUT NOCOPY VARCHAR2,
  x_token_value OUT NOCOPY VARCHAR2
)
IS
  d_mod CONSTANT VARCHAR2(100) := D_check_line_info;
  d_position NUMBER := 0;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
    PO_LOG.proc_begin(d_mod,'p_agreement_id',p_agreement_id);
  END IF;

  -- Initialize message code, token name, and token value to NULL
  x_message_code := NULL;
  x_token_name := NULL;
  x_token_value := NULL;

  -- Check line-level attributes. If any mismatches are found, set error
  -- message values and skip the rest of the checks.
  IF (NOT PO_CORE_S.is_equal(p_line_one.item_id, p_line_two.item_id)
      --bug 16819236
      OR NOT PO_CORE_S.is_equal(p_line_one.SUGGESTED_VENDOR_PRODUCT_CODE, p_line_two.SUGGESTED_VENDOR_PRODUCT_CODE)
      --Bug#18007864
      OR (NVL(G_check_item_desc_match,'N') = 'Y' AND
            (p_line_one.item_id IS NULL AND p_line_two.item_id IS NULL
           AND NOT PO_CORE_S.is_equal(
             p_line_one.item_description,
             p_line_two.item_description))))
  THEN
    x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
    x_token_name := 'REASON_FOR_DIFF';
    x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_ITEMS');

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

    -- Bugfix#16097884
  -- 1) Removed Item Description check for one time items
  -- 2) Added Check, Category Id should be same to group/addto
  --  between Req and PO for Autocreate Process.

  IF (NOT PO_CORE_S.is_equal(
      p_line_one.category_id,
	  p_line_two.category_id))
  THEN
    x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
    x_token_name := 'REASON_FOR_DIFF';
    x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_CATEGORY_ID');

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  IF (NOT PO_CORE_S.is_equal(
        p_line_one.item_revision,
        p_line_two.item_revision))
  THEN
    x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
    x_token_name := 'REASON_FOR_DIFF';
    x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_ITEM_REVISION');

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  --BUG 5641147 : Donot group for RATE and FIXED PRICE lines
  IF  p_line_two.order_type_lookup_code IN ('RATE','FIXED PRICE')
     OR
    (NOT PO_CORE_S.is_equal(
        p_line_one.order_type_lookup_code,
        p_line_two.order_type_lookup_code
      )
      OR NOT PO_CORE_S.is_equal(
        p_line_one.purchase_basis,
        p_line_two.purchase_basis
      )
      OR NOT PO_CORE_S.is_equal(
        p_line_one.matching_basis,
        p_line_two.matching_basis))
  THEN
    x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
    x_token_name := 'REASON_FOR_DIFF';
    x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_LINE_TYPE');

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  IF (NOT PO_CORE_S.is_equal(
        p_line_one.preferred_grade,
        p_line_two.preferred_grade))
  THEN
    x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
    x_token_name := 'REASON_FOR_DIFF';
    x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_PREF_GRADE');

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  IF (NOT PO_CORE_S.is_equal(
        p_line_one.unit_meas_lookup_code,
        p_line_two.unit_meas_lookup_code))
  THEN
    x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
    x_token_name := 'REASON_FOR_DIFF';
    x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_PRI_UOM');

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  IF (NOT PO_CORE_S.is_equal(
        p_line_one.transaction_reason,
        p_line_two.transaction_reason))
  THEN
    x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
    x_token_name := 'REASON_FOR_DIFF';
    x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_TRANS_REASON');

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  IF (NOT PO_CORE_S.is_equal(p_line_one.contract_id, p_line_two.contract_id))
  THEN
    x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
    x_token_name := 'REASON_FOR_DIFF';
    x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_CONTRACT');

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  IF (p_agreement_id IS NULL
      AND (NOT PO_CORE_S.is_equal(
             p_line_one.source_document_id,
             p_line_two.source_document_id
           )
           OR NOT PO_CORE_S.is_equal(
             p_line_one.source_document_line_id,
             p_line_two.source_document_line_id)))
  THEN
    x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
    x_token_name := 'REASON_FOR_DIFF';
    x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_SRC_NUM');

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  IF (p_line_two.cancel_flag = 'Y')
  THEN
    x_message_code := 'PO_ALL_CANT_COMB_CANCLD_LINE';
    x_token_name := NULL;
    x_token_value := NULL;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  IF (p_line_two.closed_code = 'FINALLY CLOSED')
  THEN
    x_message_code := 'PO_ALL_CANT_COMB_FCLOSED_LINE';
    x_token_name := NULL;
    x_token_value := NULL;

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  IF (NOT PO_CORE_S.is_equal(
        p_line_one.supplier_ref_number,
        p_line_two.supplier_ref_number))
  THEN
    x_message_code := 'PO_ALL_LINE_CANNOT_BE_COMB_STP';
    x_token_name := 'REASON_FOR_DIFF';
    x_token_value := FND_MESSAGE.GET_STRING('PO', 'PO_BW_SUPPLIER_REF_NUMBER');

    IF (PO_LOG.d_proc) THEN
      PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
      PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
      PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
    END IF;

    RETURN;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_mod, 'x_message_code', x_message_code);
    PO_LOG.proc_end(d_mod, 'x_token_name', x_token_name);
    PO_LOG.proc_end(d_mod, 'x_token_value', x_token_value);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in lines_info_match');
    END IF;

    RAISE;
END check_line_info;

-------------------------------------------------------------------------------
--Start of Comments
--Name: group_by_requisition_line_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Perform 'REQUISITION' grouping using the requisition line numbers.
--  If the req line number has already been used as the PO line number
--  for a previous req line, then NULL will be assigned.
--Parameters:
--IN:
--p_req_line_num_tbl
--  Table of requisition line numbers for the req lines in the Doc Builder.
--p_po_line_num_tbl
--  Table of PO line numbers currently assigned to the Document Builder
--  requisition lines.
--p_start_index
--  The index of the first requisition line in the input table which
--  should have a PO line number calculated (default value of 1
--  if not specified).
--p_end_index
--  The index of the last requisition line in the input table which
--  should have a PO line number calculated (default value of last
--  index in the table if not specified).
--Returns:
--  Table of PO line numbers corresponding to each of the input requisition
--  lines.
--Notes:
--  N/A
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
FUNCTION group_by_requisition_line_num
(
    p_req_line_num_tbl       IN   PO_TBL_NUMBER
,   p_po_line_num_tbl        IN   PO_TBL_NUMBER
,   p_start_index            IN   NUMBER
,   p_end_index              IN   NUMBER
)
RETURN PO_TBL_NUMBER
IS
    x_po_line_num_tbl        PO_TBL_NUMBER := p_po_line_num_tbl;

    -- BUG13778496,change index type to varchar2 in order to resolve the
    -- fraction value of requisition line num and generate decimal fraction
    -- po line num
    -- TYPE NUM_INDEX_TBL_TYPE  IS TABLE OF VARCHAR2(1) INDEX BY PLS_INTEGER;
    TYPE NUM_INDEX_TBL_TYPE  IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(40);

    l_line_num_used_tbl      NUM_INDEX_TBL_TYPE;

    d_mod CONSTANT VARCHAR2(100) := D_group_by_requisition_line;
    d_position NUMBER := 0;

BEGIN

    IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_req_line_num_tbl',p_req_line_num_tbl);
        PO_LOG.proc_begin(d_mod,'p_po_line_num_tbl',p_po_line_num_tbl);
        PO_LOG.proc_begin(d_mod,'p_start_index',p_start_index);
        PO_LOG.proc_begin(d_mod,'p_end_index',p_end_index);
    END IF;

    -- Initialize the l_line_num_used_tbl to indicate which line
    -- numbers are already assigned. We will mark a 'Y' in the associative
    -- array at the index with the value of the used line number.
    --
    FOR i IN 1..(p_start_index - 1)
    LOOP
        IF ( p_po_line_num_tbl(i) IS NOT NULL )
        THEN

            -- BUG13778496
            -- l_line_num_used_tbl(p_po_line_num_tbl(i)) := 'Y';
            l_line_num_used_tbl(TO_CHAR(p_po_line_num_tbl(i))) := 'Y';

        END IF;
    END LOOP;

    d_position := 10;

    -- Loop through and assign req line numbers as the PO line numbers
    -- if no other req line before already has that PO line number
    -- assigned.
    --
    FOR i IN p_start_index..p_end_index
    LOOP

        -- BUG13778496
        -- IF ( l_line_num_used_tbl.EXISTS(p_req_line_num_tbl(i)) )
        IF ( l_line_num_used_tbl.EXISTS(TO_CHAR(p_req_line_num_tbl(i))) )

        THEN
            x_po_line_num_tbl(i) := NULL;
        ELSE
            x_po_line_num_tbl(i) := p_req_line_num_tbl(i);

            -- BUG13778496
            -- l_line_num_used_tbl(x_po_line_num_tbl(i)) := 'Y';
            l_line_num_used_tbl(TO_CHAR(x_po_line_num_tbl(i))) := 'Y';

        END IF;
    END LOOP;

    d_position := 50;
    IF PO_LOG.d_proc THEN PO_LOG.proc_return(d_mod,x_po_line_num_tbl); END IF;

    return (x_po_line_num_tbl);

EXCEPTION

    WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,d_position); END IF;
        RAISE;

END group_by_requisition_line_num;

-------------------------------------------------------------------------------
--Start of Comments
--Name: group_by_requisition_seq_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Perform 'REQUISITION' grouping using the sequential line numbers
--  starting after the maximum line number currently in the Doc Builder
--  or on the PO being added to.
--Parameters:
--IN:
--p_po_line_num_tbl
--  Table of PO line numbers currently assigned to the Document Builder
--  requisition lines.
--p_add_to_po_header_id
--  The ID of the PO to which the requisition lines are being added
--  (will be null when creating a new PO).
--p_start_index
--  The index of the first requisition line in the input table which
--  should have a PO line number calculated (default value of 1
--  if not specified).
--p_end_index
--  The index of the last requisition line in the input table which
--  should have a PO line number calculated (default value of last
--  index in the table if not specified).
--Returns:
--  Table of PO line numbers corresponding to each of the input requisition
--  lines.
--Notes:
--  N/A
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
FUNCTION group_by_requisition_seq_num
(
    p_po_line_num_tbl      IN  PO_TBL_NUMBER
,   p_add_to_po_header_id  IN  NUMBER
,   p_start_index          IN  NUMBER
,   p_end_index            IN  NUMBER
)
RETURN PO_TBL_NUMBER
IS
    x_po_line_num_tbl          PO_TBL_NUMBER := p_po_line_num_tbl;

    l_max_line_num             NUMBER;
    l_next_line_num            NUMBER;

    d_mod CONSTANT VARCHAR2(100) := D_group_by_requisition_seq_num;
    d_position NUMBER := 0;

BEGIN

    -- Get the max line number from either the PO or the other
    -- lines in the Document Builder.
    --
    l_max_line_num := get_max_po_line_num ( p_po_line_num_tbl
                                          , p_add_to_po_header_id );

    -- Loop through and assign line numbers sequentially to each
    -- req line starting from the max line number derived above.
    --
    l_next_line_num := l_max_line_num + 1;

    FOR i IN p_start_index..p_end_index
    LOOP
        x_po_line_num_tbl(i) := l_next_line_num;
        l_next_line_num := l_next_line_num + 1;
    END LOOP;

    return (x_po_line_num_tbl);

EXCEPTION

    WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,d_position); END IF;
        RAISE;

END group_by_requisition_seq_num;

-------------------------------------------------------------------------------
--Start of Comments
--Name: group_by_default
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Defaults the PO line numbers for requisition lines in the Autocreate
--  Document Builder using the 'Default' grouping method.
--Parameters:
--IN:
--p_req_line_id_tbl
--  Table of requisition line IDs representing the Autocreate Document Builder.
--p_po_line_num_tbl
--  Table of PO line numbers currently assigned to the Document Builder
--  requisition lines. The PO line numbers for req lines within the
--  start and end index (i.e. those for which defaulting will be performed)
--  must be nulled out.
--p_consigned_flag_tbl
--  Table of Consigned Flag values corresponding to each req line in
--  p_req_line_id_tbl.
--p_add_to_po_header_id
--  The ID of the PO to which the requisition lines are being added
--  (will be null when creating a new PO).
--p_builder_agreement_id
--  The ID of the Global Agreement for which the PO will be created.
--p_start_index
--  The index of the first requisition line in the input table which
--  should have a PO line number calculated (default value of 1
--  if not specified).
--p_end_index
--  The index of the last requisition line in the input table which
--  should have a PO line number calculated (default value of last
--  index in the table if not specified).
--Returns:
--  Table of PO line numbers corresponding to each of the input requisition
--  lines.
--Notes:
--  N/A
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
FUNCTION group_by_default
(
    p_req_line_id_tbl          IN   PO_TBL_NUMBER
,   p_po_line_num_tbl          IN   PO_TBL_NUMBER
,   p_consigned_flag_tbl       IN   PO_TBL_VARCHAR1
,   p_add_to_po_header_id      IN   NUMBER
,   p_builder_agreement_id     IN   NUMBER
,   p_start_index              IN   NUMBER
,   p_end_index                IN   NUMBER
)
RETURN PO_TBL_NUMBER
IS
    l_max_line_num              NUMBER := 0;
    l_matching_index            NUMBER;
    l_po_line_num               NUMBER;
    x_po_line_num_tbl           PO_TBL_NUMBER := p_po_line_num_tbl;

    l_add_to_po_req_line_id_tbl PO_TBL_NUMBER;
    l_add_to_po_line_num_tbl    PO_TBL_NUMBER;

    d_mod CONSTANT VARCHAR2(100) := D_group_by_default;
    d_position NUMBER := 0;

BEGIN

    IF PO_LOG.d_proc THEN PO_LOG.proc_begin(d_mod); END IF;

    -- Initialize the max PO line number.
    --
    l_max_line_num := get_max_po_line_num ( p_po_line_num_tbl
                                          , p_add_to_po_header_id );

    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,d_position,'l_max_line_num',l_max_line_num); END IF;

    d_position := 10;

    -- Get nested tables of requisition lines and their corresponding
    -- matching PO line numbers from the PO being added to.
    --
    match_add_to_po_lines ( p_req_line_id_tbl
                          , p_consigned_flag_tbl
                          , p_add_to_po_header_id
                          , p_builder_agreement_id
                          , p_start_index
                          , p_end_index
                          , l_add_to_po_req_line_id_tbl -- OUT
                          , l_add_to_po_line_num_tbl    -- OUT
                          );
    d_position := 20;

    -- Loop through input nested table of req lines.
    --
    FOR i IN p_start_index..p_end_index LOOP

        l_po_line_num := NULL;

        d_position := 30;

        -- Find a matching line on the PO being added to (if one exists).
        --
        IF ( p_add_to_po_header_id IS NOT NULL )
        THEN
            l_po_line_num := find_matching_po_line_num
                             ( p_req_line_id => p_req_line_id_tbl(i)
                             , p_comparison_tbl => l_add_to_po_req_line_id_tbl
                             , p_po_line_num_tbl => l_add_to_po_line_num_tbl
                             );
            IF PO_LOG.d_stmt THEN  PO_LOG.stmt(d_mod,d_position,'Add To PO Line Num',l_po_line_num); END IF;
        END IF;

        d_position := 40;

        -- If no line was found on the PO being added to, search for any
        -- matching lines before the current line in the Doc Builder.
        --
        IF ( l_po_line_num IS NULL )
        THEN
            l_po_line_num := find_matching_builder_line_num
                             ( p_current_index => i
                             , p_req_line_id_tbl => p_req_line_id_tbl
                             , p_po_line_num_tbl => x_po_line_num_tbl
                             , p_builder_agreement_id => p_builder_agreement_id
                             );
            IF PO_LOG.d_stmt THEN  PO_LOG.stmt(d_mod,d_position,'Builder Line Num',l_po_line_num); END IF;
        END IF;

        d_position := 50;

        -- If no matching lines found in the PO or the Doc Builder,
        -- set the PO line num to the next line number and then set
        -- the new max line number.
        --
        IF ( l_po_line_num IS NULL )
        THEN
            l_max_line_num := l_max_line_num + 1;
            l_po_line_num := l_max_line_num;

            IF PO_LOG.d_stmt THEN  PO_LOG.stmt(d_mod,d_position,'Max Line Num',l_po_line_num); END IF;
        END IF;

        d_position := 60;

        x_po_line_num_tbl(i) := l_po_line_num;

    END LOOP;

    d_position := 70;

    IF PO_LOG.d_proc THEN PO_LOG.proc_return(d_mod,x_po_line_num_tbl); END IF;

    return (x_po_line_num_tbl);

EXCEPTION

    WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,d_position); END IF;
        RAISE;

END group_by_default;

-------------------------------------------------------------------------------
--Start of Comments
--Name: has_same_req_header
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Determines if all the requisition lines in the input list belong to the
--  same requisition header.
--Parameters:
--IN:
--p_req_line_id_tbl
--  Table of requisition line IDs representing the Autocreate Document Builder.
--Returns:
--  TRUE if all req lines in the input nested table belong to the same
--  requisition header; FALSE otherwise.
--Notes:
--  N/A
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
FUNCTION has_same_req_header
(
    p_req_line_id_tbl        IN   PO_TBL_NUMBER
)
RETURN BOOLEAN
IS
    l_req_header_id          NUMBER;
    l_first_req_header_id    NUMBER;

    d_mod CONSTANT VARCHAR2(100) := D_has_same_req_header;
    d_position NUMBER := 0;

BEGIN

    -- Loop through all req lines and compare their req headers
    -- with each other.
    --
    FOR i IN 1..p_req_line_id_tbl.COUNT LOOP

        d_position := 10;

        SELECT requisition_header_id
        INTO   l_req_header_id
        FROM   po_requisition_lines_all
        WHERE  requisition_line_id = p_req_line_id_tbl(i);

        d_position := 20;

        -- If first line, initialize variable for first line.
        -- Otherwise, check if the current req header matches
        -- that of the first req header.
        --
        IF ( l_first_req_header_id IS NULL ) THEN

            l_first_req_header_id := l_req_header_id;

        ELSIF ( l_req_header_id <> l_first_req_header_id ) THEN

            IF PO_LOG.d_proc THEN PO_LOG.proc_return(d_mod,FALSE); END IF;
            return (FALSE); -- return false if header does not match

        END IF;

    END LOOP;

    IF PO_LOG.d_proc THEN PO_LOG.proc_return(d_mod,TRUE); END IF;
    return (TRUE);

EXCEPTION

    WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,d_position); END IF;
        RAISE;

END has_same_req_header;

-------------------------------------------------------------------------------
--Start of Comments
--Name: match_add_to_po_lines
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Constructs a table of requisition line IDs representing the subset of
--  the input requisition lines that match at least one line on the input PO.
--  Also constructs a corresponding table of PO line numbers from the
--  mached PO lines.
--Parameters:
--IN:
--p_req_line_id_tbl
--  Table of requisition line IDs representing the Autocreate Document Builder.
--p_consigned_flag_tbl
--  Table of Consigned Flag values corresponding to each req line in
--  p_req_line_id_tbl.
--p_add_to_po_header_id
--  The ID of the PO to which the requisition lines are being added
--  (will be null when creating a new PO).
--p_builder_agreement_id
--  The ID of the Global Agreement for which the PO will be created.
--p_start_index
--  The index of the first requisition line in the input table which
--  should have a PO line number calculated (default value of 1
--  if not specified).
--p_end_index
--  The index of the last requisition line in the input table which
--  should have a PO line number calculated (default value of last
--  index in the table if not specified).
--OUT:
--x_req_line_id_tbl
--  Table of requisition line IDs that match at least one line on the PO.
--x_po_line_num_tbl
--  Table of PO line numbers representing the lines on the PO which match
--  to each of the requisition lines in x_req_line_id_tbl.
--Notes:
--  N/A
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE match_add_to_po_lines
(
    p_req_line_id_tbl        IN         PO_TBL_NUMBER
,   p_consigned_flag_tbl     IN         PO_TBL_VARCHAR1
,   p_add_to_po_header_id    IN         NUMBER
,   p_builder_agreement_id   IN         NUMBER
,   p_start_index            IN         NUMBER
,   p_end_index              IN         NUMBER
,   x_req_line_id_tbl        OUT NOCOPY PO_TBL_NUMBER
,   x_po_line_num_tbl        OUT NOCOPY PO_TBL_NUMBER
)
IS
    l_key              NUMBER;

    l_need_by_grouping_profile
                       FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
    l_ship_to_grouping_profile
                       FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;

    d_mod CONSTANT VARCHAR2(100) := D_match_add_to_po_lines;
    d_position NUMBER := 0;

BEGIN

    IF PO_LOG.d_proc THEN PO_LOG.proc_begin(d_mod); END IF;

    -- Return immediately if there is no Add To PO.
    --
    IF ( p_add_to_po_header_id IS NULL )
    THEN
        x_req_line_id_tbl := PO_TBL_NUMBER();
        x_po_line_num_tbl := PO_TBL_NUMBER();
        return;
    END IF;

    d_position := 10;

    -- Retrieve a new GT table key.
    --
    l_key := PO_CORE_S.get_session_gt_nextval;

    -- Get Profile Option values to be used in query.
    --
    l_need_by_grouping_profile := FND_PROFILE.value('PO_NEED_BY_GROUPING');
    l_ship_to_grouping_profile := FND_PROFILE.value('PO_SHIPTO_GROUPING');

    d_position := 20;
    IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'l_key',l_key);
        PO_LOG.stmt(d_mod,d_position,'l_need_by_grouping_profile',l_need_by_grouping_profile);
        PO_LOG.stmt(d_mod,d_position,'l_ship_to_grouping_profile',l_ship_to_grouping_profile);
    END IF;

    -- Bulk insert matching lines into GT table.
    --
    FORALL i IN p_start_index..p_end_index

        INSERT INTO po_session_gt
        (      key
        ,      num1
        ,      num2
        )
        SELECT DISTINCT
               l_key
        ,      prl.requisition_line_id
        ,      pol.line_num
        FROM   po_requisition_lines_all  prl
        ,      po_lines_all              pol
        ,      po_line_locations_all     pll
        ,      po_lines_all              src_line
        WHERE  pol.po_header_id = p_add_to_po_header_id
        AND    pll.po_line_id = pol.po_line_id
        AND    prl.requisition_line_id = p_req_line_id_tbl(i)
        AND    decode ( prl.item_id
                      , pol.item_id, 1, 0) = 1
        AND    ((prl.item_id IS NOT NULL OR pol.item_id IS NOT NULL)
                OR decode(
                  prl.item_description,
                  pol.item_description, 1, 0) = 1)
        AND    decode ( prl.item_revision
                      , pol.item_revision, 1, 0) = 1
        AND    decode ( prl.line_type_id
                      , pol.line_type_id, 1, 0) = 1
        AND    decode ( prl.preferred_grade
                      , pol.preferred_grade, 1, 0) = 1
        AND    decode ( prl.unit_meas_lookup_code
                      , pol.unit_meas_lookup_code, 1, 0) = 1
        AND    decode ( prl.transaction_reason_code
                      , pol.transaction_reason_code, 1, 0) = 1
        AND    decode ( prl.supplier_ref_number
                      , pol.supplier_ref_number, 1, 0) = 1
        AND    (  ( l_need_by_grouping_profile = 'N' )
               OR ( decode ( trunc(prl.need_by_date,'MI')
                           , trunc(pll.need_by_date,'MI'), 1, 0) = 1 ) )
        AND    (  ( l_ship_to_grouping_profile = 'N' )
               OR ( decode ( prl.destination_organization_id
                           , pll.ship_to_organization_id, 1, 0) = 1 ) )
        AND    (  ( prl.document_type_code <> 'CONTRACT' )
               OR ( decode ( prl.blanket_po_header_id
                           , pol.contract_id, 1, 0) = 1 ) )
        AND    src_line.po_header_id (+) = prl.blanket_po_header_id
        AND    src_line.line_num (+) = prl.blanket_po_line_num
        AND    (  ( p_builder_agreement_id IS NOT NULL )
               OR (   ( decode ( prl.blanket_po_header_id
                               , pol.from_header_id, 1, 0) = 1 )
                  AND ( decode ( src_line.po_line_id
                               , pol.from_line_id, 1, 0) = 1 ) ) )
        AND    nvl(pol.cancel_flag, 'N') <> 'Y'
        AND    nvl(pol.closed_code, 'OPEN') <> 'FINALLY CLOSED'
        AND    nvl(pll.consigned_flag, 'N') = p_consigned_flag_tbl(i);

    d_position := 30;

    -- Clean up GT table and return the results into the output tables.
    --
    DELETE FROM po_session_gt
    WHERE key = l_key
    RETURNING num1, num2
    BULK COLLECT INTO x_req_line_id_tbl, x_po_line_num_tbl;

    IF PO_LOG.d_proc THEN
        PO_LOG.proc_end(d_mod,'x_req_line_id_tbl',x_req_line_id_tbl);
        PO_LOG.proc_end(d_mod,'x_po_line_num_tbl',x_po_line_num_tbl);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,d_position); END IF;
        RAISE;

END match_add_to_po_lines;


-------------------------------------------------------------------------------
--Start of Comments
--Name: find_matching_builder_line_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Finds a matching line in the input table with index less than the
--  given current index and its PO Line Number column populated.
--Parameters:
--IN:
--p_current_index
--  The index in the nested table of the requisition line to match. The
--  search will be conducted only for indices less than this value.
--p_req_line_id_tbl
--  Nested table of requisition line IDs.
--p_po_line_num_tbl
--  Nested table of PO line numbers.
--p_builder_agreement_id
--  Global Agreement ID specified in the Doc Builder.
--Returns:
--  PO line number of the matching requisition line.
--Notes:
--  N/A
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
FUNCTION find_matching_builder_line_num
(
    p_current_index          IN   NUMBER
,   p_req_line_id_tbl        IN   PO_TBL_NUMBER
,   p_po_line_num_tbl        IN   PO_TBL_NUMBER
,   p_builder_agreement_id   IN   NUMBER
)
RETURN NUMBER
IS
    d_mod CONSTANT VARCHAR2(100) := D_find_matching_builder_line;
    d_position NUMBER := 0;

BEGIN

    -- Loop from beginning of the Doc Builder up to (but not including)
    -- the current line to look for a match.
    --
    FOR i IN 1..(p_current_index - 1)
    LOOP
        IF (   ( req_lines_match ( p_builder_agreement_id
                                 , p_req_line_id_tbl(p_current_index)
                                 , p_req_line_id_tbl(i) )
               )
           AND ( p_po_line_num_tbl(i) IS NOT NULL ) )
        THEN
            return (p_po_line_num_tbl(i)); -- return PO line num
        END IF;

    END LOOP;

    return (NULL); -- if loop completes, no matching line was found

EXCEPTION

    WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,d_position); END IF;
        RAISE;

END find_matching_builder_line_num;

-------------------------------------------------------------------------------
--Start of Comments
--Name: req_lines_match
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Determines if two requisition lines can be grouped.
--Parameters:
--IN:
--p_agreement_id
--  The ID of the Global Agreement for which the PO will be created.
--p_req_line_id_1
--  First requisition line to compare.
--p_req_line_id_2
--  Second requisition line to compare.
--Returns:
--  TRUE if all pertinent attributes match; FALSE otherwise.
--Notes:
--  N/A
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
FUNCTION req_lines_match
(
    p_agreement_id    IN   NUMBER
,   p_req_line_id_1   IN   NUMBER
,   p_req_line_id_2   IN   NUMBER
)
RETURN BOOLEAN
IS
    l_message_code         VARCHAR2(30);
    l_token_name           VARCHAR2(30);
    l_token_value          VARCHAR2(2000);

    l_result               BOOLEAN;

    d_mod CONSTANT VARCHAR2(100) := D_req_lines_match;
    d_position NUMBER := 0;

BEGIN

    IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_agreement_id',p_agreement_id);
        PO_LOG.proc_begin(d_mod,'p_req_line_id_1',p_req_line_id_1);
        PO_LOG.proc_begin(d_mod,'p_req_line_id_2',p_req_line_id_2);
    END IF;

    -- Make a call to lines_match to determine if all relevant attributes
    -- match. Note that we do not need Supplier/Site since we do not need
    -- to derive the Consigned Flag when comparing two req lines.

    --Bug#18007864:: FIX
    -- Item description Check needs to fired, so that the one time item based requisiton lines
    -- will not be grouped togather by default when having diffrent item description.

    G_check_item_desc_match := 'Y';

    lines_match ( p_agreement_id           => p_agreement_id
                , p_supplier_id            => null
                , p_site_id                => null
                , p_req_line_id            => p_req_line_id_1
                , p_req_line_id_to_compare => p_req_line_id_2
                , p_po_line_id_to_compare  => null
                , x_message_code           => l_message_code
                , x_token_name             => l_token_name
                , x_token_value            => l_token_value
                );
    IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,d_position,'l_message_code',l_message_code); END IF;

    IF ( l_message_code IS NULL )
    THEN
        l_result := TRUE;
    ELSE
        l_result := FALSE;
    END IF;

    IF PO_LOG.d_proc THEN PO_LOG.proc_return(d_mod,l_result); END IF;

    return (l_result);

EXCEPTION

    WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,d_position); END IF;
        RAISE;

END req_lines_match;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_max_po_line_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Retrieves the maximum PO line number value from either the input
--  PO or the Document Builder.
--Parameters:
--IN:
--p_po_line_num_tbl
--  Table of PO line numbers to check for maximum.
--p_po_header_id
--  ID of PO to check for maximum line number.
--Returns:
--  Maximum PO line number between the input PO and PO line number table.
--Notes:
--  N/A
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_max_po_line_num
(
    p_po_line_num_tbl        IN   PO_TBL_NUMBER
,   p_po_header_id           IN   NUMBER := NULL
)
RETURN NUMBER
IS
    x_max_po_line_num        NUMBER := 0;

    d_mod CONSTANT VARCHAR2(100) := D_get_max_po_line_num;
    d_position NUMBER := 0;

BEGIN

    IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_po_line_num_tbl',p_po_line_num_tbl);
        PO_LOG.proc_begin(d_mod,'p_po_header_id',p_po_header_id);
    END IF;

    -- Find max line number for the input PO.
    --
    IF ( p_po_header_id IS NOT NULL )
    THEN
        SELECT nvl(max(line_num), 0)
        INTO   x_max_po_line_num
        FROM   po_lines_all
        WHERE  po_header_id = p_po_header_id;
    END IF;

    -- Find max line number in the nested table of line numbers.
    --
    FOR i IN 1..p_po_line_num_tbl.COUNT
    LOOP
        IF ( p_po_line_num_tbl(i) > x_max_po_line_num )
        THEN
            x_max_po_line_num := p_po_line_num_tbl(i);
        END IF;
    END LOOP;

    -- Return max PO line number.
    --
    return (x_max_po_line_num);

EXCEPTION

    WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,d_position); END IF;
        RAISE;

END get_max_po_line_num;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_consigned_flag_tbl
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Constructs a table of the Consigned Flags corresponding to each
--  requisition line in p_req_line_id_tbl.
--Parameters:
--IN:
--p_req_line_id_tbl
--  Table of requisition lines to find the Consigned Flag for.
--p_builder_org_id
--  ID of the operating unit in which the PO will be created.
--p_builder_supplier_id
--  The ID of the Supplier for which the PO will be created.
--p_builder_site_id
--  The ID of the Site for which the PO will be created.
--Returns:
--  Table of Consigned Flags corresponding each requisition line in
--  p_req_line_id_tbl.
--Notes:
--  N/A
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_consigned_flag_tbl
(
    p_req_line_id_tbl        IN   PO_TBL_NUMBER
,   p_builder_org_id         IN   NUMBER
,   p_builder_supplier_id    IN   NUMBER
,   p_builder_site_id        IN   NUMBER
)
RETURN PO_TBL_VARCHAR1
IS
    l_item_id                NUMBER;
    x_consigned_flag_tbl     PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

    d_mod CONSTANT VARCHAR2(100) := D_get_consigned_flag_tbl;
    d_position NUMBER := 0;

BEGIN

    IF PO_LOG.d_proc THEN
        PO_LOG.proc_begin(d_mod,'p_req_line_id_tbl',p_req_line_id_tbl);
        PO_LOG.proc_begin(d_mod,'p_builder_org_id',p_builder_org_id);
        PO_LOG.proc_begin(d_mod,'p_builder_supplier_id',p_builder_supplier_id);
        PO_LOG.proc_begin(d_mod,'p_builder_site_id',p_builder_site_id);
    END IF;

    x_consigned_flag_tbl.EXTEND(p_req_line_id_tbl.COUNT);

    FOR i IN 1..p_req_line_id_tbl.COUNT LOOP

        SELECT item_id
        INTO l_item_id
        FROM po_requisition_lines_all
        WHERE requisition_line_id = p_req_line_id_tbl(i);

        IF PO_LOG.d_stmt THEN PO_LOG.stmt(d_mod,d_position,'l_item_id',l_item_id); END IF;

        x_consigned_flag_tbl(i) := PO_THIRD_PARTY_STOCK_GRP.get_consigned_flag
                                   ( p_builder_org_id
                                   , l_item_id
                                   , p_builder_supplier_id
                                   , p_builder_site_id
				   ,NULL  --Bug 5976612
                                   );
      /* Bug 5976612
      Added the 'NULL' parameter in the end for the inv org id.
      These changes are driven by the changes done to the function PO_THIRD_PARTY_STOCK_GRP.get_consigned_flag. */

    END LOOP;

    IF PO_LOG.d_proc THEN PO_LOG.proc_return(d_mod,x_consigned_flag_tbl); END IF;

    return (x_consigned_flag_tbl);

EXCEPTION

    WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,d_position); END IF;
        RAISE;

END get_consigned_flag_tbl;

-------------------------------------------------------------------------------
--Start of Comments
--Name: find_matching_po_line_num
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Finds a given ID in a table (p_comparison_tbl) and returns the
--  corresponding value from p_po_line_num_tbl for that index.
--Parameters:
--IN:
--p_req_line_id
--  Requisition line ID to search for.
--p_comparison_tbl
--  Table of requisition line IDs.
--p_po_line_num_tbl
--  Table of PO line numbers corresponding to p_comparison_tbl.
--Returns:
--  Returns the PO line number at the index for which the comparison table
--  matches the input req line ID. If the req line ID is not found in the
--  comparison table, returns NULL.
--  p_req_line_id_tbl.
--Notes:
--  N/A
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
FUNCTION find_matching_po_line_num
(
    p_req_line_id            IN   NUMBER
,   p_comparison_tbl         IN   PO_TBL_NUMBER
,   p_po_line_num_tbl        IN   PO_TBL_NUMBER
)
RETURN NUMBER
IS
    d_mod CONSTANT VARCHAR2(100) := D_find_matching_po_line_num;
    d_position NUMBER := 0;

BEGIN

    FOR i IN 1..p_comparison_tbl.COUNT
    LOOP
        IF ( p_req_line_id = p_comparison_tbl(i) )
        THEN
            return (p_po_line_num_tbl(i));
        END IF;
    END LOOP;

    return (null);

EXCEPTION

    WHEN OTHERS THEN
        IF PO_LOG.d_exc THEN PO_LOG.exc(d_mod,d_position); END IF;
        RAISE;

END find_matching_po_line_num;

-------------------------------------------------------------------------------
--Start of Comments
--Name:  check_item_description
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Checks whether a requisition line and a PO line having same Item Description
-- for one time Item Based Lines and returns the result during the Autocreate
-- process in manual mode.
--Parameters:
--IN:
--p_po_header_id
--  The ID of the add to purchase order specified in the document builder.
--p_po_line_num
--  The ID of the po line number specified in the document builder of req line.
--p_req_line_id
--  The ID of the requisition line added for autocreate to a PO.
--OUT:
--x_same_item_desc
--  The result code corresponding to whether the two lines item desc match or not.
--Notes:
-- Added as part of bug fix 16097884
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE check_item_description(
  p_po_header_id IN NUMBER,
  p_po_line_num IN NUMBER,
  p_req_line_id IN NUMBER,
  x_same_item_desc OUT NOCOPY VARCHAR2
 )
IS
  d_mod CONSTANT VARCHAR2(100) := D_check_item_description;
  d_position NUMBER := 0;

  l_req_line                    LINE_INFO;
  l_po_line                     LINE_INFO;
  l_po_line_id                  PO_LINES_ALL.PO_LINE_ID%TYPE;

BEGIN

IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_mod);
    PO_LOG.proc_begin(d_mod,'p_po_header_id',p_po_header_id);
    PO_LOG.proc_begin(d_mod,'p_po_line_num',p_po_line_num);
    PO_LOG.proc_begin(d_mod,'p_req_line_id',p_req_line_id);
  END IF;

   x_same_item_desc := 'N';

   d_position := 10;
  -- Fetch the po line id
   BEGIN
   SELECT po_line_id
   INTO l_po_line_id
   FROM po_lines_all
   WHERE po_header_id = p_po_header_id
     AND line_num  = p_po_line_num;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
	-- REQ added with New Line Added to PO during Autocreate
      x_same_item_desc := 'Y';
	  RETURN;
   END;

   d_position := 20;
   --- Get the PO Line Details
   l_po_line := get_po_line_info(l_po_line_id);

   d_position := 30;
    --- Get the Req Line Details
   l_req_line := get_req_line_info(p_req_line_id);

   d_position := 40;
    IF (l_req_line.item_id IS NULL
	    AND l_po_line.item_id IS NULL
        AND PO_CORE_S.is_equal(
            l_req_line.item_description,
            l_po_line.item_description))
   THEN
      x_same_item_desc := 'Y';
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_mod, d_position, 'An error occured in check_item_description');
    END IF;
  RAISE;

END check_item_description;

END PO_AUTOCREATE_GROUPING_PVT;

/
