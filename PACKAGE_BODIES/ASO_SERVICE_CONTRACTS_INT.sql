--------------------------------------------------------
--  DDL for Package Body ASO_SERVICE_CONTRACTS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SERVICE_CONTRACTS_INT" as
/* $Header: asoioksb.pls 120.2.12010000.2 2009/07/20 09:35:47 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_service_contracts_INT
-- Purpose          :
-- History          :
-- 				10/18/2002 hyang - 2633507 performance fix
--				10/21/2002 hyang - fix GSSC warning about default parameter values
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_service_contracts_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoioksb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

Procedure Get_service_attributes
	   (
	P_Api_Version_Number	  IN  Number,
        P_init_msg_list	  IN  Varchar2  := FND_API.G_FALSE,
	 P_Qte_Line_Rec     IN   ASO_QUOTE_PUB.Qte_Line_Rec_Type,
        P_Qte_Line_Dtl_tbl  IN    ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type,
         X_msg_Count       OUT NOCOPY /* file.sql.39 change */    Number,
        X_msg_Data		  OUT NOCOPY /* file.sql.39 change */    Varchar2,
        X_Return_Status	  OUT NOCOPY /* file.sql.39 change */    Varchar2
         	  )
IS

/* 2633507 - hyang: using cursor variable and base table */
  CURSOR C_item1(inv1 NUMBER, lc_organization_id NUMBER) IS
                select SERVICEABLE_PRODUCT_FLAG
      		from MTL_SYSTEM_ITEMS_B
      		where inventory_item_id = inv1
      		and organization_id = lc_organization_id;
 CURSOR C_qln(c_qln_id NUMBER) IS
             SELECT b.inventory_item_id,b.organization_id,a.cust_account_id
	     FROM aso_quote_headers_all a,aso_quote_lines_all b
	     WHERE b.quote_line_id = c_qln_id and
	     a.quote_header_id=b.quote_header_id;
CURSOR C_get_cust IS
            SELECT cust_account_id
	     FROM aso_quote_headers_all
	     WHERE quote_header_id= P_Qte_Line_Rec.quote_header_id;
/*
CURSOR C_cs_item(cs_prd_id NUMBER) IS
SELECT  a.inventory_item_id
FROM
CS_CUSTOMER_PRODUCTS_All a, mtl_system_items_kfv b
WHERE  a.inventory_item_id   = b.inventory_item_id
  AND  a.customer_product_id = cs_prd_id
  AND  b.organization_id     = ( SELECT  cs_std.get_item_valdn_orgzn_id  FROM DUAL ) ;
*/

CURSOR C_cs_item(p_instance_id NUMBER, cs_org_id NUMBER) IS
SELECT  a.inventory_item_id
FROM
csi_item_instances a, mtl_system_items_b b
WHERE  a.inventory_item_id   = b.inventory_item_id
  AND  a.instance_id = p_instance_id
  AND  b.organization_id     = cs_org_id ;

CURSOR C_ord_item(ord_line_id NUMBER) IS
	     SELECT  inventory_item_id
             FROM  oe_order_lines_All
	     WHERE  line_id=ord_line_id;

/* Commented for Sun ER 8647883
CURSOR C_cust_id (Quote_hd_id NUMBER)IS
             SELECT cust_account_id
	     FROM aso_quote_headers_all
	     WHERE quote_header_id= Quote_hd_id;
*/

