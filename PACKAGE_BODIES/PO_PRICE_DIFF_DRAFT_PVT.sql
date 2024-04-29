--------------------------------------------------------
--  DDL for Package Body PO_PRICE_DIFF_DRAFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PRICE_DIFF_DRAFT_PVT" AS
/* $Header: PO_PRICE_DIFF_DRAFT_PVT.plb 120.2 2005/07/26 16:22 bao noship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_PRICE_DIFF_DRAFT_PVT');

-----------------------------------------------------------------------
--Start of Comments
--Name: draft_changes_exist
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--    Checks whether there is any draft changes in the draft table
--  given the draft_id or draft_id + price_differential_id
--    If only draft_id is provided, this program returns FND_API.G_TRUE for
--  any draft changes in this table for the draft
--    If the whole primary key is provided (draft_id + price differential id),
--  then it return true if there is draft for this particular record in
--  the draft table
--Parameters:
--IN:
--p_draft_id_tbl
--  draft unique identifier
--p_price_differential_id_tbl
--  po price differentials unique identifier
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
  p_price_differential_id_tbl IN PO_TBL_NUMBER
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
                  FROM   po_price_diff_draft PPDD
                  WHERE  PPDD.draft_id = p_draft_id_tbl(i)
                  AND    PPDD.price_differential_id =
                           NVL(p_price_differential_id_tbl(i),
                               PPDD.price_differential_id)
                  AND    NVL(PPDD.change_accepted_flag, 'Y') = 'Y');

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
--p_price_differential_id
--  price differential unique identifier
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
  p_price_differential_id IN NUMBER
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
    ( p_draft_id_tbl     => PO_TBL_NUMBER(p_draft_id),
      p_price_differential_id_tbl => PO_TBL_NUMBER(p_price_differential_id)
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
--  Process price diff draft records and merge them to transaction table. It
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

  IF (p_draft_info.price_diff_changed = FND_API.G_FALSE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'no change-no need to apply');
    END IF;

    RETURN;
  END IF;

  d_position := 10;
  -- Merge Changes
  PO_PRICE_DIFF_DRAFT_PKG.merge_changes
  ( p_draft_id => p_draft_info.draft_id
  );

  d_position := 20;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END apply_changes;

END PO_PRICE_DIFF_DRAFT_PVT;

/
