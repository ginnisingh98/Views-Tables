--------------------------------------------------------
--  DDL for Package Body ASO_MAP_QUOTE_ORDER_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_MAP_QUOTE_ORDER_INT" as
/* $Header: asoimqob.pls 120.29.12010000.40 2016/08/19 06:01:20 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_MAP_QUOTE_ORDER_INT
-- Purpose          :
-- History          :
--				10/18/2002 hyang - 2633507, performance fix
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_MAP_QUOTE_ORDER_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoimqob.pls';


PROCEDURE Map_Quote_to_order(
    P_Operation        IN    VARCHAR2,
    P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
                       := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
    P_Header_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Header_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Header_Price_Attributes_Tbl  IN  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Header_Price_Adj_rltship_Tbl  IN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Header_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
                       := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Header_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Header_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Header_FREIGHT_CHARGE_Tbl  IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_header_sales_credit_TBL   IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
                        := ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Qte_Line_Tbl     IN    ASO_QUOTE_PUB.Qte_Line_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_qte_line_TBL,
    P_Qte_Line_Dtl_TBL IN    ASO_QUOTE_PUB.Qte_Line_Dtl_TBL_Type
                       := ASO_QUOTE_PUB.G_MISS_qte_line_dtl_TBL,
    P_Line_Payment_Tbl      IN    ASO_QUOTE_PUB.Payment_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Payment_TBL,
    P_Line_Price_Adj_Tbl    IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Price_Adj_TBL,
    P_Line_Price_Attributes_Tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_Price_attributes_TBL,
    P_Line_Price_Adj_rltship_Tbl IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_price_adj_rltship_TBL,
    P_Line_Price_Adj_Attr_Tbl    IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
                       := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Line_Shipment_Tbl     IN    ASO_QUOTE_PUB.Shipment_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_shipment_TBL,
    P_Line_TAX_DETAIL_Tbl  IN    ASO_QUOTE_PUB.TAX_DETAIL_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_TBL,
    P_Line_FREIGHT_CHARGE_Tbl    IN   ASO_QUOTE_PUB.FREIGHT_CHARGE_Tbl_Type
                        := ASO_QUOTE_PUB.G_MISS_FREIGHT_CHARGE_Tbl,
    P_Line_Rltship_Tbl      IN   ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
                       := ASO_QUOTE_PUB.G_MISS_line_rltship_TBL,
    P_Line_sales_credit_TBL      IN   ASO_QUOTE_PUB.Sales_credit_tbl_type
                        := ASO_QUOTE_PUB.G_MISS_sales_credit_TBL,
    P_Lot_Serial_Tbl        IN   ASO_QUOTE_PUB.Lot_Serial_Tbl_Type
                             := ASO_QUOTE_PUB.G_MISS_Lot_Serial_Tbl,
    P_Calculate_Price_Flag  IN   VARCHAR2 := FND_API.G_FALSE
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Payment_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Lot_Serial_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Line_Payment_Tbl_Type
)
IS

   CURSOR c_functional_currency (X_set_of_books_id NUMBER) IS
      SELECT currency_code
      FROM gl_sets_of_books
      WHERE set_of_books_id = X_set_of_books_id;

     name1 varchar2(50);

/*
 * 2633507 - hyang: use OE_ORDER_SOURCES instead of aso_i_order_sources_v
 */

   CURSOR C_order_source(quote_source_code VARCHAR2) IS
      SELECT order_source_id
      FROM  OE_ORDER_SOURCES
      WHERE name = quote_source_code;

-- Change START
-- Release 12 MOAC Changes : Bug 4500739
-- Changes Done by : Girish
-- Comments : Changed the reference from ASO_I_OE_ORDER_HEADERS_V to OE_ORDER_HEADERS_V

   CURSOR get_cust_account_id(order_id NUMBER) IS
     select sold_to_org_id from oe_order_headers_v
           where header_id = order_id;


-- Change END

   CURSOR get_cust_acct_site_id(l_site_use_id number) IS
     select cust_acct_site_id from hz_cust_site_uses
     where site_use_id = l_site_use_id;

   CURSOR C_get_quote_number(l_qte_hdr_id NUMBER) IS
     SELECT quote_number, quote_version
     FROM aso_quote_headers_all
     WHERE quote_header_id = l_qte_hdr_id ;

  CURSOR scheduling_level_cur(p_type_id number) IS
      SELECT nvl(scheduling_level_code,' ')
      FROM OE_TRANSACTION_TYPES_ALL
      WHERE transaction_type_id = p_type_id;

    l_order_scheduling_level VARCHAR2(30) := ' ' ;
    l_line_scheduling_level VARCHAR2(30);

  -- declaration for line and header level record types

    l_api_version_number          CONSTANT NUMBER := 1.0;
    l_api_name                    CONSTANT VARCHAR2(30):= 'MAP_QUOTE_TO_Order';
    l_control_rec                 OE_GLOBALS.Control_Rec_Type;
    l_return_status               VARCHAR2(1);
    l_header_rec                  OE_Order_PUB.Header_Rec_Type;
    l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
    l_Header_price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type ;
    l_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
    l_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
    l_Header_Scredit_tbl          OE_Order_PUB.Header_Scredit_Tbl_Type;
    l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
    l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
    l_Line_price_Att_tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type ;
    l_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
    l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
    l_Line_Scredit_tbl            OE_Order_PUB.Line_Scredit_Tbl_Type;
    l_Lot_Serial_tbl              OE_Order_PUB.Lot_Serial_Tbl_Type;
    l_action_request_tbl          OE_Order_PUB.Request_Tbl_Type;


-- declaration for line and header level value record types
    l_return_values               varchar2(50);
    l_header_val_rec	          OE_Order_PUB.Header_Val_Rec_Type;
    l_header_adj_val_tbl          OE_Order_PUB.Header_Adj_Val_Tbl_Type;
    l_header_scredit_val_tbl      OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
    l_line_val_tbl		  OE_Order_PUB.Line_Val_Tbl_Type;
    l_line_adj_val_tbl            OE_Order_PUB.Line_Adj_Val_Tbl_Type;
   --Line Payments change
    l_Line_Payment_tbl            OE_Order_PUB.Line_Payment_Tbl_Type;
    l_final_Payment_tbl           OE_Order_PUB.Line_Payment_Tbl_Type;
    l_line_scredit_val_tbl        OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
    l_lot_serial_val_tbl          OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
    l_msg_count                   number;
    l_msg_data                    varchar2(2000);
    l_invoice_cust_account_id  number;
    l_ship_cust_account_id number;
    l_end_cust_account_id number;
    l_invoice_cust_account_site number;
    l_ship_cust_account_site number;
    l_quote_number                NUMBER;
    l_version_number              NUMBER;

-- other variable and count declarations

	found         VARCHAR2(1) := FND_API.G_FALSE;
	found_service VARCHAR2(1) := FND_API.G_FALSE;
     found_tax     VARCHAR2(1) := FND_API.G_FALSE;
	i  	      NUMBER := 1;
	j             NUMBER := 1;
	k             NUMBER := 1;
	l             NUMBER := 1;
	option_item   NUMBER;
	parent        NUMBER;
	count1        NUMBER;
	count2        NUMBER;
	l_sort_order  VARCHAR2(240);
	l_component_sequence_id NUMBER;
     l_org_id                NUMBER;
     l_cust_account_id         NUMBER;
     l_employee_person_id    NUMBER;
     l_org_party_id          NUMBER;
     l_header_party_id       NUMBER;
     l_quote_source          VARCHAR2(240);

-- currency conversion

    l_set_of_books_id	NUMBER
                    := oe_profile.value('OE_SET_OF_BOOKS_ID', p_qte_rec.org_id);
                  --:= to_number(FND_PROFILE.value('OE_SET_OF_BOOKS_ID'));
    l_conversion_type	VARCHAR2(30)
                  := FND_PROFILE.Value('ASO_QUOTE_CONVERSION_TYPE');
    l_conversion_rate	NUMBER;

    l_om_defaulting_prof  VARCHAR2(2)
                  := NVL(FND_PROFILE.Value('ASO_OM_DEFAULTING'), 'N');
    l_validate_salesrep_prof  VARCHAR2(2)
                  := FND_PROFILE.VALUE('ASO_VALIDATE_SALESREP');
    l_ret_reason_code_prof VARCHAR2(200)
                := FND_PROFILE.value('ASO_RET_REASON_CODE');

    -- Change START
    -- Release 12 MOAC Changes : Bug 4500739
    -- Changes Done by : Girish
    -- Comments : Using HR EIT in place of org striped profile

    -- l_default_person_id_prof VARCHAR2(300) := FND_PROFILE.Value('ASO_DEFAULT_PERSON_ID');
    l_default_person_id_prof VARCHAR2(300) := ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_SALESREP);

    -- Change END


    l_reservation_lvl_prof       VARCHAR2(80)
                := FND_PROFILE.Value('ASO_RESERVATION_LEVEL');

    l_sysdate           DATE := sysdate;
    l_functional_currency	VARCHAR2(15);

    l_g_user_id number :=  fnd_global.user_id;
    l_g_login_id number := fnd_global.conc_login_id;
    l_org_contact_party_id   NUMBER;
    l_invoice_contact_party_id NUMBER;
    l_ship_contact_party_id  NUMBER;
    l_org_contact            NUMBER;

    l_hd_inv_cust_acct_site  NUMBER;
    l_hd_shp_cust_acct_site  NUMBER;
    l_hd_end_cust_acct_site  NUMBER;
    l_ln_inv_cust_acct_site  NUMBER;
    l_ln_shp_cust_acct_site  NUMBER;
    l_ln_end_cust_acct_site  NUMBER;

     -- bug 16338603
    l_price_req_code         varchar2(240);
    limit_exist             number;

    l_Line_Price_Adj_rltship_Tbl   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

    l_Header_Payment_Tbl               OE_ORDER_PUB.Header_Payment_Tbl_Type;

    pay_count                      NUMBER := 1;

    CURSOR salesrep( p_resource_id NUMBER) IS
      select salesrep_id
      /* from jtf_rs_srp_vl */ --Commented Code Yogeshwar (MOAC)
      from jtf_rs_salesreps_mo_v --New Code Yogeshwar (MOAC)
      where resource_id = p_resource_id ;
      --Commented code Start Yogeshwar (MOAC)
      /*
	 and NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
	 NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(
	 USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
      */
     --Commented Code End Yogeshwar (MOAC)

   CURSOR C_Get_Srep_From_Snumber( lc_srep_num VARCHAR2) IS
    SELECT Salesrep_Id
    FROM JTF_RS_SALESREPS_MO_V
    WHERE Salesrep_Number = lc_srep_num
    AND NVL(status,'A') = 'A'
    AND nvl(trunc(start_date_active), trunc(sysdate)) <= trunc(sysdate)
    AND nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate) ;

    l_ln_total_tax_amount NUMBER := 0;
    l_line_adj_tbl_count  NUMBER := 0;

    CURSOR C_GET_TAX_REASONCODE(l_header_id NUMBER) IS -- cursor made for 6781917
    SELECT TAX_EXEMPT_REASON_CODE
    FROM aso_tax_details
    WHERE quote_header_id = l_header_id
    AND quote_line_id IS NULL;

    /* Added for ER 12879412 */

l_PROD_FISC_CLASSIFICATION   VARCHAR2(240) :=NULL;
l_TRX_BUSINESS_CATEGORY      VARCHAR2(240) :=NULL;

/* End for ER 12879412 */

-- bug 14162429
l_MDL_PROD_FISC_CLASS   VARCHAR2(240) :=NULL;
l_MDL_TRX_BUSI_CATE      VARCHAR2(240) :=NULL;

BEGIN
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('beginning of map_quote_to_order ', 1, 'Y');
    END IF;

  -- initialize OM record types

   ASO_ORDER_INT.Initialize_OM_rec_types(
     px_header_rec         => l_header_rec,
     px_line_tbl           => l_line_tbl,
     p_line_tbl_count      => p_line_shipment_tbl.count
    );
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('initialized OM rec types ', 1, 'N');
   END IF;

   l_header_rec.accounting_rule_id := p_qte_rec.accounting_rule_id;
   l_header_rec.agreement_id:=     p_qte_rec.contract_id;
   l_header_rec.context     :=     p_qte_rec.attribute_category;
   l_header_rec.attribute1  :=     p_qte_rec.attribute1;
   l_header_rec.attribute2  :=     p_qte_rec.attribute2;
   l_header_rec.attribute3  := 	   p_qte_rec.attribute3;
   l_header_rec.attribute4  :=     p_qte_rec.attribute4;
   l_header_rec.attribute5  :=     p_qte_rec.attribute5;
   l_header_rec.attribute6  := 	   p_qte_rec.attribute6;
   l_header_rec.attribute7  := 	   p_qte_rec.attribute7;
   l_header_rec.attribute8  := 	   p_qte_rec.attribute8;
   l_header_rec.attribute9  := 	   p_qte_rec.attribute9;
   l_header_rec.attribute10 := 	   p_qte_rec.attribute10;
   l_header_rec.attribute11 := 	   p_qte_rec.attribute11;
   l_header_rec.attribute12 := 	   p_qte_rec.attribute12;
   l_header_rec.attribute13 := 	   p_qte_rec.attribute13;
   l_header_rec.attribute14 := 	   p_qte_rec.attribute14;
   l_header_rec.attribute15 :=	   p_qte_rec.attribute15;
   -- for bug 7560676
   l_header_rec.attribute16 := 	   p_qte_rec.attribute16;
   l_header_rec.attribute17 := 	   p_qte_rec.attribute17;
   l_header_rec.attribute18 := 	   p_qte_rec.attribute18;
   l_header_rec.attribute19 := 	   p_qte_rec.attribute19;
   l_header_rec.attribute20 :=	   p_qte_rec.attribute20;

   l_header_rec.order_category_code  := p_qte_rec.quote_category_code;
   l_header_rec.ordered_date         := p_qte_rec.ordered_date;
    IF (l_header_rec.ordered_date is NULL OR
        l_header_rec.ordered_date = FND_API.G_MISS_DATE) AND
        p_operation = 'CREATE' THEN
         l_header_rec.ordered_date   := sysdate;
    END IF;
   l_header_rec.marketing_source_code_id := p_qte_rec.marketing_source_code_id;

-- hyang new okc
    l_header_rec.Customer_Signature             := p_qte_rec.Customer_Name_And_Title;
    l_header_rec.Customer_Signature_date        := p_qte_rec.Customer_Signature_Date;
    l_header_rec.Supplier_Signature             := p_qte_rec.Supplier_Name_And_Title;
    l_header_rec.Supplier_Signature_date        := p_qte_rec.Supplier_Signature_Date;
    l_header_rec.Contract_Template_Id           := p_qte_rec.Contract_Template_ID;
    l_header_rec.Contract_Source_Doc_Type_Code  := 'QUOTE';
    l_header_rec.Contract_Source_Document_Id    := p_qte_rec.quote_header_id;

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Customer_Signature: '||l_header_rec.Customer_Signature,1,'Y');
    aso_debug_pub.add('Customer_Signature_date: '||l_header_rec.Customer_Signature_date, 1, 'Y');
    aso_debug_pub.add('Supplier_Signature: '||l_header_rec.Supplier_Signature, 1, 'Y');
    aso_debug_pub.add('Supplier_Signature_date: '||l_header_rec.Supplier_Signature_date, 1, 'Y');
    aso_debug_pub.add('Contract_Template_Id: '||l_header_rec.Contract_Template_Id, 1, 'Y');
    aso_debug_pub.add('Contract_Source_Doc_Type_Code: '||l_header_rec.Contract_Source_Doc_Type_Code, 1, 'Y');
    aso_debug_pub.add('Contract_Source_Document_Id: '||l_header_rec.Contract_Source_Document_Id, 1, 'Y');
  END IF;

-- end of hyang new okc


--conversion rate depends on the profile value

   l_header_rec.conversion_rate_date := p_qte_rec.exchange_rate_date ;
   l_header_rec.conversion_type_code := p_qte_rec.exchange_type_code ;

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('before functional currency'||p_qte_rec.currency_code,1,'N');
  aso_debug_pub.add('set of books id prof: '||l_set_of_books_id, 1, 'N');
  aso_debug_pub.add('conversion type prof: '||l_conversion_type, 1, 'N');
  END IF;

   -- vtariker: 3057860: overriding profile value if value is passed in hdr
   IF l_header_rec.conversion_type_code IS NOT NULL OR
	 l_header_rec.conversion_type_code <> FND_API.G_MISS_CHAR THEN
       l_conversion_type := l_header_rec.conversion_type_code;
   END IF;
   -- vtariker: 3057860

  IF p_qte_rec.currency_code is not NULL
     AND p_qte_rec.currency_code <> FND_API.G_MISS_CHAR THEN

    IF (l_set_of_books_id IS NOT NULL) THEN

	OPEN C_Functional_Currency(l_set_of_books_id);
	FETCH C_Functional_Currency INTO l_functional_currency;
	CLOSE C_Functional_Currency;

	IF (l_functional_currency <> p_qte_rec.currency_code) THEN

	   IF (l_conversion_type is NULL) THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	           fnd_message.set_name('ASO', 'ASO_QTE_MISSING_CONV_TYPE');
  	           FND_MSG_PUB.Add;
	        END IF;
            RAISE FND_API.G_EXC_ERROR;
	    END IF;

	   IF l_conversion_type <> 'USER' THEN
	      l_header_rec.conversion_rate := FND_API.G_MISS_NUM;
	      l_header_rec.conversion_rate_date := FND_API.G_MISS_DATE;
        ELSE
		  IF (p_qte_rec.exchange_rate is NULL OR
		      p_qte_rec.exchange_rate = FND_API.G_MISS_NUM) THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	           fnd_message.set_name('ASO', 'ASO_QTE_MISSING_CONV_RATE');
		       fnd_message.set_token('CURRENCY_CODE', p_qte_rec.currency_code, FALSE);
  	           FND_MSG_PUB.Add;
	         END IF;
            RAISE FND_API.G_EXC_ERROR;
		  END IF;
            l_header_rec.conversion_rate := p_qte_rec.exchange_rate;
		  l_header_rec.conversion_rate_date := l_sysdate;
        END IF;

        l_header_rec.conversion_type_code := l_conversion_type;

		 -- update in quote tables if needed
                IF upper(p_qte_rec.quote_source_code) = 'ORDER CAPTURE QUOTES' THEN
                     UPDATE ASO_QUOTE_HEADERS_ALL
	             SET Exchange_Type_Code = l_conversion_type,
		         Exchange_Rate_Date = l_sysdate,
		         Exchange_rate	= p_qte_rec.exchange_rate
              ,last_update_date = l_sysdate
              ,last_updated_by = l_g_user_id
              ,last_update_login = l_g_login_id

	             WHERE Quote_header_Id = p_qte_rec.quote_header_id;
                END IF;  -- update quote
        END IF;

  END IF; -- conversion
 END IF; -- currency code not null

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_header_rec.conversion_rate: '||l_header_rec.conversion_rate,1,'N');
aso_debug_pub.add('l_header_rec.conversion_rate_date: '||l_header_rec.conversion_rate_date,1,'N');
aso_debug_pub.add('l_header_rec.conversion_type_code: '||l_header_rec.conversion_type_code,1,'N');
aso_debug_pub.add('before customer account ', 1, 'Y'  );
END IF;

     IF p_qte_rec.cust_account_id is not NULL
        AND p_qte_rec.cust_account_id <> FND_API.G_MISS_NUM THEN
          l_header_rec.sold_to_org_id := p_qte_rec.cust_account_id;
          l_cust_account_id      :=  p_qte_rec.cust_account_id;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('validating cust account ' || l_cust_account_id || 'for party' || p_qte_rec.party_id, 1, 'N');
END IF;
          ASO_PARTY_INT.Validate_CustAccount (
          p_init_msg_list     => FND_API.G_FALSE,
          p_party_id     => p_qte_rec.party_id,
          p_cust_account_id=> l_cust_account_id,
          x_return_status => l_return_status,
          x_msg_count    => l_msg_count,
          x_msg_data     => l_msg_data);
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add(' done validating customer.return status = ' || l_return_status ,1, 'Y');
END IF;
          IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
		  FND_MESSAGE.Set_Token('COLUMN', 'CUST_ACCOUNT_ID', FALSE);
            FND_MSG_PUB.ADD;
           END IF;
          raise FND_API.G_EXC_ERROR;
          END IF;
     ELSE
       IF p_operation = 'CREATE' THEN
        IF p_qte_rec.party_id is not NULL
             AND p_qte_rec.party_id <> FND_API.G_MISS_NUM THEN
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('deriving cust account id:p_qte_rec.party_id: '||p_qte_rec.party_id, 1, 'N');
	    END IF;
            ASO_CHECK_TCA_PVT.Customer_Account(
                p_api_version       => 1.0,
                p_Party_Id          => p_qte_rec.party_id,
			 p_calling_api_flag  => 0,
                x_Cust_Acct_Id      => l_cust_account_id,
                x_return_status     => l_return_status,
                x_msg_count         => l_msg_count,
                x_msg_data          => l_msg_data);

               IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                  FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
                  FND_MESSAGE.Set_Token('ID', to_char( p_qte_rec.party_id), FALSE);
                  FND_MSG_PUB.ADD;
                END IF;
                raise FND_API.G_EXC_ERROR;
               END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Cust_Accnt_Id in'||l_cust_account_id, 1, 'N');
END IF;
             -- update quote header if account is created
            IF upper(p_qte_rec.quote_source_code) = 'ORDER CAPTURE QUOTES' THEN
                     UPDATE ASO_QUOTE_HEADERS_ALL
	             SET cust_account_id = l_cust_account_id
              ,last_update_date = l_sysdate
              ,last_updated_by = l_g_user_id
              ,last_update_login = l_g_login_id


	             WHERE Quote_header_Id = p_qte_rec.quote_header_id;
                  END IF;  -- update quote

             l_header_rec.sold_to_org_id := l_cust_account_id;
        END IF;
      END IF;
      IF p_operation = 'UPDATE' THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('before query = ' || p_qte_rec.order_id , 1, 'Y');
END IF;
          OPEN get_cust_account_id(p_qte_rec.order_id);
          FETCH get_cust_account_id INTO l_header_rec.sold_to_org_id;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after query = ' || l_header_rec.sold_to_org_id, 1, 'Y');
END IF;
          CLOSE get_cust_account_id;
          IF l_header_rec.sold_to_org_id is NULL THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            --  fnd_message.set_name('ASO', 'MISSING_CUST_ACCOUNT_ID');
		    FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
		    FND_MESSAGE.Set_Token('COLUMN', 'CUST_ACCOUNT_ID', FALSE);
              FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
     END IF;

    IF p_qte_rec.invoice_to_cust_account_id <> FND_API.G_MISS_NUM AND
	  p_qte_rec.invoice_to_cust_account_id IS NOT NULL AND
       p_qte_rec.invoice_to_cust_account_id <> l_cust_account_id THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('before cust_acct_reltn:p_sold_to_cust_account: '||l_cust_account_id, 1, 'N');
aso_debug_pub.add('before cust_acct_reltn:p_related_cust_account: '||p_qte_rec.invoice_to_cust_account_id, 1, 'N');
END IF;
        ASO_CHECK_TCA_PVT.Cust_acct_Relationship (
          p_api_version => 1.0,
          p_sold_to_cust_account => l_cust_account_id,
          p_related_cust_account =>p_qte_rec.invoice_to_cust_account_id,
          p_relationship_type => 'BILL_TO',
          x_return_status    => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data
        );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after cust_acct_reltn:l_return_status: '||l_return_status, 1, 'N');
END IF;
          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('before org contact', 1, 'N');
aso_debug_pub.add('p_qte_rec.org_contact_id: ' || p_qte_rec.org_contact_id,1, 'N');
END IF;
   IF p_qte_rec.party_id is not null and
	 p_qte_rec.party_id <> FND_API.G_MISS_NUM THEN

     IF p_qte_rec.org_contact_id is NULL OR
		    p_qte_rec.org_contact_id = FND_API.G_MISS_NUM THEN
       get_org_contact( p_party_id => p_qte_rec.party_id,
				    x_org_contact => l_org_contact
                      );
     ELSE
	   l_org_contact := p_qte_rec.org_contact_id;
     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_org_contact: ' || l_org_contact,1, 'N');
END IF;
     IF l_org_contact is not NULL AND
         l_org_contact <> FND_API.G_MISS_NUM THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('deriving org_contact_role:l_header_rec.sold_to_org_id: ' || l_header_rec.sold_to_org_id,1, 'N');
END IF;
          get_org_contact_role(
                   p_Org_Contact_Id   => l_org_contact
                  ,p_Cust_account_id  => l_header_rec.sold_to_org_id
                  ,x_return_status    => l_return_status
                  ,x_party_id         => l_org_contact_party_id
                  ,x_cust_account_role_id => l_header_rec.sold_to_contact_id
                  );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after get org contact. sold_to_contact_id = ' || l_header_rec.sold_to_contact_id ,1, 'N');
END IF;
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_ORG_CON_ACT_CRS');
              FND_MSG_PUB.ADD;
            END IF;
            raise FND_API.G_EXC_ERROR;
          END IF;

          IF l_header_rec.sold_to_contact_id is NULL OR
             l_header_rec.sold_to_contact_id = FND_API.G_MISS_NUM THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('calling create contact role for org contact:l_org_contact_party_id: '||l_org_contact_party_id,1, 'N');
aso_debug_pub.add('calling create contact role for org contact:l_header_rec.sold_to_org_id: '||l_header_rec.sold_to_org_id,1, 'N');
END IF;
            ASO_PARTY_INT.Create_Contact_Role (
                  p_api_version      => 1.0
                 ,p_party_id         =>l_org_contact_party_id
                 ,p_Cust_account_id  =>  l_header_rec.sold_to_org_id
                 ,x_return_status    => l_return_status
                 ,x_msg_count        => l_msg_count
                 ,x_msg_data         => l_msg_data
                 ,x_cust_account_role_id  => l_header_rec.sold_to_contact_id
  	        );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after create contact role. sold_to_contact_id = ' || l_header_rec.sold_to_contact_id ,1, 'Y');
END IF;
              IF L_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                  FND_MESSAGE.Set_Name('ASO', 'ASO_ORG_CONTACT');
                  FND_MESSAGE.Set_Token('ID', to_char(p_qte_rec.org_contact_id), FALSE);
                  FND_MSG_PUB.ADD;
                END IF;
                raise FND_API.G_EXC_ERROR;
              END IF;
          END IF;
     END IF;
   END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('invoice_to_cust_account = ' || p_qte_rec.invoice_to_cust_account_id,1,'N');
END IF;
      IF p_qte_rec.invoice_to_cust_account_id is not NULL AND
         p_qte_rec.invoice_to_cust_account_id <> FND_API.G_MISS_NUM THEN
         l_invoice_cust_account_id := p_qte_rec.invoice_to_cust_account_id;
		 --commenting the below else part as a part of customer bug 17630779
     /* ELSE
         --l_invoice_cust_account_id := l_header_rec.sold_to_org_id;
		   	fnd_message.set_name( 'ASO', 'ASO_NO_CUST_ACCOUNT_ID' ) ;
        fnd_message.set_token( 'CUSTOMER_TYPE ', 'ASO_DFLT_VLDN_BILL_CUSTOMER',TRUE) ;
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR; /*14600446 */
      END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_invoice_cust_acccount_id = ' || l_invoice_cust_account_id,1,'N' );
aso_debug_pub.add('before invoice to party site id '|| p_qte_rec.invoice_to_party_site_id, 1, 'Y');
END IF;
     IF p_qte_rec.invoice_to_party_site_id is not NULL
      AND p_qte_rec.invoice_to_party_site_id <> FND_API.G_MISS_NUM THEN

	 ASO_CHECK_TCA_PVT.Customer_Account_Site
	 (
   		p_api_version     => 1.0
	   ,p_party_site_id => p_qte_rec.invoice_to_party_site_id
	   ,p_acct_site_type => 'BILL_TO'
	   ,p_cust_account_id => l_invoice_cust_account_id
	   ,x_cust_acct_site_id => l_hd_inv_cust_acct_site
	   ,x_return_status   => l_return_status
 	   ,x_msg_count       => l_msg_count
 	   ,x_msg_data        => l_msg_data
	   ,x_site_use_id  => l_header_rec.invoice_to_org_id
       );

       IF l_header_rec.invoice_to_org_id IS NULL THEN
		 l_header_rec.invoice_to_org_id := FND_API.G_MISS_NUM;
       END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('site_use_id after deriving invoice = ' || l_header_rec.invoice_to_org_id,1,'Y');
aso_debug_pub.add('inv_acct_site after deriving invoice = ' || l_hd_inv_cust_acct_site,1,'Y');
END IF;
	  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		 THEN
         FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_INV_SITE_AC_CRS');
	    FND_MSG_PUB.ADD;
        END IF;
        raise FND_API.G_EXC_ERROR;
	  END IF;

     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add(' invoice_to_party = ' || p_qte_rec.invoice_to_party_id,1, 'N' );
aso_debug_pub.add(' invoice_to_party_Site = ' || p_qte_rec.invoice_to_party_site_id,1, 'N' );
aso_debug_pub.add('before Cust_Acct_Contact_Addr:l_invoice_cust_acccount =  ' ||l_invoice_cust_account_id ,1,'Y');
END IF;

    ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
     p_api_version       =>  1.0,
     p_party_site_id     =>  p_qte_rec.invoice_to_party_site_id,
     p_role_type         =>  'BILL_TO',
     p_cust_account_id   =>  l_invoice_cust_account_id,
     p_party_id          =>  p_qte_rec.invoice_to_party_id,
     p_cust_account_site =>  l_hd_inv_cust_acct_site,
     x_return_status     =>  l_return_status,
     x_msg_count         =>  l_msg_count,
     x_msg_data          =>  l_msg_data,
     x_cust_account_role_id      =>  l_header_rec.invoice_to_contact_id);

     IF l_header_rec.invoice_to_contact_id IS NULL THEN
         l_header_rec.invoice_to_contact_id := FND_API.G_MISS_NUM;
     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq hd: after Cust_Acct_Contact_Addr:l_header_rec.invoice_to_contact_id: '||l_header_rec.invoice_to_contact_id,1,'N');
