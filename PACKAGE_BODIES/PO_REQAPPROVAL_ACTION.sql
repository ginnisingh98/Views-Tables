--------------------------------------------------------
--  DDL for Package Body PO_REQAPPROVAL_ACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQAPPROVAL_ACTION" AS
/* $Header: POXWPA4B.pls 120.10.12010000.23 2014/07/25 02:15:46 roqiu ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

 /*=======================================================================+
 | FILENAME
 |   xxx.sql
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_REQAPPROVAL_ACTION
 |
 | NOTES        Ben Chihaoui Created 6/15/97
 | MODIFIED     Wlau	Support for Kanban Execution 	8/28/97
 |
 *=======================================================================*/


-- The following are local/Private procedure that support the workflow APIs:


PROCEDURE Invoke_Acknowledge_PO_WF(itemtype in varchar2, itemkey in varchar2);
--

FUNCTION StateCheckApprove(itemtype in varchar2, itemkey in varchar2) RETURN VARCHAR2;

--
FUNCTION StateCheckReject(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
FUNCTION DocCompleteCheck(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

PROCEDURE InsertHistForOwnerApprove (itemtype VARCHAR2,
                                     itemkey VARCHAR2,
                                     p_document_id NUMBER,
                                     p_document_type VARCHAR2,
                                     p_document_subtype VARCHAR2);

--
FUNCTION ApproveDoc(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
FUNCTION ApproveAndForward(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
FUNCTION ForwardDocInProcess(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
FUNCTION ForwardDocPreApproved(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
FUNCTION RejectDoc(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
FUNCTION VerifyAuthority(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
FUNCTION OpenDocumentState(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
/* Bug# 2234341 */
FUNCTION ReserveDoc(itemtype VARCHAR2, itemkey VARCHAR2,
                    p_override_funds VARCHAR2 default 'N') RETURN VARCHAR2;

--

-- <ENCUMBRANCE FPJ START>
-- Adding an autonomous call

PROCEDURE ReserveAutonomous(
   p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_id                         IN             NUMBER
,  p_override_funds                 IN             VARCHAR2
,  p_employee_id                    IN             NUMBER
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);

PROCEDURE po_submission_check_autonomous(
   p_document_type                  IN             VARCHAR2
,  p_document_subtype               IN             VARCHAR2
,  p_document_id                    IN             NUMBER
,  p_check_asl                      IN             BOOLEAN
,  x_return_status                  OUT NOCOPY     VARCHAR2
,  x_sub_check_status               OUT NOCOPY     VARCHAR2
,  x_msg_data                       OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
);

-- <ENCUMBRANCE FPJ END>

PROCEDURE get_online_report_text(itemtype VARCHAR2, itemkey VARCHAR2, p_online_report_id NUMBER);

-- Bug 3536831: Added get_advisory_warning(), and created set_report_text_attr()
-- Both get_advisory_warning and get_online_report_text will now call set_report_text_attr.

PROCEDURE get_advisory_warning(
  itemtype                          IN             VARCHAR2
, itemkey                           IN             VARCHAR2
, p_online_report_id                IN             NUMBER
, p_warning_header_text             IN             VARCHAR2
);

PROCEDURE set_report_text_attr(
  itemtype                          IN             VARCHAR2
, itemkey                           IN             VARCHAR2
, p_online_report_id                IN             NUMBER
, p_attribute                       IN             VARCHAR2
, p_header_text                     IN             VARCHAR2   DEFAULT NULL
);


-- <Doc Manager Rewrite 11.5.11 Start>

PROCEDURE ApproveAutonomous(
   p_document_id       IN NUMBER
,  p_document_type     IN VARCHAR2
,  p_document_subtype  IN VARCHAR2
,  p_note              IN VARCHAR2
,  p_approval_path_id  IN NUMBER
,  x_return_status     OUT NOCOPY VARCHAR2
,  x_exception_msg     OUT NOCOPY VARCHAR2
);

PROCEDURE RejectAutonomous(
   p_document_id       IN NUMBER
,  p_document_type     IN VARCHAR2
,  p_document_subtype  IN VARCHAR2
,  p_note              IN VARCHAR2
,  p_approval_path_id  IN NUMBER
,  x_return_status     OUT NOCOPY VARCHAR2
,  x_return_code       OUT NOCOPY VARCHAR2
,  x_exception_msg     OUT NOCOPY VARCHAR2
,  x_online_report_id  OUT NOCOPY NUMBER
);

PROCEDURE ForwardAutonomous(
   p_document_id       IN NUMBER
,  p_document_type     IN VARCHAR2
,  p_document_subtype  IN VARCHAR2
,  p_new_doc_status    IN VARCHAR2
,  p_note              IN VARCHAR2
,  p_approval_path_id  IN NUMBER
,  p_forward_to_id     IN NUMBER
,  x_return_status     OUT NOCOPY VARCHAR2
,  x_exception_msg     OUT NOCOPY VARCHAR2
);

PROCEDURE AutoUpdateCloseAutonomous(
   p_document_id       IN NUMBER
,  p_document_type     IN VARCHAR2
,  p_document_subtype  IN VARCHAR2
,  x_return_status     OUT NOCOPY VARCHAR2
,  x_exception_msg     OUT NOCOPY VARCHAR2
,  x_return_code       OUT NOCOPY VARCHAR2
);

-- <Doc Manager Rewrite 11.5.11 End>

--
PROCEDURE set_doc_mgr_context(itemtype VARCHAR2, itemkey VARCHAR2);
PROCEDURE set_responder_doc_mgr_context(itemtype VARCHAR2, itemkey VARCHAR2);

/***************************************************************************************/

PROCEDURE Invoke_Acknowledge_PO_WF(itemtype in varchar2, itemkey in varchar2)
is
	x_orig_system varchar2(12);
	contact_user_name varchar2(60);
	contact_display_name varchar2(240);
  	l_ItemType  VARCHAR2(100) := 'POSPOACK';
  	l_ItemKey   VARCHAR2(240) ;
	Document_id number;
	x_document_type varchar2(80);
	x_doc_revision	number;
	x_vendor_contact_id number;
	x_vendor_user_id number := NULL;
	x_contact_user_name varchar2(240);
	x_contact_display_name varchar2(240);
	x_acceptance_due_date date;
	x_acceptance_required_flag varchar2(1);
	x_minutes_to_acceptance number;
	x_item_exists number;
	x_progress varchar2(4) := '000';

	cursor vendor_contacts (supplier_contact_id varchar2) is
		select USER_ID from fnd_user where supplier_id = supplier_contact_id;
begin

	-- check if web suppliers is installed - return FALSE if not.

	Document_Id    :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         		itemkey  => itemkey,
                                         		aname    => 'DOCUMENT_ID');

	x_Document_type   :=  wf_engine.GetItemAttrText (	itemtype => itemtype,
                                         			itemkey  => itemkey,
                                         			aname    => 'DOCUMENT_TYPE');

	select vendor_contact_id, nvl(acceptance_required_flag, 'N'), acceptance_due_date, nvl(revision_num, 0)
	into x_vendor_contact_id, x_acceptance_required_flag, x_acceptance_due_date, x_doc_revision
	from po_headers
	where po_header_id = document_id;

	if x_vendor_contact_id is not null then

		-- get the vendor contact user name.

		open vendor_contacts(x_vendor_contact_id);

		fetch vendor_contacts into x_vendor_user_id;

	  	x_orig_system:= 'FND_USR';

	  	WF_DIRECTORY.GetUserName(  x_orig_system,
	        	                   x_vendor_user_id,
       		         	           x_contact_user_name,
                	        	   x_contact_display_name);

		if ( x_contact_user_name is not null ) then

			l_itemkey := 'POS_ACK_' || to_char (document_id) || '_' || to_char(nvl(x_doc_revision, 0));

			-- Check if WF already exists

			select count(*) into x_item_exists
			from wf_items
			where item_type = 'POSPOACK'
			and item_key = l_itemkey;

			if nvl(x_item_exists, 0) <> 0 then
				begin
					-- abort if process still active.
					wf_engine.abortprocess ('POSPOACK', l_itemkey);
				exception
					when others then
					null;
				end;

				-- purge the workflow
				wf_purge.items( 'POSPOACK', l_itemkey);
			end if;

			wf_engine.createProcess     ( ItemType  => l_ItemType,
                                      		      ItemKey   => l_ItemKey,
				      		      Process   => 'MAIN_PROCESS');

			wf_engine.SetItemAttrNumber ( itemtype => l_itemtype,
        					    itemkey  => l_itemkey,
        	        			    aname    => 'DOCUMENT_ID',
						    avalue   => document_id);

			wf_engine.SetItemAttrText ( itemtype => l_itemtype,
        					    itemkey  => l_itemkey,
        	        			    aname    => 'DOCUMENT_TYPE_CODE',
						    avalue   => x_document_type);

			wf_engine.SetItemAttrText ( itemtype => l_itemtype,
        					    itemkey  => l_itemkey,
        	        			    aname    => 'SUPPLIER_USER_NAME',
						    avalue   => x_contact_user_name);

			wf_engine.SetItemAttrDate ( itemtype => l_itemtype,
        					    itemkey  => l_itemkey,
        	        			    aname    => 'ACCEPTANCE_DUE_DATE',
						    avalue   => x_acceptance_due_date);

			-- set item owner.
			wf_engine.setitemowner ( l_itemtype, l_itemkey, x_contact_user_name);

			begin
				select (trunc(nvl(x_acceptance_due_date, sysdate)) - trunc(sysdate)) * 60
				into x_minutes_to_acceptance
				from sys.dual;

				if x_minutes_to_acceptance is not null then

					wf_engine.SetItemAttrNumber ( itemtype => l_itemtype,
        							      itemkey  => l_itemkey,
        	        					      aname    => 'NUM_MINUTES_TO_ACCEPTANCE',
								      avalue   =>  x_minutes_to_acceptance);
				end if;
			exception
				when others then
				null;
			end;

  		      	wf_engine.StartProcess      ( ItemType  => l_ItemType,
                        		              ItemKey   => l_ItemKey );
		end if;
	end if;

EXCEPTION

  WHEN OTHERS THEN
    WF_CORE.context('PO_REQAPPROVAL_ACTION' , 'Invoke_Acknowledge_PO_WF', itemtype, itemkey, x_progress);
    RAISE;

end;

/***************************************************************************************/

procedure State_Check_approve(  itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

x_progress  varchar2(100);
x_resultout varchar2(30);

l_doc_mgr_return_val VARCHAR2(1);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
doc_manager_exception exception;

l_doc_type varchar2(30);
l_orgid number;


BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.State_Check_approve: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Set the Doc manager context */
  -- Context Fixing revamp
  --set_doc_mgr_context(itemtype, itemkey);

	/* RG: bug fix 2424044
	code has been changed from doc mgr call to pl/sql call
	apps_initialize internally calls set_org_context to org_id
	that is not necessarily same as the org_id on the document */

	l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

	IF l_orgid is NOT NULL THEN
          PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12.MOAC>
	END IF;

  /* begin code to branch to check document in plsql */

  l_doc_type :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'DOCUMENT_TYPE');
  if(l_doc_type = 'PA' or l_doc_type = 'PO' or l_doc_type = 'RELEASE') then
    x_resultout := PO_APPROVAL_ACTION.po_state_check_approve(itemtype, itemkey, l_doc_type);
    resultout := wf_engine.eng_completed || ':' || x_resultout;
    return;
  elsif (l_doc_type = 'REQUISITION') then
    x_resultout := PO_APPROVAL_ACTION.req_state_check_approve(itemtype, itemkey);
    resultout := wf_engine.eng_completed || ':' || x_resultout;
    return;
  end if;

  /* end code to branch to check document in plsql */

  l_doc_mgr_return_val := StateCheckApprove(itemtype, itemkey);

  IF l_doc_mgr_return_val = 'Y' THEN

     resultout := wf_engine.eng_completed || ':' ||  'Y';
     x_resultout := 'Y';

  ELSIF l_doc_mgr_return_val = 'N' THEN

     resultout := wf_engine.eng_completed || ':' ||  'N';
     x_resultout := 'N';

  ELSIF l_doc_mgr_return_val = 'F' THEN

     /* This will force the transition in the Workflow to be "Default" */
     raise doc_manager_exception;

  END IF;


  x_progress := 'PO_REQAPPROVAL_ACTION.State_Check_approve: 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION
  WHEN doc_manager_exception THEN
        raise;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION' , 'state_check_approve', itemtype, itemkey, x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.STATE_CHECK_APPROVE');
    RAISE;


END State_Check_approve;


--
-- State_Check_reject
--  Is the state of the document compatible with the reject action.
--
procedure State_Check_reject(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
x_progress              varchar2(100);
x_resultout varchar2(30);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

l_doc_mgr_return_val VARCHAR2(1);
doc_manager_exception exception;

BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.State_Check_reject: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Set the Doc manager context */
  -- Context Setting revamp
  -- set_doc_mgr_context(itemtype, itemkey);

  l_doc_mgr_return_val := StateCheckReject(itemtype, itemkey);

  IF l_doc_mgr_return_val = 'Y' THEN

     resultout := wf_engine.eng_completed || ':' ||  'Y';
     x_resultout := 'Y';

  ELSIF l_doc_mgr_return_val = 'N' THEN

     resultout := wf_engine.eng_completed || ':' ||  'N';
     x_resultout := 'N';

  ELSIF l_doc_mgr_return_val = 'F' THEN

     /* This will force the transition in the Workflow to be "Default" */
     x_resultout := 'F';
     raise doc_manager_exception;

  END IF;


  x_progress := 'PO_REQAPPROVAL_ACTION.State_Check_reject: 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN doc_manager_exception THEN
        raise;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION', 'State_Check_reject', itemtype, itemkey, x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.STATE_CHECK_REJECT');
    RAISE;

END State_Check_reject;

--
-- Doc_complete_check
--  Is the doc complete (all quantities match, at least one line and one distribution...)
--
procedure Doc_complete_check(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

x_progress              varchar2(100);
x_resultout varchar2(30);
l_doc_mgr_return_val VARCHAR2(1);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
doc_manager_exception exception;

l_doc_type varchar2(30);
l_orgid  number;

--<SUBMISSION CHECK FPI>
l_sub_check_status varchar2(1);

BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.Doc_complete_check: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Set the Doc manager context */
   -- Context Setting revamp
   -- set_doc_mgr_context(itemtype, itemkey);

--<SUBMISSION CHECK FPI START>
       /* RG: bug fix 2424044
        code has been changed from doc mgr call to pl/sql call
        apps_initialize internally calls set_org_context to org_id
        that is not necessarily same as the org_id on the document */

        l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

        IF l_orgid is NOT NULL THEN
          PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12.MOAC>
        END IF;
--<SUBMISSION CHECK FPI END>


  /* begin code to branch to check document in plsql */
  l_doc_type :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'DOCUMENT_TYPE');
  if(l_doc_type = 'REQUISITION') then
    x_resultout := PO_APPROVAL_ACTION.req_complete_check(itemtype, itemkey);
    resultout := wf_engine.eng_completed || ':' || x_resultout;
    return;
  end if;
  /* end code to branch to check document in plsql */


--<SUBMISSION CHECK FPI START>
-- Starting 115.33 the submission check code has been changed from doc
-- mgr call to PL/SQL call as part of SUBMISSION CHECK REWRITE project in FPI
-- Following doc mgr call is commented
/*
  l_doc_mgr_return_val := DocCompleteCheck(itemtype, itemkey);

  IF l_doc_mgr_return_val = 'Y' THEN

     resultout := wf_engine.eng_completed || ':' ||  'Y';
     x_resultout := 'Y';

  ELSIF l_doc_mgr_return_val = 'N' THEN

     resultout := wf_engine.eng_completed || ':' ||  'N';
     x_resultout := 'N';

  ELSIF l_doc_mgr_return_val = 'F' THEN

    -- This will force the transition in the Workflow to be "Default"
     raise doc_manager_exception;

  END IF;
*/

-- New call in FPI
  l_sub_check_status := DocCompleteCheck(itemtype, itemkey);

  IF l_sub_check_status = FND_API.G_RET_STS_SUCCESS THEN


     /* AME Project - setting the bypass flag to Y once submission checks are successful*/
     po_wf_util_pkg.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'BYPASS_CHECKS_FLAG',
                                   avalue   => 'Y');

     resultout := wf_engine.eng_completed || ':' ||  'Y';
     x_resultout := 'Y';

  ELSIF l_sub_check_status = FND_API.G_RET_STS_ERROR THEN

     resultout := wf_engine.eng_completed || ':' ||  'N';
     x_resultout := 'N';

  ELSIF l_sub_check_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

	raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
--<SUBMISSION CHECK FPI END>

  x_progress := 'PO_REQAPPROVAL_ACTION.Doc_complete_check: 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN doc_manager_exception THEN
        raise;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION', 'Doc_complete_check', itemtype, itemkey, x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.DOC_COMPLETE_CHECK');
    RAISE;

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION', 'Doc_complete_check', itemtype, itemkey, x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.DOC_COMPLETE_CHECK');
    RAISE;

END Doc_complete_check;

--
-- Approve_doc
-- Approve the document
--
procedure Approve_doc(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

x_progress              varchar2(100);
x_vendor_contact_id	number;
x_doc_id 		number;
x_resultout varchar2(30);

l_doc_mgr_return_val VARCHAR2(1);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
doc_manager_exception exception;

l_document_type         PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_document_subtype      PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;
l_document_id           NUMBER;
l_approver_id           NUMBER;
l_preparer_id            NUMBER;
l_insert_owner_app  Boolean := true;
l_is_ame_used    varchar2(10);

--bug 19264583, add an indication that identify which process calling from
l_interface_source      VARCHAR2(30);

---Bug#17798300 newly added variables
l_ApprovalListCount  NUMBER := 0;
l_ameTransactionType po_document_types.ame_transaction_type%TYPE;
l_approverList      ame_util.approversTable2;
l_applicationId     number :=201; /* ame is using PO id  */

BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.Approve_doc: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_document_type    :=  po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_subtype :=  po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  l_document_id      :=  po_wf_util_pkg.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_interface_source :=  po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'INTERFACE_SOURCE_CODE');


-- Bug8795687: When AME is present with First responder win then
-- if the last approver is not the first responder then a NO ACTION
-- is recorded in his action_code. Hence Approve action
-- for owner should not be captured in this case.

  l_is_ame_used := po_wf_util_pkg.GetItemAttrText(
                                     itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'IS_AME_APPROVAL');

  l_approver_id := po_wf_util_pkg.GetItemAttrNumber(
                                         itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_EMPID');

  l_preparer_id := po_wf_util_pkg.GetItemAttrNumber(
                                         itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PREPARER_ID');

 IF( l_is_ame_used ='Y' AND l_approver_id <> l_preparer_id) THEN
 	l_insert_owner_app := false;

 END IF;
-- Bug8795687: end;

  --Bug#17798300,update below code to avoid duplicate action history
  --if the preparer is the same as the final approver for requisition
  if (l_document_type = 'REQUISITION' and l_insert_owner_app) then
     IF(l_is_ame_used ='Y') THEN
	l_ameTransactionType := PO_WF_UTIL_PKG.GetItemAttrText( itemtype => itemtype,
                                                                itemkey  => itemkey,
                                                   aname => 'AME_TRANSACTION_TYPE');

	ame_api6.getApprovers2( applicationIdIn => l_applicationId,
	                       transactionTypeIn => l_ameTransactionType,
 	                       transactionIdIn => l_document_id,
                               approversOut => l_approverList
                              );
        l_ApprovalListCount := l_approverList.count;
     ELSE
        l_ApprovalListCount := 0;
     END IF;

    if(l_ApprovalListCount = 0 ) then
	IF (g_po_wf_debug = 'Y') THEN
             x_progress := 'No approver, require to insert an action history record of APPROVE!';
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
        END IF;

      po_wf_util_pkg.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'NOTE',
                                   avalue   => '');

      InsertHistForOwnerApprove(itemtype, itemkey,
                            l_document_id, l_document_type, l_document_subtype);
    end if;
  end if;

  /*AME Project If AME is used then need to call InsertHistForOwnerApprove*/
IF (l_document_type <> 'REQUISITION') THEN

  BEGIN

  SELECT 'Y'
  INTO   l_is_ame_used
  FROM   po_headers
  WHERE  po_header_id = l_document_id
         AND ame_transaction_type IS NOT NULL;

  EXCEPTION
    WHEN OTHERS THEN
      l_is_ame_used := 'N';
  END;
  -- bug 19234290, if the calling from PDOI auto-approve, then return false, does not handle action history.
  IF(l_is_ame_used ='Y' and l_approver_id = l_preparer_id and (l_interface_source is null or l_interface_source <> 'PDOI_AUTO_APPROVE')) THEN

    po_wf_util_pkg.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'NOTE',
                                   avalue   => '');

    InsertHistForOwnerApprove(itemtype, itemkey,
                            l_document_id, l_document_type, l_document_subtype);

  END IF;

END IF;
/*AME Project End*/



  /* Set the Doc manager context */
   -- Context Setting revamp
   -- set_doc_mgr_context(itemtype, itemkey);

  l_doc_mgr_return_val := ApproveDoc(itemtype, itemkey);

  IF l_doc_mgr_return_val = 'Y' THEN

     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     x_resultout := 'ACTIVITY_PERFORMED';

     -- check if web suppliers is installed.

     /* Commenting out the call to Invoke Acknowledge PO workflow
     since this will now be handled as part of the approval workflow.
      Changes for this workflow have been made in poxwfpoa.wft 115.22 */

     /*if po_core_s.get_product_install_status('POS') = 'I' and
        itemtype = 'POAPPRV' then

	-- Start Acknowledgement Workflow if supplier contact is provided.
	Invoke_Acknowledge_PO_WF(itemtype, itemkey);

     end if;  */

  ELSE
     raise doc_manager_exception;

  END IF;

  x_progress := 'PO_REQAPPROVAL_ACTION.Approve_doc: 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN doc_manager_exception THEN
        raise;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION' , 'Approve_doc', itemtype, itemkey, x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.APPROVE_DOC');
    RAISE;


END Approve_doc;

--
-- Approve_and_forward_doc
--   Approve and forward the doc (i.e. set it status to PRE-APPROVED)
--
procedure Approve_and_forward_doc(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

x_progress        varchar2(100);
x_resultout varchar2(30);

l_approver_empid number;
l_approver_user_name  varchar2(100);
l_approver_disp_name  varchar2(100);
l_doc_mgr_return_val  varchar2(1);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
doc_manager_exception exception;


BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.Approve_and_forward_doc: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Set the Doc manager context */
  -- Context Setting revamp
  -- set_doc_mgr_context(itemtype, itemkey);

     /* AME Project - setting the bypass flag to N if document is getting forwarded.*/
     po_wf_util_pkg.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'BYPASS_CHECKS_FLAG',
                                   avalue   => 'N');

  l_doc_mgr_return_val := ApproveAndForward(itemtype, itemkey);

  IF l_doc_mgr_return_val = 'Y' THEN

     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     x_resultout := 'ACTIVITY_PERFORMED';

    /* Set the value of APPROVER_USER_NAME to the Forward-to person, since
    ** this he/she is going to be the new approver.
    */
    l_approver_user_name := wf_engine.GetItemAttrText
                                      ( itemtype => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'FORWARD_TO_USERNAME');

    l_approver_empid := wf_engine.GetItemAttrNumber
                                      ( itemtype => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'FORWARD_TO_ID');

    l_approver_disp_name := wf_engine.GetItemAttrText
                                      ( itemtype => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'FORWARD_TO_DISPLAY_NAME');

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => l_approver_user_name);

   wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_EMPID',
                                 avalue   => l_approver_empid);

   wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_DISPLAY_NAME',
                                 avalue   => l_approver_disp_name);

  ELSE
	 raise doc_manager_exception;


  END IF;

  x_progress := 'PO_REQAPPROVAL_ACTION.Approve_and_forward_doc: 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN doc_manager_exception THEN
        raise;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION', 'Approve_and_forward_doc', itemtype, itemkey,x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.APPROVE_AND_FORWARD_DOC');
    RAISE;

