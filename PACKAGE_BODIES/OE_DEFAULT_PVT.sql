--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_PVT" AS
/* $Header: OEXVDEFB.pls 120.12.12010000.3 2009/12/08 14:18:14 msundara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Default_Pvt';

-----------------------------------------------------------------------
-- DEFAULTING FUNCTIONS TO BE USED FOR ATTRIBUTES ON ORDER HEADER
-----------------------------------------------------------------------


FUNCTION Get_Credit_Card_Number
	(p_database_object_name IN VARCHAR2
	,p_attribute_code IN VARCHAR2)
RETURN VARCHAR2
IS
   l_Credit_Card_Number VARCHAR2(80);
   l_Bank_Account_ID    Number;
   l_Invoice_To_Cust_Id Number;

/*
   Cursor C_Credit_Card_Number (X_Bank_Account_ID NUMBER) is
		SELECT bank_account_num
		FROM   ap_bank_accounts
		WHERE  bank_account_id = X_Bank_Account_Id
		AND    bank_branch_id=1
		AND    account_type='EXTERNAL';
*/

   Cursor C_Invoice_To_Cust (X_Invoice_To_Org_Id NUMBER) is
		SELECT customer_id
		FROM   oe_invoice_to_orgs_v
		WHERE  organization_id = X_Invoice_To_Org_Id;

   Cursor get_hdr_sold_inv(x_header_id number) is
                SELECT sold_to_org_id, invoice_to_org_id
                from oe_order_headers_all
                where header_id = x_header_id;

   Cursor get_line_sold_inv(x_line_id number) is
                SELECT sold_to_org_id, invoice_to_org_id
                from oe_order_lines_all
                where line_id = x_line_id;

   l_cust_org_id number;
   l_invoice_to_org_id number;
   l_payment_type_code varchar2(30) := NULL;
   --R12 CC Encryption
   l_result_limit     IBY_FNDCPT_COMMON_PUB.ResultLimit_rec_type;
   l_conditions       IBY_FNDCPT_COMMON_PUB.TrxnContext_rec_type;
   l_payer	      IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
   l_assignments      IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_tbl_type;
   L_response_code    IBY_FNDCPT_COMMON_PUB.Result_rec_type;
   L_return_status    VARCHAR2(30);
   L_msg_count	      NUMBER;
   L_msg_data	      VARCHAR2(2000);
   l_payment_function VARCHAR2(40) := 'CUSTOMER_PAYMENT';
   l_org_type         VARCHAR2(40) := 'OPERATING_UNIT';
   l_party_id	      NUMBER;
   l_cust_account_id  NUMBER;
   l_trans_curr_code  VARCHAR2(20); --Verify
   l_card_instrument  IBY_FNDCPT_SETUP_PUB.CreditCard_rec_Type;

   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   IF l_debug_level > 0 THEN
   	oe_debug_pub.add('Entering OE_Default_PVT.Get_Credit_Card_Number.', 1);
   END IF;


  IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V' THEN

    l_payment_type_code := ONT_HEADER_DEF_HDLR.g_record.payment_type_code;

    IF ONT_HEADER_DEF_HDLR.g_record.sold_to_org_id IS NOT NULL
    AND ONT_HEADER_DEF_HDLR.g_record.sold_to_org_id <> FND_API.G_MISS_NUM
    THEN

       l_cust_org_id := ONT_HEADER_DEF_HDLR.g_record.sold_to_org_id;
       IF ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id IS NOT NULL
       AND ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id <> FND_API.G_MISS_NUM
       THEN
         l_invoice_to_org_id := ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id;
       END IF;  -- if ont_header_def_hdlr.g_record.invoice_to...
    ELSE
       RETURN NULL;
    END IF;  -- if ont_header_def_hdlr.g_record.sold_to_org_id is not null

  ELSIF p_database_object_name = 'OE_AK_HEADER_PAYMENTS_V' THEN

  l_payment_type_code := ONT_HEADER_PAYMENT_DEF_HDLR.g_record.payment_type_code;

        OPEN get_hdr_sold_inv(ONT_HEADER_PAYMENT_DEF_HDLR.g_record.header_id);
        FETCH get_hdr_sold_inv into l_cust_org_id, l_invoice_to_org_id;
        CLOSE get_hdr_sold_inv;

  ELSIF p_database_object_name = 'OE_AK_LINE_PAYMENTS_V' THEN

  l_payment_type_code := ONT_LINE_PAYMENT_DEF_HDLR.g_record.payment_type_code;

        OPEN get_line_sold_inv(ONT_LINE_PAYMENT_DEF_HDLR.g_record.line_id);
        FETCH get_line_sold_inv into l_cust_org_id, l_invoice_to_org_id;
        CLOSE get_line_sold_inv;

  END IF;

  IF nvl(l_payment_type_code, 'x') <> 'CREDIT_CARD' THEN

     Return null;

  END IF;

/* Fix Bug #2297053:Customer of Invoice To may be different from the Sold To */
    --R12 CC Encryption Verify
    --l_trans_curr_code   := ONT_HEADER_DEF_HDLR.transactional_curr_code;
    --R12 CC Encryption

   IF l_invoice_to_org_id is not null THEN
      OPEN C_Invoice_To_Cust(l_invoice_to_org_id);
      FETCH C_Invoice_To_Cust INTO l_Invoice_To_Cust_Id;
      CLOSE C_Invoice_To_Cust;
   END IF;
   --R12 CC Encryption
   --Need to call the appropriate payments API to populate
   --the credit card details now.

      /*l_Bank_Account_ID := arp_bank_pkg.get_primary_bank_acct
			(  l_Invoice_To_Cust_Id
			 , l_invoice_to_org_id
			 , TRUE );
   ELSIF l_cust_org_id is not null THEN

      l_Bank_Account_ID := arp_bank_pkg.get_primary_bank_acct
			  (l_cust_org_id);
   END IF;

   IF l_Bank_Account_ID is NOT NULL THEN
       OPEN C_Credit_Card_Number(l_Bank_Account_ID);
       FETCH C_Credit_Card_Number INTO l_Credit_Card_Number;
       CLOSE C_Credit_Card_Number;
       RETURN l_Credit_Card_Number;
   ELSE
	  RETURN NULL;*/

   --R12 CC Encryption
   Begin
	Select	party_site.party_id, acct_site.cust_account_id
	Into 	l_party_id, l_cust_account_id
	From 	HZ_CUST_SITE_USES_ALL SITE,
		HZ_PARTY_SITES             PARTY_SITE,
		HZ_CUST_ACCT_SITES         ACCT_SITE
	Where 	SITE.SITE_USE_ID = l_invoice_to_org_id
	AND	SITE.SITE_USE_CODE  = 'BILL_TO'
	AND   	SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
	AND   	ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
	AND  	SITE.ORG_ID = ACCT_SITE.ORG_ID;
   Exception
   When No_Data_Found THEN
	Null;
   End;

	L_result_limit.default_flag := 'Y';

	--Setting the payer context values
	l_payer.party_id	 := l_party_id; --Verify
	l_payer.payment_function := l_payment_function;
	l_payer.org_type	 := l_org_type;
	l_payer.org_id		:=  OE_GLOBALS.G_ORG_ID;
	l_payer.cust_account_id	:=  l_cust_account_id; --l_invoice_to_org_id
        l_payer.account_site_id	:=  l_invoice_to_org_id;

	l_conditions.Currency_Code := l_trans_curr_code;
	l_conditions.Payment_InstrType := 'CREDITCARD';

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Payer context values in Defaulting package');
		oe_debug_pub.add('Party id'||l_party_id);
		oe_debug_pub.add('Org id'||l_payer.org_id);
		oe_debug_pub.add('cust acct id'||l_invoice_to_org_id);
		oe_debug_pub.add('acct site id'||l_invoice_to_cust_id);
	END IF;

	--payer equivalency value of g_payer_equiv_upward means to retrieve from
	--if out found at the current transaction level higher level,
	--site -> customer -> party level
	IBY_FNDCPT_SETUP_PUB.Get_Trxn_Appl_Instr_Assign
	(p_api_version		=> 1.0,
	 X_return_status	=> l_return_status,
	 X_msg_count		=> l_msg_count,
	 X_msg_data		=> l_msg_data,
	 P_payer		=> l_payer,
	 P_payer_equivalency	=> IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
	 P_conditions		=> l_conditions,
	 P_result_limit		=> l_result_limit,
	 X_assignments		=> l_assignments,
	 X_response		=> l_response_code);

	IF l_debug_level > 0 THEN
 	  oe_debug_pub.add('Return status after Get_Trxn_Appl_Instr_Assign is: '||l_return_status, 3);
	  oe_debug_pub.add('assignment id is: '||l_assignments(1).instrument.instrument_id, 3);
	END IF;

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Result error code in Get_Trxn_Appl_Instr_Assign'||l_response_code.result_code);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Result error code in Get_Trxn_Appl_Instr_Assign'||l_response_code.result_code);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
		IF l_debug_level > 0 THEN
	 	oe_debug_pub.add('Get_Trxn_Appl_Instr_Assign Successful....'||l_assignments(1).instrument.instrument_id);
			oe_debug_pub.add('After calling Get_Trxn_Appl_Instr_Assign');
		END IF;
	END IF;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Calling IBY_FNDCPT_SETUP_PUB.Get_Card.',3);
	END IF;


	IBY_FNDCPT_SETUP_PUB.Get_Card
	(p_api_version		=> 1.0,
	 X_return_status	=> l_return_status,
	 X_msg_count		=> l_msg_count,
	 X_msg_data		=> l_msg_data,
	 P_card_id		=> l_assignments(1).instrument.instrument_id,
	 X_card_instrument	=> l_card_instrument,
	 X_response		=> l_response_code);

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Return status after IBY_FNDCPT_SETUP_PUB.Get_Card.'||l_return_status, 3);
	END IF;

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Result error code in Get_Card'||l_response_code.result_code);
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Result error code in Get_Card'||l_response_code.result_code);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Get_Card Successful....');
			oe_debug_pub.add('After calling Get_Card');
			oe_debug_pub.add('Card values in Defaulting package');
			--oe_debug_pub.add('card_number'||l_card_instrument.card_number);
			--oe_debug_pub.add('expiration_date'||l_card_instrument.expiration_date);
			--oe_debug_pub.add('Card_Holder_Name'||l_card_instrument.Card_Holder_Name);
			--oe_debug_pub.add('card_id'||l_card_instrument.card_id);
			oe_debug_pub.add('Instrument_id'||l_assignments(1).instrument.instrument_id);
			oe_debug_pub.add('assign id'||l_assignments(1).assignment_id);
		END IF;
	END IF;


	IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V' THEN
		ONT_HEADER_DEF_HDLR.g_record.credit_card_number := l_card_instrument.card_number;
		ONT_HEADER_DEF_HDLR.g_record.credit_card_holder_name :=	l_card_instrument.card_holder_name;
		ONT_HEADER_DEF_HDLR.g_record.credit_card_code := l_card_instrument.card_issuer;
		ONT_HEADER_DEF_HDLR.g_record.credit_card_expiration_date := l_card_instrument.expiration_date;
		OE_Default_Pvt.g_default_instrument_id := l_assignments(1).instrument.instrument_id;
		OE_Default_Pvt.g_default_instr_assignment_id := l_assignments(1).assignment_id;
	ELSIF p_database_object_name = 'OE_AK_HEADER_PAYMENTS_V' THEN
		ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_number := l_card_instrument.card_number;
		ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_holder_name := l_card_instrument.card_holder_name;
		ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_code := l_card_instrument.card_issuer;
		ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_expiration_date := l_card_instrument.expiration_date;
		OE_Default_Pvt.g_default_instrument_id := l_assignments(1).instrument.instrument_id;
		OE_Default_Pvt.g_default_instr_assignment_id := l_assignments(1).assignment_id;
        ELSIF p_database_object_name = 'OE_AK_LINE_PAYMENTS_V' THEN
		ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_number := l_card_instrument.card_number;
		ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_holder_name := l_card_instrument.card_holder_name;
		ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_code := l_card_instrument.card_issuer;
		ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_expiration_date := l_card_instrument.expiration_date;
		OE_Default_Pvt.g_default_instrument_id := l_assignments(1).instrument.instrument_id;
		OE_Default_Pvt.g_default_instr_assignment_id := l_assignments(1).assignment_id;
	END IF;


	--R12 CC Encryption

	--IF l_debug_level > 0 THEN
  	  --oe_debug_pub.add('returned card number is: '||l_card_instrument.card_number);
        --END IF;

	RETURN l_card_instrument.card_number;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
           RETURN NULL;

    WHEN FND_API.G_EXC_ERROR THEN
      l_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RETURN NULL;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RETURN NULL;

    WHEN OTHERS THEN
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'OE_DEFAULT_PVT'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );
      RETURN NULL;
