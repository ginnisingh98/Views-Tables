--------------------------------------------------------
--  DDL for Package Body QOT_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QOT_DEFAULT_PVT" AS
/* $Header: qotvdefb.pls 120.22 2007/11/08 12:00:05 akushwah ship $ */
-- Package name     : QOT_DEFAULT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_USER_ID     NUMBER                := FND_GLOBAL.USER_ID;

FUNCTION Get_OperatingUnit(P_Database_Object_Name IN VARCHAR2,
					P_Attribute_Code	IN VARCHAR2) RETURN NUMBER

IS

	l_default_org_id	NUMBER;
	l_default_org_name	VARCHAR2(240);
	l_ou_count		NUMBER;

BEGIN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_OperatingUnit Default -- Begin :',1,'N');
	END IF;

	MO_UTILS.GET_DEFAULT_OU( P_DEFAULT_ORG_ID 	=> l_default_org_id,
						P_DEFAULT_OU_NAME 	=> l_default_org_name,
						P_OU_COUNT 		=> l_ou_count
						);
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_OperatingUnit Default Organization Id :' ||l_default_org_id,1,'N');
	aso_debug_pub.add('Function Get_OperatingUnit Default Organization Name :'||l_default_org_name,1,'N');
	END IF;

	IF l_default_org_id is not null THEN
		mo_global.set_policy_context('S',l_default_org_id);
	END IF;

RETURN l_default_org_id;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_OperatingUnit NO_DATA_FOUND Exception Occurs: ',1,'N');
	END IF;

		RETURN NULL;

    	WHEN OTHERS THEN

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_OperatingUnit Inside When Others Exception',1,'N');
	END IF;

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_OperatingUnit '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_OperatingUnit;


FUNCTION Get_OrderType(P_Database_Object_Name IN VARCHAR2,
					P_Attribute_Code	IN VARCHAR2) RETURN NUMBER

IS

	l_order_type_id	NUMBER;
	l_org_id			NUMBER;

BEGIN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_OrderType Default -- Begin :',1,'N');
	END IF;

	IF p_database_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN
    		l_org_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_Org_id;
	ELSIF p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
		l_org_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.O_Org_id;
	END IF;

    l_order_type_id := aso_utility_pvt.get_ou_attribute_value(aso_utility_pvt.GET_DEFAULT_ORDER_TYPE,l_org_id);

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_OrderType Default Organization Id :' ||l_order_type_id,1,'N');
	END IF;

RETURN l_order_type_id;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_OrderType NO_DATA_FOUND Exception Occurs: ',1,'N');
	END IF;

		RETURN NULL;

    	WHEN OTHERS THEN

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_OrderType Inside When Others Exception',1,'N');
	END IF;

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_OrderType '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_OrderType;

FUNCTION Get_ContractTemplate(P_Database_Object_Name IN VARCHAR2,
					P_Attribute_Code	IN VARCHAR2) RETURN NUMBER

IS

	l_contract_template_id	NUMBER;
	l_org_id				NUMBER;

BEGIN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ContractTemplate Default -- Begin :',1,'N');
	END IF;

	IF p_database_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN
    		l_org_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_Org_id;
	ELSIF p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
		l_org_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.O_Org_id;
	END IF;

	l_contract_template_id := aso_utility_pvt.get_ou_attribute_value(aso_utility_pvt.GET_DEFAULT_CONTRACT_TEMPLATE,l_org_id);

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('Function Get_ContractTemplate Contract_Template_Id :' ||l_contract_template_id,1,'N');
	END IF;

RETURN l_contract_template_id;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_ContractTemplate NO_DATA_FOUND Exception Occurs: ',1,'N');
	END IF;

		RETURN NULL;

    	WHEN OTHERS THEN

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ContractTemplate Inside When Others Exception',1,'N');
	END IF;

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_ContractTemplate '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_ContractTemplate;

FUNCTION Get_CustAcct_From_CustParty (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS

    CURSOR C_Get_Acct_Count(l_party NUMBER) IS
     SELECT count(rowid)
     FROM HZ_CUST_ACCOUNTS
     WHERE party_id = l_party
     AND status = 'A'
     AND trunc(sysdate) BETWEEN trunc(NVL(account_activation_date, sysdate))
     		AND trunc(NVL(account_termination_date, sysdate));

    CURSOR C_Get_Acct (l_party NUMBER) IS
     SELECT Cust_Account_Id
     FROM HZ_CUST_ACCOUNTS
     WHERE Party_Id = l_party
     AND status = 'A'
     AND trunc(sysdate) BETWEEN trunc(NVL(account_activation_date, sysdate))
     		AND trunc(NVL(account_termination_date, sysdate));

    CURSOR C_oldest_Account(l_party NUMBER) IS
    SELECT CUST_ACCOUNT_ID
    FROM HZ_CUST_ACCOUNTS
    WHERE Party_id = l_party
    AND status = 'A'
    AND trunc(sysdate) BETWEEN trunc(NVL(account_activation_date, sysdate)) AND
            trunc(NVL(account_termination_date, sysdate))
    AND ROWNUM = 1
    ORDER BY account_activation_date;

   l_party_id    NUMBER;
   l_ret_value   NUMBER;
   l_acct_count  NUMBER;

BEGIN

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_CustAcct_From_CustParty -- Begin :',1,'N');
END IF;

   	IF p_database_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN
    		l_party_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_cust_party_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_CustAcct_From_CustParty Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_party_id : ' || l_party_id ,1,'N');
		END IF;

	ELSIF p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
		l_party_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_oppty_cust_party_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_CustAcct_From_CustParty Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_party_id : ' || l_party_id ,1,'N');
		END IF;

	END IF;

    OPEN C_Get_Acct_Count (l_party_id);
    FETCH C_Get_Acct_Count INTO l_acct_count;
    CLOSE C_Get_Acct_Count;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_CustAcct_From_CustParty Cursor C_Get_Acct_Count l_acct_count : ' ||
	l_acct_count ,1,'N');
	END IF;

    IF l_acct_count > 1 THEN
    	   OPEN C_oldest_Account(l_party_id);
	   FETCH C_oldest_Account INTO l_ret_value;
	   CLOSE C_oldest_Account;
    ELSE

        OPEN C_Get_Acct (l_party_id);
        FETCH C_Get_Acct INTO l_ret_value;
        CLOSE C_Get_Acct;
    END IF;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_CustAcct_From_CustParty Returns : ' || l_ret_value ,1,'N');
	END IF;

RETURN l_ret_value;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_CustAcct_From_CustParty NO_DATA_FOUND Exception Occurs: ',1,'N');
	END IF;

		RETURN NULL;

    	WHEN OTHERS THEN

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_CustAcct_From_CustParty Inside When Others Exception',1,'N');
	END IF;

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_CustAcct_From_CustParty '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_CustAcct_From_CustParty;

