--------------------------------------------------------
--  DDL for Package Body PO_DIFF_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DIFF_SUMMARY_PKG" AS
  -- $Header: PO_DIFF_SUMMARY_PKG.plb 120.11.12010000.8 2014/05/12 08:33:11 shipwu ship $

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_DIFF_SUMMARY_PKG');

g_ITEMTYPE CONSTANT VARCHAR2(20) := 'PODSNOTF';
g_ITEMKEY_PREFIX CONSTANT VARCHAR2(50) := 'PO_DS_ACCEPT_NOTIF';

--==========================================================================
-- Private procedures prototype
--==========================================================================
PROCEDURE accept_translations
( p_draft_id IN NUMBER
);

PROCEDURE autoaccept_deleted_records
( p_draft_id IN NUMBER
);

FUNCTION autoaccept_unchanged_records
( p_draft_id IN NUMBER
) RETURN VARCHAR2;

FUNCTION has_record_to_accept
( p_draft_id IN NUMBER
) RETURN VARCHAR2;


PROCEDURE accept_if_no_line_changes
( p_draft_id IN NUMBER
);

PROCEDURE cascade_change_acceptance
( p_draft_id IN NUMBER,
  p_line_id_list IN PO_TBL_NUMBER,
  p_change_accepted_value IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE validate_disposition
( p_draft_id IN NUMBER,
  p_reject_line_id_list IN PO_TBL_NUMBER,
  x_invalid_line_id_list OUT NOCOPY PO_TBL_NUMBER,
  x_invalid_line_num_list OUT NOCOPY PO_TBL_NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2
);

--==========================================================================
-- Workflow related procedures
--==========================================================================

------------------------------------------------------------------------------
--Start of Comments
--Name: start_workflow
--Function:
--  Initiates Buyer Acceptance Workflow for draft changes submitted by
--  Supplier or Catalog Admin
--  If Draft does not exists, this procedure returns without initiating the
--  workflow
--Parameters:
--IN:
--p_po_header_id
--  Header id of the document
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE start_workflow
( p_po_header_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'send_acceptance_notification';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_ItemKey      VARCHAR2(240);
l_agreement_num    PO_HEADERS_ALL.segment1%TYPE;
l_revision_num    PO_HEADERS_ALL.revision_num%TYPE;
l_draft_id        PO_DRAFTS.draft_id%TYPE;
l_draft_status    PO_DRAFTS.status%TYPE;
l_draft_owner_role PO_DRAFTS.owner_role%TYPE;
l_draft_owner_user_id PO_DRAFTS.owner_user_id%TYPE;
l_org_id          PO_HEADERS_ALL.org_id%TYPE;
l_agent_id        PO_HEADERS_ALL.agent_id%TYPE;
l_buyer_user_name FND_USER.user_name%TYPE;
l_buyer_name_dsp VARCHAR2(1000);

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- Get the agreement number and revision number
  SELECT NVL(revision_num, 0), segment1, org_id, agent_id
  INTO l_revision_num, l_agreement_num, l_org_id, l_agent_id
  FROM po_headers_all
  WHERE po_header_id = p_po_header_id;

  d_position := 10;

  PO_DRAFTS_PVT.find_draft
  ( p_po_header_id => p_po_header_id,
    x_draft_id     => l_draft_id,
    x_draft_status => l_draft_status,
    x_draft_owner_role => l_draft_owner_role
  );

  IF (l_draft_id IS NULL) THEN
    -- no draft exists. Do nothing.
    RETURN;
  END IF;

  SELECT owner_user_id
  INTO   l_draft_owner_user_id
  FROM   po_drafts DFT
  WHERE  draft_id = l_draft_id;

  d_position := 20;

  -- Get buyer user name
  PO_REQAPPROVAL_INIT1.get_user_name
  ( l_agent_id,
    l_buyer_user_name,
    l_buyer_name_dsp
  );

  l_ItemKey := get_new_itemkey
               ( p_draft_id => l_draft_id
               );

  d_position := 30;

  WF_ENGINE.createProcess
  ( ItemType  => g_ITEMTYPE,
    ItemKey   => l_ItemKey,
    process   => 'PO_DS_BUYER_ACCEPTANCE_PROCESS'
  );

  -- Set all the Item Attributes

  PO_WF_UTIL_PKG.SetItemAttrNumber
  ( itemtype => g_ITEMTYPE,
    itemkey   => l_ItemKey,
    aname     => 'PO_HEADER_ID',
    avalue   => p_po_header_id
  );

  PO_WF_UTIL_PKG.SetItemAttrText
  ( itemtype => g_ITEMTYPE,
    itemkey   => l_ItemKey,
    aname     => 'AGREEMENT_NUM',
    avalue   => l_agreement_num
  );

  d_position := 40;

  PO_WF_UTIL_PKG.SetItemAttrNumber
  ( itemtype => g_ITEMTYPE,
    itemkey   => l_ItemKey,
    aname     => 'ORG_ID',
    avalue   => l_org_id
  );

  PO_WF_UTIL_PKG.SetItemAttrNumber
  ( itemtype => g_ITEMTYPE,
    itemkey  => l_ItemKey,
    aname    => 'REVISION_NUM',
    avalue   => l_revision_num
  );

  d_position := 50;

  PO_WF_UTIL_PKG.SetItemAttrNumber
  ( itemtype => g_ITEMTYPE,
    itemkey  => l_ItemKey,
    aname    => 'DRAFT_ID',
    avalue   => l_draft_id
  );

  PO_WF_UTIL_PKG.SetItemAttrText
  ( itemtype => g_ITEMTYPE,
    itemkey  => l_ItemKey,
    aname    => 'DRAFT_OWNER_ROLE',
    avalue   => l_draft_owner_role
  );

  d_position := 60;

  PO_WF_UTIL_PKG.SetItemAttrNumber
  ( itemtype => g_ITEMTYPE,
    itemkey  => l_ItemKey,
    aname    => 'DRAFT_OWNER_USER_ID',
    avalue   => l_draft_owner_user_id
  );

  PO_WF_UTIL_PKG.SetItemAttrNumber
  ( itemtype => g_ITEMTYPE,
    itemkey  => l_ItemKey,
    aname    => 'AGENT_ID',
    avalue   => l_agent_id
  );

  d_position := 70;

  PO_WF_UTIL_PKG.SetItemAttrText
  ( itemtype => g_ITEMTYPE,
    itemkey  => l_ItemKey,
    aname    => 'BUYER_USER_NAME',
    avalue   => l_buyer_user_name
  );

  PO_WF_UTIL_PKG.SetItemAttrText
  ( itemtype => g_ITEMTYPE,
    itemkey  => l_ItemKey,
    aname    => 'BUYER_NAME_DSP',
    avalue   => l_buyer_name_dsp
  );

  d_position := 80;

  -- Start the workflow process
  WF_ENGINE.startProcess
  ( ItemType  => g_ITEMTYPE,
    ItemKey   => l_ItemKey
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   WF_CORE.context (d_pkg_name,d_api_name, d_position || ': No Data Found');
   RAISE;
WHEN OTHERS THEN
   WF_CORE.context (d_pkg_name,d_api_name, d_position || ': SQL Error ' || sqlcode);
   RAISE;
END start_workflow;

PROCEDURE selector
( item_type   IN VARCHAR2,
  item_key    IN VARCHAR2,
  activity_id IN NUMBER,
  command     IN VARCHAR2,
  resultout   IN OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'selector';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_cur_org_id PO_HEADERS_ALL.org_id%TYPE;
l_org_id PO_HEADERS_ALL.org_id%TYPE;
BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'item_type', item_type);
    PO_LOG.proc_begin (d_module, 'item_key', item_key);
    PO_LOG.proc_begin (d_module, 'activity_id', activity_id);
    PO_LOG.proc_begin (d_module, 'command', command);
  END IF;

  IF (command = 'RUN') THEN
    d_position := 10;
    resultout := 'PO_DS_BUYER_ACCEPTANCE_PROCESS';

  ELSIF (command = 'SET_CTX') THEN
    d_position := 20;
    l_org_id :=
      PO_WF_UTIL_PKG.GetItemAttrNumber
      ( itemtype => item_type,
        itemkey   => item_key,
        aname     => 'ORG_ID'
      );

    PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

  ELSIF (command = 'TEST_CTX') THEN
    d_position := 30;
    l_cur_org_id := PO_MOAC_UTILS_PVT.get_current_org_id;

    l_org_id :=
      PO_WF_UTIL_PKG.GetItemAttrNumber
      ( itemtype => item_type,
        itemkey   => item_key,
        aname     => 'ORG_ID'
      );

    IF (l_cur_org_id IS NULL) THEN
      resultout := 'NOTSET';
    ELSIF (l_cur_org_id = l_org_id) THEN
      resultout := 'TRUE';
    ELSE
      resultout := 'FALSE';
    END IF;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
  RAISE;
END selector;




PROCEDURE mark_autoaccept_lines
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'mark_autoaccept_lines';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_contains_changes VARCHAR2(1);
l_acceptance_required VARCHAR2(1);
l_org_id PO_HEADERS_ALL.org_id%TYPE;
l_draft_id PO_DRAFTS.draft_id%TYPE;
l_draft_owner_role PO_DRAFTS.owner_role%TYPE;
l_acceptance_level PO_SYSTEM_PARAMETERS_ALL.cat_admin_authoring_acceptance%TYPE;
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  l_acceptance_required := FND_API.G_TRUE;

  l_org_id :=
    PO_WF_UTIL_PKG.GetItemAttrNumber
    ( itemtype => itemType,
      itemkey   => itemKey,
      aname     => 'ORG_ID'
    );

  l_draft_id :=
    PO_WF_UTIL_PKG.GetItemAttrNumber
    ( itemtype => itemType,
      itemkey   => itemKey,
      aname     => 'DRAFT_ID'
    );

  l_draft_owner_role :=
    PO_WF_UTIL_PKG.GetItemAttrText
    ( itemtype => itemType,
      itemkey   => itemKey,
      aname     => 'DRAFT_OWNER_ROLE'
    );

  -- Get acceptance level setting from po_system_paramaters
  -- For Cat Admin, default acceptance level is 'No Acceptance Required'
  -- For Supplier, default acceptance level is 'Acceptance Required'
  SELECT DECODE (l_draft_owner_role,
                 PO_GLOBAL.g_ROLE_CAT_ADMIN,
                 NVL(PSP.cat_admin_authoring_acceptance, 'NOT_REQUIRED'),
                 PO_GLOBAL.g_ROLE_SUPPLIER,
                 NVL(PSP.supplier_authoring_acceptance, 'REQUIRED'))
  INTO  l_acceptance_level
  FROM po_system_parameters_all PSP
  WHERE PSP.org_id = l_org_id;

  -- bug5249414
  -- Accept attribute values tlp records that are translations
  accept_translations
  ( p_draft_id => l_draft_id
  );


  IF (l_acceptance_level = 'NOT_REQUIRED') THEN
    l_acceptance_required := FND_API.G_FALSE;

  ELSE

    -- bug5570989
    -- accept records with delete_flag = 'Y' but without corresponding lines
    -- in the txn table
    autoaccept_deleted_records
    ( p_draft_id => l_draft_id
    );


    -- bug5249414 START

    IF (l_acceptance_level = 'REQ_PRICE_CHANGES') THEN

      l_acceptance_required :=
          accept_lines_within_tolerance
          ( p_draft_id => l_draft_id
          );
    END IF;

    -- Clean up process...
    -- IF there are still lines that require acceptance, make sure that
    -- the changes they are making are supported by Diff Summary
    IF (l_acceptance_required = FND_API.G_TRUE) THEN

      l_acceptance_required :=
        autoaccept_unchanged_records
        ( p_draft_id => l_draft_id
        );

    END IF;

    -- bug5249414 END
  END IF;

  PO_WF_UTIL_PKG.SetItemAttrText
  ( itemtype => itemType,
    itemkey  => itemKey,
    aname    => 'BUYER_ACCEPTANCE_REQUIRED',
    avalue   => l_acceptance_required
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
  RAISE;
END mark_autoaccept_lines;


PROCEDURE buyer_acceptance_required
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'buyer_acceptance_required';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_accept_required VARCHAR2(1);
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  l_accept_required := PO_WF_UTIL_PKG.GetItemAttrText
                     ( itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'BUYER_ACCEPTANCE_REQUIRED'
                     );

  IF (l_accept_required = FND_API.G_TRUE) THEN
    resultout := WF_ENGINE.eng_completed || ':Y';
  ELSE
    resultout := WF_ENGINE.eng_completed || ':N';
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
  RAISE;
END buyer_acceptance_required;

PROCEDURE transfer_if_all_autoaccepted
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'transfer_if_all_autoaccepted';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_transfer_flag VARCHAR2(1);

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  l_transfer_flag := PO_WF_UTIL_PKG.GetItemAttrText
                     ( itemtype => itemtype,
                       itemkey  => itemkey,
                       aname    => 'TRANSFER_IF_AUTOACCEPT_ALL'
                     );

  IF (l_transfer_flag = FND_API.G_TRUE) THEN
    resultout := WF_ENGINE.eng_completed || ':Y';
  ELSE
    resultout := WF_ENGINE.eng_completed || ':N';
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
  RAISE;
END transfer_if_all_autoaccepted;


PROCEDURE start_buyer_acceptance_process
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'start_buyer_acceptance_process';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_po_header_id PO_HEADERS_ALL.po_header_id%TYPE;
l_draft_id     PO_DRAFTS.draft_id%TYPE;
l_emp_id       FND_USER.employee_id%TYPE;
l_buyer_user_name FND_USER.user_name%TYPE;

l_lock_owner_role PO_DRAFTS.owner_role%TYPE;
l_lock_owner_user_id PO_DRAFTS.owner_user_id%TYPE;

l_lock_owner_wf_role WF_USERS.name%TYPE;
l_lock_owner_wf_role_dsp WF_USERS.display_name%TYPE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  l_po_header_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                    ( itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'PO_HEADER_ID'
                    );

  l_draft_id    := PO_WF_UTIL_PKG.GetItemAttrNumber
                    ( itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'DRAFT_ID'
                    );

  d_position := 10;

  PO_DRAFTS_PVT.update_draft_status
  ( p_draft_id   => l_draft_id,
    p_new_status => PO_DRAFTS_PVT.g_status_IN_PROCESS
  );

  l_buyer_user_name := PO_WF_UTIL_PKG.GetItemAttrText
                        ( itemtype => itemtype,
                          itemkey  => itemkey,
                          aname    => 'BUYER_USER_NAME'
                        );

  -- Initially, the user role of the acceptance party is the buyer of
  -- the document
  PO_WF_UTIL_PKG.SetItemAttrText
  ( itemtype => itemtype,
    itemkey  => itemkey,
    aname    => 'ACCEPTANCE_USER_WF_ROLE',
    avalue   => l_buyer_user_name
  );

  d_position := 20;

  -- bug5249393
  -- Get the document lock owner as it is the last owner that touched the
  -- document
  PO_DRAFTS_PVT.get_lock_owner_info
  ( p_po_header_id => l_po_header_id,
    x_lock_owner_role => l_lock_owner_role,
    x_lock_owner_user_id => l_lock_owner_user_id
  );

  PO_ONLINE_AUTHORING_WF_ACTIONS.get_wf_role_for_lock_owner
  ( p_po_header_id => l_po_header_id,
    p_lock_owner_role => l_lock_owner_role,
    p_lock_owner_user_id => l_lock_owner_user_id,
    x_wf_role_name => l_lock_owner_wf_role,
    x_wf_role_name_dsp => l_lock_owner_wf_role_dsp
  );

  WF_ENGINE.SetItemAttrText
  ( itemtype => itemType,
    itemkey  => itemKey,
    aname    => 'DRAFT_OWNER_WF_ROLE',
    avalue   => l_lock_owner_wf_role
  );

  WF_ENGINE.SetItemAttrText
  ( itemtype => itemType,
    itemkey  => itemKey,
    aname    => 'DRAFT_OWNER_NAME_DSP',
    avalue   => l_lock_owner_wf_role_dsp
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
  RAISE;
END start_buyer_acceptance_process;


PROCEDURE get_buyers_manager
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'get_buyers_manager';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_agent_id PO_HEADERS_ALL.agent_id%TYPE;
l_manager_id NUMBER;
l_manager_user_name FND_USER.user_name%TYPE;
l_manager_name_dsp  VARCHAR2(1000);
BEGIN
  d_position := 0;

  l_agent_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                ( itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'AGENT_ID'
                );

  d_position := 10;

  BEGIN
    SELECT supervisor_id
    INTO   l_manager_id
    FROM   hr_employees_current_v HREMP
    WHERE  employee_id = l_agent_id;

    -- Get manager's user name
    PO_REQAPPROVAL_INIT1.get_user_name
    ( l_manager_id,
      l_manager_user_name,
      l_manager_name_dsp
    );

    d_position := 20;

    -- Change user that performs acceptance
    PO_WF_UTIL_PKG.SetItemAttrText
    ( itemtype => itemtype,
      itemkey  => itemkey,
      aname    => 'ACCEPTANCE_USER_WF_ROLE',
      avalue   => l_manager_user_name
    );

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- if supervisor cannot be found, do no change the acceptance performer
    d_position := 30;
    NULL;
  END;

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
  RAISE;
END get_buyers_manager;




PROCEDURE buyer_accept_changes
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'buyer_accept_changes';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  PO_WF_UTIL_PKG.SetItemAttrText
  ( itemtype => itemType,
    itemkey   => itemKey,
    aname     => 'ACCEPTANCE_RESULT',
    avalue   => PO_DRAFTS_PVT.g_ACCEPT_ALL
  );

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
   WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
RAISE;
END buyer_accept_changes;


PROCEDURE buyer_reject_changes
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'buyer_reject_changes';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_draft_id PO_DRAFTS.draft_id%TYPE;
l_po_header_id PO_HEADERS_ALL.po_header_id%TYPE;
l_created_language PO_HEADERS_ALL.created_language%TYPE;
l_reject_list PO_TBL_NUMBER;

l_return_status VARCHAR2(1);

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  l_draft_id :=
    PO_WF_UTIL_PKG.GetItemAttrNumber
    ( itemtype => itemType,
      itemkey   => itemKey,
      aname     => 'DRAFT_ID'
    );

  l_po_header_id :=
    PO_WF_UTIL_PKG.GetItemAttrNumber
    ( itemtype => itemType,
      itemkey   => itemKey,
      aname     => 'PO_HEADER_ID'
    );

  d_position := 10;

  SELECT created_language
  INTO   l_created_language
  FROM   po_headers_all
  WHERE  po_header_id = l_po_header_id;

  d_position := 20;

  -- bug5249414
  -- When user clicks "Reject All", we only want to reject the lines that
  -- are visible to the user.
  -- Example: If the price that cat admin updates does not exceed price
  --          tolerance and the acceptance level is "Required only if
  --          price tolerance exceeded", then the line will be automatically
  --          accepted and won't show up in the report. If buyer clicks reject
  --          all, the line should still be accepted since the buyer can't see
  --          it in the report to begin with
  --          On the other hand, if buyer does reject a line, the whole pending
  --          changes for the line will be rejected, even though it contains
  --          things that are supposed to be autoaccepted, like tranlsations
  --          and flexfield changes.

  SELECT *
  BULK COLLECT
  INTO l_reject_list
  FROM
   (
    SELECT po_line_id
    FROM   po_lines_draft_all
    WHERE  draft_id = l_draft_id
    AND    change_accepted_flag IS NULL
    UNION
    SELECT po_line_id
    FROM   po_line_locations_draft_all
    WHERE  draft_id = l_draft_id
    AND    change_accepted_flag IS NULL
    UNION
    SELECT entity_id
    FROM   po_price_diff_draft
    WHERE  draft_id = l_draft_id
    AND    entity_type = 'BLANKET LINE'
    AND    change_accepted_flag IS NULL
    UNION
    SELECT NVL(LLD.po_line_id, LL.po_line_id)
    FROM   po_line_locations_draft_all LLD,
           po_line_locations_all LL,
           po_price_diff_draft PDD
    WHERE  PDD.draft_id = l_draft_id
    AND    entity_type = 'PRICE BREAK'
    AND    PDD.change_accepted_flag IS NULL
    AND    PDD.entity_id = LLD.line_location_id(+)
    AND    PDD.draft_id = LLD.draft_id(+)
    AND    PDD.entity_id = LL.line_location_id(+)
    UNION
    SELECT po_line_id
    FROM   po_attribute_values_draft
    WHERE  draft_id = l_draft_id
    AND    change_accepted_flag IS NULL
    UNION
    SELECT po_line_id
    FROM   po_attribute_values_tlp_draft
    WHERE  draft_id = l_draft_id
    AND    language = l_created_language
    AND    change_accepted_flag IS NULL
   );

  d_position := 30;

  cascade_change_acceptance
  ( p_draft_id => l_draft_id,
    p_line_id_list => l_reject_list,
    p_change_accepted_value => 'N',
    x_return_status => l_return_status
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
   WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
RAISE;
END buyer_reject_changes;


PROCEDURE any_lines_get_rejected
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'any_lines_get_rejected';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_draft_id  PO_DRAFTS.draft_id%TYPE;
l_any_lines_get_rejected VARCHAR2(10);
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  l_draft_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                ( itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'DRAFT_ID'
                );

  d_position := 10;

  BEGIN
    SELECT 'Y'
    INTO l_any_lines_get_rejected
    FROM DUAL
    WHERE EXISTS
            (SELECT 1
             FROM   po_lines_draft_all
             WHERE  draft_id = l_draft_id
             AND    change_accepted_flag = 'N')
    OR    EXISTS
            (SELECT 1
             FROM   po_line_locations_draft_all
             WHERE  draft_id = l_draft_id
             AND    change_accepted_flag = 'N')
    OR    EXISTS
            (SELECT 1
             FROM   po_price_diff_draft
             WHERE  draft_id = l_draft_id
             AND    change_accepted_flag = 'N')
    OR    EXISTS
            (SELECT 1
             FROM   po_attribute_values_draft
             WHERE  draft_id = l_draft_id
             AND    change_accepted_flag = 'N');
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_any_lines_get_rejected := 'N';
  END;

  d_position := 20;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, 'l_any_lines_get_rejected', l_any_lines_get_rejected);
  END IF;

  IF (l_any_lines_get_rejected = 'Y') THEN
    resultout := WF_ENGINE.eng_completed || ':Y';
  ELSE
    resultout := WF_ENGINE.eng_completed || ':N';
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
  RAISE;
END any_lines_get_rejected;



PROCEDURE transfer_draft_to_txn
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'transfer_draft_to_txn';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_draft_id  PO_DRAFTS.draft_id%TYPE;
l_po_header_id PO_HEADERS_ALL.po_header_id%TYPE;
l_acceptance_action VARCHAR2(20);
l_need_notif VARCHAR2(1);
l_return_status VARCHAR2(1);

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  l_draft_id    := PO_WF_UTIL_PKG.GetItemAttrNumber
                    ( itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'DRAFT_ID'
                    );

  l_po_header_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                    ( itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'PO_HEADER_ID'
                    );

  l_acceptance_action := PO_WF_UTIL_PKG.GetItemAttrText
                         ( itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'ACCEPTANCE_RESULT'
                         );

  d_position := 10;

  PO_DRAFTS_PVT.transfer_draft_to_txn
  ( p_api_version            => 1.0,
    p_init_msg_list          => FND_API.G_TRUE,
    p_draft_id               => l_draft_id,
    p_po_header_id           => l_po_header_id,
    p_delete_processed_draft => FND_API.G_FALSE,
    p_acceptance_action      => l_acceptance_action,
    x_return_status          => l_return_status
  );

  IF (l_return_status <> FND_API.g_RET_STS_SUCCESS) THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
   WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
RAISE;
END transfer_draft_to_txn;


PROCEDURE launch_po_approval_wf
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'launch_po_approval_wf';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_document_type VARCHAR2(10) := 'PA';
l_document_subtype VARCHAR2(10) := 'BLANKET';
l_po_header_id PO_HEADERS_ALL.po_header_id%TYPE;
l_org_id PO_HEADERS_ALL.org_id%TYPE;
l_preparer_id PO_HEADERS_ALL.agent_id%TYPE;

l_printflag           VARCHAR2(1) := 'N';
l_faxflag             VARCHAR2(1) := 'N';
l_faxnum              VARCHAR2(30);        --Bug 5765243
l_emailflag           VARCHAR2(1) := 'N';
l_emailaddress        PO_VENDOR_SITES.email_address%TYPE;
l_default_method      PO_VENDOR_SITES.supplier_notif_method%TYPE;
l_document_num        PO_HEADERS.segment1%TYPE;
l_note_to_approver    VARCHAR2(480);

/* Bug 10026155 Start */
l_create_sourcing_rule VARCHAR2(10);
l_update_sourcing_rule VARCHAR2(10);
/* Bug 10026155 End   */

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;


  -- Launch Approval WF
  -- Retrieve some settings for launching the PO Approval workflow.
  l_po_header_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                    ( itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'PO_HEADER_ID'
                    );

  l_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                    ( itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'ORG_ID'
                    );

  l_note_to_approver := PO_WF_UTIL_PKG.GetItemAttrText
                        ( itemtype => itemtype,
                          itemkey  => itemkey,
                          aname    => 'NOTE_TO_APPROVER'
                        );

  d_position := 10;

  PO_VENDOR_SITES_SV.get_transmission_defaults
  ( p_document_id => l_po_header_id,
    p_document_type => l_document_type,
    p_document_subtype => l_document_subtype,
    p_preparer_id => l_preparer_id, -- IN OUT parameter
    x_default_method => l_default_method,
    x_email_address => l_emailaddress,
    x_fax_number => l_faxnum,
    x_document_num => l_document_num
  );

  d_position := 20;

  IF (l_default_method = 'EMAIL') AND (l_emailaddress IS NOT NULL) THEN
    l_emailflag := 'Y';
  ELSIF (l_default_method  = 'FAX') AND (l_faxnum IS NOT NULL) then
    l_emailaddress := NULL;
    l_faxflag := 'Y';
  ELSIF (l_default_method  = 'PRINT') then
    l_emailaddress := null;
    l_faxnum := null;
    l_printflag := 'Y';
  ELSE
    l_emailaddress := null;
    l_faxnum := null;
  END IF; -- l_default_method

  d_position := 30;

  /* Bug 10026155 Start */

  SELECT AUTO_SOURCING_FLAG,UPDATE_SOURCING_RULES_FLAG
        INTO
        l_create_sourcing_rule,l_update_sourcing_rule
        FROM
        PO_HEADERS_ALL
        WHERE
        PO_HEADER_ID=l_po_header_id;

  /* Bug 10026155 End */


  -- Launch the PO Approval workflow.
  PO_REQAPPROVAL_INIT1.start_wf_process (
    ItemType => NULL,                   -- defaulted in start_wf_process
    ItemKey => NULL,                    -- defaulted in start_wf_process
    WorkflowProcess => NULL,            -- defaulted in start_wf_process
    ActionOriginatedFrom => NULL,
    DocumentID => l_po_header_id,
    DocumentNumber => NULL,
    PreparerID => l_preparer_id,
    DocumentTypeCode => l_document_type,
    DocumentSubtype => l_document_subtype,
    SubmitterAction => NULL,
    ForwardToID => NULL,
    ForwardFromID => NULL,
    DefaultApprovalPathID => NULL,
    Note => l_note_to_approver,
    PrintFlag => l_printflag,
    FaxFlag => l_faxflag,
    FaxNumber => l_faxnum,
    EmailFlag => l_emailflag,
    EmailAddress => l_emailaddress,
    CreateSourcingRule=>l_create_sourcing_rule,
    UpdateSourcingRule=>l_update_sourcing_rule
  );

  d_position := 40;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
  RAISE;
END launch_po_approval_wf;


--==========================================================================
-- Regular procedures
--==========================================================================

-----------------------------------------------------------------------
--Start of Comments
--Name: get_new_itemkey
--Function:
--  Get new itemkey
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--IN OUT:
--OUT:
--Returns:
-- New item key
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION get_new_itemkey
( p_draft_id IN NUMBER
) RETURN VARCHAR2
IS

l_new_itemkey NUMBER;

BEGIN
  SELECT PO_WF_ITEMKEY_S.NEXTVAL
  INTO l_new_itemkey
  FROM DUAL;

  RETURN g_ITEMKEY_PREFIX || '#' || TO_CHAR(p_draft_id) || '#' ||
         TO_CHAR(l_new_itemkey);

END get_new_itemkey;

-----------------------------------------------------------------------
--Start of Comments
--Name: find_itemkey
--Function:
--  Find item key of the buyer acceptance workflow for the current draft
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION find_itemkey
( p_draft_id IN NUMBER
) RETURN VARCHAR2
IS

d_api_name CONSTANT VARCHAR2(30) := 'find_itemkey';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_itemkey_like WF_ITEMS.item_key%TYPE;
l_itemkey WF_ITEMS.item_key%TYPE;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  l_itemkey_like := g_ITEMKEY_PREFIX || '#' || TO_CHAR(p_draft_id) || '#%';

  SELECT MAX(item_key)
  INTO   l_itemkey
  FROM   WF_ITEMS
  WHERE  item_type = g_ITEMTYPE
  AND    item_key LIKE l_itemkey_like
  AND    end_date IS NULL;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module, 'l_itemkey', l_itemkey);
  END IF;

  RETURN l_itemkey;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  RAISE;
END find_itemkey;

-----------------------------------------------------------------------
--Start of Comments
--Name: record_disposition
--Function:
--  Mark all lines and their children with status Rejected based on the
--  line rejection list passed in, if the rejected lines passed validation
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_reject_line_id_list
--  lines to reject
--IN OUT:
--OUT:
--x_invalid_line_id_list
--  lines that fail validation
--x_invalid_line_num_list
--  line num for the lines that fail validation
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE record_disposition
( p_draft_id IN NUMBER,
  p_reject_line_id_list IN PO_TBL_NUMBER,
  x_invalid_line_id_list OUT NOCOPY PO_TBL_NUMBER,  -- bug5187544
  x_invalid_line_num_list OUT NOCOPY PO_TBL_NUMBER,  -- bug5187544
  x_return_status OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'record_disposition';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_return_status VARCHAR2(1);
BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'p_draft_id', p_draft_id);
    PO_LOG.proc_begin (d_module, 'p_reject_line_id_list.COUNT', p_reject_line_id_list.COUNT);
  END IF;

  x_return_status := FND_API.g_RET_STS_SUCCESS;

  d_position := 10;

  -- bug5187544 START
  -- perform validation to the rejected lines
  validate_disposition
  ( p_draft_id => p_draft_id,
    p_reject_line_id_list => p_reject_line_id_list,
    x_invalid_line_id_list => x_invalid_line_id_list,
    x_invalid_line_num_list => x_invalid_line_num_list,
    x_return_status => l_return_status
  );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, 'l_return_status', l_return_status);
  END IF;

  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    x_return_status := l_return_status;
    RETURN;

  ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- bug5187544 END

  d_position := 20;

  -- bug5035979
  -- refactored the code to call cascade_change_aceptance
  cascade_change_acceptance
  ( p_draft_id => p_draft_id,
    p_line_id_list => p_reject_line_id_list,
    p_change_accepted_value => 'N',
    x_return_status => l_return_status
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END record_disposition;

-----------------------------------------------------------------------
--Start of Comments
--Name: complete_resp_to_changes
--Function:
--  Post processing after buyer has responded to the changes. It relieves
--  the block set up in buyer acceptance workflow so that draft changes can
--  be applied to the transaction table
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_action
--  Buyer's response to the draft changes
--p_initiate_approval
--  Buyer's response whether approval workflow should be launched or not.
--p_note_to_approver
--  Note to the approver in approval hierarchy
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE complete_resp_to_changes
( p_draft_id         IN NUMBER,
  p_action           IN VARCHAR2,
  p_initiate_approval  IN VARCHAR2,    --Bug 13356264
  p_note_to_approver IN VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'complete_resp_to_changes';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_itemKey WF_ITEMS.item_key%TYPE;
l_activity VARCHAR2(200);
l_activity_result VARCHAR2(30);

--Bug 18542010 Start
lerrname   varchar2(30);
lerrmsg    varchar2(2000);
lerrstack  varchar2(32000);
--Bug 18542010 End

BEGIN
  d_position := 0;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'p_draft_id', p_draft_id);
  END IF;

  l_itemKey := find_ItemKey
               ( p_draft_id => p_draft_id
               );

  d_position := 10;

  IF (l_itemKey IS NOT NULL) THEN

    -- release the activity that is blocked since the user has responded to
    -- the draft changes

    l_activity := 'BUYER_NOTIFICATIONS:WAIT_FOR_RESP_TO_CHG';

    IF (p_action = PO_DRAFTS_PVT.g_ACCEPT_ALL) THEN
      l_activity_result := 'ACCEPT';
    ELSIF (p_action = PO_DRAFTS_PVT.g_REJECT_ALL) THEN
      l_activity_result := 'REJECT';
    ELSIF (p_action = PO_DRAFTS_PVT.g_LINE_DISP) THEN
      l_activity_result := 'SUBMIT_LINE_DISP';
    END IF;

    d_position := 20;

    --Bug 13356264
    PO_WF_UTIL_PKG.SetItemAttrText
    ( itemtype => g_ITEMTYPE,
      itemkey  => l_ItemKey,
      aname    => 'LAUNCH_APPROVAL',
      avalue   =>  p_initiate_approval
    );


    PO_WF_UTIL_PKG.SetItemAttrText
    ( itemtype => g_ITEMTYPE,
      itemkey  => l_ItemKey,
      aname    => 'NOTE_TO_APPROVER',
      avalue   => SUBSTRB(p_note_to_approver, 1, 480)
    );

    --Bug 18542010 Start
    --Add exception handling to bypass any issue in this activity
    --also add debug msg
    BEGIN
      WF_ENGINE.CompleteActivity
      ( itemType => g_ITEMTYPE,
        itemKey  => l_itemKey,
        activity => l_activity,
        result   => l_activity_result
      );
    EXCEPTION
      WHEN OTHERS THEN
        WF_CORE.Get_Error(lerrname,lerrmsg,lerrstack);
        IF lerrname = 'WFENG_NOT_NOTIFIED'
        THEN
          NULL;
        END IF;

        IF (PO_LOG.d_stmt)
        THEN
          PO_LOG.stmt(d_module, d_position,
                    'Exception when completing resp to changes '
                     ||'Item key='||l_Itemkey);
        END IF;
    END;
    --Bug 18542010 End

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END complete_resp_to_changes;


-----------------------------------------------------------------------
--Start of Comments
--Name: accept_lines_within_tolerance
--Function:
--  Check the lines in draft table and see if the price change has exceed
--  tolerance. If so, return an indicator saying that manual acceptance is
--  required. For those that do not exceed price tolerance, makr them as
--  autoaccepted
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--IN OUT:
--OUT:
--Returns:
--  FND_API.G_TRUE if manual acceptance is required
--  FND_API.G_FALSE otherwise
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION accept_lines_within_tolerance
( p_draft_id IN NUMBER
) RETURN VARCHAR2
IS

d_api_name CONSTANT VARCHAR2(30) := 'accept_lines_within_tolerance';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_index NUMBER;

l_manual_accept_required VARCHAR2(1) := FND_API.G_FALSE;
l_need_to_check_tolerance VARCHAR2(1) := FND_API.G_FALSE;
l_has_autoaccepted_line VARCHAR2(1) := FND_API.G_FALSE;
l_over_tolerance VARCHAR2(1);

l_check_tolerance_index_tbl DBMS_SQL.NUMBER_TABLE;

l_autoaccept_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
l_vendor_id_tbl PO_TBL_NUMBER;
l_po_line_id_tbl PO_TBL_NUMBER;
l_po_header_id_tbl PO_TBL_NUMBER;
l_item_id_tbl PO_TBL_NUMBER;
l_category_id_tbl PO_TBL_NUMBER;
l_new_price_tbl PO_TBL_NUMBER;
l_old_price_tbl PO_TBL_NUMBER;
l_new_line_flag_tbl PO_TBL_VARCHAR1;
l_price_update_tolerance_tbl PO_TBL_NUMBER;

l_return_status VARCHAR2(1);

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'p_draft_id', p_draft_id);
  END IF;

  -- bug5035979
  -- mark the records that do not have line level changes as
  -- 'accepted'
  accept_if_no_line_changes
  ( p_draft_id => p_draft_id
  );

  SELECT PH.vendor_id,
         PLD.po_line_id,
         PLD.po_header_id,
         PLD.item_id,
         PLD.category_id,
         PLD.unit_price,
         PL.unit_price,
         NVL2(PL.po_line_id, 'N', 'Y')
  BULK COLLECT
  INTO l_vendor_id_tbl,
       l_po_line_id_tbl,
       l_po_header_id_tbl,
       l_item_id_tbl,
       l_category_id_tbl,
       l_new_price_tbl,
       l_old_price_tbl,
       l_new_line_flag_tbl
  FROM po_headers_all PH,
       po_lines_draft_all PLD,
       po_lines_all PL
  WHERE PLD.draft_id = p_draft_id
  AND   NVL(PLD.delete_flag, 'N') = 'N'
  AND   PLD.change_accepted_flag IS NULL
  AND   PLD.po_line_id = PL.po_line_id(+)
  AND   PLD.po_header_id = PH.po_header_id;

  d_position := 10;

  -- If there are any new lines, manual acceptance will be required by default
  -- Otherwise, we need to check price tolerance to see if manual acceptance
  -- is necessary
  FOR i IN 1..l_po_line_id_tbl.COUNT LOOP
    IF (l_new_line_flag_tbl(i) = 'Y') THEN
      l_manual_accept_required := FND_API.G_TRUE;
    ELSE
      -- add to the table that indicates what rows we need to check
      -- for tolerance
      l_check_tolerance_index_tbl(i) := i;
      l_need_to_check_tolerance := FND_API.G_TRUE;
    END IF;
  END LOOP;

  d_position := 20;

  IF (l_need_to_check_tolerance = FND_API.G_TRUE) THEN

    PO_PDOI_PRICE_TOLERANCE_PVT.get_price_tolerance
    ( p_index_tbl => l_check_tolerance_index_tbl,
      p_po_header_id_tbl => l_po_header_id_tbl,
      p_item_id_tbl => l_item_id_tbl,
      p_category_id_tbl => l_category_id_tbl,
      p_vendor_id_tbl => l_vendor_id_tbl,
      x_price_update_tolerance_tbl => l_price_update_tolerance_tbl
    );

    d_position := 30;

    -- now, check whether the lines have exceeded price tolerance
    l_index := l_check_tolerance_index_tbl.FIRST;

    WHILE (l_index IS NOT NULL) LOOP
      d_position := 40;

      l_over_tolerance :=
        PO_PDOI_PRICE_TOLERANCE_PVT.exceed_tolerance_check
        ( p_price_tolerance => l_price_update_tolerance_tbl(l_index),
          p_old_price       => l_old_price_tbl(l_index),
          p_new_price       => l_new_price_tbl(l_index)
        );

      IF (l_over_tolerance = FND_API.G_FALSE) THEN
        -- need to autoaccept this line
        l_autoaccept_tbl.EXTEND;
        l_autoaccept_tbl(l_autoaccept_tbl.COUNT) := l_po_line_id_tbl(l_index);

        l_has_autoaccepted_line := FND_API.G_TRUE;
      ELSE
        -- require manual acceptance, if there is a line that goes over
        -- price tolerance limit
        l_manual_accept_required := FND_API.G_TRUE;
      END IF;

      l_index := l_check_tolerance_index_tbl.NEXT(l_index);
    END LOOP;

    d_position := 50;

    -- For the lines that do not exceed price tolerance, autoaccept them.
    IF (l_has_autoaccepted_line = FND_API.G_TRUE) THEN
      -- bug5035979
      -- cascade acceptance value to lower level as well.
      cascade_change_acceptance
      ( p_draft_id => p_draft_id,
        p_line_id_list => l_autoaccept_tbl,
        p_change_accepted_value => 'Y',
        x_return_status => l_return_status
      );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

  RETURN l_manual_accept_required;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );

  RAISE;
END accept_lines_within_tolerance;

--==========================================================================
-- Private procedures
--==========================================================================

-- bug5249414 START
PROCEDURE accept_translations
( p_draft_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'accept_translations';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_created_language PO_HEADERS_ALL.created_language%TYPE;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  SELECT PH.created_language
  INTO   l_created_language
  FROM   po_drafts DFT,
         po_headers_all PH
  WHERE  DFT.draft_id = p_draft_id
  AND    PH.po_header_id = DFT.document_id;

  UPDATE po_attribute_values_tlp_draft PAVTD
  SET    change_accepted_flag = 'Y'
  WHERE  change_accepted_flag IS NULL
  AND    PAVTD.draft_id = p_draft_id
  AND    PAVTD.language <> l_created_language;


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module, '# of records updated: ', SQL%ROWCOUNT);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );

  RAISE;
END accept_translations;

-- bug5570989 START
-----------------------------------------------------------------------
--Start of Comments
--Name: autoaccept_deleted_records
--Function:
--  If the draft record is marked for deletion, but the corresponding
--  line doesn't exist in the txn table, autoaccept it because they
--  won't show up in the diff summary report anyway
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE autoaccept_deleted_records
( p_draft_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'autoaccept_deleted_records';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_has_record_to_accept VARCHAR2(1) := FND_API.G_TRUE;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- Line Level
  UPDATE po_lines_draft_all PLD
  SET    PLD.change_accepted_flag = 'Y'
  WHERE  PLD.draft_id = p_draft_id
  AND    PLD.change_accepted_flag IS NULL
  AND    PLD.delete_flag = 'Y'
  AND    NOT EXISTS
           ( SELECT 1
             FROM   po_lines_all PL
             WHERE  PLD.po_line_id = PL.po_line_id);

  d_position := 10;

  -- Price Break Level
  UPDATE po_line_locations_draft_all PLLD
  SET    PLLD.change_accepted_flag = 'Y'
  WHERE  PLLD.draft_id = p_draft_id
  AND    PLLD.change_accepted_flag IS NULL
  AND    PLLD.delete_flag = 'Y'
  AND    NOT EXISTS
           ( SELECT 1
             FROM   po_line_locations_all PLL
             WHERE  PLLD.line_location_id = PLL.line_location_id);

  d_position := 20;

  -- Price Diff Level
  UPDATE po_price_diff_draft PPDD
  SET    PPDD.change_accepted_flag = 'Y'
  WHERE  PPDD.draft_id = p_draft_id
  AND    PPDD.change_accepted_flag IS NULL
  AND    PPDD.delete_flag = 'Y'
  AND    NOT EXISTS
           ( SELECT 1
             FROM   po_price_differentials PPD
             WHERE  PPDD.price_differential_id = PPD.price_differential_id);

  d_position := 30;

  -- Attr Values Level
  UPDATE po_attribute_values_draft PAVD
  SET    PAVD.change_accepted_flag = 'Y'
  WHERE  PAVD.draft_id = p_draft_id
  AND    PAVD.change_accepted_flag IS NULL
  AND    PAVD.delete_flag = 'Y'
  AND    NOT EXISTS
           ( SELECT 1
             FROM   po_attribute_values PAV
             WHERE  PAVD.attribute_values_id = PAV.attribute_values_id);

  d_position := 40;

  -- Attr Values TLP Level
  UPDATE po_attribute_values_tlp_draft PAVTD
  SET    PAVTD.change_accepted_flag = 'Y'
  WHERE  PAVTD.draft_id = p_draft_id
  AND    PAVTD.change_accepted_flag IS NULL
  AND    PAVTD.delete_flag = 'Y'
  AND    NOT EXISTS
           ( SELECT 1
             FROM   po_attribute_values_tlp PAVT
             WHERE  PAVTD.attribute_values_tlp_id = PAVT.attribute_values_tlp_id);

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
END autoaccept_deleted_records;



-- bug5570989 END

-----------------------------------------------------------------------
--Start of Comments
--Name: autoaccept_unchanged_records
--Function:
--  For records that are not changed or have only the non-diffsummary-supported
--  attributes changed, autoaccept them
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--IN OUT:
--OUT:
--Returns:
--  FND_API.G_TRUE if there's still record in the draft to accept
--  FND_API.G_FALSE otherwise
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION autoaccept_unchanged_records
( p_draft_id IN NUMBER
) RETURN VARCHAR2
IS

d_api_name CONSTANT VARCHAR2(30) := 'autoaccept_unchanged_records';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_has_record_to_accept VARCHAR2(1) := FND_API.G_TRUE;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  -- Line Level Attributes
  UPDATE po_lines_draft_all PLD
  SET    PLD.change_accepted_flag = 'Y'
  WHERE  PLD.draft_id = p_draft_id
  AND    PLD.change_accepted_flag IS NULL
  AND    NVL(PLD.delete_flag, 'N') <> 'Y'
  AND    EXISTS
           ( SELECT 1
             FROM   po_lines_all PL
             WHERE  PLD.po_line_id = PL.po_line_id
             AND    DECODE (PLD.line_num,
                            PL.line_num, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.line_type_id,
                            PL.line_type_id, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.item_id,
                            PL.item_id, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.job_id,
                            PL.job_id, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.item_description,
                            PL.item_description, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.category_id,
                            PL.category_id, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.unit_meas_lookup_code,
                            PL.unit_meas_lookup_code, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.unit_price,
                            PL.unit_price, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.amount,
                            PL.amount, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.expiration_date,
                            PL.expiration_date, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.item_revision,
                            PL.item_revision, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.vendor_product_num,
                            PL.vendor_product_num, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.supplier_ref_number,
                            PL.supplier_ref_number, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.ip_category_id,
                            PL.ip_category_id, 'Y', 'N') = 'Y'
             AND    DECODE (NVL(PLD.capital_expense_flag, 'N'),
                            NVL(PL.capital_expense_flag, 'N'), 'Y', 'N') = 'Y'
             AND    DECODE (NVL(PLD.allow_price_override_flag, 'N'),
                            NVL(PL.allow_price_override_flag, 'N'), 'Y', 'N') = 'Y'
             AND    DECODE (PLD.not_to_exceed_price,
                            PL.not_to_exceed_price, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.list_price_per_unit,
                            PL.list_price_per_unit, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.market_price,
                            PL.market_price, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.price_type_lookup_code,
                            PL.price_type_lookup_code, 'Y', 'N') = 'Y'
             AND    DECODE (NVL(PLD.negotiated_by_preparer_flag, 'N'),
                            NVL(PL.negotiated_by_preparer_flag, 'N'), 'Y', 'N') = 'Y'
             AND    DECODE (PLD.min_release_amount,
                            PL.min_release_amount, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.committed_amount,
                            PL.committed_amount, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.quantity_committed,
                            PL.quantity_committed, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.supplier_part_auxid,
                            PL.supplier_part_auxid, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.un_number_id,
                            PL.un_number_id, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.hazard_class_id,
                            PL.hazard_class_id, 'Y', 'N') = 'Y'
             AND    DECODE (PLD.note_to_vendor,
                            PL.note_to_vendor, 'Y', 'N') = 'Y');

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, '# of lines autoaccepted', SQL%ROWCOUNT);
  END IF;

  d_position := 10;

  -- Price Break attributes
  UPDATE po_line_locations_draft_all PLLD
  SET    PLLD.change_accepted_flag = 'Y'
  WHERE  PLLD.draft_id = p_draft_id
  AND    PLLD.change_accepted_flag IS NULL
  AND    NVL(PLLD.delete_flag, 'N') <> 'Y'
  AND    EXISTS
           ( SELECT 1
             FROM   po_line_locations_all PLL
             WHERE  PLLD.line_location_id = PLL.line_location_id
             AND DECODE (PLLD.ship_to_organization_id,
                         PLL.ship_to_organization_id, 'Y', 'N') = 'Y'
             AND DECODE (PLLD.ship_to_location_id,
                         PLL.ship_to_location_id, 'Y', 'N') = 'Y'
             AND DECODE (PLLD.quantity,
                         PLL.quantity, 'Y', 'N') = 'Y'
             AND DECODE (PLLD.price_override,
                         PLL.price_override, 'Y', 'N') = 'Y'
             AND DECODE (PLLD.price_discount,
                         PLL.price_discount, 'Y', 'N') = 'Y'
             AND DECODE (PLLD.start_date,
                         PLL.start_date, 'Y', 'N') = 'Y'
             AND DECODE (PLLD.end_date,
                         PLL.end_date, 'Y', 'N') = 'Y');

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, '# of price breaks autoaccepted', SQL%ROWCOUNT);
  END IF;

  d_position := 20;

  -- Pirce Differentials Attributes
  UPDATE po_price_diff_draft PPDD
  SET    PPDD.change_accepted_flag = 'Y'
  WHERE  PPDD.draft_id = p_draft_id
  AND    PPDD.change_accepted_flag IS NULL
  AND    NVL(PPDD.delete_flag, 'N') <> 'Y'
  AND    EXISTS
           ( SELECT 1
             FROM   po_price_differentials PPD
             WHERE  PPDD.price_differential_id = PPD.price_differential_id
             AND    DECODE (PPDD.price_differential_num,
                            PPD.price_differential_num, 'Y', 'N') = 'Y'
             AND    DECODE (PPDD.price_type,
                            PPD.price_type, 'Y', 'N') = 'Y'
             AND    DECODE (PPDD.min_multiplier,
                            PPD.min_multiplier, 'Y', 'N') = 'Y'
             AND    DECODE (PPDD.max_multiplier,
                            PPD.max_multiplier, 'Y', 'N') = 'Y');

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, '# of price diff autoaccepted', SQL%ROWCOUNT);
  END IF;

  d_position := 30;

  -- Attribute Values
  UPDATE po_attribute_values_draft PAVD
  SET    PAVD.change_accepted_flag = 'Y'
  WHERE  PAVD.draft_id = p_draft_id
  AND    PAVD.change_accepted_flag IS NULL
  AND    NVL(PAVD.delete_flag, 'N') <> 'Y'
  AND    EXISTS
           ( SELECT 1
             FROM   po_attribute_values PAV
             WHERE  PAVD.attribute_values_id = PAV.attribute_values_id
             AND    DECODE (PAVD.manufacturer_part_num ,
                            PAV.manufacturer_part_num , 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.picture,
                            PAV.picture, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.thumbnail_image,
                            PAV.thumbnail_image, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.supplier_url,
                            PAV.supplier_url, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.manufacturer_url,
                            PAV.manufacturer_url, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.attachment_url,
                            PAV.attachment_url, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.unspsc,
                            PAV.unspsc, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.availability,
                            PAV.availability, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.lead_time,
                            PAV.lead_time, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute1,
                            PAV.text_base_attribute1, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute2,
                            PAV.text_base_attribute2, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute3,
                            PAV.text_base_attribute3, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute4,
                            PAV.text_base_attribute4, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute5,
                            PAV.text_base_attribute5, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute6,
                            PAV.text_base_attribute6, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute7,
                            PAV.text_base_attribute7, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute8,
                            PAV.text_base_attribute8, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute9,
                            PAV.text_base_attribute9, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute10,
                            PAV.text_base_attribute10, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute11,
                            PAV.text_base_attribute11, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute12,
                            PAV.text_base_attribute12, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute13,
                            PAV.text_base_attribute13, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute14,
                            PAV.text_base_attribute14, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute15,
                            PAV.text_base_attribute15, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute16,
                            PAV.text_base_attribute16, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute17,
                            PAV.text_base_attribute17, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute18,
                            PAV.text_base_attribute18, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute19,
                            PAV.text_base_attribute19, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute20,
                            PAV.text_base_attribute20, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute21,
                            PAV.text_base_attribute21, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute22,
                            PAV.text_base_attribute22, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute23,
                            PAV.text_base_attribute23, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute24,
                            PAV.text_base_attribute24, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute25,
                            PAV.text_base_attribute25, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute26,
                            PAV.text_base_attribute26, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute27,
                            PAV.text_base_attribute27, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute28,
                            PAV.text_base_attribute28, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute29,
                            PAV.text_base_attribute29, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute30,
                            PAV.text_base_attribute30, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute31,
                            PAV.text_base_attribute31, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute32,
                            PAV.text_base_attribute32, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute33,
                            PAV.text_base_attribute33, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute34,
                            PAV.text_base_attribute34, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute35,
                            PAV.text_base_attribute35, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute36,
                            PAV.text_base_attribute36, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute37,
                            PAV.text_base_attribute37, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute38,
                            PAV.text_base_attribute38, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute39,
                            PAV.text_base_attribute39, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute40,
                            PAV.text_base_attribute40, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute41,
                            PAV.text_base_attribute41, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute42,
                            PAV.text_base_attribute42, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute43,
                            PAV.text_base_attribute43, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute44,
                            PAV.text_base_attribute44, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute45,
                            PAV.text_base_attribute45, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute46,
                            PAV.text_base_attribute46, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute47,
                            PAV.text_base_attribute47, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute48,
                            PAV.text_base_attribute48, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute49,
                            PAV.text_base_attribute49, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute50,
                            PAV.text_base_attribute50, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute51,
                            PAV.text_base_attribute51, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute52,
                            PAV.text_base_attribute52, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute53,
                            PAV.text_base_attribute53, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute54,
                            PAV.text_base_attribute54, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute55,
                            PAV.text_base_attribute55, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute56,
                            PAV.text_base_attribute56, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute57,
                            PAV.text_base_attribute57, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute58,
                            PAV.text_base_attribute58, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute59,
                            PAV.text_base_attribute59, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute60,
                            PAV.text_base_attribute60, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute61,
                            PAV.text_base_attribute61, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute62,
                            PAV.text_base_attribute62, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute63,
                            PAV.text_base_attribute63, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute64,
                            PAV.text_base_attribute64, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute65,
                            PAV.text_base_attribute65, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute66,
                            PAV.text_base_attribute66, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute67,
                            PAV.text_base_attribute67, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute68,
                            PAV.text_base_attribute68, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute69,
                            PAV.text_base_attribute69, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute70,
                            PAV.text_base_attribute70, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute71,
                            PAV.text_base_attribute71, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute72,
                            PAV.text_base_attribute72, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute73,
                            PAV.text_base_attribute73, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute74,
                            PAV.text_base_attribute74, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute75,
                            PAV.text_base_attribute75, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute76,
                            PAV.text_base_attribute76, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute77,
                            PAV.text_base_attribute77, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute78,
                            PAV.text_base_attribute78, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute79,
                            PAV.text_base_attribute79, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute80,
                            PAV.text_base_attribute80, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute81,
                            PAV.text_base_attribute81, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute82,
                            PAV.text_base_attribute82, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute83,
                            PAV.text_base_attribute83, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute84,
                            PAV.text_base_attribute84, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute85,
                            PAV.text_base_attribute85, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute86,
                            PAV.text_base_attribute86, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute87,
                            PAV.text_base_attribute87, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute88,
                            PAV.text_base_attribute88, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute89,
                            PAV.text_base_attribute89, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute90,
                            PAV.text_base_attribute90, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute91,
                            PAV.text_base_attribute91, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute92,
                            PAV.text_base_attribute92, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute93,
                            PAV.text_base_attribute93, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute94,
                            PAV.text_base_attribute94, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute95,
                            PAV.text_base_attribute95, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute96,
                            PAV.text_base_attribute96, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute97,
                            PAV.text_base_attribute97, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute98,
                            PAV.text_base_attribute98, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute99,
                            PAV.text_base_attribute99, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_base_attribute100,
                            PAV.text_base_attribute100, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute1,
                            PAV.num_base_attribute1, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute2,
                            PAV.num_base_attribute2, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute3,
                            PAV.num_base_attribute3, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute4,
                            PAV.num_base_attribute4, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute5,
                            PAV.num_base_attribute5, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute6,
                            PAV.num_base_attribute6, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute7,
                            PAV.num_base_attribute7, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute8,
                            PAV.num_base_attribute8, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute9,
                            PAV.num_base_attribute9, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute10,
                            PAV.num_base_attribute10, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute11,
                            PAV.num_base_attribute11, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute12,
                            PAV.num_base_attribute12, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute13,
                            PAV.num_base_attribute13, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute14,
                            PAV.num_base_attribute14, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute15,
                            PAV.num_base_attribute15, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute16,
                            PAV.num_base_attribute16, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute17,
                            PAV.num_base_attribute17, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute18,
                            PAV.num_base_attribute18, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute19,
                            PAV.num_base_attribute19, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute20,
                            PAV.num_base_attribute20, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute21,
                            PAV.num_base_attribute21, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute22,
                            PAV.num_base_attribute22, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute23,
                            PAV.num_base_attribute23, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute24,
                            PAV.num_base_attribute24, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute25,
                            PAV.num_base_attribute25, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute26,
                            PAV.num_base_attribute26, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute27,
                            PAV.num_base_attribute27, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute28,
                            PAV.num_base_attribute28, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute29,
                            PAV.num_base_attribute29, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute30,
                            PAV.num_base_attribute30, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute31,
                            PAV.num_base_attribute31, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute32,
                            PAV.num_base_attribute32, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute33,
                            PAV.num_base_attribute33, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute34,
                            PAV.num_base_attribute34, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute35,
                            PAV.num_base_attribute35, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute36,
                            PAV.num_base_attribute36, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute37,
                            PAV.num_base_attribute37, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute38,
                            PAV.num_base_attribute38, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute39,
                            PAV.num_base_attribute39, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute40,
                            PAV.num_base_attribute40, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute41,
                            PAV.num_base_attribute41, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute42,
                            PAV.num_base_attribute42, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute43,
                            PAV.num_base_attribute43, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute44,
                            PAV.num_base_attribute44, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute45,
                            PAV.num_base_attribute45, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute46,
                            PAV.num_base_attribute46, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute47,
                            PAV.num_base_attribute47, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute48,
                            PAV.num_base_attribute48, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute49,
                            PAV.num_base_attribute49, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute50,
                            PAV.num_base_attribute50, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute51,
                            PAV.num_base_attribute51, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute52,
                            PAV.num_base_attribute52, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute53,
                            PAV.num_base_attribute53, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute54,
                            PAV.num_base_attribute54, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute55,
                            PAV.num_base_attribute55, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute56,
                            PAV.num_base_attribute56, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute57,
                            PAV.num_base_attribute57, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute58,
                            PAV.num_base_attribute58, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute59,
                            PAV.num_base_attribute59, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute60,
                            PAV.num_base_attribute60, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute61,
                            PAV.num_base_attribute61, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute62,
                            PAV.num_base_attribute62, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute63,
                            PAV.num_base_attribute63, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute64,
                            PAV.num_base_attribute64, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute65,
                            PAV.num_base_attribute65, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute66,
                            PAV.num_base_attribute66, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute67,
                            PAV.num_base_attribute67, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute68,
                            PAV.num_base_attribute68, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute69,
                            PAV.num_base_attribute69, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute70,
                            PAV.num_base_attribute70, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute71,
                            PAV.num_base_attribute71, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute72,
                            PAV.num_base_attribute72, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute73,
                            PAV.num_base_attribute73, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute74,
                            PAV.num_base_attribute74, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute75,
                            PAV.num_base_attribute75, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute76,
                            PAV.num_base_attribute76, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute77,
                            PAV.num_base_attribute77, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute78,
                            PAV.num_base_attribute78, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute79,
                            PAV.num_base_attribute79, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute80,
                            PAV.num_base_attribute80, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute81,
                            PAV.num_base_attribute81, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute82,
                            PAV.num_base_attribute82, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute83,
                            PAV.num_base_attribute83, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute84,
                            PAV.num_base_attribute84, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute85,
                            PAV.num_base_attribute85, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute86,
                            PAV.num_base_attribute86, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute87,
                            PAV.num_base_attribute87, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute88,
                            PAV.num_base_attribute88, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute89,
                            PAV.num_base_attribute89, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute90,
                            PAV.num_base_attribute90, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute91,
                            PAV.num_base_attribute91, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute92,
                            PAV.num_base_attribute92, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute93,
                            PAV.num_base_attribute93, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute94,
                            PAV.num_base_attribute94, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute95,
                            PAV.num_base_attribute95, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute96,
                            PAV.num_base_attribute96, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute97,
                            PAV.num_base_attribute97, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute98,
                            PAV.num_base_attribute98, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute99,
                            PAV.num_base_attribute99, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_base_attribute100,
                            PAV.num_base_attribute100, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute1,
                            PAV.text_cat_attribute1, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute2,
                            PAV.text_cat_attribute2, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute3,
                            PAV.text_cat_attribute3, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute4,
                            PAV.text_cat_attribute4, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute5,
                            PAV.text_cat_attribute5, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute6,
                            PAV.text_cat_attribute6, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute7,
                            PAV.text_cat_attribute7, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute8,
                            PAV.text_cat_attribute8, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute9,
                            PAV.text_cat_attribute9, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute10,
                            PAV.text_cat_attribute10, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute11,
                            PAV.text_cat_attribute11, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute12,
                            PAV.text_cat_attribute12, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute13,
                            PAV.text_cat_attribute13, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute14,
                            PAV.text_cat_attribute14, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute15,
                            PAV.text_cat_attribute15, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute16,
                            PAV.text_cat_attribute16, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute17,
                            PAV.text_cat_attribute17, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute18,
                            PAV.text_cat_attribute18, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute19,
                            PAV.text_cat_attribute19, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute20,
                            PAV.text_cat_attribute20, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute21,
                            PAV.text_cat_attribute21, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute22,
                            PAV.text_cat_attribute22, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute23,
                            PAV.text_cat_attribute23, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute24,
                            PAV.text_cat_attribute24, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute25,
                            PAV.text_cat_attribute25, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute26,
                            PAV.text_cat_attribute26, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute27,
                            PAV.text_cat_attribute27, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute28,
                            PAV.text_cat_attribute28, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute29,
                            PAV.text_cat_attribute29, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute30,
                            PAV.text_cat_attribute30, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute31,
                            PAV.text_cat_attribute31, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute32,
                            PAV.text_cat_attribute32, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute33,
                            PAV.text_cat_attribute33, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute34,
                            PAV.text_cat_attribute34, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute35,
                            PAV.text_cat_attribute35, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute36,
                            PAV.text_cat_attribute36, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute37,
                            PAV.text_cat_attribute37, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute38,
                            PAV.text_cat_attribute38, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute39,
                            PAV.text_cat_attribute39, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute40,
                            PAV.text_cat_attribute40, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute41,
                            PAV.text_cat_attribute41, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute42,
                            PAV.text_cat_attribute42, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute43,
                            PAV.text_cat_attribute43, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute44,
                            PAV.text_cat_attribute44, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute45,
                            PAV.text_cat_attribute45, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute46,
                            PAV.text_cat_attribute46, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute47,
                            PAV.text_cat_attribute47, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute48,
                            PAV.text_cat_attribute48, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute49,
                            PAV.text_cat_attribute49, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.text_cat_attribute50,
                            PAV.text_cat_attribute50, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute1,
                            PAV.num_cat_attribute1, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute2,
                            PAV.num_cat_attribute2, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute3,
                            PAV.num_cat_attribute3, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute4,
                            PAV.num_cat_attribute4, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute5,
                            PAV.num_cat_attribute5, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute6,
                            PAV.num_cat_attribute6, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute7,
                            PAV.num_cat_attribute7, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute8,
                            PAV.num_cat_attribute8, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute9,
                            PAV.num_cat_attribute9, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute10,
                            PAV.num_cat_attribute10, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute11,
                            PAV.num_cat_attribute11, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute12,
                            PAV.num_cat_attribute12, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute13,
                            PAV.num_cat_attribute13, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute14,
                            PAV.num_cat_attribute14, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute15,
                            PAV.num_cat_attribute15, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute16,
                            PAV.num_cat_attribute16, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute17,
                            PAV.num_cat_attribute17, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute18,
                            PAV.num_cat_attribute18, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute19,
                            PAV.num_cat_attribute19, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute20,
                            PAV.num_cat_attribute20, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute21,
                            PAV.num_cat_attribute21, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute22,
                            PAV.num_cat_attribute22, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute23,
                            PAV.num_cat_attribute23, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute24,
                            PAV.num_cat_attribute24, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute25,
                            PAV.num_cat_attribute25, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute26,
                            PAV.num_cat_attribute26, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute27,
                            PAV.num_cat_attribute27, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute28,
                            PAV.num_cat_attribute28, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute29,
                            PAV.num_cat_attribute29, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute30,
                            PAV.num_cat_attribute30, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute31,
                            PAV.num_cat_attribute31, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute32,
                            PAV.num_cat_attribute32, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute33,
                            PAV.num_cat_attribute33, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute34,
                            PAV.num_cat_attribute34, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute35,
                            PAV.num_cat_attribute35, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute36,
                            PAV.num_cat_attribute36, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute37,
                            PAV.num_cat_attribute37, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute38,
                            PAV.num_cat_attribute38, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute39,
                            PAV.num_cat_attribute39, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute40,
                            PAV.num_cat_attribute40, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute41,
                            PAV.num_cat_attribute41, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute42,
                            PAV.num_cat_attribute42, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute43,
                            PAV.num_cat_attribute43, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute44,
                            PAV.num_cat_attribute44, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute45,
                            PAV.num_cat_attribute45, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute46,
                            PAV.num_cat_attribute46, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute47,
                            PAV.num_cat_attribute47, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute48,
                            PAV.num_cat_attribute48, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute49,
                            PAV.num_cat_attribute49, 'Y', 'N') = 'Y'
             AND    DECODE (PAVD.num_cat_attribute50,
                            PAV.num_cat_attribute50, 'Y', 'N') = 'Y');


  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, '# of attr values autoaccepted', SQL%ROWCOUNT);
  END IF;

  d_position := 40;

  -- Attribute values tlp
  UPDATE po_attribute_values_tlp_draft PAVTD
  SET    PAVTD.change_accepted_flag = 'Y'
  WHERE  PAVTD.draft_id = p_draft_id
  AND    PAVTD.change_accepted_flag IS NULL
  AND    NVL(PAVTD.delete_flag, 'N') <> 'Y'
  AND    EXISTS
           ( SELECT 1
             FROM   po_attribute_values_tlp PAVT
             WHERE  PAVTD.attribute_values_tlp_id = PAVT.attribute_values_tlp_id
             AND    DECODE (PAVTD.description,
                            PAVT.description, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.manufacturer,
                            PAVT.manufacturer, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.comments,
                            PAVT.comments, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.alias,
                            PAVT.alias, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.long_description,
                            PAVT.long_description, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute1,
                            PAVT.tl_text_base_attribute1, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute2,
                            PAVT.tl_text_base_attribute2, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute3,
                            PAVT.tl_text_base_attribute3, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute4,
                            PAVT.tl_text_base_attribute4, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute5,
                            PAVT.tl_text_base_attribute5, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute6,
                            PAVT.tl_text_base_attribute6, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute7,
                            PAVT.tl_text_base_attribute7, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute8,
                            PAVT.tl_text_base_attribute8, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute9,
                            PAVT.tl_text_base_attribute9, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute10,
                            PAVT.tl_text_base_attribute10, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute11,
                            PAVT.tl_text_base_attribute11, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute12,
                            PAVT.tl_text_base_attribute12, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute13,
                            PAVT.tl_text_base_attribute13, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute14,
                            PAVT.tl_text_base_attribute14, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute15,
                            PAVT.tl_text_base_attribute15, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute16,
                            PAVT.tl_text_base_attribute16, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute17,
                            PAVT.tl_text_base_attribute17, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute18,
                            PAVT.tl_text_base_attribute18, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute19,
                            PAVT.tl_text_base_attribute19, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute20,
                            PAVT.tl_text_base_attribute20, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute21,
                            PAVT.tl_text_base_attribute21, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute22,
                            PAVT.tl_text_base_attribute22, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute23,
                            PAVT.tl_text_base_attribute23, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute24,
                            PAVT.tl_text_base_attribute24, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute25,
                            PAVT.tl_text_base_attribute25, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute26,
                            PAVT.tl_text_base_attribute26, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute27,
                            PAVT.tl_text_base_attribute27, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute28,
                            PAVT.tl_text_base_attribute28, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute29,
                            PAVT.tl_text_base_attribute29, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute30,
                            PAVT.tl_text_base_attribute30, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute31,
                            PAVT.tl_text_base_attribute31, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute32,
                            PAVT.tl_text_base_attribute32, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute33,
                            PAVT.tl_text_base_attribute33, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute34,
                            PAVT.tl_text_base_attribute34, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute35,
                            PAVT.tl_text_base_attribute35, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute36,
                            PAVT.tl_text_base_attribute36, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute37,
                            PAVT.tl_text_base_attribute37, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute38,
                            PAVT.tl_text_base_attribute38, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute39,
                            PAVT.tl_text_base_attribute39, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute40,
                            PAVT.tl_text_base_attribute40, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute41,
                            PAVT.tl_text_base_attribute41, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute42,
                            PAVT.tl_text_base_attribute42, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute43,
                            PAVT.tl_text_base_attribute43, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute44,
                            PAVT.tl_text_base_attribute44, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute45,
                            PAVT.tl_text_base_attribute45, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute46,
                            PAVT.tl_text_base_attribute46, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute47,
                            PAVT.tl_text_base_attribute47, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute48,
                            PAVT.tl_text_base_attribute48, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute49,
                            PAVT.tl_text_base_attribute49, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute50,
                            PAVT.tl_text_base_attribute50, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute51,
                            PAVT.tl_text_base_attribute51, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute52,
                            PAVT.tl_text_base_attribute52, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute53,
                            PAVT.tl_text_base_attribute53, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute54,
                            PAVT.tl_text_base_attribute54, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute55,
                            PAVT.tl_text_base_attribute55, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute56,
                            PAVT.tl_text_base_attribute56, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute57,
                            PAVT.tl_text_base_attribute57, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute58,
                            PAVT.tl_text_base_attribute58, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute59,
                            PAVT.tl_text_base_attribute59, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute60,
                            PAVT.tl_text_base_attribute60, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute61,
                            PAVT.tl_text_base_attribute61, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute62,
                            PAVT.tl_text_base_attribute62, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute63,
                            PAVT.tl_text_base_attribute63, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute64,
                            PAVT.tl_text_base_attribute64, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute65,
                            PAVT.tl_text_base_attribute65, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute66,
                            PAVT.tl_text_base_attribute66, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute67,
                            PAVT.tl_text_base_attribute67, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute68,
                            PAVT.tl_text_base_attribute68, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute69,
                            PAVT.tl_text_base_attribute69, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute70,
                            PAVT.tl_text_base_attribute70, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute71,
                            PAVT.tl_text_base_attribute71, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute72,
                            PAVT.tl_text_base_attribute72, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute73,
                            PAVT.tl_text_base_attribute73, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute74,
                            PAVT.tl_text_base_attribute74, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute75,
                            PAVT.tl_text_base_attribute75, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute76,
                            PAVT.tl_text_base_attribute76, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute77,
                            PAVT.tl_text_base_attribute77, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute78,
                            PAVT.tl_text_base_attribute78, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute79,
                            PAVT.tl_text_base_attribute79, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute80,
                            PAVT.tl_text_base_attribute80, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute81,
                            PAVT.tl_text_base_attribute81, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute82,
                            PAVT.tl_text_base_attribute82, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute83,
                            PAVT.tl_text_base_attribute83, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute84,
                            PAVT.tl_text_base_attribute84, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute85,
                            PAVT.tl_text_base_attribute85, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute86,
                            PAVT.tl_text_base_attribute86, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute87,
                            PAVT.tl_text_base_attribute87, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute88,
                            PAVT.tl_text_base_attribute88, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute89,
                            PAVT.tl_text_base_attribute89, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute90,
                            PAVT.tl_text_base_attribute90, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute91,
                            PAVT.tl_text_base_attribute91, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute92,
                            PAVT.tl_text_base_attribute92, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute93,
                            PAVT.tl_text_base_attribute93, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute94,
                            PAVT.tl_text_base_attribute94, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute95,
                            PAVT.tl_text_base_attribute95, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute96,
                            PAVT.tl_text_base_attribute96, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute97,
                            PAVT.tl_text_base_attribute97, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute98,
                            PAVT.tl_text_base_attribute98, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute99,
                            PAVT.tl_text_base_attribute99, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_base_attribute100,
                            PAVT.tl_text_base_attribute100, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute1,
                            PAVT.tl_text_cat_attribute1, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute2,
                            PAVT.tl_text_cat_attribute2, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute3,
                            PAVT.tl_text_cat_attribute3, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute4,
                            PAVT.tl_text_cat_attribute4, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute5,
                            PAVT.tl_text_cat_attribute5, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute6,
                            PAVT.tl_text_cat_attribute6, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute7,
                            PAVT.tl_text_cat_attribute7, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute8,
                            PAVT.tl_text_cat_attribute8, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute9,
                            PAVT.tl_text_cat_attribute9, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute10,
                            PAVT.tl_text_cat_attribute10, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute11,
                            PAVT.tl_text_cat_attribute11, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute12,
                            PAVT.tl_text_cat_attribute12, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute13,
                            PAVT.tl_text_cat_attribute13, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute14,
                            PAVT.tl_text_cat_attribute14, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute15,
                            PAVT.tl_text_cat_attribute15, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute16,
                            PAVT.tl_text_cat_attribute16, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute17,
                            PAVT.tl_text_cat_attribute17, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute18,
                            PAVT.tl_text_cat_attribute18, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute19,
                            PAVT.tl_text_cat_attribute19, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute20,
                            PAVT.tl_text_cat_attribute20, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute21,
                            PAVT.tl_text_cat_attribute21, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute22,
                            PAVT.tl_text_cat_attribute22, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute23,
                            PAVT.tl_text_cat_attribute23, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute24,
                            PAVT.tl_text_cat_attribute24, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute25,
                            PAVT.tl_text_cat_attribute25, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute26,
                            PAVT.tl_text_cat_attribute26, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute27,
                            PAVT.tl_text_cat_attribute27, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute28,
                            PAVT.tl_text_cat_attribute28, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute29,
                            PAVT.tl_text_cat_attribute29, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute30,
                            PAVT.tl_text_cat_attribute30, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute31,
                            PAVT.tl_text_cat_attribute31, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute32,
                            PAVT.tl_text_cat_attribute32, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute33,
                            PAVT.tl_text_cat_attribute33, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute34,
                            PAVT.tl_text_cat_attribute34, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute35,
                            PAVT.tl_text_cat_attribute35, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute36,
                            PAVT.tl_text_cat_attribute36, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute37,
                            PAVT.tl_text_cat_attribute37, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute38,
                            PAVT.tl_text_cat_attribute38, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute39,
                            PAVT.tl_text_cat_attribute39, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute40,
                            PAVT.tl_text_cat_attribute40, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute41,
                            PAVT.tl_text_cat_attribute41, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute42,
                            PAVT.tl_text_cat_attribute42, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute43,
                            PAVT.tl_text_cat_attribute43, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute44,
                            PAVT.tl_text_cat_attribute44, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute45,
                            PAVT.tl_text_cat_attribute45, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute46,
                            PAVT.tl_text_cat_attribute46, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute47,
                            PAVT.tl_text_cat_attribute47, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute48,
                            PAVT.tl_text_cat_attribute48, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute49,
                            PAVT.tl_text_cat_attribute49, 'Y', 'N') = 'Y'
             AND    DECODE (PAVTD.tl_text_cat_attribute50,
                            PAVT.tl_text_cat_attribute50, 'Y', 'N') = 'Y');

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt (d_module, d_position, '# of attr values tlp autoaccepted', SQL%ROWCOUNT);
  END IF;

  d_position := 50;

  l_has_record_to_accept := has_record_to_accept
                            ( p_draft_id => p_draft_id
                            );


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module, 'l_has_record_to_accept', l_has_record_to_accept);
  END IF;

  RETURN l_has_record_to_accept;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );

  RAISE;
