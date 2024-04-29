--------------------------------------------------------
--  DDL for Package Body PO_DRAFTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DRAFTS_PVT" AS
/* $Header: PO_DRAFTS_PVT.plb 120.32.12010000.14 2014/02/25 19:44:42 sautrive ship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_DRAFTS_PVT');


-------------------------------------------------------
----------- PRIVATE PROCEDURES PROTOTYPE --------------
-------------------------------------------------------

PROCEDURE pre_apply
( p_draft_info IN DRAFT_INFO_REC_TYPE
);

PROCEDURE set_new_revision
( p_draft_info IN DRAFT_INFO_REC_TYPE
);

PROCEDURE complete_transfer
( p_draft_info IN DRAFT_INFO_REC_TYPE,
  p_delete_draft IN VARCHAR2
);

PROCEDURE update_acceptance_status
( p_draft_id IN NUMBER,
  p_acceptance_action IN VARCHAR2
);

FUNCTION is_doc_in_updatable_state
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2
) RETURN VARCHAR2;

-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: draft_id_nextval
--Pre-reqs: None
--Modifies:
--Locks:
--Function:
--  Return next draft id from sequence PO_DRAFTS_S
--Parameters:
--IN:
--IN OUT:
--OUT:
--Returns:
--  Next draft id from sequence
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION draft_id_nextval
RETURN NUMBER IS

l_draft_id NUMBER;
BEGIN
  SELECT PO_DRAFTS_S.nextval
  INTO   l_draft_id
  FROM   DUAL;

  RETURN l_draft_id;
END draft_id_nextval;

-----------------------------------------------------------------------
--Start of Comments
--Name: transfer_draft_to_txn
--Pre-reqs: None
--Modifies:
--Locks:
--  transaction tables if update is allowed
--Function:
--  API to move the draft changes to transaction table
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_po_header_id
--  unique identifier for document with the draft changes
--p_delete_processed_draft
--  indicates whether draft changes should be removed after the process
--  If FND_API.G_TRUE, draft records will be removed after the process
--  If FND_API.G_FALSE, draft records will retain after the process
--  If 'X', drafts records except for the one in PO_DRAFTS will be removed
--    after the process
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE transfer_draft_to_txn
( p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2,
  p_draft_id IN NUMBER,
  p_po_header_id IN NUMBER,
  p_delete_processed_draft IN VARCHAR2,
  p_acceptance_action IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'transfer_draft_to_txn';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

d_api_version CONSTANT NUMBER := 1.0;

l_draft_info DRAFT_INFO_REC_TYPE;
l_status_rec PO_STATUS_REC_TYPE;
l_return_status VARCHAR2(1);
l_rebuild_attribs BOOLEAN := TRUE; -- 4902870
l_type VARCHAR2(20); -- 4902870
l_new_approval_status PO_HEADERS_ALL.AUTHORIZATION_STATUS%TYPE; --bug 9407474

BEGIN
  d_position := 0;

  SAVEPOINT transfer_draft_to_txn_sp;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_init_msg_list', p_init_msg_list);
    PO_LOG.proc_begin(d_module, 'p_draft_id', p_draft_id);
    PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
    PO_LOG.proc_begin(d_module, 'p_delete_processed_draft',
                                p_delete_processed_draft);
    PO_LOG.proc_begin(d_module, 'p_acceptance_action', p_acceptance_action);
  END IF;

  IF (FND_API.to_boolean(p_init_msg_list)) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (NOT FND_API.Compatible_API_Call
        ( p_current_version_number => d_api_version
        , p_caller_version_number  => p_api_version
        , p_api_name               => d_api_name
        , p_pkg_name               => d_pkg_name
        )
   ) THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;  -- not compatible_api

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- if acceptance action is specified, we need to propogate the action to
  -- all levels
  IF (p_acceptance_action IS NOT NULL) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'update acceptance action');
    END IF;

    update_acceptance_status
    ( p_draft_id => p_draft_id,
      p_acceptance_action => p_acceptance_action
    );
  END IF;

  d_position := 10;
  -- gather draft related information and put it into l_draft_info
  populate_draft_info
  ( p_draft_id => p_draft_id,
    p_po_header_id => p_po_header_id,
    x_draft_info => l_draft_info
  );

  IF (l_draft_info.doc_type <> 'QUOTATION') THEN

    d_position := 20;

    -- determine the new approval status for the document
    PO_DRAFT_APPR_STATUS_PVT.update_approval_status
    ( p_draft_info => l_draft_info
    , x_rebuild_attribs => l_rebuild_attribs -- Bug#4902870
    );


    -- bug4176111
    -- actions to be done before applying draft changes to txn tables
    d_position := 30;
    pre_apply
    ( p_draft_info => l_draft_info
    );

    d_position := 40;
    -- move changes from draft to transaction tables
    apply_changes
    ( p_draft_info => l_draft_info
    );

   d_position := 50;
    -- determine new revision
    set_new_revision
    ( p_draft_info => l_draft_info
    );
    l_type := PO_CATALOG_INDEX_PVT.TYPE_BLANKET; --Bug#4902870

  ELSE -- QUOTATION
    l_type := PO_CATALOG_INDEX_PVT.TYPE_QUOTATION; --Bug#4902870
    -- For quotations, there is no need to performa approval status or revision
    -- checking

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'document is quotation');
    END IF;

    d_position := 60;
    apply_changes
    ( p_draft_info => l_draft_info
    );

  END IF;

  d_position := 70;

  -- <Unified Catalog R12 Start>
  -- Generate the default translations for the Attribute TLP records.
  -- (Call this BEFORE complete_transfer because it deletes drafts)
  PO_ATTRIBUTE_VALUES_PVT.gen_draft_line_translations
  (
    p_draft_id => p_draft_id
  , p_doc_type => l_draft_info.doc_subtype
  );
  -- <Unified Catalog R12 End>

  -- mark transction as completed
  complete_transfer
  ( p_draft_info => l_draft_info,
    p_delete_draft => p_delete_processed_draft
  );

  d_position := 80;

  --bug 9407474 start
  -- Previous control flow was not taking care of the case where changes made to a 'Approved' document do not cause it to
  -- go into 'Requires Reapproval' status.
  -- While saving doc, if it is 'approved', it should not be locked. Following fix unlocks doc if it is
  -- in 'APPROVED' states.

    SELECT authorization_status
    INTO l_new_approval_status
    FROM po_headers_all
    WHERE po_header_id = p_po_header_id;

    IF(l_new_approval_status = 'APPROVED') THEN

       unlock_document(p_po_header_id);
    ELSE
    -- document can be saved by any person (not necessary buyer). So, cant determine with which role it should be locked.
    -- there is no scenario found where document does not get a locked when it is needed. Hence, leaving else part null.

       NULL ;
    END IF;

  --bug 9407474 end



  --Bug#4902870
  if(l_rebuild_attribs) then
      PO_CATALOG_INDEX_PVT.rebuild_index
      ( p_type          => l_type,
        p_po_header_id  => p_po_header_id
      );
  end if;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK TO transfer_draft_to_txn_sp;
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END transfer_draft_to_txn;


-----------------------------------------------------------------------
--Start of Comments
--Name: remove_draft_changes
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Removes all draft changes at all levels
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_exclude_ctrl_tbl
--  determines whether control table should be excluded from deletion
--  FND_API.G_TRUE if PO_DRAFTS should be excluded
--  FND_API.G_FALSE if PO_DRAFTS should not be excluded
--IN OUT:
--OUT:
--x_return_status
--  return status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE remove_draft_changes
( p_draft_id IN NUMBER,
  p_exclude_ctrl_tbl IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'remove_draft_changes';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  PO_HEADERS_DRAFT_PKG.delete_rows
  ( p_draft_id => p_draft_id,
    p_po_header_id => NULL
  );

  d_position := 10;
  PO_LINES_DRAFT_PKG.delete_rows
  ( p_draft_id => p_draft_id,
    p_po_line_id => NULL
  );

  d_position := 20;
  PO_LINE_LOCATIONS_DRAFT_PKG.delete_rows
  ( p_draft_id => p_draft_id,
    p_line_location_id => NULL
  );

  d_position := 30;
  PO_DISTRIBUTIONS_DRAFT_PKG.delete_rows
  ( p_draft_id => p_draft_id,
    p_po_distribution_id => NULL
  );

  d_position := 40;
  PO_GA_ORG_ASSIGN_DRAFT_PKG.delete_rows
  ( p_draft_id => p_draft_id,
    p_org_assignment_id => NULL
  );

  d_position := 50;
  PO_PRICE_DIFF_DRAFT_PKG.delete_rows
  ( p_draft_id => p_draft_id,
    p_price_differential_id => NULL
  );

  d_position := 60;
  PO_NOTIFICATION_CTRL_DRAFT_PKG.delete_rows
  ( p_draft_id => p_draft_id,
    p_notification_id => NULL
  );

  d_position := 70;
  PO_ATTR_VALUES_DRAFT_PKG.delete_rows
  ( p_draft_id => p_draft_id,
    p_attribute_values_id => NULL
  );

  d_position := 80;
  PO_ATTR_VALUES_TLP_DRAFT_PKG.delete_rows
  ( p_draft_id => p_draft_id,
    p_attribute_values_tlp_id => NULL
  );

  --<Enhanced Pricing Start>
  d_position := 85;
  PO_PRICE_ADJ_DRAFT_PKG.delete_rows
  ( p_draft_id => p_draft_id,
    p_price_adjustment_id => NULL
  );
  --<Enhanced Pricing End>

  d_position := 90;
  IF (NVL(p_exclude_ctrl_tbl, FND_API.G_FALSE) = FND_API.G_FALSE) THEN
    -- delete draft control table as well
    DELETE FROM po_drafts
    WHERE draft_id = p_draft_id;
  END IF;

  d_position := 100;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END remove_draft_changes;



-----------------------------------------------------------------------
--Start of Comments
--Name: populate_draft_info
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Populates record structure that holds draft information
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_po_header_id
--  document unique identifier
--IN OUT:
--OUT:
--x_draft_info
--  record that holds draft information
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE populate_draft_info
( p_draft_id IN NUMBER,
  p_po_header_id IN NUMBER,
  x_draft_info OUT NOCOPY DRAFT_INFO_REC_TYPE
) IS

d_api_name CONSTANT VARCHAR2(30) := 'populate_draft_info';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_type_lookup_code PO_HEADERS_ALL.type_lookup_code%TYPE;
l_quote_type_lookup_code PO_HEADERS_ALL.quote_type_lookup_code%TYPE;


BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_draft_info.draft_id := p_draft_id;
  x_draft_info.po_header_id := p_po_header_id;

  -- SQL What: Check whether po_header_id specified already
  --           exists in PO_HEADERS_ALL
  -- SQL Why: Need to see whether it is a new document being created
  SELECT NVL(MAX(FND_API.G_FALSE), FND_API.G_TRUE)
  INTO x_draft_info.new_document
  FROM po_headers_all POH
  WHERE POH.po_header_id = p_po_header_id;

  IF (x_draft_info.new_document = FND_API.G_TRUE) THEN
    d_position := 10;
    SELECT PHD.type_lookup_code,
           PHD.quote_type_lookup_code,
           NVL(PHD.global_agreement_flag, 'N')
    INTO   l_type_lookup_code,
           l_quote_type_lookup_code,
           x_draft_info.ga_flag
    FROM PO_HEADERS_DRAFT_ALL PHD
    WHERE PHD.po_header_id = p_po_header_id
    AND   PHD.draft_id = p_draft_id;
  ELSE
    d_position := 20;
    -- If it's not new document, then the changes may not contain header
    -- change. Get the information from the underlined transaction table
    SELECT PHA.type_lookup_code,
           PHA.quote_type_lookup_code,
           NVL(PHA.global_agreement_flag, 'N')
    INTO   l_type_lookup_code,
           l_quote_type_lookup_code,
           x_draft_info.ga_flag
    FROM PO_HEADERS_ALL PHA
    WHERE PHA.po_header_id = p_po_header_id;
  END IF;

  d_position := 30;
  IF (l_type_lookup_code = 'QUOTATION') THEN
    x_draft_info.doc_type := 'QUOTATION';
    x_draft_info.doc_subtype := l_quote_type_lookup_code;
  ELSE
    IF (l_type_lookup_code = 'STANDARD') THEN
      x_draft_info.doc_type := 'PO';
    ELSIF (l_type_lookup_code IN ('BLANKET', 'CONTRACT')) THEN
      x_draft_info.doc_type := 'PA';
    END IF;

    x_draft_info.doc_subtype := l_type_lookup_code;
  END IF;

  d_position := 40;
  -- check if header gets changed
  x_draft_info.headers_changed :=
    PO_HEADERS_DRAFT_PVT.draft_changes_exist
    ( p_draft_id => p_draft_id,
      p_po_header_id => NULL
    );

  d_position := 50;
  -- check if any line gets changed
  x_draft_info.lines_changed :=
    PO_LINES_DRAFT_PVT.draft_changes_exist
    ( p_draft_id => p_draft_id,
                  p_po_line_id => NULL
    );

  d_position := 60;
  -- check if any line location gets changed
  x_draft_info.line_locations_changed :=
    PO_LINE_LOCATIONS_DRAFT_PVT.draft_changes_exist
    ( p_draft_id => p_draft_id,
      p_line_location_id => NULL
    );

  d_position := 70;
  -- check if any distribution gets changed
  x_draft_info.distributions_changed :=
    PO_DISTRIBUTIONS_DRAFT_PVT.draft_changes_exist
    ( p_draft_id => p_draft_id,
      p_po_distribution_id => NULL
    );

  d_position := 80;
  -- check if any org assignment gets changed
  x_draft_info.ga_org_assign_changed :=
    PO_GA_ORG_ASSIGN_DRAFT_PVT.draft_changes_exist
    ( p_draft_id => p_draft_id,
      p_org_assignment_id => NULL
    );

  d_position := 90;
  -- check if price differentials gets changed
  x_draft_info.price_diff_changed :=
    PO_PRICE_DIFF_DRAFT_PVT.draft_changes_exist
    ( p_draft_id => p_draft_id,
      p_price_differential_id => NULL
    );

  d_position := 100;
  -- check if any notification control gets changed
  x_draft_info.notification_ctrl_changed :=
    PO_NOTIFICATION_CTRL_DRAFT_PVT.draft_changes_exist
    ( p_draft_id => p_draft_id,
      p_notification_id => NULL
    );

  d_position := 110;
  -- check if any attribute values record gets changed
  x_draft_info.attr_values_changed :=
    PO_ATTR_VALUES_DRAFT_PVT.draft_changes_exist
    ( p_draft_id => p_draft_id,
      p_attribute_values_id => NULL
    );

  d_position := 120;
  -- check if any attribute values record gets changed
  x_draft_info.attr_values_tlp_changed :=
    PO_ATTR_VALUES_TLP_DRAFT_PVT.draft_changes_exist
    ( p_draft_id => p_draft_id,
      p_attribute_values_tlp_id => NULL
    );

  --<Enhanced Pricing Start>
  d_position := 130;
  -- check if any price adjustment record gets changed
  x_draft_info.price_adj_changed :=
    PO_PRICE_ADJ_DRAFT_PVT.draft_changes_exist
    ( p_draft_id => p_draft_id,
      p_price_adjustment_id => NULL
    );
  --<Enhanced Pricing End>

  d_position := 140;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'draft_id', x_draft_info.draft_id);
    PO_LOG.stmt(d_module, d_position, 'po_header_id',
                                      x_draft_info.po_header_id);
    PO_LOG.stmt(d_module, d_position, 'doc_type', x_draft_info.doc_type);
    PO_LOG.stmt(d_module, d_position, 'doc_subtype', x_draft_info.doc_subtype);
    PO_LOG.stmt(d_module, d_position, 'ga_flag', x_draft_info.ga_flag);
    PO_LOG.stmt(d_module, d_position, 'new_document',
                                      x_draft_info.new_document);
    PO_LOG.stmt(d_module, d_position, 'headers_changed',
                                      x_draft_info.headers_changed);
    PO_LOG.stmt(d_module, d_position, 'lines_changed',
                                      x_draft_info.lines_changed);
    PO_LOG.stmt(d_module, d_position, 'line_locations_changed',
                                      x_draft_info.line_locations_changed);
    PO_LOG.stmt(d_module, d_position, 'distributions_changed',
                                      x_draft_info.distributions_changed);
    PO_LOG.stmt(d_module, d_position, 'ga_org_assign_changed',
                                      x_draft_info.ga_org_assign_changed);
    PO_LOG.stmt(d_module, d_position, 'price_diff_changed',
                                      x_draft_info.price_diff_changed);
    PO_LOG.stmt(d_module, d_position, 'notification_ctrl_changed',
                                      x_draft_info.notification_ctrl_changed);
    PO_LOG.stmt(d_module, d_position, 'attribute_values_changed',
                                      x_draft_info.attr_values_changed);
    PO_LOG.stmt(d_module, d_position, 'attribute_values_tlp_changed',
                                      x_draft_info.attr_values_tlp_changed);
    --Enhanced Pricing
    PO_LOG.stmt(d_module, d_position, 'price_adjustments_changed',
                                      x_draft_info.price_adj_changed);
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
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END populate_draft_info;

-- bug4176111
-----------------------------------------------------------------------
--Start of Comments
--Name: pre_apply
--Function: This is the procedure to call before any draft data is moved
--          to transaction table
--
--Parameters:
--IN:
--p_draft_info
--  record structure that holds draft information
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------

PROCEDURE pre_apply
( p_draft_info IN DRAFT_INFO_REC_TYPE
) IS
d_api_name CONSTANT VARCHAR2(30) := 'pre_apply';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_position := 0;

  PO_LINES_DRAFT_PVT.maintain_retroactive_change
  ( p_draft_info => p_draft_info
  );

  d_position := 10;

  PO_LINE_LOCATIONS_DRAFT_PVT.maintain_retroactive_change
  ( p_draft_info => p_draft_info
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
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END pre_apply;





-----------------------------------------------------------------------
--Start of Comments
--Name: find_draft
--Function: Find a non-completed draft that meets the search criteria. It also
--          returns extra information about the draft
--
--Parameters:
--IN:
--p_po_header_id
--  document id
--IN OUT:
--x_draft_id
--  The draft id identifying the draft changes.
--x_draft_status
--  Status of the draft
--x_draft_owner_role
--  Owner role of the draft
--OUT:
--End of Comments
------------------------------------------------------------------------

PROCEDURE find_draft
( p_po_header_id IN NUMBER,
  x_draft_id OUT NOCOPY NUMBER,
  x_draft_status OUT NOCOPY VARCHAR2,
  x_draft_owner_role OUT NOCOPY VARCHAR2
) IS
d_api_name CONSTANT VARCHAR2(30) := 'find_draft';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  --SQL What: Search for a non-completed draft given the document id
  --SQL Why:
  SELECT DFT.draft_id,
         DFT.status,
         DFT.owner_role
  INTO x_draft_id,
       x_draft_status,
       x_draft_owner_role
  FROM po_drafts DFT
  WHERE DFT.document_id = p_po_header_id
  AND DFT.status <> g_status_COMPLETED;

  d_position := 10;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'draft_id', x_draft_id);
    PO_LOG.proc_end(d_module, 'draft_status', x_draft_status);
    PO_LOG.proc_end(d_module, 'draft_owner_role', x_draft_owner_role);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  x_draft_id := NULL;
  x_draft_status := NULL;
  x_draft_owner_role := NULL;
WHEN OTHERS THEN
  x_draft_id := NULL;
  x_draft_status := NULL;
  x_draft_owner_role := NULL;
END find_draft;

-----------------------------------------------------------------------
--Start of Comments
--Name: find_draft
--Function: Find a non-completed draft that meets the search criteria.
--          This is an overloadded procedure
--Parameters:
--IN:
--p_po_header_id
--  document id
--IN OUT:
--x_draft_id
--  The draft id identifying the draft changes.
--OUT:
--End of Comments
------------------------------------------------------------------------

PROCEDURE find_draft
( p_po_header_id IN NUMBER,
  x_draft_id OUT NOCOPY NUMBER
) IS
d_api_name CONSTANT VARCHAR2(30) := 'find_draft';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_draft_status PO_DRAFTS.status%TYPE;
l_draft_owner_role PO_DRAFTS.owner_role%TYPE;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  find_draft
  ( p_po_header_id => p_po_header_id,
    x_draft_id => x_draft_id,
    x_draft_status => l_draft_status,
    x_draft_owner_role => l_draft_owner_role
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'draft_id', x_draft_id);
    PO_LOG.proc_end(d_module);
  END IF;
END find_draft;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_request_id
--Function:
--  Get request id that is processing the draft
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--IN OUT:
--OUT:
--x_request_id
--  request_id processing the draft
--Returns:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_request_id
( p_draft_id IN NUMBER,
  x_request_id OUT NOCOPY NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'get_request_id';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT request_id
  INTO   x_request_id
  FROM   po_drafts
  WHERE  draft_id = p_draft_id;

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
END get_request_id;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_lock_owner_info
--Function:
--  Gets lock owner and role info for the document in transaction table.
--  This
--Parameters:
--IN:p_po_header_id
--  document header id
--IN OUT:
--OUT:
--x_lock_owner_role
--  role of the user locking the document
--x_lock_owner_user_id
--  id of the user having control of the document
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_lock_owner_info
( p_po_header_id IN NUMBER,
  x_lock_owner_role OUT NOCOPY VARCHAR2,
  x_lock_owner_user_id OUT NOCOPY NUMBER
) IS
d_api_name CONSTANT VARCHAR2(30) := 'get_lock_owner_info';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  --SQL What: get information about the user locking the document
  --SQL Why: these are the values getting returned
  SELECT lock_owner_role,
         lock_owner_user_id
  INTO   x_lock_owner_role,
         x_lock_owner_user_id
  FROM   po_headers_all
  WHERE  po_header_id = p_po_header_id;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  x_lock_owner_role := NULL;
  x_lock_owner_user_id := NULL;

END get_lock_owner_info;

-----------------------------------------------------------------------
--Start of Comments
--Name: set_lock_owner_info
--Function:
--  sets lock owner and role info for the document in transaction table.
--  This
--Parameters:
--IN:
--p_po_header_id
--  document header id
--p_role
--  role of the user
--p_role_user_id
--  user id of the user
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------
PROCEDURE set_lock_owner_info
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_role_user_id IN NUMBER
) IS
d_api_name CONSTANT VARCHAR2(30) := 'set_lock_owner_info';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_role', p_role);
    PO_LOG.proc_begin(d_module, 'p_role_user_id', p_role_user_id);
  END IF;

  --SQL What: update lock owner role and lock owner id
  --SQL Why: This is what this procedure is doing
  UPDATE po_headers_all
  SET lock_owner_role = p_role,
      lock_owner_user_id = p_role_user_id
  WHERE po_header_id = p_po_header_id;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
END set_lock_owner_info;


-----------------------------------------------------------------------
--Start of Comments
--Name: update_permission_check
--Function:
--  Checks whether user can update the document based on draft and
--  functional locking status - This is just a subset of checks to determine
--  whether a document can be updated
--Parameters:
--IN:
--p_calling_module
--  indicate where this API is invoked from
--p_po_header_id
--  document header id
--p_role
--  role of the user
--IN OUT:
--OUT:
--x_update_allowed
--  indicates whether user has
--  authority to update the document
--x_lock_applicable
--  returns whether locking is applicable for the document
--x_unlock_required
--  if update is allowed, checks whether unlock needs to be done before
--  updating
--x_message
--  placeholder for whatever error message that prevents the document
--  from being updatable
--End of Comments
------------------------------------------------------------------------

PROCEDURE update_permission_check
( p_calling_module IN VARCHAR2,
  p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_skip_cat_upload_chk IN VARCHAR2,
  x_update_allowed OUT NOCOPY VARCHAR2,
  x_locking_applicable OUT NOCOPY VARCHAR2,
  x_unlock_required OUT NOCOPY VARCHAR2,
  x_message OUT NOCOPY VARCHAR2
) IS
d_api_name CONSTANT VARCHAR2(30) := 'update_permission_check';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_draft_id PO_DRAFTS.draft_id%TYPE;
l_draft_status PO_DRAFTS.status%TYPE;
l_draft_owner_role PO_DRAFTS.owner_role%TYPE;

l_calling_module            VARCHAR2(100);
l_upload_in_progress        VARCHAR2(1);
l_upload_status_code        VARCHAR2(30);
l_upload_requestor_role     PO_DRAFTS.owner_role%TYPE;
l_upload_requestor_role_id  PO_DRAFTS.owner_user_id%TYPE;
l_upload_job_number         NUMBER;
l_upload_status_display     VARCHAR2(80);

l_authorization_status PO_HEADERS_ALL.authorization_status%TYPE;
l_supplier_auth_enabled PO_HEADERS_ALL.supplier_auth_enabled_flag%TYPE;
l_cat_admin_auth_enabled PO_HEADERS_ALL.cat_admin_auth_enabled_flag%TYPE;
l_current_lock_owner_role PO_HEADERS_ALL.lock_owner_role%TYPE;
l_current_lock_owner_id PO_HEADERS_ALL.lock_owner_user_id%TYPE;

l_updatable_state VARCHAR2(1); -- bug5532550
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_update_allowed := FND_API.G_TRUE;
  x_locking_applicable := FND_API.G_TRUE;
  x_unlock_required := FND_API.G_FALSE;

  -- Default calling module if one is not specified
  l_calling_module := NVL(p_calling_module, g_call_mod_UNKNOWN);

  IF (p_po_header_id IS NULL) THEN
    d_position := 10;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt (d_module, d_position, 'no po header id. Quitting');
    END IF;

    -- no document to check. Simply return
    RETURN;
  END IF;

-- Bug 13037956 starts
-- Getting the lock owner role details before so that based on the lock owner and current role
-- appropriate mesage can be displayed to the user.

  d_position := 15;

  get_lock_owner_info
  ( p_po_header_id    => p_po_header_id,
    x_lock_owner_role => l_current_lock_owner_role,
    x_lock_owner_user_id   => l_current_lock_owner_id
  );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, 'lock owner role', l_current_lock_owner_role);
    PO_LOG.stmt (d_module, d_position, 'lock owner user id', l_current_lock_owner_id);
	PO_LOG.stmt (d_module, d_position, 'p_calling_module', p_calling_module);
	PO_LOG.stmt (d_module, d_position, 'p_role', p_role);

  END IF;
-- Bug 13037956 ends

  d_position := 20;
  -- search for any non-completed draft
  find_draft
  ( p_po_header_id     => p_po_header_id,
    x_draft_id         => l_draft_id,
    x_draft_status     => l_draft_status,
    x_draft_owner_role => l_draft_owner_role
  );
  --Bug 16369813, reposition this call. This position same as 12.0 code line
  x_locking_applicable := is_locking_applicable
                          ( p_po_header_id => p_po_header_id,
                            p_role => p_role
                          );
  --end Bug 16369813

  IF (l_draft_id IS NOT NULL) THEN

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt (d_module, d_position, 'has active draft');
    END IF;

    d_position := 30;

    -- modules other than HTML UI or PDOI cannot handle draft changes
    --<Bug#4382472>
    --Added FORMS PO SUMMARY module to the list as we would allow the breaking of the lock from PO Summary
    --Form.
    -- bug 5358300
    -- Added g_call_mod_HTML_UI_SAVE to the list as we would allow online save operations on the document
    IF ( l_calling_module NOT IN (g_call_mod_HTML_UI, g_call_mod_HTML_UI_SAVE, g_call_mod_PDOI, g_call_mod_FORMS_PO_SUMMARY)) THEN
      x_message := 'PO_DOC_LOCKED';
      x_update_allowed := FND_API.G_FALSE;
	  RETURN;
    END IF;

    -- Disallow update if one of the following is true
    -- 1) status of the draft is 'IN PROCESS', meaning it's pending for buyer
    --    acceptance
    -- 2) status is PDOI PROCESSING, and the calling module is not PDOI
    --    (status = PDOI PROCESSING may mean that there was an unhandled
    --     exception during PDOI. Within PDOI there is code to handle
    --     such case to recover the document so we do not want to prevent
    --     PDOI from processing this document here)
    IF (l_draft_status = g_status_IN_PROCESS ) THEN
      x_message := 'PO_BUYER_ACCEPTANCE_PENDING';
      x_update_allowed := FND_API.G_FALSE;
      RETURN;

    ELSIF (l_draft_status = g_status_PDOI_PROCESSING AND
           l_calling_module <> g_call_mod_PDOI ) THEN

      x_message := 'PO_UPLOAD_PENDING_RUNNING';
      x_update_allowed := FND_API.G_FALSE;
      RETURN;

      -- Bug 13037956 :
      -- if the lock owner is same as current role and there is error, he should face error
      -- If the lock owner is Buyer and Cat.Admin/Supplier is the current role,
      -- then user should see the error as the "Document is locked by other Role"
      -- if the lock owner is Cat.Admin/Supplier and Buyer is the current role,
      -- the user should get a warning and  he can break the lock and continue
      -- If the Upload failure is due to PDOI Error, then also the USer will see the
      -- Standard Upload Error, In View Upload Errors, he/she will be able to see the exact error message.
    ELSIF (l_draft_status = g_status_PDOI_ERROR
	         AND l_calling_module <> g_call_mod_PDOI) THEN
         if(l_current_lock_owner_role = p_role OR l_current_lock_owner_role IS NULL) THEN
            x_message := 'PO_UPLOAD_ERROR';
            x_update_allowed := FND_API.G_FALSE;
			RETURN;
         ELSE
           x_message := 'PO_DOC_LOCKED_BY_OTHER_ROLE';
		   IF(p_role <> PO_GLOBAL.g_role_BUYER) THEN
              x_update_allowed := FND_API.G_FALSE;
		   ELSE
             x_unlock_required := FND_API.G_TRUE;
           END IF;
     -- Bug 13037956 ends
      RETURN;
      END IF;

    END IF;
  END IF;

  d_position := 40;

  IF ( NVL(p_skip_cat_upload_chk, FND_API.G_FALSE) = FND_API.G_FALSE) THEN
    -- Call iP API to see if there is catalog uploading activity. If so,
    -- Prevent locking

    -- bug5014131
    -- Changed the API call to the one that checks any in progress upload
    get_in_process_upload_info
    ( p_po_header_id => p_po_header_id,
      x_upload_in_progress => l_upload_in_progress,
      x_upload_status_code => l_upload_status_code,
      x_upload_requestor_role => l_upload_requestor_role,
      x_upload_requestor_role_id => l_upload_requestor_role_id,
      x_upload_job_number => l_upload_job_number,
      x_upload_status_display => l_upload_status_display
    );

    IF (l_upload_in_progress = FND_API.G_TRUE) THEN
      IF (l_upload_status_code IN (g_upload_status_PENDING, g_upload_status_RUNNING)) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt (d_module, d_position, 'in progress catalog upload');
		  PO_LOG.stmt (d_module, d_position, 'x_update_allowed', x_update_allowed);
		  PO_LOG.stmt (d_module, d_position, 'x_unlock_required', x_unlock_required);
		  PO_LOG.stmt (d_module, d_position, 'x_locking_applicable', x_locking_applicable);
        END IF;

        x_message := 'PO_UPLOAD_PENDING_RUNNING';
        x_update_allowed := FND_API.G_FALSE;
        RETURN;
      ELSIF (l_upload_status_code = g_upload_status_ERROR) THEN
         IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt (d_module, d_position, 'errored catalog upload');
		  PO_LOG.stmt (d_module, d_position, 'x_update_allowed', x_update_allowed);
		  PO_LOG.stmt (d_module, d_position, 'x_unlock_required', x_unlock_required);
		  PO_LOG.stmt (d_module, d_position, 'x_locking_applicable', x_locking_applicable);
		 END IF;
          -- Bug 13037956 :
          -- if the lock owner is same as current role and there is error, he should face error
          -- If the lock owner is Buyer and Cat.Admin/Supplier is the current role,
          -- then user should see the error as the "Document is locked by other Role"
          -- if the lock owner is Cat.Admin/Supplier and Buyer is the current role,
          -- the user should get a warning and  he can break the lock and continue

         IF(l_upload_requestor_role = p_role) THEN
            x_message := 'PO_UPLOAD_ERROR';
            x_update_allowed := FND_API.G_FALSE;

            RETURN;
         ELSE
           x_message := 'PO_DOC_LOCKED_BY_OTHER_ROLE';
           IF(p_role <> PO_GLOBAL.g_role_BUYER) THEN
            x_update_allowed := FND_API.G_FALSE;

           ELSE
             x_unlock_required := FND_API.G_TRUE;
		   END IF;

            RETURN;
         END IF;
    END IF;
  END IF;
  END IF;
-- Bug 13037956 ends

  --Leave this check here, so that above error check populate x_message and x_update_allowed
  -- return back to call module.
  IF (x_locking_applicable = FND_API.G_FALSE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt (d_module, d_position, 'locking is not applicable');
    END IF;

    -- if locking is not applicable, then we are done with the checks.
    -- simply return
    RETURN;
  END IF;
  d_position := 50;

  IF (p_role = PO_GLOBAL.g_role_SUPPLIER) THEN
    l_supplier_auth_enabled :=
      get_supplier_auth_enabled_flag
      ( p_po_header_id => p_po_header_id
      );

    -- supplier is allowed to get the lock only if the document is enabled
    -- for supplier authoring
    IF (NVL(l_supplier_auth_enabled, 'N') = 'N') THEN
      x_message := 'PO_UPDATE_NOT_ALLOWED';
      x_update_allowed := FND_API.G_FALSE;
      RETURN;
    END IF;
  END IF;

  IF (p_role = PO_GLOBAL.g_role_CAT_ADMIN) THEN
    l_cat_admin_auth_enabled :=
      get_cat_admin_auth_enable_flag
      ( p_po_header_id => p_po_header_id
      );

    -- cat admin is allowed to get the lock only if the document is enabled
    -- for Cat Admin authoring
    IF (NVL(l_cat_admin_auth_enabled, 'N') = 'N') THEN
      x_message := 'PO_UPDATE_NOT_ALLOWED';
      x_update_allowed := FND_API.G_FALSE;
      RETURN;
    END IF;
  END IF;

  d_position := 55;

  SELECT NVL(authorization_status, 'INCOMPLETE')
  INTO l_authorization_status
  FROM po_headers_all
  WHERE po_header_id = p_po_header_id;

  -- do not allow document update by non-buyer role if
  -- document is not in INCOMPLETE or APPROVED status
  IF ( p_role <> PO_GLOBAL.g_role_BUYER AND
       l_authorization_status NOT IN ('INCOMPLETE', 'APPROVED')) THEN

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt (d_module, d_position, 'auth status = ' ||
       l_authorization_status || '. This role cannot update the document ' ||
       'in this status');
    END IF;

    x_message := 'PO_AUTH_STATUS_ERROR';
    x_update_allowed := FND_API.G_FALSE;
    RETURN;
  END IF;

  -- bug5532550 START
  -- Check and make sure that the document is in a state allowing
  -- updates

  l_updatable_state := is_doc_in_updatable_state
                       ( p_po_header_id => p_po_header_id,
                         p_role => p_role
                       );

  IF ( l_updatable_state = FND_API.G_FALSE ) THEN
    x_message := 'PO_ALL_CADM_DOC_CANT_BE_OPENED';
    x_update_allowed := FND_API.G_FALSE;
    RETURN;
  END IF;

  -- bug5532550 END

  -- Bug 13037956 : Moved the call to get_lock_owner_info up as the lock_owner infor was needed
  -- to show the appropriate error message can be shown based on lock owner role

  IF ( l_calling_module in (g_call_mod_HTML_UI,g_call_mod_FORMS_PO_SUMMARY)) THEN --<Bug4382472>

    d_position := 70;

    IF (p_role = l_current_lock_owner_role OR
        l_current_lock_owner_role IS NULL) THEN

      -- In HTML, a role can update the document if
      -- the same role is currently locking the document OR
      -- nobody is locking the document

      -- In such cases, we can simply take the default value of the
      -- update_allowed_flag (FND_API.G_TRUE)
      NULL;
    ELSIF (p_role = PO_GLOBAL.g_role_BUYER) THEN
      x_message := 'PO_DOC_LOCKED_BY_OTHER_ROLE';
      -- if role is buyer and the role currently locking the document
      -- is different, we need to unlock the document first
      x_unlock_required := FND_API.G_TRUE;
	  RETURN;
    ELSE
      -- cannot update - role is not BUYER and it is currently locked
      -- by somebody else
      x_message := 'PO_DOC_LOCKED_BY_OTHER_ROLE';
      x_update_allowed := FND_API.G_FALSE;
      RETURN;
    END IF;

  ELSIF (l_calling_module in (g_call_mod_HTML_UI_SAVE)) THEN
    -- bug 5358300
    -- call during html save operation
    -- current role must have lock on document
    d_position := 80;

    -- If coming from html save operation, nobody has update authority
    -- if document is currently locked by some other role

    IF (p_role <> l_current_lock_owner_role) THEN
      x_message := 'PO_DOC_LOCKED_BY_OTHER_ROLE';
      x_update_allowed := FND_API.G_FALSE;
      RETURN;
    END IF;

  ELSE
    d_position := 90;

    -- If coming from anywhere else, nobody has update authority
    -- if document is currently locked by some other role

    IF (p_role <> l_current_lock_owner_role) THEN
      x_message := 'PO_DOC_LOCKED';
      x_update_allowed := FND_API.G_FALSE;
      RETURN;
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
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END update_permission_check;

-- update_permission_check - 2
PROCEDURE update_permission_check
( p_calling_module IN VARCHAR2,
  p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_skip_cat_upload_chk IN VARCHAR2,
  x_update_allowed OUT NOCOPY VARCHAR2,
  x_locking_applicable OUT NOCOPY VARCHAR2,
  x_unlock_required OUT NOCOPY VARCHAR2,
  x_message OUT NOCOPY VARCHAR2,
  x_token_name_tbl OUT NOCOPY PO_TBL_VARCHAR30,
  x_token_value_tbl OUT NOCOPY PO_TBL_VARCHAR2000
) IS

l_num_records NUMBER;
l_style_name PO_DOC_STYLE_HEADERS.style_name%TYPE;

BEGIN
  update_permission_check
  ( p_calling_module      => p_calling_module,
    p_po_header_id        => p_po_header_id,
    p_role                => p_role,
    p_skip_cat_upload_chk => p_skip_cat_upload_chk,
    x_update_allowed      => x_update_allowed,
    x_locking_applicable  => x_locking_applicable,
    x_unlock_required     => x_unlock_required,
    x_message             => x_message
  );

  x_token_name_tbl := PO_TBL_VARCHAR30();
  x_token_value_tbl := PO_TBL_VARCHAR2000();

  IF (x_update_allowed = FND_API.G_TRUE) THEN
    RETURN;
  END IF;

  l_style_name := PO_DOC_STYLE_PVT.get_style_display_name
                  (p_doc_id => p_po_header_id);

  IF (x_message IN ('PO_DOC_LOCKED', 'PO_UPDATE_NOT_ALLOWED',
                'PO_AUTH_STATUS_ERROR', 'PO_DOC_LOCKED_BY_OTHER_ROLE',
                'PO_UPLOAD_PENDING_RUNNING', 'PO_UPLOAD_ERROR',
                'PO_BUYER_ACCEPTANCE_PENDING',
                'PO_LOCKED_BY_PDOI_ERR')) THEN
    x_token_name_tbl := PO_TBL_VARCHAR30 ('STYLE_NAME');
    x_token_value_tbl := PO_TBL_VARCHAR2000 (l_style_name);
  END IF;

END update_permission_check;

-- update_permission_check - 3
PROCEDURE update_permission_check
( p_calling_module IN VARCHAR2,
  p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_skip_cat_upload_chk IN VARCHAR2,
  x_update_allowed OUT NOCOPY VARCHAR2,
  x_locking_applicable OUT NOCOPY VARCHAR2,
  x_unlock_required OUT NOCOPY VARCHAR2,
  x_message OUT NOCOPY VARCHAR2,
  x_message_text OUT NOCOPY VARCHAR2
) IS

l_token_name_tbl PO_TBL_VARCHAR30;
l_token_value_tbl PO_TBL_VARCHAR2000;

BEGIN
  update_permission_check
  ( p_calling_module      => p_calling_module,
    p_po_header_id        => p_po_header_id,
    p_role                => p_role,
    p_skip_cat_upload_chk => p_skip_cat_upload_chk,
    x_update_allowed      => x_update_allowed,
    x_locking_applicable  => x_locking_applicable,
    x_unlock_required     => x_unlock_required,
    x_message             => x_message,
    x_token_name_tbl      => l_token_name_tbl,
    x_token_value_tbl     => l_token_value_tbl
  );

  IF (x_update_allowed = FND_API.G_TRUE) THEN
    RETURN;
  END IF;

  FND_MESSAGE.set_name ('PO', x_message);
  FOR i IN 1..l_token_name_tbl.COUNT LOOP
    FND_MESSAGE.set_token (l_token_name_tbl(i), l_token_value_tbl(i));
  END LOOP;

  x_message_text := FND_MESSAGE.get;

END update_permission_check;


-----------------------------------------------------------------------
--Start of Comments
--Name: unlock_document
--Function: unlock the document by setting role and role id to null
--Parameters:
--IN:
--p_po_header_id
--document header id
--IN OUT:
--OUT:
--End of Comments
------------------------------------------------------------------------

PROCEDURE unlock_document
( p_po_header_id IN NUMBER
) IS
d_api_name CONSTANT VARCHAR2(30) := 'unlock_document';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_draft_id PO_DRAFTS.draft_id%TYPE;
l_draft_status PO_DRAFTS.status%TYPE;
l_draft_owner_role PO_DRAFTS.owner_role%TYPE;

l_return_status VARCHAR2(1);

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  find_draft
  ( p_po_header_id => p_po_header_id,
    x_draft_id => l_draft_id,
    x_draft_status => l_draft_status,
    x_draft_owner_role => l_draft_owner_role
  );

  IF ( l_draft_id IS NOT NULL ) THEN
    d_position := 10;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'need to remove draft changes');
    END IF;

    PO_DRAFTS_PVT.remove_draft_changes
    ( p_draft_id => l_draft_id,
      p_exclude_ctrl_tbl => FND_API.G_FALSE,
      x_return_status => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

 -- unlock document by setting lock owner role to NULL
  set_lock_owner_info
  ( p_po_header_id => p_po_header_id,
    p_role => NULL,
    p_role_user_id => NULL
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

END unlock_document;



-----------------------------------------------------------------------
--Start of Comments
--Name: lock_document
--Function:
--  Set document lock of the document. it first unlocks the document, removes
--  draft changes before locking
--Parameters:
--IN:
--p_po_header_id
--  document header id
--p_role
--  role of the user
--p_role_user_id
--  role id of the user
--p_unlock_current
--  indicates whether the document needs to go through draft cleanup
--IN OUT:
--OUT:
--RETURNS
--
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_document
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_role_user_id IN NUMBER,
  p_unlock_current IN VARCHAR2
) IS
d_api_name CONSTANT VARCHAR2(30) := 'lock_document';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_locking_applicable VARCHAR2(1);
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  l_locking_applicable := is_locking_applicable
                          ( p_po_header_id => p_po_header_id,
                            p_role         => p_role
                          );

  IF (l_locking_applicable = FND_API.G_FALSE) THEN
    RETURN;
  END IF;

  IF (p_unlock_current = FND_API.G_TRUE) THEN
    unlock_document
    ( p_po_header_id => p_po_header_id
    );
  END IF;

  d_position := 10;
  set_lock_owner_info
  ( p_po_header_id => p_po_header_id,
    p_role => p_role,
    p_role_user_id => p_role_user_id
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
END lock_document;


-----------------------------------------------------------------------
--Start of Comments
--Name: is_locking_applicable
--Function:
--  check whether locking of the document is required
--Parameters:
--IN:
--p_po_header_id
--  document header id
--p_role
--  role of the user
--End of Comments
------------------------------------------------------------------------
FUNCTION is_locking_applicable
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'is_locking_applicable';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_applicable VARCHAR2(1) := FND_API.G_TRUE;

l_type_lookup_code PO_HEADERS_ALL.type_lookup_code%TYPE;
l_ga_flag PO_HEADERS_ALL.global_agreement_flag%TYPE;
l_approved_date PO_HEADERS_ALL.approved_date%TYPE;
l_current_lock_owner_role PO_HEADERS_ALL.lock_owner_role%TYPE;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- SQL What: Get several columns from PO tables
  -- SQL Why: Need all these columns to determine whether locking
  --          is applicable
  SELECT type_lookup_code,
         NVL(global_agreement_flag, 'N'),
         approved_date,
         lock_owner_role
  INTO   l_type_lookup_code,
         l_ga_flag,
         l_approved_date,
         l_current_lock_owner_role
  FROM   po_headers_all
  WHERE  po_header_id = p_po_header_id;

  -- locking is applicable only for global blanket agreement
  IF (NOT (l_type_lookup_code = 'BLANKET' AND l_ga_flag = 'Y')) THEN

    l_applicable := FND_API.G_FALSE;

  ELSIF ( l_current_lock_owner_role IS NULL AND
          p_role = PO_GLOBAL.g_role_BUYER AND
          l_approved_date IS NULL ) THEN

    l_applicable := FND_API.G_FALSE;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'l_applicable', l_applicable);
  END IF;

  RETURN l_applicable;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  l_applicable := FND_API.G_FALSE;
  RETURN l_applicable;
END is_locking_applicable;

-----------------------------------------------------------------------
--Start of Comments
--Name: is_draft_applicable
--Function:
--  check whether the document can have pending drafts
--Parameters:
--IN:
--p_po_header_id
--  document header id
--p_role
--  role of the user
--End of Comments
------------------------------------------------------------------------
FUNCTION is_draft_applicable
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'is_draft_applicable';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_applicable VARCHAR2(1) := FND_API.G_TRUE;

l_type_lookup_code PO_HEADERS_ALL.type_lookup_code%TYPE;
l_ga_flag PO_HEADERS_ALL.global_agreement_flag%TYPE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- SQL What: Get several columns from PO tables
  -- SQL Why: Need all these columns to determine whether locking
  --          is applicable
  SELECT type_lookup_code,
         NVL(global_agreement_flag, 'N')
  INTO   l_type_lookup_code,
         l_ga_flag
  FROM   po_headers_all
  WHERE  po_header_id = p_po_header_id;

  d_position := 10;

  -- locking is applicable only for global blanket agreement
  IF (NOT (l_type_lookup_code = 'BLANKET' AND l_ga_flag = 'Y')) THEN

    l_applicable := FND_API.G_FALSE;

  ELSIF ( p_role = PO_GLOBAL.g_role_BUYER) THEN

    l_applicable := FND_API.G_FALSE;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'l_applicable', l_applicable);
  END IF;

  RETURN l_applicable;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  l_applicable := FND_API.G_FALSE;
  RETURN l_applicable;
END is_draft_applicable;



-----------------------------------------------------------------------
--Start of Comments
--Name: lock_document_with_validate
--Function:
--  Same as lock_document, except that it performs update_permission_check
--  procedure before going to lock_document procedure.
--Parameters:
--IN:
--p_calling_module
--  indicates where the procedure is called from
--p_po_header_id
--  document header id
--p_role
--  role of the user
--p_role_user_id
--  role id of the user
--OUT:
--x_locking_allowed
--  indicate whether locking was permitted
--x_message
--  error message when locking has not been permitted
--End of Comments
------------------------------------------------------------------------

PROCEDURE lock_document_with_validate
( p_calling_module IN VARCHAR2,
  p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  p_role_user_id IN NUMBER,
  x_locking_allowed OUT NOCOPY VARCHAR2,
  x_message OUT NOCOPY VARCHAR2,
  x_message_text OUT NOCOPY VARCHAR2
) IS
d_api_name CONSTANT VARCHAR2(30) := 'lock_document_with_validate';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_message VARCHAR2(2000);
l_locking_applicable VARCHAR2(1);
l_unlock_required VARCHAR2(1);

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  update_permission_check
  ( p_calling_module => p_calling_module,
    p_po_header_id => p_po_header_id,
    p_role => p_role,
    x_update_allowed => x_locking_allowed,
    x_locking_applicable => l_locking_applicable,
    x_unlock_required => l_unlock_required,
    x_message => x_message,
    x_message_text => x_message_text
  );


  -- if locking is not allowed, do not need to continue to lock the
  -- document
  IF (l_locking_applicable = FND_API.G_FALSE OR
      x_locking_allowed = FND_API.G_FALSE) THEN
    RETURN;
  END IF;

  d_position := 10;

  lock_document
  ( p_po_header_id => p_po_header_id,
    p_role => p_role,
    p_role_user_id => p_role_user_id,
    p_unlock_current => l_unlock_required
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
END lock_document_with_validate;

-----------------------------------------------------------------------
--Start of Comments
--Name: update_draft_status
--Function:
--  updates status of the draft
--Parameters:
--IN:
--p_draft_id
-- draft id of the pending changes
--End of Comments
------------------------------------------------------------------------

PROCEDURE update_draft_status
( p_draft_id IN NUMBER,
  p_new_status IN VARCHAR2
) IS
d_api_name CONSTANT VARCHAR2(30) := 'update_draft_status';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_cur_conc_request_id NUMBER := FND_GLOBAL.conc_request_id;
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- for request id, populate only if the draft is being processed by PDOI
  UPDATE po_drafts
  SET status = p_new_status,
      request_id = DECODE (p_new_status,
                           g_status_PDOI_PROCESSING, l_cur_conc_request_id,
                           NULL)
  WHERE draft_id = p_draft_id;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

END update_draft_status;

-----------------------------------------------------------------------
--Start of Comments
--Name: pending_changes_exist
--Function:
--  check whether a non-completed draft exists in the system
--Parameters:
--IN:
--p_po_header_id
-- document id of the record
--End of Comments
------------------------------------------------------------------------

FUNCTION pending_changes_exist
( p_po_header_id IN NUMBER
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'pending_changes_exist';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_draft_id PO_DRAFTS.draft_id%TYPE;
l_draft_status PO_DRAFTS.status%TYPE;
l_draft_owner_role PO_DRAFTS.owner_role%TYPE;

l_pending_changes_exist VARCHAR2(1) := FND_API.G_FALSE;
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  find_draft
  ( p_po_header_id => p_po_header_id,
    x_draft_id => l_draft_id,
    x_draft_status => l_draft_status,
    x_draft_owner_role => l_draft_owner_role
  );

  IF (l_draft_id IS NOT NULL) THEN
    l_pending_changes_exist := FND_API.G_TRUE;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'l_pending_changes_exist', l_pending_changes_exist);
  END IF;

  RETURN l_pending_changes_exist;

END pending_changes_exist;

-----------------------------------------------------------------------
--Start of Comments
--Name: changes_exist_for_draft
--Function:
--  Given the draft id table, check whether there exist any draft changes
--  at any entity for each draft id. FND_API.G_TRUE will be populated to
--  the corresponding entry in the returned table
--Parameters:
--IN:
--p_draft_id_tbl
--  draft id table
--RETURN
--  list of VARCHAR2(1) indicating whether the draft id has draft changes
--  at any entity level for the corrsponding entry in p_draft_id_tbl
--End of Comments
------------------------------------------------------------------------
FUNCTION changes_exist_for_draft
( p_draft_id_tbl PO_TBL_NUMBER
) RETURN PO_TBL_VARCHAR1 IS

d_api_name CONSTANT VARCHAR2(30) := 'changes_exist_for_draft';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_null_id_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();

l_master_chg_exist_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
l_chg_exist_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();
BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  l_null_id_tbl.EXTEND(p_draft_id_tbl.COUNT);
  l_master_chg_exist_tbl.EXTEND(p_draft_id_tbl.COUNT);
  l_chg_exist_tbl.EXTEND(p_draft_id_tbl.COUNT);

  d_position := 10;

  -- check if header gets changed
  l_master_chg_exist_tbl :=
    PO_HEADERS_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_po_header_id_tbl => l_null_id_tbl
    );

  d_position := 20;
  -- check if any line gets changed
  l_chg_exist_tbl :=
    PO_LINES_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_po_line_id_tbl => l_null_id_tbl
    );

  FOR i IN 1..l_master_chg_exist_tbl.COUNT LOOP
    IF (l_chg_exist_tbl(i) = FND_API.G_TRUE) THEN
      l_master_chg_exist_tbl(i) := FND_API.G_TRUE;
    END IF;
  END LOOP;

  d_position := 30;
  -- check if any line location gets changed
  l_chg_exist_tbl :=
    PO_LINE_LOCATIONS_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_line_location_id_tbl => l_null_id_tbl
    );

  FOR i IN 1..l_master_chg_exist_tbl.COUNT LOOP
    IF (l_chg_exist_tbl(i) = FND_API.G_TRUE) THEN
      l_master_chg_exist_tbl(i) := FND_API.G_TRUE;
    END IF;
  END LOOP;

  d_position := 40;
  -- check if any distribution gets changed
  l_chg_exist_tbl :=
    PO_DISTRIBUTIONS_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_po_distribution_id_tbl => l_null_id_tbl
    );

  FOR i IN 1..l_master_chg_exist_tbl.COUNT LOOP
    IF (l_chg_exist_tbl(i) = FND_API.G_TRUE) THEN
      l_master_chg_exist_tbl(i) := FND_API.G_TRUE;
    END IF;
  END LOOP;

  d_position := 50;
  -- check if any org assignment gets changed
  l_chg_exist_tbl :=
    PO_GA_ORG_ASSIGN_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_org_assignment_id_tbl => l_null_id_tbl
    );

  FOR i IN 1..l_master_chg_exist_tbl.COUNT LOOP
    IF (l_chg_exist_tbl(i) = FND_API.G_TRUE) THEN
      l_master_chg_exist_tbl(i) := FND_API.G_TRUE;
    END IF;
  END LOOP;

  d_position := 60;
  -- check if price differentials gets changed
  l_chg_exist_tbl :=
    PO_PRICE_DIFF_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_price_differential_id_tbl => l_null_id_tbl
    );

  FOR i IN 1..l_master_chg_exist_tbl.COUNT LOOP
    IF (l_chg_exist_tbl(i) = FND_API.G_TRUE) THEN
      l_master_chg_exist_tbl(i) := FND_API.G_TRUE;
    END IF;
  END LOOP;

  d_position := 70;
  -- check if any notification control gets changed
  l_chg_exist_tbl :=
    PO_NOTIFICATION_CTRL_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_notification_id_tbl => l_null_id_tbl
    );

  FOR i IN 1..l_master_chg_exist_tbl.COUNT LOOP
    IF (l_chg_exist_tbl(i) = FND_API.G_TRUE) THEN
      l_master_chg_exist_tbl(i) := FND_API.G_TRUE;
    END IF;
  END LOOP;

  d_position := 80;
  -- check if any attribute values record gets changed
  l_chg_exist_tbl :=
    PO_ATTR_VALUES_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_attribute_values_id_tbl => l_null_id_tbl
    );

  FOR i IN 1..l_master_chg_exist_tbl.COUNT LOOP
    IF (l_chg_exist_tbl(i) = FND_API.G_TRUE) THEN
      l_master_chg_exist_tbl(i) := FND_API.G_TRUE;
    END IF;
  END LOOP;

  d_position := 90;
  -- check if any attribute values record gets changed
  l_chg_exist_tbl :=
    PO_ATTR_VALUES_TLP_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_attribute_values_tlp_id_tbl => l_null_id_tbl
    );

  FOR i IN 1..l_master_chg_exist_tbl.COUNT LOOP
    IF (l_chg_exist_tbl(i) = FND_API.G_TRUE) THEN
      l_master_chg_exist_tbl(i) := FND_API.G_TRUE;
    END IF;
  END LOOP;

  --<Enhanced Pricing Start>
  d_position := 100;
  -- check if any price adjustments record gets changed
  l_chg_exist_tbl :=
    PO_PRICE_ADJ_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl => p_draft_id_tbl,
      p_price_adjustment_id_tbl => l_null_id_tbl
    );

  FOR i IN 1..l_master_chg_exist_tbl.COUNT LOOP
    IF (l_chg_exist_tbl(i) = FND_API.G_TRUE) THEN
      l_master_chg_exist_tbl(i) := FND_API.G_TRUE;
    END IF;
  END LOOP;
  --<Enhanced Pricing End>

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

  RETURN l_master_chg_exist_tbl;

END changes_exist_for_draft;




-----------------------------------------------------------------------
--Start of Comments
--Name: is_pending_buyer_acceptance
--Function:
--  checks whether the draft changes have been submitted for buyer acceptance
--Parameters:
--IN:
--p_po_header_id
--  document header id.
--End of Comments
------------------------------------------------------------------------

FUNCTION is_pending_buyer_acceptance
( p_po_header_id IN NUMBER
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'is_pending_buyer_acceptance';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_draft_id PO_DRAFTS.draft_id%TYPE;
l_draft_status PO_DRAFTS.status%TYPE;
l_draft_owner_role PO_DRAFTS.owner_role%TYPE;

l_pending_acceptance VARCHAR2(1) := FND_API.G_FALSE;
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  find_draft
  ( p_po_header_id => p_po_header_id,
    x_draft_id => l_draft_id,
    x_draft_status => l_draft_status,
    x_draft_owner_role => l_draft_owner_role
  );

  IF (l_draft_status = g_status_IN_PROCESS) THEN
    l_pending_acceptance := FND_API.G_TRUE;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'l_pending_acceptance', l_pending_acceptance);
  END IF;

  RETURN l_pending_acceptance;

END is_pending_buyer_acceptance;


-----------------------------------------------------------------------
--Start of Comments
--Name: lock_merge_view_records
--Function:
--  given the table id and draft id, obtain DB lock for the draft and
--  transaciton table
--Parameters:
--IN:
--p_view_name
--  View name of the merge view
--p_entity_id
--  primary key of the transaction table.
--p_draft_id
--  draft unique identifier
--RETURN:
--  a flag indicating whether there are problems during locking
--End of Comments
------------------------------------------------------------------------

FUNCTION lock_merge_view_records
( p_view_name   IN VARCHAR2,
  p_entity_id     IN NUMBER,
  p_draft_id      IN NUMBER
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'lock_merge_view_records';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

-- Assign exception with a name
INVALID_VIEW_NAME_EXC EXCEPTION;
RESOURCE_BUSY_EXC      EXCEPTION;
PRAGMA EXCEPTION_INIT (RESOURCE_BUSY_EXC, -54);

l_success VARCHAR2(1) := FND_API.G_TRUE;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_view_name = 'PO_HEADERS_MERGE_V') THEN
    d_position := 10;

    PO_HEADERS_DRAFT_PKG.lock_draft_record
    ( p_po_header_id => p_entity_id,
      p_draft_id     => p_draft_id
    );

    PO_HEADERS_DRAFT_PKG.lock_transaction_record
    ( p_po_header_id => p_entity_id
    );

  ELSIF (p_view_name = 'PO_LINES_MERGE_V') THEN
    d_position := 20;

    PO_LINES_DRAFT_PKG.lock_draft_record
    ( p_po_line_id => p_entity_id,
      p_draft_id   => p_draft_id
    );

    PO_LINES_DRAFT_PKG.lock_transaction_record
    ( p_po_line_id => p_entity_id
    );

  ELSIF (p_view_name = 'PO_LINE_LOCATIONS_MERGE_V') THEN
    d_position := 30;

    PO_LINE_LOCATIONS_DRAFT_PKG.lock_draft_record
    ( p_line_location_id => p_entity_id,
      p_draft_id            => p_draft_id
    );

    PO_LINE_LOCATIONS_DRAFT_PKG.lock_transaction_record
    ( p_line_location_id => p_entity_id
    );

  ELSIF (p_view_name = 'PO_DISTRIBUTIONS_MERGE_V') THEN
    d_position := 40;

    PO_DISTRIBUTIONS_DRAFT_PKG.lock_draft_record
    ( p_po_distribution_id => p_entity_id,
      p_draft_id           => p_draft_id
    );

    PO_DISTRIBUTIONS_DRAFT_PKG.lock_transaction_record
    ( p_po_distribution_id => p_entity_id
    );

  ELSIF (p_view_name = 'PO_GA_ORG_ASSIGN_MERGE_V') THEN
    d_position := 50;

    PO_GA_ORG_ASSIGN_DRAFT_PKG.lock_draft_record
    ( p_org_assignment_id => p_entity_id,
      p_draft_id          => p_draft_id
    );

    PO_GA_ORG_ASSIGN_DRAFT_PKG.lock_transaction_record
    ( p_org_assignment_id => p_entity_id
    );

  ELSIF (p_view_name = 'PO_PRICE_DIFF_MERGE_V') THEN
    d_position := 60;

    PO_PRICE_DIFF_DRAFT_PKG.lock_draft_record
    ( p_price_differential_id => p_entity_id,
      p_draft_id              => p_draft_id
    );

    PO_PRICE_DIFF_DRAFT_PKG.lock_transaction_record
    ( p_price_differential_id => p_entity_id
    );

  ELSIF (p_view_name = 'PO_NOTIFICATION_CTRL_MERGE_V') THEN
    d_position := 70;

    PO_NOTIFICATION_CTRL_DRAFT_PKG.lock_draft_record
    ( p_notification_id => p_entity_id,
      p_draft_id        => p_draft_id
    );

    PO_NOTIFICATION_CTRL_DRAFT_PKG.lock_transaction_record
    ( p_notification_id => p_entity_id
    );

  ELSIF (p_view_name = 'PO_ATTR_VALUES_MERGE_V') THEN
    d_position := 80;

    PO_ATTR_VALUES_DRAFT_PKG.lock_draft_record
    ( p_attribute_values_id => p_entity_id,
      p_draft_id            => p_draft_id
    );

    PO_ATTR_VALUES_DRAFT_PKG.lock_transaction_record
    ( p_attribute_values_id => p_entity_id
    );

  ELSIF (p_view_name = 'PO_ATTR_VALUES_TLP_MERGE_V') THEN
    d_position := 90;

    PO_ATTR_VALUES_TLP_DRAFT_PKG.lock_draft_record
    ( p_attribute_values_tlp_id => p_entity_id,
      p_draft_id                => p_draft_id
    );

    PO_ATTR_VALUES_TLP_DRAFT_PKG.lock_transaction_record
    ( p_attribute_values_tlp_id => p_entity_id
    );

  --<Enhanced Pricing Start>
  ELSIF (p_view_name = 'PO_PRICE_ADJUSTMENTS_MERGE_V') THEN
    d_position := 100;

    PO_PRICE_ADJ_DRAFT_PKG.lock_draft_record
    ( p_price_adjustment_id => p_entity_id,
      p_draft_id            => p_draft_id
    );

    PO_PRICE_ADJ_DRAFT_PKG.lock_transaction_record
    ( p_price_adjustment_id => p_entity_id
    );
  --<Enhanced Pricing End>

  ELSE
    d_position := 110;

    RAISE INVALID_VIEW_NAME_EXC;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN FND_API.G_TRUE;

EXCEPTION
WHEN RESOURCE_BUSY_EXC THEN
  -- come here if database locking cannot be acquired
  l_success := FND_API.G_FALSE;
  RETURN FND_API.G_FALSE;

WHEN INVALID_VIEW_NAME_EXC THEN
  IF (PO_LOG.d_exc) THEN
    PO_LOG.exc(d_module, d_position, 'Invalid view name');
  END IF;

  l_success := FND_API.G_FALSE;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
WHEN OTHERS THEN
  l_success := FND_API.G_FALSE;

  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );

  RAISE;
END lock_merge_view_records;




-----------------------------------------------------------------------
--Start of Comments
--Name: get_supplier_auth_enabled_flag
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Returns back the supp_auth_enabled_flag value
--Parameters:
--IN:
--p_po_header_id
--  header_id of the document
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION get_supplier_auth_enabled_flag
(p_po_header_id IN NUMBER
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'get_supplier_authoring_status';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;
l_supplier_auth_enabled_flag VARCHAR2(1);

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT supplier_auth_enabled_flag
  INTO l_supplier_auth_enabled_flag
  FROM  po_headers_all
  WHERE po_header_id = p_po_header_id;

  return l_supplier_auth_enabled_flag;

EXCEPTION
   WHEN no_data_found THEN
            RETURN NULL;
   WHEN others THEN
            po_message_s.sql_error('get_supp_auth_enabled_flag',d_position, sqlcode);
            raise;

END get_supplier_auth_enabled_flag;

-----------------------------------------------------------------------
--Start of Comments
--Name: set_supplier_auth_enabled_flag
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Sets the supp_auth_enabled_flag value
--Parameters:
--IN:
--p_po_header_id
--  header_id of the document
--p_supplier_auth_enabled_flag
--  the value to set
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION set_supplier_auth_enabled_flag
(p_po_header_id IN NUMBER,
 p_supplier_auth_enabled_flag IN VARCHAR2
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'set_supplier_authoring_status';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  UPDATE po_headers_all
  SET supplier_auth_enabled_flag
             = p_supplier_auth_enabled_flag
  WHERE po_header_id = p_po_header_id;

  return FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN no_data_found THEN
            RETURN FND_API.G_RET_STS_ERROR;
   WHEN others THEN
            po_message_s.sql_error('get_supp_auth_enabled_flag',d_position, sqlcode);
            raise;

END set_supplier_auth_enabled_flag;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_cat_admin_auth_enable_flag
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Returns back the cat_admin_auth_enabled_flag value
--Parameters:
--IN:
--p_po_header_id
--  header_id of the document
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION get_cat_admin_auth_enable_flag
(p_po_header_id IN NUMBER
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'get_cat_admin_authoring_status';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;
l_cat_admin_auth_enable_flag VARCHAR2(1);

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT cat_admin_auth_enabled_flag
  INTO l_cat_admin_auth_enable_flag
  FROM  po_headers_all
  WHERE po_header_id = p_po_header_id;

  return l_cat_admin_auth_enable_flag;

EXCEPTION
   WHEN no_data_found THEN
            RETURN NULL;
   WHEN others THEN
            po_message_s.sql_error('get_cat_admin_auth_enable_flag',d_position, sqlcode);
            raise;

END get_cat_admin_auth_enable_flag;

-----------------------------------------------------------------------
--Start of Comments
--Name: set_cat_admin_auth_enable_flag
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Sets the cat_admin_auth_enable_flag value
--Parameters:
--IN:
--p_po_header_id
--  header_id of the document
--p_cat_admin_auth_enable_flag
--  the value to set
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION set_cat_admin_auth_enable_flag
(p_po_header_id IN NUMBER,
 p_cat_admin_auth_enable_flag IN VARCHAR2
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'set_cat_admin_authoring_status';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  UPDATE po_headers_all
  SET cat_admin_auth_enabled_flag
             = p_cat_admin_auth_enable_flag
  WHERE po_header_id = p_po_header_id;

  return FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN no_data_found THEN
            RETURN FND_API.G_RET_STS_ERROR;
   WHEN others THEN
            po_message_s.sql_error('get_cat_admin_auth_enable_flag',d_position, sqlcode);
            raise;

END set_cat_admin_auth_enable_flag;

-- bug 5014131 START
-----------------------------------------------------------------------
--Start of Comments
--Name: get_upload_status_info
--Function:
--  Get the catalog upload status based on user role
--Parameters:
--IN:
--p_po_header_id
--  header_id of the document
--p_role
--
--IN OUT:
--OUT:
--  upload_status_code
--  upload_requestor_role_id id of the role
--  upload_job_number latest upload job id
--  upload_is_error Whether Upload errored out
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_upload_status_info
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2,
  x_upload_status_code OUT NOCOPY VARCHAR2,
  x_upload_requestor_role_id OUT NOCOPY NUMBER,
  x_upload_job_number OUT NOCOPY NUMBER,
  x_upload_status_display OUT NOCOPY VARCHAR2,
  x_upload_is_error OUT NOCOPY NUMBER -- Bug#5518826
) IS

BEGIN

  --Bug#5518826
  --Added is_error column in the select clause
  SELECT job_status,
         -- role_user_id,
         job_number,
         job_status_display,
         is_error
  INTO   x_upload_status_code,
         --x_upload_requestor_role_id,
         x_upload_job_number,
         x_upload_status_display,
         x_upload_is_error
  FROM icx_cat_latest_batch_jobs_v
  WHERE po_header_Id = p_po_header_id
  AND   role = p_role
  AND   ROWNUM = 1; --bug18238444

EXCEPTION
WHEN NO_DATA_FOUND THEN
  x_upload_status_code := 'NOT_REQUESTED';
  x_upload_requestor_role_id := NULL;
  x_upload_job_number := NULL;
  x_upload_status_display := NULL;
  x_upload_is_error := NULL;
END get_upload_status_info;

-----------------------------------------------------------------------
--Start of Comments
--Name: get_in_process_upload_info
--Function:
--  Return the information for the upload that in progress regardless
--  of the role
--Parameters:
--IN:
--p_po_header_id
--  header_id of the document
--p_role
--  role of the user
--IN OUT:
--OUT:
--  upload_in_progress: FND_API.G_TRUE if there's one upload that's not yet
--                      complete
--  upload_status_code
--  upload_requestor_role
--  upload_requestor_role_id id of the role
--  upload_job_id latest upload job id
--  upload_status_display
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE get_in_process_upload_info
( p_po_header_id IN NUMBER,
  x_upload_in_progress OUT NOCOPY VARCHAR2,
  x_upload_status_code OUT NOCOPY VARCHAR2,
  x_upload_requestor_role OUT NOCOPY VARCHAR2,
  x_upload_requestor_role_id OUT NOCOPY NUMBER,
  x_upload_job_number OUT NOCOPY NUMBER,
  x_upload_status_display OUT NOCOPY VARCHAR2
) IS

BEGIN
  x_upload_in_progress := FND_API.G_FALSE;

  -- return the upload status for any upload that's considered 'IN PROGRESS'
  -- Bug 13037956, Role was not being fetched, so fetched it and used it later
  SELECT job_status,
         -- role_user_id,
         ROLE,
         job_number,
         job_status_display
  INTO   x_upload_status_code,
         --x_upload_requestor_role_id,
         x_upload_requestor_role,
         x_upload_job_number,
         x_upload_status_display
  FROM icx_cat_latest_batch_jobs_v
  WHERE po_header_id = p_po_header_id
  AND   job_status IN (g_upload_status_PENDING,
                       g_upload_status_RUNNING,
                       g_upload_status_ERROR)
  AND   ROWNUM = 1;

  x_upload_in_progress := FND_API.G_TRUE;


EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END get_in_process_upload_info;

-- bug 5014131 END

-- bug5090429 START
-- Overloaded procedure for another one. All the parameters required by
-- the other one can be derived from p_po_header_id
PROCEDURE unlock_document_and_send_notif
( p_commit       IN VARCHAR2 := FND_API.G_FALSE,
  p_po_header_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'unlock_document_and_send_notif';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_org_id PO_HEADERS_ALL.org_id%TYPE;
l_segment1 PO_HEADERS_ALL.segment1%TYPE;
l_revision_num PO_HEADERS_ALL.revision_num%TYPE;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module,'p_commit',p_commit);
    PO_LOG.proc_begin(d_module,'p_po_header_id',p_po_header_id);
  END IF;

  SELECT org_id,
         segment1,
         revision_num
  INTO   l_org_id,
         l_segment1,
         l_revision_num
  FROM   po_headers_all
  WHERE  po_header_id = p_po_header_id;

  unlock_document_and_send_notif
  ( p_commit       => p_commit,
    p_po_header_id => p_po_header_id,
    p_org_id       => l_org_id,
    p_segment1     => l_segment1,
    p_revision_num => l_revision_num
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module,'p_commit',p_commit);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );

  RAISE;
END unlock_document_and_send_notif;



-- bug5090429 END


--<Bug#4382472 Start>
-----------------------------------------------------------------------
--Start of Comments
--Name: unlock_document_and_send_notif
--Pre-reqs:
--  None
--Modifies:None
--Locks:
--  None
--Parameters:
--IN:
--p_commit
--  Flag to indicate whether the procedure will commit or not.
--p_po_header_id
--  header_id of the document
--p_org_id
--  Unique Identifier for Org to which document belongs
--p_segment1
--  Document Number
--p_revision_num
--  Revision Number of the document
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
procedure unlock_document_and_send_notif(p_commit        IN VARCHAR2,
                                         p_po_header_id  IN NUMBER,
                                         p_org_id        IN NUMBER,
                                         p_segment1      IN VARCHAR2,
                                         p_revision_num  IN NUMBER)
IS
  d_api_name CONSTANT VARCHAR2(30) := 'unlock_document_and_send_notif';
  d_module CONSTANT VARCHAR2(2000) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
  d_pos NUMBER := 0;

  l_agreement_info FND_NEW_MESSAGES.message_text%type := NULL;
  l_doc_style_name PO_DOC_STYLE_LINES_TL.display_name%type := NULL;
  l_ou_name HR_OPERATING_UNITS.name%type := NULL;

  l_lock_owner_role PO_HEADERS_ALL.lock_owner_role%TYPE;
  l_lock_owner_user_id PO_HEADERS_ALL.lock_owner_user_id%TYPE;

  l_agent_id PO_HEADERS_ALL.agent_id%TYPE;
BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module,'p_commit',p_commit);
    PO_LOG.proc_begin(d_module,'p_po_header_id',p_po_header_id);
    PO_LOG.proc_begin(d_module,'p_org_id',p_org_id);
    PO_LOG.proc_begin(d_module,'p_segment1',p_segment1);
    PO_LOG.proc_begin(d_module,'p_revision_num',p_revision_num);
  END IF;

  -- bug5090429
  -- Get who is locking the document

  get_lock_owner_info
  ( p_po_header_id => p_po_header_id,
    x_lock_owner_role => l_lock_owner_role,
    x_lock_owner_user_id => l_lock_owner_user_id
  );


  --Unlock the document
  unlock_document(p_po_header_id => p_po_header_id);

 -- Bug 13037956 starts :
 -- Buyer can break the lock if the Upload was by Cat. Admin/Suppplier and
 -- if the Upload was successful or had errors
 -- So clearing the errors from ICX table and PO interface tables.

  --Clear Errors from ICX Jobs Table  when buyer breaks the lock
   UPDATE  icx_cat_batch_jobs
   SET  JOB_STATUS ='COMPLETED'
   WHERE po_header_id=p_po_header_id;

  -- Purging the errored record FROM PO INTERFACE and PO_INTERFACE_ERROR tables
   po_docs_interface_purge.process_po_interface_tables(
                        NULL,
                        NULL,
                              'Y',
                              'Y',
                              NULL,
                              NULL,
                        NULL,
            NULL,
            p_po_header_id);
-- Bug 13037956 ends

  d_pos := 10;
  --Get Operating Unit Name
  l_ou_name := PO_MOAC_UTILS_PVT.get_ou_name(p_org_id);
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'l_ou_name',l_ou_name);
  END IF;

  d_pos := 20;
  --Get the Agreement's Title as we get by calling getTitle of HTML page's controller
  IF nvl(p_revision_num, 0) > 0 THEN
    fnd_message.set_name('PO', 'PO_DOCUMENT_PO_TTL_INFO_REV');
    fnd_message.set_token('POREVNUM', p_revision_num);
  ELSE
    fnd_message.set_name('PO', 'PO_DOCUMENT_PO_TTL_INFO_NO_REV');
  END IF;

  d_pos := 30;
  l_doc_style_name := PO_DOC_STYLE_PVT.get_style_display_name(p_po_header_id);
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'l_doc_style_name',l_doc_style_name);
  END IF;

  d_pos := 40;
  fnd_message.set_token('PONUM', p_segment1);
  fnd_message.set_token('DOCSTYLE', l_doc_style_name);
  l_agreement_info := fnd_message.get;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module,d_pos,'l_agreement_info',l_agreement_info);
  END IF;

  d_pos := 50;
  --Send the notification

  -- bug5249393
  -- The notification from is always the buyer
  SELECT agent_id
  INTO   l_agent_id
  FROM   po_headers_all
  WHERE  po_header_id = p_po_header_id;

 -- bug5090429
  -- Changed the signature of the API
  PO_ONLINE_AUTHORING_WF_ACTIONS.start_changes_discarded_wf
  ( p_agreement_id => p_po_header_id,
    p_agreement_info => l_agreement_info,
    p_lock_owner_role => l_lock_owner_role,
    p_lock_owner_user_id => l_lock_owner_user_id,
    p_buyer_user_id => l_agent_id  -- bug5249393
  );

  d_pos := 60;
  --Commit the changes
  IF p_commit = FND_API.G_TRUE THEN
    COMMIT WORK;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_pos
    );

    PO_MESSAGE_S.sql_error('unlock_document_and_send_notif',d_pos, sqlcode);
    RAISE;
END unlock_document_and_send_notif;
--<Bug#4382472 End>

-------------------------------------------------------
-------------- PRIVATE PROCEDURES ---------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments                        < bug5532550 >
--Name: is_doc_in_updatable_state
--Function:
--  check whether the document is in a status updatable by the role
--Parameters:
--IN:
--p_po_header_id
--  document header id
--p_role
--  role of the user
--End of Comments
------------------------------------------------------------------------
FUNCTION is_doc_in_updatable_state
( p_po_header_id IN NUMBER,
  p_role IN VARCHAR2
) RETURN VARCHAR2 IS

d_api_name CONSTANT VARCHAR2(30) := 'is_doc_in_updatable_state';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_dummy NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_role IN (PO_GLOBAL.g_role_SUPPLIER,
                 PO_GLOBAL.g_role_CAT_ADMIN)) THEN

    SELECT 1
    INTO   l_dummy
    FROM   po_headers_all POH
    WHERE  POH.po_header_id = p_po_header_id
    AND    NVL(cancel_flag, 'N') = 'N'
    AND    NVL(closed_code, 'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED')
    AND    NVL(frozen_flag, 'N') <> 'Y'
    AND    NVL(user_hold_flag, 'N') <> 'Y';

    RETURN FND_API.G_TRUE;
  ELSE
    RETURN FND_API.G_TRUE;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN FND_API.G_FALSE;
END is_doc_in_updatable_state;

-----------------------------------------------------------------------
--Start of Comments
--Name: apply_changes
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Merge data to transaction tables at each level
--Parameters:
--IN:
--p_draft_info
--  record structure that holds draft information
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE apply_changes
( p_draft_info IN DRAFT_INFO_REC_TYPE
) IS

d_api_name CONSTANT VARCHAR2(30) := 'apply_changes';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  PO_HEADERS_DRAFT_PVT.apply_changes
  (p_draft_info => p_draft_info
  );

  d_position := 10;
  PO_LINES_DRAFT_PVT.apply_changes
  (p_draft_info => p_draft_info
  );

  d_position := 20;
  PO_LINE_LOCATIONS_DRAFT_PVT.apply_changes
  (p_draft_info => p_draft_info
  );

  d_position := 30;
  PO_DISTRIBUTIONS_DRAFT_PVT.apply_changes
  (p_draft_info => p_draft_info
  );

  d_position := 40;
  PO_GA_ORG_ASSIGN_DRAFT_PVT.apply_changes
  (p_draft_info => p_draft_info
  );

  d_position := 50;
  PO_PRICE_DIFF_DRAFT_PVT.apply_changes
  (p_draft_info => p_draft_info
  );

  d_position := 60;
  PO_NOTIFICATION_CTRL_DRAFT_PVT.apply_changes
  (p_draft_info => p_draft_info
  );

  d_position := 70;
  PO_ATTR_VALUES_DRAFT_PVT.apply_changes
  (p_draft_info => p_draft_info
  );

  d_position := 80;
  PO_ATTR_VALUES_TLP_DRAFT_PVT.apply_changes
  (p_draft_info => p_draft_info
  );

  --<Enhanced Pricing Start>
  d_position := 90;
  PO_PRICE_ADJ_DRAFT_PVT.apply_changes
  (p_draft_info => p_draft_info
  );
  --<Enhanced Pricing End>

  d_position := 100;
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
END apply_changes;


-----------------------------------------------------------------------
--Start of Comments
--Name: set_new_revision
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Update document revision, if necessary
--Parameters:
--IN:
--p_draft_info
--  record structure that holds draft information
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE set_new_revision
( p_draft_info DRAFT_INFO_REC_TYPE
) IS

TYPE rev_check_level_tbl_type IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;

d_api_name CONSTANT VARCHAR2(30) := 'set_new_revision';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_orig_revision_num PO_HEADERS_ALL.revision_num%TYPE;
l_rev_check_level_tbl rev_check_level_tbl_type;
l_index NUMBER := 0;
l_new_revision_num PO_HEADERS_ALL.revision_num%TYPE;
l_return_status VARCHAR2(1);
l_message VARCHAR2(2000);

/* PO AME Approval workflow change */
-- Start : PO AME Approval workflow
  l_ame_approval_id  NUMBER;
  l_ame_transaction_type PO_DOC_STYLE_HEADERS.ame_transaction_type%TYPE;
  l_new_ame_appr_id_req varchar2(1);