/*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
CURSOR C_cust_id (Quote_hd_id NUMBER)IS
                       SELECT cust_account_id,
	decode(nvl(fnd_profile.value('ASO_FILTER_SERVICE_RF_END_CUST'),'N'),'Y',nvl(END_CUSTOMER_CUST_ACCOUNT_ID,cust_account_id),cust_account_id)
  hd_end_cust_account_id
              FROM  aso_quote_headers_all
	     WHERE quote_header_id= Quote_hd_id;


CURSOR C_get_cust_line(Quote_ln_id number) IS
       SELECT END_CUSTOMER_CUST_ACCOUNT_ID cust_account_id
	     FROM aso_quote_lines_all
	     WHERE quote_line_id= Quote_ln_id;

/*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/

  l_api_version_number NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'Get_service_attributes';
  l_inventory_item_id NUMBER ;
  l_organization_id   NUMBER;
  l_cust_account_id   NUMBER;
  l_serviceable_flag  VARCHAR2(1);
  l_check_service_rec ASO_SERVICE_CONTRACTS_INT.CHECK_SERVICE_REC_TYPE;
  l_Available_YN VARCHAR2(1);
  l_cs_org_id number;
  ln_end_cust_account_id   NUMBER; -- line level end customer Sun ER 8647883
  lh_end_cust_account_id   NUMBER; -- header level end customer Sun ER 8647883

BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT GET_SERVICE_ATTRIBUTES_PVT;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
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

      -- Debug Message

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

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
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
  OPEN C_cust_id(P_Qte_Line_rec.quote_header_id);
                           FETCH C_cust_id INTO l_cust_account_id,lh_end_cust_account_id; -- ER 8647883

					  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                               aso_debug_pub.add('Get Service Attr:  cust Acct id'||l_cust_account_id);
			       aso_debug_pub.add('Get Service Attr:  header cust Acct id'||lh_end_cust_account_id);
                           END IF;

                           IF C_cust_id%NOTFOUND THEN
                           l_cust_account_id := NULL;
			   lh_end_cust_account_id := NULL;
                           END IF;
                           CLOSE C_cust_id;

 FOR i in 1..P_Qte_Line_Dtl_tbl.count LOOP
       IF P_Qte_Line_Dtl_tbl(i).SERVICE_REF_TYPE_CODE = 'QUOTE' THEN
       		OPEN C_qln( P_Qte_Line_Dtl_tbl(i).service_ref_line_id);
      		 FETCH C_qln INTO l_inventory_item_id,l_organization_id,l_cust_account_id;

IF aso_debug_pub.g_debug_flag = 'Y' THEN

    aso_debug_pub.add('Get Service Attr:ref code QUOTE inv id '||l_inventory_item_id, 1, 'Y');
    aso_debug_pub.add('Get Service Attr:ref code QUOTE orgnization id '||l_organization_id , 1, 'Y');
    aso_debug_pub.add('Get Service Attr:ref code QUOTE cust id '||l_cust_account_id, 1, 'Y');

END IF;

       		IF C_qln%NOTFOUND THEN
      			CLOSE C_qln;
			x_return_status := FND_API.G_RET_STS_ERROR;
        		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               			FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_INFO');
               			FND_MESSAGE.Set_Token('COLUMN','SERVICE_REF_LINE_ID', FALSE);
               			FND_MSG_PUB.Add;
        		END IF;
       		 	raise FND_API.G_EXC_ERROR;
       		 ELSE
		 	CLOSE C_qln;
         	 	OPEN C_item1( l_inventory_item_id,l_organization_id);
        		 FETCH C_item1 INTO l_serviceable_flag;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Get Service Attr:ref code QUOTE serviceable flag '||l_serviceable_flag, 1, 'Y');
END IF;

         		IF C_item1%NOTFOUND OR l_serviceable_flag <> 'Y' THEN
				CLOSE C_item1;
				x_return_status := FND_API.G_RET_STS_ERROR;
	                 	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               				FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SRV_INFO1');
               				--FND_MESSAGE.Set_Token('COLUMN','SERVICE_REF_LINE_ID', FALSE);
               				FND_MSG_PUB.Add;
        			END IF;
				 raise FND_API.G_EXC_ERROR;

        		END IF;
			CLOSE C_item1;

		    IF aso_debug_pub.g_debug_flag = 'Y' THEN

                  aso_debug_pub.add('Get Service Attr:product_item_id '||l_inventory_item_id, 1, 'Y');
                  aso_debug_pub.add('Get Service Attr:service_item_id '||P_Qte_Line_rec.inventory_item_id, 1, 'Y');
                  aso_debug_pub.add('Get Service Attr:customer_id '||l_cust_account_id, 1, 'Y');

		    END IF;

			l_check_service_rec.product_item_id := l_inventory_item_id;
			l_check_service_rec.service_item_id := P_Qte_Line_rec.inventory_item_id;
			l_check_service_rec.customer_id :=  l_cust_account_id;

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
                   aso_debug_pub.add('Get Service Attr:ref code QUOTE before Is Service '||l_serviceable_flag, 1, 'Y');
               END IF;

			ASO_SERVICE_CONTRACTS_INT.Is_Service_Available(
        					P_Api_Version_Number	=> P_Api_Version_Number ,
        					P_init_msg_list	=> p_init_msg_list,
						   X_msg_Count     => X_msg_count ,
        					X_msg_Data	=> X_msg_data	 ,
        					X_Return_Status	=> X_return_status  ,
						p_check_service_rec => l_check_service_rec,
						X_Available_YN	    => l_Available_YN
					  );

 IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Get Service Attr:ref code QUOTE after  Is Service '||l_Available_YN);
 END IF;

			IF l_Available_YN = 'N' THEN
				 x_return_status := FND_API.G_RET_STS_ERROR;
			  	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               				FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SRV_INFO2');
               				--FND_MESSAGE.Set_Token('COLUMN','SERVICE_REF_LINE_ID', FALSE);
               				FND_MSG_PUB.Add;
        			END IF;
				 raise FND_API.G_EXC_ERROR;
			END IF;
		END IF;
	ELSIF  P_Qte_Line_Dtl_tbl(i).SERVICE_REF_TYPE_CODE = 'CUSTOMER_PRODUCT' THEN

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('Get Service Attr:SERVICE_REF_TYPE_CODE CUSTOMER_PRODUCT');
          aso_debug_pub.add('Get Service Attr: CUSTOMER_PRODUCT inv id'||P_Qte_Line_rec.inventory_item_id);
          aso_debug_pub.add('Get Service Attr: CUSTOMER_PRODUCT organization id'||P_Qte_Line_rec.organization_id);
          aso_debug_pub.add('Get Service Attr: CUSTOMER_PRODUCT service ref line id'||P_Qte_Line_Dtl_tbl(i).SERVICE_REF_LINE_ID, 1, 'Y');

      END IF;

                            l_cs_org_id := cs_std.get_item_valdn_orgzn_id;

		                  OPEN C_cs_item( P_Qte_Line_Dtl_tbl(i).SERVICE_REF_LINE_ID, l_cs_org_id);
		                  FETCH C_cs_item INTO l_inventory_item_id;
			                 IF C_cs_item%NOTFOUND THEN
				                CLOSE C_cs_item;
				                x_return_status := FND_API.G_RET_STS_ERROR;
				                    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               				             FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SRV_INFO3');
               				--FND_MESSAGE.Set_Token('COLUMN','INSTALLBASE', FALSE);
               				             FND_MSG_PUB.Add;
        			                 END IF;
				                raise FND_API.G_EXC_ERROR;
		 	                END IF;
		                  CLOSE C_cs_item;

				  /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
				  if fnd_profile.value('ASO_FILTER_SERVICE_RF_END_CUST') ='Y' then

					OPEN C_get_cust_line (P_Qte_Line_rec.quote_line_id);
					FETCH C_get_cust_line INTO ln_end_cust_account_id;

					IF aso_debug_pub.g_debug_flag = 'Y' THEN
						aso_debug_pub.add('Get Service Attr:  line level cust Acct id'||ln_end_cust_account_id);
					END IF;
					IF C_get_cust_line%NOTFOUND THEN
					  ln_end_cust_account_id := NULL;
	                                end if;
	                                if ln_end_cust_account_id is not null then
					  l_cust_account_id := ln_end_cust_account_id;
                                        else
					  l_cust_account_id := lh_end_cust_account_id;
	                                END IF;
	                                CLOSE C_get_cust_line;

                                     END IF; -- profile check


				    IF aso_debug_pub.g_debug_flag = 'Y' THEN
					aso_debug_pub.add('Get Service Attr:  cust Acct id'||l_cust_account_id);
				    END IF;

                                  /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
		                  l_check_service_rec.product_item_id := l_inventory_item_id;
		                  l_check_service_rec.service_item_id := P_Qte_Line_rec.inventory_item_id;
		                  l_check_service_rec.customer_id :=  l_cust_account_id;
		                  ASO_SERVICE_CONTRACTS_INT.Is_Service_Available(
        					P_Api_Version_Number	=> 1.0 ,
        					P_init_msg_list	=> p_init_msg_list,
						      X_msg_Count     => X_msg_count ,
        					X_msg_Data	=> X_msg_data	 ,
        					X_Return_Status	=> X_return_status  ,
						p_check_service_rec => l_check_service_rec,
						X_Available_YN	    => l_Available_YN
					       );
			                 IF l_Available_YN = 'N' THEN
				                x_return_status := FND_API.G_RET_STS_ERROR;
			  	                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               				         FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SRV_INFO2');
               				--FND_MESSAGE.Set_Token('COLUMN','SERVICE_REF_LINE_ID', FALSE);
               				         FND_MSG_PUB.Add;
        			               END IF;
				                raise FND_API.G_EXC_ERROR;
			                 END IF;
		       -- END IF;
	ELSIF P_Qte_Line_Dtl_tbl(i).SERVICE_REF_TYPE_CODE = 'ORDER' THEN

IF aso_debug_pub.g_debug_flag = 'Y' THEN

    aso_debug_pub.add('Get Service Attr:SERVICE_REF_TYPE_CODE ORDER', 1, 'Y');
    aso_debug_pub.add('Get Service Attr: ORDER inv id'||P_Qte_Line_rec.inventory_item_id, 1, 'Y');
    aso_debug_pub.add('Get Service Attr: ORDER organization id'||P_Qte_Line_rec.organization_id, 1, 'Y');
    aso_debug_pub.add('Get Service Attr: ORDER service ref line id'||P_Qte_Line_Dtl_tbl(i).SERVICE_REF_LINE_ID, 1, 'Y');

END IF;


		 OPEN C_ord_item( P_Qte_Line_Dtl_tbl(i).SERVICE_REF_LINE_ID);
		 FETCH  C_ord_item INTO  l_inventory_item_id;
			IF C_ord_item%NOTFOUND THEN
				CLOSE C_ord_item;
				x_return_status := FND_API.G_RET_STS_ERROR;
				IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               				FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SRV_INFO3');
               				--FND_MESSAGE.Set_Token('COLUMN','ORDER_LINE_ID', FALSE);
               				FND_MSG_PUB.Add;
        			END IF;
				 raise FND_API.G_EXC_ERROR;
		 	 END IF;
		CLOSE C_ord_item;
		l_check_service_rec.product_item_id := l_inventory_item_id;
		l_check_service_rec.service_item_id := P_Qte_Line_rec.inventory_item_id;
		l_check_service_rec.customer_id :=  l_cust_account_id;
		ASO_SERVICE_CONTRACTS_INT.Is_Service_Available(
        						P_Api_Version_Number	=> 1.0 ,
        					P_init_msg_list	=> p_init_msg_list,
						X_msg_Count     => X_msg_count ,
        					X_msg_Data	=> X_msg_data	 ,
        					X_Return_Status	=> X_return_status  ,
						p_check_service_rec => l_check_service_rec,
						X_Available_YN	    => l_Available_YN
					   );
			IF l_Available_YN = 'N' THEN
				 x_return_status := FND_API.G_RET_STS_ERROR;
			  	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               				FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SRV_INFO2');
               				--FND_MESSAGE.Set_Token('COLUMN','SERVICE_REF_LINE_ID', FALSE);
               				FND_MSG_PUB.Add;
        			END IF;
				 raise FND_API.G_EXC_ERROR;
			END IF;
		--END IF;
        /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
        ELSIF  P_Qte_Line_Dtl_tbl(i).SERVICE_REF_TYPE_CODE = 'PRODUCT_CATALOG' THEN

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('SUN ER Get Service Attr: PRODUCT_CATALOG');
          aso_debug_pub.add('SUN ER Get Service Attr: PRODUCT_CATALOG SERVICE_REF_LINE_ID inv id'||P_Qte_Line_Dtl_tbl(i).SERVICE_REF_LINE_ID);
	  aso_debug_pub.add('SUN ER Get Service Attr: PRODUCT_CATALOG inv id'||P_Qte_Line_rec.inventory_item_id);
          aso_debug_pub.add('SUN ER Get Service Attr: PRODUCT_CATALOG organization id'||P_Qte_Line_rec.organization_id);
          aso_debug_pub.add('SUN ER Get Service Attr: PRODUCT_CATALOG service ref line id'||P_Qte_Line_rec.quote_LINE_ID, 1, 'Y');

        END IF;
	  -- Checking for end customer depending on profile 8647883
	  if fnd_profile.value('ASO_FILTER_SERVICE_RF_END_CUST') ='Y' then

	    OPEN C_get_cust_line (P_Qte_Line_rec.quote_line_id);
	    FETCH C_get_cust_line INTO ln_end_cust_account_id;

	    IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('Get Service Attr:  line level cust Acct id'||ln_end_cust_account_id);
	    END IF;
	    IF C_get_cust_line%NOTFOUND THEN
		  ln_end_cust_account_id := NULL;
	    end if;
	    if ln_end_cust_account_id is not null then
		l_cust_account_id := ln_end_cust_account_id;
            else
	       l_cust_account_id := lh_end_cust_account_id;
	    END IF;
	    CLOSE C_get_cust_line;

           END IF; -- profile check

           l_inventory_item_id:= P_Qte_Line_Dtl_tbl(i).SERVICE_REF_LINE_ID;
           l_check_service_rec.product_item_id := l_inventory_item_id;
	   l_check_service_rec.service_item_id := P_Qte_Line_rec.inventory_item_id;
	   l_check_service_rec.customer_id :=  l_cust_account_id;
		 ASO_SERVICE_CONTRACTS_INT.Is_Service_Available(
        					P_Api_Version_Number	=> 1.0 ,
        					P_init_msg_list	=> p_init_msg_list,
						      X_msg_Count     => X_msg_count ,
        					X_msg_Data	=> X_msg_data	 ,
        					X_Return_Status	=> X_return_status  ,
						p_check_service_rec => l_check_service_rec,
						X_Available_YN	    => l_Available_YN
					       );
		IF l_Available_YN = 'N' THEN
		              x_return_status := FND_API.G_RET_STS_ERROR;
		              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               	         FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_SRV_INFO2');
                             FND_MSG_PUB.Add;
        			    END IF;
				    raise FND_API.G_EXC_ERROR;
		END IF;
    /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
	END IF;-- If Service_ref_type_code

    END LOOP;





      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

   /*   -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
   */



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
END  Get_service_attributes;





