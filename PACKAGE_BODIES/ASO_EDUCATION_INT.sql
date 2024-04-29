--------------------------------------------------------
--  DDL for Package Body ASO_EDUCATION_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_EDUCATION_INT" as
/* $Header: asoiedub.pls 120.1 2005/06/29 12:33:17 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_EDUCATION_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


PROCEDURE Delete_OTA_Line(
	P_Init_Msg_List	IN	VARCHAR2 := FND_API.G_FALSE,
	P_Commit			IN	VARCHAR2 := FND_API.G_FALSE,
	P_Qte_Line_Id		IN	NUMBER,
	X_Return_Status OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
	X_Msg_Count	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
	X_Msg_Data	 OUT NOCOPY /* file.sql.39 change */  	VARCHAR2 )

IS

	CURSOR C_Get_UOM(l_qte_ln_id NUMBER) IS
	 SELECT UOM_Code FROM ASO_QUOTE_LINES_ALL
	 WHERE Quote_Line_Id = l_qte_ln_id;

	l_UOM_Code		VARCHAR2(3);

BEGIN

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Enter Delete_OTA_Line ', 1, 'Y');
  aso_debug_pub.add('Delete_OTA_Line- P_Qte_Line_Id: '||P_Qte_Line_Id, 1, 'N');
END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( P_Init_Msg_List ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

	OPEN C_Get_UOM(P_Qte_Line_Id);
	FETCH C_Get_UOM INTO l_UOM_Code;
	CLOSE C_Get_UOM;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Delete_OTA_Line- l_UOM_Code: '||l_UOM_Code, 1, 'N');
END IF;

	IF l_UOM_Code = 'ENR' THEN

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Delete_OTA_Line- l_UOM_Code=ENR ', 1, 'N');
END IF;
/*
		OTA_ASO_INTERFACE.ota_aso_del(
			P_Api_Version		=>	1.0,
			P_Init_Msg_List	=>	FND_API.G_FALSE,
			P_Commit			=>	FND_API.G_FALSE,
			P_Quote_Line_Id	=>	P_Qte_Line_Id,
			X_Return_Status	=>	X_Return_Status,
			X_Msg_Count		=>	X_Msg_Count,
			X_Msg_Data		=>	X_Msg_Data);
aso_debug_pub.add('Delete_OTA_Line- after OTA_ASO_INTERFACE.ota_aso_del: '||X_Return_Status, 1, 'N');
		IF X_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
	  		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    			FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_DELETE_OTA_LINE');
	    			FND_MSG_PUB.ADD;
	  		END IF;
		END IF;
*/
	END IF;

END Delete_OTA_Line;


PROCEDURE Update_OTA_With_OrderLine(
     P_Init_Msg_List     IN   VARCHAR2 := FND_API.G_FALSE,
     P_Commit            IN   VARCHAR2 := FND_API.G_FALSE,
     P_Order_Line_Tbl      IN   ASO_ORDER_INT.Order_Line_Tbl_Type,
     X_Return_Status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     X_Msg_Count         OUT NOCOPY /* file.sql.39 change */    NUMBER,
     X_Msg_Data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2 )

IS

     CURSOR C_Get_UOM_Line(l_ship_ln_id NUMBER) IS
      SELECT qtl.UOM_Code, qtl.Quote_Line_Id
	 FROM ASO_QUOTE_LINES_ALL qtl, ASO_SHIPMENTS shp
      WHERE shp.Shipment_Id = l_ship_ln_id
	 AND shp.Quote_Line_Id = qtl.Quote_Line_Id;

     l_UOM_Code          VARCHAR2(3);
	l_Qte_Line_Id		NUMBER;

BEGIN

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Enter Update_OTA_Line ', 1, 'Y');
  aso_debug_pub.add('Update_OTA_Line- P_Order_Line_Tbl.count: '||P_Order_Line_Tbl.count, 1, 'N');
END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( P_Init_Msg_List ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    X_Return_Status := FND_API.G_RET_STS_SUCCESS;

    FOR i IN 1..P_Order_Line_Tbl.count LOOP

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Update_OTA_Line- P_Order_Line_Tbl(i).Quote_Shipment_Line_Id: '||P_Order_Line_Tbl(i).Quote_Shipment_Line_Id, 1, 'N');
END IF;

     OPEN C_Get_UOM_Line(P_Order_Line_Tbl(i).Quote_Shipment_Line_Id);
     FETCH C_Get_UOM_Line INTO l_UOM_Code, l_Qte_Line_Id;
     CLOSE C_Get_UOM_Line;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Update_OTA_Line- l_UOM_Code: '||l_UOM_Code, 1, 'N');
  aso_debug_pub.add('Update_OTA_Line- l_Qte_Line_Id: '||l_Qte_Line_Id, 1, 'N');
END IF;

     IF l_UOM_Code = 'ENR' THEN

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  aso_debug_pub.add('Update_OTA_Line- l_UOM_Code=ENR ', 1, 'N');
END IF;
/*
          OTA_ASO_INTERFACE.ota_aso_upd(
			P_Api_Version		=>	1.0,
               P_Init_Msg_List     =>   FND_API.G_FALSE,
               P_Commit            =>   FND_API.G_FALSE,
               P_Quote_Line_Id     =>   l_Qte_Line_Id,
			P_Order_Line_Id	=>	P_Order_Line_Tbl(i).Order_Line_Id,
               X_Return_Status     =>   X_Return_Status,
               X_Msg_Count          =>   X_Msg_Count,
               X_Msg_Data          =>   X_Msg_Data);
aso_debug_pub.add('Update_OTA_Line- after OTA_ASO_INTERFACE.ota_aso_upd: '||X_Return_Status, 1, 'N');
          IF X_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_UPDATE_OTA_LINE');
                    FND_MSG_PUB.ADD;
               END IF;
          END IF;
*/
     END IF;  -- UOM = 'ENR'

    END LOOP;  -- Order_line_tbl

END Update_OTA_With_OrderLine;


END ASO_EDUCATION_INT;

/
