--------------------------------------------------------
--  DDL for Package ASO_ORDER_FEEDBACK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_ORDER_FEEDBACK_PUB" AUTHID CURRENT_USER AS
/* $Header: asopomfs.pls 120.1.12010000.3 2014/06/26 18:38:02 vidsrini ship $ */

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
--  Function   : This API is the PUBLIC API that is invoked by Order Manager
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
--  Standard OUT NOCOPY /* file.sql.39 change */  Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
--	  x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2(2000)
--
--  UPDATE_NOTICE API specific IN Parameters:
--
--   ALL PARAMETERS ARE OPTIONAL
--
--   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
--                                       Default = OE_Order_PUB.G_MISS_HEADER_REC
--   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_REC
--   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_TBL
--   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_TBL
--   p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_PRICE_ATT_TBL
--   p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_PRICE_ATT_TBL
--   p_Header_Adj_Att_tbl            IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_ATT_TBL
--   p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_ATT_TBL
--   p_Header_Adj_Assoc_tbl          IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
--   p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
--   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_TBL
--   p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_TBL
--   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_TBL
--   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_TBL
--   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_TBL
--   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_TBL
--   p_Line_Price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_TBL
--   p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_TBL
--   p_Line_Adj_Att_tbl              IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_ATT_TBL
--   p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_ATT_TBL
--   p_Line_Adj_Assoc_tbl            IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
--   p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
--   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_SCREDIT_TBL
--   p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_SCREDIT_TBL
--   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LOT_SERIAL_TBL
--   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LOT_SERIAL_TBL
--   p_action_request_tbl            IN  OE_Order_PUB.Request_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_REQUEST_TBL
--
--
--  UPDATE_NOTICE API specific OUT NOCOPY /* file.sql.39 change */  Parameters:
--   none
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE UPDATE_NOTICE
(
 p_api_version		               IN	 NUMBER,
 p_init_msg_list		            IN	 VARCHAR2	DEFAULT FND_API.G_FALSE,
 p_commit					         IN  VARCHAR2	DEFAULT FND_API.G_FALSE,
 x_return_status		            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 x_msg_count				         OUT NOCOPY /* file.sql.39 change */  NUMBER,
 x_msg_data				            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC,
 p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC,
 p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL,
 p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL,
 p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
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
 p_Line_Price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
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
                                        OE_Order_PUB.G_MISS_REQUEST_TBL
);


--------------------------------------------------------------------------

