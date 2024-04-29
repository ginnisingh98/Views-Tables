--------------------------------------------------------
--  DDL for Package Body PO_REQAPPROVAL_FINDAPPRV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQAPPROVAL_FINDAPPRV1" AS
/* $Header: POXWPA3B.pls 120.5.12010000.8 2013/05/02 02:29:15 xueche ship $ */

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');


 /*=======================================================================+
 | FILENAME
 |   POXWPA3B.sql
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_REQAPPROVAL_FINDAPPRV1
 |
 | NOTES        Ben Chihaoui Created 6/15/97
 | MODIFIED    (MM/DD/YY)
 *=======================================================================*/


-- The following are local/Private procedure that support the workflow APIs:

FUNCTION IsForwardToProvided(itemtype in varchar2, itemkey in varchar2) RETURN VARCHAR2;

--
-- change CheckForward as public procedure.
--
--FUNCTION CheckForwardTo( p_username varchar2,  x_user_id IN OUT number) RETURN VARCHAR2;
--
--
PROCEDURE GetApprovalPathId(itemtype VARCHAR2, itemkey VARCHAR2);

--
FUNCTION GetForwardMode(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
FUNCTION UsePositionFlag RETURN VARCHAR2;

--
FUNCTION GetMgrHRHier(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
FUNCTION GetMgrPOHier(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2;

--
/* Bug# 1496490
** New Procedure to check the owner can approve flag value
*/
--<bug 14105414>: moved the declaration to SPEC.
--PROCEDURE CheckOwnerCanApprove (itemtype in VARCHAR2, itemkey in VARCHAR2,
--CanOwnerApprove out NOCOPY VARCHAR2);


/******************************************************************************/

--
procedure Set_Forward_To_From_App_fwd(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is
x_progress varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

--Added the below variables as part of bug 14105414 fix.
l_forward_to_username_response varchar2(100);
l_forward_to_username          varchar2(100);
l_forward_to_username_disp     varchar2(240);
l_error_msg                    varchar2(500);

BEGIN

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Set_Forward_To_From_App_fwd: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  --Start of code changes. <bug 14105414>
  IF itemtype in ('POAPPRV') THEN
    l_error_msg := wf_engine.GetItemAttrText (itemtype => itemtype,
                                              itemkey => itemkey,
                                              aname => 'WRONG_FORWARD_TO_MSG');
    x_progress :=  'PO_REQAPPROVAL_FINDAPPRV1.Set_Forward_To_From_App_fwd: l_error_msg: ';
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress || l_error_msg);
    END IF;

    IF l_error_msg is NULL THEN
      l_forward_to_username_response := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                    itemkey => itemkey,
                                                    aname => 'FORWARD_TO_USERNAME_RESPONSE');
      l_forward_to_username_response := UPPER(l_forward_to_username_response);

      l_forward_to_username:= wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_USERNAME');
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
                       'l_forward_to_username: ' || l_forward_to_username);
      END IF;

      IF l_forward_to_username is NOT NULL THEN

     	 l_forward_to_username_disp:= wf_engine.GetItemAttrText (itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'FORWARD_TO_DISPLAY_NAME');

       ELSE /* get the approver name who took this action */
         l_forward_to_username:= wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_USER_NAME');

         l_forward_to_username_disp:= wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_DISPLAY_NAME');
      END IF;

      /* Set the FORWARD_FROM */
      wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_FROM_USER_NAME',
                                        avalue          =>  l_forward_to_username);

      wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_FROM_DISP_NAME',
                                        avalue          =>  l_forward_to_username_disp);

      /* Set the approver to the person who took the action on the notification,
      ** i.e. the old forward-to person
      */
      wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'APPROVER_USER_NAME',
                                        avalue          =>  l_forward_to_username);

      wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'APPROVER_DISPLAY_NAME',
                                        avalue          =>  l_forward_to_username_disp);

      /* Set the FORWARD-TO */

	  --Bug#16657268
      if trim(l_forward_to_username_response) is not null and l_forward_to_username_response <> l_forward_to_username then
      wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_TO_USERNAME',
                                        avalue          =>  l_forward_to_username_response);


      /* Get the Display name for the user from the WF Directory  */
      wf_engine.SetItemAttrText ( itemtype        => itemtype,
                        itemkey         => itemkey,
                        aname           => 'FORWARD_TO_DISPLAY_NAME',
                        avalue          =>
                        wf_directory.GetRoleDisplayName(l_forward_to_username_response));
     end if;
    --end Bug#16657268

      /* Reset the FORWARD_TO_USERNAME_RESPONSE attribute */
      wf_engine.SetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_USERNAME_RESPONSE',
                                         avalue   => NULL);

    END IF;
  END IF;
  --End of code changes. <bug 14105414>

  /* Bug 2114328: Need to set fnd_context for responder */

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

  --   resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

  resultout := 'COMPLETE' ;

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Set_Forward_To_From_App_fwd: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','Set_Forward_To_From_App_fwd',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_FINDAPPRV1.SET_FORWARD_TO_FROM_APP_FWD');
    raise;

END Set_Forward_To_From_App_fwd;
--
--
procedure Set_Fwd_To_From_App_timeout(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_approver_id        number;
l_approver_username  varchar2(100);
l_approver_disp_name varchar2(100);
l_error_msg          varchar2(200);
x_progress           varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

/* Bug 9593873 */
l_note po_action_history.note%TYPE;
l_document_type varchar2(25);
/*Bug 9593873 */

BEGIN

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Set_Fwd_To_From_App_timeout: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug 2114328: Need to set fnd_context for responder */

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

      /* If the responder chooses APPROVE or the notification times out, then
      ** Set the Approver to be the old forward-to
      */
      l_approver_id := wf_engine.GetItemAttrNumber (itemtype  => itemtype,
                                   itemkey         => itemkey,
                                   aname           => 'FORWARD_TO_ID');

      l_approver_username := wf_engine.GetItemAttrText (itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_USERNAME');

      l_approver_disp_name := wf_engine.GetItemAttrText (itemtype => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_DISPLAY_NAME');
      --
      wf_engine.SetItemAttrNumber (itemtype        => itemtype,
                                   itemkey         => itemkey,
                                   aname           => 'APPROVER_EMPID',
                                   avalue          =>  l_approver_id);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => l_approver_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_DISPLAY_NAME' ,
                              avalue     => l_approver_disp_name);

      /*
      ** Reset the Forward-to and Forward-From.
      */
      wf_engine.SetItemAttrNumber (itemtype        => itemtype,
                                   itemkey         => itemkey,
                                   aname           => 'FORWARD_TO_ID',
                                   avalue          =>  NULL);
      --
      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_USERNAME' ,
                              avalue     => NULL);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_DISPLAY_NAME' ,
                              avalue     => NULL);
      --

