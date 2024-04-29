--------------------------------------------------------
--  DDL for Package Body PO_APPROVAL_LIST_HISTORY_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_APPROVAL_LIST_HISTORY_SV" AS
/* $Header: POXWAHIB.pls 120.4.12010000.9 2013/04/24 05:57:15 uchennam ship $*/

PROCEDURE UpdateActionHistory(p_more_info_id           IN NUMBER,
                              p_original_recipient_id  IN NUMBER,
                              p_responder_id           IN NUMBER,
                              p_last_approver          IN BOOLEAN,
                              p_action_code            IN VARCHAR2,
                              p_note                   IN VARCHAR2,
                              p_req_header_id          IN NUMBER,
   			      p_app_and_fwd_flag       IN BOOLEAN );

procedure Forward_Action_History(itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 x_approval_path_id in number,
                                 x_req_header_id    in number,
				 x_forward_to_id in number) IS

pragma AUTONOMOUS_TRANSACTION;

  l_progress                  VARCHAR2(100) := '000';
  x_count number := 0;
  x_sequence_num              NUMBER;
  e_invalid_action       EXCEPTION;
  e_no_forward_to_id     EXCEPTION;
  l_note varchar2(4000); /* Bug 5142600 */

  CURSOR C IS
  SELECT  object_id,
          object_type_code,
          object_sub_type_code,
          sequence_num,
          object_revision_num,
          request_id,
          program_application_id,
          program_date,
          program_id,
          last_update_date,
          employee_id
    FROM  PO_ACTION_HISTORY
   WHERE  object_type_code = 'REQUISITION'
     AND  object_id  = x_req_header_id
     AND  sequence_num = x_sequence_num;

   Recinfo C%ROWTYPE;


BEGIN

   SELECT count(*)
     INTO x_count
     FROM PO_ACTION_HISTORY
    WHERE object_type_code = 'REQUISITION'
      AND object_id   = x_req_header_id
      AND action_code IS NULL;

   l_progress := '010';

   /*
   ** the only case where we can have a null role in
   ** POAH is the first call, since the workflow submission
   ** code inserts the first NULL row
   */

   IF (x_count > 1) THEN

     RAISE e_invalid_action;

   ELSE

      SELECT max(sequence_num)
        INTO x_sequence_num
        FROM PO_ACTION_HISTORY
       WHERE object_type_code = 'REQUISITION'
         AND object_id = x_req_header_id;

        OPEN C;

          FETCH C INTO Recinfo;

        IF (C%NOTFOUND) then
           RAISE NO_DATA_FOUND;
        END IF;

        CLOSE C;

        /*
        ** if it is the first call and it gets here it means there is
        ** an implicit forward.  We want to update the
        ** first NULL row in POAH with FORWARD action
        */

        IF (x_count = 1) THEN
/*bug 5142600: need to update the note also */
        l_note := wf_engine.GetItemAttrText(itemtype=>itemtype,
	                                    itemkey=>itemkey,
					    aname=>'NOTE');
           po_forward_sv1.update_action_history (
   		Recinfo.object_id,
   		Recinfo.object_type_code,
   		Recinfo.employee_id,
   		'FORWARD',
   		l_note,
   		fnd_global.user_id,
   		fnd_global.login_id
            );

           l_progress := '015';

        END IF;

        l_progress := '020';


        IF (x_forward_to_id is NULL) THEN
           -- dbms_output.put_line ('Null forward to id in approve/forward or forward ! ');
           RAISE e_no_forward_to_id;
        ELSE
           po_forward_sv1.insert_action_history (
      	   Recinfo.object_id,
      	   Recinfo.object_type_code,
     	   Recinfo.object_sub_type_code,
     	   Recinfo.sequence_num+1,
     	   NULL,
     	   NULL,
     	   x_forward_to_id,
     	   x_approval_path_id,
     	   NULL,
     	   Recinfo.object_revision_num,
     	   NULL,                  /* offline_code */
     	   Recinfo.request_id,
     	   Recinfo.program_application_id,
     	   Recinfo.program_id,
     	   Recinfo.program_date,
     	   fnd_global.user_id,
     	   fnd_global.login_id);

           l_progress := '040';


         END IF;
    END IF;

   l_progress := '050';

   commit;

EXCEPTION
  WHEN e_invalid_action THEN
   RAISE;

  WHEN e_no_forward_to_id THEN
   RAISE;

  WHEN others THEN
   RAISE;