END Get_Credit_Card_Number;

--R12 CC Encryption
FUNCTION Get_Credit_Card_Code
( p_database_object_name IN VARCHAR2
,p_attribute_code IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN


	IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V'
	AND ONT_HEADER_DEF_HDLR.g_record.credit_card_code IS NOT NULL
	AND ONT_HEADER_DEF_HDLR.g_record.credit_card_code <> FND_API.G_MISS_CHAR THEN
		RETURN ONT_HEADER_DEF_HDLR.g_record.credit_card_code;
	ELSIF p_database_object_name = 'OE_AK_HEADER_PAYMENTS_V'
	AND ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_code IS NOT NULL
	AND ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_code <> FND_API.G_MISS_CHAR
	THEN
		RETURN ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_code;
	ELSIF p_database_object_name = 'OE_AK_LINE_PAYMENTS_V'
	AND ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_code IS NOT NULL
	AND ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_code <> FND_API.G_MISS_CHAR
	THEN
		RETURN ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_code;
	END IF;
	RETURN NULL;

END Get_Credit_Card_Code;
--R12 CC Encryption

FUNCTION Get_CC_Holder_Name
	( p_database_object_name IN VARCHAR2
	,p_attribute_code IN VARCHAR2)
RETURN VARCHAR2
IS
   l_Credit_Card_Holder_Name VARCHAR2(80);
   l_Bank_Account_ID    Number;
/**
   Cursor C_Holder_Name (X_Bank_Account_ID NUMBER) is
		SELECT bank_account_name
		FROM   ap_bank_accounts
		WHERE  bank_account_id = X_Bank_Account_Id
		AND    bank_branch_id=1
		AND    account_type='EXTERNAL';

   Cursor C_Holder_Name2 (X_CC_Number VARCHAR2) is
		SELECT bank_account_name
		FROM   ap_bank_accounts
                WHERE  bank_account_num=X_CC_Number
		AND    bank_branch_id=1
		AND    account_type='EXTERNAL'
                AND    rownum=1;
**/

   Cursor get_hdr_sold_inv(x_header_id number) is
                SELECT sold_to_org_id, invoice_to_org_id
                from oe_order_headers_all
                where header_id = x_header_id;

   Cursor get_line_sold_inv(x_line_id number) is
                SELECT sold_to_org_id, invoice_to_org_id
                from oe_order_lines_all
                where line_id = x_line_id;

   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   l_credit_card_number VARCHAR2(80) := NULL;
   l_cust_org_id number;
   l_invoice_to_org_id number;

BEGIN

   /*
   ** Bug Fix # 2297053: CC Holder now defaulted from CC Number.
   ** Old defaulting code will not even get executed now.
   */
   --R12 CC Encryption
   IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V'
   AND ONT_HEADER_DEF_HDLR.g_record.credit_card_holder_name IS NOT NULL
   AND ONT_HEADER_DEF_HDLR.g_record.credit_card_holder_name
		<> FND_API.G_MISS_CHAR
   THEN

	RETURN ONT_HEADER_DEF_HDLR.g_record.credit_card_holder_name;
   ELSIF p_database_object_name = 'OE_AK_HEADER_PAYMENTS_V'
   AND ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_holder_name IS NOT NULL
   AND ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_holder_name
		<> FND_API.G_MISS_CHAR
   THEN
	RETURN ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_holder_name;
   ELSIF p_database_object_name = 'OE_AK_LINE_PAYMENTS_V'
   AND ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_holder_name IS NOT NULL
   AND ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_holder_name
		<> FND_API.G_MISS_CHAR
   THEN
	RETURN ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_holder_name;
   END IF;
   RETURN NULL;

  /*IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V' THEN
     l_credit_card_number := ONT_HEADER_DEF_HDLR.g_record.credit_card_number;
  ELSIF p_database_object_name = 'OE_AK_HEADER_PAYMENTS_V' THEN
     l_credit_card_number := ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_number;
  ELSIF p_database_object_name = 'OE_AK_LINE_PAYMENTS_V' THEN
     l_credit_card_number := ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_number;
  END IF;

  IF l_credit_card_number IS NOT NULL AND
       l_credit_card_number <> FND_API.G_MISS_CHAR THEN
      OPEN  C_Holder_Name2(l_credit_card_number);
      FETCH C_Holder_Name2 INTO l_Credit_Card_Holder_Name;
      CLOSE C_Holder_Name2;

  END IF;

  RETURN l_Credit_Card_Holder_Name;

  -- code below is not needed. Hence the return statement is above this line

  IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V' THEN

    IF ONT_HEADER_DEF_HDLR.g_record.sold_to_org_id IS NOT NULL
    AND ONT_HEADER_DEF_HDLR.g_record.sold_to_org_id <> FND_API.G_MISS_NUM
    THEN

       l_cust_org_id := ONT_HEADER_DEF_HDLR.g_record.sold_to_org_id;
       IF ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id IS NOT NULL
       AND ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id <> FND_API.G_MISS_NUM
       THEN
         l_invoice_to_org_id := ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id;
       END IF;  -- if ont_header_def_hdlr.g_record.invoice_to...
    END IF;  -- if ont_header_def_hdlr.g_record.sold_to_org_id is not null

  ELSIF p_database_object_name = 'OE_AK_HEADER_PAYMENTS_V' THEN

        OPEN get_hdr_sold_inv(ONT_HEADER_PAYMENT_DEF_HDLR.g_record.header_id);
        FETCH get_hdr_sold_inv into l_cust_org_id, l_invoice_to_org_id;
        CLOSE get_hdr_sold_inv;

  ELSIF p_database_object_name = 'OE_AK_LINE_PAYMENTS_V' THEN

        OPEN get_line_sold_inv(ONT_LINE_PAYMENT_DEF_HDLR.g_record.line_id);
        FETCH get_line_sold_inv into l_cust_org_id, l_invoice_to_org_id;
        CLOSE get_line_sold_inv;

  END IF;

  IF l_cust_org_id IS NOT NULL THEN
      IF l_invoice_to_org_id IS NOT NULL THEN
         l_Bank_Account_ID := arp_bank_pkg.get_primary_bank_acct
			( l_cust_org_id
			, l_invoice_to_org_id
			, TRUE);
      ELSE
         l_Bank_Account_ID := arp_bank_pkg.get_primary_bank_acct
			(l_cust_org_id);
      END IF;
   ELSE
      RETURN NULL;
   END IF;

   IF l_Bank_Account_ID is NOT NULL THEN
      OPEN  C_Holder_Name(l_Bank_Account_ID);
      FETCH C_Holder_Name INTO l_Credit_Card_Holder_Name;
      CLOSE C_Holder_Name;
      RETURN l_Credit_Card_Holder_Name;
   ELSE
	 RETURN NULL;
   END IF;*/
   --R12 CC Encryption

EXCEPTION
       WHEN NO_DATA_FOUND THEN
            RETURN NULL;
END Get_CC_Holder_Name;

FUNCTION Get_CC_Expiration_Date
	( p_database_object_name IN VARCHAR2
	,p_attribute_code IN VARCHAR2)
RETURN VARCHAR2
IS
   l_CC_Expiration_Date VARCHAR2(20);
   l_Bank_Account_ID    Number;
/**
   Cursor C_Expiry_Date (X_Bank_Account_ID NUMBER) is
		SELECT to_char(inactive_date,'DD-MON-YYYY')
		FROM   ap_bank_accounts
		WHERE  bank_account_id = X_Bank_Account_Id
		AND    bank_branch_id=1
		AND    account_type='EXTERNAL';

   Cursor C_Expiry_Date2 (X_CC_Number VARCHAR2) is
		SELECT to_char(inactive_date,'DD-MON-YYYY')
		FROM   ap_bank_accounts
                WHERE  bank_account_num=X_CC_Number
		AND    bank_branch_id=1
		AND    account_type='EXTERNAL'
                AND    rownum=1;
**/
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_credit_card_number VARCHAR2(80) := NULL;

BEGIN

	--R12 CC Encryption
	IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V'
	AND ONT_HEADER_DEF_HDLR.g_record.credit_card_expiration_date IS NOT NULL
	AND ONT_HEADER_DEF_HDLR.g_record.credit_card_expiration_date
          	<> FND_API.G_MISS_DATE
        THEN
		RETURN ONT_HEADER_DEF_HDLR.g_record.credit_card_expiration_date;
	ELSIF p_database_object_name = 'OE_AK_HEADER_PAYMENTS_V'
	AND ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_expiration_date IS NOT NULL
	AND ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_expiration_date
        	<> FND_API.G_MISS_DATE
        THEN
		RETURN ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_expiration_date;
	ELSIF p_database_object_name = 'OE_AK_LINE_PAYMENTS_V'
	AND ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_expiration_date IS NOT NULL
	AND ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_expiration_date
        	<> FND_API.G_MISS_DATE
        THEN
		RETURN ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_expiration_date;
	END IF;

	RETURN NULL;

   /*
   ** Bug Fix # 2297053: CC Exp Dt now defaulted from CC Number.
   ** Old defaulting code will not even get executed now.
   */

  /*IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V' THEN
     l_credit_card_number := ONT_HEADER_DEF_HDLR.g_record.credit_card_number;
  ELSIF p_database_object_name = 'OE_AK_HEADER_PAYMENTS_V' THEN
     l_credit_card_number := ONT_HEADER_PAYMENT_DEF_HDLR.g_record.credit_card_number;
  ELSIF p_database_object_name = 'OE_AK_LINE_PAYMENTS_V' THEN
     l_credit_card_number := ONT_LINE_PAYMENT_DEF_HDLR.g_record.credit_card_number;
  END IF;

  IF l_credit_card_number IS NOT NULL AND
     l_credit_card_number <> FND_API.G_MISS_CHAR THEN
      OPEN  C_Expiry_Date2(l_credit_card_number);
      FETCH C_Expiry_Date2 INTO l_CC_Expiration_Date;
      CLOSE C_Expiry_Date2;
  END IF;

  RETURN l_CC_Expiration_Date;

   IF ONT_HEADER_DEF_HDLR.g_record.sold_to_org_id IS NOT NULL
	 AND ONT_HEADER_DEF_HDLR.g_record.sold_to_org_id <> FND_API.G_MISS_NUM THEN
      IF ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id IS NOT NULL
	    AND ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id <> FND_API.G_MISS_NUM THEN
         l_Bank_Account_ID := arp_bank_pkg.get_primary_bank_acct
			(ONT_HEADER_DEF_HDLR.g_record.sold_to_org_id
			, ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id
			, TRUE);
      ELSE
         l_Bank_Account_ID := arp_bank_pkg.get_primary_bank_acct
			(ONT_HEADER_DEF_HDLR.g_record.sold_to_org_id);
      END IF;
   ELSE
      RETURN NULL;
   END IF;
   IF l_Bank_Account_ID is NOT NULL THEN
      OPEN C_Expiry_Date(l_Bank_Account_ID);
      FETCH C_Expiry_Date INTO l_CC_Expiration_Date;
      CLOSE C_Expiry_Date;
      RETURN l_CC_Expiration_Date;
   ELSE
	 RETURN NULL;
   END IF;*/
   --R12 CC Encryption
   EXCEPTION
       WHEN NO_DATA_FOUND THEN
            RETURN NULL;
END Get_CC_Expiration_Date;

/*************************************************************/
--
-- Following function is no more used in defaulting
--
/*************************************************************/

FUNCTION Get_Tax_Exempt_Number
         ( p_database_object_name 	IN  VARCHAR2
	    ,p_attribute_code 	IN  VARCHAR2)
RETURN VARCHAR2
IS
   l_tax_exempt_number VARCHAR2(80);
   l_line_type_rec       OE_Order_Cache.line_type_Rec_Type;
/***
CURSOR C_Std_Tax_Exemption(X_Ship_To_Org_Id    NUMBER,
                               X_Invoice_To_Org_id NUMBER,
                               X_Date_Ordered           DATE) is

      SELECT tax.tax_exempt_number
      FROM tax_exemptions_qp_v tax,
        oe_ship_to_orgs_v s,
        hr_organization_information hr,
        hz_cust_site_uses site	--ra_site_uses (bug fix 2116858)
      WHERE  tax.ship_to_site_use_id = s.site_use_id
      AND    s.organization_id = X_Ship_To_Org_Id
      AND    tax.bill_to_customer_id = hr.org_information1
      AND    hr.organization_id = X_Invoice_To_Org_Id
      and hr.org_information_context = 'Customer/Supplier Association'
      and SITE.SITE_USE_ID = TO_NUMBER ( hr.ORG_INFORMATION2 )
      and SITE.SITE_USE_CODE = 'BILL_TO'
      AND    trunc(NVL(X_Date_Ordered, SYSDATE))
             between trunc(tax.start_date) and
                     trunc(NVL(tax.end_date, NVL(X_Date_Ordered, SYSDATE)))
      AND    tax.status_code = 'PRIMARY'
      AND ROWNUM = 1;
***/
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
BEGIN
/***
    IF ONT_HEADER_DEF_HDLR.g_record.ship_to_org_id IS NOT NULL AND
        ONT_HEADER_DEF_HDLR.g_record.ship_to_org_id <> FND_API.G_MISS_NUM AND
        ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id IS NOT NULL AND
        ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id <> FND_API.G_MISS_NUM AND
        ONT_HEADER_DEF_HDLR.g_record.ordered_date IS NOT NULL AND
        ONT_HEADER_DEF_HDLR.g_record.ordered_date <> FND_API.G_MISS_DATE
    THEN


      OPEN C_Std_Tax_Exemption(ONT_HEADER_DEF_HDLR.g_record.ship_to_org_id,
                           ONT_HEADER_DEF_HDLR.g_record.Invoice_To_Org_id,
                           ONT_HEADER_DEF_HDLR.g_record.ordered_date);
      FETCH C_Std_Tax_Exemption INTO l_tax_exempt_number;
      CLOSE C_Std_Tax_Exemption;
    END IF;
    RETURN l_tax_exempt_number;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
***/
    RETURN NULL;
END Get_Tax_Exempt_Number;

/*************************************************************/
--
-- Following function is no more used in defaulting
--
/*************************************************************/

FUNCTION Get_Tax_Exempt_Reason
         ( p_database_object_name 	IN  VARCHAR2
	    ,p_attribute_code 	IN  VARCHAR2)
RETURN VARCHAR2
IS
l_tax_exempt_reason_code VARCHAR2(80);
l_line_type_rec       OE_Order_Cache.line_type_Rec_Type;
/***
CURSOR C_Std_Tax_Exemption(X_Ship_To_Org_Id    NUMBER,
                               X_Invoice_To_Org_id NUMBER,
                               X_Date_Ordered           DATE) is
      SELECT tax.tax_exempt_reason_code
      FROM tax_exemptions_qp_v tax,
        oe_ship_to_orgs_v s,
        hr_organization_information hr,
        hz_cust_site_uses site	--ra_site_uses (bug fix 2116858)
      WHERE  tax.ship_to_site_use_id = s.site_use_id
      AND    s.organization_id = X_Ship_To_Org_Id
      AND    tax.bill_to_customer_id = hr.org_information1
      AND    hr.organization_id = X_Invoice_To_Org_Id
      and hr.org_information_context = 'Customer/Supplier Association'
      and SITE.SITE_USE_ID = TO_NUMBER ( hr.ORG_INFORMATION2 )
      and SITE.SITE_USE_CODE = 'BILL_TO'
      AND    trunc(NVL(X_Date_Ordered, SYSDATE))
             between trunc(tax.start_date) and
                     trunc(NVL(tax.end_date, NVL(X_Date_Ordered, SYSDATE)))
      AND    tax.status_code = 'PRIMARY'
      AND ROWNUM = 1;
***/
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
BEGIN
/***
    IF ONT_HEADER_DEF_HDLR.g_record.ship_to_org_id IS NOT NULL AND
        ONT_HEADER_DEF_HDLR.g_record.ship_to_org_id <> FND_API.G_MISS_NUM AND
        ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id IS NOT NULL AND
        ONT_HEADER_DEF_HDLR.g_record.invoice_to_org_id <> FND_API.G_MISS_NUM AND
        ONT_HEADER_DEF_HDLR.g_record.ordered_date IS NOT NULL AND
        ONT_HEADER_DEF_HDLR.g_record.ordered_date <> FND_API.G_MISS_DATE
    THEN

      OPEN C_Std_Tax_Exemption(ONT_HEADER_DEF_HDLR.g_record.ship_to_org_id,
                           ONT_HEADER_DEF_HDLR.g_record.Invoice_To_Org_id,
                           ONT_HEADER_DEF_HDLR.g_record.ordered_date);
      FETCH C_Std_Tax_Exemption INTO l_tax_exempt_reason_code;
      CLOSE C_Std_Tax_Exemption;
    END IF;
    RETURN l_tax_exempt_reason_code;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
***/
    RETURN NULL;
END Get_Tax_Exempt_Reason;

-- Added for new view-defination (oe_tax_exemptions_qp_v)
-- for Tax Exemption details.

FUNCTION Get_Tax_Exemption_Details
         ( p_database_object_name 	IN  VARCHAR2
	    ,p_attribute_code 	IN  VARCHAR2)
RETURN VARCHAR2
IS
l_tax_exempt_flag        VARCHAR2(1)  := NULL;
l_tax_exempt_number      VARCHAR2(80) := NULL;
l_tax_exempt_reason_code VARCHAR2(80) := NULL;
l_line_type_rec       	 OE_Order_Cache.line_type_Rec_Type;

-- eBTax changes
/*
CURSOR C_Line_Std_Tax_Exemption(X_Ship_To_Org_Id    NUMBER,
                               X_Invoice_To_Org_id NUMBER,
                               X_Sold_To_Org_id NUMBER,
                               X_Tax_Date   DATE,
						 X_Tax_Code  VARCHAR2) is
--* recheck the joins
      SELECT tax_exempt_number,tax_exempt_reason_code
        FROM zx_exemptions_v
       WHERE site_use_id = NVL(X_Ship_To_Org_Id,X_Invoice_To_Org_id)
         AND cust_account_id = X_Sold_To_Org_Id
--*	 AND tax_code = X_Tax_Code
         AND trunc(NVL(X_Tax_Date, SYSDATE)) BETWEEN trunc(effective_from) and
                     trunc(NVL(effective_to, NVL(X_Tax_Date, SYSDATE)))
         AND status_code = 'PRIMARY'
         AND rownum = 1;
*/

  l_ship_to_cust_Acct_id  hz_cust_Accounts.cust_Account_id%type;
  l_ship_to_party_id      hz_cust_accounts.party_id%type;
  l_ship_to_party_site_id hz_party_sites.party_site_id%type;
  l_bill_to_cust_Acct_id  hz_cust_Accounts.cust_Account_id%type;
  l_bill_to_party_id      hz_cust_accounts.party_id%type;
  l_bill_to_party_site_id hz_party_sites.party_site_id%type;
  l_org_id                NUMBER;
 --  l_legal_entity_id       NUMBER;

     cursor partyinfo(p_site_org_id HZ_CUST_SITE_USES_ALL.SITE_USE_ID%type) is
     SELECT cust_acct.cust_account_id,
            cust_Acct.party_id,
            acct_site.party_site_id,
            site_use.org_id
      FROM
            HZ_CUST_SITE_USES_ALL       site_use,
            HZ_CUST_ACCT_SITES_ALL      acct_site,
            HZ_CUST_ACCOUNTS_ALL        cust_Acct
     WHERE  site_use.site_use_id = p_site_org_id
       AND  site_use.cust_acct_site_id  = acct_site.cust_acct_site_id
       and  acct_site.cust_account_id = cust_acct.cust_account_id;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_line_type_rec :=  oe_order_cache.load_line_type(ONT_LINE_DEF_HDLR.g_record.line_type_id);

    IF nvl(ONT_LINE_DEF_HDLR.g_record.tax_exempt_flag, 'S') <> 'R' AND
       l_line_type_rec.calculate_tax_flag = 'N' THEN

       RETURN NULL;
    END IF;

    -- If defaulting for Header Level Tax exemptions
    IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V' THEN
	   RETURN NULL;

    -- If defaulting for Line Level Tax exemptions

    ELSIF p_database_object_name = 'OE_AK_ORDER_LINES_V' THEN

        IF ONT_LINE_Def_Hdlr.g_record.tax_exempt_flag = 'S' THEN

            -- bug 5485367 when tax_exempt_flag is 'S', shouldn't have any tax_exempt_number
            -- without tax_exempt_number, tax_exempt_reason is not necessary either
            -- so the following defaulting code is no longer used
            IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'Do not default tax exempt because flag is standard');
            END IF;
            RETURN NULL;
            -- Check whether the attribute has got a value in privious call to
            -- the related attribute.
            -- e.g. when tax exempt number is defaulted, the reason code is also
            -- retrieved and stored in the global record
            -- (OE_Line_DEF_HANDLER.g_record). It can used in defaulting the
            -- tax exempt reason.

            IF p_attribute_code = 'TAX_EXEMPT_REASON' THEN
                IF ONT_LINE_Def_Hdlr.g_record.tax_exempt_reason_code <> FND_API.G_MISS_CHAR
                THEN
                    RETURN ONT_LINE_Def_Hdlr.g_record.tax_exempt_reason_code;
                END IF;
            ELSIF  p_attribute_code = 'TAX_EXEMPT_NUMBER' THEN
                IF ONT_LINE_Def_Hdlr.g_record.tax_exempt_number <> FND_API.G_MISS_CHAR
                THEN
                    RETURN ONT_LINE_Def_Hdlr.g_record.tax_exempt_number;
                END IF;
            END IF;
            IF ((ONT_LINE_Def_Hdlr.g_record.ship_to_org_id IS NOT NULL AND
                ONT_LINE_Def_Hdlr.g_record.ship_to_org_id <> FND_API.G_MISS_NUM) OR
               (ONT_LINE_Def_Hdlr.g_record.invoice_to_org_id IS NOT NULL AND
                ONT_LINE_Def_Hdlr.g_record.invoice_to_org_id <> FND_API.G_MISS_NUM)) AND
                ONT_LINE_Def_Hdlr.g_record.sold_to_org_id IS NOT NULL AND
                ONT_LINE_Def_Hdlr.g_record.sold_to_org_id <> FND_API.G_MISS_NUM AND
                ONT_LINE_Def_Hdlr.g_record.tax_date IS NOT NULL AND
                ONT_LINE_Def_Hdlr.g_record.tax_date <> FND_API.G_MISS_DATE AND
                ONT_LINE_Def_Hdlr.g_record.tax_code IS NOT NULL AND
                ONT_LINE_Def_Hdlr.g_record.tax_code <> FND_API.G_MISS_CHAR
            THEN
            --bsadri if the  cached values are the same do not fetch them
              IF nvl(ONT_LINE_Def_Hdlr.g_record.ship_to_org_id,FND_API.G_MISS_NUM)
             <>nvl( OE_Order_Cache.g_TAX_EXEMPTION_CACH.ship_to_org_id,FND_API.G_MISS_NUM)
               OR nvl(ONT_LINE_Def_Hdlr.g_record.invoice_to_org_id,FND_API.G_MISS_NUM) <>
                NVL( OE_Order_Cache.g_TAX_EXEMPTION_CACH.invoice_to_org_id,FND_API.G_MISS_NUM)
               OR NVL(ONT_LINE_Def_Hdlr.g_record.sold_to_org_id,FND_API.G_MISS_NUM) <>
                 nvl(OE_Order_Cache.g_TAX_EXEMPTION_CACH.sold_to_org_id,FND_API.G_MISS_NUM)
               OR nvl(ONT_LINE_Def_Hdlr.g_record.tax_date,FND_API.G_MISS_DATE) <>
                 nvl(OE_Order_Cache.g_TAX_EXEMPTION_CACH.tax_date,FND_API.G_MISS_DATE)
               OR nvl(ONT_LINE_Def_Hdlr.g_record.tax_code,FND_API.G_MISS_CHAR) <>
                 nvl(OE_Order_Cache.g_TAX_EXEMPTION_CACH.tax_code ,FND_API.G_MISS_CHAR)
              THEN --{
           -- eBTax changes
             /*   OPEN C_Line_Std_Tax_Exemption(ONT_LINE_Def_Hdlr.g_record.ship_to_org_id,
                             ONT_LINE_Def_Hdlr.g_record.Invoice_To_Org_id,
                             ONT_LINE_Def_Hdlr.g_record.sold_To_Org_id,
                             ONT_LINE_Def_Hdlr.g_record.tax_date,
                             ONT_LINE_Def_Hdlr.g_record.tax_code);
                FETCH C_Line_Std_Tax_Exemption INTO l_tax_exempt_number,
                                                    l_tax_exempt_reason_code;
                CLOSE C_Line_Std_Tax_Exemption;
              */

               open partyinfo(ONT_LINE_Def_Hdlr.g_record.Invoice_To_Org_id);
               fetch partyinfo into l_bill_to_cust_Acct_id,
                                    l_bill_to_party_id,
                                    l_bill_to_party_site_id,
                                    l_org_id;
               close partyinfo;

               if ONT_LINE_Def_Hdlr.g_record.ship_to_org_id = ONT_LINE_Def_Hdlr.g_record.Invoice_To_Org_id then
                  l_ship_to_cust_Acct_id    :=  l_bill_to_cust_Acct_id;
                  l_ship_to_party_id        :=  l_bill_to_party_id;
                  l_ship_to_party_site_id   :=  l_bill_to_party_site_id ;
               else
                  open partyinfo(ONT_LINE_Def_Hdlr.g_record.ship_to_org_id);
                  fetch partyinfo into l_ship_to_cust_Acct_id,
                                    l_ship_to_party_id,
                                    l_ship_to_party_site_id,
                                    l_org_id;
                  close partyinfo;
               end if;


               SELECT EXEMPT_CERTIFICATE_NUMBER,
                      EXEMPT_REASON_CODE
                 INTO l_tax_exempt_number,
                      l_tax_exempt_reason_code
                 FROM ZX_EXEMPTIONS_V
                WHERE
                      nvl(site_use_id,nvl(ONT_LINE_Def_Hdlr.g_record.ship_to_org_id,
                                        ONT_LINE_Def_Hdlr.g_record.invoice_to_org_id))
                      =  nvl(ONT_LINE_Def_Hdlr.g_record.ship_to_org_id,
                                        ONT_LINE_Def_Hdlr.g_record.Invoice_to_org_id)
                  AND nvl(cust_account_id, l_bill_to_cust_acct_id) = l_bill_to_cust_acct_id
                  AND nvl(PARTY_SITE_ID,nvl(l_ship_to_party_site_id, l_bill_to_party_site_id))=
                                    nvl(l_ship_to_party_site_id, l_bill_to_party_site_id)
                  AND  org_id = l_org_id
                  AND  party_id = l_bill_to_party_id
       --         AND nvl(LEGAL_ENTITY_ID,-99) IN (nvl(l_legal_entity_id, legal_entity_id), -99)
                  AND EXEMPTION_STATUS_CODE = 'PRIMARY'
                  AND TRUNC(NVL(ONT_LINE_Def_Hdlr.g_record.tax_date,sysdate))
                        BETWEEN TRUNC(EFFECTIVE_FROM)
                                AND TRUNC(NVL(EFFECTIVE_TO,NVL(ONT_LINE_Def_Hdlr.g_record.tax_date,sysdate)))
                  AND ROWNUM = 1;

            -- end eBtax changes


                  OE_Order_Cache.g_TAX_EXEMPTION_CACH.ship_to_org_id :=
                    ONT_LINE_Def_Hdlr.g_record.ship_to_org_id ;
                  OE_Order_Cache.g_TAX_EXEMPTION_CACH.invoice_to_org_id :=
                    ONT_LINE_Def_Hdlr.g_record.invoice_to_org_id;
                  OE_Order_Cache.g_TAX_EXEMPTION_CACH.sold_to_org_id :=
                    ONT_LINE_Def_Hdlr.g_record.sold_to_org_id ;
                  OE_Order_Cache.g_TAX_EXEMPTION_CACH.tax_date :=
                    ONT_LINE_Def_Hdlr.g_record.tax_date;
                  OE_Order_Cache.g_TAX_EXEMPTION_CACH.tax_code :=
                    ONT_LINE_Def_Hdlr.g_record.tax_code;
                  OE_Order_Cache.g_TAX_EXEMPTION_CACH.tax_exempt_number :=
                     l_tax_exempt_number;
                  OE_Order_Cache.g_TAX_EXEMPTION_CACH.tax_exempt_reason_code :=
                     l_tax_exempt_reason_code;


              ELSE --}{
                --use the cached values
                l_tax_exempt_number :=
                    OE_Order_Cache.g_TAX_EXEMPTION_CACH.tax_exempt_number;
                l_tax_exempt_reason_code :=
                    OE_Order_Cache.g_TAX_EXEMPTION_CACH.tax_exempt_reason_code;
              END IF; --}
            END IF;

        ELSIF ONT_LINE_Def_Hdlr.g_record.tax_exempt_flag = 'R' THEN
           RETURN NULL;

        ELSIF ONT_LINE_Def_Hdlr.g_record.tax_exempt_flag = 'E' THEN

            -- Check whether the attribute has got a value in privious call to
            -- the related attribute.
            -- e.g. when tax exempt number is defaulted, the reason code is also
            -- retrieved and stored in the global record
            -- (OE_Line_DEF_HANDLER.g_record). It can used in defaulting the
            -- tax exempt reason.

            IF p_attribute_code = 'TAX_EXEMPT_REASON' THEN
                IF ONT_LINE_Def_Hdlr.g_record.tax_exempt_reason_code <> FND_API.G_MISS_CHAR
                THEN
                    RETURN ONT_LINE_Def_Hdlr.g_record.tax_exempt_reason_code;
                END IF;
            ELSIF  p_attribute_code = 'TAX_EXEMPT_NUMBER' THEN
                IF ONT_LINE_Def_Hdlr.g_record.tax_exempt_number <> FND_API.G_MISS_CHAR
                THEN
                    RETURN ONT_LINE_Def_Hdlr.g_record.tax_exempt_number;
                END IF;
            END IF;


            -- Check the Header Record for the Tax Handling

            BEGIN
                SELECT tax_exempt_flag,
                       tax_exempt_number,
                       tax_exempt_reason_code
                INTO   l_tax_exempt_flag,
                       l_tax_exempt_number,
                       l_tax_exempt_reason_code
                FROM   OE_ORDER_HEADERS_ALL
                WHERE  header_id = ONT_LINE_Def_Hdlr.g_record.header_id;
                IF l_tax_exempt_flag <> 'E' THEN
                   l_tax_exempt_number := NULL;
                   l_tax_exempt_reason_code := NULL;
                END IF;

            -- ??? problem here is that if the header level flag is not 'E' then
            -- the tax exempt reason will remain null. It will fail in the
            -- validation for the Order Line as the Tax Exempt Reason is a
            -- required field at line level when the Tax Exempt Flag = 'E'.

            END;

        END IF;

    END IF;
   -- bug 5184842 only set both when both needs to be defaulted
   -- otherwise, the return value should take care
   IF (ONT_LINE_Def_Hdlr.g_record.tax_exempt_reason_code = FND_API.G_MISS_CHAR
     AND ONT_LINE_Def_Hdlr.g_record.tax_exempt_number = FND_API.G_MISS_CHAR)
   THEN
     IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'DEFAULTED TAX EXEMPT NUMBER/REASON '||L_TAX_EXEMPT_NUMBER|| '/' || L_TAX_EXEMPT_REASON_CODE ) ;
    END IF;

    ONT_LINE_Def_Hdlr.g_record.tax_exempt_number := l_tax_exempt_number;
    ONT_LINE_Def_Hdlr.g_record.tax_exempt_reason_code := l_tax_exempt_reason_code;
   END IF;--bug5184842

    IF p_attribute_code = 'TAX_EXEMPT_NUMBER' THEN
      IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'DEFAULTED TAX EXEMPT NUMBER '||L_TAX_EXEMPT_NUMBER) ;
    END IF;

            RETURN l_tax_exempt_number;
    ELSIF p_attribute_code = 'TAX_EXEMPT_REASON' THEN
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'DEFAULTED TAX EXEMPT REASON '||L_TAX_EXEMPT_REASON_CODE ) ;
      END IF;
            RETURN l_tax_exempt_reason_code;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V' THEN
            ONT_HEADER_Def_Hdlr.g_record.tax_exempt_number := NULL;
            ONT_HEADER_Def_Hdlr.g_record.tax_exempt_reason_code := NULL;
        ELSIF p_database_object_name = 'OE_AK_ORDER_LINES_V' THEN
            ONT_LINE_Def_Hdlr.g_record.tax_exempt_number := NULL;
            ONT_LINE_Def_Hdlr.g_record.tax_exempt_reason_code := NULL;
        END IF;
        RETURN NULL;

    WHEN OTHERS THEN

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_Tax_Exemption_details'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Tax_Exemption_Details;