END Approve_and_forward_doc;

--

--
-- Forward_doc_inprocess
-- If document status is INCOMPLETE, then call cover routine to set the
-- status to INPROCESS and forward to the approver.
--
--
procedure Forward_doc_inprocess(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_found_manager   VARCHAR2(1);
x_progress              varchar2(100);
x_resultout varchar2(30);

l_approver_user_name  varchar2(100);
l_approver_disp_name  varchar2(100);
l_approver_empid      number;
l_doc_mgr_return_val varchar2(1);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
doc_manager_exception exception;

BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.Forward_doc_inprocess: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Set the Doc manager context */

  -- Context Setting revamp
  -- set_doc_mgr_context(itemtype, itemkey);

    /* AME Project - setting the bypass flag to N if document is getting forwarded.*/
     po_wf_util_pkg.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'BYPASS_CHECKS_FLAG',
                                   avalue   => 'N');

  l_doc_mgr_return_val := ForwardDocInProcess(itemtype, itemkey);

  IF l_doc_mgr_return_val = 'Y' THEN

     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     x_resultout := 'ACTIVITY_PERFORMED';

    /* Set the value of APPROVER_USER_NAME to the Forward-to person, since
    ** this he/she is going to be the new approver.
    */

    l_approver_user_name := wf_engine.GetItemAttrText
                                      ( itemtype => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'FORWARD_TO_USERNAME');

    l_approver_empid := wf_engine.GetItemAttrNumber
                                      ( itemtype => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'FORWARD_TO_ID');

    l_approver_disp_name := wf_engine.GetItemAttrText
                                      ( itemtype => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'FORWARD_TO_DISPLAY_NAME');

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => l_approver_user_name);

   wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_EMPID',
                                 avalue   => l_approver_empid);

   wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_DISPLAY_NAME',
                                 avalue   => l_approver_disp_name);

  ELSE

     raise doc_manager_exception;

  END IF;

  x_progress := 'PO_REQAPPROVAL_ACTION.Forward_doc_inprocess: 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN doc_manager_exception THEN
        raise;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION' , 'Forward_doc_inprocess', itemtype, itemkey,x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.FORWARD_DOC_INPROCESS');
    RAISE;

