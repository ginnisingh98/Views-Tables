--------------------------------------------------------
--  DDL for Package Body ASO_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_UTILITY_PVT" as
/* $Header: asovutlb.pls 120.20.12010000.18 2015/05/28 19:02:44 rassharm ship $ */
--
-- NAME
-- ASO_UTILITY_PVT
--
-- HISTORY
--				10/18/2002 hyang - 2633507, performance fix
--

G_PKG_NAME    CONSTANT VARCHAR2(30):='ASO_UTILITY_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12):='asovutlb.pls';

PROCEDURE Start_API(
    p_api_name              IN      VARCHAR2,
    p_pkg_name              IN      VARCHAR2,
    p_init_msg_list         IN      VARCHAR2,
    p_l_api_version         IN      NUMBER,
    p_api_version           IN      NUMBER,
    p_api_type              IN      VARCHAR2,
    x_return_status         OUT NOCOPY /* file.sql.39 change */       VARCHAR2)
IS
BEGIN
    NULL;
END Start_API;


PROCEDURE End_API(
    x_msg_count             OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data              OUT NOCOPY /* file.sql.39 change */       VARCHAR2)
IS
BEGIN
    NULL;
END End_API;


PROCEDURE Handle_Exceptions(
                P_API_NAME        IN  VARCHAR2,
                P_PKG_NAME        IN  VARCHAR2,
                P_EXCEPTION_LEVEL IN  NUMBER   := FND_API.G_MISS_NUM,
                P_SQLCODE         IN  NUMBER   :=NULL,
                P_SQLERRM         IN  VARCHAR2 := NULL,
                P_PACKAGE_TYPE    IN  VARCHAR2,
                X_MSG_COUNT       OUT NOCOPY /* file.sql.39 change */   NUMBER,
                X_MSG_DATA        OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
			 X_RETURN_STATUS   OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS
l_api_name    VARCHAR2(30);
l_len_sqlerrm Number ;
i number := 1;

BEGIN
    l_api_name := UPPER(p_api_name);

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('Exception in package : '|| P_PKG_NAME, 1, 'N');
      aso_debug_pub.add('Exception in API : '|| P_API_NAME, 1, 'N');
      aso_debug_pub.add('SQLCODE : '|| P_SQLCODE, 1, 'N');
      aso_debug_pub.add('SQLERRM : '|| P_SQLERRM, 1, 'N');
    END IF;

    DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || p_package_type);
    IF p_exception_level = FND_MSG_PUB.G_MSG_LVL_ERROR
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
    ELSIF p_exception_level = FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
    ELSIF p_exception_level = G_EXC_OTHERS
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.Set_Name('ASO', 'ASO_ERROR_RETURNED');
        FND_MESSAGE.Set_token('PKG_NAME' , p_pkg_name);
        FND_MESSAGE.Set_token('API_NAME' , p_api_name);
        FND_MSG_PUB.ADD;
        l_len_sqlerrm := Length(P_SQLERRM) ;
           While l_len_sqlerrm >= i Loop
             FND_MESSAGE.Set_Name('ASO', 'ASO_SQLERRM');
             FND_MESSAGE.Set_token('ERR_TEXT' , substr(P_SQLERRM,i,240));
             i := i + 240;
             FND_MSG_PUB.ADD;
          end loop;


        FND_MSG_PUB.Count_And_Get(
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);

    END IF;

END Handle_Exceptions;




FUNCTION get_subOrderBy(p_col_choice IN NUMBER, p_col_name IN VARCHAR2)
        RETURN VARCHAR2 IS
l_col_name varchar2(30);
begin

     if (p_col_choice is NULL and p_col_name is NOT NULL)
         or (p_col_choice is NOT NULL and p_col_name is NULL)
     then
         if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         then
             fnd_message.set_name('ASO', 'API_MISSING_ORDERBY_ELEMENT');
             fnd_msg_pub.add;
         end if;
         raise fnd_api.g_exc_error;
     end if;


	if (nls_upper(p_col_name) = 'CUSTOMER_NAME')
	then
		l_col_name :=  ' nls_upper' ||'(' ||p_col_name|| ')';
	else
		l_col_name := p_col_name;
	end if;

     if (mod(p_col_choice, 10) = 1)
     then
         return(l_col_name || ' ASC, ');
     elsif (mod(p_col_choice, 10) = 0)
     then
         return(l_col_name || ' DESC, ');
     else
         if fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
         then
             fnd_message.set_name('ASO', 'API_INVALID_ORDERBY_CHOICE');
             fnd_message.set_token('PARAM',p_col_choice, false);
             fnd_msg_pub.add;
         end if;
         raise fnd_api.g_exc_error;
         return '';
     end if;
end;

PROCEDURE Translate_OrderBy
(   p_api_version_number IN    NUMBER,
    p_init_msg_list      IN    VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN    NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    p_order_by_tbl       IN    UTIL_ORDER_BY_TBL_TYPE,
    x_order_by_clause    OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    x_return_status      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    x_msg_count          OUT NOCOPY /* file.sql.39 change */     NUMBER,
    x_msg_data           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
) IS

TYPE OrderByTabTyp is TABLE of VARCHAR2(80) INDEX BY BINARY_INTEGER;
l_sortedOrderBy_tbl  OrderByTabTyp;
i                    BINARY_INTEGER := 1;
j                    BINARY_INTEGER := 1;
l_order_by_clause    VARCHAR2(2000) := NULL;
l_api_name           CONSTANT VARCHAR2(30)     := 'Translate_OrderBy';
l_api_version_number CONSTANT NUMBER   := 1.0;
G_USER_ID     NUMBER := FND_GLOBAL.User_Id;
begin
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
	THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('ASO', 'API_UNEXP_ERROR_IN_PROCESSING');
			FND_MESSAGE.Set_Token('ROW', 'TRANSLATE_ORDERBY', TRUE);
			FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	--
	-- API body
	--

	-- Validate Environment

	IF G_User_Id IS NULL
	THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
			FND_MESSAGE.Set_Name('ASO', 'UT_CANNOT_GET_PROFILE_VALUE');
			FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
			FND_MSG_PUB.ADD;
		END IF;
	END IF;

     -- initialize the table to ''.
        for i in 1..p_order_by_tbl.count loop
            l_sortedOrderBy_tbl(i) := '';
        end loop;

     -- We allow the choice seqence order such as 41, 20, 11, ...
     -- So, we need to sort it first(put them into a table),
     -- then loop through the whole table.

     for j in 1..p_order_by_tbl.count loop
        if (p_order_by_tbl(j).col_choice is NOT NULL)
        then
            l_sortedOrderBy_tbl(floor(p_order_by_tbl(j).col_choice/10)) :=
                get_subOrderBy(p_order_by_tbl(j).col_choice,
                                p_order_by_tbl(j).col_name);
        end if;
     end loop;

     for i in 1..p_order_by_tbl.count loop
            l_order_by_clause := l_order_by_clause || l_sortedOrderBy_tbl(i);
     end loop;
     l_order_by_clause := rtrim(l_order_by_clause); -- trim ''
     l_order_by_clause := rtrim(l_order_by_clause, ',');    -- trim last ,
     x_order_by_clause := l_order_by_clause;

     EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );


     WHEN OTHERS THEN


          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get
              ( p_count           =>      x_msg_count,
                p_data            =>      x_msg_data
              );

end Translate_OrderBy;


PROCEDURE Debug_Message(
    p_msg_level IN NUMBER,
--    p_app_name IN VARCHAR2 := 'ASO',
    p_msg       IN VARCHAR2)
IS
l_length    NUMBER;
l_start     NUMBER := 1;
l_substring VARCHAR2(30);
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    THEN
/*
        l_length := length(p_msg);

        -- FND_MESSAGE doesn't allow message name to be over 30 chars
        -- chop message name if length > 30
        WHILE l_length > 30 LOOP
            l_substring := substr(p_msg, l_start, 30);

            FND_MESSAGE.Set_Name('ASO', l_substring);
--          FND_MESSAGE.Set_Name(p_app_name, l_substring);
            l_start := l_start + 30;
            l_length := l_length - 30;
            FND_MSG_PUB.Add;
        END LOOP;

        l_substring := substr(p_msg, l_start);
        FND_MESSAGE.Set_Name('ASO', l_substring);
        --dbms_output.put_line('l_substring: ' || l_substring);
--      FND_MESSAGE.Set_Name(p_app_name, p_msg);
        FND_MSG_PUB.Add;
*/
        l_length := length(p_msg);

        -- FND_MESSAGE doesn't allow message name to be over 30 chars
        -- chop message name if length > 30
        IF l_length > 30
        THEN
            l_substring := substr(p_msg, l_start, 30);
            FND_MESSAGE.Set_Name('ASO', l_substring);
        ELSE
            FND_MESSAGE.Set_Name('ASO', p_msg);
        END IF;

        FND_MSG_PUB.Add;
    END IF;
END Debug_Message;


PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2
)
IS
BEGIN
    NULL;
END Set_Message;

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2
)
IS
BEGIN
    NULL;
END Set_Message;

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2,
    p_token3        IN      VARCHAR2,
    p_token3_value  IN      VARCHAR2
)
IS
BEGIN
    NULL;
END Set_Message;



PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token1_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token2        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token3        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token3_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token4        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token4_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token5        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token5_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token6        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token6_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token7        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token7_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR
)
IS
BEGIN
    NULL;
END Set_Message;

PROCEDURE Gen_Flexfield_Where(
		p_flex_where_tbl_type	IN 	ASO_UTILITY_PVT.flex_where_tbl_type,
		x_flex_where_clause OUT NOCOPY /* file.sql.39 change */  	VARCHAR2) IS
l_flex_where_cl 	VARCHAR2(2000) 		:= NULL;
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    null;
    --dbms_output.put_line('ASO_UTILITY_PVT Generate Flexfield Where: begin');
  END IF;

  FOR i IN 1..p_flex_where_tbl_type.count LOOP
    IF (p_flex_where_tbl_type(i).value IS NOT NULL
		AND p_flex_where_tbl_type(i).value <> FND_API.G_MISS_CHAR) THEN
      l_flex_where_cl := l_flex_where_cl||' AND '||p_flex_where_tbl_type(i).name
			 || ' = :p_ofso_flex_var'||i;
    END IF;
  END LOOP;
  x_flex_where_clause := l_flex_where_cl;

  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    null;
    --dbms_output.put_line('ASO_UTILITY_PVT Generate Flexfield Where: end');
  END IF;
END;

PROCEDURE Bind_Flexfield_Where(
		p_cursor_id		IN	NUMBER,
		p_flex_where_tbl_type	IN 	ASO_UTILITY_PVT.flex_where_tbl_type) IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    null;
    --dbms_output.put_line('ASO_UTILITY_PVT Bind Flexfield Where: begin');
  END IF;

  FOR i IN 1..p_flex_where_tbl_type.count LOOP
    IF (p_flex_where_tbl_type(i).value IS NOT NULL
		AND p_flex_where_tbl_type(i).value <> FND_API.G_MISS_CHAR) THEN
      DBMS_SQL.Bind_Variable(p_cursor_id, ':p_ofso_flex_var'||i,
				p_flex_where_tbl_type(i).value);
    END IF;
  END LOOP;

  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    null;
    --dbms_output.put_line('ASO_UTILITY_PVT Bind Flexfield Where: end');
  END IF;
END;



PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_msgs          OUT NOCOPY /* file.sql.39 change */   VARCHAR2)
IS

      l_msg_list        VARCHAR2(2000) := '
';
      l_temp_msg        VARCHAR2(2000);


      l_appl_short_name  VARCHAR2(20) ;
      l_message_name    VARCHAR2(30) ;
      l_prefix_msg      VARCHAR2(2000);
      l_id              NUMBER;
      l_message_num     NUMBER;

      l_msg_count       NUMBER;
      l_msg_data        VARCHAR2(2000);

      Cursor Get_Appl_Id (x_short_name VARCHAR2) IS
        SELECT  application_id
        FROM    fnd_application_vl
        WHERE   application_short_name = x_short_name;

      Cursor Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
        SELECT  msg.message_number
        FROM    fnd_new_messages msg, fnd_languages_vl lng
        WHERE   msg.message_name = x_msg
          and   msg.application_id = x_id
          and   lng.LANGUAGE_CODE = msg.language_code
          and   lng.language_id = x_lang_id;
BEGIN



      FOR l_count in 1..NVL(p_message_count,1) LOOP
          l_temp_msg := fnd_msg_pub.get(l_count, fnd_api.g_true);

          fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);

          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id into l_id;
          CLOSE Get_Appl_Id;

          l_message_num := NULL;
          IF l_id is not NULL
          THEN
              OPEN Get_Message_Num (l_message_name, l_id,
                        to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num into l_message_num;
              CLOSE Get_Message_Num;
          END IF;


          IF NVL(l_message_num, 0) <> 0
          THEN
            l_prefix_msg := 'APP-' || to_char(l_message_num) || ': ';
          ELSE
            l_prefix_msg := NULL;
          END IF;

          l_temp_msg := fnd_msg_pub.get(l_count, fnd_api.g_false);

          EXIT WHEN (Length(l_msg_list) + Length(l_prefix_msg) + Length(l_temp_msg)) > 2000;

          l_msg_list := l_msg_list || l_prefix_msg || l_temp_msg;

          l_msg_list := l_msg_list || '
';
      END LOOP;

      x_msgs := substr(l_msg_list, 0, 2000);

END Get_Messages;

FUNCTION  Query_Header_Row (
    P_Qte_Header_Id		 IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.qte_header_rec_Type
IS
    l_qte_header_rec	ASO_QUOTE_PUB.qte_header_rec_Type;
BEGIN
	Select
	   quote_header_id,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
           ORG_ID,
           QUOTE_NAME,
           QUOTE_NUMBER,
           QUOTE_VERSION,
           QUOTE_STATUS_ID,
           QUOTE_SOURCE_CODE,
           QUOTE_EXPIRATION_DATE,
           PRICE_FROZEN_DATE,
           QUOTE_PASSWORD,
           ORIGINAL_SYSTEM_REFERENCE,
           PARTY_ID,
           CUST_ACCOUNT_ID,
           INVOICE_TO_CUST_ACCOUNT_ID,
           ORG_CONTACT_ID,
	   PHONE_ID,
           INVOICE_TO_PARTY_SITE_ID,
           INVOICE_TO_PARTY_ID,
           ORIG_MKTG_SOURCE_CODE_ID,
           MARKETING_SOURCE_CODE_ID,
           ORDER_TYPE_ID,
           QUOTE_CATEGORY_CODE,
           ORDERED_DATE,
           ACCOUNTING_RULE_ID,
           INVOICING_RULE_ID,
           EMPLOYEE_PERSON_ID,
           PRICE_LIST_ID,
           CURRENCY_CODE,
           TOTAL_LIST_PRICE,
           TOTAL_ADJUSTED_AMOUNT,
           TOTAL_ADJUSTED_PERCENT,
           TOTAL_TAX,
           TOTAL_SHIPPING_CHARGE,
           SURCHARGE,
           TOTAL_QUOTE_PRICE,
           PAYMENT_AMOUNT,
           EXCHANGE_RATE,
           EXCHANGE_TYPE_CODE,
           EXCHANGE_RATE_DATE,
           CONTRACT_ID,
           SALES_CHANNEL_CODE,
	   ORDER_ID,
           RESOURCE_ID,
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
           CONTRACT_TEMPLATE_ID,
           CONTRACT_TEMPLATE_MAJOR_VER,
           CONTRACT_REQUESTER_ID,
           CONTRACT_APPROVAL_LEVEL,
           PUBLISH_FLAG,
           RESOURCE_GRP_ID,
           SOLD_TO_PARTY_SITE_ID,
		 DISPLAY_ARITHMETIC_OPERATOR,
		 MAX_VERSION_FLAG,
		 QUOTE_TYPE,
		 QUOTE_DESCRIPTION,
		 MINISITE_ID,
		 CUST_PARTY_ID,
		 INVOICE_TO_CUST_PARTY_ID,
		 PRICING_STATUS_INDICATOR,
		 TAX_STATUS_INDICATOR,
		 PRICE_UPDATED_DATE,
		 TAX_UPDATED_DATE,
		 RECALCULATE_FLAG,
		 PRICE_REQUEST_ID,
		 CREDIT_UPDATE_DATE,
-- hyang new okc
    Customer_Name_And_Title,
    Customer_Signature_Date,
    Supplier_Name_And_Title,
    Supplier_Signature_Date,
-- end of hyang new okc
           END_CUSTOMER_PARTY_ID,
           END_CUSTOMER_PARTY_SITE_ID,
           END_CUSTOMER_CUST_ACCOUNT_ID,
           END_CUSTOMER_CUST_PARTY_ID,
		 AUTOMATIC_PRICE_FLAG,
		 AUTOMATIC_TAX_FLAG,
		 ASSISTANCE_REQUESTED,
		 ASSISTANCE_REASON_CODE,
           OBJECT_VERSION_NUMBER,
	    -- ER 12879412
	   PRODUCT_FISC_CLASSIFICATION,
	   TRX_BUSINESS_CATEGORY,
	   -- ER 17900033
	   TOTAL_UNIT_COST,
	   TOTAL_MARGIN_AMOUNT,
	   TOTAL_MARGIN_PERCENT

	INTO
	   l_qte_header_rec.quote_header_id,
	   l_qte_header_rec.CREATION_DATE,
	   l_qte_header_rec.CREATED_BY,
	   l_qte_header_rec.LAST_UPDATE_DATE,
	   l_qte_header_rec.LAST_UPDATED_BY,
	   l_qte_header_rec.LAST_UPDATE_LOGIN,
	   l_qte_header_rec.REQUEST_ID,
	   l_qte_header_rec.PROGRAM_APPLICATION_ID,
	   l_qte_header_rec.PROGRAM_ID,
	   l_qte_header_rec.PROGRAM_UPDATE_DATE,
           l_qte_header_rec.ORG_ID,
           l_qte_header_rec.QUOTE_NAME,
           l_qte_header_rec.QUOTE_NUMBER,
           l_qte_header_rec.QUOTE_VERSION,
           l_qte_header_rec.QUOTE_STATUS_ID,
           l_qte_header_rec.QUOTE_SOURCE_CODE,
           l_qte_header_rec.QUOTE_EXPIRATION_DATE,
           l_qte_header_rec.PRICE_FROZEN_DATE,
           l_qte_header_rec.QUOTE_PASSWORD,
           l_qte_header_rec.ORIGINAL_SYSTEM_REFERENCE,
           l_qte_header_rec.PARTY_ID,
           l_qte_header_rec.CUST_ACCOUNT_ID,
           l_qte_header_rec.INVOICE_TO_CUST_ACCOUNT_ID,
           l_qte_header_rec.ORG_CONTACT_ID,
           l_qte_header_rec.PHONE_ID,
           l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID,
           l_qte_header_rec.INVOICE_TO_PARTY_ID,
           l_qte_header_rec.ORIG_MKTG_SOURCE_CODE_ID,
           l_qte_header_rec.MARKETING_SOURCE_CODE_ID,
           l_qte_header_rec.ORDER_TYPE_ID,
           l_qte_header_rec.QUOTE_CATEGORY_CODE,
           l_qte_header_rec.ORDERED_DATE,
           l_qte_header_rec.ACCOUNTING_RULE_ID,
           l_qte_header_rec.INVOICING_RULE_ID,
           l_qte_header_rec.EMPLOYEE_PERSON_ID,
           l_qte_header_rec.PRICE_LIST_ID,
           l_qte_header_rec.CURRENCY_CODE,
           l_qte_header_rec.TOTAL_LIST_PRICE,
           l_qte_header_rec.TOTAL_ADJUSTED_AMOUNT,
           l_qte_header_rec.TOTAL_ADJUSTED_PERCENT,
           l_qte_header_rec.TOTAL_TAX,
           l_qte_header_rec.TOTAL_SHIPPING_CHARGE,
           l_qte_header_rec.SURCHARGE,
           l_qte_header_rec.TOTAL_QUOTE_PRICE,
           l_qte_header_rec.PAYMENT_AMOUNT,
           l_qte_header_rec.EXCHANGE_RATE,
           l_qte_header_rec.EXCHANGE_TYPE_CODE,
           l_qte_header_rec.EXCHANGE_RATE_DATE,
           l_qte_header_rec.CONTRACT_ID,
           l_qte_header_rec.SALES_CHANNEL_CODE,
	   l_qte_header_rec.ORDER_ID,
           l_qte_header_rec.RESOURCE_ID,
           l_qte_header_rec.ATTRIBUTE_CATEGORY,
           l_qte_header_rec.ATTRIBUTE1,
           l_qte_header_rec.ATTRIBUTE2,
           l_qte_header_rec.ATTRIBUTE3,
           l_qte_header_rec.ATTRIBUTE4,
           l_qte_header_rec.ATTRIBUTE5,
           l_qte_header_rec.ATTRIBUTE6,
           l_qte_header_rec.ATTRIBUTE7,
           l_qte_header_rec.ATTRIBUTE8,
           l_qte_header_rec.ATTRIBUTE9,
           l_qte_header_rec.ATTRIBUTE10,
           l_qte_header_rec.ATTRIBUTE11,
           l_qte_header_rec.ATTRIBUTE12,
           l_qte_header_rec.ATTRIBUTE13,
           l_qte_header_rec.ATTRIBUTE14,
           l_qte_header_rec.ATTRIBUTE15,
           l_qte_header_rec.ATTRIBUTE16,
           l_qte_header_rec.ATTRIBUTE17,
           l_qte_header_rec.ATTRIBUTE18,
           l_qte_header_rec.ATTRIBUTE19,
           l_qte_header_rec.ATTRIBUTE20,
           l_qte_header_rec.CONTRACT_TEMPLATE_ID,
           l_qte_header_rec.CONTRACT_TEMPLATE_MAJOR_VER,
           l_qte_header_rec.CONTRACT_REQUESTER_ID,
           l_qte_header_rec.CONTRACT_APPROVAL_LEVEL,
           l_qte_header_rec.PUBLISH_FLAG,
           l_qte_header_rec.RESOURCE_GRP_ID,
           l_qte_header_rec.SOLD_TO_PARTY_SITE_ID,
		 l_qte_header_rec.DISPLAY_ARITHMETIC_OPERATOR,
		 l_qte_header_rec.MAX_VERSION_FLAG,
		 l_qte_header_rec.QUOTE_TYPE,
		 l_qte_header_rec.QUOTE_DESCRIPTION,
		 l_qte_header_rec.MINISITE_ID,
		 l_qte_header_rec.CUST_PARTY_ID,
		 l_qte_header_rec.INVOICE_TO_CUST_PARTY_ID,
		 l_qte_header_rec.PRICING_STATUS_INDICATOR,
		 l_qte_header_rec.TAX_STATUS_INDICATOR,
		 l_qte_header_rec.PRICE_UPDATED_DATE,
		 l_qte_header_rec.TAX_UPDATED_DATE,
		 l_qte_header_rec.RECALCULATE_FLAG,
		 l_qte_header_rec.PRICE_REQUEST_ID,
		 l_qte_header_rec.CREDIT_UPDATE_DATE,
-- hyang new okc
    l_qte_header_rec.Customer_Name_And_Title,
    l_qte_header_rec.Customer_Signature_Date,
    l_qte_header_rec.Supplier_Name_And_Title,
    l_qte_header_rec.Supplier_Signature_Date,
-- end of hyang new okc
           l_qte_header_rec.END_CUSTOMER_PARTY_ID,
           l_qte_header_rec.END_CUSTOMER_PARTY_SITE_ID,
           l_qte_header_rec.END_CUSTOMER_CUST_ACCOUNT_ID,
           l_qte_header_rec.END_CUSTOMER_CUST_PARTY_ID,
		 l_qte_header_rec.AUTOMATIC_PRICE_FLAG,
           l_qte_header_rec.AUTOMATIC_TAX_FLAG,
           l_qte_header_rec.ASSISTANCE_REQUESTED,
		 l_qte_header_rec.ASSISTANCE_REASON_CODE,
		 l_qte_header_rec.OBJECT_VERSION_NUMBER,
                  -- ER 12879412
	   l_qte_header_rec.PRODUCT_FISC_CLASSIFICATION,
	   l_qte_header_rec.TRX_BUSINESS_CATEGORY,
	   -- ER 17900033
	   l_qte_header_rec.TOTAL_UNIT_COST,
           l_qte_header_rec.TOTAL_MARGIN_AMOUNT,
           l_qte_header_rec.TOTAL_MARGIN_PERCENT



	FROM ASO_QUOTE_HEADERS_ALL
	WHERE quote_header_id = p_qte_header_id;
	RETURN l_qte_header_rec;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_IN_QUERY');
	    FND_MSG_PUB.ADD;
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Header_Row;


FUNCTION Query_Price_Adj_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Tbl_Type
IS
    CURSOR c_price_adj_hdr IS
	SELECT
        PRICE_ADJUSTMENT_ID,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   REQUEST_ID,
	   QUOTE_HEADER_ID,
	   QUOTE_LINE_ID,
	   MODIFIER_HEADER_ID,
	   MODIFIER_LINE_ID,
	   MODIFIER_LINE_TYPE_CODE,
	   MODIFIER_MECHANISM_TYPE_CODE,
	   MODIFIED_FROM,
        MODIFIED_TO,
	   OPERAND,
	   ARITHMETIC_OPERATOR,
	   AUTOMATIC_FLAG,
	   UPDATE_ALLOWABLE_FLAG,
        UPDATED_FLAG,
	   APPLIED_FLAG,
	   ON_INVOICE_FLAG,
	   PRICING_PHASE_ID,
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
	   TAX_CODE,
	   TAX_EXEMPT_FLAG,
	   TAX_EXEMPT_NUMBER,
	   TAX_EXEMPT_REASON_CODE,
	   PARENT_ADJUSTMENT_ID,
	   INVOICED_FLAG,
	   ESTIMATED_FLAG,
	   INC_IN_SALES_PERFORMANCE,
	   SPLIT_ACTION_CODE,
	   ADJUSTED_AMOUNT,
	   CHARGE_TYPE_CODE,
	   CHARGE_SUBTYPE_CODE,
	   RANGE_BREAK_QUANTITY,
	   ACCRUAL_CONVERSION_RATE,
	   PRICING_GROUP_SEQUENCE,
	   ACCRUAL_FLAG,
	   LIST_LINE_NO,
	   SOURCE_SYSTEM_CODE,
	   BENEFIT_QTY,
	   BENEFIT_UOM_CODE,
	   PRINT_ON_INVOICE_FLAG,
	   EXPIRATION_DATE,
	   REBATE_TRANSACTION_TYPE_CODE,
	   REBATE_TRANSACTION_REFERENCE,
	   REBATE_PAYMENT_SYSTEM_CODE,
	   REDEEMED_DATE,
	   REDEEMED_FLAG,
	   MODIFIER_LEVEL_CODE,
	   PRICE_BREAK_TYPE_CODE,
	   SUBSTITUTION_ATTRIBUTE,
	   PRORATION_TYPE_CODE,
	   INCLUDE_ON_RETURNS_FLAG,
	   CREDIT_OR_CHARGE_FLAG,
	   ORIG_SYS_DISCOUNT_REF,
	   CHANGE_REASON_CODE,
	   CHANGE_REASON_TEXT,
	   COST_ID,
	   LIST_LINE_TYPE_CODE,
	   UPDATE_ALLOWED,
	   CHANGE_SEQUENCE,
	   LIST_HEADER_ID,
	   LIST_LINE_ID,
	   QUOTE_SHIPMENT_ID,
	   OPERAND_PER_PQTY,
	   ADJUSTED_AMOUNT_PER_PQTY,
        OBJECT_VERSION_NUMBER
     FROM ASO_PRICE_ADJUSTMENTS
	WHERE quote_header_id = p_qte_header_id
	     AND quote_line_id IS NULL;

    CURSOR c_price_adj_line IS
	SELECT
        PRICE_ADJUSTMENT_ID,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   REQUEST_ID,
	   QUOTE_HEADER_ID,
	   QUOTE_LINE_ID,
	   MODIFIER_HEADER_ID,
	   MODIFIER_LINE_ID,
	   MODIFIER_LINE_TYPE_CODE,
	   MODIFIER_MECHANISM_TYPE_CODE,
	   MODIFIED_FROM,
        MODIFIED_TO,
	   OPERAND,
	   ARITHMETIC_OPERATOR,
	   AUTOMATIC_FLAG,
	   UPDATE_ALLOWABLE_FLAG,
        UPDATED_FLAG,
	   APPLIED_FLAG,
	   ON_INVOICE_FLAG,
	   PRICING_PHASE_ID,
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
	   TAX_CODE,
	   TAX_EXEMPT_FLAG,
	   TAX_EXEMPT_NUMBER,
	   TAX_EXEMPT_REASON_CODE,
	   PARENT_ADJUSTMENT_ID,
	   INVOICED_FLAG,
	   ESTIMATED_FLAG,
	   INC_IN_SALES_PERFORMANCE,
	   SPLIT_ACTION_CODE,
	   ADJUSTED_AMOUNT,
	   CHARGE_TYPE_CODE,
	   CHARGE_SUBTYPE_CODE,
	   RANGE_BREAK_QUANTITY,
	   ACCRUAL_CONVERSION_RATE,
	   PRICING_GROUP_SEQUENCE,
	   ACCRUAL_FLAG,
	   LIST_LINE_NO,
	   SOURCE_SYSTEM_CODE,
	   BENEFIT_QTY,
	   BENEFIT_UOM_CODE,
	   PRINT_ON_INVOICE_FLAG,
	   EXPIRATION_DATE,
	   REBATE_TRANSACTION_TYPE_CODE,
	   REBATE_TRANSACTION_REFERENCE,
	   REBATE_PAYMENT_SYSTEM_CODE,
	   REDEEMED_DATE,
	   REDEEMED_FLAG,
	   MODIFIER_LEVEL_CODE,
	   PRICE_BREAK_TYPE_CODE,
	   SUBSTITUTION_ATTRIBUTE,
	   PRORATION_TYPE_CODE,
	   INCLUDE_ON_RETURNS_FLAG,
	   CREDIT_OR_CHARGE_FLAG,
	   ORIG_SYS_DISCOUNT_REF,
	   CHANGE_REASON_CODE,
	   CHANGE_REASON_TEXT,
	   COST_ID,
	   LIST_LINE_TYPE_CODE,
	   UPDATE_ALLOWED,
	   CHANGE_SEQUENCE,
	   LIST_HEADER_ID,
	   LIST_LINE_ID,
	   QUOTE_SHIPMENT_ID,
	   OPERAND_PER_PQTY,
	   ADJUSTED_AMOUNT_PER_PQTY,
        OBJECT_VERSION_NUMBER
     FROM ASO_PRICE_ADJUSTMENTS
	WHERE quote_header_id = p_qte_header_id
     AND quote_line_id IS NOT NULL
     AND quote_line_id = p_qte_line_id;

    l_price_adj_rec             ASO_QUOTE_PUB.Price_Adj_Rec_Type;
    l_price_adj_tbl             ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
BEGIN
    IF P_Qte_Line_Id is NULL or P_Qte_Line_Id = FND_API.G_MISS_NUM THEN
      FOR price_adj_rec IN c_price_adj_hdr LOOP
	   l_price_adj_rec.PRICE_ADJUSTMENT_ID := price_adj_rec.PRICE_ADJUSTMENT_ID;
	   l_price_adj_rec.CREATION_DATE := price_adj_rec.CREATION_DATE;
	   l_price_adj_rec.CREATED_BY := price_adj_rec.CREATED_BY;
	   l_price_adj_rec.LAST_UPDATE_DATE := price_adj_rec.LAST_UPDATE_DATE;
	   l_price_adj_rec.LAST_UPDATED_BY := price_adj_rec.LAST_UPDATED_BY;
	   l_price_adj_rec.LAST_UPDATE_LOGIN := price_adj_rec.LAST_UPDATE_LOGIN;
	   l_price_adj_rec.REQUEST_ID := price_adj_rec.REQUEST_ID;
	   l_price_adj_rec.PROGRAM_APPLICATION_ID := price_adj_rec.PROGRAM_APPLICATION_ID;
	   l_price_adj_rec.PROGRAM_ID := price_adj_rec.PROGRAM_ID;
	   l_price_adj_rec.PROGRAM_UPDATE_DATE := price_adj_rec.PROGRAM_UPDATE_DATE;
	   l_price_adj_rec.QUOTE_HEADER_ID := price_adj_rec.QUOTE_HEADER_ID;
	   l_price_adj_rec.QUOTE_LINE_ID := price_adj_rec.QUOTE_LINE_ID;
	   l_price_adj_rec.MODIFIER_HEADER_ID := price_adj_rec.MODIFIER_HEADER_ID;
	   l_price_adj_rec.MODIFIER_LINE_ID := price_adj_rec.MODIFIER_LINE_ID;
	   l_price_adj_rec.MODIFIER_LINE_TYPE_CODE := price_adj_rec.MODIFIER_LINE_TYPE_CODE;
	   l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE := price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE;
	   l_price_adj_rec.MODIFIED_FROM := price_adj_rec.MODIFIED_FROM;
	   l_price_adj_rec.MODIFIED_TO := price_adj_rec.MODIFIED_TO;
	   l_price_adj_rec.OPERAND := price_adj_rec.OPERAND;
	   l_price_adj_rec.ARITHMETIC_OPERATOR := price_adj_rec.ARITHMETIC_OPERATOR;
	   l_price_adj_rec.AUTOMATIC_FLAG := price_adj_rec.AUTOMATIC_FLAG;
	   l_price_adj_rec.UPDATE_ALLOWABLE_FLAG := price_adj_rec.UPDATE_ALLOWABLE_FLAG;
	   l_price_adj_rec.UPDATED_FLAG := price_adj_rec.UPDATED_FLAG;
	   l_price_adj_rec.APPLIED_FLAG := price_adj_rec.APPLIED_FLAG;
	   l_price_adj_rec.ON_INVOICE_FLAG := price_adj_rec.ON_INVOICE_FLAG;
	   l_price_adj_rec.PRICING_PHASE_ID := price_adj_rec.PRICING_PHASE_ID;
	   l_price_adj_rec.QUOTE_SHIPMENT_ID := price_adj_rec.QUOTE_SHIPMENT_ID;
	   l_price_adj_rec.ATTRIBUTE_CATEGORY := price_adj_rec.ATTRIBUTE_CATEGORY;
	   l_price_adj_rec.ATTRIBUTE1 := price_adj_rec.ATTRIBUTE1;
	   l_price_adj_rec.ATTRIBUTE2 := price_adj_rec.ATTRIBUTE2;
	   l_price_adj_rec.ATTRIBUTE3 := price_adj_rec.ATTRIBUTE3;
	   l_price_adj_rec.ATTRIBUTE4 := price_adj_rec.ATTRIBUTE4;
	   l_price_adj_rec.ATTRIBUTE5 := price_adj_rec.ATTRIBUTE5;
	   l_price_adj_rec.ATTRIBUTE6 := price_adj_rec.ATTRIBUTE6;
	   l_price_adj_rec.ATTRIBUTE7 := price_adj_rec.ATTRIBUTE7;
	   l_price_adj_rec.ATTRIBUTE8 := price_adj_rec.ATTRIBUTE8;
	   l_price_adj_rec.ATTRIBUTE9 := price_adj_rec.ATTRIBUTE9;
	   l_price_adj_rec.ATTRIBUTE10 := price_adj_rec.ATTRIBUTE10;
	   l_price_adj_rec.ATTRIBUTE11 := price_adj_rec.ATTRIBUTE11;
	   l_price_adj_rec.ATTRIBUTE12 := price_adj_rec.ATTRIBUTE12;
	   l_price_adj_rec.ATTRIBUTE13 := price_adj_rec.ATTRIBUTE13;
	   l_price_adj_rec.ATTRIBUTE14 := price_adj_rec.ATTRIBUTE14;
	   l_price_adj_rec.ATTRIBUTE15 := price_adj_rec.ATTRIBUTE15;
	   l_price_adj_rec.ATTRIBUTE16 := price_adj_rec.ATTRIBUTE16;
	   l_price_adj_rec.ATTRIBUTE17 := price_adj_rec.ATTRIBUTE17;
	   l_price_adj_rec.ATTRIBUTE18 := price_adj_rec.ATTRIBUTE18;
	   l_price_adj_rec.ATTRIBUTE19 := price_adj_rec.ATTRIBUTE19;
	   l_price_adj_rec.ATTRIBUTE20 := price_adj_rec.ATTRIBUTE20;
        l_price_adj_rec.TAX_CODE   := price_adj_rec.TAX_CODE;
	   l_price_adj_rec.TAX_EXEMPT_FLAG := price_adj_rec.TAX_EXEMPT_FLAG;
	   l_price_adj_rec.TAX_EXEMPT_NUMBER := price_adj_rec.TAX_EXEMPT_NUMBER;
	   l_price_adj_rec.TAX_EXEMPT_REASON_CODE := price_adj_rec.TAX_EXEMPT_REASON_CODE;
	   l_price_adj_rec.PARENT_ADJUSTMENT_ID := price_adj_rec.PARENT_ADJUSTMENT_ID;
	   l_price_adj_rec.INVOICED_FLAG := price_adj_rec.INVOICED_FLAG;
	   l_price_adj_rec.ESTIMATED_FLAG := price_adj_rec.ESTIMATED_FLAG;
	   l_price_adj_rec.INC_IN_SALES_PERFORMANCE := price_adj_rec.INC_IN_SALES_PERFORMANCE;
	   l_price_adj_rec.SPLIT_ACTION_CODE := price_adj_rec.SPLIT_ACTION_CODE;
	   l_price_adj_rec.ADJUSTED_AMOUNT := price_adj_rec.ADJUSTED_AMOUNT;
	   l_price_adj_rec.CHARGE_TYPE_CODE := price_adj_rec.CHARGE_TYPE_CODE;
	   l_price_adj_rec.CHARGE_SUBTYPE_CODE := price_adj_rec.CHARGE_SUBTYPE_CODE;
	   l_price_adj_rec.RANGE_BREAK_QUANTITY := price_adj_rec.RANGE_BREAK_QUANTITY;
	   l_price_adj_rec.ACCRUAL_CONVERSION_RATE := price_adj_rec.ACCRUAL_CONVERSION_RATE;
	   l_price_adj_rec.PRICING_GROUP_SEQUENCE := price_adj_rec.PRICING_GROUP_SEQUENCE;
	   l_price_adj_rec.ACCRUAL_FLAG := price_adj_rec.ACCRUAL_FLAG;
	   l_price_adj_rec.LIST_LINE_NO := price_adj_rec.LIST_LINE_NO;
	   l_price_adj_rec.SOURCE_SYSTEM_CODE := price_adj_rec.SOURCE_SYSTEM_CODE;
	   l_price_adj_rec.BENEFIT_QTY := price_adj_rec.BENEFIT_QTY;
	   l_price_adj_rec.BENEFIT_UOM_CODE := price_adj_rec.BENEFIT_UOM_CODE;
	   l_price_adj_rec.PRINT_ON_INVOICE_FLAG := price_adj_rec.PRINT_ON_INVOICE_FLAG;
	   l_price_adj_rec.EXPIRATION_DATE := price_adj_rec.EXPIRATION_DATE;
	   l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE := price_adj_rec.REBATE_TRANSACTION_TYPE_CODE;
	   l_price_adj_rec.REBATE_TRANSACTION_REFERENCE := price_adj_rec.REBATE_TRANSACTION_REFERENCE;
	   l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE := price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE;
	   l_price_adj_rec.REDEEMED_DATE := price_adj_rec.REDEEMED_DATE;
	   l_price_adj_rec.REDEEMED_FLAG := price_adj_rec.REDEEMED_FLAG;
	   l_price_adj_rec.MODIFIER_LEVEL_CODE := price_adj_rec.MODIFIER_LEVEL_CODE;
	   l_price_adj_rec.PRICE_BREAK_TYPE_CODE := price_adj_rec.PRICE_BREAK_TYPE_CODE;
	   l_price_adj_rec.SUBSTITUTION_ATTRIBUTE := price_adj_rec.SUBSTITUTION_ATTRIBUTE;
	   l_price_adj_rec.PRORATION_TYPE_CODE := price_adj_rec.PRORATION_TYPE_CODE;
	   l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG := price_adj_rec.INCLUDE_ON_RETURNS_FLAG;
	   l_price_adj_rec.CREDIT_OR_CHARGE_FLAG := price_adj_rec.CREDIT_OR_CHARGE_FLAG;
	   l_price_adj_rec.ORIG_SYS_DISCOUNT_REF := price_adj_rec.ORIG_SYS_DISCOUNT_REF;
	   l_price_adj_rec.CHANGE_REASON_CODE := price_adj_rec.CHANGE_REASON_CODE;
	   l_price_adj_rec.CHANGE_REASON_TEXT := price_adj_rec.CHANGE_REASON_TEXT;
	   l_price_adj_rec.COST_ID := price_adj_rec.COST_ID;
	   --l_price_adj_rec.LIST_LINE_TYPE_CODE := price_adj_rec.LIST_LINE_TYPE_CODE;
	   l_price_adj_rec.UPDATE_ALLOWED := price_adj_rec.UPDATE_ALLOWED;
	   l_price_adj_rec.CHANGE_SEQUENCE := price_adj_rec.CHANGE_SEQUENCE;
	   l_price_adj_rec.OBJECT_VERSION_NUMBER := price_adj_rec.OBJECT_VERSION_NUMBER;
	   l_price_adj_rec.OPERAND_PER_PQTY := price_adj_rec.OPERAND_PER_PQTY;
	   l_price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY := price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY;

	   l_price_adj_tbl(l_price_adj_tbl.COUNT+1) := l_price_adj_rec;
      END LOOP;
    ELSIF P_Qte_Line_Id is NOT NULL OR P_Qte_Line_Id <> FND_API.G_MISS_NUM THEN
      FOR price_adj_rec IN c_price_adj_line LOOP
	   l_price_adj_rec.PRICE_ADJUSTMENT_ID := price_adj_rec.PRICE_ADJUSTMENT_ID;
	   l_price_adj_rec.CREATION_DATE := price_adj_rec.CREATION_DATE;
	   l_price_adj_rec.CREATED_BY := price_adj_rec.CREATED_BY;
	   l_price_adj_rec.LAST_UPDATE_DATE := price_adj_rec.LAST_UPDATE_DATE;
	   l_price_adj_rec.LAST_UPDATED_BY := price_adj_rec.LAST_UPDATED_BY;
	   l_price_adj_rec.LAST_UPDATE_LOGIN := price_adj_rec.LAST_UPDATE_LOGIN;
	   l_price_adj_rec.REQUEST_ID := price_adj_rec.REQUEST_ID;
	   l_price_adj_rec.PROGRAM_APPLICATION_ID := price_adj_rec.PROGRAM_APPLICATION_ID;
	   l_price_adj_rec.PROGRAM_ID := price_adj_rec.PROGRAM_ID;
	   l_price_adj_rec.PROGRAM_UPDATE_DATE := price_adj_rec.PROGRAM_UPDATE_DATE;
	   l_price_adj_rec.QUOTE_HEADER_ID := price_adj_rec.QUOTE_HEADER_ID;
	   l_price_adj_rec.QUOTE_LINE_ID := price_adj_rec.QUOTE_LINE_ID;
	   l_price_adj_rec.MODIFIER_HEADER_ID := price_adj_rec.MODIFIER_HEADER_ID;
	   l_price_adj_rec.MODIFIER_LINE_ID := price_adj_rec.MODIFIER_LINE_ID;
	   l_price_adj_rec.MODIFIER_LINE_TYPE_CODE := price_adj_rec.MODIFIER_LINE_TYPE_CODE;
	   l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE := price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE;
	   l_price_adj_rec.MODIFIED_FROM := price_adj_rec.MODIFIED_FROM;
	   l_price_adj_rec.MODIFIED_TO := price_adj_rec.MODIFIED_TO;
	   l_price_adj_rec.OPERAND := price_adj_rec.OPERAND;
	   l_price_adj_rec.ARITHMETIC_OPERATOR := price_adj_rec.ARITHMETIC_OPERATOR;
	   l_price_adj_rec.AUTOMATIC_FLAG := price_adj_rec.AUTOMATIC_FLAG;
	   l_price_adj_rec.UPDATE_ALLOWABLE_FLAG := price_adj_rec.UPDATE_ALLOWABLE_FLAG;
	   l_price_adj_rec.UPDATED_FLAG := price_adj_rec.UPDATED_FLAG;
	   l_price_adj_rec.APPLIED_FLAG := price_adj_rec.APPLIED_FLAG;
	   l_price_adj_rec.ON_INVOICE_FLAG := price_adj_rec.ON_INVOICE_FLAG;
	   l_price_adj_rec.PRICING_PHASE_ID := price_adj_rec.PRICING_PHASE_ID;
	   l_price_adj_rec.QUOTE_SHIPMENT_ID := price_adj_rec.QUOTE_SHIPMENT_ID;
	   l_price_adj_rec.ATTRIBUTE_CATEGORY := price_adj_rec.ATTRIBUTE_CATEGORY;
	   l_price_adj_rec.ATTRIBUTE1 := price_adj_rec.ATTRIBUTE1;
	   l_price_adj_rec.ATTRIBUTE2 := price_adj_rec.ATTRIBUTE2;
	   l_price_adj_rec.ATTRIBUTE3 := price_adj_rec.ATTRIBUTE3;
	   l_price_adj_rec.ATTRIBUTE4 := price_adj_rec.ATTRIBUTE4;
	   l_price_adj_rec.ATTRIBUTE5 := price_adj_rec.ATTRIBUTE5;
	   l_price_adj_rec.ATTRIBUTE6 := price_adj_rec.ATTRIBUTE6;
	   l_price_adj_rec.ATTRIBUTE7 := price_adj_rec.ATTRIBUTE7;
	   l_price_adj_rec.ATTRIBUTE8 := price_adj_rec.ATTRIBUTE8;
	   l_price_adj_rec.ATTRIBUTE9 := price_adj_rec.ATTRIBUTE9;
	   l_price_adj_rec.ATTRIBUTE10 := price_adj_rec.ATTRIBUTE10;
	   l_price_adj_rec.ATTRIBUTE11 := price_adj_rec.ATTRIBUTE11;
	   l_price_adj_rec.ATTRIBUTE12 := price_adj_rec.ATTRIBUTE12;
	   l_price_adj_rec.ATTRIBUTE13 := price_adj_rec.ATTRIBUTE13;
	   l_price_adj_rec.ATTRIBUTE14 := price_adj_rec.ATTRIBUTE14;
	   l_price_adj_rec.ATTRIBUTE15 := price_adj_rec.ATTRIBUTE15;
	   l_price_adj_rec.ATTRIBUTE16 := price_adj_rec.ATTRIBUTE16;
	   l_price_adj_rec.ATTRIBUTE17 := price_adj_rec.ATTRIBUTE17;
	   l_price_adj_rec.ATTRIBUTE18 := price_adj_rec.ATTRIBUTE18;
	   l_price_adj_rec.ATTRIBUTE19 := price_adj_rec.ATTRIBUTE19;
	   l_price_adj_rec.ATTRIBUTE20 := price_adj_rec.ATTRIBUTE20;
        l_price_adj_rec.TAX_CODE   := price_adj_rec.TAX_CODE;
	   l_price_adj_rec.TAX_EXEMPT_FLAG := price_adj_rec.TAX_EXEMPT_FLAG;
	   l_price_adj_rec.TAX_EXEMPT_NUMBER := price_adj_rec.TAX_EXEMPT_NUMBER;
	   l_price_adj_rec.TAX_EXEMPT_REASON_CODE := price_adj_rec.TAX_EXEMPT_REASON_CODE;
	   l_price_adj_rec.PARENT_ADJUSTMENT_ID := price_adj_rec.PARENT_ADJUSTMENT_ID;
	   l_price_adj_rec.INVOICED_FLAG := price_adj_rec.INVOICED_FLAG;
	   l_price_adj_rec.ESTIMATED_FLAG := price_adj_rec.ESTIMATED_FLAG;
	   l_price_adj_rec.INC_IN_SALES_PERFORMANCE := price_adj_rec.INC_IN_SALES_PERFORMANCE;
	   l_price_adj_rec.SPLIT_ACTION_CODE := price_adj_rec.SPLIT_ACTION_CODE;
	   l_price_adj_rec.ADJUSTED_AMOUNT := price_adj_rec.ADJUSTED_AMOUNT;
	   l_price_adj_rec.CHARGE_TYPE_CODE := price_adj_rec.CHARGE_TYPE_CODE;
	   l_price_adj_rec.CHARGE_SUBTYPE_CODE := price_adj_rec.CHARGE_SUBTYPE_CODE;
	   l_price_adj_rec.RANGE_BREAK_QUANTITY := price_adj_rec.RANGE_BREAK_QUANTITY;
	   l_price_adj_rec.ACCRUAL_CONVERSION_RATE := price_adj_rec.ACCRUAL_CONVERSION_RATE;
	   l_price_adj_rec.PRICING_GROUP_SEQUENCE := price_adj_rec.PRICING_GROUP_SEQUENCE;
	   l_price_adj_rec.ACCRUAL_FLAG := price_adj_rec.ACCRUAL_FLAG;
	   l_price_adj_rec.LIST_LINE_NO := price_adj_rec.LIST_LINE_NO;
	   l_price_adj_rec.SOURCE_SYSTEM_CODE := price_adj_rec.SOURCE_SYSTEM_CODE;
	   l_price_adj_rec.BENEFIT_QTY := price_adj_rec.BENEFIT_QTY;
	   l_price_adj_rec.BENEFIT_UOM_CODE := price_adj_rec.BENEFIT_UOM_CODE;
	   l_price_adj_rec.PRINT_ON_INVOICE_FLAG := price_adj_rec.PRINT_ON_INVOICE_FLAG;
	   l_price_adj_rec.EXPIRATION_DATE := price_adj_rec.EXPIRATION_DATE;
	   l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE := price_adj_rec.REBATE_TRANSACTION_TYPE_CODE;
	   l_price_adj_rec.REBATE_TRANSACTION_REFERENCE := price_adj_rec.REBATE_TRANSACTION_REFERENCE;
	   l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE := price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE;
	   l_price_adj_rec.REDEEMED_DATE := price_adj_rec.REDEEMED_DATE;
	   l_price_adj_rec.REDEEMED_FLAG := price_adj_rec.REDEEMED_FLAG;
	   l_price_adj_rec.MODIFIER_LEVEL_CODE := price_adj_rec.MODIFIER_LEVEL_CODE;
	   l_price_adj_rec.PRICE_BREAK_TYPE_CODE := price_adj_rec.PRICE_BREAK_TYPE_CODE;
	   l_price_adj_rec.SUBSTITUTION_ATTRIBUTE := price_adj_rec.SUBSTITUTION_ATTRIBUTE;
	   l_price_adj_rec.PRORATION_TYPE_CODE := price_adj_rec.PRORATION_TYPE_CODE;
	   l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG := price_adj_rec.INCLUDE_ON_RETURNS_FLAG;
	   l_price_adj_rec.CREDIT_OR_CHARGE_FLAG := price_adj_rec.CREDIT_OR_CHARGE_FLAG;
	   l_price_adj_rec.ORIG_SYS_DISCOUNT_REF := price_adj_rec.ORIG_SYS_DISCOUNT_REF;
	   l_price_adj_rec.CHANGE_REASON_CODE := price_adj_rec.CHANGE_REASON_CODE;
	   l_price_adj_rec.CHANGE_REASON_TEXT := price_adj_rec.CHANGE_REASON_TEXT;
	   l_price_adj_rec.COST_ID := price_adj_rec.COST_ID;
	   --l_price_adj_rec.LIST_LINE_TYPE_CODE := price_adj_rec.LIST_LINE_TYPE_CODE;
	   l_price_adj_rec.UPDATE_ALLOWED := price_adj_rec.UPDATE_ALLOWED;
	   l_price_adj_rec.CHANGE_SEQUENCE := price_adj_rec.CHANGE_SEQUENCE;
	   l_price_adj_rec.OBJECT_VERSION_NUMBER := price_adj_rec.OBJECT_VERSION_NUMBER;
	   l_price_adj_rec.OPERAND_PER_PQTY := price_adj_rec.OPERAND_PER_PQTY;
	   l_price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY := price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY;

	   l_price_adj_tbl(l_price_adj_tbl.COUNT+1) := l_price_adj_rec;
      END LOOP;

    END IF;
    RETURN l_price_adj_tbl;
END Query_Price_Adj_Rows;

FUNCTION Query_Price_Adj_NonPRG_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Tbl_Type
IS
    CURSOR c_price_adj_hdr IS
	SELECT
        PRICE_ADJUSTMENT_ID,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   REQUEST_ID,
	   QUOTE_HEADER_ID,
	   QUOTE_LINE_ID,
	   MODIFIER_HEADER_ID,
	   MODIFIER_LINE_ID,
	   MODIFIER_LINE_TYPE_CODE,
	   MODIFIER_MECHANISM_TYPE_CODE,
	   MODIFIED_FROM,
        MODIFIED_TO,
	   OPERAND,
	   ARITHMETIC_OPERATOR,
	   AUTOMATIC_FLAG,
	   UPDATE_ALLOWABLE_FLAG,
        UPDATED_FLAG,
	   APPLIED_FLAG,
	   ON_INVOICE_FLAG,
	   PRICING_PHASE_ID,
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
	   TAX_CODE,
	   TAX_EXEMPT_FLAG,
	   TAX_EXEMPT_NUMBER,
	   TAX_EXEMPT_REASON_CODE,
	   PARENT_ADJUSTMENT_ID,
	   INVOICED_FLAG,
	   ESTIMATED_FLAG,
	   INC_IN_SALES_PERFORMANCE,
	   SPLIT_ACTION_CODE,
	   ADJUSTED_AMOUNT,
	   CHARGE_TYPE_CODE,
	   CHARGE_SUBTYPE_CODE,
	   RANGE_BREAK_QUANTITY,
	   ACCRUAL_CONVERSION_RATE,
	   PRICING_GROUP_SEQUENCE,
	   ACCRUAL_FLAG,
	   LIST_LINE_NO,
	   SOURCE_SYSTEM_CODE,
	   BENEFIT_QTY,
	   BENEFIT_UOM_CODE,
	   PRINT_ON_INVOICE_FLAG,
	   EXPIRATION_DATE,
	   REBATE_TRANSACTION_TYPE_CODE,
	   REBATE_TRANSACTION_REFERENCE,
	   REBATE_PAYMENT_SYSTEM_CODE,
	   REDEEMED_DATE,
	   REDEEMED_FLAG,
	   MODIFIER_LEVEL_CODE,
	   PRICE_BREAK_TYPE_CODE,
	   SUBSTITUTION_ATTRIBUTE,
	   PRORATION_TYPE_CODE,
	   INCLUDE_ON_RETURNS_FLAG,
	   CREDIT_OR_CHARGE_FLAG,
	   ORIG_SYS_DISCOUNT_REF,
	   CHANGE_REASON_CODE,
	   CHANGE_REASON_TEXT,
	   COST_ID,
	   LIST_LINE_TYPE_CODE,
	   UPDATE_ALLOWED,
	   CHANGE_SEQUENCE,
	   LIST_HEADER_ID,
	   LIST_LINE_ID,
	   QUOTE_SHIPMENT_ID,
	   OPERAND_PER_PQTY,
	   ADJUSTED_AMOUNT_PER_PQTY,
        OBJECT_VERSION_NUMBER
     FROM ASO_PRICE_ADJUSTMENTS
	WHERE quote_header_id = p_qte_header_id
	     AND quote_line_id IS NULL;

    CURSOR c_price_adj_line IS
	SELECT
        PRICE_ADJUSTMENT_ID,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   REQUEST_ID,
	   QUOTE_HEADER_ID,
	   QUOTE_LINE_ID,
	   MODIFIER_HEADER_ID,
	   MODIFIER_LINE_ID,
	   MODIFIER_LINE_TYPE_CODE,
	   MODIFIER_MECHANISM_TYPE_CODE,
	   MODIFIED_FROM,
        MODIFIED_TO,
	   OPERAND,
	   ARITHMETIC_OPERATOR,
	   AUTOMATIC_FLAG,
	   UPDATE_ALLOWABLE_FLAG,
        UPDATED_FLAG,
	   APPLIED_FLAG,
	   ON_INVOICE_FLAG,
	   PRICING_PHASE_ID,
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
	   TAX_CODE,
	   TAX_EXEMPT_FLAG,
	   TAX_EXEMPT_NUMBER,
	   TAX_EXEMPT_REASON_CODE,
	   PARENT_ADJUSTMENT_ID,
	   INVOICED_FLAG,
	   ESTIMATED_FLAG,
	   INC_IN_SALES_PERFORMANCE,
	   SPLIT_ACTION_CODE,
	   ADJUSTED_AMOUNT,
	   CHARGE_TYPE_CODE,
	   CHARGE_SUBTYPE_CODE,
	   RANGE_BREAK_QUANTITY,
	   ACCRUAL_CONVERSION_RATE,
	   PRICING_GROUP_SEQUENCE,
	   ACCRUAL_FLAG,
	   LIST_LINE_NO,
	   SOURCE_SYSTEM_CODE,
	   BENEFIT_QTY,
	   BENEFIT_UOM_CODE,
	   PRINT_ON_INVOICE_FLAG,
	   EXPIRATION_DATE,
	   REBATE_TRANSACTION_TYPE_CODE,
	   REBATE_TRANSACTION_REFERENCE,
	   REBATE_PAYMENT_SYSTEM_CODE,
	   REDEEMED_DATE,
	   REDEEMED_FLAG,
	   MODIFIER_LEVEL_CODE,
	   PRICE_BREAK_TYPE_CODE,
	   SUBSTITUTION_ATTRIBUTE,
	   PRORATION_TYPE_CODE,
	   INCLUDE_ON_RETURNS_FLAG,
	   CREDIT_OR_CHARGE_FLAG,
	   ORIG_SYS_DISCOUNT_REF,
	   CHANGE_REASON_CODE,
	   CHANGE_REASON_TEXT,
	   COST_ID,
	   LIST_LINE_TYPE_CODE,
	   UPDATE_ALLOWED,
	   CHANGE_SEQUENCE,
	   LIST_HEADER_ID,
	   LIST_LINE_ID,
	   QUOTE_SHIPMENT_ID,
	   OPERAND_PER_PQTY,
	   ADJUSTED_AMOUNT_PER_PQTY,
        OBJECT_VERSION_NUMBER
     FROM ASO_PRICE_ADJUSTMENTS
	WHERE quote_header_id = p_qte_header_id
     AND quote_line_id IS NOT NULL
     AND quote_line_id = p_qte_line_id
	AND modifier_line_type_code <> 'PRG';

    l_price_adj_rec             ASO_QUOTE_PUB.Price_Adj_Rec_Type;
    l_price_adj_tbl             ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
BEGIN
    IF P_Qte_Line_Id is NULL or P_Qte_Line_Id = FND_API.G_MISS_NUM THEN
      FOR price_adj_rec IN c_price_adj_hdr LOOP
	   l_price_adj_rec.PRICE_ADJUSTMENT_ID := price_adj_rec.PRICE_ADJUSTMENT_ID;
	   l_price_adj_rec.CREATION_DATE := price_adj_rec.CREATION_DATE;
	   l_price_adj_rec.CREATED_BY := price_adj_rec.CREATED_BY;
	   l_price_adj_rec.LAST_UPDATE_DATE := price_adj_rec.LAST_UPDATE_DATE;
	   l_price_adj_rec.LAST_UPDATED_BY := price_adj_rec.LAST_UPDATED_BY;
	   l_price_adj_rec.LAST_UPDATE_LOGIN := price_adj_rec.LAST_UPDATE_LOGIN;
	   l_price_adj_rec.REQUEST_ID := price_adj_rec.REQUEST_ID;
	   l_price_adj_rec.PROGRAM_APPLICATION_ID := price_adj_rec.PROGRAM_APPLICATION_ID;
	   l_price_adj_rec.PROGRAM_ID := price_adj_rec.PROGRAM_ID;
	   l_price_adj_rec.PROGRAM_UPDATE_DATE := price_adj_rec.PROGRAM_UPDATE_DATE;
	   l_price_adj_rec.QUOTE_HEADER_ID := price_adj_rec.QUOTE_HEADER_ID;
	   l_price_adj_rec.QUOTE_LINE_ID := price_adj_rec.QUOTE_LINE_ID;
	   l_price_adj_rec.MODIFIER_HEADER_ID := price_adj_rec.MODIFIER_HEADER_ID;
	   l_price_adj_rec.MODIFIER_LINE_ID := price_adj_rec.MODIFIER_LINE_ID;
	   l_price_adj_rec.MODIFIER_LINE_TYPE_CODE := price_adj_rec.MODIFIER_LINE_TYPE_CODE;
	   l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE := price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE;
	   l_price_adj_rec.MODIFIED_FROM := price_adj_rec.MODIFIED_FROM;
	   l_price_adj_rec.MODIFIED_TO := price_adj_rec.MODIFIED_TO;
	   l_price_adj_rec.OPERAND := price_adj_rec.OPERAND;
	   l_price_adj_rec.ARITHMETIC_OPERATOR := price_adj_rec.ARITHMETIC_OPERATOR;
	   l_price_adj_rec.AUTOMATIC_FLAG := price_adj_rec.AUTOMATIC_FLAG;
	   l_price_adj_rec.UPDATE_ALLOWABLE_FLAG := price_adj_rec.UPDATE_ALLOWABLE_FLAG;
	   l_price_adj_rec.UPDATED_FLAG := price_adj_rec.UPDATED_FLAG;
	   l_price_adj_rec.APPLIED_FLAG := price_adj_rec.APPLIED_FLAG;
	   l_price_adj_rec.ON_INVOICE_FLAG := price_adj_rec.ON_INVOICE_FLAG;
	   l_price_adj_rec.PRICING_PHASE_ID := price_adj_rec.PRICING_PHASE_ID;
	   l_price_adj_rec.QUOTE_SHIPMENT_ID := price_adj_rec.QUOTE_SHIPMENT_ID;
	   l_price_adj_rec.ATTRIBUTE_CATEGORY := price_adj_rec.ATTRIBUTE_CATEGORY;
	   l_price_adj_rec.ATTRIBUTE1 := price_adj_rec.ATTRIBUTE1;
	   l_price_adj_rec.ATTRIBUTE2 := price_adj_rec.ATTRIBUTE2;
	   l_price_adj_rec.ATTRIBUTE3 := price_adj_rec.ATTRIBUTE3;
	   l_price_adj_rec.ATTRIBUTE4 := price_adj_rec.ATTRIBUTE4;
	   l_price_adj_rec.ATTRIBUTE5 := price_adj_rec.ATTRIBUTE5;
	   l_price_adj_rec.ATTRIBUTE6 := price_adj_rec.ATTRIBUTE6;
	   l_price_adj_rec.ATTRIBUTE7 := price_adj_rec.ATTRIBUTE7;
	   l_price_adj_rec.ATTRIBUTE8 := price_adj_rec.ATTRIBUTE8;
	   l_price_adj_rec.ATTRIBUTE9 := price_adj_rec.ATTRIBUTE9;
	   l_price_adj_rec.ATTRIBUTE10 := price_adj_rec.ATTRIBUTE10;
	   l_price_adj_rec.ATTRIBUTE11 := price_adj_rec.ATTRIBUTE11;
	   l_price_adj_rec.ATTRIBUTE12 := price_adj_rec.ATTRIBUTE12;
	   l_price_adj_rec.ATTRIBUTE13 := price_adj_rec.ATTRIBUTE13;
	   l_price_adj_rec.ATTRIBUTE14 := price_adj_rec.ATTRIBUTE14;
	   l_price_adj_rec.ATTRIBUTE15 := price_adj_rec.ATTRIBUTE15;
	   l_price_adj_rec.ATTRIBUTE16 := price_adj_rec.ATTRIBUTE16;
	   l_price_adj_rec.ATTRIBUTE17 := price_adj_rec.ATTRIBUTE17;
	   l_price_adj_rec.ATTRIBUTE18 := price_adj_rec.ATTRIBUTE18;
	   l_price_adj_rec.ATTRIBUTE19 := price_adj_rec.ATTRIBUTE19;
	   l_price_adj_rec.ATTRIBUTE20 := price_adj_rec.ATTRIBUTE20;
        l_price_adj_rec.TAX_CODE   := price_adj_rec.TAX_CODE;
	   l_price_adj_rec.TAX_EXEMPT_FLAG := price_adj_rec.TAX_EXEMPT_FLAG;
	   l_price_adj_rec.TAX_EXEMPT_NUMBER := price_adj_rec.TAX_EXEMPT_NUMBER;
	   l_price_adj_rec.TAX_EXEMPT_REASON_CODE := price_adj_rec.TAX_EXEMPT_REASON_CODE;
	   l_price_adj_rec.PARENT_ADJUSTMENT_ID := price_adj_rec.PARENT_ADJUSTMENT_ID;
	   l_price_adj_rec.INVOICED_FLAG := price_adj_rec.INVOICED_FLAG;
	   l_price_adj_rec.ESTIMATED_FLAG := price_adj_rec.ESTIMATED_FLAG;
	   l_price_adj_rec.INC_IN_SALES_PERFORMANCE := price_adj_rec.INC_IN_SALES_PERFORMANCE;
	   l_price_adj_rec.SPLIT_ACTION_CODE := price_adj_rec.SPLIT_ACTION_CODE;
	   l_price_adj_rec.ADJUSTED_AMOUNT := price_adj_rec.ADJUSTED_AMOUNT;
	   l_price_adj_rec.CHARGE_TYPE_CODE := price_adj_rec.CHARGE_TYPE_CODE;
	   l_price_adj_rec.CHARGE_SUBTYPE_CODE := price_adj_rec.CHARGE_SUBTYPE_CODE;
	   l_price_adj_rec.RANGE_BREAK_QUANTITY := price_adj_rec.RANGE_BREAK_QUANTITY;
	   l_price_adj_rec.ACCRUAL_CONVERSION_RATE := price_adj_rec.ACCRUAL_CONVERSION_RATE;
	   l_price_adj_rec.PRICING_GROUP_SEQUENCE := price_adj_rec.PRICING_GROUP_SEQUENCE;
	   l_price_adj_rec.ACCRUAL_FLAG := price_adj_rec.ACCRUAL_FLAG;
	   l_price_adj_rec.LIST_LINE_NO := price_adj_rec.LIST_LINE_NO;
	   l_price_adj_rec.SOURCE_SYSTEM_CODE := price_adj_rec.SOURCE_SYSTEM_CODE;
	   l_price_adj_rec.BENEFIT_QTY := price_adj_rec.BENEFIT_QTY;
	   l_price_adj_rec.BENEFIT_UOM_CODE := price_adj_rec.BENEFIT_UOM_CODE;
	   l_price_adj_rec.PRINT_ON_INVOICE_FLAG := price_adj_rec.PRINT_ON_INVOICE_FLAG;
	   l_price_adj_rec.EXPIRATION_DATE := price_adj_rec.EXPIRATION_DATE;
	   l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE := price_adj_rec.REBATE_TRANSACTION_TYPE_CODE;
	   l_price_adj_rec.REBATE_TRANSACTION_REFERENCE := price_adj_rec.REBATE_TRANSACTION_REFERENCE;
	   l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE := price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE;
	   l_price_adj_rec.REDEEMED_DATE := price_adj_rec.REDEEMED_DATE;
	   l_price_adj_rec.REDEEMED_FLAG := price_adj_rec.REDEEMED_FLAG;
	   l_price_adj_rec.MODIFIER_LEVEL_CODE := price_adj_rec.MODIFIER_LEVEL_CODE;
	   l_price_adj_rec.PRICE_BREAK_TYPE_CODE := price_adj_rec.PRICE_BREAK_TYPE_CODE;
	   l_price_adj_rec.SUBSTITUTION_ATTRIBUTE := price_adj_rec.SUBSTITUTION_ATTRIBUTE;
	   l_price_adj_rec.PRORATION_TYPE_CODE := price_adj_rec.PRORATION_TYPE_CODE;
	   l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG := price_adj_rec.INCLUDE_ON_RETURNS_FLAG;
	   l_price_adj_rec.CREDIT_OR_CHARGE_FLAG := price_adj_rec.CREDIT_OR_CHARGE_FLAG;
	   l_price_adj_rec.ORIG_SYS_DISCOUNT_REF := price_adj_rec.ORIG_SYS_DISCOUNT_REF;
	   l_price_adj_rec.CHANGE_REASON_CODE := price_adj_rec.CHANGE_REASON_CODE;
	   l_price_adj_rec.CHANGE_REASON_TEXT := price_adj_rec.CHANGE_REASON_TEXT;
	   l_price_adj_rec.COST_ID := price_adj_rec.COST_ID;
	   --l_price_adj_rec.LIST_LINE_TYPE_CODE := price_adj_rec.LIST_LINE_TYPE_CODE;
	   l_price_adj_rec.UPDATE_ALLOWED := price_adj_rec.UPDATE_ALLOWED;
	   l_price_adj_rec.CHANGE_SEQUENCE := price_adj_rec.CHANGE_SEQUENCE;
	   l_price_adj_rec.OBJECT_VERSION_NUMBER := price_adj_rec.OBJECT_VERSION_NUMBER;
	   l_price_adj_rec.OPERAND_PER_PQTY := price_adj_rec.OPERAND_PER_PQTY;
	   l_price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY := price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY;

	   l_price_adj_tbl(l_price_adj_tbl.COUNT+1) := l_price_adj_rec;
      END LOOP;
    ELSIF P_Qte_Line_Id is NOT NULL OR P_Qte_Line_Id <> FND_API.G_MISS_NUM THEN
      FOR price_adj_rec IN c_price_adj_line LOOP
	   l_price_adj_rec.PRICE_ADJUSTMENT_ID := price_adj_rec.PRICE_ADJUSTMENT_ID;
	   l_price_adj_rec.CREATION_DATE := price_adj_rec.CREATION_DATE;
	   l_price_adj_rec.CREATED_BY := price_adj_rec.CREATED_BY;
	   l_price_adj_rec.LAST_UPDATE_DATE := price_adj_rec.LAST_UPDATE_DATE;
	   l_price_adj_rec.LAST_UPDATED_BY := price_adj_rec.LAST_UPDATED_BY;
	   l_price_adj_rec.LAST_UPDATE_LOGIN := price_adj_rec.LAST_UPDATE_LOGIN;
	   l_price_adj_rec.REQUEST_ID := price_adj_rec.REQUEST_ID;
	   l_price_adj_rec.PROGRAM_APPLICATION_ID := price_adj_rec.PROGRAM_APPLICATION_ID;
	   l_price_adj_rec.PROGRAM_ID := price_adj_rec.PROGRAM_ID;
	   l_price_adj_rec.PROGRAM_UPDATE_DATE := price_adj_rec.PROGRAM_UPDATE_DATE;
	   l_price_adj_rec.QUOTE_HEADER_ID := price_adj_rec.QUOTE_HEADER_ID;
	   l_price_adj_rec.QUOTE_LINE_ID := price_adj_rec.QUOTE_LINE_ID;
	   l_price_adj_rec.MODIFIER_HEADER_ID := price_adj_rec.MODIFIER_HEADER_ID;
	   l_price_adj_rec.MODIFIER_LINE_ID := price_adj_rec.MODIFIER_LINE_ID;
	   l_price_adj_rec.MODIFIER_LINE_TYPE_CODE := price_adj_rec.MODIFIER_LINE_TYPE_CODE;
	   l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE := price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE;
	   l_price_adj_rec.MODIFIED_FROM := price_adj_rec.MODIFIED_FROM;
	   l_price_adj_rec.MODIFIED_TO := price_adj_rec.MODIFIED_TO;
	   l_price_adj_rec.OPERAND := price_adj_rec.OPERAND;
	   l_price_adj_rec.ARITHMETIC_OPERATOR := price_adj_rec.ARITHMETIC_OPERATOR;
	   l_price_adj_rec.AUTOMATIC_FLAG := price_adj_rec.AUTOMATIC_FLAG;
	   l_price_adj_rec.UPDATE_ALLOWABLE_FLAG := price_adj_rec.UPDATE_ALLOWABLE_FLAG;
	   l_price_adj_rec.UPDATED_FLAG := price_adj_rec.UPDATED_FLAG;
	   l_price_adj_rec.APPLIED_FLAG := price_adj_rec.APPLIED_FLAG;
	   l_price_adj_rec.ON_INVOICE_FLAG := price_adj_rec.ON_INVOICE_FLAG;
	   l_price_adj_rec.PRICING_PHASE_ID := price_adj_rec.PRICING_PHASE_ID;
	   l_price_adj_rec.QUOTE_SHIPMENT_ID := price_adj_rec.QUOTE_SHIPMENT_ID;
	   l_price_adj_rec.ATTRIBUTE_CATEGORY := price_adj_rec.ATTRIBUTE_CATEGORY;
	   l_price_adj_rec.ATTRIBUTE1 := price_adj_rec.ATTRIBUTE1;
	   l_price_adj_rec.ATTRIBUTE2 := price_adj_rec.ATTRIBUTE2;
	   l_price_adj_rec.ATTRIBUTE3 := price_adj_rec.ATTRIBUTE3;
	   l_price_adj_rec.ATTRIBUTE4 := price_adj_rec.ATTRIBUTE4;
	   l_price_adj_rec.ATTRIBUTE5 := price_adj_rec.ATTRIBUTE5;
	   l_price_adj_rec.ATTRIBUTE6 := price_adj_rec.ATTRIBUTE6;
	   l_price_adj_rec.ATTRIBUTE7 := price_adj_rec.ATTRIBUTE7;
	   l_price_adj_rec.ATTRIBUTE8 := price_adj_rec.ATTRIBUTE8;
	   l_price_adj_rec.ATTRIBUTE9 := price_adj_rec.ATTRIBUTE9;
	   l_price_adj_rec.ATTRIBUTE10 := price_adj_rec.ATTRIBUTE10;
	   l_price_adj_rec.ATTRIBUTE11 := price_adj_rec.ATTRIBUTE11;
	   l_price_adj_rec.ATTRIBUTE12 := price_adj_rec.ATTRIBUTE12;
	   l_price_adj_rec.ATTRIBUTE13 := price_adj_rec.ATTRIBUTE13;
	   l_price_adj_rec.ATTRIBUTE14 := price_adj_rec.ATTRIBUTE14;
	   l_price_adj_rec.ATTRIBUTE15 := price_adj_rec.ATTRIBUTE15;
	   l_price_adj_rec.ATTRIBUTE16 := price_adj_rec.ATTRIBUTE16;
	   l_price_adj_rec.ATTRIBUTE17 := price_adj_rec.ATTRIBUTE17;
	   l_price_adj_rec.ATTRIBUTE18 := price_adj_rec.ATTRIBUTE18;
	   l_price_adj_rec.ATTRIBUTE19 := price_adj_rec.ATTRIBUTE19;
	   l_price_adj_rec.ATTRIBUTE20 := price_adj_rec.ATTRIBUTE20;
        l_price_adj_rec.TAX_CODE   := price_adj_rec.TAX_CODE;
	   l_price_adj_rec.TAX_EXEMPT_FLAG := price_adj_rec.TAX_EXEMPT_FLAG;
	   l_price_adj_rec.TAX_EXEMPT_NUMBER := price_adj_rec.TAX_EXEMPT_NUMBER;
	   l_price_adj_rec.TAX_EXEMPT_REASON_CODE := price_adj_rec.TAX_EXEMPT_REASON_CODE;
	   l_price_adj_rec.PARENT_ADJUSTMENT_ID := price_adj_rec.PARENT_ADJUSTMENT_ID;
	   l_price_adj_rec.INVOICED_FLAG := price_adj_rec.INVOICED_FLAG;
	   l_price_adj_rec.ESTIMATED_FLAG := price_adj_rec.ESTIMATED_FLAG;
	   l_price_adj_rec.INC_IN_SALES_PERFORMANCE := price_adj_rec.INC_IN_SALES_PERFORMANCE;
	   l_price_adj_rec.SPLIT_ACTION_CODE := price_adj_rec.SPLIT_ACTION_CODE;
	   l_price_adj_rec.ADJUSTED_AMOUNT := price_adj_rec.ADJUSTED_AMOUNT;
	   l_price_adj_rec.CHARGE_TYPE_CODE := price_adj_rec.CHARGE_TYPE_CODE;
	   l_price_adj_rec.CHARGE_SUBTYPE_CODE := price_adj_rec.CHARGE_SUBTYPE_CODE;
	   l_price_adj_rec.RANGE_BREAK_QUANTITY := price_adj_rec.RANGE_BREAK_QUANTITY;
	   l_price_adj_rec.ACCRUAL_CONVERSION_RATE := price_adj_rec.ACCRUAL_CONVERSION_RATE;
	   l_price_adj_rec.PRICING_GROUP_SEQUENCE := price_adj_rec.PRICING_GROUP_SEQUENCE;
	   l_price_adj_rec.ACCRUAL_FLAG := price_adj_rec.ACCRUAL_FLAG;
	   l_price_adj_rec.LIST_LINE_NO := price_adj_rec.LIST_LINE_NO;
	   l_price_adj_rec.SOURCE_SYSTEM_CODE := price_adj_rec.SOURCE_SYSTEM_CODE;
	   l_price_adj_rec.BENEFIT_QTY := price_adj_rec.BENEFIT_QTY;
	   l_price_adj_rec.BENEFIT_UOM_CODE := price_adj_rec.BENEFIT_UOM_CODE;
	   l_price_adj_rec.PRINT_ON_INVOICE_FLAG := price_adj_rec.PRINT_ON_INVOICE_FLAG;
	   l_price_adj_rec.EXPIRATION_DATE := price_adj_rec.EXPIRATION_DATE;
	   l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE := price_adj_rec.REBATE_TRANSACTION_TYPE_CODE;
	   l_price_adj_rec.REBATE_TRANSACTION_REFERENCE := price_adj_rec.REBATE_TRANSACTION_REFERENCE;
	   l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE := price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE;
	   l_price_adj_rec.REDEEMED_DATE := price_adj_rec.REDEEMED_DATE;
	   l_price_adj_rec.REDEEMED_FLAG := price_adj_rec.REDEEMED_FLAG;
	   l_price_adj_rec.MODIFIER_LEVEL_CODE := price_adj_rec.MODIFIER_LEVEL_CODE;
	   l_price_adj_rec.PRICE_BREAK_TYPE_CODE := price_adj_rec.PRICE_BREAK_TYPE_CODE;
	   l_price_adj_rec.SUBSTITUTION_ATTRIBUTE := price_adj_rec.SUBSTITUTION_ATTRIBUTE;
	   l_price_adj_rec.PRORATION_TYPE_CODE := price_adj_rec.PRORATION_TYPE_CODE;
	   l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG := price_adj_rec.INCLUDE_ON_RETURNS_FLAG;
	   l_price_adj_rec.CREDIT_OR_CHARGE_FLAG := price_adj_rec.CREDIT_OR_CHARGE_FLAG;
	   l_price_adj_rec.ORIG_SYS_DISCOUNT_REF := price_adj_rec.ORIG_SYS_DISCOUNT_REF;
	   l_price_adj_rec.CHANGE_REASON_CODE := price_adj_rec.CHANGE_REASON_CODE;
	   l_price_adj_rec.CHANGE_REASON_TEXT := price_adj_rec.CHANGE_REASON_TEXT;
	   l_price_adj_rec.COST_ID := price_adj_rec.COST_ID;
	   --l_price_adj_rec.LIST_LINE_TYPE_CODE := price_adj_rec.LIST_LINE_TYPE_CODE;
	   l_price_adj_rec.UPDATE_ALLOWED := price_adj_rec.UPDATE_ALLOWED;
	   l_price_adj_rec.CHANGE_SEQUENCE := price_adj_rec.CHANGE_SEQUENCE;
	   l_price_adj_rec.OBJECT_VERSION_NUMBER := price_adj_rec.OBJECT_VERSION_NUMBER;
	   l_price_adj_rec.OPERAND_PER_PQTY := price_adj_rec.OPERAND_PER_PQTY;
	   l_price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY := price_adj_rec.ADJUSTED_AMOUNT_PER_PQTY;

	   l_price_adj_tbl(l_price_adj_tbl.COUNT+1) := l_price_adj_rec;
      END LOOP;

    END IF;
    RETURN l_price_adj_tbl;
END Query_Price_Adj_NonPRG_Rows;

/************Commenting it out for performance fix*****************************************************
FUNCTION Query_Price_Adj_NonPRG_Rows (
    P_Qte_Header_Id      IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id        IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Tbl_Type
IS
    CURSOR c_price_adj IS
     SELECT
     PRICE_ADJUSTMENT_ID,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     REQUEST_ID,
     QUOTE_HEADER_ID,
     QUOTE_LINE_ID,
     MODIFIER_HEADER_ID,
     MODIFIER_LINE_ID,
     MODIFIER_LINE_TYPE_CODE,
     MODIFIER_MECHANISM_TYPE_CODE,
     MODIFIED_FROM,
     MODIFIED_TO,
     OPERAND,
     ARITHMETIC_OPERATOR,
     AUTOMATIC_FLAG,
     UPDATE_ALLOWABLE_FLAG,
     UPDATED_FLAG,
     APPLIED_FLAG,
     ON_INVOICE_FLAG,
     PRICING_PHASE_ID,
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
     TAX_CODE,
     TAX_EXEMPT_FLAG,
     TAX_EXEMPT_NUMBER,
     TAX_EXEMPT_REASON_CODE,
     PARENT_ADJUSTMENT_ID,
     INVOICED_FLAG,
     ESTIMATED_FLAG,
     INC_IN_SALES_PERFORMANCE,
     SPLIT_ACTION_CODE,
     ADJUSTED_AMOUNT,
     CHARGE_TYPE_CODE,
     CHARGE_SUBTYPE_CODE,
     RANGE_BREAK_QUANTITY,
     ACCRUAL_CONVERSION_RATE,
     PRICING_GROUP_SEQUENCE,
     ACCRUAL_FLAG,
     LIST_LINE_NO,
     SOURCE_SYSTEM_CODE,
     BENEFIT_QTY,
     BENEFIT_UOM_CODE,
     PRINT_ON_INVOICE_FLAG,
     EXPIRATION_DATE,
     REBATE_TRANSACTION_TYPE_CODE,
     REBATE_TRANSACTION_REFERENCE,
     REBATE_PAYMENT_SYSTEM_CODE,
     REDEEMED_DATE,
     REDEEMED_FLAG,
     MODIFIER_LEVEL_CODE,
     PRICE_BREAK_TYPE_CODE,
     SUBSTITUTION_ATTRIBUTE,
     PRORATION_TYPE_CODE,
     INCLUDE_ON_RETURNS_FLAG,
     CREDIT_OR_CHARGE_FLAG,
     ORIG_SYS_DISCOUNT_REF,
     CHANGE_REASON_CODE,
     CHANGE_REASON_TEXT,
     COST_ID,
     LIST_LINE_TYPE_CODE,
     UPDATE_ALLOWED,
     CHANGE_SEQUENCE,
     LIST_HEADER_ID,
     LIST_LINE_ID,
     QUOTE_SHIPMENT_ID,
     OBJECT_VERSION_NUMBER
     FROM ASO_PRICE_ADJUSTMENTS
     WHERE quote_header_id = p_qte_header_id AND
         (quote_line_id = p_qte_line_id OR
          (quote_line_id IS NULL AND p_qte_line_id IS NULL))
         AND modifier_line_type_code <> 'PRG';

    l_price_adj_rec             ASO_QUOTE_PUB.Price_Adj_Rec_Type;
    l_price_adj_tbl             ASO_QUOTE_PUB.Price_Adj_Tbl_Type;

BEGIN
      FOR price_adj_rec IN c_price_adj LOOP
       l_price_adj_rec.PRICE_ADJUSTMENT_ID := price_adj_rec.PRICE_ADJUSTMENT_ID;
        l_price_adj_rec.CREATION_DATE := price_adj_rec.CREATION_DATE;
        l_price_adj_rec.CREATED_BY := price_adj_rec.CREATED_BY;
        l_price_adj_rec.LAST_UPDATE_DATE := price_adj_rec.LAST_UPDATE_DATE;
        l_price_adj_rec.LAST_UPDATED_BY := price_adj_rec.LAST_UPDATED_BY;
        l_price_adj_rec.LAST_UPDATE_LOGIN := price_adj_rec.LAST_UPDATE_LOGIN;
        l_price_adj_rec.REQUEST_ID := price_adj_rec.REQUEST_ID;
        l_price_adj_rec.PROGRAM_APPLICATION_ID := price_adj_rec.PROGRAM_APPLICATION_ID;
        l_price_adj_rec.PROGRAM_ID := price_adj_rec.PROGRAM_ID;
        l_price_adj_rec.PROGRAM_UPDATE_DATE := price_adj_rec.PROGRAM_UPDATE_DATE;
       l_price_adj_rec.QUOTE_HEADER_ID := price_adj_rec.QUOTE_HEADER_ID;
       l_price_adj_rec.QUOTE_LINE_ID := price_adj_rec.QUOTE_LINE_ID;
       l_price_adj_rec.MODIFIER_HEADER_ID := price_adj_rec.MODIFIER_HEADER_ID;
       l_price_adj_rec.MODIFIER_LINE_ID := price_adj_rec.MODIFIER_LINE_ID;
       l_price_adj_rec.MODIFIER_LINE_TYPE_CODE := price_adj_rec.MODIFIER_LINE_TYPE_CODE;
       l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE
                         := price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE;
       l_price_adj_rec.MODIFIED_FROM := price_adj_rec.MODIFIED_FROM;
       l_price_adj_rec.MODIFIED_TO := price_adj_rec.MODIFIED_TO;
       l_price_adj_rec.OPERAND := price_adj_rec.OPERAND;
       l_price_adj_rec.ARITHMETIC_OPERATOR := price_adj_rec.ARITHMETIC_OPERATOR;
       l_price_adj_rec.AUTOMATIC_FLAG := price_adj_rec.AUTOMATIC_FLAG;
       l_price_adj_rec.UPDATE_ALLOWABLE_FLAG := price_adj_rec.UPDATE_ALLOWABLE_FLAG;
       l_price_adj_rec.UPDATED_FLAG := price_adj_rec.UPDATED_FLAG;
       l_price_adj_rec.APPLIED_FLAG := price_adj_rec.APPLIED_FLAG;
       l_price_adj_rec.ON_INVOICE_FLAG := price_adj_rec.ON_INVOICE_FLAG;
       l_price_adj_rec.PRICING_PHASE_ID := price_adj_rec.PRICING_PHASE_ID;
       l_price_adj_rec.QUOTE_SHIPMENT_ID := price_adj_rec.QUOTE_SHIPMENT_ID;
       l_price_adj_rec.ATTRIBUTE_CATEGORY := price_adj_rec.ATTRIBUTE_CATEGORY;
       l_price_adj_rec.ATTRIBUTE1 := price_adj_rec.ATTRIBUTE1;
       l_price_adj_rec.ATTRIBUTE2 := price_adj_rec.ATTRIBUTE2;
       l_price_adj_rec.ATTRIBUTE3 := price_adj_rec.ATTRIBUTE3;
       l_price_adj_rec.ATTRIBUTE4 := price_adj_rec.ATTRIBUTE4;
       l_price_adj_rec.ATTRIBUTE5 := price_adj_rec.ATTRIBUTE5;
       l_price_adj_rec.ATTRIBUTE6 := price_adj_rec.ATTRIBUTE6;
       l_price_adj_rec.ATTRIBUTE7 := price_adj_rec.ATTRIBUTE7;
       l_price_adj_rec.ATTRIBUTE8 := price_adj_rec.ATTRIBUTE8;
       l_price_adj_rec.ATTRIBUTE9 := price_adj_rec.ATTRIBUTE9;
       l_price_adj_rec.ATTRIBUTE10 := price_adj_rec.ATTRIBUTE10;
       l_price_adj_rec.ATTRIBUTE11 := price_adj_rec.ATTRIBUTE11;
       l_price_adj_rec.ATTRIBUTE12 := price_adj_rec.ATTRIBUTE12;
       l_price_adj_rec.ATTRIBUTE13 := price_adj_rec.ATTRIBUTE13;
       l_price_adj_rec.ATTRIBUTE14 := price_adj_rec.ATTRIBUTE14;
       l_price_adj_rec.ATTRIBUTE15 := price_adj_rec.ATTRIBUTE15;
       l_price_adj_rec.ATTRIBUTE16 := price_adj_rec.ATTRIBUTE16;
       l_price_adj_rec.ATTRIBUTE17 := price_adj_rec.ATTRIBUTE17;
       l_price_adj_rec.ATTRIBUTE18 := price_adj_rec.ATTRIBUTE18;
       l_price_adj_rec.ATTRIBUTE19 := price_adj_rec.ATTRIBUTE19;
       l_price_adj_rec.ATTRIBUTE20 := price_adj_rec.ATTRIBUTE20;
          l_price_adj_rec.TAX_CODE   := price_adj_rec.TAX_CODE;
     l_price_adj_rec.TAX_EXEMPT_FLAG := price_adj_rec.TAX_EXEMPT_FLAG;
     l_price_adj_rec.TAX_EXEMPT_NUMBER := price_adj_rec.TAX_EXEMPT_NUMBER;
     l_price_adj_rec.TAX_EXEMPT_REASON_CODE := price_adj_rec.TAX_EXEMPT_REASON_CODE;
     l_price_adj_rec.PARENT_ADJUSTMENT_ID := price_adj_rec.PARENT_ADJUSTMENT_ID;
     l_price_adj_rec.INVOICED_FLAG := price_adj_rec.INVOICED_FLAG;
     l_price_adj_rec.ESTIMATED_FLAG := price_adj_rec.ESTIMATED_FLAG;
     l_price_adj_rec.INC_IN_SALES_PERFORMANCE := price_adj_rec.INC_IN_SALES_PERFORMANCE;
     l_price_adj_rec.SPLIT_ACTION_CODE := price_adj_rec.SPLIT_ACTION_CODE;
     l_price_adj_rec.ADJUSTED_AMOUNT := price_adj_rec.ADJUSTED_AMOUNT;
     l_price_adj_rec.CHARGE_TYPE_CODE := price_adj_rec.CHARGE_TYPE_CODE;
     l_price_adj_rec.CHARGE_SUBTYPE_CODE := price_adj_rec.CHARGE_SUBTYPE_CODE;
     l_price_adj_rec.RANGE_BREAK_QUANTITY := price_adj_rec.RANGE_BREAK_QUANTITY;
     l_price_adj_rec.ACCRUAL_CONVERSION_RATE := price_adj_rec.ACCRUAL_CONVERSION_RATE;
     l_price_adj_rec.PRICING_GROUP_SEQUENCE := price_adj_rec.PRICING_GROUP_SEQUENCE;
     l_price_adj_rec.ACCRUAL_FLAG := price_adj_rec.ACCRUAL_FLAG;
     l_price_adj_rec.LIST_LINE_NO := price_adj_rec.LIST_LINE_NO;
     l_price_adj_rec.SOURCE_SYSTEM_CODE := price_adj_rec.SOURCE_SYSTEM_CODE;
     l_price_adj_rec.BENEFIT_QTY := price_adj_rec.BENEFIT_QTY;
     l_price_adj_rec.BENEFIT_UOM_CODE := price_adj_rec.BENEFIT_UOM_CODE;
     l_price_adj_rec.PRINT_ON_INVOICE_FLAG := price_adj_rec.PRINT_ON_INVOICE_FLAG;
     l_price_adj_rec.EXPIRATION_DATE := price_adj_rec.EXPIRATION_DATE;
     l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE := price_adj_rec.REBATE_TRANSACTION_TYPE_CODE;
     l_price_adj_rec.REBATE_TRANSACTION_REFERENCE := price_adj_rec.REBATE_TRANSACTION_REFERENCE;
     l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE := price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE;
     l_price_adj_rec.REDEEMED_DATE := price_adj_rec.REDEEMED_DATE;
     l_price_adj_rec.REDEEMED_FLAG := price_adj_rec.REDEEMED_FLAG;
     l_price_adj_rec.MODIFIER_LEVEL_CODE := price_adj_rec.MODIFIER_LEVEL_CODE;
     l_price_adj_rec.PRICE_BREAK_TYPE_CODE := price_adj_rec.PRICE_BREAK_TYPE_CODE;
     l_price_adj_rec.SUBSTITUTION_ATTRIBUTE := price_adj_rec.SUBSTITUTION_ATTRIBUTE;
     l_price_adj_rec.PRORATION_TYPE_CODE := price_adj_rec.PRORATION_TYPE_CODE;
     l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG := price_adj_rec.INCLUDE_ON_RETURNS_FLAG;
     l_price_adj_rec.CREDIT_OR_CHARGE_FLAG := price_adj_rec.CREDIT_OR_CHARGE_FLAG;
     l_price_adj_rec.ORIG_SYS_DISCOUNT_REF := price_adj_rec.ORIG_SYS_DISCOUNT_REF;
     l_price_adj_rec.CHANGE_REASON_CODE := price_adj_rec.CHANGE_REASON_CODE;
     l_price_adj_rec.CHANGE_REASON_TEXT := price_adj_rec.CHANGE_REASON_TEXT;
     l_price_adj_rec.COST_ID := price_adj_rec.COST_ID;
     l_price_adj_rec.UPDATE_ALLOWED := price_adj_rec.UPDATE_ALLOWED;
     l_price_adj_rec.CHANGE_SEQUENCE := price_adj_rec.CHANGE_SEQUENCE;
     l_price_adj_rec.OBJECT_VERSION_NUMBER := price_adj_rec.OBJECT_VERSION_NUMBER;
       l_price_adj_tbl(l_price_adj_tbl.COUNT+1) := l_price_adj_rec;
      END LOOP;
      RETURN l_price_adj_tbl;
END Query_Price_Adj_NonPRG_Rows;
************************************************************************************************************/


FUNCTION Query_Price_Adj_Attr_Rows (
    p_price_adj_tbl		IN  ASO_QUOTE_PUB.Price_Adj_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
IS
    CURSOR c_price_adj_attr (c_price_adj_id NUMBER) IS
	SELECT
        PRICE_ADJ_ATTRIB_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	REQUEST_ID,
	PRICE_ADJUSTMENT_ID,
	PRICING_CONTEXT,
	PRICING_ATTRIBUTE,
	PRICING_ATTR_VALUE_FROM,
	PRICING_ATTR_VALUE_TO,
	COMPARISON_OPERATOR,
	FLEX_TITLE,
     OBJECT_VERSION_NUMBER
 	FROM ASO_PRICE_ADJ_ATTRIBS
	WHERE PRICE_ADJUSTMENT_ID = c_price_adj_id;
    l_Price_Adj_Attr_rec	ASO_QUOTE_PUB.Price_Adj_Attr_rec_Type;
    l_Price_Adj_Attr_Tbl	ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
BEGIN
   FOR i IN 1..P_price_adj_tbl.count LOOP
      FOR price_adj_attr_rec IN c_price_adj_attr(P_price_adj_tbl(i).PRICE_ADJUSTMENT_ID) LOOP
	  l_price_adj_attr_rec.PRICE_ADJ_ATTRIB_ID :=
						price_adj_attr_rec.PRICE_ADJ_ATTRIB_ID;
	  l_price_adj_attr_rec.price_adj_index := i;
	  l_price_adj_attr_rec.CREATION_DATE := price_adj_attr_rec.CREATION_DATE;
	   l_price_adj_attr_rec.CREATED_BY := price_adj_attr_rec.CREATED_BY;
	   l_price_adj_attr_rec.LAST_UPDATE_DATE := price_adj_attr_rec.LAST_UPDATE_DATE;
	   l_price_adj_attr_rec.LAST_UPDATED_BY := price_adj_attr_rec.LAST_UPDATED_BY;
	   l_price_adj_attr_rec.LAST_UPDATE_LOGIN := price_adj_attr_rec.LAST_UPDATE_LOGIN;
	   l_price_adj_attr_rec.REQUEST_ID := price_adj_attr_rec.REQUEST_ID;
	   l_price_adj_attr_rec.PROGRAM_APPLICATION_ID := price_adj_attr_rec.PROGRAM_APPLICATION_ID;
	   l_price_adj_attr_rec.PROGRAM_ID := price_adj_attr_rec.PROGRAM_ID;
	   l_price_adj_attr_rec.PROGRAM_UPDATE_DATE := price_adj_attr_rec.PROGRAM_UPDATE_DATE;
	  l_price_adj_attr_rec.PRICE_ADJUSTMENT_ID := price_adj_attr_rec.PRICE_ADJUSTMENT_ID;
	  l_price_adj_attr_rec.PRICING_CONTEXT := price_adj_attr_rec.PRICING_CONTEXT;
	  l_price_adj_attr_rec.PRICING_ATTRIBUTE := price_adj_attr_rec.PRICING_ATTRIBUTE;
	  l_price_adj_attr_rec.PRICING_ATTR_VALUE_FROM := price_adj_attr_rec.PRICING_ATTR_VALUE_FROM;
	  l_price_adj_attr_rec.PRICING_ATTR_VALUE_TO := price_adj_attr_rec.PRICING_ATTR_VALUE_TO;
	  l_price_adj_attr_rec.COMPARISON_OPERATOR := price_adj_attr_rec.COMPARISON_OPERATOR;
	  l_price_adj_attr_rec.FLEX_TITLE := price_adj_attr_rec.FLEX_TITLE;
	  l_price_adj_attr_rec.OBJECT_VERSION_NUMBER := price_adj_attr_rec.OBJECT_VERSION_NUMBER;

	  l_price_adj_attr_tbl(l_price_adj_attr_tbl.COUNT+1) := l_price_adj_attr_rec;
      END LOOP;
   END LOOP;
   RETURN l_price_adj_attr_tbl;
END  Query_Price_Adj_Attr_Rows;

FUNCTION Query_Payment_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Payment_Tbl_Type
IS
    CURSOR c_payment IS
	SELECT
	PAYMENT_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	QUOTE_HEADER_ID,
	QUOTE_LINE_ID,
	PAYMENT_TYPE_CODE,
	PAYMENT_REF_NUMBER,
	PAYMENT_OPTION,
	PAYMENT_TERM_ID,
	CREDIT_CARD_CODE,
	CREDIT_CARD_HOLDER_NAME,
	CREDIT_CARD_EXPIRATION_DATE,
	CREDIT_CARD_APPROVAL_CODE,
	CREDIT_CARD_APPROVAL_DATE,
	PAYMENT_AMOUNT,
	QUOTE_SHIPMENT_ID,
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
	CUST_PO_NUMBER,
     CUST_PO_LINE_NUMBER,
     OBJECT_VERSION_NUMBER,
	TRXN_EXTENSION_ID,
	PAYMENT_TERM_ID_FROM
 	FROM ASO_PAYMENTS
	WHERE quote_header_id = p_qte_header_id AND
	   (quote_line_id = p_qte_line_id OR
		(quote_line_id IS NULL AND p_qte_line_id IS NULL));
    l_payment_rec             ASO_QUOTE_PUB.Payment_Rec_Type;
    l_payment_tbl             ASO_QUOTE_PUB.Payment_Tbl_Type;
BEGIN
      FOR payment_rec IN c_payment LOOP
	   l_payment_rec.PAYMENT_ID := payment_rec.PAYMENT_ID;
	   l_payment_rec.CREATION_DATE := payment_rec.CREATION_DATE;
	   l_payment_rec.CREATED_BY := payment_rec.CREATED_BY;
	   l_payment_rec.LAST_UPDATE_DATE := payment_rec.LAST_UPDATE_DATE;
	   l_payment_rec.LAST_UPDATED_BY := payment_rec.LAST_UPDATED_BY;
	   l_payment_rec.LAST_UPDATE_LOGIN := payment_rec.LAST_UPDATE_LOGIN;
	   l_payment_rec.REQUEST_ID := payment_rec.REQUEST_ID;
	   l_payment_rec.PROGRAM_APPLICATION_ID := payment_rec.PROGRAM_APPLICATION_ID;
	   l_payment_rec.PROGRAM_ID := payment_rec.PROGRAM_ID;
	   l_payment_rec.PROGRAM_UPDATE_DATE := payment_rec.PROGRAM_UPDATE_DATE;
	  l_payment_rec.QUOTE_HEADER_ID := payment_rec.QUOTE_HEADER_ID;
	  l_payment_rec.QUOTE_LINE_ID := payment_rec.QUOTE_LINE_ID;
	  l_payment_rec.PAYMENT_TYPE_CODE := payment_rec.PAYMENT_TYPE_CODE;
--      l_payment_rec.PAYMENT_AMOUNT := payment_rec.PAYMENT_AMOUNT;
      l_payment_rec.PAYMENT_REF_NUMBER := payment_rec.PAYMENT_REF_NUMBER;
	  l_payment_rec.PAYMENT_OPTION := payment_rec.PAYMENT_OPTION;
	  l_payment_rec.PAYMENT_TERM_ID := payment_rec.PAYMENT_TERM_ID;
	  l_payment_rec.CREDIT_CARD_CODE := payment_rec.CREDIT_CARD_CODE;
	  l_payment_rec.CREDIT_CARD_HOLDER_NAME := payment_rec.CREDIT_CARD_HOLDER_NAME;
	  l_payment_rec.CREDIT_CARD_EXPIRATION_DATE :=
					payment_rec.CREDIT_CARD_EXPIRATION_DATE;
	  l_payment_rec.CREDIT_CARD_APPROVAL_CODE :=
					payment_rec.CREDIT_CARD_APPROVAL_CODE;
	  l_payment_rec.CREDIT_CARD_APPROVAL_DATE :=
					payment_rec.CREDIT_CARD_APPROVAL_DATE;
	  l_payment_rec.PAYMENT_AMOUNT := payment_rec.PAYMENT_AMOUNT;
	  l_payment_rec.QUOTE_SHIPMENT_ID := payment_rec.QUOTE_SHIPMENT_ID;
	  l_payment_rec.ATTRIBUTE_CATEGORY := payment_rec.ATTRIBUTE_CATEGORY;
	  l_payment_rec.ATTRIBUTE1 := payment_rec.ATTRIBUTE1;
	  l_payment_rec.ATTRIBUTE2 := payment_rec.ATTRIBUTE2;
	  l_payment_rec.ATTRIBUTE3 := payment_rec.ATTRIBUTE3;
	  l_payment_rec.ATTRIBUTE4 := payment_rec.ATTRIBUTE4;
	  l_payment_rec.ATTRIBUTE5 := payment_rec.ATTRIBUTE5;
	  l_payment_rec.ATTRIBUTE6 := payment_rec.ATTRIBUTE6;
	  l_payment_rec.ATTRIBUTE7 := payment_rec.ATTRIBUTE7;
	  l_payment_rec.ATTRIBUTE8 := payment_rec.ATTRIBUTE8;
	  l_payment_rec.ATTRIBUTE9 := payment_rec.ATTRIBUTE9;
	  l_payment_rec.ATTRIBUTE10 := payment_rec.ATTRIBUTE10;
	  l_payment_rec.ATTRIBUTE11 := payment_rec.ATTRIBUTE11;
	  l_payment_rec.ATTRIBUTE12 := payment_rec.ATTRIBUTE12;
	  l_payment_rec.ATTRIBUTE13 := payment_rec.ATTRIBUTE13;
	  l_payment_rec.ATTRIBUTE14 := payment_rec.ATTRIBUTE14;
	  l_payment_rec.ATTRIBUTE15 := payment_rec.ATTRIBUTE15;
	  l_payment_rec.ATTRIBUTE16 := payment_rec.ATTRIBUTE16;
	  l_payment_rec.ATTRIBUTE17 := payment_rec.ATTRIBUTE17;
	  l_payment_rec.ATTRIBUTE18 := payment_rec.ATTRIBUTE18;
	  l_payment_rec.ATTRIBUTE19 := payment_rec.ATTRIBUTE19;
	  l_payment_rec.ATTRIBUTE20 := payment_rec.ATTRIBUTE20;
	  l_payment_rec.CUST_PO_NUMBER := payment_rec.CUST_PO_NUMBER;
	  l_payment_rec.CUST_PO_LINE_NUMBER := payment_rec.CUST_PO_LINE_NUMBER; --Line Payments Change
	  l_payment_rec.OBJECT_VERSION_NUMBER := payment_rec.OBJECT_VERSION_NUMBER;
       l_payment_rec.TRXN_EXTENSION_ID := payment_rec.TRXN_EXTENSION_ID;
       l_payment_rec.PAYMENT_TERM_ID_FROM := payment_rec.PAYMENT_TERM_ID_FROM;
       l_payment_tbl(l_payment_tbl.COUNT+1) := l_payment_rec;
	 END LOOP;
      RETURN l_payment_tbl;
END Query_Payment_Rows;

--Added with TAX_RATE_ID column added by Anoop Rajan on 30/08/2005 as part of eTAX

FUNCTION Query_Tax_Detail_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Shipment_Tbl		IN  ASO_QUOTE_PUB.Shipment_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
IS
    CURSOR c_tax1 IS
	SELECT
	TAX_DETAIL_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	QUOTE_HEADER_ID,
	QUOTE_LINE_ID,
	QUOTE_SHIPMENT_ID,
	ORIG_TAX_CODE,
	TAX_CODE,
	TAX_RATE,
	TAX_DATE,
	TAX_AMOUNT,
	TAX_EXEMPT_FLAG,
	TAX_EXEMPT_NUMBER,
	TAX_EXEMPT_REASON_CODE,
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
	TAX_INCLUSIVE_FLAG,
     OBJECT_VERSION_NUMBER,
     TAX_RATE_ID,
     TAX_CLASSIFICATION_CODE  -- rassharm gsi
  FROM ASO_TAX_DETAILS
  WHERE quote_header_id = p_qte_header_id
  AND quote_line_id IS NULL ;

    CURSOR c_tax2(c_shipment_id NUMBER) IS
	SELECT
        TAX_DETAIL_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	QUOTE_HEADER_ID,
	QUOTE_LINE_ID,
	QUOTE_SHIPMENT_ID,
	ORIG_TAX_CODE,
	TAX_CODE,
	TAX_RATE,
	TAX_DATE,
	TAX_AMOUNT,
	TAX_EXEMPT_FLAG,
	TAX_EXEMPT_NUMBER,
	TAX_EXEMPT_REASON_CODE,
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
     TAX_INCLUSIVE_FLAG,
     OBJECT_VERSION_NUMBER,
     TAX_RATE_ID,
     TAX_CLASSIFICATION_CODE -- rassharm gsi
     FROM ASO_TAX_DETAILS
     WHERE quote_shipment_id = c_shipment_id
	and quote_header_id = p_qte_header_id
	and quote_line_id IS NOT NULL
	AND quote_line_id = p_qte_line_id;

    l_tax_detail_rec             ASO_QUOTE_PUB.Tax_Detail_Rec_Type;
    l_tax_detail_tbl             ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
BEGIN
   IF P_Qte_Line_Id is NULL or P_Qte_Line_Id = FND_API.G_MISS_NUM THEN

      FOR tax_rec IN c_tax1 LOOP
	   l_tax_detail_rec.TAX_DETAIL_ID := tax_rec.TAX_DETAIL_ID;
	   l_tax_detail_rec.CREATION_DATE := tax_rec.CREATION_DATE;
	   l_tax_detail_rec.CREATED_BY := tax_rec.CREATED_BY;
	   l_tax_detail_rec.LAST_UPDATE_DATE := tax_rec.LAST_UPDATE_DATE;
	   l_tax_detail_rec.LAST_UPDATED_BY := tax_rec.LAST_UPDATED_BY;
	   l_tax_detail_rec.LAST_UPDATE_LOGIN := tax_rec.LAST_UPDATE_LOGIN;
	   l_tax_detail_rec.REQUEST_ID := tax_rec.REQUEST_ID;
	   l_tax_detail_rec.PROGRAM_APPLICATION_ID := tax_rec.PROGRAM_APPLICATION_ID;
	   l_tax_detail_rec.PROGRAM_ID := tax_rec.PROGRAM_ID;
	   l_tax_detail_rec.PROGRAM_UPDATE_DATE := tax_rec.PROGRAM_UPDATE_DATE;
	  l_tax_detail_rec.QUOTE_HEADER_ID := tax_rec.QUOTE_HEADER_ID;
	  l_tax_detail_rec.QUOTE_LINE_ID := tax_rec.QUOTE_LINE_ID;
	  l_tax_detail_rec.QUOTE_SHIPMENT_ID := tax_rec.QUOTE_SHIPMENT_ID;
	  l_tax_detail_rec.ORIG_TAX_CODE := tax_rec.ORIG_TAX_CODE;
	  l_tax_detail_rec.TAX_CODE := tax_rec.TAX_CODE;
	  l_tax_detail_rec.TAX_RATE := tax_rec.TAX_RATE;
	  l_tax_detail_rec.TAX_DATE := tax_rec.TAX_DATE;
	  l_tax_detail_rec.TAX_AMOUNT := tax_rec.TAX_AMOUNT;
	  l_tax_detail_rec.TAX_EXEMPT_FLAG := tax_rec.TAX_EXEMPT_FLAG;
	  l_tax_detail_rec.TAX_EXEMPT_NUMBER := tax_rec.TAX_EXEMPT_NUMBER;
	  l_tax_detail_rec.TAX_EXEMPT_REASON_CODE := tax_rec.TAX_EXEMPT_REASON_CODE;
	  l_tax_detail_rec.ATTRIBUTE_CATEGORY := tax_rec.ATTRIBUTE_CATEGORY;
	  l_tax_detail_rec.ATTRIBUTE1 := tax_rec.ATTRIBUTE1;
	  l_tax_detail_rec.ATTRIBUTE2 := tax_rec.ATTRIBUTE2;
	  l_tax_detail_rec.ATTRIBUTE3 := tax_rec.ATTRIBUTE3;
	  l_tax_detail_rec.ATTRIBUTE4 := tax_rec.ATTRIBUTE4;
	  l_tax_detail_rec.ATTRIBUTE5 := tax_rec.ATTRIBUTE5;
	  l_tax_detail_rec.ATTRIBUTE6 := tax_rec.ATTRIBUTE6;
	  l_tax_detail_rec.ATTRIBUTE7 := tax_rec.ATTRIBUTE7;
	  l_tax_detail_rec.ATTRIBUTE8 := tax_rec.ATTRIBUTE8;
	  l_tax_detail_rec.ATTRIBUTE9 := tax_rec.ATTRIBUTE9;
	  l_tax_detail_rec.ATTRIBUTE10 := tax_rec.ATTRIBUTE10;
	  l_tax_detail_rec.ATTRIBUTE11 := tax_rec.ATTRIBUTE11;
	  l_tax_detail_rec.ATTRIBUTE12 := tax_rec.ATTRIBUTE12;
	  l_tax_detail_rec.ATTRIBUTE13 := tax_rec.ATTRIBUTE13;
	  l_tax_detail_rec.ATTRIBUTE14 := tax_rec.ATTRIBUTE14;
	  l_tax_detail_rec.ATTRIBUTE15 := tax_rec.ATTRIBUTE15;
	  l_tax_detail_rec.ATTRIBUTE16 := tax_rec.ATTRIBUTE16;
	  l_tax_detail_rec.ATTRIBUTE17 := tax_rec.ATTRIBUTE17;
	  l_tax_detail_rec.ATTRIBUTE18 := tax_rec.ATTRIBUTE18;
	  l_tax_detail_rec.ATTRIBUTE19 := tax_rec.ATTRIBUTE19;
	  l_tax_detail_rec.ATTRIBUTE20 := tax_rec.ATTRIBUTE20;
	  l_tax_detail_rec.TAX_INCLUSIVE_FLAG := tax_rec.TAX_INCLUSIVE_FLAG;
	  l_tax_detail_rec.OBJECT_VERSION_NUMBER := tax_rec.OBJECT_VERSION_NUMBER;
	  l_tax_detail_rec.TAX_RATE_ID := tax_rec.TAX_RATE_ID;
	  l_tax_detail_rec.TAX_CLASSIFICATION_CODE:=tax_rec.TAX_CLASSIFICATION_CODE; -- rassharm gsi
	  l_tax_detail_tbl(l_tax_detail_tbl.COUNT+1) := l_tax_detail_rec;
      END LOOP;
	 ELSIF P_Qte_Line_Id is NOT NULL OR P_Qte_Line_Id <> FND_API.G_MISS_NUM THEN
       FOR i IN 1..P_shipment_tbl.count LOOP
	  FOR tax_rec IN c_tax2(p_shipment_tbl(i).shipment_id) LOOP
	   l_tax_detail_rec.TAX_DETAIL_ID := tax_rec.TAX_DETAIL_ID;
	    l_tax_detail_rec.shipment_index := i;
	   l_tax_detail_rec.CREATION_DATE := tax_rec.CREATION_DATE;
	   l_tax_detail_rec.CREATED_BY := tax_rec.CREATED_BY;
	   l_tax_detail_rec.LAST_UPDATE_DATE := tax_rec.LAST_UPDATE_DATE;
	   l_tax_detail_rec.LAST_UPDATED_BY := tax_rec.LAST_UPDATED_BY;
	   l_tax_detail_rec.LAST_UPDATE_LOGIN := tax_rec.LAST_UPDATE_LOGIN;
	   l_tax_detail_rec.REQUEST_ID := tax_rec.REQUEST_ID;
	   l_tax_detail_rec.PROGRAM_APPLICATION_ID := tax_rec.PROGRAM_APPLICATION_ID;
	   l_tax_detail_rec.PROGRAM_ID := tax_rec.PROGRAM_ID;
	   l_tax_detail_rec.PROGRAM_UPDATE_DATE := tax_rec.PROGRAM_UPDATE_DATE;
	     l_tax_detail_rec.QUOTE_HEADER_ID := tax_rec.QUOTE_HEADER_ID;
	     l_tax_detail_rec.QUOTE_LINE_ID := tax_rec.QUOTE_LINE_ID;
	     l_tax_detail_rec.QUOTE_SHIPMENT_ID := tax_rec.QUOTE_SHIPMENT_ID;
	     l_tax_detail_rec.ORIG_TAX_CODE := tax_rec.ORIG_TAX_CODE;
	     l_tax_detail_rec.TAX_CODE := tax_rec.TAX_CODE;
	     l_tax_detail_rec.TAX_RATE := tax_rec.TAX_RATE;
	     l_tax_detail_rec.TAX_DATE := tax_rec.TAX_DATE;
	     l_tax_detail_rec.TAX_AMOUNT := tax_rec.TAX_AMOUNT;
	     l_tax_detail_rec.TAX_EXEMPT_FLAG := tax_rec.TAX_EXEMPT_FLAG;
	     l_tax_detail_rec.TAX_EXEMPT_NUMBER := tax_rec.TAX_EXEMPT_NUMBER;
	     l_tax_detail_rec.TAX_EXEMPT_REASON_CODE := tax_rec.TAX_EXEMPT_REASON_CODE;
	     l_tax_detail_rec.ATTRIBUTE_CATEGORY := tax_rec.ATTRIBUTE_CATEGORY;
	     l_tax_detail_rec.ATTRIBUTE1 := tax_rec.ATTRIBUTE1;
	     l_tax_detail_rec.ATTRIBUTE2 := tax_rec.ATTRIBUTE2;
	     l_tax_detail_rec.ATTRIBUTE3 := tax_rec.ATTRIBUTE3;
	     l_tax_detail_rec.ATTRIBUTE4 := tax_rec.ATTRIBUTE4;
	     l_tax_detail_rec.ATTRIBUTE5 := tax_rec.ATTRIBUTE5;
	     l_tax_detail_rec.ATTRIBUTE6 := tax_rec.ATTRIBUTE6;
	     l_tax_detail_rec.ATTRIBUTE7 := tax_rec.ATTRIBUTE7;
	     l_tax_detail_rec.ATTRIBUTE8 := tax_rec.ATTRIBUTE8;
	     l_tax_detail_rec.ATTRIBUTE9 := tax_rec.ATTRIBUTE9;
	     l_tax_detail_rec.ATTRIBUTE10 := tax_rec.ATTRIBUTE10;
	     l_tax_detail_rec.ATTRIBUTE11 := tax_rec.ATTRIBUTE11;
	     l_tax_detail_rec.ATTRIBUTE12 := tax_rec.ATTRIBUTE12;
	     l_tax_detail_rec.ATTRIBUTE13 := tax_rec.ATTRIBUTE13;
	     l_tax_detail_rec.ATTRIBUTE14 := tax_rec.ATTRIBUTE14;
	     l_tax_detail_rec.ATTRIBUTE15 := tax_rec.ATTRIBUTE15;
	     l_tax_detail_rec.ATTRIBUTE16 := tax_rec.ATTRIBUTE16;
	     l_tax_detail_rec.ATTRIBUTE17 := tax_rec.ATTRIBUTE17;
	     l_tax_detail_rec.ATTRIBUTE18 := tax_rec.ATTRIBUTE18;
	     l_tax_detail_rec.ATTRIBUTE19 := tax_rec.ATTRIBUTE19;
	     l_tax_detail_rec.ATTRIBUTE20 := tax_rec.ATTRIBUTE20;
	     l_tax_detail_rec.TAX_INCLUSIVE_FLAG := tax_rec.TAX_INCLUSIVE_FLAG;
	     l_tax_detail_rec.OBJECT_VERSION_NUMBER := tax_rec.OBJECT_VERSION_NUMBER;
	     l_tax_detail_rec.TAX_RATE_ID := tax_rec.TAX_RATE_ID;
	     l_tax_detail_rec.TAX_CLASSIFICATION_CODE:=tax_rec.TAX_CLASSIFICATION_CODE; -- rassharm GSI
	     l_tax_detail_tbl(l_tax_detail_tbl.COUNT+1) := l_tax_detail_rec;
          END LOOP;
      END LOOP;
	 END IF;
      RETURN l_tax_detail_tbl;
END Query_Tax_Detail_Rows;

FUNCTION  Query_shipment_Row (
    P_shipment_Id		 IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.shipment_rec_Type
IS
    l_shipment_rec	ASO_QUOTE_PUB.shipment_rec_Type;
BEGIN
	Select
	   SHIPMENT_ID,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   QUOTE_HEADER_ID,
	   QUOTE_LINE_ID,
	   PROMISE_DATE,
	   REQUEST_DATE,
	   SCHEDULE_SHIP_DATE,
	   SHIP_TO_PARTY_SITE_ID,
	   SHIP_TO_PARTY_ID,
           SHIP_TO_CUST_ACCOUNT_ID,
	   SHIP_PARTIAL_FLAG,
	   SHIP_SET_ID,
	   SHIP_METHOD_CODE,
	   FREIGHT_TERMS_CODE,
	   FREIGHT_CARRIER_CODE,
	   FOB_CODE,
	   SHIPPING_INSTRUCTIONS,
	   PACKING_INSTRUCTIONS,
	   QUANTITY,
	   RESERVED_QUANTITY,
	   RESERVATION_ID,
	   ORDER_LINE_ID,
	   SHIP_QUOTE_PRICE,
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
		 SHIPMENT_PRIORITY_CODE,
		 SHIP_TO_CUST_PARTY_ID,
           REQUEST_DATE_TYPE,
           DEMAND_CLASS_CODE,
           OBJECT_VERSION_NUMBER,
		 SHIP_METHOD_CODE_FROM,
		 FREIGHT_TERMS_CODE_FROM
	INTO
	   l_shipment_rec.SHIPMENT_ID,
	   l_shipment_rec.CREATION_DATE,
	   l_shipment_rec.CREATED_BY,
	   l_shipment_rec.LAST_UPDATE_DATE,
	   l_shipment_rec.LAST_UPDATED_BY,
	   l_shipment_rec.LAST_UPDATE_LOGIN,
	   l_shipment_rec.REQUEST_ID,
	   l_shipment_rec.PROGRAM_APPLICATION_ID,
	   l_shipment_rec.PROGRAM_ID,
	   l_shipment_rec.PROGRAM_UPDATE_DATE,
	   l_shipment_rec.QUOTE_HEADER_ID,
	   l_shipment_rec.QUOTE_LINE_ID,
	   l_shipment_rec.PROMISE_DATE,
	   l_shipment_rec.REQUEST_DATE,
	   l_shipment_rec.SCHEDULE_SHIP_DATE,
	   l_shipment_rec.SHIP_TO_PARTY_SITE_ID,
	   l_shipment_rec.SHIP_TO_PARTY_ID,
           l_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID,
	   l_shipment_rec.SHIP_PARTIAL_FLAG,
	   l_shipment_rec.SHIP_SET_ID,
	   l_shipment_rec.SHIP_METHOD_CODE,
	   l_shipment_rec.FREIGHT_TERMS_CODE,
	   l_shipment_rec.FREIGHT_CARRIER_CODE,
	   l_shipment_rec.FOB_CODE,
	   l_shipment_rec.SHIPPING_INSTRUCTIONS,
	   l_shipment_rec.PACKING_INSTRUCTIONS,
	   l_shipment_rec.QUANTITY,
	   l_shipment_rec.RESERVED_QUANTITY,
	   l_shipment_rec.RESERVATION_ID,
	   l_shipment_rec.ORDER_LINE_ID,
	   l_shipment_rec.SHIP_QUOTE_PRICE,
           l_shipment_rec.ATTRIBUTE_CATEGORY,
           l_shipment_rec.ATTRIBUTE1,
           l_shipment_rec.ATTRIBUTE2,
           l_shipment_rec.ATTRIBUTE3,
           l_shipment_rec.ATTRIBUTE4,
           l_shipment_rec.ATTRIBUTE5,
           l_shipment_rec.ATTRIBUTE6,
           l_shipment_rec.ATTRIBUTE7,
           l_shipment_rec.ATTRIBUTE8,
           l_shipment_rec.ATTRIBUTE9,
           l_shipment_rec.ATTRIBUTE10,
           l_shipment_rec.ATTRIBUTE11,
           l_shipment_rec.ATTRIBUTE12,
           l_shipment_rec.ATTRIBUTE13,
           l_shipment_rec.ATTRIBUTE14,
           l_shipment_rec.ATTRIBUTE15,
           l_shipment_rec.ATTRIBUTE16,
           l_shipment_rec.ATTRIBUTE17,
           l_shipment_rec.ATTRIBUTE18,
           l_shipment_rec.ATTRIBUTE19,
           l_shipment_rec.ATTRIBUTE20,
		 l_shipment_rec.SHIPMENT_PRIORITY_CODE,
		 l_shipment_rec.SHIP_TO_CUST_PARTY_ID,
		 l_shipment_rec.REQUEST_DATE_TYPE,
		 l_shipment_rec.DEMAND_CLASS_CODE,
		 l_shipment_rec.OBJECT_VERSION_NUMBER,
		 l_shipment_rec.SHIP_METHOD_CODE_FROM,
		 l_shipment_rec.FREIGHT_TERMS_CODE_FROM
	FROM ASO_SHIPMENTS
	WHERE shipment_id = p_shipment_id;
    RETURN l_shipment_rec;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_IN_QUERY');
	    FND_MSG_PUB.ADD;
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Shipment_Row;

FUNCTION Query_Shipment_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Shipment_Tbl_Type
IS
    CURSOR c_shipment_hdr IS
	SELECT
        SHIPMENT_ID,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   QUOTE_HEADER_ID,
	   QUOTE_LINE_ID,
	   PROMISE_DATE,
	   REQUEST_DATE,
	   SCHEDULE_SHIP_DATE,
	   SHIP_TO_PARTY_SITE_ID,
	   SHIP_TO_PARTY_ID,
        SHIP_TO_CUST_ACCOUNT_ID,
	   SHIP_PARTIAL_FLAG,
	   SHIP_SET_ID,
	   SHIP_METHOD_CODE,
	   FREIGHT_TERMS_CODE,
	   FREIGHT_CARRIER_CODE,
	   FOB_CODE,
	   SHIPPING_INSTRUCTIONS,
	   PACKING_INSTRUCTIONS,
	   QUANTITY,
	   RESERVED_QUANTITY,
	   RESERVATION_ID,
	   ORDER_LINE_ID,
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
        SHIPMENT_PRIORITY_CODE,
        SHIP_QUOTE_PRICE,
        SHIP_FROM_ORG_ID,
  	   SHIP_TO_CUST_PARTY_ID,
        REQUEST_DATE_TYPE,
        DEMAND_CLASS_CODE,
        OBJECT_VERSION_NUMBER,
        SHIP_METHOD_CODE_FROM,
        FREIGHT_TERMS_CODE_FROM
     FROM ASO_SHIPMENTS
	WHERE quote_header_id = p_qte_header_id
	     AND quote_line_id IS NULL;

    CURSOR c_shipment_line IS
	SELECT
        SHIPMENT_ID,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   QUOTE_HEADER_ID,
	   QUOTE_LINE_ID,
	   PROMISE_DATE,
	   REQUEST_DATE,
	   SCHEDULE_SHIP_DATE,
	   SHIP_TO_PARTY_SITE_ID,
	   SHIP_TO_PARTY_ID,
        SHIP_TO_CUST_ACCOUNT_ID,
	   SHIP_PARTIAL_FLAG,
	   SHIP_SET_ID,
	   SHIP_METHOD_CODE,
	   FREIGHT_TERMS_CODE,
	   FREIGHT_CARRIER_CODE,
	   FOB_CODE,
	   SHIPPING_INSTRUCTIONS,
	   PACKING_INSTRUCTIONS,
	   QUANTITY,
	   RESERVED_QUANTITY,
	   RESERVATION_ID,
	   ORDER_LINE_ID,
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
        SHIPMENT_PRIORITY_CODE,
        SHIP_QUOTE_PRICE,
        SHIP_FROM_ORG_ID,
  	   SHIP_TO_CUST_PARTY_ID,
        REQUEST_DATE_TYPE,
        DEMAND_CLASS_CODE,
        OBJECT_VERSION_NUMBER,
        SHIP_METHOD_CODE_FROM,
        FREIGHT_TERMS_CODE_FROM

     FROM ASO_SHIPMENTS
	WHERE quote_header_id = p_qte_header_id
	AND quote_line_id IS NOT NULL
	AND quote_line_id = p_qte_line_id;

    l_shipment_rec             ASO_QUOTE_PUB.Shipment_Rec_Type;
    l_shipment_tbl             ASO_QUOTE_PUB.Shipment_Tbl_Type;
BEGIN
   IF P_Qte_Line_Id is NULL or P_Qte_Line_Id = FND_API.G_MISS_NUM THEN
      FOR shipment_rec IN c_shipment_hdr LOOP
	   l_shipment_rec.SHIPMENT_ID := shipment_rec.SHIPMENT_ID;
	   l_shipment_rec.CREATION_DATE := shipment_rec.CREATION_DATE;
	   l_shipment_rec.CREATED_BY := shipment_rec.CREATED_BY;
	   l_shipment_rec.LAST_UPDATE_DATE := shipment_rec.LAST_UPDATE_DATE;
	   l_shipment_rec.LAST_UPDATED_BY := shipment_rec.LAST_UPDATED_BY;
	   l_shipment_rec.LAST_UPDATE_LOGIN := shipment_rec.LAST_UPDATE_LOGIN;
	   l_shipment_rec.REQUEST_ID := shipment_rec.REQUEST_ID;
	   l_shipment_rec.PROGRAM_APPLICATION_ID := shipment_rec.PROGRAM_APPLICATION_ID;
	   l_shipment_rec.PROGRAM_ID := shipment_rec.PROGRAM_ID;
	   l_shipment_rec.PROGRAM_UPDATE_DATE := shipment_rec.PROGRAM_UPDATE_DATE;
	   l_shipment_rec.QUOTE_HEADER_ID := shipment_rec.QUOTE_HEADER_ID;
	   l_shipment_rec.QUOTE_LINE_ID := shipment_rec.QUOTE_LINE_ID;
	   l_shipment_rec.PROMISE_DATE := shipment_rec.PROMISE_DATE;
	   l_shipment_rec.REQUEST_DATE := shipment_rec.REQUEST_DATE;
	   l_shipment_rec.SCHEDULE_SHIP_DATE := shipment_rec.SCHEDULE_SHIP_DATE;
	   l_shipment_rec.SHIP_TO_PARTY_SITE_ID := shipment_rec.SHIP_TO_PARTY_SITE_ID;
	   l_shipment_rec.SHIP_TO_PARTY_ID := shipment_rec.SHIP_TO_PARTY_ID;
        l_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID := shipment_rec.SHIP_TO_CUST_ACCOUNT_ID;
	   l_shipment_rec.SHIP_PARTIAL_FLAG := shipment_rec.SHIP_PARTIAL_FLAG;
	   l_shipment_rec.SHIP_SET_ID := shipment_rec.SHIP_SET_ID;
	   l_shipment_rec.SHIP_METHOD_CODE := shipment_rec.SHIP_METHOD_CODE;
	   l_shipment_rec.FREIGHT_TERMS_CODE := shipment_rec.FREIGHT_TERMS_CODE;
	   l_shipment_rec.FREIGHT_CARRIER_CODE := shipment_rec.FREIGHT_CARRIER_CODE;
	   l_shipment_rec.FOB_CODE := shipment_rec.FOB_CODE;
	   l_shipment_rec.SHIPPING_INSTRUCTIONS := shipment_rec.SHIPPING_INSTRUCTIONS;
	   l_shipment_rec.PACKING_INSTRUCTIONS := shipment_rec.PACKING_INSTRUCTIONS;
	   l_shipment_rec.QUANTITY := shipment_rec.QUANTITY;
	   l_shipment_rec.RESERVED_QUANTITY := shipment_rec.RESERVED_QUANTITY;
	   l_shipment_rec.RESERVATION_ID := shipment_rec.RESERVATION_ID;
	   l_shipment_rec.ORDER_LINE_ID := shipment_rec.ORDER_LINE_ID;
	   l_shipment_rec.ATTRIBUTE_CATEGORY := shipment_rec.ATTRIBUTE_CATEGORY;
	   l_shipment_rec.ATTRIBUTE1 := shipment_rec.ATTRIBUTE1;
	   l_shipment_rec.ATTRIBUTE2 := shipment_rec.ATTRIBUTE2;
	   l_shipment_rec.ATTRIBUTE3 := shipment_rec.ATTRIBUTE3;
	   l_shipment_rec.ATTRIBUTE4 := shipment_rec.ATTRIBUTE4;
	   l_shipment_rec.ATTRIBUTE5 := shipment_rec.ATTRIBUTE5;
	   l_shipment_rec.ATTRIBUTE6 := shipment_rec.ATTRIBUTE6;
	   l_shipment_rec.ATTRIBUTE7 := shipment_rec.ATTRIBUTE7;
	   l_shipment_rec.ATTRIBUTE8 := shipment_rec.ATTRIBUTE8;
	   l_shipment_rec.ATTRIBUTE9 := shipment_rec.ATTRIBUTE9;
	   l_shipment_rec.ATTRIBUTE10 := shipment_rec.ATTRIBUTE10;
	   l_shipment_rec.ATTRIBUTE11 := shipment_rec.ATTRIBUTE11;
	   l_shipment_rec.ATTRIBUTE12 := shipment_rec.ATTRIBUTE12;
	   l_shipment_rec.ATTRIBUTE13 := shipment_rec.ATTRIBUTE13;
	   l_shipment_rec.ATTRIBUTE14 := shipment_rec.ATTRIBUTE14;
	   l_shipment_rec.ATTRIBUTE15 := shipment_rec.ATTRIBUTE15;
	   l_shipment_rec.ATTRIBUTE16 := shipment_rec.ATTRIBUTE16;
	   l_shipment_rec.ATTRIBUTE17 := shipment_rec.ATTRIBUTE17;
	   l_shipment_rec.ATTRIBUTE18 := shipment_rec.ATTRIBUTE18;
	   l_shipment_rec.ATTRIBUTE19 := shipment_rec.ATTRIBUTE19;
	   l_shipment_rec.ATTRIBUTE20 := shipment_rec.ATTRIBUTE20;
	   l_shipment_rec.SHIPMENT_PRIORITY_CODE := shipment_rec.SHIPMENT_PRIORITY_CODE;
	   l_shipment_rec.SHIP_QUOTE_PRICE := shipment_rec.SHIP_QUOTE_PRICE;
        l_shipment_rec.SHIP_FROM_ORG_ID := shipment_rec.SHIP_FROM_ORG_ID;
        l_shipment_rec.SHIP_TO_CUST_PARTY_ID := shipment_rec.SHIP_TO_CUST_PARTY_ID;
        l_shipment_rec.REQUEST_DATE_TYPE := shipment_rec.REQUEST_DATE_TYPE;
        l_shipment_rec.DEMAND_CLASS_CODE := shipment_rec.DEMAND_CLASS_CODE;
        l_shipment_rec.OBJECT_VERSION_NUMBER := shipment_rec.OBJECT_VERSION_NUMBER;
        l_shipment_rec.SHIP_METHOD_CODE_FROM := shipment_rec.SHIP_METHOD_CODE_FROM;
        l_shipment_rec.FREIGHT_TERMS_CODE_FROM := shipment_rec.FREIGHT_TERMS_CODE_FROM;
	   l_shipment_tbl(l_shipment_tbl.COUNT+1) := l_shipment_rec;
      END LOOP;
    ELSIF (P_Qte_Line_Id is NOT NULL and P_Qte_Line_Id <> FND_API.G_MISS_NUM) THEN
      FOR shipment_rec IN c_shipment_line  LOOP
	   l_shipment_rec.SHIPMENT_ID := shipment_rec.SHIPMENT_ID;
	   l_shipment_rec.CREATION_DATE := shipment_rec.CREATION_DATE;
	   l_shipment_rec.CREATED_BY := shipment_rec.CREATED_BY;
	   l_shipment_rec.LAST_UPDATE_DATE := shipment_rec.LAST_UPDATE_DATE;
	   l_shipment_rec.LAST_UPDATED_BY := shipment_rec.LAST_UPDATED_BY;
	   l_shipment_rec.LAST_UPDATE_LOGIN := shipment_rec.LAST_UPDATE_LOGIN;
	   l_shipment_rec.REQUEST_ID := shipment_rec.REQUEST_ID;
	   l_shipment_rec.PROGRAM_APPLICATION_ID := shipment_rec.PROGRAM_APPLICATION_ID;
	   l_shipment_rec.PROGRAM_ID := shipment_rec.PROGRAM_ID;
	   l_shipment_rec.PROGRAM_UPDATE_DATE := shipment_rec.PROGRAM_UPDATE_DATE;
	   l_shipment_rec.QUOTE_HEADER_ID := shipment_rec.QUOTE_HEADER_ID;
	   l_shipment_rec.QUOTE_LINE_ID := shipment_rec.QUOTE_LINE_ID;
	   l_shipment_rec.PROMISE_DATE := shipment_rec.PROMISE_DATE;
	   l_shipment_rec.REQUEST_DATE := shipment_rec.REQUEST_DATE;
	   l_shipment_rec.SCHEDULE_SHIP_DATE := shipment_rec.SCHEDULE_SHIP_DATE;
	   l_shipment_rec.SHIP_TO_PARTY_SITE_ID := shipment_rec.SHIP_TO_PARTY_SITE_ID;
	   l_shipment_rec.SHIP_TO_PARTY_ID := shipment_rec.SHIP_TO_PARTY_ID;
        l_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID := shipment_rec.SHIP_TO_CUST_ACCOUNT_ID;
	   l_shipment_rec.SHIP_PARTIAL_FLAG := shipment_rec.SHIP_PARTIAL_FLAG;
	   l_shipment_rec.SHIP_SET_ID := shipment_rec.SHIP_SET_ID;
	   l_shipment_rec.SHIP_METHOD_CODE := shipment_rec.SHIP_METHOD_CODE;
	   l_shipment_rec.FREIGHT_TERMS_CODE := shipment_rec.FREIGHT_TERMS_CODE;
	   l_shipment_rec.FREIGHT_CARRIER_CODE := shipment_rec.FREIGHT_CARRIER_CODE;
	   l_shipment_rec.FOB_CODE := shipment_rec.FOB_CODE;
	   l_shipment_rec.SHIPPING_INSTRUCTIONS := shipment_rec.SHIPPING_INSTRUCTIONS;
	   l_shipment_rec.PACKING_INSTRUCTIONS := shipment_rec.PACKING_INSTRUCTIONS;
	   l_shipment_rec.QUANTITY := shipment_rec.QUANTITY;
	   l_shipment_rec.RESERVED_QUANTITY := shipment_rec.RESERVED_QUANTITY;
	   l_shipment_rec.RESERVATION_ID := shipment_rec.RESERVATION_ID;
	   l_shipment_rec.ORDER_LINE_ID := shipment_rec.ORDER_LINE_ID;
	   l_shipment_rec.ATTRIBUTE_CATEGORY := shipment_rec.ATTRIBUTE_CATEGORY;
	   l_shipment_rec.ATTRIBUTE1 := shipment_rec.ATTRIBUTE1;
	   l_shipment_rec.ATTRIBUTE2 := shipment_rec.ATTRIBUTE2;
	   l_shipment_rec.ATTRIBUTE3 := shipment_rec.ATTRIBUTE3;
	   l_shipment_rec.ATTRIBUTE4 := shipment_rec.ATTRIBUTE4;
	   l_shipment_rec.ATTRIBUTE5 := shipment_rec.ATTRIBUTE5;
	   l_shipment_rec.ATTRIBUTE6 := shipment_rec.ATTRIBUTE6;
	   l_shipment_rec.ATTRIBUTE7 := shipment_rec.ATTRIBUTE7;
	   l_shipment_rec.ATTRIBUTE8 := shipment_rec.ATTRIBUTE8;
	   l_shipment_rec.ATTRIBUTE9 := shipment_rec.ATTRIBUTE9;
	   l_shipment_rec.ATTRIBUTE10 := shipment_rec.ATTRIBUTE10;
	   l_shipment_rec.ATTRIBUTE11 := shipment_rec.ATTRIBUTE11;
	   l_shipment_rec.ATTRIBUTE12 := shipment_rec.ATTRIBUTE12;
	   l_shipment_rec.ATTRIBUTE13 := shipment_rec.ATTRIBUTE13;
	   l_shipment_rec.ATTRIBUTE14 := shipment_rec.ATTRIBUTE14;
	   l_shipment_rec.ATTRIBUTE15 := shipment_rec.ATTRIBUTE15;
	   l_shipment_rec.ATTRIBUTE16 := shipment_rec.ATTRIBUTE16;
	   l_shipment_rec.ATTRIBUTE17 := shipment_rec.ATTRIBUTE17;
	   l_shipment_rec.ATTRIBUTE18 := shipment_rec.ATTRIBUTE18;
	   l_shipment_rec.ATTRIBUTE19 := shipment_rec.ATTRIBUTE19;
	   l_shipment_rec.ATTRIBUTE20 := shipment_rec.ATTRIBUTE20;
	   l_shipment_rec.SHIPMENT_PRIORITY_CODE := shipment_rec.SHIPMENT_PRIORITY_CODE;
	   l_shipment_rec.SHIP_QUOTE_PRICE := shipment_rec.SHIP_QUOTE_PRICE;
        l_shipment_rec.SHIP_FROM_ORG_ID := shipment_rec.SHIP_FROM_ORG_ID;
        l_shipment_rec.SHIP_TO_CUST_PARTY_ID := shipment_rec.SHIP_TO_CUST_PARTY_ID;
        l_shipment_rec.REQUEST_DATE_TYPE := shipment_rec.REQUEST_DATE_TYPE;
        l_shipment_rec.DEMAND_CLASS_CODE := shipment_rec.DEMAND_CLASS_CODE;
        l_shipment_rec.OBJECT_VERSION_NUMBER := shipment_rec.OBJECT_VERSION_NUMBER;
        l_shipment_rec.SHIP_METHOD_CODE_FROM := shipment_rec.SHIP_METHOD_CODE_FROM;
        l_shipment_rec.FREIGHT_TERMS_CODE_FROM := shipment_rec.FREIGHT_TERMS_CODE_FROM;
        l_shipment_tbl(l_shipment_tbl.COUNT+1) := l_shipment_rec;
      END LOOP;
    END IF;

    RETURN l_shipment_tbl;
END Query_Shipment_Rows;

FUNCTION Query_Line_Shipment_Row_atp (
    P_Qte_Header_Id		IN  NUMBER,
    P_Qte_Line_Id        IN  NUMBER
    ) RETURN ASO_QUOTE_PUB.Shipment_Rec_Type
IS
    CURSOR c_shipment IS
	SELECT
           SHIPMENT_ID,
	   CREATION_DATE,
	   CREATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   QUOTE_HEADER_ID,
	   QUOTE_LINE_ID,
	   PROMISE_DATE,
	   REQUEST_DATE,
	   SCHEDULE_SHIP_DATE,
	   SHIP_TO_PARTY_SITE_ID,
	   SHIP_TO_PARTY_ID,
           SHIP_TO_CUST_ACCOUNT_ID,
	   SHIP_PARTIAL_FLAG,
	   SHIP_SET_ID,
	   SHIP_METHOD_CODE,
	   FREIGHT_TERMS_CODE,
	   FREIGHT_CARRIER_CODE,
	   FOB_CODE,
	   SHIPPING_INSTRUCTIONS,
	   PACKING_INSTRUCTIONS,
	   QUANTITY,
	   RESERVED_QUANTITY,
	   RESERVATION_ID,
	   ORDER_LINE_ID,
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
           SHIPMENT_PRIORITY_CODE,
           SHIP_QUOTE_PRICE,
           SHIP_FROM_ORG_ID,
		 SHIP_TO_CUST_PARTY_ID,
           REQUEST_DATE_TYPE,
           DEMAND_CLASS_CODE,
           OBJECT_VERSION_NUMBER,
           SHIP_METHOD_CODE_FROM,
           FREIGHT_TERMS_CODE_FROM

        FROM ASO_SHIPMENTS
	WHERE quote_header_id = p_qte_header_id
	AND   quote_line_id = p_qte_line_id;

    l_shipment_rec             ASO_QUOTE_PUB.Shipment_Rec_Type;
BEGIN

      FOR shipment_rec IN c_shipment LOOP

	  l_shipment_rec.SHIPMENT_ID := shipment_rec.SHIPMENT_ID;
	   l_shipment_rec.CREATION_DATE := shipment_rec.CREATION_DATE;
	   l_shipment_rec.CREATED_BY := shipment_rec.CREATED_BY;
	   l_shipment_rec.LAST_UPDATE_DATE := shipment_rec.LAST_UPDATE_DATE;
	   l_shipment_rec.LAST_UPDATED_BY := shipment_rec.LAST_UPDATED_BY;
	   l_shipment_rec.LAST_UPDATE_LOGIN := shipment_rec.LAST_UPDATE_LOGIN;
	   l_shipment_rec.REQUEST_ID := shipment_rec.REQUEST_ID;
	   l_shipment_rec.PROGRAM_APPLICATION_ID := shipment_rec.PROGRAM_APPLICATION_ID;
	   l_shipment_rec.PROGRAM_ID := shipment_rec.PROGRAM_ID;
	   l_shipment_rec.PROGRAM_UPDATE_DATE := shipment_rec.PROGRAM_UPDATE_DATE;
	  l_shipment_rec.QUOTE_HEADER_ID := shipment_rec.QUOTE_HEADER_ID;
	  l_shipment_rec.QUOTE_LINE_ID := shipment_rec.QUOTE_LINE_ID;
	  l_shipment_rec.PROMISE_DATE := shipment_rec.PROMISE_DATE;
	  l_shipment_rec.REQUEST_DATE := shipment_rec.REQUEST_DATE;
	  l_shipment_rec.SCHEDULE_SHIP_DATE := shipment_rec.SCHEDULE_SHIP_DATE;
	  l_shipment_rec.SHIP_TO_PARTY_SITE_ID := shipment_rec.SHIP_TO_PARTY_SITE_ID;
	  l_shipment_rec.SHIP_TO_PARTY_ID := shipment_rec.SHIP_TO_PARTY_ID;
          l_shipment_rec.SHIP_TO_CUST_ACCOUNT_ID := shipment_rec.SHIP_TO_CUST_ACCOUNT_ID;
	  l_shipment_rec.SHIP_PARTIAL_FLAG := shipment_rec.SHIP_PARTIAL_FLAG;
	  l_shipment_rec.SHIP_SET_ID := shipment_rec.SHIP_SET_ID;
	  l_shipment_rec.SHIP_METHOD_CODE := shipment_rec.SHIP_METHOD_CODE;
	  l_shipment_rec.FREIGHT_TERMS_CODE := shipment_rec.FREIGHT_TERMS_CODE;
	  l_shipment_rec.FREIGHT_CARRIER_CODE := shipment_rec.FREIGHT_CARRIER_CODE;
	  l_shipment_rec.FOB_CODE := shipment_rec.FOB_CODE;
	  l_shipment_rec.SHIPPING_INSTRUCTIONS := shipment_rec.SHIPPING_INSTRUCTIONS;
	  l_shipment_rec.PACKING_INSTRUCTIONS := shipment_rec.PACKING_INSTRUCTIONS;
	  l_shipment_rec.QUANTITY := shipment_rec.QUANTITY;
	  l_shipment_rec.RESERVED_QUANTITY := shipment_rec.RESERVED_QUANTITY;
	  l_shipment_rec.RESERVATION_ID := shipment_rec.RESERVATION_ID;
	  l_shipment_rec.ORDER_LINE_ID := shipment_rec.ORDER_LINE_ID;
	  l_shipment_rec.ATTRIBUTE_CATEGORY := shipment_rec.ATTRIBUTE_CATEGORY;
	  l_shipment_rec.ATTRIBUTE1 := shipment_rec.ATTRIBUTE1;
	  l_shipment_rec.ATTRIBUTE2 := shipment_rec.ATTRIBUTE2;
	  l_shipment_rec.ATTRIBUTE3 := shipment_rec.ATTRIBUTE3;
	  l_shipment_rec.ATTRIBUTE4 := shipment_rec.ATTRIBUTE4;
	  l_shipment_rec.ATTRIBUTE5 := shipment_rec.ATTRIBUTE5;
	  l_shipment_rec.ATTRIBUTE6 := shipment_rec.ATTRIBUTE6;
	  l_shipment_rec.ATTRIBUTE7 := shipment_rec.ATTRIBUTE7;
	  l_shipment_rec.ATTRIBUTE8 := shipment_rec.ATTRIBUTE8;
	  l_shipment_rec.ATTRIBUTE9 := shipment_rec.ATTRIBUTE9;
	  l_shipment_rec.ATTRIBUTE10 := shipment_rec.ATTRIBUTE10;
	  l_shipment_rec.ATTRIBUTE11 := shipment_rec.ATTRIBUTE11;
	  l_shipment_rec.ATTRIBUTE12 := shipment_rec.ATTRIBUTE12;
	  l_shipment_rec.ATTRIBUTE13 := shipment_rec.ATTRIBUTE13;
	  l_shipment_rec.ATTRIBUTE14 := shipment_rec.ATTRIBUTE14;
	  l_shipment_rec.ATTRIBUTE15 := shipment_rec.ATTRIBUTE15;
	  l_shipment_rec.ATTRIBUTE16 := shipment_rec.ATTRIBUTE16;
	  l_shipment_rec.ATTRIBUTE17 := shipment_rec.ATTRIBUTE17;
	  l_shipment_rec.ATTRIBUTE18 := shipment_rec.ATTRIBUTE18;
	  l_shipment_rec.ATTRIBUTE19 := shipment_rec.ATTRIBUTE19;
	  l_shipment_rec.ATTRIBUTE20 := shipment_rec.ATTRIBUTE20;
	  l_shipment_rec.SHIPMENT_PRIORITY_CODE := shipment_rec.SHIPMENT_PRIORITY_CODE;
	  l_shipment_rec.SHIP_QUOTE_PRICE := shipment_rec.SHIP_QUOTE_PRICE;
       l_shipment_rec.SHIP_FROM_ORG_ID := shipment_rec.SHIP_FROM_ORG_ID;
       l_shipment_rec.SHIP_TO_CUST_PARTY_ID := shipment_rec.SHIP_TO_CUST_PARTY_ID;
       l_shipment_rec.REQUEST_DATE_TYPE := shipment_rec.REQUEST_DATE_TYPE;
       l_shipment_rec.DEMAND_CLASS_CODE := shipment_rec.DEMAND_CLASS_CODE;
       l_shipment_rec.OBJECT_VERSION_NUMBER := shipment_rec.OBJECT_VERSION_NUMBER;
        l_shipment_rec.SHIP_METHOD_CODE_FROM := shipment_rec.SHIP_METHOD_CODE_FROM;
        l_shipment_rec.FREIGHT_TERMS_CODE_FROM := shipment_rec.FREIGHT_TERMS_CODE_FROM;
      END LOOP;

      RETURN l_shipment_rec;

END Query_Line_Shipment_Row_atp;

FUNCTION Query_Freight_Charge_Rows (
    P_Shipment_Tbl		IN  ASO_QUOTE_PUB.Shipment_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
IS
    CURSOR c_freight_charge (c_shipment_id NUMBER) IS
	SELECT
        FREIGHT_CHARGE_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	QUOTE_SHIPMENT_ID,
	FREIGHT_CHARGE_TYPE_ID,
	CHARGE_AMOUNT,
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
	ATTRIBUTE15
        FROM ASO_FREIGHT_CHARGES
	WHERE quote_shipment_id = c_shipment_id;
    l_freight_charge_rec             ASO_QUOTE_PUB.Freight_Charge_Rec_Type;
    l_freight_charge_tbl             ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
BEGIN
   FOR i IN 1..P_shipment_tbl.count LOOP
      FOR freight_charge_rec IN c_freight_charge(P_shipment_tbl(i).shipment_id) LOOP
	  l_freight_charge_rec.FREIGHT_CHARGE_ID :=
						freight_charge_rec.FREIGHT_CHARGE_ID;
	  l_freight_charge_rec.shipment_index := i;
	   l_freight_charge_rec.CREATION_DATE := freight_charge_rec.CREATION_DATE;
	   l_freight_charge_rec.CREATED_BY := freight_charge_rec.CREATED_BY;
	   l_freight_charge_rec.LAST_UPDATE_DATE := freight_charge_rec.LAST_UPDATE_DATE;
	   l_freight_charge_rec.LAST_UPDATED_BY := freight_charge_rec.LAST_UPDATED_BY;
	   l_freight_charge_rec.LAST_UPDATE_LOGIN := freight_charge_rec.LAST_UPDATE_LOGIN;
	   l_freight_charge_rec.REQUEST_ID := freight_charge_rec.REQUEST_ID;
	   l_freight_charge_rec.PROGRAM_APPLICATION_ID := freight_charge_rec.PROGRAM_APPLICATION_ID;
	   l_freight_charge_rec.PROGRAM_ID := freight_charge_rec.PROGRAM_ID;
	   l_freight_charge_rec.PROGRAM_UPDATE_DATE := freight_charge_rec.PROGRAM_UPDATE_DATE;
	  l_freight_charge_rec.QUOTE_SHIPMENT_ID :=
						freight_charge_rec.QUOTE_SHIPMENT_ID;

	  l_freight_charge_rec.CHARGE_AMOUNT := freight_charge_rec.CHARGE_AMOUNT;
	  l_freight_charge_rec.FREIGHT_CHARGE_TYPE_ID :=
						freight_charge_rec.FREIGHT_CHARGE_TYPE_ID;
	  l_freight_charge_rec.ATTRIBUTE1 := freight_charge_rec.ATTRIBUTE1;
	  l_freight_charge_rec.ATTRIBUTE2 := freight_charge_rec.ATTRIBUTE2;
	  l_freight_charge_rec.ATTRIBUTE3 := freight_charge_rec.ATTRIBUTE3;
	  l_freight_charge_rec.ATTRIBUTE4 := freight_charge_rec.ATTRIBUTE4;
	  l_freight_charge_rec.ATTRIBUTE5 := freight_charge_rec.ATTRIBUTE5;
	  l_freight_charge_rec.ATTRIBUTE6 := freight_charge_rec.ATTRIBUTE6;
	  l_freight_charge_rec.ATTRIBUTE7 := freight_charge_rec.ATTRIBUTE7;
	  l_freight_charge_rec.ATTRIBUTE8 := freight_charge_rec.ATTRIBUTE8;
	  l_freight_charge_rec.ATTRIBUTE9 := freight_charge_rec.ATTRIBUTE9;
	  l_freight_charge_rec.ATTRIBUTE10 := freight_charge_rec.ATTRIBUTE10;
	  l_freight_charge_rec.ATTRIBUTE11 := freight_charge_rec.ATTRIBUTE11;
	  l_freight_charge_rec.ATTRIBUTE12 := freight_charge_rec.ATTRIBUTE12;
	  l_freight_charge_rec.ATTRIBUTE13 := freight_charge_rec.ATTRIBUTE13;
	  l_freight_charge_rec.ATTRIBUTE14 := freight_charge_rec.ATTRIBUTE14;
	  l_freight_charge_rec.ATTRIBUTE15 := freight_charge_rec.ATTRIBUTE15;
	  l_freight_charge_tbl(l_freight_charge_tbl.COUNT+1) := l_freight_charge_rec;
      END LOOP;
   END LOOP;
   RETURN l_freight_charge_tbl;
END Query_Freight_Charge_Rows;

FUNCTION  Query_Sales_Credit_Row (
    P_Sales_Credit_Id		 IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.Sales_Credit_rec_Type
IS
  l_sales_credit_rec        ASO_QUOTE_PUB.Sales_Credit_rec_Type;
  l_sales_credit_tbl        ASO_QUOTE_PUB.Sales_Credit_tbl_Type;

  CURSOR C1 IS
SELECT
CREATION_DATE,
CREATED_BY,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
REQUEST_ID,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
SALES_CREDIT_ID,
QUOTE_HEADER_ID,
QUOTE_LINE_ID,
PERCENT,
RESOURCE_ID,
RESOURCE_GROUP_ID,
EMPLOYEE_PERSON_ID,
SALES_CREDIT_TYPE_ID,
ATTRIBUTE_CATEGORY_CODE,
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
OBJECT_VERSION_NUMBER,
SYSTEM_ASSIGNED_FLAG,
CREDIT_RULE_ID
FROM ASO_SALES_CREDITS
WHERE SALES_CREDIT_ID = P_Sales_Credit_Id;
BEGIN
 FOR sales_rec IN c1 LOOP
      --dbms_output.put_line('Inside Sales');
l_sales_credit_rec.CREATION_DATE :=                  sales_rec.CREATION_DATE;
l_sales_credit_rec.CREATED_BY :=                     sales_rec.CREATED_BY;
l_sales_credit_rec.LAST_UPDATED_BY :=                sales_rec.LAST_UPDATED_BY;
l_sales_credit_rec.LAST_UPDATE_DATE :=               sales_rec.LAST_UPDATE_DATE;
l_sales_credit_rec.LAST_UPDATE_LOGIN :=              sales_rec.LAST_UPDATE_LOGIN;
l_sales_credit_rec.REQUEST_ID :=                     sales_rec.REQUEST_ID;
l_sales_credit_rec.PROGRAM_APPLICATION_ID :=         sales_rec.PROGRAM_APPLICATION_ID;
l_sales_credit_rec.PROGRAM_ID :=                     sales_rec.PROGRAM_ID;
l_sales_credit_rec.PROGRAM_UPDATE_DATE :=            sales_rec.PROGRAM_UPDATE_DATE;
l_sales_credit_rec.SALES_CREDIT_ID :=                sales_rec.SALES_CREDIT_ID;
l_sales_credit_rec.QUOTE_HEADER_ID :=                sales_rec.QUOTE_HEADER_ID;
l_sales_credit_rec.QUOTE_LINE_ID :=                  sales_rec.QUOTE_LINE_ID;
l_sales_credit_rec.PERCENT :=                        sales_rec.PERCENT;
l_sales_credit_rec.RESOURCE_ID :=                    sales_rec.RESOURCE_ID;
l_sales_credit_rec.RESOURCE_GROUP_ID :=              sales_rec.RESOURCE_GROUP_ID;
l_sales_credit_rec.EMPLOYEE_PERSON_ID :=             sales_rec.EMPLOYEE_PERSON_ID;
l_sales_credit_rec.SALES_CREDIT_TYPE_ID :=           sales_rec.SALES_CREDIT_TYPE_ID;
l_sales_credit_rec.ATTRIBUTE_CATEGORY_CODE :=        sales_rec.ATTRIBUTE_CATEGORY_CODE;
l_sales_credit_rec.ATTRIBUTE1 :=                     sales_rec.ATTRIBUTE1;
l_sales_credit_rec.ATTRIBUTE2 :=                     sales_rec.ATTRIBUTE2;
l_sales_credit_rec.ATTRIBUTE3 :=                     sales_rec.ATTRIBUTE3;
l_sales_credit_rec.ATTRIBUTE4 :=                     sales_rec.ATTRIBUTE4;
l_sales_credit_rec.ATTRIBUTE5 :=                     sales_rec.ATTRIBUTE5;
l_sales_credit_rec.ATTRIBUTE6 :=                     sales_rec.ATTRIBUTE6;
l_sales_credit_rec.ATTRIBUTE7 :=                     sales_rec.ATTRIBUTE7;
l_sales_credit_rec.ATTRIBUTE8 :=                     sales_rec.ATTRIBUTE8;
l_sales_credit_rec.ATTRIBUTE9 :=                     sales_rec.ATTRIBUTE9;
l_sales_credit_rec.ATTRIBUTE10 :=                    sales_rec.ATTRIBUTE10;
l_sales_credit_rec.ATTRIBUTE11 :=                    sales_rec.ATTRIBUTE11;
l_sales_credit_rec.ATTRIBUTE12 :=                    sales_rec.ATTRIBUTE12;
l_sales_credit_rec.ATTRIBUTE13 :=                    sales_rec.ATTRIBUTE13;
l_sales_credit_rec.ATTRIBUTE14 :=                    sales_rec.ATTRIBUTE14;
l_sales_credit_rec.ATTRIBUTE15 :=                    sales_rec.ATTRIBUTE15;
l_sales_credit_rec.ATTRIBUTE16 :=                    sales_rec.ATTRIBUTE16;
l_sales_credit_rec.ATTRIBUTE17 :=                    sales_rec.ATTRIBUTE17;
l_sales_credit_rec.ATTRIBUTE18 :=                    sales_rec.ATTRIBUTE18;
l_sales_credit_rec.ATTRIBUTE19 :=                    sales_rec.ATTRIBUTE19;
l_sales_credit_rec.ATTRIBUTE20 :=                    sales_rec.ATTRIBUTE20;
l_sales_credit_rec.SYSTEM_ASSIGNED_FLAG :=           sales_rec.SYSTEM_ASSIGNED_FLAG;
l_sales_credit_rec.CREDIT_RULE_ID :=                 sales_rec.CREDIT_RULE_ID;
l_sales_credit_rec.OBJECT_VERSION_NUMBER :=          sales_rec.OBJECT_VERSION_NUMBER;
END LOOP;
RETURN l_sales_credit_rec;
END Query_Sales_Credit_Row;

FUNCTION  Query_Sales_Credit_Row (
    P_qte_header_Id		 IN   NUMBER,
    p_qte_line_id        IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.Sales_Credit_tbl_Type
IS
  l_sales_credit_rec        ASO_QUOTE_PUB.Sales_Credit_rec_Type;
  l_sales_credit_tbl        ASO_QUOTE_PUB.Sales_Credit_tbl_Type;

  CURSOR C1 IS
SELECT
CREATION_DATE,
CREATED_BY,
LAST_UPDATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
REQUEST_ID,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
SALES_CREDIT_ID,
QUOTE_HEADER_ID,
QUOTE_LINE_ID,
PERCENT,
RESOURCE_ID,
RESOURCE_GROUP_ID,
EMPLOYEE_PERSON_ID,
SALES_CREDIT_TYPE_ID,
ATTRIBUTE_CATEGORY_CODE,
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
OBJECT_VERSION_NUMBER,
SYSTEM_ASSIGNED_FLAG,
CREDIT_RULE_ID
FROM ASO_SALES_CREDITS
WHERE  quote_header_id = p_qte_header_id AND
	   ((quote_line_id = p_qte_line_id) OR (quote_line_id IS NULL AND p_qte_line_id IS NULL));
BEGIN
 FOR sales_rec IN c1 LOOP
      --dbms_output.put_line('Inside Sales');
l_sales_credit_rec.CREATION_DATE :=                  sales_rec.CREATION_DATE;
l_sales_credit_rec.CREATED_BY :=                     sales_rec.CREATED_BY;
l_sales_credit_rec.LAST_UPDATED_BY :=                sales_rec.LAST_UPDATED_BY;
l_sales_credit_rec.LAST_UPDATE_DATE :=               sales_rec.LAST_UPDATE_DATE;
l_sales_credit_rec.LAST_UPDATE_LOGIN :=              sales_rec.LAST_UPDATE_LOGIN;
l_sales_credit_rec.REQUEST_ID :=                     sales_rec.REQUEST_ID;
l_sales_credit_rec.PROGRAM_APPLICATION_ID :=         sales_rec.PROGRAM_APPLICATION_ID;
l_sales_credit_rec.PROGRAM_ID :=                     sales_rec.PROGRAM_ID;
l_sales_credit_rec.PROGRAM_UPDATE_DATE :=            sales_rec.PROGRAM_UPDATE_DATE;
l_sales_credit_rec.SALES_CREDIT_ID :=                sales_rec.SALES_CREDIT_ID;
l_sales_credit_rec.QUOTE_HEADER_ID :=                sales_rec.QUOTE_HEADER_ID;
l_sales_credit_rec.QUOTE_LINE_ID :=                  sales_rec.QUOTE_LINE_ID;
l_sales_credit_rec.PERCENT :=                        sales_rec.PERCENT;
l_sales_credit_rec.RESOURCE_ID :=                    sales_rec.RESOURCE_ID;
l_sales_credit_rec.RESOURCE_GROUP_ID :=              sales_rec.RESOURCE_GROUP_ID;
l_sales_credit_rec.EMPLOYEE_PERSON_ID :=             sales_rec.EMPLOYEE_PERSON_ID;
l_sales_credit_rec.SALES_CREDIT_TYPE_ID :=           sales_rec.SALES_CREDIT_TYPE_ID;
l_sales_credit_rec.ATTRIBUTE_CATEGORY_CODE :=        sales_rec.ATTRIBUTE_CATEGORY_CODE;
l_sales_credit_rec.ATTRIBUTE1 :=                     sales_rec.ATTRIBUTE1;
l_sales_credit_rec.ATTRIBUTE2 :=                     sales_rec.ATTRIBUTE2;
l_sales_credit_rec.ATTRIBUTE3 :=                     sales_rec.ATTRIBUTE3;
l_sales_credit_rec.ATTRIBUTE4 :=                     sales_rec.ATTRIBUTE4;
l_sales_credit_rec.ATTRIBUTE5 :=                     sales_rec.ATTRIBUTE5;
l_sales_credit_rec.ATTRIBUTE6 :=                     sales_rec.ATTRIBUTE6;
l_sales_credit_rec.ATTRIBUTE7 :=                     sales_rec.ATTRIBUTE7;
l_sales_credit_rec.ATTRIBUTE8 :=                     sales_rec.ATTRIBUTE8;
l_sales_credit_rec.ATTRIBUTE9 :=                     sales_rec.ATTRIBUTE9;
l_sales_credit_rec.ATTRIBUTE10 :=                    sales_rec.ATTRIBUTE10;
l_sales_credit_rec.ATTRIBUTE11 :=                    sales_rec.ATTRIBUTE11;
l_sales_credit_rec.ATTRIBUTE12 :=                    sales_rec.ATTRIBUTE12;
l_sales_credit_rec.ATTRIBUTE13 :=                    sales_rec.ATTRIBUTE13;
l_sales_credit_rec.ATTRIBUTE14 :=                    sales_rec.ATTRIBUTE14;
l_sales_credit_rec.ATTRIBUTE15 :=                    sales_rec.ATTRIBUTE15;
l_sales_credit_rec.ATTRIBUTE16 :=                    sales_rec.ATTRIBUTE16;
l_sales_credit_rec.ATTRIBUTE17 :=                    sales_rec.ATTRIBUTE17;
l_sales_credit_rec.ATTRIBUTE18 :=                    sales_rec.ATTRIBUTE18;
l_sales_credit_rec.ATTRIBUTE19 :=                    sales_rec.ATTRIBUTE19;
l_sales_credit_rec.ATTRIBUTE20 :=                    sales_rec.ATTRIBUTE20;
l_sales_credit_rec.SYSTEM_ASSIGNED_FLAG :=           sales_rec.SYSTEM_ASSIGNED_FLAG;
l_sales_credit_rec.CREDIT_RULE_ID :=                 sales_rec.CREDIT_RULE_ID;

l_sales_credit_rec.OBJECT_VERSION_NUMBER :=          sales_rec.OBJECT_VERSION_NUMBER;
l_sales_credit_tbl(l_sales_credit_tbl.COUNT+1) := l_sales_credit_rec;
END LOOP;
RETURN l_sales_credit_tbl;
END Query_Sales_Credit_Row;


FUNCTION  Query_Quote_Party_Row (
    P_Quote_Party_Id		 IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.QUOTE_PARTY_rec_Type
IS
  l_quote_party_rec        ASO_QUOTE_PUB.QUOTE_PARTY_rec_Type;
  l_quote_party_tbl        ASO_QUOTE_PUB.QUOTE_PARTY_tbl_Type;

CURSOR C1 is
SELECT QUOTE_PARTY_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
LAST_UPDATED_BY,
REQUEST_ID,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
QUOTE_HEADER_ID,
QUOTE_LINE_ID,
QUOTE_SHIPMENT_ID,
PARTY_TYPE,
PARTY_ID,
PARTY_OBJECT_TYPE,
PARTY_OBJECT_ID,
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
ATTRIBUTE15
FROM ASO_QUOTE_PARTIES WHERE
QUOTE_PARTY_ID= P_Quote_Party_Id;

BEGIN
 FOR qpt_rec in C1 LOOP
 l_quote_party_rec.QUOTE_PARTY_ID :=                 qpt_rec.QUOTE_PARTY_ID;
l_quote_party_rec.CREATION_DATE :=                  qpt_rec.CREATION_DATE;
l_quote_party_rec.CREATED_BY :=                     qpt_rec.CREATED_BY;
l_quote_party_rec.LAST_UPDATE_DATE :=               qpt_rec.LAST_UPDATE_DATE;
l_quote_party_rec.LAST_UPDATE_LOGIN :=              qpt_rec.LAST_UPDATE_LOGIN;
l_quote_party_rec.LAST_UPDATED_BY :=                qpt_rec.LAST_UPDATED_BY;
l_quote_party_rec.REQUEST_ID :=                     qpt_rec.REQUEST_ID;
l_quote_party_rec.PROGRAM_APPLICATION_ID :=         qpt_rec.PROGRAM_APPLICATION_ID;
l_quote_party_rec.PROGRAM_ID :=                     qpt_rec.PROGRAM_ID;
l_quote_party_rec.PROGRAM_UPDATE_DATE :=            qpt_rec.PROGRAM_UPDATE_DATE;
l_quote_party_rec.QUOTE_HEADER_ID :=                qpt_rec.QUOTE_HEADER_ID;
l_quote_party_rec.QUOTE_LINE_ID :=                  qpt_rec.QUOTE_LINE_ID;
l_quote_party_rec.QUOTE_SHIPMENT_ID :=              qpt_rec.QUOTE_SHIPMENT_ID;
l_quote_party_rec.PARTY_TYPE :=                     qpt_rec.PARTY_TYPE;
l_quote_party_rec.PARTY_ID :=                       qpt_rec.PARTY_ID;
l_quote_party_rec.PARTY_OBJECT_TYPE :=              qpt_rec.PARTY_OBJECT_TYPE;
l_quote_party_rec.PARTY_OBJECT_ID :=                qpt_rec.PARTY_OBJECT_ID;
l_quote_party_rec.ATTRIBUTE_CATEGORY :=             qpt_rec.ATTRIBUTE_CATEGORY;
l_quote_party_rec.ATTRIBUTE1 :=                     qpt_rec.ATTRIBUTE1;
l_quote_party_rec.ATTRIBUTE2 :=                     qpt_rec.ATTRIBUTE2;
l_quote_party_rec.ATTRIBUTE3 :=                     qpt_rec.ATTRIBUTE3;
l_quote_party_rec.ATTRIBUTE4 :=                     qpt_rec.ATTRIBUTE4;
l_quote_party_rec.ATTRIBUTE5 :=                     qpt_rec.ATTRIBUTE5;
l_quote_party_rec.ATTRIBUTE6 :=                     qpt_rec.ATTRIBUTE6;
l_quote_party_rec.ATTRIBUTE7 :=                     qpt_rec.ATTRIBUTE7;
l_quote_party_rec.ATTRIBUTE8 :=                     qpt_rec.ATTRIBUTE8;
l_quote_party_rec.ATTRIBUTE9 :=                     qpt_rec.ATTRIBUTE9;
l_quote_party_rec.ATTRIBUTE10 :=                    qpt_rec.ATTRIBUTE10;
l_quote_party_rec.ATTRIBUTE11 :=                    qpt_rec.ATTRIBUTE11;
l_quote_party_rec.ATTRIBUTE12 :=                    qpt_rec.ATTRIBUTE12;
l_quote_party_rec.ATTRIBUTE13 :=                    qpt_rec.ATTRIBUTE13;
l_quote_party_rec.ATTRIBUTE14 :=                    qpt_rec.ATTRIBUTE14;
l_quote_party_rec.ATTRIBUTE15 :=                    qpt_rec.ATTRIBUTE15;
END LOOP;
RETURN l_quote_party_rec;

END Query_Quote_Party_Row;


FUNCTION  Query_Quote_Party_Row (
    P_Qte_header_Id		 IN   NUMBER,
    P_Qte_line_Id		 IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.QUOTE_PARTY_tbl_Type
IS
  l_quote_party_rec        ASO_QUOTE_PUB.QUOTE_PARTY_rec_Type;
  l_quote_party_tbl        ASO_QUOTE_PUB.QUOTE_PARTY_tbl_Type;

CURSOR C1 is
SELECT QUOTE_PARTY_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,
LAST_UPDATED_BY,
REQUEST_ID,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
QUOTE_HEADER_ID,
QUOTE_LINE_ID,
QUOTE_SHIPMENT_ID,
PARTY_TYPE,
PARTY_ID,
PARTY_OBJECT_TYPE,
PARTY_OBJECT_ID,
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
ATTRIBUTE15
FROM ASO_QUOTE_PARTIES WHERE quote_header_id = p_qte_header_id AND
	   ((quote_line_id = p_qte_line_id) OR (quote_line_id IS NULL AND p_qte_line_id IS NULL));

BEGIN
 FOR qpt_rec in C1 LOOP
 l_quote_party_rec.QUOTE_PARTY_ID :=                 qpt_rec.QUOTE_PARTY_ID;
l_quote_party_rec.CREATION_DATE :=                  qpt_rec.CREATION_DATE;
l_quote_party_rec.CREATED_BY :=                     qpt_rec.CREATED_BY;
l_quote_party_rec.LAST_UPDATE_DATE :=               qpt_rec.LAST_UPDATE_DATE;
l_quote_party_rec.LAST_UPDATE_LOGIN :=              qpt_rec.LAST_UPDATE_LOGIN;
l_quote_party_rec.LAST_UPDATED_BY :=                qpt_rec.LAST_UPDATED_BY;
l_quote_party_rec.REQUEST_ID :=                     qpt_rec.REQUEST_ID;
l_quote_party_rec.PROGRAM_APPLICATION_ID :=         qpt_rec.PROGRAM_APPLICATION_ID;
l_quote_party_rec.PROGRAM_ID :=                     qpt_rec.PROGRAM_ID;
l_quote_party_rec.PROGRAM_UPDATE_DATE :=            qpt_rec.PROGRAM_UPDATE_DATE;
l_quote_party_rec.QUOTE_HEADER_ID :=                qpt_rec.QUOTE_HEADER_ID;
l_quote_party_rec.QUOTE_LINE_ID :=                  qpt_rec.QUOTE_LINE_ID;
l_quote_party_rec.QUOTE_SHIPMENT_ID :=              qpt_rec.QUOTE_SHIPMENT_ID;
l_quote_party_rec.PARTY_TYPE :=                     qpt_rec.PARTY_TYPE;
l_quote_party_rec.PARTY_ID :=                       qpt_rec.PARTY_ID;
l_quote_party_rec.PARTY_OBJECT_TYPE :=              qpt_rec.PARTY_OBJECT_TYPE;
l_quote_party_rec.PARTY_OBJECT_ID :=                qpt_rec.PARTY_OBJECT_ID;
l_quote_party_rec.ATTRIBUTE_CATEGORY :=             qpt_rec.ATTRIBUTE_CATEGORY;
l_quote_party_rec.ATTRIBUTE1 :=                     qpt_rec.ATTRIBUTE1;
l_quote_party_rec.ATTRIBUTE2 :=                     qpt_rec.ATTRIBUTE2;
l_quote_party_rec.ATTRIBUTE3 :=                     qpt_rec.ATTRIBUTE3;
l_quote_party_rec.ATTRIBUTE4 :=                     qpt_rec.ATTRIBUTE4;
l_quote_party_rec.ATTRIBUTE5 :=                     qpt_rec.ATTRIBUTE5;
l_quote_party_rec.ATTRIBUTE6 :=                     qpt_rec.ATTRIBUTE6;
l_quote_party_rec.ATTRIBUTE7 :=                     qpt_rec.ATTRIBUTE7;
l_quote_party_rec.ATTRIBUTE8 :=                     qpt_rec.ATTRIBUTE8;
l_quote_party_rec.ATTRIBUTE9 :=                     qpt_rec.ATTRIBUTE9;
l_quote_party_rec.ATTRIBUTE10 :=                    qpt_rec.ATTRIBUTE10;
l_quote_party_rec.ATTRIBUTE11 :=                    qpt_rec.ATTRIBUTE11;
l_quote_party_rec.ATTRIBUTE12 :=                    qpt_rec.ATTRIBUTE12;
l_quote_party_rec.ATTRIBUTE13 :=                    qpt_rec.ATTRIBUTE13;
l_quote_party_rec.ATTRIBUTE14 :=                    qpt_rec.ATTRIBUTE14;
l_quote_party_rec.ATTRIBUTE15 :=                    qpt_rec.ATTRIBUTE15;
l_quote_party_tbl(l_quote_party_tbl.COUNT+1) := l_quote_party_rec;
END LOOP;
RETURN l_quote_party_tbl;

END Query_Quote_Party_Row;




FUNCTION  Query_Qte_Line_Row (
    P_Qte_Line_Id		 IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.qte_line_rec_Type
IS
    l_qte_line_rec	ASO_QUOTE_PUB.qte_line_rec_Type;
BEGIN
	Select
	  QUOTE_LINE_ID,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN,
	  REQUEST_ID,
	  PROGRAM_APPLICATION_ID,
	  PROGRAM_ID,
	  PROGRAM_UPDATE_DATE,
	  QUOTE_HEADER_ID,
	  ORG_ID,
	  LINE_CATEGORY_CODE,
	  ITEM_TYPE_CODE,
	  LINE_NUMBER,
	  START_DATE_ACTIVE,
	  END_DATE_ACTIVE,
	  ORDER_LINE_TYPE_ID,
	  INVOICE_TO_PARTY_SITE_ID,
	  INVOICE_TO_PARTY_ID,
          INVOICE_TO_CUST_ACCOUNT_ID,
	  ORGANIZATION_ID,
	  INVENTORY_ITEM_ID,
	  QUANTITY,
	  UOM_CODE,
	  MARKETING_SOURCE_CODE_ID,
	  PRICE_LIST_ID,
	  PRICE_LIST_LINE_ID,
	  CURRENCY_CODE,
	  LINE_LIST_PRICE,
	  LINE_ADJUSTED_AMOUNT,
	  LINE_ADJUSTED_PERCENT,
	  LINE_QUOTE_PRICE,
	  RELATED_ITEM_ID,
	  ITEM_RELATIONSHIP_TYPE,
	  ACCOUNTING_RULE_ID,
	  INVOICING_RULE_ID,
	   SPLIT_SHIPMENT_FLAG,
	   BACKORDER_FLAG,
           MINISITE_ID,
           SECTION_ID,
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
           PRICED_PRICE_LIST_ID,
           AGREEMENT_ID,
           COMMITMENT_ID,
		 DISPLAY_ARITHMETIC_OPERATOR,
		 SERVICE_ITEM_FLAG,
		 SERVICEABLE_PRODUCT_FLAG,
		 INVOICE_TO_CUST_PARTY_ID,
		 SELLING_PRICE_CHANGE,
		 RECALCULATE_FLAG,
		 PRICING_LINE_TYPE_INDICATOR,
           END_CUSTOMER_PARTY_ID,
           END_CUSTOMER_PARTY_SITE_ID,
           END_CUSTOMER_CUST_ACCOUNT_ID,
           END_CUSTOMER_CUST_PARTY_ID,
           SHIP_MODEL_COMPLETE_FLAG,
           CHARGE_PERIODICITY_CODE,
           OBJECT_VERSION_NUMBER,
		 PRICING_QUANTITY_UOM,
		 PRICING_QUANTITY,
		 CONFIG_MODEL_TYPE,
		 -- ER 12879412
		 PRODUCT_FISC_CLASSIFICATION,
		 TRX_BUSINESS_CATEGORY,
		 ORDERED_ITEM_ID,
		 ITEM_IDENTIFIER_TYPE,
		 ORDERED_ITEM,
		-- UNIT_PRICE -- bug 17517305
		-- ER 17900033
		 LINE_UNIT_COST,
		 LINE_MARGIN_AMOUNT,
		 LINE_MARGIN_PERCENT

	INTO
	   l_qte_line_rec.QUOTE_LINE_ID,
	   l_qte_line_rec.CREATION_DATE,
	   l_qte_line_rec.CREATED_BY,
	   l_qte_line_rec.LAST_UPDATE_DATE,
	   l_qte_line_rec.LAST_UPDATED_BY,
	   l_qte_line_rec.LAST_UPDATE_LOGIN,
	   l_qte_line_rec.REQUEST_ID,
	   l_qte_line_rec.PROGRAM_APPLICATION_ID,
	   l_qte_line_rec.PROGRAM_ID,
	   l_qte_line_rec.PROGRAM_UPDATE_DATE,
	   l_qte_line_rec.QUOTE_HEADER_ID,
	   l_qte_line_rec.ORG_ID,
	   l_qte_line_rec.LINE_CATEGORY_CODE,
	   l_qte_line_rec.ITEM_TYPE_CODE,
	   l_qte_line_rec.LINE_NUMBER,
	   l_qte_line_rec.START_DATE_ACTIVE,
	   l_qte_line_rec.END_DATE_ACTIVE,
	   l_qte_line_rec.ORDER_LINE_TYPE_ID,
	   l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID,
	   l_qte_line_rec.INVOICE_TO_PARTY_ID,
           l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID,
	   l_qte_line_rec.ORGANIZATION_ID,
	   l_qte_line_rec.INVENTORY_ITEM_ID,
	   l_qte_line_rec.QUANTITY,
	   l_qte_line_rec.UOM_CODE,
	   l_qte_line_rec.MARKETING_SOURCE_CODE_ID,
	   l_qte_line_rec.PRICE_LIST_ID,
	   l_qte_line_rec.PRICE_LIST_LINE_ID,
	   l_qte_line_rec.CURRENCY_CODE,
	   l_qte_line_rec.LINE_LIST_PRICE,
	   l_qte_line_rec.LINE_ADJUSTED_AMOUNT,
	   l_qte_line_rec.LINE_ADJUSTED_PERCENT,
	   l_qte_line_rec.LINE_QUOTE_PRICE,
	   l_qte_line_rec.RELATED_ITEM_ID,
	   l_qte_line_rec.ITEM_RELATIONSHIP_TYPE,
	   l_qte_line_rec.ACCOUNTING_RULE_ID,
	   l_qte_line_rec.INVOICING_RULE_ID,
	   l_qte_line_rec.SPLIT_SHIPMENT_FLAG,
	   l_qte_line_rec.BACKORDER_FLAG,
           l_qte_line_rec.MINISITE_ID,
           l_qte_line_rec.SECTION_ID,
           l_qte_line_rec.ATTRIBUTE_CATEGORY,
           l_qte_line_rec.ATTRIBUTE1,
           l_qte_line_rec.ATTRIBUTE2,
           l_qte_line_rec.ATTRIBUTE3,
           l_qte_line_rec.ATTRIBUTE4,
           l_qte_line_rec.ATTRIBUTE5,
           l_qte_line_rec.ATTRIBUTE6,
           l_qte_line_rec.ATTRIBUTE7,
           l_qte_line_rec.ATTRIBUTE8,
           l_qte_line_rec.ATTRIBUTE9,
           l_qte_line_rec.ATTRIBUTE10,
           l_qte_line_rec.ATTRIBUTE11,
           l_qte_line_rec.ATTRIBUTE12,
           l_qte_line_rec.ATTRIBUTE13,
           l_qte_line_rec.ATTRIBUTE14,
           l_qte_line_rec.ATTRIBUTE15,
           l_qte_line_rec.ATTRIBUTE16,
           l_qte_line_rec.ATTRIBUTE17,
           l_qte_line_rec.ATTRIBUTE18,
           l_qte_line_rec.ATTRIBUTE19,
           l_qte_line_rec.ATTRIBUTE20,
           l_qte_line_rec.PRICED_PRICE_LIST_ID,
           l_qte_line_rec.AGREEMENT_ID,
           l_qte_line_rec.COMMITMENT_ID,
		 l_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR,
		 l_qte_line_rec.service_item_flag,
		 l_qte_line_rec.serviceable_product_flag,
		 l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID,
		 l_qte_line_rec.SELLING_PRICE_CHANGE,
		 l_qte_line_rec.RECALCULATE_FLAG,
		 l_qte_line_rec.PRICING_LINE_TYPE_INDICATOR,
           l_qte_line_rec.END_CUSTOMER_PARTY_ID,
           l_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID,
           l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID,
           l_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID,
           l_qte_line_rec.SHIP_MODEL_COMPLETE_FLAG,
           l_qte_line_rec.CHARGE_PERIODICITY_CODE,
           l_qte_line_rec.OBJECT_VERSION_NUMBER,
		 l_qte_line_rec.PRICING_QUANTITY_UOM,
		 l_qte_line_rec.PRICING_QUANTITY,
		 l_qte_line_rec.CONFIG_MODEL_TYPE,
		 -- ER 12879412
		 l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION,
                 l_qte_line_rec.TRX_BUSINESS_CATEGORY,
				 l_qte_line_rec.ORDERED_ITEM_ID,
				 l_qte_line_rec.ITEM_IDENTIFIER_TYPE,
				 l_qte_line_rec.ORDERED_ITEM,
				-- l_qte_line_rec.UNIT_PRICE -- bug 17517305
				-- ER 17900033
		 l_qte_line_rec.LINE_UNIT_COST,
		 l_qte_line_rec.LINE_MARGIN_AMOUNT,
		 l_qte_line_rec.LINE_MARGIN_PERCENT

	FROM ASO_QUOTE_LINES_ALL
	WHERE quote_line_id = p_qte_line_id;
    RETURN l_qte_line_rec;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('ASO', 'ASO_API_ERROR_IN_QUERY');
	    FND_MSG_PUB.ADD;
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Qte_Line_Row;


FUNCTION Query_Qte_Line_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type
IS
    CURSOR c_Qte_Line IS
	SELECT
           QUOTE_LINE_ID,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN,
	  REQUEST_ID,
	  PROGRAM_APPLICATION_ID,
	  PROGRAM_ID,
	  PROGRAM_UPDATE_DATE,
	  QUOTE_HEADER_ID,
	  ORG_ID,
	  LINE_CATEGORY_CODE,
	  ITEM_TYPE_CODE,
	  LINE_NUMBER,
	  START_DATE_ACTIVE,
	  END_DATE_ACTIVE,
	  ORDER_LINE_TYPE_ID,
	  INVOICE_TO_PARTY_SITE_ID,
	  INVOICE_TO_PARTY_ID,
          INVOICE_TO_CUST_ACCOUNT_ID,
	  ORGANIZATION_ID,
	  INVENTORY_ITEM_ID,
	  QUANTITY,
	  UOM_CODE,
	  MARKETING_SOURCE_CODE_ID,
	  PRICE_LIST_ID,
	  PRICE_LIST_LINE_ID,
	  CURRENCY_CODE,
	  LINE_LIST_PRICE,
	  LINE_ADJUSTED_AMOUNT,
	  LINE_ADJUSTED_PERCENT,
	  LINE_QUOTE_PRICE,
	  RELATED_ITEM_ID,
	  ITEM_RELATIONSHIP_TYPE,
	  ACCOUNTING_RULE_ID,
	  INVOICING_RULE_ID,
	   SPLIT_SHIPMENT_FLAG,
	   BACKORDER_FLAG,
           MINISITE_ID,
           SECTION_ID,
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
           PRICED_PRICE_LIST_ID,
		 AGREEMENT_ID,
		 COMMITMENT_ID,
		 DISPLAY_ARITHMETIC_OPERATOR,
		 SERVICE_ITEM_FLAG,
		 SERVICEABLE_PRODUCT_FLAG,
		 INVOICE_TO_CUST_PARTY_ID,
		 SELLING_PRICE_CHANGE,
		 RECALCULATE_FLAG,
		 PRICING_LINE_TYPE_INDICATOR,
           END_CUSTOMER_PARTY_ID,
           END_CUSTOMER_PARTY_SITE_ID,
           END_CUSTOMER_CUST_ACCOUNT_ID,
           END_CUSTOMER_CUST_PARTY_ID,
           CHARGE_PERIODICITY_CODE ,
           SHIP_MODEL_COMPLETE_FLAG ,
           OBJECT_VERSION_NUMBER,
		 PRICING_QUANTITY_UOM,
		 PRICING_QUANTITY,
		 CONFIG_MODEL_TYPE,
		 -- ER 12879412
		 PRODUCT_FISC_CLASSIFICATION,
                 TRX_BUSINESS_CATEGORY,
				 ORDERED_ITEM_ID,
				 ITEM_IDENTIFIER_TYPE,
				 ORDERED_ITEM,
				-- UNIT_PRICE -- bug 17517305
				 -- ER 17900033
		 LINE_UNIT_COST,
		 LINE_MARGIN_AMOUNT,
		 LINE_MARGIN_PERCENT


         FROM ASO_Quote_Lines_All
	WHERE quote_header_id = p_qte_header_id
	ORDER BY Line_Number;
    l_Qte_Line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_Qte_Line_tbl             ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
BEGIN
      FOR Line_rec IN c_Qte_Line LOOP
	   l_qte_line_rec.QUOTE_LINE_ID := line_rec.QUOTE_LINE_ID;
	   l_qte_line_rec.CREATION_DATE := line_rec.CREATION_DATE;
	   l_qte_line_rec.CREATED_BY := line_rec.CREATED_BY;
	   l_qte_line_rec.LAST_UPDATE_DATE := line_rec.LAST_UPDATE_DATE;
	   l_qte_line_rec.LAST_UPDATED_BY := line_rec.LAST_UPDATED_BY;
	   l_qte_line_rec.LAST_UPDATE_LOGIN := line_rec.LAST_UPDATE_LOGIN;
	   l_qte_line_rec.REQUEST_ID := line_rec.REQUEST_ID;
	   l_qte_line_rec.PROGRAM_APPLICATION_ID := line_rec.PROGRAM_APPLICATION_ID;
	   l_qte_line_rec.PROGRAM_ID := line_rec.PROGRAM_ID;
	   l_qte_line_rec.PROGRAM_UPDATE_DATE := line_rec.PROGRAM_UPDATE_DATE;
	    l_qte_line_rec.quote_header_id := line_rec.quote_header_id;
	    l_qte_line_rec.ORG_ID := line_rec.ORG_ID;
	    l_qte_line_rec.LINE_CATEGORY_CODE := line_rec.LINE_CATEGORY_CODE;
	    l_qte_line_rec.ITEM_TYPE_CODE := line_rec.ITEM_TYPE_CODE;
	    l_qte_line_rec.LINE_NUMBER := line_rec.LINE_NUMBER;
	    l_qte_line_rec.START_DATE_ACTIVE := line_rec.START_DATE_ACTIVE;
	    l_qte_line_rec.END_DATE_ACTIVE := line_rec.END_DATE_ACTIVE;
	    l_qte_line_rec.ORDER_LINE_TYPE_ID := line_rec.ORDER_LINE_TYPE_ID;
	    l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID := line_rec.INVOICE_TO_PARTY_SITE_ID;
	    l_qte_line_rec.INVOICE_TO_PARTY_ID := line_rec.INVOICE_TO_PARTY_ID;
            l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID := line_rec.INVOICE_TO_CUST_ACCOUNT_ID;
	    l_qte_line_rec.ORGANIZATION_ID := line_rec.ORGANIZATION_ID;
	    l_qte_line_rec.INVENTORY_ITEM_ID := line_rec.INVENTORY_ITEM_ID;
	    l_qte_line_rec.QUANTITY := line_rec.QUANTITY;
	    l_qte_line_rec.UOM_CODE := line_rec.UOM_CODE;
	    l_qte_line_rec.MARKETING_SOURCE_CODE_ID := line_rec.MARKETING_SOURCE_CODE_ID;
	    l_qte_line_rec.PRICE_LIST_ID := line_rec.PRICE_LIST_ID;
	    l_qte_line_rec.PRICE_LIST_LINE_ID := line_rec.PRICE_LIST_LINE_ID;
	    l_qte_line_rec.CURRENCY_CODE := line_rec.CURRENCY_CODE;
	    l_qte_line_rec.LINE_LIST_PRICE := line_rec.LINE_LIST_PRICE;
	    l_qte_line_rec.LINE_ADJUSTED_AMOUNT := line_rec.LINE_ADJUSTED_AMOUNT;
	    l_qte_line_rec.LINE_ADJUSTED_PERCENT := line_rec.LINE_ADJUSTED_PERCENT;
	    l_qte_line_rec.LINE_QUOTE_PRICE := line_rec.LINE_QUOTE_PRICE;
	    l_qte_line_rec.RELATED_ITEM_ID := line_rec.RELATED_ITEM_ID;
	    l_qte_line_rec.ITEM_RELATIONSHIP_TYPE := line_rec.ITEM_RELATIONSHIP_TYPE;
	    l_qte_line_rec.ACCOUNTING_RULE_ID := line_rec.ACCOUNTING_RULE_ID;
	    l_qte_line_rec.INVOICING_RULE_ID := line_rec.INVOICING_RULE_ID;
	    l_qte_line_rec.SPLIT_SHIPMENT_FLAG := line_rec.SPLIT_SHIPMENT_FLAG;
	    l_qte_line_rec.BACKORDER_FLAG := line_rec.BACKORDER_FLAG;
	    l_qte_line_rec.MINISITE_ID := line_rec.MINISITE_ID;
	    l_qte_line_rec.SECTION_ID := line_rec.SECTION_ID;
	    l_qte_line_rec.ATTRIBUTE_CATEGORY := line_rec.ATTRIBUTE_CATEGORY;
	    l_qte_line_rec.ATTRIBUTE1 := line_rec.ATTRIBUTE1;
	    l_qte_line_rec.ATTRIBUTE2 := line_rec.ATTRIBUTE2;
	    l_qte_line_rec.ATTRIBUTE3 := line_rec.ATTRIBUTE3;
	    l_qte_line_rec.ATTRIBUTE4 := line_rec.ATTRIBUTE4;
	    l_qte_line_rec.ATTRIBUTE5 := line_rec.ATTRIBUTE5;
	    l_qte_line_rec.ATTRIBUTE6 := line_rec.ATTRIBUTE6;
	    l_qte_line_rec.ATTRIBUTE7 := line_rec.ATTRIBUTE7;
	    l_qte_line_rec.ATTRIBUTE8 := line_rec.ATTRIBUTE8;
	    l_qte_line_rec.ATTRIBUTE9 := line_rec.ATTRIBUTE9;
	    l_qte_line_rec.ATTRIBUTE10 := line_rec.ATTRIBUTE10;
	    l_qte_line_rec.ATTRIBUTE11 := line_rec.ATTRIBUTE11;
	    l_qte_line_rec.ATTRIBUTE12 := line_rec.ATTRIBUTE12;
	    l_qte_line_rec.ATTRIBUTE13 := line_rec.ATTRIBUTE13;
	    l_qte_line_rec.ATTRIBUTE14 := line_rec.ATTRIBUTE14;
	    l_qte_line_rec.ATTRIBUTE15 := line_rec.ATTRIBUTE15;
	    l_qte_line_rec.ATTRIBUTE16 := line_rec.ATTRIBUTE16;
	    l_qte_line_rec.ATTRIBUTE17 := line_rec.ATTRIBUTE17;
	    l_qte_line_rec.ATTRIBUTE18 := line_rec.ATTRIBUTE18;
	    l_qte_line_rec.ATTRIBUTE19 := line_rec.ATTRIBUTE19;
	    l_qte_line_rec.ATTRIBUTE20 := line_rec.ATTRIBUTE20;
   	    l_qte_line_rec.PRICED_PRICE_LIST_ID := line_rec.PRICED_PRICE_LIST_ID;
	    l_qte_line_rec.AGREEMENT_ID := line_rec.AGREEMENT_ID;
	    l_qte_line_rec.COMMITMENT_ID := line_rec.COMMITMENT_ID;
	    l_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR := line_rec.DISPLAY_ARITHMETIC_OPERATOR;
	    l_qte_line_rec.service_item_flag := line_rec.service_item_flag;
         l_qte_line_rec.serviceable_product_flag  := line_rec.serviceable_product_flag;
         l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID  := line_rec.INVOICE_TO_CUST_PARTY_ID;
         l_qte_line_rec.SELLING_PRICE_CHANGE      := line_rec.SELLING_PRICE_CHANGE;
         l_qte_line_rec.RECALCULATE_FLAG          := line_rec.RECALCULATE_FLAG;
         l_qte_line_rec.PRICING_LINE_TYPE_INDICATOR  := line_rec.PRICING_LINE_TYPE_INDICATOR;
         l_qte_line_rec.END_CUSTOMER_PARTY_ID        := line_rec.END_CUSTOMER_PARTY_ID;
         l_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID   := line_rec.END_CUSTOMER_PARTY_SITE_ID;
         l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := line_rec.END_CUSTOMER_CUST_ACCOUNT_ID;
         l_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID   := line_rec.END_CUSTOMER_CUST_PARTY_ID;
         l_qte_line_rec.CHARGE_PERIODICITY_CODE := line_rec.CHARGE_PERIODICITY_CODE; -- Recurring charges Change
         l_qte_line_rec.SHIP_MODEL_COMPLETE_FLAG   := line_rec.SHIP_MODEL_COMPLETE_FLAG;
         l_qte_line_rec.OBJECT_VERSION_NUMBER   := line_rec.OBJECT_VERSION_NUMBER;
	    l_qte_line_rec.PRICING_QUANTITY_UOM := line_rec.PRICING_QUANTITY_UOM;
	    l_qte_line_rec.PRICING_QUANTITY := line_rec.PRICING_QUANTITY;
         l_qte_line_rec.CONFIG_MODEL_TYPE := line_rec.CONFIG_MODEL_TYPE;
	 -- ER 12879412
		 l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION := line_rec.PRODUCT_FISC_CLASSIFICATION;
                 l_qte_line_rec.TRX_BUSINESS_CATEGORY := line_rec.TRX_BUSINESS_CATEGORY;

				 	 l_qte_line_rec.ORDERED_ITEM_ID:= line_rec.ORDERED_ITEM_ID;
                 l_qte_line_rec.ITEM_IDENTIFIER_TYPE := line_rec.ITEM_IDENTIFIER_TYPE;
				 l_qte_line_rec.ORDERED_ITEM:= line_rec.ORDERED_ITEM;
				--  l_qte_line_rec.UNIT_PRICE:= line_rec.UNIT_PRICE;-- bug 17517305
		-- ER 17900033
		l_qte_line_rec.LINE_UNIT_COST := line_rec.LINE_UNIT_COST;
		l_qte_line_rec.LINE_MARGIN_AMOUNT := line_rec.LINE_MARGIN_AMOUNT;
		l_qte_line_rec.LINE_MARGIN_PERCENT := line_rec.LINE_MARGIN_PERCENT;

         l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
      END LOOP;
      RETURN l_Qte_Line_tbl;
END Query_Qte_Line_Rows;


FUNCTION Query_Qte_Line_Rows_Submit (
    P_Qte_Header_Id      IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type
IS
    CURSOR c_Qte_Line IS
     SELECT
       QUOTE_LINE_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       REQUEST_ID,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE,
       QUOTE_HEADER_ID,
       ORG_ID,
       LINE_CATEGORY_CODE,
       ITEM_TYPE_CODE,
       UI_LINE_NUMBER,
       START_DATE_ACTIVE,
       END_DATE_ACTIVE,
       ORDER_LINE_TYPE_ID,
       INVOICE_TO_PARTY_SITE_ID,
       INVOICE_TO_PARTY_ID,
       INVOICE_TO_CUST_ACCOUNT_ID,
       ORGANIZATION_ID,
       INVENTORY_ITEM_ID,
       QUANTITY,
       UOM_CODE,
       MARKETING_SOURCE_CODE_ID,
       PRICE_LIST_ID,
       PRICE_LIST_LINE_ID,
       CURRENCY_CODE,
       LINE_LIST_PRICE,
       LINE_ADJUSTED_AMOUNT,
       LINE_ADJUSTED_PERCENT,
       LINE_QUOTE_PRICE,
       RELATED_ITEM_ID,
       ITEM_RELATIONSHIP_TYPE,
       ACCOUNTING_RULE_ID,
       INVOICING_RULE_ID,
       SPLIT_SHIPMENT_FLAG,
       BACKORDER_FLAG,
       MINISITE_ID,
       SECTION_ID,
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
           PRICED_PRICE_LIST_ID,
           AGREEMENT_ID,
           COMMITMENT_ID,
           DISPLAY_ARITHMETIC_OPERATOR,
           SERVICE_ITEM_FLAG,
           SERVICEABLE_PRODUCT_FLAG,
           INVOICE_TO_CUST_PARTY_ID,
           SELLING_PRICE_CHANGE,
           RECALCULATE_FLAG,
		 PRICING_LINE_TYPE_INDICATOR,
           END_CUSTOMER_PARTY_ID,
           END_CUSTOMER_PARTY_SITE_ID,
           END_CUSTOMER_CUST_ACCOUNT_ID,
           END_CUSTOMER_CUST_PARTY_ID,
           CHARGE_PERIODICITY_CODE,
           SHIP_MODEL_COMPLETE_FLAG ,
           OBJECT_VERSION_NUMBER,
		 --CONFIG_MODEL_TYPE
		   -- ER 12879412
          PRODUCT_FISC_CLASSIFICATION,
          TRX_BUSINESS_CATEGORY,
		  ORDERED_ITEM,
		  ORDERED_ITEM_ID,
		  ITEM_IDENTIFIER_TYPE

         FROM ASO_Pvt_Quote_Lines_Bali_V
     WHERE quote_header_id = p_qte_header_id;

    l_Qte_Line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_Qte_Line_tbl             ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
BEGIN
      FOR Line_rec IN c_Qte_Line LOOP
        l_qte_line_rec.QUOTE_LINE_ID := line_rec.QUOTE_LINE_ID;
        l_qte_line_rec.CREATION_DATE := line_rec.CREATION_DATE;
        l_qte_line_rec.CREATED_BY := line_rec.CREATED_BY;
        l_qte_line_rec.LAST_UPDATE_DATE := line_rec.LAST_UPDATE_DATE;
        l_qte_line_rec.LAST_UPDATED_BY := line_rec.LAST_UPDATED_BY;
        l_qte_line_rec.LAST_UPDATE_LOGIN := line_rec.LAST_UPDATE_LOGIN;
        l_qte_line_rec.REQUEST_ID := line_rec.REQUEST_ID;
        l_qte_line_rec.PROGRAM_APPLICATION_ID := line_rec.PROGRAM_APPLICATION_ID;
        l_qte_line_rec.PROGRAM_ID := line_rec.PROGRAM_ID;
        l_qte_line_rec.PROGRAM_UPDATE_DATE := line_rec.PROGRAM_UPDATE_DATE;
         l_qte_line_rec.quote_header_id := line_rec.quote_header_id;
         l_qte_line_rec.ORG_ID := line_rec.ORG_ID;
         l_qte_line_rec.LINE_CATEGORY_CODE := line_rec.LINE_CATEGORY_CODE;
         l_qte_line_rec.ITEM_TYPE_CODE := line_rec.ITEM_TYPE_CODE;
         l_qte_line_rec.UI_LINE_NUMBER := line_rec.UI_LINE_NUMBER;
         l_qte_line_rec.START_DATE_ACTIVE := line_rec.START_DATE_ACTIVE;
         l_qte_line_rec.END_DATE_ACTIVE := line_rec.END_DATE_ACTIVE;
         l_qte_line_rec.ORDER_LINE_TYPE_ID := line_rec.ORDER_LINE_TYPE_ID;
         l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID := line_rec.INVOICE_TO_PARTY_SITE_ID;
         l_qte_line_rec.INVOICE_TO_PARTY_ID := line_rec.INVOICE_TO_PARTY_ID;
         l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID := line_rec.INVOICE_TO_CUST_ACCOUNT_ID;
         l_qte_line_rec.ORGANIZATION_ID := line_rec.ORGANIZATION_ID;
         l_qte_line_rec.INVENTORY_ITEM_ID := line_rec.INVENTORY_ITEM_ID;
         l_qte_line_rec.QUANTITY := line_rec.QUANTITY;
         l_qte_line_rec.UOM_CODE := line_rec.UOM_CODE;
         l_qte_line_rec.MARKETING_SOURCE_CODE_ID := line_rec.MARKETING_SOURCE_CODE_ID;
         l_qte_line_rec.PRICE_LIST_ID := line_rec.PRICE_LIST_ID;
         l_qte_line_rec.PRICE_LIST_LINE_ID := line_rec.PRICE_LIST_LINE_ID;
         l_qte_line_rec.CURRENCY_CODE := line_rec.CURRENCY_CODE;
         l_qte_line_rec.LINE_LIST_PRICE := line_rec.LINE_LIST_PRICE;
         l_qte_line_rec.LINE_ADJUSTED_AMOUNT := line_rec.LINE_ADJUSTED_AMOUNT;
         l_qte_line_rec.LINE_ADJUSTED_PERCENT := line_rec.LINE_ADJUSTED_PERCENT;
         l_qte_line_rec.LINE_QUOTE_PRICE := line_rec.LINE_QUOTE_PRICE;
         l_qte_line_rec.RELATED_ITEM_ID := line_rec.RELATED_ITEM_ID;
         l_qte_line_rec.ITEM_RELATIONSHIP_TYPE := line_rec.ITEM_RELATIONSHIP_TYPE;
         l_qte_line_rec.ACCOUNTING_RULE_ID := line_rec.ACCOUNTING_RULE_ID;
         l_qte_line_rec.INVOICING_RULE_ID := line_rec.INVOICING_RULE_ID;
         l_qte_line_rec.SPLIT_SHIPMENT_FLAG := line_rec.SPLIT_SHIPMENT_FLAG;
         l_qte_line_rec.BACKORDER_FLAG := line_rec.BACKORDER_FLAG;
         l_qte_line_rec.MINISITE_ID := line_rec.MINISITE_ID;
         l_qte_line_rec.SECTION_ID := line_rec.SECTION_ID;
         l_qte_line_rec.ATTRIBUTE_CATEGORY := line_rec.ATTRIBUTE_CATEGORY;
         l_qte_line_rec.ATTRIBUTE1 := line_rec.ATTRIBUTE1;
         l_qte_line_rec.ATTRIBUTE2 := line_rec.ATTRIBUTE2;
         l_qte_line_rec.ATTRIBUTE3 := line_rec.ATTRIBUTE3;
         l_qte_line_rec.ATTRIBUTE4 := line_rec.ATTRIBUTE4;
         l_qte_line_rec.ATTRIBUTE5 := line_rec.ATTRIBUTE5;
         l_qte_line_rec.ATTRIBUTE6 := line_rec.ATTRIBUTE6;
         l_qte_line_rec.ATTRIBUTE7 := line_rec.ATTRIBUTE7;
         l_qte_line_rec.ATTRIBUTE8 := line_rec.ATTRIBUTE8;
         l_qte_line_rec.ATTRIBUTE9 := line_rec.ATTRIBUTE9;
         l_qte_line_rec.ATTRIBUTE10 := line_rec.ATTRIBUTE10;
         l_qte_line_rec.ATTRIBUTE11 := line_rec.ATTRIBUTE11;
         l_qte_line_rec.ATTRIBUTE12 := line_rec.ATTRIBUTE12;
         l_qte_line_rec.ATTRIBUTE13 := line_rec.ATTRIBUTE13;
         l_qte_line_rec.ATTRIBUTE14 := line_rec.ATTRIBUTE14;
         l_qte_line_rec.ATTRIBUTE15 := line_rec.ATTRIBUTE15;
         l_qte_line_rec.ATTRIBUTE16 := line_rec.ATTRIBUTE16;
         l_qte_line_rec.ATTRIBUTE17 := line_rec.ATTRIBUTE17;
         l_qte_line_rec.ATTRIBUTE18 := line_rec.ATTRIBUTE18;
         l_qte_line_rec.ATTRIBUTE19 := line_rec.ATTRIBUTE19;
         l_qte_line_rec.ATTRIBUTE20 := line_rec.ATTRIBUTE20;
         l_qte_line_rec.PRICED_PRICE_LIST_ID := line_rec.PRICED_PRICE_LIST_ID;
         l_qte_line_rec.AGREEMENT_ID := line_rec.AGREEMENT_ID;
         l_qte_line_rec.COMMITMENT_ID := line_rec.COMMITMENT_ID;
         l_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR := line_rec.DISPLAY_ARITHMETIC_OPERATOR;
         l_qte_line_rec.service_item_flag := line_rec.service_item_flag;
         l_qte_line_rec.serviceable_product_flag  := line_rec.serviceable_product_flag;
         l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID  := line_rec.INVOICE_TO_CUST_PARTY_ID;
         l_qte_line_rec.SELLING_PRICE_CHANGE      := line_rec.SELLING_PRICE_CHANGE;
         l_qte_line_rec.RECALCULATE_FLAG          := line_rec.RECALCULATE_FLAG;
         l_qte_line_rec.PRICING_LINE_TYPE_INDICATOR  := line_rec.PRICING_LINE_TYPE_INDICATOR;
         l_qte_line_rec.END_CUSTOMER_PARTY_ID        := line_rec.END_CUSTOMER_PARTY_ID;
         l_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID   := line_rec.END_CUSTOMER_PARTY_SITE_ID;
         l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := line_rec.END_CUSTOMER_CUST_ACCOUNT_ID;
         l_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID   := line_rec.END_CUSTOMER_CUST_PARTY_ID;
         l_qte_line_rec.CHARGE_PERIODICITY_CODE := line_rec.CHARGE_PERIODICITY_CODE;
        l_qte_line_rec.SHIP_MODEL_COMPLETE_FLAG   := line_rec.SHIP_MODEL_COMPLETE_FLAG;
         l_qte_line_rec.OBJECT_VERSION_NUMBER   := line_rec.OBJECT_VERSION_NUMBER;
         --l_qte_line_rec.CONFIG_MODEL_TYPE   := line_rec.CONFIG_MODEL_TYPE;
	    -- ER 12879412
            l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION :=  line_rec.PRODUCT_FISC_CLASSIFICATION;
            l_qte_line_rec.TRX_BUSINESS_CATEGORY := line_rec.TRX_BUSINESS_CATEGORY;
			--ESCO ER
			 l_qte_line_rec.ORDERED_ITEM_ID:= line_rec.ORDERED_ITEM_ID;
			  l_qte_line_rec.ITEM_IDENTIFIER_TYPE := line_rec.ITEM_IDENTIFIER_TYPE;
				 l_qte_line_rec.ORDERED_ITEM:= line_rec.ORDERED_ITEM;
                 l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
      END LOOP;
      RETURN l_Qte_Line_tbl;
END Query_Qte_Line_Rows_Submit;


FUNCTION Query_Qte_Line_Rows_Sort (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type
IS
    CURSOR c_Qte_Line IS
	SELECT
    QUOTE_LINE_ID,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN,
	  REQUEST_ID,
	  PROGRAM_APPLICATION_ID,
	  PROGRAM_ID,
	  PROGRAM_UPDATE_DATE,
	  QUOTE_HEADER_ID,
	  ORG_ID,
	  LINE_CATEGORY_CODE,
	  ITEM_TYPE_CODE,
	  LINE_NUMBER,
	  START_DATE_ACTIVE,
	  END_DATE_ACTIVE,
	  ORDER_LINE_TYPE_ID,
	  INVOICE_TO_PARTY_SITE_ID,
	  INVOICE_TO_PARTY_ID,
    INVOICE_TO_CUST_ACCOUNT_ID,
	  ORGANIZATION_ID,
	  INVENTORY_ITEM_ID,
	  QUANTITY,
	  UOM_CODE,
	  MARKETING_SOURCE_CODE_ID,
	  PRICE_LIST_ID,
	  PRICE_LIST_LINE_ID,
	  CURRENCY_CODE,
	  LINE_LIST_PRICE,
	  LINE_ADJUSTED_AMOUNT,
	  LINE_ADJUSTED_PERCENT,
	  LINE_QUOTE_PRICE,
	  RELATED_ITEM_ID,
	  ITEM_RELATIONSHIP_TYPE,
	  ACCOUNTING_RULE_ID,
	  INVOICING_RULE_ID,
	   SPLIT_SHIPMENT_FLAG,
	   BACKORDER_FLAG,
           MINISITE_ID,
           SECTION_ID,
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
           --ATTRIBUTE16,
          -- ATTRIBUTE17,
         --  ATTRIBUTE18,
         --  ATTRIBUTE19,
          -- ATTRIBUTE20,
           PRICED_PRICE_LIST_ID,
		 AGREEMENT_ID,
		 COMMITMENT_ID,
		 DISPLAY_ARITHMETIC_OPERATOR,
		 SERVICE_ITEM_FLAG,
		 SERVICEABLE_PRODUCT_FLAG,
		 --SELLING_PRICE_CHANGE,
           --RECALCULATE_FLAG
		 PRICING_LINE_TYPE_INDICATOR,
           END_CUSTOMER_PARTY_ID,
           END_CUSTOMER_PARTY_SITE_ID,
           END_CUSTOMER_CUST_ACCOUNT_ID,
           END_CUSTOMER_CUST_PARTY_ID,
           --CHARGE_PERIODICITY_CODE,
           --SHIP_MODEL_COMPLETE_FLAG,
           OBJECT_VERSION_NUMBER,
		 --CONFIG_MODEL_TYPE
           -- ER 12879412
           PRODUCT_FISC_CLASSIFICATION,
	   TRX_BUSINESS_CATEGORY
        FROM aso_pvt_quote_lines_sort_v
	WHERE quote_header_id = p_qte_header_id;

    l_Qte_Line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_Qte_Line_tbl             ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

BEGIN
      FOR Line_rec IN c_Qte_Line LOOP
	   l_qte_line_rec.QUOTE_LINE_ID := line_rec.QUOTE_LINE_ID;
	   l_qte_line_rec.CREATION_DATE := line_rec.CREATION_DATE;
	   l_qte_line_rec.CREATED_BY := line_rec.CREATED_BY;
	   l_qte_line_rec.LAST_UPDATE_DATE := line_rec.LAST_UPDATE_DATE;
	   l_qte_line_rec.LAST_UPDATED_BY := line_rec.LAST_UPDATED_BY;
	   l_qte_line_rec.LAST_UPDATE_LOGIN := line_rec.LAST_UPDATE_LOGIN;
	   l_qte_line_rec.REQUEST_ID := line_rec.REQUEST_ID;
	   l_qte_line_rec.PROGRAM_APPLICATION_ID := line_rec.PROGRAM_APPLICATION_ID;
	   l_qte_line_rec.PROGRAM_ID := line_rec.PROGRAM_ID;
	   l_qte_line_rec.PROGRAM_UPDATE_DATE := line_rec.PROGRAM_UPDATE_DATE;
	    l_qte_line_rec.quote_header_id := line_rec.quote_header_id;
	    l_qte_line_rec.ORG_ID := line_rec.ORG_ID;
	    l_qte_line_rec.LINE_CATEGORY_CODE := line_rec.LINE_CATEGORY_CODE;
	    l_qte_line_rec.ITEM_TYPE_CODE := line_rec.ITEM_TYPE_CODE;
	    l_qte_line_rec.LINE_NUMBER := line_rec.LINE_NUMBER;
	    l_qte_line_rec.START_DATE_ACTIVE := line_rec.START_DATE_ACTIVE;
	    l_qte_line_rec.END_DATE_ACTIVE := line_rec.END_DATE_ACTIVE;
	    l_qte_line_rec.ORDER_LINE_TYPE_ID := line_rec.ORDER_LINE_TYPE_ID;
	    l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID := line_rec.INVOICE_TO_PARTY_SITE_ID;
	    l_qte_line_rec.INVOICE_TO_PARTY_ID := line_rec.INVOICE_TO_PARTY_ID;
      l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID := line_rec.INVOICE_TO_CUST_ACCOUNT_ID;
	    l_qte_line_rec.ORGANIZATION_ID := line_rec.ORGANIZATION_ID;
	    l_qte_line_rec.INVENTORY_ITEM_ID := line_rec.INVENTORY_ITEM_ID;
	    l_qte_line_rec.QUANTITY := line_rec.QUANTITY;
	    l_qte_line_rec.UOM_CODE := line_rec.UOM_CODE;
	    l_qte_line_rec.MARKETING_SOURCE_CODE_ID := line_rec.MARKETING_SOURCE_CODE_ID;
	    l_qte_line_rec.PRICE_LIST_ID := line_rec.PRICE_LIST_ID;
	    l_qte_line_rec.PRICE_LIST_LINE_ID := line_rec.PRICE_LIST_LINE_ID;
	    l_qte_line_rec.CURRENCY_CODE := line_rec.CURRENCY_CODE;
	    l_qte_line_rec.LINE_LIST_PRICE := line_rec.LINE_LIST_PRICE;
	    l_qte_line_rec.LINE_ADJUSTED_AMOUNT := line_rec.LINE_ADJUSTED_AMOUNT;
	    l_qte_line_rec.LINE_ADJUSTED_PERCENT := line_rec.LINE_ADJUSTED_PERCENT;
	    l_qte_line_rec.LINE_QUOTE_PRICE := line_rec.LINE_QUOTE_PRICE;
	    l_qte_line_rec.RELATED_ITEM_ID := line_rec.RELATED_ITEM_ID;
	    l_qte_line_rec.ITEM_RELATIONSHIP_TYPE := line_rec.ITEM_RELATIONSHIP_TYPE;
	    l_qte_line_rec.ACCOUNTING_RULE_ID := line_rec.ACCOUNTING_RULE_ID;
	    l_qte_line_rec.INVOICING_RULE_ID := line_rec.INVOICING_RULE_ID;
	    l_qte_line_rec.SPLIT_SHIPMENT_FLAG := line_rec.SPLIT_SHIPMENT_FLAG;
	    l_qte_line_rec.BACKORDER_FLAG := line_rec.BACKORDER_FLAG;
	    l_qte_line_rec.MINISITE_ID := line_rec.MINISITE_ID;
	    l_qte_line_rec.SECTION_ID := line_rec.SECTION_ID;
	    l_qte_line_rec.ATTRIBUTE_CATEGORY := line_rec.ATTRIBUTE_CATEGORY;
	    l_qte_line_rec.ATTRIBUTE1 := line_rec.ATTRIBUTE1;
	    l_qte_line_rec.ATTRIBUTE2 := line_rec.ATTRIBUTE2;
	    l_qte_line_rec.ATTRIBUTE3 := line_rec.ATTRIBUTE3;
	    l_qte_line_rec.ATTRIBUTE4 := line_rec.ATTRIBUTE4;
	    l_qte_line_rec.ATTRIBUTE5 := line_rec.ATTRIBUTE5;
	    l_qte_line_rec.ATTRIBUTE6 := line_rec.ATTRIBUTE6;
	    l_qte_line_rec.ATTRIBUTE7 := line_rec.ATTRIBUTE7;
	    l_qte_line_rec.ATTRIBUTE8 := line_rec.ATTRIBUTE8;
	    l_qte_line_rec.ATTRIBUTE9 := line_rec.ATTRIBUTE9;
	    l_qte_line_rec.ATTRIBUTE10 := line_rec.ATTRIBUTE10;
	    l_qte_line_rec.ATTRIBUTE11 := line_rec.ATTRIBUTE11;
	    l_qte_line_rec.ATTRIBUTE12 := line_rec.ATTRIBUTE12;
	    l_qte_line_rec.ATTRIBUTE13 := line_rec.ATTRIBUTE13;
	    l_qte_line_rec.ATTRIBUTE14 := line_rec.ATTRIBUTE14;
	    l_qte_line_rec.ATTRIBUTE15 := line_rec.ATTRIBUTE15;
	    /*l_qte_line_rec.ATTRIBUTE16 := line_rec.ATTRIBUTE16;
	    l_qte_line_rec.ATTRIBUTE17 := line_rec.ATTRIBUTE17;
	    l_qte_line_rec.ATTRIBUTE18 := line_rec.ATTRIBUTE18;
	    l_qte_line_rec.ATTRIBUTE19 := line_rec.ATTRIBUTE19;
	    l_qte_line_rec.ATTRIBUTE20 := line_rec.ATTRIBUTE20;*/
      l_qte_line_rec.PRICED_PRICE_LIST_ID := line_rec.PRICED_PRICE_LIST_ID;
	    l_qte_line_rec.AGREEMENT_ID := line_rec.AGREEMENT_ID;
	    l_qte_line_rec.COMMITMENT_ID := line_rec.COMMITMENT_ID;
	    l_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR := line_rec.DISPLAY_ARITHMETIC_OPERATOR;
	    l_qte_line_rec.service_item_flag := line_rec.service_item_flag;
         l_qte_line_rec.serviceable_product_flag  := line_rec.serviceable_product_flag;
         --l_qte_line_rec.selling_price_change  := line_rec.selling_price_change;
         --l_qte_line_rec.recalculate_flag      := line_rec.recalculate_flag;
         l_qte_line_rec.pricing_line_type_indicator  := line_rec.pricing_line_type_indicator;
         l_qte_line_rec.END_CUSTOMER_PARTY_ID        := line_rec.END_CUSTOMER_PARTY_ID;
         l_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID   := line_rec.END_CUSTOMER_PARTY_SITE_ID;
         l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := line_rec.END_CUSTOMER_CUST_ACCOUNT_ID;
         l_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID   := line_rec.END_CUSTOMER_CUST_PARTY_ID;
        -- l_qte_line_rec.CHARGE_PERIODICITY_CODE      := line_rec.CHARGE_PERIODICITY_CODE;

         --l_qte_line_rec.SHIP_MODEL_COMPLETE_FLAG   := line_rec.SHIP_MODEL_COMPLETE_FLAG;
         l_qte_line_rec.OBJECT_VERSION_NUMBER   := line_rec.OBJECT_VERSION_NUMBER;
         --l_qte_line_rec.CONFIG_MODEL_TYPE   := line_rec.CONFIG_MODEL_TYPE;
	 -- ER 12879412
          l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION := line_rec.PRODUCT_FISC_CLASSIFICATION;
          l_qte_line_rec.TRX_BUSINESS_CATEGORY := line_rec.TRX_BUSINESS_CATEGORY;
         l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;

   END LOOP;

 RETURN l_Qte_Line_tbl;

END Query_Qte_Line_Rows_Sort;

FUNCTION Query_Qte_Line_Rows_atp (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type
IS
    CURSOR c_Qte_Line IS
	SELECT
           QUOTE_LINE_ID,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN,
	  REQUEST_ID,
	  PROGRAM_APPLICATION_ID,
	  PROGRAM_ID,
	  PROGRAM_UPDATE_DATE,
	  QUOTE_HEADER_ID,
	  ORG_ID,
	  LINE_CATEGORY_CODE,
	  ITEM_TYPE_CODE,
	  LINE_NUMBER,
	  START_DATE_ACTIVE,
	  END_DATE_ACTIVE,
	  ORDER_LINE_TYPE_ID,
	  INVOICE_TO_PARTY_SITE_ID,
	  INVOICE_TO_PARTY_ID,
          INVOICE_TO_CUST_ACCOUNT_ID,
	  ORGANIZATION_ID,
	  INVENTORY_ITEM_ID,
	  QUANTITY,
	  UOM_CODE,
	  MARKETING_SOURCE_CODE_ID,
	  PRICE_LIST_ID,
	  PRICE_LIST_LINE_ID,
	  CURRENCY_CODE,
	  LINE_LIST_PRICE,
	  LINE_ADJUSTED_AMOUNT,
	  LINE_ADJUSTED_PERCENT,
	  LINE_QUOTE_PRICE,
	  RELATED_ITEM_ID,
	  ITEM_RELATIONSHIP_TYPE,
	  ACCOUNTING_RULE_ID,
	  INVOICING_RULE_ID,
	   SPLIT_SHIPMENT_FLAG,
	   BACKORDER_FLAG,
           MINISITE_ID,
           SECTION_ID,
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
           ATTRIBUTE15,/*
           ATTRIBUTE16,
           ATTRIBUTE17,
           ATTRIBUTE18,
           ATTRIBUTE19,
           ATTRIBUTE20,*/
           PRICED_PRICE_LIST_ID,
		 AGREEMENT_ID,
		 COMMITMENT_ID,
		 DISPLAY_ARITHMETIC_OPERATOR,
		 SERVICE_ITEM_FLAG,
		 SERVICEABLE_PRODUCT_FLAG,
		 INVOICE_TO_CUST_PARTY_ID,
		 SELLING_PRICE_CHANGE,
		 RECALCULATE_FLAG,
		 PRICING_LINE_TYPE_INDICATOR,
           END_CUSTOMER_PARTY_ID,
           END_CUSTOMER_PARTY_SITE_ID,
           END_CUSTOMER_CUST_ACCOUNT_ID,
           END_CUSTOMER_CUST_PARTY_ID,
           CHARGE_PERIODICITY_CODE ,
           SHIP_MODEL_COMPLETE_FLAG ,
           OBJECT_VERSION_NUMBER,
           UI_LINE_NUMBER,
	    -- ER 12879412
PRODUCT_FISC_CLASSIFICATION,
TRX_BUSINESS_CATEGORY
		 --CONFIG_MODEL_TYPE
	    FROM ASO_PVT_QUOTE_LINES_BALI_V
	WHERE quote_header_id = p_qte_header_id;
    l_Qte_Line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_Qte_Line_tbl             ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
BEGIN
      FOR Line_rec IN c_Qte_Line LOOP
	   l_qte_line_rec.QUOTE_LINE_ID := line_rec.QUOTE_LINE_ID;
	   l_qte_line_rec.CREATION_DATE := line_rec.CREATION_DATE;
	   l_qte_line_rec.CREATED_BY := line_rec.CREATED_BY;
	   l_qte_line_rec.LAST_UPDATE_DATE := line_rec.LAST_UPDATE_DATE;
	   l_qte_line_rec.LAST_UPDATED_BY := line_rec.LAST_UPDATED_BY;
	   l_qte_line_rec.LAST_UPDATE_LOGIN := line_rec.LAST_UPDATE_LOGIN;
	   l_qte_line_rec.REQUEST_ID := line_rec.REQUEST_ID;
	   l_qte_line_rec.PROGRAM_APPLICATION_ID := line_rec.PROGRAM_APPLICATION_ID;
	   l_qte_line_rec.PROGRAM_ID := line_rec.PROGRAM_ID;
	   l_qte_line_rec.PROGRAM_UPDATE_DATE := line_rec.PROGRAM_UPDATE_DATE;
	    l_qte_line_rec.quote_header_id := line_rec.quote_header_id;
	    l_qte_line_rec.ORG_ID := line_rec.ORG_ID;
	    l_qte_line_rec.LINE_CATEGORY_CODE := line_rec.LINE_CATEGORY_CODE;
	    l_qte_line_rec.ITEM_TYPE_CODE := line_rec.ITEM_TYPE_CODE;
	    l_qte_line_rec.LINE_NUMBER := line_rec.LINE_NUMBER;
	    l_qte_line_rec.START_DATE_ACTIVE := line_rec.START_DATE_ACTIVE;
	    l_qte_line_rec.END_DATE_ACTIVE := line_rec.END_DATE_ACTIVE;
	    l_qte_line_rec.ORDER_LINE_TYPE_ID := line_rec.ORDER_LINE_TYPE_ID;
	    l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID := line_rec.INVOICE_TO_PARTY_SITE_ID;
	    l_qte_line_rec.INVOICE_TO_PARTY_ID := line_rec.INVOICE_TO_PARTY_ID;
            l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID := line_rec.INVOICE_TO_CUST_ACCOUNT_ID;
	    l_qte_line_rec.ORGANIZATION_ID := line_rec.ORGANIZATION_ID;
	    l_qte_line_rec.INVENTORY_ITEM_ID := line_rec.INVENTORY_ITEM_ID;
	    l_qte_line_rec.QUANTITY := line_rec.QUANTITY;
	    l_qte_line_rec.UOM_CODE := line_rec.UOM_CODE;
	    l_qte_line_rec.MARKETING_SOURCE_CODE_ID := line_rec.MARKETING_SOURCE_CODE_ID;
	    l_qte_line_rec.PRICE_LIST_ID := line_rec.PRICE_LIST_ID;
	    l_qte_line_rec.PRICE_LIST_LINE_ID := line_rec.PRICE_LIST_LINE_ID;
	    l_qte_line_rec.CURRENCY_CODE := line_rec.CURRENCY_CODE;
	    l_qte_line_rec.LINE_LIST_PRICE := line_rec.LINE_LIST_PRICE;
	    l_qte_line_rec.LINE_ADJUSTED_AMOUNT := line_rec.LINE_ADJUSTED_AMOUNT;
	    l_qte_line_rec.LINE_ADJUSTED_PERCENT := line_rec.LINE_ADJUSTED_PERCENT;
	    l_qte_line_rec.LINE_QUOTE_PRICE := line_rec.LINE_QUOTE_PRICE;
	    l_qte_line_rec.RELATED_ITEM_ID := line_rec.RELATED_ITEM_ID;
	    l_qte_line_rec.ITEM_RELATIONSHIP_TYPE := line_rec.ITEM_RELATIONSHIP_TYPE;
	    l_qte_line_rec.ACCOUNTING_RULE_ID := line_rec.ACCOUNTING_RULE_ID;
	    l_qte_line_rec.INVOICING_RULE_ID := line_rec.INVOICING_RULE_ID;
	    l_qte_line_rec.SPLIT_SHIPMENT_FLAG := line_rec.SPLIT_SHIPMENT_FLAG;
	    l_qte_line_rec.BACKORDER_FLAG := line_rec.BACKORDER_FLAG;
	    l_qte_line_rec.MINISITE_ID := line_rec.MINISITE_ID;
	    l_qte_line_rec.SECTION_ID := line_rec.SECTION_ID;
	    l_qte_line_rec.ATTRIBUTE_CATEGORY := line_rec.ATTRIBUTE_CATEGORY;
	    l_qte_line_rec.ATTRIBUTE1 := line_rec.ATTRIBUTE1;
	    l_qte_line_rec.ATTRIBUTE2 := line_rec.ATTRIBUTE2;
	    l_qte_line_rec.ATTRIBUTE3 := line_rec.ATTRIBUTE3;
	    l_qte_line_rec.ATTRIBUTE4 := line_rec.ATTRIBUTE4;
	    l_qte_line_rec.ATTRIBUTE5 := line_rec.ATTRIBUTE5;
	    l_qte_line_rec.ATTRIBUTE6 := line_rec.ATTRIBUTE6;
	    l_qte_line_rec.ATTRIBUTE7 := line_rec.ATTRIBUTE7;
	    l_qte_line_rec.ATTRIBUTE8 := line_rec.ATTRIBUTE8;
	    l_qte_line_rec.ATTRIBUTE9 := line_rec.ATTRIBUTE9;
	    l_qte_line_rec.ATTRIBUTE10 := line_rec.ATTRIBUTE10;
	    l_qte_line_rec.ATTRIBUTE11 := line_rec.ATTRIBUTE11;
	    l_qte_line_rec.ATTRIBUTE12 := line_rec.ATTRIBUTE12;
	    l_qte_line_rec.ATTRIBUTE13 := line_rec.ATTRIBUTE13;
	    l_qte_line_rec.ATTRIBUTE14 := line_rec.ATTRIBUTE14;
	    l_qte_line_rec.ATTRIBUTE15 := line_rec.ATTRIBUTE15;
	    /*l_qte_line_rec.ATTRIBUTE16 := line_rec.ATTRIBUTE16;
	    l_qte_line_rec.ATTRIBUTE17 := line_rec.ATTRIBUTE17;
	    l_qte_line_rec.ATTRIBUTE18 := line_rec.ATTRIBUTE18;
	    l_qte_line_rec.ATTRIBUTE19 := line_rec.ATTRIBUTE19;
	    l_qte_line_rec.ATTRIBUTE20 := line_rec.ATTRIBUTE20;*/
   	    l_qte_line_rec.PRICED_PRICE_LIST_ID := line_rec.PRICED_PRICE_LIST_ID;
	    l_qte_line_rec.AGREEMENT_ID := line_rec.AGREEMENT_ID;
	    l_qte_line_rec.COMMITMENT_ID := line_rec.COMMITMENT_ID;
	    l_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR := line_rec.DISPLAY_ARITHMETIC_OPERATOR;
	    l_qte_line_rec.service_item_flag := line_rec.service_item_flag;
         l_qte_line_rec.serviceable_product_flag  := line_rec.serviceable_product_flag;
         l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID  := line_rec.INVOICE_TO_CUST_PARTY_ID;
         l_qte_line_rec.SELLING_PRICE_CHANGE      := line_rec.SELLING_PRICE_CHANGE;
         l_qte_line_rec.RECALCULATE_FLAG          := line_rec.RECALCULATE_FLAG;
         l_qte_line_rec.PRICING_LINE_TYPE_INDICATOR  := line_rec.PRICING_LINE_TYPE_INDICATOR;
         l_qte_line_rec.END_CUSTOMER_PARTY_ID        := line_rec.END_CUSTOMER_PARTY_ID;
         l_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID   := line_rec.END_CUSTOMER_PARTY_SITE_ID;
         l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := line_rec.END_CUSTOMER_CUST_ACCOUNT_ID;
         l_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID   := line_rec.END_CUSTOMER_CUST_PARTY_ID;
         l_qte_line_rec.CHARGE_PERIODICITY_CODE := line_rec.CHARGE_PERIODICITY_CODE; -- Recurring charges Change
         l_qte_line_rec.SHIP_MODEL_COMPLETE_FLAG   := line_rec.SHIP_MODEL_COMPLETE_FLAG;
         l_qte_line_rec.OBJECT_VERSION_NUMBER   := line_rec.OBJECT_VERSION_NUMBER;
	    l_qte_line_rec.ui_line_number := line_rec.ui_line_number;
	      -- ER 12879412
            l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION :=  line_rec.PRODUCT_FISC_CLASSIFICATION;
            l_qte_line_rec.TRX_BUSINESS_CATEGORY := line_rec.TRX_BUSINESS_CATEGORY;

         --l_qte_line_rec.CONFIG_MODEL_TYPE := line_rec.CONFIG_MODEL_TYPE;
         l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
      END LOOP;
      RETURN l_Qte_Line_tbl;
END Query_Qte_Line_Rows_atp;


-- New Function for Pricing Starts Here...................................


FUNCTION Query_Pricing_Line_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_change_line_flag   IN  VARCHAR2 := FND_API.G_FALSE
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type
IS
    CURSOR c_Qte_Line IS
	SELECT
       QUOTE_LINE_ID,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN,
	  REQUEST_ID,
	  PROGRAM_APPLICATION_ID,
	  PROGRAM_ID,
	  PROGRAM_UPDATE_DATE,
	  QUOTE_HEADER_ID,
	  ORG_ID,
	  LINE_CATEGORY_CODE,
	  ITEM_TYPE_CODE,
	  LINE_NUMBER,
	  START_DATE_ACTIVE,
	  END_DATE_ACTIVE,
	  ORDER_LINE_TYPE_ID,
	  INVOICE_TO_PARTY_SITE_ID,
	  INVOICE_TO_PARTY_ID,
       INVOICE_TO_CUST_ACCOUNT_ID,
	  ORGANIZATION_ID,
	  INVENTORY_ITEM_ID,
	  QUANTITY,
	  UOM_CODE,
	  MARKETING_SOURCE_CODE_ID,
	  PRICE_LIST_ID,
	  PRICE_LIST_LINE_ID,
	  CURRENCY_CODE,
	  LINE_LIST_PRICE,
	  LINE_ADJUSTED_AMOUNT,
	  LINE_ADJUSTED_PERCENT,
	  LINE_QUOTE_PRICE,
	  RELATED_ITEM_ID,
	  ITEM_RELATIONSHIP_TYPE,
	  ACCOUNTING_RULE_ID,
	  INVOICING_RULE_ID,
	  SPLIT_SHIPMENT_FLAG,
	  BACKORDER_FLAG,
       MINISITE_ID,
       SECTION_ID,
	  INVOICE_TO_CUST_PARTY_ID,
	  RECALCULATE_FLAG,
	  SELLING_PRICE_CHANGE,
	  SERVICE_ITEM_FLAG,
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
       PRICED_PRICE_LIST_ID,
	  AGREEMENT_ID,
	  COMMITMENT_ID,
	  DISPLAY_ARITHMETIC_OPERATOR,
       PRICING_LINE_TYPE_INDICATOR,
       END_CUSTOMER_PARTY_ID,
       END_CUSTOMER_PARTY_SITE_ID,
       END_CUSTOMER_CUST_ACCOUNT_ID,
       END_CUSTOMER_CUST_PARTY_ID,
	  SHIP_MODEL_COMPLETE_FLAG,
	  CHARGE_PERIODICITY_CODE,
	  PRICING_QUANTITY_UOM,
	  PRICING_QUANTITY,
	  OBJECT_VERSION_NUMBER,
	    -- ER 12879412
         PRODUCT_FISC_CLASSIFICATION,
         TRX_BUSINESS_CATEGORY,
		 ORDERED_ITEM_ID,
		 ITEM_IDENTIFIER_TYPE,
		 ORDERED_ITEM
--		 UNIT_PRICE -- bug 17517305

   FROM ASO_Quote_Lines_All
   WHERE quote_header_id = p_qte_header_id
   ORDER BY Line_Number;

    CURSOR c_Qte_Line_SVC_ref(p_qte_line_id IN NUMBER) IS
         SELECT service_ref_type_code , service_ref_line_id
	 FROM   ASO_QUOTE_LINE_DETAILS
	 WHERE  quote_line_id = p_qte_line_id;

    CURSOR c_order_line (p_order_line_id IN NUMBER) IS
	 SELECT line_id, inventory_item_id, pricing_quantity, pricing_quantity_uom,
		unit_list_price, price_list_id, charge_periodicity_code,UNIT_LIST_PRICE_PER_PQTY -- bug 17517305
	 FROM OE_ORDER_LINES_ALL
	 WHERE line_id = p_order_line_id;

	 /* Cursors used for the customer_products*/

	 /*CURSOR c_get_cust_acct_id IS
	 SELECT cust_account_id
	 FROM ASO_QUOTE_HEADERS_ALL
	 WHERE quote_header_id = p_qte_header_id;
         */
      CURSOR c_get_orig_order_line_id(p_instance_id IN NUMBER, p_cust_account_id NUMBER) IS
      SELECT   original_order_line_id
      FROM     csi_instance_accts_rg_v
      WHERE    customer_product_id = p_instance_id
      AND      account_id          = p_cust_account_id;

       /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
       CURSOR c_get_cust_acct_id IS
	 select decode(nvl(fnd_profile.value('ASO_FILTER_SERVICE_RF_END_CUST'),'N'),'Y',nvl(END_CUSTOMER_CUST_ACCOUNT_ID,cust_account_id),cust_account_id) cust_account_id
         from ASO_QUOTE_HEADERS_ALL
         WHERE quote_header_id = p_qte_header_id;

	 CURSOR c_get_cust_acct_id_ln(p_qte_line_id number) IS
	 select decode(nvl(fnd_profile.value('ASO_FILTER_SERVICE_RF_END_CUST'),'N'),'Y',END_CUSTOMER_CUST_ACCOUNT_ID)
         from ASO_QUOTE_LINES_ALL
         WHERE quote_line_id = p_qte_line_id;

	 cursor c_get_price_list(p_qte_hdr_id number) is
		select  price_list_id
		from    aso_quote_headers_all
		where   quote_header_id = p_qte_hdr_id;


         l_cust_account_id number;
     /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/

     /******* Start SUN Changes ER: 3802859 *******/

    l_order_found BOOLEAN := FALSE;

     -- changed cursor for bug 12839557
     CURSOR c_csi_line_details(p_instance_id IN NUMBER, p_cust_account_id NUMBER) IS
     SELECT si.concatenated_segments product, si.inventory_item_id, cii.quantity, cii.unit_of_measure
	FROM mtl_system_items_kfv si, csi_item_instances cii
	WHERE NVL(cii.active_end_date, (SYSDATE + 1)) > SYSDATE
	AND cii.inventory_item_id = si.inventory_item_id
	AND si.organization_id = cii.inv_master_organization_id
	AND cii.instance_id =p_instance_id;

	/* SELECT   distinct a.product,b.inventory_item_id,a.quantity,a.unit_of_measure_code
	 FROM     csi_instance_accts_rg_v a ,mtl_system_items_vl  b
      where    a.product = b.concatenated_segments
	 AND      a.customer_product_id = p_instance_id;
	 --AND      a.account_id          = p_cust_account_id;
      */
     l_prod     varchar2(1000);
     l_item_id  number;
     l_qty      number;
     l_uom      varchar2(30);

/******* Start SUN Changes ER: 3802859 *******/


    l_service_item_flag        MTL_SYSTEM_ITEMS_VL.SERVICE_ITEM_FLAG%TYPE;
    l_ref_type_code            ASO_QUOTE_LINE_DETAILS.SERVICE_REF_TYPE_CODE%TYPE;
    l_service_ref_line_id      ASO_QUOTE_LINE_DETAILS.SERVICE_REF_LINE_ID%TYPE;

    l_Qte_Line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_Qte_Line_tbl             ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_service_ref_line_id_tbl  Index_Link_Tbl_Type;
    l_order_ref_line_id_tbl    Index_Link_Tbl_Type;

BEGIN

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_UTL_PVT: Start Query Pricing Line Rows p_qte_header_id: '||p_qte_header_id,1,'Y');
     END IF;

     FOR c_qte_line_rec IN c_Qte_Line LOOP
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.add('ASO_UTL_PVT: Inside c_qte_line_rec with c_qte_line_rec.quote_line_id: '
		                      ||c_qte_line_rec.quote_line_id,1,'Y');
             aso_debug_pub.add('ASO_UTL_PVT: Inside c_qte_line_rec with c_qte_line_rec.service_item_flag: '
		                      ||c_qte_line_rec.service_item_flag,1,'Y');
		END IF;

	     IF  NVL(c_qte_line_rec.service_item_flag,'N') = 'Y' THEN
		     OPEN c_qte_line_SVC_ref(c_qte_line_rec.quote_line_id);
		     FETCH c_qte_line_SVC_ref INTO l_ref_type_code, l_service_ref_line_id;
               CLOSE c_qte_line_SVC_ref;
     		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('ASO_UTL_PVT: Parent Service Line collection ... ',1,'Y');
               END IF;

	 	     IF l_ref_type_code = 'ORDER' THEN
		        IF l_order_ref_line_id_tbl.exists(l_service_ref_line_id) THEN
     		      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                        aso_debug_pub.add('ASO_UTL_PVT: Parent Order Line has already been added to l_qte_line_tbl.',1,'Y');
     		      END IF;
		        ELSE
		        FOR c_order_line_rec IN c_order_line(l_service_ref_line_id) LOOP
			       l_order_ref_line_id_tbl(l_service_ref_line_id) := l_service_ref_line_id;
                      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    			          aso_debug_pub.add('ASO_UTL_PVT: Parent Order Line has not yet been added to l_qte_line_tbl.', 1, 'N');
                         aso_debug_pub.add('ASO_UTL_PVT: l_service_ref_line_id_tbl('||l_service_ref_line_id||').:'
                                            ||NVL(to_char(l_order_ref_line_id_tbl(l_service_ref_line_id)),'null'),1,'Y');
			       END IF;
			       l_qte_line_rec.QUOTE_LINE_ID := c_order_line_rec.LINE_ID;
			       l_qte_line_rec.INVENTORY_ITEM_ID := c_order_line_rec.INVENTORY_ITEM_ID;
			       l_qte_line_rec.QUANTITY := c_order_line_rec.PRICING_QUANTITY;
			       l_qte_line_rec.UOM_CODE := c_order_line_rec.PRICING_QUANTITY_UOM;
			       l_qte_line_rec.PRICE_LIST_ID := c_order_line_rec.PRICE_LIST_ID;
			       l_qte_line_rec.LINE_LIST_PRICE := c_order_line_rec.UNIT_LIST_PRICE;
			    --    l_qte_line_rec.UNIT_PRICE := c_order_line_rec.UNIT_LIST_PRICE_PER_PQTY; -- bug 17517305
			       l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_ORDER_LINE';
			       l_qte_line_rec.CHARGE_PERIODICITY_CODE := c_order_line_rec.CHARGE_PERIODICITY_CODE;

                      l_qte_line_rec.PRICING_QUANTITY := c_order_line_rec.PRICING_QUANTITY;
                      l_qte_line_rec.PRICING_QUANTITY_UOM := c_order_line_rec.PRICING_QUANTITY_UOM;
				  l_qte_line_rec.IS_LINE_CHANGED_FLAG := 'Y';
				  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				      aso_debug_pub.add('ASO_UTL_PVT:P_change_line_flag:'||P_change_line_flag,1,'Y');
				  END IF;
                      If P_change_line_flag = FND_API.G_FALSE Then
	  		          l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
				  else
				     l_Qte_Line_tbl(l_qte_line_rec.QUOTE_LINE_ID) := l_Qte_Line_rec;
				  end if;
    			       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    			          aso_debug_pub.add('Order Line  Count'|| l_Qte_line_tbl.COUNT, 1, 'N');
    			       END IF;

		        END LOOP;
		     END IF;--l_order_ref_line_id_tbl.exists(l_service_ref_line_id)
		   ELSIF l_ref_type_code = 'CUSTOMER_PRODUCT' THEN
		     IF l_service_ref_line_id_tbl.exists(l_service_ref_line_id) THEN
     		   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('ASO_UTL_PVT: Parent Instance Line has already been added to l_qte_line_tbl.',1,'Y');
     		   END IF;
		     ELSE
     	         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('ASO_UTL_PVT: Before customer install processing:',1,'Y');
     	         END IF;
                   /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
                   --FOR c_get_cust_acct_id_rec IN c_get_cust_acct_id LOOP
		   open c_get_cust_acct_id_ln(c_qte_line_rec.quote_line_id);
		   fetch c_get_cust_acct_id_ln into l_cust_account_id;
		   if (c_get_cust_acct_id_ln%NOTFOUND) or (l_cust_account_id is null) THEN
			open c_get_cust_acct_id;
			fetch c_get_cust_acct_id into l_cust_account_id;
			if c_get_cust_acct_id%NOTFOUND THEN
				l_cust_account_id:=NULL;
			end if;
			close c_get_cust_acct_id;
		   end if;
		   close c_get_cust_acct_id_ln;
     		      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                        aso_debug_pub.add('ASO_UTL_PVT: l_cust_account_id:'||l_cust_account_id,1,'Y');

     		      END IF;
                   /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
                     l_service_ref_line_id_tbl(l_service_ref_line_id) := l_service_ref_line_id;

                     For c_get_orig_order_line_id_rec IN c_get_orig_order_line_id(l_service_ref_line_id,l_cust_account_id) LOOP

		      l_order_found := FALSE;  -- fix for bug Bug 9724104

     		        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    			           aso_debug_pub.add('ASO_UTL_PVT: Parent Instance Line has not yet been added to l_qte_line_tbl.', 1, 'N');
                          aso_debug_pub.add('ASO_UTL_PVT: l_service_ref_line_id_tbl('||l_service_ref_line_id||').:'
			                               ||NVL(to_char(l_service_ref_line_id_tbl(l_service_ref_line_id)),'null'),1,'Y');
			        END IF;

		             FOR c_order_line_rec IN c_order_line(c_get_orig_order_line_id_rec.original_order_line_id) LOOP
                                    l_order_found := TRUE;
			            l_qte_line_rec.QUOTE_LINE_ID := l_service_ref_line_id;
			            l_qte_line_rec.INVENTORY_ITEM_ID := c_order_line_rec.INVENTORY_ITEM_ID;
			            l_qte_line_rec.QUANTITY := c_order_line_rec.PRICING_QUANTITY;
			            l_qte_line_rec.UOM_CODE := c_order_line_rec.PRICING_QUANTITY_UOM;
			            l_qte_line_rec.PRICE_LIST_ID := c_order_line_rec.PRICE_LIST_ID;
			            l_qte_line_rec.LINE_LIST_PRICE := c_order_line_rec.UNIT_LIST_PRICE;
--				     l_qte_line_rec.UNIT_PRICE := c_order_line_rec.UNIT_LIST_PRICE_PER_PQTY;  -- bug 17517305
			            l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_CUSTOMER_LINE';
					  l_qte_line_rec.CHARGE_PERIODICITY_CODE := c_order_line_rec.CHARGE_PERIODICITY_CODE;

                                    l_qte_line_rec.PRICING_QUANTITY := c_order_line_rec.PRICING_QUANTITY;
                                    l_qte_line_rec.PRICING_QUANTITY_UOM := c_order_line_rec.PRICING_QUANTITY_UOM;
					  l_qte_line_rec.IS_LINE_CHANGED_FLAG := 'Y';
				       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				           aso_debug_pub.add('ASO_UTL_PVT:P_change_line_flag:'||P_change_line_flag,1,'Y');
				       END IF;
                                      If P_change_line_flag = FND_API.G_FALSE Then
	  		               l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
				       else
				          l_Qte_Line_tbl(l_qte_line_rec.QUOTE_LINE_ID) := l_Qte_Line_rec;
				       end if;
    			            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    			               aso_debug_pub.add('Instance Line Count '|| l_Qte_line_tbl.COUNT, 1, 'N');
    			            END IF;

		            END LOOP;




		    /****** Start SUN Changes ER:3802859 *******/

                    IF l_order_found = FALSE THEN -- this means no order line was found then

                         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  				    aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** Inside new condition', 1, 'N');
				    aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** l_service_ref_line_id: '|| l_service_ref_line_id, 1, 'N');
				    aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** l_cust_account_id: '|| l_cust_account_id, 1, 'N');
				 END IF;

                       open c_csi_line_details(l_service_ref_line_id,l_cust_account_id);
                       fetch c_csi_line_details into l_prod,l_item_id,l_qty,l_uom;

                       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			   aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** After fetching the csi line details', 1, 'N');
		       END IF;

			l_qte_line_rec.QUOTE_LINE_ID := l_service_ref_line_id;
			l_qte_line_rec.INVENTORY_ITEM_ID := l_item_id;
			l_qte_line_rec.QUANTITY := l_qty;
			l_qte_line_rec.UOM_CODE := l_uom;

                        -- get the price list from the header
                        open c_get_price_list(p_qte_header_id);
                        fetch c_get_price_list INTO l_qte_line_rec.PRICE_LIST_ID;
                        CLOSE c_get_price_list;

			l_qte_line_rec.LINE_LIST_PRICE := 0;
--			l_qte_line_rec.UNIT_PRICE := 0; -- bug 17517305
			l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_CUSTOMER_LINE';

                        --l_qte_line_rec.CHARGE_PERIODICITY_CODE := c_order_line_rec.CHARGE_PERIODICITY_CODE;

                        l_qte_line_rec.PRICING_QUANTITY := l_qty;
                        l_qte_line_rec.PRICING_QUANTITY_UOM := l_UOM;
                        l_qte_line_rec.IS_LINE_CHANGED_FLAG := 'Y';
			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			   aso_debug_pub.add('ASO_UTL_PVT:P_change_line_flag:'||P_change_line_flag,1,'Y');
			END IF;
                        If P_change_line_flag = FND_API.G_FALSE Then
	  		     l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
			else
			    l_Qte_Line_tbl(l_qte_line_rec.QUOTE_LINE_ID) := l_Qte_Line_rec;
			end if;
    			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    			               aso_debug_pub.add('Instance Line Count '|| l_Qte_line_tbl.COUNT, 1, 'N');
    			END IF;

			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ******  l_service_ref_line_id: '|| l_service_ref_line_id, 1, 'N');
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ******  l_item_id: '|| l_item_id, 1, 'N');
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ******  l_qty: '|| l_qty, 1, 'N');
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ******  l_uom: '|| l_uom, 1, 'N');
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** l_qte_line_rec.PRICE_LIST_ID: '||l_qte_line_rec.PRICE_LIST_ID, 1, 'N');
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** Instance Line Count: '|| NVL(l_Qte_line_tbl.COUNT,0), 1, 'N');
			END IF;

                       close c_csi_line_details;
                    END IF;

/******* End SUN Changes ER:3802859 *******/
                  END LOOP;
                  --END LOOP;

		     END IF;--l_service_ref_line_id_tbl.exists(l_service_ref_line_id)
                /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
		ELSIF l_ref_type_code = 'PRODUCT_CATALOG' THEN
		  IF l_service_ref_line_id_tbl.exists(l_service_ref_line_id) THEN
     			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('ASO_UTL_PVT: Parent Instance Line has already been added to l_qte_line_tbl.',1,'Y');
     			END IF;
                  ELSE
	           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_UTL_PVT:  **** ER: II****** Before product catalog processing:',1,'Y');
		   END IF;


	           l_service_ref_line_id_tbl(l_service_ref_line_id) := l_service_ref_line_id;
	           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('ASO_UTL_PVT: **** **** ER: II****** ****** Inside new condition', 1, 'N');
                     aso_debug_pub.add('ASO_UTL_PVT: ****  **** ER: II****** ****** l_service_ref_line_id: '|| l_service_ref_line_id, 1, 'N');

	           END IF;

	           l_qte_line_rec.QUOTE_LINE_ID := l_service_ref_line_id;       --c_qte_line_rec.QUOTE_LINE_ID;
	           l_qte_line_rec.INVENTORY_ITEM_ID := l_service_ref_line_id;
	           l_qte_line_rec.QUANTITY := c_qte_line_rec.pricing_QUANTITY;
	           l_qte_line_rec.UOM_CODE := c_qte_line_rec.PRICING_QUANTITY_UOM;
                   -- get the price list from the header
	           open c_get_price_list(p_qte_header_id);
		   fetch c_get_price_list INTO l_qte_line_rec.PRICE_LIST_ID;
	           CLOSE c_get_price_list;

		   l_qte_line_rec.LINE_LIST_PRICE := 0;
--		   l_qte_line_rec.UNIT_PRICE := 0; -- bug 17517305
		   l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_CUSTOMER_LINE';
		   l_qte_line_rec.PRICING_QUANTITY := c_qte_line_rec.PRICING_QUANTITY;
                   l_qte_line_rec.PRICING_QUANTITY_UOM := c_qte_line_rec.PRICING_QUANTITY_UOM;
		   l_qte_line_rec.IS_LINE_CHANGED_FLAG := 'Y';

		   If P_change_line_flag = FND_API.G_FALSE Then
	  	      l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
		   else
		      l_Qte_Line_tbl(l_qte_line_rec.QUOTE_LINE_ID) := l_Qte_Line_rec;
		   end if;
    		   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    		        aso_debug_pub.add('Instance Line Count '|| l_Qte_line_tbl.COUNT, 1, 'N');
    		   END IF;



	           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                   aso_debug_pub.add('ASO_UTL_PVT: **** ER: II******  l_service_ref_line_id: '|| l_service_ref_line_id, 1, 'N');
                   aso_debug_pub.add('ASO_UTL_PVT: **** ER:II ******  l_item_id: '|| l_qte_line_rec.INVENTORY_ITEM_ID , 1, 'N');
                   aso_debug_pub.add('ASO_UTL_PVT: **** ER:II ******  l_qty: '|| l_qte_line_rec.QUANTITY , 1, 'N');
                   aso_debug_pub.add('ASO_UTL_PVT: **** ER:II ******  l_uom: '|| l_qte_line_rec.UOM_CODE, 1, 'N');
                   aso_debug_pub.add('ASO_UTL_PVT: **** ER:II ****** l_qte_line_rec.PRICE_LIST_ID: '||l_qte_line_rec.PRICE_LIST_ID, 1, 'N');
                   aso_debug_pub.add('ASO_UTL_PVT: **** ER:II ****** Instance Line Count: '|| NVL(l_Qte_line_tbl.COUNT,0), 1, 'N');
                   END IF;
                 END IF;--l_service_ref_line_id_tbl.exists(l_service_ref_line_id)

             END IF;--elsif l_ref_type_code = 'PRODUCT_CATALOG'

             --END IF;--elsif l_ref_type_code = 'CUSTOMER_PRODUCT'
          /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
          END IF; /* Service Item Flag Check */

	     l_qte_line_rec.QUOTE_LINE_ID := c_qte_line_rec.QUOTE_LINE_ID;
	     l_qte_line_rec.CREATION_DATE := c_qte_line_rec.CREATION_DATE;
	     l_qte_line_rec.CREATED_BY := c_qte_line_rec.CREATED_BY;
	     l_qte_line_rec.LAST_UPDATE_DATE := c_qte_line_rec.LAST_UPDATE_DATE;
	     l_qte_line_rec.LAST_UPDATED_BY := c_qte_line_rec.LAST_UPDATED_BY;
	     l_qte_line_rec.LAST_UPDATE_LOGIN := c_qte_line_rec.LAST_UPDATE_LOGIN;
	     l_qte_line_rec.REQUEST_ID := c_qte_line_rec.REQUEST_ID;
	     l_qte_line_rec.PROGRAM_APPLICATION_ID := c_qte_line_rec.PROGRAM_APPLICATION_ID;
	     l_qte_line_rec.PROGRAM_ID := c_qte_line_rec.PROGRAM_ID;
	     l_qte_line_rec.PROGRAM_UPDATE_DATE := c_qte_line_rec.PROGRAM_UPDATE_DATE;
	     l_qte_line_rec.quote_header_id := c_qte_line_rec.quote_header_id;
	     l_qte_line_rec.ORG_ID := c_qte_line_rec.ORG_ID;
	     l_qte_line_rec.LINE_CATEGORY_CODE := c_qte_line_rec.LINE_CATEGORY_CODE;
	     l_qte_line_rec.ITEM_TYPE_CODE := c_qte_line_rec.ITEM_TYPE_CODE;
	     l_qte_line_rec.LINE_NUMBER := c_qte_line_rec.LINE_NUMBER;
	     l_qte_line_rec.START_DATE_ACTIVE := c_qte_line_rec.START_DATE_ACTIVE;
	     l_qte_line_rec.END_DATE_ACTIVE := c_qte_line_rec.END_DATE_ACTIVE;
	     l_qte_line_rec.ORDER_LINE_TYPE_ID := c_qte_line_rec.ORDER_LINE_TYPE_ID;
	     l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID := c_qte_line_rec.INVOICE_TO_PARTY_SITE_ID;
	     l_qte_line_rec.INVOICE_TO_PARTY_ID := c_qte_line_rec.INVOICE_TO_PARTY_ID;
          l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID := c_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID;
	     l_qte_line_rec.ORGANIZATION_ID := c_qte_line_rec.ORGANIZATION_ID;
	     l_qte_line_rec.INVENTORY_ITEM_ID := c_qte_line_rec.INVENTORY_ITEM_ID;
	     l_qte_line_rec.QUANTITY := c_qte_line_rec.QUANTITY;
	     l_qte_line_rec.UOM_CODE := c_qte_line_rec.UOM_CODE;
	     l_qte_line_rec.MARKETING_SOURCE_CODE_ID := c_qte_line_rec.MARKETING_SOURCE_CODE_ID;
	     l_qte_line_rec.PRICE_LIST_ID := c_qte_line_rec.PRICE_LIST_ID;
	     l_qte_line_rec.PRICE_LIST_LINE_ID := c_qte_line_rec.PRICE_LIST_LINE_ID;
	     l_qte_line_rec.CURRENCY_CODE := c_qte_line_rec.CURRENCY_CODE;
	     l_qte_line_rec.LINE_LIST_PRICE := c_qte_line_rec.LINE_LIST_PRICE;
--	     l_qte_line_rec.UNIT_PRICE := c_qte_line_rec.UNIT_PRICE;  -- bug 17517305
	     l_qte_line_rec.LINE_ADJUSTED_AMOUNT := c_qte_line_rec.LINE_ADJUSTED_AMOUNT;
	     l_qte_line_rec.LINE_ADJUSTED_PERCENT := c_qte_line_rec.LINE_ADJUSTED_PERCENT;
	     l_qte_line_rec.LINE_QUOTE_PRICE := c_qte_line_rec.LINE_QUOTE_PRICE;
	     l_qte_line_rec.RELATED_ITEM_ID := c_qte_line_rec.RELATED_ITEM_ID;
	     l_qte_line_rec.ITEM_RELATIONSHIP_TYPE := c_qte_line_rec.ITEM_RELATIONSHIP_TYPE;
	     l_qte_line_rec.ACCOUNTING_RULE_ID := c_qte_line_rec.ACCOUNTING_RULE_ID;
	     l_qte_line_rec.INVOICING_RULE_ID := c_qte_line_rec.INVOICING_RULE_ID;
	     l_qte_line_rec.SPLIT_SHIPMENT_FLAG := c_qte_line_rec.SPLIT_SHIPMENT_FLAG;
	     l_qte_line_rec.BACKORDER_FLAG := c_qte_line_rec.BACKORDER_FLAG;
	     l_qte_line_rec.MINISITE_ID := c_qte_line_rec.MINISITE_ID;
	     l_qte_line_rec.SECTION_ID := c_qte_line_rec.SECTION_ID;
          l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID:= c_qte_line_rec.INVOICE_TO_CUST_PARTY_ID;
          l_qte_line_rec.RECALCULATE_FLAG := c_qte_line_rec.RECALCULATE_FLAG;
          l_qte_line_rec.SELLING_PRICE_CHANGE := c_qte_line_rec.SELLING_PRICE_CHANGE;
	     l_qte_line_rec.service_item_flag   := c_qte_line_rec.service_item_flag;
	     l_qte_line_rec.ATTRIBUTE_CATEGORY := c_qte_line_rec.ATTRIBUTE_CATEGORY;
	     l_qte_line_rec.ATTRIBUTE1 := c_qte_line_rec.ATTRIBUTE1;
	     l_qte_line_rec.ATTRIBUTE2 := c_qte_line_rec.ATTRIBUTE2;
	     l_qte_line_rec.ATTRIBUTE3 := c_qte_line_rec.ATTRIBUTE3;
	     l_qte_line_rec.ATTRIBUTE4 := c_qte_line_rec.ATTRIBUTE4;
	     l_qte_line_rec.ATTRIBUTE5 := c_qte_line_rec.ATTRIBUTE5;
	     l_qte_line_rec.ATTRIBUTE6 := c_qte_line_rec.ATTRIBUTE6;
	     l_qte_line_rec.ATTRIBUTE7 := c_qte_line_rec.ATTRIBUTE7;
	     l_qte_line_rec.ATTRIBUTE8 := c_qte_line_rec.ATTRIBUTE8;
	     l_qte_line_rec.ATTRIBUTE9 := c_qte_line_rec.ATTRIBUTE9;
	     l_qte_line_rec.ATTRIBUTE10 := c_qte_line_rec.ATTRIBUTE10;
	     l_qte_line_rec.ATTRIBUTE11 := c_qte_line_rec.ATTRIBUTE11;
	     l_qte_line_rec.ATTRIBUTE12 := c_qte_line_rec.ATTRIBUTE12;
	     l_qte_line_rec.ATTRIBUTE13 := c_qte_line_rec.ATTRIBUTE13;
	     l_qte_line_rec.ATTRIBUTE14 := c_qte_line_rec.ATTRIBUTE14;
	     l_qte_line_rec.ATTRIBUTE15 := c_qte_line_rec.ATTRIBUTE15;
	     l_qte_line_rec.ATTRIBUTE16 := c_qte_line_rec.ATTRIBUTE16;
	     l_qte_line_rec.ATTRIBUTE17 := c_qte_line_rec.ATTRIBUTE17;
	     l_qte_line_rec.ATTRIBUTE18 := c_qte_line_rec.ATTRIBUTE18;
	     l_qte_line_rec.ATTRIBUTE19 := c_qte_line_rec.ATTRIBUTE19;
	     l_qte_line_rec.ATTRIBUTE20 := c_qte_line_rec.ATTRIBUTE20;
   	     l_qte_line_rec.PRICED_PRICE_LIST_ID := c_qte_line_rec.PRICED_PRICE_LIST_ID;
	     l_qte_line_rec.AGREEMENT_ID := c_qte_line_rec.AGREEMENT_ID;
	     l_qte_line_rec.COMMITMENT_ID := c_qte_line_rec.COMMITMENT_ID;
	     l_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR := c_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR;
	     l_qte_line_rec.PRICING_LINE_TYPE_INDICATOR   := c_qte_line_rec.PRICING_LINE_TYPE_INDICATOR;
          l_qte_line_rec.END_CUSTOMER_PARTY_ID        := c_qte_line_rec.END_CUSTOMER_PARTY_ID;
          l_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID   := c_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID;
          l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := c_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID;
          l_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID   := c_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID;
          l_qte_line_rec.SHIP_MODEL_COMPLETE_FLAG := c_qte_line_rec.SHIP_MODEL_COMPLETE_FLAG;
          l_qte_line_rec.CHARGE_PERIODICITY_CODE := c_qte_line_rec.CHARGE_PERIODICITY_CODE;
          l_qte_line_rec.PRICING_QUANTITY_UOM := c_qte_line_rec.PRICING_QUANTITY_UOM;
          l_qte_line_rec.PRICING_QUANTITY := c_qte_line_rec.PRICING_QUANTITY;
          l_qte_line_rec.OBJECT_VERSION_NUMBER := c_qte_line_rec.OBJECT_VERSION_NUMBER;
	    -- ER 12879412
            l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION :=  c_qte_line_rec.PRODUCT_FISC_CLASSIFICATION;
            l_qte_line_rec.TRX_BUSINESS_CATEGORY := c_qte_line_rec.TRX_BUSINESS_CATEGORY;

		l_qte_line_rec.IS_LINE_CHANGED_FLAG := 'Y';
	     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	        aso_debug_pub.add('ASO_UTL_PVT:P_change_line_flag:'||P_change_line_flag,1,'Y');
	     END IF;
          If P_change_line_flag = FND_API.G_FALSE Then
	        l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
	     else
	        l_Qte_Line_tbl(l_qte_line_rec.QUOTE_LINE_ID) := l_Qte_Line_rec;
	     end if;

    	     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    	       aso_debug_pub.add('Quote Line Count'|| l_Qte_line_tbl.COUNT, 1, 'N');
    	     END IF;
         END LOOP;
      RETURN l_Qte_Line_tbl;

END Query_Pricing_Line_Rows;

-- New Function for Pricing Ends Here...................................

-- New Function for Pricing Line Row Starts Here...................................


FUNCTION Query_Pricing_Line_Row (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id               IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type
IS
    CURSOR c_Qte_Line IS
	SELECT
       QUOTE_LINE_ID,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN,
	  REQUEST_ID,
	  PROGRAM_APPLICATION_ID,
	  PROGRAM_ID,
	  PROGRAM_UPDATE_DATE,
	  QUOTE_HEADER_ID,
	  ORG_ID,
	  LINE_CATEGORY_CODE,
	  ITEM_TYPE_CODE,
	  LINE_NUMBER,
	  START_DATE_ACTIVE,
	  END_DATE_ACTIVE,
	  ORDER_LINE_TYPE_ID,
	  INVOICE_TO_PARTY_SITE_ID,
	  INVOICE_TO_PARTY_ID,
       INVOICE_TO_CUST_ACCOUNT_ID,
	  ORGANIZATION_ID,
	  INVENTORY_ITEM_ID,
	  QUANTITY,
	  UOM_CODE,
	  MARKETING_SOURCE_CODE_ID,
	  PRICE_LIST_ID,
	  PRICE_LIST_LINE_ID,
	  CURRENCY_CODE,
	  LINE_LIST_PRICE,
	  LINE_ADJUSTED_AMOUNT,
	  LINE_ADJUSTED_PERCENT,
	  LINE_QUOTE_PRICE,
	  RELATED_ITEM_ID,
	  ITEM_RELATIONSHIP_TYPE,
	  ACCOUNTING_RULE_ID,
	  INVOICING_RULE_ID,
	  SPLIT_SHIPMENT_FLAG,
	  BACKORDER_FLAG,
       MINISITE_ID,
       SECTION_ID,
	  INVOICE_TO_CUST_PARTY_ID,
	  RECALCULATE_FLAG,
	  SELLING_PRICE_CHANGE,
	  SERVICE_ITEM_FLAG,
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
       PRICED_PRICE_LIST_ID,
	  AGREEMENT_ID,
	  COMMITMENT_ID,
	  DISPLAY_ARITHMETIC_OPERATOR,
	  PRICING_LINE_TYPE_INDICATOR,
       END_CUSTOMER_PARTY_ID,
       END_CUSTOMER_PARTY_SITE_ID,
       END_CUSTOMER_CUST_ACCOUNT_ID,
       END_CUSTOMER_CUST_PARTY_ID,
	  SHIP_MODEL_COMPLETE_FLAG,
	  CHARGE_PERIODICITY_CODE,
	  PRICING_QUANTITY_UOM,
	  PRICING_QUANTITY,
	  OBJECT_VERSION_NUMBER,
	    -- ER 12879412
           PRODUCT_FISC_CLASSIFICATION,
           TRX_BUSINESS_CATEGORY
	   -- bug 17517305
--	   UNIT_PRICE

     FROM ASO_Quote_Lines_All
	WHERE quote_header_id = p_qte_header_id
     AND   quote_line_id   = p_qte_line_id
	ORDER BY Line_Number;

/* 2633507 - hyang: use mtl_system_items_b instead of vl */

    CURSOR c_Qte_Line_SVC_chk (p_inventory_item_id IN NUMBER,
			       p_organization_id IN NUMBER) IS
         SELECT mtl.service_item_flag
	 FROM   MTL_SYSTEM_ITEMS_B mtl
	 WHERE  mtl.inventory_item_id = p_inventory_item_id
	 AND    mtl.organization_id = p_organization_id;

    CURSOR c_Qte_Line_SVC_ref(p_qte_line_id IN NUMBER) IS
         SELECT service_ref_type_code , service_ref_line_id
	 FROM   ASO_QUOTE_LINE_DETAILS
	 WHERE  quote_line_id = p_qte_line_id;

    CURSOR c_order_line (p_order_line_id IN NUMBER) IS
	 SELECT line_id, inventory_item_id, pricing_quantity, pricing_quantity_uom,
		unit_list_price, price_list_id, charge_periodicity_code,UNIT_LIST_PRICE_PER_PQTY -- bug 17517305
	 FROM OE_ORDER_LINES_ALL
	 WHERE line_id = p_order_line_id;

   /* Cursors used for the customer_products*/

       /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
       CURSOR c_get_cust_acct_id IS
	 select decode(nvl(fnd_profile.value('ASO_FILTER_SERVICE_RF_END_CUST'),'N'),'Y',nvl(END_CUSTOMER_CUST_ACCOUNT_ID,cust_account_id),cust_account_id) cust_account_id
         from ASO_QUOTE_HEADERS_ALL
         WHERE quote_header_id = p_qte_header_id;

	 CURSOR c_get_cust_acct_id_ln(p_qte_line_id number) IS
	 select decode(nvl(fnd_profile.value('ASO_FILTER_SERVICE_RF_END_CUST'),'N'),'Y',END_CUSTOMER_CUST_ACCOUNT_ID)
         from ASO_QUOTE_LINES_ALL
         WHERE quote_line_id = p_qte_line_id;

	 cursor c_get_price_list(p_qte_hdr_id number) is
		select  price_list_id
		from    aso_quote_headers_all
		where   quote_header_id = p_qte_hdr_id;


         l_cust_account_id number;

     /* CURSOR c_get_cust_acct_id IS
      SELECT cust_account_id
      FROM ASO_QUOTE_HEADERS_ALL
      WHERE quote_header_id = p_qte_header_id;*/

       /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/

      CURSOR c_get_orig_order_line_id(p_instance_id IN NUMBER, p_cust_account_id NUMBER) IS
      SELECT   original_order_line_id
      FROM     csi_instance_accts_rg_v
      WHERE    customer_product_id = p_instance_id
      AND      account_id          = p_cust_account_id;

            /******* Start SUN Changes ER: 3802859 *******/

       l_order_found BOOLEAN := FALSE;

     CURSOR c_csi_line_details(p_instance_id IN NUMBER, p_cust_account_id NUMBER) IS
     SELECT si.concatenated_segments product, si.inventory_item_id, cii.quantity, cii.unit_of_measure
    	FROM mtl_system_items_kfv si, csi_item_instances cii
	   WHERE NVL(cii.active_end_date, (SYSDATE + 1)) > SYSDATE
	   AND cii.inventory_item_id = si.inventory_item_id
	   AND si.organization_id = cii.inv_master_organization_id
	   AND cii.instance_id =p_instance_id;

     l_prod     varchar2(1000);
     l_item_id  number;
     l_qty      number;
     l_uom      varchar2(30);

/******* End  SUN Changes ER: 3802859 *******/

/* Start bug 13482837 for current quote service reference */

cursor c_curr_quote_line_details(p_Quote_line_id number) is
select inventory_item_id,quantity,line_list_price,PRICING_QUANTITY_UOM,PRICING_QUANTITY--,unit_price
from aso_quote_lines_all
where quote_line_id=p_quote_line_id;

/* End bug 13482837 for current quote service reference */

    l_service_item_flag        MTL_SYSTEM_ITEMS_VL.SERVICE_ITEM_FLAG%TYPE;
    l_ref_type_code            ASO_QUOTE_LINE_DETAILS.SERVICE_REF_TYPE_CODE%TYPE;
    l_service_ref_line_id      ASO_QUOTE_LINE_DETAILS.SERVICE_REF_LINE_ID%TYPE;

    l_Qte_Line_rec             ASO_QUOTE_PUB.Qte_Line_Rec_Type;
    l_Qte_Line_tbl             ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    l_service_ref_line_id_tbl  Index_Link_Tbl_Type;
    l_order_ref_line_id_tbl    Index_Link_Tbl_Type;
BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_UTL_PVT: Start Query Pricing Line Row p_qte_header_id: '||p_qte_header_id,1,'Y');
        aso_debug_pub.add('ASO_UTL_PVT: Start Query Pricing Line Row P_Qte_Line_Id: '||P_Qte_Line_Id,1,'Y');
     END IF;

     FOR c_qte_line_rec IN c_Qte_Line LOOP
         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_UTL_PVT: Inside c_qte_line_rec with c_qte_line_rec.quote_line_id: '
		                     ||c_qte_line_rec.quote_line_id,1,'Y');
            aso_debug_pub.add('ASO_UTL_PVT: Inside c_qte_line_rec with c_qte_line_rec.service_item_flag: '
		                     ||c_qte_line_rec.service_item_flag,1,'Y');
         END IF;

	    IF  NVL(c_qte_line_rec.service_item_flag,'N') = 'Y' THEN
		     OPEN c_qte_line_SVC_ref(c_qte_line_rec.quote_line_id);
		     FETCH c_qte_line_SVC_ref INTO l_ref_type_code, l_service_ref_line_id;
               CLOSE c_qte_line_SVC_ref;

     		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                  aso_debug_pub.add('ASO_UTL_PVT: Parent Service Line collection ... ',1,'Y');
               END IF;
	 	     IF l_ref_type_code = 'ORDER' THEN
                  IF l_order_ref_line_id_tbl.exists(l_service_ref_line_id) THEN
                     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                        aso_debug_pub.add('ASO_UTL_PVT: Parent Order Line has already been added to l_qte_line_tbl.',1,'Y');
                     END IF;
                  ELSE
		           FOR c_order_line_rec IN c_order_line(l_service_ref_line_id) LOOP
                         l_order_ref_line_id_tbl(l_service_ref_line_id) := l_service_ref_line_id;
    			          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                            aso_debug_pub.add('ASO_UTL_PVT: Parent Order Line has not yet been added to l_qte_line_tbl.', 1, 'N');
                            aso_debug_pub.add('ASO_UTL_PVT: l_order_ref_line_id_tbl('||l_service_ref_line_id||').:'
                                               ||NVL(to_char(l_order_ref_line_id_tbl(l_service_ref_line_id)),'null'),1,'Y');
    			          END IF;
			          l_qte_line_rec.QUOTE_LINE_ID := c_order_line_rec.LINE_ID;
			          l_qte_line_rec.INVENTORY_ITEM_ID := c_order_line_rec.INVENTORY_ITEM_ID;
			          l_qte_line_rec.QUANTITY := c_order_line_rec.PRICING_QUANTITY;
			          l_qte_line_rec.UOM_CODE := c_order_line_rec.PRICING_QUANTITY_UOM;
			          l_qte_line_rec.PRICE_LIST_ID := c_order_line_rec.PRICE_LIST_ID;
			          l_qte_line_rec.LINE_LIST_PRICE := c_order_line_rec.UNIT_LIST_PRICE;
--                                  l_qte_line_rec.UNIT_PRICE := c_order_line_rec.UNIT_LIST_PRICE_PER_PQTY; -- bug 17517305
			          l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_ORDER_LINE';
					l_qte_line_rec.CHARGE_PERIODICITY_CODE := c_order_line_rec.CHARGE_PERIODICITY_CODE;

                         l_qte_line_rec.PRICING_QUANTITY := c_order_line_rec.PRICING_QUANTITY;
                         l_qte_line_rec.PRICING_QUANTITY_UOM := c_order_line_rec.PRICING_QUANTITY_UOM;
	  		          l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
    			          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    			            aso_debug_pub.add('Order Line  Count'|| l_Qte_line_tbl.COUNT, 1, 'N');
    			          END IF;
		           END LOOP;
                   END IF;--l_service_ref_line_id_tbl.exists(l_service_ref_line_id)

		     ELSIF l_ref_type_code = 'CUSTOMER_PRODUCT' THEN

                   IF l_service_ref_line_id_tbl.exists(l_service_ref_line_id) THEN
                      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                         aso_debug_pub.add('ASO_UTL_PVT: Parent Instance Line already added to l_qte_line_tbl.',1,'Y');
                      END IF;
                   ELSE
                      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                         aso_debug_pub.add('ASO_UTL_PVT: Before customer install processing:',1,'Y');
                      END IF;
                       /*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
                   --FOR c_get_cust_acct_id_rec IN c_get_cust_acct_id LOOP
		   open c_get_cust_acct_id_ln(c_qte_line_rec.quote_line_id);
		   fetch c_get_cust_acct_id_ln into l_cust_account_id;
		   if (c_get_cust_acct_id_ln%NOTFOUND) or (l_cust_account_id is null) THEN
			open c_get_cust_acct_id;
			fetch c_get_cust_acct_id into l_cust_account_id;
			if c_get_cust_acct_id%NOTFOUND THEN
				l_cust_account_id := NULL;
			end if;
			close c_get_cust_acct_id;
		   end if;
		   close c_get_cust_acct_id_ln;
     		      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                        aso_debug_pub.add('ASO_UTL_PVT: l_cust_account_id:'||l_cust_account_id,1,'Y');

     		      END IF;
                   /*** End: BugNo 8647883: R12.1.2 Service reference SUN ER ***/


                          l_service_ref_line_id_tbl(l_service_ref_line_id) := l_service_ref_line_id;
                          For c_get_orig_order_line_id_rec IN c_get_orig_order_line_id(l_service_ref_line_id,l_cust_account_id) LOOP
			          l_order_found := FALSE;
			         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                                  aso_debug_pub.add('ASO_UTL_PVT: Parent Instance Line not added to l_qte_line_tbl', 1, 'N');
                                  aso_debug_pub.add('ASO_UTL_PVT: l_service_ref_line_id_tbl('||l_service_ref_line_id||').:'
                                              ||NVL(to_char(l_service_ref_line_id_tbl(l_service_ref_line_id)),'null'),1,'Y');
                               END IF;
                               FOR c_order_line_rec IN c_order_line(c_get_orig_order_line_id_rec.original_order_line_id) LOOP
    		                   l_order_found := TRUE;
                                   l_qte_line_rec.QUOTE_LINE_ID := l_service_ref_line_id;
                                   l_qte_line_rec.INVENTORY_ITEM_ID := c_order_line_rec.INVENTORY_ITEM_ID;
                                   l_qte_line_rec.QUANTITY := c_order_line_rec.PRICING_QUANTITY;
                                   l_qte_line_rec.UOM_CODE := c_order_line_rec.PRICING_QUANTITY_UOM;
                                   l_qte_line_rec.PRICE_LIST_ID := c_order_line_rec.PRICE_LIST_ID;
                                   l_qte_line_rec.LINE_LIST_PRICE := c_order_line_rec.UNIT_LIST_PRICE;
--				   l_qte_line_rec.UNIT_PRICE := c_order_line_rec.UNIT_LIST_PRICE_PER_PQTY; -- bug 17517305
                                   l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_CUSTOMER_LINE';
							l_qte_line_rec.CHARGE_PERIODICITY_CODE := c_order_line_rec.CHARGE_PERIODICITY_CODE;

                                   l_qte_line_rec.PRICING_QUANTITY := c_order_line_rec.PRICING_QUANTITY;
                                   l_qte_line_rec.PRICING_QUANTITY_UOM := c_order_line_rec.PRICING_QUANTITY_UOM;
                                   l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
                                   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                                      aso_debug_pub.add('Instance Line Count '|| l_Qte_line_tbl.COUNT, 1, 'N');
                                   END IF;
                              END LOOP;

				/****** Start SUN Changes ER:3802859 *******/

                                IF l_order_found = FALSE THEN -- this means no order line was found then

                                         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
  				                aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** Inside new condition', 1, 'N');
				                  aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** l_service_ref_line_id: '|| l_service_ref_line_id, 1, 'N');
				                  aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** l_cust_account_id: '|| l_cust_account_id, 1, 'N');
				         END IF;

                                        open c_csi_line_details(l_service_ref_line_id,l_cust_account_id);
                                        fetch c_csi_line_details into l_prod,l_item_id,l_qty,l_uom;

                                        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			                    aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** After fetching the csi line details', 1, 'N');
		                      END IF;

			                l_qte_line_rec.QUOTE_LINE_ID := l_service_ref_line_id;
			                l_qte_line_rec.INVENTORY_ITEM_ID := l_item_id;
			                l_qte_line_rec.QUANTITY := l_qty;
			                l_qte_line_rec.UOM_CODE := l_uom;

                                        -- get the price list from the header
                                         open c_get_price_list(p_qte_header_id);
                                         fetch c_get_price_list INTO l_qte_line_rec.PRICE_LIST_ID;
                                         CLOSE c_get_price_list;

			                  l_qte_line_rec.LINE_LIST_PRICE := 0;
--					  l_qte_line_rec.UNIT_PRICE := 0; -- bug 17517305
			                  l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_CUSTOMER_LINE';

                                            --l_qte_line_rec.CHARGE_PERIODICITY_CODE := c_order_line_rec.CHARGE_PERIODICITY_CODE;

                                          l_qte_line_rec.PRICING_QUANTITY := l_qty;
                                          l_qte_line_rec.PRICING_QUANTITY_UOM := l_UOM;
                                          l_qte_line_rec.IS_LINE_CHANGED_FLAG := 'Y';
			                  l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
					  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    			                  aso_debug_pub.add('Instance Line Count '|| l_Qte_line_tbl.COUNT, 1, 'N');
    			                  END IF;

			                IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ******  l_service_ref_line_id: '|| l_service_ref_line_id, 1, 'N');
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ******  l_item_id: '|| l_item_id, 1, 'N');
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ******  l_qty: '|| l_qty, 1, 'N');
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ******  l_uom: '|| l_uom, 1, 'N');
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** l_qte_line_rec.PRICE_LIST_ID: '||l_qte_line_rec.PRICE_LIST_ID, 1, 'N');
                                       aso_debug_pub.add('ASO_UTL_PVT: **** ER:3802859 ****** Instance Line Count: '|| NVL(l_Qte_line_tbl.COUNT,0), 1, 'N');
			                END IF;

                                        close c_csi_line_details;
                                   END IF;
		    /******* End SUN Changes ER:3802859 *******/
                         End LOOP;
                      --End LOOP;
                    END IF;--l_service_ref_line_id_tbl.exists(l_service_ref_line_id)
		/*** Start: BugNo 8647883: R12.1.2 Service reference SUN ER ***/
		ELSIF l_ref_type_code = 'PRODUCT_CATALOG' THEN
		  IF l_service_ref_line_id_tbl.exists(l_service_ref_line_id) THEN
     			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('ASO_UTL_PVT: Parent Instance Line has already been added to l_qte_line_tbl.',1,'Y');
     			END IF;
                  ELSE
	           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_UTL_PVT:  **** ER: II****** Before product catalog processing:',1,'Y');
		   END IF;


	           l_service_ref_line_id_tbl(l_service_ref_line_id) := l_service_ref_line_id;
	           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('ASO_UTL_PVT: **** **** ER: II****** ****** Inside new condition', 1, 'N');
                     aso_debug_pub.add('ASO_UTL_PVT: ****  **** ER: II****** ****** l_service_ref_line_id: '|| l_service_ref_line_id, 1, 'N');

	           END IF;

	           l_qte_line_rec.QUOTE_LINE_ID := l_service_ref_line_id;       --c_qte_line_rec.QUOTE_LINE_ID;
	           l_qte_line_rec.INVENTORY_ITEM_ID := l_service_ref_line_id;
	           l_qte_line_rec.QUANTITY := c_qte_line_rec.pricing_QUANTITY;
	           l_qte_line_rec.UOM_CODE := c_qte_line_rec.PRICING_QUANTITY_UOM;
                   -- get the price list from the header
	           open c_get_price_list(p_qte_header_id);
		   fetch c_get_price_list INTO l_qte_line_rec.PRICE_LIST_ID;
	           CLOSE c_get_price_list;

		   l_qte_line_rec.LINE_LIST_PRICE := 0;
--		   l_qte_line_rec.UNIT_PRICE := 0; -- bug 17517305
		   l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_CUSTOMER_LINE';
		   l_qte_line_rec.PRICING_QUANTITY := c_qte_line_rec.PRICING_QUANTITY;
                   l_qte_line_rec.PRICING_QUANTITY_UOM := c_qte_line_rec.PRICING_QUANTITY_UOM;

		   l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
                   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                       aso_debug_pub.add('Instance Line Count '|| l_Qte_line_tbl.COUNT, 1, 'N');
                   END IF;

                 END IF;--l_service_ref_line_id_tbl.exists(l_service_ref_line_id)

	    ELSIF l_ref_type_code = 'QUOTE' THEN   -- bug 13482837
		  IF l_service_ref_line_id_tbl.exists(l_service_ref_line_id) THEN
     			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
				aso_debug_pub.add('ASO_UTL_PVT: Parent Instance Line has already been added to l_qte_line_tbl.',1,'Y');
     			END IF;
                  ELSE
	           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('ASO_UTL_PVT:  **** ER: II****** Before current quote processing:',1,'Y');
		   END IF;


	           l_service_ref_line_id_tbl(l_service_ref_line_id) := l_service_ref_line_id;
	           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                     aso_debug_pub.add('ASO_UTL_PVT: **** **** ER: II****** ****** Inside new condition', 1, 'N');
                     aso_debug_pub.add('ASO_UTL_PVT: ****  **** ER: II****** ****** l_service_ref_line_id: '|| l_service_ref_line_id, 1, 'N');

	           END IF;

	           l_qte_line_rec.QUOTE_LINE_ID := l_service_ref_line_id;
		  for  c_quote_line1 in c_curr_quote_line_details(l_service_ref_line_id) loop

	           l_qte_line_rec.INVENTORY_ITEM_ID := c_quote_line1.inventory_item_id;
	           l_qte_line_rec.QUANTITY := c_quote_line1.pricing_QUANTITY;
	           l_qte_line_rec.UOM_CODE := c_quote_line1.PRICING_QUANTITY_UOM;
                   -- get the price list from the header
	           open c_get_price_list(p_qte_header_id);
		   fetch c_get_price_list INTO l_qte_line_rec.PRICE_LIST_ID;
	           CLOSE c_get_price_list;

		   l_qte_line_rec.LINE_LIST_PRICE := c_quote_line1.line_list_price;
		   --l_qte_line_rec.UNIT_PRICE := c_quote_line1.unit_price;
		   l_qte_line_rec.LINE_CATEGORY_CODE := 'SERVICE_REF_CUSTOMER_LINE';
		   l_qte_line_rec.PRICING_QUANTITY := c_quote_line1.PRICING_QUANTITY;
                   l_qte_line_rec.PRICING_QUANTITY_UOM := c_quote_line1.PRICING_QUANTITY_UOM;
		    end loop;

		   l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
                   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
                       aso_debug_pub.add('Instance Line Count '|| l_Qte_line_tbl.COUNT, 1, 'N');
                   END IF;
            END IF;--l_service_ref_line_id_tbl.exists(l_service_ref_line_id)

                END IF;--elsif l_ref_type_code = 'PRODUCT_CATALOG'

              END IF; /* Service Item Flag Check */

	         l_qte_line_rec.QUOTE_LINE_ID := c_qte_line_rec.QUOTE_LINE_ID;
	         l_qte_line_rec.CREATION_DATE := c_qte_line_rec.CREATION_DATE;
	         l_qte_line_rec.CREATED_BY := c_qte_line_rec.CREATED_BY;
	         l_qte_line_rec.LAST_UPDATE_DATE := c_qte_line_rec.LAST_UPDATE_DATE;
	         l_qte_line_rec.LAST_UPDATED_BY := c_qte_line_rec.LAST_UPDATED_BY;
	         l_qte_line_rec.LAST_UPDATE_LOGIN := c_qte_line_rec.LAST_UPDATE_LOGIN;
	         l_qte_line_rec.REQUEST_ID := c_qte_line_rec.REQUEST_ID;
	         l_qte_line_rec.PROGRAM_APPLICATION_ID := c_qte_line_rec.PROGRAM_APPLICATION_ID;
	         l_qte_line_rec.PROGRAM_ID := c_qte_line_rec.PROGRAM_ID;
	         l_qte_line_rec.PROGRAM_UPDATE_DATE := c_qte_line_rec.PROGRAM_UPDATE_DATE;
	         l_qte_line_rec.quote_header_id := c_qte_line_rec.quote_header_id;
	         l_qte_line_rec.ORG_ID := c_qte_line_rec.ORG_ID;
	         l_qte_line_rec.LINE_CATEGORY_CODE := c_qte_line_rec.LINE_CATEGORY_CODE;
	         l_qte_line_rec.ITEM_TYPE_CODE := c_qte_line_rec.ITEM_TYPE_CODE;
	         l_qte_line_rec.LINE_NUMBER := c_qte_line_rec.LINE_NUMBER;
	         l_qte_line_rec.START_DATE_ACTIVE := c_qte_line_rec.START_DATE_ACTIVE;
	         l_qte_line_rec.END_DATE_ACTIVE := c_qte_line_rec.END_DATE_ACTIVE;
	         l_qte_line_rec.ORDER_LINE_TYPE_ID := c_qte_line_rec.ORDER_LINE_TYPE_ID;
	         l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID := c_qte_line_rec.INVOICE_TO_PARTY_SITE_ID;
	         l_qte_line_rec.INVOICE_TO_PARTY_ID := c_qte_line_rec.INVOICE_TO_PARTY_ID;
              l_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID := c_qte_line_rec.INVOICE_TO_CUST_ACCOUNT_ID;
	         l_qte_line_rec.ORGANIZATION_ID := c_qte_line_rec.ORGANIZATION_ID;
	         l_qte_line_rec.INVENTORY_ITEM_ID := c_qte_line_rec.INVENTORY_ITEM_ID;
	         l_qte_line_rec.QUANTITY := c_qte_line_rec.QUANTITY;
	         l_qte_line_rec.UOM_CODE := c_qte_line_rec.UOM_CODE;
	         l_qte_line_rec.MARKETING_SOURCE_CODE_ID := c_qte_line_rec.MARKETING_SOURCE_CODE_ID;
	         l_qte_line_rec.PRICE_LIST_ID := c_qte_line_rec.PRICE_LIST_ID;
	         l_qte_line_rec.PRICE_LIST_LINE_ID := c_qte_line_rec.PRICE_LIST_LINE_ID;
	         l_qte_line_rec.CURRENCY_CODE := c_qte_line_rec.CURRENCY_CODE;
	         l_qte_line_rec.LINE_LIST_PRICE := c_qte_line_rec.LINE_LIST_PRICE;
--		 l_qte_line_rec.UNIT_PRICE := c_qte_line_rec.UNIT_PRICE; -- bug 17517305
	         l_qte_line_rec.LINE_ADJUSTED_AMOUNT := c_qte_line_rec.LINE_ADJUSTED_AMOUNT;
	         l_qte_line_rec.LINE_ADJUSTED_PERCENT := c_qte_line_rec.LINE_ADJUSTED_PERCENT;
	         l_qte_line_rec.LINE_QUOTE_PRICE := c_qte_line_rec.LINE_QUOTE_PRICE;
	         l_qte_line_rec.RELATED_ITEM_ID := c_qte_line_rec.RELATED_ITEM_ID;
	         l_qte_line_rec.ITEM_RELATIONSHIP_TYPE := c_qte_line_rec.ITEM_RELATIONSHIP_TYPE;
	         l_qte_line_rec.ACCOUNTING_RULE_ID := c_qte_line_rec.ACCOUNTING_RULE_ID;
	         l_qte_line_rec.INVOICING_RULE_ID := c_qte_line_rec.INVOICING_RULE_ID;
	         l_qte_line_rec.SPLIT_SHIPMENT_FLAG := c_qte_line_rec.SPLIT_SHIPMENT_FLAG;
	         l_qte_line_rec.BACKORDER_FLAG := c_qte_line_rec.BACKORDER_FLAG;
	         l_qte_line_rec.MINISITE_ID := c_qte_line_rec.MINISITE_ID;
	         l_qte_line_rec.SECTION_ID := c_qte_line_rec.SECTION_ID;
              l_qte_line_rec.INVOICE_TO_CUST_PARTY_ID:= c_qte_line_rec.INVOICE_TO_CUST_PARTY_ID;
              l_qte_line_rec.RECALCULATE_FLAG := c_qte_line_rec.RECALCULATE_FLAG;
              l_qte_line_rec.SELLING_PRICE_CHANGE := c_qte_line_rec.SELLING_PRICE_CHANGE;
	         l_qte_line_rec.service_item_flag   := c_qte_line_rec.service_item_flag;
	         l_qte_line_rec.ATTRIBUTE_CATEGORY := c_qte_line_rec.ATTRIBUTE_CATEGORY;
	         l_qte_line_rec.ATTRIBUTE1 := c_qte_line_rec.ATTRIBUTE1;
	         l_qte_line_rec.ATTRIBUTE2 := c_qte_line_rec.ATTRIBUTE2;
	         l_qte_line_rec.ATTRIBUTE3 := c_qte_line_rec.ATTRIBUTE3;
	         l_qte_line_rec.ATTRIBUTE4 := c_qte_line_rec.ATTRIBUTE4;
	         l_qte_line_rec.ATTRIBUTE5 := c_qte_line_rec.ATTRIBUTE5;
	         l_qte_line_rec.ATTRIBUTE6 := c_qte_line_rec.ATTRIBUTE6;
	         l_qte_line_rec.ATTRIBUTE7 := c_qte_line_rec.ATTRIBUTE7;
	         l_qte_line_rec.ATTRIBUTE8 := c_qte_line_rec.ATTRIBUTE8;
	         l_qte_line_rec.ATTRIBUTE9 := c_qte_line_rec.ATTRIBUTE9;
	         l_qte_line_rec.ATTRIBUTE10 := c_qte_line_rec.ATTRIBUTE10;
	         l_qte_line_rec.ATTRIBUTE11 := c_qte_line_rec.ATTRIBUTE11;
	         l_qte_line_rec.ATTRIBUTE12 := c_qte_line_rec.ATTRIBUTE12;
	         l_qte_line_rec.ATTRIBUTE13 := c_qte_line_rec.ATTRIBUTE13;
	         l_qte_line_rec.ATTRIBUTE14 := c_qte_line_rec.ATTRIBUTE14;
	         l_qte_line_rec.ATTRIBUTE15 := c_qte_line_rec.ATTRIBUTE15;
	         l_qte_line_rec.ATTRIBUTE16 := c_qte_line_rec.ATTRIBUTE16;
	         l_qte_line_rec.ATTRIBUTE17 := c_qte_line_rec.ATTRIBUTE17;
	         l_qte_line_rec.ATTRIBUTE18 := c_qte_line_rec.ATTRIBUTE18;
	         l_qte_line_rec.ATTRIBUTE19 := c_qte_line_rec.ATTRIBUTE19;
	         l_qte_line_rec.ATTRIBUTE20 := c_qte_line_rec.ATTRIBUTE20;
              l_qte_line_rec.PRICED_PRICE_LIST_ID := c_qte_line_rec.PRICED_PRICE_LIST_ID;
	         l_qte_line_rec.AGREEMENT_ID := c_qte_line_rec.AGREEMENT_ID;
	         l_qte_line_rec.COMMITMENT_ID := c_qte_line_rec.COMMITMENT_ID;
	         l_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR := c_qte_line_rec.DISPLAY_ARITHMETIC_OPERATOR;
	         l_qte_line_rec.PRICING_LINE_TYPE_INDICATOR := c_qte_line_rec.PRICING_LINE_TYPE_INDICATOR;
              l_qte_line_rec.END_CUSTOMER_PARTY_ID        := c_qte_line_rec.END_CUSTOMER_PARTY_ID;
              l_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID   := c_qte_line_rec.END_CUSTOMER_PARTY_SITE_ID;
              l_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID := c_qte_line_rec.END_CUSTOMER_CUST_ACCOUNT_ID;
              l_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID   := c_qte_line_rec.END_CUSTOMER_CUST_PARTY_ID;
              l_qte_line_rec.SHIP_MODEL_COMPLETE_FLAG := c_qte_line_rec.SHIP_MODEL_COMPLETE_FLAG;
              l_qte_line_rec.CHARGE_PERIODICITY_CODE := c_qte_line_rec.CHARGE_PERIODICITY_CODE;
              l_qte_line_rec.PRICING_QUANTITY_UOM := c_qte_line_rec.PRICING_QUANTITY_UOM;
              l_qte_line_rec.PRICING_QUANTITY := c_qte_line_rec.PRICING_QUANTITY;
              l_qte_line_rec.OBJECT_VERSION_NUMBER := c_qte_line_rec.OBJECT_VERSION_NUMBER;
	      -- ER 12879412
            l_qte_line_rec.PRODUCT_FISC_CLASSIFICATION :=  c_qte_line_rec.PRODUCT_FISC_CLASSIFICATION;
            l_qte_line_rec.TRX_BUSINESS_CATEGORY := c_qte_line_rec.TRX_BUSINESS_CATEGORY;

	         l_Qte_Line_tbl(l_Qte_Line_tbl.COUNT+1) := l_Qte_Line_rec;
    	      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    	            aso_debug_pub.add('Quote Line Count'|| l_Qte_line_tbl.COUNT, 1, 'N');
    	      END IF;
      END LOOP;

      RETURN l_Qte_Line_tbl;
END Query_Pricing_Line_Row;

-- New Function for Pricing Row Ends Here...................................


FUNCTION Query_Line_Dtl_Rows (
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
IS
    CURSOR c_Line_Dtl IS
	SELECT
	QUOTE_LINE_DETAIL_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	QUOTE_LINE_ID,
	CONFIG_HEADER_ID,
	CONFIG_REVISION_NUM,
	CONFIG_ITEM_ID,
	COMPLETE_CONFIGURATION_FLAG,
	VALID_CONFIGURATION_FLAG,
	COMPONENT_CODE,
	SERVICE_COTERMINATE_FLAG,
	SERVICE_DURATION,
	SERVICE_PERIOD,
	SERVICE_UNIT_SELLING_PERCENT,
	SERVICE_UNIT_LIST_PERCENT,
	SERVICE_NUMBER,
	UNIT_PERCENT_BASE_PRICE,
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
	SERVICE_REF_TYPE_CODE,
	SERVICE_REF_ORDER_NUMBER,
	SERVICE_REF_LINE_NUMBER,
	SERVICE_REF_LINE_ID,
	SERVICE_REF_SYSTEM_ID,
	SERVICE_REF_OPTION_NUMB,
	SERVICE_REF_SHIPMENT_NUMB,
	RETURN_REF_TYPE,
	RETURN_REF_HEADER_ID,
	RETURN_REF_LINE_ID,
	RETURN_REASON_CODE,
	RETURN_ATTRIBUTE1,
	RETURN_ATTRIBUTE2,
	RETURN_ATTRIBUTE3,
	RETURN_ATTRIBUTE4,
	RETURN_ATTRIBUTE5,
	RETURN_ATTRIBUTE6,
	RETURN_ATTRIBUTE7,
	RETURN_ATTRIBUTE8,
	RETURN_ATTRIBUTE9,
	RETURN_ATTRIBUTE10,
	RETURN_ATTRIBUTE11,
	RETURN_ATTRIBUTE12,
	RETURN_ATTRIBUTE13,
	RETURN_ATTRIBUTE14,
	RETURN_ATTRIBUTE15,
     REF_TYPE_CODE,
     REF_LINE_ID,
	INSTANCE_ID,
	BOM_SORT_ORDER,
	TOP_MODEL_LINE_ID,
	ATO_LINE_ID,
	COMPONENT_SEQUENCE_ID,
	OBJECT_VERSION_NUMBER,
	CONFIG_DELTA,
	CONFIG_INSTANCE_NAME
        FROM ASO_Quote_Line_Details
	WHERE quote_line_id = p_qte_line_id;
    l_Line_Dtl_rec             ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;
    l_Line_Dtl_tbl             ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
BEGIN
      FOR Line_Dtl_rec IN c_Line_Dtl LOOP
	   l_line_dtl_rec.QUOTE_LINE_DETAIL_ID := line_dtl_rec.QUOTE_LINE_DETAIL_ID;
	   l_line_dtl_rec.QUOTE_LINE_ID := line_dtl_rec.QUOTE_LINE_ID;
	   l_line_dtl_rec.CREATION_DATE := line_dtl_rec.CREATION_DATE;
	   l_line_dtl_rec.CREATED_BY := line_dtl_rec.CREATED_BY;
	   l_line_dtl_rec.LAST_UPDATE_DATE := line_dtl_rec.LAST_UPDATE_DATE;
	   l_line_dtl_rec.LAST_UPDATED_BY := line_dtl_rec.LAST_UPDATED_BY;
	   l_line_dtl_rec.LAST_UPDATE_LOGIN := line_dtl_rec.LAST_UPDATE_LOGIN;
	   l_line_dtl_rec.REQUEST_ID := line_dtl_rec.REQUEST_ID;
	   l_line_dtl_rec.PROGRAM_APPLICATION_ID := line_dtl_rec.PROGRAM_APPLICATION_ID;
	   l_line_dtl_rec.PROGRAM_ID := line_dtl_rec.PROGRAM_ID;
	   l_line_dtl_rec.PROGRAM_UPDATE_DATE := line_dtl_rec.PROGRAM_UPDATE_DATE;
	  l_line_dtl_rec.CONFIG_HEADER_ID := line_dtl_rec.CONFIG_HEADER_ID;
	  l_line_dtl_rec.COMPLETE_CONFIGURATION_FLAG :=
						line_dtl_rec.COMPLETE_CONFIGURATION_FLAG;
	  l_line_dtl_rec.CONFIG_REVISION_NUM := line_dtl_rec.CONFIG_REVISION_NUM;
	  l_line_dtl_rec.VALID_CONFIGURATION_FLAG :=
						line_dtl_rec.VALID_CONFIGURATION_FLAG;
	  l_line_dtl_rec.COMPONENT_CODE := line_dtl_rec.COMPONENT_CODE;
	  l_line_dtl_rec.SERVICE_COTERMINATE_FLAG :=
						line_dtl_rec.SERVICE_COTERMINATE_FLAG;
	  l_line_dtl_rec.SERVICE_DURATION := line_dtl_rec.SERVICE_DURATION;
	  l_line_dtl_rec.SERVICE_UNIT_SELLING_PERCENT :=
						line_dtl_rec.SERVICE_UNIT_SELLING_PERCENT;
	  l_line_dtl_rec.SERVICE_UNIT_LIST_PERCENT :=
						line_dtl_rec.SERVICE_UNIT_LIST_PERCENT;
	  l_line_dtl_rec.SERVICE_NUMBER := line_dtl_rec.SERVICE_NUMBER;
	  l_line_dtl_rec.UNIT_PERCENT_BASE_PRICE := line_dtl_rec.UNIT_PERCENT_BASE_PRICE;
	  l_line_dtl_rec.SERVICE_PERIOD := line_dtl_rec.SERVICE_PERIOD;
	  l_line_dtl_rec.ATTRIBUTE_CATEGORY := line_dtl_rec.ATTRIBUTE_CATEGORY;
	  l_line_dtl_rec.ATTRIBUTE1 := line_dtl_rec.ATTRIBUTE1;
	  l_line_dtl_rec.ATTRIBUTE2 := line_dtl_rec.ATTRIBUTE2;
	  l_line_dtl_rec.ATTRIBUTE3 := line_dtl_rec.ATTRIBUTE3;
	  l_line_dtl_rec.ATTRIBUTE4 := line_dtl_rec.ATTRIBUTE4;
	  l_line_dtl_rec.ATTRIBUTE5 := line_dtl_rec.ATTRIBUTE5;
	  l_line_dtl_rec.ATTRIBUTE6 := line_dtl_rec.ATTRIBUTE6;
	  l_line_dtl_rec.ATTRIBUTE7 := line_dtl_rec.ATTRIBUTE7;
	  l_line_dtl_rec.ATTRIBUTE8 := line_dtl_rec.ATTRIBUTE8;
	  l_line_dtl_rec.ATTRIBUTE9 := line_dtl_rec.ATTRIBUTE9;
	  l_line_dtl_rec.ATTRIBUTE10 := line_dtl_rec.ATTRIBUTE10;
	  l_line_dtl_rec.ATTRIBUTE11 := line_dtl_rec.ATTRIBUTE11;
	  l_line_dtl_rec.ATTRIBUTE12 := line_dtl_rec.ATTRIBUTE12;
	  l_line_dtl_rec.ATTRIBUTE13 := line_dtl_rec.ATTRIBUTE13;
	  l_line_dtl_rec.ATTRIBUTE14 := line_dtl_rec.ATTRIBUTE14;
	  l_line_dtl_rec.ATTRIBUTE15 := line_dtl_rec.ATTRIBUTE15;
	  l_line_dtl_rec.ATTRIBUTE16 := line_dtl_rec.ATTRIBUTE16;
	  l_line_dtl_rec.ATTRIBUTE17 := line_dtl_rec.ATTRIBUTE17;
	  l_line_dtl_rec.ATTRIBUTE18 := line_dtl_rec.ATTRIBUTE18;
	  l_line_dtl_rec.ATTRIBUTE19 := line_dtl_rec.ATTRIBUTE19;
	  l_line_dtl_rec.ATTRIBUTE20 := line_dtl_rec.ATTRIBUTE20;
	  l_line_dtl_rec.SERVICE_REF_TYPE_CODE     := line_dtl_rec.SERVICE_REF_TYPE_CODE;
	  l_line_dtl_rec.SERVICE_REF_ORDER_NUMBER  := line_dtl_rec.SERVICE_REF_ORDER_NUMBER;
	  l_line_dtl_rec.SERVICE_REF_LINE_NUMBER   := line_dtl_rec.SERVICE_REF_LINE_NUMBER;
	  l_line_dtl_rec.SERVICE_REF_LINE_ID       := line_dtl_rec.SERVICE_REF_LINE_ID;
	  l_line_dtl_rec.SERVICE_REF_SYSTEM_ID     := line_dtl_rec.SERVICE_REF_SYSTEM_ID;
	  l_line_dtl_rec.SERVICE_REF_OPTION_NUMB   := line_dtl_rec.SERVICE_REF_OPTION_NUMB;
	  l_line_dtl_rec.SERVICE_REF_SHIPMENT_NUMB := line_dtl_rec.SERVICE_REF_SHIPMENT_NUMB;
	  l_line_dtl_rec.RETURN_REF_TYPE      := line_dtl_rec.RETURN_REF_TYPE;
	  l_line_dtl_rec.RETURN_REF_HEADER_ID := line_dtl_rec.RETURN_REF_HEADER_ID;
	  l_line_dtl_rec.RETURN_REF_LINE_ID   := line_dtl_rec.RETURN_REF_LINE_ID;
	  l_line_dtl_rec.RETURN_REASON_CODE   := line_dtl_rec.RETURN_REASON_CODE;
	  l_line_dtl_rec.RETURN_ATTRIBUTE1    := line_dtl_rec.RETURN_ATTRIBUTE1;
	  l_line_dtl_rec.RETURN_ATTRIBUTE2    := line_dtl_rec.RETURN_ATTRIBUTE2;
	  l_line_dtl_rec.RETURN_ATTRIBUTE3    := line_dtl_rec.RETURN_ATTRIBUTE3;
	  l_line_dtl_rec.RETURN_ATTRIBUTE4    := line_dtl_rec.RETURN_ATTRIBUTE4;
	  l_line_dtl_rec.RETURN_ATTRIBUTE5    := line_dtl_rec.RETURN_ATTRIBUTE5;
	  l_line_dtl_rec.RETURN_ATTRIBUTE6    := line_dtl_rec.RETURN_ATTRIBUTE6;
	  l_line_dtl_rec.RETURN_ATTRIBUTE7    := line_dtl_rec.RETURN_ATTRIBUTE7;
	  l_line_dtl_rec.RETURN_ATTRIBUTE8    := line_dtl_rec.RETURN_ATTRIBUTE8;
	  l_line_dtl_rec.RETURN_ATTRIBUTE9    := line_dtl_rec.RETURN_ATTRIBUTE9;
	  l_line_dtl_rec.RETURN_ATTRIBUTE10   := line_dtl_rec.RETURN_ATTRIBUTE10;
	  l_line_dtl_rec.RETURN_ATTRIBUTE11   := line_dtl_rec.RETURN_ATTRIBUTE11;
	  l_line_dtl_rec.RETURN_ATTRIBUTE12   := line_dtl_rec.RETURN_ATTRIBUTE12;
	  l_line_dtl_rec.RETURN_ATTRIBUTE13   := line_dtl_rec.RETURN_ATTRIBUTE13;
	  l_line_dtl_rec.RETURN_ATTRIBUTE14   := line_dtl_rec.RETURN_ATTRIBUTE14;
	  l_line_dtl_rec.RETURN_ATTRIBUTE15   := line_dtl_rec.RETURN_ATTRIBUTE15;
	  l_line_dtl_rec.CONFIG_ITEM_ID       := line_dtl_rec.CONFIG_ITEM_ID;
       l_line_dtl_rec.REF_TYPE_CODE        := line_dtl_rec.REF_TYPE_CODE;
       l_line_dtl_rec.REF_LINE_ID          := line_dtl_rec.REF_LINE_ID;
       l_line_dtl_rec.INSTANCE_ID          := line_dtl_rec.INSTANCE_ID;
       l_line_dtl_rec.BOM_SORT_ORDER       := line_dtl_rec.BOM_SORT_ORDER;
       l_line_dtl_rec.TOP_MODEL_LINE_ID    := line_dtl_rec.TOP_MODEL_LINE_ID;
       l_line_dtl_rec.ATO_LINE_ID          := line_dtl_rec.ATO_LINE_ID;
       l_line_dtl_rec.COMPONENT_SEQUENCE_ID  := line_dtl_rec.COMPONENT_SEQUENCE_ID;
       l_line_dtl_rec.OBJECT_VERSION_NUMBER := line_dtl_rec.OBJECT_VERSION_NUMBER;
       l_line_dtl_rec.CONFIG_DELTA := line_dtl_rec.CONFIG_DELTA;
       l_line_dtl_rec.CONFIG_INSTANCE_NAME := line_dtl_rec.CONFIG_INSTANCE_NAME;

	  l_line_dtl_tbl(l_Line_dtl_tbl.COUNT+1) := l_Line_dtl_rec;
      END LOOP;
      RETURN l_line_dtl_tbl;
END Query_Line_Dtl_Rows;


FUNCTION Query_Line_Attribs_header_Rows(
    P_Qte_header_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
IS
    CURSOR c_Line_Attr_Ext IS
	SELECT
        LINE_ATTRIBUTE_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	APPLICATION_ID,
	QUOTE_LINE_ID,
	ATTRIBUTE_TYPE_CODE,
	NAME,
	VALUE,
	VALUE_TYPE,
	STATUS,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE,
	QUOTE_HEADER_ID,
	QUOTE_SHIPMENT_ID
        FROM ASO_QUOTE_LINE_ATTRIBS_EXT
	WHERE quote_header_id = p_qte_header_id AND
    quote_line_id  is null;
    l_Line_Attr_Ext_Rec		ASO_QUOTE_PUB.Line_Attribs_Ext_Rec_Type;
    l_Line_Attr_Ext_Tbl		ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
BEGIN
      FOR Line_Attr_Ext_rec IN c_Line_Attr_Ext LOOP
	   l_line_attr_ext_rec.LINE_ATTRIBUTE_ID := line_attr_ext_rec.LINE_ATTRIBUTE_ID;
	   l_line_attr_ext_rec.QUOTE_LINE_ID := line_attr_ext_rec.QUOTE_LINE_ID;
	   l_line_attr_ext_rec.CREATION_DATE := line_attr_ext_rec.CREATION_DATE;
	   l_line_attr_ext_rec.CREATED_BY := line_attr_ext_rec.CREATED_BY;
	   l_line_attr_ext_rec.LAST_UPDATE_DATE := line_attr_ext_rec.LAST_UPDATE_DATE;
	   l_line_attr_ext_rec.LAST_UPDATED_BY := line_attr_ext_rec.LAST_UPDATED_BY;
	   l_line_attr_ext_rec.LAST_UPDATE_LOGIN := line_attr_ext_rec.LAST_UPDATE_LOGIN;
	   l_line_attr_ext_rec.REQUEST_ID := line_attr_ext_rec.REQUEST_ID;
	   l_line_attr_ext_rec.PROGRAM_APPLICATION_ID := line_attr_ext_rec.PROGRAM_APPLICATION_ID;
	   l_line_attr_ext_rec.PROGRAM_ID := line_attr_ext_rec.PROGRAM_ID;
	   l_line_attr_ext_rec.PROGRAM_UPDATE_DATE := line_attr_ext_rec.PROGRAM_UPDATE_DATE;
	   l_line_attr_ext_rec.ATTRIBUTE_TYPE_CODE := line_attr_ext_rec.ATTRIBUTE_TYPE_CODE;
	   l_line_attr_ext_rec.NAME := line_attr_ext_rec.NAME;
	   l_line_attr_ext_rec.VALUE := line_attr_ext_rec.VALUE;
	   l_line_attr_ext_rec.START_DATE_ACTIVE := line_attr_ext_rec.START_DATE_ACTIVE;
	   l_line_attr_ext_rec.END_DATE_ACTIVE := line_attr_ext_rec.END_DATE_ACTIVE;
	   l_line_attr_ext_rec.QUOTE_HEADER_ID := line_attr_ext_rec.QUOTE_HEADER_ID;
	   l_line_attr_ext_rec.QUOTE_SHIPMENT_ID := line_attr_ext_rec.QUOTE_SHIPMENT_ID;
	   l_line_attr_ext_rec.APPLICATION_ID := line_attr_ext_rec.APPLICATION_ID;
	   l_line_attr_ext_rec.STATUS := line_attr_ext_rec.STATUS;
	   l_line_attr_ext_rec.VALUE_TYPE := line_attr_ext_rec.VALUE_TYPE;
	  l_line_attr_ext_tbl(l_line_attr_ext_tbl.COUNT+1) := l_line_attr_ext_rec;
      END LOOP;
      RETURN l_line_attr_ext_tbl;
END Query_Line_Attribs_header_Rows;


FUNCTION Query_Line_Attribs_Ext_Rows(
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
IS
    CURSOR c_Line_Attr_Ext IS
	SELECT
        LINE_ATTRIBUTE_ID,
	CREATION_DATE,
	CREATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	REQUEST_ID,
	PROGRAM_APPLICATION_ID,
	PROGRAM_ID,
	PROGRAM_UPDATE_DATE,
	APPLICATION_ID,
	QUOTE_LINE_ID,
	ATTRIBUTE_TYPE_CODE,
	NAME,
	VALUE,
	VALUE_TYPE,
	STATUS,
	START_DATE_ACTIVE,
	END_DATE_ACTIVE,
	QUOTE_HEADER_ID,
	QUOTE_SHIPMENT_ID
        FROM ASO_QUOTE_LINE_ATTRIBS_EXT
	WHERE quote_line_id = p_qte_line_id;
    l_Line_Attr_Ext_Rec		ASO_QUOTE_PUB.Line_Attribs_Ext_Rec_Type;
    l_Line_Attr_Ext_Tbl		ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
BEGIN
      FOR Line_Attr_Ext_rec IN c_Line_Attr_Ext LOOP
	   l_line_attr_ext_rec.LINE_ATTRIBUTE_ID := line_attr_ext_rec.LINE_ATTRIBUTE_ID;
	   l_line_attr_ext_rec.QUOTE_LINE_ID := line_attr_ext_rec.QUOTE_LINE_ID;
	   l_line_attr_ext_rec.CREATION_DATE := line_attr_ext_rec.CREATION_DATE;
	   l_line_attr_ext_rec.CREATED_BY := line_attr_ext_rec.CREATED_BY;
	   l_line_attr_ext_rec.LAST_UPDATE_DATE := line_attr_ext_rec.LAST_UPDATE_DATE;
	   l_line_attr_ext_rec.LAST_UPDATED_BY := line_attr_ext_rec.LAST_UPDATED_BY;
	   l_line_attr_ext_rec.LAST_UPDATE_LOGIN := line_attr_ext_rec.LAST_UPDATE_LOGIN;
	   l_line_attr_ext_rec.REQUEST_ID := line_attr_ext_rec.REQUEST_ID;
	   l_line_attr_ext_rec.PROGRAM_APPLICATION_ID := line_attr_ext_rec.PROGRAM_APPLICATION_ID;
	   l_line_attr_ext_rec.PROGRAM_ID := line_attr_ext_rec.PROGRAM_ID;
	   l_line_attr_ext_rec.PROGRAM_UPDATE_DATE := line_attr_ext_rec.PROGRAM_UPDATE_DATE;
	   l_line_attr_ext_rec.ATTRIBUTE_TYPE_CODE := line_attr_ext_rec.ATTRIBUTE_TYPE_CODE;
	   l_line_attr_ext_rec.NAME := line_attr_ext_rec.NAME;
	   l_line_attr_ext_rec.VALUE := line_attr_ext_rec.VALUE;
	   l_line_attr_ext_rec.START_DATE_ACTIVE := line_attr_ext_rec.START_DATE_ACTIVE;
	   l_line_attr_ext_rec.END_DATE_ACTIVE := line_attr_ext_rec.END_DATE_ACTIVE;
	   l_line_attr_ext_rec.QUOTE_HEADER_ID := line_attr_ext_rec.QUOTE_HEADER_ID;
	   l_line_attr_ext_rec.QUOTE_SHIPMENT_ID := line_attr_ext_rec.QUOTE_SHIPMENT_ID;
	   l_line_attr_ext_rec.APPLICATION_ID := line_attr_ext_rec.APPLICATION_ID;
	   l_line_attr_ext_rec.STATUS := line_attr_ext_rec.STATUS;
	   l_line_attr_ext_rec.VALUE_TYPE := line_attr_ext_rec.VALUE_TYPE;
	  l_line_attr_ext_tbl(l_line_attr_ext_tbl.COUNT+1) := l_line_attr_ext_rec;
      END LOOP;
      RETURN l_line_attr_ext_tbl;
END Query_Line_Attribs_Ext_Rows;


FUNCTION Query_Price_Attr_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
IS
    CURSOR c_price_attr IS
	SELECT
PRICE_ATTRIBUTE_ID,
CREATION_DATE,
CREATED_BY,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
PROGRAM_APPLICATION_ID,
PROGRAM_ID,
PROGRAM_UPDATE_DATE,
REQUEST_ID,
QUOTE_HEADER_ID,
QUOTE_LINE_ID,
FLEX_TITLE,
PRICING_CONTEXT,
PRICING_ATTRIBUTE1,
PRICING_ATTRIBUTE2,
PRICING_ATTRIBUTE3,
PRICING_ATTRIBUTE4,
PRICING_ATTRIBUTE5,
PRICING_ATTRIBUTE6,
PRICING_ATTRIBUTE7,
PRICING_ATTRIBUTE8,
PRICING_ATTRIBUTE9,
PRICING_ATTRIBUTE10,
PRICING_ATTRIBUTE11,
PRICING_ATTRIBUTE12,
PRICING_ATTRIBUTE13,
PRICING_ATTRIBUTE14,
PRICING_ATTRIBUTE15,
PRICING_ATTRIBUTE16,
PRICING_ATTRIBUTE17,
PRICING_ATTRIBUTE18,
PRICING_ATTRIBUTE19,
PRICING_ATTRIBUTE20,
PRICING_ATTRIBUTE21,
PRICING_ATTRIBUTE22,
PRICING_ATTRIBUTE23,
PRICING_ATTRIBUTE24,
PRICING_ATTRIBUTE25,
PRICING_ATTRIBUTE26,
PRICING_ATTRIBUTE27,
PRICING_ATTRIBUTE28,
PRICING_ATTRIBUTE29,
PRICING_ATTRIBUTE30,
PRICING_ATTRIBUTE31,
PRICING_ATTRIBUTE32,
PRICING_ATTRIBUTE33,
PRICING_ATTRIBUTE34,
PRICING_ATTRIBUTE35,
PRICING_ATTRIBUTE36,
PRICING_ATTRIBUTE37,
PRICING_ATTRIBUTE38,
PRICING_ATTRIBUTE39,
PRICING_ATTRIBUTE40,
PRICING_ATTRIBUTE41,
PRICING_ATTRIBUTE42,
PRICING_ATTRIBUTE43,
PRICING_ATTRIBUTE44,
PRICING_ATTRIBUTE45,
PRICING_ATTRIBUTE46,
PRICING_ATTRIBUTE47,
PRICING_ATTRIBUTE48,
PRICING_ATTRIBUTE49,
PRICING_ATTRIBUTE50,
PRICING_ATTRIBUTE51,
PRICING_ATTRIBUTE52,
PRICING_ATTRIBUTE53,
PRICING_ATTRIBUTE54,
PRICING_ATTRIBUTE55,
PRICING_ATTRIBUTE56,
PRICING_ATTRIBUTE57,
PRICING_ATTRIBUTE58,
PRICING_ATTRIBUTE59,
PRICING_ATTRIBUTE60,
PRICING_ATTRIBUTE61,
PRICING_ATTRIBUTE62,
PRICING_ATTRIBUTE63,
PRICING_ATTRIBUTE64,
PRICING_ATTRIBUTE65,
PRICING_ATTRIBUTE66,
PRICING_ATTRIBUTE67,
PRICING_ATTRIBUTE68,
PRICING_ATTRIBUTE69,
PRICING_ATTRIBUTE70,
PRICING_ATTRIBUTE71,
PRICING_ATTRIBUTE72,
PRICING_ATTRIBUTE73,
PRICING_ATTRIBUTE74,
PRICING_ATTRIBUTE75,
PRICING_ATTRIBUTE76,
PRICING_ATTRIBUTE77,
PRICING_ATTRIBUTE78,
PRICING_ATTRIBUTE79,
PRICING_ATTRIBUTE80,
PRICING_ATTRIBUTE81,
PRICING_ATTRIBUTE82,
PRICING_ATTRIBUTE83,
PRICING_ATTRIBUTE84,
PRICING_ATTRIBUTE85,
PRICING_ATTRIBUTE86,
PRICING_ATTRIBUTE87,
PRICING_ATTRIBUTE88,
PRICING_ATTRIBUTE89,
PRICING_ATTRIBUTE90,
PRICING_ATTRIBUTE91,
PRICING_ATTRIBUTE92,
PRICING_ATTRIBUTE93,
PRICING_ATTRIBUTE94,
PRICING_ATTRIBUTE95,
PRICING_ATTRIBUTE96,
PRICING_ATTRIBUTE97,
PRICING_ATTRIBUTE98,
PRICING_ATTRIBUTE99,
PRICING_ATTRIBUTE100,
CONTEXT,
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
        FROM ASO_PRICE_ATTRIBUTES
	WHERE quote_header_id = p_qte_header_id AND
	   (quote_line_id = p_qte_line_id OR
		(quote_line_id IS NULL AND p_qte_line_id IS NULL));
    l_price_attr_rec             ASO_QUOTE_PUB.Price_Attributes_Rec_Type;
    l_price_attr_tbl             ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
BEGIN
      FOR price_attr_rec IN c_price_attr LOOP
	   l_price_attr_rec.PRICE_ATTRIBUTE_ID := price_attr_rec.PRICE_ATTRIBUTE_ID;
	   l_price_attr_rec.CREATION_DATE := price_attr_rec.CREATION_DATE;
	   l_price_attr_rec.CREATED_BY := price_attr_rec.CREATED_BY;
	   l_price_attr_rec.LAST_UPDATE_DATE := price_attr_rec.LAST_UPDATE_DATE;
	   l_price_attr_rec.LAST_UPDATED_BY := price_attr_rec.LAST_UPDATED_BY;
	   l_price_attr_rec.LAST_UPDATE_LOGIN := price_attr_rec.LAST_UPDATE_LOGIN;
	   l_price_attr_rec.REQUEST_ID := price_attr_rec.REQUEST_ID;
	   l_price_attr_rec.PROGRAM_APPLICATION_ID := price_attr_rec.PROGRAM_APPLICATION_ID;
	   l_price_attr_rec.PROGRAM_ID := price_attr_rec.PROGRAM_ID;
	   l_price_attr_rec.PROGRAM_UPDATE_DATE := price_attr_rec.PROGRAM_UPDATE_DATE;
	   l_price_attr_rec.QUOTE_HEADER_ID := price_attr_rec.QUOTE_HEADER_ID;
	   l_price_attr_rec.QUOTE_LINE_ID := price_attr_rec.QUOTE_LINE_ID;
	   l_price_attr_rec.FLEX_TITLE := price_attr_rec.FLEX_TITLE;
 	  l_price_attr_rec.PRICING_CONTEXT := price_attr_rec.PRICING_CONTEXT;
 	  l_price_attr_rec.PRICING_ATTRIBUTE1 := price_attr_rec.PRICING_ATTRIBUTE1;
 	  l_price_attr_rec.PRICING_ATTRIBUTE2 := price_attr_rec.PRICING_ATTRIBUTE2;
 	  l_price_attr_rec.PRICING_ATTRIBUTE3 := price_attr_rec.PRICING_ATTRIBUTE3;
 	  l_price_attr_rec.PRICING_ATTRIBUTE4 := price_attr_rec.PRICING_ATTRIBUTE4;
 	  l_price_attr_rec.PRICING_ATTRIBUTE5 := price_attr_rec.PRICING_ATTRIBUTE5;
 	  l_price_attr_rec.PRICING_ATTRIBUTE6 := price_attr_rec.PRICING_ATTRIBUTE6;
 	  l_price_attr_rec.PRICING_ATTRIBUTE7 := price_attr_rec.PRICING_ATTRIBUTE7;
 	  l_price_attr_rec.PRICING_ATTRIBUTE8 := price_attr_rec.PRICING_ATTRIBUTE8;
 	  l_price_attr_rec.PRICING_ATTRIBUTE9 := price_attr_rec.PRICING_ATTRIBUTE9;
 	  l_price_attr_rec.PRICING_ATTRIBUTE10 := price_attr_rec.PRICING_ATTRIBUTE10;
 	  l_price_attr_rec.PRICING_ATTRIBUTE11 := price_attr_rec.PRICING_ATTRIBUTE11;
 	  l_price_attr_rec.PRICING_ATTRIBUTE12 := price_attr_rec.PRICING_ATTRIBUTE12;
 	  l_price_attr_rec.PRICING_ATTRIBUTE13 := price_attr_rec.PRICING_ATTRIBUTE13;
 	  l_price_attr_rec.PRICING_ATTRIBUTE14 := price_attr_rec.PRICING_ATTRIBUTE14;
 	  l_price_attr_rec.PRICING_ATTRIBUTE15 := price_attr_rec.PRICING_ATTRIBUTE15;
 	  l_price_attr_rec.PRICING_ATTRIBUTE16 := price_attr_rec.PRICING_ATTRIBUTE16;
 	  l_price_attr_rec.PRICING_ATTRIBUTE17 := price_attr_rec.PRICING_ATTRIBUTE17;
 	  l_price_attr_rec.PRICING_ATTRIBUTE18 := price_attr_rec.PRICING_ATTRIBUTE18;
 	  l_price_attr_rec.PRICING_ATTRIBUTE19 := price_attr_rec.PRICING_ATTRIBUTE19;
 	  l_price_attr_rec.PRICING_ATTRIBUTE20 := price_attr_rec.PRICING_ATTRIBUTE20;
 	  l_price_attr_rec.PRICING_ATTRIBUTE21 := price_attr_rec.PRICING_ATTRIBUTE21;
 	  l_price_attr_rec.PRICING_ATTRIBUTE22 := price_attr_rec.PRICING_ATTRIBUTE22;
 	  l_price_attr_rec.PRICING_ATTRIBUTE23 := price_attr_rec.PRICING_ATTRIBUTE23;
 	  l_price_attr_rec.PRICING_ATTRIBUTE24 := price_attr_rec.PRICING_ATTRIBUTE24;
 	  l_price_attr_rec.PRICING_ATTRIBUTE25 := price_attr_rec.PRICING_ATTRIBUTE25;
 	  l_price_attr_rec.PRICING_ATTRIBUTE26 := price_attr_rec.PRICING_ATTRIBUTE26;
 	  l_price_attr_rec.PRICING_ATTRIBUTE27 := price_attr_rec.PRICING_ATTRIBUTE27;
 	  l_price_attr_rec.PRICING_ATTRIBUTE28 := price_attr_rec.PRICING_ATTRIBUTE28;
 	  l_price_attr_rec.PRICING_ATTRIBUTE29 := price_attr_rec.PRICING_ATTRIBUTE29;
 	  l_price_attr_rec.PRICING_ATTRIBUTE30 := price_attr_rec.PRICING_ATTRIBUTE30;
 	  l_price_attr_rec.PRICING_ATTRIBUTE31 := price_attr_rec.PRICING_ATTRIBUTE31;
 	  l_price_attr_rec.PRICING_ATTRIBUTE32 := price_attr_rec.PRICING_ATTRIBUTE32;
 	  l_price_attr_rec.PRICING_ATTRIBUTE33 := price_attr_rec.PRICING_ATTRIBUTE33;
 	  l_price_attr_rec.PRICING_ATTRIBUTE34 := price_attr_rec.PRICING_ATTRIBUTE34;
 	  l_price_attr_rec.PRICING_ATTRIBUTE35 := price_attr_rec.PRICING_ATTRIBUTE35;
 	  l_price_attr_rec.PRICING_ATTRIBUTE36 := price_attr_rec.PRICING_ATTRIBUTE36;
 	  l_price_attr_rec.PRICING_ATTRIBUTE37 := price_attr_rec.PRICING_ATTRIBUTE37;
 	  l_price_attr_rec.PRICING_ATTRIBUTE38 := price_attr_rec.PRICING_ATTRIBUTE38;
 	  l_price_attr_rec.PRICING_ATTRIBUTE39 := price_attr_rec.PRICING_ATTRIBUTE39;
 	  l_price_attr_rec.PRICING_ATTRIBUTE40 := price_attr_rec.PRICING_ATTRIBUTE40;
 	  l_price_attr_rec.PRICING_ATTRIBUTE41 := price_attr_rec.PRICING_ATTRIBUTE41;
 	  l_price_attr_rec.PRICING_ATTRIBUTE42 := price_attr_rec.PRICING_ATTRIBUTE42;
 	  l_price_attr_rec.PRICING_ATTRIBUTE43 := price_attr_rec.PRICING_ATTRIBUTE43;
 	  l_price_attr_rec.PRICING_ATTRIBUTE44 := price_attr_rec.PRICING_ATTRIBUTE44;
 	  l_price_attr_rec.PRICING_ATTRIBUTE45 := price_attr_rec.PRICING_ATTRIBUTE45;
 	  l_price_attr_rec.PRICING_ATTRIBUTE46 := price_attr_rec.PRICING_ATTRIBUTE46;
 	  l_price_attr_rec.PRICING_ATTRIBUTE47 := price_attr_rec.PRICING_ATTRIBUTE47;
 	  l_price_attr_rec.PRICING_ATTRIBUTE48 := price_attr_rec.PRICING_ATTRIBUTE48;
 	  l_price_attr_rec.PRICING_ATTRIBUTE49 := price_attr_rec.PRICING_ATTRIBUTE49;
 	  l_price_attr_rec.PRICING_ATTRIBUTE50 := price_attr_rec.PRICING_ATTRIBUTE50;
 	  l_price_attr_rec.PRICING_ATTRIBUTE51 := price_attr_rec.PRICING_ATTRIBUTE51;
 	  l_price_attr_rec.PRICING_ATTRIBUTE52 := price_attr_rec.PRICING_ATTRIBUTE52;
 	  l_price_attr_rec.PRICING_ATTRIBUTE53 := price_attr_rec.PRICING_ATTRIBUTE53;
 	  l_price_attr_rec.PRICING_ATTRIBUTE54 := price_attr_rec.PRICING_ATTRIBUTE54;
 	  l_price_attr_rec.PRICING_ATTRIBUTE55 := price_attr_rec.PRICING_ATTRIBUTE55;
 	  l_price_attr_rec.PRICING_ATTRIBUTE56 := price_attr_rec.PRICING_ATTRIBUTE56;
 	  l_price_attr_rec.PRICING_ATTRIBUTE57 := price_attr_rec.PRICING_ATTRIBUTE57;
 	  l_price_attr_rec.PRICING_ATTRIBUTE58 := price_attr_rec.PRICING_ATTRIBUTE58;
 	  l_price_attr_rec.PRICING_ATTRIBUTE59 := price_attr_rec.PRICING_ATTRIBUTE59;
 	  l_price_attr_rec.PRICING_ATTRIBUTE60 := price_attr_rec.PRICING_ATTRIBUTE60;
 	  l_price_attr_rec.PRICING_ATTRIBUTE61 := price_attr_rec.PRICING_ATTRIBUTE61;
 	  l_price_attr_rec.PRICING_ATTRIBUTE62 := price_attr_rec.PRICING_ATTRIBUTE62;
 	  l_price_attr_rec.PRICING_ATTRIBUTE63 := price_attr_rec.PRICING_ATTRIBUTE63;
 	  l_price_attr_rec.PRICING_ATTRIBUTE64 := price_attr_rec.PRICING_ATTRIBUTE64;
 	  l_price_attr_rec.PRICING_ATTRIBUTE65 := price_attr_rec.PRICING_ATTRIBUTE65;
 	  l_price_attr_rec.PRICING_ATTRIBUTE66 := price_attr_rec.PRICING_ATTRIBUTE66;
 	  l_price_attr_rec.PRICING_ATTRIBUTE67 := price_attr_rec.PRICING_ATTRIBUTE67;
 	  l_price_attr_rec.PRICING_ATTRIBUTE68 := price_attr_rec.PRICING_ATTRIBUTE68;
 	  l_price_attr_rec.PRICING_ATTRIBUTE69 := price_attr_rec.PRICING_ATTRIBUTE69;
 	  l_price_attr_rec.PRICING_ATTRIBUTE70 := price_attr_rec.PRICING_ATTRIBUTE70;
 	  l_price_attr_rec.PRICING_ATTRIBUTE71 := price_attr_rec.PRICING_ATTRIBUTE71;
 	  l_price_attr_rec.PRICING_ATTRIBUTE72 := price_attr_rec.PRICING_ATTRIBUTE72;
 	  l_price_attr_rec.PRICING_ATTRIBUTE73 := price_attr_rec.PRICING_ATTRIBUTE73;
 	  l_price_attr_rec.PRICING_ATTRIBUTE74 := price_attr_rec.PRICING_ATTRIBUTE74;
 	  l_price_attr_rec.PRICING_ATTRIBUTE75 := price_attr_rec.PRICING_ATTRIBUTE75;
 	  l_price_attr_rec.PRICING_ATTRIBUTE76 := price_attr_rec.PRICING_ATTRIBUTE76;
 	  l_price_attr_rec.PRICING_ATTRIBUTE77 := price_attr_rec.PRICING_ATTRIBUTE77;
 	  l_price_attr_rec.PRICING_ATTRIBUTE78 := price_attr_rec.PRICING_ATTRIBUTE78;
 	  l_price_attr_rec.PRICING_ATTRIBUTE79 := price_attr_rec.PRICING_ATTRIBUTE79;
 	  l_price_attr_rec.PRICING_ATTRIBUTE80 := price_attr_rec.PRICING_ATTRIBUTE80;
 	  l_price_attr_rec.PRICING_ATTRIBUTE81 := price_attr_rec.PRICING_ATTRIBUTE81;
 	  l_price_attr_rec.PRICING_ATTRIBUTE82 := price_attr_rec.PRICING_ATTRIBUTE82;
 	  l_price_attr_rec.PRICING_ATTRIBUTE83 := price_attr_rec.PRICING_ATTRIBUTE83;
 	  l_price_attr_rec.PRICING_ATTRIBUTE84 := price_attr_rec.PRICING_ATTRIBUTE84;
 	  l_price_attr_rec.PRICING_ATTRIBUTE85 := price_attr_rec.PRICING_ATTRIBUTE85;
 	  l_price_attr_rec.PRICING_ATTRIBUTE86 := price_attr_rec.PRICING_ATTRIBUTE86;
 	  l_price_attr_rec.PRICING_ATTRIBUTE87 := price_attr_rec.PRICING_ATTRIBUTE87;
 	  l_price_attr_rec.PRICING_ATTRIBUTE88 := price_attr_rec.PRICING_ATTRIBUTE88;
 	  l_price_attr_rec.PRICING_ATTRIBUTE89 := price_attr_rec.PRICING_ATTRIBUTE89;
 	  l_price_attr_rec.PRICING_ATTRIBUTE90 := price_attr_rec.PRICING_ATTRIBUTE90;
 	  l_price_attr_rec.PRICING_ATTRIBUTE91 := price_attr_rec.PRICING_ATTRIBUTE91;
 	  l_price_attr_rec.PRICING_ATTRIBUTE92 := price_attr_rec.PRICING_ATTRIBUTE92;
 	  l_price_attr_rec.PRICING_ATTRIBUTE93 := price_attr_rec.PRICING_ATTRIBUTE93;
 	  l_price_attr_rec.PRICING_ATTRIBUTE94 := price_attr_rec.PRICING_ATTRIBUTE94;
 	  l_price_attr_rec.PRICING_ATTRIBUTE95 := price_attr_rec.PRICING_ATTRIBUTE95;
 	  l_price_attr_rec.PRICING_ATTRIBUTE96 := price_attr_rec.PRICING_ATTRIBUTE96;
 	  l_price_attr_rec.PRICING_ATTRIBUTE97 := price_attr_rec.PRICING_ATTRIBUTE97;
 	  l_price_attr_rec.PRICING_ATTRIBUTE98 := price_attr_rec.PRICING_ATTRIBUTE98;
 	  l_price_attr_rec.PRICING_ATTRIBUTE99 := price_attr_rec.PRICING_ATTRIBUTE99;
 	  l_price_attr_rec.PRICING_ATTRIBUTE100 := price_attr_rec.PRICING_ATTRIBUTE100;
	  l_price_attr_rec.CONTEXT := price_attr_rec.CONTEXT;
	  l_price_attr_rec.ATTRIBUTE1 := price_attr_rec.ATTRIBUTE1;
	  l_price_attr_rec.ATTRIBUTE2 := price_attr_rec.ATTRIBUTE2;
	  l_price_attr_rec.ATTRIBUTE3 := price_attr_rec.ATTRIBUTE3;
	  l_price_attr_rec.ATTRIBUTE4 := price_attr_rec.ATTRIBUTE4;
	  l_price_attr_rec.ATTRIBUTE5 := price_attr_rec.ATTRIBUTE5;
	  l_price_attr_rec.ATTRIBUTE6 := price_attr_rec.ATTRIBUTE6;
	  l_price_attr_rec.ATTRIBUTE7 := price_attr_rec.ATTRIBUTE7;
	  l_price_attr_rec.ATTRIBUTE8 := price_attr_rec.ATTRIBUTE8;
	  l_price_attr_rec.ATTRIBUTE9 := price_attr_rec.ATTRIBUTE9;
	  l_price_attr_rec.ATTRIBUTE10 := price_attr_rec.ATTRIBUTE10;
	  l_price_attr_rec.ATTRIBUTE11 := price_attr_rec.ATTRIBUTE11;
	  l_price_attr_rec.ATTRIBUTE12 := price_attr_rec.ATTRIBUTE12;
	  l_price_attr_rec.ATTRIBUTE13 := price_attr_rec.ATTRIBUTE13;
	  l_price_attr_rec.ATTRIBUTE14 := price_attr_rec.ATTRIBUTE14;
	  l_price_attr_rec.ATTRIBUTE15 := price_attr_rec.ATTRIBUTE15;
	  l_price_attr_rec.ATTRIBUTE16 := price_attr_rec.ATTRIBUTE16;
	  l_price_attr_rec.ATTRIBUTE17 := price_attr_rec.ATTRIBUTE17;
	  l_price_attr_rec.ATTRIBUTE18 := price_attr_rec.ATTRIBUTE18;
	  l_price_attr_rec.ATTRIBUTE19 := price_attr_rec.ATTRIBUTE19;
	  l_price_attr_rec.ATTRIBUTE20 := price_attr_rec.ATTRIBUTE20;
	  l_price_attr_rec.OBJECT_VERSION_NUMBER := price_attr_rec.OBJECT_VERSION_NUMBER;
	  l_price_attr_tbl(l_price_attr_tbl.COUNT+1) := l_price_attr_rec;
      END LOOP;
      RETURN l_price_attr_tbl;
END Query_Price_Attr_Rows;

FUNCTION Query_Price_Adj_Rltship_Rows (
    P_Price_Adjustment_Id     IN  NUMBER := FND_API.G_MISS_NUM
	   ) RETURN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
IS
	CURSOR C_Price_Adj_Rltd IS
	SELECT
	ADJ_RELATIONSHIP_ID
	,CREATION_DATE
	,CREATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,PROGRAM_APPLICATION_ID
	,PROGRAM_ID
	,PROGRAM_UPDATE_DATE
	,REQUEST_ID
	,QUOTE_LINE_ID
	,PRICE_ADJUSTMENT_ID
	,RLTD_PRICE_ADJ_ID
	,QUOTE_SHIPMENT_ID
	,SECURITY_GROUP_ID
	,OBJECT_VERSION_NUMBER
	FROM aso_price_adj_relationships
	WHERE price_adjustment_id = P_Price_Adjustment_Id;

	l_price_adj_rltd_rec         ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type;
    	l_price_adj_rltd_tbl         ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

BEGIN
FOR C_Price_Adj_Rltd_Rec IN C_Price_Adj_Rltd LOOP
l_price_adj_rltd_rec.ADJ_RELATIONSHIP_ID := C_Price_Adj_Rltd_Rec.ADJ_RELATIONSHIP_ID;
l_price_adj_rltd_rec.CREATION_DATE := C_Price_Adj_Rltd_Rec.CREATION_DATE;
l_price_adj_rltd_rec.CREATED_BY := C_Price_Adj_Rltd_Rec.CREATED_BY;
l_price_adj_rltd_rec.LAST_UPDATE_DATE := C_Price_Adj_Rltd_Rec.LAST_UPDATE_DATE;
l_price_adj_rltd_rec.LAST_UPDATED_BY := C_Price_Adj_Rltd_Rec.LAST_UPDATED_BY;
l_price_adj_rltd_rec.LAST_UPDATE_LOGIN := C_Price_Adj_Rltd_Rec.LAST_UPDATE_LOGIN;
l_price_adj_rltd_rec.PROGRAM_APPLICATION_ID := C_Price_Adj_Rltd_Rec.PROGRAM_APPLICATION_ID;
l_price_adj_rltd_rec.PROGRAM_ID := C_Price_Adj_Rltd_Rec.PROGRAM_ID;
l_price_adj_rltd_rec.PROGRAM_UPDATE_DATE := C_Price_Adj_Rltd_Rec.PROGRAM_UPDATE_DATE;
l_price_adj_rltd_rec.REQUEST_ID := C_Price_Adj_Rltd_Rec.REQUEST_ID;
l_price_adj_rltd_rec.QUOTE_LINE_ID := C_Price_Adj_Rltd_Rec.QUOTE_LINE_ID;
l_price_adj_rltd_rec.PRICE_ADJUSTMENT_ID := C_Price_Adj_Rltd_Rec.PRICE_ADJUSTMENT_ID;
l_price_adj_rltd_rec.RLTD_PRICE_ADJ_ID := C_Price_Adj_Rltd_Rec.RLTD_PRICE_ADJ_ID;
l_price_adj_rltd_rec.QUOTE_SHIPMENT_ID := C_Price_Adj_Rltd_Rec.QUOTE_SHIPMENT_ID;
l_price_adj_rltd_tbl(l_price_adj_rltd_tbl.COUNT+1) := l_price_adj_rltd_rec;
END LOOP;
RETURN l_price_adj_rltd_tbl;
END  Query_Price_Adj_Rltship_Rows;


FUNCTION Query_Price_Adj_Rltn_Rows (
    P_Quote_Line_Id     IN  NUMBER := FND_API.G_MISS_NUM
        ) RETURN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
IS
     CURSOR C_Price_Adj_Rltd IS
     SELECT
     ADJ_RELATIONSHIP_ID
     ,CREATION_DATE
     ,CREATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_LOGIN
     ,PROGRAM_APPLICATION_ID
     ,PROGRAM_ID
     ,PROGRAM_UPDATE_DATE
     ,REQUEST_ID
     ,QUOTE_LINE_ID
     ,PRICE_ADJUSTMENT_ID
     ,RLTD_PRICE_ADJ_ID
     ,QUOTE_SHIPMENT_ID
     ,SECURITY_GROUP_ID
     ,OBJECT_VERSION_NUMBER
     FROM aso_price_adj_relationships
     WHERE quote_line_id = P_Quote_Line_Id;

     l_price_adj_rltd_rec         ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type;
     l_price_adj_rltd_tbl         ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;

BEGIN
FOR C_Price_Adj_Rltd_Rec IN C_Price_Adj_Rltd LOOP
l_price_adj_rltd_rec.ADJ_RELATIONSHIP_ID := C_Price_Adj_Rltd_Rec.ADJ_RELATIONSHIP_ID;
l_price_adj_rltd_rec.CREATION_DATE := C_Price_Adj_Rltd_Rec.CREATION_DATE;
l_price_adj_rltd_rec.CREATED_BY := C_Price_Adj_Rltd_Rec.CREATED_BY;
l_price_adj_rltd_rec.LAST_UPDATE_DATE := C_Price_Adj_Rltd_Rec.LAST_UPDATE_DATE;
l_price_adj_rltd_rec.LAST_UPDATED_BY := C_Price_Adj_Rltd_Rec.LAST_UPDATED_BY;
l_price_adj_rltd_rec.LAST_UPDATE_LOGIN := C_Price_Adj_Rltd_Rec.LAST_UPDATE_LOGIN;
l_price_adj_rltd_rec.PROGRAM_APPLICATION_ID := C_Price_Adj_Rltd_Rec.PROGRAM_APPLICATION_ID;
l_price_adj_rltd_rec.PROGRAM_ID := C_Price_Adj_Rltd_Rec.PROGRAM_ID;
l_price_adj_rltd_rec.PROGRAM_UPDATE_DATE := C_Price_Adj_Rltd_Rec.PROGRAM_UPDATE_DATE;
l_price_adj_rltd_rec.REQUEST_ID := C_Price_Adj_Rltd_Rec.REQUEST_ID;
l_price_adj_rltd_rec.QUOTE_LINE_ID := C_Price_Adj_Rltd_Rec.QUOTE_LINE_ID;
l_price_adj_rltd_rec.PRICE_ADJUSTMENT_ID := C_Price_Adj_Rltd_Rec.PRICE_ADJUSTMENT_ID;
l_price_adj_rltd_rec.RLTD_PRICE_ADJ_ID := C_Price_Adj_Rltd_Rec.RLTD_PRICE_ADJ_ID;
l_price_adj_rltd_rec.QUOTE_SHIPMENT_ID := C_Price_Adj_Rltd_Rec.QUOTE_SHIPMENT_ID;
l_price_adj_rltd_tbl(l_price_adj_rltd_tbl.COUNT+1) := l_price_adj_rltd_rec;
END LOOP;
RETURN l_price_adj_rltd_tbl;
END  Query_Price_Adj_Rltn_Rows;




FUNCTION Get_Profile_Obsolete_Status (
    p_profile_name       IN  VARCHAR2,
    p_application_id     IN  NUMBER
  ) RETURN VARCHAR2
IS

cursor c_end_date is
select end_date_active
from fnd_profile_options
where profile_option_name = p_profile_name
and application_id = p_application_id
and trunc(start_date_active) <= trunc(sysdate)
and trunc(nvl(end_date_active, sysdate)) >= trunc(sysdate);

l_end_date_active date;

begin
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_UTL_PVT: Get_Profile_Obsolete_Status: p_profile_name:   '||p_profile_name,1,'Y');
        aso_debug_pub.add('ASO_UTL_PVT: Get_Profile_Obsolete_Status: p_application_id: '||p_application_id,1,'Y');
     END IF;

	open c_end_date;
	fetch c_end_date into l_end_date_active;

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('ASO_UTL_PVT: Get_Profile_Obsolete_Status: l_end_date_active: '||l_end_date_active,1,'Y');
     END IF;

	if c_end_date%found then

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('ASO_UTL_PVT: Get_Profile_Obsolete_Status: Inside c_end_date%found cond',1,'Y');
        END IF;

	   close c_end_date;
	   return 'F';
     else

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('ASO_UTL_PVT: Get_Profile_Obsolete_Status: Inside else c_end_date%found cond',1,'Y');
        END IF;

	   close c_end_date;
	   return 'T';
     end if;

end Get_Profile_Obsolete_Status;


FUNCTION  GET_Control_Rec  RETURN  ASO_QUOTE_PUB.Control_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Control_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Control_Rec;

FUNCTION  GET_Qte_Header_Rec  RETURN  ASO_QUOTE_PUB.Qte_Header_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Qte_Header_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Qte_Header_Rec;

FUNCTION  GET_Qte_Sort_Rec  RETURN  ASO_QUOTE_PUB.Qte_Sort_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Qte_Sort_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Qte_Sort_Rec;

FUNCTION  GET_Qte_Line_Rec  RETURN  ASO_QUOTE_PUB.Qte_Line_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Qte_Line_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Qte_Line_Rec;

FUNCTION  GET_Qte_Line_sort_Rec  RETURN  ASO_QUOTE_PUB.Qte_Line_sort_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Qte_Line_sort_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Qte_Line_sort_Rec;

FUNCTION  GET_Qte_Line_Dtl_Rec  RETURN  ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Qte_Line_Dtl_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Qte_Line_Dtl_Rec;

FUNCTION  GET_Price_Attributes_Rec
    RETURN ASO_QUOTE_PUB.Price_Attributes_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Price_Attributes_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Price_Attributes_Rec;

FUNCTION  GET_Price_Adj_Rec  RETURN  ASO_QUOTE_PUB.Price_Adj_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Price_Adj_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Price_Adj_Rec;

FUNCTION  GET_PRICE_ADJ_ATTR_Rec
    RETURN  ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.PRICE_ADJ_ATTR_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_PRICE_ADJ_ATTR_Rec;


FUNCTION  GET_Price_Adj_Rltship_Rec
    RETURN  ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Price_Adj_Rltship_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Price_Adj_Rltship_Rec;

FUNCTION  GET_Sales_Credit_Rec
    RETURN  ASO_QUOTE_PUB.Sales_Credit_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Sales_Credit_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Sales_Credit_Rec;

FUNCTION  GET_Payment_Rec  RETURN  ASO_QUOTE_PUB.Payment_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Payment_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Payment_Rec;

FUNCTION  GET_Shipment_Rec  RETURN  ASO_QUOTE_PUB.Shipment_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Shipment_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Shipment_Rec;


FUNCTION  GET_Freight_Charge_Rec
    RETURN  ASO_QUOTE_PUB.Freight_Charge_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Freight_Charge_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Freight_Charge_Rec;

FUNCTION  GET_Tax_Detail_Rec  RETURN  ASO_QUOTE_PUB.Tax_Detail_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Tax_Detail_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Tax_Detail_Rec;

FUNCTION  GET_Tax_Control_Rec  RETURN  ASO_TAX_INT.Tax_control_rec_type
IS
    TMP_REC  ASO_TAX_INT.Tax_control_rec_type ;
BEGIN
    RETURN   TMP_REC;
END GET_Tax_Control_Rec;

FUNCTION  GET_Header_Rltship_Rec
    RETURN  ASO_QUOTE_PUB.Header_Rltship_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Header_Rltship_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Header_Rltship_Rec;


FUNCTION  GET_Line_Rltship_Rec  RETURN  ASO_QUOTE_PUB.Line_Rltship_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Line_Rltship_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Line_Rltship_Rec;

FUNCTION  GET_PARTY_RLTSHIP_Rec  RETURN  ASO_QUOTE_PUB.PARTY_RLTSHIP_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.PARTY_RLTSHIP_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_PARTY_RLTSHIP_Rec;

FUNCTION  GET_Related_Object_Rec
    RETURN  ASO_QUOTE_PUB.Related_Object_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Related_Object_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Related_Object_Rec;

FUNCTION  GET_RELATED_OBJ_Rec  RETURN  ASO_QUOTE_PUB.RELATED_OBJ_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.RELATED_OBJ_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END  GET_RELATED_OBJ_Rec;

FUNCTION  GET_Line_Attribs_Ext_Rec
    RETURN ASO_QUOTE_PUB.Line_Attribs_Ext_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Line_Attribs_Ext_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Line_Attribs_Ext_Rec;

FUNCTION  GET_Order_Header_Rec  RETURN  ASO_QUOTE_PUB.Order_Header_Rec_TYPE
IS
    TMP_REC  ASO_QUOTE_PUB.Order_Header_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Order_Header_Rec;

FUNCTION  GET_SUBMIT_CONTROL_REC	RETURN  ASO_QUOTE_PUB.Submit_Control_Rec_Type
IS
    TMP_REC  ASO_QUOTE_PUB.Submit_Control_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END Get_Submit_Control_Rec;


FUNCTION  GET_Sales_Alloc_Control_Rec   RETURN  ASO_QUOTE_PUB.Sales_Alloc_Control_Rec_Type
IS
    TMP_REC  ASO_QUOTE_PUB.Sales_Alloc_Control_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END Get_Sales_Alloc_Control_Rec;


FUNCTION  GET_Party_Rec		RETURN  ASO_PARTY_INT.Party_Rec_Type
IS
    TMP_REC  ASO_PARTY_INT.Party_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_Party_Rec;

FUNCTION  GET_Location_Rec	RETURN  ASO_PARTY_INT.Location_Rec_Type
IS
    TMP_REC  ASO_PARTY_INT.Location_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_Location_Rec;

FUNCTION  GET_Party_Site_Rec	RETURN  ASO_PARTY_INT.Party_Site_Rec_Type
IS
    TMP_REC  ASO_PARTY_INT.Party_Site_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_Party_Site_Rec;

FUNCTION  GET_Org_Contact_Rec	RETURN  ASO_PARTY_INT.Org_Contact_Rec_Type
IS
    TMP_REC  ASO_PARTY_INT.Org_Contact_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_Org_Contact_Rec;

FUNCTION  GET_Contact_Point_Rec
		RETURN ASO_PARTY_INT.Contact_Point_Rec_Type
IS
    TMP_REC  ASO_PARTY_INT.Contact_Point_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_Contact_Point_Rec;


FUNCTION  GET_Out_Contact_Point_Rec
		RETURN ASO_PARTY_INT.Out_Contact_Point_Rec_Type
IS
    TMP_REC   ASO_PARTY_INT.Out_Contact_Point_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_Out_Contact_Point_Rec;

FUNCTION  GET_Contact_Restriction_Rec
		RETURN ASO_PARTY_INT.Contact_Restrictions_Rec_Type
IS
    TMP_REC  ASO_PARTY_INT.Contact_Restrictions_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_Contact_Restriction_Rec;

 FUNCTION  GET_PRICING_CONTROL_REC	RETURN  ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE
IS
    TMP_REC   ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_PRICING_CONTROL_REC;

FUNCTION  GET_X_Order_Header_Rec	RETURN ASO_ORDER_INT.Order_Header_Rec_Type
IS
    TMP_REC   ASO_ORDER_INT.Order_Header_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_X_Order_Header_Rec;

FUNCTION  GET_X_Order_Line_Rec	        RETURN ASO_ORDER_INT.Order_Line_Rec_Type
IS
   TMP_REC   ASO_ORDER_INT.Order_Line_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_X_Order_Line_Rec;

FUNCTION  GET_X_Control_Rec	        RETURN ASO_ORDER_INT.Control_Rec_Type
IS
   TMP_REC   ASO_ORDER_INT.Control_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_X_Control_Rec;
FUNCTION  GET_QTE_IN_REC  RETURN  ASO_OPP_QTE_PUB.OPP_QTE_IN_REC_TYPE
IS
    TMP_REC  ASO_OPP_QTE_PUB.OPP_QTE_IN_REC_TYPE;
    BEGIN
	   RETURN   TMP_REC;
	   END GET_QTE_IN_REC;
FUNCTION  GET_QTE_OUT_REC  RETURN  ASO_OPP_QTE_PUB.OPP_QTE_OUT_REC_TYPE
IS
    TMP_REC  ASO_OPP_QTE_PUB.OPP_QTE_OUT_REC_TYPE;
    BEGIN
	   RETURN   TMP_REC;
	   END GET_QTE_OUT_REC;
FUNCTION GET_Qte_Access_Rec RETURN ASO_SECURITY_INT.Qte_Access_Rec_Type
IS
    TMP_REC ASO_SECURITY_INT.Qte_Access_Rec_Type;
    BEGIN
       RETURN   TMP_REC;
   END GET_Qte_Access_Rec;


FUNCTION GET_copy_qte_cntrl_Rec RETURN
ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type
IS
TMP_REC ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type;
BEGIN
RETURN   TMP_REC;
END GET_copy_qte_cntrl_Rec;


FUNCTION GET_copy_qte_hdr_Rec RETURN
ASO_COPY_QUOTE_PUB.Copy_Quote_Header_Rec_Type
IS
TMP_REC ASO_COPY_QUOTE_PUB.Copy_Quote_Header_Rec_Type ;
BEGIN
RETURN   TMP_REC;
END GET_copy_qte_hdr_Rec;


FUNCTION  GET_Def_Control_Rec  RETURN  ASO_DEFAULTING_INT.Control_Rec_Type
IS
   TMP_REC   ASO_DEFAULTING_INT.Control_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_Def_Control_Rec;


FUNCTION  GET_Header_Misc_Rec  RETURN  ASO_DEFAULTING_INT.Header_Misc_Rec_Type
IS
   TMP_REC   ASO_DEFAULTING_INT.Header_Misc_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_Header_Misc_Rec;


FUNCTION  GET_Line_Misc_Rec    RETURN  ASO_DEFAULTING_INT.Line_Misc_Rec_Type
IS
   TMP_REC   ASO_DEFAULTING_INT.Line_Misc_Rec_Type;
BEGIN
    RETURN   TMP_REC;
END GET_Line_Misc_Rec;


FUNCTION  GET_Attr_Codes_Tbl    RETURN  ASO_DEFAULTING_INT.ATTRIBUTE_CODES_TBL_TYPE
IS
   TMP_REC   ASO_DEFAULTING_INT.ATTRIBUTE_CODES_TBL_TYPE;
BEGIN
    RETURN   TMP_REC;
END GET_Attr_Codes_Tbl;


FUNCTION Decode(l_base_date DATE, comp1 DATE, date1 DATE, date2 DATE)
	RETURN DATE
IS
BEGIN
    IF l_base_date = comp1 THEN
	return date1;
    ELSE
	return date2;
    END IF;
END Decode;

-- Change START
-- Release 12 MOAC Changes : Bug 4500739
-- Changes Done by : Girish
-- Comments : The following functions are used for HR Extra Information Types

FUNCTION GET_OU_ATTRIBUTE_VALUE(p_attribute IN VARCHAR2, p_organization_id IN NUMBER) RETURN VARCHAR2
IS
	l_attribute_value	HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE; -- bug 12324106
BEGIN
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   aso_debug_pub.add('ASO_UTILITY_PVT: GET_OU_ATTRIBUTE_VALUE:  p_attribute   '||p_attribute,1,'Y');
	   aso_debug_pub.add('ASO_UTILITY_PVT: GET_OU_ATTRIBUTE_VALUE:  p_organization_id   '||p_organization_id,1,'Y');
     END IF;

	IF (p_attribute = G_DEFAULT_ORDER_TYPE) THEN
	BEGIN
	    SELECT ORG_INFORMATION1
	    INTO l_attribute_value
	    FROM hr_organization_information
	    WHERE org_information_context = 'ASO_ORG_INFO'
	    AND organization_id = p_organization_id ;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RETURN NULL ;
	END;
	ELSIF (p_attribute = G_DEFAULT_SALESREP) THEN
	BEGIN
	    SELECT ORG_INFORMATION2
	    INTO l_attribute_value
	    FROM hr_organization_information
	    WHERE org_information_context = 'ASO_ORG_INFO'
	    AND organization_id = p_organization_id ;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RETURN NULL ;
	END;
	ELSIF (p_attribute = G_DEFAULT_SALES_GROUP) THEN
	BEGIN
	    SELECT ORG_INFORMATION3
	    INTO l_attribute_value
	    FROM hr_organization_information
	    WHERE org_information_context = 'ASO_ORG_INFO'
	    AND organization_id = p_organization_id ;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RETURN NULL ;
	END;
	ELSIF (p_attribute = G_DEFAULT_SALES_ROLE) THEN
	BEGIN
	    SELECT ORG_INFORMATION4
	    INTO l_attribute_value
	    FROM hr_organization_information
	    WHERE org_information_context = 'ASO_ORG_INFO'
	    AND organization_id = p_organization_id ;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RETURN NULL ;
	END;
	ELSIF (p_attribute = G_DEFAULT_CONTRACT_TEMPLATE) THEN
	BEGIN
	    SELECT ORG_INFORMATION5
	    INTO l_attribute_value
	    FROM hr_organization_information
	    WHERE org_information_context = 'ASO_ORG_INFO'
	    AND organization_id = p_organization_id ;
	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RETURN NULL ;
	END;
	END IF;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   aso_debug_pub.add('ASO_UTILITY_PVT: GET_OU_ATTRIBUTE_VALUE:  l_attribute_value   '||l_attribute_value,1,'Y');
	END IF;

	RETURN l_attribute_value;

END GET_OU_ATTRIBUTE_VALUE;

FUNCTION GET_OU_ATTRIBUTE_VALUE(p_attribute IN VARCHAR2) RETURN VARCHAR2
IS
	l_attribute_value	HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE; -- bug 12324106
	l_organization_id	NUMBER ;
BEGIN

	l_organization_id := MO_GLOBAL.GET_CURRENT_ORG_ID;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('ASO_UTILITY_PVT: GET_OU_ATTRIBUTE_VALUE:  p_attribute   '||p_attribute,1,'Y');
		aso_debug_pub.add('ASO_UTILITY_PVT: GET_OU_ATTRIBUTE_VALUE:  l_organization_id   '||l_organization_id,1,'Y');
	END IF;

	l_attribute_value := GET_OU_ATTRIBUTE_VALUE(p_attribute, l_organization_id);


	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   aso_debug_pub.add('ASO_UTILITY_PVT: GET_OU_ATTRIBUTE_VALUE:  l_attribute_value   '||l_attribute_value,1,'Y');
	END IF;

	RETURN l_attribute_value;

END GET_OU_ATTRIBUTE_VALUE;

FUNCTION GET_DEFAULT_ORDER_TYPE RETURN VARCHAR2
IS
BEGIN
	RETURN G_DEFAULT_ORDER_TYPE;
END GET_DEFAULT_ORDER_TYPE;

FUNCTION GET_DEFAULT_SALESREP RETURN VARCHAR2
IS
BEGIN
	RETURN G_DEFAULT_SALESREP;
END GET_DEFAULT_SALESREP;

FUNCTION GET_DEFAULT_SALES_GROUP RETURN VARCHAR2
IS
BEGIN
	RETURN G_DEFAULT_SALES_GROUP;
END GET_DEFAULT_SALES_GROUP;

FUNCTION GET_DEFAULT_SALES_ROLE RETURN VARCHAR2
IS
BEGIN
	RETURN G_DEFAULT_SALES_ROLE;
END GET_DEFAULT_SALES_ROLE;

FUNCTION GET_DEFAULT_CONTRACT_TEMPLATE RETURN VARCHAR2
IS
BEGIN
	RETURN G_DEFAULT_CONTRACT_TEMPLATE;
END GET_DEFAULT_CONTRACT_TEMPLATE;

-- Change END

-- Change START
-- Release 12
-- Changes Done by : Girish
-- Comments : Procedure to add entry in ASO_CHANGED_QUOTES

PROCEDURE UPDATE_CHANGED_QUOTES (
	p_quote_number	ASO_CHANGED_QUOTES.QUOTE_NUMBER%TYPE
)
IS

	l_module_name  VARCHAR2(30) := 'ASO';
	l_source_name  VARCHAR2(50) := 'asovutlb.pls';
	l_error_text   VARCHAR2(2000);

	l_quote_number		ASO_CHANGED_QUOTES.QUOTE_NUMBER%TYPE;
	l_conc_request_id	ASO_CHANGED_QUOTES.CONC_REQUEST_ID%TYPE;
	l_to_insert		NUMBER ;
	l_found_rec		NUMBER ;

	G_USER_ID	  NUMBER := FND_GLOBAL.USER_ID;
	G_LOGIN_ID	  NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

	CURSOR cur_find_rec(p_quote_number ASO_CHANGED_QUOTES.QUOTE_NUMBER%TYPE) IS
	SELECT quote_number, conc_request_id
	FROM   aso_changed_quotes
	WHERE  quote_number = p_quote_number;
BEGIN

	l_to_insert := 0;
	l_found_rec := 0;

	OPEN cur_find_rec(p_quote_number);
	IF cur_find_rec%ISOPEN THEN
		LOOP
			FETCH  cur_find_rec INTO l_quote_number, l_conc_request_id ;

			IF (cur_find_rec%ROWCOUNT = 0) THEN
				IF aso_debug_pub.g_debug_flag = 'Y' THEN
					aso_debug_pub.add('ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES : No record found for the quote number, inserting the new record.', 1, 'Y');
				END IF;
				l_to_insert := 1;
			END IF ;

			EXIT WHEN cur_find_rec%NOTFOUND ;

			IF (l_conc_request_id IS NOT null)
			THEN
				-- Record exists but a conc request id is also present, hence insert the record
				IF aso_debug_pub.g_debug_flag = 'Y' THEN
					aso_debug_pub.add('ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES : Found record with quote number passed but the conc request id is not null, hence inserting the new record.', 1, 'Y');
				END IF;
				l_to_insert := 1;
			END IF;

			IF (l_conc_request_id IS null)
			THEN
				-- Record exists with a null conc request id, hence we need not insert a new record
				IF aso_debug_pub.g_debug_flag = 'Y' THEN
					aso_debug_pub.add('ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES : Found record with quote number and the conc request id is null, hence no need to insert the new record.', 1, 'Y');
				END IF;
				l_found_rec := 1;
			END IF;

		END LOOP ;
		CLOSE  cur_find_rec;
ELSE
	-- TBD : If the cursor does not open, then insert the record or not?
	l_to_insert := 1;
END IF;

IF (l_found_rec = 1) THEN
	l_to_insert := 0;
END IF;


IF (l_to_insert = 1) THEN

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES : Before Inserting record in ASO_CHANGED_QUOTES', 1, 'Y');
		aso_debug_pub.add('ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES : Quote Number : ' || p_quote_number, 1, 'Y');
	END IF;

	ASO_CHANGED_QUOTES_PKG.INSERT_ROW(
		P_QUOTE_NUMBER			=> p_quote_number,
		P_LAST_UPDATE_DATE		=> SYSDATE,
		P_LAST_UPDATED_BY		=> G_USER_ID,
		P_CREATION_DATE			=> SYSDATE,
		P_CREATED_BY			=> G_USER_ID,
		P_LAST_UPDATE_LOGIN		=> G_LOGIN_ID,
		P_REQUEST_ID			=> FND_API.G_MISS_NUM,
		P_PROGRAM_APPLICATION_ID	=> FND_API.G_MISS_NUM,
		P_PROGRAM_ID			=> FND_API.G_MISS_NUM,
		P_PROGRAM_UPDATE_DATE		=> FND_API.G_MISS_DATE,
		P_CONC_REQUEST_ID		=> FND_API.G_MISS_NUM
	);

END IF;

EXCEPTION
WHEN OTHERS THEN
	l_error_text := 'Error in ASO_UTILITY_PVT.UPDATE_CHANGED_QUOTES : ' || SQLERRM;
	aso_upgrade_pvt.add_message( p_module_name => l_module_name,
				     p_error_level => 'ERROR',
				     p_error_text  => l_error_text,
				     p_source_name => l_source_name
				   );

END UPDATE_CHANGED_QUOTES;

-- Change END

--Procedure added by Anoop Rajan on 30/09/2005 to print login details
procedure print_login_info is
	cursor CUR_MO_GLOB is select
		ORGANIZATION_ID,
		ORGANIZATION_NAME
	FROM MO_GLOB_ORG_ACCESS_TMP;

	l_security_profile_id  NUMBER;
	l_org_id	     NUMBER;
	l_def_org_id	     NUMBER;
	l_file		VARCHAR2(200);
begin
	IF (aso_debug_pub.g_debug_flag = 'Y' ) THEN

		aso_debug_pub.add( '*******************************************',1, 'Y' );
		aso_debug_pub.add( '*****  Printing the Variable Values   *****',1, 'Y' );
		aso_debug_pub.add( '*******************************************',1, 'Y' );
		aso_debug_pub.add( '						',1, 'Y' );

			aso_debug_pub.add(rpad('USER ID',50,'------')||'------>'||FND_GLOBAL.USER_ID , 1, 'Y');
			aso_debug_pub.add(rpad('RESPONSIBILITY ID',50,'------')||'------>'||FND_GLOBAL.RESP_ID , 1, 'Y');
			aso_debug_pub.add(rpad('RESPONSIBILITY APPLICATION ID',50,'------')||'------>'||FND_GLOBAL.RESP_APPL_ID , 1, 'Y');
			aso_debug_pub.add(rpad('USER NAME',50,'------')||'------>'||FND_GLOBAL.USER_NAME , 1, 'Y');
			aso_debug_pub.add(rpad('RESPONSIBILITY NAME',50,'------')||'------>'||FND_GLOBAL.RESP_NAME , 1, 'Y');
			aso_debug_pub.add(rpad('APPLICATION NAME',50,'------')||'------>'||FND_GLOBAL.APPLICATION_NAME , 1, 'Y');
			aso_debug_pub.add(rpad('APPLICATION SHORT NAME',50,'------')||'------>'||FND_GLOBAL.APPLICATION_SHORT_NAME , 1, 'Y');

		aso_debug_pub.add( '						',1, 'Y' );


		aso_debug_pub.add( '******************************************',1, 'Y' );
		aso_debug_pub.add( '*****  Printing the profile values   *****',1, 'Y' );
		aso_debug_pub.add( '******************************************',1, 'Y' );
		aso_debug_pub.add( '						',1, 'Y' );

			fnd_profile.get('XLA_MO_SECURITY_PROFILE_LEVEL',l_security_profile_id);
			fnd_profile.get('DEFAULT_ORG_ID',l_def_org_id);
			fnd_profile.get('ORG_ID',l_org_id);
			aso_debug_pub.add(rpad('SECURITY PROFILE ID',50,'------')||'------>'||l_security_profile_id , 1, 'Y');
			aso_debug_pub.add(rpad('DEFAULT ORG ID',50,'------')||'------>'||l_def_org_id , 1, 'Y');
			aso_debug_pub.add(rpad('ORG ID',50,'------')||'------>'||l_org_id , 1, 'Y');

		aso_debug_pub.add( '						',1, 'Y' );


		aso_debug_pub.add( '********************************************************',1, 'Y' );
		aso_debug_pub.add( '*****  Printing the MO_GLOB_ORG_ACCESS_TMP details *****',1, 'Y' );
		aso_debug_pub.add( '********************************************************',1, 'Y' );
		aso_debug_pub.add( '						',1, 'Y' );

			aso_debug_pub.add(rpad('ORGANIZATION_ID',50,'------')||'<----->'||rpad('ORGANIZATION_NAME',50,' ') , 1, 'Y');
			for i in CUR_MO_GLOB loop
				aso_debug_pub.add(rpad(i.ORGANIZATION_ID,50,'------')||'------>'||rpad(i.ORGANIZATION_NAME,50,' '), 1, 'Y');
			end loop;

		aso_debug_pub.add( '						',1, 'Y' );


		aso_debug_pub.add( '********************************************************',1, 'Y' );
		aso_debug_pub.add( '**************  Printing the ORG details  **************',1, 'Y' );
		aso_debug_pub.add( '********************************************************',1, 'Y' );
		aso_debug_pub.add( '						',1, 'Y' );

			aso_debug_pub.add(rpad('CURRENT ORG ID',50,'------')||'------>'||MO_GLOBAL.get_current_org_id , 1, 'Y');
			aso_debug_pub.add(rpad('ACCESS MODE',50,'------')||'------>'||MO_GLOBAL.get_access_mode , 1, 'Y');
			aso_debug_pub.add(rpad('OPERATING UNITS COUNT',50,'------')||'------>'||MO_GLOBAL.get_ou_count , 1, 'Y');
			aso_debug_pub.add(rpad('DEFAULT ORG_ID',50,'------')||'------>'||MO_UTILS.get_default_org_id , 1, 'Y');
			aso_debug_pub.add(rpad('SYS CONTEXT',50,'------')||'------>'||sys_context('multi_org2','current_org_id') , 1, 'Y');

		aso_debug_pub.add( '						',1, 'Y' );

	END IF;
END print_login_info;


FUNCTION  Tax_Rec_Exists( p_tax_rec IN ASO_QUOTE_PUB.Tax_Detail_Rec_Type ) RETURN BOOLEAN
IS

BEGIN
     IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Begin tax_Rec_Exists function.', 1, 'Y');
     END IF;

     IF (         P_tax_rec.ATTRIBUTE1<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE10<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE11<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE12<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE13<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE14<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE15<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE2<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE3<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE4<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE5<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE6<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE7<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE8<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE9<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.ATTRIBUTE_CATEGORY<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.CREATED_BY<> FND_API.G_MISS_NUM OR
                  P_tax_rec.CREATION_DATE<> FND_API.G_MISS_DATE OR
                  P_tax_rec.LAST_UPDATED_BY<> FND_API.G_MISS_NUM OR
                  P_tax_rec.LAST_UPDATE_DATE<> FND_API.G_MISS_DATE OR
                  P_tax_rec.LAST_UPDATE_LOGIN<> FND_API.G_MISS_NUM OR
                  P_tax_rec.ORIG_TAX_CODE<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.PROGRAM_APPLICATION_ID<> FND_API.G_MISS_NUM OR
                  P_tax_rec.PROGRAM_ID<> FND_API.G_MISS_NUM OR
                  P_tax_rec.PROGRAM_UPDATE_DATE<> FND_API.G_MISS_DATE OR
                  P_tax_rec.QUOTE_HEADER_ID<> FND_API.G_MISS_NUM OR
                  P_tax_rec.QUOTE_LINE_ID<> FND_API.G_MISS_NUM OR
                  P_tax_rec.QUOTE_SHIPMENT_ID<> FND_API.G_MISS_NUM OR
                  P_tax_rec.REQUEST_ID<> FND_API.G_MISS_NUM OR
                  P_tax_rec.TAX_AMOUNT<> FND_API.G_MISS_NUM OR
                  P_tax_rec.TAX_CODE<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.TAX_DATE<> FND_API.G_MISS_DATE OR
                  P_tax_rec.TAX_DETAIL_ID<> FND_API.G_MISS_NUM OR
                  P_tax_rec.TAX_EXEMPT_FLAG<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.TAX_EXEMPT_NUMBER<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.TAX_EXEMPT_REASON_CODE<> FND_API.G_MISS_CHAR OR
                  P_tax_rec.TAX_RATE<> FND_API.G_MISS_NUM ) THEN

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Tax_Rec_Exists function returning TRUE');
              END IF;

              return TRUE;

     ELSE

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
              aso_debug_pub.add('Tax_Rec_Exists function returning FALSE');
              END IF;

              return FALSE;

     END IF;

END Tax_Rec_Exists;


END ASO_UTILITY_PVT;


/
