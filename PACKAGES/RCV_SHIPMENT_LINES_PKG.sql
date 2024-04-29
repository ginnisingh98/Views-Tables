--------------------------------------------------------
--  DDL for Package RCV_SHIPMENT_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_SHIPMENT_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: RCVTISLS.pls 120.2.12010000.7 2014/01/16 01:27:53 yilali ship $ */


  PROCEDURE Lock_Line_s( X_Rowid                          VARCHAR2,
                       X_Shipment_Line_Id	            NUMBER,
                       X_item_revision              	VARCHAR2,
                       X_stock_locator_id               NUMBER,
                       X_packing_slip                   VARCHAR2,
                       X_comments                  	VARCHAR2,
                       X_routing_header_id              NUMBER,
                       X_Reason_id                      NUMBER,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
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
		       X_Request_Id			NUMBER,
		       X_Program_Application_Id		NUMBER,
		       X_Program_Id			NUMBER,
		       X_Program_Update_Date		DATE,
           X_equipment_id   NUMBER DEFAULT NULL  --add by rcv changed for YMS

                      );


  PROCEDURE update_wc_line(
			p_shipment_line_id IN NUMBER,
			p_requested_amount       IN      NUMBER DEFAULT NULL,
			p_material_stored_amount IN      NUMBER DEFAULT NULL,
			p_amount_shipped         IN      NUMBER DEFAULT NULL,
			p_quantity_shipped       IN      NUMBER DEFAULT NULL
		       );


  PROCEDURE update_quantity_amount(
                        p_Shipment_Line_Id       IN      NUMBER,
                        p_quantity_shipped      IN      NUMBER,
                        p_amount_shipped        IN      NUMBER);

  PROCEDURE delete_line_s(
                       p_Shipment_Line_Id       IN      NUMBER) ;

PROCEDURE update_approval_status(p_level IN VARCHAR2,
                                p_approval_status IN VARCHAR2,
                                p_comments IN VARCHAR2,
                                p_document_id IN NUMBER);

 /* Bug 9534775 WC -ve correction */
  PROCEDURE correct_wc_line(
			p_shipment_line_id IN NUMBER,
			p_interface_transaction_id IN NUMBER
		       );

/* Bug 9534775 WC -ve correction, get available quantity for correction
   against WC and at Pay Item level receipt */
PROCEDURE get_wc_correct_quantity(p_correction_type            IN  VARCHAR2,
				  p_parent_transaction_type    IN  VARCHAR2,
				  p_receipt_source_code        IN  VARCHAR2,
				  p_po_line_location_id        IN  NUMBER,
				  p_shipment_header_id         IN  NUMBER,
				  p_available_quantity      IN OUT NOCOPY NUMBER);

/* Bug 9534775 WC -ve correction, get available amount for correction
   against WC and at Pay Item level receipt */
PROCEDURE get_wc_correct_amount(p_correction_type            IN  VARCHAR2,
				  p_parent_transaction_type    IN  VARCHAR2,
				  p_receipt_source_code        IN  VARCHAR2,
				  p_po_line_location_id        IN  NUMBER,
				  p_shipment_header_id         IN  NUMBER,
				  p_available_amount      IN OUT NOCOPY NUMBER);

/**
** update RSL in the main block with item_revision,stock_locator_id,packing_slip,comments,
** routging_header_is,reason_id and equipment_id
**/
PROCEDURE Update_Line_s(
		       X_Shipment_Line_Id	        NUMBER,
                       X_item_revision              	VARCHAR2,
                       X_stock_locator_id               NUMBER,
                       X_packing_slip                   VARCHAR2,
                       X_comments                  	VARCHAR2,
                       X_routing_header_id              NUMBER,
                       X_Reason_id                      NUMBER
		       );

   /* split line ER Begin*/

/**
** insert into RSL with insert RSL with the splitting data in the splitting window;
** the shipment id should be 1.2, 1.3
**/
PROCEDURE insert_rsl_split_line(
		         X_Shipment_Line_Id	         NUMBER,
             x_user_id                   NUMBER,
             x_logon_id                  NUMBER,
             x_qty1                      NUMBER,
             x_qty2                      NUMBER,
             x_line_num                  NUMBER,
             x_equipment_id              NUMBER

		      );
/**
** update the original rsl with the shipped quantity = the original quantity- total splitting quantity
** and LINE_NUM to 1.1;
**/
PROCEDURE update_split_original_line(
	              X_Shipment_Line_Id	        NUMBER,
                x_user_id                   NUMBER,
                x_logon_id                  NUMBER,
	              X_qty1                      NUMBER,
	              X_qty2                      NUMBER,
	              X_linenum                   NUMBER
	 );

/**
** API provide to YMS to return the item value at the equipment_id level
**/
PROCEDURE  get_rsl_value_for_yms (
             p_shipment_header_id   IN NUMBER
            ,p_equipment_id    IN  NUMBER
            ,x_value         OUT NOCOPY NUMBER
            ,x_pending_receipt_qty   OUT NOCOPY BOOLEAN
            ,x_ret_msg        OUT NOCOPY VARCHAR2
            ,x_return_status  OUT NOCOPY VARCHAR2);

/**
** API provide to YMS to update the equipment_id by shipment_header_id, and return the result status.
**/


PROCEDURE  set_yms_equipment (
             p_shipment_header_id IN  NUMBER ,
             p_equipment_id   IN NUMBER ,
             p_shipment_line_id       NUMBER DEFAULT NULL,
             x_return_status  OUT NOCOPY VARCHAR2,
             x_msg_data OUT NOCOPY VARCHAR2);

/**
** get primary quantity
**/
FUNCTION get_primary_qty
        (x_current_qty NUMBER,
         x_current_uom VARCHAR2,
         x_item_id NUMBER,
         x_to_org_id NUMBER
         ) RETURN   NUMBER;


/**
check if the x_org_id is yms_enabled
if yes, return true;else return false;
**/

FUNCTION get_yms_enable_flag(x_org_id NUMBER) RETURN BOOLEAN;

/**
** call the yms api to update the equipment
**/
PROCEDURE update_yms_content(x_equipment_id NUMBER,
                                x_equipment_id_old NUMBER DEFAULT NULL,
                                x_header_id    NUMBER);





/**
** get equipment_status
**/
FUNCTION get_equipment_status( x_header_id    NUMBER )  RETURN   VARCHAR2;


END RCV_SHIPMENT_LINES_PKG;




/
