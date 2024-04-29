--------------------------------------------------------
--  DDL for Package Body PO_SHIPMENTS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHIPMENTS_SV1" as
/* $Header: POXPOS1B.pls 120.4 2006/06/16 11:30:50 nipagarw noship $*/
/*===========================================================================

  PROCEDURE NAME:	get_shipment_num

===========================================================================*/
   PROCEDURE get_shipment_num
		      (X_po_release_id 	      IN     NUMBER,
		       X_po_line_id           IN     NUMBER,
                       X_shipment_num         IN OUT NOCOPY NUMBER) IS

      X_progress varchar2(3) := '';

      BEGIN

	 -- If this is a release, pass in the release number.
         -- If this is not a release, pass in the po_line_id
	 IF (X_po_release_id is NOT NULL) THEN
	   SELECT max(PLL.shipment_num) + 1
	   INTO   X_shipment_num
           FROM   po_line_locations PLL
	   WHERE  PLL.po_release_id = X_po_release_id;

	 ELSE
	   SELECT max(PLL.shipment_num) + 1
	   INTO   X_shipment_num
           FROM   po_line_locations PLL
	   WHERE  PLL.po_line_id = X_po_line_id
	   AND    PLL.shipment_type in ('STANDARD', 'PLANNED', 'PRICE BREAK');

	 END IF;

	 --
	 -- If a shipment number is not selected, this is
	 -- the first shipment and a shipment number of
	 -- one should be returned.
	 --
	 IF (X_shipment_num is null) THEN
            X_shipment_num := 1;
	 END IF;



      EXCEPTION
	when others then
	  po_message_s.sql_error('get_shipment_num', X_progress, sqlcode);
          raise;

      END get_shipment_num;

/*===========================================================================

  PROCEDURE NAME:	get_planned_ship_info

===========================================================================*/
   PROCEDURE get_planned_ship_info
		      (X_source_shipment_id      IN     NUMBER,
                       X_set_of_books_id         IN     NUMBER,
                       X_ship_to_location_code   IN OUT NOCOPY VARCHAR2,
		       X_ship_to_location_id     IN OUT NOCOPY NUMBER,
		       X_ship_to_org_code        IN OUT NOCOPY VARCHAR2,
		       X_ship_to_organization_id IN OUT NOCOPY NUMBER,
		       X_quantity                IN OUT NOCOPY NUMBER,
		       X_price_override		 IN OUT NOCOPY NUMBER,
		       X_promised_date	         IN OUT NOCOPY DATE,
		       X_need_by_date            IN OUT NOCOPY DATE,
		       X_taxable_flag 		 IN OUT NOCOPY VARCHAR2,
		       X_tax_name                IN OUT NOCOPY VARCHAR2,
                       X_enforce_ship_to_location   IN OUT NOCOPY VARCHAR2,
                       X_allow_substitute_receipts  IN OUT NOCOPY VARCHAR2,
                       X_receiving_routing_id       IN OUT NOCOPY NUMBER  ,
                       X_qty_rcv_tolerance          IN OUT NOCOPY NUMBER  ,
                       X_qty_rcv_exception_code     IN OUT NOCOPY VARCHAR2  ,
                       X_days_early_receipt_allowed IN OUT NOCOPY NUMBER ,
                       X_last_accept_date        IN OUT NOCOPY DATE,
		       X_days_late_receipt_allowed  IN OUT NOCOPY NUMBER  ,
                       X_receipt_days_exception_code IN OUT NOCOPY VARCHAR2  ,
                       X_invoice_close_tolerance IN OUT NOCOPY NUMBER,
		       X_receive_close_tolerance IN OUT NOCOPY NUMBER,
		       X_accrue_on_receipt_flag  IN OUT NOCOPY VARCHAR2,
		       X_receipt_required_flag   IN OUT NOCOPY VARCHAR2,
		       X_inspection_required_flag IN OUT NOCOPY VARCHAR2) IS

      X_progress varchar2(3) := '';

      -- These two variables are required for the calls to get
      -- location name and get ship to org code.
      -- They are out parameters that are not used by this routine
      X_inv_org_id  number ;
      X_ship_to_org_name  varchar2(240);

      -- Bug 4963855. Removed references to tax columns. The calling procedure
      -- PO_SHIPMENTS_SV5.val_source_ship_num is not called from anywhere
      CURSOR C is
      SELECT PLL.ship_to_location_id,
             PLL.ship_to_organization_id,
             PLL.quantity,
             PLL.price_override,
             PLL.promised_date,
             PLL.need_by_date,
             PLL.enforce_ship_to_location_code,
             PLL.allow_substitute_receipts_flag,
             PLL.receiving_routing_id ,
             PLL.qty_rcv_tolerance ,
             PLL.qty_rcv_exception_code ,
             PLL.days_early_receipt_allowed ,
             PLL.last_accept_date,
             PLL.days_late_receipt_allowed,
             PLL.receipt_days_exception_code  ,
             PLL.invoice_close_tolerance,
             PLL.receive_close_tolerance,
             PLL.accrue_on_receipt_flag,
             PLL.receipt_required_flag,
             PLL.inspection_required_flag
      FROM   PO_LINE_LOCATIONS PLL
      WHERE  PLL.line_location_id = X_source_shipment_id;

      BEGIN

	 IF (X_source_shipment_id is not null) THEN
	    X_progress := '010';
            OPEN C;
	    X_progress := '020';

            FETCH C into X_ship_to_location_id,
			 X_ship_to_organization_id,
			 X_quantity,
			 X_price_override,
			 X_promised_date,
		         X_need_by_date,
                         X_enforce_ship_to_location   ,
                         X_allow_substitute_receipts  ,
                         X_receiving_routing_id       ,
                         X_qty_rcv_tolerance          ,
                         X_qty_rcv_exception_code     ,
                         X_days_early_receipt_allowed ,
                         X_last_accept_date,
			 X_days_late_receipt_allowed  ,
                         X_receipt_days_exception_code ,
                         X_invoice_close_tolerance,
			 X_receive_close_tolerance,
			 X_accrue_on_receipt_flag,
			 X_receipt_required_flag,
			 X_inspection_required_flag;

            CLOSE C;


         ELSE
	   X_progress := '030';
	   po_message_s.sql_error('get_planned_ship_info', X_progress,
				   sqlcode);

	 END IF;

         -- Get the location code based on location id.
         IF X_ship_to_location_id is not null then
            po_locations_s.get_loc_attributes(X_ship_to_location_id,
                                              X_ship_to_location_code,
                                              X_inv_org_id);
         ELSE
            X_ship_to_location_code := NULL;

         END IF;

	 -- get the ship to org code based on ship to org
         IF X_ship_to_organization_id is not null then
            po_orgs_sv.get_org_info(X_ship_to_organization_id,
                                    X_set_of_books_id,
                                    X_ship_to_org_code ,
                                    X_ship_to_org_name);
         ELSE
            X_ship_to_org_code := NULL;

         END IF;


      EXCEPTION
	when others then
	  po_message_s.sql_error('get_planned_ship_info', X_progress, sqlcode);
          raise;

   END get_planned_ship_info;


