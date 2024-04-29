--------------------------------------------------------
--  DDL for Package Body OE_PORTAL_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PORTAL_LINE" AS
/* $Header: OEXLPORB.pls 120.0 2005/06/04 11:11:24 appldev noship $ */



--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Oe_Portal_Line';

--  Global variables holding cached record.

g_line_rec                  OE_Order_PUB.Line_Rec_Type;
g_db_line_rec               OE_Order_PUB.Line_Rec_Type;
--g_set_of_books_rec            Set_Of_Books_Rec_Type;
--  Forward declaration of procedures maintaining entity record cache.



PROCEDURE Get_line
(   p_line_id                       IN  NUMBER
,   x_line_rec                      OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
);


PROCEDURE    Get_Item_Values(Item_Id IN NUMBER ,
				Inventory_Item OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
				Item_Desc    OUT NOCOPY /* file.sql.39 change */ VARCHAR2);
PROCEDURE Clear_Line;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Order_PUB.Header_Tbl_Type;


PROCEDURE Validate_Write_Line
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_line_id                       IN  NUMBER
, p_header_id                       IN NUMBER
, p_db_flag                         IN VARCHAR2 DEFAULT 'N'
, p_sold_to_org_id                  IN NUMBER
, p_inventory_item_id               IN NUMBER
, p_ordered_quantity               IN NUMBER
, p_order_quantity_uom             IN VARCHAR2
,p_ship_to_org_id                  IN NUMBER
, p_request_date                   IN varchar2
,   x_discounts                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_charges                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_taxes                         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_line_tax_value                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_schedule_ship_date            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_schedule_arrival_date         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_schedule_status_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_schedule_action_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_address1            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_address2            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_address3            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_address4            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_location            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_org                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_org_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_promise_date                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_unit_selling_price			 OUT NOCOPY /* file.sql.39 change */	NUMBER
,   x_unit_list_price			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_percent				 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_selling_percent			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_quantity			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_quantity_uom		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_calculate_price_flag		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_calculate_price_descr         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item_id			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_customer_item                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_item_desc                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_ordered_quantity               OUT NOCOPY /* file.sql.39 change */  NUMBER
, x_order_quantity_uom             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_request_date                    OUT NOCOPY /* file.sql.39 change */ DATE
,   x_ordered_item_id			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_list_id				 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_list				 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_payment_term_id			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_payment_term				 OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_shipment_priority_code		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_shipment_priority			 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms_code			 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms				 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_lock_control                  OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_line_id                         OUT NOCOPY /* file.sql.39 change */ NUMBER
,  x_ship_to_org_id                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,  x_ship_to_org                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_ship_to_location           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_address1            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_address2            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_address3            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_to_address4            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_x_old_line_tbl            OE_Order_PUB.Line_Tbl_Type;
l_x_line_tbl            OE_Order_PUB.Line_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_line_rec                OE_Order_PUB.Line_Rec_Type;
l_charge_amount             NUMBER := 0.0;
BEGIN

/* chhung delete the content of all procedures. Request by Esha */
null;

END Validate_Write_Line;



PROCEDURE    Get_Item_Values(Item_Id IN NUMBER ,
				Inventory_Item OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
				Item_Desc    OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
BEGIN

/* chhung delete the content of all procedures. Request by Esha */
null;

END Get_Item_Values;




PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_line_id                     IN  NUMBER
)
IS
l_x_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_x_old_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
BEGIN

/* chhung delete the content of all procedures. Request by Esha */
null;

END Delete_Row;


PROCEDURE Get_line
(
   p_line_id                       IN  NUMBER
,   x_line_rec                      OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
)
IS
BEGIN

/* chhung delete the content of all procedures. Request by Esha */
null;

END Get_Line;

PROCEDURE Clear_Line
IS
BEGIN

/* chhung delete the content of all procedures. Request by Esha */
null;

END Clear_Line;




END Oe_Portal_Line;

/
