--------------------------------------------------------
--  DDL for Package Body OE_VALIDATE_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_VALIDATE_HEADER" AS
/* $Header: OEXLHDRB.pls 120.20.12010000.5 2010/03/02 15:16:30 amimukhe ship $ */

--  Global constant holding the package name

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_Validate_Header';


/* LOCAL PROCEDURES */

-- QUOTING changes
/*-------------------------------------------------------
PROCEDURE:    Check_Negotiation_Attributes
Description:  This procedures validates the order attributes
              against transaction phase (Negotiation vs Fulfillment).
--------------------------------------------------------*/

PROCEDURE Check_Negotiation_Attributes
( p_header_rec            IN OE_Order_PUB.Header_Rec_Type
, p_old_header_rec        IN OE_Order_PUB.Header_Rec_Type
, x_return_status         IN OUT NOCOPY VARCHAR2
)
IS
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    if l_debug_level > 0 then
       oe_debug_pub.add('Enter OE_VALIDATE_HEADER.Check_Negotiation_Attributes',1);
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    IF p_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

       -- Transaction phase cannot be updated on a saved transaction.

       IF OE_Quote_Util.G_COMPLETE_NEG = 'N' AND
          NOT OE_GLOBALS.EQUAL(p_header_rec.transaction_phase_code
                                ,p_old_header_rec.transaction_phase_code)
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_PHASE_UPDATE_NOT_ALLOWED');
          OE_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- New version number cannot be lower than previous version

       IF nvl(p_header_rec.version_number,-1) < p_old_header_rec.version_number
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_VERSION_NUM_ERROR');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF; -- End of check for UPDATE operation


    -- Start checks specific to the transaction phase

    IF nvl(p_header_rec.transaction_phase_code,'F') = 'F' THEN

       -- Cannot update following quote attributes in fulfillment phase

       IF (NOT OE_GLOBALS.EQUAL(p_header_rec.quote_number
                         ,p_old_header_rec.quote_number)) OR
          (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
           p_header_rec.quote_number IS NOT NULL )
          --OR cnd added for Bug 5060064
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_QUOTE_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              OE_Order_UTIL.Get_Attribute_Name('QUOTE_NUMBER'));
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF (NOT OE_GLOBALS.EQUAL(p_header_rec.quote_date
                         ,p_old_header_rec.quote_date)) OR
          (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
           p_header_rec.quote_date IS NOT NULL )
          --OR cnd added for Bug 5060064
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_QUOTE_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              OE_Order_UTIL.Get_Attribute_Name('QUOTE_DATE'));
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF (NOT OE_GLOBALS.EQUAL(p_header_rec.expiration_date
                         ,p_old_header_rec.expiration_date)) OR
          (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
           p_header_rec.expiration_date IS NOT NULL )
          --OR cnd added for Bug 5060064
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_QUOTE_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              OE_Order_UTIL.Get_Attribute_Name('EXPIRATION_DATE'));
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- Bug 3189579
       -- Sales document name is supported on both sales orders and
       -- quoted orders. Check is not needed here.

    -- Checks if order is in negotiation phase

    ELSIF p_header_rec.transaction_phase_code = 'N' THEN

       -- Cannot update following order attributes in negotiation phase

       IF (NOT OE_GLOBALS.EQUAL(p_header_rec.order_number
                         ,p_old_header_rec.order_number)) OR
          (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
           p_header_rec.order_number IS NOT NULL )
          --OR cnd added for Bug 5060064
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              OE_Order_UTIL.Get_Attribute_Name('ORDER_NUMBER'));
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       IF (NOT OE_GLOBALS.EQUAL(p_header_rec.ordered_date
                         ,p_old_header_rec.ordered_date))  OR
          (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE AND
           p_header_rec.ordered_date IS NOT NULL )
          --OR cnd added for Bug 5060064
       THEN
          FND_MESSAGE.SET_NAME('ONT','OE_CANT_UPDATE_ORDER_ATTR');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
              OE_Order_UTIL.Get_Attribute_Name('ORDERED_DATE'));
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- Return orders not supported
       IF p_header_rec.order_category_code = 'RETURN' THEN
          FND_MESSAGE.SET_NAME('ONT','OE_QUOTE_RETURN_NOT_SUPP');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- Internal sales orders not allowed
       IF p_header_rec.order_source_id = 10 THEN
          FND_MESSAGE.SET_NAME('ONT','OE_QUOTE_INT_ORD_NOT_SUPP');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

       -- Cancellation operation not supported for quotes
       IF p_header_rec.cancelled_flag = 'Y' THEN
          FND_MESSAGE.SET_NAME('ONT','OE_QUOTE_CANCEL_NOT_SUPP');
          OE_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF; -- End of check if phase = F/N

    oe_debug_pub.add('Exiting OE_VALIDATE_HEADER.Check_Negotiation_Attributes',1);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (  G_PKG_NAME ,
        'Check_Negotiation_Attributes'
      );
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Check_Negotiation_Attributes;

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

    oe_debug_pub.add('Enter OE_VALIDATE_HEADER.CHECK_BOOK_REQD',1);

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

--key transaction dates
   IF (OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' and p_header_rec.order_firmed_date > p_header_rec.booked_date) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('ONT','ONT_ORDER_FIRMED_DATE_INVALID');
       OE_MSG_PUB.ADD;
   END IF;
--end

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

    IF    OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED = FALSE
    AND   p_header_rec.payment_type_code <> 'CREDIT_CARD'
    AND   p_header_rec.payment_amount IS NULL
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

    oe_debug_pub.add('Exiting OE_VALIDATE_HEADER.CHECK_BOOK_REQD',1);
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



/*-------------------------------------------------------
PROCEDURE:   Validate_Order_Type
Description:
--------------------------------------------------------*/

Procedure Validate_Order_Type(p_order_type_id     IN NUMBER,
                              p_old_order_type_id IN NUMBER,
                              p_header_id         IN NUMBER,
                              p_operation         IN VARCHAR2)
IS
lexists      varchar2(30);
lprocessname varchar2(80);
BEGIN

  oe_debug_pub.add('Entering OE_VALIDATE_HEADER.Validate_Order_Type',1);
  IF p_operation = OE_GLOBALS.G_OPR_UPDATE
  THEN
    IF NOT OE_GLOBALS.EQUAL(p_order_type_id
                           ,p_old_Order_type_id)
    THEN
      SELECT root_activity
      into   lprocessname
      from   wf_items_v
      where  item_key = to_char(p_header_id)
      AND    item_type = 'OEOH'
      AND rownum = 1;

      SELECT 'EXISTS'
      INTO   lexists
      FROM   oe_workflow_assignments a
      WHERE  a.order_type_id = p_order_type_id
      AND    a.process_name = lprocessname
      AND    a.line_type_id IS NULL
      AND    a.end_date_active is null
      AND    rownum = 1;
    END IF;
  END IF;

   oe_debug_pub.add('Exiting OE_VALIDATE_HEADER.Validate_Order_Type',1);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('ONT','OE_FLOW_CNT_CHANGE');
    OE_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME ,
        'Validate_Order_Type'
      );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Order_type;

-- bug 1618229.
-- Procedure to validate if the currency matches the currency for
-- the commitment on order line if there is any.
Procedure Validate_Commitment_Currency(p_header_id 		 IN NUMBER
                                      ,p_transactional_curr_code IN VARCHAR2
                                      ,x_return_status		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

l_commitment_id		NUMBER;
L_COMMITMENT_CURR_CODE	VARCHAR2(15);

CURSOR l_line_csr IS
SELECT commitment_id
FROM   oe_order_lines
WHERE  header_id = p_header_id
AND    commitment_id is not null;

BEGIN

  oe_debug_pub.add('Entering OE_VALIDATE_HEADER.Validate_Commitment_Currency',1);
  OPEN l_line_csr;
  LOOP
    FETCH l_line_csr INTO l_commitment_id;
    EXIT WHEN l_line_csr%NOTFOUND;

    -- get the currency code associated with the commitment.
    IF l_commitment_id IS NOT NULL THEN
      BEGIN
        SELECT invoice_currency_code
        INTO   l_commitment_curr_code
        FROM   ra_customer_trx
        WHERE  customer_trx_id = l_commitment_id;

      EXCEPTION WHEN NO_DATA_FOUND THEN
        null;
      END;

      oe_debug_pub.add('OEXLHDRB: commitment currency is: '||l_commitment_curr_code, 3);
      oe_debug_pub.add('OEXLHDRB: order currency is: '||p_transactional_curr_code, 3);

      IF NOT OE_GLOBALS.EQUAL(l_commitment_curr_code, p_transactional_curr_code) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        EXIT;
      END IF;
    END IF;

  END LOOP;
  CLOSE l_line_csr;

  oe_debug_pub.add('Exiting OE_VALIDATE_HEADER.Validate_Commitment_Currency',1);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('ONT','OE_FLOW_CNT_CHANGE');
    OE_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME ,
        'Validate_Commitment_Currency'
      );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Commitment_Currency;

-- bug 1618229.
-- Procedure to validate if the the customer on order header matches
-- the customer for the commitment on order line if there is any.
Procedure Validate_Commitment_Customer(p_header_id 		 IN NUMBER
                                      ,p_sold_to_org_id		 IN NUMBER
                                      ,x_return_status		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS

l_commitment_id		NUMBER;
l_exists		VARCHAR2(1) := 'N';

CURSOR l_line_csr IS
SELECT commitment_id
FROM   oe_order_lines
WHERE  header_id = p_header_id
AND    commitment_id is not null;

Cursor cur_customer_relations (p_commitment_id IN NUMBER) is
	select 'Y'
	from ra_customer_trx ratrx
	where ratrx.customer_trx_id = p_commitment_id
	and ratrx.bill_to_customer_id = p_sold_to_org_id

	union all

	select 'Y'
	from ra_customer_trx ratrx
	where ratrx.customer_trx_id = p_commitment_id
	and exists (SELECT 1
                   FROM   hz_cust_acct_relate_all hcar
                   WHERE  hcar.cust_account_id = ratrx.bill_to_customer_id
		   and    hcar.related_cust_account_id = p_sold_to_org_id
                   AND    hcar.status = 'A'
		   and    hcar.org_id = ratrx.org_id
                   AND    hcar.bill_to_flag = 'Y');

BEGIN

  oe_debug_pub.add('Entering OE_VALIDATE_HEADER.Validate_Commitment_Customer',1);
  OPEN l_line_csr;
  LOOP
    FETCH l_line_csr INTO l_commitment_id;
    EXIT WHEN l_line_csr%NOTFOUND;

    -- validate the sold_to_org_id of order against the customer for commitment.
    oe_debug_pub.add('OEXLHDRB: l_commitment_id in validation is: '||l_commitment_id, 3);
    IF l_commitment_id IS NOT NULL THEN
      BEGIN
        /*SELECT  MOAC_SQL_CHANGE 'Y'
        INTO   l_exists
        FROM   ra_customer_trx ratrx
        WHERE  ratrx.bill_to_customer_id
               IN (SELECT p_sold_to_org_id
                   FROM   sys.dual
                   UNION
                   SELECT cust_account_id customer_id
                   FROM   hz_cust_acct_relate_all h
                   WHERE  related_cust_account_id = p_sold_to_org_id
                   AND    status = 'A'
		   and    h.org_id = ratrx.org_id
                   AND    bill_to_flag = 'Y')

        AND    ratrx.customer_trx_id = l_commitment_id;*/
	--bug 4729536
	OPEN cur_customer_relations(l_commitment_id);
	Fetch cur_customer_relations into l_exists;
	Close cur_customer_relations;
	--bug 4729536


      EXCEPTION WHEN NO_DATA_FOUND THEN
        null;
      END;

      oe_debug_pub.add('OEXLHDRB: l_exists in validate_commitment_customer is: '||l_exists, 3);

      IF l_exists = 'N' THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        EXIT;
      END IF;
    END IF;

    END LOOP;
    CLOSE l_line_csr;

    oe_debug_pub.add('Exiting OE_VALIDATE_HEADER.Validate_Commitment_Customer',1);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('ONT','OE_FLOW_CNT_CHANGE');
    OE_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME ,
        'Validate_Commitment_Customer'
      );
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Commitment_Customer;

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
l_check_duplicate varchar2(1) :='Y';  --Added for 5053933
BEGIN
     --Added for 5053933 start
     l_check_duplicate :=nvl(FND_PROFILE.VALUE('ONT_ENFORCE_DUP_PO'),'Y');
     if l_check_duplicate='Y' then
     --Added for ER 4760436 end
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
     else
       RETURN FALSE;
     end if ; --l_check_duplicate
     RETURN TRUE;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
        RETURN FALSE;

END Is_Duplicate_PO_Number;

----------------------------------------------------------------------------
-- Procedure Validate_Blanket_Values
----------------------------------------------------------------------------

Procedure Validate_Blanket_Values
( p_header_rec                IN  OE_Order_PUB.Header_Rec_Type,
  p_old_header_rec            IN  OE_Order_PUB.Header_Rec_Type,
  x_return_status             OUT NOCOPY VARCHAR2
)

IS
 l_sold_to_org_id                   NUMBER;
 l_agreement_id                     NUMBER;
 l_on_hold_flag                     VARCHAR2(1);
 l_start_date_active                DATE;
 l_end_date_active                  DATE;
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --FOR BUG 3192386
 l_flow_status_code                 VARCHAR2(30);
 -- Bug 3232544
 lcustomer_relations    varchar2(1)  :=
           OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');
 l_exists               varchar2(1);
 --For Bug 3257240
 l_customer_name                    VARCHAR2(240);
 l_customer_number                  NUMBER;