-- Get the Set of Books Currency

FUNCTION Get_SOB_currency_Code
         ( p_database_object_name 	IN  VARCHAR2
	    ,p_attribute_code 	IN  VARCHAR2)
RETURN VARCHAR2
IS
X_Currency_Code       VARCHAR2(15);
l_set_of_books_rec    OE_Order_Cache.Set_Of_Books_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    l_set_of_books_rec :=
    OE_Order_Cache.Load_Set_Of_Books;
    x_Currency_Code := l_set_of_books_rec.Currency_Code;

    IF x_Currency_Code = FND_API.G_MISS_CHAR THEN

     x_Currency_Code := Null;

    END IF;

    RETURN x_Currency_Code;

EXCEPTION

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'GET_TAX_CODE'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_SOB_Currency_Code;


-----------------------------------------------------------------------
-- DEFAULTING FUNCTIONS TO BE USED FOR ATTRIBUTES ON ORDER LINE
-----------------------------------------------------------------------

-- Function to get the Default TAX_CODE

FUNCTION Get_Tax_Code
         ( p_database_object_name 	IN  VARCHAR2
	    ,p_attribute_code 	IN  VARCHAR2)
RETURN VARCHAR2
IS
l_site_org_id          NUMBER;
l_org_id               NUMBER;
l_Set_Of_Books_Id	   NUMBER;
l_Ord_Type_Id		   NUMBER;
x_tax_code             VARCHAR2(50);
l_trx_type_id	        NUMBER;
l_set_of_books_rec    OE_Order_Cache.Set_Of_Books_Rec_Type;
l_line_type_rec       OE_Order_Cache.line_type_Rec_Type;
l_organization_id      NUMBER := -1;
l_cust_trx_type_id         NUMBER := 0;
l_calculate_tax_flag     VARCHAR2(1) ;

