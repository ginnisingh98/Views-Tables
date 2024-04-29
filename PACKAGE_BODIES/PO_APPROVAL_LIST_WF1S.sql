--------------------------------------------------------
--  DDL for Package Body PO_APPROVAL_LIST_WF1S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_APPROVAL_LIST_WF1S" AS
/* $Header: POXWAL1B.pls 120.3.12010000.3 2010/05/04 10:40:27 dashah ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

 /*=======================================================================+
 | FILENAME
 |   POXWAL1B.sql
 |
 | DESCRIPTION
 |   PL/SQL package:  PO_APPROVAL_LIST_WF1S
 |
 | NOTES
 |   Created 10/04/98 ecso
 *=====================================================================*/
-- Local procedure
-- set context for calls to doc manager
--
procedure set_doc_mgr_context(itemtype VARCHAR2, itemkey VARCHAR2);
PROCEDURE set_doc_mgr_err(itemtype VARCHAR2, itemkey VARCHAR2,
                          p_error_stack PO_APPROVALLIST_S1.ErrorStackType,
                          p_return_code Number);

procedure Is_Document_Manager_Error_1_2(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_error_number   NUMBER;

BEGIN

  IF (funcmode='RUN') THEN

   l_progress := 'Is_Document_Manager_Error_1_2: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   l_error_number:=
   wf_engine.GetItemAttrNumber (   itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'DOC_MGR_ERROR_NUM');

   l_progress := 'Is_Document_Manager_Error_1_2: 002 - '||
                  to_char(l_error_number);
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   IF (l_error_number = 1 or l_error_number = 2) THEN
     resultout:='COMPLETE:'||'Y';
     return;

   ELSE
     resultout:='COMPLETE:'||'N';
     return;

   END IF;

  END IF; --run mode

EXCEPTION
 WHEN OTHERS THEN
    WF_CORE.context('PO_APPROVAL_LIST_WF1S' , 'Is_Document_Manager_Error_1_2', itemtype, itemkey, l_progress);
    resultout:='COMPLETE:'||'N';

END Is_Document_Manager_Error_1_2;


-- Public procedures
--
-- Does_Approval_list_Exist
-- Check if there exists an approval list
-- for a requisition
--
procedure Does_Approval_List_Exist( itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_return_code               NUMBER;
  l_approval_list_header_id   NUMBER;

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN

  IF (funcmode='RUN') THEN

   l_progress := 'Does_Approval_List_Exist: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   l_approval_list_header_id:=
   wf_engine.GetItemAttrNumber (   itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'APPROVAL_LIST_HEADER_ID');

   l_progress := 'Does_Approval_List_Exist: 002 - '||
                  'l_approval_list_header_id: '||
                  to_char(l_approval_list_header_id);
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   IF l_approval_list_header_id IS NOT NULL THEN
     resultout:='COMPLETE:'||'Y';
     return;

   ELSE
     resultout:='COMPLETE:'||'N';
     return;

   END IF;

  END IF; --run mode

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_APPROVAL_LIST_WF1S' , 'Does_Approval_List_Exist', itemtype, itemkey, l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.DOES_APPROVAL_LIST_EXIST');
    RAISE;

END Does_Approval_List_Exist;

-- Find_Approval_List
-- 1. search for an approval list created by preparer
--    through web requisition
-- 2. if approval list is found,
--     record the approval list id on workflow attribute and
--     mark approval list with workflow itemtype, itemkey
--     by calling update_approval_list_itemkey API
--
procedure Find_Approval_List      ( itemtype        in varchar2,
                                    itemkey         in varchar2,
                                    actid           in number,
                                    funcmode        in varchar2,
                                    resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_approval_list_header_id   NUMBER;
  E_FAILURE                   EXCEPTION;

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN

  IF (funcmode='RUN') THEN
   -- Context Setting revamp
   --set_doc_mgr_context(itemtype, itemkey);

   l_progress := 'Find_Approval_List: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

   l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

   l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

   -- Set the multi-org context

   l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'ORG_ID');

   IF l_org_id is NOT NULL THEN

     PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

   END IF;

   l_progress := 'Find_Approval_List: 002-'||to_char(l_document_id)||'-'||
                         l_document_type||'-'||l_document_subtype;
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   /* Pass null for itemtype and itemkey to find
   ** new approval list.
   */
   PO_APPROVALLIST_S1.does_approval_list_exist(
                        p_document_id=>l_document_id,
                        p_document_type=>l_document_type,
                        p_document_subtype=>l_document_subtype,
                        p_itemtype=>NULL,
                        p_itemkey=>NULL,
                        p_return_code=>l_return_code,
                        p_approval_list_header_id=>l_approval_list_header_id);

   l_progress := 'Find_Approval_List: 003- does_approval_list_exist - '||
                         to_char(l_return_code)||
                         ', l_approval_list_header_id: '||
                         to_char(l_approval_list_header_id);
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   IF l_return_code = PO_APPROVALLIST_S1.E_SUCCESS THEN
       wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                     itemkey    => itemkey,
                                     aname      => 'APPROVAL_LIST_HEADER_ID',
                                     avalue     => l_approval_list_header_id);

        l_progress := 'Find_Approval_List: 004';
        IF (g_po_wf_debug = 'Y') THEN
           /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
        END IF;

        PO_APPROVALLIST_S1.update_approval_list_itemkey(
                         p_approval_list_header_id=>l_approval_list_header_id,
                         p_itemtype=>itemtype,
                         p_itemkey=>itemkey,
                         p_return_code=>l_return_code);

        l_progress := 'Find_Approval_List: 005- update_approval_list_itemkey - '||
                       to_char(l_return_code);
        IF (g_po_wf_debug = 'Y') THEN
           /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
        END IF;

        IF l_return_code = PO_APPROVALLIST_S1.E_SUCCESS THEN

          resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
          return;
        END IF;

   END IF;

   RAISE E_FAILURE;


  END IF; -- run mode

EXCEPTION

 WHEN E_FAILURE THEN
   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
   wf_core.context('PO_APPROVAL_LIST_WF1S',
                   'Find_Approval_list E_FAILURE',
                   l_progress,l_return_code,sqlerrm);
--   wf_core.raise('Find_Approval_list E_FAILURE' || l_progress||sqlerrm);
   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.FIND_APPROVAL_LIST');

   RAISE;

 WHEN OTHERS THEN
   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
   wf_core.context('PO_APPROVAL_LIST_WF1S',
                   'Find_Approval_list',l_progress,l_return_code,sqlerrm);

   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.FIND_APPROVAL_LIST');

   RAISE;


END Find_Approval_List;

-- Build_Default_Approval_List
-- Build default approval list
--
procedure Build_Default_Approval_list(itemtype        in varchar2,
                                      itemkey         in varchar2,
                                      actid           in number,
                                      funcmode        in varchar2,
                                      resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(300) := '000';
  l_preparer_id               NUMBER;
  l_first_approver_id         NUMBER;
  l_approval_path_id          NUMBER;
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25);
  l_document_subtype          VARCHAR2(25);
  l_employee_id               NUMBER;
  l_return_code               NUMBER;
  l_error_stack               PO_APPROVALLIST_S1.ErrorStackType;
  l_approval_list             PO_APPROVALLIST_S1.ApprovalListType;
  l_approval_list_header_id   NUMBER:=null;
  E_APPROVAL_LIST_BUILD_FAIL  EXCEPTION;
  E_APPROVAL_LIST_SAVE_FAIL   EXCEPTION;

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;
  doc_manager_exception exception;

  l_approver_id               NUMBER := null;