BEGIN
    if l_debug_level > 0 then
    OE_DEBUG_PUB.Add('Entering OE_VALIDATE_HEADER.Validate_Blanket_Values',1);
    OE_DEBUG_PUB.Add('Blanket Number :'||p_header_rec.blanket_number,1);
    end if;

    IF p_header_rec.blanket_number IS NULL THEN
       FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_NO_BLANKET_LINE_NUM');
       OE_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
    END IF;

   BEGIN
   --Altered the sql for bug 3192386. Blankets in Negotiation or with Draft submitted as 'N' will not be selected.
       SELECT  BH.AGREEMENT_ID,
               BH.SOLD_TO_ORG_ID,
               BHE.on_hold_flag,
               BHE.START_DATE_ACTIVE,
               BHE.END_DATE_ACTIVE,
               NVL(BH.FLOW_STATUS_CODE,'ACTIVE')
       INTO    l_agreement_id,
               l_sold_to_org_id,
               l_on_hold_flag,
               l_start_date_active,
               l_end_date_active,
               l_flow_status_code
       FROM    OE_BLANKET_HEADERS BH,OE_BLANKET_HEADERS_EXT BHE
      WHERE    BH.ORDER_NUMBER  = p_header_rec.blanket_number
        AND    BH.ORDER_NUMBER  = BHE.ORDER_NUMBER
        AND    BH.SALES_DOCUMENT_TYPE_CODE = 'B'
        AND    NVL(BH.TRANSACTION_PHASE_CODE,'F')='F'
        AND    NVL(BH.DRAFT_SUBMITTED_FLAG,'Y') = 'Y';

   EXCEPTION

       WHEN NO_DATA_FOUND THEN
             FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ATTRIBUTE');
             FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_Util.Get_Attribute_Name('BLANKET_NUMBER'));
             OE_MSG_PUB.Add;
             if l_debug_level > 0 then
                 OE_DEBUG_PUB.Add('No Data Found when Validating Blanket',3);
             end if;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        WHEN OTHERS THEN
            if l_debug_level > 0 then
                 OE_DEBUG_PUB.Add('When Others when Validating Blanket',3);
            end if;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    IF ( p_header_rec.sold_to_org_id <> l_sold_to_org_id) AND
              (NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id
                                  ,p_old_header_rec.sold_to_org_id) OR
               NOT OE_GLOBALS.EQUAL(p_header_rec.blanket_number
                                  ,p_old_header_rec.blanket_number) ) THEN
       If l_debug_level > 0 then
        oe_debug_pub.add('Customer on release does not match blanket customer');
       End if;
        if lcustomer_relations = 'Y' then
           begin
           SELECT 'Y'
             INTO l_exists
             FROM HZ_CUST_ACCT_RELATE
            WHERE RELATED_CUST_ACCOUNT_ID = p_header_rec.sold_to_org_id
              AND CUST_ACCOUNT_ID = l_sold_to_org_id
              AND STATUS = 'A'
              AND ROWNUM = 1;
           exception
             when no_data_found then
               FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('SOLD_TO_ORG_ID'));
               --for bug 3257240
               OE_Id_To_Value.Sold_To_Org
                (   p_sold_to_org_id              => l_sold_to_org_id
                ,   x_org                         => l_customer_name
                ,   x_customer_number             => l_customer_number
                );
               FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',l_customer_name);
               OE_MSG_PUB.Add;
               x_return_status := FND_API.G_RET_STS_ERROR;
           end;
        else
           FND_MESSAGE.SET_NAME('ONT','OE_BLKT_INVALID_ATTRIBUTE');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_Util.Get_Attribute_Name
                                                ('SOLD_TO_ORG_ID'));
           --for bug 3257240
           OE_Id_To_Value.Sold_To_Org
            (   p_sold_to_org_id              => l_sold_to_org_id
            ,   x_org                         => l_customer_name
            ,   x_customer_number             => l_customer_number
            );
           FND_MESSAGE.SET_TOKEN('BLANKET_VALUE',l_customer_name);
           OE_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        end if;
    END IF;

    IF (p_header_rec.order_category_code = 'ORDER')  AND ( l_on_hold_flag <> 'N') AND
              (NOT OE_GLOBALS.EQUAL(p_header_rec.blanket_number
                                  ,p_old_header_rec.blanket_number) ) THEN
       if l_debug_level > 0 then
           OE_DEBUG_PUB.Add('Blanket order is currently on hold', 1);
      end if;
      FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_ON_HOLD');
      OE_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_header_rec.order_category_code = 'ORDER' AND
           (NOT OE_GLOBALS.EQUAL(p_header_rec.request_date
                                  ,p_old_header_rec.request_date)   OR
           NOT OE_GLOBALS.EQUAL(p_header_rec.blanket_number
                                  ,p_old_header_rec.blanket_number)) AND
         NOT (trunc(nvl(p_header_rec.request_date,sysdate))
         BETWEEN trunc(l_start_date_active)
         AND     trunc(nvl(l_end_date_active, nvl(p_header_rec.request_date,sysdate)))) THEN
      if l_debug_level > 0 then
          oe_debug_pub.add('Request date is not within active blanket  dates', 1);
      end if;
      FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ATTRIBUTE');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_Util.Get_Attribute_Name('BLANKET_NUMBER'));
      OE_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --For Bug 3192386
    IF p_header_rec.order_category_code  = 'ORDER' AND
                l_flow_status_code <> 'ACTIVE'
    THEN
       if l_debug_level > 0 then
          oe_debug_pub.add('Not an active Blanket for Release', 1);
       end if;
       FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                OE_Order_Util.Get_Attribute_Name('BLANKET_NUMBER'));
       OE_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_header_rec.agreement_id IS NOT NULL THEN
       FND_MESSAGE.SET_NAME('ONT', 'OE_BLKT_AGREEMENT_EXISTS');
       OE_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
    if l_debug_level > 0 then
         OE_DEBUG_PUB.Add('Exiting OE_VALIDATE_HEADER.Validate_Blanket_Values',1);
    end if;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        if l_debug_level > 0 then
           OE_DEBUG_PUB.Add('Expected Error in Validate Blanket Values',2);
        End if;

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    if l_debug_level > 0 then
        OE_DEBUG_PUB.Add('Unexpected Error in Validate Blanket Values:'||SqlErrm, 1);
    End if;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   'OE_VALIDATE_LINE',
              'Validate_Blanket_Values');
        END IF;

End Validate_Blanket_Values;


/*-------------------------------------------------------
PROCEDURE:    Entity
Description:
--------------------------------------------------------*/

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.Header_Rec_Type
      /* modified the above line to fix the bug 2824240 */
,   p_old_header_rec                IN  OE_Order_PUB.Header_Rec_Type :=
                                        OE_Order_PUB.G_MISS_HEADER_REC
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
      /* added the above line to fix the bug 2824240 */
)
IS
l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_dummy             VARCHAR2(10);
l_price_list_rec    OE_Order_Cache.Price_List_Rec_Type;
-- l_order_type_rec    OE_Order_Cache.Order_Type_Rec_Type;
-- L_agreement_rec     OE_Order_Cache.Agreement_Rec_Type;

l_agreement_name    varchar2(240);
l_agreement_revision    varchar2(50);
l_sold_to_org       number;
l_price_list_id     number;
lcustomer_relations varchar2(1);
l_list_type_code	VARCHAR2(30);
--MC Bgn
l_validate_result Varchar2(1):='N';
--MC End
L_COMMITMENT_CURR_CODE	VARCHAR2(15);
l_creation_status	VARCHAR2(30);
l_receipt_method_id	NUMBER;
l_cc_only               BOOLEAN := TRUE ;
l_customer_name		VARCHAR2(360);
l_temp                  pls_integer;
l_comt_cust_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_comt_curr_status  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_blanket_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_control_rec               OE_GLOBALS.Control_Rec_Type;
l_header_rec                OE_Order_PUB.Header_Rec_Type := p_header_rec;
l_old_header_rec            OE_Order_PUB.Header_Rec_Type := p_old_header_rec;
/* Added the above  3 line to fix the bug 2824240 */

 -- eBTax Changes
  l_ship_to_cust_Acct_id  hz_cust_Accounts.cust_Account_id%type;
  l_ship_to_party_id      hz_cust_accounts.party_id%type;
  l_ship_to_party_site_id hz_party_sites.party_site_id%type;
  l_bill_to_cust_Acct_id  hz_cust_Accounts.cust_Account_id%type;
  l_bill_to_party_id      hz_cust_accounts.party_id%type;
  l_bill_to_party_site_id hz_party_sites.party_site_id%type;
  l_org_id                NUMBER;

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

l_payment_count number;

-- required for IN line level validation, a corner case
CURSOR ib_lines IS
   SELECT l.line_id,
   l.ib_current_location,
   l.ib_installed_at_location
   FROM oe_order_lines_all l
   WHERE l.header_id=p_old_header_rec.header_id;
 --added for bug 3739650
   l_site_use_code   VARCHAR2(30);
BEGIN
    oe_debug_pub.add('Enter OE_VALIDATE_HEADER.ENTITY',1);

    --  Check required attributes.
 --lcustomer_relations := FND_PROFILE.VALUE('ONT_CUSTOMER_RELATIONSHIPS');
 lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');

    IF  p_header_rec.header_id IS NULL
    THEN
      l_return_status := FND_API.G_RET_STS_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_UTIL.Get_Attribute_Name('HEADER_ID'));
        OE_MSG_PUB.Add;
      END IF;

    END IF;

    -- QUOTING changes
    IF oe_code_control.code_release_level >= '110510'
       AND p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
       AND p_header_rec.transaction_phase_code IS NULL
    THEN
      l_return_status := FND_API.G_RET_STS_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
        OE_Order_UTIL.Get_Attribute_Name('TRANSACTION_PHASE_CODE'));
        OE_MSG_PUB.Add;
      END IF;

    END IF;


    ----------------------------------------------------------
    --  Check rest of required attributes here.
    ----------------------------------------------------------

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
    ELSE
      Validate_Order_Type
                (p_order_type_id     => p_header_rec.order_type_id,
                 p_old_order_type_id => p_old_header_rec.order_type_id,
                 p_header_id         => p_header_rec.header_id,
                 p_operation         => p_header_rec.operation);
    END IF;


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
        if l_debug_level > 0 then
           oe_debug_pub.add('reqd attribute missing');
        end if;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    ----------------------------------------------------------
    --  Check conditionally required attributes here.
    ----------------------------------------------------------

    -- QUOTING changes
    IF oe_code_control.code_release_level >= '110510' THEN

       Check_Negotiation_Attributes(p_header_rec
                                   ,p_old_header_rec
                                   ,l_return_status
                                   );

    ELSE

       -- Feature not supported prior to 11i10, raise error
       IF p_header_rec.transaction_phase_code = 'N' THEN
          FND_MESSAGE.SET_NAME('ONT','OE_QUOTE_INVALID_RELEASE');
          OE_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END IF;
    -- QUOTING changes END


    --  Check attributes required for booked header
    IF p_header_rec.booked_flag = 'Y' THEN

      Check_Book_Reqd_Attributes
      ( p_header_rec      => p_header_rec
      , x_return_status    => l_return_status
       );

    END IF;




    --bug6441512
   IF p_header_rec.tax_exempt_flag ='S'  THEN

      -- Check for Tax exempt number/Tax exempt reason.

      IF (p_header_rec.tax_exempt_number IS NOT NULL AND
          p_header_rec.tax_exempt_number <> FND_API.G_MISS_CHAR)
          OR
         (p_header_rec.tax_exempt_reason_code IS NOT NULL AND
          p_header_rec.tax_exempt_reason_code <> FND_API.G_MISS_CHAR) THEN
          l_return_status := FND_API.G_RET_STS_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
            fnd_message.set_name('ONT','OE_NO_TAX_EXEMPTION');
            OE_MSG_PUB.Add;
          END IF;
      END IF;

   END IF;


   --bug6441512
    IF p_header_rec.tax_exempt_flag = 'E'     THEN

         --bug6732513
	/* IF p_header_rec.tax_exempt_number IS NULL  OR
		 p_header_rec.tax_exempt_number = FND_API.G_MISS_CHAR
	      THEN

		 l_return_status := FND_API.G_RET_STS_ERROR;

		 IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
		 THEN
	          fnd_message.set_name('ONT','OE_TAX_EXEMPTION_REQUIRED');
	          OE_MSG_PUB.Add;
		 END IF;

           END IF; */



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


     --bug6441512
  IF p_header_rec.tax_exempt_flag ='R'  THEN

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

    --BUG#9366518
    oe_debug_pub.add('Checking for Payment Type and its Related Required Attributes');
    oe_debug_pub.add('PAYMENT_TYPE_CODE =             '||  p_header_rec.PAYMENT_TYPE_CODE);
    oe_debug_pub.add('CREDIT_CARD_CODE =              '||  p_header_rec.CREDIT_CARD_CODE);
    oe_debug_pub.add('CREDIT_CARD_NUMBER =            '||  p_header_rec.CREDIT_CARD_NUMBER);
    oe_debug_pub.add('CREDIT_CARD_HOLDER_NAME =       '||  p_header_rec.CREDIT_CARD_HOLDER_NAME);
    oe_debug_pub.add('CREDIT_CARD_EXPIRATION_DATE =   '||  p_header_rec.CREDIT_CARD_EXPIRATION_DATE);
    oe_debug_pub.add('CHECK_NUMBER =                  '||  p_header_rec.CHECK_NUMBER);

    IF p_header_rec.PAYMENT_TYPE_CODE = 'CHECK' THEN
    	IF p_header_rec.CHECK_NUMBER IS NULL
    	THEN
    		l_return_status := FND_API.G_RET_STS_ERROR;

    		IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
    		THEN
    			fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
    			FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_Attribute_Name('CHECK_NUMBER'));
    			OE_MSG_PUB.Add;
    		END IF;
    	END IF;
    END IF;

    IF p_header_rec.PAYMENT_TYPE_CODE = 'CREDIT_CARD' THEN
        IF (p_header_rec.CREDIT_CARD_NUMBER IS NULL) or (p_header_rec.CREDIT_CARD_HOLDER_NAME IS NULL)
    	--or (p_header_rec.CREDIT_CARD_EXPIRATION_DATE IS NULL) --commented for BUG#9436914
    	THEN
    		l_return_status := FND_API.G_RET_STS_ERROR;
    		IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_ERROR)
    		THEN
    			fnd_message.set_name('ONT','OE_VAL_CREDIT_CARD_REQD');
    			--FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_Attribute_Name('CREDIT_CARD_CODE'));
    			OE_MSG_PUB.Add;
    		END IF;
    	END IF;
    END IF;
   --BUG#9366518

    ----------------------------------------------------------------
    -- VALIDATE ATTRIBUTE DEPENDENCIES
    ----------------------------------------------------------------

    oe_debug_pub.add('old price ' ||  p_old_header_rec.price_list_id,2);
    oe_debug_pub.add('New price ' ||  p_header_rec.price_list_id,2);
    oe_debug_pub.add('old curr ' ||  p_old_header_rec.transactional_curr_code,2);
    oe_debug_pub.add('New curr ' ||  p_header_rec.transactional_curr_code,2);
    -- Validate currency

    l_price_list_rec :=OE_Order_Cache.Load_Price_List (p_header_rec.price_list_id );

    --Added OR condition for CREATE Operation for bug 5060064

    IF (p_header_rec.price_list_id <>
        Nvl(p_old_header_rec.price_list_id,FND_API.G_MISS_NUM) OR
        p_header_rec.transactional_curr_code <>
        p_old_header_rec.transactional_curr_code OR
        p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) AND
        p_header_rec.price_list_id IS NOT NULL
    THEN
       Begin
       QP_UTIL_PUB.Validate_Price_list_Curr_code(p_header_rec.price_list_id,
                                                 p_header_rec.transactional_curr_code,
                                                 p_header_rec.pricing_date,
                                                 l_validate_result);
       Exception when others then
            IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN

              OE_MSG_PUB.Add_Exc_Msg
              (  G_PKG_NAME ,
                'OE_VALIDATE_HEADER-QP_UTIL_PUB'
               );
            END IF;
            Oe_Debug_Pub.Add('Error when calling QP_UTIL_PUB.Validate_Price_list_Curr_code:'||SQLERRM);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       End;

      Oe_Debug_Pub.add(' M Currency:'||l_validate_result);
      IF l_validate_result = 'N' THEN
        Begin
          Select 1
          into   l_temp
          From   Oe_Order_Lines_All
          Where  header_id =   p_header_rec.header_id
          and    calculate_price_flag in ('P','N')
          and    rownum = 1;

        Exception when no_data_found then
--retro{
          /* Added the following if condition to fix the bug 2824240 */
          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_header_rec.operation = 'CREATE'
          THEN
	     IF(p_header_rec.order_source_id=27) THEN
	       p_header_rec.price_list_id := OE_RETROBILL_PVT.Get_First_Line_Price_List_Id;
	     ELSE
               p_header_rec.price_list_id := NULL;
	     END IF;
          ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
                p_header_rec.operation = 'CREATE'
          THEN
	     IF(p_header_rec.order_source_id=27) THEN
	       p_header_rec.price_list_id := OE_RETROBILL_PVT.Get_First_Line_Price_List_Id;
	     ELSE
               p_header_rec.price_list_id  := FND_API.G_MISS_NUM;
             END IF;
--retro}
             l_header_rec                := p_header_rec;
             l_old_header_rec            := p_old_header_rec;
             l_control_rec.controlled_operation := TRUE;
             l_control_rec.write_to_DB          := FALSE ;
             l_control_rec.process              := FALSE ;
             Oe_Order_Pvt.Header
             (    p_validation_level    => FND_API.G_VALID_LEVEL_NONE
             ,    p_control_rec         =>l_control_rec
             ,    p_x_header_rec        =>l_header_rec
             ,    p_x_old_header_rec    =>l_old_header_rec
             ,    x_return_status       =>l_return_status
              );
             p_header_rec                := l_header_rec;
             IF l_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

          /* End of code added to fix the bug 2824240 */

          ELSE
             --no frozen lines, error condition
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT','OE_VAL_ORD_CURRENCY_MISMATCH');
             FND_MESSAGE.SET_TOKEN('ORDER_CURRENCY',p_header_rec.transactional_curr_code);
             FND_MESSAGE.SET_TOKEN('PRICE_LIST_CURRENCY',l_price_list_rec.currency_code);
             OE_MSG_PUB.Add;
          END IF;
        End;
      END IF;
    END IF; -- Price list or currency changed.

    -- bug 1618229, if the currency changed, also needs to revalidate commitment
    -- on the order line.
    IF NOT OE_GLOBALS.EQUAL(p_header_rec.transactional_curr_code,
           p_old_header_rec.transactional_curr_code) THEN

       oe_debug_pub.add('OEXLHDRB: before validating currency for commitment.', 3);
       Validate_Commitment_Currency
                  (p_header_id 	    	     => p_header_rec.header_id
                  ,p_transactional_curr_code => p_header_rec.transactional_curr_code
                  ,x_return_status 	     => l_comt_curr_status);

       IF l_comt_curr_status = FND_API.G_RET_STS_ERROR THEN
         l_return_status := FND_API.G_RET_STS_ERROR;
         Fnd_Message.Set_Name('ONT','ONT_INVALID_CURR_CHANGE');
         Fnd_message.set_token('REASON','ONT_COMMITMENT_ON_LINE',TRUE);
         OE_MSG_PUB.Add;
         oe_debug_pub.add('Error: currency code does not match the currency for the commitment.', 3);
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

    -- Currency_date, currency_rate should be null when type is null.

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