END Forward_doc_inprocess;

--

-- Forward_doc_preapproved
--   If document status is PRE-APPROVED then call cover routine to
--   forward the document to the next approver (doc status stays PRE-APPROVED).
--
procedure Forward_doc_preapproved(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

x_progress              varchar2(100);
x_resultout varchar2(30);

l_approver_user_name varchar2(100);
l_approver_disp_name  varchar2(100);
l_approver_empid number;
l_doc_mgr_return_val varchar2(1);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
doc_manager_exception exception;


BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.Forward_doc_preapproved: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

     /* AME Project  - setting the bypass flag to N if document is getting forwarded.*/
     po_wf_util_pkg.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'BYPASS_CHECKS_FLAG',
                                   avalue   => 'N');

  /* Set the Doc manager context */
   -- Context Setting revamp
   -- set_doc_mgr_context(itemtype, itemkey);

  l_doc_mgr_return_val := ForwardDocPreapproved(itemtype, itemkey);

  IF l_doc_mgr_return_val = 'Y' THEN

     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     x_resultout := 'ACTIVITY_PERFORMED';

    /* Set the value of APPROVER_USER_NAME to the Forward-to person, since
    ** this he/she is going to be the new approver.
    */
    l_approver_user_name := wf_engine.GetItemAttrText
                                      ( itemtype => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'FORWARD_TO_USERNAME');

    l_approver_empid := wf_engine.GetItemAttrNumber
                                      ( itemtype => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'FORWARD_TO_ID');

    l_approver_disp_name := wf_engine.GetItemAttrText
                                      ( itemtype => itemType,
                                        itemkey    => itemkey,
                                        aname      => 'FORWARD_TO_DISPLAY_NAME');

   wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => l_approver_user_name);

   wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_EMPID',
                                 avalue   => l_approver_empid);

   wf_engine.SetItemAttrText (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_DISPLAY_NAME',
                                 avalue   => l_approver_disp_name);

  ELSE
     raise doc_manager_exception;

  END IF;

  x_progress := 'PO_REQAPPROVAL_ACTION.Forward_doc_preapproved: 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN doc_manager_exception THEN
        raise;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION' , 'Forward_doc_preapproved', itemtype, itemkey,x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.FORWARD_DOC_PREAPPROVED');
    RAISE;


END Forward_doc_preapproved;

-- Reject_DOc
--
procedure            Reject_Doc(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

x_progress              varchar2(100);
x_resultout varchar2(30);
l_doc_mgr_return_val varchar2(1);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
doc_manager_exception exception;

/* Bug 12360278 */
l_note po_action_history.note%TYPE;
l_document_type varchar2(25);
/*Bug 12360278 */

BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.Reject_Doc: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Set the Doc manager context */
  -- Context Setting revamp
  -- set_doc_mgr_context(itemtype, itemkey);

   	/*Bug 12360278 Reset response note*/
    l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');
   IF (l_document_type='PO' OR l_document_type='PA' OR l_document_type='RELEASE' ) THEN
    l_note := PO_WF_UTIL_PKG.GetItemAttrText(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'NOTE_R');
    PO_WF_UTIL_PKG.SetItemAttrText(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'NOTE',
	  			      avalue  => l_note);
    PO_WF_UTIL_PKG.SetItemAttrText(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'NOTE_R',
	  			      avalue  => null);
    END IF;
    /*Bug 12360278 */


  l_doc_mgr_return_val := RejectDoc(itemtype, itemkey);

  IF l_doc_mgr_return_val = 'F' THEN
	raise doc_manager_exception;

  END IF;
  resultout := wf_engine.eng_completed || ':' ||  l_doc_mgr_return_val;

  x_progress := 'PO_REQAPPROVAL_ACTION.Reject_Doc: 02. RESULT= ' || l_doc_mgr_return_val;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN doc_manager_exception THEN
        raise;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION' , 'Reject_doc', itemtype, itemkey,x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.REJECT_DOC');
    RAISE;


END Reject_Doc;

--
-- Verify_authority
--   Verify the approval authority against the PO setup control rules.
--
procedure Verify_authority(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

x_progress  varchar2(100);
x_resultout varchar2(30);

l_doc_mgr_return_val varchar2(1);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
doc_manager_exception exception;

BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.Verify_authority: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Set the Doc manager context */
  -- Context Setting revamp
  -- set_doc_mgr_context(itemtype, itemkey);

  l_doc_mgr_return_val := VerifyAuthority(itemtype, itemkey);

  /* If the return value is 'F', then the transition in the Wokflow will
  ** be "Default"
  */
  If l_doc_mgr_return_val = 'F' then
     raise doc_manager_exception;
  End if;

  resultout := wf_engine.eng_completed || ':' ||  l_doc_mgr_return_val;
  x_resultout := l_doc_mgr_return_val;


  x_progress := 'PO_REQAPPROVAL_ACTION.Verify_authority: 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN doc_manager_exception THEN
        raise;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION' , 'Verify_authority', itemtype, itemkey, x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.VERIFY_AUTHORITY');
    RAISE;


END Verify_authority;


--
-- Open_Doc_State
--
--
procedure Open_Doc_State(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
x_progress              varchar2(100);
x_resultout varchar2(30);

l_doc_mgr_return_val varchar2(1);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
doc_manager_exception exception;

BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.Open_Doc_State: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Set the Doc manager context */
   -- Context Setting revamp
   -- set_doc_mgr_context(itemtype, itemkey);

  l_doc_mgr_return_val := OpenDocumentState(itemtype, itemkey);

  /* If the return value is 'F', then the transition in the Wokflow will
  ** be "Default"
  */
  IF l_doc_mgr_return_val <> 'F' THEN

     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     x_resultout :=  'ACTIVITY_PERFORMED';
  ELSE
     raise doc_manager_exception;

  END IF;

  x_progress := 'PO_REQAPPROVAL_ACTION.Open_Doc_State 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN doc_manager_exception THEN
	raise;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION', 'Open_Doc_State', itemtype, itemkey, x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_ACTION.OPEN_DOC_STATE');
    RAISE;

END Open_Doc_State;

--
--
procedure Reserve_Doc(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
x_progress  varchar2(100);
x_resultout varchar2(30);

l_responder_id number;
l_doc_type varchar2(30);

l_doc_mgr_return_val  varchar2(1);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
doc_manager_exception exception;

x_override_funds varchar2(3) := NULL;

l_org_id  number;   -- Bug 3426272


BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.Reserve_Doc: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_doc_type :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'DOCUMENT_TYPE');


  l_responder_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'RESPONDER_USER_ID');


  -- Context Setting revamp
  -- if (l_responder_id is null) then

    /* Set the Doc manager context */
    -- set_doc_mgr_context(itemtype, itemkey);

  --else

    /* Set the Doc manager context based on responder */
    --set_responder_doc_mgr_context(itemtype, itemkey);

  --end if;

  /* Bug 3426272: Set the org context to the org context stored in the
   * workflow attribute.  If the approval workflow is called from another
   * application, the above doc_mgr_context calls may reset the
   * application context and its sub context, the org context, to that
   * of the calling org / application.
   *
   * Before calling the new FPJ encumbrance code, we must ensure
   * that the org context is set to that of the document we are reserving.
   * This is conveniently stored at workflow setup time in the
   * attribute 'ORG_ID'.
   *
   */

  l_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'ORG_ID');

  IF l_org_id is NOT NULL
  THEN
     PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12.MOAC>
  END IF;

  /* End Bug 3426272 */


  /* Bug# 2234341: kagarwal
  ** Desc: Get the value of profile option PO: Override Funds Reservation
  ** and pass it to the ReserveDoc function.
  */

  fnd_profile.get('PO_REQAPPR_OVERRIDE_FUNDS', x_override_funds);

  l_doc_mgr_return_val := ReserveDoc(itemtype, itemkey, x_override_funds);

-- <ENCUMBRANCE FPJ START>
-- Commenting the Doc manager Handling

--  If l_doc_mgr_return_val = 'F' then
--     raise doc_manager_exception;
--  End if;

-- <ENCUMBRANCE FPJ END>

  resultout := wf_engine.eng_completed || ':' ||  l_doc_mgr_return_val;
  x_resultout := l_doc_mgr_return_val;

  x_progress := 'PO_REQAPPROVAL_ACTION.Reserve_Doc 02. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION
--  WHEN doc_manager_exception THEN
--        raise;

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                            itemType, itemkey);

    WF_CORE.context('PO_REQAPPROVAL_ACTION', 'Reserve_Doc', itemtype, itemkey,
                   x_progress);

    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
      l_preparer_user_name, l_doc_string, sqlerrm,
      'PO_REQAPPROVAL_ACTION.RESERVE_DOC');
    RAISE;
END Reserve_Doc;
--

/*********************************************************************************
** The following are the APIs that support the workflow procedures.
*********************************************************************************/


