--------------------------------------------------------
--  DDL for Package Body PO_REQ_LINES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_LINES_SV" as
/* $Header: POXRQL1B.pls 120.10.12010000.19 2014/07/23 06:04:33 rkandima ship $ */
/*==========================  po_req_lines_sv  ============================*/


  -- Constants :
  -- Read the profile option that enables/disables the debug log
  g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/*===========================================================================

  PROCEDURE NAME:	lock_row_for_status_update

===========================================================================*/

PROCEDURE lock_row_for_buyer_update (x_rowid  IN  VARCHAR2)
IS
    CURSOR C IS
        SELECT 	*
        FROM   	po_requisition_lines
        WHERE   rowid = x_rowid
        FOR UPDATE of requisition_line_id NOWAIT;
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
	PO_MESSAGE_S.SQL_ERROR('LOCK_ROW_FOR_BUYER_UPDATE', x_progress, sqlcode);
	RAISE;
END;


/*===========================================================================

  PROCEDURE NAME:	delete_line

===========================================================================*/

PROCEDURE delete_line(X_line_id  		IN  NUMBER,
		      X_mode	 		IN  VARCHAR2,
		      X_transferred_to_oe_flag	OUT NOCOPY VARCHAR2) IS

x_progress VARCHAR2(3) := NULL;
x_rowid    VARCHAR2(30);

BEGIN

   x_progress := '010';

   SELECT rowid
   INTO   x_rowid
   FROM   po_requisition_lines
   WHERE  requisition_line_id = x_line_id;

   -- dbms_output.put_line('After selecting rowid');

   /*
   ** DEBUG: We need to delete attachments.
   */

   /*
   ** Delete the children before deleting the line.
   */

   x_progress := '020';

   po_req_lines_sv.delete_children(X_line_id, X_mode);

   -- dbms_output.put_line('After call to delete children');

   /*
   ** Delete the requisition line.
   */

   x_progress := '030';

   po_requisition_lines_pkg1.delete_row(x_rowid, x_transferred_to_oe_flag);

   -- dbms_output.put_line('After call to delete line');

   EXCEPTION
   WHEN OTHERS THEN
      -- dbms_output.put_line('In exception');
      po_message_s.sql_error('delete_line', x_progress, sqlcode);
      raise;
END delete_line;

/*===========================================================================

  PROCEDURE NAME:	delete_children

===========================================================================*/

PROCEDURE delete_children(X_line_id   IN NUMBER,
			  X_mode      IN VARCHAR2) IS

x_progress VARCHAR2(3) := NULL;

BEGIN

   x_progress := '010';

   -- Added for bug 17701039
   fnd_attached_documents2_pkg.delete_attachments('REQ_LINES',
                                                  X_line_id,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  'Y');

   -- dbms_output.put_line('After call to delete attachments');

   x_progress := '020';

   DELETE FROM po_req_distributions
   WHERE  requisition_line_id = X_line_id;

   -- dbms_output.put_line('After call to delete distributions');

   EXCEPTION
   WHEN OTHERS THEN
      -- dbms_output.put_line('In exception');
      po_message_s.sql_error('delete_children', x_progress, sqlcode);
      raise;
END delete_children;



/*===========================================================================

  FUNCTION NAME:	val_reqs_po_shipment

===========================================================================*/

 FUNCTION val_reqs_po_shipment
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER) RETURN BOOLEAN IS

   X_progress                 VARCHAR2(3) := NULL;
   X_row_exists               NUMBER := 0;

 BEGIN

  --  dbms_output.put_line('Enter val_reqs_po_shipment');

   IF X_req_header_id is NOT NULL OR
      X_req_line_id is NOT NULL THEN

      /* Search for line exists.
      ** The following SQL statement is optimized to search for either
      ** 1. all document lines - if header_id is passed or,
      ** 2. one document line  - if both header_id and line_id are passed.
      */

      X_progress := '010';
      SELECT COUNT(1)
      INTO   X_row_exists
      FROM   PO_REQUISITION_LINES PORL,
             PO_LINE_LOCATIONS_ALL POLL   -- Bug 8659519
      WHERE  PORL.requisition_header_id = X_req_header_id
      AND    PORL.requisition_line_id = nvl(X_req_line_id, PORL.requisition_line_id)
      AND    PORL.line_location_id = POLL.line_location_id
      AND    PORL.line_location_id is NOT NULL
      AND    (nvl(POLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
              AND nvl(POLL.cancel_flag, 'N') = 'N');
   ELSE
      /* DEBUG - show error message */
      X_progress := '015';
      po_message_s.sql_error('val_reqs_po_shipment', X_progress, sqlcode);
   END IF;

   IF X_row_exists > 0 THEN
      RETURN (FALSE);
   ELSE
      RETURN (TRUE);
   END IF;

   -- dbms_output.put_line('Exit val_reqs_po_shipment');

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_reqs_po_shipment', X_progress, sqlcode);
   RAISE;

 END val_reqs_po_shipment;



/*===========================================================================

  FUNCTION NAME:	val_reqs_oe_shipment

===========================================================================*/

 FUNCTION val_reqs_oe_shipment
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER) RETURN BOOLEAN IS

   X_progress                 VARCHAR2(3) := NULL;
   X_row_exists               NUMBER := 0;
   p_req_line_id	      NUMBER;

   Cursor get_req_lines_cur is
   	Select requisition_line_id
        From po_requisition_lines
        Where requisition_line_id = nvl(X_req_line_id, requisition_line_id)
        And requisition_header_id = X_req_header_id
        and nvl(cancel_flag,'N')<>'Y' --Added for bug 13036681
        And source_type_code = 'INVENTORY';

 BEGIN

   -- dbms_output.put_line('Enter val_reqs_oe_shipment');

   IF X_req_header_id is NOT NULL OR
      X_req_line_id is NOT NULL THEN

      /* Search for line exists.
      ** The following SQL statement is optimized to search for either
      ** 1. all document lines - if header_id is passed or,
      ** 2. one document line  - if both header_id and line_id are passed.
      */

      X_progress := '010';