/* Bug# 1325552: kagarwal
** Desc: In Main Requistion approval Process, when the 'Requisition Approval
** Reminder 2' times out the forward from and forward to data is all reset to
** Null.
**
** Now when the approval process is unable to Find a new approver it 'Returns
** Requisition to Submitter'. This process sends Notification to the preparer
** and the last approver, which is the forward from person. Since the Forward
** From data is not set the workflow errors out.
**
** Hence we need to set the forward from data to the last approver in the
** Set_Fwd_To_From_App_timeout procedure which is the forward to person
** when the timeout occurs.
*/

      wf_engine.SetItemAttrNumber (itemtype        => itemtype,
                                   itemkey         => itemkey,
                                   aname           => 'FORWARD_FROM_ID',
                                   avalue          =>  l_approver_id);
      --
      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_FROM_USER_NAME' ,
                              avalue     => l_approver_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_FROM_DISP_NAME' ,
                              avalue     => l_approver_disp_name);


    /* Reset the FORWARD_TO_USERNAME_RESPONSE attribute */
    wf_engine.SetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_USERNAME_RESPONSE',
                                         avalue   => NULL);

	/*Bug 9593873 Reset response note*/
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
    /*Bug 9593873 */



     /* Set the Subject of the Approval notification to "requires your approval".
     ** Since the user did not enter a forward-to, then set the
     ** "Invalid Forward-to" message to NULL.
     */
     fnd_message.set_name ('PO','PO_WF_NOTIF_REQUIRES_APPROVAL');
     l_error_msg := fnd_message.get;

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQUIRES_APPROVAL_MSG' ,
                                 avalue     => l_error_msg);

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'WRONG_FORWARD_TO_MSG' ,
                                 avalue     => '');

  --   resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

  resultout := 'COMPLETE' ;

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Set_Fwd_To_From_App_timeout: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','Set_Fwd_To_From_App_timeout',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_FINDAPPRV1.SET_FWD_TO_FROM_APP_TIMEOUT');
    raise;

END Set_Fwd_To_From_App_timeout;
--

-- Is_Forward_To_Valid
--  Is Forward-To userame entered in the Forward-To field in response to the
--  the approval notification, a valid username. If not resend the
--  notification back to the user.
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - Y/N
--
procedure Is_Forward_To_Valid(  itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

x_user_id         number;
l_approver_empid  number;
l_forward_to_username_response varchar2(100);
l_forward_to_username          varchar2(100);
l_forward_to_username_disp     varchar2(240);
l_forward_to_id                number;
l_error_msg                    varchar2(500);
x_progress  varchar2(200);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

/* Bug# 1496490 */
l_preparer_id number;
x_CanOwnerApproveFlag varchar2(1);

l_orgid         number;

/* Bug 9593873 */
l_note po_action_history.note%TYPE;
l_document_type varchar2(25);
/*Bug 9593873 */

BEGIN

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Is_Forward_To_Valid: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  /* Bug# 2353153
  ** Setting application context
  */
  -- Context Setting revamp
  /* PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(itemtype, itemkey); */


/* Bug# 1796605: kagarwal
** Desc: When responding from the E-mail notifications, the forward
** to failed as the org context was not set.
*/

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    po_moac_utils_pvt.set_org_context(l_orgid); --<R12 MOAC>

  END IF;

  /* Check that the value entered by responder as the FORWARD-TO user, is actually
  ** a valid employee (has an employee id).
  ** If valid, then set the FORWARD-FROM USERNAME and ID from the old FORWARD-TO.
  ** Then set the Forward-To to the one the user entered in the response.
  */
  /* NOTE: We take the value entered by the user and set it to ALL CAPITAL LETTERS!!!
  */
  l_forward_to_username_response := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_USERNAME_RESPONSE');

  l_forward_to_username_response := UPPER(l_forward_to_username_response);

  x_progress := 'Set_Forward_To_From_App_fwd: 02';
  x_progress := x_progress || ' Forward-To=' || l_forward_to_username_response;
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  IF  CheckForwardTo(l_forward_to_username_response, x_user_id) = 'Y' THEN

     x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Is_Forward_To_Valid: 010 '||
                   'x_user_id: ' ||x_user_id;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

     /* The FORWARD-FROM is now the old FORWARD-TO and the NEW FORWARD-TO is set
     ** to what the user entered in the response
     */

     l_forward_to_username:= wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_USERNAME');

/* Bug# 1352995: kagarwal
** Desc: When the approver takes approve action from the Notification form after
** modifying the PO. The Approver attributes are set but forward-to attributes
** are set to Null. Now if any error is encountered, the Notification is sent to
** the approver and if after the error the approver forwards the PO, the
** is_forward_to_valid function sets the forward-from and approver attributes
** from the forward-to attributes (it has not changed as of now) and then sets
** the forward-to attributes to the the response-forward person but in this case
** the forward-to attributes had been set to null by previous approve action
** hence the approver_username was set to NULL by this function.
**
** If the forward-to attributes are null when taking the forward action we
** should use the approver attributes. This will ensure that the approver
** attributes and the forward-from attributes are not set to NULL on
** forwarding the document.
*/

     IF l_forward_to_username is NOT NULL THEN

     	l_forward_to_username_disp:= wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_DISPLAY_NAME');

     	l_forward_to_id:= wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');
     ELSE /* get the approver name who took this action */
          l_forward_to_username:= wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_USER_NAME');

          l_forward_to_username_disp:= wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_DISPLAY_NAME');

          l_forward_to_id:= wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_EMPID');
     END IF;

/* Bug# 1496490: kagarwal
** Desc: If the forward to person is the preparer and the
** owner can approve flag is set to N then return the Notification
** to the responder with Invalid Forward to Message
*/
       x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Is_Forward_To_Valid: 015';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

           l_preparer_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'PREPARER_ID');

           if (x_user_id = l_preparer_id) then
               PO_REQAPPROVAL_FINDAPPRV1.CheckOwnerCanApprove(itemtype, itemkey,
								x_CanOwnerApproveFlag);

                x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Is_Forward_To_Valid: 020 ' ||
                               'x_CanOwnerApproveFlag: '||x_CanOwnerApproveFlag;
               IF (g_po_wf_debug = 'Y') THEN
                  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
               END IF;

               if x_CanOwnerApproveFlag = 'N' then

                  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Is_Forward_To_Valid: 025';
                 IF (g_po_wf_debug = 'Y') THEN
                    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
                 END IF;

		  fnd_message.set_name('PO', 'PO_WF_NOTIF_INVALID_FORWARD');
		  l_error_msg := fnd_message.get;

                  wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname   => 'REQUIRES_APPROVAL_MSG',
                                   avalue  => '');

                  wf_engine.SetItemAttrText (itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'WRONG_FORWARD_TO_MSG',
                                   avalue => l_error_msg);

                  resultout := wf_engine.eng_completed || ':' || 'N';

                  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Is_Forward_To_Valid: 050';
                  IF (g_po_wf_debug = 'Y') THEN
                     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
                  END IF;

		  return;
		end if;
           end if;