END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;

-- end_cust
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('End_Customer_cust_account = ' || p_qte_rec.End_Customer_cust_account_id,1,'N');
END IF;
      IF p_qte_rec.End_Customer_cust_account_id is not NULL AND
         p_qte_rec.End_Customer_cust_account_id <> FND_API.G_MISS_NUM THEN
         l_End_cust_account_id := p_qte_rec.End_Customer_cust_account_id;
      ELSE
         l_End_cust_account_id := l_header_rec.sold_to_org_id;
      END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_End_cust_acccount_id = ' || l_End_cust_account_id,1,'N' );
aso_debug_pub.add('before End_Customer party site id '|| p_qte_rec.End_Customer_party_site_id, 1, 'Y');
END IF;
     IF p_qte_rec.End_Customer_party_site_id is not NULL
      AND p_qte_rec.End_Customer_party_site_id <> FND_API.G_MISS_NUM THEN

	 ASO_CHECK_TCA_PVT.Customer_Account_Site
	 (
   		p_api_version     => 1.0
	   ,p_party_site_id => p_qte_rec.End_Customer_party_site_id
	   ,p_acct_site_type => 'END_USER'
	   ,p_cust_account_id => l_End_cust_account_id
	   ,x_cust_acct_site_id => l_hd_end_cust_acct_site
	   ,x_return_status   => l_return_status
 	   ,x_msg_count       => l_msg_count
 	   ,x_msg_data        => l_msg_data
	   ,x_site_use_id  => l_header_rec.End_Customer_Site_Use_Id
       );

       IF l_header_rec.End_Customer_Site_Use_Id IS NULL THEN
		 l_header_rec.End_Customer_Site_Use_Id := FND_API.G_MISS_NUM;
       END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('site_use_id after deriving End_Customer = ' || l_header_rec.End_Customer_Site_Use_Id,1,'Y');
aso_debug_pub.add('inv_acct_site after deriving End_Customer = ' || l_hd_end_cust_acct_site,1,'Y');
END IF;
	  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		 THEN
         FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_END_SITE_AC_CRS');
	    FND_MSG_PUB.ADD;
        END IF;
        raise FND_API.G_EXC_ERROR;
	  END IF;

      l_header_rec.End_Customer_id := l_End_cust_account_id;

     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add(' End_Customer_party = ' || p_qte_rec.End_Customer_party_id,1, 'N' );
aso_debug_pub.add(' invoice_to_party_Site = ' || p_qte_rec.End_Customer_party_site_id,1, 'N' );
aso_debug_pub.add('before Cust_Acct_Contact_Addr:l_End_cust_acccount =  ' ||l_End_cust_account_id ,1,'Y');
END IF;

    ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
     p_api_version       =>  1.0,
     p_party_site_id     =>  p_qte_rec.End_Customer_party_site_id,
     p_role_type         =>  'END_USER',
     p_cust_account_id   =>  l_End_cust_account_id,
     p_party_id          =>  p_qte_rec.End_Customer_party_id,
     p_cust_account_site =>  l_hd_end_cust_acct_site,
     x_return_status     =>  l_return_status,
     x_msg_count         =>  l_msg_count,
     x_msg_data          =>  l_msg_data,
     x_cust_account_role_id      =>  l_header_rec.End_Customer_contact_id);

     IF l_header_rec.End_Customer_contact_id IS NULL THEN
         l_header_rec.End_Customer_contact_id := FND_API.G_MISS_NUM;
     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq hd: after Cust_Acct_Contact_Addr:l_header_rec.End_Customer_contact_id: '||l_header_rec.End_Customer_contact_id,1,'N');
aso_debug_pub.add('mapq hd: after Cust_Acct_Contact_Addr:l_header_rec.End_Customer_id: '||l_header_rec.End_Customer_id,1,'N');
END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;

-- end_cust

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('beginning of mapping for header shipping ', 1, 'N' );
END IF;

   IF p_header_shipment_tbl.count > 0 THEN
   -- OM takes in only one shipment at the header level

     IF p_header_shipment_tbl(1).ship_to_cust_account_id <> FND_API.G_MISS_NUM AND
	   p_header_shipment_tbl(1).ship_to_cust_account_id IS NOT NULL AND
        p_header_shipment_tbl(1).ship_to_cust_account_id <> l_cust_account_id THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('before cust_acct_relationship ', 1, 'N' );
END IF;
        ASO_CHECK_TCA_PVT.Cust_acct_Relationship (
          p_api_version => 1.0,
          p_sold_to_cust_account => l_cust_account_id,
          p_related_cust_account => p_header_shipment_tbl(1).ship_to_cust_account_id,
          p_relationship_type => 'SHIP_TO',
          x_return_status    => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data
        );

          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

     END IF;

     IF p_header_shipment_tbl(1).ship_to_cust_account_id is not NULL AND
        p_header_shipment_tbl(1).ship_to_cust_account_id <> FND_API.G_MISS_NUM THEN
         l_ship_cust_account_id := p_header_shipment_tbl(1).ship_to_cust_account_id;
		 --commenting the below else part as a part of customer bug 17630779
     /*ELSE
         --l_ship_cust_account_id := l_header_rec.sold_to_org_id;
	 	fnd_message.set_name( 'ASO', 'ASO_NO_CUST_ACCOUNT_ID' ) ;
        fnd_message.set_token( 'CUSTOMER_TYPE ', 'ASO_DFLT_VLDN_SHIP_CUSTOMER',TRUE) ;
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
		/*bug17230231 */
     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('ship cust acccount = ' || l_ship_cust_account_id ,1, 'N');
aso_debug_pub.add('ship to party site = ' || p_header_shipment_tbl(1).ship_to_party_site_id, 1, 'N');
END IF;
     IF p_header_shipment_tbl(1).ship_to_party_site_id is not NULL
       AND p_header_shipment_tbl(1).ship_to_party_site_id <> FND_API.G_MISS_NUM
     THEN

   ASO_CHECK_TCA_PVT.Customer_Account_Site
      (
  	 p_api_version     => 1.0
        ,p_party_site_id => p_header_shipment_tbl(1).ship_to_party_site_id
        ,p_acct_site_type => 'SHIP_TO'
        ,p_cust_account_id => l_ship_cust_account_id
        ,x_cust_acct_site_id => l_hd_shp_cust_acct_site
        ,x_return_status => l_return_status
        ,x_msg_count       => l_msg_count
        ,x_msg_data        => l_msg_data
        ,x_site_use_id  => l_header_rec.ship_to_org_id
       );

       IF l_header_rec.ship_to_org_id IS NULL THEN
           l_header_rec.ship_to_org_id := FND_API.G_MISS_NUM;
       END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('ship to org after deriving = ' || l_header_rec.ship_to_org_id, 1, 'N');
aso_debug_pub.add('ship acct site after deriving = ' || l_hd_shp_cust_acct_site, 1, 'N');
END IF;
       if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
         FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_SHP_SITE_AC_CRS');
         FND_MSG_PUB.ADD;
        END IF;
        raise FND_API.G_EXC_ERROR;
       END IF;

     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('beginning of map 2:ship_party_id: ' || p_header_shipment_tbl(1).ship_to_party_id,1,'N');
aso_debug_pub.add('before Cust_Acct_Contact_Addr:l_ship_cust_account_id: '||l_ship_cust_account_id,1,'N');
aso_debug_pub.add('before Cust_Acct_Contact_Addr:p_header_shipment_tbl(1).ship_to_party_site_id: '||p_header_shipment_tbl(1).ship_to_party_site_id,1,'N');
END IF;

ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
     p_api_version       =>  1.0,
     p_party_site_id     =>  p_header_shipment_tbl(1).ship_to_party_site_id,
     p_role_type         =>  'SHIP_TO',
     p_cust_account_id   =>  l_ship_cust_account_id,
     p_party_id          =>  p_header_shipment_tbl(1).ship_to_party_id,
     p_cust_account_site =>  l_hd_shp_cust_acct_site,
     x_return_status     =>  l_return_status,
     x_msg_count         =>  l_msg_count,
     x_msg_data          =>  l_msg_data,
     x_cust_account_role_id      =>  l_header_rec.ship_to_contact_id);

       IF l_header_rec.ship_to_contact_id IS NULL THEN
           l_header_rec.ship_to_contact_id := FND_API.G_MISS_NUM;
       END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq hdr: after Cust_Acct_Contact_Addr:l_header_rec.ship_to_contact_id: '||l_header_rec.ship_to_contact_id,1,'N');
END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;

  END IF;  -- shipment tbl count
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after map 2 for header',1,'N');
END IF;


   IF p_operation = 'CREATE' THEN
      l_header_rec.operation   := OE_GLOBALS.G_OPR_CREATE;
   ELSIF p_operation = 'UPDATE' THEN
      l_header_rec.operation   := OE_GLOBALS.G_OPR_UPDATE;
      l_header_rec.header_id   := p_qte_rec.order_id;
   END IF;

   l_header_rec.order_number         := p_qte_rec.order_number;
   l_header_rec.invoicing_rule_id    := p_qte_rec.invoicing_rule_id;
   l_header_rec.order_type_id        := p_qte_rec.order_type_id;
   l_header_rec.org_id               := p_qte_rec.org_id ;

   l_header_rec.minisite_id          := p_qte_rec.minisite_id;

-- employee person id is converted to salesrep
-- salesrep id is required for booking an order


-- if an employee person id is passed then it needs to be converted to a
-- salesrep id. no error is raised if the conversion is not possible

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_validate_salesrep_prof =' ||l_validate_salesrep_prof,1,'N');
aso_debug_pub.add('l_om_defaulting_prof =' ||l_om_defaulting_prof,1,'N');
aso_debug_pub.add('p_qte_rec.employee_person_id = '|| p_qte_rec.employee_person_id,1,'N');
aso_debug_pub.add('p_qte_rec.resource_id = ' || p_qte_rec.resource_id,1,'N');
END IF;

IF (p_qte_rec.employee_person_id IS NOT NULL AND
      p_qte_rec.employee_person_id <> FND_API.G_MISS_NUM) AND
        (p_qte_rec.resource_id IS NULL OR
         p_qte_rec.resource_id = FND_API.G_MISS_NUM) THEN

     l_header_rec.salesrep_id	  := ASO_ORDER_INT.Salesrep_id(p_qte_rec.employee_person_id);
  ELSE
      IF (p_qte_rec.resource_id IS NOT NULL AND
           p_qte_rec.resource_id <> FND_API.G_MISS_NUM) THEN

            OPEN salesrep(p_qte_rec.resource_id);
            FETCH salesrep into l_header_rec.salesrep_id;
            CLOSE salesrep;
     END IF;
  END IF;

-- if the salesrep id is null and the validate flag is set to 'N' then
-- the sales rep id is defaulted. No warning is given if the salesrep is not
-- the same as the salesrep id
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('salesrep id =' ||l_header_rec.salesrep_id,1,'N');
aso_debug_pub.add('default salesrep =  '|| l_default_person_id_prof,1,'N');
aso_debug_pub.add('p_operation =  '|| p_operation,1,'N');
END IF;

IF (l_header_rec.salesrep_id IS  NULL OR
    l_header_rec.salesrep_id = FND_API.G_MISS_NUM) AND
    p_operation = 'UPDATE' THEN

     l_header_rec.salesrep_id := FND_API.G_MISS_NUM;

ELSE

  IF  (l_header_rec.salesrep_id IS  NULL OR
       l_header_rec.salesrep_id = FND_API.G_MISS_NUM) AND
       l_om_defaulting_prof = 'N' THEN

    IF l_validate_salesrep_prof = 'N' THEN

        OPEN C_Get_Srep_From_Snumber(l_default_person_id_prof);
        FETCH C_Get_Srep_From_Snumber INTO l_header_rec.salesrep_id;
        CLOSE C_Get_Srep_From_Snumber;

        --l_header_rec.salesrep_id := l_default_person_id_prof;

    ELSE
       IF l_validate_salesrep_prof = 'Y' THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('ASO', 'ASO_SALESREP');
             FND_MSG_PUB.Add;
          END IF;
       END IF;
    END IF;
  END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('salesrep id =' ||l_header_rec.salesrep_id,1,'N');
END IF;

-- if the salesrep is still null then an error is raised.

  IF  (l_header_rec.salesrep_id IS  NULL OR
       l_header_rec.salesrep_id = FND_API.G_MISS_NUM) AND
       l_om_defaulting_prof = 'N' AND
       l_validate_salesrep_prof = 'N' THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

	    -- Created new message to display the error message more appropriately - Girish Bug 4654938
            -- FND_MESSAGE.Set_Name('ASO', 'ASO_API_NO_PROFILE_VALUE');
	    -- FND_MESSAGE.Set_Token('PROFILE', 'ASO_DEFAULT_PERSON_ID', FALSE);
	    FND_MESSAGE.Set_Name('ASO', 'ASO_NO_DEFAULT_VALUE');
	    FND_MESSAGE.Set_Token('PROFILE', 'ASO_DEFAULT_SALESREP', TRUE);

  	    FND_MSG_PUB.Add;
	 END IF;
  ELSE
     IF l_om_defaulting_prof = 'Y' AND
	  (l_header_rec.salesrep_id IS  NULL OR
	   l_header_rec.salesrep_id = FND_API.G_MISS_NUM) THEN
	  	  l_header_rec.salesrep_id := FND_API.G_MISS_NUM;
     END IF;
  END IF;

END IF; -- p_operation = UPDATE;

   l_header_rec.price_list_id         := p_qte_rec.price_list_id;
   l_header_rec.pricing_date          := p_qte_rec.price_frozen_date;
   l_header_rec.sales_channel_code   := p_qte_rec.sales_channel_code;

   l_header_rec.transactional_curr_code  := p_qte_rec.currency_code;
   l_header_rec.source_document_id       := p_qte_rec.quote_header_id;


    -- Start bug 16338603
   IF NVL(FND_PROFILE.VALUE('QP_LIMITS_INSTALLED'),'N') = 'Y' THEN
      l_price_req_code:='ASO-'|| p_qte_rec.quote_header_id;
      select count(*) into limit_exist
      from   qp_limit_transactions
      WHERE  price_request_code = l_price_req_code
      and price_request_type_code='ASO';
      if limit_exist>0 then
	l_header_rec.price_request_code:=l_price_req_code;
     end if;
   end if;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.add('l_header_rec.price_request_code: '||l_header_rec.price_request_code,1,'N');
   END IF;
   -- End bug 16338603

   IF p_operation = 'CREATE' THEN
    IF (p_qte_rec.original_system_reference IS NOT NULL OR
      p_qte_rec.original_system_reference <> FND_API.G_MISS_CHAR) THEN
       l_header_rec.orig_sys_document_ref := p_qte_rec.original_system_reference;
    ELSE
     IF (p_qte_rec.quote_header_id IS NULL OR
        p_qte_rec.quote_header_id = FND_API.G_MISS_NUM) THEN
         l_quote_number := NULL;
         l_version_number := NULL;
     ELSE

	   OPEN C_get_quote_number(p_qte_rec.quote_header_id);
	   FETCH C_get_quote_number INTO l_quote_number, l_version_number;
	   CLOSE C_get_quote_number;

        IF l_quote_number IS NOT NULL THEN

            IF l_version_number IS NOT NULL THEN

                l_header_rec.orig_sys_document_ref := to_char(l_quote_number)||':'||to_char(l_version_number);
            ELSE
                l_header_rec.orig_sys_document_ref := to_char(l_quote_number);

            END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_header_rec.orig_sys_document_ref: '||l_header_rec.orig_sys_document_ref,1,'N');
END IF;

        END IF;

    END IF;

   END IF;  -- p_qte_rec.original_system_reference
  ELSIF p_operation = 'UPDATE' THEN
    l_header_rec.orig_sys_document_ref := p_qte_rec.original_system_reference;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('p_operation = UPDATE ** l_header_rec.orig_sys_document_ref: '||l_header_rec.orig_sys_document_ref,1,'N');
    END IF;

  END IF; -- CREATE
-- default value if null

    IF p_qte_rec.quote_source_code is NULL OR
       p_qte_rec.quote_source_code = FND_API.G_MISS_CHAR THEN

	IF p_operation = 'CREATE' THEN

       IF (l_om_defaulting_prof = 'N') THEN
         l_quote_source := 'CRM Apps';
       ELSE
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
	       FND_MESSAGE.Set_Token('COLUMN', 'QUOTE_SOURCE_CODE', FALSE);
		  FND_MSG_PUB.ADD;
		END IF;
       END IF;
     --    p_qte_rec.quote_source_code := 'CRM Apps';

	ELSIF p_operation = 'UPDATE' THEN
		l_quote_source := FND_API.G_MISS_CHAR;
	END IF;

    ELSE
         l_quote_source := p_qte_rec.quote_source_code;

    END IF;


-- source document type id will determine the source of the document
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('in here for quote source',1,'N');
END IF;
   IF l_quote_source is not NULL AND
      l_quote_source <> FND_API.G_MISS_CHAR THEN

      OPEN C_order_source(l_quote_source);
      FETCH C_order_source INTO l_header_rec.source_document_type_id;
       IF (C_order_source%NOTFOUND) THEN
          null;
       END IF;
      CLOSE C_order_source;
   END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('in here after source code',1,'N');
END IF;
  For i in 1..p_header_payment_tbl.count  LOOP

   IF (NVL(l_om_defaulting_prof, 'N') = 'Y') THEN
	IF p_header_payment_tbl(i).payment_term_id IS NULL THEN
	  l_header_rec.payment_term_id :=  FND_API.G_MISS_NUM;
     ELSE -- 3465720
       l_header_rec.payment_term_id :=  p_header_payment_tbl(i).payment_term_id;
     END IF;
   ELSE
     l_header_rec.payment_term_id :=  p_header_payment_tbl(i).payment_term_id;
   END IF;

-- Bug 7253077

/*  Commented for bug 11783589
IF p_header_payment_tbl(i).payment_type_code <> 'PO' THEN
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('p_header_payment_tbl(i).payment_type_code: '||p_header_payment_tbl(i).payment_type_code,1,'N');
     END IF;
      l_header_rec.payment_type_code := p_header_payment_tbl(i).payment_type_code;
   END IF;*/
-- end bug 7253077

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('p_header_payment_tbl(i).cust_po_number: '||p_header_payment_tbl(i).cust_po_number,1,'N');
END IF;

   l_header_rec.cust_po_number := p_header_payment_tbl(i).cust_po_number;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('p_header_payment_tbl(i).payment_type_code: '||p_header_payment_tbl(i).payment_type_code,1,'N');
END IF;
   IF p_header_payment_tbl(i).payment_type_code IS NOT NULL
      AND P_header_Payment_Tbl(i).payment_type_code <> FND_API.G_MISS_CHAR THEN  -- Code change done for Bug 17669369
     l_header_payment_tbl(pay_count).payment_type_code := p_header_payment_tbl(i).payment_type_code;

     l_header_payment_tbl(pay_count).payment_amount  := p_header_payment_tbl(i).payment_amount;

     IF p_operation = 'CREATE' THEN
       l_header_payment_tbl(pay_count).operation := p_operation;
     ELSIF p_operation = 'UPDATE' THEN
       l_header_payment_tbl(pay_count).operation := p_header_payment_tbl(i).operation_code;

       -- Start : Code change done for Bug 16343780
       l_header_payment_tbl(pay_count).header_id := p_qte_rec.order_id;
       aso_debug_pub.add('mapping of header payment , p_qte_rec.order_id : '||p_qte_rec.order_id,1,'N');
        IF p_header_payment_tbl(i).payment_type_code = 'CREDIT_CARD'  THEN
           l_header_payment_tbl(pay_count).payment_number := p_header_payment_tbl(i).payment_ref_number;
     	   aso_debug_pub.add('mapping of header payment , p_header_payment_tbl('||i||').payment_ref_number: '||p_header_payment_tbl(i).payment_ref_number,1,'N');
        END IF;

	If p_header_payment_tbl(i).operation_code IS Null Then
           l_header_payment_tbl(pay_count).operation := p_operation;
        End If;
        -- End : Code change done for Bug 16343780

     END IF;

     l_header_payment_tbl(pay_count).trxn_extension_id := p_header_payment_tbl(i).trxn_extension_id;
     l_header_payment_tbl(pay_count).payment_collection_event := 'INVOICE';
     l_header_payment_tbl(pay_count).payment_level_code := 'ORDER';

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_header_payment_tbl(pay_count).operation: '||l_header_payment_tbl(pay_count).operation,1,'N');
aso_debug_pub.add('l_header_payment_tbl(pay_count).trxn_extension_id: '||l_header_payment_tbl(pay_count).trxn_extension_id,1,'N');
END IF;

     /* Start : code change done for Bug 9401669 */
     If (l_header_payment_tbl(pay_count).trxn_extension_id Is Null Or
         l_header_payment_tbl(pay_count).trxn_extension_id = FND_API.G_MISS_NUM ) Then

         l_header_payment_tbl(pay_count).CC_INSTRUMENT_ASSIGNMENT_ID := p_header_payment_tbl(i).INSTR_ASSIGNMENT_ID;
         l_header_payment_tbl(pay_count).CC_INSTRUMENT_ID := p_header_payment_tbl(i).INSTRUMENT_ID;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Map_Quote_to_order : l_header_payment_tbl(pay_count).CC_INSTRUMENT_ASSIGNMENT_ID : '||l_header_payment_tbl(pay_count).CC_INSTRUMENT_ASSIGNMENT_ID, 1, 'N');
            aso_debug_pub.add('Map_Quote_to_order : l_header_payment_tbl(pay_count).CC_INSTRUMENT_ID : '||l_header_payment_tbl(pay_count).CC_INSTRUMENT_ID, 1, 'N');
         End If;
     End If;
     /* End : code change done for Bug 9401669 */

     IF p_header_payment_tbl(i).payment_type_code = 'CHECK' THEN
          l_header_payment_tbl(pay_count).check_number := p_header_payment_tbl(i).payment_ref_number;
     END IF;

   END IF; -- payment_type_code is not null

   -- bug 5613870
   -- IF p_header_payment_tbl(i).payment_type_code = 'CREDIT_CARD'  THEN         -- Code Change done for Bug 14180257
      l_header_payment_tbl(pay_count).receipt_method_id := fnd_api.g_miss_num;
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Passing receipt method id as g miss num' ,1,'N');
      END IF;
   -- END IF;

   pay_count := pay_count + 1;

  END LOOP;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapped header payment tbl',1,'N');
END IF;


  For i in 1..p_header_shipment_tbl.count LOOP
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapped header shipment tbl:shipping_instructions: '|| p_header_shipment_tbl(i).shipping_instructions||'trimmed',1,'N');
END IF;
--bug 1921958
      IF (p_header_shipment_tbl(i).shipping_instructions IS NULL) AND
         (l_om_defaulting_prof = 'Y') THEN
          l_header_rec.shipping_instructions
              :=FND_API.G_MISS_CHAR;
      ELSE
           l_header_rec.shipping_instructions
              :=rtrim(p_header_shipment_tbl(i).shipping_instructions);
      END IF;

      IF (p_header_shipment_tbl(i).packing_instructions IS NULL) AND
         (l_om_defaulting_prof = 'Y') THEN
          l_header_rec.packing_instructions
              :=FND_API.G_MISS_CHAR;
      ELSE
           l_header_rec.packing_instructions
              :=rtrim(p_header_shipment_tbl(i).packing_instructions);
      END IF;
--bug 1921958
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapped header shipment tbl:shipping_instructions: '|| l_header_rec.shipping_instructions||'trimmed',1,'N');
aso_debug_pub.add('mapped header shipment tbl:packing_instructions: '|| l_header_rec.packing_instructions||'trimmed',1,'N');
END IF;

      IF (NVL(l_om_defaulting_prof, 'N') = 'Y') THEN
          IF p_header_shipment_tbl(i).FOB_CODE is null then
            l_header_rec.fob_point_code := FND_API.G_MISS_CHAR;
          ELSE -- 3465720
            l_header_rec.fob_point_code := p_header_shipment_tbl(i).fob_code;
          end if;
          IF p_header_shipment_tbl(i).FREIGHT_TERMS_CODE is null then
            l_header_rec.FREIGHT_TERMS_CODE := FND_API.G_MISS_CHAR;
          ELSE -- 3465720
            l_header_rec.FREIGHT_TERMS_CODE := p_header_shipment_tbl(i).freight_terms_code;
          end if;
          IF p_header_shipment_tbl(i).SHIPMENT_PRIORITY_CODE is null then
            l_header_rec.SHIPMENT_PRIORITY_CODE := FND_API.G_MISS_CHAR;
          ELSE -- 3465720
            l_header_rec.SHIPMENT_PRIORITY_CODE := p_header_shipment_tbl(i).shipment_priority_code;
          end if;
          IF p_header_shipment_tbl(i).ship_method_code is null then
            l_header_rec.shipping_method_code := FND_API.G_MISS_CHAR;
          ELSE -- 3582285
            l_header_rec.shipping_method_code := p_header_shipment_tbl(i).ship_method_code;
          end if;

      ELSE
          l_header_rec.fob_point_code   := p_header_shipment_tbl(i).fob_code;
          l_header_rec.freight_terms_code
                := p_header_shipment_tbl(i).freight_terms_code;
          l_header_rec.shipment_priority_code
               := p_header_shipment_tbl(i).shipment_priority_code;
          l_header_rec.shipping_method_code
               := p_header_shipment_tbl(i).ship_method_code;
      END IF;

	 IF p_header_shipment_tbl(i).request_date IS NOT NULL THEN
        l_header_rec.request_date := p_header_shipment_tbl(i).request_date;
      END IF;

      -- Start : Code change done for Bug 7668492
      IF p_header_shipment_tbl(i).request_date_type IS NOT NULL THEN
         l_header_rec.order_date_type_code := p_header_shipment_tbl(i).request_date_type;
      End If;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Map_Qte_To_Ord hdr shipment :l_header_rec.order_date_type_code: '||l_header_rec.order_date_type_code,1,'N');
      END IF;
      -- End : Code change fonr for Bug 7668492

      l_header_rec.freight_carrier_code
                 := p_header_shipment_tbl(i).freight_carrier_code;

      l_header_rec.partial_shipments_allowed
                      :=p_header_shipment_tbl(i).ship_partial_flag;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('request date= ' ||l_header_rec.request_date,1,'N');
 aso_debug_pub.add('Map_Qte_To_Ord: p_header_shipment_tbl(i).Ship_From_Org_Id: '||p_header_shipment_tbl(i).Ship_From_Org_Id,1,'Y');
END IF;
   IF p_header_shipment_tbl(i).Ship_From_Org_Id IS NOT NULL AND
      p_header_shipment_tbl(i).Ship_From_Org_Id <> FND_API.G_MISS_NUM THEN

          l_header_rec.Ship_From_Org_Id
                           :=p_header_shipment_tbl(i).Ship_From_Org_Id;
   END IF;

 -- bug 4916969
  IF (p_header_shipment_tbl(i).demand_class_code is not null and p_header_shipment_tbl(i).demand_class_code <> fnd_api.g_miss_char) then
     l_header_rec.demand_class_code := p_header_shipment_tbl(i).demand_class_code;

  end if;

  END LOOP;


 For i in 1..p_header_tax_detail_tbl.count LOOP

  l_header_rec.tax_exempt_flag := p_header_tax_detail_tbl(i).tax_exempt_flag;
  l_header_rec.tax_exempt_number
               := p_header_tax_detail_tbl(i).tax_exempt_number;
  l_header_rec.tax_exempt_reason_code
               := p_header_tax_detail_tbl(i).tax_exempt_reason_code;
  l_header_rec.tax_point_code :=  p_header_tax_detail_tbl(i).tax_code;

 END LOOP;

-- reserve quantity
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('MapQ: l_reservation_lvl_prof: '||l_reservation_lvl_prof,1,'N');
END IF;

   IF (l_header_rec.order_type_id is not null AND
       l_header_rec.order_type_id <> FND_API.G_MISS_NUM) AND
       l_reservation_lvl_prof = 'AUTO_ORDER' THEN
         OPEN scheduling_level_cur(l_header_rec.order_type_id);
         FETCH scheduling_level_cur INTO l_order_scheduling_level;
         CLOSE scheduling_level_cur;
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('l_header_rec.order_type_id = ' ||
                         l_header_rec.order_type_id, 1,'N');
      END IF;
   END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after mapping header tax detail ',1,'Y');
END IF;

  map_header_price_attr(
        p_header_price_attributes_tbl => p_header_price_attributes_tbl,
        p_qte_rec  => p_qte_rec,
        p_operation => l_header_rec.operation,
        x_Header_price_Att_tbl => l_header_price_att_tbl
        );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('after mapping header price attr:l_header_price_att_tbl.count: '||l_header_price_att_tbl.count,1,'N');
END IF;

    map_header_price_adj(
        p_header_price_adj_tbl => p_header_price_adj_tbl,
        p_qte_rec  => p_qte_rec,
        p_operation => l_header_rec.operation,
        x_Header_adj_tbl => l_header_adj_tbl
        );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after header price adjustments:l_header_adj_tbl.count: '||l_header_adj_tbl.count,1,'N');
END IF;

    map_header_price_adj_attr(
      p_header_price_adj_attr_tbl  =>  p_header_price_adj_attr_tbl,
      p_operation => l_header_rec.operation,
      x_header_adj_att_tbl   =>   l_header_adj_att_tbl
     );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after header price adj attribute:l_header_adj_att_tbl.count:  '||l_header_adj_att_tbl.count,1,'N');
END IF;

  map_header_price_adj_rltn(
     P_Header_Price_Adj_rltship_Tbl  =>   P_Header_Price_Adj_rltship_Tbl,
	P_operation => l_header_rec.operation,
     x_Header_Adj_Assoc_tbl   =>   l_Header_Adj_Assoc_tbl
     );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('before header sales credit:l_Header_Adj_Assoc_tbl.count: '||l_Header_Adj_Assoc_tbl.count,1,'N');