END Forward_Action_History;


procedure Update_Action_History(itemtype        in varchar2,
                                itemkey         in varchar2,
				x_action	in varchar2,
				x_req_header_id in number,
				x_last_approver in boolean,
				x_note          in varchar2) IS

  l_progress                  VARCHAR2(100) := '000';
  x_action_code               VARCHAR2(24)  := NULL;
  x_responder_id              wf_local_roles.ORIG_SYSTEM_ID%TYPE;
  x_notification_id           NUMBER;
  e_invalid_action            EXCEPTION;
  l_responder                 wf_notifications.responder%TYPE;
  l_employee_id               NUMBER;
  l_original_recipient_id     NUMBER;
  l_original_recipient        wf_notifications.original_recipient%TYPE;
  l_recipient_role            wf_notifications.recipient_role%TYPE;

  /* begin bug 3090563
   * notification enhancement to support more info requested
   */
  l_more_info_role            wf_notifications.more_info_role%TYPE;
  l_more_origsys              wf_roles.orig_system%TYPE;
  l_more_origsysid            wf_roles.orig_system_id%TYPE := null;
  /* end bug 3090563 */
  l_appr_and_fwd_flag boolean := FALSE;-- Flag to check if we have 'APPROVE_AND_FORWARD' action
  /* bug 1817306 new cursor c_responderid is defined to replace c_responder */
  CURSOR c_responderid(p_responder VARCHAR2) IS
    SELECT nvl((wfu.orig_system_id), -9996)
    FROM   wf_users wfu
    WHERE  wfu.name = p_responder
    AND    wfu.orig_system not in ('HZ_PARTY', 'POS', 'ENG_LIST', 'CUST_CONT');

BEGIN
   IF (x_action IN ('APPROVE', 'FORWARD', 'REJECT', 'RETURN', 'NO ACTION')) THEN
       x_action_code := x_action;

   ELSIF (x_action = 'APPROVE_AND_FORWARD') THEN
       x_action_code := 'APPROVE';
       l_appr_and_fwd_flag := TRUE; --Set flag TRUE
   ELSE
       RAISE e_invalid_action;
   END IF;
   -- dbms_output.put_line ('Action: ' || x_action_code);


   l_progress := '020';

   /*
   ** use MAX to get the latest notification sent for
   ** the wf item
   */

   SELECT NVL(MAX(wf.notification_id), -9995)
     INTO    x_notification_id
     FROM    WF_NOTIFICATIONS WF,
 	     WF_ITEM_ACTIVITY_STATUSES WIAS
    WHERE  WIAS.ITEM_TYPE = itemtype  AND
	   WIAS.ITEM_KEY = itemkey    AND
	   WIAS.NOTIFICATION_ID = WF.group_id;


 /*FP 14058500
 Fix for bug 7391797
 ** When an activity is skipped the old data is moved to
 ** wf_item_activity_statuses_h. Hence added if condition
 ** to return the notification_id in this case
 */

   IF (x_notification_id = -9995)  THEN
      SELECT NVL(MAX(wf.notification_id), -9995)
        INTO    x_notification_id
        FROM    WF_NOTIFICATIONS WF,
                WF_ITEM_ACTIVITY_STATUSES_H WIAS
        WHERE   WIAS.ITEM_TYPE = itemtype  AND
                WIAS.ITEM_KEY = itemkey    AND
                WIAS.NOTIFICATION_ID = WF.group_id;
   END IF;


    -- dbms_output.put_line ('x_notification_id ' || to_char(x_notification_id));

    /*
    ** if we cannot find the responder within our system, either the ntf has not
    ** been responded yet or the response came from outside.
    ** Therefore we cannot record the responder in
    ** PO_ACTION_HISTORY
    */

    /* internal name of responder */

    /* bug 3090563, added to fetch more info role as well */

	SELECT wfn.responder, wfn.recipient_role,
               wfn.original_recipient, wfn.more_info_role
	INTO l_responder, l_recipient_role,
             l_original_recipient, l_more_info_role
	FROM   wf_notifications wfn
	WHERE  wfn.notification_id = x_notification_id;

