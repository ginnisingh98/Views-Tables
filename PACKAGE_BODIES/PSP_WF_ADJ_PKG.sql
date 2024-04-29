--------------------------------------------------------
--  DDL for Package Body PSP_WF_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_WF_ADJ_PKG" AS
/* $Header: PSPWFAJB.pls 120.0.12010000.2 2008/08/05 10:15:21 ubhat ship $ */

  /***********************************************************************
  ** Function GET_SUPERVISOR returns the employee's supervisor person ID for
  ** the given assignment. The employee
  ** person ID and assignment number are passed in. If there is no supervisor
  ** for the given assignment, -1 will be returned.
  ***************************************************************************/
   FUNCTION get_supervisor(p_person_id 	       IN NUMBER,
			   p_assignment_number IN VARCHAR2)
   RETURN NUMBER IS
      l_supervisor_id NUMBER;
/*
-- Old Cursor
      CURSOR get_supervisor_id_csr IS
         SELECT supervisor_id
         FROM   per_assignments_f
         WHERE  person_id = p_person_id
         AND    assignment_number = p_assignment_number
 	 AND    sysdate between effective_start_date and effective_end_date;
*/
-- Bug : 1994421. Cursor get_supervisor_id_csr rewritten for Enhancement Employee Assignment for Zero Work days.

      CURSOR get_supervisor_id_csr IS
      	 SELECT paf1.supervisor_id
      	 FROM   per_assignments_f paf1
      	 WHERE  paf1.person_id = p_person_id
      	 AND	paf1.assignment_number = p_assignment_number
      	 AND	paf1.effective_end_date = (SELECT max(paf2.effective_end_date)
      	 				FROM	per_assignments_f paf2
      	 				WHERE	paf2.assignment_id = paf1.assignment_id);

   BEGIN
      OPEN get_supervisor_id_csr;
      FETCH get_supervisor_id_csr INTO l_supervisor_id;
      IF get_supervisor_id_csr%NOTFOUND THEN
         l_supervisor_id := -1;
      END IF;
      CLOSE get_supervisor_id_csr;

      RETURN l_supervisor_id;
   END;

/***************************************************************************
** This Function is added for Enhancement- Employee assignments with Zero work days.
** Bug  1994421
**************************************************************************/

FUNCTION get_approver_status (p_supervisor_id IN NUMBER)
RETURN NUMBER IS
l_approver_status NUMBER;
l_valid_supervisor NUMBER;
BEGIN
	SELECT	count(*)
	INTO	l_valid_supervisor
-- 	FROM	per_people_f ppf  Commented for Bug 3741272
	FROM	per_all_people_f ppf
	WHERE	ppf.person_id = p_supervisor_id
	AND	trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
	AND 	current_employee_flag = 'Y';

	IF l_valid_supervisor > 0 THEN
		l_approver_status:=1;
	ELSE
		l_approver_status:=-1;
	END IF;
	RETURN l_approver_status;
END get_approver_status;

   /**************************************************************************/
   /*Procedure UPDATE_ADJUSTMENT_CONTROL_TABLE updated the table
     PSP_ADJUSTMENT_CONTROL_TABLE with the         */
   /*approver's UserID.                                 */
   /**************************************************************************/
   PROCEDURE update_adj_ctrl_table(p_batch_name       IN  VARCHAR2,
			           p_approver_userID  IN  NUMBER,
				   p_comments	      IN  VARCHAR2,
			           return_code        OUT NOCOPY NUMBER) IS
   BEGIN

      UPDATE psp_adjustment_control_table
      SET    approver_id = p_approver_userID,
             approval_date = SYSDATE,  -- Added to fix bug 1661405. approval_date is a new column added to table
	     comments = p_comments
      WHERE  adjustment_batch_name = p_batch_name;

      IF (SQL%NOTFOUND) THEN
         return_code := -1;
	 return;
      END IF;

      update psp_payroll_controls
	set status_code = 'N'
      where batch_name = p_batch_name
      and   source_type = 'A'
      and   status_code = 'C';

      IF (SQL%NOTFOUND) THEN
         return_code := -1;
	 return;
      END IF;

      return_code := 0;

   END update_adj_ctrl_table;