FUNCTION StateCheckApprove(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

-- <Doc Manager Rewrite 11.5.11 Start>

l_document_type         PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_document_subtype      PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;
l_document_id           NUMBER;

l_ret_sts      VARCHAR2(1);
l_exc_msg      VARCHAR2(2000);
l_ret_code     VARCHAR2(25);

-- <Doc Manager Rewrite 11.5.11 End>

x_progress varchar2(200);

BEGIN

  -- <Doc Manager Rewrite 11.5.11 Start>

  l_document_type    :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_subtype :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  x_progress := 'StateCheckApprove: calling action  with: ' || 'Doc_type= ' ||
              l_document_type || ' Subtype= ' || l_document_subtype ||
              ' Doc_id= ' || to_char(l_document_id);

  IF (g_po_wf_debug = 'Y') THEN
    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  PO_DOCUMENT_ACTION_PVT.check_doc_status_approve(
     p_document_id        =>  l_document_id
  ,  p_document_type      =>  l_document_type
  ,  p_document_subtype   =>  l_document_subtype
  ,  x_return_status      =>  l_ret_sts
  ,  x_return_code        =>  l_ret_code
  ,  x_exception_msg      =>  l_exc_msg
  );

  -- check_doc_status_approve sets return status to 'S' or 'U' only
  IF (l_ret_sts = 'S') THEN

     /*  If state check passed, then l_ret_code should be null
     **  otherwise it should be 'STATE_FAILED'.
     */

    IF (l_ret_code is NULL) THEN

      return('Y');

    ELSE

      x_progress := 'PO_REQAPPROVAL_ACTION.StateCheckApprove: Returned_code= ' || l_ret_code;
      IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      return('N');

    END IF;  -- l_ret_code IS NULL

  ELSE

    x_progress := 'PO_REQAPPROVAL_ACTION.StateCheckApprove: action call returned with: ' || l_ret_sts;
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    doc_mgr_err_num := 3;
    sysadmin_err_msg :=  l_exc_msg;

    return('F');

  END IF;  -- l_ret_sts = 'S'

  -- <Doc Manager Rewrite 11.5.11 End>

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','StateCheckApprove',x_progress);
        raise;

END StateCheckApprove;

--

FUNCTION StateCheckReject(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

-- <Doc Manager Rewrite 11.5.11 Start>

l_document_type         PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_document_subtype      PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;
l_document_id           NUMBER;

l_ret_sts      VARCHAR2(1);
l_exc_msg      VARCHAR2(2000);
l_ret_code     VARCHAR2(25);

-- <Doc Manager Rewrite 11.5.11 End>

x_progress varchar2(200);

BEGIN

  -- <Doc Manager Rewrite 11.5.11 Start>

  l_document_type    :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_subtype :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  x_progress := 'StateCheckReject: calling action  with: ' || 'Doc_type= ' ||
              l_document_type || ' Subtype= ' || l_document_subtype ||
              ' Doc_id= ' || to_char(l_document_id);

  IF (g_po_wf_debug = 'Y') THEN
    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  PO_DOCUMENT_ACTION_PVT.check_doc_status_reject(
     p_document_id        =>  l_document_id
  ,  p_document_type      =>  l_document_type
  ,  p_document_subtype   =>  l_document_subtype
  ,  x_return_status      =>  l_ret_sts
  ,  x_return_code        =>  l_ret_code
  ,  x_exception_msg      =>  l_exc_msg
  );

  -- check_doc_status_reject returns either 'S' or 'U'
  IF (l_ret_sts = 'S') THEN

     /*  If state check passed, then l_ret_code should be null
     **  otherwise it should be 'STATE_FAILED'.
     */

    IF (l_ret_code is NULL) THEN

      return('Y');

    ELSE

      x_progress := 'PO_REQAPPROVAL_ACTION.StateCheckReject: Returned_code= ' || l_ret_code;
      IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      return('N');

    END IF;  -- l_ret_code IS NULL

  ELSE

    x_progress := 'PO_REQAPPROVAL_ACTION.StateCheckReject: action call returned with: ' || l_ret_sts;
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    doc_mgr_err_num := 3;
    sysadmin_err_msg :=  l_exc_msg;

    return('F');

  END IF;  -- l_ret_sts = 'S'

  -- <Doc Manager Rewrite 11.5.11 End>

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','StateCheckReject',x_progress);
        raise;

END StateCheckReject;

--
FUNCTION DocCompleteCheck(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

--<SUBMISSION CHECK FPI START>
--L_DM_CALL_REC  PO_DOC_MANAGER_PUB.DM_CALL_REC_TYPE;
    l_document_type VARCHAR2(25);
    l_document_subtype VARCHAR2(25);
    l_document_id NUMBER;
    x_return_status VARCHAR2(1);
    x_sub_check_status VARCHAR2(1);
    x_msg_data VARCHAR2(2000);
    x_online_report_id NUMBER;
--<SUBMISSION CHECK FPI END>

    l_create_sourcing_rule     VARCHAR2(1);                        -- <2757450>
    l_check_asl                BOOLEAN;                            -- <2757450>

    x_progress varchar2(200);

    l_error   VARCHAR2(1) := 'W'; --CONTERMS FPJ
    l_conterms_yn     PO_headers_all.conterms_exist_Flag%Type :='N'; -- CONTERMS FPJ

BEGIN

--<SUBMISSION CHECK FPI START>
-- Starting 115.33 the submission check code has been changed from doc
-- mgr call to PL/SQL call as part of SUBMISSION CHECK REWRITE project in FPI

-- New call to pl/sql package PO_DOCUMENT_CHECKS_GRP.po_submission_check()
-- in file POXGDCKB.pls as part of FPI project SUBMISSION CHECK REWRITE

    l_document_type :=        PO_WF_UTIL_PKG.GetItemAttrText
                              (   itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'DOCUMENT_TYPE'
                              );
    l_document_subtype :=     PO_WF_UTIL_PKG.GetItemAttrText
                              (   itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'DOCUMENT_SUBTYPE'
                              );
    l_document_id :=          PO_WF_UTIL_PKG.GetItemAttrNumber
                              (   itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'DOCUMENT_ID'
                              );
    l_create_sourcing_rule := PO_WF_UTIL_PKG.GetItemAttrText       -- <2757450>
                              (   itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'CREATE_SOURCING_RULE'
                              );

    -- Start of code changes for the bug 16021525
    application_id :=          PO_WF_UTIL_PKG.GetItemAttrNumber
                              (   itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPLICATION_ID'
                              );
    responsibility_id :=          PO_WF_UTIL_PKG.GetItemAttrNumber
                              (   itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'RESPONSIBILITY_ID'
                              );
    user_id :=          PO_WF_UTIL_PKG.GetItemAttrNumber
                              (   itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'USER_ID'
                              );

   x_progress := 'DocCompleteCheck: calling NEW po_submission_check  with: ' || 'Doc_type= ' ||
                  l_document_Type || ' Subtype= ' || l_document_subtype ||
                  ' Doc_id= ' || to_char(l_document_Id)||
                  'Application ID = '||to_char(application_id)||
                  'responsibility_id = '||to_char(responsibility_id)||
                  'user_id = '||to_char(user_id);

   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

    -- <2757450 START>: If user chose to Create Sourcing Rule at the time
    -- of Approval, do not run the ASL Submission Checks.
    --
    IF ( l_create_sourcing_rule = 'Y' )
    THEN
        l_check_asl := FALSE;       -- indicates ASL checks should NOT be run
    ELSE
        l_check_asl := TRUE;        -- indicates ASL checks should be run
    END IF;
    --
    -- <2757450 END>

    --Call the API to do Submission Checks in PL/SQL
   --<ENCUMBRANCE FPJ>
   po_submission_check_autonomous(
      p_document_type      => l_document_type
   ,  p_document_subtype   => l_document_subtype
   ,  p_document_id        => l_document_id
   ,  p_check_asl          => l_check_asl
   ,  x_return_status      => x_return_status
   ,  x_sub_check_status   => x_sub_check_status
   ,  x_msg_data           => x_msg_data
   ,  x_online_report_id   => x_online_report_id
   );

   application_id := null;
   responsibility_id := null;
   user_id := null;
   -- END of code changes for the bug 16021525

  /* If the API executed with no errors
  **     x_return_status = G_RET_STS_SUCCESS
  **     x_sub_check_status = G_RET_STS_SUCCESS then return G_RET_STS_SUCCESS
  ** If the API call went finw while doc has submission check error
  **     x_return_status = G_RET_STS_SUCCESS
  **     x_sub_check_status = G_RET_STS_ERROR then return G_RET_STS_ERROR
  ** Else issue a notification to the system admin that something is wrong with the
  ** Submission Check API call.
  */
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

       IF x_sub_check_status = FND_API.G_RET_STS_SUCCESS THEN
           return(FND_API.G_RET_STS_SUCCESS);
       ELSE

          x_progress := 'PO_REQAPPROVAL_ACTION.DocCompleteCheck: x_sub_check_status= ' ||
              x_sub_check_status || ' On_Line_Report_id= ' ||
              to_char(x_online_report_id);



          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
          END IF;

          --<CONTERMS FPJ START>
          l_conterms_yn:= PO_wf_Util_Pkg.GetItemAttrText(
                          itemtype => itemtype,
  			              itemkey  => itemkey,
			              aname    =>  'CONTERMS_EXIST_FLAG');

          IF (l_conterms_yn = 'Y')  then
             BEGIN
                 -- SQL What:Checks for error message type in error table
                 -- SQL Why :If no errors and only warnings then, success is returned
                 -- SQL JOIN: NONE
                 SELECT 'E'
                 INTO l_error
                 FROM dual
                 WHERE EXISTS (SELECT 1
                          FROM PO_ONLINE_REPORT_TEXT
                          WHERE online_report_id = x_online_report_id
                          AND NVL(message_type, 'E') = 'E');  -- Bug 3906870
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    l_error:='W';
             END;
             IF (l_error = 'W') then
                  x_progress := 'PO_REQAPPROVAL_ACTION.DocCompleteCheck: Only Warnings found. Return success';

                  IF (g_po_wf_debug = 'Y') THEN
                     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
                  END IF;
                  return (FND_API.G_RET_STS_SUCCESS);
             END IF; --l_error=W
          END IF;-- l_conterms_yn

          --<CONTERMS FPJ END>
        /* Get the online_report_id (to be used to populate the notification */
        wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'ONLINE_REPORT_ID',
                                   avalue     =>  x_online_report_id);

        /* Get the text of the online_report and store in workflow item attribute */
        get_online_report_text( itemtype, itemkey, x_online_report_id );

        return(FND_API.G_RET_STS_ERROR);

     END IF; --API is success

  ELSE
    /* something went wrong with Submission Check API call. Send notification to Sys Admin.
         ** The error message is kept in Item Attribute SYSADMIN_ERROR_MSG */


        x_progress := 'PO_REQAPPROVAL_ACTION.DocCompleteCheck: po_submission_check returned with: ' ||
               x_return_status ;

         IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
         END IF;

     sysadmin_err_msg := x_msg_data;

     x_progress := 'PO_REQAPPROVAL_ACTION.DocCompleteCheck: po_submission_check error msg is: ' ||
               x_msg_data;

      IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      return(FND_API.G_RET_STS_UNEXP_ERROR);

  END IF;
--<SUBMISSION CHECK FPI END>

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','DocCompleteCheck',x_progress);
        raise;

END DocCompleteCheck;

/*
  If the document is self approved, add a new blank row in PO_ACTION_HISTORY
  for doc mgr call.
*/
PROCEDURE InsertHistForOwnerApprove (itemtype VARCHAR2,
                                     itemkey VARCHAR2,
                                     p_document_id NUMBER,
                                     p_document_type VARCHAR2,
                                     p_document_subtype VARCHAR2) IS
pragma AUTONOMOUS_TRANSACTION;

l_action_code           PO_ACTION_HISTORY.ACTION_CODE%TYPE;
l_sequence_num          NUMBER;
l_employee_id           NUMBER;
l_object_rev_num        NUMBER;
l_approval_path_id      NUMBER;

x_progress              varchar2(200);

BEGIN

   x_progress := 'PO_REQAPPROVAL_ACTION.InsertHistForOwnerApprove begin';

   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

  -- get data from last entry in po_action_history
  select sequence_num,
         action_code,
         object_revision_num,
         approval_path_id
    into l_sequence_num,
         l_action_code,
         l_object_rev_num,
         l_approval_path_id
    from po_action_history
   where object_id = p_document_id
     and object_type_code = p_document_type
     and sequence_num = (select max(sequence_num)
                           from po_action_history
                          where object_id = p_document_id
                            and object_type_code = p_document_type);

   x_progress := 'PO_REQAPPROVAL_ACTION.InsertHistForOwnerApprove action_code: ' || l_action_code;

   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, x_progress);
   END IF;

  -- if last entry into po_action_history is submit or reserve, then
  -- req is self-approved.  Insert approval entry.
  if (l_action_code in ('SUBMIT', 'RESERVE', 'NO ACTION')) THEN

    -- get data from last SUBMIT entry in po_action_history (req submission)

    /*Bug 12701382 - In case of Timeout employee id corresponding to last Approve action should be taken.
    In case of timeout and document is self approved,  employee id corresponding to Submit action should be taken.*/

 IF l_action_code = 'NO ACTION' THEN

    BEGIN

    select employee_id
    into l_employee_id
    from po_action_history
    where object_id = p_document_id
     and object_type_code = p_document_type
     and sequence_num = (select max(sequence_num)
                           from po_action_history
                          where object_id = p_document_id
                            and action_code = 'APPROVE'
                            and object_type_code = p_document_type);

    EXCEPTION

    WHEN No_Data_Found THEN

    select employee_id
    into l_employee_id
    from po_action_history
    where object_id = p_document_id
     and object_type_code = p_document_type
     and sequence_num = (select max(sequence_num)
                           from po_action_history
                          where object_id = p_document_id
                            and action_code = 'SUBMIT'
                            and object_type_code = p_document_type);

    END;

  ELSE

    select employee_id
    into l_employee_id
    from po_action_history
    where object_id = p_document_id
     and object_type_code = p_document_type
     and sequence_num = (select max(sequence_num)
                           from po_action_history
                          where object_id = p_document_id
                            and action_code = l_action_code
                            and object_type_code = p_document_type);

    END IF;

   x_progress := ' PO_REQAPPROVAL_ACTION.InsertHistForOwnerApprove employee_id: ' || l_employee_id;

   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype, itemkey, x_progress);
   END IF;

      INSERT into PO_ACTION_HISTORY
             (object_id,
              object_type_code,
              object_sub_type_code,
              sequence_num,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (p_document_id,
              p_document_type,
              p_document_subtype,
              l_sequence_num + 1,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              NULL,
              NULL,
              l_employee_id,
              NULL,
              l_object_rev_num,
              fnd_global.login_id,
              0,
              0,
              0,
              '',
              l_approval_path_id,
              '' );

     commit;

     x_progress := 'PO_REQAPPROVAL_ACTION.InsertHistForOwnerApprove inserted';

   END IF;

   x_progress := 'PO_REQAPPROVAL_ACTION.InsertHistForOwnerApprove end';

   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','ApproveDoc',x_progress || ', ' || sqlerrm);
    raise;

END InsertHistForOwnerApprove;

--
FUNCTION ApproveDoc(itemtype varchar2, itemkey varchar2)
RETURN VARCHAR2
IS

-- <Doc Manager Rewrite 11.5.11 Start>
l_document_type         PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_document_subtype      PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;
l_document_id           NUMBER;
l_note                  PO_ACTION_HISTORY.note%TYPE;
l_approval_path_id      NUMBER;


l_ret_sts      VARCHAR2(1);
l_exc_msg      VARCHAR2(2000);
-- <Doc Manager Rewrite 11.5.11 End>


l_kanban_return_status varchar2(10);
x_progress varchar2(200);

BEGIN

  -- <Doc Manager Rewrite 11.5.11 Start>

  l_document_type    :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_subtype :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');


  l_note               := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

  l_approval_path_id   := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVAL_PATH_ID');


  x_progress := 'ApproveDoc: calling ApproveAutonomous with: '
                 || 'Doc_type= ' || l_document_type
                 || ' Subtype= ' || l_document_subtype
                 || ' Doc_id= ' || to_char(l_document_id);

  IF (g_po_wf_debug = 'Y') THEN
    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  ApproveAutonomous(
     p_document_id       => l_document_id
  ,  p_document_type     => l_document_type
  ,  p_document_subtype  => l_document_subtype
  ,  p_note              => l_note
  ,  p_approval_path_id  => l_approval_path_id
  ,  x_return_status     => l_ret_sts
  ,  x_exception_msg     => l_exc_msg
  );

  -- Approve returns with only 'S' or 'U'
  IF (l_ret_sts = 'S')
  THEN

    /* Keep the AUTHORIZATION_STATUS in sync with database */
    wf_engine.SetItemAttrText ( itemtype   => itemType,
                                itemkey    => itemkey,
                                aname      => 'AUTHORIZATION_STATUS',
                                avalue     => 'APPROVED');

    IF  ((l_document_type IN ('PO','RELEASE') ) OR
        (l_document_type = 'REQUISITION' AND l_document_subtype = 'INTERNAL'))
    THEN

      -- Support for Kanban Execution
      -- When document is approved, update Kanban status to 'IN_PROCESS'

      PO_KANBAN_SV.Update_Card_Status ('IN_PROCESS',
  					      l_document_type,
  					      l_document_id,
					      l_kanban_return_status);

    END IF;

    return('Y');

  ELSE

    x_progress := 'PO_REQAPPROVAL_ACTION.ApproveDoc: ApproveAutonomous returned with: '
                   || l_ret_sts;

    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    doc_mgr_err_num := 3;
    sysadmin_err_msg := l_exc_msg;

    return('F');

  END IF;  -- l_ret_sts = 'S'

  -- <Doc Manager Rewrite 11.5.11 End>

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','ApproveDoc',x_progress);
        raise;

END ApproveDoc;

--
FUNCTION ApproveAndForward(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

-- <Doc Manager Rewrite 11.5.11 Start>
l_document_type         PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_document_subtype      PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;
l_document_id           NUMBER;
l_note                  PO_ACTION_HISTORY.note%TYPE;
l_approval_path_id      NUMBER;
l_forward_to_id         NUMBER;

l_ret_sts      VARCHAR2(1);
l_exc_msg      VARCHAR2(2000);
-- <Doc Manager Rewrite 11.5.11 End>

x_progress varchar2(200);

BEGIN

  -- <Doc Manager Rewrite 11.5.11 Start>

  /* The action FORWARD_DOCUMENT creates a new row in PO_ACTION_HISTORY
  ** with an action_code that is NULL and it sets the status on the
  ** DOCUMENT to 'PRE-APPROVED' (PO_HEADERS, REQs or RELEASES).
  */

  l_document_type    :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_subtype :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');


  l_note            := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

  l_approval_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVAL_PATH_ID');

  l_forward_to_id    := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');


  x_progress := 'ApproveAndForwardDoc: calling ForwardAutonomous  with: ' || 'Doc_type= ' ||
               l_document_type || ' Subtype= ' || l_document_subtype ||
              ' Doc_id= ' || to_char(l_document_id);

  IF (g_po_wf_debug = 'Y') THEN
    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  ForwardAutonomous(
     p_document_id       => l_document_id
  ,  p_document_type     => l_document_type
  ,  p_document_subtype  => l_document_subtype
  ,  p_new_doc_status    => PO_DOCUMENT_ACTION_PVT.g_doc_status_PREAPPROVED
  ,  p_note              => l_note
  ,  p_approval_path_id  => l_approval_path_id
  ,  p_forward_to_id     => l_forward_to_id
  ,  x_return_status     => l_ret_sts
  ,  x_exception_msg     => l_exc_msg
  );


  -- Forward returns with only 'S' or 'U'
  IF (l_ret_sts = 'S') THEN

    /* Keep the AUTHORIZATION_STATUS in sync with database */
    wf_engine.SetItemAttrText ( itemtype   => itemType,
                                itemkey    => itemkey,
                                aname      => 'AUTHORIZATION_STATUS',
                                avalue     => 'PRE-APPROVED');

    return('Y');

  ELSE

    -- fatal exception, l_ret_sts = 'U'

    x_progress := 'PO_REQAPPROVAL_ACTION.ApproveAndForward: ForwardAutonomous returned with: ' || l_ret_sts;
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    doc_mgr_err_num := 3;
    sysadmin_err_msg :=  l_exc_msg;

    return('F');

  END IF;

  -- <Doc Manager Rewrite 11.5.11 End>

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','ApproveAndForward',x_progress);
        raise;

END ApproveAndForward;

--
FUNCTION ForwardDocInProcess(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

-- <Doc Manager Rewrite 11.5.11 Start>

l_document_type         PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_document_subtype      PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;
l_document_id           NUMBER;
l_note                  PO_ACTION_HISTORY.note%TYPE;
l_approval_path_id      NUMBER;
l_forward_to_id         NUMBER;

l_ret_sts      VARCHAR2(1);
l_exc_msg      VARCHAR2(2000);

-- <Doc Manager Rewrite 11.5.11 End>

x_progress varchar2(200);
BEGIN

  -- <Doc Manager Rewrite 11.5.11 Start>

  /* The action FORWARD_DOCUMENT creates a new row in PO_ACTION_HISTORY
  ** with an action_code that is NULL and it sets the status on the
  ** DOCUMENT to 'IN PROCESS' (PO_HEADERS, REQs or RELEASES).
  */

  l_document_type    :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_subtype :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');


  l_note            := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

  l_approval_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVAL_PATH_ID');

  l_forward_to_id    := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');


  x_progress := 'ForwardDocInProcess: calling ForwardAutonomous  with: ' || 'Doc_type= ' ||
               l_document_type || ' Subtype= ' || l_document_subtype ||
              ' Doc_id= ' || to_char(l_document_id);

  IF (g_po_wf_debug = 'Y') THEN
    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  ForwardAutonomous(
     p_document_id       => l_document_id
  ,  p_document_type     => l_document_type
  ,  p_document_subtype  => l_document_subtype
  ,  p_new_doc_status    => PO_DOCUMENT_ACTION_PVT.g_doc_status_INPROCESS
  ,  p_note              => l_note
  ,  p_approval_path_id  => l_approval_path_id
  ,  p_forward_to_id     => l_forward_to_id
  ,  x_return_status     => l_ret_sts
  ,  x_exception_msg     => l_exc_msg
  );

  -- Forward returns with only 'S' or 'U'
  IF (l_ret_sts = 'S') THEN

    /* Keep the AUTHORIZATION_STATUS in sync with database */
    wf_engine.SetItemAttrText ( itemtype   => itemType,
                                itemkey    => itemkey,
                                aname      => 'AUTHORIZATION_STATUS',
                                avalue     => 'IN PROCESS');

    return('Y');

  ELSE

    -- fatal exception, l_ret_sts = 'U'

    x_progress := 'PO_REQAPPROVAL_ACTION.ForwardDocInProcess: ForwardAutonomous returned with: ' || l_ret_sts;
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    doc_mgr_err_num := 3;
    sysadmin_err_msg :=  l_exc_msg;

    return('F');

  END IF;  -- l_ret_sts = 'S';

  -- <Doc Manager Rewrite 11.5.11 End>

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','ForwardDocInProcess',x_progress);
        raise;

END ForwardDocInProcess;

--
FUNCTION ForwardDocPreApproved(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

-- <Doc Manager Rewrite 11.5.11 Start>

l_document_type         PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_document_subtype      PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;
l_document_id           NUMBER;
l_note                  PO_ACTION_HISTORY.note%TYPE;
l_approval_path_id      NUMBER;
l_forward_to_id         NUMBER;

l_ret_sts      VARCHAR2(1);
l_exc_msg      VARCHAR2(2000);

-- <Doc Manager Rewrite 11.5.11 End>

x_progress varchar2(200);

BEGIN

  -- <Doc Manager Rewrite 11.5.11 Start>

  /* The action FORWARD_DOCUMENT creates a new row in PO_ACTION_HISTORY
  ** with an action_code that is NULL and it sets the status on the
  ** DOCUMENT to 'PRE-APPROVED' (PO_HEADERS, REQs or RELEASES).
  */

  l_document_type    :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_subtype :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');


  l_note            := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'NOTE');

  l_approval_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVAL_PATH_ID');

  l_forward_to_id    := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');


  x_progress := 'ForwardDocPreapproved: calling ForwardAutonomous  with: ' || 'Doc_type= ' ||
               l_document_type || ' Subtype= ' || l_document_subtype ||
              ' Doc_id= ' || to_char(l_document_id);

  IF (g_po_wf_debug = 'Y') THEN
    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  ForwardAutonomous(
     p_document_id       => l_document_id
  ,  p_document_type     => l_document_type
  ,  p_document_subtype  => l_document_subtype
  ,  p_new_doc_status    => PO_DOCUMENT_ACTION_PVT.g_doc_status_PREAPPROVED
  ,  p_note              => l_note
  ,  p_approval_path_id  => l_approval_path_id
  ,  p_forward_to_id     => l_forward_to_id
  ,  x_return_status     => l_ret_sts
  ,  x_exception_msg     => l_exc_msg
  );

  -- Forward returns with only 'S' or 'U'
  IF (l_ret_sts = 'S') THEN

    /* Keep the AUTHORIZATION_STATUS in sync with database */
    wf_engine.SetItemAttrText ( itemtype   => itemType,
                                itemkey    => itemkey,
                                aname      => 'AUTHORIZATION_STATUS',
                                avalue     => 'PRE-APPROVED');

    return('Y');

  ELSE

    -- fatal exception, l_ret_sts = 'U'

    x_progress := 'PO_REQAPPROVAL_ACTION.ForwardDocPreApproved: ForwardAutonomous returned with: ' || l_ret_sts;
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    doc_mgr_err_num := 3;
    sysadmin_err_msg :=  l_exc_msg;

    return('F');

  END IF;

  -- <Doc Manager Rewrite 11.5.11 End>

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','ForwardDocPreApproved',x_progress);
        raise;


END ForwardDocPreApproved;

--
FUNCTION RejectDoc(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

-- <Doc Manager Rewrite 11.5.11 Start>
l_document_type         PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_document_subtype      PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;
l_document_id           NUMBER;
l_note                  PO_ACTION_HISTORY.note%TYPE;
l_approval_path_id      NUMBER;

l_ret_sts           VARCHAR2(1);
l_exc_msg           VARCHAR2(2000);
l_ret_code          VARCHAR2(25);
l_online_report_id  NUMBER;
-- <Doc Manager Rewrite 11.5.11 End>

x_progress varchar2(200);
l_caller   varchar2(25);-- Bug 14742082 changed size from 20 to 25


BEGIN

  -- <Doc Manager Rewrite 11.5.11 Start>

  l_caller :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'INTERFACE_SOURCE_CODE');


  l_document_type    :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'DOCUMENT_TYPE');

  l_document_subtype :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'DOCUMENT_SUBTYPE');

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'DOCUMENT_ID');


  l_note            :=wf_engine.GetItemAttrText (itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'NOTE');

  l_approval_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'APPROVAL_PATH_ID');


  -- On reject, the Pro*C code was hard coded to set the status
  -- of the document to rejected.  Hence, the following code was
  -- meaningless; commenting it out.
  --
  -- If the Requisition comes from Web Reqs, then when the approver
  -- rejects it, we set the status to 'CANCELLED'. If it comes from
  -- any other system, then set it to REJECTED.
  --
  -- IF  l_caller = 'ICX' THEN
  --
  --    l_reject_status  := 'CANCELLED';
  --
  --  ELSE
  --
  --    l_reject_status  := 'REJECTED';
  --
  --  END IF;

  x_progress := 'RejectDoc: calling RejectAutonomous  with: ' || 'Doc_type= ' ||
                          l_document_type || ' Subtype= ' || l_document_subtype ||
                          ' Doc_id= ' || to_char(l_document_id);

  IF (g_po_wf_debug = 'Y') THEN
    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  RejectAutonomous(
     p_document_id       => l_document_id
  ,  p_document_type     => l_document_type
  ,  p_document_subtype  => l_document_subtype
  ,  p_note              => l_note
  ,  p_approval_path_id  => l_approval_path_id
  ,  x_return_status     => l_ret_sts
  ,  x_return_code       => l_ret_code
  ,  x_exception_msg     => l_exc_msg
  ,  x_online_report_id  => l_online_report_id
  );

  -- Reject returns with 'S' or 'U'
  IF (l_ret_sts = 'S')
  THEN

    -- If reject succeeded, then l_ret_code is null or 'A' or 'S'

    IF ((l_ret_code IS NULL) OR (l_ret_code IN ('A', 'S')))
    THEN

        -- Reject Succeeded

        /* Keep the AUTHORIZATION_STATUS in sync with database */
        wf_engine.SetItemAttrText ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'AUTHORIZATION_STATUS',
                                   avalue     => 'REJECTED');

        return('Y');

    ELSE

        -- Reject Failed

        x_progress := 'PO_REQAPPROVAL_ACTION.RejectDoc: Returned_code= ' ||
              l_ret_code ;
        IF (g_po_wf_debug = 'Y') THEN
           /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
        END IF;

       return('N');

    END IF;  -- l_ret_code IS NULL

  ELSE

    -- Fatal Error: l_ret_sts := 'U';

    x_progress := 'PO_REQAPPROVAL_ACTION.RejectDoc: RejectAutonomous returned with: ' || l_ret_sts;

    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;


    doc_mgr_err_num := 3;
    sysadmin_err_msg := l_exc_msg ;

    return('F');

  END IF;  -- If l_ret_sts = 'S'

  -- <Doc Manager Rewrite 11.5.11 End>

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','RejectDoc',x_progress);
        raise;

