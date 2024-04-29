--------------------------------------------------------
--  DDL for Package Body ASO_ORDER_FEEDBACK_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_ORDER_FEEDBACK_UPDATE_PVT" AS
/* $Header: asovomub.pls 120.1.12010000.3 2015/08/03 22:09:32 vidsrini ship $ */


-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'ASO_ORDER_FEEDBACK_UPDATE_PVT';
G_USER CONSTANT VARCHAR2(30) := FND_GLOBAL.USER_ID;


-- ---------------------------------------------------------
-- Define Procedures
-- ---------------------------------------------------------

--------------------------------------------------------------------------

-- Start of comments
--  API name   : UPDATE_NOTICE
--  Type       : Private
--  Function   : This API is the PRIVATE API that is invoked by Order Manager
--               to communicate any changes (inserts/updates/deletes) to the
--               Order Entities to Oracle Order Capture application.
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
--   p_Header_Price_Att_tbl          IN  OE_Order_PUB.Header_Price_Att_Tbl_Type
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
-- p_app_short_name                  IN  VARCHAR2(30)       := NULL      ,
-- p_queue_type                      IN  VARCHAR2(30)       := 'OF_QUEUE'
--
--
--  UPDATE_NOTICE specific OUT NOCOPY /* file.sql.39 change */   Parameters:
--   none
--
--  Version :  Current version   1.0
--             Initial version   1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE UPDATE_NOTICE
(
 p_api_version                   IN  NUMBER,
 p_init_msg_list                 IN  VARCHAR2 :=  FND_API.G_FALSE,
 p_commit                        IN  VARCHAR2 := FND_API.G_FALSE,
 x_return_status                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 x_msg_count                     OUT NOCOPY /* file.sql.39 change */   NUMBER,
 x_msg_data                      OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
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
 p_app_short_name                IN  VARCHAR2         := NULL,
 p_queue_type                    IN  VARCHAR2       := 'OF_QUEUE'
)
IS
l_api_name	CONSTANT		VARCHAR2(30)	:= 'UPDATE_NOTICE';
l_api_version	CONSTANT		NUMBER			:= 1.0;
l_header_type					SYSTEM.ASO_Header_Type;
l_old_header_type				SYSTEM.ASO_Header_Type;
l_header_adj_var_type			SYSTEM.ASO_Header_Adj_Var_Type;
l_old_header_adj_var			SYSTEM.ASO_Header_Adj_Var_Type;
l_header_price_att_var_type		SYSTEM.ASO_Header_Price_Att_Var_Type;
l_old_header_price_att_var		SYSTEM.ASO_Header_Price_Att_Var_Type;
l_header_adj_att_var_type		SYSTEM.ASO_Header_Adj_Att_Var_Type;
l_old_header_adj_att_var		     SYSTEM.ASO_Header_Adj_Att_Var_Type;
l_header_adj_assoc_var_type		SYSTEM.ASO_Header_Adj_Assoc_Var_Type;
l_old_header_adj_assoc_var		SYSTEM.ASO_Header_Adj_Assoc_Var_Type;
l_header_scredit_var_type		SYSTEM.ASO_Header_Scredit_Var_Type;
l_old_header_scredit_var			SYSTEM.ASO_Header_Scredit_Var_Type;
l_line_var_type				SYSTEM.ASO_Line_Var_Type;
l_old_line_var					SYSTEM.ASO_Line_Var_Type;
l_line_adj_var_type				SYSTEM.ASO_Line_Adj_Var_Type;
l_old_line_adj_var				SYSTEM.ASO_Line_Adj_Var_Type;
l_line_price_att_var_type		SYSTEM.ASO_Line_Price_Att_Var_Type;
l_old_line_price_att_var			SYSTEM.ASO_Line_Price_Att_Var_Type;
l_line_adj_att_var_type			SYSTEM.ASO_Line_Adj_Att_Var_Type;
l_old_line_adj_att_var			SYSTEM.ASO_Line_Adj_Att_Var_Type;
l_line_adj_assoc_var_type		SYSTEM.ASO_Line_Adj_Assoc_Var_Type;
l_old_line_adj_assoc_var			SYSTEM.ASO_Line_Adj_Assoc_Var_Type;
l_line_scredit_var_type			SYSTEM.ASO_Line_Scredit_Var_Type;
l_old_line_scredit_var			SYSTEM.ASO_Line_Scredit_Var_Type;
l_lot_serial_var_type			SYSTEM.ASO_Lot_Serial_Var_Type;
l_old_lot_serial_var			SYSTEM.ASO_Lot_Serial_Var_Type;
l_request_var_type		          SYSTEM.ASO_Request_Var_Type;
l_aso_order_feedback_type		SYSTEM.ASO_ORDER_FEEDBACK_TYPE;
BEGIN

-- Standard Start of API savepoint

	SAVEPOINT	UPDATE_NOTICE_PVT;

-- Standard call to check for call compatibility.

	IF NOT FND_API.Compatible_API_Call (l_api_version ,
					    p_api_version ,
					    l_api_name ,
					    G_PKG_NAME )
		THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

--  Initialize API return status to success

	x_return_status := FND_API.G_RET_STS_SUCCESS;

-- UPDATE_NOTICE API specific input parameter validation logic
-- none

-- API Body

     -- Added debug message for P1 bug 21473372
        aso_debug_pub.g_debug_flag := 'Y';

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT.update_notice',1,'Y');
        END IF;
     ASO_Header_Rec_To_Type( p_header_rec , l_header_type);
	ASO_Header_Rec_To_Type( p_old_header_rec , l_old_header_type);

       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('** ASO_ORDER_FEEDBACK_UPDATE_PVT.update_notice before calling type conversion for ASO_HEADER_ADJ_TYPE with input p_Header_Adj_tbl **',1,'Y');
        END IF;
	ASO_Header_Adj_Tbl_To_Var( p_Header_Adj_tbl , l_header_adj_var_type);
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('** ASO_ORDER_FEEDBACK_UPDATE_PVT.update_notice before calling type conversion for ASO_HEADER_ADJ_TYPE with input p_old_Header_Adj_tbl ** ',1,'Y');
        END IF;
	ASO_Header_Adj_Tbl_To_Var( p_old_Header_Adj_tbl , l_old_header_adj_var);

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('** ASO_ORDER_FEEDBACK_UPDATE_PVT.update_notice before calling type conversion for ASO_HEADER_ADJ_TYPE with input p_Header_Adj_Assoc_tbl ** ',1,'Y');
        END IF;
	ASO_Header_Adj_Assoc_Tbl_T_Var( p_Header_Adj_Assoc_tbl , l_header_adj_assoc_var_type);
     ASO_Header_Adj_Assoc_Tbl_T_Var( p_old_Header_Adj_Assoc_tbl , l_old_header_adj_assoc_var);

	ASO_Header_Adj_Att_Tbl_To_Var( p_Header_Adj_Att_tbl , l_header_adj_att_var_type);
     ASO_Header_Adj_Att_Tbl_To_Var( p_old_Header_Adj_Att_tbl, l_old_header_adj_att_var);

	ASO_Header_Price_Tbl_To_Var( p_Header_price_Att_tbl , l_header_price_att_var_type);
     ASO_Header_Price_Tbl_To_Var( p_old_Header_Price_Att_tbl, l_old_header_price_att_var);

	ASO_Header_Scredit_Tbl_To_Var( p_Header_Scredit_tbl , l_header_scredit_var_type);
     ASO_Header_Scredit_Tbl_To_Var( p_old_Header_Scredit_tbl , l_old_header_scredit_var);

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('** ASO_ORDER_FEEDBACK_UPDATE_PVT.update_notice before calling type conversion for ASO_LINE_TYPE with input p_line_tbl **',1,'Y');
     END IF;
	ASO_Line_Tbl_To_Var( p_line_tbl , l_line_var_type);
	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('** ASO_ORDER_FEEDBACK_UPDATE_PVT.update_notice before calling type conversion for ASO_LINE_TYPE with input p_old_line_tbl **',1,'Y');
     END IF;
     ASO_Line_Tbl_To_Var( p_old_line_tbl , l_old_line_var);

     ASO_Line_Adj_Tbl_To_Var( p_Line_Adj_tbl , l_line_adj_var_type);
	ASO_Line_Adj_Tbl_To_Var( p_old_Line_Adj_tbl , l_old_line_adj_var);

     ASO_Line_Adj_Assoc_Tbl_To_Var( p_Line_Adj_Assoc_tbl , l_line_adj_assoc_var_type);
	ASO_Line_Adj_Assoc_Tbl_To_Var( p_old_Line_Adj_Assoc_tbl , l_old_line_adj_assoc_var);

     ASO_Line_Adj_Att_Tbl_To_Var( p_Line_Adj_Att_tbl , l_line_adj_att_var_type);
	ASO_Line_Adj_Att_Tbl_To_Var( p_old_Line_Adj_Att_tbl , l_old_line_adj_att_var);

     ASO_Line_Price_Att_Tbl_To_Var( p_Line_Price_Att_tbl , l_line_price_att_var_type);
	ASO_Line_Price_Att_Tbl_To_Var( p_old_Line_Price_Att_tbl , l_old_line_price_att_var);

     ASO_Line_Scredit_Tbl_To_Var( p_Line_Scredit_tbl , l_line_scredit_var_type);
	ASO_Line_Scredit_Tbl_To_Var( p_old_Line_Scredit_tbl , l_old_line_scredit_var);

     ASO_Lot_Serial_Tbl_To_Var( p_Lot_Serial_tbl , l_lot_serial_var_type);
	ASO_Lot_Serial_Tbl_To_Var( p_old_Lot_Serial_tbl , l_old_lot_serial_var);

     ASO_Request_Tbl_To_Var( p_action_request_tbl , l_request_var_type);

	l_aso_order_feedback_type  :=  SYSTEM.ASO_ORDER_FEEDBACK_TYPE(
											     l_header_type,
												l_old_header_type,
												l_header_adj_var_type,
												l_old_header_adj_var,
												l_header_price_att_var_type,
												l_old_header_price_att_var ,
												l_header_adj_att_var_type,
												l_old_header_adj_att_var,
												l_header_adj_assoc_var_type,
												l_old_header_adj_assoc_var,
												l_header_scredit_var_type,
												l_old_header_scredit_var,
												l_line_var_type,
												l_old_line_var,
												l_line_adj_var_type,
												l_old_line_adj_var,
												l_line_price_att_var_type,
												l_old_line_price_att_var,
												l_line_adj_att_var_type,
												l_old_line_adj_att_var,
												l_line_adj_assoc_var_type,
												l_old_line_adj_assoc_var,
												l_line_scredit_var_type,
												l_old_line_scredit_var,
												l_lot_serial_var_type,
												l_old_lot_serial_var,
												l_request_var_type
												);

	ASO_Order_Feedback_ENQ		(
							   l_aso_order_feedback_type,
							   p_queue_type,
							   p_commit,
							   p_app_short_name
							);

-- End of API Body

-- Standard check of p_commit.

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

-- Standard call to get message count and if count is 1, get message info.

	FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
	      p_data => x_msg_data
		);

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO  UPDATE_NOTICE_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  UPDATE_NOTICE_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
		 	 p_data => x_msg_data
      	);
	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_NOTICE_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
END UPDATE_NOTICE;

PROCEDURE ASO_Header_Rec_To_Type
(
     p_header_rec        IN   OE_Order_PUB.Header_Rec_Type ,
     x_header_type       OUT NOCOPY /* file.sql.39 change */    SYSTEM.ASO_Header_Type
)
IS

BEGIN

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.accounting_rule_id:'|| p_header_rec.accounting_rule_id );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.agreement_id:'|| p_header_rec.agreement_id);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute1 :'|| p_header_rec.attribute1) ;
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute10 :'|| p_header_rec.attribute10);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute11 :'|| p_header_rec.attribute11);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute12 :'|| p_header_rec.attribute12);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute13:'|| p_header_rec.attribute13);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute14:'|| p_header_rec.attribute14);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute15:'|| p_header_rec.attribute15);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute2:'|| p_header_rec.attribute2);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute3:'|| p_header_rec.attribute3);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute4:'|| p_header_rec.attribute4);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute5:'|| p_header_rec.attribute5);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute6:'|| p_header_rec.attribute6);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute7:'|| p_header_rec.attribute7);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute8:'|| p_header_rec.attribute8);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.attribute9:'|| p_header_rec.attribute9);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.booked_flag:'|| p_header_rec.booked_flag);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.cancelled_flag:'|| p_header_rec.cancelled_flag);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.context:'|| p_header_rec.context);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.conversion_rate:'|| p_header_rec.conversion_rate);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.conversion_rate_date:'|| p_header_rec.conversion_rate_date);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.conversion_type_code:'|| p_header_rec.conversion_type_code);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.created_by :'|| p_header_rec.created_by);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.creation_date:'|| p_header_rec.creation_date);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.cust_po_number:'|| p_header_rec.cust_po_number);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.deliver_to_contact_id:'|| p_header_rec.deliver_to_contact_id);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.deliver_to_org_id:'|| p_header_rec.deliver_to_org_id );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.demand_class_code:'|| p_header_rec.demand_class_code);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.earliest_schedule_limit:'|| p_header_rec.earliest_schedule_limit);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.expiration_date:'|| p_header_rec.expiration_date);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.fob_point_code:'|| p_header_rec.fob_point_code);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.freight_carrier_code:'|| p_header_rec.freight_carrier_code);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.freight_terms_code:'|| p_header_rec.freight_terms_code);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute1:'|| p_header_rec.global_attribute1);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute10:'|| p_header_rec.global_attribute10);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute11:'|| p_header_rec.global_attribute11);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute12:'|| p_header_rec.global_attribute12);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute13:'|| p_header_rec.global_attribute13);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute14:'|| p_header_rec.global_attribute14) ;
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute15:'|| p_header_rec.global_attribute15);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute16:'|| p_header_rec.global_attribute16);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute17:'|| p_header_rec.global_attribute17);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute18:'|| p_header_rec.global_attribute18);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute19:'|| p_header_rec.global_attribute19);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute20:'|| p_header_rec.global_attribute20);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute2:'|| p_header_rec.global_attribute2);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute3:'|| p_header_rec.global_attribute3);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute4:'|| p_header_rec.global_attribute4);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute5:'|| p_header_rec.global_attribute5);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute6:'|| p_header_rec.global_attribute6);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute7:'|| p_header_rec.global_attribute7);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute8:'|| p_header_rec.global_attribute8);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute9:'|| p_header_rec.global_attribute9);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.global_attribute_category:'|| p_header_rec.global_attribute_category );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_CONTEXT:'|| p_header_rec.TP_CONTEXT);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE1:'|| p_header_rec.TP_ATTRIBUTE1);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE2:'|| p_header_rec.TP_ATTRIBUTE2);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE3:'|| p_header_rec.TP_ATTRIBUTE3);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE4:'|| p_header_rec.TP_ATTRIBUTE4);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE5:'|| p_header_rec.TP_ATTRIBUTE5);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE6:'|| p_header_rec.TP_ATTRIBUTE6);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE7:'|| p_header_rec.TP_ATTRIBUTE7);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE8:'|| p_header_rec.TP_ATTRIBUTE8);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE9:'|| p_header_rec.TP_ATTRIBUTE9);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE10:'|| p_header_rec.TP_ATTRIBUTE10);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE11:'|| p_header_rec.TP_ATTRIBUTE11);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE12:'|| p_header_rec.TP_ATTRIBUTE12);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE13:'|| p_header_rec.TP_ATTRIBUTE13);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE14:'|| p_header_rec.TP_ATTRIBUTE14);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.TP_ATTRIBUTE15:'|| p_header_rec.TP_ATTRIBUTE15);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.header_id:'|| p_header_rec.header_id);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.invoice_to_contact_id:'|| p_header_rec.invoice_to_contact_id);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.invoice_to_org_id:'|| p_header_rec.invoice_to_org_id);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.invoicing_rule_id:'|| p_header_rec.invoicing_rule_id);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.latest_schedule_limit:'|| p_header_rec.latest_schedule_limit);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.open_flag:'|| p_header_rec.open_flag );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.order_category_code:'|| p_header_rec.order_category_code);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.ordered_date:'|| p_header_rec.ordered_date);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.order_date_type_code:'|| p_header_rec.order_date_type_code );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.order_number:'|| p_header_rec.order_number);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.order_source_id:'|| p_header_rec.order_source_id);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.order_type_id:'|| p_header_rec.order_type_id  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.org_id:'|| p_header_rec.org_id  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.orig_sys_document_ref:'|| p_header_rec.orig_sys_document_ref );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.partial_shipments_allowed:'|| p_header_rec.partial_shipments_allowed );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.payment_term_id:'|| p_header_rec.payment_term_id  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.price_list_id:'|| p_header_rec.price_list_id );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.pricing_date:'|| p_header_rec.pricing_date );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.program_application_id:'|| p_header_rec.program_application_id);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.program_id:'|| p_header_rec.program_id );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.program_update_date:'|| p_header_rec.program_update_date );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.request_date:'|| p_header_rec.request_date    );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.request_id:'|| p_header_rec.request_id  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.return_reason_code:'|| p_header_rec.return_reason_code);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.salesrep_id:'|| p_header_rec.salesrep_id	 );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.sales_channel_code:'|| p_header_rec.sales_channel_code );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.shipment_priority_code:'|| p_header_rec.shipment_priority_code  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.shipping_method_code:'|| p_header_rec.shipping_method_code );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.ship_from_org_id:'|| p_header_rec.ship_from_org_id  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.ship_tolerance_above:'|| p_header_rec.ship_tolerance_above );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.ship_tolerance_below:'|| p_header_rec.ship_tolerance_below  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.ship_to_contact_id:'|| p_header_rec.ship_to_contact_id );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.ship_to_org_id:'|| p_header_rec.ship_to_org_id );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.sold_from_org_id:'|| p_header_rec.sold_from_org_id);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.sold_to_contact_id:'|| p_header_rec.sold_to_contact_id);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.sold_to_org_id:'|| p_header_rec.sold_to_org_id );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.source_document_id:'|| p_header_rec.source_document_id  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.source_document_type_id:'|| p_header_rec.source_document_type_id  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.tax_exempt_flag:'|| p_header_rec.tax_exempt_flag );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.tax_exempt_number:'|| p_header_rec.tax_exempt_number);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.tax_exempt_reason_code:'|| p_header_rec.tax_exempt_reason_code);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.tax_point_code:'|| p_header_rec.tax_point_code );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.transactional_curr_code:'|| p_header_rec.transactional_curr_code);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.version_number:'|| p_header_rec.version_number );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.return_status:'|| p_header_rec.return_status );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.db_flag:'|| p_header_rec.db_flag  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.operation:'|| p_header_rec.operation  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.first_ack_code:'|| p_header_rec.first_ack_code );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.first_ack_date:'|| p_header_rec.first_ack_date  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.last_ack_code:'|| p_header_rec.last_ack_code );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.last_ack_date:'|| p_header_rec.last_ack_date );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.change_reason:'|| p_header_rec.change_reason );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.change_comments:'|| p_header_rec.change_comments  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.change_sequence:'|| p_header_rec.change_sequence );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.change_request_code:'|| p_header_rec.change_request_code);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.ready_flag:'|| p_header_rec.ready_flag);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.status_flag:'|| p_header_rec.status_flag);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.force_apply_flag:'|| p_header_rec.force_apply_flag );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.drop_ship_flag:'|| p_header_rec.drop_ship_flag );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.customer_payment_term_id:'|| p_header_rec.customer_payment_term_id );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.payment_type_code:'|| p_header_rec.payment_type_code );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.payment_amount:'|| p_header_rec.payment_amount  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.check_number:'|| p_header_rec.check_number );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.credit_card_code:'|| p_header_rec.credit_card_code  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.credit_card_holder_name:'|| p_header_rec.credit_card_holder_name  );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.credit_card_number:'|| p_header_rec.credit_card_number );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.credit_card_expiration_date:'|| p_header_rec.credit_card_expiration_date );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.credit_card_approval_code:'|| p_header_rec.credit_card_approval_code );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.shipping_instructions:'|| p_header_rec.shipping_instructions);
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.packing_instructions:'|| p_header_rec.packing_instructions );
 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_rec.flow_status_code:'|| p_header_rec.flow_status_code  );
         End If;

     x_header_type := SYSTEM.ASO_Header_Type(
p_header_rec.accounting_rule_id
, p_header_rec.agreement_id
, p_header_rec.attribute1
, p_header_rec.attribute10
, p_header_rec.attribute11
, p_header_rec.attribute12
, p_header_rec.attribute13
, p_header_rec.attribute14
, p_header_rec.attribute15
, p_header_rec.attribute2
, p_header_rec.attribute3
, p_header_rec.attribute4
, p_header_rec.attribute5
, p_header_rec.attribute6
, p_header_rec.attribute7
, p_header_rec.attribute8
, p_header_rec.attribute9
, p_header_rec.booked_flag
, p_header_rec.cancelled_flag
, p_header_rec.context
, p_header_rec.conversion_rate
, p_header_rec.conversion_rate_date
, p_header_rec.conversion_type_code
, p_header_rec.created_by
, p_header_rec.creation_date
, p_header_rec.cust_po_number
, p_header_rec.deliver_to_contact_id
, p_header_rec.deliver_to_org_id
, p_header_rec.demand_class_code
, p_header_rec.earliest_schedule_limit
, p_header_rec.expiration_date
, p_header_rec.fob_point_code
, p_header_rec.freight_carrier_code
, p_header_rec.freight_terms_code
, p_header_rec.global_attribute1
, p_header_rec.global_attribute10
, p_header_rec.global_attribute11
, p_header_rec.global_attribute12
, p_header_rec.global_attribute13
, p_header_rec.global_attribute14
, p_header_rec.global_attribute15
, p_header_rec.global_attribute16
, p_header_rec.global_attribute17
, p_header_rec.global_attribute18
, p_header_rec.global_attribute19
, p_header_rec.global_attribute2
, p_header_rec.global_attribute20
, p_header_rec.global_attribute3
, p_header_rec.global_attribute4
, p_header_rec.global_attribute5
, p_header_rec.global_attribute6
, p_header_rec.global_attribute7
, p_header_rec.global_attribute8
, p_header_rec.global_attribute9
, p_header_rec.global_attribute_category
, p_header_rec.TP_CONTEXT
, p_header_rec.TP_ATTRIBUTE1
, p_header_rec.TP_ATTRIBUTE2
, p_header_rec.TP_ATTRIBUTE3
, p_header_rec.TP_ATTRIBUTE4
, p_header_rec.TP_ATTRIBUTE5
, p_header_rec.TP_ATTRIBUTE6
, p_header_rec.TP_ATTRIBUTE7
, p_header_rec.TP_ATTRIBUTE8
, p_header_rec.TP_ATTRIBUTE9
, p_header_rec.TP_ATTRIBUTE10
, p_header_rec.TP_ATTRIBUTE11
, p_header_rec.TP_ATTRIBUTE12
, p_header_rec.TP_ATTRIBUTE13
, p_header_rec.TP_ATTRIBUTE14
, p_header_rec.TP_ATTRIBUTE15
, p_header_rec.header_id
, p_header_rec.invoice_to_contact_id
, p_header_rec.invoice_to_org_id
, p_header_rec.invoicing_rule_id
, p_header_rec.last_updated_by
, p_header_rec.last_update_date
, p_header_rec.last_update_login
, p_header_rec.latest_schedule_limit
, p_header_rec.open_flag
, p_header_rec.order_category_code
, p_header_rec.ordered_date
, p_header_rec.order_date_type_code
, p_header_rec.order_number
, p_header_rec.order_source_id
, p_header_rec.order_type_id
, p_header_rec.org_id
, p_header_rec.orig_sys_document_ref
, p_header_rec.partial_shipments_allowed
, p_header_rec.payment_term_id
, p_header_rec.price_list_id
, p_header_rec.pricing_date
, p_header_rec.program_application_id
, p_header_rec.program_id
, p_header_rec.program_update_date
, p_header_rec.request_date
, p_header_rec.request_id
, p_header_rec.return_reason_code
, p_header_rec.salesrep_id
, p_header_rec.sales_channel_code
, p_header_rec.shipment_priority_code
, p_header_rec.shipping_method_code
, p_header_rec.ship_from_org_id
, p_header_rec.ship_tolerance_above
, p_header_rec.ship_tolerance_below
, p_header_rec.ship_to_contact_id
, p_header_rec.ship_to_org_id
, p_header_rec.sold_from_org_id
, p_header_rec.sold_to_contact_id
, p_header_rec.sold_to_org_id
, p_header_rec.source_document_id
, p_header_rec.source_document_type_id
, p_header_rec.tax_exempt_flag
, p_header_rec.tax_exempt_number
, p_header_rec.tax_exempt_reason_code
, p_header_rec.tax_point_code
, p_header_rec.transactional_curr_code
, p_header_rec.version_number
, p_header_rec.return_status
, p_header_rec.db_flag
, p_header_rec.operation
, p_header_rec.first_ack_code
, p_header_rec.first_ack_date
, p_header_rec.last_ack_code
, p_header_rec.last_ack_date
, p_header_rec.change_reason
, p_header_rec.change_comments
, p_header_rec.change_sequence
, p_header_rec.change_request_code
, p_header_rec.ready_flag
, p_header_rec.status_flag
, p_header_rec.force_apply_flag
, p_header_rec.drop_ship_flag
, p_header_rec.customer_payment_term_id
, p_header_rec.payment_type_code
, p_header_rec.payment_amount
, p_header_rec.check_number
, p_header_rec.credit_card_code
, p_header_rec.credit_card_holder_name
, p_header_rec.credit_card_number
, p_header_rec.credit_card_expiration_date
, p_header_rec.credit_card_approval_code
, p_header_rec.shipping_instructions
, p_header_rec.packing_instructions
, p_header_rec.flow_status_code
);