END IF;

  map_header_sales_credits(
     P_header_sales_credit_Tbl  =>  P_header_sales_credit_Tbl,
     p_operation  =>  p_operation,
     p_qte_rec  => p_qte_rec,
     p_header_operation => l_header_rec.operation,
     x_Header_Scredit_tbl   =>   l_Header_Scredit_tbl
     );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after header sales credit:l_Header_Scredit_tbl.count: '||l_Header_Scredit_tbl.count,1,'N');
END IF;

-- mapping  quote lines to order lines
-- mapping is done based on the index and not on the line id for quotes
-- the line ids should be used for orders

-- initializing all counts for lines
	i := 1;
	j := 1;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('mapping quote lines',1,'N');
END IF;
  FOR j in 1..P_line_Shipment_Tbl.count LOOP
   found := FND_API.G_FALSE;
   FOR k in 1..p_qte_line_tbl.count LOOP

-- kchervel the quantity check should be done before the loop.

   IF p_line_shipment_tbl(j).qte_line_index = k THEN

-- check if the line is satisfied by fulfillment (not required any more 02/09

-- EDU
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('map_quote_to_order- p_qte_line_tbl(k).Commitment_Id: '||p_qte_line_tbl(k).Commitment_Id, 1, 'N');
aso_debug_pub.add('map_quote_to_order- p_qte_line_tbl(k).Agreement_Id: '||p_qte_line_tbl(k).Agreement_Id,1, 'N');
aso_debug_pub.add('map_quote_to_order- p_qte_line_tbl(k).minisite_id: '||p_qte_line_tbl(k).minisite_id,1, 'N');
aso_debug_pub.add('map_quote_to_order- p_qte_rec.minisite_id: '||p_qte_rec.minisite_id,1, 'N');
END IF;
     IF p_qte_line_tbl(k).Commitment_Id IS NOT NULL AND
        p_qte_line_tbl(k).Commitment_Id <> FND_API.G_MISS_NUM THEN
          l_line_tbl(i).Commitment_Id  :=   p_qte_line_tbl(k).Commitment_Id;
     END IF;

     IF p_qte_line_tbl(k).Agreement_Id IS NOT NULL AND
        p_qte_line_tbl(k).Agreement_Id <> FND_API.G_MISS_NUM THEN
          l_line_tbl(i).Agreement_Id :=  p_qte_line_tbl(k).Agreement_Id;
     END IF;
-- EDU

     IF p_qte_line_tbl(k).Item_Revision IS NOT NULL AND
        p_qte_line_tbl(k).Item_Revision <> FND_API.G_MISS_CHAR THEN
          l_line_tbl(i).Item_Revision := p_qte_line_tbl(k).Item_Revision;
     END IF;

     l_line_tbl(i).minisite_id  :=   p_qte_line_tbl(k).minisite_id;

	l_line_tbl(i).accounting_rule_id
		:= p_qte_line_tbl(k).accounting_rule_id;
	l_line_tbl(i).attribute1  :=   p_qte_line_tbl(k).attribute1;
	l_line_tbl(i).attribute10 :=   p_qte_line_tbl(k).attribute10;
	l_line_tbl(i).attribute11 :=   p_qte_line_tbl(k).attribute11;
	l_line_tbl(i).attribute12 :=   p_qte_line_tbl(k).attribute12;
	l_line_tbl(i).attribute13 :=   p_qte_line_tbl(k).attribute13;
	l_line_tbl(i).attribute14 :=   p_qte_line_tbl(k).attribute14;
	l_line_tbl(i).attribute15 :=   p_qte_line_tbl(k).attribute15;
-- for bug 7560676
        l_line_tbl(i).attribute16 :=   p_qte_line_tbl(k).attribute16;
	l_line_tbl(i).attribute17 :=   p_qte_line_tbl(k).attribute17;
	l_line_tbl(i).attribute18 :=   p_qte_line_tbl(k).attribute18;
	l_line_tbl(i).attribute19 :=   p_qte_line_tbl(k).attribute19;
	l_line_tbl(i).attribute20 :=   p_qte_line_tbl(k).attribute20;


	l_line_tbl(i).attribute2  :=   p_qte_line_tbl(k).attribute2;
	l_line_tbl(i).attribute3  :=   p_qte_line_tbl(k).attribute3;
	l_line_tbl(i).attribute4  :=   p_qte_line_tbl(k).attribute4;
	l_line_tbl(i).attribute5  :=   p_qte_line_tbl(k).attribute5;
	l_line_tbl(i).attribute6  :=   p_qte_line_tbl(k).attribute6;
	l_line_tbl(i).attribute7  :=   p_qte_line_tbl(k).attribute7;
	l_line_tbl(i).attribute8  :=   p_qte_line_tbl(k).attribute8;
	l_line_tbl(i).attribute9  :=   p_qte_line_tbl(k).attribute9;
	l_line_tbl(i).context     :=   p_qte_line_tbl(k).attribute_category;
	l_line_tbl(i).invoicing_rule_id
				  :=  p_qte_line_tbl(k).invoicing_rule_id;
     l_line_tbl(i).marketing_source_code_id
                      :=  p_qte_line_tbl(k).marketing_source_code_id;
	l_line_tbl(i).inventory_item_id := p_qte_line_tbl(k).inventory_item_id;
	 l_line_tbl(i).subinventory := p_qte_line_tbl(k).subinventory;

   --bug 16338603
   IF NVL(FND_PROFILE.VALUE('QP_LIMITS_INSTALLED'),'N') = 'Y' THEN
	l_price_req_code :='ASO-'||p_qte_line_tbl(k).quote_header_id||'-'||p_qte_line_tbl(k).quote_line_id;
	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('mapq line: l_price_req_code for line: '|| l_price_req_code,1,'N');
	END IF;
	select count(*) into limit_exist
	from   qp_limit_transactions
	WHERE  price_request_code = l_price_req_code
	and price_request_type_code='ASO';
	if limit_exist>0 then
		l_line_tbl(i).price_request_code:=l_price_req_code;

	end if;
  end if;

--end bug 16338603

	 --ER 12879412
  l_PROD_FISC_CLASSIFICATION := p_qte_line_tbl(k).PRODUCT_FISC_CLASSIFICATION;
  l_TRX_BUSINESS_CATEGORY := p_qte_line_tbl(k).TRX_BUSINESS_CATEGORY;

   --ER 16531247

 --l_line_tbl(i).ORDERED_ITEM_ID:= p_qte_line_tbl(k).ORDERED_ITEM_ID;
 -- l_line_tbl(i).ITEM_IDENTIFIER_TYPE := p_qte_line_tbl(k).ITEM_IDENTIFIER_TYPE;

if p_qte_line_tbl(k).item_type_code='CFG' then   -- bug 14162429
  BEGIN
      select PRODUCT_FISC_CLASSIFICATION,TRX_BUSINESS_CATEGORY
       into l_MDL_PROD_FISC_CLASS, l_MDL_TRX_BUSI_CATE
       from aso_quote_lines_all where quote_line_id =
       (select top_model_line_id from aso_Quote_line_Details where quote_line_id = p_qte_line_tbl(k).quote_line_id);
   EXCEPTION
      when no_data_found then
         null;
      when others then
        null;
    END;
end if;


if (l_PROD_FISC_CLASSIFICATION is null) or (l_PROD_FISC_CLASSIFICATION=FND_API.G_MISS_CHAR) then
   if (p_qte_line_tbl(k).item_type_code='CFG' ) and (l_MDL_PROD_FISC_CLASS is not null) then  -- bug 14162429
     l_PROD_FISC_CLASSIFICATION:=l_MDL_PROD_FISC_CLASS;
 else
     if (p_qte_rec.PRODUCT_FISC_CLASSIFICATION is not null) and (p_qte_rec.PRODUCT_FISC_CLASSIFICATION <> FND_API.G_MISS_CHAR) then
	l_PROD_FISC_CLASSIFICATION := p_qte_rec.PRODUCT_FISC_CLASSIFICATION;
    else
	l_PROD_FISC_CLASSIFICATION:=null;
     end if;
   end if; -- CFG
end if;

if (l_TRX_BUSINESS_CATEGORY is null) or (l_TRX_BUSINESS_CATEGORY=FND_API.G_MISS_CHAR) then
   if (p_qte_line_tbl(k).item_type_code='CFG' ) and (l_MDL_TRX_BUSI_CATE is not null) then  -- bug 14162429
       l_TRX_BUSINESS_CATEGORY:=l_MDL_TRX_BUSI_CATE;
  else
    if (p_qte_rec.TRX_BUSINESS_CATEGORY is not null) and (p_qte_rec.TRX_BUSINESS_CATEGORY <> FND_API.G_MISS_CHAR) then
      l_TRX_BUSINESS_CATEGORY := p_qte_rec.TRX_BUSINESS_CATEGORY;
  else
   l_TRX_BUSINESS_CATEGORY:=null;
  end if;
end if;
end if;

l_line_tbl(i).GLOBAL_ATTRIBUTE5:=l_PROD_FISC_CLASSIFICATION;
l_line_tbl(i).GLOBAL_ATTRIBUTE6:=l_TRX_BUSINESS_CATEGORY;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line:  l_PROD_FISC_CLASSIFICATION: '||l_PROD_FISC_CLASSIFICATION,1,'N');
aso_debug_pub.add('mapq line: l_TRX_BUSINESS_CATEGORY: '||l_TRX_BUSINESS_CATEGORY,1,'N');
END IF;
-- End ER 12879412

-- Start ER 17968970

aso_debug_pub.add('mapq line:  p_qte_line_tbl(k).PREFERRED_GRADE  : '|| p_qte_line_tbl(k).PREFERRED_GRADE,1,'N');
IF p_qte_line_tbl(k).PREFERRED_GRADE IS NOT NULL AND
        p_qte_line_tbl(k).PREFERRED_GRADE <> FND_API.G_MISS_CHAR THEN

	   l_line_tbl(i).PREFERRED_GRADE := p_qte_line_tbl(k).PREFERRED_GRADE;
     END IF;

aso_debug_pub.add('mapq line:  p_qte_line_tbl(k).ORDERED_QUANTITY2  : '|| p_qte_line_tbl(k).ORDERED_QUANTITY2,1,'N');
IF p_qte_line_tbl(k).ORDERED_QUANTITY2 IS NOT NULL AND
        p_qte_line_tbl(k).ORDERED_QUANTITY2 <> FND_API.G_MISS_NUM THEN

	   l_line_tbl(i).ORDERED_QUANTITY2 := p_qte_line_tbl(k).ORDERED_QUANTITY2;
     END IF;

aso_debug_pub.add('mapq line:  p_qte_line_tbl(k).ORDERED_QUANTITY_UOM2  : '|| p_qte_line_tbl(k).ORDERED_QUANTITY_UOM2,1,'N');
IF p_qte_line_tbl(k).ORDERED_QUANTITY_UOM2 IS NOT NULL AND
        p_qte_line_tbl(k).ORDERED_QUANTITY_UOM2 <> FND_API.G_MISS_CHAR THEN

	   l_line_tbl(i).ORDERED_QUANTITY_UOM2 := p_qte_line_tbl(k).ORDERED_QUANTITY_UOM2;
     END IF;


-- End ER 17968970

      -- Recurring charge Change
      --l_line_tbl(i).charge_periodicity_code := p_qte_line_tbl(k).charge_periodicity_code;

      IF p_qte_line_tbl(k).invoice_to_cust_account_id <> FND_API.G_MISS_NUM AND
         p_qte_line_tbl(k).invoice_to_cust_account_id IS NOT NULL AND
         p_qte_line_tbl(k).invoice_to_cust_account_id <> l_cust_account_id THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: before cust_acct_reltn:p_sold_to_cust_account: '||l_cust_account_id,1,'N');
aso_debug_pub.add('mapq line: before cust_acct_reltn:p_related_cust_account: '||p_qte_line_tbl(k).invoice_to_cust_account_id,1,'N');
END IF;
        ASO_CHECK_TCA_PVT.Cust_acct_Relationship (
          p_api_version => 1.0,
          p_sold_to_cust_account => l_cust_account_id,
          p_related_cust_account =>p_qte_line_tbl(k).invoice_to_cust_account_id,
          p_relationship_type => 'BILL_TO',
          x_return_status    => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data
        );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: after cust_acct_reltn:l_return_status: '||l_return_status,1,'N');
END IF;
          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

     END IF;

     IF p_qte_line_tbl(k).invoice_to_cust_account_id is not NULL AND
        p_qte_line_tbl(k).invoice_to_cust_account_id <> FND_API.G_MISS_NUM THEN
         l_invoice_cust_account_id := p_qte_line_tbl(k).invoice_to_cust_account_id;
     ELSE
         l_invoice_cust_account_id := l_header_rec.sold_to_org_id;
     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: before cust_acct_site:l_invoice_cust_account_id: '||l_invoice_cust_account_id,1,'N');
aso_debug_pub.add('mapq line: before cust_acct_site:p_qte_line_tbl(k).invoice_to_party_site_id: '||p_qte_line_tbl(k).invoice_to_party_site_id,1,'N');
END IF;
     IF p_qte_line_tbl(k).invoice_to_party_site_id is not NULL
      AND p_qte_line_tbl(k).invoice_to_party_site_id <> FND_API.G_MISS_NUM THEN

      ASO_CHECK_TCA_PVT.Customer_Account_Site
      (
 	 p_api_version     => 1.0
        ,p_party_site_id => p_qte_line_tbl(k).invoice_to_party_site_id
        ,p_acct_site_type => 'BILL_TO'
        ,p_cust_account_id => l_invoice_cust_account_id
	,x_cust_acct_site_id => l_ln_inv_cust_acct_site
        ,x_return_status => l_return_status
 	,x_msg_count       => l_msg_count
 	,x_msg_data        => l_msg_data
        ,x_site_use_id  => l_line_tbl(i).invoice_to_org_id
       );

       IF l_line_tbl(i).invoice_to_org_id IS NULL THEN
           l_line_tbl(i).invoice_to_org_id := FND_API.G_MISS_NUM;
       END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: after cust_acct_site:l_line_tbl(i).invoice_to_org_id: '||l_line_tbl(i).invoice_to_org_id,1,'N');
aso_debug_pub.add('mapq line: after cust_acct_site:l_ln_inv_cust_acct_site: '||l_ln_inv_cust_acct_site,1,'N');
END IF;
       if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
         FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_INV_SITE_AC_CRS');
         FND_MSG_PUB.ADD;
        END IF;
        raise FND_API.G_EXC_ERROR;
       END IF;

    END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: before Cust_Acct_Contact_Addr:l_invoice_cust_account_id: '||l_invoice_cust_account_id,1,'N');
END IF;

    ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
	p_api_version       =>  1.0,
	p_party_site_id     =>  p_qte_line_tbl(k).invoice_to_party_site_id,
	p_role_type    	    =>  'BILL_TO',
	p_cust_account_id   =>  l_invoice_cust_account_id,
	p_party_id          =>  p_qte_line_tbl(k).invoice_to_party_id,
	p_cust_account_site =>  l_ln_inv_cust_acct_site,
	x_return_status     =>  l_return_status,
	x_msg_count         =>  l_msg_count,
	x_msg_data          =>  l_msg_data,
	x_cust_account_role_id      =>  l_line_tbl(i).invoice_to_contact_id);

       IF l_line_tbl(i).invoice_to_contact_id IS NULL THEN
           l_line_tbl(i).invoice_to_contact_id := FND_API.G_MISS_NUM;
       END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: after Cust_Acct_Contact_Addr:l_line_tbl(i).invoice_to_contact_id: '||l_line_tbl(i).invoice_to_contact_id,1,'N');
END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;

-- end_cust
     IF p_qte_line_tbl(k).End_Customer_cust_account_id is not NULL AND
        p_qte_line_tbl(k).End_Customer_cust_account_id <> FND_API.G_MISS_NUM THEN
         l_End_cust_account_id := p_qte_line_tbl(k).End_Customer_cust_account_id;
     ELSE
         l_End_cust_account_id := l_header_rec.sold_to_org_id;
     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: before cust_acct_site:l_End_cust_account_id: '||l_End_cust_account_id,1,'N');
aso_debug_pub.add('mapq line: before cust_acct_site:p_qte_line_tbl(k).End_Customer_party_site_id: '||p_qte_line_tbl(k).End_Customer_party_site_id,1,'N');
END IF;
     IF p_qte_line_tbl(k).End_Customer_party_site_id is not NULL
      AND p_qte_line_tbl(k).End_Customer_party_site_id <> FND_API.G_MISS_NUM THEN

      ASO_CHECK_TCA_PVT.Customer_Account_Site
      (
 	 p_api_version     => 1.0
        ,p_party_site_id => p_qte_line_tbl(k).End_Customer_party_site_id
        ,p_acct_site_type => 'END_USER'
        ,p_cust_account_id => l_End_cust_account_id
	,x_cust_acct_site_id => l_ln_end_cust_acct_site
        ,x_return_status => l_return_status
 	,x_msg_count       => l_msg_count
 	,x_msg_data        => l_msg_data
        ,x_site_use_id  => l_line_tbl(i).End_Customer_site_use_id
       );

       IF l_line_tbl(i).End_Customer_site_use_id IS NULL THEN
           l_line_tbl(i).End_Customer_site_use_id := FND_API.G_MISS_NUM;
       END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: after cust_acct_site:l_line_tbl(i).End_Customer_site_use_id: '||l_line_tbl(i).End_Customer_site_use_id,1,'N');
aso_debug_pub.add('mapq line: after cust_acct_site:l_ln_end_cust_acct_site: '||l_ln_end_cust_acct_site,1,'N');
END IF;
       if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
         FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_END_SITE_AC_CRS');
         FND_MSG_PUB.ADD;
        END IF;
        raise FND_API.G_EXC_ERROR;
       END IF;

     l_line_tbl(i).End_Customer_Id := l_End_cust_account_id;

    END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: before Cust_Acct_Contact_Addr:l_End_cust_account_id: '||l_End_cust_account_id,1,'N');
END IF;

    ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
	p_api_version       =>  1.0,
	p_party_site_id     =>  p_qte_line_tbl(k).End_Customer_party_site_id,
	p_role_type    	    =>  'END_USER',
	p_cust_account_id   =>  l_End_cust_account_id,
	p_party_id          =>  p_qte_line_tbl(k).End_Customer_party_id,
	p_cust_account_site =>  l_ln_end_cust_acct_site,
	x_return_status     =>  l_return_status,
	x_msg_count         =>  l_msg_count,
	x_msg_data          =>  l_msg_data,
	x_cust_account_role_id      =>  l_line_tbl(i).End_Customer_contact_id);

       IF l_line_tbl(i).End_Customer_contact_id IS NULL THEN
           l_line_tbl(i).End_Customer_contact_id := FND_API.G_MISS_NUM;
       END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: after Cust_Acct_Contact_Addr:l_line_tbl(i).End_Customer_contact_id: '||l_line_tbl(i).End_Customer_contact_id,1,'N');
aso_debug_pub.add('mapq line: after Cust_Acct_Contact_Addr:l_line_tbl(i).End_Customer_id: '||l_line_tbl(i).End_Customer_id,1,'N');
END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;
-- end_cust

-- item type code in OC is different from OM and this will be defaulted by OM
--     l_line_tbl(i).item_type_code   := p_qte_line_tbl(k).item_type_code;
--l_line_tbl(i).line_type_id  := p_qte_line_tbl(k).quote_line_type_code;
--       l_line_tbl(i).calculate_price_flag   := 'N';

      l_line_tbl(i).line_type_id  := p_qte_line_tbl(k).order_line_type_id;

-- this piece of code should be in submit_quote. this is done because OM
-- does its defaulting only if it is g_miss and not if it is null

      IF l_line_tbl(i).line_type_id is NULL THEN
          l_line_tbl(i).line_type_id := FND_API.G_MISS_NUM;
      END IF;

      l_line_tbl(i).line_category_code := p_qte_line_tbl(k).line_category_code;
      l_line_tbl(i).org_id             :=  l_header_rec.org_id;

      IF p_qte_line_tbl(k).priced_price_list_id IS NOT NULL AND
         p_qte_line_tbl(k).priced_price_list_id <> FND_API.G_MISS_NUM THEN
            l_line_tbl(i).price_list_id      :=  p_qte_line_tbl(k).priced_price_list_id;
      ELSE
            l_line_tbl(i).price_list_id      :=  p_qte_line_tbl(k).price_list_id;
      END IF;

      IF l_line_tbl(i).price_list_id IS NULL THEN
          l_line_tbl(i).price_list_id := FND_API.G_MISS_NUM;
      END IF;

      l_line_tbl(i).unit_list_price
             := p_qte_line_tbl(k).line_list_price;
      l_line_tbl(i).unit_selling_price
             := p_qte_line_tbl(k).line_quote_price ;

--      l_line_tbl(i).ship_from_org_id := p_qte_line_tbl(k).organization_id;

-- item identifier is set to internal. OC does not use item numbers so it does
-- not matter what type we use.since we always use mtl_system_items i am using
-- 'INT'

  --ER 16531247

 /* commented for for Bug 21870706

   If  l_line_tbl(i).item_identifier_type is null then
      l_line_tbl(i).item_identifier_type  := 'INT';
            else
      l_line_tbl(i).ITEM_IDENTIFIER_TYPE := p_qte_line_tbl(k).ITEM_IDENTIFIER_TYPE;
      End if;

       If  l_line_tbl(i).ordered_item_id  is null then
      l_line_tbl(i).ordered_item_id       := l_line_tbl(i).inventory_item_id;
          else
       l_line_tbl(i).ORDERED_ITEM_ID:= p_qte_line_tbl(k).ORDERED_ITEM_ID;
      End If;

	  If  l_line_tbl(i).ordered_item  is not null then
           l_line_tbl(i).ORDERED_ITEM:= p_qte_line_tbl(k).ORDERED_ITEM;
      End If;
*/

-- start : code change done for Bug 21870706

   If  p_qte_line_tbl(k).ITEM_IDENTIFIER_TYPE is null Or
       p_qte_line_tbl(k).ITEM_IDENTIFIER_TYPE = FND_API.G_MISS_CHAR Then
       l_line_tbl(i).item_identifier_type  := 'INT';
   ElsIf p_qte_line_tbl(k).ITEM_IDENTIFIER_TYPE is not null and
       p_qte_line_tbl(k).ITEM_IDENTIFIER_TYPE <> FND_API.G_MISS_CHAR Then
      l_line_tbl(i).ITEM_IDENTIFIER_TYPE := p_qte_line_tbl(k).ITEM_IDENTIFIER_TYPE;
   End if;

   --Start : code chane done for Bug 22993140
/*
   If p_qte_line_tbl(k).ORDERED_ITEM_ID is null Or
      p_qte_line_tbl(k).ORDERED_ITEM_ID = FND_API.G_MISS_NUM Then
      l_line_tbl(i).ordered_item_id := p_qte_line_tbl(k).inventory_item_id;
   ElsIf p_qte_line_tbl(k).ORDERED_ITEM_ID is not null and
      p_qte_line_tbl(k).ORDERED_ITEM_ID <> FND_API.G_MISS_NUM Then
      l_line_tbl(i).ORDERED_ITEM_ID:= p_qte_line_tbl(k).ORDERED_ITEM_ID;
   End If;
*/
   If l_line_tbl(i).item_identifier_type = 'INT' Then
      l_line_tbl(i).ordered_item_id := p_qte_line_tbl(k).inventory_item_id;
   ElsIf l_line_tbl(i).item_identifier_type = 'CUST' Then

	  If p_qte_line_tbl(k).ORDERED_ITEM_ID is null Or
         p_qte_line_tbl(k).ORDERED_ITEM_ID = FND_API.G_MISS_NUM Then
         l_line_tbl(i).ordered_item_id := FND_API.G_MISS_NUM;
      ElsIf p_qte_line_tbl(k).ORDERED_ITEM_ID is not null and
         p_qte_line_tbl(k).ORDERED_ITEM_ID <> FND_API.G_MISS_NUM Then
         l_line_tbl(i).ORDERED_ITEM_ID:= p_qte_line_tbl(k).ORDERED_ITEM_ID;
      End If;
   Else
      l_line_tbl(i).ordered_item_id := FND_API.G_MISS_NUM;
   End if;
   --End : code chane done for Bug 22993140

   If p_qte_line_tbl(k).ORDERED_ITEM is not null and
      p_qte_line_tbl(k).ORDERED_ITEM <> FND_API.G_MISS_CHAR then
      l_line_tbl(i).ORDERED_ITEM:= p_qte_line_tbl(k).ORDERED_ITEM;
   End If;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('mapq line : l_line_tbl(i).item_identifier_type: '||l_line_tbl(i).item_identifier_type,1,'N');
      aso_debug_pub.add('mapq line : l_line_tbl(i).ordered_item_id: '||l_line_tbl(i).ordered_item_id,1,'N');
	  aso_debug_pub.add('mapq line : l_line_tbl(i).ordered_item: '||l_line_tbl(i).ordered_item,1,'N');
   END IF;
-- end : code change done for Bug 21870706

-- the operation code of the line is the same as shipment for create, delete
-- however, for update it is obtained from line directly.
-- for eg: if there is a payment line added then operation at shipment level
-- will be null however it will be update for the line
       IF l_header_rec.operation <> OE_GLOBALS.G_OPR_CREATE THEN
          l_line_tbl(i).header_id := p_qte_rec.order_id;
       END IF;

       IF p_operation = 'CREATE' THEN
	   l_line_tbl(i).operation := OE_GLOBALS.G_OPR_CREATE;
        ELSIF p_line_shipment_tbl(j).operation_code = 'CREATE' THEN
           l_line_tbl(i).operation := OE_GLOBALS.G_OPR_CREATE;
        ELSIF p_line_shipment_tbl(j).operation_code = 'DELETE' THEN
           l_line_tbl(i).operation := OE_GLOBALS.G_OPR_DELETE;
           l_line_tbl(i).line_id   := p_line_shipment_tbl(j).order_line_id;
        ELSIF  p_qte_line_tbl(k).operation_code = 'UPDATE' THEN
           l_line_tbl(i).operation := OE_GLOBALS.G_OPR_UPDATE;
           l_line_tbl(i).line_id   := p_line_shipment_tbl(j).order_line_id;
        ELSIF  p_qte_line_tbl(k).operation_code = 'CREATE' THEN
           l_line_tbl(i).operation := OE_GLOBALS.G_OPR_CREATE;
       END IF;

FOR l in 1..p_qte_line_dtl_tbl.count LOOP


      IF  (p_qte_line_dtl_tbl(l).qte_line_index = k) THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('in quote line details',1,'N');
END IF;
	l_line_tbl(i).service_duration:=p_qte_line_dtl_tbl(l).service_duration;
	l_line_tbl(i).service_period  := p_qte_line_dtl_tbl(l).service_period;
	l_line_tbl(i).service_start_date:= p_qte_line_tbl(k).start_date_active;
	l_line_tbl(i).service_end_date  := p_qte_line_tbl(k).end_date_active;
	l_line_tbl(i).service_coterminate_flag
			   := p_qte_line_dtl_tbl(l).service_coterminate_flag;
	l_line_tbl(i).unit_list_percent
			   := p_qte_line_dtl_tbl(l).service_unit_list_percent;
	l_line_tbl(i).unit_selling_percent
			:= p_qte_line_dtl_tbl(l).service_unit_selling_percent;
	l_line_tbl(i).unit_percent_base_price
			:= p_qte_line_dtl_tbl(l).unit_percent_base_price;
	l_line_tbl(i).service_reference_type_code
			:= p_qte_line_dtl_tbl(l).service_ref_type_code;
	l_line_tbl(i).service_reference_line_id
			:= p_qte_line_dtl_tbl(l).service_ref_line_id;
	l_line_tbl(i).service_reference_system_id
			:= p_qte_line_dtl_tbl(l).service_ref_system_id;