/* end fix Bug# 1496490 */

      x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Is_Forward_To_Valid: 060';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;


     /* Set the FORWARD_FROM */
     wf_engine.SetItemAttrNumber (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_FROM_ID',
                                        avalue          =>  l_forward_to_id);

     wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_FROM_USER_NAME',
                                        avalue          =>  l_forward_to_username);

     wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_FROM_DISP_NAME',
                                        avalue          =>  l_forward_to_username_disp);

     /* Set the approver to the person who took the action on the notification,
     ** i.e. the old forward-to person
     */
     wf_engine.SetItemAttrNumber (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'APPROVER_EMPID',
                                        avalue          =>  l_forward_to_id);

     wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'APPROVER_USER_NAME',
                                        avalue          =>  l_forward_to_username);

     wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'APPROVER_DISPLAY_NAME',
                                        avalue          =>  l_forward_to_username_disp);

     /* Set the FORWARD-TO */

     wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_TO_USERNAME',
                                        avalue          =>  l_forward_to_username_response);

     wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'FORWARD_TO_ID',
                                   avalue     => x_user_id);


    /* Get the Display name for the user from the WF Directory  */
    wf_engine.SetItemAttrText ( itemtype        => itemtype,
                        itemkey         => itemkey,
                        aname           => 'FORWARD_TO_DISPLAY_NAME',
                        avalue          =>
                        wf_directory.GetRoleDisplayName(l_forward_to_username_response));

    /* Reset the FORWARD_TO_USERNAME_RESPONSE attribute */
    wf_engine.SetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_USERNAME_RESPONSE',
                                         avalue   => NULL);

        /*Bug 9593873 Reset response note */
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
    /*Bug 9593873 */


     /* Set the Subject of the Approval notification to "requires your approval".
     ** Since the user entered a valid forward-to, then set the
     ** "Invalid Forward-to" message to NULL.
     */
     fnd_message.set_name ('PO','PO_WF_NOTIF_REQUIRES_APPROVAL');
     l_error_msg := fnd_message.get;

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQUIRES_APPROVAL_MSG' ,
                                 avalue     => l_error_msg);

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'WRONG_FORWARD_TO_MSG' ,
                                 avalue     => '');

    --
    resultout := wf_engine.eng_completed || ':' ||  'Y';
    --

  ELSE

     /* Set the error message that will be shown to the user in the ERROR MESSAGE
     ** Field in the Notification.
     */

     /* Set the Subject of the Approval notification to "Invalid forward-to"
     ** Since the user entered an invalid forward-to, then set the
     ** "requires your approval" message to NULL.
     */
     fnd_message.set_name ('PO','PO_WF_NOTIF_INVALID_FORWARD');
     l_error_msg := fnd_message.get;

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQUIRES_APPROVAL_MSG' ,
                                 avalue     => '');

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'WRONG_FORWARD_TO_MSG' ,
                                 avalue     => l_error_msg);

    --
    resultout := wf_engine.eng_completed || ':' ||  'N';
    --

  END IF;


END Is_Forward_To_Valid  ;
--


-- Is_forward_to_provided
--   Did the submitter or the person responding to the approval notification provide
--   a Forward_to.
--
-- IN
--   itemtype, itemkey, actid, funcmode
-- OUT
--   Resultout
--    - Completed   - Activity was completed without any errors.
--
procedure Is_forward_to_provided(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_forward_to_id number;
x_progress  varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Is_forward_to_provided: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;


  l_forward_to_id :=  wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');

  IF l_forward_to_id is NOT NULL THEN

         /* Set the Approver to be the person receiving the approval notification */
         wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_EMPID',
                                 avalue   => l_forward_to_id);

         resultout := wf_engine.eng_completed || ':' ||  'Y';

    ELSE

     resultout := wf_engine.eng_completed || ':' ||  'N';

  END IF;


  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Is_forward_to_provided: 03';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','Is_forward_to_provided',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_FINDAPPRV1.IS_FORWARD_TO_PROVIDED');
    raise;

END Is_forward_to_provided;


-- Is_Forward_To_User_Name_Valid
--   Is the user_name valid for the next approver?
--
-- IN
--   itemtype --   itemkey --   actid  --   funcmode
-- OUT
--   Resultout
--    - Y/N
procedure Is_Forward_To_User_Name_Valid(itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					resultout	out NOCOPY varchar2	) IS

  l_user_name VARCHAR2(100);
  l_id NUMBER;
  l_disp_name VARCHAR2(100);
  x_progress varchar2(100);

  l_doc_string varchar2(200);
  l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Is_forward_to_user_name_valid: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  l_user_name :=  wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_USERNAME');

  IF l_user_name is NOT NULL THEN

         resultout := wf_engine.eng_completed || ':' ||  'Y';

  ELSE
     l_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'FORWARD_TO_ID');

	/* Bug# 1312794: kagarwal
	** Desc: The SQL below would retun multiple rows for a person_id
	**       if the person has changed names or status or was rehired.
	**
	**       Added addition clause:
	**       trunc(sysdate) BETWEEN effective_start_date
	**                      AND effective_end_date
	*/

     SELECT full_name
     INTO   l_disp_name
     FROM   PER_ALL_PEOPLE_F    -- <BUG 6615913>
     WHERE  person_id = l_id
     AND    trunc(sysdate) BETWEEN effective_start_date
                               AND effective_end_date;

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                     itemkey    => itemkey,
                                     aname      => 'APPROVER_DISPLAY_NAME' ,
                                     avalue     => l_disp_name);

     resultout := wf_engine.eng_completed || ':' ||  'N';

  END IF;

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Is_forward_to_user_name_valid: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','Is_forward_to_user_name_valid',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_FINDAPPRV1.IS_FORWARD_TO_USER_NAME_VALID');
    raise;