END ASO_Header_Rec_To_Type;

PROCEDURE ASO_Header_Adj_Tbl_To_Var
(
    p_header_adj_tbl_type	IN	OE_Order_PUB.Header_Adj_Tbl_Type,
    x_header_adj_var_type  OUT NOCOPY /* file.sql.39 change */   	SYSTEM.ASO_Header_Adj_Var_Type
)
IS
    l_header_adj_type              SYSTEM.ASO_Header_Adj_Type;
    i                              NUMBER;
    j                              NUMBER := 1;
BEGIN
        IF p_header_adj_tbl_type.COUNT = 0 THEN
		 return;
        END IF;

        i := p_header_adj_tbl_type.FIRST;
        WHILE i IS NOT NULL LOOP
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute1:'||p_header_adj_tbl_type(i).attribute1,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute10:'||p_header_adj_tbl_type(i).attribute10,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute11:'||p_header_adj_tbl_type(i).attribute11,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute12:'||p_header_adj_tbl_type(i).attribute12,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute13:'||p_header_adj_tbl_type(i).attribute13,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute14:'||p_header_adj_tbl_type(i).attribute14,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute15:'||p_header_adj_tbl_type(i).attribute15,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute2:'||p_header_adj_tbl_type(i).attribute2,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute3:'||p_header_adj_tbl_type(i).attribute3,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute4:'||p_header_adj_tbl_type(i).attribute4,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute5:'||p_header_adj_tbl_type(i).attribute5,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute6:'||p_header_adj_tbl_type(i).attribute6,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute7:'||p_header_adj_tbl_type(i).attribute7,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute8:'||p_header_adj_tbl_type(i).attribute8,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.attribute9:'||p_header_adj_tbl_type(i).attribute9,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.context:'||p_header_adj_tbl_type(i).context,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.automatic_flag:'||p_header_adj_tbl_type(i).automatic_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.created_by:'||p_header_adj_tbl_type(i).created_by,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.creation_date:'||p_header_adj_tbl_type(i).creation_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.discount_id:'||p_header_adj_tbl_type(i).discount_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.discount_line_id:'||p_header_adj_tbl_type(i).discount_line_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.last_updated_by:'||p_header_adj_tbl_type(i).last_updated_by,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.last_update_date:'||p_header_adj_tbl_type(i).last_update_date,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.last_update_login:'||p_header_adj_tbl_type(i).last_update_login,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.line_id:'||p_header_adj_tbl_type(i).line_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.percent:'||p_header_adj_tbl_type(i).percent,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.price_adjustment_id:'||p_header_adj_tbl_type(i).price_adjustment_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.program_application_id:'||p_header_adj_tbl_type(i).program_application_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.program_id:'||p_header_adj_tbl_type(i).program_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.request_id:'||p_header_adj_tbl_type(i).request_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.return_status:'||p_header_adj_tbl_type(i).return_status,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.db_flag:'||p_header_adj_tbl_type(i).db_flag,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.operation:'||p_header_adj_tbl_type(i).operation,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.orig_sys_discount_ref:'||p_header_adj_tbl_type(i).orig_sys_discount_ref,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.change_request_code:'||p_header_adj_tbl_type(i).change_request_code,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.status_flag:'||p_header_adj_tbl_type(i).status_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.list_header_id:'||p_header_adj_tbl_type(i).list_header_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.list_line_id:'||p_header_adj_tbl_type(i).list_line_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.list_line_type_code:'||p_header_adj_tbl_type(i).list_line_type_code,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.modifier_mechanism_type_code:'||p_header_adj_tbl_type(i).modifier_mechanism_type_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.updated_flag:'||p_header_adj_tbl_type(i).updated_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.update_allowed:'||p_header_adj_tbl_type(i).update_allowed,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.applied_flag:'||p_header_adj_tbl_type(i).applied_flag,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.change_reason_code:'||p_header_adj_tbl_type(i).change_reason_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.change_reason_text:'||p_header_adj_tbl_type(i).change_reason_text,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.operand:'||p_header_adj_tbl_type(i).operand,1,'Y');
	     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.arithmetic_operator:'||p_header_adj_tbl_type(i).arithmetic_operator,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.cost_id:'||p_header_adj_tbl_type(i).cost_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.tax_code:'||p_header_adj_tbl_type(i).tax_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.tax_exempt_flag:'||p_header_adj_tbl_type(i).tax_exempt_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.tax_exempt_number:'||p_header_adj_tbl_type(i).tax_exempt_number,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.tax_exempt_reason_code:'||p_header_adj_tbl_type(i).tax_exempt_reason_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.parent_adjustment_id:'||p_header_adj_tbl_type(i).parent_adjustment_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.invoiced_flag:'||p_header_adj_tbl_type(i).invoiced_flag,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.estimated_flag:'||p_header_adj_tbl_type(i).estimated_flag,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.inc_in_sales_performance:'||p_header_adj_tbl_type(i).inc_in_sales_performance,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.split_action_code:'||p_header_adj_tbl_type(i).split_action_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.adjusted_amount:'||p_header_adj_tbl_type(i).adjusted_amount,1,'Y');
	     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_tbl_type('||i||')'||'.pricing_phase_id:'||p_header_adj_tbl_type(i).pricing_phase_id,1,'Y');



        END IF;

        l_header_adj_type := SYSTEM.ASO_Header_Adj_Type
( p_header_adj_tbl_type(i).attribute1
, p_header_adj_tbl_type(i).attribute10
, p_header_adj_tbl_type(i).attribute11
, p_header_adj_tbl_type(i).attribute12
, p_header_adj_tbl_type(i).attribute13
, p_header_adj_tbl_type(i).attribute14
, p_header_adj_tbl_type(i).attribute15
, p_header_adj_tbl_type(i).attribute2
, p_header_adj_tbl_type(i).attribute3
, p_header_adj_tbl_type(i).attribute4
, p_header_adj_tbl_type(i).attribute5
, p_header_adj_tbl_type(i).attribute6
, p_header_adj_tbl_type(i).attribute7
, p_header_adj_tbl_type(i).attribute8
, p_header_adj_tbl_type(i).attribute9
, p_header_adj_tbl_type(i).automatic_flag
, p_header_adj_tbl_type(i).context
, p_header_adj_tbl_type(i).created_by
, p_header_adj_tbl_type(i).creation_date
, p_header_adj_tbl_type(i).discount_id
, p_header_adj_tbl_type(i).discount_line_id
, p_header_adj_tbl_type(i).header_id
, p_header_adj_tbl_type(i).last_updated_by
, p_header_adj_tbl_type(i).last_update_date
, p_header_adj_tbl_type(i).last_update_login
, p_header_adj_tbl_type(i).line_id
, p_header_adj_tbl_type(i).percent
, p_header_adj_tbl_type(i).price_adjustment_id
, p_header_adj_tbl_type(i).program_application_id
, p_header_adj_tbl_type(i).program_id
, p_header_adj_tbl_type(i).program_update_date
, p_header_adj_tbl_type(i).request_id
, p_header_adj_tbl_type(i).return_status
, p_header_adj_tbl_type(i).db_flag
, p_header_adj_tbl_type(i).operation
, p_header_adj_tbl_type(i).orig_sys_discount_ref
, p_header_adj_tbl_type(i).change_request_code
, p_header_adj_tbl_type(i).status_flag
, p_header_adj_tbl_type(i).list_header_id
, p_header_adj_tbl_type(i).list_line_id
, p_header_adj_tbl_type(i).list_line_type_code
, p_header_adj_tbl_type(i).modifier_mechanism_type_code
, p_header_adj_tbl_type(i).modified_from
, p_header_adj_tbl_type(i).modified_to
, p_header_adj_tbl_type(i).updated_flag
, p_header_adj_tbl_type(i).update_allowed
, p_header_adj_tbl_type(i).applied_flag
, p_header_adj_tbl_type(i).change_reason_code
, p_header_adj_tbl_type(i).change_reason_text
, p_header_adj_tbl_type(i).operand
, p_header_adj_tbl_type(i).arithmetic_operator
, p_header_adj_tbl_type(i).cost_id
, p_header_adj_tbl_type(i).tax_code
, p_header_adj_tbl_type(i).tax_exempt_flag
, p_header_adj_tbl_type(i).tax_exempt_number
, p_header_adj_tbl_type(i).tax_exempt_reason_code
, p_header_adj_tbl_type(i).parent_adjustment_id
, p_header_adj_tbl_type(i).invoiced_flag
, p_header_adj_tbl_type(i).estimated_flag
, p_header_adj_tbl_type(i).inc_in_sales_performance
, p_header_adj_tbl_type(i).split_action_code
, p_header_adj_tbl_type(i).adjusted_amount
, p_header_adj_tbl_type(i).pricing_phase_id
);
IF i =  p_header_adj_tbl_type.FIRST then
  x_header_adj_var_type := SYSTEM.ASO_Header_Adj_Var_Type(l_header_adj_type);
ELSE
  x_header_adj_var_type.EXTEND;
  x_header_adj_var_type(j) := l_header_adj_type;
END IF;
j := j + 1;
i := p_header_adj_tbl_type.NEXT(i);
END LOOP;
END ASO_Header_Adj_Tbl_To_Var;


PROCEDURE ASO_Header_Adj_Assoc_Tbl_T_Var
(
    p_header_adj_assoc_tbl_type IN        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
    x_header_adj_assoc_var_type OUT NOCOPY /* file.sql.39 change */         SYSTEM.ASO_Header_Adj_Assoc_Var_Type
)
IS
l_header_adj_assoc_type                   SYSTEM.ASO_Header_Adj_Assoc_Type;
i                                         NUMBER;
j                                         NUMBER :=  1;
BEGIN
    IF p_header_adj_assoc_tbl_type.count = 0  THEN
       return;
    END IF;

    i  :=  p_header_adj_assoc_tbl_type.FIRST;

    WHILE i IS NOT NULL LOOP
  	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT Printing the value  before type conversion for ASO_Header_Adj_Assoc_Tbl_T_Var('||i||')' ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_assoc_tbl_type('||i||')'||'.price_adj_assoc_id :'||p_header_adj_assoc_tbl_type(i).price_adj_assoc_id ,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_assoc_tbl_type('||i||')'||'.line_id:'||p_header_adj_assoc_tbl_type(i).line_id,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_assoc_tbl_type('||i||')'||'.Line_Index:'||p_header_adj_assoc_tbl_type(i).Line_Index,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_assoc_tbl_type('||i||')'||'.price_adj_assoc_id :'||p_header_adj_assoc_tbl_type(i).price_adj_assoc_id ,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_assoc_tbl_type('||i||')'||'.line_id:'||p_header_adj_assoc_tbl_type(i).line_id,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_assoc_tbl_type('||i||')'||'.Line_Index:'||p_header_adj_assoc_tbl_type(i).Line_Index,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_assoc_tbl_type('||i||')'||'.Adj_index   :'||p_header_adj_assoc_tbl_type(i).Adj_index ,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_assoc_tbl_type('||i||')'||'.request_id  :'||p_header_adj_assoc_tbl_type(i).request_id  ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_assoc_tbl_type('||i||')'||'.return_status:'||p_header_adj_assoc_tbl_type(i).return_status,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_assoc_tbl_type('||i||')'||'.db_flag  :'||p_header_adj_assoc_tbl_type(i).db_flag ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_adj_assoc_tbl_type('||i||')'||'.operation:'||p_header_adj_assoc_tbl_type(i).operation,1,'Y');
	  End If;
      l_header_adj_assoc_type := SYSTEM.ASO_Header_Adj_Assoc_Type
                                ( p_header_adj_assoc_tbl_type(i).price_adj_assoc_id
                                , p_header_adj_assoc_tbl_type(i).line_id
                                , p_header_adj_assoc_tbl_type(i).Line_Index
                                , p_header_adj_assoc_tbl_type(i).price_adjustment_id
                                , p_header_adj_assoc_tbl_type(i).Adj_index
                                , p_header_adj_assoc_tbl_type(i).creation_date
                                , p_header_adj_assoc_tbl_type(i).created_by
                                , p_header_adj_assoc_tbl_type(i).last_update_date
                                , p_header_adj_assoc_tbl_type(i).last_updated_by
                                , p_header_adj_assoc_tbl_type(i).last_update_login
                                , p_header_adj_assoc_tbl_type(i).program_application_id
                                , p_header_adj_assoc_tbl_type(i).program_id
                                , p_header_adj_assoc_tbl_type(i).program_update_date
                                , p_header_adj_assoc_tbl_type(i).request_id
                                , p_header_adj_assoc_tbl_type(i).return_status
                                , p_header_adj_assoc_tbl_type(i).db_flag
                                , p_header_adj_assoc_tbl_type(i).operation
                                );


      IF i = p_header_adj_assoc_tbl_type.FIRST then
         x_header_adj_assoc_var_type := SYSTEM.ASO_Header_Adj_Assoc_Var_Type
								(l_header_adj_assoc_type);
      ELSE
         x_header_adj_assoc_var_type.EXTEND;
         x_header_adj_assoc_var_type(j) :=  l_header_adj_assoc_type;
      END IF;
	 j := j + 1;
      i  := p_header_adj_assoc_tbl_type.NEXT(i);
      END LOOP;
END ASO_Header_Adj_Assoc_Tbl_T_Var;

PROCEDURE ASO_Header_Adj_Att_Tbl_To_Var
(
   p_header_adj_att_tbl_type  IN  OE_Order_PUB.Header_Adj_Att_Tbl_Type,
   x_header_adj_att_var_type  OUT NOCOPY /* file.sql.39 change */   SYSTEM.ASO_Header_Adj_Att_Var_Type
)
IS
   l_header_adj_att_type          SYSTEM.ASO_Header_Adj_Att_Type;
   i                              NUMBER;
   j                              NUMBER := 1;
BEGIN
    IF p_header_adj_att_tbl_type.COUNT = 0 THEN
       return;
    END IF;

    i  := p_header_adj_att_tbl_type.FIRST;

    WHILE i IS NOT NULL LOOP
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT Printing the value  before type conversion for ASO_Header_Adj_Att_Tbl_To_Var('||i||')' ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.price_adj_attrib_id :'|| p_header_adj_att_tbl_type(i).price_adj_attrib_id ,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.price_adjustment_id  :'||  p_header_adj_att_tbl_type(i).price_adjustment_id  ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.Adj_index :'|| p_header_adj_att_tbl_type(i).Adj_index ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.flex_title :'|| p_header_adj_att_tbl_type(i).flex_title ,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.pricing_context  :'||  p_header_adj_att_tbl_type(i).pricing_context  ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.pricing_attribute :'|| p_header_adj_att_tbl_type(i).pricing_attribute ,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.request_id  :'||  p_header_adj_att_tbl_type(i).request_id  ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.pricing_attr_value_from :'|| p_header_adj_att_tbl_type(i).pricing_attr_value_from ,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.pricing_attr_value_to  :'||  p_header_adj_att_tbl_type(i).pricing_attr_value_to  ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.comparison_operator :'|| p_header_adj_att_tbl_type(i).comparison_operator ,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.return_status  :'||  p_header_adj_att_tbl_type(i).return_status  ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.db_flag :'|| p_header_adj_att_tbl_type(i).db_flag ,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT   p_header_adj_att_tbl_type('||i||')'||'.operation  :'||  p_header_adj_att_tbl_type(i).operation  ,1,'Y');

    End if;
