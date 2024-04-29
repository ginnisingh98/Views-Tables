--------------------------------------------------------
--  DDL for Package Body ASO_CONC_REQ_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CONC_REQ_INT" as
/* $Header: asoiprqb.pls 120.5 2006/02/08 11:59:46 skulkarn ship $*/

G_PKG_NAME CONSTANT     VARCHAR2 (30):= 'ASO_CONC_REQ_INT';

Procedure Submit_price_tax_req(
		P_Api_Version_Number	IN	NUMBER,
		P_Init_Msg_List		IN	VARCHAR2		:= FND_API.G_FALSE,
		p_qte_header_rec	IN	ASO_QUOTE_PUB.Qte_Header_Rec_Type,
		p_control_rec		IN	ASO_QUOTE_PUB.Control_Rec_Type :=ASO_QUOTE_PUB.G_Miss_Control_Rec,
		x_request_id	 OUT NOCOPY /* file.sql.39 change */  Number,
		x_return_status	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
		x_msg_count	 OUT NOCOPY /* file.sql.39 change */  Number,
		x_msg_data	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
           ) is

lx_request_id				Number;
errbuf					VARCHAR2(2000);
L_API_VERSION				CONSTANT    NUMBER	   := 1.0;
l_api_name				CONSTANT VARCHAR2(30)  := 'Submit_price_tax_req';
l_header_pricing_event			VARCHAR2(10);
l_pricing_request_type			VARCHAR2(10);
l_calculate_tax_flag			VARCHAR2(1);
l_calc_freight_charge_flag		VARCHAR2(1);
l_price_mode				VARCHAR2(20);
l_auto_version_flag			VARCHAR2(1);
l_copy_task_flag			VARCHAR2(1);
l_copy_notes_flag			VARCHAR2(1);
l_copy_att_flag				VARCHAR2(1);
l_DEPENDENCY_FLAG                  VARCHAR2(1);
l_DEFAULTING_FLAG                  VARCHAR2(1);
l_DEFAULTING_FWK_FLAG              VARCHAR2(1);
l_APPLICATION_TYPE_CODE            VARCHAR2(30);
l_pricing_status_indicator		VARCHAR2(11);
l_tax_status_indicator			VARCHAR2(11);
G_USER_ID				NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID				NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
x_status				VARCHAR2(1);
l_qte_header_rec			ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
l_control_rec				ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec;
l_hd_Price_Attributes_Tbl		ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
l_hd_Payment_Tbl			ASO_QUOTE_PUB.Payment_Tbl_Type;
l_hd_Shipment_Tbl			ASO_QUOTE_PUB.Shipment_Tbl_Type;
l_hd_Freight_Charge_Tbl			ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
l_hd_Tax_Detail_Tbl			ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
l_hd_Attr_Ext_Tbl			ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
l_hd_Sales_Credit_Tbl			ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
l_hd_Quote_Party_Tbl			ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
l_Qte_Line_Tbl				ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
l_Qte_Line_Dtl_Tbl			ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
l_Line_Attr_Ext_Tbl			ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
l_line_rltship_tbl			ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
l_Price_Adjustment_Tbl			ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
l_Price_Adj_Attr_Tbl			ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
l_Price_Adj_Rltship_Tbl			ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
l_Ln_Price_Attributes_Tbl		ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
l_Ln_Payment_Tbl			ASO_QUOTE_PUB.Payment_Tbl_Type;
l_Ln_Shipment_Tbl			ASO_QUOTE_PUB.Shipment_Tbl_Type;
l_Ln_Freight_Charge_Tbl			ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
l_Ln_Tax_Detail_Tbl			ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
l_ln_Sales_Credit_Tbl			ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
l_ln_Quote_Party_Tbl			ASO_QUOTE_PUB.Quote_Party_Tbl_Type;

lx_Qte_Line_Tbl				ASO_QUOTE_PUB.Qte_line_tbl_type;
lx_Qte_Line_Dtl_Tbl			ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
lx_qte_header_rec			ASO_QUOTE_PUB.Qte_Header_Rec_Type;
lx_hd_Price_Attr_Tbl			ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
lx_hd_payment_tbl			ASO_QUOTE_PUB.Payment_Tbl_Type;
lx_hd_shipment_tbl			ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_hd_freight_charge_tbl		ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_hd_tax_detail_tbl			ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
lX_hd_Attr_Ext_Tbl			ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_Line_Attr_Ext_Tbl			ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_line_rltship_tbl			ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
lx_Price_Adjustment_Tbl			ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
lx_Price_Adj_Attr_Tbl			ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
lx_price_adj_rltship_tbl		ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
lx_hd_Sales_Credit_Tbl			ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
lx_Quote_Party_Tbl			ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
lX_Ln_Sales_Credit_Tbl			ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
lX_Ln_Quote_Party_Tbl			ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
lx_ln_Price_Attr_Tbl			ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
lx_ln_payment_tbl			ASO_QUOTE_PUB.Payment_Tbl_Type;
lx_ln_shipment_tbl			ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_ln_freight_charge_tbl		ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_ln_tax_detail_tbl			ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
l_org_id				NUMBER ;

Begin

	savepoint Submit_price_tax_req_INT;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call(
		L_API_VERSION       ,
		P_API_VERSION_NUMBER,
		L_API_NAME          ,
		G_PKG_NAME
				    ) THEN
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_Msg_Pub.initialize;
	END IF;


        x_return_status := FND_API.G_RET_STS_SUCCESS;

        x_msg_count := 0;

/*******************************************************
 Submit Batch Request
*******************************************************/

Lock_Exists(
		p_quote_header_id	=> p_qte_header_rec.quote_header_id,
		x_status		=> x_status);

if (x_status = FND_API.G_TRUE) then
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
			FND_MSG_PUB.ADD;
		END IF;

		raise FND_API.G_EXC_ERROR;