END RejectDoc;

--
FUNCTION VerifyAuthority(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

-- <Doc Manager Rewrite 11.5.11 Start>

l_document_type         PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_document_subtype      PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;
l_document_id           NUMBER;
l_employee_id           NUMBER;

l_ret_sts      VARCHAR2(1);
l_exc_msg      VARCHAR2(2000);
l_fail_msg     VARCHAR2(2000);
l_ret_code     VARCHAR2(25);

-- <Doc Manager Rewrite 11.5.11 End>

x_progress varchar2(200);
BEGIN

  -- <Doc Manager Rewrite 11.5.11 Start>

  l_document_type    :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_subtype :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  l_employee_id      := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_EMPID');

  x_progress := 'VerifyAuthority: calling verify_authority  with: ' || 'Doc_type= ' ||
                 l_document_type || ' Subtype= ' || l_document_subtype ||
                ' Doc_id= ' || to_char(l_document_id);

  IF (g_po_wf_debug = 'Y') THEN
    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  PO_DOCUMENT_ACTION_PVT.verify_authority(
     p_document_id        =>  l_document_id
  ,  p_document_type      =>  l_document_type
  ,  p_document_subtype   =>  l_document_subtype
  ,  p_employee_id        =>  l_employee_id
  ,  x_return_status      =>  l_ret_sts
  ,  x_return_code        =>  l_ret_code
  ,  x_exception_msg      =>  l_exc_msg
  ,  x_auth_failed_msg    =>  l_fail_msg
  );

  -- verify_authority sets return status to 'S' or 'U'
  IF (l_ret_sts = 'S')
  THEN

     /*  If authority check passed, then l_ret_code should be null
     **  otherwise it should be 'AUTHORIZATION_FAILED'.
     */
     IF ( l_ret_code is NULL )
     THEN
       return('Y');
     ELSE
       return('N');
     END IF;

  ELSE

    -- fatal exceptionl; l_ret_sts := 'U';

    x_progress := 'PO_REQAPPROVAL_ACTION.VerifyAuthority: action call returned with: ' || l_ret_sts;
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    doc_mgr_err_num := 3;
    sysadmin_err_msg :=  l_exc_msg;

    return('F');

  END IF;  -- l_ret_sts = 'S'

  -- <Doc Manager Rewrite 11.5.11 End>

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','VerifyAuthority',x_progress);
        raise;

END VerifyAuthority;


--
FUNCTION OpenDocumentState(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

-- <Doc Manager Rewrite 11.5.11 Start>
l_document_type         PO_DOCUMENT_TYPES_ALL.document_type_code%TYPE;
l_document_subtype      PO_DOCUMENT_TYPES_ALL.document_subtype%TYPE;
l_document_id           NUMBER;

l_ret_code     VARCHAR2(25);
l_ret_sts      VARCHAR2(1);
l_exc_msg      VARCHAR2(2000);
-- <Doc Manager Rewrite 11.5.11 End>

x_progress varchar2(200);

BEGIN

  -- <Doc Manager Rewrite 11.5.11 Start>

  l_document_type    :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'DOCUMENT_TYPE');

  l_document_subtype :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'DOCUMENT_SUBTYPE');

  l_document_id      :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'DOCUMENT_ID');

  x_progress := 'OpenDocumentState: calling autoupdatecloseautonomous  with: ' || 'Doc_type= ' ||
  l_document_type || ' Subtype= ' || l_document_subtype ||
  ' Doc_id= ' || to_char(l_document_id);

   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;

  AutoUpdateCloseAutonomous(
     p_document_id      => l_document_id
  ,  p_document_type    => l_document_type
  ,  p_document_subtype => l_document_subtype
  ,  x_return_status    => l_ret_sts
  ,  x_exception_msg    => l_exc_msg
  ,  x_return_code      => l_ret_code
  );

  IF (l_ret_sts = 'S')
  THEN

    IF (l_ret_code IS NULL)
    THEN

      return('Y');

    ELSE

      x_progress := 'PO_REQAPPROVAL_ACTION.OpenDocumentState: Returned_code= ' ||
              l_ret_code ;
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      return('N');

    END IF;  -- if l_ret_code IS NULL

  ELSE

    -- Fatal Error: l_ret_sts := 'U';

    /* something went wrong with Doc Action. Send notification to Sys Admin.
    ** The error message is kept in Item Attribute SYSADMIN_ERROR_MSG */

    x_progress := 'PO_REQAPPROVAL_ACTION.OpenDocumentState: auto_close_update_autonomous returned with: ' ||
               l_ret_sts;
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    END IF;

    doc_mgr_err_num := 3;
    sysadmin_err_msg := l_exc_msg;

    return('F');

  END IF;  -- IF l_ret_sts = 'S'

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','OpenDocumentState',x_progress);
        raise;

