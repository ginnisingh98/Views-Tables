--------------------------------------------------------
--  DDL for Package Body PO_SECURITY_CHECK_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SECURITY_CHECK_SV" as
/* $Header: POXSCHKB.pls 120.1.12010000.6 2014/07/18 06:19:09 yyoliu ship $ */

/*=============================  PO_SECURITY_CHECK_SV  ===============================*/


/*===========================================================================

  PROCEDURE NAME:	check_before_lock()

===========================================================================*/

function  check_for_delegation (x_itemtype      in varchar2,
                                x_itemkey       in varchar2,
                                x_logged_emp_id in number,
                                x_action_emp_id in number) return boolean;

PROCEDURE  check_before_lock (x_type_lookup_code in varchar2,
                                                x_object_id        in number,
                                                x_logged_emp_id in number,
                                                x_modify_action in out NOCOPY boolean) IS

x_can_approver_modify_flag varchar2(25);
x_progress    varchar2(3);
x_last_action_emp_id  number;
x_document_type_code  varchar2(25);
x_document_subtype    varchar2(25);
x_count               number := 0;

l_authorization_status varchar2(25);

x_wf_item_type        po_headers_all.wf_item_type%type := NULL;
x_wf_item_key         po_headers_all.wf_item_key%type := NULL;   -- Modified for Bug 2783162

BEGIN

    IF x_type_lookup_code = 'RELEASE' THEN

	x_document_type_code := 'RELEASE';
	x_document_subtype := 'BLANKET';

    ELSE

	x_document_subtype := x_type_lookup_code;
	IF x_type_lookup_code IN ('STANDARD', 'PLANNED') THEN
	    x_document_type_code := 'PO';
	ELSIF x_type_lookup_code IN ('BLANKET', 'CONTRACT') THEN
	    x_document_type_code := 'PA';
	ELSIF x_type_lookup_code IN ('INTERNAL', 'PURCHASE') THEN
	    x_document_type_code := 'REQUISITION';
	ELSIF x_type_lookup_code = 'SCHEDULED' THEN
	    x_document_type_code := 'RELEASE';
        ELSE
            x_document_type_code := null;
	END IF;

    END IF;

  /* Bug# 1266226
  ** Desc: When a document is INCOMPLETE, we need not verify that
  **       the action history exists or not. The INCOMPLETE status
  **       signifies that the document has not been submitted for
  **       approval or has been returned in original status without
  **       any approval action (approve, forward) being taken on it
  **       when the document was first submitted for the approval
  **       process.
  **
  **       If the authorization status of the doc is INCOMPLETE
  **       set x_modify_action := TRUE and return.
  */

     x_progress := '005';

     IF x_document_type_code='REQUISITION' THEN

        x_progress := '006';       -- Added for bug 2783162
        select NVL(AUTHORIZATION_STATUS, 'INCOMPLETE'),
               wf_item_type, wf_item_key
        into l_authorization_status, x_wf_item_type, x_wf_item_key
        from po_requisition_headers_all
        where REQUISITION_HEADER_ID = x_object_id;

     ELSIF x_document_type_code IN ('PO','PA') THEN
        x_progress := '007';       -- Added for bug 2783162

        select NVL(AUTHORIZATION_STATUS, 'INCOMPLETE'),
               wf_item_type, wf_item_key
        into l_authorization_status, x_wf_item_type, x_wf_item_key
        from po_headers_all
        where PO_HEADER_ID = x_object_id;

     ELSIF x_document_type_code = 'RELEASE' THEN
         x_progress := '008';       -- Added for bug 2783162

         select NVL(AUTHORIZATION_STATUS, 'INCOMPLETE'),
               wf_item_type, wf_item_key
         into l_authorization_status, x_wf_item_type, x_wf_item_key
         from po_releases_all
         where  PO_RELEASE_ID = x_object_id;

     END IF;

  /* Bug# 2454444: kagarwal
  ** Desc: When a document is in REQUIRES REAPPROVAL status, we need not verify
  ** the action history. The REQUIRES REAPPROVAL status signifies that the
  ** document is NOT in between the Approval process hence the buyers can
  ** modify the document depending on the Security setup.
  */

     IF ((l_authorization_status = 'INCOMPLETE') OR
         (l_authorization_status = 'REQUIRES REAPPROVAL')) THEN
         x_modify_action := TRUE;
         return;
     END IF;

