--------------------------------------------------------
--  DDL for Package Body OE_CNCL_VALIDATE_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CNCL_VALIDATE_HEADER" AS
/* $Header: OEXVCHDB.pls 120.8 2006/06/26 17:43:08 aycui ship $ */

--  Global constant holding the package name

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_CNCL_Validate_Header';


/* LOCAL PROCEDURES */

/*-------------------------------------------------------
PROCEDURE:    Check_Book_Reqd_Attributes
Description:
--------------------------------------------------------*/

PROCEDURE Check_Book_Reqd_Attributes
( p_header_rec            IN OE_Order_PUB.Header_Rec_Type
, x_return_status         IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_order_type_rec      OE_Order_Cache.Order_Type_Rec_Type;
l_set_of_books_rec    OE_Order_Cache.Set_Of_Books_Rec_Type;
BEGIN

    oe_debug_pub.add('Enter OE_CNCL_VALIDATE_HEADER.CHECK_BOOK_REQD',1);

  -- Check for the following required fields on a booked order:
  -- Order Number, Sold To Org, Invoice To Org,
  -- Price List, Tax Exempt Flag, Sales Person, Order Date

  IF p_header_rec.sold_to_org_id IS NULL
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQUIRED_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
    OE_Order_UTIL.Get_Attribute_Name('SOLD_TO_ORG_ID'));
    OE_MSG_PUB.ADD;
  END IF;

  IF p_header_rec.salesrep_id IS NULL
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQUIRED_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
    OE_Order_UTIL.Get_Attribute_Name('SALESREP_ID'));
    OE_MSG_PUB.ADD;
  END IF;

  IF p_header_rec.ordered_date IS NULL
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQUIRED_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
    OE_Order_UTIL.Get_Attribute_Name('ORDERED_DATE'));
    OE_MSG_PUB.ADD;
  END IF;

  IF p_header_rec.invoice_to_org_id IS NULL
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQUIRED_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
      OE_Order_UTIL.Get_Attribute_Name('INVOICE_TO_ORG_ID'));
    OE_MSG_PUB.ADD;
  END IF;

  IF p_header_rec.tax_exempt_flag IS NULL
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQUIRED_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
      OE_Order_UTIL.Get_Attribute_Name('TAX_EXEMPT_FLAG'));
    OE_MSG_PUB.ADD;
  END IF;


  -- Fix bug 1262790
  -- Ship To Org and Payment Term are required only on regular or
  -- MIXED orders, NOT on RETURN orders

  oe_debug_pub.add('p_header_rec.ship_to_org_id' || to_char(p_header_rec.ship_to_org_id),2);

  IF p_header_rec.order_category_code <>
               OE_GLOBALS.G_RETURN_CATEGORY_CODE THEN

    IF p_header_rec.ship_to_org_id IS NULL
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQUIRED_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_UTIL.Get_Attribute_Name('SHIP_TO_ORG_ID'));
      OE_MSG_PUB.ADD;
    END IF;

    IF p_header_rec.payment_term_id IS NULL
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQUIRED_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_UTIL.Get_Attribute_Name('PAYMENT_TERM_ID'));
      OE_MSG_PUB.ADD;
    END IF;

  END IF;


  -- Check for additional required fields based on flags set
  -- at the order type: agreement, customer po number

  l_order_type_rec := OE_Order_Cache.Load_Order_Type
                      (p_header_rec.order_type_id);

  IF ( l_order_type_rec.agreement_required_flag = 'Y' AND
       p_header_rec.agreement_id IS NULL)
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQUIRED_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
    OE_Order_UTIL.Get_Attribute_Name('AGREEMENT_ID'));
    OE_MSG_PUB.ADD;
  END IF;

  IF ( l_order_type_rec.require_po_flag = 'Y' AND
       p_header_rec.cust_po_number IS NULL)
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQUIRED_ATTRIBUTE');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
    OE_Order_UTIL.Get_Attribute_Name('CUST_PO_NUMBER'));
    OE_MSG_PUB.ADD;
  END IF;


  -- Conversion Type Related Checks

  -- IF SOB currency is dIFferent from order currency,
  -- conversion type is required

  IF p_header_rec.conversion_type_code IS NULL
  THEN
     l_set_of_books_rec := OE_Order_Cache.Load_Set_Of_Books;

     IF ( l_set_of_books_rec.currency_code <>
      p_header_rec.transactional_curr_code) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_VAL_REQ_NON_BASE_CURRENCY');
      FND_MESSAGE.SET_TOKEN
      ('ORDER_CURRENCY',p_header_rec.transactional_curr_code);
      FND_MESSAGE.SET_TOKEN('SOB_CURRENCY',l_set_of_books_rec.currency_code);
      OE_MSG_PUB.ADD;
     END IF;

  -- IF conversion type is 'User', conversion rate AND conversion rate date
  -- required.

  ELSIF p_header_rec.conversion_type_code = 'User'
  THEN

    IF p_header_rec.conversion_rate IS NULL OR
       p_header_rec.conversion_rate_date IS NULL
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_VAL_USER_CONVERSION_TYPE');
      OE_MSG_PUB.ADD;
    END IF;

  END IF; -- END of checks based on conversion type


  -- Checks based on payment type attached to the order

  IF p_header_rec.payment_type_code IS NOT NULL THEN

    -- payment amount should be specIFied
    -- only IF Payment Type is NOT Credit Card

    IF  p_header_rec.payment_type_code <> 'CREDIT_CARD' AND
        p_header_rec.payment_amount IS NULL
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_BOOK_REQUIRED_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
      OE_Order_UTIL.Get_Attribute_Name('PAYMENT_AMOUNT'));
      OE_MSG_PUB.ADD;
    END IF;

    -- check number required IF payment type is Check

    IF (p_header_rec.payment_type_code = 'CHECK' AND
        p_header_rec.check_number IS NULL )
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_VAL_CHECK_NUM_REQD');
      OE_MSG_PUB.ADD;
    END IF;

    -- credit card holder name, number AND expiration date
    -- required for payment type of Credit Card

    /*
    ** Following Validation Moved to Authorize Credit Card
    ** Payment Routine. Not required anymore at BOOKING.
    IF p_header_rec.payment_type_code = 'CREDIT_CARD' THEN
      IF p_header_rec.credit_card_holder_name IS NULL
      OR p_header_rec.credit_card_number IS NULL
      OR p_header_rec.credit_card_expiration_date IS NULL
      THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ONT','OE_VAL_CREDIT_CARD_REQD');
      OE_MSG_PUB.ADD;
      END IF;
    END IF;
    */

  END IF; -- END of checks related to payment type

    oe_debug_pub.add('Exiting OE_CNCL_VALIDATE_HEADER.CHECK_BOOK_REQD',1);
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (  G_PKG_NAME ,
        'Check_Book_Reqd_Attributes'
      );
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Book_Reqd_Attributes;

---------------------------------------------------------------
-- FUNCTION Is_Duplicate_PO_Number
-- Added to fix bug 1162304
-- Returns TRUE if the PO number is referenced on another order
-- for the same customer
---------------------------------------------------------------