END Is_Forward_To_User_Name_Valid;



--
-- Get_approval_path_id
--   Get the requisition values on the doc header and assigns then to workflow attributes
--
procedure Get_approval_path_id(     itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_type varchar2(25);
l_document_id   number;
l_orgid         number;
l_requisition_header_id NUMBER;
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Get_approval_path_id: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');
  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

--  PO_REQAPPROVAL_INIT1.get_multiorg_context (l_document_type, l_document_id, x_orgid);
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

     po_moac_utils_pvt.set_org_context(l_orgid); --<R12 MOAC>

  END IF;


  PO_REQAPPROVAL_FINDAPPRV1.GetApprovalPathId(itemtype,itemkey);


     --
     resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';
     --
  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Get_approval_path_id: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','Get_approval_path_id',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_FINDAPPRV1.GET_APPROVAL_PATH_ID');
    raise;

END Get_approval_path_id;

-- Get_Forward_mode
--   Get the requisition values on the doc header and assigns then to workflow attributes
--
procedure Get_Forward_mode(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_type varchar2(25);
l_document_id   number;
l_orgid         number;
l_forward_mode   varchar2(25);
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Get_Forward_mode: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');
  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

--  PO_REQAPPROVAL_INIT1.get_multiorg_context (l_document_type, l_document_id,x_orgid);

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    po_moac_utils_pvt.set_org_context(l_orgid); --<R12 MOAC>

  END IF;


  l_forward_mode := PO_REQAPPROVAL_FINDAPPRV1.GetForwardMode(itemtype, itemkey);

  IF l_forward_mode = 'DIRECT' THEN

     resultout := wf_engine.eng_completed || ':' ||  'DIRECT';

  ELSIF l_forward_mode = 'HIERARCHY' THEN

     resultout := wf_engine.eng_completed || ':' ||  'HIERARCHY';

  END IF;

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Get_Forward_mode: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','Get_Forward_mode',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_FINDAPPRV1.GET_FORWARD_MODE');
    raise;


END Get_Forward_mode;

--
procedure Use_Position_flag(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_type varchar2(25);
l_document_id   number;
l_orgid         number;
l_use_positions_flag    varchar2(1);
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Use_Position_flag: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');
  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

--  PO_REQAPPROVAL_INIT1.get_multiorg_context (l_document_type, l_document_id,x_orgid);
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    po_moac_utils_pvt.set_org_context(l_orgid); --<R12 MOAC>

  END IF;


  l_use_positions_flag := PO_REQAPPROVAL_FINDAPPRV1.UsePositionFlag;

  IF l_use_positions_flag = 'Y' THEN

     resultout := wf_engine.eng_completed || ':' ||  'Y';

  ELSIF l_use_positions_flag = 'N' THEN

     resultout := wf_engine.eng_completed || ':' ||  'N';

  END IF;

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.Use_Position_flag: 02';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','Use_Position_flag',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_FINDAPPRV1.USE_POSITION_FLAG');
    raise;


END Use_Position_flag;

--
-- GetMgr_hr_hier
--   Get the requisition values on the doc header and assigns then to workflow attributes
--
procedure GetMgr_hr_hier(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_type   varchar2(25);
l_document_id     number;
l_orgid           number;
l_found_manager   VARCHAR2(1);
x_progress        varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.GetMgr_hr_hier: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');
  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

--  PO_REQAPPROVAL_INIT1.get_multiorg_context (l_document_type, l_document_id,x_orgid);

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    po_moac_utils_pvt.set_org_context(l_orgid); --<R12 MOAC>

  END IF;



 l_found_manager := PO_REQAPPROVAL_FINDAPPRV1.GetMgrHRHier(itemtype, itemkey);

 IF l_found_manager = 'Y' THEN

     resultout := wf_engine.eng_completed || ':' ||  'Y';
     x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.GetMgr_hr_hier: RESULT=Y';

  ELSIF l_found_manager = 'N' THEN

     resultout := wf_engine.eng_completed || ':' ||  'N';
     x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.GetMgr_hr_hier: RESULT=N';

  END IF;

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','GetMgr_hr_hier',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_FINDAPPRV1.GETMGR_HR_HIER');
    raise;

END GetMgr_hr_hier;

--

--
-- GetMgr_po_hier
--   Get the requisition values on the doc header and assigns then to workflow attributes
--
procedure GetMgr_po_hier(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2    ) is

l_document_type varchar2(25);
l_document_id   number;
l_orgid         number;
l_found_manager   VARCHAR2(1);
x_progress              varchar2(100);

l_doc_string varchar2(200);
l_preparer_user_name varchar2(100);

BEGIN

  x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.GetMgr_po_hier: 01';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      resultout := wf_engine.eng_null;
      return;

  end if;

  -- Set the multi-org context
  l_document_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');
  l_document_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_ID');

--  PO_REQAPPROVAL_INIT1.get_multiorg_context (l_document_type, l_document_id, x_orgid);
  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN

    po_moac_utils_pvt.set_org_context(l_orgid); --<R12 MOAC>

  END IF;


 l_found_manager := PO_REQAPPROVAL_FINDAPPRV1.GetMgrPOHier(itemtype, itemkey);

 IF l_found_manager = 'Y' THEN

     resultout := wf_engine.eng_completed || ':' ||  'Y';
     x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.GetMgr_po_hier: RESULT=Y';

  ELSIF l_found_manager = 'N' THEN

     resultout := wf_engine.eng_completed || ':' ||  'N';
     x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.GetMgr_po_hier: RESULT=N';

  END IF;

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','GetMgr_po_hier',x_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name, l_doc_string, sqlerrm, 'PO_REQAPPROVAL_FINDAPPRV1.GETMGR_PO_HIER');
    raise;


END GetMgr_po_hier;

--

/*********************************************************************************
** The following are the APIs that support the workflow procedures.
*********************************************************************************/


FUNCTION IsForwardToProvided(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

l_forward_to_id     NUMBER := NULL;
l_forward_to_id_old NUMBER := NULL;
l_forward_to_username_response varchar2(60):= NULL;

x_progress varchar2(100):='000';
BEGIN

/* DEBUG: This procedure needs to get the employee_id of the username
**        provided by the person responding to the notification.
**        If we are unable to get an employee_id (for example, the
**        user is only a Web user, not in Per_people_F table),
**        then we should raise some kind of execption (e.g. send a notification
**        to the system administrator????).
**        If we get an employee_id, then we need to compare it to the old
**        value in the forward_to_id, to check if the user provided a new
**        forward_to.
*/

  x_progress :='In IsForwardToProvided. x_progress= 001';
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  /* Get_employee_id(), should set the item attribute FORWARD_TO_ID
  ** to the id of the username supplied as a forward_to in the notification
  ** (It gets the username from item_attribute FORWARD_TO_USERNAME, which is
  **  referenced in the message attribute).
  ** It should also return that id.
  */

  l_forward_to_username_response := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_USERNAME_RESPONSE');

  /* If there is no Forward-to provided in the notification, then the forward_to_id
  ** comes from the current value of the FORWARD_TO_ID.
  ** Otherwise, we get it from the username supplied in the notification.
  */
  IF l_forward_to_username_response is NOT NULL THEN

     x_progress :='In IsForwardToProvided. x_progress= 002';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;


     /* Set the forward_to username so they would get the notification */
     /* DEBUG: Only set the FORWARD_TO_USERNAME, if Get_employee_id() returned
     **        a valid employee.
     */
     PO_REQAPPROVAL_INIT1.Get_employee_id(l_forward_to_username_response,
                                             l_forward_to_id);

     IF l_forward_to_id is NOT NULL THEN

         x_progress := '003';
         x_progress :='In IsForwardToProvided. x_progress= 003';
         IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
         END IF;

         wf_engine.SetItemAttrText ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'FORWARD_TO_USERNAME',
                                   avalue     => l_forward_to_username_response);

         wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'FORWARD_TO_ID',
                                   avalue     => l_forward_to_id);

      ELSE

         x_progress :='In IsForwardToProvided. x_progress= 004';
         IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
         END IF;

         RETURN('N'); -- If no valid user provide, then return 'NO FORWARD-TO'

      END IF;

  ELSE

      x_progress :='In IsForwardToProvided. x_progress= 005';
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
      END IF;

      l_forward_to_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');
  END IF;

  /* Reset the value of the forward_to RESPONSE attribute */
  wf_engine.SetItemAttrText ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'FORWARD_TO_USERNAME_RESPONSE',
                                   avalue     => NULL);

  l_forward_to_id_old := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID_OLD');

  IF ( NVL(l_forward_to_id,0) <> NVL(l_forward_to_id_old,0) ) THEN

     -- x_progress:= '006';

     /* Set the old value equal to the new value */
     wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'FORWARD_TO_ID_OLD',
                                   avalue     => l_forward_to_id);

     RETURN('Y');

  ELSE

     x_progress :='In IsForwardToProvided. x_progress= 007';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
     END IF;

     RETURN('N');
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','IsForwardToProvided',x_progress);
        raise;