--Bug# 1392077
--Toju George 08/31/2000
--Modified the call to procedure to replace req_num and line_num with ids.
/*      SELECT COUNT(1)
      INTO   X_row_exists
      FROM   PO_REQUISITION_HEADERS PORH, PO_REQUISITION_LINES PORL,
             PO_SYSTEM_PARAMETERS POSP
       WHERE  PORH.requisition_header_id = X_req_header_id
       AND    PORL.requisition_line_id = nvl(X_req_line_id, PORL.requisition_line_id)
       AND    PORH.requisition_header_id = PORL.requisition_header_id
       AND    PORL.source_type_code = 'INVENTORY'
       AND    OE_ORDER_IMPORT_INTEROP_PUB .Get_Open_Qty(POSP.order_source_id,
                                                       PORH.segment1,
                                                       PORL.line_num ) > 0 ;
*/
      SELECT COUNT(1)
      INTO   X_row_exists
      FROM   PO_REQUISITION_HEADERS PORH, PO_REQUISITION_LINES PORL,
             PO_SYSTEM_PARAMETERS POSP
       WHERE  PORH.requisition_header_id = X_req_header_id
       AND    PORL.requisition_line_id = nvl(X_req_line_id, PORL.requisition_line_id)
       AND    PORH.requisition_header_id = PORL.requisition_header_id
       AND    PORL.source_type_code = 'INVENTORY'
       AND    OE_ORDER_IMPORT_INTEROP_PUB .Get_Open_Qty(POSP.order_source_id,
                                                       PORH.requisition_header_id,
                                                       PORL.requisition_line_id ) > 0 ;
   ELSE
      /* DEBUG - show error message */
      X_progress := '015';
      po_message_s.sql_error('val_reqs_oe_shipment', X_progress, sqlcode);
   END IF;

   IF X_row_exists > 0 THEN
      RETURN (FALSE);
   ELSE
      /* Bug#2492314: kagarwal
      ** Now call to check whether the SO shipments are still in process.
      */

      OPEN get_req_lines_cur;
      LOOP
        Fetch get_req_lines_cur Into p_req_line_id;
        Exit When get_req_lines_cur%NotFound;

      	If NOT (val_oe_shipment_in_proc(X_req_header_id, p_req_line_id)) Then
           RETURN(FALSE);
        End If;

      END LOOP;

      RETURN (TRUE);
   END IF;

   -- dbms_output.put_line('Exit val_reqs_oe_shipment');

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_reqs_oe_shipment', X_progress, sqlcode);
   RAISE;

 END val_reqs_oe_shipment;


/*===========================================================================

  FUNCTION NAME:	val_reqs_qty_delivered

===========================================================================*/

 FUNCTION val_reqs_qty_delivered
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER) RETURN BOOLEAN IS

   X_progress                 VARCHAR2(3) := NULL;
   X_row_exists               NUMBER := 0;

 BEGIN

   -- dbms_output.put_line('Enter val_reqs_qty_delivered');

   IF X_req_header_id is NOT NULL OR
      X_req_line_id is NOT NULL THEN

      /* Search for line exists.
      ** The following SQL statement is optimized to search for either
      ** 1. all document lines - if header_id is passed or,
      ** 2. one document line  - if both header_id and line_id are passed.
      */
      /* Bug# 5414478, We were using RCV_SHIPMENT_LINES quantity_received
         to compare with quantity_deliverd in po_requisition_lines.
         But in certain cases the Req. line and rcv_shipment_line are
         in different UOM and were not doing the quantity conversion while
         comparing quantity. Since we store the quantity_received in
         po_requisition_lines and it is in the same UOM as quantity_received
         we are going on quantity_received of po_requisition_lines
         to do the comparision. */
      X_progress := '010';
      SELECT COUNT(1)
      INTO   X_row_exists
      FROM   PO_REQUISITION_LINES PORL
      WHERE  PORL.requisition_header_id = X_req_header_id
      AND    PORL.requisition_line_id = nvl(X_req_line_id, PORL.requisition_line_id)
      AND    PORL.source_type_code = 'INVENTORY'
      AND    nvl(PORL.cancel_flag, 'N') = 'N'
      AND    nvl(PORL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
      AND    PORL.quantity_delivered < nvl(PORL.quantity_received,0);

      /* Start Bug# 5414478, Commented the code below
                      (select nvl(sum(quantity_received),0)
                 from RCV_SHIPMENT_LINES RSL
                 where RSL.requisition_line_id = PORL.requisition_line_id);
      End Bug# 5414478*/
   ELSE
      /* DEBUG - show error message */
      X_progress := '015';
      po_message_s.sql_error('val_reqs_qty_delivered', X_progress, sqlcode);
   END IF;

   IF X_row_exists > 0 THEN
      RETURN (FALSE);
   ELSE
      RETURN (TRUE);
   END IF;

   -- dbms_output.put_line('Exit val_reqs_qty_delivered');

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_reqs_qty_delivered', X_progress, sqlcode);
   RAISE;

 END val_reqs_qty_delivered;


/*===========================================================================

  PROCEDURE NAME:	update_reqs_lines_incomplete

===========================================================================*/

 PROCEDURE update_reqs_lines_incomplete
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER,
                   X_req_control_error_rc    IN OUT NOCOPY VARCHAR2,
                   X_oe_installed_flag       IN     VARCHAR2) IS

   X_progress                 VARCHAR2(3) := NULL;
   X_quantity_cancelled       PO_REQUISITION_LINES.quantity_cancelled%TYPE := NULL;
   X_order_source_id          po_system_parameters.order_source_id%TYPE;

 BEGIN

   -- dbms_output.put_line('Enter update_reqs_lines_incomplete');

   X_req_control_error_rc := '';

   IF X_req_header_id is NOT NULL OR
      X_req_line_id is NOT NULL THEN

       X_progress := '010';

       IF (X_oe_installed_flag = 'Y') THEN

	X_progress := '020';

       /* Bug#2275686: kagarwal
       ** Desc: When OM is installed, we need to get the cancelled qty and
       ** update it on the Req line before calling the code to reverse
       ** encumbrance.
       */

	BEGIN
       		select order_source_id
       		into   X_order_source_id
       		from po_system_parameters;

		X_quantity_cancelled := OE_ORDER_IMPORT_INTEROP_PUB.Get_Cancelled_Qty(
                                                           X_order_source_id,
                                                           to_char(X_req_header_id),
                                                           to_char(X_req_line_id));
	EXCEPTION
            	WHEN NO_DATA_FOUND THEN
                   X_quantity_cancelled := NULL;
	END;

       ELSE
           X_quantity_cancelled := NULL;
       END IF;

      /* The following SQL statement is optimized to update either
      ** 1. all document lines - if header_id is passed or,
      ** 2. one document line  - if both header_id and line_id are passed.
      */
      X_progress := '010';
      UPDATE PO_REQUISITION_LINES
      SET    cancel_flag = 'I',
             quantity_cancelled = NVL(X_quantity_cancelled, quantity_cancelled),
             reqs_in_pool_flag = NULL,          -- <REQINPOOL>
             last_update_login = fnd_global.login_id,
             last_updated_by = fnd_global.user_id,
             last_update_date = sysdate
      WHERE  requisition_header_id = X_req_header_id
      AND    requisition_line_id = nvl(X_req_line_id, requisition_line_id)
      AND    nvl(cancel_flag, 'N') IN ('N', 'I')
      AND    nvl(closed_code, 'OPEN') <> 'FINALLY CLOSED';

   ELSE
      /* DEBUG - show error message */
      X_req_control_error_rc := 'Y';
      X_progress := '015';
      po_message_s.sql_error('update_reqs_lines_incomplete', X_progress, sqlcode);
   END IF;

   -- dbms_output.put_line('Exit update_reqs_lines_incomplete');

   EXCEPTION

   WHEN OTHERS THEN
      X_req_control_error_rc := 'Y';
      po_message_s.sql_error('update_reqs_lines_incomplete', X_progress, sqlcode);
   RAISE;


 END update_reqs_lines_incomplete;


