--------------------------------------------------------
--  DDL for Package Body PO_SHIPMENTS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHIPMENTS_SV2" as
/* $Header: POXPOS2B.pls 120.0.12010000.3 2013/03/11 06:45:35 rkandima ship $*/

-- Read the profile option that enables/disables the debug log
g_po_pdoi_write_to_file VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_PDOI_WRITE_TO_FILE'),'N');

/*===========================================================================

  FUNCTION NAME:	get_number_shipments

===========================================================================*/
   FUNCTION get_number_shipments
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type        IN     VARCHAR2) RETURN NUMBER IS

      X_progress          VARCHAR2(3) := '';
      X_number_shipments  NUMBER      := '';

      BEGIN

	 X_progress := '010';

	 SELECT count(PLL.line_location_id)
	 INTO   X_number_shipments
         FROM   po_line_locations PLL
         WHERE  PLL.po_line_id = X_po_line_id
	 AND    PLL.shipment_type = X_shipment_type;

	 IF (g_po_pdoi_write_to_file = 'Y') THEN
   	 po_debug.put_line ('Number Shipments  = '||X_number_shipments);
	 END IF;

         RETURN(X_number_shipments);

      EXCEPTION
	when others then
	  IF (g_po_pdoi_write_to_file = 'Y') THEN
   	  po_debug.put_line('In exception');
	  END IF;
	  po_message_s.sql_error('get_number_shipments', X_progress, sqlcode);
          raise;
      END get_number_shipments;

/*===========================================================================

  FUNCTION NAME:	val_release_shipments

===========================================================================*/
   FUNCTION val_release_shipments
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type        IN     VARCHAR2) RETURN BOOLEAN IS

      X_progress          VARCHAR2(3) := '';
      X_number_shipments  NUMBER      := '';

      BEGIN

	 X_progress := '010';

	 /*
         ** To get the number of shipments for a planned line,
	 ** pass in a type of SCHEDULED.
	 ** To get the number of shipments for a blanket line,
	 ** pass in a type of BLANKET.
         */
	 X_number_shipments := get_number_shipments(X_po_line_id,
					            X_shipment_type);

         If (X_number_shipments is null OR
             X_number_shipments = 0) THEN
	    IF (g_po_pdoi_write_to_file = 'Y') THEN
   	    po_debug.put_line ('Returned FALSE - No Shipments');
	    END IF;
	    return(FALSE);
	 ELSE
	    IF (g_po_pdoi_write_to_file = 'Y') THEN
   	    po_debug.put_line ('Returned TRUE - Shipments');
	    END IF;
	    return(TRUE);
         END IF;

      EXCEPTION
	when others then
	  IF (g_po_pdoi_write_to_file = 'Y') THEN
   	  po_debug.put_line('In exception');
	  END IF;
	  po_message_s.sql_error('val_release_shipments', X_progress, sqlcode);
          raise;
      END val_release_shipments;



/*===========================================================================

  PROCEDURE NAME:	get_shipment_status

===========================================================================*/
   PROCEDURE get_shipment_status
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type        IN     VARCHAR2,
                       X_line_location_id     IN     NUMBER,
		       X_approved_flag        IN OUT NOCOPY VARCHAR2,
		       X_encumbered_flag      IN OUT NOCOPY VARCHAR2,
		       X_closed_code          IN OUT NOCOPY VARCHAR2,
		       X_cancelled_flag       IN OUT NOCOPY VARCHAR2) IS

      X_progress          VARCHAR2(3)  := '';

      CURSOR C is
	 SELECT nvl(PLL.approved_flag,'N'),
	        nvl(PLL.encumbered_flag,'N'),
		nvl(PLL.closed_code,'OPEN'),
		nvl(PLL.cancel_flag,'N')
	 FROM   po_line_locations PLL
         WHERE  PLL.line_location_id = X_line_location_id
	 AND    PLL.shipment_type = X_shipment_type;

      BEGIN

	 IF (g_po_pdoi_write_to_file = 'Y') THEN
   	 po_debug.put_line('Before open cursor');
	 END IF;

	 if (X_line_location_id is not null) then
	    if (X_shipment_type is not null) then

	       X_progress := '010';
               OPEN C;
	       X_progress := '020';

               FETCH C into X_approved_flag,
			    X_encumbered_flag,
			    X_closed_code,
			    X_cancelled_flag;

               CLOSE C;

	       IF (g_po_pdoi_write_to_file = 'Y') THEN
   	       po_debug.put_line('Line Location Id : '|| X_line_location_id);
                  po_debug.put_line('Approved Flag = '||X_approved_flag);
   	       po_debug.put_line('Encumbered Flag = '||X_encumbered_flag);
   	       po_debug.put_line('Closed Code = '||X_closed_code);
   	       po_debug.put_line('Canclled_flag = '||X_cancelled_flag);
	       END IF;

	    else
	       X_progress := '025';
               po_message_s.sql_error('get_shipment_status', X_progress, sqlcode);

	    end if;

         else
	   X_progress := '030';
	   po_message_s.sql_error('get_shipment_status', X_progress, sqlcode);

	 end if;

      EXCEPTION
	when others then
	  IF (g_po_pdoi_write_to_file = 'Y') THEN
   	  po_debug.put_line('In exception');
	  END IF;
	  po_message_s.sql_error('get_shipment_status', X_progress, sqlcode);
          raise;
      END get_shipment_status;