--bug8222651
               begin
		select name into name1 from csi_systems_vl  where system_id = p_qte_line_dtl_tbl(l).service_ref_system_id;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN NULL ;
    	l_line_tbl(i).service_reference_system := name1;
                end;

	l_line_tbl(i).service_ref_order_number
			:= p_qte_line_dtl_tbl(l).service_ref_order_number;
	l_line_tbl(i).service_ref_line_number
			:= p_qte_line_dtl_tbl(l).service_ref_line_number;
	l_line_tbl(i).service_ref_shipment_number
			:= p_qte_line_dtl_tbl(l).service_ref_shipment_numb;
	l_line_tbl(i).service_ref_option_number
			:= p_qte_line_dtl_tbl(l).service_ref_option_numb;
     IF p_qte_line_dtl_tbl(l).service_ref_type_code = 'QUOTE' THEN
        l_line_tbl(i).service_reference_type_code := 'ORDER';

	   -- line_id should be G_MISS_NUM. bug 1399679
	   l_line_tbl(i).service_reference_line_id := FND_API.G_MISS_NUM;
        l_line_tbl(i).service_line_index
		:=  ASO_ORDER_INT.Service_Index (
     			p_qte_line_dtl_tbl(l).quote_line_id    ,
     			p_qte_line_dtl_tbl(l).qte_line_index ,
                        P_Line_Rltship_Tbl,
     			p_line_shipment_tbl);
     END IF;

	IF p_qte_line_dtl_tbl(l).service_ref_type_code = 'ORDER' THEN
	   IF  p_qte_line_dtl_tbl(l).service_ref_line_id IS NULL OR
		   p_qte_line_dtl_tbl(l).service_ref_line_id = FND_API.G_MISS_NUM THEN
		  l_line_tbl(i).service_line_index :=  p_qte_line_dtl_tbl(l).service_ref_qte_line_index;
        END IF;
	END IF;


     l_line_tbl(i).reference_header_id
			:= p_qte_line_dtl_tbl(l).return_ref_header_id;
	l_line_tbl(i).reference_line_id
			:= p_qte_line_dtl_tbl(l).return_ref_line_id;
	l_line_tbl(i).reference_type
			:= p_qte_line_dtl_tbl(l).return_ref_type;

    IF (p_qte_line_dtl_tbl(l).return_attribute1 is null or
       p_qte_line_dtl_tbl(l).return_attribute1 = FND_API.G_MISS_CHAR) AND
        (p_qte_line_dtl_tbl(l).return_ref_header_id is not null AND
         p_qte_line_dtl_tbl(l).return_ref_header_id <> FND_API.G_MISS_NUM) Then

	  l_line_tbl(i).return_attribute1
			:= p_qte_line_dtl_tbl(l).return_ref_header_id;
    ELSE
      l_line_tbl(i).return_attribute1
			:= p_qte_line_dtl_tbl(l).return_attribute1;
    END IF;

	l_line_tbl(i).return_attribute10
			:= p_qte_line_dtl_tbl(l).return_attribute10;
	l_line_tbl(i).return_attribute11
			:= p_qte_line_dtl_tbl(l).return_attribute11;
	l_line_tbl(i).return_attribute12
			:= p_qte_line_dtl_tbl(l).return_attribute12;
	l_line_tbl(i).return_attribute13
			:= p_qte_line_dtl_tbl(l).return_attribute13;
	l_line_tbl(i).return_attribute14
			:= p_qte_line_dtl_tbl(l).return_attribute14;
	l_line_tbl(i).return_attribute15
			:= p_qte_line_dtl_tbl(l).return_attribute15;

    IF (p_qte_line_dtl_tbl(l).return_attribute2 is null or
       p_qte_line_dtl_tbl(l).return_attribute2 = FND_API.G_MISS_CHAR) AND
        (p_qte_line_dtl_tbl(l).return_ref_line_id is not null AND
         p_qte_line_dtl_tbl(l).return_ref_line_id <> FND_API.G_MISS_NUM) Then

	  l_line_tbl(i).return_attribute2
			:= p_qte_line_dtl_tbl(l).return_ref_line_id;
    ELSE
      l_line_tbl(i).return_attribute2
			:= p_qte_line_dtl_tbl(l).return_attribute2;
    END IF;

	l_line_tbl(i).return_attribute3
			:= p_qte_line_dtl_tbl(l).return_attribute3;
	l_line_tbl(i).return_attribute4
			:= p_qte_line_dtl_tbl(l).return_attribute4;
	l_line_tbl(i).return_attribute5
			:= p_qte_line_dtl_tbl(l).return_attribute5;
	l_line_tbl(i).return_attribute6
			:= p_qte_line_dtl_tbl(l).return_attribute6;
	l_line_tbl(i).return_attribute7
			:= p_qte_line_dtl_tbl(l).return_attribute7;
	l_line_tbl(i).return_attribute8
			:= p_qte_line_dtl_tbl(l).return_attribute8;
	l_line_tbl(i).return_attribute9
			:= p_qte_line_dtl_tbl(l).return_attribute9;

    IF upper(p_qte_line_dtl_tbl(l).return_ref_type) = 'SALES ORDER' OR
       upper(p_qte_line_dtl_tbl(l).return_ref_type) = 'ORDER' THEN
        l_line_tbl(i).return_context
                := 'ORDER';
    ELSE
     l_line_tbl(i).return_context
               := p_qte_line_dtl_tbl(l).return_attribute_category;
    END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_ret_reason_code_prof: '||l_ret_reason_code_prof,1,'N');
END IF;

        IF p_qte_line_tbl(k).line_category_code = 'RETURN' THEN

            --  Default return reason code from profile
            IF (p_qte_line_dtl_tbl(l).return_reason_code IS NULL OR
                p_qte_line_dtl_tbl(l).return_reason_code = FND_API.G_MISS_CHAR) THEN
                    IF(l_ret_reason_code_prof IS NULL) THEN
                        l_return_status := FND_API.G_RET_STS_ERROR;
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                            FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                            FND_MESSAGE.Set_Token('COLUMN', 'RETURN_REASON_CODE', FALSE);
                            FND_MSG_PUB.ADD;
                          RAISE FND_API.G_EXC_ERROR;
                        END IF;
                    ELSE
                          l_line_tbl(i).return_reason_code := l_ret_reason_code_prof;
                    END IF;
             ELSE
                    l_line_tbl(i).return_reason_code
                              := p_qte_line_dtl_tbl(l).return_reason_code;

            END IF;

        END IF;

-- for configuration fields

		l_line_tbl(i).component_code
			:= p_qte_line_dtl_tbl(l).component_code;
/* FOR BUG 6737851 , added OR condition( p_qte_line_tbl(k).item_type_code = 'ATO' IN THE FOLLOWING IF CLAUSE)  */
     IF p_qte_line_tbl(k).item_type_code = 'MDL' OR  p_qte_line_tbl(k).item_type_code = 'ATO' THEN
        l_line_tbl(i).top_model_line_index := i ; -- the index is same as the line index for a model item 1;
        l_line_tbl(i).link_to_line_index   := null;
		--Commented for bug21224933
       -- l_line_tbl(i).config_header_id
                      -- :=  p_qte_line_dtl_tbl(l).config_header_id;
       -- l_line_tbl(i).config_rev_nbr
                      -- := p_qte_line_dtl_tbl(l).config_revision_num;
        l_line_tbl(i).configuration_id
                       :=  p_qte_line_dtl_tbl(l).config_item_id;
        l_line_tbl(i).sort_order
                       := p_qte_line_dtl_tbl(l).bom_sort_order;

      -- Recurring charge Change
      l_line_tbl(i).charge_periodicity_code := null;


     END IF;

     IF p_qte_line_tbl(k).item_type_code = 'CFG' THEN

	 -- Recurring charge Change
      l_line_tbl(i).charge_periodicity_code := p_qte_line_tbl(k).charge_periodicity_code;

--Commented for bug21224933
      --  l_line_tbl(i).config_header_id
                      --  :=  p_qte_line_dtl_tbl(l).config_header_id;
       -- l_line_tbl(i).config_rev_nbr
                       -- := p_qte_line_dtl_tbl(l).config_revision_num;
        l_line_tbl(i).configuration_id
                       :=  p_qte_line_dtl_tbl(l).config_item_id;
        l_line_tbl(i).sort_order
                       := p_qte_line_dtl_tbl(l).bom_sort_order;

     option_item := k;
	FOR count_1 in 1..p_Line_Rltship_TBL.count LOOP
		 FOR count_2 in 1..p_Line_Rltship_TBL.count LOOP
 		    if ( p_Line_Rltship_TBL(count_2).related_qte_line_index = option_item) then
  		    parent := p_Line_Rltship_TBL(count_2).qte_line_index;
	            EXIT;
 		    end if;
		 END LOOP;
  		 if parent = option_item then
  		   exit;
 	         else
  		   option_item := parent;
 	         end if;
	END LOOP;

-- figure OUT NOCOPY /* file.sql.39 change */ the shipment line index for the corresponding qte line index.
-- this will be the index to the order line.
FOR count_2 in 1..p_line_shipment_tbl.count LOOP
   if p_line_shipment_tbl(count_2).qte_line_index = parent THEN
      l_line_tbl(i).top_model_line_index     := count_2;
      exit;
   end if;
END LOOP;

option_item := k;
parent := option_item;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('p_Line_Rltship_TBL.count is '||p_Line_Rltship_TBL.count,1 ,'N');
END IF;

		 FOR count_2 in 1..p_Line_Rltship_TBL.count LOOP
 		    if ( p_Line_Rltship_TBL(count_2).related_qte_line_index
                = option_item and p_Line_Rltship_TBL(count_2).relationship_type_code = 'CONFIG') then
  		    parent := p_Line_Rltship_TBL(count_2).qte_line_index;
	            EXIT;
 		    end if;
            END LOOP;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('parent item is '||parent,1,'N');
END IF;

 IF  (parent <> option_item) THEN
-- figure OUT NOCOPY /* file.sql.39 change */ the shipment line index for the corresponding qte line index.
-- this will be the index to the order line.
	FOR count_2 in 1..p_line_shipment_tbl.count LOOP
 	  if p_line_shipment_tbl(count_2).qte_line_index = parent THEN
  	     l_line_tbl(i).link_to_line_index   := count_2;
  	    exit;
 	  end if;
	END LOOP;
 END IF;

END IF;   -- configuration fields

END IF;
END LOOP;  -- line details

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_ret_reason_code_prof: '||l_ret_reason_code_prof,1,'N');
END IF;

     IF p_qte_line_tbl(k).line_category_code = 'RETURN' THEN
         --  Default return reason code from profile
         IF (l_line_tbl(i).return_reason_code IS NULL OR
             l_line_tbl(i).return_reason_code = FND_API.G_MISS_CHAR) THEN
                 IF(l_ret_reason_code_prof IS NULL) THEN
                     l_return_status := FND_API.G_RET_STS_ERROR;
                     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                         FND_MESSAGE.Set_Name('ASO', 'API_INVALID_ID');
                         FND_MESSAGE.Set_Token('COLUMN', 'RETURN_REASON_CODE', FALSE);
                         FND_MSG_PUB.ADD;
                          RAISE FND_API.G_EXC_ERROR;
                     END IF;
                 ELSE
                     l_line_tbl(i).return_reason_code := l_ret_reason_code_prof;
                 END IF;

         END IF;

     END IF;

     IF (NVL(l_om_defaulting_prof, 'N') = 'Y') THEN
        IF p_line_shipment_tbl(j).fob_code IS NULL THEN
           l_line_tbl(i).fob_point_code := FND_API.G_MISS_CHAR;
        ELSE -- 3465720
           l_line_tbl(i).fob_point_code := p_line_shipment_tbl(j).fob_code;
        END IF;
        IF p_line_shipment_tbl(j).freight_terms_code IS NULL THEN
           l_line_tbl(i).freight_terms_code := FND_API.G_MISS_CHAR;
        ELSE -- 3465720
           l_line_tbl(i).freight_terms_code := p_line_shipment_tbl(j).freight_terms_code;
        END IF;
        IF p_line_shipment_tbl(j).shipment_priority_code IS NULL THEN
           l_line_tbl(i).shipment_priority_code := FND_API.G_MISS_CHAR;
        ELSE -- 3465720
           l_line_tbl(i).shipment_priority_code := p_line_shipment_tbl(j).shipment_priority_code;
        END IF;
        IF p_line_shipment_tbl(j).ship_method_code IS NULL THEN
           l_line_tbl(i).shipping_method_code := FND_API.G_MISS_CHAR;
        ELSE -- 3582285
           l_line_tbl(i).shipping_method_code := p_line_shipment_tbl(j).ship_method_code;
        END IF;
     ELSE
	   l_line_tbl(i).fob_point_code := p_line_shipment_tbl(j).fob_code;
	   l_line_tbl(i).freight_terms_code
			:= p_line_shipment_tbl(j).freight_terms_code;
	   l_line_tbl(i).shipment_priority_code
			:= p_line_shipment_tbl(j).shipment_priority_code;
	   l_line_tbl(i).shipping_method_code
			:= p_line_shipment_tbl(j).ship_method_code;
     END IF;

	l_line_tbl(i).freight_carrier_code
			:= p_line_shipment_tbl(j).freight_carrier_code;
--bug 1921958
    IF (p_line_shipment_tbl(j).shipping_instructions IS NULL) AND
       (l_om_defaulting_prof = 'Y') THEN
	   l_line_tbl(i).shipping_instructions
			:= FND_API.G_MISS_CHAR;
    ELSE
	   l_line_tbl(i).shipping_instructions
			:= rtrim(p_line_shipment_tbl(j).shipping_instructions);
    END IF;

    IF (p_line_shipment_tbl(j).packing_instructions IS NULL) AND
       (l_om_defaulting_prof = 'Y') THEN
	   l_line_tbl(i).packing_instructions
			:= FND_API.G_MISS_CHAR;
    ELSE
	l_line_tbl(i).packing_instructions
			:= rtrim(p_line_shipment_tbl(j).packing_instructions);
    END IF;
--bug 1921958
     IF p_line_shipment_tbl(j).schedule_ship_date IS NOT NULL THEN
       l_line_tbl(i).schedule_ship_date
			:= p_line_shipment_tbl(j).schedule_ship_date;
     END IF;
	IF p_line_shipment_tbl(j).request_date IS NOT NULL THEN
       l_line_tbl(i).request_date
         		:= p_line_shipment_tbl(j).request_date;
     END IF;
-- bug 1783862 hyang
	IF p_line_shipment_tbl(j).promise_date IS NOT NULL THEN
       l_line_tbl(i).promise_date
         		:= p_line_shipment_tbl(j).promise_date;
     END IF;
-- bug 1783862 hyang
	l_line_tbl(i).ordered_quantity      := p_line_shipment_tbl(j).quantity;
	l_line_tbl(i).order_quantity_uom    :=  p_qte_line_tbl(k).uom_code;

-- bug 4916969
    IF (p_line_shipment_tbl(j).demand_class_code is not null and p_line_shipment_tbl(j).demand_class_code <> fnd_api.g_miss_char) then
       l_line_tbl(i).demand_class_code := p_line_shipment_tbl(j).demand_class_code;
    end if;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('p_line_shipment_tbl(j).Ship_From_Org_Id: '||p_line_shipment_tbl(j).Ship_From_Org_Id,1,'N');
END IF;

     IF p_line_shipment_tbl(j).Ship_From_Org_Id IS NOT NULL AND
        p_line_shipment_tbl(j).Ship_From_Org_Id <> FND_API.G_MISS_NUM THEN
          l_line_tbl(i).ship_from_org_id := p_line_shipment_tbl(j).Ship_From_Org_Id;
     END IF;

     IF p_line_shipment_tbl(j).ship_to_cust_account_id <> FND_API.G_MISS_NUM AND
        p_line_shipment_tbl(j).ship_to_cust_account_id IS NOT NULL AND
        p_line_shipment_tbl(j).ship_to_cust_account_id <> l_cust_account_id THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('before cust_acct_reltn:p_sold_to_cust_account: '||l_cust_account_id,1,'N');
aso_debug_pub.add('before cust_acct_reltn:p_related_cust_account: '||p_line_shipment_tbl(j).ship_to_cust_account_id,1,'N');
END IF;
        ASO_CHECK_TCA_PVT.Cust_acct_Relationship (
          p_api_version => 1.0,
          p_sold_to_cust_account => l_cust_account_id,
          p_related_cust_account =>p_line_shipment_tbl(j).ship_to_cust_account_id,
          p_relationship_type => 'SHIP_TO',
          x_return_status    => l_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => l_msg_data
        );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after cust_acct_reltn:l_return_status: '||l_return_status,1,'N');
END IF;

          IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

     END IF;

     IF p_line_shipment_tbl(j).ship_to_cust_account_id is not NULL AND
        p_line_shipment_tbl(j).ship_to_cust_account_id <> FND_API.G_MISS_NUM THEN
         l_ship_cust_account_id := p_line_shipment_tbl(j).ship_to_cust_account_id;
     ELSE
         l_ship_cust_account_id := l_header_rec.sold_to_org_id;
     END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: before cust_acct_site:l_ship_cust_account_id: '||l_ship_cust_account_id,1,'N');
aso_debug_pub.add('p_line_shipment_tbl(j).ship_to_party_site_id: '||p_line_shipment_tbl(j).ship_to_party_site_id,1,'N');
END IF;
	IF p_line_shipment_tbl(j).ship_to_party_site_id is not NULL AND
        p_line_shipment_tbl(j).ship_to_party_site_id <> FND_API.G_MISS_NUM THEN

          ASO_CHECK_TCA_PVT.Customer_Account_Site
         (
  	    p_api_version     => 1.0
        ,p_party_site_id => p_line_shipment_tbl(j).ship_to_party_site_id
        ,p_acct_site_type => 'SHIP_TO'
        ,p_cust_account_id => l_ship_cust_account_id
	   ,x_cust_acct_site_id => l_ln_shp_cust_acct_site
        ,x_return_status => l_return_status
        ,x_msg_count       => l_msg_count
        ,x_msg_data        => l_msg_data
        ,x_site_use_id  => l_line_tbl(i).ship_to_org_id
         );

       IF l_line_tbl(i).ship_to_org_id IS NULL THEN
           l_line_tbl(i).ship_to_org_id := FND_API.G_MISS_NUM;
       END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: after cust_acct_site:l_line_tbl(i).ship_to_org_id: '||l_line_tbl(i).ship_to_org_id,1,'N');
aso_debug_pub.add('mapq line: after cust_acct_site:l_ln_shp_cust_acct_site: '||l_ln_shp_cust_acct_site,1,'N');
END IF;
       if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
         FND_MESSAGE.Set_Name('ASO', 'ASO_VALIDATE_INV_SITE_AC_CRS');
         FND_MSG_PUB.ADD;
        END IF;
        raise FND_API.G_EXC_ERROR;
       END IF;

      END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('p_line_shipment_tbl(j).ship_to_party_id: '||p_line_shipment_tbl(j).ship_to_party_id,1,'N');
aso_debug_pub.add('p_line_shipment_tbl(j).ship_to_party_site_id: '||p_line_shipment_tbl(j).ship_to_party_site_id,1,'N');
aso_debug_pub.add('mapq line: before Cust_Acct_Contact_Addr:l_ship_cust_account_id: '||l_ship_cust_account_id,1,'N');
END IF;

    ASO_CHECK_TCA_PVT.Cust_Acct_Contact_Addr(
     p_api_version       =>  1.0,
     p_party_site_id     =>  p_line_shipment_tbl(j).ship_to_party_site_id,
     p_role_type         =>  'SHIP_TO',
     p_cust_account_id   =>  l_ship_cust_account_id,
     p_party_id          =>  p_line_shipment_tbl(j).ship_to_party_id,
     p_cust_account_site =>  l_ln_shp_cust_acct_site,
     x_return_status     =>  l_return_status,
     x_msg_count         =>  l_msg_count,
     x_msg_data          =>  l_msg_data,
     x_cust_account_role_id      =>  l_line_tbl(i).ship_to_contact_id);

       IF l_line_tbl(i).ship_to_contact_id IS NULL THEN
           l_line_tbl(i).ship_to_contact_id := FND_API.G_MISS_NUM;
       END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapq line: after Cust_Acct_Contact_Addr:l_line_tbl(i).ship_to_contact_id: '||l_line_tbl(i).ship_to_contact_id,1,'N');
END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
    END IF;

    l_line_tbl(i).source_document_id := p_line_shipment_tbl(j).quote_header_id;
    l_line_tbl(i).source_document_line_id
					:= p_line_shipment_tbl(j).shipment_id;
    l_line_tbl(i).source_document_type_id
                           := l_header_rec.source_document_type_id;
   -- l_line_tbl(i).orig_sys_document_ref := l_header_rec.orig_sys_document_ref;

   -- Code change done for Bug 21237538 added for charges

     aso_debug_pub.add('mapq line: Bug 21237538  p_qte_line_tbl(k).orig_sys_document_ref: '||p_qte_line_tbl(k).orig_sys_document_ref,1,'N');

    If p_qte_line_tbl(k).orig_sys_document_ref is not null and
       p_qte_line_tbl(k).orig_sys_document_ref <> FND_API.G_MISS_CHAR then
    l_line_tbl(i).orig_sys_document_ref := p_qte_line_tbl(k).orig_sys_document_ref;
	ELSE
	l_line_tbl(i).orig_sys_document_ref := l_header_rec.orig_sys_document_ref;
    End If;


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_line_tbl(i).orig_sys_document_ref: '||l_line_tbl(i).orig_sys_document_ref,1,'N');
END IF;

        IF p_qte_line_tbl(k).ui_line_number IS NOT NULL AND
           p_qte_line_tbl(k).ui_line_number <> FND_API.G_MISS_CHAR THEN
            l_line_tbl(i).orig_sys_line_ref := p_qte_line_tbl(k).ui_line_number;

        ELSIF p_qte_line_tbl(k).line_number IS NOT NULL
          AND p_qte_line_tbl(k).line_number <> FND_API.G_MISS_NUM THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('p_qte_line_tbl(k).line_number: '||p_qte_line_tbl(k).line_number,1,'N');
END IF;

		  l_line_tbl(i).orig_sys_line_ref := to_char(p_qte_line_tbl(k).line_number);

	   END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_line_tbl(i).orig_sys_line_ref: '||l_line_tbl(i).orig_sys_line_ref,1,'N');
END IF;

-- must have both the index values for create

   l_ln_total_tax_amount := 0;

   FOR l in 1..p_line_tax_detail_tbl.count LOOP

    IF (p_line_tax_detail_tbl(l).qte_line_index = k AND p_line_tax_detail_tbl(l).shipment_index = j) then

  	  l_line_tbl(i).tax_exempt_flag        := p_line_tax_detail_tbl(l).tax_exempt_flag;

         /*IF nvl(p_line_tax_detail_tbl(l).tax_exempt_flag,'S') = 'E' THEN clause is created for bug#6781917*/
	  IF nvl(p_line_tax_detail_tbl(l).tax_exempt_flag,'S') = 'E' THEN

  	     l_line_tbl(i).tax_exempt_number      := p_line_tax_detail_tbl(l).tax_exempt_number;
  	     --l_line_tbl(i).tax_exempt_reason_code := p_line_tax_detail_tbl(l).tax_exempt_reason_code;

	     IF l_line_tbl(i).tax_exempt_reason_code IS NULL THEN
		OPEN  C_GET_TAX_REASONCODE(p_line_tax_detail_tbl(l).quote_header_id);
	        FETCH C_GET_TAX_REASONCODE INTO l_line_tbl(i).tax_exempt_reason_code;
	        CLOSE C_GET_TAX_REASONCODE;
             END IF;
          END IF;

     --l_line_tbl(i).tax_point_code         := p_line_tax_detail_tbl(l).tax_group_code;
  	  l_line_tbl(i).tax_date               := p_line_tax_detail_tbl(l).tax_date;
  	  l_line_tbl(i).tax_rate               := p_line_tax_detail_tbl(l).tax_rate;
     --l_line_tbl(i).tax_value              := p_line_tax_detail_tbl(l).tax_amount;
  	--l_line_tbl(i).tax_rate_id            := p_line_tax_detail_tbl(l).tax_rate_id;

	   --aso_debug_pub.add('rassharm classificationl_line_tbl('||i||').tax_code: '             ||p_line_tax_detail_tbl(l).tax_classification_code,1,'N');

	  l_line_tbl(i).tax_code               := p_line_tax_detail_tbl(l).tax_classification_code;  -- rassharm gsi

       if nvl(p_line_tax_detail_tbl(l).tax_inclusive_flag, 'N') <> 'Y' then
	     l_ln_total_tax_amount := l_ln_total_tax_amount + nvl( p_line_tax_detail_tbl(l).tax_amount,0);
	  end if;

       --Pass the tax records in the OM price adjustment table
       l_line_adj_tbl_count := l_Line_Adj_tbl.count;

       l_Line_Adj_tbl(l_line_adj_tbl_count + 1).price_adjustment_id := FND_API.G_MISS_NUM;
       --l_Line_Adj_tbl(l_line_adj_tbl_count + 1).header_id := FND_API.G_MISS_NUM;
       --l_Line_Adj_tbl(l_line_adj_tbl_count + 1).line_id := FND_API.G_MISS_NUM;
       l_Line_Adj_tbl(l_line_adj_tbl_count + 1).line_index := i;
       --l_Line_adj_rec.tax_code := l_tax_rate_code; --This is for 11i
       l_Line_Adj_tbl(l_line_adj_tbl_count + 1).tax_rate_id := p_line_tax_detail_tbl(l).tax_rate_id;  -- This is for R12

       l_Line_Adj_tbl(l_line_adj_tbl_count + 1).operand := p_line_tax_detail_tbl(l).tax_rate;
       l_Line_Adj_tbl(l_line_adj_tbl_count + 1).adjusted_amount := p_line_tax_detail_tbl(l).tax_amount;
       l_Line_Adj_tbl(l_line_adj_tbl_count + 1).automatic_flag := 'N';
       l_Line_Adj_tbl(l_line_adj_tbl_count + 1).list_line_type_code := 'TAX';
       l_Line_Adj_tbl(l_line_adj_tbl_count + 1).arithmetic_operator := 'AMT';
       l_Line_Adj_tbl(l_line_adj_tbl_count + 1).operation := OE_GLOBALS.g_opr_create;

   if aso_debug_pub.g_debug_flag = 'Y' then

       aso_debug_pub.add('l_line_tbl('||i||').tax_exempt_flag:        '||l_line_tbl(i).tax_exempt_flag,1,'N');
       aso_debug_pub.add('l_line_tbl('||i||').tax_exempt_number:      '||l_line_tbl(i).tax_exempt_number,1,'N');
       aso_debug_pub.add('l_line_tbl('||i||').tax_exempt_reason_code: '||l_line_tbl(i).tax_exempt_reason_code,1,'N');
       aso_debug_pub.add('l_line_tbl('||i||').tax_date: '              ||l_line_tbl(i).tax_date,1,'N');
       aso_debug_pub.add('l_line_tbl('||i||').tax_rate: '              ||l_line_tbl(i).tax_rate,1,'N');
       aso_debug_pub.add('l_line_tbl('||i||').tax_value: '             ||l_line_tbl(i).tax_value,1,'N');
         aso_debug_pub.add('l_line_tbl('||i||').tax_code: '             ||l_line_tbl(i).tax_code,1,'N');

   end if;

/*
       if aso_debug_pub.g_debug_flag = 'Y' then

           aso_debug_pub.add('l_Line_Adj_tbl('||l_line_adj_tbl_count + 1||').price_adjustment_id: '||l_Line_Adj_tbl(l_line_adj_tbl_count + 1).price_adjustment_id,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||l_line_adj_tbl_count + 1||').line_index:          '||l_Line_Adj_tbl(l_line_adj_tbl_count + 1).line_index,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||l_line_adj_tbl_count + 1||').tax_rate_id:         '||l_Line_Adj_tbl(l_line_adj_tbl_count + 1).tax_rate_id,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||l_line_adj_tbl_count + 1||').operand:             '||l_Line_Adj_tbl(l_line_adj_tbl_count + 1).operand,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||l_line_adj_tbl_count + 1||').adjusted_amount:     '||l_Line_Adj_tbl(l_line_adj_tbl_count + 1).adjusted_amount,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||l_line_adj_tbl_count + 1||').automatic_flag:      '||l_Line_Adj_tbl(l_line_adj_tbl_count + 1).automatic_flag,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||l_line_adj_tbl_count + 1||').list_line_type_code: '||l_Line_Adj_tbl(l_line_adj_tbl_count + 1).list_line_type_code,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||l_line_adj_tbl_count + 1||').arithmetic_operator: '||l_Line_Adj_tbl(l_line_adj_tbl_count + 1).arithmetic_operator,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||l_line_adj_tbl_count + 1||').operation:           '||l_Line_Adj_tbl(l_line_adj_tbl_count + 1).operation,1,'N');

       end if;

*/
    END IF;

   END LOOP;

   l_line_tbl(i).tax_value := l_ln_total_tax_amount;

   if aso_debug_pub.g_debug_flag = 'Y' then

       aso_debug_pub.add('l_line_tbl('||i||').tax_exempt_flag:        '||l_line_tbl(i).tax_exempt_flag,1,'N');
       aso_debug_pub.add('l_line_tbl('||i||').tax_exempt_number:      '||l_line_tbl(i).tax_exempt_number,1,'N');
       aso_debug_pub.add('l_line_tbl('||i||').tax_exempt_reason_code: '||l_line_tbl(i).tax_exempt_reason_code,1,'N');
       aso_debug_pub.add('l_line_tbl('||i||').tax_date: '              ||l_line_tbl(i).tax_date,1,'N');
       aso_debug_pub.add('l_line_tbl('||i||').tax_rate: '              ||l_line_tbl(i).tax_rate,1,'N');
       aso_debug_pub.add('l_line_tbl('||i||').tax_value: '             ||l_line_tbl(i).tax_value,1,'N');


       for p in 1..l_Line_Adj_tbl.count loop

           aso_debug_pub.add('l_Line_Adj_tbl('||p||').price_adjustment_id: '||l_Line_Adj_tbl(p).price_adjustment_id,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||p||').line_index:          '||l_Line_Adj_tbl(p).line_index,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||p||').tax_rate_id:         '||l_Line_Adj_tbl(p).tax_rate_id,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||p||').operand:             '||l_Line_Adj_tbl(p).operand,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||p||').adjusted_amount:     '||l_Line_Adj_tbl(p).adjusted_amount,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||p||').automatic_flag:      '||l_Line_Adj_tbl(p).automatic_flag,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||p||').list_line_type_code: '||l_Line_Adj_tbl(p).list_line_type_code,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||p||').arithmetic_operator: '||l_Line_Adj_tbl(p).arithmetic_operator,1,'N');
           aso_debug_pub.add('l_Line_Adj_tbl('||p||').operation:           '||l_Line_Adj_tbl(p).operation,1,'N');

       end loop;

   end if;
  -- tax

     IF (l_line_tbl(i).top_model_line_index is NULL OR
        l_line_tbl(i).top_model_line_index = FND_API.G_MISS_NUM) AND
        l_reservation_lvl_prof = 'AUTO_ORDER' THEN

	  -- initialize for each line
           l_line_scheduling_level :=  ' ';
	   IF l_line_tbl(i).line_type_id is not null AND
	      l_line_tbl(i).line_type_id <> FND_API.G_MISS_NUM then
		 OPEN scheduling_level_cur(l_line_tbl(i).line_type_id);
		 FETCH scheduling_level_cur INTO l_line_scheduling_level;
		 CLOSE scheduling_level_cur;
        END IF;
		 IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('l_line_tbl(i).line_type_id = ' ||
                              l_line_tbl(i).line_type_id,1,'N');

           aso_debug_pub.add('l_order_scheduling_level = ' ||
                              l_order_scheduling_level,1,'N');
           aso_debug_pub.add('l_line_scheduling_level = ' ||
                              l_line_scheduling_level,1,'N');
           END IF;