--bug 3220059 for other conversion types, conversion rate should be NULL, not conversion rate date
   IF p_header_rec.conversion_type_code <> 'User' AND
        p_header_rec.conversion_rate IS NOT NULL
   THEN
    l_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('ONT','OE_VALIDATION_CONV_TYPE');
    OE_MSG_PUB.ADD;

  END IF; -- END of checks based on conversion type


    --  Order Type has to be valid on the date ordered.
    IF (p_header_rec.order_type_id <>
        NVL(p_old_header_rec.order_type_id,FND_API.G_MISS_NUM)) OR
       (p_header_rec.ordered_date <>
        NVL(p_old_header_rec.ordered_date,FND_API.G_MISS_DATE))
    THEN

      IF p_header_rec.ordered_date IS NOT NULL THEN

        BEGIN
          -- Bug 3942415
          SELECT  'VALID'
          INTO  l_dummy
          FROM  OE_ORDER_TYPES_V
          WHERE  ORDER_TYPE_ID = p_header_rec.order_type_id
          AND  TRUNC(p_header_rec.ordered_date)
          BETWEEN NVL(START_DATE_ACTIVE,TRUNC(p_header_rec.ordered_date))
          AND     NVL( END_DATE_ACTIVE,TRUNC(p_header_rec.ordered_date));
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

      END IF; -- date ordered is not null.

    END IF; -- Order Type or date has changed.


    --  Agreement depends on Order Type AND Sold To Org
    -- Added OR condition for CREATE Operation. Bug 5060064

    IF (NOT OE_GLOBALS.EQUAL(p_header_rec.order_type_id
                           ,p_old_header_rec.order_type_id)) OR
       (NOT OE_GLOBALS.EQUAL(p_header_rec.agreement_id
                           ,p_old_header_rec.agreement_id)) OR
       (NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id
                           ,p_old_header_rec.sold_to_org_id)) OR
       (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE)
    THEN

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

/* Added the following code to fix the bug 2124912 */

                BEGIN
                  --bug 5206956 added sold_to_org_id in the next 2 selects
                  select name,revision, sold_to_org_id
                  into l_agreement_name,l_agreement_revision, l_sold_to_org
                  from oe_agreements_vl
                  where agreement_id = p_header_rec.agreement_id;

                  select name,revision, sold_to_org_id
                  into l_agreement_name,l_agreement_revision, l_sold_to_org
                  from oe_agreements_vl
                  where agreement_id = p_header_rec.agreement_id
                  AND trunc(nvl(p_header_rec.pricing_date,sysdate)) between
                  trunc(nvl(START_DATE_ACTIVE,add_months(sysdate,-10000)))
                  AND  trunc(nvl(END_DATE_ACTIVE,add_months(sysdate,+10000)));

                EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    /* Added the following if condition to fix the bug 2824240 */
                    IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
                       p_header_rec.operation = 'CREATE'
                     THEN
                       p_header_rec.agreement_id := NULL;
                     ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
                           p_header_rec.operation = 'CREATE'
                     THEN
                       p_header_rec.agreement_id  := FND_API.G_MISS_NUM;
                       l_header_rec                := p_header_rec;
                       l_old_header_rec            := p_old_header_rec;
                       l_control_rec.controlled_operation := TRUE;
                       l_control_rec.write_to_DB          := FALSE ;
                       l_control_rec.process              := FALSE ;
                       Oe_Order_Pvt.Header
                       (    p_validation_level    => FND_API.G_VALID_LEVEL_NONE
                       ,    p_control_rec         =>l_control_rec
                       ,    p_x_header_rec        =>l_header_rec
                       ,    p_x_old_header_rec    =>l_old_header_rec
                       ,    x_return_status       =>l_return_status
                        );
                       p_header_rec                := l_header_rec;
                       IF l_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
                          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                          RAISE FND_API.G_EXC_ERROR;
                       END IF;

                    /* End of code added to fix the bug 2824240 */
                    ELSE
                      fnd_message.set_name('ONT', 'ONT_INVALID_AGREEMENT');
                      fnd_message.set_Token('AGREEMENT_NAME',l_agreement_name);
                      fnd_message.set_Token('REVISION',l_agreement_revision);
                      OE_MSG_PUB.Add;
                      oe_debug_pub.add('Invalid Agreement ',1);
                      raise FND_API.G_EXC_ERROR;
                    END IF;
                END;