END autoaccept_unchanged_records;


-----------------------------------------------------------------------
--Start of Comments
--Name: has_record_to_accept
--Function:
--  Returns whether there's still record pending for acceptance in the
--  draft
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--IN OUT:
--OUT:
--Return:
--  FND_API.G_TRUE if there's still record in the draft to accept
--  FND_API.G_FALSE otherwise
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
FUNCTION has_record_to_accept
( p_draft_id IN NUMBER
) RETURN VARCHAR2
IS

d_api_name CONSTANT VARCHAR2(30) := 'has_record_to_accept';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_has_record_to_accept VARCHAR2(1) := FND_API.G_TRUE;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  SELECT NVL(MAX(FND_API.G_TRUE), FND_API.G_FALSE)
  INTO   l_has_record_to_accept
  FROM   DUAL
  WHERE  EXISTS
           ( SELECT 1
             FROM   po_lines_draft_all
             WHERE  draft_id = p_draft_id
             AND    change_accepted_flag IS NULL)
  OR     EXISTS
           ( SELECT 1
             FROM   po_line_locations_draft_all
             WHERE  draft_id = p_draft_id
             AND    change_accepted_flag IS NULL)
  OR     EXISTS
           ( SELECT 1
             FROM   po_price_diff_draft
             WHERE  draft_id = p_draft_id
             AND    change_accepted_flag IS NULL)
  OR     EXISTS
           ( SELECT 1
             FROM   po_attribute_values_draft
             WHERE  draft_id = p_draft_id
             AND    change_accepted_flag IS NULL)
  OR     EXISTS
           ( SELECT 1
             FROM   po_attribute_values_tlp_draft
             WHERE  draft_id = p_draft_id
             AND    change_accepted_flag IS NULL);


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module, 'l_has_record_to_accept', l_has_record_to_accept);
  END IF;

  RETURN l_has_record_to_accept;


EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );

  RAISE;
END has_record_to_accept;

-- bug5249414 END


-- bug5035979 START
-- when the price acceptance level is 'Required when price update exceeds
-- tolerance', we need to autoaccept lines that do not contain line changes

-----------------------------------------------------------------------
--Start of Comments
--Name: accept_if_no_line_changes
--Function:
--  Autoaccept records that do not have line level changes. This is called
--  when acceptance level is 'required when price exceeds tolereance'. We
--  do not need to accept the records since they won't contain any price
--  changes.
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--IN OUT:
--OUT:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE accept_if_no_line_changes
( p_draft_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'accept_if_no_line_changes';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

BEGIN

  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module);
  END IF;

  UPDATE po_line_locations_draft_all PLLDA
  SET    PLLDA.change_accepted_flag = 'Y'
  WHERE  PLLDA.draft_id = p_draft_id
  AND    NVL(PLLDA.change_accepted_flag, 'N') <> 'Y'
  AND    NOT EXISTS
           ( SELECT NULL
             FROM   po_lines_draft_all PLDA
             WHERE  PLDA.po_line_id = PLLDA.po_line_id
             AND    PLDA.draft_id = PLLDA.draft_id );

  d_position := 10;

  UPDATE po_attribute_values_draft PLVD
  SET    PLVD.change_accepted_flag = 'Y'
  WHERE  PLVD.draft_id = p_draft_id
  AND    NVL(PLVD.change_accepted_flag, 'N') <> 'Y'
  AND    NOT EXISTS
           ( SELECT NULL
             FROM   po_lines_draft_all PLDA
             WHERE  PLDA.po_line_id = PLVD.po_line_id
             AND    PLDA.draft_id = PLVD.draft_id );

  d_position := 20;

  UPDATE po_attribute_values_tlp_draft PLVTD
  SET    PLVTD.change_accepted_flag = 'Y'
  WHERE  PLVTD.draft_id = p_draft_id
  AND    NVL(PLVTD.change_accepted_flag, 'N') <> 'Y'
  AND    NOT EXISTS
           ( SELECT NULL
             FROM   po_lines_draft_all PLDA
             WHERE  PLDA.po_line_id = PLVTD.po_line_id
  AND    PLDA.draft_id = PLVTD.draft_id );

  d_position := 30;

  UPDATE po_price_diff_draft PPDD
  SET    PPDD.change_accepted_flag = 'Y'
  WHERE  PPDD.draft_id = p_draft_id
  AND    NVL(PPDD.change_accepted_flag, 'N') <> 'Y'
  AND    (( PPDD.entity_type = 'BLANKET LINE'
            AND NOT EXISTS
            ( SELECT NULL
              FROM   po_lines_draft_all PLDA
              WHERE  PLDA.po_line_id = PPDD.entity_id
              AND    PLDA.draft_id = PPDD.draft_id
            )
          )
          OR
          ( PPDD.entity_type = 'PRICE BREAK'
            AND NOT EXISTS
            ( SELECT NULL
              FROM   po_line_locations_draft_all PLLDA,
                     po_lines_draft_all PLDA
              WHERE  PLLDA.line_location_id = PPDD.entity_id
              AND    PLLDA.draft_id = PPDD.draft_id
              AND    PLDA.po_line_id = PLLDA.po_line_id
              AND    PLDA.draft_id = PLLDA.draft_id )
            AND NOT EXISTS
            ( SELECT NULL
              FROM   po_line_locations_all PLLA,
                     po_lines_draft_all PLDA
              WHERE  PLLA.line_location_id = PPDD.entity_id
              AND    PLDA.po_line_id = PLLA.po_line_id
              AND    PLDA.draft_id = PPDD.draft_id)));

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
END accept_if_no_line_changes;

