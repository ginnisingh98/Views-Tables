--------------------------------------------------------
--  DDL for Package OE_ORDER_IMPORT_SPECIFIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_IMPORT_SPECIFIC_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVIMSS.pls 120.1.12000000.1 2007/01/16 22:11:03 appldev ship $ */

--  Start of Comments
--  API name    OE_ORDER_IMPORT_SPECIFIC_PVT
--  Type        Private
--  Purpose  	Order Import Pre- and Post- Process_Order Processing
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--  Notes
--  End of Comments

G_PKG_NAME                       Varchar2(30) := 'OE_ORDER_IMPORT_SPECIFIC_PVT';
G_ONT_ADD_CUSTOMER               Varchar2(1);
G_ONT_TRANSACTION_PROCESSING     Varchar2(30);

--  Record structure for Add Customer processing

TYPE Customer_Rec_Type IS RECORD
(   Orig_Sys_Customer_Ref         Varchar2(50)
,   Orig_Ship_Address_Ref         Varchar2(50)
,   Orig_Bill_Address_Ref         Varchar2(50)
,   Orig_Deliver_Address_Ref      Varchar2(50)
,   Sold_to_Contact_Ref           Varchar2(50)
,   Ship_to_Contact_Ref           Varchar2(50)
,   Bill_to_Contact_Ref           Varchar2(50)
,   Deliver_to_Contact_Ref        Varchar2(50));

TYPE Customer_Tbl_Type IS TABLE OF Customer_Rec_Type
    INDEX BY BINARY_INTEGER;

PROCEDURE PRE_PROCESS(
   p_x_header_rec              IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type
  ,p_x_header_adj_tbl          IN OUT NOCOPY OE_Order_Pub.Header_Adj_Tbl_Type
-- 1433292 Pricing Attribute
  ,p_x_header_price_att_tbl    IN OUT NOCOPY OE_Order_Pub.Header_Price_Att_Tbl_Type
  ,p_x_header_adj_att_tbl      IN OUT NOCOPY OE_Order_Pub.Header_Adj_Att_Tbl_Type
  ,p_x_header_adj_assoc_tbl    IN OUT NOCOPY OE_Order_Pub.Header_Adj_Assoc_Tbl_Type
  ,p_x_header_scredit_tbl      IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Tbl_Type
  ,p_x_header_payment_tbl      IN OUT NOCOPY OE_Order_Pub.Header_Payment_Tbl_Type
  ,p_x_line_tbl                IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
  ,p_x_line_adj_tbl            IN OUT NOCOPY OE_Order_Pub.Line_Adj_Tbl_Type
  ,p_x_line_price_att_tbl      IN OUT NOCOPY OE_Order_Pub.Line_Price_Att_Tbl_Type
  ,p_x_line_adj_att_tbl        IN OUT NOCOPY OE_Order_Pub.Line_Adj_Att_Tbl_Type
  ,p_x_line_adj_assoc_tbl      IN OUT NOCOPY OE_Order_Pub.Line_Adj_Assoc_Tbl_Type
  ,p_x_line_scredit_tbl        IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Tbl_Type
  ,p_x_line_payment_tbl        IN OUT NOCOPY OE_Order_Pub.Line_payment_Tbl_Type
  ,p_x_lot_serial_tbl          IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Tbl_Type
  ,p_x_reservation_tbl         IN OUT NOCOPY OE_Order_Pub.Reservation_Tbl_Type
  ,p_x_action_request_tbl         IN OUT NOCOPY OE_Order_Pub.Request_Tbl_Type
--bsadri put back the action table
  ,p_x_header_val_rec          IN OUT NOCOPY OE_Order_Pub.Header_Val_Rec_Type
  ,p_x_header_adj_val_tbl      IN OUT NOCOPY OE_Order_Pub.Header_Adj_Val_Tbl_Type
  ,p_x_header_scredit_val_tbl  IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Val_Tbl_Type
  ,p_x_header_payment_val_tbl  IN OUT NOCOPY OE_Order_Pub.Header_Payment_Val_Tbl_Type
  ,p_x_line_val_tbl            IN OUT NOCOPY OE_Order_Pub.Line_Val_Tbl_Type
  ,p_x_line_adj_val_tbl        IN OUT NOCOPY OE_Order_Pub.Line_Adj_Val_Tbl_Type
  ,p_x_line_scredit_val_tbl    IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Val_Tbl_Type
  ,p_x_line_payment_val_tbl    IN OUT NOCOPY OE_Order_Pub.Line_Payment_Val_Tbl_Type
  ,p_x_lot_serial_val_tbl      IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Val_Tbl_Type
  ,p_x_reservation_val_tbl     IN OUT NOCOPY OE_Order_Pub.Reservation_Val_Tbl_Type
  ,p_header_customer_rec       IN            Customer_Rec_Type
  ,p_line_customer_tbl         IN            Customer_Tbl_Type

,p_return_status OUT NOCOPY VARCHAR2

);


