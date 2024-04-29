--------------------------------------------------------
--  DDL for Package Body PSP_WF_EFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_WF_EFF_PKG" AS
/* $Header: PSPWFEFB.pls 120.0.12010000.4 2008/08/05 10:16:06 ubhat ship $ */

  /*****************************************************************
   *Function UPDATE_STATUS updates the status of effort		   *
   *report. It is called by STATUS_APPROVED, STATUS_REJECTED,	   *
   *STATUS_CERTIFIED, STATUS_NEW, STATUS_SUPERSEDED.		   *
   *****************************************************************/
  function UPDATE_STATUS(itemkey  in varchar2,
		         funcmode in varchar2,
		         status   in varchar2) return VARCHAR2;

/**********************************************************************************
**Function INIT_WORKFLOW is called when an effort report is created. It is called**
**from package psp_efforts_pkg.crt. This creates the workflow process, populates **
**attributes, and starts the process.						 **
***********************************************************************************/
function INIT_WORKFLOW(a_template_id IN NUMBER)
return NUMBER
IS
  ItemType 	VARCHAR2(30) := 'PSPEFFWF';
  ItemKey      	VARCHAR2(30);

  l_omit_approval_step 	VARCHAR2(1);
  l_creator_username  	VARCHAR2(100);
  l_report_id 		NUMBER;
-- Fix bug 954141
  l_report_id1		NUMBER;
  l_max_ver		NUMBER;
-- End fix bug 954141
  l_person_id     	NUMBER;
  l_begin_date        	DATE;
  l_end_date           	DATE;
  l_emp_display_name    VARCHAR2(240);
  l_emp_username      	VARCHAR2(100);

-- Start fix bug 954141. Added the max(version) and group by in the
-- cursor below. Concatenate these two and initiate WF.
  CURSOR get_report_id_csr IS
    SELECT effort_report_id, max(version_num)
    FROM   psp_effort_reports
    WHERE  template_id=a_template_id
    GROUP BY effort_report_id;

  CURSOR get_emp_id_csr IS
    SELECT person_id
    FROM   psp_effort_reports
    WHERE  effort_report_id = l_report_id;

  CURSOR get_period_details_csr IS
    SELECT Begin_date,
           End_date
    FROM   psp_effort_report_templates
    WHERE  template_id = a_template_id;

  CURSOR get_emp_display_name IS
   SELECT full_name
   FROM   per_all_people_f
   WHERE person_id =l_person_id
   AND   effective_end_date   >= l_begin_date
   AND   effective_start_date <= l_end_date
   ORDER BY effective_start_date desc;

BEGIN

     OPEN get_report_id_csr;
     LOOP
       FETCH get_report_id_csr INTO l_report_id, l_max_ver;
       EXIT WHEN get_report_id_csr%NOTFOUND;
       l_report_id1 := to_char(l_report_id) || to_char(l_max_ver);
