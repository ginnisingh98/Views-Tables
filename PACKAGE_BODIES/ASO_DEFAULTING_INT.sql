--------------------------------------------------------
--  DDL for Package Body ASO_DEFAULTING_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_DEFAULTING_INT" AS
/* $Header: asoidefb.pls 120.7.12010000.7 2015/09/23 11:49:57 rassharm ship $ */
-- Package name     : ASO_DEFAULTING_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'ASO_DEFAULTING_INT';


  PROCEDURE Default_Entity (
    P_API_VERSION               IN        NUMBER,
    P_INIT_MSG_LIST             IN        VARCHAR2 := FND_API.G_FALSE,
    P_COMMIT                    IN        VARCHAR2 := FND_API.G_FALSE,
    P_CONTROL_REC               IN        CONTROL_REC_TYPE
                                            := G_MISS_CONTROL_REC,
    P_DATABASE_OBJECT_NAME      IN        VARCHAR2,
    P_TRIGGER_ATTRIBUTES_TBL    IN        ATTRIBUTE_CODES_TBL_TYPE
                                            := G_MISS_ATTRIBUTE_CODES_TBL,
    P_QUOTE_HEADER_REC          IN        ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_QTE_HEADER_REC,
    P_OPP_QTE_HEADER_REC        IN        ASO_OPP_QTE_PUB.OPP_QTE_IN_REC_TYPE
                                            := ASO_OPP_QTE_PUB.G_MISS_OPP_QTE_IN_REC,
    P_HEADER_MISC_REC           IN        HEADER_MISC_REC_TYPE
                                            := G_MISS_HEADER_MISC_REC,
    P_HEADER_SHIPMENT_REC       IN        ASO_QUOTE_PUB.SHIPMENT_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
    P_HEADER_PAYMENT_REC        IN        ASO_QUOTE_PUB.PAYMENT_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_PAYMENT_REC,
    P_HEADER_TAX_DETAIL_REC     IN        ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC,
    P_QUOTE_LINE_REC            IN        ASO_QUOTE_PUB.QTE_LINE_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC,
    P_LINE_MISC_REC             IN        LINE_MISC_REC_TYPE
                                            := G_MISS_LINE_MISC_REC,
    P_LINE_SHIPMENT_REC         IN        ASO_QUOTE_PUB.SHIPMENT_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_SHIPMENT_REC,
    P_LINE_PAYMENT_REC          IN        ASO_QUOTE_PUB.PAYMENT_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_PAYMENT_REC,
    P_LINE_TAX_DETAIL_REC       IN        ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE
                                            := ASO_QUOTE_PUB.G_MISS_TAX_DETAIL_REC,
    X_QUOTE_HEADER_REC          OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE,
    X_HEADER_MISC_REC           OUT NOCOPY /* file.sql.39 change */       HEADER_MISC_REC_TYPE,
    X_HEADER_SHIPMENT_REC       OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.SHIPMENT_REC_TYPE,
    X_HEADER_PAYMENT_REC        OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.PAYMENT_REC_TYPE,
    X_HEADER_TAX_DETAIL_REC     OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
    X_QUOTE_LINE_REC            OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.QTE_LINE_REC_TYPE,
    X_LINE_MISC_REC             OUT NOCOPY /* file.sql.39 change */       LINE_MISC_REC_TYPE,
    X_LINE_SHIPMENT_REC         OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.SHIPMENT_REC_TYPE,
    X_LINE_PAYMENT_REC          OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.PAYMENT_REC_TYPE,
    X_LINE_TAX_DETAIL_REC       OUT NOCOPY /* file.sql.39 change */       ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE,
    X_CHANGED_FLAG              OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    X_RETURN_STATUS             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    X_MSG_DATA                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  )

IS

l_api_name                      CONSTANT VARCHAR2 ( 30 ) := 'Default_Entity';

l_quote_header_rec              ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE;
l_header_misc_rec               HEADER_MISC_REC_TYPE;
l_opp_qte_header_rec            ASO_OPP_QTE_PUB.OPP_QTE_IN_REC_TYPE;
l_header_shipment_rec           ASO_QUOTE_PUB.SHIPMENT_REC_TYPE;
l_header_payment_rec            ASO_QUOTE_PUB.PAYMENT_REC_TYPE;
l_header_tax_detail_rec         ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE;
l_quote_line_rec                ASO_QUOTE_PUB.QTE_LINE_REC_TYPE;
l_line_misc_rec                 LINE_MISC_REC_TYPE;
l_line_shipment_rec             ASO_QUOTE_PUB.SHIPMENT_REC_TYPE;
l_line_payment_rec              ASO_QUOTE_PUB.PAYMENT_REC_TYPE;
l_line_tax_detail_rec           ASO_QUOTE_PUB.TAX_DETAIL_REC_TYPE;

l_Qte_Header_Row_Rec           ASO_AK_Quote_Header_V%Rowtype;
lx_Qte_Header_Row_Rec           ASO_AK_Quote_Header_V%Rowtype;
l_Qte_Opportunity_Row_Rec      ASO_AK_Quote_Oppty_V%Rowtype;
lx_Qte_Opportunity_Row_Rec      ASO_AK_Quote_Oppty_V%Rowtype;
l_Qte_Line_Row_Rec             ASO_AK_Quote_Line_V%Rowtype;
lx_Qte_Line_Row_Rec             ASO_AK_Quote_Line_V%Rowtype;

l_triggers_id_tbl               ASO_DEFAULTING_INT.ATTRIBUTE_IDS_TBL_TYPE;

l_entity_code                   VARCHAR2(15);
l_dependency_flag               VARCHAR2(1);

l_msg_count_start               NUMBER;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_org_id			NUMBER;   -- Variable to store ORG_ID Yogeshwar (MOAC)
l_valid_org_id			NUMBER; --New variable to store ORG_ID value Yogeshwar (MOAC)


BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT DEFAULT_ENTITY_INT;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

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

      l_Quote_Header_Rec := p_Quote_Header_Rec;
      l_Header_Misc_Rec := p_Header_Misc_Rec;
      l_Opp_Qte_Header_Rec := p_Opp_Qte_Header_Rec;
      l_Header_Shipment_Rec := p_Header_Shipment_Rec;
      l_Header_Payment_Rec := p_Header_Payment_Rec;
      l_Header_Tax_Detail_Rec := p_Header_Tax_Detail_Rec;
      l_Quote_Line_Rec := p_Quote_Line_Rec;
      l_Line_Misc_Rec := p_Line_Misc_Rec;
      l_Line_Shipment_Rec := p_Line_Shipment_Rec;
      l_Line_Payment_Rec := p_Line_Payment_Rec;
      l_Line_Tax_Detail_Rec := p_Line_Tax_Detail_Rec;

      l_dependency_flag := p_control_rec.dependency_flag;

      ASO_DEPENDENCY_UTIL.Attribute_Code_To_Id
          (
            P_ATTRIBUTE_CODES_TBL      =>     p_trigger_attributes_tbl
          , P_DATABASE_OBJECT_NAME     =>     p_database_object_name
          , X_ATTRIBUTE_IDS_TBL        =>     l_triggers_id_tbl
           );


      IF p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
          l_entity_code := 'QUOTE_OPPTY';

          IF p_control_rec.defaulting_flow_code like 'CREATE%' THEN
              l_dependency_flag := FND_API.G_FALSE;

              IF l_Quote_Header_Rec.Created_By = FND_API.G_MISS_NUM OR l_Quote_Header_Rec.Created_By IS NULL THEN
                  l_Quote_Header_Rec.Created_By := FND_GLOBAL.User_Id;
              END IF;

	      --Commented Code Start Yogeshwar (MOAC)
	      /* IF l_Quote_Header_Rec.Org_Id  = FND_API.G_MISS_NUM OR l_Quote_Header_Rec.Org_Id IS NULL THEN
                  IF SUBSTRB(USERENV('CLIENT_INFO'),1,1) <> ' ' THEN
                      l_Quote_Header_Rec.Org_Id := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10));
                  END IF;
              END IF;
              */
	      --Commented Code End Yogeshwar (MOAC)

	--New Code Start Yogeshwar (MOAC)
	-- Commented as per bug 4548593
	/*
	If l_Quote_Header_Rec.Org_Id  IS NULL THEN
		l_org_id := FND_API.G_MISS_NUM;
	Else
		l_org_id := l_Quote_Header_Rec.Org_Id;
	End if;
	 l_valid_org_id:= MO_GLOBAL.get_valid_org(l_org_id);
	IF l_valid_org_id is NULL then
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
        else
	       l_Quote_Header_Rec.Org_Id := l_valid_org_id;

	End if;
	*/
       --New Code  End  Yogeshwar (MOAC)

          END IF;

      ELSIF p_database_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN
          l_entity_code := 'QUOTE_HEADER';

          IF p_control_rec.defaulting_flow_code like 'CREATE%' THEN
              l_dependency_flag := FND_API.G_FALSE;
              IF l_Quote_Header_Rec.Created_By = FND_API.G_MISS_NUM OR l_Quote_Header_Rec.Created_By IS NULL THEN
                  l_Quote_Header_Rec.Created_By := FND_GLOBAL.User_Id;
              END IF;

	     --Commented Code  Start (MOAC)
	     /*
	      IF l_Quote_Header_Rec.Org_Id  = FND_API.G_MISS_NUM OR l_Quote_Header_Rec.Org_Id IS NULL THEN
                  IF SUBSTRB(USERENV('CLIENT_INFO'),1,1) <> ' ' THEN
                      l_Quote_Header_Rec.Org_Id := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10));
                  END IF;
              END IF;
	     */
	    --Commented Code End Yogeshwar (MOAC)

	    --New Code Start Yogeshwar (MOAC)
	    -- Commented as per bug 4548593
		/*
		If l_Quote_Header_Rec.Org_Id  IS NULL THEN
			l_org_id := FND_API.G_MISS_NUM;
		Else
			l_org_id := l_Quote_Header_Rec.Org_Id;
		End if;
		l_valid_org_id:= MO_GLOBAL.get_valid_org(l_org_id);
		if l_valid_org_id is NULL then
			x_return_status := FND_API.G_RET_STS_ERROR;
			RAISE FND_API.G_EXC_ERROR;
                Else
		     l_Quote_Header_Rec.Org_Id := l_valid_org_id;
		End if;
		*/
	    --New Code End Yogeshwar (MOAC)

	  END IF;

      ELSIF p_database_object_name = 'ASO_AK_QUOTE_LINE_V' THEN
          l_entity_code := 'QUOTE_LINE';

          IF p_control_rec.defaulting_flow_code like 'CREATE%' THEN
              l_dependency_flag := FND_API.G_FALSE;
              IF l_Quote_Line_Rec.Created_By = FND_API.G_MISS_NUM OR l_Quote_Line_Rec.Created_By IS NULL THEN
                  l_Quote_Line_Rec.Created_By := FND_GLOBAL.User_Id;
              END IF;

	      --Commented Code Start Yogeshwar (MOAC)
	      /*
	      IF l_Quote_Line_Rec.Org_Id  = FND_API.G_MISS_NUM OR l_Quote_Line_Rec.Org_Id IS NULL THEN
                  IF SUBSTRB(USERENV('CLIENT_INFO'),1,1) <> ' ' THEN
                      l_Quote_Line_Rec.Org_Id := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10));
                  END IF;
              END IF;
              */
             --Commented Code End Yogeshwar (MOAC)

	     --New Code start yogeshwar (MOAC)
		-- Commented as per bug 4548593
		/*
		If l_Quote_Line_Rec.Org_Id  IS NULL THEN
			l_org_id := FND_API.G_MISS_NUM;
		Else
			l_org_id := l_Quote_Line_Rec.Org_Id;
		End if;
		l_valid_org_id:= MO_GLOBAL.get_valid_org(l_org_id);
		if l_valid_org_id is NULL then
			x_return_status := FND_API.G_RET_STS_ERROR;
			RAISE FND_API.G_EXC_ERROR;
		else
			l_Quote_Header_Rec.Org_Id := l_valid_org_id;
		End if;
		*/
	     --New Code End  Yogeshwar (MOAC)

	  END IF;

      ELSE
          FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
          FND_MESSAGE.Set_Token('ID', p_database_object_name, FALSE);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_control_rec.defaulting_flow_code like 'CREATE%' THEN
          l_dependency_flag := FND_API.G_FALSE;

      END IF;


      ASO_DEFAULTING_UTIL.Initialize_Row_Type
         (
           P_Entity_Code                      =>     l_entity_code,
           P_Qte_Header_Row_Rec              =>     l_Qte_Header_Row_Rec,
           P_Qte_Opportunity_Row_Rec         =>     l_Qte_Opportunity_Row_Rec,
           P_Qte_Line_Row_Rec                =>     l_Qte_Line_Row_Rec);


      ASO_DEFAULTING_UTIL.Api_Rec_To_Row_Type
          (
           P_Entity_Code                 =>        l_entity_code,
           P_Quote_Header_Rec            =>        l_Quote_Header_Rec,
           P_Header_Shipment_Rec         =>        l_Header_Shipment_Rec,
           P_Header_Payment_Rec          =>        l_Header_Payment_Rec,
           P_Quote_Line_Rec              =>        l_Quote_Line_Rec,
           P_Line_Shipment_Rec           =>        l_Line_Shipment_Rec,
           P_Line_Payment_Rec            =>        l_Line_Payment_Rec,
           P_Control_Rec                 =>        p_Control_Rec,
           P_Opp_Qte_Header_Rec          =>        l_Opp_Qte_Header_Rec,
           P_Header_Misc_Rec             =>        l_Header_Misc_Rec,
           P_Header_Tax_Detail_Rec       =>        l_Header_Tax_Detail_Rec,
           P_Line_Misc_Rec               =>        l_Line_Misc_Rec,
           P_Line_Tax_Detail_Rec         =>        l_Line_Tax_Detail_Rec,
           X_Qte_Header_Row_Rec         =>        l_Qte_Header_Row_Rec,
           X_Qte_Opportunity_Row_Rec    =>        l_Qte_Opportunity_Row_Rec,
           X_Qte_Line_Row_Rec           =>        l_Qte_Line_Row_Rec);

       IF l_dependency_flag = FND_API.G_TRUE THEN

           IF l_entity_code = 'QUOTE_HEADER' THEN

               ASO_QUOTE_HEADER_DEP_HDLR.Get_Dependent_Attributes_Proc
                   (
                    p_init_msg_list       =>    p_init_msg_list,
                    p_trigger_record      =>    l_Qte_Header_Row_Rec,
                    p_triggers_id_tbl     =>    l_triggers_id_tbl,
                    p_control_record      =>    p_control_rec,
                    x_dependent_record    =>    lx_Qte_Header_Row_Rec,
                    x_return_status       =>    x_return_status,
                    x_msg_count           =>    x_msg_count,
                    x_msg_data            =>    x_msg_data );

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
               l_Qte_Header_Row_Rec := lx_Qte_Header_Row_Rec;   --Nocopy changes
               X_Changed_Flag := FND_API.G_TRUE;

           END IF;

           IF l_entity_code = 'QUOTE_LINE' THEN

               ASO_QUOTE_LINE_DEP_HDLR.Get_Dependent_Attributes_Proc
                   (
                    p_init_msg_list       =>    p_init_msg_list,
                    p_trigger_record      =>    l_Qte_Line_Row_Rec,
                    p_triggers_id_tbl     =>    l_triggers_id_tbl,
                    p_control_record      =>    p_control_rec,
                    x_dependent_record    =>    lx_Qte_Line_Row_Rec,
                    x_return_status       =>    x_return_status,
                    x_msg_count           =>    x_msg_count,
                    x_msg_data            =>    x_msg_data );

              IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
               l_Qte_Line_Row_Rec  := lx_Qte_Line_Row_Rec;  --Nocopy changes
               X_Changed_Flag := FND_API.G_TRUE;

           END IF;

       END IF;  -- Dependency Flag

       OE_MSG_PUB.Count_And_Get
          ( p_count         	=>      l_msg_count_start,
        	  p_data          	=>      l_msg_data
    		);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Before Defaulting HDLR:l_msg_count_start: '  || l_msg_count_start,1,'N');
