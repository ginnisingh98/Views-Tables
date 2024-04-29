--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_LINES_PVT" as
/* $Header: asovqlnb.pls 120.34.12010000.21 2016/01/22 16:40:56 akushwah ship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_LINES_PVT
-- Purpose          :
-- History          :
--                              10/20/2002 hyang - 2633507 performance fix
--                 08/19/04  skulkarn - In new BC4J implementation, the primary key for
--                                    for all input parameters in Create_Quote, Update_Quote APIs
--                                    will be passed. In order to honor the primary key passed
--                                    the primary key will not be set to null before calling the
--                                    table handler. Hence, commented OUT NOCOPY /* file.sql.39 change */ the code where
--                                    primary key is being set to null before calling table handler.
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30)  := 'ASO_QUOTE_LINES_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovqlnb.pls';

type number_tbl_type is table of number index by BINARY_INTEGER;

-- this procedure is used to insert rows into the various tables. It is used by
-- copy quote to override the validations.

-- can be modified to use table types instead of rec types for inserts.

PROCEDURE Insert_Quote_Line_Rows(
	P_Qte_Line_Rec     IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_REC,
    	P_Control_REC      IN    ASO_QUOTE_PUB.Control_Rec_Type
			:= ASO_QUOTE_PUB.G_MISS_Control_Rec,
    	P_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    	P_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    	P_Qte_Line_Dtl_tbl  IN    ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_qte_line_dtl_tbl,
    	P_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    	P_Tax_Detail_Tbl  IN    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
			:= ASO_QUOTE_PUB.G_MISS_tax_detail_TBL,
    	P_Freight_Charge_Tbl        IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
		        := ASO_QUOTE_PUB.G_MISS_freight_charge_TBL,
    	P_Price_Attributes_Tbl    IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
			 := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    	P_Price_Adj_Attr_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
			 := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    	P_Line_Attribs_Ext_Tbl  IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type
                         := ASO_QUOTE_PUB.G_Miss_Line_Attribs_Ext_Tbl,
        P_Sales_Credit_Tbl        IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type
                                  := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
        P_Quote_Party_Tbl         IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                    := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    	X_Qte_Line_Rec     OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    	X_Payment_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Payment_Tbl_Type,
    	X_Price_Adj_Tbl    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    	X_Qte_Line_Dtl_Tbl OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    	X_Shipment_Tbl     OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Tbl_Type,
    	X_Tax_Detail_Tbl   OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    	X_Freight_Charge_Tbl   OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ,
    	X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
    	X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    	X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type,
        X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
        X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    	X_Return_Status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    	X_Msg_Count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
    	X_Msg_Data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS

   cursor get_quote_number( l_qte_header_id number) is
     SELECT quote_number
     FROM   aso_quote_headers_all
     WHERE  quote_header_id = l_qte_header_id;


    G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
    G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
    l_price_adj_rec		ASO_QUOTE_PUB.Price_Adj_Rec_Type;
    l_price_adj_tbl		ASO_QUOTE_PUB.Price_Adj_TBL_Type;
    l_shipment_rec		ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_freight_charge_rec	ASO_QUOTE_PUB.Freight_Charge_Rec_Type;
    l_freight_charge_tbl        ASO_QUOTE_PUB.Freight_Charge_TBL_Type;
    l_tax_detail_rec		ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
    l_tax_detail_tbl            ASO_QUOTE_PUB.Tax_Detail_TBL_Type;
    l_price_attributes_rec      ASO_QUOTE_PUB.Price_Attributes_Rec_Type;
    l_qte_line_dtl_rec          ASO_QUOTE_PUB.QTE_LINE_DTL_REC_TYPE;
    l_payment_rec               ASO_QUOTE_PUB.Payment_rec_type;
    l_payment_tbl               ASO_QUOTE_PUB.Payment_tbl_type;
    l_line_attribs_rec          ASO_QUOTE_PUB.Line_Attribs_Ext_REC_type;
    l_line_attribs_tbl          ASO_QUOTE_PUB.Line_Attribs_Ext_TBL_type;
    l_price_adj_attr_tbl        ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;

    l_line_rtlship_rec          ASO_QUOTE_PUB.LINE_RLTSHIP_Rec_Type ;
    l_Sales_Credit_Tbl          ASO_QUOTE_PUB.Sales_Credit_Tbl_Type ;
    l_Quote_Party_Tbl           ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
    l_Sales_Credit_rec          ASO_QUOTE_PUB.Sales_Credit_rec_Type ;
    l_Quote_Party_rec           ASO_QUOTE_PUB.Quote_Party_rec_Type;
    l_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type;
    x_relationship_id           NUMBER;
    my_message                  VARCHAR2(2000);
    l_quote_number		NUMBER ;
    lx_price_attr_tbl          ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;


BEGIN

	X_Return_Status   :=  FND_API.G_RET_STS_SUCCESS;

-- make ids null or g_miss. this checking should be removed from table handlers



--  creating a row in the aso_quote_lines_all table
-- set id to null because table handler will not generate a new value.
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		ASO_DEBUG_PUB.add('organization_id is '||nvl(to_char(p_qte_line_rec.organization_id),'null') , 1, 'Y');
		aso_debug_pub.add('Insert_Quote_lines - Begin ', 1, 'Y');
	END IF;



l_payment_tbl := p_payment_tbl;
l_price_adj_tbl := p_price_adj_tbl;
l_price_adj_attr_tbl := p_price_adj_attr_tbl;
l_freight_charge_tbl := p_freight_charge_tbl;
l_tax_detail_tbl     := p_tax_detail_tbl ;
l_line_attribs_tbl   := p_line_attribs_ext_tbl;
l_quote_party_tbl    := p_quote_party_tbl;

x_qte_line_rec := p_qte_line_rec;
--x_qte_line_rec.QUOTE_LINE_ID := NULL;

ASO_QUOTE_LINES_PKG.Insert_Row(
          px_QUOTE_LINE_ID   => x_qte_line_rec.QUOTE_LINE_ID,
          p_CREATION_DATE    => SYSDATE,
          p_CREATED_BY       => G_USER_ID,
          p_LAST_UPDATE_DATE => SYSDATE,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_LOGIN => G_LOGIN_ID,
          p_REQUEST_ID        => p_qte_line_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_qte_line_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID              => p_qte_line_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE     => p_qte_line_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID         => p_qte_line_rec.QUOTE_HEADER_ID,
          p_ORG_ID                  => p_qte_line_rec.ORG_ID        ,
          p_LINE_CATEGORY_CODE      => p_qte_line_rec.LINE_CATEGORY_CODE ,
          p_ITEM_TYPE_CODE          => p_qte_line_rec.ITEM_TYPE_CODE ,
          p_LINE_NUMBER             => p_qte_line_rec.LINE_NUMBER,
          p_START_DATE_ACTIVE       => trunc(p_qte_line_rec.START_DATE_ACTIVE),
          p_END_DATE_ACTIVE         => trunc(p_qte_line_rec.END_DATE_ACTIVE)   ,
          p_ORDER_LINE_TYPE_ID      => p_qte_line_rec.ORDER_LINE_TYPE_ID ,
          p_INVOICE_TO_PARTY_SITE_ID=> p_qte_line_rec.INVOICE_TO_PARTY_SITE_ID,
          p_INVOICE_TO_PARTY_ID     => p_qte_line_rec.INVOICE_TO_PARTY_ID  ,
          p_INVOICE_TO_CUST_ACCOUNT_ID     => p_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID  ,
          p_ORGANIZATION_ID         => p_qte_line_rec.ORGANIZATION_ID,
          p_INVENTORY_ITEM_ID       => p_qte_line_rec.INVENTORY_ITEM_ID ,
          p_QUANTITY                => p_qte_line_rec.QUANTITY   ,
          p_UOM_CODE                => p_qte_line_rec.UOM_CODE ,
          p_MARKETING_SOURCE_CODE_ID=> p_qte_line_rec.marketing_source_code_id,
          p_PRICE_LIST_ID           => p_qte_line_rec.PRICE_LIST_ID   ,
          p_PRICE_LIST_LINE_ID      => p_qte_line_rec.PRICE_LIST_LINE_ID,
          p_CURRENCY_CODE           => p_qte_line_rec.CURRENCY_CODE   ,
          p_LINE_LIST_PRICE         => p_qte_line_rec.LINE_LIST_PRICE    ,
          p_LINE_ADJUSTED_AMOUNT    => p_qte_line_rec.LINE_ADJUSTED_AMOUNT    ,
          p_LINE_ADJUSTED_PERCENT   => p_qte_line_rec.LINE_ADJUSTED_PERCENT,
          p_LINE_QUOTE_PRICE        => p_qte_line_rec.LINE_QUOTE_PRICE   ,
          p_RELATED_ITEM_ID         => p_qte_line_rec.RELATED_ITEM_ID ,
          p_ITEM_RELATIONSHIP_TYPE  => p_qte_line_rec.ITEM_RELATIONSHIP_TYPE,
          p_ACCOUNTING_RULE_ID      => p_qte_line_rec.ACCOUNTING_RULE_ID,
          p_INVOICING_RULE_ID       => p_qte_line_rec.INVOICING_RULE_ID,
          p_SPLIT_SHIPMENT_FLAG     => p_qte_line_rec.SPLIT_SHIPMENT_FLAG   ,
          p_BACKORDER_FLAG          => p_qte_line_rec.BACKORDER_FLAG   ,
          p_MINISITE_ID             => p_qte_line_rec.MINISITE_ID,
          p_SECTION_ID              => p_qte_line_rec.SECTION_ID,
          p_ATTRIBUTE_CATEGORY      => p_qte_line_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1     => p_qte_line_rec.ATTRIBUTE1,
          p_ATTRIBUTE2     => p_qte_line_rec.ATTRIBUTE2,
          p_ATTRIBUTE3     => p_qte_line_rec.ATTRIBUTE3,
          p_ATTRIBUTE4     => p_qte_line_rec.ATTRIBUTE4,
          p_ATTRIBUTE5     => p_qte_line_rec.ATTRIBUTE5,
          p_ATTRIBUTE6     => p_qte_line_rec.ATTRIBUTE6,
          p_ATTRIBUTE7     => p_qte_line_rec.ATTRIBUTE7,
          p_ATTRIBUTE8     => p_qte_line_rec.ATTRIBUTE8,
          p_ATTRIBUTE9     => p_qte_line_rec.ATTRIBUTE9,
          p_ATTRIBUTE10    => p_qte_line_rec.ATTRIBUTE10,
          p_ATTRIBUTE11    => p_qte_line_rec.ATTRIBUTE11,
          p_ATTRIBUTE12    => p_qte_line_rec.ATTRIBUTE12,
          p_ATTRIBUTE13    => p_qte_line_rec.ATTRIBUTE13,
          p_ATTRIBUTE14    => p_qte_line_rec.ATTRIBUTE14,
          p_ATTRIBUTE15    => p_qte_line_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  => p_qte_line_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  => p_qte_line_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  => p_qte_line_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  => p_qte_line_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => p_qte_line_rec.ATTRIBUTE20,
		p_PRICED_PRICE_LIST_ID    => p_qte_line_rec.PRICED_PRICE_LIST_ID,
          p_AGREEMENT_ID            => p_qte_line_rec.AGREEMENT_ID,
          p_COMMITMENT_ID           => p_qte_line_rec.COMMITMENT_ID,
          p_DISPLAY_ARITHMETIC_OPERATOR => p_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR,
		p_LINE_TYPE_SOURCE_FLAG => p_qte_line_rec.LINE_TYPE_SOURCE_FLAG,
		p_SERVICE_ITEM_FLAG     => p_qte_line_rec.SERVICE_ITEM_FLAG,
		p_SERVICEABLE_PRODUCT_FLAG => p_qte_line_rec.SERVICEABLE_PRODUCT_FLAG,
		p_INVOICE_TO_CUST_PARTY_ID => p_qte_line_rec.INVOICE_TO_CUST_PARTY_ID,
		P_Selling_Price_Change	   => p_qte_line_rec.Selling_Price_Change,
		P_Recalculate_flag	   => p_qte_line_rec.recalculate_flag,
		p_pricing_line_type_indicator	   => p_qte_line_rec.pricing_line_type_indicator,
          p_END_CUSTOMER_PARTY_ID         =>  p_qte_line_rec.END_CUSTOMER_PARTY_ID,
          p_END_CUSTOMER_CUST_PARTY_ID    =>  p_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID,
          p_END_CUSTOMER_PARTY_SITE_ID    =>  p_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID,
          p_END_CUSTOMER_CUST_ACCOUNT_ID  =>  p_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID,
		p_OBJECT_VERSION_NUMBER => p_qte_line_rec.OBJECT_VERSION_NUMBER,
            p_CHARGE_PERIODICITY_CODE => p_qte_line_rec.CHARGE_PERIODICITY_CODE, -- Recurring charges Change
          p_SHIP_MODEL_COMPLETE_FLAG => p_qte_line_rec.SHIP_MODEL_COMPLETE_FLAG,
          p_LINE_PAYNOW_CHARGES => p_qte_line_rec.LINE_PAYNOW_CHARGES,
		p_LINE_PAYNOW_TAX => p_qte_line_rec.LINE_PAYNOW_TAX,
		p_LINE_PAYNOW_SUBTOTAL => p_qte_line_rec.LINE_PAYNOW_SUBTOTAL,
		p_PRICING_QUANTITY_UOM => p_qte_line_rec.PRICING_QUANTITY_UOM,
		p_PRICING_QUANTITY => p_qte_line_rec.PRICING_QUANTITY,
          p_CONFIG_MODEL_TYPE => p_qte_line_rec.CONFIG_MODEL_TYPE,
	           -- ER 12879412
    P_PRODUCT_FISC_CLASSIFICATION => p_qte_line_rec.PRODUCT_FISC_CLASSIFICATION,
    P_TRX_BUSINESS_CATEGORY =>   p_qte_line_rec.TRX_BUSINESS_CATEGORY
	  --ER 16531247
    ,P_ORDERED_ITEM_ID   => p_qte_line_rec.ORDERED_ITEM_ID
,P_ITEM_IDENTIFIER_TYPE => p_qte_line_rec.ITEM_IDENTIFIER_TYPE
,P_ORDERED_ITEM   => p_qte_line_rec.ORDERED_ITEM,
-- ,P_UNIT_PRICE     => p_qte_line_rec.UNIT_PRICE -- bug 17517305 commented for Bug 18930865
-- ER 21158830
		 P_LINE_UNIT_COST => p_qte_line_rec.LINE_UNIT_COST,
		 P_LINE_MARGIN_AMOUNT => p_qte_line_rec.LINE_MARGIN_AMOUNT,
		 P_LINE_MARGIN_PERCENT => p_qte_line_rec.LINE_MARGIN_PERCENT,
         P_QUANTITY_UOM_CHANGE => p_qte_line_rec.QUANTITY_UOM_CHANGE  -- added for Bug 22582573
);


	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('quote_lines ' || nvl(to_char(x_qte_line_rec.quote_line_id),'null'), 1, 'Y' );
		aso_debug_pub.add('Insert_Quote_lines - quote_line.insert_row ', 1, 'N');
	end if;
-- insert rows into the quote line details table
FOR i in 1..p_qte_line_dtl_tbl.count LOOP
        l_qte_line_dtl_rec := p_qte_line_dtl_tbl(i);
        l_qte_line_dtl_rec.quote_line_id := x_qte_line_rec.quote_line_id;
        x_qte_line_dtl_tbl(i) := l_qte_line_dtl_rec;
         -- BC4J Fix
         --x_qte_line_dtl_tbl(i).QUOTE_LINE_DETAIL_ID := NULL;
      ASO_QUOTE_LINE_DETAILS_PKG.Insert_Row(
        px_QUOTE_LINE_DETAIL_ID  => x_qte_line_dtl_tbl(i).QUOTE_LINE_DETAIL_ID,
        p_CREATION_DATE          => SYSDATE,
        p_CREATED_BY             => G_USER_ID,
        p_LAST_UPDATE_DATE       => SYSDATE,
        p_LAST_UPDATED_BY        => G_USER_ID,
        p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
        p_REQUEST_ID             => l_qte_line_dtl_rec.REQUEST_ID,
        p_PROGRAM_APPLICATION_ID =>l_qte_line_dtl_rec.PROGRAM_APPLICATION_ID,
        p_PROGRAM_ID             => l_qte_line_dtl_rec.PROGRAM_ID,
        p_PROGRAM_UPDATE_DATE    => l_qte_line_dtl_rec.PROGRAM_UPDATE_DATE,
        p_QUOTE_LINE_ID          => l_qte_line_dtl_rec.QUOTE_LINE_ID,
        p_CONFIG_HEADER_ID       => l_qte_line_dtl_rec.CONFIG_HEADER_ID,
        p_CONFIG_REVISION_NUM    => l_qte_line_dtl_rec.CONFIG_REVISION_NUM,
        p_COMPLETE_CONFIGURATION_FLAG
                             => l_qte_line_dtl_rec.COMPLETE_CONFIGURATION_FLAG,
        p_VALID_CONFIGURATION_FLAG
                             => l_qte_line_dtl_rec.VALID_CONFIGURATION_FLAG,
          p_COMPONENT_CODE   => l_qte_line_dtl_rec.COMPONENT_CODE,
          p_SERVICE_COTERMINATE_FLAG
                              => l_qte_line_dtl_rec.SERVICE_COTERMINATE_FLAG,
          p_SERVICE_DURATION  => l_qte_line_dtl_rec.SERVICE_DURATION,
          p_SERVICE_PERIOD    => l_qte_line_dtl_rec.SERVICE_PERIOD,
          p_SERVICE_UNIT_SELLING_PERCENT
                            => l_qte_line_dtl_rec.SERVICE_UNIT_SELLING_PERCENT,
          p_SERVICE_UNIT_LIST_PERCENT
                            => l_qte_line_dtl_rec.SERVICE_UNIT_LIST_PERCENT,
          p_SERVICE_NUMBER  => l_qte_line_dtl_rec.SERVICE_NUMBER,
          p_UNIT_PERCENT_BASE_PRICE
                                => l_qte_line_dtl_rec.UNIT_PERCENT_BASE_PRICE,
          p_ATTRIBUTE_CATEGORY  => l_qte_line_dtl_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_qte_line_dtl_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_qte_line_dtl_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_qte_line_dtl_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_qte_line_dtl_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_qte_line_dtl_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_qte_line_dtl_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_qte_line_dtl_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_qte_line_dtl_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_qte_line_dtl_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_qte_line_dtl_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_qte_line_dtl_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_qte_line_dtl_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_qte_line_dtl_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_qte_line_dtl_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_qte_line_dtl_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  => l_qte_line_dtl_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  => l_qte_line_dtl_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  => l_qte_line_dtl_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  => l_qte_line_dtl_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => l_qte_line_dtl_rec.ATTRIBUTE20,
		p_SERVICE_REF_TYPE_CODE  => l_qte_line_dtl_rec.SERVICE_REF_TYPE_CODE,
          p_SERVICE_REF_ORDER_NUMBER
                                => l_qte_line_dtl_rec.SERVICE_REF_ORDER_NUMBER,
          p_SERVICE_REF_LINE_NUMBER
                                => l_qte_line_dtl_rec.SERVICE_REF_LINE_NUMBER,
          p_SERVICE_REF_LINE_ID    => l_qte_line_dtl_rec.SERVICE_REF_LINE_ID,
          p_SERVICE_REF_SYSTEM_ID  => l_qte_line_dtl_rec.SERVICE_REF_SYSTEM_ID,
          p_SERVICE_REF_OPTION_NUMB
                                 => l_qte_line_dtl_rec.SERVICE_REF_OPTION_NUMB,
          p_SERVICE_REF_SHIPMENT_NUMB
                               => l_qte_line_dtl_rec.SERVICE_REF_SHIPMENT_NUMB,
          p_RETURN_REF_TYPE    => l_qte_line_dtl_rec.RETURN_REF_TYPE,
          p_RETURN_REF_HEADER_ID  => l_qte_line_dtl_rec.RETURN_REF_HEADER_ID,
          p_RETURN_REF_LINE_ID    => l_qte_line_dtl_rec.RETURN_REF_LINE_ID,
          p_RETURN_ATTRIBUTE1     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE1,
          p_RETURN_ATTRIBUTE2     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE2,
          p_RETURN_ATTRIBUTE3     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE3,
          p_RETURN_ATTRIBUTE4     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE4,
          p_RETURN_ATTRIBUTE5     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE5,
          p_RETURN_ATTRIBUTE6     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE6,
          p_RETURN_ATTRIBUTE7     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE7,
          p_RETURN_ATTRIBUTE8     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE8,
          p_RETURN_ATTRIBUTE9     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE9,
          p_RETURN_ATTRIBUTE10    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE10,
          p_RETURN_ATTRIBUTE11    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE11,
          p_RETURN_ATTRIBUTE15    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE15,
          p_RETURN_ATTRIBUTE12    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE12,
          p_RETURN_ATTRIBUTE13    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE13,
          p_RETURN_ATTRIBUTE14    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE14,
          p_RETURN_REASON_CODE    => l_qte_line_dtl_rec.RETURN_REASON_CODE,
          p_CONFIG_ITEM_ID        => l_qte_line_dtl_rec.CONFIG_ITEM_ID,
          p_REF_TYPE_CODE         => l_qte_line_dtl_rec.REF_TYPE_CODE,
          p_REF_LINE_ID           => l_qte_line_dtl_rec.REF_LINE_ID,
		p_INSTANCE_ID           => l_qte_line_dtl_rec.INSTANCE_ID,
		p_BOM_SORT_ORDER        => l_qte_line_dtl_rec.BOM_SORT_ORDER,
	     p_CONFIG_DELTA          => l_qte_line_dtl_rec.CONFIG_DELTA,
	     p_CONFIG_INSTANCE_NAME  => l_qte_line_dtl_rec.CONFIG_INSTANCE_NAME,
		P_OBJECT_VERSION_NUMBER => l_qte_line_dtl_rec.OBJECT_VERSION_NUMBER,
	     p_top_model_line_id     => l_qte_line_dtl_rec.top_model_line_id,
		p_ato_line_id           => l_qte_line_dtl_rec.ato_line_id,
		p_component_sequence_id => l_qte_line_dtl_rec.component_sequence_id
		);
END LOOP;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Insert_Quote_lines - quote_line_details.insert_row '|| x_return_status, 1, 'N');
	end if;

-- if service is immediate create a relationship line

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('service item  is ' || x_return_status, 1, 'Y');
	end if;

       IF l_qte_line_dtl_rec.service_ref_type_code = 'QUOTE' THEN

              l_line_rtlship_rec.operation_code := 'CREATE';
              l_line_rtlship_rec.quote_line_id
			:= l_qte_line_dtl_rec.SERVICE_REF_LINE_ID;
              l_line_rtlship_rec.related_quote_line_id
			:= x_qte_line_rec.quote_line_id;
              l_line_rtlship_rec.relationship_type_code := 'SERVICE';
	      l_line_rtlship_rec.reciprocal_flag   := FND_API.G_FALSE;

            ASO_LINE_RLTSHIP_PVT.Create_line_rltship(
                P_Api_Version_Number   => 1.0,
    		P_LINE_RLTSHIP_Rec     => l_line_rtlship_rec,
    		X_LINE_RELATIONSHIP_ID => x_relationship_id,
    		X_Return_Status       => x_return_status,
    		X_Msg_Count           => x_msg_count,
    		X_Msg_Data            => x_msg_data
            );


       END IF;



 -- check for duplicate promotions, see bug 4521799
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Before  calling Validate_Promotion price_attr_tbl.count: '|| p_price_attributes_tbl.count, 1, 'Y');
  END IF;

  ASO_VALIDATE_PVT.Validate_Promotion (
     P_Api_Version_Number       => 1.0,
     P_Init_Msg_List            => FND_API.G_FALSE,
     P_Commit                   => FND_API.G_FALSE,
     p_price_attr_tbl           => p_price_attributes_tbl,
     x_price_attr_tbl           => lx_price_attr_tbl,
     x_return_status            => x_return_status,
     x_msg_count                => x_msg_count,
     x_msg_data                 => x_msg_data);

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('after calling Validate_Promotion ', 1, 'Y');
      aso_debug_pub.add('Validate_Promotion  Return Status: '||x_return_status, 1, 'Y');
   END IF;

   if x_return_status <> fnd_api.g_ret_sts_success then
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   end if;


 -- end of check for duplicate promotions


-- inserting rows into the aso_price_attributes

FOR i in 1..p_price_attributes_tbl.count LOOP

     l_price_attributes_rec := p_price_attributes_tbl(i);
     l_price_attributes_rec.quote_line_id := x_qte_line_rec.quote_line_id;
     l_price_attributes_rec.quote_header_id := p_qte_line_rec.quote_header_id;
     x_price_attributes_tbl(i) := l_price_attributes_rec;
-- BC4J Fix
--x_price_attributes_tbl(i).price_attribute_id := NULL;
ASO_PRICE_ATTRIBUTES_PKG.Insert_Row(
          px_PRICE_ATTRIBUTE_ID   => x_price_attributes_tbl(i).price_attribute_id,
          p_CREATION_DATE         => SYSDATE,
          p_CREATED_BY            => G_USER_ID,
          p_LAST_UPDATE_DATE      => SYSDATE,
          p_LAST_UPDATED_BY       => G_USER_ID,
          p_LAST_UPDATE_LOGIN     => G_LOGIN_ID,
          p_REQUEST_ID            => p_qte_line_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_qte_line_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID           => p_qte_line_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => p_qte_line_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID      => p_qte_line_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID        => l_price_attributes_rec.quote_line_id,
          p_FLEX_TITLE           => l_price_attributes_rec.flex_title,
          p_PRICING_CONTEXT      => l_price_attributes_rec.pricing_context,
          p_PRICING_ATTRIBUTE1    => l_price_attributes_rec.PRICING_ATTRIBUTE1,
          p_PRICING_ATTRIBUTE2    => l_price_attributes_rec.PRICING_ATTRIBUTE2,
          p_PRICING_ATTRIBUTE3    => l_price_attributes_rec.PRICING_ATTRIBUTE3,
          p_PRICING_ATTRIBUTE4    => l_price_attributes_rec.PRICING_ATTRIBUTE4,
          p_PRICING_ATTRIBUTE5    => l_price_attributes_rec.PRICING_ATTRIBUTE5,
          p_PRICING_ATTRIBUTE6    => l_price_attributes_rec.PRICING_ATTRIBUTE6,
          p_PRICING_ATTRIBUTE7    => l_price_attributes_rec.PRICING_ATTRIBUTE7,
          p_PRICING_ATTRIBUTE8    => l_price_attributes_rec.PRICING_ATTRIBUTE8,
          p_PRICING_ATTRIBUTE9    => l_price_attributes_rec.PRICING_ATTRIBUTE9,
        p_PRICING_ATTRIBUTE10    => l_price_attributes_rec.PRICING_ATTRIBUTE10,
        p_PRICING_ATTRIBUTE11    => l_price_attributes_rec.PRICING_ATTRIBUTE11,
        p_PRICING_ATTRIBUTE12    => l_price_attributes_rec.PRICING_ATTRIBUTE12,
        p_PRICING_ATTRIBUTE13    => l_price_attributes_rec.PRICING_ATTRIBUTE13,
        p_PRICING_ATTRIBUTE14    => l_price_attributes_rec.PRICING_ATTRIBUTE14,
        p_PRICING_ATTRIBUTE15    => l_price_attributes_rec.PRICING_ATTRIBUTE15,
        p_PRICING_ATTRIBUTE16    => l_price_attributes_rec.PRICING_ATTRIBUTE16,
        p_PRICING_ATTRIBUTE17    => l_price_attributes_rec.PRICING_ATTRIBUTE17,
        p_PRICING_ATTRIBUTE18    => l_price_attributes_rec.PRICING_ATTRIBUTE18,
        p_PRICING_ATTRIBUTE19    => l_price_attributes_rec.PRICING_ATTRIBUTE19,
        p_PRICING_ATTRIBUTE20    => l_price_attributes_rec.PRICING_ATTRIBUTE20,
        p_PRICING_ATTRIBUTE21    => l_price_attributes_rec.PRICING_ATTRIBUTE21,
        p_PRICING_ATTRIBUTE22    => l_price_attributes_rec.PRICING_ATTRIBUTE22,
        p_PRICING_ATTRIBUTE23    => l_price_attributes_rec.PRICING_ATTRIBUTE23,
        p_PRICING_ATTRIBUTE24    => l_price_attributes_rec.PRICING_ATTRIBUTE24,
        p_PRICING_ATTRIBUTE25    => l_price_attributes_rec.PRICING_ATTRIBUTE25,
        p_PRICING_ATTRIBUTE26    => l_price_attributes_rec.PRICING_ATTRIBUTE26,
        p_PRICING_ATTRIBUTE27    => l_price_attributes_rec.PRICING_ATTRIBUTE27,
        p_PRICING_ATTRIBUTE28    => l_price_attributes_rec.PRICING_ATTRIBUTE28,
        p_PRICING_ATTRIBUTE29    => l_price_attributes_rec.PRICING_ATTRIBUTE29,
        p_PRICING_ATTRIBUTE30    => l_price_attributes_rec.PRICING_ATTRIBUTE30,
        p_PRICING_ATTRIBUTE31    => l_price_attributes_rec.PRICING_ATTRIBUTE31,
        p_PRICING_ATTRIBUTE32    => l_price_attributes_rec.PRICING_ATTRIBUTE32,
        p_PRICING_ATTRIBUTE33    => l_price_attributes_rec.PRICING_ATTRIBUTE33,
        p_PRICING_ATTRIBUTE34    => l_price_attributes_rec.PRICING_ATTRIBUTE34,
        p_PRICING_ATTRIBUTE35    => l_price_attributes_rec.PRICING_ATTRIBUTE35,
        p_PRICING_ATTRIBUTE36    => l_price_attributes_rec.PRICING_ATTRIBUTE36,
        p_PRICING_ATTRIBUTE37    => l_price_attributes_rec.PRICING_ATTRIBUTE37,
        p_PRICING_ATTRIBUTE38    => l_price_attributes_rec.PRICING_ATTRIBUTE38,
        p_PRICING_ATTRIBUTE39    => l_price_attributes_rec.PRICING_ATTRIBUTE39,
        p_PRICING_ATTRIBUTE40    => l_price_attributes_rec.PRICING_ATTRIBUTE40,
        p_PRICING_ATTRIBUTE41    => l_price_attributes_rec.PRICING_ATTRIBUTE41,
        p_PRICING_ATTRIBUTE42    => l_price_attributes_rec.PRICING_ATTRIBUTE42,
        p_PRICING_ATTRIBUTE43    => l_price_attributes_rec.PRICING_ATTRIBUTE43,
        p_PRICING_ATTRIBUTE44    => l_price_attributes_rec.PRICING_ATTRIBUTE44,
        p_PRICING_ATTRIBUTE45    => l_price_attributes_rec.PRICING_ATTRIBUTE45,
        p_PRICING_ATTRIBUTE46    => l_price_attributes_rec.PRICING_ATTRIBUTE46,
        p_PRICING_ATTRIBUTE47    => l_price_attributes_rec.PRICING_ATTRIBUTE47,
        p_PRICING_ATTRIBUTE48    => l_price_attributes_rec.PRICING_ATTRIBUTE48,
        p_PRICING_ATTRIBUTE49    => l_price_attributes_rec.PRICING_ATTRIBUTE49,
        p_PRICING_ATTRIBUTE50    => l_price_attributes_rec.PRICING_ATTRIBUTE50,
        p_PRICING_ATTRIBUTE51    => l_price_attributes_rec.PRICING_ATTRIBUTE51,
        p_PRICING_ATTRIBUTE52    => l_price_attributes_rec.PRICING_ATTRIBUTE52,
        p_PRICING_ATTRIBUTE53    => l_price_attributes_rec.PRICING_ATTRIBUTE53,
        p_PRICING_ATTRIBUTE54    => l_price_attributes_rec.PRICING_ATTRIBUTE54,
        p_PRICING_ATTRIBUTE55    => l_price_attributes_rec.PRICING_ATTRIBUTE55,
        p_PRICING_ATTRIBUTE56    => l_price_attributes_rec.PRICING_ATTRIBUTE56,
        p_PRICING_ATTRIBUTE57    => l_price_attributes_rec.PRICING_ATTRIBUTE57,
        p_PRICING_ATTRIBUTE58    => l_price_attributes_rec.PRICING_ATTRIBUTE58,
        p_PRICING_ATTRIBUTE59    => l_price_attributes_rec.PRICING_ATTRIBUTE59,
        p_PRICING_ATTRIBUTE60    => l_price_attributes_rec.PRICING_ATTRIBUTE60,
        p_PRICING_ATTRIBUTE61    => l_price_attributes_rec.PRICING_ATTRIBUTE61,
        p_PRICING_ATTRIBUTE62    => l_price_attributes_rec.PRICING_ATTRIBUTE62,
        p_PRICING_ATTRIBUTE63    => l_price_attributes_rec.PRICING_ATTRIBUTE63,
        p_PRICING_ATTRIBUTE64    => l_price_attributes_rec.PRICING_ATTRIBUTE64,
        p_PRICING_ATTRIBUTE65    => l_price_attributes_rec.PRICING_ATTRIBUTE65,
        p_PRICING_ATTRIBUTE66    => l_price_attributes_rec.PRICING_ATTRIBUTE66,
        p_PRICING_ATTRIBUTE67    => l_price_attributes_rec.PRICING_ATTRIBUTE67,
        p_PRICING_ATTRIBUTE68    => l_price_attributes_rec.PRICING_ATTRIBUTE68,
        p_PRICING_ATTRIBUTE69    => l_price_attributes_rec.PRICING_ATTRIBUTE69,
        p_PRICING_ATTRIBUTE70    => l_price_attributes_rec.PRICING_ATTRIBUTE70,
        p_PRICING_ATTRIBUTE71    => l_price_attributes_rec.PRICING_ATTRIBUTE71,
        p_PRICING_ATTRIBUTE72    => l_price_attributes_rec.PRICING_ATTRIBUTE72,
        p_PRICING_ATTRIBUTE73    => l_price_attributes_rec.PRICING_ATTRIBUTE73,
        p_PRICING_ATTRIBUTE74    => l_price_attributes_rec.PRICING_ATTRIBUTE74,
        p_PRICING_ATTRIBUTE75    => l_price_attributes_rec.PRICING_ATTRIBUTE75,
        p_PRICING_ATTRIBUTE76    => l_price_attributes_rec.PRICING_ATTRIBUTE76,
        p_PRICING_ATTRIBUTE77    => l_price_attributes_rec.PRICING_ATTRIBUTE77,
        p_PRICING_ATTRIBUTE78    => l_price_attributes_rec.PRICING_ATTRIBUTE78,
        p_PRICING_ATTRIBUTE79    => l_price_attributes_rec.PRICING_ATTRIBUTE79,
        p_PRICING_ATTRIBUTE80    => l_price_attributes_rec.PRICING_ATTRIBUTE80,
        p_PRICING_ATTRIBUTE81    => l_price_attributes_rec.PRICING_ATTRIBUTE81,
        p_PRICING_ATTRIBUTE82    => l_price_attributes_rec.PRICING_ATTRIBUTE82,
        p_PRICING_ATTRIBUTE83    => l_price_attributes_rec.PRICING_ATTRIBUTE83,
        p_PRICING_ATTRIBUTE84    => l_price_attributes_rec.PRICING_ATTRIBUTE84,
        p_PRICING_ATTRIBUTE85    => l_price_attributes_rec.PRICING_ATTRIBUTE85,
        p_PRICING_ATTRIBUTE86    => l_price_attributes_rec.PRICING_ATTRIBUTE86,
        p_PRICING_ATTRIBUTE87    => l_price_attributes_rec.PRICING_ATTRIBUTE87,
        p_PRICING_ATTRIBUTE88    => l_price_attributes_rec.PRICING_ATTRIBUTE88,
        p_PRICING_ATTRIBUTE89    => l_price_attributes_rec.PRICING_ATTRIBUTE89,
        p_PRICING_ATTRIBUTE90    => l_price_attributes_rec.PRICING_ATTRIBUTE90,
        p_PRICING_ATTRIBUTE91    => l_price_attributes_rec.PRICING_ATTRIBUTE91,
        p_PRICING_ATTRIBUTE92    => l_price_attributes_rec.PRICING_ATTRIBUTE92,
        p_PRICING_ATTRIBUTE93    => l_price_attributes_rec.PRICING_ATTRIBUTE93,
        p_PRICING_ATTRIBUTE94    => l_price_attributes_rec.PRICING_ATTRIBUTE94,
        p_PRICING_ATTRIBUTE95    => l_price_attributes_rec.PRICING_ATTRIBUTE95,
        p_PRICING_ATTRIBUTE96    => l_price_attributes_rec.PRICING_ATTRIBUTE96,
        p_PRICING_ATTRIBUTE97    => l_price_attributes_rec.PRICING_ATTRIBUTE97,
        p_PRICING_ATTRIBUTE98    => l_price_attributes_rec.PRICING_ATTRIBUTE98,
        p_PRICING_ATTRIBUTE99    => l_price_attributes_rec.PRICING_ATTRIBUTE99,
        p_PRICING_ATTRIBUTE100  => l_price_attributes_rec.PRICING_ATTRIBUTE100,
          p_CONTEXT    => l_price_attributes_rec.CONTEXT,
          p_ATTRIBUTE1    => l_price_attributes_rec.ATTRIBUTE1,
          p_ATTRIBUTE2    => l_price_attributes_rec.ATTRIBUTE2,
          p_ATTRIBUTE3    => l_price_attributes_rec.ATTRIBUTE3,
          p_ATTRIBUTE4    => l_price_attributes_rec.ATTRIBUTE4,
          p_ATTRIBUTE5    => l_price_attributes_rec.ATTRIBUTE5,
          p_ATTRIBUTE6    => l_price_attributes_rec.ATTRIBUTE6,
          p_ATTRIBUTE7    => l_price_attributes_rec.ATTRIBUTE7,
          p_ATTRIBUTE8    => l_price_attributes_rec.ATTRIBUTE8,
          p_ATTRIBUTE9    => l_price_attributes_rec.ATTRIBUTE9,
          p_ATTRIBUTE10    => l_price_attributes_rec.ATTRIBUTE10,
          p_ATTRIBUTE11    => l_price_attributes_rec.ATTRIBUTE11,
          p_ATTRIBUTE12    => l_price_attributes_rec.ATTRIBUTE12,
          p_ATTRIBUTE13    => l_price_attributes_rec.ATTRIBUTE13,
          p_ATTRIBUTE14    => l_price_attributes_rec.ATTRIBUTE14,
          p_ATTRIBUTE15    => l_price_attributes_rec.ATTRIBUTE15,
	     p_ATTRIBUTE16    => l_price_attributes_rec.ATTRIBUTE16,
          p_ATTRIBUTE17    => l_price_attributes_rec.ATTRIBUTE17,
          p_ATTRIBUTE18    => l_price_attributes_rec.ATTRIBUTE18,
          p_ATTRIBUTE19    => l_price_attributes_rec.ATTRIBUTE19,
          p_ATTRIBUTE20    => l_price_attributes_rec.ATTRIBUTE20,
		p_OBJECT_VERSION_NUMBER => l_price_attributes_rec.OBJECT_VERSION_NUMBER
);

END LOOP;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Insert_Quote_lines - price_attr.insert_row ', 1, 'N');
	end if;

--- insert into salescredit table

FOR i in 1..p_Sales_Credit_Tbl.count LOOP

     l_Sales_Credit_rec := p_sales_credit_tbl(i);
     l_sales_credit_rec.quote_line_id := x_qte_line_rec.quote_line_id;
     l_sales_credit_rec.quote_header_id := p_qte_line_rec.quote_header_id;
     x_sales_credit_tbl(i) := l_sales_credit_rec;
-- BC4J Fix
--x_sales_credit_tbl(i).sales_credit_id := NULL;
       ASO_SALES_CREDITS_PKG.Insert_Row(
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => l_sales_CREDIT_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_sales_CREDIT_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_sales_CREDIT_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_sales_CREDIT_rec.PROGRAM_UPDATE_DATE,
          px_SALES_CREDIT_ID  => x_SALES_CREDIT_tbl(i).SALES_CREDIT_ID,
          p_QUOTE_HEADER_ID  => l_sales_CREDIT_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_sales_CREDIT_rec.QUOTE_LINE_ID,
          p_PERCENT  => l_sales_CREDIT_rec.PERCENT,
          p_RESOURCE_ID  => l_sales_CREDIT_rec.RESOURCE_ID,
          p_RESOURCE_GROUP_ID  => l_sales_CREDIT_rec.RESOURCE_GROUP_ID,
          p_EMPLOYEE_PERSON_ID  => l_sales_CREDIT_rec.EMPLOYEE_PERSON_ID,
          p_SALES_CREDIT_TYPE_ID  => l_sales_CREDIT_rec.SALES_CREDIT_TYPE_ID,
--          p_SECURITY_GROUP_ID  => l_sales_CREDIT_rec.SECURITY_GROUP_ID,
          p_ATTRIBUTE_CATEGORY_CODE  => l_sales_CREDIT_rec.ATTRIBUTE_CATEGORY_CODE,
          p_ATTRIBUTE1  => l_sales_CREDIT_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_sales_CREDIT_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_sales_CREDIT_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_sales_CREDIT_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_sales_CREDIT_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_sales_CREDIT_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_sales_CREDIT_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_sales_CREDIT_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_sales_CREDIT_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_sales_CREDIT_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_sales_CREDIT_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_sales_CREDIT_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_sales_CREDIT_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_sales_CREDIT_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_sales_CREDIT_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  => l_sales_CREDIT_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  => l_sales_CREDIT_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  => l_sales_CREDIT_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  => l_sales_CREDIT_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => l_sales_CREDIT_rec.ATTRIBUTE20,
		p_SYSTEM_ASSIGNED_FLAG  => 'N',
          p_CREDIT_RULE_ID  => l_sales_CREDIT_rec.CREDIT_RULE_ID,
          p_OBJECT_VERSION_NUMBER  => l_sales_CREDIT_rec.OBJECT_VERSION_NUMBER);

END LOOP;

-- insert into aso_price_adjustments

 --  l_price_adj_attr_tbl  := p_price_adj_attr_tbl;



    FOR i IN 1..P_Shipment_Tbl.count LOOP

	    l_shipment_rec                            :=  p_shipment_tbl(i);
         l_shipment_rec.quote_line_id              :=  x_qte_line_rec.quote_line_id;
         l_shipment_rec.quote_header_id            :=  p_qte_line_rec.quote_header_id;
         x_shipment_tbl(i)                         :=  l_shipment_rec;
         -- BC4J Fix
    	   x_shipment_tbl(i).shipment_id             := p_shipment_tbl(i).shipment_id;
	   -- x_shipment_tbl(i).shipment_id             :=  null;
         l_shipment_rec.ship_method_code_from      :=  l_shipment_rec.ship_method_code;
         l_shipment_rec.freight_terms_code_from    :=  l_shipment_rec.freight_terms_code;
         x_shipment_tbl(i).ship_method_code_from   :=  l_shipment_rec.ship_method_code_from;
         x_shipment_tbl(i).freight_terms_code_from :=  l_shipment_rec.freight_terms_code_from;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Before ASO_SHIPMENTS_PKG.insert_rows Quote Line- p_shipment_tbl(1).ship_method_code'||p_shipment_tbl(1).ship_method_code, 1, 'Y');
           aso_debug_pub.add('Before ASO_SHIPMENTS_PKG.insert_rows Quote Line- p_shipment_tbl(1).freight_terms_code'||p_shipment_tbl(1).freight_terms_code, 1, 'Y');
         END IF;

	ASO_SHIPMENTS_PKG.Insert_Row(
            px_SHIPMENT_ID            => x_shipment_tbl(i).SHIPMENT_ID,
            p_CREATION_DATE  	      => SYSDATE,
            p_CREATED_BY  	      => G_USER_ID,
            p_LAST_UPDATE_DATE        => SYSDATE,
            p_LAST_UPDATED_BY         => G_USER_ID,
            p_LAST_UPDATE_LOGIN       => G_LOGIN_ID,
            p_REQUEST_ID  	      => l_shipment_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID  => l_shipment_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID  	      => l_shipment_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE     => l_shipment_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_HEADER_ID  	      => l_shipment_rec.QUOTE_HEADER_ID,
            p_QUOTE_LINE_ID  	      => l_shipment_rec.QUOTE_LINE_ID,
            p_PROMISE_DATE            => l_shipment_rec.PROMISE_DATE,
            p_REQUEST_DATE            => l_shipment_rec.REQUEST_DATE,
            p_SCHEDULE_SHIP_DATE      => l_shipment_rec.SCHEDULE_SHIP_DATE,
            p_SHIP_TO_PARTY_SITE_ID   => l_shipment_rec.SHIP_TO_PARTY_SITE_ID,
            p_SHIP_TO_PARTY_ID        => l_shipment_rec.SHIP_TO_PARTY_ID,
            p_SHIP_TO_CUST_ACCOUNT_ID     => l_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID  ,
            p_SHIP_PARTIAL_FLAG       => l_shipment_rec.SHIP_PARTIAL_FLAG,
            p_SHIP_SET_ID             => l_shipment_rec.SHIP_SET_ID,
            p_SHIP_METHOD_CODE        => l_shipment_rec.SHIP_METHOD_CODE,
            p_FREIGHT_TERMS_CODE      => l_shipment_rec.FREIGHT_TERMS_CODE,
            p_FREIGHT_CARRIER_CODE    => l_shipment_rec.FREIGHT_CARRIER_CODE,
            p_FOB_CODE                => l_shipment_rec.FOB_CODE,
            p_SHIPPING_INSTRUCTIONS   => l_shipment_rec.SHIPPING_INSTRUCTIONS,
            p_PACKING_INSTRUCTIONS    => l_shipment_rec.PACKING_INSTRUCTIONS,
            p_SHIPMENT_PRIORITY_CODE  => l_shipment_rec.SHIPMENT_PRIORITY_CODE,
            p_SHIP_QUOTE_PRICE        => l_shipment_rec.SHIP_QUOTE_PRICE,
            p_QUANTITY                => l_shipment_rec.QUANTITY,
            p_RESERVED_QUANTITY       => l_shipment_rec.RESERVED_QUANTITY,
            p_RESERVATION_ID          => l_shipment_rec.RESERVATION_ID,
            p_ORDER_LINE_ID           => l_shipment_rec.ORDER_LINE_ID,
            p_ATTRIBUTE_CATEGORY      => l_shipment_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1              => l_shipment_rec.ATTRIBUTE1,
            p_ATTRIBUTE2 	      => l_shipment_rec.ATTRIBUTE2,
            p_ATTRIBUTE3 	      => l_shipment_rec.ATTRIBUTE3,
            p_ATTRIBUTE4 	      => l_shipment_rec.ATTRIBUTE4,
            p_ATTRIBUTE5 	      => l_shipment_rec.ATTRIBUTE5,
            p_ATTRIBUTE6 	      => l_shipment_rec.ATTRIBUTE6,
            p_ATTRIBUTE7 	      => l_shipment_rec.ATTRIBUTE7,
            p_ATTRIBUTE8 	      => l_shipment_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  	      => l_shipment_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  	      => l_shipment_rec.ATTRIBUTE10,
            p_ATTRIBUTE11             => l_shipment_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  	      => l_shipment_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  	      => l_shipment_rec.ATTRIBUTE13,
            p_ATTRIBUTE14 	      => l_shipment_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  	      => l_shipment_rec.ATTRIBUTE15,
            p_ATTRIBUTE16  => l_shipment_rec.ATTRIBUTE16,
            p_ATTRIBUTE17  => l_shipment_rec.ATTRIBUTE17,
            p_ATTRIBUTE18  => l_shipment_rec.ATTRIBUTE18,
            p_ATTRIBUTE19  => l_shipment_rec.ATTRIBUTE19,
            p_ATTRIBUTE20  => l_shipment_rec.ATTRIBUTE20,
		  p_SHIP_FROM_ORG_ID      => l_shipment_rec.SHIP_FROM_ORG_ID,
		  p_SHIP_TO_CUST_PARTY_ID => l_shipment_rec.SHIP_TO_CUST_PARTY_ID,
            p_SHIP_METHOD_CODE_FROM   => l_shipment_rec.SHIP_METHOD_CODE_FROM,
            p_FREIGHT_TERMS_CODE_FROM  => l_shipment_rec.FREIGHT_TERMS_CODE_FROM,
		  p_OBJECT_VERSION_NUMBER  => l_shipment_rec.OBJECT_VERSION_NUMBER,
	       p_REQUEST_DATE_TYPE => l_shipment_rec.REQUEST_DATE_TYPE,
		  p_DEMAND_CLASS_CODE => l_shipment_rec.DEMAND_CLASS_CODE
		);

         FOR j IN 1..P_Freight_Charge_Tbl.count LOOP
             IF l_freight_charge_tbl(j).shipment_index = i THEN
                l_freight_charge_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;

          END LOOP;

          FOR j in 1..P_Tax_Detail_Tbl.count LOOP
              IF l_tax_detail_tbl(j).shipment_index = i THEN
                 l_tax_detail_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;
          END LOOP;

          FOR j in 1..l_line_attribs_Tbl.count LOOP
              IF l_line_attribs_tbl(j).shipment_index = i THEN
                 l_line_attribs_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;

         END LOOP;

           FOR j in 1..P_Payment_Tbl.count LOOP
              IF l_payment_tbl(j).shipment_index = i THEN
                 l_payment_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;

         END LOOP;

           FOR j in 1..P_Price_Adj_Tbl.count LOOP
              IF l_Price_Adj_tbl(j).shipment_index = i THEN
                 l_Price_Adj_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;

         END LOOP;

            FOR j in 1..P_Quote_Party_Tbl.count LOOP
              IF l_quote_party_tbl(j).shipment_index = i THEN
                 l_quote_party_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;
            END LOOP;


    END LOOP;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Insert_Quote_lines - shipments.insert_row ', 1, 'N');
	end if;

    FOR i IN 1..l_Freight_Charge_Tbl.count LOOP
	l_freight_charge_rec := l_freight_charge_tbl(i);
        l_freight_charge_rec.quote_line_id :=  x_qte_line_rec.QUOTE_LINE_ID;
        x_freight_charge_tbl(i) := l_freight_charge_rec;
        -- BC4J Fix
	   --x_FREIGHT_CHARGE_tbl(i).freight_charge_id := NULL;

-- insert rows into aso_freight_charges

        ASO_FREIGHT_CHARGES_PKG.Insert_Row(
            px_FREIGHT_CHARGE_ID  => x_FREIGHT_CHARGE_tbl(i).freight_charge_id,
            p_CREATION_DATE       => SYSDATE,
            p_CREATED_BY          => G_USER_ID,
            p_LAST_UPDATE_DATE    => SYSDATE,
            p_LAST_UPDATED_BY     => G_USER_ID,
            p_LAST_UPDATE_LOGIN   => G_LOGIN_ID,
            p_REQUEST_ID          => l_freight_charge_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID
                                => l_freight_charge_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID           => l_freight_charge_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE  => l_freight_charge_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_SHIPMENT_ID    => l_freight_charge_rec.QUOTE_SHIPMENT_ID,
            p_FREIGHT_CHARGE_TYPE_ID
                                => l_freight_charge_rec.FREIGHT_CHARGE_TYPE_ID,
            p_CHARGE_AMOUNT        => l_freight_charge_rec.CHARGE_AMOUNT,
            p_ATTRIBUTE_CATEGORY   => l_freight_charge_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1   => l_freight_charge_rec.ATTRIBUTE1,
            p_ATTRIBUTE2   => l_freight_charge_rec.ATTRIBUTE2,
            p_ATTRIBUTE3   => l_freight_charge_rec.ATTRIBUTE3,
            p_ATTRIBUTE4   => l_freight_charge_rec.ATTRIBUTE4,
            p_ATTRIBUTE5   => l_freight_charge_rec.ATTRIBUTE5,
            p_ATTRIBUTE6   => l_freight_charge_rec.ATTRIBUTE6,
            p_ATTRIBUTE7   => l_freight_charge_rec.ATTRIBUTE7,
            p_ATTRIBUTE8   => l_freight_charge_rec.ATTRIBUTE8,
            p_ATTRIBUTE9   => l_freight_charge_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  => l_freight_charge_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  => l_freight_charge_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  => l_freight_charge_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  => l_freight_charge_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  => l_freight_charge_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  => l_freight_charge_rec.ATTRIBUTE15);

    END LOOP;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Insert_Quote_lines - after frieght.insert_row '||x_return_status, 1, 'N');
	end if;

    FOR i IN 1..P_tax_detail_Tbl.count LOOP
	l_tax_detail_rec := l_tax_detail_tbl(i);
        l_tax_detail_rec.quote_line_id :=  x_qte_line_rec.QUOTE_LINE_ID;
        l_tax_detail_rec.quote_header_id := p_qte_line_rec.quote_header_id;
         x_tax_detail_tbl(i) := l_tax_detail_rec;
         -- BC4J Fix
	    --x_tax_detail_tbl(i).TAX_DETAIL_ID := NULL;

        ASO_TAX_DETAILS_PKG.Insert_Row(
            px_TAX_DETAIL_ID 	 => x_tax_detail_tbl(i).TAX_DETAIL_ID,
            p_CREATION_DATE 	 => SYSDATE,
            p_CREATED_BY 	 => G_USER_ID,
            p_LAST_UPDATE_DATE 	 => SYSDATE,
            p_LAST_UPDATED_BY	 => G_USER_ID,
            p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
            p_REQUEST_ID 	 => l_tax_detail_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID =>l_tax_detail_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID 	 => l_tax_detail_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE=> l_tax_detail_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_HEADER_ID 	 => l_tax_detail_rec.QUOTE_HEADER_ID,
            p_QUOTE_LINE_ID 	 => l_tax_detail_rec.QUOTE_LINE_ID,
            p_QUOTE_SHIPMENT_ID  => l_tax_detail_rec.QUOTE_SHIPMENT_ID,
            p_ORIG_TAX_CODE 	 => l_tax_detail_rec.ORIG_TAX_CODE,
            p_TAX_CODE  	 => l_tax_detail_rec.TAX_CODE,
            p_TAX_RATE 		 => l_tax_detail_rec.TAX_RATE,
            p_TAX_DATE 		 => l_tax_detail_rec.TAX_DATE,
            p_TAX_AMOUNT 	 => l_tax_detail_rec.TAX_AMOUNT,
            p_TAX_EXEMPT_FLAG    => l_tax_detail_rec.TAX_EXEMPT_FLAG,
            p_TAX_EXEMPT_NUMBER  => l_tax_detail_rec.TAX_EXEMPT_NUMBER,
            p_TAX_EXEMPT_REASON_CODE =>l_tax_detail_rec.TAX_EXEMPT_REASON_CODE,
            p_ATTRIBUTE_CATEGORY  => l_tax_detail_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  => l_tax_detail_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  => l_tax_detail_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  => l_tax_detail_rec.ATTRIBUTE3,
            p_ATTRIBUTE4  => l_tax_detail_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  => l_tax_detail_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  => l_tax_detail_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  => l_tax_detail_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  => l_tax_detail_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  => l_tax_detail_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  => l_tax_detail_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  => l_tax_detail_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  => l_tax_detail_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  => l_tax_detail_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  => l_tax_detail_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  => l_tax_detail_rec.ATTRIBUTE15,
            p_ATTRIBUTE16  => l_tax_detail_rec.ATTRIBUTE16,
            p_ATTRIBUTE17  => l_tax_detail_rec.ATTRIBUTE17,
            p_ATTRIBUTE18  => l_tax_detail_rec.ATTRIBUTE18,
            p_ATTRIBUTE19  => l_tax_detail_rec.ATTRIBUTE19,
            p_ATTRIBUTE20  => l_tax_detail_rec.ATTRIBUTE20,
		  p_TAX_INCLUSIVE_FLAG  => l_tax_detail_rec.TAX_INCLUSIVE_FLAG,
		  p_OBJECT_VERSION_NUMBER => l_tax_detail_rec.OBJECT_VERSION_NUMBER,
		  p_TAX_RATE_ID => l_tax_detail_rec.TAX_RATE_ID
		  );
    END LOOP;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Insert_Quote_lines - after tax_details.insert_row '|| x_return_status, 1, 'N');
	end if;

       FOR i IN 1..l_Price_Adj_Tbl.count LOOP
	l_price_adj_rec := l_price_adj_tbl(i);
        l_price_adj_rec.quote_line_id := x_qte_line_rec.quote_line_id;
        l_price_adj_rec.quote_header_id := p_qte_line_rec.quote_header_id;
        x_price_adj_tbl(i) := l_price_adj_rec;
-- BC4J Fix
--x_price_adj_tbl(i).PRICE_ADJUSTMENT_ID := NULL;
        ASO_PRICE_ADJUSTMENTS_PKG.Insert_Row(
            px_PRICE_ADJUSTMENT_ID   => x_price_adj_tbl(i).PRICE_ADJUSTMENT_ID,
            p_CREATION_DATE           => SYSDATE,
            p_CREATED_BY              => G_USER_ID,
            p_LAST_UPDATE_DATE        => SYSDATE,
            p_LAST_UPDATED_BY         => G_USER_ID,
            p_LAST_UPDATE_LOGIN       => G_LOGIN_ID,
            p_PROGRAM_APPLICATION_ID  =>l_price_adj_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID              => l_price_adj_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE     => l_price_adj_rec.PROGRAM_UPDATE_DATE,
            p_REQUEST_ID              => l_price_adj_rec.REQUEST_ID,
            p_QUOTE_HEADER_ID         => l_price_adj_rec.QUOTE_HEADER_ID,
            p_QUOTE_LINE_ID           => l_price_adj_rec.QUOTE_LINE_ID,
            p_QUOTE_SHIPMENT_ID       => l_price_adj_rec.QUOTE_SHIPMENT_ID,
            p_MODIFIER_HEADER_ID      => l_price_adj_rec.MODIFIER_HEADER_ID,
            p_MODIFIER_LINE_ID         => l_price_adj_rec.MODIFIER_LINE_ID,
            p_MODIFIER_LINE_TYPE_CODE
                               => l_price_adj_rec.MODIFIER_LINE_TYPE_CODE,
            p_MODIFIER_MECHANISM_TYPE_CODE
                               => l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE,
            p_MODIFIED_FROM         => l_price_adj_rec.MODIFIED_FROM,
            p_MODIFIED_TO           => l_price_adj_rec.MODIFIED_TO,
            p_OPERAND               => l_price_adj_rec.OPERAND,
            p_ARITHMETIC_OPERATOR   => l_price_adj_rec.ARITHMETIC_OPERATOR,
            p_AUTOMATIC_FLAG        => l_price_adj_rec.AUTOMATIC_FLAG,
            p_UPDATE_ALLOWABLE_FLAG => l_price_adj_rec.UPDATE_ALLOWABLE_FLAG,
            p_UPDATED_FLAG          => l_price_adj_rec.UPDATED_FLAG,
            p_APPLIED_FLAG          => l_price_adj_rec.APPLIED_FLAG,
            p_ON_INVOICE_FLAG       => l_price_adj_rec.ON_INVOICE_FLAG,
            p_PRICING_PHASE_ID      => l_price_adj_rec.PRICING_PHASE_ID,
            p_ATTRIBUTE_CATEGORY    => l_price_adj_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1            => l_price_adj_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  	    => l_price_adj_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  	    => l_price_adj_rec.ATTRIBUTE3,
            p_ATTRIBUTE4            => l_price_adj_rec.ATTRIBUTE4,
            p_ATTRIBUTE5            => l_price_adj_rec.ATTRIBUTE5,
            p_ATTRIBUTE6            => l_price_adj_rec.ATTRIBUTE6,
            p_ATTRIBUTE7            => l_price_adj_rec.ATTRIBUTE7,
            p_ATTRIBUTE8            => l_price_adj_rec.ATTRIBUTE8,
            p_ATTRIBUTE9            => l_price_adj_rec.ATTRIBUTE9,
            p_ATTRIBUTE10           => l_price_adj_rec.ATTRIBUTE10,
            p_ATTRIBUTE11           => l_price_adj_rec.ATTRIBUTE11,
            p_ATTRIBUTE12           => l_price_adj_rec.ATTRIBUTE12,
            p_ATTRIBUTE13           => l_price_adj_rec.ATTRIBUTE13,
            p_ATTRIBUTE14           => l_price_adj_rec.ATTRIBUTE14,
            p_ATTRIBUTE15           => l_price_adj_rec.ATTRIBUTE15,
            p_ATTRIBUTE16  =>  l_price_adj_rec.ATTRIBUTE16,
            p_ATTRIBUTE17  =>  l_price_adj_rec.ATTRIBUTE17,
            p_ATTRIBUTE18  =>  l_price_adj_rec.ATTRIBUTE18,
            p_ATTRIBUTE19  =>  l_price_adj_rec.ATTRIBUTE19,
            p_ATTRIBUTE20  =>  l_price_adj_rec.ATTRIBUTE20,
		  p_ORIG_SYS_DISCOUNT_REF                    => l_price_adj_rec.ORIG_SYS_DISCOUNT_REF ,
          p_CHANGE_SEQUENCE                           => l_price_adj_rec.CHANGE_SEQUENCE ,
          -- p_LIST_HEADER_ID                            => l_price_adj_rec. ,
          -- p_LIST_LINE_ID                              => l_price_adj_rec. ,
          -- p_LIST_LINE_TYPE_CODE                       => l_price_adj_rec.,
          p_UPDATE_ALLOWED                            => l_price_adj_rec.UPDATE_ALLOWED,
          p_CHANGE_REASON_CODE                        => l_price_adj_rec.CHANGE_REASON_CODE,
          p_CHANGE_REASON_TEXT                        => l_price_adj_rec.CHANGE_REASON_TEXT,
          p_COST_ID                                   => l_price_adj_rec.COST_ID ,
          p_TAX_CODE                                  => l_price_adj_rec.TAX_CODE,
          p_TAX_EXEMPT_FLAG                           => l_price_adj_rec.TAX_EXEMPT_FLAG,
          p_TAX_EXEMPT_NUMBER                         => l_price_adj_rec.TAX_EXEMPT_NUMBER,
          p_TAX_EXEMPT_REASON_CODE                    => l_price_adj_rec.TAX_EXEMPT_REASON_CODE,
          p_PARENT_ADJUSTMENT_ID                      => l_price_adj_rec.PARENT_ADJUSTMENT_ID,
          p_INVOICED_FLAG                             => l_price_adj_rec.INVOICED_FLAG,
          p_ESTIMATED_FLAG                            => l_price_adj_rec.ESTIMATED_FLAG,
          p_INC_IN_SALES_PERFORMANCE                  => l_price_adj_rec.INC_IN_SALES_PERFORMANCE,
          p_SPLIT_ACTION_CODE                         => l_price_adj_rec.SPLIT_ACTION_CODE,
          p_ADJUSTED_AMOUNT                           => l_price_adj_rec.ADJUSTED_AMOUNT ,
          p_CHARGE_TYPE_CODE                          => l_price_adj_rec.CHARGE_TYPE_CODE,
          p_CHARGE_SUBTYPE_CODE                       => l_price_adj_rec.CHARGE_SUBTYPE_CODE,
          p_RANGE_BREAK_QUANTITY                      => l_price_adj_rec.RANGE_BREAK_QUANTITY,
          p_ACCRUAL_CONVERSION_RATE                   => l_price_adj_rec.ACCRUAL_CONVERSION_RATE ,
          p_PRICING_GROUP_SEQUENCE                    => l_price_adj_rec.PRICING_GROUP_SEQUENCE,
          p_ACCRUAL_FLAG                              => l_price_adj_rec.ACCRUAL_FLAG,
          p_LIST_LINE_NO                              => l_price_adj_rec.LIST_LINE_NO,
          p_SOURCE_SYSTEM_CODE                        => l_price_adj_rec.SOURCE_SYSTEM_CODE ,
          p_BENEFIT_QTY                               => l_price_adj_rec.BENEFIT_QTY,
          p_BENEFIT_UOM_CODE                          => l_price_adj_rec.BENEFIT_UOM_CODE,
          p_PRINT_ON_INVOICE_FLAG                     => l_price_adj_rec.PRINT_ON_INVOICE_FLAG,
          p_EXPIRATION_DATE                           => l_price_adj_rec.EXPIRATION_DATE,
          p_REBATE_TRANSACTION_TYPE_CODE              => l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE,
          p_REBATE_TRANSACTION_REFERENCE              => l_price_adj_rec.REBATE_TRANSACTION_REFERENCE,
          p_REBATE_PAYMENT_SYSTEM_CODE                => l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE,
          p_REDEEMED_DATE                             => l_price_adj_rec.REDEEMED_DATE,
          p_REDEEMED_FLAG                             => l_price_adj_rec.REDEEMED_FLAG,
          p_MODIFIER_LEVEL_CODE                       => l_price_adj_rec.MODIFIER_LEVEL_CODE,
          p_PRICE_BREAK_TYPE_CODE                     => l_price_adj_rec.PRICE_BREAK_TYPE_CODE ,
          p_SUBSTITUTION_ATTRIBUTE                    => l_price_adj_rec.SUBSTITUTION_ATTRIBUTE,
          p_PRORATION_TYPE_CODE                       => l_price_adj_rec.PRORATION_TYPE_CODE ,
          p_INCLUDE_ON_RETURNS_FLAG                   => l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG,
          p_CREDIT_OR_CHARGE_FLAG                     => l_price_adj_rec.CREDIT_OR_CHARGE_FLAG,
		p_OPERAND_PER_PQTY                          => l_price_adj_rec.OPERAND_PER_PQTY,
		p_ADJUSTED_AMOUNT_PER_PQTY                  => l_price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY,
	     p_OBJECT_VERSION_NUMBER                     => l_price_adj_rec.OBJECT_VERSION_NUMBER
		);

   FOR j in 1..l_price_adj_attr_tbl.count LOOP
     IF l_price_adj_attr_tbl(j).price_adj_index = i THEN
        l_price_adj_attr_tbl(j).price_adjustment_id
                     := x_price_adj_tbl(i).PRICE_ADJUSTMENT_ID;
     END IF;
   END LOOP;

 END LOOP;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
  		aso_debug_pub.add('Insert_Quote_lines - after price_adj.insert_row ', 1, 'N');
	end if;


   x_price_adj_attr_tbl := l_price_adj_attr_tbl;

   FOR i in 1..l_price_adj_attr_tbl.count LOOP
     -- BC4J Fix
	--x_price_adj_attr_tbl(i).PRICE_ADJ_ATTRIB_ID := NULL;
    ASO_PRICE_ADJ_ATTRIBS_PKG.Insert_Row(
          px_PRICE_ADJ_ATTRIB_ID
			=> x_price_adj_attr_tbl(i).PRICE_ADJ_ATTRIB_ID,
          p_CREATION_DATE      => SYSDATE,
          p_CREATED_BY         => G_USER_ID,
          p_LAST_UPDATE_DATE   => SYSDATE,
          p_LAST_UPDATED_BY    => G_USER_ID,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_PROGRAM_APPLICATION_ID
			=>l_price_adj_attr_tbl(i).PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_price_adj_attr_tbl(i).PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE =>l_price_adj_attr_tbl(i).PROGRAM_UPDATE_DATE,
          p_REQUEST_ID  	=> l_price_adj_attr_tbl(i).REQUEST_ID,
          p_PRICE_ADJUSTMENT_ID => l_price_adj_attr_tbl(i).PRICE_ADJUSTMENT_ID,
          p_PRICING_CONTEXT     => l_price_adj_attr_tbl(i).PRICING_CONTEXT,
          p_PRICING_ATTRIBUTE   => l_price_adj_attr_tbl(i).PRICING_ATTRIBUTE,
          p_PRICING_ATTR_VALUE_FROM
			   => l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_FROM,
          p_PRICING_ATTR_VALUE_TO
                           => l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_TO,
          p_COMPARISON_OPERATOR
                           => l_price_adj_attr_tbl(i).COMPARISON_OPERATOR,
          p_FLEX_TITLE     => l_price_adj_attr_tbl(i).FLEX_TITLE,
		P_OBJECT_VERSION_NUMBER => l_price_adj_attr_tbl(i).OBJECT_VERSION_NUMBER
		);

END LOOP;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Insert_Quote_lines - price_adj_attr.insert_row ', 1, 'N');
	end if;


    FOR i IN 1..l_Payment_Tbl.count LOOP

        l_payment_rec                      := l_payment_tbl(i);
        l_payment_rec.quote_line_id        := x_qte_line_rec.quote_line_id;
        l_payment_rec.quote_header_id      := p_qte_line_rec.quote_header_id;
        x_payment_tbl(i)                   := l_payment_rec;
        l_payment_rec.payment_term_id_from := l_payment_tbl(i).payment_term_id;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Insert Rows l_payment_tbl(i).payment_term_id'||l_payment_tbl(i).payment_term_id, 1, 'Y');
           aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Insert Rows l_payment_rec.PAYMENT_TERM_ID_FROM'||l_payment_rec.PAYMENT_TERM_ID_FROM, 1, 'Y');
        END IF;
         -- BC4J Fix
        --x_payment_tbl(i).PAYMENT_ID           := NULL;
        x_payment_tbl(i).PAYMENT_TERM_ID_FROM := l_payment_rec.PAYMENT_TERM_ID_FROM;

     -- Suyog Payments Changes

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Insert_Quote_Line_Rows: Before  call to create_payment_row ', 1, 'Y');
           END IF;

         aso_payment_int.create_payment_row(p_payment_rec => l_payment_rec  ,
                                             x_payment_rec   => x_payment_tbl(i),
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Insert_Quote_Line_Rows: After call to create_payment_row: x_return_status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;

     x_payment_tbl(i).payment_term_id_from := l_payment_rec.payment_term_id_from;

     -- End Suyog Payment Changes
    END LOOP;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Insert_Quote_lines - payment.insert_row ', 1, 'N');
	end if;

-- insert rows into aso_shipments_tbl


-- insert into quote party table

 FOR i IN 1..l_quote_party_Tbl.count LOOP
	l_quote_party_rec := l_quote_party_tbl(i);
        l_quote_party_rec.quote_line_id :=  x_qte_line_rec.QUOTE_LINE_ID;
        l_quote_party_rec.quote_header_id := p_qte_line_rec.quote_header_id;
        x_quote_party_tbl(i) := l_quote_party_rec;
         -- BC4J Fix
        --x_quote_party_tbl(i).QUOTE_PARTY_ID := NULL;

           ASO_QUOTE_PARTIES_PKG.Insert_Row(
          px_QUOTE_PARTY_ID  => x_quote_party_tbl(i).QUOTE_PARTY_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_REQUEST_ID  => l_QUOTE_PARTY_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  =>l_QUOTE_PARTY_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_QUOTE_PARTY_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_QUOTE_PARTY_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID  => l_QUOTE_PARTY_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_QUOTE_PARTY_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID  => l_QUOTE_PARTY_rec.QUOTE_SHIPMENT_ID,
          p_PARTY_TYPE  => l_QUOTE_PARTY_rec.PARTY_TYPE,
          p_PARTY_ID  => l_QUOTE_PARTY_rec.PARTY_ID,
          p_PARTY_OBJECT_TYPE  => l_QUOTE_PARTY_rec.PARTY_OBJECT_TYPE,
          p_PARTY_OBJECT_ID  => l_QUOTE_PARTY_rec.PARTY_OBJECT_ID,
          p_ATTRIBUTE_CATEGORY  => l_QUOTE_PARTY_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_QUOTE_PARTY_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_QUOTE_PARTY_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_QUOTE_PARTY_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_QUOTE_PARTY_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_QUOTE_PARTY_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_QUOTE_PARTY_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_QUOTE_PARTY_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_QUOTE_PARTY_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_QUOTE_PARTY_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_QUOTE_PARTY_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_QUOTE_PARTY_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_QUOTE_PARTY_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_QUOTE_PARTY_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_QUOTE_PARTY_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_QUOTE_PARTY_rec.ATTRIBUTE15,
  --          p_SECURITY_GROUP_ID  => p_QUOTE_PARTY_rec.SECURITY_GROUP_ID);
        p_OBJECT_VERSION_NUMBER  => l_QUOTE_PARTY_rec.OBJECT_VERSION_NUMBER);

 END LOOP;


    FOR i IN 1..l_line_attribs_Tbl.count LOOP
	l_line_attribs_rec := l_line_attribs_tbl(i);
        l_line_attribs_rec.quote_line_id :=  x_qte_line_rec.QUOTE_LINE_ID;
        l_line_attribs_rec.quote_header_id := x_qte_line_rec.QUOTE_HEADER_ID;
        x_line_attribs_ext_tbl(i) := l_line_attribs_rec;
        -- BC4J Fix
	   --x_LINE_ATTRIBS_EXT_TBL(i).LINE_ATTRIBUTE_ID := NULL;

 ASO_QUOTE_LINE_ATTRIBS_EXT_PKG.Insert_Row(
          px_LINE_ATTRIBUTE_ID  => x_LINE_ATTRIBS_EXT_TBL(i).LINE_ATTRIBUTE_ID,
          p_CREATION_DATE          => SYSDATE,
          p_CREATED_BY             => G_USER_ID,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_LAST_UPDATED_BY        => G_USER_ID,
          p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
          p_REQUEST_ID             => l_LINE_ATTRIBS_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID =>l_LINE_ATTRIBS_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID             => l_LINE_ATTRIBS_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE    => l_LINE_ATTRIBS_rec.PROGRAM_UPDATE_DATE,
           p_APPLICATION_ID         => l_LINE_ATTRIBS_rec.APPLICATION_ID,
          p_STATUS                 => l_LINE_ATTRIBS_rec.STATUS,
          p_QUOTE_HEADER_ID        => l_LINE_ATTRIBS_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID          => l_LINE_ATTRIBS_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID      => l_LINE_ATTRIBS_rec.QUOTE_SHIPMENT_ID,
          p_ATTRIBUTE_TYPE_CODE    => l_LINE_ATTRIBS_rec.ATTRIBUTE_TYPE_CODE,
          p_NAME                   => l_LINE_ATTRIBS_rec.NAME,
          p_VALUE                  => l_LINE_ATTRIBS_rec.VALUE,
           p_VALUE_TYPE             => l_LINE_ATTRIBS_rec.VALUE_TYPE,
          p_START_DATE_ACTIVE      => l_LINE_ATTRIBS_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE        => l_LINE_ATTRIBS_rec.END_DATE_ACTIVE,
		P_OBJECT_VERSION_NUMBER  => l_LINE_ATTRIBS_rec.OBJECT_VERSION_NUMBER);
END LOOP;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Insert_Quote_lines - line_attribs.insert_row ', 1, 'N');
	end if;

	-- Change START
	-- Release 12 TAP Changes
	-- Girish Sachdeva 8/30/2005
	-- Adding the call to insert record in the ASO_CHANGED_QUOTES

	-- Finding the quote number
    open get_quote_number(X_Qte_Line_Rec.QUOTE_HEADER_ID);
    fetch get_quote_number into l_quote_number;
    if get_quote_number%FOUND then
	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_QUOTE_LINES_PVT.Insert_Quote_lines : Calling ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES, quote number : ' || l_quote_number, 1, 'Y');
	 END IF;

	  -- Call to insert record in ASO_CHANGED_QUOTES
	  ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES(l_quote_number);
    end if;
    close get_quote_number;

	-- Change END

END;

PROCEDURE Populate_Quote_Line(
    P_Qte_Line_Rec          IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type         := ASO_QUOTE_PUB.G_MISS_qte_line_REC,
    P_Control_REC           IN   ASO_QUOTE_PUB.Control_Rec_Type          := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    P_Payment_Tbl           IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Price_Adj_Tbl         IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type        := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Qte_Line_Dtl_tbl      IN   ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type     := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Shipment_Tbl          IN   ASO_QUOTE_PUB.Shipment_Tbl_Type         := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl        IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl    IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_freight_charge_TBL,
    P_Price_Attributes_Tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type   := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Attribs_Ext_Tbl  IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type := ASO_QUOTE_PUB.G_Miss_Line_Attribs_Ext_Tbl,
    P_Sales_Credit_Tbl      IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type     := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Update_Header_Flag    IN   VARCHAR2                                := FND_API.G_TRUE,
    P_operation_code        IN   VARCHAR2,
    X_Qte_Line_Rec          OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    X_Payment_Tbl           OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_Price_Adj_Tbl         OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Qte_Line_Dtl_TBL      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Dtl_TBL_Type,
    X_Shipment_Tbl          OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2

)
IS

/* 2633507 - hyang: using lc_organization_id as cursor variable */

        CURSOR C_item1(inv1 NUMBER, lc_organization_id NUMBER) IS
                select primary_uom_code, service_item_flag,serviceable_product_flag,ship_model_complete_flag,
			        payment_terms_id,config_model_type
      		from mtl_system_items_b
      		where inventory_item_id = inv1
      		and organization_id = lc_organization_id;

	CURSOR C_shipment IS
        	SELECT count(*) ,sum(quantity)
        	FROM aso_shipments
        	WHERE quote_line_id = p_qte_line_rec.quote_line_id;

        CURSOR C_header IS
         	SELECT quote_header_id, organization_id, inventory_item_id
   		FROM aso_quote_lines_all
   		WHERE quote_line_id = p_qte_line_rec.quote_line_id;

        CURSOR C_customer IS
                SELECT cust_account_id, party_id
                FROM aso_quote_headers_all
                WHERE quote_header_id = p_qte_line_rec.quote_header_id;

        CURSOR C_service_item IS
                SELECT qln.start_date_active, qln.end_date_active,
                       detail.service_duration, detail.service_period,
                       detail.service_coterminate_flag,
                       qhd.cust_account_id, qhd.party_id
                FROM aso_quote_lines_all qln,
                     aso_quote_line_details detail,
                     aso_quote_headers_all qhd
                WHERE detail.quote_line_id = qln.quote_line_id
                AND qln.quote_line_id = p_qte_line_rec.quote_line_id
                AND qln.quote_header_id = qhd.quote_header_id;

         CURSOR C_org_id IS
                SELECT org_id
                FROM aso_quote_headers_all
                WHERE quote_header_id = p_qte_line_rec.quote_header_id;

      CURSOR c_line_number ( p_quote_line_id  NUMBER ) IS
      SELECT line_number
      FROM aso_quote_lines_all
      where quote_line_id = p_quote_line_id;

     cursor c_config_item_id( p_config_header_id number, p_config_revision_num number,
                               p_component_code varchar2 ) is
      select config_item_id, bom_sort_order
      from cz_config_details_v
      where config_hdr_id  = p_config_header_id     and
            config_rev_nbr = p_config_revision_num  and
            component_code = p_component_code;

      cursor c_bom_sort_order( p_config_header_id number, p_config_revision_num number,
                               p_config_item_id number ) is
      select bom_sort_order
      from cz_config_details_v
      where config_hdr_id  = p_config_header_id     and
            config_rev_nbr = p_config_revision_num  and
            config_item_id = p_config_item_id;

     -- Recurring charges Change
     CURSOR c_periodicity(p_inventory_item_id IN Number, p_organization_id IN Number) IS
      SELECT charge_periodicity_code
      FROM   mtl_system_items_b
      WHERE  inventory_item_id = p_inventory_item_id
      AND    organization_id = p_organization_id;

     Cursor get_hdr_term(l_qte_hdr_id number) is
     select payment_term_id
     from aso_payments
     where quote_header_id = l_qte_hdr_id
     and quote_line_id is null;

     l_hdr_term_id              number := null;
	l_uom_code 		  VARCHAR2(3);
	l_service_item_flag 	  VARCHAR2(1);
	l_total_shipment_quantity NUMBER := 0;
        l_total_quantity          NUMBER;
	l_shipment_quantity       NUMBER;
	l_shipment_rec_count      NUMBER;
	l_line_number             NUMBER;
	l_check           	  VARCHAR2(1) := FND_API.G_FALSE;
        l_customer_id             NUMBER;
        l_acct                    NUMBER;
        l_party                   NUMBER;
        l_coterminate_flag        VARCHAR2(1);
        l_start_date              DATE;
        l_end_date                DATE;
        l_service_period          VARCHAR2(200);
        l_service_duration        NUMBER;
        calc_service              VARCHAR2(1) := FND_API.G_FALSE;
        l_inventory_item_id       NUMBER;
        l_organization_id         NUMBER;
	i                         NUMBER;
        l_serviceable_line_number         NUMBER;
	   l_serviceable_product_flag VARCHAR2(1);

-- local variables
	l_Qte_Line_Rec          ASO_QUOTE_PUB.Qte_Line_Rec_Type          := ASO_QUOTE_PUB.G_MISS_qte_line_REC;
	l_Payment_Tbl           ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_Payment_TBL;
	l_Price_Adj_Tbl         ASO_QUOTE_PUB.Price_Adj_Tbl_Type         := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL;
	l_Qte_Line_Dtl_rec      ASO_QUOTE_PUB.Qte_Line_Dtl_rec_Type      := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_REC;
	l_Shipment_Tbl          ASO_QUOTE_PUB.Shipment_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_shipment_TBL;
	l_Tax_Detail_Tbl        ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_MISS_tax_detail_TBL;
	l_Freight_Charge_Tbl    ASO_QUOTE_PUB.Freight_Charge_Tbl_Type    := ASO_QUOTE_PUB.G_MISS_freight_charge_TBL;
	l_Line_Rltship_Tbl      ASO_QUOTE_PUB.Line_Rltship_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_line_rltship_TBL;
	l_Price_Attributes_Tbl  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL;
	l_Price_Adj_rltship_Tbl ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL;
	l_Price_Adj_Attr_Tbl    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type    := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl;
	l_Line_Attribs_Ext_Tbl  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type  := ASO_QUOTE_PUB.G_Miss_Line_Attribs_Ext_Tbl;
	l_Qte_Line_Dtl_tbl      ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type      := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL;
	l_qte_header_rec        ASO_QUOTE_PUB.Qte_Header_Rec_Type;
	l_hd_shipment_tbl       ASO_QUOTE_PUB.Shipment_Tbl_Type;
	l_hd_shipment_rec       ASO_QUOTE_PUB.Shipment_Rec_Type;
	l_hd_price_attr_tbl     ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
l_Qte_Line_Dtl_tbl_old ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type      := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL;
     l_call_get_duration       VARCHAR2(1) := FND_API.G_FALSE;
     /* New Variable for  changes */
	l_Qte_Line_Dtl_tbl_out  ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type;
     l_qte_line_rec_out  ASO_QUOTE_PUB.Qte_Line_Rec_Type;
     l_ship_model_complete_flag  VARCHAR2(1);
	l_master_organization_id    number;
     l_payment_term_id           number;
     l_installment_option        varchar2(240);
     l_config_model_type         varchar2(1);

BEGIN

aso_debug_pub.add('Inside populate_quote_line p_qte_line_dtl_tbl.count' || p_qte_line_dtl_tbl.count);
    X_Return_Status          := FND_API.G_RET_STS_SUCCESS;

    l_Qte_Line_Rec           := p_Qte_Line_Rec   ;
    l_Payment_Tbl            := p_Payment_Tbl    ;
    l_Price_Adj_Tbl          := p_Price_Adj_Tbl  ;
    l_Qte_Line_Dtl_tbl       := p_Qte_Line_Dtl_tbl   ;
    l_Shipment_Tbl           := p_Shipment_Tbl       ;
    l_Tax_Detail_Tbl         := p_Tax_Detail_Tbl     ;
    l_Freight_Charge_Tbl     := p_Freight_Charge_Tbl       ;
    l_Price_Attributes_Tbl   := p_Price_Attributes_Tbl     ;
    l_Price_Adj_Attr_Tbl     := p_Price_Adj_Attr_Tbl ;
    l_Line_Attribs_Ext_Tbl   := p_Line_Attribs_Ext_Tbl;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Populate_Quote_lines - Begin ', 1, 'Y');
    end if;

    -- default quantity for every shipment line is 1


    IF p_operation_code = 'CREATE' THEN

        -- default org id from header

        IF l_qte_line_rec.org_id is NULL OR l_qte_line_rec.org_id = FND_API.G_MISS_NUM THEN

            OPEN C_org_id;
            FETCH C_org_id into l_qte_line_rec.org_id;

            IF (C_org_id%NOTFOUND) THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                 FND_MESSAGE.Set_Token('COLUMN', 'ORG_ID', FALSE);
                 FND_MSG_PUB.ADD;
              END IF;

            END IF;

            CLOSE C_org_id;

        END IF;

        -- default organization_id from profile

        IF l_qte_line_rec.organization_id is NULL or l_qte_line_rec.organization_id = FND_API.G_MISS_NUM THEN

            l_qte_line_rec.organization_id := oe_profile.value('OE_ORGANIZATION_ID',l_qte_line_rec.org_id);

            IF l_qte_line_rec.organization_id is NULL or l_qte_line_rec.organization_id = FND_API.G_MISS_NUM THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		         FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
		         FND_MESSAGE.Set_Token('COLUMN', 'ORGANIZATION_ID', FALSE);
		         FND_MSG_PUB.ADD;
	           END IF;

            END IF;

	       if aso_debug_pub.g_debug_flag = 'Y' then
		      aso_debug_pub.add('Populate_Quote_lines: l_qte_line_rec.organization_id: '||l_qte_line_rec.organization_id);
	       end if;

        END IF;


        -- item_type code

        IF l_qte_line_rec.item_type_code is NULL OR l_qte_line_rec.item_type_code = FND_API.G_MISS_CHAR THEN

             SELECT Decode(i.bom_item_type , 1, 'MDL',2,'OPT',3,'PLN',4,'STD')
             INTO  l_qte_line_rec.item_type_code
             FROM mtl_system_items_b i
             WHERE inventory_item_id = l_qte_line_rec.inventory_item_id
             AND organization_id     = l_qte_line_rec.organization_id;

             IF (SQL%NOTFOUND) THEN

                 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
                     FND_MESSAGE.Set_Token('COLUMN', 'ITEM TYPE CODE', FALSE);
                     FND_MSG_PUB.ADD;
                 END IF;

             END IF;

        END IF; --IF l_qte_line_rec.item_type_code is NULL OR l_qte_line_rec.item_type_code = FND_API.G_MISS_CHAR





        -- Recurring charges Change
        -- default charge_periodicity_code from Inventory

	   if p_control_rec.defaulting_fwk_flag = 'N' then

            IF l_qte_line_rec.charge_periodicity_code is NULL OR l_qte_line_rec.charge_periodicity_code = FND_API.G_MISS_CHAR THEN

		         l_master_organization_id := oe_sys_parameters.value(param_name => 'MASTER_ORGANIZATION_ID', p_org_id => l_qte_line_rec.org_id);

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('Populate_Quote_lines: l_master_organization_id: '|| l_master_organization_id, 1, 'N');
                   END IF;

                   OPEN c_periodicity(l_qte_line_rec.inventory_item_id, l_master_organization_id);
              	    FETCH c_periodicity INTO l_qte_line_rec.charge_periodicity_code;

                   IF c_periodicity%NOTFOUND THEN
                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('Populate_Quote_lines: IF c_periodicity%NOTFOUND invitem'||l_qte_line_rec.inventory_item_id, 1, 'N');
                       END IF;
                   END IF;

                   close c_periodicity;

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('Populate_Quote_lines: l_qte_line_rec.charge_periodicity_code: '|| l_qte_line_rec.charge_periodicity_code, 1, 'N');
                   END IF;
            END IF;
	   end if;


        IF  l_qte_line_rec.quantity is null or l_qte_line_rec.quantity = FND_API.G_MISS_NUM THEN
             l_qte_line_rec.quantity :=  nvl(fnd_profile.value(name => 'ASO_DEFAULT_QTY'),1);
        END IF;


        OPEN C_Shipment;
        FETCH C_shipment INTO l_shipment_rec_count, l_total_shipment_quantity;

        IF C_shipment%FOUND THEN
            CLOSE C_Shipment;

            IF l_shipment_rec_count > 0  THEN

                 FOR i IN 1..l_shipment_tbl.count LOOP
                     IF l_shipment_tbl(i).operation_code = 'CREATE' THEN
                         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                             FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_SHIPMENTS');
                             FND_MSG_PUB.ADD;
                         END IF;
                         raise FND_API.G_EXC_ERROR;
                     END IF;
                 END LOOP;

            END IF;

        ELSE
            CLOSE C_Shipment;
        END IF;


        IF l_shipment_tbl.count > 1 THEN

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_SHIPMENTS');
                FND_MSG_PUB.ADD;
            END IF;
            raise FND_API.G_EXC_ERROR;

        ELSIF l_shipment_tbl.count > 0 THEN

            IF l_qte_line_rec.quantity <> l_shipment_tbl(1).quantity THEN
                l_shipment_tbl(1).quantity := l_qte_line_rec.quantity;
            END IF;
        END IF;


        Open C_Item1(p_qte_line_rec.inventory_item_id, l_qte_line_rec.organization_id);
        Fetch C_Item1 into l_uom_code, l_service_item_flag,l_serviceable_product_flag,l_ship_model_complete_flag,l_payment_term_id,l_config_model_type;

        If C_Item1%NOTFOUND Then

            CLOSE C_Item1;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_INFO');
                FND_MESSAGE.Set_Token('COLUMN','ITEM RELATED', FALSE);
                FND_MSG_PUB.Add;
            END IF;
            raise FND_API.G_EXC_ERROR;

        ELSE

            -- pnpl changes
            l_installment_option := oe_sys_parameters.value(param_name => 'INSTALLMENT_OPTIONS',
	                                                                      p_org_id =>l_qte_line_rec.org_id);

          if (l_installment_option =  'ENABLE_PAY_NOW') THEN

		   --if ((p_control_rec.defaulting_fwk_flag = 'N') and (l_installment_option =  'ENABLE_PAYNOW')) THEN

             if (l_payment_term_id is not null and l_payment_term_id <> fnd_api.g_miss_num) then

			  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Populate_Quote_lines:Setting the payment term for line from item master ', 1, 'N');
                 END IF;

                 IF (l_payment_tbl.count = 0) THEN
                  l_payment_tbl(1).operation_code := 'CREATE';
                  l_payment_tbl(1).quote_header_id := l_qte_line_rec.quote_header_id ;
                  l_payment_tbl(1).payment_term_id := l_payment_term_id;
                  l_payment_tbl(1).qte_line_index := 1;
                 ELSIF (l_payment_tbl.count= 1  and l_payment_tbl(1).payment_term_id = FND_API.G_MISS_NUM
                         and l_payment_tbl(1).operation_code = 'CREATE') THEN
                   l_payment_tbl(1).payment_term_id := l_payment_term_id;
                 End if;
              end if;

           end if;  -- check for installment option

		  -- end of pnpl changes


             -- default uom code

            IF l_qte_line_rec.uom_code IS NULL OR l_qte_line_rec.uom_code = FND_API.G_MISS_CHAR THEN
                l_qte_line_rec.uom_code := l_uom_code;
            END IF;

            -- Default the ship model complete flag and config model type
	       IF nvl(l_qte_line_rec.item_type_code,'XXX')  <> 'CFG' THEN
	           l_qte_line_rec.ship_model_complete_flag := nvl(l_ship_model_complete_flag,'N');
                l_qte_line_rec.config_model_type := l_config_model_type;
            END IF;

            --Default Service Item Flag and Serviceable Product Flag
            if aso_debug_pub.g_debug_flag = 'Y' THEN
		      aso_debug_pub.add('Populate_Quote_lines CREATE- l_service_item_flag is '||l_service_item_flag, 1, 'N');
		      aso_debug_pub.add('Populate_Quote_lines CREATE- l_serviceable_product_flag is '||l_serviceable_product_flag, 1, 'N');
	       end if;

            l_qte_line_rec.service_item_flag := nvl(l_service_item_flag,'N');
		  l_qte_line_rec.serviceable_product_flag := nvl(l_serviceable_product_flag,'N');

		  -- find end date for service

            IF nvl(l_service_item_flag,'N') = 'Y' THEN
             -- commented as part of 17412190:R12.ASO.B
                /*
				IF P_Qte_Line_Rec.start_date_active is NULL OR P_Qte_Line_Rec.start_date_active = FND_API.G_MISS_DATE THEN

                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		                FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
		                FND_MESSAGE.Set_Token('COLUMN', 'START_DATE_ACTIVE', FALSE);
		                FND_MSG_PUB.ADD;
	               END IF;
			     RAISE FND_API.G_EXC_ERROR;

                END IF; */

                -- if account id is not null use account id otherwise use party id

                Open C_customer;
                Fetch C_customer into l_acct, l_party;

                IF C_customer%NOTFOUND THEN

                     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		                 FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
		                 FND_MESSAGE.Set_Token('COLUMN', 'CUSTOMER_INFO', FALSE);
		                 FND_MSG_PUB.ADD;
	                END IF;
                END IF;

                Close C_customer;

                IF l_acct is NOT  NULL THEN
                    l_customer_id := l_acct;
                ELSE
                    l_customer_id := l_party;
                END IF;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Populate_Quote_lines:Create :before get service attr ', 1, 'N');
                end if;

                ASO_SERVICE_CONTRACTS_INT.Get_service_attributes(
	               P_Api_Version_Number  => 1,
                    P_init_msg_list	  => FND_API.G_FALSE,
                    P_Qte_Line_Rec        => P_Qte_Line_Rec,
                    P_Qte_Line_Dtl_tbl    => P_Qte_Line_Dtl_tbl,
                    X_msg_Count           => X_msg_Count,
                    X_msg_Data		  => X_msg_Data,
                    X_Return_Status	  => X_Return_Status);

	           IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Populate_Quote_lines:Create :after  get service attr '||X_Return_Status, 1, 'N');
	           end if;

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

                -- New code begins 04/26/2002

	           if aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Populate_quote_lines: l_qte_line_dtl_tbl.count: '|| l_qte_line_dtl_tbl.count,1,'N');
                   aso_debug_pub.add('Populate_quote_lines: p_qte_line_dtl_tbl.count: '|| p_qte_line_dtl_tbl.count,1,'N');
                end if;

                l_call_get_duration := FND_API.G_FALSE;
          IF (l_qte_line_rec.start_date_active is null or l_qte_line_rec.start_date_active =  fnd_api.g_miss_date)  AND  l_qte_line_dtl_tbl(1).Service_Duration is not null and l_qte_line_dtl_tbl(1).Service_Period is not null THEN --added by vidya
          aso_debug_pub.add('inside new api l_qte_line_dtl_tbl(1).Service_Duration' || l_qte_line_dtl_tbl(1).Service_Duration);
          aso_debug_pub.add('inside new api l_qte_line_dtl_tbl_out(1).service_period' || l_qte_line_dtl_tbl(1).service_period);
          aso_debug_pub.add('inside new api l_qte_line_rec.start_date_active' || l_qte_line_rec.start_date_active);

--Data Card ER 13630721
                  oks_omint_pub.VALIDATE_DURATION(  P_Api_Version   => 1.0,
                  P_init_msg_list => OKC_API.G_FALSE,
                  X_msg_Count     =>x_msg_count,
                  X_msg_Data      => x_msg_data,
                  X_Return_Status => x_return_status,
                  P_Service_Duration    => l_qte_line_dtl_tbl(1).Service_Duration,
                  P_service_period      => l_qte_line_dtl_tbl(1).service_period ,
                  X_service_duration    => l_qte_line_dtl_tbl_out(1).Service_Duration,
                  X_service_period      => l_qte_line_dtl_tbl_out(1).service_period
              );
 l_qte_line_dtl_tbl(1).Service_Duration := l_qte_line_dtl_tbl_out(1).Service_Duration;
					   l_qte_line_dtl_tbl(1).service_period   := l_qte_line_dtl_tbl_out(1).service_period;
aso_debug_pub.add('inside after  new apil_qte_line_dtl_tbl_out(1).Service_Duration' || l_qte_line_dtl_tbl_out(1).Service_Duration);
aso_debug_pub.add('inside after new api l_qte_line_dtl_tbl_out(1).service_period' || l_qte_line_dtl_tbl_out(1).service_period);
	           ELSIF l_qte_line_rec.end_date_active is NOT NULL AND l_qte_line_rec.end_date_active = FND_API.G_MISS_DATE THEN

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('Populate_quote_lines: First IF cond G_MISS_DATE', 1, 'N');
                     end if;

                     IF l_qte_line_dtl_tbl.count > 0 THEN
                      aso_debug_pub.add('_qte_line_dtl_tbl.count' ||l_qte_line_dtl_tbl.count ,1, 'N');
			           l_qte_line_rec.end_date_active := null;
			           l_call_get_duration := FND_API.G_TRUE;
                  aso_debug_pub.add('l_qte_line_rec.end_date_active' || l_qte_line_rec.end_date_active, 1, 'N');
                   aso_debug_pub.add('l_call_get_duration  ' || l_call_get_duration , 1, 'N');
                     ELSE
				      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                              FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SRV_INFO5');
               		     FND_MSG_PUB.Add;
        		           END IF;
			           RAISE FND_API.G_EXC_ERROR;
                     END IF;

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('Populate_quote_lines: l_qte_line_rec.end_date_active: '|| l_qte_line_rec.end_date_active,1,'N');
                     end if;

                     IF l_qte_line_dtl_tbl(1).Service_Duration is NOT NULL AND l_qte_line_dtl_tbl(1).Service_Duration = FND_API.G_MISS_NUM  THEN
                          l_qte_line_dtl_tbl(1).Service_Duration := null;
                     END IF;

                     if aso_debug_pub.g_debug_flag = 'Y' THEN
                          aso_debug_pub.add('Populate_quote_lines: l_qte_line_dtl_tbl(1).Service_Duration: '|| l_qte_line_dtl_tbl(1).Service_Duration,1,'N');
                     end if;

                     IF l_qte_line_dtl_tbl(1).Service_period is NOT NULL AND l_qte_line_dtl_tbl(1).Service_period = FND_API.G_MISS_CHAR THEN
                         l_qte_line_dtl_tbl(1).Service_period := null;
                     END IF;

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('Populate_quote_lines: l_qte_line_dtl_tbl(1).Service_period: '|| l_qte_line_dtl_tbl(1).Service_period,1,'N');
                     end if;

                     IF l_qte_line_dtl_tbl(1).service_coterminate_flag is NOT NULL AND l_qte_line_dtl_tbl(1).service_coterminate_flag <> FND_API.G_MISS_CHAR THEN
                         l_qte_line_dtl_tbl(1).service_coterminate_flag := null;
                     END IF;

                     if aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('Populate_quote_lines: l_qte_line_dtl_tbl(1).service_coterminate_flag: '|| l_qte_line_dtl_tbl(1).service_coterminate_flag,1,'N');
                     end if;

                ELSIF l_qte_line_rec.end_date_active IS NOT NULL AND l_qte_line_dtl_tbl.count = 0 THEN

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('Populate_quote_lines: ELSIF Cond not G_MISS_DATE but not null', 1, 'N');
                     end if;

                     ASO_Service_Contracts_INT.Get_Duration(
                            P_Api_Version_Number => 1.0,
                            X_msg_Count          => x_msg_count  ,
                            X_msg_Data           => x_msg_data   ,
                            X_Return_Status      => x_return_status,
                            P_customer_id        => l_customer_id,
                            P_system_id          => null,
                            P_Service_Duration   => null,
                            P_service_period     => null ,
                            P_coterm_checked_yn  => null,
                            P_start_date         => l_qte_line_rec.start_date_active,
                            P_end_date           => l_qte_line_rec.end_date_active,
                            X_service_duration   => l_qte_line_dtl_tbl_out(1).Service_Duration,
                            X_service_period     => l_qte_line_dtl_tbl_out(1).service_period,
                            X_new_end_date       => l_qte_line_rec_out.end_date_active );

					   l_qte_line_dtl_tbl(1).Service_Duration := l_qte_line_dtl_tbl_out(1).Service_Duration;
					   l_qte_line_dtl_tbl(1).service_period   := l_qte_line_dtl_tbl_out(1).service_period;
					   l_qte_line_rec.end_date_active         := l_qte_line_rec_out.end_date_active;

	                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('Populate_Quote_lines: After call to ASO Get_Duration x_return_status: '||X_Return_Status, 1, 'N');
                         aso_debug_pub.add('After call to ASO Get_Duration: l_qte_line_rec.end_date_active: '||l_qte_line_rec.end_date_active, 1, 'N');
                         aso_debug_pub.add('After call to ASO Get_Duration: l_qte_line_dtl_tbl(1).service_period: '||l_qte_line_dtl_tbl(1).service_period, 1, 'N');
                         aso_debug_pub.add('After call to ASO Get_Duration: l_qte_line_dtl_tbl(1).Service_Duration: '||l_qte_line_dtl_tbl(1).Service_Duration, 1, 'N');
	                end if;

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

                ELSIF l_qte_line_rec.end_date_active IS NULL AND l_qte_line_dtl_tbl.count = 0 THEN

	                if aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('Populate_quote_lines: ELSEIF Cond end date IS NULL and l_qte_line_dtl_tbl.count = 0', 1, 'N');
                     end if;

                     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                         FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SRV_INFO5');
                         FND_MSG_PUB.Add;
        		      END IF;

	                RAISE FND_API.G_EXC_ERROR;

                ELSE

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('Populate_quote_lines: ELSE Cond not end date NULL', 1, 'N');
                     end if;

	                l_call_get_duration := FND_API.G_TRUE;

                     IF l_qte_line_dtl_tbl(1).Service_Duration is NOT NULL
                           AND l_qte_line_dtl_tbl(1).Service_Duration = FND_API.G_MISS_NUM  THEN

                         l_qte_line_dtl_tbl(1).Service_Duration := null;
                     END IF;

                     IF l_qte_line_dtl_tbl(1).Service_period is NOT NULL
                              AND l_qte_line_dtl_tbl(1).Service_period = FND_API.G_MISS_CHAR  THEN

                         l_qte_line_dtl_tbl(1).Service_period := null;
                     END IF;

                     IF l_qte_line_dtl_tbl(1).service_coterminate_flag is NOT NULL
                            AND l_qte_line_dtl_tbl(1).service_coterminate_flag <> FND_API.G_MISS_CHAR THEN

                        l_qte_line_dtl_tbl(1).service_coterminate_flag := null;
                     END IF;

                END IF;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('Populate_quote_lines: Before call to Get_Duration: l_call_get_duration: '||l_call_get_duration,1,'N');
                end if;

                IF l_call_get_duration = FND_API.G_TRUE THEN

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Populate_quote_lines: Inside IF l_call_get_duration = FND_API.G_TRUE Cond ', 1, 'N');
                    end if;

aso_debug_pub.add('vefore call ASO_Service_Contracts_INT.Get_Duration');
                    ASO_Service_Contracts_INT.Get_Duration(
                        P_Api_Version_Number  => 1.0,
                        X_msg_Count           => x_msg_count  ,
                        X_msg_Data            => x_msg_data   ,
                        X_Return_Status       => x_return_status,
                        P_customer_id         => l_customer_id,
                        P_system_id           => null,
                        P_Service_Duration    => l_qte_line_dtl_tbl(1).Service_Duration,
                        P_service_period      => l_qte_line_dtl_tbl(1).service_period ,
                        P_coterm_checked_yn   => l_qte_line_dtl_tbl(1).service_coterminate_flag,
                        P_start_date          => l_qte_line_rec.start_date_active,
                        P_end_date            => l_qte_line_rec.end_date_active,
                        X_service_duration    => l_qte_line_dtl_tbl_out(1).Service_Duration,
                        X_service_period      => l_qte_line_dtl_tbl_out(1).service_period,
                        X_new_end_date        => l_qte_line_rec_out.end_date_active );

                       l_qte_line_dtl_tbl(1).Service_Duration := l_qte_line_dtl_tbl_out(1).Service_Duration;
			        l_qte_line_dtl_tbl(1).service_period := l_qte_line_dtl_tbl_out(1).service_period;
				   l_qte_line_rec.end_date_active := l_qte_line_rec_out.end_date_active;

                       if aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('Populate_Quote_lines: After call to ASO Get_Duration x_return_status: '||X_Return_Status, 1, 'N');
                           aso_debug_pub.add('After call to ASO Get_Duration: l_qte_line_rec.end_date_active: '||l_qte_line_rec.end_date_active, 1, 'N');
                           aso_debug_pub.add('After call to ASO Get_Duration: l_qte_line_dtl_tbl(1).service_period: '||l_qte_line_dtl_tbl(1).service_period, 1, 'N');
                           aso_debug_pub.add('After call to ASO Get_Duration: l_qte_line_dtl_tbl(1).Service_Duration: '||l_qte_line_dtl_tbl(1).Service_Duration, 1, 'N');
                       end if;

                      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE FND_API.G_EXC_ERROR;
                      END IF;

                END IF; --l_call_get_duration = FND_API.G_TRUE

            END IF; -- Service_item_flag

            --populate the config_item_id and bom_sort_order column values from cz_config_details_v
            --view if the calling application is passing config_header_id, config_revision_num and
            --component_code values. Fix for Bug#2980130

            if aso_debug_pub.g_debug_flag = 'Y' then
               aso_debug_pub.add('Before populating config_item_id,bom_sort_order. Operation_code = CREATE');
               aso_debug_pub.add('l_qte_line_dtl_tbl.count: ' || l_qte_line_dtl_tbl.count);
            end if;

            for i in 1 .. l_qte_line_dtl_tbl.count loop

                 if aso_debug_pub.g_debug_flag = 'Y' then
                     aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').config_header_id:    '||l_qte_line_dtl_tbl(i).config_header_id);
                     aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').config_revision_num: '||l_qte_line_dtl_tbl(i).config_revision_num);
                     aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').component_code:      '||l_qte_line_dtl_tbl(i).component_code);
                     aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').config_item_id:      '||l_qte_line_dtl_tbl(i).config_item_id);
                     aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').bom_sort_order:      '||l_qte_line_dtl_tbl(i).bom_sort_order);
                 end if;

                 if ( l_qte_line_dtl_tbl(i).config_header_id is not null and
                      l_qte_line_dtl_tbl(i).config_header_id <> fnd_api.g_miss_num ) and
                    ( l_qte_line_dtl_tbl(i).config_revision_num is not null and
                      l_qte_line_dtl_tbl(i).config_revision_num <> fnd_api.g_miss_num ) and
                      l_qte_line_dtl_tbl(i).operation_code = 'CREATE' then

                      if ( l_qte_line_dtl_tbl(i).config_item_id is null or l_qte_line_dtl_tbl(i).config_item_id = fnd_api.g_miss_num ) then

                           open c_config_item_id( l_qte_line_dtl_tbl(i).config_header_id,
                                                  l_qte_line_dtl_tbl(i).config_revision_num,
                                                  l_qte_line_dtl_tbl(i).component_code );

                           fetch c_config_item_id into l_qte_line_dtl_tbl(i).config_item_id, l_qte_line_dtl_tbl(i).bom_sort_order;

                           if aso_debug_pub.g_debug_flag = 'Y' then
                               aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').config_item_id: '||l_qte_line_dtl_tbl(i).config_item_id);
                               aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').bom_sort_order: '||l_qte_line_dtl_tbl(i).bom_sort_order);
                           end if;

                           if c_config_item_id%notfound then

                                if aso_debug_pub.g_debug_flag = 'Y' then
                                    aso_debug_pub.add('Inside c_config_item_id%notfound cond.');
                                end if;

                                close c_config_item_id;
                                raise fnd_api.g_exc_error;
                           end if;

                           close c_config_item_id;

                      elsif ( l_qte_line_dtl_tbl(i).bom_sort_order is null or l_qte_line_dtl_tbl(i).bom_sort_order = fnd_api.g_miss_char ) then

                           open c_bom_sort_order( l_qte_line_dtl_tbl(i).config_header_id,
                                                  l_qte_line_dtl_tbl(i).config_revision_num,
                                                  l_qte_line_dtl_tbl(i).config_item_id );

                           fetch c_bom_sort_order into l_qte_line_dtl_tbl(i).bom_sort_order;

                           if aso_debug_pub.g_debug_flag = 'Y' then
                               aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').bom_sort_order: '||l_qte_line_dtl_tbl(i).bom_sort_order);
                           end if;

                           if c_bom_sort_order%notfound then

                                if aso_debug_pub.g_debug_flag = 'Y' then
                                   aso_debug_pub.add('Inside c_bom_sort_order%notfound cond.');
                                end if;

                                close c_bom_sort_order;
                                raise fnd_api.g_exc_error;

                           end if;
                           close c_bom_sort_order;

                      end if; --l_qte_line_dtl_tbl(i).config_item_id is null or l_qte_line_dtl_tbl(i).config_item_id = fnd_api.g_miss_num

                 end if; --l_qte_line_dtl_tbl(i).config_header_id is not null and

            end loop;

            --end of fix for Bug#2980130

            X_Qte_Line_Dtl_tbl  := l_qte_line_dtl_tbl;


            --Set the line_number of service items to the line_number of serviceable item, if the
            --service is attached to a quote line

            IF  nvl(l_service_item_flag,'N') = 'Y' AND l_qte_line_dtl_tbl.count > 0 THEN

                 IF  l_qte_line_dtl_tbl(1).service_ref_line_id IS NOT NULL
                     AND l_qte_line_dtl_tbl(1).service_ref_type_code = 'QUOTE' THEN

                       OPEN  c_line_number(l_qte_line_dtl_tbl(1).service_ref_line_id);
                       FETCH c_line_number INTO l_serviceable_line_number;

                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('Populate_quote_lines: l_serviceable_line_number: '|| l_serviceable_line_number);
                       end if;

                       IF c_line_number%FOUND AND l_serviceable_line_number IS NOT NULL THEN
                             l_qte_line_rec.line_number := l_serviceable_line_number;
                       ELSE

                             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                                 aso_debug_pub.add('Line Number does not exist for the serviceable item of the service');
                             end if;
                       END IF;

                       CLOSE c_line_number;

                 END IF;

            END IF; --nvl(l_service_item_flag,'N') = 'Y' AND l_qte_line_dtl_tbl.count > 0

            --End of service line_number code

	       --Populate configured lines line number

            IF  l_qte_line_rec.item_type_code = 'CFG' AND l_qte_line_dtl_tbl.count > 0 THEN

                 IF  l_qte_line_dtl_tbl(1).ref_line_id IS NOT NULL AND l_qte_line_dtl_tbl(1).ref_type_code = 'CONFIG' THEN

                       open  c_line_number(l_qte_line_dtl_tbl(1).ref_line_id);
                       fetch c_line_number into l_qte_line_rec.line_number;

                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('Populate_quote_lines: parent line_number: '|| l_qte_line_rec.line_number);
                       end if;

                       IF c_line_number%notfound  THEN

                           IF aso_debug_pub.g_debug_flag = 'Y' THEN
                               aso_debug_pub.add('parent line number does not exist for this child line');
                           end if;

                       ELSIF l_qte_line_rec.line_number is null THEN

                           IF aso_debug_pub.g_debug_flag = 'Y' THEN
                               aso_debug_pub.add('parent line_number of this child line is null');
                           end if;

                       END IF;

                       close c_line_number;
                 END IF;

            END IF; --IF  l_qte_line_rec.item_type_code = 'CFG' AND l_qte_line_dtl_tbl.count > 0 THEN

        End if; --If C_Item1%NOTFOUND Then

        Close C_Item1;

	if aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Populate_Quote_lines - l_qte_line_rec.item_type_code : '||l_qte_line_rec.item_type_code);
	end if;

        IF (l_qte_line_rec.line_number IS NULL OR l_qte_line_rec.line_number = FND_API.G_MISS_NUM) THEN

            SELECT max(line_number) into l_line_number
            FROM aso_quote_lines_all
            WHERE quote_header_id = l_qte_line_rec.quote_header_id;

            -- IF (SQL%NOTFOUND) OR l_line_number is NULL THEN
	    IF l_line_number is NULL THEN  -- Bug 19952104
               l_line_number := 0;
            END IF;

            --l_qte_line_rec.line_number := l_line_number + 10000;

	    -- Start : Code change done for Bug 19952104
	    If l_qte_line_rec.item_type_code = 'CFG' then
               l_qte_line_rec.line_number := l_line_number;
	    Else
 	       l_qte_line_rec.line_number := l_line_number + 10000;
	    End If;
	    -- End : Code change done for Bug 19952104

        END IF;

	   if aso_debug_pub.g_debug_flag = 'Y' THEN
    		  aso_debug_pub.add('Populate_Quote_lines - line_number: '||l_qte_line_rec.line_number, 1, 'N');
	   end if;

        -- there should be atleast one shipment record for every quote line record

        IF l_shipment_tbl.count < 1 THEN

            l_shipment_tbl(1).quote_header_id := l_qte_line_rec.quote_header_id;
            l_shipment_tbl(1).quote_line_id   := l_qte_line_rec.quote_line_id;
	       l_shipment_tbl(1).quantity        := l_qte_line_rec.quantity;

        END IF;


     END IF;  --IF p_operation_code = 'CREATE'



	IF p_operation_code = 'UPDATE' THEN

         l_qte_line_rec.service_item_flag        := fnd_api.g_miss_char;
         l_qte_line_rec.serviceable_product_flag := fnd_api.g_miss_char;
         l_qte_line_rec.config_model_type        := fnd_api.g_miss_char;


	    --Made changes in cursor to select inventory_item_id for Bug#2930734

         OPEN  C_header;
         FETCH C_header into l_qte_line_rec.quote_header_id, l_organization_id, l_inventory_item_id;

         IF (C_header%NOTFOUND) THEN

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

		      FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                FND_MESSAGE.Set_Token('COLUMN', 'QUOTE_ID', FALSE);
	           FND_MESSAGE.Set_Token('VALUE', TO_CHAR(l_qte_line_rec.quote_header_id), FALSE);
	           FND_MSG_PUB.ADD;
	       END IF;

         END IF;
         CLOSE C_header;

         --Made the following changes for Bug#2930734

         IF l_qte_line_rec.organization_id IS NULL OR l_qte_line_rec.organization_id = FND_API.G_MISS_NUM THEN
		      l_qte_line_rec.organization_id := l_organization_id;
	    END IF;

         if l_qte_line_rec.inventory_item_id = fnd_api.g_miss_num then
		   l_qte_line_rec.inventory_item_id := l_inventory_item_id;
	    end if;

	    if aso_debug_pub.g_debug_flag = 'Y' then
             aso_debug_pub.add('populate_quote_line: operation_code: UPDATE');
             aso_debug_pub.add('l_qte_line_rec.organization_id:   '||l_qte_line_rec.organization_id);
             aso_debug_pub.add('l_qte_line_rec.inventory_item_id: '||l_qte_line_rec.inventory_item_id);
         end if;

	    --End of change for Bug#2930734

         open c_shipment;
	    fetch c_shipment into l_shipment_rec_count, l_total_shipment_quantity;

         IF (C_Shipment%NOTFOUND) THEN

            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		      FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SHIPMENT');
                FND_MESSAGE.Set_Token('LINE', to_char(p_qte_line_rec.quote_line_id), FALSE);
            END IF;

         END IF;

	    CLOSE C_Shipment;


         -- Added by bmishra on 05/15/2001

          IF  l_qte_line_rec.quantity is null then

               l_qte_line_rec.quantity :=  nvl(fnd_profile.value(name => 'ASO_DEFAULT_QTY'),1);

          ELSIF  l_qte_line_rec.quantity = FND_API.G_MISS_NUM THEN

               select quantity  into l_qte_line_rec.quantity from aso_quote_lines_All
               where quote_line_id = l_qte_line_rec.quote_line_id;

          END IF;


	     IF l_shipment_tbl.count > 1 THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_SHIPMENTS');
                    FND_MSG_PUB.ADD;
               END IF;
               raise FND_API.G_EXC_ERROR;

          ELSIF l_shipment_tbl.count > 0  THEN

               IF l_qte_line_rec.quantity <> l_shipment_tbl(1).quantity THEN
	            l_shipment_tbl(1).quantity := l_qte_line_rec.quantity;
               END IF;

          ELSIF l_shipment_tbl.count = 0 AND l_shipment_rec_count = 1 THEN

               -- update the existing rec

               SELECT shipment_id into l_shipment_tbl(1).shipment_id
               FROM aso_shipments
               WHERE quote_line_id = l_qte_line_rec.quote_line_id
               AND quote_header_id = l_qte_line_rec.quote_header_id;

               l_shipment_tbl(1).quote_header_id := l_qte_line_rec.quote_header_id;
               l_shipment_tbl(1).quote_line_id   := l_qte_line_rec.quote_line_id;
               l_shipment_tbl(1).quantity        := l_qte_line_rec.quantity;
               l_shipment_tbl(1).operation_code  := 'UPDATE';

          END IF;

          -- If the operation code is 'CREATE' in shipment table then raise an error

          IF l_shipment_rec_count > 0  THEN

               FOR i IN 1..l_shipment_tbl.count LOOP

                   IF l_shipment_tbl(i).operation_code = 'CREATE' THEN
                       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                           FND_MESSAGE.Set_Name('ASO', 'ASO_API_TOO_MANY_SHIPMENT');
                           FND_MSG_PUB.ADD;
                       END IF;
                       raise FND_API.G_EXC_ERROR;
                   END IF;

               END LOOP;

          END IF;


          open c_item1(l_qte_line_rec.inventory_item_id, l_qte_line_rec.organization_id);
          fetch c_item1 into l_uom_code, l_service_item_flag, l_serviceable_product_flag, l_ship_model_complete_flag, l_payment_term_id, l_config_model_type;

          if (c_item1%notfound) then

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Populate_Quote_lines: c_item1%NOTFOUND true, raising error', 1, 'N');
               END IF;

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_INFO');
                   FND_MESSAGE.Set_Token ('INFO', 'ITEM RELATED', FALSE);
                   FND_MSG_PUB.Add;
               END IF;

               close c_item1;
               raise FND_API.G_EXC_ERROR;

           end if;

           close c_item1;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Populate_Quote_lines: l_uom_code:                 '|| l_uom_code, 1, 'N');
               aso_debug_pub.add('Populate_Quote_lines: l_service_item_flag:        '|| l_service_item_flag, 1, 'N');
               aso_debug_pub.add('Populate_Quote_lines: l_serviceable_product_flag: '|| l_serviceable_product_flag, 1, 'N');
               aso_debug_pub.add('Populate_Quote_lines: l_ship_model_complete_flag: '|| l_ship_model_complete_flag, 1, 'N');
               aso_debug_pub.add('Populate_Quote_lines: l_payment_term_id:          '|| l_payment_term_id, 1, 'N');
               aso_debug_pub.add('Populate_Quote_lines: l_config_model_type:        '|| l_config_model_type, 1, 'N');
           END IF;


           IF nvl(l_service_item_flag,'N') = 'Y'  THEN

               --if start_date_active is null then raise error
-- commented as part of 17412190:R12.ASO.B
             /*  if p_qte_line_rec.start_date_active is NULL then

                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
                       FND_MESSAGE.Set_Token('COLUMN', 'START_DATE_ACTIVE', FALSE);
                       FND_MSG_PUB.ADD;
                   END IF;

                   RAISE FND_API.G_EXC_ERROR;

               end if;*/

               --Check if any of the service attributes has changed

               l_call_get_duration := FND_API.G_FALSE;
aso_debug_pub.add('1212121%%%%%%%%% p_Qte_Line_Rec.start_date_active ' ||  p_Qte_Line_Rec.start_date_active);

l_Qte_Line_Dtl_tbl_old := aso_utility_pvt.Query_Line_Dtl_Rows(l_qte_line_rec.quote_line_id);
--l_Qte_Line_Dtl_tbl := aso_utility_pvt.Query_Line_Dtl_Rows(l_qte_line_rec.quote_line_id);
if l_qte_line_dtl_tbl.count > 0 THEN
if  (l_qte_line_dtl_tbl(1).Service_Duration is null) or  (l_qte_line_dtl_tbl(1).Service_Duration = fnd_api.g_miss_NUM ) then

l_qte_line_dtl_tbl(1).Service_Duration := l_Qte_Line_Dtl_tbl_old(1).Service_Duration;


end if;
if  (l_qte_line_dtl_tbl(1).Service_Period is null) or  (l_qte_line_dtl_tbl(1).Service_Period = FND_API.G_MISS_CHAR) then
begin
l_qte_line_dtl_tbl(1).Service_Period := l_Qte_Line_Dtl_tbl_old(1).Service_Period;
aso_debug_pub.add('Service_Period not changing ');
aso_debug_pub.add('l_qte_line_dtl_tbl(1).Service_Period' || l_qte_line_dtl_tbl(1).Service_Period);

end;
end if;
else
l_qte_line_dtl_tbl(1).Service_Duration := l_Qte_Line_Dtl_tbl_old(1).Service_Duration;
l_qte_line_dtl_tbl(1).Service_Period := l_Qte_Line_Dtl_tbl_old(1).Service_Period;

END IF;
 IF (l_qte_line_rec.start_date_active is null or l_qte_line_rec.start_date_active =  fnd_api.g_miss_date)  AND  l_qte_line_dtl_tbl(1).Service_Duration is not null and l_qte_line_dtl_tbl(1).Service_Period is not null THEN --added by vidya
 l_qte_line_rec.end_date_active := null;
          aso_debug_pub.add('inside update  new api l_qte_line_dtl_tbl(1).Service_Duration' || l_qte_line_dtl_tbl(1).Service_Duration);
          aso_debug_pub.add('inside update new api l_qte_line_dtl_tbl_out(1).service_period' || l_qte_line_dtl_tbl(1).service_period);
aso_debug_pub.add('inside update  new api l_qte_line_dtl_tbl(1).Service_Duration' || l_qte_line_dtl_tbl(1).Service_Duration);
 aso_debug_pub.add('inside update new api l_qte_line_dtl_tbl_out(1).service_period' || l_qte_line_dtl_tbl(1).service_period);

                  oks_omint_pub.VALIDATE_DURATION(  P_Api_Version   => 1.0,
                  P_init_msg_list => OKC_API.G_FALSE,
                  X_msg_Count     =>x_msg_count,
                  X_msg_Data      => x_msg_data,
                  X_Return_Status => x_return_status,
                  P_Service_Duration    => l_qte_line_dtl_tbl(1).Service_Duration,
                  P_service_period      => l_qte_line_dtl_tbl(1).service_period ,
                  X_service_duration    => l_qte_line_dtl_tbl_out(1).Service_Duration,
                  X_service_period      => l_qte_line_dtl_tbl_out(1).service_period
              );
 l_qte_line_dtl_tbl(1).Service_Duration := l_qte_line_dtl_tbl_out(1).Service_Duration;
					   l_qte_line_dtl_tbl(1).service_period   := l_qte_line_dtl_tbl_out(1).service_period;
aso_debug_pub.add('inside update  after  new apil_qte_line_dtl_tbl_out(1).Service_Duration' || l_qte_line_dtl_tbl_out(1).Service_Duration);
aso_debug_pub.add('inside update  after new api l_qte_line_dtl_tbl_out(1).service_period' || l_qte_line_dtl_tbl_out(1).service_period);



 aso_debug_pub.add('l_qte_line_dtl_tbl(1).Service_Duration ' || l_qte_line_dtl_tbl(1).Service_Duration);
 aso_debug_pub.add('l_qte_line_dtl_tbl(1).Service_PERIOD ' || l_qte_line_dtl_tbl(1).Service_PERIOD);

	           ELSIF   (p_qte_line_rec.start_date_active IS NOT NULL and p_qte_line_rec.start_date_active <> FND_API.G_MISS_DATE)
               OR (p_qte_line_rec.end_date_active IS NOT NULL AND p_qte_line_rec.end_date_active <> FND_API.G_MISS_DATE) then
aso_debug_pub.add('inside update  1111');

                    l_call_get_duration := FND_API.G_TRUE;

               elsif p_qte_line_dtl_tbl.count > 0 then

                    if (p_qte_line_dtl_tbl(1).service_duration <> FND_API.G_MISS_NUM) OR (p_qte_line_dtl_tbl(1).service_period <> FND_API.G_MISS_CHAR) then

                         l_call_get_duration := FND_API.G_TRUE;

                    end if;

               end if;

               if l_call_get_duration = FND_API.G_TRUE then

                   OPEN C_service_item;
                   FETCH C_service_item INTO l_start_date, l_end_date, l_service_duration, l_service_period, l_coterminate_flag, l_customer_id, l_party;

                   IF (C_service_item%NOTFOUND) THEN

                        CLOSE C_service_item;

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('Populate_Quote_lines: C_service_item%NOTFOUND true, raising error', 1, 'N');
                        END IF;

                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		                  FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_INFO');
		                  FND_MESSAGE.Set_Token('INFO', 'SERVICE RELATED', FALSE);
		                  FND_MSG_PUB.ADD;
	                   END IF;

	                   RAISE FND_API.G_EXC_ERROR;

                   END IF;

                   CLOSE C_service_item;

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Populate_Quote_lines: l_start_date:       '|| l_start_date, 1, 'N');
                        aso_debug_pub.add('Populate_Quote_lines: l_end_date:         '|| l_end_date, 1, 'N');
                        aso_debug_pub.add('Populate_Quote_lines: l_service_duration: '|| l_service_duration, 1, 'N');
                        aso_debug_pub.add('Populate_Quote_lines: l_service_period:   '|| l_service_period, 1, 'N');
                        aso_debug_pub.add('Populate_Quote_lines: l_coterminate_flag: '|| l_coterminate_flag, 1, 'N');
                        aso_debug_pub.add('Populate_Quote_lines: l_customer_id:      '|| l_customer_id, 1, 'N');
                        aso_debug_pub.add('Populate_Quote_lines: l_party:            '|| l_party, 1, 'N');
                        aso_debug_pub.add('Populate_Quote_lines:Update :before call to ASO_SERVICE_CONTRACTS_INT.Get_service_attributes', 1, 'N');
                   END IF;

                   ASO_SERVICE_CONTRACTS_INT.Get_service_attributes( P_Api_Version_Number => 1,
                                                                     P_init_msg_list	 => FND_API.G_FALSE,
	                                                             P_Qte_Line_Rec       => P_Qte_Line_Rec,
                                                                     P_Qte_Line_Dtl_tbl   => P_Qte_Line_Dtl_tbl,
                                                                     X_msg_Count          => X_msg_Count,
                                                                     X_msg_Data		 => X_msg_Data,
                                                                     X_Return_Status	 => X_Return_Status );

	           IF aso_debug_pub.g_debug_flag = 'Y' THEN
   	               aso_debug_pub.add('Populate_Quote_lines:after call to Get_service_attributes: X_Return_Status: '|| X_Return_Status, 1, 'N');
	           end if;

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;

                    --print the input parameter values

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN

                        aso_debug_pub.add('Populate_Quote_lines: p_qte_line_rec.start_date_active: '|| p_qte_line_rec.start_date_active, 1, 'N');
                        aso_debug_pub.add('Populate_Quote_lines: p_qte_line_rec.end_date_active:   '|| p_qte_line_rec.end_date_active, 1, 'N');
                        aso_debug_pub.add('Populate_Quote_lines: p_qte_line_dtl_tbl.count: '|| p_qte_line_dtl_tbl.count, 1, 'N');
                        IF p_qte_line_dtl_tbl.count > 0 THEN

                           aso_debug_pub.add('p_qte_line_dtl_tbl(1).Service_Duration:         '|| p_qte_line_dtl_tbl(1).Service_Duration, 1, 'N');
                           aso_debug_pub.add('p_qte_line_dtl_tbl(1).service_period:           '|| p_qte_line_dtl_tbl(1).service_period, 1, 'N');
                           aso_debug_pub.add('p_qte_line_dtl_tbl(1).service_coterminate_flag: '|| p_qte_line_dtl_tbl(1).service_coterminate_flag, 1, 'N');

                        end if;
                    END IF;

                    --Now check which service attribute value has changed

                    if aso_debug_pub.g_debug_flag = 'Y' then
                        aso_debug_pub.add('Populate_quote_lines: p_qte_line_dtl_tbl.count: '|| p_qte_line_dtl_tbl.count, 1, 'N');
                    end if;

                    if p_qte_line_dtl_tbl.count = 0 then

                        l_qte_line_dtl_tbl := aso_utility_pvt.Query_Line_Dtl_Rows(l_qte_line_rec.quote_line_id);

                        if aso_debug_pub.g_debug_flag = 'Y' then
                            aso_debug_pub.add('After querying line detail tbl from db: l_qte_line_dtl_tbl.count: '|| l_qte_line_dtl_tbl.count, 1, 'N');
                        end if;

                        if l_qte_line_dtl_tbl.count = 0 then

                            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                 FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SRV_INFO5');
                                 FND_MSG_PUB.Add;
                            END IF;

                            RAISE FND_API.G_EXC_ERROR;

                        else

                            l_qte_line_dtl_tbl(1).operation_code := 'UPDATE';

                        end if;

                    end if;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Populate_quote_lines: l_qte_line_rec.start_date_active: '|| l_qte_line_rec.start_date_active,1,'N');
                        aso_debug_pub.add('Populate_quote_lines: l_qte_line_rec.end_date_active:   '|| l_qte_line_rec.end_date_active,1,'N');
                    end if;

                    IF p_qte_line_rec.start_date_active = FND_API.G_MISS_DATE THEN
                        l_qte_line_rec.start_date_active := l_start_date;
                    END IF;

                    IF p_qte_line_rec.end_date_active = FND_API.G_MISS_DATE THEN
                        l_qte_line_rec.end_date_active := null;
                    END IF;

                    if aso_debug_pub.g_debug_flag = 'Y' then
                        aso_debug_pub.add('Populate_quote_lines: p_qte_line_dtl_tbl.count: '|| p_qte_line_dtl_tbl.count, 1, 'N');
                    end if;

                    if p_qte_line_dtl_tbl.count > 0 then

                        IF l_qte_line_dtl_tbl(1).Service_Duration = FND_API.G_MISS_NUM  THEN
                            l_qte_line_dtl_tbl(1).Service_Duration := l_service_duration;
                        END IF;

                        IF l_qte_line_dtl_tbl(1).Service_period = FND_API.G_MISS_CHAR THEN
                            l_qte_line_dtl_tbl(1).Service_period := l_service_period;
                        END IF;

                        IF l_qte_line_dtl_tbl(1).service_coterminate_flag = FND_API.G_MISS_CHAR THEN
                            l_qte_line_dtl_tbl(1).service_coterminate_flag := l_coterminate_flag;
                        END IF;

                    end if;

                    IF l_customer_id is NULL OR l_customer_id = FND_API.G_MISS_NUM THEN
                        l_customer_id := l_party;
                    END IF;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Populate_quote_lines: l_qte_line_dtl_tbl(1).Service_Duration: '|| l_qte_line_dtl_tbl(1).Service_Duration,1,'N');
                        aso_debug_pub.add('Populate_quote_lines: l_qte_line_dtl_tbl(1).Service_period: '|| l_qte_line_dtl_tbl(1).Service_period,1,'N');
                        aso_debug_pub.add('l_qte_line_dtl_tbl(1).service_coterminate_flag: '|| l_qte_line_dtl_tbl(1).service_coterminate_flag,1,'N');
                        aso_debug_pub.add('Populate_quote_lines: Before call to Get_Duration: l_call_get_duration: '||l_call_get_duration,1,'N');
                    end if;

                    ASO_Service_Contracts_INT.Get_Duration(
                        P_Api_Version_Number  => 1.0,
                        X_msg_Count           => x_msg_count  ,
                        X_msg_Data            => x_msg_data   ,
                        X_Return_Status       => x_return_status,
                        P_customer_id         => l_customer_id,
                        P_system_id           => null,
                        P_Service_Duration    => l_qte_line_dtl_tbl(1).Service_Duration,
                        P_service_period      => l_qte_line_dtl_tbl(1).service_period ,
                        P_coterm_checked_yn   => l_qte_line_dtl_tbl(1).service_coterminate_flag,
                        P_start_date          => l_qte_line_rec.start_date_active,
                        P_end_date            => l_qte_line_rec.end_date_active,
                        X_service_duration    => l_qte_line_dtl_tbl_out(1).Service_Duration,
                        X_service_period      => l_qte_line_dtl_tbl_out(1).service_period,
                        X_new_end_date        => l_qte_line_rec_out.end_date_active );

                    l_qte_line_dtl_tbl(1).Service_Duration := l_qte_line_dtl_tbl_out(1).Service_Duration;
                    l_qte_line_dtl_tbl(1).service_period   := l_qte_line_dtl_tbl_out(1).service_period;
                    l_qte_line_rec.end_date_active         := l_qte_line_rec_out.end_date_active;

	            if aso_debug_pub.g_debug_flag = 'Y' then
                        aso_debug_pub.add('Populate_Quote_lines: After call to ASO Get_Duration x_return_status: '||X_Return_Status, 1, 'N');
                        aso_debug_pub.add('l_qte_line_rec.end_date_active:         '|| l_qte_line_rec.end_date_active, 1, 'N');
                        aso_debug_pub.add('l_qte_line_dtl_tbl(1).service_period:   '|| l_qte_line_dtl_tbl(1).service_period, 1, 'N');
                        aso_debug_pub.add('l_qte_line_dtl_tbl(1).Service_Duration: '|| l_qte_line_dtl_tbl(1).Service_Duration, 1, 'N');
                    end if;

                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;

               end if; --if l_call_get_duration = fnd_api.g_true then

           end if;  -- service item flag = 'Y'

     --Set the line_number of service items to the line_number of serviceable item, if the
     --service is attached to a quote line

     IF  nvl(l_service_item_flag,'N') = 'Y' AND p_qte_line_dtl_tbl.count > 0 THEN

          IF  l_qte_line_dtl_tbl(1).service_ref_line_id IS NOT NULL AND l_qte_line_dtl_tbl(1).service_ref_type_code = 'QUOTE' THEN

               OPEN  c_line_number(l_qte_line_dtl_tbl(1).service_ref_line_id);
               FETCH c_line_number INTO l_serviceable_line_number;

               if aso_debug_pub.g_debug_flag = 'Y' then
                   aso_debug_pub.add('Populate_quote_lines: l_serviceable_line_number: '|| l_serviceable_line_number);
               end if;

               IF c_line_number%FOUND AND l_serviceable_line_number IS NOT NULL THEN
                   l_qte_line_rec.line_number := l_serviceable_line_number;
               ELSE
                   if aso_debug_pub.g_debug_flag = 'Y' then
                       aso_debug_pub.add('Line Number does not exist for the serviceable item of the service');
                   end if;
               END IF;

               CLOSE c_line_number;

          END IF;

     END IF;

     --End of service line_number code


     --populate the config_item_id and bom_sort_order column values from cz_config_details_v
     --view if the calling application is passing config_header_id, config_revision_num and
     --component_code values. Fix for Bug#2980130

     if aso_debug_pub.g_debug_flag = 'Y' then

        aso_debug_pub.add('Before populating config_item_id,bom_sort_order. Operation_code = UPDATE');
        aso_debug_pub.add('l_qte_line_dtl_tbl.count: ' || l_qte_line_dtl_tbl.count);

     end if;

     for i in 1 .. l_qte_line_dtl_tbl.count loop

         if aso_debug_pub.g_debug_flag = 'Y' then

             aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').config_header_id:    '||l_qte_line_dtl_tbl(i).config_header_id);
             aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').config_revision_num: '||l_qte_line_dtl_tbl(i).config_revision_num);
             aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').component_code:      '||l_qte_line_dtl_tbl(i).component_code);
             aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').config_item_id:      '||l_qte_line_dtl_tbl(i).config_item_id);
             aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').bom_sort_order:      '||l_qte_line_dtl_tbl(i).bom_sort_order);

         end if;

         if ( l_qte_line_dtl_tbl(i).config_header_id is not null and
              l_qte_line_dtl_tbl(i).config_header_id <> fnd_api.g_miss_num ) and
            ( l_qte_line_dtl_tbl(i).config_revision_num is not null and
              l_qte_line_dtl_tbl(i).config_revision_num <> fnd_api.g_miss_num ) and
              l_qte_line_dtl_tbl(i).operation_code = 'CREATE' then

             if ( l_qte_line_dtl_tbl(i).config_item_id is null or
                  l_qte_line_dtl_tbl(i).config_item_id = fnd_api.g_miss_num ) then

                    open c_config_item_id( l_qte_line_dtl_tbl(i).config_header_id,
                                         l_qte_line_dtl_tbl(i).config_revision_num,
                                         l_qte_line_dtl_tbl(i).component_code );



                    fetch c_config_item_id into l_qte_line_dtl_tbl(i).config_item_id,
                                                l_qte_line_dtl_tbl(i).bom_sort_order;

                    if aso_debug_pub.g_debug_flag = 'Y' then

                        aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').config_item_id: '||l_qte_line_dtl_tbl(i).config_item_id);
                        aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').bom_sort_order: '||l_qte_line_dtl_tbl(i).bom_sort_order);

                    end if;

                    if c_config_item_id%notfound then

                         if aso_debug_pub.g_debug_flag = 'Y' then
                             aso_debug_pub.add('Inside c_config_item_id%notfound cond.');
                         end if;

                         close c_config_item_id;
                         raise fnd_api.g_exc_error;

                    end if;

                    close c_config_item_id;

             elsif ( l_qte_line_dtl_tbl(i).bom_sort_order is null or
                     l_qte_line_dtl_tbl(i).bom_sort_order = fnd_api.g_miss_char ) then

                    open c_bom_sort_order( l_qte_line_dtl_tbl(i).config_header_id,
                                           l_qte_line_dtl_tbl(i).config_revision_num,
                                           l_qte_line_dtl_tbl(i).config_item_id );

                    fetch c_bom_sort_order into l_qte_line_dtl_tbl(i).bom_sort_order;

                    if aso_debug_pub.g_debug_flag = 'Y' then

                        aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').bom_sort_order: '||l_qte_line_dtl_tbl(i).bom_sort_order);

                    end if;

                    if c_bom_sort_order%notfound then

                         if aso_debug_pub.g_debug_flag = 'Y' then
                            aso_debug_pub.add('Inside c_bom_sort_order%notfound cond.');
                         end if;

                         close c_bom_sort_order;
                         raise fnd_api.g_exc_error;

                    end if;

                    close c_bom_sort_order;

             end if;

         end if;

     end loop;

     --end of fix for Bug#2980130

	END IF; -- operation code 'update'


	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Populate_Quote_lines:Update :after  update '||X_Return_Status, 1, 'N');
	end if;


    X_Qte_Line_Rec          :=  l_qte_line_rec;
    X_Qte_Line_Dtl_TBL      :=  l_Qte_Line_Dtl_TBL;
    X_Payment_Tbl           :=  l_payment_tbl;
    X_Price_Adj_Tbl         :=  l_price_adj_tbl;
    X_Shipment_Tbl          :=  l_shipment_tbl;
    X_Tax_Detail_Tbl        :=  l_tax_detail_tbl;
    X_Freight_Charge_Tbl    :=  l_freight_charge_tbl;
    X_Price_Attributes_Tbl  :=  l_price_attributes_tbl;
    X_Price_Adj_Attr_Tbl    :=  l_price_adj_attr_tbl;
    X_Line_Attribs_Ext_Tbl  :=  l_line_attribs_ext_tbl;
    X_Sales_Credit_tbl      :=  p_sales_credit_tbl;
    X_quote_party_tbl       :=  p_quote_party_tbl;
END;





--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Quote_Lines
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_qte_lines_Rec     IN    qte_line_Rec_Type         Required
--       P_Payment_Tbl       IN    Payment_Tbl_Type
--       P_Price_Adj_Tbl     IN    Price_Adj_Tbl_Type
--       P_Qte_Line_Dtl_Rec  IN    Qte_Line_Dtl_Rec_Type
--       P_Shipment_Tbl      IN    Shipment_Tbl_Type
--       P_Tax_Details_Tbl      IN    Tax_Details_Tbl_Type
--       P_Freight_Charges_Tbl  IN    Freight_Charges_Tbl_Type
--       P_Line_Relationship_Tbl IN   Line_Relationship_Tbl_Type
--       P_Price_Attributes_Tbl  IN   Price_Attributes_Tbl_Type
--       P_Price_Adj_Relationship_Tbl IN Price_Adj_Relationship_Tbl_Type
--       P_Update_Header_Flag    IN   VARCHAR2     Optional  Default = FND_API.G_TRUE

--   OUT:
--       X_quote_line_id           OUT NOCOPY /* file.sql.39 change */ NUMBER,
--       x_return_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */ NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_Quote_Lines(
    P_Api_Version_Number    IN   NUMBER,
    P_Init_Msg_List         IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Commit                IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Validation_Level      IN   NUMBER                                  := FND_API.G_VALID_LEVEL_FULL,
    P_Qte_Header_Rec        IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type       := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Qte_Line_Rec          IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type         := ASO_QUOTE_PUB.G_MISS_qte_line_REC,
    P_Control_REC           IN   ASO_QUOTE_PUB.Control_Rec_Type          := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    P_Payment_Tbl           IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Price_Adj_Tbl         IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type        := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Qte_Line_Dtl_tbl      IN   ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type     := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Shipment_Tbl          IN   ASO_QUOTE_PUB.Shipment_Tbl_Type         := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl        IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl    IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_freight_charge_TBL,
    P_Price_Attributes_Tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type   := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Attribs_Ext_Tbl  IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type := ASO_QUOTE_PUB.G_Miss_Line_Attribs_Ext_Tbl,
    P_Sales_Credit_Tbl      IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type     := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Update_Header_Flag    IN   VARCHAR2                                := 'Y',
    X_Qte_Line_Rec          OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    X_Payment_Tbl           OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_Price_Adj_Tbl         OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Qte_Line_Dtl_tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Dtl_TBL_Type,
    X_Shipment_Tbl          OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS

   Cursor C_Get_quote(c_QUOTE_HEADER_ID Number) IS
   Select LAST_UPDATE_DATE, QUOTE_STATUS_ID, QUOTE_NUMBER, TOTAL_ADJUSTED_PERCENT
   From  ASO_QUOTE_HEADERS_ALL
   Where QUOTE_HEADER_ID = c_QUOTE_HEADER_ID;

   CURSOR C_Qte_Status(c_qte_status_id NUMBER) IS
   SELECT UPDATE_ALLOWED_FLAG, AUTO_VERSION_FLAG FROM ASO_QUOTE_STATUSES_B
   WHERE quote_status_id = c_qte_status_id;

   CURSOR C_Qte_Version (X_qte_number NUMBER) IS
   SELECT max(quote_version)
   FROM ASO_QUOTE_HEADERS_ALL
   WHERE quote_number = X_qte_number;

   CURSOR get_cust_acct(cust_QUOTE_HEADER_ID Number) IS
   SELECT CUST_ACCOUNT_ID
   FROM ASO_QUOTE_HEADERS_ALL
   WHERE QUOTE_HEADER_ID = cust_QUOTE_HEADER_ID;

   CURSOR c_reservation(C_inv_item_id NUMBER,C_Organization_id NUMBER) IS
   SELECT  INVENTORY_ITEM_ID,ORGANIZATION_ID  FROM mtl_system_items_b
   WHERE RESERVABLE_TYPE =1 AND
   MTL_TRANSACTIONS_ENABLED_FLAG = 'Y' AND
   INVENTORY_ITEM_ID= C_inv_item_id AND
   ORGANIZATION_ID = C_Organization_id;


   Cursor C_exp_date(c_QUOTE_HEADER_ID Number) IS
   Select quote_expiration_date
   From  ASO_QUOTE_HEADERS_ALL
   Where QUOTE_HEADER_ID = c_QUOTE_HEADER_ID;

   CURSOR C_org_id IS
   SELECT org_id
   FROM aso_quote_headers_all
   WHERE quote_header_id = p_qte_line_rec.quote_header_id;

   cursor c_service (p_qln_id number)is
   select service_item_flag,serviceable_product_flag
   from aso_quote_lines_All
   where quote_line_id = p_qln_id;

   --New code for Bug # 2498942 fix

   CURSOR C_line_category_code(p_quote_line_id  NUMBER) IS
   SELECT line_category_code
   FROM aso_quote_lines_all
   WHERE quote_line_id = p_quote_line_id;

   --End of new code for Bug # 2498942 fix

   Cursor c_container_item_check (C_inv_item_id NUMBER,C_Organization_id NUMBER) IS
   select config_model_type
   from mtl_system_items_b
   where INVENTORY_ITEM_ID= C_inv_item_id
   AND ORGANIZATION_ID = C_Organization_id;


   CURSOR c_header_org IS
   SELECT org_id,quote_type FROM aso_quote_headers_all
   WHERE quote_header_id = P_qte_line_rec.quote_header_id;



   l_api_version_number    NUMBER := 1.0;
   l_last_update_date      DATE;
   l_api_name              VARCHAR2(50) := 'Create_Quote_Lines';
   l_Return_Status         VARCHAR2(50);
   l_Msg_Count             NUMBER;
   l_Msg_Data              VARCHAR2(240);
   l_qte_status_id         NUMBER;
   l_update_allowed	       VARCHAR2(1);
   l_auto_version          VARCHAR2(1);
   l_quote_number          NUMBER;
   l_old_header_rec        ASO_QUOTE_PUB.qte_header_rec_type;
   l_qte_header_rec        ASO_QUOTE_PUB.qte_header_rec_type;
   l_quote_version         NUMBER;
   x_quote_header_id       NUMBER;
   l_hd_discount_percent   NUMBER;
   l_control_rec           ASO_QUOTE_PUB.Control_REc_Type := p_control_rec;
   l_pricing_control_rec   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE;
   l_hd_shipment_rec       ASO_QUOTE_PUB.Shipment_Rec_Type;
   l_hd_shipment_tbl       ASO_QUOTE_PUB.Shipment_Tbl_Type;
   l_hd_price_attr_tbl     ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
   x_qte_line_tbl          ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
   l_organization_id       NUMBER;
   l_invoice_org_id        NUMBER;
   l_ship_org_id           NUMBER;
   l_cust_acct             NUMBER;
   l_inv_item              NUMBER;
   l_org_id                NUMBER;
   l_quote_exp_date        DATE;

   l_service_item_flag         varchar2(1);
   l_serviceable_product_flag  varchar2(1);
   l_service                   varchar2(1);
   l_call_update               varchar2(1);
   l_line_category_code        VARCHAR2(30);
   l_db_order_type_id          Number;

   -- local variables
   l_Qte_Line_Rec           ASO_QUOTE_PUB.Qte_Line_Rec_Type          := ASO_QUOTE_PUB.G_MISS_qte_line_REC;
   l_Payment_Tbl            ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_Payment_TBL;
   l_Price_Adj_Tbl          ASO_QUOTE_PUB.Price_Adj_Tbl_Type         := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL;
   l_Qte_Line_Dtl_rec       ASO_QUOTE_PUB.Qte_Line_Dtl_rec_Type      := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_REC;
   l_Shipment_Tbl           ASO_QUOTE_PUB.Shipment_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_shipment_TBL;
   l_Tax_Detail_Tbl         ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_MISS_tax_detail_TBL;
   l_Freight_Charge_Tbl     ASO_QUOTE_PUB.Freight_Charge_Tbl_Type    := ASO_QUOTE_PUB.G_MISS_freight_charge_TBL;
   l_Line_Rltship_Tbl       ASO_QUOTE_PUB.Line_Rltship_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_line_rltship_TBL;
   l_Price_Attributes_Tbl   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL;
   l_Price_Adj_rltship_Tbl  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL;
   l_Price_Adj_Attr_Tbl     ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type    := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl;
   l_Line_Attribs_Ext_Tbl   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type  := ASO_QUOTE_PUB.G_Miss_Line_Attribs_Ext_Tbl;
   l_Qte_Line_Dtl_tbl       ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type      := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL;
   l_Sales_Credit_Tbl       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl;
   l_Quote_Party_Tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl;
   l_qte_line_tbl           ASO_QUOTE_PUB.Qte_Line_tbl_Type          := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;
   l_tax_control_rec        ASO_TAX_INT.Tax_control_rec_type;
   x_tax_amount             NUMBER;
   l_tax_detail_rec         ASO_QUOTE_PUB.Tax_Detail_Rec_Type        := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC;
   lx_tax_shipment_tbl      ASO_QUOTE_PUB.Shipment_Tbl_Type;
   my_message               VARCHAR2(2000);

   l_copy_quote_control_rec aso_copy_quote_pub.copy_quote_control_rec_type;
   l_copy_quote_header_rec  aso_copy_quote_pub.copy_quote_header_rec_type;
   l_qte_nbr                number;
   l_shipment_tbl_out       ASO_QUOTE_PUB.Shipment_Tbl_Type;

   --new code to call overload pricing_order procedure
   lx_qte_header_rec        ASO_QUOTE_PUB.Qte_Header_Rec_Type;
   lx_qte_line_tbl          ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
   lx_qte_line_dtl_tbl      ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type;
   lx_price_adj_tbl         ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
   lx_price_adj_attr_tbl    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
   lx_price_adj_rltship_tbl ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

   -- bmishra defaulting framework
   l_def_control_rec               ASO_DEFAULTING_INT.Control_Rec_Type     := ASO_DEFAULTING_INT.G_MISS_CONTROL_REC;
   l_db_object_name                VARCHAR2(30);
   l_shipment_rec                  ASO_QUOTE_PUB.Shipment_Rec_Type;
   l_payment_rec                   ASO_QUOTE_PUB.Payment_Rec_Type          := ASO_QUOTE_PUB.G_MISS_Payment_REC;
   lx_hd_shipment_rec              ASO_QUOTE_PUB.Shipment_Rec_Type;
   lx_hd_payment_rec               ASO_QUOTE_PUB.Payment_Rec_Type;
   lx_hd_tax_detail_rec            ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
   lx_hd_misc_rec                  ASO_DEFAULTING_INT.Header_Misc_Rec_Type;
   lx_qte_line_rec                 ASO_QUOTE_PUB.Qte_Line_Rec_Type;
   lx_ln_misc_rec                  ASO_DEFAULTING_INT.Line_Misc_Rec_Type;
   lx_ln_shipment_rec              ASO_QUOTE_PUB.Shipment_Rec_Type;
   lx_ln_payment_rec               ASO_QUOTE_PUB.Payment_Rec_Type;
   lx_ln_tax_detail_rec            ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
   lx_changed_flag                 VARCHAR2(1);
   lx_ln_payment_tbl	          ASO_QUOTE_PUB.Payment_Tbl_Type;
   lx_ln_Shipment_Tbl              ASO_QUOTE_PUB.Shipment_Tbl_Type;
   l_Orig_Payment_Tbl              ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_Payment_TBL;
   l_container_item_flag           varchar2(1) := null;
   l_is_model_published            number;
   l_def_Qte_Line_Rec              ASO_QUOTE_PUB.Qte_Line_Rec_Type          := ASO_QUOTE_PUB.G_MISS_qte_line_REC;
   l_quote_type                    VARCHAR2(1) := null;
   l_header_org_id                 NUMBER;


BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_quote_lines_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                       	                   p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Create_Quote_lines - Begin ', 1, 'Y');
     		aso_debug_pub.add('P_Control_REC.AUTO_VERSION_FLAG: '||nvl(P_Control_REC.AUTO_VERSION_FLAG,'null'),1,'N');
     		aso_debug_pub.add('P_Control_REC.pricing_request_type: '||nvl(P_Control_REC.pricing_request_type,'null'),1,'N');
     		aso_debug_pub.add('P_Control_REC.header_pricing_event: '||nvl(P_Control_REC.header_pricing_event,'null'),1,'N');
     		aso_debug_pub.add('P_Control_REC.line_pricing_event: '||nvl(P_Control_REC.line_pricing_event,'null'),1,'N');
     		aso_debug_pub.add('P_Control_REC.CALCULATE_TAX_FLAG: '||nvl(P_Control_REC.CALCULATE_TAX_FLAG,'null'),1,'N');
     		aso_debug_pub.add('P_Control_REC.CALCULATE_FREIGHT_CHARGE_FLAG: '||nvl(P_Control_REC.CALCULATE_FREIGHT_CHARGE_FLAG,'null'),1,'N');
     		aso_debug_pub.add('P_Control_REC.COPY_TASK_FLAG: '||nvl(P_Control_REC.COPY_TASK_FLAG,'null'),1,'N');
     		aso_debug_pub.add('P_Control_REC.COPY_NOTES_FLAG: '||nvl(P_Control_REC.COPY_NOTES_FLAG,'null'),1,'N');
     		aso_debug_pub.add('P_Control_REC.COPY_ATT_FLAG: '||nvl(P_Control_REC.COPY_ATT_FLAG,'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.OPERATION_CODE: '||nvl(P_Qte_Line_Rec.OPERATION_CODE,'null'),1,'N');
     		--aso_debug_pub.add('P_Qte_Line_Rec.QUOTE_LINE_ID: '||nvl(P_Qte_Line_Rec.QUOTE_LINE_ID,'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.QUOTE_HEADER_ID: '||nvl(to_char(P_Qte_Line_Rec.QUOTE_HEADER_ID),'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.LINE_CATEGORY_CODE: '||nvl(P_Qte_Line_Rec.LINE_CATEGORY_CODE,'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.ITEM_TYPE_CODE: '||nvl(P_Qte_Line_Rec.ITEM_TYPE_CODE,'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.ORDER_LINE_TYPE_ID: '||nvl(to_char(P_Qte_Line_Rec.ORDER_LINE_TYPE_ID),'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.INVOICE_TO_PARTY_SITE_ID: '||nvl(to_char(P_Qte_Line_Rec.INVOICE_TO_PARTY_SITE_ID),'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.INVOICE_TO_PARTY_ID: '||nvl(to_char(P_Qte_Line_Rec.INVOICE_TO_PARTY_ID),'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.INVOICE_TO_CUST_ACCOUNT_ID: '||nvl(to_char(P_Qte_Line_Rec.INVOICE_TO_CUST_ACCOUNT_ID),'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.INVENTORY_ITEM_ID: '||nvl(to_char(P_Qte_Line_Rec.INVENTORY_ITEM_ID),'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.QUANTITY: '||nvl(to_char(P_Qte_Line_Rec.QUANTITY),'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.UOM_CODE: '||nvl(P_Qte_Line_Rec.UOM_CODE,'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.PRICING_QUANTITY_UOM: '||nvl(P_Qte_Line_Rec.PRICING_QUANTITY_UOM,'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.PRICE_LIST_ID: '||nvl(to_char(P_Qte_Line_Rec.PRICE_LIST_ID),'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.PRICE_LIST_LINE_ID: '||nvl(to_char(P_Qte_Line_Rec.PRICE_LIST_LINE_ID),'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.CURRENCY_CODE: '||nvl(P_Qte_Line_Rec.CURRENCY_CODE,'null'),1,'N');
     		aso_debug_pub.add('P_Qte_Line_Rec.RELATED_ITEM_ID: '||nvl(to_char(P_Qte_Line_Rec.RELATED_ITEM_ID),'null'),1,'N');
               aso_debug_pub.add('P_Qte_Line_Rec.org_id: '||nvl(to_char(P_Qte_Line_Rec.org_id),'null'));
      end if;
      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      IF (p_update_header_flag = 'Y') THEN


          Open C_Get_quote( p_qte_line_rec.QUOTE_HEADER_ID);
          Fetch C_Get_quote into l_LAST_UPDATE_DATE, l_qte_status_id, l_quote_number, l_hd_discount_percent;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	      aso_debug_pub.add('After c_get_quote',1,'N');
      	      aso_debug_pub.add('l_qte_status_id: '||nvl(to_char(l_qte_status_id),'null'),1,'N');
      	      aso_debug_pub.add('l_quote_number: '||nvl(to_char(l_quote_number),'null'),1,'N');
      	      aso_debug_pub.add('l_hd_discount_percent: '||nvl(to_char(l_hd_discount_percent),'null'),1,'N');
	  end if;


          If ( C_Get_quote%NOTFOUND) Then

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'API_MISSING_UPDATE_TARGET');
                  FND_MESSAGE.Set_Token ('INFO', 'quote', FALSE);
                  FND_MSG_PUB.Add;
              END IF;
              raise FND_API.G_EXC_ERROR;
          END IF;
          Close C_Get_quote;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	      aso_debug_pub.add('After C_Get_quote Cursor call ',1,'N');
	  end if;

          If (l_last_update_date is NULL or l_last_update_date = FND_API.G_MISS_Date ) Then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
                  FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
                  FND_MSG_PUB.ADD;
              END IF;
              raise FND_API.G_EXC_ERROR;
          End if;

          -- Check Whether record has been changed by someone else

          If (trunc(l_last_update_date) <> trunc(p_control_rec.last_update_date)) Then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'API_RECORD_CHANGED');
                  FND_MESSAGE.Set_Token('INFO', 'quote', FALSE);
                  FND_MSG_PUB.ADD;
              END IF;
              raise FND_API.G_EXC_ERROR;
          End if;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	      aso_debug_pub.add('After Last update date validation',1,'N');
	  end if;

          Open c_qte_status (l_qte_status_id);
          Fetch C_qte_status into l_update_allowed, l_auto_version;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	      aso_debug_pub.add('after c_qte_status',1,'N');
      	      aso_debug_pub.add('l_update_allowed: '|| nvl(l_update_allowed,'null'),1,'N');
      	      aso_debug_pub.add('l_auto_version:   '|| nvl(l_auto_version,'null'),1,'N');
	  end if;

          -- hyang quote_status
          -- removed checking of update_allowed_flag
          -- end of hyang quote_status
          Close c_qte_status;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	      aso_debug_pub.add('After c_qte_status cursor call',1,'N');
	  end if;

          --If the control rec does not set auto version to 'Y' then it should not be versioned

          IF p_control_rec.auto_version_flag = FND_API.G_TRUE AND NVL(l_auto_version,'Y') = 'Y' THEN

	      OPEN C_Qte_Version(l_quote_number);
	      FETCH C_Qte_Version into l_quote_version;
	      l_quote_version := nvl(l_quote_version, 0) + 1;
	      CLOSE C_Qte_Version;
          ELSE
              l_auto_version := 'N';

          END IF;

          -- update Quote Header

          -- validate header information

          IF l_auto_version = 'Y' THEN

	      l_old_header_rec := ASO_UTILITY_PVT.Query_Header_Row(p_qte_line_rec.QUOTE_HEADER_ID);

              -- header should be updated only if the flag is set to 'Y'
              -- update quote header with the new version number
              -- should be called after querying the existing rec and before copying

              l_copy_quote_control_rec.new_version     :=  FND_API.G_TRUE;
              l_copy_quote_header_rec.quote_header_id  :=  l_old_header_rec.quote_header_id;

              aso_copy_quote_pvt.copy_quote( P_Api_Version_Number      =>  1.0,
                                             P_Init_Msg_List           =>  FND_API.G_FALSE,
                                             P_Commit                  =>  FND_API.G_FALSE,
                                             P_Copy_Quote_Header_Rec   =>  l_copy_quote_header_rec,
                                             P_Copy_Quote_Control_Rec  =>  l_copy_quote_control_rec,
                                             X_Qte_Header_Id           =>  x_quote_header_id,
                                             X_Qte_Number              =>  l_qte_nbr,
                                             X_Return_Status           =>  l_return_status,
                                             X_Msg_Count               =>  x_msg_count,
                                             X_Msg_Data                =>  x_msg_data
                                            );

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
            	  aso_debug_pub.add('Create_Quote_Lines: After copy_quote l_return_status: '|| l_return_status);
            	  aso_debug_pub.add('Create_Quote_Lines: After copy_quote x_quote_header_id: '|| x_quote_header_id);
            	  aso_debug_pub.add('Create_Quote_Lines: After copy_quote l_qte_nbr:  '|| l_qte_nbr);
              end if;

              IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

                 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                     FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
                     FND_MESSAGE.Set_Token('ROW', 'ASO_QUOTE_HEADER', TRUE);
                     FND_MSG_PUB.ADD;
                 END IF;

                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

              ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN

                 x_return_status := FND_API.G_RET_STS_ERROR;

              END IF;

              update aso_quote_headers_all
                 set quote_version      =  l_quote_version + 1,
                     max_version_flag   =  'Y',
                     last_update_date   =  sysdate,
                     last_updated_by    =  fnd_global.user_id,
                     last_update_login  =  fnd_global.conc_login_id
                 where quote_header_id = p_qte_line_rec.quote_header_id;

                 update aso_quote_headers_all
                 set max_version_flag   =  'N',
                     quote_version      =  l_old_header_rec.quote_version,
                     last_update_date   =  sysdate,
                     last_updated_by    =  fnd_global.user_id,
                     last_update_login  =  fnd_global.conc_login_id
                 where quote_header_id = x_quote_header_id;

                 update aso_quote_headers_all
                 set quote_version      =  l_quote_version,
                     last_update_date   =  sysdate,
                     last_updated_by    =  fnd_global.user_id,
                     last_update_login  =  fnd_global.conc_login_id
                 where quote_header_id = p_qte_line_rec.quote_header_id;

          END IF;    -- auto_version set to 'Y'

      END IF;    -- header update flag


      -- bmishra line defaulting framework begin
      OPEN c_header_org;
      FETCH c_header_org INTO l_header_org_id,l_quote_type;
      CLOSE c_header_org;


      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote_Line: l_header_org_id'||l_header_org_id, 1, 'Y');
          aso_debug_pub.add('Create_Quote_Line:l_quote_type'||l_quote_type, 1, 'Y');
          aso_debug_pub.add('Create_Quote_Line: Before defaulting framework', 1, 'Y');
          aso_debug_pub.add('Create_Quote_Line: populate defaulting control record from the line control record', 1, 'Y');
      END IF ;

      l_def_control_rec.Dependency_Flag       := p_control_rec.Dependency_Flag;
      l_def_control_rec.Defaulting_Flag       := p_control_rec.Defaulting_Flag;
      l_def_control_rec.Application_Type_Code := p_control_rec.Application_Type_Code;
      l_def_control_rec.Defaulting_Flow_Code  := 'CREATE';

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Defaulting_Fwk_Flag:   '|| p_control_rec.Defaulting_Fwk_Flag, 1, 'Y');
          aso_debug_pub.add('Dependency_Flag:       '|| l_def_control_rec.Dependency_Flag, 1, 'Y');
          aso_debug_pub.add('Defaulting_Flag:       '|| l_def_control_rec.Defaulting_Flag, 1, 'Y');
          aso_debug_pub.add('Application_Type_Code: '|| l_def_control_rec.Application_Type_Code, 1, 'Y');
          aso_debug_pub.add('Defaulting_Flow_Code:  '|| l_def_control_rec.Defaulting_Flow_Code, 1, 'Y');
      END IF ;

      IF l_def_control_rec.application_type_code = 'QUOTING HTML' OR  l_def_control_rec.application_type_code = 'QUOTING FORM' THEN
          l_db_object_name := ASO_QUOTE_HEADERS_PVT.G_QUOTE_LINE_DB_NAME;
      ELSIF l_def_control_rec.application_type_code = 'ISTORE' THEN
          l_db_object_name := ASO_QUOTE_HEADERS_PVT.G_STORE_CART_LINE_DB_NAME;
      ELSE
          l_control_rec.Defaulting_Fwk_Flag := 'N';
      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Pick '||l_db_object_name ||' based on calling application '||l_def_control_rec.application_type_code, 1, 'Y');
      END IF ;

      IF p_shipment_tbl.count > 0 THEN
          l_shipment_rec := p_shipment_tbl(1);
      END IF;

      IF p_payment_tbl.count > 0 THEN
          l_payment_rec := p_payment_tbl(1);
      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_Quote_Line - Before Calling Default_Entity procedure', 1, 'Y');
      END IF ;

      IF l_control_rec.defaulting_fwk_flag = 'Y'  AND nvl(l_quote_type,'X')  <> 'T' THEN

         l_def_Qte_Line_Rec := p_qte_line_rec;
         l_def_Qte_Line_Rec.org_id := l_header_org_id;


          ASO_DEFAULTING_INT.Default_Entity ( p_api_version           =>  1.0,
                                              p_control_rec           =>  l_def_control_rec,
                                              p_database_object_name  =>  l_db_object_name,
                                              p_quote_line_rec        =>  l_def_Qte_Line_Rec,
                                              p_line_shipment_rec     =>  l_shipment_rec,
                                              p_line_payment_rec      =>  l_payment_rec,
                                              x_quote_header_rec      =>  l_qte_header_rec,
                                              x_header_misc_rec       =>  lx_hd_misc_rec,
                                              x_header_shipment_rec   =>  lx_hd_shipment_rec,
                                              x_header_payment_rec    =>  lx_hd_payment_rec,
                                              x_header_tax_detail_rec =>  lx_hd_tax_detail_rec,
                                              x_quote_line_rec        =>  lx_qte_line_rec,
                                              x_line_misc_rec         =>  lx_ln_misc_rec,
                                              x_line_shipment_rec     =>  lx_ln_shipment_rec,
                                              x_line_payment_rec      =>  lx_ln_payment_rec,
                                              x_line_tax_detail_rec   =>  lx_ln_tax_detail_rec,
                                              x_changed_flag          =>  lx_changed_flag,
                                              x_return_status         =>  x_return_status,
                                              x_msg_count             =>  x_msg_count,
                                              x_msg_data              =>  x_msg_data);

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote_line: After call to ASO_DEFAULTING_INT.Default_Entity', 1, 'Y');
              aso_debug_pub.add('Create_Quote_line: x_return_status: '|| x_return_status, 1, 'Y');
          end if;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_DEFAULTING');
                  FND_MSG_PUB.ADD;
              END IF;

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

          END IF;

          IF aso_quote_headers_pvt.Shipment_Null_Rec_Exists(lx_ln_shipment_rec, l_db_object_name) THEN
              lx_ln_shipment_tbl(1) := lx_ln_shipment_rec;
          END IF;

--          IF aso_quote_headers_pvt.Payment_Null_Rec_Exists(lx_ln_payment_rec, l_db_object_name) THEN
          lx_ln_payment_tbl(1) := lx_ln_payment_rec;
--          END IF;

	 ELSE

	     lx_qte_line_rec := p_qte_line_rec;
          lx_ln_shipment_tbl := p_shipment_tbl;
          lx_ln_payment_tbl := p_payment_tbl;

      END IF;


-- bmishra defaulting framework end


	IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN

          -- item type code must exist in aso_lookups and the item, item type
          -- should exist in mtl_system_items

          ASO_VALIDATE_PVT.Validate_item_type_code(
		  p_init_msg_list  => FND_API.G_FALSE,
		  p_item_type_code => lx_qte_line_rec.item_type_code,
		  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);

	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

	  -- invoice_to_party_id must exist and be active in HZ_PARTIES,
	  -- and have the usage INVOICE.

	  ASO_VALIDATE_PVT.Validate_Party (
		p_init_msg_list	=> FND_API.G_FALSE,
		p_party_id	=> lx_qte_line_rec.invoice_to_party_id,
		p_party_usage	=> 'INVOICE',
		x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);
	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	      aso_debug_pub.add('Create_Quote_lines - after validate_party ', 1, 'N');
	  end if;

	  -- price list must exist and be active in OE_PRICE_LISTS
	  ASO_VALIDATE_PVT.Validate_PriceList (
		p_init_msg_list	=> FND_API.G_FALSE,
		p_price_list_id	=> lx_qte_line_rec.price_list_id,
		x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);

	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
          END IF;


          ASO_VALIDATE_PVT.Validate_Quote_Price_Exp(
  	        p_init_msg_list		=> FND_API.G_FALSE,
                p_price_list_id	        => lx_qte_line_rec.price_list_id,
                p_quote_expiration_date => l_quote_exp_date,
                x_return_status         => x_return_status,
	        x_msg_count	        => x_msg_count,
	        x_msg_data	        => x_msg_data);

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
          END IF;

	  -- shp_to_party_id must exist and be active in HZ_PARTIES and have the usage SHIP.
          For i in 1..lx_ln_shipment_tbl.count LOOP

	    ASO_VALIDATE_PVT.Validate_Party (
		p_init_msg_list	=> FND_API.G_FALSE,
		p_party_id	=> lx_ln_shipment_tbl(i).ship_to_party_id,
		p_party_usage	=> 'SHIP',
		x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);

	    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

	  END LOOP;

          ASO_VALIDATE_PVT.Validate_Marketing_Source_Code(
		p_init_msg_list         => FND_API.G_FALSE,
		p_mkting_source_code_id	=> lx_qte_line_rec.marketing_source_code_id,
                x_return_status         => x_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data);

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
          END IF;

          FOR i in 1..p_qte_line_dtl_tbl.count LOOP

             ASO_VALIDATE_PVT.Validate_Service_Duration(
		p_init_msg_list      => FND_API.G_FALSE,
        	p_service_duration   => p_qte_line_dtl_tbl(i).service_duration,
		x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);

             IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
             END IF;

          END LOOP;


          FOR i in 1..p_sales_credit_tbl.count LOOP

             if aso_debug_pub.g_debug_flag = 'Y' then
                 aso_debug_pub.add('p_sales_credit_tbl('||i||').operation_code: '|| p_sales_credit_tbl(i).operation_code,1,'Y');
             end if;

             if (p_sales_credit_tbl(i).operation_code = 'CREATE' or p_sales_credit_tbl(i).operation_code = 'UPDATE') then

                 ASO_VALIDATE_PVT.Validate_Resource_id(
		             p_init_msg_list => FND_API.G_FALSE,
		             p_resource_id   => p_sales_credit_tbl(i).resource_id,
		             x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data);

                 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		               FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_SALES_REP_ID');
		               FND_MSG_PUB.ADD;
	                END IF;
                     RAISE FND_API.G_EXC_ERROR;

                 END IF;

                 ASO_VALIDATE_PVT.Validate_Resource_group_id(
		             p_init_msg_list      => FND_API.G_FALSE,
		             p_resource_group_id  => p_sales_credit_tbl(i).resource_group_id,
		             x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data);

                 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 ASO_VALIDATE_PVT.Validate_Salescredit_Type(
		             p_init_msg_list        => FND_API.G_FALSE,
		             p_salescredit_type_id	 => p_sales_credit_tbl(i).sales_credit_type_id,
		             x_return_status        => x_return_status,
                       x_msg_count            => x_msg_count,
                       x_msg_data             => x_msg_data);

                 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

                 ASO_VALIDATE_PVT.Validate_EmployPerson(
        	             p_init_msg_list => FND_API.G_FALSE,
        	             p_employee_id   => p_sales_credit_tbl(i).employee_person_id,
		             x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data);

                 IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                 END IF;

             end if;

          END LOOP;

          FOR i in 1..p_quote_party_tbl.count LOOP

             ASO_VALIDATE_PVT.Validate_Party_Type(
		         p_init_msg_list => FND_API.G_FALSE,
		         p_party_type    => p_quote_party_tbl(i).party_type,
        	         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data);

             IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

             ASO_VALIDATE_PVT.Validate_Party(
		       p_init_msg_list => FND_API.G_FALSE,
		       p_party_id      => p_quote_party_tbl(i).party_id,
		       p_party_usage   => null,
		       x_return_status => x_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data);

             IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

 	     ASO_VALIDATE_PVT.Validate_Party_Object_Type(
		       p_init_msg_list	    => FND_API.G_FALSE,
		       p_party_object_type  => p_quote_party_tbl(i).party_object_type,
		       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data);

             IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

          END LOOP;


             ASO_VALIDATE_PVT.Validate_MiniSite(
                p_init_msg_list => FND_API.G_FALSE,
                p_minisite_id   => lx_qte_line_rec.minisite_id,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);
             IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

             ASO_VALIDATE_PVT.Validate_Section(
                p_init_msg_list => FND_API.G_FALSE,
                p_section_id    => lx_qte_line_rec.section_id,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);
             IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

      END IF;



      IF p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_RECORD THEN

         -- if organization id does not exist then it should be defaulted

         IF lx_qte_line_rec.organization_id is NULL or
            lx_qte_line_rec.organization_id = FND_API.G_MISS_NUM THEN

             -- default org id from header

             IF lx_qte_line_rec.org_id is NULL  OR  lx_qte_line_rec.org_id = FND_API.G_MISS_NUM THEN

                 OPEN C_org_id;
                 FETCH C_org_id into l_org_id;
                 IF C_org_id%NOTFOUND THEN

                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                           FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                           FND_MESSAGE.Set_Token('COLUMN', 'ORG_ID', FALSE);
                           FND_MSG_PUB.ADD;
                      END IF;
                 END IF;
                 CLOSE C_org_id;
             END IF;

             l_organization_id := oe_profile.value('OE_ORGANIZATION_ID', l_org_id);

         ELSE

		   l_organization_id := lx_qte_line_rec.organization_id;

         END IF;


         -- UOM must exist and should be in ASO_I_UNITS_OF_MEASURE

         ASO_VALIDATE_PVT.Validate_UOM_code(
		      p_init_msg_list	  => FND_API.G_FALSE,
		      p_uom_code          => lx_qte_line_rec.uom_code,
                      p_organization_id   => l_organization_id,
                      p_inventory_item_id => lx_qte_line_rec.inventory_item_id,
		      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data);

	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          if aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Create_Quote_lines - After validate_UOM_code ', 1, 'N');
          end if;

          ASO_VALIDATE_PVT.Validate_For_GreaterEndDate (
		      p_init_msg_list	=> FND_API.G_FALSE,
		      p_start_date      => lx_qte_line_rec.start_date_active,
        	      p_end_date        => lx_qte_line_rec.end_date_active,
		      x_return_status   => x_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data);

	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_END_DATE');
	     FND_MSG_PUB.ADD;
	   END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

       FOR i in 1..p_qte_line_dtl_tbl.count LOOP
        ASO_VALIDATE_PVT.Validate_Returns(
        p_init_msg_list	  	=> FND_API.G_FALSE,
        p_return_ref_type_code  => p_qte_line_dtl_tbl(i).return_ref_type,
        p_return_ref_header_id  => p_qte_line_dtl_tbl(i).return_ref_header_id,
        p_return_ref_line_id    => p_qte_line_dtl_tbl(i).return_ref_line_id,
	x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data);

	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
             FND_MESSAGE.Set_Token('INFO', 'RETURN', FALSE);
	     FND_MSG_PUB.ADD;
	   END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;
        END LOOP;

	  -- tax_exempt_flag must be in 'E', 'R' and 'S'
	  -- and tax_exempt_reason_code must exist if tax_exempt_flag is 'E'.
         FOR i in 1..p_tax_detail_tbl.count LOOP
	  ASO_VALIDATE_PVT.Validate_Tax_Exemption (
		p_init_msg_list	=> FND_API.G_FALSE,
		p_tax_exempt_flag	=> p_tax_detail_tbl(i).tax_exempt_flag,
		p_tax_exempt_reason_code=> p_tax_detail_tbl(i).tax_exempt_reason_code,
		x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);
	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
             FND_MESSAGE.Set_Token('INFO', 'TAX', FALSE);
	     FND_MSG_PUB.ADD;
	   END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;
         END LOOP;

      FOR i in 1..p_qte_line_dtl_tbl.count LOOP
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
        		aso_debug_pub.add('ASO_QUOTE_LINES_PVT:Create_Quote_Lines:config_header_id: '|| p_qte_line_dtl_tbl(i).config_header_id,1,'N');
        		aso_debug_pub.add('ASO_QUOTE_LINES_PVT:Create_Quote_Lines:config_revision_num: '|| p_qte_line_dtl_tbl(i).config_revision_num,1,'N');
        		aso_debug_pub.add('ASO_QUOTE_LINES_PVT:Create_Quote_Lines:component_code: '|| p_qte_line_dtl_tbl(i).component_code,1,'N');
        		aso_debug_pub.add('ASO_QUOTE_LINES_PVT:Create_Quote_Lines:config_item_id: '|| p_qte_line_dtl_tbl(i).config_item_id,1,'N');
		end if;

        -- We will add config_item_id when we will implement solution model
        IF ((p_qte_line_dtl_tbl(i).config_header_id IS NOT NULL AND
             p_qte_line_dtl_tbL(i).config_header_id <> FND_API.G_MISS_NUM) AND
            (p_qte_line_dtl_tbl(i).config_revision_num IS NOT NULL AND
             p_qte_line_dtl_tbl(i).config_revision_num <> FND_API.G_MISS_NUM) AND
            (p_qte_line_dtl_tbl(i).config_item_id IS NOT NULL AND
             p_qte_line_dtl_tbl(i).config_item_id <> FND_API.G_MISS_NUM)) THEN

             ASO_VALIDATE_PVT.Validate_Configuration(
		        p_init_msg_list			=> FND_API.G_FALSE,
		        p_config_header_id         => p_qte_line_dtl_tbl(i).config_header_id,
                  p_config_revision_num      => p_qte_line_dtl_tbl(i).config_revision_num,
                  p_config_item_id           => p_qte_line_dtl_tbl(i).config_item_id,
      		   x_return_status            => x_return_status,
                  x_msg_count                => x_msg_count,
                  x_msg_data                 => x_msg_data);

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
             		aso_debug_pub.add('Create_Quote_Lines after Validate_Configuration :x_return_status:'||x_return_status,1,'N');
			end if;
	        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
             END IF;
         END IF;
      END LOOP;


       FOR i in 1..p_qte_line_dtl_tbl.count LOOP
	ASO_VALIDATE_PVT.Validate_Delayed_Service(
		p_init_msg_list		=> FND_API.G_FALSE,
		p_service_ref_type_code
				=> p_qte_line_dtl_tbl(i).service_ref_type_code,
        	p_service_ref_line_id
				=> p_qte_line_dtl_tbl(i).service_ref_line_id,
        	p_service_ref_system_id
				=> p_qte_line_dtl_tbl(i).service_ref_system_id,
		x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);
	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
             FND_MESSAGE.Set_Token('INFO', 'DELAYED_SERVICE', FALSE);
	     FND_MSG_PUB.ADD;
	    END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;
       END LOOP;



  FOR i in 1..p_quote_party_tbl.count LOOP
    ASO_VALIDATE_PVT.Validate_Party_Object_Id(
	p_init_msg_list    => FND_API.G_FALSE,
        p_party_id         => p_quote_party_tbl(i).party_id,
	p_party_object_type     => p_quote_party_tbl(i).party_object_type,
        p_party_object_id       => p_quote_party_tbl(i).party_object_id,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data);
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
             FND_MESSAGE.Set_Token('INFO', 'PARTY OBJECT ID', FALSE);
	     FND_MSG_PUB.ADD;
	    END IF;
              RAISE FND_API.G_EXC_ERROR;
      END IF;
  END LOOP;


-- rahsan 10/11/2000
-- new validation for ship_from_org_id

        IF lx_ln_shipment_tbl.count > 0 THEN

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Create_Quote_Lines: Before Validate_ship_from_org_ID', 1, 'Y');
                aso_debug_pub.add('Create_Quote_Lines: lx_qte_line_rec.quote_header_id:        '||lx_qte_line_rec.quote_header_id, 1, 'Y');
                aso_debug_pub.add('Create_Quote_Lines: lx_qte_line_rec.quote_line_id:          '||lx_qte_line_rec.quote_line_id, 1, 'Y');
                aso_debug_pub.add('Create_Quote_Lines: lx_ln_shipment_tbl(1).quote_line_id:    '||lx_ln_shipment_tbl(1).quote_line_id, 1, 'Y');
                aso_debug_pub.add('Create_Quote_Lines: lx_qte_line_rec.inventory_item_id:      '||lx_qte_line_rec.inventory_item_id, 1, 'Y');
                aso_debug_pub.add('Create_Quote_Lines: lx_ln_shipment_tbl(1).ship_from_org_id: '||lx_ln_shipment_tbl(1).ship_from_org_id, 1, 'Y');
            end if;

            IF lx_ln_shipment_tbl(1).ship_from_org_id IS NOT NULL AND lx_ln_shipment_tbl(1).ship_from_org_id <> FND_API.G_MISS_NUM THEN
			IF aso_debug_pub.g_debug_flag = 'Y' THEN
                		aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_Lines: before Validate_ship_from_org_ID', 1, 'Y');
			end if;
                ASO_VALIDATE_PVT.Validate_ship_from_org_ID(
                    P_qte_line_rec  => lx_qte_line_rec,
                    P_Shipment_rec  => lx_ln_shipment_tbl(1),
                    x_return_status => x_return_status);

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
                		aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_Lines:  after Validate_ship_from_org_ID', 1, 'Y');
			end if;
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    		aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_Lines:  after Validate_ship_from_org_ID: <> SUCCESS', 1, 'Y');
				end if;

                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SHIP_FROM_ORG_ID');
                        FND_MESSAGE.Set_Token('SHIP_FROM_ORG_ID', lx_ln_shipment_tbl(1).ship_from_org_id, FALSE);
                        FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', lx_qte_line_rec.inventory_item_id, FALSE);
                        FND_MSG_PUB.ADD;
                    END IF;

                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;

        ELSE

            l_hd_shipment_rec := NULL;

            l_hd_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(
                                     P_Qte_Header_Id => lx_qte_line_rec.quote_header_id,
                                     P_Qte_Line_Id   => NULL
                                 );

            IF l_hd_shipment_tbl.count = 1 THEN
                l_hd_shipment_rec := l_hd_shipment_tbl(1);
            END IF;

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
            	aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_Lines: before Validate_ship_from_org_ID: lx_qte_line_rec.quote_header_id:     '||lx_qte_line_rec.quote_header_id, 1, 'Y');
            	aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_Lines: before Validate_ship_from_org_ID: lx_qte_line_rec.inventory_item_id:   '||lx_qte_line_rec.inventory_item_id, 1, 'Y');
            	aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_Lines: before Validate_ship_from_org_ID: l_hd_shipment_rec.ship_from_org_id: '||l_hd_shipment_rec.ship_from_org_id, 1, 'Y');
		end if;

            IF l_hd_shipment_rec.ship_from_org_id IS NOT NULL AND l_hd_shipment_rec.ship_from_org_id <> FND_API.G_MISS_NUM THEN
			IF aso_debug_pub.g_debug_flag = 'Y' THEN
                		aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_Lines: before Validate_ship_from_org_ID (no ln_shipment_tbl)', 1, 'Y');
			end if;
                ASO_VALIDATE_PVT.Validate_ship_from_org_ID(
                    P_Qte_Line_rec  => lx_qte_line_rec,
                    P_Shipment_rec  => l_hd_shipment_rec,
                    x_return_status => x_return_status
                );

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
                		aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_Lines:  after Validate_ship_from_org_ID (no ln_shipment_tbl)', 1, 'Y');
			end if;
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_Lines:  after Validate_ship_from_org_ID: <> SUCCESS', 1, 'Y');
			end if;

                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SHIP_FROM_ORG_ID');
                        FND_MESSAGE.Set_Token('SHIP_FROM_ORG_ID', l_hd_shipment_rec.ship_from_org_id, FALSE);
                        FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', lx_qte_line_rec.inventory_item_id, FALSE);
                        FND_MSG_PUB.ADD;
                    END IF;

                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;

        END IF;

-- end new validation for ship_from_org_id


END IF;

   	IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 	aso_debug_pub.add('Create_Quote_lines - before populate_quote_line ', 1, 'Y');
	end if;

    Populate_Quote_Line(
    P_Qte_Line_Rec            => lx_qte_line_rec   ,
    P_Control_Rec             => l_Control_Rec    ,
    P_Payment_Tbl             => lx_ln_Payment_Tbl    ,
    P_Price_Adj_Tbl           => P_Price_Adj_Tbl  ,
    P_Qte_Line_Dtl_tbl        => P_Qte_line_dtl_tbl   ,
    P_Shipment_Tbl            => lx_ln_shipment_tbl       ,
    P_Tax_Detail_Tbl          => P_Tax_Detail_Tbl           ,
    P_Freight_Charge_Tbl      => P_Freight_Charge_Tbl   ,
    P_Price_Attributes_Tbl    => P_Price_Attributes_Tbl ,
    P_Price_Adj_Attr_Tbl      => P_Price_Adj_Attr_Tbl    ,
    P_Line_Attribs_Ext_Tbl    => P_Line_Attribs_Ext_Tbl ,
    P_Sales_Credit_Tbl        => P_sales_credit_tbl,
    P_Quote_Party_Tbl         => P_quote_party_tbl,
    P_Operation_Code          => 'CREATE' ,
    X_Qte_Line_Rec            => l_Qte_Line_Rec   ,
    X_Payment_Tbl             => l_Payment_Tbl    ,
    X_Price_Adj_Tbl           => l_Price_Adj_Tbl  ,
    X_Qte_Line_Dtl_tbl        => l_Qte_Line_Dtl_tbl   ,
    X_Shipment_Tbl            => l_Shipment_Tbl       ,
    X_Tax_Detail_Tbl          => l_Tax_Detail_Tbl    ,
    X_Freight_Charge_Tbl      => l_Freight_Charge_Tbl       ,
    X_Price_Attributes_Tbl    => l_Price_Attributes_Tbl      ,
    X_Price_Adj_Attr_Tbl      => l_Price_Adj_Attr_Tbl ,
    X_Line_Attribs_Ext_Tbl    => l_Line_Attribs_Ext_Tbl,
    X_Sales_Credit_Tbl        => l_sales_credit_tbl,
    x_Quote_Party_Tbl         => l_quote_party_tbl,
    X_Return_Status           => X_return_status,
    X_Msg_Count               => x_msg_count,
    X_Msg_Data                => x_msg_data );

   -- copy the payment tbl to another variable, since the payment tbl count may change becoz
   -- of the payment validation which is done later
   l_orig_payment_tbl := l_Payment_Tbl;

-- check return status
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Create_Quote_lines - after populate_quote_line '||x_return_status, 1, 'Y');
	end if;

    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('ASO', 'ASO_POPULATING_COLUMNS');
             FND_MESSAGE.Set_Token('LINE' , x_qte_line_rec.line_number, FALSE);
	     FND_MSG_PUB.ADD;
	    END IF;

       IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
       END IF;

      END IF;

      -- check if the item being added is a MDL and a Network Container
      -- if so, then it must be published otherwise raise error
      open c_container_item_check(l_qte_line_rec.inventory_item_id, l_Qte_Line_Rec.organization_id);
      fetch c_container_item_check into l_container_item_flag;
      close c_container_item_check;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          ASO_DEBUG_PUB.add(' l_container_item_flag  = '|| l_container_item_flag , 1, 'Y');
      END IF;


      IF ( l_qte_line_rec.item_type_code = 'MDL' and l_container_item_flag = 'N' ) THEN

         -- call the cz api to check if the model is published
       l_is_model_published :=  CZ_CF_API.ui_for_item(inventory_item_id     => l_qte_line_rec.inventory_item_id,
                                                      organization_id       => l_Qte_Line_Rec.organization_id,
                                                      config_creation_date  => sysdate  ,
                                                      ui_type               => 'DHTML',
                                                      user_id               => FND_API.G_MISS_NUM,
                                                      responsibility_id     => FND_PROFILE.value('RESP_ID'),
                                                      calling_application_id => fnd_profile.VALUE('RESP_APPL_ID')
                                                      );

         IF  (l_is_model_published is null or l_is_model_published = 101 ) THEN
         --cz_cf_api.NATIVEBOM_UI_DEF
            -- this means the model is not published , raise error
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                      FND_MESSAGE.Set_Name('ASO', 'ASO_NO_CFG_UI');
                      FND_MSG_PUB.ADD;
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

          --inter entity validations

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 	aso_debug_pub.add('ASO_QUOTE_LINES_PVT: CREATE_QUOTE_LINES: Begin Inter entity validations');
	end if;

      IF p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_ENTITY THEN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
		ASO_DEBUG_PUB.add('cq organization_id  = '||nvl(to_char(l_Qte_Line_Rec.organization_id),'null') , 1, 'Y');
		ASO_DEBUG_PUB.add('cq Inventory_item_id  = '||l_qte_line_rec.inventory_item_id, 1, 'Y');
	END IF;

      -- validate inventory item id. item should be active
            ASO_VALIDATE_PVT.Validate_Inventory_Item(
		p_init_msg_list => FND_API.G_FALSE,
		p_inventory_item_id => l_qte_line_rec.inventory_item_id,
        p_organization_id   => l_Qte_Line_Rec.organization_id,
		x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);
	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

       -- bug 5196952 validate the ship method code
       if   (l_Shipment_Tbl.count > 0 ) then

	   IF (l_Shipment_Tbl(1).ship_method_code is not null and l_Shipment_Tbl(1).ship_method_code <> fnd_api.g_miss_char) then

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Create_Quote_lines - before validate ship_method_code ', 1, 'N');
          end if;
         ASO_VALIDATE_PVT.validate_ship_method_code
         (
          p_init_msg_list          => fnd_api.g_false,
          p_qte_header_id          => fnd_api.g_miss_num,
          p_qte_line_id            => fnd_api.g_miss_num,
          p_organization_id        => lx_qte_line_rec.organization_id,
          p_ship_method_code       => l_Shipment_Tbl(1).ship_method_code,
          p_operation_code         => 'CREATE',
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data);

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Create_Quote_lines - After validate ship_method_code ', 1, 'N');
          end if;

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
        end if;  -- end if for ship method code check
       end if; -- end if for the ship tbl count


          FOR i in 1..p_qte_line_dtl_tbl.count LOOP

	         ASO_VALIDATE_PVT.Validate_Service(
		            p_init_msg_list		     => FND_API.G_FALSE,
		            p_inventory_item_id         => l_qte_line_rec.inventory_item_id,
        	            p_start_date_active         => l_qte_line_rec.start_date_active,
        	            p_end_date_active           => l_qte_line_rec.end_date_active,
        	            p_service_duration          => p_qte_line_dtl_tbl(i).service_duration,
        	            p_service_period            => p_qte_line_dtl_tbl(i).service_period,
        	            p_service_coterminate_flag  => p_qte_line_dtl_tbl(i).service_coterminate_flag,
        	            p_organization_id           => l_Qte_Line_Rec.organization_id,
		            x_return_status             => x_return_status,
                      x_msg_count                 => x_msg_count,
                      x_msg_data                  => x_msg_data);

	         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                 FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
                      FND_MESSAGE.Set_Token('INFO','SERVICE', FALSE);
	                 FND_MSG_PUB.ADD;
	             END IF;

                  RAISE FND_API.G_EXC_ERROR;

              END IF;


              --validate service period

              ASO_VALIDATE_PVT.Validate_UOM_code(
		         p_init_msg_list	     => FND_API.G_FALSE,
		         p_uom_code           => p_qte_line_dtl_tbl(i).service_period,
                   p_organization_id    => l_qte_line_rec.organization_id,
                   p_inventory_item_id  => l_qte_line_rec.inventory_item_id,
		         x_return_status      => x_return_status,
                   x_msg_count          => x_msg_count,
                   x_msg_data           => x_msg_data);

	         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;


              --New code for Bug # 2498942 fix

              IF p_qte_line_dtl_tbl(i).service_ref_type_code = 'QUOTE'
                   AND p_qte_line_dtl_tbl(i).service_ref_line_id IS NOT NULL
                   AND p_qte_line_dtl_tbl(i).service_ref_line_id <> FND_API.G_MISS_NUM THEN

                     OPEN C_line_category_code(p_qte_line_dtl_tbl(i).service_ref_line_id);
                     FETCH C_line_category_code INTO l_line_category_code;

                     IF C_line_category_code%FOUND AND l_line_category_code = 'RETURN' THEN

                          CLOSE C_line_category_code;

                          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                         FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SERVICE_REFERENCE');
                              FND_MSG_PUB.ADD;
	                     END IF;

                          RAISE FND_API.G_EXC_ERROR;

                     END IF;

                     CLOSE C_line_category_code;

              END IF;


		    --New code for Bug#3280130

		    if p_qte_line_dtl_tbl(i).service_ref_line_id is not null and
		       p_qte_line_dtl_tbl(i).service_ref_line_id <> fnd_api.g_miss_num then

			  if p_qte_line_dtl_tbl(i).service_ref_type_code is null or
			     p_qte_line_dtl_tbl(i).service_ref_type_code = fnd_api.g_miss_char then

                    x_return_status := fnd_api.g_ret_sts_error;

                    IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                       FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                       FND_MESSAGE.Set_Token('COLUMN', 'SERVICE_REF_TYPE_CODE', FALSE);
                       FND_MESSAGE.Set_Token('VALUE', p_qte_line_dtl_tbl(i).service_ref_type_code,FALSE);
                       FND_MSG_PUB.ADD;
                    END IF;

                    raise fnd_api.g_exc_error;

                 else

	               if aso_debug_pub.g_debug_flag = 'Y' then
                       aso_debug_pub.add('CREATE_QUOTE_LINES: Before calling aso_validate_pvt.validate_service_ref_line_id');
                    end if;

                    aso_validate_pvt.validate_service_ref_line_id (
                                    p_init_msg_list         => fnd_api.g_false,
                                    p_service_ref_type_code => p_qte_line_dtl_tbl(i).service_ref_type_code,
                                    p_service_ref_line_id   => p_qte_line_dtl_tbl(i).service_ref_line_id,
                                    p_qte_header_id         => l_qte_line_rec.quote_header_id,
                                    x_return_status         => x_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data);

	               if aso_debug_pub.g_debug_flag = 'Y' then
                       aso_debug_pub.add('CREATE_QUOTE_LINES: After calling aso_validate_pvt.validate_service_ref_line_id');
                       aso_debug_pub.add('CREATE_QUOTE_LINES: x_return_status: '|| x_return_status);
                    end if;

	               if x_return_status <> fnd_api.g_ret_sts_success then
                       raise fnd_api.g_exc_error;
                    end if;

                 end if;

              end if;

		    --End new code for Bug#3280130

          END LOOP;

      END IF;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 	aso_debug_pub.add('ASO_QUOTE_LINES_PVT: CREATE_QUOTE_LINES: End of Inter entity validations');
	end if;


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	          FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
	          FND_MSG_PUB.ADD;
	      END IF;

           RAISE FND_API.G_EXC_ERROR;

      END IF;


         l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row(l_qte_line_rec.QUOTE_HEADER_ID);

-- IF NVL(FND_PROFILE.value('ASO_TCA_VALIDATE'),'N') = 'Y' THEN
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Validation level is set',1,'N');
	end if;

    ASO_CHECK_TCA_PVT.check_line_account_info(
        p_api_version         => 1.0,
        p_init_msg_list       => FND_API.G_FALSE,
        p_cust_account_id     => l_qte_header_rec.cust_account_id,
        p_qte_line_rec        => l_qte_line_rec,
        p_line_shipment_tbl   => l_shipment_tbl,
        p_application_type_code      => l_control_rec.application_type_code,
        x_return_status       => l_return_status,
        x_msg_count           => l_msg_count,
        x_msg_data            => l_msg_data );

    IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;
-- END IF;

    ASO_TRADEIN_PVT.LineType(
               p_init_msg_list => FND_API.G_FALSE,
     p_qte_header_rec  => l_qte_header_rec,
     p_qte_line_rec        => l_qte_line_rec,
       x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data);

	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('after order type'||  x_return_status, 1, 'Y');
          END IF;


          If (p_qte_header_rec.order_type_id = FND_API.G_MISS_NUM )then -- [This is for backward compatibility]
	           l_db_order_type_id  := l_qte_header_rec.order_type_id;
          else
	           l_db_order_type_id  :=  p_qte_header_rec.order_type_id;
          end if;

		  If (l_db_order_type_id  = l_qte_header_rec.order_type_id) and (l_qte_line_rec.order_line_type_id <> FND_API.G_MISS_NUM) then
                ASO_validate_PVT.Validate_ln_type_for_ord_type(
                p_init_msg_list     =>   FND_API.G_FALSE,
                p_qte_header_rec    =>   l_qte_header_rec,
                P_Qte_Line_rec      =>   l_qte_line_rec,
                x_return_status     =>   x_return_status,
                x_msg_count         =>   x_msg_count,
                x_msg_data          =>   x_msg_data);

                IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
		  End if;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('x_return_status for Validate_ln_type_for_ord_type'||  x_return_status, 1, 'Y');
          END IF;

          aso_validate_pvt.Validate_po_line_number
		(
			p_init_msg_list	  => fnd_api.g_false,
			p_qte_header_rec    => l_qte_header_rec,
			P_Qte_Line_rec	  => l_qte_line_rec,
			x_return_status     => x_return_status,
			x_msg_count         => x_msg_count,
			x_msg_data          => x_msg_data);

		IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
            END IF;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('x_return_status for Validate_po_line_number'||  x_return_status, 1, 'Y');
          END IF;


   ASO_TRADEIN_PVT.Validate_Line_Tradein(
       p_init_msg_list      =>   FND_API.G_FALSE,
       p_qte_header_rec         =>   l_qte_header_rec,
     P_Qte_Line_rec             =>   l_qte_line_rec,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data);

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
       END IF;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_QUOTE_LINES Create_Quote_lines - after validate_line_tradein '||x_return_status, 1, 'Y');
	end if;

   ASO_TRADEIN_PVT.Validate_IB_Return_Qty(
            p_init_msg_list      =>   FND_API.G_FALSE,
            p_Qte_Line_rec       =>   l_qte_line_rec,
            p_Qte_Line_Dtl_Tbl   =>   l_qte_line_dtl_tbl,
            x_return_status      =>   x_return_status,
            x_msg_count          =>   x_msg_count,
            x_msg_data           =>   x_msg_data);

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
       END IF;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_QUOTE_LINES Create_Quote_lines - after validate_IB_Return_Qty '||x_return_status, 1, 'Y');
	end if;

    IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN
        ASO_VALIDATE_PVT.Validate_Sales_Credit_Return(
            p_init_msg_list             => FND_API.G_FALSE,
            p_sales_credit_tbl          => p_sales_credit_tbl,
            p_qte_line_rec              => l_qte_line_rec,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data);
        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

-- EDU
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Create_Quote_Line - before Validate_Agreement:l_qte_line_rec.Agreement_Id: '||l_qte_line_rec.Agreement_Id, 1, 'N');
	end if;

     IF (l_qte_line_rec.Agreement_Id IS NOT NULL AND
        l_qte_line_rec.Agreement_Id <> FND_API.G_MISS_NUM) THEN
          ASO_VALIDATE_PVT.Validate_Agreement(
               p_init_msg_list             => FND_API.G_FALSE,
               P_Agreement_Id              => l_qte_line_rec.Agreement_Id,
               x_return_status             => x_return_status,
               x_msg_count                 => x_msg_count,
               x_msg_data                  => x_msg_data);
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('Create_Quote_Line - after Validate_Agreement:x_return_status: '||x_return_status, 1, 'N');
		end if;

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
          END IF;
     END IF;
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('Create_Quote - after Validate_Agreement:l_qte_line_rec.UOM_Code: '||l_qte_line_rec.UOM_Code,1, 'N');
			aso_debug_pub.add('Create_Quote - after Validate_Agreement:l_qte_line_rec.Quantity: '||l_qte_line_rec.Quantity,1, 'N');
		end if;
     IF l_qte_line_rec.UOM_Code = 'ENR' THEN
          IF l_qte_line_rec.Quantity <> 1 THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_EDU_INVALID_QTY');
                    FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
          END IF;
     END IF;
-- EDU

    -- Validate the invoice to cust party id and payment info, if any
     IF l_payment_tbl.count = 0   then
        l_payment_tbl := aso_utility_pvt.Query_Payment_Rows( p_qte_line_rec.QUOTE_HEADER_ID,p_qte_line_rec.quote_line_id);
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before  calling Validate_cc_info payment_tbl count is: '|| l_payment_tbl.count, 1, 'Y');
           END IF;
     End if;

     IF l_payment_tbl.count > 0 then
          l_payment_rec := l_payment_tbl(1);
        IF l_payment_rec.payment_type_code = 'CREDIT_CARD' THEN
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before  calling Validate_cc_info ', 1, 'Y');
           END IF;
           l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row (p_qte_line_rec.Quote_Header_Id );

           aso_validate_pvt.Validate_cc_info
            (
                p_init_msg_list     =>  fnd_api.g_false,
                p_payment_rec       =>  l_payment_rec,
                p_qte_header_rec    =>  l_qte_header_rec,
                P_Qte_Line_rec      =>  p_qte_line_rec,
                x_return_status     =>  x_return_status,
                x_msg_count         =>  x_msg_count,
                x_msg_data          =>  x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after calling Validate_cc_info ', 1, 'Y');
              aso_debug_pub.add('Validate_cc_info  Return Status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;
        END IF;

      End if;
   -- the payment tbl count may have been changed, hence re-set back the value
   l_Payment_Tbl := l_orig_payment_tbl ;

  Insert_Quote_Line_Rows(
    P_Qte_Line_Rec      =>  l_Qte_Line_Rec   ,
    P_Control_Rec       =>  l_Control_Rec    ,
    P_Payment_Tbl       =>  l_Payment_Tbl    ,
    P_Price_Adj_Tbl     =>  l_Price_Adj_Tbl  ,
    P_Qte_Line_Dtl_tbl  =>  l_Qte_Line_Dtl_tbl  ,
    P_Shipment_Tbl      =>  l_Shipment_Tbl       ,
    P_Tax_Detail_Tbl    =>  l_Tax_Detail_Tbl           ,
    P_Freight_Charge_Tbl     => l_Freight_Charge_Tbl   ,
    P_Price_Attributes_Tbl   => l_Price_Attributes_Tbl ,
    P_Price_Adj_Attr_Tbl      => l_Price_Adj_Attr_Tbl    ,
    P_Line_Attribs_Ext_Tbl    => l_Line_Attribs_Ext_Tbl,
    P_Sales_Credit_Tbl        => l_sales_credit_tbl,
    P_Quote_Party_Tbl        => l_quote_party_tbl,
    X_Qte_Line_Rec      =>  X_Qte_Line_Rec   ,
    X_Payment_Tbl       =>  X_Payment_Tbl    ,
    X_Price_Adj_Tbl     =>  X_Price_Adj_Tbl  ,
    X_Qte_Line_Dtl_tbl  =>  X_Qte_Line_Dtl_tbl   ,
    X_Shipment_Tbl      =>  X_Shipment_Tbl       ,
    X_Tax_Detail_Tbl   =>  X_Tax_Detail_Tbl    ,
    X_Freight_Charge_Tbl     => X_Freight_Charge_Tbl       ,
    X_Price_Attributes_Tbl   => X_Price_Attributes_Tbl      ,
    X_Price_Adj_Attr_Tbl      => X_Price_Adj_Attr_Tbl ,
    X_Line_Attribs_Ext_Tbl   => X_Line_Attribs_Ext_Tbl,
    X_Sales_Credit_Tbl        =>x_sales_credit_tbl,
    X_Quote_Party_Tbl         =>x_quote_party_tbl,
    X_Return_Status          => X_return_status,
    X_Msg_Count              => x_msg_count,
    X_Msg_Data               => x_msg_data
    );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('ASO', 'ASO_INSERT_ERROR');
	     FND_MSG_PUB.ADD;
	    END IF;
       IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
       END IF;
      END IF;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Create_Quote_lines - after insert_quote_line_rows '||x_return_status, 1, 'Y');
	end if;

     -- Service line quantity update Bmishra 01/09/02
     l_call_update := FND_API.G_FALSE;
     OPEN c_service (X_Qte_Line_Rec.quote_line_id);

     FETCH c_service INTO l_service_item_flag, l_serviceable_product_flag;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_lines: l_service_item_flag'||l_service_item_flag,1, 'N');
		aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_lines: l_serviceable_product_flag'||l_serviceable_product_flag,1, 'N');
	end if;
     IF c_service%FOUND THEN
       CLOSE c_service;
       IF l_service_item_flag = 'Y' THEN
          l_service := FND_API.G_TRUE;
          l_call_update := FND_API.G_TRUE;
       ELSIF l_serviceable_product_flag = 'Y' THEN
          l_service := FND_API.G_FALSE;
          l_call_update := FND_API.G_TRUE;
       END IF;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Create_Quote_lines: l_call_update'||l_call_update,1, 'N');
	end if;

       IF l_call_update = FND_API.G_TRUE THEN
          ASO_QUOTE_LINES_PVT.service_item_qty_update
           (p_qte_line_rec  => X_Qte_Line_Rec ,
            p_service_item_flag  => l_service,
            x_return_status => X_return_status
            );
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
            	aso_debug_pub.add('Create_Quote_lines - after call to ASO_QUOTE_LINES_PVT.service_item_qty_update '|| x_return_status, 1, 'Y');
		end if;
       END IF;
     ELSE
       CLOSE c_service;
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
       		aso_debug_pub.add('Create_quote_lines, Item not found in inventry',1,'N');
		end if;
   END IF;


-- sales credits
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Quote_Percent: BEFORE: X_Qte_Line_Rec.quote_header_id: '||X_Qte_Line_Rec.quote_header_id,1,'N');
            aso_debug_pub.add('Validate_Quote_Percent: BEFORE: X_Qte_Line_Rec.quote_line_id:   '||X_Qte_Line_Rec.quote_line_id,1,'N');
	end if;

            IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN
                IF x_sales_credit_tbl.count > 0 THEN
                    IF x_sales_credit_tbl(1).quote_header_id IS NULL OR x_sales_credit_tbl(1).quote_header_id = FND_API.G_MISS_NUM THEN
                        x_sales_credit_tbl(1).quote_header_id := X_Qte_Line_Rec.quote_header_id;
                    END IF;
                    IF x_sales_credit_tbl(1).quote_line_id IS NULL OR x_sales_credit_tbl(1).quote_line_id = FND_API.G_MISS_NUM THEN
                        x_sales_credit_tbl(1).quote_line_id := X_Qte_Line_Rec.quote_line_id;
                    END IF;

       	            ASO_VALIDATE_PVT.Validate_Quote_Percent(
                        p_init_msg_list             => FND_API.G_FALSE,
                        p_sales_credit_tbl          => x_sales_credit_tbl,
                        x_return_status             => x_return_status,
                        x_msg_count                 => x_msg_count,
                        x_msg_data                  => x_msg_data
                    );
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END IF;
            END IF;

-- end sales credits


   IF  l_control_rec.line_pricing_event IS NOT NULL AND
        l_control_rec.line_pricing_event <> FND_API.G_MISS_CHAR  THEN

       -- call pricing engine

      l_pricing_control_rec.pricing_event := l_control_rec.line_pricing_event;
      l_pricing_control_rec.request_type  := l_control_rec.pricing_request_type;
      l_pricing_control_rec.price_mode    := l_control_rec.price_mode;

      l_qte_line_tbl(1)                   := l_qte_line_rec;

      --New Code to call overload pricing_order

        l_hd_price_attr_tbl := aso_utility_pvt.query_price_attr_rows(l_qte_header_rec.quote_header_id,null);
        l_hd_shipment_tbl   := aso_utility_pvt.query_shipment_rows(l_qte_header_rec.quote_header_id,null);

        if l_hd_shipment_tbl.count = 1 then
            l_hd_shipment_rec := l_hd_shipment_tbl(1);
        end if;


        ASO_PRICING_INT.Pricing_Order(
                    P_Api_Version_Number     => 1.0,
                    P_Init_Msg_List          => fnd_api.g_false,
                    P_Commit                 => fnd_api.g_false,
                    p_control_rec            => l_pricing_control_rec,
                    p_qte_header_rec         => l_qte_header_rec,
                    p_hd_shipment_rec        => l_hd_shipment_rec,
                    p_hd_price_attr_tbl      => l_hd_price_attr_tbl,
                    p_qte_line_tbl           => l_qte_line_tbl,
                    x_qte_header_rec         => lx_qte_header_rec,
                    x_qte_line_tbl           => lx_qte_line_tbl,
                    x_qte_line_dtl_tbl       => lx_qte_line_dtl_tbl,
                    x_price_adj_tbl          => lx_price_adj_tbl,
                    x_price_adj_attr_tbl     => lx_price_adj_attr_tbl,
                    x_price_adj_rltship_tbl  => lx_price_adj_rltship_tbl,
                    x_return_status          => x_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data );

         if lx_qte_line_tbl.count > 0 then
             x_qte_line_rec  :=  lx_qte_line_tbl(1);
         end if;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

          IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

          ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN

               RAISE FND_API.G_EXC_ERROR;

          END IF;

      END IF;


   END IF;        -- pricing

/*
 *
 *
IF l_control_rec.CALCULATE_TAX_FLAG = 'Y'THEN
      l_tax_control_rec.tax_level := 'SHIPPING';
      l_tax_control_rec.update_db := 'Y' ;  --FND_API.G_TRUE;

      l_tax_detail_rec.quote_header_id := l_qte_line_rec.quote_header_id;
      l_tax_detail_rec.quote_line_id := l_qte_line_rec.quote_line_id;

-- added to calc tax based on accounts
        OPEN get_cust_acct( l_qte_line_rec.QUOTE_HEADER_ID);
        FETCH get_cust_acct into l_cust_acct;
        IF get_cust_acct%NOTFOUND THEN
          NULL;
        END IF;
        CLOSE get_cust_acct;

        IF( l_qte_line_rec.invoice_to_party_site_id is not NULL
      AND l_qte_line_rec.invoice_to_party_site_id <> FND_API.G_MISS_NUM )
      AND (l_cust_Acct is NOT NULL AND l_cust_acct <>  FND_API.G_MISS_NUM) THEN

          ASO_PARTY_INT.GET_ACCT_SITE_USES (
  		  p_api_version     => 1.0
 		 ,P_Cust_Account_Id => l_cust_acct
 		 ,P_Party_Site_Id   => l_qte_line_rec.invoice_to_party_site_id
	         ,P_Acct_Site_type  => 'BILL_TO'
 		 ,x_return_status   => l_return_status
 		 ,x_msg_count       => l_msg_count
 		 ,x_msg_data        => l_msg_data
 		 ,x_site_use_id     => l_invoice_org_id
  	   );
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
  		aso_debug_pub.add('Create_Quote_lines - after create_acct_site_uses- invoice_org_id: '||nvl(to_char(l_invoice_org_id),'null'), 1, 'N');
	end if;
              IF L_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                  FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
                  FND_MESSAGE.Set_Token('COLUMN', 'INVOICE_TO_SITE_USE_ID',FALSE);
                  FND_MSG_PUB.ADD;
                END IF;
               -- raise FND_API.G_EXC_ERROR;
              END IF;
      END IF;

lx_tax_shipment_tbl :=  ASO_UTILITY_PVT.Query_Shipment_Rows(l_qte_line_rec.quote_header_id,x_qte_line_rec.quote_line_id);

      FOR i in 1..lx_tax_shipment_tbl.count LOOP
         l_tax_detail_rec.quote_shipment_id := lx_tax_shipment_tbl(i).shipment_id;

         IF (lx_tax_shipment_tbl(i).ship_to_party_site_id is not NULL           AND lx_tax_shipment_tbl(i).ship_to_party_site_id <> FND_API.G_MISS_NUM)
 AND(l_cust_acct is NOT NULL AND l_cust_acct <> FND_API.G_MISS_NUM )
          THEN
           ASO_PARTY_INT.GET_ACCT_SITE_USES (
  		  p_api_version     => 1.0
 		 ,P_Cust_Account_Id => l_cust_acct
 		 ,P_Party_Site_Id   =>  lx_tax_shipment_tbl(i).ship_to_party_site_id
	         ,P_Acct_Site_type  => 'SHIP_TO'
 		 ,x_return_status   => l_return_status
 		 ,x_msg_count       => l_msg_count
 		 ,x_msg_data        => l_msg_data
 		 ,x_site_use_id     => l_ship_org_id
  	   );

              IF L_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                  FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
                  FND_MESSAGE.Set_Token('COLUMN', 'INVOICE_TO_SITE_USE_ID',FALSE);
                  FND_MSG_PUB.ADD;
                END IF;
               -- raise FND_API.G_EXC_ERROR;
              END IF;

    END IF;

	ASO_TAX_INT.Calculate_Tax(
         P_Api_Version_Number => 1.0,
         p_quote_header_id    => l_qte_line_rec.quote_header_id,
         P_Tax_Control_Rec    => l_tax_control_rec,
         x_tax_amount	     => x_tax_amount    ,
         x_tax_detail_tbl    => l_tax_detail_tbl,
         X_Return_Status     => x_return_status ,
         X_Msg_Count         => x_msg_count     ,
        X_Msg_Data           => x_msg_data      );


		IF aso_debug_pub.g_debug_flag = 'Y' THEN
  			aso_debug_pub.add('Create_Quote_lines - after_calculate_tax- tax_amount: '||nvl(to_char(x_tax_amount),'null'), 1, 'N');
		end if;

          if l_tax_detail_tbl.count > 0 then
           x_tax_detail_tbl(i) := l_tax_detail_tbl(1);
          end if;

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_TAX_CALCULATION');
	        FND_MSG_PUB.ADD;
	       END IF;
           IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
      END LOOP;

   END IF;

*
*/

-- check the profile option for reservation and create reservation if needed

    IF FND_PROFILE.Value('ASO_RESERVATION_LEVEL') = 'AUTO_CART' THEN
       l_shipment_tbl := x_shipment_tbl;

     OPEN c_reservation(x_qte_line_rec.inventory_item_id,x_qte_line_rec.organization_id);
     FETCH c_reservation INTO l_inv_item,l_organization_id;
     IF c_reservation%FOUND THEN

     FOR i in 1..l_shipment_tbl.count LOOP
       ASO_RESERVATION_INT.Create_reservation(
         P_Api_Version_Number   => 1.0,
         p_line_rec             => x_qte_line_rec,
         p_shipment_rec         => l_shipment_tbl(i),
         X_Return_Status        => x_return_status,
         X_Msg_Count            => x_msg_count,
         X_Msg_Data             => x_msg_data,
         X_quantity_reserved    => l_shipment_tbl_out(i).reserved_quantity,
         X_reservation_id       => l_shipment_tbl_out(i).reservation_id
      );

	    l_shipment_tbl(i).reserved_quantity := l_shipment_tbl_out(i).reserved_quantity;
	    l_shipment_tbl(i).reservation_id := l_shipment_tbl_out(i).reservation_id;


         UPDATE ASO_SHIPMENTS
         SET reservation_id     =  l_shipment_tbl(i).reservation_id,
             reserved_quantity  =  l_shipment_tbl(i).reserved_quantity,
             last_update_date   =  sysdate,
             last_updated_by    =  fnd_global.user_id,
             last_update_login  =  fnd_global.conc_login_id
         WHERE shipment_id     = l_shipment_tbl(i).shipment_id;

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('ASO', 'ASO_CREATING_RESERVATION');
             FND_MESSAGE.Set_Token('LINE' , x_qte_line_rec.line_number, FALSE);
	     FND_MSG_PUB.ADD;
	    END IF;
           IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;


      END LOOP;

     END IF;
     CLOSE c_reservation;
    END IF;  --automatic reservation


    IF p_update_header_flag = 'Y' THEN

      -- Update Quote total info (do summation to get TOTAL_LIST_PRICE,
      -- TOTAL_ADJUSTED_AMOUNT, TOTAL_TAX, TOTAL_SHIPPING_CHARGE, SURCHARGE,
      -- TOTAL_QUOTE_PRICE, PAYMENT_AMOUNT)
      -- IF calculate_tax_flag = 'N', not summation on line level tax,
      -- just take the value of p_qte_rec.total_tax as the total_tax
      -- IF calculate_Freight_Charge = 'N', not summation on line level freight charge,
      -- just take the value of p_qte_rec.total_freight_charge
      -- how can i get the calc_tax_flag and calc_freight_charge_flag ??

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Create_Quote_lines - before update_quote_total '||l_return_status, 1, 'Y');
	end if;

       ASO_QUOTE_HEADERS_PVT.Update_Quote_Total (
	P_Qte_Header_id		=> x_Qte_line_rec.quote_header_id,
        P_calculate_tax         => l_control_rec.CALCULATE_TAX_FLAG,
        P_calculate_freight_charge=> l_control_rec.calculate_freight_charge_flag,
            p_control_rec		 =>  l_control_rec,
	X_Return_Status         => l_return_status,
	X_Msg_Count		=> x_msg_count,
	X_Msg_Data              => x_msg_data);

           IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
 	     FND_MESSAGE.Set_Name('ASO', 'ASO_UPDATE_QUOTE_TOTAL');
          -- FND_MESSAGE.Set_Token('LINE' , x_qte_line_rec.line_number, FALSE);
 	     FND_MSG_PUB.ADD;
 	    END IF;
          END IF;


    IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
 	     FND_MESSAGE.Set_Name('ASO', 'ASO_UPDATE_QUOTE_TOTAL');
          -- FND_MESSAGE.Set_Token('LINE' , x_qte_line_rec.line_number, FALSE);
 	     FND_MSG_PUB.ADD;
 	    END IF;
          END IF;

      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

	-- Change START
	-- Release 12 TAP Changes
	-- Girish Sachdeva 8/30/2005
	-- Adding the call to insert record in the ASO_CHANGED_QUOTES

	SELECT quote_number
	INTO   l_quote_number
	FROM   aso_quote_headers_all -- bug 8968033
	WHERE  quote_header_id = x_Qte_line_rec.quote_header_id ;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_QUOTE_LINES_PVT.Create_Quote_lines : Calling ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES, quote number : ' || l_quote_number, 1, 'Y');
	END IF;

	-- Call to insert record in ASO_CHANGED_QUOTES
	ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES(l_quote_number);

	-- Change END


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



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
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

End Create_quote_lines;




--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_qte_lines_Rec     IN    qte_line_Rec_Type         Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
--       P_Payment_Tbl       IN    Payment_Tbl_Type
--       P_Price_Adj_Tbl     IN    Price_Adj_Tbl_Type
--       P_Qte_Line_Dtl_Rec  IN    Qte_Line_Dtl_Rec_Type
--       P_Shipment_Tbl      IN    Shipment_Tbl_Type
--       P_Tax_Details_Tbl      IN    Tax_Details_Tbl_Type
--       P_Freight_Charges_Tbl  IN    Freight_Charges_Tbl_Type
--       P_Line_Relationship_Tbl IN   Line_Relationship_Tbl_Type
--       P_Price_Attributes_Tbl  IN   Price_Attributes_Tbl_Type
--       P_Price_Adj_Relationship_Tbl IN Price_Adj_Relationship_Tbl_Type
--       P_Update_Header_Flag    IN   VARCHAR2     Optional  Default = FND_API.G_TRUE
--   OUT:
--       X_quote_line_id     OUT NOCOPY /* file.sql.39 change */ NUMBER,
--       x_return_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */ NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.

PROCEDURE Update_Quote_Line(
    P_Api_Version_Number    IN   NUMBER,
    P_Init_Msg_List         IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Commit                IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Validation_Level 	   IN   NUMBER                                  := FND_API.G_VALID_LEVEL_FULL,
    P_Qte_Header_Rec        IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type       := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Qte_Line_Rec          IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type         := ASO_QUOTE_PUB.G_MISS_qte_line_REC,
    P_Control_REC           IN   ASO_QUOTE_PUB.Control_Rec_Type          := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    P_Payment_Tbl           IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Price_Adj_Tbl         IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type        := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Qte_Line_Dtl_tbl      IN   ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type     := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Shipment_Tbl          IN   ASO_QUOTE_PUB.Shipment_Tbl_Type         := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl        IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl    IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_freight_charge_TBL,
    P_Price_Attributes_Tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type   := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Attribs_Ext_Tbl  IN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type := ASO_QUOTE_PUB.G_Miss_Line_Attribs_Ext_Tbl,
    P_Sales_Credit_Tbl      IN   ASO_QUOTE_PUB.Sales_Credit_Tbl_Type     := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl,
    P_Quote_Party_Tbl       IN   ASO_QUOTE_PUB.Quote_Party_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl,
    P_Update_Header_Flag    IN   VARCHAR2                                := 'Y',
    X_Qte_Line_Rec          OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    X_Payment_Tbl           OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_Price_Adj_Tbl         OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Qte_Line_Dtl_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
    X_Shipment_Tbl          OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Quote_Party_Tbl_Type,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
  G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
  G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
  l_Qte_Line_Dtl_tbl_local  ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type      ;
  Cursor C_Get_quote(c_QUOTE_LINE_ID Number) IS
  SELECT head.LAST_UPDATE_DATE, head.QUOTE_STATUS_ID, head.QUOTE_NUMBER,
         head.TOTAL_ADJUSTED_PERCENT,head.quote_expiration_date
  FROM  ASO_QUOTE_HEADERS_ALL head,
        ASO_QUOTE_LINES_ALL line
  WHERE head.QUOTE_HEADER_ID = line.QUOTE_HEADER_ID
  AND   line.QUOTE_LINE_ID = c_QUOTE_LINE_ID;

  CURSOR C_Qte_Status(c_qte_status_id NUMBER) IS
  SELECT UPDATE_ALLOWED_FLAG, AUTO_VERSION_FLAG FROM ASO_QUOTE_STATUSES_B
  WHERE quote_status_id = c_qte_status_id;

  CURSOR C_Qte_Version (X_qte_number NUMBER) IS
  SELECT max(quote_version)
  FROM ASO_QUOTE_HEADERS_ALL
  WHERE quote_number = X_qte_number;

  CURSOR C_Inst_Details (X_shipment_id NUMBER) IS
  SELECT sum(customer_product_quantity) FROM cs_line_inst_details
  WHERE quote_line_shipment_id = X_shipment_id;

  --  hyang csi change 1935614
  CURSOR C_CSI_Details (X_quote_line_id NUMBER) IS
  select b.quantity
  from csi_t_transaction_lines a, csi_t_txn_line_details b
  where a.source_transaction_table='ASO_QUOTE_LINES_ALL'
  and a.source_transaction_id = x_quote_line_id
  and a.transaction_line_id = b.transaction_line_id;

  CURSOR C_ship_partial (l_quote_line_id NUMBER) IS
  SELECT count(*)
  FROM aso_shipments
  WHERE quote_line_id = l_quote_line_id;

  CURSOR get_cust_acct(cust_QUOTE_HEADER_ID Number) IS
  SELECT CUST_ACCOUNT_ID
  FROM ASO_QUOTE_HEADERS_ALL
  WHERE QUOTE_HEADER_ID = cust_QUOTE_HEADER_ID;

  Cursor C_exp_date(c_QUOTE_HEADER_ID Number) IS
  Select quote_expiration_date
  From  ASO_QUOTE_HEADERS_ALL
  Where QUOTE_HEADER_ID = c_QUOTE_HEADER_ID;

  CURSOR C_org_id IS
  SELECT org_id
  FROM aso_quote_lines_all
  WHERE quote_line_id = p_qte_line_rec.quote_line_id;

  CURSOR c_inventory_item_id IS
  select inventory_item_id
  from aso_quote_lines_all
  where quote_line_id = P_Qte_Line_Rec.quote_line_id;

  cursor c_service (p_qln_id number)is
  select service_item_flag,serviceable_product_flag
  from aso_quote_lines_All
  where quote_line_id = p_qln_id;

  CURSOR C_qln_exist IS
  select quote_line_id  from aso_quote_lines_all
  where quote_line_id = p_qte_line_rec.quote_line_id;

  -- Cursor declaration for line_category_code and order_line_type_id change bug # 2208195
  cursor c_line_category_code(p_quote_line_id  NUMBER) is
  select line_category_code
  from aso_quote_lines_all
  where quote_line_id = p_quote_line_id;

  cursor c_order_line_type_id(p_quote_line_id  NUMBER) is
  select a.line_category_code, a.order_line_type_id, b.config_header_id, b.config_revision_num
  from aso_quote_lines_all a, aso_quote_line_details b
  where a.quote_line_id = b.quote_line_id
  and a.quote_line_id   = p_quote_line_id;

  cursor c_item_type_code is
  select item_type_code
  from aso_quote_lines_all
  where quote_line_id = p_qte_line_rec.quote_line_id;

  --New code for Bug # 2498942 fix

  cursor c_service_exist is
  select quote_line_id
  from aso_quote_line_details
  where service_ref_line_id = p_qte_line_rec.quote_line_id;

  --New Code for updating PBH

  cursor c_pbh( p_price_adjustment_id number ) is
  select price_adjustment_id
  from aso_price_adj_relationships a
  where a.price_adjustment_id = ( select price_adjustment_id
                                  from aso_price_adjustments b
                                  where a.price_adjustment_id = b.price_adjustment_id
                                  and b.MODIFIER_LINE_TYPE_CODE = 'PBH')
  and a.rltd_price_adj_id = p_price_adjustment_id;

  l_price_adjustment_id number;

  l_api_version_number       NUMBER           := 1.0;
  l_last_update_date         DATE;
  l_api_name                 VARCHAR2(50)     := 'Update_Quote_Line';
  l_Return_Status            VARCHAR2(50);
  l_Msg_Count                NUMBER;
  l_Msg_Data                 VARCHAR2(240);
  l_qte_status_id            NUMBER;
  l_update_allowed           VARCHAR2(1);
  l_auto_version             VARCHAR2(1);
  l_quote_number             NUMBER;
  l_old_header_rec           ASO_QUOTE_PUB.qte_header_rec_type;
  l_qte_header_rec           ASO_QUOTE_PUB.qte_header_rec_type;
  l_quote_version            NUMBER;
  x_quote_header_id          NUMBER;
  l_hd_discount_percent      NUMBER;
  header_id                  NUMBER;
  l_inventory_item_id        NUMBER;
  l_organization_id          NUMBER;
  l_ship_count               NUMBER;
  l_cust_acct                NUMBER;
  l_invoice_org_id           NUMBER;
  l_ship_org_id              NUMBER;
  l_org_id                   NUMBER;
  l_quote_exp_date           DATE;
  l_service_item_flag        varchar2(1);
  l_serviceable_product_flag varchar2(1);
  l_service                  varchar2(1);
  l_call_update              varchar2(1);
  l_qln_exist                NUMBER;
  l_line_category_code       varchar2(30);
  l_order_line_type_id       number;
  l_item_type_code           varchar2(30);
  l_config_header_id         number;
  l_config_revision_num      number;
  l_db_order_type_id         number;

  l_Qte_Line_Rec          ASO_QUOTE_PUB.Qte_Line_Rec_Type          := ASO_QUOTE_PUB.G_MISS_qte_line_REC;
  l_Payment_Tbl           ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_Payment_TBL;
  l_Price_Adj_Tbl         ASO_QUOTE_PUB.Price_Adj_Tbl_Type         := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL;
  l_Qte_Line_Dtl_rec      ASO_QUOTE_PUB.Qte_Line_Dtl_rec_Type      := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_REC;
  l_Shipment_Tbl          ASO_QUOTE_PUB.Shipment_Tbl_Type          := ASO_QUOTE_PUB.G_MISS_shipment_TBL;
  l_Tax_Detail_Tbl        ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_MISS_tax_detail_TBL;
  l_Freight_Charge_Tbl    ASO_QUOTE_PUB.Freight_Charge_Tbl_Type    := ASO_QUOTE_PUB.G_MISS_freight_charge_TBL;
  l_Line_Rltship_Tbl      ASO_QUOTE_PUB.Line_Rltship_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_line_rltship_TBL;
  l_Price_Attributes_Tbl  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type  := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL;
  l_Price_Adj_rltship_Tbl ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL;
  l_Price_Adj_Attr_Tbl    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type    := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl;
  l_Line_Attribs_Ext_Tbl  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type  := ASO_QUOTE_PUB.G_Miss_Line_Attribs_Ext_Tbl;
  l_Qte_Line_Dtl_tbl      ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type      := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL;
  l_Sales_Credit_Tbl      ASO_QUOTE_PUB.Sales_Credit_Tbl_Type      := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl;
  l_Quote_Party_Tbl       ASO_QUOTE_PUB.Quote_Party_Tbl_Type       := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl;
  l_qte_line_tbl          ASO_QUOTE_PUB.Qte_Line_tbl_Type          := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;

  l_price_attributes_rec  ASO_QUOTE_PUB.Price_Attributes_Rec_Type;
  l_price_adj_rec         ASO_QUOTE_PUB.Price_Adj_Rec_Type;
  l_Price_Adj_Attr_rec    ASO_QUOTE_PUB.Price_Adj_Attr_Rec_Type;
  l_Shipment_rec          ASO_QUOTE_PUB.Shipment_rec_Type;
  l_Tax_Detail_rec        ASO_QUOTE_PUB.Tax_Detail_rec_Type;
  l_payment_rec           ASO_QUOTE_PUB.Payment_rec_Type;
  l_Freight_Charge_rec    ASO_QUOTE_PUB.Freight_Charge_rec_Type;
  l_Line_Attribs_rec      ASO_QUOTE_PUB.Line_Attribs_Ext_rec_type;
  l_Sales_Credit_rec      ASO_QUOTE_PUB.Sales_Credit_rec_Type;
  l_Quote_Party_rec       ASO_QUOTE_PUB.Quote_Party_rec_Type;
  lx_tax_shipment_tbl     ASO_QUOTE_PUB.Shipment_tbl_Type;
  l_quantity              NUMBER;
  my_message              VARCHAR2(2000);

  l_tax_control_rec       ASO_TAX_INT.Tax_control_rec_type;
  x_tax_amount            NUMBER;
  l_calc_tax_detail_rec   ASO_QUOTE_PUB.Tax_Detail_Rec_Type := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC;
  l_pricing_control_rec   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE;

  l_db_qte_line_rec       ASO_QUOTE_PUB.Qte_Line_Rec_Type   := ASO_QUOTE_PUB.G_MISS_Qte_Line_Rec;
  l_db_shipment_tbl       ASO_QUOTE_PUB.Shipment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_Shipment_Tbl;
  l_db_shipment_rec       ASO_QUOTE_PUB.Shipment_Rec_Type   := ASO_QUOTE_PUB.G_MISS_Shipment_Rec;
  l_hd_shipment_tbl       ASO_QUOTE_PUB.Shipment_Tbl_Type   := ASO_QUOTE_PUB.G_MISS_Shipment_Tbl;
  l_hd_shipment_rec       ASO_QUOTE_PUB.Shipment_Rec_Type   := ASO_QUOTE_PUB.G_MISS_Shipment_Rec;

  CURSOR c_line_relation (p_line_id number, p_rel_line_id number) IS
  SELECT 'x' FROM ASO_LINE_RELATIONSHIPS
  WHERE quote_line_id = p_line_id and
  related_quote_line_id = p_rel_line_id
  AND relationship_type_code = 'SERVICE';

  CURSOR c_db_payment_terms(p_payment_id number) IS
  SELECT payment_term_id_from,payment_term_id
  FROM   ASO_PAYMENTS
  WHERE  payment_id = p_payment_id;

  CURSOR c_db_ship_freight_terms(p_shipment_id number) IS
  SELECT ship_method_code_from,ship_method_code,
  Freight_terms_code_from,Freight_terms_code
  FROM   ASO_SHIPMENTS
  WHERE  shipment_id = p_shipment_id;

  cursor c_service_ref_type_code(p_quote_line_detail_id  number) is
  select service_ref_type_code from aso_quote_line_details
  where quote_line_detail_id = p_quote_line_detail_id;

    cursor get_payment_type_code( l_payment_id Number) is
    select payment_type_code
    from aso_payments
    where payment_id = l_payment_id;

    cursor get_bill_to_party( l_qte_line_id Number) is
    select invoice_to_cust_party_id
    from aso_quote_lines_all
    where quote_line_id = l_qte_line_id;

  l_service_ref_type_code     varchar2(30);

  l_line_rel                  VARCHAR2(1);
  x_relationship_id           NUMBER;
  l_line_rtlship_rec          ASO_QUOTE_PUB.Line_Rltship_Rec_Type := ASO_QUOTE_PUB.G_MISS_Line_Rltship_REC;
  l_db_qte_line_dtl_tbl       ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_tbl;

  l_copy_quote_control_rec    aso_copy_quote_pub.copy_quote_control_rec_type;
  l_copy_quote_header_rec     aso_copy_quote_pub.copy_quote_header_rec_type;
  l_qte_nbr                   number;

  --new code to call overload pricing_order procedure
  l_hd_price_attr_tbl         ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
  lx_qte_line_tbl             ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
  lx_qte_header_rec           ASO_QUOTE_PUB.Qte_Header_Rec_Type;
  lx_qte_line_dtl_tbl         ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type;
  lx_price_adj_tbl            ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
  lx_price_adj_attr_tbl       ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
  lx_price_adj_rltship_tbl    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

  -- bmishra defaulting framework
  l_def_control_rec           ASO_DEFAULTING_INT.Control_Rec_Type     := ASO_DEFAULTING_INT.G_MISS_CONTROL_REC;
  l_db_object_name            VARCHAR2(30);
  --l_shipment_rec            ASO_QUOTE_PUB.Shipment_Rec_Type;
  --l_payment_rec             ASO_QUOTE_PUB.Payment_Rec_Type          := ASO_QUOTE_PUB.G_MISS_Payment_REC;
  lx_hd_shipment_rec          ASO_QUOTE_PUB.Shipment_Rec_Type;
  lx_hd_payment_rec           ASO_QUOTE_PUB.Payment_Rec_Type;
  lx_hd_tax_detail_rec        ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
  lx_hd_misc_rec              ASO_DEFAULTING_INT.Header_Misc_Rec_Type;
  lx_qte_line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
  lx_ln_misc_rec              ASO_DEFAULTING_INT.Line_Misc_Rec_Type;
  lx_ln_shipment_rec          ASO_QUOTE_PUB.Shipment_Rec_Type;
  lx_ln_payment_rec           ASO_QUOTE_PUB.Payment_Rec_Type;
  lx_ln_tax_detail_rec        ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
  lx_changed_flag             VARCHAR2(1);
  lx_ln_payment_tbl	          ASO_QUOTE_PUB.Payment_Tbl_Type;
  lx_ln_Shipment_Tbl          ASO_QUOTE_PUB.Shipment_Tbl_Type;
  l_control_rec               ASO_QUOTE_PUB.Control_Rec_Type          := p_control_rec;
  l_Orig_Payment_Tbl          ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_Payment_TBL;
  lx_price_attr_tbl           ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;

  /* Code change for Quoting Usability Sun ER Start */

  l_def_qte_line_rec ASO_QUOTE_PUB.Qte_Line_Rec_Type := ASO_QUOTE_PUB.G_MISS_Qte_Line_Rec;
  l_line_rec         ASO_QUOTE_PUB.Qte_Line_Rec_Type := p_qte_line_rec;
  l_ln_payment_tbl   ASO_QUOTE_PUB.Payment_Tbl_Type  := p_payment_tbl;
  l_ln_Shipment_Tbl  ASO_QUOTE_PUB.Shipment_Tbl_Type := p_shipment_tbl;

  Cursor C_INVOICE_TO_CUSTOMER(P_QUOTE_LINE_ID IN NUMBER) IS
  SELECT INVOICE_TO_CUST_ACCOUNT_ID
  FROM ASO_QUOTE_LINES_ALL
  WHERE QUOTE_LINE_ID = P_QUOTE_LINE_ID;

  l_INVOICE_TO_CUSTOMER Number;

  CURSOR C_AGREEMENT(P_AGREEMENT_ID IN NUMBER,P_INVOICE_TO_CUSTOMER_ID IN NUMBER) IS
  SELECT 'x'
  FROM OE_AGREEMENTS_VL
  WHERE AGREEMENT_ID = P_AGREEMENT_ID
  AND  INVOICE_TO_CUSTOMER_ID = P_INVOICE_TO_CUSTOMER_ID;

  l_var varchar2(1);

  /* Code change for Quoting Usability Sun ER End */

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_quote_line_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      if aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote_line - Begin ', 1, 'Y');
          aso_debug_pub.add('P_Control_REC.AUTO_VERSION_FLAG: '||nvl(P_Control_REC.AUTO_VERSION_FLAG,'null'),1,'N');
          aso_debug_pub.add('P_Control_REC.pricing_request_type: '||nvl(P_Control_REC.pricing_request_type,'null'),1,'N');
          aso_debug_pub.add('P_Control_REC.header_pricing_event: '||nvl(P_Control_REC.header_pricing_event,'null'),1,'N');
          aso_debug_pub.add('P_Control_REC.line_pricing_event: '||nvl(P_Control_REC.line_pricing_event,'null'),1,'N');
          aso_debug_pub.add('P_Control_REC.CALCULATE_TAX_FLAG: '||nvl(P_Control_REC.CALCULATE_TAX_FLAG,'null'),1,'N');
          aso_debug_pub.add('P_Control_REC.CALCULATE_FREIGHT_CHARGE_FLAG: '||nvl(P_Control_REC.CALCULATE_FREIGHT_CHARGE_FLAG,'null'),1,'N');
          aso_debug_pub.add('P_Control_REC.COPY_TASK_FLAG: '||nvl(P_Control_REC.COPY_TASK_FLAG,'null'),1,'N');
          aso_debug_pub.add('P_Control_REC.COPY_NOTES_FLAG: '||nvl(P_Control_REC.COPY_NOTES_FLAG,'null'),1,'N');
          aso_debug_pub.add('P_Control_REC.COPY_ATT_FLAG: '||nvl(P_Control_REC.COPY_ATT_FLAG,'null'),1,'N');
	  aso_debug_pub.add('P_Control_Rec.Change_Customer_flag: '||nvl(P_Control_Rec.Change_Customer_flag,'null'),1,'N');  -- Code change for Quoting Usability Sun ER
          aso_debug_pub.add('P_Qte_Line_Rec.OPERATION_CODE: '||nvl(P_Qte_Line_Rec.OPERATION_CODE,'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.QUOTE_LINE_ID: '||nvl(to_char(P_Qte_Line_Rec.QUOTE_LINE_ID),'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.QUOTE_HEADER_ID: '||nvl(to_char(P_Qte_Line_Rec.QUOTE_HEADER_ID),'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.LINE_CATEGORY_CODE: '||nvl(P_Qte_Line_Rec.LINE_CATEGORY_CODE,'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.ITEM_TYPE_CODE: '||nvl(P_Qte_Line_Rec.ITEM_TYPE_CODE,'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.ORDER_LINE_TYPE_ID: '||nvl(to_char(P_Qte_Line_Rec.ORDER_LINE_TYPE_ID),'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.INVOICE_TO_PARTY_SITE_ID: '||nvl(to_char(P_Qte_Line_Rec.INVOICE_TO_PARTY_SITE_ID),'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.INVOICE_TO_PARTY_ID: '||nvl(to_char(P_Qte_Line_Rec.INVOICE_TO_PARTY_ID),'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.INVOICE_TO_CUST_ACCOUNT_ID: '||nvl(to_char(P_Qte_Line_Rec.INVOICE_TO_CUST_ACCOUNT_ID),'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.INVENTORY_ITEM_ID: '||nvl(to_char(P_Qte_Line_Rec.INVENTORY_ITEM_ID),'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.QUANTITY: '||nvl(to_char(P_Qte_Line_Rec.QUANTITY),'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.UOM_CODE: '||nvl(P_Qte_Line_Rec.UOM_CODE,'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.PRICING_QUANTITY_UOM: '||nvl(P_Qte_Line_Rec.PRICING_QUANTITY_UOM,'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.PRICE_LIST_ID: '||nvl(to_char(P_Qte_Line_Rec.PRICE_LIST_ID),'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.PRICE_LIST_LINE_ID: '||nvl(to_char(P_Qte_Line_Rec.PRICE_LIST_LINE_ID),'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.CURRENCY_CODE: '||nvl(P_Qte_Line_Rec.CURRENCY_CODE,'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.RELATED_ITEM_ID: '||nvl(to_char(P_Qte_Line_Rec.RELATED_ITEM_ID),'null'),1,'N');
          aso_debug_pub.add('P_Qte_Line_Rec.org_id: '||nvl(to_char(P_Qte_Line_Rec.org_id),'null'));
      end if;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      OPEN C_qln_exist;
	 FETCH C_qln_exist into l_qln_exist;

	 IF c_qln_exist%NOTFOUND OR l_qln_exist = FND_API.G_MISS_NUM THEN

         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'API_MISSING_LINE');
		    FND_MESSAGE.Set_Token ('VALUE', p_qte_line_rec.quote_line_id, FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          CLOSE C_qln_exist;
          raise FND_API.G_EXC_ERROR;

	 END IF;
      CLOSE C_qln_exist;

      IF (p_update_header_flag = 'Y') THEN

          Open C_Get_quote( p_qte_line_rec.QUOTE_LINE_ID);
          Fetch C_Get_quote into l_LAST_UPDATE_DATE, l_qte_status_id, l_quote_number, l_hd_discount_percent,l_quote_exp_date;

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	    aso_debug_pub.add('After c_get_quote',1,'N');
      	    aso_debug_pub.add('l_qte_status_id: '||l_qte_status_id,1,'N');
      	    aso_debug_pub.add('l_quote_number: '||nvl(to_char(l_quote_number),'null'),1,'N');
      	    aso_debug_pub.add('l_hd_discount_percent: '||nvl(to_char(l_hd_discount_percent),'null'),1,'N');
	     end if;

          If ( C_Get_quote%NOTFOUND) Then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'API_MISSING_UPDATE_TARGET');
                 FND_MESSAGE.Set_Token ('INFO', 'quote', FALSE);
                 FND_MSG_PUB.Add;
              END IF;
              Close C_Get_quote;
              raise FND_API.G_EXC_ERROR;
          END IF;
          Close C_Get_quote;

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	    aso_debug_pub.add('After C_Get_quote Cursor call ',1,'N');
	     end if;

          If (l_last_update_date is NULL or l_last_update_date = FND_API.G_MISS_Date ) Then

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
                   FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
                   FND_MSG_PUB.ADD;
               END IF;
               raise FND_API.G_EXC_ERROR;
          End if;

          -- Check Whether record has been changed by someone else
          If (trunc(l_last_update_date) <> trunc(p_control_rec.last_update_date)) Then

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'API_RECORD_CHANGED');
                   FND_MESSAGE.Set_Token('INFO', 'quote', FALSE);
                   FND_MSG_PUB.ADD;
               END IF;
               raise FND_API.G_EXC_ERROR;
          End if;

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	    aso_debug_pub.add('After Last update date validation',1,'N');
	     end if;

          Open c_qte_status (l_qte_status_id);
          Fetch C_qte_status into l_update_allowed, l_auto_version;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	   aso_debug_pub.add('after c_qte_status',1,'N');
      	   aso_debug_pub.add('l_update_allowed: '||l_update_allowed,1,'N');
      	   aso_debug_pub.add('l_auto_version: '||l_auto_version,1,'N');
	    end if;
         Close c_qte_status;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	   aso_debug_pub.add('After c_qte_status cursor call',1,'N');
	    end if;

         -- the control rec does not set auto version to 'Y' then it should not be versioned

         IF p_control_rec.auto_version_flag = FND_API.G_TRUE AND NVL(l_auto_version,'Y') = 'Y' THEN

	        OPEN C_Qte_Version(l_quote_number);
	        FETCH C_Qte_Version into l_quote_version;
	        l_quote_version := nvl(l_quote_version, 0) + 1;
	        CLOSE C_Qte_Version;
         ELSE
             l_auto_version := 'N';
         END IF;

	    if aso_debug_pub.g_debug_flag = 'Y' THEN
      	   aso_debug_pub.add('after basic validations'||  x_return_status, 1, 'Y');
	    end if;

         IF l_auto_version = 'Y' THEN

	        l_old_header_rec := ASO_UTILITY_PVT.Query_Header_Row(p_qte_line_rec.QUOTE_HEADER_ID);

             l_copy_quote_control_rec.new_version     :=  FND_API.G_TRUE;
             l_copy_quote_header_rec.quote_header_id  :=  l_old_header_rec.quote_header_id;

             aso_copy_quote_pvt.copy_quote( P_Api_Version_Number      =>  1.0,
                                            P_Init_Msg_List           =>  FND_API.G_FALSE,
                                            P_Commit                  =>  FND_API.G_FALSE,
                                            P_Copy_Quote_Header_Rec   =>  l_copy_quote_header_rec,
                                            P_Copy_Quote_Control_Rec  =>  l_copy_quote_control_rec,
                                            X_Qte_Header_Id           =>  x_quote_header_id,
                                            X_Qte_Number              =>  l_qte_nbr,
                                            X_Return_Status           =>  l_return_status,
                                            X_Msg_Count               =>  x_msg_count,
                                            X_Msg_Data                =>  x_msg_data
                                           );

		   if aso_debug_pub.g_debug_flag = 'Y' then
            	  aso_debug_pub.add('Update_Quote_Line: After copy_quote');
            	  aso_debug_pub.add('After copy_quote l_return_status:   ' || l_return_status);
            	  aso_debug_pub.add('After copy_quote x_quote_header_id: ' || x_quote_header_id);
            	  aso_debug_pub.add('After copy_quote l_qte_nbr:         ' || l_qte_nbr);
		   end if;

             update aso_quote_headers_all
             set quote_version      =  l_quote_version + 1,
                 max_version_flag   =  'Y',
                 last_update_date   =  sysdate,
                 last_updated_by    =  fnd_global.user_id,
                 last_update_login  =  fnd_global.conc_login_id
             where quote_header_id = p_qte_line_rec.quote_header_id;

             update aso_quote_headers_all
             set max_version_flag   =  'N',
                 quote_version      =  l_old_header_rec.quote_version,
                 last_update_date   =  sysdate,
                 last_updated_by    =  fnd_global.user_id,
                 last_update_login  =  fnd_global.conc_login_id
             where quote_header_id = x_quote_header_id;

             update aso_quote_headers_all
             set quote_version      =  l_quote_version,
                 last_update_date   =  sysdate,
                 last_updated_by    =  fnd_global.user_id,
                 last_update_login  =  fnd_global.conc_login_id
             where quote_header_id = p_qte_line_rec.quote_header_id;

         END IF;   -- auto version flag

      END IF;  -- update header flag

      /* Code change for Quoting Usability Sun ER Start */

      IF P_Control_Rec.Change_Customer_flag = FND_API.G_TRUE THEN

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Update_Quote_Line - P_Control_Rec.Change_Customer_flag is True', 1, 'Y');
         END IF ;

          l_line_rec.INVOICE_TO_PARTY_SITE_ID := Null;
          l_line_rec.INVOICE_TO_PARTY_ID := Null;
	  l_line_rec.INVOICE_TO_CUST_ACCOUNT_ID := Null;
	  l_line_rec.INVOICE_TO_CUST_PARTY_ID := Null;

	  If (l_ln_Shipment_Tbl.COUNT > 0) then
	      l_ln_Shipment_Tbl(1).SHIP_TO_CUST_ACCOUNT_ID := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_CUST_PARTY_ID := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_PARTY_ID := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_PARTY_SITE_ID := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_PARTY_NAME := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_CONTACT_FIRST_NAME := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_CONTACT_MIDDLE_NAME := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_CONTACT_LAST_NAME := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_ADDRESS1 := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_ADDRESS2 := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_ADDRESS3 := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_ADDRESS4 := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_COUNTRY_CODE := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_COUNTRY := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_CITY := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_POSTAL_CODE := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_STATE := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_PROVINCE := Null;
	      l_ln_Shipment_Tbl(1).SHIP_TO_COUNTY := Null;
	      l_ln_Shipment_Tbl(1).SHIP_METHOD_CODE := Null;
              l_ln_Shipment_Tbl(1).FREIGHT_TERMS_CODE := Null;
	      l_ln_Shipment_Tbl(1).FOB_CODE := Null;
	      l_ln_Shipment_Tbl(1).DEMAND_CLASS_CODE := Null;
	      l_ln_Shipment_Tbl(1).SHIP_FROM_ORG_ID := Null;
	      l_ln_Shipment_Tbl(1).REQUEST_DATE := Null;
	      l_ln_Shipment_Tbl(1).SHIPMENT_PRIORITY_CODE := Null;
	      l_ln_Shipment_Tbl(1).SHIPPING_INSTRUCTIONS := Null;
	      l_ln_Shipment_Tbl(1).PACKING_INSTRUCTIONS := Null;
	  End If;

	  l_line_rec.END_CUSTOMER_PARTY_ID := Null;
	  l_line_rec.END_CUSTOMER_PARTY_SITE_ID := Null;
	  l_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := Null;
	  l_line_rec.END_CUSTOMER_CUST_PARTY_ID := Null;

	  l_line_rec.PRICE_LIST_ID := Null;
	  l_line_rec.CURRENCY_CODE := Null;

	  IF (l_line_rec.AGREEMENT_ID IS NOT NULL AND
              l_line_rec.AGREEMENT_ID <> FND_API.G_MISS_NUM) THEN

	      Open C_AGREEMENT(l_line_rec.AGREEMENT_ID,l_line_rec.INVOICE_TO_CUST_ACCOUNT_ID);
	      Fetch C_AGREEMENT Into l_var;
	      Close C_AGREEMENT;

	      If C_AGREEMENT%Found Then
	         l_line_rec.AGREEMENT_ID := Null;
	      End If;
	  End If;

	  If (l_ln_payment_tbl.COUNT > 0) then
	      If l_ln_payment_tbl(1).PAYMENT_TYPE_CODE In ('CHECK','CREDIT_CARD') Then
       	         If l_ln_payment_tbl(1).PAYMENT_TYPE_CODE = 'CREDIT_CARD' Then
		    l_ln_payment_tbl(1).CREDIT_CARD_CODE := Null;
		    l_ln_payment_tbl(1).CREDIT_CARD_HOLDER_NAME := Null;
		    l_ln_payment_tbl(1).CREDIT_CARD_EXPIRATION_DATE := Null;
		    l_ln_payment_tbl(1).cvv2 := Null;
	         End If;
	         l_ln_payment_tbl(1).PAYMENT_TYPE_CODE := NULL;
	         l_ln_payment_tbl(1).PAYMENT_REF_NUMBER := Null;
              End If;
	      l_ln_payment_tbl(1).CUST_PO_NUMBER := Null;
	      l_ln_payment_tbl(1).CUST_PO_LINE_NUMBER := Null;
	      l_ln_payment_tbl(1).PAYMENT_TERM_ID := Null;
	  End If;

          -- bmishra line defaulting framework begin

          IF l_control_rec.defaulting_fwk_flag = 'Y' Then

             l_def_qte_line_rec := l_line_rec;

             IF l_ln_Shipment_Tbl.count > 0 THEN
                l_shipment_rec := l_ln_Shipment_Tbl(1);
             END IF;

             IF l_ln_payment_tbl.count > 0 THEN
                l_payment_rec := l_ln_payment_tbl(1);
             END IF;

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Update_Quote_Line: Before defaulting framework', 1, 'Y');
                aso_debug_pub.add('Update_Quote_Line: populate defaulting control record from the line control record', 1, 'Y');
             END IF ;

             l_def_control_rec.Dependency_Flag       := p_control_rec.Dependency_Flag;
             l_def_control_rec.Defaulting_Flag       := p_control_rec.Defaulting_Flag;
             l_def_control_rec.Application_Type_Code := p_control_rec.Application_Type_Code;
             l_def_control_rec.Defaulting_Flow_Code  := 'UPDATE';
             l_def_control_rec.last_update_date      := p_control_rec.last_update_date;

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Update_Quote_Line: Defaulting_Fwk_Flag:   '|| p_control_rec.Defaulting_Fwk_Flag, 1, 'Y');
                aso_debug_pub.add('Update_Quote_Line: Dependency_Flag:       '|| l_def_control_rec.Dependency_Flag, 1, 'Y');
                aso_debug_pub.add('Update_Quote_Line: Defaulting_Flag:       '|| l_def_control_rec.Defaulting_Flag, 1, 'Y');
                aso_debug_pub.add('Update_Quote_Line: Application_Type_Code: '|| l_def_control_rec.Application_Type_Code, 1, 'Y');
                aso_debug_pub.add('Update_Quote_Line: Defaulting_Flow_Code:  '|| l_def_control_rec.Defaulting_Flow_Code, 1, 'Y');
                aso_debug_pub.add('Update_Quote_Line: last_update_date:      '|| l_def_control_rec.last_update_date, 1, 'Y');
             END IF ;

             IF l_def_control_rec.application_type_code = 'QUOTING HTML' OR  l_def_control_rec.application_type_code = 'QUOTING FORM' THEN
                l_db_object_name := ASO_QUOTE_HEADERS_PVT.G_QUOTE_LINE_DB_NAME;
             ELSIF l_def_control_rec.application_type_code = 'ISTORE' THEN
                l_db_object_name := ASO_QUOTE_HEADERS_PVT.G_STORE_CART_LINE_DB_NAME;
             ELSE
                l_control_rec.Defaulting_Fwk_Flag := 'N';
             END IF;

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Pick '||l_db_object_name ||' based on calling application '||l_def_control_rec.application_type_code, 1, 'Y');
             END IF ;

             /* Removing Call for defaulting from create_quote_line */ -- un-commented for Quoting Usability Sun ER

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Update_Quote_Line - Before Calling Default_Entity procedure', 1, 'Y');
             END IF ;

	     ASO_DEFAULTING_INT.Default_Entity ( p_api_version           =>  1.0,
                                                 p_control_rec           =>  l_def_control_rec,
                                                 p_database_object_name  =>  l_db_object_name,
                                                 p_quote_line_rec        =>  l_def_qte_line_rec,
                                                 p_line_shipment_rec     =>  l_shipment_rec,
                                                 p_line_payment_rec      =>  l_payment_rec,
                                                 x_quote_header_rec      =>  l_qte_header_rec,
                                                 x_header_misc_rec       =>  lx_hd_misc_rec,
                                                 x_header_shipment_rec   =>  lx_hd_shipment_rec,
                                                 x_header_payment_rec    =>  lx_hd_payment_rec,
                                                 x_header_tax_detail_rec =>  lx_hd_tax_detail_rec,
                                                 x_quote_line_rec        =>  lx_qte_line_rec,
                                                 x_line_misc_rec         =>  lx_ln_misc_rec,
                                                 x_line_shipment_rec     =>  lx_ln_shipment_rec,
                                                 x_line_payment_rec      =>  lx_ln_payment_rec,
                                                 x_line_tax_detail_rec   =>  lx_ln_tax_detail_rec,
                                                 x_changed_flag          =>  lx_changed_flag,
                                                 x_return_status         =>  x_return_status,
                                                 x_msg_count             =>  x_msg_count,
                                                 x_msg_data              =>  x_msg_data );

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Update_Quote_line: After call to ASO_DEFAULTING_INT.Default_Entity', 1, 'Y');
                aso_debug_pub.add('Update_Quote_line: x_return_status: '|| x_return_status, 1, 'Y');
             End If;

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_DEFAULTING');
                   FND_MSG_PUB.ADD;
                END IF;

                IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                   RAISE FND_API.G_EXC_ERROR;
                END IF;
             END IF;

	     IF aso_quote_headers_pvt.Shipment_Null_Rec_Exists(lx_ln_shipment_rec, l_db_object_name) THEN
                lx_ln_shipment_tbl(1) := lx_ln_shipment_rec;
             END IF;

             IF aso_quote_headers_pvt.Payment_Null_Rec_Exists(lx_ln_payment_rec, l_db_object_name) THEN
                lx_ln_payment_tbl(1) := lx_ln_payment_rec;
             END IF;
	     -- bmishra defaulting framework end

	  ELSE

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Update_Quote_Line - l_control_rec.defaulting_fwk_flag is N', 1, 'Y');
             END IF ;

	     lx_qte_line_rec := l_line_rec;
             lx_ln_shipment_tbl := l_ln_Shipment_Tbl;
             lx_ln_payment_tbl := l_ln_payment_tbl;
	  END IF;

      ELSIF P_Control_Rec.Change_Customer_flag = FND_API.G_FALSE THEN

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Update_Quote_Line - P_Control_Rec.Change_Customer_flag is FALSE', 1, 'Y');
          END IF ;

          lx_qte_line_rec := p_qte_line_rec;
          lx_ln_shipment_tbl := p_shipment_tbl;
          lx_ln_payment_tbl := p_payment_tbl;
      END IF;
      /* Code change for Quoting Usability Sun ER End */

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote_line - before validation', 1, 'Y');
          aso_debug_pub.add('Update_Quote_line: ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM: '||ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM, 1, 'Y');
      end if;

      IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN

           ASO_VALIDATE_PVT.Validate_Item_Type_Code(
		                        p_init_msg_list	 => FND_API.G_FALSE,
		                        p_item_type_code => lx_qte_line_rec.item_type_code,
		                        x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

	      -- invoice_to_party_id must exist and be active in HZ_PARTIES and have the usage INVOICE.

	      ASO_VALIDATE_PVT.Validate_Party (
		                        p_init_msg_list	=> FND_API.G_FALSE,
		                        p_party_id	     => lx_qte_line_rec.invoice_to_party_id,
		                        p_party_usage	=> 'INVOICE',
		                        x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data);

	      if aso_debug_pub.g_debug_flag = 'Y' THEN
 		     aso_debug_pub.add('after validate invoice to party: x_return_status: '||x_return_status, 1, 'N');
	      end if;

	      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

	      ASO_VALIDATE_PVT.Validate_PartySite (
		                        p_init_msg_list	=> FND_API.G_FALSE,
		                        p_party_id	     => lx_qte_line_rec.invoice_to_party_id,
		                        p_party_site_id	=> lx_qte_line_rec.invoice_to_party_site_id,
		                        p_site_usage	=> 'INVOICE',
		                        x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data);

	      if aso_debug_pub.g_debug_flag = 'Y' THEN
 		     aso_debug_pub.add('after validate invoice to party site: x_return_status: '||x_return_status, 1, 'N');
	      end if;

	      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

	      -- price list must exist and be active in OE_PRICE_LISTS
	      ASO_VALIDATE_PVT.Validate_PriceList (
		                        p_init_msg_list	=> FND_API.G_FALSE,
		                        p_price_list_id	=> lx_qte_line_rec.price_list_id,
		                        x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data);

	      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           ASO_VALIDATE_PVT.Validate_Quote_Price_Exp(
  	                             p_init_msg_list		   => FND_API.G_FALSE,
                                  p_price_list_id	        => lx_qte_line_rec.price_list_id,
                                  p_quote_expiration_date => l_quote_exp_date,
                                  x_return_status         => x_return_status,
	                             x_msg_count	        => x_msg_count,
	                             x_msg_data	             => x_msg_data);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	              FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                   FND_MESSAGE.Set_Token('COLUMN', 'Price List Expires Before Quote', FALSE);
                   FND_MSG_PUB.ADD;
	          END IF;

	          RAISE FND_API.G_EXC_ERROR;
           END IF;

	      if aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('After call to Validate_Quote_Price_Exp: x_return_status: '|| x_return_status, 1, 'Y');
	      end if;

	      -- shp_to_party_id must exist and be active in HZ_PARTIES and have the usage SHIP.

           For i in 1..lx_ln_shipment_tbl.count LOOP

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
 				aso_debug_pub.add('before validating ship_to party: '||nvl(to_char(lx_ln_shipment_tbl(i).ship_to_party_id), 'null'),1,'N');
			end if;

	          ASO_VALIDATE_PVT.Validate_Party (
		                        p_init_msg_list	=> FND_API.G_FALSE,
		                        p_party_id	     => lx_ln_shipment_tbl(i).ship_to_party_id,
		                        p_party_usage	=> 'SHIP',
		                        x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data);

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
 			    aso_debug_pub.add('after validate ship to party: x_return_status: '||x_return_status, 1, 'N');
			end if;

	          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
               END IF;

		     if aso_debug_pub.g_debug_flag = 'Y' THEN
			     aso_debug_pub.add('before validating ship_to party site: '||nvl(to_char(lx_ln_shipment_tbl(i).ship_to_party_site_id),'null'),1,'N');
		     end if;

	          ASO_VALIDATE_PVT.Validate_PartySite (
		                        p_init_msg_list	 => FND_API.G_FALSE,
		                        p_party_id	      => lx_ln_shipment_tbl(i).ship_to_party_id,
		                        p_party_site_id	 => lx_ln_shipment_tbl(i).ship_to_party_site_id,
		                        p_site_usage	 => 'SHIP',
		                        x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data);

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
 			    aso_debug_pub.add('after validate ship to party site: x_return_status: '||x_return_status, 1, 'N');
			end if;

	          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
               END IF;

	      End LOOP;


           ASO_VALIDATE_PVT.Validate_Marketing_Source_Code(
		                        p_init_msg_list         => FND_API.G_FALSE,
		                        p_mkting_source_code_id => lx_qte_line_rec.marketing_source_code_id,
                                  x_return_status         => x_return_status,
                                  x_msg_count             => x_msg_count,
                                  x_msg_data              => x_msg_data);

		 IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('after marketing source code: x_return_status: '|| x_return_status, 1, 'Y');
		 end if;

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;


           FOR i in 1..p_qte_line_dtl_tbl.count LOOP

               ASO_VALIDATE_PVT.Validate_Service_Duration(
                           p_init_msg_list    => FND_API.G_FALSE,
                           p_service_duration => p_qte_line_dtl_tbl(i).service_duration,
                           x_return_status    => x_return_status,
                           x_msg_count        => x_msg_count,
                           x_msg_data         => x_msg_data);

	          IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('after service duration: x_return_status: '||  x_return_status, 1, 'Y');
	          end if;

               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

           END LOOP;


           FOR i in 1..p_sales_credit_tbl.count LOOP

              if aso_debug_pub.g_debug_flag = 'Y' then
                  aso_debug_pub.add('p_sales_credit_tbl('||i||').operation_code: '|| p_sales_credit_tbl(i).operation_code,1,'Y');
              end if;

              if (p_sales_credit_tbl(i).operation_code = 'CREATE' or p_sales_credit_tbl(i).operation_code = 'UPDATE') then

                   ASO_VALIDATE_PVT.Validate_Resource_id(
		                            p_init_msg_list	=> FND_API.G_FALSE,
		                            p_resource_id	=> p_sales_credit_tbl(i).resource_id  ,
		                            x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data);

                   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		                FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_SALES_REP_ID');
		                FND_MSG_PUB.ADD;
	                 END IF;
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;

                   ASO_VALIDATE_PVT.Validate_Resource_group_id(
		                             p_init_msg_list     => FND_API.G_FALSE,
		                             p_resource_group_id	=> p_sales_credit_tbl(i).resource_group_id,
		                             x_return_status     => x_return_status,
                                       x_msg_count         => x_msg_count,
                                       x_msg_data          => x_msg_data);

                   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                       RAISE FND_API.G_EXC_ERROR;
                   END IF;

                   ASO_VALIDATE_PVT.Validate_Salescredit_Type(
		                             p_init_msg_list        => FND_API.G_FALSE,
		                             p_salescredit_type_id  => p_sales_credit_tbl(i).sales_credit_type_id,
		                             x_return_status        => x_return_status,
                                       x_msg_count            => x_msg_count,
                                       x_msg_data             => x_msg_data);

                   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                       RAISE FND_API.G_EXC_ERROR;
                   END IF;

                   ASO_VALIDATE_PVT.Validate_EmployPerson(
        	                             p_init_msg_list => FND_API.G_FALSE,
        	                             p_employee_id   => p_sales_credit_tbl(i).employee_person_id,
		                             x_return_status => x_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data);

                   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                       RAISE FND_API.G_EXC_ERROR;
                   END IF;

              end if;

           END LOOP;


		 /* commented by bmishra on 12/15/2004 as we are not using quote_party_tbl
           FOR i in 1..p_quote_party_tbl.count LOOP

               ASO_VALIDATE_PVT.Validate_Party_Type(
		                         p_init_msg_list => FND_API.G_FALSE,
		                         p_party_type    => p_quote_party_tbl(i).party_type,
        	                         x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data);

               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

               ASO_VALIDATE_PVT.Validate_Party(
		                         p_init_msg_list => FND_API.G_FALSE,
		                         p_party_id	 => p_quote_party_tbl(i).party_id,
		                         p_party_usage	 => null,
		                         x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data);

               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_ERROR;
               END IF;

 	          ASO_VALIDATE_PVT.Validate_Party_Object_Type(
		                         p_init_msg_list	=> FND_API.G_FALSE,
		                         p_party_object_type => p_quote_party_tbl(i).party_object_type,
		                         x_return_status     => x_return_status,
                                   x_msg_count         => x_msg_count,
                                   x_msg_data          => x_msg_data);
               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

           END LOOP;
		 */


           ASO_VALIDATE_PVT.Validate_MiniSite(
                                   p_init_msg_list => FND_API.G_FALSE,
                                   p_minisite_id   => lx_qte_line_rec.minisite_id,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data);

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

           ASO_VALIDATE_PVT.Validate_Section(
                                   p_init_msg_list => FND_API.G_FALSE,
                                   p_section_id    => lx_qte_line_rec.section_id,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data);

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;

      END IF;

           l_db_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row( P_Qte_Line_Id   => lx_qte_line_rec.quote_line_id);

           l_db_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows( P_Qte_Header_Id => l_db_qte_line_rec.quote_header_id,
                                                                     P_Qte_Line_Id   => l_db_qte_line_rec.quote_line_id);


      IF p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_RECORD THEN

           IF lx_qte_line_rec.organization_id is NULL or lx_qte_line_rec.organization_id = FND_API.G_MISS_NUM THEN

                IF lx_qte_line_rec.org_id is NULL OR lx_qte_line_rec.org_id = FND_API.G_MISS_NUM THEN

                     OPEN C_org_id;
                     FETCH C_org_id into l_org_id;

                     IF C_org_id%NOTFOUND THEN

                         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                             FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                             FND_MESSAGE.Set_Token('COLUMN', 'ORG_ID', FALSE);
                             FND_MSG_PUB.ADD;
                         END IF;

                     END IF;
                     CLOSE C_org_id;

                END IF;

                l_organization_id := oe_profile.value('OE_ORGANIZATION_ID', l_org_id);

           ELSE

		      l_organization_id := lx_qte_line_rec.organization_id;

           END IF;


           IF lx_qte_line_rec.inventory_item_id is NULL OR  lx_qte_line_rec.inventory_item_id = FND_API.G_MISS_NUM THEN

               SELECT inventory_item_id INTO l_inventory_item_id
               FROM aso_quote_lines_all
               WHERE quote_line_id = lx_qte_line_rec.quote_line_id;

           ELSE

               l_inventory_item_id := lx_qte_line_rec.inventory_item_id;

           END IF;

		 IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote_Line: before Validate_UOM_code: l_organization_id:   '|| l_organization_id, 1, 'N');
               aso_debug_pub.add('Update_Quote_Line: before Validate_UOM_code: l_inventory_item_id: '|| l_inventory_item_id, 1, 'N');
		 end if;


           -- UOM must exist and should be in ASO_I_UNITS_OF_MEASURE

           ASO_VALIDATE_PVT.Validate_UOM_code(
		                         p_init_msg_list	=> FND_API.G_FALSE,
		                         p_uom_code          => lx_qte_line_rec.uom_code,
                                   p_organization_id   => l_organization_id,
                                   p_inventory_item_id => l_inventory_item_id,
		                         x_return_status     => x_return_status,
                                   x_msg_count         => x_msg_count,
                                   x_msg_data          => x_msg_data);

	      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;


           ASO_VALIDATE_PVT.Validate_For_GreaterEndDate (
		                         p_init_msg_list => FND_API.G_FALSE,
		                         p_start_date    => lx_qte_line_rec.start_date_active,
        	                         p_end_date      => lx_qte_line_rec.end_date_active,
		                         x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data);

	      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	              FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
                   FND_MESSAGE.Set_Token('INFO', 'END_DATE', FALSE);
	              FND_MSG_PUB.ADD;
	          END IF;
               RAISE FND_API.G_EXC_ERROR;
           END IF;

	      IF aso_debug_pub.g_debug_flag = 'Y' THEN
       	     aso_debug_pub.add('validate greater end date'||  x_return_status , 1, 'Y');
	      end if;

           FOR i in 1..p_qte_line_dtl_tbl.count LOOP

               ASO_VALIDATE_PVT.Validate_Returns(
                                   p_init_msg_list	   => FND_API.G_FALSE,
                                   p_return_ref_type_code => p_qte_line_dtl_tbl(i).return_ref_type,
                                   p_return_ref_header_id => p_qte_line_dtl_tbl(i).return_ref_header_id,
                                   p_return_ref_line_id   => p_qte_line_dtl_tbl(i).return_ref_line_id,
	                              x_return_status        => x_return_status,
                                   x_msg_count            => x_msg_count,
                                   x_msg_data             => x_msg_data);

	          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                  FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
	                  FND_MESSAGE.Set_Token('INFO', 'RETURN', FALSE);
                       FND_MSG_PUB.ADD;
	              END IF;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

           END LOOP;

	      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         	     aso_debug_pub.add('validate returns'||  x_return_status, 1, 'Y');
	      end if;

	      -- tax_exempt_flag must be in 'E', 'R' and 'S'
	      -- and tax_exempt_reason_code must exist if tax_exempt_flag is 'E'.

           FOR i in 1..p_tax_detail_tbl.count LOOP

	          ASO_VALIDATE_PVT.Validate_Tax_Exemption (
		                         p_init_msg_list	     => FND_API.G_FALSE,
		                         p_tax_exempt_flag	     => p_tax_detail_tbl(i).tax_exempt_flag,
		                         p_tax_exempt_reason_code => p_tax_detail_tbl(i).tax_exempt_reason_code,
		                         x_return_status          => x_return_status,
                                   x_msg_count              => x_msg_count,
                                   x_msg_data               => x_msg_data);

	          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                  FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
	                  FND_MESSAGE.Set_Token('INFO', 'TAX', FALSE);
	                  FND_MSG_PUB.ADD;
	              END IF;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

           END LOOP;

	      IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('validate tax exemption'||  x_return_status, 1, 'Y');
	      end if;

           FOR i in 1..p_qte_line_dtl_tbl.count LOOP

	          IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('ASO_QUOTE_LINES_PVT:Update_Quote_Lines:config_header_id: '|| p_qte_line_dtl_tbl(i).config_header_id,1,'N');
                   aso_debug_pub.add('ASO_QUOTE_LINES_PVT:Update_Quote_Lines:config_revision_num: '|| p_qte_line_dtl_tbl(i).config_revision_num,1,'N');
                   aso_debug_pub.add('ASO_QUOTE_LINES_PVT:Update_Quote_Lines:component_code: '|| p_qte_line_dtl_tbl(i).component_code,1,'N');
                   aso_debug_pub.add('ASO_QUOTE_LINES_PVT:Update_Quote_Lines:config_item_id: '|| p_qte_line_dtl_tbl(i).config_item_id,1,'N');
	          end if;

               IF ((p_qte_line_dtl_tbl(i).config_header_id IS NOT NULL AND
                    p_qte_line_dtl_tbL(i).config_header_id <> FND_API.G_MISS_NUM) AND
                   (p_qte_line_dtl_tbl(i).config_revision_num IS NOT NULL AND
                    p_qte_line_dtl_tbl(i).config_revision_num <> FND_API.G_MISS_NUM) AND
                   (p_qte_line_dtl_tbl(i).config_item_id IS NOT NULL AND
                    p_qte_line_dtl_tbl(i).config_item_id <> FND_API.G_MISS_NUM)) THEN

                    ASO_VALIDATE_PVT.Validate_Configuration(
		                         p_init_msg_list       => FND_API.G_FALSE,
		                         p_config_header_id    => p_qte_line_dtl_tbl(i).config_header_id,
        	                         p_config_revision_num => p_qte_line_dtl_tbl(i).config_revision_num,
                                   p_config_item_id      => p_qte_line_dtl_tbl(i).config_item_id,
		                         x_return_status       => x_return_status,
                                   x_msg_count           => x_msg_count,
                                   x_msg_data            => x_msg_data);

		          IF aso_debug_pub.g_debug_flag = 'Y' THEN
             	         aso_debug_pub.add('Update_Quote_Lines after Validate_Configuration :x_return_status:'||x_return_status,1, 'N');
		          end if;

	               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                       FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
	                       FND_MESSAGE.Set_Token('INFO', 'CONFIGURATION', FALSE);
	                       FND_MSG_PUB.ADD;
	                   END IF;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
               END IF;

           END LOOP;


	      IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('validate configuration'||  x_return_status, 1, 'Y');
	      end if;

           FOR i in 1..p_qte_line_dtl_tbl.count LOOP

	          ASO_VALIDATE_PVT.Validate_Delayed_Service(
		                         p_init_msg_list         => FND_API.G_FALSE,
		                         p_service_ref_type_code => p_qte_line_dtl_tbl(i).service_ref_type_code,
        	                         p_service_ref_line_id   => p_qte_line_dtl_tbl(i).service_ref_line_id,
        	                         p_service_ref_system_id => p_qte_line_dtl_tbl(i).service_ref_system_id,
		                         x_return_status         => x_return_status,
                                   x_msg_count             => x_msg_count,
                                   x_msg_data              => x_msg_data);

	          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                  FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
	                  FND_MESSAGE.Set_Token('INFO', 'DELAYED SERVICE', FALSE);
	                  FND_MSG_PUB.ADD;
	              END IF;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

           END LOOP;

	      IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('validate delayed service'||  x_return_status, 1, 'Y');
	      end if;

		 /* commented by bmishra on 12/15/2004 as quote_party_tbl is obsoleted

           FOR i in 1..p_quote_party_tbl.count LOOP

               ASO_VALIDATE_PVT.Validate_Party_Object_Id(
	                         p_init_msg_list    => FND_API.G_FALSE,
                                 p_party_id         => p_quote_party_tbl(i).party_id,
	                         p_party_object_type     => p_quote_party_tbl(i).party_object_type,
                                 p_party_object_id       => p_quote_party_tbl(i).party_object_id,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data);
               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                 FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
                      FND_MESSAGE.Set_Token('INFO', 'PARTY OBJECT ID', FALSE);
	                 FND_MSG_PUB.ADD;
	              END IF;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
           END LOOP;
		 */

           -- new validation for ship_from_org_id

           --l_db_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row( P_Qte_Line_Id   => lx_qte_line_rec.quote_line_id);

           -- l_db_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows( P_Qte_Header_Id => l_db_qte_line_rec.quote_header_id,
           --                                                          P_Qte_Line_Id   => l_db_qte_line_rec.quote_line_id);

           IF l_db_shipment_tbl.count = 1 THEN
               l_db_shipment_rec := l_db_shipment_tbl(1);
           END IF;

           IF lx_ln_shipment_tbl.count > 0 THEN

		     IF aso_debug_pub.g_debug_flag = 'Y' THEN
            	    aso_debug_pub.add('Update_Quote_Line: before Validate_ship_from_org_ID', 1, 'Y');
            	    aso_debug_pub.add('lx_qte_line_rec.quote_header_id:        '|| lx_qte_line_rec.quote_header_id, 1, 'Y');
            	    aso_debug_pub.add('lx_qte_line_rec.quote_line_id:          '|| lx_qte_line_rec.quote_line_id, 1, 'Y');
            	    aso_debug_pub.add('lx_ln_shipment_tbl(1).quote_line_id:    '|| lx_ln_shipment_tbl(1).quote_line_id, 1, 'Y');
            	    aso_debug_pub.add('lx_qte_line_rec.inventory_item_id:      '|| lx_qte_line_rec.inventory_item_id, 1, 'Y');
            	    aso_debug_pub.add('l_db_qte_line_rec.inventory_item_id:    '|| l_db_qte_line_rec.inventory_item_id, 1, 'Y');
            	    aso_debug_pub.add('lx_ln_shipment_tbl(1).ship_from_org_id: '|| lx_ln_shipment_tbl(1).ship_from_org_id,1,'Y');
            	    aso_debug_pub.add('l_db_shipment_rec.ship_from_org_id:     '|| l_db_shipment_rec.ship_from_org_id, 1, 'Y');
		     end if;

               IF (l_db_shipment_rec.ship_from_org_id <> lx_ln_shipment_tbl(1).ship_from_org_id) OR
                   ((l_db_qte_line_rec.inventory_item_id <> lx_qte_line_rec.inventory_item_id) AND
                    ((lx_ln_shipment_tbl(1).ship_from_org_id IS NOT NULL) AND
                     (lx_ln_shipment_tbl(1).ship_from_org_id <> FND_API.G_MISS_NUM))) THEN

			      IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  	     aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Update_Quote_Line: before Validate_ship_from_org_ID', 1, 'Y');
			      end if;

                     ASO_VALIDATE_PVT.Validate_ship_from_org_ID(
                                    P_Qte_Line_rec  => lx_qte_line_rec,
                                    P_Shipment_rec  => lx_ln_shipment_tbl(1),
                                    x_return_status => x_return_status);

			      IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  	     aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Update_Quote_Line:  after Validate_ship_from_org_ID', 1, 'Y');
			      end if;

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

					IF aso_debug_pub.g_debug_flag = 'Y' THEN
                      	    aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Update_Quote_Line:  after Validate_ship_from_org_ID: <> SUCCESS', 1, 'Y');
					end if;

                         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                             FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SHIP_FROM_ORG_ID');
                             FND_MESSAGE.Set_Token('SHIP_FROM_ORG_ID', lx_ln_shipment_tbl(1).ship_from_org_id, FALSE);
                             FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', lx_qte_line_rec.inventory_item_id, FALSE);
                             FND_MSG_PUB.ADD;
                         END IF;

                         RAISE FND_API.G_EXC_ERROR;

                     END IF;

               END IF;

           ELSE

	          IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Update_Quote_Line: before Validate_ship_from_org_ID.', 1, 'Y');
                   aso_debug_pub.add('lx_qte_line_rec.quote_header_id:     '|| lx_qte_line_rec.quote_header_id, 1, 'Y');
                   aso_debug_pub.add('lx_qte_line_rec.quote_line_id:       '|| lx_qte_line_rec.quote_line_id, 1, 'Y');
                   aso_debug_pub.add('lx_qte_line_rec.inventory_item_id:   '|| lx_qte_line_rec.inventory_item_id, 1, 'Y');
                   aso_debug_pub.add('l_db_qte_line_rec.inventory_item_id: '|| l_db_qte_line_rec.inventory_item_id, 1, 'Y');
                   aso_debug_pub.add('l_db_shipment_rec.ship_from_org_id:  '|| l_db_shipment_rec.ship_from_org_id, 1, 'Y');
	          end if;

               IF (l_db_qte_line_rec.inventory_item_id <> lx_qte_line_rec.inventory_item_id) AND
                   ((l_db_shipment_rec.ship_from_org_id IS NOT NULL) AND
                    (l_db_shipment_rec.ship_from_org_id <> FND_API.G_MISS_NUM)) THEN

		           IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('Update_Quote_Line: before Validate_ship_from_org_ID (no lx_ln_shipment_tbl)', 1, 'Y');
		           end if;

                     ASO_VALIDATE_PVT.Validate_ship_from_org_ID(
                                    P_Qte_Line_rec  => lx_qte_line_rec,
                                    P_Shipment_rec  => l_db_shipment_rec,
                                    x_return_status => x_return_status);

		           IF aso_debug_pub.g_debug_flag = 'Y' THEN
                         aso_debug_pub.add('Update_Quote_Line:  after Validate_ship_from_org_ID (no lx_ln_shipment_tbl)', 1, 'Y');
		           end if;

                     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

		               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                             aso_debug_pub.add('Update_Quote_Line:  after Validate_ship_from_org_ID: <> SUCCESS (no lx_ln_shipment_tbl)', 1, 'Y');
		               end if;

                         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                             FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SHIP_FROM_ORG_ID');
                             FND_MESSAGE.Set_Token('SHIP_FROM_ORG_ID', l_db_shipment_rec.ship_from_org_id, FALSE);
                             FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', lx_qte_line_rec.inventory_item_id, FALSE);
                             FND_MSG_PUB.ADD;
                         END IF;

                         RAISE FND_API.G_EXC_ERROR;
                     END IF;

               ELSE

                     IF (l_db_shipment_rec.ship_from_org_id IS NULL) OR (l_db_shipment_rec.ship_from_org_id = FND_API.G_MISS_NUM) THEN

                          l_hd_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows( P_Qte_Header_Id => l_db_qte_line_rec.quote_header_id,
                                                                                    P_Qte_Line_Id   => NULL);

                          IF l_hd_shipment_tbl.count = 1 THEN
                              l_hd_shipment_rec := l_hd_shipment_tbl(1);
                          END IF;

		                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                              aso_debug_pub.add('before Validate_ship_from_org_ID: l_hd_shipment_rec.ship_from_org_id:  '||l_hd_shipment_rec.ship_from_org_id, 1, 'Y');
		                end if;

                          IF (l_db_qte_line_rec.inventory_item_id <> lx_qte_line_rec.inventory_item_id) AND
                              ((l_hd_shipment_rec.ship_from_org_id IS NOT NULL) AND
                               (l_hd_shipment_rec.ship_from_org_id <> FND_API.G_MISS_NUM)) THEN

		                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                                  aso_debug_pub.add('Update_Quote_Line: before Validate_ship_from_org_ID (no db_shipment_tbl)', 1, 'Y');
		                    end if;

                              ASO_VALIDATE_PVT.Validate_ship_from_org_ID(
                                             P_Qte_Line_rec  => lx_qte_line_rec,
                                             P_Shipment_rec  => l_hd_shipment_rec,
                                             x_return_status => x_return_status);

		                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                                  aso_debug_pub.add('Update_Quote_Line:  after Validate_ship_from_org_ID (no db_shipment_tbl)', 1, 'Y');
		                    end if;

                              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

		                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                                      aso_debug_pub.add('after Validate_ship_from_org_ID: <> SUCCESS (no db_shipment_tbl)', 1, 'Y');
		                        end if;

                                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                      FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SHIP_FROM_ORG_ID');
                                      FND_MESSAGE.Set_Token('SHIP_FROM_ORG_ID', l_hd_shipment_rec.ship_from_org_id, FALSE);
                                      FND_MESSAGE.Set_Token('INVENTORY_ITEM_ID', lx_qte_line_rec.inventory_item_id, FALSE);
                                      FND_MSG_PUB.ADD;
                                  END IF;

                                  RAISE FND_API.G_EXC_ERROR;
                              END IF;

                          END IF;

                     END IF;

               END IF;

           END IF;

           -- end new validation for ship_from_org_id

      END IF; --IF p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_RECORD


      -- if quantity is decreased check to see if the installation details quantity is not greater than the new quantity
	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Update_Quote_line - before Inst details and populate_quote_line ', 1, 'N');
	 end if;

      -- hyang csi change 1935614

      FOR i IN 1..lx_ln_shipment_tbl.count LOOP

          IF lx_ln_shipment_tbl(i).quantity <> FND_API.G_MISS_NUM THEN

              if not (csi_utility_grp.ib_active()) then

                  Open C_inst_details( lx_ln_shipment_tbl(i).shipment_id);
                  Fetch C_inst_details into l_quantity;

                  IF ( C_inst_details%FOUND) AND  l_quantity > lx_ln_shipment_tbl(i).quantity Then

                      Close C_inst_details;

                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                          FND_MESSAGE.Set_Name('ASO', 'INST_DETAILS_EXIST');
                          FND_MSG_PUB.ADD;
                      END IF;
                      raise FND_API.G_EXC_ERROR;

                  ELSE
			       close C_inst_details;

                  END IF;

              else

                  open c_csi_details(lx_qte_line_rec.QUOTE_LINE_ID);
                  fetch c_csi_details into l_quantity;

                  if (c_csi_details%found) and (l_quantity > lx_ln_shipment_tbl(i).quantity) then

                     close c_csi_details;

                     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                         FND_MESSAGE.Set_Name('ASO', 'INST_DETAILS_EXIST');
                         FND_MSG_PUB.ADD;
                     END IF;
                     raise FND_API.G_EXC_ERROR;

                  else
			      close c_csi_details;

                  end if;

              end if;

          END IF;

      END LOOP;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote_Line - after Validate_Agreement:lx_qte_line_rec.UOM_Code: '||lx_qte_line_rec.UOM_Code,1, 'N');
          aso_debug_pub.add('Update_Quote_Line - after Validate_Agreement:lx_qte_line_rec.Quantity: '||lx_qte_line_rec.Quantity,1, 'N');
	 end if;

      IF lx_qte_line_rec.UOM_Code = 'ENR' THEN

          IF lx_qte_line_rec.Quantity <> FND_API.G_MISS_NUM THEN

		    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Update_Quote_Line - Invalid Quantity for EDU: ',1, 'N');
		    end if;

              x_return_status := FND_API.G_RET_STS_ERROR;
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'ASO_EDU_INVALID_QTY');
                  FND_MSG_PUB.ADD;
              END IF;
              RAISE FND_API.G_EXC_ERROR;

          END IF;

      END IF;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote_Line - Before call to Populate_Quote_Line.',1, 'N');
	 end if;

      Populate_Quote_Line( P_Qte_Line_Rec      	  =>  lx_qte_line_rec,
                           P_Control_Rec       	  =>  l_control_rec,
                           P_Payment_Tbl       	  =>  lx_ln_payment_tbl,
                           P_Price_Adj_Tbl     	  =>  P_Price_Adj_Tbl,
                           P_Qte_Line_Dtl_tbl  	  =>  P_Qte_Line_Dtl_tbl,
                           P_Shipment_Tbl      	  =>  lx_ln_shipment_tbl,
                           P_Tax_Detail_Tbl    	  =>  P_Tax_Detail_Tbl,
                           P_Freight_Charge_Tbl     =>  P_Freight_Charge_Tbl,
                           P_Price_Attributes_Tbl   =>  P_Price_Attributes_Tbl,
                           P_Price_Adj_Attr_Tbl     =>  P_Price_Adj_Attr_Tbl,
                           P_Line_Attribs_Ext_Tbl   =>  P_Line_Attribs_Ext_Tbl,
                           P_Sales_Credit_Tbl       =>  P_sales_credit_tbl,
                           P_Quote_Party_Tbl        =>  P_quote_party_tbl,
                           P_Operation_Code         =>  'UPDATE',
                           X_Qte_Line_Rec      	  =>  l_Qte_Line_Rec,
                           X_Payment_Tbl       	  =>  l_Payment_Tbl,
                           X_Price_Adj_Tbl     	  =>  l_Price_Adj_Tbl,
                           X_Qte_Line_Dtl_tbl  	  =>  l_Qte_Line_Dtl_tbl,
                           X_Shipment_Tbl      	  =>  l_Shipment_Tbl,
                           X_Tax_Detail_Tbl    	  =>  l_Tax_Detail_Tbl,
                           X_Freight_Charge_Tbl     =>  l_Freight_Charge_Tbl,
                           X_Price_Attributes_Tbl   =>  l_Price_Attributes_Tbl,
                           X_Price_Adj_Attr_Tbl     =>  l_Price_Adj_Attr_Tbl,
                           X_Line_Attribs_Ext_Tbl   =>  l_Line_Attribs_Ext_Tbl,
                           X_Sales_Credit_Tbl       =>  l_sales_credit_tbl,
                           x_Quote_Party_Tbl        =>  l_quote_party_tbl,
                           X_Return_Status          =>  X_return_status,
                           X_Msg_Count              =>  x_msg_count,
                           X_Msg_Data               =>  x_msg_data );

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Update_Quote_Line - After call to Populate_Quote_Line: x_return_status: '|| x_return_status ,1, 'N');
	 end if;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	         FND_MESSAGE.Set_Name('ASO', 'ASO_POPULATING_COLUMNS');
              FND_MESSAGE.Set_Token('LINE' , x_qte_line_rec.line_number, FALSE);
	         FND_MSG_PUB.ADD;
	     END IF;

          IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;
      -- copy the orig payment tbl to another variable as the count of the payment tbl may get changed
	 -- becoz of the payment validation which is done further down
      l_orig_payment_tbl := l_Payment_Tbl;

      -- inter entity validations
	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	aso_debug_pub.add('ASO_QUOTE_LINES_PVT: UPDATE_QUOTE_LINE: Begin Inter entity validations');
	 end if;

      IF p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_ENTITY THEN

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
		    ASO_DEBUG_PUB.add('UQ organization_id  = '||nvl(to_char(l_Qte_Line_Rec.organization_id),'null') , 1, 'Y');
		    ASO_DEBUG_PUB.add('UQ Inventory_item_id  = '||l_Qte_Line_Rec.inventory_item_id, 1, 'Y');
	     END IF;

          IF l_Qte_Line_Rec.inventory_item_id <> FND_API.G_MISS_NUM THEN

              ASO_VALIDATE_PVT.Validate_Inventory_Item(
		                   p_init_msg_list     => FND_API.G_FALSE,
		                   p_inventory_item_id => l_Qte_Line_Rec.inventory_item_id,
                             p_organization_id   => l_Qte_Line_Rec.organization_id,
		                   x_return_status     => x_return_status,
                             x_msg_count         => x_msg_count,
                             x_msg_data          => x_msg_data);

	         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
          END IF ;

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after inventory item'||  x_return_status, 1, 'Y');
	     end if;

        -- bug 5196952
      if   (P_shipment_Tbl.count > 0) then

	  IF ( p_shipment_tbl(1).ship_method_code is not null and  p_shipment_tbl(1).ship_method_code <> fnd_api.g_miss_char) then

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Update_Quote_line  - ship method codeof  quote line is being updated ', 1, 'N');
           aso_debug_pub.add('Update_Quote_line  - before validate ship_method_code ', 1, 'N');
          end if;
         ASO_VALIDATE_PVT.validate_ship_method_code
         (
          p_init_msg_list          => fnd_api.g_false,
          p_qte_header_id          => lx_qte_line_rec.quote_header_id,
          p_qte_line_id            => lx_qte_line_rec.quote_line_id,
          p_organization_id        => lx_qte_line_rec.organization_id,
          p_ship_method_code       =>  p_shipment_tbl(1).ship_method_code,
          p_operation_code         => 'UPDATE',
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data);

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Update_Quote_line  - After validate ship_method_code ', 1, 'N');
          end if;

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
        end if;  -- end if for ship method code check
	 elsif (lx_qte_line_rec.organization_id is not null and lx_qte_line_rec.organization_id <> fnd_api.g_miss_num and P_shipment_Tbl.count = 0) then
      -- this means the organization id on the qte line is being updated, hence need to validate the ship method code again for new organization id
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Update_Quote_line  - Organization id of quote line is being updated ', 1, 'N');
           aso_debug_pub.add('Update_Quote_line  - before validate ship_method_code ', 1, 'N');
          end if;
         ASO_VALIDATE_PVT.validate_ship_method_code
         (
          p_init_msg_list          => fnd_api.g_false,
          p_qte_header_id          => lx_qte_line_rec.quote_header_id,
          p_qte_line_id            => lx_qte_line_rec.quote_line_id,
          p_organization_id        => lx_qte_line_rec.organization_id,
          p_ship_method_code       => fnd_api.g_miss_char,
          p_operation_code         => 'UPDATE',
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data);

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Update_Quote_line  - After validate ship_method_code ', 1, 'N');
          end if;

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      end if; -- end if for shipment tbl check


             l_db_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows (P_Qte_Line_Id => l_Qte_Line_Rec.quote_line_id );

          FOR i in 1..l_qte_line_dtl_tbl.count LOOP

          -- bug 4258846
             IF  l_Qte_Line_Rec.start_date_active = FND_API.G_MISS_DATE THEN
                 l_Qte_Line_Rec.start_date_active :=  l_db_qte_line_rec.start_date_active;
             END IF;
             IF  l_Qte_Line_Rec.end_date_active  = FND_API.G_MISS_DATE THEN
                 l_Qte_Line_Rec.end_date_active :=  l_db_qte_line_rec.end_date_active;
             END IF;
             IF  l_Qte_Line_Rec.organization_id  = FND_API.G_MISS_NUM THEN
                 l_Qte_Line_Rec.organization_id :=  l_db_qte_line_rec.organization_id;
             END IF;

              IF l_db_qte_line_dtl_tbl.COUNT > 0 THEN

                   IF l_qte_line_dtl_tbl(i).service_duration = FND_API.G_MISS_NUM THEN
                     l_qte_line_dtl_tbl(i).service_duration := l_db_qte_line_dtl_tbl(i).service_duration;
                  END IF;

                  IF l_qte_line_dtl_tbl(i).service_period = FND_API.G_MISS_CHAR THEN
                    l_qte_line_dtl_tbl(i).service_period := l_db_qte_line_dtl_tbl(i).service_period;
                  END IF;

                  IF l_qte_line_dtl_tbl(i).service_coterminate_flag = FND_API.G_MISS_CHAR  THEN
                    l_qte_line_dtl_tbl(i).service_coterminate_flag := l_db_qte_line_dtl_tbl(i).service_coterminate_flag;
                  END IF;

		    END IF;

              ASO_VALIDATE_PVT.Validate_Service(
                             p_init_msg_list             => FND_API.G_FALSE,
                             p_inventory_item_id         => l_Qte_Line_Rec.inventory_item_id,
                             p_start_date_active         => l_Qte_Line_Rec.start_date_active,
                             p_end_date_active           => l_Qte_Line_Rec.end_date_active,
                             p_service_duration          => l_qte_line_dtl_tbl(i).service_duration,
                             p_service_period            => l_qte_line_dtl_tbl(i).service_period,
                             p_service_coterminate_flag  => l_qte_line_dtl_tbl(i).service_coterminate_flag,
                             p_organization_id           => l_Qte_Line_Rec.organization_id,
                             x_return_status             => x_return_status,
                             x_msg_count                 => x_msg_count,
                             x_msg_data                  => x_msg_data);

	         IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Update_Quote_line: After Validate_Service: x_return_status: '|| x_return_status);
	         end if;

              IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN

                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                      FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_INFORMATION');
                      FND_MESSAGE.Set_Token('INFO','SERVICE', FALSE);
                      FND_MSG_PUB.ADD;
                  END IF;

                  RAISE FND_API.G_EXC_ERROR;

              END IF;

              --validate service period

              ASO_VALIDATE_PVT.Validate_UOM_code(
                             p_init_msg_list      => FND_API.G_FALSE,
                             p_uom_code           => l_qte_line_dtl_tbl(i).service_period,
                             p_organization_id    => l_Qte_Line_Rec.organization_id,
                             p_inventory_item_id  => l_Qte_Line_Rec.inventory_item_id,
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data);

	         IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Update_Quote_line: After validate service period: x_return_status: '|| x_return_status);
	         end if;

              IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;

              --Service cannot be added to a product that is being returned

              IF l_qte_line_dtl_tbl(i).service_ref_type_code = 'QUOTE'
                  AND l_qte_line_dtl_tbl(i).service_ref_line_id IS NOT NULL
                  AND l_qte_line_dtl_tbl(i).service_ref_line_id <> FND_API.G_MISS_NUM THEN

                    OPEN C_line_category_code(l_qte_line_dtl_tbl(i).service_ref_line_id);
                    FETCH C_line_category_code INTO l_line_category_code;

                    IF C_line_category_code%FOUND AND l_line_category_code = 'RETURN' THEN

                        CLOSE C_line_category_code;

                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SERVICE_REFERENCE');
                            FND_MSG_PUB.ADD;
                        END IF;

                        RAISE FND_API.G_EXC_ERROR;

                    END IF;

                    CLOSE C_line_category_code;

              END IF;

		    --New code for Bug#3280130

	         if aso_debug_pub.g_debug_flag = 'Y' then
                  aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').service_ref_line_id: ' || l_qte_line_dtl_tbl(i).service_ref_line_id);
              end if;

		    if l_qte_line_dtl_tbl(i).service_ref_line_id is not null and
		       l_qte_line_dtl_tbl(i).service_ref_line_id <> fnd_api.g_miss_num then

	             if aso_debug_pub.g_debug_flag = 'Y' then
                      aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').service_ref_type_code: ' || l_qte_line_dtl_tbl(i).service_ref_type_code);
                  end if;

			   if l_qte_line_dtl_tbl(i).service_ref_type_code is null or
			      l_qte_line_dtl_tbl(i).service_ref_type_code = fnd_api.g_miss_char then

                      open c_service_ref_type_code( l_qte_line_dtl_tbl(i).quote_line_detail_id );
                      fetch c_service_ref_type_code into l_service_ref_type_code;
                      close c_service_ref_type_code;

	                 if aso_debug_pub.g_debug_flag = 'Y' then
                          aso_debug_pub.add('l_service_ref_type_code: ' || l_service_ref_type_code);
                      end if;

                      if l_service_ref_type_code is null then

                          x_return_status := fnd_api.g_ret_sts_error;

                          IF fnd_msg_pub.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                              FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
                              FND_MESSAGE.Set_Token('COLUMN', 'SERVICE_REF_TYPE_CODE', FALSE);
                              FND_MESSAGE.Set_Token('VALUE', l_qte_line_dtl_tbl(i).service_ref_type_code,FALSE);
                              FND_MSG_PUB.ADD;
                          END IF;

                          raise fnd_api.g_exc_error;

                      end if;

                  else

                      l_service_ref_type_code := l_qte_line_dtl_tbl(i).service_ref_type_code;

                  end if;

	             if aso_debug_pub.g_debug_flag = 'Y' then
                      aso_debug_pub.add('l_service_ref_type_code: ' || l_service_ref_type_code);
                      aso_debug_pub.add('l_qte_line_dtl_tbl('||i||').service_ref_line_id: ' || l_qte_line_dtl_tbl(i).service_ref_line_id);
                      aso_debug_pub.add('UPDATE_QUOTE_LINE: Before calling aso_validate_pvt.validate_service_ref_line_id');
                  end if;

                  aso_validate_pvt.validate_service_ref_line_id (
                                  p_init_msg_list         => fnd_api.g_false,
                                  p_service_ref_type_code => l_service_ref_type_code,
                                  p_service_ref_line_id   => l_qte_line_dtl_tbl(i).service_ref_line_id,
                                  p_qte_header_id         => l_Qte_Line_Rec.quote_header_id,
                                  x_return_status         => x_return_status,
                                  x_msg_count             => x_msg_count,
                                  x_msg_data              => x_msg_data);

	             if aso_debug_pub.g_debug_flag = 'Y' then
                      aso_debug_pub.add('UPDATE_QUOTE_LINE: After calling aso_validate_pvt.validate_service_ref_line_id');
                      aso_debug_pub.add('UPDATE_QUOTE_LINE: x_return_status: '|| x_return_status);
                  end if;

	             if x_return_status <> fnd_api.g_ret_sts_success then
                     raise fnd_api.g_exc_error;
                  end if;

              end if;

		    --End new code for Bug#3280130

          END LOOP; -- FOR i in 1..l_qte_line_dtl_tbl.count LOOP

          --You cannot select the line category code "Return" if a service is selected for a product.

          IF l_Qte_Line_Rec.line_category_code = 'RETURN' THEN

               OPEN c_service_exist;
               FETCH c_service_exist INTO l_qln_exist;

               IF c_service_exist%FOUND THEN

                   CLOSE c_service_exist;

                   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                  FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_LINE_CATEGORY');
                       FND_MSG_PUB.ADD;
	              END IF;

                   RAISE FND_API.G_EXC_ERROR;

               END IF;

               CLOSE c_service_exist;

          END IF;

      END IF; -- inter entity validation

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	aso_debug_pub.add('ASO_QUOTE_LINES_PVT: UPDATE_QUOTE_LINE: End of Inter entity validations');
	 end if;


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

	 -- order_type must exist and be active in OE_ORDER_TYPES
      l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row(l_Qte_Line_Rec.QUOTE_HEADER_ID);

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Validation level is set',1,'N');
		aso_debug_pub.add('l_control_rec.application_type_code: '|| l_control_rec.application_type_code ,1,'N');
	 end if;

      ASO_CHECK_TCA_PVT.check_line_account_info(
                      p_api_version                => 1.0,
                      p_init_msg_list              => FND_API.G_FALSE,
                      p_cust_account_id            => l_qte_header_rec.cust_account_id,
                      p_qte_line_rec               => l_Qte_Line_Rec,
                      p_line_shipment_tbl          => l_shipment_tbl,
                      p_application_type_code      => l_control_rec.application_type_code,
				  x_return_status              => l_return_status,
                      x_msg_count                  => l_msg_count,
                      x_msg_data                   => l_msg_data );

      IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
      END IF;

      ASO_TRADEIN_PVT.LineType( p_init_msg_list  => FND_API.G_FALSE,
                                p_qte_header_rec => l_qte_header_rec,
                                p_qte_line_rec   => l_Qte_Line_Rec,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data);

	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;

	  if aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('after order type'||  x_return_status, 1, 'Y');
	  end if;

       If (p_qte_header_rec.order_type_id = FND_API.G_MISS_NUM) then -- [This is for backward compatibility]
	       l_db_order_type_id  := l_qte_header_rec.order_type_id;
       else
	       l_db_order_type_id  :=  p_qte_header_rec.order_type_id;
       end if;

       If (l_db_order_type_id  = l_qte_header_rec.order_type_id) and (l_Qte_Line_Rec.order_line_type_id <> FND_API.G_MISS_NUM) Then

            ASO_validate_PVT.Validate_ln_type_for_ord_type(
                           p_init_msg_list     =>   FND_API.G_FALSE,
                           p_qte_header_rec    =>   l_qte_header_rec,
                           P_Qte_Line_rec      =>   l_Qte_Line_Rec,
                           x_return_status     =>   x_return_status,
                           x_msg_count         =>   x_msg_count,
                           x_msg_data          =>   x_msg_data);

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

       End if;


          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('x_return_status for Validate_ln_type_for_ord_type'||  x_return_status, 1, 'Y');
          END IF;


       ASO_TRADEIN_PVT.Validate_Line_Tradein( p_init_msg_list  => FND_API.G_FALSE,
                                              p_qte_header_rec => l_qte_header_rec,
                                              P_Qte_Line_rec   => l_Qte_Line_Rec,
                                              x_return_status  => x_return_status,
                                              x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data);

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
		 aso_debug_pub.add('Update_Quote_Line - after Validate_Line_Tradein:x_return_status: '||x_return_status, 1, 'N');
	  end if;

       ASO_TRADEIN_PVT.Validate_IB_Return_Qty( p_init_msg_list      =>   FND_API.G_FALSE,
                                               p_Qte_Line_rec       =>   l_Qte_Line_Rec,
                                               p_Qte_Line_Dtl_Tbl   =>   l_qte_line_dtl_tbl,
                                               x_return_status      =>   x_return_status,
                                               x_msg_count          =>   x_msg_count,
                                               x_msg_data           =>   x_msg_data);

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
		 aso_debug_pub.add('Update_Quote_Line - after Validate_IB_Return_Qty:x_return_status: '||x_return_status, 1, 'N');
	  end if;

       IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN

             ASO_VALIDATE_PVT.Validate_Sales_Credit_Return(
                            p_init_msg_list     => FND_API.G_FALSE,
                            p_sales_credit_tbl  => p_sales_credit_tbl,
                            p_qte_line_rec      => l_Qte_Line_Rec,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data);

             IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

       END IF;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
		 aso_debug_pub.add('Update_Quote_Line - before Validate_Agreement:l_Qte_Line_Rec.Agreement_Id: '||l_Qte_Line_Rec.Agreement_Id, 1, 'N');
	  end if;

       IF (l_Qte_Line_Rec.Agreement_Id IS NOT NULL AND l_Qte_Line_Rec.Agreement_Id <> FND_API.G_MISS_NUM) THEN

            ASO_VALIDATE_PVT.Validate_Agreement(
                           p_init_msg_list  => FND_API.G_FALSE,
                           P_Agreement_Id   => l_Qte_Line_Rec.Agreement_Id,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data);

	       IF aso_debug_pub.g_debug_flag = 'Y' THEN
		      aso_debug_pub.add('Update_Quote_Line - after Validate_Agreement:x_return_status: '||x_return_status, 1, 'N');
	       end if;

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

       END IF;

    -- Validate the invoice to cust party id and payment info, if any
     IF l_payment_tbl.count = 0   then
        l_payment_tbl := aso_utility_pvt.Query_Payment_Rows( l_qte_line_rec.QUOTE_HEADER_ID,l_qte_line_rec.quote_line_id);
     Else
	  -- check to see if the value has been changed, if not get orig value from db
	  if l_payment_tbl(1).payment_type_code = fnd_api.g_miss_char then
	   open get_payment_type_code(l_payment_tbl(1).payment_id);
	   fetch get_payment_type_code into l_payment_tbl(1).payment_type_code;
	   close get_payment_type_code;
	  end if;
     End if;

	-- bill to customer may not have been changed, if so get orig value from db
	if l_qte_line_rec.invoice_to_cust_party_id = fnd_api.g_miss_num then
	 open get_bill_to_party(l_qte_line_rec.quote_line_id);
	 fetch get_bill_to_party into l_qte_line_rec.invoice_to_cust_party_id;
	 close get_bill_to_party;
	end if;

     IF l_payment_tbl.count > 0 then
          l_payment_rec := l_payment_tbl(1);
        --IF l_payment_rec.payment_type_code = 'CREDIT_CARD' THEN
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before  calling Validate_cc_info ', 1, 'Y');
           END IF;
           l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row (l_qte_line_rec.Quote_Header_Id );

           aso_validate_pvt.Validate_cc_info
            (
                p_init_msg_list     =>  fnd_api.g_false,
                p_payment_rec       =>  l_payment_rec,
                p_qte_header_rec    =>  l_qte_header_rec,
                P_Qte_Line_rec      =>  l_qte_line_rec,
                x_return_status     =>  x_return_status,
                x_msg_count         =>  x_msg_count,
                x_msg_data          =>  x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after calling Validate_cc_info ', 1, 'Y');
              aso_debug_pub.add('Validate_cc_info  Return Status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;
        --END IF;

      End if;

      -- rset the payment tbl as the original count may have been changed becoz of the validation
      l_Payment_Tbl := l_orig_payment_tbl;

       x_qte_line_rec := l_Qte_Line_Rec;

       ASO_QUOTE_LINES_PKG.Update_Row(
          p_QUOTE_LINE_ID   	=> l_Qte_Line_Rec.QUOTE_LINE_ID,
          p_CREATION_DATE  	=> l_qte_line_rec.creation_date,
          p_CREATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_DATE  	=> SYSDATE,
          p_LAST_UPDATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_LOGIN  	=> G_LOGIN_ID,
          p_REQUEST_ID  	=> l_qte_line_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_qte_line_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  	=> l_qte_line_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE => l_qte_line_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID    	=> l_qte_line_rec.QUOTE_HEADER_ID,
          p_ORG_ID             	=> l_qte_line_rec.ORG_ID        ,
          p_LINE_CATEGORY_CODE  => l_qte_line_rec.LINE_CATEGORY_CODE ,
          p_ITEM_TYPE_CODE    	=> l_qte_line_rec.ITEM_TYPE_CODE ,
          p_LINE_NUMBER       	=> l_qte_line_rec.LINE_NUMBER,
          p_START_DATE_ACTIVE   => trunc(l_qte_line_rec.START_DATE_ACTIVE),
          p_END_DATE_ACTIVE     => trunc(l_qte_line_rec.END_DATE_ACTIVE)   ,
          p_ORDER_LINE_TYPE_ID  => l_qte_line_rec.ORDER_LINE_TYPE_ID ,
          p_INVOICE_TO_PARTY_SITE_ID
				=> l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID   ,
          p_INVOICE_TO_PARTY_ID => l_qte_line_rec.INVOICE_TO_PARTY_ID  ,
          p_INVOICE_TO_CUST_ACCOUNT_ID     => l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID  ,
          p_ORGANIZATION_ID     => l_qte_line_rec.ORGANIZATION_ID,
          p_INVENTORY_ITEM_ID   => l_qte_line_rec.INVENTORY_ITEM_ID ,
          p_QUANTITY   		=> l_qte_line_rec.QUANTITY   ,
          p_UOM_CODE    	=> l_qte_line_rec.UOM_CODE ,
          p_MARKETING_SOURCE_CODE_ID
				=> l_qte_line_rec.marketing_source_code_id,
          p_PRICE_LIST_ID    	=> l_qte_line_rec.PRICE_LIST_ID   ,
          p_PRICE_LIST_LINE_ID  => l_qte_line_rec.PRICE_LIST_LINE_ID,
          p_CURRENCY_CODE     	=> l_qte_line_rec.CURRENCY_CODE   ,
          p_LINE_LIST_PRICE     => l_qte_line_rec.LINE_LIST_PRICE    ,
          p_LINE_ADJUSTED_AMOUNT  => l_qte_line_rec.LINE_ADJUSTED_AMOUNT    ,
          p_LINE_ADJUSTED_PERCENT => l_qte_line_rec.LINE_ADJUSTED_PERCENT    ,
          p_LINE_QUOTE_PRICE  	   => l_qte_line_rec.LINE_QUOTE_PRICE   ,
          p_RELATED_ITEM_ID        => l_qte_line_rec.RELATED_ITEM_ID ,
          p_ITEM_RELATIONSHIP_TYPE => l_qte_line_rec.ITEM_RELATIONSHIP_TYPE   ,
          p_ACCOUNTING_RULE_ID     => l_qte_line_rec.ACCOUNTING_RULE_ID,
          p_INVOICING_RULE_ID      => l_qte_line_rec.INVOICING_RULE_ID,
          p_SPLIT_SHIPMENT_FLAG    => l_qte_line_rec.SPLIT_SHIPMENT_FLAG   ,
          p_BACKORDER_FLAG         => l_qte_line_rec.BACKORDER_FLAG   ,
          p_MINISITE_ID            => l_qte_line_rec.MINISITE_ID,
          p_SECTION_ID             => l_qte_line_rec.SECTION_ID,
          p_ATTRIBUTE_CATEGORY 	   => l_qte_line_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1     => l_qte_line_rec.ATTRIBUTE1,
          p_ATTRIBUTE2     => l_qte_line_rec.ATTRIBUTE2,
          p_ATTRIBUTE3     => l_qte_line_rec.ATTRIBUTE3,
          p_ATTRIBUTE4     => l_qte_line_rec.ATTRIBUTE4,
          p_ATTRIBUTE5     => l_qte_line_rec.ATTRIBUTE5,
          p_ATTRIBUTE6     => l_qte_line_rec.ATTRIBUTE6,
          p_ATTRIBUTE7     => l_qte_line_rec.ATTRIBUTE7,
          p_ATTRIBUTE8     => l_qte_line_rec.ATTRIBUTE8,
          p_ATTRIBUTE9     => l_qte_line_rec.ATTRIBUTE9,
          p_ATTRIBUTE10    => l_qte_line_rec.ATTRIBUTE10,
          p_ATTRIBUTE11    => l_qte_line_rec.ATTRIBUTE11,
          p_ATTRIBUTE12    => l_qte_line_rec.ATTRIBUTE12,
          p_ATTRIBUTE13    => l_qte_line_rec.ATTRIBUTE13,
          p_ATTRIBUTE14    => l_qte_line_rec.ATTRIBUTE14,
          p_ATTRIBUTE15    => l_qte_line_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  =>  l_qte_line_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  =>  l_qte_line_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  =>  l_qte_line_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  =>  l_qte_line_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  =>  l_qte_line_rec.ATTRIBUTE20,
		p_PRICED_PRICE_LIST_ID    => l_qte_line_rec.PRICED_PRICE_LIST_ID,
          p_AGREEMENT_ID            => l_qte_line_rec.AGREEMENT_ID,
          p_COMMITMENT_ID           => l_qte_line_rec.COMMITMENT_ID,
		p_DISPLAY_ARITHMETIC_OPERATOR => l_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR,
		p_LINE_TYPE_SOURCE_FLAG => l_qte_line_rec.LINE_TYPE_SOURCE_FLAG,
		p_SERVICE_ITEM_FLAG     => l_qte_line_rec.SERVICE_ITEM_FLAG,
		p_SERVICEABLE_PRODUCT_FLAG => l_qte_line_rec.SERVICEABLE_PRODUCT_FLAG,
		p_INVOICE_TO_CUST_PARTY_ID => l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID,
		P_Selling_Price_Change	   => l_qte_line_rec.Selling_Price_Change,
		P_Recalculate_flag	   => l_qte_line_rec.recalculate_flag,
		p_pricing_line_type_indicator	   => l_qte_line_rec.pricing_line_type_indicator,
          p_END_CUSTOMER_PARTY_ID         =>  l_Qte_Line_Rec.END_CUSTOMER_PARTY_ID,
          p_END_CUSTOMER_CUST_PARTY_ID    =>  l_Qte_Line_Rec.END_CUSTOMER_CUST_PARTY_ID,
          p_END_CUSTOMER_PARTY_SITE_ID    =>  l_Qte_Line_Rec.END_CUSTOMER_PARTY_SITE_ID,
          p_END_CUSTOMER_CUST_ACCOUNT_ID  =>  l_Qte_Line_Rec.END_CUSTOMER_CUST_ACCOUNT_ID,
		p_OBJECT_VERSION_NUMBER   =>  l_qte_line_rec.object_version_number,
          p_CHARGE_PERIODICITY_CODE => l_qte_line_rec.CHARGE_PERIODICITY_CODE, -- Recurring charges Change
          p_SHIP_MODEL_COMPLETE_FLAG => l_qte_line_rec.SHIP_MODEL_COMPLETE_FLAG,
          p_LINE_PAYNOW_CHARGES => l_qte_line_rec.LINE_PAYNOW_CHARGES,
          p_LINE_PAYNOW_TAX => l_qte_line_rec.LINE_PAYNOW_TAX,
          p_LINE_PAYNOW_SUBTOTAL => l_qte_line_rec.LINE_PAYNOW_SUBTOTAL,
		p_PRICING_QUANTITY_UOM => l_qte_line_rec.PRICING_QUANTITY_UOM,
		p_PRICING_QUANTITY => l_qte_line_rec.PRICING_QUANTITY,
          p_CONFIG_MODEL_TYPE => l_qte_line_rec.CONFIG_MODEL_TYPE,
	          -- ER 12879412
    P_PRODUCT_FISC_CLASSIFICATION => l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION,
    P_TRX_BUSINESS_CATEGORY =>   l_qte_line_rec.TRX_BUSINESS_CATEGORY
	  --ER 16531247
    ,P_ORDERED_ITEM_ID   => l_qte_line_rec.ORDERED_ITEM_ID
,P_ITEM_IDENTIFIER_TYPE => l_qte_line_rec.ITEM_IDENTIFIER_TYPE
,P_ORDERED_ITEM   => l_qte_line_rec.ORDERED_ITEM,
-- ,P_UNIT_PRICE     => p_qte_line_rec.UNIT_PRICE -- bug 17517305  commented for Bug 18930865
-- ER 21158830
		 P_LINE_UNIT_COST => l_qte_line_rec.LINE_UNIT_COST,
		 P_LINE_MARGIN_AMOUNT => l_qte_line_rec.LINE_MARGIN_AMOUNT,
		 P_LINE_MARGIN_PERCENT => l_qte_line_rec.LINE_MARGIN_PERCENT,
		 P_QUANTITY_UOM_CHANGE => l_qte_line_rec.QUANTITY_UOM_CHANGE  -- added for Bug 22237877
);

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Update_Quote_line - after line.update ', 1, 'N');
	end if;
-- line details

   -- Start Updating Line_category_code and order_line_type_id of configured lines if Model
   -- line Line_category_code and order_line_type_id value has changed Bmishra 02/15/02
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
   		aso_debug_pub.add('Update_Quote_lines - l_Qte_Line_Rec.line_category_code: '||l_Qte_Line_Rec.line_category_code, 1, 'Y');
   		aso_debug_pub.add('Update_Quote_lines - l_Qte_Line_Rec.order_line_type_id: '||l_Qte_Line_Rec.order_line_type_id, 1, 'Y');
	end if;
   IF (l_Qte_Line_Rec.line_category_code <> FND_API.G_MISS_CHAR) OR
                 (l_Qte_Line_Rec.order_line_type_id <> FND_API.G_MISS_NUM) THEN
				IF aso_debug_pub.g_debug_flag = 'Y' THEN
       				aso_debug_pub.add('Update_Quote_lines - l_Qte_Line_Rec.item_type_code: '||l_Qte_Line_Rec.item_type_code, 1, 'Y');
				end if;
       IF l_Qte_Line_Rec.item_type_code = FND_API.G_MISS_CHAR THEN
          OPEN c_item_type_code;
          FETCH c_item_type_code INTO l_item_type_code;
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
          		aso_debug_pub.add('Update_Quote_lines - Cursor c_item_type_code: l_item_type_code: '||l_item_type_code, 1, 'Y');
		end if;
          CLOSE c_item_type_code;
       ELSIF l_Qte_Line_Rec.item_type_code = 'MDL' THEN
          l_item_type_code := l_Qte_Line_Rec.item_type_code;
       END IF;

       IF l_item_type_code = 'MDL' THEN

          OPEN c_order_line_type_id(l_Qte_Line_Rec.quote_line_id);
          FETCH c_order_line_type_id INTO l_line_category_code, l_order_line_type_id,
								  l_config_header_id, l_config_revision_num;

          if aso_debug_pub.g_debug_flag = 'Y' then

             aso_debug_pub.add('c_order_line_type_id: l_line_category_code:  '||l_line_category_code);
             aso_debug_pub.add('c_order_line_type_id: l_order_line_type_id:  '||l_order_line_type_id);
             aso_debug_pub.add('c_order_line_type_id: l_config_header_id:    '||l_config_header_id);
             aso_debug_pub.add('c_order_line_type_id: l_config_revision_num: '||l_config_revision_num);

          end if;

          CLOSE c_order_line_type_id;

          BEGIN

              if aso_debug_pub.g_debug_flag = 'Y' then
                  aso_debug_pub.add('Update_Quote_lines - Updating l_line_category_code of children.');
              end if;

              if l_config_header_id is not null and l_config_revision_num is not null then

                  update aso_quote_lines_all
                  set line_category_code =  l_line_category_code,
                      order_line_type_id =  l_order_line_type_id,
                      last_update_date   =  sysdate,
                      last_updated_by    =  fnd_global.user_id,
                      last_update_login  =  fnd_global.conc_login_id
                  where  NVL(line_type_source_flag,'X') <> 'C'
                    and  quote_line_id in( select quote_line_id
                                          from aso_quote_line_details
                                          where ref_line_id is not null
                                          and ref_type_code       = 'CONFIG'
                                          and config_header_id    = l_config_header_id
                                          and config_revision_num = l_config_revision_num );

              end if;


                  EXCEPTION

                       WHEN OTHERS THEN
                            x_return_status := FND_API.G_RET_STS_ERROR;

			    if aso_debug_pub.g_debug_flag = 'Y' then
                       aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Update_quote_line: line_category_code
								  update, inside WHEN OTHERS EXCEPTION');
			    end if;


          END;

       END IF;
   END IF;

   -- End Updating Line_category_code and order_line_type_id of configured lines if Model
   -- line Line_category_code and order_line_type_id value has changed 02/15/02



FOR i in 1..l_qte_line_dtl_tbl.count LOOP
        l_qte_line_dtl_rec := l_qte_line_dtl_tbl(i);


  IF l_qte_line_dtl_tbl(i).operation_code = 'CREATE' THEN


        l_qte_line_dtl_rec.quote_line_id := l_qte_line_rec.quote_line_id;
        x_qte_line_dtl_tbl(i) := l_qte_line_dtl_rec;
        -- BC4J Fix
	   --x_qte_line_dtl_tbl(i).QUOTE_LINE_DETAIL_ID := null;

        ASO_QUOTE_LINE_DETAILS_PKG.Insert_Row(
          px_QUOTE_LINE_DETAIL_ID
			 	=> x_qte_line_dtl_tbl(i).QUOTE_LINE_DETAIL_ID,
          p_CREATION_DATE  	=> SYSDATE,
          p_CREATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_DATE  	=> SYSDATE,
          p_LAST_UPDATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_LOGIN  	=> G_LOGIN_ID,
          p_REQUEST_ID  	=> l_qte_line_dtl_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID
				=> l_qte_line_dtl_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  	=> l_qte_line_dtl_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE => l_qte_line_dtl_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_LINE_ID  	=> l_qte_line_dtl_rec.QUOTE_LINE_ID,
          p_CONFIG_HEADER_ID  	=> l_qte_line_dtl_rec.CONFIG_HEADER_ID,
          p_CONFIG_REVISION_NUM => l_qte_line_dtl_rec.CONFIG_REVISION_NUM,
          p_COMPLETE_CONFIGURATION_FLAG
			=> l_qte_line_dtl_rec.COMPLETE_CONFIGURATION_FLAG,
          p_VALID_CONFIGURATION_FLAG
			=> l_qte_line_dtl_rec.VALID_CONFIGURATION_FLAG,
          p_COMPONENT_CODE  	=> l_qte_line_dtl_rec.COMPONENT_CODE,
          p_SERVICE_COTERMINATE_FLAG
			=> l_qte_line_dtl_rec.SERVICE_COTERMINATE_FLAG,
          p_SERVICE_DURATION  	=> l_qte_line_dtl_rec.SERVICE_DURATION,
          p_SERVICE_PERIOD  	=> l_qte_line_dtl_rec.SERVICE_PERIOD,
          p_SERVICE_UNIT_SELLING_PERCENT
			=> l_qte_line_dtl_rec.SERVICE_UNIT_SELLING_PERCENT,
          p_SERVICE_UNIT_LIST_PERCENT
			=> l_qte_line_dtl_rec.SERVICE_UNIT_LIST_PERCENT,
          p_SERVICE_NUMBER  	=> l_qte_line_dtl_rec.SERVICE_NUMBER,
          p_UNIT_PERCENT_BASE_PRICE
			=> l_qte_line_dtl_rec.UNIT_PERCENT_BASE_PRICE,
          p_ATTRIBUTE_CATEGORY  => l_qte_line_dtl_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  	=> l_qte_line_dtl_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  	=> l_qte_line_dtl_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  	=> l_qte_line_dtl_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  	=> l_qte_line_dtl_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  	=> l_qte_line_dtl_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  	=> l_qte_line_dtl_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  	=> l_qte_line_dtl_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  	=> l_qte_line_dtl_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  	=> l_qte_line_dtl_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  	=> l_qte_line_dtl_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  	=> l_qte_line_dtl_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  	=> l_qte_line_dtl_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  	=> l_qte_line_dtl_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  	=> l_qte_line_dtl_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  	=> l_qte_line_dtl_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  => l_qte_line_dtl_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  => l_qte_line_dtl_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  => l_qte_line_dtl_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  => l_qte_line_dtl_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => l_qte_line_dtl_rec.ATTRIBUTE20,
		p_SERVICE_REF_TYPE_CODE  => l_qte_line_dtl_rec.SERVICE_REF_TYPE_CODE,
          p_SERVICE_REF_ORDER_NUMBER
			=> l_qte_line_dtl_rec.SERVICE_REF_ORDER_NUMBER,
          p_SERVICE_REF_LINE_NUMBER
			=> l_qte_line_dtl_rec.SERVICE_REF_LINE_NUMBER,
          p_SERVICE_REF_LINE_ID     => l_qte_line_dtl_rec.SERVICE_REF_LINE_ID,
          p_SERVICE_REF_SYSTEM_ID  => l_qte_line_dtl_rec.SERVICE_REF_SYSTEM_ID,
          p_SERVICE_REF_OPTION_NUMB
			=> l_qte_line_dtl_rec.SERVICE_REF_OPTION_NUMB,
          p_SERVICE_REF_SHIPMENT_NUMB
			=> l_qte_line_dtl_rec.SERVICE_REF_SHIPMENT_NUMB,
          p_RETURN_REF_TYPE       => l_qte_line_dtl_rec.RETURN_REF_TYPE,
          p_RETURN_REF_HEADER_ID  => l_qte_line_dtl_rec.RETURN_REF_HEADER_ID,
          p_RETURN_REF_LINE_ID    => l_qte_line_dtl_rec.RETURN_REF_LINE_ID,
          p_RETURN_ATTRIBUTE1     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE1,
          p_RETURN_ATTRIBUTE2     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE2,
          p_RETURN_ATTRIBUTE3     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE3,
          p_RETURN_ATTRIBUTE4     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE4,
          p_RETURN_ATTRIBUTE5     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE5,
          p_RETURN_ATTRIBUTE6     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE6,
          p_RETURN_ATTRIBUTE7     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE7,
          p_RETURN_ATTRIBUTE8     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE8,
          p_RETURN_ATTRIBUTE9     => l_qte_line_dtl_rec.RETURN_ATTRIBUTE9,
          p_RETURN_ATTRIBUTE10    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE10,
          p_RETURN_ATTRIBUTE11    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE11,
          p_RETURN_ATTRIBUTE15    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE15,
          p_RETURN_ATTRIBUTE12    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE12,
          p_RETURN_ATTRIBUTE13    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE13,
          p_RETURN_ATTRIBUTE14    => l_qte_line_dtl_rec.RETURN_ATTRIBUTE14,
          p_RETURN_REASON_CODE    => l_qte_line_dtl_rec.RETURN_REASON_CODE,
          p_CONFIG_ITEM_ID        => l_qte_line_dtl_rec.CONFIG_ITEM_ID,
          p_REF_TYPE_CODE         => l_qte_line_dtl_rec.REF_TYPE_CODE,
          p_REF_LINE_ID           => l_qte_line_dtl_rec.REF_LINE_ID,
		p_INSTANCE_ID           => l_qte_line_dtl_rec.INSTANCE_ID,
		p_BOM_SORT_ORDER        => l_qte_line_dtl_rec.BOM_SORT_ORDER,
	     p_CONFIG_DELTA          => l_qte_line_dtl_rec.CONFIG_DELTA,
	     p_CONFIG_INSTANCE_NAME  => l_qte_line_dtl_rec.CONFIG_INSTANCE_NAME,
		p_OBJECT_VERSION_NUMBER => l_qte_line_dtl_rec.OBJECT_VERSION_NUMBER,
          p_top_model_line_id     => l_qte_line_dtl_rec.top_model_line_id,
          p_ato_line_id           => l_qte_line_dtl_rec.ato_line_id,
          p_component_sequence_id => l_qte_line_dtl_rec.component_sequence_id
		);

          IF l_qte_line_dtl_rec.service_ref_type_code = 'QUOTE' THEN
              OPEN C_Line_relation(l_qte_line_dtl_rec.service_ref_line_id, l_qte_line_dtl_rec.quote_line_id);
              FETCH C_Line_relation INTO l_line_rel;
              IF C_Line_relation%NOTFOUND THEN
                  l_line_rtlship_rec.operation_code         := 'CREATE';
                  l_line_rtlship_rec.quote_line_id          := l_qte_line_dtl_rec.SERVICE_REF_LINE_ID;
                  l_line_rtlship_rec.related_quote_line_id  := x_qte_line_rec.quote_line_id;
                  l_line_rtlship_rec.relationship_type_code := 'SERVICE';
                  l_line_rtlship_rec.reciprocal_flag        := FND_API.G_FALSE;

                  ASO_LINE_RLTSHIP_PVT.Create_line_rltship(
                      P_Api_Version_Number   => 1.0,
                      P_LINE_RLTSHIP_Rec     => l_line_rtlship_rec,
                      X_LINE_RELATIONSHIP_ID => x_relationship_id,
                      X_Return_Status        => x_return_status,
                      X_Msg_Count            => x_msg_count,
                      X_Msg_Data             => x_msg_data
                  );
              END IF;
          END IF;

    ELSIF l_qte_line_dtl_tbl(i).operation_code = 'UPDATE' THEN

        x_qte_line_dtl_tbl(i) := l_qte_line_dtl_rec;

            ASO_QUOTE_LINE_DETAILS_PKG.Update_Row(
          p_QUOTE_LINE_DETAIL_ID  => l_qte_line_dtl_rec.QUOTE_LINE_DETAIL_ID,
          p_CREATION_DATE  	  => l_qte_line_dtl_rec.creation_date,
          p_CREATED_BY  	  => G_USER_ID,
          p_LAST_UPDATE_DATE  	  => SYSDATE,
          p_LAST_UPDATED_BY  	  => G_USER_ID,
          p_LAST_UPDATE_LOGIN     => G_LOGIN_ID,
          p_REQUEST_ID  	  => l_qte_line_dtl_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID
				=> l_qte_line_dtl_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  	=> l_qte_line_dtl_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE => l_qte_line_dtl_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_LINE_ID  	=> l_qte_line_dtl_rec.QUOTE_LINE_ID,
          p_CONFIG_HEADER_ID  	=> l_qte_line_dtl_rec.CONFIG_HEADER_ID,
          p_CONFIG_REVISION_NUM => l_qte_line_dtl_rec.CONFIG_REVISION_NUM,
          p_COMPLETE_CONFIGURATION_FLAG
			=> l_qte_line_dtl_rec.COMPLETE_CONFIGURATION_FLAG,
          p_VALID_CONFIGURATION_FLAG
			=> l_qte_line_dtl_rec.VALID_CONFIGURATION_FLAG,
          p_COMPONENT_CODE  	=> l_qte_line_dtl_rec.COMPONENT_CODE,
          p_SERVICE_COTERMINATE_FLAG
			=> l_qte_line_dtl_rec.SERVICE_COTERMINATE_FLAG,
          p_SERVICE_DURATION  	=> l_qte_line_dtl_rec.SERVICE_DURATION,
          p_SERVICE_PERIOD  	=> l_qte_line_dtl_rec.SERVICE_PERIOD,
          p_SERVICE_UNIT_SELLING_PERCENT
			=> l_qte_line_dtl_rec.SERVICE_UNIT_SELLING_PERCENT,
          p_SERVICE_UNIT_LIST_PERCENT
			=> l_qte_line_dtl_rec.SERVICE_UNIT_LIST_PERCENT,
          p_SERVICE_NUMBER  => l_qte_line_dtl_rec.SERVICE_NUMBER,
          p_UNIT_PERCENT_BASE_PRICE
			=> l_qte_line_dtl_rec.UNIT_PERCENT_BASE_PRICE,
          p_ATTRIBUTE_CATEGORY  => l_qte_line_dtl_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  	=> l_qte_line_dtl_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  	=> l_qte_line_dtl_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  	=> l_qte_line_dtl_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  	=> l_qte_line_dtl_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  	=> l_qte_line_dtl_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  	=> l_qte_line_dtl_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  	=> l_qte_line_dtl_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  	=> l_qte_line_dtl_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  	=> l_qte_line_dtl_rec.ATTRIBUTE9,
          p_ATTRIBUTE10 	=> l_qte_line_dtl_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  	=> l_qte_line_dtl_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  	=> l_qte_line_dtl_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  	=> l_qte_line_dtl_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  	=> l_qte_line_dtl_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  	=> l_qte_line_dtl_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  =>  l_qte_line_dtl_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  =>  l_qte_line_dtl_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  =>  l_qte_line_dtl_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  =>  l_qte_line_dtl_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => l_qte_line_dtl_rec.ATTRIBUTE20,
		p_SERVICE_REF_TYPE_CODE  => l_qte_line_dtl_rec.SERVICE_REF_TYPE_CODE,
          p_SERVICE_REF_ORDER_NUMBER
				=> l_qte_line_dtl_rec.SERVICE_REF_ORDER_NUMBER,
          p_SERVICE_REF_LINE_NUMBER
				=> l_qte_line_dtl_rec.SERVICE_REF_LINE_NUMBER,
          p_SERVICE_REF_LINE_ID => l_qte_line_dtl_rec.SERVICE_REF_LINE_ID,
          p_SERVICE_REF_SYSTEM_ID  => l_qte_line_dtl_rec.SERVICE_REF_SYSTEM_ID,
          p_SERVICE_REF_OPTION_NUMB
				=> l_qte_line_dtl_rec.SERVICE_REF_OPTION_NUMB,
          p_SERVICE_REF_SHIPMENT_NUMB
			       => l_qte_line_dtl_rec.SERVICE_REF_SHIPMENT_NUMB,
          p_RETURN_REF_TYPE  	=> l_qte_line_dtl_rec.RETURN_REF_TYPE,
          p_RETURN_REF_HEADER_ID=> l_qte_line_dtl_rec.RETURN_REF_HEADER_ID,
          p_RETURN_REF_LINE_ID  => l_qte_line_dtl_rec.RETURN_REF_LINE_ID,
          p_RETURN_ATTRIBUTE1  	=> l_qte_line_dtl_rec.RETURN_ATTRIBUTE1,
          p_RETURN_ATTRIBUTE2  	=> l_qte_line_dtl_rec.RETURN_ATTRIBUTE2,
          p_RETURN_ATTRIBUTE3  	=> l_qte_line_dtl_rec.RETURN_ATTRIBUTE3,
          p_RETURN_ATTRIBUTE4  	=> l_qte_line_dtl_rec.RETURN_ATTRIBUTE4,
          p_RETURN_ATTRIBUTE5  	=> l_qte_line_dtl_rec.RETURN_ATTRIBUTE5,
          p_RETURN_ATTRIBUTE6  	=> l_qte_line_dtl_rec.RETURN_ATTRIBUTE6,
          p_RETURN_ATTRIBUTE7  	=> l_qte_line_dtl_rec.RETURN_ATTRIBUTE7,
          p_RETURN_ATTRIBUTE8  	=> l_qte_line_dtl_rec.RETURN_ATTRIBUTE8,
          p_RETURN_ATTRIBUTE9  	=> l_qte_line_dtl_rec.RETURN_ATTRIBUTE9,
          p_RETURN_ATTRIBUTE10  => l_qte_line_dtl_rec.RETURN_ATTRIBUTE10,
          p_RETURN_ATTRIBUTE11  => l_qte_line_dtl_rec.RETURN_ATTRIBUTE11,
          p_RETURN_ATTRIBUTE15  => l_qte_line_dtl_rec.RETURN_ATTRIBUTE15,
          p_RETURN_ATTRIBUTE12  => l_qte_line_dtl_rec.RETURN_ATTRIBUTE12,
          p_RETURN_ATTRIBUTE13  => l_qte_line_dtl_rec.RETURN_ATTRIBUTE13,
          p_RETURN_ATTRIBUTE14  => l_qte_line_dtl_rec.RETURN_ATTRIBUTE14,
          p_RETURN_REASON_CODE    => l_qte_line_dtl_rec.RETURN_REASON_CODE,
          p_CONFIG_ITEM_ID    => l_qte_line_dtl_rec.CONFIG_ITEM_ID,
          p_REF_TYPE_CODE       => l_qte_line_dtl_rec.REF_TYPE_CODE,
          p_REF_LINE_ID         => l_qte_line_dtl_rec.REF_LINE_ID,
		p_INSTANCE_ID         => l_qte_line_dtl_rec.INSTANCE_ID,
		p_BOM_SORT_ORDER      => l_qte_line_dtl_rec.BOM_SORT_ORDER,
		p_CONFIG_DELTA          => l_qte_line_dtl_rec.CONFIG_DELTA,
	     p_CONFIG_INSTANCE_NAME  => l_qte_line_dtl_rec.CONFIG_INSTANCE_NAME,
		p_OBJECT_VERSION_NUMBER => l_qte_line_dtl_rec.OBJECT_VERSION_NUMBER,
          p_top_model_line_id     => l_qte_line_dtl_rec.top_model_line_id,
          p_ato_line_id           => l_qte_line_dtl_rec.ato_line_id,
          p_component_sequence_id => l_qte_line_dtl_rec.component_sequence_id
		);

         l_db_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows (P_Qte_Line_Id => x_qte_line_rec.quote_line_id );
         IF l_db_qte_line_dtl_tbl(1).service_ref_type_code = 'QUOTE' THEN
             OPEN C_Line_relation(l_db_qte_line_dtl_tbl(1).service_ref_line_id, l_db_qte_line_dtl_tbl(1).quote_line_id);
             FETCH C_Line_relation INTO l_line_rel;
             IF C_Line_relation%NOTFOUND THEN
                 l_line_rtlship_rec.operation_code         := 'CREATE';
                 l_line_rtlship_rec.quote_line_id          := l_db_qte_line_dtl_tbl(1).SERVICE_REF_LINE_ID;
                 l_line_rtlship_rec.related_quote_line_id  := x_qte_line_rec.quote_line_id;
                 l_line_rtlship_rec.relationship_type_code := 'SERVICE';
                 l_line_rtlship_rec.reciprocal_flag        := FND_API.G_FALSE;
                 ASO_LINE_RLTSHIP_PVT.Create_line_rltship(
                     P_Api_Version_Number   => 1.0,
      	             P_LINE_RLTSHIP_Rec     => l_line_rtlship_rec,
                     X_LINE_RELATIONSHIP_ID => x_relationship_id,
                     X_Return_Status        => x_return_status,
                     X_Msg_Count            => x_msg_count,
                     X_Msg_Data             => x_msg_data
                 );
            END IF;
        END IF;

  ELSIF l_qte_line_dtl_tbl(i).operation_code = 'DELETE' THEN

        ASO_QUOTE_LINE_DETAILS_PKG.Delete_Row(
         p_QUOTE_LINE_DETAIL_ID => l_qte_line_dtl_rec.quote_line_detail_id);
  END IF;

END LOOP;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Update_Quote_line - after line_details.update ', 1, 'Y');
	end if;

-- Service line quantity update Bmishra 01/09/02
  l_call_update := FND_API.G_FALSE;
  IF l_Qte_Line_Rec.inventory_item_id = FND_API.G_MISS_NUM THEN
     OPEN c_inventory_item_id;
     FETCH c_inventory_item_id INTO l_Qte_Line_Rec.inventory_item_id;
     CLOSE c_inventory_item_id;
  END IF;
  OPEN c_service (l_Qte_Line_Rec.quote_line_id);
  FETCH c_service INTO l_service_item_flag, l_serviceable_product_flag;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
  		aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Update_Quote_lines: l_service_item_flag'||l_service_item_flag,1,'N');
  		aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Update_Quote_lines: l_serviceable_product_flag'||l_serviceable_product_flag, 1, 'N');
	end if;
  IF c_service%FOUND THEN
     CLOSE c_service;
     IF l_service_item_flag = 'Y' THEN
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Update_Quote_lines: Inside IF l_service_item_flag = Y',1,'N');
	end if;
        l_service := FND_API.G_TRUE;
        l_call_update := FND_API.G_TRUE;
     ELSIF l_serviceable_product_flag = 'Y' THEN
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Update_Quote_lines: Inside IF l_serviceable_product_flag = Y',
1,'N');
	end if;
        l_service := FND_API.G_FALSE;
        l_call_update := FND_API.G_TRUE;
     END IF;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
     		aso_debug_pub.add('ASO_QUOTE_LINES_PVT: Update_Quote_lines: l_call_update'||l_call_update,1,'N');
	end if;
     IF l_call_update = FND_API.G_TRUE THEN
        ASO_QUOTE_LINES_PVT.service_item_qty_update
         (p_qte_line_rec  => l_Qte_Line_Rec ,
          p_service_item_flag  => l_service,
          x_return_status => X_return_status
          );
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
     		aso_debug_pub.add('Update_Quote_lines - after call to ASO_QUOTE_LINES_PVT.service_item_qty_update '||x_return_status, 1, 'Y');
	end if;
     END IF;
  ELSE
     CLOSE c_service;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
     		aso_debug_pub.add('Update_quote_lines, Item not found in inventry',1,'N');
	end if;
  END IF;

-- End of Service line quantity update Bmishra 01/09/02


-- sales credits
   FOR i in 1..p_Sales_Credit_Tbl.count LOOP

     l_Sales_Credit_rec := p_sales_credit_tbl(i);
     x_sales_credit_tbl(i) := l_sales_credit_rec;

     IF l_sales_credit_rec.operation_code = 'CREATE' THEN
     l_sales_credit_rec.quote_line_id := l_qte_line_rec.quote_line_id;
     l_sales_credit_rec.quote_header_id := l_qte_line_rec.quote_header_id;
     -- BC4J Fix
	--x_sales_credit_tbl(i).sales_credit_id := NULL;
       ASO_SALES_CREDITS_PKG.Insert_Row(
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => l_sales_CREDIT_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_sales_CREDIT_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_sales_CREDIT_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_sales_CREDIT_rec.PROGRAM_UPDATE_DATE,
          px_SALES_CREDIT_ID  => x_SALES_CREDIT_tbl(i).SALES_CREDIT_ID,
          p_QUOTE_HEADER_ID  => l_sales_CREDIT_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_sales_CREDIT_rec.QUOTE_LINE_ID,
          p_PERCENT  => l_sales_CREDIT_rec.PERCENT,
          p_RESOURCE_ID  => l_sales_CREDIT_rec.RESOURCE_ID,
          p_RESOURCE_GROUP_ID  => l_sales_CREDIT_rec.RESOURCE_GROUP_ID,
          p_EMPLOYEE_PERSON_ID  => l_sales_CREDIT_rec.EMPLOYEE_PERSON_ID,
          p_SALES_CREDIT_TYPE_ID  => l_sales_CREDIT_rec.SALES_CREDIT_TYPE_ID,
--          p_SECURITY_GROUP_ID  => l_sales_CREDIT_rec.SECURITY_GROUP_ID,
          p_ATTRIBUTE_CATEGORY_CODE  => l_sales_CREDIT_rec.ATTRIBUTE_CATEGORY_CODE,
          p_ATTRIBUTE1  => l_sales_CREDIT_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_sales_CREDIT_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_sales_CREDIT_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_sales_CREDIT_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_sales_CREDIT_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_sales_CREDIT_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_sales_CREDIT_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_sales_CREDIT_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_sales_CREDIT_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_sales_CREDIT_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_sales_CREDIT_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_sales_CREDIT_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_sales_CREDIT_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_sales_CREDIT_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_sales_CREDIT_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  => l_sales_CREDIT_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  => l_sales_CREDIT_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  => l_sales_CREDIT_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  => l_sales_CREDIT_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => l_sales_CREDIT_rec.ATTRIBUTE20,
		p_SYSTEM_ASSIGNED_FLAG  => 'N',
          p_CREDIT_RULE_ID  => l_sales_CREDIT_rec.CREDIT_RULE_ID,
          p_OBJECT_VERSION_NUMBER  => l_sales_CREDIT_rec.OBJECT_VERSION_NUMBER);

        ELSIF l_sales_credit_rec.operation_code = 'UPDATE' THEN
               ASO_SALES_CREDITS_PKG.Update_Row(
          p_CREATION_DATE  => l_sales_CREDIT_rec.creation_date,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_REQUEST_ID  => l_sales_CREDIT_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID=> l_sales_CREDIT_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_sales_CREDIT_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_sales_CREDIT_rec.PROGRAM_UPDATE_DATE,
          p_SALES_CREDIT_ID  => l_SALES_CREDIT_rec.SALES_CREDIT_ID,
          p_QUOTE_HEADER_ID  => l_sales_CREDIT_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_sales_CREDIT_rec.QUOTE_LINE_ID,
          p_PERCENT  => l_sales_CREDIT_rec.PERCENT,
          p_RESOURCE_ID  => l_sales_CREDIT_rec.RESOURCE_ID,
          p_RESOURCE_GROUP_ID  => l_sales_CREDIT_rec.RESOURCE_GROUP_ID,
          p_EMPLOYEE_PERSON_ID  => l_sales_CREDIT_rec.EMPLOYEE_PERSON_ID,
          p_SALES_CREDIT_TYPE_ID  => l_sales_CREDIT_rec.SALES_CREDIT_TYPE_ID,
--          p_SECURITY_GROUP_ID  => l_sales_CREDIT_rec.SECURITY_GROUP_ID,
          p_ATTRIBUTE_CATEGORY_CODE  => l_sales_CREDIT_rec.ATTRIBUTE_CATEGORY_CODE,
          p_ATTRIBUTE1  => l_sales_CREDIT_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_sales_CREDIT_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_sales_CREDIT_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_sales_CREDIT_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_sales_CREDIT_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_sales_CREDIT_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_sales_CREDIT_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_sales_CREDIT_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_sales_CREDIT_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_sales_CREDIT_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_sales_CREDIT_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_sales_CREDIT_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_sales_CREDIT_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_sales_CREDIT_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_sales_CREDIT_rec.ATTRIBUTE15,
          p_ATTRIBUTE16  => l_sales_CREDIT_rec.ATTRIBUTE16,
          p_ATTRIBUTE17  => l_sales_CREDIT_rec.ATTRIBUTE17,
          p_ATTRIBUTE18  => l_sales_CREDIT_rec.ATTRIBUTE18,
          p_ATTRIBUTE19  => l_sales_CREDIT_rec.ATTRIBUTE19,
          p_ATTRIBUTE20  => l_sales_CREDIT_rec.ATTRIBUTE20,
		p_SYSTEM_ASSIGNED_FLAG  => 'N',
          p_CREDIT_RULE_ID  => l_sales_CREDIT_rec.CREDIT_RULE_ID,
		p_OBJECT_VERSION_NUMBER  => l_sales_CREDIT_rec.OBJECT_VERSION_NUMBER);

         ELSIF l_sales_credit_rec.operation_code = 'DELETE' THEN
                 ASO_SALES_CREDITS_PKG.Delete_Row(
          p_SALES_CREDIT_ID  => l_SALES_CREDIT_rec.SALES_CREDIT_ID);

         END IF;
END LOOP;


-- sales credits
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Quote_Percent: BEFORE: l_qte_line_rec.quote_header_id: '||l_qte_line_rec.quote_header_id,1,'N');
            aso_debug_pub.add('Validate_Quote_Percent: BEFORE: l_qte_line_rec.quote_line_id:   '||l_qte_line_rec.quote_line_id,1,'N');
	end if;

            IF ( P_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM) THEN
                IF x_sales_credit_tbl.count > 0 THEN
                    IF x_sales_credit_tbl(1).quote_header_id IS NULL OR x_sales_credit_tbl(1).quote_header_id = FND_API.G_MISS_NUM THEN
                        x_sales_credit_tbl(1).quote_header_id := l_qte_line_rec.quote_header_id;
                    END IF;
                    IF x_sales_credit_tbl(1).quote_line_id IS NULL OR x_sales_credit_tbl(1).quote_line_id = FND_API.G_MISS_NUM THEN
                        x_sales_credit_tbl(1).quote_line_id := l_qte_line_rec.quote_line_id;
                    END IF;

                    ASO_VALIDATE_PVT.Validate_Quote_Percent(
                        p_init_msg_list             => FND_API.G_FALSE,
                        p_sales_credit_tbl          => x_sales_credit_tbl,
                        x_return_status             => x_return_status,
                        x_msg_count                 => x_msg_count,
                        x_msg_data                  => x_msg_data
                    );
                    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END IF;
            END IF;

-- end sales credits

 -- check for duplicate promotions, see bug 4521799
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Before  calling Validate_Promotion price_attr_tbl.count: '|| p_price_attributes_tbl.count, 1, 'Y');
  END IF;

  ASO_VALIDATE_PVT.Validate_Promotion (
     P_Api_Version_Number       => 1.0,
     P_Init_Msg_List            => FND_API.G_FALSE,
     P_Commit                   => FND_API.G_FALSE,
     p_price_attr_tbl           => p_price_attributes_tbl,
     x_price_attr_tbl           => lx_price_attr_tbl,
     x_return_status            => x_return_status,
     x_msg_count                => x_msg_count,
     x_msg_data                 => x_msg_data);

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('after calling Validate_Promotion ', 1, 'Y');
      aso_debug_pub.add('Validate_Promotion  Return Status: '||x_return_status, 1, 'Y');
   END IF;

   if x_return_status <> fnd_api.g_ret_sts_success then
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   end if;


 -- end of check for duplicate promotions

-- price attributes

    FOR i in 1..l_price_attributes_tbl.count LOOP

     l_price_attributes_rec := l_price_attributes_tbl(i);
    -- l_price_attributes_rec.quote_line_id := p_qte_line_rec.quote_line_id;
     x_price_attributes_tbl(i) := l_price_attributes_rec;

     IF l_price_attributes_rec.operation_code = 'CREATE' THEN
        l_price_attributes_rec.quote_line_id := l_qte_line_rec.quote_line_id;
      l_price_attributes_rec.quote_header_id := l_qte_line_rec.quote_header_id;
       -- BC4J Fix
	  -- x_price_attributes_tbl(1).price_attribute_id := NULL;

   ASO_PRICE_ATTRIBUTES_PKG.Insert_Row(
          px_PRICE_ATTRIBUTE_ID   => x_price_attributes_tbl(i).price_attribute_id,
          p_CREATION_DATE  	=> SYSDATE,
          p_CREATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_DATE  	=> SYSDATE,
          p_LAST_UPDATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_LOGIN  	=> G_LOGIN_ID,
          p_REQUEST_ID  	=> l_Qte_Line_Rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_Qte_Line_Rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  	=> l_Qte_Line_Rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_Qte_Line_Rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID      => l_Qte_Line_Rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID        => l_price_attributes_rec.quote_line_id,
          p_FLEX_TITLE           => l_price_attributes_rec.flex_title,
          p_PRICING_CONTEXT      => l_price_attributes_rec.pricing_context,
          p_PRICING_ATTRIBUTE1    => l_price_attributes_rec.PRICING_ATTRIBUTE1,
          p_PRICING_ATTRIBUTE2    => l_price_attributes_rec.PRICING_ATTRIBUTE2,
          p_PRICING_ATTRIBUTE3    => l_price_attributes_rec.PRICING_ATTRIBUTE3,
          p_PRICING_ATTRIBUTE4    => l_price_attributes_rec.PRICING_ATTRIBUTE4,
          p_PRICING_ATTRIBUTE5    => l_price_attributes_rec.PRICING_ATTRIBUTE5,
          p_PRICING_ATTRIBUTE6    => l_price_attributes_rec.PRICING_ATTRIBUTE6,
          p_PRICING_ATTRIBUTE7    => l_price_attributes_rec.PRICING_ATTRIBUTE7,
          p_PRICING_ATTRIBUTE8    => l_price_attributes_rec.PRICING_ATTRIBUTE8,
          p_PRICING_ATTRIBUTE9    => l_price_attributes_rec.PRICING_ATTRIBUTE9,
        p_PRICING_ATTRIBUTE10    => l_price_attributes_rec.PRICING_ATTRIBUTE10,
        p_PRICING_ATTRIBUTE11    => l_price_attributes_rec.PRICING_ATTRIBUTE11,
        p_PRICING_ATTRIBUTE12    => l_price_attributes_rec.PRICING_ATTRIBUTE12,
        p_PRICING_ATTRIBUTE13    => l_price_attributes_rec.PRICING_ATTRIBUTE13,
        p_PRICING_ATTRIBUTE14    => l_price_attributes_rec.PRICING_ATTRIBUTE14,
        p_PRICING_ATTRIBUTE15    => l_price_attributes_rec.PRICING_ATTRIBUTE15,
        p_PRICING_ATTRIBUTE16    => l_price_attributes_rec.PRICING_ATTRIBUTE16,
        p_PRICING_ATTRIBUTE17    => l_price_attributes_rec.PRICING_ATTRIBUTE17,
        p_PRICING_ATTRIBUTE18    => l_price_attributes_rec.PRICING_ATTRIBUTE18,
        p_PRICING_ATTRIBUTE19    => l_price_attributes_rec.PRICING_ATTRIBUTE19,
        p_PRICING_ATTRIBUTE20    => l_price_attributes_rec.PRICING_ATTRIBUTE20,
        p_PRICING_ATTRIBUTE21    => l_price_attributes_rec.PRICING_ATTRIBUTE21,
        p_PRICING_ATTRIBUTE22    => l_price_attributes_rec.PRICING_ATTRIBUTE22,
        p_PRICING_ATTRIBUTE23    => l_price_attributes_rec.PRICING_ATTRIBUTE23,
        p_PRICING_ATTRIBUTE24    => l_price_attributes_rec.PRICING_ATTRIBUTE24,
        p_PRICING_ATTRIBUTE25    => l_price_attributes_rec.PRICING_ATTRIBUTE25,
        p_PRICING_ATTRIBUTE26    => l_price_attributes_rec.PRICING_ATTRIBUTE26,
        p_PRICING_ATTRIBUTE27    => l_price_attributes_rec.PRICING_ATTRIBUTE27,
        p_PRICING_ATTRIBUTE28    => l_price_attributes_rec.PRICING_ATTRIBUTE28,
        p_PRICING_ATTRIBUTE29    => l_price_attributes_rec.PRICING_ATTRIBUTE29,
        p_PRICING_ATTRIBUTE30    => l_price_attributes_rec.PRICING_ATTRIBUTE30,
        p_PRICING_ATTRIBUTE31    => l_price_attributes_rec.PRICING_ATTRIBUTE31,
        p_PRICING_ATTRIBUTE32    => l_price_attributes_rec.PRICING_ATTRIBUTE32,
        p_PRICING_ATTRIBUTE33    => l_price_attributes_rec.PRICING_ATTRIBUTE33,
        p_PRICING_ATTRIBUTE34    => l_price_attributes_rec.PRICING_ATTRIBUTE34,
        p_PRICING_ATTRIBUTE35    => l_price_attributes_rec.PRICING_ATTRIBUTE35,
        p_PRICING_ATTRIBUTE36    => l_price_attributes_rec.PRICING_ATTRIBUTE36,
        p_PRICING_ATTRIBUTE37    => l_price_attributes_rec.PRICING_ATTRIBUTE37,
        p_PRICING_ATTRIBUTE38    => l_price_attributes_rec.PRICING_ATTRIBUTE38,
        p_PRICING_ATTRIBUTE39    => l_price_attributes_rec.PRICING_ATTRIBUTE39,
        p_PRICING_ATTRIBUTE40    => l_price_attributes_rec.PRICING_ATTRIBUTE40,
        p_PRICING_ATTRIBUTE41    => l_price_attributes_rec.PRICING_ATTRIBUTE41,
        p_PRICING_ATTRIBUTE42    => l_price_attributes_rec.PRICING_ATTRIBUTE42,
        p_PRICING_ATTRIBUTE43    => l_price_attributes_rec.PRICING_ATTRIBUTE43,
        p_PRICING_ATTRIBUTE44    => l_price_attributes_rec.PRICING_ATTRIBUTE44,
        p_PRICING_ATTRIBUTE45    => l_price_attributes_rec.PRICING_ATTRIBUTE45,
        p_PRICING_ATTRIBUTE46    => l_price_attributes_rec.PRICING_ATTRIBUTE46,
        p_PRICING_ATTRIBUTE47    => l_price_attributes_rec.PRICING_ATTRIBUTE47,
        p_PRICING_ATTRIBUTE48    => l_price_attributes_rec.PRICING_ATTRIBUTE48,
        p_PRICING_ATTRIBUTE49    => l_price_attributes_rec.PRICING_ATTRIBUTE49,
        p_PRICING_ATTRIBUTE50    => l_price_attributes_rec.PRICING_ATTRIBUTE50,
        p_PRICING_ATTRIBUTE51    => l_price_attributes_rec.PRICING_ATTRIBUTE51,
        p_PRICING_ATTRIBUTE52    => l_price_attributes_rec.PRICING_ATTRIBUTE52,
        p_PRICING_ATTRIBUTE53    => l_price_attributes_rec.PRICING_ATTRIBUTE53,
        p_PRICING_ATTRIBUTE54    => l_price_attributes_rec.PRICING_ATTRIBUTE54,
        p_PRICING_ATTRIBUTE55    => l_price_attributes_rec.PRICING_ATTRIBUTE55,
        p_PRICING_ATTRIBUTE56    => l_price_attributes_rec.PRICING_ATTRIBUTE56,
        p_PRICING_ATTRIBUTE57    => l_price_attributes_rec.PRICING_ATTRIBUTE57,
        p_PRICING_ATTRIBUTE58    => l_price_attributes_rec.PRICING_ATTRIBUTE58,
        p_PRICING_ATTRIBUTE59    => l_price_attributes_rec.PRICING_ATTRIBUTE59,
        p_PRICING_ATTRIBUTE60    => l_price_attributes_rec.PRICING_ATTRIBUTE60,
        p_PRICING_ATTRIBUTE61    => l_price_attributes_rec.PRICING_ATTRIBUTE61,
        p_PRICING_ATTRIBUTE62    => l_price_attributes_rec.PRICING_ATTRIBUTE62,
        p_PRICING_ATTRIBUTE63    => l_price_attributes_rec.PRICING_ATTRIBUTE63,
        p_PRICING_ATTRIBUTE64    => l_price_attributes_rec.PRICING_ATTRIBUTE64,
        p_PRICING_ATTRIBUTE65    => l_price_attributes_rec.PRICING_ATTRIBUTE65,
        p_PRICING_ATTRIBUTE66    => l_price_attributes_rec.PRICING_ATTRIBUTE66,
        p_PRICING_ATTRIBUTE67    => l_price_attributes_rec.PRICING_ATTRIBUTE67,
        p_PRICING_ATTRIBUTE68    => l_price_attributes_rec.PRICING_ATTRIBUTE68,
        p_PRICING_ATTRIBUTE69    => l_price_attributes_rec.PRICING_ATTRIBUTE69,
        p_PRICING_ATTRIBUTE70    => l_price_attributes_rec.PRICING_ATTRIBUTE70,
        p_PRICING_ATTRIBUTE71    => l_price_attributes_rec.PRICING_ATTRIBUTE71,
        p_PRICING_ATTRIBUTE72    => l_price_attributes_rec.PRICING_ATTRIBUTE72,
        p_PRICING_ATTRIBUTE73    => l_price_attributes_rec.PRICING_ATTRIBUTE73,
        p_PRICING_ATTRIBUTE74    => l_price_attributes_rec.PRICING_ATTRIBUTE74,
        p_PRICING_ATTRIBUTE75    => l_price_attributes_rec.PRICING_ATTRIBUTE75,
        p_PRICING_ATTRIBUTE76    => l_price_attributes_rec.PRICING_ATTRIBUTE76,
        p_PRICING_ATTRIBUTE77    => l_price_attributes_rec.PRICING_ATTRIBUTE77,
        p_PRICING_ATTRIBUTE78    => l_price_attributes_rec.PRICING_ATTRIBUTE78,
        p_PRICING_ATTRIBUTE79    => l_price_attributes_rec.PRICING_ATTRIBUTE79,
        p_PRICING_ATTRIBUTE80    => l_price_attributes_rec.PRICING_ATTRIBUTE80,
        p_PRICING_ATTRIBUTE81    => l_price_attributes_rec.PRICING_ATTRIBUTE81,
        p_PRICING_ATTRIBUTE82    => l_price_attributes_rec.PRICING_ATTRIBUTE82,
        p_PRICING_ATTRIBUTE83    => l_price_attributes_rec.PRICING_ATTRIBUTE83,
        p_PRICING_ATTRIBUTE84    => l_price_attributes_rec.PRICING_ATTRIBUTE84,
        p_PRICING_ATTRIBUTE85    => l_price_attributes_rec.PRICING_ATTRIBUTE85,
        p_PRICING_ATTRIBUTE86    => l_price_attributes_rec.PRICING_ATTRIBUTE86,
        p_PRICING_ATTRIBUTE87    => l_price_attributes_rec.PRICING_ATTRIBUTE87,
        p_PRICING_ATTRIBUTE88    => l_price_attributes_rec.PRICING_ATTRIBUTE88,
        p_PRICING_ATTRIBUTE89    => l_price_attributes_rec.PRICING_ATTRIBUTE89,
        p_PRICING_ATTRIBUTE90    => l_price_attributes_rec.PRICING_ATTRIBUTE90,
        p_PRICING_ATTRIBUTE91    => l_price_attributes_rec.PRICING_ATTRIBUTE91,
        p_PRICING_ATTRIBUTE92    => l_price_attributes_rec.PRICING_ATTRIBUTE92,
        p_PRICING_ATTRIBUTE93    => l_price_attributes_rec.PRICING_ATTRIBUTE93,
        p_PRICING_ATTRIBUTE94    => l_price_attributes_rec.PRICING_ATTRIBUTE94,
        p_PRICING_ATTRIBUTE95    => l_price_attributes_rec.PRICING_ATTRIBUTE95,
        p_PRICING_ATTRIBUTE96    => l_price_attributes_rec.PRICING_ATTRIBUTE96,
        p_PRICING_ATTRIBUTE97    => l_price_attributes_rec.PRICING_ATTRIBUTE97,
        p_PRICING_ATTRIBUTE98    => l_price_attributes_rec.PRICING_ATTRIBUTE98,
        p_PRICING_ATTRIBUTE99    => l_price_attributes_rec.PRICING_ATTRIBUTE99,
        p_PRICING_ATTRIBUTE100  => l_price_attributes_rec.PRICING_ATTRIBUTE100,
          p_CONTEXT    => l_price_attributes_rec.CONTEXT,
          p_ATTRIBUTE1    => l_price_attributes_rec.ATTRIBUTE1,
          p_ATTRIBUTE2    => l_price_attributes_rec.ATTRIBUTE2,
          p_ATTRIBUTE3    => l_price_attributes_rec.ATTRIBUTE3,
          p_ATTRIBUTE4    => l_price_attributes_rec.ATTRIBUTE4,
          p_ATTRIBUTE5    => l_price_attributes_rec.ATTRIBUTE5,
          p_ATTRIBUTE6    => l_price_attributes_rec.ATTRIBUTE6,
          p_ATTRIBUTE7    => l_price_attributes_rec.ATTRIBUTE7,
          p_ATTRIBUTE8    => l_price_attributes_rec.ATTRIBUTE8,
          p_ATTRIBUTE9    => l_price_attributes_rec.ATTRIBUTE9,
          p_ATTRIBUTE10    => l_price_attributes_rec.ATTRIBUTE10,
          p_ATTRIBUTE11    => l_price_attributes_rec.ATTRIBUTE11,
          p_ATTRIBUTE12    => l_price_attributes_rec.ATTRIBUTE12,
          p_ATTRIBUTE13    => l_price_attributes_rec.ATTRIBUTE13,
          p_ATTRIBUTE14    => l_price_attributes_rec.ATTRIBUTE14,
          p_ATTRIBUTE15    => l_price_attributes_rec.ATTRIBUTE15,
	     p_ATTRIBUTE16    => l_price_attributes_rec.ATTRIBUTE16,
          p_ATTRIBUTE17    => l_price_attributes_rec.ATTRIBUTE17,
          p_ATTRIBUTE18    => l_price_attributes_rec.ATTRIBUTE18,
          p_ATTRIBUTE19    => l_price_attributes_rec.ATTRIBUTE19,
          p_ATTRIBUTE20    => l_price_attributes_rec.ATTRIBUTE20,
		p_OBJECT_VERSION_NUMBER  => l_price_attributes_rec.OBJECT_VERSION_NUMBER
);


   ELSIF l_price_attributes_rec.operation_code = 'UPDATE' THEN

ASO_PRICE_ATTRIBUTES_PKG.Update_Row(
          p_PRICE_ATTRIBUTE_ID  => l_price_attributes_rec.price_attribute_id,
          p_CREATION_DATE  	=> l_price_attributes_rec.creation_date,
          p_CREATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_DATE  	=> SYSDATE,
          p_LAST_UPDATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_LOGIN  	=> G_LOGIN_ID,
          p_REQUEST_ID  	=> l_Qte_Line_Rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_Qte_Line_Rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  	 => l_Qte_Line_Rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_Qte_Line_Rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID      => l_Qte_Line_Rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID        => l_price_attributes_rec.quote_line_id,
          p_FLEX_TITLE           => l_price_attributes_rec.flex_title,
          p_PRICING_CONTEXT      => l_price_attributes_rec.pricing_context,
          p_PRICING_ATTRIBUTE1    => l_price_attributes_rec.PRICING_ATTRIBUTE1,
          p_PRICING_ATTRIBUTE2    => l_price_attributes_rec.PRICING_ATTRIBUTE2,
          p_PRICING_ATTRIBUTE3    => l_price_attributes_rec.PRICING_ATTRIBUTE3,
          p_PRICING_ATTRIBUTE4    => l_price_attributes_rec.PRICING_ATTRIBUTE4,
          p_PRICING_ATTRIBUTE5    => l_price_attributes_rec.PRICING_ATTRIBUTE5,
          p_PRICING_ATTRIBUTE6    => l_price_attributes_rec.PRICING_ATTRIBUTE6,
          p_PRICING_ATTRIBUTE7    => l_price_attributes_rec.PRICING_ATTRIBUTE7,
          p_PRICING_ATTRIBUTE8    => l_price_attributes_rec.PRICING_ATTRIBUTE8,
          p_PRICING_ATTRIBUTE9    => l_price_attributes_rec.PRICING_ATTRIBUTE9,
        p_PRICING_ATTRIBUTE10    => l_price_attributes_rec.PRICING_ATTRIBUTE10,
        p_PRICING_ATTRIBUTE11    => l_price_attributes_rec.PRICING_ATTRIBUTE11,
        p_PRICING_ATTRIBUTE12    => l_price_attributes_rec.PRICING_ATTRIBUTE12,
        p_PRICING_ATTRIBUTE13    => l_price_attributes_rec.PRICING_ATTRIBUTE13,
        p_PRICING_ATTRIBUTE14    => l_price_attributes_rec.PRICING_ATTRIBUTE14,
        p_PRICING_ATTRIBUTE15    => l_price_attributes_rec.PRICING_ATTRIBUTE15,
        p_PRICING_ATTRIBUTE16    => l_price_attributes_rec.PRICING_ATTRIBUTE16,
        p_PRICING_ATTRIBUTE17    => l_price_attributes_rec.PRICING_ATTRIBUTE17,
        p_PRICING_ATTRIBUTE18    => l_price_attributes_rec.PRICING_ATTRIBUTE18,
        p_PRICING_ATTRIBUTE19    => l_price_attributes_rec.PRICING_ATTRIBUTE19,
        p_PRICING_ATTRIBUTE20    => l_price_attributes_rec.PRICING_ATTRIBUTE20,
        p_PRICING_ATTRIBUTE21    => l_price_attributes_rec.PRICING_ATTRIBUTE21,
        p_PRICING_ATTRIBUTE22    => l_price_attributes_rec.PRICING_ATTRIBUTE22,
        p_PRICING_ATTRIBUTE23    => l_price_attributes_rec.PRICING_ATTRIBUTE23,
        p_PRICING_ATTRIBUTE24    => l_price_attributes_rec.PRICING_ATTRIBUTE24,
        p_PRICING_ATTRIBUTE25    => l_price_attributes_rec.PRICING_ATTRIBUTE25,
        p_PRICING_ATTRIBUTE26    => l_price_attributes_rec.PRICING_ATTRIBUTE26,
        p_PRICING_ATTRIBUTE27    => l_price_attributes_rec.PRICING_ATTRIBUTE27,
        p_PRICING_ATTRIBUTE28    => l_price_attributes_rec.PRICING_ATTRIBUTE28,
        p_PRICING_ATTRIBUTE29    => l_price_attributes_rec.PRICING_ATTRIBUTE29,
        p_PRICING_ATTRIBUTE30    => l_price_attributes_rec.PRICING_ATTRIBUTE30,
        p_PRICING_ATTRIBUTE31    => l_price_attributes_rec.PRICING_ATTRIBUTE31,
        p_PRICING_ATTRIBUTE32    => l_price_attributes_rec.PRICING_ATTRIBUTE32,
        p_PRICING_ATTRIBUTE33    => l_price_attributes_rec.PRICING_ATTRIBUTE33,
        p_PRICING_ATTRIBUTE34    => l_price_attributes_rec.PRICING_ATTRIBUTE34,
        p_PRICING_ATTRIBUTE35    => l_price_attributes_rec.PRICING_ATTRIBUTE35,
        p_PRICING_ATTRIBUTE36    => l_price_attributes_rec.PRICING_ATTRIBUTE36,
        p_PRICING_ATTRIBUTE37    => l_price_attributes_rec.PRICING_ATTRIBUTE37,
        p_PRICING_ATTRIBUTE38    => l_price_attributes_rec.PRICING_ATTRIBUTE38,
        p_PRICING_ATTRIBUTE39    => l_price_attributes_rec.PRICING_ATTRIBUTE39,
        p_PRICING_ATTRIBUTE40    => l_price_attributes_rec.PRICING_ATTRIBUTE40,
        p_PRICING_ATTRIBUTE41    => l_price_attributes_rec.PRICING_ATTRIBUTE41,
        p_PRICING_ATTRIBUTE42    => l_price_attributes_rec.PRICING_ATTRIBUTE42,
        p_PRICING_ATTRIBUTE43    => l_price_attributes_rec.PRICING_ATTRIBUTE43,
        p_PRICING_ATTRIBUTE44    => l_price_attributes_rec.PRICING_ATTRIBUTE44,
        p_PRICING_ATTRIBUTE45    => l_price_attributes_rec.PRICING_ATTRIBUTE45,
        p_PRICING_ATTRIBUTE46    => l_price_attributes_rec.PRICING_ATTRIBUTE46,
        p_PRICING_ATTRIBUTE47    => l_price_attributes_rec.PRICING_ATTRIBUTE47,
        p_PRICING_ATTRIBUTE48    => l_price_attributes_rec.PRICING_ATTRIBUTE48,
        p_PRICING_ATTRIBUTE49    => l_price_attributes_rec.PRICING_ATTRIBUTE49,
        p_PRICING_ATTRIBUTE50    => l_price_attributes_rec.PRICING_ATTRIBUTE50,
        p_PRICING_ATTRIBUTE51    => l_price_attributes_rec.PRICING_ATTRIBUTE51,
        p_PRICING_ATTRIBUTE52    => l_price_attributes_rec.PRICING_ATTRIBUTE52,
        p_PRICING_ATTRIBUTE53    => l_price_attributes_rec.PRICING_ATTRIBUTE53,
        p_PRICING_ATTRIBUTE54    => l_price_attributes_rec.PRICING_ATTRIBUTE54,
        p_PRICING_ATTRIBUTE55    => l_price_attributes_rec.PRICING_ATTRIBUTE55,
        p_PRICING_ATTRIBUTE56    => l_price_attributes_rec.PRICING_ATTRIBUTE56,
        p_PRICING_ATTRIBUTE57    => l_price_attributes_rec.PRICING_ATTRIBUTE57,
        p_PRICING_ATTRIBUTE58    => l_price_attributes_rec.PRICING_ATTRIBUTE58,
        p_PRICING_ATTRIBUTE59    => l_price_attributes_rec.PRICING_ATTRIBUTE59,
        p_PRICING_ATTRIBUTE60    => l_price_attributes_rec.PRICING_ATTRIBUTE60,
        p_PRICING_ATTRIBUTE61    => l_price_attributes_rec.PRICING_ATTRIBUTE61,
        p_PRICING_ATTRIBUTE62    => l_price_attributes_rec.PRICING_ATTRIBUTE62,
        p_PRICING_ATTRIBUTE63    => l_price_attributes_rec.PRICING_ATTRIBUTE63,
        p_PRICING_ATTRIBUTE64    => l_price_attributes_rec.PRICING_ATTRIBUTE64,
        p_PRICING_ATTRIBUTE65    => l_price_attributes_rec.PRICING_ATTRIBUTE65,
        p_PRICING_ATTRIBUTE66    => l_price_attributes_rec.PRICING_ATTRIBUTE66,
        p_PRICING_ATTRIBUTE67    => l_price_attributes_rec.PRICING_ATTRIBUTE67,
        p_PRICING_ATTRIBUTE68    => l_price_attributes_rec.PRICING_ATTRIBUTE68,
        p_PRICING_ATTRIBUTE69    => l_price_attributes_rec.PRICING_ATTRIBUTE69,
        p_PRICING_ATTRIBUTE70    => l_price_attributes_rec.PRICING_ATTRIBUTE70,
        p_PRICING_ATTRIBUTE71    => l_price_attributes_rec.PRICING_ATTRIBUTE71,
        p_PRICING_ATTRIBUTE72    => l_price_attributes_rec.PRICING_ATTRIBUTE72,
        p_PRICING_ATTRIBUTE73    => l_price_attributes_rec.PRICING_ATTRIBUTE73,
        p_PRICING_ATTRIBUTE74    => l_price_attributes_rec.PRICING_ATTRIBUTE74,
        p_PRICING_ATTRIBUTE75    => l_price_attributes_rec.PRICING_ATTRIBUTE75,
        p_PRICING_ATTRIBUTE76    => l_price_attributes_rec.PRICING_ATTRIBUTE76,
        p_PRICING_ATTRIBUTE77    => l_price_attributes_rec.PRICING_ATTRIBUTE77,
        p_PRICING_ATTRIBUTE78    => l_price_attributes_rec.PRICING_ATTRIBUTE78,
        p_PRICING_ATTRIBUTE79    => l_price_attributes_rec.PRICING_ATTRIBUTE79,
        p_PRICING_ATTRIBUTE80    => l_price_attributes_rec.PRICING_ATTRIBUTE80,
        p_PRICING_ATTRIBUTE81    => l_price_attributes_rec.PRICING_ATTRIBUTE81,
        p_PRICING_ATTRIBUTE82    => l_price_attributes_rec.PRICING_ATTRIBUTE82,
        p_PRICING_ATTRIBUTE83    => l_price_attributes_rec.PRICING_ATTRIBUTE83,
        p_PRICING_ATTRIBUTE84    => l_price_attributes_rec.PRICING_ATTRIBUTE84,
        p_PRICING_ATTRIBUTE85    => l_price_attributes_rec.PRICING_ATTRIBUTE85,
        p_PRICING_ATTRIBUTE86    => l_price_attributes_rec.PRICING_ATTRIBUTE86,
        p_PRICING_ATTRIBUTE87    => l_price_attributes_rec.PRICING_ATTRIBUTE87,
        p_PRICING_ATTRIBUTE88    => l_price_attributes_rec.PRICING_ATTRIBUTE88,
        p_PRICING_ATTRIBUTE89    => l_price_attributes_rec.PRICING_ATTRIBUTE89,
        p_PRICING_ATTRIBUTE90    => l_price_attributes_rec.PRICING_ATTRIBUTE90,
        p_PRICING_ATTRIBUTE91    => l_price_attributes_rec.PRICING_ATTRIBUTE91,
        p_PRICING_ATTRIBUTE92    => l_price_attributes_rec.PRICING_ATTRIBUTE92,
        p_PRICING_ATTRIBUTE93    => l_price_attributes_rec.PRICING_ATTRIBUTE93,
        p_PRICING_ATTRIBUTE94    => l_price_attributes_rec.PRICING_ATTRIBUTE94,
        p_PRICING_ATTRIBUTE95    => l_price_attributes_rec.PRICING_ATTRIBUTE95,
        p_PRICING_ATTRIBUTE96    => l_price_attributes_rec.PRICING_ATTRIBUTE96,
        p_PRICING_ATTRIBUTE97    => l_price_attributes_rec.PRICING_ATTRIBUTE97,
        p_PRICING_ATTRIBUTE98    => l_price_attributes_rec.PRICING_ATTRIBUTE98,
        p_PRICING_ATTRIBUTE99    => l_price_attributes_rec.PRICING_ATTRIBUTE99,
        p_PRICING_ATTRIBUTE100  => l_price_attributes_rec.PRICING_ATTRIBUTE100,
          p_CONTEXT    => l_price_attributes_rec.CONTEXT,
          p_ATTRIBUTE1    => l_price_attributes_rec.ATTRIBUTE1,
          p_ATTRIBUTE2    => l_price_attributes_rec.ATTRIBUTE2,
          p_ATTRIBUTE3    => l_price_attributes_rec.ATTRIBUTE3,
          p_ATTRIBUTE4    => l_price_attributes_rec.ATTRIBUTE4,
          p_ATTRIBUTE5    => l_price_attributes_rec.ATTRIBUTE5,
          p_ATTRIBUTE6    => l_price_attributes_rec.ATTRIBUTE6,
          p_ATTRIBUTE7    => l_price_attributes_rec.ATTRIBUTE7,
          p_ATTRIBUTE8    => l_price_attributes_rec.ATTRIBUTE8,
          p_ATTRIBUTE9    => l_price_attributes_rec.ATTRIBUTE9,
          p_ATTRIBUTE10    => l_price_attributes_rec.ATTRIBUTE10,
          p_ATTRIBUTE11    => l_price_attributes_rec.ATTRIBUTE11,
          p_ATTRIBUTE12    => l_price_attributes_rec.ATTRIBUTE12,
          p_ATTRIBUTE13    => l_price_attributes_rec.ATTRIBUTE13,
          p_ATTRIBUTE14    => l_price_attributes_rec.ATTRIBUTE14,
          p_ATTRIBUTE15    => l_price_attributes_rec.ATTRIBUTE15,
	     p_ATTRIBUTE16    => l_price_attributes_rec.ATTRIBUTE16,
          p_ATTRIBUTE17    => l_price_attributes_rec.ATTRIBUTE17,
          p_ATTRIBUTE18    => l_price_attributes_rec.ATTRIBUTE18,
          p_ATTRIBUTE19    => l_price_attributes_rec.ATTRIBUTE19,
          p_ATTRIBUTE20    => l_price_attributes_rec.ATTRIBUTE20,
		p_OBJECT_VERSION_NUMBER  => l_price_attributes_rec.OBJECT_VERSION_NUMBER
);

  END IF;

END LOOP;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Update_Quote_line - after line_price_attribs.update ', 1, 'N');
	end if;


-- aso_shipments_tbl


    FOR i IN 1..l_Shipment_Tbl.count LOOP

	   l_shipment_rec    := l_shipment_tbl(i);
        x_shipment_tbl(i) := l_shipment_rec;

        IF l_shipment_rec.operation_code = 'CREATE' THEN

            l_shipment_rec.quote_header_id            := l_qte_line_rec.quote_header_id;
            l_shipment_rec.quote_line_id              := l_qte_line_rec.quote_line_id;
            -- BC4J Fix
              x_shipment_tbl(i).shipment_id            := l_shipment_rec.shipment_id;
		  --x_shipment_tbl(i).shipment_id             := null;
            l_shipment_rec.ship_method_code_from      := l_shipment_rec.ship_method_code;
            l_shipment_rec.freight_terms_code_from    := l_shipment_rec.freight_terms_code;
            x_shipment_tbl(i).ship_method_code_from   := l_shipment_rec.ship_method_code_from;
            x_shipment_tbl(i).freight_terms_code_from := l_shipment_rec.freight_terms_code_from;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Before ASO_SHIPMENTS_PKG.insert_rows Quote Line- l_shipment_tbl(1).ship_method_code'||l_shipment_tbl(1).ship_method_code, 1, 'Y');
           aso_debug_pub.add('Before ASO_SHIPMENTS_PKG.insert_rows Quote Line- l_shipment_tbl(1).freight_terms_code'||l_shipment_tbl(1).freight_terms_code, 1, 'Y');
         END IF;

        ASO_SHIPMENTS_PKG.Insert_Row(
            px_SHIPMENT_ID  	=> x_shipment_tbl(i).SHIPMENT_ID,
            p_CREATION_DATE  	=> SYSDATE,
            p_CREATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_LOGIN => G_LOGIN_ID,
            p_REQUEST_ID  	=> l_shipment_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID  => l_shipment_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID  	=> l_shipment_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE  => l_shipment_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_HEADER_ID   => l_shipment_rec.QUOTE_HEADER_ID,
            p_QUOTE_LINE_ID  	=> l_shipment_rec.QUOTE_LINE_ID,
            p_PROMISE_DATE  	=> l_shipment_rec.PROMISE_DATE,
            p_REQUEST_DATE   	=> l_shipment_rec.REQUEST_DATE,
            p_SCHEDULE_SHIP_DATE     => l_shipment_rec.SCHEDULE_SHIP_DATE,
            p_SHIP_TO_PARTY_SITE_ID  => l_shipment_rec.SHIP_TO_PARTY_SITE_ID,
            p_SHIP_TO_PARTY_ID  => l_shipment_rec.SHIP_TO_PARTY_ID,
            p_SHIP_TO_CUST_ACCOUNT_ID     => l_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID  ,
            p_SHIP_PARTIAL_FLAG => l_shipment_rec.SHIP_PARTIAL_FLAG,
            p_SHIP_SET_ID  	=> l_shipment_rec.SHIP_SET_ID,
            p_SHIP_METHOD_CODE  => l_shipment_rec.SHIP_METHOD_CODE,
            p_FREIGHT_TERMS_CODE=> l_shipment_rec.FREIGHT_TERMS_CODE,
            p_FREIGHT_CARRIER_CODE  => l_shipment_rec.FREIGHT_CARRIER_CODE,
            p_FOB_CODE  	=> l_shipment_rec.FOB_CODE,
            p_SHIPPING_INSTRUCTIONS  => l_shipment_rec.SHIPPING_INSTRUCTIONS,
            p_PACKING_INSTRUCTIONS   => l_shipment_rec.PACKING_INSTRUCTIONS,
            p_SHIPMENT_PRIORITY_CODE  => l_shipment_rec.SHIPMENT_PRIORITY_CODE,
            p_SHIP_QUOTE_PRICE        => l_shipment_rec.SHIP_QUOTE_PRICE,
            p_QUANTITY  	=> l_shipment_rec.QUANTITY,
            p_RESERVED_QUANTITY => l_shipment_rec.RESERVED_QUANTITY,
            p_RESERVATION_ID    => l_shipment_rec.RESERVATION_ID,
            p_ORDER_LINE_ID     => l_shipment_rec.ORDER_LINE_ID,
            p_ATTRIBUTE_CATEGORY  => l_shipment_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  => l_shipment_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  => l_shipment_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  => l_shipment_rec.ATTRIBUTE3,
            p_ATTRIBUTE4  => l_shipment_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  => l_shipment_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  => l_shipment_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  => l_shipment_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  => l_shipment_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  => l_shipment_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  => l_shipment_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  => l_shipment_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  => l_shipment_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  => l_shipment_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  => l_shipment_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  => l_shipment_rec.ATTRIBUTE15,
		  p_ATTRIBUTE16  => l_shipment_rec.ATTRIBUTE16,
            p_ATTRIBUTE17  => l_shipment_rec.ATTRIBUTE17,
            p_ATTRIBUTE18  => l_shipment_rec.ATTRIBUTE18,
            p_ATTRIBUTE19  => l_shipment_rec.ATTRIBUTE19,
            p_ATTRIBUTE20  => l_shipment_rec.ATTRIBUTE20,
		  p_SHIP_FROM_ORG_ID => l_shipment_rec.SHIP_FROM_ORG_ID,
		  p_SHIP_TO_CUST_PARTY_ID => l_shipment_rec.SHIP_TO_CUST_PARTY_ID,
            p_SHIP_METHOD_CODE_FROM   => l_shipment_rec.SHIP_METHOD_CODE_FROM,
            p_FREIGHT_TERMS_CODE_FROM  => l_shipment_rec.FREIGHT_TERMS_CODE_FROM,
		  p_OBJECT_VERSION_NUMBER  => l_shipment_rec.OBJECT_VERSION_NUMBER,
	       p_REQUEST_DATE_TYPE => l_shipment_rec.REQUEST_DATE_TYPE,
            p_DEMAND_CLASS_CODE => l_shipment_rec.DEMAND_CLASS_CODE
		);

         FOR j IN 1..l_Freight_Charge_Tbl.count LOOP
             IF l_freight_charge_tbl(j).shipment_index = i THEN
                l_freight_charge_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;

          END LOOP;

          FOR j in 1..l_Tax_Detail_Tbl.count LOOP
              IF l_tax_detail_tbl(j).shipment_index = i THEN
                 l_tax_detail_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;

           FOR j in 1..l_line_attribs_ext_Tbl.count LOOP
              IF l_line_attribs_ext_tbl(j).shipment_index = i THEN
                 l_line_attribs_ext_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;

         END LOOP;

           FOR j in 1..l_Payment_Tbl.count LOOP
              IF l_payment_tbl(j).shipment_index = i THEN
                 l_payment_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;

         END LOOP;

           FOR j in 1..P_Price_Adj_Tbl.count LOOP
              IF l_Price_Adj_tbl(j).shipment_index = i THEN
                 l_Price_Adj_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;

         END LOOP;

          FOR j in 1..P_Quote_Party_Tbl.count LOOP
              IF l_quote_party_tbl(j).shipment_index = i THEN
                 l_quote_party_tbl(j).quote_shipment_id := x_shipment_tbl(i).shipment_id;
             END IF;
            END LOOP;

         END LOOP;

       ELSIF l_shipment_rec.operation_code = 'UPDATE' THEN

             IF l_shipment_rec.ship_method_code = fnd_api.g_miss_char THEN

                FOR l_ship_db_rec IN c_db_ship_freight_terms(l_shipment_rec.shipment_id) LOOP

                  IF l_ship_db_rec.ship_method_code_from is null THEN
                       l_shipment_rec.ship_method_code_from := l_ship_db_rec.ship_method_code;
                  END IF;

                END LOOP;

             ELSE
                    l_shipment_rec.ship_method_code_from := l_shipment_rec.ship_method_code;

             END IF;

             IF l_shipment_rec.freight_terms_code = fnd_api.g_miss_char THEN

                FOR l_ship_db_rec IN c_db_ship_freight_terms(l_shipment_rec.shipment_id) LOOP

                    IF l_ship_db_rec.freight_terms_code_from is null THEN
                        l_shipment_rec.freight_terms_code_from := l_ship_db_rec.freight_terms_code;
                    END IF;

                END LOOP;

             ELSE
                       l_shipment_rec.freight_terms_code_from := l_shipment_rec.freight_terms_code;

             END IF;


        ASO_SHIPMENTS_PKG.Update_Row(
            p_SHIPMENT_ID  	=> l_shipment_tbl(i).SHIPMENT_ID,
            p_CREATION_DATE  	=> l_shipment_tbl(i).creation_date,
            p_CREATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_LOGIN => G_LOGIN_ID,
            p_REQUEST_ID  	=> l_shipment_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID  => l_shipment_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID  	=> l_shipment_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE  => l_shipment_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_HEADER_ID  	=> l_shipment_rec.QUOTE_HEADER_ID,
            p_QUOTE_LINE_ID  	=> l_shipment_rec.QUOTE_LINE_ID,
            p_PROMISE_DATE  	=> l_shipment_rec.PROMISE_DATE,
            p_REQUEST_DATE  	=> l_shipment_rec.REQUEST_DATE,
            p_SCHEDULE_SHIP_DATE=> l_shipment_rec.SCHEDULE_SHIP_DATE,
            p_SHIP_TO_PARTY_SITE_ID  => l_shipment_rec.SHIP_TO_PARTY_SITE_ID,
            p_SHIP_TO_PARTY_ID  => l_shipment_rec.SHIP_TO_PARTY_ID,
            p_SHIP_TO_CUST_ACCOUNT_ID     => l_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID  ,
            p_SHIP_PARTIAL_FLAG => l_shipment_rec.SHIP_PARTIAL_FLAG,
            p_SHIP_SET_ID  	=> l_shipment_rec.SHIP_SET_ID,
            p_SHIP_METHOD_CODE  => l_shipment_rec.SHIP_METHOD_CODE,
            p_FREIGHT_TERMS_CODE=> l_shipment_rec.FREIGHT_TERMS_CODE,
            p_FREIGHT_CARRIER_CODE  => l_shipment_rec.FREIGHT_CARRIER_CODE,
            p_FOB_CODE  	=> l_shipment_rec.FOB_CODE,
            p_SHIPPING_INSTRUCTIONS  => l_shipment_rec.SHIPPING_INSTRUCTIONS,
            p_PACKING_INSTRUCTIONS   => l_shipment_rec.PACKING_INSTRUCTIONS,
            p_SHIPMENT_PRIORITY_CODE  => l_shipment_rec.SHIPMENT_PRIORITY_CODE,
            p_SHIP_QUOTE_PRICE        => l_shipment_rec.SHIP_QUOTE_PRICE,
            p_QUANTITY  	=> l_shipment_rec.QUANTITY,
            p_RESERVED_QUANTITY => l_shipment_rec.RESERVED_QUANTITY,
            p_RESERVATION_ID    => l_shipment_rec.RESERVATION_ID,
            p_ORDER_LINE_ID     => l_shipment_rec.ORDER_LINE_ID,
            p_ATTRIBUTE_CATEGORY  => l_shipment_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  => l_shipment_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  => l_shipment_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  => l_shipment_rec.ATTRIBUTE3,
            p_ATTRIBUTE4  => l_shipment_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  => l_shipment_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  => l_shipment_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  => l_shipment_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  => l_shipment_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  => l_shipment_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  => l_shipment_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  => l_shipment_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  => l_shipment_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  => l_shipment_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  => l_shipment_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  => l_shipment_rec.ATTRIBUTE15,
	       p_ATTRIBUTE16  => l_shipment_rec.ATTRIBUTE16,
		  p_ATTRIBUTE17  => l_shipment_rec.ATTRIBUTE17,
		  p_ATTRIBUTE18  => l_shipment_rec.ATTRIBUTE18,
		  p_ATTRIBUTE19  => l_shipment_rec.ATTRIBUTE19,
		  p_ATTRIBUTE20  => l_shipment_rec.ATTRIBUTE20,
		p_SHIP_FROM_ORG_ID =>l_shipment_rec.SHIP_FROM_ORG_ID,
		p_SHIP_TO_CUST_PARTY_ID => l_shipment_rec.SHIP_TO_CUST_PARTY_ID,
            p_SHIP_METHOD_CODE_FROM   => l_shipment_rec.SHIP_METHOD_CODE_FROM,
            p_FREIGHT_TERMS_CODE_FROM  => l_shipment_rec.FREIGHT_TERMS_CODE_FROM,
		  p_OBJECT_VERSION_NUMBER  => l_shipment_rec.OBJECT_VERSION_NUMBER,
	       p_REQUEST_DATE_TYPE => l_shipment_rec.REQUEST_DATE_TYPE,
            p_DEMAND_CLASS_CODE => l_shipment_rec.DEMAND_CLASS_CODE
		);

        ELSIF l_shipment_rec.operation_code = 'DELETE' THEN

        OPEN C_ship_partial(l_qte_line_rec.QUOTE_LINE_ID);
        FETCH C_ship_partial into l_ship_count;
        CLOSE C_ship_partial;

      IF l_ship_count = 1 THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'DELETE_SHIPMENT');
            FND_MESSAGE.Set_Token('COLUMN', 'SHIPMENT_ID', FALSE);
            FND_MSG_PUB.ADD;
       	END IF;
      END IF;


        ASO_SHIPMENTS_PKG.Delete_Row(
            p_SHIPMENT_ID  => l_shipment_tbl(i).SHIPMENT_ID);

        END IF;

    END LOOP;      -- for shipments

-- insert rows into aso_freight_charges

    FOR i IN 1..l_Freight_Charge_Tbl.count LOOP
	l_freight_charge_rec := l_freight_charge_tbl(i);
    --  l_freight_charge_rec.quote_line_id :=  x_qte_line_rec.QUOTE_LINE_ID;
        x_freight_charge_tbl(i) := l_freight_charge_rec;

      IF l_freight_charge_rec.operation_code = 'CREATE' THEN

        l_freight_charge_rec.quote_line_id := l_qte_line_rec.quote_line_id;
        -- BC4J Fix
	   --x_FREIGHT_CHARGE_tbl(i).freight_charge_id := null;

        ASO_FREIGHT_CHARGES_PKG.Insert_Row(
            px_FREIGHT_CHARGE_ID  => x_FREIGHT_CHARGE_tbl(i).freight_charge_id,
            p_CREATION_DATE  	=> SYSDATE,
            p_CREATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_LOGIN => G_LOGIN_ID,
            p_REQUEST_ID  	=> l_freight_charge_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID
			=> l_freight_charge_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID  	=> l_freight_charge_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE  => l_freight_charge_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_SHIPMENT_ID  => l_freight_charge_rec.QUOTE_SHIPMENT_ID,
            p_FREIGHT_CHARGE_TYPE_ID
				=> l_freight_charge_rec.FREIGHT_CHARGE_TYPE_ID,
            p_CHARGE_AMOUNT     => l_freight_charge_rec.CHARGE_AMOUNT,
            p_ATTRIBUTE_CATEGORY  => l_freight_charge_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  => l_freight_charge_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  => l_freight_charge_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  => l_freight_charge_rec.ATTRIBUTE3,
            p_ATTRIBUTE4  => l_freight_charge_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  => l_freight_charge_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  => l_freight_charge_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  => l_freight_charge_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  => l_freight_charge_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  => l_freight_charge_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  => l_freight_charge_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  => l_freight_charge_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  => l_freight_charge_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  => l_freight_charge_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  => l_freight_charge_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  => l_freight_charge_rec.ATTRIBUTE15
		  );


      ELSIF l_freight_charge_rec.operation_code = 'UPDATE' THEN
        ASO_FREIGHT_CHARGES_PKG.Update_Row(
            p_FREIGHT_CHARGE_ID => p_FREIGHT_CHARGE_tbl(i).freight_charge_id,
            p_CREATION_DATE  	=> l_freight_charge_rec.creation_date,
            p_CREATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_LOGIN => G_LOGIN_ID,
            p_REQUEST_ID  	=> l_freight_charge_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID
			=> l_freight_charge_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID  	=> l_freight_charge_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE  => l_freight_charge_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_SHIPMENT_ID    => l_freight_charge_rec.QUOTE_SHIPMENT_ID,
            p_FREIGHT_CHARGE_TYPE_ID
			=> l_freight_charge_rec.FREIGHT_CHARGE_TYPE_ID,
            p_CHARGE_AMOUNT  => l_freight_charge_rec.CHARGE_AMOUNT,
            p_ATTRIBUTE_CATEGORY  => l_freight_charge_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  => l_freight_charge_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  => l_freight_charge_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  => l_freight_charge_rec.ATTRIBUTE3,
            p_ATTRIBUTE4  => l_freight_charge_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  => l_freight_charge_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  => l_freight_charge_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  => l_freight_charge_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  => l_freight_charge_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  => l_freight_charge_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  => l_freight_charge_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  => l_freight_charge_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  => l_freight_charge_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  => l_freight_charge_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  => l_freight_charge_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  => l_freight_charge_rec.ATTRIBUTE15);

       ELSIF l_freight_charge_rec.operation_code = 'DELETE' THEN
        ASO_FREIGHT_CHARGES_PKG.delete_Row(
            p_FREIGHT_CHARGE_ID  => p_FREIGHT_CHARGE_tbl(i).freight_charge_id);

       END IF;
    END LOOP;   -- freight charges


-- tax information

    FOR i IN 1..l_tax_detail_Tbl.count LOOP
          l_tax_detail_rec := l_tax_detail_tbl(i);
      --  l_tax_detail_rec.quote_line_id :=  x_qte_line_rec.QUOTE_LINE_ID;
         x_tax_detail_tbl(i) := l_tax_detail_rec;

      IF l_tax_detail_rec.operation_code = 'CREATE' THEN
        l_tax_detail_rec.quote_header_id := l_qte_line_rec.quote_header_id;
        l_tax_detail_rec.quote_line_id := l_qte_line_rec.quote_line_id;
        -- BC4J Fix
	   --x_tax_detail_tbl(i).TAX_DETAIL_ID := null;

        ASO_TAX_DETAILS_PKG.Insert_Row(
            px_TAX_DETAIL_ID  	=> x_tax_detail_tbl(i).TAX_DETAIL_ID,
            p_CREATION_DATE  	=> SYSDATE,
            p_CREATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_LOGIN => G_LOGIN_ID,
            p_REQUEST_ID  	=> l_tax_detail_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID =>l_tax_detail_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID  	=> l_tax_detail_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE  => l_tax_detail_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_HEADER_ID  	=> l_tax_detail_rec.QUOTE_HEADER_ID,
            p_QUOTE_LINE_ID  	=> l_tax_detail_rec.QUOTE_LINE_ID,
            p_QUOTE_SHIPMENT_ID => l_tax_detail_rec.QUOTE_SHIPMENT_ID,
            p_ORIG_TAX_CODE  	=> l_tax_detail_rec.ORIG_TAX_CODE,
            p_TAX_CODE  	=> l_tax_detail_rec.TAX_CODE,
            p_TAX_RATE  	=> l_tax_detail_rec.TAX_RATE,
            p_TAX_DATE  	=> l_tax_detail_rec.TAX_DATE,
            p_TAX_AMOUNT  	=> l_tax_detail_rec.TAX_AMOUNT,
            p_TAX_EXEMPT_FLAG  	=> l_tax_detail_rec.TAX_EXEMPT_FLAG,
            p_TAX_EXEMPT_NUMBER => l_tax_detail_rec.TAX_EXEMPT_NUMBER,
            p_TAX_EXEMPT_REASON_CODE =>l_tax_detail_rec.TAX_EXEMPT_REASON_CODE,
            p_ATTRIBUTE_CATEGORY     => l_tax_detail_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  	=> l_tax_detail_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  	=> l_tax_detail_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  	=> l_tax_detail_rec.ATTRIBUTE3,
            p_ATTRIBUTE4   	=> l_tax_detail_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  	=> l_tax_detail_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  	=> l_tax_detail_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  	=> l_tax_detail_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  	=> l_tax_detail_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  	=> l_tax_detail_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  	=> l_tax_detail_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  	=> l_tax_detail_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  	=> l_tax_detail_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  	=> l_tax_detail_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  	=> l_tax_detail_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  	=> l_tax_detail_rec.ATTRIBUTE15,
            p_ATTRIBUTE16  => l_tax_detail_rec.ATTRIBUTE16,
            p_ATTRIBUTE17  => l_tax_detail_rec.ATTRIBUTE17,
            p_ATTRIBUTE18  => l_tax_detail_rec.ATTRIBUTE18,
            p_ATTRIBUTE19  => l_tax_detail_rec.ATTRIBUTE19,
            p_ATTRIBUTE20  => l_tax_detail_rec.ATTRIBUTE20,
		  p_TAX_INCLUSIVE_FLAG  	=> l_tax_detail_rec.TAX_INCLUSIVE_FLAG,
		  p_OBJECT_VERSION_NUMBER => l_tax_detail_rec.OBJECT_VERSION_NUMBER,
		  p_TAX_RATE_ID => l_tax_detail_rec.TAX_RATE_ID
		  );

       ELSIF l_tax_detail_rec.operation_code = 'UPDATE' THEN

        ASO_TAX_DETAILS_PKG.Update_Row(
            p_TAX_DETAIL_ID  	=> l_tax_detail_rec.TAX_DETAIL_ID,
            p_CREATION_DATE  	=> l_tax_detail_rec.creation_date,
            p_CREATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_LOGIN => G_LOGIN_ID,
            p_REQUEST_ID  	=> l_tax_detail_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID =>l_tax_detail_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID  	=> l_tax_detail_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE  => l_tax_detail_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_HEADER_ID  	=> l_tax_detail_rec.QUOTE_HEADER_ID,
            p_QUOTE_LINE_ID  	=> l_tax_detail_rec.QUOTE_LINE_ID,
            p_QUOTE_SHIPMENT_ID => l_tax_detail_rec.QUOTE_SHIPMENT_ID,
            p_ORIG_TAX_CODE  	=> l_tax_detail_rec.ORIG_TAX_CODE,
            p_TAX_CODE  	=> l_tax_detail_rec.TAX_CODE,
            p_TAX_RATE  	=> l_tax_detail_rec.TAX_RATE,
            p_TAX_DATE  	=> l_tax_detail_rec.TAX_DATE,
            p_TAX_AMOUNT  	=> l_tax_detail_rec.TAX_AMOUNT,
            p_TAX_EXEMPT_FLAG  	=> l_tax_detail_rec.TAX_EXEMPT_FLAG,
            p_TAX_EXEMPT_NUMBER => l_tax_detail_rec.TAX_EXEMPT_NUMBER,
            p_TAX_EXEMPT_REASON_CODE =>l_tax_detail_rec.TAX_EXEMPT_REASON_CODE,
            p_ATTRIBUTE_CATEGORY  => l_tax_detail_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  	=> l_tax_detail_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  	=> l_tax_detail_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  	=> l_tax_detail_rec.ATTRIBUTE3,
            p_ATTRIBUTE4  	=> l_tax_detail_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  	=> l_tax_detail_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  	=> l_tax_detail_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  	=> l_tax_detail_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  	=> l_tax_detail_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  	=> l_tax_detail_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  	=> l_tax_detail_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  	=> l_tax_detail_rec.ATTRIBUTE11,
            p_ATTRIBUTE12   	=> l_tax_detail_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  	=> l_tax_detail_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  	=> l_tax_detail_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  	=> l_tax_detail_rec.ATTRIBUTE15,
            p_ATTRIBUTE16  => l_tax_detail_rec.ATTRIBUTE16,
            p_ATTRIBUTE17  => l_tax_detail_rec.ATTRIBUTE17,
            p_ATTRIBUTE18  => l_tax_detail_rec.ATTRIBUTE18,
            p_ATTRIBUTE19  => l_tax_detail_rec.ATTRIBUTE19,
            p_ATTRIBUTE20  => l_tax_detail_rec.ATTRIBUTE20,
		  p_TAX_INCLUSIVE_FLAG  	=> l_tax_detail_rec.TAX_INCLUSIVE_FLAG,
		  p_OBJECT_VERSION_NUMBER => l_tax_detail_rec.OBJECT_VERSION_NUMBER,
		  p_TAX_RATE_ID => l_tax_detail_rec.TAX_RATE_ID
		  );

         ELSIF l_tax_detail_rec.operation_code = 'DELETE' THEN

        ASO_TAX_DETAILS_PKG.Delete_Row(
            p_TAX_DETAIL_ID  => l_tax_detail_tbl(i).TAX_DETAIL_ID);

         END IF;
    END LOOP;    -- tax details

   -- quote party
      FOR i IN 1..l_quote_party_Tbl.count LOOP
	l_quote_party_rec := l_quote_party_tbl(i);
        x_quote_party_tbl(i) := l_quote_party_rec;

       IF l_quote_party_rec.operation_code = 'CREATE' THEN
        l_quote_party_rec.quote_line_id :=  x_qte_line_rec.QUOTE_LINE_ID;
        l_quote_party_rec.quote_header_id := l_Qte_Line_Rec.quote_header_id;
        -- BC4J Fix
	   --x_quote_party_tbl(i).QUOTE_PARTY_ID := NULL;

           ASO_QUOTE_PARTIES_PKG.Insert_Row(
          px_QUOTE_PARTY_ID  => x_quote_party_tbl(i).QUOTE_PARTY_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_REQUEST_ID  => l_QUOTE_PARTY_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  =>l_QUOTE_PARTY_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_QUOTE_PARTY_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_QUOTE_PARTY_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID  => l_QUOTE_PARTY_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_QUOTE_PARTY_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID  => l_QUOTE_PARTY_rec.QUOTE_SHIPMENT_ID,
          p_PARTY_TYPE  => l_QUOTE_PARTY_rec.PARTY_TYPE,
          p_PARTY_ID  => l_QUOTE_PARTY_rec.PARTY_ID,
          p_PARTY_OBJECT_TYPE  => l_QUOTE_PARTY_rec.PARTY_OBJECT_TYPE,
          p_PARTY_OBJECT_ID  => l_QUOTE_PARTY_rec.PARTY_OBJECT_ID,
          p_ATTRIBUTE_CATEGORY  => l_QUOTE_PARTY_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_QUOTE_PARTY_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_QUOTE_PARTY_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_QUOTE_PARTY_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_QUOTE_PARTY_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_QUOTE_PARTY_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_QUOTE_PARTY_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_QUOTE_PARTY_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_QUOTE_PARTY_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_QUOTE_PARTY_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_QUOTE_PARTY_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_QUOTE_PARTY_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_QUOTE_PARTY_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_QUOTE_PARTY_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_QUOTE_PARTY_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_QUOTE_PARTY_rec.ATTRIBUTE15,
  --          p_SECURITY_GROUP_ID  => p_QUOTE_PARTY_rec.SECURITY_GROUP_ID);
        p_OBJECT_VERSION_NUMBER  => l_QUOTE_PARTY_rec.OBJECT_VERSION_NUMBER);

        ELSIF  l_quote_party_rec.operation_code = 'UPDATE' THEN
            ASO_QUOTE_PARTIES_PKG.Update_Row(
          p_QUOTE_PARTY_ID  => l_quote_party_rec.QUOTE_PARTY_ID,
          p_CREATION_DATE  => l_quote_party_rec.creation_date,
          p_CREATED_BY  => G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => G_LOGIN_ID,
          p_LAST_UPDATED_BY  => G_USER_ID,
          p_REQUEST_ID  => l_QUOTE_PARTY_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  =>l_QUOTE_PARTY_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_QUOTE_PARTY_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_QUOTE_PARTY_rec.PROGRAM_UPDATE_DATE,
          p_QUOTE_HEADER_ID  => l_QUOTE_PARTY_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID  => l_QUOTE_PARTY_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID  => l_QUOTE_PARTY_rec.QUOTE_SHIPMENT_ID,
          p_PARTY_TYPE  => l_QUOTE_PARTY_rec.PARTY_TYPE,
          p_PARTY_ID  => l_QUOTE_PARTY_rec.PARTY_ID,
          p_PARTY_OBJECT_TYPE  => l_QUOTE_PARTY_rec.PARTY_OBJECT_TYPE,
          p_PARTY_OBJECT_ID  => l_QUOTE_PARTY_rec.PARTY_OBJECT_ID,
          p_ATTRIBUTE_CATEGORY  => l_QUOTE_PARTY_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_QUOTE_PARTY_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_QUOTE_PARTY_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_QUOTE_PARTY_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_QUOTE_PARTY_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_QUOTE_PARTY_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_QUOTE_PARTY_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_QUOTE_PARTY_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_QUOTE_PARTY_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_QUOTE_PARTY_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_QUOTE_PARTY_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_QUOTE_PARTY_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_QUOTE_PARTY_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_QUOTE_PARTY_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_QUOTE_PARTY_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_QUOTE_PARTY_rec.ATTRIBUTE15,
		p_OBJECT_VERSION_NUMBER  => l_QUOTE_PARTY_rec.OBJECT_VERSION_NUMBER);

        ELSIF  l_quote_party_rec.operation_code = 'DELETE' THEN
            ASO_QUOTE_PARTIES_PKG.Delete_Row(
          p_QUOTE_PARTY_ID  => l_QUOTE_PARTY_rec.QUOTE_PARTY_ID);

        END IF;
 END LOOP;




    -- price adjustment attributes


    FOR i IN 1..l_Price_Adj_Tbl.count LOOP
	l_price_adj_rec := l_price_adj_tbl(i);
--        l_price_adj_rec.quote_line_id := x_qte_line_rec.quote_line_id;
        x_price_adj_tbl(i) := l_price_adj_rec;

     IF l_price_adj_rec.operation_code = 'CREATE' THEN

        l_price_adj_rec.quote_header_id := l_qte_line_rec.quote_header_id;
        l_price_adj_rec.quote_line_id := l_qte_line_rec.quote_line_id;
        -- BC4J Fix
	   --x_price_adj_tbl(i).PRICE_ADJUSTMENT_ID := NULL;

        ASO_PRICE_ADJUSTMENTS_PKG.Insert_Row(
            px_PRICE_ADJUSTMENT_ID  => x_price_adj_tbl(i).PRICE_ADJUSTMENT_ID,
            p_CREATION_DATE  	    => SYSDATE,
            p_CREATED_BY  	    => G_USER_ID,
            p_LAST_UPDATE_DATE      => SYSDATE,
            p_LAST_UPDATED_BY  	    => G_USER_ID,
            p_LAST_UPDATE_LOGIN     => G_LOGIN_ID,
            p_PROGRAM_APPLICATION_ID  =>l_price_adj_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID  	    => l_price_adj_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE   => l_price_adj_rec.PROGRAM_UPDATE_DATE,
            p_REQUEST_ID 	    => l_price_adj_rec.REQUEST_ID,
            p_QUOTE_HEADER_ID  	    => l_price_adj_rec.QUOTE_HEADER_ID,
            p_QUOTE_LINE_ID  	    => l_price_adj_rec.QUOTE_LINE_ID,
            p_QUOTE_SHIPMENT_ID     => l_price_adj_rec.QUOTE_SHIPMENT_ID,
            p_MODIFIER_HEADER_ID    => l_price_adj_rec.MODIFIER_HEADER_ID,
            p_MODIFIER_LINE_ID      => l_price_adj_rec.MODIFIER_LINE_ID,
            p_MODIFIER_LINE_TYPE_CODE
				    => l_price_adj_rec.MODIFIER_LINE_TYPE_CODE,
            p_MODIFIER_MECHANISM_TYPE_CODE
			=> l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE,
            p_MODIFIED_FROM  	    => l_price_adj_rec.MODIFIED_FROM,
            p_MODIFIED_TO    	    => l_price_adj_rec.MODIFIED_TO,
            p_OPERAND        	    => l_price_adj_rec.OPERAND,
            p_ARITHMETIC_OPERATOR   => l_price_adj_rec.ARITHMETIC_OPERATOR,
            p_AUTOMATIC_FLAG        => l_price_adj_rec.AUTOMATIC_FLAG,
            p_UPDATE_ALLOWABLE_FLAG => l_price_adj_rec.UPDATE_ALLOWABLE_FLAG,
            p_UPDATED_FLAG          => l_price_adj_rec.UPDATED_FLAG,
            p_APPLIED_FLAG          => l_price_adj_rec.APPLIED_FLAG,
            p_ON_INVOICE_FLAG       => l_price_adj_rec.ON_INVOICE_FLAG,
            p_PRICING_PHASE_ID      => l_price_adj_rec.PRICING_PHASE_ID,
            p_ATTRIBUTE_CATEGORY    => l_price_adj_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  	    => l_price_adj_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  	    => l_price_adj_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  	    => l_price_adj_rec.ATTRIBUTE3,
            p_ATTRIBUTE4  	    => l_price_adj_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  	    => l_price_adj_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  	    => l_price_adj_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  	    => l_price_adj_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  	    => l_price_adj_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  	    => l_price_adj_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  	    => l_price_adj_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  	    => l_price_adj_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  	    => l_price_adj_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  	    => l_price_adj_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  	    => l_price_adj_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  	    => l_price_adj_rec.ATTRIBUTE15,
            p_ATTRIBUTE16  =>  l_price_adj_rec.ATTRIBUTE16,
            p_ATTRIBUTE17  =>  l_price_adj_rec.ATTRIBUTE17,
            p_ATTRIBUTE18  =>  l_price_adj_rec.ATTRIBUTE18,
            p_ATTRIBUTE19  =>  l_price_adj_rec.ATTRIBUTE19,
            p_ATTRIBUTE20  =>  l_price_adj_rec.ATTRIBUTE20,
		  p_ORIG_SYS_DISCOUNT_REF                    => l_price_adj_rec.ORIG_SYS_DISCOUNT_REF ,
          p_CHANGE_SEQUENCE                           => l_price_adj_rec.CHANGE_SEQUENCE ,
          -- p_LIST_HEADER_ID                            => l_price_adj_rec. ,
          -- p_LIST_LINE_ID                              => l_price_adj_rec. ,
          -- p_LIST_LINE_TYPE_CODE                       => l_price_adj_rec.,
          p_UPDATE_ALLOWED                            => l_price_adj_rec.UPDATE_ALLOWED,
          p_CHANGE_REASON_CODE                        => l_price_adj_rec.CHANGE_REASON_CODE,
          p_CHANGE_REASON_TEXT                        => l_price_adj_rec.CHANGE_REASON_TEXT,
          p_COST_ID                                   => l_price_adj_rec.COST_ID ,
          p_TAX_CODE                                  => l_price_adj_rec.TAX_CODE,
          p_TAX_EXEMPT_FLAG                           => l_price_adj_rec.TAX_EXEMPT_FLAG,
          p_TAX_EXEMPT_NUMBER                         => l_price_adj_rec.TAX_EXEMPT_NUMBER,
          p_TAX_EXEMPT_REASON_CODE                    => l_price_adj_rec.TAX_EXEMPT_REASON_CODE,
          p_PARENT_ADJUSTMENT_ID                      => l_price_adj_rec.PARENT_ADJUSTMENT_ID,
          p_INVOICED_FLAG                             => l_price_adj_rec.INVOICED_FLAG,
          p_ESTIMATED_FLAG                            => l_price_adj_rec.ESTIMATED_FLAG,
          p_INC_IN_SALES_PERFORMANCE                  => l_price_adj_rec.INC_IN_SALES_PERFORMANCE,
          p_SPLIT_ACTION_CODE                         => l_price_adj_rec.SPLIT_ACTION_CODE,
          p_ADJUSTED_AMOUNT                           => l_price_adj_rec.ADJUSTED_AMOUNT ,
          p_CHARGE_TYPE_CODE                          => l_price_adj_rec.CHARGE_TYPE_CODE,
          p_CHARGE_SUBTYPE_CODE                       => l_price_adj_rec.CHARGE_SUBTYPE_CODE,
          p_RANGE_BREAK_QUANTITY                      => l_price_adj_rec.RANGE_BREAK_QUANTITY,
          p_ACCRUAL_CONVERSION_RATE                   => l_price_adj_rec.ACCRUAL_CONVERSION_RATE ,
          p_PRICING_GROUP_SEQUENCE                    => l_price_adj_rec.PRICING_GROUP_SEQUENCE,
          p_ACCRUAL_FLAG                              => l_price_adj_rec.ACCRUAL_FLAG,
          p_LIST_LINE_NO                              => l_price_adj_rec.LIST_LINE_NO,
          p_SOURCE_SYSTEM_CODE                        => l_price_adj_rec.SOURCE_SYSTEM_CODE ,
          p_BENEFIT_QTY                               => l_price_adj_rec.BENEFIT_QTY,
          p_BENEFIT_UOM_CODE                          => l_price_adj_rec.BENEFIT_UOM_CODE,
          p_PRINT_ON_INVOICE_FLAG                     => l_price_adj_rec.PRINT_ON_INVOICE_FLAG,
          p_EXPIRATION_DATE                           => l_price_adj_rec.EXPIRATION_DATE,
          p_REBATE_TRANSACTION_TYPE_CODE              => l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE,
          p_REBATE_TRANSACTION_REFERENCE              => l_price_adj_rec.REBATE_TRANSACTION_REFERENCE,
          p_REBATE_PAYMENT_SYSTEM_CODE                => l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE,
          p_REDEEMED_DATE                             => l_price_adj_rec.REDEEMED_DATE,
          p_REDEEMED_FLAG                             => l_price_adj_rec.REDEEMED_FLAG,
          p_MODIFIER_LEVEL_CODE                       => l_price_adj_rec.MODIFIER_LEVEL_CODE,
          p_PRICE_BREAK_TYPE_CODE                     => l_price_adj_rec.PRICE_BREAK_TYPE_CODE ,
          p_SUBSTITUTION_ATTRIBUTE                    => l_price_adj_rec.SUBSTITUTION_ATTRIBUTE,
          p_PRORATION_TYPE_CODE                       => l_price_adj_rec.PRORATION_TYPE_CODE ,
          p_INCLUDE_ON_RETURNS_FLAG                   => l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG,
          p_CREDIT_OR_CHARGE_FLAG                     => l_price_adj_rec.CREDIT_OR_CHARGE_FLAG,
		p_OPERAND_PER_PQTY                          => l_price_adj_rec.OPERAND_PER_PQTY,
		p_ADJUSTED_AMOUNT_PER_PQTY                  => l_price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY,
		p_OBJECT_VERSION_NUMBER                     => l_price_adj_rec.OBJECT_VERSION_NUMBER);

   FOR j in 1..l_price_adj_attr_tbl.count LOOP
     IF l_price_adj_attr_tbl(j).price_adj_index = j THEN
        l_price_adj_attr_tbl(j).price_adjustment_id := x_price_adj_tbl(i).PRICE_ADJUSTMENT_ID;
     END IF;
   END LOOP;


   ELSIF l_price_adj_rec.operation_code = 'UPDATE' THEN
         -- New Code for updating PBH
         if l_price_adj_rec.updated_flag = 'Y' then

            l_price_adjustment_id := null;

            --get the price_adjustment_id of the PBH adjustment line, if this is children of a PBH parent
            open c_pbh( l_price_adj_rec.price_adjustment_id );
            fetch c_pbh into l_price_adjustment_id;
            close c_pbh;


            --if the above query returns a not null value then update all the children of this PBH

            if  l_price_adjustment_id is not null then

               --update all child lines
               UPDATE aso_price_adjustments
               SET updated_flag = 'Y',
                   applied_flag = null
               Where price_adjustment_id in ( SELECT rltd_price_adj_id
                                              FROM aso_price_adj_relationships b
                                              WHERE price_adjustment_id = l_price_adjustment_id );

               --update the parent PBH line
               UPDATE aso_price_adjustments
               SET updated_flag = 'Y',
                   applied_flag = 'Y'
               Where price_adjustment_id = l_price_adjustment_id;

            end if;

         end if;


        ASO_PRICE_ADJUSTMENTS_PKG.Update_Row(
            p_PRICE_ADJUSTMENT_ID  => l_price_adj_rec.PRICE_ADJUSTMENT_ID,
            p_CREATION_DATE  	=> l_price_adj_rec.creation_date,
            p_CREATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  	=> G_USER_ID,
            p_LAST_UPDATE_LOGIN => G_LOGIN_ID,
            p_PROGRAM_APPLICATION_ID  =>l_price_adj_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID  	    => l_price_adj_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE   => l_price_adj_rec.PROGRAM_UPDATE_DATE,
            p_REQUEST_ID  	    => l_price_adj_rec.REQUEST_ID,
            p_QUOTE_HEADER_ID  	    => l_price_adj_rec.QUOTE_HEADER_ID,
            p_QUOTE_LINE_ID  	    => l_price_adj_rec.QUOTE_LINE_ID,
            p_QUOTE_SHIPMENT_ID     => l_price_adj_rec.QUOTE_SHIPMENT_ID,
            p_MODIFIER_HEADER_ID    => l_price_adj_rec.MODIFIER_HEADER_ID,
            p_MODIFIER_LINE_ID      => l_price_adj_rec.MODIFIER_LINE_ID,
            p_MODIFIER_LINE_TYPE_CODE
				=> l_price_adj_rec.MODIFIER_LINE_TYPE_CODE,
            p_MODIFIER_MECHANISM_TYPE_CODE
			=> l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE,
            p_MODIFIED_FROM  	    => l_price_adj_rec.MODIFIED_FROM,
            p_MODIFIED_TO  	    => l_price_adj_rec.MODIFIED_TO,
            p_OPERAND      	    => l_price_adj_rec.OPERAND,
            p_ARITHMETIC_OPERATOR   => l_price_adj_rec.ARITHMETIC_OPERATOR,
            p_AUTOMATIC_FLAG        => l_price_adj_rec.AUTOMATIC_FLAG,
            p_UPDATE_ALLOWABLE_FLAG => l_price_adj_rec.UPDATE_ALLOWABLE_FLAG,
            p_UPDATED_FLAG          => l_price_adj_rec.UPDATED_FLAG,
            p_APPLIED_FLAG          => l_price_adj_rec.APPLIED_FLAG,
            p_ON_INVOICE_FLAG       => l_price_adj_rec.ON_INVOICE_FLAG,
            p_PRICING_PHASE_ID      => l_price_adj_rec.PRICING_PHASE_ID,
            p_ATTRIBUTE_CATEGORY    => l_price_adj_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  	    => l_price_adj_rec.ATTRIBUTE1,
            p_ATTRIBUTE2  	    => l_price_adj_rec.ATTRIBUTE2,
            p_ATTRIBUTE3  	    => l_price_adj_rec.ATTRIBUTE3,
            p_ATTRIBUTE4  	    => l_price_adj_rec.ATTRIBUTE4,
            p_ATTRIBUTE5  	    => l_price_adj_rec.ATTRIBUTE5,
            p_ATTRIBUTE6  	    => l_price_adj_rec.ATTRIBUTE6,
            p_ATTRIBUTE7  	    => l_price_adj_rec.ATTRIBUTE7,
            p_ATTRIBUTE8  	    => l_price_adj_rec.ATTRIBUTE8,
            p_ATTRIBUTE9  	    => l_price_adj_rec.ATTRIBUTE9,
            p_ATTRIBUTE10  	    => l_price_adj_rec.ATTRIBUTE10,
            p_ATTRIBUTE11  	    => l_price_adj_rec.ATTRIBUTE11,
            p_ATTRIBUTE12  	    => l_price_adj_rec.ATTRIBUTE12,
            p_ATTRIBUTE13  	    => l_price_adj_rec.ATTRIBUTE13,
            p_ATTRIBUTE14  	    => l_price_adj_rec.ATTRIBUTE14,
            p_ATTRIBUTE15  	    => l_price_adj_rec.ATTRIBUTE15,
            p_ATTRIBUTE16  =>  l_price_adj_rec.ATTRIBUTE16,
            p_ATTRIBUTE17  =>  l_price_adj_rec.ATTRIBUTE17,
            p_ATTRIBUTE18  =>  l_price_adj_rec.ATTRIBUTE18,
            p_ATTRIBUTE19  =>  l_price_adj_rec.ATTRIBUTE19,
            p_ATTRIBUTE20  =>  l_price_adj_rec.ATTRIBUTE20,
		  p_ORIG_SYS_DISCOUNT_REF                    => l_price_adj_rec.ORIG_SYS_DISCOUNT_REF ,
          p_CHANGE_SEQUENCE                           => l_price_adj_rec.CHANGE_SEQUENCE ,
          -- p_LIST_HEADER_ID                            => l_price_adj_rec. ,
          -- p_LIST_LINE_ID                              => l_price_adj_rec. ,
          -- p_LIST_LINE_TYPE_CODE                       => l_price_adj_rec.,
          p_UPDATE_ALLOWED                            => l_price_adj_rec.UPDATE_ALLOWED,
          p_CHANGE_REASON_CODE                        => l_price_adj_rec.CHANGE_REASON_CODE,
          p_CHANGE_REASON_TEXT                        => l_price_adj_rec.CHANGE_REASON_TEXT,
          p_COST_ID                                   => l_price_adj_rec.COST_ID ,
          p_TAX_CODE                                  => l_price_adj_rec.TAX_CODE,
          p_TAX_EXEMPT_FLAG                           => l_price_adj_rec.TAX_EXEMPT_FLAG,
          p_TAX_EXEMPT_NUMBER                         => l_price_adj_rec.TAX_EXEMPT_NUMBER,
          p_TAX_EXEMPT_REASON_CODE                    => l_price_adj_rec.TAX_EXEMPT_REASON_CODE,
          p_PARENT_ADJUSTMENT_ID                      => l_price_adj_rec.PARENT_ADJUSTMENT_ID,
          p_INVOICED_FLAG                             => l_price_adj_rec.INVOICED_FLAG,
          p_ESTIMATED_FLAG                            => l_price_adj_rec.ESTIMATED_FLAG,
          p_INC_IN_SALES_PERFORMANCE                  => l_price_adj_rec.INC_IN_SALES_PERFORMANCE,
          p_SPLIT_ACTION_CODE                         => l_price_adj_rec.SPLIT_ACTION_CODE,
          p_ADJUSTED_AMOUNT                           => l_price_adj_rec.ADJUSTED_AMOUNT ,
          p_CHARGE_TYPE_CODE                          => l_price_adj_rec.CHARGE_TYPE_CODE,
          p_CHARGE_SUBTYPE_CODE                       => l_price_adj_rec.CHARGE_SUBTYPE_CODE,
          p_RANGE_BREAK_QUANTITY                      => l_price_adj_rec.RANGE_BREAK_QUANTITY,
          p_ACCRUAL_CONVERSION_RATE                   => l_price_adj_rec.ACCRUAL_CONVERSION_RATE ,
          p_PRICING_GROUP_SEQUENCE                    => l_price_adj_rec.PRICING_GROUP_SEQUENCE,
          p_ACCRUAL_FLAG                              => l_price_adj_rec.ACCRUAL_FLAG,
          p_LIST_LINE_NO                              => l_price_adj_rec.LIST_LINE_NO,
          p_SOURCE_SYSTEM_CODE                        => l_price_adj_rec.SOURCE_SYSTEM_CODE ,
          p_BENEFIT_QTY                               => l_price_adj_rec.BENEFIT_QTY,
          p_BENEFIT_UOM_CODE                          => l_price_adj_rec.BENEFIT_UOM_CODE,
          p_PRINT_ON_INVOICE_FLAG                     => l_price_adj_rec.PRINT_ON_INVOICE_FLAG,
          p_EXPIRATION_DATE                           => l_price_adj_rec.EXPIRATION_DATE,
          p_REBATE_TRANSACTION_TYPE_CODE              => l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE,
          p_REBATE_TRANSACTION_REFERENCE              => l_price_adj_rec.REBATE_TRANSACTION_REFERENCE,
          p_REBATE_PAYMENT_SYSTEM_CODE                => l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE,
          p_REDEEMED_DATE                             => l_price_adj_rec.REDEEMED_DATE,
          p_REDEEMED_FLAG                             => l_price_adj_rec.REDEEMED_FLAG,
          p_MODIFIER_LEVEL_CODE                       => l_price_adj_rec.MODIFIER_LEVEL_CODE,
          p_PRICE_BREAK_TYPE_CODE                     => l_price_adj_rec.PRICE_BREAK_TYPE_CODE ,
          p_SUBSTITUTION_ATTRIBUTE                    => l_price_adj_rec.SUBSTITUTION_ATTRIBUTE,
          p_PRORATION_TYPE_CODE                       => l_price_adj_rec.PRORATION_TYPE_CODE ,
          p_INCLUDE_ON_RETURNS_FLAG                   => l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG,
          p_CREDIT_OR_CHARGE_FLAG                     => l_price_adj_rec.CREDIT_OR_CHARGE_FLAG,
		p_OPERAND_PER_PQTY                          => l_price_adj_rec.OPERAND_PER_PQTY,
		p_ADJUSTED_AMOUNT_PER_PQTY                  => l_price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY,
		p_OBJECT_VERSION_NUMBER                     => l_price_adj_rec.OBJECT_VERSION_NUMBER
		);

       ELSIF l_price_adj_rec.operation_code = 'DELETE' THEN
        ASO_PRICE_ADJUSTMENTS_PKG.Delete_Row(
            p_PRICE_ADJ_ID  => l_price_adj_rec.PRICE_ADJUSTMENT_ID);

       END IF;
    END LOOP;


-- price adjustment attributes

           FOR i in 1..l_price_adj_attr_tbl.count LOOP

           x_price_adj_attr_tbl(i) := l_price_adj_attr_tbl(i);

     IF l_price_adj_attr_tbl(i).operation_code = 'CREATE' THEN
        -- BC4J Fix
        -- x_price_adj_attr_tbl(i).PRICE_ADJ_ATTRIB_ID := null;

    	ASO_PRICE_ADJ_ATTRIBS_PKG.Insert_Row(
          px_PRICE_ADJ_ATTRIB_ID=> x_price_adj_attr_tbl(i).PRICE_ADJ_ATTRIB_ID,
          p_CREATION_DATE  	=> SYSDATE,
          p_CREATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_LOGIN => G_LOGIN_ID,
          p_PROGRAM_APPLICATION_ID
			=>l_price_adj_attr_tbl(i).PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  	=> l_price_adj_attr_tbl(i).PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE => l_price_adj_attr_tbl(i).PROGRAM_UPDATE_DATE,
          p_REQUEST_ID  	=> l_price_adj_attr_tbl(i).REQUEST_ID,
          p_PRICE_ADJUSTMENT_ID => l_price_adj_attr_tbl(i).PRICE_ADJUSTMENT_ID,
          p_PRICING_CONTEXT  	=> l_price_adj_attr_tbl(i).PRICING_CONTEXT,
          p_PRICING_ATTRIBUTE   => l_price_adj_attr_tbl(i).PRICING_ATTRIBUTE,
          p_PRICING_ATTR_VALUE_FROM
			=> l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_FROM,
          p_PRICING_ATTR_VALUE_TO
			=> l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_TO,
          p_COMPARISON_OPERATOR => l_price_adj_attr_tbl(i).COMPARISON_OPERATOR,
          p_FLEX_TITLE   	=> l_price_adj_attr_tbl(i).FLEX_TITLE ,
		p_OBJECT_VERSION_NUMBER                     => l_price_adj_attr_tbl(i).OBJECT_VERSION_NUMBER);

   ELSIF l_price_adj_attr_tbl(i).operation_code = 'UPDATE' THEN

    ASO_PRICE_ADJ_ATTRIBS_PKG.Update_Row(
          p_PRICE_ADJ_ATTRIB_ID => l_price_adj_attr_tbl(i).PRICE_ADJ_ATTRIB_ID,
          p_CREATION_DATE  	=> l_price_adj_attr_tbl(i).creation_date,
          p_CREATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_DATE  	=> SYSDATE,
          p_LAST_UPDATED_BY  	=> G_USER_ID,
          p_LAST_UPDATE_LOGIN  	=> G_LOGIN_ID,
          p_PROGRAM_APPLICATION_ID
		=>l_price_adj_attr_tbl(i).PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  	=> l_price_adj_attr_tbl(i).PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE => l_price_adj_attr_tbl(i).PROGRAM_UPDATE_DATE,
          p_REQUEST_ID  	=> l_price_adj_attr_tbl(i).REQUEST_ID,
          p_PRICE_ADJUSTMENT_ID => l_price_adj_attr_tbl(i).PRICE_ADJUSTMENT_ID,
          p_PRICING_CONTEXT  	=> l_price_adj_attr_tbl(i).PRICING_CONTEXT,
          p_PRICING_ATTRIBUTE   => l_price_adj_attr_tbl(i).PRICING_ATTRIBUTE,
          p_PRICING_ATTR_VALUE_FROM
			=> l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_FROM,
          p_PRICING_ATTR_VALUE_TO
			=> l_price_adj_attr_tbl(i).PRICING_ATTR_VALUE_TO,
          p_COMPARISON_OPERATOR => l_price_adj_attr_tbl(i).COMPARISON_OPERATOR,
          p_FLEX_TITLE   	=> l_price_adj_attr_tbl(i).FLEX_TITLE ,
		p_OBJECT_VERSION_NUMBER                     => l_price_adj_attr_tbl(i).OBJECT_VERSION_NUMBER
		);

   ELSIF l_price_adj_attr_tbl(i).operation_code = 'DELETE' THEN

    ASO_PRICE_ADJ_ATTRIBS_PKG.Delete_Row(
          p_PRICE_ADJ_ATTRIB_ID   => l_price_adj_attr_tbl(i).PRICE_ADJ_ATTRIB_ID);

   END IF;

END LOOP;


-- New code to call aso_pricing_int.delete_promotion 07/22/02
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
   		aso_debug_pub.add('Update_Rows: l_Price_Attributes_Tbl.count: '||l_Price_Attributes_Tbl.count,1, 'N');
   		aso_debug_pub.add('Update_Rows: Before call to aso_pricing_int.Delete_Promotion',1, 'N');
	end if;

   IF l_Price_Attributes_Tbl.count > 0 THEN

        aso_pricing_int.Delete_Promotion (
                           P_Api_Version_Number =>  1.0,
                           P_Init_Msg_List      =>  FND_API.G_FALSE,
                           P_Commit             =>  FND_API.G_FALSE,
                           p_price_attr_tbl     =>  l_Price_Attributes_Tbl,
                           x_return_status      =>  x_return_status,
                           x_msg_count          =>  x_msg_count,
                           x_msg_data           =>  x_msg_data
                                   );
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
        	aso_debug_pub.add('Update_Rows: After call to Delete_Promotion: x_return_status: '||x_return_status,1, 'N');
	end if;

   END IF;

-- End of New code to call aso_pricing_int.delete_promotion 07/22/02


-- insert rows into aso_payments_tbl


    FOR i IN 1..l_Payment_Tbl.count LOOP
	l_payment_rec := l_payment_tbl(i);
       -- l_payment_rec.quote_line_id :=  x_qte_line_rec.QUOTE_LINE_ID;
        x_payment_tbl(i) := l_payment_rec;

       IF l_payment_rec.operation_code = 'CREATE' THEN

        l_payment_rec.quote_header_id := l_qte_line_rec.quote_header_id;
        l_payment_rec.quote_line_id := l_qte_line_rec.quote_line_id;
       -- BC4J Fix
	  -- x_payment_tbl(i).PAYMENT_ID := null;
        l_payment_rec.PAYMENT_TERM_ID_FROM := l_payment_tbl(i).payment_term_id;
       IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Insert Rows Quote Line l_payment_tbl(i).payment_term_id'||l_payment_tbl(i).payment_term_id, 1, 'Y');
        aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Insert Rows Quote Linel_payment_rec.PAYMENT_TERM_ID_FROM'||l_payment_rec.PAYMENT_TERM_ID_FROM, 1, 'Y');
       END IF;

     -- Suyog Payments Changes

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote_Line_Rows: Before  call to create_payment_row ', 1, 'Y');
           END IF;

         aso_payment_int.create_payment_row(p_payment_rec => l_payment_rec  ,
                                             x_payment_rec   => x_payment_tbl(i),
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote_Line_Rows: After call to create_payment_row: x_return_status: '||x_return_status, 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;

     -- End Suyog Payment Changes

         x_payment_tbl(i).PAYMENT_TERM_ID_FROM := l_payment_rec.PAYMENT_TERM_ID_FROM;

      ELSIF l_payment_rec.operation_code = 'UPDATE' THEN

        IF l_payment_rec.payment_term_id = FND_API.G_MISS_NUM THEN
          FOR l_payment_db_rec IN c_db_payment_terms(l_payment_rec.PAYMENT_ID) LOOP
            IF l_payment_db_rec.payment_term_id_from IS NULL THEN
              l_payment_rec.payment_term_id_from := l_payment_db_rec.payment_term_id;
            END IF;
          END LOOP;
        ELSE
              l_payment_rec.payment_term_id_from := l_payment_rec.payment_term_id;
        END IF;
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Update Rows l_payment_rec.payment_term_id'||l_payment_rec.payment_term_id, 1, 'Y');
            aso_debug_pub.add('Inside ASO_PAYMENTS_PKG - Update Rows l_payment_rec.PAYMENT_TERM_ID_FROM'||l_payment_rec.PAYMENT_TERM_ID_FROM, 1, 'Y');
         END IF;


     -- Suyog Payments Changes

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote_Line_Rows: Before  call to update_payment_row ', 1, 'Y');
           END IF;

         aso_payment_int.update_payment_row(p_payment_rec => l_payment_rec  ,
                                             x_payment_rec   => x_payment_tbl(i),
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote_Line_Rows: After call to update_payment_row: x_return_status: '||x_return_status, 1, 'Y');
           END IF;
            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;

     -- End Suyog Payment Changes


       ELSIF l_payment_rec.operation_code = 'DELETE' THEN

     -- Suyog Payments Changes

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote_Line_Rows: Before  call to delete_payment_row ', 1, 'Y');
           END IF;

         aso_payment_int.delete_payment_row(p_payment_rec => l_payment_rec  ,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Update_Quote_Line_Rows: After call to delete_payment_row: x_return_status: '||x_return_status, 1, 'Y');
           END IF;
            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;

     -- End Suyog Payment Changes

       END IF;

    END LOOP;       -- payment loop

          -- fix for bug 4483808 , moved validation after the row has been updated
          aso_validate_pvt.Validate_po_line_number
          (
               p_init_msg_list       => fnd_api.g_false,
               p_qte_header_rec    => l_qte_header_rec,
               P_Qte_Line_rec   => l_Qte_Line_Rec,
               x_return_status     => x_return_status,
               x_msg_count         => x_msg_count,
               x_msg_data          => x_msg_data);

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
            END IF;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('x_return_status for Validate_po_line_number'||  x_return_status, 1, 'Y');
          END IF;


    FOR i IN 1..l_line_attribs_ext_Tbl.count LOOP
	l_line_attribs_rec := l_line_attribs_ext_tbl(i);
     --   l_line_attribs_rec.quote_line_id :=  x_qte_line_rec.QUOTE_LINE_ID;
        x_line_attribs_ext_tbl(i) := l_line_attribs_rec;

     IF l_line_attribs_rec.operation_code = 'CREATE' THEN
      -- BC4J Fix
      --x_LINE_ATTRIBS_EXT_TBL(i).LINE_ATTRIBUTE_ID := null;

 ASO_QUOTE_LINE_ATTRIBS_EXT_PKG.Insert_Row(
          px_LINE_ATTRIBUTE_ID  => x_LINE_ATTRIBS_EXT_TBL(i).LINE_ATTRIBUTE_ID,
          p_CREATION_DATE          => SYSDATE,
          p_CREATED_BY             => G_USER_ID,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_LAST_UPDATED_BY        => G_USER_ID,
          p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
          p_REQUEST_ID             => l_LINE_ATTRIBS_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID =>l_LINE_ATTRIBS_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID             => l_LINE_ATTRIBS_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE    => l_LINE_ATTRIBS_rec.PROGRAM_UPDATE_DATE,
           p_APPLICATION_ID         => l_LINE_ATTRIBS_rec.APPLICATION_ID,
           p_STATUS                 => l_LINE_ATTRIBS_rec.STATUS,
          p_QUOTE_HEADER_ID          => l_LINE_ATTRIBS_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID          => l_LINE_ATTRIBS_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID          => l_LINE_ATTRIBS_rec.QUOTE_SHIPMENT_ID,
          p_ATTRIBUTE_TYPE_CODE    => l_LINE_ATTRIBS_rec.ATTRIBUTE_TYPE_CODE,
          p_NAME                   => l_LINE_ATTRIBS_rec.NAME,
          p_VALUE                  => l_LINE_ATTRIBS_rec.VALUE,
           p_VALUE_TYPE             => l_LINE_ATTRIBS_rec.VALUE_TYPE,
          p_START_DATE_ACTIVE      => l_LINE_ATTRIBS_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE        => l_LINE_ATTRIBS_rec.END_DATE_ACTIVE,
		p_OBJECT_VERSION_NUMBER  => l_LINE_ATTRIBS_rec.OBJECT_VERSION_NUMBER);

      ELSIF l_line_attribs_rec.operation_code = 'UPDATE' THEN
      ASO_QUOTE_LINE_ATTRIBS_EXT_PKG.Update_Row(
          p_LINE_ATTRIBUTE_ID  => l_LINE_ATTRIBS_REC.LINE_ATTRIBUTE_ID,
          p_CREATION_DATE          => l_LINE_ATTRIBS_rec.creation_date,
          p_CREATED_BY             => G_USER_ID,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_LAST_UPDATED_BY        => G_USER_ID,
          p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
          p_REQUEST_ID             => l_LINE_ATTRIBS_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID =>l_LINE_ATTRIBS_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID             => l_LINE_ATTRIBS_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE    => l_LINE_ATTRIBS_rec.PROGRAM_UPDATE_DATE,
           p_APPLICATION_ID         => l_LINE_ATTRIBS_rec.APPLICATION_ID,
          p_STATUS                 => l_LINE_ATTRIBS_rec.STATUS,
          p_QUOTE_HEADER_ID        => l_LINE_ATTRIBS_rec.QUOTE_HEADER_ID,
          p_QUOTE_LINE_ID          => l_LINE_ATTRIBS_rec.QUOTE_LINE_ID,
          p_QUOTE_SHIPMENT_ID      => l_LINE_ATTRIBS_rec.QUOTE_SHIPMENT_ID,
          p_ATTRIBUTE_TYPE_CODE    => l_LINE_ATTRIBS_rec.ATTRIBUTE_TYPE_CODE,
          p_NAME                   => l_LINE_ATTRIBS_rec.NAME,
          p_VALUE                  => l_LINE_ATTRIBS_rec.VALUE,
           p_VALUE_TYPE             => l_LINE_ATTRIBS_rec.VALUE_TYPE,
          p_START_DATE_ACTIVE      => l_LINE_ATTRIBS_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE        => l_LINE_ATTRIBS_rec.END_DATE_ACTIVE,
		p_OBJECT_VERSION_NUMBER  => l_LINE_ATTRIBS_rec.OBJECT_VERSION_NUMBER);

     ELSIF l_line_attribs_rec.operation_code = 'DELETE' THEN
     ASO_QUOTE_LINE_ATTRIBS_EXT_PKG.delete_Row(
          p_LINE_ATTRIB_ID  => l_LINE_ATTRIBS_rec.LINE_ATTRIBUTE_ID);
     END IF;
END LOOP;      -- line attribs


     --set the ship partial flag

     OPEN  C_ship_partial(l_Qte_Line_Rec.quote_line_id);
     FETCH C_ship_partial INTO l_ship_count;
     CLOSE C_ship_partial;

     IF l_ship_count > 1 THEN

        update aso_quote_lines_all
        set split_shipment_flag  =  'T',
            last_update_date     =  sysdate,
            last_updated_by      =  fnd_global.user_id,
            last_update_login    =  fnd_global.conc_login_id
        where quote_line_id = l_Qte_Line_Rec.quote_line_id;

     ELSIF l_ship_count = 1 THEN

        update aso_quote_lines_all
        set split_shipment_flag  =  'F',
            last_update_date     =  sysdate,
            last_updated_by      =  fnd_global.user_id,
            last_update_login    =  fnd_global.conc_login_id
        where quote_line_id = l_Qte_Line_Rec.quote_line_id;

     END IF;



   IF  l_control_rec.line_pricing_event IS NOT NULL AND
        l_control_rec.line_pricing_event <> FND_API.G_MISS_CHAR  THEN

      l_pricing_control_rec.pricing_event := l_control_rec.line_pricing_event;
      l_pricing_control_rec.request_type  := l_control_rec.pricing_request_type;
      l_pricing_control_rec.price_mode    := l_control_rec.price_mode;

	 x_qte_line_rec.quote_line_id        := l_qte_line_rec.quote_line_id;
      l_qte_line_tbl(1)                   := l_Qte_Line_Rec;

      --New Code to call overload pricing_order

        l_hd_price_attr_tbl := aso_utility_pvt.query_price_attr_rows(l_qte_header_rec.quote_header_id,null);
        l_hd_shipment_tbl   := aso_utility_pvt.query_shipment_rows(l_qte_header_rec.quote_header_id,null);

        if l_hd_shipment_tbl.count = 1 then
            l_hd_shipment_rec := l_hd_shipment_tbl(1);
        end if;


        ASO_PRICING_INT.Pricing_Order(
                    P_Api_Version_Number     => 1.0,
                    P_Init_Msg_List          => fnd_api.g_false,
                    P_Commit                 => fnd_api.g_false,
                    p_control_rec            => l_pricing_control_rec,
                    p_qte_header_rec         => l_qte_header_rec,
                    p_hd_shipment_rec        => l_hd_shipment_rec,
                    p_hd_price_attr_tbl      => l_hd_price_attr_tbl,
                    p_qte_line_tbl           => l_qte_line_tbl,
                    --p_line_rltship_tbl     => l_line_rltship_tbl,
                    --p_qte_line_dtl_tbl     => l_qte_line_dtl_tbl,
                    --p_ln_shipment_tbl      => ln_shipment_tbl,
                    --p_ln_price_attr_tbl    => l_ln_price_attr_tbl,
                    x_qte_header_rec         => lx_qte_header_rec,
                    x_qte_line_tbl           => lx_qte_line_tbl,
                    x_qte_line_dtl_tbl       => lx_qte_line_dtl_tbl,
                    x_price_adj_tbl          => lx_price_adj_tbl,
                    x_price_adj_attr_tbl     => lx_price_adj_attr_tbl,
                    x_price_adj_rltship_tbl  => lx_price_adj_rltship_tbl,
                    x_return_status          => x_return_status,
                    x_msg_count              => x_msg_count,
                    x_msg_data               => x_msg_data );

      if lx_qte_line_tbl.count > 0 then
		x_qte_line_rec  :=  lx_qte_line_tbl(1);
      end if;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;


   END IF;        -- pricing

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Update_Quote_line - before calculate_tax_flag ', 1, 'N');
   end if;

   /*
    *
    *
   IF l_control_rec.CALCULATE_TAX_FLAG = 'Y'THEN
      l_tax_control_rec.tax_level := 'SHIPPING';
      l_tax_control_rec.update_db := 'Y' ;  --FND_API.G_TRUE;

      l_calc_tax_detail_rec.quote_header_id := l_Qte_Line_Rec.quote_header_id;
      l_calc_tax_detail_rec.quote_line_id := l_Qte_Line_Rec.quote_line_id;

-- added to calc tax based on accounts
        OPEN get_cust_acct( l_Qte_Line_Rec.QUOTE_HEADER_ID);
        FETCH get_cust_acct into l_cust_acct;
        IF get_cust_acct%NOTFOUND THEN
          NULL;
        END IF;
        CLOSE get_cust_acct;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Cust acct'||l_cust_acct , 1, 'Y');
	end if;

        IF (l_Qte_Line_Rec.invoice_to_party_site_id is not NULL
      AND l_Qte_Line_Rec.invoice_to_party_site_id <> FND_API.G_MISS_NUM) AND
       (l_cust_acct is NOT NULL AND l_cust_acct <> FND_API.G_MISS_NUM)  THEN
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
     		aso_debug_pub.add('inside if'||nvl(to_char(l_Qte_Line_Rec.invoice_to_party_site_id),'null'), 1, 'Y' );
	end if;

          ASO_PARTY_INT.GET_ACCT_SITE_USES (
  		  p_api_version     => 1.0
 		 ,P_Cust_Account_Id => l_cust_acct
 		 ,P_Party_Site_Id   => l_Qte_Line_Rec.invoice_to_party_site_id
	         ,P_Acct_Site_type  => 'BILL_TO'
 		 ,x_return_status   => l_return_status
 		 ,x_msg_count       => l_msg_count
 		 ,x_msg_data        => l_msg_data
 		 ,x_site_use_id     => l_invoice_org_id
  	   );
              IF L_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                  FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
                  FND_MESSAGE.Set_Token('COLUMN', 'INVOICE_TO_SITE_USE_ID',FALSE);
                  FND_MSG_PUB.ADD;
                END IF;
               -- raise FND_API.G_EXC_ERROR;
              END IF;
      END IF;

lx_tax_shipment_tbl :=  ASO_UTILITY_PVT.Query_Shipment_Rows(l_Qte_Line_Rec.quote_header_id,l_Qte_Line_Rec.quote_line_id);

      FOR i in 1..lx_tax_shipment_tbl.count LOOP
         l_calc_tax_detail_rec.quote_shipment_id := lx_tax_shipment_tbl(i).shipment_id;

         IF (lx_tax_shipment_tbl(i).ship_to_party_site_id is not NULL
        AND lx_tax_shipment_tbl(i).ship_to_party_site_id <> FND_API.G_MISS_NUM)
        AND    (l_cust_acct is NOT NULL AND l_cust_acct <> FND_API.G_MISS_NUM)
          THEN
           ASO_PARTY_INT.GET_ACCT_SITE_USES (
  		  p_api_version     => 1.0
 		 ,P_Cust_Account_Id => l_cust_acct
 		 ,P_Party_Site_Id   =>  lx_tax_shipment_tbl(i).ship_to_party_site_id
	         ,P_Acct_Site_type  => 'SHIP_TO'
 		 ,x_return_status   => l_return_status
 		 ,x_msg_count       => l_msg_count
 		 ,x_msg_data        => l_msg_data
 		 ,x_site_use_id     => l_ship_org_id
  	   );

              IF L_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                  FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
                  FND_MESSAGE.Set_Token('COLUMN', 'INVOICE_TO_SITE_USE_ID',FALSE);
                  FND_MSG_PUB.ADD;
                END IF;
               -- raise FND_API.G_EXC_ERROR;
              END IF;

    END IF;
	ASO_TAX_INT.Calculate_Tax(
         P_Api_Version_Number => 1.0,
         p_quote_header_id    => l_Qte_Line_Rec.quote_header_id,
         P_Tax_Control_Rec    => l_tax_control_rec,
         x_tax_amount	     => x_tax_amount    ,
         x_tax_detail_tbl    => l_tax_detail_tbl,
         X_Return_Status     => x_return_status ,
         X_Msg_Count         => x_msg_count     ,
        X_Msg_Data           => x_msg_data      );

          if l_tax_detail_tbl.count > 0 then
           x_tax_detail_tbl(i) := l_tax_detail_tbl(1);
          end if;

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        FND_MESSAGE.Set_Name('ASO', 'ASO_TAX_CALCULATION');
	        FND_MSG_PUB.ADD;
	       END IF;
           IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
      END LOOP;

   END IF;

*
*/
   -- check the profile option for reservation and create reservation if needed

    IF FND_PROFILE.Value('ASO_RESERVATION_LEVEL') = 'AUTO_CART' THEN
       l_shipment_tbl := x_shipment_tbl;

     FOR i in 1..l_shipment_tbl.count LOOP

       -- shipment quantity should be changed
      IF l_shipment_tbl(i).quantity is not NULL AND
         l_shipment_tbl(i).quantity <> FND_API.G_MISS_NUM THEN

         SELECT reservation_id INTO l_shipment_tbl(i).reservation_id
         FROM ASO_SHIPMENTS
         WHERE shipment_id = l_shipment_tbl(i).shipment_id;

       ASO_RESERVATION_INT.Update_reservation(
         P_Api_Version_Number   => 1.0,
         p_line_rec             => x_qte_line_rec,
         p_shipment_rec         => l_shipment_tbl(i),
         X_Return_Status        => x_return_status,
         X_Msg_Count            => x_msg_count,
         X_Msg_Data             => x_msg_data
      );

         UPDATE ASO_SHIPMENTS
         SET reservation_id     =  l_shipment_tbl(i).reservation_id,
             reserved_quantity  =  l_shipment_tbl(i).reserved_quantity,
             last_update_date   =  sysdate,
             last_updated_by    =  fnd_global.user_id,
             last_update_login  =  fnd_global.conc_login_id
         WHERE shipment_id     = l_shipment_tbl(i).shipment_id;

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('ASO', 'ASO_CREATING_RESERVATION');
	     FND_MSG_PUB.ADD;
	    END IF;
           IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;


       END IF;  -- quantity change
      END LOOP;

    END IF;  --automatic reservation



           IF p_update_header_flag = 'Y' THEN

      -- Update Quote total info (do summation to get TOTAL_LIST_PRICE,
      -- TOTAL_ADJUSTED_AMOUNT, TOTAL_TAX, TOTAL_SHIPPING_CHARGE, SURCHARGE,
      -- TOTAL_QUOTE_PRICE, PAYMENT_AMOUNT)
      -- IF calculate_tax_flag = 'N', not summation on line level tax,
      -- just take the value of p_qte_rec.total_tax as the total_tax
      -- IF calculate_Freight_Charge = 'N', not summation on line level freight charge,
      -- just take the value of p_qte_rec.total_freight_charge
      -- how can i get the calc_tax_flag and calc_freight_charge_flag ??

       ASO_QUOTE_HEADERS_PVT.Update_Quote_Total (
	P_Qte_Header_id		=> l_Qte_Line_Rec.quote_header_id,
        P_calculate_tax         => l_control_rec.CALCULATE_TAX_FLAG,
        P_calculate_freight_charge=> l_control_rec.calculate_freight_charge_flag,
            p_control_rec		 =>  l_control_rec,
	X_Return_Status         => l_return_status,
	X_Msg_Count		=> x_msg_count,
	X_Msg_Data              => x_msg_data);

           IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
 	     FND_MESSAGE.Set_Name('ASO', 'ASO_UPDATE_QUOTE_TOTAL');
          -- FND_MESSAGE.Set_Token('LINE' , x_qte_line_rec.line_number, FALSE);
	     FND_MSG_PUB.ADD;
 	    END IF;
          END IF;

      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--        ASO_UTILITY_PVT.Print(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH, 'Private API: '|| l_api_name || 'error in updating header');
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


    END IF;

	-- Change START
	-- Release 12 TAP Changes
	-- Girish Sachdeva 8/30/2005
	-- Adding the call to insert record in the ASO_CHANGED_QUOTES

	SELECT quote_number
	INTO   l_quote_number
	FROM   aso_quote_headers_all -- bug 8968033
	WHERE  quote_header_id = l_Qte_Line_Rec.quote_header_id;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_QUOTE_LINES_PVT.update_quote_line : Calling ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES, quote number : ' || l_quote_number, 1, 'Y');
	END IF;

	-- Call to insert record in ASO_CHANGED_QUOTES
	ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES(l_quote_number);

	-- Change END


      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



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
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);


End Update_quote_line;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_qte_line_Rec      IN qte_line_Rec_Type  Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */ NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.

PROCEDURE Delete_Quote_Line(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_qte_line_Rec     IN    ASO_QUOTE_PUB.qte_line_Rec_Type,
    P_Control_REC      IN    ASO_QUOTE_PUB.Control_Rec_Type
				:= ASO_QUOTE_PUB.G_MISS_Control_Rec,
    P_Update_Header_Flag         IN   VARCHAR2   := 'Y',
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    )
IS
   Cursor C_Get_quote(c_QUOTE_LINE_ID Number) IS
    Select head.LAST_UPDATE_DATE, head.QUOTE_STATUS_ID, head.QUOTE_NUMBER,
	   head.TOTAL_ADJUSTED_PERCENT, head.quote_header_id
    From  ASO_QUOTE_HEADERS_ALL head,
          ASO_QUOTE_LINES_ALL line
    Where head.QUOTE_HEADER_ID = line.QUOTE_HEADER_ID
    And   line.QUOTE_LINE_ID = c_QUOTE_LINE_ID;

    CURSOR C_Qte_Status(c_qte_status_id NUMBER) IS
      SELECT UPDATE_ALLOWED_FLAG, AUTO_VERSION_FLAG FROM ASO_QUOTE_STATUSES_B
      WHERE quote_status_id = c_qte_status_id;

    CURSOR C_Qte_Version (X_qte_number NUMBER) IS
	SELECT max(quote_version)
	FROM ASO_QUOTE_HEADERS_ALL
	WHERE quote_number = X_qte_number;

   CURSOR C_Shipment IS
       SELECT shipment_id, reservation_id
       FROM aso_shipments
       WHERE quote_line_id = p_qte_line_rec.quote_line_id;

   CURSOR C_Inst_Details(shipment_id NUMBER) IS
       SELECT line_inst_detail_id
       FROM cs_line_inst_details
       WHERE quote_line_shipment_id = shipment_id;

-- hyang csi change 1935614
   cursor c_csi_details is
     select transaction_line_id
     from csi_t_transaction_lines
     where source_transaction_id = p_qte_line_rec.quote_line_id
       and source_transaction_table = 'ASO_QUOTE_LINES_ALL';

   CURSOR C_config IS
       SELECT qln.item_type_code, dtl.config_header_id, dtl.config_revision_num, dtl.ref_type_code
       FROM  aso_quote_lines_all qln, aso_quote_line_details dtl
       WHERE qln.quote_line_id = p_qte_line_rec.quote_line_id
       AND qln.quote_line_id = dtl.quote_line_id;

   CURSOR C_Children(l_quote_line_id NUMBER) IS
       SELECT quote_line_id
       FROM aso_quote_line_details
       WHERE ref_line_id = l_quote_line_id
       AND ref_type_code = 'TOP_MODEL';

   cursor c_pricing_line_type_indicator is
   select pricing_line_type_indicator
   from aso_quote_lines_all
   where quote_line_id = P_qte_line_Rec.quote_line_id;

   cursor c_prg_lines is
   select modifier_line_type_code
   from aso_price_adjustments
   where quote_line_id = p_qte_line_rec.quote_line_id
   and modifier_line_type_code = G_PROMO_GOODS_DISCOUNT;

   cursor c_free_lines is
   select a.quote_line_id
   from aso_price_adjustments a, aso_price_adj_relationships b
   where a.price_adjustment_id = b.rltd_price_adj_id
   and b.quote_line_id = p_qte_line_rec.quote_line_id
   and a.quote_line_id <> p_qte_line_rec.quote_line_id;

   cursor get_qte_nbr(qte_hdr_id  number) is
   SELECT quote_number
   FROM aso_quote_headers_all -- bug 8968033
   WHERE quote_header_id = qte_hdr_id;

        -- bug 14474230
   cursor c_get_modifier(qte_line_id number) is
   SELECT modifier_header_id, modifier_line_id
    FROM aso_price_adjustments
    where quote_line_id = qte_line_id
    and modifier_line_type_code=G_PROMO_GOODS_DISCOUNT
    and modifier_level_code='LINEGROUP';
-- end bug 14474230

	l_api_name                CONSTANT VARCHAR2(30) := 'Delete_quote_line';
	l_api_version_number      CONSTANT NUMBER   := 1.0;

	l_last_update_date       DATE;
	l_quote_line_detail_id   NUMBER;
     l_shipment_rec           ASO_QUOTE_PUB.shipment_rec_type;
	l_Return_Status          VARCHAR2(50);
	l_Msg_Count              NUMBER;
	l_Msg_Data               VARCHAR2(240);
	l_line_rltship_rec       ASO_quote_PUB.LINE_RLTSHIP_Rec_Type
                                := ASO_quote_PUB.G_MISS_LINE_RLTSHIP_Rec;
     l_price_adj_rltship_rec  ASO_QUOTE_PUB.PRICE_ADJ_RLTSHIP_Rec_Type ;
	l_hd_discount_percent   NUMBER;
	l_qte_status_id		NUMBER;
	l_update_allowed	VARCHAR2(1);
	l_auto_version		VARCHAR2(1);
	l_quote_number          NUMBER;
	l_old_header_rec        ASO_QUOTE_PUB.qte_header_rec_type;
	l_qte_header_rec        ASO_QUOTE_PUB.qte_header_rec_type;
	l_quote_version         NUMBER;
	x_quote_header_id       NUMBER;
     l_quote_header_id       NUMBER;
     l_line_inst_dtl_id      NUMBER;
     l_item_type             VARCHAR2(50);
     l_config_id             NUMBER;
     l_rev_num               NUMBER;
	l_ref_type_code         VARCHAR2(30);
     l_qte_line_rec          ASO_QUOTE_PUB.Qte_line_Rec_Type
                              := ASO_QUOTE_PUB.G_MISS_Qte_Line_rec;

     l_copy_quote_control_rec  aso_copy_quote_pub.copy_quote_control_rec_type;
     l_copy_quote_header_rec   aso_copy_quote_pub.copy_quote_header_rec_type;
     l_qte_nbr            number;
     l_pricing_line_type_indicator  varchar2(3);

     adj_id_tbl  number_tbl_type;
     l_modifier_line_type_code  varchar2(30);
    l_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
    l_payment_rec         aso_quote_pub.payment_rec_type;
    l_qte_number	NUMBER ;

    -- Start : Code change done for Bug 18702527
    Cursor C_ITEM_TYPE_CODE(p_quote_line_id Number) Is
    Select item_type_code
    From aso_quote_lines_all
    Where quote_line_id = p_quote_line_id;

    l_item_type_code varchar(10);
    -- End : Code change done for Bug 18702527
 BEGIN
	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 	aso_debug_pub.add('Delete_Quote_lines - Begin ', 1, 'Y');
          aso_debug_pub.add('Delete_Quote_Line: P_qte_line_Rec.quote_line_id: '||P_qte_line_Rec.quote_line_id);
	  aso_debug_pub.add('Delete_Quote_Line: P_qte_line_rec.item_type_code: '||P_qte_line_rec.item_type_code);
          aso_debug_pub.add('Delete_Quote_Line: P_Update_Header_Flag: '||P_Update_Header_Flag);
	 end if;

      -- Standard Start of API savepoint
      SAVEPOINT DELETE_quote_line_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      open  c_pricing_line_type_indicator;
      fetch c_pricing_line_type_indicator into l_pricing_line_type_indicator;
      close c_pricing_line_type_indicator;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('l_pricing_line_type_indicator: '|| l_pricing_line_type_indicator);
	 end if;

     IF (p_update_header_flag = 'Y') THEN

      Open C_Get_quote( p_qte_line_rec.QUOTE_LINE_ID);
      Fetch C_Get_quote into l_LAST_UPDATE_DATE, l_qte_status_id,
                             l_quote_number, l_hd_discount_percent,
                             l_quote_header_id;
      If ( C_Get_quote%NOTFOUND) Then
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('ASO', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'quote', FALSE);
               FND_MSG_PUB.Add;
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;   -- update header flag
      Close C_Get_quote;


      If (l_last_update_date is NULL or
          l_last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;


      -- Check Whether record has been changed by someone else
      If l_last_update_date <> p_control_rec.last_update_date Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'quote', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      Open c_qte_status (l_qte_status_id);
      Fetch C_qte_status into l_update_allowed, l_auto_version;
      Close c_qte_status;


      IF p_control_rec.auto_version_flag = FND_API.G_TRUE  AND  NVL(l_auto_version,'Y') = 'Y' THEN

	     OPEN C_Qte_Version(l_quote_number);
	     FETCH C_Qte_Version into l_quote_version;
	     l_quote_version := nvl(l_quote_version, 0) + 1;
	     CLOSE C_Qte_Version;

      ELSE

          l_auto_version := 'N';

      END IF;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Delete_Quote_Line: l_auto_version: '|| l_auto_version);
	 end if;


      IF l_auto_version = 'Y' THEN

	       l_old_header_rec := aso_utility_pvt.Query_Header_Row(p_qte_line_rec.QUOTE_HEADER_ID);

            IF l_quote_header_id IS NULL OR l_quote_header_id = FND_API.G_MISS_NUM THEN

                open c_get_quote( p_qte_line_rec.quote_line_id);
                fetch c_get_quote into l_last_update_date, l_qte_status_id,
                             l_quote_number, l_hd_discount_percent,
                             l_quote_header_id;
                close c_get_quote;


            END IF; -- l_quote_header is null

            l_copy_quote_control_rec.new_version     :=  fnd_api.g_true;
            l_copy_quote_header_rec.quote_header_id  :=  l_old_header_rec.quote_header_id;

            aso_copy_quote_pvt.copy_quote( P_Api_Version_Number      =>  1.0,
                                           P_Init_Msg_List           =>  FND_API.G_FALSE,
                                           P_Commit                  =>  FND_API.G_FALSE,
                                           P_Copy_Quote_Header_Rec   =>  l_copy_quote_header_rec,
                                           P_Copy_Quote_Control_Rec  =>  l_copy_quote_control_rec,
                                           X_Qte_Header_Id           =>  x_quote_header_id,
                                           X_Qte_Number              =>  l_qte_nbr,
                                           X_Return_Status           =>  l_return_status,
                                           X_Msg_Count               =>  x_msg_count,
                                           X_Msg_Data                =>  x_msg_data
                                          );

            if aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Delete_Quote_Line: After call to aso_copy_quote_pvt.copy_quote');
                aso_debug_pub.add('After copy_quote l_return_status:   ' || l_return_status);
                aso_debug_pub.add('After copy_quote x_quote_header_id: ' || x_quote_header_id);
                aso_debug_pub.add('After copy_quote l_qte_nbr:         ' || l_qte_nbr);
            end if;

            update aso_quote_headers_all
            set quote_version      =  l_quote_version + 1,
                max_version_flag   =  'Y',
                last_update_date   =  sysdate,
                last_updated_by    =  fnd_global.user_id,
                last_update_login  =  fnd_global.conc_login_id
            where quote_header_id = p_qte_line_rec.quote_header_id;

            update aso_quote_headers_all
            set max_version_flag   =  'N',
                quote_version      =  l_old_header_rec.quote_version,
                last_update_date   =  sysdate,
                last_updated_by    =  fnd_global.user_id,
                last_update_login  =  fnd_global.conc_login_id
            where quote_header_id = x_quote_header_id;

            update aso_quote_headers_all
            set quote_version      =  l_quote_version,
                last_update_date   =  sysdate,
                last_updated_by    =  fnd_global.user_id,
                last_update_login  =  fnd_global.conc_login_id
            where quote_header_id = p_qte_line_rec.quote_header_id;

      END IF;


    END IF;

    --Code for PRG line deletion 05/01/2003

    if nvl(l_pricing_line_type_indicator,'XXX') = 'F' then

	   begin

             --Get the free lines and update it

             select rel.rltd_price_adj_id
             BULK COLLECT INTO
             adj_id_tbl
             from aso_price_adj_relationships rel,
                  aso_price_adjustments adj
             where rel.price_adjustment_id = adj.price_adjustment_id
             and adj.modifier_line_type_code = G_PROMO_GOODS_DISCOUNT
             and rel.price_adjustment_id in (select a.price_adjustment_id
                                             from aso_price_adj_relationships a,
                                                  aso_price_adjustments b
                                             where a.rltd_price_adj_id = b.price_adjustment_id
                                             and b.quote_line_id = p_qte_line_rec.quote_line_id);

             if aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('No. of free adjustment lines selected is sql%rowcount: '||sql%rowcount);
             end if;

             if aso_debug_pub.g_debug_flag = 'Y' THEN

                 if adj_id_tbl.count > 0 then

                     for i in adj_id_tbl.FIRST..adj_id_tbl.LAST loop
                          aso_debug_pub.add('adj_id_tbl('||i||'): ' || adj_id_tbl(i));
                     end loop;

                 end if;

             end if;

             if adj_id_tbl.count > 0 then

                 FORALL i IN adj_id_tbl.FIRST..adj_id_tbl.LAST

                    UPDATE aso_price_adjustments
                    SET updated_flag = 'Y'
                    WHERE price_adjustment_id = adj_id_tbl(i)
                    AND modifier_line_type_code = G_DISCOUNT;

                    if aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('No of adjustment lines updated is sql%rowcount: '||sql%rowcount);
                    end if;

             end if;

             --Get the PRG lines and update it

     	   select a.price_adjustment_id
             BULK COLLECT INTO
             adj_id_tbl
             from aso_price_adj_relationships a, aso_price_adjustments b
             where a.rltd_price_adj_id = b.price_adjustment_id
             and b.quote_line_id = p_qte_line_rec.quote_line_id;

             if aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('No. of PRG adjustment lines selected is sql%rowcount: '||sql%rowcount);
             end if;

             if aso_debug_pub.g_debug_flag = 'Y' THEN

                 if adj_id_tbl.count > 0 then

                     for i in adj_id_tbl.FIRST..adj_id_tbl.LAST loop
                          aso_debug_pub.add('adj_id_tbl('||i||'): ' || adj_id_tbl(i));
                     end loop;

                 end if;

             end if;

             if adj_id_tbl.count> 0 then

                FORALL i IN adj_id_tbl.FIRST..adj_id_tbl.LAST

                   UPDATE aso_price_adjustments
                   SET updated_flag = 'Y'
                   WHERE price_adjustment_id = adj_id_tbl(i)
                   AND modifier_line_type_code = G_PROMO_GOODS_DISCOUNT;

                if aso_debug_pub.g_debug_flag = 'Y' THEN
                    aso_debug_pub.add('No of PRG adjustment lines updated is sql%rowcount: '||sql%rowcount);
                end if;

             end if;

             exception

                 when others then

                    if aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Delete_Quote_Line: Updation of updated_flag column in aso_price_adjustments table failed.');
                    end if;

        end;

    end if;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Delete_Quote_Line : After updation of updated_flag column in aso_price_adjustments table.', 1, 'Y');
    end if;

    --Changes for deleting PRG lines
    open  c_prg_lines;
    fetch c_prg_lines into l_modifier_line_type_code;

    if c_prg_lines%found then

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Delete_Quote_Line : Before deleting the PRG lines', 1, 'Y');
            end if;

	   -- Start : Code change done for Bug 18702527
           If p_qte_line_rec.item_type_code Is Null Or p_qte_line_rec.item_type_code = FND_API.G_MISS_CHAR Then

	      Open C_ITEM_TYPE_CODE(p_qte_line_rec.quote_line_id);
              Fetch C_ITEM_TYPE_CODE Into l_item_type_code;
              Close C_ITEM_TYPE_CODE;

           ElsIf p_qte_line_rec.item_type_code Is Not Null And p_qte_line_rec.item_type_code <> FND_API.G_MISS_CHAR Then
	       l_item_type_code :=  p_qte_line_rec.item_type_code;
           End If;

           aso_debug_pub.ADD ('Delete_Quote_Line: l_item_type_code : '||l_item_type_code , 1, 'N' );

	   If l_item_type_code <> 'CFG' Then

           -- End : Code change done for Bug 18702527

        for row in c_free_lines loop

            l_qte_line_rec               := aso_quote_pub.g_miss_qte_line_rec;
            l_qte_line_rec.quote_line_id := row.quote_line_id;

	    -- Start : Code change done for Bug 18702527
	    If aso_debug_pub.g_debug_flag = 'Y' Then
               aso_debug_pub.add('Delete_Quote_Line: l_qte_line_rec.quote_line_id : '||l_qte_line_rec.quote_line_id, 1, 'Y');
            End If;
	    -- End : Code change done for Bug 18702527

		  aso_quote_lines_pvt.delete_quote_line(
 			         P_Api_Version_Number	=> 1.0,
 			         p_control_rec		=> p_control_rec,
 			         p_update_header_flag	=> fnd_api.g_false,
 			         P_qte_Line_Rec		=> l_qte_line_rec,
 			         X_Return_Status 	=> x_return_status,
 			         X_Msg_Count		=> x_msg_count,
 			         X_Msg_Data		     => x_msg_data);

            if x_return_status <> fnd_api.g_ret_sts_success then
                 raise fnd_api.g_exc_error;
            end if;

            end loop;

	   End If;  -- Code change done for Bug 18702527
    end if;

    close c_prg_lines;

    -- Invoke table handler(ASO_QUOTE_HEADERS_PKG.Delete_Row)
    -- these tables may or may not have any rows
    -- ideally exception should be handled by the table handler


    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('before deleting the quote line attributes.', 1, 'Y');
    end if;

-- delete quote line attributes
    BEGIN
     ASO_QUOTE_LINE_ATTRIBS_EXT_PKG.Delete_Row(
         p_QUOTE_LINE_ID => p_qte_line_rec.quote_line_id);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       null;
    END;

-- delete price attributes
    BEGIN
     ASO_PRICE_ATTRIBUTES_PKG.Delete_Row(
         p_QUOTE_LINE_ID => p_qte_line_rec.quote_line_id);
      EXCEPTION
    WHEN NO_DATA_FOUND THEN
       null;
    END;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('before deleting the quote line relationships.', 1, 'Y');
    end if;

-- delete line relationships

  l_line_rltship_rec.quote_line_id :=  p_qte_line_rec.quote_line_id;
    ASO_LINE_RLTSHIP_PVT.Delete_line_rltship(
      P_Api_Version_Number    => 1.0,
      p_control_rec          => p_control_rec,
      P_LINE_RLTSHIP_Rec      => l_line_rltship_rec,
      X_Return_Status         => x_return_status,
      X_Msg_Count             => x_msg_count,
      X_Msg_Data              => x_msg_data);

     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
             FND_MESSAGE.Set_Token('OBJECT','LINE_RLTSHIP',FALSE);
	     FND_MSG_PUB.ADD;
	    END IF;
            RAISE FND_API.G_EXC_ERROR;
     END IF;


-- delete price adjustment relationships

  l_price_adj_rltship_rec.quote_line_id := p_qte_line_rec.quote_line_id;
     ASO_PRICE_ADJ_RLTSHIP_PVT.Delete_Price_Adj_Rltship(
         P_Api_Version_Number    => 1.0,
         P_PRICE_ADJ_RLTSHIP_Rec => l_price_adj_rltship_rec,
         X_Return_Status         => x_return_status,
         X_Msg_Count             => x_msg_count,
         X_Msg_Data              => x_msg_data);

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
           FND_MESSAGE.Set_Token('OBJECT','PRICE_ADJ_RLTSHIP',FALSE);
	     FND_MSG_PUB.ADD;
	    END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('before deleting the quote line price adjustments.', 1, 'Y');
    end if;

            -- bug 14474230
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('rassharm before deleting the related quote line price adjustments quote_line_id'||p_qte_line_rec.quote_line_id, 1, 'Y');
    end if;
    for row in c_get_modifier(p_qte_line_rec.quote_line_id) loop
        for c2 in (select price_adjustment_id
              FROM aso_price_adjustments
              where quote_header_id=p_qte_line_rec.quote_header_id
              and quote_line_id <> p_qte_line_rec.quote_line_id
              and modifier_header_id=row.modifier_header_id
              and modifier_line_id=row.modifier_line_id
              and modifier_line_type_code=G_PROMO_GOODS_DISCOUNT
              and modifier_level_code='LINEGROUP'
              ) LOOP
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('before deleting the related quote line price adjustments.'||c2.price_adjustment_id, 1, 'Y');
              end if;
	      BEGIN
              ASO_PRICE_ADJUSTMENTS_PKG.Delete_Row(p_PRICE_ADJ_ID => c2.price_adjustment_id);
	       EXCEPTION
			WHEN NO_DATA_FOUND THEN
			null;
		END;
              end loop;

  end loop;
  --14474230

-- delete price adjustments
-- this should once again delete price adj relationships
    BEGIN
       ASO_PRICE_ADJUSTMENTS_PKG.Delete_Row(
         p_LINE_ID => p_qte_line_rec.quote_line_id,
         p_TYPE_CODE => 'QUOTE_LINE');
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       null;
    END;

-- delete payments
    BEGIN

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Delete_Quote_Line: Before  call to delete_payment_row ', 1, 'Y');
     END IF;

     l_payment_tbl := aso_utility_pvt.Query_Payment_Rows(p_qte_line_rec.quote_header_id,p_qte_line_rec.quote_line_id);

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Delete_Quote_Line: l_payment_tbl.count:  '|| l_payment_tbl.count, 1, 'Y');
     END IF;

       if l_payment_tbl.count > 0 then

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Delete_Quote_Line: Inside if for payment tbl count > 0 ', 1, 'Y');
              END IF;


          if l_payment_tbl(1).trxn_extension_id is not null then

              l_payment_rec := l_payment_tbl(1);

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Delete_Quote_Line: Before call to delete_payment_row', 1, 'Y');
              END IF;

              aso_payment_int.delete_payment_row(p_payment_rec   => l_payment_rec  ,
                                                 x_return_status => x_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data);

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Delete_Quote_Line: After call to delete_payment_row: x_return_status: '||x_return_status, 1, 'Y');
              END IF;
            if x_return_status <> fnd_api.g_ret_sts_success then
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            end if;

          else

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Delete_Quote_Line: Before calling table handler to delete payment row', 1, 'Y');
              END IF;

              aso_payments_pkg.Delete_Row(p_payment_id => l_payment_tbl(1).payment_id);
           end if;

       end if;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Delete_Quote_Line: After deleting the payment row', 1, 'Y');
     END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       null;
    END;

-- delete freight
    BEGIN
       ASO_FREIGHT_CHARGES_PKG.delete_Row(
            p_QUOTE_LINE_ID  => p_qte_line_rec.quote_line_id);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       null;
    END;

-- delete tax details
    BEGIN
       ASO_TAX_DETAILS_PKG.Delete_Row(
            p_QUOTE_LINE_ID => p_qte_line_rec.quote_line_id);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
       null;
    END;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Delete_Quote_Line: Before deleting the sales credits', 1, 'Y');
     END IF;

-- delete salescredits
     ASO_SALES_CREDITS_PKG.Delete_row(
             p_QUOTE_LINE_ID => p_qte_line_rec.quote_line_id);

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Delete_Quote_Line: Before deleting the quote parties', 1, 'Y');
     END IF;

-- delete quote parties
     ASO_QUOTE_PARTIES_PKG.Delete_row(
             p_QUOTE_LINE_ID => p_qte_line_rec.quote_line_id);

-- delete configurations - supported only at model levels
   OPEN C_config;
   FETCH C_config into l_item_type, l_config_id, l_rev_num, l_ref_type_code;
   IF (C_config%NOTFOUND) THEN
      null;
   END IF;
   CLOSE C_config;

   IF l_item_type = 'MDL' THEN

	IF l_config_id is not NULL THEN

       ASO_CFG_INT.DELETE_CONFIGURATION(
 		P_API_VERSION_NUMBER	=> 1.0,
 		P_INIT_MSG_LIST		=> FND_API.G_FALSE,
 		P_CONFIG_HDR_ID		=> l_config_id,
 		P_CONFIG_REV_NBR	=> l_rev_num,
 		X_RETURN_STATUS		=> x_return_status,
 		X_MSG_COUNT		=> x_msg_count,
 		X_MSG_DATA		=> x_msg_data);

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	         FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
              FND_MESSAGE.Set_Token('OBJECT', 'CONFIGURATION', FALSE);
	         FND_MSG_PUB.ADD;
	      END IF;
              RAISE FND_API.G_EXC_ERROR;
       END IF;

     ELSIF l_ref_type_code = 'TOP_MODEL' THEN

	    FOR Cur_Children IN C_Children(p_qte_line_rec.quote_line_id) LOOP

            l_qte_line_rec.quote_line_id := Cur_Children.quote_line_id;

		  ASO_QUOTE_LINES_PVT.Delete_Quote_Line(
 			         P_Api_Version_Number	=> 1.0,
 			         p_control_rec		=> p_control_rec,
 			         p_update_header_flag	=> p_update_header_flag,
 			         P_qte_Line_Rec		=> l_qte_line_rec,
 			         X_Return_Status 	=> x_return_status,
 			         X_Msg_Count		=> x_msg_count,
 			         X_Msg_Data		     => x_msg_data);
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;

         END LOOP;

    END IF;  -- config


   END IF;  -- 'MDL'

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Delete_Quote_Line: Before deleting the quote line details', 1, 'Y');
        aso_debug_pub.add('p_qte_line_rec.quote_line_id: '|| p_qte_line_rec.quote_line_id);
     END IF;

-- delete quote line details
    BEGIN
     ASO_QUOTE_LINE_DETAILS_PKG.Delete_Row(
         p_QUOTE_LINE_ID => p_qte_line_rec.quote_line_id);

    EXCEPTION

       WHEN NO_DATA_FOUND THEN
          null;
    END;


-- shipment should exist
    --  OPEN C_Shipment;
      FOR i in C_Shipment LOOP

        l_shipment_rec.shipment_id := i.shipment_id;
        l_shipment_rec.reservation_id := i.reservation_id;

-- hyang csi change 1935614
        if not (csi_utility_grp.ib_active()) then

          FOR j in C_inst_details(l_shipment_rec.shipment_id) LOOP

            l_line_inst_dtl_id := j.line_inst_detail_id;

            null;

          END LOOP;

        else

        -- new ib module
          for j in C_csi_details LOOP

            l_line_inst_dtl_id := j.transaction_line_id;

            ASO_INSTBASE_INT.Delete_Installation_Detail(
              p_api_version_number  => 1.0,
                  p_init_msg_list       => FND_API.G_FALSE,
                  p_commit              => FND_API.G_FALSE,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data,
                  p_line_inst_dtl_id    => l_line_inst_dtl_id
            );

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
                FND_MESSAGE.Set_Token('OBJECT', 'INSTALLATION DETAILS');
                    FND_MSG_PUB.ADD;
                  END IF;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END LOOP;
        END IF;


        ASO_SHIPMENT_PVT.Delete_shipment(
          P_Api_Version_Number    => 1.0,
          P_SHIPMENT_Rec          => l_shipment_rec,
          X_Return_Status         => x_return_status,
          X_Msg_Count             => x_msg_count,
          X_Msg_Data              => x_msg_data);

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		     FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
               FND_MESSAGE.Set_Token('OBJECT', 'LINE_SHIPMENTS', FALSE);
	    		FND_MSG_PUB.ADD;
	      END IF;
           RAISE FND_API.G_EXC_ERROR;
         END IF;

      END LOOP;


     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Delete_Quote_Line: Before deleting the quote line', 1, 'Y');
        aso_debug_pub.add('p_qte_line_rec.quote_line_id: '|| p_qte_line_rec.quote_line_id);
     END IF;

     BEGIN
      ASO_QUOTE_LINES_PKG.Delete_Row( p_quote_line_id  => p_qte_line_rec.quote_line_id);
     EXCEPTION
	WHEN no_data_found then
	 null;
	END;


     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Delete_Quote_Line: After deleting the quote line', 1, 'Y');
     END IF;

      IF p_update_header_flag = 'Y' THEN

      -- Update Quote total info (do summation to get TOTAL_LIST_PRICE,
      -- TOTAL_ADJUSTED_AMOUNT, TOTAL_TAX, TOTAL_SHIPPING_CHARGE, SURCHARGE,
      -- TOTAL_QUOTE_PRICE, PAYMENT_AMOUNT)
      -- IF calculate_tax_flag = 'N', not summation on line level tax,
      -- just take the value of p_qte_rec.total_tax as the total_tax
      -- IF calculate_Freight_Charge = 'N', not summation on line level freight charge,
      -- just take the value of p_qte_rec.total_freight_charge
      -- how can i get the calc_tax_flag and calc_freight_charge_flag ??


      ASO_QUOTE_HEADERS_PVT.Update_Quote_Total(
                     P_Qte_Header_id             => l_quote_header_id,
                     P_calculate_tax             => p_control_rec.CALCULATE_TAX_FLAG,
                     P_calculate_freight_charge  => p_control_rec.calculate_freight_charge_flag,
                     p_control_rec               => p_control_rec,
                     X_Return_Status             => l_return_status,
                     X_Msg_Count                 => x_msg_count,
                     X_Msg_Data                  => x_msg_data);

      IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN

          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
 	         FND_MESSAGE.Set_Name('ASO', 'ASO_UPDATE_QUOTE_TOTAL');
	         FND_MSG_PUB.ADD;
 	     END IF;

      END IF;


      IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


    END IF;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Delete_Quote_Line: Before call to Delete_OTA_Line.');
		aso_debug_pub.add('p_qte_line_rec.quote_line_id: '|| p_qte_line_rec.quote_line_id);
	end if;

     ASO_EDUCATION_INT.Delete_OTA_Line(
          P_Init_Msg_List     => FND_API.G_FALSE,
          P_Commit            => FND_API.G_FALSE,
          P_Qte_Line_Id       => p_qte_line_rec.quote_line_id,
          X_Return_Status     => l_return_status,
          X_Msg_Count         => x_msg_count,
          X_Msg_Data          => x_msg_data);

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Delete_Quote_Line: After call to Delete_OTA_Line.');
          aso_debug_pub.add('Delete_Quote_Line: l_return_status: '|| l_return_status);
     end if;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

        -- Change START
	-- Release 12 TAP Changes
	-- Girish Sachdeva 8/30/2005
	-- Adding the call to insert record in the ASO_CHANGED_QUOTES

	IF ((p_qte_line_rec.quote_header_id is not null) and (p_qte_line_rec.quote_header_id <> FND_API.G_MISS_NUM)) THEN

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('ASO_QUOTE_LINES_PVT.delete_quote_line : Before calling ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES, Quote Header ID :' || p_qte_line_rec.quote_header_id, 1, 'Y');
		END IF;

          OPEN get_qte_nbr(p_qte_line_rec.quote_header_id);
		FETCH get_qte_nbr INTO l_qte_number;
		CLOSE get_qte_nbr;

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('ASO_QUOTE_LINES_PVT.delete_quote_line : Before calling ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES, quote number : ' || l_qte_number, 1, 'Y');
		END IF;


		-- Call to insert record in ASO_CHANGED_QUOTES
		ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES(l_qte_number);

	END IF ;

	-- Change END

     --
     -- End of API body
     --

     -- Standard check for p_commit
     IF FND_API.to_Boolean( p_commit ) THEN
          COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                 p_data  => x_msg_data );


     EXCEPTION

	  WHEN FND_API.G_EXC_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	      ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

END;




--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_Quote_Lines
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_quote_id                IN   NUMBER     Required
--       p_rec_requested           IN   NUMBER     Optional  Default = 30
--       p_start_rec_ptr           IN   NUMBER     Optional  Default = 1
--
--       Return Total Records Count Flag. This flag controls whether the total record count
--       and total record amount is returned.
--
--       p_return_tot_count        IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--   Hint: User defined record type
--       p_order_by_tbl            IN   AS_UTILITY_PUB.UTIL_ORDER_BY_TBL_TYPE;
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */ NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--       X_qte_line_Tbl     OUT NOCOPY /* file.sql.39 change */  qte_line_Tbl_Type
--       X_Payment_Tbl       OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type
--       X_Price_Adj_Tbl     OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type
--       X_Qte_Line_Dtl_Tbl  OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type
--       X_Shipment_Tbl      OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type
--       X_Tax_Details_Tbl   OUT NOCOPY /* file.sql.39 change */  Tax_Details_Tbl_Type
--       X_Freight_Charges_Tbl OUT NOCOPY /* file.sql.39 change */ Freight_Charges_Tbl_Type
--       X_Line_Relationship_Tbl OUT NOCOPY /* file.sql.39 change */ Line_Relationship_Tbl_Type
--       X_Related_Object_Tbl OUT NOCOPY /* file.sql.39 change */   Related_Object_Tbl_Type
--       X_Price_Attributes_Tbl   OUT NOCOPY /* file.sql.39 change */    Price_Attributes_Tbl_Type
--       X_Price_Adj_Relationship_Tbl OUT NOCOPY /* file.sql.39 change */ Price_Adj_relationship_Tbl_Type
--       x_returned_rec_count      OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_next_rec_ptr            OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_tot_rec_count           OUT NOCOPY /* file.sql.39 change */   NUMBER
--  other optional OUT NOCOPY /* file.sql.39 change */ parameters
--       x_tot_rec_amount          OUT NOCOPY /* file.sql.39 change */   NUMBER
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Get_Quote_Line(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
     p_order_by_rec               IN   ASO_QUOTE_PUB.qte_line_sort_rec_type,
    x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_returned_rec_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_next_rec_ptr               OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_tot_rec_count              OUT NOCOPY /* file.sql.39 change */  NUMBER,
    P_Qte_Line_Rec     		 IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type  := ASO_QUOTE_PUB.G_MISS_qte_line_REC,
    P_Control_REC      		 IN   ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_MISS_Control_Rec,
    X_Qte_Line_Rec     OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    X_Payment_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Payment_Tbl_Type,
    X_Price_Adj_Tbl    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
    X_Qte_Line_Dtl_rec OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Line_Dtl_rec_Type,
    X_Shipment_Tbl     OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Shipment_Tbl_Type,
    X_Tax_Detail_Tbl   OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type ,
    X_Line_Rltship_Tbl      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Rltship_Tbl_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type ,
    X_Price_Adj_rltship_Tbl OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
    X_Line_Attribs_Ext_Tbl       OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_type
    )
IS
BEGIN
null;
END;

Procedure service_item_qty_update
(p_qte_line_rec  IN ASO_QUOTE_PUB.QTE_LINE_REC_TYPE,
 p_service_item_flag  IN VARCHAR2,
 x_return_status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
 )IS

CURSOR C_ord_qty(ord_line_id NUMBER) IS
SELECT  ordered_quantity
FROM  oe_order_lines_All
WHERE  line_id = ord_line_id;

CURSOR C_cs_qty(p_instance_id NUMBER) IS
SELECT  quantity
FROM CSI_ITEM_INSTANCES
WHERE  instance_id = p_instance_id;

CURSOR C_quantity(p_quote_line_id NUMBER) IS
SELECT  quantity
FROM  aso_quote_lines_all
WHERE  quote_line_id = p_quote_line_id;

l_serviceable_product_flag VARCHAR2(1);
l_qte_line_rec ASO_QUOTE_PUB.QTE_LINE_REC_TYPE;
l_org_id NUMBER;
l_inventory_item_id NUMBER;
l_organization_id NUMBER;
l_qte_line_detail_tbl ASO_QUOTE_PUB.QTE_LINE_DTL_TBL_TYPE;
l_quantity NUMBER;
l_update_flag VARCHAR2(1) := FND_API.G_FALSE;

Begin
IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('Procedure Service_item_qty_update Starts.', 1, 'Y');
end if;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_service_item_flag = FND_API.G_FALSE THEN
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
    		aso_debug_pub.add('Service_item_qty_update: Inside IF condition p_service_item_flag = FND_API.G_FALSE', 1, 'N');
	end if;

    l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(p_qte_line_rec.quote_line_id);
    begin
        UPDATE aso_quote_lines_all
        set quantity           =  l_qte_line_rec.quantity,
            last_update_date   =  sysdate,
            last_updated_by    =  fnd_global.user_id,
            last_update_login  =  fnd_global.conc_login_id
        where quote_line_id IN
        ( select quote_line_id from aso_quote_line_details
          where service_ref_type_code = 'QUOTE' and service_ref_line_id = l_qte_line_rec.quote_line_id );

        EXCEPTION
            WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
			IF aso_debug_pub.g_debug_flag = 'Y' THEN
             		aso_debug_pub.add('Service_item_qty_update:Exception1',1,'N');
			end if;
    end;
  ELSE
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
    		aso_debug_pub.add('Service_item_qty_update:ELSE condition of p_service_item_flag = FND_API.G_FALSE', 1, 'N');
	end if;
    l_qte_line_detail_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(p_qte_line_rec.quote_line_id);

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
    		aso_debug_pub.add('Service_item_qty_update: ASO_UTILITY_PVT.Query_Line_Dtl_Rows', 1, 'N');
	end if;

    FOR i IN 1..l_qte_line_detail_tbl.count LOOP
      IF l_qte_line_detail_tbl(i).service_ref_type_code = 'QUOTE' THEN
         OPEN C_quantity(l_qte_line_detail_tbl(i).service_ref_line_id);
         FETCH C_quantity INTO l_quantity;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Service_item_qty_update: Cursor C_quantity: l_quantity: '||l_quantity, 1, 'N');
	end if;
         IF C_quantity%NOTFOUND THEN
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
             	aso_debug_pub.add('Service_item_qty_update: Inside cursor C_quantity%NOTFOUND ', 1, 'N');
		end if;
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  		      FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SERVICE_REF_LINE');
  		      FND_MESSAGE.Set_Token('CODE', 'QUOTE', FALSE);
                FND_MESSAGE.Set_Token('VALUE', l_qte_line_detail_tbl(i).service_ref_line_id, FALSE);
  		      FND_MSG_PUB.ADD;
  	        END IF;
	    ELSE
		   l_update_flag := FND_API.G_TRUE;
   	    END IF;
         CLOSE C_quantity;
      ELSIF l_qte_line_detail_tbl(i).service_ref_type_code = 'ORDER' THEN
         OPEN C_ord_qty(l_qte_line_detail_tbl(i).service_ref_line_id);
         FETCH C_ord_qty INTO l_quantity;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Service_item_qty_update: Cursor C_ord_qty: l_quantity: '||l_quantity, 1, 'N');
	end if;
         IF C_ord_qty%NOTFOUND THEN
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Service_item_qty_update: Inside cursor C_ord_qty%NOTFOUND condition.', 1, 'N');
	end if;
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  		      FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SERVICE_REF_LINE');
  		      FND_MESSAGE.Set_Token('CODE', 'ORDER', FALSE);
                FND_MESSAGE.Set_Token('VALUE', l_qte_line_detail_tbl(i).service_ref_line_id, FALSE);
  		      FND_MSG_PUB.ADD;
  	       END IF;
         ELSE
			 l_update_flag := FND_API.G_TRUE;
         END IF;
         CLOSE C_ord_qty;
      ELSIF l_qte_line_detail_tbl(i).service_ref_type_code = 'CUSTOMER_PRODUCT' THEN
         OPEN C_cs_qty(l_qte_line_detail_tbl(i).service_ref_line_id);
         FETCH C_cs_qty INTO l_quantity;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Service_item_qty_update: Cursor C_cs_qty: l_quantity: '||l_quantity, 1, 'N');
	end if;

         IF C_cs_qty%NOTFOUND THEN
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
             aso_debug_pub.add('Service_item_qty_update: Inside cursor C_cs_qty%NOTFOUND condition. ', 1, 'N');
	end if;
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  		      FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SERVICE_REF_LINE');
  		      FND_MESSAGE.Set_Token('CODE', 'CUSTOMER_PRODUCT', FALSE);
                FND_MESSAGE.Set_Token('VALUE', l_qte_line_detail_tbl(i).service_ref_line_id, FALSE);
  		      FND_MSG_PUB.ADD;
  	        END IF;
         ELSE
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
             	aso_debug_pub.add('Service_item_qty_update: cursor C_cs_qty%FOUND ', 1, 'N ');
		end if;
	        l_update_flag := FND_API.G_TRUE;
         END IF;
         CLOSE C_cs_qty;
      /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
      ELSIF l_qte_line_detail_tbl(i).service_ref_type_code = 'PRODUCT_CATALOG' THEN
        OPEN C_quantity(l_qte_line_detail_tbl(i).quote_line_id);
        FETCH C_quantity INTO l_quantity; --using the line qunatity
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('PRODUCT CATALOG Service_item_qty_update: Cursor C_quantity: l_quantity: '||l_quantity, 1, 'N');
	end if;
         IF C_quantity%NOTFOUND THEN
	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
             	aso_debug_pub.add('Service_item_qty_update: Inside cursor C_quantity%NOTFOUND ', 1, 'N');
	   end if;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
  		      FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_SERVICE_REF_LINE');
  		      FND_MESSAGE.Set_Token('CODE', 'PRODUCT_CATALOG', FALSE);
		      FND_MESSAGE.Set_Token('VALUE', l_qte_line_detail_tbl(i).service_ref_line_id, FALSE);
  		      FND_MSG_PUB.ADD;
  	    END IF;
	   ELSE
		   l_update_flag := FND_API.G_TRUE;
   	    END IF;
         CLOSE C_quantity;
      /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
      END IF; -- service_ref_type_code


      IF x_return_status <> FND_API.G_RET_STS_ERROR  AND l_update_flag = FND_API.G_TRUE THEN

         Begin

           UPDATE aso_quote_lines_all
           set quantity           =  l_quantity,
               last_update_date   =  sysdate,
               last_updated_by    =  fnd_global.user_id,
               last_update_login  =  fnd_global.conc_login_id
           where quote_line_id =  p_qte_line_rec.quote_line_id;

           EXCEPTION
              WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_ERROR;

              if aso_debug_pub.g_debug_flag = 'Y' THEN
              	   aso_debug_pub.add('Service_item_qty_update:Exception raised when others', 1, 'N');
              end if;

         End;

      END IF;

	 l_update_flag := FND_API.G_FALSE;

    END LOOP;

  END IF;
End service_item_qty_update;

END ASO_QUOTE_LINES_PVT;

/