end if;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request:quote_header_id:'|| p_qte_header_rec.quote_header_id,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: header_pricing_event:'|| p_control_rec.header_pricing_event,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: pricing_request_type:'|| p_control_rec.pricing_request_type,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: calculate_tax_flag:'|| p_control_rec.calculate_tax_flag,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: calc_freight_charge_flag:'|| p_control_rec.calculate_freight_charge_flag,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: price_mode:'|| p_control_rec.price_mode,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: auto_version_flag:'|| p_control_rec.auto_version_flag,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: copy_task_flag:'|| p_control_rec.copy_task_flag ,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: copy_notes_flag:'|| p_control_rec.copy_notes_flag,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: copy_att_flag:'|| p_control_rec.copy_att_flag,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: DEPENDENCY_FLAG:'|| p_control_rec.DEPENDENCY_FLAG,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: DEFAULTING_FLAG:'|| p_control_rec.DEFAULTING_FLAG,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: DEFAULTING_FWK_FLAG:'|| p_control_rec.DEFAULTING_FWK_FLAG,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: APPLICATION_TYPE_CODE:'|| p_control_rec.APPLICATION_TYPE_CODE,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: pricing status indicator:'|| p_qte_header_rec.Pricing_status_indicator,1,'N');
	aso_debug_pub.add('ASO_CONC_REQ: Submit_request: tax status indicator:'|| p_qte_header_rec.tax_status_indicator,1,'N');
END IF;

	If ((p_control_rec.header_pricing_event = null) or (p_control_rec.header_pricing_event = FND_API.G_MISS_CHAR)) then
			l_header_pricing_event := ' ';
	else
			l_header_pricing_event := p_control_rec.header_pricing_event;
	end if;

	If ((p_control_rec.pricing_request_type = null) or (p_control_rec.pricing_request_type = FND_API.G_MISS_CHAR)) then
			l_pricing_request_type := ' ';
	else
			l_pricing_request_type := p_control_rec.pricing_request_type;
	end if;

	If ((p_control_rec.CALCULATE_TAX_FLAG = null) or (p_control_rec.CALCULATE_TAX_FLAG = FND_API.G_MISS_CHAR)) then
			l_CALCULATE_TAX_FLAG := ' ';
	else
			l_CALCULATE_TAX_FLAG := p_control_rec.CALCULATE_TAX_FLAG;
	end if;

	If ((p_control_rec.calculate_freight_charge_flag = null) or (p_control_rec.calculate_freight_charge_flag = FND_API.G_MISS_CHAR)) then
			l_calc_freight_charge_flag := ' ';
	else
			l_calc_freight_charge_flag := p_control_rec.calculate_freight_charge_flag;
	end if;

	If ((p_control_rec.auto_version_flag = null) or (p_control_rec.auto_version_flag = FND_API.G_MISS_CHAR)) then
			l_auto_version_flag := ' ';
	else
			l_auto_version_flag := p_control_rec.auto_version_flag;
	end if;

	If ((p_control_rec.copy_task_flag = null) or (p_control_rec.copy_task_flag = FND_API.G_MISS_CHAR)) then
			l_copy_task_flag := ' ';
	else
			l_copy_task_flag := p_control_rec.copy_task_flag;
	end if;

	If ((p_control_rec.copy_notes_flag  = null) or (p_control_rec.copy_notes_flag  = FND_API.G_MISS_CHAR)) then
			l_copy_notes_flag  := ' ';
	else
			l_copy_notes_flag  := p_control_rec.copy_notes_flag ;
	end if;

	If ((p_control_rec.copy_att_flag = null) or (p_control_rec.copy_att_flag = FND_API.G_MISS_CHAR)) then
			l_copy_att_flag := ' ';
	else
			l_copy_att_flag := p_control_rec.copy_att_flag;
	end if;

     --Defaulting Framework changes
	If ((p_control_rec.DEPENDENCY_FLAG is NULL ) or (p_control_rec.DEPENDENCY_FLAG = FND_API.G_MISS_CHAR)) then
			l_DEPENDENCY_FLAG := ' ';
	else
			l_DEPENDENCY_FLAG := p_control_rec.DEPENDENCY_FLAG;
	End If;

	If ((p_control_rec.DEFAULTING_FLAG IS NULL) or (p_control_rec.DEFAULTING_FLAG = FND_API.G_MISS_CHAR)) then
			l_DEFAULTING_FLAG := ' ';
	else
			l_DEFAULTING_FLAG := p_control_rec.DEFAULTING_FLAG;
	End If;

	If ((p_control_rec.DEFAULTING_FWK_FLAG IS NULL) or (p_control_rec.DEFAULTING_FWK_FLAG = FND_API.G_MISS_CHAR)) then
			l_DEFAULTING_FWK_FLAG := ' ';
	else
			l_DEFAULTING_FWK_FLAG := p_control_rec.DEFAULTING_FWK_FLAG;
	End If;

	If ((p_control_rec.APPLICATION_TYPE_CODE IS NULL) or (p_control_rec.APPLICATION_TYPE_CODE = FND_API.G_MISS_CHAR)) then
			l_APPLICATION_TYPE_CODE := ' ';
	else
			l_APPLICATION_TYPE_CODE := p_control_rec.APPLICATION_TYPE_CODE;
	End If;



	If 	(p_qte_header_rec.Pricing_status_indicator = null) then
			l_Pricing_status_indicator := ' ';
	elsif (p_qte_header_rec.Pricing_status_indicator = FND_API.G_MISS_CHAR) then
			l_Pricing_status_indicator := 'G_MISS_CHAR';
	else
			l_Pricing_status_indicator := p_qte_header_rec.Pricing_status_indicator;
	end if;

	If (p_qte_header_rec.tax_status_indicator = null) then
			l_tax_status_indicator := ' ';
	elsif (p_qte_header_rec.tax_status_indicator = FND_API.G_MISS_CHAR) then
			l_tax_status_indicator := 'G_MISS_CHAR';
	else
			l_tax_status_indicator := p_qte_header_rec.tax_status_indicator;
	end if;


	-- Change START
	-- Release 12 MOAC Changes : Bug 4500739
	-- Changes Done by : Girish
	-- Comments : Setting the org id context before submitting the request

	l_org_id := MO_GLOBAL.GET_CURRENT_ORG_ID;
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('ASO_CONC_REQ: Submit_request:Org ID:'|| l_org_id,1,'N');
	END IF;
	fnd_request.set_org_id(l_org_id);

	-- Change END

	lx_request_id := fnd_request.submit_request
	(	Application	=>	'ASO',
		Program		=>	'ASOBTPRC',
		Description	=>	null,
		Start_time	=>	null,
		Sub_request	=>	FALSE,
		Argument1		=>	p_qte_header_rec.quote_header_id,
		Argument2		=>	l_header_pricing_event,
		Argument3		=>	l_pricing_request_type,
		Argument4		=>	l_calculate_tax_flag,
		Argument5		=>	l_calc_freight_charge_flag,
		Argument6		=>	p_control_rec.price_mode,
		Argument7		=>	l_auto_version_flag,
		Argument8		=>	l_copy_task_flag,
		Argument9		=>	l_copy_notes_flag,
		Argument10	=>	l_copy_att_flag,
		Argument11	=>	l_pricing_status_indicator,
		Argument12	=>	l_tax_status_indicator,
		Argument13	=>	l_DEPENDENCY_FLAG,
		Argument14	=>	l_DEFAULTING_FLAG,
		Argument15	=>	l_DEFAULTING_FWK_FLAG,
		Argument16	=>	l_APPLICATION_TYPE_CODE);


	if lx_request_id = 0 then
		fnd_file.put_line(FND_FILE.LOG,'Error in submitting concurrent request');
		errbuf  := FND_MESSAGE.GET;
		fnd_message.set_name('ASO', errbuf);
		FND_MSG_PUB.Add;
		raise FND_API.G_EXC_ERROR;
	end if;

