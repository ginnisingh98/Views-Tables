--------------------------------------------------------
--  DDL for Package Body PO_SHIPMENTS_SV9
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHIPMENTS_SV9" as
/* $Header: POXPOS9B.pls 120.2 2006/07/27 23:49:37 dreddy noship $*/

/*===========================================================================

  PROCEDURE NAME:	test_get_shipment_num

===========================================================================*/
   PROCEDURE test_get_shipment_num (X_po_release_id IN NUMBER,
				    X_po_line_id    IN NUMBER) IS

      X_shipment_num     NUMBER;

      BEGIN

         dbms_output.put_line('before call');

         po_shipments_sv1.get_shipment_num(X_po_release_id,
					  X_po_line_id,
					  X_shipment_num);

         dbms_output.put_line('after call');
         dbms_output.put_line(X_shipment_num);

      END test_get_shipment_num;

/*===========================================================================

  PROCEDURE NAME:	test_get_planned_ship_info

===========================================================================*/
   PROCEDURE test_get_planned_ship_info (X_source_shipment_id IN NUMBER,
                                         X_set_of_books_id    IN NUMBER) IS

/** PO UTF8 Column Expansion Project 9/23/2002 tpoon **/
/** Changed X_ship_to_location_code to use %TYPE **/
--      X_ship_to_location_code    VARCHAR2(20) := '';
      X_ship_to_location_code    hr_locations_all.location_code%TYPE := '';

      X_ship_to_location_id      NUMBER := '';
      X_ship_to_org_code         VARCHAR2(3) := '';
      X_ship_to_organization_id  NUMBER := '';
      X_quantity                 NUMBER := '';
      X_price_override		 NUMBER := '';
      X_promised_date		 DATE   := '';
      X_need_by_date		 DATE   := '';
      X_taxable_flag		 VARCHAR2(1) := '';
      X_tax_name		 zx_id_tcc_mapping.TAX_CLASSIFICATION_CODE%type:='';
      X_enforce_ship_to_location varchar2(25) := '';
      X_allow_substitute_receipts VARCHAR2(1) := '';
      X_receiving_routing_id    NUMBER := '';
      X_qty_rcv_tolerance       NUMBER := '';
      X_qty_rcv_exception_code  varchar2(25) := '';
      X_days_early_receipt_allowed NUMBER := '';
      X_last_accept_date	 DATE   := '';
      X_days_late_receipt_allowed NUMBER := '';
      X_receipt_days_exception_code varchar2(25) := '';
      X_invoice_close_tolerance  NUMBER := '';
      X_receive_close_tolerance  NUMBER := '';
      X_accrue_on_receipt_flag   VARCHAR2(1) := '';
      X_receipt_required_flag    VARCHAR2(1) := '';
      X_inspection_required_flag VARCHAR2(1) := '';

      BEGIN

         dbms_output.put_line('before call');

         po_shipments_sv1.get_planned_ship_info(
		         X_source_shipment_id,
                         X_set_of_books_id   ,
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
                         X_allow_substitute_receipts ,
                         X_receiving_routing_id,
                         X_qty_rcv_tolerance  ,
                         X_qty_rcv_exception_code  ,
                         X_days_early_receipt_allowed ,
                         X_last_accept_date,
                         X_days_late_receipt_allowed  ,
                         X_receipt_days_exception_code ,
                         X_invoice_close_tolerance,
			 X_receive_close_tolerance,
			 X_accrue_on_receipt_flag,
			 X_receipt_required_flag,
			 X_inspection_required_flag);

         dbms_output.put_line('after call');
         dbms_output.put_line('Location Code = '||X_ship_to_location_code);
	 dbms_output.put_line('Location Id   = '||X_ship_to_location_id);
	 dbms_output.put_line('Org Code   = '||X_ship_to_org_code);
	 dbms_output.put_line('Org Id   = '||X_ship_to_organization_id);
	 dbms_output.put_line('Quantity = '||X_quantity);

      END test_get_planned_ship_info;


/*===========================================================================

  PROCEDURE NAME:	test_get_sched_released_qty

===========================================================================*/
   PROCEDURE test_get_sched_released_qty (X_source_id        IN NUMBER,
		                          X_entity_level     IN VARCHAR2,
					  X_shipment_type    IN VARCHAR2) IS

   	 X_quantity_released NUMBER := '';

      BEGIN

         dbms_output.put_line('before call');

         X_quantity_released := po_shipments_sv1.get_sched_released_qty(X_source_id,
					X_entity_level, X_shipment_type);

         dbms_output.put_line('Return Value is = '||X_quantity_released);

      END test_get_sched_released_qty;


/*===========================================================================

  PROCEDURE NAME:	test_get_number_shipments

===========================================================================*/
   PROCEDURE test_get_number_shipments (X_po_line_id       IN NUMBER,
				        X_shipment_type    IN VARCHAR2) IS

   	 X_number_shipments NUMBER := '';

      BEGIN

         dbms_output.put_line('before call');

         X_number_shipments := po_shipments_sv2.get_number_shipments(X_po_line_id,
							       X_shipment_type);

         dbms_output.put_line('Return Value is = '||X_number_shipments);

      END test_get_number_shipments;