BEGIN

   IF (funcmode='RUN') THEN

     l_progress := 'Build_Default_Approval_list: 001';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

     l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_progress := 'Build_Default_Approval_list: 002-'||
                           to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     l_preparer_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PREPARER_ID');

     l_approval_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVAL_PATH_ID');

     l_first_approver_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');

     --Bug 3246530. The approval Authority should be verified for Approver not Preparer.
     l_approver_id := po_wf_util_pkg.GetItemAttrNumber ( ItemType => itemtype,
                                                    ItemKey  => itemkey,
                                                    aname    => 'APPROVER_EMPID');
     -- Set the multi-org context

     l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ORG_ID');

     IF l_org_id is NOT NULL THEN

       PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

     END IF;

     l_progress := 'Build_Default_Approval_list: 003-'||
                           to_char(l_document_id)||'-'||
                           to_char(l_preparer_id)||'-'||
                           to_char(l_approval_path_id)||'-'||
                           to_char(l_first_approver_id);
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     PO_APPROVALLIST_S1.get_default_approval_list(
                                    p_first_approver_id=>l_first_approver_id,
                                    p_approval_path_id=>l_approval_path_id,
                                    p_document_id=>l_document_id,
                                    p_document_type=>l_document_type,
                                    p_document_subtype=>l_document_subtype,
                                    p_return_code=>l_return_code,
                                    p_error_stack=>l_error_stack,
                                    p_approval_list=>l_approval_list,
                                    p_approver_id=>l_approver_id); -- Bug 3246530

     l_progress := 'Build_Default_Approval_list: 004-get_default_approval_list-'||
                        to_char(l_return_code);
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     IF l_return_code = PO_APPROVALLIST_S1.E_SUCCESS THEN

        l_progress := 'Build_Default_Approval_list: 006-print_approval_list';
         IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
         END IF;

        PO_APPROVALLIST_S1.print_approval_list(l_approval_list);
        PO_APPROVALLIST_S1.save_approval_list(p_document_id=>l_document_id,
                           p_document_type=>l_document_type,
                           p_document_subtype=>l_document_subtype,
                           p_approval_list_header_id=>l_approval_list_header_id,
                           p_first_approver_id=>l_first_approver_id,
                           p_approval_path_id=>l_approval_path_id,
                           p_approval_list=>l_approval_list,
                           p_last_update_date=>null,
                           p_return_code=>l_return_code,
                           p_error_stack=>l_error_stack);

        l_progress := 'Build_Default_Approval_list: 008-save_approval_list-'||
                       to_char(l_return_code);
        IF (g_po_wf_debug = 'Y') THEN
           /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
        END IF;

        IF l_return_code = PO_APPROVALLIST_S1.E_SUCCESS THEN

          l_progress := 'Build_Default_Approval_list: 009-'||
                         'l_approval_list_header_id: '||
                         to_char(l_approval_list_header_id);
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
          END IF;

          PO_APPROVALLIST_S1.update_approval_list_itemkey(
                          p_approval_list_header_id=>l_approval_list_header_id,
                          p_itemtype=>itemtype,
                          p_itemkey=>itemkey,
                          p_return_code=>l_return_code);

          l_progress := 'Build_Default_Approval_list: 010 '||
                         '- update_approval_list_itemkey-'||
                         to_char(l_return_code);
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
          END IF;

          IF l_return_code = PO_APPROVALLIST_S1.E_SUCCESS THEN
            wf_engine.SetItemAttrNumber(itemtype   => itemType,
                                      itemkey    => itemkey,
                                      aname      => 'APPROVAL_LIST_HEADER_ID',
                                      avalue     => l_approval_list_header_id);
          ELSE
            raise E_APPROVAL_LIST_SAVE_FAIL;
          END IF;
        ELSE
          raise E_APPROVAL_LIST_SAVE_FAIL;
        END IF;

      l_progress := 'Build_Default_Approval_list: 015';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

    ELSE

     l_progress := 'Build_Default_Approval_list: 020 ' ||to_char(l_return_code);
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;


     IF l_return_code in
        (PO_APPROVALLIST_S1.E_NO_SUPERVISOR_FOUND,
         PO_APPROVALLIST_S1.E_NO_ONE_HAS_AUTHORITY) THEN

         l_progress := 'Build_Default_Approval_list: 021'||
                       '- E_NO_SUPERVISOR_FOUND OR E_NO_ONE_HAS_AUTHORITY';
         IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
         END IF;

         resultout:='COMPLETE:'||'FAILURE';
         return;

/* Bug# 2378775 */

     ELSIF l_return_code in (PO_APPROVALLIST_S1.E_DOC_MGR_TIMEOUT,
                             PO_APPROVALLIST_S1.E_DOC_MGR_NOMGR,
                             PO_APPROVALLIST_S1.E_DOC_MGR_OTHER) THEN

          set_doc_mgr_err(itemtype, itemkey, l_error_stack, l_return_code);
          raise doc_manager_exception;

     ELSE
       l_progress := 'Build_Default_Approval_list: 022-E_APPROVAL_LIST_BUILD_FAIL';
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
       END IF;

         raise E_APPROVAL_LIST_BUILD_FAIL;
     END IF;

    END IF;

    l_progress := 'Build_Default_Approval_list: 030 - Build_Default_Approval_list'||
                  ' - SUCCESS';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    resultout:='COMPLETE:'||'SUCCESS';
    return;

   END IF; -- run mode

EXCEPTION
 WHEN doc_manager_exception THEN
        raise;

 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_APPROVAL_LIST_WF1S' , 'Build_Default_Approval_list', itemtype, itemkey, l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.Build_Default_Approval_list');
    RAISE;

END Build_Default_Approval_list;

-- Rebuild_Approval_List
-- An approval list will be rebuilt under the following scenario:
-- (1) Approver forwards the requisition
-- (2) Approver modifies the requisition
-- (3) The current approver is not valid
--
procedure Rebuild_List_Forward(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(300) := '000';
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_rebuild_code              VARCHAR2(25):='FORWARD_RESPONSE';
  l_error_stack               PO_APPROVALLIST_S1.ErrorStackType;
  l_approval_list_header_id   NUMBER;

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;
  doc_manager_exception exception;

BEGIN

   IF (funcmode = 'RUN') THEN

    l_progress := 'Rebuild_List_Forward: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

    -- Set the multi-org context

    l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'ORG_ID');

    IF l_org_id is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

    END IF;

    l_progress := 'Rebuild_List_Forward: 002-'||to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    PO_APPROVALLIST_S1.rebuild_approval_list(
                            p_document_id=>l_document_id,
                            p_document_type=>l_document_type,
                            p_document_subtype=>l_document_subtype,
                            p_rebuild_code=>l_rebuild_code,
                            p_return_code=>l_return_code,
                            p_error_stack=>l_error_stack,
                            p_approval_list_header_id=>l_approval_list_header_id);

    l_progress := 'Rebuild_List_Forward: 003- rebuild_approval_list - '||
                 l_rebuild_code||'-'||to_char(l_return_code);
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;


    IF l_return_code=PO_APPROVALLIST_S1.E_SUCCESS THEN
       wf_engine.SetItemAttrNumber (   itemtype   => itemType,
                                     itemkey    => itemkey,
                                     aname      => 'APPROVAL_LIST_HEADER_ID',
                                     avalue     => l_approval_list_header_id);


     resultout:='COMPLETE:'||'SUCCESS';
     return;

/* Bug# 2378775 */

    ELSIF l_return_code in (PO_APPROVALLIST_S1.E_DOC_MGR_TIMEOUT,
                            PO_APPROVALLIST_S1.E_DOC_MGR_NOMGR,
                            PO_APPROVALLIST_S1.E_DOC_MGR_OTHER) THEN

         set_doc_mgr_err(itemtype, itemkey, l_error_stack, l_return_code);
         raise doc_manager_exception;
    ELSE
     resultout:='COMPLETE:'||'FAILURE';
     return;

    END IF;

   END IF; -- run mode


EXCEPTION
 WHEN doc_manager_exception THEN
        raise;

 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Rebuild_List_Forward',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.REBUILD_LIST_FORWARD');
    RAISE;

END Rebuild_List_Forward;

--
procedure Rebuild_List_Doc_Changed(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2)IS
  l_progress                  VARCHAR2(300) := '000';
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_rebuild_code              VARCHAR2(25):='DOCUMENT_CHANGED';
  l_error_stack               PO_APPROVALLIST_S1.ErrorStackType;
  l_approval_list_header_id   NUMBER:='';

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;
  doc_manager_exception exception;

BEGIN

   IF (funcmode = 'RUN') THEN

     l_progress := 'Rebuild_List_Doc_Changed: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

    -- Set the multi-org context

    l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'ORG_ID');

    IF l_org_id is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

    END IF;

    l_progress := 'Rebuild_List_Doc_Changed: 002-'||to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    PO_APPROVALLIST_S1.rebuild_approval_list(
                            p_document_id=>l_document_id,
                            p_document_type=>l_document_type,
                            p_document_subtype=>l_document_subtype,
                            p_rebuild_code=>l_rebuild_code,
                            p_return_code=>l_return_code,
                            p_error_stack=>l_error_stack,
                            p_approval_list_header_id=>l_approval_list_header_id);

    l_progress := 'Rebuild_List_Doc_Changed: 003- rebuild_approval_list - '
                 ||l_rebuild_code||'-'||to_char(l_return_code);
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF l_return_code=PO_APPROVALLIST_S1.E_SUCCESS THEN
       wf_engine.SetItemAttrNumber (   itemtype   => itemType,
                                     itemkey    => itemkey,
                                     aname      => 'APPROVAL_LIST_HEADER_ID',
                                     avalue     => l_approval_list_header_id);

     resultout:='COMPLETE:'||'SUCCESS';
     return;

/* Bug# 2378775 */

    ELSIF l_return_code in (PO_APPROVALLIST_S1.E_DOC_MGR_TIMEOUT,
                             PO_APPROVALLIST_S1.E_DOC_MGR_NOMGR,
                             PO_APPROVALLIST_S1.E_DOC_MGR_OTHER) THEN

          set_doc_mgr_err(itemtype, itemkey, l_error_stack, l_return_code);
          raise doc_manager_exception;

    ELSE
     resultout:='COMPLETE:'||'FAILURE';
     return;

    END IF;

   END IF; -- run mode


EXCEPTION
 WHEN doc_manager_exception THEN
        raise;

 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Rebuild_List_Doc_Changed',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.REBUILD_LIST_DOC_CHANGED');
    RAISE;

END Rebuild_List_Doc_Changed;