/*****************************************************************************
*This procedure is called from generate_lines procedure in PSP_ADJ_DRIVER
*when user submits the  Adjustment Batch.
****************************************************************************/
PROCEDURE init_workflow(p_batch_name 	   	IN  VARCHAR2,
		        p_person_id  	   	IN  NUMBER,
                        p_display_name     	IN  VARCHAR2,
                        p_assignment 	   	IN  VARCHAR2,
                        ---p_earnings_element 	IN  VARCHAR2,
                        p_begin_date	   	IN  DATE,
		        p_end_date	   	IN  DATE,
		        p_currency_code	   	IN  VARCHAR2,	-- Introduced for bug fix 2916848
			p_comments	   	IN  VARCHAR2,
			p_time_out		IN  NUMBER,
	                return_code        	OUT NOCOPY NUMBER)
IS
   ItemType	VARCHAR2(30) := 'PSPADJWF';
   ItemKey	VARCHAR2(30);

   l_creator_username	VARCHAR2(100);

BEGIN

   /*---------------------------------------------------------------*/
   /*1. Created the workflow process "psp_distribution_adjustment"  */
   /*---------------------------------------------------------------*/
   ItemKey := p_batch_name;

   -- dbms_output.put_line('batch Name '||p_batch_name);

   l_creator_username := FND_GLOBAL.user_name;

      wf_engine.CreateProcess( itemtype => ItemType,
                               itemkey  => ItemKey,
			       process  => 'PSP_DISTRIBUTION_ADJUSTMENT');

      /*Added for bug 7004679 */
      wf_engine.setitemowner(itemtype => ItemType,
                             itemkey  => ItemKey,
                             owner    => l_creator_username);


   /*---------------------------------------------------------------*/
   /*2. Initialize the item attributes:                             */
   /*   (1) BATCH						    */
   /*   (2) EMPLOYEE_PERSON_ID					    */
   /*   (3) EMPLOYEE_DISPLAY_NAME				    */
   /*   (4) ASSIGNMENT					            */
   /*   (5) EARNINGS_ELEMENT  					    */
   /*   (6) BEGIN_DATE						    */
   /*   (7) END_DATE                                                */
   /*   (8) CREATOR_USERNAME			                    */
   /*   (9) CREATOR_DISPLAY_NAME                                    */
   /*   (10) Comments                                               */
   /*   (11) Time Out                                               */
   /*---------------------------------------------------------------*/
   wf_engine.SetItemAttrText(itemtype => ItemType,
			     itemkey  => ItemKey,
                             aname    => 'BATCH',
                             avalue   => p_batch_name);

   wf_engine.SetItemAttrNUMBER(itemtype => ItemType,
			       itemkey  => ItemKey,
                               aname    => 'EMPLOYEE_PERSON_ID',
                               avalue   => p_person_id);

   wf_engine.SetItemAttrText(itemtype => ItemType,
			     itemkey  => ItemKey,
                             aname    => 'EMPLOYEE_DISPLAY_NAME',
                             avalue   => p_display_name);

   wf_engine.SetItemAttrText(itemtype => ItemType,
			     itemkey  => ItemKey,
                             aname    => 'ASSIGNMENT',
                             avalue   => p_assignment);
/*
   wf_engine.SetItemAttrText(itemtype => ItemType,
			     itemkey  => ItemKey,
                             aname    => 'EARNINGS_ELEMENT',
                             avalue   => p_earnings_element); */

   wf_engine.SetItemAttrDATE(itemtype => ItemType,
			     itemkey  => ItemKey,
                             aname    => 'BEGIN_DATE',
                             avalue   => p_begin_date);

   wf_engine.SetItemAttrDATE(itemtype => ItemType,
			     itemkey  => ItemKey,
                             aname    => 'END_DATE',
                             avalue   => p_end_date);

--	Introduced the following for bug fix 2916848
   wf_engine.SetItemAttrText(itemtype => ItemType,
			     itemkey  => ItemKey,
                             aname    => 'CURRENCY_CODE',
                             avalue   => p_currency_code);
--	End of bug fix 2916848


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
                             aname    => 'NOTE',
                             avalue   => p_comments);


   wf_engine.SetItemAttrNUMBER(itemtype => ItemType,
			       itemkey  => ItemKey,
                               aname    => 'TIME_OUT',
                               avalue   => p_time_out);

   -- 	dbms_output.put_line('After setting the attribute');
   /*---------------------------------------------------------------*/
   /*3. Start the workflow process "psp_distribution_adjustment"    */
   /*---------------------------------------------------------------*/
   wf_engine.StartProcess(itemtype => ItemType,
                          itemkey  => ItemKey);
--	dbms_output.put_line('After starting process');

   return_code := 0;

END init_workflow;