END IsForwardToProvided;

--
FUNCTION CheckForwardTo( p_username varchar2,  x_user_id IN OUT NOCOPY number) RETURN VARCHAR2 is

/* Bug# 1646614: kagarwal
** Desc: We need to remove the check for orig_system_id from wf_users in
** function CheckForwardTo() in POXWPA3B.pls as it is not required. Also it will
** improve performance.
*/

/*
Cursor C1(username varchar2) is
    Select ORIG_SYSTEM_ID
    from WF_USERS
    where name = username;
*/

/* Bug# 1134100: kagarwal
** Desc: If the forward to user was not an employee the
**       Notification would get forwarded to the user.
**       A check has been added that the user is also a
**       valid employee.
*/

/* Bug# 1301432: kagarwal
** Desc: When validating the forward to username we need to verify that the
** user is a valid employee and also belongs to fnd_users
**
** We need to change the Fix of Bug#1134100.
** The ORIG_SYSTEM_ID in wf_roles returns employee number for username
** associated with an employee and fnd_user.user_id for username not
** associated with an employee
**
** We can do away with the check of wf_roles but it will help us
** identify if the users have setup issue. Also the check from
** PER_WORKFORCE_CURRENT_V makes sure that the employee is
** active on the current date.
*/

cursor C2(username varchar2) is
SELECT HR.PERSON_ID
FROM   FND_USER FND, PO_WORKFORCE_CURRENT_X HR     --<BUG 6615913>
WHERE  FND.USER_NAME = username
AND    FND.EMPLOYEE_ID = HR.PERSON_ID
AND    ROWNUM = 1;

-- check_emp_id number;

x_progress varchar2(3) := '000';

BEGIN

  x_progress := '001';

    OPEN C2(p_username);

    FETCH C2 into x_user_id;

    x_progress := '003';

    IF C2%FOUND THEN
       x_progress := '004';
       CLOSE C2;
       RETURN('Y');
    ELSE
       x_progress := '005';
       CLOSE C2;
       RETURN('N');
    END IF;

  x_progress := '007';

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','CheckForwardTo',x_progress);
        raise;

END CheckForwardTo;

--
PROCEDURE GetApprovalPathId(itemtype VARCHAR2, itemkey VARCHAR2) is

l_approval_path_id NUMBER;
l_document_type_code VARCHAR2(25);
l_document_subtype   VARCHAR2(25);

x_progress varchar2(200) := '000';
BEGIN

  x_progress := '001';
  l_approval_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVAL_PATH_ID');

  /* If No Approval Path was specified by the user, then get the default */

  IF l_approval_path_id is NULL THEN

    l_document_type_code := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

    x_progress := '002';

    Select default_approval_path_id into l_approval_path_id
    FROM   po_document_types podt
    WHERE  podt.document_type_code = l_document_type_code
    AND    podt.document_subtype = l_document_subtype;

    wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVAL_PATH_ID',
                                 avalue   => l_approval_path_id);

  END IF;

  x_progress := 'Procedure GetApprovalPathId(). PATH_ID= ' || to_char(l_approval_path_id);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','GetApprovalPathId',x_progress);
        raise;


END GetApprovalPathId;


--
FUNCTION GetForwardMode(itemtype varchar2, itemkey varchar2) RETURN VARCHAR2 is

l_forward_mode  VARCHAR2(25);
l_document_subtype VARCHAR2(25);
l_document_type_code VARCHAR2(25);

x_progress varchar2(3) := '000';
BEGIN

  x_progress := '001';
  l_document_type_code := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

  l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

  SELECT FORWARDING_MODE_CODE into l_forward_mode
  from po_document_types
   where  document_subtype   = l_document_subtype
   and    document_type_code = l_document_type_code;

   RETURN(l_forward_mode);

  x_progress := '002';
EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','GetForwardMode',x_progress);
        raise;

END GetForwardMode;

--
FUNCTION UsePositionFlag RETURN VARCHAR2 is