--bug4333881
l_commitment_id      NUMBER;

/* Cursor C_tax_calculation_flag is
                SELECT tax_calculation_flag
                  into l_calculate_tax_flag
                  FROM RA_CUST_TRX_TYPES
                  WHERE CUST_TRX_TYPE_ID = l_cust_trx_type_id;
*/
                       /* added by Renga for bug 1476390 */
                       --
                       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
                       --
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_DEFAULT_PVT.GET_TAX_CODE' , 1 ) ;
  END IF;

 Begin
    --bug4333881 start
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('line_id : ' ||  ONT_LINE_DEF_HDLR.g_record.line_id);
       oe_debug_pub.add('commitment_id : ' ||  ONT_LINE_DEF_HDLR.g_record.commitment_id);
    END IF;

    l_commitment_id := ONT_LINE_DEF_HDLR.g_record.commitment_id;

    IF l_commitment_id IS NOT NULL AND
       l_commitment_id <> FND_API.G_MISS_NUM THEN
       BEGIN
	  SELECT NVL(cust_type.subsequent_trx_type_id,cust_type.cust_trx_type_id)
	  INTO l_cust_trx_type_id
	  FROM ra_cust_trx_types cust_type,ra_customer_trx_all cust_trx
	  WHERE cust_type.cust_trx_type_id = cust_trx.cust_trx_type_id
	  AND cust_trx.customer_trx_id = l_commitment_id;

	  IF l_debug_level > 0 THEN
	     oe_debug_pub.add( 'value of commitment customer trx type id '||l_cust_trx_type_id,1);
	  END IF;

       EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     l_cust_trx_type_id := 0;
	  WHEN OTHERS THEN
	     RETURN null;
       END;
    ELSE
       l_cust_trx_type_id := OE_Invoice_PUB.Get_Customer_Transaction_Type(ONT_LINE_DEF_HDLR.g_record);
       oe_debug_pub.add( 'value of customer trx type id '||l_cust_trx_type_id,1);
    END IF;
    --bug4333881 end

  --bug 3175277  begin
   --There is no need to load line_type cache again because
   --OE_Invoice_PUB.Get_Customer_Transaction_Type checks the line_type cache to get cust_trx_type_id
  /*if (l_cust_trx_type_id = 0 or l_cust_trx_type_id is null) then
   l_line_type_rec :=  oe_order_cache.load_line_type(ONT_LINE_DEF_HDLR.g_record.line_type_id);
   l_cust_trx_type_id := l_line_type_rec.cust_trx_type_id;
   oe_debug_pub.add( 'customer trx type id:'||l_cust_trx_type_id,1);
  end if; */
  --bug 3175277  end

	-- performance fix for bug 4200055
       IF OE_ORDER_CACHE.g_line_type_rec.cust_trx_type_id = l_cust_trx_type_id THEN
		l_calculate_tax_flag := OE_ORDER_CACHE.g_line_type_rec.calculate_tax_flag ;
       ELSE
		SELECT tax_calculation_flag
                  into l_calculate_tax_flag
                  FROM RA_CUST_TRX_TYPES
                  WHERE CUST_TRX_TYPE_ID = l_cust_trx_type_id;
      END IF ;
      /*if( l_cust_trx_type_id is not NULL or l_cust_trx_type_id <> 0) then
                SELECT tax_calculation_flag
                  into l_calculate_tax_flag
                  FROM RA_CUST_TRX_TYPES
                  WHERE CUST_TRX_TYPE_ID = l_cust_trx_type_id;
      end if; */
      -- end bug 4200055
  --l_line_type_rec :=  oe_order_cache.load_line_type(ONT_LINE_DEF_HDLR.g_record.line_type_id);

  IF l_debug_level > 0 THEN
     oe_debug_pub.add('l_calculate_tax_flag : '|| l_calculate_tax_flag);
  END IF;

  IF nvl(ONT_LINE_DEF_HDLR.g_record.tax_exempt_flag, 'S') <> 'R' AND
     l_calculate_tax_flag = 'N' THEN

     RETURN NULL;
  END IF;

    EXCEPTION
        WHEN No_Data_Found THEN
               oe_debug_pub.add(' in no data found for cust_trx_type_id - tax code ');
       RETURN NULL;

      WHEN OTHERS THEN
       oe_debug_pub.add(' in when others for cust_trx_type_code - tax code' );
   End;

  IF ONT_LINE_DEF_HDLR.g_record.inventory_item_id IS NOT NULL AND
     ONT_LINE_DEF_HDLR.g_record.inventory_item_id <> FND_API.G_MISS_NUM AND
     ONT_LINE_DEF_HDLR.g_record.tax_date IS NOT NULL AND
     ONT_LINE_DEF_HDLR.g_record.tax_date <> FND_API.G_MISS_DATE
  THEN


    OE_GLOBALS.Set_Context;

    l_org_id := OE_GLOBALS.G_ORG_ID;