Procedure Get_Duration
	   (
	P_Api_Version_Number	  IN  Number,
        P_init_msg_list	  IN  Varchar2 :=  FND_API.G_FALSE,
	X_msg_Count       OUT NOCOPY /* file.sql.39 change */    Number,
        X_msg_Data		  OUT NOCOPY /* file.sql.39 change */    Varchar2,
        X_Return_Status	  OUT NOCOPY /* file.sql.39 change */    Varchar2,
	P_customer_id 	  IN  Number,
	P_system_id 	  IN  Number,
	P_Service_Duration  IN	Number,
        P_service_period    IN	Varchar2,
	P_coterm_checked_yn IN	Varchar2 := FND_API.G_FALSE,
	P_start_date 	  IN  Date,
	P_end_date 		  IN  Date,
	X_service_duration  OUT NOCOPY /* file.sql.39 change */    Number,
	X_service_period 	  OUT NOCOPY /* file.sql.39 change */    Varchar2,
        X_new_end_date 	  OUT NOCOPY /* file.sql.39 change */    Date
				 	  )
IS
  l_api_version_number NUMBER := 1.0;
  l_api_name VARCHAR2(50)     := 'Get_Duration';


BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT GET_DURATION_PUB;

	 aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
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

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

	   aso_utility_pvt.print_login_info();
        aso_debug_pub.add('ASO_service_contracts_INT.Get_Duration: Before call OKS_OMINT_PUB.Get Duration.',1,'Y');
        aso_debug_pub.add('Get Duration: p_customer_id: '||p_customer_id, 1, 'Y');
        aso_debug_pub.add('Get Duration: p_system_id: '||p_system_id, 1, 'Y');
        aso_debug_pub.add('Get Duration: p_service_duration: '||p_service_duration, 1, 'Y');
        aso_debug_pub.add('Get Duration: p_service_period: '||p_service_period, 1, 'Y');
        aso_debug_pub.add('Get Duration: p_coterm_checked_yn: '||p_coterm_checked_yn, 1, 'Y');
        aso_debug_pub.add('Get Duration: p_start_date: '||p_start_date, 1, 'Y');
        aso_debug_pub.add('Get Duration: p_end_date: '||p_end_date, 1, 'Y');

    END IF;


       OKS_OMINT_PUB.Get_Duration(
	P_Api_Version 	=> 1.0 ,
     P_init_msg_list	 => P_init_msg_list,
	X_msg_Count     => X_msg_count ,
     X_msg_Data	=> X_msg_data	 ,
     X_Return_Status	=> X_return_status  ,
	P_customer_id 	=> p_customer_id  ,
	P_system_id 	=> p_system_id  ,
	P_Service_Duration => p_service_duration ,
     P_service_period   => p_service_period ,
	P_coterm_checked_yn => p_coterm_checked_yn,
	P_start_date 	 => p_start_date ,
	P_end_date 	 => p_end_date  ,
	X_service_duration => x_service_duration ,
	X_service_period   => x_service_period  ,
     X_new_end_date 	  => x_new_end_date) ;


    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('Get Duration: After Call to OKS_OMINT_PUB.Get_Duration: X_return_status: '||X_return_status, 1, 'Y');
        aso_debug_pub.add('Get Duration: x_service_duration: '||x_service_duration, 1, 'Y');
        aso_debug_pub.add('Get Duration: x_service_period: '||x_service_period, 1, 'Y');
        aso_debug_pub.add('Get Duration: x_new_end_date: '||x_new_end_date, 1, 'Y');
        aso_utility_pvt.print_login_info();

    END IF;


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

   /*   -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
   */



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
END Get_Duration;