/*===========================================================================

  PROCEDURE NAME:	update_reqs_lines_status

===========================================================================*/

 PROCEDURE update_reqs_lines_status
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER,
                   X_req_control_action      IN     VARCHAR2,
                   X_req_control_reason      IN     VARCHAR2,
		   X_req_action_date         IN     DATE,
                   X_oe_installed_flag       IN     VARCHAR2,
                   X_req_control_error_rc    IN OUT NOCOPY VARCHAR2) IS

   X_progress                 VARCHAR2(3) := NULL;
   X_cancel_flag              PO_REQUISITION_LINES.cancel_flag%TYPE := NULL;
   X_cancel_date              PO_REQUISITION_LINES.cancel_date%TYPE := NULL;
   X_cancel_reason            PO_REQUISITION_LINES.cancel_reason%TYPE := NULL;
   X_closed_code              PO_REQUISITION_LINES.closed_code%TYPE := NULL;
   X_closed_reason            PO_REQUISITION_LINES.closed_reason%TYPE := NULL;
   X_closed_date              PO_REQUISITION_LINES.closed_date%TYPE := NULL;
   X_quantity_cancelled       PO_REQUISITION_LINES.quantity_cancelled%TYPE := NULL;
   X_terminal_performed       NUMBER(1) := 0;     -- <REQINPOOL>
   X_order_source_id          PO_SYSTEM_PARAMETERS.order_source_id%TYPE;
   x_last_update_login  po_requisition_lines.last_update_login%TYPE := fnd_global.login_id;
   x_last_updated_by    po_requisition_lines.last_updated_by%TYPE   := fnd_global.user_id;
   x_last_update_date   po_requisition_lines.last_update_date%TYPE  := SYSDATE;

   TYPE requisition_line_id_tb  IS TABLE OF po_requisition_lines.requisition_line_id%TYPE            INDEX BY PLS_INTEGER;
   TYPE cancel_flag_tb          IS TABLE OF po_requisition_lines.cancel_flag%TYPE                INDEX BY PLS_INTEGER;
   TYPE cancel_date_tb          IS TABLE OF po_requisition_lines.cancel_date%TYPE                 INDEX BY PLS_INTEGER;
   TYPE cancel_reason_tb        IS TABLE OF po_requisition_lines.cancel_reason%TYPE               INDEX BY PLS_INTEGER;
   TYPE closed_code_tb          IS TABLE OF po_requisition_lines.closed_code%TYPE                 INDEX BY PLS_INTEGER;
   TYPE closed_reason_tb        IS TABLE OF po_requisition_lines.closed_reason%TYPE                 INDEX BY PLS_INTEGER;
   TYPE closed_date_tb          IS TABLE OF po_requisition_lines.closed_date%TYPE                 INDEX BY PLS_INTEGER;
   TYPE contractor_status_tb    IS TABLE OF po_requisition_lines.contractor_status%TYPE           INDEX BY PLS_INTEGER;
   TYPE last_update_login_tb    IS TABLE OF po_requisition_lines.last_update_login%TYPE           INDEX BY PLS_INTEGER;
   TYPE last_updated_by_tb      IS TABLE OF po_requisition_lines.last_updated_by%TYPE             INDEX BY PLS_INTEGER;
   TYPE last_update_date_tb     IS TABLE OF po_requisition_lines.last_update_date%TYPE           INDEX BY PLS_INTEGER;
   TYPE quantity_cancelled_tb   IS TABLE OF po_requisition_lines.quantity_cancelled%TYPE          INDEX BY PLS_INTEGER;

   requisition_line_id_v        requisition_line_id_tb;
   cancel_flag_v                cancel_flag_tb;
   cancel_date_v                cancel_date_tb;
   cancel_reason_v              cancel_reason_tb;
   closed_code_v                closed_code_tb;
   closed_reason_v              closed_reason_tb;
   closed_date_v                closed_date_tb;
   contractor_status_v          contractor_status_tb;
   last_update_login_v          last_update_login_tb;
   last_updated_by_v            last_updated_by_tb;
   last_update_date_v           last_update_date_tb;
   quantity_cancelled_v         quantity_cancelled_tb;