/***************************************************************************
** Procedure SELECT_APPROVER is called by "Select Approver" activity in the
** distribution adjustment workflow process.
** By default, the supervisor is the approver.
** If customization is needed,  enter your code in
** PSP_WF_ADJ_CUSTOM.select_approver_custom.
****************************************************************************/
PROCEDURE select_approver(itemtype IN  VARCHAR2,
                          itemkey  IN  VARCHAR2,
                          actid    IN  NUMBER,
                          funcmode IN  VARCHAR2,
                          result   OUT NOCOPY VARCHAR2)
IS

   l_person_id 			NUMBER;
   l_custom_supervisor_id	NUMBER;
   l_assignment_number		VARCHAR2(30);
   l_supervisor_id		NUMBER;
   l_approver_status		NUMBER;
   l_approver_username		VARCHAR2(100);
   l_approver_display_name 	VARCHAR2(240);
BEGIN

   IF (funcmode = 'RUN') THEN
      l_person_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
						 itemkey  => itemkey,
					         aname    => 'EMPLOYEE_PERSON_ID');
      l_assignment_number := wf_engine.GetItemAttrText(itemtype => itemtype,
						         itemkey  => itemkey,
					                 aname    => 'ASSIGNMENT');

      /*------------------------------------------------------------------
      **By default, the supervisor is the approver. To get the supervisor's
      ** person ID call get_supervisor():
      ** l_supervisor_id := get_supervisor(l_person_id, assignment_number);
      ** However, if the approver is not the employee's supervisor, we need
      ** to customize the program to select the approver.
      ** Customize code can be entered in psp_wf_adj_custom.select_approver_custom
      ** procedure and returns the appropriate supervisior id.
      **---------------------------------------------------------------------*/

      l_supervisor_id := get_supervisor(l_person_id, l_assignment_number);

-- Bug : 1994421 Code added for Enhancement Employee Assignment with Zero work days.
	IF l_supervisor_id <> -1 THEN
		l_approver_status := get_approver_status(l_supervisor_id);
	END IF;
-- Bug : 1994421 Code ended for Enhancement Employee Assignment with Zero work days.

      --for customization purpose
      -- two standard value person_id and assignment_number is passed
      -- If more values are required user can get from workflow .
      -- All internal names are given in the custom package.
  	psp_wf_adj_custom.select_approver_custom(itemtype,
                          		         itemkey,
                          			 actid,
                          		         funcmode,
						 l_person_id,
						 l_assignment_number,
						 l_custom_supervisor_id);
	if l_custom_supervisor_id is not null
	then
	    l_supervisor_id := l_custom_supervisor_id;
		l_approver_status := 0;		-- Introduced for bug fix 3443921
	end if;

      wf_directory.GetUserName('PER', l_supervisor_id, l_approver_username, l_approver_display_name);

      /*Added for bug 7004679 */
      wf_engine.setitemowner(itemtype => ItemType,
                             itemkey  => ItemKey,
                             owner    => l_approver_username);

   -- Bug :  1994421
   -- Added an IF condition to check Terminated approver or Employee (irrespective of Valid or terminated) with No approver.

    IF l_approver_status=-1 or l_supervisor_id=-1 THEN
      	result := 'COMPLETE:NOT_FOUND';
      	ELSE
      IF (wf_directory.UserActive(l_approver_username)) THEN
         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'APPROVER_USERNAME',
                                   avalue   => l_approver_username);
         wf_engine.SetItemAttrText(itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'APPROVER_DISPLAY_NAME',
                                   avalue   => l_approver_display_name);
         result := 'COMPLETE:FOUND';
       ELSE
       	result := 'COMPLETE:NOT_FOUND';
       END IF;
     END IF;
   END IF; --end of IF (funcmode = 'RUN') THEN--

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PSP_WF_ADJ_PKG', 'SELECT_APPROVER', itemtype, itemkey, to_char(actid), funcmode);
    raise;
END select_approver;

/**************************************************************************
** Procedure UNDO_DISTRIBUTION_ADJUSTMENT is called by "Undo Distribution
** Adjustment" activity in the distribution adjustment workflow process.
** If the adjustment batch is cancelled by the creator or rejected by
** the approver, the database will be returned to the state that is before
** the batch is created.
***************************************************************************/
PROCEDURE undo_distribution_adjustment(itemtype IN  VARCHAR2,
                                       itemkey  IN  VARCHAR2,
                                       actid    IN  NUMBER,
                                       funcmode IN  VARCHAR2,
                                       result   OUT NOCOPY VARCHAR2)
