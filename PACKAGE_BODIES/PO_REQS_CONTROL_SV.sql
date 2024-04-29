--------------------------------------------------------
--  DDL for Package Body PO_REQS_CONTROL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQS_CONTROL_SV" AS
/* $Header: POXRQCNB.pls 120.1.12010000.3 2012/11/14 09:04:24 ssindhe ship $*/

/*===========================================================================

  FUNCTION NAME:	val_doc_security

===========================================================================*/

 FUNCTION val_doc_security
                  (X_doc_agent_id            IN     NUMBER,
                   X_agent_id                IN     NUMBER,
                   X_doc_type                IN     VARCHAR2,
                   X_doc_subtype             IN     VARCHAR2) RETURN BOOLEAN IS

   X_progress                 VARCHAR2(3) := NULL;
   X_row_exists               NUMBER := 0;

 BEGIN
--   dbms_output.put_line('Enter val_doc_security');

   X_progress := '010';

   IF X_doc_type = 'REQUISITION' THEN

     -- Check for requisition document security/access control

     SELECT  COUNT(1)
     INTO    X_row_exists
     FROM    PO_DOCUMENT_TYPES PODT
     WHERE   PODT.DOCUMENT_TYPE_CODE = X_doc_type
     AND     PODT.DOCUMENT_SUBTYPE = X_doc_subtype
     AND      (X_doc_agent_id = X_agent_id
               OR (PODT.SECURITY_LEVEL_CODE = 'PUBLIC'
                   AND PODT.access_level_code = 'FULL')
               OR (PODT.SECURITY_LEVEL_CODE = 'PURCHASING'
                   AND PODT.access_level_code = 'FULL'
                   AND EXISTS
                       (SELECT 'Is the user an agent'
                        FROM   PO_AGENTS POA
                        WHERE  POA.AGENT_ID = X_agent_id
                        AND    sysdate BETWEEN POA.start_date_active
                               AND  nvl(POA.end_date_active,sysdate+1)))
               OR (PODT.SECURITY_LEVEL_CODE = 'HIERARCHY'
                   AND PODT.access_level_code = 'FULL'
                   AND X_agent_id IN
                       (SELECT POEH.SUPERIOR_ID
                        FROM   PO_EMPLOYEE_HIERARCHIES POEH,
                               PO_SYSTEM_PARAMETERS POSP
                        WHERE  POEH.EMPLOYEE_ID = X_doc_agent_id
                        AND    POEH.POSITION_STRUCTURE_ID =
                               POSP.SECURITY_POSITION_STRUCTURE_ID)));

   ELSE

     -- Check for PO/Release document security/access control
     /*Bug6640107 Reverting the changes done in the previous version */

     SELECT  COUNT(1)
     INTO    X_row_exists
     FROM    PO_DOCUMENT_TYPES PODT
     WHERE   PODT.DOCUMENT_TYPE_CODE = X_doc_type
     AND     PODT.DOCUMENT_SUBTYPE = X_doc_subtype
     AND      (X_doc_agent_id = X_agent_id
               OR (PODT.SECURITY_LEVEL_CODE = 'PUBLIC'
                   AND PODT.access_level_code IN ('MODIFY','FULL'))
               OR (PODT.SECURITY_LEVEL_CODE = 'PURCHASING'
                   AND PODT.access_level_code IN ('MODIFY','FULL')
                   AND EXISTS
                       (SELECT 'Is the user an agent'
                        FROM   PO_AGENTS POA
                        WHERE  POA.AGENT_ID = X_agent_id
                        AND    sysdate BETWEEN POA.start_date_active
                               AND  nvl(POA.end_date_active,sysdate+1)))
               OR (PODT.SECURITY_LEVEL_CODE = 'HIERARCHY'
                   AND PODT.access_level_code IN ('MODIFY','FULL')
                   AND X_agent_id IN
                       (SELECT POEH.SUPERIOR_ID
                        FROM   PO_EMPLOYEE_HIERARCHIES POEH,
                               PO_SYSTEM_PARAMETERS POSP
                        WHERE  POEH.EMPLOYEE_ID = X_doc_agent_id
                        AND    POEH.POSITION_STRUCTURE_ID =
                               POSP.SECURITY_POSITION_STRUCTURE_ID)));

   END IF;


   IF X_row_exists > 0 THEN
      /* document security check is passed */
      RETURN (TRUE);
   ELSE
      /* document security check is failed */
      RETURN (FALSE);
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_doc_security', X_progress, sqlcode);
   RAISE;