-----------------------------------------------------------------------
--Start of Comments
--Name: cascade_change_acceptance
--Function:
--  Update the change acceptance status for the lines being passed in,
--  and cascade the changes to their children.
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_line_id_list
--  lines to modify
--p_change_accepted_value
--  New change acceptance status
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE cascade_change_acceptance
( p_draft_id IN NUMBER,
  p_line_id_list IN PO_TBL_NUMBER,
  p_change_accepted_value IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'cascade_change_acceptance';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

BEGIN
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'p_draft_id', p_draft_id);
    PO_LOG.proc_begin (d_module, 'p_line_id_list.COUNT', p_line_id_list.COUNT);
  END IF;

  x_return_status := FND_API.g_RET_STS_SUCCESS;

  -- Update records in PO_LINES_DRAFT_ALL based on the list of lines to change
  -- in p_line_id_list;
  FORALL i IN 1..p_line_id_list.COUNT
    UPDATE po_lines_draft_all
    SET change_accepted_flag = p_change_accepted_value
    WHERE draft_id = p_draft_id
    AND po_line_id = p_line_id_list(i);

  d_position := 10;

  -- price breaks
  FORALL i IN 1..p_line_id_list.COUNT
    UPDATE po_line_locations_draft_all
    SET change_accepted_flag = p_change_accepted_value
    WHERE draft_id = p_draft_id
    AND po_line_id = p_line_id_list(i);

  d_position := 20;

  -- attribute values
  FORALL i IN 1..p_line_id_list.COUNT
    UPDATE po_attribute_values_draft
    SET change_accepted_flag = p_change_accepted_value
    WHERE draft_id = p_draft_id
    AND po_line_id = p_line_id_list(i);

  d_position := 30;

  -- attribute values tlp
  FORALL i IN 1..p_line_id_list.COUNT
    UPDATE po_attribute_values_tlp_draft
    SET change_accepted_flag = p_change_accepted_value
    WHERE draft_id = p_draft_id
    AND po_line_id = p_line_id_list(i);

  d_position := 40;

  -- blanket line price differentials
  FORALL i IN 1..p_line_id_list.COUNT
    UPDATE po_price_diff_draft
    SET change_accepted_flag = p_change_accepted_value
    WHERE draft_id = p_draft_id
    AND entity_id = p_line_id_list(i)
    AND entity_type = 'BLANKET LINE';

  d_position := 50;

  -- Price break price diffs - the po_line_id reference can either
  -- be found in draft or transaction table
  FORALL i IN 1..p_line_id_list.COUNT
    UPDATE po_price_diff_draft PPDD
    SET change_accepted_flag = p_change_accepted_value
    WHERE draft_id = p_draft_id
    AND entity_type = 'PRICE BREAK'
    AND EXISTS (SELECT 1
                FROM po_line_locations_draft_all PLLD
                WHERE PLLD.draft_id = p_draft_id
                AND PLLD.po_line_id = p_line_id_list(i)
                AND PLLD.line_location_id = PPDD.entity_id
                UNION ALL
                SELECT 1
                FROM po_line_locations_all PLLD
                WHERE PLLD.po_line_id = p_line_id_list(i)
                AND PLLD.line_location_id = PPDD.entity_id);

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END cascade_change_acceptance;