/* csheu bug #1287135 use reponder value in wf_notification to find
   its orig_system_id from wf_users. If no matched rows found from
   wf_users then we will use l_recipient_role value from wf_notification
   to find its orig_system_id from wf_users instead.
*/

        OPEN c_responderid(l_responder);
        FETCH c_responderid INTO x_responder_id;


        IF c_responderid%NOTFOUND THEN

          CLOSE c_responderid;
          OPEN c_responderid(l_recipient_role);
          FETCH c_responderid INTO x_responder_id;
          CLOSE c_responderid;

        END IF;

        IF (c_responderid%ISOPEN) THEN
          CLOSE c_responderid;
        END IF;

    -- dbms_output.put_line ('x_responder_id' || to_char(x_responder_id));

        OPEN c_responderid(l_original_recipient);
        FETCH c_responderid INTO l_original_recipient_id;

        IF c_responderid%NOTFOUND THEN

         CLOSE c_responderid;

         BEGIN
           SELECT WFU.ORIG_SYSTEM_ID
             INTO l_original_recipient_id
             FROM WF_ROLES WFU
            WHERE WFU.NAME = l_original_recipient
              AND WFU.ORIG_SYSTEM NOT IN ('POS', 'ENG_LIST', 'CUST_CONT');
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_original_recipient_id := fnd_global.employee_id;
         END;

        END IF;

        IF (c_responderid%ISOPEN) THEN
          CLOSE c_responderid;
        END IF;

    /* begin bug 3090563
     * notification enhancement to support more info requested
     */
    if (l_more_info_role is not null) then
      Wf_Directory.GetRoleOrigSysInfo(l_more_info_role, l_more_origsys, l_more_origsysid);
    end if;

    /* Bug 2893011: Move update history logic to private autonomus procedure. */

    UpdateActionHistory(l_more_origsysid, --bug 3090563
                        l_original_recipient_id,
                        x_responder_id,
                        x_last_approver,
                        x_action_code,
                        x_note,
                        x_req_header_id,
      			l_appr_and_fwd_flag);

    /* end bug 3090563 */

EXCEPTION

 WHEN e_invalid_action THEN
   RAISE;
 WHEN OTHERS THEN
   RAISE;

END Update_Action_History;

/* Bug# 2684757: kagarwal
** Desc: Added new procedure to insert null action in
** po_action_history for the Requisition if it does not exists.
*/

procedure Reserve_Action_History(x_approval_path_id in number,
                                 x_req_header_id    in number,
                                 x_approver_id      in number) IS

pragma AUTONOMOUS_TRANSACTION;

  l_progress                  VARCHAR2(100) := '000';
  x_count number := 0;
  x_sequence_num              NUMBER;

  CURSOR C IS
  SELECT  object_id,
          object_type_code,
          object_sub_type_code,
          sequence_num,
          action_code,
          object_revision_num,
          request_id,
          program_application_id,
          program_date,
          program_id,
          last_update_date,
          employee_id
    FROM  PO_ACTION_HISTORY
   WHERE  object_type_code = 'REQUISITION'
     AND  object_id  = x_req_header_id
     AND  sequence_num = x_sequence_num;

   Recinfo C%ROWTYPE;

BEGIN

   l_progress := '010';

      SELECT max(sequence_num)
        INTO x_sequence_num
        FROM PO_ACTION_HISTORY
       WHERE object_type_code = 'REQUISITION'
         AND object_id = x_req_header_id;

        OPEN C;

          FETCH C INTO Recinfo;

        IF (C%NOTFOUND) then
           RAISE NO_DATA_FOUND;
        END IF;

        CLOSE C;

        IF (Recinfo.action_code is NOT NULL) THEN
           l_progress := '015';

           po_forward_sv1.insert_action_history (
           Recinfo.object_id,
           Recinfo.object_type_code,
           Recinfo.object_sub_type_code,
           Recinfo.sequence_num+1,
           NULL,
           NULL,
           x_approver_id,
           x_approval_path_id,
           NULL,
           Recinfo.object_revision_num,
           NULL,                  /* offline_code */
           Recinfo.request_id,
           Recinfo.program_application_id,
           Recinfo.program_id,
           Recinfo.program_date,
           fnd_global.user_id,
           fnd_global.login_id);

           l_progress := '040';

           commit;

         END IF;

   l_progress := '050';

EXCEPTION
  WHEN others THEN
   RAISE;

END Reserve_Action_History;

/*
 * This method is a private method to update the action history in autonomous context.
 */
PROCEDURE UpdateActionHistory(p_more_info_id           IN NUMBER,
                              p_original_recipient_id  IN NUMBER,
                              p_responder_id           IN NUMBER,
                              p_last_approver          IN BOOLEAN,
                              p_action_code            IN VARCHAR2,
                              p_note                   IN VARCHAR2,
                              p_req_header_id          IN NUMBER,
			      p_app_and_fwd_flag       IN BOOLEAN )