/*******************************************************
 Update quote with Price_request_id
*******************************************************/

	l_qte_header_rec				:= p_qte_header_rec;
	l_qte_header_rec.price_request_id		:= lx_request_id;
	l_qte_header_rec.pricing_status_indicator	:= FND_API.G_MISS_CHAR;
	l_qte_header_rec.tax_status_indicator		:= FND_API.G_MISS_CHAR;

ASO_QUOTE_PUB.Update_Quote(
	p_api_version_number		=> 1.0,
	p_init_msg_list			=> FND_API.G_FALSE,
	p_commit			=> FND_API.G_FALSE,
    	P_Validation_Level		=> FND_API.G_VALID_LEVEL_FULL,
	p_control_rec			=> l_control_rec,
    	p_qte_header_rec		=> l_qte_header_rec,
	P_hd_Price_Attributes_Tbl 	=> l_hd_Price_Attributes_Tbl,
	P_hd_Payment_Tbl		=> l_hd_Payment_Tbl,
     P_hd_Shipment_Tbl		=> l_hd_Shipment_Tbl,
     P_hd_Freight_Charge_Tbl		=> l_hd_Freight_Charge_Tbl,
     P_hd_Tax_Detail_Tbl		=> l_hd_Tax_Detail_Tbl,
     P_hd_Attr_Ext_Tbl		=> l_hd_Attr_Ext_Tbl,
     P_hd_Sales_Credit_Tbl		=> l_hd_Sales_Credit_Tbl,
     P_hd_Quote_Party_Tbl		=> l_hd_Quote_Party_Tbl,
     P_Qte_Line_Tbl			=> l_Qte_Line_Tbl,
     P_Qte_Line_Dtl_Tbl		=> l_Qte_Line_Dtl_Tbl,
     P_Line_Attr_Ext_Tbl		=> l_Line_Attr_Ext_Tbl,
     P_line_rltship_tbl		=> l_line_rltship_tbl,
     P_Price_Adjustment_Tbl		=> l_Price_Adjustment_Tbl,
     P_Price_Adj_Attr_Tbl		=> l_Price_Adj_Attr_Tbl,
     P_Price_Adj_Rltship_Tbl		=> l_Price_Adj_Rltship_Tbl,
     P_Ln_Price_Attributes_Tbl	=> l_Ln_Price_Attributes_Tbl,
     P_Ln_Payment_Tbl		=> l_Ln_Payment_Tbl,
     P_Ln_Shipment_Tbl		=> l_Ln_Shipment_Tbl,
     P_Ln_Freight_Charge_Tbl		=> l_Ln_Freight_Charge_Tbl,
     P_Ln_Tax_Detail_Tbl		=> l_Ln_Tax_Detail_Tbl,
     P_ln_Sales_Credit_Tbl		=> l_ln_Sales_Credit_Tbl,
     P_ln_Quote_Party_Tbl		=> l_ln_Quote_Party_Tbl,
     X_Qte_Header_Rec		=> lx_qte_header_rec,
     X_Qte_Line_Tbl			=> lx_Qte_Line_Tbl,
     X_Qte_Line_Dtl_Tbl		=> lx_Qte_Line_Dtl_Tbl,
     X_hd_Price_Attributes_Tbl	=> lx_hd_Price_Attr_Tbl,
     X_hd_Payment_Tbl		=> lx_hd_Payment_Tbl,
     X_hd_Shipment_Tbl		=> lx_hd_Shipment_Tbl,
    	X_hd_Freight_Charge_Tbl		=> lx_hd_Freight_Charge_Tbl,
     X_hd_Tax_Detail_Tbl		=> lx_hd_Tax_Detail_Tbl,
     X_hd_Attr_Ext_Tbl        	=> lX_hd_Attr_Ext_Tbl,
     X_hd_Sales_Credit_Tbl    	=> lx_hd_Sales_Credit_Tbl,
     X_hd_Quote_Party_Tbl     	=> lx_Quote_Party_Tbl,
     X_Line_Attr_Ext_Tbl      	=> lx_Line_Attr_Ext_Tbl,
     X_line_rltship_tbl       	=> lx_line_rltship_tbl,
     X_Price_Adjustment_Tbl   	=> lx_Price_Adjustment_Tbl,
     X_Price_Adj_Attr_Tbl     	=> lx_Price_Adj_Attr_Tbl,
    	X_Price_Adj_Rltship_Tbl  	=> lx_Price_Adj_Rltship_Tbl,
     X_ln_Price_Attributes_Tbl	=> lx_ln_Price_Attr_Tbl,
     X_ln_Payment_Tbl         	=> lx_ln_Payment_Tbl,
     X_ln_Shipment_Tbl        	=> lx_ln_Shipment_Tbl,
     X_ln_Freight_Charge_Tbl  	=> lx_ln_Freight_Charge_Tbl,
     X_ln_Tax_Detail_Tbl      	=> lx_ln_Tax_Detail_Tbl,
     X_Ln_Sales_Credit_Tbl    	=> lX_Ln_Sales_Credit_Tbl,
     X_Ln_Quote_Party_Tbl     	=> lX_Ln_Quote_Party_Tbl,
     X_Return_Status          	=> x_Return_Status,
     X_Msg_Count              	=> x_Msg_Count,
     X_Msg_Data               	=> x_Msg_Data);