l_header_adj_att_type  := SYSTEM.ASO_Header_Adj_Att_Type
( p_header_adj_att_tbl_type(i).price_adj_attrib_id
, p_header_adj_att_tbl_type(i).price_adjustment_id
, p_header_adj_att_tbl_type(i).Adj_index
, p_header_adj_att_tbl_type(i).flex_title
, p_header_adj_att_tbl_type(i).pricing_context
, p_header_adj_att_tbl_type(i).pricing_attribute
, p_header_adj_att_tbl_type(i).creation_date
, p_header_adj_att_tbl_type(i).created_by
, p_header_adj_att_tbl_type(i).last_update_date
, p_header_adj_att_tbl_type(i).last_updated_by
, p_header_adj_att_tbl_type(i).last_update_login
, p_header_adj_att_tbl_type(i).program_application_id
, p_header_adj_att_tbl_type(i).program_id
, p_header_adj_att_tbl_type(i).program_update_date
, p_header_adj_att_tbl_type(i).request_id
, p_header_adj_att_tbl_type(i).pricing_attr_value_from
, p_header_adj_att_tbl_type(i).pricing_attr_value_to
, p_header_adj_att_tbl_type(i).comparison_operator
, p_header_adj_att_tbl_type(i).return_status
, p_header_adj_att_tbl_type(i).db_flag
, p_header_adj_att_tbl_type(i).operation
);
    IF i = p_header_adj_att_tbl_type.FIRST THEN
       x_header_adj_att_var_type := SYSTEM.ASO_Header_Adj_Att_Var_Type(l_header_adj_att_type);
    ELSE
    x_header_adj_att_var_type.EXTEND;
    x_header_adj_att_var_type(j) :=  l_header_adj_att_type;
    END IF;
    j := j + 1;
    i  := p_header_adj_att_tbl_type.NEXT(i);
    END LOOP;
END ASO_Header_Adj_Att_Tbl_To_Var;

PROCEDURE ASO_Header_Price_Tbl_To_Var
(
   p_header_price_att_tbl_type  IN  OE_Order_PUB.Header_Price_Att_Tbl_Type,
   x_header_price_att_var_type  OUT NOCOPY /* file.sql.39 change */   SYSTEM.ASO_Header_Price_Att_Var_Type
)
IS
   l_header_price_att_type          SYSTEM.ASO_Header_Price_Att_Type;
   i                                NUMBER;
   j                                NUMBER := 1;
BEGIN
    IF p_header_price_att_tbl_type.COUNT = 0 THEN
       return;
    END IF;

    i    := p_header_price_att_tbl_type.FIRST;
    WHILE i IS NOT NULL LOOP
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT Printing the value  before type conversion for ASO_Header_Price_Tbl_To_Var('||i||')' ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.order_price_attrib_id :'||p_header_price_att_tbl_type(i).order_price_attrib_id ,1,'Y');
	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.header_id:'||p_header_price_att_tbl_type(i).header_id,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.line_id :'||p_header_price_att_tbl_type(i).line_id ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.request_id :'||p_header_price_att_tbl_type(i).request_id ,1,'Y');
	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.flex_title:'||p_header_price_att_tbl_type(i).flex_title,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.request_id :'||p_header_price_att_tbl_type(i).request_id ,1,'Y');
	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.flex_title:'||p_header_price_att_tbl_type(i).flex_title,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_context:'||p_header_price_att_tbl_type(i).pricing_context,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute1:'||p_header_price_att_tbl_type(i).pricing_attribute1	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute2:'||p_header_price_att_tbl_type(i).pricing_attribute2	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute3:'||p_header_price_att_tbl_type(i).pricing_attribute3	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute4:'||p_header_price_att_tbl_type(i).pricing_attribute4	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute5:'||p_header_price_att_tbl_type(i).pricing_attribute5	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute6:'||p_header_price_att_tbl_type(i).pricing_attribute6	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute7:'||p_header_price_att_tbl_type(i).pricing_attribute7	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute8:'||p_header_price_att_tbl_type(i).pricing_attribute8	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute9:'||p_header_price_att_tbl_type(i).pricing_attribute9	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute10:'||p_header_price_att_tbl_type(i).pricing_attribute10	,1,'Y');


      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute11:'||p_header_price_att_tbl_type(i).pricing_attribute11	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute12:'||p_header_price_att_tbl_type(i).pricing_attribute12	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute13:'||p_header_price_att_tbl_type(i).pricing_attribute13	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute14:'||p_header_price_att_tbl_type(i).pricing_attribute14	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute15:'||p_header_price_att_tbl_type(i).pricing_attribute15	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute16:'||p_header_price_att_tbl_type(i).pricing_attribute16	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute17:'||p_header_price_att_tbl_type(i).pricing_attribute17	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute18:'||p_header_price_att_tbl_type(i).pricing_attribute18	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute19:'||p_header_price_att_tbl_type(i).pricing_attribute19	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute20:'||p_header_price_att_tbl_type(i).pricing_attribute20	,1,'Y');


      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute21:'||p_header_price_att_tbl_type(i).pricing_attribute21	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute22:'||p_header_price_att_tbl_type(i).pricing_attribute22	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute23:'||p_header_price_att_tbl_type(i).pricing_attribute23	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute24:'||p_header_price_att_tbl_type(i).pricing_attribute24	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute25:'||p_header_price_att_tbl_type(i).pricing_attribute25	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute26:'||p_header_price_att_tbl_type(i).pricing_attribute26	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute27:'||p_header_price_att_tbl_type(i).pricing_attribute27	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute28:'||p_header_price_att_tbl_type(i).pricing_attribute28	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute29:'||p_header_price_att_tbl_type(i).pricing_attribute29	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute30:'||p_header_price_att_tbl_type(i).pricing_attribute30	,1,'Y');


      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute31:'||p_header_price_att_tbl_type(i).pricing_attribute31	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute32:'||p_header_price_att_tbl_type(i).pricing_attribute32	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute33:'||p_header_price_att_tbl_type(i).pricing_attribute33	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute34:'||p_header_price_att_tbl_type(i).pricing_attribute34	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute35:'||p_header_price_att_tbl_type(i).pricing_attribute35	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute36:'||p_header_price_att_tbl_type(i).pricing_attribute36	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute37:'||p_header_price_att_tbl_type(i).pricing_attribute37	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute38:'||p_header_price_att_tbl_type(i).pricing_attribute38	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute39:'||p_header_price_att_tbl_type(i).pricing_attribute39	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute40:'||p_header_price_att_tbl_type(i).pricing_attribute40	,1,'Y');

      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute41:'||p_header_price_att_tbl_type(i).pricing_attribute41	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute42:'||p_header_price_att_tbl_type(i).pricing_attribute42	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute43:'||p_header_price_att_tbl_type(i).pricing_attribute43	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute44:'||p_header_price_att_tbl_type(i).pricing_attribute44	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute45:'||p_header_price_att_tbl_type(i).pricing_attribute45	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute46:'||p_header_price_att_tbl_type(i).pricing_attribute46	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute47:'||p_header_price_att_tbl_type(i).pricing_attribute47	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute48:'||p_header_price_att_tbl_type(i).pricing_attribute48	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute49:'||p_header_price_att_tbl_type(i).pricing_attribute49	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute50:'||p_header_price_att_tbl_type(i).pricing_attribute50	,1,'Y');


      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute51:'||p_header_price_att_tbl_type(i).pricing_attribute51	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute52:'||p_header_price_att_tbl_type(i).pricing_attribute52	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute53:'||p_header_price_att_tbl_type(i).pricing_attribute53	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute54:'||p_header_price_att_tbl_type(i).pricing_attribute54	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute55:'||p_header_price_att_tbl_type(i).pricing_attribute55	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute56:'||p_header_price_att_tbl_type(i).pricing_attribute56	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute57:'||p_header_price_att_tbl_type(i).pricing_attribute57	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute58:'||p_header_price_att_tbl_type(i).pricing_attribute58	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute59:'||p_header_price_att_tbl_type(i).pricing_attribute59	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute60:'||p_header_price_att_tbl_type(i).pricing_attribute60	,1,'Y');

      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute61:'||p_header_price_att_tbl_type(i).pricing_attribute61	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute62:'||p_header_price_att_tbl_type(i).pricing_attribute62	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute63:'||p_header_price_att_tbl_type(i).pricing_attribute63	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute64:'||p_header_price_att_tbl_type(i).pricing_attribute64	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute65:'||p_header_price_att_tbl_type(i).pricing_attribute65	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute66:'||p_header_price_att_tbl_type(i).pricing_attribute66	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute67:'||p_header_price_att_tbl_type(i).pricing_attribute67	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute68:'||p_header_price_att_tbl_type(i).pricing_attribute68	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute69:'||p_header_price_att_tbl_type(i).pricing_attribute69	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute70:'||p_header_price_att_tbl_type(i).pricing_attribute70	,1,'Y');

      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute71:'||p_header_price_att_tbl_type(i).pricing_attribute71	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute72:'||p_header_price_att_tbl_type(i).pricing_attribute72	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute73:'||p_header_price_att_tbl_type(i).pricing_attribute73	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute74:'||p_header_price_att_tbl_type(i).pricing_attribute74	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute75:'||p_header_price_att_tbl_type(i).pricing_attribute75	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute76:'||p_header_price_att_tbl_type(i).pricing_attribute76	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute77:'||p_header_price_att_tbl_type(i).pricing_attribute77	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute78:'||p_header_price_att_tbl_type(i).pricing_attribute78	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute79:'||p_header_price_att_tbl_type(i).pricing_attribute79	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute80:'||p_header_price_att_tbl_type(i).pricing_attribute80	,1,'Y');

	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute81:'||p_header_price_att_tbl_type(i).pricing_attribute81	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute82:'||p_header_price_att_tbl_type(i).pricing_attribute82	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute83:'||p_header_price_att_tbl_type(i).pricing_attribute83	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute84:'||p_header_price_att_tbl_type(i).pricing_attribute84	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute85:'||p_header_price_att_tbl_type(i).pricing_attribute85	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute86:'||p_header_price_att_tbl_type(i).pricing_attribute86	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute87:'||p_header_price_att_tbl_type(i).pricing_attribute87	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute88:'||p_header_price_att_tbl_type(i).pricing_attribute88	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute89:'||p_header_price_att_tbl_type(i).pricing_attribute89	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute90:'||p_header_price_att_tbl_type(i).pricing_attribute90	,1,'Y');

	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute91:'||p_header_price_att_tbl_type(i).pricing_attribute91	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute92:'||p_header_price_att_tbl_type(i).pricing_attribute92	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute93:'||p_header_price_att_tbl_type(i).pricing_attribute93	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute94:'||p_header_price_att_tbl_type(i).pricing_attribute94	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute95:'||p_header_price_att_tbl_type(i).pricing_attribute95	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute96:'||p_header_price_att_tbl_type(i).pricing_attribute96	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute97:'||p_header_price_att_tbl_type(i).pricing_attribute97	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute98:'||p_header_price_att_tbl_type(i).pricing_attribute98	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute99:'||p_header_price_att_tbl_type(i).pricing_attribute99	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.pricing_attribute100:'||p_header_price_att_tbl_type(i).pricing_attribute100	,1,'Y');

	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.context:'||p_header_price_att_tbl_type(i).context	,1,'Y');
	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute1:'||p_header_price_att_tbl_type(i).attribute1	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute2:'||p_header_price_att_tbl_type(i).attribute2	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute3:'||p_header_price_att_tbl_type(i).attribute3	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute4:'||p_header_price_att_tbl_type(i).attribute4	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute5:'||p_header_price_att_tbl_type(i).attribute5	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute6:'||p_header_price_att_tbl_type(i).attribute6	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute7:'||p_header_price_att_tbl_type(i).attribute7	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute8:'||p_header_price_att_tbl_type(i).attribute8	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute9:'||p_header_price_att_tbl_type(i).attribute9	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute10:'||p_header_price_att_tbl_type(i).attribute10	,1,'Y');


      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute11:'||p_header_price_att_tbl_type(i).attribute11	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute12:'||p_header_price_att_tbl_type(i).attribute12	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute13:'||p_header_price_att_tbl_type(i).attribute13	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute14:'||p_header_price_att_tbl_type(i).attribute14	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.attribute15:'||p_header_price_att_tbl_type(i).attribute15	,1,'Y');
	 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.return_status:'||p_header_price_att_tbl_type(i).return_status	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.db_flag:'||p_header_price_att_tbl_type(i).db_flag	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_price_att_tbl_type('||i||')'||'.operation:'||p_header_price_att_tbl_type(i).operation	,1,'Y');

End If;
l_header_price_att_type := SYSTEM.ASO_Header_Price_Att_Type
( p_header_price_att_tbl_type(i).order_price_attrib_id
, p_header_price_att_tbl_type(i).header_id
, p_header_price_att_tbl_type(i).line_id
, p_header_price_att_tbl_type(i).creation_date
, p_header_price_att_tbl_type(i).created_by
, p_header_price_att_tbl_type(i).last_update_date
, p_header_price_att_tbl_type(i).last_updated_by
, p_header_price_att_tbl_type(i).last_update_login
, p_header_price_att_tbl_type(i).program_application_id
, p_header_price_att_tbl_type(i).program_id
, p_header_price_att_tbl_type(i).program_update_date
, p_header_price_att_tbl_type(i).request_id
, p_header_price_att_tbl_type(i).flex_title
, p_header_price_att_tbl_type(i).pricing_context
, p_header_price_att_tbl_type(i).pricing_attribute1
, p_header_price_att_tbl_type(i).pricing_attribute2
, p_header_price_att_tbl_type(i).pricing_attribute3
, p_header_price_att_tbl_type(i).pricing_attribute4
, p_header_price_att_tbl_type(i).pricing_attribute5
, p_header_price_att_tbl_type(i).pricing_attribute6
, p_header_price_att_tbl_type(i).pricing_attribute7
, p_header_price_att_tbl_type(i).pricing_attribute8
, p_header_price_att_tbl_type(i).pricing_attribute9
, p_header_price_att_tbl_type(i).pricing_attribute10
, p_header_price_att_tbl_type(i).pricing_attribute11
, p_header_price_att_tbl_type(i).pricing_attribute12
, p_header_price_att_tbl_type(i).pricing_attribute13
, p_header_price_att_tbl_type(i).pricing_attribute14
, p_header_price_att_tbl_type(i).pricing_attribute15
, p_header_price_att_tbl_type(i).pricing_attribute16
, p_header_price_att_tbl_type(i).pricing_attribute17
, p_header_price_att_tbl_type(i).pricing_attribute18
, p_header_price_att_tbl_type(i).pricing_attribute19
, p_header_price_att_tbl_type(i).pricing_attribute20
, p_header_price_att_tbl_type(i).pricing_attribute21
, p_header_price_att_tbl_type(i).pricing_attribute22
, p_header_price_att_tbl_type(i).pricing_attribute23
, p_header_price_att_tbl_type(i).pricing_attribute24
, p_header_price_att_tbl_type(i).pricing_attribute25
, p_header_price_att_tbl_type(i).pricing_attribute26
, p_header_price_att_tbl_type(i).pricing_attribute27
, p_header_price_att_tbl_type(i).pricing_attribute28
, p_header_price_att_tbl_type(i).pricing_attribute29
, p_header_price_att_tbl_type(i).pricing_attribute30
, p_header_price_att_tbl_type(i).pricing_attribute31
, p_header_price_att_tbl_type(i).pricing_attribute32
, p_header_price_att_tbl_type(i).pricing_attribute33
, p_header_price_att_tbl_type(i).pricing_attribute34
, p_header_price_att_tbl_type(i).pricing_attribute35
, p_header_price_att_tbl_type(i).pricing_attribute36
, p_header_price_att_tbl_type(i).pricing_attribute37
, p_header_price_att_tbl_type(i).pricing_attribute38
, p_header_price_att_tbl_type(i).pricing_attribute39
, p_header_price_att_tbl_type(i).pricing_attribute40
, p_header_price_att_tbl_type(i).pricing_attribute41
, p_header_price_att_tbl_type(i).pricing_attribute42
, p_header_price_att_tbl_type(i).pricing_attribute43
, p_header_price_att_tbl_type(i).pricing_attribute44
, p_header_price_att_tbl_type(i).pricing_attribute45
, p_header_price_att_tbl_type(i).pricing_attribute46
, p_header_price_att_tbl_type(i).pricing_attribute47
, p_header_price_att_tbl_type(i).pricing_attribute48
, p_header_price_att_tbl_type(i).pricing_attribute49
, p_header_price_att_tbl_type(i).pricing_attribute50
, p_header_price_att_tbl_type(i).pricing_attribute51
, p_header_price_att_tbl_type(i).pricing_attribute52
, p_header_price_att_tbl_type(i).pricing_attribute53
, p_header_price_att_tbl_type(i).pricing_attribute54
, p_header_price_att_tbl_type(i).pricing_attribute55
, p_header_price_att_tbl_type(i).pricing_attribute56
, p_header_price_att_tbl_type(i).pricing_attribute57
, p_header_price_att_tbl_type(i).pricing_attribute58
, p_header_price_att_tbl_type(i).pricing_attribute59
, p_header_price_att_tbl_type(i).pricing_attribute60
, p_header_price_att_tbl_type(i).pricing_attribute61
, p_header_price_att_tbl_type(i).pricing_attribute62
, p_header_price_att_tbl_type(i).pricing_attribute63
, p_header_price_att_tbl_type(i).pricing_attribute64
, p_header_price_att_tbl_type(i).pricing_attribute65
, p_header_price_att_tbl_type(i).pricing_attribute66
, p_header_price_att_tbl_type(i).pricing_attribute67
, p_header_price_att_tbl_type(i).pricing_attribute68
, p_header_price_att_tbl_type(i).pricing_attribute69
, p_header_price_att_tbl_type(i).pricing_attribute70
, p_header_price_att_tbl_type(i).pricing_attribute71
, p_header_price_att_tbl_type(i).pricing_attribute72
, p_header_price_att_tbl_type(i).pricing_attribute73
, p_header_price_att_tbl_type(i).pricing_attribute74
, p_header_price_att_tbl_type(i).pricing_attribute75
, p_header_price_att_tbl_type(i).pricing_attribute76
, p_header_price_att_tbl_type(i).pricing_attribute77
, p_header_price_att_tbl_type(i).pricing_attribute78
, p_header_price_att_tbl_type(i).pricing_attribute79
, p_header_price_att_tbl_type(i).pricing_attribute80
, p_header_price_att_tbl_type(i).pricing_attribute81
, p_header_price_att_tbl_type(i).pricing_attribute82
, p_header_price_att_tbl_type(i).pricing_attribute83
, p_header_price_att_tbl_type(i).pricing_attribute84
, p_header_price_att_tbl_type(i).pricing_attribute85
, p_header_price_att_tbl_type(i).pricing_attribute86
, p_header_price_att_tbl_type(i).pricing_attribute87
, p_header_price_att_tbl_type(i).pricing_attribute88
, p_header_price_att_tbl_type(i).pricing_attribute89
, p_header_price_att_tbl_type(i).pricing_attribute90
, p_header_price_att_tbl_type(i).pricing_attribute91
, p_header_price_att_tbl_type(i).pricing_attribute92
, p_header_price_att_tbl_type(i).pricing_attribute93
, p_header_price_att_tbl_type(i).pricing_attribute94
, p_header_price_att_tbl_type(i).pricing_attribute95
, p_header_price_att_tbl_type(i).pricing_attribute96
, p_header_price_att_tbl_type(i).pricing_attribute97
, p_header_price_att_tbl_type(i).pricing_attribute98
, p_header_price_att_tbl_type(i).pricing_attribute99
, p_header_price_att_tbl_type(i).pricing_attribute100
, p_header_price_att_tbl_type(i).context
, p_header_price_att_tbl_type(i).attribute1
, p_header_price_att_tbl_type(i).attribute2
, p_header_price_att_tbl_type(i).attribute3
, p_header_price_att_tbl_type(i).attribute4
, p_header_price_att_tbl_type(i).attribute5
, p_header_price_att_tbl_type(i).attribute6
, p_header_price_att_tbl_type(i).attribute7
, p_header_price_att_tbl_type(i).attribute8
, p_header_price_att_tbl_type(i).attribute9
, p_header_price_att_tbl_type(i).attribute10
, p_header_price_att_tbl_type(i).attribute11
, p_header_price_att_tbl_type(i).attribute12
, p_header_price_att_tbl_type(i).attribute13
, p_header_price_att_tbl_type(i).attribute14
, p_header_price_att_tbl_type(i).attribute15
, p_header_price_att_tbl_type(i).return_status
, p_header_price_att_tbl_type(i).db_flag
, p_header_price_att_tbl_type(i).operation
);
IF i = p_header_price_att_tbl_type.FIRST then
  x_header_price_att_var_type := SYSTEM.ASO_Header_Price_Att_Var_Type(l_header_price_att_type);
