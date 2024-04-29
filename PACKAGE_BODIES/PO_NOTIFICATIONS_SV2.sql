--------------------------------------------------------
--  DDL for Package Body PO_NOTIFICATIONS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NOTIFICATIONS_SV2" AS
/* $Header: POXBWN2B.pls 120.0 2005/06/01 15:11:10 appldev noship $*/

	ARRAY_LB			NUMBER := 1;
        ARRAY_UB			NUMBER := 23;

/*===========================================================================

  PROCEDURE NAME:       insert_into_po_notif

===========================================================================*/

PROCEDURE insert_into_po_notif (x_employee_id  	IN 	NUMBER,
			x_message_name		IN	VARCHAR2,
			x_doc_type		IN 	VARCHAR2,
			x_object_id		IN 	NUMBER,
			x_doc_creation_date	IN      DATE,
			x_start_effective_date  IN	DATE,
			x_end_effective_date	IN	DATE) IS

    x_approved_flag	VARCHAR2(255) := '';
    x_progress		VARCHAR2(3) := '';
    x_user_id  		NUMBER  := FND_GLOBAL.user_id;
    x_login_id 		NUMBER  := FND_GLOBAL.login_id;


BEGIN

    -- dbms_output.put_line('before insert');

    -- Insert notification into po_notifications.
 -- put null as bugfix for bug# 155260
    null;
    -- dbms_output.put_line('after insert');

