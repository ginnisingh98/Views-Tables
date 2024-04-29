--------------------------------------------------------
--  DDL for Package Body PO_REQS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQS_SV" as
/* $Header: POXRQR1B.pls 120.2.12010000.5 2011/11/10 03:16:48 yuandli ship $ */
/*=============================  po_reqs_sv  ===============================*/

/*===========================================================================

  PROCEDURE NAME:	lock_row_for_status_update

===========================================================================*/

PROCEDURE lock_row_for_status_update (x_requisition_header_id  IN  NUMBER)
IS
    CURSOR C IS
        SELECT 	*
        FROM   	po_requisition_headers
        WHERE   requisition_header_id = x_requisition_header_id
        FOR UPDATE of requisition_header_id NOWAIT;
    Recinfo C%ROWTYPE;

    x_progress	VARCHAR2(3) := '';

BEGIN
    x_progress := '010';
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;

EXCEPTION
    WHEN app_exception.record_lock_exception THEN
        po_message_s.app_error ('PO_ALL_CANNOT_RESERVE_RECORD');

    WHEN OTHERS THEN
	-- dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('LOCK_ROW_FOR_STATUS_UPDATE', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:	update_reqs_header_status

===========================================================================*/

 PROCEDURE update_reqs_header_status
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER,
                   X_req_control_action      IN     VARCHAR2,
                   X_req_control_reason      IN     VARCHAR2,
                   X_req_action_history_code IN OUT NOCOPY VARCHAR2,
                   X_req_control_error_rc    IN OUT NOCOPY VARCHAR2) IS

   X_progress                 VARCHAR2(3)  := NULL;
   X_authorization_status     PO_REQUISITION_HEADERS.authorization_status%TYPE := NULL;
   X_closed_code              PO_REQUISITION_HEADERS.closed_code%TYPE := NULL;
   X_req_has_open_shipment    NUMBER       := 0;
   X_req_has_open_line        NUMBER       := 0;

 BEGIN

   -- dbms_output.put_line('Enter update_reqs_header_status');

   X_progress := '000';

   /* 1) set the default header authorization status or closed code value
   **    according to the control action.
   */

   IF SubStr(X_req_control_action,1,6) = 'CANCEL' THEN
      X_authorization_status := 'CANCELLED';
      X_req_action_history_code := SubStr(X_req_control_action,1,6);
   ELSE
      X_authorization_status := NULL;
   END IF;

    IF X_req_control_action = 'FINALLY CLOSE' THEN
      X_closed_code := 'FINALLY CLOSED';
      X_req_action_history_code := X_req_control_action;
   ELSE
      X_closed_code := NULL;
   END IF;

   /* 2) When cancel or final close a line, continue to test
   **    if requisition still has lines that are not finally closed
   **    and are associated with a po shipment.
   **    If YES, set the header authorization status to 'APPROVED' and do not
   **    change the header closed_code.
   */
   /* BUG: 889643 - Changed the ELSEIF to END IF so that the system
   ** goes through both the IF statement if the condition matches. This is
   ** done to keep the authorization status as the same if there are any
   ** open lines in the Req.      */


   IF X_req_line_id is NOT NULL THEN

      X_progress := '010';
      SELECT   COUNT(1),
               nvl(sum(decode(PORL.line_location_id,NULL,0,1)),0)
      INTO    X_req_has_open_line,  X_req_has_open_shipment
      FROM   PO_REQUISITION_LINES PORL
      WHERE  PORL.requisition_header_id = X_req_header_id
      AND    nvl(PORL.cancel_flag, 'N') IN ('N', 'I')
      AND    nvl(PORL.closed_code, 'OPEN') <> 'FINALLY CLOSED';

     IF X_req_has_open_shipment > 0 THEN
        X_authorization_status := 'APPROVED';
        X_req_action_history_code := 'APPROVE';
        X_closed_code := NULL;

     END IF;
     IF X_req_has_open_line > 0 THEN

         /* Requisition still has open lines.  Do not update
         ** requisition header.
         */
           X_authorization_status := NULL;
           X_closed_code := NULL;
           X_req_action_history_code := NULL;
     END IF;

   END IF;

   --Start Bug 9611149 - FP of Bug 9537322
   UPDATE PO_REQUISITION_HEADERS
          SET  active_shopping_cart_flag = null
          WHERE  requisition_header_id = X_req_header_id;
   --End Bug 9611149 - FP of Bug 9537322

   IF X_authorization_status IS NOT NULL OR
      X_closed_code IS NOT NULL THEN
       X_progress := '015';
       UPDATE PO_REQUISITION_HEADERS
       SET    authorization_status  = nvl(X_authorization_status, authorization_status),
              closed_code           = nvl(X_closed_code, closed_code),
              contractor_status     = decode(X_authorization_status,'CANCELLED',null,
                                      contractor_status), -- Bug 3495679
              last_update_login     = fnd_global.login_id,
              last_updated_by       = fnd_global.user_id,
              last_update_date      = sysdate
       WHERE  requisition_header_id = X_req_header_id;
   END IF;

   -- dbms_output.put_line('Exit update_reqs_header_status');

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      X_req_control_error_rc := 'Y';
      po_message_s.sql_error('update_reqs_header_status', X_progress, sqlcode);
      RAISE;
   WHEN OTHERS THEN
      po_message_s.sql_error('update_reqs_header_status', X_progress, sqlcode);
      RAISE;

 END update_reqs_header_status;