--       ItemKey   := to_char(l_report_id); /* Fix 954141 */
	ItemKey := l_report_id1;
       /*-----------------------------*/
       /*Create a new workflow process*/
       /*-----------------------------*/

       l_creator_username := FND_GLOBAL.user_name;

       wf_engine.CreateProcess(itemtype => ItemType,
                               itemkey  => ItemKey,
			       process  => 'EFFORT_REPORT_WF');

       /*Added for bug 7004679 */
        wf_engine.setitemowner(itemtype => ItemType,
                               itemkey  => ItemKey,
                               owner    => l_creator_username);

      /*----------------------------------------------------------------------------------------*/
      /*Set Item Attributes                      						*/
      /*1.  PROCESS   ----- keep track which phase workflow is in(APPROVAL/CERTIFICATION)	*/
      /*2.  CEATOR_USERNAME			 						*/
      /*3.  CREATOR_DISPLAY_NAME                  						*/
      /*4.  EMPLOYEE_PERSON_ID									*/
      /*5.  EMPLOYEE_USERNAME									*/
      /*6.  EMPLOYEE_DISPLAY_NAME								*/
      /*7.  REPORT_ID	---\									*/
      /*8.  BEGIN_DATE	------ effort report related info					*/
      /*9.  END_DATE    ---/									*/
      /*10. TEMPLATE_ID                                                                         */
      /*----------------------------------------------------------------------------------------*/

       l_omit_approval_step := wf_engine.GetItemAttrText(itemtype, itemkey, 'OMIT_APPROVAL_STEP');
       IF (l_omit_approval_step = 'Y') THEN
	 wf_engine.SetItemAttrText(itemtype => ItemType,
		  		   itemkey  => ItemKey,
				   aname    => 'PROCESS',
				   avalue   => 'CERTIFICATION');
       ELSE
         wf_engine.SetItemAttrText(itemtype => ItemType,
				   itemkey  => ItemKey,
				   aname    => 'PROCESS',
				   avalue   => 'APPROVAL');
       END IF;

       wf_engine.SetItemAttrText(itemtype => ItemType,
				 itemkey  => ItemKey,
				 aname    => 'CREATOR_USERNAME',
				 avalue   => l_creator_username);

	wf_engine.SetItemAttrText(itemtype => ItemType,
                                  itemkey  => ItemKey,
                                  aname    => 'CREATOR_DISPLAY_NAME',
                                  avalue   => wf_directory.GetRoleDisplayName(l_creator_username));

	wf_engine.SetItemAttrText(itemtype => ItemType,
                                  itemkey  => ItemKey,
                                  aname    => 'REPORT_ID',
                                  avalue   => l_report_id);

  	OPEN get_period_details_csr;
  	FETCH get_period_details_csr INTO l_begin_date, l_end_date;
  	CLOSE get_period_details_csr;

	wf_engine.SetItemAttrText(itemtype => ItemType,
                                  itemkey  => ItemKey,
                                  aname    => 'BEGIN_DATE',
                                  avalue   => l_begin_date);

	wf_engine.SetItemAttrText(itemtype => ItemType,
                                  itemkey  => ItemKey,
                                  aname    => 'END_DATE',
                                  avalue   => l_end_date);

	OPEN get_emp_id_csr;
	FETCH get_emp_id_csr INTO l_person_id;
	CLOSE get_emp_id_csr;

        wf_directory.GetUserName('PER', l_person_id, l_emp_username, l_emp_display_name);

/*Bug 5145170: person name is null when he dont have any record in fnd users
In this case get the name from per_all_people_f*/


	IF (l_emp_display_name IS NULL) THEN
	    OPEN get_emp_display_name;
	    FETCH get_emp_display_name INTO l_emp_display_name;
	    CLOSE get_emp_display_name;
        END IF;

  	wf_engine.SetItemAttrText(itemtype => ItemType,
                                  itemkey  => ItemKey,
                                  aname    => 'EMPLOYEE_PERSON_ID',
                                  avalue   => l_person_id);

   	wf_engine.SetItemAttrText(itemtype => ItemType,
                                  itemkey  => ItemKey,
                                  aname    => 'EMPLOYEE_USERNAME',
                                  avalue   => l_emp_username);

  	wf_engine.SetItemAttrText(itemtype => ItemType,
                                  itemkey  => ItemKey,
                                  aname    => 'EMPLOYEE_DISPLAY_NAME',
                                  avalue   => l_emp_display_name);

  	wf_engine.SetItemAttrText(itemtype => ItemType,
                                  itemkey  => ItemKey,
                                  aname    => 'TEMPLATE_ID',
                                  avalue   => a_template_id);

	/*-----------------------------------------------------*/
        /*Start the workflow process                           */
        /*-----------------------------------------------------*/
	wf_engine.startprocess(itemtype => ItemType,
                               itemkey  => ItemKey);
     END LOOP;
     CLOSE get_report_id_csr;

     RETURN(0);
EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN(-1);
      WHEN OTHERS THEN
         RETURN(-2);
END INIT_WORKFLOW;

/*********************************************************
**Procedure OMIT_APPROVAL_STEP checks the value of the	**
**attribute by the same name in the workflow process and**
**sends the result. This procedure is called by the 	**
**workflow activity OMIT_APPROVAL_STEP.			**
**********************************************************/
procedure OMIT_APPROVAL_STEP (itemtype in varchar2,
                              itemkey  in varchar2,
                              actid    in number,
                              funcmode in varchar2,
                              result   out NOCOPY varchar2)