IF x_return_status = FND_API.G_RET_STS_ERROR then
          x_request_id := null;
          raise FND_API.G_EXC_ERROR;
elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          x_request_id := null;
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

		x_request_id := lx_request_id;
		commit work;

Exception

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

end Submit_price_tax_req;

/*******************************************************
Procedure to call pricing
********************************************************/

procedure batch_pricing(
         	errbuf				 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	 	retcode				 OUT NOCOPY /* file.sql.39 change */  Number,
  	  	p_quote_header_id			IN	Number,
         	p_header_pricing_event		IN	VARCHAR2,
		p_pricing_request_type		IN	VARCHAR2,
		p_calculate_tax_flag		IN	VARCHAR2,
		p_calc_freight_charge_flag	IN	VARCHAR2,
		p_price_mode				IN	VARCHAR2,
		p_auto_version_flag			IN	VARCHAR2,
         	p_copy_task_flag			IN	VARCHAR2,
         	p_copy_notes_flag			IN	VARCHAR2,
         	p_copy_att_flag			IN	VARCHAR2,
		p_PRICING_STATUS_INDICATOR	IN	VARCHAR2,
		p_TAX_STATUS_INDICATOR		IN	VARCHAR2,
		p_DEPENDENCY_FLAG			IN	VARCHAR2,
         	p_DEFAULTING_FLAG			IN	VARCHAR2,
         	p_DEFAULTING_FWK_FLAG		IN	VARCHAR2,
         	p_APPLICATION_TYPE_CODE		IN	VARCHAR2

) is

l_api_name        	CONSTANT VARCHAR2(30) := 'batch_pricing';
l_subject 	    	VARCHAR2(2000);
l_body   	      	VARCHAR2(2000);
l_quote_name    	VARCHAR2(240);
l_org_id		VARCHAR2(240);
l_qte_header_rec  	ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
x_return_status   	VARCHAR2(1);
l_last_update_date	DATE;
x_msg_count       	Number;
l_request_id       	Number;
x_msg_index        	Number;
x_Msg_Data        	VARCHAR2(2000);
l_control_rec     	ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec;

l_qte_line_dtl_tbl        	ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
l_ln_shipment_tbl	      	ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_Qte_Line_Tbl           	ASO_QUOTE_PUB.Qte_line_tbl_type;
lx_Qte_Line_Dtl_Tbl       	ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
lx_qte_header_rec         	ASO_QUOTE_PUB.Qte_Header_Rec_Type;
lx_hd_Price_Attr_Tbl      	ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
lx_hd_payment_tbl         	ASO_QUOTE_PUB.Payment_Tbl_Type;
lx_hd_shipment_tbl        	ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_hd_freight_charge_tbl  	ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_hd_tax_detail_tbl      	ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
lX_hd_Attr_Ext_Tbl        	ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_Line_Attr_Ext_Tbl      	ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_line_rltship_tbl       	ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
lx_Price_Adjustment_Tbl   	ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
lx_Price_Adj_Attr_Tbl     	ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
lx_price_adj_rltship_tbl  	ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
lx_hd_Sales_Credit_Tbl    	ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
lx_Quote_Party_Tbl        	ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
lX_Ln_Sales_Credit_Tbl    	ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
lX_Ln_Quote_Party_Tbl     	ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
lx_ln_Price_Attr_Tbl      	ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
lx_ln_payment_tbl         	ASO_QUOTE_PUB.Payment_Tbl_Type;
lx_ln_shipment_tbl        	ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_ln_freight_charge_tbl  	ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_ln_tax_detail_tbl      	ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

Begin

SAVEPOINT Batch_Pricing_INT;
/*******************************************************
 Call update quote with pricing parameters
********************************************************/
FND_FILE.PUT_LINE(FND_FILE.LOG,'Quote Header Id for Batch Pricing='||p_quote_header_id);

Begin

   begin
     SELECT a.quote_name ,a.price_request_id, a.org_id into l_quote_name ,l_request_id, l_org_id
     FROM ASO_QUOTE_HEADERS_ALL a
     WHERE a.quote_header_id = p_quote_header_id;
   end;

FND_FILE.PUT_LINE(FND_FILE.LOG,l_quote_name);

 exception when no_data_found then
   	x_return_status := FND_API.G_RET_STS_ERROR;