FUNCTION Get_PriceList_From_Agreement (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS

    CURSOR C_Get_PL (l_agreement_id NUMBER) IS
     SELECT Price_List_Id
     FROM OE_AGREEMENTS_B
     WHERE Agreement_Id = l_agreement_id
     AND sysdate BETWEEN nvl(Start_Date_Active,sysdate) AND nvl(End_Date_Active,sysdate);

   l_agreement_id    NUMBER;
   l_ret_value   	 NUMBER;

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_PriceList_From_Agreement -- Begin :',1,'N');
END IF;


	IF p_database_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN
    		l_agreement_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_contract_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PriceList_From_Agreement Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_agreement_id : ' || l_agreement_id ,1,'N');
		END IF;

	ELSIF p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
		l_agreement_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_contract_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PriceList_From_Agreement Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_agreement_id : ' || l_agreement_id ,1,'N');
		END IF;
	ELSIF p_database_object_name = 'ASO_AK_QUOTE_LINE_V' THEN
		l_agreement_id := ASO_QUOTE_LINE_DEF_HDLR.g_record.l_agreement_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PriceList_From_Agreement Database Object ASO_AK_QUOTE_LINE_V '||
		' l_agreement_id : ' || l_agreement_id ,1,'N');
		END IF;
	END IF;

    	OPEN C_Get_PL (l_agreement_id);
	FETCH C_Get_PL INTO l_ret_value;
	CLOSE C_Get_PL;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_PriceList_From_Agreement Cursor C_Get_PL l_ret_vaule : ' ||
	l_ret_value,1,'N');
	END IF;

    RETURN l_ret_value;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_PriceList_From_Agreement NO_DATA_FOUND Exception Occurs: ',1,'N');
	END IF;

		RETURN NULL;

    WHEN OTHERS THEN

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PriceList_From_Agreement Inside When Others Exception',1,'N');
	END IF;

	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_PriceList_From_Agreement '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_PriceList_From_Agreement;


FUNCTION Get_PriceList_From_CustAcct (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS

    CURSOR C_Get_PL (l_acct NUMBER) IS
     SELECT Price_List_Id
     FROM HZ_CUST_ACCOUNTS
     WHERE Cust_Account_Id = l_acct
     AND Status = 'A';

    CURSOR C_Get_CustAcct(l_header_id NUMBER) IS
    SELECT cust_account_id
    FROM ASO_QUOTE_HEADERS_ALL
    WHERE quote_header_id = l_header_id;


   l_acct_id     NUMBER;
   l_ret_value   NUMBER;
   l_quote_header_id NUMBER;

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_PriceList_From_CustAcct -- Begin :',1,'N');
END IF;

	IF p_database_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN
    		l_acct_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_cust_account_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PriceList_From_CustAcct Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_acct_id : ' || l_acct_id ,1,'N');
		END IF;

	ELSIF p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
		l_acct_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_cust_account_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PriceList_From_CustAcct Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_acct_id : ' || l_acct_id ,1,'N');
		END IF;

	END IF;

    OPEN C_Get_PL (l_acct_id);
    FETCH C_Get_PL INTO l_ret_value;
    CLOSE C_Get_PL;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_PriceList_From_CustAcct Cursor C_Get_PL l_rel_value : ' ||
	l_ret_value ,1,'N');
	END IF;

    RETURN l_ret_value;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_PriceList_From_CustAcct NO_DATA_FOUND Exception Occurs: ',1,'N');
	END IF;

		RETURN NULL;

    WHEN OTHERS THEN

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PriceList_From_CustAcct Inside When Others Exception',1,'N');
	END IF;

	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_PriceList_From_CustAcct '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_PriceList_From_CustAcct;


FUNCTION Get_PriceList_From_OrderType (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS

   l_order_type_id NUMBER;
   l_ret_value   NUMBER;

    CURSOR C_Get_PL (l_order_type NUMBER) IS
     SELECT Price_List_Id
     FROM OE_TRANSACTION_TYPES_ALL
     WHERE Transaction_Type_Id = l_order_type
     AND sysdate BETWEEN nvl(Start_Date_Active,sysdate) AND nvl(End_Date_Active,sysdate);


BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_PriceList_From_OrderType -- Begin : ',1,'N');
END IF;

	IF p_database_object_name='ASO_AK_QUOTE_HEADER_V' THEN
	    l_order_type_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_order_type_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PriceList_From_OrderType Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_order_type_id : ' || l_order_type_id ,1,'N');
		END IF;

	ELSIF p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
		l_order_type_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_order_type_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PriceList_From_OrderType Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_order_type_id : ' || l_order_type_id ,1,'N');
		END IF;
 	END IF;

	OPEN C_Get_PL (l_order_type_id);
	FETCH C_Get_PL INTO l_ret_value;
	CLOSE C_Get_PL;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_PriceList_From_OrderType l_ret_value : ' || l_ret_value ,1,'N');
	END IF;

    RETURN l_ret_value;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_PriceList_From_OrderType NO_DATA_FOUND Exception Occurs: ',1,'N');
	END IF;

		RETURN NULL;

    WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PriceList_From_OrderType Inside When Others Exception',1,'N');
	END IF;

	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_PriceList_From_OrderType '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_PriceList_From_OrderType;


FUNCTION Get_PaymentTerm_From_Agreement (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS

    CURSOR C_Get_PayTerm (l_agreement_id NUMBER) IS
     SELECT Term_Id
     FROM OE_AGREEMENTS_B
     WHERE Agreement_Id = l_agreement_id
     AND sysdate BETWEEN nvl(Start_Date_Active,sysdate) AND nvl(End_Date_Active,sysdate);

   l_agreement_id    NUMBER;
   l_ret_value   NUMBER;

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_PaymentTerm_From_Agreement --- Begin : ' ,1,'N');
END IF;

   IF p_database_object_name='ASO_AK_QUOTE_HEADER_V' THEN
    		l_agreement_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_contract_id;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_PaymentTerm_From_Agreement Database Object ASO_AK_QUOTE_HEADER_V '||
	' l_agreement_id : ' || l_agreement_id ,1,'N');
	END IF;

   ELSIF p_database_object_name='ASO_AK_QUOTE_OPPTY_V' THEN
		l_agreement_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_contract_id;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_PaymentTerm_From_Agreement Database Object ASO_AK_QUOTE_OPPTY_V '||
	' l_agreement_id : ' || l_agreement_id ,1,'N');
	END IF;

   END IF;

    OPEN C_Get_PayTerm (l_agreement_id);
    FETCH C_Get_PayTerm INTO l_ret_value;
    CLOSE C_Get_PayTerm;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_PaymentTerm_From_Agreement Cursor C_Get_PayTerm l_ret_value: '||
	l_ret_value ,1,'N');
	END IF;
    RETURN l_ret_value;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_PaymentTerm_From_Agreement NO_DATA_FOUND Exception Occurs: ',1,'N');
	END IF;

		RETURN NULL;
    	WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PaymentTerm_From_Agreement Inside When Others Exception',1,'N');
	END IF;

	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_PaymentTerm_From_Agreement '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_PaymentTerm_From_Agreement;

FUNCTION Get_PaymentTerm_From_Customer (
			P_Database_Object_Name    IN   VARCHAR2,
            	P_Attribute_Code          IN   VARCHAR2 ) RETURN NUMBER
