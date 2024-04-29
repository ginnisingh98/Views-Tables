--------------------------------------------------------
--  DDL for Package Body PO_SHIPMENTS_SV5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHIPMENTS_SV5" as
/* $Header: POXPOS5B.pls 120.1 2005/07/19 14:41:56 pbamb noship $*/

/*===========================================================================

  PROCEDURE NAME:	val_source_line_num

===========================================================================*/
   PROCEDURE val_source_line_num
   			(X_entity_level 		IN VARCHAR2,
			 X_po_line_id 			IN NUMBER,
			 X_line_location_id		IN NUMBER,
			 X_shipment_type		IN VARCHAR2,
			 X_item_id			IN NUMBER,
			 X_inventory_organization_id	IN NUMBER,
                         X_line_type_id                 IN NUMBER,
			 X_quantity_ordered		IN OUT NOCOPY NUMBER,
			 X_line_type			IN OUT NOCOPY VARCHAR2,
                         X_outside_operation_flag	IN OUT NOCOPY VARCHAR2,
			 X_receiving_flag		IN OUT NOCOPY VARCHAR2,
                         X_planned_item_flag            IN OUT NOCOPY VARCHAR2,
                         X_outside_op_uom_type          IN OUT NOCOPY VARCHAR2,
                         X_invoice_close_tolerance      IN OUT NOCOPY NUMBER,
                         X_receive_close_tolerance      IN OUT NOCOPY NUMBER,
                         X_receipt_required_flag        IN OUT NOCOPY VARCHAR2,
                         X_stock_enabled_flag           IN OUT NOCOPY VARCHAR2,
                         X_total_line_quantity          IN OUT NOCOPY NUMBER) IS

      X_progress                VARCHAR2(3)  := '';
      X_val_sched_released_qty  VARCHAR2(1)  := '';

      X_outside_op_flag_msi      VARCHAR2(1) := ''; -- get item place holder
      X_internal_orderable       VARCHAR2(1) := ''; -- get item place holder
      X_purchasing_enabled	 VARCHAR2(1) := ''; -- get item place holder
      X_inventory_asset_flag	 VARCHAR2(1) := ''; -- get item place holder

      X_receipt_required_flag_temp   VARCHAR2(1);

      X_source_shipment_id     NUMBER := ''; -- only relevant if entity is SHIP
      X_planned_qty_ordered NUMBER := '';
      X_quantity_released NUMBER := '';
      X_receipt_close_tolerance_tmp NUMBER := '';

      --<INVCONV R12 START>
      X_secondary_default_ind      MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND%TYPE;
      X_grade_control_flag         MTL_SYSTEM_ITEMS.GRADE_CONTROL_FLAG%TYPE;
      X_secondary_unit_of_measure  MTL_UNITS_OF_MEASURE.UNIT_OF_MEASURE%TYPE;
      --<INVCONV R12 END>

      BEGIN

            --dbms_output.put_line('010');
	    X_progress := '010';
	    /*
	    ** If the quantity ordered is less than the quantity released to date
	    ** for all scheduled releases against the planned shipment, display a
	    ** message that they have over released.
	    */
            IF (X_shipment_type = 'SCHEDULED') THEN

	       SELECT quantity
	       INTO   X_planned_qty_ordered
	       FROM   po_lines
	       WHERE  po_line_id = X_po_line_id;

	       SELECT sum(quantity - nvl(quantity_cancelled,0))
	       INTO   X_quantity_released
	       FROM   po_line_locations
	       WHERE  po_line_id = X_po_line_id
	       AND    shipment_type = 'SCHEDULED';

	       IF (X_planned_qty_ordered = X_quantity_released) THEN
   	          po_message_s.app_error('PO_PO_ALL_SHIP_RELEASED');
	       END IF;

	    END IF;

            /* Get the Total Line Quantity that can still be released */
            IF X_shipment_type = 'SCHEDULED' then

               --dbms_output.put_line('020');
               X_progress := '020';

               SELECT nvl(sum(nvl(quantity,0) - nvl(quantity_cancelled, 0)),0)
               INTO   X_total_line_quantity
               FROM   po_line_locations
               WHERE  po_line_id    = X_po_line_id
               AND    shipment_type = 'SCHEDULED';

            ELSIF (X_shipment_type = 'PLANNED') THEN

               --dbms_output.put_line('030');
               X_progress := '030';

               SELECT sum(quantity - nvl(quantity_cancelled, 0))
               INTO   X_total_line_quantity
               FROM   po_line_locations
               WHERE  po_line_id = X_po_line_id
               AND    shipment_type <> 'PRICE BREAK';

            END IF;

            --dbms_output.put_line('040');
	    X_progress := '040';
	    /*
	    ** DEBUG.  Call the routine to get the line type information
	    */
             SELECT line_type,
                    nvl(outside_operation_flag,'N'),
                    receiving_flag,
					receipt_close
             INTO   X_line_type,
                    X_outside_operation_flag,
                    X_receipt_required_flag_temp,
					X_receipt_close_tolerance_tmp
	     FROM   po_line_types_v
             WHERE  line_type_id = X_line_type_id;


	    /*
	    **         Call the routine to get the item information
            **         If the item id is NOT NULL.
	    **         We do not use the OUTSIDE_OPERATION_FLAG from
            **         MSI here. It is here as the procedure happens
            **         to have it as a formal IN OUT parameter.
	    */
            --dbms_output.put_line('050');
	    X_progress := '050';

              If X_item_id is NOT NULL then

                 po_items_sv2.get_item_details(
                                 X_item_id                     ,
                                 X_inventory_organization_id   ,
                                 X_planned_item_flag           ,
                                 X_outside_op_flag_msi         ,
                                 X_outside_op_uom_type         ,
                                 X_invoice_close_tolerance     ,
                                 X_receive_close_tolerance     ,
                                 X_receipt_required_flag       ,
                                 X_stock_enabled_flag          ,
                                 X_internal_orderable	       ,
                                 X_purchasing_enabled	       ,
                                 X_inventory_asset_flag        ,
                             	 --<INVCONV R12 START>
                                 X_secondary_default_ind,
                             	 X_grade_control_flag,
                             	 X_secondary_unit_of_measure ) ;
                                 --<INVCONV R12 END>
             end if;

            /*
            ** Set the correct value of receipt_required_flag.
            ** The receipt required flag value on the Item overrides
            ** the value defined at the LINE TYPES level as long as
            ** it is NOT NULL
            */
            --dbms_output.put_line('060');
            if X_receipt_required_flag is NULL then
               X_receipt_required_flag := X_receipt_required_flag_temp;
            end if;

   -- Bug: 1322342 set the correct value of receive close tolerance also.

            if X_receive_close_tolerance is NULL then
               X_receive_close_tolerance := X_receipt_close_tolerance_tmp;
            end if;


      EXCEPTION
	when others then
	  --dbms_output.put_line('In exception');
	  po_message_s.sql_error('val_source_line_num', X_progress, sqlcode);
          raise;
      END val_source_line_num;


