--------------------------------------------------------
--  DDL for Package Body ASO_CREDIT_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CREDIT_CHECK_PVT" as
/* $Header: asoiqccb.pls 120.1 2005/06/29 12:35:19 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_CREDIT_CHECK_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_CREDIT_CHECK_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoiqccb.pls';

PROCEDURE Credit_Check(
  P_API_VERSION		          IN	NUMBER,
  P_INIT_MSG_LIST	          IN	VARCHAR2  := FND_API.G_FALSE,
  P_COMMIT		          IN 	VARCHAR2  := FND_API.G_FALSE,
  P_QTE_HEADER_REC                IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
  X_RESULT_OUT                    OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  X_CC_HOLD_COMMENT               OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  X_RETURN_STATUS	          OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
  X_MSG_COUNT		          OUT NOCOPY /* file.sql.39 change */  	NUMBER,
  X_MSG_DATA		          OUT NOCOPY /* file.sql.39 change */  	VARCHAR2
)
IS

  CURSOR c_functional_currency(p_set_of_books_id NUMBER) IS
  SELECT currency_code
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = p_set_of_books_id;

  CURSOR c_credit_check_flag(p_credit_check_rule_id NUMBER) IS
  SELECT incl_freight_charges_flag,include_tax_flag
  FROM OE_CREDIT_CHECK_RULES
  WHERE credit_check_rule_id = p_credit_check_rule_id;

  l_api_version  		NUMBER := 1.0;
  l_api_name 			VARCHAR2(50) := 'Credit_Check';
  l_return_status               VARCHAR2(1);
  l_msg_data                    VARCHAR2(2000);
  l_msg_count                   NUMBER := 0;
  l_set_of_books_id   		NUMBER;
  l_functional_currency 	VARCHAR2(15);
  l_credit_check_rule_id        NUMBER;
  l_site_use_id                 NUMBER;
  l_qte_header_rec              ASO_QUOTE_PUB.Qte_Header_Rec_Type;
  l_include_tax_flag            OE_CREDIT_CHECK_RULES.INCLUDE_TAX_FLAG%TYPE;
  l_incl_freight_charges_flag   OE_CREDIT_CHECK_RULES.INCL_FREIGHT_CHARGES_FLAG%TYPE;
  l_transactional_amount        ASO_QUOTE_HEADERS_ALL.TOTAL_QUOTE_PRICE%TYPE;
  x_status			VARCHAR2(1);


BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT CREDIT_CHECK_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                         	           p_api_version,
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



      -- Initializing Global Debug Variable.
      aso_debug_pub.g_debug_flag := NVL(FND_PROFILE.VALUE('ASO_ENABLE_DEBUG'),'N');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
      	 aso_debug_pub.add('Credit Check - Begin...', 1, 'Y');
      END IF;


      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'ASO_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- ******************************************************************
      -- Validate Profile
      -- ******************************************************************

      l_credit_check_rule_id :=  NVL(FND_PROFILE.VALUE('ASO_CREDIT_CHECK_RULE'),0);

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Credit Check Rule Profile Value : '||NVL(to_char(l_credit_check_rule_id),'null'), 1, 'Y');
      END IF;

      IF  NVL(l_credit_check_rule_id,0) > 0 THEN

      -- ******************************************************************
      -- Validate Required Information
      -- ******************************************************************
      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Quote Header Id : '||NVL(to_char(p_qte_header_rec.quote_header_id),'null'), 1, 'Y');
      END IF;

         IF p_qte_header_rec.quote_header_id IS NOT NULL AND
            p_qte_header_rec.quote_header_id <> FND_API.G_MISS_NUM
         THEN
      		IF aso_debug_pub.g_debug_flag = 'Y' THEN
         	   aso_debug_pub.add(' Credit Check Lock Exists or not... ', 1, 'Y');
      		END IF;

      		-- ******************************************************************
      		-- Validate For any locks on the quote.
      		-- ******************************************************************

	   		ASO_CONC_REQ_INT.Lock_Exists(
		 		p_quote_header_id     => p_qte_header_rec.quote_header_id,
		 		x_status              => x_status);
      			IF aso_debug_pub.g_debug_flag = 'Y' THEN
         	   	   aso_debug_pub.add(' Credit Check Lock Exists : x_status '||NVL(x_status,'null'), 1, 'Y');
      			END IF;

   			IF (x_status = FND_API.G_TRUE) THEN
   				IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    					FND_MESSAGE.Set_Name('ASO', 'ASO_CONC_REQUEST_RUNNING');
    					FND_MSG_PUB.ADD;
    				END IF;
         			RAISE FND_API.G_EXC_ERROR;
  			END IF;

       	     -- get quote information

                BEGIN
                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('Before ASO_UTILITY_PVT.Query_Header_Row... ', 1, 'Y');
			END IF;

                	l_qte_header_rec  := ASO_UTILITY_PVT.Query_Header_Row(p_qte_header_rec.quote_header_id);
                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('After ASO_UTILITY_PVT.Query_Header_Row... ', 1, 'Y');
			END IF;
       	        EXCEPTION
                        WHEN OTHERS THEN
                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                           aso_debug_pub.add('Exception ASO_UTILITY_PVT.Query_Header_Row... ', 1, 'Y');
                        END IF;
           		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              			FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_ID');
              			FND_MESSAGE.Set_Token('COLUMN', 'Quote_header_id', FALSE);
              			FND_MESSAGE.Set_Token('VALUE', l_qte_header_rec.quote_header_id, FALSE);
              			FND_MSG_PUB.ADD;
          		END IF;
          		raise FND_API.G_EXC_ERROR;
        	END;
         ELSE
              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('before - p_qte_header_rec is NULL... ', 1, 'Y');
              END IF;

              l_qte_header_rec := p_qte_header_rec;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                 aso_debug_pub.add('After - p_qte_header_rec is NULL... ', 1, 'Y');
              END IF;
         END IF;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Checking for all the required values... ', 1, 'Y');
      aso_debug_pub.add('Org Id :'||NVL(to_char(l_qte_header_rec.org_id),'null'), 1, 'Y');
      aso_debug_pub.add('Currency Code:'||NVL(l_qte_header_rec.currency_code,'null'), 1, 'Y');
      aso_debug_pub.add('Invoice To Party Site Id :'||NVL(to_char(l_qte_header_rec.invoice_to_party_site_id),'null'), 1, 'Y');
      aso_debug_pub.add('Invoice To Cust Account Id :'||NVL(to_char(l_qte_header_rec.invoice_to_cust_account_id),'null'), 1, 'Y');
  END IF;

         -- Check if all the required values are available.

         IF l_qte_header_rec.org_id IS NOT NULL  AND
            l_qte_header_rec.org_id <> FND_API.G_MISS_NUM AND
            l_qte_header_rec.currency_code IS NOT NULL AND
            l_qte_header_rec.currency_code <> FND_API.G_MISS_CHAR AND
            l_qte_header_rec.invoice_to_party_site_id IS NOT NULL AND
            l_qte_header_rec.invoice_to_party_site_id <> FND_API.G_MISS_NUM AND
            NVL(l_qte_header_rec.invoice_to_cust_account_id,l_qte_header_rec.cust_account_id) IS NOT NULL AND
            NVL(l_qte_header_rec.invoice_to_cust_account_id,l_qte_header_rec.cust_account_id) <> FND_API.G_MISS_NUM
         THEN
                l_set_of_books_id := OE_PROFILE.VALUE('OE_SET_OF_BOOKS_ID',l_qte_header_rec.org_id);

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
      		aso_debug_pub.add('Set Of books ID:'||NVL(to_char(l_set_of_books_id),'null'), 1, 'Y');
             END IF;

                IF l_set_of_books_id IS NOT NULL THEN

			-- get functional currency

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
      			   aso_debug_pub.add('Before Fetching Functional Currency', 1, 'Y');
			END IF;

       			OPEN C_functional_currency(l_set_of_books_id);
       			FETCH C_functional_currency INTO l_functional_currency;

                        IF aso_debug_pub.g_debug_flag = 'Y' THEN
      			   aso_debug_pub.add('After Fetching Functional Currency :'||NVL(l_functional_currency,'null'), 1, 'Y');
			END IF;


       			IF ( C_functional_currency%NOTFOUND) Then
           			IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              				FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_GL_CURRENCY');
              				FND_MSG_PUB.ADD;
          			END IF;
          			raise FND_API.G_EXC_ERROR;
        		END IF;

        		CLOSE C_functional_currency;
                ELSE
           		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              			FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_OE_PROFILE');
              			FND_MSG_PUB.ADD;
          		END IF;
          		raise FND_API.G_EXC_ERROR;
                END IF;

                -- Get Bill to Site Use Id.

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
      		   aso_debug_pub.add('Before Bill To Site Use Id Fetch', 1, 'Y');
		END IF;


       		ASO_MAP_QUOTE_ORDER_INT.GET_ACCT_SITE_USES (
 		 P_Cust_Account_Id => NVL(l_qte_header_rec.invoice_to_cust_account_id,l_qte_header_rec.cust_account_id)
 		 ,P_Party_Site_Id   =>l_qte_header_rec.invoice_to_party_site_id
	         ,P_Acct_Site_type  => 'BILL_TO'
 		 ,x_return_status   => l_return_status
 		 ,x_site_use_id     => l_site_use_id
  	   	);

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
      		   aso_debug_pub.add('After Bill To Site Use Id Fetch :'||NVL(to_char(l_site_use_id),'null'), 1, 'Y');
      		   aso_debug_pub.add('After Bill To Site Use Id Fetch l_return_status  :'||NVL(l_return_status,' '), 1, 'Y');
		END IF;

       		IF l_return_status <> FND_API.G_RET_STS_SUCCESS  OR
                   NVL(l_site_use_id ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
		THEN
           		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              			FND_MESSAGE.Set_Name('ASO', 'ASO_API_INVALID_BILLTO_INFO');
              			FND_MSG_PUB.ADD;
           		END IF;
           		raise FND_API.G_EXC_ERROR;
       		END IF;

                -- Transaction Amount Calculation.

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
      		   aso_debug_pub.add('Before Credit Check Flags Fetch', 1, 'Y');
		END IF;

       		OPEN C_credit_check_flag(l_credit_check_rule_id);
       		FETCH C_credit_check_flag INTO l_incl_freight_charges_flag,l_include_tax_flag;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
      		   aso_debug_pub.add('After Credit Check Flag Fetch... ', 1, 'Y');
      		   aso_debug_pub.add('Include Tax Flag : '||NVL(l_include_tax_flag,'null'), 1, 'Y');
      		   aso_debug_pub.add('Include Freight Charges Flag : '||NVL(l_incl_freight_charges_flag,'null'), 1, 'Y');
		END IF;

       		IF ( C_credit_check_flag%NOTFOUND) Then
           		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              			FND_MESSAGE.Set_Name('ASO', 'ASO_API_NO_TAX_FREIGHT_INFO');
              			FND_MSG_PUB.ADD;
          		END IF;
          		raise FND_API.G_EXC_ERROR;
        	END IF;

        	CLOSE C_credit_check_flag;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
      		   aso_debug_pub.add('Before Transactional Amount Calulation', 1, 'Y');
      		   aso_debug_pub.add('Total Quote Price :'||NVL(to_char(l_qte_header_rec.total_quote_price),'null'), 1, 'Y');
      		   aso_debug_pub.add('Total Tax :'||NVL(to_char(l_qte_header_rec.total_tax),'null'), 1, 'Y');
      		   aso_debug_pub.add('Total Freight Charges :'||NVL(to_char(l_qte_header_rec.total_shipping_charge),'null'), 1, 'Y');
	        END IF;

                IF NVL(l_include_tax_flag,'N') = 'N' THEN
                   l_transactional_amount := NVL(l_qte_header_rec.total_quote_price,0) - NVL(l_qte_header_rec.total_tax,0);
		ELSE
                   l_transactional_amount := NVL(l_qte_header_rec.total_quote_price,0);
                END IF;

                IF NVL(l_incl_freight_charges_flag,'N') = 'N' THEN
                   l_transactional_amount := NVL(l_transactional_amount,0) - NVL(l_qte_header_rec.total_shipping_charge,0);
	        END IF;
                IF aso_debug_pub.g_debug_flag = 'Y' THEN
      		   aso_debug_pub.add('After Transactional Amount Calulation : '||NVL(to_char(l_transactional_amount),'null'), 1, 'Y');

      		    aso_debug_pub.add('Before OM Public API call', 1, 'Y');
		END IF;

      		-- calling the om api to do internal credit check.
        	OE_EXTERNAL_CREDIT_PUB.CHECK_EXTERNAL_CREDIT
       		(
        	P_API_VERSION         => 1.0,
 		P_INIT_MSG_LIST	      => p_init_msg_list,
 		X_RETURN_STATUS       => x_return_status,
        	X_RESULT_OUT          => x_result_out,
 		X_MSG_DATA	      => x_msg_data,
 		X_MSG_COUNT	      => x_msg_count,
        	X_CC_HOLD_COMMENT     => x_cc_hold_comment,
        	p_bill_to_site_use_id => l_site_use_id,
        	p_functional_currency_code => l_functional_currency,
        	p_transaction_currency_code => l_qte_header_rec.currency_code,
        	p_transaction_amount => l_transactional_amount,
        	p_credit_check_rule_id => l_credit_check_rule_id,
        	p_org_id               => l_qte_header_rec.org_id
      		 );

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
      		   aso_debug_pub.add('After OM Public API call - return status :'||x_return_status, 1, 'Y');
      		   aso_debug_pub.add('After OM Public API call - msg count :'||nvl(to_char(x_msg_count),'0'), 1, 'Y');
      		   aso_debug_pub.add('After OM Public API call - msg data :'||nvl(x_msg_data,'null'), 1, 'Y');
     		END IF;
      		-- Check return status from the above procedure call
      		IF x_return_status = FND_API.G_RET_STS_ERROR then
                	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
				oe_msg_pub.count_and_get( p_encoded    => 'F'
   							   , p_count      => x_msg_count
     							   , p_data        => x_msg_data);
    				for k in 1 .. x_msg_count loop
   				    x_msg_data := oe_msg_pub.get( p_msg_index => k,
                     					           p_encoded => 'F');
                		    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      		                       aso_debug_pub.add('k='||k||'.OM error Message :'||nvl(x_msg_data,'null'), 1, 'Y');
				    END IF;
                   	   	    FND_MESSAGE.Set_Name('ASO', 'ASO_OM_ERROR');
                   	   	    FND_MESSAGE.Set_Token('MSG_TXT', x_msg_data, FALSE);
                   	            FND_MSG_PUB.ADD;
 				end loop;
                	END IF;
          		raise FND_API.G_EXC_ERROR;
      		ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                 	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                    	   FND_MESSAGE.Set_Name('ASO', 'ASO_API_UNEXP_ERROR');
                    	   FND_MESSAGE.Set_Token('ROW', 'ASO_CREDIT_CHECK_PVT AFTER OM CALL', TRUE);
                    	   FND_MSG_PUB.ADD;
                 	END IF;
          		raise FND_API.G_EXC_UNEXPECTED_ERROR;
      		END IF;
         ELSE
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_INFO');
              FND_MESSAGE.Set_Token('COLUMN', 'Internal Credit Check Required ', FALSE);
              FND_MSG_PUB.ADD;
           END IF;
           raise FND_API.G_EXC_ERROR;
         END IF;  -- Missing Values Check

      END IF;  -- Credit Check Rule Profile is not set

      --
      -- End of API body.
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
END Credit_Check;

-- subha madapusi - quote credit check end.

End ASO_CREDIT_CHECK_PVT;

/