/* End of code added to fix the bug 2124912 */

          IF NOT OE_GLOBALS.EQUAL(l_list_type_code,'PRL') THEN
		-- any price list with 'PRL' type should be allowed to
		-- be associated with any agreement according to bug 1386406.

            select name ,sold_to_org_id , price_list_id
            into l_agreement_name,l_sold_to_org,l_price_list_id
            from oe_agreements_v
            where agreement_id = p_header_rec.agreement_id
            AND trunc(nvl(p_header_rec.pricing_date,sysdate)) between
            trunc(nvl(START_DATE_ACTIVE,add_months(sysdate,-10000)))
            AND  trunc(nvl(END_DATE_ACTIVE,add_months(sysdate,+10000)));

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

   --bug 5206956 to check for customer relationships
        IF l_sold_to_org IS NOT NULL AND l_sold_to_org <> -1
                AND NOT OE_GLOBALS.EQUAL(l_sold_to_org,p_header_rec.sold_to_org_id) THEN
                IF nvl(lcustomer_relations,'N') = 'N' THEN
                        fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT');
                        fnd_message.set_Token('AGREEMENT_ID', p_header_rec.agreement_id);
                        fnd_message.set_Token('AGREEMENT_NAME', l_agreement_name);
                        fnd_message.set_Token('CUSTOMER_ID', p_header_rec.sold_to_org_id);
                        OE_MSG_PUB.Add;
                        IF l_debug_level > 0 then
                                oe_debug_pub.add('Invalid Agreement +sold_org_id combination',2);
                        END IF;
                                RAISE FND_API.G_EXC_ERROR;
        ELSIF lcustomer_relations = 'Y' THEN

                        BEGIN
                          SELECT        'VALID'
                          INTO  l_dummy
                          FROM  dual
                          WHERE         exists(
                        select 'x' from
                        hz_cust_acct_relate where
                        related_cust_account_id = p_header_rec.sold_to_org_id
                        and status = 'A'
                                AND cust_account_id = l_sold_to_org
                                        );

                        EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                        fnd_message.set_name('ONT', 'OE_INVALID_AGREEMENT');
                        fnd_message.set_Token('AGREEMENT_ID', p_header_rec.agreement_id);
                        fnd_message.set_Token('AGREEMENT_NAME', l_agreement_name);
                        fnd_message.set_Token('CUSTOMER_ID', p_header_rec.sold_to_org_id);
                        OE_MSG_PUB.Add;
                        IF l_debug_level > 0 then
                                oe_debug_pub.add('Invalid Agreement +sold_org_id combination',2);
                        END IF;
                                RAISE FND_API.G_EXC_ERROR;
                        END;
           END IF;
         END IF;
   --bug 5206956



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

	   /***
        IF (l_agreement_rec.sold_to_org_id IS NOT NULL AND
            l_agreement_rec.sold_to_org_id <>
            p_header_rec.sold_to_org_id ) OR
            (l_order_type_rec.agreement_type_code IS NOT NULL AND
            l_agreement_rec.agreement_type_code <>
            l_order_type_rec.agreement_type_code ) THEN
           	l_return_status := FND_API.G_RET_STS_ERROR;
          	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
          	THEN
            	 	fnd_message.set_name('ONT','OE_INVALID_AGREEMENT');
            		OE_MSG_PUB.Add;
          	END IF;
        END IF;
	   ***/

      END IF;  --  Agreement is not null

    END IF; -- Agreement needed validation.


    --  Ship to Org id depends on sold to org.
    -- Added OR condition for CREATE Operation. Bug 5060064
    IF p_header_rec.ship_to_org_id IS NOT NULL AND
     ( NOT OE_GLOBALS.EQUAL(p_header_rec.ship_to_org_id
                           ,p_old_header_rec.ship_to_org_id)
       OR
       NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id
                           ,p_old_header_rec.sold_to_org_id)
       OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE))
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
        AND    status = 'A'
	AND    address_status ='A'; --bug 2752321

   ELSIF lcustomer_relations = 'Y' THEN
        oe_debug_pub.add
        ('Cr: Yes Ship',2);
    --variable added for bug 3739650
    l_site_use_code := 'SHIP_TO' ;
    SELECT /* MOAC_SQL_CHANGE */ 'VALID'
    Into   l_dummy
    FROM   HZ_CUST_SITE_USES_ALL SITE,
	   HZ_CUST_ACCT_SITES ACCT_SITE
    WHERE SITE.SITE_USE_ID     = p_header_rec.ship_to_org_id
    AND SITE.SITE_USE_CODE     = l_site_use_code
    AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
    AND SITE.STATUS = 'A'
    AND ACCT_SITE.STATUS ='A' AND --bug 2752321
     ACCT_SITE.CUST_ACCOUNT_ID in (
                    SELECT p_header_rec.sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE_ALL h  WHERE
                    RELATED_CUST_ACCOUNT_ID = p_header_rec.sold_to_org_id
		    and h.org_id =acct_site.org_id
			and ship_to_flag = 'Y' and status = 'A')
	--bug 4205113
    AND EXISTS(SELECT 1 FROM HZ_CUST_ACCOUNTS WHERE CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID AND STATUS='A')
    AND ROWNUM = 1;
        oe_debug_pub.add
        ('Cr: Yes- After the select',2);
   ELSIF lcustomer_relations = 'A' THEN
    SELECT  'VALID'
    INTO    l_dummy
    FROM    OE_SHIP_TO_ORGS_V   SHP
    WHERE   SHP.ORGANIZATION_ID =p_header_rec.ship_to_org_id
    AND     SHP.STATUS = 'A'
    AND     SHP.ADDRESS_STATUS ='A' --bug 2752321
    AND     SYSDATE BETWEEN NVL(SHP.START_DATE_ACTIVE, SYSDATE)
                    AND     NVL(SHP.END_DATE_ACTIVE, SYSDATE);


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
    IF p_header_rec.deliver_to_org_id IS NOT NULL AND
       ( NOT OE_GLOBALS.EQUAL(p_header_rec.deliver_to_org_id
                             ,p_old_header_rec.deliver_to_org_id)
       OR
        NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id
                            ,p_old_header_rec.sold_to_org_id)
       OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE))
    THEN
      BEGIN

      oe_debug_pub.add('deliver_to_org_id :'||to_char(p_header_rec.deliver_to_org_id),2);
      oe_debug_pub.add('Customer Relation :'||lcustomer_relations,2);

      IF nvl(lcustomer_relations,'N') = 'N' THEN

        oe_debug_pub.add('Cr: No',2);

        SELECT 'VALID'
        INTO   l_dummy
        FROM   oe_deliver_to_orgs_v
        WHERE  customer_id = p_header_rec.sold_to_org_id
        AND    site_use_id = p_header_rec.deliver_to_org_id
        AND    status = 'A'
	AND    address_status ='A'; --bug 2752321
        --  Valid Deliver To Org Id.

      ELSIF lcustomer_relations = 'Y' THEN
        oe_debug_pub.add('Cr: Yes deliver',2);
     --variable added for bug 3739650
       l_site_use_code := 'DELIVER_TO' ;
        SELECT /* MOAC_SQL_CHANGE */ 'VALID'
         Into   l_dummy
         FROM   HZ_CUST_SITE_USES_ALL SITE,
	        HZ_CUST_ACCT_SITES ACCT_SITE
        WHERE SITE.SITE_USE_ID     = p_header_rec.deliver_to_org_id
         AND SITE.SITE_USE_CODE    = l_site_use_code
         AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
         AND SITE.STATUS = 'A'
	   AND ACCT_SITE.STATUS = 'A' AND --bug 2752321
         ACCT_SITE.CUST_ACCOUNT_ID in (
                    SELECT p_header_rec.sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE_ALL h WHERE
                    RELATED_CUST_ACCOUNT_ID = p_header_rec.sold_to_org_id
                    and h.org_id =acct_site.org_id
			and ship_to_flag = 'Y' and status='A')
	--bug 4205113
    AND EXISTS(SELECT 1 FROM HZ_CUST_ACCOUNTS WHERE CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID AND STATUS='A')
    AND ROWNUM = 1;
        oe_debug_pub.add('Cr: Yes- After the select',2);

      ELSIF lcustomer_relations = 'A' THEN

        SELECT  'VALID'
         INTO    l_dummy
         FROM    OE_DELIVER_TO_ORGS_V   DEL
        WHERE   DEL.ORGANIZATION_ID =p_header_rec.deliver_to_org_id
          AND     DEL.STATUS = 'A'
	  AND     DEL.ADDRESS_STATUS ='A' --bug 2752321
          AND     SYSDATE BETWEEN NVL(DEL.START_DATE_ACTIVE, SYSDATE)
                          AND     NVL(DEL.END_DATE_ACTIVE, SYSDATE);


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

    IF p_header_rec.invoice_to_org_id IS NOT NULL AND
      ( NOT OE_GLOBALS.EQUAL(p_header_rec.invoice_to_org_id
                            ,p_old_header_rec.invoice_to_org_id) OR
        NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id
                            ,p_old_header_rec.sold_to_org_id)
       OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE))
    THEN
      BEGIN
        oe_debug_pub.add
        ('invoice_to_org_id :'||to_char(p_header_rec.invoice_to_org_id),2);

	   IF nvl(lcustomer_relations,'N') = 'N' THEN

        Select 'VALID'
        Into   l_dummy
        From   oe_invoice_to_orgs_v
        Where  customer_id = p_header_rec.sold_to_org_id
        AND    site_use_id = p_header_rec.invoice_to_org_id
        and    status = 'A'
	and    address_status ='A'; --bug 2752321
    -- validation for lcustomer_relations=A is done at the attribute level.
    -- for Order entered in the Sales Order form , it is assumed that the
    -- invoice to org passed is the correct one
    ELSIF lcustomer_relations = 'Y' THEN

        oe_debug_pub.add
        ('Cr: Yes Inv',2);
  --variable added for bug 3739650
    l_site_use_code := 'BILL_TO' ;
    SELECT 'VALID'
    Into   l_dummy
    FROM   HZ_CUST_SITE_USES_ALL SITE,
	   HZ_CUST_ACCT_SITES ACCT_SITE
    WHERE SITE.SITE_USE_ID     = p_header_rec.invoice_to_org_id
    AND SITE.SITE_USE_CODE     = l_site_use_code
    AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
    AND SITE.STATUS = 'A'
    AND ACCT_SITE.ORG_ID=SITE.ORG_ID
    AND ACCT_SITE.STATUS = 'A' AND
    ACCT_SITE.CUST_ACCOUNT_ID in (
                    SELECT p_header_rec.sold_to_org_id FROM DUAL
                    UNION
                    SELECT CUST_ACCOUNT_ID FROM
                    HZ_CUST_ACCT_RELATE_ALL h WHERE
                    RELATED_CUST_ACCOUNT_ID = p_header_rec.sold_to_org_id
		    and h.org_id =site.org_id
		    and bill_to_flag = 'Y' and status='A' )
    --bug 4205113
    AND EXISTS(SELECT 1 FROM HZ_CUST_ACCOUNTS WHERE CUST_ACCOUNT_ID = ACCT_SITE.CUST_ACCOUNT_ID AND STATUS='A')
    AND ROWNUM = 1;
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

    -- QUOTING changes
    --  Customer Location depends on Sold To Org

    IF p_header_rec.sold_to_site_use_id IS NOT NULL AND
      ( NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_site_use_id
                            ,p_old_header_rec.sold_to_site_use_id) OR
        NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id
                            ,p_old_header_rec.sold_to_org_id)
       OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE))
    THEN

      BEGIN

        SELECT /* MOAC_SQL_CHANGE */ 'VALID'
        INTO    l_dummy
        FROM
             HZ_CUST_SITE_USES_ALL   SITE,
             HZ_CUST_ACCT_SITES  ACCT_SITE
        WHERE
             SITE.SITE_USE_ID = p_header_rec.sold_to_site_use_id
             AND  SITE.SITE_USE_CODE = 'SOLD_TO'
             AND  SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
             AND  ACCT_SITE.CUST_ACCOUNT_ID = p_header_rec.sold_to_org_id
             AND  SITE.STATUS = 'A'
             AND  ACCT_SITE.STATUS='A';

        --  Valid Customer Location



      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('SOLD_TO_SITE_USE_ID'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN

         IF OE_MSG_PUB.Check_Msg_Level
         (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN

           OE_MSG_PUB.Add_Exc_Msg
           (  G_PKG_NAME ,
             'Record - Customer Location'
           );
         END IF;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END;

    END IF;
    -- QUOTING changes

    -- end customer contact id depends on end customer id
    IF p_header_rec.end_customer_contact_id IS NOT NULL AND
     ( NOT OE_GLOBALS.EQUAL(p_header_rec.end_customer_contact_id
                           ,p_old_header_rec.end_customer_contact_id) OR
       NOT OE_GLOBALS.EQUAL(p_header_rec.end_customer_id
                           ,p_old_header_rec.end_customer_id)
       OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE))
    THEN

      BEGIN

        SELECT  'VALID'
        INTO  l_dummy
        FROM
             HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
        WHERE
             ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_header_rec.end_customer_contact_id
             AND  ACCT_ROLE.CUST_ACCOUNT_ID = p_header_rec.end_customer_id
             AND  ROWNUM = 1
             AND  ACCT_ROLE.ROLE_TYPE = 'CONTACT'
             AND  STATUS= 'A';

        --  Valid Sold To Contact

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('END_CUSTOMER_CONTACT_ID'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level
          ( OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            OE_MSG_PUB.Add_Exc_Msg
            (  G_PKG_NAME ,
              'Record - End Customer Contact'
             );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END; -- BEGIN

    END IF; -- End Customer contact needed validation.


    IF p_header_rec.end_customer_site_use_id IS NOT NULL AND
     ( NOT OE_GLOBALS.EQUAL(p_header_rec.end_customer_site_use_id
                           ,p_old_header_rec.end_customer_id) OR
       NOT OE_GLOBALS.EQUAL(p_header_rec.end_customer_id
                           ,p_old_header_rec.end_customer_id)
       OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE))
    THEN

      BEGIN

	 SELECT /* MOAC_SQL_CHANGE */ 'VALID'
	    INTO
	    l_dummy
	    FROM
	    hz_cust_site_uses_all site_use,
	    hz_cust_acct_sites acct_site
	    WHERE
	    site_use.site_use_id=p_header_rec.end_customer_site_use_id
	    and site_use.cust_acct_site_id=acct_site.cust_acct_site_id
	    and acct_site.cust_account_id=p_header_rec.end_customer_id;
        --  Valid End customer site

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
          OE_Order_Util.Get_Attribute_Name('END_CUSTOMER_SITE_USE_ID'));
          OE_MSG_PUB.Add;

        WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level
          ( OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            OE_MSG_PUB.Add_Exc_Msg
            (  G_PKG_NAME ,
              'Record - End Customer Site'
             );
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END; -- BEGIN

    END IF; -- End Customer site needed validation.

    --  Sold to contact depends on Sold To Org

    IF p_header_rec.sold_to_contact_id IS NOT NULL AND
     ( NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_contact_id
                           ,p_old_header_rec.sold_to_contact_id) OR
       NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id
                           ,p_old_header_rec.sold_to_org_id)
       OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE))
    THEN

      BEGIN

        SELECT  'VALID'
        INTO  l_dummy
        FROM
             HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
        WHERE
             ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_header_rec.sold_to_contact_id
             AND  ACCT_ROLE.CUST_ACCOUNT_ID = p_header_rec.sold_to_org_id
             AND  ROWNUM = 1
             AND  ACCT_ROLE.ROLE_TYPE = 'CONTACT'
             AND  STATUS= 'A';

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

    IF p_header_rec.invoice_to_contact_id IS NOT NULL AND
       ( NOT OE_GLOBALS.EQUAL(p_header_rec.invoice_to_contact_id
                             ,p_old_header_rec.invoice_to_contact_id) OR
         NOT OE_GLOBALS.EQUAL(p_header_rec.invoice_to_org_id
                             ,p_old_header_rec.invoice_to_org_id)
       OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE))
    THEN
      BEGIN
        oe_debug_pub.add
        ('inv_to_contact :'||to_char(p_header_rec.invoice_to_contact_id),2);

        SELECT /* MOAC_SQL_CHANGE */ 'VALID'
        INTO    l_dummy
        FROM
             HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
             HZ_CUST_SITE_USES_ALL   SITE_USE,         --changed INV to SITE_USE for bug 3739650
             HZ_CUST_ACCT_SITES  ADDR
        WHERE
             ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_header_rec.invoice_to_contact_id
             AND  ACCT_ROLE.CUST_ACCOUNT_ID = ADDR.CUST_ACCOUNT_ID
             AND  ACCT_ROLE.ROLE_TYPE = 'CONTACT'
             AND  ADDR.CUST_ACCT_SITE_ID = SITE_USE.CUST_ACCT_SITE_ID
             AND  SITE_USE.SITE_USE_ID = p_header_rec.invoice_to_org_id
             AND  SITE_USE.STATUS = 'A'
             AND  ADDR.STATUS ='A' --bug 2752321
             AND  ACCT_ROLE.STATUS = 'A'
             AND  ROWNUM = 1;

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

    IF p_header_rec.ship_to_contact_id IS NOT NULL AND
      ( NOT OE_GLOBALS.EQUAL(p_header_rec.ship_to_contact_id
                            ,p_old_header_rec.ship_to_contact_id) OR
        NOT OE_GLOBALS.EQUAL(p_header_rec.ship_to_org_id
                            ,p_old_header_rec.ship_to_org_id)
       OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE))
    THEN

      BEGIN

        SELECT /* MOAC_SQL_CHANGE */  'VALID'
        INTO    l_dummy
        FROM
             HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
             HZ_CUST_SITE_USES_ALL   SITE_USE,               --changed SHIP to SITE_USE for bug 3739650
             HZ_CUST_ACCT_SITES  ADDR
        WHERE
             ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_header_rec.ship_to_contact_id
             AND  ACCT_ROLE.CUST_ACCOUNT_ID = ADDR.CUST_ACCOUNT_ID
             AND  ACCT_ROLE.ROLE_TYPE = 'CONTACT'
             AND  ADDR.CUST_ACCT_SITE_ID = SITE_USE.CUST_ACCT_SITE_ID
             AND  SITE_USE.SITE_USE_ID = p_header_rec.ship_to_org_id
             AND  SITE_USE.STATUS = 'A'
	     AND  ADDR.STATUS ='A' --bug 2752321
             AND  ACCT_ROLE.STATUS = 'A'
             AND  ROWNUM = 1;

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

    IF p_header_rec.deliver_to_contact_id IS NOT NULL AND
       ( NOT OE_GLOBALS.EQUAL(p_header_rec.deliver_to_contact_id
                             ,p_old_header_rec.deliver_to_contact_id) OR
         NOT OE_GLOBALS.EQUAL(p_header_rec.deliver_to_org_id
                             ,p_old_header_rec.deliver_to_org_id)
       OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE))
    THEN

      BEGIN

        SELECT /* MOAC_SQL_CHANGE */ 'VALID'
        INTO    l_dummy
        FROM
             HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
             HZ_CUST_SITE_USES_ALL   SITE_USE,   --changed DELIVER to SITE_USE for bug 3739650
             HZ_CUST_ACCT_SITES  ADDR
        WHERE
             ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_header_rec.deliver_to_contact_id
             AND  ACCT_ROLE.CUST_ACCOUNT_ID = ADDR.CUST_ACCOUNT_ID
             AND  ACCT_ROLE.ROLE_TYPE = 'CONTACT'
             AND  ADDR.CUST_ACCT_SITE_ID = SITE_USE.CUST_ACCT_SITE_ID
             AND  SITE_USE.SITE_USE_ID = p_header_rec.deliver_to_org_id
             AND  SITE_USE.STATUS = 'A'
	     AND  ADDR.STATUS ='A' --bug 2752321
             AND  ACCT_ROLE.STATUS = 'A'
             AND  ROWNUM = 1;

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



    --Following validation for Tax Exemption Number is removed for bug 6441512
    --  Check for Tax Exempt number/Tax exempt reason code IF the Tax exempt
    --    flag is 'S' (StANDard).


   /* IF p_header_rec.tax_exempt_flag IS NOT NULL
       AND ( NOT OE_GLOBALS.EQUAL(p_header_rec.tax_exempt_number
                                 ,p_old_header_rec.tax_exempt_number)
       OR NOT OE_GLOBALS.EQUAL(p_header_rec.tax_exempt_reason_code
                              ,p_old_header_rec.tax_exempt_reason_code)
       OR NOT OE_GLOBALS.EQUAL(p_header_rec.ship_to_org_id
                              ,p_old_header_rec.ship_to_org_id)
       OR NOT OE_GLOBALS.EQUAL(p_header_rec.invoice_to_org_id
                              ,p_old_header_rec.invoice_to_org_id)
       OR NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id
                              ,p_old_header_rec.sold_to_org_id)
       OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE)
           )
    THEN

      BEGIN
        -- 6118092
        IF ( p_header_rec.tax_exempt_flag = 'S' OR p_header_rec.tax_exempt_flag = 'E' ) AND
           p_header_rec.tax_exempt_number IS NOT NULL AND
           p_header_rec.tax_exempt_reason_code IS NOT NULL
        THEN

         -- EBTax Changes

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

         -- Modified below code to validate Tax Exempt Number based on Tax Handling for Bug 6378168
         IF ( p_header_rec.tax_exempt_flag = 'S' ) THEN
          SELECT 'VALID'
          INTO l_dummy
          FROM ZX_EXEMPTIONS_V
          WHERE EXEMPT_CERTIFICATE_NUMBER = p_header_rec.tax_exempt_number
          AND EXEMPT_REASON_CODE=p_header_rec.tax_exempt_reason_code
          AND nvl(site_use_id,nvl(p_header_rec.ship_to_org_id,p_header_rec.invoice_to_org_id)) =
                    nvl(p_header_rec.ship_to_org_id,p_header_rec.invoice_to_org_id)
          AND nvl(cust_account_id, l_bill_to_cust_acct_id) = l_bill_to_cust_acct_id
          AND nvl(PARTY_SITE_ID,nvl(l_ship_to_party_site_id, l_bill_to_party_site_id))=
                       nvl(l_ship_to_party_site_id, l_bill_to_party_site_id)
          and  org_id = p_header_rec.org_id
          and  party_id = l_bill_to_party_id
          AND EXEMPTION_STATUS_CODE = 'PRIMARY'
          AND TRUNC(NVL(p_header_rec.request_date,sysdate)) BETWEEN
          TRUNC(EFFECTIVE_FROM) AND
          TRUNC(NVL(EFFECTIVE_TO,NVL(p_header_rec.request_date,sysdate)))
          AND ROWNUM = 1;
         ELSIF ( p_header_rec.tax_exempt_flag = 'E' ) THEN
          SELECT 'VALID'
          INTO l_dummy
          FROM ZX_EXEMPTIONS_V
          WHERE EXEMPT_CERTIFICATE_NUMBER = p_header_rec.tax_exempt_number
          AND EXEMPT_REASON_CODE=p_header_rec.tax_exempt_reason_code
          AND nvl(site_use_id,nvl(p_header_rec.ship_to_org_id,p_header_rec.invoice_to_org_id)) =
                    nvl(p_header_rec.ship_to_org_id,p_header_rec.invoice_to_org_id)
          AND nvl(cust_account_id, l_bill_to_cust_acct_id) = l_bill_to_cust_acct_id
          AND nvl(PARTY_SITE_ID,nvl(l_ship_to_party_site_id, l_bill_to_party_site_id))=
                       nvl(l_ship_to_party_site_id, l_bill_to_party_site_id)
          and  org_id = p_header_rec.org_id
          and  party_id = l_bill_to_party_id
          AND EXEMPTION_STATUS_CODE IN ('PRIMARY','MANUAL','UNAPPROVED')
          AND TRUNC(NVL(p_header_rec.request_date,sysdate)) BETWEEN
          TRUNC(EFFECTIVE_FROM) AND
          TRUNC(NVL(EFFECTIVE_TO,NVL(p_header_rec.request_date,sysdate)))
          AND ROWNUM = 1;
         END IF;

        END IF;

       oe_debug_pub.Add(' Valid Tax Exempt Number',1);

      EXCEPTION

        WHEN NO_DATA_FOUND THEN

                   -- Bug 6118092 Redefault as it may be no more valid
                  IF p_header_rec.order_category_code = 'RETURN' THEN  -- 6430711
                     null;
                    ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
                          p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE   THEN
                          p_header_rec.tax_exempt_number := FND_API.G_MISS_CHAR;
                          p_header_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
                          p_header_rec.tax_exempt_flag :=FND_API.G_MISS_CHAR;

                          oe_debug_pub.Add('Redefault the tax_exempt_number',1);
                   ELSE
                        l_return_status := FND_API.G_RET_STS_ERROR;
                        fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
                        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',
                        OE_Order_Util.Get_Attribute_Name('TAX_EXEMPT_NUMBER'));
                        OE_MSG_PUB.Add;
                   END IF;

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

    */

    oe_debug_pub.Add('p_header_rec.cust_po_number'|| p_header_rec.cust_po_number);-- Bug# 6603714
    IF p_header_rec.order_source_id <> 27 THEN-- Bug# 6603714

    -- Fix bug 1162304: issue a warning message if the PO number
    -- is being referenced by another order
    IF p_header_rec.cust_po_number IS NOT NULL
	  AND ( NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id
                              ,p_old_header_rec.sold_to_org_id)
             OR NOT OE_GLOBALS.EQUAL(p_header_rec.cust_po_number
                              ,p_old_header_rec.cust_po_number)
             OR (p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE)
            )
    THEN

      IF OE_Validate_Header.Is_Duplicate_PO_Number
           (p_header_rec.cust_po_number
           ,p_header_rec.sold_to_org_id
           ,p_header_rec.header_id )
      THEN
          FND_MESSAGE.SET_NAME('ONT','OE_VAL_DUP_PO_NUMBER');
          OE_MSG_PUB.ADD;
      END IF;

    END IF;
    -- End of check for duplicate PO number
    END IF;-- Bug# 6603714


    -- bug 1618229, validation for sold_to_org_id on order against
    -- the customer for commitment when commitment is used.
    /*
    ** Fix Bug # 3015881
    ** No need to validate here as this will be validated anyway
    ** when the sold to org id changes are cascaded to the line.

    IF (NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id
                            ,p_old_header_rec.sold_to_org_id)) THEN

       oe_debug_pub.add('OEXLHDRB: before validating customer for commitment.', 3);
       Validate_Commitment_Customer
                  (p_header_id 	    	=> p_header_rec.header_id
                  ,p_sold_to_org_id    	=> p_header_rec.sold_to_org_id
                  ,x_return_status      => l_comt_cust_status);

       IF l_comt_cust_status = FND_API.G_RET_STS_ERROR THEN

         l_return_status := FND_API.G_RET_STS_ERROR;

         -- to get the customer name of the order.
         BEGIN
           SELECT party.party_name
           INTO   l_customer_name
           FROM   hz_parties party,
                  hz_cust_accounts cust_acct
           WHERE  cust_acct.cust_account_id = p_header_rec.sold_to_org_id
           AND    cust_acct.party_id = party.party_id;

         EXCEPTION WHEN NO_DATA_FOUND THEN
           null;
         END;

         Fnd_Message.Set_Name('ONT','ONT_COM_CUSTOMER_MISMATCH');
         Fnd_message.set_token('CUSTOMER',l_customer_name);
         OE_MSG_PUB.Add;
         oe_debug_pub.add('Error: customer of the order does not match the customer for the commitment.', 3);
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    */

     -------------------------------------------------------------------
     -- Validating Blankets
     -------------------------------------------------------------------

     IF OE_CODE_CONTROL.Get_Code_Release_Level < '110509' AND
                             p_header_rec.blanket_number IS NOT NULL THEN
        If l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('Blankets are only available in Pack I or greater',1);
        End if;
        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('ONT','OE_BLANKET_INVALID_VERSION');
        OE_MSG_PUB.Add;
     ELSE
         IF p_header_rec.blanket_number IS NOT NULL THEN
            Validate_Blanket_Values
                 (p_header_rec     => p_header_rec,
                  p_old_header_rec => p_old_header_rec,
                  x_return_status  => l_blanket_status);
            IF l_blanket_status = FND_API.G_RET_STS_ERROR THEN
               x_return_status := l_blanket_status;
            ELSIF l_blanket_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
     END IF;

     --Commenting the following for bug 3733877
