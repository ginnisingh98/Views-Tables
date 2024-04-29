--------------------------------------------------------
--  DDL for Package Body ASO_ORDER_FEEDBACK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_ORDER_FEEDBACK_PUB" AS
/* $Header: asopomfb.pls 120.1.12010000.3 2014/06/26 18:39:06 vidsrini ship $ */


-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'ASO_ORDER_FEEDBACK_PUB';
G_USER CONSTANT VARCHAR2(30) := FND_GLOBAL.USER_ID;


-- ---------------------------------------------------------
-- Define Procedures
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
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */  Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
--   x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2(2000)
--
--  UPDATE_NOTICE API specific IN Parameters:
--
--   ALL PARAMETERS ARE OPTIONAL
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
--   p_Line_Price_Att_tbl            IN  OE_Order_PUB.Line_Price_Att_Tbl_Type
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
--
--  UPDATE_NOTICE API specific OUT NOCOPY /* file.sql.39 change */  Parameters:
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
 p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
 p_commit                        IN  VARCHAR2 := FND_API.G_FALSE,
 x_return_status                 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 x_msg_count                     OUT NOCOPY /* file.sql.39 change */  NUMBER,
 x_msg_data                      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
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
) IS
	l_api_name		CONSTANT		VARCHAR2(30)	:= 'UPDATE_NOTICE';
	l_api_version	CONSTANT		NUMBER			:= 1.0;

  -- 3042254
  l_header_rec	              OE_Order_PUB.Header_Rec_Type;
  l_old_header_rec            OE_Order_PUB.Header_Rec_Type;
  l_Header_Adj_tbl	          OE_Order_PUB.Header_Adj_Tbl_Type;
  l_old_Header_Adj_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
  l_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
  l_old_Header_Price_Att_tbl  OE_Order_PUB.Header_Price_Att_Tbl_Type;
  l_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
  l_old_Header_Adj_Att_tbl    OE_Order_PUB.Header_Adj_Att_Tbl_Type;
  l_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
  l_old_Header_Adj_Assoc_tbl  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
  l_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_old_Header_Scredit_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
  l_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
  l_old_line_tbl              OE_Order_PUB.Line_Tbl_Type;
  l_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
  l_old_Line_Adj_tbl          OE_Order_PUB.Line_Adj_Tbl_Type;
  l_Line_Price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
  l_old_Line_Price_Att_tbl    OE_Order_PUB.Line_Price_Att_Tbl_Type;
  l_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
  l_old_Line_Adj_Att_tbl      OE_Order_PUB.Line_Adj_Att_Tbl_Type;
  l_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
  l_old_Line_Adj_Assoc_tbl    OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
  l_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_old_Line_Scredit_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
  l_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
  l_old_Lot_Serial_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
  l_action_request_tbl        OE_Order_PUB.Request_Tbl_Type;

