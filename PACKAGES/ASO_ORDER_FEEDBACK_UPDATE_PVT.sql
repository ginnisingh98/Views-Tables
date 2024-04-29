--------------------------------------------------------
--  DDL for Package ASO_ORDER_FEEDBACK_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_ORDER_FEEDBACK_UPDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: asovomus.pls 120.1 2005/06/29 12:42:41 appldev ship $ */

-- ---------------------------------------------------------
-- Declare Data Types
-- ---------------------------------------------------------

-- ---------------------------------------------------------
-- Declare Procedures
-- ---------------------------------------------------------

--------------------------------------------------------------------------

-- Start of comments
--  API name   : UPDATE_NOTICE
--  Type       : Public
--  Function   : This API is the PRIVATE API that is invoked by Order Manager
--               to communicate any changes (inserts/updates/deletes) to the
--               Order Entities to Oracle Order Capture application.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--	  p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */ Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER
--	  x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2(2000)
--
--  UPDATE_NOTICE specific IN Parameters:
--
--   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type OPTIONAL
--                                       Default := OE_Order_PUB.G_MISS_HEADER_REC
--   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type
--                                       Default := OE_ORDER_PUB.G_MISS_HEADER_REC
--   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_HEADER_ADJ_TBL
--   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_HEADER_ADJ_TBL
--   p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_HEADER_PRICE_ATT_TBL
--   p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_HEADER_PRICE_ATT_TBL
--   p_Header_Adj_Att_tbl            IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_HEADER_ADJ_ATT_TBL
--   p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_HEADER_ADJ_ATT_TBL
--   p_Header_Adj_Assoc_tbl          IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
--   p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
--   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_TBL
--   p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_TBL
--   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_TBL
--   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_TBL
--   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_ADJ_TBL
--   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_ADJ_TBL
--   p_Line_price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_TBL
--   p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_TBL
--   p_Line_Adj_Att_tbl              IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_ADJ_ATT_TBL
--   p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_ADJ_ATT_TBL
--   p_Line_Adj_Assoc_tbl            IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
--   p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
--   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_SCREDIT_TBL
--   p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LINE_SCREDIT_TBL
--   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LOT_SERIAL_TBL
--   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_LOT_SERIAL_TBL
--   p_action_request_tbl            IN  OE_Order_PUB.Request_Tbl_Type
--                                       Default := OE_ORDER_PUB.G_MISS_REQUEST_TBL
--
-- p_app_short_name        IN  VARCHAR2(30)       := NULL      ,
-- p_queue_type                    IN  VARCHAR2(30)       := 'ASO_OF_Q'
--
--  UPDATE_NOTICE specific OUT NOCOPY /* file.sql.39 change */ Parameters:
--   none
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE UPDATE_NOTICE
(
 p_api_version		             IN	 NUMBER,
 p_init_msg_list	             IN	 VARCHAR2	DEFAULT FND_API.G_FALSE,
 p_commit			             IN  VARCHAR2	DEFAULT FND_API.G_FALSE,
 x_return_status	             OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 x_msg_count		             OUT NOCOPY /* file.sql.39 change */  NUMBER,
 x_msg_data		             OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC,
 p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC,
 p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL,
 p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL,
 p_Header_Price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL,
 p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL,
 p_Header_Adj_Att_tbl            IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL,
 p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL,
 p_Header_Adj_Assoc_tbl          IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL,
 p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL,
 p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL,
 p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL,
 p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL,
 p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_TBL,
 p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL,
 p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_TBL,
 p_Line_price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL,
 p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL,
 p_Line_Adj_Att_tbl              IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL,
 p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL,
 p_Line_Adj_Assoc_tbl            IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL,
 p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL,
 p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL,
 p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL,
 p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL,
 p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_LOT_SERIAL_TBL,
 p_action_request_tbl            IN  OE_Order_PUB.Request_Tbl_Type   :=
                                        OE_Order_PUB.G_MISS_REQUEST_TBL,
 p_app_short_name                IN  VARCHAR2       := NULL    ,
 p_queue_type                    IN  VARCHAR2       := 'OF_QUEUE'
);