-- bug5035979 END

-- bug5187544 START
-----------------------------------------------------------------------
--Start of Comments
--Name: validate_disposition
--Function:
--  Validate the rejected list by the user can make sure that the action
--  can be performed
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_reject_line_id_list
--  lines being rejected
--IN OUT:
--OUT:
--x_invalid_line_id_list
--  lines that fail the validation
--x_invalid_line_num_list
--  line num for the lines that fail the validation
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE validate_disposition
( p_draft_id IN NUMBER,
  p_reject_line_id_list IN PO_TBL_NUMBER,
  x_invalid_line_id_list OUT NOCOPY PO_TBL_NUMBER,
  x_invalid_line_num_list OUT NOCOPY PO_TBL_NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'validate_disposition';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;

l_key PO_SESSION_GT.key%TYPE;

BEGIN

  d_position := 0;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'p_draft_id', p_draft_id);
  END IF;

  x_invalid_line_id_list := PO_TBL_NUMBER();

  IF (p_reject_line_id_list IS NULL OR
      p_reject_line_id_list.COUNT = 0) THEN
    RETURN;
  END IF;

  -- If user rejects the deletion of a line, he cannot accept another line
  -- with the same line number, otherwise we'll have the old line not being
  -- deleted and the new line (same line #) being inserted.

  l_key := PO_CORE_S.get_session_gt_nextval;

  d_position := 10;

  FORALL i IN 1..p_reject_line_id_list.COUNT
    INSERT INTO po_session_gt
    ( key,
      index_num1,    -- po_line_id
      num2,          -- line_num
      char2          -- delete_flag
    )
    SELECT l_key,
           p_reject_line_id_list(i),
           pld.line_num,
           pld.delete_flag
    FROM   po_lines_draft_all pld
    WHERE  pld.draft_id = p_draft_id
    AND    pld.po_line_id = p_reject_line_id_list(i);

  d_position := 20;

  -- SQL What: Return the deleted lines that are being rejected, if there are
  --           other lines with the same line number that are being accepted
  SELECT PSG.index_num1,
         num2
  BULK COLLECT
  INTO   x_invalid_line_id_list,
         x_invalid_line_num_list
  FROM   po_session_gt PSG
  WHERE  PSG.key = l_key
  AND    PSG.char2 = 'Y'  -- delete_flag
  AND    EXISTS
           (SELECT NULL
            FROM   po_lines_draft_all PLD
            WHERE  PLD.draft_id = p_draft_id
            AND    NVL(PLD.delete_flag, 'N') <> 'Y'
            AND    PLD.line_num = PSG.num2  -- line_num
            AND    NOT EXISTS
                     (SELECT NULL
                      FROM   po_session_gt PSG1
                      WHERE  PSG1.key = l_key
                      AND    PSG1.index_num1 = PLD.po_line_id));

  d_position := 30;

  DELETE FROM po_session_gt
  WHERE key = l_key;

  IF (x_invalid_line_id_list.COUNT > 0) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  PO_MESSAGE_S.add_exc_msg
  ( p_pkg_name => d_pkg_name,
    p_procedure_name => d_api_name || '.' || d_position
  );
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END validate_disposition;

-- bug5187544 END

--Bug 12964696
PROCEDURE post_buyer_acceptance
( itemtype        IN VARCHAR2,
  itemkey         IN VARCHAR2,
  actid           IN NUMBER,
  funcmode        IN VARCHAR2,
  resultout       OUT NOCOPY VARCHAR2
)
IS

d_api_name CONSTANT VARCHAR2(30) := 'post_buyer_acceptance';
d_module CONSTANT VARCHAR2(255) := PO_LOG.get_subprogram_base(d_pkg_name, d_api_name);
d_position NUMBER;


   l_nid   wf_notifications.notification_id%TYPE;
   l_session_user_id  fnd_user.USER_ID%TYPE;
   l_responder_id fnd_user.USER_ID%TYPE;
   l_responder_name fnd_user.user_name%TYPE;

BEGIN

  d_position := 0;



  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin (d_module, 'funcmode : ', funcmode);
  END IF;



IF (funcmode = 'CANCEL') THEN
        d_position := 1;

 l_nid := WF_ENGINE.context_nid;
 l_session_user_id := fnd_global.user_id;



    SELECT fu.USER_ID, fu.user_name
      INTO l_responder_id, l_responder_name
      FROM fnd_user fu,
           wf_notifications wfn
     WHERE wfn.notification_id = l_nid
       AND wfn.original_recipient = fu.user_name;

            d_position := 2;

IF (l_responder_id = l_session_user_id) THEN
       d_position := 3;
       wf_notification.CLOSE(l_nid,l_responder_name);
END IF;
     d_position := 4;

END IF;

d_position := 5;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end (d_module);
  END IF;


EXCEPTION

WHEN OTHERS THEN

  WF_CORE.context (d_pkg_name, d_api_name, d_position || ': SQL Error ' || sqlcode);
  RAISE;

END post_buyer_acceptance;


-- Bug 13356264
PROCEDURE Should_approval_be_launched (itemtype  IN VARCHAR2,
                                       itemkey   IN VARCHAR2,
                                       actid     IN NUMBER,
                                       funcmode  IN VARCHAR2,
                                       resultout OUT NOCOPY VARCHAR2)
IS

  d_api_name CONSTANT VARCHAR2(30) := 'should_approval_be_launched';
  d_module CONSTANT VARCHAR2(255) := po_log.Get_subprogram_base(d_pkg_name,
                                     d_api_name);
  d_position          NUMBER;

  l_launch_approval   VARCHAR2(10);
  l_any_line_accepted VARCHAR2(1);
  l_draft_id          po_drafts.draft_id%TYPE;
  l_po_header_id PO_HEADERS_ALL.po_header_id%TYPE;

BEGIN

  d_position := 0;

  IF ( po_log.d_proc ) THEN
    po_log.Proc_begin (d_module);
  END IF;

  l_draft_id := po_wf_util_pkg.Getitemattrnumber (itemtype => itemtype,
                                                  itemkey => itemkey,
                                                  aname => 'DRAFT_ID');

  l_po_header_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                    ( itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'PO_HEADER_ID'
                    );

  BEGIN

      SELECT 'Y'
      INTO   l_any_line_accepted
      FROM   dual
      WHERE  EXISTS (SELECT 1
                     FROM   po_lines_draft_all
                     WHERE  draft_id = l_draft_id
                            AND nvl(change_accepted_flag,'Y') = 'Y')
              OR EXISTS (SELECT 1
                         FROM   po_line_locations_draft_all
                         WHERE  draft_id = l_draft_id
                                AND nvl(change_accepted_flag,'Y') = 'Y')
              OR EXISTS (SELECT 1
                         FROM   po_price_diff_draft
                         WHERE  draft_id = l_draft_id
                                AND nvl(change_accepted_flag,'Y') = 'Y')
              OR EXISTS (SELECT 1
                         FROM   po_attribute_values_draft
                         WHERE  draft_id = l_draft_id
                                AND nvl(change_accepted_flag,'Y') = 'Y');

  EXCEPTION

      WHEN no_data_found THEN
        l_any_line_accepted := 'N';
  END;

  d_position := 20;

  IF ( po_log.d_stmt ) THEN
    po_log.Stmt (d_module, d_position, 'l_any_line_accepted', l_any_line_accepted);
  END IF;

  l_launch_approval := po_wf_util_pkg.Getitemattrtext (itemtype => itemtype,
                                                       itemkey => itemkey,
                                                       aname=> 'LAUNCH_APPROVAL');

  d_position := 30;

  IF ( po_log.d_stmt ) THEN
    po_log.Stmt (d_module, d_position, 'l_launch_approval', l_launch_approval);
  END IF;

  IF( l_any_line_accepted = 'Y' AND l_launch_approval = 'Y' ) THEN
    resultout := wf_engine.eng_completed || ':Y';
  ELSE
    PO_DRAFTS_PVT.unlock_document(l_po_header_id);
    resultout := wf_engine.eng_completed || ':N';
  END IF;

  IF ( po_log.d_proc ) THEN
    po_log.Proc_end (d_module);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
             wf_core.Context (d_pkg_name, d_api_name, d_position
                                                      || ': SQL Error '
                                                      || SQLCODE);

             RAISE;

END should_approval_be_launched;

END PO_DIFF_SUMMARY_PKG;

/