IS
  l_omit_approval_step VARCHAR2(1);
BEGIN

  IF (funcmode = 'RUN') THEN
    l_omit_approval_step := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'OMIT_APPROVAL_STEP');
    result := 'COMPLETE:'||l_omit_approval_step;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'OMIT_APPROVAL_STEP', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END OMIT_APPROVAL_STEP;

/**************************************************************
**Procedure CAN_EMPLOYEE_APPROVE checks the value of the item**
**attribute CAN_EMPLOYEE_APPROVE and sends the result to     **
**workflow process. This procedure is called by the          **
**workflow activity "Can Employee Approve".		     **
***************************************************************/
procedure CAN_EMPLOYEE_APPROVE(itemtype in varchar2,
                               itemkey  in varchar2,
                               actid    in number,
                               funcmode in varchar2,
                               result   out NOCOPY varchar2)
IS
  l_can_employee_approve            varchar2(1);
BEGIN

  IF (funcmode = 'RUN') THEN
   l_can_employee_approve := wf_engine.GetItemAttrText(itemtype, itemkey, 'CAN_EMPLOYEE_APPROVE');
   result := 'COMPLETE:'||l_can_employee_approve;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'CAN_EMPLOYEE_APPROVE', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END CAN_EMPLOYEE_APPROVE;

/************************************************************
**PROCEDURE CAN_SUPERVISOR_CERTIFY checks if supervisor can**
**certify the effort report. If yes, set the certifier's   **
**display name and username.				   **
*************************************************************/
procedure CAN_SUPERVISOR_CERTIFY (itemtype in varchar2,
                                  itemkey  in varchar2,
                              	  actid    in number,
                                  funcmode in varchar2,
                                  result   out NOCOPY varchar2)
IS
  l_can_supervisor_certify 	VARCHAR2(1);
BEGIN

  IF (funcmode = 'RUN') THEN
    l_can_supervisor_certify := wf_engine.GetItemAttrText(itemtype, itemkey, 'CAN_SUPERVISOR_CERTIFY');
    result := 'COMPLETE:'||l_can_supervisor_certify;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'CAN_SUPERVISOR_CERTIFY', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END CAN_SUPERVISOR_CERTIFY;

/***********************************************************
**Procedure VERIFY_EMPLOYEE checks if employee username   **
**exists and populates the item attriutes                 **
**APPROVER_USERNAME and APPROVER_DISPLAY_NAME with the    **
**employee's. username and display name. This procedure is**
**called by the workflow activity VERIFY_EMPLOYEE.        **
************************************************************/
procedure VERIFY_EMPLOYEE(itemtype in varchar2,
                          itemkey  in varchar2,
                          actid    in number,
                          funcmode in varchar2,
                          result   out NOCOPY varchar2)
IS
  l_employee_username		VARCHAR2(100);
  l_employee_display_name 	VARCHAR2(240);
BEGIN

  IF (funcmode = 'RUN') THEN
    l_employee_username := wf_engine.GetItemAttrText(itemtype, itemkey, 'EMPLOYEE_USERNAME');
    wf_engine.SetItemAttrText(itemtype, itemkey, 'APPROVER_USERNAME', l_employee_username);
    l_employee_display_name := wf_engine.GetItemAttrText(itemtype, itemkey, 'EMPLOYEE_DISPLAY_NAME');
    wf_engine.SetItemAttrText(itemtype, itemkey, 'APPROVER_DISPLAY_NAME', l_employee_display_name);

    IF (wf_directory.UserActive(l_employee_username) = TRUE) THEN
      result := 'COMPLETE:FOUND';
    ELSE
      result := 'COMPLETE:NOT_FOUND';
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'VERIFY_EMPLOYEE', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END VERIFY_EMPLOYEE;