END OpenDocumentState;

--

--
/* Bug# 2234341 */

-- <ENCUMBRANCE FPJ START>
-- Modify the procedure to call FPJ Encumbrance

FUNCTION ReserveDoc(itemtype VARCHAR2, itemkey VARCHAR2,
                    p_override_funds VARCHAR2 default 'N')
RETURN VARCHAR2 is

-- BUG 6334215
-- Approval workflow was failing in the RESERVE_DOCUMENT
-- process. Approval failed because x_progress which is defined as
-- varchar2(200) was unable to hold the debug message

x_progress         varchar2(1000);

l_doc_type         PO_DOCUMENT_TYPES.document_type_code%TYPE;
l_doc_subtype      PO_DOCUMENT_TYPES.document_subtype%TYPE;
l_doc_id	   NUMBER;
l_employee_id      NUMBER;
l_po_return_code   VARCHAR2(10);
l_online_report_id NUMBER;
l_warning_mesg     VARCHAR2(2000) := NULL;
l_return	   VARCHAR2(1) := 'N';
l_is_ame_used   varchar2(1) := 'N';
BEGIN

  x_progress := 'ReserveDoc 001';
  IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  l_doc_type :=  wf_engine.GetItemAttrText(
                                         itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_doc_subtype :=  wf_engine.GetItemAttrText(
                                         itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  x_progress := 'ReserveDoc 010: '|| 'Doc Type = '|| l_doc_type ||
                 ' Doc Subtype = '|| l_doc_subtype;
  IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- If the Document type is Contract Agreement, then don't reserve

  IF l_doc_subtype = 'CONTRACT' THEN

     return('Y');

  END IF;

  l_doc_id :=  wf_engine.GetItemAttrNumber(
                                         itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

  x_progress := 'ReserveDoc 020: ' || 'Doc Header Id = ' || to_char(l_doc_id);
  IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  IF (l_doc_type = 'REQUISITION') THEN

    l_is_ame_used := wf_engine.GetItemAttrText(
                                         itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'IS_AME_APPROVAL');



   IF(l_is_ame_used ='Y') THEN

        l_employee_id := wf_engine.GetItemAttrNumber(
                                         itemtype => itemtype,
                                         itemkey  => itemkey,
	               aname    => 'APPROVER_EMPID');

   ELSE

    l_employee_id := wf_engine.GetItemAttrNumber(
                                         itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'RESPONDER_ID');

   END IF;

  END IF;

  IF (l_employee_id IS NULL) THEN
     l_employee_id := wf_engine.GetItemAttrNumber(
                                           itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'APPROVER_EMPID');
  END IF;

  x_progress := 'ReserveDoc 025: ' || 'l_is_ame_used  = ' ||l_is_ame_used || ' l_employee_id ='|| to_char(l_employee_id);
  IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;
  -- Call the ReserveAutonomous
  ReserveAutonomous(
   p_doc_type             => l_doc_type
,  p_doc_subtype          => l_doc_subtype
,  p_doc_id               => l_doc_id
,  p_override_funds       => p_override_funds
,  p_employee_id          => l_employee_id
,  x_po_return_code       => l_po_return_code
,  x_online_report_id     => l_online_report_id
);

  x_progress := 'ReserveDoc 030: ReserveAutonomous return code = ' ||
                l_po_return_code;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  IF (l_po_return_code = PO_DOCUMENT_FUNDS_PVT.g_return_SUCCESS) THEN

     l_return := 'Y';

  ELSIF (l_po_return_code = PO_DOCUMENT_FUNDS_PVT.g_return_WARNING) THEN

     -- Also set the online report id for warnings
     wf_engine.SetItemAttrNumber(
                  itemtype   => itemType,
                  itemkey    => itemkey,
                  aname      => 'ONLINE_REPORT_ID',
                  avalue     =>  l_online_report_id);


     -- Get warning message off of stack.
     -- Bug 3518326: Since we pass l_warning_mesg directly
     -- into the 'ADVISORY WARNING' wf attribute below, we
     -- have to make sure that we decode it.  Hence, pass
     -- p_encoded = FND_API.G_FALSE to FND_MSG_PUB.get().

     l_warning_mesg := FND_MSG_PUB.get(p_encoded => FND_API.G_FALSE);

     -- Set the warning message to workflow attribute ADVISORY_WARNING.
     -- If there is no message then it will be set to null
     -- Bug 3536831: Call new get_advisory_warning procedure so that the
     -- contents of the online report are also shown as part of the warning
     -- in the notification to preparer.  This is a new procedure.
     -- Read note below about why the setting of this attribute was moved here from below.

     x_progress := 'ReserveDoc 100 Advisory Message: '||l_warning_mesg;
     IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

     get_advisory_warning(  itemtype              =>  itemType
                          , itemkey               =>  itemkey
                          , p_online_report_id    =>  l_online_report_id
                          , p_warning_header_text =>  l_warning_mesg
                          );

     l_return := 'Y';

  ELSE

     -- Get the online_report_id (to be used to populate the notification
     wf_engine.SetItemAttrNumber(
                  itemtype   => itemType,
                  itemkey    => itemkey,
                  aname      => 'ONLINE_REPORT_ID',
                  avalue     =>  l_online_report_id);

     -- Get the text of the online_report and store in workflow item
     -- attribute
     get_online_report_text( itemtype, itemkey,l_online_report_id);

     l_return := 'N';

  END IF; -- IF l_po_return_code

  -- Bug 3536831: The setting of the advisory_warning attribute is removed
  -- from here, and moved above.  This attribute is now set only if there
  -- actually was a warning.  Previously, the attribute would be set to NULL
  -- if there wasn't a warning.  This should not changed by removing the
  -- code here, as now, the attribute is not set, and will default to NULL.
  -- The move was made because otherwise, the new implementation would put
  -- online report text information into advisory_warning even if there was
  -- no warning.

  x_progress := 'ReserveDoc 999';
  IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  return(l_return);

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','ReserveDoc',x_progress);

    /*
	Bug 9886447
	When exception is raised in function ReserveDoc it does not return proper
	value and hence, parent function i.e. Reserve_doc does not get correct value
	to return. Hence, putting return in exception block so that Reserve_doc function
	will have proper value to return.
	If Reserve_doc does not get proper value to return, approval work flow gets stuck.
    */

    return(l_return);

    raise;

END ReserveDoc;

-- <ENCUMBRANCE FPJ END>

--


PROCEDURE get_online_report_text(itemtype VARCHAR2, itemkey VARCHAR2, p_online_report_id NUMBER) is

x_progress   varchar2(400);

BEGIN

  -- Bug 3536831: get_online_report_text is refactored to call new set_report_text_attr.

  x_progress := 'PO_REQAPPROVAL_ACTION.get_online_report_text.010.ON_LINE_REPORT_ID= '
                || to_char(p_online_report_id);


  set_report_text_attr(  itemtype => itemtype
                       , itemkey => itemkey
                       , p_online_report_id => p_online_report_id
                       , p_attribute => 'ONLINE_REPORT_TEXT'
                      );

  x_progress := 'PO_REQAPPROVAL_ACTION.get_online_report_text.020.ON_LINE_REPORT_ID= '
                || to_char(p_online_report_id);

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','get_online_report_text',x_progress);
        raise;
END get_online_report_text;


-- <Start Bug 3536831: Added get_advisory_warning and set_report_text_attr>

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_advisory_warning
--Function:
--  Sets the workflow attribute "ADVISORY_WARNING" to the text of the online
--  report provided.  It is valid for this attribute to be set to NULL.
--Parameters:
--IN:
--itemtype
--  Workflow itemtype.  This should be called only from the PO Approval workflow.
--itemkey
--  Workflow itemkey.  The key for the particular PO Approval workflow process
--  that the warning was generated in.
--p_online_report_id
--  The id of the report from which to copy the text.  This may be NULL.
--p_warning_header_text
--  A header string that should be appended before the text of the online report.
--  This may be NULL.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_advisory_warning(
  itemtype                          IN             VARCHAR2
, itemkey                           IN             VARCHAR2
, p_online_report_id                IN             NUMBER
, p_warning_header_text             IN             VARCHAR2
)
IS

x_progress      VARCHAR2(400);
l_document_type po_document_types_all.document_type_code%TYPE;--<BUG 7361295>

BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.get_advisory_warning.010.ON_LINE_REPORT_ID= '
                || to_char(p_online_report_id);


  set_report_text_attr(  itemtype => itemtype
                       , itemkey => itemkey
                       , p_online_report_id => p_online_report_id
                       , p_attribute => 'ADVISORY_WARNING'
                       , p_header_text => p_warning_header_text
                      );

  -- <BUG 7361295>
  l_document_type := wf_engine.GetItemAttrText(itemtype   =>  itemType,
			                       itemkey    =>  itemkey,
			                       aname      =>  'DOCUMENT_TYPE');


  IF (l_document_type = 'REQUISITION') THEN  -- <BUG 7361295>
	-- Set the workflow attribute Advisory Warning Check to 'Y'
	PO_WF_UTIL_PKG.SetItemAttrText(itemtype   =>  itemType,
	                               itemkey    =>  itemkey,
			               aname      =>  'ADVISORY_WARNING_CHECK',
			               avalue     =>  'Y');
  END IF;

  x_progress := 'PO_REQAPPROVAL_ACTION.get_advisory_warning.020.ON_LINE_REPORT_ID= '
                || to_char(p_online_report_id);

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','get_advisory_warning',x_progress);
        raise;
END get_advisory_warning;


-------------------------------------------------------------------------------
--Start of Comments
--Name: set_report_text_attr
--Function:
--  Generic procedure to copy the text of an online report into a workflow attribute.
--  Reads each line in the online report, and concatenates them together.
--  The string that is copied into the attribute is truncated to 2000 characters.
--Parameters:
--IN:
--itemtype
--  Workflow itemtype. Make sure that the attribute that the text will be copied into
--  is defined for this particular workflow.
--itemkey
--  Workflow itemkey.  The key for the particular workflow process for which the
--  the attribute will be set.
--p_online_report_id
--  The id of the report from which to copy the text.  This may be NULL.
--p_attribute
--  The workflow attribute which should be set to the header + report text.
--p_warning_header_text
--  A header string that should be appended before the text of the online report.
--  This may be NULL, and will default to NULL.
--  This paramater should be <= 2000 characters long.
--  Any characters over the 2000 limit will be truncated.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE set_report_text_attr(
  itemtype                          IN             VARCHAR2
, itemkey                           IN             VARCHAR2
, p_online_report_id                IN             NUMBER
, p_attribute                       IN             VARCHAR2
, p_header_text                     IN             VARCHAR2   DEFAULT NULL
)
IS

TYPE g_report_list_type       IS TABLE OF VARCHAR2(2000);

l_report_text_lines          g_report_list_type;
l_attribute_text             VARCHAR2(4000);
len_att_text                 NUMBER  := 0;
i                            NUMBER;

x_progress                   VARCHAR2(400);

BEGIN


  x_progress := 'PO_REQAPPROVAL_ACTION.set_report_attr_text.010.ON_LINE_REPORT_ID= '
                || to_char(p_online_report_id);


  -- Add header text to beginning of attribute string.
  IF (p_header_text IS NOT NULL)
  THEN
    l_attribute_text := substr(p_header_text || ' ', 1, 2000);
    len_att_text := length(l_attribute_text);
  END IF;

  -- Bulk collect text lines for the online report in question.
  SELECT substr(text_line, 1, 2000)
  BULK COLLECT INTO l_report_text_lines
  FROM po_online_report_text
  WHERE online_report_id = p_online_report_id
  ORDER BY sequence;

  x_progress := 'PO_REQAPPROVAL_ACTION.set_report_attr_text.020.ON_LINE_REPORT_ID= '
                || to_char(p_online_report_id);

  -- Loop through the plsql table, and concatenate each of the lines.
  -- Exit the loop if we run out of lines, or the string exceeds 2000 characters.
  -- Overflow is avoided since l_attribute_text is 4000 char.
  i := l_report_text_lines.FIRST;
  WHILE ((i is NOT NULL) and (len_att_text < 2000))
  LOOP
    l_attribute_text := l_attribute_text || l_report_text_lines(i) || fnd_global.local_chr(10) ; --Bug 10625022
    len_att_text := length(l_attribute_text);
    i := l_report_text_lines.NEXT(i);
  END LOOP;

  -- Set the workflow attribute to the derived attribute string.
  wf_engine.SetItemAttrText (
                              itemtype   =>  itemType,
                              itemkey    =>  itemkey,
                              aname      =>  p_attribute,
                              avalue     =>  substr(l_attribute_text, 1, 2000)
                            );

  x_progress := 'PO_REQAPPROVAL_ACTION.set_report_attr_text.030.ON_LINE_REPORT_ID= '
                || to_char(p_online_report_id);

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','set_report_attr_text',x_progress);
        raise;
END set_report_text_attr;

-- <END Bug 3536831>



--
PROCEDURE set_doc_mgr_context (itemtype VARCHAR2, itemkey VARCHAR2) is

l_user_id            number;
l_responsibility_id  number;
l_application_id     number;

x_progress  varchar2(200);

BEGIN

  -- Bug 4290541, replaced call to set apps init context with
  -- po reqapproval init1 set doc mgr context
  --
  po_reqapproval_init1.set_doc_mgr_context(itemtype,itemkey);

  x_progress := 'PO_REQAPPROVAL_ACTION.set_doc_mgr_context. USER_ID= ' || to_char(l_user_id)
                || ' APPLICATION_ID= ' || to_char(l_application_id) ||
                   'RESPONSIBILITY_ID= ' || to_char(l_responsibility_id);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','set_doc_mgr_context',x_progress);
        raise;


END set_doc_mgr_context;

PROCEDURE set_responder_doc_mgr_context (itemtype VARCHAR2, itemkey VARCHAR2) is

l_user_id            number;
l_responsibility_id  number;
l_application_id     number;

x_progress  varchar2(200);

-- Bug 4290541 Start
X_User_Id            NUMBER;
X_Responsibility_Id  NUMBER;
X_Application_Id     NUMBER;
-- Bug 4290541 End

BEGIN

   -- Context Setting Revamp
   -- Bug 4290541 Start
   -- FND_PROFILE.GET('USER_ID',X_USER_ID);
   --FND_PROFILE.GET('RESP_ID',X_RESPONSIBILITY_ID);
   --FND_PROFILE.GET('RESP_APPL_ID',X_APPLICATION_ID);
   -- Bug 4290541 End

   X_USER_ID := fnd_global.user_id;
   X_RESPONSIBILITY_ID := fnd_global.resp_id;
   X_APPLICATION_ID := fnd_global.resp_appl_id;


    IF (X_USER_ID = -1) THEN
        X_USER_ID := NULL;
    END IF;

    IF (X_RESPONSIBILITY_ID = -1) THEN
        X_RESPONSIBILITY_ID := NULL;
    END IF;

    IF (X_APPLICATION_ID = -1) THEN
        X_APPLICATION_ID := NULL;
    END IF;

   l_user_id := PO_WF_UTIL_PKG.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey          => itemkey,
                                      aname            => 'RESPONDER_USER_ID');
   --
   l_application_id := PO_WF_UTIL_PKG.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'RESPONDER_APPL_ID');
   --
   l_responsibility_id := PO_WF_UTIL_PKG.GetItemAttrNumber ( itemtype => itemtype,
                                      itemkey         => itemkey,
                                      aname           => 'RESPONDER_RESP_ID');

   /* Bug# 2626935: kagarwal
   ** Desc: If the application context for responder is not set or set to -1
   ** then call the set_doc_mgr_context.
   */

   IF ((l_user_id is NULL) OR (l_user_id = -1) OR
       (l_application_id is NULL) OR (l_application_id = -1) OR
       (l_responsibility_id is NULL) OR (l_responsibility_id = -1)) THEN

   	set_doc_mgr_context(itemtype, itemkey);
   ELSE
   	/* Set the context for the doc manager */
       -- Bug 4290541 Start
       IF X_User_Id IS NOT NULL THEN
          FND_GLOBAL.APPS_INITIALIZE (X_User_Id, L_Responsibility_Id, L_Application_Id);
       ELSE
          FND_GLOBAL.APPS_INITIALIZE (L_User_Id, L_Responsibility_Id, L_Application_Id);
       END IF;
    -- Bug 4290541 End
   END IF;

  x_progress := 'PO_REQAPPROVAL_ACTION.set_responder_doc_mgr_context. USER_ID= ' || to_char(l_user_id)
                || ' APPLICATION_ID= ' || to_char(l_application_id) ||
                   'RESPONSIBILITY_ID= ' || to_char(l_responsibility_id);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_ACTION','set_responder_doc_mgr_context',x_progress);
        raise;


END set_responder_doc_mgr_context;

/* Bug# 2234341: kagarwal
** Desc: Added a new wf api Reserve_doc_Override(...) for overriding
** funds reservation, if the approve responds to the 'Reservation failure'
** Notification with result 'Try Override'
*/

procedure Reserve_doc_Override( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) is
x_progress  varchar2(100);
x_resultout varchar2(30);

l_responder_id number;
l_doc_type varchar2(30);

l_doc_mgr_return_val  varchar2(1);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);
doc_manager_exception exception;

BEGIN

  x_progress := 'PO_REQAPPROVAL_ACTION.Reserve_doc_Override: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_doc_type :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'DOCUMENT_TYPE');


  l_responder_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'RESPONDER_USER_ID');

  -- Context Setting revamp
  -- if (l_responder_id is null) then

    /* Set the Doc manager context */
  --  set_doc_mgr_context(itemtype, itemkey);

  -- else

    /* Set the Doc manager context based on responder */
  --  set_responder_doc_mgr_context(itemtype, itemkey);

  -- end if;

  /* Bug# 2234341: kagarwal
  ** Desc: Always pass override_funds parameter as 'Y'
  */

  l_doc_mgr_return_val := ReserveDoc(itemtype, itemkey, 'Y');

  x_progress := 'PO_REQAPPROVAL_ACTION.Reserve_doc_Override 10. RESULT= ' || x_resultout;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