--   dbms_output.put_line('Exit val_doc_security');

 END val_doc_security;


/*===========================================================================

  FUNCTION NAME:	val_reqs_action

===========================================================================*/

 FUNCTION val_reqs_action
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER,
                   X_agent_id                IN     NUMBER,
                   X_req_doc_type            IN     VARCHAR2,
                   X_req_doc_subtype         IN     VARCHAR2,
                   X_req_control_action      IN     VARCHAR2,
                   X_req_control_reason      IN     VARCHAR2,
		   X_req_action_date         IN     DATE,
                   X_encumbrance_flag        IN     VARCHAR2,
                   X_oe_installed_flag       IN     VARCHAR2) RETURN BOOLEAN IS

   X_progress                 VARCHAR2(3) := NULL;
   X_req_control_error_rc     VARCHAR2(1) := 'N';
   X_action_code              VARCHAR2 (30);
   X_action_dsp               VARCHAR2 (80);
   X_document_dsp             VARCHAR2 (80);

 BEGIN

--   dbms_output.put_line('Enter val_reqs_action');

   X_progress := '000';
   IF po_req_lines_sv.val_reqs_po_shipment(X_req_header_id,
                                            X_req_line_id) = FALSE THEN
--      dbms_output.put_line('val_reqs_po_shipment return FALSE');
      /* DEBUG - display req. has open PO shipment message */

      IF SubStr(X_req_control_action,1,6) = 'CANCEL' THEN
         X_action_code := SubStr(X_req_control_action,1,6);
      ELSE
         X_action_code := X_req_control_action;
      END IF;

      po_headers_sv4.get_lookup_code_dsp ('CONTROL ACTIONS',
                                           X_action_code,
                                           X_action_dsp);

      po_headers_sv4.get_lookup_code_dsp ('DOCUMENT TYPE',
                                           X_req_doc_type,
                                           X_document_dsp);

      po_message_s.app_error ('PO_CONTROL_OPEN_PO_SHIPMENT',
                              'ACTION',  X_action_dsp,
                              'DOCUMENT',X_document_dsp);

      RETURN (FALSE);
   END IF;

   IF X_oe_installed_flag = 'Y' THEN
      IF po_req_lines_sv.val_reqs_oe_shipment (X_req_header_id,
                                                X_req_line_id) = FALSE THEN
--         dbms_output.put_line('val_reqs_oe_shipment return FALSE');
         /* DEBUG - display req. has open OE shipment message */
         IF SubStr(X_req_control_action,1,6) = 'CANCEL' THEN
            X_action_code := SubStr(X_req_control_action,1,6);
         ELSE
            X_action_code := X_req_control_action;
         END IF;

         po_headers_sv4.get_lookup_code_dsp ('CONTROL ACTIONS',
                                              X_action_code,
                                              X_action_dsp);

         po_headers_sv4.get_lookup_code_dsp ('DOCUMENT TYPE',
                                              X_req_doc_type,
                                              X_document_dsp);

         po_message_s.app_error ('PO_CONTROL_OPEN_OE_SHIPMENT',
                                 'ACTION',  X_action_dsp,
                                 'DOCUMENT',X_document_dsp);

         RETURN (FALSE);

      END IF;

/* Bug# 2607180: kagarwal
** Desc: Call po_req_lines_sv.val_reqs_qty_received to verify if internal
** requisition lines which are sourced from inventory, have been received
** or not. For this we will check if the 'SHIPMENT' supply exists for the
** requisition lines.
**
** If 'SHIPMENT' supply exists return FALSE.
*/

      IF po_req_lines_sv.val_reqs_qty_received (X_req_header_id,
                                                X_req_line_id) = FALSE THEN
         IF SubStr(X_req_control_action,1,6) = 'CANCEL' THEN
            X_action_code := SubStr(X_req_control_action,1,6);
         ELSE
            X_action_code := X_req_control_action;
         END IF;

         po_headers_sv4.get_lookup_code_dsp ('CONTROL ACTIONS',
                                              X_action_code,
                                              X_action_dsp);

         po_headers_sv4.get_lookup_code_dsp ('DOCUMENT TYPE',
                                              X_req_doc_type,
                                              X_document_dsp);

         po_message_s.app_error ('PO_CONTROL_OPEN_OE_SHIPMENT',
                                 'ACTION',  X_action_dsp,
                                 'DOCUMENT',X_document_dsp);

         RETURN (FALSE);
      END IF;
   END IF;


   IF X_encumbrance_flag = 'Y' THEN

      IF po_req_lines_sv.val_reqs_qty_delivered (X_req_header_id,
		         	                  X_req_line_id) = FALSE THEN