-- END  : PO AME Approval workflow

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_draft_info.new_document = FND_API.G_TRUE) THEN
    RETURN;
  END IF;

  SELECT PH.revision_num
  INTO   l_orig_revision_num
  FROM   po_headers_all PH
  WHERE  PH.po_header_id = p_draft_info.po_header_id;

  d_position := 10;
  -- determine which level(s) do we need to check for revision change
  IF (p_draft_info.headers_changed = FND_API.G_TRUE
      OR p_draft_info.ga_org_assign_changed = FND_API.G_TRUE) THEN

    l_index := l_index +1;
    l_rev_check_level_tbl(l_index) := 'HEADER';
  END IF;

  d_position := 20;
  IF (p_draft_info.lines_changed = FND_API.G_TRUE) THEN
    l_index := l_index +1;
    l_rev_check_level_tbl(l_index) := 'LINES';
  END IF;

  d_position := 30;
  IF (p_draft_info.line_locations_changed = FND_API.G_TRUE) THEN
    l_index := l_index +1;
    l_rev_check_level_tbl(l_index) := 'SHIPMENTS';
  END IF;

  d_position := 40;
  IF (p_draft_info.distributions_changed = FND_API.G_TRUE) THEN
    l_index := l_index +1;
    l_rev_check_level_tbl(l_index) := 'DISTRIBUTIONS';
  END IF;

  d_position := 50;
  IF (p_draft_info.price_diff_changed = FND_API.G_TRUE) THEN
    l_index := l_index +1;
    l_rev_check_level_tbl(l_index) := 'PO_LINE_PRICE_DIFF';

    IF (p_draft_info.doc_subtype = 'BLANKET') THEN
      l_index := l_index +1;
      l_rev_check_level_tbl(l_index) := 'PO_PB_PRICE_DIFF';
    END IF;
  END IF;

  d_position := 60;
  l_new_revision_num := l_orig_revision_num;

  FOR i IN 1..l_index LOOP
    d_position := 70;

    PO_DOCUMENT_REVISION_GRP.check_new_revision
    ( p_api_version => 1.0,
      p_doc_type => p_draft_info.doc_type,
      p_doc_subtype => p_draft_info.doc_subtype,
      p_doc_id => p_draft_info.po_header_id,
      p_table_name => l_rev_check_level_tbl(i),
      x_return_status => l_return_status,
      x_doc_revision_num => l_new_revision_num,
      x_message => l_message
    );

    d_position := 80;
    IF (l_return_status <> 'S') THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_orig_revision_num <> l_new_revision_num) THEN
      d_position := 90;

    /*  UPDATE po_headers_all
      SET revision_num = l_new_revision_num,
          revised_date = SYSDATE
      WHERE po_header_id = p_draft_info.po_header_id;*/

	 /* PO AME Approval workflow change : Updating po_headers_all with ame_transaction_type and ame_approval_id
	     in case AME transaction type is populated in Style Headers page*/
	   -- Start : PO AME Approval workflow

			BEGIN
			SELECT 'Y',
				   podsh.ame_transaction_type
			INTO   l_new_ame_appr_id_req,
				   l_ame_transaction_type
			FROM   po_headers_all poh,
				   po_doc_style_headers podsh
			WHERE  poh.style_id = podsh.style_id
            AND podsh.ame_transaction_type IS NOT NULL
            AND poh.po_header_id = p_draft_info.po_header_id;

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
				l_new_ame_appr_id_req := 'N';
			END;

			UPDATE po_headers_all
			SET revision_num = l_new_revision_num,
			revised_date = SYSDATE,
			ame_approval_id = DECODE(l_new_ame_appr_id_req,
                                   'Y', po_ame_approvals_s.NEXTVAL,
										ame_approval_id),
			ame_transaction_type = DECODE(l_new_ame_appr_id_req,
                                        'Y', l_ame_transaction_type,
                                        ame_transaction_type)
			WHERE po_header_id = p_draft_info.po_header_id;


	  -- End :  PO AME Approval workflow

      -- revision has been incremented. No need to check another level
      EXIT;
    END IF;
  END LOOP;

  d_position := 100;
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
END set_new_revision;