ELSE
  x_header_price_att_var_type.EXTEND;
  x_header_price_att_var_type(j) := l_header_price_att_type;
END IF;
j := j + 1;
i := p_header_price_att_tbl_type.NEXT(i);
END LOOP;
END ASO_Header_Price_Tbl_To_Var;


PROCEDURE ASO_Header_Scredit_Tbl_To_Var
(
   p_header_scredit_tbl_type	IN  OE_Order_PUB.Header_Scredit_Tbl_Type,
   x_header_scredit_var_type OUT NOCOPY /* file.sql.39 change */   SYSTEM.ASO_Header_Scredit_Var_Type
)
IS
   l_header_scredit_type          SYSTEM.ASO_Header_Scredit_Type;
   i                              NUMBER;
   j                              NUMBER := 1;
BEGIN
    IF p_header_scredit_tbl_type.COUNT = 0 THEN
       return;
    END IF;

    i   := p_header_scredit_tbl_type.FIRST;
    WHILE i IS NOT NULL LOOP
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT Printing the value  before type conversion for ASO_Header_Scredit_Tbl_To_Var('||i||')' ,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute1:'||p_header_scredit_tbl_type(i).attribute1	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute10:'||p_header_scredit_tbl_type(i).attribute10	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute11:'||p_header_scredit_tbl_type(i).attribute11	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute12:'||p_header_scredit_tbl_type(i).attribute12	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute13:'||p_header_scredit_tbl_type(i).attribute13	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute14:'||p_header_scredit_tbl_type(i).attribute14	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute15:'||p_header_scredit_tbl_type(i).attribute15	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute2:'||p_header_scredit_tbl_type(i).attribute2	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute3:'||p_header_scredit_tbl_type(i).attribute3	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute4:'||p_header_scredit_tbl_type(i).attribute4	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute5:'||p_header_scredit_tbl_type(i).attribute5	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute6:'||p_header_scredit_tbl_type(i).attribute6	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute7:'||p_header_scredit_tbl_type(i).attribute7	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute8:'||p_header_scredit_tbl_type(i).attribute8	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.attribute9:'||p_header_scredit_tbl_type(i).attribute9	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.context:'||p_header_scredit_tbl_type(i).context	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.dw_update_advice_flag:'||p_header_scredit_tbl_type(i).dw_update_advice_flag	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.header_id:'||p_header_scredit_tbl_type(i).header_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.line_id:'||p_header_scredit_tbl_type(i).line_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.header_id:'||p_header_scredit_tbl_type(i).header_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.line_id:'||p_header_scredit_tbl_type(i).line_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.percent:'||p_header_scredit_tbl_type(i).percent	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.salesrep_id:'||p_header_scredit_tbl_type(i).salesrep_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.sales_credit_id:'||p_header_scredit_tbl_type(i).sales_credit_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.wh_update_date:'||p_header_scredit_tbl_type(i).wh_update_date	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.return_status:'||p_header_scredit_tbl_type(i).return_status	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.db_flag:'||p_header_scredit_tbl_type(i).db_flag	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.operation:'||p_header_scredit_tbl_type(i).operation	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.orig_sys_credit_ref:'||p_header_scredit_tbl_type(i).orig_sys_credit_ref	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.change_request_code:'||p_header_scredit_tbl_type(i).change_request_code	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_header_scredit_tbl_type('||i||')'||'.status_flag:'||p_header_scredit_tbl_type(i).status_flag	,1,'Y');

End if;

l_header_scredit_type := SYSTEM.ASO_Header_Scredit_Type
(  p_header_scredit_tbl_type(i).attribute1
,  p_header_scredit_tbl_type(i).attribute10
,  p_header_scredit_tbl_type(i).attribute11
,  p_header_scredit_tbl_type(i).attribute12
,  p_header_scredit_tbl_type(i).attribute13
,  p_header_scredit_tbl_type(i).attribute14
,  p_header_scredit_tbl_type(i).attribute15
,  p_header_scredit_tbl_type(i).attribute2
,  p_header_scredit_tbl_type(i).attribute3
,  p_header_scredit_tbl_type(i).attribute4
,  p_header_scredit_tbl_type(i).attribute5
,  p_header_scredit_tbl_type(i).attribute6
,  p_header_scredit_tbl_type(i).attribute7
,  p_header_scredit_tbl_type(i).attribute8
,  p_header_scredit_tbl_type(i).attribute9
,  p_header_scredit_tbl_type(i).context
,  p_header_scredit_tbl_type(i).created_by
,  p_header_scredit_tbl_type(i).creation_date
,  p_header_scredit_tbl_type(i).dw_update_advice_flag
,  p_header_scredit_tbl_type(i).header_id
,  p_header_scredit_tbl_type(i).last_updated_by
,  p_header_scredit_tbl_type(i).last_update_date
,  p_header_scredit_tbl_type(i).last_update_login
,  p_header_scredit_tbl_type(i).line_id
,  p_header_scredit_tbl_type(i).percent
,  p_header_scredit_tbl_type(i).salesrep_id
,  p_header_scredit_tbl_type(i).sales_credit_id
,  p_header_scredit_tbl_type(i).wh_update_date
,  p_header_scredit_tbl_type(i).return_status
,  p_header_scredit_tbl_type(i).db_flag
,  p_header_scredit_tbl_type(i).operation
,  p_header_scredit_tbl_type(i).orig_sys_credit_ref
,  p_header_scredit_tbl_type(i).change_request_code
,  p_header_scredit_tbl_type(i).status_flag
);
IF i = p_header_scredit_tbl_type.FIRST then
  x_header_scredit_var_type := SYSTEM.ASO_Header_Scredit_Var_Type(l_header_scredit_type);
ELSE
  x_header_scredit_var_type.EXTEND;
  x_header_scredit_var_type(j) :=  l_header_scredit_type;
END IF;
  j := j + 1;
  i  := p_header_scredit_tbl_type.NEXT(i);
END LOOP;
END ASO_Header_Scredit_Tbl_To_Var;

PROCEDURE ASO_Line_Tbl_To_Var
(
   p_line_tbl_type		IN	OE_Order_PUB.Line_Tbl_Type,
   x_line_var_type	 OUT NOCOPY /* file.sql.39 change */  	SYSTEM.ASO_Line_Var_Type
)
IS
   l_line_type             SYSTEM.ASO_Line_Type;
   l_semi_processed_flag   VARCHAR2(3);
   i                       NUMBER;
   j                       NUMBER := 1;
BEGIN
    IF p_line_tbl_type.COUNT = 0 THEN
       return;
    END IF;

    i  := p_line_tbl_type.FIRST;
    WHILE i IS NOT NULL LOOP
      if p_line_tbl_type(i).semi_processed_flag then
         l_semi_processed_flag := FND_API.G_TRUE;
      elsif p_line_tbl_type(i).semi_processed_flag is null then
         l_semi_processed_flag := NULL;
      else
         l_semi_processed_flag := FND_API.G_FALSE;
         end if;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT Printing the value  before type conversion for ASO_Line_Type('||i||')' ,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.accounting_rule_id:'||p_line_tbl_type(i).accounting_rule_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type(  '||i||')'||'.actual_arrival_date:'||p_line_tbl_type(i).actual_arrival_date,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.actual_shipment_date:'||p_line_tbl_type(i).actual_shipment_date,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.agreement_id:'||p_line_tbl_type(i).agreement_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.arrival_set_id:'||p_line_tbl_type(i).arrival_set_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ato_line_id:'||p_line_tbl_type(i).ato_line_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute1:'||p_line_tbl_type(i).attribute1,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute10:'||p_line_tbl_type(i).attribute10,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute11:'||p_line_tbl_type(i).attribute11,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute12:'||p_line_tbl_type(i).attribute12,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute13:'||p_line_tbl_type(i).attribute13,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute14:'||p_line_tbl_type(i).attribute14,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute15:'||p_line_tbl_type(i).attribute15,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute2:'||p_line_tbl_type(i).attribute2,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute3:'||p_line_tbl_type(i).attribute3,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute4:'||p_line_tbl_type(i).attribute4,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute5:'||p_line_tbl_type(i).attribute5,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute6:'||p_line_tbl_type(i).attribute6,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute7:'||p_line_tbl_type(i).attribute7,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute8:'||p_line_tbl_type(i).attribute8,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.attribute9:'||p_line_tbl_type(i).attribute9,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.context:'||p_line_tbl_type(i).context,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.authorized_to_ship_flag:'||p_line_tbl_type(i).authorized_to_ship_flag,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.auto_selected_quantity:'||p_line_tbl_type(i).auto_selected_quantity,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.booked_flag:'||p_line_tbl_type(i).booked_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.cancelled_flag:'||p_line_tbl_type(i).cancelled_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.cancelled_quantity:'||p_line_tbl_type(i).cancelled_quantity,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.commitment_id:'||p_line_tbl_type(i).commitment_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.component_code:'||p_line_tbl_type(i).component_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.component_number:'||p_line_tbl_type(i).component_number,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.component_sequence_id:'||p_line_tbl_type(i).component_sequence_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.config_header_id:'||p_line_tbl_type(i).config_header_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.config_rev_nbr:'||p_line_tbl_type(i).config_rev_nbr,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.config_display_sequence:'||p_line_tbl_type(i).config_display_sequence,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.configuration_id:'||p_line_tbl_type(i).configuration_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.created_by:'||p_line_tbl_type(i).created_by,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.creation_date:'||p_line_tbl_type(i).creation_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.credit_invoice_line_id:'||p_line_tbl_type(i).credit_invoice_line_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.customer_dock_code:'||p_line_tbl_type(i).customer_dock_code,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.customer_job:'||p_line_tbl_type(i).customer_job,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.customer_production_line:'||p_line_tbl_type(i).customer_production_line,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.customer_trx_line_id:'||p_line_tbl_type(i).customer_trx_line_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.cust_model_serial_number:'||p_line_tbl_type(i).cust_model_serial_number,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.cust_po_number:'||p_line_tbl_type(i).cust_po_number,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.cust_production_seq_num:'||p_line_tbl_type(i).cust_production_seq_num,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.delivery_lead_time:'||p_line_tbl_type(i).delivery_lead_time,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.deliver_to_contact_id:'||p_line_tbl_type(i).deliver_to_contact_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.deliver_to_org_id:'||p_line_tbl_type(i).deliver_to_org_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.demand_bucket_type_code:'||p_line_tbl_type(i).demand_bucket_type_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.demand_class_code:'||p_line_tbl_type(i).demand_class_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.dep_plan_required_flag:'||p_line_tbl_type(i).dep_plan_required_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.earliest_acceptable_date:'||p_line_tbl_type(i).earliest_acceptable_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.end_item_unit_number:'||p_line_tbl_type(i).end_item_unit_number,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.explosion_date:'||p_line_tbl_type(i).explosion_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.fob_point_code:'||p_line_tbl_type(i).fob_point_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.freight_carrier_code:'||p_line_tbl_type(i).freight_carrier_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.freight_terms_code:'||p_line_tbl_type(i).freight_terms_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.fulfilled_quantity:'||p_line_tbl_type(i).fulfilled_quantity,1,'Y');
	     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute1:'||p_line_tbl_type(i).global_attribute1,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute10:'||p_line_tbl_type(i).global_attribute10,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute11:'||p_line_tbl_type(i).global_attribute11,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute12:'||p_line_tbl_type(i).global_attribute12,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute13:'||p_line_tbl_type(i).global_attribute13,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute14:'||p_line_tbl_type(i).global_attribute14,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute15:'||p_line_tbl_type(i).global_attribute15,1,'Y');
	     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute16:'||p_line_tbl_type(i).global_attribute16,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute17:'||p_line_tbl_type(i).global_attribute17,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute18:'||p_line_tbl_type(i).global_attribute18,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute19:'||p_line_tbl_type(i).global_attribute19,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute2:'||p_line_tbl_type(i).global_attribute2,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute3:'||p_line_tbl_type(i).global_attribute3,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute4:'||p_line_tbl_type(i).global_attribute4,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute5:'||p_line_tbl_type(i).global_attribute5,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute6:'||p_line_tbl_type(i).global_attribute6,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute7:'||p_line_tbl_type(i).global_attribute7,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute8:'||p_line_tbl_type(i).global_attribute8,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute9:'||p_line_tbl_type(i).global_attribute9,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute20:'||p_line_tbl_type(i).global_attribute20,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.global_attribute_category:'||p_line_tbl_type(i).global_attribute_category,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.header_id:'||p_line_tbl_type(i).header_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute1:'||p_line_tbl_type(i).industry_attribute1,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute10:'||p_line_tbl_type(i).industry_attribute10,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute11:'||p_line_tbl_type(i).industry_attribute11,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute12:'||p_line_tbl_type(i).industry_attribute12,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute13:'||p_line_tbl_type(i).industry_attribute13,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute14:'||p_line_tbl_type(i).industry_attribute14,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute15:'||p_line_tbl_type(i).industry_attribute15,1,'Y');
	     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute16:'||p_line_tbl_type(i).industry_attribute16,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute17:'||p_line_tbl_type(i).industry_attribute17,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute18:'||p_line_tbl_type(i).industry_attribute18,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute19:'||p_line_tbl_type(i).industry_attribute19,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute2:'||p_line_tbl_type(i).industry_attribute2,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute3:'||p_line_tbl_type(i).industry_attribute3,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute4:'||p_line_tbl_type(i).industry_attribute4,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute5:'||p_line_tbl_type(i).industry_attribute5,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute6:'||p_line_tbl_type(i).industry_attribute6,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute7:'||p_line_tbl_type(i).industry_attribute7,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute8:'||p_line_tbl_type(i).industry_attribute8,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute9:'||p_line_tbl_type(i).industry_attribute9,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute20:'||p_line_tbl_type(i).industry_attribute20,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute21:'||p_line_tbl_type(i).industry_attribute21,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute22:'||p_line_tbl_type(i).industry_attribute22,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute23:'||p_line_tbl_type(i).industry_attribute23,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute24:'||p_line_tbl_type(i).industry_attribute24,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute25:'||p_line_tbl_type(i).industry_attribute25,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute26:'||p_line_tbl_type(i).industry_attribute26,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute27:'||p_line_tbl_type(i).industry_attribute27,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute28:'||p_line_tbl_type(i).industry_attribute28,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute29:'||p_line_tbl_type(i).industry_attribute29,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_attribute30:'||p_line_tbl_type(i).industry_attribute30,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.industry_context:'||p_line_tbl_type(i).industry_context,1,'Y');

	     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE1:'||p_line_tbl_type(i).TP_ATTRIBUTE1,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE10:'||p_line_tbl_type(i).TP_ATTRIBUTE10,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE11:'||p_line_tbl_type(i).TP_ATTRIBUTE11,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE12:'||p_line_tbl_type(i).TP_ATTRIBUTE12,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE13:'||p_line_tbl_type(i).TP_ATTRIBUTE13,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE14:'||p_line_tbl_type(i).TP_ATTRIBUTE14,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE15:'||p_line_tbl_type(i).TP_ATTRIBUTE15,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE2:'||p_line_tbl_type(i).TP_ATTRIBUTE2,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE3:'||p_line_tbl_type(i).TP_ATTRIBUTE3,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE4:'||p_line_tbl_type(i).TP_ATTRIBUTE4,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE5:'||p_line_tbl_type(i).TP_ATTRIBUTE5,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE6:'||p_line_tbl_type(i).TP_ATTRIBUTE6,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE7:'||p_line_tbl_type(i).TP_ATTRIBUTE7,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE8:'||p_line_tbl_type(i).TP_ATTRIBUTE8,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_ATTRIBUTE9:'||p_line_tbl_type(i).TP_ATTRIBUTE9,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.TP_context:'||p_line_tbl_type(i).TP_CONTEXT,1,'Y');

            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.intermed_ship_to_org_id:'||p_line_tbl_type(i).intermed_ship_to_org_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.intermed_ship_to_contact_id:'||p_line_tbl_type(i).intermed_ship_to_contact_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.inventory_item_id:'||p_line_tbl_type(i).inventory_item_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.invoice_interface_status_code:'||p_line_tbl_type(i).invoice_interface_status_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.invoice_to_contact_id:'||p_line_tbl_type(i).invoice_to_contact_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.invoice_to_org_id:'||p_line_tbl_type(i).invoice_to_org_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.invoicing_rule_id:'||p_line_tbl_type(i).invoicing_rule_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ordered_item:'||p_line_tbl_type(i).ordered_item,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.item_revision:'||p_line_tbl_type(i).item_revision,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.item_type_code:'||p_line_tbl_type(i).item_type_code,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.last_updated_by:'||p_line_tbl_type(i).last_updated_by,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.last_update_date:'||p_line_tbl_type(i).last_update_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.last_update_login:'||p_line_tbl_type(i).last_update_login,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.latest_acceptable_date:'||p_line_tbl_type(i).latest_acceptable_date,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.line_category_code:'||p_line_tbl_type(i).line_category_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.line_id:'||p_line_tbl_type(i).line_id,1,'Y');

	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.line_number:'||p_line_tbl_type(i).line_number,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.line_type_id:'||p_line_tbl_type(i).line_type_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.link_to_line_ref:'||p_line_tbl_type(i).link_to_line_ref,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.link_to_line_id:'||p_line_tbl_type(i).link_to_line_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.model_group_number:'||p_line_tbl_type(i).model_group_number,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.mfg_component_sequence_id:'||p_line_tbl_type(i).mfg_component_sequence_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.open_flag:'||p_line_tbl_type(i).open_flag,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.option_flag:'||p_line_tbl_type(i).option_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.option_number:'||p_line_tbl_type(i).option_number,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ordered_quantity:'||p_line_tbl_type(i).ordered_quantity,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.order_quantity_uom:'||p_line_tbl_type(i).order_quantity_uom,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.org_id:'||p_line_tbl_type(i).org_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.orig_sys_document_ref:'||p_line_tbl_type(i).orig_sys_document_ref,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.orig_sys_line_ref:'||p_line_tbl_type(i).orig_sys_line_ref,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.over_ship_reason_code:'||p_line_tbl_type(i).over_ship_reason_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.over_ship_resolved_flag:'||p_line_tbl_type(i).over_ship_resolved_flag,1,'Y');
	     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.payment_term_id:'||p_line_tbl_type(i).payment_term_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.planning_priority:'||p_line_tbl_type(i).planning_priority,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.price_list_id:'||p_line_tbl_type(i).price_list_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_attribute1:'||p_line_tbl_type(i).pricing_attribute1,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_attribute10:'||p_line_tbl_type(i).pricing_attribute10,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_attribute2:'||p_line_tbl_type(i).pricing_attribute2,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_attribute3:'||p_line_tbl_type(i).pricing_attribute3,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_attribute4:'||p_line_tbl_type(i).pricing_attribute4,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_attribute5:'||p_line_tbl_type(i).pricing_attribute5,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_attribute6:'||p_line_tbl_type(i).pricing_attribute6,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_attribute7:'||p_line_tbl_type(i).pricing_attribute7,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_attribute8:'||p_line_tbl_type(i).pricing_attribute8,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_attribute9:'||p_line_tbl_type(i).pricing_attribute9,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_context:'||p_line_tbl_type(i).pricing_context,1,'Y');

	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_date:'||p_line_tbl_type(i).pricing_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_quantity:'||p_line_tbl_type(i).pricing_quantity,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.pricing_quantity_uom:'||p_line_tbl_type(i).pricing_quantity_uom,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.program_application_id:'||p_line_tbl_type(i).program_application_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.program_id:'||p_line_tbl_type(i).program_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.program_update_date:'||p_line_tbl_type(i).program_update_date,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.project_id:'||p_line_tbl_type(i).project_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.promise_date:'||p_line_tbl_type(i).promise_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.re_source_flag:'||p_line_tbl_type(i).re_source_flag,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.reference_customer_trx_line_id:'||p_line_tbl_type(i).reference_customer_trx_line_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.reference_header_id:'||p_line_tbl_type(i).reference_header_id,1,'Y');

	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.reference_line_id:'||p_line_tbl_type(i).reference_line_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.reference_type:'||p_line_tbl_type(i).reference_type,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.request_date:'||p_line_tbl_type(i).request_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.request_id:'||p_line_tbl_type(i).request_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.reserved_quantity:'||p_line_tbl_type(i).reserved_quantity,1,'Y');

            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute1:'||p_line_tbl_type(i).return_attribute1,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute10:'||p_line_tbl_type(i).return_attribute10,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute11:'||p_line_tbl_type(i).return_attribute11,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute12:'||p_line_tbl_type(i).return_attribute12,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute13:'||p_line_tbl_type(i).return_attribute13,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute14:'||p_line_tbl_type(i).return_attribute14,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute15:'||p_line_tbl_type(i).return_attribute15,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute2:'||p_line_tbl_type(i).return_attribute2,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute3:'||p_line_tbl_type(i).return_attribute3,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute4:'||p_line_tbl_type(i).return_attribute4,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute5:'||p_line_tbl_type(i).return_attribute5,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute6:'||p_line_tbl_type(i).return_attribute6,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute7:'||p_line_tbl_type(i).return_attribute7,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute8:'||p_line_tbl_type(i).return_attribute8,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_attribute9:'||p_line_tbl_type(i).return_attribute9,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_context:'||p_line_tbl_type(i).return_context,1,'Y');

	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_reason_code:'||p_line_tbl_type(i).return_reason_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.rla_schedule_type_code:'||p_line_tbl_type(i).rla_schedule_type_code,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.salesrep_id:'||p_line_tbl_type(i).salesrep_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.schedule_arrival_date:'||p_line_tbl_type(i).schedule_arrival_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.schedule_ship_date:'||p_line_tbl_type(i).schedule_ship_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.schedule_action_code:'||p_line_tbl_type(i).schedule_action_code,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.schedule_status_code:'||p_line_tbl_type(i).schedule_status_code,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.shipment_number:'||p_line_tbl_type(i).shipment_number,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.shipment_priority_code:'||p_line_tbl_type(i).shipment_priority_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.shipped_quantity:'||p_line_tbl_type(i).shipped_quantity,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.shipping_interfaced_flag:'||p_line_tbl_type(i).shipping_interfaced_flag,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.shipping_method_code:'||p_line_tbl_type(i).shipping_method_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.shipping_quantity:'||p_line_tbl_type(i).shipping_quantity,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.shipping_quantity_uom:'||p_line_tbl_type(i).shipping_quantity_uom,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ship_from_org_id:'||p_line_tbl_type(i).ship_from_org_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ship_model_complete_flag:'||p_line_tbl_type(i).ship_model_complete_flag,1,'Y');

	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ship_set_id:'||p_line_tbl_type(i).ship_set_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ship_tolerance_above:'||p_line_tbl_type(i).ship_tolerance_above,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ship_tolerance_below:'||p_line_tbl_type(i).ship_tolerance_below,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ship_to_contact_id:'||p_line_tbl_type(i).ship_to_contact_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ship_to_org_id:'||p_line_tbl_type(i).ship_to_org_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.sold_to_org_id:'||p_line_tbl_type(i).sold_to_org_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.sold_from_org_id:'||p_line_tbl_type(i).sold_from_org_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.sort_order:'||p_line_tbl_type(i).sort_order,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.source_document_id:'||p_line_tbl_type(i).source_document_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.source_document_line_id:'||p_line_tbl_type(i).source_document_line_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.source_document_type_id:'||p_line_tbl_type(i).source_document_type_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.source_type_code:'||p_line_tbl_type(i).source_type_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.split_from_line_id:'||p_line_tbl_type(i).split_from_line_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.task_id:'||p_line_tbl_type(i).task_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.tax_code:'||p_line_tbl_type(i).tax_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.tax_date:'||p_line_tbl_type(i).tax_date,1,'Y');

            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.tax_exempt_flag:'||p_line_tbl_type(i).tax_exempt_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.tax_exempt_number:'||p_line_tbl_type(i).tax_exempt_number,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.tax_exempt_reason_code:'||p_line_tbl_type(i).tax_exempt_reason_code,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.tax_point_code:'||p_line_tbl_type(i).tax_point_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.tax_rate:'||p_line_tbl_type(i).tax_rate,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.tax_value:'||p_line_tbl_type(i).tax_value,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.top_model_line_ref:'||p_line_tbl_type(i).top_model_line_ref,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.top_model_line_id:'||p_line_tbl_type(i).top_model_line_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.top_model_line_index:'||p_line_tbl_type(i).top_model_line_index,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.unit_list_price:'||p_line_tbl_type(i).unit_list_price,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.unit_selling_price:'||p_line_tbl_type(i).unit_selling_price,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.veh_cus_item_cum_key_id:'||p_line_tbl_type(i).veh_cus_item_cum_key_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.visible_demand_flag:'||p_line_tbl_type(i).visible_demand_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.return_status:'||p_line_tbl_type(i).return_status,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.db_flag:'||p_line_tbl_type(i).db_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.operation:'||p_line_tbl_type(i).operation,1,'Y');

	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.first_ack_code:'||p_line_tbl_type(i).first_ack_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.first_ack_date:'||p_line_tbl_type(i).first_ack_date,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.last_ack_code:'||p_line_tbl_type(i).last_ack_code,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.last_ack_date:'||p_line_tbl_type(i).last_ack_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.change_reason:'||p_line_tbl_type(i).change_reason,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.change_comments:'||p_line_tbl_type(i).change_comments,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.arrival_set:'||p_line_tbl_type(i).arrival_set,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ship_set:'||p_line_tbl_type(i).ship_set,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.order_source_id:'||p_line_tbl_type(i).order_source_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.orig_sys_shipment_ref:'||p_line_tbl_type(i).orig_sys_shipment_ref,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.change_sequence:'||p_line_tbl_type(i).change_sequence,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.change_request_code:'||p_line_tbl_type(i).change_request_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.status_flag:'||p_line_tbl_type(i).status_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.drop_ship_flag:'||p_line_tbl_type(i).drop_ship_flag,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.customer_line_number:'||p_line_tbl_type(i).customer_line_number,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.customer_shipment_number:'||p_line_tbl_type(i).customer_shipment_number,1,'Y');

	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.customer_item_net_price:'||p_line_tbl_type(i).customer_item_net_price,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.customer_payment_term_id:'||p_line_tbl_type(i).customer_payment_term_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.ordered_item_id:'||p_line_tbl_type(i).ordered_item_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.item_identifier_type:'||p_line_tbl_type(i).item_identifier_type,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.shipping_instructions:'||p_line_tbl_type(i).shipping_instructions,1,'Y');

	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.packing_instructions:'||p_line_tbl_type(i).packing_instructions,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.calculate_price_flag:'||p_line_tbl_type(i).calculate_price_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.invoiced_quantity:'||p_line_tbl_type(i).invoiced_quantity,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_txn_reason_code:'||p_line_tbl_type(i).service_txn_reason_code,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_txn_comments:'||p_line_tbl_type(i).service_txn_comments,1,'Y');

	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_duration:'||p_line_tbl_type(i).service_duration,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_period:'||p_line_tbl_type(i).service_period,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_start_date:'||p_line_tbl_type(i).service_start_date,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_end_date:'||p_line_tbl_type(i).service_end_date,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_coterminate_flag:'||p_line_tbl_type(i).service_coterminate_flag,1,'Y');

	     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.unit_list_percent:'||p_line_tbl_type(i).unit_list_percent,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.unit_selling_percent:'||p_line_tbl_type(i).unit_selling_percent,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.unit_percent_base_price:'||p_line_tbl_type(i).unit_percent_base_price,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_number:'||p_line_tbl_type(i).service_number,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_reference_type_code:'||p_line_tbl_type(i).service_reference_type_code,1,'Y');

	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_reference_line_id:'||p_line_tbl_type(i).service_reference_line_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_reference_system_id:'||p_line_tbl_type(i).service_reference_system_id,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_ref_order_number:'||p_line_tbl_type(i).service_ref_order_number,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_ref_line_number:'||p_line_tbl_type(i).service_ref_line_number,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_ref_shipment_number:'||p_line_tbl_type(i).service_ref_shipment_number,1,'Y');

	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_ref_option_number:'||p_line_tbl_type(i).service_ref_option_number,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.service_line_index:'||p_line_tbl_type(i).service_line_index,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.Line_set_id:'||p_line_tbl_type(i).Line_set_id,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.split_by:'||p_line_tbl_type(i).split_by,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.Split_Action_Code:'||p_line_tbl_type(i).Split_Action_Code,1,'Y');

	     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.shippable_flag:'||p_line_tbl_type(i).shippable_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.model_remnant_flag:'||p_line_tbl_type(i).model_remnant_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.flow_status_code:'||p_line_tbl_type(i).flow_status_code,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.fulfilled_flag:'||p_line_tbl_type(i).fulfilled_flag,1,'Y');
	    aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_tbl_type('||i||')'||'.fulfillment_method_code:'||p_line_tbl_type(i).fulfillment_method_code,1,'Y');
	     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT l_semi_processed_flag:'||l_semi_processed_flag,1,'Y');

      end if;