END IF;

/* Start : Code change done for Bug 12940278 */

IF l_Qte_Header_Row_Rec.Q_CURRENCY_CODE Is Null Then
   l_Qte_Header_Row_Rec.Q_CURRENCY_CODE := FND_API.G_MISS_CHAR;
End If;

IF l_Qte_Header_Row_Rec.Q_PAYMENT_TERM_ID Is Null Then
   l_Qte_Header_Row_Rec.Q_PAYMENT_TERM_ID := FND_API.G_MISS_NUM;
End If;

/* End : Code change done for Bug 12940278 */

       IF p_control_rec.defaulting_flag = FND_API.G_TRUE THEN

           IF l_entity_code = 'QUOTE_HEADER' THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('#############  BEFORE QUOTE_HEADER DEFAULT HDLR START #############' ,1,'N');
aso_debug_pub.add('QUOTE_HEADER.APPLICATION_TYPE_CODE: '  || l_Qte_Header_Row_Rec.Q_APPLICATION_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE1: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE1,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE10: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE10,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE11: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE11,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE12: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE12,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE13: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE13,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE14: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE14,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE15: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE15,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE16: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE16,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE17: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE17,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE18: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE18,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE19: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE19,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE2: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE2,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE20: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE20,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE3: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE3,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE4: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE4,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE5: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE5,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE6: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE6,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE7: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE7,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE8: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE8,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE9: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE9,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE_CATEGORY: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE_CATEGORY,1,'N');
aso_debug_pub.add('QUOTE_HEADER.AUTOMATIC_PRICE_FLAG: '  || l_Qte_Header_Row_Rec.Q_AUTOMATIC_PRICE_FLAG,1,'N');
aso_debug_pub.add('QUOTE_HEADER.AUTOMATIC_TAX_FLAG: '  || l_Qte_Header_Row_Rec.Q_AUTOMATIC_TAX_FLAG,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CONTRACT_ID: '  || l_Qte_Header_Row_Rec.Q_CONTRACT_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CONTRACT_TEMPLATE_ID: '  || l_Qte_Header_Row_Rec.Q_CONTRACT_TEMPLATE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CREATED_BY: '  || l_Qte_Header_Row_Rec.Q_CREATED_BY,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CREDIT_CARD_CODE: '  || l_Qte_Header_Row_Rec.Q_CREDIT_CARD_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CREDIT_CARD_EXPIRATION_DATE: '  || l_Qte_Header_Row_Rec.Q_CREDIT_CARD_EXP_DATE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CREDIT_CARD_HOLDER_NAME: '  || l_Qte_Header_Row_Rec.Q_CREDIT_CARD_HLD_NAME,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CURRENCY_CODE: '  || l_Qte_Header_Row_Rec.Q_CURRENCY_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CUST_ACCOUNT_ID: '  || l_Qte_Header_Row_Rec.Q_CUST_ACCOUNT_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CUST_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_CUST_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CUST_PO_NUMBER: '  || l_Qte_Header_Row_Rec.Q_CUST_PO_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_HEADER.DEMAND_CLASS_CODE: '  || l_Qte_Header_Row_Rec.Q_DEMAND_CLASS_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.END_CUSTOMER_CUST_ACCOUNT_ID: '  || l_Qte_Header_Row_Rec.Q_END_CUST_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.END_CUSTOMER_CUST_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_END_CUST_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.END_CUSTOMER_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_END_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.END_CUSTOMER_PARTY_SITE_ID: '  || l_Qte_Header_Row_Rec.Q_END_CUST_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.FOB_CODE: '  || l_Qte_Header_Row_Rec.Q_FOB_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.FREIGHT_TERMS_CODE: '  || l_Qte_Header_Row_Rec.Q_FREIGHT_TERMS_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.INVOICE_TO_CUST_ACCOUNT_ID: '  || l_Qte_Header_Row_Rec.Q_INV_TO_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.INVOICE_TO_CUST_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_INV_TO_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.INVOICE_TO_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_INV_TO_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.INVOICE_TO_PARTY_SITE_ID: '  || l_Qte_Header_Row_Rec.Q_INV_TO_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.LAST_UPDATE_DATE: '  || l_Qte_Header_Row_Rec.Q_LAST_UPDATE_DATE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.MARKETING_SOURCE_CODE_ID: '  || l_Qte_Header_Row_Rec.Q_MKTING_SRC_CODE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.OBJECT_VERSION_NUMBER: '  || l_Qte_Header_Row_Rec.Q_OBJECT_VERSION_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ORDER_TYPE_ID: '  || l_Qte_Header_Row_Rec.Q_ORDER_TYPE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ORG_ID: '  || l_Qte_Header_Row_Rec.Q_ORG_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PACKING_INSTRUCTIONS: '  || l_Qte_Header_Row_Rec.Q_PACKING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PAYMENT_REF_NUMBER: '  || l_Qte_Header_Row_Rec.Q_PAYMENT_REF_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PAYMENT_TERM_ID: '  || l_Qte_Header_Row_Rec.Q_PAYMENT_TERM_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PAYMENT_TYPE_CODE: '  || l_Qte_Header_Row_Rec.Q_PAYMENT_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PHONE_ID: '  || l_Qte_Header_Row_Rec.Q_PHONE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PRICE_FROZEN_DATE: '  || l_Qte_Header_Row_Rec.Q_PRICE_FROZEN_DATE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PRICE_LIST_ID: '  || l_Qte_Header_Row_Rec.Q_PRICE_LIST_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.QUOTE_EXPIRATION_DATE: '  || l_Qte_Header_Row_Rec.Q_QUOTE_EXPIRATION_DATE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.QUOTE_HEADER_ID: '  || l_Qte_Header_Row_Rec.Q_QUOTE_HEADER_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.QUOTE_NAME: '  || l_Qte_Header_Row_Rec.Q_QUOTE_NAME,1,'N');
aso_debug_pub.add('QUOTE_HEADER.QUOTE_STATUS_ID: '  || l_Qte_Header_Row_Rec.Q_QUOTE_STATUS_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.QUOTE_TO_CUSTOMER_TYPE: '  || l_Qte_Header_Row_Rec.Q_QUOTE_CUSTOMER_TYPE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.REQUEST_DATE: '  || l_Qte_Header_Row_Rec.Q_REQUEST_DATE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.REQUEST_DATE_TYPE: '  || l_Qte_Header_Row_Rec.Q_REQUEST_DATE_TYPE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.RESOURCE_GRP_ID: '  || l_Qte_Header_Row_Rec.Q_RESOURCE_GRP_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.RESOURCE_ID: '  || l_Qte_Header_Row_Rec.Q_RESOURCE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SALES_CHANNEL_CODE: '  || l_Qte_Header_Row_Rec.Q_SALES_CHANNEL_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIPMENT_PRIORITY_CODE: '  || l_Qte_Header_Row_Rec.Q_SHIPMENT_PRIORITY_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIPPING_INSTRUCTIONS: '  || l_Qte_Header_Row_Rec.Q_SHIPPING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIP_METHOD_CODE: '  || l_Qte_Header_Row_Rec.Q_SHIP_METHOD_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIP_TO_CUST_ACCOUNT_ID: '  || l_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIP_TO_CUST_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIP_TO_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIP_TO_PARTY_SITE_ID: '  || l_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SOLD_TO_PARTY_SITE_ID: '  || l_Qte_Header_Row_Rec.Q_SOLD_TO_PARTY_SITE_ID,1,'N');
aso_debug_pub.add('#############  BEFORE QUOTE_HEADER DEFAULT HDLR END #############' ,1,'N');
END IF;

               ASO_QUOTE_HEADER_DEF_HDLR.Default_Record
                   (
                    p_x_rec              =>      l_Qte_Header_Row_Rec,
                    p_in_old_rec         =>      l_Qte_Header_Row_Rec);

-- bug 21842898
-- Since Q_QUOTE_NAME is not used in defaulting for ASO_QUOTE_HEADERS_ALL, G_MISS_CHAR is returned in HTML UI
-- Due to which special character is shown in HTML UI
-- As per OM bug 21880080, calling application needs to handled this since Q_QUOTE_NAME is not defaultable

IF l_Qte_Header_Row_Rec.Q_QUOTE_NAME = FND_API.G_MISS_CHAR THEN
  -- Attribute is NOT defaulting enabled, return NULL if MISSING
  l_Qte_Header_Row_Rec.Q_QUOTE_NAME := NULL;
END IF;

-- end bug 21842898

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('#############  AFTER QUOTE_HEADER DEFAULT HDLR START #############' ,1,'N');
aso_debug_pub.add('QUOTE_HEADER.APPLICATION_TYPE_CODE: '  || l_Qte_Header_Row_Rec.Q_APPLICATION_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE1: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE1,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE10: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE10,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE11: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE11,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE12: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE12,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE13: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE13,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE14: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE14,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE15: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE15,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE16: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE16,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE17: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE17,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE18: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE18,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE19: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE19,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE2: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE2,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE20: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE20,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE3: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE3,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE4: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE4,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE5: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE5,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE6: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE6,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE7: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE7,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE8: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE8,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE9: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE9,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ATTRIBUTE_CATEGORY: '  || l_Qte_Header_Row_Rec.Q_ATTRIBUTE_CATEGORY,1,'N');
aso_debug_pub.add('QUOTE_HEADER.AUTOMATIC_PRICE_FLAG: '  || l_Qte_Header_Row_Rec.Q_AUTOMATIC_PRICE_FLAG,1,'N');
aso_debug_pub.add('QUOTE_HEADER.AUTOMATIC_TAX_FLAG: '  || l_Qte_Header_Row_Rec.Q_AUTOMATIC_TAX_FLAG,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CONTRACT_ID: '  || l_Qte_Header_Row_Rec.Q_CONTRACT_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CONTRACT_TEMPLATE_ID: '  || l_Qte_Header_Row_Rec.Q_CONTRACT_TEMPLATE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CREATED_BY: '  || l_Qte_Header_Row_Rec.Q_CREATED_BY,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CREDIT_CARD_CODE: '  || l_Qte_Header_Row_Rec.Q_CREDIT_CARD_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CREDIT_CARD_EXPIRATION_DATE: '  || l_Qte_Header_Row_Rec.Q_CREDIT_CARD_EXP_DATE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CREDIT_CARD_HOLDER_NAME: '  || l_Qte_Header_Row_Rec.Q_CREDIT_CARD_HLD_NAME,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CURRENCY_CODE: '  || l_Qte_Header_Row_Rec.Q_CURRENCY_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CUST_ACCOUNT_ID: '  || l_Qte_Header_Row_Rec.Q_CUST_ACCOUNT_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CUST_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_CUST_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.CUST_PO_NUMBER: '  || l_Qte_Header_Row_Rec.Q_CUST_PO_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_HEADER.DEMAND_CLASS_CODE: '  || l_Qte_Header_Row_Rec.Q_DEMAND_CLASS_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.END_CUSTOMER_CUST_ACCOUNT_ID: '  || l_Qte_Header_Row_Rec.Q_END_CUST_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.END_CUSTOMER_CUST_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_END_CUST_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.END_CUSTOMER_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_END_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.END_CUSTOMER_PARTY_SITE_ID: '  || l_Qte_Header_Row_Rec.Q_END_CUST_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.FOB_CODE: '  || l_Qte_Header_Row_Rec.Q_FOB_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.FREIGHT_TERMS_CODE: '  || l_Qte_Header_Row_Rec.Q_FREIGHT_TERMS_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.INVOICE_TO_CUST_ACCOUNT_ID: '  || l_Qte_Header_Row_Rec.Q_INV_TO_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.INVOICE_TO_CUST_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_INV_TO_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.INVOICE_TO_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_INV_TO_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.INVOICE_TO_PARTY_SITE_ID: '  || l_Qte_Header_Row_Rec.Q_INV_TO_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.LAST_UPDATE_DATE: '  || l_Qte_Header_Row_Rec.Q_LAST_UPDATE_DATE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.MARKETING_SOURCE_CODE_ID: '  || l_Qte_Header_Row_Rec.Q_MKTING_SRC_CODE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.OBJECT_VERSION_NUMBER: '  || l_Qte_Header_Row_Rec.Q_OBJECT_VERSION_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ORDER_TYPE_ID: '  || l_Qte_Header_Row_Rec.Q_ORDER_TYPE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.ORG_ID: '  || l_Qte_Header_Row_Rec.Q_ORG_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PACKING_INSTRUCTIONS: '  || l_Qte_Header_Row_Rec.Q_PACKING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PAYMENT_REF_NUMBER: '  || l_Qte_Header_Row_Rec.Q_PAYMENT_REF_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PAYMENT_TERM_ID: '  || l_Qte_Header_Row_Rec.Q_PAYMENT_TERM_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PAYMENT_TYPE_CODE: '  || l_Qte_Header_Row_Rec.Q_PAYMENT_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PHONE_ID: '  || l_Qte_Header_Row_Rec.Q_PHONE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PRICE_FROZEN_DATE: '  || l_Qte_Header_Row_Rec.Q_PRICE_FROZEN_DATE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.PRICE_LIST_ID: '  || l_Qte_Header_Row_Rec.Q_PRICE_LIST_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.QUOTE_EXPIRATION_DATE: '  || l_Qte_Header_Row_Rec.Q_QUOTE_EXPIRATION_DATE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.QUOTE_HEADER_ID: '  || l_Qte_Header_Row_Rec.Q_QUOTE_HEADER_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.QUOTE_NAME: '  || l_Qte_Header_Row_Rec.Q_QUOTE_NAME,1,'N');
aso_debug_pub.add('QUOTE_HEADER.QUOTE_STATUS_ID: '  || l_Qte_Header_Row_Rec.Q_QUOTE_STATUS_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.QUOTE_TO_CUSTOMER_TYPE: '  || l_Qte_Header_Row_Rec.Q_QUOTE_CUSTOMER_TYPE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.REQUEST_DATE: '  || l_Qte_Header_Row_Rec.Q_REQUEST_DATE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.REQUEST_DATE_TYPE: '  || l_Qte_Header_Row_Rec.Q_REQUEST_DATE_TYPE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.RESOURCE_GRP_ID: '  || l_Qte_Header_Row_Rec.Q_RESOURCE_GRP_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.RESOURCE_ID: '  || l_Qte_Header_Row_Rec.Q_RESOURCE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SALES_CHANNEL_CODE: '  || l_Qte_Header_Row_Rec.Q_SALES_CHANNEL_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIPMENT_PRIORITY_CODE: '  || l_Qte_Header_Row_Rec.Q_SHIPMENT_PRIORITY_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIPPING_INSTRUCTIONS: '  || l_Qte_Header_Row_Rec.Q_SHIPPING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIP_METHOD_CODE: '  || l_Qte_Header_Row_Rec.Q_SHIP_METHOD_CODE,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIP_TO_CUST_ACCOUNT_ID: '  || l_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIP_TO_CUST_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_SHIP_TO_CUST_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIP_TO_PARTY_ID: '  || l_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SHIP_TO_PARTY_SITE_ID: '  || l_Qte_Header_Row_Rec.Q_SHIP_TO_PARTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_HEADER.SOLD_TO_PARTY_SITE_ID: '  || l_Qte_Header_Row_Rec.Q_SOLD_TO_PARTY_SITE_ID,1,'N');
aso_debug_pub.add('#############  AFTER QUOTE_HEADER DEFAULT HDLR END #############' ,1,'N');
END IF;

           END IF;

           IF l_entity_code = 'QUOTE_LINE' THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('#############  BEFORE QUOTE_LINE DEFAULT HDLR START #############' ,1,'N');
aso_debug_pub.add('QUOTE_LINE.AGREEMENT_ID: '  || l_Qte_Line_Row_Rec.L_AGREEMENT_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.APPLICATION_TYPE_CODE: '  || l_Qte_Line_Row_Rec.L_APPLICATION_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE1: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE1,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE10: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE10,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE11: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE11,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE12: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE12,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE13: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE13,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE14: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE14,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE15: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE15,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE16: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE16,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE17: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE17,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE18: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE18,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE19: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE19,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE2: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE2,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE20: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE20,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE3: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE3,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE4: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE4,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE5: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE5,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE6: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE6,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE7: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE7,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE8: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE8,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE9: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE9,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE_CATEGORY: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE_CATEGORY,1,'N');
aso_debug_pub.add('QUOTE_LINE.CHARGE_PERIODICITY_CODE: '  || l_Qte_Line_Row_Rec.L_PERIODICITY_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.CREATED_BY: '  || l_Qte_Line_Row_Rec.L_CREATED_BY,1,'N');
aso_debug_pub.add('QUOTE_LINE.CREDIT_CARD_CODE: '  || l_Qte_Line_Row_Rec.L_CREDIT_CARD_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.CREDIT_CARD_EXPIRATION_DATE: '  || l_Qte_Line_Row_Rec.L_CREDIT_CARD_EXP_DATE,1,'N');
aso_debug_pub.add('QUOTE_LINE.CREDIT_CARD_HOLDER_NAME: '  || l_Qte_Line_Row_Rec.L_CREDIT_CARD_HLD_NAME,1,'N');
aso_debug_pub.add('QUOTE_LINE.CUST_PO_LINE_NUMBER: '  || l_Qte_Line_Row_Rec.L_CUST_PO_LINE_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_LINE.CUST_PO_NUMBER: '  || l_Qte_Line_Row_Rec.L_CUST_PO_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_LINE.DEMAND_CLASS_CODE: '  || l_Qte_Line_Row_Rec.L_DEMAND_CLASS_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.END_CUSTOMER_CUST_ACCOUNT_ID: '  || l_Qte_Line_Row_Rec.L_END_CUST_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.END_CUSTOMER_CUST_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_END_CUST_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.END_CUSTOMER_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_END_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.END_CUSTOMER_PARTY_SITE_ID: '  || l_Qte_Line_Row_Rec.L_END_CUST_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.FOB_CODE: '  || l_Qte_Line_Row_Rec.L_FOB_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.FREIGHT_TERMS_CODE: '  || l_Qte_Line_Row_Rec.L_FREIGHT_TERMS_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.INVOICE_TO_CUST_ACCOUNT_ID: '  || l_Qte_Line_Row_Rec.L_INV_TO_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.INVOICE_TO_CUST_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_INV_TO_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.INVOICE_TO_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_INV_TO_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.INVOICE_TO_PARTY_SITE_ID: '  || l_Qte_Line_Row_Rec.L_INV_TO_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.ORDER_LINE_TYPE_ID: '  || l_Qte_Line_Row_Rec.L_ORDER_LINE_TYPE_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.LAST_UPDATE_DATE: '  || l_Qte_Line_Row_Rec.L_LAST_UPDATE_DATE,1,'N');
aso_debug_pub.add('QUOTE_LINE.LINE_CATEGORY_CODE: '  || l_Qte_Line_Row_Rec.L_LINE_CATEGORY_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.OBJECT_VERSION_NUMBER: '  || l_Qte_Line_Row_Rec.L_OBJECT_VERSION_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_FROM_ORG_ID: '  || l_Qte_Line_Row_Rec.L_SHIP_FROM_ORG_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.ORG_ID: '  || l_Qte_Line_Row_Rec.L_ORG_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.PACKING_INSTRUCTIONS: '  || l_Qte_Line_Row_Rec.L_PACKING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_LINE.PAYMENT_REF_NUMBER: '  || l_Qte_Line_Row_Rec.L_PAYMENT_REF_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_LINE.PAYMENT_TERM_ID: '  || l_Qte_Line_Row_Rec.L_PAYMENT_TERM_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.PAYMENT_TYPE_CODE: '  || l_Qte_Line_Row_Rec.L_PAYMENT_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.PRICE_LIST_ID: '  || l_Qte_Line_Row_Rec.L_PRICE_LIST_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.QUOTE_HEADER_ID: '  || l_Qte_Line_Row_Rec.L_QUOTE_HEADER_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.QUOTE_LINE_ID: '  || l_Qte_Line_Row_Rec.L_QUOTE_LINE_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.QUOTE_TO_CUSTOMER_TYPE: '  || l_Qte_Line_Row_Rec.L_QUOTE_CUSTOMER_TYPE,1,'N');
aso_debug_pub.add('QUOTE_LINE.REQUEST_DATE: '  || l_Qte_Line_Row_Rec.L_REQUEST_DATE,1,'N');
aso_debug_pub.add('QUOTE_LINE.SEGMENT1: '  || l_Qte_Line_Row_Rec.L_PRODUCT,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIPMENT_PRIORITY_CODE: '  || l_Qte_Line_Row_Rec.L_SHIPMENT_PRIORITY_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIPPING_INSTRUCTIONS: '  || l_Qte_Line_Row_Rec.L_SHIPPING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_METHOD_CODE: '  || l_Qte_Line_Row_Rec.L_SHIP_METHOD_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_TO_CUST_ACCOUNT_ID: '  || l_Qte_Line_Row_Rec.L_SHIP_TO_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_TO_CUST_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_SHIP_TO_CUST_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_TO_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_TO_PARTY_SITE_ID: '  || l_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_SITE_ID,1,'N');
aso_debug_pub.add('#############  BEFORE QUOTE_LINE DEFAULT HDLR END #############' ,1,'N');
END IF;

-- Start : code change done for Bug 20364638
If l_Qte_Line_Row_Rec.L_APPLICATION_TYPE_CODE = 'QUOTING FORM' Then
   ASO_QUOTE_HEADER_Def_Util.Clear_QUOTE_HEADER_Cache;
End If;
-- End : code change done for Bug 20364638

               ASO_QUOTE_LINE_DEF_HDLR.Default_Record
                   (
                    p_x_rec              =>      l_Qte_Line_Row_Rec,
                    p_in_old_rec         =>      l_Qte_Line_Row_Rec);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('#############  AFTER QUOTE_LINE DEFAULT HDLR START #############' ,1,'N');
aso_debug_pub.add('QUOTE_LINE.AGREEMENT_ID: '  || l_Qte_Line_Row_Rec.L_AGREEMENT_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.APPLICATION_TYPE_CODE: '  || l_Qte_Line_Row_Rec.L_APPLICATION_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE1: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE1,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE10: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE10,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE11: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE11,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE12: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE12,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE13: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE13,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE14: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE14,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE15: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE15,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE16: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE16,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE17: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE17,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE18: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE18,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE19: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE19,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE2: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE2,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE20: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE20,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE3: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE3,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE4: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE4,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE5: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE5,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE6: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE6,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE7: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE7,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE8: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE8,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE9: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE9,1,'N');
aso_debug_pub.add('QUOTE_LINE.ATTRIBUTE_CATEGORY: '  || l_Qte_Line_Row_Rec.L_ATTRIBUTE_CATEGORY,1,'N');
aso_debug_pub.add('QUOTE_LINE.CHARGE_PERIODICITY_CODE: '  || l_Qte_Line_Row_Rec.L_PERIODICITY_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.CREATED_BY: '  || l_Qte_Line_Row_Rec.L_CREATED_BY,1,'N');
aso_debug_pub.add('QUOTE_LINE.CREDIT_CARD_CODE: '  || l_Qte_Line_Row_Rec.L_CREDIT_CARD_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.CREDIT_CARD_EXPIRATION_DATE: '  || l_Qte_Line_Row_Rec.L_CREDIT_CARD_EXP_DATE,1,'N');
aso_debug_pub.add('QUOTE_LINE.CREDIT_CARD_HOLDER_NAME: '  || l_Qte_Line_Row_Rec.L_CREDIT_CARD_HLD_NAME,1,'N');
aso_debug_pub.add('QUOTE_LINE.CUST_PO_LINE_NUMBER: '  || l_Qte_Line_Row_Rec.L_CUST_PO_LINE_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_LINE.CUST_PO_NUMBER: '  || l_Qte_Line_Row_Rec.L_CUST_PO_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_LINE.DEMAND_CLASS_CODE: '  || l_Qte_Line_Row_Rec.L_DEMAND_CLASS_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.END_CUSTOMER_CUST_ACCOUNT_ID: '  || l_Qte_Line_Row_Rec.L_END_CUST_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.END_CUSTOMER_CUST_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_END_CUST_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.END_CUSTOMER_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_END_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.END_CUSTOMER_PARTY_SITE_ID: '  || l_Qte_Line_Row_Rec.L_END_CUST_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.FOB_CODE: '  || l_Qte_Line_Row_Rec.L_FOB_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.FREIGHT_TERMS_CODE: '  || l_Qte_Line_Row_Rec.L_FREIGHT_TERMS_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.INVOICE_TO_CUST_ACCOUNT_ID: '  || l_Qte_Line_Row_Rec.L_INV_TO_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.INVOICE_TO_CUST_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_INV_TO_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.INVOICE_TO_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_INV_TO_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.INVOICE_TO_PARTY_SITE_ID: '  || l_Qte_Line_Row_Rec.L_INV_TO_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.ORDER_LINE_TYPE_ID: '  || l_Qte_Line_Row_Rec.L_ORDER_LINE_TYPE_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.LAST_UPDATE_DATE: '  || l_Qte_Line_Row_Rec.L_LAST_UPDATE_DATE,1,'N');
aso_debug_pub.add('QUOTE_LINE.LINE_CATEGORY_CODE: '  || l_Qte_Line_Row_Rec.L_LINE_CATEGORY_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.OBJECT_VERSION_NUMBER: '  || l_Qte_Line_Row_Rec.L_OBJECT_VERSION_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_FROM_ORG_ID: '  || l_Qte_Line_Row_Rec.L_SHIP_FROM_ORG_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.ORG_ID: '  || l_Qte_Line_Row_Rec.L_ORG_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.PACKING_INSTRUCTIONS: '  || l_Qte_Line_Row_Rec.L_PACKING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_LINE.PAYMENT_REF_NUMBER: '  || l_Qte_Line_Row_Rec.L_PAYMENT_REF_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_LINE.PAYMENT_TERM_ID: '  || l_Qte_Line_Row_Rec.L_PAYMENT_TERM_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.PAYMENT_TYPE_CODE: '  || l_Qte_Line_Row_Rec.L_PAYMENT_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.PRICE_LIST_ID: '  || l_Qte_Line_Row_Rec.L_PRICE_LIST_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.QUOTE_HEADER_ID: '  || l_Qte_Line_Row_Rec.L_QUOTE_HEADER_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.QUOTE_LINE_ID: '  || l_Qte_Line_Row_Rec.L_QUOTE_LINE_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.QUOTE_TO_CUSTOMER_TYPE: '  || l_Qte_Line_Row_Rec.L_QUOTE_CUSTOMER_TYPE,1,'N');
aso_debug_pub.add('QUOTE_LINE.REQUEST_DATE: '  || l_Qte_Line_Row_Rec.L_REQUEST_DATE,1,'N');
aso_debug_pub.add('QUOTE_LINE.SEGMENT1: '  || l_Qte_Line_Row_Rec.L_PRODUCT,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIPMENT_PRIORITY_CODE: '  || l_Qte_Line_Row_Rec.L_SHIPMENT_PRIORITY_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIPPING_INSTRUCTIONS: '  || l_Qte_Line_Row_Rec.L_SHIPPING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_METHOD_CODE: '  || l_Qte_Line_Row_Rec.L_SHIP_METHOD_CODE,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_TO_CUST_ACCOUNT_ID: '  || l_Qte_Line_Row_Rec.L_SHIP_TO_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_TO_CUST_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_SHIP_TO_CUST_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_TO_PARTY_ID: '  || l_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_LINE.SHIP_TO_PARTY_SITE_ID: '  || l_Qte_Line_Row_Rec.L_SHIP_TO_PARTY_SITE_ID,1,'N');
aso_debug_pub.add('#############  AFTER QUOTE_LINE DEFAULT HDLR END #############' ,1,'N');
END IF;

           END IF;

           IF l_entity_code = 'QUOTE_OPPTY' THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('#############  BEFORE QUOTE_OPPTY DEFAULT HDLR START #############' ,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.APPLICATION_TYPE_CODE: '  || l_Qte_Opportunity_Row_Rec.O_APPLICATION_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE1: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE1,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE10: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE10,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE11: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE11,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE12: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE12,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE13: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE13,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE14: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE14,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE15: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE15,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE16: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE16,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE17: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE17,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE18: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE18,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE19: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE19,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE2: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE2,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE20: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE20,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE3: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE3,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE4: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE4,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE5: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE5,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE6: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE6,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE7: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE7,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE8: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE8,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE9: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE9,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE_CATEGORY: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE_CATEGORY,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.AUTOMATIC_PRICE_FLAG: '  || l_Qte_Opportunity_Row_Rec.O_AUTOMATIC_PRICE_FLAG,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.AUTOMATIC_TAX_FLAG: '  || l_Qte_Opportunity_Row_Rec.O_AUTOMATIC_TAX_FLAG,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CONTRACT_ID: '  || l_Qte_Opportunity_Row_Rec.O_CONTRACT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CONTRACT_TEMPLATE_ID: '  || l_Qte_Opportunity_Row_Rec.O_CONTRACT_TEMPLATE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CREATED_BY: '  || l_Qte_Opportunity_Row_Rec.O_CREATED_BY,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CREDIT_CARD_CODE: '  || l_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CREDIT_CARD_EXPIRATION_DATE: '  || l_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_EXP_DATE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CREDIT_CARD_HOLDER_NAME: '  || l_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_HLD_NAME,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CURRENCY_CODE: '  || l_Qte_Opportunity_Row_Rec.O_CURRENCY_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CUST_ACCOUNT_ID: '  || l_Qte_Opportunity_Row_Rec.O_CUST_ACCOUNT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CUST_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_CUST_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CUST_PO_NUMBER: '  || l_Qte_Opportunity_Row_Rec.O_CUST_PO_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.DEMAND_CLASS_CODE: '  || l_Qte_Opportunity_Row_Rec.O_DEMAND_CLASS_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.END_CUSTOMER_CUST_ACCOUNT_ID: '  || l_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.END_CUSTOMER_CUST_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.END_CUSTOMER_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.END_CUSTOMER_PARTY_SITE_ID: '  || l_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.FOB_CODE: '  || l_Qte_Opportunity_Row_Rec.O_FOB_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.FREIGHT_TERMS_CODE: '  || l_Qte_Opportunity_Row_Rec.O_FREIGHT_TERMS_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.INVOICE_TO_CUST_ACCOUNT_ID: '  || l_Qte_Opportunity_Row_Rec.O_INV_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.INVOICE_TO_CUST_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_INV_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.INVOICE_TO_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_INV_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.INVOICE_TO_PARTY_SITE_ID: '  || l_Qte_Opportunity_Row_Rec.O_INV_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.LAST_UPDATE_DATE: '  || l_Qte_Opportunity_Row_Rec.O_LAST_UPDATE_DATE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.MARKETING_SOURCE_CODE_ID: '  || l_Qte_Opportunity_Row_Rec.O_MKTING_SRC_CODE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OBJECT_VERSION_NUMBER: '  || l_Qte_Opportunity_Row_Rec.O_OBJECT_VERSION_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_CHANNEL_CODE: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_CHANNEL_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_CURRENCY_CODE: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_CURRENCY_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_CUST_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_CUST_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_MKTG_SRC_CODE_ID: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_MKTG_SRC_CD_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_QUOTE_NAME: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_QUOTE_NAME,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_SOLD_TO_CONTACT_ID: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_SLD_TO_CONT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_SOLD_TO_PARTY_SITE_ID: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_SLD_PTY_ST_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ORDER_TYPE_ID: '  || l_Qte_Opportunity_Row_Rec.O_ORDER_TYPE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ORG_ID: '  || l_Qte_Opportunity_Row_Rec.O_ORG_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PACKING_INSTRUCTIONS: '  || l_Qte_Opportunity_Row_Rec.O_PACKING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PAYMENT_REF_NUMBER: '  || l_Qte_Opportunity_Row_Rec.O_PAYMENT_REF_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PAYMENT_TERM_ID: '  || l_Qte_Opportunity_Row_Rec.O_PAYMENT_TERM_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PAYMENT_TYPE_CODE: '  || l_Qte_Opportunity_Row_Rec.O_PAYMENT_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PHONE_ID: '  || l_Qte_Opportunity_Row_Rec.O_PHONE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PRICE_FROZEN_DATE: '  || l_Qte_Opportunity_Row_Rec.O_PRICE_FROZEN_DATE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PRICE_LIST_ID: '  || l_Qte_Opportunity_Row_Rec.O_PRICE_LIST_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.QUOTE_EXPIRATION_DATE: '  || l_Qte_Opportunity_Row_Rec.O_QUOTE_EXP_DATE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.QUOTE_HEADER_ID: '  || l_Qte_Opportunity_Row_Rec.O_QUOTE_HEADER_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.QUOTE_NAME: '  || l_Qte_Opportunity_Row_Rec.O_QUOTE_NAME,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.QUOTE_STATUS_ID: '  || l_Qte_Opportunity_Row_Rec.O_QUOTE_STATUS_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.QUOTE_TO_CUSTOMER_TYPE: '  || l_Qte_Opportunity_Row_Rec.O_QUOTE_TO_CUST_TYPE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.REQUEST_DATE: '  || l_Qte_Opportunity_Row_Rec.O_REQUEST_DATE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.REQUEST_DATE_TYPE: '  || l_Qte_Opportunity_Row_Rec.O_REQUEST_DATE_TYPE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.RESOURCE_GRP_ID: '  || l_Qte_Opportunity_Row_Rec.O_RESOURCE_GRP_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.RESOURCE_ID: '  || l_Qte_Opportunity_Row_Rec.O_RESOURCE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SALES_CHANNEL_CODE: '  || l_Qte_Opportunity_Row_Rec.O_SALES_CHANNEL_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIPMENT_PRIORITY_CODE: '  || l_Qte_Opportunity_Row_Rec.O_SHIPMENT_PRIORITY_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIPPING_INSTRUCTIONS: '  || l_Qte_Opportunity_Row_Rec.O_SHIPPING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIP_METHOD_CODE: '  || l_Qte_Opportunity_Row_Rec.O_SHIP_METHOD_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIP_TO_CUST_ACCOUNT_ID: '  || l_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIP_TO_CUST_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIP_TO_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIP_TO_PARTY_SITE_ID: '  || l_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SOLD_TO_PARTY_SITE_ID: '  || l_Qte_Opportunity_Row_Rec.O_SOLD_TO_PARTY_SITE_ID,1,'N');
aso_debug_pub.add('#############  BEFORE QUOTE_OPPTY DEFAULT HDLR END #############' ,1,'N');
END IF;

               ASO_QUOTE_OPPTY_DEF_HDLR.Default_Record
                   (
                    p_x_rec              =>      l_Qte_Opportunity_Row_Rec,
                    p_in_old_rec         =>      l_Qte_Opportunity_Row_Rec);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('#############  AFTER QUOTE_OPPTY DEFAULT HDLR START #############' ,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.APPLICATION_TYPE_CODE: '  || l_Qte_Opportunity_Row_Rec.O_APPLICATION_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE1: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE1,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE10: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE10,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE11: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE11,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE12: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE12,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE13: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE13,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE14: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE14,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE15: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE15,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE16: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE16,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE17: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE17,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE18: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE18,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE19: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE19,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE2: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE2,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE20: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE20,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE3: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE3,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE4: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE4,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE5: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE5,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE6: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE6,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE7: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE7,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE8: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE8,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE9: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE9,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ATTRIBUTE_CATEGORY: '  || l_Qte_Opportunity_Row_Rec.O_ATTRIBUTE_CATEGORY,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.AUTOMATIC_PRICE_FLAG: '  || l_Qte_Opportunity_Row_Rec.O_AUTOMATIC_PRICE_FLAG,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.AUTOMATIC_TAX_FLAG: '  || l_Qte_Opportunity_Row_Rec.O_AUTOMATIC_TAX_FLAG,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CONTRACT_ID: '  || l_Qte_Opportunity_Row_Rec.O_CONTRACT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CONTRACT_TEMPLATE_ID: '  || l_Qte_Opportunity_Row_Rec.O_CONTRACT_TEMPLATE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CREATED_BY: '  || l_Qte_Opportunity_Row_Rec.O_CREATED_BY,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CREDIT_CARD_CODE: '  || l_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CREDIT_CARD_EXPIRATION_DATE: '  || l_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_EXP_DATE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CREDIT_CARD_HOLDER_NAME: '  || l_Qte_Opportunity_Row_Rec.O_CREDIT_CARD_HLD_NAME,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CURRENCY_CODE: '  || l_Qte_Opportunity_Row_Rec.O_CURRENCY_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CUST_ACCOUNT_ID: '  || l_Qte_Opportunity_Row_Rec.O_CUST_ACCOUNT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CUST_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_CUST_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.CUST_PO_NUMBER: '  || l_Qte_Opportunity_Row_Rec.O_CUST_PO_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.DEMAND_CLASS_CODE: '  || l_Qte_Opportunity_Row_Rec.O_DEMAND_CLASS_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.END_CUSTOMER_CUST_ACCOUNT_ID: '  || l_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.END_CUSTOMER_CUST_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_END_CUST_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.END_CUSTOMER_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.END_CUSTOMER_PARTY_SITE_ID: '  || l_Qte_Opportunity_Row_Rec.O_END_CUST_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.FOB_CODE: '  || l_Qte_Opportunity_Row_Rec.O_FOB_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.FREIGHT_TERMS_CODE: '  || l_Qte_Opportunity_Row_Rec.O_FREIGHT_TERMS_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.INVOICE_TO_CUST_ACCOUNT_ID: '  || l_Qte_Opportunity_Row_Rec.O_INV_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.INVOICE_TO_CUST_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_INV_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.INVOICE_TO_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_INV_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.INVOICE_TO_PARTY_SITE_ID: '  || l_Qte_Opportunity_Row_Rec.O_INV_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.LAST_UPDATE_DATE: '  || l_Qte_Opportunity_Row_Rec.O_LAST_UPDATE_DATE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.MARKETING_SOURCE_CODE_ID: '  || l_Qte_Opportunity_Row_Rec.O_MKTING_SRC_CODE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OBJECT_VERSION_NUMBER: '  || l_Qte_Opportunity_Row_Rec.O_OBJECT_VERSION_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_CHANNEL_CODE: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_CHANNEL_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_CURRENCY_CODE: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_CURRENCY_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_CUST_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_CUST_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_MKTG_SRC_CODE_ID: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_MKTG_SRC_CD_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_QUOTE_NAME: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_QUOTE_NAME,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_SOLD_TO_CONTACT_ID: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_SLD_TO_CONT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.OPPTY_SOLD_TO_PARTY_SITE_ID: '  || l_Qte_Opportunity_Row_Rec.O_OPPTY_SLD_PTY_ST_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ORDER_TYPE_ID: '  || l_Qte_Opportunity_Row_Rec.O_ORDER_TYPE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.ORG_ID: '  || l_Qte_Opportunity_Row_Rec.O_ORG_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PACKING_INSTRUCTIONS: '  || l_Qte_Opportunity_Row_Rec.O_PACKING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_PARTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PAYMENT_REF_NUMBER: '  || l_Qte_Opportunity_Row_Rec.O_PAYMENT_REF_NUMBER,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PAYMENT_TERM_ID: '  || l_Qte_Opportunity_Row_Rec.O_PAYMENT_TERM_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PAYMENT_TYPE_CODE: '  || l_Qte_Opportunity_Row_Rec.O_PAYMENT_TYPE_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PHONE_ID: '  || l_Qte_Opportunity_Row_Rec.O_PHONE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PRICE_FROZEN_DATE: '  || l_Qte_Opportunity_Row_Rec.O_PRICE_FROZEN_DATE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.PRICE_LIST_ID: '  || l_Qte_Opportunity_Row_Rec.O_PRICE_LIST_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.QUOTE_EXPIRATION_DATE: '  || l_Qte_Opportunity_Row_Rec.O_QUOTE_EXP_DATE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.QUOTE_HEADER_ID: '  || l_Qte_Opportunity_Row_Rec.O_QUOTE_HEADER_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.QUOTE_NAME: '  || l_Qte_Opportunity_Row_Rec.O_QUOTE_NAME,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.QUOTE_STATUS_ID: '  || l_Qte_Opportunity_Row_Rec.O_QUOTE_STATUS_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.QUOTE_TO_CUSTOMER_TYPE: '  || l_Qte_Opportunity_Row_Rec.O_QUOTE_TO_CUST_TYPE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.REQUEST_DATE: '  || l_Qte_Opportunity_Row_Rec.O_REQUEST_DATE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.REQUEST_DATE_TYPE: '  || l_Qte_Opportunity_Row_Rec.O_REQUEST_DATE_TYPE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.RESOURCE_GRP_ID: '  || l_Qte_Opportunity_Row_Rec.O_RESOURCE_GRP_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.RESOURCE_ID: '  || l_Qte_Opportunity_Row_Rec.O_RESOURCE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SALES_CHANNEL_CODE: '  || l_Qte_Opportunity_Row_Rec.O_SALES_CHANNEL_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIPMENT_PRIORITY_CODE: '  || l_Qte_Opportunity_Row_Rec.O_SHIPMENT_PRIORITY_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIPPING_INSTRUCTIONS: '  || l_Qte_Opportunity_Row_Rec.O_SHIPPING_INSTRUCTIONS,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIP_METHOD_CODE: '  || l_Qte_Opportunity_Row_Rec.O_SHIP_METHOD_CODE,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIP_TO_CUST_ACCOUNT_ID: '  || l_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_ACCT_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIP_TO_CUST_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_SHIP_TO_CUST_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIP_TO_PARTY_ID: '  || l_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SHIP_TO_PARTY_SITE_ID: '  || l_Qte_Opportunity_Row_Rec.O_SHIP_TO_PTY_SITE_ID,1,'N');
aso_debug_pub.add('QUOTE_OPPTY.SOLD_TO_PARTY_SITE_ID: '  || l_Qte_Opportunity_Row_Rec.O_SOLD_TO_PARTY_SITE_ID,1,'N');
aso_debug_pub.add('#############  AFTER QUOTE_OPPTY DEFAULT HDLR END #############' ,1,'N');
END IF;

           END IF;

       END IF; -- Defaulting Flag

       OE_MSG_PUB.Count_And_Get
          ( p_count         	=>      l_msg_count,
        	  p_data          	=>      l_msg_data
    		);

       x_msg_count := 0;

       IF l_msg_count > l_msg_count_start THEN

          x_msg_count := l_msg_count;
          x_msg_data := l_msg_data;

          FND_MESSAGE.Set_Name('ASO', 'ASO_INVALID_DEFAULTING_RULE');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;

       END IF;

       ASO_DEFAULTING_UTIL.Row_To_Api_Rec_Type
           (
            p_entity_code                =>      l_entity_code,
            P_Qte_Header_Row_Rec        =>      l_Qte_Header_Row_Rec,
            P_Qte_Opportunity_Row_Rec   =>      l_Qte_Opportunity_Row_Rec,
            P_Qte_Line_Row_Rec          =>      l_Qte_Line_Row_Rec,
            X_Quote_Header_Rec           =>      l_Quote_Header_Rec,
            X_Header_Shipment_Rec        =>      l_Header_Shipment_Rec,
            X_Header_Payment_Rec         =>      l_Header_Payment_Rec,
            X_Quote_Line_Rec             =>      l_Quote_Line_Rec,
            X_Line_Shipment_Rec          =>      l_Line_Shipment_Rec,
            X_Line_Payment_Rec           =>      l_Line_Payment_Rec,
            X_Header_Misc_Rec            =>      l_Header_Misc_Rec,
            X_Header_Tax_Detail_Rec      =>      l_Header_Tax_Detail_Rec,
            X_Line_Misc_Rec              =>      l_Line_Misc_Rec,
            X_Line_Tax_Detail_Rec        =>      l_Line_Tax_Detail_Rec);


            X_Quote_Header_Rec := l_Quote_Header_Rec;
            X_Header_Shipment_Rec := l_Header_Shipment_Rec;
            X_Header_Payment_Rec := l_Header_Payment_Rec;
            X_Quote_Line_Rec := l_Quote_Line_Rec;
            X_Line_Shipment_Rec := l_Line_Shipment_Rec;
            X_Line_Payment_Rec := l_Line_Payment_Rec;
            X_Header_Misc_Rec := l_Header_Misc_Rec;
            X_Header_Tax_Detail_Rec := l_Header_Tax_Detail_Rec;
            X_Line_Misc_Rec := l_Line_Misc_Rec;
            X_Line_Tax_Detail_Rec := l_Line_Tax_Detail_Rec;

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END DEFAULT_ENTITY;


END ASO_DEFAULTING_INT;

/