Procedure Is_Service_Available
   	 (
	P_Api_Version_Number	  IN  Number,
	P_init_msg_list	  IN  Varchar2 := FND_API.G_FALSE,
	X_msg_Count	  	  OUT NOCOPY /* file.sql.39 change */    Number,
	X_msg_Data	  	  OUT NOCOPY /* file.sql.39 change */    Varchar2,
	X_Return_Status	  OUT NOCOPY /* file.sql.39 change */    Varchar2,
	p_check_service_rec IN	   CHECK_SERVICE_REC_TYPE,
	X_Available_YN	  OUT NOCOPY /* file.sql.39 change */    Varchar2
				   	  )
IS
  l_api_version_number NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'Is_Service_Available';

  l_check_service_rec OKS_OMINT_PUB.CHECK_SERVICE_REC_TYPE;
BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT IS_SERVICE_AVAILABLE_PUB;

      aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
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

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN

     aso_debug_pub.add('ASO_SER_INT:IS_service_available: p_check_service_rec.product_item_id '|| p_check_service_rec.product_item_id, 1, 'N');
 aso_debug_pub.add('ASO_SER_INT:IS_service_available: p_check_service_rec.customer_id '|| p_check_service_rec.customer_id, 1, 'N');
aso_debug_pub.add('ASO_SER_INT:IS_service_available: p_check_service_rec.request_date '|| p_check_service_rec.request_date, 1, 'N');
aso_debug_pub.add('ASO_SER_INT:IS_service_available: p_check_service_rec.service_item_id '|| p_check_service_rec.service_item_id, 1, 'N');
aso_debug_pub.add('ASO_SER_INT:IS_service_available: p_check_service_rec.product_revision '|| p_check_service_rec.product_revision, 1, 'N');

     END IF;