/*
     IF OE_PREPAYMENT_UTIL.IS_MULTIPLE_PAYMENTS_ENABLED = TRUE THEN

       IF (NOT OE_GLOBALS.EQUAL(p_header_rec.payment_type_code
                            ,p_old_header_rec.payment_type_code))
          or
          (NOT OE_GLOBALS.EQUAL(p_header_rec.credit_card_code
                            ,p_old_header_rec.credit_card_code))
          or
          (NOT OE_GLOBALS.EQUAL(p_header_rec.credit_card_number
                            ,p_old_header_rec.credit_card_number))
          or
          (NOT OE_GLOBALS.EQUAL(p_header_rec.credit_card_holder_name
                            ,p_old_header_rec.credit_card_holder_name))
          or
           (NOT OE_GLOBALS.EQUAL(p_header_rec.credit_card_expiration_date
                            ,p_old_header_rec.credit_card_expiration_date))
          or
           (NOT OE_GLOBALS.EQUAL(p_header_rec.check_number
                            ,p_old_header_rec.check_number))
          or
           (NOT OE_GLOBALS.EQUAL(p_header_rec.payment_amount
                            ,p_old_header_rec.payment_amount))

           THEN

            select count(payment_type_code) into l_payment_count
            from oe_payments
            where header_id = p_header_rec.header_id
            and line_id is null;

            if l_payment_count > 1 then
               l_return_status := FND_API.G_RET_STS_ERROR;

              fnd_message.Set_Name('ONT','ONT_MULTIPLE_PAYMENTS_EXIST');
              OE_MSG_PUB.Add;
              oe_debug_pub.add('Error: multiple payments exist. cannot update order header',3);

            end if;

         END IF; -- if not oe_globals.equal...

      END IF; -- if multiple_payments is enabled
*/
     --distributed orders @
      oe_debug_pub.ADD('ib_owner: '||p_header_rec.ib_owner);
     IF p_header_rec.ib_owner IS NOT NULL AND
	( NOT OE_GLOBALS.EQUAL(p_header_rec.ib_owner ,p_old_header_rec.ib_owner)
	  OR p_old_header_rec.ib_owner is null
	  OR NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_org_id, p_old_header_rec.sold_to_org_id)
	  OR NOT OE_GLOBALS.EQUAL(p_header_rec.end_customer_id, p_old_header_rec.end_customer_id)
          OR p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE)
     THEN
	IF (p_header_rec.ib_owner = 'SOLD_TO' AND
	     p_header_rec.sold_to_org_id is null)
	THEN
	   l_return_status := FND_API.G_RET_STS_ERROR;
	   fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_OWNER'));
	   OE_MSG_PUB.Add;
	  ELSIF p_header_rec.ib_owner = 'END_CUSTOMER' AND
		p_header_rec.end_customer_id is null
	  THEN
	     l_return_status := FND_API.G_RET_STS_ERROR;
	     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_OWNER'));
	     OE_MSG_PUB.Add;
	  END IF;
       END IF;
       oe_debug_pub.ADD('ib_installed_at_location: '||p_header_rec.ib_installed_at_location);

       IF p_header_rec.ib_installed_at_location IS NOT NULL AND
	  ( NOT OE_GLOBALS.EQUAL(p_header_rec.ib_installed_at_location ,p_old_header_rec.ib_installed_at_location)
	    OR p_old_header_rec.ib_installed_at_location is null
	    OR NOT OE_GLOBALS.EQUAL(p_header_rec.invoice_to_org_id ,p_old_header_rec.invoice_to_org_id)
	    OR NOT OE_GLOBALS.EQUAL(p_header_rec.ship_to_org_id ,p_old_header_rec.ship_to_org_id)
	    OR NOT OE_GLOBALS.EQUAL(p_header_rec.deliver_to_org_id ,p_old_header_rec.deliver_to_org_id)
	    OR NOT OE_GLOBALS.EQUAL(p_header_rec.end_customer_site_use_id ,p_old_header_rec.end_customer_site_use_id)
	    OR NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_site_use_id ,p_old_header_rec.sold_to_site_use_id)
            OR p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE)
       THEN
	IF (p_header_rec.ib_installed_at_location = 'BILL_TO' AND
	     p_header_rec.invoice_to_org_id is null)
	THEN
	   l_return_status := FND_API.G_RET_STS_ERROR;
	   fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
	   OE_MSG_PUB.Add;
	  ELSIF p_header_rec.ib_installed_at_location = 'SHIP_TO' AND
		p_header_rec.ship_to_org_id is null
	  THEN
	     l_return_status := FND_API.G_RET_STS_ERROR;
	     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
	     OE_MSG_PUB.Add;
	  ELSIF p_header_rec.ib_installed_at_location = 'DELIVER_TO' AND
		p_header_rec.deliver_to_org_id is null
	  THEN
	     l_return_status := FND_API.G_RET_STS_ERROR;
	     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
	     OE_MSG_PUB.Add;
	  ELSIF p_header_rec.ib_installed_at_location = 'END_CUSTOMER' AND
		p_header_rec.end_customer_site_use_id is null
	  THEN
	     l_return_status := FND_API.G_RET_STS_ERROR;
	     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
	     OE_MSG_PUB.Add;
	  ELSIF p_header_rec.ib_installed_at_location = 'SOLD_TO' AND
		p_header_rec.sold_to_site_use_id is null
	  THEN
	     l_return_status := FND_API.G_RET_STS_ERROR;
	     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
	     OE_MSG_PUB.Add;
	  END IF;
       END IF;
       oe_debug_pub.ADD('ib_current_location: '||p_header_rec.ib_current_location);

       IF p_header_rec.ib_current_location IS NOT NULL AND
	  ( NOT OE_GLOBALS.EQUAL(p_header_rec.ib_current_location ,p_old_header_rec.ib_current_location)
	    OR NOT OE_GLOBALS.EQUAL(p_header_rec.invoice_to_org_id ,p_old_header_rec.invoice_to_org_id)
	    OR NOT OE_GLOBALS.EQUAL(p_header_rec.ship_to_org_id ,p_old_header_rec.ship_to_org_id)
	    OR NOT OE_GLOBALS.EQUAL(p_header_rec.deliver_to_org_id ,p_old_header_rec.deliver_to_org_id)
	    OR NOT OE_GLOBALS.EQUAL(p_header_rec.end_customer_site_use_id ,p_old_header_rec.end_customer_site_use_id)
	    OR NOT OE_GLOBALS.EQUAL(p_header_rec.sold_to_site_use_id ,p_old_header_rec.sold_to_site_use_id)
	    OR p_old_header_rec.ib_current_location is null
            OR p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE )
       THEN
	IF (p_header_rec.ib_current_location = 'BILL_TO' AND
	     p_header_rec.invoice_to_org_id is null)
	THEN
	   l_return_status := FND_API.G_RET_STS_ERROR;
	   fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
	   OE_MSG_PUB.Add;
	  ELSIF p_header_rec.ib_current_location = 'SHIP_TO' AND
		p_header_rec.ship_to_org_id is null
	  THEN
	     l_return_status := FND_API.G_RET_STS_ERROR;
	     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
	     OE_MSG_PUB.Add;
	  ELSIF p_header_rec.ib_current_location = 'DELIVER_TO' AND
		p_header_rec.deliver_to_org_id is null
	  THEN
	     l_return_status := FND_API.G_RET_STS_ERROR;
	     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
	     OE_MSG_PUB.Add;
	  ELSIF p_header_rec.ib_current_location = 'END_CUSTOMER' AND
		p_header_rec.end_customer_site_use_id is null
	  THEN
	     l_return_status := FND_API.G_RET_STS_ERROR;
	     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
	     OE_MSG_PUB.Add;
	  ELSIF p_header_rec.ib_current_location = 'SOLD_TO' AND
		p_header_rec.sold_to_site_use_id is null
	  THEN
	     l_return_status := FND_API.G_RET_STS_ERROR;
	     fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	     FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
	     OE_MSG_PUB.Add;
	  END IF;
       END IF;

   -- IB Validation START
   -- for validating line level ib_installed_at_location
   -- and ib_current_location for all lines
   -- This should be a CORNER CASE, hence not much perf impact
   IF p_old_header_rec.sold_to_site_use_id IS NOT NULL
      and p_header_rec.sold_to_site_use_id IS NULL
      and p_old_header_rec.header_id is not null
   then
      -- okay, loop for all lines
      If l_debug_level > 0 THEN
	 oe_debug_pub.add('>sold_to_site_use_id has changed to null,');
	 oe_debug_pub.add('>checking all lines for IB validation');
      end if;

      for l in ib_lines loop
	 if l.ib_current_location='SOLD_TO'
	 then
	    If l_debug_level > 0 THEN
	       oe_debug_pub.add('>line_id:'||l.line_id||' has ib_current_location as SOLD_TO');
	    end if;
	    l_return_status := FND_API.G_RET_STS_ERROR;
	    fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_CURRENT_LOCATION'));
	    OE_MSG_PUB.Add;
	 elsif l.ib_installed_at_location='SOLD_TO'
	 then
	    If l_debug_level > 0 THEN
	       oe_debug_pub.add('>line_id:'||l.line_id||' has ib_installed_at_location as SOLD_TO');
	    end if;
	    l_return_status := FND_API.G_RET_STS_ERROR;
	    fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',OE_Order_UTIL.Get_attribute_name('IB_INSTALLED_AT_LOCATION'));
	    OE_MSG_PUB.Add;
	 end if;
      end loop;
   end if;
   If l_debug_level > 0 THEN
      oe_debug_pub.add('>IB Line validation done');
   end if;
   -- IB Validation ENDS

   --R12 CC Encryption
   IF p_header_rec.payment_type_code = 'CREDIT_CARD' THEN
	IF p_header_rec.invoice_to_org_id is NULL THEN
		l_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.SET_NAME('ONT','OE_VPM_INV_TO_REQUIRED');
		OE_MSG_PUB.ADD;
	END IF;
   END IF;
   --R12 CC Encryption
   /*
		OE_MSG_PUB.ADD;
	      	ELSIF p_header_rec.credit_card_number is NULL THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
	    		FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_NUM_REQUIRED');
	    		OE_MSG_PUB.ADD;
	     	ELSIF p_header_rec.credit_card_expiration_date is NULL THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
	   		FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_EXP_DT_REQUIRED');
	    		OE_MSG_PUB.ADD;
	    	ELSIF p_header_rec.credit_card_holder_name is NULL THEN
			l_return_status := FND_API.G_RET_STS_ERROR;
	    		FND_MESSAGE.SET_NAME('ONT','OE_VPM_CC_HOLDER_REQUIRED');
	    		OE_MSG_PUB.ADD;
	    	END IF;
    END IF;*/

    --  Done validating entity
    x_return_status := l_return_status;

    oe_debug_pub.add('Exit OE_VALIDATE_HEADER.ENTITY',1);

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
,   p_old_header_rec     IN  OE_Order_PUB.Header_Rec_Type :=
                                   OE_Order_PUB.G_MISS_HEADER_REC
,   p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
)
IS
  l_cc_security_code_use Varchar2(20);