/* End Fix Bug# 1266226
*/


    -- First check whether there has been any action at all on the
    -- document. If there has been no action then the document is
    -- still with the creator (no approval actions) and he can modify.

    x_progress := '010';

    select count(*) into x_count
    from po_action_history pah
    where
      pah.object_id = x_object_id  and
      pah.object_type_code = x_document_type_code and
      pah.object_sub_type_code = x_document_subtype and
      pah.action_code is null;

    if x_count = 0 then -- no records in po_action_history
      --  dbms_output.put_line('Count is zero');
       x_modify_action := TRUE;
       return;

    else
      -- check the approver can modify flag

      x_progress := '020';

      select nvl(podt.can_approver_modify_doc_flag,'N')
      into   x_can_approver_modify_flag
      from   po_document_types podt
      where
         podt.document_type_code = x_document_type_code and
         podt.document_subtype   = x_document_subtype;

      IF x_can_approver_modify_flag = 'Y' then

      --  dbms_output.put_line('approver may modify');
        -- making the assumption that max(sequence_num) would have null action code
        -- select the last emp_id

        x_progress := '030';
        select count(EMPLOYEE_ID)
        into   x_count  --bug:19068890
        from po_action_history pah
        where
          pah.object_id = x_object_id  and
          pah.object_type_code = x_document_type_code and
          pah.object_sub_type_code = x_document_subtype and
          pah.action_code is null and x_logged_emp_id=EMPLOYEE_ID;
        IF x_count>0 THEN  --bug:19068890

           -- dbms_output.put_line('The employee ids are the same');
           x_modify_action := TRUE;
           return;

        ELSE

           -- dbms_output.put_line('The employee ids are not the same');

           /* Bug# 2559747: kagarwal
           ** Check if this is a delegated doc and if the logged user is the recipient_role
           ** of the notification then allow the user to modify the doc.
           */
           If ((x_wf_item_type is not NULL) AND (x_wf_item_key is not NULL)) Then
               If (check_for_delegation(x_wf_item_type, x_wf_item_key,
                                        x_logged_emp_id, x_last_action_emp_id)) Then
                  x_modify_action := TRUE;
                  return;
               End If;
           End If;

           x_modify_action := FALSE;
           return;

        END IF;

      ELSE

         -- dbms_output.put_line('Approver cannot modify document');
         x_modify_action := FALSE;
         return;

      END IF;  -- x_can_approver_modify_flag = Y
      -- dbms_output.put_line('No records were found in po_action_history');
     -- dbms_output.put_line('We have a problem here');

   END IF; -- count(*)

EXCEPTION
     WHEN OTHERS THEN
          -- dbms_output.put_line('Errors');
     NULL;
/* Bug 2814939 - removed RAISE introduced in bug 2783162
   The problem with doing this is that this proc is called in
   many places, and they were not designed to handle raised exceptions
   from this procedure.  May be refactored in the future.
     -- Added for bug 2783162
     -- PO_MESSAGE_S.sql_error('check_before_lock', X_progress, sqlcode);
     --   RAISE;
*/

end check_before_lock;

/* Bug# 2559747: kagarwal
** Added new function check_for_delegation to validate that
** the delegated user is the logged employee.
*/

function  check_for_delegation (x_itemtype      in varchar2,
                                x_itemkey       in varchar2,
                                x_logged_emp_id in number,
                                x_action_emp_id in number)
return boolean IS

/* use MAX to get the latest notification sent for the wf item */

CURSOR getcurrnotif is
--Bug: 19068890 start
SELECT wf.notification_id, wf.from_role
--Bug 12534279
 FROM   WF_NOTIFICATIONS WF,
        WF_ITEMS WI
 WHERE  WF.MESSAGE_TYPE =  x_itemtype  AND
        WF.ITEM_KEY = WI.ITEM_KEY AND
        (WI.ITEM_KEY = x_itemkey OR
        WI.PARENT_ITEM_KEY = x_itemkey) AND
        WI.ITEM_TYPE = x_itemtype AND
        WF.STATUS = 'OPEN';
--Bug: 19068890 end