IS

    Cursor default_payment_term_customer(l_cust_account_id NUMBER) Is
    select hcp.standard_terms
    from hz_cust_accounts hca,
         hz_customer_profiles hcp
    where  hcp.cust_account_id = hca.cust_account_id
    and    hca.cust_account_id = l_cust_account_id
    and    nvl(hcp.status,'A') = 'A';
   l_cust_acct_id 	number;
   l_term_id Number;

 Begin
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_PaymentTerm_From_Customer  --- Begin : ' ,1,'N');
END IF;

  	IF p_database_object_name='ASO_AK_QUOTE_HEADER_V' THEN
    		l_cust_acct_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_Cust_Account_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   aso_debug_pub.add('Function Get_PaymentTerm_From_Customer Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_cust_acct_id : ' || l_cust_acct_id ,1,'N');
		END IF;
	ELSIF p_database_object_name='ASO_AK_QUOTE_OPPTY_V' THEN
		l_cust_acct_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_cust_account_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PaymentTerm_From_Customer Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_cust_acct_id : ' || l_cust_acct_id ,1,'N');
		END IF;
	END IF;

         Open default_payment_term_customer(l_cust_acct_id);
         Fetch default_payment_term_customer into l_term_id;
  	    CLOSE default_payment_term_customer;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PaymentTerm_From_Customer Cursor default_payment_term_customer '||
		' l_term_id : ' || l_term_id ,1,'N');
		END IF;

	    RETURN l_term_id;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_PaymentTerm_From_Customer NO_DATA_FOUND Exception Occurs: ',1,'N');
	END IF;
		RETURN NULL;

    	WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_PaymentTerm_From_Customer Inside When Others Exception',1,'N');
	END IF;

	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_PaymentTerm_From_Customer '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_PaymentTerm_From_Customer;

FUNCTION Get_ExpirationDate (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN DATE
IS

      CURSOR C_Get_Expiration_Date (l_Def_Cal VARCHAR2, l_Def_Per VARCHAR2) IS
         SELECT End_Date
         FROM   GL_PERIODS_V
         WHERE  Period_Type = l_Def_Per
         AND    Period_Set_Name = l_Def_Cal
         AND    SYSDATE BETWEEN NVL(Start_Date,sysdate) AND NVL(End_Date,sysdate);

      l_Default_Cal_Prof VARCHAR2(15):= FND_PROFILE.VALUE ('ASO_DEFAULT_EXP_GL_CAL' );
      l_Default_Per_Prof VARCHAR2(15):= FND_PROFILE.VALUE ('ASO_DEFAULT_EXP_GL_PERIOD' );
      l_qte_duration_prof NUMBER     := NVL(FND_PROFILE.VALUE ('ASO_QUOTE_DURATION'),30);

      l_Quote_Exp_Date   DATE;

BEGIN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_ExpiraionDate  -- Begin: ',1,'N');
	END IF;

     IF l_Default_Cal_Prof IS NOT NULL
          AND l_Default_Per_Prof IS NOT NULL THEN

         	OPEN C_Get_Expiration_Date(l_Default_Cal_Prof , l_Default_Per_Prof );
         	FETCH C_Get_Expiration_Date INTO l_Quote_Exp_Date;
		CLOSE C_Get_Expiration_Date;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ExpirationDate Cursor C_Get_Expiration_Date l_Quote_Exp_Date : '||
		l_Quote_Exp_Date ,1,'N');
		END IF;

	    	IF l_Quote_Exp_Date IS NULL THEN
		   l_Quote_Exp_Date := SYSDATE + l_Qte_Duration_Prof;
			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Function Get_ExpirationDate Cursor C_Get_Expiration_Date returns ' ||
			' l_Quote_Exp_Date AS Null Then l_Quote_Exp_Date :' || l_Quote_Exp_Date ,1,'N');
			END IF;

		   	RETURN l_Quote_Exp_Date;

	    	END IF;

         	RETURN l_Quote_Exp_Date;



     ELSE

         	l_Quote_Exp_Date := SYSDATE + l_Qte_Duration_Prof;

	 	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ExpirationDate if Profile ASO_DEFAULT_EXP_GL_CAL and Profile '||                 ' ASO_DEFAULT_EXP_GL_PERIOD ARE NULL Then  l_Quote_Exp_Date : ' || l_Quote_Exp_Date ,1,'N');
		END IF;

       	RETURN l_Quote_Exp_Date;

     END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_ExpirationDate NO_DATA_FOUND Exception Occurs: ',1,'N');
	END IF;

		RETURN NULL;
    WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ExpirationDate Inside When Others Exception',1,'N');
	END IF;
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_ExpirationDate '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_ExpirationDate;





FUNCTION Get_QuotePhone (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS

   CURSOR C_Get_Type (l_party NUMBER) IS
    SELECT Party_Type
    FROM HZ_PARTIES
    WHERE Party_Id = l_party
    AND Status = 'A';

   CURSOR C_Get_Phone (l_party NUMBER) IS
    SELECT Contact_Point_Id
    FROM HZ_CONTACT_POINTS
    WHERE Owner_Table_Id = l_party
    AND Owner_Table_Name = 'HZ_PARTIES'
    AND Contact_Point_Type = 'PHONE'
    AND Status = 'A'
    AND Primary_Flag = 'Y';

   l_party_id             NUMBER;
   l_cust_party_id        NUMBER;
   l_ret_value            NUMBER;
   l_cust_party_type      VARCHAR2(15);

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_QuotePhone --- Begin ',1,'N');
END IF;

	IF p_database_object_name='ASO_AK_QUOTE_HEADER_V' THEN
	    	l_cust_party_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.q_cust_party_id;
	    	l_party_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.q_party_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuotePhone Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_cust_party_id :' || l_cust_party_id ,1,'N');
		aso_debug_pub.add('Function Get_QuotePhone Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_party_id :' || l_party_id ,1,'N');
		END IF;

	ELSIF p_database_object_name='ASO_AK_QUOTE_OPPTY_V' THEN
		--l_cust_party_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_cust_party_id; --Bug#5195151
		l_cust_party_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_oppty_cust_party_id;
		l_party_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_party_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuotePhone Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_cust_party_id :' || l_cust_party_id ,1,'N');
		aso_debug_pub.add('Function Get_QuotePhone Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_party_id :' || l_party_id ,1,'N');
		END IF;

	END IF;

    OPEN C_Get_Type (l_cust_party_id);
    FETCH C_Get_Type INTO l_cust_party_type;
    CLOSE C_Get_Type;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_QuotePhone Customer Party Type : '||l_cust_party_type,1,'N');
	END IF;

    IF l_cust_party_type = 'PERSON' THEN

       	OPEN C_Get_Phone (l_cust_party_id);
	   	FETCH C_Get_Phone INTO l_ret_value;
	   	CLOSE C_Get_Phone;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuotePhone Customer Party Type is PERSON l_ret_value: '||
		l_ret_value,1,'N');
		END IF;
    ELSE

	   IF l_party_id IS NOT NULL AND l_party_id <> FND_API.G_MISS_NUM THEN
            OPEN C_Get_Phone (l_party_id);
            FETCH C_Get_Phone INTO l_ret_value;
            CLOSE C_Get_Phone;
	   END IF;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_QuotePhone Customer Party Type is Organization l_ret_value:'||
	l_ret_value,1,'N');
	END IF;

    END IF;

    RETURN l_ret_value;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuotePhone NO_DATA_FOUND Exception Occurs : ',1,'N');
	END IF;

		RETURN NULL;
    WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuotePhone Inside When Others Exception',1,'N');
	END IF;

	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_QuotePhone '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_QuotePhone;

