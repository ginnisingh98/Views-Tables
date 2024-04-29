--------------------------------------------------------
--  DDL for Package Body PO_HEADERS_DRAFT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADERS_DRAFT_PVT" AS
/* $Header: PO_HEADERS_DRAFT_PVT.plb 120.4 2006/02/06 11:24 dedelgad noship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_HEADERS_DRAFT_PVT');

-----------------------------------------------------------------------
--Start of Comments
--Name: draft_changes_exist
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--    Checks whether there is any draft changes in the draft table
--  given the draft_id or draft_id + po_header_id
--    If only draft_id is provided, this program returns FND_API.G_TRUE for
--  any draft changes in this table for the draft
--    If the whole primary key is provided (draft_id + header id), then
--  it return true if there is draft for this particular record in
--  the draft table
--Parameters:
--IN:
--p_draft_id_tbl
--  draft unique identifier
--p_po_header_id_tbl
--  po header unique identifier
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
  p_po_header_id_tbl IN PO_TBL_NUMBER
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
                  FROM   po_headers_draft_all PHD
                  WHERE  PHD.draft_id = p_draft_id_tbl(i)
                  AND    PHD.po_header_id = NVL(p_po_header_id_tbl(i),
                                                PHD.po_header_id)
                  AND    NVL(PHD.change_accepted_flag, 'Y') = 'Y');


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
--  Same functionality as the bulk version of draft_changes_exist
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_po_header_id
--  po header unique identifier
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
  p_po_header_id IN NUMBER
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
      p_po_header_id_tbl => PO_TBL_NUMBER(p_po_header_id)
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
--  Process header draft records and merge them to transaction table. It
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

l_delete_flag PO_HEADERS_DRAFT_ALL.delete_flag%TYPE;
l_record_exists_in_txn VARCHAR2(1);
l_dml_operation VARCHAR2(10);
l_vendor_changed VARCHAR2(1);
l_vendor_site_changed VARCHAR2(1);
l_conterms_exist_flag PO_HEADERS_ALL.conterms_exist_flag%TYPE;
l_new_vendor_id PO_HEADERS_ALL.vendor_id%TYPE;
l_new_vendor_site_id PO_HEADERS_ALL.vendor_site_id%TYPE;
l_contract_document_type VARCHAR2(20);

l_return_status VARCHAR2(1);
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER;
BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_draft_info.headers_changed = FND_API.G_FALSE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'no change-no need to apply');
    END IF;

    RETURN;
  END IF;

  d_position := 10;
  SELECT NVL(PHD.delete_flag, 'N'),
         DECODE (PH.po_header_id, NULL, 'N', 'Y')
  INTO l_delete_flag, l_record_exists_in_txn
  FROM po_headers_draft_all PHD,
       po_headers_all PH
  WHERE PHD.draft_id = p_draft_info.draft_id
  AND   PHD.po_header_id = p_draft_info.po_header_Id
  AND   NVL(PHD.change_accepted_flag, 'Y') = 'Y'
  AND   PHD.po_header_id = PH.po_header_id(+);

  l_dml_operation := NULL;

  IF (l_delete_flag = 'Y') THEN
    IF (l_record_exists_in_txn = 'Y') THEN
      l_dml_operation := 'DELETE';
    END IF;
  ELSE
    IF (l_record_exists_in_txn = 'Y') THEN
      l_dml_operation := 'UPDATE';
    ELSE
      l_dml_operation := 'INSERT';
    END IF;
  END IF;

  d_position := 20;
  IF (l_dml_operation = 'UPDATE') THEN
    SELECT DECODE (PHD.vendor_id, PH.vendor_id, 'Y', 'N'),
           DECODE (PHD.vendor_site_id, PH.vendor_site_id, 'Y', 'N'),
           NVL(PH.conterms_exist_flag, 'N'),
           PHD.vendor_id,
           PHD.vendor_site_id
    INTO l_vendor_changed,
         l_vendor_site_changed,
         l_conterms_exist_flag,
         l_new_vendor_id,
         l_new_vendor_site_id
    FROM po_headers_draft_all PHD,
         po_headers_all PH
    WHERE PHD.draft_id = p_draft_info.draft_id
    AND   PHD.po_header_id = p_draft_info.po_header_id
    AND   PHD.po_header_id = PH.po_header_id;
  END IF;

  IF (l_dml_operation = 'DELETE') THEN
    -- No need to delete children because OA will handle it
    NULL;
  END IF;

  d_position := 30;
  -- transfer changes from draft to txn table
  PO_HEADERS_DRAFT_PKG.merge_changes
  ( p_draft_id => p_draft_info.draft_id
  );

  d_position := 40;
  IF (l_dml_operation = 'DELETE') THEN

    d_position := 50;

    --TODO: delete action history (Phase 2)

    FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
    ( 'PO_HEADERS',
      p_draft_info.po_header_id,
      '', '', '', '', 'Y');

    SELECT NVL(PH.conterms_exist_flag, 'N')
    INTO   l_conterms_exist_flag
    FROM   po_headers_all PH
    WHERE  po_header_id = p_draft_info.po_header_id;

    l_contract_document_type :=
      PO_CONTERMS_UTL_GRP.get_po_contract_doctype
      ( p_sub_doc_type => p_draft_info.doc_subtype
      );

    -- call contract api to delete contract terms
    OKC_TERMS_UTIL_GRP.delete_doc
    ( p_api_version     => 1.0
    , p_init_msg_list   => FND_API.G_TRUE
    , p_commit           => FND_API.G_FALSE
    , p_doc_id           => p_draft_info.po_header_id
    , p_doc_type         => l_contract_document_type
    , p_validate_commit => FND_API.G_FALSE
    , x_return_status   => l_return_status
    , x_msg_data         => l_msg_data
    , x_msg_count       => l_msg_count
    );

    d_position := 60;
    IF (l_return_status <> 'S') THEN
      -- display error
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSIF (l_dml_operation = 'UPDATE') THEN

    d_position := 70;
    IF ( (l_vendor_changed = 'Y' OR l_vendor_site_changed = 'Y')
         AND l_conterms_exist_flag = 'Y') THEN

      l_contract_document_type :=
        PO_CONTERMS_UTL_GRP.get_po_contract_doctype
        ( p_sub_doc_type => p_draft_info.doc_subtype
        );

      OKC_MANAGE_DELIVERABLES_GRP.updateExtPartyOnDeliverables
      ( p_api_version             => 1.0
      , p_bus_doc_id               => p_draft_info.po_header_id
      , p_bus_doc_type            => l_contract_document_type
      , p_external_party_id        => l_new_vendor_id
      , p_external_party_site_id  => l_new_vendor_site_id
      , x_msg_data                => l_msg_data
      , x_msg_count                => l_msg_count
      , x_return_status            => l_return_status
      );

      d_position := 80;
      IF (l_return_status <> 'S') THEN
        -- display error
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

  END IF;

  d_position := 90;

  d_position := 110;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END apply_changes;

END PO_HEADERS_DRAFT_PVT;

/