-- Bug 930894

/*==========================================================================

  PROCEDURE NAME:	get_req_encumbered()

===========================================================================*/

 FUNCTION  get_req_encumbered(X_req_hdr_id IN  number)
           return boolean is

           X_encumbered boolean := FALSE;

           X_progress VARCHAR2(3) := '';

           cursor c1 is SELECT 'Y'
                        FROM   po_req_distributions
                        WHERE  requisition_line_id
			IN     (SELECT requisition_line_id
				FROM   po_requisition_lines
				WHERE  requisition_header_id = X_req_hdr_id)
                        AND    nvl(encumbered_flag,'N') <> 'N';

           Recinfo c1%rowtype;

BEGIN
     X_progress := '010';
     open c1;
     X_progress := '020';

     /* Check if any distributions for a given req_header_id is encumbered
     ** If there are encumbered distributions, return TRUE else
     ** return FALSE */

     fetch c1 into recinfo;

     X_progress := '030';

     if (c1%notfound) then
        close c1;
        X_encumbered := FALSE;
        return(X_encumbered);
     end if;

     close c1;
     X_encumbered := TRUE;
     return(X_encumbered);


   exception
      when others then
           po_message_s.sql_error('get_req_encumbered', X_progress, sqlcode);
           raise;

END get_req_encumbered;

-- Bug 930894

/*===========================================================================

  PROCEDURE NAME:	val_req_delete()

===========================================================================*/

 FUNCTION  val_req_delete(X_req_hdr_id IN NUMBER)
           return boolean is
           X_allow_delete boolean;

           X_progress VARCHAR2(3) := NULL;
           X_encumbered boolean;

BEGIN

     /* Check if the Reuisition is encumbered */

          X_progress := '005';

          X_encumbered := po_reqs_sv.get_req_encumbered(X_req_hdr_id);

          /* If the REQ is encumbered, it has to be cancelled */

          if X_encumbered then
             X_allow_delete := FALSE;
             po_message_s.app_error('PO_RQ_USE_LINE_DEL');
          else
             X_allow_delete := TRUE;
          end if;

      return(X_allow_delete);


   EXCEPTION
      when others then
           X_allow_delete := FALSE;
           po_message_s.sql_error('val_req_delete', x_progress, sqlcode);
           raise;

END val_req_delete;

/*===========================================================================

  PROCEDURE NAME:	delete_children

===========================================================================*/

PROCEDURE delete_children(X_req_hdr_id	IN NUMBER) IS

x_progress VARCHAR2(3) := NULL;

CURSOR S IS SELECT requisition_line_id
	    FROM   po_requisition_lines
	    WHERE  requisition_header_id = X_req_hdr_id;

BEGIN

   x_progress := '010';

   -- dbms_output.put_line('Before open cursor');

   FOR Srec IN S LOOP
       	DELETE FROM po_req_distributions
	WHERE requisition_line_id = Srec.requisition_line_id;

   x_progress := '020';

       fnd_attached_documents2_pkg.delete_attachments('REQ_LINE',
						      Srec.requisition_line_id,
						      '',
						      '',
						      '',
						      '',
						      'Y');
   x_progress := '030';

	DELETE FROM po_requisition_lines
	WHERE requisition_line_id = Srec.requisition_line_id;

   END LOOP;
   -- dbms_output.put_line('After delete of distributions and lines');

   EXCEPTION
   WHEN OTHERS THEN
      -- dbms_output.put_line('In exception');
      po_message_s.sql_error('delete_children', x_progress, sqlcode);
      raise;
END delete_children;

/*===========================================================================

  PROCEDURE NAME:	delete_req

===========================================================================*/

PROCEDURE delete_req(X_req_hdr_id  IN NUMBER) IS

x_progress 		VARCHAR2(3) := NULL;
x_rowid    		VARCHAR2(30);
x_type_lookup_code	VARCHAR2(25):= NULL;
x_item_type             VARCHAR2(8);
x_item_key		VARCHAR2(240);
x_allow_delete		BOOLEAN;

