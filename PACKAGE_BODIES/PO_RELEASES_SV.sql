--------------------------------------------------------
--  DDL for Package Body PO_RELEASES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RELEASES_SV" as
/* $Header: POXPOR1B.pls 120.1.12010000.3 2011/05/23 10:35:42 vegajula ship $ */

/*========================  PO_RELEASES_SV  ===============================*/

/*===========================================================================

  PROCEDURE NAME:	lock_row_for_status_update

===========================================================================*/

PROCEDURE lock_row_for_status_update (x_po_release_id  IN  NUMBER)
IS
    CURSOR C IS
        SELECT 	*
        FROM   	po_releases
        WHERE   po_release_id = x_po_release_id
        FOR UPDATE of po_release_id NOWAIT;
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
	dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('LOCK_ROW_FOR_STATUS_UPDATE', x_progress, sqlcode);
	RAISE;
END;


/*===========================================================================

  PROCEDURE NAME:	delete_release


===========================================================================*/
   PROCEDURE delete_release
		      (X_po_release_id IN NUMBER,
	               X_row_id        IN VARCHAR2) IS

      X_progress                VARCHAR2(3)  := '';
      x_item_type         PO_RELEASES_ALL.WF_ITEM_TYPE%TYPE;
      x_item_key          PO_RELEASES_ALL.WF_ITEM_KEY%TYPE;
      X_release_type      PO_RELEASES_ALL.RELEASE_TYPE%TYPE;

      BEGIN

         /*
         ** Call the table handler to delete the release shipment row.
         */
   /* Bug 2904413 */
      X_progress := '010';

      SELECT wf_item_key, wf_item_type, release_type
      INTO   x_item_key, x_item_type, X_release_type
      FROM   po_releases
      WHERE  po_release_id = X_po_release_id;

    X_progress := '020';

       	if ((x_item_type is null) and (x_item_key is null)) then
  		 po_approval_reminder_sv.cancel_notif (X_release_type, X_po_release_id,'Y');
  	else
                 po_approval_reminder_sv.cancel_notif (X_release_type, X_po_release_id,'Y');
                 po_approval_reminder_sv.stop_process(x_item_type,x_item_key);
    	end if;

    X_progress := '030';

       Delete From po_action_history
       Where OBJECT_TYPE_CODE = 'RELEASE' and
             OBJECT_SUB_TYPE_CODE = X_release_type and
             OBJECT_ID = X_po_release_id;

    X_progress := '040';

       fnd_attached_documents2_pkg.delete_attachments('PO_RELEASES', X_po_release_id,'', '', '', '', 'Y');

  /* Bug 2904413 */
      X_progress := '050';

         /*12405805  changed the order of delete_children and delete_row*/
	 /* Added delete_events_entities call to delete unnecessary events n entities*/
	 /** Call the cover routine to delete all of the children
         */

         po_headers_sv1.delete_events_entities('RELEASE', X_po_release_id);
         po_releases_sv.delete_children(X_po_release_id);
	 -- dbms_output.put_line('after delete children');

            po_releases_pkg_s2.delete_row(X_row_id);
         -- dbms_output.put_line('after call to delete row');


      EXCEPTION
	WHEN OTHERS THEN
	  -- dbms_output.put_line('In exception');
	  po_message_s.sql_error('delete_release', X_progress, sqlcode);
          raise;
      END delete_release;


/*===========================================================================

  PROCEDURE NAME:	delete_children


===========================================================================*/
   PROCEDURE delete_children
		      (X_po_release_id IN NUMBER) IS

      X_progress                VARCHAR2(3)  := '';
      X_entity_level            VARCHAR2(25) := 'RELEASE';
      x_line_location_id        NUMBER := '';
      x_item_type               VARCHAR2(8);
      x_item_key                VARCHAR2(240);

      CURSOR C is
         SELECT line_location_id
         FROM   po_line_locations
         WHERE  po_release_id = X_po_release_id;


      BEGIN

	 /*
         ** Call the routine to delete all of the release shipments.
         */
         po_shipments_sv4.delete_all_shipments(X_po_release_id,
				  	       X_entity_level,
					       'NOT RFQ/QUOTE');

	 /*
	 ** Call the routine to delete all of the release distributions.
	 */
	 po_distributions_sv.delete_distributions(X_po_release_id,
						  'RELEASE');

         /*
         ** Call the routine to delete all attachements.
	 */
	 fnd_attached_documents2_pkg.delete_attachments('PO_RELEASE',
				     X_po_release_id,
				     '', '', '', '', 'Y');

	 OPEN C;

         LOOP

            FETCH C INTO x_line_location_id;
            EXIT WHEN C%notfound;

            fnd_attached_documents2_pkg.delete_attachments('PO_SHIPMENT',
                                     x_line_location_id,
                                     '', '', '', '', 'Y');
         END LOOP;

	 CLOSE C;

	 /*
	 ** Call the routine to delete all notifications.
	 */

         /*hvadlamu : commenting out the delete and adding the workflow call*/

	 /*po_notifications_sv1.delete_po_notif ('RELEASE',
		           			X_po_release_id); */
	   SELECT wf_item_type,wf_item_key
       	   INTO   x_item_type,x_item_key
       	   FROM   PO_RELEASES
       	   WHERE  po_release_id = x_po_release_id;

		if ((x_item_type is null) and (x_item_key is null)) then
		     po_approval_reminder_sv.cancel_notif ('BLANKET',
                                     x_po_release_id,'Y');
		else
		    po_approval_reminder_sv.stop_process(x_item_type,x_item_key);
		end if;
	 /*
	 ** Call the routine to remove the req link from the po
	 */
	 po_req_lines_sv.remove_req_from_po(X_po_release_id, 'RELEASE');


      EXCEPTION
	WHEN OTHERS THEN
	  dbms_output.put_line('In exception');
	  po_message_s.sql_error('delete_children', X_progress, sqlcode);
      END delete_children;


END PO_RELEASES_SV;

/