IS

pragma AUTONOMOUS_TRANSACTION;


  l_progress                  VARCHAR2(100) := '000';
  x_sequence_num              NUMBER;
  l_note                      VARCHAR2(4000) := NULL;
  l_sequence_num              NUMBER;
  l_del_action VARCHAR2(25);
  l_seq_num  number;
  CURSOR C IS

  SELECT  PH.ACTION_CODE  				     action_code	      ,
          PH.OBJECT_TYPE_CODE                                object_type_code         ,
          PH.OBJECT_SUB_TYPE_CODE			     object_sub_type_code     ,
          PH.SEQUENCE_NUM				     sequence_num             ,
          PH.OBJECT_REVISION_NUM			     object_revision_num      ,
          PH.APPROVAL_PATH_ID				     approval_path_id         ,
          PH.REQUEST_ID					     request_id               ,
          PH.PROGRAM_APPLICATION_ID			     program_application_id   ,
          PH.PROGRAM_DATE				     program_date             ,
          PH.PROGRAM_ID					     program_id               ,
          PH.LAST_UPDATE_DATE				     last_update_date         ,
	  PH.OBJECT_ID                			     object_id
  FROM
     PO_DOCUMENT_TYPES PODT,
     PO_REQUISITION_HEADERS PRH,
     PO_ACTION_HISTORY PH
  WHERE PRH.REQUISITION_HEADER_ID = PH.OBJECT_ID AND
     PODT.DOCUMENT_TYPE_CODE = 'REQUISITION' AND
     PODT.DOCUMENT_SUBTYPE (+) = PRH.TYPE_LOOKUP_CODE AND
     PODT.DOCUMENT_TYPE_CODE = PH.OBJECT_TYPE_CODE  AND
     PRH.TYPE_LOOKUP_CODE  = PH.OBJECT_SUB_TYPE_CODE AND
     PRH.requisition_header_id=p_req_header_id and
     PH.SEQUENCE_NUM = X_SEQUENCE_NUM;

   Recinfo C%ROWTYPE;

BEGIN

   SELECT max(sequence_num)
     INTO x_sequence_num
     FROM PO_ACTION_HISTORY
    WHERE object_type_code = 'REQUISITION'
      AND object_id = p_req_header_id;

    -- dbms_output.put_line ('x_sequence_num' || to_char(x_sequence_num));
    l_sequence_num:=x_sequence_num;
   OPEN C;

   FETCH C INTO Recinfo;

   IF (C%NOTFOUND) then
      -- dbms_output.put_line ('not_here!!');
      RAISE NO_DATA_FOUND;
   END IF;

   CLOSE C;

   -- Add a blank line if the last line is not blank.
   if (Recinfo.action_code is not null) then
	l_sequence_num:= l_sequence_num +1;
	     po_forward_sv1.insert_action_history (
		Recinfo.object_id,
		Recinfo.object_type_code,
		Recinfo.object_sub_type_code,
		l_sequence_num,
		NULL,
		NULL,
		p_original_recipient_id,
		Recinfo.approval_path_id,
		NULL,
		Recinfo.object_revision_num,
		NULL,                  /* offline_code */
		Recinfo.request_id,
		Recinfo.program_application_id,
		Recinfo.program_id,
		Recinfo.program_date,
		fnd_global.user_id,
		fnd_global.login_id);

   end if;

   /*
   ** if the ntf has been reassigned, update the original NULL row in POAH
   ** with action NO ACTION and insert a new row with NULL action
   ** for the new responder
   */

   IF (p_responder_id <> -9996) THEN

   /** bug 3090563
    ** the logic to handle re-assignment is now in post notification function
    ** so that the update to action history can be viewed
    ** at the moment of reassignment.
    **
    ** this following is used to handle request for more info:
    ** 1. at the moment an approver requests for more info,
    **    action history is updated (performed within post notification)
    ** 2. if the approver approve/reject the requisition
    **      before the more info request is responded
    **    then we need to update the action history
    **      to reflect 'no action' from the more info role
    */
         l_progress := '030';

         IF (p_more_info_id is not null) THEN

             /*
             ** update the original NULL row for the original approver with
             ** action code of 'NO ACTION'
             */

            l_progress := '040';
            -- dbms_output.put_line ('l_progress!! -' || l_progress );

             po_forward_sv1.update_action_history (
 		Recinfo.object_id,
 		Recinfo.object_type_code,
 		p_more_info_id,
 		'NO ACTION',
 		NULL,
 		fnd_global.user_id,
 		fnd_global.login_id
                );

             /*
             ** insert a new NULL row into PO_ACTION_HISTORY  for
             ** the new approver
             */

             l_progress := '050';
	l_sequence_num:= l_sequence_num +1;

	     po_forward_sv1.insert_action_history (
		Recinfo.object_id,
		Recinfo.object_type_code,
		Recinfo.object_sub_type_code,
		l_sequence_num,
		NULL,
		NULL,
		p_responder_id,
		Recinfo.approval_path_id,
		NULL,
		Recinfo.object_revision_num,
		NULL,                  /* offline_code */
		Recinfo.request_id,
		Recinfo.program_application_id,
		Recinfo.program_id,
		Recinfo.program_date,
		fnd_global.user_id,
		fnd_global.login_id);

             -- dbms_output.put_line ('l_progress!! -' || l_progress );

         END IF;

     END IF;  -- p_responder_id != -9996


     l_progress := '070';

    IF (not p_last_approver) THEN
        if p_app_and_fwd_flag = FALSE then
           l_note := substrb(p_note,1,4000); --x_note,
        end if;

     /*
     ** update pending row of action history with approval action
     */