-- a value of 'TWO' for scheduling level means that the transaction type
-- doesn't allow reservations.
        IF l_order_scheduling_level <> 'TWO' AND
           l_line_scheduling_level <> 'TWO' then
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('setting schedule action to reserve',1,'N');
		END IF;
           l_line_tbl(i).schedule_action_code
                := OE_ORDER_SCH_UTIL.OESCH_ACT_RESERVE;
        END IF;
     END IF;  -- reservation

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Map_Quote_to_order: p_calculate_price_flag : '||p_calculate_price_flag,1,'Y');
       aso_debug_pub.add('Map_Quote_to_order: PRICING_LINE_TYPE_INDICATOR: '||p_qte_line_tbl(k).PRICING_LINE_TYPE_INDICATOR,1,'Y');
     END IF;

   IF (p_calculate_price_flag = FND_API.G_FALSE) or (p_calculate_price_flag = 'N')  THEN  -- added for Bug 22248123
        l_line_tbl(i).calculate_price_flag := 'N';
        l_line_tbl(i).pricing_quantity_uom := l_line_tbl(i).order_quantity_uom;
        l_line_tbl(i).pricing_quantity := l_line_tbl(i).ordered_quantity;
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('l_line_tbl(i).pricing_quantity_uom: '||l_line_tbl(i).pricing_quantity_uom,1,'N');
          aso_debug_pub.add('l_line_tbl(i).pricing_quantity: '||l_line_tbl(i).pricing_quantity,1,'N');
		END IF;
   ElsIf p_calculate_price_flag = 'P' THEN -- added for Bug 22248123
        l_line_tbl(i).calculate_price_flag := 'P';
	    l_line_tbl(i).pricing_quantity_uom := l_line_tbl(i).order_quantity_uom;
        l_line_tbl(i).pricing_quantity := l_line_tbl(i).ordered_quantity;
   ELSE
       -- Start bug fix 23136741
         if (nvl(p_qte_line_tbl(k).PRICING_LINE_TYPE_INDICATOR,'S')='F') then
          l_line_tbl(i).calculate_price_flag := 'P';
        else
          l_line_tbl(i).calculate_price_flag := 'Y';
	end if;
	-- End bug fix 23136741
   END IF;  -- pricing



IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Map_Quote_to_order: l_line_tbl(i).calculate_price_flag: '||l_line_tbl(i).calculate_price_flag,1,'Y');
aso_debug_pub.add('before line price att',1,'Y');
END IF;

-- pricing attributes

 map_line_price_att(
     p_line_price_attributes_tbl  =>    p_line_price_attributes_tbl,
     p_line_index  =>  i,
     p_qte_line_index =>  k,
     p_operation   =>   l_line_tbl(i).operation,
     x_line_price_att_tbl  =>  l_line_price_att_tbl
     );

l_line_price_adj_rltship_tbl := P_Line_Price_Adj_rltship_Tbl;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after line price att:l_line_price_att_tbl.count: '||l_line_price_att_tbl.count,1,'N');
aso_debug_pub.add('before map_ln_adj:l_Line_Price_Adj_rltship_Tbl.count: '||l_Line_Price_Adj_rltship_Tbl.count,1,'N');
END IF;

  map_line_price_adj(
     p_line_price_adj_tbl  =>   p_line_price_adj_tbl,
     p_line_price_adj_attr_tbl  => p_line_price_adj_attr_tbl,
     p_line_index  =>  i,
     p_qte_line_index =>  k,
     p_operation   =>   l_line_tbl(i).operation,
     x_line_adj_tbl  =>  l_line_adj_tbl,
     x_line_adj_att_tbl  =>  l_line_adj_att_tbl,
	lx_Line_Price_Adj_rltship_Tbl => l_line_price_adj_rltship_tbl
     );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after line price adjustments:l_line_adj_att_tbl.count: '||l_line_adj_att_tbl.count,1,'N');
aso_debug_pub.add('after line price adjustments:l_line_price_adj_rltship_tbl.count: '||l_line_price_adj_rltship_tbl.count,1,'N');
END IF;

  map_line_price_adj_rltn(
     P_Line_Price_Adj_rltship_Tbl  =>   l_Line_Price_Adj_rltship_Tbl,
     p_line_index  =>  i,
     p_qte_line_index =>  k,
	p_operation   =>   l_line_tbl(i).operation,
     x_Line_Adj_Assoc_tbl  =>  l_Line_Adj_Assoc_tbl
     );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('before line sales credit:l_Line_Adj_Assoc_tbl.count: '||l_Line_Adj_Assoc_tbl.count,1,'Y');
END IF;

  map_line_sales_credit(
     P_line_sales_credit_Tbl  =>   P_line_sales_credit_Tbl,
     p_line_index  =>  i,
     p_qte_line_index  =>  k,
     p_line_operation =>  l_line_tbl(i).operation,
     p_operation  =>  p_operation,
     x_Line_Scredit_tbl  =>  l_Line_Scredit_tbl
     );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after line sales credit:l_Line_Scredit_tbl.count: '||l_Line_Scredit_tbl.count,1,'Y');
END IF;

--Line Payments change

map_line_payments(
        P_line_payment_Tbl   => P_line_payment_Tbl,
        p_line_index =>  i,
        p_qte_line_index  =>  k,
        p_line_operation =>  l_line_tbl(i).operation,
        p_operation => p_operation,
        x_Line_tbl  => l_line_tbl,
        x_Line_Payment_tbl  => l_line_payment_tbl
        );
	   IF l_line_payment_tbl.count > 0 THEN
         l_final_payment_tbl(l_final_payment_tbl.count + 1) := l_line_payment_tbl(1);
	   END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after line payments:l_line_payment_tbl.count: '||l_line_payment_tbl.count,1,'Y');
aso_debug_pub.add('after line payments:l_final_payment_tbl.count: '||l_final_payment_tbl.count,1,'Y');
END IF;

  map_lot_serial(
     P_lot_serial_tbl  =>  P_lot_serial_tbl,
     p_operation  =>  l_line_tbl(i).operation,
     p_line_index  =>  i,
     p_qte_line_index  =>  k,
     x_lot_serial_tbl  =>  l_lot_serial_tbl
     );
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('after lot serial:l_lot_serial_tbl.count: '||l_lot_serial_tbl.count,1,'Y');
END IF;

found := FND_API.G_TRUE;
END IF;
END LOOP;  -- lines

i:= i+1;
END LOOP;  -- for shipment

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_final_payment_tbl.count: '|| l_final_payment_tbl.count,1,'Y');
END IF;
IF l_final_payment_tbl.count > 0 THEN
l_line_payment_tbl := l_final_payment_tbl;
END IF;



-- mapping operation code

  x_header_rec    		:= l_header_rec ;
  x_header_val_rec 		:= l_header_val_rec;
  x_Header_Adj_tbl    		:= l_header_adj_tbl;
  x_Header_Adj_val_tbl    	:= l_header_adj_val_tbl;
  x_Header_price_Att_tbl   	:= l_header_price_att_tbl;
  x_Header_Adj_Att_tbl       	:= l_header_adj_att_tbl;
  x_Header_Adj_Assoc_tbl    	:= l_header_adj_assoc_tbl;
  x_Header_Scredit_tbl        := l_header_scredit_tbl;
  x_Header_Scredit_val_tbl    := l_header_scredit_val_tbl;
  x_Header_Payment_tbl        := l_header_payment_tbl;
  x_line_tbl              	:= l_line_tbl;
  x_line_val_tbl         	:= l_line_val_tbl;
  x_Line_Adj_tbl     		:= l_line_adj_tbl;
  x_Line_Adj_val_tbl 		:= l_line_adj_val_tbl;
  x_Line_price_Att_tbl   	:= l_line_price_att_tbl;
  x_Line_Adj_Att_tbl     	:= l_Line_Adj_Att_tbl;
  x_Line_Adj_Assoc_tbl   	:= l_line_adj_assoc_tbl;
  x_Line_Scredit_tbl      	:= l_line_scredit_tbl;
  x_Line_Scredit_val_tbl   	:= l_line_scredit_val_tbl;
  x_Lot_Serial_tbl          	:= l_lot_serial_tbl;
  x_Lot_Serial_val_tbl      	:= l_lot_serial_val_tbl;
  x_Line_Payment_tbl      	:= l_line_payment_tbl;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('end of map quote to order ',1,'Y');
END IF;

END Map_quote_to_order;


PROCEDURE get_org_contact(
  p_party_id IN NUMBER,
  x_org_contact OUT NOCOPY /* file.sql.39 change */  number )
IS
CURSOR party_cur IS
SELECT party_type
from
hz_parties
where party_id = p_party_id
and status = 'A';
CURSOR org_contact IS
select a.org_contact_id
from
hz_org_contacts a, hz_relationships b
where b.party_id = p_party_id
and a.party_relationship_id = b.relationship_id
and b.STATUS = 'A' AND trunc(b.START_DATE) <= trunc(sysdate)
AND trunc(nvl(b.END_DATE, sysdate)) >= trunc(sysdate);
--and a.status = 'A'; /* status column in hz_org_contacts is obseleted */
l_party_type varchar2(30);
begin

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('entering get_org_contact ',1,'N');
aso_debug_pub.add('party_id = ' || p_party_id,1,'N');
END IF;

OPEN party_cur;
FETCH party_cur INTO l_party_type;
CLOSE party_cur;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('party_type = '|| l_party_type,1,'N');
END IF;

IF l_party_type = 'PARTY_RELATIONSHIP' THEN
 OPEN org_contact;
 FETCH org_contact INTO x_org_contact;
 CLOSE org_contact;
END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('org_contact = ' || x_org_contact,1,'N');
END IF;

END;

PROCEDURE  get_acct_site_uses
(
p_party_site_id IN NUMBER,
p_acct_site_type IN VARCHAR2,
p_cust_account_id IN NUMBER,
x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
x_site_use_id OUT NOCOPY /* file.sql.39 change */  number
)
IS
CURSOR party_cur IS
SELECT a.party_type, a.party_id
from
HZ_PARTIES a, HZ_PARTY_SITES b
where
a.status = 'A'
AND b.status = 'A'
and b.party_site_id = p_party_site_id
and b.party_id = a.party_id;


CURSOR site_use_cur IS
select a.site_use_id, b.status,a.status
from
hz_cust_site_uses a, hz_cust_acct_sites b
where
b.cust_account_id = p_cust_account_id
and b.party_site_id = p_party_site_id
and a.cust_acct_site_id = b.cust_acct_site_id
and a.site_use_code = p_acct_site_type
and a.status = 'A'
and b.status = 'A';

l_party_id number;
cur_party_id number;
l_cust_account_id number;
cust_acct_site_status varchar2(1);
cust_site_use_status varchar2(1);

CURSOR  relationship_cur IS
select a.object_id
from
hz_relationships a, hz_cust_accounts  b
where  a.party_id = l_party_id
and a.object_id = b.party_id
and b.cust_account_id = p_cust_account_id
and a.status = 'A'
and (sysdate between nvl(a.start_date, sysdate)
and nvl(a.end_date, sysdate))
AND b.status = 'A'
AND (sysdate BETWEEN NVL(b.account_activation_date, sysdate) AND
                     NVL(b.account_termination_date, sysdate));

                     l_party_type VARCHAR2(30);
                     l_site_use_id number;
begin

aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('site use in get_acct_site_uses = ' || p_acct_site_type,1,'N');
END IF;
  OPEN party_cur;
  FETCH party_cur INTO l_party_type, l_party_id;
  IF (party_cur%NOTFOUND) THEN
     l_party_type := NULL;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('party_type in get_acct_site_uses = ' || l_party_type,1,'N');
END IF;
  CLOSE party_cur;

  IF l_party_type = 'PARTY_RELATIONSHIP' THEN
    OPEN relationship_cur;
    FETCH relationship_cur INTO cur_party_id;
    IF (relationship_cur%NOTFOUND) THEN
      cur_party_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    CLOSE relationship_cur;
  ELSE
    cur_party_id := l_party_id;
  END IF;
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('cur_party_id = ' || cur_party_id,1,'N');
  END IF;

  OPEN site_use_cur;
  FETCH site_use_cur
    INTO l_site_use_id, cust_acct_site_status, cust_site_use_status;
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('site use id = ' || l_site_use_id, 1, 'N');
  aso_debug_pub.add('account site status = ' || cust_acct_site_status, 1,'N');
  aso_debug_pub.add('account site use status = ' || cust_site_use_status, 1,'N');
  END IF;
  IF (site_use_cur%NOTFOUND) THEN
    l_site_use_id := NULL;
-- x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    IF cust_acct_site_status <> 'A' OR cust_site_use_status <> 'A' THEN
     l_site_use_id := NULL;
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF p_acct_site_type = 'BILL_TO' THEN
      FND_MESSAGE.Set_Name('ASO','ASO_INV_CUST_SITE_INACTIVE');
     ELSE
      FND_MESSAGE.Set_Name('ASO','ASO_SHIP_CUST_SITE_INACTIVE');
     END IF;
     FND_MSG_PUB.ADD;
    END IF;
  END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('site_use_id in get_acct_site_uses = ' || l_site_use_id,1,'N');
END IF;
  CLOSE site_use_cur;
  x_site_use_id := l_site_use_id;
END get_acct_site_uses;


PROCEDURE get_cust_acct_roles
(
p_party_id IN NUMBER,
p_party_site_id IN NUMBER,
p_acct_site_type IN VARCHAR2,
p_cust_account_id IN NUMBER,
x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
x_party_id   OUT NOCOPY /* file.sql.39 change */  NUMBER,
x_cust_account_role_id OUT NOCOPY /* file.sql.39 change */  number
)
IS
CURSOR party_cur IS
SELECT party_type
from
HZ_PARTIES
where party_id = p_party_id and status ='A';

CURSOR cust_cur IS
SELECT party_id
from hz_cust_accounts
where cust_account_id = p_cust_account_id
AND status = 'A'
AND (sysdate BETWEEN NVL(account_activation_date, sysdate) AND
				     NVL(account_termination_date, sysdate));

CURSOR person_relationship_cur IS
SELECT b.party_id
from hz_org_contacts a, hz_relationships b, hz_cust_accounts c
where
--a.status = 'A' and -- status column obseleted
a.party_relationship_id = b.relationship_id
and b.subject_id = p_party_id
and b.object_id = c.party_id
and c.cust_account_id = p_cust_account_id
AND c.status = 'A'
and b.status = 'A'
and (sysdate between nvl(b.start_date, sysdate) and nvl(b.end_date, sysdate))
AND (sysdate BETWEEN NVL(c.account_activation_date, sysdate) AND
				 NVL(c.account_termination_date, sysdate));

CURSOR org_contact IS
select a.org_contact_id
from
hz_org_contacts a, hz_relationships b
where
b.party_id = p_party_id
/* and a.status = 'A'  vtariker: Status for hz_org_contacts is now obsolete */
and b.relationship_id = a.party_relationship_id
and b.status = 'A'
and (sysdate between nvl(b.start_date, sysdate) and nvl(b.end_date, sysdate));

CURSOR cust_role(l_party_id number) IS
select a.cust_account_role_id, a.status
from
hz_cust_account_roles a,  hz_cust_acct_sites c
--,hz_role_responsibility d
where
a.role_type = 'CONTACT'
and a.party_id = l_party_id
and a.cust_account_id = p_cust_account_id
and a.cust_acct_site_id = c.cust_acct_site_id
and a.cust_account_id = c.cust_account_id
and c.party_site_id = p_party_site_id
--and a.cust_account_role_id = d.cust_account_role_id
--and d.responsibility_type = p_acct_site_type
and c.status = 'A'
and a.status = 'A';

CURSOR cust_role_exists(l_party_id number) IS
select 'Y'
from
hz_cust_account_roles a,  hz_cust_acct_sites c
where
a.role_type = 'CONTACT'
and a.party_id = l_party_id
and a.cust_account_id = p_cust_account_id
and a.cust_acct_site_id = c.cust_acct_site_id
and a.cust_account_id = c.cust_account_id
and c.party_site_id = p_party_site_id
and c.status = 'A';

l_exists VARCHAR2(1) := 'N';
cust_account_role_status varchar2(1);
l_org_contact_id number;
l_party_type VARCHAR2(30);
l_cust_account_role_id number;
l_party_id   number;
l_relationship_party_id number := NULL;
l_multiple_flag VARCHAR2(1) := FND_API.G_FALSE;
l_count_relationship number := 0;
l_acct_site_type VARCHAR2(50);
begin

 x_return_status := FND_API.G_RET_STS_SUCCESS;
 IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('site use in get_cust_account_roles = ' || p_acct_site_type,1,'N');
 aso_debug_pub.add('p_party_id = ' || p_party_id,1,'N');
 END IF;

 IF p_acct_site_type = 'END_USER' THEN
     l_acct_site_type := 'SHIP_TO';
 END IF;

 OPEN party_cur;
 FETCH party_cur INTO l_party_type;
 IF (party_cur%NOTFOUND) THEN
   l_party_type := NULL;
   x_return_status := FND_API.G_RET_STS_ERROR;
 END IF;
 IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('party_type in get_cust_account_roles = ' || l_party_type,1,'N');
 END IF;
 CLOSE party_cur;

 IF l_party_type = 'PERSON' THEN
  OPEN cust_cur;
  FETCH cust_cur INTO l_party_id;
  IF cust_cur%NOTFOUND THEN
   l_party_id := NULL;
   x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  CLOSE cust_cur;

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('l_party_id = ' || l_party_id, 1,'N');
  END IF;
  IF l_party_id IS NOT NULL AND l_party_id = p_party_id THEN
   -- p_party_id is owner of account, hence not a contact
   x_party_id := FND_API.G_MISS_NUM;
   x_cust_account_role_id := FND_API.G_MISS_NUM;
   return;
  END IF;

  OPEN person_relationship_cur;
  LOOP
   FETCH person_relationship_cur INTO l_relationship_party_id;
   EXIT WHEN person_relationship_cur%NOTFOUND OR x_return_status = FND_API.G_RET_STS_ERROR;
   l_count_relationship := l_count_relationship + 1;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('relationship_party_id = ' || l_relationship_party_id,1,'N');
   aso_debug_pub.add('x_return_status = ' || x_return_status,1,'N');
   aso_debug_pub.add('opening cust_role cursor',1,'N');
   END IF;

     OPEN cust_role(l_relationship_party_id);
     LOOP
	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('looping in cust_role',1,'N');
	 END IF;
      FETCH cust_role INTO l_cust_account_role_id, cust_account_role_status;
      EXIT WHEN cust_role%NOTFOUND OR x_return_status = FND_API.G_RET_STS_ERROR;
      IF (cust_role%ROWCOUNT) > 1   THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
     END LOOP;
     CLOSE cust_role;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add(' l_cust_account_role_id = '|| l_cust_account_role_id,1,'N' );
     aso_debug_pub.add('rowcount = ' || person_relationship_cur%ROWCOUNT,1,'N');
     aso_debug_pub.add('l_multiple_flag = ' || l_multiple_flag,1,'N');
	END IF;

     IF person_relationship_cur%ROWCOUNT > 1 AND l_multiple_flag = FND_API.G_TRUE
      THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     IF l_cust_account_role_id IS NOT NULL THEN
      l_multiple_flag := FND_API.G_TRUE;
     END IF;
  END LOOP;
  IF l_count_relationship = 0 THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
   CLOSE person_relationship_cur;
   x_party_id := l_relationship_party_id;
 END IF; --end person
 IF l_party_type = 'PARTY_RELATIONSHIP' THEN
  OPEN org_contact;
  FETCH org_contact INTO l_org_contact_id;
  IF (org_contact%NOTFOUND) THEN
    l_org_contact_id := NULL;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
 IF aso_debug_pub.g_debug_flag = 'Y' THEN
 aso_debug_pub.add('org_contact_id in get_cust_acct_roles = '|| l_org_contact_id,1,'N');
 END IF;
  CLOSE org_contact;

  OPEN cust_role_exists(p_party_id);
  FETCH cust_role_exists INTO l_exists;
  CLOSE cust_role_exists;

  IF NVL(l_exists,'N') <> 'Y' THEN
    l_cust_account_role_id := NULL;
--    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    OPEN cust_role(p_party_id);
    FETCH cust_role INTO l_cust_account_role_id, cust_account_role_status;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('cust account role id = ' || l_cust_account_role_id, 1, 'N');
     aso_debug_pub.add('cust account role status = ' || cust_account_role_status, 1 , 'N');
    END IF;

   IF (cust_role%NOTFOUND) THEN
     l_cust_account_role_id := NULL;
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF p_acct_site_type = 'BILL_TO' THEN
      FND_MESSAGE.Set_Name('ASO','ASO_INV_CUST_ROLE_INACTIVE');
     ELSIF p_acct_site_type = 'END_USER' THEN
      FND_MESSAGE.Set_Name('ASO','ASO_END_CUST_ROLE_INACTIVE');
     ELSIF p_acct_site_type = 'SHIP_TO' THEN
      FND_MESSAGE.Set_Name('ASO','ASO_SHP_CUST_ROLE_INACTIVE');
     END IF;
     FND_MSG_PUB.ADD;
   END IF;
   CLOSE cust_role;
  END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_cust_account_role_id in get_cust_acct_roles = '|| l_cust_account_role_id,1,'N');
END IF;
  x_party_id := p_party_id;

 END IF; -- end party relationship

 x_cust_account_role_id := l_cust_account_role_id;
END get_cust_acct_roles;