-- bug 16240233 :: modifying cursor select statement to consider transferred_to_oe_flag while getting
-- cancelled quantity for internal requisitions.

   CURSOR cancel_cursor IS SELECT
          nvl(X_req_line_id, requisition_line_id),
          nvl(X_cancel_flag, cancel_flag),
          nvl(X_cancel_date, cancel_date),
          nvl(X_cancel_reason, cancel_reason),
          Nvl(X_closed_code, closed_code),
          nvl(X_closed_reason, closed_reason),
          nvl(X_closed_date, closed_date),
          decode(X_cancel_flag,'Y',null,contractor_status), -- Bug 3495679
          x_last_update_login,
          x_last_updated_by,
          x_last_update_date,
          decode(X_cancel_flag, 'Y', Decode(SOURCE_TYPE_CODE,'INVENTORY',
                                                           Decode(TRANSFERRED_TO_OE_FLAG,'Y',
                                                           OE_ORDER_IMPORT_INTEROP_PUB.Get_Cancelled_Qty(
                                                           X_order_source_id,
                                                           to_char(X_req_header_id),
                                                           Nvl(to_char(X_req_line_id), requisition_line_id)),quantity),
                                                           quantity - nvl(quantity_delivered, 0)), quantity_cancelled) -- Bug 17279437 added nvl() before quantity_delivered


           FROM po_requisition_lines
           WHERE  requisition_header_id = X_req_header_id
            AND    requisition_line_id   = nvl(X_req_line_id, requisition_line_id)
            AND    nvl(cancel_flag, 'N') IN ('N', 'I')
            AND    nvl(closed_code, 'OPEN') <> 'FINALLY CLOSED';

 BEGIN

   -- dbms_output.put_line('Enter update_reqs_lines_status');

   IF SubStr(X_req_control_action,1,6) = 'CANCEL' THEN
      X_cancel_flag   := 'Y';
      X_cancel_reason := X_req_control_reason;

      /* <Modified Action Date TZ FPJ 10-10-2003>
      *  change: should set cancel date to current time
      *  previous: set cancel date to action_date field
      *  That field was intended for GL/encumbrance only.
      */

      X_cancel_date := SYSDATE;

      -- <End Action Date TZ FPJ>

      X_terminal_performed := 1;     -- <REQINPOOL>

   ELSIF X_req_control_action = 'FINALLY CLOSE' THEN
         X_closed_code   := 'FINALLY CLOSED';
         X_closed_reason := X_req_control_reason;

         -- <Modified Action Date TZ FPJ 10-10-2003, similar to above>
         X_closed_date := SYSDATE;
         -- <End Action Date TZ FPJ>

         X_terminal_performed := 1;      -- <REQINPOOL>

   END IF;

   IF (X_oe_installed_flag = 'Y' AND
       SubStr(X_req_control_action,1,6) = 'CANCEL') THEN

       /* Bug#2275686: kagarwal
       ** Desc: When OM is installed, we need to get the cancelled qty and
       ** update it on the Req line.
       */

        BEGIN
                select order_source_id
                into   X_order_source_id
                from po_system_parameters;

 -- for bug 16240233 adding exception clause to handle cases of req lines not transferred to OE.

        EXCEPTION

        WHEN No_Data_Found THEN

               NULL;

        END;


   END IF;


   X_progress := '015';

   /* The following SQL statement is optimized to update either
   ** 1. all document lines - if only header_id is passed.
   ** 2. one document line  - if line_id is also passed.
   */
   /* Bug 4036549 - changed the below sql assignment from
      quantity_cancelled = nvl(X_quantity_cancelled, quantity_cancelled) to
      quantity_cancelled = nvl(X_quantity_cancelled, decode(X_cancel_flag,'Y',quantity,quantity_cancelled))
   */


   --Bug 6849650 - When cancelling from Header level, the cancelled quantity was not updated correctly for
   --internal requisition. In case of Cancel done from header leve, line_id will be null and hence cancelled
   --quantity was always taken as null as per previous logic. Changed the logic to get the cancelled quantity.
   --Also, used bulk collect to improve performance in case of large requisitions.

   OPEN cancel_cursor;

    LOOP
      FETCH cancel_cursor
        BULK COLLECT INTO
                requisition_line_id_v,
                        cancel_flag_v,
                cancel_date_v,
                cancel_reason_v,
                closed_code_v,
                closed_reason_v,
                                  closed_date_v,
                contractor_status_v,
                last_update_login_v,
                last_updated_by_v,
                last_update_date_v,
                quantity_cancelled_v
      LIMIT 2500;
      EXIT WHEN  cancel_flag_v.Count = 0;

     FORALL indx IN requisition_line_id_v.First .. requisition_line_id_v.LAST
        UPDATE po_requisition_lines SET
          cancel_flag   = cancel_flag_v(indx),
          cancel_date   = cancel_date_v(indx),
          cancel_reason = cancel_reason_v(indx),
          closed_code   = closed_code_v(indx),
          closed_reason = closed_reason_v(indx),
          closed_date   = closed_date_v(indx),
          contractor_status     = contractor_status_v(indx),
          reqs_in_pool_flag  = DECODE(X_terminal_performed,
                                      1,NULL,
                                      reqs_in_pool_flag), -- <REQINPOOL>
          last_update_login     = last_update_login_v(indx),
          last_updated_by       = last_updated_by_v(indx),
          last_update_date      = last_update_date_v(indx),
          quantity_cancelled    = quantity_cancelled_v(indx)
     WHERE requisition_line_id  = requisition_line_id_v(indx);
   END LOOP;

   -- dbms_output.put_line('Exit update_reqs_lines_status');
  /* Start Bug 4036549 - updating the req_line_quantity to 0  for 'Purchase Req'*/
   UPDATE PO_REQ_DISTRIBUTIONS
   SET    req_line_quantity = 0
   WHERE  requisition_line_id IN
             (SELECT requisition_line_id
              FROM   po_requisition_lines PORL
              WHERE  PORL.requisition_header_id = X_req_header_id
        AND    nvl(PORL.cancel_flag,'N') = 'Y'
      --  AND    PORL.source_type_code = 'VENDOR' /* commenting this condition for bug 16240233 to update dist quantity for internal reqs also */
        AND    PORL.requisition_line_id = nvl(X_req_line_id, PORL.requisition_line_id));
  /* End Bug 4036549 */

   EXCEPTION

   WHEN OTHERS THEN
       X_req_control_error_rc := 'Y';
      po_message_s.sql_error('update_reqs_lines_status', X_progress, sqlcode);
   RAISE;

 END update_reqs_lines_status;


/*===========================================================================

  PROCEDURE NAME:	remove_req_from_po

===========================================================================*/

PROCEDURE remove_req_from_po(X_entity_id  IN NUMBER,
			     X_entity     IN VARCHAR2) IS

x_progress VARCHAR2(3) := NULL;

--<DropShip FPJ Start>
l_po_header_id  PO_TBL_NUMBER;
l_po_release_id PO_TBL_NUMBER;
l_po_line_id    PO_TBL_NUMBER;
l_line_location_id PO_TBL_NUMBER;
L_req_header_id PO_TBL_NUMBER;
l_req_line_id   PO_TBL_NUMBER;
l_return_status VARCHAR2(30);
l_msg_data VARCHAR2(3000);
l_msg_count NUMBER;
l_api_name    CONSTANT VARCHAR(60) := 'po.plsql.PO_REQ_LINES_SV.REMOVE_REQ_FROM_PO';


--<DropShip FPJ End>