-----------------------------------------------------------------------
--Start of Comments
--Name: complete_transfer
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Mark transfer process as completed. If draft changes should be
--  removed, then all draft changes will get deleted
--Parameters:
--IN:
--p_draft_info
--  record structure that holds draft information
--p_delete_draft
--  flag to indicate whether draft changes should get removed from draft
--  tables. Possible values are FND_API.G_TRUE, FND_API.G_FALSE, 'X'
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE complete_transfer
( p_draft_info IN DRAFT_INFO_REC_TYPE,
  p_delete_draft IN VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'complete_transfer';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_return_status VARCHAR2(1);
l_exclude_ctrl_tbl VARCHAR2(1);

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- delete_draft = 'X' means that the PO_DRAFTS table should be
  -- excluded from deletion. We should just mark it as 'COMPLETED'

  IF (p_delete_draft = FND_API.G_FALSE OR
      p_delete_draft = 'X') THEN

    d_position := 10;

    update_draft_status
    ( p_draft_id   => p_draft_info.draft_id,
      p_new_status => g_status_COMPLETED
    );

  END IF;

  IF (p_delete_draft = FND_API.G_TRUE OR
      p_delete_draft = 'X') THEN

    IF (p_delete_draft = FND_API.G_TRUE) THEN
      l_exclude_ctrl_tbl := FND_API.G_FALSE;
    ELSIF (p_delete_draft = 'X') THEN
      l_exclude_ctrl_tbl := FND_API.G_TRUE;
    END IF;

    d_position := 20;
    remove_draft_changes
    ( p_draft_id => p_draft_info.draft_id,
      p_exclude_ctrl_tbl => l_exclude_ctrl_tbl,
      x_return_status => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  d_position := 30;
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
END complete_transfer;


-----------------------------------------------------------------------
--Start of Comments
--Name: update_acceptance_status
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  This procedure performs mass update of the draft records if action is
--  either ACCEPT_ALL or REJECT_ALL
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_acceptance_action
--  either g_ACCEPT_ALL (Accept all changes) or g_REJECT_ALL
--  (Reject all changes)
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_acceptance_status
( p_draft_id IN NUMBER,
  p_acceptance_action IN VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'update_acceptance_status';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_change_accepted_flag PO_HEADERS_DRAFT_ALL.change_accepted_flag%TYPE := NULL;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_acceptance_action = g_ACCEPT_ALL) THEN
    l_change_accepted_flag := 'Y';
  ELSIF (p_acceptance_action = g_REJECT_ALL) THEN
    l_change_accepted_flag := 'N';
  END IF;

  d_position := 20;

  IF (l_change_accepted_flag IS NOT NULL) THEN
    d_position := 30;
    UPDATE po_headers_draft_all
    SET change_accepted_flag = l_change_accepted_flag
    WHERE draft_id = p_draft_id
    AND change_accepted_flag IS NULL;

    d_position := 40;
    UPDATE po_lines_draft_all
    SET change_accepted_flag = l_change_accepted_flag
    WHERE draft_id = p_draft_id
    AND change_accepted_flag IS NULL;

    d_position := 50;
    UPDATE po_line_locations_draft_all
    SET change_accepted_flag = l_change_accepted_flag
    WHERE draft_id = p_draft_id
    AND change_accepted_flag IS NULL;

    d_position := 60;
    UPDATE po_distributions_draft_all
    SET change_accepted_flag = l_change_accepted_flag
    WHERE draft_id = p_draft_id
    AND change_accepted_flag IS NULL;

    d_position := 70;
    UPDATE po_ga_org_assign_draft
    SET change_accepted_flag = l_change_accepted_flag
    WHERE draft_id = p_draft_id
    AND change_accepted_flag IS NULL;

    d_position := 80;
    UPDATE po_price_diff_draft
    SET change_accepted_flag = l_change_accepted_flag
    WHERE draft_id = p_draft_id
    AND change_accepted_flag IS NULL;

    d_position := 90;
    UPDATE po_notification_ctrl_draft
    SET change_accepted_flag = l_change_accepted_flag
    WHERE draft_id = p_draft_id
    AND change_accepted_flag IS NULL;

    d_position := 100;
    UPDATE po_attribute_values_draft
    SET change_accepted_flag = l_change_accepted_flag
    WHERE draft_id = p_draft_id
    AND change_accepted_flag IS NULL;

    d_position := 110;
    UPDATE po_attribute_values_tlp_draft
    SET change_accepted_flag = l_change_accepted_flag
    WHERE draft_id = p_draft_id
    AND change_accepted_flag IS NULL;

    --<Enhanced Pricing Start>
    d_position := 120;
    UPDATE po_price_adjustments_draft
    SET change_accepted_flag = l_change_accepted_flag
    WHERE draft_id = p_draft_id
    AND change_accepted_flag IS NULL;
    --<Enhanced Pricing End>

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
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END update_acceptance_status;

END PO_DRAFTS_PVT;

/
