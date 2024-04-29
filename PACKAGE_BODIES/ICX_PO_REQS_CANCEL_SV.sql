--------------------------------------------------------
--  DDL for Package Body ICX_PO_REQS_CANCEL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_PO_REQS_CANCEL_SV" AS
/* $Header: ICXRQCNB.pls 115.3 99/07/17 03:22:56 porting ship $*/


/*===========================================================================

  PROCEDURE NAME:	update_web_reqs_status

  Parameters:
	x_req_header_id	- req header to be cancelled
	x_req_line_id	- leave null for now (we only support cancel
			  at header level; UPS will want line level)
	x_agent_id	- leave null; not used (kept for consistency)
	x_req_doc_subtype = 'REQUISITION'
	x_req_doc_subtype  = po_requistion_headers.type_lookup_code
	x_req_control_action = 'CANCEL'
	x_req_control_reason - user entered reason for cancel
	x_req_control_date   - date of cancellation (pass sysdate
				if not specified by user)
	x_encumbrance_flag - pass null (not used for now)
	x_oe_installed_flag - pass null (not used for now)

	x_req_control_error_rc - return code; only filled in
			         if there is an error

===========================================================================*/

 PROCEDURE update_web_reqs_status
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER,
                   X_agent_id                IN     NUMBER,
                   X_req_doc_type            IN     VARCHAR2,
                   X_req_doc_subtype         IN     VARCHAR2,
                   X_req_control_action      IN     VARCHAR2,
                   X_req_control_reason      IN     VARCHAR2,
		   x_req_control_date	     IN     date,
                   X_encumbrance_flag        IN     VARCHAR2,
                   X_oe_installed_flag       IN     VARCHAR2,
                   X_req_control_error_rc    IN OUT VARCHAR2) IS


    X_progress                  VARCHAR2(3) := NULL;
    X_req_header_auth_status    PO_REQUISITION_HEADERS.authorization_status%TYPE := NULL;
    X_req_action_history_code   PO_ACTION_HISTORY.action_code%TYPE := NULL;
    X_supply_action             VARCHAR2(50) := NULL;
    X_supply_id                 NUMBER;

 BEGIN

--   dbms_output.put_line('Enter update_reqs_status');

   X_progress := '000';
   X_req_control_error_rc := 'N';


       SELECT authorization_status
       INTO   X_req_header_auth_status
       FROM   PO_REQUISITION_HEADERS
       WHERE  requisition_header_id = X_req_header_id;


   /*
   ** Call maintain_supply to set:
   ** 1. Req header:  quantity in mtl_supply to 0 for a given req header
   ** 2. Req line:    quantity in mtl_supply to 0 for a given req line.
   **
   ** DEBUG: The maintain_supply used in this server package is
   **        for testing.  It should be moved to the maintain_supply server
   **        package when it is ready.
   */


   X_progress := '010';
   IF X_req_header_auth_status = 'APPROVED' THEN

      IF X_req_line_id IS NULL THEN
         X_supply_action := 'Remove_Req_Supply';
         X_supply_id     := X_req_header_id;
      ELSE
         X_supply_action := 'Remove_Req_Line_Supply';
         X_supply_id     := X_req_line_id;
      END IF;

      icx_po_reqs_cancel_sv.icx_maintain_supply (X_supply_action,
	          	                  X_supply_id,
                                          X_req_control_error_rc);

   END IF;


   X_progress := '020';
   UPDATE PO_REQUISITION_LINES
   SET    cancel_flag        = 'Y',
          cancel_date        = nvl(X_req_control_date, cancel_date),
          cancel_reason      = nvl(X_req_control_reason, cancel_reason)
   WHERE  requisition_header_id = X_req_header_id
   AND    nvl(cancel_flag, 'N') IN ('N', 'I')
   AND    nvl(closed_code, 'OPEN') <> 'FINALLY CLOSED';


   X_req_action_history_code := NULL;

   IF SubStr(X_req_control_action,1,6) = 'CANCEL' THEN
      X_req_action_history_code := SubStr(X_req_control_action,1,6);
   ELSE
      X_req_action_history_code := X_req_control_action;
   END IF;


   X_progress := '030';
       UPDATE PO_REQUISITION_HEADERS
       SET    authorization_status   = 'CANCELLED'
       WHERE  requisition_header_id  = X_req_header_id;

   IF X_req_action_history_code IS NOT NULL THEN

      IF X_req_header_auth_status = 'IN PROCESS' OR
         X_req_header_auth_status = 'PRE-APPROVED' THEN
         po_forward_sv1.update_action_history (X_req_header_id,
                                               X_req_doc_type,
                                               NULL,
                                               X_req_action_history_code,
                                               X_req_control_reason,
                                               fnd_global.user_id,
                                               null);
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
                                               null);
      END IF;


   END IF;

--   dbms_output.put_line('Exit update_reqs_status');


   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('update_reqs_status', x_progress, sqlcode);
   RAISE;

 END update_web_reqs_status;


/*===========================================================================

  PROCEDURE NAME: 	maintain_supply

===========================================================================*/

 PROCEDURE icx_maintain_supply
                 (X_supply_action           IN      VARCHAR2,
                  X_supply_id               IN      NUMBER,
                  X_req_control_error_rc    IN OUT  VARCHAR2) IS

   X_progress                  VARCHAR2(3) := NULL;

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


    ELSIF X_supply_action = 'Remove_Req_Line_Supply' THEN
          X_progress := '010';

          /*
          ** Sets the req quantity in mtl_supply to 0 for a given req line.
          */

          UPDATE  mtl_supply
             SET  quantity = 0,
                  change_flag = 'Y'
           WHERE  supply_type_code = 'REQ'
             AND  req_line_id = X_supply_id;
    END IF;

--   dbms_output.put_line('Exit maintain_supply');

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      X_req_control_error_rc := '';
   WHEN OTHERS THEN
      X_req_control_error_rc := 'Y';
      po_message_s.sql_error('maintain_supply', x_progress, sqlcode);
   RAISE;

 END icx_maintain_supply;


END icx_po_reqs_cancel_sv;


/
