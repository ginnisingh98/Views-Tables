--------------------------------------------------------
--  DDL for Package Body ASO_COPY_TMPL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_COPY_TMPL_PUB" AS
/* $Header: asoptcpb.pls 120.0.12010000.11 2015/05/28 19:22:05 rassharm noship $ */
-- Start of Comments
-- Package name     : ASO_COPY_TMPL_PUB
-- Purpose          :
--   This package body contains procedure for creating template from quote
--   Public  API of Order Capture.
--
--   Procedures:
--   Copy_Quote_To_Tmpl
--
-- History          :
-- NOTE             :
--
-- End of Comments

   G_USER_ID     NUMBER                := FND_GLOBAL.USER_ID;
   G_LOGIN_ID    NUMBER                := FND_GLOBAL.CONC_LOGIN_ID;
   G_PKG_NAME CONSTANT VARCHAR2 ( 30 ) := 'ASO_COPY_TMPL _PUB';
   G_FILE_NAME CONSTANT VARCHAR2 ( 12 ) := 'asoptcpb.pls';


PROCEDURE Copy_Quote_To_Tmpl (
     P_Api_Version_Number IN NUMBER
    , P_Init_Msg_List IN VARCHAR2 := FND_API.G_FALSE
    , P_Commit IN VARCHAR2 := FND_API.G_FALSE
    , P_old_quote_header_Id IN NUMBER
    , X_Qte_Header_Id OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Qte_Number OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS

      CURSOR C_Qte_Number IS
         SELECT ASO_QUOTE_NUMBER_S.NEXTVAL
         FROM   sys.DUAL;

    CURSOR C_Qte_Details
      (l_quote_header_Id NUMBER)
      IS
         select org_id,quote_name||':'||quote_number||':'||quote_version qte_name,currency_code,price_list_id,order_type_id,quote_category_code
	 from aso_Quote_headers_all
	 where quote_header_id=l_quote_header_Id;


	CURSOR C_Qte_Status_Id (
          c_status_code VARCHAR2
       ) IS
         SELECT quote_status_id
         FROM   ASO_QUOTE_STATUSES_B
         WHERE  status_code = c_status_code;

      l_api_name CONSTANT VARCHAR2 ( 30 ) := 'Copy_Quote_To_Tmpl';
      l_api_version_number CONSTANT NUMBER := 1.0;
      l_return_status VARCHAR2 ( 1 );
      l_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type;
      l_qte_num NUMBER;
      l_quote_name varchar2(2000);
      l_currency_code varchar2(15);
      l_price_list_id number;
      l_order_type_id number;
      l_quote_category_code varchar2(240);

      -- ER 3177722
       lx_config_tbl                  ASO_QUOTE_PUB.Config_Vaild_Tbl_Type;
       l_copy_config_profile     varchar2(1):=nvl(fnd_profile.value('ASO_COPY_CONFIG_EFF_DATE'),'Y');


    begin

         -- Standard Start of API savepoint
      SAVEPOINT COPY_QUOTE_TO_TMPL;
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
         FND_MESSAGE.Set_Name ('ASO' , 'Copy Quote To Template API: Start' );
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

 IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Tmpl - Begin- ASO_COPY_TMPL_PUB.Copy_Tmpl_to_tmpl ' , 1 , 'Y' );
	  aso_debug_pub.ADD ( 'Copy_Tmpl - Begin- ASO_COPY_TMPL_PUB.Copy_Quote_to_tmpl quote_header_id'||P_old_quote_header_Id , 1 , 'Y' );
 end if;

  OPEN C_Qte_Number;
  FETCH C_Qte_Number INTO l_qte_header_rec.quote_number;
  CLOSE C_Qte_Number;

  l_qte_header_rec.quote_version := 1;
  l_qte_header_rec.max_version_flag := 'Y';
  l_qte_header_rec.AUTOMATIC_PRICE_FLAG:= 'A';
  l_qte_header_rec.AUTOMATIC_Tax_FLAG:= 'A';
   l_qte_header_rec.PRICING_STATUS_INDICATOR:='I';
   l_qte_header_rec.Tax_STATUS_INDICATOR:='I';
   l_qte_header_rec.QUOTE_SOURCE_CODE  := 'Order Capture Quotes';
   l_qte_header_rec.QUOTE_TYPE := 'T';


  OPEN C_Qte_Details(P_old_quote_header_Id);
  FETCH C_Qte_Details INTO l_qte_header_rec.org_id,l_quote_name,l_currency_code,l_price_list_id,l_order_type_id,l_quote_category_code;
  CLOSE C_Qte_Details;

   l_qte_header_rec.QUOTE_NAME:=substr(l_quote_name,1,240);
   l_qte_header_rec.currency_code:= l_currency_code;
   l_qte_header_rec.order_type_id:=l_order_type_id;
   l_qte_header_rec.quote_category_code:=l_quote_category_code;


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



   IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Tmpl - Begin- ASO_COPY_TMPL_PUB.Copy_Quote_to_tmpl ' , 1 , 'Y' );
	  aso_debug_pub.ADD ( 'Copy_Tmpl - Begin- ASO_COPY_TMPL_PUB.Copy_Quote_to_tmpl quote_number'|| l_qte_header_rec.quote_number , 1 , 'Y' );
  	  aso_debug_pub.ADD ( 'Copy_Tmpl - Begin- ASO_COPY_TMPL_PUB.Copy_Quote_to_tmpl org_id'|| l_qte_header_rec.org_id , 1 , 'Y' );
 end if;


        l_qte_header_rec.TOTAL_LIST_PRICE := NULL;
         l_qte_header_rec.TOTAL_ADJUSTED_AMOUNT := NULL;
         l_qte_header_rec.TOTAL_ADJUSTED_PERCENT := NULL;
         l_qte_header_rec.TOTAL_TAX := NULL;
         l_qte_header_rec.TOTAL_SHIPPING_CHARGE := NULL;
         l_qte_header_rec.SURCHARGE := NULL;
         l_qte_header_rec.TOTAL_QUOTE_PRICE := NULL;
         l_qte_header_rec.PAYMENT_AMOUNT := NULL;
         l_qte_header_rec.ORDERED_DATE := NULL;


      l_qte_header_rec.PUBLISH_FLAG := NULL;
      l_qte_header_rec.ORDER_ID  := NULL;
      l_qte_header_rec.ORDER_NUMBER := NULL;
      l_qte_header_rec.quote_header_id := NULL;
      l_qte_header_rec.price_updated_date := NULL;
      l_qte_header_rec.tax_updated_date := NULL;
      l_qte_header_rec.price_request_id := NULL;
      l_qte_header_rec.price_frozen_date := NULL;


    l_qte_header_rec.Customer_Name_And_Title := NULL;
    l_qte_header_rec.Customer_Signature_Date := NULL;
    l_qte_header_rec.Supplier_Name_And_Title := NULL;
    l_qte_header_rec.Supplier_Signature_Date := NULL;
    l_qte_header_rec.OBJECT_VERSION_NUMBER:=1;

     l_qte_header_rec.ASSISTANCE_REQUESTED := null;
     l_qte_header_rec.ASSISTANCE_REASON_CODE := null;


      Copy_Tmpl_Header (
          P_Api_Version_Number =>         1.0
       , P_Init_Msg_List =>               FND_API.G_FALSE
       , P_Commit =>                      FND_API.G_FALSE
       , P_qte_Header_Rec =>              l_qte_header_rec
        , X_Qte_Header_id =>               x_qte_header_id
       , X_Return_Status =>               l_return_status
       , X_Msg_Count =>                   x_msg_count
       , X_Msg_Data =>                    x_msg_data
       );
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Tmpl - After copy_ header rows ' || l_return_status , 1 , 'Y' );
	 END IF;

     X_Qte_Number:= l_qte_header_rec.quote_number;
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

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_template -  before copy template rows ', 1 , 'Y' );
     END IF;



          Copy_Tmpl_Lines (
            P_Api_Version_Number =>         1.0
          , P_Init_Msg_List =>               FND_API.G_FALSE
          , P_Commit =>                      FND_API.G_FALSE
          , P_qte_Header_Id =>               P_old_quote_header_Id
          , P_new_qte_header_id =>           x_qte_header_id
          --, P_Qte_Header_Rec         =>   l_copy_line_qte_header_rec
          , P_Control_Rec            =>   ASO_QUOTE_PUB.G_MISS_Control_Rec
         , X_Return_Status =>               l_return_status
          , X_Msg_Count =>                   x_msg_count
          , X_Msg_Data =>                    x_msg_data
          );
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_template -  template rows  ' || l_return_status , 1 , 'Y' );
	    END IF;

       if (l_return_status =FND_API.G_RET_STS_SUCCESS) then


         if l_copy_config_profile='N' then
	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
		 aso_debug_pub.add('Copy_template -before   ASO_QUOTE_PUB.validate_model_configuration return status:  ', 1, 'N');
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

      if l_Return_Status=FND_API.G_RET_STS_SUCCESS then
                       commit work;
    end if;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.add('Copy_template -After  ASO_QUOTE_PUB.validate_model_configuration return status:  '||l_Return_Status, 1, 'N');
			aso_debug_pub.add('Copy_template -After  ASO_QUOTE_PUB.validate_model_configuration lx_config_tbl:  '||lx_config_tbl.count, 1, 'N');
      END IF;

     end if; -- profile
 end if; -- success



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

     X_Return_Status := l_return_status;

    end Copy_Quote_To_Tmpl;

    PROCEDURE Copy_Tmpl_Header (
       P_Api_Version_Number IN NUMBER
    , P_Init_Msg_List IN VARCHAR2 := FND_API.G_FALSE
    , P_Commit IN VARCHAR2 := FND_API.G_FALSE
    , P_Qte_Header_Rec IN ASO_QUOTE_PUB.qte_header_rec_Type
    , X_Qte_Header_Id OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    ) IS

    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2 ( 1 );
    l_api_name CONSTANT VARCHAR2 ( 30 ) := 'Copy_Tmpl_Header';
    l_api_version_number CONSTANT NUMBER := 1.0;


   -- out tables parameters
     l_qte_header_rec_out ASO_QUOTE_PUB.Qte_Header_Rec_Type;
     l_Price_Attr_Tbl_out ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
     l_Price_Adj_Attr_Tbl_out ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
     l_freight_charge_tbl_out ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
      l_tax_detail_tbl_out ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
      l_payment_tbl_out ASO_QUOTE_PUB.Payment_Tbl_Type;
       l_hd_Price_Adj_Tbl_out ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
       l_shipment_rec_out ASO_QUOTE_PUB.Shipment_Rec_Type;
       l_hd_Attr_Ext_Tbl_out ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
      l_Sales_Credit_Tbl_out ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
      l_Quote_Party_Tbl_out ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
      l_qte_access_tbl_out   aso_quote_pub.qte_access_tbl_type ;



begin

      -- Standard Start of API savepoint
      SAVEPOINT COPY_TMPL_HEADER;

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
         FND_MESSAGE.Set_Name ('ASO' , 'Copy Template Header API: Start'||P_Qte_Header_Rec.quote_number );
         FND_MSG_PUB.ADD;
      END IF;

      --  Initialize API return status to success
      l_return_status            := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      ASO_QUOTE_HEADERS_PVT.Insert_Rows (
          p_qte_header_rec =>             P_Qte_Header_Rec
       , p_Price_Attributes_Tbl =>       aso_quote_pub.G_Miss_Price_Attributes_Tbl
       , P_Price_Adjustment_Tbl =>   aso_quote_pub.G_MISS_Price_Adj_TBL
       , P_Price_Adj_Attr_Tbl =>          aso_quote_pub.G_MISS_PRICE_ADJ_ATTR_TBL
       , P_Payment_Tbl =>                   aso_quote_pub.G_MISS_PAYMENT_TBL
       , P_Shipment_Tbl =>                 aso_quote_pub.G_MISS_Shipment_TBL
       , P_Freight_Charge_Tbl =>      aso_quote_pub.G_Miss_Freight_Charge_Tbl
       , P_Tax_Detail_Tbl =>                aso_quote_pub.G_Miss_Tax_Detail_Tbl
       , P_hd_Attr_Ext_Tbl =>               aso_quote_pub.G_MISS_Line_Attribs_Ext_TBL
       , P_Sales_Credit_Tbl =>           aso_quote_pub.G_MISS_Sales_Credit_Tbl
       , P_Quote_Party_Tbl =>             aso_quote_pub.G_MISS_Quote_Party_Tbl
       , P_qte_access_Tbl =>              aso_quote_pub.G_MISS_QTE_ACCESS_TBL
	 , x_qte_header_rec =>              l_qte_header_rec_out
       , x_Price_Attributes_Tbl =>        l_price_attr_tbl_out
       , x_Price_Adjustment_Tbl =>     l_hd_Price_Adj_Tbl_out
       , x_Price_Adj_Attr_Tbl =>          l_price_adj_attr_tbl_out
       , x_Payment_Tbl =>                 l_payment_tbl_out
       , x_Shipment_Rec =>                l_shipment_rec_out
       , x_Freight_Charge_Tbl =>          l_freight_charge_tbl_out
       , x_Tax_Detail_Tbl =>              l_tax_detail_tbl_out
       , x_hd_Attr_Ext_Tbl =>             l_hd_Attr_Ext_Tbl_out
       , x_sales_credit_tbl =>            l_sales_credit_tbl_out
       , x_quote_party_tbl =>             l_quote_party_tbl_out
       , x_qte_access_Tbl =>             l_qte_access_tbl_out
       , X_Return_Status =>               l_return_status
       , X_Msg_Count =>                   x_msg_count
       , X_Msg_Data =>                    x_msg_data
       );



      --l_qte_header_rec :=l_qte_header_rec_out ;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( 'Copy_Template - After insert_rows - status: ' || l_return_status , 1 , 'Y' );
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

      x_qte_header_id            := l_qte_header_rec_out.quote_header_id;

       X_Return_Status := l_return_status;

end Copy_Tmpl_Header;


PROCEDURE Copy_Tmpl_Lines(
     P_Api_Version_Number          IN   NUMBER,
     P_Init_Msg_List               IN   VARCHAR2     := FND_API.G_FALSE,
     P_Commit                      IN   VARCHAR2     := FND_API.G_FALSE,
     P_Qte_Header_Id          IN   NUMBER,
     P_New_Qte_Header_Id      IN   NUMBER,
     P_Control_Rec            IN   ASO_QUOTE_PUB.Control_Rec_Type,
     X_Return_Status          OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
     X_Msg_Count              OUT NOCOPY /* file.sql.39 change */     NUMBER,
     X_Msg_Data               OUT NOCOPY /* file.sql.39 change */     VARCHAR2 )
     as
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
      l_control_rec ASO_QUOTE_PUB.Control_Rec_Type;

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

         l_val varchar2(1);
--    l_appl_param_rec   CZ_API_PUB.appl_param_rec_type;
         l_last_update_date   DATE;
         l_line_number        NUMBER;



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

      l_copy_flag                     varchar2(1):='T';


   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT COPY_TMPL_LINES;

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
         FND_MESSAGE.Set_Name ('ASO' , 'Copy Template Lines API: Start' );
         FND_MSG_PUB.ADD;
      END IF;

      --  Initialize API return status to success
      x_return_status            := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ('Copy_Template - Header and Lines' , 1, 'N' );
	 END IF;


      l_qte_line_tbl             :=   ASO_UTILITY_PVT.Query_Qte_Line_Rows ( p_qte_header_id );


      FOR i IN 1 .. l_qte_line_tbl.COUNT LOOP
         l_line_index_link_tbl ( l_qte_line_tbl ( i ).quote_line_id ) :=   FND_API.G_MISS_NUM;
      END LOOP;



      FOR i IN 1 .. l_qte_line_tbl.COUNT LOOP
          l_copy_flag:='T';

          IF l_qte_line_tbl ( i ).uom_code = 'ENR' THEN
            l_copy_flag:='F';
           END IF;

         -- for promotional items
	 if  l_qte_line_tbl ( i ).PRICING_LINE_TYPE_INDICATOR='F' then
	      l_copy_flag:='F';
         END IF;

         l_qte_line_tbl ( i ).quote_header_id := P_New_Qte_Header_Id;
         l_qte_line_id              := l_qte_line_tbl ( i ).quote_line_id;

          -- Setting customer information, price list and currency to null bug 10212323
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

          -- Setting DFF information, to null (bug 12850154)
	 l_qte_line_tbl( i ).ATTRIBUTE_CATEGORY := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE1 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE2 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE3 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE4 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE5 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE6 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE7 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE8 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE9 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE10 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE11 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE12 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE13 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE14 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE15 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE16 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE17 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE18 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE19 := Null;
	 l_qte_line_tbl( i ).ATTRIBUTE20 := Null;


         IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.ADD (   'qte line id = ' || l_qte_line_id, 1, 'N' );
		aso_debug_pub.ADD (   'i = ' || i, 1, 'N' );
		aso_debug_pub.ADD ( 'item_type_code = ' || l_qte_line_tbl ( i ).item_type_code , 1 , 'N' );
		 aso_debug_pub.ADD ( 'l_copy_flag ='||l_copy_flag);
	 END IF;



         IF  (l_copy_flag = 'T') then
            IF l_line_index_link_tbl ( l_qte_line_id ) = FND_API.G_MISS_NUM THEN

              l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows ( l_qte_line_id );

          -- for reconfigure from install base
	     IF l_qte_line_tbl(i).line_category_code = 'RETURN' THEN

	         IF ( l_qte_line_dtl_tbl(1).RETURN_REF_TYPE = 'SALES ORDER' AND   l_qte_line_dtl_tbl(1).RETURN_REF_LINE_ID IS NOT NULL AND
                       l_qte_line_dtl_tbl(1).INSTANCE_ID IS NOT NULL )      OR ( l_qte_line_dtl_tbl(1).REF_TYPE_CODE = 'TOP_MODEL' ) THEN
                                 l_copy_flag:='F';
		                 IF aso_debug_pub.g_debug_flag = 'Y' THEN
			              aso_debug_pub.ADD ('Install Base Check Failed' , 1, 'N' );
			          END IF;

                   end if;
              end if;  -- end "RETURN"


          -- for Trade in
          IF (l_qte_line_tbl(i).item_type_code = 'STD' ) and ( l_qte_line_tbl(i).line_category_code = 'RETURN' )THEN
	      if     (l_qte_line_dtl_tbl(1).INSTANCE_ID IS NOT NULL)  then
                   l_copy_flag:='F';
		   IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ('Trade in from install Base Check Failed' , 1, 'N' );
		    END IF;
	       end if;
          end if;  -- Trade in






               IF (l_qte_line_tbl ( i ).item_type_code = 'MDL' ) and (l_copy_flag='T') THEN

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



         --    Only copy only with no service reference and service reference with current quote
	 IF      l_service_item_flag = 'Y'
                AND (l_qte_line_dtl_tbl ( 1 ).service_ref_type_code IS NULL OR
			     l_qte_line_dtl_tbl ( 1 ).service_ref_type_code <> 'QUOTE' )
			     THEN
               l_service_item_flag        := 'N';
	       -- Do not copy service ref type other than quote
	       if   (l_qte_line_dtl_tbl ( 1 ).service_ref_type_code IS NOT NULL) then
   	           l_copy_flag := 'F';
               end if;
       END IF;

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.ADD ( 'service item flag 2= ' || l_service_item_flag , 1 , 'N' );
		  END IF;






            IF      l_qte_line_tbl ( i ).item_type_code <> 'CFG'
                AND l_qte_line_tbl ( i ).item_type_code <> 'OPT'
                AND l_service_item_flag <> 'Y'
		AND (l_copy_flag='T') THEN

               -- Setting Pricing parameters as null
              l_qte_line_tbl(i).line_list_price:=FND_API.G_MISS_NUM;
	      -- l_qte_line_tbl(i).unit_price:=FND_API.G_MISS_NUM;  -- bug 17517305
  	      l_qte_line_tbl(i).line_adjusted_amount:=FND_API.G_MISS_NUM;
              l_qte_line_tbl(i).line_Quote_price:=FND_API.G_MISS_NUM;
              l_qte_line_tbl(i).priced_price_list_id:=FND_API.G_MISS_NUM;
              l_qte_line_tbl(i).pricing_quantity_uom:=null;
              l_qte_line_tbl(i).pricing_quantity:=FND_API.G_MISS_NUM;


           -- Setting the shipment data
	       l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(p_qte_header_id, L_QTE_LINE_ID);
	       l_qte_line_tbl(i).quote_line_id := NULL;

               l_qte_line_tbl ( i ).object_version_number := FND_API.G_MISS_NUM;

	       FOR j IN 1 .. l_shipment_tbl.COUNT LOOP
                 l_shipment_tbl( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
		 l_shipment_tbl( j ).shipment_id := null;
                 l_shipment_tbl( j ).object_version_number := FND_API.G_MISS_NUM;
		 l_shipment_tbl( j ).SHIP_TO_CUST_ACCOUNT_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_CUST_PARTY_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_PARTY_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_PARTY_SITE_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_PARTY_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_CONTACT_FIRST_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_CONTACT_MIDDLE_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_CONTACT_LAST_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS1 := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS2 := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS3 := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS4 := Null;
	         l_shipment_tbl( j ).SHIP_TO_COUNTRY_CODE := Null;
	         l_shipment_tbl( j ).SHIP_TO_COUNTRY := Null;
	         l_shipment_tbl( j ).SHIP_TO_CITY := Null;
	         l_shipment_tbl( j ).SHIP_TO_POSTAL_CODE := Null;
	         l_shipment_tbl( j ).SHIP_TO_STATE := Null;
	         l_shipment_tbl( j ).SHIP_TO_PROVINCE := Null;
	         l_shipment_tbl( j ).SHIP_TO_COUNTY := Null;
		 l_shipment_tbl( j ).FREIGHT_TERMS_CODE := Null;
		 l_shipment_tbl( j ).FOB_CODE := Null;
	         l_shipment_tbl( j ).DEMAND_CLASS_CODE := Null;
	         l_shipment_tbl( j ).REQUEST_DATE_TYPE := Null;
	         l_shipment_tbl( j ).REQUEST_DATE := Null;
	         l_shipment_tbl( j ).SHIPMENT_PRIORITY_CODE := Null;
	         l_shipment_tbl( j ).SHIPPING_INSTRUCTIONS := Null;
	         l_shipment_tbl( j ).PACKING_INSTRUCTIONS := Null;
		END LOOP;




               --BC4J Fix

               FOR j IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP
		         l_qte_line_dtl_tbl(j).quote_line_detail_id := null;
                          l_qte_line_dtl_tbl(j).object_version_number := FND_API.G_MISS_NUM;
			  l_qte_line_dtl_tbl(j).top_model_line_id := null;
			  l_qte_line_dtl_tbl(j).ato_line_id := null;
                          l_qte_line_dtl_tbl(j).qte_line_index := i;
		END LOOP;





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
      l_payment_tbl := l_payment_tbl_out     ;
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
			aso_debug_pub.ADD ( 'Copy_Template - After insert_quote_line_rows - status: ' || l_return_status , 1 , 'Y' );
			END IF;

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Copy_Template - Updating the top model and ato line id for the top model line ', 1 , 'Y' );
			aso_debug_pub.ADD ( 'Copy_Template - l_ato_model: ' || l_ato_model , 1 , 'Y' );
			END IF;
               update aso_quote_line_details
			set top_model_line_id =  lx_qte_line_rec.quote_line_id,
			    ato_line_id       =  decode(l_ato_model,fnd_api.g_true,lx_qte_line_rec.quote_line_id,null)
			where quote_line_id = lx_qte_line_rec.quote_line_id;


             l_line_index_link_tbl ( l_qte_line_id ) :=
                                                 lx_qte_line_rec.quote_line_id;
               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( 'Copy_Config - l_qte_line_tbl(i).item_type_code ' || l_qte_line_tbl ( i ).item_type_code , 1 , 'Y' );
			aso_debug_pub.ADD ( 'Copy - l_qte_line_tbl(i).inventory_item_id ' || l_qte_line_tbl ( i ).inventory_item_id , 1 , 'Y' );
			aso_debug_pub.ADD ( 'Copy - l_serviceable_product_flag ' || l_serviceable_product_flag , 1 , 'Y' );
		END IF;


            -- code for copying service

	     IF (l_serviceable_product_flag = 'Y' ) and (l_copy_flag='T') THEN

	            IF aso_debug_pub.g_debug_flag = 'Y' THEN
			  aso_debug_pub.ADD ( 'Before Calling Service Copy ' , 1 , 'N' );
	            END IF;

			 Copy_Tmpl_Service (
                      p_qte_line_id =>                l_qte_line_id
                     , p_new_qte_header_id =>           p_new_qte_header_id
                     , p_qte_header_id =>               p_qte_header_id
                     , lx_line_index_link_tbl =>        l_line_index_link_tbl
                     , X_Return_Status =>               l_return_status
                      , X_Msg_Count =>                   x_msg_count
                      , X_Msg_Data =>                    x_msg_data
                    );



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

           END IF;






            END IF; -- If <> CFG and OPT



            IF (l_qte_line_tbl ( i ).item_type_code = 'MDL' ) and (l_copy_flag='T') THEN
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
                        aso_debug_pub.ADD ( ' Before Calling Tmpl  Quote Config Copy' , 1 , 'N' );
			END IF;

			Config_Copy_Tmpl (
                   p_old_config_header_id =>       l_old_config_header_id
                , p_old_config_revision_num =>     l_old_config_revision_num
                , p_config_header_id =>            l_config_hdr_id
                , p_config_revision_num =>         l_config_rev_nbr
                , p_new_qte_header_id =>           p_new_qte_header_id
                , p_qte_header_id =>               p_qte_header_id
                , lx_line_index_link_tbl =>        l_line_index_link_tbl
               -- , lx_price_index_link_tbl =>       l_price_index_link_tbl
                , X_Return_Status =>               l_return_status
                , X_Msg_Count =>                   x_msg_count
                , X_Msg_Data =>                    x_msg_data
               );

               IF aso_debug_pub.g_debug_flag = 'Y' THEN
			aso_debug_pub.ADD ( ' After Calling Copy Tmp  Config Copy' , 1 , 'N' );
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

      END IF; -- for copy_flag


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
--end if;




      IF aso_debug_pub.g_debug_flag = 'Y' THEN
	 aso_debug_pub.ADD ( ' End Copy template Lines API ', 1 , 'N' );
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



     end Copy_Tmpl_Lines;

     PROCEDURE Copy_Tmpl_Service(
       p_qte_line_id IN NUMBER
    , p_new_qte_header_id IN NUMBER
    , p_qte_header_id IN NUMBER
    , lx_line_index_link_tbl IN OUT NOCOPY  ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2

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
	 aso_debug_pub.ADD ('Copy_Tmpl_Service - Begin ' , 1, 'Y' );
      aso_debug_pub.ADD ( 'Copy_Tmpl_Service - p_new_qte_header_id ' || p_new_qte_header_id , 1 , 'Y' );
      aso_debug_pub.ADD ( 'Copy_Tmpl_Service - p_qte_header_id ' || p_qte_header_id , 1 , 'Y' );
      aso_debug_pub.ADD ( 'Copy_Tmpl_Service - p_qte_line_id ' || p_qte_line_id , 1 , 'Y' );
	 END IF;

      x_return_status            := FND_API.G_RET_STS_SUCCESS;

      OPEN line_id_from_service ( p_qte_line_id );

      LOOP
         FETCH line_id_from_service INTO qte_line_id;
         EXIT WHEN line_id_from_service%NOTFOUND;
         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Tmpl_Service - inside cursor qte_line_id ' || qte_line_id , 1 , 'Y' );
	    END IF;

         l_qte_line_rec             :=
                           ASO_UTILITY_PVT.Query_Qte_Line_Row ( qte_line_id );

          IF p_new_qte_header_id = p_qte_header_id THEN

           OPEN get_qte_line_number(lx_line_index_link_tbl(p_qte_line_id));
           FETCH get_qte_line_number into l_line_number;
           CLOSE get_qte_line_number;

           l_qte_line_rec.line_number := l_line_number;

          END IF;


         l_qte_line_rec.quote_header_id := p_new_qte_header_id;
         l_qte_line_dtl_tbl         :=
                          ASO_UTILITY_PVT.Query_Line_Dtl_Rows ( qte_line_id );

         IF l_qte_line_dtl_tbl.COUNT > 0 THEN

            FOR k IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP


	       IF l_qte_line_dtl_tbl ( k ).service_ref_type_code = 'QUOTE' THEN

                  IF l_qte_line_dtl_tbl ( k ).service_ref_line_id IS NOT NULL THEN

                     IF aso_debug_pub.g_debug_flag = 'Y' THEN
				 aso_debug_pub.ADD ( 'Copy_Tmpl_Service - l_qte_line_dtl_tbl(k).service_ref_line_id ' || l_qte_line_dtl_tbl ( k ).service_ref_line_id , 1 , 'Y' );
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
	    aso_debug_pub.ADD ( 'Copy_Tmpl_Service - 2 l_service_ref_line_id ' || l_service_ref_line_id , 1 , 'Y' );
	    END IF;

         --l_line_attr_Ext_Tbl := ASO_UTILITY_PVT.Query_Line_Attribs_Ext_Rows ( qte_line_id );

         --l_price_adj_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Rows ( p_qte_header_id , qte_line_id );

	   -- l_dup_price_adj_tbl := l_price_adj_tbl;

         --l_price_adj_attr_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Attr_Rows ( p_price_adj_tbl => l_price_adj_tbl );

         --l_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows ( p_qte_header_id , qte_line_id );

         --l_payment_tbl := ASO_UTILITY_PVT.Query_Payment_Rows ( p_qte_header_id , QTE_LINE_ID );

         l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows ( p_qte_header_id , QTE_LINE_ID );

         --l_sales_credit_tbl := ASO_UTILITY_PVT.Query_Sales_Credit_Row ( p_qte_header_id , QTE_LINE_ID );

         --l_quote_party_tbl := ASO_UTILITY_PVT.Query_Quote_Party_Row ( p_qte_header_id , QTE_LINE_ID );

         --l_freight_charge_tbl := ASO_UTILITY_PVT.Query_Freight_Charge_Rows ( l_shipment_tbl );

         --l_tax_detail_tbl := ASO_UTILITY_PVT.Query_Tax_Detail_Rows ( p_qte_header_id , QTE_LINE_ID , l_shipment_tbl );

         l_qte_line_rec.quote_line_id := NULL;
         l_qte_line_rec.object_version_number := FND_API.G_MISS_NUM;

	 --Setting line attributes as null as they are not required for template 10212323

	 l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID := Null;
         l_qte_line_rec.INVOICE_TO_PARTY_ID := Null;
	 l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID := Null;
	 l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID := Null;

	 l_qte_line_rec.END_CUSTOMER_PARTY_ID := Null;
	 l_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID := Null;
	 l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := Null;
	 l_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID := Null;

	 l_qte_line_rec.PRICE_LIST_ID := Null;
	 l_qte_line_rec.CURRENCY_CODE := Null;

	 l_qte_line_rec.line_list_price:= NULL;
	 --l_qte_line_rec.unit_price:=null;  -- bug 17517305
  	 l_qte_line_rec.line_adjusted_amount:= NULL;
         l_qte_line_rec.line_Quote_price:= NULL;
         l_qte_line_rec.priced_price_list_id:= NULL;
         l_qte_line_rec.pricing_quantity_uom:= null;
         l_qte_line_rec.pricing_quantity:= NULL;


     --BC4J Fix

         FOR j IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP
	       l_qte_line_dtl_tbl(j).quote_line_detail_id := null;
            l_qte_line_dtl_tbl(j).object_version_number := FND_API.G_MISS_NUM;
	    END LOOP;

         /*FOR j IN 1 .. l_price_adj_tbl.COUNT LOOP
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

         */
         FOR j IN 1 .. l_shipment_tbl.COUNT LOOP
                 l_shipment_tbl( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
                 l_shipment_tbl( j ).shipment_id := null;
		 l_shipment_tbl( j ).object_version_number := FND_API.G_MISS_NUM;
		 l_shipment_tbl( j ).SHIP_TO_CUST_ACCOUNT_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_CUST_PARTY_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_PARTY_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_PARTY_SITE_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_PARTY_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_CONTACT_FIRST_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_CONTACT_MIDDLE_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_CONTACT_LAST_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS1 := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS2 := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS3 := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS4 := Null;
	         l_shipment_tbl( j ).SHIP_TO_COUNTRY_CODE := Null;
	         l_shipment_tbl( j ).SHIP_TO_COUNTRY := Null;
	         l_shipment_tbl( j ).SHIP_TO_CITY := Null;
	         l_shipment_tbl( j ).SHIP_TO_POSTAL_CODE := Null;
	         l_shipment_tbl( j ).SHIP_TO_STATE := Null;
	         l_shipment_tbl( j ).SHIP_TO_PROVINCE := Null;
	         l_shipment_tbl( j ).SHIP_TO_COUNTY := Null;
		 l_shipment_tbl( j ).FREIGHT_TERMS_CODE := Null;
		 l_shipment_tbl( j ).FOB_CODE := Null;
	         l_shipment_tbl( j ).DEMAND_CLASS_CODE := Null;
	         l_shipment_tbl( j ).REQUEST_DATE_TYPE := Null;
	         l_shipment_tbl( j ).REQUEST_DATE := Null;
	         l_shipment_tbl( j ).SHIPMENT_PRIORITY_CODE := Null;
	         l_shipment_tbl( j ).SHIPPING_INSTRUCTIONS := Null;
	         l_shipment_tbl( j ).PACKING_INSTRUCTIONS := Null;
         END LOOP;

/*
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
*/

	--End of BC4J Fix

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Tmpl_Service - Before insert_quote_line_rows: ' || p_qte_line_id , 1 , 'Y' );
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


         lx_line_index_link_tbl ( qte_line_id ) := lx_qte_line_rec.quote_line_id;



      END LOOP;

      CLOSE line_id_from_service;

   END Copy_Tmpl_Service;

     PROCEDURE Config_Copy_Tmpl (
       p_old_config_header_id IN NUMBER
    , p_old_config_revision_num IN NUMBER
    , p_config_header_id IN NUMBER
    , p_config_revision_num IN NUMBER
    , p_new_qte_header_id IN NUMBER
    , p_qte_header_id IN NUMBER
    , lx_line_index_link_tbl IN OUT NOCOPY ASO_QUOTE_HEADERS_PVT.Index_Link_Tbl_Type
    , X_Return_Status OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    , X_Msg_Count OUT NOCOPY /* file.sql.39 change */   NUMBER
    , X_Msg_Data OUT NOCOPY /* file.sql.39 change */   VARCHAR2
)  as
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
	 aso_debug_pub.ADD ('Copy_Config_Tmpl - Begin ' , 1, 'Y' );
      aso_debug_pub.ADD ( 'Copy_Config_Tmpl - p_new_qte_header_id ' || p_new_qte_header_id , 1 , 'Y' );
      aso_debug_pub.ADD ( 'Copy_Config_Tmpl - p_qte_header_id ' || p_qte_header_id , 1 , 'Y' );
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
	    aso_debug_pub.ADD ( 'Copy_Config_Tmpl - inside cursor qte_line_id ' || qte_line_id , 1 , 'Y' );
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


         l_qte_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows ( qte_line_id );

         FOR k IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP
            l_qte_line_dtl_tbl ( k ).config_header_id := p_config_header_id;
            l_qte_line_dtl_tbl ( k ).config_revision_num := p_config_revision_num;
         END LOOP;

        /* l_line_attr_Ext_Tbl := ASO_UTILITY_PVT.Query_Line_Attribs_Ext_Rows ( qte_line_id );

         l_price_adj_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Rows ( p_qte_header_id , qte_line_id );
	    l_dup_price_adj_tbl := l_price_adj_tbl;

         l_price_adj_attr_tbl := ASO_UTILITY_PVT.Query_Price_Adj_Attr_Rows(p_price_adj_tbl => l_price_adj_tbl);

         l_price_attr_tbl := ASO_UTILITY_PVT.Query_Price_Attr_Rows ( p_qte_header_id , qte_line_id );

         */

         l_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows ( p_qte_header_id , qte_line_id );

         /*l_sales_credit_tbl := ASO_UTILITY_PVT.Query_Sales_Credit_Row ( p_qte_header_id , qte_line_id );

         l_quote_party_tbl := ASO_UTILITY_PVT.Query_Quote_Party_Row ( p_qte_header_id , qte_line_id );

         l_freight_charge_tbl := ASO_UTILITY_PVT.Query_Freight_Charge_Rows ( l_shipment_tbl );

         l_tax_detail_tbl := ASO_UTILITY_PVT.Query_Tax_Detail_Rows ( p_qte_header_id , qte_line_id , l_shipment_tbl );

        */

         OPEN C_Serviceable_Product ( l_qte_line_rec.organization_id , l_qte_line_rec.inventory_item_id );
         FETCH C_Serviceable_Product INTO l_serviceable_product_flag;
         CLOSE C_Serviceable_Product;

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.ADD ('Copy_Config_Tmpl - After querying all the records for the line ' , 1, 'Y' );
	    END IF;

         FOR j IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP

            IF aso_debug_pub.g_debug_flag = 'Y' THEN
	           aso_debug_pub.ADD ('Copy_Config_Tmpl - l_qte_line_dtl_tbl('||j||')ref_line_id: '||l_qte_line_dtl_tbl(j).ref_line_id , 1, 'Y' );
	           aso_debug_pub.ADD ('Copy_Config_Tmpl - l_qte_line_dtl_tbl('||j||')top_model_line_id: '||l_qte_line_dtl_tbl(j).top_model_line_id , 1, 'Y' );
	           aso_debug_pub.ADD ('Copy_Config_Tmpl - l_qte_line_dtl_tbl('||j||')ato_line_id: '||l_qte_line_dtl_tbl(j).ato_line_id , 1, 'Y' );
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

	  --Setting line attributes as null as they are not required for template 10212323

	 l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID := Null;
         l_qte_line_rec.INVOICE_TO_PARTY_ID := Null;
	 l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID := Null;
	 l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID := Null;

	 l_qte_line_rec.END_CUSTOMER_PARTY_ID := Null;
	 l_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID := Null;
	 l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := Null;
	 l_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID := Null;

	 l_qte_line_rec.PRICE_LIST_ID := Null;
	 l_qte_line_rec.CURRENCY_CODE := Null;

	 l_qte_line_rec.line_list_price:= NULL;
	 --l_qte_line_rec.unit_price:= NULL; -- bug 17517305
  	 l_qte_line_rec.line_adjusted_amount:= NULL;
         l_qte_line_rec.line_Quote_price:= NULL;
         l_qte_line_rec.priced_price_list_id:= NULL;
         l_qte_line_rec.pricing_quantity_uom:= null;
         l_qte_line_rec.pricing_quantity:= NULL;


	 --BC4J Fix

         FOR j IN 1 .. l_qte_line_dtl_tbl.COUNT LOOP
	       l_qte_line_dtl_tbl(j).quote_line_detail_id := null;
            l_qte_line_dtl_tbl(j).object_version_number := FND_API.G_MISS_NUM;
	    END LOOP;

         /*FOR j IN 1 .. l_price_adj_tbl.COUNT LOOP
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

         */

         FOR j IN 1 .. l_shipment_tbl.COUNT LOOP
                 l_shipment_tbl( j ).QUOTE_HEADER_ID := p_new_qte_header_id;
                 l_shipment_tbl( j ).shipment_id := null;
		 l_shipment_tbl( j ).object_version_number := FND_API.G_MISS_NUM;
		 l_shipment_tbl( j ).SHIP_TO_CUST_ACCOUNT_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_CUST_PARTY_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_PARTY_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_PARTY_SITE_ID := Null;
	         l_shipment_tbl( j ).SHIP_TO_PARTY_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_CONTACT_FIRST_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_CONTACT_MIDDLE_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_CONTACT_LAST_NAME := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS1 := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS2 := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS3 := Null;
	         l_shipment_tbl( j ).SHIP_TO_ADDRESS4 := Null;
	         l_shipment_tbl( j ).SHIP_TO_COUNTRY_CODE := Null;
	         l_shipment_tbl( j ).SHIP_TO_COUNTRY := Null;
	         l_shipment_tbl( j ).SHIP_TO_CITY := Null;
	         l_shipment_tbl( j ).SHIP_TO_POSTAL_CODE := Null;
	         l_shipment_tbl( j ).SHIP_TO_STATE := Null;
	         l_shipment_tbl( j ).SHIP_TO_PROVINCE := Null;
	         l_shipment_tbl( j ).SHIP_TO_COUNTY := Null;
		 l_shipment_tbl( j ).FREIGHT_TERMS_CODE := Null;
		 l_shipment_tbl( j ).FOB_CODE := Null;
	         l_shipment_tbl( j ).DEMAND_CLASS_CODE := Null;
	         l_shipment_tbl( j ).REQUEST_DATE_TYPE := Null;
	         l_shipment_tbl( j ).REQUEST_DATE := Null;
	         l_shipment_tbl( j ).SHIPMENT_PRIORITY_CODE := Null;
	         l_shipment_tbl( j ).SHIPPING_INSTRUCTIONS := Null;
	         l_shipment_tbl( j ).PACKING_INSTRUCTIONS := Null;
         END LOOP;

      /*   FOR j IN 1 .. l_sales_credit_tbl.COUNT LOOP
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
*/

	--End of BC4J Fix

         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	    aso_debug_pub.ADD ( 'Copy_Config_Tmpl - Before insert_quote_line_rows: ' || l_quote_line_id , 1 , 'Y' );
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



         lx_line_index_link_tbl(qte_line_id) := lx_qte_line_rec.quote_line_id;



         IF aso_debug_pub.g_debug_flag = 'Y' THEN
	       aso_debug_pub.ADD('Copy_Config_Tmpl - l_qte_line_tbl(i).item_type_code ' || l_qte_line_rec.item_type_code , 1 , 'Y' );
            aso_debug_pub.ADD('Copy - l_qte_line_tbl(i).inventory_item_id ' || l_qte_line_rec.inventory_item_id , 1 , 'Y' );
            aso_debug_pub.ADD('Copy - l_serviceable_product_flag ' || l_serviceable_product_flag , 1 , 'Y' );
	    END IF;

         IF l_serviceable_product_flag = 'Y' THEN

	     Copy_Tmpl_Service (
                      p_qte_line_id =>                l_quote_line_id
                     , p_new_qte_header_id =>           p_new_qte_header_id
                     , p_qte_header_id =>               p_qte_header_id
                     , lx_line_index_link_tbl =>        lx_line_index_link_tbl
                     , X_Return_Status =>               l_return_status
                      , X_Msg_Count =>                   x_msg_count
                      , X_Msg_Data =>                    x_msg_data
                    );


             IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
                IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
                  FND_MESSAGE.Set_Name ('ASO' , 'ASO_API_UNEXP_ERROR' );
                  FND_MESSAGE.Set_Token ( 'ROW' , 'ASO_COPY_TMPLCONFIG AFTER_SERVICE' , TRUE );
                   FND_MSG_PUB.ADD;
              END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
        END IF;
      END LOOP;

      CLOSE line_id_from_config;

end Config_Copy_Tmpl;

    end ASO_COPY_TMPL_PUB;

/