FUNCTION Is_Duplicate_PO_Number
( p_cust_po_number                  IN VARCHAR2
, p_sold_to_org_id                  IN NUMBER
, p_header_id                       IN NUMBER
) RETURN BOOLEAN
IS
l_duplicate_exists		varchar2(1);
BEGIN

	SELECT /* MOAC_SQL_NO_CHANGE */ 'Y'
	INTO l_duplicate_exists
	FROM DUAL
	WHERE EXISTS (SELECT 'Y'
			    FROM OE_ORDER_HEADERS
			    WHERE HEADER_ID <> p_header_id
				 AND SOLD_TO_ORG_ID = p_sold_to_org_id
				 AND CUST_PO_NUMBER = p_cust_po_number )
        OR EXISTS (SELECT 'Y'
                   FROM OE_ORDER_LINES
                   WHERE HEADER_ID <> p_header_id
                     AND SOLD_TO_ORG_ID = p_sold_to_org_id
                     AND CUST_PO_NUMBER = p_cust_po_number );

     RETURN TRUE;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
        RETURN FALSE;

END Is_Duplicate_PO_Number;

/*-------------------------------------------------------
PROCEDURE:    Entity
Description:
--------------------------------------------------------*/

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
)
IS
l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_dummy             VARCHAR2(10);
l_price_list_rec    OE_Order_Cache.Price_List_Rec_Type;
-- l_order_type_rec    OE_Order_Cache.Order_Type_Rec_Type;
-- L_agreement_rec     OE_Order_Cache.Agreement_Rec_Type;

l_agreement_name    varchar2(240);
l_sold_to_org       number;
l_price_list_id     number;
lcustomer_relations varchar2(1);
l_list_type_code	VARCHAR2(30);

-- eBTax Changes
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
  -- end eBtax changes

--bug 4729536
Cursor Cur_Customer_Relations IS
    SELECT /*MOAC_SQL_NO_CHANGE*/ 'VALID'
    FROM   oe_ship_to_orgs_v
    WHERE site_use_id = p_header_rec.ship_to_org_id
    AND customer_id = p_header_rec.sold_to_org_id
    AND ROWNUM = 1

    UNION ALL

    SELECT /*MOAC_SQL_NO_CHANGE*/ 'VALID'
    FROM   oe_ship_to_orgs_v osov
    WHERE site_use_id = p_header_rec.ship_to_org_id
    AND EXISTS
		(SELECT 1 FROM
                 HZ_CUST_ACCT_RELATE hcar
                    WHERE hcar.cust_account_id = osov.customer_id AND
		    hcar.related_cust_account_id = p_header_rec.sold_to_org_id
		    /* added the following condition to fix the bug 2002486 */
                    AND hcar.ship_to_flag = 'Y')
    AND ROWNUM = 1;

Cursor Cur_customer_relations_inv IS
    SELECT /*MOAC_SQL_NO_CHANGE*/ 'VALID'
    FROM   oe_invoice_to_orgs_v
    WHERE site_use_id = p_header_rec.invoice_to_org_id
    AND customer_id = p_header_rec.sold_to_org_id
    AND ROWNUM = 1

    UNION ALL

    SELECT /*MOAC_SQL_NO_CHANGE*/ 'VALID'
    FROM   oe_invoice_to_orgs_v oito
    WHERE oito.site_use_id = p_header_rec.invoice_to_org_id
    AND EXISTS(
                    SELECT 1 FROM
                    HZ_CUST_ACCT_RELATE hcar WHERE
		    hcar.cust_account_id = oito.customer_id AND
                    hcar.related_cust_account_id = p_header_rec.sold_to_org_id
                    AND hcar.bill_to_flag = 'Y')
    AND ROWNUM = 1;