-- Start of comments
--  API name   : GET_NOTICE
--  Type       : Public
--  Function   : This API is the PUBLIC API that is invoked by CRM Apps
--               to get the data regarding changes (inserts/updates/deletes) to the
--               Order Entities communicated by the Order Management application.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--	  p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */  Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
--	  x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2(2000)
--
--  GET_NOTICE API specific IN Parameters:
--   p_app_short_name   IN    VARCHAR2  Required
--   p_wait             IN    NUMBER    Optional
--                                      Default = DBMS_AQ.NO_WAIT
--
--  GET_NOTICE API specific OUT NOCOPY /* file.sql.39 change */  Parameters:
--
--   x_no_more_messages              OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   x_header_rec                    OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Rec_Type
--   x_old_header_rec                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Rec_Type
--   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Tbl_Type
--   x_old_Header_Adj_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Tbl_Type
--   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Price_Att_Tbl_Type
--   x_old_Header_Price_Att_tbl      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Price_Att_Tbl_Type
--   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Att_Tbl_Type
--   x_old_Header_Adj_Att_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Att_Tbl_Type
--   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--   x_old_Header_Adj_Assoc_tbl      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Scredit_Tbl_Type
--   x_old_Header_Scredit_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Scredit_Tbl_Type
--   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Tbl_Type
--   x_old_line_tbl                  OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Tbl_Type
--   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Tbl_Type
--   x_old_Line_Adj_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Tbl_Type
--   x_Line_Price_Att_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Price_Att_Tbl_Type
--   x_old_Line_Price_Att_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Price_Att_Tbl_Type
--   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Att_Tbl_Type
--   x_old_Line_Adj_Att_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Att_Tbl_Type
--   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--   x_old_Line_Adj_Assoc_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Scredit_Tbl_Type
--   x_old_Line_Scredit_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Scredit_Tbl_Type
--   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Lot_Serial_Tbl_Type
--   x_old_Lot_Serial_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Lot_Serial_Tbl_Type
--   x_action_request_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Request_Tbl_Type
--
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE GET_NOTICE
(
 p_api_version                   IN	  NUMBER,
 p_init_msg_list                 IN	  VARCHAR2	DEFAULT FND_API.G_FALSE,
 p_commit                        IN   VARCHAR2	DEFAULT FND_API.G_FALSE,
 x_return_status                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 x_msg_count                     OUT NOCOPY /* file.sql.39 change */   NUMBER,
 x_msg_data                      OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 p_app_short_name                IN   VARCHAR2,
 p_wait                          IN   NUMBER    DEFAULT DBMS_AQ.NO_WAIT,
 p_deq_condition                 IN   VARCHAR2  DEFAULT NULL, /* Bug 9410311 */
 p_navigation                    IN   NUMBER DEFAULT DBMS_AQ.FIRST_MESSAGE,
 x_no_more_messages              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 x_header_rec                    OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Rec_Type,
 x_old_header_rec                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Rec_Type,
 x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Tbl_Type,
 x_old_Header_Adj_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Tbl_Type,
 x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Price_Att_Tbl_Type,
 x_old_Header_Price_Att_tbl      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Price_Att_Tbl_Type,
 x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Att_Tbl_Type,
 x_old_Header_Adj_Att_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Att_Tbl_Type,
 x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
 x_old_Header_Adj_Assoc_tbl      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
 x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Scredit_Tbl_Type,
 x_old_Header_Scredit_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Scredit_Tbl_Type,
 x_line_tbl                      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Tbl_Type,
 x_old_line_tbl                  OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Tbl_Type,
 x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Tbl_Type,
 x_old_Line_Adj_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Tbl_Type,
 x_Line_Price_Att_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Price_Att_Tbl_Type,
 x_old_Line_Price_Att_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Price_Att_Tbl_Type,
 x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Att_Tbl_Type,
 x_old_Line_Adj_Att_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Att_Tbl_Type,
 x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
 x_old_Line_Adj_Assoc_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
 x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Scredit_Tbl_Type,
 x_old_Line_Scredit_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Scredit_Tbl_Type,
 x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Lot_Serial_Tbl_Type,
 x_old_Lot_Serial_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Lot_Serial_Tbl_Type,
 x_action_request_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Request_Tbl_Type
);


--------------------------------------------------------------------------

-- Start of comments
--  API name   : HANDLE_EXCEPTION
--  Type       : Public
--  Function   : This API is the PUBLIC API that is invoked by consumer apps
--               to enqueue a failed message in the Order Feedback Exception
--               Queue. Consumers may use the GET_EXCEPTION public API
--               to subsequently dequeue these failed message. If p_commit is
--               set to true the message is enqueued in an immediate mode and
--               is immediately available in for dequeueing by the
--               GET_EXCEPTION API, otherwise the message is available in
--               the exception queue only after the calling application commits.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--	  p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */  Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
--	  x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2(2000)
--
--  HANDLE_EXCEPTION API specific IN Parameters:

--   p_app_short_name   IN    VARCHAR2  Required
--
--   ALL PARAMETERS BELOW ARE OPTIONAL
--
--   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
--                                       Default = OE_Order_PUB.G_MISS_HEADER_REC
--   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_REC
--   p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_TBL
--   p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_TBL
--   p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_PRICE_ATT_TBL
--   p_old_Header_Price_Att_tbl      IN  OE_Order_PUB.Header_Price_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_PRICE_ATT_TBL
--   p_Header_Adj_Att_tbl            IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_ATT_TBL
--   p_old_Header_Adj_Att_tbl        IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_ATT_TBL
--   p_Header_Adj_Assoc_tbl          IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
--   p_old_Header_Adj_Assoc_tbl      IN  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL
--   p_Header_Scredit_tbl            IN  OE_Order_PUB.Header_Scredit_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_TBL
--   p_old_Header_Scredit_tbl        IN  OE_Order_PUB.Header_Scredit_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_HEADER_SCREDIT_TBL
--   p_line_tbl                      IN  OE_Order_PUB.Line_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_TBL
--   p_old_line_tbl                  IN  OE_Order_PUB.Line_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_TBL
--   p_Line_Adj_tbl                  IN  OE_Order_PUB.Line_Adj_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_TBL
--   p_old_Line_Adj_tbl              IN  OE_Order_PUB.Line_Adj_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_TBL
--   p_Line_Price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_TBL
--   p_old_Line_Price_Att_tbl        IN  OE_Order_PUB.Line_Price_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_PRICE_ATT_TBL
--   p_Line_Adj_Att_tbl              IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_ATT_TBL
--   p_old_Line_Adj_Att_tbl          IN  OE_Order_PUB.Line_Adj_Att_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_ATT_TBL
--   p_Line_Adj_Assoc_tbl            IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
--   p_old_Line_Adj_Assoc_tbl        IN  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_ADJ_ASSOC_TBL
--   p_Line_Scredit_tbl              IN  OE_Order_PUB.Line_Scredit_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_SCREDIT_TBL
--   p_old_Line_Scredit_tbl          IN  OE_Order_PUB.Line_Scredit_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LINE_SCREDIT_TBL
--   p_Lot_Serial_tbl                IN  OE_Order_PUB.Lot_Serial_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LOT_SERIAL_TBL
--   p_old_Lot_Serial_tbl            IN  OE_Order_PUB.Lot_Serial_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_LOT_SERIAL_TBL
--   p_action_request_tbl            IN  OE_Order_PUB.Request_Tbl_Type
--                                       Default = OE_ORDER_PUB.G_MISS_REQUEST_TBL
--
--
--  HANDLE_EXCEPTION API specific OUT NOCOPY /* file.sql.39 change */  Parameters:
--   none
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE HANDLE_EXCEPTION
(
 p_api_version		               IN	 NUMBER,
 p_init_msg_list		            IN	 VARCHAR2	DEFAULT FND_API.G_FALSE,
 p_commit					         IN  VARCHAR2	DEFAULT FND_API.G_FALSE,
 x_return_status		            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 x_msg_count				         OUT NOCOPY /* file.sql.39 change */  NUMBER,
 x_msg_data				            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 p_app_short_name                IN  VARCHAR2,
 p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC,
 p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC,
 p_Header_Adj_tbl                IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL,
 p_old_Header_Adj_tbl            IN  OE_Order_PUB.Header_Adj_Tbl_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_ADJ_TBL,
 p_Header_price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type :=
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
 p_Line_Price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type :=
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
                                        OE_Order_PUB.G_MISS_REQUEST_TBL
);

--------------------------------------------------------------------------