FUNCTION Get_QuoteAddress(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS

   CURSOR C_Get_Type (l_party NUMBER) IS
    SELECT Party_Type
    FROM HZ_PARTIES
    WHERE Party_Id = l_party
    AND Status = 'A';

    CURSOR C_Use_Exists (l_party NUMBER) IS
     SELECT A.Party_Site_Id
     FROM HZ_PARTY_SITES A, HZ_PARTY_SITE_USES B
     WHERE A.Party_Id = l_party
     AND A.Party_Site_Id = B.Party_Site_Id
     AND B.Site_Use_Type = 'SOLD_TO'
     AND B.Primary_Per_Type = 'Y'
     AND A.Status = 'A'
     AND B.Status = 'A';

    CURSOR C_Get_PrAddr (l_party NUMBER) IS
     SELECT Party_Site_Id
     FROM HZ_PARTY_SITES
     WHERE Party_Id = l_party
     AND Identifying_Address_Flag = 'Y'
     AND Status = 'A';

l_cust_party_type      VARCHAR2(15);
l_cust_party_id        NUMBER;
l_party_id             NUMBER;
x_party_site_id        NUMBER;

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_QuoteAddress --- Begin :',1,'N');
END IF;

	IF p_database_object_name='ASO_AK_QUOTE_HEADER_V' THEN
  		l_cust_party_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_cust_party_id;
		l_party_id      := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_party_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuoteAddress Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_cust_party_id :' || l_cust_party_id ,1,'N');
		aso_debug_pub.add('Function Get_QuoteAddress Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_party_id :' || l_party_id ,1,'N');
		END IF;

	ELSIF p_database_object_name='ASO_AK_QUOTE_OPPTY_V' THEN
		--l_cust_party_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_cust_party_id; --Bug#5195151
		l_cust_party_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_oppty_cust_party_id;
		l_party_id   	 := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_party_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuoteAddress Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_cust_party_id :' || l_cust_party_id ,1,'N');
		aso_debug_pub.add('Function Get_QuoteAddress Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_party_id :' || l_party_id ,1,'N');
		END IF;
	END IF;

   OPEN C_Get_Type (l_cust_party_id);
   FETCH C_Get_Type INTO l_cust_party_type;
   CLOSE C_Get_Type;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_QuoteAddress Cursor C_Get_Type l_cust_party_type :'||
	l_cust_party_type,1,'N');
	END IF;

	/* if Party is PERSON */
IF l_cust_party_type = 'PERSON' THEN
  	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_QuoteAddress IF l_cust_party_type is PERSON :',1,'N');
	END IF;
	 /* Get Primary Sold To Address for Quote to Customer */
      OPEN C_Use_Exists (l_cust_party_id);
      FETCH C_Use_Exists INTO x_party_site_id;
      CLOSE C_Use_Exists;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_QuoteAddress Cursor C_Use_Exists Primary Address ' ||
	' x_party_site_id :' ||x_party_site_id ,1,'N');
	END IF;
    IF x_party_site_id IS NULL THEN
	    /* Get Identifying Address for Quote to Customer */
         OPEN C_Get_PrAddr (l_cust_party_id);
         FETCH C_Get_PrAddr INTO x_party_site_id;
         CLOSE C_Get_PrAddr;
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuoteAddress Cursor C_Get_PrAddr Identifying Address'||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
		END IF;
    END IF;

ELSE
	/* If Party Type is Organization */
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_QuoteAddress IF l_cust_party_type is ORGANIZATION :',1,'N');
	END IF;
 IF nvl(l_party_id,l_cust_party_id) = l_cust_party_id  THEN
		/* if party type is Organization and contact is not specified */

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuoteAddress IF l_cust_party_type is ORGANIZATION '||
		' and Contact is not Specified :',1,'N');
		END IF;

		/* Get Primary Sold to Address for Quote to Customer */

         OPEN C_Use_Exists (l_cust_party_id);
         FETCH C_Use_Exists INTO x_party_site_id;
         CLOSE C_Use_Exists;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuoteAddress Cursor C_Use_Exists Primary Address ' ||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
		END IF;

	 IF x_party_site_id IS NULL THEN
		/* Get Identifying Address for Quote to Customer */

            OPEN C_Get_PrAddr (l_cust_party_id);
            FETCH C_Get_PrAddr INTO x_party_site_id;
            CLOSE C_Get_PrAddr;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuoteAddress Cursor C_Get_PrAddr Identifying Address '||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
	     END IF;
      END IF; ----- TEST
  ELSIF l_party_id <> l_cust_party_id THEN
	  /* if party type is Organization and contact is specified */
	  	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuoteAddress IF l_cust_party_type is ORGANIZATION '||
		' and Contact is Specified :',1,'N');
		END IF;
	   /* Get Primary 'SOLD TO' address for Quote to Contact */
         OPEN C_Use_Exists (l_party_id);
         FETCH C_Use_Exists INTO x_party_site_id;
         CLOSE C_Use_Exists;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuoteAddress Cursor C_Use_Exists Primary Address ' ||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
		END IF;

         IF x_party_site_id IS NULL THEN
		/* Get Identifying Address for Quote to Contact */

            OPEN C_Get_PrAddr (l_party_id);
            FETCH C_Get_PrAddr INTO x_party_site_id;
            CLOSE C_Get_PrAddr;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_QuoteAddress Cursor C_Get_PrAddr Identifying Address '||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
	     END IF;

         END IF;

         IF x_party_site_id IS NULL THEN
		 /* Get Primary 'SOLD TO' address for Quote to Customer */

            OPEN C_Use_Exists (l_cust_party_id);
            FETCH C_Use_Exists INTO x_party_site_id;
            CLOSE C_Use_Exists;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuoteAddress Cursor C_Use_Exists Primary Address ' ||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
		END IF;

            IF x_party_site_id IS NULL THEN
			/* Get Identifying address for Quote to Customer */

               OPEN C_Get_PrAddr (l_cust_party_id);
               FETCH C_Get_PrAddr INTO x_party_site_id;
               CLOSE C_Get_PrAddr;

			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Function Get_QuoteAddress Cursor C_Get_PrAddr Identifying '||
			' Address x_party_site_id :' ||x_party_site_id ,1,'N');
	     	END IF;
            END IF;   -- if x_party_site_id IS NULL

         END IF;  -- if x_party_site_id IS NULL

       END IF;

    END IF;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_QuoteAddress Party_Site_ID :' || x_party_site_id ,1,'N');
END IF;

RETURN x_party_site_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_QuoteAddress NO_DATA_FOUND Exception Occurs :',1,'N');
	END IF;

		RETURN NULL;
    WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_QuoteAddress Inside When Others Exception',1,'N');
	END IF;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        ' Get_QuoteAddress '
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_QuoteAddress;