/*
Bug 14580064 : Replaced p_responder_id by p_original_recipient_id   for the case when recepient and responder are different.
*/
--Bug 15958867 added code to update action and note against employee to whom it was delegated instead of original employee
	BEGIN
		SELECT action_code,sequence_num
		INTO l_del_action,l_seq_num
		from po_action_history
		where object_id = Recinfo.object_id
		AND   object_type_code = Recinfo.object_type_code
		AND   EMPLOYEE_ID       =p_original_recipient_id;

	EXCEPTION
	  WHEN OTHERS THEN
	    	l_del_action := nuLL;
	END;

	IF l_del_action = 'DELEGATE' THEN
	     l_seq_num:= l_seq_num+1;
	     	UPDATE PO_ACTION_HISTORY
	    	SET     last_update_date = sysdate,
	            	last_updated_by = fnd_global.user_id, --x_user_id,
	            	last_update_login = fnd_global.login_id, --x_login_id,
	            	action_date = sysdate,
	            	action_code = p_action_code, --x_action_code,
				note = l_note, --x_note,
	            	offline_code =  NULL
	    	WHERE   object_id = Recinfo.object_id
		    AND   object_type_code = Recinfo.object_type_code
		    AND   sequence_num  = l_seq_num
	    	AND   action_code IS NULL;
	 ELSE
	  --End 15958867
	UPDATE PO_ACTION_HISTORY
    	SET     last_update_date = sysdate,
            	last_updated_by = fnd_global.user_id, --x_user_id,
            	last_update_login = fnd_global.login_id, --x_login_id,
            	action_date = sysdate,
            	action_code = p_action_code, --x_action_code,
		note = l_note, --x_note,
            	offline_code =  NULL
    	WHERE   object_id = Recinfo.object_id
	AND   object_type_code = Recinfo.object_type_code
	AND   EMPLOYEE_ID       =p_original_recipient_id
    	AND   action_code IS NULL;
       END IF;
       /* If 'APPROVE_AND_FORWARD' add a row for forward  in action history table */
        IF p_app_and_fwd_flag = TRUE THEN
               l_sequence_num:= l_sequence_num +1;

             po_forward_sv1.insert_action_history (
                Recinfo.object_id,
                Recinfo.object_type_code,
                Recinfo.object_sub_type_code,
                l_sequence_num ,
                'FORWARD',
                sysdate,
                p_responder_id,
                Recinfo.approval_path_id,
                substrb(p_note,1,4000), -- Inserting note in forwarded row
                Recinfo.object_revision_num,
                NULL,   /* offline_code */
                Recinfo.request_id,
                Recinfo.program_application_id,
                Recinfo.program_id,
                Recinfo.program_date,
                fnd_global.user_id,
                fnd_global.login_id);
       END IF;
    END IF;

    l_progress := '080';

    -- dbms_output.put_line ('l_progress!! -' || l_progress );

  commit;

EXCEPTION

 WHEN OTHERS THEN
   RAISE;

END;

END PO_APPROVAL_LIST_HISTORY_SV;

/