l_line_type := SYSTEM.ASO_Line_Type
( p_line_tbl_type(i).accounting_rule_id
, p_line_tbl_type(i).actual_arrival_date
, p_line_tbl_type(i).actual_shipment_date
, p_line_tbl_type(i).agreement_id
, p_line_tbl_type(i).arrival_set_id
, p_line_tbl_type(i).ato_line_id
, p_line_tbl_type(i).attribute1
, p_line_tbl_type(i).attribute10
, p_line_tbl_type(i).attribute11
, p_line_tbl_type(i).attribute12
, p_line_tbl_type(i).attribute13
, p_line_tbl_type(i).attribute14
, p_line_tbl_type(i).attribute15
, p_line_tbl_type(i).attribute2
, p_line_tbl_type(i).attribute3
, p_line_tbl_type(i).attribute4
, p_line_tbl_type(i).attribute5
, p_line_tbl_type(i).attribute6
, p_line_tbl_type(i).attribute7
, p_line_tbl_type(i).attribute8
, p_line_tbl_type(i).attribute9
, p_line_tbl_type(i).authorized_to_ship_flag
, p_line_tbl_type(i).auto_selected_quantity
, p_line_tbl_type(i).booked_flag
, p_line_tbl_type(i).cancelled_flag
, p_line_tbl_type(i).cancelled_quantity
, p_line_tbl_type(i).commitment_id
, p_line_tbl_type(i).component_code
, p_line_tbl_type(i).component_number
, p_line_tbl_type(i).component_sequence_id
, p_line_tbl_type(i).config_header_id
, p_line_tbl_type(i).config_rev_nbr
, p_line_tbl_type(i).config_display_sequence
, p_line_tbl_type(i).configuration_id
, p_line_tbl_type(i).context
, p_line_tbl_type(i).created_by
, p_line_tbl_type(i).creation_date
, p_line_tbl_type(i).credit_invoice_line_id
, p_line_tbl_type(i).customer_dock_code
, p_line_tbl_type(i).customer_job
, p_line_tbl_type(i).customer_production_line
, p_line_tbl_type(i).customer_trx_line_id
, p_line_tbl_type(i).cust_model_serial_number
, p_line_tbl_type(i).cust_po_number
, p_line_tbl_type(i).cust_production_seq_num
, p_line_tbl_type(i).delivery_lead_time
, p_line_tbl_type(i).deliver_to_contact_id
, p_line_tbl_type(i).deliver_to_org_id
, p_line_tbl_type(i).demand_bucket_type_code
, p_line_tbl_type(i).demand_class_code
, p_line_tbl_type(i).dep_plan_required_flag
, p_line_tbl_type(i).earliest_acceptable_date
, p_line_tbl_type(i).end_item_unit_number
, p_line_tbl_type(i).explosion_date
, p_line_tbl_type(i).fob_point_code
, p_line_tbl_type(i).freight_carrier_code
, p_line_tbl_type(i).freight_terms_code
, p_line_tbl_type(i).fulfilled_quantity
, p_line_tbl_type(i).global_attribute1
, p_line_tbl_type(i).global_attribute10
, p_line_tbl_type(i).global_attribute11
, p_line_tbl_type(i).global_attribute12
, p_line_tbl_type(i).global_attribute13
, p_line_tbl_type(i).global_attribute14
, p_line_tbl_type(i).global_attribute15
, p_line_tbl_type(i).global_attribute16
, p_line_tbl_type(i).global_attribute17
, p_line_tbl_type(i).global_attribute18
, p_line_tbl_type(i).global_attribute19
, p_line_tbl_type(i).global_attribute2
, p_line_tbl_type(i).global_attribute20
, p_line_tbl_type(i).global_attribute3
, p_line_tbl_type(i).global_attribute4
, p_line_tbl_type(i).global_attribute5
, p_line_tbl_type(i).global_attribute6
, p_line_tbl_type(i).global_attribute7
, p_line_tbl_type(i).global_attribute8
, p_line_tbl_type(i).global_attribute9
, p_line_tbl_type(i).global_attribute_category
, p_line_tbl_type(i).header_id
, p_line_tbl_type(i).industry_attribute1
, p_line_tbl_type(i).industry_attribute10
, p_line_tbl_type(i).industry_attribute11
, p_line_tbl_type(i).industry_attribute12
, p_line_tbl_type(i).industry_attribute13
, p_line_tbl_type(i).industry_attribute14
, p_line_tbl_type(i).industry_attribute15
, p_line_tbl_type(i).industry_attribute16
, p_line_tbl_type(i).industry_attribute17
, p_line_tbl_type(i).industry_attribute18
, p_line_tbl_type(i).industry_attribute19
, p_line_tbl_type(i).industry_attribute20
, p_line_tbl_type(i).industry_attribute21
, p_line_tbl_type(i).industry_attribute22
, p_line_tbl_type(i).industry_attribute23
, p_line_tbl_type(i).industry_attribute24
, p_line_tbl_type(i).industry_attribute25
, p_line_tbl_type(i).industry_attribute26
, p_line_tbl_type(i).industry_attribute27
, p_line_tbl_type(i).industry_attribute28
, p_line_tbl_type(i).industry_attribute29
, p_line_tbl_type(i).industry_attribute30
, p_line_tbl_type(i).industry_attribute2
, p_line_tbl_type(i).industry_attribute3
, p_line_tbl_type(i).industry_attribute4
, p_line_tbl_type(i).industry_attribute5
, p_line_tbl_type(i).industry_attribute6
, p_line_tbl_type(i).industry_attribute7
, p_line_tbl_type(i).industry_attribute8
, p_line_tbl_type(i).industry_attribute9
, p_line_tbl_type(i).industry_context
, p_line_tbl_type(i).TP_CONTEXT
, p_line_tbl_type(i).TP_ATTRIBUTE1
, p_line_tbl_type(i).TP_ATTRIBUTE2
, p_line_tbl_type(i).TP_ATTRIBUTE3
, p_line_tbl_type(i).TP_ATTRIBUTE4
, p_line_tbl_type(i).TP_ATTRIBUTE5
, p_line_tbl_type(i).TP_ATTRIBUTE6
, p_line_tbl_type(i).TP_ATTRIBUTE7
, p_line_tbl_type(i).TP_ATTRIBUTE8
, p_line_tbl_type(i).TP_ATTRIBUTE9
, p_line_tbl_type(i).TP_ATTRIBUTE10
, p_line_tbl_type(i).TP_ATTRIBUTE11
, p_line_tbl_type(i).TP_ATTRIBUTE12
, p_line_tbl_type(i).TP_ATTRIBUTE13
, p_line_tbl_type(i).TP_ATTRIBUTE14
, p_line_tbl_type(i).TP_ATTRIBUTE15
, p_line_tbl_type(i).intermed_ship_to_org_id
, p_line_tbl_type(i).intermed_ship_to_contact_id
, p_line_tbl_type(i).inventory_item_id
, p_line_tbl_type(i).invoice_interface_status_code
, p_line_tbl_type(i).invoice_to_contact_id
, p_line_tbl_type(i).invoice_to_org_id
, p_line_tbl_type(i).invoicing_rule_id
, p_line_tbl_type(i).ordered_item
, p_line_tbl_type(i).item_revision
, p_line_tbl_type(i).item_type_code
, p_line_tbl_type(i).last_updated_by
, p_line_tbl_type(i).last_update_date
, p_line_tbl_type(i).last_update_login
, p_line_tbl_type(i).latest_acceptable_date
, p_line_tbl_type(i).line_category_code
, p_line_tbl_type(i).line_id
, p_line_tbl_type(i).line_number
, p_line_tbl_type(i).line_type_id
, p_line_tbl_type(i).link_to_line_ref
, p_line_tbl_type(i).link_to_line_id
, p_line_tbl_type(i).link_to_line_index
, p_line_tbl_type(i).model_group_number
, p_line_tbl_type(i).mfg_component_sequence_id
, p_line_tbl_type(i).open_flag
, p_line_tbl_type(i).option_flag
, p_line_tbl_type(i).option_number
, p_line_tbl_type(i).ordered_quantity
, p_line_tbl_type(i).order_quantity_uom
, p_line_tbl_type(i).org_id
, p_line_tbl_type(i).orig_sys_document_ref
, p_line_tbl_type(i).orig_sys_line_ref
, p_line_tbl_type(i).over_ship_reason_code
, p_line_tbl_type(i).over_ship_resolved_flag
, p_line_tbl_type(i).payment_term_id
, p_line_tbl_type(i).planning_priority
, p_line_tbl_type(i).price_list_id
, p_line_tbl_type(i).pricing_attribute1
, p_line_tbl_type(i).pricing_attribute10
, p_line_tbl_type(i).pricing_attribute2
, p_line_tbl_type(i).pricing_attribute3
, p_line_tbl_type(i).pricing_attribute4
, p_line_tbl_type(i).pricing_attribute5
, p_line_tbl_type(i).pricing_attribute6
, p_line_tbl_type(i).pricing_attribute7
, p_line_tbl_type(i).pricing_attribute8
, p_line_tbl_type(i).pricing_attribute9
, p_line_tbl_type(i).pricing_context
, p_line_tbl_type(i).pricing_date
, p_line_tbl_type(i).pricing_quantity
, p_line_tbl_type(i).pricing_quantity_uom
, p_line_tbl_type(i).program_application_id
, p_line_tbl_type(i).program_id
, p_line_tbl_type(i).program_update_date
, p_line_tbl_type(i).project_id
, p_line_tbl_type(i).promise_date
, p_line_tbl_type(i).re_source_flag
, p_line_tbl_type(i).reference_customer_trx_line_id
, p_line_tbl_type(i).reference_header_id
, p_line_tbl_type(i).reference_line_id
, p_line_tbl_type(i).reference_type
, p_line_tbl_type(i).request_date
, p_line_tbl_type(i).request_id
, p_line_tbl_type(i).reserved_quantity
, p_line_tbl_type(i).return_attribute1
, p_line_tbl_type(i).return_attribute10
, p_line_tbl_type(i).return_attribute11
, p_line_tbl_type(i).return_attribute12
, p_line_tbl_type(i).return_attribute13
, p_line_tbl_type(i).return_attribute14
, p_line_tbl_type(i).return_attribute15
, p_line_tbl_type(i).return_attribute2
, p_line_tbl_type(i).return_attribute3
, p_line_tbl_type(i).return_attribute4
, p_line_tbl_type(i).return_attribute5
, p_line_tbl_type(i).return_attribute6
, p_line_tbl_type(i).return_attribute7
, p_line_tbl_type(i).return_attribute8
, p_line_tbl_type(i).return_attribute9
, p_line_tbl_type(i).return_context
, p_line_tbl_type(i).return_reason_code
, p_line_tbl_type(i).rla_schedule_type_code
, p_line_tbl_type(i).salesrep_id
, p_line_tbl_type(i).schedule_arrival_date
, p_line_tbl_type(i).schedule_ship_date
, p_line_tbl_type(i).schedule_action_code
, p_line_tbl_type(i).schedule_status_code
, p_line_tbl_type(i).shipment_number
, p_line_tbl_type(i).shipment_priority_code
, p_line_tbl_type(i).shipped_quantity
, p_line_tbl_type(i).shipping_interfaced_flag
, p_line_tbl_type(i).shipping_method_code
, p_line_tbl_type(i).shipping_quantity
, p_line_tbl_type(i).shipping_quantity_uom
, p_line_tbl_type(i).ship_from_org_id
, p_line_tbl_type(i).ship_model_complete_flag
, p_line_tbl_type(i).ship_set_id
, p_line_tbl_type(i).ship_tolerance_above
, p_line_tbl_type(i).ship_tolerance_below
, p_line_tbl_type(i).ship_to_contact_id
, p_line_tbl_type(i).ship_to_org_id
, p_line_tbl_type(i).sold_to_org_id
, p_line_tbl_type(i).sold_from_org_id
, p_line_tbl_type(i).sort_order
, p_line_tbl_type(i).source_document_id
, p_line_tbl_type(i).source_document_line_id
, p_line_tbl_type(i).source_document_type_id
, p_line_tbl_type(i).source_type_code
, p_line_tbl_type(i).split_from_line_id
, p_line_tbl_type(i).task_id
, p_line_tbl_type(i).tax_code
, p_line_tbl_type(i).tax_date
, p_line_tbl_type(i).tax_exempt_flag
, p_line_tbl_type(i).tax_exempt_number
, p_line_tbl_type(i).tax_exempt_reason_code
, p_line_tbl_type(i).tax_point_code
, p_line_tbl_type(i).tax_rate
, p_line_tbl_type(i).tax_value
, p_line_tbl_type(i).top_model_line_ref
, p_line_tbl_type(i).top_model_line_id
, p_line_tbl_type(i).top_model_line_index
, p_line_tbl_type(i).unit_list_price
, p_line_tbl_type(i).unit_selling_price
, p_line_tbl_type(i).veh_cus_item_cum_key_id
, p_line_tbl_type(i).visible_demand_flag
, p_line_tbl_type(i).return_status
, p_line_tbl_type(i).db_flag
, p_line_tbl_type(i).operation
, p_line_tbl_type(i).first_ack_code
, p_line_tbl_type(i).first_ack_date
, p_line_tbl_type(i).last_ack_code
, p_line_tbl_type(i).last_ack_date
, p_line_tbl_type(i).change_reason
, p_line_tbl_type(i).change_comments
, p_line_tbl_type(i).arrival_set
, p_line_tbl_type(i).ship_set
, p_line_tbl_type(i).order_source_id
, p_line_tbl_type(i).orig_sys_shipment_ref
, p_line_tbl_type(i).change_sequence
, p_line_tbl_type(i).change_request_code
, p_line_tbl_type(i).status_flag
, p_line_tbl_type(i).drop_ship_flag
, p_line_tbl_type(i).customer_line_number
, p_line_tbl_type(i).customer_shipment_number
, p_line_tbl_type(i).customer_item_net_price
, p_line_tbl_type(i).customer_payment_term_id
, p_line_tbl_type(i).ordered_item_id
, p_line_tbl_type(i).item_identifier_type
, p_line_tbl_type(i).shipping_instructions
, p_line_tbl_type(i).packing_instructions
, p_line_tbl_type(i).calculate_price_flag
, p_line_tbl_type(i).invoiced_quantity
, p_line_tbl_type(i).service_txn_reason_code
, p_line_tbl_type(i).service_txn_comments
, p_line_tbl_type(i).service_duration
, p_line_tbl_type(i).service_period
, p_line_tbl_type(i).service_start_date
, p_line_tbl_type(i).service_end_date
, p_line_tbl_type(i).service_coterminate_flag
, p_line_tbl_type(i).unit_list_percent
, p_line_tbl_type(i).unit_selling_percent
, p_line_tbl_type(i).unit_percent_base_price
, p_line_tbl_type(i).service_number
, p_line_tbl_type(i).service_reference_type_code
, p_line_tbl_type(i).service_reference_line_id
, p_line_tbl_type(i).service_reference_system_id
, p_line_tbl_type(i).service_ref_order_number
, p_line_tbl_type(i).service_ref_line_number
, p_line_tbl_type(i).service_ref_shipment_number
, p_line_tbl_type(i).service_ref_option_number
, p_line_tbl_type(i).service_line_index
, p_line_tbl_type(i).Line_set_id
, p_line_tbl_type(i).split_by
, p_line_tbl_type(i).Split_Action_Code
, p_line_tbl_type(i).shippable_flag
, p_line_tbl_type(i).model_remnant_flag
, p_line_tbl_type(i).flow_status_code
, p_line_tbl_type(i).fulfilled_flag
, p_line_tbl_type(i).fulfillment_method_code
, l_semi_processed_flag
);
IF i = p_line_tbl_type.FIRST then
  x_line_var_type := SYSTEM.ASO_Line_Var_Type(l_line_type);