--
procedure Rebuild_List_Invalid_Approver(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(300) := '000';
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_rebuild_code              VARCHAR2(25):='INVALID_APPROVER';
  l_approval_list_header_id   NUMBER:='';
  l_error_stack               PO_APPROVALLIST_S1.ErrorStackType;

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

  doc_manager_exception exception;

BEGIN

   IF (funcmode = 'RUN') THEN

    l_progress := 'Rebuild_List_Invalid_Approver: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

    -- Set the multi-org context

    l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'ORG_ID');

    IF l_org_id is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

    END IF;

    l_progress := 'Rebuild_List_Invalid_Approver: 002-'||
                           to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    PO_APPROVALLIST_S1.rebuild_approval_list(
                            p_document_id=>l_document_id,
                            p_document_type=>l_document_type,
                            p_document_subtype=>l_document_subtype,
                            p_rebuild_code=>l_rebuild_code,
                            p_return_code=>l_return_code,
                            p_error_stack=>l_error_stack,
                            p_approval_list_header_id=>l_approval_list_header_id);

    l_progress := 'Rebuild_List_Invalid_Approver: 003- rebuild_approval_list - '
                 ||l_rebuild_code||'-'||to_char(l_return_code);
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF l_return_code=PO_APPROVALLIST_S1.E_SUCCESS THEN
       wf_engine.SetItemAttrNumber (   itemtype   => itemType,
                                     itemkey    => itemkey,
                                     aname      => 'APPROVAL_LIST_HEADER_ID',
                                     avalue     => l_approval_list_header_id);

     resultout:='COMPLETE:'||'SUCCESS';
     return;

/* Bug# 2378775 */

    ELSIF l_return_code in (PO_APPROVALLIST_S1.E_DOC_MGR_TIMEOUT,
                            PO_APPROVALLIST_S1.E_DOC_MGR_NOMGR,
                            PO_APPROVALLIST_S1.E_DOC_MGR_OTHER) THEN

         set_doc_mgr_err(itemtype, itemkey, l_error_stack, l_return_code);
         raise doc_manager_exception;

    ELSE
     resultout:='COMPLETE:'||'FAILURE';
     return;

    END IF;

   END IF; -- run mode

EXCEPTION
 WHEN doc_manager_exception THEN
        raise;

 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Rebuild_List_Invalid_Approver',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.REBUILD_LIST_INVALID_APPROVER');
    RAISE;

END Rebuild_List_Invalid_Approver;

--
-- Get_Next_Approver
-- get the next approver name from the approval list
-- and update workflow attributes.
--
procedure Get_Next_Approver(itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       out NOCOPY varchar2) IS
  l_progress                  VARCHAR2(100) := '000';
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_next_approver_id          NUMBER;
  l_next_approver_user_name   VARCHAR2(100);
  l_next_approver_disp_name   VARCHAR2(240);
  l_orig_system               VARCHAR2(48):='PER';
  l_sequence_num              NUMBER;
  l_approver_type             VARCHAR2(30);
  E_FAILURE                   EXCEPTION;

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN
   IF (funcmode = 'RUN') THEN

   l_progress := 'Get_Next_Approver: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

   l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

   l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

   -- Set the multi-org context

   l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'ORG_ID');

   IF l_org_id is NOT NULL THEN

     PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

   END IF;

   l_progress := 'Get_Next_Approver: 002-'||to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   PO_APPROVALLIST_S1.get_next_approver(l_document_id,
                            l_document_type,
                            l_document_subtype,
                            l_return_code,
                            l_next_approver_id,
                            l_sequence_num,
                            l_approver_type);

   l_progress := 'Get_Next_Approver: 003- get_next_approver - '||
                       to_char(l_next_approver_id)||'-'||
                       to_char(l_return_code);
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;


   IF l_return_code = PO_APPROVALLIST_S1.E_SUCCESS THEN


     wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'APPROVER_EMPID',
                                   avalue     => l_next_approver_id);

     wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'FORWARD_TO_ID',
                                   avalue     => l_next_approver_id);

     l_orig_system:= 'PER';

     WF_DIRECTORY.GetUserName(l_orig_system,
                            l_next_approver_id,
                            l_next_approver_user_name,
                            l_next_approver_disp_name);

     l_progress := 'Get_Next_Approver: 004- GetUserName - '||
                    l_next_approver_user_name;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => l_next_approver_user_name);

     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_DISPLAY_NAME' ,
                              avalue     => l_next_approver_disp_name);

     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_USERNAME' ,
                              avalue     => l_next_approver_user_name);

     wf_engine.SetItemAttrText( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_DISPLAY_NAME' ,
                              avalue     => l_next_approver_disp_name);

     resultout:='COMPLETE:'||'VALID_APPROVER';
     return;
  ELSIF l_return_code = PO_APPROVALLIST_S1.E_NO_NEXT_APPROVER_FOUND THEN
     resultout:='COMPLETE:'||'NO_NEXT_APPROVER';
     return;
  ELSIF l_return_code = PO_APPROVALLIST_S1.E_INVALID_APPROVER THEN
     resultout:='COMPLETE:'||'INVALID_APPROVER';
     return;
  ELSE
     RAISE E_FAILURE;
  END IF;
 END IF;
EXCEPTION
 WHEN E_FAILURE THEN
   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
   wf_core.context('PO_APPROVAL_LIST_WF1S',
                   'Get_Next_Approver E_FAILURE',
                   l_progress,l_return_code,sqlerrm);
--   wf_core.raise('Get_Next_Approver E_FAILURE' || l_progress||sqlerrm);

   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.GET_NEXT_APPROVER');

   RAISE;
 WHEN OTHERS THEN
   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
   wf_core.context('PO_APPROVAL_LIST_WF1S','Get_Next_Approver',l_progress,sqlerrm);

   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.GET_NEXT_APPROVER');

   RAISE;

END Get_Next_Approver;


-- Is_Approval_List_Empty
-- at the end of the approval list
-- i.e. list exhausted.
procedure Is_Approval_List_Empty(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_result                    BOOLEAN:=FALSE;
  E_FAILURE                   EXCEPTION;

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN
   l_progress := 'Is_Approval_List_Empty: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   IF (funcmode='RUN') THEN


    l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

    l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

    -- Set the multi-org context

    l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'ORG_ID');

    IF l_org_id is NOT NULL THEN

      PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

    END IF;

    l_progress := 'Is_Approval_List_Empty: 002-'||to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;


    PO_APPROVALLIST_S1.is_approval_list_exhausted(p_document_id=>l_document_id,
                                     p_document_type=>l_document_type,
                                     p_document_subtype=>l_document_subtype,
                                     p_itemtype=>itemtype,
                                     p_itemkey=>itemkey,
                                     p_return_code=>l_return_code,
                                     p_result=> l_result);

   l_progress := 'Is_Approval_List_Empty: 005- is_approval_list_exhausted -'||
                    to_char(l_return_code);
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

   IF l_return_code = PO_APPROVALLIST_S1.E_SUCCESS THEN
    IF l_result THEN

     resultout:='COMPLETE:'||'Y';
     return;
    ELSE
     resultout:='COMPLETE:'||'N';
     return;

    END IF;

   ELSE

    RAISE E_FAILURE;

   END IF; -- return_code success

   END IF; -- run mode

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Is_Approver_List_Empty',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.IS_APPROVAL_LIST_EMPTY');
    RAISE;

END Is_Approval_List_Empty;


procedure Insert_Action_History(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_action                    VARCHAR2(30)  := 'APPROVE';
  l_next_approver_id             NUMBER:='';
  l_approval_path_id             NUMBER:='';
  l_req_header_id                NUMBER:='';

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN

    l_progress := 'Insert_Action_History: 001';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

    IF (funcmode='RUN') THEN

      l_next_approver_id := wf_engine.GetItemAttrNumber(itemtype=>itemtype,
                                                 itemkey=>itemkey,
                                                 aname=>'APPROVER_EMPID');

      l_approval_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVAL_PATH_ID');

      l_req_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

      -- Set the multi-org context

      l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'ORG_ID');

      IF l_org_id is NOT NULL THEN

	PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

      END IF;

       /* update po action history */
      PO_APPROVAL_LIST_HISTORY_SV.Forward_Action_History(itemtype=>itemtype,
                                             itemkey=>itemkey,
                                             x_forward_to_id=>l_next_approver_id,
					     x_req_header_id=>l_req_header_id,
                                             x_approval_path_id=>l_approval_path_id);

      l_progress := 'Insert_Action_History: 005 - Forward_Action_History';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

    /* Reset the FORWARD_TO_USERNAME_RESPONSE attribute */
    wf_engine.SetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_USERNAME_RESPONSE',
                                         avalue   => NULL);

    /* Reset the NOTE attribute */
    wf_engine.SetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE',
                                         avalue   => NULL);

      resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
      return;

    END IF; -- run mode

    l_progress := 'Insert_Action_History: 999';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Insert_Action_History',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.INSERT_ACTION_HISTORY');
    RAISE;

END Insert_Action_History;

