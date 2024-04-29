--------------------------------------------------------
--  DDL for Package Body PO_NOTIFICATIONS_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NOTIFICATIONS_SV3" AS
/* $Header: POXBWN3B.pls 120.1.12010000.3 2014/01/20 06:28:14 roqiu ship $*/

/*===========================================================================

  PROCEDURE NAME:       forward_all

===========================================================================*/

PROCEDURE forward_all (x_old_employee_id  IN NUMBER,
		       x_new_employee_id  IN NUMBER,
		       x_note		  IN VARCHAR2 DEFAULT NULL) IS

	x_progress	    VARCHAR2(3)  := '';
	x_notification_id   NUMBER;
	x_doc_type	    VARCHAR2(25);
	x_object_id	    NUMBER;

	-- Cursor C will select all approval-required notifications
	-- whose recipient id is x_old_employee_id.

    /* Commenting out since no longe rused in R11
	CURSOR C is
	    SELECT notification_id, doc_type, object_id
	    FROM   fnd_notifications
	    WHERE  employee_id = x_old_employee_id
	    AND    message_name = 'AWAITING_YOUR_APPROVAL'; */

BEGIN
    x_progress := '010';
   /* Commenting out since no longe rused in R11
    OPEN C;
    LOOP
 	x_progress := '030';
	FETCH C into x_notification_id, x_doc_type, x_object_id;
	EXIT WHEN C%NOTFOUND;

	ntn.forward_notification(x_notification_id, x_new_employee_id, x_note);

        -- Forward notification in po_notifications.

	PO_NOTIFICATIONS_SV2.update_po_notif (x_new_employee_id,
				   x_doc_type,
				   x_object_id);

    END LOOP;
    CLOSE C;
   */