end;

  begin
     SELECT a.last_update_date into l_last_update_date
     FROM ASO_QUOTE_HEADERS_ALL a
     WHERE a.quote_header_id = p_quote_header_id;
   end;


    l_qte_header_rec.batch_price_flag			:= FND_API.G_FALSE;
    l_qte_header_rec.quote_header_id			:= p_quote_header_id;
    l_qte_header_rec.last_update_date			:= l_last_update_date;

	if p_pricing_status_indicator = 'G_MISS_CHAR' then
		l_qte_header_rec.pricing_status_indicator	:= FND_API.G_MISS_CHAR;
	else
		l_qte_header_rec.pricing_status_indicator    := p_pricing_status_indicator;
	end if;

	if p_tax_status_indicator = 'G_MISS_CHAR' then
		l_qte_header_rec.tax_status_indicator        := FND_API.G_MISS_CHAR;
	else
		l_qte_header_rec.tax_status_indicator		:= p_tax_status_indicator;
	end if;

    l_control_rec.header_pricing_event			:= p_header_pricing_event;
    l_control_rec.pricing_request_type			:= p_pricing_request_type;
    l_control_rec.CALCULATE_TAX_FLAG			:= p_calculate_tax_flag;
    l_control_rec.calculate_freight_charge_flag	:= p_calc_freight_charge_flag;
    l_control_rec.price_mode				:= p_price_mode ;
    l_control_rec.auto_version_flag			:= p_auto_version_flag;
    l_control_rec.copy_task_flag			:= p_copy_task_flag;
    l_control_rec.copy_notes_flag			:= p_copy_notes_flag;
    l_control_rec.copy_att_flag				:= p_copy_att_flag;
    l_control_rec.dependency_flag			:= p_dependency_flag;
    l_control_rec.defaulting_flag			:= p_defaulting_flag;
    l_control_rec.defaulting_fwk_flag		:= p_defaulting_fwk_flag;
    l_control_rec.application_type_code		:= p_application_type_code;


    mo_global.set_policy_context('S', l_org_id);

   FND_FILE.PUT_LINE(FND_FILE.LOG,'Before Update quote');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Org ID : '||l_org_id);

   ASO_QUOTE_PUB.Update_Quote(
          p_api_version_number     	=> 1.0,
          p_init_msg_list			=> FND_API.G_FALSE,
          p_commit                 	=> FND_API.G_false,
          p_control_rec            	=> l_control_rec,
          p_qte_header_rec         	=> l_qte_header_rec,
          X_Qte_Header_Rec         	=> lx_qte_header_rec,
          X_Qte_Line_Tbl           	=> lx_Qte_Line_Tbl,
          X_Qte_Line_Dtl_Tbl       	=> lx_Qte_Line_Dtl_Tbl,
          X_hd_Price_Attributes_Tbl 	=> lx_hd_Price_Attr_Tbl,
          X_hd_Payment_Tbl         	=> lx_hd_Payment_Tbl,
          X_hd_Shipment_Tbl        	=> lx_hd_Shipment_Tbl,
          X_hd_Freight_Charge_Tbl  	=> lx_hd_Freight_Charge_Tbl,
          X_hd_Tax_Detail_Tbl      	=> lx_hd_Tax_Detail_Tbl,
          X_hd_Attr_Ext_Tbl        	=> lX_hd_Attr_Ext_Tbl,
          X_hd_Sales_Credit_Tbl    	=> lx_hd_Sales_Credit_Tbl,
          X_hd_Quote_Party_Tbl     	=> lx_Quote_Party_Tbl,
          X_Line_Attr_Ext_Tbl      	=> lx_Line_Attr_Ext_Tbl,
          X_line_rltship_tbl       	=> lx_line_rltship_tbl,
          X_Price_Adjustment_Tbl   	=> lx_Price_Adjustment_Tbl,
          X_Price_Adj_Attr_Tbl     	=> lx_Price_Adj_Attr_Tbl,
          X_Price_Adj_Rltship_Tbl  	=> lx_Price_Adj_Rltship_Tbl,
          X_ln_Price_Attributes_Tbl	=> lx_ln_Price_Attr_Tbl,
          X_ln_Payment_Tbl         	=> lx_ln_Payment_Tbl,
          X_ln_Shipment_Tbl        	=> lx_ln_Shipment_Tbl,
          X_ln_Freight_Charge_Tbl  	=> lx_ln_Freight_Charge_Tbl,
          X_ln_Tax_Detail_Tbl      	=> lx_ln_Tax_Detail_Tbl,
          X_Ln_Sales_Credit_Tbl    	=> lX_Ln_Sales_Credit_Tbl,
          X_Ln_Quote_Party_Tbl     	=> lX_Ln_Quote_Party_Tbl,
          X_Return_Status          	=> x_Return_Status,
          X_Msg_Count              	=> x_Msg_Count,
          X_Msg_Data               	=> x_Msg_Data);

        FND_FILE.PUT_LINE(FND_FILE.LOG,X_Return_Status);

        x_msg_index := 1;

          while x_msg_count > 0 loop
                x_msg_data := fnd_msg_pub.get(x_msg_index,
                                         fnd_api.g_false);
                FND_FILE.PUT_LINE(FND_FILE.LOG,x_msg_data);
                x_msg_index := x_msg_index + 1;
                x_msg_count := x_msg_count - 1;
          end loop;

