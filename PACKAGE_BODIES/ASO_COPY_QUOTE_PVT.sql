--------------------------------------------------------
--  DDL for Package Body ASO_COPY_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_COPY_QUOTE_PVT" AS
/* $Header: asovcpyb.pls 120.18.12010000.42 2016/07/29 07:43:51 akushwah ship $ */
-- Start of Comments
-- Package name     : ASO_COPY_QUOTE_PVT
-- Purpose         :
-- History         :
--    12-03-2002 hyang - bug 2692785, checking running concurrent pricing request.
--    10-13-2003 hyang - new okc integration.
--    06/21/04   skulkarn - fixed bug 3704719
--    08/05/04   skulkarn - fixed bug3805575
--    12/02/04   skulkarn - fixed bug4036748
-- NOTE       :
-- End of Comments


   G_USER_ID     NUMBER                := FND_GLOBAL.USER_ID;
   G_LOGIN_ID    NUMBER                := FND_GLOBAL.CONC_LOGIN_ID;
   G_PKG_NAME CONSTANT VARCHAR2 ( 30 ) := 'ASO_COPY_QUOTE_PVT';
   G_FILE_NAME CONSTANT VARCHAR2 ( 12 ) := 'asovcpyb.pls';


   PROCEDURE Copy_Quote (
       P_Api_Version_Number IN NUMBER
    , P_Init_Msg_List IN VARCHAR2 := FND_API.G_FALSE
    , P_Commit IN VARCHAR2 := FND_API.G_FALSE
    , P_Copy_Quote_Header_Rec IN ASO_COPY_QUOTE_PUB.Copy_Quote_Header_Rec_Type
            := ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Header_Rec
    , P_Copy_Quote_Control_Rec IN ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type
            := ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Control_Rec
    /* Code change for Quoting Usability Sun ER Start */
    , P_Qte_Header_Rec          IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type        := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec
    , P_Hd_Shipment_Rec         IN  ASO_QUOTE_PUB.Shipment_Rec_Type          := ASO_QUOTE_PUB.G_MISS_Shipment_Rec
    , P_hd_Payment_Tbl	        IN  ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL
    , P_hd_Tax_Detail_Tbl	IN  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl
    /* Code change for Quoting Usability Sun ER End */
    , X_Qte_Header_Id OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Qte_Number OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    ) IS

      CURSOR C_Validate_Quote (
          x_qte_header_id NUMBER
       ) IS
         SELECT 'X'
         FROM   ASO_QUOTE_HEADERS_ALL
         WHERE  quote_header_id = x_qte_header_id;

      CURSOR C_Qte_Number IS
         SELECT ASO_QUOTE_NUMBER_S.NEXTVAL
         FROM   sys.DUAL;

      CURSOR C_Qte_Status_Id (
          c_status_code VARCHAR2
       ) IS
         SELECT quote_status_id
         FROM   ASO_QUOTE_STATUSES_B
         WHERE  status_code = c_status_code;

      CURSOR C_Qte_Number_exists (
          X_qte_number NUMBER
       ) IS
         SELECT quote_number
         FROM   ASO_QUOTE_HEADERS_ALL
         WHERE  quote_number = X_qte_number;

      CURSOR C_Curr_Qte_Info (
          qte_numb NUMBER
       ) IS
         SELECT quote_status_id, quote_header_id, quote_version
         FROM   ASO_QUOTE_HEADERS_ALL
         WHERE  quote_number = qte_numb
         AND    max_version_flag = 'Y';

      CURSOR C_Check_Qte_Status (
          qte_status_id NUMBER
       ) IS
         SELECT 'X'
         FROM   ASO_QUOTE_STATUSES_B
         WHERE  quote_status_id = qte_status_id
         AND    status_code NOT IN ('ORDER SUBMITTED'
                                  , 'APPROVAL PENDING'
                                  , 'FINANCING PENDING'
                                    );

      CURSOR C_Get_Qte_Num (
          qte_hdr_id NUMBER
       ) IS
         SELECT Quote_Number
         FROM   ASO_QUOTE_HEADERS_ALL
         WHERE  Quote_Header_Id = qte_hdr_id;

      l_api_name CONSTANT VARCHAR2 ( 30 ) := 'Copy_quote';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status VARCHAR2 ( 1 );
      l_val VARCHAR2 ( 1 );
      l_enabled_flag VARCHAR2 ( 1 );
      -- l_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type;
      l_qte_header_rec  ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;  -- code change done for Bug 18942516
      l_HEADER_RELATIONSHIP_ID NUMBER;
      l_qte_num NUMBER;
      l_qte_header_id NUMBER;
      l_qte_status_id NUMBER;
      l_dummy VARCHAR2 ( 2 );
      lx_Price_Index_Link_Tbl ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type;
      G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
      G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
      X_New_Qte_Line_Id  NUMBER;
      -- hyang: for bug 2692785
      lx_status                     VARCHAR2(1);
      l_copy_line_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type;

       -- ER 3177722
       lx_config_tbl                  ASO_QUOTE_PUB.Config_Vaild_Tbl_Type;
       l_copy_config_profile     varchar2(1):=nvl(fnd_profile.value('ASO_COPY_CONFIG_EFF_DATE'),'Y');

      -- vtariker Price/Tax enh
      CURSOR C_Get_Last_Upd_Date (
          qte_hdr_id NUMBER
       ) IS
         SELECT last_update_date
         FROM aso_quote_headers_all
         WHERE quote_header_id = qte_hdr_id;

      CURSOR C_Get_RSA ( l_qte_hdr_id NUMBER) IS
	 Select assistance_requested
	 FROM   aso_quote_headers_all
	 WHERE  quote_header_id = l_qte_hdr_id;


      CURSOR get_note_id ( l_qte_hdr_id NUMBER) IS
	 Select jtf_note_id
	 FROM   jtf_notes_vl
	 WHERE  note_type = 'QOT_SALES_ASSIST'
      AND    source_object_id  = l_qte_hdr_id;

      /* commented for Bug 22512986
	  -- Start : Code change done for Bug 12674665

      CURSOR C_Agreement_PL(p_agreement_id Number) Is
      Select pri.list_header_id, pri.currency_code
      from OE_AGREEMENTS_B agr, qp_list_headers_vl pri
      where agr.agreement_id = p_agreement_id
      and pri.list_header_id = agr.price_list_id
      and pri.list_type_code in ('PRL','AGR')
      and pri.active_flag = 'Y'
      and trunc(nvl(pri.start_date_active, sysdate)) <= trunc(sysdate)
      and trunc(nvl(pri.end_date_active, sysdate)) >= trunc(sysdate);

      CURSOR C_Customer_PL(p_cust_acct_id Number) Is
      Select pri.list_header_id , pri.currency_code
      from HZ_CUST_ACCOUNTS cust, qp_list_headers_vl pri
      where cust.cust_account_id = p_cust_acct_id
      and cust.price_list_id = pri.list_header_id
      and pri.list_type_code in ('PRL','AGR')
      and pri.active_flag = 'Y'
      and trunc(nvl(pri.start_date_active, sysdate)) <= trunc(sysdate)
      and trunc(nvl(pri.end_date_active, sysdate)) >= trunc(sysdate);

      CURSOR C_Order_Type_PL(p_order_type_id Number) Is
      Select pri.list_header_id, pri.currency_code
      from OE_TRANSACTION_TYPES_ALL ord, qp_list_headers_vl pri
      where ord.TRANSACTION_TYPE_ID = p_order_type_id
      and ord.price_list_id = pri.list_header_id
      and pri.list_type_code in ('PRL','AGR')
      and pri.active_flag = 'Y'
      and trunc(nvl(pri.start_date_active, sysdate)) <= trunc(sysdate)
      and trunc(nvl(pri.end_date_active, sysdate)) >= trunc(sysdate);

      -- End : Code change done for Bug 12674665
	  commented for Bug 22512986 */

      l_upd_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_MISS_qte_header_rec;
	 l_control_rec    ASO_QUOTE_PUB.Control_Rec_Type;
      x_qte_header_rec              aso_quote_pub.qte_header_rec_type;
      x_qte_line_tbl                aso_quote_pub.qte_line_tbl_type;
      x_qte_line_dtl_tbl            aso_quote_pub.qte_line_dtl_tbl_type;
      x_hd_price_attributes_tbl     aso_quote_pub.price_attributes_tbl_type;
      x_hd_payment_tbl              aso_quote_pub.payment_tbl_type;
      x_hd_shipment_tbl             aso_quote_pub.shipment_tbl_type;
      x_hd_freight_charge_tbl       aso_quote_pub.freight_charge_tbl_type;
      x_hd_tax_detail_tbl           aso_quote_pub.tax_detail_tbl_type;
      x_line_attr_ext_tbl           aso_quote_pub.line_attribs_ext_tbl_type;
      x_line_rltship_tbl            aso_quote_pub.line_rltship_tbl_type;
      x_price_adjustment_tbl        aso_quote_pub.price_adj_tbl_type;
      x_price_adj_attr_tbl          aso_quote_pub.price_adj_attr_tbl_type;
      x_price_adj_rltship_tbl       aso_quote_pub.price_adj_rltship_tbl_type;
      x_ln_price_attributes_tbl     aso_quote_pub.price_attributes_tbl_type;
      x_ln_payment_tbl              aso_quote_pub.payment_tbl_type;
      x_ln_shipment_tbl             aso_quote_pub.shipment_tbl_type;
      x_ln_freight_charge_tbl       aso_quote_pub.freight_charge_tbl_type;
      x_ln_tax_detail_tbl           aso_quote_pub.tax_detail_tbl_type;
      -- vtariker Price/Tax enh

      -- hyang new okc
      l_terms_template_name               VARCHAR2(240);
      l_target_doc_type                   VARCHAR2(30);
      l_target_doc_id                     NUMBER;
      -- end of hyang new okc
      lx_jtf_note_context_id              NUMBER;
      l_note_id                           NUMBER;
      l_rsa                               varchar2(1);
      l_copy_for_amendment                varchar2(1);
	 l_copy_abstract_yn                  varchar2(1);
      l_has_terms                         varchar2(1):= 'N';

      /* Code change for Quoting Usability Sun ER Start */
      CURSOR C_AGREEMENT(P_AGREEMENT_ID IN NUMBER,P_INVOICE_TO_CUSTOMER_ID IN NUMBER) IS
      SELECT 'x'
      FROM OE_AGREEMENTS_VL
      WHERE AGREEMENT_ID = P_AGREEMENT_ID
      AND  INVOICE_TO_CUSTOMER_ID = P_INVOICE_TO_CUSTOMER_ID;

      l_var varchar2(1);
      l_sales_team_prof  VARCHAR2(30) := FND_PROFILE.value('ASO_AUTO_TEAM_ASSIGN');
      /* Code change for Quoting Usability Sun ER End */

   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT COPY_QUOTE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
                 l_api_version_number
              , p_api_version_number
              , l_api_name
              , G_PKG_NAME
              ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean ( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ) THEN
         FND_MESSAGE.Set_Name ('ASO' , 'Copy Quote API: Start' );
         FND_MSG_PUB.ADD;
      END IF;

      --  Initialize API return status to success
      l_return_status            := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--
-- ******************************************************************
-- Validate Environment
-- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL THEN
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'UT_CANNOT_GET_PROFILE_VALUE' );
            FND_MESSAGE.Set_Token ('PROFILE' , 'USER_ID', FALSE );
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

-- ******************************************************************



      OPEN C_Validate_Quote ( P_Copy_Quote_Header_Rec.Quote_Header_Id );
      FETCH C_Validate_Quote INTO l_val;

      IF C_Validate_Quote%NOTFOUND THEN
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
            FND_MESSAGE.Set_Token ('COLUMN' , 'ORIGINAL_QUOTE_ID', FALSE );
            FND_MESSAGE.Set_Token ( 'VALUE' , TO_CHAR ( P_Copy_Quote_Header_Rec.Quote_Header_Id ) , FALSE );
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE C_Validate_Quote;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      CLOSE C_Validate_Quote;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Quote - Begin- ASO_COPY_QUOTE_PVT.Copy_Quote ' , 1 , 'Y' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Header_Rec.Quote_Header_Id: ' || P_Copy_Quote_Header_Rec.Quote_Header_Id , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Header_Only ' || P_Copy_Quote_Control_Rec.Copy_Header_Only , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.New_Version ' || P_Copy_Quote_Control_Rec.New_Version , 1 , 'N' );

      /* Code change for Quoting Usability Sun ER Start */
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Note: ' || P_Copy_Quote_Control_Rec.Copy_Note, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Task: ' || P_Copy_Quote_Control_Rec.Copy_Task, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Attachment: ' || P_Copy_Quote_Control_Rec.Copy_Attachment, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Shipping: ' || P_Copy_Quote_Control_Rec.Copy_Shipping, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Billing: ' || P_Copy_Quote_Control_Rec.Copy_Billing, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Payment: ' || P_Copy_Quote_Control_Rec.Copy_Payment, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_End_Customer: ' || P_Copy_Quote_Control_Rec.Copy_End_Customer , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Sales_Supplement: ' || P_Copy_Quote_Control_Rec.Copy_Sales_Supplement , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Flexfield: ' || P_Copy_Quote_Control_Rec.Copy_Flexfield , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Sales_Credit: ' || P_Copy_Quote_Control_Rec.Copy_Sales_Credit, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Contract_Terms: ' || P_Copy_Quote_Control_Rec.Copy_Contract_Terms, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Sales_Team: ' || P_Copy_Quote_Control_Rec.Copy_Sales_Team, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Line_Shipping: ' || P_Copy_Quote_Control_Rec.Copy_Line_Shipping, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Line_Billing: ' || P_Copy_Quote_Control_Rec.Copy_Line_Billing, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Line_Payment: ' || P_Copy_Quote_Control_Rec.Copy_Line_Payment, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Line_End_Customer: ' || P_Copy_Quote_Control_Rec.Copy_Line_End_Customer, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Line_Sales_Supplement: ' || P_Copy_Quote_Control_Rec.Copy_Line_Sales_Supplement, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Line_Attachment: ' || P_Copy_Quote_Control_Rec.Copy_Line_Attachment, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Line_Flexfield: ' || P_Copy_Quote_Control_Rec.Copy_Line_Flexfield, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_Line_Sales_Credit: ' || P_Copy_Quote_Control_Rec.Copy_Line_Sales_Credit, 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_To_Same_Customer: ' || P_Copy_Quote_Control_Rec.Copy_To_Same_Customer, 1 , 'N' );
      /* Code change for Quoting Usability Sun ER End */

      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Header_Rec.Quote_Number ' || P_Copy_Quote_Header_Rec.Quote_Number , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Header_Rec.Resource_Id ' || P_Copy_Quote_Header_Rec.Resource_Id , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Header_Rec.Resource_Grp_Id ' || P_Copy_Quote_Header_Rec.Resource_Grp_Id , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Header_Rec.Quote_Name ' || P_Copy_Quote_Header_Rec.Quote_Name , 1 , 'N' );

      END IF;

      l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row ( P_Copy_Quote_Header_Rec.Quote_Header_Id );

      /* Code change for Quoting Usability Sun ER Start */
      If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Copy_To_Same_Customer is False ', 1 , 'N' );
	 END IF;

	 -- for change customer , initializing quote header attributes with defaulted input header values

	 l_qte_header_rec.CUST_ACCOUNT_ID            := P_Qte_Header_Rec.CUST_ACCOUNT_ID;
	 l_qte_header_rec.CUST_PARTY_ID              := P_Qte_Header_Rec.CUST_PARTY_ID;
	 l_qte_header_rec.PARTY_ID                   := P_Qte_Header_Rec.PARTY_ID;

	 -- Start : code change done for Bug 23299200
	 l_qte_header_rec.INVOICE_TO_CUST_ACCOUNT_ID := P_Qte_Header_Rec.CUST_ACCOUNT_ID;
	 l_qte_header_rec.INVOICE_TO_CUST_PARTY_ID   := P_Qte_Header_Rec.CUST_PARTY_ID;

	 -- Start : code change done for Bug 24304297
	 l_qte_header_rec.SOLD_TO_PARTY_SITE_ID      := FND_API.G_MISS_NUM;

	 l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID   := FND_API.G_MISS_NUM;
	 l_qte_header_rec.INVOICE_TO_PARTY_NAME          := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_CONTACT_FIRST_NAME  := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_CONTACT_MIDDLE_NAME := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_CONTACT_LAST_NAME   := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_ADDRESS1            := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_ADDRESS2            := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_ADDRESS3            := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_ADDRESS4            := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_COUNTRY_CODE        := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_COUNTRY             := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_CITY                := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_POSTAL_CODE         := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_STATE               := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_PROVINCE            := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.INVOICE_TO_COUNTY              := FND_API.G_MISS_CHAR;

	 l_qte_header_rec.END_CUSTOMER_PARTY_ID          := FND_API.G_MISS_NUM;
	 l_qte_header_rec.END_CUSTOMER_PARTY_SITE_ID     := FND_API.G_MISS_NUM;
	 l_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID   := FND_API.G_MISS_NUM;
	 l_qte_header_rec.END_CUSTOMER_CUST_PARTY_ID     := FND_API.G_MISS_NUM;

	 l_qte_header_rec.MARKETING_SOURCE_CODE_ID       := FND_API.G_MISS_NUM;
	 l_qte_header_rec.MARKETING_SOURCE_NAME          := FND_API.G_MISS_CHAR;
	 l_qte_header_rec.MARKETING_SOURCE_CODE          := FND_API.G_MISS_CHAR;
	 -- End : code change done for Bug 24304297

	 /*
	 l_qte_header_rec.SOLD_TO_PARTY_SITE_ID      := P_Qte_Header_Rec.SOLD_TO_PARTY_SITE_ID;

	 l_qte_header_rec.INVOICE_TO_CUST_ACCOUNT_ID := P_Qte_Header_Rec.INVOICE_TO_CUST_ACCOUNT_ID ;
	 l_qte_header_rec.INVOICE_TO_CUST_PARTY_ID   := P_Qte_Header_Rec.INVOICE_TO_CUST_PARTY_ID;
	 l_qte_header_rec.INVOICE_TO_PARTY_ID        := P_Qte_Header_Rec.INVOICE_TO_PARTY_ID;
	 l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID   := P_Qte_Header_Rec.INVOICE_TO_PARTY_SITE_ID;	*/
	 -- End : code change done for Bug 23299200

	 -- Start : Code Change done for Bug 19509297
	 l_qte_header_rec.PRICE_LIST_ID := Null;
	 l_qte_header_rec.CURRENCY_CODE := Null;
	 -- End : Code Change done for Bug 19509297

         /* Commented out code to add call to api ASO_DEFAULTING_INT.Default_Entity for Bug 18942516

	 l_qte_header_rec.CUST_ACCOUNT_ID                := P_Qte_Header_Rec.CUST_ACCOUNT_ID;
	 l_qte_header_rec.CUST_PARTY_ID                  := P_Qte_Header_Rec.CUST_PARTY_ID;
	 l_qte_header_rec.PARTY_ID                       := P_Qte_Header_Rec.PARTY_ID;
	 l_qte_header_rec.SOLD_TO_PARTY_SITE_ID          := P_Qte_Header_Rec.SOLD_TO_PARTY_SITE_ID;
	 l_qte_header_rec.PHONE_ID                       := P_Qte_Header_Rec.PHONE_ID;

	 l_qte_header_rec.INVOICE_TO_CUST_ACCOUNT_ID     := P_Qte_Header_Rec.INVOICE_TO_CUST_ACCOUNT_ID ;
	 l_qte_header_rec.INVOICE_TO_CUST_PARTY_ID       := P_Qte_Header_Rec.INVOICE_TO_CUST_PARTY_ID;
	 l_qte_header_rec.INVOICE_TO_PARTY_ID            := P_Qte_Header_Rec.INVOICE_TO_PARTY_ID;
	 l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID       := P_Qte_Header_Rec.INVOICE_TO_PARTY_SITE_ID;
	 l_qte_header_rec.INVOICE_TO_PARTY_NAME          := P_Qte_Header_Rec.INVOICE_TO_PARTY_NAME;
	 l_qte_header_rec.INVOICE_TO_CONTACT_FIRST_NAME  := P_Qte_Header_Rec.INVOICE_TO_CONTACT_FIRST_NAME;
	 l_qte_header_rec.INVOICE_TO_CONTACT_MIDDLE_NAME := P_Qte_Header_Rec.INVOICE_TO_CONTACT_MIDDLE_NAME;
	 l_qte_header_rec.INVOICE_TO_CONTACT_LAST_NAME   := P_Qte_Header_Rec.INVOICE_TO_CONTACT_LAST_NAME;
	 l_qte_header_rec.INVOICE_TO_ADDRESS1            := P_Qte_Header_Rec.INVOICE_TO_ADDRESS1;
	 l_qte_header_rec.INVOICE_TO_ADDRESS2            := P_Qte_Header_Rec.INVOICE_TO_ADDRESS2;
	 l_qte_header_rec.INVOICE_TO_ADDRESS3            := P_Qte_Header_Rec.INVOICE_TO_ADDRESS3;
	 l_qte_header_rec.INVOICE_TO_ADDRESS4            := P_Qte_Header_Rec.INVOICE_TO_ADDRESS4;
	 l_qte_header_rec.INVOICE_TO_COUNTRY_CODE        := P_Qte_Header_Rec.INVOICE_TO_COUNTRY_CODE;
	 l_qte_header_rec.INVOICE_TO_COUNTRY             := P_Qte_Header_Rec.INVOICE_TO_COUNTRY;
	 l_qte_header_rec.INVOICE_TO_CITY                := P_Qte_Header_Rec.INVOICE_TO_CITY;
	 l_qte_header_rec.INVOICE_TO_POSTAL_CODE         := P_Qte_Header_Rec.INVOICE_TO_POSTAL_CODE;
	 l_qte_header_rec.INVOICE_TO_STATE               := P_Qte_Header_Rec.INVOICE_TO_STATE;
	 l_qte_header_rec.INVOICE_TO_PROVINCE            := P_Qte_Header_Rec.INVOICE_TO_PROVINCE;
	 l_qte_header_rec.INVOICE_TO_COUNTY              := P_Qte_Header_Rec.INVOICE_TO_COUNTY;

	 l_qte_header_rec.END_CUSTOMER_PARTY_ID          := P_Qte_Header_Rec.END_CUSTOMER_PARTY_ID;
	 l_qte_header_rec.END_CUSTOMER_PARTY_SITE_ID     := P_Qte_Header_Rec.END_CUSTOMER_PARTY_SITE_ID;
	 l_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID   := P_Qte_Header_Rec.END_CUSTOMER_CUST_ACCOUNT_ID;
	 l_qte_header_rec.END_CUSTOMER_CUST_PARTY_ID     := P_Qte_Header_Rec.END_CUSTOMER_CUST_PARTY_ID;

	 l_qte_header_rec.MARKETING_SOURCE_CODE_ID       := P_Qte_Header_Rec.MARKETING_SOURCE_CODE_ID;
	 l_qte_header_rec.MARKETING_SOURCE_NAME          := P_Qte_Header_Rec.MARKETING_SOURCE_NAME;
	 l_qte_header_rec.MARKETING_SOURCE_CODE          := P_Qte_Header_Rec.MARKETING_SOURCE_CODE;

	 -- l_qte_header_rec.PRICE_LIST_ID                  := P_Qte_Header_Rec.PRICE_LIST_ID; commented for Bug 12674665

	 -- un-commented following code which was commented for Bug 13569621 , this done code change as per Bug 12879412
	 -- ER 12879412
    /*  Commented since defaulting would be in phase 2 of the ER
         l_qte_header_rec.PRODUCT_FISC_CLASSIFICATION := P_Qte_Header_Rec.PRODUCT_FISC_CLASSIFICATION;
         l_qte_header_rec.TRX_BUSINESS_CATEGORY := P_Qte_Header_Rec.TRX_BUSINESS_CATEGORY; */

	 /* commented for bug Bug 12674665
	 If (P_Qte_Header_Rec.CURRENCY_CODE Is Not Null And
	     P_Qte_Header_Rec.currency_code <> FND_API.G_MISS_CHAR) Then
	     l_qte_header_rec.CURRENCY_CODE := P_Qte_Header_Rec.CURRENCY_CODE;
         End If; */

         -- Check for Pricing Agreement
	 IF (l_qte_header_rec.CONTRACT_ID IS NOT NULL AND
	     l_qte_header_rec.CONTRACT_ID <> FND_API.G_MISS_NUM) THEN

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
	        aso_debug_pub.ADD ( 'Copy_Quote - l_qte_header_rec.contract_id : '||l_qte_header_rec.contract_id, 1 , 'N' );
		aso_debug_pub.ADD ( 'Copy_Quote - l_qte_header_rec.INVOICE_TO_CUST_ACCOUNT_ID : '||l_qte_header_rec.INVOICE_TO_CUST_ACCOUNT_ID, 1 , 'N' );
	     END IF;

             Open C_AGREEMENT(l_qte_header_rec.CONTRACT_ID,l_qte_header_rec.INVOICE_TO_CUST_ACCOUNT_ID);
	     Fetch C_AGREEMENT Into l_var;

	     If C_AGREEMENT%NotFound Then
	        l_qte_header_rec.CONTRACT_ID := Null;
	     End If;
	     Close C_AGREEMENT; -- added as per bug 11735688
         End If;

	 /* commented for Bug 22512986
	 -- Start : Code change done for Bug 12674665

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Quote - Price List defaulting starting', 1 , 'N' );
	    aso_debug_pub.ADD ( 'Copy_Quote - Agreement Id : '||l_qte_header_rec.CONTRACT_ID, 1 , 'N' );
	    aso_debug_pub.ADD ( 'Copy_Quote - Customer Account Id : '||l_qte_header_rec.CUST_ACCOUNT_ID, 1 , 'N' );
            aso_debug_pub.ADD ( 'Copy_Quote - Order Type Id : '||l_qte_header_rec.ORDER_TYPE_ID, 1 , 'N' );
         END IF;

         Open C_Agreement_PL(l_qte_header_rec.CONTRACT_ID);
         Fetch C_Agreement_PL Into l_qte_header_rec.PRICE_LIST_ID,l_qte_header_rec.CURRENCY_CODE;

	 If C_Agreement_PL%FOUND then

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.ADD ( 'Copy_Quote - Price List is defaulted based on Agreement', 1 , 'N' );
            END IF;

	 ElsIf C_Agreement_PL%NOTFOUND then

	    Open C_Customer_PL(l_qte_header_rec.CUST_ACCOUNT_ID);
            Fetch C_Customer_PL Into l_qte_header_rec.PRICE_LIST_ID,l_qte_header_rec.CURRENCY_CODE;

            If C_Customer_PL%FOUND then

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
	          aso_debug_pub.ADD ( 'Copy_Quote - Price List is defaulted based on Customer Account', 1 , 'N' );
               END IF;

	    ElsIf C_Customer_PL%NOTFOUND then

	       Open C_Order_Type_PL(l_qte_header_rec.ORDER_TYPE_ID);
	       Fetch C_Order_Type_PL Into l_qte_header_rec.PRICE_LIST_ID,l_qte_header_rec.CURRENCY_CODE;

               If C_Order_Type_PL%FOUND then
		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	             aso_debug_pub.ADD ( 'Copy_Quote - Price List is defaulted based on Order Type', 1 , 'N' );
                  END IF;
	       End If;
	       Close C_Order_Type_PL;

            End If;
	    Close C_Customer_PL;

         End If;
	 Close C_Agreement_PL;

	  -- End : Code change done for Bug 12674665

	 -- Start : Code change done Bug 19509297
	 IF l_qte_header_rec.CURRENCY_CODE IS NULL OR l_qte_header_rec.CURRENCY_CODE = FND_API.G_MISS_CHAR THEN
	    l_qte_header_rec.CURRENCY_CODE := FND_PROFILE.Value('ICX_PREFERRED_CURRENCY');
	 End if;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Quote - l_qte_header_rec.PRICE_LIST_ID : '||l_qte_header_rec.PRICE_LIST_ID, 1 , 'N' );
	    aso_debug_pub.ADD ( 'Copy_Quote - l_qte_header_rec.CURRENCY_CODE : '||l_qte_header_rec.CURRENCY_CODE, 1 , 'N' );
         END IF;

	 IF l_qte_header_rec.CURRENCY_CODE IS NULL OR l_qte_header_rec.CURRENCY_CODE = FND_API.G_MISS_CHAR THEN
	    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
               FND_MESSAGE.Set_Token ('COLUMN' , 'CURRENCY_CODE', FALSE );
               FND_MESSAGE.Set_Token ( 'VALUE' , l_qte_header_rec.CURRENCY_CODE , FALSE );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
	 -- End : Code change done Bug 19509297
	 commented for Bug 22512986 */

         /* commented for Bug 18942516
         If (l_sales_team_prof = 'FULL' OR l_sales_team_prof = 'PARTIAL') Then
             If (P_Qte_Header_Rec.RESOURCE_ID IS NOT NULL AND P_Qte_Header_Rec.RESOURCE_ID <> FND_API.G_MISS_NUM) Then

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	            aso_debug_pub.ADD ( 'Copy_Quote - P_Qte_Header_Rec.RESOURCE_ID : '||P_Qte_Header_Rec.RESOURCE_ID, 1 , 'N' );
		    aso_debug_pub.ADD ( 'Copy_Quote - P_Qte_Header_Rec.RESOURCE_GRP_ID : '||P_Qte_Header_Rec.RESOURCE_GRP_ID, 1 , 'N' );
	         END IF;

                 l_qte_header_rec.RESOURCE_ID     := P_Qte_Header_Rec.RESOURCE_ID;
	         l_qte_header_rec.RESOURCE_GRP_ID := P_Qte_Header_Rec.RESOURCE_GRP_ID;
             End If;
         End If; */
      End If;  -- Copy_To_Same_Customer

      /* Code change for Quoting Usability Sun ER End */

      IF ( P_Copy_Quote_Control_Rec.New_Version = FND_API.G_FALSE ) THEN
         IF (    P_Copy_Quote_Header_Rec.Quote_Number IS NULL
             OR P_Copy_Quote_Header_Rec.Quote_Number = FND_API.G_MISS_NUM
             ) THEN
            IF ( NVL ( FND_PROFILE.VALUE ('ASO_AUTO_NUMBERING' ), 'Y' ) = 'Y' ) THEN
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Copy_Quote - AUTO_NUMBERING is Y ' , 1 , 'N' );
			END IF;

               OPEN C_Qte_Number;
               FETCH C_Qte_Number INTO l_qte_header_rec.quote_number;
               CLOSE C_Qte_Number;

               l_qte_header_rec.quote_version := 1;
               l_qte_header_rec.max_version_flag := 'Y';
            ELSE
               IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                  FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_MISSING_COLUMN' );
                  FND_MESSAGE.Set_Token ('COLUMN' , 'QUOTE_NUMBER', FALSE );
                  FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF; -- profile auto numbering
         ELSE

            OPEN C_Qte_Number_Exists ( P_Copy_Quote_Header_Rec.Quote_Number );
            FETCH C_Qte_Number_Exists INTO l_qte_num;
            CLOSE C_Qte_Number_Exists;

            IF l_qte_num = P_Copy_Quote_Header_Rec.Quote_Number THEN
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Copy_Quote - AUTO_NUMBERING is N ' , 1 , 'N' );
			END IF;
               IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                  FND_MESSAGE.Set_Name ('ASO' , 'ASO_CANNOT_COPY_QTE' );
                  FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            ELSE
               l_qte_header_rec.quote_number := P_Copy_Quote_Header_Rec.Quote_Number;
               l_qte_header_rec.quote_version := 1;
               l_qte_header_rec.max_version_flag := 'Y';
            END IF;
         END IF; -- p_qte_number is null

-- Qte_Exp_Date
         IF P_Copy_Quote_Header_Rec.Quote_Expiration_Date = FND_API.G_MISS_DATE THEN
            ASO_COPY_QUOTE_PVT.Get_Quote_Exp_Date (
                X_Quote_Exp_Date =>             l_qte_header_rec.quote_expiration_date
             , X_Return_Status =>               l_return_status
             , X_Msg_Count =>                   x_msg_count
             , X_Msg_Data =>                    x_msg_data
             );
            IF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
               x_return_status            := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;

-- Quote_Exp_Date

      ELSE -- new_version is TRUE

        -- hyang: for bug 2692785
        ASO_CONC_REQ_INT.Lock_Exists(
          p_quote_header_id => P_Copy_Quote_Header_Rec.Quote_Header_Id,
          x_status          => lx_status);

        IF (lx_status = FND_API.G_TRUE) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

         IF      P_Copy_Quote_Header_Rec.Quote_Number IS NOT NULL
             AND P_Copy_Quote_Header_Rec.Quote_Number <> FND_API.G_MISS_NUM THEN

            OPEN C_Qte_Number_Exists ( P_Copy_Quote_Header_Rec.Quote_Number );
            FETCH C_Qte_Number_Exists INTO l_qte_num;

            IF C_Qte_Number_Exists%NOTFOUND THEN
               IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                  FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
                  FND_MESSAGE.Set_Token ('COLUMN' , 'QUOTE_NUMBER', FALSE );
                  FND_MSG_PUB.ADD;
               END IF;
               CLOSE C_Qte_Number_Exists;
               RAISE FND_API.G_EXC_ERROR;
            ELSE
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Copy_Quote - P_Qte_Number Exists' , 1 , 'N' );
			END IF;
               l_qte_header_rec.quote_number := P_Copy_Quote_Header_Rec.Quote_Number;
               CLOSE C_Qte_Number_Exists;
            END IF;

         END IF; -- qte_number not null

         OPEN C_Curr_Qte_Info ( l_qte_header_rec.quote_number );
         FETCH C_Curr_Qte_Info INTO l_qte_status_id
                                  , l_qte_header_id
                                  , l_qte_header_rec.quote_version;
         CLOSE C_Curr_Qte_Info;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Quote - l_qte_status_id ' || l_qte_status_id , 1 , 'N' );
         aso_debug_pub.ADD ( 'Copy_Quote - l_qte_header_id ' || l_qte_header_id , 1 , 'N' );
         aso_debug_pub.ADD ( 'Copy_Quote - l_qte_header_rec.quote_version ' || l_qte_header_rec.quote_version , 1 , 'N' );
	    END IF;

         OPEN C_Check_Qte_Status ( l_qte_status_id );
         FETCH C_Check_Qte_Status INTO l_dummy;

         IF C_Check_Qte_Status%NOTFOUND THEN
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.ADD ('Copy_Quote - invalid status ' , 1, 'N' );
		  END IF;
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_CANNOT_COPY_FOR_STATUS' );
               FND_MSG_PUB.ADD;
            END IF;
            CLOSE C_Check_Qte_Status;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         CLOSE C_Check_Qte_Status;

         l_qte_header_rec.quote_version := NVL ( l_qte_header_rec.quote_version, 0 ) + 1;
         l_qte_header_rec.max_version_flag := 'Y';

         UPDATE ASO_QUOTE_HEADERS_ALL
            SET Max_Version_Flag = 'N'
              ,last_update_date =sysdate
              ,last_updated_by = G_USER_ID
              ,last_update_login = G_LOGIN_ID

          WHERE Quote_Header_Id = l_qte_header_id;

      END IF; -- p_new_version

      OPEN c_qte_status_id ( fnd_profile.VALUE ('ASO_DEFAULT_STATUS_CODE' ) );
      FETCH c_qte_status_id INTO l_qte_header_rec.quote_status_id;

      IF c_qte_status_id%NOTFOUND THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_NO_PROFILE_VALUE' );
            FND_MESSAGE.Set_Token ( 'PROFILE' , 'ASO_DEFAULT_STATUS_CODE' , FALSE );
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE c_qte_status_id;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      CLOSE c_qte_status_id;

      IF P_Copy_Quote_Header_Rec.Quote_Name <> FND_API.G_MISS_CHAR THEN
         l_qte_header_rec.Quote_Name := P_Copy_Quote_Header_Rec.Quote_Name;

      ELSE
          -- since the quote name is not passed in, set the quote name
        IF ( P_Copy_Quote_Control_Rec.New_Version = FND_API.G_FALSE ) THEN
         IF (l_qte_header_rec.quote_name is not null and l_qte_header_rec.quote_name <> fnd_api.g_miss_char) then
            l_qte_header_rec.quote_name := 'Copy Of '||substr(l_qte_header_rec.quote_name,1,232);
         Else
            l_qte_header_rec.quote_name := 'Copy Of ';
         end if;
        end if;

      END IF;

      IF P_Copy_Quote_Header_Rec.Quote_Source_Code <> FND_API.G_MISS_CHAR THEN
         l_qte_header_rec.Quote_Source_Code := P_Copy_Quote_Header_Rec.Quote_Source_Code;
      END IF;

      IF P_Copy_Quote_Header_Rec.Quote_Expiration_Date <> FND_API.G_MISS_DATE THEN
         l_qte_header_rec.Quote_Expiration_Date := P_Copy_Quote_Header_Rec.Quote_Expiration_Date;
      END IF;

      IF P_Copy_Quote_Header_Rec.Resource_Id <> FND_API.G_MISS_NUM THEN
         l_qte_header_rec.Resource_Id := P_Copy_Quote_Header_Rec.Resource_Id;
      END IF;

      IF P_Copy_Quote_Header_Rec.Resource_Grp_Id <> FND_API.G_MISS_NUM THEN
         l_qte_header_rec.Resource_Grp_Id := P_Copy_Quote_Header_Rec.Resource_Grp_Id;
      END IF;

  -- added four new fields as per changes to the copy quote header rec
      IF P_Copy_Quote_Header_Rec.pricing_status_indicator <> FND_API.G_MISS_CHAR THEN
         l_qte_header_rec.pricing_status_indicator := P_Copy_Quote_Header_Rec.pricing_status_indicator;
      END IF;

      IF P_Copy_Quote_Header_Rec.tax_status_indicator <> FND_API.G_MISS_CHAR THEN
         l_qte_header_rec.tax_status_indicator := P_Copy_Quote_Header_Rec.tax_status_indicator;
      END IF;

      IF P_Copy_Quote_Header_Rec.price_updated_date <> FND_API.G_MISS_DATE THEN
         l_qte_header_rec.price_updated_date := P_Copy_Quote_Header_Rec.price_updated_date;
      END IF;

      IF P_Copy_Quote_Header_Rec.tax_updated_date <> FND_API.G_MISS_DATE THEN
         l_qte_header_rec.tax_updated_date := P_Copy_Quote_Header_Rec.tax_updated_date;
      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ('Copy_Quote - Begin- before copy_rows ' , 1, 'Y' );
	 END IF;
      Copy_Header_Rows (
          P_Api_Version_Number =>         1.0
       , P_Init_Msg_List =>               FND_API.G_FALSE
       , P_Commit =>                      FND_API.G_FALSE
       , P_qte_Header_Rec =>              l_qte_header_rec
       /* Code change for Quoting Usability Sun ER Start */
       , P_Hd_Shipment_Rec         => P_Hd_Shipment_Rec
       , P_hd_Payment_Tbl          => P_hd_Payment_Tbl
       , P_hd_Tax_Detail_Tbl       => P_hd_Tax_Detail_Tbl
       /* Code change for Quoting Usability Sun ER End */
       , P_Copy_Quote_Control_Rec =>      P_Copy_Quote_Control_Rec
       , X_Qte_Header_id =>               x_qte_header_id
       , X_Price_Index_Link_Tbl =>        lx_Price_Index_Link_Tbl
       , X_Return_Status =>               l_return_status
       , X_Msg_Count =>                   x_msg_count
       , X_Msg_Data =>                    x_msg_data
       );
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Quote - After copy_rows ' || l_return_status , 1 , 'Y' );
	 END IF;

      IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
            FND_MESSAGE.Set_Token ('ROW' , 'ASO_QUOTE_HEADER', TRUE );
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF P_Copy_Quote_Control_Rec.Copy_Header_Only <> FND_API.G_TRUE THEN

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ('Copy_Quote - Begin- before copy_rows ' , 1, 'Y' );
	    END IF;


	    l_copy_line_qte_header_rec.batch_price_flag := FND_API.G_FALSE;

         Copy_Line_Rows (
            P_Api_Version_Number =>         1.0
          , P_Init_Msg_List =>               FND_API.G_FALSE
          , P_Commit =>                      FND_API.G_FALSE
          , P_qte_Header_Id =>               P_Copy_Quote_Header_Rec.Quote_Header_Id
          , P_new_qte_header_id =>           x_qte_header_id
          , P_Qte_Line_Id =>                 FND_API.G_MISS_NUM
          , P_Price_Index_Link_Tbl =>        lx_Price_Index_Link_Tbl
          , P_Copy_Quote_Control_Rec =>      P_Copy_Quote_Control_Rec
          , P_Qte_Header_Rec         =>   l_copy_line_qte_header_rec
          , P_Control_Rec            =>   ASO_QUOTE_PUB.G_MISS_Control_Rec
          , X_Qte_Line_Id            =>  X_New_Qte_Line_Id
          , X_Return_Status =>               l_return_status
          , X_Msg_Count =>                   x_msg_count
          , X_Msg_Data =>                    x_msg_data
          );
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Quote - After copy_rows ' || l_return_status , 1 , 'Y' );
	    END IF;
      END IF;
-- ER 3177722
 /*      if (l_return_status =FND_API.G_RET_STS_SUCCESS) then


         if l_copy_config_profile='N' then
	         aso_debug_pub.add('Copy Quote -before   ASO_QUOTE_PUB.validate_model_configuration return status:  ', 1, 'N');

      ASO_QUOTE_PUB.validate_model_configuration
			(
			P_Api_Version_Number  => 1.0,
			P_Init_Msg_List       => FND_API.G_FALSE,
			P_Commit              => FND_API.G_FALSE,
               P_Quote_header_id     =>x_qte_header_id,
			P_UPDATE_QUOTE        =>'T',
			P_CONFIG_EFFECTIVE_DATE      => sysdate,
			P_CONFIG_model_lookup_DATE   => sysdate,
			X_Config_tbl          => lx_config_tbl,
			X_Return_Status       => l_return_status,
			X_Msg_Count           => x_msg_count,
			X_Msg_Data            => x_msg_data
               );

      if l_Return_Status=FND_API.G_RET_STS_SUCCESS then
                       commit work;
		      aso_debug_pub.add('rassharm Copy Quote -after   ASO_QUOTE_PUB.validate_model_configuration committing data return status:  ', 1, 'N');

		    end if;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('Copy Quote -After  ASO_QUOTE_PUB.validate_model_configuration return status:  '||l_Return_Status, 1, 'N');
			aso_debug_pub.add('Copy Quote -After  ASO_QUOTE_PUB.validate_model_configuration lx_config_tbl:  '||lx_config_tbl.count, 1, 'N');
		    END IF;



            end if; -- profile
       end if; -- success
*/
      IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
            FND_MESSAGE.Set_Token ('ROW' , 'ASO_QUOTE_HEADER', TRUE );
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      OPEN C_Get_Qte_Num ( x_qte_header_id );
      FETCH C_Get_Qte_Num INTO x_qte_number;
      CLOSE C_Get_Qte_Num;
--bug8975090
       -- create header relationship

      ASO_HEADER_RELATIONSHIPS_PKG.Insert_Row (
          px_HEADER_RELATIONSHIP_ID =>    l_HEADER_RELATIONSHIP_ID
       , p_CREATION_DATE =>               SYSDATE
       , p_CREATED_BY =>                  G_USER_ID
       , p_LAST_UPDATE_DATE =>            SYSDATE
       , p_LAST_UPDATED_BY =>             G_USER_ID
       , p_LAST_UPDATE_LOGIN =>           G_LOGIN_ID
       , p_REQUEST_ID =>                  NULL
       , p_PROGRAM_APPLICATION_ID =>      NULL
       , p_PROGRAM_ID =>                  NULL
       , p_PROGRAM_UPDATE_DATE =>         NULL
       , p_QUOTE_HEADER_ID =>             P_Copy_Quote_Header_Rec.quote_header_id
       , p_RELATED_HEADER_ID =>           x_qte_header_id
       , p_RELATIONSHIP_TYPE_CODE =>      'COPY'
       , p_RECIPROCAL_FLAG =>             NULL
       ,p_OBJECT_VERSION_NUMBER =>         NULL

       );
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Quote - After header_relationships,insert: END ' , 1 , 'Y' );
	 END IF;
--8975090

    --  IF P_Copy_Quote_Control_Rec.New_Version = FND_API.G_TRUE THEN code commented for Quoting Usability Sun ER

         If P_Copy_Quote_Control_Rec.Copy_Sales_Supplement = FND_API.G_TRUE Then  -- Code change for Quoting Usability Sun ER

         COPY_SALES_SUPPLEMENT (
             P_Api_Version_Number =>         1.0
          , P_Init_Msg_List =>               FND_API.G_FALSE
          , P_Commit =>                      FND_API.G_FALSE
          , p_old_quote_header_id =>         P_Copy_Quote_Header_Rec.quote_header_id
          , p_new_quote_header_id =>         x_qte_header_id
          , X_Return_Status =>               l_return_status
          , X_Msg_Count =>                   x_msg_count
          , X_Msg_Data =>                    x_msg_data
          );
         IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
               FND_MESSAGE.Set_Token ('ROW' , 'ASO_QUOTE_HEADER', TRUE );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
            x_return_status            := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

	 End If;  -- Code change for Quoting Usability Sun ER

       IF P_Copy_Quote_Control_Rec.New_Version = FND_API.G_TRUE THEN  -- Code change for Quoting Usability Sun ER

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Quote - Before Copy_Opp_Quote: ' , 1 , 'N' );
	    END IF;
         ASO_COPY_QUOTE_PVT.Copy_Opp_Quote(
               p_api_version_number  => 1.0,
               p_qte_header_id       => P_Copy_Quote_Header_Rec.quote_header_id,
               p_new_qte_header_id   => x_qte_header_id,
               X_Return_Status       => l_return_status,
               X_Msg_Count           => x_msg_count,
               X_Msg_Data            => x_msg_data
             );
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.ADD ( 'Copy_Quote - After Copy_Opp_Quote: l_return_status '||l_return_status , 1 , 'N' );
		END IF;
          IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
             x_return_status            := l_return_status;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      -- vtariker Price/Tax Enh
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Pricing_Request_Type'||
					  P_Copy_Quote_Control_Rec.Pricing_Request_Type , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Header_Pricing_Event'||
					  P_Copy_Quote_Control_Rec.Header_Pricing_Event , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Price_Mode'||
					  P_Copy_Quote_Control_Rec.Price_Mode , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Calculate_Tax_Flag'||
					  P_Copy_Quote_Control_Rec.Calculate_Tax_Flag , 1 , 'N' );
      aso_debug_pub.ADD ( 'Copy_Quote - P_Copy_Quote_Control_Rec.Calculate_Freight_Charge_Flag'||
					  P_Copy_Quote_Control_Rec.Calculate_Freight_Charge_Flag , 1 , 'N' );
      END IF;

      IF (P_Copy_Quote_Control_Rec.Header_Pricing_Event <> FND_API.G_MISS_CHAR
          AND P_Copy_Quote_Control_Rec.Header_Pricing_Event IS NOT NULL) OR
         P_Copy_Quote_Control_Rec.Calculate_Tax_Flag = 'Y' THEN

         IF P_Copy_Quote_Control_Rec.Header_Pricing_Event <> FND_API.G_MISS_CHAR
            AND P_Copy_Quote_Control_Rec.Header_Pricing_Event IS NOT NULL THEN

             l_control_rec.pricing_request_type := P_Copy_Quote_Control_Rec.Pricing_Request_Type;
             l_control_rec.header_pricing_event := P_Copy_Quote_Control_Rec.Header_Pricing_Event;
             l_control_rec.price_mode           := P_Copy_Quote_Control_Rec.Price_Mode;
             l_control_rec.Calculate_Freight_Charge_Flag
							   := P_Copy_Quote_Control_Rec.Calculate_Freight_Charge_Flag;
            -- l_control_rec.calculate_tax_flag   := 'N'; -- Code change for Quoting Usability Sun ER
         END IF;

         IF P_Copy_Quote_Control_Rec.Calculate_Tax_Flag = 'Y' THEN
             l_control_rec.calculate_tax_flag   :=  'Y';
         /* Code change for Quoting Usability Sun ER Start */
         ElsIf P_Copy_Quote_Control_Rec.Calculate_Tax_Flag = 'N' THEN
             l_control_rec.calculate_tax_flag   :=  'N';
	 /* Code change for Quoting Usability Sun ER End */
         END IF;

         l_control_rec.auto_version_flag            :=  FND_API.G_TRUE;

         OPEN C_Get_Last_Upd_Date ( x_qte_header_id );
         FETCH C_Get_Last_Upd_Date INTO l_upd_qte_header_rec.last_update_date;
         CLOSE C_Get_Last_Upd_Date;

         l_upd_qte_header_rec.quote_header_id := x_qte_header_id;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.ADD ( 'Copy_Quote - Before Update_Qte: x_qte_header_id '||x_qte_header_id , 1 , 'N' );
         END IF;
         aso_quote_pub.update_quote (
            p_api_version_number         => 1.0,
            p_init_msg_list              => fnd_api.g_false,
            p_commit                     => fnd_api.g_false,
            p_control_rec                => l_control_rec,
            p_qte_header_rec             => l_upd_qte_header_rec,
            p_hd_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
            p_hd_payment_tbl             => aso_quote_pub.g_miss_payment_tbl,
            p_hd_shipment_tbl            => aso_quote_pub.g_miss_shipment_tbl,
            p_hd_freight_charge_tbl      => aso_quote_pub.g_miss_freight_charge_tbl,
            p_hd_tax_detail_tbl          => aso_quote_pub.g_miss_tax_detail_tbl,
            p_qte_line_tbl               => aso_quote_pub.g_miss_qte_line_tbl,
            p_qte_line_dtl_tbl           => aso_quote_pub.g_miss_qte_line_dtl_tbl,
            p_line_attr_ext_tbl          => aso_quote_pub.g_miss_Line_Attribs_Ext_TBL,
            p_line_rltship_tbl           => aso_quote_pub.g_miss_line_rltship_tbl,
            p_price_adjustment_tbl       => aso_quote_pub.g_miss_price_adj_tbl,
            p_price_adj_attr_tbl         => aso_quote_pub.g_miss_price_adj_attr_tbl,
            p_price_adj_rltship_tbl      => aso_quote_pub.g_miss_price_adj_rltship_tbl,
            p_ln_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
            p_ln_payment_tbl             => aso_quote_pub.g_miss_payment_tbl,
            p_ln_shipment_tbl            => aso_quote_pub.g_miss_shipment_tbl,
            p_ln_freight_charge_tbl      => aso_quote_pub.g_miss_freight_charge_tbl,
            p_ln_tax_detail_tbl          => aso_quote_pub.g_miss_tax_detail_tbl,
            x_qte_header_rec             => x_qte_header_rec,
            x_qte_line_tbl               => x_qte_line_tbl,
            x_qte_line_dtl_tbl           => x_qte_line_dtl_tbl,
            x_hd_price_attributes_tbl    => x_hd_price_attributes_tbl,
            x_hd_payment_tbl             => x_hd_payment_tbl,
            x_hd_shipment_tbl            => x_hd_shipment_tbl,
            x_hd_freight_charge_tbl      => x_hd_freight_charge_tbl,
            x_hd_tax_detail_tbl          => x_hd_tax_detail_tbl,
            x_line_attr_ext_tbl          => x_line_attr_ext_tbl,
            x_line_rltship_tbl           => x_line_rltship_tbl,
            x_price_adjustment_tbl       => x_price_adjustment_tbl,
            x_price_adj_attr_tbl         => x_price_adj_attr_tbl,
            x_price_adj_rltship_tbl      => x_price_adj_rltship_tbl,
            x_ln_price_attributes_tbl    => x_ln_price_attributes_tbl,
            x_ln_payment_tbl             => x_ln_payment_tbl,
            x_ln_shipment_tbl            => x_ln_shipment_tbl,
            x_ln_freight_charge_tbl      => x_ln_freight_charge_tbl,
            x_ln_tax_detail_tbl          => x_ln_tax_detail_tbl,
            x_return_status              => l_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data
          );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.ADD ( 'Copy_Quote - After Update_Quote (Reprice/tax): l_return_status '||
						 l_return_status , 1 ,'N' );
          END IF;
          IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
             x_return_status            := l_return_status;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF; -- Header_pricing_event/Tax_flag = TRUE

      -- hyang new okc

      IF NVL(FND_PROFILE.Value('OKC_ENABLE_SALES_CONTRACTS'),'N') = 'Y'
      THEN

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
  	      aso_debug_pub.add(
  	        'Copy_Quote - Checking whether the old quote has terms associated with.',
  	        1,
  	        'Y');
  	    END IF;
        -- bug 5314615
        l_has_terms := OKC_TERMS_UTIL_GRP.has_terms('QUOTE', p_copy_quote_header_rec.quote_header_id);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
  	      aso_debug_pub.add(
  	        'Copy_Quote - l_has_terms ' || l_has_terms,
  	        1,
  	        'Y');
  	    END IF;


        IF l_has_terms  = 'Y'
        THEN

          l_target_doc_type := 'QUOTE';
          l_target_doc_Id   := x_qte_header_id;

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
    	      aso_debug_pub.add(
    	        'Copy_Quote - P_Source_Doc_ID ' ||  P_Copy_Quote_Header_Rec.Quote_Header_Id,
    	        1,
    	        'Y');
    	      aso_debug_pub.add(
    	        'Copy_Quote - P_Target_Doc_ID ' ||  l_target_doc_Id,
    	        1,
    	        'Y');
    	      aso_debug_pub.add(
    	        'Copy_Quote - P_Target_Doc_Type ' ||  l_target_doc_type,
    	        1,
    	        'Y');
    	    END IF;

         -- bug 4932493,always copying the contract documents
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	      aso_debug_pub.add(
      	        'Copy_Quote - Copying terms, as well as contract documents',
      	        1,
      	        'Y');
            END IF;
         -- bug 5314615
	    IF P_Copy_Quote_Control_Rec.New_Version = FND_API.G_TRUE THEN
            l_copy_for_amendment := 'Y';
		  l_copy_abstract_yn   := 'Y';
	    ELSE
            l_copy_for_amendment := 'N';
		  l_copy_abstract_yn   := 'N';
         END IF;

	      If P_Copy_Quote_Control_Rec.Copy_Contract_Terms = FND_API.G_TRUE Then  -- Code change for Quoting Usability Sun ER

    	      OKC_TERMS_COPY_GRP.Copy_Doc (
                 P_Api_Version			   => 1.0,
	            P_Source_doc_Type		        => 'QUOTE',
                 P_Source_Doc_ID			   => P_Copy_Quote_Header_Rec.Quote_Header_Id,
          	  P_Target_Doc_ID			   => l_target_doc_Id,
          	  P_Target_Doc_Type		        => l_target_doc_type,
           	  P_Keep_Version			   => 'Y',
          	  P_Article_Effective_Date	   => NULL,
          	  P_Copy_Deliverables		   => 'N',
          	  P_Copy_Doc_Attachments	        => 'Y',
                 P_copy_for_amendment           => l_copy_for_amendment,
		       P_copy_abstract_yn             => l_copy_abstract_yn,
                 X_Return_Status        	   => X_Return_Status,
                 X_Msg_Count             	   => X_Msg_Count,
                 X_Msg_Data              	   => X_Msg_Data
            );


          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_COPY_DOC');
              FND_MSG_PUB.ADD;
            END IF;

            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;

	      End If;  -- Code change for Quoting Usability Sun ER

        END IF; -- has_terms

      END IF;  -- profile

      -- end of hyang new okc

      -- vtariker Price/Tax Enh

      -- bug 5162246
	 OPEN C_Get_RSA(x_qte_header_id);
	 FETCH C_Get_RSA INTO l_rsa;
	 CLOSE C_Get_RSA;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Quote - l_rsa: '|| l_rsa  , 1 , 'Y' );
	 END IF;

	 IF  ( (P_Copy_Quote_Control_Rec.New_Version = FND_API.G_TRUE) and (nvl(l_rsa,'N') = 'Y') ) then

        -- get the note id for the original quote
        OPEN get_note_id(P_Copy_Quote_Header_Rec.quote_header_id);
	   FETCH get_note_id into l_note_id;
	   CLOSE get_note_id;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.ADD ( 'Copy_Quote - l_note_id: '|| l_note_id  , 1 , 'Y' );
	       aso_debug_pub.ADD ( 'Copy_Quote - Before Calling JTF_NOTES_PUB.Create_Note_Context', 1 , 'Y' );
	    END IF;

        JTF_NOTES_PUB.Create_Note_Context(
               p_validation_level      => FND_API.G_VALID_LEVEL_NONE,
               x_return_status         => x_return_status           ,
               p_jtf_note_id           => l_note_id                 ,
               p_last_update_date      => sysdate                   ,
               p_last_updated_by       => FND_Global.USER_ID        ,
               p_creation_date         => sysdate                   ,
               p_created_by            => FND_Global.USER_ID        ,
               p_last_update_login     => FND_GLOBAL.LOGIN_ID       ,
               p_note_context_type_id  => x_qte_header_id           ,
               p_note_context_type     => 'ASO_QUOTE'               ,
               x_note_context_id       => lx_jtf_note_context_id
               );

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.ADD ( 'Copy_Quote - After Calling JTF_NOTES_PUB.Create_Note_Context', 1 , 'Y' );
	       aso_debug_pub.ADD ( 'Copy_Quote - x_return_status       : ' || x_return_status, 1 , 'Y' );
	       aso_debug_pub.ADD ( 'Copy_Quote - lx_jtf_note_context_id: ' || lx_jtf_note_context_id, 1 , 'Y' );
	     END IF;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END IF; -- end if for the new version and rsa check

     -- ER 3177722
     if l_copy_config_profile='N' then
           IF aso_debug_pub.g_debug_flag = 'Y' THEN
	         aso_debug_pub.add('Copy Quote -before   ASO_QUOTE_PUB.validate_model_configuration x_qte_header_id:  '||x_qte_header_id, 1, 'N');
            end if;

      ASO_QUOTE_PUB.validate_model_configuration
			(
			P_Api_Version_Number  => 1.0,
			P_Init_Msg_List       => FND_API.G_FALSE,
			P_Commit              => FND_API.G_FALSE,
               P_Quote_header_id     =>x_qte_header_id,
			P_UPDATE_QUOTE        =>'T',
			P_CONFIG_EFFECTIVE_DATE      => sysdate,
			P_CONFIG_model_lookup_DATE   => sysdate,
			X_Config_tbl          => lx_config_tbl,
			X_Return_Status       => l_return_status,
			X_Msg_Count           => x_msg_count,
			X_Msg_Data            => x_msg_data
               );

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('Copy Quote -After  ASO_QUOTE_PUB.validate_model_configuration return status:  '||l_Return_Status, 1, 'N');
			aso_debug_pub.add('Copy Quote -After  ASO_QUOTE_PUB.validate_model_configuration lx_config_tbl:  '||lx_config_tbl.count, 1, 'N');
			aso_debug_pub.add('Copy Quote -After  ASO_QUOTE_PUB.validate_model_configuration x_msg_count:  '||x_msg_count, 1, 'N');
      END IF;
	 /* if (l_Return_Status=FND_API.G_RET_STS_SUCCESS) and (lx_config_tbl.count>0) then
                       commit work;
		      aso_debug_pub.add('rassharm Copy Quote -after   ASO_QUOTE_PUB.validate_model_configuration committing data return status:  ', 1, 'N');

		    end if;
       */

if (l_Return_Status=FND_API.G_RET_STS_SUCCESS)  then
    x_return_status            := FND_API.G_RET_STS_SUCCESS;

elsIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
END IF;

end if; -- profile


	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Quote - END ' , 1 , 'Y' );
	 END IF;

      x_return_status            := FND_API.G_RET_STS_SUCCESS;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean ( p_commit ) THEN
         COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
          p_count =>                      x_msg_count
       , p_data =>                        x_msg_data
       );

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_SQLCODE =>                     SQLCODE
          , P_SQLERRM =>                     SQLERRM
          , P_EXCEPTION_LEVEL =>             ASO_UTILITY_PVT.G_EXC_OTHERS
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

   END Copy_Quote;


   PROCEDURE Copy_Header_Rows (
       P_Api_Version_Number IN NUMBER
    , P_Init_Msg_List IN VARCHAR2 := FND_API.G_FALSE
    , P_Commit IN VARCHAR2 := FND_API.G_FALSE
    , P_Qte_Header_Rec IN ASO_QUOTE_PUB.qte_header_rec_Type
    /* Code change for Quoting Usability Sun ER Start */
    , P_Hd_Shipment_REC         IN  ASO_QUOTE_PUB.Shipment_Rec_Type          := ASO_QUOTE_PUB.G_MISS_Shipment_Rec
    , P_hd_Payment_Tbl	        IN  ASO_QUOTE_PUB.Payment_Tbl_Type           := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL
    , P_hd_Tax_Detail_Tbl	IN  ASO_QUOTE_PUB.Tax_Detail_Tbl_Type        := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl
    /* Code change for Quoting Usability Sun ER End */
    , P_Copy_Quote_Control_Rec IN ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type
    , X_Qte_Header_Id OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Price_Index_Link_Tbl OUT NOCOPY /* file.sql.39 change */   ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    ) IS

      l_qte_header_id NUMBER := P_qte_Header_Rec.quote_header_id;
      l_old_qte_header_id NUMBER := P_qte_Header_Rec.quote_header_id;
      l_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type := P_qte_Header_Rec;
      l_payment_tbl ASO_QUOTE_PUB.Payment_Tbl_Type;
      l_shipment_tbl ASO_QUOTE_PUB.Shipment_Tbl_Type;
      l_shipment_rec ASO_QUOTE_PUB.Shipment_Rec_Type;
      l_freight_charge_tbl ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
      l_tax_detail_tbl ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
      l_Price_Attr_Tbl ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
      l_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
      l_Price_Adj_Attr_Tbl ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
      lx_hd_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
      l_control_rec ASO_QUOTE_PUB.Control_Rec_Type;
      X_hd_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      X_Sales_Credit_Tbl ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      X_Quote_Party_Tbl ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_hd_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      l_quote_party_tbl ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_quote_party_rec ASO_QUOTE_PUB.Quote_Party_rec_Type;
      l_sales_credit_tbl ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      l_sales_credit_rec ASO_QUOTE_PUB.Sales_Credit_rec_Type;
      l_Line_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      l_api_version CONSTANT NUMBER := 1.0;
      l_return_status VARCHAR2 ( 1 );
      l_api_name CONSTANT VARCHAR2 ( 30 ) := 'Copy_Header_Rows';
      l_api_version_number CONSTANT NUMBER := 1.0;


      l_qte_header_rec_out ASO_QUOTE_PUB.Qte_Header_Rec_Type;
      l_Price_Attr_Tbl_out ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
	 l_Price_Adj_Attr_Tbl_out ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
	 l_freight_charge_tbl_out ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
	 l_tax_detail_tbl_out ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
      l_payment_tbl_out ASO_QUOTE_PUB.Payment_Tbl_Type;

      l_old_qte_num                   NUMBER;
      l_sequence                      NUMBER := null;
      l_sales_team_prof               VARCHAR2(30) := FND_PROFILE.value('ASO_AUTO_TEAM_ASSIGN');

	 --BC4J Fix
      l_dup_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;

      CURSOR C_Get_Sales_Team (l_qte_num NUMBER) IS
       SELECT RESOURCE_ID,
              RESOURCE_GRP_ID,
              REQUEST_ID,
              PROGRAM_APPLICATION_ID,
              PROGRAM_ID,
              PROGRAM_UPDATE_DATE,
              KEEP_FLAG,
              UPDATE_ACCESS_FLAG,
              CREATED_BY_TAP_FLAG,
              TERRITORY_ID,
              TERRITORY_SOURCE_FLAG,
              ROLE_ID,
              ATTRIBUTE_CATEGORY,
              ATTRIBUTE1,
              ATTRIBUTE2,
              ATTRIBUTE3,
              ATTRIBUTE4,
              ATTRIBUTE5,
              ATTRIBUTE6,
              ATTRIBUTE7,
              ATTRIBUTE8,
              ATTRIBUTE9,
              ATTRIBUTE10,
              ATTRIBUTE11,
              ATTRIBUTE12,
              ATTRIBUTE13,
              ATTRIBUTE14,
              ATTRIBUTE15,
		    ATTRIBUTE16,
		    ATTRIBUTE17,
		    ATTRIBUTE18,
		    ATTRIBUTE19,
		    ATTRIBUTE20,
		    OBJECT_VERSION_NUMBER
       FROM ASO_QUOTE_ACCESSES
       WHERE QUOTE_NUMBER = l_qte_num;

      CURSOR C_Get_Old_Qte (l_hdr_id NUMBER) IS
       SELECT Quote_Number
       FROM ASO_QUOTE_HEADERS_ALL
       WHERE QUote_Header_Id = l_hdr_id;

	 l_qte_access_tbl    aso_quote_pub.qte_access_tbl_type  := aso_quote_pub.g_miss_qte_access_tbl;
	 x_qte_access_tbl    aso_quote_pub.qte_access_tbl_type;

      -- Start : Code change done for Bug 18942516
      l_def_control_rec      ASO_DEFAULTING_INT.Control_Rec_Type  := ASO_DEFAULTING_INT.G_MISS_CONTROL_REC;
      l_db_object_name       VARCHAR2(30);
      l_payment_rec          ASO_QUOTE_PUB.Payment_Rec_Type       := ASO_QUOTE_PUB.G_MISS_Payment_REC;
      l_hd_tax_detail_rec    ASO_QUOTE_PUB.Tax_Detail_Rec_Type    := ASO_QUOTE_PUB.G_MISS_Tax_Detail_REC;
      lx_qte_header_rec      ASO_Quote_Pub.qte_header_rec_type    := ASO_Quote_Pub.G_MISS_Qte_Header_Rec;
      lx_hd_shipment_rec     ASO_Quote_Pub.shipment_rec_type      := ASO_Quote_Pub.G_MISS_shipment_Rec;
      lx_hd_payment_rec      ASO_Quote_Pub.payment_rec_type       := ASO_Quote_Pub.G_MISS_payment_Rec;
      lx_hd_tax_detail_rec   ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
      lx_hd_misc_rec         ASO_DEFAULTING_INT.Header_Misc_Rec_Type;
      lx_qte_line_rec        ASO_Quote_Pub.qte_line_rec_type      := ASO_Quote_Pub.G_MISS_qte_line_Rec;
      lx_ln_misc_rec         ASO_DEFAULTING_INT.Line_Misc_Rec_Type;
      lx_ln_shipment_rec     ASO_QUOTE_PUB.Shipment_Rec_Type;
      lx_ln_payment_rec      ASO_QUOTE_PUB.Payment_Rec_Type;
      lx_ln_tax_detail_rec   ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
      lx_changed_flag        VARCHAR2(1);

      l_def_profile_value    VARCHAR2(3) := FND_PROFILE.value('ASO_ENABLE_DEFAULTING_RULE');
      -- End : Code change done for Bug 18942516

	  -- Start : Code change done for Bug 22512986

      CURSOR C_Agreement_PL(p_agreement_id Number) Is
      Select pri.list_header_id, pri.currency_code
      from OE_AGREEMENTS_B agr, qp_list_headers_vl pri
      where agr.agreement_id = p_agreement_id
      and pri.list_header_id = agr.price_list_id
      and pri.list_type_code in ('PRL','AGR')
      and pri.active_flag = 'Y'
      and trunc(nvl(pri.start_date_active, sysdate)) <= trunc(sysdate)
      and trunc(nvl(pri.end_date_active, sysdate)) >= trunc(sysdate);

      CURSOR C_Customer_PL(p_cust_acct_id Number) Is
      Select pri.list_header_id , pri.currency_code
      from HZ_CUST_ACCOUNTS cust, qp_list_headers_vl pri
      where cust.cust_account_id = p_cust_acct_id
      and cust.price_list_id = pri.list_header_id
      and pri.list_type_code in ('PRL','AGR')
      and pri.active_flag = 'Y'
      and trunc(nvl(pri.start_date_active, sysdate)) <= trunc(sysdate)
      and trunc(nvl(pri.end_date_active, sysdate)) >= trunc(sysdate);

      CURSOR C_Order_Type_PL(p_order_type_id Number) Is
      Select pri.list_header_id, pri.currency_code
      from OE_TRANSACTION_TYPES_ALL ord, qp_list_headers_vl pri
      where ord.TRANSACTION_TYPE_ID = p_order_type_id
      and ord.price_list_id = pri.list_header_id
      and pri.list_type_code in ('PRL','AGR')
      and pri.active_flag = 'Y'
      and trunc(nvl(pri.start_date_active, sysdate)) <= trunc(sysdate)
      and trunc(nvl(pri.end_date_active, sysdate)) >= trunc(sysdate);

      -- End : Code change done for Bug 22512986

	  -- Start : Code change done for Bug 23299200
      Cursor C_Primary_Address(p_party_id NUMBER) Is
      Select Party_Site.party_site_id,
             uses.site_use_type
      From  Hz_Party_Sites Party_Site,
            Hz_Party_Site_Uses Uses
      Where party_site.party_id = p_party_id
      And   party_site.party_site_id = uses.party_site_id
      And   party_site.status = 'A'
      And   uses.status = 'A'
      And   uses.site_use_type in ('SOLD_TO','SHIP_TO','BILL_TO')
      And   uses.primary_per_type = 'Y';

	  Cursor C_identifying_Address(p_party_id NUMBER) Is
      Select Party_Site.party_site_id
      From  Hz_Party_Sites Party_Site
      Where party_site.party_id = p_party_id
      And   party_site.status = 'A'
      And   party_site.identifying_address_flag = 'Y';

	  Cursor C_primary_phone(p_party_id NUMBER) Is
      Select phone.contact_point_id phone_id
      From   Hz_Contact_Points  phone
      Where  phone.owner_table_id = p_party_id
      And    phone.STATUS = 'A'
      And    phone.OWNER_TABLE_NAME = 'HZ_PARTIES'
      And    phone.CONTACT_POINT_TYPE = 'PHONE'
      And    phone.Primary_Flag = 'Y';
	  -- End : Code change done for Bug 23299200

   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT COPY_HEADER_ROWS_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
                 l_api_version_number
              , p_api_version_number
              , l_api_name
              , G_PKG_NAME
              ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean ( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ) THEN
         FND_MESSAGE.Set_Name ('ASO' , 'Copy Quote Header API: Start' );
         FND_MSG_PUB.ADD;
      END IF;

      --  Initialize API return status to success
      l_return_status            := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      /* Code change for Quoting Usability Sun ER Start */

      l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows (
                        p_qte_header_id => l_qte_header_id,
                        p_qte_line_id   => NULL );

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Header_Rows - l_shipment_tbl.count: ' || TO_CHAR ( l_shipment_tbl.COUNT ) , 1 , 'N' );
      END IF;

      l_freight_charge_tbl  := ASO_UTILITY_PVT.Query_Freight_Charge_Rows (
                               P_Shipment_Tbl =>  l_shipment_tbl );

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Header_Rows - l_freight_charge_tbl.count: ' || TO_CHAR ( l_freight_charge_tbl.COUNT ) , 1 , 'N' );
      END IF;

      l_tax_detail_tbl := ASO_UTILITY_PVT.Query_Tax_Detail_Rows (
                          p_qte_header_id => l_qte_header_id,
                          p_qte_line_id   => NULL,
                          p_shipment_tbl  => ASO_QUOTE_PUB.g_miss_shipment_tbl );

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Header_Rows - l_tax_detail_tbl.count: ' || TO_CHAR ( l_tax_detail_tbl.COUNT ) , 1 , 'N' );
      END IF;

      -- Start : Code change done for Bug 18942516
      -- Copy the header payment record
      l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows(p_qte_header_id =>l_qte_header_id,p_qte_line_id =>NULL);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Header_Rows - l_payment_tbl.count: ' || TO_CHAR(l_payment_tbl.COUNT) , 1 , 'N' );
      END IF;
      -- End : Code change done for Bug 18942516

      /* Code change for Quoting Usability Sun ER End */

      If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_TRUE Then  -- Code change for Quoting Usability Sun ER

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Header_Rows - P_Copy_Quote_Control_Rec.Copy_To_Same_Customer is True ', 1 , 'N' );
         END IF;

         l_price_adj_tbl            :=
                ASO_UTILITY_PVT.Query_Price_Adj_Rows (
                   p_qte_header_id =>              l_qte_header_id
                   , p_qte_line_id =>                 NULL );

         l_dup_Price_Adj_Tbl := l_price_adj_tbl;

         l_price_adj_attr_tbl       :=
                 ASO_UTILITY_PVT.Query_Price_Adj_Attr_Rows (
                 p_price_adj_tbl =>              l_price_adj_tbl );

         l_price_attr_tbl           :=
             ASO_UTILITY_PVT.Query_Price_Attr_Rows (
                   p_qte_header_id =>              l_qte_header_id
                   , p_qte_line_id =>                 NULL  );

          /* l_payment_tbl              :=
            ASO_UTILITY_PVT.Query_Payment_Rows (
                p_qte_header_id =>              l_qte_header_id
             , p_qte_line_id =>                 NULL
             );

          IF aso_debug_pub.g_debug_flag = 'Y' THEN
	     aso_debug_pub.ADD ( 'Copy_Rows - payment_tbl.count: ' || TO_CHAR ( l_payment_tbl.COUNT ) , 1 , 'N' );
	  END IF;  */

         /* Code change for Quoting Usability Sun ER Start */

         If P_Copy_Quote_Control_Rec.Copy_Shipping = FND_API.G_FALSE Then
            l_shipment_tbl(1).SHIP_TO_CUST_ACCOUNT_ID := Null;
	    l_shipment_tbl(1).SHIP_TO_CUST_PARTY_ID := Null;
	    l_shipment_tbl(1).SHIP_TO_PARTY_ID := Null;
	    l_shipment_tbl(1).SHIP_TO_PARTY_SITE_ID := Null;
	    l_shipment_tbl(1).SHIP_TO_PARTY_NAME := Null;
	    l_shipment_tbl(1).SHIP_TO_CONTACT_FIRST_NAME := Null;
	    l_shipment_tbl(1).SHIP_TO_CONTACT_MIDDLE_NAME := Null;
	    l_shipment_tbl(1).SHIP_TO_CONTACT_LAST_NAME := Null;
	    l_shipment_tbl(1).SHIP_TO_ADDRESS1 := Null;
	    l_shipment_tbl(1).SHIP_TO_ADDRESS2 := Null;
	    l_shipment_tbl(1).SHIP_TO_ADDRESS3 := Null;
	    l_shipment_tbl(1).SHIP_TO_ADDRESS4 := Null;
	    l_shipment_tbl(1).SHIP_TO_COUNTRY_CODE := Null;
	    l_shipment_tbl(1).SHIP_TO_COUNTRY := Null;
	    l_shipment_tbl(1).SHIP_TO_CITY := Null;
	    l_shipment_tbl(1).SHIP_TO_POSTAL_CODE := Null;
	    l_shipment_tbl(1).SHIP_TO_STATE := Null;
	    l_shipment_tbl(1).SHIP_TO_PROVINCE := Null;
	    l_shipment_tbl(1).SHIP_TO_COUNTY := Null;
	    l_shipment_tbl(1).SHIP_METHOD_CODE := Null;
            l_shipment_tbl(1).FREIGHT_TERMS_CODE := Null;
	    l_shipment_tbl(1).FOB_CODE := Null;
	    l_shipment_tbl(1).DEMAND_CLASS_CODE := Null;
	    l_shipment_tbl(1).REQUEST_DATE_TYPE := Null;
	    l_shipment_tbl(1).REQUEST_DATE := Null;
	    l_shipment_tbl(1).SHIPMENT_PRIORITY_CODE := Null;
	    l_shipment_tbl(1).SHIPPING_INSTRUCTIONS := Null;
	    l_shipment_tbl(1).PACKING_INSTRUCTIONS := Null;
         End If;

         If P_Copy_Quote_Control_Rec.Copy_Billing = FND_API.G_FALSE Then
            l_qte_header_rec.INVOICE_TO_CUST_ACCOUNT_ID := Null;
	    l_qte_header_rec.INVOICE_TO_CUST_PARTY_ID := Null;
	    l_qte_header_rec.INVOICE_TO_PARTY_ID := Null;
	    l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID := Null;
	    l_qte_header_rec.INVOICE_TO_PARTY_NAME := Null;
	    l_qte_header_rec.INVOICE_TO_CONTACT_FIRST_NAME := Null;
	    l_qte_header_rec.INVOICE_TO_CONTACT_MIDDLE_NAME := Null;
	    l_qte_header_rec.INVOICE_TO_CONTACT_LAST_NAME := Null;
	    l_qte_header_rec.INVOICE_TO_ADDRESS1 := Null;
	    l_qte_header_rec.INVOICE_TO_ADDRESS2 := Null;
	    l_qte_header_rec.INVOICE_TO_ADDRESS3 := Null;
	    l_qte_header_rec.INVOICE_TO_ADDRESS4 := Null;
	    l_qte_header_rec.INVOICE_TO_COUNTRY_CODE := Null;
	    l_qte_header_rec.INVOICE_TO_COUNTRY := Null;
	    l_qte_header_rec.INVOICE_TO_CITY := Null;
	    l_qte_header_rec.INVOICE_TO_POSTAL_CODE := Null;
	    l_qte_header_rec.INVOICE_TO_STATE := Null;
	    l_qte_header_rec.INVOICE_TO_PROVINCE := Null;
	    l_qte_header_rec.INVOICE_TO_COUNTY := Null;
         End If;

         If P_Copy_Quote_Control_Rec.Copy_End_Customer = FND_API.G_FALSE Then
            l_qte_header_rec.END_CUSTOMER_PARTY_ID :=  Null;
	    l_qte_header_rec.END_CUSTOMER_PARTY_SITE_ID :=  Null;
	    l_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID :=  Null;
	    l_qte_header_rec.END_CUSTOMER_CUST_PARTY_ID :=  Null;
         End If;

         If P_Copy_Quote_Control_Rec.Copy_Sales_Credit = FND_API.G_TRUE Then
            l_sales_credit_tbl :=  ASO_UTILITY_PVT.Query_Sales_Credit_Row (
                                   P_qte_header_Id => l_qte_header_id ,
                                   P_qte_line_id   => NULL );

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.ADD ( 'Copy_Header_Rows - l_sales_credit_tbl.count: ' || TO_CHAR ( l_sales_credit_tbl.COUNT ) , 1 , 'N' );
            END IF;
         End If;

         -- Start : Code change done for Bug 18942516
         IF l_payment_tbl.count > 0 then
            If P_Copy_Quote_Control_Rec.Copy_Payment = FND_API.G_FALSE Then
               l_payment_tbl ( 1 ).CUST_PO_NUMBER := Null;
	       l_payment_tbl ( 1 ).PAYMENT_TERM_ID := Null;
	       l_payment_tbl ( 1 ).PAYMENT_TYPE_CODE := NULL;
	       l_payment_tbl ( 1 ).PAYMENT_REF_NUMBER := Null;
	       l_payment_tbl ( 1 ).CREDIT_CARD_CODE := Null;
	       l_payment_tbl ( 1 ).CREDIT_CARD_HOLDER_NAME := Null;
	       l_payment_tbl ( 1 ).CREDIT_CARD_EXPIRATION_DATE := Null;
	       l_payment_tbl ( 1 ).CVV2 := Null;
	    End If;
         End If;

	 l_qte_header_rec.price_frozen_date := NULL;
         -- End : Code change done for Bug 18942516

      ElsIf P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.ADD ( 'Copy_Header_Rows - P_Copy_Quote_Control_Rec.Copy_To_Same_Customer is False ', 1 , 'N' );
	END IF;

	l_price_adj_tbl      := aso_quote_pub.g_miss_price_adj_tbl;
        l_dup_Price_Adj_Tbl  := l_price_adj_tbl;
        l_price_adj_attr_tbl := aso_quote_pub.g_miss_price_adj_attr_tbl;
        l_price_attr_tbl     := aso_quote_pub.g_miss_price_attributes_tbl;

	l_sales_credit_tbl   :=  ASO_UTILITY_PVT.Query_Sales_Credit_Row (
                                 P_qte_header_Id => l_qte_header_id ,
                                 P_qte_line_id   => NULL );

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.ADD ( 'Copy_Header_Rows - l_sales_credit_tbl.count: ' || TO_CHAR ( l_sales_credit_tbl.COUNT ) , 1 , 'N' );
        END IF;

	-- Start : code change done for Bug 23299200
	l_shipment_tbl(1).SHIP_TO_CUST_ACCOUNT_ID     := l_qte_header_rec.CUST_ACCOUNT_ID;
	l_shipment_tbl(1).SHIP_TO_CUST_PARTY_ID       := l_qte_header_rec.CUST_PARTY_ID;

	-- Start : code change done for Bug 24304297
	l_shipment_tbl(1).SHIP_TO_PARTY_SITE_ID       := FND_API.G_MISS_NUM;
	l_shipment_tbl(1).SHIP_TO_PARTY_ID            := FND_API.G_MISS_NUM;
	l_shipment_tbl(1).SHIP_TO_PARTY_NAME          := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_CONTACT_FIRST_NAME  := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_CONTACT_MIDDLE_NAME := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_CONTACT_LAST_NAME   := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_ADDRESS1            := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_ADDRESS2            := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_ADDRESS3            := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_ADDRESS4            := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_COUNTRY_CODE        := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_COUNTRY             := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_CITY                := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_POSTAL_CODE         := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_STATE               := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_PROVINCE            := FND_API.G_MISS_CHAR;
	l_shipment_tbl(1).SHIP_TO_COUNTY              := FND_API.G_MISS_CHAR;
	-- End : code change done for Bug 24304297

    /*
	l_shipment_tbl(1).SHIP_TO_CUST_ACCOUNT_ID     := P_Hd_Shipment_Rec.SHIP_TO_CUST_ACCOUNT_ID;
	l_shipment_tbl(1).SHIP_TO_CUST_PARTY_ID       := P_Hd_Shipment_Rec.SHIP_TO_CUST_PARTY_ID;
	l_shipment_tbl(1).SHIP_TO_PARTY_ID            := P_Hd_Shipment_Rec.SHIP_TO_PARTY_ID;
	l_shipment_tbl(1).SHIP_TO_PARTY_SITE_ID       := P_Hd_Shipment_Rec.SHIP_TO_PARTY_SITE_ID;
	l_shipment_tbl(1).SHIP_TO_PARTY_NAME          := P_Hd_Shipment_Rec.SHIP_TO_PARTY_NAME;
	l_shipment_tbl(1).SHIP_TO_CONTACT_FIRST_NAME  := P_Hd_Shipment_Rec.SHIP_TO_CONTACT_FIRST_NAME;
	l_shipment_tbl(1).SHIP_TO_CONTACT_MIDDLE_NAME := P_Hd_Shipment_Rec.SHIP_TO_CONTACT_MIDDLE_NAME;
	l_shipment_tbl(1).SHIP_TO_CONTACT_LAST_NAME   := P_Hd_Shipment_Rec.SHIP_TO_CONTACT_LAST_NAME;
	l_shipment_tbl(1).SHIP_TO_ADDRESS1            := P_Hd_Shipment_Rec.SHIP_TO_ADDRESS1;
	l_shipment_tbl(1).SHIP_TO_ADDRESS2            := P_Hd_Shipment_Rec.SHIP_TO_ADDRESS2;
	l_shipment_tbl(1).SHIP_TO_ADDRESS3            := P_Hd_Shipment_Rec.SHIP_TO_ADDRESS3;
	l_shipment_tbl(1).SHIP_TO_ADDRESS4            := P_Hd_Shipment_Rec.SHIP_TO_ADDRESS4;
	l_shipment_tbl(1).SHIP_TO_COUNTRY_CODE        := P_Hd_Shipment_Rec.SHIP_TO_COUNTRY_CODE;
	l_shipment_tbl(1).SHIP_TO_COUNTRY             := P_Hd_Shipment_Rec.SHIP_TO_COUNTRY;
	l_shipment_tbl(1).SHIP_TO_CITY                := P_Hd_Shipment_Rec.SHIP_TO_CITY;
	l_shipment_tbl(1).SHIP_TO_POSTAL_CODE         := P_Hd_Shipment_Rec.SHIP_TO_POSTAL_CODE;
	l_shipment_tbl(1).SHIP_TO_STATE               := P_Hd_Shipment_Rec.SHIP_TO_STATE;
	l_shipment_tbl(1).SHIP_TO_PROVINCE            := P_Hd_Shipment_Rec.SHIP_TO_PROVINCE;
	l_shipment_tbl(1).SHIP_TO_COUNTY              := P_Hd_Shipment_Rec.SHIP_TO_COUNTY; */
	-- End : code change done for Bug 23299200

	If P_Copy_Quote_Control_Rec.Copy_Shipping = FND_API.G_FALSE Then
           l_shipment_tbl(1).SHIP_METHOD_CODE := Null;
           l_shipment_tbl(1).FREIGHT_TERMS_CODE := Null;
	   l_shipment_tbl(1).FOB_CODE := Null;
	   l_shipment_tbl(1).DEMAND_CLASS_CODE := Null;
	   l_shipment_tbl(1).REQUEST_DATE_TYPE := Null;
	   l_shipment_tbl(1).REQUEST_DATE := Null;
	   l_shipment_tbl(1).SHIPMENT_PRIORITY_CODE := Null;
	   l_shipment_tbl(1).SHIPPING_INSTRUCTIONS := Null;
	   l_shipment_tbl(1).PACKING_INSTRUCTIONS := Null;
	End If;

	-- If Tax Handling is Exempt then don't copy following values
	--FOR j IN 1 .. l_tax_detail_tbl.COUNT LOOP
	IF l_tax_detail_tbl.count > 0 then
           If l_tax_detail_tbl(1).TAX_EXEMPT_FLAG = 'E' Then
	      l_tax_detail_tbl(1).TAX_EXEMPT_FLAG        := 'S';
	      l_tax_detail_tbl(1).TAX_EXEMPT_NUMBER      := Null;
	      l_tax_detail_tbl(1).TAX_EXEMPT_REASON_CODE := Null;
           End If;
        End If;
	--END LOOP;

	-- Start : Code change done for Bug 18942516

	IF l_payment_tbl.count > 0 then
	    -- Setting payment related fields to null as per discussion bug 16591499
	    If l_payment_tbl ( 1 ).PAYMENT_TYPE_CODE In ('CHECK','CREDIT_CARD') Then
       	       If l_payment_tbl ( 1 ).PAYMENT_TYPE_CODE = 'CREDIT_CARD' Then
		  l_payment_tbl ( 1 ).CREDIT_CARD_CODE            := null;--P_hd_Payment_Tbl(j).CREDIT_CARD_CODE;
		  l_payment_tbl ( 1 ).CREDIT_CARD_HOLDER_NAME     := null;--P_hd_Payment_Tbl(j).CREDIT_CARD_HOLDER_NAME;
		  l_payment_tbl ( 1 ).CREDIT_CARD_EXPIRATION_DATE := null;--P_hd_Payment_Tbl(j).CREDIT_CARD_EXPIRATION_DATE;
		  l_payment_tbl ( 1 ).CVV2 := Null;
	       End If;
	       l_payment_tbl ( 1 ).PAYMENT_TYPE_CODE  := null;--P_hd_Payment_Tbl(j).PAYMENT_TYPE_CODE;
	       l_payment_tbl ( 1 ).PAYMENT_REF_NUMBER := null;--P_hd_Payment_Tbl(j).PAYMENT_REF_NUMBER;
            End If;
	    --If P_hd_Payment_Tbl.count > 0 Then -- Added condition for Bug 11059482
	    l_payment_tbl ( 1 ).CUST_PO_NUMBER  := null;--P_hd_Payment_Tbl(j).CUST_PO_NUMBER;
	    l_payment_tbl ( 1 ).PAYMENT_TERM_ID := null;--P_hd_Payment_Tbl(j).PAYMENT_TERM_ID;
	    --End If;
        End If;

      End If; --  P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then

      -- Header level defaulting starts
      If l_def_profile_value = 'Y' Then

         l_def_control_rec.Dependency_Flag       := FND_API.G_TRUE;
         l_def_control_rec.Defaulting_Flag       := FND_API.G_TRUE;
         l_def_control_rec.Application_Type_Code := 'QUOTING HTML';
         l_def_control_rec.Defaulting_Flow_Code  := 'CREATE';
	 l_db_object_name                        := 'ASO_AK_QUOTE_HEADER_V';
	 l_qte_header_rec.org_id                 := P_Qte_Header_Rec.org_id;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Copy_Header_Rows - Begin Defaulting framework', 1, 'Y');
	    aso_debug_pub.add('Copy_Header_Rows - Dependency_Flag:       '|| l_def_control_rec.Dependency_Flag, 1, 'Y');
            aso_debug_pub.add('Copy_Header_Rows - Defaulting_Flag:       '|| l_def_control_rec.Defaulting_Flag, 1, 'Y');
            aso_debug_pub.add('Copy_Header_Rows - Application_Type_Code: '|| l_def_control_rec.Application_Type_Code, 1, 'Y');
            aso_debug_pub.add('Copy_Header_Rows - Defaulting_Flow_Code:  '|| l_def_control_rec.Defaulting_Flow_Code, 1, 'Y');
            aso_debug_pub.add('Copy_Header_Rows - l_qte_header_rec.org_id: '||l_qte_header_rec.org_id, 1, 'Y');
         END IF ;

	 IF (l_shipment_tbl.COUNT > 0) then
	     l_shipment_rec := l_shipment_tbl(1);
         END IF;

	 IF (l_payment_tbl.COUNT > 0) then
	     l_payment_rec := l_payment_tbl(1);
         END IF;

	 IF l_tax_detail_tbl.count > 0 THEN
            l_hd_tax_detail_rec := l_tax_detail_tbl(1);
         END IF;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.add('Copy_Header_Rows - before call to ASO_DEFAULTING_INT.Default_Entity', 1, 'Y');
         END IF ;

	 ASO_DEFAULTING_INT.Default_Entity ( p_api_version           =>  1.0,
                                             p_control_rec           =>  l_def_control_rec,
                                             p_database_object_name  =>  l_db_object_name,
                                             p_quote_header_rec      =>  l_qte_header_rec,
                                             p_header_shipment_rec   =>  l_shipment_rec,
                                             p_header_payment_rec    =>  l_payment_rec,
				             p_header_tax_detail_rec =>  l_hd_tax_detail_rec,
                                             x_quote_header_rec      =>  lx_qte_header_rec,
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
            aso_debug_pub.add('Copy_Header_Rows: After call to ASO_DEFAULTING_INT.Default_Entity', 1, 'Y');
            aso_debug_pub.add('Copy_Header_Rows: x_return_status: '|| x_return_status, 1, 'Y');
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

	 If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_TRUE Then
            l_qte_header_rec.price_frozen_date := lx_qte_header_rec.price_frozen_date;
         ElsIf P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then
	    l_qte_header_rec := lx_qte_header_rec;

            IF aso_quote_headers_pvt.Shipment_Null_Rec_Exists(lx_hd_shipment_rec, l_db_object_name) THEN
               l_shipment_tbl(1) := lx_hd_shipment_rec;
            END IF;

            IF aso_quote_headers_pvt.Payment_Null_Rec_Exists(lx_hd_payment_rec, l_db_object_name) THEN
               l_payment_tbl(1) := lx_hd_payment_rec;
            END IF;

            l_tax_detail_tbl(1) := lx_hd_tax_detail_rec;
         End If;
	-- Start : code change done in Bug 23299200
	Else
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
	      aso_debug_pub.ADD ( 'Copy_Header_Rows - Defaulting profile is Off', 1 , 'N' );
	    END IF;

		If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then
		   Open C_primary_phone(l_qte_header_rec.PARTY_ID);
           Fetch C_primary_phone into l_qte_header_rec.PHONE_ID;
           Close C_primary_phone;

           For C_Primary_Address_rec In C_Primary_Address(l_qte_header_rec.PARTY_ID)
		   Loop
		       If C_Primary_Address_rec.site_use_type = 'SOLD_TO' Then
                  l_qte_header_rec.SOLD_TO_PARTY_SITE_ID    := C_Primary_Address_rec.party_site_id;
 			   ElsIf C_Primary_Address_rec.site_use_type = 'BILL_TO' Then
				  l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID := C_Primary_Address_rec.party_site_id;
			   ElsIf C_Primary_Address_rec.site_use_type = 'SHIP_TO' Then
                  l_shipment_tbl(1).SHIP_TO_PARTY_SITE_ID   := C_Primary_Address_rec.party_site_id;
			   End If;
           End Loop;

           If l_qte_header_rec.SOLD_TO_PARTY_SITE_ID is Null Or
		      l_qte_header_rec.SOLD_TO_PARTY_SITE_ID = FND_API.G_MISS_NUM Then

			  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	             aso_debug_pub.ADD ( 'Copy_Header_Rows - l_qte_header_rec.SOLD_TO_PARTY_SITE_ID is Null', 1 , 'N' );
	          END IF;

			  Open C_Identifying_Address(l_qte_header_rec.PARTY_ID);
			  Fetch C_Identifying_Address Into l_qte_header_rec.SOLD_TO_PARTY_SITE_ID;
			  Close C_Identifying_Address;
			  l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID := l_qte_header_rec.SOLD_TO_PARTY_SITE_ID;
			  l_shipment_tbl(1).SHIP_TO_PARTY_SITE_ID   := l_qte_header_rec.SOLD_TO_PARTY_SITE_ID;
           End If;
		End If;
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.ADD ( 'Copy_Header_Rows - l_qte_header_rec.SOLD_TO_PARTY_SITE_ID : '||l_qte_header_rec.SOLD_TO_PARTY_SITE_ID, 1 , 'N' );
		   aso_debug_pub.ADD ( 'Copy_Header_Rows - l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID : '||l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID, 1 , 'N' );
		   aso_debug_pub.ADD ( 'Copy_Header_Rows - l_shipment_tbl(1).SHIP_TO_PARTY_SITE_ID : '||l_shipment_tbl(1).SHIP_TO_PARTY_SITE_ID, 1 , 'N' );
	    END IF;
	-- End : code change done in Bug 23299200
	End If;  -- l_def_profile_value = 'Y'
	-- End : Code change done for Bug 18942516

	-- Start : code change done in Bug 22512986

	IF l_qte_header_rec.PRICE_LIST_ID IS NULL OR l_qte_header_rec.PRICE_LIST_ID = FND_API.G_MISS_NUM THEN

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	      aso_debug_pub.ADD ( 'Copy_Header_Rows - Price List defaulting starting', 1 , 'N' );
	      aso_debug_pub.ADD ( 'Copy_Header_Rows - Agreement Id : '||l_qte_header_rec.CONTRACT_ID, 1 , 'N' );
	      aso_debug_pub.ADD ( 'Copy_Header_Rows - Customer Account Id : '||l_qte_header_rec.CUST_ACCOUNT_ID, 1 , 'N' );
          aso_debug_pub.ADD ( 'Copy_Header_Rows - Order Type Id : '||l_qte_header_rec.ORDER_TYPE_ID, 1 , 'N' );
       END IF;

       Open C_Agreement_PL(l_qte_header_rec.CONTRACT_ID);
       Fetch C_Agreement_PL Into l_qte_header_rec.PRICE_LIST_ID,l_qte_header_rec.CURRENCY_CODE;

	    If C_Agreement_PL%FOUND then

	      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	         aso_debug_pub.ADD ( 'Copy_Header_Rows - Price List is defaulted based on Agreement', 1 , 'N' );
          END IF;

	    ElsIf C_Agreement_PL%NOTFOUND then

	      Open C_Customer_PL(l_qte_header_rec.CUST_ACCOUNT_ID);
          Fetch C_Customer_PL Into l_qte_header_rec.PRICE_LIST_ID,l_qte_header_rec.CURRENCY_CODE;

          If C_Customer_PL%FOUND then
             IF aso_debug_pub.g_debug_flag = 'Y' THEN
	            aso_debug_pub.ADD ( 'Copy_Header_Rows - Price List is defaulted based on Customer Account', 1 , 'N' );
             END IF;

	      ElsIf C_Customer_PL%NOTFOUND then

	         Open C_Order_Type_PL(l_qte_header_rec.ORDER_TYPE_ID);
	         Fetch C_Order_Type_PL Into l_qte_header_rec.PRICE_LIST_ID,l_qte_header_rec.CURRENCY_CODE;

             If C_Order_Type_PL%FOUND then
		        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	               aso_debug_pub.ADD ( 'Copy_Header_Rows - Price List is defaulted based on Order Type', 1 , 'N' );
                END IF;
	         End If;
	         Close C_Order_Type_PL;
          End If;
	      Close C_Customer_PL;

       End If;
	   Close C_Agreement_PL;
	End If;

	IF l_qte_header_rec.CURRENCY_CODE IS NULL OR l_qte_header_rec.CURRENCY_CODE = FND_API.G_MISS_CHAR THEN
	   l_qte_header_rec.CURRENCY_CODE := FND_PROFILE.Value('ICX_PREFERRED_CURRENCY');
	End if;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.ADD ( 'Copy_Header_Rows - l_qte_header_rec.PRICE_LIST_ID : '||l_qte_header_rec.PRICE_LIST_ID, 1 , 'N' );
	   aso_debug_pub.ADD ( 'Copy_Header_Rows - l_qte_header_rec.CURRENCY_CODE : '||l_qte_header_rec.CURRENCY_CODE, 1 , 'N' );
    END IF;

	IF l_qte_header_rec.CURRENCY_CODE IS NULL OR l_qte_header_rec.CURRENCY_CODE = FND_API.G_MISS_CHAR THEN
	   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
          FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
          FND_MESSAGE.Set_Token ('COLUMN' , 'CURRENCY_CODE', FALSE );
          FND_MESSAGE.Set_Token ( 'VALUE' , l_qte_header_rec.CURRENCY_CODE , FALSE );
          FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
	-- End : code change done for Bug 22512986

      If P_Copy_Quote_Control_Rec.Copy_Flexfield = FND_API.G_FALSE Then
          l_qte_header_rec.ATTRIBUTE1 :=  Null;
	  l_qte_header_rec.ATTRIBUTE2 :=  Null;
	  l_qte_header_rec.ATTRIBUTE3 :=  Null;
	  l_qte_header_rec.ATTRIBUTE4 :=  Null;
	  l_qte_header_rec.ATTRIBUTE5 :=  Null;
	  l_qte_header_rec.ATTRIBUTE6 :=  Null;
	  l_qte_header_rec.ATTRIBUTE7 :=  Null;
	  l_qte_header_rec.ATTRIBUTE8 :=  Null;
	  l_qte_header_rec.ATTRIBUTE9 :=  Null;
	  l_qte_header_rec.ATTRIBUTE10 := Null;
	  l_qte_header_rec.ATTRIBUTE11 := Null;
	  l_qte_header_rec.ATTRIBUTE12 := Null;
	  l_qte_header_rec.ATTRIBUTE13 := Null;
	  l_qte_header_rec.ATTRIBUTE14 := Null;
	  l_qte_header_rec.ATTRIBUTE15 := Null;
	  l_qte_header_rec.ATTRIBUTE16 := Null;
	  l_qte_header_rec.ATTRIBUTE17 := Null;
	  l_qte_header_rec.ATTRIBUTE18 := Null;
	  l_qte_header_rec.ATTRIBUTE19 := Null;
	  l_qte_header_rec.ATTRIBUTE20 := Null;
      End If;
      /* Code change for Quoting Usability Sun ER End */

      l_Line_Attr_Ext_Tbl        :=
            ASO_UTILITY_PVT.Query_Line_Attribs_header_Rows (
                P_Qte_header_Id =>              l_qte_header_id
             );
/*
      l_sales_credit_tbl         :=
            ASO_UTILITY_PVT.Query_Sales_Credit_Row (
                P_qte_header_Id =>              l_qte_header_id
             , P_qte_line_id =>                 NULL
             );
*/
      l_quote_party_tbl          :=
            ASO_UTILITY_PVT.Query_Quote_Party_Row (
                P_Qte_header_Id =>              l_qte_header_id
             , P_qte_line_id =>                 NULL
             );

      IF P_Copy_Quote_Control_Rec.Copy_Header_Only = FND_API.G_TRUE THEN
         l_qte_header_rec.TOTAL_LIST_PRICE := NULL;
         l_qte_header_rec.TOTAL_ADJUSTED_AMOUNT := NULL;
         l_qte_header_rec.TOTAL_ADJUSTED_PERCENT := NULL;
         l_qte_header_rec.TOTAL_TAX := NULL;
         l_qte_header_rec.TOTAL_SHIPPING_CHARGE := NULL;
         l_qte_header_rec.SURCHARGE := NULL;
         l_qte_header_rec.TOTAL_QUOTE_PRICE := NULL;
         l_qte_header_rec.PAYMENT_AMOUNT := NULL;
         l_qte_header_rec.ORDERED_DATE := NULL;
      END IF;

      l_qte_header_rec.PUBLISH_FLAG := NULL;
      l_qte_header_rec.ORDER_ID  := NULL;
      l_qte_header_rec.ORDER_NUMBER := NULL;
      l_qte_header_rec.quote_header_id := NULL;
      l_qte_header_rec.price_updated_date := NULL;
	 l_qte_header_rec.tax_updated_date := NULL;
      l_qte_header_rec.price_request_id := NULL;
       -- l_qte_header_rec.price_frozen_date := NULL; commented as per Bug 18942516

-- hyang new okc
    l_qte_header_rec.Customer_Name_And_Title := NULL;
    l_qte_header_rec.Customer_Signature_Date := NULL;
    l_qte_header_rec.Supplier_Name_And_Title := NULL;
    l_qte_header_rec.Supplier_Signature_Date := NULL;
-- end of hyang new okc

   -- bug 5159758
        IF ( P_Copy_Quote_Control_Rec.New_Version = FND_API.G_FALSE ) THEN
            l_qte_header_rec.ASSISTANCE_REQUESTED := null;
            l_qte_header_rec.ASSISTANCE_REASON_CODE := null;
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
	          aso_debug_pub.ADD ( 'Copy_Rows - Nulled out the ASSISTANCE_REQUESTED and ASSISTANCE_REASON_CODE' , 1 , 'N' );
	       END IF;
        END IF;



--BC4J Primary Key Fix


               FOR j IN 1 .. l_price_adj_tbl.COUNT LOOP
                  l_price_adj_tbl ( j ).price_adjustment_id := null;
                  l_price_adj_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_price_adj_attr_tbl.COUNT LOOP
                  l_price_adj_attr_tbl(j).price_adj_attrib_id := null;
                  l_price_adj_attr_tbl(j).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_price_attr_tbl.COUNT LOOP
                  l_price_attr_tbl ( j ).price_attribute_id := null;
                  l_price_attr_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               /*
               FOR j IN 1 .. l_payment_tbl.COUNT LOOP
                  l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_CODE := NULL;
                  l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_DATE := NULL;
                  l_payment_tbl ( j ).payment_id := NULL;
                  l_payment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
			END LOOP; */

               FOR j IN 1 .. l_shipment_tbl.COUNT LOOP
                  l_shipment_tbl ( j ).shipment_id := null;
                  l_shipment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_sales_credit_tbl.COUNT LOOP
                  l_sales_credit_tbl(j).sales_credit_id := null;
			   l_sales_credit_tbl(j).object_version_number := FND_API.G_MISS_NUM;
               END LOOP;

               FOR j IN 1 .. l_quote_party_tbl.COUNT LOOP
                  l_quote_party_tbl(j).QUOTE_PARTY_ID  := null;
                  l_quote_party_tbl(j).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_tax_detail_tbl.COUNT LOOP
                  l_tax_detail_tbl(j).tax_detail_id  := null;
                  l_tax_detail_tbl(j).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_Line_Attr_Ext_Tbl.COUNT LOOP
                  l_Line_Attr_Ext_Tbl(j).line_attribute_id  := null;
                  l_Line_Attr_Ext_Tbl(j).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

			l_qte_header_rec.object_version_number := FND_API.G_MISS_NUM;

       --End of BC4J Primary Key Fix

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Header_Rows - Before insert_rows ', 1 , 'Y' );
	 END IF;

      ASO_QUOTE_HEADERS_PVT.Insert_Rows (
          p_qte_header_rec =>             l_qte_header_rec
       , p_Price_Attributes_Tbl =>        l_price_attr_tbl
       , P_Price_Adjustment_Tbl =>        l_price_adj_tbl
       , P_Price_Adj_Attr_Tbl =>          l_price_adj_attr_tbl
       -- , P_Payment_Tbl =>              l_payment_tbl  ASO_QUOTE_PUB.G_MISS_Payment_TBL
       , P_Payment_Tbl =>                 ASO_QUOTE_PUB.G_MISS_Payment_TBL  -- Added for Bug 18942516
       , P_Shipment_Tbl =>                l_shipment_tbl
       , P_Freight_Charge_Tbl =>          l_freight_charge_tbl
       , P_Tax_Detail_Tbl =>              l_tax_detail_tbl
       , P_hd_Attr_Ext_Tbl =>             l_Line_Attr_Ext_Tbl
       , P_Sales_Credit_Tbl =>            l_sales_credit_tbl
       , P_Quote_Party_Tbl =>             l_Quote_Party_Tbl
       , P_qte_access_Tbl =>              l_qte_access_tbl
	  , x_qte_header_rec =>              l_qte_header_rec_out
       , x_Price_Attributes_Tbl =>        l_price_attr_tbl_out
       , x_Price_Adjustment_Tbl =>        lx_hd_Price_Adj_Tbl
       , x_Price_Adj_Attr_Tbl =>          l_price_adj_attr_tbl_out
       , x_Payment_Tbl =>                 l_payment_tbl_out
       , x_Shipment_Rec =>                l_shipment_rec
       , x_Freight_Charge_Tbl =>          l_freight_charge_tbl_out
       , x_Tax_Detail_Tbl =>              l_tax_detail_tbl_out
       , x_hd_Attr_Ext_Tbl =>             x_hd_Attr_Ext_Tbl
       , x_sales_credit_tbl =>            x_sales_credit_tbl
       , x_quote_party_tbl =>             x_quote_party_tbl
       , x_qte_access_Tbl =>              x_qte_access_tbl
       , X_Return_Status =>               l_return_status
       , X_Msg_Count =>                   x_msg_count
       , X_Msg_Data =>                    x_msg_data
       );



      l_qte_header_rec :=l_qte_header_rec_out ;
      l_Price_Attr_Tbl := l_Price_Attr_Tbl_out ;
      l_Price_Adj_Attr_Tbl := l_Price_Adj_Attr_Tbl_out ;
      l_freight_charge_tbl :=l_freight_charge_tbl_out ;
      l_tax_detail_tbl := l_tax_detail_tbl_out ;
      --  l_payment_tbl := l_payment_tbl_out; commented for Bug 18942516

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Header_Rows - After insert_rows - status: ' || l_return_status , 1 , 'Y' );
	 END IF;

      IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
            FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYHEADER AFTER_INSERT' , TRUE );
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_qte_header_id            := l_qte_header_rec.quote_header_id;

      -- Copy the header payment record
      l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows(p_qte_header_id =>l_qte_header_id,p_qte_line_id =>NULL);

    IF l_payment_tbl.count > 0 then

          l_payment_tbl ( 1 ).quote_header_id := l_qte_header_rec.quote_header_id;
	  l_payment_tbl ( 1 ).CREDIT_CARD_APPROVAL_CODE := NULL;
          l_payment_tbl ( 1 ).CREDIT_CARD_APPROVAL_DATE := NULL;
          l_payment_tbl ( 1 ).payment_id := NULL;
	  l_payment_tbl ( 1 ).object_version_number := FND_API.G_MISS_NUM;

	  /* commented as per Bug 18942516
	  /* Code change for Quoting Usability Sun ER Start
          FOR j IN 1 .. l_payment_tbl.COUNT LOOP
	  If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_TRUE Then
	     If P_Copy_Quote_Control_Rec.Copy_Payment = FND_API.G_FALSE Then
                l_payment_tbl ( j ).CUST_PO_NUMBER := Null;
	        l_payment_tbl ( j ).PAYMENT_TERM_ID := Null;
		l_payment_tbl ( j ).PAYMENT_TYPE_CODE := NULL;
		l_payment_tbl ( j ).PAYMENT_REF_NUMBER := Null;
		l_payment_tbl ( j ).CREDIT_CARD_CODE := Null;
		l_payment_tbl ( j ).CREDIT_CARD_HOLDER_NAME := Null;
		l_payment_tbl ( j ).CREDIT_CARD_EXPIRATION_DATE := Null;
	     End If;
	  ElsIf P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then
	     -- Setting payment related fields to null as per discussion bug 16591499
	     If l_payment_tbl ( j ).PAYMENT_TYPE_CODE In ('CHECK','CREDIT_CARD') Then
       		If l_payment_tbl ( j ).PAYMENT_TYPE_CODE = 'CREDIT_CARD' Then
		   l_payment_tbl ( j ).CREDIT_CARD_CODE            := null;--P_hd_Payment_Tbl(j).CREDIT_CARD_CODE;
		   l_payment_tbl ( j ).CREDIT_CARD_HOLDER_NAME     := null;--P_hd_Payment_Tbl(j).CREDIT_CARD_HOLDER_NAME;
		   l_payment_tbl ( j ).CREDIT_CARD_EXPIRATION_DATE := null;--P_hd_Payment_Tbl(j).CREDIT_CARD_EXPIRATION_DATE;
		End If;
		l_payment_tbl ( j ).PAYMENT_TYPE_CODE  := null;--P_hd_Payment_Tbl(j).PAYMENT_TYPE_CODE;
		l_payment_tbl ( j ).PAYMENT_REF_NUMBER := null;--P_hd_Payment_Tbl(j).PAYMENT_REF_NUMBER;
             End If;
	     --If P_hd_Payment_Tbl.count > 0 Then -- Added condition for Bug 11059482
	        l_payment_tbl ( j ).CUST_PO_NUMBER  := null;--P_hd_Payment_Tbl(j).CUST_PO_NUMBER;
	        l_payment_tbl ( j ).PAYMENT_TERM_ID := null;--P_hd_Payment_Tbl(j).PAYMENT_TERM_ID;
	     --End If;
          End If;
	  END LOOP; */
	  /* Code change for Quoting Usability Sun ER End */

       If P_Copy_Quote_Control_Rec.Copy_Payment = FND_API.G_TRUE Then  -- Code change for Quoting Usability Sun ER

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Copy_Header: Before  call to copy_payment_row ', 1, 'Y');
       END IF;

         aso_copy_quote_pvt.copy_payment_row(p_payment_rec => l_payment_tbl(1)  ,
                                             x_return_status => l_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Copy_Header: After call to copy_payment_row: x_return_status: '||l_return_status, 1, 'Y');
       END IF;
      IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
            FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYHEADER AFTER_INSERT' , TRUE );
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF;

   End If; -- Code change for Quoting Usability Sun ER

     -- End Copy payment record

      -- Copy Notes,Task and Attachment related to quote header only if the control_rec flag is set
      IF P_Copy_Quote_Control_Rec.Copy_Note = FND_API.G_TRUE THEN

	  -- Checking the new version flag, if new version then creating reference otherwise creating new note
	  -- see bug3805575 for more details

	  IF P_Copy_Quote_Control_Rec.New_Version = FND_API.G_TRUE THEN

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Rows - Begin- before copy_notes-l_old_qte_header_id ' || l_old_qte_header_id , 1 , 'N' );
	    aso_debug_pub.ADD ( 'Copy_Rows - Begin- before copy_notes-x_qte_header_id ' || x_qte_header_id , 1 , 'N' );
         aso_debug_pub.ADD ('Copy_Rows - Begin- before copy_notes ' , 1, 'N' );
	    aso_debug_pub.ADD ('Copy_Rows - Begin- creating new reference for note ' , 1, 'N' );
	    END IF;

         ASO_NOTES_INT.COPY_NOTES (
             p_api_version =>                l_api_version
          , p_init_msg_list =>               FND_API.G_FALSE
          , p_commit =>                      FND_API.G_FALSE
          , x_return_status =>               l_return_status
          , x_msg_count =>                   x_msg_count
          , x_msg_data =>                    x_msg_data
          , p_old_object_id =>               l_old_qte_header_id
          , p_new_object_id =>               x_qte_header_id
          , p_old_object_type_code =>        'ASO_QUOTE'
          , p_new_object_type_code =>        'ASO_QUOTE'
          );
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Rows - after copy_notes status' || l_return_status , 1 , 'Y' );
	    END IF;

         IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
               FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYHEADER AFTER_NOTES' , TRUE );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
            x_return_status            := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

       ELSE  -- this means new quote is being created
	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.ADD ('Copy_Rows - Begin- creating new note ' , 1, 'N' );
         END IF;
         ASO_NOTES_INT.Copy_Notes_copy_quote (
            p_api_version =>                l_api_version
          , p_init_msg_list =>               FND_API.G_FALSE
          , p_commit =>                      FND_API.G_FALSE
          , p_old_object_id =>               l_old_qte_header_id
          , p_new_object_id =>               x_qte_header_id
          , p_old_object_type_code =>        'ASO_QUOTE'
          , p_new_object_type_code =>        'ASO_QUOTE'
          , x_return_status =>               l_return_status
          , x_msg_count =>                   x_msg_count
          , x_msg_data =>                    x_msg_data
          );
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.ADD ( 'Copy_Rows - after Copy_Notes_copy_quote  status' || l_return_status , 1 , 'Y' );
         END IF;

         IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
               FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYHEADER AFTER_NOTES' , TRUE );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
            x_return_status            := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

	  END IF; -- end if for new version flag

      END IF;  -- end if for copy notes flag

      IF P_Copy_Quote_Control_Rec.Copy_Task = FND_API.G_TRUE THEN
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ('Copy_Rows - Begin- before copy_tasks ' , 1, 'Y' );
	    END IF;

         ASO_TASK_INT.COPY_TASKS (
             p_api_version =>                l_api_version
          , p_init_msg_list =>               FND_API.G_FALSE
          , p_commit =>                      FND_API.G_FALSE
          , x_return_status =>               l_return_status
          , x_msg_count =>                   x_msg_count
          , x_msg_data =>                    x_msg_data
          , p_old_object_id =>               l_old_qte_header_id
          , p_new_object_id =>               x_qte_header_id
          , p_old_object_type_code =>        'ASO_QUOTE'
          , p_new_object_type_code =>        'ASO_QUOTE'
          , p_new_object_name =>                l_qte_header_rec.quote_number
                                             || FND_GLOBAL.local_chr ( 45 )
                                             || l_qte_header_rec.quote_version ,
		p_quote_version_flag  =>          P_Copy_Quote_Control_Rec.New_Version
          );
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Rows - after  copy_tasks status' || l_return_status , 1 , 'Y' );
	    END IF;

         IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
               FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYHEADER AFTER_TASKS' , TRUE );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
            x_return_status            := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;

      IF P_Copy_Quote_Control_Rec.Copy_Attachment = FND_API.G_TRUE THEN
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Rows - Begin- before copy_attch  ' , 1 , 'Y' );
	    END IF;

         ASO_ATTACHMENT_INT.COPY_ATTACHMENTS(
            p_api_version         =>  l_api_version,
            p_old_object_code     => 'ASO_QUOTE_HEADERS_ALL',
            p_new_object_code     => 'ASO_QUOTE_HEADERS_ALL',
            p_old_object_id       =>  l_old_qte_header_id,
            p_new_object_id       =>  x_qte_header_id,
            x_return_status       =>  l_return_status,
            x_msg_count           =>  x_msg_count,
            x_msg_data            =>  x_msg_data
          );
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Rows -After copy_attch ' || l_return_status , 1 , 'Y' );
	    END IF;

         IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
               FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYHEADER AFTER_ATTACHMENTS' , TRUE );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
            x_return_status            := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      END IF;

      FOR j IN 1 .. l_price_adj_tbl.COUNT LOOP
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Header_Rows: lx_hd_price_adj_tbl(j).price_adjustment_id' || lx_hd_price_adj_tbl ( j ).price_adjustment_id , 1 , 'Y' );
	    END IF;

         X_Price_Index_Link_Tbl ( l_dup_price_adj_tbl ( j ).price_adjustment_id ) :=
                                lx_hd_price_adj_tbl ( j ).price_adjustment_id;
      END LOOP;

-- Requirement CPQ-5

      IF P_Copy_Quote_Control_Rec.New_Version = FND_API.G_FALSE THEN
         -- security changes

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Header_Rows: value of ASO_API_ENABLE_SECURITY: ' || FND_PROFILE.VALUE ('ASO_API_ENABLE_SECURITY' ) , 1 , 'Y' );
	    END IF;

	    l_qte_header_rec.batch_price_flag := FND_API.G_FALSE;

	    IF NVL ( FND_PROFILE.VALUE ('ASO_API_ENABLE_SECURITY' ), 'N' ) = 'Y' THEN

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.ADD ( 'Copy_Header_Rows: Sales_Team: l_sales_team_prof: ' || l_sales_team_prof , 1 , 'N' );
              END IF;

            If (P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_TRUE And
	        P_Copy_Quote_Control_Rec.Copy_Sales_Team = FND_API.G_TRUE) Then   -- Code change for Quoting Usability Sun ER

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.ADD ( 'Copy_Header_Rows - Copy_To_Same_Customer is True and Copy_Sales_Team is True ', 1 , 'N' );
                END IF;

            IF l_sales_team_prof = 'FULL' OR l_sales_team_prof = 'PARTIAL' THEN

              OPEN C_Get_Old_Qte (l_old_qte_header_id);
              FETCH C_Get_Old_Qte INTO l_old_qte_num;
              CLOSE C_Get_Old_Qte;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.ADD ( 'Copy_Header_Rows: Sales_Team: l_old_qte_num: ' || l_old_qte_num , 1 , 'N' );
              END IF;
              FOR C_Sales_Team_Rec IN C_Get_Sales_Team(l_old_qte_num) LOOP

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.ADD ( 'Copy_Header_Rows: Sales_Team: Add Res: Resource_Id: ' || C_Sales_Team_Rec.Resource_Id , 1 , 'N' );
		   aso_debug_pub.ADD ( 'Copy_Header_Rows: Sales_Team: Add Res: Resource_Grp_Id: ' || C_Sales_Team_Rec.Resource_Grp_Id , 1 , 'N' );
		   aso_debug_pub.ADD ( 'Copy_Header_Rows: Sales_Team: Add Res: l_qte_header_rec.Quote_Number: ' || l_qte_header_rec.Quote_Number , 1 , 'N' );
                END IF;

		l_sequence := NULL;

                ASO_QUOTE_ACCESSES_PKG.Insert_Row(
                px_ACCESS_ID             => l_sequence,
                p_QUOTE_NUMBER           => l_qte_header_rec.Quote_Number,
                p_RESOURCE_ID            => C_Sales_Team_Rec.Resource_Id,
                p_RESOURCE_GRP_ID        => C_Sales_Team_Rec.Resource_Grp_Id,
	        p_CREATED_BY             => G_USER_ID,
                p_CREATION_DATE          => SYSDATE,
                p_LAST_UPDATED_BY        => G_USER_ID,
                p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
                p_LAST_UPDATE_DATE       => SYSDATE,
                p_REQUEST_ID             => C_Sales_Team_Rec.Request_Id,
                p_PROGRAM_APPLICATION_ID => C_Sales_Team_Rec.Program_Application_Id,
                p_PROGRAM_ID             => C_Sales_Team_Rec.Program_Id,
                p_PROGRAM_UPDATE_DATE    => C_Sales_Team_Rec.Program_Update_Date,
                p_KEEP_FLAG              => C_Sales_Team_Rec.Keep_Flag,
                p_UPDATE_ACCESS_FLAG     => C_Sales_Team_Rec.Update_Access_Flag,
                p_CREATED_BY_TAP_FLAG    => C_Sales_Team_Rec.Created_By_Tap_Flag,
                p_TERRITORY_ID           => C_Sales_Team_Rec.Territory_Id,
                p_TERRITORY_SOURCE_FLAG  => C_Sales_Team_Rec.Territory_Source_Flag,
                p_ROLE_ID                => C_Sales_Team_Rec.Role_Id,
                p_ATTRIBUTE_CATEGORY     => C_Sales_Team_Rec.ATTRIBUTE_CATEGORY,
                p_ATTRIBUTE1             => C_Sales_Team_Rec.ATTRIBUTE1,
                p_ATTRIBUTE2             => C_Sales_Team_Rec.ATTRIBUTE2,
                p_ATTRIBUTE3             => C_Sales_Team_Rec.ATTRIBUTE3,
                p_ATTRIBUTE4             => C_Sales_Team_Rec.ATTRIBUTE4,
                p_ATTRIBUTE5             => C_Sales_Team_Rec.ATTRIBUTE5,
                p_ATTRIBUTE6             => C_Sales_Team_Rec.ATTRIBUTE6,
                p_ATTRIBUTE7             => C_Sales_Team_Rec.ATTRIBUTE7,
                p_ATTRIBUTE8             => C_Sales_Team_Rec.ATTRIBUTE8,
                p_ATTRIBUTE9             => C_Sales_Team_Rec.ATTRIBUTE9,
                p_ATTRIBUTE10            => C_Sales_Team_Rec.ATTRIBUTE10,
                p_ATTRIBUTE11            => C_Sales_Team_Rec.ATTRIBUTE11,
                p_ATTRIBUTE12            => C_Sales_Team_Rec.ATTRIBUTE12,
                p_ATTRIBUTE13            => C_Sales_Team_Rec.ATTRIBUTE13,
                p_ATTRIBUTE14            => C_Sales_Team_Rec.ATTRIBUTE14,
                p_ATTRIBUTE15            => C_Sales_Team_Rec.ATTRIBUTE15,
			 p_ATTRIBUTE16            => C_Sales_Team_Rec.ATTRIBUTE16,
			 p_ATTRIBUTE17            => C_Sales_Team_Rec.ATTRIBUTE17,
			 p_ATTRIBUTE18            => C_Sales_Team_Rec.ATTRIBUTE18,
			 p_ATTRIBUTE19            => C_Sales_Team_Rec.ATTRIBUTE19,
			 p_ATTRIBUTE20            => C_Sales_Team_Rec.ATTRIBUTE20,
			 p_Object_Version_Number => C_Sales_Team_Rec.OBJECT_VERSION_NUMBER
                );

              END LOOP;

            ELSE

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.ADD ( 'Copy_Header_Rows: Sales_Team: l_sales_team_prof : ' || l_sales_team_prof , 1 , 'N' );
                END IF;

              ASO_SECURITY_INT.Add_SalesRep_QuoteCreator (
                  p_init_msg_list =>              FND_API.G_FALSE
               , p_commit =>                      FND_API.G_FALSE
               , p_Qte_Header_Rec =>              l_qte_header_rec
               , x_return_status =>               x_return_status
               , x_msg_count =>                   x_msg_count
               , x_msg_data =>                    x_msg_data
               );
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.ADD ( 'Copy_Header_Rows: After Add Salesrep: x_return_status: ' || x_return_status , 1 , 'N' );
              END IF;
            END IF; -- sales_team_prof

	    /* Code change for Quoting Usability Sun ER Start */
	    ElsIf (P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_TRUE And
	           P_Copy_Quote_Control_Rec.Copy_Sales_Team = FND_API.G_FALSE) Then

		   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	              aso_debug_pub.ADD ( 'Copy_Header_Rows - Copy_To_Same_Customer is True and Copy_Sales_Team is False ', 1 , 'N' );
                   END IF;

		ASO_SECURITY_INT.Add_SalesRep_QuoteCreator (
                  p_init_msg_list =>              FND_API.G_FALSE
               , p_commit =>                      FND_API.G_FALSE
               , p_Qte_Header_Rec =>              l_qte_header_rec
               , x_return_status =>               x_return_status
               , x_msg_count =>                   x_msg_count
               , x_msg_data =>                    x_msg_data
               );
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.ADD ( 'Copy_Header_Rows: After Add Salesrep: x_return_status: ' || x_return_status , 1 , 'N' );
              END IF;

            ElsIf (P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE) Then

	           IF aso_debug_pub.g_debug_flag = 'Y' THEN
	              aso_debug_pub.ADD ( 'Copy_Header_Rows - Copy_To_Same_Customer is False in Copy Sales Team flow', 1 , 'N' );
                   END IF;

		   IF l_sales_team_prof = 'FULL' OR l_sales_team_prof = 'PARTIAL' THEN

		        IF aso_debug_pub.g_debug_flag = 'Y' THEN
		           aso_debug_pub.ADD ( 'Copy_Header_Rows: Before calling ASO_SECURITY_INT.Add_SalesRep_QuoteCreator ' , 1 , 'N' );
                        END IF;

	                  ASO_SECURITY_INT.Add_SalesRep_QuoteCreator (
                          p_init_msg_list =>               FND_API.G_FALSE
                        , p_commit =>                      FND_API.G_FALSE
                        , p_Qte_Header_Rec =>              l_qte_header_rec
                        , x_return_status =>               x_return_status
                        , x_msg_count =>                   x_msg_count
                        , x_msg_data =>                    x_msg_data );

                        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.ADD ( 'Copy_Header_Rows: After Add Salesrep: x_return_status: ' || x_return_status , 1 , 'N' );
                        END IF;
		   Else
                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
                          aso_debug_pub.ADD ( 'Copy_Header_Rows: Sales_Team: l_sales_team_prof : ' || l_sales_team_prof , 1 , 'N' );
                       END IF;

		       OPEN C_Get_Old_Qte (l_old_qte_header_id);
                       FETCH C_Get_Old_Qte INTO l_old_qte_num;
                       CLOSE C_Get_Old_Qte;

                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
                          aso_debug_pub.ADD ( 'Copy_Header_Rows: Sales_Team: l_old_qte_num: ' || l_old_qte_num , 1 , 'N' );
                       END IF;

		       FOR C_Sales_Team_Rec IN C_Get_Sales_Team(l_old_qte_num) LOOP

		           IF aso_debug_pub.g_debug_flag = 'Y' THEN
			      aso_debug_pub.ADD ( 'Copy_Header_Rows: Sales_Team: Add Res: C_Sales_Team_Rec.Resource_Id: ' || C_Sales_Team_Rec.Resource_Id , 1 , 'N' );
		              aso_debug_pub.ADD ( 'Copy_Header_Rows: Sales_Team: Add Res: C_Sales_Team_Rec.Resource_Grp_Id: ' || C_Sales_Team_Rec.Resource_Grp_Id , 1 , 'N' );
			      aso_debug_pub.ADD ( 'Copy_Header_Rows: Sales_Team: Add Res: l_qte_header_rec.Quote_Number: ' || l_qte_header_rec.Quote_Number , 1 , 'N' );
                           END IF;

		           l_sequence := NULL;

                           ASO_QUOTE_ACCESSES_PKG.Insert_Row(
                           px_ACCESS_ID             => l_sequence,
                           p_QUOTE_NUMBER           => l_qte_header_rec.Quote_Number,
 	                   p_RESOURCE_ID            => C_Sales_Team_Rec.Resource_Id,
	                   p_RESOURCE_GRP_ID        => C_Sales_Team_Rec.Resource_Grp_Id,
                           p_CREATED_BY             => G_USER_ID,
                           p_CREATION_DATE          => SYSDATE,
                           p_LAST_UPDATED_BY        => G_USER_ID,
                           p_LAST_UPDATE_LOGIN      => G_LOGIN_ID,
                           p_LAST_UPDATE_DATE       => SYSDATE,
                           p_REQUEST_ID             => C_Sales_Team_Rec.Request_Id,
                           p_PROGRAM_APPLICATION_ID => C_Sales_Team_Rec.Program_Application_Id,
                           p_PROGRAM_ID             => C_Sales_Team_Rec.Program_Id,
                           p_PROGRAM_UPDATE_DATE    => C_Sales_Team_Rec.Program_Update_Date,
                           p_KEEP_FLAG              => C_Sales_Team_Rec.Keep_Flag,
                           p_UPDATE_ACCESS_FLAG     => C_Sales_Team_Rec.Update_Access_Flag,
                           p_CREATED_BY_TAP_FLAG    => C_Sales_Team_Rec.Created_By_Tap_Flag,
                           p_TERRITORY_ID           => C_Sales_Team_Rec.Territory_Id,
                           p_TERRITORY_SOURCE_FLAG  => C_Sales_Team_Rec.Territory_Source_Flag,
                           p_ROLE_ID                => C_Sales_Team_Rec.Role_Id,
                           p_ATTRIBUTE_CATEGORY     => C_Sales_Team_Rec.ATTRIBUTE_CATEGORY,
                           p_ATTRIBUTE1             => C_Sales_Team_Rec.ATTRIBUTE1,
                           p_ATTRIBUTE2             => C_Sales_Team_Rec.ATTRIBUTE2,
                           p_ATTRIBUTE3             => C_Sales_Team_Rec.ATTRIBUTE3,
                           p_ATTRIBUTE4             => C_Sales_Team_Rec.ATTRIBUTE4,
                           p_ATTRIBUTE5             => C_Sales_Team_Rec.ATTRIBUTE5,
                           p_ATTRIBUTE6             => C_Sales_Team_Rec.ATTRIBUTE6,
                           p_ATTRIBUTE7             => C_Sales_Team_Rec.ATTRIBUTE7,
                           p_ATTRIBUTE8             => C_Sales_Team_Rec.ATTRIBUTE8,
                           p_ATTRIBUTE9             => C_Sales_Team_Rec.ATTRIBUTE9,
                           p_ATTRIBUTE10            => C_Sales_Team_Rec.ATTRIBUTE10,
                           p_ATTRIBUTE11            => C_Sales_Team_Rec.ATTRIBUTE11,
                           p_ATTRIBUTE12            => C_Sales_Team_Rec.ATTRIBUTE12,
                           p_ATTRIBUTE13            => C_Sales_Team_Rec.ATTRIBUTE13,
                           p_ATTRIBUTE14            => C_Sales_Team_Rec.ATTRIBUTE14,
                           p_ATTRIBUTE15            => C_Sales_Team_Rec.ATTRIBUTE15,
			   p_ATTRIBUTE16            => C_Sales_Team_Rec.ATTRIBUTE16,
			   p_ATTRIBUTE17            => C_Sales_Team_Rec.ATTRIBUTE17,
			   p_ATTRIBUTE18            => C_Sales_Team_Rec.ATTRIBUTE18,
			   p_ATTRIBUTE19            => C_Sales_Team_Rec.ATTRIBUTE19,
			   p_ATTRIBUTE20            => C_Sales_Team_Rec.ATTRIBUTE20,
			   p_Object_Version_Number  => C_Sales_Team_Rec.OBJECT_VERSION_NUMBER);
                       END LOOP;
		   End If;	-- l_sales_team_prof is None
	    End If;
	    /* Code change for Quoting Usability Sun ER End */
         END IF;
      -- end security changes

      END IF;

      x_return_status            := FND_API.G_RET_STS_SUCCESS;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean ( p_commit ) THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
          p_count =>                      x_msg_count
       , p_data =>                        x_msg_data
       );

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_SQLCODE =>                     SQLCODE
          , P_SQLERRM =>                     SQLERRM
          , P_EXCEPTION_LEVEL =>             ASO_UTILITY_PVT.G_EXC_OTHERS
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

   END Copy_Header_Rows;


   PROCEDURE Copy_Line_Rows (
       P_Api_Version_Number IN NUMBER
    , P_Init_Msg_List IN VARCHAR2 := FND_API.G_FALSE
    , P_Commit IN VARCHAR2 := FND_API.G_FALSE
    , P_Qte_Header_Id IN NUMBER
    , P_New_Qte_Header_Id IN NUMBER
    , P_Qte_Line_Id     IN   NUMBER   := FND_API.G_MISS_NUM
    , P_Price_Index_Link_Tbl IN ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type
    , P_Copy_Quote_Control_Rec IN ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type
    , P_Qte_Header_Rec         IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
    , P_Control_Rec            IN   ASO_QUOTE_PUB.Control_Rec_Type
    , X_Qte_Line_Id            OUT NOCOPY /* file.sql.39 change */    NUMBER
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    ) IS

      CURSOR c_line_relation (
          x_quote_header_id NUMBER
       ) IS
         SELECT LINE_RELATIONSHIP_ID, CREATION_DATE, CREATED_BY
              , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
              , REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID
              , PROGRAM_UPDATE_DATE, QUOTE_LINE_ID, RELATED_QUOTE_LINE_ID
              , RELATIONSHIP_TYPE_CODE, RECIPROCAL_FLAG, OBJECT_VERSION_NUMBER
         FROM   ASO_LINE_RELATIONSHIPS
         WHERE  quote_line_id IN ( SELECT quote_line_id
                                  FROM   aso_quote_lines_all
                                  WHERE  quote_header_id = x_quote_header_id )
         AND    relationship_type_code <> 'SERVICE';

      CURSOR c_price_adj_rel (
          x_quote_header_id NUMBER
       ) IS
         SELECT apr.ADJ_RELATIONSHIP_ID, apr.CREATION_DATE, apr.CREATED_BY
              , apr.LAST_UPDATE_DATE, apr.LAST_UPDATED_BY
              , apr.LAST_UPDATE_LOGIN, apr.PROGRAM_APPLICATION_ID
              , apr.PROGRAM_ID, apr.PROGRAM_UPDATE_DATE, apr.REQUEST_ID
              , apr.QUOTE_LINE_ID, apr.PRICE_ADJUSTMENT_ID
              , apr.RLTD_PRICE_ADJ_ID , apr.OBJECT_VERSION_NUMBER
         FROM   ASO_PRICE_ADJ_RELATIONSHIPS apr
              , ASO_PRICE_ADJUSTMENTS apa
         WHERE  apr.price_adjustment_id = apa.price_adjustment_id
         AND    apa.quote_header_id = x_quote_header_id
         AND    EXISTS (  SELECT 'x'
                         FROM   aso_quote_lines_all aql
                         WHERE  aql.quote_header_id = x_quote_header_id
                         AND    apr.quote_line_id = aql.quote_line_id );

      CURSOR C_Serviceable_Product (
          l_organization_id NUMBER
       , l_inv_item_id NUMBER
       ) IS
         SELECT serviceable_product_flag, service_item_flag
         FROM   MTL_SYSTEM_ITEMS_VL
         WHERE  inventory_item_id = l_inv_item_id
         AND    organization_id = l_organization_id;

	 CURSOR C_Get_Ship_Id (
          lc_line_id NUMBER
       ) IS
         SELECT shipment_id
         FROM   ASO_SHIPMENTS
         WHERE  quote_line_id = lc_line_id;

      l_qte_line_rec ASO_QUOTE_PUB.Qte_Line_Rec_Type;
      l_qte_line_tbl ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
      l_payment_tbl ASO_QUOTE_PUB.Payment_Tbl_Type;
      l_shipment_tbl ASO_QUOTE_PUB.Shipment_Tbl_Type;
      l_shipment_rec ASO_QUOTE_PUB.Shipment_Rec_Type;
      l_freight_charge_tbl ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
      l_tax_detail_tbl ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
      l_Price_Attr_Tbl ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
      l_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
      l_Price_Adj_Attr_Tbl ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
      l_qte_line_dtl_tbl ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
      l_Line_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      lx_ln_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
      lx_qte_line_rec ASO_QUOTE_PUB.Qte_Line_Rec_Type;
      l_control_rec ASO_QUOTE_PUB.Control_Rec_Type  := p_control_rec; -- Code change for Quoting Usability Sun ER
      l_price_index_link_tbl ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type
                                                    := P_Price_Index_Link_Tbl;
      l_line_index_link_tbl ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type;
      l_qte_line_id NUMBER;
      l_index NUMBER;
      l_index_2 NUMBER;
      l_service_ref_line_id NUMBER;
      l_config_control_rec ASO_CFG_INT.Control_Rec_Type
                                            := ASO_CFG_INT.G_MISS_Control_Rec;
      l_old_config_header_id NUMBER;
      l_old_config_revision_num NUMBER;
      l_config_hdr_id NUMBER;
      l_config_rev_nbr NUMBER;
      LX_PRICE_ADJ_RLTSHIP_ID NUMBER;
      LX_LINE_RELATIONSHIP_ID NUMBER;
      X_hd_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      X_Sales_Credit_Tbl ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      X_Quote_Party_Tbl ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_hd_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      l_quote_party_tbl ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_quote_party_rec ASO_QUOTE_PUB.Quote_Party_rec_Type;
      l_sales_credit_tbl ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      l_sales_credit_rec ASO_QUOTE_PUB.Sales_Credit_rec_Type;
      l_api_version CONSTANT NUMBER := 1.0;
      l_api_name CONSTANT VARCHAR2 ( 30 ) := 'Copy_Line_Rows';
      l_service_item_flag VARCHAR2 ( 1 );
      l_serviceable_product_flag VARCHAR2 ( 1 );
      l_return_status VARCHAR2 ( 1 );
      l_api_version_number CONSTANT NUMBER := 1.0;
      G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
      G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
      l_ship_id NUMBER;
      l_orig_item_id_tbl CZ_API_PUB.number_tbl_type;
      l_new_item_id_tbl CZ_API_PUB.number_tbl_type;
      -- hyang: for bug 2692785
      lx_status                     VARCHAR2(1);

      l_dup_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;

  --- New Code added for Copy Quote Line Functionality

      CURSOR C_Validate_Quote_Line (
          x_qte_header_id NUMBER,
          x_qte_line_id NUMBER
       ) IS
         SELECT 'X'
         FROM   ASO_QUOTE_LINES_ALL
         WHERE  quote_header_id = x_qte_header_id
         AND quote_line_id = x_qte_line_id;

      CURSOR c_line_relation_from_line_id (
          x_quote_line_id NUMBER
       ) IS
         SELECT LINE_RELATIONSHIP_ID, CREATION_DATE, CREATED_BY
              , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
              , REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID
              , PROGRAM_UPDATE_DATE, QUOTE_LINE_ID, RELATED_QUOTE_LINE_ID
              , RELATIONSHIP_TYPE_CODE, RECIPROCAL_FLAG, OBJECT_VERSION_NUMBER
         FROM   ASO_LINE_RELATIONSHIPS
         WHERE  relationship_type_code <> 'SERVICE'
	    CONNECT BY PRIOR related_quote_line_id = quote_line_id
         START WITH quote_line_id = x_quote_line_id;

      CURSOR c_price_adj_rel_from_line_id (
            x_quote_line_id NUMBER
       ) IS
         SELECT apr.ADJ_RELATIONSHIP_ID, apr.CREATION_DATE, apr.CREATED_BY
              , apr.LAST_UPDATE_DATE, apr.LAST_UPDATED_BY
              , apr.LAST_UPDATE_LOGIN, apr.PROGRAM_APPLICATION_ID
              , apr.PROGRAM_ID, apr.PROGRAM_UPDATE_DATE, apr.REQUEST_ID
              , apr.QUOTE_LINE_ID, apr.PRICE_ADJUSTMENT_ID
              , apr.RLTD_PRICE_ADJ_ID
		    , apr.OBJECT_VERSION_NUMBER
         FROM   ASO_PRICE_ADJ_RELATIONSHIPS apr
		    , ASO_PRICE_ADJUSTMENTS apa
         WHERE  apr.price_adjustment_id = apa.price_adjustment_id
         AND    apr.quote_line_id = x_quote_line_id
         AND    apa.quote_line_id = x_quote_line_id
         AND    apa.modifier_line_type_code <> 'PRG';

         l_val varchar2(1);
         l_appl_param_rec   CZ_API_PUB.appl_param_rec_type;
         l_last_update_date   DATE;
         l_line_number        NUMBER;


    Cursor C_Get_quote(c_QUOTE_HEADER_ID Number) IS
    Select
        LAST_UPDATE_DATE
    From  ASO_QUOTE_HEADERS_ALL
    Where QUOTE_HEADER_ID = c_QUOTE_HEADER_ID;

    Cursor Get_Max_Line_Number ( c_QUOTE_HEADER_ID Number) IS
    Select Max(Line_number)
    From ASO_QUOTE_LINES_ALL
    WHERE quote_header_id = c_QUOTE_HEADER_ID;

    x_qte_header_rec              aso_quote_pub.qte_header_rec_type;
    x_qte_line_tbl                aso_quote_pub.qte_line_tbl_type;
    x_qte_line_dtl_tbl            aso_quote_pub.qte_line_dtl_tbl_type;
    x_hd_price_attributes_tbl     aso_quote_pub.price_attributes_tbl_type;
    x_hd_payment_tbl              aso_quote_pub.payment_tbl_type;
    x_hd_shipment_tbl             aso_quote_pub.shipment_tbl_type;
    x_hd_freight_charge_tbl       aso_quote_pub.freight_charge_tbl_type;
    x_hd_tax_detail_tbl           aso_quote_pub.tax_detail_tbl_type;
    x_line_attr_ext_tbl           aso_quote_pub.line_attribs_ext_tbl_type;
    x_line_rltship_tbl            aso_quote_pub.line_rltship_tbl_type;
    x_price_adjustment_tbl        aso_quote_pub.price_adj_tbl_type;
    x_price_adj_attr_tbl          aso_quote_pub.price_adj_attr_tbl_type;
    x_price_adj_rltship_tbl       aso_quote_pub.price_adj_rltship_tbl_type;
    x_ln_price_attributes_tbl     aso_quote_pub.price_attributes_tbl_type;
    x_ln_payment_tbl              aso_quote_pub.payment_tbl_type;
    x_ln_shipment_tbl             aso_quote_pub.shipment_tbl_type;
    x_ln_freight_charge_tbl       aso_quote_pub.freight_charge_tbl_type;
    x_ln_tax_detail_tbl           aso_quote_pub.tax_detail_tbl_type;
    l_Qte_Header_Rec              ASO_QUOTE_PUB.Qte_Header_Rec_Type :=  ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec;

      l_quote_party_tbl_out      ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_sales_credit_tbl_out     ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      l_tax_detail_tbl_out       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
      l_freight_charge_tbl_out   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
      l_shipment_tbl_out         ASO_QUOTE_PUB.Shipment_Tbl_Type;
      l_payment_tbl_out          ASO_QUOTE_PUB.Payment_Tbl_Type;
      l_Price_Adj_Attr_Tbl_out   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
      l_Price_Attr_Tbl_out       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
      l_qte_line_dtl_tbl_out     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
      l_Line_Attr_Ext_Tbl_out    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      l_ato_model                VARCHAR2(1) := FND_API.G_FALSE;

      /* Code change for Quoting Usability Sun ER Start */
      CURSOR c_header_org IS
      SELECT org_id FROM aso_quote_headers_all
      WHERE quote_header_id = P_Qte_Header_Id;

      l_header_org_id        NUMBER;

      l_copy_flag            VARCHAR2(1) := 'T';
      l_def_control_rec      ASO_DEFAULTING_INT.Control_Rec_Type  := ASO_DEFAULTING_INT.G_MISS_CONTROL_REC;
      l_db_object_name       VARCHAR2(30);
      l_payment_rec          ASO_QUOTE_PUB.Payment_Rec_Type       := ASO_QUOTE_PUB.G_MISS_Payment_REC;
      lx_hd_shipment_rec     ASO_QUOTE_PUB.Shipment_Rec_Type;
      lx_hd_payment_rec      ASO_QUOTE_PUB.Payment_Rec_Type;
      lx_hd_tax_detail_rec   ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
      lx_hd_misc_rec         ASO_DEFAULTING_INT.Header_Misc_Rec_Type;
      lx_ln_misc_rec         ASO_DEFAULTING_INT.Line_Misc_Rec_Type;
      lx_ln_shipment_rec     ASO_QUOTE_PUB.Shipment_Rec_Type;
      lx_ln_payment_rec      ASO_QUOTE_PUB.Payment_Rec_Type;
      lx_ln_tax_detail_rec   ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
      lx_changed_flag        VARCHAR2(1);
      l_def_Qte_Line_Rec     ASO_QUOTE_PUB.Qte_Line_Rec_Type    := ASO_QUOTE_PUB.G_MISS_qte_line_REC;

      l_check_service_rec ASO_SERVICE_CONTRACTS_INT.CHECK_SERVICE_REC_TYPE;

      x_available_yn   Varchar2(1);

      cursor c_service_ref_quote (P_Quote_line_id number) is
      select service_ref_line_id
      from aso_quote_line_Details
      where quote_line_id=  P_Quote_line_id
      and service_ref_type_code ='QUOTE';

      l_return_value  Varchar2(1);

      CURSOR C_AGREEMENT(P_AGREEMENT_ID IN NUMBER,P_INVOICE_TO_CUSTOMER_ID IN NUMBER) IS
      SELECT 'x'
      FROM OE_AGREEMENTS_VL
      WHERE AGREEMENT_ID = P_AGREEMENT_ID
      AND  INVOICE_TO_CUSTOMER_ID = P_INVOICE_TO_CUSTOMER_ID;

      l_var varchar2(1);

      /* Code change for Quoting Usability Sun ER End */

      -- Start : Code change done for Bug 16928074

      CURSOR C_NEW_QUOTE_LINES IS
      SELECT quote_line_id,inventory_item_id
      FROM aso_quote_lines_all
      WHERE quote_header_id = P_new_qte_header_id
      ORDER BY inventory_item_id,quote_line_id; -- added for Bug 19210425

      -- ln_qte_line_tbl ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

      -- End : Code change done for Bug 16928074

      -- Start : Code change done for Bug 19470596
      CURSOR C_OLD_QUOTE_LINES IS
      SELECT quote_line_id,inventory_item_id
      FROM aso_quote_lines_all
      WHERE quote_header_id = P_Qte_Header_Id
      ORDER BY inventory_item_id,quote_line_id;

      ln_old_line_tbl ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
      ln_new_line_tbl ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
      ln_qte_line_rec ASO_Quote_Pub.qte_line_rec_type := ASO_Quote_Pub.G_MISS_qte_line_Rec;
      -- End : Code change done for Bug 19470596

      -- Start : Code change done for Bug 20332841
      ln_old_changed_line_tbl ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
      l_diff Number := 0;
      -- End : Code change done for Bug 20332841

   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT COPY_LINE_ROWS_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
                 l_api_version_number
              , p_api_version_number
              , l_api_name
              , G_PKG_NAME
              ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean ( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ) THEN
         FND_MESSAGE.Set_Name ('ASO' , 'Copy Quote Lines API: Start' );
         FND_MSG_PUB.ADD;
      END IF;

      --  Initialize API return status to success
      x_return_status            := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ('Copy_Rows - Header and Lines' , 1, 'N' );
	 END IF;

    -- hyang: for bug 2692785
  IF  P_Qte_Header_Rec.batch_price_flag <> FND_API.G_FALSE THEN

    ASO_CONC_REQ_INT.Lock_Exists(
      p_quote_header_id => p_qte_header_id,
      x_status          => lx_status);

    IF (lx_status = FND_API.G_TRUE) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;


      l_qte_line_tbl             :=
                       ASO_UTILITY_PVT.Query_Qte_Line_Rows ( p_qte_header_id );

      FOR i IN 1 .. l_qte_line_tbl.COUNT LOOP
         l_line_index_link_tbl ( l_qte_line_tbl ( i ).quote_line_id ) :=
                                                           FND_API.G_MISS_NUM;
      END LOOP;

  --- New Code added for Copy Quote Line Functionality
IF ( P_Qte_Line_Id IS NOT NULL ) AND (P_Qte_Line_Id <> FND_API.G_MISS_NUM) THEN

  -- Validating if the quote_line_id belongs to the qte_header_id

      OPEN C_Validate_Quote_Line ( P_Qte_Header_Id, P_Qte_Line_Id);
      FETCH C_Validate_Quote_Line INTO l_val;


      IF C_Validate_Quote_Line%NOTFOUND THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
            FND_MESSAGE.Set_Token ('COLUMN' , 'ORIGINAL_QUOTE_ID', FALSE );
            FND_MESSAGE.Set_Token ( 'VALUE' , TO_CHAR ( P_Qte_Line_Id ) , FALSE );
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE C_Validate_Quote_Line;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      CLOSE C_Validate_Quote_Line;

   -- Validate for the last update of the quote


     Open C_Get_quote( P_Qte_Header_Id);

      Fetch C_Get_quote into l_LAST_UPDATE_DATE;
      If ( C_Get_quote%NOTFOUND) Then

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_UPDATE_TARGET');
            FND_MESSAGE.Set_Token ('INFO', 'quote', FALSE);
            FND_MSG_PUB.Add;
        END IF;
      raise FND_API.G_EXC_ERROR;
      END IF;
      Close C_Get_quote;

      If (l_last_update_date is NULL or
       l_last_update_date = FND_API.G_MISS_Date ) Then
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
           FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
           FND_MSG_PUB.ADD;
       END IF;
       raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If (l_last_update_date <> p_qte_header_rec.last_update_date) Then
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('ASO', 'ASO_API_RECORD_CHANGED');
           FND_MESSAGE.Set_Token('INFO', 'quote', FALSE);
           FND_MSG_PUB.ADD;
       END IF;
       raise FND_API.G_EXC_ERROR;
      End if;

  -- end validation for last update data



      l_qte_line_tbl             := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL ;
      l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row ( P_Qte_Line_Id );
      l_qte_line_tbl(1) := l_qte_line_rec;



    -- Getting the quote line detail record
      l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows ( P_Qte_Line_Id );


 IF l_qte_line_rec.line_category_code = 'RETURN' THEN
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.ADD ('l_qte_line_dtl_tbl.count' , 1, 'N' );
  END IF;

  IF l_qte_line_dtl_tbl.count > 0 THEN

     IF ( l_qte_line_dtl_tbl(1).RETURN_REF_TYPE = 'SALES ORDER' AND
          l_qte_line_dtl_tbl(1).RETURN_REF_LINE_ID IS NOT NULL AND
          l_qte_line_dtl_tbl(1).INSTANCE_ID IS NOT NULL )
     OR ( l_qte_line_dtl_tbl(1).REF_TYPE_CODE = 'TOP_MODEL' ) THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;

	 /* Code change for Quoting Usability Sun ER Start */
	 If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then
	    l_copy_flag:='F';
         End If;
	 /* Code change for Quoting Usability Sun ER End */

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ('Install Base Check Failed' , 1, 'N' );
	 END IF;

	 IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_RECONFIG_ITM_ERR' );
            FND_MSG_PUB.ADD;
         END IF;

     END IF;

  END IF;

 END IF;


/*
 -- Validating if the  item is a container item
     l_appl_param_rec.calling_application_id := nvl(FND_PROFILE.value('JTF_PROFILE_DEFAULT_APPLICATION'),697);

        cz_network_api_pub.is_container(p_api_version  => 1.0
                                       ,p_inventory_item_id  => l_qte_line_rec.inventory_item_id
                                       ,p_organization_id   => l_qte_line_rec.organization_id
                                       ,p_appl_param_rec => l_appl_param_rec
                                       ,x_return_value       => l_return_value
                                       ,x_return_status      => l_return_status
                                       ,x_msg_count          => x_msg_count
                                       ,x_msg_data           => x_msg_data  );

           IF ( l_return_status = FND_API.G_RET_STS_SUCCESS  ) THEN

              IF l_return_value = 'Y' THEN
               x_return_status            := FND_API.G_RET_STS_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                FND_MESSAGE.Set_Name ('ASO' , 'ASO_RECONFIG_ITM_ERR' );
                FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
              END IF;

           ELSE
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_CONFIG_COPY' , TRUE );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

           END IF;
*/


   IF l_qte_line_rec.item_type_code = 'CFG' then
    x_return_status            := FND_API.G_RET_STS_ERROR;

    /* Code change for Quoting Usability Sun ER Start */
    If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then
       l_copy_flag:='F';

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.ADD ('Copy_Line_Rows : ASO_CFG_ITM_ERR error' , 1, 'N' );
       END IF;
    End If;
    /* Code change for Quoting Usability Sun ER End */

    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
     FND_MESSAGE.Set_Name ('ASO' , 'ASO_CFG_ITM_ERR' );
     FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.G_EXC_ERROR;

  END IF;


  -- Check to see if it is a servicable product

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.ADD ( 'service item flag = ' || l_qte_line_rec.service_item_flag , 1 , 'N' );
		  END IF;
            IF      l_qte_line_rec.service_item_flag = 'Y'  THEN

             x_return_status            := FND_API.G_RET_STS_ERROR;

	     /* Code change for Quoting Usability Sun ER Start */
             If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then
                l_copy_flag:='F';

		IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.ADD ('Copy_Line_Rows : ASO_SRV_ITM_ERR error' , 1, 'N' );
	        END IF;
             End If;
             /* Code change for Quoting Usability Sun ER End */

             IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
              FND_MESSAGE.Set_Name ('ASO' , 'ASO_SRV_ITM_ERR' );
              FND_MSG_PUB.ADD;
             END IF;

             RAISE FND_API.G_EXC_ERROR;

           END IF;

        -- Set the variables to null as they are re-used later on
           l_service_item_flag := NULL;
           l_serviceable_product_flag := NULL;

END IF;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.ADD ('End Of New Code ' , 1, 'N' );
END IF;

-- End of New Code added

-- Start : Code change for Quoting Usability Sun ER
If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE And
   l_control_rec.defaulting_fwk_flag = 'Y' Then
   OPEN c_header_org;
   FETCH c_header_org INTO l_header_org_id;
   CLOSE c_header_org;
End If;
-- End : Code change for Quoting Usability Sun ER

      FOR i IN 1 .. l_qte_line_tbl.COUNT LOOP

	    l_copy_flag:='T';  -- added for Bug 23242949

         IF l_qte_line_tbl ( i ).uom_code = 'ENR' THEN
            x_return_status            := FND_API.G_RET_STS_ERROR;

	    /* Code change for Quoting Usability Sun ER Start */
            If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then
               l_copy_flag:='F';

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.ADD ('Copy_Line_Rows : ASO_CANNOT_COPY_EDU error' , 1, 'N' );
	       END IF;
            End If;
            /* Code change for Quoting Usability Sun ER End */

	    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_CANNOT_COPY_EDU' );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_qte_line_tbl ( i ).quote_header_id := P_New_Qte_Header_Id;
         l_qte_line_id              := l_qte_line_tbl ( i ).quote_line_id;

	/* -- Start : Code change done for Bug 16928074
	 ln_qte_line_tbl(i).quote_line_id := l_qte_line_tbl (i).quote_line_id;
	 ln_qte_line_tbl(i).inventory_item_id := l_qte_line_tbl (i).inventory_item_id;
	*/ -- End : Code change done for Bug 16928074

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD (   'qte line id = ' || l_qte_line_id, 1, 'N' );
         aso_debug_pub.ADD (   'i = ' || i, 1, 'N' );
         aso_debug_pub.ADD ( 'item_type_code = ' || l_qte_line_tbl ( i ).item_type_code , 1 , 'N' );
	    END IF;

         IF l_line_index_link_tbl ( l_qte_line_id ) = FND_API.G_MISS_NUM THEN

            l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows ( l_qte_line_id );

	    /* Code change for Quoting Usability Sun ER Start */
            -- Validation check for Trade in product
	    If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then
               IF (l_qte_line_tbl(i).item_type_code = 'STD' ) and ( l_qte_line_tbl(i).line_category_code = 'RETURN' )THEN
	           IF (l_qte_line_dtl_tbl(1).INSTANCE_ID IS NOT NULL) Then
                       l_copy_flag:='F';
	               IF aso_debug_pub.g_debug_flag = 'Y' THEN
		          aso_debug_pub.ADD ('Copy_Line_Rows : Trade in from install Base Check Failed' , 1, 'N' );
	               END IF;
	           End IF;
               End IF;

	       l_appl_param_rec.calling_application_id := 697;

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Copy_Line_Rows:Call TO CZ_NETWORK_API_PUB.Is_Container ');
               END IF;

               -- Validation check for Container Model
	       cz_network_api_pub.is_container(p_api_version  => 1.0
                                        ,p_inventory_item_id  => l_qte_line_tbl( i ).inventory_item_id
                                        ,p_organization_id    => l_qte_line_tbl( i ).organization_id
                                        ,p_appl_param_rec     => l_appl_param_rec
                                        ,x_return_value       => l_return_value
                                        ,x_return_status      => l_return_status
                                        ,x_msg_count          => x_msg_count
                                        ,x_msg_data           => x_msg_data );

               IF ( l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                    IF l_return_value = 'Y' THEN
                       l_copy_flag := 'F';
		       IF aso_debug_pub.g_debug_flag = 'Y' THEN
		          aso_debug_pub.ADD ('Copy_Line_Rows : Container Model Check Failed' , 1, 'N' );
	               END IF;
                    END IF;
               ELSE
                    x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
                    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                       FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                       FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_CONFIG_COPY' , TRUE );
                       FND_MSG_PUB.ADD;
                    END IF;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
	    End If;
            /* Code change for Quoting Usability Sun ER End */

  	   IF l_qte_line_tbl ( i ).item_type_code = 'MDL'
	      And (l_copy_flag = 'T') THEN -- Code change for Quoting Usability Sun ER

               IF l_qte_line_dtl_tbl.COUNT > 0 THEN

                  IF      l_qte_line_dtl_tbl ( 1 ).config_header_id IS NOT NULL
                      AND l_qte_line_dtl_tbl ( 1 ).config_revision_num IS NOT NULL THEN

                     l_config_control_rec.new_config_flag := FND_API.G_TRUE;

                     -- set the flag for ato model
                     IF (l_qte_line_dtl_tbl(1).ato_line_id is not null and l_qte_line_dtl_tbl(1).ato_line_id <> fnd_api.g_miss_num) then
                        l_ato_model := fnd_api.g_true;
				 end if;


			     IF aso_debug_pub.g_debug_flag = 'Y' THEN
				aso_debug_pub.ADD ( 'Before Calling ASO_CGF_INT.Copy Configuration' , 1 , 'N' );
				END IF;

				 ASO_CFG_INT.Copy_Configuration (
                         P_Api_version_NUmber =>         1.0
                      , P_config_header_id =>            l_qte_line_dtl_tbl ( 1 ).config_header_id
                      , p_config_revision_num =>         l_qte_line_dtl_tbl ( 1 ).config_revision_num
                      , p_copy_mode =>                   CZ_API_PUB.G_NEW_HEADER_COPY_MODE
                      , x_config_header_id =>            l_config_hdr_id
                      , x_config_revision_num =>         l_config_rev_nbr
                      , x_orig_item_id_tbl =>            l_orig_item_id_tbl
                      , x_new_item_id_tbl =>             l_new_item_id_tbl
                      , x_return_status =>               l_return_status
                      , x_msg_count =>                   x_msg_count
                      , x_msg_data =>                    x_msg_data
                      , p_autonomous_flag =>             FND_API.G_FALSE
				  );

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
				aso_debug_pub.ADD ( 'After Calling ASO_CGF_INT.Copy Configuration' , 1 , 'N' );
				END IF;

				 IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        l_old_config_header_id     :=
                                    l_qte_line_dtl_tbl ( 1 ).config_header_id;
                        l_old_config_revision_num  :=
                                 l_qte_line_dtl_tbl ( 1 ).config_revision_num;
                        l_qte_line_dtl_tbl ( 1 ).config_header_id :=
                                                              l_config_hdr_id;
                        l_qte_line_dtl_tbl ( 1 ).config_revision_num :=
                                                             l_config_rev_nbr;
                     ELSE
                        x_return_status            := FND_API.G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

                  END IF; -- config_header_id

               END IF; -- line_dtl_tbl.count

            END IF; -- 'MDL'

           l_serviceable_product_flag := l_qte_line_tbl ( i ).SERVICEABLE_PRODUCT_FLAG;
           l_service_item_flag  := l_qte_line_tbl ( i ).service_item_flag;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
		 aso_debug_pub.ADD ( 'service item flag = ' || l_service_item_flag , 1 , 'N' );
           aso_debug_pub.ADD ( 'serviceable_product_flag = ' || l_serviceable_product_flag , 1 , 'N' );
		 END IF;

            IF      l_service_item_flag = 'Y'
                AND (l_qte_line_dtl_tbl ( 1 ).service_ref_type_code IS NULL OR
			     l_qte_line_dtl_tbl ( 1 ).service_ref_type_code <> 'QUOTE') THEN
               l_service_item_flag        := 'N';
            END IF;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.ADD ( 'service item flag 2= ' || l_service_item_flag , 1 , 'N' );
		  END IF;

            /* Code change for Quoting Usability Sun ER Start  */
	    If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then

		If l_service_item_flag = 'Y' Then

	            -- Validation check for service reference - Install Base and Pending Order
		    If (l_qte_line_dtl_tbl ( 1 ).service_ref_type_code = 'CUSTOMER_PRODUCT') Or
		       (l_qte_line_dtl_tbl ( 1 ).service_ref_type_code = 'PENDING_ORDER') Then
		        l_copy_flag := 'F';
			IF aso_debug_pub.g_debug_flag = 'Y' THEN
		           aso_debug_pub.ADD ('Copy_Line_Rows : service_ref_type_code = '||l_qte_line_dtl_tbl ( 1 ).service_ref_type_code , 1, 'N' );
	                END IF;

		    -- Validation check for service reference - Product Catalog
		    ElsIf l_qte_line_dtl_tbl ( 1 ).service_ref_type_code = 'PRODUCT_CATALOG' Then

		        l_check_service_rec.product_item_id := l_qte_line_dtl_tbl ( 1 ).SERVICE_REF_LINE_ID;
	                l_check_service_rec.customer_id     := P_Qte_Header_Rec.CUST_ACCOUNT_ID;
                        l_check_service_rec.service_item_id := l_qte_line_tbl ( i ).INVENTORY_ITEM_ID;

		        IF aso_debug_pub.g_debug_flag = 'Y' THEN
		           aso_debug_pub.ADD( 'Copy_Line_Rows:Before calling ASO_SERVICE_CONTRACTS_INT.Is_Service_Available for IB', 1 , 'N' );
		        END IF;

                        ASO_SERVICE_CONTRACTS_INT.is_service_available (
       		  	     P_Api_Version_Number	=> 1.0 ,
       			     P_init_msg_list		=> FND_API.G_FALSE ,
		    	     X_msg_Count     	=> x_msg_count ,
       			     X_msg_Data		=> x_msg_data	 ,
       			     X_Return_Status		=> x_return_status  ,
			     p_check_service_rec 	=> l_check_service_rec,
			     X_Available_YN	    	=> x_Available_YN );

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
		           aso_debug_pub.ADD( 'Copy_Line_Rows:After calling ASO_SERVICE_CONTRACTS_INT.Is_Service_Available for IB', 1 , 'N' );
		        END IF;

                        If nvl(x_Available_YN, 'N') = 'N' Then
			   l_copy_flag := 'F';
		           IF aso_debug_pub.g_debug_flag = 'Y' THEN
			      aso_debug_pub.add('Copy_Line_Rows: PC Service Not Available');
		           END IF;
                        End If;

		    -- Validation check for service reference - Quote
		    ElsIf l_qte_line_dtl_tbl ( 1 ).service_ref_type_code = 'QUOTE' Then

		       open c_service_ref_quote(l_qte_line_id);
	               fetch c_service_ref_quote into l_check_service_rec.product_item_id;
	               close c_service_ref_quote;

	               l_check_service_rec.customer_id     := P_Qte_Header_Rec.CUST_ACCOUNT_ID;
                       l_check_service_rec.service_item_id := l_qte_line_tbl ( i ).INVENTORY_ITEM_ID;

		       IF aso_debug_pub.g_debug_flag = 'Y' THEN
		          aso_debug_pub.ADD( 'Copy_Line_Rows:Before calling ASO_SERVICE_CONTRACTS_INT.Is_Service_Available for Quote', 1 , 'N' );
		       END IF;

                       ASO_SERVICE_CONTRACTS_INT.is_service_available (
       		   	        P_Api_Version_Number	=> 1.0 ,
       			        P_init_msg_list	        => FND_API.G_FALSE ,
		    	        X_msg_Count     	=> x_msg_count ,
       			        X_msg_Data		=> x_msg_data	 ,
       			        X_Return_Status 	=> x_return_status  ,
			        p_check_service_rec 	=> l_check_service_rec,
			        X_Available_YN	    	=> x_Available_YN );

                       IF aso_debug_pub.g_debug_flag = 'Y' THEN
		          aso_debug_pub.ADD( 'Copy_Line_Rows:After calling ASO_SERVICE_CONTRACTS_INT.Is_Service_Available for Quote', 1 , 'N' );
		       END IF;

                       If nvl(x_Available_YN, 'N') = 'N' Then
		          l_copy_flag := 'F';
		          IF aso_debug_pub.g_debug_flag = 'Y' THEN
			     aso_debug_pub.add('Copy_Line_Rows: Quote Service Not Available');
		          END IF;
                       End If;

	 	    End If;
                End If;
            END IF;
            /* Code change for Quoting Usability Sun ER End */

            IF      l_qte_line_tbl ( i ).item_type_code <> 'CFG'
                AND l_qte_line_tbl ( i ).item_type_code <> 'OPT'
                AND l_service_item_flag <> 'Y'
		AND (l_copy_flag = 'T') THEN  -- Code change for Quoting Usability Sun ER

               l_line_attr_Ext_Tbl := ASO_UTILITY_PVT.Query_Line_Attribs_Ext_Rows ( l_qte_line_id );

               IF ( P_Qte_Line_Id IS NOT NULL ) AND (P_Qte_Line_Id <> FND_API.G_MISS_NUM) THEN

                  l_price_adj_tbl := ASO_UTILITY_PVT.Query_Price_Adj_NonPRG_Rows(p_qte_header_id, l_qte_line_id);
               ELSE
                  l_price_adj_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Rows(p_qte_header_id, l_qte_line_id);
               END IF;

			l_dup_Price_Adj_Tbl := l_price_adj_tbl;

               l_price_adj_attr_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Attr_Rows( p_price_adj_tbl => l_price_adj_tbl );

               l_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows(p_qte_header_id, l_qte_line_id);

               l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows(p_qte_header_id, L_QTE_LINE_ID);

               --  l_payment_tbl := ASO_QUOTE_PUB.g_miss_payment_tbl;

	       l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(p_qte_header_id, L_QTE_LINE_ID);  -- Added for Bug 18497111

               l_shipment_tbl(1).ORDER_LINE_ID := Null; -- code change done for Bug 20501846

               /* Code change for Quoting Usability Sun ER Start */
	       If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_TRUE Then

	          IF aso_debug_pub.g_debug_flag = 'Y' THEN
                     aso_debug_pub.add('Copy_Line_Rows - P_Copy_Quote_Control_Rec.Copy_To_Same_Customer is True ', 1, 'Y');
                  END IF ;

                  -- l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(p_qte_header_id,l_qte_line_id);

		  If P_Copy_Quote_Control_Rec.Copy_Line_Shipping = FND_API.G_FALSE Then
		     l_shipment_tbl(1).SHIP_TO_CUST_ACCOUNT_ID := Null;
	             l_shipment_tbl(1).SHIP_TO_CUST_PARTY_ID := Null;
	             l_shipment_tbl(1).SHIP_TO_PARTY_ID := Null;
	             l_shipment_tbl(1).SHIP_TO_PARTY_SITE_ID := Null;
	             l_shipment_tbl(1).SHIP_TO_PARTY_NAME := Null;
	             l_shipment_tbl(1).SHIP_TO_CONTACT_FIRST_NAME := Null;
	             l_shipment_tbl(1).SHIP_TO_CONTACT_MIDDLE_NAME := Null;
	             l_shipment_tbl(1).SHIP_TO_CONTACT_LAST_NAME := Null;
	             l_shipment_tbl(1).SHIP_TO_ADDRESS1 := Null;
	             l_shipment_tbl(1).SHIP_TO_ADDRESS2 := Null;
	             l_shipment_tbl(1).SHIP_TO_ADDRESS3 := Null;
	             l_shipment_tbl(1).SHIP_TO_ADDRESS4 := Null;
	             l_shipment_tbl(1).SHIP_TO_COUNTRY_CODE := Null;
	             l_shipment_tbl(1).SHIP_TO_COUNTRY := Null;
	             l_shipment_tbl(1).SHIP_TO_CITY := Null;
	             l_shipment_tbl(1).SHIP_TO_POSTAL_CODE := Null;
	             l_shipment_tbl(1).SHIP_TO_STATE := Null;
	             l_shipment_tbl(1).SHIP_TO_PROVINCE := Null;
	             l_shipment_tbl(1).SHIP_TO_COUNTY := Null;
	             l_shipment_tbl(1).SHIP_METHOD_CODE := Null;
                     l_shipment_tbl(1).FREIGHT_TERMS_CODE := Null;
	             l_shipment_tbl(1).FOB_CODE := Null;
	             l_shipment_tbl(1).DEMAND_CLASS_CODE := Null;
	             l_shipment_tbl(1).SHIP_FROM_ORG_ID := Null;
	             l_shipment_tbl(1).REQUEST_DATE := Null;
	             l_shipment_tbl(1).SHIPMENT_PRIORITY_CODE := Null;
	             l_shipment_tbl(1).SHIPPING_INSTRUCTIONS := Null;
	             l_shipment_tbl(1).PACKING_INSTRUCTIONS := Null;
		  End If;

		  If P_Copy_Quote_Control_Rec.Copy_Line_Billing = FND_API.G_FALSE Then
	             l_qte_line_tbl ( i ).INVOICE_TO_PARTY_SITE_ID := Null;
		     l_qte_line_tbl ( i ).INVOICE_TO_PARTY_ID := Null;
		     l_qte_line_tbl ( i ).INVOICE_TO_CUST_ACCOUNT_ID := Null;
		     l_qte_line_tbl ( i ).INVOICE_TO_CUST_PARTY_ID := Null;
	          End If;

	          If P_Copy_Quote_Control_Rec.Copy_Line_End_Customer = FND_API.G_FALSE Then
	             l_qte_line_tbl ( i ).END_CUSTOMER_PARTY_ID := Null;
		     l_qte_line_tbl ( i ).END_CUSTOMER_PARTY_SITE_ID := Null;
		     l_qte_line_tbl ( i ).END_CUSTOMER_CUST_ACCOUNT_ID := Null;
		     l_qte_line_tbl ( i ).END_CUSTOMER_CUST_PARTY_ID := Null;
	          End If;

		  If P_Copy_Quote_Control_Rec.Copy_Line_Sales_Credit = FND_API.G_TRUE Then
	             l_sales_credit_tbl := ASO_UTILITY_PVT.Query_Sales_Credit_Row(p_qte_header_id,l_qte_line_id);
	          End If;

               ElsIf P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then

	             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Copy_Line_Rows - P_Copy_Quote_Control_Rec.Copy_To_Same_Customer is False ', 1, 'Y');
                     END IF ;

		     l_qte_line_tbl ( i ).INVOICE_TO_PARTY_SITE_ID := Null;
                     l_qte_line_tbl ( i ).INVOICE_TO_PARTY_ID := Null;
	             l_qte_line_tbl ( i ).INVOICE_TO_CUST_ACCOUNT_ID := Null;
	             l_qte_line_tbl ( i ).INVOICE_TO_CUST_PARTY_ID := Null;

	             l_qte_line_tbl ( i ).END_CUSTOMER_PARTY_ID := Null;
	             l_qte_line_tbl ( i ).END_CUSTOMER_PARTY_SITE_ID := Null;
	             l_qte_line_tbl ( i ).END_CUSTOMER_CUST_ACCOUNT_ID := Null;
	             l_qte_line_tbl ( i ).END_CUSTOMER_CUST_PARTY_ID := Null;

	             l_qte_line_tbl( i ).PRICE_LIST_ID := Null;
	             l_qte_line_tbl( i ).CURRENCY_CODE := Null;

                     /*      -- ER 12879412
                     l_qte_line_tbl( i ).PRODUCT_FISC_CLASSIFICATION := Null;
                     l_qte_line_tbl( i ).TRX_BUSINESS_CATEGORY := Null;
                      */

		     IF (l_qte_line_tbl(i).AGREEMENT_ID IS NOT NULL AND
                         l_qte_line_tbl(i).AGREEMENT_ID <> FND_API.G_MISS_NUM) THEN

		         IF aso_debug_pub.g_debug_flag = 'Y' THEN
                            aso_debug_pub.add('Copy_Line_Rows - l_qte_line_tbl('||i||').AGREEMENT_ID : '||l_qte_line_tbl(i).AGREEMENT_ID, 1, 'Y');
		            aso_debug_pub.add('Copy_Line_Rows - l_qte_line_tbl('||i||').INVOICE_TO_CUST_ACCOUNT_ID : '||l_qte_line_tbl(i).INVOICE_TO_CUST_ACCOUNT_ID, 1, 'Y');
                         END IF ;

	                 Open C_AGREEMENT(l_qte_line_tbl(i).AGREEMENT_ID,l_qte_line_tbl(i).INVOICE_TO_CUST_ACCOUNT_ID);
	                 Fetch C_AGREEMENT Into l_var;

	                 If C_AGREEMENT%Found Then
	                    l_qte_line_tbl(i).AGREEMENT_ID := Null;
	                 End If;

					 Close C_AGREEMENT; -- added as per Bug 22724427
	             End If;

                     IF (l_shipment_tbl.COUNT > 0) then
	                 l_shipment_tbl(1).SHIP_TO_CUST_ACCOUNT_ID := Null;
	                 l_shipment_tbl(1).SHIP_TO_CUST_PARTY_ID := Null;
	                 l_shipment_tbl(1).SHIP_TO_PARTY_ID := Null;
	                 l_shipment_tbl(1).SHIP_TO_PARTY_SITE_ID := Null;
	                 l_shipment_tbl(1).SHIP_TO_PARTY_NAME := Null;
	                 l_shipment_tbl(1).SHIP_TO_CONTACT_FIRST_NAME := Null;
	                 l_shipment_tbl(1).SHIP_TO_CONTACT_MIDDLE_NAME := Null;
	                 l_shipment_tbl(1).SHIP_TO_CONTACT_LAST_NAME := Null;
	                 l_shipment_tbl(1).SHIP_TO_ADDRESS1 := Null;
	                 l_shipment_tbl(1).SHIP_TO_ADDRESS2 := Null;
	                 l_shipment_tbl(1).SHIP_TO_ADDRESS3 := Null;
	                 l_shipment_tbl(1).SHIP_TO_ADDRESS4 := Null;
	                 l_shipment_tbl(1).SHIP_TO_COUNTRY_CODE := Null;
	                 l_shipment_tbl(1).SHIP_TO_COUNTRY := Null;
	                 l_shipment_tbl(1).SHIP_TO_CITY := Null;
	                 l_shipment_tbl(1).SHIP_TO_POSTAL_CODE := Null;
	                 l_shipment_tbl(1).SHIP_TO_STATE := Null;
	                 l_shipment_tbl(1).SHIP_TO_PROVINCE := Null;
	                 l_shipment_tbl(1).SHIP_TO_COUNTY := Null;

			 If P_Copy_Quote_Control_Rec.Copy_Line_Shipping = FND_API.G_FALSE Then
		            l_shipment_tbl(1).SHIP_METHOD_CODE := Null;
                            l_shipment_tbl(1).FREIGHT_TERMS_CODE := Null;
			    l_shipment_tbl(1).FOB_CODE := Null;
			    l_shipment_tbl(1).DEMAND_CLASS_CODE := Null;
			    l_shipment_tbl(1).SHIP_FROM_ORG_ID := Null;
			    l_shipment_tbl(1).REQUEST_DATE := Null;
			    l_shipment_tbl(1).SHIPMENT_PRIORITY_CODE := Null;
	                    l_shipment_tbl(1).SHIPPING_INSTRUCTIONS := Null;
	                    l_shipment_tbl(1).PACKING_INSTRUCTIONS := Null;
                         End If;
                     END IF;

	             IF (l_payment_tbl.COUNT > 0) then
	                 If l_payment_tbl(1).PAYMENT_TYPE_CODE In ('CHECK','CREDIT_CARD') Then
       		            If l_payment_tbl(1).PAYMENT_TYPE_CODE = 'CREDIT_CARD' Then
		               l_payment_tbl(1).CREDIT_CARD_CODE := Null;
		               l_payment_tbl(1).CREDIT_CARD_HOLDER_NAME := Null;
		               l_payment_tbl(1).CREDIT_CARD_EXPIRATION_DATE := Null;
		               l_payment_tbl(1).cvv2 := Null;
		            End If;
		            l_payment_tbl(1).PAYMENT_TYPE_CODE := NULL;
		            l_payment_tbl(1).PAYMENT_REF_NUMBER := Null;
                         End If;
	                 l_payment_tbl(1).CUST_PO_NUMBER := Null;
	                 l_payment_tbl(1).CUST_PO_LINE_NUMBER := Null;
	                 l_payment_tbl(1).PAYMENT_TERM_ID := Null;
	             END IF;

                     -- Line level defaulting for different customer

	             If l_control_rec.defaulting_fwk_flag = 'Y' Then

		        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('Copy_Line_Rows - l_header_org_id'||l_header_org_id, 1, 'Y');
		           aso_debug_pub.add('Copy_Line_Rows - before defaulting framework', 1, 'Y');
                           aso_debug_pub.add('Copy_Line_Rows - populate defaulting control record from the header control record', 1, 'Y');
                        END IF ;

		        l_def_Qte_Line_Rec := l_qte_line_tbl(i);
		        l_def_Qte_Line_Rec.org_id := l_header_org_id;

                        l_def_control_rec.Dependency_Flag       := FND_API.G_TRUE;
                        l_def_control_rec.Defaulting_Flag       := FND_API.G_TRUE;
                        l_def_control_rec.Application_Type_Code := 'QUOTING HTML';
                        l_def_control_rec.Defaulting_Flow_Code  := 'CREATE';
	                l_db_object_name                        := 'ASO_AK_QUOTE_LINE_V'; -- ASO_QUOTE_HEADERS_PVT.G_QUOTE_LINE_DB_NAME; commented for Bug 18942516

	                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('Copy_Line_Rows - Dependency_Flag:       '|| l_def_control_rec.Dependency_Flag, 1, 'Y');
                           aso_debug_pub.add('Copy_Line_Rows - Defaulting_Flag:       '|| l_def_control_rec.Defaulting_Flag, 1, 'Y');
                           aso_debug_pub.add('Copy_Line_Rows - Application_Type_Code: '|| l_def_control_rec.Application_Type_Code, 1, 'Y');
                           aso_debug_pub.add('Copy_Line_Rows - Defaulting_Flow_Code:  '|| l_def_control_rec.Defaulting_Flow_Code, 1, 'Y');
                        END IF ;

		        IF (l_shipment_tbl.COUNT > 0) then
		            l_shipment_rec := l_shipment_tbl(1);
                        END IF;

		        IF (l_payment_tbl.COUNT > 0) then
		            l_payment_rec := l_payment_tbl(1);
                        END IF;

		        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	                   aso_debug_pub.add('Copy_Line_Rows - before call to ASO_DEFAULTING_INT.Default_Entity', 1, 'Y');
                        END IF ;

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
                                                            x_msg_data              =>  x_msg_data );

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('Copy_Line_Rows: After call to ASO_DEFAULTING_INT.Default_Entity', 1, 'Y');
                           aso_debug_pub.add('Copy_Line_Rows: x_return_status: '|| x_return_status, 1, 'Y');
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

	                l_qte_line_tbl(i) := lx_qte_line_rec;

                        IF aso_quote_headers_pvt.Shipment_Null_Rec_Exists(lx_ln_shipment_rec, l_db_object_name) THEN
                           l_shipment_tbl(i) := lx_ln_shipment_rec;
                        END IF;

                        IF aso_quote_headers_pvt.Payment_Null_Rec_Exists(lx_ln_payment_rec, l_db_object_name) THEN
                           l_payment_tbl(i) := lx_ln_payment_rec;
                        END IF;

	             End If;     -- l_control_rec.defaulting_fwk_flag = 'Y'

	             If P_Copy_Quote_Control_Rec.Copy_Line_Shipping = FND_API.G_FALSE Then
		        l_shipment_tbl(1).SHIP_METHOD_CODE := Null;
                        l_shipment_tbl(1).FREIGHT_TERMS_CODE := Null;
			l_shipment_tbl(1).FOB_CODE := Null;
			l_shipment_tbl(1).DEMAND_CLASS_CODE := Null;
			l_shipment_tbl(1).SHIP_FROM_ORG_ID := Null;
			l_shipment_tbl(1).REQUEST_DATE := Null;
			l_shipment_tbl(1).SHIPMENT_PRIORITY_CODE := Null;
	                l_shipment_tbl(1).SHIPPING_INSTRUCTIONS := Null;
	                l_shipment_tbl(1).PACKING_INSTRUCTIONS := Null;
                     End If;

		     l_sales_credit_tbl := ASO_UTILITY_PVT.Query_Sales_Credit_Row(p_qte_header_id,l_qte_line_id);
               End If;      -- P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE

               If P_Copy_Quote_Control_Rec.Copy_Line_Flexfield = FND_API.G_FALSE Then
                  l_qte_line_tbl ( i ).ATTRIBUTE1 :=  Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE2 :=  Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE3 :=  Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE4 :=  Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE5 :=  Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE6 :=  Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE7 :=  Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE8 :=  Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE9 :=  Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE10 := Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE11 := Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE12 := Null;
		  l_qte_line_tbl ( i ).ATTRIBUTE13 := Null;
 	          l_qte_line_tbl ( i ).ATTRIBUTE14 := Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE15 := Null;
	          l_qte_line_tbl ( i ).ATTRIBUTE16 := Null;
		  l_qte_line_tbl ( i ).ATTRIBUTE17 := Null;
		  l_qte_line_tbl ( i ).ATTRIBUTE18 := Null;
		  l_qte_line_tbl ( i ).ATTRIBUTE19 := Null;
		  l_qte_line_tbl ( i ).ATTRIBUTE20 := Null;
               End If;
	       /* Code change for Quoting Usability Sun ER End */

               l_quote_party_tbl := ASO_UTILITY_PVT.Query_Quote_Party_Row(p_qte_header_id, L_QTE_LINE_ID);

               l_freight_charge_tbl := ASO_UTILITY_PVT.Query_Freight_Charge_Rows(l_shipment_tbl);

               l_tax_detail_tbl := ASO_UTILITY_PVT.Query_Tax_Detail_Rows(p_qte_header_id, L_QTE_LINE_ID, l_shipment_tbl);

               l_qte_line_tbl(i).quote_line_id := NULL;

               l_qte_line_tbl ( i ).object_version_number := FND_API.G_MISS_NUM;

	       --BC4J Fix

               FOR j IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP
		         l_qte_line_dtl_tbl(j).quote_line_detail_id := null;
                   l_qte_line_dtl_tbl(j).object_version_number := FND_API.G_MISS_NUM;
			    l_qte_line_dtl_tbl(j).top_model_line_id := null;
			    l_qte_line_dtl_tbl(j).ato_line_id := null;
                   l_qte_line_dtl_tbl(j).qte_line_index := i;
			END LOOP;

               FOR j IN 1 .. l_price_adj_tbl.COUNT LOOP
                  l_price_adj_tbl ( j ).QUOTE_HEADER_ID     := p_new_qte_header_id;
                  l_price_adj_tbl ( j ).price_adjustment_id := null;
                  l_price_adj_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_price_adj_attr_tbl.COUNT LOOP
                  l_price_adj_attr_tbl(j).price_adj_attrib_id := null;
                  l_price_adj_attr_tbl(j).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_price_attr_tbl.COUNT LOOP
                  l_price_attr_tbl ( j ).QUOTE_HEADER_ID    := p_new_qte_header_id;
                  l_price_attr_tbl ( j ).price_attribute_id := null;
                  l_price_attr_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               /* FOR j IN 1 .. l_payment_tbl.COUNT LOOP
                  l_payment_tbl ( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
                  l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_CODE := NULL;
                  l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_DATE := NULL;
                  l_payment_tbl ( j ).payment_id := NULL;
                  l_payment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
			END LOOP; */

               FOR j IN 1 .. l_shipment_tbl.COUNT LOOP
                  l_shipment_tbl ( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
                  l_shipment_tbl ( j ).shipment_id := null;
                  l_shipment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_sales_credit_tbl.COUNT LOOP
                  l_sales_credit_tbl(j).QUOTE_HEADER_ID := p_new_qte_header_id;
                  l_sales_credit_tbl(j).sales_credit_id := null;
                  l_sales_credit_tbl(j).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_quote_party_tbl.COUNT LOOP
                  l_quote_party_tbl(j).QUOTE_HEADER_ID := p_new_qte_header_id;
                  l_quote_party_tbl(j).QUOTE_PARTY_ID  := null;
                  l_quote_party_tbl(j).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_tax_detail_tbl.COUNT LOOP
                  l_tax_detail_tbl(j).tax_detail_id  := null;
                  l_tax_detail_tbl(j).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_line_attr_Ext_Tbl.COUNT LOOP
                  l_line_attr_Ext_Tbl(j).line_attribute_id := null;
                  l_line_attr_Ext_Tbl(j).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

               FOR j IN 1 .. l_freight_charge_tbl.COUNT LOOP
                  l_freight_charge_tbl(j).freight_charge_id := null;
                  l_freight_charge_tbl(j).object_version_number := FND_API.G_MISS_NUM;
			END LOOP;

		     --End of BC4J Fix

             -- Setting the new line number if a quote line is being copied
             IF ( P_Qte_Line_Id IS NOT NULL ) AND (P_Qte_Line_Id <> FND_API.G_MISS_NUM) THEN
                Open Get_Max_Line_Number(P_Qte_Header_Id);
                Fetch Get_Max_Line_Number into l_line_number;
                Close Get_Max_Line_Number;

                l_qte_line_tbl ( i ).line_number := l_line_number + 10000;

             END IF;


               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Copy_Line_Rows - Before insert_quote_line_rows: ' || l_qte_line_id , 1 , 'Y' );
			END IF;
               ASO_QUOTE_LINES_PVT.Insert_Quote_Line_Rows (
                   p_control_rec =>                l_control_rec
                , P_qte_Line_Rec =>                l_qte_line_tbl ( i )
                , P_qte_line_dtl_tbl =>            l_qte_line_dtl_tbl
                , P_Line_Attribs_Ext_Tbl =>        l_line_attr_ext_tbl
                , P_price_attributes_tbl =>        l_price_attr_tbl
                , P_Price_Adj_Tbl =>               l_price_adj_tbl
                , P_Price_Adj_Attr_Tbl =>          l_Price_Adj_Attr_Tbl
                , P_Payment_Tbl =>                 ASO_QUOTE_PUB.g_miss_payment_tbl
                , P_Shipment_Tbl =>                l_shipment_tbl
                , P_Freight_Charge_Tbl =>          l_freight_charge_tbl
                , P_Tax_Detail_Tbl =>              l_tax_detail_tbl
                , P_Sales_Credit_Tbl =>            l_sales_credit_tbl
                , P_Quote_Party_Tbl =>             l_quote_party_tbl
			 , x_qte_Line_Rec =>                lx_qte_line_rec
                , x_qte_line_dtl_tbl =>            l_qte_line_dtl_tbl_out
                , x_Line_Attribs_Ext_Tbl =>        l_line_attr_Ext_Tbl_out
                , x_price_attributes_tbl =>        l_price_attr_tbl_out
                , x_Price_Adj_Tbl =>               lx_ln_price_adj_tbl
                , x_Price_Adj_Attr_Tbl =>          l_Price_Adj_Attr_Tbl_out
                , x_Payment_Tbl =>                 l_payment_tbl_out
                , x_Shipment_Tbl =>                l_shipment_tbl_out
                , x_Freight_Charge_Tbl =>          l_freight_charge_tbl_out
                , x_Tax_Detail_Tbl =>              l_tax_detail_tbl_out
                , x_Sales_Credit_Tbl =>            l_sales_credit_tbl_out
                , x_Quote_Party_Tbl =>             l_quote_party_tbl_out
                , x_Return_Status =>               l_return_status
                , x_Msg_Count =>                   x_msg_count
                , x_Msg_Data =>                    x_msg_data
                );

      l_quote_party_tbl :=l_quote_party_tbl_out ;
      l_sales_credit_tbl :=l_sales_credit_tbl_out ;
      l_tax_detail_tbl := l_tax_detail_tbl_out    ;
      l_freight_charge_tbl := l_freight_charge_tbl_out  ;
      l_shipment_tbl := l_shipment_tbl_out   ;
      -- l_payment_tbl := l_payment_tbl_out     ;
      l_Price_Adj_Attr_Tbl  := l_Price_Adj_Attr_Tbl_out  ;
      l_Price_Attr_Tbl  :=  l_Price_Attr_Tbl_out     ;
      l_qte_line_dtl_tbl := l_qte_line_dtl_tbl_out   ;
      l_Line_Attr_Ext_Tbl  :=  l_Line_Attr_Ext_Tbl_out;


               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_INSERT' , TRUE );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Copy_Rows - After insert_quote_line_rows - status: ' || l_return_status , 1 , 'Y' );
			END IF;

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Copy_Rows - Updating the top model and ato line id for the top model line ', 1 , 'Y' );
			aso_debug_pub.ADD ( 'Copy_Rows - l_ato_model: ' || l_ato_model , 1 , 'Y' );
			END IF;
               update aso_quote_line_details
			set top_model_line_id =  lx_qte_line_rec.quote_line_id,
			    ato_line_id       =  decode(l_ato_model,fnd_api.g_true,lx_qte_line_rec.quote_line_id,null)
			where quote_line_id = lx_qte_line_rec.quote_line_id;

     -- Copy the payment record
     -- l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows(p_qte_header_id, L_QTE_LINE_ID);

     IF l_payment_tbl.count > 0 then

                FOR j IN 1 .. l_payment_tbl.COUNT LOOP
                  l_payment_tbl ( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
                  l_payment_tbl ( j ).quote_line_id := lx_qte_line_rec.quote_line_id;
                  l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_CODE := NULL;
                  l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_DATE := NULL;
                  l_payment_tbl ( j ).payment_id := NULL;
                  l_payment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;

		  /* Code change for Quoting Usability Sun ER Start */
		  If (P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_TRUE And
	              P_Copy_Quote_Control_Rec.Copy_Line_Payment = FND_API.G_FALSE) Then
                        l_payment_tbl ( j ).CUST_PO_NUMBER := Null;
			l_payment_tbl ( j ).CUST_PO_LINE_NUMBER := Null;
	                l_payment_tbl ( j ).PAYMENT_TERM_ID := Null;
		        l_payment_tbl ( j ).PAYMENT_TYPE_CODE := NULL;
		        l_payment_tbl ( j ).PAYMENT_REF_NUMBER := Null;
		        l_payment_tbl ( j ).CREDIT_CARD_CODE := Null;
		        l_payment_tbl ( j ).CREDIT_CARD_HOLDER_NAME := Null;
		        l_payment_tbl ( j ).CREDIT_CARD_EXPIRATION_DATE := Null;
                  End If;
	          l_payment_tbl ( j ).cvv2 := Null;
	          /* Code change for Quoting Usability Sun ER End */
               END LOOP;

       If P_Copy_Quote_Control_Rec.Copy_Line_Payment = FND_API.G_TRUE Then -- Code change for Quoting Usability Sun ER

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Copy_Rows: Before  call to copy_payment_row ', 1, 'Y');
       END IF;

         aso_copy_quote_pvt.copy_payment_row(p_payment_rec => l_payment_tbl(1)  ,
                                             x_return_status => l_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Copy_Rows: After call to copy_payment_row: x_return_status: '||l_return_status, 1, 'Y');
       END IF;
               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_INSERT' , TRUE );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.ADD ( 'Copy_Rows - After insert_quote_line_rows - status: ' || l_return_status , 1 , 'Y' );
               END IF;

     END IF;

     End If; -- Code change for Quoting Usability Sun ER

  --  End Copy payment record

/* Commented for Bug 16928074

         -- Copying the sales supplement data for the line
    --  IF ( P_Copy_Quote_Control_Rec.New_Version = FND_API.G_TRUE ) THEN code commented for Quoting Usability Sun ER

          If P_Copy_Quote_Control_Rec.Copy_Line_Sales_Supplement = FND_API.G_TRUE Then  -- Code change for Quoting Usability Sun ER

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.ADD ( 'Copy_Rows - Begin- before line copy_sales_supplement  ' , 1 , 'Y' );
                 END IF;

          ASO_COPY_QUOTE_PVT.INSERT_SALES_SUPP_DATA
          (
          P_Api_Version_Number          =>  1.0,
          P_Init_Msg_List               => P_Init_Msg_List,
          P_Commit                      => P_Commit,
          P_OLD_QUOTE_LINE_ID           => L_QTE_LINE_ID,
          P_NEW_QUOTE_LINE_ID           => lx_qte_line_rec.quote_line_id,
          X_Return_Status               => l_return_status,
          X_Msg_Count                   => X_Msg_Count,
          X_Msg_Data                    => X_Msg_Data );


                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.ADD ( 'Copy_Rows -After line copy_sales_supplement ' || x_return_status , 1 , 'Y' );
                  END IF;


               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                 IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                  FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                  FND_MESSAGE.Set_Token ('ROW' , 'ASO_QUOTE_HEADER', TRUE );
                  FND_MSG_PUB.ADD;
                END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                x_return_status            := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
               END IF;

  	  End If; -- Code change for Quoting Usability Sun ER

	-- END IF;  -- new version check

*/






               --IF P_Copy_Quote_Control_Rec.Copy_Attachment = FND_API.G_TRUE
	       IF P_Copy_Quote_Control_Rec.Copy_Line_Attachment = FND_API.G_TRUE   -- Code change for Quoting Usability Sun ER

                  OR ( ( P_Qte_Line_Id IS NOT NULL ) AND (P_Qte_Line_Id <> FND_API.G_MISS_NUM)) THEN

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
			  aso_debug_pub.ADD ( 'Copy_Rows - Begin- before line copy_attch  ' , 1 , 'Y' );
			  END IF;

                 ASO_ATTACHMENT_INT.Copy_Attachments(
                     p_api_version       => l_api_version,
                     p_old_object_code   => 'ASO_QUOTE_LINES_ALL',
                     p_new_object_code   => 'ASO_QUOTE_LINES_ALL',
                     p_old_object_id     => L_QTE_LINE_ID,
                     p_new_object_id     => lx_qte_line_rec.quote_line_id,
                     x_return_status     => l_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data
                   );
                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
			   aso_debug_pub.ADD ( 'Copy_Rows -After line copy_attch ' || l_return_status , 1 , 'Y' );
			   END IF;

                  IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                        FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                        FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_ATTACHMENTS' , TRUE );
                        FND_MSG_PUB.ADD;
                     END IF;
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                     x_return_status            := FND_API.G_RET_STS_ERROR;
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

               END IF;

               FOR j IN 1 .. l_dup_price_adj_tbl.COUNT LOOP
                  l_price_index_link_tbl ( l_dup_price_adj_tbl ( j ).price_adjustment_id ) :=
                                lx_ln_price_adj_tbl ( j ).price_adjustment_id;
               aso_debug_pub.ADD ( 'Copy - l_dup_price_adj_tbl ( j ).price_adjustment_id ' || l_dup_price_adj_tbl ( j ).price_adjustment_id , 1 , 'Y' );
               aso_debug_pub.ADD ( 'Copy - lx_ln_price_adj_tbl ( j ).price_adjustment_id ' || lx_ln_price_adj_tbl ( j ).price_adjustment_id , 1 , 'Y' );
               END LOOP;

               l_line_index_link_tbl ( l_qte_line_id ) :=
                                                 lx_qte_line_rec.quote_line_id;
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Copy_Config - l_qte_line_tbl(i).item_type_code ' || l_qte_line_tbl ( i ).item_type_code , 1 , 'Y' );
               aso_debug_pub.ADD ( 'Copy - l_qte_line_tbl(i).inventory_item_id ' || l_qte_line_tbl ( i ).inventory_item_id , 1 , 'Y' );
               aso_debug_pub.ADD ( 'Copy - l_serviceable_product_flag ' || l_serviceable_product_flag , 1 , 'Y' );
			END IF;

               IF l_serviceable_product_flag = 'Y' THEN

			  IF aso_debug_pub.g_debug_flag = 'Y' THEN
			  aso_debug_pub.ADD ( 'Before Calling Service Copy ' , 1 , 'N' );
			  END IF;

			   ASO_COPY_QUOTE_PVT.service_copy (
                      p_qte_line_id =>                l_qte_line_id
                   , p_copy_quote_control_rec =>      p_copy_quote_control_rec
                   , p_new_qte_header_id =>           p_new_qte_header_id
                   , p_qte_header_id =>               p_qte_header_id
                   , lx_line_index_link_tbl =>        l_line_index_link_tbl
                   , lx_price_index_link_tbl =>       l_price_index_link_tbl
                   , X_Return_Status =>               l_return_status
                   , X_Msg_Count =>                   x_msg_count
                   , X_Msg_Data =>                    x_msg_data
                   , p_line_quantity            =>  FND_API.G_MISS_NUM
                   );

               END IF;

		     IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( ' After Calling Service Copy' , 1 , 'N' );
			END IF;


               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_SERVICE' , TRUE );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

            END IF; -- If <> CFG and OPT and copy_flag = 'T'

            IF l_qte_line_tbl ( i ).item_type_code = 'MDL'
	       AND (l_copy_flag = 'T') THEN  -- Code change for Quoting Usability Sun ER
               IF l_qte_line_dtl_tbl.COUNT > 1 THEN
                  FOR k IN 2 .. l_qte_line_dtl_tbl.COUNT LOOP
                     l_qte_line_dtl_tbl ( k ).config_header_id :=
                                                              l_config_hdr_id;
                     l_qte_line_dtl_tbl ( k ).config_revision_num :=
                                                             l_config_rev_nbr;
                  END LOOP;
               END IF;

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'l_old_config_header_id = ' || l_old_config_header_id , 1 , 'N' );
               aso_debug_pub.ADD ( ' Before Calling Copy Quote Config Copy' , 1 , 'N' );
			END IF;

			ASO_COPY_QUOTE_PVT.config_copy (
                   p_old_config_header_id =>       l_old_config_header_id
                , p_old_config_revision_num =>     l_old_config_revision_num
                , p_config_header_id =>            l_config_hdr_id
                , p_config_revision_num =>         l_config_rev_nbr
                , p_copy_quote_control_rec =>      p_copy_quote_control_rec
                , p_new_qte_header_id =>           p_new_qte_header_id
                , p_qte_header_id =>               p_qte_header_id
                , lx_line_index_link_tbl =>        l_line_index_link_tbl
                , lx_price_index_link_tbl =>       l_price_index_link_tbl
                , X_Return_Status =>               l_return_status
                , X_Msg_Count =>                   x_msg_count
                , X_Msg_Data =>                    x_msg_data
                , p_line_quantity =>               FND_API.G_MISS_NUM
                );

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( ' After Calling Copy Quote Config Copy' , 1 , 'N' );
			END IF;


               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_CONFIG_COPY' , TRUE );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

               /* bug 1903605*/
               l_old_config_header_id     := NULL;
               l_old_config_revision_num  := NULL;
               /* bug 1903605*/

               IF (l_orig_item_id_tbl IS NOT NULL)  AND (l_new_item_id_tbl IS NOT NULL)  THEN

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'item_id_count > 0 ', 1 , 'N' );
		     aso_debug_pub.ADD ( 'Orig Tbl Count ' ||l_orig_item_id_tbl.count, 1 , 'N' );
               aso_debug_pub.ADD ( 'New Tbl Count '||l_new_item_id_tbl.count, 1 , 'N' );

			END IF;

			  IF l_orig_item_id_tbl.count > 0 AND l_new_item_id_tbl.count > 0 THEN

			   FORALL  i  IN l_orig_item_id_tbl.FIRST..l_orig_item_id_tbl.LAST
                     UPDATE aso_quote_line_details
                     SET config_item_id = l_new_item_id_tbl(i)
                        ,last_update_date = SYSDATE
                        ,last_updated_by =G_USER_ID
                        ,last_update_login = G_LOGIN_ID

                     WHERE config_header_id = l_config_hdr_id
                     AND config_revision_num = l_config_rev_nbr
                     AND config_item_id = l_orig_item_id_tbl(i);

			  END IF;

               END IF;

		    END IF; -- 'MDL'


         END IF; -- checking index link tbl

      END LOOP;

      -- Start : Code change done for Bug 16928074

      -- Copying the sales supplement data for the line
      IF P_Copy_Quote_Control_Rec.Copy_Line_Sales_Supplement = FND_API.G_TRUE THEN

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.ADD ( 'Copy_Rows - Begin- before line copy_sales_supplement ' , 1 , 'Y' );
         END IF;

	 /* FOR new_quote_lines_rec IN C_NEW_QUOTE_LINES LOOP
	    FOR i IN 1 .. ln_qte_line_tbl.COUNT LOOP
	    IF new_quote_lines_rec.inventory_item_id = ln_qte_line_tbl(i).inventory_item_id AND new_quote_lines_rec.rownum = i THEN */

	 -- Start : Code change done for Bug 19470596
	 FOR old_quote_lines_rec IN C_OLD_QUOTE_LINES LOOP
	     ln_qte_line_rec.quote_line_id     := old_quote_lines_rec.quote_line_id;
             ln_qte_line_rec.inventory_item_id := old_quote_lines_rec.inventory_item_id;
	     ln_old_line_tbl(ln_old_line_tbl.count+1) := ln_qte_line_rec;
	 END LOOP;

	 ln_qte_line_rec := ASO_Quote_Pub.G_MISS_qte_line_Rec;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.ADD ( 'Copy_Rows - line copy_sales_supplement ln_old_line_tbl.Count: '||ln_old_line_tbl.count , 1 , 'Y' );
         END IF;

	 FOR new_quote_lines_rec IN C_NEW_QUOTE_LINES LOOP
	     ln_qte_line_rec.quote_line_id     := new_quote_lines_rec.quote_line_id;
             ln_qte_line_rec.inventory_item_id := new_quote_lines_rec.inventory_item_id;
	     ln_new_line_tbl(ln_new_line_tbl.count+1) := ln_qte_line_rec;
	 END LOOP;

	 ln_qte_line_rec := ASO_Quote_Pub.G_MISS_qte_line_Rec;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.ADD ( 'Copy_Rows - line copy_sales_supplement ln_new_line_tbl.Count: '||ln_new_line_tbl.count , 1 , 'Y' );
         END IF;

	 -- Start : code change done for Bug 20332841
         If ln_new_line_tbl.count > 0 Then
	    l_diff := ln_old_line_tbl.count-ln_new_line_tbl.count;

	    If l_diff > 0 Then
               For i In 1 .. ln_new_line_tbl.count Loop
                   ln_qte_line_rec := ln_old_line_tbl(i);

		   If ln_new_line_tbl(i).inventory_item_id = ln_qte_line_rec.inventory_item_id Then
		      ln_old_changed_line_tbl(ln_old_changed_line_tbl.count+1) := ln_qte_line_rec;
                   Else
		      For j In 1 .. l_diff Loop
		          ln_qte_line_rec := ln_old_line_tbl(i+j);

		          If ln_new_line_tbl(i).inventory_item_id = ln_qte_line_rec.inventory_item_id Then
		             ln_old_changed_line_tbl(ln_old_changed_line_tbl.count+1) := ln_qte_line_rec;
			     EXIT;
                          End If;
		      End Loop;
	 	   End If;
	       End Loop;

	       IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.ADD ( 'Copy_Rows - line copy_sales_supplement ln_old_changed_line_tbl.Count: '||ln_old_changed_line_tbl.count , 1 , 'Y' );
               END IF;

	       ln_old_line_tbl := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;
	       ln_old_line_tbl := ln_old_changed_line_tbl;
	       ln_qte_line_rec := ASO_Quote_Pub.G_MISS_qte_line_Rec;
	    End if;
	 ElsIf ln_new_line_tbl.count = 0 Then
	       ln_old_line_tbl := ln_new_line_tbl;
	 End If;
	 -- End : code change done for Bug 20332841

	 FOR i IN 1 .. ln_old_line_tbl.COUNT LOOP

	     ln_qte_line_rec := ln_new_line_tbl(i);

	     IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.ADD (lpad('-',80,'-') , 1 , 'Y' );
		aso_debug_pub.ADD ( 'Copy_Rows - line copy_sales_supplement ln_old_line_tbl('||i||').quote_line_id : ' ||ln_old_line_tbl(i).quote_line_id , 1 , 'Y' );
	        aso_debug_pub.ADD ( 'Copy_Rows - line copy_sales_supplement ln_old_line_tbl('||i||').inventory_item_id : ' ||ln_old_line_tbl(i).inventory_item_id , 1 , 'Y' );
		aso_debug_pub.ADD (lpad('-',80,'-') , 1 , 'Y' );
                aso_debug_pub.ADD ( 'Copy_Rows - line copy_sales_supplement new quote_line_id : ' ||ln_qte_line_rec.quote_line_id , 1 , 'Y' );
		aso_debug_pub.ADD ( 'Copy_Rows - line copy_sales_supplement new inventory_item_id  : ' ||ln_qte_line_rec.inventory_item_id , 1 , 'Y' );
             END IF;

	     IF ln_old_line_tbl(i).inventory_item_id = ln_qte_line_rec.inventory_item_id Then

	 -- End : Code change done for Bug 19470596

		ASO_COPY_QUOTE_PVT.INSERT_SALES_SUPP_DATA
                   (
                    P_Api_Version_Number   =>  1.0,
                    P_Init_Msg_List        => P_Init_Msg_List,
                    P_Commit               => P_Commit,
                    P_OLD_QUOTE_LINE_ID    => ln_old_line_tbl(i).quote_line_id,
                    P_NEW_QUOTE_LINE_ID    => ln_qte_line_rec.quote_line_id,
                    X_Return_Status        => l_return_status,
                    X_Msg_Count            => X_Msg_Count,
                    X_Msg_Data             => X_Msg_Data );

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.ADD ( 'Copy_Rows -After line copy_sales_supplement l_return_status : ' || l_return_status , 1 , 'Y' );
                    END IF;

                    IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                         x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                            FND_MESSAGE.Set_Token ('ROW' , 'ASO_QUOTE_HEADER', TRUE );
                            FND_MSG_PUB.ADD;
                         END IF;
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                    ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                         x_return_status            := FND_API.G_RET_STS_ERROR;
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;
 	     END IF;
	 END LOOP;
      END IF;
      -- End : Code change done for Bug 16928074

-- Added a new IF for Copy Line Functionality

IF ( P_Qte_Line_Id IS NULL ) OR (P_Qte_Line_Id = FND_API.G_MISS_NUM) THEN

      FOR price_adj_rltship_rec IN c_price_adj_rel ( p_qte_header_id ) LOOP
         lx_price_adj_rltship_id    := FND_API.G_MISS_NUM;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'l_line_index_link_tbl ( price_adj_rltship_rec.quote_line_id ) = ' || l_line_index_link_tbl ( price_adj_rltship_rec.quote_line_id ) , 1 , 'N' );
	    END IF;

         OPEN C_Get_Ship_Id (
            l_line_index_link_tbl ( price_adj_rltship_rec.quote_line_id )
          );
         FETCH C_Get_Ship_Id INTO l_ship_id;
         CLOSE C_Get_Ship_Id;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'l_ship_id from line_id = ' || l_ship_id , 1 , 'N' );
	    aso_debug_pub.ADD ( 'price_adj_rltship_rec.price_adjustment_id = ' || price_adj_rltship_rec.price_adjustment_id , 1 , 'N' );
	    aso_debug_pub.ADD ( 'price_adj_rltship_rec.rltd_price_adj_id = ' || price_adj_rltship_rec.rltd_price_adj_id , 1 , 'N' );
	    END IF;

         ASO_PRICE_RLTSHIPS_PKG.Insert_Row (
            px_ADJ_RELATIONSHIP_ID =>       lx_price_adj_rltship_id
          , p_creation_date =>               SYSDATE
          , p_CREATED_BY =>                  G_USER_ID
          , p_LAST_UPDATE_DATE =>            SYSDATE
          , p_LAST_UPDATED_BY =>             G_USER_ID
          , p_LAST_UPDATE_LOGIN =>           G_LOGIN_ID
          , p_PROGRAM_APPLICATION_ID =>      price_adj_rltship_rec.PROGRAM_APPLICATION_ID
          , p_PROGRAM_ID =>                  price_adj_rltship_rec.PROGRAM_ID
          , p_PROGRAM_UPDATE_DATE =>         price_adj_rltship_rec.PROGRAM_UPDATE_DATE
          , p_REQUEST_ID =>                  price_adj_rltship_rec.REQUEST_ID
          , p_QUOTE_LINE_ID =>               l_line_index_link_tbl ( price_adj_rltship_rec.quote_line_id )
          , p_PRICE_ADJUSTMENT_ID =>         l_price_index_link_tbl ( price_adj_rltship_rec.price_adjustment_id )
          , p_RLTD_PRICE_ADJ_ID =>           l_price_index_link_tbl ( price_adj_rltship_rec.rltd_price_adj_id )
          , p_QUOTE_SHIPMENT_ID =>           l_ship_id
		, p_OBJECT_VERSION_NUMBER =>       price_adj_rltship_rec.OBJECT_VERSION_NUMBER
          );
      END LOOP;

      -- copy line relationships

      FOR line_rel_rec IN c_line_relation ( p_qte_header_id ) LOOP
         lx_LINE_RELATIONSHIP_ID    := FND_API.G_MISS_NUM;
         ASO_LINE_RELATIONSHIPS_PKG.Insert_Row (
             px_LINE_RELATIONSHIP_ID =>      lx_LINE_RELATIONSHIP_ID
          , p_CREATION_DATE =>               SYSDATE
          , p_CREATED_BY =>                  G_USER_ID
          , p_LAST_UPDATED_BY =>             G_USER_ID
          , p_LAST_UPDATE_DATE =>            SYSDATE
          , p_LAST_UPDATE_LOGIN =>           G_LOGIN_ID
          , p_REQUEST_ID =>                  line_rel_rec.REQUEST_ID
          , p_PROGRAM_APPLICATION_ID =>      line_rel_rec.PROGRAM_APPLICATION_ID
          , p_PROGRAM_ID =>                  line_rel_rec.PROGRAM_ID
          , p_PROGRAM_UPDATE_DATE =>         line_rel_rec.PROGRAM_UPDATE_DATE
          , p_QUOTE_LINE_ID =>               l_line_index_link_tbl ( line_rel_rec.quote_line_id )
          , p_RELATED_QUOTE_LINE_ID =>       l_line_index_link_tbl ( line_rel_rec.related_quote_line_id )
          , p_RECIPROCAL_FLAG =>             line_rel_rec.RECIPROCAL_FLAG
          , P_RELATIONSHIP_TYPE_CODE =>      line_rel_rec.RELATIONSHIP_TYPE_CODE
		, p_OBJECT_VERSION_NUMBER =>       line_rel_rec.OBJECT_VERSION_NUMBER
          );
      END LOOP;

-- Copy for only that line if a line id was passed in
ELSIF ( P_Qte_Line_Id IS NOT NULL ) AND (P_Qte_Line_Id <> FND_API.G_MISS_NUM) THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.ADD ( ' Copying price adj records ', 1 , 'N' );
aso_debug_pub.ADD ( 'Line Index Tbl Count = '||to_char(l_line_index_link_tbl.count) , 1 , 'N' );
END IF;

      FOR price_adj_rltship_rec IN c_price_adj_rel_from_line_id ( P_Qte_Line_Id ) LOOP
         lx_price_adj_rltship_id    := FND_API.G_MISS_NUM;
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'l_line_index_link_tbl ( price_adj_rltship_rec.quote_line_id ) = '
                             || l_line_index_link_tbl( price_adj_rltship_rec.quote_line_id ) , 1 , 'N' );
         END IF;

         OPEN C_Get_Ship_Id (
            l_line_index_link_tbl ( price_adj_rltship_rec.quote_line_id )
          );
         FETCH C_Get_Ship_Id INTO l_ship_id;
         CLOSE C_Get_Ship_Id;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'l_ship_id from line_id = ' || l_ship_id , 1 , 'N' );
	    END IF;

         ASO_PRICE_RLTSHIPS_PKG.Insert_Row (
             px_ADJ_RELATIONSHIP_ID =>       lx_price_adj_rltship_id
          , p_creation_date =>               SYSDATE
          , p_CREATED_BY =>                  G_USER_ID
          , p_LAST_UPDATE_DATE =>            SYSDATE
          , p_LAST_UPDATED_BY =>             G_USER_ID
          , p_LAST_UPDATE_LOGIN =>           G_LOGIN_ID
          , p_PROGRAM_APPLICATION_ID =>      price_adj_rltship_rec.PROGRAM_APPLICATION_ID
          , p_PROGRAM_ID =>                  price_adj_rltship_rec.PROGRAM_ID
          , p_PROGRAM_UPDATE_DATE =>         price_adj_rltship_rec.PROGRAM_UPDATE_DATE
          , p_REQUEST_ID =>                  price_adj_rltship_rec.REQUEST_ID
          , p_QUOTE_LINE_ID =>               l_line_index_link_tbl ( price_adj_rltship_rec.quote_line_id )
          , p_PRICE_ADJUSTMENT_ID =>         l_price_index_link_tbl ( price_adj_rltship_rec.price_adjustment_id )
          , p_RLTD_PRICE_ADJ_ID =>           l_price_index_link_tbl ( price_adj_rltship_rec.rltd_price_adj_id )
          , p_QUOTE_SHIPMENT_ID =>           l_ship_id
		, p_OBJECT_VERSION_NUMBER =>       price_adj_rltship_rec.OBJECT_VERSION_NUMBER
          );
      END LOOP;


      -- copy line relationships

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( ' Copying line relationship records ', 1 , 'N' );
	 END IF;

      FOR line_rel_rec IN c_line_relation_from_line_id ( P_Qte_Line_Id ) LOOP
         lx_LINE_RELATIONSHIP_ID    := FND_API.G_MISS_NUM;
         ASO_LINE_RELATIONSHIPS_PKG.Insert_Row (
             px_LINE_RELATIONSHIP_ID =>      lx_LINE_RELATIONSHIP_ID
          , p_CREATION_DATE =>               SYSDATE
          , p_CREATED_BY =>                  G_USER_ID
          , p_LAST_UPDATED_BY =>             G_USER_ID
          , p_LAST_UPDATE_DATE =>            SYSDATE
          , p_LAST_UPDATE_LOGIN =>           G_LOGIN_ID
          , p_REQUEST_ID =>                  line_rel_rec.REQUEST_ID
          , p_PROGRAM_APPLICATION_ID =>      line_rel_rec.PROGRAM_APPLICATION_ID
          , p_PROGRAM_ID =>                  line_rel_rec.PROGRAM_ID
          , p_PROGRAM_UPDATE_DATE =>         line_rel_rec.PROGRAM_UPDATE_DATE
          , p_QUOTE_LINE_ID =>               l_line_index_link_tbl ( line_rel_rec.quote_line_id )
          , p_RELATED_QUOTE_LINE_ID =>       l_line_index_link_tbl ( line_rel_rec.related_quote_line_id )
          , p_RECIPROCAL_FLAG =>             line_rel_rec.RECIPROCAL_FLAG
          , P_RELATIONSHIP_TYPE_CODE =>      line_rel_rec.RELATIONSHIP_TYPE_CODE
		, p_OBJECT_VERSION_NUMBER =>       line_rel_rec.OBJECT_VERSION_NUMBER
          );
      END LOOP;

END IF;


 -- Pass back the new quote line id which was created
IF ( P_Qte_Line_Id IS NOT NULL ) AND (P_Qte_Line_Id <> FND_API.G_MISS_NUM) THEN

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( 'Calling Update Quote to re-price the quote  ', 1 , 'N' );
    END IF;
  -- Call Update Quote for repricing the quote

    --   l_control_rec.pricing_request_type          :=  'ASO';
    --   l_control_rec.header_pricing_event          :=  'BATCH';


       l_Qte_Header_Rec.quote_header_id := P_Qte_Header_Id;
	  l_Qte_Header_Rec.last_update_date := l_last_update_date;
	  l_Qte_Header_Rec.pricing_status_indicator :=  P_Qte_Header_Rec.pricing_status_indicator;
	  l_Qte_Header_Rec.tax_status_indicator :=  P_Qte_Header_Rec.tax_status_indicator;
	  l_Qte_Header_Rec.price_updated_date :=  P_Qte_Header_Rec.price_updated_date;
	  l_Qte_Header_Rec.tax_updated_date :=  P_Qte_Header_Rec.tax_updated_date;

  aso_quote_pub.update_quote (
      p_api_version_number         => 1.0,
      p_init_msg_list              => fnd_api.g_false,
      p_commit                     => fnd_api.g_false,
      p_control_rec                => p_control_rec,
      p_qte_header_rec             => l_Qte_Header_Rec,
      p_hd_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
      p_hd_payment_tbl             => aso_quote_pub.g_miss_payment_tbl,
      p_hd_shipment_tbl            => aso_quote_pub.g_miss_shipment_tbl,
      p_hd_freight_charge_tbl      => aso_quote_pub.g_miss_freight_charge_tbl,
      p_hd_tax_detail_tbl          => aso_quote_pub.g_miss_tax_detail_tbl,
      p_qte_line_tbl               => aso_quote_pub.g_miss_qte_line_tbl,
      p_qte_line_dtl_tbl           => aso_quote_pub.g_miss_qte_line_dtl_tbl,
      p_line_attr_ext_tbl          => aso_quote_pub.G_MISS_Line_Attribs_Ext_TBL,
      p_line_rltship_tbl           => aso_quote_pub.g_miss_line_rltship_tbl,
      p_price_adjustment_tbl       => aso_quote_pub.g_miss_price_adj_tbl,
      p_price_adj_attr_tbl         => aso_quote_pub.g_miss_price_adj_attr_tbl,
      p_price_adj_rltship_tbl      => aso_quote_pub.g_miss_price_adj_rltship_tbl,
      p_ln_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
      p_ln_payment_tbl             => aso_quote_pub.g_miss_payment_tbl,
      p_ln_shipment_tbl            => aso_quote_pub.g_miss_shipment_tbl,
      p_ln_freight_charge_tbl      => aso_quote_pub.g_miss_freight_charge_tbl,
      p_ln_tax_detail_tbl          => aso_quote_pub.g_miss_tax_detail_tbl,
      x_qte_header_rec             => x_qte_header_rec,
      x_qte_line_tbl               => x_qte_line_tbl,
      x_qte_line_dtl_tbl           => x_qte_line_dtl_tbl,
      x_hd_price_attributes_tbl    => x_hd_price_attributes_tbl,
      x_hd_payment_tbl             => x_hd_payment_tbl,
      x_hd_shipment_tbl            => x_hd_shipment_tbl,
      x_hd_freight_charge_tbl      => x_hd_freight_charge_tbl,
      x_hd_tax_detail_tbl          => x_hd_tax_detail_tbl,
      x_line_attr_ext_tbl          => x_line_attr_ext_tbl,
      x_line_rltship_tbl           => x_line_rltship_tbl,
      x_price_adjustment_tbl       => x_price_adjustment_tbl,
      x_price_adj_attr_tbl         => x_price_adj_attr_tbl,
      x_price_adj_rltship_tbl      => x_price_adj_rltship_tbl,
      x_ln_price_attributes_tbl    => x_ln_price_attributes_tbl,
      x_ln_payment_tbl             => x_ln_payment_tbl,
      x_ln_shipment_tbl            => x_ln_shipment_tbl,
      x_ln_freight_charge_tbl      => x_ln_freight_charge_tbl,
      x_ln_tax_detail_tbl          => x_ln_tax_detail_tbl,
      x_return_status              => l_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( ' Return Status from Update Quote = '||l_return_status, 1 , 'N' );
    END IF;

               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.ADD ( ' After Calling Update Quote  ', 1 , 'N' );
   END IF;

  X_Qte_Line_Id := lx_qte_line_rec.quote_line_id;
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.ADD ('X_Qte_Line_Id =   '||to_char(X_Qte_Line_Id), 1 , 'N' );
  END IF;

ELSE

 X_Qte_Line_Id := NULL;
END IF;

/* Code change for Quoting Usability Sun ER Start */
If P_Copy_Quote_Control_Rec.Copy_To_Same_Customer = FND_API.G_FALSE Then
IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.ADD ( 'Copy_Line_Rows : Calling Update Quote for lines in change customer flow', 1 , 'N' );
   aso_debug_pub.ADD ( 'Copy_Line_Rows : P_Qte_Header_Id :'||P_Qte_Header_Id, 1 , 'N' );
   aso_debug_pub.ADD ( 'Copy_Line_Rows : l_last_update_date :'||l_last_update_date, 1 , 'N' );
   aso_debug_pub.ADD ( 'Copy_Line_Rows : P_Qte_Header_Rec.pricing_status_indicator :'||P_Qte_Header_Rec.pricing_status_indicator, 1 , 'N' );
   aso_debug_pub.ADD ( 'Copy_Line_Rows : P_Qte_Header_Rec.price_updated_date :'||P_Qte_Header_Rec.price_updated_date, 1 , 'N' );
   aso_debug_pub.ADD ( 'Copy_Line_Rows : P_Qte_Header_Rec.tax_updated_date :'||P_Qte_Header_Rec.tax_updated_date, 1 , 'N' );
END IF;

-- Call Update Quote for repricing the quote

l_control_rec.pricing_request_type  := Null;
l_control_rec.header_pricing_event  := Null;

--Bug12829891
/*Changed from P_Qte_Header_Id to P_New_Qte_Header_Id*/
l_Qte_Header_Rec.quote_header_id := P_New_Qte_Header_Id;
l_Qte_Header_Rec.last_update_date := l_last_update_date;
l_Qte_Header_Rec.pricing_status_indicator :=  P_Qte_Header_Rec.pricing_status_indicator;
l_Qte_Header_Rec.tax_status_indicator :=  P_Qte_Header_Rec.tax_status_indicator;
l_Qte_Header_Rec.price_updated_date :=  P_Qte_Header_Rec.price_updated_date;
l_Qte_Header_Rec.tax_updated_date :=  P_Qte_Header_Rec.tax_updated_date;

  aso_quote_pub.update_quote (
      p_api_version_number         => 1.0,
      p_init_msg_list              => fnd_api.g_false,
      p_commit                     => fnd_api.g_false,
      p_control_rec                => p_control_rec,
      p_qte_header_rec             => l_Qte_Header_Rec,
      p_hd_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
      p_hd_payment_tbl             => aso_quote_pub.g_miss_payment_tbl,
      p_hd_shipment_tbl            => aso_quote_pub.g_miss_shipment_tbl,
      p_hd_freight_charge_tbl      => aso_quote_pub.g_miss_freight_charge_tbl,
      p_hd_tax_detail_tbl          => aso_quote_pub.g_miss_tax_detail_tbl,
      p_qte_line_tbl               => l_qte_line_tbl,
      p_qte_line_dtl_tbl           => l_qte_line_dtl_tbl,
      p_line_attr_ext_tbl          => l_line_attr_Ext_Tbl,
      p_line_rltship_tbl           => aso_quote_pub.g_miss_line_rltship_tbl,
      p_price_adjustment_tbl       => aso_quote_pub.g_miss_price_adj_tbl,
      p_price_adj_attr_tbl         => aso_quote_pub.g_miss_price_adj_attr_tbl,
      p_price_adj_rltship_tbl      => aso_quote_pub.g_miss_price_adj_rltship_tbl,
      p_ln_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
      p_ln_payment_tbl             => l_payment_tbl,
      p_ln_shipment_tbl            => l_shipment_tbl,
      p_ln_freight_charge_tbl      => l_freight_charge_tbl,
      p_ln_tax_detail_tbl          => l_tax_detail_tbl,
      x_qte_header_rec             => x_qte_header_rec,
      x_qte_line_tbl               => x_qte_line_tbl,
      x_qte_line_dtl_tbl           => x_qte_line_dtl_tbl,
      x_hd_price_attributes_tbl    => x_hd_price_attributes_tbl,
      x_hd_payment_tbl             => x_hd_payment_tbl,
      x_hd_shipment_tbl            => x_hd_shipment_tbl,
      x_hd_freight_charge_tbl      => x_hd_freight_charge_tbl,
      x_hd_tax_detail_tbl          => x_hd_tax_detail_tbl,
      x_line_attr_ext_tbl          => x_line_attr_ext_tbl,
      x_line_rltship_tbl           => x_line_rltship_tbl,
      x_price_adjustment_tbl       => x_price_adjustment_tbl,
      x_price_adj_attr_tbl         => x_price_adj_attr_tbl,
      x_price_adj_rltship_tbl      => x_price_adj_rltship_tbl,
      x_ln_price_attributes_tbl    => x_ln_price_attributes_tbl,
      x_ln_payment_tbl             => x_ln_payment_tbl,
      x_ln_shipment_tbl            => x_ln_shipment_tbl,
      x_ln_freight_charge_tbl      => x_ln_freight_charge_tbl,
      x_ln_tax_detail_tbl          => x_ln_tax_detail_tbl,
      x_return_status              => l_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( ' Copy_Line_Rows : Return Status from Update Quote = '||l_return_status, 1 , 'N' );
    END IF;

               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.ADD ( 'Copy_Line_Rows : After Calling Update Quote for lines in change customer flow ', 1 , 'N' );
   END IF;
   End If;
   /* Code change for Quoting Usability Sun ER End */

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( ' End Copy Line Rows API ', 1 , 'N' );
	 END IF;

      x_return_status            := FND_API.G_RET_STS_SUCCESS;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean ( p_commit ) THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
          p_count =>                      x_msg_count
       , p_data =>                        x_msg_data
       );

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_SQLCODE =>                     SQLCODE
          , P_SQLERRM =>                     SQLERRM
          , P_EXCEPTION_LEVEL =>             ASO_UTILITY_PVT.G_EXC_OTHERS
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

   END Copy_Line_Rows;


   PROCEDURE config_copy (
       p_old_config_header_id IN NUMBER
    , p_old_config_revision_num IN NUMBER
    , p_config_header_id IN NUMBER
    , p_config_revision_num IN NUMBER
    , p_new_qte_header_id IN NUMBER
    , p_qte_header_id IN NUMBER
    , p_copy_quote_control_rec IN ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type
            := ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Control_Rec
    , lx_line_index_link_tbl IN OUT NOCOPY ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type
    , lx_price_index_link_tbl IN OUT NOCOPY ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , p_line_quantity  IN NUMBER := FND_API.G_MISS_NUM
   ) IS

      -- made changes to the cursor as per bug4036748
      CURSOR line_id_from_config (
          config_hdr_id NUMBER
       , config_rev_number NUMBER
       , qte_hdr_id NUMBER
       ) IS
         SELECT   ASO_Quote_Line_Details.QUOTE_LINE_ID
         FROM     ASO_Quote_Line_Details
                , ASO_Quote_Lines_all
         WHERE    ASO_Quote_Line_Details.config_header_id = config_hdr_id
         AND      ASO_Quote_Line_Details.config_revision_num = config_rev_number
         AND      ASO_quote_line_details.quote_line_id = ASO_Quote_Lines_all.quote_line_id
         AND      ASO_quote_line_details.ref_type_code = 'CONFIG'
	    AND      ASO_quote_line_details.ref_line_id is not null
         AND      aso_quote_lines_all.quote_header_id = qte_hdr_id
         ORDER BY aso_quote_line_details.bom_sort_order;

      CURSOR C_Serviceable_Product (
          l_organization_id NUMBER
       , l_inv_item_id NUMBER
       ) IS
         SELECT serviceable_product_flag
         FROM   MTL_SYSTEM_ITEMS_VL
         WHERE  inventory_item_id = l_inv_item_id
         AND    organization_id = l_organization_id;

      l_payment_tbl ASO_QUOTE_PUB.Payment_Tbl_Type;
      l_shipment_tbl ASO_QUOTE_PUB.Shipment_Tbl_Type;
      l_shipment_rec ASO_QUOTE_PUB.Shipment_Rec_Type;
      l_freight_charge_tbl ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
      l_tax_detail_tbl ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
      l_Price_Attr_Tbl ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
      l_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
      l_Price_Adj_Attr_Tbl ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
      l_qte_line_dtl_tbl ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
      l_qte_line_rec ASO_QUOTE_PUB.Qte_Line_Rec_Type;
      l_Line_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      lx_ln_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
      lx_qte_line_rec ASO_QUOTE_PUB.Qte_Line_Rec_Type;
      l_control_rec ASO_QUOTE_PUB.Control_Rec_Type;
      LX_PRICE_ADJ_RLTSHIP_ID NUMBER;
      LX_LINE_RELATIONSHIP_ID NUMBER;
      X_hd_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      X_Sales_Credit_Tbl ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      X_Quote_Party_Tbl ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_hd_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      l_quote_party_tbl ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_quote_party_rec ASO_QUOTE_PUB.Quote_Party_rec_Type;
      l_sales_credit_tbl ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      l_sales_credit_rec ASO_QUOTE_PUB.Sales_Credit_rec_Type;
      l_return_status VARCHAR2 ( 1 );
      qte_line_id NUMBER;
      i NUMBER;
      j NUMBER;
      k NUMBER;
      l_quote_line_id NUMBER;
      l_serviceable_product_flag VARCHAR2 ( 1 );
      l_api_version CONSTANT NUMBER := 1.0;
      l_ref_ln_id NUMBER;
      l_ato_line_id NUMBER;
	 l_top_model_line_id NUMBER;


      Cursor get_qte_line_number (x_qte_line_id NUMBER)  IS
      SELECT line_number
      FROM aso_quote_lines_all
      WHERE quote_line_id = x_qte_line_id ;

      l_line_number  NUMBER;
      l_old_quote_line_id  Number;

      CURSOR get_old_line_id (
          config_hdr_id NUMBER
       , config_rev_number NUMBER
       , qte_hdr_id NUMBER
       ) IS
         SELECT   ASO_Quote_Line_Details.QUOTE_LINE_ID
         FROM     ASO_Quote_Line_Details
                , ASO_Quote_Lines_all
         WHERE    ASO_Quote_Line_Details.config_header_id = config_hdr_id
         AND      ASO_Quote_Line_Details.config_revision_num = config_rev_number
         AND      ASO_quote_line_details.quote_line_id = ASO_Quote_Lines_all.quote_line_id
         AND      ASO_Quote_Lines_all.item_type_code = 'MDL'
         AND      aso_quote_lines_all.quote_header_id = qte_hdr_id;

      l_quote_party_tbl_out      ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_sales_credit_tbl_out     ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      l_tax_detail_tbl_out       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
      l_freight_charge_tbl_out   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
      l_shipment_tbl_out         ASO_QUOTE_PUB.Shipment_Tbl_Type;
      l_payment_tbl_out          ASO_QUOTE_PUB.Payment_Tbl_Type;
      l_Price_Adj_Attr_Tbl_out   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
      l_Price_Attr_Tbl_out       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
      l_qte_line_dtl_tbl_out     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
      l_Line_Attr_Ext_Tbl_out    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;

      l_dup_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;


   BEGIN

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ('Copy_Config - Begin ' , 1, 'Y' );
      aso_debug_pub.ADD ( 'Copy_Config - p_new_qte_header_id ' || p_new_qte_header_id , 1 , 'Y' );
      aso_debug_pub.ADD ( 'Copy_Config - p_qte_header_id ' || p_qte_header_id , 1 , 'Y' );
	 END IF;

      x_return_status            := FND_API.G_RET_STS_SUCCESS;

      OPEN line_id_from_config (
          p_old_config_header_id
       , p_old_config_revision_num
       , p_qte_header_id
       );
      LOOP
         FETCH line_id_from_config INTO qte_line_id;
         EXIT WHEN line_id_from_config%NOTFOUND;
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Config - inside cursor qte_line_id ' || qte_line_id , 1 , 'Y' );
	    END IF;

         l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row ( qte_line_id );

          IF p_new_qte_header_id = p_qte_header_id THEN

          OPEN  get_old_line_id (
          p_old_config_header_id
        , p_old_config_revision_num
        , p_qte_header_id
         );

         FETCH get_old_line_id INTO l_old_quote_line_id;
         CLOSE get_old_line_id;

           OPEN get_qte_line_number(lx_line_index_link_tbl(l_old_quote_line_id));
           FETCH get_qte_line_number into l_line_number;
           CLOSE get_qte_line_number;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
		 aso_debug_pub.ADD ( 'Line Number --  ' || l_line_number , 1 , 'Y' );
		 END IF;


           l_qte_line_rec.line_number := l_line_number;

          END IF;

         l_qte_line_rec.quote_header_id := p_new_qte_header_id;

         -- Setting the line quantity ( as per changes for split_line API )
         IF (p_line_quantity is not null ) and (p_line_quantity <>  FND_API.G_MISS_NUM ) THEN
          l_qte_line_rec.quantity := p_line_quantity;
         END IF;

         l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows ( qte_line_id );

         FOR k IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP
            l_qte_line_dtl_tbl ( k ).config_header_id := p_config_header_id;
            l_qte_line_dtl_tbl ( k ).config_revision_num := p_config_revision_num;
         END LOOP;

         l_line_attr_Ext_Tbl := ASO_UTILITY_PVT.Query_Line_Attribs_Ext_Rows ( qte_line_id );

         l_price_adj_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Rows ( p_qte_header_id , qte_line_id );
	    l_dup_price_adj_tbl := l_price_adj_tbl;

         l_price_adj_attr_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Attr_Rows(p_price_adj_tbl => l_price_adj_tbl);

         l_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows ( p_qte_header_id , qte_line_id );

         --l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows ( p_qte_header_id , qte_line_id );

         l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows ( p_qte_header_id , qte_line_id );

         l_sales_credit_tbl := ASO_UTILITY_PVT.Query_Sales_Credit_Row ( p_qte_header_id , qte_line_id );

         l_quote_party_tbl := ASO_UTILITY_PVT.Query_Quote_Party_Row ( p_qte_header_id , qte_line_id );

         l_freight_charge_tbl := ASO_UTILITY_PVT.Query_Freight_Charge_Rows ( l_shipment_tbl );

         l_tax_detail_tbl := ASO_UTILITY_PVT.Query_Tax_Detail_Rows ( p_qte_header_id , qte_line_id , l_shipment_tbl );

         OPEN C_Serviceable_Product ( l_qte_line_rec.organization_id , l_qte_line_rec.inventory_item_id );
         FETCH C_Serviceable_Product INTO l_serviceable_product_flag;
         CLOSE C_Serviceable_Product;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.ADD ('Copy_Config - After querying all the records for the line ' , 1, 'Y' );
	    END IF;

         FOR j IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.ADD ('Copy_Config - l_qte_line_dtl_tbl('||j||')ref_line_id: '||l_qte_line_dtl_tbl(j).ref_line_id , 1, 'Y' );
	           aso_debug_pub.ADD ('Copy_Config - l_qte_line_dtl_tbl('||j||')top_model_line_id: '||l_qte_line_dtl_tbl(j).top_model_line_id , 1, 'Y' );
	           aso_debug_pub.ADD ('Copy_Config - l_qte_line_dtl_tbl('||j||')ato_line_id: '||l_qte_line_dtl_tbl(j).ato_line_id , 1, 'Y' );
	       END IF;

            l_ref_ln_id := lx_line_index_link_tbl ( l_qte_line_dtl_tbl ( j ).ref_line_id );
            l_qte_line_dtl_tbl ( j ).ref_line_id := l_ref_ln_id;

		 IF (l_qte_line_dtl_tbl(j).top_model_line_id IS NOT NULL AND l_qte_line_dtl_tbl(j).top_model_line_id <> FND_API.G_MISS_NUM
		     and lx_line_index_link_tbl.exists(l_qte_line_dtl_tbl(j).top_model_line_id) ) THEN
		     l_top_model_line_id := lx_line_index_link_tbl ( l_qte_line_dtl_tbl ( j ).top_model_line_id );
               l_qte_line_dtl_tbl ( j ).top_model_line_id := l_top_model_line_id;
		 END IF;

		 IF (l_qte_line_dtl_tbl ( j ).ato_line_id IS NOT NULL AND l_qte_line_dtl_tbl ( j ).ato_line_id <> FND_API.G_MISS_NUM
		     and lx_line_index_link_tbl.exists(l_qte_line_dtl_tbl(j).ato_line_id) ) THEN
		      l_ato_line_id := lx_line_index_link_tbl ( l_qte_line_dtl_tbl ( j ).ato_line_id );
                l_qte_line_dtl_tbl ( j ).ato_line_id := l_ato_line_id;
		 END IF;


         END LOOP;

         l_quote_line_id := l_qte_line_rec.quote_line_id;
         l_qte_line_rec.quote_line_id := NULL;
         l_qte_line_rec.object_version_number := FND_API.G_MISS_NUM;


	 --BC4J Fix

         FOR j IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP
	       l_qte_line_dtl_tbl(j).quote_line_detail_id := null;
            l_qte_line_dtl_tbl(j).object_version_number := FND_API.G_MISS_NUM;
	    END LOOP;

         FOR j IN 1 .. l_price_adj_tbl.COUNT LOOP
            l_price_adj_tbl ( j ).QUOTE_HEADER_ID     := p_new_qte_header_id;
            l_price_adj_tbl ( j ).price_adjustment_id := null;
            l_price_adj_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
	    END LOOP;

         FOR j IN 1 .. l_price_adj_attr_tbl.COUNT LOOP
            l_price_adj_attr_tbl(j).price_adj_attrib_id := null;
            l_price_adj_attr_tbl(j).object_version_number := FND_API.G_MISS_NUM;
	    END LOOP;

         FOR j IN 1 .. l_price_attr_tbl.COUNT LOOP
            l_price_attr_tbl ( j ).QUOTE_HEADER_ID    := p_new_qte_header_id;
            l_price_attr_tbl ( j ).price_attribute_id := null;
            l_price_attr_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
	    END LOOP;

         /* FOR j IN 1 .. l_payment_tbl.COUNT LOOP
            l_payment_tbl ( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
            l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_CODE := NULL;
            l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_DATE := NULL;
            l_payment_tbl ( j ).payment_id := NULL;
		  l_payment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;  */

         FOR j IN 1 .. l_shipment_tbl.COUNT LOOP
            l_shipment_tbl ( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
            l_shipment_tbl ( j ).shipment_id := null;
		  l_shipment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_sales_credit_tbl.COUNT LOOP
            l_sales_credit_tbl(j).QUOTE_HEADER_ID := p_new_qte_header_id;
            l_sales_credit_tbl(j).sales_credit_id := null;
		  l_sales_credit_tbl(j).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_tax_detail_tbl.COUNT LOOP
            l_tax_detail_tbl(j).tax_detail_id  := null;
		  l_tax_detail_tbl(j).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_quote_party_tbl.COUNT LOOP
            l_quote_party_tbl(j).QUOTE_HEADER_ID := p_new_qte_header_id;
            l_quote_party_tbl(j).QUOTE_PARTY_ID := null;
		  l_quote_party_tbl(j).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_line_attr_Ext_Tbl.COUNT LOOP
            l_line_attr_Ext_Tbl(j).line_attribute_id  := null;
		  l_line_attr_Ext_Tbl(j).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_freight_charge_tbl.COUNT LOOP
            l_freight_charge_tbl(j).freight_charge_id  := null;
		  l_freight_charge_tbl(j).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;


	--End of BC4J Fix

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Config - Before insert_quote_line_rows: ' || l_quote_line_id , 1 , 'Y' );
	    END IF;
         ASO_QUOTE_LINES_PVT.Insert_Quote_Line_Rows (
             p_control_rec =>                l_control_rec
          , P_qte_Line_Rec =>                l_qte_line_rec
          , P_qte_line_dtl_tbl =>            l_qte_line_dtl_tbl
          , P_Line_Attribs_Ext_Tbl =>        l_line_attr_ext_tbl
          , P_price_attributes_tbl =>        l_price_attr_tbl
          , P_Price_Adj_Tbl =>               l_price_adj_tbl
          , P_Price_Adj_Attr_Tbl =>          l_Price_Adj_Attr_Tbl
          , P_Payment_Tbl =>                 ASO_QUOTE_PUB.g_miss_payment_tbl
          , P_Shipment_Tbl =>                l_shipment_tbl
          , P_Freight_Charge_Tbl =>          l_freight_charge_tbl
          , P_Tax_Detail_Tbl =>              l_tax_detail_tbl
          , P_Sales_Credit_Tbl =>            l_sales_credit_tbl
          , P_Quote_Party_Tbl =>             l_quote_party_tbl

		, x_qte_Line_Rec =>                lx_qte_line_rec
          , x_qte_line_dtl_tbl =>            l_qte_line_dtl_tbl_out
          , x_Line_Attribs_Ext_Tbl =>        l_line_attr_Ext_Tbl_out
          , x_price_attributes_tbl =>        l_price_attr_tbl_out
          , x_Price_Adj_Tbl =>               lx_ln_price_adj_tbl
          , x_Price_Adj_Attr_Tbl =>          l_Price_Adj_Attr_Tbl_out
          , x_Payment_Tbl =>                 l_payment_tbl_out
          , x_Shipment_Tbl =>                l_shipment_tbl_out
          , x_Freight_Charge_Tbl =>          l_freight_charge_tbl_out
          , x_Tax_Detail_Tbl =>              l_tax_detail_tbl_out
          , X_Sales_Credit_Tbl =>            l_sales_credit_tbl_out
          , X_Quote_Party_Tbl =>             l_quote_party_tbl_out
          , X_Return_Status =>               x_return_status
          , X_Msg_Count =>                   x_msg_count
          , X_Msg_Data =>                    x_msg_data
          );

      l_quote_party_tbl :=l_quote_party_tbl_out ;
      l_sales_credit_tbl :=l_sales_credit_tbl_out ;
      l_tax_detail_tbl := l_tax_detail_tbl_out    ;
      l_freight_charge_tbl := l_freight_charge_tbl_out  ;
      l_shipment_tbl := l_shipment_tbl_out   ;
      l_payment_tbl := l_payment_tbl_out     ;
      l_Price_Adj_Attr_Tbl  := l_Price_Adj_Attr_Tbl_out  ;
      l_Price_Attr_Tbl  :=  l_Price_Attr_Tbl_out     ;
      l_qte_line_dtl_tbl := l_qte_line_dtl_tbl_out   ;
      l_Line_Attr_Ext_Tbl  :=  l_Line_Attr_Ext_Tbl_out;



         IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
               FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYCONFIG AFTER_INSERT' , TRUE );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      -- Copy the payment record
       l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows ( p_qte_header_id , qte_line_id );
      IF l_payment_tbl.count > 0 then

         FOR j IN 1 .. l_payment_tbl.COUNT LOOP
            l_payment_tbl ( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
            l_payment_tbl ( j ).QUOTE_LINE_ID := lx_qte_line_rec.quote_line_id;
            l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_CODE := NULL;
            l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_DATE := NULL;
            l_payment_tbl ( j ).payment_id := NULL;
            l_payment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Copy_Config: Before  call to copy_payment_row ', 1, 'Y');
       END IF;

         aso_copy_quote_pvt.copy_payment_row(p_payment_rec => l_payment_tbl(1)  ,
                                             x_return_status => l_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Copy_Config: After call to copy_payment_row: x_return_status: '||l_return_status, 1, 'Y');
       END IF;
      IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
            FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYCONFIG AFTER_INSERT' , TRUE );
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;
     --  End Copy payment record


         -- Copying the sales supplement data for the line
      IF ( P_Copy_Quote_Control_Rec.New_Version = FND_API.G_TRUE ) THEN

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.ADD ( 'Copy_Config: Begin- before line copy_sales_supplement , call is commented ' , 1 , 'Y' );
                 END IF;

		  /* following code is commented for Bug 21571359

          ASO_COPY_QUOTE_PVT.INSERT_SALES_SUPP_DATA
          (
          P_Api_Version_Number          =>  1.0,
          P_Init_Msg_List               => FND_API.G_FALSE,
          P_Commit                      => FND_API.G_FALSE,
          P_OLD_QUOTE_LINE_ID           => qte_line_id,
          P_NEW_QUOTE_LINE_ID           => lx_qte_line_rec.quote_line_id,
          X_Return_Status               => l_return_status,
          X_Msg_Count                   => X_Msg_Count,
          X_Msg_Data                    => X_Msg_Data );


                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.ADD ( 'Copy_Config: After line copy_sales_supplement ' || x_return_status , 1 , 'Y' );
                  END IF;


               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                 IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                  FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                  FND_MESSAGE.Set_Token ('ROW' , 'ASO_QUOTE_HEADER', TRUE );
                  FND_MSG_PUB.ADD;
                END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                x_return_status            := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
               END IF;
	     */

        END IF;  -- new version check




         IF P_Copy_Quote_Control_Rec.copy_attachment = FND_API.G_TRUE THEN
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.ADD ( 'Copy_Rows - Begin- before config  line copy_attch  ' , 1 , 'Y' );
		  END IF;

            ASO_ATTACHMENT_INT.Copy_Attachments(
                p_api_version       => l_api_version,
                p_old_object_code   => 'ASO_QUOTE_LINES_ALL',
                p_new_object_code   => 'ASO_QUOTE_LINES_ALL',
                p_old_object_id     => qte_line_id,
                p_new_object_id     => lx_qte_line_rec.quote_line_id,
                x_return_status     => x_return_status ,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data
             );
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		     aso_debug_pub.ADD ( 'Copy_Rows -After config line copy_attch ' || x_return_status , 1 , 'Y' );
		  END IF;
            IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
               IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                  FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                  FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYCONFIG AFTER_ATTACHMENTS' , TRUE );
                  FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

         END IF;

         FOR j IN 1 .. l_dup_price_adj_tbl.COUNT LOOP
            lx_price_index_link_tbl(l_dup_price_adj_tbl(j).price_adjustment_id) := lx_ln_price_adj_tbl(j).price_adjustment_id;
         END LOOP;

         lx_line_index_link_tbl(qte_line_id) := lx_qte_line_rec.quote_line_id;

-- CLOSE line_id_from_config;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.ADD('Copy_Config - l_qte_line_tbl(i).item_type_code ' || l_qte_line_rec.item_type_code , 1 , 'Y' );
            aso_debug_pub.ADD('Copy - l_qte_line_tbl(i).inventory_item_id ' || l_qte_line_rec.inventory_item_id , 1 , 'Y' );
            aso_debug_pub.ADD('Copy - l_serviceable_product_flag ' || l_serviceable_product_flag , 1 , 'Y' );
	    END IF;

         IF l_serviceable_product_flag = 'Y' THEN
            ASO_COPY_QUOTE_PVT.service_copy (
                p_qte_line_id =>                l_quote_line_id
             , p_copy_quote_control_rec =>      p_copy_quote_control_rec
             , p_new_qte_header_id =>           p_new_qte_header_id
             , p_qte_header_id =>               p_qte_header_id
             , lx_line_index_link_tbl =>        lx_line_index_link_tbl
             , lx_price_index_link_tbl =>       lx_price_index_link_tbl
             , X_Return_Status =>               x_return_status
             , X_Msg_Count =>                   x_msg_count
             , X_Msg_Data =>                    x_msg_data
             , p_line_quantity            =>  FND_API.G_MISS_NUM
             );
         END IF;
         IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
               FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYCONFIG AFTER_SERVICE' , TRUE );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      END LOOP;

      CLOSE line_id_from_config;

   END config_copy;


   PROCEDURE service_copy (
       p_qte_line_id IN NUMBER
    , p_copy_quote_control_rec IN ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type
            := ASO_COPY_QUOTE_PUB.G_MISS_Copy_Quote_Control_Rec
    , p_new_qte_header_id IN NUMBER
    , p_qte_header_id IN NUMBER
    , lx_line_index_link_tbl IN OUT NOCOPY  ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type
    , lx_price_index_link_tbl IN OUT NOCOPY  ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , p_line_quantity     IN NUMBER  := FND_API.G_MISS_NUM
   ) IS

      CURSOR line_id_from_service (
          qte_ln_id NUMBER
       ) IS
         SELECT related_quote_line_id
         FROM   aso_line_relationships
         WHERE  quote_line_id = qte_ln_id
         AND    relationship_type_code = 'SERVICE';

      l_payment_tbl ASO_QUOTE_PUB.Payment_Tbl_Type;
      l_shipment_tbl ASO_QUOTE_PUB.Shipment_Tbl_Type;
      l_shipment_rec ASO_QUOTE_PUB.Shipment_Rec_Type;
      l_freight_charge_tbl ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
      l_tax_detail_tbl ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
      l_Price_Attr_Tbl ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
      l_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
      l_Price_Adj_Attr_Tbl ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
      l_qte_line_dtl_tbl ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
      l_qte_line_rec ASO_QUOTE_PUB.Qte_Line_Rec_Type;
      l_Line_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      lx_ln_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
      lx_qte_line_rec ASO_QUOTE_PUB.Qte_Line_Rec_Type;
      l_control_rec ASO_QUOTE_PUB.Control_Rec_Type;
      LX_PRICE_ADJ_RLTSHIP_ID NUMBER;
      LX_LINE_RELATIONSHIP_ID NUMBER;
      X_hd_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      X_Sales_Credit_Tbl ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      X_Quote_Party_Tbl ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_hd_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      l_quote_party_tbl ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_quote_party_rec ASO_QUOTE_PUB.Quote_Party_rec_Type;
      l_sales_credit_tbl ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      l_sales_credit_rec ASO_QUOTE_PUB.Sales_Credit_rec_Type;
      l_service_ref_line_id NUMBER;
      l_return_status VARCHAR2 ( 1 );
      qte_line_id NUMBER;
      i NUMBER;
      j NUMBER;
      k NUMBER;
      l_api_version CONSTANT NUMBER := 1.0;

      Cursor get_qte_line_number (x_qte_line_id NUMBER)  IS
      SELECT line_number
      FROM aso_quote_lines_all
      WHERE quote_line_id = x_qte_line_id ;

      l_line_number  NUMBER;

      l_quote_party_tbl_out      ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_sales_credit_tbl_out     ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      l_tax_detail_tbl_out       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
      l_freight_charge_tbl_out   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
      l_shipment_tbl_out         ASO_QUOTE_PUB.Shipment_Tbl_Type;
      l_payment_tbl_out          ASO_QUOTE_PUB.Payment_Tbl_Type;
      l_Price_Adj_Attr_Tbl_out   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
      l_Price_Attr_Tbl_out       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
      l_qte_line_dtl_tbl_out     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
      l_Line_Attr_Ext_Tbl_out    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;

      l_dup_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;


   BEGIN

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ('Copy_Service - Begin ' , 1, 'Y' );
      aso_debug_pub.ADD ( 'Copy_Service - p_new_qte_header_id ' || p_new_qte_header_id , 1 , 'Y' );
      aso_debug_pub.ADD ( 'Copy_Service - p_qte_header_id ' || p_qte_header_id , 1 , 'Y' );
      aso_debug_pub.ADD ( 'Copy_Service - p_qte_line_id ' || p_qte_line_id , 1 , 'Y' );
	 END IF;

      x_return_status            := FND_API.G_RET_STS_SUCCESS;

      OPEN line_id_from_service ( p_qte_line_id );

      LOOP
         FETCH line_id_from_service INTO qte_line_id;
         EXIT WHEN line_id_from_service%NOTFOUND;
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Service - inside cursor qte_line_id ' || qte_line_id , 1 , 'Y' );
	    END IF;

         l_qte_line_rec             :=
                           ASO_UTILITY_PVT.Query_Qte_Line_Row ( qte_line_id );

          IF p_new_qte_header_id = p_qte_header_id THEN

           OPEN get_qte_line_number(lx_line_index_link_tbl(p_qte_line_id));
           FETCH get_qte_line_number into l_line_number;
           CLOSE get_qte_line_number;

           l_qte_line_rec.line_number := l_line_number;

          END IF;

         -- Setting the line quantity ( as per changes for split_line API )
         IF (p_line_quantity is not null ) and (p_line_quantity <>  FND_API.G_MISS_NUM ) THEN
          l_qte_line_rec.quantity := p_line_quantity;
         END IF;

	    l_qte_line_rec.quote_header_id := p_new_qte_header_id;
         l_qte_line_dtl_tbl         :=
                          ASO_UTILITY_PVT.Query_Line_Dtl_Rows ( qte_line_id );

         IF l_qte_line_dtl_tbl.COUNT > 0 THEN

            FOR k IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP

               IF l_qte_line_dtl_tbl ( k ).service_ref_type_code = 'QUOTE' THEN

                  IF l_qte_line_dtl_tbl ( k ).service_ref_line_id IS NOT NULL THEN

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
				 aso_debug_pub.ADD ( 'Copy_Service - l_qte_line_dtl_tbl(k).service_ref_line_id ' || l_qte_line_dtl_tbl ( k ).service_ref_line_id , 1 , 'Y' );
				 END IF;
                     l_service_ref_line_id      :=
                           lx_line_index_link_tbl ( l_qte_line_dtl_tbl ( k ).service_ref_line_id );
                     l_qte_line_dtl_tbl ( k ).service_ref_line_id :=
                                                        l_service_ref_line_id;
                  END IF;

               END IF;

            END LOOP;

         END IF;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Service - 2 l_service_ref_line_id ' || l_service_ref_line_id , 1 , 'Y' );
	    END IF;

         l_line_attr_Ext_Tbl := ASO_UTILITY_PVT.Query_Line_Attribs_Ext_Rows ( qte_line_id );

         l_price_adj_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Rows ( p_qte_header_id , qte_line_id );

	    l_dup_price_adj_tbl := l_price_adj_tbl;

         l_price_adj_attr_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Attr_Rows ( p_price_adj_tbl => l_price_adj_tbl );

         l_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows ( p_qte_header_id , qte_line_id );

         --l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows ( p_qte_header_id , QTE_LINE_ID );

         l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows ( p_qte_header_id , QTE_LINE_ID );

         l_sales_credit_tbl := ASO_UTILITY_PVT.Query_Sales_Credit_Row ( p_qte_header_id , QTE_LINE_ID );

         l_quote_party_tbl := ASO_UTILITY_PVT.Query_Quote_Party_Row ( p_qte_header_id , QTE_LINE_ID );

         l_freight_charge_tbl := ASO_UTILITY_PVT.Query_Freight_Charge_Rows ( l_shipment_tbl );

         l_tax_detail_tbl := ASO_UTILITY_PVT.Query_Tax_Detail_Rows ( p_qte_header_id , QTE_LINE_ID , l_shipment_tbl );

         l_qte_line_rec.quote_line_id := NULL;
         l_qte_line_rec.object_version_number := FND_API.G_MISS_NUM;


     --BC4J Fix

         FOR j IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP
	       l_qte_line_dtl_tbl(j).quote_line_detail_id := null;
            l_qte_line_dtl_tbl(j).object_version_number := FND_API.G_MISS_NUM;
	    END LOOP;

         FOR j IN 1 .. l_price_adj_tbl.COUNT LOOP
            l_price_adj_tbl ( j ).QUOTE_HEADER_ID     := p_new_qte_header_id;
            l_price_adj_tbl ( j ).price_adjustment_id := null;
		  l_price_adj_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_price_adj_attr_tbl.COUNT LOOP
            l_price_adj_attr_tbl(j).price_adj_attrib_id := null;
		  l_price_adj_attr_tbl(j).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_price_attr_tbl.COUNT LOOP
            l_price_attr_tbl ( j ).QUOTE_HEADER_ID    := p_new_qte_header_id;
            l_price_attr_tbl ( j ).price_attribute_id := null;
		  l_price_attr_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         /* FOR j IN 1 .. l_payment_tbl.COUNT LOOP
            l_payment_tbl ( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
            l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_CODE := NULL;
            l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_DATE := NULL;
            l_payment_tbl ( j ).payment_id := NULL;
		  l_payment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
         END LOOP; */

         FOR j IN 1 .. l_shipment_tbl.COUNT LOOP
            l_shipment_tbl ( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
            l_shipment_tbl ( j ).shipment_id := null;
		  l_shipment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_sales_credit_tbl.COUNT LOOP
            l_sales_credit_tbl(j).QUOTE_HEADER_ID := p_new_qte_header_id;
            l_sales_credit_tbl(j).sales_credit_id := null;
		  l_sales_credit_tbl(j).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_quote_party_tbl.COUNT LOOP
            l_quote_party_tbl(j).QUOTE_HEADER_ID  := p_new_qte_header_id;
            l_quote_party_tbl(j).QUOTE_PARTY_ID  := null;
		  l_quote_party_tbl(j).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_tax_detail_tbl.COUNT LOOP
            l_tax_detail_tbl(j).tax_detail_id  := null;
		  l_tax_detail_tbl(j).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_line_attr_Ext_Tbl.COUNT LOOP
            l_line_attr_Ext_Tbl(j).line_attribute_id  := null;
		  l_line_attr_Ext_Tbl(j).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

         FOR j IN 1 .. l_freight_charge_tbl.COUNT LOOP
            l_freight_charge_tbl(j).freight_charge_id  := null;
		  l_freight_charge_tbl(j).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;


	--End of BC4J Fix

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Service - Before insert_quote_line_rows: ' || p_qte_line_id , 1 , 'Y' );
	    END IF;
         ASO_QUOTE_LINES_PVT.Insert_Quote_Line_Rows (
             p_control_rec =>                l_control_rec
          , P_qte_Line_Rec =>                l_qte_line_rec
          , P_qte_line_dtl_tbl =>            l_qte_line_dtl_tbl
          , P_Line_Attribs_Ext_Tbl =>        l_line_attr_ext_tbl
          , P_price_attributes_tbl =>        l_price_attr_tbl
          , P_Price_Adj_Tbl =>               l_price_adj_tbl
          , P_Price_Adj_Attr_Tbl =>          l_Price_Adj_Attr_Tbl
          , P_Payment_Tbl =>                 ASO_QUOTE_PUB.g_miss_payment_tbl
          , P_Shipment_Tbl =>                l_shipment_tbl
          , P_Freight_Charge_Tbl =>          l_freight_charge_tbl
          , P_Tax_Detail_Tbl =>              l_tax_detail_tbl
          , P_Sales_Credit_Tbl =>            l_sales_credit_tbl
          , P_Quote_Party_Tbl =>             l_quote_party_tbl
		, x_qte_Line_Rec =>                lx_qte_line_rec
          , x_qte_line_dtl_tbl =>            l_qte_line_dtl_tbl_out
          , x_Line_Attribs_Ext_Tbl =>        l_line_attr_Ext_Tbl_out
          , x_price_attributes_tbl =>        l_price_attr_tbl_out
          , x_Price_Adj_Tbl =>               lx_ln_price_adj_tbl
          , x_Price_Adj_Attr_Tbl =>          l_Price_Adj_Attr_Tbl_out
          , x_Payment_Tbl =>                 l_payment_tbl_out
          , x_Shipment_Tbl =>                l_shipment_tbl_out
          , x_Freight_Charge_Tbl =>          l_freight_charge_tbl_out
          , x_Tax_Detail_Tbl =>              l_tax_detail_tbl_out
          , X_Sales_Credit_Tbl =>            l_sales_credit_tbl_out
          , X_Quote_Party_Tbl =>             l_quote_party_tbl_out
          , X_Return_Status =>               l_return_status
          , X_Msg_Count =>                   x_msg_count
          , X_Msg_Data =>                    x_msg_data
          );

      l_quote_party_tbl :=l_quote_party_tbl_out ;
      l_sales_credit_tbl :=l_sales_credit_tbl_out ;
      l_tax_detail_tbl := l_tax_detail_tbl_out    ;
      l_freight_charge_tbl := l_freight_charge_tbl_out  ;
      l_shipment_tbl := l_shipment_tbl_out   ;
      l_payment_tbl := l_payment_tbl_out     ;
      l_Price_Adj_Attr_Tbl  := l_Price_Adj_Attr_Tbl_out  ;
      l_Price_Attr_Tbl  :=  l_Price_Attr_Tbl_out     ;
      l_qte_line_dtl_tbl := l_qte_line_dtl_tbl_out   ;
      l_Line_Attr_Ext_Tbl  :=  l_Line_Attr_Ext_Tbl_out;



         IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
               FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYSERVICE AFTER_INSERT' , TRUE );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;


      -- Copy the payment record
    l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows ( p_qte_header_id , QTE_LINE_ID );

    IF l_payment_tbl.count > 0 then

         FOR j IN 1 .. l_payment_tbl.COUNT LOOP
            l_payment_tbl ( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
            l_payment_tbl ( j ).QUOTE_LINE_ID := lx_qte_line_rec.quote_line_id;
            l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_CODE := NULL;
            l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_DATE := NULL;
            l_payment_tbl ( j ).payment_id := NULL;
            l_payment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
         END LOOP;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Service_Copy: Before  call to copy_payment_row ', 1, 'Y');
       END IF;

         aso_copy_quote_pvt.copy_payment_row(p_payment_rec => l_payment_tbl(1)  ,
                                             x_return_status => l_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Service_Copy:: After call to copy_payment_row: x_return_status: '||l_return_status, 1, 'Y');
       END IF;
      IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
            FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYSERVICE AFTER_INSERT' , TRUE );
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF;
     --  End Copy payment record

         -- Copying the sales supplement data for the line
      IF ( P_Copy_Quote_Control_Rec.New_Version = FND_API.G_TRUE ) THEN

                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.ADD ( 'Copy_Rows - Begin- before line copy_sales_supplement  ' , 1 , 'Y' );
                 END IF;

          ASO_COPY_QUOTE_PVT.INSERT_SALES_SUPP_DATA
          (
          P_Api_Version_Number          =>  1.0,
          P_Init_Msg_List               => FND_API.G_FALSE,
          P_Commit                      => FND_API.G_FALSE,
          P_OLD_QUOTE_LINE_ID           => qte_line_id,
          P_NEW_QUOTE_LINE_ID           => lx_qte_line_rec.quote_line_id,
          X_Return_Status               => l_return_status,
          X_Msg_Count                   => X_Msg_Count,
          X_Msg_Data                    => X_Msg_Data );


                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.ADD ( 'Copy_Rows -After line copy_sales_supplement ' || x_return_status , 1 , 'Y' );
                  END IF;


               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                 IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                  FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                  FND_MESSAGE.Set_Token ('ROW' , 'ASO_QUOTE_HEADER', TRUE );
                  FND_MSG_PUB.ADD;
                END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                x_return_status            := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
               END IF;
        END IF;  -- new version check



         IF P_Copy_Quote_Control_Rec.copy_attachment = FND_API.G_TRUE THEN
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.ADD ( 'Copy_Rows - Begin- before config  line copy_attch  ' , 1 , 'Y' );
		  END IF;

            ASO_ATTACHMENT_INT.Copy_Attachments (
                p_api_version       => l_api_version,
                p_old_object_code   => 'ASO_QUOTE_LINES_ALL',
                p_new_object_code   => 'ASO_QUOTE_LINES_ALL',
                p_old_object_id     => qte_line_id,
                p_new_object_id     => lx_qte_line_rec.quote_line_id,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data
             );
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.ADD ( 'Copy_Rows -After config line copy_attch ' || x_return_status , 1 , 'Y' );
		  END IF;
            IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
               IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                  FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                  FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYSERVICE AFTER_ATTACHMENTS' , TRUE );
                  FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

         END IF;

         FOR j IN 1 .. l_dup_price_adj_tbl.COUNT LOOP
            lx_price_index_link_tbl(l_dup_price_adj_tbl(j).price_adjustment_id) := lx_ln_price_adj_tbl(j).price_adjustment_id;
         END LOOP;

         lx_line_index_link_tbl ( qte_line_id ) := lx_qte_line_rec.quote_line_id;

      END LOOP;

      CLOSE line_id_from_service;

   END service_copy;


   PROCEDURE Get_Quote_Exp_Date (
       X_Quote_Exp_Date OUT NOCOPY /* file.sql.39 change */   DATE
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    ) IS

      CURSOR C_Get_Expiration_Date (
          l_Def_Cal VARCHAR2
       , l_Def_Per VARCHAR2
       ) IS
         SELECT End_Date
         FROM   GL_PERIODS_V
         WHERE  Period_Type = l_Def_Per
         AND    Period_Set_Name = l_Def_Cal
         AND    SYSDATE BETWEEN Start_Date AND End_Date;

      l_Default_Cal_Prof VARCHAR2 ( 15 )
                            := FND_PROFILE.VALUE ('ASO_DEFAULT_EXP_GL_CAL' );
      l_Default_Per_Prof VARCHAR2 ( 15 )
                         := FND_PROFILE.VALUE ('ASO_DEFAULT_EXP_GL_PERIOD' );
      l_qte_duration_prof NUMBER
                                := FND_PROFILE.VALUE ('ASO_QUOTE_DURATION' );

   BEGIN

      X_Return_Status            := FND_API.G_RET_STS_SUCCESS;

      IF      l_Default_Cal_Prof IS NOT NULL
          AND l_Default_Per_Prof IS NOT NULL THEN

         OPEN C_Get_Expiration_Date (
             l_Default_Cal_Prof
          , l_Default_Per_Prof
          );
         FETCH C_Get_Expiration_Date INTO X_Quote_Exp_Date;

         IF C_Get_Expiration_Date%NOTFOUND THEN

            IF l_qte_duration_prof IS NOT NULL THEN
               X_Quote_Exp_Date           :=   SYSDATE + l_qte_duration_prof;
            ELSE
              /* If profile ASO_QUOTE_DURATION is null, then exp date is sysdate + 30
			see bug 3704719 for more detaisl */
		    X_Quote_Exp_Date := sysdate + NVL(FND_PROFILE.value('ASO_QUOTE_DURATION'), 30);
            END IF;

         END IF;

         CLOSE C_Get_Expiration_Date;

      ELSE

         IF l_qte_duration_prof IS NOT NULL THEN
            X_Quote_Exp_Date           :=   SYSDATE + l_qte_duration_prof;
         ELSE
              /* If profile ASO_QUOTE_DURATION is null, then exp date is sysdate + 30
               see bug 3704719 for more detaisl */
		  X_Quote_Exp_Date := sysdate + NVL(FND_PROFILE.value('ASO_QUOTE_DURATION'), 30);
         END IF;

      END IF;

   END Get_Quote_Exp_Date;


   PROCEDURE COPY_SALES_SUPPLEMENT (
       P_Api_Version_Number IN NUMBER
    , P_Init_Msg_List IN VARCHAR2 := FND_API.G_FALSE
    , P_Commit IN VARCHAR2 := FND_API.G_FALSE
    , p_old_quote_header_id IN NUMBER
    , p_new_quote_header_id IN NUMBER
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    ) IS

      CURSOR get_template_id (
          qte_header_id NUMBER
       ) IS
         SELECT template_instance_id, template_id
         FROM   aso_sup_tmpl_instance
         WHERE  owner_table_name = 'ASO_QUOTE_HEADERS'
         AND    owner_table_id = qte_header_id;

      CURSOR get_values (
          temp_instance_id NUMBER
       ) IS
         SELECT sect_comp_map_id, VALUE, value_type_qualifier, response_id,
	        rtfdata                -- Code added for Bug 13083656
         FROM   aso_sup_instance_value
         WHERE  template_instance_id = temp_instance_id;

      l_old_template_instance_id NUMBER;
      l_new_template_instance_id NUMBER;
      l_sup_instance_rowid ROWID;
      l_template_instance_rowid ROWID;
      l_instance_value_id NUMBER;
      l_old_instance_value_id NUMBER;
      l_api_name VARCHAR2 ( 50 ) := 'COPY_SALES_SUPPLEMENT';
      l_api_version_number CONSTANT NUMBER := 1.0;

   BEGIN

-- Establish a standard save point
      SAVEPOINT COPY_SALES_SUPPLEMENT_PVT;

-- Standard call to check for call compatability
      IF NOT FND_API.Compatible_API_Call (
                 l_api_version_number
              , p_api_version_number
              , l_api_name
              , G_PKG_NAME
              ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean ( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

-- API BODY
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ('COPY_SALES_SUPPLEMENT API: Begin' , 1, 'N' );
      aso_debug_pub.ADD ( 'Old Qte Header Id : ' || TO_CHAR ( p_old_quote_header_id ) , 1 , 'N' );
      aso_debug_pub.ADD ( 'New Qte Header Id : ' || TO_CHAR ( p_new_quote_header_id ) , 1 , 'N' );
	 END IF;

-- Get the template id's  and template_instance_id's based upon the
-- quote header id

      FOR template_val IN get_template_id ( p_old_quote_header_id ) LOOP
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Template Id : ' || TO_CHAR ( template_val.template_id ) , 1 , 'N' );
         aso_debug_pub.ADD ( ' Old Template Instance Id : ' || TO_CHAR ( template_val.template_instance_id ) , 1 , 'N' );

         -- Create a new row in the ASO_SUP_TMPL_INSTANCE Table with the template id

         aso_debug_pub.ADD ( 'Inserting a row into tmpl_instance table' , 1 , 'N' );
	    END IF;

         -- Initiate the variable to null,
         -- so that each time they contain new value for every pass of loop

         l_new_template_instance_id := NULL;
         ASO_SUP_TMPL_INSTANCE_PKG.INSERT_ROW (
             PX_ROWID =>                     l_template_instance_rowid
          , PX_TEMPLATE_INSTANCE_ID =>       l_new_template_instance_id
          , P_created_by =>                  FND_GLOBAL.USER_ID
          , P_creation_date =>               SYSDATE
          , P_last_updated_by =>             FND_GLOBAL.USER_ID
          , P_last_update_date =>            SYSDATE
          , P_last_update_login =>           FND_GLOBAL.CONC_LOGIN_ID
          , P_TEMPLATE_ID =>                 template_val.template_id
          , P_Owner_Table_Name =>            'ASO_QUOTE_HEADERS'
          , P_Owner_Table_Id =>              p_new_quote_header_id
		, P_OBJECT_VERSION_NUMBER =>       FND_API.G_MISS_NUM
          );
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( ' New Template Instance Id : ' || TO_CHAR ( l_new_template_instance_id ) , 1 , 'N' );
	    END IF;

         -- Get the values for that instance
         FOR inst_val IN get_values ( template_val.template_instance_id ) LOOP
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.ADD (   'Value : ' || inst_val.VALUE, 1, 'N' );
            aso_debug_pub.ADD ( 'Value Type Qualifier : ' || inst_val.value_type_qualifier , 1 , 'N' );
            aso_debug_pub.ADD ( 'Response Id : ' || TO_CHAR ( inst_val.response_id ) , 1 , 'N' );
		  END IF;

            -- If values are fetched then insert rows
            IF inst_val.sect_comp_map_id IS NOT NULL THEN
               -- Initiate the variables to null,
               -- so that each time they contain new value for every pass of loop

               l_instance_value_id        := NULL;
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Inserting a row into instance_value table' , 1 , 'N' );
			END IF;

               -- Create a new row in the ASO_SUP_INSTANCE_VALUE table
               ASO_SUP_INSTANCE_VALUE_PKG.INSERT_ROW (
                   PX_ROWID =>                     l_sup_instance_rowid
                , PX_INSTANCE_VALUE_ID =>          l_instance_value_id
                , P_SECT_COMP_MAP_ID =>            inst_val.sect_comp_map_id
                , P_Template_Instance_ID =>        l_new_template_instance_id
                , p_value =>                       inst_val.VALUE
                , p_value_type_qualifier =>        inst_val.value_type_qualifier
                , p_response_id =>                 inst_val.response_id
                , P_created_by =>                  FND_GLOBAL.USER_ID
                , P_last_updated_by =>             FND_GLOBAL.USER_ID
                , P_last_update_login =>           FND_GLOBAL.CONC_LOGIN_ID
			 , P_OBJECT_VERSION_NUMBER =>       FND_API.G_MISS_NUM
                );
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'New Instance Value Id : ' || TO_CHAR ( l_instance_value_id ) , 1 , 'N' );
			END IF;
            END IF;

	        If inst_val.rtfdata Is Not Null Then

	          /* Start : Code Added for Bug 13083656 */
	          Update aso_sup_instance_value
                  Set rtfdata = inst_val.rtfdata
	          Where instance_value_id = l_instance_value_id;
	          /* End : Code Added for Bug 13083656 */

	        End If;

         END LOOP; -- instance value loop

      END LOOP; -- template loop

      -- Standard check for p_commit
      IF FND_API.to_Boolean ( p_commit ) THEN
         COMMIT WORK;
      END IF;

--  Initialize API return status to success
      x_return_status            := FND_API.G_RET_STS_SUCCESS;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'COPY_SALES_SUPPLEMENT API: ' || l_api_name || 'end' , 1 , 'N' );
	 END IF;

   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_SQLCODE =>                     SQLCODE
          , P_SQLERRM =>                     SQLERRM
          , P_EXCEPTION_LEVEL =>             ASO_UTILITY_PVT.G_EXC_OTHERS
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

   END COPY_SALES_SUPPLEMENT;



PROCEDURE Copy_Opp_Quote(
           p_api_version_number  IN NUMBER := 1.0,
           p_qte_header_id       IN NUMBER,
           p_new_qte_header_id   IN NUMBER,
           X_Return_Status       OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
           X_Msg_Count           OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
           X_Msg_Data            OUT NOCOPY /* file.sql.39 change */   VARCHAR2
         )
IS

   CURSOR C_Get_Opp_From_Hdr (qte_hdr NUMBER) IS
    SELECT request_id, program_application_id, program_id, program_update_date,
           quote_object_type_code, quote_object_id, object_type_code, object_id,
           relationship_type_code, reciprocal_flag
    FROM ASO_QUOTE_RELATED_OBJECTS
    WHERE relationship_type_code = 'OPP_QUOTE'
      AND quote_object_id = qte_hdr;

   l_related_obj_rec     ASO_quote_PUB.RELATED_OBJ_Rec_Type  := ASO_quote_PUB.G_MISS_RELATED_OBJ_REC;
   l_related_obj_id      NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.ADD ( 'Copy_Opp_Quote: p_qte_header_id: ' || p_qte_header_id, 1 , 'N' );
aso_debug_pub.ADD ( 'Copy_Opp_Quote: p_new_qte_header_id: ' || p_new_qte_header_id, 1 , 'N' );
END IF;

   OPEN C_Get_Opp_From_Hdr (p_qte_header_id);
   FETCH C_Get_Opp_From_Hdr INTO l_related_obj_rec.request_id, l_related_obj_rec.program_application_id,
         l_related_obj_rec.program_id, l_related_obj_rec.program_update_date,
         l_related_obj_rec.quote_object_type_code, l_related_obj_rec.quote_object_id,
         l_related_obj_rec.object_type_code, l_related_obj_rec.object_id,
         l_related_obj_rec.relationship_type_code, l_related_obj_rec.reciprocal_flag;
   IF C_Get_Opp_From_Hdr%NOTFOUND THEN
IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.ADD ( 'Copy_Opp_Quote: Not from Opportunity ', 1 , 'N' );
END IF;
       CLOSE C_Get_Opp_From_Hdr;
       RETURN;
   END IF;
   CLOSE C_Get_Opp_From_Hdr;

   l_related_obj_rec.quote_object_id := p_new_qte_header_id;


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.ADD ( 'Copy_Opp_Quote: before insert rel object ', 1 , 'N' );
END IF;
      aso_related_obj_pvt.create_related_obj (
        p_api_version_number         => 1.0,
        p_validation_level           => fnd_api.g_valid_level_none,
        p_related_obj_rec            => l_related_obj_rec,
        x_related_object_id          => l_related_obj_id,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data
      );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.ADD ( 'Copy_Opp_Quote: after insert_rel_object:x_return_status: ' || x_return_status, 1 , 'N' );
END IF;
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name ( 'ASO', 'ASO_API_ERROR_IN_CREATING_RLTSHIPS');
          fnd_msg_pub.ADD;
        END IF;

      END IF;


END Copy_Opp_Quote;

PROCEDURE Split_Model_Line (
    P_Api_Version_Number   IN NUMBER,
    P_Init_Msg_List        IN VARCHAR2     := FND_API.G_FALSE,
    P_Commit               IN VARCHAR2     := FND_API.G_FALSE,
    P_Control_Rec            IN   ASO_QUOTE_PUB.Control_Rec_Type,
    P_Qte_Header_Rec         IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    P_Original_Qte_Line_Rec  IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    P_Qte_Line_Tbl         IN ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Quote_Line_Tbl       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
    X_Return_Status        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Count            OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    X_Msg_Data             OUT NOCOPY /* file.sql.39 change */    VARCHAR2 )

IS

      CURSOR C_Validate_Quote (
          x_qte_header_id NUMBER
       ) IS
         SELECT 'X'
         FROM   ASO_QUOTE_HEADERS_ALL
         WHERE  quote_header_id = x_qte_header_id;

      CURSOR C_Validate_Quote_Line (
          x_qte_header_id NUMBER,
          x_qte_line_id NUMBER
       ) IS
         SELECT 'X'
         FROM   ASO_QUOTE_LINES_ALL
         WHERE  quote_header_id = x_qte_header_id
         AND quote_line_id = x_qte_line_id;


      CURSOR C_Serviceable_Product (
          l_organization_id NUMBER
       , l_inv_item_id NUMBER
       ) IS
         SELECT serviceable_product_flag, service_item_flag
         FROM   MTL_SYSTEM_ITEMS_VL
         WHERE  inventory_item_id = l_inv_item_id
         AND    organization_id = l_organization_id;


      CURSOR c_price_adj_rel (
            x_quote_line_id NUMBER
       ) IS
         SELECT apr.ADJ_RELATIONSHIP_ID, apr.CREATION_DATE, apr.CREATED_BY
              , apr.LAST_UPDATE_DATE, apr.LAST_UPDATED_BY
              , apr.LAST_UPDATE_LOGIN, apr.PROGRAM_APPLICATION_ID
              , apr.PROGRAM_ID, apr.PROGRAM_UPDATE_DATE, apr.REQUEST_ID
              , apr.QUOTE_LINE_ID, apr.PRICE_ADJUSTMENT_ID
              , apr.RLTD_PRICE_ADJ_ID, apr.OBJECT_VERSION_NUMBER
         FROM   ASO_PRICE_ADJ_RELATIONSHIPS apr
              , ASO_PRICE_ADJUSTMENTS apa

         WHERE  apr.price_adjustment_id = apa.price_adjustment_id
         AND    apr.quote_line_id = x_quote_line_id
         AND    apa.quote_line_id = x_quote_line_id
         AND    apa.modifier_line_type_code <> 'PRG';


    CURSOR C_Get_Ship_Id (
          lc_line_id NUMBER
       ) IS
         SELECT shipment_id
         FROM   ASO_SHIPMENTS
         WHERE  quote_line_id = lc_line_id;


      CURSOR c_line_relation (
          x_quote_line_id NUMBER
       ) IS
         SELECT LINE_RELATIONSHIP_ID, CREATION_DATE, CREATED_BY
              , LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN
              , REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID
              , PROGRAM_UPDATE_DATE, QUOTE_LINE_ID, RELATED_QUOTE_LINE_ID
              , RELATIONSHIP_TYPE_CODE, RECIPROCAL_FLAG, OBJECT_VERSION_NUMBER
         FROM   ASO_LINE_RELATIONSHIPS
         WHERE  relationship_type_code <> 'SERVICE'
	    CONNECT BY PRIOR related_quote_line_id = quote_line_id
         START WITH quote_line_id = x_quote_line_id;

    CURSOR get_latest_date (
      c_quote_header_id                    NUMBER
    ) IS
      SELECT last_update_date
      FROM aso_quote_headers_all
      WHERE quote_header_id = c_quote_header_id;


    Cursor Get_Max_Line_Number ( c_QUOTE_HEADER_ID Number) IS
    Select Max(Line_number)
    From ASO_QUOTE_LINES_ALL
    WHERE quote_header_id = c_QUOTE_HEADER_ID;

    x_qte_header_rec              aso_quote_pub.qte_header_rec_type;
    x_qte_line_tbl                aso_quote_pub.qte_line_tbl_type;
    x_qte_line_dtl_tbl            aso_quote_pub.qte_line_dtl_tbl_type;
    x_hd_price_attributes_tbl     aso_quote_pub.price_attributes_tbl_type;
    x_hd_payment_tbl              aso_quote_pub.payment_tbl_type;
    x_hd_shipment_tbl             aso_quote_pub.shipment_tbl_type;
    x_hd_freight_charge_tbl       aso_quote_pub.freight_charge_tbl_type;
    x_hd_tax_detail_tbl           aso_quote_pub.tax_detail_tbl_type;
    x_line_attr_ext_tbl           aso_quote_pub.line_attribs_ext_tbl_type;
    x_line_rltship_tbl            aso_quote_pub.line_rltship_tbl_type;
    x_price_adjustment_tbl        aso_quote_pub.price_adj_tbl_type;
    x_price_adj_attr_tbl          aso_quote_pub.price_adj_attr_tbl_type;
    x_price_adj_rltship_tbl       aso_quote_pub.price_adj_rltship_tbl_type;
    x_ln_price_attributes_tbl     aso_quote_pub.price_attributes_tbl_type;
    x_ln_payment_tbl              aso_quote_pub.payment_tbl_type;
    x_ln_shipment_tbl             aso_quote_pub.shipment_tbl_type;
    x_ln_freight_charge_tbl       aso_quote_pub.freight_charge_tbl_type;
    x_ln_tax_detail_tbl           aso_quote_pub.tax_detail_tbl_type;
    l_qte_line_tbl ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_line_number                 NUMBER;

   l_val                       VARCHAR2 ( 1 );
   l_qte_line_rec              ASO_QUOTE_PUB.qte_line_rec_Type;
   l_qte_line_detail_tbl       ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
   l_qte_shipment_dtl_tbl      ASO_QUOTE_PUB.Shipment_Tbl_Type;
   l_quantity                  NUMBER := 0;
   l_remaining_quantity        NUMBER := 0;
   l_return_value              Varchar2(1);

      l_line_index_link_tbl ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type;
      l_old_config_header_id NUMBER;
      l_old_config_revision_num NUMBER;
      l_config_hdr_id NUMBER;
      l_config_rev_nbr NUMBER;
      l_return_status VARCHAR2 ( 1 );
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_api_version CONSTANT NUMBER := 1.0;
      l_service_item_flag VARCHAR2 ( 1 );
      l_serviceable_product_flag VARCHAR2 ( 1 );
      l_Line_Attr_Ext_Tbl ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      l_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
      l_Price_Attr_Tbl ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
      l_Price_Adj_Attr_Tbl ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
      l_payment_tbl ASO_QUOTE_PUB.Payment_Tbl_Type;
      l_shipment_tbl ASO_QUOTE_PUB.Shipment_Tbl_Type;
      l_sales_credit_tbl ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      l_quote_party_tbl ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_freight_charge_tbl ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
      l_tax_detail_tbl ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
      lx_ln_Price_Adj_Tbl ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
      lx_qte_line_rec ASO_QUOTE_PUB.Qte_Line_Rec_Type;
      l_control_rec ASO_QUOTE_PUB.Control_Rec_Type;
      l_config_control_rec ASO_CFG_INT.Control_Rec_Type
                                            := ASO_CFG_INT.G_MISS_Control_Rec;
     l_Copy_Quote_Control_Rec ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type;
      LX_PRICE_ADJ_RLTSHIP_ID NUMBER;
      LX_LINE_RELATIONSHIP_ID NUMBER;
     G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
      G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
      l_ship_id NUMBER;
    --  l_appl_param_rec   CZ_API_PUB.appl_param_rec_type;
      l_price_index_link_tbl ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type;

      l_quote_header_rec          ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec;
      l_api_name varchar2(50) := 'Split_Model_Line';
      TYPE inserted_qte_line_Rec_Type IS RECORD
      (
       quote_line_id         NUMBER:= FND_API.G_MISS_NUM,
       quantity              NUMBER := FND_API.G_MISS_NUM
      );

      TYPE  inserted_qte_line_Tbl_Type      IS TABLE OF inserted_qte_line_Rec_Type INDEX BY BINARY_INTEGER;

      G_MISS_inserted_qte_line_Rec   inserted_qte_line_Rec_Type;
      G_MISS_inserted_qte_line_tbl   inserted_qte_line_tbl_type;
      l_inserted_qte_line_tbl  inserted_qte_line_Tbl_Type := G_MISS_inserted_qte_line_tbl;

      l_total_lines NUMBER := 0;

      l_qty_qte_line_tbl ASO_QUOTE_PUB.Qte_Line_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Qte_Line_Tbl;
      l_orig_item_id_tbl CZ_API_PUB.number_tbl_type;
      l_new_item_id_tbl CZ_API_PUB.number_tbl_type;
      -- hyang: for bug 2692785
      lx_status                     VARCHAR2(1);

      l_quote_party_tbl_out      ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_sales_credit_tbl_out     ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      l_tax_detail_tbl_out       ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
      l_freight_charge_tbl_out   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
      l_shipment_tbl_out         ASO_QUOTE_PUB.Shipment_Tbl_Type;
      l_payment_tbl_out          ASO_QUOTE_PUB.Payment_Tbl_Type;
      l_Price_Adj_Attr_Tbl_out   ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
      l_Price_Attr_Tbl_out       ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
      l_qte_line_detail_tbl_out  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
      l_Line_Attr_Ext_Tbl_out    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;

      l_dup_Price_Adj_Tbl        ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
      l_ato_model                VARCHAR2(1) := FND_API.G_FALSE;


  BEGIN

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.ADD ( 'SPLIT_MODEL_LINE - Begin- ASO_COPY_QUOTE_PVT.SPLIT_MODEL_LINE ' , 1 , 'Y' );
	END IF;
      -- Standard Start of API savepoint
      SAVEPOINT SPLIT_MODEL_LINE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
                 l_api_version_number
              , p_api_version_number
              , l_api_name
              , G_PKG_NAME
              ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean ( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;
      -- Debug Message
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW ) THEN
         FND_MESSAGE.Set_Name ('ASO' , 'Copy Quote API: Start' );
         FND_MSG_PUB.ADD;
      END IF;

      --  Initialize API return status to success
      x_return_status            := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--
-- Validating the qte_header_id

    -- hyang: for bug 2692785
    ASO_CONC_REQ_INT.Lock_Exists(
      p_quote_header_id => P_Qte_Header_Rec.quote_header_id,
      x_status          => lx_status);

    IF (lx_status = FND_API.G_TRUE) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.ADD ( 'SPLIT_MODEL_LINE - Vaildating the quote ' , 1 , 'Y' );
   END IF;

      OPEN C_Validate_Quote ( P_Qte_Header_Rec.quote_header_id);
      FETCH C_Validate_Quote INTO l_val;

      IF C_Validate_Quote%NOTFOUND THEN

         x_return_status            := FND_API.G_RET_STS_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
            FND_MESSAGE.Set_Token ('COLUMN' , 'ORIGINAL_QUOTE_ID', FALSE );
            FND_MESSAGE.Set_Token ( 'VALUE' , TO_CHAR ( P_Qte_Header_Rec.quote_header_id ) , FALSE );
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE C_Validate_Quote;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      CLOSE C_Validate_Quote;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( 'SPLIT_MODEL_LINE - After Validating the Quote  ' , 1 , 'N' );
    END IF;
 -- Validating if the quote_line_id belongs to the qte_header_id

      OPEN C_Validate_Quote_Line ( P_Qte_Header_Rec.quote_header_id, P_Original_Qte_Line_Rec.quote_line_id);
      FETCH C_Validate_Quote_Line INTO l_val;
      IF C_Validate_Quote_Line%NOTFOUND THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_INVALID_ID' );
            FND_MESSAGE.Set_Token ('COLUMN' , 'ORIGINAL_QUOTE_ID', FALSE );
            FND_MESSAGE.Set_Token ( 'VALUE' , TO_CHAR ( P_Original_Qte_Line_Rec.quote_line_id ) , FALSE );
            FND_MSG_PUB.ADD;
         END IF;
         CLOSE C_Validate_Quote_Line;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      CLOSE C_Validate_Quote_Line;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( 'SPLIT_MODEL_LINE - After Validating the Quote Line  ' , 1 , 'N' );
    END IF;

      -- Getting the quote line record
      l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row ( P_Original_Qte_Line_Rec.quote_line_id );

    -- Getting the quote line detail record
      l_qte_line_detail_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows ( P_Original_Qte_Line_Rec.quote_line_id );

    -- Getting the shipment details for the quote line
      l_qte_shipment_dtl_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows (P_Qte_Header_Rec.quote_header_id, P_Original_Qte_Line_Rec.quote_line_id );


    -- Copy the Qte line table to the local variable
    For i in 1..P_Qte_Line_Tbl.count LOOP

     l_qty_qte_line_tbl(i).quantity := P_Qte_Line_Tbl(i).quantity;

    END LOOP;


    -- Looping through the quantity list to get the total quantity
     For i in 1..l_qty_qte_line_tbl.count LOOP

     l_quantity := l_quantity +  l_qty_qte_line_tbl(i).quantity;

     END LOOP;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( 'SPLIT_MODEL_LINE - Total Qty Passed =  '||to_char(l_quantity) , 1 , 'N' );
    END IF;


   -- If quantity list total is less than quote line quantity

   IF l_quantity < l_qte_line_rec.quantity THEN

      -- storing the remaining quantity
     l_remaining_quantity := l_qte_line_rec.quantity - l_quantity;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.ADD ( 'SPLIT_MODEL_LINE - Remaining Qty =  '||to_char(l_remaining_quantity) , 1 , 'N' );
	END IF;

	l_qty_qte_line_tbl( l_qty_qte_line_tbl.count + 1 ).quantity  := l_remaining_quantity;

   ELSIF l_quantity > l_qte_line_rec.quantity THEN

    x_return_status            := FND_API.G_RET_STS_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN


     FND_MESSAGE.Set_Name('ASO', 'ASO_ERR_SPLITLINE_QTY');
     FND_MESSAGE.Set_Token('TBLNAME', 'p_qte_line_tbl', FALSE);
     FND_MESSAGE.Set_Token('VALUE', p_qte_line_tbl(1).quantity, FALSE);
     FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.G_EXC_ERROR;

   END IF;

   -- Check to see if the item is a component
   IF l_qte_line_rec.item_type_code <> 'MDL' then

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'SPLIT_MODEL_LINE - Item is not a Model Item', 1 , 'N' );
	 END IF;
      x_return_status            := FND_API.G_RET_STS_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_CANNOT_SPLIT' );
     FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.G_EXC_ERROR;

  END IF;


   -- Check to see if the item is a service item
   IF l_qte_line_rec.service_item_flag  = 'Y'  THEN

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'SPLIT_MODEL_LINE - Item is Service  Item', 1 , 'N' );
	 END IF;
      x_return_status            := FND_API.G_RET_STS_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_CANNOT_SPLIT' );
     FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.G_EXC_ERROR;

  END IF;




/*
 -- Validating if the  item is a container item
     l_appl_param_rec.calling_application_id := 769;

        cz_network_api_pub.is_container(p_api_version  => 1.0
                                       ,p_inventory_item_id  => l_qte_line_rec.inventory_item_id
                                       ,p_organization_id   => l_qte_line_rec.organization_id
                                       ,p_appl_param_rec => l_appl_param_rec
                                       ,x_return_value       => l_return_value
                                       ,x_return_status      => l_return_status
                                       ,x_msg_count          => x_msg_count
                                       ,x_msg_data           => x_msg_data  );

           IF ( l_return_status = FND_API.G_RET_STS_SUCCESS  ) THEN

              IF l_return_value = 'Y' THEN
               x_return_status            := FND_API.G_RET_STS_ERROR;
               IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                FND_MESSAGE.Set_Name ('ASO' , 'ASO_CON_ITM_ERR' );
                FND_MSG_PUB.ADD;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
              END IF;

           ELSE
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_CONFIG_COPY' , TRUE );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

           END IF;
*/

 IF l_qte_line_rec.line_category_code = 'RETURN' THEN
   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.ADD ('l_qte_line_dtl_tbl.count' , 1, 'N' );
   aso_debug_pub.ADD ( 'SPLIT_MODEL_LINE - Line Category Code is RETURN ', 1 , 'N' );
   END IF;

     IF l_qte_line_detail_tbl.count > 0 THEN

     IF ( l_qte_line_detail_tbl(1).RETURN_REF_TYPE = 'SALES ORDER' AND
          l_qte_line_detail_tbl(1).RETURN_REF_LINE_ID IS NOT NULL AND
          l_qte_line_detail_tbl(1).INSTANCE_ID IS NOT NULL )
     OR ( l_qte_line_detail_tbl(1).REF_TYPE_CODE = 'TOP_MODEL' ) THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;

         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_CANNOT_SPLIT' );
            FND_MSG_PUB.ADD;
         END IF;

     END IF;

    END IF;

 END IF;


  IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.ADD ( 'SPLIT_MODEL_LINE - Line Tbl Count = '||to_char(l_qty_qte_line_tbl.count), 1 , 'N' );
  END IF;
     -- Copying the line
     For i in 1..l_qty_qte_line_tbl.count-1  LOOP

        -- set the quantity for the line rec record
        --l_qte_line_rec.quantity := l_qty_qte_line_tbl(i).quantity;
        l_qte_line_rec.quote_header_id := P_Qte_Header_Rec.quote_header_id;

         IF l_qte_line_rec.uom_code = 'ENR' THEN
            x_return_status            := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
               FND_MESSAGE.Set_Name ('ASO' , 'ASO_CANNOT_COPY_EDU' );
               FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         -- Initializing the line index table
         l_line_index_link_tbl (P_Original_Qte_Line_Rec.quote_line_id ) :=  FND_API.G_MISS_NUM;

         IF l_line_index_link_tbl ( P_Original_Qte_Line_Rec.quote_line_id ) = FND_API.G_MISS_NUM THEN
            l_qte_line_detail_tbl         :=
                        ASO_UTILITY_PVT.Query_Line_Dtl_Rows ( P_Original_Qte_Line_Rec.quote_line_id );

            IF l_qte_line_rec.item_type_code = 'MDL' THEN

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.ADD ( 'item_type_code = ' || l_qte_line_rec.item_type_code , 1 , 'N' );
		   END IF;

                IF l_qte_line_detail_tbl.COUNT > 0 THEN

                  IF      l_qte_line_detail_tbl ( 1 ).config_header_id IS NOT NULL
                      AND l_qte_line_detail_tbl ( 1 ).config_revision_num IS NOT NULL THEN

                     l_config_control_rec.new_config_flag := FND_API.G_TRUE;

                     IF (l_qte_line_detail_tbl(1).ato_line_id is not null and l_qte_line_detail_tbl(1).ato_line_id <> fnd_api.g_miss_num) then
                        l_ato_model := fnd_api.g_true;
                     end if;

		   IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.ADD ( ' Calling Copy Configuration ', 1 , 'N' );
		   END IF;

                     ASO_CFG_INT.Copy_Configuration (
                         P_Api_version_NUmber =>         1.0
                      , P_config_header_id =>            l_qte_line_detail_tbl ( 1 ).config_header_id
                      , p_config_revision_num =>         l_qte_line_detail_tbl ( 1 ).config_revision_num
                      , p_copy_mode =>                   CZ_API_PUB.G_NEW_HEADER_COPY_MODE
                      , x_config_header_id =>            l_config_hdr_id
                      , x_config_revision_num =>         l_config_rev_nbr
                      , x_orig_item_id_tbl =>            l_orig_item_id_tbl
                      , x_new_item_id_tbl =>             l_new_item_id_tbl
                      , x_return_status =>               l_return_status
                      , x_msg_count =>                   x_msg_count
                      , x_msg_data =>                    x_msg_data
                      , p_autonomous_flag =>             FND_API.G_TRUE
				  );

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   aso_debug_pub.ADD ( ' After  Calling Copy Configuration ', 1 , 'N' );
		   END IF;

                     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        l_old_config_header_id     :=
                                    l_qte_line_detail_tbl ( 1 ).config_header_id;
                        l_old_config_revision_num  :=
                                 l_qte_line_detail_tbl ( 1 ).config_revision_num;
                        l_qte_line_detail_tbl ( 1 ).config_header_id :=
                                                              l_config_hdr_id;
                        l_qte_line_detail_tbl ( 1 ).config_revision_num :=
                                                             l_config_rev_nbr;

			         IF aso_debug_pub.g_debug_flag = 'Y' THEN
				    aso_debug_pub.ADD ( ' Old Config Hdr Id = '||to_char(l_old_config_header_id) , 1 , 'N' );
				    aso_debug_pub.ADD ( ' Old Rev Nbr =   '||to_char(l_old_config_revision_num), 1 , 'N' );
				    aso_debug_pub.ADD ( 'New Config Hdr Id = '||to_char(l_config_hdr_id), 1 , 'N' );
				    aso_debug_pub.ADD ( ' New Rev Nbr = '||to_char(l_config_rev_nbr), 1 , 'N' );
				    END IF;

				 ELSE
                        x_return_status            := FND_API.G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

                  END IF; -- config_header_id

               END IF; -- line_dtl_tbl.count

            END IF; -- 'MDL'

            OPEN C_Serviceable_Product (
                l_qte_line_rec.organization_id
             , l_qte_line_rec.inventory_item_id
             );
            FETCH C_Serviceable_Product INTO l_serviceable_product_flag
                                           , l_service_item_flag;
            CLOSE C_Serviceable_Product;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.ADD ( 'service item flag = ' || l_service_item_flag , 1 , 'N' );
		  END IF;
            IF      l_service_item_flag = 'Y'
                AND l_qte_line_detail_tbl ( 1 ).service_ref_type_code <> 'QUOTE' THEN
               l_service_item_flag        := 'N';
            END IF;
		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.ADD ( 'service item flag 2= ' || l_service_item_flag , 1 , 'N' );
		  END IF;

            IF      l_qte_line_rec.item_type_code <> 'CFG'
                AND l_qte_line_rec.item_type_code <> 'OPT'
                AND l_service_item_flag <> 'Y' THEN

               l_line_attr_Ext_Tbl := ASO_UTILITY_PVT.Query_Line_Attribs_Ext_Rows ( P_Original_Qte_Line_Rec.quote_line_id);

               l_price_adj_tbl := ASO_UTILITY_PVT.Query_Price_Adj_NonPRG_Rows ( P_Qte_Header_Rec.quote_header_id ,
			                                                                 P_Original_Qte_Line_Rec.quote_line_id);
               l_dup_Price_Adj_Tbl := l_price_adj_tbl;

               l_price_adj_attr_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Attr_Rows(p_price_adj_tbl => l_price_adj_tbl);

               l_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows( P_Qte_Header_Rec.quote_header_id,
			                                                           P_Original_Qte_Line_Rec.quote_line_id);

               /* l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows ( P_Qte_Header_Rec.quote_header_id,
			                                                      P_Original_Qte_Line_Rec.quote_line_id); */

               l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows ( P_Qte_Header_Rec.quote_header_id,
			                                                        P_Original_Qte_Line_Rec.quote_line_id);

               l_sales_credit_tbl := ASO_UTILITY_PVT.Query_Sales_Credit_Row ( P_Qte_Header_Rec.quote_header_id,
			                                                               P_Original_Qte_Line_Rec.quote_line_id);

               l_quote_party_tbl := ASO_UTILITY_PVT.Query_Quote_Party_Row ( P_Qte_Header_Rec.quote_header_id,
			                                                             P_Original_Qte_Line_Rec.quote_line_id);

               l_freight_charge_tbl := ASO_UTILITY_PVT.Query_Freight_Charge_Rows ( l_shipment_tbl );

               l_tax_detail_tbl := ASO_UTILITY_PVT.Query_Tax_Detail_Rows ( P_Qte_Header_Rec.quote_header_id,
			                                                            P_Original_Qte_Line_Rec.quote_line_id,
															l_shipment_tbl);

               l_qte_line_rec.quote_line_id := NULL;

               l_qte_line_rec.object_version_number := FND_API.G_MISS_NUM;

               --BC4J Fix

                FOR j IN 1 .. l_qte_line_detail_tbl.COUNT LOOP
	              l_qte_line_detail_tbl(j).quote_line_detail_id := null;
                   l_qte_line_detail_tbl(j).object_version_number := FND_API.G_MISS_NUM;
			    l_qte_line_detail_tbl(j).top_model_line_id := null;
			    l_qte_line_detail_tbl(j).ato_line_id := null;
                   l_qte_line_detail_tbl(j).qte_line_index := i;
			 END LOOP;

                FOR j IN 1 .. l_price_adj_tbl.COUNT LOOP
                   l_price_adj_tbl ( j ).QUOTE_HEADER_ID     := P_Qte_Header_Rec.quote_header_id;
                   l_price_adj_tbl ( j ).price_adjustment_id := null;
			    l_price_adj_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
                END LOOP;

                FOR j IN 1 .. l_price_adj_attr_tbl.COUNT LOOP
                   l_price_adj_attr_tbl(j).price_adj_attrib_id := null;
			    l_price_adj_attr_tbl(j).object_version_number := FND_API.G_MISS_NUM;
                END LOOP;

                FOR j IN 1 .. l_price_attr_tbl.COUNT LOOP
                   l_price_attr_tbl ( j ).QUOTE_HEADER_ID    := P_Qte_Header_Rec.quote_header_id;
                   l_price_attr_tbl ( j ).price_attribute_id := null;
			    l_price_attr_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
                END LOOP;

                /* FOR j IN 1 .. l_payment_tbl.COUNT LOOP
                   l_payment_tbl ( j ).QUOTE_HEADER_ID := P_Qte_Header_Rec.quote_header_id;
                   l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_CODE := NULL;
                   l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_DATE := NULL;
                   l_payment_tbl ( j ).payment_id := NULL;
			    l_payment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
                END LOOP;  */

                FOR j IN 1 .. l_shipment_tbl.COUNT LOOP
                   l_shipment_tbl ( j ).QUOTE_HEADER_ID := P_Qte_Header_Rec.quote_header_id;
                   l_shipment_tbl ( j ).shipment_id := null;
			    l_shipment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
                END LOOP;

                FOR j IN 1 .. l_sales_credit_tbl.COUNT LOOP
                   l_sales_credit_tbl(j).QUOTE_HEADER_ID := P_Qte_Header_Rec.quote_header_id;
                   l_sales_credit_tbl(j).sales_credit_id := null;
			    l_sales_credit_tbl(j).object_version_number := FND_API.G_MISS_NUM;
                END LOOP;

                FOR j IN 1 .. l_quote_party_tbl.COUNT LOOP
                   l_quote_party_tbl(j).QUOTE_HEADER_ID  := P_Qte_Header_Rec.quote_header_id;
                   l_quote_party_tbl(j).QUOTE_PARTY_ID  := null;
			    l_quote_party_tbl(j).object_version_number := FND_API.G_MISS_NUM;
                END LOOP;

                FOR j IN 1 .. l_tax_detail_tbl.COUNT LOOP
                   l_tax_detail_tbl(j).tax_detail_id  := null;
			    l_tax_detail_tbl(j).object_version_number := FND_API.G_MISS_NUM;
                END LOOP;

                FOR j IN 1 .. l_line_attr_Ext_Tbl.COUNT LOOP
                   l_line_attr_Ext_Tbl(j).line_attribute_id  := null;
			    l_line_attr_Ext_Tbl(j).object_version_number := FND_API.G_MISS_NUM;
                END LOOP;

                FOR j IN 1 .. l_freight_charge_tbl.COUNT LOOP
                   l_freight_charge_tbl(j).freight_charge_id  := null;
			    l_freight_charge_tbl(j).object_version_number := FND_API.G_MISS_NUM;
                END LOOP;


	          --End of BC4J Fix

             -- Setting the new line number if a quote line is being copied
             IF ( P_Original_Qte_Line_Rec.quote_line_id IS NOT NULL ) AND
                (P_Original_Qte_Line_Rec.quote_line_id <> FND_API.G_MISS_NUM) THEN

                Open Get_Max_Line_Number(P_Qte_Header_Rec.quote_header_id);
                Fetch Get_Max_Line_Number into l_line_number;
                Close Get_Max_Line_Number;

                l_qte_line_rec.line_number := l_line_number + 10000;

             END IF;

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Split_Model_Line - Before insert_quote_line_rows: ' ||
                                    P_Original_Qte_Line_Rec.quote_line_id , 1 , 'Y' );
               END IF;

			ASO_QUOTE_LINES_PVT.Insert_Quote_Line_Rows (
                   p_control_rec =>                l_control_rec
                , P_qte_Line_Rec =>               l_qte_line_rec
                , P_qte_line_dtl_tbl =>            l_qte_line_detail_tbl
                , P_Line_Attribs_Ext_Tbl =>        l_line_attr_ext_tbl
                , P_price_attributes_tbl =>        l_price_attr_tbl
                , P_Price_Adj_Tbl =>               l_price_adj_tbl
                , P_Price_Adj_Attr_Tbl =>          l_Price_Adj_Attr_Tbl
                , P_Payment_Tbl =>                 ASO_QUOTE_PUB.g_miss_payment_tbl
                , P_Shipment_Tbl =>                l_shipment_tbl
                , P_Freight_Charge_Tbl =>          l_freight_charge_tbl
                , P_Tax_Detail_Tbl =>              l_tax_detail_tbl
                , P_Sales_Credit_Tbl =>            l_sales_credit_tbl
                , P_Quote_Party_Tbl =>             l_quote_party_tbl
			 , x_qte_Line_Rec =>                lx_qte_line_rec
                , x_qte_line_dtl_tbl =>            l_qte_line_detail_tbl_out
                , x_Line_Attribs_Ext_Tbl =>        l_line_attr_Ext_Tbl_out
                , x_price_attributes_tbl =>        l_price_attr_tbl_out
                , x_Price_Adj_Tbl =>               lx_ln_price_adj_tbl
                , x_Price_Adj_Attr_Tbl =>          l_Price_Adj_Attr_Tbl_out
                , x_Payment_Tbl =>                 l_payment_tbl_out
                , x_Shipment_Tbl =>                l_shipment_tbl_out
                , x_Freight_Charge_Tbl =>          l_freight_charge_tbl_out
                , x_Tax_Detail_Tbl =>              l_tax_detail_tbl_out
                , x_Sales_Credit_Tbl =>            l_sales_credit_tbl_out
                , x_Quote_Party_Tbl =>             l_quote_party_tbl_out
                , x_Return_Status =>               l_return_status
                , x_Msg_Count =>                   x_msg_count
                , x_Msg_Data =>                    x_msg_data
                );

      l_quote_party_tbl :=l_quote_party_tbl_out ;
      l_sales_credit_tbl :=l_sales_credit_tbl_out ;
      l_tax_detail_tbl := l_tax_detail_tbl_out    ;
      l_freight_charge_tbl := l_freight_charge_tbl_out  ;
      l_shipment_tbl := l_shipment_tbl_out   ;
      l_payment_tbl := l_payment_tbl_out     ;
      l_Price_Adj_Attr_Tbl  := l_Price_Adj_Attr_Tbl_out  ;
      l_Price_Attr_Tbl  :=  l_Price_Attr_Tbl_out     ;
      l_qte_line_detail_tbl := l_qte_line_detail_tbl_out   ;
      l_Line_Attr_Ext_Tbl  :=  l_Line_Attr_Ext_Tbl_out;

               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_INSERT' , TRUE );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			   aso_debug_pub.ADD ( 'Split_Model_Line - After insert_quote_line_rows - status: ' ||l_return_status ,1 , 'Y' );
                  aso_debug_pub.ADD ( 'SPLIT_MODEL_LINE - New Qte Line ID ='||to_char(lx_qte_line_rec.quote_line_id), 1 , 'N' );
                  aso_debug_pub.ADD ( 'Split_Model_Line - Updating the top model and ato line id for the top model line ', 1 , 'Y' );
                  aso_debug_pub.ADD ( 'Split_Model_Line - l_ato_model: ' || l_ato_model , 1 , 'Y' );
               END IF;
               update aso_quote_line_details
               set top_model_line_id =  lx_qte_line_rec.quote_line_id,
                   ato_line_id       =  decode(l_ato_model,fnd_api.g_true,lx_qte_line_rec.quote_line_id,null)
               where quote_line_id = lx_qte_line_rec.quote_line_id;

               -- Storing the new quote line id to be used later in update quote
               l_inserted_qte_line_tbl(i).quote_line_id := lx_qte_line_rec.quote_line_id;
               l_inserted_qte_line_tbl(i).quantity :=  l_qty_qte_line_tbl(i).quantity;

	  IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.ADD ( ' Qty for new line =  '||to_char(l_qty_qte_line_tbl(i).quantity), 1 , 'N' );
	  END IF;


      -- Copy the payment record
         l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows ( P_Qte_Header_Rec.quote_header_id,
                                                                     P_Original_Qte_Line_Rec.quote_line_id);

    IF l_payment_tbl.count > 0 then

                FOR j IN 1 .. l_payment_tbl.COUNT LOOP
                   l_payment_tbl ( j ).QUOTE_HEADER_ID := P_Qte_Header_Rec.quote_header_id;
                   l_payment_tbl ( j ).QUOTE_LINE_ID := lx_qte_line_rec.quote_line_id;
                   l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_CODE := NULL;
                   l_payment_tbl ( j ).CREDIT_CARD_APPROVAL_DATE := NULL;
                   l_payment_tbl ( j ).payment_id := NULL;
                   l_payment_tbl ( j ).object_version_number := FND_API.G_MISS_NUM;
                END LOOP;

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('SPLIT_MODEL_LINE: Before  call to copy_payment_row ', 1, 'Y');
       END IF;

         aso_copy_quote_pvt.copy_payment_row(p_payment_rec => l_payment_tbl(1)  ,
                                             x_return_status => l_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data);

       IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('SPLIT_MODEL_LINE: After call to copy_payment_row: x_return_status: '||l_return_status, 1, 'Y');
       END IF;
      IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
            FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
            FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_SPLITLINE  AFTER_INSERT' , TRUE );
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
         x_return_status            := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF;
     --  End Copy payment record


         -- Copying the sales supplement data for the line
                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.ADD ( 'Copy_Rows - Begin- before line copy_sales_supplement  ' , 1 , 'Y' );
                 END IF;

          ASO_COPY_QUOTE_PVT.INSERT_SALES_SUPP_DATA
          (
          P_Api_Version_Number          =>  1.0,
          P_Init_Msg_List               => P_Init_Msg_List,
          P_Commit                      => P_Commit,
          P_OLD_QUOTE_LINE_ID           => P_Original_Qte_Line_Rec.quote_line_id,
          P_NEW_QUOTE_LINE_ID           => lx_qte_line_rec.quote_line_id,
          X_Return_Status               => l_return_status,
          X_Msg_Count                   => X_Msg_Count,
          X_Msg_Data                    => X_Msg_Data );


                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.ADD ( 'Copy_Rows -After line copy_sales_supplement ' || x_return_status , 1 , 'Y' );
                  END IF;


               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                 x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                 IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                  FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                  FND_MESSAGE.Set_Token ('ROW' , 'ASO_QUOTE_HEADER', TRUE );
                  FND_MSG_PUB.ADD;
                END IF;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                x_return_status            := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
               END IF;


--               IF P_Copy_Quote_Control_Rec.Copy_Attachment = FND_API.G_TRUE THEN
                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
			   aso_debug_pub.ADD ( 'Split_Model_Line- Begin- before line copy_attch  ' , 1 , 'Y' );
			   END IF;

                 ASO_ATTACHMENT_INT.Copy_Attachments(
                     p_api_version       => l_api_version,
                     p_old_object_code   => 'ASO_QUOTE_LINES_ALL',
                     p_new_object_code   => 'ASO_QUOTE_LINES_ALL',
                     p_old_object_id     => P_Original_Qte_Line_Rec.quote_line_id,
                     p_new_object_id     => lx_qte_line_rec.quote_line_id,
                     x_return_status     => l_return_status,
                     x_msg_count         => x_msg_count,
                     x_msg_data          => x_msg_data
                   );
                  IF aso_debug_pub.g_debug_flag = 'Y' THEN
			   aso_debug_pub.ADD ( 'Split_Model_Line -After line copy_attch ' || l_return_status , 1 , 'Y' );
			   END IF;

                  IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                        FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                        FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_ATTACHMENTS' , TRUE );
                        FND_MSG_PUB.ADD;
                     END IF;
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                     x_return_status            := FND_API.G_RET_STS_ERROR;
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

        ---       END IF;   -- Copy Attachments

               FOR j IN 1 .. l_dup_Price_Adj_Tbl.COUNT LOOP
                  l_price_index_link_tbl ( l_dup_Price_Adj_Tbl ( j ).price_adjustment_id ) :=
                                lx_ln_price_adj_tbl ( j ).price_adjustment_id;
               END LOOP;

               l_line_index_link_tbl ( P_Original_Qte_Line_Rec.quote_line_id) :=
                                                 lx_qte_line_rec.quote_line_id;
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Split_Model_Line - l_qte_line_tbl(i).item_type_code ' ||
                                    l_qte_line_rec.item_type_code , 1 , 'Y' );
               aso_debug_pub.ADD ( 'Copy - l_qte_line_tbl(i).inventory_item_id ' ||
                                    l_qte_line_rec.inventory_item_id, 1 , 'Y' );
               aso_debug_pub.ADD ( 'Copy - l_serviceable_product_flag ' || l_serviceable_product_flag , 1 , 'Y' );
			END IF;

               IF l_serviceable_product_flag = 'Y' THEN

                 l_copy_quote_control_rec.Copy_Note := FND_API.G_TRUE;
                 l_copy_quote_control_rec.Copy_Task     := FND_API.G_TRUE;
                 l_copy_quote_control_rec.Copy_Attachment := FND_API.G_TRUE;
                 l_copy_quote_control_rec.New_Version := FND_API.G_TRUE;

                  ASO_COPY_QUOTE_PVT.service_copy (
                     p_qte_line_id =>                P_Original_Qte_Line_Rec.quote_line_id
                   , p_copy_quote_control_rec =>      l_copy_quote_control_rec
                   , p_new_qte_header_id =>          P_Qte_Header_Rec.quote_header_id
                   , p_qte_header_id =>               P_Qte_Header_Rec.quote_header_id
                   , lx_line_index_link_tbl =>        l_line_index_link_tbl
                   , lx_price_index_link_tbl =>       l_price_index_link_tbl
                   , X_Return_Status =>               l_return_status
                   , X_Msg_Count =>                   x_msg_count
                   , X_Msg_Data =>                    x_msg_data
                   , p_line_quantity            =>  FND_API.G_MISS_NUM  --l_qty_qte_line_tbl(i).quantity
                   );
               END IF;

               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_SERVICE' , TRUE );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

            END IF; -- If <> CFG and OPT

            IF l_qte_line_rec.item_type_code = 'MDL' THEN
               IF l_qte_line_detail_tbl.COUNT > 1 THEN
                  FOR k IN 2 .. l_qte_line_detail_tbl.COUNT LOOP
                     l_qte_line_detail_tbl ( k ).config_header_id :=
                                                              l_config_hdr_id;
                     l_qte_line_detail_tbl ( k ).config_revision_num :=
                                                             l_config_rev_nbr;
                  END LOOP;
               END IF;

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'l_old_config_header_id = ' || l_old_config_header_id , 1 , 'N' );
			END IF;

                 l_copy_quote_control_rec.Copy_Note := FND_API.G_TRUE;
                 l_copy_quote_control_rec.Copy_Task     := FND_API.G_TRUE;
                 l_copy_quote_control_rec.Copy_Attachment := FND_API.G_TRUE;
                 l_copy_quote_control_rec.New_Version := FND_API.G_TRUE;

               ASO_COPY_QUOTE_PVT.config_copy (
                   p_old_config_header_id =>       l_old_config_header_id
                , p_old_config_revision_num =>     l_old_config_revision_num
                , p_config_header_id =>            l_config_hdr_id
                , p_config_revision_num =>         l_config_rev_nbr
                , p_copy_quote_control_rec =>      l_copy_quote_control_rec
                , p_new_qte_header_id =>           P_Qte_Header_Rec.quote_header_id
                , p_qte_header_id =>               P_Qte_Header_Rec.quote_header_id
                , lx_line_index_link_tbl =>        l_line_index_link_tbl
                , lx_price_index_link_tbl =>       l_price_index_link_tbl
                , X_Return_Status =>               l_return_status
                , X_Msg_Count =>                   x_msg_count
                , X_Msg_Data =>                    x_msg_data
                , p_line_quantity =>               FND_API.G_MISS_NUM  --l_qte_line_rec.quantity
                );

               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPYLINE AFTER_CONFIG_COPY' , TRUE );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

 --               bug 1903605
               l_old_config_header_id     := NULL;
               l_old_config_revision_num  := NULL;
--                bug 1903605

              IF (l_orig_item_id_tbl IS NOT NULL)  AND (l_new_item_id_tbl IS NOT NULL)  THEN

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'item_id_count > 0 ', 1 , 'N' );
               aso_debug_pub.ADD ( 'Orig Tbl Count ' ||l_orig_item_id_tbl.count, 1 , 'N' );
               aso_debug_pub.ADD ( 'New Tbl Count '||l_new_item_id_tbl.count, 1 , 'N' );
               END IF;

                 IF l_orig_item_id_tbl.count > 0 AND l_new_item_id_tbl.count > 0 THEN

                    FORALL  i  IN l_orig_item_id_tbl.FIRST..l_orig_item_id_tbl.LAST
                     UPDATE aso_quote_line_details
                     SET config_item_id = l_new_item_id_tbl(i)
                        ,last_update_date = SYSDATE
                        ,last_updated_by = G_USER_ID
                        ,last_update_login = G_LOGIN_ID

                     WHERE config_header_id = l_config_hdr_id
                     AND config_revision_num = l_config_rev_nbr
                     AND config_item_id = l_orig_item_id_tbl(i);
                 END IF;

               END IF;



             END IF; -- 'MDL'


     END IF; -- Checking the index line table

      --Insert rows for line relationships and line price relationships for that quote line---
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	aso_debug_pub.ADD ( ' Copying the line relationship and price relation records for the new qte line' , 1 , 'N' );
	END IF;


      FOR price_adj_rltship_rec IN c_price_adj_rel ( P_Original_Qte_Line_Rec.quote_line_id ) LOOP
         lx_price_adj_rltship_id    := FND_API.G_MISS_NUM;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'l_line_index_link_tbl ( price_adj_rltship_rec.quote_line_id ) = ' ||
                              l_line_index_link_tbl ( price_adj_rltship_rec.quote_line_id ) , 1 , 'N' );
	    aso_debug_pub.ADD ( 'l_price_index_link_tbl ( price_adj_rltship_rec.rltd_price_adj_id ) = ' ||
                              l_price_index_link_tbl ( price_adj_rltship_rec.rltd_price_adj_id ) , 1 , 'N' );
	    aso_debug_pub.ADD ( 'price_adj_rltship_rec.rltd_price_adj_id = ' ||
                              price_adj_rltship_rec.rltd_price_adj_id  , 1 , 'N' );
         END IF;

         OPEN C_Get_Ship_Id (
            l_line_index_link_tbl ( price_adj_rltship_rec.quote_line_id )
          );
         FETCH C_Get_Ship_Id INTO l_ship_id;
         CLOSE C_Get_Ship_Id;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'l_ship_id from line_id = ' || l_ship_id , 1 , 'N' );
	    END IF;

         ASO_PRICE_RLTSHIPS_PKG.Insert_Row (
             px_ADJ_RELATIONSHIP_ID =>       lx_price_adj_rltship_id
          , p_creation_date =>               SYSDATE
          , p_CREATED_BY =>                  G_USER_ID
          , p_LAST_UPDATE_DATE =>            SYSDATE
          , p_LAST_UPDATED_BY =>             G_USER_ID
          , p_LAST_UPDATE_LOGIN =>           G_LOGIN_ID
          , p_PROGRAM_APPLICATION_ID =>      price_adj_rltship_rec.PROGRAM_APPLICATION_ID
          , p_PROGRAM_ID =>                  price_adj_rltship_rec.PROGRAM_ID
          , p_PROGRAM_UPDATE_DATE =>         price_adj_rltship_rec.PROGRAM_UPDATE_DATE
          , p_REQUEST_ID =>                  price_adj_rltship_rec.REQUEST_ID
          , p_QUOTE_LINE_ID =>               l_line_index_link_tbl ( price_adj_rltship_rec.quote_line_id )
          , p_PRICE_ADJUSTMENT_ID =>         l_price_index_link_tbl ( price_adj_rltship_rec.price_adjustment_id )
          , p_RLTD_PRICE_ADJ_ID =>           l_price_index_link_tbl ( price_adj_rltship_rec.rltd_price_adj_id )
          , p_QUOTE_SHIPMENT_ID =>           l_ship_id
		, p_OBJECT_VERSION_NUMBER =>       price_adj_rltship_rec.OBJECT_VERSION_NUMBER
          );
      END LOOP;

      -- copy line relationships

      FOR line_rel_rec IN c_line_relation ( P_Original_Qte_Line_Rec.quote_line_id ) LOOP

         lx_LINE_RELATIONSHIP_ID    := FND_API.G_MISS_NUM;
         ASO_LINE_RELATIONSHIPS_PKG.Insert_Row (
             px_LINE_RELATIONSHIP_ID =>      lx_LINE_RELATIONSHIP_ID
          , p_CREATION_DATE =>               SYSDATE
          , p_CREATED_BY =>                  G_USER_ID
          , p_LAST_UPDATED_BY =>             G_USER_ID
          , p_LAST_UPDATE_DATE =>            SYSDATE
          , p_LAST_UPDATE_LOGIN =>           G_LOGIN_ID
          , p_REQUEST_ID =>                  line_rel_rec.REQUEST_ID
          , p_PROGRAM_APPLICATION_ID =>      line_rel_rec.PROGRAM_APPLICATION_ID
          , p_PROGRAM_ID =>                  line_rel_rec.PROGRAM_ID
          , p_PROGRAM_UPDATE_DATE =>         line_rel_rec.PROGRAM_UPDATE_DATE
          , p_QUOTE_LINE_ID =>               l_line_index_link_tbl ( line_rel_rec.quote_line_id )
          , p_RELATED_QUOTE_LINE_ID =>       l_line_index_link_tbl ( line_rel_rec.related_quote_line_id )
          , p_RECIPROCAL_FLAG =>             line_rel_rec.RECIPROCAL_FLAG
          , P_RELATIONSHIP_TYPE_CODE =>      line_rel_rec.RELATIONSHIP_TYPE_CODE
		, p_OBJECT_VERSION_NUMBER =>       line_rel_rec.OBJECT_VERSION_NUMBER
          );

    END LOOP;


END LOOP;
  -- End Copying the Line Loop
  -- Calling Update Quote to update the quantities

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.ADD ( ' Getting the last update date of the quote before updating the quote ', 1 , 'N' );
   END IF;

    l_quote_header_rec := ASO_UTILITY_PVT.Query_Header_Row(P_Qte_Header_Rec.quote_header_id);

   OPEN get_latest_date (
      P_Qte_Header_Rec.quote_header_id
    );
    FETCH get_latest_date INTO l_quote_header_rec.last_update_date;
    CLOSE get_latest_date;

    l_quote_header_rec.quote_header_id := P_Qte_Header_Rec.quote_header_id;
    l_quote_header_rec.pricing_status_indicator := P_Qte_Header_Rec.pricing_status_indicator;
    l_quote_header_rec.tax_status_indicator := P_Qte_Header_Rec.tax_status_indicator;

/*
   P_Control_Rec is going to be passed by the calling API
	  l_control_rec.last_update_date :=     l_quote_header_rec.last_update_date;
       l_control_rec.pricing_request_type          :=  'ASO';
       l_control_rec.header_pricing_event          :=  'BATCH';
       l_control_rec.calculate_tax_flag            :=  'Y';
       l_control_rec.calculate_freight_charge_flag :=  'Y';
*/


    l_qte_line_tbl := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( 'No Of Qte Lines 1 =  '|| to_char(l_qte_line_tbl.count), 1 , 'N' );
    aso_debug_pub.ADD ( ' Setting the qty and op code for new line created ', 1 , 'N' );
    END IF;

  FOR i  in 1..l_inserted_qte_line_tbl.count LOOP
   l_qte_line_tbl(i).quote_header_id := P_Qte_Header_Rec.quote_header_id;
   l_qte_line_tbl(i).quantity := l_inserted_qte_line_tbl(i).quantity;
   l_qte_line_tbl(i).quote_line_id := l_inserted_qte_line_tbl(i).quote_line_id;
   l_qte_line_tbl(i).operation_code := 'UPDATE';


    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( 'New Qte Line '|| to_char(l_inserted_qte_line_tbl(i).quote_line_id), 1 , 'N' );
    aso_debug_pub.ADD ( 'New Qty '|| to_char(l_inserted_qte_line_tbl(i).quantity), 1 , 'N' );
    END IF;

 END LOOP;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.ADD ( 'No Of Qte Lines 2 =  '|| to_char(l_qte_line_tbl.count), 1 , 'N' );
   aso_debug_pub.ADD ( ' Setting the qty and op code for orig line to be updated ', 1 , 'N' );
   END IF;

   l_total_lines := l_qte_line_tbl.count;

   l_qte_line_tbl(l_total_lines + 1).quantity := l_qty_qte_line_tbl(l_qty_qte_line_tbl.count).quantity;

   l_qte_line_tbl(l_total_lines + 1).quote_header_id := P_Qte_Header_Rec.quote_header_id;
   l_qte_line_tbl(l_total_lines + 1).operation_code := 'UPDATE';
   l_qte_line_tbl(l_total_lines + 1).quote_line_id := P_Original_Qte_Line_Rec.quote_line_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( 'No Of Qte Lines before update qty =  '|| to_char(l_qte_line_tbl.count), 1 , 'N' );
    aso_debug_pub.ADD ( ' Calling Update Quote to update all lines  ', 1 , 'N' );
    END IF;

  aso_quote_pub.update_quote (
      p_api_version_number         => 1.0,
      p_init_msg_list              => fnd_api.g_false,
      p_commit                     => fnd_api.g_false,
      p_control_rec                => p_control_rec,
      p_qte_header_rec             => l_quote_header_rec,
      p_hd_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
      p_hd_payment_tbl             => aso_quote_pub.g_miss_payment_tbl,
      p_hd_shipment_tbl            => aso_quote_pub.g_miss_shipment_tbl,
      p_hd_freight_charge_tbl      => aso_quote_pub.g_miss_freight_charge_tbl,
      p_hd_tax_detail_tbl          => aso_quote_pub.g_miss_tax_detail_tbl,
      p_qte_line_tbl               => l_qte_line_tbl,
      p_qte_line_dtl_tbl           => aso_quote_pub.g_miss_qte_line_dtl_tbl,
      p_line_attr_ext_tbl          => aso_quote_pub.G_MISS_Line_Attribs_Ext_TBL,
      p_line_rltship_tbl           => aso_quote_pub.g_miss_line_rltship_tbl,
      p_price_adjustment_tbl       => aso_quote_pub.g_miss_price_adj_tbl,
      p_price_adj_attr_tbl         => aso_quote_pub.g_miss_price_adj_attr_tbl,
      p_price_adj_rltship_tbl      => aso_quote_pub.g_miss_price_adj_rltship_tbl,
      p_ln_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
      p_ln_payment_tbl             => aso_quote_pub.g_miss_payment_tbl,
      p_ln_shipment_tbl            => aso_quote_pub.g_miss_shipment_tbl,
      p_ln_freight_charge_tbl      => aso_quote_pub.g_miss_freight_charge_tbl,
      p_ln_tax_detail_tbl          => aso_quote_pub.g_miss_tax_detail_tbl,
      x_qte_header_rec             => x_qte_header_rec,
      x_qte_line_tbl               => x_qte_line_tbl,
      x_qte_line_dtl_tbl           => x_qte_line_dtl_tbl,
      x_hd_price_attributes_tbl    => x_hd_price_attributes_tbl,
      x_hd_payment_tbl             => x_hd_payment_tbl,
      x_hd_shipment_tbl            => x_hd_shipment_tbl,
      x_hd_freight_charge_tbl      => x_hd_freight_charge_tbl,
      x_hd_tax_detail_tbl          => x_hd_tax_detail_tbl,
      x_line_attr_ext_tbl          => x_line_attr_ext_tbl,
      x_line_rltship_tbl           => x_line_rltship_tbl,
      x_price_adjustment_tbl       => x_price_adjustment_tbl,
      x_price_adj_attr_tbl         => x_price_adj_attr_tbl,
      x_price_adj_rltship_tbl      => x_price_adj_rltship_tbl,
      x_ln_price_attributes_tbl    => x_ln_price_attributes_tbl,
      x_ln_payment_tbl             => x_ln_payment_tbl,
      x_ln_shipment_tbl            => x_ln_shipment_tbl,
      x_ln_freight_charge_tbl      => x_ln_freight_charge_tbl,
      x_ln_tax_detail_tbl          => x_ln_tax_detail_tbl,
      x_return_status              => l_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( ' Return Status from Update Quote = '||l_return_status, 1 , 'N' );
    END IF;


               IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;
                  IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                     FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                     FND_MSG_PUB.ADD;
                  END IF;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
                  x_return_status            := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( ' After Calling Update Quote to update all lines  ', 1 , 'N' );
	 END IF;


      X_Quote_Line_Tbl := x_qte_line_tbl;
      --
      -- End of API body
      --
      -- Standard check for p_commit
      IF FND_API.to_Boolean ( p_commit ) THEN
         COMMIT WORK;
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
          p_count =>                      x_msg_count
       , p_data =>                        x_msg_data
       );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.ADD ( ' End of Split_Model_Line   ', 1 , 'N' );
    END IF;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );


      WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_SQLCODE =>                     SQLCODE
          , P_SQLERRM =>                     SQLERRM
          , P_EXCEPTION_LEVEL =>             ASO_UTILITY_PVT.G_EXC_OTHERS
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

 END Split_Model_Line;


PROCEDURE INSERT_SALES_SUPP_DATA
(
P_Api_Version_Number          IN         NUMBER,
P_Init_Msg_List               IN         VARCHAR2     := FND_API.G_FALSE,
P_Commit                      IN         VARCHAR2     := FND_API.G_FALSE,
P_OLD_QUOTE_LINE_ID           IN         NUMBER,
P_NEW_QUOTE_LINE_ID           IN         NUMBER,
X_Return_Status               OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
X_Msg_Count                   OUT NOCOPY /* file.sql.39 change */           VARCHAR2,
X_Msg_Data                    OUT NOCOPY /* file.sql.39 change */           VARCHAR2 ) IS


      CURSOR get_template_id (
          qte_line_id NUMBER
       ) IS
         SELECT template_instance_id, template_id
         FROM   aso_sup_tmpl_instance
         WHERE  owner_table_name = 'ASO_QUOTE_LINES'
         AND    owner_table_id = qte_line_id;

      CURSOR get_values (
          temp_instance_id NUMBER
       ) IS
         SELECT sect_comp_map_id, VALUE, value_type_qualifier, response_id,
         rtfdata                -- Code added for Bug 14478526
         FROM   aso_sup_instance_value
         WHERE  template_instance_id = temp_instance_id;

      l_old_template_instance_id NUMBER;
      l_new_template_instance_id NUMBER;
      l_sup_instance_rowid ROWID;
      l_template_instance_rowid ROWID;
      l_instance_value_id NUMBER;
      l_old_instance_value_id NUMBER;
      l_api_name VARCHAR2 ( 150 ) := 'INSERT_SALES_SUPP_DATA';
      l_api_version_number CONSTANT NUMBER := 1.0;

   BEGIN

-- Establish a standard save point
      SAVEPOINT INSERT_SALES_SUPP_DATA_PVT;

-- Standard call to check for call compatability
      IF NOT FND_API.Compatible_API_Call (
                 l_api_version_number
              , p_api_version_number
              , l_api_name
              , G_PKG_NAME
              ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean ( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

-- API BODY
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.ADD ('INSERT_SALES_SUPP_DATA: Begin' , 1, 'N' );
      aso_debug_pub.ADD ( 'Old QTE Line  Id : ' || TO_CHAR ( P_OLD_QUOTE_LINE_ID ) , 1 , 'N' );
      aso_debug_pub.ADD ( 'New QTE Line  Id : ' || TO_CHAR ( P_NEW_QUOTE_LINE_ID ) , 1 , 'N' );
      END IF;

-- Get the template id and template_instance_id based upon the
-- quote line id

      FOR template_val IN get_template_id ( P_OLD_QUOTE_LINE_ID ) LOOP
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.ADD ( 'Template Id : ' || TO_CHAR ( template_val.template_id ) , 1 , 'N' );
         aso_debug_pub.ADD ( ' Old Template Instance Id : ' || TO_CHAR ( template_val.template_instance_id ) , 1 , 'N
' );

         -- Create a new row in the ASO_SUP_TMPL_INSTANCE Table with the template id

         aso_debug_pub.ADD ( 'Inserting a row into tmpl_instance table' , 1 , 'N' );
         END IF;

         -- Initiate the variable to null,
         -- so that each time they contain new value for every pass of loop

         l_new_template_instance_id := NULL;
         ASO_SUP_TMPL_INSTANCE_PKG.INSERT_ROW (
             PX_ROWID =>                     l_template_instance_rowid
          , PX_TEMPLATE_INSTANCE_ID =>       l_new_template_instance_id
          , P_created_by =>                  FND_GLOBAL.USER_ID
          , P_creation_date =>               SYSDATE
          , P_last_updated_by =>             FND_GLOBAL.USER_ID
          , P_last_update_date =>            SYSDATE
          , P_last_update_login =>           FND_GLOBAL.CONC_LOGIN_ID
          , P_TEMPLATE_ID =>                 template_val.template_id
          , P_Owner_Table_Name =>            'ASO_QUOTE_LINES'
          , P_Owner_Table_Id =>              P_NEW_QUOTE_LINE_ID
		, P_OBJECT_VERSION_NUMBER =>       FND_API.G_MISS_NUM
          );

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.ADD ( ' New Template Instance Id : ' || TO_CHAR ( l_new_template_instance_id ) , 1 , 'N' );
         END IF;

         -- Get the values for that instance
         FOR inst_val IN get_values ( template_val.template_instance_id ) LOOP
            IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.ADD (   'Value : ' || inst_val.VALUE, 1, 'N' );
            aso_debug_pub.ADD ( 'Value Type Qualifier : ' || inst_val.value_type_qualifier , 1 , 'N' );
            aso_debug_pub.ADD ( 'Response Id : ' || TO_CHAR ( inst_val.response_id ) , 1 , 'N' );
            END IF;

            -- If values are fetched then insert rows
            IF inst_val.sect_comp_map_id IS NOT NULL THEN
               -- Initiate the variables to null,
               -- so that each time they contain new value for every pass of loop

               l_instance_value_id        := NULL;
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.ADD ( 'Inserting a row into instance_value table' , 1 , 'N' );
               END IF;

               -- Create a new row in the ASO_SUP_INSTANCE_VALUE table
               ASO_SUP_INSTANCE_VALUE_PKG.INSERT_ROW (
                   PX_ROWID =>                     l_sup_instance_rowid
                , PX_INSTANCE_VALUE_ID =>          l_instance_value_id
                , P_SECT_COMP_MAP_ID =>            inst_val.sect_comp_map_id
                , P_Template_Instance_ID =>        l_new_template_instance_id
                , p_value =>                       inst_val.VALUE
                , p_value_type_qualifier =>        inst_val.value_type_qualifier
                , p_response_id =>                 inst_val.response_id
                , P_created_by =>                  FND_GLOBAL.USER_ID
                , P_last_updated_by =>             FND_GLOBAL.USER_ID
                , P_last_update_login =>           FND_GLOBAL.CONC_LOGIN_ID
			 , P_OBJECT_VERSION_NUMBER =>       FND_API.G_MISS_NUM
                );
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.ADD ( 'New Instance Value Id : ' || TO_CHAR ( l_instance_value_id ) , 1 , 'N' );
               END IF;
            END IF;

   	     /* Start : Code Added for Bug 14478526 */
	     If inst_val.rtfdata Is Not Null Then

                Update aso_sup_instance_value
                Set rtfdata = inst_val.rtfdata
	        Where instance_value_id = l_instance_value_id;

	     End If;
	     /* End : Code Added for Bug 14478526 */

         END LOOP; -- instance value loop

      END LOOP; -- template loop

      -- Standard check for p_commit
      IF FND_API.to_Boolean ( p_commit ) THEN
         COMMIT WORK;
      END IF;

--  Initialize API return status to success
      x_return_status            := FND_API.G_RET_STS_SUCCESS;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.ADD ( 'INSERT_SALES_SUPP_DATA: ' || l_api_name || 'end' , 1 , 'N' );
      END IF;



EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_EXCEPTION_LEVEL =>             FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );

      WHEN OTHERS THEN
         ASO_UTILITY_PVT.HANDLE_EXCEPTIONS (
             P_API_NAME =>                   L_API_NAME
          , P_PKG_NAME =>                    G_PKG_NAME
          , P_SQLCODE =>                     SQLCODE
          , P_SQLERRM =>                     SQLERRM
          , P_EXCEPTION_LEVEL =>             ASO_UTILITY_PVT.G_EXC_OTHERS
          , P_PACKAGE_TYPE =>                ASO_UTILITY_PVT.G_PVT
          , X_MSG_COUNT =>                   X_MSG_COUNT
          , X_MSG_DATA =>                    X_MSG_DATA
          , X_RETURN_STATUS =>               X_RETURN_STATUS
          );


END INSERT_SALES_SUPP_DATA;

PROCEDURE copy_payment_row(p_payment_rec   IN         aso_quote_pub.payment_rec_type,
                             x_return_status OUT NOCOPY varchar2,
                             x_msg_count     OUT NOCOPY number,
                             x_msg_data      OUT NOCOPY varchar2) is

  l_api_name            varchar2(1000) := 'copy_payment_row';
  l_payment_rec         aso_quote_pub.payment_rec_type := p_payment_rec;
  l_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type;
  l_payer               IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
  lx_response           IBY_FNDCPT_COMMON_PUB.Result_rec_type;
  lx_assign_id          number;
  lx_entity_id          number;
  l_trxn_attribs        IBY_FNDCPT_TRXN_PUB.TrxnExtension_rec_type;
  l_qte_line_rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type;
  l_entities            IBY_FNDCPT_COMMON_PUB.Id_tbl_type;
  l_payment_ref_number  varchar2(240);
  lx_channel_attrib_uses IBY_FNDCPT_SETUP_PUB.PmtChannel_AttribUses_rec_type;

 Cursor c_get_payer_from_trxn(p_trxn_extension_id number) is
 select a.party_id, a.instr_assignment_id
 from iby_fndcpt_payer_assgn_instr_v a, IBY_TRXN_EXTENSIONS_V b
 where a.instr_assignment_id = b.instr_assignment_id
 and b.trxn_extension_id = p_trxn_extension_id;

 Cursor c_get_payment_id is
 SELECT ASO_PAYMENTS_S.nextval FROM sys.dual;

begin
     SAVEPOINT COPY_PAYMENT_ROW_PVT;
     aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Begin copy_payment_row ', 1, 'Y');
         aso_debug_pub.add('l_payment_rec.Quote_Header_Id:  ' || l_payment_rec.Quote_Header_Id, 1, 'Y');
         aso_debug_pub.add('l_payment_rec.Quote_Line_Id:    ' || l_payment_rec.Quote_Line_Id, 1, 'Y');
         aso_debug_pub.add('l_payment_rec.trxn_extension_id:' || l_payment_rec.trxn_extension_id, 1, 'Y');
         aso_debug_pub.add('l_payment_rec.PAYMENT_REF_NUMBER:'|| l_payment_rec.PAYMENT_REF_NUMBER , 1, 'Y');
         aso_debug_pub.add('l_payment_rec.PAYMENT_TERM_ID:  ' || l_payment_rec.PAYMENT_TERM_ID, 1, 'Y');
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_qte_header_rec := ASO_UTILITY_PVT.Query_Header_Row (l_payment_rec.Quote_Header_Id );
     IF ( l_payment_rec.Quote_Line_Id IS NOT NULL and l_payment_rec.Quote_Line_Id <> fnd_api.g_miss_num) then
       l_qte_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row ( l_payment_rec.Quote_Line_Id );
     END IF;

    if (l_payment_rec.trxn_extension_id is not null or l_payment_rec.trxn_extension_id <> fnd_api.g_miss_num) then

        -- Check to see if cvv2 is mandatory or not
        IF aso_debug_pub.g_debug_flag = 'Y' THEN
           aso_debug_pub.add('Before calling IBY_FNDCPT_TRXN_PUB.Get_Payment_Channel_Attribs ', 1, 'Y');
        END IF;

        IBY_FNDCPT_SETUP_PUB.Get_Payment_Channel_Attribs
            (
            p_api_version          => 1.0,
            p_init_msg_list        => FND_API.G_FALSE,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data,
            p_channel_code         => 'CREDIT_CARD',
            x_channel_attrib_uses  => lx_channel_attrib_uses,
            x_response             => lx_response);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('after calling IBY_FNDCPT_TRXN_PUB.Get_Payment_Channel_Attribs ', 1, 'Y');
            aso_debug_pub.add('Return Status: '||x_return_status, 1, 'Y');
            aso_debug_pub.add('cvv2 use:      '||lx_channel_attrib_uses.Instr_SecCode_Use, 1, 'Y');
            aso_debug_pub.add('x_response.result_code:    '|| to_char(lx_response.result_code), 1, 'Y');
            aso_debug_pub.add('x_response.result_category:'|| to_char(lx_response.result_category), 1, 'Y');
            aso_debug_pub.add('x_response.result_message: '|| to_char(lx_response.result_message), 1, 'Y');
        END IF;

        -- if cvv2 is not mandatory then call IBY API to create the new trxn extension
        -- if cvv2 is mandatory then do not call IBY API, make payment ref as null and insert row

        IF (nvl(lx_channel_attrib_uses.Instr_SecCode_Use,'null') <>  'REQUIRED') THEN

            l_payer.cust_account_id := null;
            l_payer.account_site_id := null;
            l_payer.payment_function := 'CUSTOMER_PAYMENT';


            open c_get_payer_from_trxn(l_payment_rec.trxn_extension_id);
            fetch c_get_payer_from_trxn into l_payer.party_id,l_payment_rec.instr_assignment_id;
            close c_get_payer_from_trxn;

		  if (l_payment_rec.payment_id is null or l_payment_rec.payment_id = fnd_api.g_miss_num) then
		    open c_get_payment_id;
		    fetch c_get_payment_id into l_payment_rec.payment_id;
		    close c_get_payment_id;
            end if;

            l_trxn_attribs.Originating_Application_Id := 697;

            l_trxn_attribs.Order_Id := to_char(l_payment_rec.payment_id)||'-'||l_qte_header_rec.quote_number;
            l_trxn_attribs.PO_Number := null;
            l_trxn_attribs.PO_Line_Number := null;
            l_trxn_attribs.Trxn_Ref_Number1 := l_payment_rec.quote_header_id;
            IF l_payment_rec.quote_line_id = fnd_api.g_miss_num then
             l_trxn_attribs.Trxn_Ref_Number2 := null;
            Else
             l_trxn_attribs.Trxn_Ref_Number2 := l_payment_rec.quote_line_id;
            End if;
            -- Do NOT copy the cvv2 info if the cvv2 is OPTIONAL see bug 4777120
		  -- l_trxn_attribs.Instrument_Security_Code := l_payment_rec.cvv2;

            l_trxn_attribs.VoiceAuth_Flag := null;
            l_trxn_attribs.VoiceAuth_Date := null;
            l_trxn_attribs.VoiceAuth_Code := null;
            l_trxn_attribs.Additional_Info := null;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Before calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', 1, 'Y');
              aso_debug_pub.add('Instrument Assignment id: '|| l_payment_rec.instr_assignment_id, 1, 'Y');
              aso_debug_pub.add('payment id is :           '|| l_payment_rec.payment_id,1,'Y');
              aso_debug_pub.add('quote line  id is :       '|| l_payment_rec.quote_line_id,1,'Y');
              aso_debug_pub.add('party_id is :             '|| l_payer.party_id,1,'Y');
           END IF;

            IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension
            (
            p_api_version       => 1.0,
            p_init_msg_list     => FND_API.G_FALSE,
            p_commit            => FND_API.G_FALSE,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_payer             => l_payer,
            p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
            p_pmt_channel       => l_payment_rec.payment_type_code,
            p_instr_assignment  => l_payment_rec.instr_assignment_id,
            p_trxn_attribs      => l_trxn_attribs,
            x_entity_id         => lx_entity_id,
            x_response          => lx_response);

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('after calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', 1, 'Y');
              aso_debug_pub.add('Return Status: '||x_return_status, 1, 'Y');
            aso_debug_pub.add('lx_entity_id:            '||lx_entity_id, 1, 'Y');
            aso_debug_pub.add('x_response.result_code:    '|| to_char(lx_response.result_code), 1, 'Y');
            aso_debug_pub.add('x_response.result_category:'|| to_char(lx_response.result_category), 1, 'Y');
            aso_debug_pub.add('x_response.result_message: '|| to_char(lx_response.result_message), 1, 'Y');
           END IF;

            if x_return_status <> fnd_api.g_ret_sts_success then
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 FND_MESSAGE.Set_Name('ASO', 'ERROR_RETURNED');
                 FND_MESSAGE.Set_Token('API', 'IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension ', FALSE);
                 FND_MSG_PUB.ADD;
              END IF;
              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
            end if;

            -- setting the trxn extn id
            l_payment_rec.trxn_extension_id := lx_entity_id;

     ELSE

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Instr Sec Code cvv2 is mandatory hence setting the payment ref number and trxn ext id to null ', 1, 'Y');
           END IF;

            l_payment_rec.PAYMENT_REF_NUMBER := null;
            l_payment_rec.trxn_extension_id := null;
            l_payment_rec.payment_type_code := null;

     END IF; -- end if for the cvv2 check

    end if; -- end if for trxn ext id check

           IF l_payment_rec.PAYMENT_TYPE_CODE = 'CREDIT_CARD' then
              l_payment_ref_number := null;
           else
              l_payment_ref_number := l_payment_rec.PAYMENT_REF_NUMBER;
           END IF;

     ASO_PAYMENTS_PKG.Insert_Row(
            px_PAYMENT_ID                 => l_payment_rec.PAYMENT_ID,
            p_CREATION_DATE               => SYSDATE,
            p_CREATED_BY                  => fnd_global.USER_ID,
            p_LAST_UPDATE_DATE            => SYSDATE,
            p_LAST_UPDATED_BY             => fnd_global.USER_ID,
            p_LAST_UPDATE_LOGIN           => FND_GLOBAL.CONC_LOGIN_ID,
            p_REQUEST_ID                  => l_payment_rec.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID      => l_payment_rec.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID                  => l_payment_rec.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE         => l_payment_rec.PROGRAM_UPDATE_DATE,
            p_QUOTE_HEADER_ID             => l_payment_rec.QUOTE_HEADER_ID,
            p_QUOTE_LINE_ID               => l_payment_rec.QUOTE_LINE_ID,
            p_QUOTE_SHIPMENT_ID           => l_payment_rec.QUOTE_SHIPMENT_ID ,
            p_PAYMENT_TYPE_CODE           => l_payment_rec.PAYMENT_TYPE_CODE,
            p_PAYMENT_REF_NUMBER          => l_payment_ref_number,
            p_PAYMENT_OPTION              => l_payment_rec.PAYMENT_OPTION,
            p_PAYMENT_TERM_ID             => l_payment_rec.PAYMENT_TERM_ID,
            p_CREDIT_CARD_CODE            => null,
            p_CREDIT_CARD_HOLDER_NAME     => null,
            p_CREDIT_CARD_EXPIRATION_DATE => null,
            p_CREDIT_CARD_APPROVAL_CODE   => null,
            p_CREDIT_CARD_APPROVAL_DATE   => null,
            p_PAYMENT_AMOUNT              => l_payment_rec.PAYMENT_AMOUNT,
            p_ATTRIBUTE_CATEGORY          => l_payment_rec.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1                  => l_payment_rec.ATTRIBUTE1,
            p_ATTRIBUTE2                  => l_payment_rec.ATTRIBUTE2,
            p_ATTRIBUTE3                  => l_payment_rec.ATTRIBUTE3,
            p_ATTRIBUTE4                  => l_payment_rec.ATTRIBUTE4,
            p_ATTRIBUTE5                  => l_payment_rec.ATTRIBUTE5,
            p_ATTRIBUTE6                  => l_payment_rec.ATTRIBUTE6,
            p_ATTRIBUTE7                  => l_payment_rec.ATTRIBUTE7,
            p_ATTRIBUTE8                  => l_payment_rec.ATTRIBUTE8,
            p_ATTRIBUTE9                  => l_payment_rec.ATTRIBUTE9,
            p_ATTRIBUTE10                 => l_payment_rec.ATTRIBUTE10,
            p_ATTRIBUTE11                 => l_payment_rec.ATTRIBUTE11,
            p_ATTRIBUTE12                 => l_payment_rec.ATTRIBUTE12,
            p_ATTRIBUTE13                 => l_payment_rec.ATTRIBUTE13,
            p_ATTRIBUTE14                 => l_payment_rec.ATTRIBUTE14,
            p_ATTRIBUTE15                 => l_payment_rec.ATTRIBUTE15,
           p_ATTRIBUTE16                 => l_payment_rec.ATTRIBUTE16,
            p_ATTRIBUTE17                 => l_payment_rec.ATTRIBUTE17,
            p_ATTRIBUTE18                 => l_payment_rec.ATTRIBUTE18,
            p_ATTRIBUTE19                 => l_payment_rec.ATTRIBUTE19,
            p_ATTRIBUTE20                 => l_payment_rec.ATTRIBUTE20,
          p_CUST_PO_NUMBER              => l_payment_rec.CUST_PO_NUMBER,
           p_PAYMENT_TERM_ID_FROM        => l_payment_rec.PAYMENT_TERM_ID_FROM,
          p_OBJECT_VERSION_NUMBER       => l_payment_rec.OBJECT_VERSION_NUMBER,
            p_CUST_PO_LINE_NUMBER         => l_payment_rec.CUST_PO_LINE_NUMBER,
            p_trxn_extension_id           => l_payment_rec.trxn_extension_id
          );
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD ('END copy_payment_row',1,'N');
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

  WHEN OTHERS THEN
    ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

end copy_payment_row;

END ASO_COPY_QUOTE_PVT;

/