/*===========================================================================

  FUNCTION NAME:	update_shipment_qty

===========================================================================*/
   FUNCTION update_shipment_qty
		      (X_line_location_id     IN     NUMBER,
		       X_shipment_type        IN     VARCHAR2,
		       X_line_quantity        IN     NUMBER) RETURN BOOLEAN IS

      X_progress          VARCHAR2(3)  := '';
      X_login_id          NUMBER       := '';
      X_last_updated_by   NUMBER       := '';

      BEGIN

         X_progress := '010';

	 IF (g_po_pdoi_write_to_file = 'Y') THEN
   	 po_debug.put_line('Before get who information');
	 END IF;
         /*
         ** Get the who information
	 */
	 X_login_id        := fnd_global.login_id;
         X_last_updated_by := fnd_global.user_id;

	 IF (g_po_pdoi_write_to_file = 'Y') THEN
   	 po_debug.put_line('Before update statement');
	 END IF;
	 /*
	 ** Update the purchase order shipment quantity to the lines qty.
	 */
	 UPDATE PO_LINE_LOCATIONS
	 SET    quantity           = X_line_quantity,
	        approved_flag      = decode(approved_flag, 'N', 'N', 'R'),
	        last_update_date   = sysdate,
		last_updated_by    = X_last_updated_by,
		last_update_login  = X_login_id
	 WHERE  line_location_id   = X_line_location_id
         AND    shipment_type      = X_shipment_type;

	 RETURN(TRUE);

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  null;
	WHEN OTHERS THEN
	  IF (g_po_pdoi_write_to_file = 'Y') THEN
   	  po_debug.put_line('In UPDATE exception');
	  END IF;
	  po_message_s.sql_error('update_shipment_qty', X_progress, sqlcode);
          raise;
      END update_shipment_qty;


