--------------------------------------------------------
--  DDL for Package Body ASO_CONFIG_OPERATIONS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CONFIG_OPERATIONS_INT" as
/* $Header: asoicfob.pls 120.3 2005/11/18 14:58:55 bmishra ship $ */


G_PKG_NAME CONSTANT     VARCHAR2(30) := 'ASO_CONFIG_OPERATIONS_INT';

PROCEDURE config_operations(
   	P_Api_Version_Number  	IN	  NUMBER,
    P_Init_Msg_List   		IN	  VARCHAR2    := FND_API.G_FALSE,
    P_Commit    		    IN	  VARCHAR2    := FND_API.G_FALSE,
    p_validation_level   	IN	  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec  		    IN	  ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec   		IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_qte_line_tbl          IN	  ASO_QUOTE_PUB.Qte_line_tbl_type := ASO_QUOTE_PUB.G_MISS_Qte_line_tbl ,
    P_instance_tbl          IN    ASO_QUOTE_HEADERS_PVT.Instance_Tbl_Type,
    p_operation_code        IN    VARCHAR2,
    p_delete_flag           IN    VARCHAR2  := FND_API.G_TRUE,
    x_Qte_Header_Rec        OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_Msg_Count    		   OUT NOCOPY /* file.sql.39 change */ NUMBER,
    X_Msg_Data    		   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)is

l_api_name               CONSTANT VARCHAR2(30) := 'config_operations';
l_api_version	         CONSTANT NUMBER := 1.0;
l_last_update_date       Date;
l_qte_header_rec         ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
l_Control_Rec  		     ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec;
l_QTE_LINE_TBL           ASO_QUOTE_PUB.Qte_line_tbl_type := ASO_QUOTE_PUB.G_MISS_Qte_line_tbl;

l_qte_line_dtl_tbl        ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
l_ln_shipment_tbl	      ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_Qte_Line_Tbl           ASO_QUOTE_PUB.Qte_line_tbl_type;
lx_Qte_Line_Dtl_Tbl       ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
lx_qte_header_rec         ASO_QUOTE_PUB.Qte_Header_Rec_Type;
lx_hd_Price_Attr_Tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
lx_hd_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
lx_hd_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_hd_freight_charge_tbl  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_hd_tax_detail_tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
lX_hd_Attr_Ext_Tbl        ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_Line_Attr_Ext_Tbl      ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_line_rltship_tbl       ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
lx_Price_Adjustment_Tbl   ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
lx_Price_Adj_Attr_Tbl     ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
lx_price_adj_rltship_tbl  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
lx_hd_Sales_Credit_Tbl    ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
lx_Quote_Party_Tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
lX_Ln_Sales_Credit_Tbl    ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
lX_Ln_Quote_Party_Tbl     ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
lx_ln_Price_Attr_Tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
lx_ln_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
lx_ln_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_ln_freight_charge_tbl  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_ln_tax_detail_tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;


Begin

     SAVEPOINT config_operations_int;

        -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (
					l_api_version,
					p_api_version_Number,
					l_api_name,
					G_PKG_NAME )
     THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
	 IF FND_API.to_Boolean( p_init_msg_list ) THEN
		   FND_MSG_PUB.initialize;
	 END IF;


     -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
If (p_operation_code = ASO_QUOTE_PUB.G_ADD_TO_CONTAINER) THEN

ASO_CONFIG_OPERATIONS_PVT.Add_to_Container_from_IB(
   	P_Api_Version_Number  	=> 1.0,
    P_Init_Msg_List   		=> FND_API.G_FALSE,
    P_Commit    		    => FND_API.G_FALSE,
   	p_validation_level   	=> p_validation_level,
    P_Control_Rec  		    => l_control_rec,
    P_Qte_Header_Rec   		=> p_qte_header_rec,
    P_Quote_line_Id		    => p_qte_line_tbl(1).quote_line_id,
    P_instance_tbl          => p_instance_tbl,
    X_qte_header_rec        => x_Qte_Header_Rec,
    X_Return_Status   		=> X_Return_Status,
    X_Msg_Count    		    => X_Msg_Count,
    X_Msg_Data    		    => X_Msg_Data
    );

ELSIF (p_operation_code = ASO_QUOTE_PUB.G_RECONFIGURE) THEN

ASO_CONFIG_OPERATIONS_PVT.Reconfigure_from_IB(
   	P_Api_Version_Number  	=> 1.0,
    P_Init_Msg_List   		=> FND_API.G_FALSE,
    P_Commit    		    => FND_API.G_FALSE,
   	p_validation_level   	=> p_validation_level,
    P_Control_Rec  		    => l_control_rec,
    P_Qte_Header_Rec   		=> p_qte_header_rec,
    P_instance_tbl          => p_instance_tbl,
    X_qte_header_rec        => x_Qte_Header_Rec,
    X_Return_Status   		=> X_Return_Status,
    X_Msg_Count    		    => X_Msg_Count,
    X_Msg_Data    		    => X_Msg_Data
    );

