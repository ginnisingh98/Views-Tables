--------------------------------------------------------
--  DDL for Package ASO_ORDER_FEEDBACK_GET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_ORDER_FEEDBACK_GET_PVT" AUTHID CURRENT_USER AS
/* $Header: asovomgs.pls 120.1.12010000.2 2010/05/05 12:37:11 rassharm ship $ */

-- ---------------------------------------------------------
-- Declare Data Types
-- ---------------------------------------------------------

-- ---------------------------------------------------------
-- Declare Procedures
-- ---------------------------------------------------------

--------------------------------------------------------------------------
-- Start of comments
--  API name   : GET_NOTICE
--  Type       : Private
--  Function   : This API is the PRIVATE API that is invoked by CRM Apps
--               to get the data regarding changes (inserts/updates/deletes) to the
--               Order Entities communicated by the Order Management application.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */   Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */    NUMBER
--   x_msg_data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2(2000)
--
--  GET_NOTICE API specific IN Parameters:
--   p_app_short_name    IN   VARCHAR2  Required
--   p_queue_type        IN   VARCHAR2  Optional
--                                      Default =  OF_QUEUE
--   p_dequeue_mode      IN   NUMBER    Optional
--                                      Default = DBMS_AQ.REMOVE
--   p_navigation        IN   NUMBER    Optional
--                                      Default = DBMS_AQ.FIRST_MESSAGE
--   p_wait              IN   NUMBER    Optional
--                                      Default = DBMS_AQ.NO_WAIT
--
--  GET_NOTICE API specific OUT NOCOPY /* file.sql.39 change */   Parameters:
--
--   x_no_more_messages              OUT NOCOPY /* file.sql.39 change */    VARCHAR2
--   x_header_rec                    OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Rec_Type
--   x_old_header_rec                OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Rec_Type
--   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Tbl_Type
--   x_old_Header_Adj_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Tbl_Type
--   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Price_Att_Tbl_Type
--   x_old_Header_Price_Att_tbl      OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Price_Att_Tbl_Type
--   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Att_Tbl_Type
--   x_old_Header_Adj_Att_tbl        OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Att_Tbl_Type
--   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--   x_old_Header_Adj_Assoc_tbl      OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Scredit_Tbl_Type
--   x_old_Header_Scredit_tbl        OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Scredit_Tbl_Type
--   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Tbl_Type
--   x_old_line_tbl                  OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Tbl_Type
--   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Tbl_Type
--   x_old_Line_Adj_tbl              OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Tbl_Type
--   x_Line_Price_Att_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Price_Att_Tbl_Type
--   x_old_Line_Price_Att_tbl        OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Price_Att_Tbl_Type
--   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Att_Tbl_Type
--   x_old_Line_Adj_Att_tbl          OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Att_Tbl_Type
--   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--   x_old_Line_Adj_Assoc_tbl        OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Scredit_Tbl_Type
--   x_old_Line_Scredit_tbl          OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Scredit_Tbl_Type
--   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Lot_Serial_Tbl_Type
--   x_old_Lot_Serial_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Lot_Serial_Tbl_Type
--   x_action_request_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Request_Tbl_Type
--
--
--  Version	:	Current version	1.0
--  			Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE GET_NOTICE
(
 p_api_version                   IN   NUMBER,
 p_init_msg_list                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_commit                        IN   VARCHAR2	 DEFAULT FND_API.G_FALSE,
 x_return_status                 OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
 x_msg_count                     OUT NOCOPY /* file.sql.39 change */    NUMBER,
 x_msg_data                      OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
 p_app_short_name                IN   VARCHAR2,
 p_queue_type                    IN   VARCHAR2   DEFAULT 'OF_QUEUE',
 p_dequeue_mode                  IN   NUMBER     DEFAULT DBMS_AQ.REMOVE,
 p_navigation                    IN   NUMBER     DEFAULT DBMS_AQ.FIRST_MESSAGE,
 p_wait                          IN   NUMBER     DEFAULT DBMS_AQ.NO_WAIT,
 p_deq_condition                 IN   VARCHAR2  DEFAULT NULL, /* Bug 9410311 */
 x_no_more_messages              OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
 x_header_rec                    OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Rec_Type,
 x_old_header_rec                OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Rec_Type,
 x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Tbl_Type,
 x_old_Header_Adj_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Tbl_Type,
 x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Price_Att_Tbl_Type,
 x_old_Header_Price_Att_tbl      OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Price_Att_Tbl_Type,
 x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Att_Tbl_Type,
 x_old_Header_Adj_Att_tbl        OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Att_Tbl_Type,
 x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
 x_old_Header_Adj_Assoc_tbl      OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
 x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Scredit_Tbl_Type,
 x_old_Header_Scredit_tbl        OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Header_Scredit_Tbl_Type,
 x_line_tbl                      OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Tbl_Type,
 x_old_line_tbl                  OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Tbl_Type,
 x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Tbl_Type,
 x_old_Line_Adj_tbl              OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Tbl_Type,
 x_Line_Price_Att_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Price_Att_Tbl_Type,
 x_old_Line_Price_Att_tbl        OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Price_Att_Tbl_Type,
 x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Att_Tbl_Type,
 x_old_Line_Adj_Att_tbl          OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Att_Tbl_Type,
 x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
 x_old_Line_Adj_Assoc_tbl        OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
 x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Scredit_Tbl_Type,
 x_old_Line_Scredit_tbl          OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Line_Scredit_Tbl_Type,
 x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Lot_Serial_Tbl_Type,
 x_old_Lot_Serial_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Lot_Serial_Tbl_Type,
 x_action_request_tbl            OUT NOCOPY /* file.sql.39 change */    OE_Order_PUB.Request_Tbl_Type
);


END ASO_ORDER_FEEDBACK_GET_PVT;

/