/*===========================================================================

  FUNCTION NAME:	val_ship_qty

  	Note:		you should only call this routine if your
			shipment type is standard or planned.
			This way you prevent a server call.
			I am checking it in the server side just
			in case it is called.
	Issues:		Should you be able to update the quantity
			on a shipment if is finally closed?
			DEBUG.

===========================================================================*/
   FUNCTION val_ship_qty
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type        IN     VARCHAR2,
		       X_line_quantity        IN     NUMBER) RETURN BOOLEAN IS

      X_progress          VARCHAR2(3)  := '';
      X_approved_flag     VARCHAR2(1)  := '';
      X_encumbered_flag   VARCHAR2(1)  := '';
      X_closed_code       VARCHAR2(25) := '';
      X_cancelled_flag    VARCHAR2(1)  := '';
      X_line_location_id  NUMBER       := '';
      X_number_shipments  NUMBER       := '';


      BEGIN

	 /*
	 ** If this is a standard or planned purchase order, continue
	 ** with checks.  Otherwise, we should not update the price.
	 */
	 IF (X_shipment_type = 'STANDARD' OR X_shipment_type =  'PLANNED') THEN
	   null;
         ELSE
	   return(FALSE);
         END IF;

	 /*
         ** Get the number of shipments associated with the purchase order line.
	 */
	 X_number_shipments := po_shipments_sv2.get_number_shipments(X_po_line_id,
						              X_shipment_type);

	 IF (g_po_pdoi_write_to_file = 'Y') THEN
   	 po_debug.put_line('X_number_shipments = '||X_number_shipments);
	 END IF;

	 /*
         ** If the number of shipment is 1, then continue.  Otherwise,
	 ** we should not update the quantity on the shipment.
	 */
         IF (X_number_shipments = 1) THEN

	    X_line_location_id := po_shipments_sv3.get_line_location_id(X_po_line_id,
					                         X_shipment_type);

	    IF (g_po_pdoi_write_to_file = 'Y') THEN
   	    po_debug.put_line('X_line_location_id = '||X_line_location_id);
	    END IF;

	    /*
	    ** Get the line_location_id and status of the single shipment.
	    */
	    po_shipments_sv2.get_shipment_status (X_po_line_id,
					   X_shipment_type,
                                           X_line_location_id,
					   X_approved_flag,
					   X_encumbered_flag,
					   X_closed_code,
					   X_cancelled_flag);

	    IF (g_po_pdoi_write_to_file = 'Y') THEN
   	    po_debug.put_line('X_encumbered_flag = '||X_encumbered_flag);
     	    po_debug.put_line('X_cancelled_flag  = '||X_cancelled_flag);
	    END IF;

	    /*
	    ** Allow the quantity to be updated if the shipment is
	    ** not encumbered, cancelled or finally closed..
	    */
	    IF ( (X_encumbered_flag = 'N') AND
	         (X_cancelled_flag  = 'N') AND
                 (X_closed_code <> 'FINALLY CLOSED') )  THEN

		  IF po_shipments_sv2.update_shipment_qty (X_line_location_id,
						    X_shipment_type,
					            X_line_quantity) THEN
		     RETURN(TRUE);
                  ELSE
                     RETURN(FALSE);
                  END IF;

	     ELSE  /* The Shipment is encumbered/cancelled/finally closed. */
	       RETURN(FALSE);
             END IF;

           ELSE  /* Number of Shipments != 1  */
	       RETURN(FALSE);
          END IF;

      EXCEPTION
	when others then
	  IF (g_po_pdoi_write_to_file = 'Y') THEN
   	  po_debug.put_line('In exception');
	  END IF;
	  po_message_s.sql_error('val_ship_qty', X_progress, sqlcode);
          raise;
      END val_ship_qty;



/*===========================================================================

  FUNCTION NAME:	val_ship_price

	   Note:	you should only call this routine for standard
			and planned purchase orders.
===========================================================================*/
   FUNCTION val_ship_price
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type        IN     VARCHAR2,
		       X_unit_price           IN     NUMBER    ) RETURN BOOLEAN IS

      X_progress          VARCHAR2(3)  := '';

      BEGIN

	 /*
	 ** If this is a standard or planned purchase order, continue
	 ** with checks.  Otherwise, we should not update the price.
	 */
	 IF (X_shipment_type = 'STANDARD' OR X_shipment_type =  'PLANNED') THEN
	   null;
	   IF (g_po_pdoi_write_to_file = 'Y') THEN
   	   po_debug.put_line('It is STANDARD or PLANNED');
	   END IF;
         ELSE
	   IF (g_po_pdoi_write_to_file = 'Y') THEN
   	   po_debug.put_line('It is not STANDARD or PLANNED');
	   END IF;
	   return(FALSE);
         END IF;

	 IF (g_po_pdoi_write_to_file = 'Y') THEN
   	 po_debug.put_line('Before If');
	 END IF;
	 IF po_shipments_sv2.update_shipment_price (X_po_line_id,
		  			     X_shipment_type,
					     X_unit_price) THEN
	    IF (g_po_pdoi_write_to_file = 'Y') THEN
   	    po_debug.put_line('Returned TRUE');
	    END IF;
	    return(TRUE);
         ELSE
	    IF (g_po_pdoi_write_to_file = 'Y') THEN
   	    po_debug.put_line('Returned FALSE');
	    END IF;
            return(FALSE);
         END IF;
	 IF (g_po_pdoi_write_to_file = 'Y') THEN
   	 po_debug.put_line('After If');
	 END IF;


      EXCEPTION
	when others then
	  IF (g_po_pdoi_write_to_file = 'Y') THEN
   	  po_debug.put_line('In VAL exception');
	  END IF;
	  po_message_s.sql_error('val_ship_price', X_progress, sqlcode);
          raise;
      END val_ship_price;