IS
   l_batch_name		VARCHAR2(30);
   l_comments		VARCHAR2(2000);
   l_errbuf 		VARCHAR2(2000);
   l_return_code	NUMBER;
   l_business_group_id	NUMBER;
   l_set_of_books_id	NUMBER;
BEGIN

   IF (funcmode = 'RUN') THEN
      l_batch_name := wf_engine.GetItemAttrText(itemtype => itemtype,
	   				        itemkey  => itemkey,
					        aname    => 'BATCH');

      l_comments := wf_engine.GetItemAttrText(itemtype => itemtype,
	   				        itemkey  => itemkey,
					        aname    => 'NOTE');

      l_business_group_id := to_number(psp_general.get_specific_profile('PER_BUSINESS_GROUP_ID'));

      l_set_of_books_id := to_number(psp_general.get_specific_profile('GL_SET_OF_BKS_ID'));

      psp_adj_driver.undo_adjustment(l_batch_name, l_business_group_id,
					l_set_of_books_id,l_comments,
					l_errbuf, l_return_code);
      IF (l_return_code = 0) THEN
         result := 'COMPLETE';
      ELSE
         result := 'ERROR';
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
    wf_core.context('PSP_WF_ADJ_PKG', 'UNDO_DISTRIBUTION_ADJUSTMENT', itemtype, itemkey, to_char(actid), funcmode);
    raise;
END undo_distribution_adjustment;