procedure Update_Action_History_Approve(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_action                    VARCHAR2(30)  := 'APPROVE';
  l_forward_to_id             NUMBER:='';
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_result                    BOOLEAN:=FALSE;
  l_note                      VARCHAR2(4000);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN

    l_progress := 'Update_Action_History_Approve: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF (funcmode='RUN') THEN

     l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

     l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_note := wf_engine.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

     -- Set the multi-org context

     l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ORG_ID');

     IF l_org_id is NOT NULL THEN

       PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

     END IF;

     l_progress := 'Update_Action_History_Approve: 002-'||
                           to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     /* update po action history */
     PO_APPROVAL_LIST_HISTORY_SV.Update_Action_History(itemtype=>itemtype,
                                         itemkey=>itemkey,
                                         x_action=>l_action,
                                         x_req_header_id=>l_document_id,
                                         x_last_approver=>l_result,
                                         x_note=>l_note);

     l_progress := 'Update_Action_History_Approve: 005 - Update_Action_History';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     /* need to release locks for doc mgr */
     -- commit;

     l_progress := 'Update_Action_History_Approve: 006';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
     return;

    END IF; -- run mode

    l_progress := 'Update_Action_History_Approve: 999';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;


EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Update_Action_History_Approve',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.UPDATE_ACTION_HISTORY_APPROVE');
    RAISE;

END Update_Action_History_Approve;


procedure Update_Action_History_Timeout(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_action                    VARCHAR2(30)  := 'NO ACTION';
  l_forward_to_id             NUMBER:='';
  l_document_id               NUMBER:='';
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_result                    BOOLEAN:=FALSE;
  l_note                      VARCHAR2(4000);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN
    l_progress := 'Update_Action_History_Timeout: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF (funcmode='RUN') THEN

     l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

     l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_note := fnd_message.get_string('ICX', 'ICX_POR_NOTIF_TIMEOUT');

     -- Set the multi-org context

     l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ORG_ID');

     IF l_org_id is NOT NULL THEN
       PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>
     END IF;

     l_progress := 'Update_Action_History_Timeout: 002-'||
                           to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;

     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     /* update po action history */
     PO_APPROVAL_LIST_HISTORY_SV.Update_Action_History(itemtype=>itemtype,
                                         itemkey=>itemkey,
                                         x_action=>l_action,
                                         x_req_header_id=>l_document_id,
                                         x_last_approver=>l_result,
                                         x_note=>l_note);

     l_progress := 'Update_Action_History_Timeout: 003- Update_Action_History';

     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     l_progress := 'Update_Action_History_App_Fwd: 004';

     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
     return;

    END IF; -- run mode

    l_progress := 'Update_Action_History_Timeout: 999';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Update_Action_History_Timeout',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.UPDATE_ACTION_HISTORY_TIMEOUT');
    RAISE;

END Update_Action_History_Timeout;


procedure Update_Action_History_App_Fwd(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_action                    VARCHAR2(30)  := 'APPROVE_AND_FORWARD';
  l_forward_to_id             NUMBER:='';
  l_document_id               NUMBER:='';
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_result                    BOOLEAN:=FALSE;
  l_note                      VARCHAR2(4000);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN
    l_progress := 'Update_Action_History_App_Fwd: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF (funcmode='RUN') THEN

     l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

     l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_note := wf_engine.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

     -- Set the multi-org context

     l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ORG_ID');

     IF l_org_id is NOT NULL THEN

       PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

     END IF;

     l_progress := 'Update_Action_History_App_Fwd: 002-'||
                           to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     /* update po action history */
     PO_APPROVAL_LIST_HISTORY_SV.Update_Action_History(itemtype=>itemtype,
                                         itemkey=>itemkey,
                                         x_action=>l_action,
                                         x_req_header_id=>l_document_id,
                                         x_last_approver=>l_result,
                                        x_note=>l_note);

     l_progress := 'Update_Action_History_App_Fwd: 005- Update_Action_History';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     /* need to release locks for doc mgr */
     -- commit;

     l_progress := 'Update_Action_History_App_Fwd: 006';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
     return;

    END IF; -- run mode

    l_progress := 'Update_Action_History_App_Fwd: 999';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Update_Action_History_App_Fwd',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.UPDATE_ACTION_HISTORY_APP_FWD');
    RAISE;

END Update_Action_History_App_Fwd;

procedure Update_Action_History_Forward(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_action                    VARCHAR2(30)  := 'FORWARD';
  l_forward_to_id             NUMBER:='';
  l_document_id               NUMBER:='';
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_result                    BOOLEAN:=FALSE;
  l_note                      VARCHAR2(4000);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN
    l_progress := 'Update_Action_History_Forward: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF (funcmode='RUN') THEN

     l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

     l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_note := wf_engine.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

     -- Set the multi-org context

     l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ORG_ID');

     IF l_org_id is NOT NULL THEN

       PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

     END IF;

     l_progress := 'Update_Action_History_Forward: 002-'||
                           to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     /* update po action history */
     PO_APPROVAL_LIST_HISTORY_SV.Update_Action_History(itemtype=>itemtype,
                                         itemkey=>itemkey,
                                         x_action=>l_action,
                                         x_req_header_id=>l_document_id,
                                         x_last_approver=>l_result,
                                         x_note=>l_note);

     l_progress := 'Update_Action_History_Forward: 005- Update_Action_History';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     /* need to release locks for doc mgr */
     -- commit;

     l_progress := 'Update_Action_History_Forward: 006';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
     return;

    END IF; -- run mode
    l_progress := 'Update_Action_History_Forward: 999';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Update_Action_History_Forward',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.UPDATE_ACTION_HISTORY_FORWARD');
    RAISE;

END Update_Action_History_Forward;

procedure Update_Action_History_Reject(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_action                    VARCHAR2(30)  := 'REJECT';
  l_forward_to_id             NUMBER:='';
  l_document_id                NUMBER:='';
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_result                    BOOLEAN:=FALSE;
  l_note                      VARCHAR2(4000);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;

BEGIN
    l_progress := 'Update_Action_History_Reject: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    IF (funcmode='RUN') THEN

     l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

     l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

     l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

     l_note := wf_engine.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

     -- Set the multi-org context

     l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ORG_ID');

     IF l_org_id is NOT NULL THEN

       PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

     END IF;

     l_progress := 'Update_Action_History_Reject: 002-'||
                           to_char(l_document_id)||'-'||
                           l_document_type||'-'||l_document_subtype;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     /* update po action history */
     PO_APPROVAL_LIST_HISTORY_SV.Update_Action_History(itemtype=>itemtype,
                                         itemkey=>itemkey,
                                         x_action=>l_action,
                                         x_req_header_id=>l_document_id,
                                         x_last_approver=>l_result,
                                         x_note=>l_note);

     l_progress := 'Update_Action_History_Reject: 005 - Update_Action_History';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     /* need to release locks for doc mgr */
     -- commit;

     l_progress := 'Update_Action_History_Reject: 006';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     END IF;

     resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
     return;

    END IF; -- run mode
    l_progress := 'Update_Action_History_Reject: 999';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Update_Action_History_Reject',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.UPDATE_ACTION_HISTORY_REJECT');
    RAISE;

END Update_Action_History_Reject;

/* Bug# 1712121: kagarwal
** Desc: We now use the new API: Update_App_List_Resp_Success.
**
** Also reverted the change of bug# 1394711 in the old API
** 'Update_Approval_List_Response'. It will now return 'ACTIVITY_PERFORMED'
** as before the fix in bug# 1394711.
**
** This is to support reqs submitted for approval before applying this bug
** fix otherwise their approval will error out due to change in return value.
**
** For reqs submitted for approval after bug# 1394711 and before this new
** fix, modified the API 'Update_Approval_List_Response' to check for the
** expected result type for that req approval process and return
** 'SUCCESS-FAILURE' instead of 'ACTIVITY_PERFORMED' if the expected result
** lookup type is 'PO_SUCCESS_FAILURE'.
*/

