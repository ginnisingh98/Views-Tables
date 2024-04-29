--------------------------------------------------------
--  DDL for Package Body RCV_CORRECTION_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_CORRECTION_SV" AS
/* $Header: RCVTXCOB.pls 115.5 2004/03/19 03:03:31 wkunz ship $*/

/*===========================================================================

  PROCEDURE NAME:	post_query()

===========================================================================*/

PROCEDURE  POST_QUERY (  x_transaction_id                IN NUMBER,
                         x_receipt_source_code           IN VARCHAR2,
                         x_organization_id               IN NUMBER,
                         x_hazard_class_id               IN NUMBER,
                         x_un_number_id                  IN NUMBER,
                         x_shipment_line_id              IN NUMBER,
                         x_po_line_location_id           IN NUMBER,
                         x_rma_line_id           	 IN NUMBER,
			 x_parent_transaction_type	 IN VARCHAR2,
			 x_grand_parent_id		 IN NUMBER,

                         x_source_document_code          IN VARCHAR2,
			 x_destination_type_code         IN VARCHAR2,
                         x_lpn_id                        IN VARCHAR2,
                         x_transfer_lpn_id               IN VARCHAR2,
                         x_po_type                       IN VARCHAR2,

                         x_hazard_class                 OUT NOCOPY VARCHAR2,
                         x_un_number                    OUT NOCOPY VARCHAR2,
                         x_max_positive_qty          IN OUT NOCOPY NUMBER,
                         x_max_negative_qty          IN OUT NOCOPY NUMBER ,
			 x_max_tolerable_qty	     IN OUT NOCOPY NUMBER,
                         x_packing_slip                 OUT NOCOPY VARCHAR2,
			 x_max_supply_qty	        OUT NOCOPY NUMBER,

			 x_parent_transaction_type_dsp  OUT NOCOPY VARCHAR2,
			 x_destination_type_dsp         OUT NOCOPY VARCHAR2,
                         x_license_plate_number         OUT NOCOPY VARCHAR2,
                         x_transfer_license_plate_num   OUT NOCOPY VARCHAR2,

                         x_ordered_uom               IN OUT NOCOPY VARCHAR2,
                         x_secondary_ordered_uom     IN OUT NOCOPY VARCHAR2,
                         x_order_type                IN OUT NOCOPY VARCHAR2
			 )
IS

     cursor get_po_lookup_code(p_lookup_type in varchar2,p_lookup_code in varchar2) is
       select displayed_field
       from   po_lookup_codes
       where  lookup_type = p_lookup_type
       and    lookup_code = p_lookup_code
       AND    ROWNUM<=1;

     cursor get_uom_class(p_uom in varchar2) is
       select uom_class
       from   mtl_units_of_measure
       where  unit_of_measure = p_uom
       AND    ROWNUM<=1;

     cursor get_uom(p_uom_code in varchar2) is
       select unit_of_measure
       from   mtl_units_of_measure
       where  uom_code = p_uom_code
       AND    ROWNUM<=1;

     cursor get_license_plate_number(p_license_plate_id in varchar2) is
       select LICENSE_PLATE_NUMBER
       from   WMS_LICENSE_PLATE_NUMBERS
       where  LPN_ID = p_license_plate_id
       AND    ROWNUM<=1;

   x_progress 	        VARCHAR2(3) := NULL;
   unit_of_measure	VARCHAR2(25);
   tolerable_qty	NUMBER := 0;
   grand_parent_id      NUMBER := 0;

   /*Bug 1548597 */
   x_secondary_available_qty NUMBER := 0;