/*******************************************************************************
 *Procedure VERIFY_SUPERVISOR is called by workflow activity VERIFY SUPERVISOR.*
 *It finds the supervisor for EMPLOYEE and populdate item attributes:          *
 *certifier_username and certifier_display_name. The procedure returns         *
 *COMPLETE:Found if the supervisor is found; returns COMPLETE:Not Found, if    *
 *the supervisor cannot be found.					       *
 *******************************************************************************/
procedure VERIFY_SUPERVISOR(itemtype in  varchar2,
			    itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out NOCOPY varchar2)
IS
  l_employee_id			NUMBER;
  l_supervisor_id		NUMBER;

  l_certifier_username 		VARCHAR2(100); --column USER_NAME in FND_USER is VARCHAR2(100)
  l_certifier_display_name	VARCHAR2(240); --column FULL_NAME in PER_PEOPLE_F is VARCHAR2(240)

  CURSOR get_supervisor_id_csr IS
    SELECT assignment.supervisor_id
    FROM   per_assignments_f assignment,
           per_people_f      people
    WHERE  assignment.person_id = l_employee_id
    AND    assignment.supervisor_id = people.person_id
    AND    assignment.assignment_type ='E'  --Added for bug 2624259.
    AND    trunc(SYSDATE) BETWEEN people.effective_start_date AND people.effective_end_date
    AND    assignment.primary_flag = 'Y';

BEGIN

    IF (funcmode = 'RUN') THEN ---<<OUTER IF..THEN>>
      l_employee_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'EMPLOYEE_PERSON_ID');

      OPEN get_supervisor_id_csr;
      FETCH get_supervisor_id_csr INTO l_supervisor_id;
      IF (get_supervisor_id_csr%NOTFOUND) THEN
        l_supervisor_id := -1;
      END IF;
      CLOSE get_supervisor_id_csr;

      wf_directory.GetUserName('PER', l_supervisor_id, l_certifier_username, l_certifier_display_name);

      IF ((l_supervisor_id <> -1) AND
          (l_certifier_username IS NOT NULL) AND (l_certifier_display_name IS NOT NULL) AND
	  (wf_directory.UserActive(l_certifier_username))) THEN
	result := 'COMPLETE:FOUND';
      ELSE
        result := 'COMPLETE:NOT_FOUND';
      END IF;

        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'CERTIFIER_USERNAME',
                                  avalue   => l_certifier_username);

        wf_engine.SetItemAttrText(itemType => itemtype,
                                  itemKey  => itemkey,
                                  aname    => 'CERTIFIER_DISPLAY_NAME',
                                  avalue   => l_certifier_display_name);


    END IF; ---<<OUTER IF..THEN>>

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'VERIFY_SUPERVISOR', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END VERIFY_SUPERVISOR;

/*****************************************************************
**Function UPDATE_STATUS updates the status of effort		**
**report. It is called by STATUS_APPROVED, STATUS_REJECTED,	**
**STATUS_CERTIFIED, STATUS_NEW, STATUS_SUPERSEDED.		**
******************************************************************/
function UPDATE_STATUS(itemkey  in varchar2,
		       funcmode in varchar2,
		       status   in varchar2)
return VARCHAR2
IS
  l_version_num NUMBER;
--Bug# 954141
  l_rep_id	varchar2(30);
--Bug# 954141
BEGIN

  IF (funcmode = 'RUN') THEN

--Bug# 954141
  l_rep_id := substr(itemkey, 1, length(itemkey) - 1 );
-- Bug# 954141

    SELECT max(version_num) INTO l_version_num
    FROM psp_effort_reports
--    WHERE effort_report_id = to_number(itemkey);
    WHERE effort_report_id = to_number(l_rep_id);
--Bug# 954141

    UPDATE psp_effort_reports
    SET status_code = status
--    WHERE effort_report_id = to_number(itemkey);
    WHERE effort_report_id = to_number(l_rep_id)
      AND version_num = l_version_num;
--Bug# 954141

    RETURN('COMPLETE');

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN('ERROR:'||TO_CHAR(SQLCODE));

END UPDATE_STATUS;