ELSE
  x_line_var_type.EXTEND;
  x_line_var_type(j) :=  l_line_type;
END IF;
  j := j + 1;
  i  := p_line_tbl_type.NEXT(i);
END LOOP;
END ASO_Line_Tbl_To_Var;

PROCEDURE ASO_Line_Adj_Tbl_To_Var
(
	p_line_adj_tbl_type	IN	OE_Order_PUB.Line_Adj_Tbl_Type  ,
	x_line_adj_var_type OUT NOCOPY /* file.sql.39 change */  	SYSTEM.ASO_Line_Adj_Var_Type
)
IS
     l_line_adj_type          SYSTEM.ASO_Line_Adj_Type;
     i                        NUMBER;
	j                        NUMBER := 1;
BEGIN
    IF p_line_adj_tbl_type.COUNT = 0 THEN
       return;
    END IF;

    i  := p_line_adj_tbl_type.FIRST;
    WHILE i IS NOT NULL LOOP
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT Printing the value  before type conversion for ASO_Line_Adj_Tbl_To_Var('||i||')' ,1,'Y');
     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute1:'||p_line_adj_tbl_type(i).attribute1	,1,'Y');
	 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute10:'||p_line_adj_tbl_type(i).attribute10	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute11:'||p_line_adj_tbl_type(i).attribute11	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute12:'||p_line_adj_tbl_type(i).attribute12	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute13:'||p_line_adj_tbl_type(i).attribute13	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute14:'||p_line_adj_tbl_type(i).attribute14	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute15:'||p_line_adj_tbl_type(i).attribute15	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute2:'||p_line_adj_tbl_type(i).attribute2	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute3:'||p_line_adj_tbl_type(i).attribute3	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute4:'||p_line_adj_tbl_type(i).attribute4	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute5:'||p_line_adj_tbl_type(i).attribute5	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute6:'||p_line_adj_tbl_type(i).attribute6	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute7:'||p_line_adj_tbl_type(i).attribute7	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute8:'||p_line_adj_tbl_type(i).attribute8	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.attribute9:'||p_line_adj_tbl_type(i).attribute9	,1,'Y');

	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.automatic_flag:'||p_line_adj_tbl_type(i).automatic_flag,1,'Y');
	 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||' .context:'||p_line_adj_tbl_type(i).context	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.discount_id:'||p_line_adj_tbl_type(i).discount_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.discount_line_id:'||p_line_adj_tbl_type(i).discount_line_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.header_id:'||p_line_adj_tbl_type(i).header_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.line_id:'||p_line_adj_tbl_type(i).line_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.percent:'||p_line_adj_tbl_type(i).percent	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.price_adjustment_id:'||p_line_adj_tbl_type(i).price_adjustment_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.request_id:'||p_line_adj_tbl_type(i).request_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.return_status:'||p_line_adj_tbl_type(i).return_status	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.db_flag:'||p_line_adj_tbl_type(i).db_flag	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.operation :'||p_line_adj_tbl_type(i).operation	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.line_index:'||p_line_adj_tbl_type(i).line_index	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.orig_sys_discount_ref:'||p_line_adj_tbl_type(i).orig_sys_discount_ref	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.change_request_code:'||p_line_adj_tbl_type(i).change_request_code	,1,'Y');


	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.status_flag:'||p_line_adj_tbl_type(i).status_flag,1,'Y');
	 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||' .list_header_id:'||p_line_adj_tbl_type(i).list_header_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.list_line_id:'||p_line_adj_tbl_type(i).list_line_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.list_line_type_code:'||p_line_adj_tbl_type(i).list_line_type_code	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.modifier_mechanism_type_code :'||p_line_adj_tbl_type(i).modifier_mechanism_type_code 	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.modified_from:'||p_line_adj_tbl_type(i).modified_from	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.modified_to:'||p_line_adj_tbl_type(i).modified_to	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.updated_flag:'||p_line_adj_tbl_type(i).updated_flag	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.update_allowed:'||p_line_adj_tbl_type(i).update_allowed	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.applied_flag :'||p_line_adj_tbl_type(i).applied_flag	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.change_reason_code :'||p_line_adj_tbl_type(i).change_reason_code 	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.change_reason_text :'||p_line_adj_tbl_type(i).change_reason_text	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.operand:'||p_line_adj_tbl_type(i).operand	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.arithmetic_operator:'||p_line_adj_tbl_type(i).arithmetic_operator	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.cost_id:'||p_line_adj_tbl_type(i).cost_id	,1,'Y');


	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.tax_code:'||p_line_adj_tbl_type(i).tax_code,1,'Y');
	 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||' .tax_exempt_flag:'||p_line_adj_tbl_type(i).tax_exempt_flag	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.tax_exempt_number:'||p_line_adj_tbl_type(i).tax_exempt_number	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.tax_exempt_reason_code :'||p_line_adj_tbl_type(i).tax_exempt_reason_code 	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.parent_adjustment_id :'||p_line_adj_tbl_type(i).parent_adjustment_id 	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.invoiced_flag:'||p_line_adj_tbl_type(i).invoiced_flag	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.estimated_flag:'||p_line_adj_tbl_type(i).estimated_flag	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.inc_in_sales_performance:'||p_line_adj_tbl_type(i).inc_in_sales_performance	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.split_action_code:'||p_line_adj_tbl_type(i).split_action_code	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.adjusted_amount :'||p_line_adj_tbl_type(i).adjusted_amount	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_adj_tbl_type('||i||')'||'.pricing_phase_id :'||p_line_adj_tbl_type(i).pricing_phase_id 	,1,'Y');

      End If;
l_line_adj_type := SYSTEM.ASO_Line_Adj_Type
( p_line_adj_tbl_type(i).attribute1
, p_line_adj_tbl_type(i).attribute10
, p_line_adj_tbl_type(i).attribute11
, p_line_adj_tbl_type(i).attribute12
, p_line_adj_tbl_type(i).attribute13
, p_line_adj_tbl_type(i).attribute14
, p_line_adj_tbl_type(i).attribute15
, p_line_adj_tbl_type(i).attribute2
, p_line_adj_tbl_type(i).attribute3
, p_line_adj_tbl_type(i).attribute4
, p_line_adj_tbl_type(i).attribute5
, p_line_adj_tbl_type(i).attribute6
, p_line_adj_tbl_type(i).attribute7
, p_line_adj_tbl_type(i).attribute8
, p_line_adj_tbl_type(i).attribute9
, p_line_adj_tbl_type(i).automatic_flag
, p_line_adj_tbl_type(i).context
, p_line_adj_tbl_type(i).created_by
, p_line_adj_tbl_type(i).creation_date
, p_line_adj_tbl_type(i).discount_id
, p_line_adj_tbl_type(i).discount_line_id
, p_line_adj_tbl_type(i).header_id
, p_line_adj_tbl_type(i).last_updated_by
, p_line_adj_tbl_type(i).last_update_date
, p_line_adj_tbl_type(i).last_update_login
, p_line_adj_tbl_type(i).line_id
, p_line_adj_tbl_type(i).percent
, p_line_adj_tbl_type(i).price_adjustment_id
, p_line_adj_tbl_type(i).program_application_id
, p_line_adj_tbl_type(i).program_id
, p_line_adj_tbl_type(i).program_update_date
, p_line_adj_tbl_type(i).request_id
, p_line_adj_tbl_type(i).return_status
, p_line_adj_tbl_type(i).db_flag
, p_line_adj_tbl_type(i).operation
, p_line_adj_tbl_type(i).line_index
, p_line_adj_tbl_type(i).orig_sys_discount_ref
, p_line_adj_tbl_type(i).change_request_code
, p_line_adj_tbl_type(i).status_flag
, p_line_adj_tbl_type(i).list_header_id
, p_line_adj_tbl_type(i).list_line_id
, p_line_adj_tbl_type(i).list_line_type_code
, p_line_adj_tbl_type(i).modifier_mechanism_type_code
, p_line_adj_tbl_type(i).modified_from
, p_line_adj_tbl_type(i).modified_to
, p_line_adj_tbl_type(i).updated_flag
, p_line_adj_tbl_type(i).update_allowed
, p_line_adj_tbl_type(i).applied_flag
, p_line_adj_tbl_type(i).change_reason_code
, p_line_adj_tbl_type(i).change_reason_text
, p_line_adj_tbl_type(i).operand
, p_line_adj_tbl_type(i).arithmetic_operator
, p_line_adj_tbl_type(i).cost_id
, p_line_adj_tbl_type(i).tax_code
, p_line_adj_tbl_type(i).tax_exempt_flag
, p_line_adj_tbl_type(i).tax_exempt_number
, p_line_adj_tbl_type(i).tax_exempt_reason_code
, p_line_adj_tbl_type(i).parent_adjustment_id
, p_line_adj_tbl_type(i).invoiced_flag
, p_line_adj_tbl_type(i).estimated_flag
, p_line_adj_tbl_type(i).inc_in_sales_performance
, p_line_adj_tbl_type(i).split_action_code
, p_line_adj_tbl_type(i).adjusted_amount
, p_line_adj_tbl_type(i).pricing_phase_id
);
IF i = p_line_adj_tbl_type.FIRST then
  x_line_adj_var_type := SYSTEM.ASO_Line_Adj_Var_Type(l_line_adj_type);
ELSE
  x_line_adj_var_type.EXTEND;
  x_line_adj_var_type(j) :=  l_line_adj_type;
END IF;
  j := j + 1;
  i  := p_line_adj_tbl_type.NEXT(i);
END LOOP;
END ASO_Line_Adj_Tbl_To_Var;

PROCEDURE ASO_Line_Adj_Assoc_Tbl_To_Var
(
   p_line_adj_assoc_tbl_type	IN      OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
   x_line_adj_assoc_var_type OUT NOCOPY /* file.sql.39 change */       SYSTEM.ASO_Line_Adj_Assoc_Var_Type
)
IS
   l_line_adj_assoc_type              SYSTEM.ASO_Line_Adj_Assoc_Type;
   i                                  NUMBER;
   j                                  NUMBER := 1;
BEGIN
    IF p_line_adj_assoc_tbl_type.COUNT = 0 THEN
       return;
    END IF;

    i := p_line_adj_assoc_tbl_type.FIRST;
    WHILE i IS NOT NULL LOOP
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT Printing the value  before type conversion for ASO_Line_Adj_Assoc_Tbl_To_Var('||i||')' ,1,'Y');
     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_assoc_tbl_type('||i||')'||'.price_adj_assoc_id:'||p_line_adj_assoc_tbl_type(i).price_adj_assoc_id	,1,'Y');
	   aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_assoc_tbl_type('||i||')'||'.line_id:'||p_line_adj_assoc_tbl_type(i).line_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_assoc_tbl_type('||i||')'||'.Line_index:'||p_line_adj_assoc_tbl_type(i).Line_index	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_assoc_tbl_type('||i||')'||'.price_adjustment_id:'||p_line_adj_assoc_tbl_type(i).price_adjustment_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_assoc_tbl_type('||i||')'||'.Adj_index:'||p_line_adj_assoc_tbl_type(i).Adj_index	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_assoc_tbl_type('||i||')'||'.program_id:'||p_line_adj_assoc_tbl_type(i).program_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_assoc_tbl_type('||i||')'||'.request_id:'||p_line_adj_assoc_tbl_type(i).request_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_assoc_tbl_type('||i||')'||'.return_status:'||p_line_adj_assoc_tbl_type(i).return_status	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_assoc_tbl_type('||i||')'||'.db_flag:'||p_line_adj_assoc_tbl_type(i).db_flag	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_assoc_tbl_type('||i||')'||'.operation:'||p_line_adj_assoc_tbl_type(i).operation	,1,'Y');
      End If;
l_line_adj_assoc_type := SYSTEM.ASO_Line_Adj_Assoc_Type
( p_line_adj_assoc_tbl_type(i).price_adj_assoc_id
, p_line_adj_assoc_tbl_type(i).line_id
, p_line_adj_assoc_tbl_type(i).Line_index
, p_line_adj_assoc_tbl_type(i).price_adjustment_id
, p_line_adj_assoc_tbl_type(i).Adj_index
, p_line_adj_assoc_tbl_type(i).creation_date
, p_line_adj_assoc_tbl_type(i).created_by
, p_line_adj_assoc_tbl_type(i).last_update_date
, p_line_adj_assoc_tbl_type(i).last_updated_by
, p_line_adj_assoc_tbl_type(i).last_update_login
, p_line_adj_assoc_tbl_type(i).program_application_id
, p_line_adj_assoc_tbl_type(i).program_id
, p_line_adj_assoc_tbl_type(i).program_update_date
, p_line_adj_assoc_tbl_type(i).request_id
, p_line_adj_assoc_tbl_type(i).return_status
, p_line_adj_assoc_tbl_type(i).db_flag
, p_line_adj_assoc_tbl_type(i).operation
);
IF i = p_line_adj_assoc_tbl_type.FIRST then
  x_line_adj_assoc_var_type := SYSTEM.ASO_Line_Adj_Assoc_Var_Type(l_line_adj_assoc_type);
ELSE
  x_line_adj_assoc_var_type.EXTEND;
  x_line_adj_assoc_var_type(j) :=  l_line_adj_assoc_type;
END IF;
  j := j + 1;
  i := p_line_adj_assoc_tbl_type.NEXT(i);
END LOOP;
END ASO_Line_Adj_Assoc_Tbl_To_Var;


PROCEDURE ASO_Line_Adj_Att_Tbl_To_Var
(
    p_line_adj_att_tbl_type IN	 OE_Order_PUB.Line_Adj_Att_Tbl_Type,
    x_line_adj_att_var_type OUT NOCOPY /* file.sql.39 change */       SYSTEM.ASO_Line_Adj_Att_Var_Type
)
IS
    l_line_adj_att_type             SYSTEM.ASO_Line_Adj_Att_Type;
    i                               NUMBER;
    j                               NUMBER := 1;
