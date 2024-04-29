--------------------------------------------------------
--  DDL for Package Body ASO_COPY_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_COPY_QUOTE_PUB" as
/* $Header: asopcpyb.pls 120.1.12010000.5 2010/04/30 05:21:32 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_COPY_QUOTE_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_Copy_Quote_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asopcpyb.pls';


PROCEDURE Copy_Quote(
     P_Api_Version_Number          IN   NUMBER,
     P_Init_Msg_List               IN   VARCHAR2     := FND_API.G_FALSE,
     P_Commit                      IN   VARCHAR2     := FND_API.G_FALSE,
     P_Copy_Quote_Header_Rec       IN   ASO_COPY_QUOTE_PUB.Copy_Quote_Header_Rec_Type
									:= ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Header_Rec,
     P_Copy_Quote_Control_Rec      IN   ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type
									:= ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Control_Rec,
     /* Code change for Quoting Usability Sun ER Start */
     P_Qte_Header_Rec          IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type        := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
     P_Hd_Shipment_Rec         IN  ASO_QUOTE_PUB.Shipment_Rec_Type          := ASO_QUOTE_PUB.G_MISS_Shipment_Rec,
     P_hd_Payment_Tbl	       IN  ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL,
     P_hd_Tax_Detail_Tbl       IN  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl,
     /* Code change for Quoting Usability Sun ER End */
     X_Qte_Header_Id               OUT NOCOPY /* file.sql.39 change */   NUMBER,
	X_Qte_Number			 OUT NOCOPY /* file.sql.39 change */   NUMBER,
     X_Return_Status               OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
     X_Msg_Count                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
     X_Msg_Data                    OUT NOCOPY /* file.sql.39 change */   VARCHAR2 )
IS

  l_api_version             NUMBER        := 1.0;
  l_api_name                VARCHAR2(50)  := 'Copy_Quote';

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Copy_Quote_PUB;

  aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                     	              p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- API body
  --

ASO_COPY_QUOTE_PVT.Copy_Quote(
	P_Api_Version_Number		=>	P_Api_Version_Number,
	P_Init_Msg_List			=>	P_Init_Msg_List,
	P_Commit					=>	P_Commit,
	P_Copy_Quote_Header_Rec		=>	P_Copy_Quote_Header_Rec,
	P_Copy_Quote_Control_Rec		=>	P_Copy_Quote_Control_Rec,
	/* Code change for Quoting Usability Sun ER Start */
	P_Qte_Header_Rec   => P_Qte_Header_Rec,
        P_Hd_Shipment_Rec  => P_Hd_Shipment_Rec,
        P_hd_Payment_Tbl => P_hd_Payment_Tbl,
        P_hd_Tax_Detail_Tbl => P_hd_Tax_Detail_Tbl,
	/* Code change for Quoting Usability Sun ER End */
	X_Qte_Header_Id			=>	X_Qte_Header_Id,
	X_Qte_Number				=>	X_Qte_Number,
	X_Return_Status			=>	X_Return_Status,
	X_Msg_Count				=>	X_Msg_Count,
	X_Msg_Data				=>	X_Msg_Data );

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- End of API body.
  --

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;


  -- Debug Message
  ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);

END Copy_Quote;


PROCEDURE Copy_Line(
     P_Api_Version_Number     IN  NUMBER,
     P_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
     P_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
     P_Qte_Header_Id          IN  NUMBER,
     P_Qte_Line_Id            IN  NUMBER   := NULL,
     P_Copy_Quote_Control_Rec IN  ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type,
     P_Qte_Header_Rec         IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     P_Control_Rec            IN   ASO_QUOTE_PUB.Control_Rec_Type,
	X_Qte_Line_Id            OUT NOCOPY /* file.sql.39 change */   NUMBER,
	X_Return_Status          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
     X_Msg_Count              OUT NOCOPY /* file.sql.39 change */   NUMBER,
     X_Msg_Data               OUT NOCOPY /* file.sql.39 change */   VARCHAR2 )

IS


  l_api_version             NUMBER        := 1.0;
  l_api_name                VARCHAR2(50)  := 'Copy_Line';
  l_qte_header_rec          ASO_QUOTE_PUB.Qte_Header_Rec_Type;
  l_Copy_Quote_Control_Rec  ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type;

   -- ER 3177722
lx_config_tbl                  ASO_QUOTE_PUB.Config_Vaild_Tbl_Type;
l_copy_config_profile     varchar2(1):=nvl(fnd_profile.value('ASO_COPY_CONFIG_EFF_DATE'),'Y');
l_item_type_code            varchar2(30);


BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Copy_Line_PUB;

  aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- API body
  --

     IF ( P_Qte_Line_Id IS NULL OR P_Qte_Line_Id = FND_API.G_MISS_NUM ) THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
           FND_MESSAGE.Set_Token('COLUMN', 'P_Qte_Line_Id', FALSE);
           FND_MSG_PUB.ADD;
       END IF;
       raise FND_API.G_EXC_ERROR;
      End if;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( ' Calling Copy_Line_Rows API ' , 1 , 'N' );
    END IF;

    l_qte_header_rec := P_Qte_Header_Rec;

    l_qte_header_rec.batch_price_flag := FND_API.G_TRUE;

    l_Copy_Quote_Control_Rec := P_Copy_Quote_Control_Rec;

     -- change for sales supp enhancement  as per bug 2940126
    l_Copy_Quote_Control_Rec.New_Version := FND_API.G_TRUE;


  ASO_COPY_QUOTE_PVT.Copy_Line_Rows (
     P_Api_Version_Number     => P_Api_Version_Number,
     P_Init_Msg_List          => P_Init_Msg_List,
     P_Commit                 => P_Commit,
     P_Qte_Header_Id          => P_Qte_Header_Id,
     P_New_Qte_Header_Id      => P_Qte_Header_Id,
     P_Qte_Line_Id            => P_Qte_Line_Id,
     P_Price_Index_Link_Tbl   => ASO_QUOTE_HEADERS_PVT.G_MISS_LINK_TBL,
     P_Copy_Quote_Control_Rec => l_Copy_Quote_Control_Rec,
     P_Qte_Header_Rec         => l_qte_header_rec,
     P_Control_Rec            => P_Control_Rec,
     X_Qte_Line_Id            => X_Qte_Line_Id,
     X_Return_Status          => X_Return_Status,
     X_Msg_Count              => X_Msg_Count,
     X_Msg_Data               => X_Msg_Data);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( ' After calling Copy_Line_rows API ' , 1 , 'N' );
    END IF;

 -- ER 3177722

      if (x_return_status =FND_API.G_RET_STS_SUCCESS) then

        if l_copy_config_profile='N' then
	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Copy_Line -before   ASO_QUOTE_PUB.validate_model_configuration l_quote_header_rec:  '||P_Qte_Header_Id, 1, 'N');
           aso_debug_pub.add('Copy_Line -before   ASO_QUOTE_PUB.validate_model_configuration X_Qte_Line_Id:  '||X_Qte_Line_Id, 1, 'N');
	   end if;
           select item_type_code into l_item_type_code
           from aso_Quote_lines_all
           where quote_line_id=X_Qte_Line_Id;
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Copy_Line -before   ASO_QUOTE_PUB.validate_model_configuration l_item_type_code:  '||l_item_type_code, 1, 'N');
	   end if;

           if l_item_type_code='MDL' then

              ASO_QUOTE_PUB.validate_model_configuration
              (
              P_Api_Version_Number  => 1.0,
              P_Init_Msg_List       => FND_API.G_FALSE,
              P_Commit              => FND_API.G_FALSE,
              P_Quote_header_id     =>P_Qte_Header_Id,
              p_Quote_line_id => X_Qte_Line_Id,
              P_UPDATE_QUOTE        =>'T',
              P_CONFIG_EFFECTIVE_DATE      => sysdate,
              P_CONFIG_model_lookup_DATE   => sysdate,
              X_Config_tbl          => lx_config_tbl,
              X_Return_Status       => x_return_status,
              X_Msg_Count           => x_msg_count,
              X_Msg_Data            => x_msg_data
               );

              /*if (x_Return_Status=FND_API.G_RET_STS_SUCCESS) and (lx_config_tbl.count>0) then
                       commit work;
              end if;
              */

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Copy_Line -After  ASO_QUOTE_PUB.validate_model_configuration return status:  '||x_Return_Status, 1, 'N');
              aso_debug_pub.add('Copy_Line -After  ASO_QUOTE_PUB.validate_model_configuration lx_config_tbl:  '||lx_config_tbl.count, 1, 'N');
              aso_debug_pub.add('Copy_Line -After  ASO_QUOTE_PUB.validate_model_configuration x_msg_count:  '||x_msg_count, 1, 'N');
              END IF;
        END IF; -- MDL
 end if; -- profile
end if; -- in case success

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- End of API body.
  --

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;


  -- Debug Message
  ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);

END Copy_Line;

PROCEDURE Copy_Line(
     P_Api_Version_Number     IN  NUMBER,
     P_Init_Msg_List          IN  VARCHAR2     := FND_API.G_FALSE,
     P_Commit                 IN  VARCHAR2     := FND_API.G_FALSE,
     P_Qte_Header_Id          IN  NUMBER,
     P_Qte_Line_Id            IN  NUMBER   := NULL,
     P_Copy_Quote_Control_Rec IN  ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type,
     P_Qte_Header_Rec         IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     P_Control_Rec            IN   ASO_QUOTE_PUB.Control_Rec_Type,
     X_Qte_Line_Id            OUT NOCOPY /* file.sql.39 change */   NUMBER,
     X_Qte_Header_Rec         OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     X_Return_Status          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
     X_Msg_Count              OUT NOCOPY /* file.sql.39 change */   NUMBER,
     X_Msg_Data               OUT NOCOPY /* file.sql.39 change */   VARCHAR2 )

IS

  l_header_id               NUMBER;
  Cursor c_get_header_id (l_line_id NUMBER) IS
  Select quote_header_id
  from aso_quote_lines_all
  where quote_line_id = l_line_id;
BEGIN

     ASO_COPY_QUOTE_PUB.Copy_Line(
     P_Api_Version_Number     => P_Api_Version_Number,
     P_Init_Msg_List          => P_Init_Msg_List,
     P_Commit                 => P_Commit,
     P_Qte_Header_Id          => P_Qte_Header_Id,
     P_Qte_Line_Id            => P_Qte_Line_Id,
     P_Copy_Quote_Control_Rec => P_Copy_Quote_Control_Rec,
     P_Qte_Header_Rec         => P_Qte_Header_Rec,
     P_Control_Rec            => P_Control_Rec,
     X_Qte_Line_Id            => X_Qte_Line_Id,
     X_Return_Status          => X_Return_Status,
     X_Msg_Count              => X_Msg_Count,
     X_Msg_Data               => X_Msg_Data  );

  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    OPEN c_get_header_id(X_Qte_Line_Id);
    Fetch c_get_header_id INTO l_header_id;
    Close c_get_header_id;

    X_Qte_Header_Rec := ASO_UTILITY_PVT.Query_Header_Row(l_header_id);

  END IF;

END Copy_Line;

End ASO_COPY_QUOTE_PUB;

/