/********************************************************
 Send Notification on completion
*********************************************************/

   If  x_return_status = FND_API.G_RET_STS_ERROR  then
	     fnd_message.set_name('ASO','ASO_PRICE_REQ_COM_SUB');
		fnd_message.set_token('QUOTE_NAME',l_quote_name);
	   	fnd_message.set_token('REQUEST_ID',l_request_id);

		l_subject  :=  fnd_message.get ;

	   	FND_FILE.PUT_LINE(FND_FILE.LOG,l_subject);

		fnd_message.set_name('ASO','ASO_PRICE_REQ_COM_ERR_BODY');
		l_body     :=  fnd_message.get ;

	   	FND_FILE.PUT_LINE(FND_FILE.LOG,l_body);

  elsif   x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          fnd_message.set_name('ASO','ASO_PRICE_REQ_COM_SUB');
		fnd_message.set_token('QUOTE_NAME',l_quote_name);
		fnd_message.set_token('REQUEST_ID',l_request_id);

		l_subject  :=  fnd_message.get ;

		FND_FILE.PUT_LINE(FND_FILE.LOG,l_subject);

		fnd_message.set_name('ASO','ASO_PRICE_REQ_COM_ERR_BODY');
		l_body     :=  fnd_message.get ;

		FND_FILE.PUT_LINE(FND_FILE.LOG,l_body);
   else
    		fnd_message.set_name('ASO','ASO_PRICE_REQ_COM_SUB');
    		fnd_message.set_token('QUOTE_NAME',l_quote_name);
        	fnd_message.set_token('REQUEST_ID',l_request_id);
    		l_subject  :=  fnd_message.get ;

        	FND_FILE.PUT_LINE(FND_FILE.LOG,l_subject);

    		fnd_message.set_name('ASO','ASO_PRICE_REQ_COM_BODY');
    		l_body     :=  fnd_message.get ;

        	FND_FILE.PUT_LINE(FND_FILE.LOG,l_body);

   end if;

IF x_return_status = FND_API.G_RET_STS_ERROR then
        rollback;
elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        rollback;
else
	commit work;
END IF;

  Send_notification(
   p_quote_header_id    	=>  p_quote_header_id,
   p_subject        	=>  l_subject,
   p_body           	=>  l_body);

   FND_FILE.PUT_LINE(FND_FILE.LOG,'After Notification');

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
end  batch_pricing;


/*******************************************************
 Procedure to cancel request
*******************************************************/


Procedure  Cancel_price_tax_req(
		P_Api_Version_Number    	IN   NUMBER,
		P_Init_Msg_List         	IN   VARCHAR2	:= FND_API.G_FALSE,
		p_qte_header_rec		IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
		x_return_status	 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
		x_msg_count		 OUT NOCOPY /* file.sql.39 change */   Number,
		x_msg_data		 OUT NOCOPY /* file.sql.39 change */   VARCHAR2
          ) is

Cursor find_quote_csr(p_quote_header_id  IN   Number) is

select a.quote_name,a.price_request_id from aso_quote_headers_all a
where  a.quote_header_id = p_quote_header_id;

L_API_VERSION   	CONSTANT    NUMBER    := 1.0;
l_api_name        	CONSTANT VARCHAR2(30) := 'Cancel_price_tax_req';
l_subject          	VARCHAR2(2000);
l_body             	VARCHAR2(2000);
l_quote_name      	VARCHAR2(240);
l_quote_header_id  	Number;
l_result           	boolean  := TRUE;
lx_msg_data        	VARCHAR2(2000);
errbuf			VARCHAR2(2000);
l_request_id       	Number;

Begin

