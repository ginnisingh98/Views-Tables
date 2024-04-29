--------------------------------------------------------
--  DDL for Package Body PO_LINE_LOCATIONS_DRAFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_LOCATIONS_DRAFT_PVT" AS
/* $Header: PO_LINE_LOCATIONS_DRAFT_PVT.plb 120.3 2006/09/14 01:30:39 bao noship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_LINE_LOCATIONS_DRAFT_PVT');

-------------------------------------------------------
----------- PRIVATE PROCEDURES PROTOTYPE --------------
-------------------------------------------------------

PROCEDURE group_records_by_dml_type
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE
, x_delete_list OUT NOCOPY PO_TBL_NUMBER
, x_insert_list OUT NOCOPY PO_TBL_NUMBER
, x_update_list OUT NOCOPY PO_TBL_NUMBER
);


-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: draft_changes_exist
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--    Checks whether there is any draft changes in the draft table
--  given the draft_id or draft_id + line_location_id
--    If only draft_id is provided, this program returns FND_API.G_TRUE for
--  any draft changes in this table for the draft
--    If the whole primary key is provided (draft_id + line location id), then
--  it return true if there is draft for this particular record in
--  the draft table
--Parameters:
--IN:
--p_draft_id_tbl
--  draft unique identifier
--p_line_location_id_tbl
--  po line location unique identifier
--IN OUT:
--OUT:
--Returns:
--  Array of flags indicating whether draft changes exist for the corresponding
--  entry in the input parameter. For each entry in the returning array:
--    FND_API.G_TRUE if there are draft changes
--    FND_API.G_FALSE if there aren't draft changes
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION draft_changes_exist
( p_draft_id_tbl         IN PO_TBL_NUMBER,
  p_line_location_id_tbl IN PO_TBL_NUMBER
) RETURN PO_TBL_VARCHAR1
IS
d_api_name CONSTANT VARCHAR2(30) := 'draft_changes_exist';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_key NUMBER;
l_index_tbl      PO_TBL_NUMBER := PO_TBL_NUMBER();
l_dft_exists_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
l_dft_exists_index_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  l_index_tbl.extend(p_draft_id_tbl.COUNT);
  l_dft_exists_tbl.extend(p_draft_id_tbl.COUNT);

  FOR i IN 1..l_index_tbl.COUNT LOOP
    l_index_tbl(i) := i;
    l_dft_exists_tbl(i) := FND_API.G_FALSE;
  END LOOP;

  d_position := 10;

  l_key := PO_CORE_S.get_session_gt_nextval;

  d_position := 20;

  FORALL i IN 1..p_draft_id_tbl.COUNT
    INSERT INTO po_session_gt
    ( key,
      num1
    )
    SELECT l_key,
           l_index_tbl(i)
    FROM DUAL
    WHERE EXISTS (SELECT 1
                  FROM   po_line_locations_draft_all PLLD
                  WHERE  PLLD.draft_id = p_draft_id_tbl(i)
                  AND    PLLD.line_location_id = NVL(p_line_location_id_tbl(i),
                                                     PLLD.line_location_id)
                  AND    NVL(PLLD.change_accepted_flag, 'Y') = 'Y');


  d_position := 30;

  -- All the num1 returned from this DELETE statement are indexes for
  -- records that contain draft changes
  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1
  BULK COLLECT INTO l_dft_exists_index_tbl;

  d_position := 40;

  FOR i IN 1..l_dft_exists_index_tbl.COUNT LOOP
    l_dft_exists_tbl(l_dft_exists_index_tbl(i)) := FND_API.G_TRUE;
  END LOOP;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, '# of records that have dft changes',
                l_dft_exists_index_tbl.COUNT);
  END IF;

  RETURN l_dft_exists_tbl;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END draft_changes_exist;


-----------------------------------------------------------------------
--Start of Comments
--Name: draft_changes_exist
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--    Same functionality as the bulk version of draft_changes_exist
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_line_location_id
--  line location unique identifier
--IN OUT:
--OUT:
--Returns:
--  FND_API.G_TRUE if there are draft changes
--  FND_API.G_FALSE if there aren't draft changes
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION draft_changes_exist
( p_draft_id IN NUMBER,
  p_line_location_id IN NUMBER
) RETURN VARCHAR2
IS
d_api_name CONSTANT VARCHAR2(30) := 'draft_changes_exist';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_exists_tbl PO_TBL_VARCHAR1;
BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  l_exists_tbl :=
    draft_changes_exist
    ( p_draft_id_tbl         => PO_TBL_NUMBER(p_draft_id),
      p_line_location_id_tbl => PO_TBL_NUMBER(p_line_location_id)
    );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'exists', l_exists_tbl(1));
  END IF;

  RETURN l_exists_tbl(1);

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END draft_changes_exist;

-----------------------------------------------------------------------
--Start of Comments
--Name: apply_changes
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Process line location draft records and merge them to transaction table. It
--  also performs all additional work related specifically to the merge
--  action
--Parameters:
--IN:
--p_draft_info
--  data structure storing draft information
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE apply_changes
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE
) IS
d_api_name CONSTANT VARCHAR2(30) := 'apply_changes';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_delete_list PO_TBL_NUMBER;
l_insert_list PO_TBL_NUMBER;
l_update_list PO_TBL_NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_draft_info.line_locations_changed = FND_API.G_FALSE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'no change-no need to apply');
    END IF;

    RETURN;
  END IF;

  d_position := 10;
  group_records_by_dml_type
  ( p_draft_info  => p_draft_info
  , x_delete_list => l_delete_list
  , x_insert_list => l_insert_list
  , x_update_list => l_update_list
  );

  IF (l_delete_list.COUNT > 0) THEN
    d_position := 20;    FOR i IN 1..l_delete_list.COUNT LOOP

      PO_REQ_LINES_SV.remove_req_from_po (l_delete_list(i), 'SHIPMENT');

      FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
      ( 'PO_SHIPMENTS',
        l_delete_list(i),
        '','','','','', 'Y'
      );
    END LOOP;
  END IF;

  d_position := 30;
  -- Merge Changes
  PO_LINE_LOCATIONS_DRAFT_PKG.merge_changes
  ( p_draft_id => p_draft_info.draft_id
  );

  d_position := 40;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END apply_changes;

-- bug4176111
-----------------------------------------------------------------------
--Start of Comments
--Name: maintain_retroactive_change
--Modifies:
--Locks:
--  None
--Function:
--  Updates retroactive date at line level for blanket and SPO if there's
--  price change
--Parameters:
--IN:
--p_draft_info
--  data structure storing draft information
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE maintain_retroactive_change
( p_draft_info IN PO_DRAFTS_PVT.draft_info_rec_type
) IS
d_api_name CONSTANT VARCHAR2(30) := 'maintain_retroactive_change';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_key NUMBER;

l_po_line_id_tbl PO_TBL_NUMBER;
l_draft_id_tbl   PO_TBL_NUMBER;
l_delete_flag_tbl PO_TBL_VARCHAR1;
l_record_exist_tbl PO_TBL_VARCHAR1;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (NOT (p_draft_info.doc_type = 'PA' AND
           p_draft_info.doc_subtype = 'BLANKET') OR
      p_draft_info.line_locations_changed = FND_API.G_FALSE) THEN

    RETURN;
  END IF;


  d_position := 10;

  l_key := PO_CORE_S.get_session_gt_nextval;

  -- New price break or deleted price break trigger retroactive pricing
  INSERT INTO po_session_gt
  ( key,
    num1
  )
  SELECT l_key,
         POLLD.po_line_id
  FROM po_line_locations_draft_all POLLD,
       po_line_locations_all POLL
  WHERE POLLD.draft_id = p_draft_info.draft_id
  AND   POLLD.line_location_id = POLL.line_location_id (+)
  AND   NVL(POLLD.change_accepted_flag, 'Y') = 'Y'
  AND   (NVL(POLLD.delete_flag, 'N') = 'Y' OR
         POLL.line_location_id IS NULL);

  d_position := 20;

  -- If one of the pricing attributes get modified, it triggers
  -- retroactive pricing event as well
  INSERT INTO po_session_gt
  ( key,
    num1
  )
  SELECT l_key,
         POLLD.po_line_id
  FROM po_line_locations_draft_all POLLD,
       po_line_locations_all POLL
  WHERE POLLD.draft_id = p_draft_info.draft_id
  AND   POLLD.line_location_id = POLL.line_location_id
  AND   NVL(POLLD.change_accepted_flag, 'Y') = 'Y'
  AND   NVL(POLLD.delete_flag, 'N') = 'N'
  AND   (DECODE (POLLD.ship_to_organization_id,
                 POLL.ship_to_organization_id, 'Y', 'N') = 'N' OR
         DECODE (POLLD.ship_to_location_id,
                 POLL.ship_to_location_id, 'Y', 'N') = 'N' OR
         DECODE (POLLD.quantity,
                 POLL.quantity, 'Y', 'N') = 'N' OR
         DECODE (POLLD.price_override,
                 POLL.price_override, 'Y', 'N') = 'N' OR
         DECODE (POLLD.price_discount,
                 POLL.price_discount, 'Y', 'N') = 'N' OR
         DECODE (POLLD.start_date,
                 POLL.start_date, 'Y', 'N') = 'N' OR
         DECODE (POLLD.end_date,
                 POLL.end_date, 'Y', 'N') = 'N');

  d_position := 30;

  -- get all the lines that need to retroactively re-price
  DELETE FROM po_session_gt
  WHERE key = l_key
  RETURNING num1, p_draft_info.draft_id, NULL
  BULK COLLECT
  INTO l_po_line_id_tbl, l_draft_id_tbl, l_delete_flag_tbl;

  d_position := 40;

  PO_LINES_DRAFT_PKG.sync_draft_from_txn
  ( p_po_line_id_tbl => l_po_line_id_tbl,
    p_draft_id_tbl => l_draft_id_tbl,
    p_delete_flag_tbl => l_delete_flag_tbl,
    x_record_already_exist_tbl => l_record_exist_tbl
  );

  d_position := 50;

  FORALL i IN 1..l_po_line_id_tbl.COUNT
    UPDATE po_lines_draft_all
    SET    retroactive_date = SYSDATE
    WHERE  draft_id = p_draft_info.draft_id
    AND    po_line_id = l_po_line_id_tbl(i);


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END maintain_retroactive_change;

-------------------------------------------------------
-------------- PRIVATE PROCEDURES ---------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: group_records_by_dml_type
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Get all the draft records and separate them into three categories:
--  records to be deleted, inserted, and updated. The lists are returned
--  as arrays of numbers
--Parameters:
--IN:
--p_draft_info
--  record structure to hold draft information
--IN OUT:
--OUT:
--x_delete_list
--  IDs to be deleted from transaction table
--x_insert_list
--  IDs to be inserted in transaction table
--x_update_list
--  IDs to be updated in transaction table
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE group_records_by_dml_type
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE
, x_delete_list OUT NOCOPY PO_TBL_NUMBER
, x_insert_list OUT NOCOPY PO_TBL_NUMBER
, x_update_list OUT NOCOPY PO_TBL_NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'group_records_by_dml_type';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_id_list PO_TBL_NUMBER;
l_del_flag_list PO_TBL_VARCHAR1;
l_txn_exists_list PO_TBL_VARCHAR1;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_delete_list := PO_TBL_NUMBER();
  x_insert_list := PO_TBL_NUMBER();
  x_update_list := PO_TBL_NUMBER();

  d_position := 10;
  SELECT PLLD.line_location_id,
         NVL(PLLD.delete_flag, 'N'),
         DECODE(PLL.po_line_id, NULL, 'N', 'Y')
  BULK COLLECT
  INTO l_id_list,
       l_del_flag_list,
       l_txn_exists_list
  FROM po_line_locations_draft_all PLLD,
       po_line_locations_all PLL
  WHERE PLLD.draft_id = p_draft_info.draft_id
  AND   NVL(PLLD.change_accepted_flag, 'Y') = 'Y'
  AND   PLLD.line_location_id = PLL.line_location_id(+);

  d_position := 20;
  FOR i IN 1..l_id_list.COUNT LOOP
    IF (l_del_flag_list(i) = 'Y') THEN
      IF (l_txn_exists_list(i) = 'Y') THEN
        x_delete_list.extend;
        x_delete_list(x_delete_list.LAST) := l_id_list(i);
      END IF;
    ELSE
      IF (l_txn_exists_list(i) = 'Y') THEN
        x_update_list.extend;
        x_update_list(x_update_list.LAST) := l_id_list(i);
      ELSE
        x_insert_list.extend;
        x_insert_list(x_insert_list.LAST) := l_id_list(i);
      END IF;
    END IF;
  END LOOP;

  d_position := 30;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END group_records_by_dml_type;

END PO_LINE_LOCATIONS_DRAFT_PVT;

/