--         dbms_output.put_line('val_reqs_qty_delivered return FALSE');
         /* DEBUG - display  PO_RQCON_NOT_DELIVERED message */
         po_message_s.app_error('PO_RQCON_NOT_DELIVERED');
        RETURN (FALSE);

      END IF;

      IF SubStr(X_req_control_action,1,6) = 'CANCEL' THEN
         po_req_lines_sv.update_reqs_lines_incomplete (X_req_header_id,
                                                       X_req_line_id,
                                                       X_req_control_error_rc,
                                                       X_oe_installed_flag);
           IF X_req_control_error_rc = 'Y' THEN
--              dbms_output.put_line('update_reqs_lines_incomplete return ERROR');
              RETURN (FALSE);
           END IF;
      END IF;
   ELSE
      /*
      ** if encumbrance flag is OFF, continue the process of updating the
      ** requisition status on the server side
      */
      po_reqs_control_sv.update_reqs_status (X_req_header_id,
                                             X_req_line_id,
                                             X_agent_id,
                                             X_req_doc_type,
                                             X_req_doc_subtype,
                                             X_req_control_action,
                                             X_req_control_reason,
        			 	     X_req_action_date,
                                             X_encumbrance_flag,
                                             X_oe_installed_flag,
                                             X_req_control_error_rc);
           IF X_req_control_error_rc = 'Y' THEN
--              dbms_output.put_line('update_reqs_status return ERROR');
              RETURN (FALSE);

           END IF;
   END IF;

   RETURN (TRUE);
--   dbms_output.put_line('Exit process_req_control');

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_reqs_action', X_progress, sqlcode);
   RAISE;

 END val_reqs_action;



/*===========================================================================

  PROCEDURE NAME:	update_reqs_status

===========================================================================*/

 PROCEDURE update_reqs_status
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER,
                   X_agent_id                IN     NUMBER,
                   X_req_doc_type            IN     VARCHAR2,
                   X_req_doc_subtype         IN     VARCHAR2,
                   X_req_control_action      IN     VARCHAR2,
                   X_req_control_reason      IN     VARCHAR2,
 		   X_req_action_date         IN     DATE,
                   X_encumbrance_flag        IN     VARCHAR2,
                   X_oe_installed_flag       IN     VARCHAR2,
                   X_req_control_error_rc    IN OUT NOCOPY VARCHAR2) IS


    X_progress                  VARCHAR2(3) := NULL;
    X_req_header_auth_status    PO_REQUISITION_HEADERS.authorization_status%TYPE := NULL;
    X_req_action_history_code   PO_ACTION_HISTORY.action_code%TYPE := NULL;
    X_supply_action             VARCHAR2(50) := NULL;
    X_supply_id                 NUMBER;
    X_req_header_auth_status_dsp  VARCHAR2(80);
    x_item_type   varchar2(8);
    x_item_key   varchar2(240);

 BEGIN

--   dbms_output.put_line('Enter update_reqs_status');

   X_progress := '000';
   X_req_control_error_rc := 'N';


   po_reqs_sv2.get_reqs_auth_status (X_req_header_id,
                                    X_req_header_auth_status,
				    X_req_header_auth_status_dsp,
                                    X_req_control_error_rc);

   IF X_encumbrance_flag = 'Y' THEN
      po_req_dist_sv.update_reqs_distributions (X_req_header_id,
                                                         X_req_line_id,
                                                         X_req_control_action,
							 X_req_action_date,
                                                         X_req_control_error_rc);
   END IF;

   /*
   ** Call maintain_supply to set:
   ** 1. Req header:  quantity in mtl_supply to 0 for a given req header
   ** 2. Req line:    quantity in mtl_supply to 0 for a given req line.
   **
   ** DEBUG: The maintain_supply used in this server package is
   **        for testing.  It should be moved to the maintain_supply server
   **        package when it is ready.
   */