PROCEDURE Get_Cust_Accnt_Id(
   P_Qte_Rec          IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type
                           := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
   p_Party_Id  IN  NUMBER,
   p_Cust_Acct_Id  OUT NOCOPY /* file.sql.39 change */  NUMBER,
   x_return_status OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
   x_msg_count  OUT NOCOPY /* file.sql.39 change */  NUMBER,
   x_msg_data  OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
   IS

   CURSOR C_get_cust_id_from_party_id(l_Party_Id NUMBER) IS
     SELECT cust_account_id
     FROM hz_cust_accounts
     WHERE party_id = l_Party_Id
     and status = 'A'
     AND (sysdate BETWEEN NVL(account_activation_date, sysdate) AND
				          NVL(account_termination_date, sysdate));

   CURSOR party_rec IS
   select party_type
   from hz_parties
   where party_id = p_party_id
   AND status = 'A';

   CURSOR account_user_cur IS
    select a.cust_account_id
    from hz_cust_accounts a, hz_cust_account_roles b
    where a.cust_account_id = b.cust_account_id
    and b.party_id = p_party_id
    and b.role_type = 'ACCOUNT_USER'
    AND b.status = 'A'
    AND a.status = 'A'
    AND (sysdate BETWEEN NVL(a.account_activation_date, sysdate) AND
				         NVL(a.account_termination_date, sysdate));

     count NUMBER := 0;
     x_cust_id NUMBER := NULL;
     lx_cust_id NUMBER := NULL;
    l_msg_count                   number;
    l_msg_data                    varchar2(200);
    cust_account_id         NUMBER;
    l_return_status               VARCHAR2(1);
    l_party_type               VARCHAR2(30);


BEGIN

OPEN party_rec;
FETCH party_rec INTO l_party_type;
CLOSE party_rec;

IF l_party_type = 'PERSON' OR l_party_type ='ORGANIZATION' THEN

OPEN C_get_cust_id_from_party_id(p_Party_Id);

LOOP
  FETCH C_get_cust_id_from_party_id INTO lx_cust_id;
  IF C_get_cust_id_from_party_id%ROWCOUNT > 1 THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     EXIT;
  END IF;
  EXIT WHEN C_get_cust_id_from_party_id%NOTFOUND;
END LOOP;

CLOSE C_get_cust_id_from_party_id;

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
   FND_MESSAGE.Set_Name('ASO', 'ASO_MULTIPLE_CUST_ACCOUNT');
    FND_MESSAGE.Set_Token('ID', to_char( p_qte_rec.party_id), FALSE);
    FND_MSG_PUB.ADD;
    raise FND_API.G_EXC_ERROR;
END IF;

ELSIF l_party_type = 'PARTY_RELATIONSHIP' THEN
  OPEN account_user_cur;
  LOOP
  FETCH account_user_cur INTO lx_cust_id;
  IF account_user_cur%ROWCOUNT > 1 THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    EXIT;
  END IF;
  EXIT WHEN C_get_cust_id_from_party_id%NOTFOUND;
  END LOOP;
  CLOSE account_user_cur;
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    FND_MESSAGE.Set_Name('ASO', 'ASO_MULTIPLE_CUST_ACCOUNT');
    FND_MESSAGE.Set_Token('ID', to_char( p_qte_rec.party_id), FALSE);
    FND_MSG_PUB.ADD;
    raise FND_API.G_EXC_ERROR;
  END IF;
END IF;

IF lx_cust_id IS NULL OR lx_cust_id = FND_API.G_MISS_NUM THEN
          IF p_qte_rec.party_id is not NULL
             AND p_qte_rec.party_id <> FND_API.G_MISS_NUM THEN
                ASO_PARTY_INT.Create_Customer_Account(
                      p_api_version      => 1.0
                     ,P_Qte_REC          => p_qte_rec
                     ,x_return_status    => l_return_status
                     ,x_msg_count        => l_msg_count
                     ,x_msg_data         => l_msg_data
                     ,x_acct_id          => cust_account_id
                             );

                 IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                       THEN
                          FND_MESSAGE.Set_Name('ASO', 'ASO_CUST_ACCOUNT');
                          FND_MESSAGE.Set_Token('ID', to_char( p_qte_rec.party_id), FALSE);
                          FND_MSG_PUB.ADD;
                    END IF;
                    raise FND_API.G_EXC_ERROR;
               END IF;

          p_Cust_Acct_Id := cust_account_id;
     END IF;

ELSE
          p_Cust_Acct_Id := lx_cust_id;

END IF;

END Get_Cust_Accnt_Id;

PROCEDURE get_org_contact_role(
  p_Org_Contact_Id      IN  NUMBER
  ,p_Cust_account_id     IN  NUMBER
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ,x_party_id         OUT NOCOPY /* file.sql.39 change */  NUMBER
  ,x_cust_account_role_id OUT NOCOPY /* file.sql.39 change */  NUMBER
     )
IS
CURSOR C_active_contact (p_party_id NUMBER) IS
      SELECT cust_account_role_id, status
      FROM hz_cust_account_roles
      WHERE party_id = p_party_id
      AND cust_account_id = p_cust_account_id
      AND role_type ='CONTACT'
      AND cust_acct_site_id is null
	 and status = 'A';

CURSOR C_inactive_contact (p_party_id NUMBER) IS
      SELECT cust_account_role_id, status
      FROM hz_cust_account_roles
      WHERE party_id = p_party_id
      AND cust_account_id = p_cust_account_id
      AND role_type ='CONTACT'
      AND cust_acct_site_id is null
      and status <> 'A';

cust_account_role_status varchar2(1);


CURSOR C_party IS
      SELECT par.party_id
      FROM hz_relationships par,
           hz_org_contacts     org ,
           hz_cust_accounts acc
      WHERE org.party_relationship_id = par.relationship_id
      AND org.org_contact_id  = p_org_contact_id
--      AND org.status = 'A'  -- status column obseleted
      and par.status = 'A'
      and (sysdate between nvl(par.start_date, sysdate) and nvl(par.end_date, sysdate))
      AND acc.cust_account_id = p_cust_account_id
      AND par.object_id = acc.party_id
      AND acc.status = 'A'
      AND (sysdate BETWEEN NVL(acc.account_activation_date, sysdate) AND
				           NVL(acc.account_termination_date, sysdate));


l_party_id                NUMBER;
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;


OPEN C_party;
FETCH C_party INTO l_party_id;
IF (C_party%NOTFOUND) THEN
 x_return_status := FND_API.G_RET_STS_ERROR;
END IF;
CLOSE C_party;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('x_return_status = ' || x_return_status,1,'N');
aso_debug_pub.add('l_party_id is = ' || l_party_id,1,'N');
END IF;

OPEN  C_active_contact (l_party_id);
FETCH C_active_contact INTO  x_cust_account_role_id, cust_account_role_status;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('cust account role id = ' || x_cust_account_role_id, 1, 'N');
aso_debug_pub.add('cust_account_role_status = '|| cust_account_role_status, 1, 'N');
END IF;
IF (C_active_contact%NOTFOUND) THEN
   -- this means there are no active contacts
  OPEN C_inactive_contact(l_party_id);
  FETCH C_inactive_contact INTO x_cust_account_role_id, cust_account_role_status;
  IF C_inactive_contact%FOUND THEN
   -- this means there are ONLY inactive contacts
       x_cust_account_role_id := NULL;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.Set_Name('ASO','ASO_SOLD_CUST_ROLE_INACTIVE');
       FND_MSG_PUB.ADD;
   ELSE
    -- this means there are no contacts
     x_cust_account_role_id := NULL;
   END IF;
   CLOSE C_inactive_contact;
END IF;
CLOSE C_active_contact;

x_party_id := l_party_id;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('cust acct role '||x_cust_account_role_id,1,'N');
END IF;
END get_org_contact_role;


PROCEDURE map_header_price_attr(
        p_header_price_attributes_tbl IN  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
        p_qte_rec  IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
        p_operation IN VARCHAR2,
        x_Header_price_Att_tbl  OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Price_Att_Tbl_Type
        )
        IS
i  NUMBER;
p_att_count NUMBER := 1;
l_header_price_att_tbl OE_Order_PUB.Header_Price_Att_Tbl_Type;
BEGIN
  FOR i in 1..p_header_price_attributes_tbl.count LOOP
     l_header_price_att_tbl(p_att_count).pricing_context
                           := p_header_price_attributes_tbl(i).pricing_context;
     l_header_price_att_tbl(p_att_count).pricing_attribute1
                        := p_header_price_attributes_tbl(i).pricing_attribute1;
     l_header_price_att_tbl(p_att_count).pricing_attribute2
                        := p_header_price_attributes_tbl(i).pricing_attribute2;
     l_header_price_att_tbl(p_att_count).pricing_attribute3
          :=  p_header_price_attributes_tbl(i).pricing_attribute3;
     l_header_price_att_tbl(p_att_count).pricing_attribute4
          :=  p_header_price_attributes_tbl(i).pricing_attribute4;
     l_header_price_att_tbl(p_att_count).pricing_attribute5
          :=  p_header_price_attributes_tbl(i).pricing_attribute5;
     l_header_price_att_tbl(p_att_count).pricing_attribute6
          :=  p_header_price_attributes_tbl(i).pricing_attribute6;
     l_header_price_att_tbl(p_att_count).pricing_attribute7
          :=  p_header_price_attributes_tbl(i).pricing_attribute7;
     l_header_price_att_tbl(p_att_count).pricing_attribute8
          :=  p_header_price_attributes_tbl(i).pricing_attribute8;
     l_header_price_att_tbl(p_att_count).pricing_attribute9
          :=  p_header_price_attributes_tbl(i).pricing_attribute9;
     l_header_price_att_tbl(p_att_count).pricing_attribute10
          :=  p_header_price_attributes_tbl(i).pricing_attribute10;
     l_header_price_att_tbl(p_att_count).pricing_attribute11
          :=  p_header_price_attributes_tbl(i).pricing_attribute11;
     l_header_price_att_tbl(p_att_count).pricing_attribute12
          :=  p_header_price_attributes_tbl(i).pricing_attribute12;
     l_header_price_att_tbl(p_att_count).pricing_attribute13
          :=  p_header_price_attributes_tbl(i).pricing_attribute13;
     l_header_price_att_tbl(p_att_count).pricing_attribute14
          :=  p_header_price_attributes_tbl(i).pricing_attribute14;
     l_header_price_att_tbl(p_att_count).pricing_attribute15
          :=  p_header_price_attributes_tbl(i).pricing_attribute15;
     l_header_price_att_tbl(p_att_count).pricing_attribute16
          :=  p_header_price_attributes_tbl(i).pricing_attribute16;
     l_header_price_att_tbl(p_att_count).pricing_attribute17
          :=  p_header_price_attributes_tbl(i).pricing_attribute17;
     l_header_price_att_tbl(p_att_count).pricing_attribute18
          :=  p_header_price_attributes_tbl(i).pricing_attribute18;
     l_header_price_att_tbl(p_att_count).pricing_attribute19
          :=  p_header_price_attributes_tbl(i).pricing_attribute19;
     l_header_price_att_tbl(p_att_count).pricing_attribute20
          :=  p_header_price_attributes_tbl(i).pricing_attribute20;
     l_header_price_att_tbl(p_att_count).pricing_attribute21
          :=  p_header_price_attributes_tbl(i).pricing_attribute21;
     l_header_price_att_tbl(p_att_count).pricing_attribute22
          :=  p_header_price_attributes_tbl(i).pricing_attribute22;
     l_header_price_att_tbl(p_att_count).pricing_attribute23
          :=  p_header_price_attributes_tbl(i).pricing_attribute23;
     l_header_price_att_tbl(p_att_count).pricing_attribute24
          :=  p_header_price_attributes_tbl(i).pricing_attribute24;
     l_header_price_att_tbl(p_att_count).pricing_attribute25
          :=  p_header_price_attributes_tbl(i).pricing_attribute25;
     l_header_price_att_tbl(p_att_count).pricing_attribute26
          :=  p_header_price_attributes_tbl(i).pricing_attribute26;
     l_header_price_att_tbl(p_att_count).pricing_attribute27
          :=  p_header_price_attributes_tbl(i).pricing_attribute27;
     l_header_price_att_tbl(p_att_count).pricing_attribute28
          :=  p_header_price_attributes_tbl(i).pricing_attribute28;
     l_header_price_att_tbl(p_att_count).pricing_attribute29
          :=  p_header_price_attributes_tbl(i).pricing_attribute29;
     l_header_price_att_tbl(p_att_count).pricing_attribute30
          :=  p_header_price_attributes_tbl(i).pricing_attribute30;
     l_header_price_att_tbl(p_att_count).pricing_attribute31
          :=  p_header_price_attributes_tbl(i).pricing_attribute31;
     l_header_price_att_tbl(p_att_count).pricing_attribute32
          :=  p_header_price_attributes_tbl(i).pricing_attribute32;
     l_header_price_att_tbl(p_att_count).pricing_attribute33
          :=  p_header_price_attributes_tbl(i).pricing_attribute33;
     l_header_price_att_tbl(p_att_count).pricing_attribute34
          :=  p_header_price_attributes_tbl(i).pricing_attribute34;
     l_header_price_att_tbl(p_att_count).pricing_attribute35
          :=  p_header_price_attributes_tbl(i).pricing_attribute35;
     l_header_price_att_tbl(p_att_count).pricing_attribute36
          :=  p_header_price_attributes_tbl(i).pricing_attribute36;
     l_header_price_att_tbl(p_att_count).pricing_attribute37
          :=  p_header_price_attributes_tbl(i).pricing_attribute37;
     l_header_price_att_tbl(p_att_count).pricing_attribute38
          :=  p_header_price_attributes_tbl(i).pricing_attribute38;
     l_header_price_att_tbl(p_att_count).pricing_attribute39
          :=  p_header_price_attributes_tbl(i).pricing_attribute39;
     l_header_price_att_tbl(p_att_count).pricing_attribute40
          :=  p_header_price_attributes_tbl(i).pricing_attribute40;
     l_header_price_att_tbl(p_att_count).pricing_attribute41
          :=  p_header_price_attributes_tbl(i).pricing_attribute41;
     l_header_price_att_tbl(p_att_count).pricing_attribute42
          :=  p_header_price_attributes_tbl(i).pricing_attribute42;
     l_header_price_att_tbl(p_att_count).pricing_attribute43
          :=  p_header_price_attributes_tbl(i).pricing_attribute43;
     l_header_price_att_tbl(p_att_count).pricing_attribute44
          :=  p_header_price_attributes_tbl(i).pricing_attribute44;
     l_header_price_att_tbl(p_att_count).pricing_attribute45
          :=  p_header_price_attributes_tbl(i).pricing_attribute45;
     l_header_price_att_tbl(p_att_count).pricing_attribute46
          :=  p_header_price_attributes_tbl(i).pricing_attribute46;
     l_header_price_att_tbl(p_att_count).pricing_attribute47
          :=  p_header_price_attributes_tbl(i).pricing_attribute47;
     l_header_price_att_tbl(p_att_count).pricing_attribute48
          :=  p_header_price_attributes_tbl(i).pricing_attribute48;
     l_header_price_att_tbl(p_att_count).pricing_attribute49
          :=  p_header_price_attributes_tbl(i).pricing_attribute49;
     l_header_price_att_tbl(p_att_count).pricing_attribute50
          :=  p_header_price_attributes_tbl(i).pricing_attribute50;
     l_header_price_att_tbl(p_att_count).pricing_attribute51
          :=  p_header_price_attributes_tbl(i).pricing_attribute51;
     l_header_price_att_tbl(p_att_count).pricing_attribute52
          :=  p_header_price_attributes_tbl(i).pricing_attribute52;
     l_header_price_att_tbl(p_att_count).pricing_attribute53
          :=  p_header_price_attributes_tbl(i).pricing_attribute53;
     l_header_price_att_tbl(p_att_count).pricing_attribute54
          :=  p_header_price_attributes_tbl(i).pricing_attribute54;
     l_header_price_att_tbl(p_att_count).pricing_attribute55
          :=  p_header_price_attributes_tbl(i).pricing_attribute55;
     l_header_price_att_tbl(p_att_count).pricing_attribute56
          :=  p_header_price_attributes_tbl(i).pricing_attribute56;
     l_header_price_att_tbl(p_att_count).pricing_attribute57
          :=  p_header_price_attributes_tbl(i).pricing_attribute57;
     l_header_price_att_tbl(p_att_count).pricing_attribute58
          :=  p_header_price_attributes_tbl(i).pricing_attribute58;
     l_header_price_att_tbl(p_att_count).pricing_attribute59
          :=  p_header_price_attributes_tbl(i).pricing_attribute59;
     l_header_price_att_tbl(p_att_count).pricing_attribute60
          :=  p_header_price_attributes_tbl(i).pricing_attribute60;
     l_header_price_att_tbl(p_att_count).pricing_attribute61
          :=  p_header_price_attributes_tbl(i).pricing_attribute61;
     l_header_price_att_tbl(p_att_count).pricing_attribute62
          :=  p_header_price_attributes_tbl(i).pricing_attribute62;
     l_header_price_att_tbl(p_att_count).pricing_attribute63
          :=  p_header_price_attributes_tbl(i).pricing_attribute63;
     l_header_price_att_tbl(p_att_count).pricing_attribute64
          :=  p_header_price_attributes_tbl(i).pricing_attribute64;
     l_header_price_att_tbl(p_att_count).pricing_attribute65
          :=  p_header_price_attributes_tbl(i).pricing_attribute65;
     l_header_price_att_tbl(p_att_count).pricing_attribute66
          :=  p_header_price_attributes_tbl(i).pricing_attribute66;
     l_header_price_att_tbl(p_att_count).pricing_attribute67
          :=  p_header_price_attributes_tbl(i).pricing_attribute67;
     l_header_price_att_tbl(p_att_count).pricing_attribute68
          :=  p_header_price_attributes_tbl(i).pricing_attribute68;
     l_header_price_att_tbl(p_att_count).pricing_attribute69
          :=  p_header_price_attributes_tbl(i).pricing_attribute69;
     l_header_price_att_tbl(p_att_count).pricing_attribute70
          :=  p_header_price_attributes_tbl(i).pricing_attribute70;
     l_header_price_att_tbl(p_att_count).pricing_attribute71
          :=  p_header_price_attributes_tbl(i).pricing_attribute71;
     l_header_price_att_tbl(p_att_count).pricing_attribute72
          :=  p_header_price_attributes_tbl(i).pricing_attribute72;
     l_header_price_att_tbl(p_att_count).pricing_attribute73
          :=  p_header_price_attributes_tbl(i).pricing_attribute73;
     l_header_price_att_tbl(p_att_count).pricing_attribute74
          :=  p_header_price_attributes_tbl(i).pricing_attribute74;
     l_header_price_att_tbl(p_att_count).pricing_attribute75
          :=  p_header_price_attributes_tbl(i).pricing_attribute75;
     l_header_price_att_tbl(p_att_count).pricing_attribute76
          :=  p_header_price_attributes_tbl(i).pricing_attribute76;
     l_header_price_att_tbl(p_att_count).pricing_attribute77
          :=  p_header_price_attributes_tbl(i).pricing_attribute77;
     l_header_price_att_tbl(p_att_count).pricing_attribute78
          :=  p_header_price_attributes_tbl(i).pricing_attribute78;
     l_header_price_att_tbl(p_att_count).pricing_attribute79
          :=  p_header_price_attributes_tbl(i).pricing_attribute79;
     l_header_price_att_tbl(p_att_count).pricing_attribute80
          :=  p_header_price_attributes_tbl(i).pricing_attribute80;
     l_header_price_att_tbl(p_att_count).pricing_attribute81
          :=  p_header_price_attributes_tbl(i).pricing_attribute81;
     l_header_price_att_tbl(p_att_count).pricing_attribute82
          :=  p_header_price_attributes_tbl(i).pricing_attribute82;
     l_header_price_att_tbl(p_att_count).pricing_attribute83
          :=  p_header_price_attributes_tbl(i).pricing_attribute83;
     l_header_price_att_tbl(p_att_count).pricing_attribute84
          :=  p_header_price_attributes_tbl(i).pricing_attribute84;
     l_header_price_att_tbl(p_att_count).pricing_attribute85
          :=  p_header_price_attributes_tbl(i).pricing_attribute85;
     l_header_price_att_tbl(p_att_count).pricing_attribute86
          :=  p_header_price_attributes_tbl(i).pricing_attribute86;
     l_header_price_att_tbl(p_att_count).pricing_attribute87
          :=  p_header_price_attributes_tbl(i).pricing_attribute87;
     l_header_price_att_tbl(p_att_count).pricing_attribute88
          :=  p_header_price_attributes_tbl(i).pricing_attribute88;
     l_header_price_att_tbl(p_att_count).pricing_attribute89
          :=  p_header_price_attributes_tbl(i).pricing_attribute89;
     l_header_price_att_tbl(p_att_count).pricing_attribute90
          :=  p_header_price_attributes_tbl(i).pricing_attribute90;
     l_header_price_att_tbl(p_att_count).pricing_attribute91
          :=  p_header_price_attributes_tbl(i).pricing_attribute91;
     l_header_price_att_tbl(p_att_count).pricing_attribute92
          :=  p_header_price_attributes_tbl(i).pricing_attribute92;
     l_header_price_att_tbl(p_att_count).pricing_attribute93
          :=  p_header_price_attributes_tbl(i).pricing_attribute93;
     l_header_price_att_tbl(p_att_count).pricing_attribute94
          :=  p_header_price_attributes_tbl(i).pricing_attribute94;
     l_header_price_att_tbl(p_att_count).pricing_attribute95
          :=  p_header_price_attributes_tbl(i).pricing_attribute95;
     l_header_price_att_tbl(p_att_count).pricing_attribute96
          :=  p_header_price_attributes_tbl(i).pricing_attribute96;
     l_header_price_att_tbl(p_att_count).pricing_attribute97
          :=  p_header_price_attributes_tbl(i).pricing_attribute97;
     l_header_price_att_tbl(p_att_count).pricing_attribute98
          :=  p_header_price_attributes_tbl(i).pricing_attribute98;
     l_header_price_att_tbl(p_att_count).pricing_attribute99
          :=  p_header_price_attributes_tbl(i).pricing_attribute99;
     l_header_price_att_tbl(p_att_count).pricing_attribute100
          :=  p_header_price_attributes_tbl(i).pricing_attribute100;
     l_header_price_att_tbl(p_att_count).context
          := p_header_price_attributes_tbl(i).context;
     l_header_price_att_tbl(p_att_count).attribute1
          := p_header_price_attributes_tbl(i).attribute1;
     l_header_price_att_tbl(p_att_count).attribute2
          := p_header_price_attributes_tbl(i).attribute2;
     l_header_price_att_tbl(p_att_count).attribute3
          := p_header_price_attributes_tbl(i).attribute3;
     l_header_price_att_tbl(p_att_count).attribute4
          := p_header_price_attributes_tbl(i).attribute4;
     l_header_price_att_tbl(p_att_count).attribute5
          := p_header_price_attributes_tbl(i).attribute5;
     l_header_price_att_tbl(p_att_count).attribute6
          := p_header_price_attributes_tbl(i).attribute6;
     l_header_price_att_tbl(p_att_count).attribute7
          := p_header_price_attributes_tbl(i).attribute7;
     l_header_price_att_tbl(p_att_count).attribute8
          := p_header_price_attributes_tbl(i).attribute8;
     l_header_price_att_tbl(p_att_count).attribute9
          := p_header_price_attributes_tbl(i).attribute9;
     l_header_price_att_tbl(p_att_count).attribute10
          := p_header_price_attributes_tbl(i).attribute10;
     l_header_price_att_tbl(p_att_count).attribute11
          := p_header_price_attributes_tbl(i).attribute11;
     l_header_price_att_tbl(p_att_count).attribute12
          := p_header_price_attributes_tbl(i).attribute12;
     l_header_price_att_tbl(p_att_count).attribute13
          := p_header_price_attributes_tbl(i).attribute13;
     l_header_price_att_tbl(p_att_count).attribute14
          := p_header_price_attributes_tbl(i).attribute14;
     l_header_price_att_tbl(p_att_count).attribute15
          := p_header_price_attributes_tbl(i).attribute15;

-- bug# 2020930
     l_header_price_att_tbl(p_att_count).flex_title
          := p_header_price_attributes_tbl(i).flex_title;
-- bug# 2020930 end

-- this is need if header is update but the operation here is create
     IF p_operation <> OE_GLOBALS.G_OPR_CREATE THEN
       l_header_price_att_tbl(p_att_count).header_id
            :=  p_qte_rec.quote_header_id;
       l_header_price_att_tbl(p_att_count).order_price_attrib_id
		  :=  p_header_price_attributes_tbl(i).price_attribute_id;
     ELSIF p_operation = OE_GLOBALS.G_OPR_CREATE THEN
	  l_header_price_att_tbl(p_att_count).order_price_attrib_id
		  := FND_API.G_MISS_NUM;
     END IF;

     l_header_price_att_tbl(p_att_count).operation :=  p_operation;

p_att_count := p_att_count + 1;
END LOOP;

x_header_price_att_tbl := l_header_price_att_tbl;
END map_header_price_attr;

PROCEDURE  map_header_price_adj(
        p_header_price_adj_tbl  IN    ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
        p_qte_rec  IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
        p_operation IN VARCHAR2 ,
        x_Header_Adj_tbl  OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Adj_Tbl_Type
        )
        IS
i  NUMBER;
adj_count NUMBER :=1;
l_Header_Adj_tbl  OE_Order_PUB.Header_Adj_Tbl_Type
                 := OE_ORDER_PUB.G_MISS_HEADER_ADJ_TBL;

-- Start : code change done for Bug 21895702
Cursor C_Freight_Terms(p_qte_hdr_id Number) Is
Select freight_terms_code,
       freight_terms_code_from
from aso_shipments
Where quote_header_id = p_qte_hdr_id
and quote_line_id is null;
-- End : code change done for Bug 21895702

BEGIN

FOR i in 1..p_header_price_adj_tbl.count LOOP
     l_header_adj_tbl(adj_count).attribute1
                      := p_header_price_adj_tbl(i).attribute1;
     l_header_adj_tbl(adj_count).attribute10
                      := p_header_price_adj_tbl(i).attribute10;
     l_header_adj_tbl(adj_count).attribute11
                      := p_header_price_adj_tbl(i).attribute11;
     l_header_adj_tbl(adj_count).attribute12
                      := p_header_price_adj_tbl(i).attribute12;
     l_header_adj_tbl(adj_count).attribute13
                      := p_header_price_adj_tbl(i).attribute13;
     l_header_adj_tbl(adj_count).attribute14
                      := p_header_price_adj_tbl(i).attribute14;
     l_header_adj_tbl(adj_count).attribute15
                      := p_header_price_adj_tbl(i).attribute15;
     l_header_adj_tbl(adj_count).attribute2
                      := p_header_price_adj_tbl(i).attribute2;
     l_header_adj_tbl(adj_count).attribute3
                      := p_header_price_adj_tbl(i).attribute3;
     l_header_adj_tbl(adj_count).attribute4
                      := p_header_price_adj_tbl(i).attribute4;
     l_header_adj_tbl(adj_count).attribute5
                      := p_header_price_adj_tbl(i).attribute5;
     l_header_adj_tbl(adj_count).attribute6
                      := p_header_price_adj_tbl(i).attribute6;
     l_header_adj_tbl(adj_count).attribute7
                      := p_header_price_adj_tbl(i).attribute7;
     l_header_adj_tbl(adj_count).attribute8
                       := p_header_price_adj_tbl(i).attribute8;
     l_header_adj_tbl(adj_count).attribute9
                       := p_header_price_adj_tbl(i).attribute9;
     l_header_adj_tbl(adj_count).automatic_flag
                       := p_header_price_adj_tbl(i).automatic_flag;
     l_header_adj_tbl(adj_count).context
                       := p_header_price_adj_tbl(i).attribute_category;

     l_header_adj_tbl(adj_count).orig_sys_discount_ref
             := p_header_price_adj_tbl(i).orig_sys_discount_ref;
     l_header_adj_tbl(adj_count).change_reason_code
             := p_header_price_adj_tbl(i).change_reason_code;
     l_header_adj_tbl(adj_count).change_reason_text
             := p_header_price_adj_tbl(i).change_reason_text;
     l_header_adj_tbl(adj_count).cost_id
             := p_header_price_adj_tbl(i).cost_id;
     l_header_adj_tbl(adj_count).tax_code
             := p_header_price_adj_tbl(i).tax_code;
     l_header_adj_tbl(adj_count).tax_exempt_flag
             := p_header_price_adj_tbl(i).tax_exempt_flag;
     l_header_adj_tbl(adj_count).tax_exempt_number
             := p_header_price_adj_tbl(i).tax_exempt_number;
     l_header_adj_tbl(adj_count).tax_exempt_reason_code
             := p_header_price_adj_tbl(i).tax_exempt_reason_code;
     l_header_adj_tbl(adj_count).parent_adjustment_id
             := p_header_price_adj_tbl(i).parent_adjustment_id;
     l_header_adj_tbl(adj_count).invoiced_flag
             := p_header_price_adj_tbl(i).invoiced_flag;
     l_header_adj_tbl(adj_count).estimated_flag
             := p_header_price_adj_tbl(i).estimated_flag;
     l_header_adj_tbl(adj_count).inc_in_sales_performance
             := p_header_price_adj_tbl(i).inc_in_sales_performance;
     l_header_adj_tbl(adj_count).split_action_code
             := p_header_price_adj_tbl(i).split_action_code;
     l_header_adj_tbl(adj_count).adjusted_amount
             := p_header_price_adj_tbl(i).adjusted_amount;
     l_header_adj_tbl(adj_count).charge_type_code
             := p_header_price_adj_tbl(i).charge_type_code;
     l_header_adj_tbl(adj_count).charge_subtype_code
             := p_header_price_adj_tbl(i).charge_subtype_code;
     l_header_adj_tbl(adj_count).RANGE_BREAK_QUANTITY
             := p_header_price_adj_tbl(i).RANGE_BREAK_QUANTITY;
     l_header_adj_tbl(adj_count).ACCRUAL_CONVERSION_RATE
             := p_header_price_adj_tbl(i).ACCRUAL_CONVERSION_RATE;
     l_header_adj_tbl(adj_count).PRICING_GROUP_SEQUENCE
             := p_header_price_adj_tbl(i).PRICING_GROUP_SEQUENCE;
     l_header_adj_tbl(adj_count).ACCRUAL_FLAG
             := p_header_price_adj_tbl(i).ACCRUAL_FLAG;
     l_header_adj_tbl(adj_count).LIST_LINE_NO
             := p_header_price_adj_tbl(i).LIST_LINE_NO;
     l_header_adj_tbl(adj_count).SOURCE_SYSTEM_CODE
             := p_header_price_adj_tbl(i).SOURCE_SYSTEM_CODE;
     l_header_adj_tbl(adj_count).BENEFIT_QTY
             := p_header_price_adj_tbl(i).BENEFIT_QTY;
     l_header_adj_tbl(adj_count).BENEFIT_UOM_CODE
             := p_header_price_adj_tbl(i).BENEFIT_UOM_CODE;
     l_header_adj_tbl(adj_count).PRINT_ON_INVOICE_FLAG
             := p_header_price_adj_tbl(i).PRINT_ON_INVOICE_FLAG;
     l_header_adj_tbl(adj_count).EXPIRATION_DATE
             := p_header_price_adj_tbl(i).EXPIRATION_DATE;
     l_header_adj_tbl(adj_count).REBATE_TRANSACTION_TYPE_CODE
             := p_header_price_adj_tbl(i).REBATE_TRANSACTION_TYPE_CODE;
     l_header_adj_tbl(adj_count).REBATE_TRANSACTION_REFERENCE
             := p_header_price_adj_tbl(i).REBATE_TRANSACTION_REFERENCE;
     l_header_adj_tbl(adj_count).REBATE_PAYMENT_SYSTEM_CODE
             := p_header_price_adj_tbl(i).REBATE_PAYMENT_SYSTEM_CODE;
     l_header_adj_tbl(adj_count).REDEEMED_DATE
             := p_header_price_adj_tbl(i).REDEEMED_DATE;
     l_header_adj_tbl(adj_count).REDEEMED_FLAG
             := p_header_price_adj_tbl(i).REDEEMED_FLAG;
     l_header_adj_tbl(adj_count).MODIFIER_LEVEL_CODE
             := p_header_price_adj_tbl(i).MODIFIER_LEVEL_CODE;
     l_header_adj_tbl(adj_count).PRICE_BREAK_TYPE_CODE
             := p_header_price_adj_tbl(i).PRICE_BREAK_TYPE_CODE;
     l_header_adj_tbl(adj_count).SUBSTITUTION_ATTRIBUTE
             := p_header_price_adj_tbl(i).SUBSTITUTION_ATTRIBUTE;
     l_header_adj_tbl(adj_count).PRORATION_TYPE_CODE
             := p_header_price_adj_tbl(i).PRORATION_TYPE_CODE;
     l_header_adj_tbl(adj_count).INCLUDE_ON_RETURNS_FLAG
             := p_header_price_adj_tbl(i).INCLUDE_ON_RETURNS_FLAG;
     l_header_adj_tbl(adj_count).CREDIT_OR_CHARGE_FLAG
             := p_header_price_adj_tbl(i).CREDIT_OR_CHARGE_FLAG;

        IF p_operation <> OE_GLOBALS.G_OPR_CREATE THEN
           l_header_adj_tbl(adj_count).header_id
                       := p_qte_rec.quote_header_id;
           l_header_adj_tbl(adj_count).price_adjustment_id
                       := p_header_price_adj_tbl(i).price_adjustment_id;
        ELSIF p_operation = OE_GLOBALS.G_OPR_CREATE THEN
	      l_header_adj_tbl(adj_count).price_adjustment_id := FND_API.G_MISS_NUM;
        END IF;

        l_header_adj_tbl(adj_count).operation := p_operation;

     l_header_adj_tbl(adj_count).list_header_id
                    := p_header_price_adj_tbl(i).modifier_header_id;
     l_header_adj_tbl(adj_count).list_line_id
                    := p_header_price_adj_tbl(i).modifier_line_id;
     l_header_adj_tbl(adj_count).list_line_type_code
                   := p_header_price_adj_tbl(i).modifier_line_type_code;
     l_header_adj_tbl(adj_count).modifier_mechanism_type_code
             := p_header_price_adj_tbl(i).modifier_mechanism_type_code;

	-- Start : code change done for Bug 21895702
	/*
     l_header_adj_tbl(adj_count).modified_from
             := p_header_price_adj_tbl(i).modified_from;
     l_header_adj_tbl(adj_count).modified_to
             := p_header_price_adj_tbl(i).modified_to; */

	If p_header_price_adj_tbl(i).modifier_line_type_code = 'TSN' Then

	   Open C_Freight_Terms(p_qte_rec.quote_header_id);
	   Fetch C_Freight_Terms Into
		     l_header_adj_tbl(adj_count).modified_to,
		     l_header_adj_tbl(adj_count).modified_from;
       Close C_Freight_Terms;
    Else
	    l_header_adj_tbl(adj_count).modified_from
             := p_header_price_adj_tbl(i).modified_from;
        l_header_adj_tbl(adj_count).modified_to
             := p_header_price_adj_tbl(i).modified_to;
    End If;
 /*
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('map_header_price_adj : l_header_adj_tbl('||adj_count||').modified_from : '||l_header_adj_tbl(adj_count).modified_from, 1, 'Y');
	   aso_debug_pub.add('map_header_price_adj : l_header_adj_tbl('||adj_count||').modified_to : '||l_header_adj_tbl(adj_count).modified_to, 1, 'Y');
    END IF;
*/
	-- End : code change done for Bug 21895702

	 l_header_adj_tbl(adj_count).updated_flag
             := p_header_price_adj_tbl(i).updated_flag;
     l_header_adj_tbl(adj_count).operand
                  := p_header_price_adj_tbl(i).operand;
     l_header_adj_tbl(adj_count).arithmetic_operator
                  := p_header_price_adj_tbl(i).arithmetic_operator;
     l_header_adj_tbl(adj_count).applied_flag
                  := p_header_price_adj_tbl(i).applied_flag;
     l_header_adj_tbl(adj_count).pricing_phase_id
                  := p_header_price_adj_tbl(i).pricing_phase_id;
     l_header_adj_tbl(adj_count).update_allowed
                  := p_header_price_adj_tbl(i).update_allowed;

     adj_count := adj_count + 1;
   END LOOP;
x_header_adj_tbl := l_header_adj_tbl;
END map_header_price_adj;


PROCEDURE    map_header_price_adj_attr(
         p_header_price_adj_attr_tbl  IN   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
         p_operation IN VARCHAR2,
         x_header_adj_att_tbl   OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Adj_Att_Tbl_Type
     )
IS

j          NUMBER;
attr_count NUMBER := 1;
l_header_adj_att_tbl  OE_Order_PUB.Header_Adj_Att_Tbl_Type;

BEGIN

   FOR j in 1..p_header_price_adj_attr_tbl.count LOOP

     l_header_adj_att_tbl(attr_count).price_adj_attrib_id
          := p_header_price_adj_attr_tbl(j).price_adj_attrib_id;
     l_header_adj_att_tbl(attr_count).price_adjustment_id
          := p_header_price_adj_attr_tbl(j).price_adjustment_id;
     l_header_adj_att_tbl(attr_count).Adj_index
          := p_header_price_adj_attr_tbl(j).price_adj_index;
     l_header_adj_att_tbl(attr_count).flex_title
          := p_header_price_adj_attr_tbl(j).flex_title;
     l_header_adj_att_tbl(attr_count).pricing_context
          := p_header_price_adj_attr_tbl(j).pricing_context;
     l_header_adj_att_tbl(attr_count).pricing_attribute
          := p_header_price_adj_attr_tbl(j).pricing_attribute;
     l_header_adj_att_tbl(attr_count).pricing_attr_value_from
          := p_header_price_adj_attr_tbl(j).pricing_attr_value_from;
     l_header_adj_att_tbl(attr_count).pricing_attr_value_to
          := p_header_price_adj_attr_tbl(j).pricing_attr_value_to;
     l_header_adj_att_tbl(attr_count).comparison_operator
          := p_header_price_adj_attr_tbl(j).comparison_operator;


        IF p_operation <> OE_GLOBALS.G_OPR_CREATE THEN
           l_header_adj_att_tbl(attr_count).price_adjustment_id
                 := p_header_price_adj_attr_tbl(j).price_adjustment_id;
           l_header_adj_att_tbl(attr_count).price_adj_attrib_id
                 := p_header_price_adj_attr_tbl(j).price_adj_attrib_id;
        ELSIF p_operation = OE_GLOBALS.G_OPR_CREATE THEN
		 l_header_adj_att_tbl(attr_count).price_adj_attrib_id
			  := FND_API.G_MISS_NUM;
        END IF;

        l_header_adj_att_tbl(attr_count).operation := p_operation;

attr_count := attr_count+1;

END LOOP;

x_header_adj_att_tbl  := l_header_adj_att_tbl;
END map_header_price_adj_attr;


PROCEDURE  map_header_price_adj_rltn(
        P_Header_Price_Adj_rltship_Tbl  IN  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
	   P_operation IN VARCHAR2,
        x_Header_Adj_Assoc_tbl   OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
     )
IS
    j  NUMBER;
    i  NUMBER := 1;
    l_Header_Adj_Assoc_tbl     OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;

BEGIN

FOR j in 1..P_header_Price_Adj_rltship_Tbl.count LOOP


  IF P_operation = OE_GLOBALS.G_OPR_CREATE THEN
	l_Header_Adj_Assoc_tbl(i).price_adj_assoc_id  :=  FND_API.G_MISS_NUM;
	l_Header_Adj_Assoc_tbl(i).Adj_index
			:=  P_Header_Price_Adj_rltship_Tbl(j).PRICE_ADJ_INDEX ;
     l_Header_Adj_Assoc_tbl(i).Rltd_Adj_Index
			:=  P_Header_Price_Adj_rltship_Tbl(j).RLTD_PRICE_ADJ_INDEX;
  ELSE
     l_Header_Adj_Assoc_tbl(i).price_adj_assoc_id
               := P_Header_Price_Adj_rltship_Tbl(j).ADJ_RELATIONSHIP_ID;
     l_Header_Adj_Assoc_tbl(i).price_adjustment_id
               := P_Header_Price_Adj_rltship_Tbl(j).PRICE_ADJUSTMENT_ID ;
     l_Header_Adj_Assoc_tbl(i).rltd_Price_Adj_Id
               := P_Header_Price_Adj_rltship_Tbl(j).RLTD_PRICE_ADJ_ID;
  END IF;

  l_Header_Adj_Assoc_tbl(i).operation  :=  P_Operation;

  i := i + 1;
END LOOP;

x_Header_Adj_Assoc_tbl := l_Header_Adj_Assoc_tbl;

END map_header_price_adj_rltn;

PROCEDURE  map_header_sales_credits(
     P_header_sales_credit_Tbl  IN  ASO_QUOTE_PUB.Sales_credit_tbl_type,
     p_operation  IN VARCHAR2,
     p_qte_rec  IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
     p_header_operation IN VARCHAR2,
     x_Header_Scredit_tbl   OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Scredit_Tbl_Type
     )
IS

l_header_Scredit_tbl   OE_Order_PUB.Header_Scredit_Tbl_Type;
j          NUMBER;
sc_count   NUMBER := 1;

CURSOR salesrep( p_resource_id NUMBER) IS
  select salesrep_id
      /* from jtf_rs_srp_vl */ --Commented Code Yogeshwar (MOAC)
      from jtf_rs_salesreps_mo_v --New Code Yogeshwar (MOAC)
   where resource_id = p_resource_id ;
   /*
        and NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
	NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(
	USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
   */

BEGIN

FOR j in 1..P_header_sales_credit_Tbl.count LOOP

   l_Header_Scredit_tbl(sc_count).attribute1
          :=  P_header_sales_credit_Tbl(j).attribute1 ;
   l_Header_Scredit_tbl(sc_count).attribute10
          :=  P_header_sales_credit_Tbl(j).attribute10;
   l_Header_Scredit_tbl(sc_count).attribute11
          :=  P_header_sales_credit_Tbl(j).attribute11;
   l_Header_Scredit_tbl(sc_count).attribute12
          :=  P_header_sales_credit_Tbl(j).attribute12;
   l_Header_Scredit_tbl(sc_count).attribute13
          :=  P_header_sales_credit_Tbl(j).attribute13;
   l_Header_Scredit_tbl(sc_count).attribute14
          :=  P_header_sales_credit_Tbl(j).attribute14;
   l_Header_Scredit_tbl(sc_count).attribute15
          :=  P_header_sales_credit_Tbl(j).attribute15;
   l_Header_Scredit_tbl(sc_count).attribute2
          :=  P_header_sales_credit_Tbl(j).attribute2;
   l_Header_Scredit_tbl(sc_count).attribute3
          :=  P_header_sales_credit_Tbl(j).attribute3;
   l_Header_Scredit_tbl(sc_count).attribute4
          :=  P_header_sales_credit_Tbl(j).attribute4;
   l_Header_Scredit_tbl(sc_count).attribute5
          :=  P_header_sales_credit_Tbl(j).attribute5;
   l_Header_Scredit_tbl(sc_count).attribute6
          :=  P_header_sales_credit_Tbl(j).attribute6;
   l_Header_Scredit_tbl(sc_count).attribute7
          :=  P_header_sales_credit_Tbl(j).attribute7;
   l_Header_Scredit_tbl(sc_count).attribute8
          :=  P_header_sales_credit_Tbl(j).attribute8;
   l_Header_Scredit_tbl(sc_count).attribute9
          :=  P_header_sales_credit_Tbl(j).attribute9;
   l_Header_Scredit_tbl(sc_count).context
          :=  P_header_sales_credit_Tbl(j).attribute_category_code;

   l_Header_Scredit_tbl(sc_count).percent
          :=  P_header_sales_credit_Tbl(j).percent;

   OPEN salesrep(  P_header_sales_credit_Tbl(j).resource_id);
   FETCH salesrep INTO l_Header_Scredit_tbl(sc_count).salesrep_id;
   CLOSE salesrep;

    /* Code added for Bug 9865459 Start */
   l_Header_Scredit_tbl(sc_count).sales_group_id
          :=  P_header_sales_credit_Tbl(j).resource_group_id;

    l_Header_Scredit_tbl(sc_count).sales_group_updated_flag := 'Y';

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('map_header_sales_credits : l_Header_Scredit_tbl(sc_count).sales_group_id :  '||l_Header_Scredit_tbl(sc_count).sales_group_id, 1, 'N');
    END IF;
    /* Code added for Bug 9865459 End */

   l_Header_Scredit_tbl(sc_count).SALES_CREDIT_TYPE_ID
              :=  P_header_sales_credit_Tbl(j).SALES_CREDIT_TYPE_ID;

    IF p_header_operation <> OE_GLOBALS.G_OPR_CREATE THEN
        l_Header_Scredit_tbl(sc_count).header_id
          :=  P_qte_rec.quote_header_id;
        l_Header_Scredit_tbl(sc_count).sales_credit_id
         :=  P_header_sales_credit_Tbl(j).sales_credit_id;
    ELSIF p_header_operation =  OE_GLOBALS.G_OPR_CREATE THEN
        l_Header_Scredit_tbl(sc_count).sales_credit_id := FND_API.G_MISS_NUM;
    END IF;

    l_Header_Scredit_tbl(sc_count).operation  := p_header_operation;

sc_count := sc_count +1;
END LOOP;
x_Header_Scredit_tbl  := l_Header_Scredit_tbl;

END map_header_sales_credits;


PROCEDURE map_line_price_att(
        p_line_price_attributes_tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
        p_line_index  IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
        p_operation IN   VARCHAR2,
        x_line_price_att_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Price_Att_Tbl_Type
        )
IS

  l  NUMBER;
  i  NUMBER;
  l_line_price_att_tbl    OE_Order_PUB.Line_Price_Att_Tbl_Type;
  p_att_count NUMBER := 1;

BEGIN

FOR l in 1..p_line_price_attributes_tbl.count LOOP
     IF ( p_line_price_attributes_tbl(l).qte_line_index = p_qte_line_index) THEN

     l_line_price_att_tbl(p_att_count).line_index    :=      p_line_index;
     l_line_price_att_tbl(p_att_count).pricing_context
          := p_line_price_attributes_tbl(l).pricing_context;
     l_line_price_att_tbl(p_att_count).pricing_attribute1
          := p_line_price_attributes_tbl(l).pricing_attribute1;
     l_line_price_att_tbl(p_att_count).pricing_attribute2
          := p_line_price_attributes_tbl(l).pricing_attribute2;
     l_line_price_att_tbl(p_att_count).pricing_attribute3
          :=  p_line_price_attributes_tbl(l).pricing_attribute3;
     l_line_price_att_tbl(p_att_count).pricing_attribute4
          :=  p_line_price_attributes_tbl(l).pricing_attribute4;
     l_line_price_att_tbl(p_att_count).pricing_attribute5
          :=  p_line_price_attributes_tbl(l).pricing_attribute5;
     l_line_price_att_tbl(p_att_count).pricing_attribute6
          :=  p_line_price_attributes_tbl(l).pricing_attribute6;
     l_line_price_att_tbl(p_att_count).pricing_attribute7
          :=  p_line_price_attributes_tbl(l).pricing_attribute7;
     l_line_price_att_tbl(p_att_count).pricing_attribute8
          :=  p_line_price_attributes_tbl(l).pricing_attribute8;
     l_line_price_att_tbl(p_att_count).pricing_attribute9
          :=  p_line_price_attributes_tbl(l).pricing_attribute9;
     l_line_price_att_tbl(p_att_count).pricing_attribute10
          :=  p_line_price_attributes_tbl(l).pricing_attribute10;
     l_line_price_att_tbl(p_att_count).pricing_attribute11
          :=  p_line_price_attributes_tbl(l).pricing_attribute11;
     l_line_price_att_tbl(p_att_count).pricing_attribute12
          :=  p_line_price_attributes_tbl(l).pricing_attribute12;
     l_line_price_att_tbl(p_att_count).pricing_attribute13
          :=  p_line_price_attributes_tbl(l).pricing_attribute13;
     l_line_price_att_tbl(p_att_count).pricing_attribute14
          :=  p_line_price_attributes_tbl(l).pricing_attribute14;
     l_line_price_att_tbl(p_att_count).pricing_attribute15
          :=  p_line_price_attributes_tbl(l).pricing_attribute15;
     l_line_price_att_tbl(p_att_count).pricing_attribute16
          :=  p_line_price_attributes_tbl(l).pricing_attribute16;
     l_line_price_att_tbl(p_att_count).pricing_attribute17
          :=  p_line_price_attributes_tbl(l).pricing_attribute17;
     l_line_price_att_tbl(p_att_count).pricing_attribute18
          :=  p_line_price_attributes_tbl(l).pricing_attribute18;
     l_line_price_att_tbl(p_att_count).pricing_attribute19
          :=  p_line_price_attributes_tbl(l).pricing_attribute19;
     l_line_price_att_tbl(p_att_count).pricing_attribute20
          :=  p_line_price_attributes_tbl(l).pricing_attribute20;
     l_line_price_att_tbl(p_att_count).pricing_attribute21
          :=  p_line_price_attributes_tbl(l).pricing_attribute21;
     l_line_price_att_tbl(p_att_count).pricing_attribute22
          :=  p_line_price_attributes_tbl(l).pricing_attribute22;
     l_line_price_att_tbl(p_att_count).pricing_attribute23
          :=  p_line_price_attributes_tbl(l).pricing_attribute23;
     l_line_price_att_tbl(p_att_count).pricing_attribute24
          :=  p_line_price_attributes_tbl(l).pricing_attribute24;
     l_line_price_att_tbl(p_att_count).pricing_attribute25
          :=  p_line_price_attributes_tbl(l).pricing_attribute25;
     l_line_price_att_tbl(p_att_count).pricing_attribute26
          :=  p_line_price_attributes_tbl(l).pricing_attribute26;
     l_line_price_att_tbl(p_att_count).pricing_attribute27
          :=  p_line_price_attributes_tbl(l).pricing_attribute27;
     l_line_price_att_tbl(p_att_count).pricing_attribute28
          :=  p_line_price_attributes_tbl(l).pricing_attribute28;
     l_line_price_att_tbl(p_att_count).pricing_attribute29
          :=  p_line_price_attributes_tbl(l).pricing_attribute29;
     l_line_price_att_tbl(p_att_count).pricing_attribute30
          :=  p_line_price_attributes_tbl(l).pricing_attribute30;
     l_line_price_att_tbl(p_att_count).pricing_attribute31
          :=  p_line_price_attributes_tbl(l).pricing_attribute31;
     l_line_price_att_tbl(p_att_count).pricing_attribute32
          :=  p_line_price_attributes_tbl(l).pricing_attribute32;
     l_line_price_att_tbl(p_att_count).pricing_attribute33
          :=  p_line_price_attributes_tbl(l).pricing_attribute33;
     l_line_price_att_tbl(p_att_count).pricing_attribute34
          :=  p_line_price_attributes_tbl(l).pricing_attribute34;
     l_line_price_att_tbl(p_att_count).pricing_attribute35
          :=  p_line_price_attributes_tbl(l).pricing_attribute35;
     l_line_price_att_tbl(p_att_count).pricing_attribute36
          :=  p_line_price_attributes_tbl(l).pricing_attribute36;
     l_line_price_att_tbl(p_att_count).pricing_attribute37
          :=  p_line_price_attributes_tbl(l).pricing_attribute37;
     l_line_price_att_tbl(p_att_count).pricing_attribute38
          :=  p_line_price_attributes_tbl(l).pricing_attribute38;
     l_line_price_att_tbl(p_att_count).pricing_attribute39
          :=  p_line_price_attributes_tbl(l).pricing_attribute39;
     l_line_price_att_tbl(p_att_count).pricing_attribute40
          :=  p_line_price_attributes_tbl(l).pricing_attribute40;
     l_line_price_att_tbl(p_att_count).pricing_attribute41
          :=  p_line_price_attributes_tbl(l).pricing_attribute41;
     l_line_price_att_tbl(p_att_count).pricing_attribute42
          :=  p_line_price_attributes_tbl(l).pricing_attribute42;
     l_line_price_att_tbl(p_att_count).pricing_attribute43
          :=  p_line_price_attributes_tbl(l).pricing_attribute43;
     l_line_price_att_tbl(p_att_count).pricing_attribute44
          :=  p_line_price_attributes_tbl(l).pricing_attribute44;
     l_line_price_att_tbl(p_att_count).pricing_attribute45
          :=  p_line_price_attributes_tbl(l).pricing_attribute45;
     l_line_price_att_tbl(p_att_count).pricing_attribute46
          :=  p_line_price_attributes_tbl(l).pricing_attribute46;
     l_line_price_att_tbl(p_att_count).pricing_attribute47
          :=  p_line_price_attributes_tbl(l).pricing_attribute47;
     l_line_price_att_tbl(p_att_count).pricing_attribute48
          :=  p_line_price_attributes_tbl(l).pricing_attribute48;
     l_line_price_att_tbl(p_att_count).pricing_attribute49
          :=  p_line_price_attributes_tbl(l).pricing_attribute49;
     l_line_price_att_tbl(p_att_count).pricing_attribute50
          :=  p_line_price_attributes_tbl(l).pricing_attribute50;
     l_line_price_att_tbl(p_att_count).pricing_attribute51
          :=  p_line_price_attributes_tbl(l).pricing_attribute51;
     l_line_price_att_tbl(p_att_count).pricing_attribute52
          :=  p_line_price_attributes_tbl(l).pricing_attribute52;
     l_line_price_att_tbl(p_att_count).pricing_attribute53
          :=  p_line_price_attributes_tbl(l).pricing_attribute53;
     l_line_price_att_tbl(p_att_count).pricing_attribute54
          :=  p_line_price_attributes_tbl(l).pricing_attribute54;
     l_line_price_att_tbl(p_att_count).pricing_attribute55
          :=  p_line_price_attributes_tbl(l).pricing_attribute55;
     l_line_price_att_tbl(p_att_count).pricing_attribute56
          :=  p_line_price_attributes_tbl(l).pricing_attribute56;
     l_line_price_att_tbl(p_att_count).pricing_attribute57
          :=  p_line_price_attributes_tbl(l).pricing_attribute57;
     l_line_price_att_tbl(p_att_count).pricing_attribute58
          :=  p_line_price_attributes_tbl(l).pricing_attribute58;
     l_line_price_att_tbl(p_att_count).pricing_attribute59
          :=  p_line_price_attributes_tbl(l).pricing_attribute59;
     l_line_price_att_tbl(p_att_count).pricing_attribute60
          :=  p_line_price_attributes_tbl(l).pricing_attribute60;
     l_line_price_att_tbl(p_att_count).pricing_attribute61
          :=  p_line_price_attributes_tbl(l).pricing_attribute61;
     l_line_price_att_tbl(p_att_count).pricing_attribute62
          :=  p_line_price_attributes_tbl(l).pricing_attribute62;
     l_line_price_att_tbl(p_att_count).pricing_attribute63
          :=  p_line_price_attributes_tbl(l).pricing_attribute63;
     l_line_price_att_tbl(p_att_count).pricing_attribute64
          :=  p_line_price_attributes_tbl(l).pricing_attribute64;
     l_line_price_att_tbl(p_att_count).pricing_attribute65
          :=  p_line_price_attributes_tbl(l).pricing_attribute65;
     l_line_price_att_tbl(p_att_count).pricing_attribute66
          :=  p_line_price_attributes_tbl(l).pricing_attribute66;
     l_line_price_att_tbl(p_att_count).pricing_attribute67
          :=  p_line_price_attributes_tbl(l).pricing_attribute67;
     l_line_price_att_tbl(p_att_count).pricing_attribute68
          :=  p_line_price_attributes_tbl(l).pricing_attribute68;
     l_line_price_att_tbl(p_att_count).pricing_attribute69
          :=  p_line_price_attributes_tbl(l).pricing_attribute69;
     l_line_price_att_tbl(p_att_count).pricing_attribute70
          :=  p_line_price_attributes_tbl(l).pricing_attribute70;
     l_line_price_att_tbl(p_att_count).pricing_attribute71
          :=  p_line_price_attributes_tbl(l).pricing_attribute71;
     l_line_price_att_tbl(p_att_count).pricing_attribute72
          :=  p_line_price_attributes_tbl(l).pricing_attribute72;
     l_line_price_att_tbl(p_att_count).pricing_attribute73
          :=  p_line_price_attributes_tbl(l).pricing_attribute73;
     l_line_price_att_tbl(p_att_count).pricing_attribute74
          :=  p_line_price_attributes_tbl(l).pricing_attribute74;
     l_line_price_att_tbl(p_att_count).pricing_attribute75
          :=  p_line_price_attributes_tbl(l).pricing_attribute75;
     l_line_price_att_tbl(p_att_count).pricing_attribute76
          :=  p_line_price_attributes_tbl(l).pricing_attribute76;
     l_line_price_att_tbl(p_att_count).pricing_attribute77
          :=  p_line_price_attributes_tbl(l).pricing_attribute77;
     l_line_price_att_tbl(p_att_count).pricing_attribute78
          :=  p_line_price_attributes_tbl(l).pricing_attribute78;
     l_line_price_att_tbl(p_att_count).pricing_attribute79
          :=  p_line_price_attributes_tbl(l).pricing_attribute79;
     l_line_price_att_tbl(p_att_count).pricing_attribute80
          :=  p_line_price_attributes_tbl(l).pricing_attribute80;
     l_line_price_att_tbl(p_att_count).pricing_attribute81
          :=  p_line_price_attributes_tbl(l).pricing_attribute81;
     l_line_price_att_tbl(p_att_count).pricing_attribute82
          :=  p_line_price_attributes_tbl(l).pricing_attribute82;
     l_line_price_att_tbl(p_att_count).pricing_attribute83
          :=  p_line_price_attributes_tbl(l).pricing_attribute83;
     l_line_price_att_tbl(p_att_count).pricing_attribute84
          :=  p_line_price_attributes_tbl(l).pricing_attribute84;
     l_line_price_att_tbl(p_att_count).pricing_attribute85
          :=  p_line_price_attributes_tbl(l).pricing_attribute85;
     l_line_price_att_tbl(p_att_count).pricing_attribute86
          :=  p_line_price_attributes_tbl(l).pricing_attribute86;
     l_line_price_att_tbl(p_att_count).pricing_attribute87
          :=  p_line_price_attributes_tbl(l).pricing_attribute87;
     l_line_price_att_tbl(p_att_count).pricing_attribute88
          :=  p_line_price_attributes_tbl(l).pricing_attribute88;
     l_line_price_att_tbl(p_att_count).pricing_attribute89
          :=  p_line_price_attributes_tbl(l).pricing_attribute89;
     l_line_price_att_tbl(p_att_count).pricing_attribute90
          :=  p_line_price_attributes_tbl(l).pricing_attribute90;
     l_line_price_att_tbl(p_att_count).pricing_attribute91
          :=  p_line_price_attributes_tbl(l).pricing_attribute91;
     l_line_price_att_tbl(p_att_count).pricing_attribute92
          :=  p_line_price_attributes_tbl(l).pricing_attribute92;
     l_line_price_att_tbl(p_att_count).pricing_attribute93
          :=  p_line_price_attributes_tbl(l).pricing_attribute93;
     l_line_price_att_tbl(p_att_count).pricing_attribute94
          :=  p_line_price_attributes_tbl(l).pricing_attribute94;
     l_line_price_att_tbl(p_att_count).pricing_attribute95
          :=  p_line_price_attributes_tbl(l).pricing_attribute95;
     l_line_price_att_tbl(p_att_count).pricing_attribute96
          :=  p_line_price_attributes_tbl(l).pricing_attribute96;
     l_line_price_att_tbl(p_att_count).pricing_attribute97
          :=  p_line_price_attributes_tbl(l).pricing_attribute97;
     l_line_price_att_tbl(p_att_count).pricing_attribute98
          :=  p_line_price_attributes_tbl(l).pricing_attribute98;
     l_line_price_att_tbl(p_att_count).pricing_attribute99
          :=  p_line_price_attributes_tbl(l).pricing_attribute99;
     l_line_price_att_tbl(p_att_count).pricing_attribute100
          :=  p_line_price_attributes_tbl(l).pricing_attribute100;

-- bug# 2020930
     l_line_price_att_tbl(p_att_count).flex_title
          :=  p_line_price_attributes_tbl(l).flex_title;
     l_line_price_att_tbl(p_att_count).context
          :=  p_line_price_attributes_tbl(l).context;
     l_line_price_att_tbl(p_att_count).attribute1
          :=  p_line_price_attributes_tbl(l).attribute1;
     l_line_price_att_tbl(p_att_count).attribute2
          :=  p_line_price_attributes_tbl(l).attribute2;
     l_line_price_att_tbl(p_att_count).attribute3
          :=  p_line_price_attributes_tbl(l).attribute3;
     l_line_price_att_tbl(p_att_count).attribute4
          :=  p_line_price_attributes_tbl(l).attribute4;
     l_line_price_att_tbl(p_att_count).attribute5
          :=  p_line_price_attributes_tbl(l).attribute5;
     l_line_price_att_tbl(p_att_count).attribute6
          :=  p_line_price_attributes_tbl(l).attribute6;
     l_line_price_att_tbl(p_att_count).attribute7
          :=  p_line_price_attributes_tbl(l).attribute7;
     l_line_price_att_tbl(p_att_count).attribute8
          :=  p_line_price_attributes_tbl(l).attribute8;
     l_line_price_att_tbl(p_att_count).attribute9
          :=  p_line_price_attributes_tbl(l).attribute9;
     l_line_price_att_tbl(p_att_count).attribute10
          :=  p_line_price_attributes_tbl(l).attribute10;
     l_line_price_att_tbl(p_att_count).attribute11
          :=  p_line_price_attributes_tbl(l).attribute11;
     l_line_price_att_tbl(p_att_count).attribute12
          :=  p_line_price_attributes_tbl(l).attribute12;
     l_line_price_att_tbl(p_att_count).attribute13
          :=  p_line_price_attributes_tbl(l).attribute13;
     l_line_price_att_tbl(p_att_count).attribute14
          :=  p_line_price_attributes_tbl(l).attribute14;
     l_line_price_att_tbl(p_att_count).attribute15
          :=  p_line_price_attributes_tbl(l).attribute15;
-- bug# 2020930 end

        IF p_operation = OE_GLOBALS.G_OPR_CREATE THEN
       	 l_line_price_att_tbl(p_att_count).order_price_attrib_id
			  := FND_API.G_MISS_NUM;
        ELSIF  p_operation = OE_GLOBALS.G_OPR_UPDATE THEN
           l_line_price_att_tbl(p_att_count).header_id
                 := p_line_price_attributes_tbl(l).quote_header_id;
        	 l_line_price_att_tbl(p_att_count).line_id
                 := p_line_price_attributes_tbl(l).quote_line_id;
           l_line_price_att_tbl(p_att_count).order_price_attrib_id
                 := p_line_price_attributes_tbl(l).price_attribute_id;
        ELSIF p_operation = OE_GLOBALS.G_OPR_DELETE THEN
           l_line_price_att_tbl(p_att_count).order_price_attrib_id
                 := p_line_price_attributes_tbl(l).price_attribute_id;
        END IF;

        l_line_price_att_tbl(p_att_count).operation := p_operation;

p_att_count := p_att_count + 1;
END IF;

END LOOP;  -- price attributes

FOR i in 1..l_line_price_att_tbl.count LOOP
  x_line_price_att_tbl(x_line_price_att_tbl.count + 1) :=
				l_line_price_att_tbl(i);
END LOOP;

END map_line_price_att;


PROCEDURE map_line_price_adj(
        p_line_price_adj_tbl  IN   ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
        p_line_price_adj_attr_tbl  IN  ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
        p_line_index  IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
        p_operation IN VARCHAR2,
        x_line_adj_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Tbl_Type,
        x_line_adj_att_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Att_Tbl_Type,
	   lx_Line_Price_Adj_rltship_Tbl IN OUT NOCOPY ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
        )
IS

  pad_count  NUMBER;
  l          NUMBER;
  i          NUMBER;
  j          NUMBER;
  adj_count  NUMBER  :=  1;
  attr_count NUMBER := 1;
  l_line_adj_tbl    OE_Order_PUB.Line_Adj_Tbl_Type
                  := OE_ORDER_PUB.G_MISS_LINE_ADJ_TBL;
  l_line_adj_att_tbl   OE_Order_PUB.Line_Adj_Att_Tbl_Type;

BEGIN

FOR pad_count in 1..p_line_price_adj_tbl.count LOOP
   IF ( p_line_price_adj_tbl(pad_count).qte_line_index = p_qte_line_index) THEN

     l_line_adj_tbl(adj_count).attribute1     := p_line_price_adj_tbl(pad_count).attribute1;
     l_line_adj_tbl(adj_count).attribute10    := p_line_price_adj_tbl(pad_count).attribute10;
     l_line_adj_tbl(adj_count).attribute11    := p_line_price_adj_tbl(pad_count).attribute11;
     l_line_adj_tbl(adj_count).attribute12    := p_line_price_adj_tbl(pad_count).attribute12;
     l_line_adj_tbl(adj_count).attribute13    := p_line_price_adj_tbl(pad_count).attribute13;
     l_line_adj_tbl(adj_count).attribute14    := p_line_price_adj_tbl(pad_count).attribute14;
     l_line_adj_tbl(adj_count).attribute15    := p_line_price_adj_tbl(pad_count).attribute15;
     l_line_adj_tbl(adj_count).attribute2     := p_line_price_adj_tbl(pad_count).attribute2;
     l_line_adj_tbl(adj_count).attribute3     := p_line_price_adj_tbl(pad_count).attribute3;
     l_line_adj_tbl(adj_count).attribute4     := p_line_price_adj_tbl(pad_count).attribute4;
     l_line_adj_tbl(adj_count).attribute5     := p_line_price_adj_tbl(pad_count).attribute5;
     l_line_adj_tbl(adj_count).attribute6     := p_line_price_adj_tbl(pad_count).attribute6;
     l_line_adj_tbl(adj_count).attribute7     := p_line_price_adj_tbl(pad_count).attribute7;
     l_line_adj_tbl(adj_count).attribute8     := p_line_price_adj_tbl(pad_count).attribute8;
     l_line_adj_tbl(adj_count).attribute9     := p_line_price_adj_tbl(pad_count).attribute9;
     l_line_adj_tbl(adj_count).context        := p_line_price_adj_tbl(pad_count).attribute_category;
     l_line_adj_tbl(adj_count).automatic_flag := p_line_price_adj_tbl(pad_count).automatic_flag;

     IF p_operation <> OE_GLOBALS.G_OPR_CREATE AND p_operation <> FND_API.G_MISS_CHAR THEN

        l_line_adj_tbl(adj_count).header_id := p_line_price_adj_tbl(pad_count).quote_header_id;
        l_line_adj_tbl(adj_count).line_id   := p_line_price_adj_tbl(pad_count).quote_line_id;

     ELSIF p_operation = OE_GLOBALS.G_OPR_CREATE THEN

        --l_line_adj_tbl(adj_count).price_adjustment_id := FND_API.G_MISS_NUM;
	l_line_adj_tbl(adj_count).price_adjustment_id := p_line_price_adj_tbl(pad_count).price_adjustment_id; -- bug 16980660

     END IF;

     l_line_adj_tbl(adj_count).operation  := p_operation;
     l_line_adj_tbl(adj_count).line_index := p_line_index;

     l_line_adj_tbl(adj_count).list_header_id      := p_line_price_adj_tbl(pad_count).modifier_header_id;
     l_line_adj_tbl(adj_count).list_line_id        := p_line_price_adj_tbl(pad_count).modifier_line_id;
     l_line_adj_tbl(adj_count).list_line_type_code := p_line_price_adj_tbl(pad_count).modifier_line_type_code;
     l_line_adj_tbl(adj_count).modified_from       := p_line_price_adj_tbl(pad_count).modified_from;
     l_line_adj_tbl(adj_count).modified_to         := p_line_price_adj_tbl(pad_count).modified_to;
     l_line_adj_tbl(adj_count).updated_flag        := p_line_price_adj_tbl(pad_count).updated_flag;
     l_line_adj_tbl(adj_count).operand             := p_line_price_adj_tbl(pad_count).operand;
     l_line_adj_tbl(adj_count).arithmetic_operator := p_line_price_adj_tbl(pad_count).arithmetic_operator;
     l_line_adj_tbl(adj_count).automatic_flag      := p_line_price_adj_tbl(pad_count).automatic_flag;
     l_line_adj_tbl(adj_count).applied_flag        := p_line_price_adj_tbl(pad_count).applied_flag;
     l_line_adj_tbl(adj_count).pricing_phase_id    := p_line_price_adj_tbl(pad_count).pricing_phase_id;
     l_line_adj_tbl(adj_count).update_allowed      := p_line_price_adj_tbl(pad_count).update_allowed;
     l_line_adj_tbl(adj_count).updated_flag        := p_line_price_adj_tbl(pad_count).updated_flag;
     l_line_adj_tbl(adj_count).updated_flag        := p_line_price_adj_tbl(pad_count).updated_flag;
     l_line_adj_tbl(adj_count).modifier_mechanism_type_code := p_line_price_adj_tbl(pad_count).modifier_mechanism_type_code;

-- added later
     l_line_adj_tbl(adj_count).orig_sys_discount_ref        := p_line_price_adj_tbl(pad_count).orig_sys_discount_ref;
     l_line_adj_tbl(adj_count).change_reason_code           := p_line_price_adj_tbl(pad_count).change_reason_code;
     l_line_adj_tbl(adj_count).change_reason_text           := p_line_price_adj_tbl(pad_count).change_reason_text;
     l_line_adj_tbl(adj_count).cost_id                      := p_line_price_adj_tbl(pad_count).cost_id;
     l_line_adj_tbl(adj_count).tax_code                     := p_line_price_adj_tbl(pad_count).tax_code;
     l_line_adj_tbl(adj_count).tax_exempt_flag              := p_line_price_adj_tbl(pad_count).tax_exempt_flag;
     l_line_adj_tbl(adj_count).tax_exempt_number            := p_line_price_adj_tbl(pad_count).tax_exempt_number;
     l_line_adj_tbl(adj_count).tax_exempt_reason_code       := p_line_price_adj_tbl(pad_count).tax_exempt_reason_code;
     l_line_adj_tbl(adj_count).parent_adjustment_id         := p_line_price_adj_tbl(pad_count).parent_adjustment_id;
     l_line_adj_tbl(adj_count).invoiced_flag                := p_line_price_adj_tbl(pad_count).invoiced_flag;
     l_line_adj_tbl(adj_count).estimated_flag               := p_line_price_adj_tbl(pad_count).estimated_flag;
     l_line_adj_tbl(adj_count).inc_in_sales_performance     := p_line_price_adj_tbl(pad_count).inc_in_sales_performance;
     l_line_adj_tbl(adj_count).split_action_code            := p_line_price_adj_tbl(pad_count).split_action_code;
     l_line_adj_tbl(adj_count).adjusted_amount              := p_line_price_adj_tbl(pad_count).adjusted_amount;
     l_line_adj_tbl(adj_count).charge_type_code             := p_line_price_adj_tbl(pad_count).charge_type_code;
     l_line_adj_tbl(adj_count).charge_subtype_code          := p_line_price_adj_tbl(pad_count).charge_subtype_code;
     l_line_adj_tbl(adj_count).RANGE_BREAK_QUANTITY         := p_line_price_adj_tbl(pad_count).RANGE_BREAK_QUANTITY;
     l_line_adj_tbl(adj_count).ACCRUAL_CONVERSION_RATE      := p_line_price_adj_tbl(pad_count).ACCRUAL_CONVERSION_RATE;
     l_line_adj_tbl(adj_count).PRICING_GROUP_SEQUENCE       := p_line_price_adj_tbl(pad_count).PRICING_GROUP_SEQUENCE;
     l_line_adj_tbl(adj_count).ACCRUAL_FLAG                 := p_line_price_adj_tbl(pad_count).ACCRUAL_FLAG;
     l_line_adj_tbl(adj_count).LIST_LINE_NO                 := p_line_price_adj_tbl(pad_count).LIST_LINE_NO;
     l_line_adj_tbl(adj_count).SOURCE_SYSTEM_CODE           := p_line_price_adj_tbl(pad_count).SOURCE_SYSTEM_CODE;
     l_line_adj_tbl(adj_count).BENEFIT_QTY                  := p_line_price_adj_tbl(pad_count).BENEFIT_QTY;
     l_line_adj_tbl(adj_count).BENEFIT_UOM_CODE             := p_line_price_adj_tbl(pad_count).BENEFIT_UOM_CODE;
     l_line_adj_tbl(adj_count).PRINT_ON_INVOICE_FLAG        := p_line_price_adj_tbl(pad_count).PRINT_ON_INVOICE_FLAG;
     l_line_adj_tbl(adj_count).EXPIRATION_DATE              := p_line_price_adj_tbl(pad_count).EXPIRATION_DATE;
     l_line_adj_tbl(adj_count).REBATE_TRANSACTION_TYPE_CODE := p_line_price_adj_tbl(pad_count).REBATE_TRANSACTION_TYPE_CODE;
     l_line_adj_tbl(adj_count).REBATE_TRANSACTION_REFERENCE := p_line_price_adj_tbl(pad_count).REBATE_TRANSACTION_REFERENCE;
     l_line_adj_tbl(adj_count).REBATE_PAYMENT_SYSTEM_CODE   := p_line_price_adj_tbl(pad_count).REBATE_PAYMENT_SYSTEM_CODE;
     l_line_adj_tbl(adj_count).REDEEMED_DATE                := p_line_price_adj_tbl(pad_count).REDEEMED_DATE;
     l_line_adj_tbl(adj_count).REDEEMED_FLAG                := p_line_price_adj_tbl(pad_count).REDEEMED_FLAG;
     l_line_adj_tbl(adj_count).MODIFIER_LEVEL_CODE          := p_line_price_adj_tbl(pad_count).MODIFIER_LEVEL_CODE;
     l_line_adj_tbl(adj_count).PRICE_BREAK_TYPE_CODE        := p_line_price_adj_tbl(pad_count).PRICE_BREAK_TYPE_CODE;
     l_line_adj_tbl(adj_count).SUBSTITUTION_ATTRIBUTE       := p_line_price_adj_tbl(pad_count).SUBSTITUTION_ATTRIBUTE;
     l_line_adj_tbl(adj_count).PRORATION_TYPE_CODE          := p_line_price_adj_tbl(pad_count).PRORATION_TYPE_CODE;
     l_line_adj_tbl(adj_count).INCLUDE_ON_RETURNS_FLAG      := p_line_price_adj_tbl(pad_count).INCLUDE_ON_RETURNS_FLAG;
     l_line_adj_tbl(adj_count).CREDIT_OR_CHARGE_FLAG        := p_line_price_adj_tbl(pad_count).CREDIT_OR_CHARGE_FLAG;
-- end added later

FOR l in 1..p_line_price_adj_attr_tbl.count LOOP

    IF p_line_price_adj_attr_tbl(l).price_adj_index = pad_count THEN

        IF p_operation = OE_GLOBALS.G_OPR_CREATE THEN
           l_line_adj_att_tbl(attr_count).price_adj_attrib_id := FND_API.G_MISS_NUM;
        ELSIF  p_operation <> OE_GLOBALS.G_OPR_CREATE THEN
           l_line_adj_att_tbl(attr_count).price_adj_attrib_id := p_line_price_adj_attr_tbl(l).price_adj_attrib_id;
           l_line_adj_att_tbl(attr_count).price_adjustment_id := p_line_price_adj_attr_tbl(l).price_adjustment_id;
        END IF;

        l_line_adj_att_tbl(attr_count).operation  := p_operation;

        l_line_adj_att_tbl(attr_count).Adj_index               := adj_count;
        l_line_adj_att_tbl(attr_count).flex_title              := p_line_price_adj_attr_tbl(l).flex_title;
        l_line_adj_att_tbl(attr_count).pricing_context         := p_line_price_adj_attr_tbl(l).pricing_context;
        l_line_adj_att_tbl(attr_count).pricing_attribute       := p_line_price_adj_attr_tbl(l).pricing_attribute;
        l_line_adj_att_tbl(attr_count).pricing_attr_value_from := p_line_price_adj_attr_tbl(l).pricing_attr_value_from;
        l_line_adj_att_tbl(attr_count).pricing_attr_value_to   := p_line_price_adj_attr_tbl(l).pricing_attr_value_to;
        l_line_adj_att_tbl(attr_count).comparison_operator     := p_line_price_adj_attr_tbl(l).comparison_operator;

        attr_count := attr_count+1;
    END IF;

END LOOP;  --price adjustment attributes

adj_count := adj_count + 1;

END IF;

-- pbh/prg
FOR j in 1..lx_Line_Price_Adj_rltship_Tbl.count LOOP
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('map_ln_rlt: p_line_price_adj_tbl(pad_count).price_adjustment_id: '||p_line_price_adj_tbl(pad_count).price_adjustment_id,1,'N');
END IF;

   IF lx_Line_Price_Adj_rltship_Tbl(j).price_adjustment_id
             = p_line_price_adj_tbl(pad_count).price_adjustment_id THEN
      lx_Line_Price_Adj_rltship_Tbl(j).price_adj_index := pad_count;
   END IF;

   IF lx_Line_Price_Adj_rltship_Tbl(j).rltd_price_adj_id
             = p_line_price_adj_tbl(pad_count).price_adjustment_id THEN
      lx_Line_Price_Adj_rltship_Tbl(j).rltd_price_adj_index := pad_count;
   END IF;

END LOOP;
-- pbh/prg

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('map_ln_rlt: lx_Line_Price_Adj_rltship_Tbl.count: '||lx_Line_Price_Adj_rltship_Tbl.count,1,'N');
END IF;

END LOOP;  --- price adjustments

FOR i IN 1..l_line_adj_tbl.count LOOP
 x_line_adj_tbl(x_line_adj_tbl.count +1 ) := l_line_adj_tbl(i);
END LOOP;

FOR i IN 1..l_line_adj_att_tbl.count LOOP
 x_line_adj_att_tbl(x_line_adj_att_tbl.count + 1)
			 := l_line_adj_att_tbl(i);
END LOOP;

END map_line_price_adj;


PROCEDURE map_line_price_adj_rltn(
        P_Line_Price_Adj_rltship_Tbl  IN   ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
        p_line_index  IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
	   p_operation  IN VARCHAR2,
        x_Line_Adj_Assoc_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
        )
IS

  l             NUMBER;
  i             NUMBER;
  adj_rlt_count NUMBER := 1;
  l_Line_Adj_Assoc_tbl  OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

BEGIN

FOR l in 1..P_Line_Price_Adj_rltship_Tbl.count LOOP
  IF P_Line_Price_Adj_rltship_Tbl(l).qte_line_index = p_qte_line_index THEN

	l_Line_Adj_Assoc_tbl(adj_rlt_count).operation  :=  p_operation;

     IF l_Line_Adj_Assoc_tbl(adj_rlt_count).operation = OE_GLOBALS.G_OPR_CREATE THEN
       l_Line_Adj_Assoc_tbl(adj_rlt_count).Adj_index
             := P_Line_Price_Adj_rltship_Tbl(l).price_adj_index;
       l_Line_Adj_Assoc_tbl(adj_rlt_count).Rltd_Adj_index
             := P_Line_Price_Adj_rltship_Tbl(l).rltd_price_adj_index;
       l_Line_Adj_Assoc_tbl(adj_rlt_count).Line_Index :=  p_line_index;
       l_line_Adj_Assoc_tbl(adj_rlt_count).price_adj_assoc_id  := FND_API.G_MISS_NUM;

     ELSIF l_Line_Adj_Assoc_tbl(adj_rlt_count).operation = OE_GLOBALS.G_OPR_UPDATE THEN

        l_Line_Adj_Assoc_tbl(adj_rlt_count).line_id
           := P_Line_Price_Adj_rltship_Tbl(l).QUOTE_LINE_ID;
        l_Line_Adj_Assoc_tbl(adj_rlt_count).price_adj_assoc_id
                 := P_Line_Price_Adj_rltship_Tbl(l).ADJ_RELATIONSHIP_ID;
        l_Line_Adj_Assoc_tbl(adj_rlt_count).price_adjustment_id
                 := P_Line_Price_Adj_rltship_Tbl(l).PRICE_ADJUSTMENT_ID ;
        l_Line_Adj_Assoc_tbl(adj_rlt_count).rltd_Price_Adj_Id
                 := P_Line_Price_Adj_rltship_Tbl(l).RLTD_PRICE_ADJ_ID;
     END IF;

     adj_rlt_count := adj_rlt_count + 1;

     END IF;

END LOOP; -- price adj rltship

FOR i in 1..l_Line_Adj_Assoc_tbl.count loop
  x_Line_Adj_Assoc_tbl(x_Line_Adj_Assoc_tbl.count + 1) :=
			  l_Line_Adj_Assoc_tbl(i);
END LOOP;

END map_line_price_adj_rltn;


PROCEDURE map_line_sales_credit(
        P_line_sales_credit_Tbl  IN   ASO_QUOTE_PUB.Sales_credit_tbl_type,
        p_line_index  IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
        p_line_operation IN VARCHAR2,
        p_operation  IN  VARCHAR2,
        x_Line_Scredit_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Tbl_Type
        )
IS

  l        NUMBER;
  i        NUMBER;
  sc_count NUMBER := 1;
  l_Line_Scredit_tbl   OE_Order_PUB.Line_Scredit_Tbl_Type;

CURSOR salesrep( p_resource_id NUMBER) IS
      select salesrep_id
       -- from jtf_rs_srp_vl Commented Code Yogeshwar (MOAC)
        from jtf_rs_salesreps_mo_v --New Code Yogeshwar (MOAC)
       where resource_id = p_resource_id ;
       --Commented Code Start Yogeshwar (MOAC)
       /*
	 and NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), '',
	  NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) = NVL(TO_NUMBER(DECODE(SUBSTRB(
	 USERENV('CLIENT_INFO'),1,1), ' ', NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99);
       */
       --Commented Code End Yogeshwar (MOAC)

BEGIN

FOR l in 1..P_line_sales_credit_Tbl.count LOOP

 IF P_line_sales_credit_Tbl(l).qte_line_index = p_qte_line_index THEN
   l_Line_Scredit_tbl(sc_count).line_index  := p_line_index;
   l_Line_Scredit_tbl(sc_count).attribute1
          :=  P_line_sales_credit_Tbl(l).attribute1 ;
   l_Line_Scredit_tbl(sc_count).attribute10
          :=  P_line_sales_credit_Tbl(l).attribute10;
   l_Line_Scredit_tbl(sc_count).attribute11
          :=  P_line_sales_credit_Tbl(l).attribute11;
   l_Line_Scredit_tbl(sc_count).attribute12
          :=  P_line_sales_credit_Tbl(l).attribute12;
   l_Line_Scredit_tbl(sc_count).attribute13
          :=  P_line_sales_credit_Tbl(l).attribute13;
   l_Line_Scredit_tbl(sc_count).attribute14
          :=  P_line_sales_credit_Tbl(l).attribute14;
   l_Line_Scredit_tbl(sc_count).attribute15
          :=  P_line_sales_credit_Tbl(l).attribute15;
   l_Line_Scredit_tbl(sc_count).attribute2
          :=  P_line_sales_credit_Tbl(l).attribute2;
   l_Line_Scredit_tbl(sc_count).attribute3
          :=  P_line_sales_credit_Tbl(l).attribute3;
   l_Line_Scredit_tbl(sc_count).attribute4
          :=  P_line_sales_credit_Tbl(l).attribute4;
   l_Line_Scredit_tbl(sc_count).attribute5
          :=  P_line_sales_credit_Tbl(l).attribute5;
   l_Line_Scredit_tbl(sc_count).attribute6
          :=  P_line_sales_credit_Tbl(l).attribute6;
   l_Line_Scredit_tbl(sc_count).attribute7
          :=  P_line_sales_credit_Tbl(l).attribute7;
   l_Line_Scredit_tbl(sc_count).attribute8
          :=  P_line_sales_credit_Tbl(l).attribute8;
   l_Line_Scredit_tbl(sc_count).attribute9
          :=  P_line_sales_credit_Tbl(l).attribute9;
   l_Line_Scredit_tbl(sc_count).context
          :=  P_line_sales_credit_Tbl(l).attribute_category_code;
   l_Line_Scredit_tbl(sc_count).percent
          :=  P_line_sales_credit_Tbl(l).percent;

    OPEN salesrep(P_line_sales_credit_Tbl(l).resource_id);
    FETCH salesrep into l_Line_Scredit_tbl(sc_count).salesrep_id;
    CLOSE salesrep;

    /* Code added for Bug 9865459 Start */
   l_Line_Scredit_tbl(sc_count).sales_group_id
          :=  P_line_sales_credit_Tbl(l).resource_group_id;

   l_Line_Scredit_tbl(sc_count).sales_group_updated_flag := 'Y';

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('map_line_sales_credit : l_line_Scredit_tbl(sc_count).sales_group_id : '||l_line_Scredit_tbl(sc_count).sales_group_id, 1, 'N');
   END IF;
   /* Code added for Bug 9865459 End */

    l_Line_Scredit_tbl(sc_count).SALES_CREDIT_TYPE_ID
            := P_line_sales_credit_Tbl(l).SALES_CREDIT_TYPE_ID;

      IF p_line_operation <> OE_GLOBALS.G_OPR_CREATE THEN
         l_Line_Scredit_tbl(sc_count).sales_credit_id
              :=  P_line_sales_credit_Tbl(l).sales_credit_id;
      ELSIF p_line_operation = OE_GLOBALS.G_OPR_CREATE THEN
         l_Line_Scredit_tbl(sc_count).sales_credit_id := FND_API.G_MISS_NUM;
      END IF;

      l_Line_Scredit_tbl(sc_count).operation := p_line_operation;

sc_count := sc_count +1;

END IF;
END LOOP;  -- salescredit

FOR i in 1..l_line_Scredit_tbl.count loop
 x_line_Scredit_tbl(x_line_Scredit_tbl.count + 1)
	  := l_line_Scredit_tbl(i);
END LOOP;

END map_line_sales_credit;

--Line Payments change

PROCEDURE map_line_payments(
        P_line_payment_Tbl  IN   ASO_QUOTE_PUB.payment_tbl_type,
        p_line_index  IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
        p_line_operation IN VARCHAR2,
        p_operation  IN  VARCHAR2,
        x_Line_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Tbl_Type,
        x_Line_Payment_tbl  IN OUT NOCOPY  OE_Order_PUB.Line_Payment_Tbl_Type
        )
IS
  i        NUMBER;
  pay_count NUMBER := 1;
  l_Line_Payment_tbl   OE_Order_PUB.Line_Payment_Tbl_Type;
  --bug8775480
  --l_line_tbl           OE_Order_PUB.Line_Tbl_Type := x_Line_tbl;
  l_om_defaulting_prof  VARCHAR2(2)
                  := NVL(FND_PROFILE.Value('ASO_OM_DEFAULTING'), 'N');
Begin
FOR i in 1..P_Line_Payment_Tbl.count LOOP

 IF P_Line_Payment_Tbl(i).qte_line_index = p_qte_line_index THEN
  l_Line_payment_tbl(pay_count).line_index  := p_line_index;

   IF (NVL(l_om_defaulting_prof, 'N') = 'Y') THEN
	IF P_Line_Payment_Tbl(i).payment_term_id IS NULL THEN
	  x_Line_tbl(p_line_index).payment_term_id :=  FND_API.G_MISS_NUM;
     ELSE
       x_Line_tbl(p_line_index).payment_term_id :=  P_Line_Payment_Tbl(i).payment_term_id;
     END IF;
   ELSE
       x_Line_tbl(p_line_index).payment_term_id :=  P_Line_Payment_Tbl(i).payment_term_id;
   END IF;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('P_Line_Payment_Tbl(i).cust_po_number: '||P_Line_Payment_Tbl(i).cust_po_number,1,'N');
aso_debug_pub.add('P_Line_Payment_Tbl(i).cust_po_line_number: '||P_Line_Payment_Tbl(i).cust_po_line_number,1,'N');
END IF;

if  (P_Line_Payment_Tbl(i).cust_po_number is not null) and (P_Line_Payment_Tbl(i).cust_po_number<>FND_API.G_MISS_CHAR) then -- bug 14754487
    x_Line_tbl(p_line_index).cust_po_number := P_Line_Payment_Tbl(i).cust_po_number;
    x_Line_tbl(p_line_index).customer_line_number := P_Line_Payment_Tbl(i).cust_po_line_number;
end if;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('P_Line_Payment_Tbl(i).payment_type_code: '||P_Line_Payment_Tbl(i).payment_type_code,1,'N');
aso_debug_pub.add('P_Line_Payment_Tbl(i).payment_amount: '||P_Line_Payment_Tbl(i).payment_amount,1,'N');
END IF;
    IF P_Line_Payment_Tbl(i).payment_type_code IS NOT NULL
       AND P_Line_Payment_Tbl(i).payment_type_code <> FND_API.G_MISS_CHAR THEN -- Code change done for Bug 17669369

      l_Line_Payment_tbl(pay_count).payment_type_code := P_Line_Payment_Tbl(i).payment_type_code;

      l_Line_Payment_tbl(pay_count).payment_amount  := P_Line_Payment_Tbl(i).payment_amount;

      l_Line_Payment_tbl(pay_count).operation := p_line_operation;

      l_Line_Payment_tbl(pay_count).trxn_extension_id := P_Line_Payment_Tbl(i).trxn_extension_id;
      l_Line_Payment_tbl(pay_count).payment_collection_event := 'INVOICE';
      l_Line_Payment_tbl(pay_count).payment_level_code := 'LINE';

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('l_Line_Payment_tbl(pay_count).payment_type_code: '||l_Line_Payment_tbl(pay_count).payment_type_code,1,'N');
aso_debug_pub.add('l_Line_Payment_tbl(pay_count).payment_amount: '||l_Line_Payment_tbl(pay_count).payment_amount,1,'N');
aso_debug_pub.add('l_Line_Payment_tbl(pay_count).operation: '||l_Line_Payment_tbl(pay_count).operation,1,'N');
aso_debug_pub.add('l_Line_Payment_tbl(pay_count).trxn_extension_id: '||l_Line_Payment_tbl(pay_count).trxn_extension_id,1,'N');
aso_debug_pub.add('l_Line_Payment_tbl(pay_count).payment_collection_event: '||l_Line_Payment_tbl(pay_count).payment_collection_event,1,'N');
aso_debug_pub.add('l_Line_Payment_tbl(pay_count).payment_level_code: '||l_Line_Payment_tbl(pay_count).payment_level_code,1,'N');
END IF;

      /* Start : code change done for Bug 9401669 */
      If (l_Line_Payment_tbl(pay_count).trxn_extension_id Is Null Or
          l_Line_Payment_tbl(pay_count).trxn_extension_id = FND_API.G_MISS_NUM ) Then

          l_Line_Payment_tbl(pay_count).CC_INSTRUMENT_ASSIGNMENT_ID := P_Line_Payment_Tbl(i).INSTR_ASSIGNMENT_ID;
          l_Line_Payment_tbl(pay_count).CC_INSTRUMENT_ID := P_Line_Payment_Tbl(i).INSTRUMENT_ID;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.add('Map_Quote_to_order : l_Line_Payment_tbl(pay_count).CC_INSTRUMENT_ASSIGNMENT_ID : '||l_Line_Payment_tbl(pay_count).CC_INSTRUMENT_ASSIGNMENT_ID, 1, 'N');
             aso_debug_pub.add('Map_Quote_to_order : l_Line_Payment_tbl(pay_count).CC_INSTRUMENT_ID : '||l_Line_Payment_tbl(pay_count).CC_INSTRUMENT_ID, 1, 'N');
	  END IF;
       End If;
      /* End : code change done for Bug 9401669 */

      IF P_Line_Payment_Tbl(i).payment_type_code = 'CHECK' THEN
          l_Line_Payment_tbl(pay_count).check_number := P_Line_Payment_Tbl(i).payment_ref_number;
      END IF;

    END IF; -- payment_type_code is not null

    -- Code Change done for Bug 14180257
    l_Line_Payment_tbl(pay_count).receipt_method_id := fnd_api.g_miss_num;
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Map_Quote_to_order : Passing line receipt method id as g miss num' ,1,'N');
    END IF;

    pay_count := pay_count +1;

   END IF;

  END LOOP;

  x_Line_Payment_tbl := l_Line_Payment_tbl;
  --x_Line_tbl  := l_Line_tbl;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('mapped line payment tblx_Line_Payment_tbl.count'||x_Line_Payment_tbl.count,1,'N');
aso_debug_pub.add('mapped line payment tbl',1,'N');
aso_debug_pub.add('mapped line payment tblx_Line_tbl.count'||x_Line_tbl.count,1,'N');
END IF;


end map_line_payments;

PROCEDURE map_lot_serial(
        P_lot_serial_tbl  IN  ASO_QUOTE_PUB.Lot_Serial_Tbl_Type,
        p_operation IN VARCHAR2,
        p_line_index IN  NUMBER,
        p_qte_line_index  IN  NUMBER,
        x_lot_serial_tbl  OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Lot_Serial_Tbl_Type
        )
IS

l             NUMBER;
lot_srl_count NUMBER :=1;
l_lot_serial_tbl  OE_Order_PUB.Lot_Serial_Tbl_Type;

BEGIN

   For l in 1..P_lot_serial_tbl.count LOOP

     IF P_lot_serial_tbl(l).line_index = p_qte_line_index THEN


     l_lot_serial_tbl(lot_srl_count).attribute1
               :=   P_lot_serial_tbl(l).attribute1;
     l_lot_serial_tbl(lot_srl_count).attribute10
               :=   P_lot_serial_tbl(l).attribute10 ;
     l_lot_serial_tbl(lot_srl_count).attribute11
               :=   P_lot_serial_tbl(l).attribute11 ;
     l_lot_serial_tbl(lot_srl_count).attribute12
               :=   P_lot_serial_tbl(l).attribute12;
     l_lot_serial_tbl(lot_srl_count).attribute13
               :=   P_lot_serial_tbl(l).attribute13 ;
     l_lot_serial_tbl(lot_srl_count).attribute14
               :=   P_lot_serial_tbl(l).attribute14  ;
     l_lot_serial_tbl(lot_srl_count).attribute15
               :=   P_lot_serial_tbl(l).attribute15 ;
     l_lot_serial_tbl(lot_srl_count).attribute2
               :=   P_lot_serial_tbl(l).attribute2 ;
     l_lot_serial_tbl(lot_srl_count).attribute3
               :=   P_lot_serial_tbl(l).attribute3;
     l_lot_serial_tbl(lot_srl_count).attribute4
               :=   P_lot_serial_tbl(l).attribute4;
     l_lot_serial_tbl(lot_srl_count).attribute5
               :=   P_lot_serial_tbl(l).attribute5;
     l_lot_serial_tbl(lot_srl_count).attribute6
               :=   P_lot_serial_tbl(l).attribute6;
     l_lot_serial_tbl(lot_srl_count).attribute7
               :=   P_lot_serial_tbl(l).attribute7;
     l_lot_serial_tbl(lot_srl_count).attribute8
               :=   P_lot_serial_tbl(l).attribute8;
     l_lot_serial_tbl(lot_srl_count).attribute9
               :=   P_lot_serial_tbl(l).attribute9;
     l_lot_serial_tbl(lot_srl_count).context
               :=   P_lot_serial_tbl(l).context ;
     l_lot_serial_tbl(lot_srl_count).created_by
               :=   P_lot_serial_tbl(l).created_by  ;
     l_lot_serial_tbl(lot_srl_count).creation_date
               :=   P_lot_serial_tbl(l).creation_date;
     l_lot_serial_tbl(lot_srl_count).from_serial_number
               :=   P_lot_serial_tbl(l).from_serial_number ;
     l_lot_serial_tbl(lot_srl_count).last_updated_by
               :=   P_lot_serial_tbl(l).last_updated_by ;
     l_lot_serial_tbl(lot_srl_count).last_update_date
               :=   P_lot_serial_tbl(l).last_update_date;
     l_lot_serial_tbl(lot_srl_count).last_update_login
               :=   P_lot_serial_tbl(l).last_update_login;
--   l_lot_serial_tbl(lot_srl_count).line_id
--             :=   P_lot_serial_tbl(l).line_id;
     l_lot_serial_tbl(lot_srl_count).lot_number
               :=   P_lot_serial_tbl(l).lot_number;
     l_lot_serial_tbl(lot_srl_count).lot_serial_id
               :=   P_lot_serial_tbl(l).lot_serial_id;
     l_lot_serial_tbl(lot_srl_count).quantity
               :=   P_lot_serial_tbl(l).quantity  ;
     l_lot_serial_tbl(lot_srl_count).to_serial_number
               :=   P_lot_serial_tbl(l).to_serial_number;
     l_lot_serial_tbl(lot_srl_count).return_status
               :=   P_lot_serial_tbl(l).return_status;
     l_lot_serial_tbl(lot_srl_count).db_flag
               :=   P_lot_serial_tbl(l).db_flag;
     l_lot_serial_tbl(lot_srl_count).operation
               :=   P_lot_serial_tbl(l).operation ;
     l_lot_serial_tbl(lot_srl_count).line_index   :=  p_line_index;
     l_lot_serial_tbl(lot_srl_count).orig_sys_lotserial_ref
               :=   P_lot_serial_tbl(l).orig_sys_lotserial_ref ;
     l_lot_serial_tbl(lot_srl_count).change_request_code
               :=   P_lot_serial_tbl(l).change_request_code;
     l_lot_serial_tbl(lot_srl_count).status_flag
               :=   P_lot_serial_tbl(l).status_flag;
     l_lot_serial_tbl(lot_srl_count).line_set_id
               :=   P_lot_serial_tbl(l).line_set_id ;

        IF p_operation <> OE_GLOBALS.G_OPR_CREATE THEN
           l_lot_serial_tbl(lot_srl_count).line_id
               :=   P_lot_serial_tbl(l).line_id;
        END IF;

        l_lot_serial_tbl(lot_srl_count).operation := p_operation;

     lot_srl_count := lot_srl_count + 1;

   END IF;
  END LOOP;  -- lot serial LOOP

x_lot_serial_tbl := l_lot_serial_tbl;

END map_lot_serial;


End ASO_MAP_QUOTE_ORDER_INT;

/