procedure Update_Approval_List_Response(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  CURSOR c_group_id (p_itemtype VARCHAR2, p_itemkey VARCHAR2, p_activity_name VARCHAR2) IS
    SELECT notification_id
    FROM   wf_item_activity_statuses_v
    WHERE  item_type = p_itemtype
    AND    item_key = p_itemkey
    AND    activity_name = p_activity_name
    ORDER BY activity_end_date DESC;

-- bug 1263201
-- We need to get the responder information from the first
-- valid (not timeout/canceled) notification to show the error
-- notification properly.
-- The sequence of notification be checked is
-- PO_REQ_APPROVE, PO_REQ_REMINDER2 then PO_REQ_REMINDER1.

  CURSOR c_canceled_notif (notif_id number) IS
    SELECT '1'
     FROM   WF_NOTIFICATIONS
    WHERE   notification_id = notif_id
      AND   status = 'CANCELED';

  CURSOR c_response(p_group_id number) IS
    SELECT recipient_role, attribute_value
    FROM   wf_notification_attr_resp_v
    WHERE  group_id = p_group_id
    AND    attribute_name = 'RESULT';

  CURSOR c_response_note(p_group_id number) IS
    SELECT attribute_value
    FROM   wf_notification_attr_resp_v
    WHERE  group_id = p_group_id
    AND    attribute_name = 'NOTE';

  /* Bug 1578061: remove the join to wf_notifications.  This forces the
     removal of end_date column

  CURSOR c_responder(p_notification_id number) IS
    SELECT nvl((wfu.orig_system_id), -9996)
    FROM   wf_users wfu
    WHERE  wfu.name = wf_notification.responder(p_notification_id)
    AND    wfu.orig_system not in ('POS', 'ENG_LIST', 'CUST_CONT');
   */

  /* bug 1817306 new cursor c_responderid is defined to replace c_responder */
  CURSOR c_responderid(p_responder VARCHAR2) IS
    SELECT nvl((wfu.orig_system_id), -9996)
    FROM   wf_users wfu
    WHERE  wfu.name = p_responder
    AND    wfu.orig_system not in ('HZ_PARTY', 'POS', 'ENG_LIST', 'CUST_CONT');

  l_progress                  VARCHAR2(100) := '000';
  l_group_id                  NUMBER;
  l_role                      VARCHAR2(30);
  l_value                     VARCHAR2(2000);
  l_approver_id               NUMBER := NULL;
  l_responder_id              NUMBER := NULL;
  l_forward_to_id             NUMBER := NULL;
  l_document_id               NUMBER;
  l_document_type             VARCHAR2(25):='';
  l_document_subtype          VARCHAR2(25):='';
  l_return_code               NUMBER;
  l_orgid                     NUMBER;
  l_approval_list_header_id   NUMBER:='';
  l_error_stack               PO_APPROVALLIST_S1.ErrorStackType;
  E_UPDATE_RESPONSE_FAIL      EXCEPTION;
  l_end_date                  DATE; -- notification end date
  l_note                      VARCHAR2(4000);
  l_orig_system               VARCHAR2(48);
  l_responder_user_name       VARCHAR2(100);
  l_responder_disp_name       VARCHAR2(240);
  l_responder                 VARCHAR2(240);
  l_recipient_role            VARCHAR2(30);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;
  is_notif_canceled    VARCHAR2(2);

  /* Bug# 1712121 */
  retnew	BOOLEAN := FALSE;
  exp_result    VARCHAR2(30);


BEGIN

  l_progress := 'Update_Approval_List_Response: 001- at beginning of function';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

/* Bug# 1431401: kagarwal
** Desc: We need to set the doc manager context as the response may
** be coming from the E-mail Notifications otherwise the call to
** doc manager would fail.
*/

  IF (funcmode='RUN') THEN
    -- Context Setting revamp
    -- set_doc_mgr_context(itemtype, itemkey);

/* Bug# 1712121: kagarwal
** Desc: For reqs submitted for approval after bug# 1394711 and before this new
** fix, modified the API 'Update_Approval_List_Response' to check for the
** expected result type for that req approval process and return
** 'SUCCESS-FAILURE' instead of 'ACTIVITY_PERFORMED' if the expected result
** lookup type is 'PO_SUCCESS_FAILURE'.
**
** We can achieve this by running the following sql which returns
** the expected result type.
*/

    Begin
        select wa.result_type
        into exp_result
	from wf_activities wa,
	     wf_process_activities wpa,
	     wf_items wi
	where wpa.instance_id = actid
	and wpa.process_item_type = wa.item_type
	and wpa.activity_name = wa.name
	and wi.item_type = wpa.process_item_type
	and wi.item_key =  itemkey
	and wi.begin_date > wa.begin_date
	and wi.begin_date <= nvl(wa.end_date,wi.begin_date);

    exception
        when others then
           null;
    end;

    l_progress := 'Update_Approval_List_Response : 001-2'||
                  'exp_result: ' || exp_result || ' actid: ' || to_char(actid);
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

   if exp_result = 'PO_SUCCESS_FAILURE' then
      retnew := TRUE;
   end if;

   l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');


  IF l_orgid is NOT NULL THEN

    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

   END IF;

   l_progress := 'Update_Approval_List_Response: 002';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   OPEN c_group_id(itemtype, itemkey, 'PO_REQ_APPROVE');
   FETCH c_group_id INTO l_group_id;
   CLOSE c_group_id;

   l_progress := 'Update_Approval_List_Response: 003';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   /* start of fix for 1263201 */
  OPEN c_canceled_notif (l_group_id);
   FETCH c_canceled_notif into is_notif_canceled;

   -- check if PO_REQ_APPROVE notification is canceled
   IF c_canceled_notif%FOUND  THEN

       CLOSE c_canceled_notif;

      l_progress := 'Update_Approval_List_Response: 0031';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

     l_group_id := NULL;

     OPEN c_group_id(itemtype, itemkey, 'PO_REQ_REMINDER2');
     FETCH c_group_id INTO l_group_id;
     CLOSE c_group_id;

     l_progress := 'Update_Approval_List_Response: 0032';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

     OPEN c_canceled_notif (l_group_id);
     FETCH c_canceled_notif into is_notif_canceled;

     -- check if PO_REQ_REMINDER2 notification is canceled
       IF c_canceled_notif%FOUND THEN

       CLOSE c_canceled_notif;

        l_progress := 'Update_Approval_List_Response: 0033';
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
       END IF;

       l_group_id := NULL;

       OPEN c_group_id(itemtype, itemkey, 'PO_REQ_REMINDER1');
       FETCH c_group_id INTO l_group_id;
       CLOSE c_group_id;

       l_progress := 'Update_Approval_List_Response: 0034';
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
       END IF;

       OPEN c_canceled_notif (l_group_id);
       FETCH c_canceled_notif into is_notif_canceled;

       l_progress := 'Update_Approval_List_Response: 00341';
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
       END IF;

       -- check if PO_REQ_REMINDER1 notification is canceled

       IF c_canceled_notif%FOUND THEN

         CLOSE c_canceled_notif;
         l_progress := 'Update_Approval_List_Response: 00342';
         l_group_id := NULL;

       ELSE  -- PO_REQ_REMINDER1 notification is not canceled

         CLOSE c_canceled_notif;

       END IF; -- check if PO_REQ_REMINDER2 notification is canceled

     ELSE  -- PO_REQ_REMINDER2 notification is not canceled

         CLOSE c_canceled_notif;

     END IF; -- check if PO_REQ_REMINDER2 notification is canceled

   ELSE  -- PO_REQ_APPROVE notifications is not canceled

      CLOSE c_canceled_notif;

   END IF; -- checked if the PO_REQ_APPROVE notifications is canceled

  /* end of fix for 1263201 */

   l_progress := 'Update_Approval_List_Response: 0035';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

  IF l_group_id is NOT NULL THEN
    OPEN c_response(l_group_id);
    FETCH c_response INTO l_role, l_value;
    CLOSE c_response;

    l_progress := 'Update_Approval_List_Response: 004';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

    IF l_group_id is NOT NULL THEN

/* Bug 1257763 */
	SELECT wfn.responder, wfn.recipient_role, wfn.end_date
	INTO l_responder, l_recipient_role, l_end_date
	FROM   wf_notifications wfn
	WHERE  wfn.notification_id = l_group_id;

/* csheu bug #1287135 use reponder value in wf_notification to find
   its orig_system_id from wf_users. If no matched rows found from
   wf_users then we will use l_recipient_role value from wf_notification
   to find its orig_system_id from wf_users instead.
*/

        OPEN c_responderid(l_responder);
        FETCH c_responderid INTO l_responder_id;

        IF c_responderid%NOTFOUND THEN

          CLOSE c_responderid;
          OPEN c_responderid(l_recipient_role);
          FETCH c_responderid INTO l_responder_id;
          CLOSE c_responderid;

        END IF;

        IF (c_responderid%ISOPEN) THEN
          CLOSE c_responderid;
        END IF;


      l_progress := 'Update_Approval_List_Response: 005';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      wf_engine.SetItemAttrNumber(itemtype   => itemType,
                                     itemkey => itemkey,
                                     aname   => 'RESPONDER_ID',
                                     avalue  => l_responder_id);

      l_orig_system:= 'PER';

      WF_DIRECTORY.GetUserName(l_orig_system,
                               l_responder_id,
                               l_responder_user_name,
                               l_responder_disp_name);

      l_progress := 'Update_Approval_List_Response: 007 -' || l_responder_user_name;
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      wf_engine.SetItemAttrText( itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'RESPONDER_USER_NAME' ,
                              avalue     => l_responder_user_name);

      wf_engine.SetItemAttrText( itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'RESPONDER_DISPLAY_NAME' ,
                              avalue     => l_responder_disp_name);

      l_progress := 'Update_Approval_List_Response: 008' ;
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      IF (INSTR(l_value, 'FORWARD') > 0) THEN
        l_forward_to_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');
      END IF;

       l_progress := 'Update_Approval_List_Response: 009' ;
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

      l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

      l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

      l_approver_id := wf_engine.GetItemAttrNumber(itemtype=>itemtype,
                                                 itemkey=>itemkey,
                                                 aname=>'APPROVER_EMPID');

      l_note := wf_engine.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

      l_progress := 'Update_Approval_List_Response: 010 APP'||
                       to_char(l_approver_id)||
                       ' RES'||to_char(l_responder_id)||
                       ' FWD'||to_char(l_forward_to_id);
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      PO_APPROVALLIST_S1.update_approval_list_response(
                      p_document_id=>l_document_id,
                      p_document_type=>l_document_type,
                      p_document_subtype=>l_document_subtype,
                      p_itemtype=>itemtype,
                      p_itemkey=>itemkey,
                      p_approver_id=>l_approver_id,
                      p_responder_id=>l_responder_id,
                      p_forward_to_id=>l_forward_to_id,
                      p_response=>l_value,
                      p_response_date=>l_end_date,
                      p_comments=>substrb(l_note,1,480), -- bug 3105327
                      p_return_code=>l_return_code);

      l_progress := 'Update_Approval_List_Response: 011'||to_char(l_return_code);
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      IF l_return_code = PO_APPROVALLIST_S1.E_SUCCESS THEN

       /* rebuild since it is a forward */
       IF l_value in ('FORWARD', 'APPROVE_AND_FORWARD') THEN

         l_progress := 'Update_Approval_List_Response: 012';
         IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
         END IF;

         PO_APPROVALLIST_S1.rebuild_approval_list(
                        p_document_id=>l_document_id,
                        p_document_type=>l_document_type,
                        p_document_subtype=>l_document_subtype,
                        p_rebuild_code=>'FORWARD_RESPONSE',
                        p_return_code=>l_return_code,
                        p_error_stack=>l_error_stack,
                        p_approval_list_header_id=>l_approval_list_header_id);

         l_progress := 'Update_Approval_List_Response : 013'||to_char(l_return_code);
         IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
         END IF;

         IF l_return_code = PO_APPROVALLIST_S1.E_SUCCESS THEN
           wf_engine.SetItemAttrNumber(itemtype   => itemType,
                                     itemkey => itemkey,
                                     aname   => 'APPROVAL_LIST_HEADER_ID',
                                     avalue  => l_approval_list_header_id);

           /* Bug# 1712121 */
           if retnew = TRUE  then
            resultout:='COMPLETE' || ':' ||  'SUCCESS';
           else
            resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
           end if;

          RETURN;

        /* Bug# 1394711
       ** Desc: The Update_Approval_List_Response() procedure raises exception
       ** when the rebuild_approval_list() fails and the approval workflow
       ** hangs. We need to handle the situation when the rebuild_approval_list()
       ** fails because of No approver found in order to return the Requisition
       ** to the preparer.
       **
       ** Changed the procedure Update_Approval_List_Response() to return FAILURE
       ** for the above condition or SUCCESS instead of ACTIVITY_PERFORMED.
       **
       ** The Requsition workflow also has been changed to handle the above.
       **
       ** Dependency: poxwfrqa.wft
       */

         ELSIF l_return_code = PO_APPROVALLIST_S1.E_NO_ONE_HAS_AUTHORITY THEN

            /* Bug# 1712121 */

            if retnew = TRUE then
              resultout:='COMPLETE' || ':' ||  'FAILURE';
            end if;
            RETURN;
         END IF; --rebuild success

       ELSE
          /* no need to rebuild for approve or reject actions */
          l_progress := 'Update_Approval_List_Response : 100';
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
          END IF;

          /* Bug# 1712121 */
          if retnew = TRUE then
            resultout:='COMPLETE' || ':' ||  'SUCCESS';
          else
            resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
          end if;
          RETURN;

       END IF; -- forward action

     END IF; -- update success

    END IF;

  END IF; -- c_group_id
   l_progress := 'Update_Approval_List_Response : 999';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  RAISE E_UPDATE_RESPONSE_FAIL;
  END IF; -- run mode

EXCEPTION
 WHEN E_UPDATE_RESPONSE_FAIL THEN
   IF (c_group_id%ISOPEN) THEN
     CLOSE c_group_id;
   END IF;
   IF (c_response%ISOPEN) THEN
     CLOSE c_response;
   END IF;

   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
   wf_core.context('PO_APPROVAL_LIST_WF1S',
                   'Update_Approval_List_Response E_FAILURE',
                   l_progress,l_return_code,sqlerrm);
--   wf_core.raise('Find_Approval_list E_FAILURE' || l_progress||sqlerrm);

   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.UPDATE_APPROVAL_LIST_RESPONSE');

   RAISE;

 WHEN OTHERS THEN
   IF (c_group_id%ISOPEN) THEN
     CLOSE c_group_id;
   END IF;
   IF (c_response%ISOPEN) THEN
     CLOSE c_response;
   END IF;

   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
   wf_core.context('PO_APPROVAL_LIST_WF1S',
                   'Update_Approval_List_Response',l_progress,sqlerrm);

   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.UPDATE_APPROVAL_LIST_RESPONSE');

   RAISE;

END Update_Approval_List_Response;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_approval_response
--It is migrated from existing code in procedure Update_App_List_Resp_Success.
--It is made a public procedure so that the same logic can be shared by AME approval.
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Find the workflow notification's responder.
--Parameters:
--IN:
--itemtype
--  workflow item type
--itemtype
--  workflow item key
--OUT:
--responderId
--  Notification responder ID
--response
--  Notification response
--responseEndDate
--  Notification response end date
--forwardToId
--  Notification forward to person ID
--End of Comments
-------------------------------------------------------------------------------
procedure get_approval_response(itemtype        in varchar2,
                       itemkey         in varchar2,
                       responderId out NOCOPY number,
                       response out NOCOPY varchar2,
                       responseEndDate out NOCOPY date,
                       forwardToId out NOCOPY number) is

  CURSOR c_group_id (p_itemtype VARCHAR2, p_itemkey VARCHAR2, p_activity_name VARCHAR2, p_activity_name2 VARCHAR2, p_activity_name3 VARCHAR2, p_activity_name4 VARCHAR2) IS
    SELECT notification_id
    FROM   wf_item_activity_statuses_v
    WHERE  item_type = p_itemtype
    AND    item_key = p_itemkey
    AND    activity_name in ( p_activity_name, p_activity_name2,
                              p_activity_name3, p_activity_name4)
    ORDER BY activity_end_date DESC;

  CURSOR c_canceled_notif (notif_id number) IS
    SELECT '1'
     FROM   WF_NOTIFICATIONS
    WHERE   notification_id = notif_id
      AND   status = 'CANCELED';

  CURSOR c_response(p_group_id number) IS
    SELECT recipient_role, attribute_value
    FROM   wf_notification_attr_resp_v
    WHERE  group_id = p_group_id
    AND    attribute_name = 'RESULT';

  CURSOR c_response_note(p_group_id number) IS
    SELECT attribute_value
    FROM   wf_notification_attr_resp_v
    WHERE  group_id = p_group_id
    AND    attribute_name = 'NOTE';

  /* bug 1817306 new cursor c_responderid is defined to replace c_responder */
  CURSOR c_responderid(p_responder VARCHAR2) IS
    SELECT nvl((wfu.orig_system_id), -9996)
    FROM   wf_users wfu
    WHERE  wfu.name = p_responder
    AND    wfu.orig_system not in ('HZ_PARTY', 'POS', 'ENG_LIST', 'CUST_CONT');

  l_responder                 wf_notifications.responder%TYPE;
  l_recipient_role            wf_notifications.recipient_role%TYPE;

  l_progress                  VARCHAR2(100) := '000';
  l_group_id                  NUMBER;
  l_role                      wf_notifications.recipient_role%TYPE;
  l_approver_id               NUMBER := NULL;
  l_orig_system               wf_users.orig_system%TYPE;
  l_responder_user_name       wf_users.name%TYPE;
  l_responder_disp_name       wf_users.display_name%TYPE;

  l_org_id     number;
  is_notif_canceled    VARCHAR2(2);
  l_doc_string varchar2(200);
  l_preparer_user_name wf_users.name%TYPE;

BEGIN

  l_progress := 'Update_App_List_Resp_Success: 001- at beginning of function';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   => itemType,
                                itemkey    => itemkey,
                                aname      => 'RESPONDER_USER_ID',
                                avalue     => fnd_global.USER_ID);

   PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   => itemType,
                                itemkey    => itemkey,
                                aname      => 'RESPONDER_RESP_ID',
                                avalue     => fnd_global.RESP_ID);

   PO_WF_UTIL_PKG.SetItemAttrNumber ( itemtype   => itemType,
                                itemkey    => itemkey,
                                aname      => 'RESPONDER_APPL_ID',
                                avalue     => fnd_global.RESP_APPL_ID);

   l_progress := 'Update_App_List_Resp_Success: 002';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   OPEN c_group_id(itemtype, itemkey, 'PO_REQ_APPROVE', 'PO_REQ_INVALID_FORWARD', 'UNABLE_TO_RESERVE', 'PO_REQ_APPROVE_SIMPLE');

   FETCH c_group_id INTO l_group_id;
   CLOSE c_group_id;

   l_progress := 'Update_App_List_Resp_Success: 003';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

   /* start of fix for 1263201 */
  OPEN c_canceled_notif (l_group_id);
   FETCH c_canceled_notif into is_notif_canceled;


   -- check if PO_REQ_APPROVE notification is canceled
   IF c_canceled_notif%FOUND  THEN

       CLOSE c_canceled_notif;

      l_progress := 'Update_App_List_Resp_Success: 0031';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

     l_group_id := NULL;

     OPEN c_group_id(itemtype, itemkey, 'PO_REQ_REMINDER2', 'PO_REQ_INVALID_FORWARD_R1', 'UNABLE_TO_RESERVE', 'PO_REQ_APPROVE_SIMPLE');
     FETCH c_group_id INTO l_group_id;
     CLOSE c_group_id;

     l_progress := 'Update_App_List_Resp_Success: 0032';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

     OPEN c_canceled_notif (l_group_id);
     FETCH c_canceled_notif into is_notif_canceled;

     -- check if PO_REQ_REMINDER2 notification is canceled
       IF c_canceled_notif%FOUND THEN

       CLOSE c_canceled_notif;

        l_progress := 'Update_App_List_Resp_Success: 0033';
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
       END IF;
       l_group_id := NULL;

       OPEN c_group_id(itemtype, itemkey, 'PO_REQ_REMINDER1', 'PO_REQ_INVALID_FORWARD_R2','UNABLE_TO_RESERVE', 'PO_REQ_APPROVE_SIMPLE');
       FETCH c_group_id INTO l_group_id;
       CLOSE c_group_id;

       l_progress := 'Update_App_List_Resp_Success: 0034';
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
       END IF;

       OPEN c_canceled_notif (l_group_id);
       FETCH c_canceled_notif into is_notif_canceled;

       l_progress := 'Update_App_List_Resp_Success: 00341';
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
       END IF;

       -- check if PO_REQ_REMINDER1 notification is canceled

       IF c_canceled_notif%FOUND THEN

         CLOSE c_canceled_notif;
         l_progress := 'Update_App_List_Resp_Success: 00342';
         l_group_id := NULL;

       ELSE  -- PO_REQ_REMINDER1 notification is not canceled

         CLOSE c_canceled_notif;

       END IF; -- check if PO_REQ_REMINDER2 notification is canceled

     ELSE  -- PO_REQ_REMINDER2 notification is not canceled

         CLOSE c_canceled_notif;

     END IF; -- check if PO_REQ_REMINDER2 notification is canceled

   ELSE  -- PO_REQ_APPROVE notifications is not canceled

      CLOSE c_canceled_notif;

   END IF; -- checked if the PO_REQ_APPROVE notifications is canceled

  /* end of fix for 1263201 */

   l_progress := 'Update_App_List_Resp_Success: 0035';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

  IF l_group_id is NOT NULL THEN
    OPEN c_response(l_group_id);
    FETCH c_response INTO l_role, response;
    CLOSE c_response;

    l_progress := 'Update_App_List_Resp_Success: 004';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