BEGIN

    IF g_fnd_debug = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_api_name||'.'
          || x_progress, 'Entered Procedure. Entity ' || X_entity || ' ID:' || X_entity_id);
        END IF;
    END IF;

   IF (X_entity = 'PURCHASE ORDER') THEN
     x_progress := '010';
     -- dbms_output.put_line('In update for Purchase Order related req lines');

     --<DropShip FPJ Start>
     --SQL What: Finds DropShip Req Lines for this Purchase Order Header ID
     SELECT  s.po_header_id, s.po_release_id, s.po_line_id, s.line_location_id,
       rl.requisition_header_id, rl.requisition_line_id
     BULK COLLECT INTO l_po_header_id, l_po_release_id, l_po_line_id, l_line_location_id,
       L_req_header_id, l_req_line_id
     FROM    po_line_locations s, po_requisition_lines rl
     WHERE   s.line_location_id = rl.line_location_id and nvl(rl.drop_ship_flag, 'N') = 'Y'
     AND s.po_header_id = X_entity_id;
     --<DropShip FPJ End>

     UPDATE po_requisition_lines_all rl  -- Bug 3592153
     	SET line_location_id = NULL,
     	    -- Bug 2781027 resetting the reqs in pool flag
     	    --Bug 9976204.Set the reqs_in_pool_flag back to Y only if the Req is APPROVED or PRE-APPROVED
     	    rl.reqs_in_pool_flag = (select Decode(rh.authorization_status,'APPROVED','Y','PRE-APPROVED','Y',rl.reqs_in_pool_flag)
                                    from po_requisition_headers_all rh
                                    where rh.requisition_header_id = rl.requisition_header_id),
     	   rl.last_update_login = fnd_global.login_id,  -- Bug5623016 (updating who column)
     	   rl.last_updated_by = fnd_global.user_id,  -- Bug5623016 (updating who column)
     	   rl.last_update_date = sysdate  -- Bug5623016 (updating who column)
     	WHERE  rl.line_location_id in (SELECT  pll.line_location_id
     				 FROM    po_line_locations_all  pll --Bug 8777237: Looking into the base table instead of po_line_locations
				 WHERE   pll.po_header_id = X_entity_id);

   ELSIF (X_entity = 'RELEASE') THEN
     x_progress := '020';
     -- dbms_output.put_line('In update for Release related req lines');

     --<DropShip FPJ Start>
     --SQL What: Finds Drop Ship Req Lines for this Release ID
     SELECT  s.po_header_id, s.po_release_id, s.po_line_id, s.line_location_id,
       rl.requisition_header_id, rl.requisition_line_id
     BULK COLLECT INTO l_po_header_id, l_po_release_id, l_po_line_id, l_line_location_id,
       L_req_header_id, l_req_line_id
     FROM    po_line_locations s, po_requisition_lines rl
     WHERE   s.line_location_id = rl.line_location_id and nvl(rl.drop_ship_flag, 'N') = 'Y'
       AND s.po_release_id = X_entity_id;
     --<DropShip FPJ End>

     UPDATE po_requisition_lines_all rl   -- Bug 3592153
          SET    rl.line_location_id = NULL,
                  -- Bug 2781027
                  --Bug 9976204.Set the reqs_in_pool_flag back to Y only if the Req is APPROVED or PRE-APPROVED
                 rl.reqs_in_pool_flag = (select Decode(rh.authorization_status,'APPROVED','Y','PRE-APPROVED','Y',rl.reqs_in_pool_flag)
                                    from po_requisition_headers_all rh
                                    where rh.requisition_header_id = rl.requisition_header_id),
                 rl.last_update_login = fnd_global.login_id,  -- Bug5623016 (updating who column)
                 rl.last_updated_by = fnd_global.user_id,  -- Bug5623016 (updating who column)
                 rl.last_update_date = sysdate  -- Bug5623016 (updating who column)
          WHERE  rl.line_location_id in (SELECT  pll.line_location_id
        				 FROM    po_line_locations_all  pll --Bug 8777237: Looking into the base table instead of po_line_locations
       				 WHERE   pll.po_release_id = X_entity_id);


   ELSIF (X_entity = 'LINE') THEN
     x_progress := '030';
    -- dbms_output.put_line('In update for Line related req lines');

     --<DropShip FPJ Start>
     --SQL What: Finds Drop Ship Req Lines for this Line ID
     SELECT  s.po_header_id, s.po_release_id, s.po_line_id, s.line_location_id,
       rl.requisition_header_id, rl.requisition_line_id
     BULK COLLECT INTO l_po_header_id, l_po_release_id, l_po_line_id, l_line_location_id,
       L_req_header_id, l_req_line_id
     FROM    po_line_locations s, po_requisition_lines rl
     WHERE   s.line_location_id = rl.line_location_id and nvl(rl.drop_ship_flag, 'N') = 'Y'
       AND s.po_line_id = X_entity_id;
     --<DropShip FPJ End>

     UPDATE po_requisition_lines_all rl  -- Bug 3592153
          SET    rl.line_location_id = NULL,
                 -- Bug 2781027
                 --Bug 9976204.Set the reqs_in_pool_flag back to Y only if the Req is APPROVED or PRE-APPROVED
                 rl.reqs_in_pool_flag = (select Decode(rh.authorization_status,'APPROVED','Y','PRE-APPROVED','Y',rl.reqs_in_pool_flag)
                                    from po_requisition_headers_all rh
                                    where rh.requisition_header_id = rl.requisition_header_id
                                      -- Bug 15837636
                                      and rl.line_location_id in (SELECT pll.line_location_id FROM po_line_locations_all pll WHERE
                                                                  pll.po_line_id = X_entity_id)
                                      -- Bug 15837636
                                   ),
                 rl.last_update_login = fnd_global.login_id,  -- Bug5623016 (updating who column)
                 rl.last_updated_by = fnd_global.user_id,  -- Bug5623016 (updating who column)
                 rl.last_update_date = sysdate  -- Bug5623016 (updating who column)
          WHERE  rl.line_location_id in (SELECT  pll.line_location_id
                                      FROM    po_line_locations_all  pll --Bug 8777237: Looking into the base table instead of po_line_locations
                                      WHERE   pll.po_line_id = X_entity_id);


   ELSIF (X_entity = 'SHIPMENT') THEN
     x_progress := '040';
     -- dbms_output.put_line('In update for Shipment related req lines');

     --<DropShip FPJ Start>
     --SQL What: Finds Drop Ship Req Lines for this Line Location ID
     SELECT  s.po_header_id, s.po_release_id, s.po_line_id, s.line_location_id,
       rl.requisition_header_id, rl.requisition_line_id
     BULK COLLECT INTO l_po_header_id, l_po_release_id, l_po_line_id, l_line_location_id,
       L_req_header_id, l_req_line_id
     FROM    po_line_locations s, po_requisition_lines rl
     WHERE   s.line_location_id = rl.line_location_id and nvl(rl.drop_ship_flag, 'N') = 'Y'
       AND s.line_location_id = X_entity_id;
     --<DropShip FPJ End>

     UPDATE po_requisition_lines_all rl -- Bug 3592153
     SET  line_location_id = NULL,
     -- Bug 2781027
     --Bug 9976204.Set the reqs_in_pool_flag back to Y only if the Req is APPROVED or PRE-APPROVED
     	  rl.reqs_in_pool_flag = (select Decode(rh.authorization_status,'APPROVED','Y','PRE-APPROVED','Y',rl.reqs_in_pool_flag)
     	                         from po_requisition_headers_all rh
                                      where rh.requisition_header_id = rl.requisition_header_id),
          rl.last_update_login = fnd_global.login_id,  -- Bug5623016 (updating who column)
          rl.last_updated_by = fnd_global.user_id,  -- Bug5623016 (updating who column)
          rl.last_update_date = sysdate  -- Bug5623016 (updating who column)
          WHERE  rl.line_location_id in (SELECT  pll.line_location_id
                                         FROM    po_line_locations_all  pll --Bug 8777237: Looking into the base table instead of po_line_locations
                                 WHERE   pll.line_location_id = X_entity_id);

   END IF;

   --<DropShip FPJ Start>
   -- Remove deleted PO References from Drop Ship Sources Table for all deleted Shipments
   FOR I IN 1..l_line_location_id.count LOOP

       OE_DROP_SHIP_GRP.Update_Drop_Ship_links(
         p_api_version => 1.0,
         p_po_header_id => l_po_header_id(i),
         p_po_release_id => l_po_release_id(i),
         p_po_line_id => l_po_line_id(i),
         p_po_line_location_id => l_line_location_id(i),
         p_new_req_hdr_id => l_req_header_id(i),
         p_new_req_line_id => l_req_line_id(i),
         x_return_status  => l_return_status,
         x_msg_data  => l_msg_data,
         x_msg_count  => l_msg_count);

    IF g_fnd_debug = 'Y' THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_api_name|| '.' || x_progress,
        'After Call to OE_DROP_SHIP_GRP.Update_Drop_Ship_links RetStatus: ' || l_return_status
        || 'POHeader:' || l_po_header_id(i) || ' Release:' || l_po_release_id(i)
        || ' Line:' || l_po_line_id(i) || ' LineLoc:' || l_line_location_id(i)
        || ' ReqHdr:' || l_req_header_id(i) || ' ReqLine:' || l_req_line_id(i));
        END IF;
    END IF;

    IF (l_return_status IS NULL) THEN
        l_return_status := FND_API.g_ret_sts_success;
    END IF;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           po_message_s.sql_error('remove_req_from_po', x_progress, l_msg_data);
       END IF;

   END LOOP;
     --<DropShip FPJ End>

   EXCEPTION
   WHEN OTHERS THEN
    --  dbms_output.put_line('In exception');
      po_message_s.sql_error('remove_req_from_po', x_progress, sqlcode);