/*****************************************************************
**PROCEDURE STATUS_APPROVED updates the status of effort	**
**report to 'A'. It is called in the workflow activity UPDATE_EF**
**FORT_REPORT_STATUS_TO_APPROVED.				**
******************************************************************/
procedure STATUS_APPROVED(itemtype in varchar2,
                          itemkey  in varchar2,
                          actid    in number,
                          funcmode in varchar2,
                          result   out NOCOPY varchar2) IS
BEGIN

  IF (funcmode = 'RUN') THEN
    result := update_status(itemkey, funcmode, 'A');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'STATUS_APPROVED', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END STATUS_APPROVED;

/************************************************************
**PROCEDURE STATUS_SUPERSEDED updates the status of effort **
**report to 'S'. It is called in workflow activity 	   **
**UPDATE_EFFORT_REPORT_STATUS_TO_SUPERSEDED.               **
*************************************************************/
procedure STATUS_SUPERSEDED(itemtype in varchar2,
                            itemkey  in varchar2,
                            actid    in number,
                            funcmode in varchar2,
                            result   out NOCOPY varchar2) IS
BEGIN

  IF (funcmode = 'RUN') THEN
    result := update_status(itemkey, funcmode, 'S');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'STATUS_SUPERSEDED', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END STATUS_SUPERSEDED;

/**********************************************************
**PROCEDURE STATUS_CERTIFIED updates the status of effort**
**report to 'C'. It is called in workflow activity       **
**UPDATE_EFFORT_REPORT_STATUS_TO_CERTIFIED.		 **
***********************************************************/
procedure STATUS_CERTIFIED(itemtype in varchar2,
                           itemkey  in varchar2,
                           actid    in number,
                           funcmode in varchar2,
                           result   out NOCOPY varchar2) IS
BEGIN

  IF (funcmode = 'RUN') THEN
    result := update_status(itemkey, funcmode, 'C');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'STATUS_CERTIFIED', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END STATUS_CERTIFIED;

/*********************************************************
**PROCEDURE STATUS_REJECTED updates the status of effort**
**report to 'R'. It is called by a workflow activity    **
**"Update Effort Report Status to Rejected".   		**
**********************************************************/
procedure STATUS_REJECTED    (itemtype in varchar2,
                              itemkey  in varchar2,
                              actid    in number,
                              funcmode in varchar2,
                              result   out NOCOPY varchar2) IS
BEGIN

  IF (funcmode = 'RUN') THEN
    result := update_status(itemkey, funcmode, 'R');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'STATUS_REJECTED', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END STATUS_REJECTED;

/***********************************************************************
**Procedure SELECT_CERTIFIER is called by a workflow process "Select  **
**Certifier". It is invoked if user profile option "PSP:Can Supervisor**
**Certify" is set to "No". Procedure SELECT_CERTIFIER makes a call to **
**PSP_WF_CUSTOM.EFFORT_SELECT_CERTIFIER, where users can customize who**
**the certifer is.                                                    **
************************************************************************/
procedure SELECT_CERTIFIER(itemtype in varchar2,
                           itemkey  in varchar2,
                           actid    in number,
                           funcmode in varchar2,
                           result   out NOCOPY varchar2)
IS
  l_emp_id 		NUMBER;
  l_certifier_id       	NUMBER;
  l_certifier_username		VARCHAR2(100);
  l_certifier_display_name 	VARCHAR2(240);
BEGIN

  IF (funcmode = 'RUN') THEN
    l_emp_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'EMPLOYEE_PERSON_ID');
    psp_wf_custom.effort_select_certifier(l_emp_id, l_certifier_id);
    wf_directory.GetUserName('PER', l_certifier_id, l_certifier_username, l_certifier_display_name);

    IF ((l_certifier_username IS NOT NULL) AND (l_certifier_display_name IS NOT NULL) AND (wf_directory.UserActive(l_certifier_username))) THEN
      wf_engine.SetItemAttrText(itemtype, itemkey, 'CERTIFIER_USERNAME', l_certifier_username);
      wf_engine.SetItemAttrText(itemtype, itemkey, 'CERTIFIER_DISPLAY_NAME', l_certifier_display_name);
      result := 'COMPLETE:FOUND';
    ELSE
      wf_engine.SetItemAttrText(itemtype, itemkey, 'CERTIFIER_USERNAME', NULL);
      wf_engine.SetItemAttrText(itemtype, itemkey, 'CERTIFIER_DISPLAY_NAME', NULL);
      result := 'COMPLETE:NOT_FOUND';
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'SELECT_CERTIFIER', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_CERTIFIER;