BEGIN
    oe_debug_pub.add('Enter OE_CNCL_VALIDATE_HEADER.ENTITY',1);

    --  Check required attributes.
 --lcustomer_relations := FND_PROFILE.VALUE('ONT_CUSTOMER_RELATIONSHIPS');
 lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');




    ----------------------------------------------------------
    --  Check rest of required attributes here.
    ----------------------------------------------------------


    oe_debug_pub.add('p_header_rec.order_type_id' || p_header_rec.order_type_id, 2);

    IF p_header_rec.order_type_id IS NULL
    THEN
      l_return_status := FND_API.G_RET_STS_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_UTIL.Get_Attribute_Name('ORDER_TYPE_ID'));
        OE_MSG_PUB.Add;
      END IF;
    END IF;

    --add messages


    oe_debug_pub.add('p_header_rec.transactional_curr_code' || p_header_rec.transactional_curr_code, 2);

    IF p_header_rec.transactional_curr_code IS NULL
    THEN
      l_return_status := FND_API.G_RET_STS_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_UTIL.Get_Attribute_Name('TRANSACTIONAL_CURR_CODE'));
        OE_MSG_PUB.Add;
      END IF;

    END IF;


    --  Return Error IF a required attribute is missing.
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    ----------------------------------------------------------
    --  Check conditionally required attributes here.
    ----------------------------------------------------------

    --  Check attributes required for booked header


    oe_debug_pub.add('p_header_rec.booked_flag' || p_header_rec.booked_flag, 2);


    IF p_header_rec.booked_flag = 'Y' THEN

      Check_Book_Reqd_Attributes
      ( p_header_rec      => p_header_rec
      , x_return_status    => l_return_status
       );

    END IF;

    -- IF the Tax handling is "Exempt"

     oe_debug_pub.add('p_header_rec.tax_exempt_flag' || p_header_rec.tax_exempt_flag, 2);

    IF p_header_rec.tax_exempt_flag = 'E'
    THEN
     -- Check for Tax exempt reason
      IF p_header_rec.tax_exempt_reason_code IS NULL  OR
         p_header_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR
      THEN
         l_return_status := FND_API.G_RET_STS_ERROR;

         IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
           fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
           OE_Order_UTIL.Get_Attribute_Name('TAX_EXEMPT_REASON_CODE'));
           OE_MSG_PUB.Add;
         END IF;

      END IF;

    END IF; -- IF Tax handling is exempt

    -- IF the TAX handling is STANDARD THEN we can not validate the
    -- Tax Exempt Number as it can be a NULL value.

    -- IF the Tax handling is "Required"
    IF p_header_rec.tax_exempt_flag = 'R'
    THEN

      -- Check for Tax exempt number/Tax exempt reason.

      IF (p_header_rec.tax_exempt_number IS NOT NULL AND
          p_header_rec.tax_exempt_number <> FND_API.G_MISS_CHAR)
          OR
         (p_header_rec.tax_exempt_reason_code IS NOT NULL AND
          p_header_rec.tax_exempt_reason_code <> FND_API.G_MISS_CHAR)
      THEN
          l_return_status := FND_API.G_RET_STS_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            fnd_message.set_name('ONT','OE_TAX_EXEMPTION_NOT_ALLOWED');
            OE_MSG_PUB.Add;
          END IF;
      END IF;

    END IF;

    --  Return Error IF a conditionally required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    ----------------------------------------------------------------
    -- VALIDATE ATTRIBUTE DEPENDENCIES
    ----------------------------------------------------------------

    oe_debug_pub.add('New price ' ||  p_header_rec.price_list_id,2);
    oe_debug_pub.add('New curr ' ||  p_header_rec.transactional_curr_code,2);
    -- Validate currency

    l_price_list_rec :=
    OE_Order_Cache.Load_Price_List ( p_header_rec.price_list_id );


    oe_debug_pub.add('p_header_rec.price_list_id' || p_header_rec.price_list_id, 2);


    IF p_header_rec.price_list_id IS NOT NULL
    THEN

      IF p_header_rec.transactional_curr_code <>
         l_price_list_rec.currency_code
      THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_VAL_ORD_CURRENCY_MISMATCH');
        FND_MESSAGE.SET_TOKEN('ORDER_CURRENCY',
        p_header_rec.transactional_curr_code);
        FND_MESSAGE.SET_TOKEN('PRICE_LIST_CURRENCY',
        l_price_list_rec.currency_code);
        OE_MSG_PUB.Add;
      END IF; -- Currency Mismatch.

    END IF; -- Price list or currency changed.

    -- Currency_date, currency_rate should be null when type is null.


    oe_debug_pub.add('p_header_rec.Conversion_type_code' || p_header_rec.Conversion_type_code, 2);

    IF p_header_rec.Conversion_type_code IS NULL
    THEN
      IF Nvl(p_header_rec.conversion_rate, FND_API.G_MISS_NUM)
                                        <> FND_API.G_MISS_NUM  OR
         Nvl(p_header_rec.conversion_rate_date, FND_API.G_MISS_DATE)
                                        <> FND_API.G_MISS_DATE
      THEN
        l_return_status :=  FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_VAL_CONVERSION_TYPE');
        OE_MSG_PUB.Add;
      END IF;

    END IF;

  -- made changes to the bug 3220059
   -- Validation to check that conversion rate are null when type is not User

  IF p_header_rec.conversion_type_code <> 'User' AND
        p_header_rec.conversion_rate IS NOT NULL
   THEN
    l_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_VALIDATION_CONV_TYPE');
    OE_MSG_PUB.ADD;

  END IF; -- END of checks based on conversion type

    oe_debug_pub.add('p_header_rec.ordered_date' || p_header_rec.ordered_date, 2);

    --  Order Type has to be valid
        BEGIN

          SELECT  'VALID'
          INTO  l_dummy
          FROM  OE_ORDER_TYPES_V
          WHERE  ORDER_TYPE_ID = p_header_rec.order_type_id
          AND  ROWNUM = 1;
          --
          -- Commented out when importing CLOSED orders
          --           AND  p_header_rec.ordered_date
          -- BETWEEN NVL(START_DATE_ACTIVE,p_header_rec.ordered_date)
          -- AND     NVL( END_DATE_ACTIVE,p_header_rec.ordered_date);
          --  Valid Order Type.

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
            OE_Order_Util.Get_Attribute_Name('ORDER_TYPE_ID'));
            OE_MSG_PUB.Add;

          WHEN OTHERS THEN

            IF OE_MSG_PUB.Check_Msg_Level
                          (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN

              OE_MSG_PUB.Add_Exc_Msg
              (  G_PKG_NAME ,
                'Record - Order Type'
               );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;

    --  Agreement depends on Order Type AND Sold To Org


    oe_debug_pub.add('p_header_rec.agreement_id' || p_header_rec.agreement_id, 2);

    IF p_header_rec.agreement_id IS NOT NULL THEN
        -- commented by Geresh
        -- l_agreement_rec :=
        -- OE_Order_Cache.Load_Agreement (p_header_rec.agreement_id);

        BEGIN
		BEGIN
            select list_type_code
		  into l_list_type_code
		  from qp_list_headers_vl
		  where list_header_id = p_header_rec.price_list_id;
		EXCEPTION WHEN NO_DATA_FOUND THEN
		  null;
          END;

          IF NOT OE_GLOBALS.EQUAL(l_list_type_code,'PRL') THEN
		-- any price list with 'PRL' type should be allowed to
		-- be associated with any agreement according to bug 1386406.

            select name ,sold_to_org_id , price_list_id
            into l_agreement_name,l_sold_to_org,l_price_list_id
            from oe_agreements_v
            where agreement_id = p_header_rec.agreement_id
            AND ROWNUM = 1;
            -- Commented out when importing CLOSED orders
            --
            -- AND trunc(nvl(p_header_rec.pricing_date,sysdate)) between
            -- trunc(nvl(START_DATE_ACTIVE,add_months(sysdate,-10000)))
            -- AND  trunc(nvl(END_DATE_ACTIVE,add_months(sysdate,+10000)));

            -- Geresh added
            IF l_price_list_id <> p_Header_rec.price_list_id
            THEN
              fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT_PLIST');
              fnd_message.set_Token
              ('AGREEMENT_NAME', l_agreement_name || sqlerrm);
              fnd_message.set_Token('PRICE_LIST1', p_Header_rec.price_list_id);
              fnd_message.set_Token('PRICE_LIST2', l_price_list_id);
              OE_MSG_PUB.Add;
              oe_debug_pub.add('Invalid Agreement +price_list_id combination',2);
              raise FND_API.G_EXC_ERROR;
            END IF;
          END IF;


        EXCEPTION
           WHEN NO_DATA_FOUND THEN
             fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT_PLIST');
             fnd_message.set_Token('AGREEMENT_NAME', l_agreement_name);
             fnd_message.set_Token('PRICE_LIST1', p_Header_rec.price_list_id);
             fnd_message.set_Token('PRICE_LIST2', l_price_list_id || sqlerrm);
             OE_MSG_PUB.Add;
             oe_debug_pub.add
             ('No Data Found Agreement+price_list_id combination',2);
             raise FND_API.G_EXC_ERROR;
        END;

       -- l_order_type_rec :=
       --  OE_Order_Cache.Load_Order_Type (p_header_rec.order_type_id);

    END IF;  --  Agreement is not null

    --  Ship to Org id depends on sold to org.

    oe_debug_pub.add('p_header_rec.ship_to_org_id' || p_header_rec.ship_to_org_id, 2);

    IF p_header_rec.ship_to_org_id IS NOT NULL
    THEN

      BEGIN
        oe_debug_pub.add
        ('ship_to_org_id :'||to_char(p_header_rec.ship_to_org_id),2);
        oe_debug_pub.add
        ('Customer Relation :'||lcustomer_relations,2);

    --lcustomer_relations := FND_PROFILE.VALUE('ONT_CUSTOMER_RELATIONSHIPS');

    IF nvl(lcustomer_relations,'N') = 'N' THEN
        oe_debug_pub.add
        ('Cr: No',2);

        SELECT 'VALID'
        INTO   l_dummy
        FROM   oe_ship_to_orgs_v
        WHERE  customer_id = p_header_rec.sold_to_org_id
        AND    site_use_id = p_header_rec.ship_to_org_id
        AND    ROWNUM = 1;
        --
        -- Commented out when importing CLOSED orders
        --
        -- AND    status = 'A';

   ELSIF lcustomer_relations = 'Y' THEN
        oe_debug_pub.add
        ('Cr: Yes',2);

    /*Select /*MOAC_SQL_NO_CHANGE 'VALID'
    Into   l_dummy
    From   oe_ship_to_orgs_v
    WHERE site_use_id = p_header_rec.ship_to_org_id
    AND
    customer_id in (
                    Select p_header_rec.sold_to_org_id from dual
                    union
                    select cust_account_id from
                    HZ_CUST_ACCT_RELATE
                    Where related_cust_account_id = p_header_rec.sold_to_org_id
/* added the following condition to fix the bug 2002486
                    and ship_to_flag = 'Y')*/

/* Replaced ra tables with HZ tables to fix the bug 1888440
    and rownum = 1;*/

    /* Replaced ra tables with HZ tables to fix the bug 1888440 */

    --bug 4729536
    OPEN cur_customer_relations;
    Fetch cur_customer_relations into l_dummy;
    Close cur_customer_relations;
    --bug 4729536

    -- Commented out when importing CLOSED orders
    --
    -- AND    status = 'A'

/* added the following ELSIF condition to fix the bug 2002486 */

    ELSIF nvl(lcustomer_relations,'N') = 'A' THEN
        oe_debug_pub.add
        ('Cr: A',2);

        SELECT 'VALID'
        INTO   l_dummy
        FROM   oe_ship_to_orgs_v
        WHERE  site_use_id = p_header_rec.ship_to_org_id
        AND    ROWNUM = 1;


        oe_debug_pub.add
        ('Cr: Yes- After the select',2);

   END IF;


        --  Valid Ship To Org Id.

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
        oe_debug_pub.add
        ('In: No data found',2);
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', OE_Order_Util.Get_Attribute_Name
                                             ('ship_to_org_id'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN

          IF OE_MSG_PUB.Check_Msg_Level
             (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            OE_MSG_PUB.Add_Exc_Msg
           (  G_PKG_NAME ,
              'Record - Ship To'
            );
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END;

    END IF; -- Ship To needed validation.

    --  Deliver to Org id depends on sold to org.
  oe_debug_pub.add('p_header_rec.deliver_to_org_id'||  to_char(p_header_rec.deliver_to_org_id),2);
    IF p_header_rec.deliver_to_org_id IS NOT NULL
    THEN

      BEGIN

      IF nvl(lcustomer_relations,'N') = 'N' THEN

        SELECT 'VALID'
        INTO   l_dummy
        FROM   oe_deliver_to_orgs_v
        WHERE  customer_id = p_header_rec.sold_to_org_id
        AND    site_use_id = p_header_rec.deliver_to_org_id
        AND    ROWNUM = 1;

      ELSIF lcustomer_relations = 'Y' THEN

        oe_debug_pub.add('Cr: Yes deliver',2);

        SELECT /* MOAC_SQL_CHANGE */ 'VALID'
         Into   l_dummy
         FROM   HZ_CUST_SITE_USES_ALL SITE,
	        HZ_CUST_ACCT_SITES ACCT_SITE
        WHERE SITE.SITE_USE_ID     = p_header_rec.deliver_to_org_id
         AND SITE.SITE_USE_CODE     ='DELIVER_TO'
         AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
         AND ACCT_SITE.CUST_ACCOUNT_ID in (
                    SELECT p_header_rec.sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE_ALL R WHERE
		    R.ORG_ID = ACCT_SITE.ORG_ID
                    AND R.RELATED_CUST_ACCOUNT_ID = p_header_rec.sold_to_org_id
			and R.ship_to_flag = 'Y')
         AND ROWNUM = 1;
        oe_debug_pub.add('Cr: Yes- After the select',2);

      ELSIF lcustomer_relations = 'A' THEN

        SELECT  'VALID'
         INTO    l_dummy
         FROM   HZ_CUST_SITE_USES SITE
        WHERE   SITE.SITE_USE_ID =p_header_rec.deliver_to_org_id;


      END IF;

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('deliver_to_org_id'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN

          IF OE_MSG_PUB.Check_Msg_Level
             (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN

            OE_MSG_PUB.Add_Exc_Msg
            (  G_PKG_NAME ,
               'Record - Deliver To'
            );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END;

    END IF; -- Deliver To needed validation.



    --  Invoice to Org id depends on sold to org.


    oe_debug_pub.add
        ('invoice_to_org_id :'||to_char(p_header_rec.invoice_to_org_id),2);

    IF p_header_rec.invoice_to_org_id IS NOT NULL
    THEN
      BEGIN
        oe_debug_pub.add
        ('invoice_to_org_id :'||to_char(p_header_rec.invoice_to_org_id),2);

	   IF nvl(lcustomer_relations,'N') = 'N' THEN

        Select 'VALID'
        Into   l_dummy
        From   oe_invoice_to_orgs_v
        Where  customer_id = p_header_rec.sold_to_org_id
        AND    site_use_id = p_header_rec.invoice_to_org_id;
    ELSIF lcustomer_relations = 'Y' THEN

    /*Select /*MOAC_SQL_NO_CHANGE 'VALID'
    Into   l_dummy
    From   oe_invoice_to_orgs_v
    WHERE site_use_id = p_header_rec.invoice_to_org_id
    AND
    customer_id in (
                    Select p_header_rec.sold_to_org_id from dual
                    union
                    select cust_account_id from
                    HZ_CUST_ACCT_RELATE where
                    related_cust_account_id = p_header_rec.sold_to_org_id
/* added the following condition to fix the bug 2002486
                    and bill_to_flag = 'Y')

    and rownum = 1;*/
    --bug 4729536
    OPEN cur_customer_relations_inv;
    Fetch cur_customer_relations_inv into l_dummy;
    Close cur_customer_relations_inv;
    --bug 4729536

/* Changed ra_customer_relationships to HZ Table to fix the bug 1888440 */

    --
    -- Commented out when importing CLOSED orders
    --
    -- AND    status = 'A' AND

/* added the following ELSIF condition to fix the bug 2002486 */

    ELSIF nvl(lcustomer_relations,'N') = 'A' THEN
        oe_debug_pub.add
        ('Cr: A',2);

        SELECT 'VALID'
        INTO   l_dummy
        From   oe_invoice_to_orgs_v
        WHERE  site_use_id = p_header_rec.invoice_to_org_id
        AND    ROWNUM = 1;


    END IF;


      EXCEPTION

      WHEN NO_DATA_FOUND THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_Util.Get_Attribute_Name('invoice_to_org_id'));
      OE_MSG_PUB.Add;

      WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          OE_MSG_PUB.Add_Exc_Msg
          (  G_PKG_NAME ,
            'Record - Invoice To'
          );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

    END IF; -- Invoice to org needed validation.

    --  Customer Location  depends on Sold To Org
  oe_debug_pub.add('p_header_rec.sold_to_site_use_id'||  to_char(p_header_rec.sold_to_site_use_id),2);
    IF p_header_rec.sold_to_site_use_id IS NOT NULL
    THEN

      BEGIN

        SELECT  /* MOAC_SQL_CHANGE */ 'VALID'
        INTO    l_dummy
        FROM
             HZ_CUST_SITE_USES_ALL   SITE,
             HZ_CUST_ACCT_SITES  ACCT_SITE
        WHERE
             SITE.SITE_USE_ID = p_header_rec.sold_to_site_use_id
             AND  SITE.SITE_USE_CODE = 'SOLD_TO'
             AND  SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
             AND  ACCT_SITE.CUST_ACCOUNT_ID = p_header_rec.sold_to_org_id;

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('SOLD_TO_SITE_USE_ID'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level
          ( OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            OE_MSG_PUB.Add_Exc_Msg
            (  G_PKG_NAME ,
              'Record - Customer Location'
             );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END; -- BEGIN

    END IF; --
    --  Sold to contact depends on Sold To Org
  oe_debug_pub.add('p_header_rec.sold_to_contact_id'||  to_char(p_header_rec.sold_to_contact_id),2);
    IF p_header_rec.sold_to_contact_id IS NOT NULL
    THEN

      BEGIN

        SELECT  'VALID'
        INTO  l_dummy
        FROM  HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
        WHERE  ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_header_rec.sold_to_contact_id
        AND   ACCT_ROLE.ROLE_TYPE = 'CONTACT'
        AND  ACCT_ROLE.CUST_ACCOUNT_ID = p_header_rec.sold_to_org_id
           AND  ROWNUM = 1;

/* Replaced ra_contacts with HZ Table to fix the bug 1888440 */

        --  Valid Sold To Contact

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('SOLD_TO_CONTACT_ID'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level
          ( OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            OE_MSG_PUB.Add_Exc_Msg
            (  G_PKG_NAME ,
              'Record - Sold To Contact'
             );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END; -- BEGIN

    END IF; -- Sold to contact needed validation.


    --  Invoice to contact depends on Invoice To Org
  oe_debug_pub.add('p_header_rec.invoice_to_contact_id'||  to_char(p_header_rec.invoice_to_contact_id),2);
    IF p_header_rec.invoice_to_contact_id IS NOT NULL
    THEN
      BEGIN
        oe_debug_pub.add
        ('inv_to_contact :'||to_char(p_header_rec.invoice_to_contact_id),2);

        SELECT  /* MOAC_SQL_CHANGE */ 'VALID'
        INTO    l_dummy
        FROM    HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
              ,  HZ_CUST_ACCT_SITES ACCT_SITE
              , HZ_CUST_SITE_USES_ALL INV
        WHERE   ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_header_rec.invoice_to_contact_id
        AND   ACCT_ROLE.CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID
        AND   ACCT_SITE.CUST_ACCT_SITE_ID = INV.CUST_ACCT_SITE_ID
        AND   INV.SITE_USE_ID = p_header_rec.invoice_to_org_id
        AND   ACCT_ROLE.ROLE_TYPE = 'CONTACT'
        AND   ROWNUM = 1;

/* Replaced ra_contacts , ra_addresses and ra_site_uses with HZ Tables , to fix the bug 1888440 */


      EXCEPTION

        WHEN NO_DATA_FOUND THEN

          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('INVOICE_TO_CONTACT_ID'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN

          IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN

            OE_MSG_PUB.Add_Exc_Msg
            (  G_PKG_NAME ,
              'Record - Invoice To Contact'
            );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END;

    END IF; -- Invoice to contact needed validation.


    --  Ship to contact depends on Ship To Org
  oe_debug_pub.add('p_header_rec.ship_to_contact_id'||  to_char(p_header_rec.ship_to_contact_id),2);
    IF p_header_rec.ship_to_contact_id IS NOT NULL
    THEN

      BEGIN

        SELECT  /* MOAC_SQL_CHANGE */ 'VALID'
        INTO    l_dummy
        FROM    HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
              ,  HZ_CUST_ACCT_SITES ACCT_SITE
              , HZ_CUST_SITE_USES_ALL SHIP
        WHERE   ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_header_rec.ship_to_contact_id
        AND   ACCT_ROLE.CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID
        AND   ACCT_SITE.CUST_ACCT_SITE_ID = SHIP.CUST_ACCT_SITE_ID
        AND   SHIP.SITE_USE_ID = p_header_rec.ship_to_org_id
        AND   ACCT_ROLE.ROLE_TYPE = 'CONTACT'
        AND   ROWNUM = 1;

/* Replace RA views with HZ views to fix the bug 1888440 */
        --
        -- Commented out when importing CLOSED orders
        --
        -- AND   SHIP.STATUS = 'A'

        --  Valid Ship To Contact

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('SHIP_TO_CONTACT_ID'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN

         IF OE_MSG_PUB.Check_Msg_Level
         (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN

           OE_MSG_PUB.Add_Exc_Msg
           (  G_PKG_NAME ,
             'Record - Ship To Contact'
           );
         END IF;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END; -- BEGIN

    END IF; -- Ship to contact needed validation.


    --  Deliver to contact depends on Deliver To Org
  oe_debug_pub.add('p_header_rec.deliver_to_contact_id' ||  to_char(p_header_rec.deliver_to_contact_id),2);
    IF p_header_rec.deliver_to_contact_id IS NOT NULL
    THEN

      BEGIN

        SELECT  /* MOAC_SQL_CHANGE */ 'VALID'
        INTO    l_dummy
        FROM  HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
              ,  HZ_CUST_ACCT_SITES ACCT_SITE
              , HZ_CUST_SITE_USES_ALL DELIVER
        WHERE   ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_header_rec.deliver_to_contact_id
        AND   ACCT_ROLE.CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID
        AND   ACCT_SITE.CUST_ACCT_SITE_ID = DELIVER.CUST_ACCT_SITE_ID
        AND   DELIVER.SITE_USE_ID = p_header_rec.deliver_to_org_id
        AND   ACCT_ROLE.ROLE_TYPE = 'CONTACT'
        AND   ROWNUM = 1;

/* Replaced ra_contacts , ra_addresses and ra_site_uses with HZ Tables , to fix the bug 1888440 */


        --  Valid Deliver To Org.

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('DELIVER_TO_CONTACT_ID'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN

          IF OE_MSG_PUB.Check_Msg_Level (
          OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            OE_MSG_PUB.Add_Exc_Msg
            (  G_PKG_NAME ,
              'Record - Deliver To Contact'
             );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END; -- BEGIN

    END IF; -- Deliver to contact needed validation.


    --  Check for Tax Exempt number/Tax exempt reason code IF the Tax exempt
    --    flag is 'S' (StANDard).
  oe_debug_pub.add('p_header_rec.tax_exempt_number'|| p_header_rec.tax_exempt_number,2);
  oe_debug_pub.add('p_header_rec.tax_exempt_flag'||  p_header_rec.tax_exempt_flag,2);
    IF p_header_rec.tax_exempt_flag IS NOT NULL
    THEN

      BEGIN

        IF p_header_rec.tax_exempt_flag = 'S' AND
           p_header_rec.tax_exempt_number IS NOT NULL AND
           p_header_rec.tax_exempt_reason_code IS NOT NULL
        THEN
          -- eBTax changes
        /*SELECT 'VALID'
          INTO l_dummy
          FROM OE_TAX_EXEMPTIONS_QP_V
          WHERE TAX_EXEMPT_NUMBER = p_header_rec.tax_exempt_number
          AND TAX_EXEMPT_REASON_CODE=p_header_rec.tax_exempt_reason_code
          AND SHIP_TO_ORG_ID = nvl(p_header_rec.ship_to_org_id,
                                   p_header_rec.invoice_to_org_id)
          AND BILL_TO_CUSTOMER_ID = p_header_rec.sold_to_org_id
          AND ROWNUM = 1;

          -- Commented out when importing CLOSED orders ?
          -- AND STATUS_CODE = 'PRIMARY'
          -- AND TRUNC(NVL(p_header_rec.request_date,sysdate)) BETWEEN
          -- TRUNC(START_DATE) AND
          -- TRUNC(NVL(END_DATE,NVL(p_header_rec.request_date,sysdate)))
         */

          open partyinfo(p_header_rec.invoice_to_org_id);
          fetch partyinfo into l_bill_to_cust_Acct_id,
                               l_bill_to_party_id,
                               l_bill_to_party_site_id,
                               l_org_id;
          close partyinfo;

          if p_header_rec.ship_to_org_id = p_header_rec.invoice_to_org_id then
             l_ship_to_cust_Acct_id    :=  l_bill_to_cust_Acct_id;
             l_ship_to_party_id        :=  l_bill_to_party_id;
             l_ship_to_party_site_id   :=  l_bill_to_party_site_id ;
          else
             open partyinfo(p_header_rec.ship_to_org_id);
             fetch partyinfo into l_ship_to_cust_Acct_id,
                               l_ship_to_party_id,
                               l_ship_to_party_site_id,
                               l_org_id;
             close partyinfo;
          end if;


           SELECT 'VALID'
             INTO l_dummy
             FROM ZX_EXEMPTIONS_V
            WHERE EXEMPT_CERTIFICATE_NUMBER = p_header_rec.tax_exempt_number
              AND EXEMPT_REASON_CODE = p_header_rec.tax_exempt_reason_code
              AND nvl(site_use_id,nvl(p_header_rec.ship_to_org_id,
                                    p_header_rec.invoice_to_org_id))
                  =  nvl(p_header_rec.ship_to_org_id,
                                    p_header_rec.invoice_to_org_id)
              AND nvl(cust_account_id, l_bill_to_cust_acct_id) = l_bill_to_cust_acct_id
              AND nvl(PARTY_SITE_ID,nvl(l_ship_to_party_site_id, l_bill_to_party_site_id))=
                                nvl(l_ship_to_party_site_id, l_bill_to_party_site_id)
              AND  org_id = l_org_id
              AND  party_id = l_bill_to_party_id
     --       AND nvl(LEGAL_ENTITY_ID,-99) IN (nvl(l_legal_entity_id, legal_entity_id), -99)
              AND EXEMPTION_STATUS_CODE = 'PRIMARY'
     --         AND TRUNC(NVL(p_header_rec.request_date,sysdate))
     --               BETWEEN TRUNC(EFFECTIVE_FROM)
     --                       AND TRUNC(NVL(EFFECTIVE_TO,NVL(p_header_rec.request_date,sysdate)))
              AND ROWNUM = 1;

        END IF;

        --  Valid Tax Exempt Number.

      EXCEPTION

        WHEN NO_DATA_FOUND THEN

          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('TAX_EXEMPT_NUMBER'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN

          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN

            OE_MSG_PUB.Add_Exc_Msg
            (  G_PKG_NAME ,
              'Record - Tax Exempt Number'
            );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END; -- BEGIN

    END IF; -- Tax exempton info validation.


    -- Fix bug 1162304: issue a warning message if the PO number
    -- is being referenced by another order
    IF p_header_rec.cust_po_number IS NOT NULL
    THEN

      IF OE_CNCL_Validate_Header.Is_Duplicate_PO_Number
           (p_header_rec.cust_po_number
           ,p_header_rec.sold_to_org_id
           ,p_header_rec.header_id )
      THEN
          FND_MESSAGE.SET_NAME('ONT','OE_VAL_DUP_PO_NUMBER');
          OE_MSG_PUB.ADD;
      END IF;

    END IF;
    -- End of check for duplicate PO number


    --  Done validating entity
    x_return_status := l_return_status;

    oe_debug_pub.add('Exit OE_CNCL_VALIDATE_HEADER.ENTITY',1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Entity'
         );
      END IF;

END Entity;



/*-------------------------------------------------------
PROCEDURE:    Attributes
Description:
--------------------------------------------------------*/

PROCEDURE Attributes
(   x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_x_header_rec       IN  OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
)
IS
BEGIN

    oe_debug_pub.add('Entering OE_CNCL_VALIDATE_HEADER.ATTRIBUTES',1);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --  validate Sales agreements Attributes
    IF  p_x_header_rec.Blanket_number IS NOT NULL
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        fnd_message.set_name('ONT', 'OE_BLKT_DISALLOW_CLOSE_REL');
        OE_MSG_PUB.add;
    END IF;


    --  Validate header attributes

    IF  p_x_header_rec.accounting_rule_id IS NOT NULL
    THEN

      IF NOT OE_CNCL_Validate.Accounting_Rule(p_x_header_rec.accounting_rule_id)
      THEN

        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
             --
             p_x_header_rec.accounting_rule_id := NULL;
             --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
             --
             p_x_header_rec.accounting_rule_id := FND_API.G_MISS_NUM;
             --
        ELSE
             --
             x_return_status := FND_API.G_RET_STS_ERROR;
             --
        END IF;

      END IF;

    END IF;

    IF  p_x_header_rec.agreement_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Agreement(p_x_header_rec.agreement_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.agreement_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.agreement_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    IF  p_x_header_rec.booked_flag IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Booked(p_x_header_rec.booked_flag) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.booked_flag := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.booked_flag := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    IF  p_x_header_rec.cancelled_flag IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Cancelled(p_x_header_rec.cancelled_flag) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.cancelled_flag := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.cancelled_flag := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    IF p_x_header_rec.conversion_type_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Conversion_Type(p_x_header_rec.conversion_type_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.conversion_type_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.conversion_type_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    IF  p_x_header_rec.deliver_to_contact_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Deliver_To_Contact(p_x_header_rec.deliver_to_contact_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.deliver_to_contact_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.deliver_to_contact_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.deliver_to_org_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Deliver_To_Org(p_x_header_rec.deliver_to_org_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.deliver_to_org_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.deliver_to_org_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.demand_class_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Demand_Class(p_x_header_rec.demand_class_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.demAND_class_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.demAND_class_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.fob_point_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Fob_Point(p_x_header_rec.fob_point_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.fob_point_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.fob_point_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.freight_terms_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Freight_Terms(p_x_header_rec.freight_terms_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.freight_terms_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.freight_terms_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.invoice_to_contact_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Invoice_To_Contact(p_x_header_rec.invoice_to_contact_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.invoice_to_contact_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.invoice_to_contact_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.invoice_to_org_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Invoice_To_Org(p_x_header_rec.invoice_to_org_id) THEN
       --
       IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.invoice_to_org_id := NULL;
          --
       ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.invoice_to_org_id := FND_API.G_MISS_NUM;
          --
       ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
       END IF;
       --
     END IF;
     --
    END IF;
    --

    --
    IF  p_x_header_rec.invoicing_rule_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Invoicing_Rule(p_x_header_rec.invoicing_rule_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.invoicing_rule_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.invoicing_rule_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.open_flag IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Open(p_x_header_rec.open_flag) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.open_flag := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.open_flag := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.order_date_type_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Order_Date_Type_Code(p_x_header_rec.order_date_type_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.order_date_type_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.order_date_type_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.order_type_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Order_Type(p_x_header_rec.order_type_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.order_type_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.order_type_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.payment_term_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Payment_Term(p_x_header_rec.payment_term_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.payment_term_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.payment_term_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

--{added for bug 4240715

       IF  p_x_header_rec.Ib_owner  IS NOT NULL THEN

        IF NOT OE_CNCL_Validate.IB_OWNER (p_x_header_rec.Ib_owner)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL  THEN

              p_x_header_rec.Ib_owner := NULL;

           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
           THEN
              p_x_header_rec.Ib_owner := FND_API.G_MISS_CHAR;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

  IF  p_x_header_rec.Ib_installed_at_location  IS NOT NULL
   THEN

        IF NOT OE_CNCL_Validate.IB_INSTALLED_AT_LOCATION (p_x_header_rec.Ib_installed_at_location)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL
           THEN
              p_x_header_rec.Ib_installed_at_location := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
           THEN
              p_x_header_rec.Ib_installed_at_location := FND_API.G_MISS_CHAR;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

   IF  p_x_header_rec.Ib_current_location  IS NOT NULL
               THEN

        IF NOT OE_CNCL_Validate.IB_CURRENT_LOCATION (p_x_header_rec.Ib_current_location)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL
            THEN
              p_x_header_rec.Ib_current_location := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
                    THEN
              p_x_header_rec.Ib_current_location := FND_API.G_MISS_CHAR;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

   IF  p_x_header_rec.End_customer_id  IS NOT NULL  THEN

        IF NOT OE_CNCL_Validate.END_CUSTOMER (p_x_header_rec.End_customer_id)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL

           THEN
              p_x_header_rec.End_customer_id := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
           THEN
              p_x_header_rec.End_customer_id := FND_API.G_MISS_NUM;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

   IF  p_x_header_rec.End_customer_contact_id  IS NOT NULL
     THEN
        IF NOT OE_CNCL_Validate.END_CUSTOMER_CONTACT (p_x_header_rec.End_customer_contact_id)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL
           THEN
              p_x_header_rec.End_customer_contact_id := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
           THEN
              p_x_header_rec.End_customer_contact_id := FND_API.G_MISS_NUM;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

  IF  p_x_header_rec.End_customer_site_use_id  IS NOT NULL
 THEN

        IF NOT OE_CNCL_Validate.END_CUSTOMER_SITE_USE (p_x_header_rec.End_customer_site_use_id)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL
              THEN
              p_x_header_rec.End_customer_site_use_id := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF
                    THEN
              p_x_header_rec.End_customer_site_use_id := FND_API.G_MISS_NUM;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

	--bug 4240715}

    --
    IF  p_x_header_rec.price_list_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Price_List(p_x_header_rec.price_list_id) THEN
        --
        p_x_header_rec.price_list_id := NULL;
        --
      ELSE
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.shipment_priority_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Shipment_Priority(p_x_header_rec.shipment_priority_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.shipment_priority_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.shipment_priority_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.shipping_method_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Shipping_Method(p_x_header_rec.shipping_method_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.shipping_method_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.shipping_method_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.ship_from_org_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Ship_From_Org(p_x_header_rec.ship_from_org_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.ship_from_org_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.ship_from_org_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.ship_to_contact_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Ship_To_Contact(p_x_header_rec.ship_to_contact_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.ship_to_contact_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.ship_to_contact_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.ship_to_org_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Ship_To_Org(p_x_header_rec.ship_to_org_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.ship_to_org_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.ship_to_org_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.sold_to_contact_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Sold_To_Contact(p_x_header_rec.sold_to_contact_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.sold_to_contact_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.sold_to_contact_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --


    IF  p_x_header_rec.sold_to_org_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Sold_To_Org(p_x_header_rec.sold_to_org_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.sold_to_org_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.sold_to_org_id := FND_API.G_MISS_NUM;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.source_document_type_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Source_Document_Type
                           (p_x_header_rec.source_document_type_id) THEN
          --
          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
            --
            p_x_header_rec.source_document_type_id := NULL;
            --
          ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
            --
            p_x_header_rec.source_document_type_id := FND_API.G_MISS_NUM;
            --
          ELSE
            --
            x_return_status := FND_API.G_RET_STS_ERROR;
            --
          END IF;
          --
        END IF;
        --
    END IF;
    --

    --
    IF  p_x_header_rec.tax_exempt_flag IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Tax_Exempt(p_x_header_rec.tax_exempt_flag) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.tax_exempt_flag := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.tax_exempt_flag := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.tax_exempt_reason_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Tax_Exempt_Reason
                         (p_x_header_rec.tax_exempt_reason_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.tax_exempt_reason_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.tax_point_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Tax_Point(p_x_header_rec.tax_point_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.tax_point_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.tax_point_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.transactional_curr_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Transactional_Curr
                         (p_x_header_rec.transactional_curr_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.transactional_curr_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.transactional_curr_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.payment_type_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Payment_Type(p_x_header_rec.payment_type_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.payment_type_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.payment_type_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.credit_card_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Credit_Card(p_x_header_rec.credit_card_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.credit_card_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.credit_card_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.flow_status_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Flow_Status(p_x_header_rec.flow_status_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.flow_status_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.flow_status_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.attribute1 IS NOT NULL
    OR  p_x_header_rec.attribute10 IS NOT NULL
    OR  p_x_header_rec.attribute11 IS NOT NULL
    OR  p_x_header_rec.attribute12 IS NOT NULL
    OR  p_x_header_rec.attribute13 IS NOT NULL
    OR  p_x_header_rec.attribute14 IS NOT NULL
    OR  p_x_header_rec.attribute15 IS NOT NULL
    OR  p_x_header_rec.attribute16 IS NOT NULL   --For bug 2184255
    OR  p_x_header_rec.attribute17 IS NOT NULL
    OR  p_x_header_rec.attribute18 IS NOT NULL
    OR  p_x_header_rec.attribute19 IS NOT NULL
    OR  p_x_header_rec.attribute2 IS NOT NULL
    OR  p_x_header_rec.attribute20 IS NOT NULL
    OR  p_x_header_rec.attribute3 IS NOT NULL
    OR  p_x_header_rec.attribute4 IS NOT NULL
    OR  p_x_header_rec.attribute5 IS NOT NULL
    OR  p_x_header_rec.attribute6 IS NOT NULL
    OR  p_x_header_rec.attribute7 IS NOT NULL
    OR  p_x_header_rec.attribute8 IS NOT NULL
    OR  p_x_header_rec.attribute9 IS NOT NULL
    OR  p_x_header_rec.context IS NOT NULL
    THEN
         --
         oe_debug_pub.add('Before calling header_desc_flex',2);
         IF NOT OE_CNCL_VALIDATE.Header_Desc_Flex
          (p_context            => p_x_header_rec.context
          ,p_attribute1         => p_x_header_rec.attribute1
          ,p_attribute2         => p_x_header_rec.attribute2
          ,p_attribute3         => p_x_header_rec.attribute3
          ,p_attribute4         => p_x_header_rec.attribute4
          ,p_attribute5         => p_x_header_rec.attribute5
          ,p_attribute6         => p_x_header_rec.attribute6
          ,p_attribute7         => p_x_header_rec.attribute7
          ,p_attribute8         => p_x_header_rec.attribute8
          ,p_attribute9         => p_x_header_rec.attribute9
          ,p_attribute10        => p_x_header_rec.attribute10
          ,p_attribute11        => p_x_header_rec.attribute11
          ,p_attribute12        => p_x_header_rec.attribute12
          ,p_attribute13        => p_x_header_rec.attribute13
          ,p_attribute14        => p_x_header_rec.attribute14
          ,p_attribute15        => p_x_header_rec.attribute15
          ,p_attribute16        => p_x_header_rec.attribute16  -- for bug 2184255
          ,p_attribute17        => p_x_header_rec.attribute17
          ,p_attribute18        => p_x_header_rec.attribute18
          ,p_attribute19        => p_x_header_rec.attribute19
          ,p_attribute20        => p_x_header_rec.attribute20)
          THEN

            --
            IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
                --
                p_x_header_rec.context    := null;
                p_x_header_rec.attribute1 := null;
                p_x_header_rec.attribute2 := null;
                p_x_header_rec.attribute3 := null;
                p_x_header_rec.attribute4 := null;
                p_x_header_rec.attribute5 := null;
                p_x_header_rec.attribute6 := null;
                p_x_header_rec.attribute7 := null;
                p_x_header_rec.attribute8 := null;
                p_x_header_rec.attribute9 := null;
                p_x_header_rec.attribute10 := null;
                p_x_header_rec.attribute11 := null;
                p_x_header_rec.attribute12 := null;
                p_x_header_rec.attribute13 := null;
                p_x_header_rec.attribute14 := null;
                p_x_header_rec.attribute15 := null;
                p_x_header_rec.attribute16 := null;  -- for bug 2184255
                p_x_header_rec.attribute17 := null;
                p_x_header_rec.attribute18 := null;
                p_x_header_rec.attribute19 := null;
                p_x_header_rec.attribute20 := null;
                --
            ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
                --
                p_x_header_rec.context    := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute1 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute2 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute3 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute4 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute5 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute6 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute7 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute8 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute9 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute10 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute11 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute12 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute13 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute14 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute15 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute16 := FND_API.G_MISS_CHAR;  -- for bug 2184255
                p_x_header_rec.attribute17 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute18 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute19 := FND_API.G_MISS_CHAR;
                p_x_header_rec.attribute20 := FND_API.G_MISS_CHAR;
                --
            ELSE
                --
                x_return_status := FND_API.G_RET_STS_ERROR;
                --
            END IF;
            --
        END IF;
        --
    END IF;
    --
    oe_debug_pub.add('After header_desc_flex  ' || x_return_status,2);
    --
    IF  p_x_header_rec.global_attribute1 IS NOT NULL
    OR  p_x_header_rec.global_attribute10 IS NOT NULL
    OR  p_x_header_rec.global_attribute11 IS NOT NULL
    OR  p_x_header_rec.global_attribute12 IS NOT NULL
    OR  p_x_header_rec.global_attribute13 IS NOT NULL
    OR  p_x_header_rec.global_attribute14 IS NOT NULL
    OR  p_x_header_rec.global_attribute15 IS NOT NULL
    OR  p_x_header_rec.global_attribute16 IS NOT NULL
    OR  p_x_header_rec.global_attribute17 IS NOT NULL
    OR  p_x_header_rec.global_attribute18 IS NOT NULL
    OR  p_x_header_rec.global_attribute19 IS NOT NULL
    OR  p_x_header_rec.global_attribute2 IS NOT NULL
    OR  p_x_header_rec.global_attribute20 IS NOT NULL
    OR  p_x_header_rec.global_attribute3 IS NOT NULL
    OR  p_x_header_rec.global_attribute4 IS NOT NULL
    OR  p_x_header_rec.global_attribute5 IS NOT NULL
    OR  p_x_header_rec.global_attribute6 IS NOT NULL
    OR  p_x_header_rec.global_attribute7 IS NOT NULL
    OR  p_x_header_rec.global_attribute8 IS NOT NULL
    OR  p_x_header_rec.global_attribute9 IS NOT NULL
    OR  p_x_header_rec.global_attribute_category IS NOT NULL
    THEN

          --
          OE_DEBUG_PUB.ADD('Before G_header_desc_flex',2);
          IF NOT OE_CNCL_VALIDATE.G_Header_Desc_Flex
          (p_context            => p_x_header_rec.global_attribute_category
          ,p_attribute1         => p_x_header_rec.global_attribute1
          ,p_attribute2         => p_x_header_rec.global_attribute2
          ,p_attribute3         => p_x_header_rec.global_attribute3
          ,p_attribute4         => p_x_header_rec.global_attribute4
          ,p_attribute5         => p_x_header_rec.global_attribute5
          ,p_attribute6         => p_x_header_rec.global_attribute6
          ,p_attribute7         => p_x_header_rec.global_attribute7
          ,p_attribute8         => p_x_header_rec.global_attribute8
          ,p_attribute9         => p_x_header_rec.global_attribute9
          ,p_attribute10        => p_x_header_rec.global_attribute10
          ,p_attribute11        => p_x_header_rec.global_attribute11
          ,p_attribute12        => p_x_header_rec.global_attribute12
          ,p_attribute13        => p_x_header_rec.global_attribute13
          ,p_attribute14        => p_x_header_rec.global_attribute13
          ,p_attribute15        => p_x_header_rec.global_attribute14
          ,p_attribute16        => p_x_header_rec.global_attribute16
          ,p_attribute17        => p_x_header_rec.global_attribute17
          ,p_attribute18        => p_x_header_rec.global_attribute18
          ,p_attribute19        => p_x_header_rec.global_attribute19
          ,p_attribute20        => p_x_header_rec.global_attribute20)
          THEN
            --
            IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
                --
                p_x_header_rec.global_attribute_category    := null;
                p_x_header_rec.global_attribute1 := null;
                p_x_header_rec.global_attribute2 := null;
                p_x_header_rec.global_attribute3 := null;
                p_x_header_rec.global_attribute4 := null;
                p_x_header_rec.global_attribute5 := null;
                p_x_header_rec.global_attribute6 := null;
                p_x_header_rec.global_attribute7 := null;
                p_x_header_rec.global_attribute8 := null;
                p_x_header_rec.global_attribute9 := null;
                p_x_header_rec.global_attribute11 := null;
                p_x_header_rec.global_attribute12 := null;
                p_x_header_rec.global_attribute13 := null;
                p_x_header_rec.global_attribute14 := null;
                p_x_header_rec.global_attribute15 := null;
                p_x_header_rec.global_attribute16 := null;
                p_x_header_rec.global_attribute17 := null;
                p_x_header_rec.global_attribute18 := null;
                p_x_header_rec.global_attribute19 := null;
                p_x_header_rec.global_attribute20 := null;
                --
            ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
                --
                p_x_header_rec.global_attribute_category
                                               := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute1 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute2 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute3 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute4 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute5 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute6 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute7 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute8 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute9 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute11 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute12 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute13 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute14 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute15 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute16 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute17 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute18 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute19 := FND_API.G_MISS_CHAR;
                p_x_header_rec.global_attribute20 := FND_API.G_MISS_CHAR;
                --
            ELSE
                --
                x_return_status := FND_API.G_RET_STS_ERROR;
                --
            END IF;
            --
         END IF;
         --
   END IF;
   --

    --
    OE_DEBUG_PUB.ADD('After G_header_desc_flex ' || x_return_status,2);
    --  Done validating attributes

    -- Salesrep_id
    IF  p_x_header_rec.salesrep_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.salesrep(p_x_header_rec.salesrep_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
           --
           p_x_header_rec.salesrep_id := NULL;
           --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
           --
           p_x_header_rec.salesrep_id := FND_API.G_MISS_NUM;
           --
        ELSE
           --
           x_return_status := FND_API.G_RET_STS_ERROR;
           --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    --
    IF  p_x_header_rec.sales_channel_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.sales_channel(p_x_header_rec.sales_channel_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
           --
           p_x_header_rec.sales_channel_code := NULL;
           --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
           --
           p_x_header_rec.sales_channel_code := FND_API.G_MISS_NUM;
           --
        ELSE
           --
           x_return_status := FND_API.G_RET_STS_ERROR;
           --
        END IF;
        --
      END IF;
      --
    END IF;
    --


    -- Return_reason_code
    --
    IF  p_x_header_rec.return_reason_code IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.return_reason(p_x_header_rec.return_reason_code) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.return_reason_code := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.return_reason_code := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --

    -- Customer_Location
    --
    IF  p_x_header_rec.sold_to_site_use_id IS NOT NULL THEN
      --
      IF NOT OE_CNCL_Validate.Customer_Location(p_x_header_rec.sold_to_site_use_id) THEN
        --
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL THEN
          --
          p_x_header_rec.sold_to_site_use_id := NULL;
          --
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF THEN
          --
          p_x_header_rec.sold_to_site_use_id := FND_API.G_MISS_CHAR;
          --
        ELSE
          --
          x_return_status := FND_API.G_RET_STS_ERROR;
          --
        END IF;
        --
      END IF;
      --
    END IF;
    --
    oe_debug_pub.add('Exiting OE_CNCL_VALIDATE_HEADER.ATTRIBUTES',1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        OE_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
           ,'Attributes'
         );
      END IF;

END Attributes;



END OE_CNCL_Validate_Header;

/