/*===========================================================================

  FUNCTION NAME:	update_shipment_price

	   DEBUG:	Should we allow you to update the price
			on a finally closed shipment?

===========================================================================*/
   FUNCTION update_shipment_price
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type        IN     VARCHAR2,
		       X_unit_price           IN     NUMBER) RETURN BOOLEAN IS

      X_progress          VARCHAR2(3)  := '';
      X_login_id          NUMBER       := '';
      X_last_updated_by   NUMBER       := '';

      BEGIN

         X_progress := '010';

	 IF (g_po_pdoi_write_to_file = 'Y') THEN
   	 po_debug.put_line('Before get who information');
	 END IF;
         /*
         ** Get the who information
	 */
	 X_login_id        := fnd_global.login_id;
         X_last_updated_by := fnd_global.user_id;

	 IF (g_po_pdoi_write_to_file = 'Y') THEN
   	 po_debug.put_line('Before update statement');
	 END IF;
	 /*
	 ** Update the purchase order shipment price to the lines unit
	 ** price for all shipments that are not cancelled.
	 */
	 UPDATE PO_LINE_LOCATIONS
	 SET    price_override     = X_unit_price,
	        approved_flag      = decode(approved_flag, 'N', 'N', 'R'),
	        last_update_date   = sysdate,
		last_updated_by    = X_last_updated_by,
		last_update_login  = X_login_id
	 WHERE  po_line_id           = X_po_line_id
         AND    nvl(cancel_flag,'N') = 'N'
         AND    nvl(closed_code,'OPEN') <> 'FINALLY CLOSED'
         AND    shipment_type in ('STANDARD','PLANNED');

	 RETURN(TRUE);

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  null;
	WHEN OTHERS THEN
	  IF (g_po_pdoi_write_to_file = 'Y') THEN
   	  po_debug.put_line('In UPDATE exception');
	  END IF;
	  po_message_s.sql_error('update_shipment_price', X_progress, sqlcode);
          raise;
      END update_shipment_price;

/*===========================================================================
  --togeorge 05/18/2001
  --Bug# 1712919
  PROCEDURE NAME:	get_drop_ship_cust_locations
			On enter po and release forms ship to location code
			is required column. Since hz_locations does not
			store location_code and corresponding location
			code is null in hr_locations table, when a drop
			ship PO/Rel is queried in the form the user wont
			be allowed to save the records. So this procedure
			gets the concatenated address1 and city from
			hz_locations table for this specific condition.
			Called from POXPOPOS.pld(post_query)

===========================================================================*/
   PROCEDURE get_drop_ship_cust_locations
		      (x_ship_to_location_id  	IN     NUMBER,
		       x_ship_to_location_code  IN OUT NOCOPY VARCHAR2) IS

      X_progress          VARCHAR2(3)  := '';

      BEGIN
       X_progress := '010';

     --Bug# 1852364
     --togeorge 07/27/2001
     --Changed hr_locations to hz_locations in the following query as hr team
     --is going to remove union to hz_locations from hr_locations view.
     --SELECT nvl(location_code,substr(rtrim(address_line_1)||'-'||rtrim(town_or_city),1,20)) ship_to_location_code
  /* Bug 2313980 fixed. replaced below 'substr' with 'substrb' to take care of
      multibyte (like japanese) scenarios.
  */

     -- For bug 16214305 changing following select to get max 60 characters in to location code instead of 20.

       SELECT (substrb(rtrim(address1)||'-'||rtrim(city),1,60)) ship_to_location_code
         INTO x_ship_to_location_code
         FROM hz_locations
        WHERE location_id = x_ship_to_location_id;

      EXCEPTION
	WHEN OTHERS THEN
	  null;
      END get_drop_ship_cust_locations;

/*===========================================================================
  Bug 12830677
  PROCEDURE NAME: null_reference_fields
                  To remove reference at shipment level.

===========================================================================*/
   PROCEDURE null_reference_fields  (X_po_line_id   IN     NUMBER) IS

      X_progress          VARCHAR2(3)  := '';

   BEGIN

      X_progress := '010';

      IF (g_po_pdoi_write_to_file = 'Y') THEN
   	   po_debug.put_line('Before update statement');
      END IF;

     UPDATE PO_LINE_LOCATIONS
     SET
     from_header_id = NULL,
     from_line_id = NULL,
     from_line_location_id = NULL
     WHERE po_line_id = X_po_line_id;

      IF (g_po_pdoi_write_to_file = 'Y') THEN
   	   po_debug.put_line('After update statement');
      END IF;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN
        null;

      WHEN OTHERS THEN
        IF (g_po_pdoi_write_to_file = 'Y') THEN
	  po_debug.put_line('In PO_SHIPMENTS_SV2.null_reference_fields exception');
	END IF;
	po_message_s.sql_error('null_reference_fields', X_progress, sqlcode);
	raise;

   END null_reference_fields;

END PO_SHIPMENTS_SV2;

/