-- <ENCUMBRANCE FPJ START>
-- Commenting the Doc manager Handling

--  If l_doc_mgr_return_val = 'F' then
--     raise doc_manager_exception;
--  End if;

-- <ENCUMBRANCE FPJ END>

  resultout := wf_engine.eng_completed || ':' ||  l_doc_mgr_return_val;
  x_resultout := l_doc_mgr_return_val;

  x_progress := 'PO_REQAPPROVAL_ACTION.Reserve_doc_Override 99';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION
--  WHEN doc_manager_exception THEN
--        raise;
  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(
                            itemType, itemkey);
    WF_CORE.context('PO_REQAPPROVAL_ACTION', 'Reserve_doc_Override',
                     itemtype, itemkey, x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey,
                         l_preparer_user_name, l_doc_string, sqlerrm,
		         'PO_REQAPPROVAL_ACTION.RESERVE_DOC');
    RAISE;
END Reserve_doc_Override;

--

-- <ENCUMBRANCE FPJ START>
------------------------------------------------------------------------------
--Start of Comments
--Name: ReserveAutonomous
--Pre-reqs:
-- None.
--Modifies:
--  Creates encumbrance entries in the gl_bc_packets table
--  Adds distribution-specific transaction information into the
--  po_online_report_text table
--Locks:
--  None.
--Function:
--  Calls PO_DOCUMENT_FUNDS_PVT.do_reserve as an autonomous call
--Parameters:
--IN:
--p_doc_type
--  Differentiates between the doc being a REQ, PA, PO, or RELEASE,
--  which is used to identify the tables to look at (PO vs. Req)
--  and the join conditions
--p_doc_subtype
--  Differentiates between the subtypes of documents
--  REQ: NULL
--  PO: STANDARD, PLANNED
--  PA: CONTRACT, BLANKET
--  RELEASE: SCHEDULED, BLANKET
--p_doc_id
--  document header id
--p_override_funds
--  Indicates whether funds override capability can be used if needed, to make a
--  transaction succeed.
--p_employee_id
--  Employee Id of the user taking the action
--OUT:
--x_po_return_code
--  Indicates whether PO is classifying this transaction as an
--  Error/Warning/Partial Success/Success
--x_online_report_id
--  Unique id into po_online_report_text rows that store distribution specific
--  reporting information for a specific encumbrance transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ReserveAutonomous(
   p_doc_type                       IN             VARCHAR2
,  p_doc_subtype                    IN             VARCHAR2
,  p_doc_id                         IN             NUMBER
,  p_override_funds                 IN             VARCHAR2
,  p_employee_id                    IN             NUMBER
,  x_po_return_code                 OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
) IS