PROCEDURE POST_PROCESS(
   p_x_header_rec                 IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type
  ,p_x_header_adj_tbl             IN OUT NOCOPY OE_Order_Pub.Header_Adj_Tbl_Type
-- 1433292 Pricing Attributes
  ,p_x_header_price_att_tbl       IN OUT NOCOPY OE_Order_Pub.Header_Price_Att_Tbl_Type
  ,p_x_header_adj_att_tbl         IN OUT NOCOPY OE_Order_Pub.Header_Adj_Att_Tbl_Type
  ,p_x_header_adj_assoc_tbl      IN OUT NOCOPY OE_Order_Pub.Header_Adj_Assoc_Tbl_Type
  ,p_x_header_scredit_tbl         IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Tbl_Type
  ,p_x_line_tbl                   IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
  ,p_x_line_adj_tbl               IN OUT NOCOPY OE_Order_Pub.Line_Adj_Tbl_Type
  ,p_x_line_price_att_tbl         IN OUT NOCOPY OE_Order_Pub.Line_Price_Att_Tbl_Type
  ,p_x_line_adj_att_tbl           IN OUT NOCOPY OE_Order_Pub.Line_Adj_Att_Tbl_Type
  ,p_x_line_adj_assoc_tbl         IN OUT NOCOPY OE_Order_Pub.Line_Adj_Assoc_Tbl_Type
  ,p_x_line_scredit_tbl           IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Tbl_Type
  ,p_x_lot_serial_tbl             IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Tbl_Type

  ,p_x_header_val_rec             IN OUT NOCOPY OE_Order_Pub.Header_Val_Rec_Type
  ,p_x_header_adj_val_tbl         IN OUT NOCOPY OE_Order_Pub.Header_Adj_Val_Tbl_Type
  ,p_x_header_scredit_val_tbl     IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Val_Tbl_Type
  ,p_x_line_val_tbl               IN OUT NOCOPY OE_Order_Pub.Line_Val_Tbl_Type
  ,p_x_line_adj_val_tbl           IN OUT NOCOPY OE_Order_Pub.Line_Adj_Val_Tbl_Type
  ,p_x_line_scredit_val_tbl       IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Val_Tbl_Type
  ,p_x_lot_serial_val_tbl         IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Val_Tbl_Type

  ,p_x_header_rec_old             IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type
  ,p_x_header_adj_tbl_old         IN OUT NOCOPY OE_Order_Pub.Header_Adj_Tbl_Type
  ,p_x_header_scredit_tbl_old     IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Tbl_Type
  ,p_x_line_tbl_old               IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
  ,p_x_line_adj_tbl_old           IN OUT NOCOPY OE_Order_Pub.Line_Adj_Tbl_Type
  ,p_x_line_price_att_tbl_old     IN OUT NOCOPY OE_Order_Pub.Line_Price_Att_Tbl_Type
  ,p_x_line_scredit_tbl_old       IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Tbl_Type
  ,p_x_lot_serial_tbl_old         IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Tbl_Type

  ,p_x_header_val_rec_old         IN OUT NOCOPY OE_Order_Pub.Header_Val_Rec_Type
  ,p_x_header_adj_val_tbl_old     IN OUT NOCOPY OE_Order_Pub.Header_Adj_Val_Tbl_Type
  ,p_x_header_scredit_val_tbl_old IN OUT NOCOPY OE_Order_Pub.Header_Scredit_Val_Tbl_Type
  ,p_x_line_val_tbl_old           IN OUT NOCOPY OE_Order_Pub.Line_Val_Tbl_Type
  ,p_x_line_adj_val_tbl_old       IN OUT NOCOPY OE_Order_Pub.Line_Adj_Val_Tbl_Type
  ,p_x_line_scredit_val_tbl_old   IN OUT NOCOPY OE_Order_Pub.Line_Scredit_Val_Tbl_Type
  ,p_x_lot_serial_val_tbl_old     IN OUT NOCOPY OE_Order_Pub.Lot_Serial_Val_Tbl_Type

  ,p_x_reservation_tbl           IN OUT NOCOPY OE_Order_Pub.Reservation_Tbl_Type
  ,p_x_reservation_val_tbl       IN OUT NOCOPY OE_Order_Pub.Reservation_Val_Tbl_Type

,p_return_status OUT NOCOPY VARCHAR2

);

END OE_ORDER_IMPORT_SPECIFIC_PVT;

 

/