BEGIN
    IF p_line_adj_att_tbl_type.COUNT = 0 THEN
       return;
    END IF;

    i  := p_line_adj_att_tbl_type.FIRST;

    WHILE i IS NOT NULL LOOP
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT Printing the value  before type conversion for ASO_Line_Adj_Att_Tbl_To_Var('||i||')' ,1,'Y');
     aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'price_adj_attrib_id :'||p_line_adj_att_tbl_type(i).price_adj_attrib_id 	,1,'Y');
	 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.price_adjustment_id:'||p_line_adj_att_tbl_type(i).price_adjustment_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.Adj_index:'||p_line_adj_att_tbl_type(i).Adj_index	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.flex_title:'||p_line_adj_att_tbl_type(i).flex_title	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.pricing_context:'||p_line_adj_att_tbl_type(i).pricing_context	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.pricing_attribute:'||p_line_adj_att_tbl_type(i).pricing_attribute	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.request_id:'||p_line_adj_att_tbl_type(i).request_id	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.pricing_attr_value_from:'||p_line_adj_att_tbl_type(i).pricing_attr_value_from	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.pricing_attr_value_to:'||p_line_adj_att_tbl_type(i).pricing_attr_value_to	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.comparison_operator:'||p_line_adj_att_tbl_type(i).comparison_operator	,1,'Y');
	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.return_status:'||p_line_adj_att_tbl_type(i).return_status	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.db_flag:'||p_line_adj_att_tbl_type(i).db_flag	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT p_line_adj_att_tbl_type('||i||')'||'.operation:'||p_line_adj_att_tbl_type(i).operation,1,'Y');
   End If;
l_line_adj_att_type := SYSTEM.ASO_Line_Adj_Att_Type
( p_line_adj_att_tbl_type(i).price_adj_attrib_id
, p_line_adj_att_tbl_type(i).price_adjustment_id
, p_line_adj_att_tbl_type(i).Adj_index
, p_line_adj_att_tbl_type(i).flex_title
, p_line_adj_att_tbl_type(i).pricing_context
, p_line_adj_att_tbl_type(i).pricing_attribute
, p_line_adj_att_tbl_type(i).creation_date
, p_line_adj_att_tbl_type(i).created_by
, p_line_adj_att_tbl_type(i).last_update_date
, p_line_adj_att_tbl_type(i).last_updated_by
, p_line_adj_att_tbl_type(i).last_update_login
, p_line_adj_att_tbl_type(i).program_application_id
, p_line_adj_att_tbl_type(i).program_id
, p_line_adj_att_tbl_type(i).program_update_date
, p_line_adj_att_tbl_type(i).request_id
, p_line_adj_att_tbl_type(i).pricing_attr_value_from
, p_line_adj_att_tbl_type(i).pricing_attr_value_to
, p_line_adj_att_tbl_type(i).comparison_operator
, p_line_adj_att_tbl_type(i).return_status
, p_line_adj_att_tbl_type(i).db_flag
, p_line_adj_att_tbl_type(i).operation
);
IF i = p_line_adj_att_tbl_type.FIRST then
  x_line_adj_att_var_type := SYSTEM.ASO_Line_Adj_Att_Var_Type(l_line_adj_att_type);
ELSE
  x_line_adj_att_var_type.EXTEND;
  x_line_adj_att_var_type(j) :=  l_line_adj_att_type;
END IF;
j := j + 1;
i := p_line_adj_att_tbl_type.NEXT(i);
END LOOP;
END ASO_Line_Adj_Att_Tbl_To_Var;

PROCEDURE ASO_Line_Price_Att_Tbl_To_Var
(
     p_line_price_att_tbl_type IN      OE_Order_PUB.Line_Price_Att_Tbl_Type,
     x_line_price_att_var_type OUT NOCOPY /* file.sql.39 change */       SYSTEM.ASO_Line_Price_Att_Var_Type
)
IS
     l_line_price_att_type             SYSTEM.ASO_Line_Price_Att_Type;
     i                                 NUMBER;
	j                                 NUMBER := 1;
BEGIN

    IF p_line_price_att_tbl_type.COUNT = 0 THEN
       return;
    END IF;

    i  := p_line_price_att_tbl_type.FIRST;

    WHILE i IS NOT NULL LOOP
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT Printing the value  before type conversion for ASO_Line_Price_Att_Tbl_To_Var('||i||')' ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.order_price_attrib_id :'||p_line_price_att_tbl_type(i).order_price_attrib_id ,1,'Y');
	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.header_id:'||p_line_price_att_tbl_type(i).header_id,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.line_id :'||p_line_price_att_tbl_type(i).line_id ,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.request_id :'||p_line_price_att_tbl_type(i).request_id ,1,'Y');
	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.flex_title:'||p_line_price_att_tbl_type(i).flex_title,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.request_id :'||p_line_price_att_tbl_type(i).request_id ,1,'Y');
	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.flex_title:'||p_line_price_att_tbl_type(i).flex_title,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_context:'||p_line_price_att_tbl_type(i).pricing_context,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute1:'||p_line_price_att_tbl_type(i).pricing_attribute1	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute2:'||p_line_price_att_tbl_type(i).pricing_attribute2	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute3:'||p_line_price_att_tbl_type(i).pricing_attribute3	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute4:'||p_line_price_att_tbl_type(i).pricing_attribute4	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute5:'||p_line_price_att_tbl_type(i).pricing_attribute5	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute6:'||p_line_price_att_tbl_type(i).pricing_attribute6	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute7:'||p_line_price_att_tbl_type(i).pricing_attribute7	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute8:'||p_line_price_att_tbl_type(i).pricing_attribute8	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute9:'||p_line_price_att_tbl_type(i).pricing_attribute9	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute10:'||p_line_price_att_tbl_type(i).pricing_attribute10	,1,'Y');


      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute11:'||p_line_price_att_tbl_type(i).pricing_attribute11	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute12:'||p_line_price_att_tbl_type(i).pricing_attribute12	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute13:'||p_line_price_att_tbl_type(i).pricing_attribute13	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute14:'||p_line_price_att_tbl_type(i).pricing_attribute14	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute15:'||p_line_price_att_tbl_type(i).pricing_attribute15	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute16:'||p_line_price_att_tbl_type(i).pricing_attribute16	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute17:'||p_line_price_att_tbl_type(i).pricing_attribute17	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute18:'||p_line_price_att_tbl_type(i).pricing_attribute18	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute19:'||p_line_price_att_tbl_type(i).pricing_attribute19	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute20:'||p_line_price_att_tbl_type(i).pricing_attribute20	,1,'Y');


      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute21:'||p_line_price_att_tbl_type(i).pricing_attribute21	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute22:'||p_line_price_att_tbl_type(i).pricing_attribute22	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute23:'||p_line_price_att_tbl_type(i).pricing_attribute23	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute24:'||p_line_price_att_tbl_type(i).pricing_attribute24	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute25:'||p_line_price_att_tbl_type(i).pricing_attribute25	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute26:'||p_line_price_att_tbl_type(i).pricing_attribute26	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute27:'||p_line_price_att_tbl_type(i).pricing_attribute27	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute28:'||p_line_price_att_tbl_type(i).pricing_attribute28	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute29:'||p_line_price_att_tbl_type(i).pricing_attribute29	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute30:'||p_line_price_att_tbl_type(i).pricing_attribute30	,1,'Y');


      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute31:'||p_line_price_att_tbl_type(i).pricing_attribute31	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute32:'||p_line_price_att_tbl_type(i).pricing_attribute32	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute33:'||p_line_price_att_tbl_type(i).pricing_attribute33	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute34:'||p_line_price_att_tbl_type(i).pricing_attribute34	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute35:'||p_line_price_att_tbl_type(i).pricing_attribute35	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute36:'||p_line_price_att_tbl_type(i).pricing_attribute36	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute37:'||p_line_price_att_tbl_type(i).pricing_attribute37	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute38:'||p_line_price_att_tbl_type(i).pricing_attribute38	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute39:'||p_line_price_att_tbl_type(i).pricing_attribute39	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute40:'||p_line_price_att_tbl_type(i).pricing_attribute40	,1,'Y');

      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute41:'||p_line_price_att_tbl_type(i).pricing_attribute41	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute42:'||p_line_price_att_tbl_type(i).pricing_attribute42	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute43:'||p_line_price_att_tbl_type(i).pricing_attribute43	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute44:'||p_line_price_att_tbl_type(i).pricing_attribute44	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute45:'||p_line_price_att_tbl_type(i).pricing_attribute45	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute46:'||p_line_price_att_tbl_type(i).pricing_attribute46	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute47:'||p_line_price_att_tbl_type(i).pricing_attribute47	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute48:'||p_line_price_att_tbl_type(i).pricing_attribute48	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute49:'||p_line_price_att_tbl_type(i).pricing_attribute49	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute50:'||p_line_price_att_tbl_type(i).pricing_attribute50	,1,'Y');


      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute51:'||p_line_price_att_tbl_type(i).pricing_attribute51	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute52:'||p_line_price_att_tbl_type(i).pricing_attribute52	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute53:'||p_line_price_att_tbl_type(i).pricing_attribute53	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute54:'||p_line_price_att_tbl_type(i).pricing_attribute54	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute55:'||p_line_price_att_tbl_type(i).pricing_attribute55	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute56:'||p_line_price_att_tbl_type(i).pricing_attribute56	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute57:'||p_line_price_att_tbl_type(i).pricing_attribute57	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute58:'||p_line_price_att_tbl_type(i).pricing_attribute58	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute59:'||p_line_price_att_tbl_type(i).pricing_attribute59	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute60:'||p_line_price_att_tbl_type(i).pricing_attribute60	,1,'Y');

      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute61:'||p_line_price_att_tbl_type(i).pricing_attribute61	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute62:'||p_line_price_att_tbl_type(i).pricing_attribute62	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute63:'||p_line_price_att_tbl_type(i).pricing_attribute63	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute64:'||p_line_price_att_tbl_type(i).pricing_attribute64	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute65:'||p_line_price_att_tbl_type(i).pricing_attribute65	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute66:'||p_line_price_att_tbl_type(i).pricing_attribute66	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute67:'||p_line_price_att_tbl_type(i).pricing_attribute67	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute68:'||p_line_price_att_tbl_type(i).pricing_attribute68	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute69:'||p_line_price_att_tbl_type(i).pricing_attribute69	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute70:'||p_line_price_att_tbl_type(i).pricing_attribute70	,1,'Y');

      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute71:'||p_line_price_att_tbl_type(i).pricing_attribute71	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute72:'||p_line_price_att_tbl_type(i).pricing_attribute72	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute73:'||p_line_price_att_tbl_type(i).pricing_attribute73	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute74:'||p_line_price_att_tbl_type(i).pricing_attribute74	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute75:'||p_line_price_att_tbl_type(i).pricing_attribute75	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute76:'||p_line_price_att_tbl_type(i).pricing_attribute76	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute77:'||p_line_price_att_tbl_type(i).pricing_attribute77	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute78:'||p_line_price_att_tbl_type(i).pricing_attribute78	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute79:'||p_line_price_att_tbl_type(i).pricing_attribute79	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute80:'||p_line_price_att_tbl_type(i).pricing_attribute80	,1,'Y');

	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute81:'||p_line_price_att_tbl_type(i).pricing_attribute81	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute82:'||p_line_price_att_tbl_type(i).pricing_attribute82	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute83:'||p_line_price_att_tbl_type(i).pricing_attribute83	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute84:'||p_line_price_att_tbl_type(i).pricing_attribute84	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute85:'||p_line_price_att_tbl_type(i).pricing_attribute85	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute86:'||p_line_price_att_tbl_type(i).pricing_attribute86	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute87:'||p_line_price_att_tbl_type(i).pricing_attribute87	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute88:'||p_line_price_att_tbl_type(i).pricing_attribute88	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute89:'||p_line_price_att_tbl_type(i).pricing_attribute89	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute90:'||p_line_price_att_tbl_type(i).pricing_attribute90	,1,'Y');

	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute91:'||p_line_price_att_tbl_type(i).pricing_attribute91	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute92:'||p_line_price_att_tbl_type(i).pricing_attribute92	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute93:'||p_line_price_att_tbl_type(i).pricing_attribute93	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute94:'||p_line_price_att_tbl_type(i).pricing_attribute94	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute95:'||p_line_price_att_tbl_type(i).pricing_attribute95	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute96:'||p_line_price_att_tbl_type(i).pricing_attribute96	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute97:'||p_line_price_att_tbl_type(i).pricing_attribute97	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute98:'||p_line_price_att_tbl_type(i).pricing_attribute98	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute99:'||p_line_price_att_tbl_type(i).pricing_attribute99	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.pricing_attribute100:'||p_line_price_att_tbl_type(i).pricing_attribute100	,1,'Y');

	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.context:'||p_line_price_att_tbl_type(i).context	,1,'Y');
	  aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute1:'||p_line_price_att_tbl_type(i).attribute1	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute2:'||p_line_price_att_tbl_type(i).attribute2	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute3:'||p_line_price_att_tbl_type(i).attribute3	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute4:'||p_line_price_att_tbl_type(i).attribute4	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute5:'||p_line_price_att_tbl_type(i).attribute5	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute6:'||p_line_price_att_tbl_type(i).attribute6	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute7:'||p_line_price_att_tbl_type(i).attribute7	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute8:'||p_line_price_att_tbl_type(i).attribute8	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute9:'||p_line_price_att_tbl_type(i).attribute9	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute10:'||p_line_price_att_tbl_type(i).attribute10	,1,'Y');


      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute11:'||p_line_price_att_tbl_type(i).attribute11	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute12:'||p_line_price_att_tbl_type(i).attribute12	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute13:'||p_line_price_att_tbl_type(i).attribute13	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute14:'||p_line_price_att_tbl_type(i).attribute14	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.attribute15:'||p_line_price_att_tbl_type(i).attribute15	,1,'Y');
	 aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.return_status:'||p_line_price_att_tbl_type(i).return_status	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.db_flag:'||p_line_price_att_tbl_type(i).db_flag	,1,'Y');
      aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_price_att_tbl_type('||i||')'||'.operation:'||p_line_price_att_tbl_type(i).operation	,1,'Y');
      End If;
l_line_price_att_type := SYSTEM.ASO_Line_Price_Att_Type
( p_line_price_att_tbl_type(i).order_price_attrib_id
, p_line_price_att_tbl_type(i).header_id
, p_line_price_att_tbl_type(i).line_id
, p_line_price_att_tbl_type(i).line_index
, p_line_price_att_tbl_type(i).creation_date
, p_line_price_att_tbl_type(i).created_by
, p_line_price_att_tbl_type(i).last_update_date
, p_line_price_att_tbl_type(i).last_updated_by
, p_line_price_att_tbl_type(i).last_update_login
, p_line_price_att_tbl_type(i).program_application_id
, p_line_price_att_tbl_type(i).program_id
, p_line_price_att_tbl_type(i).program_update_date
, p_line_price_att_tbl_type(i).request_id
, p_line_price_att_tbl_type(i).flex_title
, p_line_price_att_tbl_type(i).pricing_context
, p_line_price_att_tbl_type(i).pricing_attribute1
, p_line_price_att_tbl_type(i).pricing_attribute2
, p_line_price_att_tbl_type(i).pricing_attribute3
, p_line_price_att_tbl_type(i).pricing_attribute4
, p_line_price_att_tbl_type(i).pricing_attribute5
, p_line_price_att_tbl_type(i).pricing_attribute6
, p_line_price_att_tbl_type(i).pricing_attribute7
, p_line_price_att_tbl_type(i).pricing_attribute8
, p_line_price_att_tbl_type(i).pricing_attribute9
, p_line_price_att_tbl_type(i).pricing_attribute10
, p_line_price_att_tbl_type(i).pricing_attribute11
, p_line_price_att_tbl_type(i).pricing_attribute12
, p_line_price_att_tbl_type(i).pricing_attribute13
, p_line_price_att_tbl_type(i).pricing_attribute14
, p_line_price_att_tbl_type(i).pricing_attribute15
, p_line_price_att_tbl_type(i).pricing_attribute16
, p_line_price_att_tbl_type(i).pricing_attribute17
, p_line_price_att_tbl_type(i).pricing_attribute18
, p_line_price_att_tbl_type(i).pricing_attribute19
, p_line_price_att_tbl_type(i).pricing_attribute20
, p_line_price_att_tbl_type(i).pricing_attribute21
, p_line_price_att_tbl_type(i).pricing_attribute22
, p_line_price_att_tbl_type(i).pricing_attribute23
, p_line_price_att_tbl_type(i).pricing_attribute24
, p_line_price_att_tbl_type(i).pricing_attribute25
, p_line_price_att_tbl_type(i).pricing_attribute26
, p_line_price_att_tbl_type(i).pricing_attribute27
, p_line_price_att_tbl_type(i).pricing_attribute28
, p_line_price_att_tbl_type(i).pricing_attribute29
, p_line_price_att_tbl_type(i).pricing_attribute30
, p_line_price_att_tbl_type(i).pricing_attribute31
, p_line_price_att_tbl_type(i).pricing_attribute32
, p_line_price_att_tbl_type(i).pricing_attribute33
, p_line_price_att_tbl_type(i).pricing_attribute34
, p_line_price_att_tbl_type(i).pricing_attribute35
, p_line_price_att_tbl_type(i).pricing_attribute36
, p_line_price_att_tbl_type(i).pricing_attribute37
, p_line_price_att_tbl_type(i).pricing_attribute38
, p_line_price_att_tbl_type(i).pricing_attribute39
, p_line_price_att_tbl_type(i).pricing_attribute40
, p_line_price_att_tbl_type(i).pricing_attribute41
, p_line_price_att_tbl_type(i).pricing_attribute42
, p_line_price_att_tbl_type(i).pricing_attribute43
, p_line_price_att_tbl_type(i).pricing_attribute44
, p_line_price_att_tbl_type(i).pricing_attribute45
, p_line_price_att_tbl_type(i).pricing_attribute46
, p_line_price_att_tbl_type(i).pricing_attribute47
, p_line_price_att_tbl_type(i).pricing_attribute48
, p_line_price_att_tbl_type(i).pricing_attribute49
, p_line_price_att_tbl_type(i).pricing_attribute50
, p_line_price_att_tbl_type(i).pricing_attribute51
, p_line_price_att_tbl_type(i).pricing_attribute52
, p_line_price_att_tbl_type(i).pricing_attribute53
, p_line_price_att_tbl_type(i).pricing_attribute54
, p_line_price_att_tbl_type(i).pricing_attribute55
, p_line_price_att_tbl_type(i).pricing_attribute56
, p_line_price_att_tbl_type(i).pricing_attribute57
, p_line_price_att_tbl_type(i).pricing_attribute58
, p_line_price_att_tbl_type(i).pricing_attribute59
, p_line_price_att_tbl_type(i).pricing_attribute60
, p_line_price_att_tbl_type(i).pricing_attribute61
, p_line_price_att_tbl_type(i).pricing_attribute62
, p_line_price_att_tbl_type(i).pricing_attribute63
, p_line_price_att_tbl_type(i).pricing_attribute64
, p_line_price_att_tbl_type(i).pricing_attribute65
, p_line_price_att_tbl_type(i).pricing_attribute66
, p_line_price_att_tbl_type(i).pricing_attribute67
, p_line_price_att_tbl_type(i).pricing_attribute68
, p_line_price_att_tbl_type(i).pricing_attribute69
, p_line_price_att_tbl_type(i).pricing_attribute70
, p_line_price_att_tbl_type(i).pricing_attribute71
, p_line_price_att_tbl_type(i).pricing_attribute72
, p_line_price_att_tbl_type(i).pricing_attribute73
, p_line_price_att_tbl_type(i).pricing_attribute74
, p_line_price_att_tbl_type(i).pricing_attribute75
, p_line_price_att_tbl_type(i).pricing_attribute76
, p_line_price_att_tbl_type(i).pricing_attribute77
, p_line_price_att_tbl_type(i).pricing_attribute78
, p_line_price_att_tbl_type(i).pricing_attribute79
, p_line_price_att_tbl_type(i).pricing_attribute80
, p_line_price_att_tbl_type(i).pricing_attribute81
, p_line_price_att_tbl_type(i).pricing_attribute82
, p_line_price_att_tbl_type(i).pricing_attribute83
, p_line_price_att_tbl_type(i).pricing_attribute84
, p_line_price_att_tbl_type(i).pricing_attribute85
, p_line_price_att_tbl_type(i).pricing_attribute86
, p_line_price_att_tbl_type(i).pricing_attribute87
, p_line_price_att_tbl_type(i).pricing_attribute88
, p_line_price_att_tbl_type(i).pricing_attribute89
, p_line_price_att_tbl_type(i).pricing_attribute90
, p_line_price_att_tbl_type(i).pricing_attribute91
, p_line_price_att_tbl_type(i).pricing_attribute92
, p_line_price_att_tbl_type(i).pricing_attribute93
, p_line_price_att_tbl_type(i).pricing_attribute94
, p_line_price_att_tbl_type(i).pricing_attribute95
, p_line_price_att_tbl_type(i).pricing_attribute96
, p_line_price_att_tbl_type(i).pricing_attribute97
, p_line_price_att_tbl_type(i).pricing_attribute98
, p_line_price_att_tbl_type(i).pricing_attribute99
, p_line_price_att_tbl_type(i).pricing_attribute100
, p_line_price_att_tbl_type(i).context
, p_line_price_att_tbl_type(i).attribute1
, p_line_price_att_tbl_type(i).attribute2
, p_line_price_att_tbl_type(i).attribute3
, p_line_price_att_tbl_type(i).attribute4
, p_line_price_att_tbl_type(i).attribute5
, p_line_price_att_tbl_type(i).attribute6
, p_line_price_att_tbl_type(i).attribute7
, p_line_price_att_tbl_type(i).attribute8
, p_line_price_att_tbl_type(i).attribute9
, p_line_price_att_tbl_type(i).attribute10
, p_line_price_att_tbl_type(i).attribute11
, p_line_price_att_tbl_type(i).attribute12
, p_line_price_att_tbl_type(i).attribute13
, p_line_price_att_tbl_type(i).attribute14
, p_line_price_att_tbl_type(i).attribute15
, p_line_price_att_tbl_type(i).return_status
, p_line_price_att_tbl_type(i).db_flag
, p_line_price_att_tbl_type(i).operation
);
IF i = p_line_price_att_tbl_type.FIRST then
  x_line_price_att_var_type := SYSTEM.ASO_Line_Price_Att_Var_Type(l_line_price_att_type
);
ELSE
  x_line_price_att_var_type.EXTEND;
  x_line_price_att_var_type(j) :=  l_line_price_att_type;