/* added by Renga for bug 1476390 */

   l_organization_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID', l_org_id);


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP_TO'||TO_CHAR ( ONT_LINE_DEF_HDLR.G_RECORD.SHIP_TO_ORG_ID ) , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BILL_TO'||TO_CHAR ( ONT_LINE_DEF_HDLR.G_RECORD.INVOICE_TO_ORG_ID ) , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'TAX_DATE'||TO_CHAR ( ONT_LINE_DEF_HDLR.G_RECORD.TAX_DATE ) , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SOLD TO'||TO_CHAR ( ONT_LINE_DEF_HDLR.G_RECORD.SOLD_TO_ORG_ID ) , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ORG'||TO_CHAR ( L_ORG_ID ) , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ITEM VALIDATION ORG'||TO_CHAR ( L_ORGANIZATION_ID ) , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ITEM_ID'||TO_CHAR ( ONT_LINE_DEF_HDLR.G_RECORD.INVENTORY_ITEM_ID ) , 3 ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP_FROM'||TO_CHAR ( ONT_LINE_DEF_HDLR.G_RECORD.SHIP_FROM_ORG_ID ) ) ;
    END IF;

    IF l_organization_id IS NOT NULL AND
       l_organization_id <> FND_API.G_MISS_NUM
    THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'REN 1' , 3 ) ;
     END IF;
        -- Get Set of book ID
        l_set_of_books_rec := OE_Order_Cache.Load_Set_Of_Books;
        l_Set_Of_Books_Id := l_set_of_books_rec.set_of_books_id;
      oe_debug_pub.add('Set of books id:'||l_set_of_books_id , 3 ) ;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'REN 2' , 3 ) ;
     END IF;


      --bug 3175277
      l_trx_type_id := l_cust_trx_type_id;
      oe_debug_pub.add('trx type id:'||l_trx_type_id , 3 ) ;

        -- Call the AR's API to get the default tax code

        --bsadri caching the values

          IF nvl(ONT_LINE_DEF_HDLR.g_record.ship_to_org_id,FND_API.G_MISS_NUM)<>

            nvl(OE_Order_Cache.g_TAX_CODE_CACH.ship_to_org_id,FND_API.G_MISS_NUM)
          OR nvl(ONT_LINE_DEF_HDLR.g_record.invoice_to_org_id,FND_API.G_MISS_NUM)<>
            nvl(OE_Order_Cache.g_TAX_CODE_CACH.invoice_to_org_id,FND_API.G_MISS_NUM)
          OR nvl(ONT_LINE_DEF_HDLR.g_record.inventory_item_id,FND_API.G_MISS_NUM) <>
            nvl(OE_Order_Cache.g_TAX_CODE_CACH.inventory_item_id,FND_API.G_MISS_NUM)
          OR nvl(ONT_LINE_DEF_HDLR.g_record.ship_from_org_id,FND_API.G_MISS_NUM)<>
            nvl(OE_Order_Cache.g_TAX_CODE_CACH.ship_from_org_id ,FND_API.G_MISS_NUM)
          OR nvl(ONT_LINE_DEF_HDLR.g_record.tax_date,FND_API.G_MISS_DATE) <>
            nvl(OE_Order_Cache.g_TAX_CODE_CACH.tax_date,FND_API.G_MISS_DATE)
          OR nvl(l_trx_type_id,FND_API.G_MISS_NUM) <>
             nvl( OE_Order_Cache.g_TAX_CODE_CACH.trx_type_id,FND_API.G_MISS_NUM)
 THEN

IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'REN INSIDE TC 1 ' , 3 ) ;
END IF;


	zx_ar_tax_classificatn_def_pkg.get_default_tax_classification(
			p_ship_to_site_use_id => ONT_LINE_DEF_HDLR.g_record.ship_to_org_id,
			p_bill_to_site_use_id => ONT_LINE_DEF_HDLR.g_record.invoice_to_org_id,
			p_inventory_item_id => ONT_LINE_DEF_HDLR.g_record.inventory_item_id,
			p_organization_id =>  ONT_LINE_DEF_HDLR.g_record.ship_from_org_id,
			p_set_of_books_id => l_Set_Of_Books_Id,
			p_trx_date => trunc(ONT_LINE_DEF_HDLR.g_record.tax_date),
			p_trx_type_id => l_trx_type_id,
			p_tax_classification_code => x_tax_code,
			appl_short_name => 'ONT',
			p_entity_code => 'OE_ORDER_HEADERS',
			p_event_class_code => 'SALES_TRANSACTION_TAX_QUOTE',
			p_application_id => 660,
			p_internal_organization_id => l_org_id);

             OE_Order_Cache.g_TAX_CODE_CACH.ship_to_org_id :=
                                    ONT_LINE_DEF_HDLR.g_record.ship_to_org_id;
             OE_Order_Cache.g_TAX_CODE_CACH.invoice_to_org_id :=
                                    ONT_LINE_DEF_HDLR.g_record.invoice_to_org_id;
             OE_Order_Cache.g_TAX_CODE_CACH.inventory_item_id :=
                                    ONT_LINE_DEF_HDLR.g_record.inventory_item_id;
             OE_Order_Cache.g_TAX_CODE_CACH.ship_from_org_id :=
                                    ONT_LINE_DEF_HDLR.g_record.ship_from_org_id;
             OE_Order_Cache.g_TAX_CODE_CACH.tax_date :=
                                    ONT_LINE_DEF_HDLR.g_record.tax_date;
             OE_Order_Cache.g_TAX_CODE_CACH.trx_type_id :=
                                    l_trx_type_id;
             OE_Order_Cache.g_TAX_CODE_CACH.tax_code := x_tax_code;

          ELSE
             --use the cached values
             x_tax_code := OE_Order_Cache.g_TAX_CODE_CACH.tax_code ;

          END IF; /* if cached values are different than passed values */

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'DEFAULTED TAX CODE IS '||X_TAX_CODE ) ;
        END IF;
        IF (x_tax_code IS NOT NULL) THEN
            RETURN x_tax_code;
        END IF;

    END IF; /* if l_organization_id is not null */

  END IF; /* if inventory_item_id and tax_date are not null and not missing */

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_DEFAULT_PVT.GET_TAX_CODE' , 1 ) ;
  END IF;
    RETURN NULL;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

       RETURN NULL;

    WHEN OTHERS THEN

    	IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	    OE_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	        'GET_TAX_CODE'
	    );
    	END IF;

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Tax_Code;