-- map quote rec to oks record type
	IF p_check_service_rec.product_item_id = FND_API.G_MISS_NUM THEN
	  l_check_service_rec.product_item_id := NULL;
     ELSE
     l_check_service_rec.product_item_id := p_check_service_rec.product_item_id;
	END IF;
      IF p_check_service_rec.customer_id = FND_API.G_MISS_NUM THEN
       l_check_service_rec.customer_id := NULL;
     ELSE
     l_check_service_rec.customer_id := p_check_service_rec.customer_id;
     END IF;
     IF p_check_service_rec.service_item_id = FND_API.G_MISS_NUM THEN
       l_check_service_rec.service_item_id := NULL;
     ELSE
     l_check_service_rec.service_item_id := p_check_service_rec.service_item_id;
     END IF;
     IF p_check_service_rec.product_revision = FND_API.G_MISS_CHAR THEN
       l_check_service_rec.product_revision := NULL;
     ELSE
         l_check_service_rec.product_revision := p_check_service_rec.product_revision;
     END IF;
     IF p_check_service_rec.request_date = FND_API.G_MISS_DATE THEN
       l_check_service_rec.request_date := NULL;
     ELSE
         l_check_service_rec.request_date := p_check_service_rec.request_date;
     END IF;

/*
      l_check_service_rec.product_item_id := p_check_service_rec.product_item_id;
      l_check_service_rec.service_item_id := p_check_service_rec.service_item_id;
      l_check_service_rec.customer_id := p_check_service_rec.customer_id;
      l_check_service_rec.product_revision:=p_check_service_rec.product_revision;
      l_check_service_rec.request_date := p_check_service_rec.request_date;
*/

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Before Calling OKS_OMINT_PUB.Is_Service_Available ',1,'Y');
         aso_utility_pvt.print_login_info();
      END IF;

       OKS_OMINT_PUB.Is_Service_Available(
        P_Api_Version	=> 1.0 ,
        P_init_msg_list	=> p_init_msg_list,
	X_msg_Count     => X_msg_count ,
        X_msg_Data	=> X_msg_data	 ,
        X_Return_Status	=> X_return_status  ,
	p_check_service_rec => l_check_service_rec,
	X_Available_YN	    => X_Available_YN	  );

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('After Calling OKS_OMINT_PUB.Is_Service_Available ',1,'Y');
         aso_utility_pvt.print_login_info();
      END IF;


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

   /*   -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
    */


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

