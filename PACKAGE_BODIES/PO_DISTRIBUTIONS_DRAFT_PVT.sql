--------------------------------------------------------
--  DDL for Package Body PO_DISTRIBUTIONS_DRAFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DISTRIBUTIONS_DRAFT_PVT" AS
/* $Header: PO_DISTRIBUTIONS_DRAFT_PVT.plb 120.3 2006/02/06 12:10 dedelgad noship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_DISTRIBUTIONS_DRAFT_PVT');

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
--  given the draft_id or draft_id + po_distribution_id
--    If only draft_id is provided, this program returns FND_API.G_TRUE for
--  any draft changes in this table for the draft
--    If the whole primary key is provided (draft_id + distribution id), then
--  it return true if there is draft for this particular record in
--  the draft table
--Parameters:
--IN:
--p_draft_id_tbl
--  draft unique identifier
--p_po_distribution_id_tbl
--  po distribution unique identifier
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
( p_draft_id_tbl IN PO_TBL_NUMBER,
  p_po_distribution_id_tbl IN PO_TBL_NUMBER
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
                  FROM   po_distributions_draft_all PDD
                  WHERE  PDD.draft_id = p_draft_id_tbl(i)
                  AND    PDD.po_distribution_id =
                           NVL(p_po_distribution_id_tbl(i),
                               PDD.po_distribution_id)
                  AND    NVL(PDD.change_accepted_flag, 'Y') = 'Y');


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
--   Same functionality as the bulk version of draft_changes_exist
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_distribution_id
--  distribution unique identifier
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
  p_po_distribution_id IN NUMBER
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
    ( p_draft_id_tbl           => PO_TBL_NUMBER(p_draft_id),
      p_po_distribution_id_tbl => PO_TBL_NUMBER(p_po_distribution_id)
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
--  Process distribution draft records and merge them to transaction table. It
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

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_draft_info.distributions_changed = FND_API.G_FALSE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'no change-no need to apply');
    END IF;

    RETURN;
  END IF;

  d_position := 20;
  -- Merge Changes
  PO_DISTRIBUTIONS_DRAFT_PKG.merge_changes
  ( p_draft_id => p_draft_info.draft_id
  );

  d_position := 30;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END apply_changes;

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
  SELECT PDD.po_distribution_id,
         NVL(PDD.delete_flag, 'N'),
         DECODE(PD.po_distribution_id, NULL, 'N', 'Y')
  BULK COLLECT
  INTO l_id_list,
       l_del_flag_list,
       l_txn_exists_list
  FROM po_distributions_draft_all PDD,
       po_distributions_all PD
  WHERE PDD.draft_id = p_draft_info.draft_id
  AND   NVL(PDD.change_accepted_flag, 'Y') = 'Y'
  AND   PDD.po_distribution_id = PD.po_distribution_id(+);

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

END PO_DISTRIBUTIONS_DRAFT_PVT;

/