BEGIN

   x_progress := '010';

   SELECT type_lookup_code
   INTO   x_type_lookup_code
   FROM   po_requisition_headers
   WHERE  requisition_header_id = X_req_hdr_id;

   /* Validate if the Document can be deleted */

   x_allow_delete := val_req_delete(X_req_hdr_id);

   /* If the Documnet can be deleted */

   IF (x_allow_delete) THEN

      /*
      ** Delete the notification.
      **/

      x_progress := '020';

      /* hvadlamu : commnting out the delete and adding the WorkFlow call */

      SELECT wf_item_type,wf_item_key
      INTO   x_item_type,x_item_key
      FROM PO_REQUISITION_HEADERS
      WHERE requisition_header_id = x_req_hdr_id;

	if ((x_item_type is null) and (x_item_key is null)) then
		 po_approval_reminder_sv.cancel_notif (x_type_lookup_code,
                                     x_req_hdr_id);
	else
 /*Bug 3047646 : the line below has been added to ensure that
		 po send notification items are deleted.
		 when trying to delete a requisition it could be that it was submitted to
		 approval workflow and was never approved and also po send notification
		 was also invoked for it,in which case  we need to stop the approval
		 workflow as well as the  reminder workflow */

		 po_approval_reminder_sv.cancel_notif (x_type_lookup_code,
                                     x_req_hdr_id);
          	 po_approval_reminder_sv.stop_process(x_item_type,x_item_key);
	end if;
        /* Bug 2904413 Need to delete the action history also */

        Delete po_action_history
        Where OBJECT_TYPE_CODE = 'REQUISITION' and
              OBJECT_SUB_TYPE_CODE = x_type_lookup_code and
              OBJECT_ID = x_req_hdr_id;

   /* po_notifications_sv1.delete_po_notif (x_type_lookup_code,
					 x_req_hdr_id); */

      x_progress := '030';

      SELECT rowid
      INTO   x_rowid
      FROM   po_requisition_headers
      WHERE  requisition_header_id = X_req_hdr_id;

      -- dbms_output.put_line('After selecting rowid');

      /*
      ** Delete all the  distributions and lines
      ** for this requisition header.
      */

      x_progress := '040';

      po_headers_sv1.delete_events_entities('REQUISITION', X_req_hdr_id);  --Bug 12405805

      po_reqs_sv.delete_children(X_req_hdr_id);

      -- dbms_output.put_line('After delete children');

      /*
      ** Delete the attachments.
      */

      x_progress := '050';

       fnd_attached_documents2_pkg.delete_attachments('REQ_HEADER',
						      x_req_hdr_id,
						      '',
						      '',
						      '',
						      '',
						      'Y');

      /*
      ** Delete the requisition header.
      */

      x_progress := '060';

      po_requisition_headers_pkg.delete_row(X_rowid);

      -- dbms_output.put_line('After delete row');

   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      -- dbms_output.put_line('In exception');
      po_message_s.sql_error('delete_req', x_progress, sqlcode);
      raise;
END delete_req;

/*===========================================================================

  PROCEDURE NAME:	insert_req()

===========================================================================*/

PROCEDURE   insert_req(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Requisition_Header_Id   IN OUT	NOCOPY NUMBER,
                       X_Preparer_Id                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Segment1                IN OUT NOCOPY VARCHAR2,
                       X_Summary_Flag                   VARCHAR2,
                       X_Enabled_Flag                   VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Description                    VARCHAR2,
                       X_Authorization_Status           VARCHAR2,
                       X_Note_To_Authorizer             VARCHAR2,
                       X_Type_Lookup_Code               VARCHAR2,
                       X_Transferred_To_Oe_Flag         VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_On_Line_Flag                   VARCHAR2,
                       X_Preliminary_Research_Flag      VARCHAR2,
                       X_Research_Complete_Flag         VARCHAR2,
                       X_Preparer_Finished_Flag         VARCHAR2,
                       X_Preparer_Finished_Date         DATE,
                       X_Agent_Return_Flag              VARCHAR2,
                       X_Agent_Return_Note              VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Interface_Source_Code          VARCHAR2,
                       X_Interface_Source_Line_Id       NUMBER,
                       X_Closed_Code                    VARCHAR2,
		       X_Manual				BOOLEAN,
		       X_amount				NUMBER,
		       X_currency_code			VARCHAR2,
                       p_org_id                     IN  NUMBER     default null        -- <R12 MOAC>
		       ) IS


x_progress VARCHAR2(3) := NULL;