END Is_Service_Available;


PROCEDURE Available_Services(
	P_Api_Version_number	  IN   Number,
	P_init_msg_list	  IN   Varchar2 := FND_API.G_FALSE,
	X_msg_Count		  OUT NOCOPY /* file.sql.39 change */    Number,
	X_msg_Data		  OUT NOCOPY /* file.sql.39 change */    Varchar2,
	X_Return_Status	  OUT NOCOPY /* file.sql.39 change */    Varchar2,
	p_avail_service_rec IN	 AVAIL_SERVICE_REC_TYPE,
	X_Orderable_Service_tbl	  OUT NOCOPY /* file.sql.39 change */    order_service_tbl_type
					    )
IS
  l_api_version_number NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'Available_Services';

  l_avail_service_rec OKS_OMINT_PUB.AVAIL_SERVICE_REC_TYPE;
  l_Orderable_Service_tbl  OKS_OMINT_PUB.order_service_tbl_type;


BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT AVAILABLE_SERVICES_PUB;

	 aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
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

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

-- map service rec type
IF aso_debug_pub.g_debug_flag = 'Y' THEN

   aso_debug_pub.add('ASO_SER_INT:available_service: p_avail_service_rec.PRODUCT_ITEM_ID '|| p_avail_service_rec.PRODUCT_ITEM_ID, 1, 'N');
   aso_debug_pub.add('ASO_SER_INT:available_service: p_avail_service_rec.CUSTOMER_ID '|| p_avail_service_rec.CUSTOMER_ID, 1, 'N');
   aso_debug_pub.add('ASO_SER_INT:available_service: p_avail_service_rec.PRODUCT_REVISION '|| p_avail_service_rec.PRODUCT_REVISION, 1, 'N');
   aso_debug_pub.add('ASO_SER_INT:available_service: p_avail_service_rec.REQUEST_DATE '|| p_avail_service_rec.REQUEST_DATE, 1, 'N');