/***********************************************************************
**Procedure SELECT_APPROVER is called by a workflow process "Select   **
**Approver". It is invoked if user profile option "PSP:Can Employee   **
**Approve" is set to "No". Procedure SELECT_APPROVER makes a call to  **
**PSP_WF_CUSTOM.EFFORT_SELECT_APPROVER, where users can customize who **
**the approver is.                                                    **
************************************************************************/
procedure SELECT_APPROVER     (itemtype in varchar2,
                              itemkey  in varchar2,
                              actid    in number,
                              funcmode in varchar2,
                              result   out NOCOPY varchar2)
IS
  l_emp_id			NUMBER;
  l_approver_id	   		NUMBER;
  l_approver_username	        VARCHAR2(100);
  l_approver_display_name	VARCHAR2(240);
BEGIN

  IF (funcmode = 'RUN') THEN
    l_emp_id := wf_engine.GetItemAttrNumber(itemtype, itemkey, 'EMPLOYEE_PERSON_ID');
    psp_wf_custom.effort_select_approver(l_emp_id, l_approver_id);
    wf_directory.GetUserName('PER', l_approver_id, l_approver_username, l_approver_display_name);

    IF ((l_approver_username IS NOT NULL) AND (l_approver_display_name IS NOT NULL) AND (wf_directory.UserActive(l_approver_username))) THEN
      wf_engine.SetItemAttrText(itemtype, itemkey, 'APPROVER_USERNAME', l_approver_username);
      wf_engine.SetItemAttrText(itemtype, itemkey, 'APPROVER_DISPLAY_NAME', l_approver_display_name);
      result := 'COMPLETE:FOUND';
    ELSE
      wf_engine.SetItemAttrText(itemtype, itemkey, 'APPROVER_USERNAME', NULL);
      wf_engine.SetItemAttrText(itemtype, itemkey, 'APPROVER_DISPLAY_NAME', NULL);
      result := 'COMPLETE:NOT_FOUND';
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'SELECT_APPROVER', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_APPROVER;

/***********************************************************************
**Procedure GET_APPROVAL_RESPONDER is called by a workflow process    **
**"Get Final Approver's Name".                                        **
************************************************************************/
procedure GET_APPROVAL_RESPONDER(itemtype in varchar2,
                                 itemkey  in varchar2,
                                 actid    in number,
                                 funcmode in varchar2,
                                 result   out NOCOPY varchar2)
IS
  l_responder_username 		VARCHAR2(100);
  l_responder_display_name	VARCHAR2(240);

  CURSOR get_approval_responder_csr IS
    SELECT responder
    FROM   wf_notifications
    WHERE  notification_id =
	--(SELECT MAX(notification_id) 			Commented for bug fix 3263333
	(SELECT notification_id 			-- Introduced for bug fix 3263333
	 FROM   wf_item_activity_statuses		-- Changed to base table for bug fix 3263333
	 WHERE  item_type = 'PSPEFFWF' AND
      	        item_key = itemkey AND
		process_activity = actid);		-- Introduced for bug fix 3263333
     	        --activity_name = 'NOTIFY_APPROVER');	Commented for bug fix 3263333
BEGIN

  IF (funcmode = 'RUN') THEN
    OPEN get_approval_responder_csr;
    FETCH get_approval_responder_csr INTO l_responder_username;
    CLOSE get_approval_responder_csr;

    l_responder_display_name := wf_directory.GetRoleDisplayName(l_responder_username);

    wf_engine.SetItemAttrText(itemtype, itemkey, 'APPROVER_USERNAME', l_responder_username);
    wf_engine.SetItemAttrText(itemtype, itemkey, 'APPROVER_DISPLAY_NAME', l_responder_display_name);

    result := 'COMPLETE';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'GET_APPROVAL_RESPONDER', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END GET_APPROVAL_RESPONDER;