l_use_positions_flag VARCHAR2(1);

x_progress varchar2(3) := '000';
BEGIN

  x_progress := '001';
  SELECT  NVL(use_positions_flag, 'N') into l_use_positions_flag
  from financials_system_parameters;

  RETURN(l_use_positions_flag);

  x_progress := '002';
EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','UsePositionFlag',x_progress);
        raise;

END UsePositionFlag;

--
FUNCTION GetMgrHRHier(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

/* Bug# 1169107: kagarwal
** Desc: Added the check that the supervisor is still
**       active on the current date.
**
*/

/* Bug# 1350792: kagarwal
** Desc: In GetMgrHRHier() function the check that the supervisor is still
** active for bug fix 1169107 should also include that the system_person_type
** is an 'EMP'.
*/

/* Bug#2278152: kagarwal
** Desc: When we retrieve the supervisor of an employee, we need
** to check for the person type of EMP_APL as well, in addition to EMP
*/

/* Bug# 2479883: kagarwal
** Desc: When we get the supervisor of an employee, we should be choosing
** the supervisor from the currently active primary assignment.
**
** Added condition pera.person_id = p_employee_id to SQL in cursor C1, C2
*/

/*  Bug# 5556434:
** Modified the cursors C1 to include the
** check to select the supervisor if the  assignment type E.
** Also modified the SQLs slightly to ensure that no more inline
** SQLs to improve performance.
** Also added CWK assignment type
*/
/*Bug 8331565:
  Introduced view PER_PERSON_TYPES_V
  to get if the next approver is Contingent worker
*/
CURSOR c1 (p_empid NUMBER, p_business_group_id NUMBER) IS
SELECT pafe.supervisor_id
FROM   Per_All_Assignments_f pafe,  -- <BUG 6615913>
       Per_All_People_f ppfs,       -- <BUG 6615913>
       Per_All_Assignments_f pafs,  -- <BUG 6615913>
       per_person_types_v ppts,
       per_person_type_usages_f pptu
WHERE  pafe.business_group_id = p_business_group_id
       AND pafe.person_id = p_empid
       AND Trunc(SYSDATE) BETWEEN pafe.Effective_Start_Date
                              AND pafe.Effective_End_Date
       AND pafe.Primary_Flag = 'Y'
       AND pafe.Assignment_Type IN ('E','C')
       AND ppfs.Person_Id = pafe.Supervisor_Id
       AND Trunc(SYSDATE) BETWEEN ppfs.Effective_Start_Date
                              AND ppfs.Effective_End_Date
       AND pafs.Person_Id = ppfs.Person_Id
       AND Trunc(SYSDATE) BETWEEN pafs.Effective_Start_Date
                              AND pafs.Effective_End_Date
       AND pafs.Primary_Flag = 'Y'
       AND pafs.Assignment_Type IN ('E','C')
       AND pptu.Person_Id = ppfs.Person_Id
       AND ppts.person_type_id = pptu.person_type_id
       AND ppts.System_Person_Type IN ('EMP','EMP_APL','CWK');   --<R12 CWK Enhancemment>

/*  Bug# 5556434:
** Modified the cursors C2 to include the
** check to select the supervisor if the assignment type E.
** Also modified the SQLs slightly to ensure that no more inline
** SQLs to improve performance.
** Also added CWK assignment type
*/
/*Bug 8331565:
  Introduced view PER_PERSON_TYPES_V
  to get if the next approver is Contingent worker
*/
CURSOR C2 ( p_empid NUMBER ) IS
SELECT DISTINCT Pafe.supervisor_id
FROM   Per_All_Assignments_f pafe,  -- <BUG 6615913>
       Per_All_People_f ppfs,       -- <BUG 6615913>
       Per_All_Assignments_f pafs,  -- <BUG 6615913>
       per_person_types_v ppts,
       per_person_type_usages_f pptu
WHERE  pafe.person_id = p_empid
     AND Trunc(SYSDATE) BETWEEN pafe.Effective_Start_Date
			    AND pafe.Effective_End_Date
     AND pafe.Primary_Flag = 'Y'
     AND pafe.Assignment_Type IN ('E','C')
     AND ppfs.Person_Id = pafe.Supervisor_Id
     AND Trunc(SYSDATE) BETWEEN ppfs.Effective_Start_Date
 			   AND ppfs.Effective_End_Date
     AND Pafs.Person_Id = ppfs.Person_Id
     AND Trunc(SYSDATE) BETWEEN pafs.Effective_Start_Date
 			    AND pafs.Effective_End_Date
     AND pafs.Primary_Flag = 'Y'
     AND pafs.Assignment_Type IN ('E','C')
     AND pptu.Person_Id = ppfs.Person_Id
     AND ppts.person_type_id = pptu.person_type_id
     AND ppts.System_Person_Type IN ('EMP','EMP_APL','CWK');   --<R12 CWK Enhancemment>

l_superior_id number;
l_empid       number;

x_username            varchar2(100);
x_user_display_name   varchar2(240);

l_forward_from_id          number;
l_forward_from_username    varchar2(100);
l_forward_from_disp_name   varchar2(100);

l_business_group_id  NUMBER;

x_progress varchar2(200) := NULL;
x_hr_profile varchar2(1) := hr_general.get_xbg_profile;

BEGIN

 /* Get the employee whos manager we need to find. This is always
 ** kept in APPROVER_EMPID.
 */

 l_empid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_EMPID');
 SELECT business_group_id
 INTO   l_business_group_id
 FROM   FINANCIALS_SYSTEM_PARAMETERS;

 x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.GetMgrHRHier Business_group_id= ' ||
                to_char(l_business_group_id);

 if x_hr_profile = 'Y' then
  OPEN C2(l_empid);
  FETCH C2 into l_superior_id;
 else
  OPEN C1(l_empid, l_business_group_id);
  FETCH C1 into l_superior_id;
 end if;

 x_progress := x_progress || ' employee_id=' || to_char(l_empid) ||
                             ' supervisor_id=' || to_char(l_superior_id);

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

 IF l_superior_id IS NOT NULL THEN

    /* Bug #1278794: kagarwal
    ** Desc: When a Doc is submitted for approval and the approver does not have
    **   the authority to approve, the approval workflow looks for the superior
    **   of the approver to forward the document.
    **
    **   If the superior does not have a valid username, we will return the
    **   document to the preparer with Message 'No Approver found'.
    **
    **   Return 'N', if PO_REQAPPROVAL_INIT1.get_user_name returns
    **   x_username as NULL
    */

    PO_REQAPPROVAL_INIT1.get_user_name(l_superior_id, x_username,
                                      x_user_display_name);

    IF x_username IS NULL THEN
       if x_hr_profile = 'Y' then
        close C2;
       else
        close C1;
       end if;

       RETURN('N');

     END IF;

    /* If we found an approver, then we need a forward-from.
    ** If the Forward_from_id is NULL, then we need to set the forward_from_id
    ** to be that of the previous approver. This takes care of the following
    ** scenario:
    ** an approver gets a notification, they respond with APPROVE action.
    ** Since the approver did not provide a forward-to, we null out
    ** the forward-from and the forward-to (see activity
    ** "Set Forward-to/from Approve"). The flow then moves to activity
    ** "Verify Authority". If the user does not have authority, then flow
    ** moves to "Find Approver". Then we get here.
    ** At this point, we find an approver, so we need to set the forward-from
    ** to be the last person that took the APPROVE action.
    */

    l_forward_from_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_FROM_ID');

    IF l_forward_from_id is NULL THEN

       /* Get the previous approver username and display name */
       l_forward_from_username := wf_engine.GetItemAttrText ( itemtype => itemType,
                                            itemkey    => itemkey,
                                            aname      => 'APPROVER_USER_NAME');

       l_forward_from_disp_name := wf_engine.GetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_DISPLAY_NAME');

       /* Set the forward-from username and display name to that of the previous
       ** approver.
       */
       wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_FROM_ID' ,
                              avalue     => l_empid);

       wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_FROM_USER_NAME' ,
                              avalue     => l_forward_from_username);

       wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_FROM_DISP_NAME' ,
                              avalue     => l_forward_from_disp_name);

    END IF;

    /* Set the approver id to that of the superior. We do this in case this manager
    ** does not have the authority to approve. Therefore, we would loop back and call
    ** this routine again. But this time we want to find the manager of this manager
    ** not of the original submitter (Also, note that When we first come into the
    ** workflow, we set the APPROVER_EMPID to the preparer id).
    **
    ** NOTE: Activity "Verify Authority" always uses the APPROVER_EMPID attribute
    **       as the approver.
    */
    wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_EMPID',
                                 avalue   => l_superior_id);

    /* Set the forward-to ID. This is the approver that will get the notification */
    wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'FORWARD_TO_ID',
                                 avalue   => l_superior_id);

    /* Set the value of FORWARD_TO_ID_OLD. This is used to determine if the responder
    ** to the notification entered a different USERNAME to forward the doc to.
    */
     wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'FORWARD_TO_ID_OLD',
                                   avalue     => l_superior_id);

    /* Get the username of Forward-to employee. We need to assign it to the
    ** performer of the notification */
	/* Commented out the call since we have already got the username */
    /*PO_REQAPPROVAL_INIT1.get_user_name(l_superior_id, x_username,
                                      x_user_display_name);*/

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_USERNAME' ,
                              avalue     => x_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => x_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);

    if x_hr_profile = 'Y' then
     close C2;
    else
     close C1;
    end if;
    RETURN('Y');

 ELSE

   if x_hr_profile = 'Y' then
     close C2;
    else
     close C1;
    end if;

   RETURN('N');

 END IF;


EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','GetMgrHRHier',x_progress);
        raise;

END GetMgrHRHier;

--
FUNCTION GetMgrPOHier(itemtype VARCHAR2, itemkey VARCHAR2) RETURN VARCHAR2 is

-- Bug 762194: The superior_level needs to be > 0 instead of = 1.

 /* Bug 2437175
    Added the LEADING(POEH) hint to get better execution plan */

-- Bug 8549707 - Replaced view PO_WORKFORCE_CURRENT_X from the query with the underlying view basetables

Cursor C1(p_empid number, p_approval_path_id number) is
  SELECT POEH.superior_id, poeh.superior_level, HREC.full_name
  FROM   PO_EMPLOYEES_CURRENT_X HREC,   -- <BUG 6615913>
         PO_EMPLOYEE_HIERARCHIES POEH
  WHERE  POEH.position_structure_id = p_approval_path_id
  AND    POEH.employee_id = p_empid
  AND    HREC.employee_id = POEH.superior_id
  AND    POEH.superior_level > 0
  UNION ALL
  SELECT poeh.superior_id, poeh.superior_level, cwk.full_name
  FROM   PER_ALL_PEOPLE_F CWK,
         PO_EMPLOYEE_HIERARCHIES POEH,
         PER_ALL_ASSIGNMENTS_F A,
         PER_PERIODS_OF_SERVICE PS
  WHERE  poeh.position_structure_id = p_approval_path_id
  AND    poeh.employee_id = p_empid
  AND    cwk.person_id = poeh.superior_id
  AND    poeh.superior_level > 0
  AND    nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'),'N') = 'Y'
  AND    A.PERSON_ID      = CWK.PERSON_ID
  AND    A.PERSON_ID      = PS.PERSON_ID
  AND    A.ASSIGNMENT_TYPE='E'
  AND    CWK.EMPLOYEE_NUMBER IS NOT NULL
  AND    A.PERIOD_OF_SERVICE_ID = PS.PERIOD_OF_SERVICE_ID
  AND    A.PRIMARY_FLAG         = 'Y'
  AND    TRUNC(SYSDATE) BETWEEN CWK.EFFECTIVE_START_DATE AND CWK.EFFECTIVE_END_DATE
  AND    TRUNC(SYSDATE) BETWEEN A.EFFECTIVE_START_DATE AND A.EFFECTIVE_END_DATE
  AND    (  PS.ACTUAL_TERMINATION_DATE>= TRUNC(sysdate) OR PS.ACTUAL_TERMINATION_DATE IS NULL )
  UNION ALL
  SELECT
         POEH.SUPERIOR_ID , POEH.SUPERIOR_LEVEL, CWK.FULL_NAME
  FROM   PER_ALL_PEOPLE_F CWK,
         PO_EMPLOYEE_HIERARCHIES POEH,
         PER_ALL_ASSIGNMENTS_F A,
         PER_PERIODS_OF_PLACEMENT PP
  WHERE  poeh.position_structure_id = p_approval_path_id
  AND    poeh.employee_id = p_empid
  AND    cwk.person_id = poeh.superior_id
  AND    poeh.superior_level > 0
  AND    nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'),'N') = 'Y'
  AND    A.PERSON_ID      = CWK.PERSON_ID
  AND    A.PERSON_ID      = PP.PERSON_ID
  AND    A.ASSIGNMENT_TYPE='C'
  AND    CWK.NPW_NUMBER IS NOT NULL
  AND    A.PERIOD_OF_PLACEMENT_DATE_START = PP.DATE_START
  AND    A.PRIMARY_FLAG         = 'Y'
  AND    TRUNC(SYSDATE) BETWEEN CWK.EFFECTIVE_START_DATE AND CWK.EFFECTIVE_END_DATE
  AND    TRUNC(SYSDATE) BETWEEN A.EFFECTIVE_START_DATE AND A.EFFECTIVE_END_DATE
  AND    (  PP.ACTUAL_TERMINATION_DATE>= TRUNC(sysdate) OR PP.ACTUAL_TERMINATION_DATE IS NULL )
  ORDER BY superior_level, full_name;