BEGIN

     if (x_parent_transaction_type is not null) then
       open  get_po_lookup_code('RCV TRANSACTION TYPE',x_parent_transaction_type);
       fetch get_po_lookup_code into x_parent_transaction_type_dsp;
       close get_po_lookup_code;
     end if;

     if (x_destination_type_code is not null) then
       open  get_po_lookup_code('RCV DESTINATION TYPE',x_destination_type_code);
       fetch get_po_lookup_code into x_destination_type_dsp;
       close get_po_lookup_code;
     end if;

     if (x_lpn_id is not null) then
       open  get_license_plate_number(x_lpn_id);
       fetch get_license_plate_number into x_license_plate_number;
       close get_license_plate_number;
     end if;

     if (x_transfer_lpn_id is not null) then
       open  get_license_plate_number(x_transfer_lpn_id);
       fetch get_license_plate_number into x_transfer_license_plate_num;
       close get_license_plate_number;
     end if;

     if (x_source_document_code = 'RMA') then
       if (x_ordered_uom is not null) then
         open  get_uom(x_ordered_uom);
         fetch get_uom into x_ordered_uom;
         close get_uom;
       end if;

       if (x_secondary_ordered_uom is not null) then
         open  get_uom(x_secondary_ordered_uom);
         fetch get_uom into x_secondary_ordered_uom;
         close get_uom;
       end if;
     else --x_source_document_code <> 'RMA'
       if (x_po_type is not null) then
         if (x_source_document_code = 'PO') then
           open  get_po_lookup_code('PO TYPE',x_po_type);
         else
           open  get_po_lookup_code('SHIPMENT SOURCE TYPE',x_po_type);
         end if;
         fetch get_po_lookup_code into x_order_type;
         close get_po_lookup_code;
       end if;
     end if; --x_source_document_code = 'RMA'




   /*
   ** Get the max negative quantity
   */
   /*Bug 1548597 */
   RCV_QUANTITIES_S.GET_AVAILABLE_QUANTITY ( 'CORRECT',
                                             x_transaction_id,
                                             x_receipt_source_code,
					     x_parent_transaction_type,
                                             null,
                                             'NEGATIVE',
                                             x_max_negative_qty,
                                             tolerable_qty,
                                             unit_of_measure,
                                             x_secondary_available_qty);
   /*
   ** For a transaction, the max supply quantity is the x_max_negative_quantity
   */
   x_max_supply_qty := x_max_negative_qty;

   /*
   ** Get the max positive quantity.
   ** The grand_parent_id is either the po_line_location_id,
   ** rcv_shipment_line_id or the x_grand_parent_id based
   ** on the parent transaction type and the receipt source
   ** code.
   */

   IF (x_parent_transaction_type not in ('RECEIVE', 'MATCH', 'UNORDERED')) THEN

	/*
	** the grand parent transaction has to be a receiving transaction.
 	** Hence, grand_parent_id = x_grand_parent_id
	*/

	grand_parent_id := x_grand_parent_id;

   ELSIF (x_parent_transaction_type = 'MATCH') THEN

	/*
	** This is the same as a vendor receipt. Hence,
	** the grand_parent_id should be the po_line_location_id
	*/

	IF (x_receipt_source_code = 'CUSTOMER') THEN
	   grand_parent_id := x_rma_line_id;
   	ELSE
	   grand_parent_id := x_po_line_location_id;
  	END IF;

   ELSIF (x_parent_transaction_type = 'UNORDERED') THEN

	/*
	** Since the unordered receipt is only backed by the
        ** receipt transaction use the transaction_id as the
        ** grandparent to get an infinite open ended positive
        ** correction quantity
	*/

	grand_parent_id := x_transaction_id;

   ELSIF (x_parent_transaction_type = 'RECEIVE') THEN

	/*
	** Depending on the receipt_source_code, the grand_parent_id
	** is either the po_line_location_id (for Vendor receipts) or
	** the rcv_shipment_line_id (for Internal receipts).
	*/

	IF (x_receipt_source_code = 'VENDOR') THEN

	   grand_parent_id := x_po_line_location_id;

	ELSIF (x_receipt_source_code = 'CUSTOMER') THEN
	   grand_parent_id := x_rma_line_id;

	ELSE

	   grand_parent_id := x_shipment_line_id;

	END IF;

   END IF;

   /*
   ** Get the max positive quantity
   */
   /*Bug 1548597 */
   RCV_QUANTITIES_S.GET_AVAILABLE_QUANTITY ( 'CORRECT',
                                             x_transaction_id,
                                             x_receipt_source_code,
                                             x_parent_transaction_type,
					     grand_parent_id,
                                             'POSITIVE',
                                             x_max_positive_qty,
                                             x_max_tolerable_qty,
                                             unit_of_measure,
                                             x_secondary_available_qty);

   /*
   ** Get the hazard class information if the hazard class id is
   ** not null
   */

   IF (x_hazard_class_id is NOT NULL) THEN

	x_progress := 10;

	SELECT 	hazard_class
    	INTO   	x_hazard_class
    	FROM   	po_hazard_classes
    	WHERE  	hazard_class_id = x_hazard_class_id;

   END IF;

   /*
   ** Get the UN Number info if the un number id is not null
   */

   IF (x_un_number_id is NOT NULL) THEN

	x_progress := 20;

	SELECT 	un_number
    	INTO   	x_un_number
    	FROM   	po_un_numbers
    	WHERE  	un_number_id = x_un_number_id;

   END IF;

        /*
         * BUG NO 782779.
         * We select the packing_slip for the block rcv_transaction
         * in the Enter Corrections form from the rcv_shipment_lines.
        */
        SELECT nvl(packing_slip,' ')
        INTO x_packing_slip
        FROM rcv_shipment_lines
        WHERE shipment_line_id = x_shipment_line_id;

EXCEPTION

   WHEN OTHERS THEN
      po_message_s.sql_error('post_query', x_progress, sqlcode);
      RAISE;

END post_query;


END RCV_CORRECTION_SV;

/