/****************************************************************************
**Procedure GET_CERTIFICATION_RESPONDER is called by a workflow process    **
**"Get Final Certifier's Name".                                            **
*****************************************************************************/
procedure GET_CERTIFICATION_RESPONDER(itemtype in varchar2,
                                      itemkey  in varchar2,
                                      actid    in number,
                                      funcmode in varchar2,
                                      result   out NOCOPY varchar2)
IS
  l_responder_username 		VARCHAR2(100);
  l_responder_display_name	VARCHAR2(240);

  CURSOR get_cert_responder_csr IS
    SELECT responder
    FROM   wf_notifications
    WHERE  notification_id =
	--(SELECT MAX(notification_id) 			Commented for bug fix 3263333
	(SELECT notification_id				-- Introduced for bug fix 3263333
	 FROM   wf_item_activity_statuses		-- changed to base table for bug fix 3263333
	 WHERE  item_type = 'PSPEFFWF' AND
      	        item_key = itemkey AND
		process_activity = actid);		-- Introduced for bug fix 3263333
     	        --activity_name = 'NOTIFY_CERTIFIER');	Commented for bug fix 3263333
BEGIN

  IF (funcmode = 'RUN') THEN
    OPEN get_cert_responder_csr;
    FETCH get_cert_responder_csr INTO l_responder_username;
    CLOSE get_cert_responder_csr;

    l_responder_display_name := wf_directory.GetRoleDisplayName(l_responder_username);

    wf_engine.SetItemAttrText(itemtype, itemkey, 'CERTIFIER_USERNAME', l_responder_username);
    wf_engine.SetItemAttrText(itemtype, itemkey, 'CERTIFIER_DISPLAY_NAME', l_responder_display_name);

    result := 'COMPLETE';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'GET_CERTIFICATION_RESPONDER', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END GET_CERTIFICATION_RESPONDER;


/***************************************************************************************************
Created By 	:	skotwal

Date Created By :	17-SEP-2001

Purpose 	:	For the Enhancement Zero Work Days

Know limitations, enhancements or remarks

Change History

Who			When 		What
skotwal 		17-SEP-2001	Creating the procedure
					This  procedure checks whether the employee has been
					terminated or not. If terminated it returns a value 'Y'
					which will then redirect the workflow to skip the Approval
					Process and lead towards Certification Process

***************************************************************************************************/
procedure VERIFY_TERM_EMPLOYEE(itemtype in  varchar2,
			       itemkey  in  varchar2,
                               actid    in  number,
                               funcmode in  varchar2,
                               result   out NOCOPY varchar2)
IS

  l_current_employee_flag	VARCHAR2(1);
  l_person_id			NUMBER(9);

  CURSOR get_term_employee_csr IS
    SELECT ppf.current_employee_flag
    FROM   per_people_f ppf
    WHERE  ppf.person_id = l_person_id
    AND    trunc(SYSDATE) BETWEEN trunc(ppf.effective_start_date) AND trunc(ppf.effective_end_date);


BEGIN
    IF (funcmode = 'RUN') THEN
      l_person_id  := WF_ENGINE.GetItemAttrText(itemtype, itemkey, 'EMPLOYEE_PERSON_ID');

      OPEN get_term_employee_csr;
      FETCH get_term_employee_csr INTO l_current_employee_flag;
      CLOSE get_term_employee_csr;

      IF (l_current_employee_flag IS NULL) THEN
	 wf_engine.SetItemAttrText(itemtype => ItemType,
		  		   itemkey  => ItemKey,
				   aname    => 'PROCESS',
				   avalue   => 'CERTIFICATION');
       result := 'COMPLETE:Y';
      ELSE
       result := 'COMPLETE:N';
      END IF;

    END IF;
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_EFF_PKG', 'VERIFY_TERM_EMPLOYEE', itemtype, itemkey, to_char(actid), funcmode);
    raise;

END VERIFY_TERM_EMPLOYEE;



END psp_wf_eff_pkg;


/