END remove_req_from_po;


/*===========================================================================

  PROCEDURE NAME:	val_dest_details()

===========================================================================*/
PROCEDURE val_dest_details (x_dest_org_id	IN OUT NOCOPY NUMBER,
			    x_item_id		IN NUMBER,
			    x_item_rev		IN VARCHAR,
			    x_location_id	IN OUT NOCOPY NUMBER,
			    x_dest_sub		IN OUT NOCOPY VARCHAR2,
			    x_dest_type		IN VARCHAR2,
			    x_val_code		IN VARCHAR2,
			    x_sob_id		IN NUMBER) IS

x_progress VARCHAR2(3) := NULL;
x_error_type	VARCHAR2(50);

BEGIN

   x_progress := '010';

   /*
   ** Stop processing if the destination type
   ** is null.
   */

   IF (x_dest_type is null) THEN
    x_dest_org_id := null;
    x_location_id := null;
    x_dest_sub    := null;

    return;

   END IF;


   /*
   ** Determine which set of fields are to
   ** be validated, call the corresponding
   ** validation functions.
   */

   IF (x_dest_org_id is null) THEN
     x_location_id := null;
     x_dest_sub    := null;

     return;

   END IF;

   IF (x_val_code = 'ORG') THEN

     x_progress := '020';

     IF (po_orgs_sv2.val_dest_org (x_dest_org_id,
				  x_item_id,
				  x_item_rev,
				  x_dest_type,
				  x_sob_id,
				  '') = FALSE) THEN

       x_dest_org_id := null;
       x_location_id := null;
       x_dest_sub    := null;

       return;

    END IF;
  END IF;

   IF ((x_val_code = 'ORG') OR
       (x_val_code = 'LOC')) THEN

     IF (x_location_id is not null) THEN

	x_progress := '030';

       IF (po_locations_sv2.val_location (x_location_id,
				     	  x_dest_org_id,
				          'N',
					  'N',
					  'N') = FALSE) THEN

         x_location_id := null;

       END IF;
    END IF;
   END IF;

  /*
  ** We would like to continue with the
  ** validation even if the deliver-to location
  ** is null since the subinventory is not
  ** dependent on the deliver-to location.
  */

  IF ((x_val_code = 'ORG') OR
      (x_val_code = 'LOC') OR
      (x_val_code = 'SUB')) THEN

    IF (x_dest_sub is not null) THEN

      x_progress := '040';

      IF (po_subinventories_s2.val_subinventory (x_dest_sub,
						x_dest_org_id,
						null,
						null,
						null,
						trunc(sysdate),
						x_item_id,
						x_dest_type,
						'DESTINATION',
						x_error_type) = FALSE) THEN
        x_dest_sub := null;

      END IF;
   END IF;
  END IF;


   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_dest_details', x_progress, sqlcode);
   RAISE;

END val_dest_details;

/*===========================================================================

 PROCEDURE NAME :  val_src_type()

===========================================================================*/