-- Start of comments
--  API name   : GET_EXCEPTION
--  Type       : Public
--  Function   : This API is the PUBLIC API that is invoked by CRM Apps
--               to get the data from the Order Feedback Exception Queue.
--               The messages from the Order Feedback Exception Queue may
--               be either retrieved in the browse mode or the remove mode.
--  Pre-reqs   : Data must have been enqueued by using the HANDLE_EXCEPTION
--               PUBLIC API.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--	  p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */  Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
--	  x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2(2000)
--
--  GET_EXCEPTION API specific IN Parameters:
--   p_app_short_name   IN    VARCHAR2  Required
--   p_wait             IN    NUMBER    Optional
--                                      Default = DBMS_AQ.NO_WAIT
--   p_dequeue_mode     IN    VARCHAR2  Optional
--                                      Default = DBMS_AQ.REMOVE
--   p_navigation       IN   VARCHAR2   Optional
--	           					DEFAULT = DBMS_AQ.FIRST_MESSAGE,
--
--  GET_EXCEPTION API specific OUT NOCOPY /* file.sql.39 change */  Parameters:
--
--   x_no_more_messages              OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   x_header_rec                    OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Rec_Type
--   x_old_header_rec                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Rec_Type
--   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Tbl_Type
--   x_old_Header_Adj_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Tbl_Type
--   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Price_Att_Tbl_Type
--   x_old_Header_Price_Att_tbl      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Price_Att_Tbl_Type
--   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Att_Tbl_Type
--   x_old_Header_Adj_Att_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Att_Tbl_Type
--   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--   x_old_Header_Adj_Assoc_tbl      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Scredit_Tbl_Type
--   x_old_Header_Scredit_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Scredit_Tbl_Type
--   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Tbl_Type
--   x_old_line_tbl                  OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Tbl_Type
--   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Tbl_Type
--   x_old_Line_Adj_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Tbl_Type
--   x_Line_Price_Att_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Price_Att_Tbl_Type
--   x_old_Line_Price_Att_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Price_Att_Tbl_Type
--   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Att_Tbl_Type
--   x_old_Line_Adj_Att_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Att_Tbl_Type
--   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--   x_old_Line_Adj_Assoc_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Scredit_Tbl_Type
--   x_old_Line_Scredit_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Scredit_Tbl_Type
--   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Lot_Serial_Tbl_Type
--   x_old_Lot_Serial_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Lot_Serial_Tbl_Type
--   x_action_request_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Request_Tbl_Type
--
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE GET_EXCEPTION
(
 p_api_version                   IN	  NUMBER,
 p_init_msg_list                 IN	  VARCHAR2	DEFAULT FND_API.G_FALSE,
 p_commit                        IN   VARCHAR2	DEFAULT FND_API.G_FALSE,
 x_return_status                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 x_msg_count                     OUT NOCOPY /* file.sql.39 change */   NUMBER,
 x_msg_data                      OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 p_app_short_name                IN   VARCHAR2,
 p_wait                          IN   NUMBER    DEFAULT DBMS_AQ.NO_WAIT,
 p_dequeue_mode                  IN   VARCHAR2  DEFAULT DBMS_AQ.REMOVE,
 p_navigation                    IN   VARCHAR2  DEFAULT DBMS_AQ.FIRST_MESSAGE,
 x_no_more_messages              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 x_header_rec                    OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Rec_Type,
 x_old_header_rec                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Rec_Type,
 x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Tbl_Type,
 x_old_Header_Adj_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Tbl_Type,
 x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Price_Att_Tbl_Type,
 x_old_Header_Price_Att_tbl      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Price_Att_Tbl_Type,
 x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Att_Tbl_Type,
 x_old_Header_Adj_Att_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Att_Tbl_Type,
 x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
 x_old_Header_Adj_Assoc_tbl      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
 x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Scredit_Tbl_Type,
 x_old_Header_Scredit_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Header_Scredit_Tbl_Type,
 x_line_tbl                      OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Tbl_Type,
 x_old_line_tbl                  OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Tbl_Type,
 x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Tbl_Type,
 x_old_Line_Adj_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Tbl_Type,
 x_Line_Price_Att_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Price_Att_Tbl_Type,
 x_old_Line_Price_Att_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Price_Att_Tbl_Type,
 x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Att_Tbl_Type,
 x_old_Line_Adj_Att_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Att_Tbl_Type,
 x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
 x_old_Line_Adj_Assoc_tbl        OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
 x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Scredit_Tbl_Type,
 x_old_Line_Scredit_tbl          OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Line_Scredit_Tbl_Type,
 x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Lot_Serial_Tbl_Type,
 x_old_Lot_Serial_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Lot_Serial_Tbl_Type,
 x_action_request_tbl            OUT NOCOPY /* file.sql.39 change */   OE_Order_PUB.Request_Tbl_Type
);

END ASO_ORDER_FEEDBACK_PUB;

/