--    IF l_group_id is NOT NULL THEN

/* Bug 1257763 */
	SELECT wfn.responder, wfn.recipient_role, wfn.end_date
	INTO l_responder, l_recipient_role, responseEndDate
	FROM   wf_notifications wfn
	WHERE  wfn.notification_id = l_group_id;

/* csheu bug #1287135 use reponder value in wf_notification to find
   its orig_system_id from wf_users. If no matched rows found from
   wf_users then we will use l_recipient_role value from wf_notification
   to find its orig_system_id from wf_users instead.
*/

        OPEN c_responderid(l_responder);
        FETCH c_responderid INTO responderId;

        IF c_responderid%NOTFOUND THEN

          CLOSE c_responderid;
          OPEN c_responderid(l_recipient_role);
          FETCH c_responderid INTO responderId;
          CLOSE c_responderid;

        END IF;

        IF (c_responderid%ISOPEN) THEN
          CLOSE c_responderid;
        END IF;

      l_progress := 'Update_App_List_Resp_Success: 005';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      wf_engine.SetItemAttrNumber(itemtype   => itemType,
                                     itemkey => itemkey,
                                     aname   => 'RESPONDER_ID',
                                     avalue  => responderId);

      l_orig_system:= 'PER';

      WF_DIRECTORY.GetUserName(l_orig_system,
                               responderId,
                               l_responder_user_name,
                               l_responder_disp_name);

      l_progress := 'Update_App_List_Resp_Success: 007 -' || l_responder_user_name;
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      wf_engine.SetItemAttrText( itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'RESPONDER_USER_NAME' ,
                              avalue     => l_responder_user_name);

      wf_engine.SetItemAttrText( itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'RESPONDER_DISPLAY_NAME' ,
                              avalue     => l_responder_disp_name);

      l_progress := 'Update_App_List_Resp_Success: 008' ;
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      IF (INSTR(response, 'FORWARD') > 0) THEN
        forwardToId := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');
      END IF;

       l_progress := 'Update_App_List_Resp_Success: 009' ;
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;


  END IF; -- c_group_id
   l_progress := 'Update_App_List_Resp_Success : 999';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