BEGIN

    oe_debug_pub.add('Entering OE_VALIDATE_HEADER.ATTRIBUTES',1);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate header attributes
    /* Bug 5060064 - PC firing inappropriately for Order Import.
       To fix the issue we are now passing in old header rec same
       as new header rec, before calling process_order. B'cas of this
       old rec and new rec may have the same values. To make sure that
       validation is done for the attributes during CREATE added an
       additional check of
            OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
       in all the conditions.
    */

    IF  p_x_header_rec.accounting_rule_id IS NOT NULL AND
        (  ( p_x_header_rec.accounting_rule_id <>
            p_old_header_rec.accounting_rule_id OR
            p_old_header_rec.accounting_rule_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Accounting_Rule(p_x_header_rec.accounting_rule_id)
      THEN

        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.accounting_rule_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.accounting_rule_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

      END IF;

    END IF;

    IF  p_x_header_rec.accounting_rule_duration IS NOT NULL AND
        ( (p_x_header_rec.accounting_rule_duration <>
            p_old_header_rec.accounting_rule_duration OR
            p_old_header_rec.accounting_rule_duration IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Accounting_Rule_Duration(p_x_header_rec.accounting_rule_duration)
      THEN

        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.accounting_rule_duration := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.accounting_rule_duration := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

      END IF;

    END IF;

    IF  p_x_header_rec.agreement_id IS NOT NULL AND
        ( ( p_x_header_rec.agreement_id <>
            p_old_header_rec.agreement_id OR
            p_old_header_rec.agreement_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Agreement(p_x_header_rec.agreement_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.agreement_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.agreement_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    oe_debug_pub.add('sarita:p_x_header_rec.booked_flag :'||
                      p_x_header_rec.booked_flag);

    IF  p_x_header_rec.booked_flag IS NOT NULL AND
        ( ( p_x_header_rec.booked_flag <>
            p_old_header_rec.booked_flag OR
            p_old_header_rec.booked_flag IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN
      oe_debug_pub.add('sarita:before validate booked flag');

      IF NOT OE_Validate.Booked(p_x_header_rec.booked_flag)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.booked_flag := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.booked_flag := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.cancelled_flag IS NOT NULL AND
        (  (p_x_header_rec.cancelled_flag <>
            p_old_header_rec.cancelled_flag OR
            p_old_header_rec.cancelled_flag IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Cancelled(p_x_header_rec.cancelled_flag)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.cancelled_flag := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.cancelled_flag := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.conversion_type_code IS NOT NULL AND
        (  (p_x_header_rec.conversion_type_code <>
            p_old_header_rec.conversion_type_code OR
            p_old_header_rec.conversion_type_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Conversion_Type(p_x_header_rec.conversion_type_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.conversion_type_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.conversion_type_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.deliver_to_contact_id IS NOT NULL AND
        (  (p_x_header_rec.deliver_to_contact_id <>
            p_old_header_rec.deliver_to_contact_id OR
            p_old_header_rec.deliver_to_contact_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Deliver_To_Contact(p_x_header_rec.deliver_to_contact_id)      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.deliver_to_contact_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.deliver_to_contact_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.deliver_to_org_id IS NOT NULL AND
        ( ( p_x_header_rec.deliver_to_org_id <>
            p_old_header_rec.deliver_to_org_id OR
            p_old_header_rec.deliver_to_org_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Deliver_To_Org(p_x_header_rec.deliver_to_org_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.deliver_to_org_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.deliver_to_org_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.demAND_class_code IS NOT NULL AND
        (  (p_x_header_rec.demAND_class_code <>
            p_old_header_rec.demAND_class_code OR
            p_old_header_rec.demAND_class_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.DemAND_Class(p_x_header_rec.demAND_class_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.demAND_class_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.demAND_class_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.fob_point_code IS NOT NULL AND
        ( ( p_x_header_rec.fob_point_code <>
            p_old_header_rec.fob_point_code OR
            p_old_header_rec.fob_point_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Fob_Point(p_x_header_rec.fob_point_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.fob_point_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.fob_point_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.freight_terms_code IS NOT NULL AND
        (  (p_x_header_rec.freight_terms_code <>
            p_old_header_rec.freight_terms_code OR
            p_old_header_rec.freight_terms_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Freight_Terms(p_x_header_rec.freight_terms_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.freight_terms_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.freight_terms_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.invoice_to_contact_id IS NOT NULL AND
        (  (p_x_header_rec.invoice_to_contact_id <>
            p_old_header_rec.invoice_to_contact_id OR
            p_old_header_rec.invoice_to_contact_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Invoice_To_Contact(p_x_header_rec.invoice_to_contact_id)      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.invoice_to_contact_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.invoice_to_contact_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.invoice_to_org_id IS NOT NULL AND
        (  (p_x_header_rec.invoice_to_org_id <>
            p_old_header_rec.invoice_to_org_id OR
            p_old_header_rec.invoice_to_org_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Invoice_To_Org(p_x_header_rec.invoice_to_org_id)
      THEN
       IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
          p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
       THEN
          p_x_header_rec.invoice_to_org_id := NULL;
       ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
             p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
       THEN
         p_x_header_rec.invoice_to_org_id := FND_API.G_MISS_NUM;
       ELSE
         x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
     END IF;

    END IF;

    IF  p_x_header_rec.invoicing_rule_id IS NOT NULL AND
        ( ( p_x_header_rec.invoicing_rule_id <>
            p_old_header_rec.invoicing_rule_id OR
            p_old_header_rec.invoicing_rule_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Invoicing_Rule(p_x_header_rec.invoicing_rule_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.invoicing_rule_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.invoicing_rule_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.open_flag IS NOT NULL AND
        (  (p_x_header_rec.open_flag <>
            p_old_header_rec.open_flag OR
            p_old_header_rec.open_flag IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Open(p_x_header_rec.open_flag)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.open_flag := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.open_flag := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.order_date_type_code IS NOT NULL AND
        (  (p_x_header_rec.order_date_type_code <>
            p_old_header_rec.order_date_type_code OR
            p_old_header_rec.order_date_type_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Order_Date_Type_Code
                         (p_x_header_rec.order_date_type_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.order_date_type_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.order_date_type_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    oe_debug_pub.add('sarita: p_x_header_rec.order_type_id:'||
                        p_x_header_rec.order_type_id);
    oe_debug_pub.add('sarita: p_old_header_rec.order_type_id:'||
                        p_old_header_rec.order_type_id);

    IF  p_x_header_rec.order_type_id IS NOT NULL AND
        (  (p_x_header_rec.order_type_id <>
            p_old_header_rec.order_type_id OR
            p_old_header_rec.order_type_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN
      oe_debug_pub.add('Before OE_Validate.Order_Type');

      IF NOT OE_Validate.Order_Type(p_x_header_rec.order_type_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.order_type_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.order_type_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.payment_term_id IS NOT NULL AND
        (  (p_x_header_rec.payment_term_id <>
            p_old_header_rec.payment_term_id OR
            p_old_header_rec.payment_term_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Payment_Term(p_x_header_rec.payment_term_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.payment_term_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.payment_term_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.price_list_id IS NOT NULL AND
        (  (p_x_header_rec.price_list_id <>
            p_old_header_rec.price_list_id OR
            p_old_header_rec.price_list_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Price_List(p_x_header_rec.price_list_id)
      THEN
      -- Bug 3572931 Commented the code below.
      -- p_x_header_rec.price_list_id := NULL;
      -- ELSE
      -- IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
      --   p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
      -- THEN
      --  x_return_status := FND_API.G_RET_STS_ERROR;
      -- END IF;
      -- Bug 3572931 if the validation level is partial set to NULL,
      -- if partial with defaulting set to G_MISS_NUM.
         IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
         THEN
              p_x_header_rec.price_list_id := NULL;
	 ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
         THEN
              p_x_header_rec.price_list_id := FND_API.G_MISS_NUM;
         ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.shipment_priority_code IS NOT NULL AND
        (  (p_x_header_rec.shipment_priority_code <>
            p_old_header_rec.shipment_priority_code OR
            p_old_header_rec.shipment_priority_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Shipment_Priority(p_x_header_rec.shipment_priority_code)      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.shipment_priority_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.shipment_priority_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.shipping_method_code IS NOT NULL AND
        (  (p_x_header_rec.shipping_method_code <>
            p_old_header_rec.shipping_method_code OR
            p_old_header_rec.shipping_method_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Shipping_Method(p_x_header_rec.shipping_method_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.shipping_method_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.shipping_method_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.ship_from_org_id IS NOT NULL AND
        (  (p_x_header_rec.ship_from_org_id <>
            p_old_header_rec.ship_from_org_id OR
            p_old_header_rec.ship_from_org_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Ship_From_Org(p_x_header_rec.ship_from_org_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.ship_from_org_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.ship_from_org_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.ship_to_contact_id IS NOT NULL AND
        (  (p_x_header_rec.ship_to_contact_id <>
            p_old_header_rec.ship_to_contact_id OR
            p_old_header_rec.ship_to_contact_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Ship_To_Contact(p_x_header_rec.ship_to_contact_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.ship_to_contact_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.ship_to_contact_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.ship_to_org_id IS NOT NULL AND
        (  (p_x_header_rec.ship_to_org_id <>
            p_old_header_rec.ship_to_org_id OR
            p_old_header_rec.ship_to_org_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Ship_To_Org(p_x_header_rec.ship_to_org_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.ship_to_org_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.ship_to_org_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;


    IF  p_x_header_rec.sold_to_contact_id IS NOT NULL AND
        (  (p_x_header_rec.sold_to_contact_id <>
            p_old_header_rec.sold_to_contact_id OR
            p_old_header_rec.sold_to_contact_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Sold_To_Contact(p_x_header_rec.sold_to_contact_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.sold_to_contact_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.sold_to_contact_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.sold_to_org_id IS NOT NULL AND
        (  (p_x_header_rec.sold_to_org_id <>
            p_old_header_rec.sold_to_org_id OR
            p_old_header_rec.sold_to_org_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Sold_To_Org(p_x_header_rec.sold_to_org_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.sold_to_org_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.sold_to_org_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.sold_to_phone_id IS NOT NULL AND
        (  (p_x_header_rec.sold_to_phone_id <>
            p_old_header_rec.sold_to_phone_id OR
            p_old_header_rec.sold_to_phone_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Sold_To_Phone(p_x_header_rec.sold_to_phone_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.sold_to_phone_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.sold_to_phone_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.source_document_type_id IS NOT NULL AND
        (  (p_x_header_rec.source_document_type_id <>
            p_old_header_rec.source_document_type_id OR
            p_old_header_rec.source_document_type_id IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

        IF NOT OE_Validate.Source_Document_Type
                           (p_x_header_rec.source_document_type_id)
        THEN
          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
          THEN
            p_x_header_rec.source_document_type_id := NULL;
          ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
                p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
          THEN
            p_x_header_rec.source_document_type_id := FND_API.G_MISS_NUM;
          ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
        END IF;

    END IF;

    IF  p_x_header_rec.tax_exempt_flag IS NOT NULL AND
        (  (p_x_header_rec.tax_exempt_flag <>
            p_old_header_rec.tax_exempt_flag OR
            p_old_header_rec.tax_exempt_flag IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN
      IF NOT OE_Validate.Tax_Exempt(p_x_header_rec.tax_exempt_flag)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.tax_exempt_flag := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.tax_exempt_flag := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.tax_exempt_reason_code IS NOT NULL AND
        (  (p_x_header_rec.tax_exempt_reason_code <>
            p_old_header_rec.tax_exempt_reason_code OR
            p_old_header_rec.tax_exempt_reason_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Tax_Exempt_Reason
                         (p_x_header_rec.tax_exempt_reason_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.tax_exempt_reason_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.tax_point_code IS NOT NULL AND
        ( ( p_x_header_rec.tax_point_code <>
            p_old_header_rec.tax_point_code OR
            p_old_header_rec.tax_point_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Tax_Point(p_x_header_rec.tax_point_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.tax_point_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.tax_point_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.transactional_curr_code IS NOT NULL AND
        (  (p_x_header_rec.transactional_curr_code <>
            p_old_header_rec.transactional_curr_code OR
            p_old_header_rec.transactional_curr_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Transactional_Curr
                         (p_x_header_rec.transactional_curr_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.transactional_curr_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.transactional_curr_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    IF  p_x_header_rec.payment_type_code IS NOT NULL AND
        (  (p_x_header_rec.payment_type_code <>
            p_old_header_rec.payment_type_code OR
            p_old_header_rec.payment_type_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Payment_Type(p_x_header_rec.payment_type_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.payment_type_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.payment_type_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    oe_debug_pub.add('after payment_type_code');

    IF  p_x_header_rec.credit_card_code IS NOT NULL AND
        ( ( p_x_header_rec.credit_card_code <>
            p_old_header_rec.credit_card_code OR
            p_old_header_rec.credit_card_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN
      IF NOT OE_Validate.Credit_Card(p_x_header_rec.credit_card_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.credit_card_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.credit_card_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    oe_debug_pub.add('after credit_card_code');

    --R12 CVV2
    IF p_x_header_rec.credit_card_number IS NOT NULL AND p_x_header_rec.credit_card_number <> FND_API.G_MISS_CHAR THEN
      l_cc_security_code_use := OE_Payment_Trxn_Util.Get_CC_Security_Code_Use;
      IF l_cc_security_code_use = 'REQUIRED' THEN
         IF p_x_header_rec.instrument_security_code IS NULL OR p_x_header_rec.instrument_security_code = FND_API.G_MISS_CHAR THEN --bug 4613168, issue 22
            FND_MESSAGE.SET_NAME('ONT','OE_CC_SECURITY_CODE_REQD');
            OE_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      END IF;
    END IF;
    --R12 CVV2

    oe_debug_pub.add('after security code');

    IF  p_x_header_rec.flow_status_code IS NOT NULL AND
        (  (p_x_header_rec.flow_status_code <>
            p_old_header_rec.flow_status_code OR
            p_old_header_rec.flow_status_code IS NULL ) OR
           ( p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ))
        --bug 5060064
    THEN

      IF NOT OE_Validate.Flow_Status(p_x_header_rec.flow_status_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.flow_status_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.flow_status_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    oe_Debug_pub.add('after flow_status_code');
   if OE_GLOBALS.g_validate_desc_flex ='Y' then -- bug4343612
      oe_debug_pub.add('Validation of desc flex is set to Y in OE_Validate_Header.attributes ',1);
    IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE OR

    (  p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
         (p_x_header_rec.attribute1 IS NOT NULL AND
        (   p_x_header_rec.attribute1 <>
            p_old_header_rec.attribute1 OR
            p_old_header_rec.attribute1 IS NULL ))
    OR  (p_x_header_rec.attribute10 IS NOT NULL AND
        (   p_x_header_rec.attribute10 <>
            p_old_header_rec.attribute10 OR
            p_old_header_rec.attribute10 IS NULL ))
    OR  (p_x_header_rec.attribute11 IS NOT NULL AND
        (   p_x_header_rec.attribute11 <>
            p_old_header_rec.attribute11 OR
            p_old_header_rec.attribute11 IS NULL ))
    OR  (p_x_header_rec.attribute12 IS NOT NULL AND
        (   p_x_header_rec.attribute12 <>
            p_old_header_rec.attribute12 OR
            p_old_header_rec.attribute12 IS NULL ))
    OR  (p_x_header_rec.attribute13 IS NOT NULL AND
        (   p_x_header_rec.attribute13 <>
            p_old_header_rec.attribute13 OR
            p_old_header_rec.attribute13 IS NULL ))
    OR  (p_x_header_rec.attribute14 IS NOT NULL AND
        (   p_x_header_rec.attribute14 <>
            p_old_header_rec.attribute14 OR
            p_old_header_rec.attribute14 IS NULL ))
    OR  (p_x_header_rec.attribute15 IS NOT NULL AND
        (   p_x_header_rec.attribute15 <>
            p_old_header_rec.attribute15 OR
            p_old_header_rec.attribute15 IS NULL ))
    OR  (p_x_header_rec.attribute16 IS NOT NULL AND --For bug 2184255
        (   p_x_header_rec.attribute16 <>
            p_old_header_rec.attribute16 OR
            p_old_header_rec.attribute16 IS NULL ))
    OR  (p_x_header_rec.attribute17 IS NOT NULL AND
        (   p_x_header_rec.attribute17 <>
            p_old_header_rec.attribute17 OR
            p_old_header_rec.attribute17 IS NULL ))
    OR  (p_x_header_rec.attribute18 IS NOT NULL AND
        (   p_x_header_rec.attribute18 <>
            p_old_header_rec.attribute18 OR
            p_old_header_rec.attribute18 IS NULL ))
    OR  (p_x_header_rec.attribute19 IS NOT NULL AND
        (   p_x_header_rec.attribute19 <>
            p_old_header_rec.attribute19 OR
            p_old_header_rec.attribute19 IS NULL ))
    OR  (p_x_header_rec.attribute2 IS NOT NULL AND
        (   p_x_header_rec.attribute2 <>
            p_old_header_rec.attribute2 OR
            p_old_header_rec.attribute2 IS NULL ))
    OR  (p_x_header_rec.attribute20 IS NOT NULL AND  -- for bug 2184255
        (   p_x_header_rec.attribute20 <>
            p_old_header_rec.attribute20 OR
            p_old_header_rec.attribute20 IS NULL ))
    OR  (p_x_header_rec.attribute3 IS NOT NULL AND
        (   p_x_header_rec.attribute3 <>
            p_old_header_rec.attribute3 OR
            p_old_header_rec.attribute3 IS NULL ))
    OR  (p_x_header_rec.attribute4 IS NOT NULL AND
        (   p_x_header_rec.attribute4 <>
            p_old_header_rec.attribute4 OR
            p_old_header_rec.attribute4 IS NULL ))
    OR  (p_x_header_rec.attribute5 IS NOT NULL AND
        (   p_x_header_rec.attribute5 <>
            p_old_header_rec.attribute5 OR
            p_old_header_rec.attribute5 IS NULL ))
    OR  (p_x_header_rec.attribute6 IS NOT NULL AND
        (   p_x_header_rec.attribute6 <>
            p_old_header_rec.attribute6 OR
            p_old_header_rec.attribute6 IS NULL ))
    OR  (p_x_header_rec.attribute7 IS NOT NULL AND
        (   p_x_header_rec.attribute7 <>
            p_old_header_rec.attribute7 OR
            p_old_header_rec.attribute7 IS NULL ))
    OR  (p_x_header_rec.attribute8 IS NOT NULL AND
        (   p_x_header_rec.attribute8 <>
            p_old_header_rec.attribute8 OR
            p_old_header_rec.attribute8 IS NULL ))
    OR  (p_x_header_rec.attribute9 IS NOT NULL AND
        (   p_x_header_rec.attribute9 <>
            p_old_header_rec.attribute9 OR
            p_old_header_rec.attribute9 IS NULL ))
    OR  (p_x_header_rec.context IS NOT NULL AND
        (   p_x_header_rec.context <>
            p_old_header_rec.context OR
            p_old_header_rec.context IS NULL )))
    THEN


         oe_debug_pub.add('Before calling header_desc_flex',2);
         oe_debug_pub.add('source doc type:'||to_char(p_x_header_rec.source_document_type_id),5);
         /*  Fixing 2375476 to skip the Flex field validation in case of
             Internal Orders. This condition will be removed once process Order
             starts defaulting the FF */
         /*  Fixing 2611912 to skip the Flex field validation in case of
             orders coming from CRM. This condition can be removed once process Order
             starts defaulting the FF */
	IF OE_ORDER_CACHE.IS_FLEX_ENABLED('OE_HEADER_ATTRIBUTES') = 'Y' THEN
        -- AND p_x_header_rec.order_source_id <> 10 AND -- added for 2611912
--             (p_x_header_rec.source_document_type_id IS NULL OR
--              p_x_header_rec.source_document_type_id = FND_API.G_MISS_NUM OR
--              p_x_header_rec.source_document_type_id = 2) THEN
-- commented above, bug 2511313

         IF NOT OE_VALIDATE.Header_Desc_Flex
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

            IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
               p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
            THEN
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


            ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
                  p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
            THEN
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


            ELSE
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
	  ELSE -- if the flex validation is successfull
	    -- For bug 2511313
	    IF p_x_header_rec.context IS NULL
	      OR p_x_header_rec.context = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.context    := oe_validate.g_context;
	    END IF;

	    IF p_x_header_rec.attribute1 IS NULL
	      OR p_x_header_rec.attribute1 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute1 := oe_validate.g_attribute1;
	    END IF;

	    IF p_x_header_rec.attribute2 IS NULL
	      OR p_x_header_rec.attribute2 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute2 := oe_validate.g_attribute2;
	    END IF;

	    IF p_x_header_rec.attribute3 IS NULL
	      OR p_x_header_rec.attribute3 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute3 := oe_validate.g_attribute3;
	    END IF;

	    IF p_x_header_rec.attribute4 IS NULL
	      OR p_x_header_rec.attribute4 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute4 := oe_validate.g_attribute4;
	    END IF;

	    IF p_x_header_rec.attribute5 IS NULL
	      OR p_x_header_rec.attribute5 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute5 := oe_validate.g_attribute5;
	    END IF;

	    IF p_x_header_rec.attribute6 IS NULL
	      OR p_x_header_rec.attribute6 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute6 := oe_validate.g_attribute6;
	    END IF;

	    IF p_x_header_rec.attribute7 IS NULL
	      OR p_x_header_rec.attribute7 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute7 := oe_validate.g_attribute7;
	    END IF;

	    IF p_x_header_rec.attribute8 IS NULL
	      OR p_x_header_rec.attribute8 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute8 := oe_validate.g_attribute8;
	    END IF;

	    IF p_x_header_rec.attribute9 IS NULL
	      OR p_x_header_rec.attribute9 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute9 := oe_validate.g_attribute9;
	    END IF;

	    IF p_x_header_rec.attribute10 IS NULL
	      OR p_x_header_rec.attribute10 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute10 := Oe_validate.G_attribute10;
	    End IF;

	    IF p_x_header_rec.attribute11 IS NULL
	      OR p_x_header_rec.attribute11 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute11 := oe_validate.g_attribute11;
	    END IF;

	    IF p_x_header_rec.attribute12 IS NULL
	      OR p_x_header_rec.attribute12 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute12 := oe_validate.g_attribute12;
	    END IF;

	    IF p_x_header_rec.attribute13 IS NULL
	      OR p_x_header_rec.attribute13 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute13 := oe_validate.g_attribute13;
	    END IF;

	    IF p_x_header_rec.attribute14 IS NULL
	      OR p_x_header_rec.attribute14 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute14 := oe_validate.g_attribute14;
	    END IF;

	    IF p_x_header_rec.attribute15 IS NULL
	      OR p_x_header_rec.attribute15 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute15 := oe_validate.g_attribute15;
	    END IF;

	    IF p_x_header_rec.attribute16 IS NULL  -- for bug 2184255
	      OR p_x_header_rec.attribute16 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute16 := oe_validate.g_attribute16;
	    END IF;

	    IF p_x_header_rec.attribute17 IS NULL
	      OR p_x_header_rec.attribute17 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute17 := oe_validate.g_attribute17;
	    END IF;

	    IF p_x_header_rec.attribute18 IS NULL
	      OR p_x_header_rec.attribute18 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute18 := oe_validate.g_attribute18;
	    END IF;

	    IF p_x_header_rec.attribute19 IS NULL
	      OR p_x_header_rec.attribute19 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute19 := oe_validate.g_attribute19;
	    END IF;

	    IF p_x_header_rec.attribute20 IS NULL
	      OR p_x_header_rec.attribute20 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.attribute20 := oe_validate.g_attribute20;
	    END IF;

	    -- end of assignments, bug 2511313
	 END IF;
	END IF ; -- If flex enabled
    END IF;

    oe_debug_pub.add('After header_desc_flex  ' || x_return_status,2);
	IF p_x_header_rec.operation = oe_globals.g_opr_create OR
    ( p_x_header_rec.operation = oe_globals.g_opr_update AND
      (p_x_header_rec.global_attribute1 IS NOT NULL AND
        (   p_x_header_rec.global_attribute1 <>
            p_old_header_rec.global_attribute1 OR
            p_old_header_rec.global_attribute1 IS NULL ))
    OR  (p_x_header_rec.global_attribute10 IS NOT NULL AND
        (   p_x_header_rec.global_attribute10 <>
            p_old_header_rec.global_attribute10 OR
            p_old_header_rec.global_attribute10 IS NULL ))
    OR  (p_x_header_rec.global_attribute11 IS NOT NULL AND
        (   p_x_header_rec.global_attribute11 <>
            p_old_header_rec.global_attribute11 OR
            p_old_header_rec.global_attribute11 IS NULL ))
    OR  (p_x_header_rec.global_attribute12 IS NOT NULL AND
        (   p_x_header_rec.global_attribute12 <>
            p_old_header_rec.global_attribute12 OR
            p_old_header_rec.global_attribute12 IS NULL ))
    OR  (p_x_header_rec.global_attribute13 IS NOT NULL AND
        (   p_x_header_rec.global_attribute13 <>
            p_old_header_rec.global_attribute13 OR
            p_old_header_rec.global_attribute13 IS NULL ))
    OR  (p_x_header_rec.global_attribute14 IS NOT NULL AND
        (   p_x_header_rec.global_attribute14 <>
            p_old_header_rec.global_attribute14 OR
            p_old_header_rec.global_attribute14 IS NULL ))
    OR  (p_x_header_rec.global_attribute15 IS NOT NULL AND
        (   p_x_header_rec.global_attribute15 <>
            p_old_header_rec.global_attribute15 OR
            p_old_header_rec.global_attribute15 IS NULL ))
    OR  (p_x_header_rec.global_attribute16 IS NOT NULL AND
        (   p_x_header_rec.global_attribute16 <>
            p_old_header_rec.global_attribute16 OR
            p_old_header_rec.global_attribute16 IS NULL ))
    OR  (p_x_header_rec.global_attribute17 IS NOT NULL AND
        (   p_x_header_rec.global_attribute17 <>
            p_old_header_rec.global_attribute17 OR
            p_old_header_rec.global_attribute17 IS NULL ))
    OR  (p_x_header_rec.global_attribute18 IS NOT NULL AND
        (   p_x_header_rec.global_attribute18 <>
            p_old_header_rec.global_attribute18 OR
            p_old_header_rec.global_attribute18 IS NULL ))
    OR  (p_x_header_rec.global_attribute19 IS NOT NULL AND
        (   p_x_header_rec.global_attribute19 <>
            p_old_header_rec.global_attribute19 OR
            p_old_header_rec.global_attribute19 IS NULL ))
    OR  (p_x_header_rec.global_attribute2 IS NOT NULL AND
        (   p_x_header_rec.global_attribute2 <>
            p_old_header_rec.global_attribute2 OR
            p_old_header_rec.global_attribute2 IS NULL ))
    OR  (p_x_header_rec.global_attribute20 IS NOT NULL AND
        (   p_x_header_rec.global_attribute20 <>
            p_old_header_rec.global_attribute20 OR
            p_old_header_rec.global_attribute20 IS NULL ))
    OR  (p_x_header_rec.global_attribute3 IS NOT NULL AND
        (   p_x_header_rec.global_attribute3 <>
            p_old_header_rec.global_attribute3 OR
            p_old_header_rec.global_attribute3 IS NULL ))
    OR  (p_x_header_rec.global_attribute4 IS NOT NULL AND
        (   p_x_header_rec.global_attribute4 <>
            p_old_header_rec.global_attribute4 OR
            p_old_header_rec.global_attribute4 IS NULL ))
    OR  (p_x_header_rec.global_attribute5 IS NOT NULL AND
        (   p_x_header_rec.global_attribute5 <>
            p_old_header_rec.global_attribute5 OR
            p_old_header_rec.global_attribute5 IS NULL ))
    OR  (p_x_header_rec.global_attribute6 IS NOT NULL AND
        (   p_x_header_rec.global_attribute6 <>
            p_old_header_rec.global_attribute6 OR
            p_old_header_rec.global_attribute6 IS NULL ))
    OR  (p_x_header_rec.global_attribute7 IS NOT NULL AND
        (   p_x_header_rec.global_attribute7 <>
            p_old_header_rec.global_attribute7 OR
            p_old_header_rec.global_attribute7 IS NULL ))
    OR  (p_x_header_rec.global_attribute8 IS NOT NULL AND
        (   p_x_header_rec.global_attribute8 <>
            p_old_header_rec.global_attribute8 OR
            p_old_header_rec.global_attribute8 IS NULL ))
    OR  (p_x_header_rec.global_attribute9 IS NOT NULL AND
        (   p_x_header_rec.global_attribute9 <>
            p_old_header_rec.global_attribute9 OR
            p_old_header_rec.global_attribute9 IS NULL ))
    OR  (p_x_header_rec.global_attribute_category IS NOT NULL AND
        (   p_x_header_rec.global_attribute_category <>
            p_old_header_rec.global_attribute_category OR
            p_old_header_rec.global_attribute_category IS NULL )))
    THEN



          OE_DEBUG_PUB.ADD('Before G_header_desc_flex',2);
          /*  Fixing 2375476 to skip the Flex field validation in case of
             Internal Orders. This condition will be removed once process Order
             starts defaulting the FF */
    IF OE_ORDER_CACHE.IS_FLEX_ENABLED('OE_HEADER_GLOBAL_ATTRIBUTE') = 'Y' THEN
--    AND p_x_header_rec.order_source_id <> 10 THEN
          IF NOT OE_VALIDATE.G_Header_Desc_Flex
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

            IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
               p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
            THEN

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

            ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
                  p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
            THEN

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

            ELSE
                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
	   ELSE -- for bug 2511313
	        IF p_x_header_rec.global_attribute_category IS NULL
		  OR p_x_header_rec.global_attribute_category = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute_category := oe_validate.g_context;
		END IF;

		IF p_x_header_rec.global_attribute1 IS NULL
		  OR p_x_header_rec.global_attribute1 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute1 := oe_validate.g_attribute1;
		END IF;

		IF p_x_header_rec.global_attribute2 IS NULL
		  OR p_x_header_rec.global_attribute2 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute2 := oe_validate.g_attribute2;
		END IF;

		IF p_x_header_rec.global_attribute3 IS NULL
		  OR p_x_header_rec.global_attribute3 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute3 := oe_validate.g_attribute3;
		END IF;

		IF p_x_header_rec.global_attribute4 IS NULL
		  OR p_x_header_rec.global_attribute4 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute4 := oe_validate.g_attribute4;
		END IF;

		IF p_x_header_rec.global_attribute5 IS NULL
		  OR p_x_header_rec.global_attribute5 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute5 := oe_validate.g_attribute5;
		END IF;

		IF p_x_header_rec.global_attribute6 IS NULL
		  OR p_x_header_rec.global_attribute6 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute6 := oe_validate.g_attribute6;
		END IF;

		IF p_x_header_rec.global_attribute7 IS NULL
		  OR p_x_header_rec.global_attribute7 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute7 := oe_validate.g_attribute7;
		END IF;

		IF p_x_header_rec.global_attribute8 IS NULL
		  OR p_x_header_rec.global_attribute8 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute8 := oe_validate.g_attribute8;
		END IF;

		IF p_x_header_rec.global_attribute9 IS NULL
		  OR p_x_header_rec.global_attribute9 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute9 := oe_validate.g_attribute9;
		END IF;

		IF p_x_header_rec.global_attribute11 IS NULL
		  OR p_x_header_rec.global_attribute11 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute11 := oe_validate.g_attribute11;
		END IF;

		IF p_x_header_rec.global_attribute12 IS NULL
		  OR p_x_header_rec.global_attribute12 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute12 := oe_validate.g_attribute12;
		END IF;

		IF p_x_header_rec.global_attribute13 IS NULL
		  OR p_x_header_rec.global_attribute13 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute13 := oe_validate.g_attribute13;
		END IF;

		IF p_x_header_rec.global_attribute14 IS NULL
		  OR p_x_header_rec.global_attribute14 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute14 := oe_validate.g_attribute14;
		END IF;

		IF p_x_header_rec.global_attribute15 IS NULL
		  OR p_x_header_rec.global_attribute15 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute15 := oe_validate.g_attribute15;
		END IF;

		IF p_x_header_rec.global_attribute16 IS NULL
		  OR p_x_header_rec.global_attribute16 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute16 := oe_validate.g_attribute16;
		END IF;

		IF p_x_header_rec.global_attribute17 IS NULL
		  OR p_x_header_rec.global_attribute17 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute17 := oe_validate.g_attribute17;
		END IF;

		IF p_x_header_rec.global_attribute18 IS NULL
		  OR p_x_header_rec.global_attribute18 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute18 := oe_validate.g_attribute18;
		END IF;

		IF p_x_header_rec.global_attribute19 IS NULL
		  OR p_x_header_rec.global_attribute19 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute19 := oe_validate.g_attribute19;
		END IF;

		IF p_x_header_rec.global_attribute20 IS NULL
		  OR p_x_header_rec.global_attribute20 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute20 := oe_validate.g_attribute20;
		END IF;

		IF p_x_header_rec.global_attribute10 IS NULL
		  OR p_x_header_rec.global_attribute10 = FND_API.G_MISS_CHAR THEN
		   p_x_header_rec.global_attribute10 := oe_validate.g_attribute10;
		END IF;
		-- end of bug 2511313
         END IF;
	END IF; -- Enabled
   END IF;

   OE_DEBUG_PUB.ADD('After G_header_desc_flex ' || x_return_status,2);

   -- Added the Trading Partner Flex Validation and also the changes for defaulting
   -- for bug 2511313

   IF  p_x_header_rec.operation = oe_globals.g_opr_create OR
     (  p_x_header_rec.operation = oe_globals.g_opr_update  AND
	(p_x_header_rec.tp_attribute1 IS NOT NULL AND
	 (   p_x_header_rec.tp_attribute1 <>
	     p_old_header_rec.tp_attribute1 OR
	     p_old_header_rec.tp_attribute1 IS NULL ))
    OR  (p_x_header_rec.tp_attribute2 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute2 <>
            p_old_header_rec.tp_attribute2 OR
            p_old_header_rec.tp_attribute2 IS NULL ))
    OR  (p_x_header_rec.tp_attribute3 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute3 <>
            p_old_header_rec.tp_attribute3 OR
            p_old_header_rec.tp_attribute3 IS NULL ))
    OR  (p_x_header_rec.tp_attribute4 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute4 <>
            p_old_header_rec.tp_attribute4 OR
            p_old_header_rec.tp_attribute4 IS NULL ))
    OR  (p_x_header_rec.tp_attribute5 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute5 <>
            p_old_header_rec.tp_attribute5 OR
            p_old_header_rec.tp_attribute5 IS NULL ))
    OR  (p_x_header_rec.tp_attribute6 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute6 <>
            p_old_header_rec.tp_attribute6 OR
            p_old_header_rec.tp_attribute6 IS NULL ))
    OR  (p_x_header_rec.tp_attribute7 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute7 <>
            p_old_header_rec.tp_attribute7 OR
            p_old_header_rec.tp_attribute7 IS NULL ))
    OR  (p_x_header_rec.tp_attribute8 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute8 <>
            p_old_header_rec.tp_attribute8 OR
            p_old_header_rec.tp_attribute8 IS NULL ))
    OR  (p_x_header_rec.tp_attribute9 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute9 <>
            p_old_header_rec.tp_attribute9 OR
            p_old_header_rec.tp_attribute9 IS NULL ))
    OR  (p_x_header_rec.tp_attribute10 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute10 <>
            p_old_header_rec.tp_attribute10 OR
            p_old_header_rec.tp_attribute10 IS NULL ))
    OR  (p_x_header_rec.tp_attribute11 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute11 <>
            p_old_header_rec.tp_attribute11 OR
            p_old_header_rec.tp_attribute11 IS NULL ))
    OR  (p_x_header_rec.tp_attribute12 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute12 <>
            p_old_header_rec.tp_attribute12 OR
            p_old_header_rec.tp_attribute12 IS NULL ))
    OR  (p_x_header_rec.tp_attribute13 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute13 <>
            p_old_header_rec.tp_attribute13 OR
            p_old_header_rec.tp_attribute13 IS NULL ))
    OR  (p_x_header_rec.tp_attribute14 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute14 <>
            p_old_header_rec.tp_attribute14 OR
            p_old_header_rec.tp_attribute14 IS NULL ))
    OR  (p_x_header_rec.tp_attribute15 IS NOT NULL AND
        (   p_x_header_rec.tp_attribute15 <>
            p_old_header_rec.tp_attribute15 OR
            p_old_header_rec.tp_attribute15 IS NULL )))

    THEN

       IF Oe_Order_Cache.IS_FLEX_ENABLED('OE_HEADER_TP_ATTRIBUTES') = 'Y' THEN
         IF NOT OE_VALIDATE.TP_Header_Desc_Flex
          (p_context            => p_x_header_rec.tp_context
          ,p_attribute1         => p_x_header_rec.tp_attribute1
          ,p_attribute2         => p_x_header_rec.tp_attribute2
          ,p_attribute3         => p_x_header_rec.tp_attribute3
          ,p_attribute4         => p_x_header_rec.tp_attribute4
          ,p_attribute5         => p_x_header_rec.tp_attribute5
          ,p_attribute6         => p_x_header_rec.tp_attribute6
          ,p_attribute7         => p_x_header_rec.tp_attribute7
          ,p_attribute8         => p_x_header_rec.tp_attribute8
          ,p_attribute9         => p_x_header_rec.tp_attribute9
          ,p_attribute10        => p_x_header_rec.tp_attribute10
          ,p_attribute11        => p_x_header_rec.tp_attribute11
          ,p_attribute12        => p_x_header_rec.tp_attribute12
          ,p_attribute13        => p_x_header_rec.tp_attribute13
          ,p_attribute14        => p_x_header_rec.tp_attribute14
          ,p_attribute15        => p_x_header_rec.tp_attribute15) THEN

          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE   THEN


                p_x_header_rec.tp_context    := null;
                p_x_header_rec.tp_attribute1 := null;
                p_x_header_rec.tp_attribute2 := null;
                p_x_header_rec.tp_attribute3 := null;
                p_x_header_rec.tp_attribute4 := null;
                p_x_header_rec.tp_attribute5 := null;
                p_x_header_rec.tp_attribute6 := null;
                p_x_header_rec.tp_attribute7 := null;
                p_x_header_rec.tp_attribute8 := null;
                p_x_header_rec.tp_attribute9 := null;
                p_x_header_rec.tp_attribute10 := null;
                p_x_header_rec.tp_attribute11 := null;
                p_x_header_rec.tp_attribute12 := null;
                p_x_header_rec.tp_attribute13 := null;
                p_x_header_rec.tp_attribute14 := null;
                p_x_header_rec.tp_attribute15 := null;

        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
           p_x_header_rec.operation =OE_GLOBALS.G_OPR_CREATE THEN

                p_x_header_rec.tp_context    := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute1 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute2 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute3 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute4 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute5 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute6 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute7 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute8 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute9 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute10 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute11 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute12 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute13 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute14 := FND_API.G_MISS_CHAR;
                p_x_header_rec.tp_attribute15 := FND_API.G_MISS_CHAR;
	   ELSE
	     x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

	  ELSE

	    IF p_x_header_rec.tp_context IS NULL
	      OR p_x_header_rec.tp_context = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_context    := oe_validate.g_context;
	    END IF;

	    IF p_x_header_rec.tp_attribute1 IS NULL
	      OR p_x_header_rec.tp_attribute1 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute1 := oe_validate.g_attribute1;
	    END IF;

	    IF p_x_header_rec.tp_attribute2 IS NULL
	      OR p_x_header_rec.tp_attribute2 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute2 := oe_validate.g_attribute2;
	    END IF;

	    IF p_x_header_rec.tp_attribute3 IS NULL
	      OR p_x_header_rec.tp_attribute3 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute3 := oe_validate.g_attribute3;
	    END IF;

	    IF p_x_header_rec.tp_attribute4 IS NULL
	      OR p_x_header_rec.tp_attribute4 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute4 := oe_validate.g_attribute4;
	    END IF;

	    IF p_x_header_rec.tp_attribute5 IS NULL
	      OR p_x_header_rec.tp_attribute5 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute5 := oe_validate.g_attribute5;
	    END IF;

	    IF p_x_header_rec.tp_attribute6 IS NULL
	      OR p_x_header_rec.tp_attribute6 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute6 := oe_validate.g_attribute6;
	    END IF;

	    IF p_x_header_rec.tp_attribute7 IS NULL
	      OR p_x_header_rec.tp_attribute7 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute7 := oe_validate.g_attribute7;
	    END IF;

	    IF p_x_header_rec.tp_attribute8 IS NULL
	      OR p_x_header_rec.tp_attribute8 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute8 := oe_validate.g_attribute8;
	    END IF;

	    IF p_x_header_rec.tp_attribute9 IS NULL
	      OR p_x_header_rec.tp_attribute9 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute9 := oe_validate.g_attribute9;
	    END IF;

	    IF p_x_header_rec.tp_attribute10 IS NULL
	      OR p_x_header_rec.tp_attribute10 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute10 := Oe_validate.G_attribute10;
	    End IF;

	    IF p_x_header_rec.tp_attribute11 IS NULL
	      OR p_x_header_rec.tp_attribute11 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute11 := oe_validate.g_attribute11;
	    END IF;

	    IF p_x_header_rec.tp_attribute12 IS NULL
	      OR p_x_header_rec.tp_attribute12 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute12 := oe_validate.g_attribute12;
	    END IF;

	    IF p_x_header_rec.tp_attribute13 IS NULL
	      OR p_x_header_rec.tp_attribute13 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute13 := oe_validate.g_attribute13;
	    END IF;

	    IF p_x_header_rec.tp_attribute14 IS NULL
	      OR p_x_header_rec.tp_attribute14 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute14 := oe_validate.g_attribute14;
	    END IF;

	    IF p_x_header_rec.tp_attribute15 IS NULL
	      OR p_x_header_rec.tp_attribute15 = FND_API.G_MISS_CHAR THEN
	       p_x_header_rec.tp_attribute15 := oe_validate.g_attribute15;
	    END IF;

         END IF;
	END IF; -- Is flex enabled

         --oe_debug_pub.add('After TP_header_desc_flex  ' || x_return_status);

    END IF;
    /* Trading Partner */
   end if; --for bug4343612
    --  Done validating attributes

    -- Salesrep_id
    IF  p_x_header_rec.salesrep_id IS NOT NULL AND
        (  (p_x_header_rec.salesrep_id <>
            p_old_header_rec.salesrep_id OR
            p_old_header_rec.salesrep_id IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
        --bug 5060064
    THEN

      IF NOT OE_Validate.salesrep(p_x_header_rec.salesrep_id)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
           p_x_header_rec.salesrep_id := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.salesrep_id := FND_API.G_MISS_NUM;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    oe_debug_pub.add('after salesrep_id');

    IF  p_x_header_rec.sales_channel_code IS NOT NULL AND
        (  (p_x_header_rec.sales_channel_code <>
            p_old_header_rec.sales_channel_code OR
            p_old_header_rec.sales_channel_code IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
        --bug 5060064
    THEN

      IF NOT OE_Validate.sales_channel(p_x_header_rec.sales_channel_code)
      THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
           p_x_header_rec.sales_channel_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.sales_channel_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    -- Return_reason_code

    IF  p_x_header_rec.return_reason_code IS NOT NULL AND
        (  (p_x_header_rec.return_reason_code <>
            p_old_header_rec.return_reason_code OR
            p_old_header_rec.return_reason_code IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
        --bug 5060064
    THEN

      IF NOT OE_Validate.return_reason(p_x_header_rec.return_reason_code) THEN
        IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
           p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.return_reason_code := NULL;
        ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
        THEN
          p_x_header_rec.return_reason_code := FND_API.G_MISS_CHAR;
        ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      END IF;

    END IF;

    -- Changes for Line Set Enhancements

     IF  p_x_header_rec.Default_fulfillment_set IS NOT NULL AND
         ( (p_x_header_rec.default_fulfillment_set <>
            p_old_header_rec.default_fulfillment_set OR
            p_old_header_rec.default_fulfillment_set IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
        --bug 5060064
      THEN

       IF NOT OE_Validate.Default_fulfillment_set(p_x_header_rec.default_fulfillment_set)
       THEN
          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
          THEN
             p_x_header_rec.default_fulfillment_set := NULL;
          ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
             p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
          THEN
             p_x_header_rec.default_fulfillment_set := FND_API.G_MISS_CHAR;
          ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

      END IF;

    END IF;

    IF  p_x_header_rec.fulfillment_set_name IS NOT NULL AND
        (  (p_x_header_rec.fulfillment_set_name <>
            p_old_header_rec.fulfillment_set_name OR
            p_old_header_rec.fulfillment_set_name IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
        --bug 5060064
    THEN

       IF NOT OE_Validate.Fulfillment_Set_name (p_x_header_rec.fulfillment_set_name)
       THEN
          IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
             p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
          THEN
             p_x_header_rec.fulfillment_set_name := NULL;
          ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
             p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
          THEN
             p_x_header_rec.fulfillment_set_name := FND_API.G_MISS_CHAR;
          ELSE
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

      END IF;

    END IF;

    IF  p_x_header_rec.Line_set_name IS NOT NULL AND
        (  (p_x_header_rec.Line_set_name  <>
            p_old_header_rec.Line_set_name OR
            p_old_header_rec.Line_set_name IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
        --bug 5060064
    THEN

        IF NOT OE_Validate.Line_set_name (p_x_header_rec.line_set_name)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.line_set_name := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.line_set_name := FND_API.G_MISS_CHAR;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;


    -- QUOTING changes

    IF  p_x_header_rec.user_status_code IS NOT NULL AND
        (  (p_x_header_rec.user_status_code  <>
            p_old_header_rec.user_status_code OR
            p_old_header_rec.user_status_code IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
        --bug 5060064
    THEN

        IF NOT OE_Validate.User_Status (p_x_header_rec.user_status_code)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.user_status_code := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.user_status_code := FND_API.G_MISS_CHAR;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

    END IF;


    IF  p_x_header_rec.version_number IS NOT NULL AND
        (  (p_x_header_rec.version_number  <>
            p_old_header_rec.version_number OR
            p_old_header_rec.version_number IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
        --bug 5060064
    THEN

        IF NOT OE_Validate.Version_Number (p_x_header_rec.version_number)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.version_number := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.version_number := FND_API.G_MISS_CHAR;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

    END IF;

    IF  p_x_header_rec.expiration_date IS NOT NULL AND
        (  (p_x_header_rec.expiration_date  <>
            p_old_header_rec.expiration_date OR
            p_old_header_rec.expiration_date IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
     THEN

        IF NOT OE_Validate.Expiration_Date (p_x_header_rec.expiration_date)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.expiration_date := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              -- Bug 3222419
              -- Copy was failing with numeric/value error if expiration date
              -- supplied was < sysdate
              p_x_header_rec.expiration_date := FND_API.G_MISS_DATE;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

    END IF;

    IF  p_x_header_rec.sold_to_site_use_id IS NOT NULL AND
        (  (p_x_header_rec.sold_to_site_use_id <>
            p_old_header_rec.sold_to_site_use_id OR
            p_old_header_rec.sold_to_site_use_id IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
    THEN
      IF NOT OE_Validate.Customer_Location(p_x_header_rec.sold_to_site_use_id)
      THEN
	 IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
	    p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
	 THEN
	    p_x_header_rec.sold_to_site_use_id := NULL;
	 ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
	       p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
	 THEN
	    p_x_header_rec.sold_to_site_use_id := FND_API.G_MISS_NUM;
	 ELSE
	    x_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;
      END IF;

   END IF;

    -- QUOTING changes END


    IF  p_x_header_rec.Minisite_Id IS NOT NULL AND
        (  (p_x_header_rec.Minisite_Id  <>
            p_old_header_rec.Minisite_Id OR
            p_old_header_rec.Minisite_Id IS NULL )  OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
    THEN

        IF NOT OE_Validate.Minisite (p_x_header_rec.Minisite_Id)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.Minisite_Id := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.Minisite_Id := FND_API.G_MISS_NUM;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

   IF  p_x_header_rec.Ib_owner  IS NOT NULL AND
        (  (p_x_header_rec.Ib_owner  <>
            p_old_header_rec.Ib_owner OR
            p_old_header_rec.Ib_owner IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
   THEN

        IF NOT OE_Validate.IB_OWNER (p_x_header_rec.Ib_owner)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.Ib_owner := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.Ib_owner := FND_API.G_MISS_CHAR;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

  IF  p_x_header_rec.Ib_installed_at_location  IS NOT NULL AND
        (  (p_x_header_rec.Ib_installed_at_location  <>
            p_old_header_rec.Ib_installed_at_location OR
            p_old_header_rec.Ib_installed_at_location IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
    THEN

        IF NOT OE_Validate.IB_INSTALLED_AT_LOCATION (p_x_header_rec.Ib_installed_at_location)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.Ib_installed_at_location := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.Ib_installed_at_location := FND_API.G_MISS_CHAR;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

   IF  p_x_header_rec.Ib_current_location  IS NOT NULL AND
        (  (p_x_header_rec.Ib_current_location  <>
            p_old_header_rec.Ib_current_location OR
            p_old_header_rec.Ib_current_location IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
   THEN

        IF NOT OE_Validate.IB_CURRENT_LOCATION (p_x_header_rec.Ib_current_location)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.Ib_current_location := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.Ib_current_location := FND_API.G_MISS_CHAR;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

   IF  p_x_header_rec.End_customer_id  IS NOT NULL AND
        (  (p_x_header_rec.End_customer_id  <>
            p_old_header_rec.End_customer_id OR
            p_old_header_rec.End_customer_id IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
   THEN

        IF NOT OE_Validate.END_CUSTOMER (p_x_header_rec.End_customer_id)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.End_customer_id := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.End_customer_id := FND_API.G_MISS_NUM;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

   IF  p_x_header_rec.End_customer_contact_id  IS NOT NULL AND
        (  (p_x_header_rec.End_customer_contact_id  <>
            p_old_header_rec.End_customer_contact_id OR
            p_old_header_rec.End_customer_contact_id IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
    THEN

        IF NOT OE_Validate.END_CUSTOMER_CONTACT (p_x_header_rec.End_customer_contact_id)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.End_customer_contact_id := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.End_customer_contact_id := FND_API.G_MISS_NUM;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

  IF  p_x_header_rec.End_customer_site_use_id  IS NOT NULL AND
        (  (p_x_header_rec.End_customer_site_use_id  <>
            p_old_header_rec.End_customer_site_use_id OR
            p_old_header_rec.End_customer_site_use_id IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
  THEN

        IF NOT OE_Validate.END_CUSTOMER_SITE_USE (p_x_header_rec.End_customer_site_use_id)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.End_customer_site_use_id := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.End_customer_site_use_id := FND_API.G_MISS_NUM;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

   IF  p_x_header_rec.supplier_signature  IS NOT NULL AND
        (  (p_x_header_rec.supplier_signature  <>
            p_old_header_rec.supplier_signature OR
            p_old_header_rec.supplier_signature IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
    THEN

       IF NOT OE_Validate.SUPPLIER_SIGNATURE (p_x_header_rec.supplier_signature)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.supplier_signature := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.supplier_signature := FND_API.G_MISS_CHAR;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

   IF  p_x_header_rec.supplier_signature_date  IS NOT NULL AND
        (  (p_x_header_rec.supplier_signature_date  <>
            p_old_header_rec.supplier_signature_date OR
            p_old_header_rec.supplier_signature_date IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
   THEN

       IF NOT OE_Validate.SUPPLIER_SIGNATURE_DATE (p_x_header_rec.supplier_signature_date)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.supplier_signature_date := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.supplier_signature_date := FND_API.G_MISS_DATE;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

   IF  p_x_header_rec.customer_signature  IS NOT NULL AND
        (  (p_x_header_rec.customer_signature  <>
            p_old_header_rec.customer_signature OR
            p_old_header_rec.customer_signature IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
   THEN

       IF NOT OE_Validate.CUSTOMER_SIGNATURE (p_x_header_rec.customer_signature)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.customer_signature := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.customer_signature := FND_API.G_MISS_CHAR;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;

  IF  p_x_header_rec.customer_signature_date  IS NOT NULL AND
        (  (p_x_header_rec.customer_signature_date  <>
            p_old_header_rec.customer_signature_date OR
            p_old_header_rec.customer_signature_date IS NULL ) OR
           (p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE ) )
    --bug 5060064
   THEN

       IF NOT OE_Validate.CUSTOMER_SIGNATURE_DATE (p_x_header_rec.customer_signature_date)
        THEN
           IF p_validation_level = OE_GLOBALS.G_VALID_LEVEL_PARTIAL AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.customer_signature_date := NULL;
           ELSIF p_validation_level = OE_GLOBALS.G_VALID_PARTIAL_WITH_DEF AND
              p_x_header_rec.operation = OE_GLOBALS.G_OPR_CREATE
           THEN
              p_x_header_rec.customer_signature_date := FND_API.G_MISS_DATE;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;

        END IF;

     END IF;




--End Of Addition
--End Of Addition
    oe_debug_pub.add('Exiting OE_VALIDATE_HEADER.ATTRIBUTES',1);

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



/*-----------------------------------------------------
PROCEDURE:   Entity_Delete
Description:
-------------------------------------------------------*/

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    --  Validate entity delete.
    NULL;
    --  Done.

    x_return_status := l_return_status;

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
          ,'Entity_Delete'
        );
      END IF;

END Entity_Delete;

END OE_Validate_Header;

/