/*******************************************************
 Initiate Cancel request
*******************************************************/
   Savepoint Cancel_price_tax_req_INT;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call(
		L_API_VERSION       ,
		P_API_VERSION_NUMBER,
		L_API_NAME          ,
		G_PKG_NAME
							  ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.To_Boolean(p_init_msg_list) THEN
		FND_Msg_Pub.initialize;
	END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_msg_count := 0;

	    Open find_quote_csr(p_qte_header_rec.quote_header_id);

		    fetch find_quote_csr  into l_quote_name,l_request_id;

	IF (find_quote_csr%NOTFOUND or l_request_id is null) THEN
		CLOSE find_quote_csr;
		x_return_status := FND_API.G_RET_STS_ERROR;
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
			FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_NOT_FOUND');
			FND_MSG_PUB.ADD;
		END IF;

		raise FND_API.G_EXC_ERROR;
	END IF;

	close find_quote_csr  ;

l_quote_header_id := p_qte_header_rec.quote_header_id;

l_result := FND_CONCURRENT.cancel_request(request_id	=> 	l_request_id,
                                          message		=> 	lx_msg_data);

if  not (l_result) then
 	errbuf  := FND_MESSAGE.GET;
 	fnd_message.set_name('ASO',errbuf);
 	FND_MSG_PUB.Add;
end if;


/*******************************************************
 Send Notification on completion
*******************************************************/

    fnd_message.set_name('ASO','ASO_PRICE_REQ_CANCELED_SUB');
    fnd_message.set_token('QUOTE_NAME',l_quote_name);
    fnd_message.set_token('REQUEST_ID',l_request_id);

    l_subject  :=  fnd_message.get ;

    fnd_message.set_name('ASO','ASO_PRICE_REQ_CANCELED_BODY');

    l_body     :=  fnd_message.get ;

  Send_notification(
   p_quote_header_id	=>  l_quote_header_id,
   p_subject			=>  l_subject,
   p_body				=>  l_body);

if  not (l_result) then
 	raise FND_API.G_EXC_ERROR;
end if;

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

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

end Cancel_price_tax_req;


/********************************************************
 Procedure to get role for sending notification
 ********************************************************/

Procedure Get_Workflow_Role(p_user_id  				IN   Number,
                            x_wf_role 			 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                            x_notification_preference  OUT NOCOPY /* file.sql.39 change */   VARCHAR2) IS

l_forward_displayname VARCHAR2(100);
l_person_id Number;
l_email_address VARCHAR2(100);
l_language VARCHAR2(100);
l_territory VARCHAR2(100);

Cursor find_person_id is
select employee_id from fnd_user
where user_id = p_user_id;

Begin
     Open find_person_id;

     fetch find_person_id  into l_person_id;

            IF (find_person_id%NOTFOUND or l_person_id is null)  THEN
               wf_directory.GetRoleName(
				p_orig_system		=>	'FND_USR',
				p_orig_system_id	=>	p_user_id,
				p_name			=>	x_wf_role,
				p_display_name		=>	l_forward_displayname );
            else
                wf_directory.GetRoleName(
			 	p_orig_system		=>	'PER',
				p_orig_system_id	=>	l_person_id,
			 	p_name			=>	x_wf_role,
			 	p_display_name		=>	l_forward_displayname );
            END IF;
     Close find_person_id  ;

     wf_directory.GetRoleInfo(
		role					=>	x_wf_role,
		display_name			=>	l_forward_displayname,
		email_address			=>	l_email_address,
		notification_preference	=>	x_notification_preference,
		language				=>	l_language,
		territory				=>	l_territory);


END Get_Workflow_Role;


 /********************************************************
 Update price_request_id in ASO_QUOTE_HEADERS_ALL
 ********************************************************/

procedure Update_price_req_id(p_quote_header_id   IN  Number) is

G_USER_ID                     NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID                    NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
l_last_update_date            Date := SYSDATE;

Begin

Update ASO_QUOTE_HEADERS_ALL
set price_request_id = null,
last_update_date = l_last_update_date,
object_version_number = object_version_number + 1,
last_updated_by = G_USER_ID,
last_update_login = G_LOGIN_ID
where quote_header_id =p_quote_header_id;

end Update_price_req_id;

/********************************************************
 Procedure to send notification
 ********************************************************/

Procedure Send_notification(
                p_quote_header_id 	IN  Number,
                p_subject       	IN  VARCHAR2,
                p_body          	IN  VARCHAR2) is

wf_itemkey_seq    	INTEGER;
wf_itemkey        	VARCHAR2(30);
lx_wf_role         	VARCHAR2(30);
l_user_id Number := FND_GLOBAL.USER_ID;
lx_notification_preference    VARCHAR2(30);
lx_document   	VARCHAR2(2000);
lx_document_type   	VARCHAR2(2000);
l_qte_number        number;

cursor c_get_qte_number is
select quote_number
from aso_quote_headers_all
where quote_header_id = p_quote_header_id;


Begin

   Get_Workflow_Role(
	p_user_id					=>	l_user_id,
	x_wf_role					=>	lx_wf_role,
	x_notification_preference	=>	lx_notification_preference);


   select ASO_WFNOTIFICATION_S2.NEXTVAL into wf_itemkey_seq from dual;

   wf_itemkey := 'ASO_NTFY' || wf_itemkey_seq;


   wf_engine.CreateProcess( itemtype 	=> 'ASO_NTFY',
		            itemkey 		=>  wf_itemkey,
		            process  		=> 'ASO_SEND_NTFY' );

   wf_engine.SetItemAttrText( itemtype 	=> 'ASO_NTFY',
		              itemkey 		=>  wf_itemkey,
		              aname   		=> 'ROLE_TO_NOTIFY',
		              avalue   		=>  lx_wf_role );

   wf_engine.SetItemAttrText( itemtype 	=> 'ASO_NTFY',
		              itemkey 		=>  wf_itemkey,
		              aname   		=> 'NOTIFICATION_SUBJECT',
		              avalue   		=>  p_subject );

   wf_engine.SetItemAttrText( itemtype  => 'ASO_NTFY',
		              itemkey   		=>  wf_itemkey,
		              aname     		=> 'NOTIFICATION_BODY',
		              avalue    		=>  p_body );


   wf_engine.SetItemAttrText(
                        itemtype                     => 'ASO_NTFY',
                        itemkey                      => wf_itemkey,
                        aname                        => 'SEQID',
                        avalue                       => wf_itemkey
                        );


   wf_engine.SetItemAttrNumber (
                        itemtype                     => 'ASO_NTFY',
                        itemkey                      => wf_itemkey,
                        aname                        => 'QTEHDRID',
                        avalue                       => p_quote_header_id
                        );


    open c_get_qte_number;
    fetch c_get_qte_number into l_qte_number;
    close c_get_qte_number;

   wf_engine.SetItemAttrNumber (
                        itemtype                     => 'ASO_NTFY',
                        itemkey                      => wf_itemkey,
                        aname                        => 'QTENUMBER',
                        avalue                       => l_qte_number
                        );


   wf_engine.SetItemOwner( itemtype 	=> 'ASO_NTFY',
		       	   itemkey  		=>  wf_itemkey,
       		  	   owner    		=>  lx_wf_role );


   wf_engine.StartProcess(itemtype => 'ASO_NTFY',
		          itemkey  		=>  wf_itemkey );


   Update_price_req_id(p_quote_header_id     => p_quote_header_id);

   end send_notification;

 /*************************************************************
 Procedure to find  pending /running request for a given quote
 **************************************************************/

Procedure Lock_Exists(p_quote_header_id 	IN 	Number,
		          		x_status	 OUT NOCOPY /* file.sql.39 change */ 	 VARCHAR2) IS

l_request_id    Number;

Begin

Select price_request_id into l_request_id   from aso_quote_headers_all
Where quote_header_id =p_quote_header_id;

If  l_request_id is null then
    x_status := FND_API.G_FALSE;
Else
    x_status := FND_API.G_TRUE;
End if;

end Lock_Exists;

 /*************************************************************
 Procedure to create quote details URL
 **************************************************************/

PROCEDURE quote_detail_url (p_quote_header_id     IN    Number,
                            p_display_type        IN    VARCHAR2,
                            x_document            OUT NOCOPY /* file.sql.39 change */    VARCHAR2) IS

    l_jsp_name                    VARCHAR2 (1000);
    l_url                         VARCHAR2 (100);
    l_attr_desc                   VARCHAR2 (100);
    l_quote_number                Number;
    l_party_number                VARCHAR2(30);
    l_party_type                  VARCHAR2 (30);
    p Number;

    CURSOR get_quote_details (p_quote_header_id  NUMBER ) IS
      SELECT qha.quote_number, hca.account_number,
      hp.party_type
      FROM aso_quote_headers_all qha,
      hz_parties hp,
      hz_cust_accounts hca
      WHERE qha.cust_account_id = hca.cust_account_id(+)
      AND hca.party_id = hp.party_id
      AND qha.party_id = hca.party_id
      AND qha.quote_header_id = p_quote_header_id;

  BEGIN

    -- get the quote header id
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('Quote header ID is ' || p_quote_header_id,1,'N');
    END IF;

    -- get the server address
    l_url := fnd_web_config.jsp_agent ();
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('URL ID is ' || l_url,1,'N');
    END IF;

    -- get the quote details
    OPEN get_quote_details (p_quote_header_id);

    FETCH get_quote_details INTO l_quote_number,
                                 l_party_number,
                                 l_party_type;
    CLOSE get_quote_details;

    -- get the jsp name
    l_jsp_name     := 'qotSZzpAppsLink.jsp?';
    l_jsp_name     := l_jsp_name || 'qotFrmMainFile=qotSZzdContainer.jsp';
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotFrmDspFile=qotSCocOverview.jsp';
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotFrmRefFile=qotSCocOverview.jsp';
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotDetCode=QUOTE';
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotPtyType='|| l_party_type;
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotHdrId='|| p_quote_header_id;
if l_party_number is not null then
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotHdrAcctId='||l_party_number;
end if;
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotHdrNbr='|| l_quote_number;
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotReqSetCookie=Y';
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotFromApvlLink=Y';

    -- get the attribute label
    Begin
	    fnd_message.set_name('ASO','ASO_QUOTE_DETAILS_URL');
    	    l_attr_desc     :=  fnd_message.get;
    end;

    -- Create an html text buffer
    IF (p_display_type = 'MAILHTML')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD ('Display type is text/html',1,'N');
      END IF;
      x_document       := '<a href = "'|| l_url|| l_jsp_name|| '">'||l_attr_desc|| '</a>';

    END IF;

    -- Create a plain text buffer

    IF (p_display_type = 'MAILTEXT')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD ('Display type is text/plain',1,'N');
      END IF;
      NULL;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('End QUOTE_DETAIL_URL procedure ',1,'N');
    END IF;

  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD ('Exception in QUOTE_DETAIL_URL SqlCode :' || SQLERRM,1,'N');
      END IF;

      RAISE;

  END quote_detail_url;

 /*************************************************************
 Procedure to create quote details URL using Document
 **************************************************************/

PROCEDURE qte_detail_url (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    itemtype                      VARCHAR2 (30);
    itemkey                       VARCHAR2 (30);
    l_quote_header_id             NUMBER;
    l_jsp_name                    VARCHAR2 (1000);
    l_url                         VARCHAR2 (100);
    l_attr_desc                   VARCHAR2 (100);
    l_quote_number                Number;
    l_party_number                VARCHAR2(30);
    l_party_type                  VARCHAR2 (30);
    p Number;
    wf_itmkey_seq                 INTEGER;
    wf_itmkey                     VARCHAR2(30);
    l_error                       VARCHAR2(2000);
    l_org_id                      NUMBER;

     CURSOR get_quote_details (p_quote_header_id  NUMBER ) IS
     SELECT qha.quote_number, hca.account_number,
     hp.party_type,qha.org_id
     FROM aso_quote_headers_all qha,
     hz_parties hp,
     hz_cust_accounts hca
     WHERE qha.cust_account_id = hca.cust_account_id(+)
     AND qha.cust_party_id = hp.party_id
     AND qha.quote_header_id =p_quote_header_id;

  BEGIN

    -- get the server address
    l_url := fnd_web_config.jsp_agent ();
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('URL ID is ' || l_url,1,'N');
    END IF;

   -- get the quote details
    itemtype       := 'ASO_NTFY';
    itemkey        :=  document_id;


    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('itemtype is ' || itemtype,1,'N');
      aso_debug_pub.ADD ('itemkey is ' || itemkey,1,'N');
    END IF;

    l_quote_header_id  := wf_engine.getitemattrnumber (
                        itemtype                     => itemtype,
                        itemkey                      => itemkey,
                        aname                        => 'QUOTEHDRID'
                      );



    OPEN get_quote_details (to_number(l_quote_header_id));

    FETCH get_quote_details INTO l_quote_number,
                                 l_party_number,
                                 l_party_type,
						   l_org_id;
    CLOSE get_quote_details;

    -- get the jsp name
    l_jsp_name     := 'qotSZzpAppsLink.jsp?';
    l_jsp_name     := l_jsp_name || 'qotFrmMainFile=qotSZzdContainer.jsp';
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotFrmDspFile=qotSCocOverview.jsp';
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotFrmRefFile=qotSCocOverview.jsp';
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotDetCode=QUOTE';
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotPtyType='|| l_party_type;
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotHdrId='|| l_quote_header_id;
if l_party_number is not null then
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotHdrAcctId='||l_party_number;
end if;
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotHdrNbr='|| l_quote_number;
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotReqSetCookie=Y';
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotFromApvlLink=Y';
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotApvOrgId='|| l_org_id;
    l_jsp_name     := l_jsp_name|| fnd_global.local_chr (38)|| 'qotApvNotifId=&#NID';

    -- get the attribute label
    Begin
	    fnd_message.set_name('ASO','ASO_QUOTE_DETAILS_URL');
    	    l_attr_desc     :=  fnd_message.get;
    end;

    -- Create an html text buffer
    IF (display_type = 'text/html')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD ('Display type is text/html',1,'N');
      END IF;
      document       := '<a href = "'|| l_url|| l_jsp_name|| '">'||l_attr_desc|| '</a>';
      document_type  := 'text/html';

    END IF;

    -- Create a plain text buffer

    IF (display_type = 'text/plain')
    THEN
      document_type  := 'text/plain';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD ('Display type is text/plain',1,'N');
      END IF;
      NULL;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('End QUOTE_DETAIL_URL procedure ',1,'N');
    END IF;

  EXCEPTION
    WHEN OTHERS
    THEN
   wf_core.context('ASO_CONC_REQ_INT', 'QTE_DETAIL_URL', document_id,
                    document_type, sqlerrm);
      RAISE;

  END qte_detail_url;



end ASO_CONC_REQ_INT;


/