pragma AUTONOMOUS_TRANSACTION;

l_api_name              CONSTANT varchar2(30) := 'ReserveAutonomous';
l_progress              VARCHAR2(3);
p_return_status         VARCHAR2(1);

BEGIN

SAVEPOINT ReserveAutonomous_SP;

l_progress := '000';

  -- Call the do_reserve API
  PO_DOCUMENT_FUNDS_PVT.do_reserve(
   x_return_status        => p_return_status
,  p_doc_type             => p_doc_type
,  p_doc_subtype          => p_doc_subtype
,  p_doc_level            => PO_DOCUMENT_FUNDS_PVT.g_doc_level_HEADER
,  p_doc_level_id         => p_doc_id
,  p_use_enc_gt_flag      => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
,  p_prevent_partial_flag => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
--<PDOI Enhancement Bug#17063664> No need to do all valildations again
,  p_validate_document    => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO
,  p_override_funds       => p_override_funds
,  p_employee_id          => p_employee_id
,  x_po_return_code       => x_po_return_code
,  x_online_report_id     => x_online_report_id
);

l_progress := '010';

IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '100';

COMMIT;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO ReserveAutonomous_SP;
   /* Bug 3293107: removed to_char() around l_progress */
   wf_core.context('PO_REQAPPROVAL_ACTION','ReserveAutonomous',
                    l_progress);

   x_po_return_code := PO_DOCUMENT_FUNDS_PVT.g_return_FATAL; /* Bug 9886447 */

WHEN OTHERS THEN
   ROLLBACK TO ReserveAutonomous_SP;
   /* Bug 3293107: removed to_char() around l_progress */
   wf_core.context('PO_REQAPPROVAL_ACTION','ReserveAutonomous',
                    l_progress);
   RAISE;

END ReserveAutonomous;



-- <Doc Manager Rewrite 11.5.11 Start>

PROCEDURE ApproveAutonomous(
   p_document_id       IN NUMBER
,  p_document_type     IN VARCHAR2
,  p_document_subtype  IN VARCHAR2
,  p_note              IN VARCHAR2
,  p_approval_path_id  IN NUMBER
,  x_return_status     OUT NOCOPY VARCHAR2
,  x_exception_msg     OUT NOCOPY VARCHAR2
)
IS
pragma AUTONOMOUS_TRANSACTION;

d_progress       NUMBER;

BEGIN

  d_progress := 10;

  PO_DOCUMENT_ACTION_PVT.do_approve(
     p_document_id       => p_document_id
  ,  p_document_type     => p_document_type
  ,  p_document_subtype  => p_document_subtype
  ,  p_note              => p_note
  ,  p_approval_path_id  => p_approval_path_id
  ,  x_return_status     => x_return_status
  ,  x_exception_msg     => x_exception_msg
  );

  d_progress := 20;

  IF (x_return_status = 'S') THEN

    COMMIT;

  ELSE

    ROLLBACK;

  END IF;

EXCEPTION
  WHEN others THEN
    ROLLBACK;
    wf_core.context('PO_REQAPPROVAL_ACTION', 'ApproveAutonomous', to_char(d_progress));
    x_return_status := 'U';

END ApproveAutonomous;

PROCEDURE RejectAutonomous(
   p_document_id       IN NUMBER
,  p_document_type     IN VARCHAR2
,  p_document_subtype  IN VARCHAR2
,  p_note              IN VARCHAR2
,  p_approval_path_id  IN NUMBER
,  x_return_status     OUT NOCOPY VARCHAR2
,  x_return_code       OUT NOCOPY VARCHAR2
,  x_exception_msg     OUT NOCOPY VARCHAR2
,  x_online_report_id  OUT NOCOPY NUMBER
)
IS
pragma AUTONOMOUS_TRANSACTION;

d_progress       NUMBER;

BEGIN

  d_progress := 10;

  PO_DOCUMENT_ACTION_PVT.do_reject(
     p_document_id       => p_document_id
  ,  p_document_type     => p_document_type
  ,  p_document_subtype  => p_document_subtype
  ,  p_note              => p_note
  ,  p_approval_path_id  => p_approval_path_id
  ,  x_return_status     => x_return_status
  ,  x_return_code       => x_return_code
  ,  x_exception_msg     => x_exception_msg
  ,  x_online_report_id  => x_online_report_id
  );

  d_progress := 20;

  IF (x_return_status = 'S') THEN

    COMMIT;

  ELSE

    ROLLBACK;

  END IF;

EXCEPTION
  WHEN others THEN
    ROLLBACK;
    wf_core.context('PO_REQAPPROVAL_ACTION', 'RejectAutonomous', to_char(d_progress));
    x_return_status := 'U';
END RejectAutonomous;


PROCEDURE ForwardAutonomous(
   p_document_id       IN NUMBER
,  p_document_type     IN VARCHAR2
,  p_document_subtype  IN VARCHAR2
,  p_new_doc_status    IN VARCHAR2
,  p_note              IN VARCHAR2
,  p_approval_path_id  IN NUMBER
,  p_forward_to_id     IN NUMBER
,  x_return_status     OUT NOCOPY VARCHAR2
,  x_exception_msg     OUT NOCOPY VARCHAR2
)
IS
pragma AUTONOMOUS_TRANSACTION;

d_progress       NUMBER;

BEGIN

  d_progress := 10;

  PO_DOCUMENT_ACTION_PVT.do_forward(
     p_document_id       => p_document_id
  ,  p_document_type     => p_document_type
  ,  p_document_subtype  => p_document_subtype
  ,  p_new_doc_status    => p_new_doc_status
  ,  p_note              => p_note
  ,  p_approval_path_id  => p_approval_path_id
  ,  p_forward_to_id     => p_forward_to_id
  ,  x_return_status     => x_return_status
  ,  x_exception_msg     => x_exception_msg
  );

  d_progress := 20;

  IF (x_return_status = 'S') THEN

    COMMIT;

  ELSE

    ROLLBACK;

  END IF;

EXCEPTION
  WHEN others THEN
    ROLLBACK;
    wf_core.context('PO_REQAPPROVAL_ACTION', 'ForwardAutonomous', to_char(d_progress));
    x_return_status := 'U';

END ForwardAutonomous;

PROCEDURE AutoUpdateCloseAutonomous(
   p_document_id       IN NUMBER
,  p_document_type     IN VARCHAR2
,  p_document_subtype  IN VARCHAR2
,  x_return_status     OUT NOCOPY VARCHAR2
,  x_exception_msg     OUT NOCOPY VARCHAR2
,  x_return_code       OUT NOCOPY VARCHAR2
)
IS
pragma AUTONOMOUS_TRANSACTION;

d_progress       NUMBER;

BEGIN

  d_progress := 10;

  PO_DOCUMENT_ACTION_PVT.auto_update_close_state(
     p_document_id       => p_document_id
  ,  p_document_type     => p_document_type
  ,  p_document_subtype  => p_document_subtype
  ,  p_line_id           => NULL
  ,  p_shipment_id       => NULL
  ,  p_calling_mode      => 'PO'
  ,  p_called_from_conc  => FALSE
  ,  x_return_status     => x_return_status
  ,  x_exception_msg     => x_exception_msg
  ,  x_return_code       => x_return_code
  );

  d_progress := 20;

  IF (x_return_status = 'S') THEN

    COMMIT;

  ELSE

    ROLLBACK;

  END IF;

EXCEPTION
  WHEN others THEN
    ROLLBACK;
    wf_core.context('PO_REQAPPROVAL_ACTION', 'AutoUpdateCloseAutonomous', to_char(d_progress));
    x_return_status := 'U';

END AutoUpdateCloseAutonomous;
-- <Doc Manager Rewrite 11.5.11 End>

------------------------------------------------------------------------------
--Start of Comments
--Name: po_submission_check_autonomous
--Function:
--  Calls PO_DOCUMENT_CHECKS_GRP.po_submission_check in an
--  autonomous transaction.
--  The autonomous_transaction is required due to the use of the
--  submission check global temp tables, as submission check is also
--  called later in the workflow as part of doc reservation,
--  which must be an autonomous transaction due to its commit.
--  Without this autonomous transaction, the following error is raised:
--  ORA-14450: attempt to access a transactional temp table already in use
--Notes:
--  See PO_DOCUMENT_CHECKS_GRP.po_submission_check for a description
--  of the parameters.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE po_submission_check_autonomous(
   p_document_type                  IN             VARCHAR2
,  p_document_subtype               IN             VARCHAR2
,  p_document_id                    IN             NUMBER
,  p_check_asl                      IN             BOOLEAN
,  x_return_status                  OUT NOCOPY     VARCHAR2
,  x_sub_check_status               OUT NOCOPY     VARCHAR2
,  x_msg_data                       OUT NOCOPY     VARCHAR2
,  x_online_report_id               OUT NOCOPY     NUMBER
)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

PO_DOCUMENT_CHECKS_GRP.po_submission_check(
   p_api_version        => 1.0
,  p_action_requested   => 'DOC_SUBMISSION_CHECK'
,  p_document_type      => p_document_type
,  p_document_subtype   => p_document_subtype
,  p_document_id        => p_document_id
,  p_check_asl          => p_check_asl
,  x_return_status      => x_return_status
,  x_sub_check_status   => x_sub_check_status
,  x_msg_data           => x_msg_data
,  x_online_report_id   => x_online_report_id
);

-- bug3539651
-- Issue a commit instead of rollback, otherwise we will lose all the data
-- in PO_ONLINE_REPORT_TEXT
COMMIT;


END po_submission_check_autonomous;


-- <ENCUMBRANCE FPJ END>




end PO_REQAPPROVAL_ACTION;

/