FUNCTION val_src_type(   x_src_type		IN VARCHAR2,
			 x_item_id		IN NUMBER,
			 x_internal_orderable	IN VARCHAR2,
			 x_stock_enabled_flag   IN VARCHAR2,
			 x_purchasable		IN VARCHAR2,
			 x_customer_id		IN NUMBER,
			 x_outside_op_line_type IN VARCHAR2,
                         x_dest_loc_id          IN NUMBER)
RETURN BOOLEAN IS

x_progress 	varchar2(3) := '';


BEGIN


  IF (x_src_type is null) THEN
    return (FALSE);

  END IF;

 /*
 ** Debug: Have this code
 ** reviewed by either Liza or
 ** Kevin.
 */

  IF (x_src_type = 'INVENTORY') THEN
    IF ((x_customer_id is null and x_dest_loc_id is not null) OR
	(x_item_id is null) OR
	(x_internal_orderable = 'N') OR
	(x_stock_enabled_flag  = 'N') OR
	(x_outside_op_line_type = 'Y')) THEN

      -- Bug 5028505 , Added the Error message when deliver_to_location
      -- does not have customer location association setup in src org OU

       IF (x_customer_id is null and x_dest_loc_id is not null) then
         fnd_message.set_name ('PO','PO_REQ_SRC_REQUIRES_CUST');
       END IF;

      return (FALSE);

    ELSE

      return (TRUE);

    END IF;

  ELSIF (x_src_type = 'VENDOR') THEN
       IF (x_purchasable = 'N') THEN

	return (FALSE);

       ELSE

        return (TRUE);

       END IF;
  END IF;

exception
   when others then
      po_message_s.sql_error('val_src_type',x_progress,sqlcode);
      raise;

end val_src_type;



/*===========================================================================

  PROCEDURE NAME:	update_transferred_to_oe_flag

===========================================================================*/

PROCEDURE update_transferred_to_oe_flag(X_req_hdr_id   		 IN  NUMBER,
		           	     X_transferred_to_oe_flag    OUT NOCOPY VARCHAR2)
IS

x_progress  VARCHAR2(3) := NULL;
x_inv_count NUMBER      := 0;
x_flag	    VARCHAR2(1) := NULL;

BEGIN


   /*
   ** Verify that there is at least one
   ** inventory sourced line.
   */

   x_progress := '010';

   SELECT count(*)
   INTO   x_inv_count
   FROM   po_requisition_lines  prl
   WHERE  prl.requisition_header_id = x_req_hdr_id
   AND    prl.source_type_code = 'INVENTORY';

   -- dbms_output.put_line ('x_inv_count: ' ||to_char(x_inv_count));

   x_progress := '020';

   /*
   ** Set the appropriate value for the
   ** transferred_to_oe_flag.
   */

   IF (x_inv_count = 0) THEN
     x_flag := NULL;

   ELSE

     /* Bug: 689677 - transferred_to_oe_flag need to be set to 'N',
     only if it is NULL. Need not update the flag, if it is already 'Y'or 'N' */

     SELECT transferred_to_oe_flag
     INTO   x_flag
     FROM   po_requisition_headers
     WHERE  requisition_header_id = x_req_hdr_id;

     IF (x_flag = 'Y' or x_flag = 'N') then
        x_transferred_to_oe_flag := x_flag;
        return;
     END IF;

      IF x_flag is NULL then
        x_flag := 'N';
     END IF;

   END IF;

   x_transferred_to_oe_flag := x_flag;

   /*
   ** Update the flag on requisition headers.
   */

   x_progress := '030';
  --  dbms_output.put_line ('Before updating requisition headers');

   po_reqs_sv.update_oe_flag (X_req_hdr_id, X_flag);

  --  dbms_output.put_line ('After updating requisition headers');



   EXCEPTION
   WHEN OTHERS THEN
     --  dbms_output.put_line('In exception');
      po_message_s.sql_error('update_transferred_to_oe_flag',
			      x_progress, sqlcode);
      raise;
END update_transferred_to_oe_flag;

-- <REQINPOOL BEGIN>


/*===========================================================================

  PROCEDURE NAME:       update_reqs_in_pool_flag

===========================================================================*/

PROCEDURE update_reqs_in_pool_flag
(   x_req_line_id                 IN          NUMBER            ,
    x_req_header_id               IN          NUMBER            ,
    x_return_status               OUT NOCOPY  VARCHAR2
)

IS
    x_progress                  VARCHAR2(3)     := NULL;

BEGIN

  x_progress := '010';

  IF ( x_req_line_id IS NOT NULL OR x_req_header_id IS NOT NULL ) THEN

    x_progress := '020';

    --SQL What: Update reqs_in_pool_flag for all lines on the passed-in
    --          requisition to be NULL where the line has been cancelled,
    --          finally closed, attached to a PO, modified since approval,
    --          sent to sourcing, or when the requisition is either
    --          internal or not approved.  If none of these conditions
    --          are met, set the flag to 'Y'.
    --
    --SQL Why:  Requisition lines where any of the above applies cannot
    --          be placed on a purchasing document; those that fail all
    --          the above criteria can.
    --
    --SQL Join: requisition_header_id from PO_REQUISITION_HEADERS_ALL
    UPDATE po_requisition_lines_all prl
    SET prl.reqs_in_pool_flag =
        CASE
          WHEN NVL(prl.cancel_flag,'N')             = 'Y'
            OR NVL(prl.closed_code,'OPEN')          = 'FINALLY CLOSED'
            OR NVL(prl.line_location_id,-999)       <> -999
            OR NVL(prl.modified_by_agent_flag,'N')  = 'Y'
            OR prl.at_sourcing_flag                 = 'Y'
            OR prl.source_type_code                 <> 'VENDOR'
            OR NVL((SELECT prh.authorization_status
                      FROM PO_REQUISITION_HEADERS_ALL prh
                     WHERE prh.requisition_header_id = prl.requisition_header_id)
                   , 'INCOMPLETE')                  <> 'APPROVED'
            OR NVL((SELECT prh.contractor_status
                      FROM PO_REQUISITION_HEADERS_ALL prh
                     WHERE prh.requisition_header_id = prl.requisition_header_id)
                   , 'NOT APPLICABLE')              = 'PENDING'
        THEN
          NULL
        ELSE
          'Y'
        END
      , prl.last_update_date   = SYSDATE
      , prl.last_updated_by    = FND_GLOBAL.USER_ID
      , prl.last_update_login  = FND_GLOBAL.LOGIN_ID
    WHERE
      PRL.Requisition_Line_ID in (
        SELECT  SUB.Requisition_Line_ID
        FROM    PO_REQUISITION_LINES_ALL SUB
        WHERE   SUB.Requisition_Header_Id = x_req_header_id
        AND     x_req_line_id IS NULL
       UNION ALL
        SELECT  SUB2.Requisition_Line_ID
        FROM    PO_REQUISITION_LINES_ALL SUB2
        WHERE   SUB2.Requisition_Line_Id = x_req_line_id
      );

  ELSE
    x_progress := '030';

  END IF; -- IF ( x_req_line_id IS NOT NULL OR x_req_header_id IS NOT NULL )

  x_progress := '040';
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    PO_MESSAGE_S.sql_error('UPDATE_REQS_IN_POOL_FLAG',x_progress,sqlcode);

