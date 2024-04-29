--------------------------------------------------------
--  DDL for Package Body PO_NOTIFICATIONS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NOTIFICATIONS_SV1" AS
/* $Header: POXBWN1B.pls 115.3 2002/11/26 23:56:07 sbull ship $*/

	DOC_OWNER 			NUMBER := 1;
	DESCRIPTION 			NUMBER := 2;
	AUTHORIZATION_STATUS_DISP	NUMBER := 3;
	OWNER_ID 			NUMBER := 20;
	SEGMENT1 			NUMBER := 21;
	RELEASE_NUM 			NUMBER := 22;
	AUTHORIZATION_STATUS    	NUMBER := 23;
	ARRAY_FIRST_NULL		NUMBER := 4;
	ARRAY_LAST_NULL			NUMBER := 19;
	ARRAY_LB			NUMBER := 1;
        ARRAY_UB			NUMBER := 23;

/*===========================================================================

  PROCEDURE NAME:       delete_po_notif

===========================================================================*/

PROCEDURE delete_po_notif (x_document_type_code IN  VARCHAR2,
		           x_object_id          IN  NUMBER)  IS

	x_progress	VARCHAR2(3)  := '';
	x_release_id    NUMBER;

	CURSOR C is
	    SELECT po_release_id
	    FROM   po_releases
	    WHERE  po_header_id = x_object_id;

BEGIN

   null;

  /* Commenting out this whole procedure since it will no longer be used in R11

    -- Delete all notifications from the fnd_notifications
    -- table for this document.

    x_progress := '010';
    delete_notif_by_id_type(x_object_id, x_document_type_code);

    -- Delete all notifications from the po_notifications table
    -- for this document.

    x_progress := '020';
    po_notifications_sv2.delete_from_po_notif (x_document_type_code,
			                       x_object_id);

    -- If document is a blanket PO, delete notifications for
    -- all releases against this blanket.  Note:  This
    -- procedure must be called prior to deleting the blanket PO.
    -- Otherwise, all the releases against that PO will automatically
    -- be deleted along with the PO, and no data will be fetched into
    -- cursor C.

    IF x_document_type_code = 'BLANKET' THEN

	x_progress := '020';
	OPEN C;
	LOOP

 	    x_progress := '030';
	    FETCH C into x_release_id;
	    EXIT WHEN C%NOTFOUND;

	    -- Delete notifications from fnd_notifications.

	    x_progress := '040';
	    delete_notif_by_id_type(x_release_id, 'RELEASE');

	    -- Delete notifications from po_notifications

            x_progress := '050';
            po_notifications_sv2.delete_from_po_notif ('RELEASE',
			                               x_release_id);

	END LOOP;
	CLOSE C;

    END IF;
*/