/*===========================================================================

  FUNCTION NAME:	get_sched_released_qty

===========================================================================*/

  FUNCTION get_sched_released_qty
		      (X_source_id            IN     NUMBER,
		       X_entity_level         IN     VARCHAR2,
		       X_shipment_type        IN     VARCHAR2) RETURN NUMBER IS

      X_progress            VARCHAR2(3) := '000';
      X_quantity_released   NUMBER      := '';
      X_planned_shipment_id NUMBER      := '';

      BEGIN
	 X_progress := '010';

	 /*
         ** Note always pass in the source shipment id or the source
	 ** line id.
         ** Get the quantity released for the scheduled shipments
	 ** When modifying this entity type:
	 **   Planned PO Shipment    = Where line_location_id = source_id
	 **   Planned PO Line        = Where po_line_id = source_id
	 */
	 IF (X_entity_level = 'LINE') THEN

            X_progress := '020';

	    SELECT sum(PLL.quantity - nvl(PLL.quantity_cancelled,0))
	    INTO   X_quantity_released
            FROM   po_line_locations PLL
            WHERE  PLL.po_line_id = X_source_id
	    AND    PLL.shipment_type = 'SCHEDULED' ;

	 ELSIF (X_entity_level = 'SHIPMENT') THEN /* Entity level is SHIPMENT */

	    /*
	    ** Get the quantity released for all releases against the
	    ** planned shipment
	    */
            X_progress := '030';

	    SELECT sum(PLL.quantity - nvl(PLL.quantity_cancelled,0))
	    INTO   X_quantity_released
            FROM   po_line_locations PLL
            WHERE  PLL.source_shipment_id  = X_source_id
	    AND    PLL.shipment_type = 'SCHEDULED' ;

	 -- Bug 3840143: Added qty released calculation for distributions
         ELSIF (X_entity_level = 'DISTRIBUTION') THEN /* Entity level is DISTRIBUTION */

	    /*
	    ** Get the quantity released for all releases against the
	    ** planned distributions
	    */
            X_progress := '040';

	    SELECT nvl(sum(nvl(POD.quantity_ordered,0)- nvl(POD.quantity_cancelled,0)),0)
	    INTO   X_quantity_released
            FROM   po_distributions POD
            WHERE  POD.source_distribution_id = X_source_id ;

         END IF;

         RETURN(X_quantity_released);

      EXCEPTION
	when others then
	  po_message_s.sql_error('get_sched_released_qty', X_progress, sqlcode);
          raise;
      END get_sched_released_qty;