/*BUG: 969859 FRKHAN 9/1/99
In the overall fix, the supply is not removed when the req is returned.So
if the returned req is cancelled, its supply needs to be removed then.
*/
/*
   Bug:2361695
   When a requisition is cancelled the supply lines corresponding
   to that requisition should be deleted irrespective of the status
   of the requisition.  Hence commenting out the condition below.
*/

/*   IF ((X_req_header_auth_status = 'APPROVED') OR (X_req_header_auth_status = 'RETURNED')) THEN
*/
      IF X_req_line_id IS NULL THEN
         X_supply_action := 'Remove_Req_Supply';
         X_supply_id     := X_req_header_id;
      ELSE
         X_supply_action := 'Remove_Req_Line_Supply';
         X_supply_id     := X_req_line_id;
      END IF;

      po_reqs_control_sv.maintain_supply (X_supply_action,
	          	                  X_supply_id,
                                          X_req_control_error_rc);

 --  END IF;


   po_req_lines_sv.update_reqs_lines_status (X_req_header_id,
					     X_req_line_id,
					     X_req_control_action,
                                             X_req_control_reason,
					     X_req_action_date,
                                             X_oe_installed_flag,
					     X_req_control_error_rc);

   X_req_action_history_code := NULL;

   po_reqs_sv.update_reqs_header_status (X_req_header_id,
                                         X_req_line_id,
					 X_req_control_action,
                                         X_req_control_reason,
                                         X_req_action_history_code,
    					 X_req_control_error_rc);

   IF X_req_action_history_code IS NOT NULL THEN

      IF X_req_header_auth_status = 'IN PROCESS' OR
         X_req_header_auth_status = 'PRE-APPROVED' THEN

         -- Bug 5108975 Start
         -- If the action is cancel then delete the rows where action_code is null
         -- and insert a row with action_code CANCEL.
         IF X_req_action_history_code = 'CANCEL' THEN

            DELETE FROM PO_ACTION_HISTORY
            WHERE   object_id = X_req_header_id
            AND	    object_type_code = X_req_doc_type
            AND     action_code IS NULL;

            po_forward_sv1.insert_action_history (X_req_header_id,
                                                  X_req_doc_type,
                                                  X_req_doc_subtype,
                                                  NULL,
                                                  X_req_action_history_code,
                                                  sysdate,
                                                  X_agent_id,
                                                  NULL,
                                                  X_req_control_reason,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  fnd_global.user_id,
                                                  fnd_global.login_id);
        -- Bug 5108975 End
         ELSE
            po_forward_sv1.update_action_history (X_req_header_id,
                                                  X_req_doc_type,
                                                  NULL,
                                                  X_req_action_history_code,
                                                  X_req_control_reason,
                                                  fnd_global.user_id,
                                                  fnd_global.login_id);
         END IF;

      ELSE
         po_forward_sv1.insert_action_history (X_req_header_id,
                                               X_req_doc_type,
                                               X_req_doc_subtype,
                                               NULL,
                                               X_req_action_history_code,
                                               sysdate,
                                               X_agent_id,
                                               NULL,
                                               X_req_control_reason,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               NULL,
                                               fnd_global.user_id,
                                               fnd_global.login_id);
      END IF;

   /*hvadlamu commenting out and adding the workflow call */
     /* po_notifications_sv1.delete_po_notif (x_Req_doc_type,
                                               X_req_header_id); */
    SELECT wf_item_type,wf_item_key
    INTO   x_item_type,x_item_key
    FROM   PO_REQUISITION_HEADERS
    WHERE  requisition_header_id = x_req_header_id;

             if ((x_item_type is null) and (x_item_key is null)) then
			 po_approval_reminder_sv.cancel_notif (x_req_doc_subtype,
                                     x_req_header_id);
	    else
  /*  Bug# 1499199
      Forward fix of bug# 13721671
      When the wf_item_type and item_type are not null
      even then, there is a possibility that  some outstanding
      notifications exist. These should be cancelled when the
      requisition is cancelled. The above cancel_notif call is also
      modified to send doc_subtype as parameter instead of doc_type */

                    po_approval_reminder_sv.cancel_notif (x_req_doc_subtype, x_req_header_id);
		    po_approval_reminder_sv.stop_process(x_item_type,x_item_key);
	    end if;

   END IF;