FUNCTION Get_BillAddress(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS

   CURSOR C_Get_Type (l_party NUMBER) IS
    SELECT Party_Type
    FROM HZ_PARTIES
    WHERE Party_Id = l_party
    AND Status = 'A';

    CURSOR C_Use_Exists (l_party NUMBER) IS
     SELECT A.Party_Site_Id
     FROM HZ_PARTY_SITES A, HZ_PARTY_SITE_USES B
     WHERE A.Party_Id = l_party
     AND A.Party_Site_Id = B.Party_Site_Id
     AND B.Site_Use_Type = 'BILL_TO'
     AND B.Primary_Per_Type = 'Y'
     AND A.Status = 'A'
     AND B.Status = 'A';

    CURSOR C_Get_PrAddr (l_party NUMBER) IS
     SELECT Party_Site_Id
     FROM HZ_PARTY_SITES
     WHERE Party_Id = l_party
     AND Identifying_Address_Flag = 'Y'
     AND Status = 'A';

	l_cust_party_type      VARCHAR2(15);
	l_cust_party_id        NUMBER;
	l_party_id             NUMBER;
	x_party_site_id        NUMBER;

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_BillAddress --- Begin : ',1,'N');
END IF;

	IF p_database_object_name='ASO_AK_QUOTE_HEADER_V' THEN
  		--l_cust_party_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_cust_party_id;
		l_cust_party_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_INV_TO_CUST_PTY_ID ;
		--l_party_id      := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_party_id;
		l_party_id      := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_INV_TO_PTY_ID ;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_BillAddress Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_cust_party_id :' || l_cust_party_id ,1,'N');
		aso_debug_pub.add('Function Get_BillAddress Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_party_id :' || l_party_id ,1,'N');
		END IF;

	ELSIF p_database_object_name='ASO_AK_QUOTE_OPPTY_V' THEN
		--l_cust_party_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_cust_party_id;
		--l_party_id   	 := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_party_id;
		l_cust_party_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_oppty_cust_party_id;
		l_party_id   	:= ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_oppty_sld_to_cont_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_BillAddress Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_cust_party_id :' || l_cust_party_id ,1,'N');
		aso_debug_pub.add('Function Get_BillAddress Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_party_id :' || l_party_id ,1,'N');
		END IF;

	END IF;

   OPEN C_Get_Type (l_cust_party_id);
   FETCH C_Get_Type INTO l_cust_party_type;
   CLOSE C_Get_Type;
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_BillAddress Cursor C_Get_Type l_cust_party_type :'||
	l_cust_party_type,1,'N');
	END IF;
   /* if  Party Type is PERSON */
   IF l_cust_party_type = 'PERSON' THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_BillAddress IF l_cust_party_type is PERSON :',1,'N');
	END IF;
    /* Get Primary Bill To Address for Bill to Customer */
	 OPEN C_Use_Exists (l_cust_party_id);
      FETCH C_Use_Exists INTO x_party_site_id;
      CLOSE C_Use_Exists;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_BillAddress Cursor C_Use_Exists Primary Address ' ||
	' x_party_site_id :' ||x_party_site_id ,1,'N');
	END IF;

	IF x_party_site_id IS NULL THEN
		/* Get Identifying Address for Bill to Customer */
        	OPEN C_Get_PrAddr (l_cust_party_id);
         	FETCH C_Get_PrAddr INTO x_party_site_id;
         	CLOSE C_Get_PrAddr;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_BillAddress Cursor C_Get_PrAddr Identifying Address'||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
		END IF;

     END IF;

   ELSE
	/* if  Party Type is ORGANIZATION */

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_BillAddress IF l_cust_party_type is Organization :',1,'N');
		END IF;
      IF nvl(l_party_id,l_cust_party_id) = l_cust_party_id THEN

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_BillAddress IF l_cust_party_type is ORGANIZATION '||
		' and Contact is not Specified :',1,'N');
		END IF;
	/* Get Primary Bill To Address for Bill to Customer */
         	OPEN C_Use_Exists (l_cust_party_id);
         	FETCH C_Use_Exists INTO x_party_site_id;
         	CLOSE C_Use_Exists;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_BillAddress Cursor C_Use_Exists Primary Address ' ||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
		END IF;

          IF x_party_site_id IS NULL THEN
		/* Get Identifying Address for Bill to Customer */

            OPEN C_Get_PrAddr (l_cust_party_id);
            FETCH C_Get_PrAddr INTO x_party_site_id;
            CLOSE C_Get_PrAddr;

			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Function Get_BillAddress Cursor C_Get_PrAddr Identifying Address'||
			' x_party_site_id :' ||x_party_site_id ,1,'N');
			END IF;

          END IF;

      ELSIF l_party_id <> l_cust_party_id THEN

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_BillAddress IF l_cust_party_type is ORGANIZATION '||
		' and Contact is Specified :',1,'N');
		END IF;

	 /* Get Primary Bill To Address for Bill to Customer */
         OPEN C_Use_Exists (l_party_id);
         FETCH C_Use_Exists INTO x_party_site_id;
         CLOSE C_Use_Exists;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_BillAddress Cursor C_Use_Exists Primary Address ' ||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
		END IF;

         IF x_party_site_id IS NULL THEN
		/* Get Identifying Address for Bill to Customer */

            OPEN C_Get_PrAddr (l_party_id);
            FETCH C_Get_PrAddr INTO x_party_site_id;
            CLOSE C_Get_PrAddr;

			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Function Get_BillAddress Cursor C_Get_PrAddr Identifying Address'||
			' x_party_site_id :' ||x_party_site_id ,1,'N');
			END IF;
         END IF;

         IF x_party_site_id IS NULL THEN
		/* Get Primary Bill To Address for Bill to Customer */
            OPEN C_Use_Exists (l_cust_party_id);
            FETCH C_Use_Exists INTO x_party_site_id;
            CLOSE C_Use_Exists;

			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Function Get_BillAddress Cursor C_Use_Exists Primary Address ' ||
			' x_party_site_id :' ||x_party_site_id ,1,'N');
			END IF;
            IF x_party_site_id IS NULL THEN
			/* Get Identifying Address for Bill to Customer */

               OPEN C_Get_PrAddr (l_cust_party_id);
               FETCH C_Get_PrAddr INTO x_party_site_id;
               CLOSE C_Get_PrAddr;

			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Function Get_BillAddress Cursor C_Get_PrAddr Identifying Address'||
			' x_party_site_id :' ||x_party_site_id ,1,'N');
			END IF;

            END IF;


         END IF;

       END IF;

    END IF;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_BillAddress Party_Site_ID Returned :'||x_party_site_id ,1,'N');
END IF;

RETURN x_party_site_id;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_BillAddress NO_DATA_FOUND Exception Occurs',1,'N');
	END IF;

		RETURN NULL;
    WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_BillAddress Inside When Others Exception',1,'N');
	END IF;
    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        ' Get_BillAddress '
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_BillAddress;