EXCEPTION
    WHEN OTHERS THEN
	dbms_output.put_line('exception occurred in delete_po_notif ');
	PO_MESSAGE_S.SQL_ERROR('DELETE_PO_NOTIF', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       delete_notif_by_id_type

===========================================================================*/

PROCEDURE delete_notif_by_id_type(x_object_id 	NUMBER,
   				  x_doc_type  	VARCHAR2) IS
	x_progress 		VARCHAR2(3) := '';
	x_notification_id	NUMBER;
	x_return_code		NUMBER;

        -- Cursor will return notification ids for all notifications
	-- for this document.

  /* commenting out since it is no longer used in R11
   	CURSOR C IS
	    SELECT    notification_id
            FROM      fnd_notifications
            WHERE     object_id = x_object_id
            AND       doc_type = x_doc_type; */

BEGIN
    null;

  /* commenting out since it is no longer used in R11
    x_progress := '010';
    OPEN C;
    LOOP
	x_progress := '020';
	FETCH C into x_notification_id;
	EXIT WHEN C%NOTFOUND;

	dbms_output.put_line('before deleting notifications');

	-- Call the procedure to delete notifications.

	ntn.delete_notification(x_notification_id, x_return_code);

	dbms_output.put_line('after deleting notifications');

    END LOOP;
    CLOSE C;
 */

EXCEPTION
    WHEN OTHERS THEN
	dbms_output.put_line('exception occurred in delete_notif_by_id_type');
	PO_MESSAGE_S.SQL_ERROR('DELETE_NOTIF_BY_ID_TYPE', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       send_po_notif

===========================================================================*/

PROCEDURE send_po_notif(x_document_type_code  IN  VARCHAR2,
	                x_object_id	      IN  NUMBER,
		        x_currency_code	      IN  VARCHAR2 DEFAULT NULL,
		        x_start_date_active   IN  DATE DEFAULT NULL,
		        x_end_date_active     IN  DATE DEFAULT NULL,
		        x_forward_to_id	      IN  NUMBER DEFAULT NULL,
			x_forward_from_id     IN  NUMBER DEFAULT NULL,
			x_note		      IN  VARCHAR2 DEFAULT NULL) IS
	x_message_name      	VARCHAR2(255) := '';
	x_doc_num	   	VARCHAR2(255) := '';
	x_employee_id	    	NUMBER  := x_forward_to_id;
	x_from_id		NUMBER := x_forward_from_id;
	x_sender_note		VARCHAR2(300) := x_note;
	x_start_date		DATE;
	x_forward_release_to 	NUMBER;
	x_forward_release_from  NUMBER := '';
	x_release_currency_code VARCHAR2(25) := '';
	x_doc_currency_code	VARCHAR2(25) := x_currency_code;
	x_release_note		VARCHAR2(240) := '';
	x_release_id	    	NUMBER;
	x_return_code	    	NUMBER;
	x_notification_id   	NUMBER;
	x_progress	    	VARCHAR2(3) := '';
	--x_attribute_array   	ntn.char_array;
	x_array_lb	     	NUMBER;
	x_array_up		NUMBER;
	x_doc_creation_date	DATE;
	x_expiration_date	DATE;
	x_close_date		DATE;
	x_acceptance_due_date   DATE;

        CURSOR C is
	    SELECT po_release_id
	    FROM   po_releases
	    WHERE  po_header_id = x_object_id
	    AND    nvl(cancel_flag,'N') = 'N';
BEGIN

    -- Delete all notifications for this document.  If the
    -- document is a blanket PO, notifications for all
    -- releases against it will also be deleted.

     null;

   /* commenting out since it is no longer used in R11

    x_progress := '010';

    delete_po_notif(x_document_type_code, x_object_id);

    IF (x_document_type_code = 'BLANKET') THEN

	-- Insert new notification for releases against
	-- this blanket.

	x_progress := '020';
	OPEN C;
	LOOP

	    -- Fetch po_release_id for each release
	    -- against this blanket PO into cursor C.

 	    x_progress := '030';
	    FETCH C into x_release_id;
	    EXIT WHEN C%NOTFOUND;

            -- Get all the information required for inserting
	    -- the notification for the release into the
	    -- fnd_notifications table.

	    x_forward_release_to :=  NULL;
	    x_forward_release_from := NULL;
	    x_release_note := NULL;
	    x_start_date := NULL;

	    po_notifications_sv1.get_notif_data ('RELEASE',
	         	x_release_id,
	       		NULL,      	-- no end_date_active
			x_start_date,
	      		x_forward_release_to,
	      		x_message_name,
	      		x_doc_num,
			x_doc_creation_date,
			x_release_currency_code,
			x_forward_release_from,
			x_release_note,
			x_expiration_date,
			x_close_date,
			x_acceptance_due_date,
			x_attribute_array);

	    -- IF x_message_name is null then a notification is
	    -- not required.

	    IF x_message_name IS NOT NULL THEN

	        -- Send the notification for the release.

		ntn.Send_Notification(
   			x_forward_release_to,
   			x_message_name,
   			x_release_id,
   			1,  		-- priority
   			'N',  		-- deletable
   			x_forward_release_from,
   			201,
   			'RELEASE',
   			x_doc_num,
			NULL,
   			x_release_currency_code,
   			x_release_note,
   			x_start_date,
   			NULL,
			x_doc_creation_date,
			x_expiration_date,
			x_close_date,
			x_acceptance_due_date,
   			x_attribute_array,
   			ARRAY_LB,
   			ARRAY_UB,
   			x_return_code,
   			x_notification_id);

		-- Insert the same notification into the po_notifications
		-- table to keep the two tables in sync.


		po_notifications_sv2.insert_into_po_notif (
			x_forward_release_to,
			x_message_name,
			'RELEASE',
			x_release_id,
			x_doc_creation_date,
			x_start_date,
			NULL);

	    END IF;

	END LOOP;
	CLOSE C;

    END IF;

    -- Get the information needed for this notification.

    x_start_date := x_start_date_active;
    po_notifications_sv1.get_notif_data (x_document_type_code,
	      x_object_id,
	      x_end_date_active,
	      x_start_date,
	      x_employee_id,
	      x_message_name,
	      x_doc_num,
	      x_doc_creation_date,
	      x_doc_currency_code,
	      x_from_id,
	      x_sender_note,
	      x_expiration_date,
	      x_close_date,
	      x_acceptance_due_date,
	      x_attribute_array);

    -- Check that a notification is required for this document.

    IF x_message_name IS NOT NULL THEN

	-- Send the notification.

    	ntn.Send_Notification(x_employee_id,
			x_message_name,
   			x_object_id,
			1, 	        -- priority
			'N',		-- deletable
   			x_from_id,
   			201,
   			x_document_type_code,
			x_doc_num,
   			NULL,
   			x_doc_currency_code,
   			x_sender_note,
			x_start_date,
			x_end_date_active,
			x_doc_creation_date,
			x_expiration_date,
			x_close_date,
			x_acceptance_due_date,
   			x_attribute_array,
   			ARRAY_LB,
   			ARRAY_UB,
   			x_return_code,
   			x_notification_id);

	-- Insert the same notification into the po_notification table
	-- to keep the two tables in sync.

	po_notifications_sv2.insert_into_po_notif (
			x_employee_id,
			x_message_name,
			x_document_type_code,
			x_object_id,
			x_doc_creation_date,
			x_start_date,
			x_end_date_active);

    END IF; */

EXCEPTION
    WHEN OTHERS THEN
	dbms_output.put_line('Exception occurred in send_po_notif');
	PO_MESSAGE_S.SQL_ERROR('SEND_PO_NOTIFICATION', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       get_notif_data

===========================================================================*/

PROCEDURE get_notif_data (x_document_type_code  IN      VARCHAR2,
		    x_object_id           IN      NUMBER,
	            x_end_date_active     IN      DATE,
		    x_start_date_active	  IN OUT NOCOPY  DATE,
		    x_employee_id	  IN OUT NOCOPY  NUMBER,
		    x_message_name	  IN OUT NOCOPY  VARCHAR2,
		    x_doc_num		  IN OUT NOCOPY  VARCHAR2,
		    x_doc_creation_date   IN OUT NOCOPY  DATE,
		    x_currency_code	  IN OUT NOCOPY  VARCHAR2,
		    x_from_id		  IN OUT NOCOPY  NUMBER,
		    x_note		  IN OUT NOCOPY  VARCHAR2,
		    x_expiration_date	  IN OUT NOCOPY  DATE,
		    x_close_date	  IN OUT NOCOPY  DATE,
		    x_acceptance_due_date IN OUT NOCOPY  DATE) IS

    x_progress        		VARCHAR2(3) := '';
    x_counter	      		NUMBER;
    x_type			VARCHAR2(25) := '';
    x_subtype			VARCHAR2(25) := '';
    x_doc_owner_id		NUMBER;
    x_forward_to_id		NUMBER := x_employee_id;
    x_code			VARCHAR2(1) := '';

BEGIN

    x_progress := '010';

   /* Obsolete in R11

    -- Get the necessary data for inserting a notification into the
    -- fnd_notifications table.  Message name is as follows:

 	-- If document is on hold, insert an 'ON_HOLD' notification.
	-- If document is APPROVED, insert an 'ACCEPTANCE_PAST_DUE'
	-- 	notification if acceptance is required.
	-- For other document statuses, insert the following types
	-- of notifications:

	-- 	Document Status		Message Name
	--	---------------		-------------
	-- 	REQUIRES REAPPROVAL	REQUIRES_REAPPROVAL
	--      REJECTED		REJECTED_BY_APPROVER
	-- 	PRE-APPROVED		AWAITING_YOUR_APPROVAL
	-- 	IN PROCESS		AWAITING_YOUR_APPROVAL
	-- 	NEVER APPROVED		NEVER_APPROVED
	-- 	RETURNED		REJECTED_BY_PURCHASING

    -- If no notification is required for this document, message_name
    -- will be returned with NULL value.

    BEGIN

    IF x_document_type_code IN ('RELEASE', 'SCHEDULED') THEN

        x_progress := '020';

        SELECT  DECODE(x_forward_to_id,
			NULL, pr.agent_id,
			x_forward_to_id),
		pr.agent_id,
		ph.comments,
		ph.segment1,
		pr.release_num,
		pr.creation_date,
		pr.agent_id,
                he.full_name,
		nvl(pr.authorization_status, 'INCOMPLETE'),
		ph.currency_code,
		DECODE(pr.acceptance_required_flag,
			   'Y', pr.acceptance_due_date, NULL),
		NULL,
		NULL,
		DECODE(PR.HOLD_FLAG,
		       'Y', 'ON_HOLD',
		       DECODE(PR.AUTHORIZATION_STATUS,
				'APPROVED', DECODE(pr.acceptance_required_flag,
						'Y', 'ACCEPTANCE_PAST_DUE',
						NULL),
			      	'REQUIRES REAPPROVAL', 'REQUIRES_REAPPROVAL',
			      	'REJECTED', 'REJECTED_BY_APPROVER',
				'PRE-APPROVED', 'AWAITING_YOUR_APPROVAL',
				'IN PROCESS', 'AWAITING_YOUR_APPROVAL',
				'NEVER_APPROVED'))
        INTO 	x_forward_to_id,
		x_doc_owner_id,
		x_attribute_array(DESCRIPTION),
		x_attribute_array(SEGMENT1),
		x_attribute_array(RELEASE_NUM),
		x_doc_creation_date,
		x_attribute_array(OWNER_ID),
		x_attribute_array(DOC_OWNER),
		x_attribute_array(AUTHORIZATION_STATUS),
		x_currency_code,
		x_acceptance_due_date,
		x_expiration_date,
		x_close_date,
		x_message_name
        FROM	PO_RELEASES PR,
		PO_HEADERS  PH,
		HR_EMPLOYEES HE
        WHERE   NVL(PR.CANCEL_FLAG,'N') = 'N'
        AND     pr.po_release_id = x_object_id
        AND     pr.po_header_id = ph.po_header_id
	AND     pr.agent_id = he.employee_id;

    ELSIF x_document_type_code IN ('STANDARD', 'PLANNED', 'BLANKET',
	'CONTRACT', 'RFQ', 'QUOTATION') THEN

        x_progress := '030';

        SELECT  DECODE(x_forward_to_id,
			NULL, ph.agent_id,
			x_forward_to_id),
	        ph.agent_id,
		ph.comments,
		ph.segment1,
		NULL,
		ph.creation_date,
		ph.agent_id,
		he.full_name,
		nvl(ph.authorization_status, 'INCOMPLETE'),
		ph.currency_code,
		DECODE(ph.acceptance_required_flag,
			   'Y', ph.acceptance_due_date, NULL),
		DECODE(x_document_type_code,
			   'QUOTATION', ph.end_date,
			   NULL),
		DECODE(x_document_type_code,
			   'RFQ', ph.rfq_close_date,
			   NULL),
 		DECODE(x_document_type_code,
                           'RFQ',DECODE(ph.STATUS_LOOKUP_CODE,
                                        'I','REQUIRES_COMPLETION',
                                        DECODE(x_end_date_active,
                                               NULL,'AWAITING_REPLIES',
                                               'NEAR_CLOSE')),
                           'QUOTATION',DECODE(ph.STATUS_LOOKUP_CODE,
                                              'I','REQUIRES_COMPLETION',
                                              DECODE(x_end_date_active,
                                                     NULL,'ACTIVE',
                                                     'NEAR_EXPIRATION')),
			   DECODE(ph.USER_HOLD_FLAG,
		       		  'Y', 'ON_HOLD',
		       		  DECODE(PH.AUTHORIZATION_STATUS,
					 'APPROVED', DECODE(ph.acceptance_required_flag,
						     'Y', 'ACCEPTANCE_PAST_DUE',
						     NULL),
			      		 'REQUIRES REAPPROVAL', 'REQUIRES_REAPPROVAL',
			      		 'REJECTED', 'REJECTED_BY_APPROVER',
					 'IN PROCESS', 'AWAITING_YOUR_APPROVAL',
					 'PRE-APPROVED', 'AWAITING_YOUR_APPROVAL',
					 'NEVER_APPROVED')))
        INTO 	x_forward_to_id,
		x_doc_owner_id,
		x_attribute_array(DESCRIPTION),
		x_attribute_array(SEGMENT1),
		x_attribute_array(RELEASE_NUM),
		x_doc_creation_date,
		x_attribute_array(OWNER_ID),
		x_attribute_array(DOC_OWNER),
		x_attribute_array(AUTHORIZATION_STATUS),
	        x_currency_code,
		x_acceptance_due_date,
		x_expiration_date,
		x_close_date,
		x_message_name
        FROM	PO_HEADERS ph,
		hr_employees he
        WHERE   NVL(ph.CANCEL_FLAG,'N') != 'Y'
        AND     NVL(ph.STATUS_LOOKUP_CODE, 'I') != 'C'
        AND     po_header_id = x_object_id
	AND	he.employee_id = ph.agent_id;

    ELSIF x_document_type_code IN ('INTERNAL', 'PURCHASE') THEN

        x_progress := '040';

        SELECT  DECODE(x_forward_to_id,
			NULL, prh.preparer_id,
			x_forward_to_id),
		prh.preparer_id,
		prh.description,
		prh.segment1,
		NULL,
		prh.creation_date,
		prh.preparer_id,
		he.full_name,
		nvl(prh.authorization_status, 'INCOMPLETE'),
		NULL,
		NULL,
		NULL,
		DECODE(prh.authorization_status,
		       'REJECTED', 'REJECTED_BY_APPROVER',
		       'RETURNED', 'REJECTED_BY_PURCHASING',
		       'APPROVED', NULL,
		       'IN PROCESS', 'AWAITING_YOUR_APPROVAL',
		       'PRE-APPROVED', 'AWAITING_YOUR_APPROVAL',
		       'NEVER_APPROVED')
        INTO 	x_forward_to_id,
		x_doc_owner_id,
		x_attribute_array(DESCRIPTION),
		x_attribute_array(SEGMENT1),
		x_attribute_array(RELEASE_NUM),
		x_doc_creation_date,
		x_attribute_array(OWNER_ID),
		x_attribute_array(DOC_OWNER),
		x_attribute_array(AUTHORIZATION_STATUS),
		x_acceptance_due_date,
		x_expiration_date,
		x_close_date,
		x_message_name
        FROM	po_requisition_headers prh,
		hr_employees	he
        WHERE   NVL(CANCEL_FLAG,'N') = 'N'
        AND     requisition_header_id = x_object_id
	AND     he.employee_id = prh.preparer_id;

        IF (x_currency_code IS NULL) THEN

	    -- get the currency code

	    x_currency_code := po_core_s2.get_base_currency;

	END IF;

    ELSE
	x_progress := '070';
	PO_MESSAGE_S.SQL_ERROR('GET_DOCUMENT_INFO', x_progress, sqlcode);
    END IF;

    EXCEPTION
	WHEN OTHERS THEN
	    dbms_output.put_line('Exception occurred when selecting from header table');
	    dbms_output.put_line('Document is '||x_document_type_code||' '||TO_CHAR(x_object_id));
	    RAISE;
    END;

    IF x_message_name IS NOT NULL THEN

	dbms_output.put_line('Message name is '||x_message_name);

	-- Determine the type and subtype of the document based on
	-- doc_type from the fnd_notifications table.

	dbms_output.put_line('before call to get_doc_type_subtype');
	po_notifications_sv2.get_doc_type_subtype(x_document_type_code,
					      		x_type,
					      		x_subtype);

        -- IF x_from_id does not have a value, get the id of the sender.

        IF x_from_id IS NULL THEN

            IF x_message_name IN ('AWAITING_YOUR_APPROVAL', 'REJECTED_BY_APPROVER',
		'REJECTED_BY_PURCHASING') THEN

	        -- Need to get sender and note from po_action_history.  Sender is the
	        -- employee that approved, rejected or returned document.  This
		-- should only be necessary for release notifications (when the PO or PA becomes
		-- unapproved and the notification for the release is updated) and
		-- for notifications that are transfered from po_notifications.

	        dbms_output.put_line('before select from po_action_history');

		BEGIN

	        SELECT	poa.employee_id,
		     	poa.note
	        INTO	x_from_id,
			x_note
	        FROM	po_action_history poa
	        WHERE   poa.object_type_code = x_type
	        AND 	poa.object_id = x_object_id
	        AND	poa.sequence_num =  (SELECT	max(sequence_num)
				     	     FROM	po_action_history  pv
				     	     WHERE	pv.object_type_code = poa.object_type_code
				     	     AND 	pv.object_id = poa.object_id
				     	     AND	pv.action_code IN ('FORWARD',
							'SUBMIT', 'REJECT', 'RETURN','APPROVE'));

		EXCEPTION
		    WHEN OTHERS THEN

			-- Bug 412292: For reqimport, insert into po_action_history
			 --  occurs after insert into po_notifications, so we cannot get
			  -- the forward from person from po_action_history.

			x_from_id := x_doc_owner_id;
			x_note := '';

		END;

	    ELSE

		-- For all other documents, sender is document owner.

		x_from_id := x_doc_owner_id;
	        x_note := '';

            END IF;
        END IF;

	dbms_output.put_line('Forward-from id = '||x_from_id);

        IF (x_message_name = 'AWAITING_YOUR_APPROVAL' and x_employee_id IS NULL) THEN

	    -- Find the id of the recipient from po_action_history.  This should only
	    -- be necessary for release notifications (when the base PO or PA becomes
	    -- unapproved and the notification for the release is updated).

	    BEGIN

	    SELECT	employee_id
	    INTO	x_forward_to_id
	    FROM	po_action_history
	    WHERE   	object_type_code = x_type
	    AND 	object_id = x_object_id
	    AND		action_code IS NULL;

	    EXCEPTION
		WHEN OTHERS THEN
		    dbms_output.put_line('Cannot get employee_id from po_action_history');
		    RAISE;
	    END;

	END IF;

	-- Copy value from local variable into OUT variable.

	x_employee_id := x_forward_to_id;
	dbms_output.put_line('Forward-to id = '||x_employee_id);

        -- Document number is segment1-release_num

        IF x_attribute_array(RELEASE_NUM) IS NULL THEN
	    x_doc_num := x_attribute_array(SEGMENT1);
        ELSE
            x_doc_num := x_attribute_array(SEGMENT1)||'-'||x_attribute_array(RELEASE_NUM);
        END IF;

        -- Determine the displayed value for document authorization_status

	dbms_output.put_line('before select from po_lookup_codes');

	BEGIN

            SELECT 	displayed_field
            INTO   	x_attribute_array(AUTHORIZATION_STATUS_DISP)
            FROM   	po_lookup_codes
            WHERE  	lookup_type = 'AUTHORIZATION STATUS'
            AND    	lookup_code = x_attribute_array(AUTHORIZATION_STATUS);

	EXCEPTION
	    WHEN OTHERS THEN
		dbms_output.put_line('cannot get displayed value for authorization status');
		x_attribute_array(AUTHORIZATION_STATUS_DISP) :=  NULL;
	END;

        IF x_message_name = 'ACCEPTANCE_PAST_DUE' THEN

            -- If ACCEPTANCE_PAST_DUE notifications, the start
            -- effective date is the acceptance due date.

	    x_start_date_active := x_acceptance_due_date;

	ELSIF x_message_name IN ('AWAITING_REPLIES', 'REQUIRES_COMPLETION',
	    'ACTIVE') THEN

	    -- Clear the start_effective_date for these types of
	    -- notifications.  This step is needed to fix a Release 10
	    -- bug that assigns the wrong start effective date to these
	    -- types of notifications.

	    x_start_date_active := NULL;

        END IF;


        -- Elements 1 through 19 in x_attribute_array contain
        -- data that is displayed in the notification. Elements 20 and
        -- above contain hidden values.  Since we are using only
        -- elements 1 through ARRAY_FIRST_NULL-1 and elements 20
        -- and above, we need to populate elements FIRST_NULL
        -- through 19 with NULL values.

        FOR x_counter IN ARRAY_FIRST_NULL..ARRAY_LAST_NULL LOOP
	    x_attribute_array(x_counter) := NULL;
        END LOOP;
    END IF;
 */

EXCEPTION
    WHEN OTHERS THEN
	dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('GET_NOTIF_DATA', x_progress, sqlcode);
	RAISE;
END;

END po_notifications_sv1;

/