END IF;
  j := j + 1;
  i := p_line_price_att_tbl_type.NEXT(i);
END LOOP;
END ASO_Line_Price_Att_Tbl_To_Var;

PROCEDURE ASO_Line_Scredit_Tbl_To_Var
(
    p_line_scredit_tbl_type IN      OE_Order_PUB.Line_Scredit_Tbl_Type,
    x_line_scredit_var_type OUT NOCOPY /* file.sql.39 change */  	 SYSTEM.ASO_Line_Scredit_Var_Type
)
IS
    l_line_scredit_type             SYSTEM.ASO_Line_Scredit_Type;
    i                               NUMBER;
    j                               NUMBER := 1;
BEGIN
    IF p_line_scredit_tbl_type.COUNT  = 0 THEN
       return;
    END IF;

    i := p_line_scredit_tbl_type.FIRST;
    WHILE i IS NOT NULL LOOP
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT Printing the value  before type conversion for ASO_Line_Scredit_Tbl_To_Var('||i||')' ,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute1:'||p_line_scredit_tbl_type(i).attribute1	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute10:'||p_line_scredit_tbl_type(i).attribute10	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute11:'||p_line_scredit_tbl_type(i).attribute11	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute12:'||p_line_scredit_tbl_type(i).attribute12	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute13:'||p_line_scredit_tbl_type(i).attribute13	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute14:'||p_line_scredit_tbl_type(i).attribute14	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute15:'||p_line_scredit_tbl_type(i).attribute15	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute2:'||p_line_scredit_tbl_type(i).attribute2	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute3:'||p_line_scredit_tbl_type(i).attribute3	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute4:'||p_line_scredit_tbl_type(i).attribute4	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute5:'||p_line_scredit_tbl_type(i).attribute5	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute6:'||p_line_scredit_tbl_type(i).attribute6	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute7:'||p_line_scredit_tbl_type(i).attribute7	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute8:'||p_line_scredit_tbl_type(i).attribute8	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.attribute9:'||p_line_scredit_tbl_type(i).attribute9	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.context:'||p_line_scredit_tbl_type(i).context	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.dw_update_advice_flag:'||p_line_scredit_tbl_type(i).dw_update_advice_flag	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.header_id:'||p_line_scredit_tbl_type(i).header_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.line_id:'||p_line_scredit_tbl_type(i).line_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.header_id:'||p_line_scredit_tbl_type(i).header_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.line_id:'||p_line_scredit_tbl_type(i).line_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.percent:'||p_line_scredit_tbl_type(i).percent	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.salesrep_id:'||p_line_scredit_tbl_type(i).salesrep_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.sales_credit_id:'||p_line_scredit_tbl_type(i).sales_credit_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.wh_update_date:'||p_line_scredit_tbl_type(i).wh_update_date	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.return_status:'||p_line_scredit_tbl_type(i).return_status	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.db_flag:'||p_line_scredit_tbl_type(i).db_flag	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.operation:'||p_line_scredit_tbl_type(i).operation	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.orig_sys_credit_ref:'||p_line_scredit_tbl_type(i).orig_sys_credit_ref	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.change_request_code:'||p_line_scredit_tbl_type(i).change_request_code	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_line_scredit_tbl_type('||i||')'||'.status_flag:'||p_line_scredit_tbl_type(i).status_flag	,1,'Y');

End if;
l_line_scredit_type := SYSTEM.ASO_Line_Scredit_Type
( p_line_scredit_tbl_type(i).attribute1
, p_line_scredit_tbl_type(i).attribute10
, p_line_scredit_tbl_type(i).attribute11
, p_line_scredit_tbl_type(i).attribute12
, p_line_scredit_tbl_type(i).attribute13
, p_line_scredit_tbl_type(i).attribute14
, p_line_scredit_tbl_type(i).attribute15
, p_line_scredit_tbl_type(i).attribute2
, p_line_scredit_tbl_type(i).attribute3
, p_line_scredit_tbl_type(i).attribute4
, p_line_scredit_tbl_type(i).attribute5
, p_line_scredit_tbl_type(i).attribute6
, p_line_scredit_tbl_type(i).attribute7
, p_line_scredit_tbl_type(i).attribute8
, p_line_scredit_tbl_type(i).attribute9
, p_line_scredit_tbl_type(i).context
, p_line_scredit_tbl_type(i).created_by
, p_line_scredit_tbl_type(i).creation_date
, p_line_scredit_tbl_type(i).dw_update_advice_flag
, p_line_scredit_tbl_type(i).header_id
, p_line_scredit_tbl_type(i).last_updated_by
, p_line_scredit_tbl_type(i).last_update_date
, p_line_scredit_tbl_type(i).last_update_login
, p_line_scredit_tbl_type(i).line_id
, p_line_scredit_tbl_type(i).percent
, p_line_scredit_tbl_type(i).salesrep_id
, p_line_scredit_tbl_type(i).sales_credit_id
, p_line_scredit_tbl_type(i).wh_update_date
, p_line_scredit_tbl_type(i).return_status
, p_line_scredit_tbl_type(i).db_flag
, p_line_scredit_tbl_type(i).operation
, p_line_scredit_tbl_type(i).line_index
, p_line_scredit_tbl_type(i).orig_sys_credit_ref
, p_line_scredit_tbl_type(i).change_request_code
, p_line_scredit_tbl_type(i).status_flag
);
IF i = p_line_scredit_tbl_type.FIRST then
  x_line_scredit_var_type := SYSTEM.ASO_Line_Scredit_Var_Type
						(l_line_scredit_type);
ELSE
  x_line_scredit_var_type.EXTEND;
  x_line_scredit_var_type(j) :=  l_line_scredit_type;
END IF;
  j := j + 1;
  i :=  p_line_scredit_tbl_type.NEXT(i);
END LOOP;
END ASO_Line_Scredit_Tbl_To_Var;


PROCEDURE ASO_Lot_Serial_Tbl_To_Var
(
    p_lot_serial_tbl_type   IN      OE_Order_PUB.Lot_Serial_Tbl_Type,
    x_lot_serial_var_type   OUT NOCOPY /* file.sql.39 change */       SYSTEM.ASO_Lot_Serial_Var_Type)
IS
    l_lot_serial_type               SYSTEM.ASO_Lot_Serial_Type;
    i                               NUMBER;
    j                               NUMBER := 1;
BEGIN
    IF p_lot_serial_tbl_type.COUNT = 0 THEN
       return;
    END IF;

    i  := p_lot_serial_tbl_type.FIRST;

    WHILE i IS NOT NULL LOOP
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT Printing the value  before type conversion for ASO_Lot_Serial_Tbl_To_Var('||i||')' ,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute1:'||p_lot_serial_tbl_type(i).attribute1	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute10:'||p_lot_serial_tbl_type(i).attribute10	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute11:'||p_lot_serial_tbl_type(i).attribute11	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute12:'||p_lot_serial_tbl_type(i).attribute12	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute13:'||p_lot_serial_tbl_type(i).attribute13	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute14:'||p_lot_serial_tbl_type(i).attribute14	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute15:'||p_lot_serial_tbl_type(i).attribute15	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute2:'||p_lot_serial_tbl_type(i).attribute2	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute3:'||p_lot_serial_tbl_type(i).attribute3	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute4:'||p_lot_serial_tbl_type(i).attribute4	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute5:'||p_lot_serial_tbl_type(i).attribute5	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute6:'||p_lot_serial_tbl_type(i).attribute6	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute7:'||p_lot_serial_tbl_type(i).attribute7	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute8:'||p_lot_serial_tbl_type(i).attribute8	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.attribute9:'||p_lot_serial_tbl_type(i).attribute9	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.context:'||p_lot_serial_tbl_type(i).context	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.from_serial_number:'||p_lot_serial_tbl_type(i).from_serial_number	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.line_id:'||p_lot_serial_tbl_type(i).line_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.lot_number:'||p_lot_serial_tbl_type(i).lot_number	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.lot_serial_id:'||p_lot_serial_tbl_type(i).lot_serial_id	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.quantity:'||p_lot_serial_tbl_type(i).quantity	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.to_serial_number:'||p_lot_serial_tbl_type(i).to_serial_number	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.return_status:'||p_lot_serial_tbl_type(i).return_status	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.db_flag:'||p_lot_serial_tbl_type(i).db_flag	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.operation:'||p_lot_serial_tbl_type(i).operation	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.line_index:'||p_lot_serial_tbl_type(i).line_index	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.orig_sys_lotserial_ref:'||p_lot_serial_tbl_type(i).orig_sys_lotserial_ref	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.change_request_code:'||p_lot_serial_tbl_type(i).change_request_code	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.status_flag:'||p_lot_serial_tbl_type(i).status_flag	,1,'Y');
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_UPDATE_PVT  p_lot_serial_tbl_type('||i||')'||'.line_set_id:'||p_lot_serial_tbl_type(i).line_set_id	,1,'Y');

End if;

l_lot_serial_type := SYSTEM.ASO_Lot_Serial_Type
( p_lot_serial_tbl_type(i).attribute1
, p_lot_serial_tbl_type(i).attribute10
, p_lot_serial_tbl_type(i).attribute11
, p_lot_serial_tbl_type(i).attribute12
, p_lot_serial_tbl_type(i).attribute13
, p_lot_serial_tbl_type(i).attribute14
, p_lot_serial_tbl_type(i).attribute15
, p_lot_serial_tbl_type(i).attribute2
, p_lot_serial_tbl_type(i).attribute3
, p_lot_serial_tbl_type(i).attribute4
, p_lot_serial_tbl_type(i).attribute5
, p_lot_serial_tbl_type(i).attribute6
, p_lot_serial_tbl_type(i).attribute7
, p_lot_serial_tbl_type(i).attribute8
, p_lot_serial_tbl_type(i).attribute9
, p_lot_serial_tbl_type(i).context
, p_lot_serial_tbl_type(i).created_by
, p_lot_serial_tbl_type(i).creation_date
, p_lot_serial_tbl_type(i).from_serial_number
, p_lot_serial_tbl_type(i).last_updated_by
, p_lot_serial_tbl_type(i).last_update_date
, p_lot_serial_tbl_type(i).last_update_login
, p_lot_serial_tbl_type(i).line_id
, p_lot_serial_tbl_type(i).lot_number
, p_lot_serial_tbl_type(i).lot_serial_id
, p_lot_serial_tbl_type(i).quantity
, p_lot_serial_tbl_type(i).to_serial_number
, p_lot_serial_tbl_type(i).return_status
, p_lot_serial_tbl_type(i).db_flag
, p_lot_serial_tbl_type(i).operation
, p_lot_serial_tbl_type(i).line_index
, p_lot_serial_tbl_type(i).orig_sys_lotserial_ref
, p_lot_serial_tbl_type(i).change_request_code
, p_lot_serial_tbl_type(i).status_flag
, p_lot_serial_tbl_type(i).line_set_id
);
IF i = p_lot_serial_tbl_type.FIRST then
  x_lot_serial_var_type := SYSTEM.ASO_Lot_Serial_Var_Type(l_lot_serial_type);
ELSE
  x_lot_serial_var_type.EXTEND;
  x_lot_serial_var_type(j) :=  l_lot_serial_type;
END IF;
  j := j + 1;
  i := p_lot_serial_tbl_type.NEXT(i);
END LOOP;
END ASO_Lot_Serial_Tbl_To_Var;

PROCEDURE ASO_Request_Tbl_To_Var
(
    p_request_tbl_type      IN      OE_Order_PUB.Request_Tbl_Type,
    x_request_var_type      OUT NOCOPY /* file.sql.39 change */       SYSTEM.ASO_Request_Var_Type
)
IS
    l_request_type                  SYSTEM.ASO_Request_Type;
    i                               NUMBER;
    j                               NUMBER := 1;
BEGIN
    if p_request_tbl_type.COUNT = 0 THEN
       return;
    END IF;

    i  := p_request_tbl_type.FIRST;
    WHILE i IS NOT NULL LOOP

      l_request_type := SYSTEM.ASO_Request_Type
(
p_request_tbl_type(i).Entity_code
, p_request_tbl_type(i).Entity_id
, p_request_tbl_type(i).Entity_index
, p_request_tbl_type(i).request_type
, p_request_tbl_type(i).return_status
, p_request_tbl_type(i).request_unique_key1
, p_request_tbl_type(i).request_unique_key2
, p_request_tbl_type(i).request_unique_key3
, p_request_tbl_type(i).request_unique_key4
, p_request_tbl_type(i).request_unique_key5
, p_request_tbl_type(i).param1
, p_request_tbl_type(i).param2
, p_request_tbl_type(i).param3
, p_request_tbl_type(i).param4
, p_request_tbl_type(i).param5
, p_request_tbl_type(i).param6
, p_request_tbl_type(i).param7
, p_request_tbl_type(i).param8
, p_request_tbl_type(i).param9
, p_request_tbl_type(i).param10
, p_request_tbl_type(i).param11
, p_request_tbl_type(i).param12
, p_request_tbl_type(i).param13
, p_request_tbl_type(i).param14
, p_request_tbl_type(i).param15
, p_request_tbl_type(i).param16
, p_request_tbl_type(i).param17
, p_request_tbl_type(i).param18
, p_request_tbl_type(i).param19
, p_request_tbl_type(i).param20
, p_request_tbl_type(i).param21
, p_request_tbl_type(i).param22
, p_request_tbl_type(i).param23
, p_request_tbl_type(i).param24
, p_request_tbl_type(i).param25
, p_request_tbl_type(i).long_param1
, p_request_tbl_type(i).date_param1
, p_request_tbl_type(i).date_param2
, p_request_tbl_type(i).date_param3
, p_request_tbl_type(i).date_param4
, p_request_tbl_type(i).date_param5
, p_request_tbl_type(i).processed
);
IF i = p_request_tbl_type.FIRST then
  x_request_var_type := SYSTEM.ASO_Request_Var_Type(l_request_type);
ELSE
  x_request_var_type.EXTEND;
  x_request_var_type(j) :=  l_request_type;
END IF;
  j := j + 1;
  i := p_request_tbl_type.NEXT(i);
END LOOP;
END ASO_Request_Tbl_To_Var;


PROCEDURE ASO_Order_Feedback_ENQ
(
    p_aso_order_feedback_type IN      SYSTEM.ASO_ORDER_FEEDBACK_TYPE,
    p_queue_type              IN      VARCHAR2,
    p_commit                  IN      VARCHAR2,
    p_app_short_name          IN      VARCHAR2
)
IS
    l_enq_msgid          RAW(16);
    l_eopt               dbms_aq.enqueue_options_t;
    l_mprop              dbms_aq.message_properties_t;
    l_expiration         VARCHAR2(30);
    queue_name           VARCHAR2(30);
BEGIN

aso_debug_pub.add('In Procedure ASO_Order_Feedback_ENQ'	,1,'Y');
    FND_PROFILE.GET('ASO_OF_RETENTION_TIME', l_expiration);
    if l_expiration is not null then
	 l_mprop.expiration           := to_number(l_expiration);
    else
      l_mprop.expiration           := dbms_aq.NEVER;
    end if;

 aso_debug_pub.add('In Procedure ASO_Order_Feedback_ENQ Value of  l_mprop.expiration'|| l_mprop.expiration,1,'Y');
    if p_queue_type = 'OF_QUEUE' then
	 l_eopt.visibility            := dbms_aq.ON_COMMIT;
	 queue_name                   := ASO_QUEUE.ASO_OF_Q;
    aso_debug_pub.add('In Procedure ASO_Order_Feedback_ENQ Value of  l_eopt.visibility '|| l_eopt.visibility ,1,'Y');
    aso_debug_pub.add('In Procedure ASO_Order_Feedback_ENQ Value of  queue_name'|| queue_name,1,'Y');
      ASO_CRM_Recipients(l_mprop.recipient_list);
    else
	 queue_name                   := ASO_QUEUE.ASO_OF_EXCP_Q;
	 l_mprop.recipient_list(0)    := sys.aq$_agent(p_app_short_name, NULL, NULL);
      if p_commit = FND_API.G_TRUE then
        l_eopt.visibility            := dbms_aq.IMMEDIATE;
      else
        l_eopt.visibility            := dbms_aq.ON_COMMIT;
      end if;
    end if;

    if l_mprop.recipient_list.COUNT >0 then
    aso_debug_pub.add('In Procedure ASO_Order_Feedback_ENQ Before dbms_aq.enqueue ',1,'Y');
      dbms_aq.enqueue (
                       queue_name => queue_name,
                       enqueue_options => l_eopt,
                       message_properties => l_mprop,
                       payload => p_aso_order_feedback_type,
                       msgid => l_enq_msgid
                      );
    end if;
END ASO_Order_Feedback_ENQ;

PROCEDURE ASO_CRM_Recipients
(
p_recipient_list        OUT NOCOPY /* file.sql.39 change */         DBMS_AQ.aq$_recipient_list_t
)
IS
   l_lookup_code        VARCHAR2(30);
   l_app_info           BOOLEAN;
   l_status             VARCHAR2(30) ;
   l_industry           VARCHAR2(30);
   l_schema             VARCHAR2(30);
   i                    NUMBER := 0;
   CURSOR c1 is
		 SELECT LOOKUP_CODE from ASO_LOOKUPS where
		 LOOKUP_TYPE = 'ASO_ORDER_FEEDBACK_CRM_APPS'
		 and enabled_flag = 'Y' and
		 sysdate between nvl(start_date_active, sysdate)
		 and nvl(end_date_active,sysdate);
BEGIN

  OPEN c1;
  LOOP
    FETCH c1 INTO l_lookup_code;
    aso_debug_pub.add('In Procedure ASO_CRM_Recipients LOOKUP_CODE'||l_LOOKUP_CODE ,1,'Y');

    EXIT WHEN (c1%NOTFOUND);
--   code commented OUT NOCOPY /* file.sql.39 change */ because of performance issue bug 1708811
--    l_app_info                   := FND_INSTALLATION.GET_APP_INFO
--                                 (l_lookup_code, l_status, l_industry, l_schema);
--    IF l_status IS NOT NULL THEN
       p_recipient_list(i) := sys.aq$_agent(l_lookup_code, NULL, NULL);
       i := i +1;
--    END IF;
  END LOOP;
  CLOSE c1;
END ASO_CRM_Recipients;

END ASO_ORDER_FEEDBACK_UPDATE_PVT;

/