ELSIF (p_operation_code = ASO_QUOTE_PUB.G_DEACTIVATE) THEN

      IF (P_Control_Rec.deactivate_all = FND_API.G_TRUE)THEN

                l_Control_Rec.deactivate_all := FND_API.G_TRUE;
      END IF;

ASO_CONFIG_OPERATIONS_PVT.Deactivate_from_quote(
   	P_Api_Version_Number  	=> 1.0,
    P_Init_Msg_List   		=> FND_API.G_FALSE,
    P_Commit    		    => FND_API.G_FALSE,
   	p_validation_level   	=> p_validation_level,
    P_Control_Rec  		    => l_control_rec,
    P_Qte_Header_Rec   		=> p_qte_header_rec,
    P_Qte_line_tbl		    => p_qte_line_tbl,
    p_delete_flag            => p_delete_flag,
    X_qte_header_rec        => x_Qte_Header_Rec,
    X_Return_Status   		=> X_Return_Status,
    X_Msg_Count    		    => X_Msg_Count,
    X_Msg_Data    		    => X_Msg_Data
    );

END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Config_Operations:X_Return_Status:'||X_Return_Status,1,'N');
aso_debug_pub.add('Config_Operations:X_Msg_Count:'||X_Msg_Count,1,'N');
END IF;

IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

   l_qte_header_rec := p_qte_header_rec;

Begin
 SELECT last_update_date, object_version_number into l_QTE_HEADER_REC.last_update_date, l_QTE_HEADER_REC.object_version_number
 FROM ASO_QUOTE_HEADERS_ALL
 WHERE quote_header_id = l_qte_header_rec.quote_header_id;

  -- l_QTE_HEADER_REC.last_update_date  := l_last_update_date;

 exception when no_data_found then

 x_return_status := FND_API.G_RET_STS_ERROR;
IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
	FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
	FND_MSG_PUB.ADD;
END IF;

	raise FND_API.G_EXC_ERROR;

end;

   ASO_QUOTE_PUB.Update_Quote(
          p_api_version_number     => 1.0,
          p_init_msg_list          => p_init_msg_list,
          p_commit                 => p_commit,
          p_control_rec            => p_control_rec,
          p_qte_header_rec         => l_qte_header_rec,
          X_Qte_Header_Rec         => lx_qte_header_rec,
          X_Qte_Line_Tbl           => lx_Qte_Line_Tbl,
          X_Qte_Line_Dtl_Tbl       => lx_Qte_Line_Dtl_Tbl,
          X_hd_Price_Attributes_Tbl => lx_hd_Price_Attr_Tbl,
          X_hd_Payment_Tbl         => lx_hd_Payment_Tbl,
          X_hd_Shipment_Tbl        => lx_hd_Shipment_Tbl,
          X_hd_Freight_Charge_Tbl  => lx_hd_Freight_Charge_Tbl,
          X_hd_Tax_Detail_Tbl      => lx_hd_Tax_Detail_Tbl,
          X_hd_Attr_Ext_Tbl        => lX_hd_Attr_Ext_Tbl,
          X_hd_Sales_Credit_Tbl    => lx_hd_Sales_Credit_Tbl,
          X_hd_Quote_Party_Tbl     => lx_Quote_Party_Tbl,
          X_Line_Attr_Ext_Tbl      => lx_Line_Attr_Ext_Tbl,
          X_line_rltship_tbl       => lx_line_rltship_tbl,
          X_Price_Adjustment_Tbl   => lx_Price_Adjustment_Tbl,
          X_Price_Adj_Attr_Tbl     => lx_Price_Adj_Attr_Tbl,
          X_Price_Adj_Rltship_Tbl  => lx_Price_Adj_Rltship_Tbl,
          X_ln_Price_Attributes_Tbl=> lx_ln_Price_Attr_Tbl,
          X_ln_Payment_Tbl         => lx_ln_Payment_Tbl,
          X_ln_Shipment_Tbl        => lx_ln_Shipment_Tbl,
          X_ln_Freight_Charge_Tbl  => lx_ln_Freight_Charge_Tbl,
          X_ln_Tax_Detail_Tbl      => lx_ln_Tax_Detail_Tbl,
          X_Ln_Sales_Credit_Tbl    => lX_Ln_Sales_Credit_Tbl,
          X_Ln_Quote_Party_Tbl     => lX_Ln_Quote_Party_Tbl,
          X_Return_Status          => x_Return_Status,
          X_Msg_Count              => x_Msg_Count,
          X_Msg_Data               => x_Msg_Data);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Config_Operations:update_quote:X_Return_Status:'||X_Return_Status,1,'N');
aso_debug_pub.add('Config_Operations:update_quote:X_Msg_Count:'||X_Msg_Count,1,'N');
END IF;

IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


 -- End of API body
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('****** End of confog operations API ******', 1, 'Y');
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count    ,
        p_data    => x_msg_data
    );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_SQLERRM  => sqlerrm
            ,P_SQLCODE  => sqlcode
            ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);
end;

END ASO_CONFIG_OPERATIONS_INT;


/
