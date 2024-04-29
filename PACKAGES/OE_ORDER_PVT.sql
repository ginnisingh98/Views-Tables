--------------------------------------------------------
--  DDL for Package OE_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVORDS.pls 120.1.12000000.1 2007/01/16 22:11:55 appldev ship $ */


-- This procedure will return TRUE if the order was a valid upgraded
-- order else will return FALSE

FUNCTION Valid_Upgraded_Order(p_header_id Number)
RETURN Boolean;


-- Entity Specific Procedures

-- Added to improve performance - if certain pvt procedures are operating
-- on only one entity, then these entity procedures can be called instead
-- of calling OE_Order_PVT.Process_Order

-- NOTE: In most cases, the API - Process_Requests_And_Notify_OC should
-- also be called after calling these procedures.

PROCEDURE Header
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_header_rec                  IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
,   p_x_old_header_rec              IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Header_Scredits
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Header_Scredit_tbl          IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_x_old_Header_Scredit_tbl      IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Header_Payments
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Header_Payment_tbl          IN OUT NOCOPY  OE_Order_PUB.Header_Payment_Tbl_Type
,   p_x_old_Header_Payment_tbl      IN OUT NOCOPY  OE_Order_PUB.Header_Payment_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Lines
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_line_tbl                    IN OUT NOCOPY  OE_Order_PUB.Line_Tbl_Type
,   p_x_old_line_tbl                IN OUT NOCOPY  OE_Order_PUB.Line_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Line_Scredits
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Scredit_tbl            IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_x_old_Line_Scredit_tbl        IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Line_Payments
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Line_Payment_tbl            IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Tbl_Type
,   p_x_old_Line_Payment_tbl        IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);

PROCEDURE Lot_Serials
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_x_Lot_Serial_tbl              IN OUT NOCOPY  OE_Order_PUB.Lot_Serial_Tbl_Type
,   p_x_old_Lot_Serial_tbl          IN OUT NOCOPY  OE_Order_PUB.Lot_Serial_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

);


-- Process_Requests_And_Notify
-- This API should be called by procedures that are directly updating
-- attributes on the sales order entities or calling the above entity
-- specific procedures for operations on the sales order entities.
-- Set p_process_requests to TRUE if delayed requests need to be executed
-- Set p_notify to TRUE if notifications to be posted to OC. Set p_process_ack
-- If acknowledgement is to be processed. Please make sure that you set
-- p_notify to TRUE when setting p_process_ack to TRUE. Otherwise
-- acknowledgements will not be processed.

PROCEDURE Process_Requests_And_Notify
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_process_requests              IN  BOOLEAN := TRUE
,   p_notify                        IN  BOOLEAN := TRUE
,   p_process_ack                   IN  BOOLEAN := TRUE
, x_return_status OUT NOCOPY VARCHAR2

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
,   p_Header_Payment_tbl            IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_old_Header_Payment_tbl        IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
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
,   p_Line_Payment_tbl              IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_old_Line_Payment_tbl          IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
);


--  Start of Comments
--  API name    Process_Order
--  Type        Private
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
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type :=
                                        OE_GLOBALS.G_MISS_CONTROL_REC
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_x_Header_Adj_tbl              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_x_Header_Price_Att_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_x_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
    								OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_x_Header_Adj_Assoc_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
    								OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_x_Header_Scredit_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_x_line_tbl                    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_x_Line_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_x_Line_Price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_x_Line_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
    								OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_x_Line_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
    								OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_x_Line_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_x_Lot_Serial_tbl              IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_x_action_request_tbl	      IN OUT NOCOPY OE_Order_PUB.request_tbl_type
,   p_action_commit				 IN  VARCHAR2 := FND_API.G_FALSE
);

-- Overloaded for payments entities
PROCEDURE Process_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type :=
                                        OE_GLOBALS.G_MISS_CONTROL_REC
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_x_Header_Adj_tbl              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL
,   p_x_Header_Price_Att_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL
,   p_x_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
    								OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL
,   p_x_Header_Adj_Assoc_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
    								OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_x_Header_Scredit_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL
,   p_x_Header_Payment_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Payment_Tbl_Type
,   p_old_Header_Payment_tbl        IN  OE_Order_PUB.Header_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PAYMENT_TBL
,   p_x_line_tbl                    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL
,   p_x_Line_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL
,   p_x_Line_Price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL
,   p_x_Line_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
    								OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL
,   p_x_Line_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
    								OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
,   p_x_Line_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL
,   p_x_Line_Payment_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Payment_Tbl_Type
,   p_old_Line_Payment_tbl          IN  OE_Order_PUB.Line_Payment_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PAYMENT_TBL
,   p_x_Lot_Serial_tbl              IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
,   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  OE_Order_PUB.Lot_Serial_Val_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_VAL_TBL
,   p_x_action_request_tbl	      IN OUT NOCOPY OE_Order_PUB.request_tbl_type
,   p_action_commit				 IN  VARCHAR2 := FND_API.G_FALSE
);

--  Start of Comments
--  API name    Lock_Order
--  Type        Private
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
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_x_Header_Adj_tbl              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   p_x_Header_Price_Att_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   p_x_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   p_x_Header_Adj_Assoc_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   p_x_Header_Scredit_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_x_line_tbl                    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   p_x_Line_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   p_x_Line_Price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   p_x_Line_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   p_x_Line_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   p_x_Line_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_x_Lot_Serial_tbl              IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
);

-- overloaded with payments parameters
PROCEDURE Lock_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_x_Header_Adj_tbl              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   p_x_Header_Price_Att_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   p_x_Header_Adj_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   p_x_Header_Adj_Assoc_tbl        IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   p_x_Header_Scredit_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   p_x_Header_Payment_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Payment_Tbl_Type
,   p_x_line_tbl                    IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   p_x_Line_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   p_x_Line_Price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   p_x_Line_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   p_x_Line_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   p_x_Line_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   p_x_Line_Payment_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Payment_Tbl_Type
,   p_x_Lot_Serial_tbl              IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
);

--  Start of Comments
--  API name    Get_Order
--  Type        Private
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
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
,   x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   x_Header_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_line_tbl                      IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   x_Line_Adj_tbl                  IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_price_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Lot_Serial_tbl                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
);

-- overloaded with payments parameters
PROCEDURE Get_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
,   x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   x_Header_Adj_tbl                IN OUT NOCOPY OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_price_Att_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          IN OUT NOCOPY OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            IN OUT NOCOPY OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Payment_tbl            IN OUT NOCOPY OE_Order_PUB.Header_Payment_Tbl_Type
,   x_line_tbl                      IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   x_Line_Adj_tbl                  IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_price_Att_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Payment_tbl              IN OUT NOCOPY OE_Order_PUB.Line_Payment_Tbl_Type
,   x_Lot_Serial_tbl                IN OUT NOCOPY OE_Order_PUB.Lot_Serial_Tbl_Type
);


Procedure Cancel_Order
(    p_api_version_number            IN  NUMBER
,    p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,    x_can_req                       IN OUT
                                        OE_ORDER_PUB.Cancel_Line_Tbl_Type
);

Procedure Set_Recursion_Mode (p_Entity_Code number,
                              p_In_Out number := 1);



END OE_Order_PVT;

 

/