END update_reqs_in_pool_flag;

-- <REQINPOOL END>

/*===========================================================================

  FUNCTION NAME:        val_oe_shipment_in_proc

===========================================================================*/

/* Bug# 2492314: kagarwal */

 FUNCTION val_oe_shipment_in_proc
                  (X_req_header_id           IN     NUMBER,
                   X_req_line_id             IN     NUMBER) RETURN BOOLEAN IS

   X_progress                 VARCHAR2(3) := NULL;
   X_order_source_id          po_system_parameters.order_source_id%TYPE;
   X_req_num                  po_requisition_headers_all.segment1%TYPE;
   X_oe_line_tbl              OE_ORDER_IMPORT_INTEROP_PUB.LineId_Tbl_Type;
   X_oe_return   	      VARCHAR2(30);
   X_oe_line_ctr              NUMBER := 0;

   X_in_rec_type    	      WSH_INTEGRATION.LineIntfInRecType;
   X_out_rec_type   	      WSH_INTEGRATION.LineIntfOutRecType;
   X_io_rec_type    	      WSH_INTEGRATION.LineIntfInOutRecType;
   X_wsh_return               VARCHAR2(200);
   X_msg_count                NUMBER;
   X_msg_data                 VARCHAR2(200);

 BEGIN

   IF X_req_header_id is NOT NULL AND
      X_req_line_id is NOT NULL THEN

      X_progress := '010';

      select order_source_id
      into   X_order_source_id
      from po_system_parameters;

      X_progress := '020';

      SELECT segment1
      INTO X_req_num
      FROM po_requisition_headers_all
      WHERE requisition_header_id = X_req_header_id;

      X_progress := '030';

      OE_ORDER_IMPORT_INTEROP_PUB.Get_Line_Id (
   		p_order_source_id        =>  X_order_source_id,
		p_orig_sys_document_ref  =>  X_req_num,
  		p_requisition_header_id  =>  X_req_header_id,
  		p_line_num               =>  NULL,
  		p_requisition_line_id    =>  X_req_line_id,
  		x_line_id_tbl            =>  X_oe_line_tbl,
  		x_return_status          =>  X_oe_return);

      X_progress := '040';

      If X_oe_return = fnd_api.g_ret_sts_success then

        /* If the table X_oe_line_tbl is empty, return TRUE */
        If (X_oe_line_tbl.FIRST is NULL) Then
           return(TRUE);
        End If;

        FOR X_oe_line_ctr IN 1..X_oe_line_tbl.COUNT
        LOOP
           X_in_rec_type.api_version_number := 1.0;
           X_in_rec_type.source_code := 'PO';
           X_in_rec_type.line_id := X_oe_line_tbl(X_oe_line_ctr).line_id;

           WSH_INTEGRATION.Get_Nonintf_Shpg_line_qty
      		( p_in_attributes   => X_in_rec_type,
            	p_out_attributes    => X_out_rec_type,
            	p_inout_attributes  => X_io_rec_type,
            	x_return_status     => X_wsh_return,
            	x_msg_count         => X_msg_count,
            	x_msg_data          => X_msg_data);

           If X_wsh_return = fnd_api.g_ret_sts_success then
             If X_out_rec_type.nonintf_line_qty > 0 then
               return FALSE;

             End If; /* If X_out_rec_type.nonintf_line_qty */

           Else
             /* DEBUG - show error message */
             X_progress := '080';
             po_message_s.sql_error('val_oe_shipment_in_proc', X_progress, sqlcode);
           End If; /* If X_wsh_return */

        END LOOP;

     Else
        /* DEBUG - show error message */
        X_progress := '090';
        po_message_s.sql_error('val_oe_shipment_in_proc', X_progress, sqlcode);

     End If; /* If X_oe_return */

     /* Nothing stuck in mti */
     X_progress := '100';
     return TRUE;

   ELSE
      /* DEBUG - show error message */
      X_progress := '999';
      po_message_s.sql_error('val_oe_shipment_in_proc', X_progress, sqlcode);
   End IF; /* IF X_req_header_id */

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_oe_shipment_in_proc', X_progress, sqlcode);
   RAISE;

 END val_oe_shipment_in_proc;

/* Bug# 2607180: kagarwal
** Desc: Verify if internal requisition lines which are sourced from inventory,
** have been received or not. For this we will check if the 'SHIPMENT' supply
** exists for the requisition lines.
**
** If 'SHIPMENT' supply exists return FALSE else TRUE
*/

/*===========================================================================

  FUNCTION NAME:        val_reqs_qty_received

===========================================================================*/

 FUNCTION val_reqs_qty_received
                       (X_req_header_id       IN     NUMBER,
                        X_req_line_id         IN     NUMBER) RETURN BOOLEAN IS

   X_progress                 VARCHAR2(3) := NULL;
   X_row_exists               NUMBER := 0;

 BEGIN
   IF X_req_header_id is NOT NULL OR
      X_req_line_id is NOT NULL THEN

      X_progress := '010';

      SELECT COUNT(1)
      INTO   X_row_exists
      FROM   MTL_SUPPLY
      WHERE  req_header_id = X_req_header_id
      AND    req_line_id   = NVL(X_req_line_id, req_line_id)
      AND    supply_type_code = 'SHIPMENT'
      AND    quantity > 0;

   ELSE
      /* DEBUG - show error message */
      X_progress := '015';
      po_message_s.sql_error('val_reqs_qty_received', X_progress, sqlcode);
   END IF;

   IF X_row_exists > 0 THEN
      RETURN (FALSE);
   ELSE
      RETURN (TRUE);
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_reqs_qty_received', X_progress, sqlcode);
   RAISE;

 END val_reqs_qty_received;

END po_req_lines_sv;

/
