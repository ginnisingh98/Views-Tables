--------------------------------------------------------
--  DDL for Package OE_SERVICE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_SERVICE_UTIL" AUTHID CURRENT_USER As
/* $Header: OEXUSVCS.pls 120.0.12010000.1 2008/07/25 07:57:52 appldev ship $ */

G_PKG_NAME                   CONSTANT VARCHAR2(30) := 'OE_SERVICE_UTIL';
G_Header_Rec                 OE_Order_Pub.Header_Rec_Type :=
							 OE_Order_PUB.G_MISS_HEADER_REC;
G_old_header_rec             OE_Order_PUB.Header_Rec_Type :=
                                    OE_Order_PUB.G_MISS_HEADER_REC;
G_Header_Adj_tbl             OE_Order_PUB.Header_Adj_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_HEADER_ADJ_TBL;
G_old_Header_Adj_tbl         OE_Order_PUB.Header_Adj_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_HEADER_ADJ_TBL;
G_Header_Price_Att_tbl       OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL;
G_old_Header_Price_Att_tbl   OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL;
G_Header_Adj_Att_tbl         OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL;
G_old_Header_Adj_Att_tbl     OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
    							 OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL;
G_Header_Adj_Assoc_tbl       OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL;
G_old_Header_Adj_Assoc_tbl   OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
    							 OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL;
G_Header_Scredit_tbl         OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL;
G_old_Header_Scredit_tbl     OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL;
G_line_tbl                   OE_Order_PUB.Line_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_TBL;
G_old_line_tbl               OE_Order_PUB.Line_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_TBL;
G_Line_Adj_tbl               OE_Order_PUB.Line_Adj_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_ADJ_TBL;
G_old_Line_Adj_tbl           OE_Order_PUB.Line_Adj_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_ADJ_TBL;
G_Line_Price_Att_tbl         OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL;
G_old_Line_Price_Att_tbl     OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL;
G_Line_Adj_Att_tbl           OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL;
G_old_Line_Adj_Att_tbl       OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL;
G_Line_Adj_Assoc_tbl         OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL;
G_old_Line_Adj_Assoc_tbl     OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL;
G_Line_Scredit_tbl           OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL;
G_old_Line_Scredit_tbl       OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL;
G_Lot_Serial_tbl             OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LOT_SERIAL_TBL;
G_old_Lot_Serial_tbl         OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LOT_SERIAL_TBL;
G_Lot_Serial_val_tbl         OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL;
G_old_Lot_Serial_val_tbl     OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                    OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL;
G_action_request_tbl	    OE_Order_PUB.request_tbl_type :=
						      OE_Order_PUB.g_miss_request_tbl;

-- Following Table will be used for the Records Group for Customer Product
-- lchen add reference_number, current_serial_number to fix bug 1529961 4/5/01
Type srv_cust_prod_rec IS RECORD(
     customer_product_id  NUMBER,
     product              VARCHAR2(2000),
     product_description  VARCHAR2(240),
     reference_number     NUMBER,
     current_serial_number VARCHAR2(30));
l_srv_cust_prod_rec      srv_cust_prod_rec;
Type srv_cust_prod_tbl IS TABLE OF srv_cust_prod_rec
     Index By Binary_Integer;
l_srv_cust_prod_tbl      srv_cust_prod_tbl;

-- Following Table will be used for the Records Group for Available Services
Type srv_item_id_tbl IS TABLE OF OE_ITEMS_V.INVENTORY_ITEM_ID%TYPE
     Index By Binary_Integer;
l_srv_tbl           srv_item_id_tbl;
Type srv_items_rec IS RECORD(
     Item                 VARCHAR2(50),
     Item_Id              NUMBER,
     Item_Description     VARCHAR2(240),
     Inventory_Item_Id    NUMBER,
     Inventory_Item       VARCHAR2(40),
     Item_Identifier_Type VARCHAR2(25));
l_srv_rec            srv_items_rec;
Type t_service_rec IS RECORD(
     Product_Item_Id      NUMBER,
     Customer_Id          NUMBER,
     Product_Revision     VARCHAR2(20),
     Request_Date         DATE);
l_service_rec         t_service_rec;