CURSOR c_responderid(p_responder VARCHAR2) IS
    SELECT nvl((wfu.orig_system_id), -9996)
    FROM   wf_users wfu
    WHERE  wfu.name = p_responder
    AND    wfu.orig_system not in ('HZ_PARTY', 'POS', 'ENG_LIST', 'CUST_CONT');

-- Bug 4633202: Cursor to get list of all granters who has provided worklist
-- access to current employee. It also lists the current user.

CURSOR c_worklist_grants IS
     SELECT PARAMETER1 AS granter_key
       FROM FND_GRANTS g,
            fnd_menus m,
            fnd_objects o,
            fnd_object_instance_sets s
      WHERE g.MENU_ID = m.menu_id
        AND m.menu_name = 'FND_WF_WORKLIST'
        AND g.OBJECT_ID = o.object_id
        AND o.obj_name = 'NOTIFICATIONS'
        AND g.INSTANCE_SET_ID = s.instance_set_id
        AND s.instance_set_name = 'WL_PROXY_ACCESS'
        AND g.GRANTEE_KEY = FND_GLOBAL.USER_NAME
        AND g.INSTANCE_TYPE = 'SET'
        AND g.START_DATE <= SYSDATE
        AND Nvl(g.END_DATE, SYSDATE ) >= SYSDATE
    UNION
     SELECT FND_GLOBAL.USER_NAME AS granter_key
       FROM dual;

-- Bug 4633202: Temp variables
l_notification_key      wf_notifications.ACCESS_KEY%TYPE;
l_granter_key           FND_GRANTS.PARAMETER1%TYPE;
l_has_access            BOOLEAN;


l_notification_id 	WF_NOTIFICATIONS.notification_id%type;
l_responder       	WF_NOTIFICATIONS.responder%type;
l_original_recipient_id wf_users.orig_system_id%type;
l_recipient_id 		wf_users.orig_system_id%type;
l_recipient_role  	WF_NOTIFICATIONS.recipient_role%type;
l_original_recipient  	WF_NOTIFICATIONS.ORIGINAL_RECIPIENT%type;

l_from_role   WF_NOTIFICATIONS.from_role%TYPE;  --Bug 12534279


Begin
	--Open getcurrnotif;
        --fetch getcurrnotif into l_notification_id, l_from_role; --Bug 12534279
        --close getcurrnotif;
        --Bug: 19068890
        l_has_access := FALSE;
      FOR notifAndRoles in getcurrnotif LOOP
        l_notification_id:=notifAndRoles.notification_id;
        l_from_role:=notifAndRoles.from_role;

	 -- Bug 4633202.
        -- Loop for all granters and current user
        FOR r_grants IN c_worklist_grants LOOP
        BEGIN

          IF( r_grants.granter_key <> l_from_role) THEN  --Bug 12534279
          -- Validate the access
          l_granter_key := wf_advanced_worklist.Authenticate
                                   ( username => r_grants.granter_key,
                                          nid => l_notification_id,
                                         nkey => l_notification_key
                                   );
          -- If we are here, means there is no exception. Access is validated.
          -- Since one valid record is found, we can exit
          l_has_access := TRUE;
          return l_has_access;

          END IF;

        EXCEPTION
           WHEN OTHERS THEN
              NULL; -- Loop through for other grants
        END;
        END LOOP;
     END LOOP;
        RETURN l_has_access;

        /* internal name of responder */
	/*  Bug 4633202.
           This check is not required. WF API itself
           will take care of all these checks.
        SELECT wfn.recipient_role, wfn.original_recipient
        INTO   l_recipient_role, l_original_recipient
        FROM   wf_notifications wfn
        WHERE  wfn.notification_id = l_notification_id;

        OPEN c_responderid(l_recipient_role);
        FETCH c_responderid INTO l_recipient_id;
        CLOSE c_responderid;

        OPEN c_responderid(l_original_recipient);
        FETCH c_responderid INTO l_original_recipient_id;
        CLOSE c_responderid;

        If ((l_recipient_id = x_logged_emp_id) AND
            (l_original_recipient_id = x_action_emp_id)) Then
            return TRUE;
       End If;

       return FALSE;
	*/
Exception
	when others then
        return FALSE;

End check_for_delegation;

END PO_SECURITY_CHECK_SV;

/