/*===========================================================================

  PROCEDURE NAME:	test_val_release_shipments

===========================================================================*/
   PROCEDURE test_val_release_shipments(X_po_line_id       IN NUMBER,
				        X_shipment_type    IN VARCHAR2) IS

      BEGIN

         dbms_output.put_line('before call');

         IF po_shipments_sv2.val_release_shipments(X_po_line_id, X_shipment_type) THEN
	    dbms_output.put_line('Return TRUE');
	 ELSE
	    dbms_output.put_line('Return FALSE');

	 END IF;
      END test_val_release_shipments;

/*===========================================================================

  PROCEDURE NAME:	test_get_line_location_id

===========================================================================*/
   PROCEDURE test_get_line_location_id (X_po_line_id       IN NUMBER,
				        X_shipment_type    IN VARCHAR2) IS

   	 X_line_location_id NUMBER := '';

      BEGIN

         dbms_output.put_line('before call');

         X_line_location_id := po_shipments_sv3.get_line_location_id(X_po_line_id,
							      X_shipment_type);

         dbms_output.put_line('Return Value is = '||X_line_location_id);

      END test_get_line_location_id;



/*===========================================================================

  PROCEDURE NAME:	test_get_shipment_status

===========================================================================*/
   PROCEDURE test_get_shipment_status (X_po_line_id IN NUMBER,
				       X_shipment_type    IN VARCHAR2) IS

	X_line_location_id  number;
        X_approved_flag   VARCHAR2(1)  := '';
        X_encumbered_flag VARCHAR2(1)  := '';
        X_closed_code     VARCHAR2(25) := '';
	X_cancelled_flag  VARCHAR2(1)  := '';

      BEGIN

         dbms_output.put_line('before call');

         po_shipments_sv2.get_shipment_status(X_po_line_id,
				       X_shipment_type,
                                       X_line_location_id,
				       X_approved_flag,
				       X_encumbered_flag,
				       X_closed_code,
				       X_cancelled_flag);

         dbms_output.put_line('Approved Value is = '||X_approved_flag);
	 dbms_output.put_line('Encumbered Value is = '||X_encumbered_flag);
	 dbms_output.put_line('Closed Code is = '||X_closed_code);
	 dbms_output.put_line('Cancelled_flag is = '||X_cancelled_flag);

      END test_get_shipment_status;

/*===========================================================================

  PROCEDURE NAME:	test_val_ship_qty

===========================================================================*/
   PROCEDURE test_val_ship_qty(X_po_line_id       IN NUMBER,
		               X_shipment_type IN VARCHAR2,
			       X_line_quantity    IN NUMBER) IS

   	 X_Ship_Val_For_Update BOOLEAN;

      BEGIN

         dbms_output.put_line('before call');

	 IF po_shipments_sv2.val_ship_qty(X_po_line_id,
				   X_shipment_type,
				   X_line_quantity) THEN
	    dbms_output.put_line('TRUE');
         ELSE
            dbms_output.put_line('FALSE');
         END IF;

      END test_val_ship_qty;


/*===========================================================================

  PROCEDURE NAME:	test_val_ship_price

===========================================================================*/
   PROCEDURE test_val_ship_price(X_po_line_id       IN NUMBER,
		               X_shipment_type      IN VARCHAR2,
			       X_unit_price         IN NUMBER) IS

   	 X_Ship_Val_For_Update BOOLEAN;

      BEGIN

         dbms_output.put_line('before call');

	 IF po_shipments_sv2.val_ship_price(X_po_line_id,
				     X_shipment_type,
				     X_unit_price) THEN
	    dbms_output.put_line('TRUE');
         ELSE
            dbms_output.put_line('FALSE');
         END IF;

      END test_val_ship_price;



/*===========================================================================

  PROCEDURE NAME:	test_val_approval_status

===========================================================================*/
   PROCEDURE test_val_approval_status(
                       X_shipment_id             IN NUMBER,
		       X_shipment_type           IN VARCHAR2,
		       X_quantity                IN NUMBER,
		       X_ship_to_location_id     IN NUMBER,
		       X_promised_date           IN DATE,
		       X_need_by_date            IN DATE,
		       X_shipment_num            IN NUMBER,
		       X_last_accept_date        IN DATE,
		       X_taxable_flag            IN VARCHAR2,
		       X_ship_to_organization_id IN NUMBER,
		       X_price_discount          IN NUMBER,
		       X_price_override          IN NUMBER,
		       X_tax_code_id		 IN NUMBER) IS

        X_need_to_approve number;

      BEGIN

         dbms_output.put_line('before call');

	 X_need_to_approve := po_shipments_sv10.val_approval_status(
		       X_shipment_id             ,
		       X_shipment_type           ,
		       X_quantity                ,
                       NULL,
		       X_ship_to_location_id     ,
		       X_promised_date           ,
		       X_need_by_date            ,
		       X_shipment_num            ,
		       X_last_accept_date        ,
		       X_taxable_flag            ,
		       X_ship_to_organization_id ,
		       X_price_discount          ,
		       X_price_override          ,
		       X_tax_code_id		 ,
                       NULL,   -- <INBOUND LOGISTICS FPJ>
                       NULL,   -- <INBOUND LOGISTICS FPJ>
                       NULL);  -- <INBOUND LOGISTICS FPJ>

         IF  ((X_need_to_approve = 1) or
              (X_need_to_approve = 2) ) THEN
	    dbms_output.put_line('TRUE');
         ELSE
            dbms_output.put_line('FALSE');
         END IF;

      END test_val_approval_status;