BEGIN

     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

	-- Standard Start of API savepoint

	SAVEPOINT	UPDATE_NOTICE_PUB;

	-- Standard call to check for call compatibility.

	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
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

  -- 3042254
  -- mapping to local variables
  l_header_rec    	             := p_header_rec	            ;
  l_old_header_rec               := p_old_header_rec          ;
  l_Header_Adj_tbl	             := p_Header_Adj_tbl	        ;
  l_old_Header_Adj_tbl           := p_old_Header_Adj_tbl      ;
  l_Header_price_Att_tbl         := p_Header_price_Att_tbl    ;
  l_old_Header_Price_Att_tbl     := p_old_Header_Price_Att_tbl;
  l_Header_Adj_Att_tbl           := p_Header_Adj_Att_tbl      ;
  l_old_Header_Adj_Att_tbl       := p_old_Header_Adj_Att_tbl  ;
  l_Header_Adj_Assoc_tbl         := p_Header_Adj_Assoc_tbl    ;
  l_old_Header_Adj_Assoc_tbl     := p_old_Header_Adj_Assoc_tbl;
  l_Header_Scredit_tbl           := p_Header_Scredit_tbl      ;
  l_old_Header_Scredit_tbl       := p_old_Header_Scredit_tbl  ;
  l_line_tbl                     := p_line_tbl                ;
  l_old_line_tbl                 := p_old_line_tbl            ;
  l_Line_Adj_tbl                 := p_Line_Adj_tbl            ;
  l_old_Line_Adj_tbl             := p_old_Line_Adj_tbl        ;
  l_Line_Price_Att_tbl           := p_Line_Price_Att_tbl      ;
  l_old_Line_Price_Att_tbl       := p_old_Line_Price_Att_tbl  ;
  l_Line_Adj_Att_tbl             := p_Line_Adj_Att_tbl        ;
  l_old_Line_Adj_Att_tbl         := p_old_Line_Adj_Att_tbl    ;
  l_Line_Adj_Assoc_tbl           := p_Line_Adj_Assoc_tbl      ;
  l_old_Line_Adj_Assoc_tbl       := p_old_Line_Adj_Assoc_tbl  ;
  l_Line_Scredit_tbl             := p_Line_Scredit_tbl        ;
  l_old_Line_Scredit_tbl         := p_old_Line_Scredit_tbl    ;
  l_Lot_Serial_tbl               := p_Lot_Serial_tbl          ;
  l_old_Lot_Serial_tbl           := p_old_Lot_Serial_tbl      ;
  l_action_request_tbl           := p_action_request_tbl      ;

  --  call user hooks
  -- customer pre processing

  IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C'))
  THEN
    ASO_ORDER_FEEDBACK_CUHK.Update_Notice_PRE(
      p_header_rec	             => l_header_rec              ,
      p_old_header_rec           => l_old_header_rec          ,
      p_Header_Adj_tbl	         => l_Header_Adj_tbl          ,
      p_old_Header_Adj_tbl       => l_old_Header_Adj_tbl      ,
      p_Header_price_Att_tbl     => l_Header_price_Att_tbl    ,
      p_old_Header_Price_Att_tbl => l_old_Header_Price_Att_tbl,
      p_Header_Adj_Att_tbl       => l_Header_Adj_Att_tbl      ,
      p_old_Header_Adj_Att_tbl   => l_old_Header_Adj_Att_tbl  ,
      p_Header_Adj_Assoc_tbl     => l_Header_Adj_Assoc_tbl    ,
      p_old_Header_Adj_Assoc_tbl => l_old_Header_Adj_Assoc_tbl,
      p_Header_Scredit_tbl       => l_Header_Scredit_tbl      ,
      p_old_Header_Scredit_tbl   => l_old_Header_Scredit_tbl  ,
      p_line_tbl                 => l_line_tbl                ,
      p_old_line_tbl             => l_old_line_tbl            ,
      p_Line_Adj_tbl             => l_Line_Adj_tbl            ,
      p_old_Line_Adj_tbl         => l_old_Line_Adj_tbl        ,
      p_Line_Price_Att_tbl       => l_Line_Price_Att_tbl      ,
      p_old_Line_Price_Att_tbl   => l_old_Line_Price_Att_tbl  ,
      p_Line_Adj_Att_tbl         => l_Line_Adj_Att_tbl        ,
      p_old_Line_Adj_Att_tbl     => l_old_Line_Adj_Att_tbl    ,
      p_Line_Adj_Assoc_tbl       => l_Line_Adj_Assoc_tbl      ,
      p_old_Line_Adj_Assoc_tbl   => l_old_Line_Adj_Assoc_tbl  ,
      p_Line_Scredit_tbl         => l_Line_Scredit_tbl        ,
      p_old_Line_Scredit_tbl     => l_old_Line_Scredit_tbl    ,
      p_Lot_Serial_tbl           => l_Lot_Serial_tbl          ,
      p_old_Lot_Serial_tbl       => l_old_Lot_Serial_tbl      ,
      p_action_request_tbl       => l_action_request_tbl      ,
      x_return_status            =>  x_return_status          ,
      x_msg_count                =>  x_msg_count              ,
      x_msg_data                 =>  x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
		    FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		    FND_MESSAGE.Set_Token('API', 'ASO_ORDER_FEEDBACK_CUHK.Update_Notice_PRE', FALSE);
		    FND_MSG_PUB.ADD;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  END IF; -- customer pre processing

  -- vertical hook
  IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V'))
  THEN

    ASO_ORDER_FEEDBACK_VUHK.Update_Notice_PRE(
      p_header_rec	             => l_header_rec              ,
      p_old_header_rec           => l_old_header_rec          ,
      p_Header_Adj_tbl	         => l_Header_Adj_tbl          ,
      p_old_Header_Adj_tbl       => l_old_Header_Adj_tbl      ,
      p_Header_price_Att_tbl     => l_Header_price_Att_tbl    ,
      p_old_Header_Price_Att_tbl => l_old_Header_Price_Att_tbl,
      p_Header_Adj_Att_tbl       => l_Header_Adj_Att_tbl      ,
      p_old_Header_Adj_Att_tbl   => l_old_Header_Adj_Att_tbl  ,
      p_Header_Adj_Assoc_tbl     => l_Header_Adj_Assoc_tbl    ,
      p_old_Header_Adj_Assoc_tbl => l_old_Header_Adj_Assoc_tbl,
      p_Header_Scredit_tbl       => l_Header_Scredit_tbl      ,
      p_old_Header_Scredit_tbl   => l_old_Header_Scredit_tbl  ,
      p_line_tbl                 => l_line_tbl                ,
      p_old_line_tbl             => l_old_line_tbl            ,
      p_Line_Adj_tbl             => l_Line_Adj_tbl            ,
      p_old_Line_Adj_tbl         => l_old_Line_Adj_tbl        ,
      p_Line_Price_Att_tbl       => l_Line_Price_Att_tbl      ,
      p_old_Line_Price_Att_tbl   => l_old_Line_Price_Att_tbl  ,
      p_Line_Adj_Att_tbl         => l_Line_Adj_Att_tbl        ,
      p_old_Line_Adj_Att_tbl     => l_old_Line_Adj_Att_tbl    ,
      p_Line_Adj_Assoc_tbl       => l_Line_Adj_Assoc_tbl      ,
      p_old_Line_Adj_Assoc_tbl   => l_old_Line_Adj_Assoc_tbl  ,
      p_Line_Scredit_tbl         => l_Line_Scredit_tbl        ,
      p_old_Line_Scredit_tbl     => l_old_Line_Scredit_tbl    ,
      p_Lot_Serial_tbl           => l_Lot_Serial_tbl          ,
      p_old_Lot_Serial_tbl       => l_old_Lot_Serial_tbl      ,
      p_action_request_tbl       => l_action_request_tbl      ,
      x_return_status            =>  x_return_status          ,
      x_msg_count                =>  x_msg_count              ,
      x_msg_data                 =>  x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
		    FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		    FND_MESSAGE.Set_Token('API', 'ASO_ORDER_FEEDBACK_VUHK.Update_Notice_PRE', FALSE);
		    FND_MSG_PUB.ADD;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  END IF; -- vertical hook
-- end of 3042254.

	ASO_ORDER_FEEDBACK_UPDATE_PVT.UPDATE_NOTICE(
      p_api_version                         =>  1.0,
      p_init_msg_list                       =>  FND_API.G_FALSE,
      p_commit                              =>  FND_API.G_FALSE,
      x_return_status                       =>  x_return_status,
      x_msg_count                           =>  x_msg_count,
      x_msg_data                            =>  x_msg_data,
      p_queue_type                          =>  'OF_QUEUE',
      p_header_rec                          =>  p_header_rec,
      p_old_header_rec                      =>  p_old_header_rec,
      p_header_adj_tbl                      =>  p_header_adj_tbl,
      p_old_header_adj_tbl                  =>  p_old_header_adj_tbl,
      p_header_price_att_tbl                =>  p_header_price_att_tbl,
      p_old_header_price_att_tbl            =>  p_old_header_price_att_tbl,
      p_Header_Adj_Att_tbl                  =>  p_Header_Adj_Att_tbl,
      p_old_Header_Adj_Att_tbl              =>  p_old_Header_Adj_Att_tbl,
      p_Header_Adj_Assoc_tbl                =>  p_Header_Adj_Assoc_tbl,
      p_old_Header_Adj_Assoc_tbl            =>  p_old_Header_Adj_Assoc_tbl,
      p_Header_Scredit_tbl                  =>  p_Header_Scredit_tbl,
      p_old_Header_Scredit_tbl              =>  p_old_Header_Scredit_tbl,
      p_line_tbl                            =>  p_line_tbl,
      p_old_line_tbl                        =>  p_old_line_tbl,
      p_Line_Adj_tbl                        =>  p_Line_Adj_tbl,
      p_old_Line_Adj_tbl                    =>  p_old_Line_Adj_tbl,
      p_Line_Price_Att_tbl                  =>  p_Line_Price_Att_tbl,
      p_old_Line_Price_Att_tbl              =>  p_old_Line_Price_Att_tbl,
      p_Line_Adj_Att_tbl                    =>  p_Line_Adj_Att_tbl,
      p_old_Line_Adj_Att_tbl                =>  p_old_Line_Adj_Att_tbl,
      p_Line_Adj_Assoc_tbl                  =>  p_Line_Adj_Assoc_tbl,
      p_old_Line_Adj_Assoc_tbl              =>  p_old_Line_Adj_Assoc_tbl,
      p_Line_Scredit_tbl                    =>  p_Line_Scredit_tbl,
      p_old_Line_Scredit_tbl                =>  p_old_Line_Scredit_tbl,
      p_Lot_Serial_tbl                      =>  p_Lot_Serial_tbl,
      p_old_Lot_Serial_tbl                  =>  p_old_Lot_Serial_tbl,
      p_action_request_tbl                  =>  p_action_request_tbl
 );


  	IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    		ROLLBACK TO  UPDATE_NOTICE_PUB;
    		RETURN;
  	END IF;

  -- 3042254
  -- call user hooks
  -- customer post processing

  IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C'))
  THEN
    ASO_ORDER_FEEDBACK_CUHK.Update_Notice_POST(
      p_header_rec    	         => l_header_rec              ,
      p_old_header_rec           => l_old_header_rec          ,
      p_Header_Adj_tbl	         => l_Header_Adj_tbl          ,
      p_old_Header_Adj_tbl       => l_old_Header_Adj_tbl      ,
      p_Header_price_Att_tbl     => l_Header_price_Att_tbl    ,
      p_old_Header_Price_Att_tbl => l_old_Header_Price_Att_tbl,
      p_Header_Adj_Att_tbl       => l_Header_Adj_Att_tbl      ,
      p_old_Header_Adj_Att_tbl   => l_old_Header_Adj_Att_tbl  ,
      p_Header_Adj_Assoc_tbl     => l_Header_Adj_Assoc_tbl    ,
      p_old_Header_Adj_Assoc_tbl => l_old_Header_Adj_Assoc_tbl,
      p_Header_Scredit_tbl       => l_Header_Scredit_tbl      ,
      p_old_Header_Scredit_tbl   => l_old_Header_Scredit_tbl  ,
      p_line_tbl                 => l_line_tbl                ,
      p_old_line_tbl             => l_old_line_tbl            ,
      p_Line_Adj_tbl             => l_Line_Adj_tbl            ,
      p_old_Line_Adj_tbl         => l_old_Line_Adj_tbl        ,
      p_Line_Price_Att_tbl       => l_Line_Price_Att_tbl      ,
      p_old_Line_Price_Att_tbl   => l_old_Line_Price_Att_tbl  ,
      p_Line_Adj_Att_tbl         => l_Line_Adj_Att_tbl        ,
      p_old_Line_Adj_Att_tbl     => l_old_Line_Adj_Att_tbl    ,
      p_Line_Adj_Assoc_tbl       => l_Line_Adj_Assoc_tbl      ,
      p_old_Line_Adj_Assoc_tbl   => l_old_Line_Adj_Assoc_tbl  ,
      p_Line_Scredit_tbl         => l_Line_Scredit_tbl        ,
      p_old_Line_Scredit_tbl     => l_old_Line_Scredit_tbl    ,
      p_Lot_Serial_tbl           => l_Lot_Serial_tbl          ,
      p_old_Lot_Serial_tbl       => l_old_Lot_Serial_tbl      ,
      p_action_request_tbl       => l_action_request_tbl      ,
      x_return_status            =>  x_return_status          ,
      x_msg_count                =>  x_msg_count              ,
      x_msg_data                 =>  x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
		    FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		    FND_MESSAGE.Set_Token('API', 'ASO_ORDER_FEEDBACK_CUHK.Update_Notice_POST', FALSE);
		    FND_MSG_PUB.ADD;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  END IF; -- customer pre processing

  -- vertical hook
  IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V'))
  THEN

    ASO_ORDER_FEEDBACK_VUHK.Update_Notice_POST(
      p_header_rec    	         => l_header_rec              ,
      p_old_header_rec           => l_old_header_rec          ,
      p_Header_Adj_tbl	         => l_Header_Adj_tbl          ,
      p_old_Header_Adj_tbl       => l_old_Header_Adj_tbl      ,
      p_Header_price_Att_tbl     => l_Header_price_Att_tbl    ,
      p_old_Header_Price_Att_tbl => l_old_Header_Price_Att_tbl,
      p_Header_Adj_Att_tbl       => l_Header_Adj_Att_tbl      ,
      p_old_Header_Adj_Att_tbl   => l_old_Header_Adj_Att_tbl  ,
      p_Header_Adj_Assoc_tbl     => l_Header_Adj_Assoc_tbl    ,
      p_old_Header_Adj_Assoc_tbl => l_old_Header_Adj_Assoc_tbl,
      p_Header_Scredit_tbl       => l_Header_Scredit_tbl      ,
      p_old_Header_Scredit_tbl   => l_old_Header_Scredit_tbl  ,
      p_line_tbl                 => l_line_tbl                ,
      p_old_line_tbl             => l_old_line_tbl            ,
      p_Line_Adj_tbl             => l_Line_Adj_tbl            ,
      p_old_Line_Adj_tbl         => l_old_Line_Adj_tbl        ,
      p_Line_Price_Att_tbl       => l_Line_Price_Att_tbl      ,
      p_old_Line_Price_Att_tbl   => l_old_Line_Price_Att_tbl  ,
      p_Line_Adj_Att_tbl         => l_Line_Adj_Att_tbl        ,
      p_old_Line_Adj_Att_tbl     => l_old_Line_Adj_Att_tbl    ,
      p_Line_Adj_Assoc_tbl       => l_Line_Adj_Assoc_tbl      ,
      p_old_Line_Adj_Assoc_tbl   => l_old_Line_Adj_Assoc_tbl  ,
      p_Line_Scredit_tbl         => l_Line_Scredit_tbl        ,
      p_old_Line_Scredit_tbl     => l_old_Line_Scredit_tbl    ,
      p_Lot_Serial_tbl           => l_Lot_Serial_tbl          ,
      p_old_Lot_Serial_tbl       => l_old_Lot_Serial_tbl      ,
      p_action_request_tbl       => l_action_request_tbl      ,
      x_return_status            =>  x_return_status          ,
      x_msg_count                =>  x_msg_count              ,
      x_msg_data                 =>  x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
		    FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
		    FND_MESSAGE.Set_Token('API', 'ASO_ORDER_FEEDBACK_VUHK.Update_Notice_POST', FALSE);
		    FND_MSG_PUB.ADD;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

  END IF; -- vertical hook
-- end of 3042254.


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
		ROLLBACK TO  UPDATE_NOTICE_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  UPDATE_NOTICE_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
		 	 p_data => x_msg_data
      	);
	WHEN OTHERS THEN
		ROLLBACK TO UPDATE_NOTICE_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
END UPDATE_NOTICE;


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
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */  Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
--   x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2(2000)
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
--  Version :  Current version   1.0
--             Initial version   1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE GET_NOTICE
(
 p_api_version                   IN   NUMBER,
 p_init_msg_list                 IN   VARCHAR2  := FND_API.G_FALSE,
 p_commit                        IN   VARCHAR2  := FND_API.G_FALSE,
 x_return_status                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 x_msg_count                     OUT NOCOPY /* file.sql.39 change */   NUMBER,
 x_msg_data                      OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 p_app_short_name                IN   VARCHAR2,
 p_wait                          IN   NUMBER    := DBMS_AQ.NO_WAIT,
 p_deq_condition                 IN   VARCHAR2  DEFAULT NULL, /* Bug 9410311 */
 --Bug19061037
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
) IS
   l_api_name     CONSTANT    VARCHAR2(30)   := 'GET_NOTICE';
   l_api_version  CONSTANT    NUMBER         := 1.0;

BEGIN

   aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

   -- Standard Start of API savepoint

   SAVEPOINT   GET_NOTICE_PUB;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version ,
                         p_api_version ,
                         l_api_name ,
                         G_PKG_NAME )  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- GET_NOTICE API specific input parameter validation logic

      -- need to check that p_app_short_name (required param) is passed in

      ASO_ORDER_FEEDBACK_UTIL.Check_Reqd_Param
      (
        p_app_short_name,
        'p_app_short_name',
        l_api_name
      );

      -- need to check that p_app_short_name is a valid application short name

      ASO_ORDER_FEEDBACK_UTIL.Check_LookupCode
      (
            'ASO_ORDER_FEEDBACK_CRM_APPS',
            p_app_short_name,
            'p_app_short_name',
            l_api_name
      );

   -- API Body


   ASO_ORDER_FEEDBACK_GET_PVT.GET_NOTICE(
      p_api_version                         =>  1.0,
      p_init_msg_list                       =>  FND_API.G_FALSE,
      p_commit                              =>  FND_API.G_FALSE,
      x_return_status                       =>  x_return_status,
      x_msg_count                           =>  x_msg_count,
      x_msg_data                            =>  x_msg_data,
      p_app_short_name                      =>  p_app_short_name,
	 p_queue_type                          =>  'OF_QUEUE',
      p_wait                                =>  p_wait,
	 p_deq_condition                       =>  p_deq_condition, -- bug 9410311
	  p_navigation                          => p_navigation,
      x_no_more_messages                    =>  x_no_more_messages,
      x_header_rec                          =>  x_header_rec,
      x_old_header_rec                      =>  x_old_header_rec,
      x_header_adj_tbl                      =>  x_header_adj_tbl,
      x_old_header_adj_tbl                  =>  x_old_header_adj_tbl,
      x_header_price_att_tbl                =>  x_header_price_att_tbl,
      x_old_header_price_att_tbl            =>  x_old_header_price_att_tbl,
      x_Header_Adj_Att_tbl                  =>  x_Header_Adj_Att_tbl,
      x_old_Header_Adj_Att_tbl              =>  x_old_Header_Adj_Att_tbl,
      x_Header_Adj_Assoc_tbl                =>  x_Header_Adj_Assoc_tbl,
      x_old_Header_Adj_Assoc_tbl            =>  x_old_Header_Adj_Assoc_tbl,
      x_Header_Scredit_tbl                  =>  x_Header_Scredit_tbl,
      x_old_Header_Scredit_tbl              =>  x_old_Header_Scredit_tbl,
      x_line_tbl                            =>  x_line_tbl,
      x_old_line_tbl                        =>  x_old_line_tbl,
      x_Line_Adj_tbl                        =>  x_Line_Adj_tbl,
      x_old_Line_Adj_tbl                    =>  x_old_Line_Adj_tbl,
      x_Line_Price_Att_tbl                  =>  x_Line_Price_Att_tbl,
      x_old_Line_Price_Att_tbl              =>  x_old_Line_Price_Att_tbl,
      x_Line_Adj_Att_tbl                    =>  x_Line_Adj_Att_tbl,
      x_old_Line_Adj_Att_tbl                =>  x_old_Line_Adj_Att_tbl,
      x_Line_Adj_Assoc_tbl                  =>  x_Line_Adj_Assoc_tbl,
      x_old_Line_Adj_Assoc_tbl              =>  x_old_Line_Adj_Assoc_tbl,
      x_Line_Scredit_tbl                    =>  x_Line_Scredit_tbl,
      x_old_Line_Scredit_tbl                =>  x_old_Line_Scredit_tbl,
      x_Lot_Serial_tbl                      =>  x_Lot_Serial_tbl,
      x_old_Lot_Serial_tbl                  =>  x_old_Lot_Serial_tbl,
      x_action_request_tbl                  =>  x_action_request_tbl
 );

   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         ROLLBACK TO  GET_NOTICE_PUB;
         RETURN;
   END IF;

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
      ROLLBACK TO  GET_NOTICE_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  GET_NOTICE_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
   WHEN OTHERS THEN
      ROLLBACK TO GET_NOTICE_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
END GET_NOTICE;


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
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */  Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
--   x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2(2000)
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
--  Version :  Current version   1.0
--             Initial version   1.0
--
-- End of comments
--------------------------------------------------------------------------


PROCEDURE HANDLE_EXCEPTION
(
 p_api_version                   IN  NUMBER,
 p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
 p_commit                        IN  VARCHAR2 := FND_API.G_FALSE,
 x_return_status                 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 x_msg_count                     OUT NOCOPY /* file.sql.39 change */  NUMBER,
 x_msg_data                      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
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
) IS
	l_api_name		CONSTANT		VARCHAR2(30)	:= 'HANDLE_EXCEPTION';
	l_api_version	CONSTANT		NUMBER			:= 1.0;

BEGIN

     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

	-- Standard Start of API savepoint

	SAVEPOINT	HANDLE_EXCEPTION_PUB;

	-- Standard call to check for call compatibility.

	IF NOT FND_API.Compatible_API_Call (l_api_version ,
								 p_api_version ,
								 l_api_name ,
								 G_PKG_NAME )	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- HANDLE_EXCEPTION API specific input parameter validation logic
      -- need to check that p_app_short_name (required param) is passed in

      ASO_ORDER_FEEDBACK_UTIL.Check_Reqd_Param
      (
        p_app_short_name,
        'p_app_short_name',
        l_api_name
      );

      -- need to check that p_app_short_name is a valid application short name

      ASO_ORDER_FEEDBACK_UTIL.Check_LookupCode
      (
            'ASO_ORDER_FEEDBACK_CRM_APPS',
            p_app_short_name,
            'p_app_short_name',
            l_api_name
      );


	-- API Body


	ASO_ORDER_FEEDBACK_UPDATE_PVT.UPDATE_NOTICE(
      p_api_version                         =>  1.0,
      p_init_msg_list                       =>  FND_API.G_FALSE,
      p_commit                              =>  FND_API.G_FALSE,
      x_return_status                       =>  x_return_status,
      x_msg_count                           =>  x_msg_count,
      x_msg_data                            =>  x_msg_data,
      p_app_short_name                      =>  p_app_short_name,
      p_queue_type                          =>  'OF_EXCP_QUEUE',
      p_header_rec                          =>  p_header_rec,
      p_old_header_rec                      =>  p_old_header_rec,
      p_header_adj_tbl                      =>  p_header_adj_tbl,
      p_old_header_adj_tbl                  =>  p_old_header_adj_tbl,
      p_header_price_att_tbl                =>  p_header_price_att_tbl,
      p_old_header_price_att_tbl            =>  p_old_header_price_att_tbl,
      p_Header_Adj_Att_tbl                  =>  p_Header_Adj_Att_tbl,
      p_old_Header_Adj_Att_tbl              =>  p_old_Header_Adj_Att_tbl,
      p_Header_Adj_Assoc_tbl                =>  p_Header_Adj_Assoc_tbl,
      p_old_Header_Adj_Assoc_tbl            =>  p_old_Header_Adj_Assoc_tbl,
      p_Header_Scredit_tbl                  =>  p_Header_Scredit_tbl,
      p_old_Header_Scredit_tbl              =>  p_old_Header_Scredit_tbl,
      p_line_tbl                            =>  p_line_tbl,
      p_old_line_tbl                        =>  p_old_line_tbl,
      p_Line_Adj_tbl                        =>  p_Line_Adj_tbl,
      p_old_Line_Adj_tbl                    =>  p_old_Line_Adj_tbl,
      p_Line_Price_Att_tbl                  =>  p_Line_Price_Att_tbl,
      p_old_Line_Price_Att_tbl              =>  p_old_Line_Price_Att_tbl,
      p_Line_Adj_Att_tbl                    =>  p_Line_Adj_Att_tbl,
      p_old_Line_Adj_Att_tbl                =>  p_old_Line_Adj_Att_tbl,
      p_Line_Adj_Assoc_tbl                  =>  p_Line_Adj_Assoc_tbl,
      p_old_Line_Adj_Assoc_tbl              =>  p_old_Line_Adj_Assoc_tbl,
      p_Line_Scredit_tbl                    =>  p_Line_Scredit_tbl,
      p_old_Line_Scredit_tbl                =>  p_old_Line_Scredit_tbl,
      p_Lot_Serial_tbl                      =>  p_Lot_Serial_tbl,
      p_old_Lot_Serial_tbl                  =>  p_old_Lot_Serial_tbl,
      p_action_request_tbl                  =>  p_action_request_tbl
 );


  	IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    		ROLLBACK TO  HANDLE_EXCEPTION_PUB;
    		RETURN;
  	END IF;

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
		ROLLBACK TO  HANDLE_EXCEPTION_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO  HANDLE_EXCEPTION_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
		 	 p_data => x_msg_data
      	);
	WHEN OTHERS THEN
		ROLLBACK TO HANDLE_EXCEPTION_PUB;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
END HANDLE_EXCEPTION;

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
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */  Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
--   x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2(2000)
--
--  GET_EXCEPTION API specific IN Parameters:
--   p_app_short_name   IN    VARCHAR2  Required
--   p_wait             IN    NUMBER    Optional
--                                      Default = DBMS_AQ.NO_WAIT
--   p_dequeue_mode       IN    VARCHAR2  Optional
--                                      Default = DBMS_AQ.REMOVE
--   p_navigation       IN   VARCHAR2   Optional
--                         DEFAULT = DBMS_AQ.FIRST_MESSAGE,
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
--  Version :  Current version   1.0
--             Initial version   1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE GET_EXCEPTION
(
 p_api_version                   IN   NUMBER,
 p_init_msg_list                 IN   VARCHAR2  := FND_API.G_FALSE,
 p_commit                        IN   VARCHAR2  := FND_API.G_FALSE,
 x_return_status                 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 x_msg_count                     OUT NOCOPY /* file.sql.39 change */   NUMBER,
 x_msg_data                      OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
 p_app_short_name                IN   VARCHAR2,
 p_wait                          IN   NUMBER    := DBMS_AQ.NO_WAIT,
 p_dequeue_mode                  IN   VARCHAR2  := DBMS_AQ.REMOVE,
 p_navigation                    IN   VARCHAR2  := DBMS_AQ.FIRST_MESSAGE,
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
) IS
   l_api_name     CONSTANT    VARCHAR2(30)   := 'GET_EXCEPTION';
   l_api_version  CONSTANT    NUMBER         := 1.0;

BEGIN

  aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
   -- Standard Start of API savepoint

   SAVEPOINT   GET_EXCEPTION_PUB;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version ,
                         p_api_version ,
                         l_api_name ,
                         G_PKG_NAME )  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- GET_EXCEPTION API specific input parameter validation logic

      -- need to check that p_app_short_name (required param) is passed in

      ASO_ORDER_FEEDBACK_UTIL.Check_Reqd_Param
      (
        p_app_short_name,
        'p_app_short_name',
        l_api_name
      );

      -- need to check that p_app_short_name is a valid application short name

      ASO_ORDER_FEEDBACK_UTIL.Check_LookupCode
      (
            'ASO_ORDER_FEEDBACK_CRM_APPS',
            p_app_short_name,
            'p_app_short_name',
            l_api_name
      );

   -- API Body


   ASO_ORDER_FEEDBACK_GET_PVT.GET_NOTICE(
      p_api_version                         =>  1.0,
      p_init_msg_list                       =>  FND_API.G_FALSE,
      p_commit                              =>  FND_API.G_FALSE,
      x_return_status                       =>  x_return_status,
      x_msg_count                           =>  x_msg_count,
      x_msg_data                            =>  x_msg_data,
      p_app_short_name                      =>  p_app_short_name,
      p_wait                                =>  p_wait,
      p_dequeue_mode                        =>  p_dequeue_mode,
      --Bug19061037
	 p_navigation                          =>  p_navigation,
      p_queue_type                          =>  'OF_EXCP_QUEUE',
      x_no_more_messages                    =>  x_no_more_messages,
      x_header_rec                          =>  x_header_rec,
      x_old_header_rec                      =>  x_old_header_rec,
      x_header_adj_tbl                      =>  x_header_adj_tbl,
      x_old_header_adj_tbl                  =>  x_old_header_adj_tbl,
      x_header_price_att_tbl                =>  x_header_price_att_tbl,
      x_old_header_price_att_tbl            =>  x_old_header_price_att_tbl,
      x_Header_Adj_Att_tbl                  =>  x_Header_Adj_Att_tbl,
      x_old_Header_Adj_Att_tbl              =>  x_old_Header_Adj_Att_tbl,
      x_Header_Adj_Assoc_tbl                =>  x_Header_Adj_Assoc_tbl,
      x_old_Header_Adj_Assoc_tbl            =>  x_old_Header_Adj_Assoc_tbl,
      x_Header_Scredit_tbl                  =>  x_Header_Scredit_tbl,
      x_old_Header_Scredit_tbl              =>  x_old_Header_Scredit_tbl,
      x_line_tbl                            =>  x_line_tbl,
      x_old_line_tbl                        =>  x_old_line_tbl,
      x_Line_Adj_tbl                        =>  x_Line_Adj_tbl,
      x_old_Line_Adj_tbl                    =>  x_old_Line_Adj_tbl,
      x_Line_Price_Att_tbl                  =>  x_Line_Price_Att_tbl,
      x_old_Line_Price_Att_tbl              =>  x_old_Line_Price_Att_tbl,
      x_Line_Adj_Att_tbl                    =>  x_Line_Adj_Att_tbl,
      x_old_Line_Adj_Att_tbl                =>  x_old_Line_Adj_Att_tbl,
      x_Line_Adj_Assoc_tbl                  =>  x_Line_Adj_Assoc_tbl,
      x_old_Line_Adj_Assoc_tbl              =>  x_old_Line_Adj_Assoc_tbl,
      x_Line_Scredit_tbl                    =>  x_Line_Scredit_tbl,
      x_old_Line_Scredit_tbl                =>  x_old_Line_Scredit_tbl,
      x_Lot_Serial_tbl                      =>  x_Lot_Serial_tbl,
      x_old_Lot_Serial_tbl                  =>  x_old_Lot_Serial_tbl,
      x_action_request_tbl                  =>  x_action_request_tbl
 );

   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         ROLLBACK TO  GET_EXCEPTION_PUB;
         RETURN;
   END IF;

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
      ROLLBACK TO  GET_EXCEPTION_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  GET_EXCEPTION_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
   WHEN OTHERS THEN
      ROLLBACK TO GET_EXCEPTION_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
END GET_EXCEPTION;

END ASO_ORDER_FEEDBACK_PUB;

/