FUNCTION Get_ShipAddress(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS

   CURSOR C_Get_Type (l_party NUMBER) IS
    SELECT Party_Type
    FROM HZ_PARTIES
    WHERE Party_Id = l_party
    AND Status = 'A';

    CURSOR C_Use_Exists (l_party NUMBER) IS
     SELECT A.Party_Site_Id
     FROM HZ_PARTY_SITES A, HZ_PARTY_SITE_USES B
     WHERE A.Party_Id = l_party
     AND A.Party_Site_Id = B.Party_Site_Id
     AND B.Site_Use_Type = 'SHIP_TO'
     AND B.Primary_Per_Type = 'Y'
     AND A.Status = 'A'
     AND B.Status = 'A';

    CURSOR C_Get_PrAddr (l_party NUMBER) IS
     SELECT Party_Site_Id
     FROM HZ_PARTY_SITES
     WHERE Party_Id = l_party
     AND Identifying_Address_Flag = 'Y'
     AND Status = 'A';

	l_cust_party_type      VARCHAR2(15);
	l_cust_party_id        NUMBER;
	l_party_id             NUMBER;
	x_party_site_id        NUMBER;

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_ShipAddress --- Begin : ',1,'N');
END IF;

	IF p_database_object_name='ASO_AK_QUOTE_HEADER_V' THEN

               /* Done code change for Bug - 5763528, commented following code -

  		--l_cust_party_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_cust_party_id;
		l_cust_party_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_INV_TO_CUST_PTY_ID;
		--l_party_id      := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_party_id;
		l_party_id      := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_INV_TO_PTY_ID;  */

		-- Following code replaced above code

                l_cust_party_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_SHIP_TO_CUST_PARTY_ID;
                l_party_id      := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_SHIP_TO_PARTY_ID;

		-- End of code for Bug - 5763528

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ShipAddress Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_cust_party_id :' || l_cust_party_id ,1,'N');
		aso_debug_pub.add('Function Get_ShipAddress Database Object ASO_AK_QUOTE_HEADER_V '||
		' l_party_id :' || l_party_id ,1,'N');
		END IF;

	ELSIF p_database_object_name='ASO_AK_QUOTE_OPPTY_V' THEN
		--l_cust_party_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_cust_party_id;
		--l_party_id   	 := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_party_id;
		l_cust_party_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_oppty_cust_party_id;
		l_party_id   	:= ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_oppty_sld_to_cont_id;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ShipAddress Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_cust_party_id :' || l_cust_party_id ,1,'N');
		aso_debug_pub.add('Function Get_ShipAddress Database Object ASO_AK_QUOTE_OPPTY_V '||
		' l_party_id :' || l_party_id ,1,'N');
		END IF;

	END IF;

   OPEN C_Get_Type (l_cust_party_id);
   FETCH C_Get_Type INTO l_cust_party_type;
   CLOSE C_Get_Type;
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_ShipAddress Cursor C_Get_Type l_cust_party_type :'||
	l_cust_party_type,1,'N');
	END IF;
   /* if party type is PERSON */
   IF l_cust_party_type = 'PERSON' THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_ShipAddress IF l_cust_party_type is PERSON :',1,'N');
	END IF;
	/* Get Primary Ship To Address for Ship to Customer */
      OPEN C_Use_Exists (l_cust_party_id);
      FETCH C_Use_Exists INTO x_party_site_id;
      CLOSE C_Use_Exists;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ShipAddress Cursor C_Use_Exists Primary Address ' ||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
		END IF;
      IF x_party_site_id IS NULL THEN
	/* Get Identifying Address for SHIP to Customer */
         OPEN C_Get_PrAddr (l_cust_party_id);
         FETCH C_Get_PrAddr INTO x_party_site_id;
         CLOSE C_Get_PrAddr;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ShipAddress Cursor C_Get_PrAddr Identifying Address'||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
		END IF;
      END IF;

   ELSE
     /* IF Party type is ORGANIZATION */
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_ShipAddress IF l_cust_party_type is ORGANIZATION :',1,'N');
	END IF;
      IF nvl(l_party_id,l_cust_party_id) = l_cust_party_id THEN
		/* If Organization Contact IS NOT Specified */
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ShipAddress IF l_cust_party_type is ORGANIZATION '||
		' and Contact is not Specified :',1,'N');
		END IF;
	/* Get Primary Ship To Address for Ship to Customer */
         OPEN C_Use_Exists (l_cust_party_id);
         FETCH C_Use_Exists INTO x_party_site_id;
         CLOSE C_Use_Exists;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ShipAddress Cursor C_Use_Exists Primary Address ' ||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
		END IF;

         IF x_party_site_id IS NULL THEN
		/* Get Identifying Address for Ship to Customer */
            OPEN C_Get_PrAddr (l_cust_party_id);
            FETCH C_Get_PrAddr INTO x_party_site_id;
            CLOSE C_Get_PrAddr;

			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Function Get_ShipAddress Cursor C_Get_PrAddr Identifying Address'||
			' x_party_site_id :' ||x_party_site_id ,1,'N');
			END IF;

         END IF;

      ELSIF l_party_id <> l_cust_party_id THEN
          /* IF Organization Contact is Specified */
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ShipAddress IF l_cust_party_type is ORGANIZATION '||
		' and Contact is Specified :',1,'N');
		END IF;
       /* Get Primary Ship To Address for Ship to Customer */
		OPEN C_Use_Exists (l_party_id);
         	FETCH C_Use_Exists INTO x_party_site_id;
         	CLOSE C_Use_Exists;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ShipAddress Cursor C_Use_Exists Primary Address ' ||
		' x_party_site_id :' ||x_party_site_id ,1,'N');
		END IF;

	    IF x_party_site_id IS NULL THEN
		/* Get Identifying Address for Ship to Customer */
            OPEN C_Get_PrAddr (l_party_id);
            FETCH C_Get_PrAddr INTO x_party_site_id;
            CLOSE C_Get_PrAddr;

			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Function Get_ShipAddress Cursor C_Get_PrAddr Identifying Address'||
			' x_party_site_id :' ||x_party_site_id ,1,'N');
			END IF;

         END IF;

         IF x_party_site_id IS NULL THEN
		/* Get Primary Ship To Address for Ship to Customer */
            OPEN C_Use_Exists (l_cust_party_id);
            FETCH C_Use_Exists INTO x_party_site_id;
            CLOSE C_Use_Exists;

			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Function Get_ShipAddress Cursor C_Use_Exists Primary Address ' ||
			' x_party_site_id :' ||x_party_site_id ,1,'N');
			END IF;

            IF x_party_site_id IS NULL THEN
			/* Get Identifying Address for Ship to Customer */
               OPEN C_Get_PrAddr (l_cust_party_id);
               FETCH C_Get_PrAddr INTO x_party_site_id;
               CLOSE C_Get_PrAddr;

			IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
			aso_debug_pub.add('Function Get_ShipAddress Cursor C_Get_PrAddr Identifying Address'||
			' x_party_site_id :' ||x_party_site_id ,1,'N');
			END IF;

            END IF;


         END IF;

       END IF;

    END IF;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_ShipAddress Party_Site_ID Returned : '||x_party_site_id,1,'N');
END IF;

    RETURN x_party_site_id;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ShipAddress NO_DATA_FOUND Exception Occurs',1,'N');
	END IF;

		RETURN NULL;
    WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ShipAddress Inside When Others Exception',1,'N');
	END IF;
    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        ' Get_ShipAddress '
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_ShipAddress;