EXCEPTION
    WHEN OTHERS THEN
	-- dbms_output.put_line('Exception occurred in insert_into_po_notif');
	PO_MESSAGE_S.SQL_ERROR('insert_into_po_notif', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       update_fnd_notif

===========================================================================*/

PROCEDURE update_fnd_notif (x_object_type_lookup_code	IN  VARCHAR2,
			    x_object_id			IN  NUMBER,
			    x_old_employee_id		IN  NUMBER,
			    x_new_employee_id		IN  NUMBER) IS
	x_type		  VARCHAR2(30) := '';
	x_subtype	  VARCHAR2(30) := '';
	x_notification_id NUMBER;
	x_progress	  VARCHAR2(3)  := '';
	x_note		  VARCHAR2(300) := '';
	x_fnd_doc_type	  VARCHAR2(25) := '';

BEGIN

      null;


EXCEPTION
    WHEN OTHERS THEN
	-- dbms_output.put_line('Exception occurred in update_fnd_notif');
	PO_MESSAGE_S.SQL_ERROR('UPDATE_FND_NOTIF', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       update_po_notif

===========================================================================*/

PROCEDURE update_po_notif (x_new_employee_id		NUMBER,
		           x_doc_type			VARCHAR2,
		           x_object_id		NUMBER)  IS
    x_user_id  		NUMBER  := FND_PROFILE.Value('USER_ID');
    x_login_id 		NUMBER  := FND_PROFILE.Value('LOGIN_ID');
    x_progress		VARCHAR2(3) := '';
    x_rowid		ROWID;


BEGIN
      null;

EXCEPTION
    WHEN OTHERS THEN
	-- dbms_output.put_line('Exception occurred in update_po_notif');
	PO_MESSAGE_S.SQL_ERROR('UPDATE_PO_NOTIF', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       delete_from_po_notif

===========================================================================*/

PROCEDURE delete_from_po_notif (x_doc_type	IN	VARCHAR2,
			        x_object_id	IN	NUMBER) IS

	x_progress	VARCHAR2(3) := '';

BEGIN

   x_progress := '010';

EXCEPTION
   WHEN OTHERS THEN
       -- dbms_output.put_line('Exception occurred in delete_from_po_notif');
       po_message_s.sql_error('delete_from_po_notif', x_progress, sqlcode);
       RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       get_doc_type_subtype

===========================================================================*/

PROCEDURE get_doc_type_subtype (x_notif_doc_type	IN	VARCHAR2,
			    x_type		OUT	NOCOPY VARCHAR2,
			    x_subtype		OUT	NOCOPY VARCHAR2) IS
	x_progress	VARCHAR2(3) := '';
BEGIN

     -- Determine the document type and subtype
     -- given the document type lookup code in fnd_notifications.

     IF x_notif_doc_type = 'RELEASE' THEN
	x_type := 'RELEASE';
	x_subtype := 'BLANKET';

     ELSIF x_notif_doc_type = 'SCHEDULED' THEN
	x_type := 'RELEASE';
	x_subtype := x_notif_doc_type;

     ELSIF x_notif_doc_type IN ('INTERNAL', 'PURCHASE') THEN
	x_type := 'REQUISITION';
	x_subtype := x_notif_doc_type;

     ELSIF x_notif_doc_type IN ('STANDARD', 'PLANNED') THEN
	x_type := 'PO';
	x_subtype := x_notif_doc_type;

     ELSIF x_notif_doc_type IN ('BLANKET', 'CONTRACT') THEN
	x_type := 'PA';
	x_subtype := x_notif_doc_type;

     ELSIF x_notif_doc_type = 'QUOTATION' THEN
	x_type := 'QUOTATION';

     ELSIF x_notif_doc_type = 'RFQ' THEN
	x_type := 'RFQ';

     ELSE
	x_progress := '030';
	PO_MESSAGE_S.SQL_ERROR('GET_DOC_TYPE_SUBTYPE', x_progress, sqlcode);

     END IF;

EXCEPTION
    WHEN OTHERS THEN
	-- dbms_output.put_line('Exception occurred in get_doc_type_subtype');
	PO_MESSAGE_S.SQL_ERROR('GET_DOC_TYPE_SUBTYPE', x_progress, sqlcode);
END;

/*===========================================================================

  PROCEDURE NAME:       get_fnd_doc_type

===========================================================================*/

PROCEDURE get_fnd_doc_type (x_po_type_code      IN     VARCHAR2,
				x_object_id	    IN     NUMBER,
			        x_fnd_type_code	    IN OUT NOCOPY VARCHAR2) IS
	x_progress	VARCHAR2(3) := '';
BEGIN

    x_progress := '010';
    IF (x_po_type_code IS NOT NULL AND
	x_object_id IS NOT NULL) THEN

        -- If document_type_lookup_code in po_notifications
        -- is REQUISTION, then we need to determine whether
        -- document is an INTERNAL or PURCHASE requisition.

	IF x_po_type_code = 'REQUISITION' THEN

            x_progress := '020';

	    SELECT  type_lookup_code
	    INTO    x_fnd_type_code
	    FROM    po_requisition_headers
	    WHERE   requisition_header_id = x_object_id;

        -- If document_type_lookup_code in po_notifications
        -- is RELEASE, then we need to determine whether
        -- document is an BLANKET or SCHEDULED release.

	ELSIF x_po_type_code = 'RELEASE' THEN

	   x_progress := '030';
	    SELECT  release_type
	    INTO    x_fnd_type_code
	    FROM    po_releases
	    WHERE   po_release_id = x_object_id;

	    -- Since we can have Blanket POs, use
	    -- 'RELEASE' as the type lookup code
            -- for blanket releases.

	    IF x_fnd_type_code = 'BLANKET' THEN
		x_fnd_type_code := 'RELEASE';
	    END IF;

        -- Otherwise, document type code in fnd_notifications is
        -- the same as that in po_notifications.

 	ELSE
	    x_progress := '040';
	    x_fnd_type_code := x_po_type_code;
        END IF;

    ELSE
	x_progress := '050';
	x_fnd_type_code := '';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	-- dbms_output.put_line('cannot get fnd doc type');
	PO_MESSAGE_S.SQL_ERROR('GET_FND_DOC_TYPE', x_progress, sqlcode);
	RAISE;
END;


/*===========================================================================

  PROCEDURE NAME:       get_fnd_message_name

===========================================================================*/

PROCEDURE get_fnd_msg_name (x_old_message_name	IN     VARCHAR2,
			    x_new_message_name	IN OUT NOCOPY VARCHAR2) IS
	x_progress	VARCHAR2(3) := '';
BEGIN
    x_progress := '010';

    IF x_old_message_name = 'AWAITING_REPLIES' THEN
	x_new_message_name := 'NEAR_CLOSE';

    ELSIF x_old_message_name = 'AWAITING_REPLIES_NO_EXP' THEN
	x_new_message_name := 'AWAITING_REPLIES';

    ELSIF x_old_message_name IN ('APPROVAL', 'APPROVAL_OR_RESERVE') THEN
	x_new_message_name := 'AWAITING_YOUR_APPROVAL';

    ELSIF x_old_message_name IN ('FAILED_APPROVAL', 'REJECTED_BY_APPROVER') THEN
	x_new_message_name := 'REJECTED_BY_APPROVER';

    ELSIF x_old_message_name = 'IN_PROCESS' THEN
	x_new_message_name := 'REQUIRES_COMPLETION';

    ELSIF x_old_message_name IN ('ON_HOLD', 'ON_USER_HOLD') THEN
	x_new_message_name := 'ON_HOLD';

    ELSIF x_old_message_name IN ('ACCEPTANCE_PAST_DUE', 'NEAR_EXPIRATION',
				'ACTIVE', 'REJECTED_BY_PURCHASING',
				'NEVER_APPROVED', 'REQUIRES_REAPPROVAL') THEN
	x_new_message_name := x_old_message_name;

    ELSE
	x_progress := '020';
	PO_MESSAGE_S.SQL_ERROR('GET_FND_MESSAGE_NAME', x_progress, sqlcode);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	-- dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('GET_FND_MESSAGE_NAME', x_progress, sqlcode);
END;

/*===========================================================================

  PROCEDURE NAME:       insert_into_fnd_notif

===========================================================================*/

PROCEDURE insert_into_fnd_notif(n_object_type_lookup_code  IN  VARCHAR2,
			   n_object_id		      IN  NUMBER,
			   n_employee_id	      IN  NUMBER,
			   n_start_date_active	      IN  DATE,
			   n_end_date_active	      IN  DATE,
			   n_notification_id	      OUT NOCOPY NUMBER) IS
	x_dummy_str             VARCHAR2(30) := '';
	x_doc_num               VARCHAR2(255) := '';
	x_doc_type              VARCHAR2(30) := '';
	x_message_name	        VARCHAR2(30) := '';
	x_employee_id		NUMBER 	:= n_employee_id;
	x_start_date		DATE := n_start_date_active;
	x_return_code		NUMBER;
	x_forward_from_id	NUMBER := '';
	x_note			VARCHAR2(300) := '';
	--x_attribute_array	ntn.char_array;
	x_progress		VARCHAR2(3)   := '';
	x_currency_code		VARCHAR2(35) := '';
	x_doc_creation_date	DATE;
	x_expiration_date	DATE;
	x_close_date		DATE;
	x_acceptance_due_date   DATE;
BEGIN

    -- Determine the document type lookup code for fnd_notifications.

    x_progress := '010';


EXCEPTION
    WHEN OTHERS THEN
	-- dbms_output.put_line('Exception occurred in insert_into_fnd_notif');
	PO_MESSAGE_S.SQL_ERROR('INSERT_INTO_FND_NOTIF', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       install_fnd_notif

===========================================================================*/

PROCEDURE install_fnd_notif IS
	x_progress   			VARCHAR2(3) := '';
	x_employee_id			NUMBER;
	x_object_type_lookup_code	VARCHAR2(30) := '';
	x_object_id			NUMBER;
	x_last_update_date		DATE;
	x_last_updated_by		NUMBER;
	x_last_update_login		NUMBER;
	x_creation_date			DATE;
	x_created_by			NUMBER;
	x_object_creation_date		DATE;
	x_action_lookup_code		VARCHAR2(30);
	x_org_info                	VARCHAR2(30);
	x_start_date_active		DATE;
	x_end_date_active		DATE;
	x_notification_id		NUMBER;
	x_row_id			ROWID;
        x_org_id                        NUMBER;


    -- Select all orgids from FINANCIALS_SYSTEM_PARAMS_ALL
    -- This is used to set the client info context while running
    -- the upgrade of po notifications (char mode) and fnd_notifications
    -- SC mode.

        CURSOR C2 IS
            SELECT ORG_ID
            FROM   FINANCIALS_SYSTEM_PARAMS_ALL;

BEGIN

    -- -- dbms_output.enable (500000);

    -- Delete all records from fnd_notifications.
    null;

EXCEPTION
    WHEN OTHERS THEN
	-- dbms_output.put_line('Exception in install_fnd_notif');
	PO_MESSAGE_S.SQL_ERROR('INSTALL_FND_NOTIF', x_progress, sqlcode);
END;

END po_notifications_sv2;

/