EXCEPTION

 WHEN OTHERS THEN
   IF (c_group_id%ISOPEN) THEN
     CLOSE c_group_id;
   END IF;
   IF (c_response%ISOPEN) THEN
     CLOSE c_response;
   END IF;

   wf_core.context('PO_APPROVAL_LIST_WF1S',
                   'Update_App_List_Resp_Success',l_progress,sqlerrm);

   RAISE;
end;






/* Bug# 1712121: kagarwal
** Desc: In bug#1394711 we changed the return type for function
** Update_Approval_List_Response from 'Activity Performed' to 'SUCCESS/FAILURE'.
** This changed was made to the API as well as the workflow.
**
** Now the reqs created after applying this patch would work fine but the
** requisitions submitted for approval before applying this fix, which are still
** in process, get stuck when the users try to approve them.
**
** In scenarios when we have to change the return type in wf, we should
** create a new API and leave the old one as it is. Now the workflow activity
** should be calling the new API. With this the new reqs will work fine as the
** new API will be returning the changed return types as expected by the new
** workflow definition and also the reqs submitted for approval before the fix
** will also work fine as the old workflow definition will be calling the old
** API which still returns the return types as expected by the old definition.
**
** Created a new API 'Update_App_List_Resp_Success'. This API will return
** 'SUCCESS-FAILURE'. The workflow activity 'Update Approval List Response'
** has also been changed to call this new API.
**
** Also reverted the change of bug# 1394711 in the old API
** 'Update_Approval_List_Response'. It will now return 'ACTIVITY_PERFORMED'
** as before the fix in bug# 1394711.
*/

procedure Update_App_List_Resp_Success(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(1000) := '000';
  l_approver_id               NUMBER := NULL;
  l_value                     VARCHAR2(2000);
  l_responder_id              NUMBER := NULL;
  l_forward_to_id             NUMBER := NULL;
  l_document_id               NUMBER;
  l_document_type             po_document_types.DOCUMENT_TYPE_CODE%TYPE;
  l_document_subtype          po_document_types.DOCUMENT_SUBTYPE%TYPE;
  l_return_code               NUMBER;
  l_orgid                     NUMBER;
  l_approval_list_header_id   NUMBER:='';
  l_error_stack               PO_APPROVALLIST_S1.ErrorStackType;
  E_UPDATE_RESPONSE_FAIL      EXCEPTION;
  l_end_date                  DATE; -- notification end date
  l_note                      VARCHAR2(4000);
  l_doc_string varchar2(200);
  l_preparer_user_name  wf_users.name%TYPE;

  doc_manager_exception exception;

BEGIN

  l_progress := 'Update_App_List_Resp_Success: 001- at beginning of function';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

  IF (funcmode='RUN') THEN

      get_approval_response(itemtype => itemtype,
                       itemkey  => itemkey,
                       responderId => l_responder_id,
                       response =>l_value,
                       responseEndDate =>l_end_date,
                       forwardToId => l_forward_to_id);

      -- Context Setting revamp
      -- set_doc_mgr_context(itemtype, itemkey);

      l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

      IF l_orgid is NOT NULL THEN

	PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

      END IF;

      l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

      l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

      l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

      l_approver_id := wf_engine.GetItemAttrNumber(itemtype=>itemtype,
                                                 itemkey=>itemkey,
                                                 aname=>'APPROVER_EMPID');

      l_note := wf_engine.GetItemAttrText(itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

      l_progress := 'Update_App_List_Resp_Success: 010 APP'||
                       to_char(l_approver_id)||
                       ' RES'||to_char(l_responder_id)||
                       ' FWD'||to_char(l_forward_to_id);
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      PO_APPROVALLIST_S1.update_approval_list_response(
                      p_document_id=>l_document_id,
                      p_document_type=>l_document_type,
                      p_document_subtype=>l_document_subtype,
                      p_itemtype=>itemtype,
                      p_itemkey=>itemkey,
                      p_approver_id=>l_approver_id,
                      p_responder_id=>l_responder_id,
                      p_forward_to_id=>l_forward_to_id,
                      p_response=>l_value,
                      p_response_date=>l_end_date,
                      p_comments=>substrb(l_note,1,480), -- bug 3105327
                      p_return_code=>l_return_code);

      l_progress := 'Update_App_List_Resp_Success: 011'||to_char(l_return_code);
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      IF l_return_code = PO_APPROVALLIST_S1.E_SUCCESS THEN

       /* rebuild since it is a forward */
       IF l_value in ('FORWARD', 'APPROVE_AND_FORWARD') THEN

         l_progress := 'Update_App_List_Resp_Success: 012';
         IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
         END IF;
         PO_APPROVALLIST_S1.rebuild_approval_list(
                        p_document_id=>l_document_id,
                        p_document_type=>l_document_type,
                        p_document_subtype=>l_document_subtype,
                        p_rebuild_code=>'FORWARD_RESPONSE',
                        p_return_code=>l_return_code,
                        p_error_stack=>l_error_stack,
                        p_approval_list_header_id=>l_approval_list_header_id
                        );


         l_progress := 'Update_App_List_Resp_Success : 013'||to_char(l_return_code);
         IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
         END IF;

         IF l_return_code = PO_APPROVALLIST_S1.E_SUCCESS THEN
           wf_engine.SetItemAttrNumber(itemtype   => itemType,
                                     itemkey => itemkey,
                                     aname   => 'APPROVAL_LIST_HEADER_ID',
                                     avalue  => l_approval_list_header_id);

          resultout:='COMPLETE' || ':' ||  'SUCCESS';
          RETURN;

        /* Bug# 1394711
       ** Desc: The Update_Approval_List_Response() procedure raises exception
       ** when the rebuild_approval_list() fails and the approval workflow
       ** hangs. We need to handle the situation when the rebuild_approval_list()
       ** fails because of No approver found in order to return the Requisition
       ** to the preparer.
       **
       ** Changed the procedure Update_Approval_List_Response() to return FAILURE
       ** for the above condition or SUCCESS instead of ACTIVITY_PERFORMED.
       **
       ** The Requsition workflow also has been changed to handle the above.
       **
       ** Dependency: poxwfrqa.wft
       */

         ELSIF l_return_code = PO_APPROVALLIST_S1.E_NO_ONE_HAS_AUTHORITY THEN
            resultout:='COMPLETE' || ':' ||  'FAILURE';
            RETURN;

/* Bug# 2378775 */

         ELSIF l_return_code in (PO_APPROVALLIST_S1.E_DOC_MGR_TIMEOUT,
                                 PO_APPROVALLIST_S1.E_DOC_MGR_NOMGR,
                                 PO_APPROVALLIST_S1.E_DOC_MGR_OTHER) THEN

              set_doc_mgr_err(itemtype, itemkey, l_error_stack, l_return_code);
              raise doc_manager_exception;

         END IF; --rebuild success

       ELSE
          /* no need to rebuild for approve or reject actions */
          resultout:='COMPLETE' || ':' ||  'SUCCESS';
          RETURN;

       END IF; -- forward action

     END IF; -- update success

    l_progress := 'Update_App_List_Resp_Success : 999';
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

    RAISE E_UPDATE_RESPONSE_FAIL;
  END IF; -- run mode

EXCEPTION
 WHEN doc_manager_exception THEN
        raise;

 WHEN E_UPDATE_RESPONSE_FAIL THEN

   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
   wf_core.context('PO_APPROVAL_LIST_WF1S',
                   'Update_App_List_Resp_Success E_FAILURE',
                   l_progress,l_return_code,sqlerrm);
--   wf_core.raise('Find_Approval_list E_FAILURE' || l_progress||sqlerrm);

   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string,
   sqlerrm, 'PO_APPROVAL_LIST_WF1S.UPDATE_APP_LIST_RESP_SUCCESS');

   RAISE;

 WHEN OTHERS THEN

   l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
   l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
   wf_core.context('PO_APPROVAL_LIST_WF1S',
                   'Update_App_List_Resp_Success',l_progress,sqlerrm);

   PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string,
   sqlerrm, 'PO_APPROVAL_LIST_WF1S.UPDATE_APP_LIST_RESP_SUCCESS');

   RAISE;