FUNCTION Get_SalesGroup_From_Salesrep(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS

	CURSOR C_sales_grp (x_resource_id  Number) IS
		SELECT   jrgm.group_id
		FROM     JTF_RS_GROUP_MEMBERS jrgm,
         		JTF_RS_GROUPS_tl jrgt,
         		JTF_RS_GROUP_USAGES jrgu
 		WHERE   jrgm.group_id =jrgt.group_id
 		AND     jrgt.language= userenv('LANG')
 		AND     jrgu.group_id = jrgm.group_id
 		AND     jrgu.usage = 'SALES'
 		AND    nvl(jrgm.delete_flag, 'N') <> 'Y'
 		AND    exists (SELECT 1 FROM
             				jtf_rs_role_relations jrrr
          			WHERE jrrr.role_resource_id= jrgm.group_member_id
          			AND    trunc( nvl(jrrr.start_date_active, SYSDATE))  <= trunc( SYSDATE )
          			AND    trunc( nvl(jrrr.end_date_active, SYSDATE))  >= trunc( SYSDATE )
          			AND    jrrr.role_resource_type='RS_GROUP_MEMBER'
          			AND     nvl(jrrr.delete_flag, 'N') <> 'Y'
          			AND     ROWNUM= 1)
 		AND    jrgm.resource_id = x_resource_id;

	Cursor C_salesrep (X_User_Id Number) IS
	SELECT j.resource_id
	FROM jtf_rs_salesreps_mo_v srp, jtf_rs_resource_extns_vl j
	WHERE j.user_id = X_User_Id
	AND j.resource_id = srp.resource_id
	AND nvl(srp.status,'A') = 'A'
	AND nvl(trunc(srp.start_date_active), trunc(sysdate)) <= trunc(sysdate)
	AND nvl(trunc(srp.end_date_active), trunc(sysdate)) >= trunc(sysdate)
	AND nvl(trunc(j.start_date_active), trunc(sysdate)) <= trunc(sysdate)
	AND nvl(trunc(j.end_date_active), trunc(sysdate)) >= trunc(sysdate);

	l_resource_id  NUMBER;
	l_salesgroup_id   NUMBER;
	l_org_id  		NUMBER;
BEGIN

	If NVL(FND_PROFILE.VALUE('ASO_AUTO_TEAM_ASSIGN'),'NONE') <> 'NONE' Then
	aso_debug_pub.add('Function Get_SalesGroup_From_Salesrep -- Automatic Team Assign'||fnd_profile.value('ASO_AUTO_TEAM_ASSIGN'),1,'N');
	return null;
	End If;

	IF p_database_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN
    		l_resource_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_resource_id;
    		l_org_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_Org_id;
	ELSIF p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
		l_resource_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.O_resource_id;
		l_org_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.O_Org_id;
	END IF;

	IF l_org_id is null or l_org_id = FND_API.G_MISS_NUM THEN
		return null;
	END IF;

     IF l_resource_id IS NULL OR l_resource_id = FND_API.G_MISS_NUM THEN
	    OPEN C_salesrep(G_USER_ID);
         FETCH C_salesrep INTO l_resource_id;
	    CLOSE C_salesrep;
	END IF;

	IF l_resource_id IS NOT NULL THEN
		OPEN C_sales_grp(l_resource_id);
		FETCH C_sales_grp INTO l_salesgroup_id;
		CLOSE C_sales_grp;
	END IF;

	RETURN l_salesgroup_id;

EXCEPTION

	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_SalesGroup_From_Salesrep NO_DATA_FOUND Exception Occurs',1,'N');
	END IF;

	RETURN NULL;

    WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_SalesGroup_From_Salesrep Inside When Others Exception',1,'N');
	END IF;

	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_SalesGroup_From_Salesrep '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_SalesGroup_From_Salesrep;

FUNCTION Get_SalesGroup_From_Profile (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS
	l_org_id  		NUMBER;
	l_salesgroup_id	NUMBER;

BEGIN

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_SalesGroup_From_Profile -- Begin :',1,'N');
	END IF;

	If NVL(FND_PROFILE.VALUE('ASO_AUTO_TEAM_ASSIGN'),'NONE') <> 'NONE' Then
	aso_debug_pub.add('Function Get_SalesGroup_From_Profile -- Automatic Team Assign'||fnd_profile.value('ASO_AUTO_TEAM_ASSIGN'),1,'N');
	return null;
	End If;

	IF p_database_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN
    		l_org_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_Org_id;
	ELSIF p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
		l_org_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.O_Org_id;
	END IF;

   l_salesgroup_id := aso_utility_pvt.get_ou_attribute_value(aso_utility_pvt.G_DEFAULT_SALES_GROUP,l_org_id);

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_SalesGroup_From_Profile Sales Group Id :' ||l_salesgroup_id,1,'N');
	END IF;

RETURN l_salesgroup_id;

EXCEPTION

    WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_SalesGroup_From_Profile Inside When Others Exception',1,'N');
	END IF;
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_SalesGroup_From_Profile '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_SalesGroup_From_Profile;


FUNCTION Get_SalesRep (
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN NUMBER
IS

   CURSOR C_Get_Creator_Res (l_user_id NUMBER) IS
    SELECT resource_id
    FROM JTF_RS_RESOURCE_EXTNS
    WHERE user_id = l_user_id
    AND SYSDATE BETWEEN NVL(start_date_active,sysdate) AND NVL(end_date_active, SYSDATE);

   CURSOR C_Valid_SalesRep (l_res_id NUMBER) IS
    SELECT 'Y'
    FROM JTF_RS_SALESREPS_MO_V
    WHERE resource_id = l_res_id
    AND NVL(status,'A') = 'A'
    AND nvl(trunc(start_date_active), trunc(sysdate)) <= trunc(sysdate)
    AND nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate);

   CURSOR C_Get_Res_From_Srep (l_Srep VARCHAR2) IS
    SELECT Resource_Id
    FROM JTF_RS_SALESREPS_MO_V
    WHERE salesrep_number = l_Srep
    AND NVL(status,'A') = 'A'
    AND nvl(trunc(start_date_active), trunc(sysdate)) <= trunc(sysdate)
    AND nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate);

   l_creator_res           NUMBER;
   l_valid                 VARCHAR2(1) := 'N';
   l_default_salesrep      VARCHAR2(40) := aso_utility_pvt.get_default_salesrep;
   l_profile_salesrep_id   NUMBER;
   l_org_id                NUMBER;

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_SalesRep --- Begin :',1,'N');
END IF;

	If NVL(FND_PROFILE.VALUE('ASO_AUTO_TEAM_ASSIGN'),'NONE') <> 'NONE' Then
	aso_debug_pub.add('Function Get_SalesRep -- Automatic Team Assign'||fnd_profile.value('ASO_AUTO_TEAM_ASSIGN'),1,'N');
	return null;
	End If;

	IF p_database_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN
    		l_org_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_ORG_ID;
	ELSIF p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
		l_org_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.O_ORG_ID;
	END IF;

	IF l_org_id is null or l_org_id = FND_API.G_MISS_NUM THEN
		return null;
	END IF;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_SalesRep Database Object :'||p_database_object_name,1,'N');
	aso_debug_pub.add('Function Get_SalesRep ORG ID : '|| l_org_id,1,'N');
	END IF;

    	OPEN C_Get_Creator_Res(G_USER_ID);
    	FETCH C_Get_Creator_Res INTO l_creator_res;
   	CLOSE C_Get_Creator_Res;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_SalesRep Cursor C_Get_Creator_Res: '||l_creator_res,1,'N');
	END IF;

    IF l_creator_res IS NOT NULL THEN
      	OPEN C_Valid_SalesRep (l_creator_res);
	     FETCH C_Valid_SalesRep INTO l_valid;
     	CLOSE C_Valid_SalesRep;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_SalesRep Cursor C_Valid_SalesRep: '||l_valid,1,'N');
		END IF;
    END IF;

    IF (l_creator_res IS NULL OR l_valid <> 'Y') THEN --AND l_profile_salesrep_id IS NOT NULL THEN

		-- Bug 4724024
                IF (l_valid <> 'Y') THEN
		      l_creator_res := NULL ;
                END IF;

		-- Passing Org id in the call - Girish 10/18/2005
		l_profile_salesrep_id := aso_utility_pvt.get_ou_attribute_value(l_default_salesrep, l_org_id);

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_SalesRep l_profile_salesrep_id: '||l_profile_salesrep_id,1,'N');
		END IF;

		IF l_profile_salesrep_id IS NOT NULL THEN
      		OPEN C_Get_Res_From_Srep (l_profile_salesrep_id);
      		FETCH C_Get_Res_From_Srep INTO l_creator_res;
      		CLOSE C_Get_Res_From_Srep;
		END IF;
    END IF;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_SalesRep Returns: '||l_creator_res,1,'N');
END IF;

RETURN l_creator_res;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_SalesRep NO_DATA_FOUND Exception Occurs',1,'N');
	END IF;

	RETURN NULL;

    	WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_SalesRep Inside When Others Exception',1,'N');
	END IF;
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_SalesRep '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_SalesRep;

FUNCTION Get_Currency_from_pricelist(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN VARCHAR2
is
	Cursor C_currency_code(q_price_list_id Number) is
	SELECT currency_code
	FROM qp_price_lists_v
	WHERE price_list_id = q_price_list_id;

	l_price_list_id	Number;
	l_currency_code 	C_currency_code%rowtype;

Begin
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_Currency_from_pricelist --- Begin : ',1,'N');
END IF;

	IF p_database_object_name = 'ASO_AK_QUOTE_HEADER_V' THEN
		l_price_list_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.q_price_list_id;

	ELSIF p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
		l_price_list_id := ASO_QUOTE_OPPTY_DEF_HDLR.g_record.o_price_list_id;


	END IF;

	open C_currency_code(l_price_list_id);
	fetch C_currency_code into l_currency_code;
	close C_Currency_code;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_Currency_from_pricelist Returns : '||l_currency_code.currency_code,1,'N');
END IF;

RETURN l_currency_code.currency_code;


EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN NULL;

    WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_Currency_from_pricelist Inside When Others Exception',1,'N');
	END IF;
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_Currency_from_pricelist '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Get_Currency_from_pricelist;

FUNCTION Get_Currency_from_Profile(
             P_Database_Object_Name    IN   VARCHAR2,
             P_Attribute_Code          IN   VARCHAR2
             ) RETURN VARCHAR2
Is
Begin
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_Currency_from_Profile  --- Begin :',1,'N');
END IF;

	IF p_database_object_name='ASO_AK_QUOTE_HEADER_V' OR
	   p_database_object_name = 'ASO_AK_QUOTE_OPPTY_V' THEN
		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_Currency_From_Profile Profile ICX_PREFERRED_CURRENCY : '||
		fnd_profile.Value('ICX_PREFERRED_CURRENCY') ,1,'N');
		END IF;

		return 	FND_PROFILE.Value('ICX_PREFERRED_CURRENCY');
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_Currency_from_Profile NO_DATA_FOUND Exception Occurs : ',1,'N');
	END IF;

	RETURN NULL;

    	WHEN OTHERS THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_Currency_From_Profile Inside When Others Exception',1,'N');
	END IF;
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_Currency_from_Profile '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Currency_from_Profile;


FUNCTION Get_RequestedDateType(P_Database_Object_Name IN VARCHAR2,
					P_Attribute_Code	IN VARCHAR2) RETURN VARCHAR2

IS

     l_ret_value   HZ_CUST_ACCOUNTS.DATE_TYPE_PREFERENCE%TYPE;
     l_acct_id     NUMBER;

     CURSOR C_Get_RDT (l_acct NUMBER) IS
     SELECT date_type_preference
     FROM HZ_CUST_ACCOUNTS
     WHERE Cust_Account_Id = l_acct
     AND Status = 'A';

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
aso_debug_pub.add('Function Get_RequestedDateType --- Begin : ',1,'N');
END IF;

	IF p_database_object_name='ASO_AK_QUOTE_HEADER_V' THEN
    		l_acct_id := ASO_QUOTE_HEADER_DEF_HDLR.g_record.Q_cust_account_id;

		IF ( l_acct_id IS NOT NULL AND
		     l_acct_id <> FND_API.G_MISS_NUM ) THEN
             OPEN C_Get_RDT (l_acct_id);
             FETCH C_Get_RDT INTO l_ret_value;
             CLOSE C_Get_RDT;

	        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	            aso_debug_pub.add('Function Get_RequestedDateType cusror C_Get_RDT l_ret_value : ' ||
	        l_ret_value ,1,'N');
	        END IF;
		ELSE
	        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	            aso_debug_pub.add('Function Get_RequestedDateType -CustomerAccount is null - requesteddatetype no retrieved',1,'N');
	        END IF;
		END IF;

	END IF;

     RETURN l_ret_value;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_RequestedDateType NO_DATA_FOUND Occurs ',1,'N');
	END IF;

	RETURN NULL;

    	WHEN OTHERS THEN

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_RequestedDateType Inside When Others Exception',1,'N');
	END IF;

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_RequestedDateType '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_RequestedDateType;


FUNCTION Get_ChargePeriodicity(P_Database_Object_Name IN VARCHAR2,
					P_Attribute_Code	IN VARCHAR2) RETURN VARCHAR2

IS

     l_ret_value   mtl_system_items_vl.charge_periodicity_code%TYPE;
     l_organization_id     NUMBER;
     l_inventory_item_id   NUMBER ;

     CURSOR C_Get_CP (l_organization NUMBER, l_inventory_item NUMBER) IS
     SELECT charge_periodicity_code
     FROM mtl_system_items_b
     WHERE organization_id = l_organization
     AND inventory_item_id = l_inventory_item;

BEGIN
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
               aso_debug_pub.add('Function Get_ChargePeriodicity --- Begin : ',1,'N');
        END IF;

	IF p_database_object_name='ASO_AK_QUOTE_LINE_V' THEN
    		l_organization_id := ASO_QUOTE_LINE_DEF_HDLR.g_record.L_ORGANIZATION_ID;
		l_inventory_item_id := ASO_QUOTE_LINE_DEF_HDLR.g_record.L_INVENTORY_ITEM_ID;

		IF ( l_organization_id IS NOT NULL AND
		     l_organization_id <> FND_API.G_MISS_NUM )
		     AND  ( l_inventory_item_id IS NOT NULL AND
		     l_inventory_item_id <> FND_API.G_MISS_NUM )THEN
             OPEN C_Get_CP (l_organization_id, l_inventory_item_id);
             FETCH C_Get_CP INTO l_ret_value;
             CLOSE C_Get_CP;

	        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	            aso_debug_pub.add('Function Get_ChargePeriodicity cusror C_Get_CP l_ret_value : ' ||
	        l_ret_value ,1,'N');
	        END IF;
		ELSE
	        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	            aso_debug_pub.add('Function Get_ChargePeriodicity -Org Id is null - Charge Periodicity not retrieved',1,'N');
	        END IF;
		END IF;

	END IF;

     RETURN l_ret_value;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('Function Get_ChargePeriodicity NO_DATA_FOUND Occurs ',1,'N');
	END IF;

	RETURN NULL;

    	WHEN OTHERS THEN

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		aso_debug_pub.add('Function Get_ChargePeriodicity Inside When Others Exception',1,'N');
	END IF;

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             ' Get_ChargePeriodicity '
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_ChargePeriodicity;

END QOT_DEFAULT_PVT;

/