/***********************************************************************
** Procedure GET_APPROVAL_RESPONDER is called by workflow activity
** Get Final Approver" to figure out who is the final approver in the
** forwarding path.
************************************************************************/
PROCEDURE get_approval_responder(itemtype in varchar2,
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
--	Introduced the following for bug fix 3263333
				(SELECT	ias.notification_id
				FROM	wf_lookups l_at,
					wf_lookups l_as,
					wf_activities_vl a,
					wf_process_activities pa,
					wf_item_types_vl it,
					wf_items i,
					wf_item_activity_statuses ias
				WHERE	ias.item_type = itemtype
				AND	ias.item_key = itemkey
				AND	i.item_type = itemtype
				AND	i.item_key = itemkey
				AND	i.begin_date between a.begin_date AND nvl(a.end_date, i.begin_date)
				AND	i.item_type = it.name
				AND	ias.process_activity = pa.instance_id
				AND	pa.activity_name = a.name
				AND	pa.activity_item_type = a.item_type
				AND	l_at.lookup_type = 'WFENG_ACTIVITY_TYPE'
				AND	l_at.lookup_code = a.type
				AND	l_as.lookup_type = 'WFENG_STATUS'
				AND	l_as.lookup_code = ias.activity_status
				AND	a.name = 'NOT_APPROVAL_REQUIRED');
/*****	Commented the following for bug fix 3263333
	--(SELECT MAX(notification_id) 				Commented for bug fix 3263333
	(SELECT notification_id					-- Introduced for bug fix 3263333
	 FROM   wf_item_activity_statuses			-- changed to base table for bug fix 3263333
	 WHERE  item_type = 'PSPADJWF' AND
      	        item_key = itemkey AND
		process_activity = actid);			-- Introduced for bug fix 3263333
     	        --activity_name = 'NOT_APPROVAL_REQUIRED');	Commented for bug fox 3263333
	End of comment for bug fix 3263333	*****/
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
    WF_CORE.CONTEXT('PSP_WF_ADJ_PKG', 'GET_APPROVAL_RESPONDER', itemtype, itemkey, to_char(actid), funcmode);
    raise;
END get_approval_responder;


/************************************************************************
** Procedure RECORD_APPROVER is called by workflow activity "Record Approver".
** When the distribution adjustment batch is approved, the approver's
** user ID is recorded in table PSP_ADJUSTMENT_CONTROL_TABLE.
************************************************************************/
PROCEDURE record_approver(itemtype IN  VARCHAR2,
                          itemkey  IN  VARCHAR2,
                          actid    IN  NUMBER,
                          funcmode IN  VARCHAR2,
                          result   OUT NOCOPY VARCHAR2)
IS
   l_approver_username	VARCHAR2(100);
   l_approver_userID	NUMBER(15);
   l_batch_name		VARCHAR2(30);
   l_return_code        NUMBER;
   l_comments		VARCHAR2(2000);

   CURSOR get_user_id_csr IS
      SELECT user_id
      FROM   fnd_user
      WHERE  user_name = l_approver_username;
BEGIN

   IF (funcmode = 'RUN') THEN
      l_approver_username := wf_engine.GetItemAttrText(itemtype => itemtype,
						       itemkey  => itemkey,
						       aname    => 'APPROVER_USERNAME');

      OPEN get_user_id_csr;
      FETCH get_user_id_csr INTO l_approver_userID;
      CLOSE get_user_id_csr;

      IF l_approver_userID IS NULL THEN
         result := 'ERROR';
      ELSE
         l_batch_name := wf_engine.GetItemAttrText(itemtype => itemtype,
						   itemkey  => itemkey,
						   aname    => 'BATCH');
         l_comments := wf_engine.GetItemAttrText(itemtype => itemtype,
						   itemkey  => itemkey,
						   aname    => 'NOTE');
     	 update_adj_ctrl_table(l_batch_name, l_approver_userID,l_comments, l_return_code);
         IF l_return_code = -1 THEN
            result := 'ERROR';
         ELSE
            result := 'COMPLETE';
         END IF;
      END IF;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_ADJ_PKG', 'GET_APPROVAL_RESPONDER', itemtype, itemkey, to_char(actid), funcmode);
    raise;
END record_approver;

/***************************************************************************
** This procedure can be used to omit the approval step. The valid return
** values are COMPLETE:N or COMPLETE:Y. Present Code is assumed approval
** required and the value is set to N.
** If the value is set to 'Y' then adjustment will directly be approved
** and ready for S and T.
** Customization code can be put in
** psp_wf_adj_custom.omit_approval_custom.
**************************************************************************/
PROCEDURE omit_approval (itemtype IN  VARCHAR2,
                          itemkey  IN  VARCHAR2,
                          actid    IN  NUMBER,
                          funcmode IN  VARCHAR2,
                          result   OUT NOCOPY VARCHAR2)
IS
	p_omit_approval		VARCHAR2(1);
BEGIN
	psp_wf_adj_custom.omit_approval_custom
                        (itemtype,
                          itemkey,
                          actid,
                          funcmode,
                          p_omit_approval);
	if p_omit_approval = 'N' -- preferred value
	then
        	result := 'COMPLETE:N';
	elsif p_omit_approval = 'Y'
	then
        	result := 'COMPLETE:Y';
	end if;
END omit_approval;

/****************************************************************************
** This procedure record creator as approver in case of OMIT_APPROVAL returns Y
** means approval is not required from approver. At present approver is creator.
** If customization is required please enter your code in
** psp_wf_adj_custom.record_creator_custom package.
******************************************************************************/
PROCEDURE record_creator (itemtype IN  VARCHAR2,
                          itemkey  IN  VARCHAR2,
                          actid    IN  NUMBER,
                          funcmode IN  VARCHAR2,
                          result   OUT NOCOPY VARCHAR2)
IS
    l_creator_username		VARCHAR2(100);
    l_creator_user_id		NUMBER;
    l_custom_approver_id	NUMBER;
    l_batch_name		VARCHAR2(100);
    l_comments			VARCHAR2(2000);
    l_return_code		NUMBER;
BEGIN
   IF (funcmode = 'RUN') THEN
      l_creator_username := wf_engine.GetItemAttrText(itemtype => itemtype,
						      itemkey  => itemkey,
						      aname    => 'CREATOR_USERNAME');
    BEGIN
      SELECT user_id
      into l_creator_user_id
      FROM   fnd_user
      WHERE  user_name = l_creator_username;
    EXCEPTION
	WHEN  OTHERS THEN
 		result := 'ERROR';
    end;

      IF l_creator_user_id IS NULL THEN
         result := 'ERROR';
      ELSE
         l_batch_name := wf_engine.GetItemAttrText(itemtype => itemtype,
						   itemkey  => itemkey,
						   aname    => 'BATCH');
         l_comments := wf_engine.GetItemAttrText(itemtype => itemtype,
						   itemkey  => itemkey,
						   aname    => 'NOTE');

	psp_wf_adj_custom.record_creator_custom(
                        		itemtype,
                          		itemkey,
                          		actid,
                          		funcmode,
					l_custom_approver_id);
	if l_custom_approver_id is not null
	then
		l_creator_user_id := l_custom_approver_id;
	end if;

     	 update_adj_ctrl_table(l_batch_name, l_creator_user_id,l_comments, l_return_code);
         IF l_return_code = -1 THEN
            result := 'ERROR';
         ELSE
            result := 'COMPLETE';
         END IF;
      END IF;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('PSP_WF_ADJ_PKG', 'RECORD_CREATOR', itemtype, itemkey, to_char(actid), funcmode);
    raise;
END record_creator;

END psp_wf_adj_pkg;

/