END Update_App_List_Resp_Success;

-- Create Attachment from Information Template
-- This procedure calls por_ift_info_pkg package
-- to create attachments from information template
--
procedure Create_Attach_Info_Temp(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS
  l_req_header_id                NUMBER:='';
  l_progress                     VARCHAR2(100) := '000';

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;
  l_preparer_language varchar2(10);

BEGIN

    l_progress := '000';

    IF (funcmode='RUN') THEN

      -- Set the multi-org context

      l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'ORG_ID');

      IF l_org_id is NOT NULL THEN

	PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

      END IF;

      l_req_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');


     --Bug 3800933. Get the preparer language and pass to info template attachment
      l_preparer_language := po_wf_util_pkg.GetItemAttrText ( ItemType => itemtype,
                                                              ItemKey  => itemkey,
                                                              aname    => 'PREPARER_LANGUAGE');

      l_progress := '001';

      por_ift_info_pkg.add_info_template_attachment(l_req_header_id, 33, l_preparer_language);

      l_progress := '002';

      resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
      return;

    END IF; -- run mode
    l_progress := '999';

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Create_Attach_Info_Temp',l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.CREATE_ATTACH_INFO_TEMP');
   RAISE;

END Create_Attach_Info_Temp;

--
PROCEDURE set_doc_mgr_context (itemtype VARCHAR2, itemkey VARCHAR2) is

l_user_id            number;
l_responsibility_id  number;
l_application_id     number;

l_progress  varchar2(200);

BEGIN

   l_user_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey          => itemkey,
                                      aname            => 'USER_ID');
   --
   l_application_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'APPLICATION_ID');
   --
   l_responsibility_id := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'RESPONSIBILITY_ID');

   /* Set the context for the doc manager */
   -- Bug 4290541, replace apps init with set doc mgr context
   -- Context Setting revamp
   -- PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey);

  l_progress := 'set_doc_mgr_context. USER_ID= ' || to_char(l_user_id)
                || ' APPLICATION_ID= ' || to_char(l_application_id) ||
                   'RESPONSIBILITY_ID= ' || to_char(l_responsibility_id);

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_APPROVAL_LIST_WFS1','set_doc_mgr_context',l_progress);
        raise;

END set_doc_mgr_context;
--

/* Bug# 2378775: kagarwal
** Desc: Added new procedure set_doc_mgr_err to initialize the document
** manager error number and system admin error message for the POERROR
** workflow.
*/

PROCEDURE set_doc_mgr_err(itemtype      varchar2,
                          itemkey       varchar2,
                          p_error_stack PO_APPROVALLIST_S1.ErrorStackType,
                          p_return_code number) is

  l_message_stack PO_APPROVALLIST_S1.MessageStackType;
  l_err_code  NUMBER;
  l_err_index NUMBER;
  l_progress  varchar2(200);

BEGIN
  l_progress := 'set_doc_mgr_err: 001';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

  IF p_return_code = PO_APPROVALLIST_S1.E_DOC_MGR_TIMEOUT THEN
     PO_REQAPPROVAL_ACTION.doc_mgr_err_num := 1;
  ELSIF p_return_code = PO_APPROVALLIST_S1.E_DOC_MGR_NOMGR THEN
     PO_REQAPPROVAL_ACTION.doc_mgr_err_num := 2;
  ELSIF p_return_code = PO_APPROVALLIST_S1.E_DOC_MGR_OTHER THEN
     PO_REQAPPROVAL_ACTION.doc_mgr_err_num := 3;
  END IF;

  l_progress := 'set_doc_mgr_err: 020: error number = '||
                to_char(PO_REQAPPROVAL_ACTION.doc_mgr_err_num);
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

  IF (p_error_stack.COUNT > 0) THEN
     PO_APPROVALLIST_S1.retrieve_messages(p_error_stack,
                                          l_err_code,
                                          l_message_stack);

     IF (l_err_code = PO_APPROVALLIST_S1.E_SUCCESS) THEN
         l_err_index := p_error_stack.LAST;

         If (l_err_index is NOT NULL) THEN
             PO_REQAPPROVAL_ACTION.sysadmin_err_msg:= l_message_stack(l_err_index);

             l_progress := 'set_doc_mgr_err: 050: error msg = '||
                           PO_REQAPPROVAL_ACTION.sysadmin_err_msg;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
             END IF;

         End If;

     END IF;

  END IF;

   l_progress := 'set_doc_mgr_err: 999';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
    wf_core.context('PO_APPROVAL_LIST_WFS1','set_doc_mgr_err',l_progress);
    raise;
END;

/* Bug# 2684757: kagarwal
** Desc: Added new wf api to insert null action before
** Reserving a Requisition, if the null action does not exists.
** Otherwise the Reserve action is not recorded.
*/
procedure Insert_Res_Action_History(itemtype    in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  l_approver_id               NUMBER:='';
  l_approval_path_id          NUMBER:='';
  l_req_header_id             NUMBER:='';

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

  l_org_id     number;
BEGIN

    l_progress := 'Insert_Res_Action_History: 001';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

    IF (funcmode='RUN') THEN

      l_approver_id := wf_engine.GetItemAttrNumber(itemtype=>itemtype,
                                                   itemkey=>itemkey,
                                                   aname=>'APPROVER_EMPID');

      l_approval_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVAL_PATH_ID');

      l_req_header_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

      -- Set the multi-org context

      l_org_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'ORG_ID');

      IF l_org_id is NOT NULL THEN

	PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

      END IF;

      PO_APPROVAL_LIST_HISTORY_SV.Reserve_Action_History(
                                  x_req_header_id=>l_req_header_id,
                                  x_approval_path_id=>l_approval_path_id,
                                  x_approver_id =>l_approver_id);

      l_progress := 'Insert_Res_Action_History: 005 - Reserve_Action_History';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      resultout:='COMPLETE' || ':' ||  'ACTIVITY_PERFORMED';
      return;

    END IF; -- run mode

    l_progress := 'Insert_Res_Action_History: 999';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType,itemkey);
    wf_core.context('PO_APPROVAL_LIST_WF1S','Insert_Res_Action_History',
                     l_progress,sqlerrm);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
           l_doc_string, sqlerrm, 'PO_APPROVAL_LIST_WF1S.INSERT_ACTION_HISTORY');
    RAISE;

END Insert_Res_Action_History;


END PO_APPROVAL_LIST_WF1S;

/