/*===========================================================================

  PROCEDURE NAME:	test_source_line_server_cover

===========================================================================*/
   PROCEDURE test_source_line_server_cover
			(X_entity_level 		IN VARCHAR2,
			 X_po_line_id 			IN NUMBER,
			 X_line_location_id		IN NUMBER,
			 X_shipment_type		IN VARCHAR2,
			 X_quantity_ordered		IN NUMBER,
			 X_line_type_id                 IN NUMBER,
			 X_item_id			IN NUMBER,
			 X_inventory_org_id             IN NUMBER) IS

		         X_out_quantity_ordered	        number;
                         X_OUTSIDE_OP_LINE_TYPE   varchar2(25);
			 X_category_id			NUMBER  := '';
			 X_item_revision		VARCHAR2(3) := '';
			 X_item_description		VARCHAR2(24) := '';
			 X_unit_meas_lookup_code 	VARCHAR2(25) := '';
			 X_unit_price			NUMBER := '';
			 X_not_to_exceed_price		NUMBER := '';
			 X_allow_price_override_flag	VARCHAR2(1) := '';
			 X_vendor_product_num		VARCHAR2(25) := '';
			 X_from_header_id		NUMBER := '';
			 X_from_line_id			NUMBER := '';
			 X_price_break_lookup_code	VARCHAR2(25) := '';
			 X_taxable_flag			VARCHAR2(1) := '';
			 X_outside_operation_flag	VARCHAR2(1) := '';
			 X_receiving_flag		VARCHAR2(1) := '';
			 X_line_type			VARCHAR2(25) := '';
			 X_item_num			VARCHAR2(40) := '';
			 X_planned_item_flag		VARCHAR2(1) := '';
			 X_outside_op_uom_type		VARCHAR2(25) := '';
			 X_invoice_close_tolerance	NUMBER := '';
			 X_receive_close_tolerance	NUMBER := '';
			 X_receipt_required_flag	VARCHAR2(1) := '';
			 X_stock_enabled_flag		VARCHAR2(1) := '';
			 X_category			VARCHAR2(40) := '';
			 X_val_sched_released_qty       VARCHAR2(1) := '';
                         X_total_line_quantity          NUMBER;

      BEGIN

         dbms_output.put_line('before call');

	 po_shipments_sv5.val_source_line_num
   			(X_entity_level 		,
			 X_po_line_id 			,
			 X_line_location_id		,
			 X_shipment_type		,
			 X_item_id			,
                         X_inventory_org_id    ,
                         X_line_type_id                 ,
                         X_out_quantity_ordered		,
			 X_line_type	                ,
			 X_outside_operation_flag	,
			 X_receiving_flag	        ,
                         X_planned_item_flag		,
			 X_outside_op_uom_type		,
			 X_invoice_close_tolerance	,
			 X_receive_close_tolerance	,
			 X_receipt_required_flag	,
			 X_stock_enabled_flag		,
                         X_total_line_quantity          );

      dbms_output.put_line('X_val_sched_released_qty = '||X_val_sched_released_qty);
      dbms_output.put_line('X_item_id = '||X_item_id);
      dbms_output.put_line('X_category_id = '||X_category_id);


      END test_source_line_server_cover;

/*===========================================================================

  PROCEDURE NAME:	test_val_start_dates()

===========================================================================*/

PROCEDURE test_val_start_dates
		(X_start_date		IN	DATE,
		 X_po_header_id		IN	NUMBER) IS

BEGIN

  dbms_output.put_line('Before_call');

 /*  IF po_rfqqt_s.val_start_dates(X_start_date, X_po_header_id) THEN
    dbms_output.put_line('Return TRUE');
  ELSE
    dbms_output.put_line('Return FALSE');
  END IF;*/

/* There is no server pkg by the name po_rfqqt_s. */
  null;


END test_val_start_dates;


/*===========================================================================

  PROCEDURE NAME:	test_val_end_dates()

===========================================================================*/

PROCEDURE test_val_end_dates
		(X_end_date		IN	DATE,
		 X_po_header_id			IN	NUMBER) IS

BEGIN

  dbms_output.put_line('Before_call');

 /* IF po_rfqqt_s.val_end_dates(X_end_date, X_po_header_id) THEN
    dbms_output.put_line('Return TRUE');
  ELSE
    dbms_output.put_line('Return FALSE');
  END IF;*/

/* There is no server pkg by the name po_rfqqt_s. */
  null;


END test_val_end_dates;

END  PO_SHIPMENTS_SV9;

/