PROCEDURE ASO_Header_Rec_To_Type
(
p_header_rec                     IN  OE_Order_PUB.Header_Rec_Type ,
x_header_type                    OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Header_Type
);

PROCEDURE ASO_Header_Adj_Tbl_To_Var
(
p_header_adj_tbl_type            IN  OE_Order_PUB.Header_Adj_Tbl_Type,
x_header_adj_var_type            OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Header_Adj_Var_Type
);

PROCEDURE ASO_Header_Adj_Assoc_Tbl_T_Var
(
p_header_adj_assoc_tbl_type      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
x_header_adj_assoc_var_type      OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Header_Adj_Assoc_Var_Type
);

PROCEDURE ASO_Header_Adj_Att_Tbl_To_Var
(
p_header_adj_att_tbl_type        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type,
x_header_adj_att_var_type        OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Header_Adj_Att_Var_Type
);

PROCEDURE ASO_Header_Price_Tbl_To_Var
(
p_header_price_att_tbl_type      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type,
x_header_price_att_var_type      OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Header_Price_Att_Var_Type
);

PROCEDURE ASO_Header_Scredit_Tbl_To_Var
(
p_header_scredit_tbl_type        IN  OE_Order_PUB.Header_Scredit_Tbl_Type,
x_header_scredit_var_type        OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Header_Scredit_Var_Type
);

PROCEDURE ASO_Line_Tbl_To_Var
(
p_line_tbl_type                  IN  OE_Order_PUB.Line_Tbl_Type,
x_line_var_type                  OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Line_Var_Type
);

PROCEDURE ASO_Line_Adj_Tbl_To_Var
(
p_line_adj_tbl_type              IN  OE_Order_PUB.Line_Adj_Tbl_Type,
x_line_adj_var_type              OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Line_Adj_Var_Type
);

PROCEDURE ASO_Line_Adj_Assoc_Tbl_To_Var
(
p_line_adj_assoc_tbl_type        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
x_line_adj_assoc_var_type        OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Line_Adj_Assoc_Var_Type
);

PROCEDURE ASO_Line_Adj_Att_Tbl_To_Var
(
p_line_adj_att_tbl_type          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type,
x_line_adj_att_var_type          OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Line_Adj_Att_Var_Type
);

PROCEDURE ASO_Line_Price_Att_Tbl_To_Var
(
p_line_price_att_tbl_type        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type,
x_line_price_att_var_type        OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Line_Price_Att_Var_Type
);

PROCEDURE ASO_Line_Scredit_Tbl_To_Var
(
p_line_scredit_tbl_type          IN  OE_Order_PUB.Line_Scredit_Tbl_Type,
x_line_scredit_var_type          OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Line_Scredit_Var_Type
);

PROCEDURE ASO_Lot_Serial_Tbl_To_Var
(
p_lot_serial_tbl_type            IN  OE_Order_PUB.Lot_Serial_Tbl_Type,
x_lot_serial_var_type            OUT NOCOPY /* file.sql.39 change */  SYSTEM.ASO_Lot_Serial_Var_Type
);

PROCEDURE ASO_Request_Tbl_To_Var
(
p_request_tbl_type               IN      OE_Order_PUB.Request_Tbl_Type,
x_request_var_type               OUT NOCOPY /* file.sql.39 change */      SYSTEM.ASO_Request_Var_Type
);

PROCEDURE ASO_Order_Feedback_ENQ
(
p_aso_order_feedback_type IN      SYSTEM.ASO_ORDER_FEEDBACK_TYPE,
p_queue_type              IN      VARCHAR2,
p_commit                  IN      VARCHAR2,
p_app_short_name  IN      VARCHAR2
);

PROCEDURE ASO_CRM_Recipients
(
p_recipient_list        OUT NOCOPY /* file.sql.39 change */        DBMS_AQ.aq$_recipient_list_t
);

END ASO_ORDER_FEEDBACK_UPDATE_PVT;

 

/