FUNCTION Get_Commitment_From_Agreement
	(p_database_object_name IN VARCHAR2
	,p_attribute_code IN VARCHAR2)
RETURN NUMBER
IS
   l_trans_curr_code 		VARCHAR2(30);
   l_Commitment_id 		NUMBER:= NULL;
   l_agreement_id 		NUMBER := NULL;
   l_class                      VARCHAR2(30);
   l_so_source_code             VARCHAR2(30);
   l_oe_installed_flag          VARCHAR2(30);
   l_commitment_bal              NUMBER;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_DEFAULT_PVT.GET_COMMITMENT_FROM_AGREEMENT' , 1 ) ;
    END IF;

    IF ONT_LINE_Def_Hdlr.g_record.Agreement_id IS NOT NULL THEN
       SELECT transactional_curr_code
       INTO l_trans_curr_code
       FROM oe_order_headers
       WHERE header_id = ONT_LINE_Def_Hdlr.g_record.header_id;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AGREEMENT_ID: '||ONT_LINE_DEF_HDLR.G_RECORD.AGREEMENT_ID|| ' L_TRANS_CURR_CODE: '||L_TRANS_CURR_CODE ||' SOLD TO ORG: '||ONT_LINE_DEF_HDLR.G_RECORD.SOLD_TO_ORG_ID ) ;
       END IF;

      --Bug 3247840 fix query for better performance
      SELECT /* MOAC_SQL_CHANGE */ customer_trx_id
      INTO l_Commitment_id
      FROM ra_customer_trx_all ratrx,
           ra_cust_trx_types ractt
      WHERE ractt.type in ('DEP','GUAR')
      AND ratrx.cust_trx_type_id = ractt.cust_trx_type_id
      AND ratrx.org_id = ractt.org_id
      AND ratrx.bill_to_customer_id =  ONT_LINE_Def_Hdlr.g_record.sold_to_org_id
      AND ratrx.invoice_currency_code = l_trans_curr_code
      AND TRUNC(sysdate) BETWEEN TRUNC(
          NVL(ratrx.start_date_commitment, sysdate))
      AND TRUNC(NVL( ratrx.end_date_commitment, sysdate ))
      AND ratrx.agreement_id = ONT_LINE_Def_Hdlr.g_record.Agreement_id
 /* Peformance changes for sql id 14882692 */
      AND ratrx.complete_flag = 'Y'

		UNION ALL /* Peformance changes for sql id 14882692 */

      SELECT /* MOAC_SQL_CHANGE */ customer_trx_id
      --INTO l_Commitment_id
      FROM ra_customer_trx_all ratrx,
           ra_cust_trx_types ractt
      WHERE ractt.type in ('DEP','GUAR')
      AND ratrx.cust_trx_type_id = ractt.cust_trx_type_id
      AND ratrx.org_id = ractt.org_id
      AND ratrx.bill_to_customer_id IN (
                  SELECT      cust_account_id
                  FROM        hz_cust_acct_relate
                  WHERE       related_cust_account_id = ONT_LINE_Def_Hdlr.g_record.sold_to_org_id
                  AND         cust_account_id <> ONT_LINE_Def_Hdlr.g_record.sold_to_org_id
                  AND         status = 'A'
                  AND         bill_to_flag = 'Y')
      AND ratrx.invoice_currency_code = l_trans_curr_code
      AND TRUNC(sysdate) BETWEEN TRUNC(
          NVL(ratrx.start_date_commitment, sysdate))
      AND TRUNC(NVL( ratrx.end_date_commitment, sysdate ))
      AND ratrx.agreement_id = ONT_LINE_Def_Hdlr.g_record.Agreement_id
      AND ratrx.complete_flag = 'Y';

      -- bug 2270925, to validate the commitment balance is greater than zero
      -- before defaulting it from agreement.
      l_class := NULL;
      l_so_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
      l_oe_installed_flag := 'I';

      l_commitment_bal := ARP_BAL_UTIL.GET_COMMITMENT_BALANCE(
                        l_commitment_id
                        ,l_class
                        ,l_so_source_code
                        ,l_oe_installed_flag );

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXVDEFB: COMMITMENT BALANCE IS: '||L_COMMITMENT_BAL ) ;
      END IF;

      IF l_commitment_bal > 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'AGREEMENT IS NOT NULL - RETURNING COMMITMENT: '||L_COMMITMENT_ID ) ;
        END IF;
        RETURN l_Commitment_id;
      ELSE
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'COMMITMENT BALANCE IS ZERO - RETURNING NULL COMMITMENT' ) ;
END IF;
        RETURN NULL;
      END IF;

    ELSE
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'AGREEMENT IS NULL ON LINE - RETURNING NULL COMMITMENT' ) ;
       END IF;
       RETURN NULL;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_DEFAULT_PVT.GET_COMMITMENT_FROM_AGREEMENT' , 1 ) ;
    END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN WHEN NO DATA FOUND - RETURNING NULL COMMITMENT' ) ;
           END IF;
           RETURN NULL;
      WHEN TOO_MANY_ROWS THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN WHEN TOO MANY ROWS - RETURNING NULL COMMITMENT' ) ;
           END IF;
           RETURN NULL;
END Get_Commitment_From_Agreement;

FUNCTION Get_Accounting_Rule_Duration
        (p_database_object_name IN VARCHAR2
        ,p_attribute_code IN VARCHAR2)