END IF;

      IF p_avail_service_rec.PRODUCT_ITEM_ID = FND_API.G_MISS_NUM THEN
        l_avail_service_rec.PRODUCT_ITEM_ID := NULL;
      ELSE
       l_avail_service_rec.PRODUCT_ITEM_ID  := p_avail_service_rec.PRODUCT_ITEM_ID;
	 END IF;
      IF p_avail_service_rec.CUSTOMER_ID = FND_API.G_MISS_NUM THEN
        l_avail_service_rec.CUSTOMER_ID := NULL;
      ELSE
       l_avail_service_rec.CUSTOMER_ID  := p_avail_service_rec.CUSTOMER_ID;
      END IF;
      IF p_avail_service_rec.PRODUCT_REVISION = FND_API.G_MISS_CHAR THEN
        l_avail_service_rec.PRODUCT_REVISION := NULL;
      ELSE
       l_avail_service_rec.PRODUCT_REVISION  := p_avail_service_rec.PRODUCT_REVISION;
      END IF;
      IF p_avail_service_rec.request_date = FND_API.G_MISS_DATE THEN
        l_avail_service_rec.request_date := NULL;
      ELSE
       l_avail_service_rec.request_date  := p_avail_service_rec.request_date;
      END IF;
/*
l_avail_service_rec.PRODUCT_ITEM_ID  := p_avail_service_rec.PRODUCT_ITEM_ID;
l_avail_service_rec.CUSTOMER_ID	     := p_avail_service_rec.CUSTOMER_ID	 ;
l_avail_service_rec.PRODUCT_REVISION := p_avail_service_rec.PRODUCT_REVISION;
l_avail_service_rec.REQUEST_DATE     := p_avail_service_rec.REQUEST_DATE;
*/

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('Before Calling OKS_OMINT_PUB.Available_Services ',1,'Y');
         aso_utility_pvt.print_login_info();
      END IF;

        OKS_OMINT_PUB.Available_Services(
	P_Api_Version	=> 1.0 ,
        P_init_msg_list	=> p_init_msg_list,
	X_msg_Count     => X_msg_count ,
        X_msg_Data	=> X_msg_data	 ,
        X_Return_Status	=> X_return_status  ,
	p_avail_service_rec => l_avail_service_rec,
	X_Orderable_Service_tbl	 => l_Orderable_Service_tbl
					   );

IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('ASO_SER_INT:After Call to OKS available_service: x_return_status '|| X_return_status, 1, 'Y');
    aso_utility_pvt.print_login_info();
END IF;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      FOR i in 1..l_Orderable_Service_tbl.count  LOOP
       x_orderable_service_tbl(i).service_item_id := l_Orderable_Service_tbl(i).service_item_id;
      END LOOP;
    END IF;


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

  /*    -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;
 */



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

END Available_Services;


Procedure Get_Warranty	   (
       P_Api_Version_Number	       IN	Number,
       P_init_msg_list	       IN	Varchar2 := FND_API.G_FALSE,
       X_msg_Count	       OUT NOCOPY /* file.sql.39 change */    Number,
       X_msg_Data		 OUT NOCOPY /* file.sql.39 change */  	  Varchar2,
       P_Org_id               IN       Number,
       P_Organization_id       IN       NUMBER := null,
       P_product_item_id 	 IN	  Number,
       x_return_status	       OUT NOCOPY /* file.sql.39 change */    Varchar2,
       X_Warranty_tbl	     OUT NOCOPY /* file.sql.39 change */      War_tbl_type  )
IS

  CURSOR C_warranty(item_id NUMBER) IS
  SELECT description, concatenated_segments
 -- SELECT description, segment1
 -- FROM aso_i_items_v
  FROM mtl_system_items_vl
  WHERE inventory_item_id = item_id
  AND organization_id = p_organization_id;
/*  AND bom_item_type in (1,4)
  AND inventory_item_status_code = 'Active'
  AND customer_order_enabled_flag = 'Y'; */

  l_api_version_number NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'Get_Warranty';

  l_warranty_tbl OKS_EXTWAR_UTIL_PUB.War_tbl;
  l_description VARCHAR2(240);
  l_concatenated_segments VARCHAR2(2000);

BEGIN
   -- Standard Start of API savepoint
      SAVEPOINT GET_WARRANTY_PUB;

 aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
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

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Before  Call to OKS_EXTWAR_UTIL_PUB.Get_Warranty_info', 1, 'Y');
        aso_utility_pvt.print_login_info();
      END IF;

      OKS_EXTWAR_UTIL_PUB.Get_Warranty_info(
       P_Api_Version	=> 1.0 ,
       P_init_msg_list	=> FND_API.G_FALSE,
       P_Org_id         => P_Org_id  ,
       P_prod_item_id   => P_product_item_id	 ,
       X_Return_Status	=> X_return_status  ,
       X_msg_Count      => X_msg_count ,
       X_msg_Data	=> X_msg_data	 ,
       X_Warranty_tbl	=> l_Warranty_tbl      );
-- map the output

      IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('After  Call to OKS_EXTWAR_UTIL_PUB.Get_Warranty_info', 1, 'Y');
        aso_utility_pvt.print_login_info();
      END IF;


   For i in 1..l_warranty_tbl.count LOOP
    IF p_organization_id is not null THEN
       OPEN C_warranty(l_Warranty_tbl(i).Service_item_id);
       FETCH C_warranty INTO l_description,
                             l_concatenated_segments;
       IF (C_warranty%FOUND) THEN
          CLOSE C_warranty;
          X_Warranty_tbl(i).Service_item_id := l_Warranty_tbl(i).Service_item_id;
          X_Warranty_tbl(i).Duration_Quantity:= l_Warranty_tbl(i).Duration_Quantity;
          X_Warranty_tbl(i).Duration_Period  := l_Warranty_tbl(i).Duration_Period;
          X_Warranty_tbl(i).Coverage_Schedule_id
                                             := l_Warranty_tbl(i).Coverage_Schedule_id ;
          X_Warranty_tbl(i).Warranty_Start_Date
                                             := l_Warranty_tbl(i).Warranty_Start_Date;
          X_Warranty_tbl(i).Warranty_End_Date := l_Warranty_tbl(i).Warranty_End_Date;
          X_Warranty_tbl(i).service_description := l_description;
          X_Warranty_tbl(i).service_name := l_concatenated_segments;
       ELSE
         -- raise FND_API.G_EXC_ERROR;
          CLOSE C_warranty;
       END IF;
    END IF;
   END LOOP;


      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --


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

END Get_Warranty;


End ASO_service_contracts_INT;

/