--   dbms_output.put_line('Exit update_reqs_status');


   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('update_reqs_status', x_progress, sqlcode);
   RAISE;

 END update_reqs_status;

/*===========================================================================

  PROCEDURE NAME: 	commit_changes

===========================================================================*/

 PROCEDURE commit_changes IS

   X_progress                  VARCHAR2(3) := NULL;
 BEGIN

    X_progress := '005';
    COMMIT;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('commit_changes', x_progress, sqlcode);
   RAISE;

 END commit_changes;

/*===========================================================================

  PROCEDURE NAME: 	rollback_changes

===========================================================================*/

 PROCEDURE rollback_changes IS

   X_progress                  VARCHAR2(3) := NULL;
 BEGIN

    X_progress := '005';
    ROLLBACK;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('rollback_changes', x_progress, sqlcode);
   RAISE;

 END rollback_changes;


/*===========================================================================

  PROCEDURE NAME: 	maintain_supply

===========================================================================*/

 PROCEDURE maintain_supply
                 (X_supply_action           IN      VARCHAR2,
                  X_supply_id               IN      NUMBER,
                  X_req_control_error_rc    IN OUT NOCOPY  VARCHAR2) IS

   X_progress                  VARCHAR2(3) := NULL;
   l_return_status		VARCHAR2(2);

 BEGIN

--    dbms_output.put_line('Enter maintain_supply');
    X_req_control_error_rc := '';

    IF X_supply_action = 'Remove_Req_Supply' THEN
       X_progress := '005';

       /*
       ** Sets the req quantity in mtl_supply to 0 for a given req header.
       */

       UPDATE  MTL_SUPPLY
          SET  quantity = 0,
               change_flag = 'Y'
        WHERE  supply_type_code = 'REQ'
          AND  req_header_id = X_supply_id;

       /* bug 404433: - Update the MTL_SUPPLY table in two steps to keep
       ** the code compatible as in R10 userexit.
       ** The delete step is to fire the MRP triggers.
       */

       DELETE FROM MTL_SUPPLY
        WHERE supply_type_code = 'REQ'
          AND quantity = 0
          AND change_flag = 'Y'
          AND req_header_id = X_supply_id;


  	PO_RESERVATION_MAINTAIN_SV.maintain_reservation(
                                            p_header_id             => X_supply_id,
                                            p_action                => X_supply_action,
                                            x_return_status         => l_return_status);


    ELSIF X_supply_action = 'Remove_Req_Line_Supply' THEN
          X_progress := '010';

          /*
          ** Sets the req quantity in mtl_supply to 0 for a given req line.
          */

          UPDATE  MTL_SUPPLY
             SET  quantity = 0,
                  change_flag = 'Y'
           WHERE  supply_type_code = 'REQ'
             AND  req_line_id = X_supply_id;


          DELETE FROM MTL_SUPPLY
           WHERE supply_type_code = 'REQ'
             AND quantity = 0
             AND change_flag = 'Y'
             AND req_line_id = X_supply_id;


   	  PO_RESERVATION_MAINTAIN_SV.maintain_reservation(
                                            p_line_id               => X_supply_id,
                                            p_action                => X_supply_action,
                                            x_return_status         => l_return_status);

    END IF;

--   dbms_output.put_line('Exit maintain_supply');

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      X_req_control_error_rc := '';
   WHEN OTHERS THEN
      X_req_control_error_rc := 'Y';
      po_message_s.sql_error('maintain_supply', x_progress, sqlcode);
   RAISE;

 END maintain_supply;

 /*===========================================================================

  PROCEDURE NAME: 	rollback_savepoint_changes

===========================================================================*/


 PROCEDURE rollback_savepoint_changes IS

   X_progress                  VARCHAR2(3) := NULL;
 BEGIN

    X_progress := '005';
    ROLLBACK TO SAVEPOINT cancel_action_savepoint; -- Bug 14845281

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('rollback_changes_after_last_savepoint', x_progress, sqlcode);
   RAISE;

 END rollback_savepoint_changes;

END po_reqs_control_sv;

/