/*===========================================================================

  PROCEDURE NAME:	val_source_ship_num

===========================================================================*/
   PROCEDURE val_source_ship_num
   		      (X_entity_level            IN     VARCHAR2,
                       X_set_of_books_id         IN     NUMBER,
		       X_line_id                 IN     NUMBER,
		       X_line_location_id        IN     NUMBER,
		       X_shipment_type           IN     VARCHAR2,
		       X_quantity_ordered        IN     NUMBER,
		       X_source_shipment_id      IN     NUMBER,
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
                       X_last_accept_date           IN OUT NOCOPY DATE,
		       X_days_late_receipt_allowed  IN OUT NOCOPY NUMBER  ,
                       X_receipt_days_exception_code IN OUT NOCOPY VARCHAR2  ,
                       X_invoice_close_tolerance IN OUT NOCOPY NUMBER,
		       X_receive_close_tolerance IN OUT NOCOPY NUMBER,
		       X_accrue_on_receipt_flag  IN OUT NOCOPY VARCHAR2,
		       X_receipt_required_flag   IN OUT NOCOPY VARCHAR2,
		       X_inspection_required_flag IN OUT NOCOPY VARCHAR2,
		       X_val_sched_released_qty  IN OUT NOCOPY VARCHAR2) IS

      X_progress                VARCHAR2(3)  := '';

      BEGIN

	    /*
	    ** If the quantity ordered is less than the quantity released to date
	    ** for all scheduled releases against the planned shipment, display a
	    ** message that they have over released.
	    */
	    IF po_shipments_sv1.val_sched_released_qty
					('SHIPMENT',
					 X_line_id,
					 X_line_location_id,
				         'SCHEDULED',
					 X_quantity_ordered,
                                         X_source_shipment_id ) THEN

	       X_val_sched_released_qty := 'Y';

	    ELSE
	       X_val_sched_released_qty := 'N';

	    END IF;

	    /*
	    ** Call the routine to get the information from the source
	    ** planned shipment.
	    */
	    po_shipments_sv1.get_planned_ship_info (
		         X_source_shipment_id,
                         X_set_of_books_id,
                         X_ship_to_location_code,
		         X_ship_to_location_id,
		         X_ship_to_org_code,
		         X_ship_to_organization_id,
		         X_quantity,
			 X_price_override,
			 X_promised_date,
		         X_need_by_date,
			 X_taxable_flag,
			 X_tax_name,
			 X_enforce_ship_to_location   ,
                         X_allow_substitute_receipts  ,
                         X_receiving_routing_id       ,
                         X_qty_rcv_tolerance          ,
                         X_qty_rcv_exception_code     ,
                         X_days_early_receipt_allowed ,
                         X_last_accept_date           ,
                         X_days_late_receipt_allowed  ,
                         X_receipt_days_exception_code ,
                         X_invoice_close_tolerance,
			 X_receive_close_tolerance,
			 X_accrue_on_receipt_flag,
			 X_receipt_required_flag,
			 X_inspection_required_flag);


      EXCEPTION
	when others then
	  --dbms_output.put_line('In exception');
	  po_message_s.sql_error('source_ship_server_cover', X_progress, sqlcode);
          raise;
      END val_source_ship_num;




END  PO_SHIPMENTS_SV5;

/