BEGIN

   x_progress := '010';

   po_requisition_headers_pkg.insert_row(X_Rowid,
                       			 X_Requisition_Header_Id,
                       			 X_Preparer_Id,
                       			 X_Last_Update_Date,
                       			 X_Last_Updated_By,
                       			 X_Segment1,
                       			 X_Summary_Flag,
                       			 X_Enabled_Flag,
                       			 X_Segment2,
                       			 X_Segment3,
                       			 X_Segment4,
                      			 X_Segment5,
                     			 X_Start_Date_Active,
                       			 X_End_Date_Active,
                       			 X_Last_Update_Login,
                       			 X_Creation_Date,
                       			 X_Created_By,
                       			 X_Description,
                       			 X_Authorization_Status,
                       			 X_Note_To_Authorizer,
                       			 X_Type_Lookup_Code,
                       			 X_Transferred_To_Oe_Flag,
                       			 X_Attribute_Category,
                       			 X_Attribute1,
                       			 X_Attribute2,
                       			 X_Attribute3,
                       			 X_Attribute4,
                       			 X_Attribute5,
                       			 X_On_Line_Flag,
		                         X_Preliminary_Research_Flag,
                  		         X_Research_Complete_Flag,
                       			 X_Preparer_Finished_Flag,
                       			 X_Preparer_Finished_Date,
                       			 X_Agent_Return_Flag,
                       			 X_Agent_Return_Note,
                       			 X_Cancel_Flag,
                       			 X_Attribute6,
                       			 X_Attribute7,
                       			 X_Attribute8,
                       			 X_Attribute9,
                       			 X_Attribute10,
                       			 X_Attribute11,
                      			 X_Attribute12,
                       			 X_Attribute13,
                       			 X_Attribute14,
                       			 X_Attribute15,
                       			 NULL, --<R12 SLA>
                       			 X_Government_Context,
                       			 X_Interface_Source_Code,
                       			 X_Interface_Source_Line_Id,
                       			 X_Closed_Code,
		       			 X_Manual,
					 p_org_id                  -- <R12 MOAC>
					 );

    -- dbms_output.put_line('After call to insert row');

   /*
   ** DEBUG. Call the routine to insert
   ** notifications.
   */

   x_progress := '020';

 /*  bug# 465696 8/5/97. The previous fix to this performance problem introduced
   a problem with the notifications (the bogus value used temporarily as the
   document number was being inserted into the fnd_notifications table, since
   the call below was made before we called the procedure to get the real
   document number (segment1) in the POST-FORMS-COMMIT trigger.
   Therefore, remove the call below from here and moving it to procedure
   PO_REQUISITION_HEADERS_PKG.get_real_segment1.
 */

   IF X_Manual THEN

/*hvadlamu : commenting out since notifications will be handled by workflow */
       /*po_notifications_sv1.send_po_notif (x_type_lookup_code,
				       x_requisition_header_id,
				       x_currency_code,
				       null,
				       null,
				       null,
				       null,
				       null); */
        null;
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      -- dbms_output.put_line('In exception');
      po_message_s.sql_error('insert_req', x_progress, sqlcode);
      raise;
END insert_req;


/*===========================================================================

  PROCEDURE NAME:	update_oe_flag

===========================================================================*/

PROCEDURE update_oe_flag(X_req_hdr_id	IN NUMBER,
			 X_flag		IN VARCHAR2) IS

x_progress VARCHAR2(3) := NULL;

BEGIN

   x_progress := '010';

   UPDATE po_requisition_headers
   SET transferred_to_oe_flag = X_flag
   WHERE requisition_header_id = X_req_hdr_id;

   -- dbms_output.put_line('After update');

   EXCEPTION
   WHEN OTHERS THEN
      -- dbms_output.put_line('In exception');
      po_message_s.sql_error('update_oe_flag', x_progress, sqlcode);
      raise;
END update_oe_flag;


/*===========================================================================

  PROCEDURE NAME:	get_req_startup_values

===========================================================================*/

PROCEDURE get_req_startup_values (X_source_inventory	IN OUT NOCOPY  VARCHAR2,
			 	  X_source_vendor	IN OUT NOCOPY  VARCHAR2) IS

x_progress VARCHAR2(3) := NULL;

BEGIN

   x_progress := '010';

   po_core_s.get_displayed_value ('REQUISITION SOURCE TYPE',
				  'INVENTORY',
				  x_source_inventory);

  x_progress := '020';

  po_core_s.get_displayed_value ('REQUISITION SOURCE TYPE',
				 'VENDOR',
				 x_source_vendor);


   -- dbms_output.put_line('After update');

   EXCEPTION
   WHEN OTHERS THEN
      -- dbms_output.put_line('In exception');
      po_message_s.sql_error('get_req_startup_values', x_progress, sqlcode);
      raise;
END get_req_startup_values;


END PO_REQS_SV;

/