/*===========================================================================

  FUNCTION NAME:	val_sched_released_qty

  DEBUG.  review this code.
===========================================================================*/
   FUNCTION val_sched_released_qty
		      (X_entity_level         IN     VARCHAR2,
		       X_line_id              IN     NUMBER,
		       X_line_location_id     IN     NUMBER,
		       X_shipment_type        IN     VARCHAR2,
		       X_quantity_ordered     IN     NUMBER,
                       X_source_shipment_id   IN     NUMBER ) RETURN BOOLEAN IS

      X_progress             VARCHAR2(3)  := '';
      X_quantity_ordered_new NUMBER       := '';
      X_quantity_released    NUMBER       := '';
      X_planned_shipment_id  NUMBER;

      BEGIN

	 /*
	 ** We should get the current quantity ordered for the
	 ** planned purchase order shipment.
	 ** We should also get total quantity released against the
	 ** planned purchase order shipment.
	 */


	 IF (X_entity_level = 'SHIPMENT') THEN

  	    -- This is called when modiyfing a scheduled shipment quantity.
	    -- DEBUG. do we ever call this for schedule releases or only
	    --- when modifying a planned po?  Messages are wrong for a release.
	    IF (X_shipment_type = 'SCHEDULED') THEN

              X_progress := '010';

	      -- get quantity ordered on planned shipment.
	      X_quantity_ordered_new := po_shipments_sv3.get_planned_qty_ordered(X_source_shipment_id,
										'PLANNED');

	      --dbms_output.put_line ('Qty ord (not null)= '||X_quantity_ordered_new);

	      -- get the quantity released to date against the planned
	      -- purchase order shipment that is associated with
	      -- the release shipment that we are modifying.
	      X_quantity_released := po_shipments_sv1.get_sched_released_qty
					     (X_source_shipment_id,
					      'SHIPMENT',
					      'SCHEDULED');

            -- This is called when modifying a planned purchase order shipment.
 	    ELSIF (X_shipment_type = 'PLANNED') THEN
	      X_quantity_ordered_new := X_quantity_ordered;

	      -- get the quantity released to date against the planned
	      -- purchase order shipment that we are currently modifying.
              X_quantity_released := po_shipments_sv1.get_sched_released_qty
                                             (X_line_location_id,
                                              'SHIPMENT',
                                              'SCHEDULED');

	    END IF;

	 ELSE /* Entity Level = Line */

	    -- this is called when modifying a planned purchase order line.
            X_quantity_ordered_new := X_quantity_ordered;

	    -- get the quantity released to date against the planned
	    -- purchase order line.
	    X_quantity_released := po_shipments_sv1.get_sched_released_qty
					     (X_line_id,
					      'LINE',
					      X_shipment_type);

            --dbms_output.put_line ('Qty released(line)= '||X_quantity_released);

         END IF;


	 /*
         ** If the quantity ordered is less than the quantity
	 ** released, we need to display a message to the user
	 ** that they cannot reduce the quantity ordered to
	 ** less than what has already be released.  The message
	 ** is displayed on the client side.
	 */
         IF (X_quantity_ordered_new > X_quantity_released OR
             X_quantity_released is NULL) THEN
	    --dbms_output.put_line ('Returned TRUE');
	    RETURN(TRUE);

	 ELSIF (X_quantity_ordered_new =  X_quantity_released) THEN
	    --dbms_output.put_line ('Returned FALSE');
            po_message_s.app_error('PO_PO_ALL_SHIP_RELEASED');

            RETURN(FALSE);

         ELSE
             /* If the Quantity Ordered is less than what has been
             ** already released display an appropriate message */
             po_message_s.app_error('PO_PO_QTY_EXCEEDS_UNREL');
             RETURN(FALSE);

         END IF;


      EXCEPTION
	when others then
	  --dbms_output.put_line('In VAL exception');
	  po_message_s.sql_error('val_sched_released_qty', X_progress, sqlcode);
          raise;
      END val_sched_released_qty;

END PO_SHIPMENTS_SV1;

/