Procedure Notify_OC
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type :=
                                        OE_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_Header_Price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
    							     OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl          IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
    							    OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_Line_Price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl            IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_action_request_tbl	           IN  OE_Order_PUB.request_tbl_type :=
						          OE_Order_PUB.g_miss_request_tbl
);

-- Procedure to Check for the availability of the CRM APIS

Procedure Check_Proc
(
	p_procedure_name	IN		varchar2,
	x_return_status     OUT NOCOPY /* file.sql.39 change */       varchar2
);


--  Procedure : Get_Service_Duration
--

PROCEDURE Get_Service_Duration
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_x_line_rec IN OUT NOCOPY  OE_ORDER_PUB.Line_Rec_Type
);

--  Procedure : Get_Service_Attribute
--

PROCEDURE Get_Service_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_x_line_rec   IN OUT NOCOPY  OE_ORDER_PUB.Line_Rec_Type
);

--  Procedure : Get_Service_Duration Overloaded for Form
--

PROCEDURE Get_Service_Duration
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_line_rec                      IN  OE_OE_FORM_LINE.Line_Rec_Type
,   x_line_rec                      OUT NOCOPY /* file.sql.39 change */ OE_OE_FORM_LINE.Line_Rec_Type
);


--  Procedure : Get_Service_Attribute overloaded for Form
--

PROCEDURE Get_Service_Attribute
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_line_rec                      IN  OE_OE_FORM_LINE.Line_Rec_Type
,   x_line_rec                      OUT NOCOPY /* file.sql.39 change */ OE_OE_FORM_LINE.Line_Rec_Type
);

PROCEDURE Get_Service_Ref_Line_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_order_number                  IN  NUMBER
,   p_line_number                   IN  NUMBER
,   p_shipment_number               IN  NUMBER
,   p_option_number                 IN  NUMBER
,   x_reference_line_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
);

PROCEDURE Get_Service_Ref_System_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_system_number                 IN  VARCHAR2
,   p_customer_id                   IN  NUMBER
,   x_reference_system_id           OUT NOCOPY /* file.sql.39 change */ NUMBER
);

PROCEDURE Get_Service_Ref_System_Name
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_reference_system_id           IN  NUMBER
,   p_customer_id                   IN  NUMBER
,   x_system_name                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE Get_Service_Ref_Cust_Product
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_reference_line_id             IN  NUMBER
,   p_customer_id                   IN  NUMBER
,   x_cust_product                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

PROCEDURE Get_Cust_Product_Line_ID
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_reference_line_id             IN  NUMBER
,   p_customer_id                   IN  NUMBER
,   x_cust_product_line_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
);


PROCEDURE Get_Cust_Prod_RG
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_customer_id                   IN  NUMBER
,   x_srv_cust_prod_tbl             OUT NOCOPY /* file.sql.39 change */ OE_SERVICE_UTIL.SRV_CUST_PROD_TBL
);

PROCEDURE Get_Avail_Service_RG
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_service_rec                   IN  OE_SERVICE_UTIL.T_SERVICE_REC
,   x_srv_cust_prod_tbl             OUT NOCOPY /* file.sql.39 change */ OE_SERVICE_UTIL.SRV_ITEM_ID_TBL
);

PROCEDURE Retrieve_OC_Messages;

PROCEDURE Val_Item_Change( p_application_id IN NUMBER,
					  p_entity_short_name in VARCHAR2,
					  p_validation_entity_short_name in VARCHAR2,
					  p_validation_tmplt_short_name in VARCHAR2,
					  p_record_set_tmplt_short_name in VARCHAR2,
					  p_scope in VARCHAR2,
					  p_result OUT NOCOPY /* file.sql.39 change */ NUMBER );

PROCEDURE Update_Service_Lines
(   p_x_line_tbl				 IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


  /* added for bug 1533658 */
Procedure CASCADE_CHANGES
( p_parent_line_id     IN  NUMBER,
  p_request_rec        IN  OE_Order_Pub.Request_Rec_Type,
  x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 );

/* Added for 1799820 */

FUNCTION IB_ACTIVE RETURN BOOLEAN;

-- For bug 2247331
PROCEDURE Update_Service_Option_Numbers
  ( p_top_model_line_id NUMBER );


END OE_SERVICE_UTIL;


/
