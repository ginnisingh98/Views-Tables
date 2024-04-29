--------------------------------------------------------
--  DDL for Package OE_ORDER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_GRP" AUTHID CURRENT_USER AS
/* $Header: OEXGORDS.pls 120.3.12010000.2 2008/12/31 07:30:27 smanian ship $ */


--  Start of Comments
--  API name    Process_Order
--  Type        Group
--  Function    Over Loaded
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec		    IN  OE_GLOBALS.Control_Rec_Type :=
				OE_GLOBALS.G_MISS_CONTROL_REC
,   p_api_service_level			 IN  VARCHAR2 := OE_GLOBALS.G_ALL_SERVICE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_Pub.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_old_header_val_rec            IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_old_Header_Adj_val_tbl        IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
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
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_old_Header_Scredit_val_tbl    IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_old_line_val_tbl              IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_old_Line_Adj_val_tbl          IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
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
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_old_Line_Scredit_val_tbl      IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_action_request_tbl            IN  OE_Order_PUB.Request_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_REQUEST_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
,   x_action_request_tbl	    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Request_Tbl_Type
--For bug 3390458
,   p_rtrim_data                    IN  Varchar2 :='N'
,   p_validate_desc_flex            in varchar2 default 'Y' -- bug4343612

--ER7675548
,   p_header_customer_info_tbl      IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
,   p_line_customer_info_tbl        IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
);

-- Process_order overloaded with payments parameters
PROCEDURE Process_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec		    IN  OE_GLOBALS.Control_Rec_Type :=
				OE_GLOBALS.G_MISS_CONTROL_REC
,   p_api_service_level			 IN  VARCHAR2 := OE_GLOBALS.G_ALL_SERVICE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_Pub.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_old_header_val_rec            IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_old_Header_Adj_val_tbl        IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
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
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_old_Header_Scredit_val_tbl    IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_Header_Payment_tbl            IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_old_Header_Payment_tbl        IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl        IN  OE_Order_PUB.Header_Payment_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_old_Header_Payment_val_tbl    IN  OE_Order_PUB.Header_Payment_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_old_line_val_tbl              IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_old_Line_Adj_val_tbl          IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
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
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_old_Line_Scredit_val_tbl      IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Line_Payment_tbl              IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_old_Line_Payment_tbl          IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl          IN  OE_Order_PUB.Line_Payment_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_VAL_TBL
,   p_old_Line_Payment_val_tbl      IN  OE_Order_PUB.Line_Payment_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_action_request_tbl            IN  OE_Order_PUB.Request_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_REQUEST_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
,   x_action_request_tbl	    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Request_Tbl_Type
--For bug 3390458
,   p_rtrim_data                    IN  Varchar2 :='N'
,   p_validate_desc_flex            in varchar2 default 'Y' -- bug4343612
--ER7675548
,   p_header_customer_info_tbl      IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
,   p_line_customer_info_tbl        IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
);

--  Start of Comments
--  API name    Lock_Order
--  Type        Group
--  Function    Over Loaded
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl          IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl            IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
);

-- Lock_order over loaded with payment parameters
PROCEDURE Lock_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl          IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_Header_Payment_tbl            IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl        IN  OE_Order_PUB.Header_Payment_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl            IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Line_Payment_tbl              IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl          IN  OE_Order_PUB.Line_Payment_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
);

--  Start of Comments
--  API name    Get_Order
--  Type        Group
--  Function    Over Loaded
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
);


-- Get_order over loaded with payment parameters
PROCEDURE Get_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
);

PROCEDURE Get_Option_Lines
( p_api_version_number   IN     NUMBER
, p_init_msg_list        IN     VARCHAR2  := FND_API.G_FALSE
, p_top_model_line_id    IN     NUMBER
, x_line_tbl             OUT NOCOPY /* file.sql.39 change */    OE_Order_Pub.Line_Tbl_Type
, x_return_status        OUT NOCOPY /* file.sql.39 change */    VARCHAR2
, x_msg_count            OUT NOCOPY /* file.sql.39 change */    NUMBER
, x_msg_data             OUT NOCOPY /* file.sql.39 change */    VARCHAR2
);

PROCEDURE Id_To_Value
(   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
);

-- Id_To_Value over loaded with payment parameters

PROCEDURE Id_To_Value
(   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_Header_Payment_tbl            IN  OE_Order_PUB.Header_Payment_Tbl_Type
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_Line_Payment_tbl              IN  OE_Order_PUB.Line_Payment_Tbl_Type
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Val_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Val_Tbl_Type
);

PROCEDURE Value_To_Id (
    x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
);

-- Id_To_Value over loaded with payment parameters

PROCEDURE Value_To_Id (
    x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type
,   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type
,   p_Header_Adj_val_tbl            IN  OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_Header_Scredit_val_tbl        IN  OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   p_Header_Payment_tbl            IN  OE_Order_PUB.Header_Payment_Tbl_Type
,   p_Header_Payment_val_tbl        IN  OE_Order_PUB.Header_Payment_Val_Tbl_Type
,   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
,   p_line_val_tbl                  IN  OE_Order_PUB.Line_Val_Tbl_Type
,   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type
,   p_Line_Adj_val_tbl              IN  OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_Line_Scredit_val_tbl          IN  OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   p_Line_Payment_tbl              IN  OE_Order_PUB.Line_Payment_Tbl_Type
,   p_Line_Payment_val_tbl          IN  OE_Order_PUB.Line_Payment_Val_Tbl_Type
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Header_Payment_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Line_Payment_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ OE_Order_PUB.Lot_Serial_Tbl_Type
);

PROCEDURE automatic_account_creation
 (
  p_header_rec			IN OE_Order_Pub.Header_Rec_Type,
  p_Header_Val_Rec              IN OE_Order_pub.Header_Val_Rec_TYPE,
  p_line_tbl			IN OE_Order_Pub.Line_Tbl_Type,
  p_Line_Val_tbl                IN OE_Order_pub.Line_Val_tbl_Type,
  x_header_rec			IN OUT NOCOPY /* file.sql.39 change */ OE_Order_Pub.Header_Rec_Type, --bug6278382
  x_line_tbl			IN OUT NOCOPY /* file.sql.39 change */ OE_Order_Pub.Line_Tbl_Type,   --bug6278382
  x_return_status		OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count 		        OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data         		OUT NOCOPY /* file.sql.39 change */ VARCHAR2
 );

--For bug 3390458
Procedure RTrim_data
(  p_x_header_rec	IN OUT NOCOPY OE_Order_Pub.Header_Rec_Type
 , p_x_line_tbl  	IN OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
 , x_return_status 	   OUT NOCOPY /* file.sql.39 change */ Varchar2);

-- Introduced for OKC workbench call. Call this API to check if there are
--constraints defined for the attribute "Contract terms"

PROCEDURE Check_Header_Security
( p_document_type IN VARCHAR2
, p_column        IN VARCHAR2 := NULL
, p_header_id     IN NUMBER
, p_operation     IN VARCHAR2
, x_msg_count     OUT NOCOPY NUMBER
, x_msg_data      OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_result        OUT NOCOPY NUMBER
);

END OE_Order_GRP;

/