EXCEPTION
    WHEN OTHERS THEN
	-- dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('FORWARD_ALL', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       forward_document

===========================================================================*/

PROCEDURE forward_document (x_new_employee_id  IN NUMBER,
			    x_doc_type	       IN VARCHAR2,
			    x_object_id	       IN NUMBER,
			    x_note	       IN VARCHAR2 DEFAULT NULL) IS

	x_progress	    	VARCHAR2(3)  := '';
	x_notification_id   	NUMBER;

	-- Cursor C will select the approval-required notification
	-- for this document.

   /*  Commenting out since no longe rused in R11
	CURSOR C is
	    SELECT notification_id
	    FROM   fnd_notifications
	    WHERE  doc_type = x_doc_type
	    AND	   object_id = x_object_id
	    AND    message_name = 'AWAITING_YOUR_APPROVAL'; */

BEGIN
    x_progress := '010';
    /* Commenting out since no longe rused in R11
    OPEN C;

	FETCH C into x_notification_id;

	-- dbms_output.put_line('Before forwarding fnd notification');
	ntn.forward_notification(x_notification_id, x_new_employee_id, x_note);

        -- Forward the same notification in po_notifications.

	-- dbms_output.put_line('Before forwarding po notification');
	PO_NOTIFICATIONS_SV2.update_po_notif (x_new_employee_id,
		    		   x_doc_type,
		  		   x_object_id);

	-- dbms_output.put_line('Done');

    CLOSE C;
    */
EXCEPTION
    WHEN OTHERS THEN
	-- dbms_output.put_line('Exception in forward_document');
	PO_MESSAGE_S.SQL_ERROR('FORWARD_DOCUMENT', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       delete_from_fnd_notif

===========================================================================*/

PROCEDURE delete_from_fnd_notif (n_object_type_lookup_code  IN VARCHAR2,
			   	 n_object_id	            IN NUMBER)
IS
	x_doc_type	VARCHAR2(30) := '';
	x_progress	VARCHAR2(3) := '';
BEGIN


    -- Check if notification has already been deleted from fnd_notifications.
    -- If not, delete notification.

    x_progress := '020';
    -- dbms_output.put_line('before select');
  /* Commenting out since no longe rused in R11

    BEGIN

    IF n_object_type_lookup_code = 'REQUISITION' THEN

	SELECT    doc_type
    	INTO      x_doc_type
    	FROM      fnd_notifications_v
    	WHERE     object_id = n_object_id
    	AND       doc_type IN ('PURCHASE', 'INTERNAL');

    ELSIF n_object_type_lookup_code = 'RELEASE' THEN

	SELECT    doc_type
    	INTO      x_doc_type
    	FROM      fnd_notifications_v
    	WHERE     object_id = n_object_id
    	AND       doc_type IN ('RELEASE', 'SCHEDULED');

    ELSE

	SELECT    doc_type
    	INTO      x_doc_type
    	FROM      fnd_notifications_v
    	WHERE     object_id = n_object_id
    	AND       doc_type = n_object_type_lookup_code;

    END IF;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    return;
	WHEN OTHERS THEN
	    -- dbms_output.put_line('In Exception');
	    PO_MESSAGE_S.SQL_ERROR('delete_fnd_notifications', x_progress, sqlcode);
	    RAISE;
    END ;

    -- delete notification from fnd_notifications.

    x_progress := '030';
    -- dbms_output.put_line('before call to delete_notif_by_id_type');

    po_notifications_sv1.delete_notif_by_id_type(n_object_id, x_doc_type);

    -- dbms_output.put_line('after call to delete_notif_by_id_type');
  */

EXCEPTION
    WHEN OTHERS THEN
	-- dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('delete_from_fnd_notif', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       get_doc_total

===========================================================================*/

FUNCTION get_doc_total (x_document_type_code	VARCHAR2,
			x_object_id		NUMBER)
return NUMBER IS
	x_progress	         VARCHAR2(3) := '';
	x_code                   VARCHAR2(30):= '';
	x_amount		 NUMBER;
	INVALID_DOC_TYPE	 EXCEPTION;
BEGIN

/* Bug 435402
 * Need to display 'Amount Agreed' instead of 'Amount Released'
 * for Blanket and Contract PO

    IF (x_document_type_code IS NOT NULL) THEN

	IF (x_document_type_code = 'PLANNED') THEN
		x_code := 'P';
	ELSIF (x_document_type_code = 'CONTRACT') THEN
		x_code := 'C';
	ELSIF (x_document_type_code IN ('RELEASE', 'SCHEDULED')) THEN
		x_code := 'R';
	ELSIF (x_document_type_code IN ('INTERNAL', 'PURCHASE')) THEN
		x_code := 'E';
	ELSIF (x_document_type_code = 'BLANKET') THEN
		x_code := 'B';
	ELSIF (x_document_type_code = 'STANDARD') THEN
		x_code := 'H';
	ELSE
		raise INVALID_DOC_TYPE;
	END IF;

	x_amount := po_core_s.get_total(x_code, x_object_id);

    END IF;
*/

    IF (x_document_type_code IS NOT NULL) THEN
	IF (x_document_type_code IN ('BLANKET', 'CONTRACT')) THEN

	 SELECT nvl(BLANKET_TOTAL_AMOUNT,0) -- bug 17926788, Add nvl method, as the amount is not mandatory.
	 INTO x_amount
	 FROM PO_HEADERS_ALL ph
	 WHERE ph.po_header_id = x_object_id;

	ELSE
-- Bug 482497, lpo, 12/22/97
-- If code = 'PLANNED' use 'H' as x_code instead of 'P' to get the total in
-- the PO line level. (Using 'P' will get the total released amount.)
		IF ((x_document_type_code = 'PLANNED') OR
		    (x_document_type_code = 'STANDARD')) THEN
			x_code := 'H';
		ELSIF (x_document_type_code IN ('RELEASE', 'SCHEDULED')) THEN
			x_code := 'R';
		ELSIF (x_document_type_code IN ('INTERNAL', 'PURCHASE')) THEN
			x_code := 'E';
		ELSE
			raise INVALID_DOC_TYPE;
		END IF;
-- End of fix. Bug 482497, lpo, 12/22/97
		x_amount := po_core_s.get_total(x_code, x_object_id);

 	END IF;

    END IF;

    return(x_amount);

EXCEPTION
    WHEN INVALID_DOC_TYPE THEN
	RAISE;
    WHEN OTHERS THEN
	RAISE;
END;


FUNCTION get_emp_name (x_emp_id  NUMBER)
	return VARCHAR2 IS
   v_full_name VARCHAR2(240);
BEGIN
  BEGIN
    SELECT   FULL_NAME
      INTO   v_full_name
      FROM   HR_EMPLOYEES
     WHERE   EMPLOYEE_ID = x_emp_id;
  EXCEPTION
   WHEN OTHERS THEN
     v_full_name := NULL;
  END;
  return v_full_name;

END;

FUNCTION get_wf_role_id (x_role_name VARCHAR2)
	return NUMBER IS
   v_role_id NUMBER;

  colon pls_integer;

  cursor c_role is
    select orig_system_id
    from wf_users
    where name = x_role_name
    and orig_system not in ('HZ_PARTY', 'POS', 'ENG_LIST', 'CUST_CONT');

  cursor corig_role is
    select orig_system_id
    from wf_users
    where orig_system = substr(x_role_name, 1, colon-1)
    and orig_system_id = substr(x_role_name, colon+1)
    and name = x_role_name
    and orig_system not in ('POS', 'ENG_LIST', 'CUST_CONT');

BEGIN

  colon := instr(x_role_name, ':');
  if (colon = 0) then
    open c_role;
    fetch c_role into v_role_id;
    close c_role;
  else
    open corig_role;
    fetch corig_role into v_role_id;
    close corig_role;
  end if;

  return v_role_id;

END;

END PO_NOTIFICATIONS_SV3;

/