l_superior_id    NUMBER := NULL;
l_superior_level NUMBER := NULL;
l_full_name      VARCHAR2(240) := '000';

l_empid       number;
l_approval_path_id number;

x_username            varchar2(100);
x_user_display_name   varchar2(240);

l_forward_from_id          number;
l_forward_from_username    varchar2(100);
l_forward_from_disp_name   varchar2(100);

x_progress varchar2(200) := NULL;
BEGIN


 l_empid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_EMPID');

 l_approval_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVAL_PATH_ID');

 x_progress := '001';

 open C1(l_empid, l_approval_path_id);
 fetch C1 into l_superior_id, l_superior_level, l_full_name;

 x_progress := 'PO_REQAPPROVAL_FINDAPPRV1.GetMgrPOHier: approval_path_id= ' ||
                to_char(l_approval_path_id) || ' employee_id=' ||
                to_char(l_empid) || ' supervisor_id=' || to_char(l_superior_id);
  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


 IF C1%FOUND THEN

    /* Bug #1278794: kagarwal
    ** Desc: When a Doc is submitted for approval and the approver does not have
    **   the authority to approve, the approval workflow looks for the superior
    **   of the approver to forward the document.
    **
    **   If the superior does not have a valid username, we will return the
    **   document to the preparer with Message 'No Approver found'.
    **
    **   Return 'N', if PO_REQAPPROVAL_INIT1.get_user_name returns
    **   x_username as NULL
    */

    PO_REQAPPROVAL_INIT1.get_user_name(l_superior_id, x_username,
                                      x_user_display_name);

    IF x_username IS NULL THEN
       close C1;
       RETURN('N');

     END IF;

    /* If we found an approver, then we need a forward-from.
    ** If the Forward_from_id is NULL, then we need to set the forward_from_id
    ** to be that of the previous approver. This takes care of the following
    ** scenario:
    ** an approver gets a notification, they respond with APPROVE action.
    ** Since the approver did not provide a forward-to, we null out
    ** the forward-from and the forward-to (see activity
    ** "Set Forward-to/from Approve"). The flow then moves to activity
    ** "Verify Authority". If the user does not have authority, then flow
    ** moves to "Find Approver". Then we get here.
    ** At this point, we find an approver, so we need to set the forward-from
    ** to be the last person that took the APPROVE action.
    */

    l_forward_from_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_FROM_ID');

    IF l_forward_from_id is NULL THEN

       /* Get the previous approver username and display name */
       l_forward_from_username := wf_engine.GetItemAttrText ( itemtype => itemType,
                                            itemkey    => itemkey,
                                            aname      => 'APPROVER_USER_NAME');

       l_forward_from_disp_name := wf_engine.GetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_DISPLAY_NAME');

       /* Set the forward-from username and display name to that of the previous
       ** approver.
       */
       wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_FROM_ID' ,
                              avalue     => l_empid);

       wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_FROM_USER_NAME' ,
                              avalue     => l_forward_from_username);

       wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_FROM_DISP_NAME' ,
                              avalue     => l_forward_from_disp_name);

    END IF;

    /* Set the employee id to the manager. The reason, we do this is that this manager
    ** may not have the authority to approve. Therefore, we would loop back and call
    ** this routine again. But this time we want to find the manager of this manager
    ** not of the original submitter (Also, note that When we first come into the
    ** workflow, we set the APPROVER_EMPID to the submitter id).
    **
    ** NOTE: Activity "Verify Authority" always uses the APPROVER_EMPID attribute
    **       as the approver.
    */
    wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVER_EMPID',
                                 avalue   => l_superior_id);

    /* Set the forward-to ID. This is the approver that will get the notification */
    wf_engine.SetItemAttrNumber (itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'FORWARD_TO_ID',
                                 avalue   => l_superior_id);

    /* Set the value of FORWARD_TO_ID_OLD. This is used to determine if the responder
    ** to the notification entered a different USERNAME to forward the doc to.
    */
     wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'FORWARD_TO_ID_OLD',
                                   avalue     => l_superior_id);

    /* Get the username of Forward-to employee. We need to assign it to the
    ** performer of the notification */
    /*PO_REQAPPROVAL_INIT1.get_user_name(l_superior_id, x_username,
                                      x_user_display_name);*/

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_USERNAME' ,
                              avalue     => x_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'FORWARD_TO_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_USER_NAME' ,
                              avalue     => x_username);

      wf_engine.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'APPROVER_DISPLAY_NAME' ,
                              avalue     => x_user_display_name);

    close C1;
    RETURN('Y');

 ELSE

   close C1;
   RETURN('N');

 END IF;


EXCEPTION

  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_FINDAPPRV1','GetMgrPOHier',x_progress);
        raise;

END GetMgrPOHier;

--

/* Bug# 1496490
** New Procedure to check the owner can approve flag value
*/

PROCEDURE CheckOwnerCanApprove (itemtype in VARCHAR2, itemkey in VARCHAR2,
CanOwnerApprove out NOCOPY VARCHAR2)  is

	Cursor C1(p_document_type_code VARCHAR2, p_document_subtype VARCHAR2) is
	select NVL(can_preparer_approve_flag,'N')
	from po_document_types
	where document_type_code = p_document_type_code
	and   document_subtype = p_document_subtype;

l_document_type_code VARCHAR2(25);
l_document_subtype   VARCHAR2(25);
x_progress varchar2(3):= '000';

BEGIN
	x_progress := '001';
 	l_document_type_code := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

 	l_document_subtype := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');

	open C1(l_document_type_code, l_document_subtype);
	Fetch C1 into CanOwnerApprove;
	close C1;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_REQAPPROVAL_INIT1','CheckOwnerCanApprove',x_progress);
        raise;
END CheckOwnerCanApprove;

--

end PO_REQAPPROVAL_FINDAPPRV1;

/
