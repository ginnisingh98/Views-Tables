--------------------------------------------------------
--  DDL for Package Body PO_NOTIF_CONTROLS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NOTIF_CONTROLS_SV" AS
/* $Header: POXPONCB.pls 120.0.12010000.1 2008/09/18 12:21:00 appldev noship $*/
/*===========================================================================

  FUNCTION NAME:	delete_notifs()

===========================================================================*/

 FUNCTION delete_notifs(X_po_header_id IN number)
          return boolean is
          X_deleted boolean;

          X_progress VARCHAR2(3) := NULL;

 BEGIN
        DELETE FROM po_notification_controls
        WHERE po_header_id = X_po_header_id;

        X_deleted := TRUE;
        return(X_deleted);

  EXCEPTION
        when no_data_found then
             null;   /* It is not an error if there are no notification controls */

        when others then
             po_message_s.sql_error('delete_notifs', x_progress, sqlcode);
             raise ;

END delete_notifs;

/*===========================================================================

  PROCEDURE NAME:	val_notif_controls()

===========================================================================*/

FUNCTION val_notif_controls (X_po_header_id IN number)
                             RETURN BOOLEAN IS

   x_progress 		     VARCHAR2(3) := NULL;
   X_amt_base_notif_cntl_row NUMBER := 0;

BEGIN

   X_progress := '010';
   SELECT  COUNT(1)
     INTO  X_amt_base_notif_cntl_row
     FROM  po_notification_controls
    WHERE  po_header_id                 = X_po_header_id
      AND  notification_condition_code <> 'EXPIRATION';

   IF X_amt_base_notif_cntl_row > 0 THEN
      RETURN (TRUE);
   ELSE
      RETURN (FALSE);
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
      po_message_s.sql_error('val_notif_controls', x_progress, sqlcode);
   RAISE;

END val_notif_controls;

/*===========================================================================

  FUNCTION NAME:	val_date_notif()

===========================================================================*/

FUNCTION   val_date_notif(X_po_header_id IN number,
                          X_end_date IN date )
                return boolean is
                X_valid_date boolean;

     X_progress  varchar2(3) := '000';
     cursor c1 is
            SELECT 'date based notification controls exist'
            FROM  po_notification_controls
            WHERE po_header_id                = X_po_header_id
            AND   notification_condition_code = 'EXPIRATION';

     Recinfo c1%rowtype;

BEGIN

    X_progress := '010';

    open c1;

    X_progress := '020';
    fetch c1 into Recinfo;

    X_progress := '030';

    if (c1%notfound) then
        close c1;
        X_valid_date := TRUE;
        return(X_valid_date);
     end if;
     X_progress := '040';

     X_valid_date := FALSE;

     -- Bug 509797
     -- po_message_s.app_error('PO_PO_NFC_DATE_CONTROLS_EXIST');
     fnd_message.set_name('PO', 'PO_PO_NFC_DATE_CONTROLS_EXIST');
     return(X_valid_date);

 EXCEPTION
     when others then
          po_message_s.sql_error('val_date_notif', x_progress, sqlcode);
         raise;

END val_date_notif;



END PO_NOTIF_CONTROLS_SV;

/