RETURN NUMBER IS
l_accounting_rule_duration NUMBER;
l_rule_type VARCHAR2(10);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_DEFAULT_PVT. GET_ACCOUNTING_RULE_DURATION' , 1 ) ;
    END IF;
    IF OE_CODE_CONTROL.Get_Code_Release_Level < '110509' THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXVDEFB: BELOW PACK I , DO NOT DEFAULT ACCOUNTING DURATION' ) ;
       END IF;
       RETURN NULL;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ITEM_TYPE_CODE:'||ONT_LINE_DEF_HDLR.G_RECORD.ITEM_TYPE_CODE||':ACCOUNTING_RULE_ID:'||ONT_LINE_DEF_HDLR.G_RECORD.ACCOUNTING_RULE_ID ) ;
    END IF;
    IF  (ONT_LINE_Def_Hdlr.g_record.item_type_code <> 'SERVICE') AND  ONT_LINE_Def_Hdlr.g_record.Accounting_Rule_ID IS NOT NULL THEN
         SELECT type
         INTO l_rule_type
         FROM ra_rules
         WHERE rule_id= ONT_LINE_Def_Hdlr.g_record.Accounting_Rule_ID;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'RULE_TYPE IS:'||L_RULE_TYPE ) ;
          END IF;
         IF l_rule_type = 'ACC_DUR' THEN
             SELECT accounting_rule_duration
             INTO l_accounting_rule_duration
             FROM   oe_order_headers
             WHERE header_id = ONT_LINE_Def_Hdlr.g_record.header_id;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'EXITING OE_DEFAULT_PVT.GET_ACCOUNTING_RULE_DURATION - DURATION:'|| L_ACCOUNTING_RULE_DURATION ) ;
             END IF;
              RETURN l_accounting_rule_duration;
          END IF;
    END IF;
    RETURN NULL;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_DEFAULT_PVT.GET_ACCOUNTING_RULE_DURATION' ) ;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'IN WHEN OTHERS - RETURNING NULL ACCOUNTING RULE DURATION' ) ;
           END IF;
           RETURN NULL;
END Get_Accounting_Rule_Duration;

-- QUOTING changes
-- Returns ID of the primary location with site use
-- of 'SOLD_TO'
FUNCTION Get_Primary_Customer_Location
         ( p_database_object_name       IN  VARCHAR2
            ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2
IS
l_sold_to_org_id   NUMBER;
l_site_use_id      NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
 l_sold_to_org_id  := ONT_HEADER_DEF_HDLR.g_record.SOLD_TO_ORG_ID;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('ENTER Get_Primary_Customer_Location');
    oe_debug_pub.add('Sold To Org ID :'||l_sold_to_org_id);
  END IF;

  IF l_sold_to_org_id is not null
     AND l_sold_to_org_id <> fnd_api.g_miss_num
  THEN

    BEGIN

    SELECT /* MOAC_SQL_CHANGE */ SITE.SITE_USE_ID
      INTO l_site_use_id
      FROM HZ_CUST_ACCT_SITES ADDR
            ,HZ_CUST_SITE_USES_ALL SITE
    WHERE ADDR.CUST_ACCOUNT_ID = l_sold_to_org_id
      AND ADDR.STATUS = 'A'
      AND SITE.CUST_ACCT_SITE_ID = ADDR.CUST_ACCT_SITE_ID
      AND ADDR.ORG_ID = SITE.ORG_ID
      AND SITE.SITE_USE_CODE = 'SOLD_TO'
      AND SITE.PRIMARY_FLAG = 'Y'
      AND SITE.STATUS = 'A'
      AND ROWNUM = 1;

    RETURN l_site_use_id;

    EXCEPTION
    -- Return null if there is no primary sold to site
    WHEN NO_DATA_FOUND THEN
       RETURN NULL;
    END;

  -- Return null if there is no customer
  ELSE

     RETURN NULL;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Error in Get_Primary_Customer_Location') ;
      oe_debug_pub.add('Error :'||substr(sqlerrm,1,200)) ;
    END IF;
    RETURN NULL;
END Get_Primary_Customer_Location;

FUNCTION Get_Receipt_Method
         ( p_database_object_name       IN  VARCHAR2
            ,p_attribute_code   IN  VARCHAR2)
RETURN NUMBER
IS
l_header_rec       OE_ORDER_PUB.Header_rec_Type;
l_pay_method_id    NUMBER;
l_payment_type_code  VARCHAR2(30);
l_org_id  NUMBER ;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_header_id number;
BEGIN
l_org_id:= ONT_HEADER_DEF_HDLR.g_record.org_id;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Entering Get_Receipt_Method');
  END IF;

  IF p_database_object_name = 'OE_AK_HEADER_PAYMENTS_V' THEN
     l_payment_type_code := ONT_HEADER_PAYMENT_DEF_HDLR.g_record.payment_type_code;
     l_header_id := ONT_HEADER_PAYMENT_DEF_HDLR.g_record.header_id;

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('payment_type_code from header payments'||l_payment_type_code);
     END IF;
  ELSIF p_database_object_name = 'OE_AK_LINE_PAYMENTS_V' THEN
     l_payment_type_code := ONT_LINE_PAYMENT_DEF_HDLR.g_record.payment_type_code;
     l_header_id := ONT_LINE_PAYMENT_DEF_HDLR.g_record.header_id;

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add('payment_type_code from line payments'||l_payment_type_code ||':org_id:'||l_org_id);
     END IF;
  ELSIF p_database_object_name = 'OE_AK_ORDER_HEADERS_V' THEN
     l_header_id := ONT_HEADER_DEF_HDLR.g_record.header_id;
  END IF;

  IF l_payment_type_code IS NOT NULL AND
     l_payment_type_code <> FND_API.G_MISS_CHAR AND
     l_payment_type_code <> 'COMMITMENT' THEN      /* Bug #3536642 */

     IF l_org_id IS NULL or l_org_id = FND_API.G_MISS_NUM THEN
        select org_id
        into l_org_id
        from oe_order_headers_all
        where header_id = l_header_id;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('org_id:'||l_org_id);
        END IF;
    END IF;

     select receipt_method_id
     into l_pay_method_id
     from oe_payment_types_all
     where payment_type_code = l_payment_type_code
     AND nvl(org_id, -99) = nvl(l_org_id, -99);

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('l_pay_method_id from payment type:'||l_pay_method_id);
     END IF;
     IF l_pay_method_id IS NOT NULL THEN
        RETURN l_pay_method_id;
     END IF;

     IF l_payment_type_code = 'CREDIT_CARD' OR
        l_payment_type_code = 'ACH' OR
        l_payment_type_code = 'DIRECT_DEBIT' THEN -- bug 8771134

        l_header_rec := OE_HEADER_UTIL.Query_Row(l_header_id);

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Sold To Org ID :'||l_header_rec.sold_to_org_id);
           oe_debug_pub.add('Invoice To Org ID :'||l_header_rec.invoice_to_org_id);
           oe_debug_pub.add('Calling OE_Verify_Payment_PUB.Get_Primary_Pay_Method');
        END IF;

        l_pay_method_id := OE_Verify_Payment_PUB.Get_Primary_Pay_Method
                      ( p_header_rec      => l_header_rec ) ;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'After Getting primary payment method'||l_pay_method_id , 5 ) ;
        END IF;

        RETURN l_pay_method_id;
     ELSE
        RETURN l_pay_method_id;
     END IF;
  END IF;
  RETURN NULL;

EXCEPTION
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Error in Get_Receipt_method') ;
      oe_debug_pub.add('Error :'||substr(sqlerrm,1,200)) ;
    END IF;
    RETURN NULL;
END Get_Receipt_Method;

-- Bug 3581592
-- Default deliver to via the API instead of Related Record rule as there
-- is a performance issue with oe_ak_sold_to_orgs_v if primary deliver to
-- is fetched via the view.
FUNCTION Get_Primary_Deliver_To
         ( p_database_object_name       IN  VARCHAR2
            ,p_attribute_code   IN  VARCHAR2)
RETURN VARCHAR2 IS
l_sold_to_org_id         NUMBER;
l_site_use_id            NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Enter Get_Primary_Deliver_To');
  END IF;

  IF p_database_object_name = 'OE_AK_ORDER_HEADERS_V' THEN
     l_sold_to_org_id := ONT_HEADER_DEF_HDLR.g_record.sold_to_org_id;
  ELSIF p_database_object_name = 'OE_AK_ORDER_LINES_V' THEN
     l_sold_to_org_id := ONT_LINE_DEF_HDLR.g_record.sold_to_org_id;
  ELSE
     IF l_debug_level > 0 THEN
        oe_debug_pub.add('Invalid DB object :'||p_database_object_name);
     END IF;
     RETURN NULL;
  END IF;

  IF l_sold_to_org_id is not null
     AND l_sold_to_org_id <> fnd_api.g_miss_num
  THEN

    BEGIN

    SELECT /* MOAC_SQL_CHANGE */ SITE.SITE_USE_ID
      INTO l_site_use_id
      FROM HZ_CUST_ACCT_SITES ADDR
            ,HZ_CUST_SITE_USES_ALL SITE
    WHERE ADDR.CUST_ACCOUNT_ID = l_sold_to_org_id
      AND ADDR.STATUS = 'A'
      AND SITE.CUST_ACCT_SITE_ID = ADDR.CUST_ACCT_SITE_ID
      AND SITE.ORG_ID = ADDR.ORG_ID
      AND SITE.SITE_USE_CODE = 'DELIVER_TO'
      AND SITE.PRIMARY_FLAG = 'Y'
      AND SITE.STATUS = 'A'
      AND ROWNUM = 1;

    RETURN l_site_use_id;

    EXCEPTION
    -- Return null if there is no primary deliver to site
    WHEN NO_DATA_FOUND THEN
       RETURN NULL;
    END;

  -- Return null if there is no customer
  ELSE

     RETURN NULL;

  END IF;

END Get_Primary_Deliver_To;

END OE_Default_Pvt;

/
