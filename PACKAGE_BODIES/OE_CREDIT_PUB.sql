--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_PUB" AS
/* $Header: OEXPCRCB.pls 120.4.12010000.4 2009/04/15 10:02:45 cpati ship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Credit_PUB';



procedure chk_past_due_invoice (
  p_header_rec             IN   OE_Order_PUB.Header_Rec_Type
 ,p_credit_rule_id         IN   NUMBER
 ,p_credit_level           IN   VARCHAR2
 ,p_check_past_due         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
 ,p_return_status          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
 )
IS
 l_maximum_days_past_due   NUMBER;
 l_dummy                   VARCHAR2(30);
--
l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN
 -- Default to pass back
 p_check_past_due := 'N';

 select    NVL(maximum_days_past_due, 0)
   into    l_maximum_days_past_due
   from    OE_CREDIT_CHECK_RULES
  where    CREDIT_CHECK_RULE_ID = p_credit_rule_id;

 if l_maximum_days_past_due > 0 then
   -- Check to see if there is any unpaid invoice that is past the
   -- due date.
   if l_debug_level > 0 then
     oe_debug_pub.ADD('OEXPCRCB.pls: maximum_days_past_due:' ||to_char(l_maximum_days_past_due) );
   end if;
   BEGIN
	-- Default to Y, in case there is one or more invoices due.
     p_check_past_due := 'Y';
     select 'Any Past due invoice'
      into  l_dummy
      from  AR_PAYMENT_SCHEDULES
     WHERE  CUSTOMER_ID = ( SELECT CUSTOMER_ID
                            FROM   OE_INVOICE_TO_ORGS_V
                            WHERE  ORGANIZATION_ID = p_header_rec.invoice_to_org_id)
       AND  INVOICE_CURRENCY_CODE = p_header_rec.transactional_curr_code
       AND  NVL(RECEIPT_CONFIRMED_FLAG, 'Y') = 'Y'
	  AND  AMOUNT_DUE_REMAINING > 0
	  AND  DUE_DATE < sysdate - l_maximum_days_past_due;
   EXCEPTION

	  WHEN NO_DATA_FOUND THEN
          p_check_past_due := 'N';
   	  if l_debug_level > 0 then
            oe_debug_pub.ADD('OEXPCRCB.pls: No Invoices Past due' );
          end if;
       WHEN TOO_MANY_ROWS THEN
		null;
   END;


 end if;

 if l_debug_level > 0 then
   oe_debug_pub.ADD('OEXPCRCB.pls: Past due Invoice Check:' || p_check_past_due);
 end if;

EXCEPTION

  WHEN others THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         OE_MSG_PUB.Add_Exc_Msg
                   (   G_PKG_NAME
                      ,'chk_past_due_invoice'
                   );
     END IF;
     RAISE;

END chk_past_due_invoice;


-- Mainline Function that will read an Order Header and Determine if should be checked,
-- calculates total exposure, find credit limits and determin result for calling function.
/* additional task - made the procedure Check_trx_Limit
   local to this package and added p_credit_rule_id as
   an additional input parameter */


PROCEDURE Check_Trx_Limit
(   p_header_rec			IN  	OE_Order_PUB.Header_Rec_Type
,   p_credit_rule_id		IN 	NUMBER
,   p_trx_credit_limit		IN   NUMBER	:= FND_API.G_MISS_NUM
,   p_total_exposure		IN	NUMBER
,   p_overall_credit_limit	IN 	NUMBER
,   p_result_out 			OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
,   p_return_status			OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
)
IS

l_order_value		      NUMBER;
l_include_tax_flag VARCHAR2(1) := 'Y';

l_order_commitment            NUMBER;

BEGIN

-- Initialize return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;

-- Default to Pass
    p_result_out := 'PASS';

/*	additional task-  Read the value of include_tax_flag from credit check rule
	and calculate the value of l_order_values accordingly */

/* 	If the value of include_tax_flag is NULL that means it is 'No' */

	select 	NVL(include_tax_flag, 'N')
	into 	l_include_tax_flag
	from		OE_CREDIT_CHECK_RULES
	where 	CREDIT_CHECK_RULE_ID = p_credit_rule_id;

-- Depending on the value of tax_flag add the tax_value

	SELECT	SUM(decode(l_include_tax_flag , 'Y', NVL(tax_value,0),0)
					+ (NVL(unit_selling_price,0)
					* (NVL(ordered_quantity,0) )))
	INTO		l_order_value
	FROM		OE_ORDER_LINES
    	WHERE	HEADER_ID = p_header_rec.header_id;

-- Get Total Commitments applied to the current order if Commitment Sequencing is "On"
    IF OE_Commitment_PVT.Do_Commitment_Sequencing THEN

	SELECT NVL(SUM(commitment_applied_amount), 0)
	INTO   l_order_commitment
	FROM   OE_PAYMENTS
	WHERE  HEADER_ID = p_header_rec.header_id;

        oe_debug_pub.ADD('OEXPCRCB.pls: order commitment total:' || l_order_commitment);

        -- get the actual order value subject to credit check.
        l_order_value := l_order_value - l_order_commitment;

    END IF;

-- If credit available is less than the total exposure or
-- if the order amount is greater than the transaction limit
-- Return Failure

   oe_debug_pub.ADD('OEXPCRCB.pls: total exposure is:' ||p_total_exposure );
   oe_debug_pub.ADD('OEXPCRCB.pls: total credit limit:' || p_overall_credit_limit);
   oe_debug_pub.ADD('OEXPCRCB.pls: total order value:' || l_order_value);
   oe_debug_pub.ADD('OEXPCRCB.pls: order credit limit:' || p_trx_credit_limit);
   -- Replaced this code
   -- IF l_order_value > p_trx_credit_limit OR
   --    p_total_exposure > p_overall_credit_limit THEN
   --      p_result_out := 'FAIL';
   --      oe_debug_pub.ADD('Over credit limit');
   -- END IF;

   -- With this
   if (p_trx_credit_limit <> -1) then
     if (l_order_value > p_trx_credit_limit) then
       p_result_out := 'FAIL';
       oe_debug_pub.ADD('Order Value greater then Transaction Limit');
     end if;
   end if;
   if (p_overall_credit_limit <> -1) then
     if (p_total_exposure > p_overall_credit_limit) then
        p_result_out := 'FAIL';
        oe_debug_pub.ADD('Total Exposure is greater then Overall Credit Limit');
     end if;
   end if;


EXCEPTION

     WHEN others THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Trx_Limit'
            );
        END IF;
	RAISE ;

END Check_Trx_Limit;



-- Mainline Function that will read an Order Header and Determine if
-- should be checked, calculates total exposure, find credit limits
-- and determine result for calling function.

PROCEDURE Check_Available_Credit
(   p_header_id 			IN 	NUMBER	:= FND_API.G_MISS_NUM
,   p_calling_action		IN	VARCHAR2 :=  'BOOKING'
,   p_msg_count			OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_msg_data			OUT NOCOPY /* file.sql.39 change */   VARCHAR2
,   p_result_out			OUT NOCOPY /* file.sql.39 change */	VARCHAR2    -- Pass or Fail Credit Check
,   p_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
)
IS
l_header_rec             OE_Order_PUB.Header_Rec_Type;
l_credit_rule_id		NUMBER;
l_credit_level			VARCHAR2(30); -- are the limits at the customer
							    -- or site level
l_order_value		     NUMBER;
l_check_order		     VARCHAR2(1);  -- Indicates if this Order is
							    -- subject to credit check
l_total_exposure	     NUMBER;
l_trx_credit_limit		NUMBER;
l_overall_credit_limit	NUMBER;
l_result_out			VARCHAR2(30);
l_return_status		VARCHAR2(30);
l_check_past_due         VARCHAR2(1); -- if any invoice is past due
--
l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

-- Set the default behaviour to pass credit check
--  oe_debug_pub.debug_on;

   p_result_out := 'PASS';
   p_return_status := FND_API.G_RET_STS_SUCCESS;

   oe_debug_pub.ADD('Calling action is   '|| p_calling_action);

-- The first thing to do is to load the record structure for the order header
-- This is done in the OE_HEADER_UTIL package by the Query Row function.
-- The caller must pass a Header id and the function returns the record
-- Structure l_header_rec

   oe_debug_pub.ADD('Before querying');
   OE_HEADER_UTIL.QUERY_ROW(p_header_id=>p_header_id,x_header_rec=>l_header_rec);

-- Now we have the Record Structure loaded we can call the other
-- functions without having to go to the database.
-- Checking whether the order should undergo a credit check. Also
-- returns whether the check should be at the customer level or the
-- bill-to site level and the credit limits at that level.

    oe_debug_pub.ADD('just before the check order procedure');
    OE_Credit_PUB.Check_Order
    (   l_header_rec
    ,   p_calling_action
    ,   l_check_order
    ,   l_credit_rule_id
    ,   l_credit_level
    ,   l_overall_credit_limit
    ,   l_trx_credit_limit
    ,   l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

IF l_check_order = 'Y' THEN

-- If the Order is subject to Credit Check i.e. l_check_order = 'Y'
-- First check if there are any unpaid invoices that are passed the
-- maximum due dates.
   oe_debug_pub.ADD('Calling Check Past Due Invoice procedure');

   oe_credit_pub.chk_past_due_invoice (
		  l_header_rec
		 ,l_credit_rule_id
		 ,l_credit_level
           ,l_check_past_due
		 ,l_return_status
			  );
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  IF l_check_past_due = 'N' THEN
      -- Determine total exposure.

    if l_debug_level > 0 then
      oe_debug_pub.ADD('Calling the check exposure procedure');
    end if;

	 OE_Credit_PUB.Check_Exposure
	 (   l_header_rec
	 ,   l_credit_rule_id
	 ,   l_credit_level
	 ,   l_total_exposure
	 ,   l_return_status
	 );

	 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

	 oe_debug_pub.ADD(' Credit Rule Id ='||to_char(l_credit_rule_id));

--  Next, compare the order amount and the exposure to the
--  order credit limit and total credit limit.

     /* additional task  - now credit_rule_id is passed to Check_trx_Limit*/


	OE_Credit_PUB.Check_Trx_Limit
	(   l_header_rec
	,   l_credit_rule_id
	,   l_trx_credit_limit
	,   l_total_exposure
     ,   l_overall_credit_limit
     ,   l_result_out
	,   l_return_status
	);

	oe_debug_pub.add('After the call for check_Trx_Limit');
     oe_debug_pub.add('Result out ='||l_result_out);
	oe_debug_pub.add('Return Status ='||l_return_status);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

     p_result_out := l_result_out;

  ELSE   -- l_check_past_due = 'N'
    oe_debug_pub.ADD('Past due Invoices: Credit Check Failed');
    p_result_out := 'FAIL';
  END IF; -- l_check_past_due = 'N'
ELSE -- if credit check order = N

         oe_debug_pub.ADD('No credit check required');
    --   FND_MESSAGE.SET_NAME('OE', 'OE_NO_CREDIT_CHECK_REQUIRED');
    --   FND_MSG_PUB.ADD;
    --   null;

END IF;

          -- oe_debug_pub.dumpdebug;
          -- oe_debug_pub.debug_off;

-- Count the Messages on the Message Stack and if only 1 return it in
-- message data.
-- If more than 1 just return the count.  The Calling routine has to get
-- the messages from the message stack.

    OE_MSG_PUB.Count_And_Get
    (   p_count		=> 	p_msg_count
    ,   p_data		=>	p_msg_data
    );

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Available_Credit'
            );
        END IF;

END Check_Available_Credit;

/* ----------------------------------------------------------------------
    Procedure to determine if the order is subject to credit check and
    if it is, return whether the check is at the site level or at the
    customer level. Also, returns the credit limits at that level.
-------------------------------------------------------------------------
*/


PROCEDURE Check_Order
(   p_header_rec           	IN  	OE_Order_PUB.Header_Rec_Type
,   p_calling_action		IN    VARCHAR2	:= 'BOOKING'
,   p_check_order_out		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   p_credit_rule_out		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_credit_check_lvl_out 	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   p_overall_credit_limit	OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_trx_credit_limit		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_return_status		OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
)
IS
-- Set up working Variables for Check Order
l_credit_limit_test 	NUMBER		:= FND_API.G_MISS_NUM;
l_credit_check_term 	NUMBER		:= FND_API.G_MISS_NUM;
l_credit_check_rule_id	NUMBER		:= FND_API.G_MISS_NUM;
l_credit_check_lvl_out  VARCHAR2(30)	:= 'SITE';
l_check_order		VARCHAR2(1);
l_invoice_to_cust_id    NUMBER;

BEGIN

-- Function to Determine if the Order Type is Subject to Credit Check
-- Assume that the Order is subject to credit Check by setting the
-- l_check_order variable to Yes.

    p_check_order_out := 'Y';
    l_check_order := 'Y';

-- Set up a variable to capture the situation of having no credit
-- profile set up.

    p_return_status := FND_API.G_RET_STS_SUCCESS;

-- Read the Credit Rules on the Order Type Definition for the
-- Order Being Credit Checked.
-- If Called from Validating the Order at Order Entry use the
-- Entry Credit Check Rule.

  oe_debug_pub.ADD('Which cchk rule');
  IF p_calling_action = 'BOOKING' THEN

    oe_debug_pub.ADD('Selecting the order entry cchk rule');
/*7194250
    SELECT NVL(ENTRY_CREDIT_CHECK_RULE_ID, -1)
    INTO l_credit_check_rule_id
    FROM OE_ORDER_TYPES_V
    WHERE ORDER_TYPE_ID = p_header_rec.order_type_id;
7194250*/
--7194250
BEGIN  --7695423
    SELECT NVL(ENTRY_CREDIT_CHECK_RULE_ID, -1)
    INTO l_credit_check_rule_id
    FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE OT.ORDER_TYPE_ID = p_header_rec.order_type_id
    AND   ENTRY_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7695423 start
EXCEPTION
WHEN OTHERS THEN
l_credit_check_rule_id := -1;
END;
--7695423 end

--7194250

    OE_Verify_Payment_PUB.G_credit_check_rule := 'Ordering';   --ER#7479609

  -- If not Use the Shipping Rule for all other calling Actions
  ELSE

    oe_debug_pub.ADD('Selecting the shipping cchk rule');
/*7194250
    SELECT NVL(SHIPPING_CREDIT_CHECK_RULE_ID, -1)
    INTO l_credit_check_rule_id
    FROM OE_ORDER_TYPES_V
    WHERE ORDER_TYPE_ID = p_header_rec.order_type_id;
7194250*/
--7194250
BEGIN   --7695423
    SELECT NVL(SHIPPING_CREDIT_CHECK_RULE_ID, -1)
    INTO l_credit_check_rule_id
    FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE OT.ORDER_TYPE_ID = p_header_rec.order_type_id
    AND   SHIPPING_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7695423 start
EXCEPTION
WHEN OTHERS THEN
l_credit_check_rule_id := -1;
END;
--7695423 end

--7194250

    OE_Verify_Payment_PUB.G_credit_check_rule := 'Shipping';   --ER#7479609

  END IF;

-- If no credit rule was found for the calling action the Order
-- is not subject to credit check

    oe_debug_pub.ADD('check order after selecting credit rule : '|| l_check_order);
    IF l_credit_check_rule_id <= 0 THEN
       oe_debug_pub.ADD('no cchk rule found');
       l_check_order := 'N';
    END IF;

-- If the Order type is subject to credit check we should check the
-- bill to site and customer to see if they are subject to credit check.

IF l_check_order = 'Y' THEN

-- The Order type is Subject to Credit Check.
-- Procedure to determine if the Order Bill to is subject to Credit Check
-- Get the flags that control if credit check should be performed
-- from the Credit Profile.  Get the Credit Limit Amounts from the
-- Credit Profile Amounts for the Customers Bill to Address.

   /* Find Customer Id of the Header Invoice To Org */
   SELECT CUSTOMER_ID
   INTO   l_invoice_to_cust_id
   FROM	  OE_INVOICE_TO_ORGS_V
   WHERE  ORGANIZATION_ID = p_header_rec.invoice_to_org_id;

   oe_debug_pub.ADD('Invoice To Customer Id: '||to_char(l_invoice_to_cust_id));

BEGIN

    SELECT NVL(CP.CREDIT_CHECKING, 'N')
    ,   (NVL(CPA.OVERALL_CREDIT_LIMIT,-1) + NVL(CPA.TRX_CREDIT_LIMIT, -1))
    ,   NVL(CPA.OVERALL_CREDIT_LIMIT * ((100 + CP.TOLERANCE)/100), -1)
    ,   NVL(CPA.TRX_CREDIT_LIMIT * ((100 + CP.TOLERANCE)/100), -1)
    INTO l_check_order
    ,   l_credit_limit_test
    ,   p_overall_credit_limit
    ,   p_trx_credit_limit
    FROM HZ_CUSTOMER_PROFILES CP
    ,   HZ_CUST_PROFILE_AMTS CPA
    WHERE CP.CUST_ACCOUNT_ID = l_invoice_to_cust_id
    AND CP.SITE_USE_ID = p_header_rec.invoice_to_org_id
    AND CPA.CUST_ACCOUNT_ID = CP.CUST_ACCOUNT_ID
    AND CPA.SITE_USE_ID = CP.SITE_USE_ID
    AND CPA.CUST_ACCOUNT_PROFILE_ID = CP.CUST_ACCOUNT_PROFILE_ID
    AND CPA.CURRENCY_CODE = p_header_rec.transactional_curr_code;

-- If we find a Credit Profile at this level the customer has credit limits
-- at the site level.


    l_credit_check_lvl_out := 'SITE';

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
-- If we do not find a Credit Profile we will assume that the credit limits are set
-- at the customer level.

    oe_debug_pub.ADD('Customer level credit check');
    l_credit_check_lvl_out := 'CUSTOMER';

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check Order:Check Customer'
            );
        END IF;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;

-- If no credit limit has been set for either the total Order Amount
-- or the Total Exposure, get the credit profiles from the customer level
    IF l_credit_limit_test < 0 and l_credit_check_lvl_out ='SITE' THEN
          l_credit_check_lvl_out := 'CUSTOMER';
    END IF;

END IF; -- Check if the Order type is subject to credit check for site or customer

    oe_debug_pub.ADD('check order after selecting site/customer level : ' || l_check_order);
    oe_debug_pub.ADD('level for credit check: '|| l_credit_check_lvl_out);
IF l_check_order = 'Y' AND  l_credit_check_lvl_out = 'CUSTOMER' THEN

-- If both the Order type and the Bill to are subject to credit check
-- and no credit profile was found at the bill to site go on to
-- check if the customer is subject to credit check.
-- Procedure to Determine if the Customer is subject to Credit Check

BEGIN

    SELECT NVL(CP.CREDIT_CHECKING,'N')
    ,   (NVL(CPA.OVERALL_CREDIT_LIMIT,-1) + NVL(CPA.TRX_CREDIT_LIMIT, -1))
    ,   NVL(CPA.OVERALL_CREDIT_LIMIT * ((100 + CP.TOLERANCE)/100), -1)
    ,   NVL(CPA.TRX_CREDIT_LIMIT * ((100 + CP.TOLERANCE)/100), -1)
    INTO l_check_order
    ,   l_credit_limit_test
    ,   p_overall_credit_limit
    ,   p_trx_credit_limit
    FROM HZ_CUSTOMER_PROFILES CP
    ,   HZ_CUST_PROFILE_AMTS CPA
    WHERE  CP.CUST_ACCOUNT_ID = l_invoice_to_cust_id
    AND CP.CUST_ACCOUNT_PROFILE_ID = CPA.CUST_ACCOUNT_PROFILE_ID
    AND CPA.CURRENCY_CODE = p_header_rec.transactional_curr_code
    AND CP.SITE_USE_ID IS NULL;

    oe_debug_pub.ADD('limit test:'||  l_credit_limit_test );

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
    -- If we don't find a credit profile at the customer level, no
    -- credit checking needed.
        l_check_order := 'N';

    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check Order:Check Customer'
            );
        END IF;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;

-- If no credit limit has been set for either the total Order Amount
-- or the Total Exposure, do not credit check.
    IF l_credit_limit_test < 0 THEN
        l_check_order := 'N';
    END IF;

    oe_debug_pub.ADD('check order after determining credit limits :'
			 || l_check_order);
END IF; -- The Order type Subject to Credit Check No credit profile at bill to.

IF l_check_order = 'Y' THEN

-- Order Type, Bill to or Customer are subject to Credit Check
-- If the Order Type, Bill to Site and Customer are subject to credit check,
-- go on to check if the payment term is subject to credit check.
-- Procedure to Determine if Payment Term is subject to Credit Check
-- Check if any line on the order has a payment term that requires credit checking.
-- If at least one order line has a payment term that requires credit checking the
-- order is subject to credit check.

BEGIN

    SELECT COUNT(*)
    INTO l_credit_check_term
    FROM OE_ORDER_LINES L, OE_RA_TERMS_V T
    WHERE L.HEADER_ID = p_header_rec.header_id
    AND T.TERM_ID = L.PAYMENT_TERM_ID
    AND NVL(T.CREDIT_CHECK_FLAG, 'Y') = 'Y';

-- If no line exists with a payment term that is subject to credit check
-- we should exempt the order from credit check.

     IF l_credit_check_term = 0 THEN
        l_check_order := 'N';
     END IF;

     EXCEPTION

    	WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Order: Check Terms'
            );
        END IF;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END;

END IF; -- Order Type, Bill to or Customer are subject to Credit Check

    p_credit_check_lvl_out := l_credit_check_lvl_out;
    p_credit_rule_out := l_credit_check_rule_id;
    p_check_order_out := l_check_order;

    oe_debug_pub.ADD('check order after checking payment term :'|| l_check_order);
    EXCEPTION

    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Order'
            );
        END IF;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Check_Order;



PROCEDURE Check_Exposure
(   p_header_rec            	IN  	OE_Order_PUB.Header_Rec_Type
,   p_credit_check_rule_id	IN      NUMBER
,   p_credit_level		IN 	VARCHAR2
,   p_total_exposure		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_return_status		OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
)
IS
l_open_ar_balance_flag		Varchar2(1) := 'Y';
l_open_ar_days			NUMBER;
l_uninvoiced_orders_flag 	Varchar2(1) := 'Y';
l_orders_on_hold_flag		Varchar2(1) := 'Y';

/* additional task -added the following variable */
l_include_tax_flag 			Varchar2(1) := 'Y';

l_shipping_horizon		Date := TO_DATE('31/12/4712', 'DD/MM/YYYY');
l_include_risk_flag		Varchar2(1) := 'Y';
l_total_from_ar		NUMBER   := 0;
l_total_on_order	     NUMBER   := 0;
l_total_on_hold		NUMBER   := 0;
l_total_exposure	     NUMBER   := 0;
l_payments_at_risk		NUMBER   := 0;
l_current_order 		NUMBER := 0;

-- ZB
l_maximum_days_past_due  NUMBER   := 0;

--additional task :  added the following variable
l_est_valid_days         NUMBER := 0 ;

l_total_commitment       NUMBER := 0;
l_current_commitment     NUMBER := 0;
l_on_hold_commitment     NUMBER := 0;

l_invoice_to_cust_id     NUMBER;

/* additional task - for adding the Include Tax option, the cursor needs to be modified */

Cursor credit_check_rule IS
        SELECT       OPEN_AR_BALANCE_FLAG
	            ,   OPEN_AR_DAYS
	            ,   UNINVOICED_ORDERS_FLAG
	            ,   ORDERS_ON_HOLD_FLAG
			  ,   INCLUDE_TAX_FLAG
	            ,   DECODE(SHIPPING_INTERVAL, NULL,
                                TO_DATE('31/12/4712', 'DD/MM/YYYY'),
                                SHIPPING_INTERVAL+SYSDATE)
	            ,   INCLUDE_PAYMENTS_AT_RISK_FLAG
        FROM		OE_CREDIT_CHECK_RULES
	   WHERE		CREDIT_CHECK_RULE_ID = p_credit_check_rule_id;

Cursor ar_balance IS
        SELECT	        NVL(SUM(AMOUNT_DUE_REMAINING), 0)
	FROM		AR_PAYMENT_SCHEDULES
	WHERE		CUSTOMER_ID = l_invoice_to_cust_id
        AND    INVOICE_CURRENCY_CODE = p_header_rec.transactional_curr_code
	AND		NVL(RECEIPT_CONFIRMED_FLAG, 'Y') = 'Y';

Cursor ar_balance_in_ar_days IS
        SELECT	        NVL(SUM(AMOUNT_DUE_REMAINING), 0)
	FROM		AR_PAYMENT_SCHEDULES
	WHERE		CUSTOMER_ID = l_invoice_to_cust_id
        AND             INVOICE_CURRENCY_CODE = p_header_rec.transactional_curr_code
	AND		NVL(RECEIPT_CONFIRMED_FLAG, 'Y') = 'Y'
	AND 		SYSDATE - TRX_DATE > l_open_ar_days;

Cursor pay_risk IS
        SELECT NVL(SUM(CRH.AMOUNT), 0)
	FROM AR_CASH_RECEIPT_HISTORY CRH
	,    AR_CASH_RECEIPTS CR
	WHERE	CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
	AND	NVL(CR.CONFIRMED_FLAG,'Y') = 'Y'
	AND 	CRH.CURRENT_RECORD_FLAG = 'Y'
	AND	CRH.STATUS <>
			DECODE(CRH.FACTOR_FLAG,'Y',
				'RISK_ELIMINATED','CLEARED')
	AND	CRH.STATUS <> 'REVERSED'
        AND	CR.CURRENCY_CODE = p_header_rec.transactional_curr_code
	AND	CR.PAY_FROM_CUSTOMER = l_invoice_to_cust_id;

Cursor pay_risk_in_ar_days IS
        SELECT NVL(SUM(CRH.AMOUNT), 0)
	FROM AR_CASH_RECEIPT_HISTORY CRH
	,    AR_CASH_RECEIPTS CR
	WHERE	CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
	AND	NVL(CR.CONFIRMED_FLAG,'Y') = 'Y'
	AND 	CRH.CURRENT_RECORD_FLAG = 'Y'
	AND	CRH.STATUS <>
			DECODE(CRH.FACTOR_FLAG,'Y',
				'RISK_ELIMINATED','CLEARED')
	AND	CRH.STATUS <> 'REVERSED'
        AND	CR.CURRENCY_CODE = p_header_rec.transactional_curr_code
	AND	CR.PAY_FROM_CUSTOMER = l_invoice_to_cust_id
        AND     SYSDATE - CR.RECEIPT_DATE > l_open_ar_days;


/* additional task : modified the following 2 cursors uninvoiced_orders and
		 orders_on_hold for the following purpose
   1. excluded unbooked orders
   2. excluded orders authorized by credit card
   3. Exclude the Current Order

   So far there was a bug in the application - if the current order was
   on hold and booked then current order value was not getting included
   into the credit exposure. With present logic, we exclude the current order
   initially while calculating the uninvoiced order total and orders_on_hold
   total and then add it up later. Because irrespective of the fact that
   current order is booked/entered/on hold etc, we have to take care of that
   amount in Credit exposure.

   Two additional conditions has been added for all cursors related
   to Include Uninvoiced Orders. We will consider only those orders
   which are not invoiced yet, i.e. invoiced qty is zero.
   Also we should consider Open Orders Only
   The decode statement has been added to improve performance*/

Cursor uninvoiced_orders(p_include_tax VARCHAR2)  IS
        SELECT /* MOAC_SQL_CHANGE */  SUM((NVL(ordered_quantity,0)
	         *NVL(unit_selling_price,0)) + decode(p_include_tax,'Y',NVL(tax_value,0), 0))
	FROM 	 OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H --ksurendr SQL# 16485169 Removed OE_PAYMENTS
	WHERE	 H.SOLD_TO_ORG_ID = l_invoice_to_cust_id  --table from outer query as it is not used.
        AND      H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND      H.OPEN_FLAG = 'Y'
	AND	 H.HEADER_ID = L.HEADER_ID
	AND      NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
		               <= l_shipping_horizon
        AND      NVL(L.INVOICED_QUANTITY,0) = 0
	AND      L.OPEN_FLAG ='Y'
	AND	 L.LINE_CATEGORY_CODE ='ORDER'
	AND 	 H.BOOKED_FLAG = 'Y'
	AND      H.HEADER_ID <> p_header_rec.header_id
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  );

/* changed for R12 cc encryption
	AND	 	 decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
		(H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate;
*/

/* old code, logic remaining same:
	AND       (H.CREDIT_CARD_APPROVAL_CODE IS NULL
			OR
			(H.CREDIT_CARD_APPROVAL_CODE IS NOT NULL
			AND  H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days < SYSDATE))*/

Cursor orders_on_hold(p_include_tax VARCHAR2) IS
        SELECT  /* MOAC_SQL_CHANGE */ SUM((NVL(ordered_quantity,0)
	         *NVL(unit_selling_price,0)) + decode(p_include_tax, 'Y',NVL(tax_value,0),0))
	FROM 	OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
	WHERE	H.SOLD_TO_ORG_ID = l_invoice_to_cust_id
        AND      H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND       H.OPEN_FLAG = 'Y'
	AND	 	H.HEADER_ID = L.HEADER_ID
	AND       NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon
	AND       NVL(L.INVOICED_QUANTITY,0) = 0
	AND       L.OPEN_FLAG ='Y'
	AND       L.LINE_CATEGORY_CODE ='ORDER'
        AND       H.BOOKED_FLAG = 'Y'
	AND       H.HEADER_ID <> p_header_rec.header_id
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  )
        /*
	AND       decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
			(H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
	AND	 	EXISTS (SELECT 	1
		             FROM 	OE_ORDER_HOLDS OH
			        WHERE	H.HEADER_ID = OH.HEADER_ID
			        AND    OH.HOLD_RELEASE_ID IS NULL
				   );

Cursor commitment_total IS
        SELECT /* MOAC_SQL_CHANGE */ NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P, OE_ORDER_HEADERS H, OE_ORDER_LINES_ALL L
	WHERE  H.SOLD_TO_ORG_ID = l_invoice_to_cust_id
        AND    H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND    H.OPEN_FLAG      = 'Y'
	AND    H.BOOKED_FLAG    = 'Y'
	AND    H.HEADER_ID      = P.HEADER_ID
	AND    H.HEADER_ID <> p_header_rec.header_id
        /*
	AND    decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
		     (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  )
        AND    L.HEADER_ID                = H.HEADER_ID
        AND    L.LINE_ID                  = P.LINE_ID
        AND    NVL(L.INVOICED_QUANTITY,0) = 0
	AND    L.OPEN_FLAG                = 'Y'
	AND    L.LINE_CATEGORY_CODE       = 'ORDER'
	AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon;

Cursor on_hold_commitment_total IS
        SELECT /* MOAC_SQL_CHANGE */ NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P, OE_ORDER_HEADERS H, OE_ORDER_LINES_ALL L
	WHERE  H.SOLD_TO_ORG_ID = l_invoice_to_cust_id
        AND    H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND    H.OPEN_FLAG      = 'Y'
	AND    H.BOOKED_FLAG    = 'Y'
	AND    H.HEADER_ID      = P.HEADER_ID
	AND    H.HEADER_ID <> p_header_rec.header_id
        /*
	AND    decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
		     (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  )
        AND    L.HEADER_ID                = H.HEADER_ID
        AND    L.LINE_ID                  = P.LINE_ID
        AND    NVL(L.INVOICED_QUANTITY,0) = 0
	AND    L.OPEN_FLAG                = 'Y'
	AND    L.LINE_CATEGORY_CODE       = 'ORDER'
	AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon
	AND    EXISTS (SELECT 'Hold Exists'
		       FROM   OE_ORDER_HOLDS OH
		       WHERE  H.HEADER_ID = OH.HEADER_ID
		       AND    OH.HOLD_RELEASE_ID IS NULL );

Cursor current_commitment_total IS
        SELECT /* MOAC_SQL_CHANGE */ NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P, OE_ORDER_HEADERS H, OE_ORDER_LINES_ALL L
	WHERE  H.HEADER_ID      =  p_header_rec.header_id
	AND    H.HEADER_ID      = P.HEADER_ID
        /*
	AND    decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
		     (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  )
        AND    L.HEADER_ID                = H.HEADER_ID
        AND    L.LINE_ID                  = P.LINE_ID
        AND    NVL(L.INVOICED_QUANTITY,0) = 0
	AND    L.OPEN_FLAG                = 'Y'
	AND    L.LINE_CATEGORY_CODE       = 'ORDER';

-- CURSORS FOR SITE - LEVEL EXPOSURE CALCULATIONS
Cursor site_ar_balance IS
        SELECT	        NVL(SUM(AMOUNT_DUE_REMAINING), 0)
	FROM		AR_PAYMENT_SCHEDULES
	WHERE		CUSTOMER_SITE_USE_ID  = p_header_rec.invoice_to_org_id
        AND             INVOICE_CURRENCY_CODE = p_header_rec.transactional_curr_code
	AND		NVL(RECEIPT_CONFIRMED_FLAG, 'Y') = 'Y';

Cursor site_ar_balance_in_ar_days IS
     SELECT	        NVL(SUM(AMOUNT_DUE_REMAINING), 0)
	FROM		AR_PAYMENT_SCHEDULES
	WHERE		CUSTOMER_SITE_USE_ID  = p_header_rec.invoice_to_org_id
        AND             INVOICE_CURRENCY_CODE = p_header_rec.transactional_curr_code
	AND		NVL(RECEIPT_CONFIRMED_FLAG, 'Y') = 'Y'
	AND 		SYSDATE - TRX_DATE > l_open_ar_days;

Cursor site_pay_risk IS
         SELECT NVL(SUM(CRH.AMOUNT),0)
         FROM   AR_CASH_RECEIPT_HISTORY CRH
                        ,      AR_CASH_RECEIPTS CR
         WHERE  CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
         AND    NVL(CR.CONFIRMED_FLAG,'Y') = 'Y'
         AND    CRH.CURRENT_RECORD_FLAG = 'Y'
         AND    CRH.STATUS <>
                           DECODE(CRH.FACTOR_FLAG,'Y',
                                  'RISK_ELIMINATED','CLEARED')
         AND    CRH.STATUS <> 'REVERSED'
         AND    CR.CURRENCY_CODE = p_header_rec.transactional_curr_code
 	 AND	CR.PAY_FROM_CUSTOMER = l_invoice_to_cust_id
         AND    CR.CUSTOMER_SITE_USE_ID = p_header_rec.invoice_to_org_id;

Cursor site_pay_risk_in_ar_days IS
         SELECT NVL(SUM(CRH.AMOUNT),0)
         FROM   AR_CASH_RECEIPT_HISTORY CRH
                        ,      AR_CASH_RECEIPTS CR
         WHERE  CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
         AND    NVL(CR.CONFIRMED_FLAG,'Y') = 'Y'
         AND    CRH.CURRENT_RECORD_FLAG = 'Y'
         AND    CRH.STATUS <>
                           DECODE(CRH.FACTOR_FLAG,'Y',
                                  'RISK_ELIMINATED','CLEARED')
         AND    CRH.STATUS <> 'REVERSED'
         AND    CR.CURRENCY_CODE = p_header_rec.transactional_curr_code
 	 AND	CR.PAY_FROM_CUSTOMER = l_invoice_to_cust_id
         AND    CR.CUSTOMER_SITE_USE_ID = p_header_rec.invoice_to_org_id
        AND     SYSDATE - TRX_DATE > l_open_ar_days;

/* additional task : modified the following 2 SITE cursors
   1. excluded unbooked orders
   2. excluded orders authorized by credit card
   3. Excludes the current order
*/

Cursor site_uninvoiced_orders(p_include_tax VARCHAR2) IS
     SELECT  /* MOAC_SQL_CHANGE */	SUM(((NVL(ordered_quantity,0) )
	         	*NVL(unit_selling_price,0)) + decode(p_include_tax, 'Y', nvl(tax_value,0), 0))
	FROM		OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
	WHERE	H.INVOICE_TO_ORG_ID = p_header_rec.invoice_to_org_id
        AND      H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND       H.OPEN_FLAG = 'Y'
	AND	 	H.HEADER_ID = L.HEADER_ID
	AND       NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon
	AND       NVL(L.INVOICED_QUANTITY,0) = 0
	AND       L.OPEN_FLAG ='Y'
	AND       L.LINE_CATEGORY_CODE ='ORDER'
        AND       H.BOOKED_FLAG = 'Y'
	AND       H.HEADER_ID <> p_header_rec.header_id
        /*
	AND       decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
			(H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate;
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  );

Cursor site_orders_on_hold(p_include_tax VARCHAR2) IS

	SELECT /* MOAC_SQL_CHANGE */  	SUM(((NVL(ordered_quantity,0))
	          *NVL(unit_selling_price,0)) + decode(p_include_tax, 'Y', NVL(tax_value,0),0))
	FROM		OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
	WHERE	H.INVOICE_TO_ORG_ID = p_header_rec.invoice_to_org_id
        AND      H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND       H.OPEN_FLAG = 'Y'
	AND	 	H.HEADER_ID = L.HEADER_ID
	AND       NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon
	AND       NVL(L.INVOICED_QUANTITY,0) = 0
	AND       L.OPEN_FLAG ='Y'
	AND       L.LINE_CATEGORY_CODE ='ORDER'
        AND       H.BOOKED_FLAG = 'Y'
	AND       H.HEADER_ID <> p_header_rec.header_id
        /*
	AND       decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
			(H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  )
	AND	 	EXISTS (SELECT 	1
		             FROM 	OE_ORDER_HOLDS OH
			       WHERE	H.HEADER_ID = OH.HEADER_ID
			         AND    OH.HOLD_RELEASE_ID IS NULL
				 );

Cursor site_commitment_total IS
        SELECT /* MOAC_SQL_CHANGE */ NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P, OE_ORDER_HEADERS H, OE_ORDER_LINES_ALL L
	WHERE  H.INVOICE_TO_ORG_ID = p_header_rec.invoice_to_org_id
        AND    H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND    H.OPEN_FLAG         = 'Y'
	AND    H.BOOKED_FLAG       = 'Y'
	AND    H.HEADER_ID         = P.HEADER_ID
        /*
	AND    decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
		     (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  )
        AND    L.HEADER_ID         = H.HEADER_ID
        AND    L.LINE_ID           = P.LINE_ID
        AND    NVL(L.INVOICED_QUANTITY,0) = 0
	AND    L.OPEN_FLAG                = 'Y'
	AND    L.LINE_CATEGORY_CODE       = 'ORDER'
	AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon;

Cursor site_on_hold_commitment_total IS
        SELECT /* MOAC_SQL_CHANGE */ NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P, OE_ORDER_HEADERS H, OE_ORDER_LINES_ALL L
	WHERE  H.INVOICE_TO_ORG_ID = p_header_rec.invoice_to_org_id
        AND    H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND    H.OPEN_FLAG         = 'Y'
	AND    H.BOOKED_FLAG       = 'Y'
	AND    H.HEADER_ID         = P.HEADER_ID
        /*
	AND    decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
		     (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  )
        AND    L.HEADER_ID         = H.HEADER_ID
        AND    L.LINE_ID           = P.LINE_ID
        AND    NVL(L.INVOICED_QUANTITY,0) = 0
	AND    L.OPEN_FLAG                = 'Y'
	AND    L.LINE_CATEGORY_CODE       = 'ORDER'
	AND    H.HEADER_ID <> p_header_rec.header_id
	AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon
	AND    EXISTS (SELECT 'Hold Exists'
		       FROM   OE_ORDER_HOLDS OH
		       WHERE  H.HEADER_ID = OH.HEADER_ID
		       AND    OH.HOLD_RELEASE_ID IS NULL );

/* additional task-  Current Order -  */

-- modified cursor for bug 1655720, to include lines falling outside of
-- shipping horizon for credit checking.
Cursor current_order(p_include_tax VARCHAR2) IS
	SELECT  /* MOAC_SQL_CHANGE */  SUM((NVL(ordered_quantity,0)
			  *NVL(unit_selling_price,0)) + decode(p_include_tax,'Y',  NVL(tax_value,0), 0))
	FROM      OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
	WHERE	H.HEADER_ID = p_header_rec.header_id
	AND		H.HEADER_ID = L.HEADER_ID
   --	AND		NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
   --					<= to_date(l_shipping_horizon, 'DD-MON-YY')
	AND       NVL(L.INVOICED_QUANTITY,0) = 0
	AND       L.OPEN_FLAG ='Y'
	AND       L.LINE_CATEGORY_CODE ='ORDER'
        /*
	AND		decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
				(H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate;
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  );


BEGIN

-- Set the default behaviour to pass credit check exposure
	p_return_status := FND_API.G_RET_STS_SUCCESS;
-- Read the Credit rule and determine the inclusions and exclusions for exposure

-- Include Amounts on Receivables if within the AR horizon.  Add the OPEN_AR_DAYS
-- to todays date to determine the AR Horizon.  Use this to compare the Due date on
-- the Invoice. If the due_date is greater than system date by less than open_ar_days
-- In the R10SC/R11, if the trx_date/invoice_date is earlier than system date
-- by open_ar_days, those
-- orders only are considered. So the check was WHERE SYSDATE - TRX_DATE > OPEN_AR_DAYS

-- Include amounts on Order Backlog if within the shipping horizon. Add the Shipping Horizon
-- to todays date to determin the shipping horizon.  Use this to compare the scheduled ship date on
-- the order line.
-- As in R10SC/R11, if the schedule_date (or when this field is null, request_date)
-- is within the no. of shipping_interval days of the current date, include only
-- those amounts for calculating uninvoiced orders total.

oe_debug_pub.ADD('In Check Exposure');
	OPEN credit_check_rule;
	/* additional task */
	FETCH credit_check_rule INTO l_open_ar_balance_flag
				,   l_open_ar_days
				,   l_uninvoiced_orders_flag
				,   l_orders_on_hold_flag
				,   l_include_tax_flag
				,   l_shipping_horizon
				,   l_include_risk_flag;
	CLOSE credit_check_rule;

oe_debug_pub.ADD('Credit Check Rule is as follows :');
oe_debug_pub.ADD('Open AR Balance Flag ='||l_open_ar_balance_flag);
oe_debug_pub.ADD('Open AR days ='||to_char(l_open_ar_days));
oe_debug_pub.ADD('Uninvoiced Orders Flag ='||l_uninvoiced_orders_flag);
oe_debug_pub.ADD('Orders On Hold flag ='||l_orders_on_hold_flag);
oe_debug_pub.ADD('Include Tax Flag ='||l_include_tax_flag);
oe_debug_pub.ADD('Shipping Horizon days ='||to_char(l_shipping_horizon, 'DD-MON-YYYY'));
oe_debug_pub.ADD('Include Risk flag ='||l_include_risk_flag);

/* additional task */
l_est_valid_days := to_number( nvl(fnd_profile.value('ONT_EST_AUTH_VALID_DAYS'), '0') ) ;
oe_debug_pub.ADD('Estimated Valid Days ='||to_char(l_est_valid_days));

   -- Move the following SQL out of if clause for customer credit level
   -- because even for site credit level, we need to pass pay_from_customer
   /* Find Customer Id of the Header Invoice To Org */
   SELECT CUSTOMER_ID
   INTO   l_invoice_to_cust_id
   FROM	  OE_INVOICE_TO_ORGS_V
   WHERE  ORGANIZATION_ID = p_header_rec.invoice_to_org_id;

   oe_debug_pub.ADD('Invoice To Customer Id: '||to_char(l_invoice_to_cust_id));

IF p_credit_level = 'CUSTOMER' THEN -- Retrieving exposure at CUSTOMER level


   IF l_open_ar_balance_flag = 'Y' THEN

-- Find Accounts Receivable Exposure

   IF l_open_ar_days IS NULL THEN

     OPEN ar_balance;
     FETCH ar_balance INTO l_total_from_ar;
     IF ar_balance%notfound THEN
        l_total_from_ar := 0;
     END IF;
     CLOSE ar_balance;

   ELSE

     OPEN ar_balance_in_ar_days;
     FETCH ar_balance_in_ar_days INTO l_total_from_ar;
     IF ar_balance_in_ar_days%notfound THEN
        l_total_from_ar := 0;
     END IF;
     CLOSE ar_balance_in_ar_days;

   END IF; -- If open_ar_days is null

   oe_debug_pub.ADD('Open Receivables Balance: '||l_total_from_ar);

/* If the include payments at risk flag is set to yes
   Update the exposure by payments that are not thought to be collectable
   These payments are in the cash receipts history
*/


    IF l_include_risk_flag = 'Y' THEN

      IF l_open_ar_days IS NULL THEN

	 OPEN pay_risk;
	 FETCH pay_risk INTO l_payments_at_risk;
         IF pay_risk%notfound THEN
	    l_payments_at_risk := 0;
	    END IF;
	 CLOSE pay_risk;

      ELSE

         OPEN pay_risk_in_ar_days;
         FETCH pay_risk_in_ar_days INTO l_payments_at_risk;
         IF pay_risk_in_ar_days%notfound THEN
	    l_payments_at_risk := 0;
	 END IF;
	 CLOSE pay_risk_in_ar_days;

      END IF;  -- If open_ar_days is null

      oe_debug_pub.ADD('Payments At Risk: '||l_payments_at_risk);

    END IF;  -- Include Payments at Risk


-- Now update the total exposure value.

    	l_total_exposure := nvl(l_total_from_ar,0) + nvl(l_payments_at_risk,0);
	oe_debug_pub.ADD(' Accounts Receivables Exposure ='||to_char(l_total_exposure));

END IF; -- checking accounts receivables exposure



	/* additional task - depending on the include_tax_flag value tax will be included or
 	   excluded from credit exposure calculation */

IF l_uninvoiced_orders_flag  = 'Y' THEN

	/* additional task */

		BEGIN
    		OPEN uninvoiced_orders(l_include_tax_flag);
    		FETCH uninvoiced_orders INTO l_total_on_order;
    		IF uninvoiced_orders%notfound THEN
        		oe_debug_pub.ADD('not found any uninvoiced orders');
			l_total_on_order := 0;
    		END IF;
    		CLOSE uninvoiced_orders;

		/*  WHEN others THEN
    		oe_debug_pub.ADD('not found');*/
 		END;


  -- Now update the total exposure value to include the Order Backlog Value

     oe_debug_pub.ADD('Total amt. of uninvoiced orders: '|| l_total_on_order);
     l_total_exposure := l_total_exposure + nvl(l_total_on_order,0);

	oe_debug_pub.ADD('Exposure after taking care of uninvoiced orders only ='||to_char(l_total_exposure));

/* Next check if we should be excluding orders that are already on hold
   from the calculation of Total exposure
   NOTE: If l_orders_on_hold_flag = 'Y', that means INCLUDE the value of orders on
   hold and hence, the following calculation doesn't need to be done.
*/

    IF l_orders_on_hold_flag = 'N' THEN

   -- Find the value of all orders that are the subject of an order hold
   -- at either the header or line level.

/* additional task - Added the logic for include_tax_flag */

		OPEN orders_on_hold(l_include_tax_flag);
		FETCH orders_on_hold INTO l_total_on_hold;
		IF orders_on_hold%notfound THEN
	    		l_total_on_hold := 0;
     	END IF;
     	CLOSE orders_on_hold;


    -- Now update the total exposure value to EXCLUDE the value of orders on hold
       oe_debug_pub.ADD('Total amount on hold:' || l_total_on_hold);

	l_total_exposure := l_total_exposure - nvl(l_total_on_hold,0);

	oe_debug_pub.ADD('Total exposure after taking care of Hold ='||to_char(l_total_exposure));

    END IF;  -- orders on hold flag

    -- Check Commitment Total if Commitment Sequencing "On"
    IF OE_Commitment_PVT.Do_Commitment_Sequencing THEN

      OPEN commitment_total;
      FETCH commitment_total INTO l_total_commitment;
      IF commitment_total%notfound THEN
        l_total_commitment := 0;
      END IF;
      CLOSE commitment_total;

      oe_debug_pub.ADD('Commitment Amount: ' || l_total_commitment);

      -- If orders on hold are to be excluded then find out
      -- the commitment amount associated to orders on hold
      IF l_orders_on_hold_flag = 'N' THEN
        OPEN on_hold_commitment_total;
        FETCH on_hold_commitment_total INTO l_on_hold_commitment;
        IF on_hold_commitment_total%notfound THEN
          l_on_hold_commitment := 0;
        END IF;

        CLOSE on_hold_commitment_total;

        oe_debug_pub.ADD('On Hold Commitment Amount: ' || l_on_hold_commitment);
      END IF;

      OPEN current_commitment_total;
      FETCH current_commitment_total INTO l_current_commitment;
      IF current_commitment_total%notfound THEN
        l_current_commitment := 0;
      END IF;
      CLOSE current_commitment_total;

      oe_debug_pub.ADD('Current Order Commitment Amount: ' || l_current_commitment);

      l_total_commitment := l_total_commitment + l_current_commitment - nvl(l_on_hold_commitment, 0);

      oe_debug_pub.ADD('Total Commitment Amount: ' || l_total_commitment);

      -- Now update the total exposure value to EXCLUDE already applied Commitments.
      l_total_exposure := l_total_exposure - nvl(l_total_commitment,0);

      oe_debug_pub.ADD('Total exposure after taking care of Commitments = '||to_char(l_total_exposure));

    END IF; -- Commitment Sequencing

/* additional task - ADD Current Order value to the calculated exposure  */


		OPEN current_order(l_include_tax_flag);
		FETCH current_order INTO l_current_order;
		IF current_order%notfound THEN
			l_current_order := 0;
		END IF;
		CLOSE current_order;

	l_total_exposure := l_total_exposure + NVL(l_current_order,0);
	oe_debug_pub.ADD('Total exposure after taking care of Current Order (CUSTOMER level)='||to_char(l_total_exposure));


   END IF; -- uninvoiced order flag

ELSE  -- Retrieving exposure at SITE level


IF l_open_ar_balance_flag = 'Y' THEN

-- Find Accounts Receivable Exposure

   IF l_open_ar_days IS NULL THEN

     OPEN site_ar_balance;
     FETCH site_ar_balance INTO l_total_from_ar;
     IF site_ar_balance%notfound THEN
        l_total_from_ar := 0;
     END IF;
     CLOSE site_ar_balance;

   ELSE

     OPEN site_ar_balance_in_ar_days;
     FETCH site_ar_balance_in_ar_days INTO l_total_from_ar;
     IF site_ar_balance_in_ar_days%notfound THEN
        l_total_from_ar := 0;
     END IF;
     CLOSE site_ar_balance_in_ar_days;

   END IF; -- If open_ar_days is null

   oe_debug_pub.ADD('Open Receivables Balance: '||l_total_from_ar);

/* If the include payments at risk flag is set to yes
   Update the exposure by payments that are not thought to be collectable
   These payments are in the cash receipts history
*/


    IF l_include_risk_flag = 'Y' THEN

      IF l_open_ar_days IS NULL THEN

	 OPEN site_pay_risk;
	 FETCH site_pay_risk INTO l_payments_at_risk;
         IF site_pay_risk%notfound THEN
	    l_payments_at_risk := 0;
	 END IF;
	 CLOSE site_pay_risk;

      ELSE

         OPEN site_pay_risk_in_ar_days;
         FETCH site_pay_risk_in_ar_days INTO l_payments_at_risk;
         IF site_pay_risk_in_ar_days%notfound THEN
	    l_payments_at_risk := 0;
	 END IF;
	 CLOSE site_pay_risk_in_ar_days;

      END IF;  -- If open_ar_days is null

      oe_debug_pub.ADD('Payments At Risk: '||l_payments_at_risk);

    END IF;  -- Include Payments at Risk

	-- Now update the total exposure value.
    	l_total_exposure := nvl(l_total_from_ar,0) + nvl(l_payments_at_risk,0);

	oe_debug_pub.ADD('Exposure from a/c receivables ='||to_char(l_total_exposure));

END IF; -- checking accounts receivables exposure


/* If the include_uninvoiced_orders is set to yes,depending on the
   value of include_tax_flag, tax valuw will be included in the
   calculation of total_exposure.
*/


IF l_uninvoiced_orders_flag  = 'Y' THEN

/* additional task  - added logic for include_tax_flag */

	    	OPEN site_uninvoiced_orders(l_include_tax_flag);
	    	FETCH site_uninvoiced_orders INTO l_total_on_order;
		IF site_uninvoiced_orders%notfound THEN
			l_total_on_order := 0;
    		END IF;
    		CLOSE site_uninvoiced_orders;


  -- Now update the total exposure value to include the Order Backlog Value

     oe_debug_pub.ADD('Total amt. of uninvoiced orders: '|| l_total_on_order);
     l_total_exposure := l_total_exposure + nvl(l_total_on_order,0);

	oe_debug_pub.ADD('Exposure after uninvoiced orders ='||to_char(l_total_exposure));

/* Next check if we should be excluding orders that are already on hold
   from the calculation of Total exposure
   NOTE: If l_orders_on_hold_flag = 'Y', that means INCLUDE the value of orders
   on hold and hence, the following calculation doesn't need to be done.
*/


IF l_orders_on_hold_flag = 'N' THEN

-- Find the value of all orders that are the subject of an order hold
-- at either the header or line level.

/* additional task - added logic for include_tax_flag  */

		OPEN site_orders_on_hold(l_include_tax_flag);
		FETCH site_orders_on_hold INTO l_total_on_hold;
		IF site_orders_on_hold%notfound THEN
	    		l_total_on_hold := 0;
        	END IF;
        	CLOSE site_orders_on_hold;

--    Now update the total exposure value to EXCLUDE the value of orders on hold
      oe_debug_pub.ADD('Total amount on hold:' || l_total_on_hold);
      l_total_exposure := l_total_exposure - nvl(l_total_on_hold,0);

	 oe_debug_pub.ADD('Total Exposure after taking care of Hold ='||to_char(l_total_exposure));

END IF; -- check orders on hold

    -- Check Commitment Total if Commitment Sequencing "On"
    IF OE_Commitment_PVT.Do_Commitment_Sequencing THEN

      OPEN site_commitment_total;
      FETCH site_commitment_total INTO l_total_commitment;
      IF site_commitment_total%notfound THEN
        l_total_commitment := 0;
      END IF;
      CLOSE site_commitment_total;

      oe_debug_pub.ADD('Commitment Amount: ' || l_total_commitment);

      -- If orders on hold are to be excluded then find out
      -- the commitment amount associated to orders on hold
      IF l_orders_on_hold_flag = 'N' THEN
        OPEN site_on_hold_commitment_total;
        FETCH site_on_hold_commitment_total INTO l_on_hold_commitment;
        IF site_on_hold_commitment_total%notfound THEN
          l_on_hold_commitment := 0;
        END IF;

        CLOSE site_on_hold_commitment_total;

        oe_debug_pub.ADD('On Hold Commitment Amount: ' || l_on_hold_commitment);
      END IF;

      l_total_commitment := l_total_commitment - nvl(l_on_hold_commitment, 0);

      -- Now update the total exposure value to EXCLUDE already applied Commitments.
      oe_debug_pub.ADD('Total Commitment Amount: ' || l_total_commitment);

      l_total_exposure := l_total_exposure - nvl(l_total_commitment,0);

      oe_debug_pub.ADD('Total exposure after taking care of Commitments = '||to_char(l_total_exposure));

    END IF; -- Commitment Sequencing

/*  additional task - ADD Current Order */


		OPEN current_order(l_include_tax_flag);
		FETCH current_order INTO l_current_order;
		IF current_order%notfound THEN
			l_current_order := 0;
		END IF;
		CLOSE current_order;

	l_total_exposure := l_total_exposure + NVL(l_current_order,0);
	oe_debug_pub.ADD('Total exposure after taking care of Current Order (SITE level) ='||to_char(l_total_exposure));

END IF;  -- uninvoiced order flag

END IF; -- credit exposure at site level or customer level

--     Load the Out Variable to be returned.
       oe_debug_pub.ADD('OUTPUT total exposure:  '|| l_total_exposure);
	  p_total_exposure := l_total_exposure;


    EXCEPTION

     WHEN others THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Exposure'
            );
        END IF;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	RAISE ;

END Check_Exposure;

-- bug 1830389, new procedures introduced for line level credit checking.
procedure chk_past_due_invoice_line (
  p_header_rec             IN   OE_Order_PUB.Header_Rec_Type
 ,p_invoice_to_org_id      IN   NUMBER
 ,p_customer_id            IN   NUMBER
 ,p_credit_rule_id         IN   NUMBER
 ,p_credit_level           IN   VARCHAR2
 ,p_check_past_due         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
 ,p_return_status          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
 )
IS
 l_maximum_days_past_due   NUMBER;
 l_dummy                   VARCHAR2(30);
BEGIN
 -- Default to pass back
 p_check_past_due := 'N';

 select    NVL(maximum_days_past_due, 0)
   into    l_maximum_days_past_due
   from    OE_CREDIT_CHECK_RULES
  where    CREDIT_CHECK_RULE_ID = p_credit_rule_id;

 if l_maximum_days_past_due > 0 then
   -- Check to see if there is any unpaid invoice that is past the
   -- due date.
   oe_debug_pub.ADD('OEXPCRCB.pls: line level maximum_days_past_due:' ||to_char(l_maximum_days_past_due) );
   BEGIN
	-- Default to Y, in case there is one or more invoices due.
     p_check_past_due := 'Y';
     select 'Any Past due invoice'
      into  l_dummy
      from  AR_PAYMENT_SCHEDULES
     WHERE  CUSTOMER_ID = p_customer_id
       AND  INVOICE_CURRENCY_CODE = p_header_rec.transactional_curr_code
       AND  NVL(RECEIPT_CONFIRMED_FLAG, 'Y') = 'Y'
	  AND  AMOUNT_DUE_REMAINING > 0
	  AND  DUE_DATE < sysdate - l_maximum_days_past_due;
   EXCEPTION

	  WHEN NO_DATA_FOUND THEN
          p_check_past_due := 'N';
          oe_debug_pub.ADD('OEXPCRCB.pls: No Invoices Past due -- line level' );
       WHEN TOO_MANY_ROWS THEN
		null;
   END;


 end if;
 oe_debug_pub.ADD('OEXPCRCB.pls: Line level Past due Invoice Check:' || p_check_past_due);
EXCEPTION

  WHEN others THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         OE_MSG_PUB.Add_Exc_Msg
                   (   G_PKG_NAME
                      ,'chk_past_due_invoice'
                   );
     END IF;
     RAISE;

END chk_past_due_invoice_line;


-- calculates total exposure, find credit limits and determin result for calling function.
/* additional task - made the procedure Check_trx_Limit
   local to this package and added p_credit_rule_id as
   an additional input parameter */


PROCEDURE Check_Trx_Limit_Line
(   p_header_rec			IN  	OE_Order_PUB.Header_Rec_Type
,   p_invoice_to_org_id  IN   NUMBER
,   p_customer_id        IN   NUMBER
,   p_credit_rule_id		IN 	NUMBER
,   p_credit_level            IN   VARCHAR2
,   p_trx_credit_limit		IN   NUMBER	:= FND_API.G_MISS_NUM
,   p_total_exposure		IN	NUMBER
,   p_overall_credit_limit	IN 	NUMBER
,   p_result_out 			OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
,   p_return_status			OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
)
IS

l_order_value		      NUMBER;
l_include_tax_flag VARCHAR2(1) := 'Y';

l_order_commitment            NUMBER;

BEGIN

-- Initialize return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;

-- Default to Pass
    p_result_out := 'PASS';

/*	additional task-  Read the value of include_tax_flag from credit check rule
	and calculate the value of l_order_values accordingly */

/* 	If the value of include_tax_flag is NULL that means it is 'No' */

	select 	NVL(include_tax_flag, 'N')
	into 	l_include_tax_flag
	from		OE_CREDIT_CHECK_RULES
	where 	CREDIT_CHECK_RULE_ID = p_credit_rule_id;

   -- Total order limit of the site should be compared against
   -- the sum of all the lines that has this site
   -- Depending on the value of tax_flag add the tax_value
   /*
   ** Commenting based on the discussion with zbutt on 07/16/01
   ** Only one select to find out Trxn level order total needed
   IF p_credit_level = 'SITE' THEN
   */
	SELECT   SUM(decode(l_include_tax_flag , 'Y', NVL(tax_value,0),0)
					+ (NVL(unit_selling_price,0)
					* (NVL(ordered_quantity,0) )))
	  INTO   l_order_value
	  FROM   OE_ORDER_LINES
    	 WHERE   HEADER_ID = p_header_rec.header_id
        AND   invoice_to_org_id = p_invoice_to_org_id;
/*
   ELSE
     SELECT   SUM(decode(l_include_tax_flag , 'Y', NVL(tax_value,0),0)
                         + (NVL(unit_selling_price,0)
                         * (NVL(ordered_quantity,0) )))
       INTO   l_order_value
       FROM   OE_ORDER_LINES
      WHERE   HEADER_ID = p_header_rec.header_id
        AND   sold_to_org_id = (select organization_id
                                  from oe_sold_to_orgs_v
                                 where customer_id = p_customer_id);


   END IF;
*/

-- Get Total Commitments applied to the current order if Commitment Sequencing is "On"
    IF OE_Commitment_PVT.Do_Commitment_Sequencing THEN

	SELECT NVL(SUM(P.commitment_applied_amount), 0)
	INTO   l_order_commitment
	FROM   OE_PAYMENTS P, OE_ORDER_LINES L
	WHERE  P.HEADER_ID         = p_header_rec.header_id
	AND    L.LINE_ID           = P.LINE_ID
	AND    L.INVOICE_TO_ORG_ID = p_invoice_to_org_id;

        oe_debug_pub.ADD('OEXPCRCB.pls: line level trx commitment total:' || l_order_commitment);

        -- get the actual order value subject to credit check.
        l_order_value := l_order_value - l_order_commitment;

    END IF;

-- If credit available is less than the total exposure or
-- if the order amount is greater than the transaction limit
-- Return Failure

   oe_debug_pub.ADD('OEXPCRCB.pls: line level total exposure is:' ||p_total_exposure );
   oe_debug_pub.ADD('OEXPCRCB.pls: line level total credit limit:' || p_overall_credit_limit);
   oe_debug_pub.ADD('OEXPCRCB.pls: line level total order value:' || l_order_value);
   oe_debug_pub.ADD('OEXPCRCB.pls: line level order credit limit:' || p_trx_credit_limit);
   -- Replaced this code
   -- IF l_order_value > p_trx_credit_limit OR
   --    p_total_exposure > p_overall_credit_limit THEN
   --      p_result_out := 'FAIL';
   --      oe_debug_pub.ADD('Over credit limit');
   -- END IF;

   -- With this
   if (p_trx_credit_limit <> -1) then
     if (l_order_value > p_trx_credit_limit) then
       p_result_out := 'FAIL';
       oe_debug_pub.ADD('Line Level: Order Value greater then Transaction Limit.');
     end if;
   end if;
   if (p_overall_credit_limit <> -1) then
     if (p_total_exposure > p_overall_credit_limit) then
        p_result_out := 'FAIL';
        oe_debug_pub.ADD('Line Level: Total Exposure is greater then Overall Credit Limit');
     end if;
   end if;


EXCEPTION

     WHEN others THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Trx_Limit_Line'
            );
        END IF;
	RAISE ;

END Check_Trx_Limit_Line;



-- Mainline Function that will read an Order Header and Determine if
-- should be checked, calculates total exposure, find credit limits
-- and determine result for calling function.

----------------------------------------------------------------------------
PROCEDURE Check_Available_Credit_Line
(   p_header_id          IN   NUMBER    := FND_API.G_MISS_NUM
,   p_invoice_to_org_id 	IN 	NUMBER	:= FND_API.G_MISS_NUM
,   p_calling_action	IN	VARCHAR2 :=  'BOOKING'
,   p_msg_count		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_msg_data			OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   p_result_out		OUT NOCOPY /* file.sql.39 change */	VARCHAR2    -- Pass or Fail Credit Check
,   p_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
)
IS
l_header_rec             OE_Order_PUB.Header_Rec_Type;
--l_line_rec               OE_Order_PUB.Line_Rec_Type;
l_credit_rule_id		NUMBER;
l_credit_level			VARCHAR2(30); -- are the limits at the customer
							    -- or site level
--l_order_value		     NUMBER;
l_check_order		     VARCHAR2(1);  -- Indicates if this Order is
							    -- subject to credit check
l_total_exposure	     NUMBER;
l_trx_credit_limit		NUMBER;
l_overall_credit_limit	NUMBER;
l_result_out			VARCHAR2(30);
l_return_status		VARCHAR2(30);
l_check_past_due         VARCHAR2(1); -- if any invoice is past due
l_customer_id            NUMBER;
BEGIN

-- Set the default behaviour to pass credit check
--  oe_debug_pub.debug_on;

   p_result_out := 'PASS';
   p_return_status := FND_API.G_RET_STS_SUCCESS;

   oe_debug_pub.ADD('Line Level: Calling action is   '|| p_calling_action);

-- The first thing to do is to load the record structure for the order header
-- This is done in the OE_HEADER_UTIL package by the Query Row function.
-- The caller must pass a Header id and the function returns the record
-- Structure l_header_rec

   oe_debug_pub.ADD('Line Level: Before querying');
   OE_HEADER_UTIL.QUERY_ROW(p_header_id  => p_header_id
                           ,x_header_rec => l_header_rec);

  -- OE_LINE_UTIL.Query_Row(p_line_id  => p_line_id
  --					,x_line_rec => l_line_rec );


   BEGIN
      SELECT customer_id
        INTO l_customer_id
        FROM oe_invoice_to_orgs_v
       WHERE ORGANIZATION_ID = p_invoice_to_org_id;
   EXCEPTION
        WHEN no_data_found then
             --x_return_status := FND_API.G_RET_STS_ERROR;
             --FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_SITE_USE_ID');
             --OE_MSG_PUB.ADD;
             --fnd_message.set_token('SITE_USE_ID',
             --        to_char(p_hold_entity_id));
             OE_Debug_PUB.Add('OEXPCRCB: Line Level: No Customer ID for Bill to:' ||
                     to_char(p_invoice_to_org_id), 1);
             RAISE FND_API.G_EXC_ERROR;
    END;
    OE_Debug_PUB.Add('OEXPCRCB: Line Level: Customer ID:' ||
                  to_char(l_customer_id), 1);
-- Now we have the Record Structure loaded we can call the other
-- functions without having to go to the database.
-- Checking whether the order should undergo a credit check. Also
-- returns whether the check should be at the customer level or the
-- bill-to site level and the credit limits at that level.

    oe_debug_pub.ADD('just before the check Line procedure');
    OE_Credit_PUB.Check_Order_Line
    (   l_header_rec
    ,   p_invoice_to_org_id
    ,   l_customer_id
    ,   p_calling_action
    ,   l_check_order
    ,   l_credit_rule_id
    ,   l_credit_level
    ,   l_overall_credit_limit
    ,   l_trx_credit_limit
    ,   l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

IF l_check_order = 'Y' THEN

-- If the Order is subject to Credit Check i.e. l_check_order = 'Y'
-- First check if there are any unpaid invoices that are passed the
-- maximum due dates.
   oe_debug_pub.ADD('Line Level: Calling Check Past Due Invoice procedure');

   oe_credit_pub.chk_past_due_invoice_line (
		  l_header_rec
           ,p_invoice_to_org_id
           ,l_customer_id
		 ,l_credit_rule_id
		 ,l_credit_level
           ,l_check_past_due
		 ,l_return_status
			  );
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  IF l_check_past_due = 'N' THEN
      -- Determine total exposure.

      oe_debug_pub.ADD('Line Level: Calling the check exposure procedure');
	 OE_Credit_PUB.Check_Exposure_Line
	 (   l_header_rec
      ,   p_invoice_to_org_id
      ,   l_customer_id
	 ,   l_credit_rule_id
	 ,   l_credit_level
	 ,   l_total_exposure
	 ,   l_return_status
	 );

	 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
	 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

	 oe_debug_pub.ADD('Line Level: Credit Rule Id ='||to_char(l_credit_rule_id));

--  Next, compare the order amount and the exposure to the
--  order credit limit and total credit limit.

     /* additional task  - now credit_rule_id is passed to Check_trx_Limit_line*/


	OE_Credit_PUB.Check_Trx_Limit_Line
	(   l_header_rec
	,   p_invoice_to_org_id
     ,   l_customer_id
	,   l_credit_rule_id
     ,   l_credit_level            -- New
	,   l_trx_credit_limit
	,   l_total_exposure
     ,   l_overall_credit_limit
     ,   l_result_out
	,   l_return_status
	);

	oe_debug_pub.add('Line Level: After the call for check_Trx_Limit_Line');
     oe_debug_pub.add('Line level: Result out ='||l_result_out);
	oe_debug_pub.add('Line Level: Return Status ='||l_return_status);

	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

     p_result_out := l_result_out;

  ELSE   -- l_check_past_due = 'N'
    oe_debug_pub.ADD('Line Level: Past due Invoices: Credit Check Failed');
    p_result_out := 'FAIL';
  END IF; -- l_check_past_due = 'N'
ELSE -- if credit check order = N

         oe_debug_pub.ADD('Line Level: No credit check required');
    --   FND_MESSAGE.SET_NAME('OE', 'OE_NO_CREDIT_CHECK_REQUIRED');
    --   FND_MSG_PUB.ADD;
    --   null;

END IF;

          -- oe_debug_pub.dumpdebug;
          -- oe_debug_pub.debug_off;

-- Count the Messages on the Message Stack and if only 1 return it in
-- message data.
-- If more than 1 just return the count.  The Calling routine has to get
-- the messages from the message stack.

    OE_MSG_PUB.Count_And_Get
    (   p_count		=> 	p_msg_count
    ,   p_data		=>	p_msg_data
    );

    EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        p_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Available_Credit'
            );
        END IF;

END Check_Available_Credit_Line;

/* ----------------------------------------------------------------------
    Procedure to determine if the Line is subject to credit check and
    if it is, return whether the check is at the site level or at the
    customer level. Also, returns the credit limits at that level.
-------------------------------------------------------------------------
*/


PROCEDURE Check_Order_Line
(   p_header_rec              IN   OE_Order_PUB.Header_Rec_Type
,   p_invoice_to_org_id       IN  	NUMBER
,   p_customer_id             IN   NUMBER
,   p_calling_action		IN    VARCHAR2	:= 'BOOKING'
,   p_check_Order_out		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   p_credit_rule_out		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_credit_check_lvl_out 	OUT NOCOPY /* file.sql.39 change */	VARCHAR2
,   p_overall_credit_limit	OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_trx_credit_limit		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_return_status		OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
)
IS
-- Set up working Variables for Check Order
l_credit_limit_test 	NUMBER		:= FND_API.G_MISS_NUM;
l_credit_check_term 	NUMBER		:= FND_API.G_MISS_NUM;
l_credit_check_rule_id	NUMBER		:= FND_API.G_MISS_NUM;
l_credit_check_lvl_out  VARCHAR2(30)	:= 'SITE';
l_check_order		VARCHAR2(1);

BEGIN
   -- Function to Determine if the Order Type is Subject to Credit Check
   -- Assume that the Order is subject to credit Check by setting the
   -- l_check_order variable to Yes.

    p_check_Order_out := 'Y';
    l_check_Order := 'Y';

   -- Set up a variable to capture the situation of having no credit
   -- profile set up.

   p_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Read the Credit Rules on the Order Type Definition for the
   -- Order Being Credit Checked.
   -- If Called from Validating the Order at Order Entry use the
   -- Entry Credit Check Rule.

  oe_debug_pub.ADD('Line Level: Which cchk rule');
  IF p_calling_action = 'BOOKING' THEN
    oe_debug_pub.ADD('Line Level: Selecting the order entry cchk rule');
/*7194250
    SELECT NVL(ENTRY_CREDIT_CHECK_RULE_ID, -1)
    INTO l_credit_check_rule_id
    FROM OE_ORDER_TYPES_V
    WHERE ORDER_TYPE_ID = p_header_rec.order_type_id;
7194250*/
--7194250
BEGIN  --7695423
    SELECT NVL(ENTRY_CREDIT_CHECK_RULE_ID, -1)
    INTO l_credit_check_rule_id
    FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE OT.ORDER_TYPE_ID = p_header_rec.order_type_id
    AND   ENTRY_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7695423 start
EXCEPTION
WHEN OTHERS THEN
l_credit_check_rule_id := -1;
END;
--7695423 end

--7194250
    -- If not Use the Shipping Rule for all other calling Actions
    OE_Verify_Payment_PUB.G_credit_check_rule := 'Ordering';   --ER#7479609
  ELSE
    oe_debug_pub.ADD('Line Level: Selecting the shipping cchk rule');
/*7194250
    SELECT NVL(SHIPPING_CREDIT_CHECK_RULE_ID, -1)
    INTO l_credit_check_rule_id
    FROM OE_ORDER_TYPES_V
    WHERE ORDER_TYPE_ID = p_header_rec.order_type_id;
7194250*/
--7194250
BEGIN --7695423
    SELECT NVL(SHIPPING_CREDIT_CHECK_RULE_ID, -1)
    INTO l_credit_check_rule_id
    FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE OT.ORDER_TYPE_ID = p_header_rec.order_type_id
    AND   SHIPPING_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7695423 start
EXCEPTION
WHEN OTHERS THEN
l_credit_check_rule_id := -1;
END;
--7695423 end

--7194250
    OE_Verify_Payment_PUB.G_credit_check_rule := 'Shipping';   --ER#7479609
  END IF;

  -- If no credit rule was found for the calling action the Order
  -- is not subject to credit check

    oe_debug_pub.ADD('line level: check order after selecting credit rule : '|| l_check_order);
    IF l_credit_check_rule_id <= 0 THEN
       oe_debug_pub.ADD('Line Level: No Credit Check rule defined for ' || p_calling_action);
       l_check_order := 'N';
    END IF;

  -- If the Order type is subject to credit check we should check the
  -- bill to site and customer to see if they are subject to credit check.

IF l_check_order = 'Y' THEN

-- The Order type is Subject to Credit Check.
-- Procedure to determine if the Order Bill to is subject to Credit Check
-- Get the flags that control if credit check should be performed
-- from the Credit Profile.  Get the Credit Limit Amounts from the
-- Credit Profile Amounts for the Customers Bill to Address.

BEGIN

    SELECT NVL(CP.CREDIT_CHECKING, 'N')
    ,   (NVL(CPA.OVERALL_CREDIT_LIMIT,-1) + NVL(CPA.TRX_CREDIT_LIMIT, -1))
    ,   NVL(CPA.OVERALL_CREDIT_LIMIT * ((100 + CP.TOLERANCE)/100), -1)
    ,   NVL(CPA.TRX_CREDIT_LIMIT * ((100 + CP.TOLERANCE)/100), -1)
    INTO l_check_order
    ,   l_credit_limit_test
    ,   p_overall_credit_limit
    ,   p_trx_credit_limit
    FROM HZ_CUSTOMER_PROFILES CP
    ,   HZ_CUST_PROFILE_AMTS CPA
    WHERE CP.CUST_ACCOUNT_ID = p_customer_id
    AND CP.SITE_USE_ID = p_invoice_to_org_id
    AND CPA.CUST_ACCOUNT_ID = CP.CUST_ACCOUNT_ID
    AND CPA.SITE_USE_ID = CP.SITE_USE_ID
    AND CPA.CUST_ACCOUNT_PROFILE_ID = CP.CUST_ACCOUNT_PROFILE_ID
    AND CPA.CURRENCY_CODE = p_header_rec.transactional_curr_code;

      -- If we find a Credit Profile at this level the customer has credit limits
      -- at the site level.
      l_credit_check_lvl_out := 'SITE';
   oe_debug_pub.ADD('Line Level: Site/CheckFlag/Limit Lest/overall_credit_limit/trx_credit_limit:'
                   ||  to_char(p_invoice_to_org_id) || '/'
                   ||  l_check_order || '/'
			    ||  to_char(l_credit_limit_test) || '/'
                   ||  to_char(p_overall_credit_limit) || '/'
                   ||  to_char(p_trx_credit_limit) );

    EXCEPTION

      WHEN NO_DATA_FOUND THEN
        -- If we do not find a Credit Profile we will assume that the credit
        -- limits are set at the customer level.
        oe_debug_pub.ADD('Line Level: Customer level credit check');
        l_credit_check_lvl_out := 'CUSTOMER';
      WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check Order:Check Customer'
            );
        END IF;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

  -- If no credit limit has been set for either the total Order Amount
  -- or the Total Exposure, get the credit profiles from the customer level
    IF l_credit_limit_test < 0 and l_credit_check_lvl_out ='SITE' THEN
          l_credit_check_lvl_out := 'CUSTOMER';
    END IF;

END IF; -- Check if the Order type is subject to credit check for site or customer

    oe_debug_pub.ADD('line level: check order after selecting site/customer level : ' || l_check_order);
    oe_debug_pub.ADD('level for credit check: '|| l_credit_check_lvl_out);
IF l_check_order = 'Y' AND  l_credit_check_lvl_out = 'CUSTOMER' THEN

  -- If both the Order type and the Bill to are subject to credit check
  -- and no credit profile was found at the bill to site go on to
  -- check if the customer is subject to credit check.
  -- Procedure to Determine if the Customer is subject to Credit Check

  BEGIN

    SELECT NVL(CP.CREDIT_CHECKING,'N')
    ,   (NVL(CPA.OVERALL_CREDIT_LIMIT,-1) + NVL(CPA.TRX_CREDIT_LIMIT, -1))
    ,   NVL(CPA.OVERALL_CREDIT_LIMIT * ((100 + CP.TOLERANCE)/100), -1)
    ,   NVL(CPA.TRX_CREDIT_LIMIT * ((100 + CP.TOLERANCE)/100), -1)
    INTO l_check_order
    ,   l_credit_limit_test
    ,   p_overall_credit_limit
    ,   p_trx_credit_limit
    FROM HZ_CUSTOMER_PROFILES CP
    ,   HZ_CUST_PROFILE_AMTS CPA
    WHERE  CP.CUST_ACCOUNT_ID = p_customer_id
    AND CP.CUST_ACCOUNT_PROFILE_ID = CPA.CUST_ACCOUNT_PROFILE_ID
    AND CPA.CURRENCY_CODE = p_header_rec.transactional_curr_code
    AND CP.SITE_USE_ID IS NULL;

    oe_debug_pub.ADD('Customer/CheckFlag/LimitTest/overall_credit_limit/trx_credit_limit:'
                   ||  to_char(p_customer_id) || '/'
                   ||  l_check_order || '/'
			    ||  to_char(l_credit_limit_test) || '/'
                   ||  to_char(p_overall_credit_limit) || '/'
                   ||  to_char(p_trx_credit_limit) );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    -- If we don't find a credit profile at the customer level, no
    -- credit checking needed.
        l_check_order := 'N';

    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check Order:Check Customer'
            );
        END IF;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

  -- If no credit limit has been set for either the total Order Amount
  -- or the Total Exposure, do not credit check
    IF l_credit_limit_test < 0 THEN
        l_check_order := 'N';
    END IF;
    oe_debug_pub.ADD('check order after determining credit limits :'|| l_check_order);
END IF; -- The Order type Subject to Credit Check No credit profile at bill to.

IF l_check_order = 'Y' THEN

  -- Order Type, Bill to or Customer are subject to Credit Check
  -- If the Order Type, Bill to Site and Customer are subject to credit check,
  -- go on to check if the payment term is subject to credit check.
  -- Procedure to Determine if Payment Term is subject to Credit Check
  -- Check if line on the order has a payment term that requires credit checking.

  -- Check to see if all the lines for this bill to have payment term set to 'Y'
  BEGIN

    SELECT COUNT(*)
    INTO l_credit_check_term
    FROM OE_ORDER_LINES L, OE_RA_TERMS_V T
    WHERE L.header_id = p_header_rec.header_id
      AND L.invoice_to_org_id    = p_invoice_to_org_id
      AND L.PAYMENT_TERM_ID = T.TERM_ID
      AND NVL(T.CREDIT_CHECK_FLAG, 'Y') = 'Y';

    -- If all the lines does not have a payment term that is subject to credit check
    -- we should exempt the bill to  from credit check.
     IF l_credit_check_term = 0 THEN
        l_check_order := 'N';
        oe_debug_pub.ADD('Line does not have Payment Term subject to credit check');
     END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_check_order := 'N';
         oe_debug_pub.ADD('Line does not have Payment Term subject to credit check');
       WHEN OTHERS THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Order: Check Terms'
            );
        END IF;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;

  END IF; -- Order Type, Bill to or Customer are subject to Credit Check

    p_credit_check_lvl_out := l_credit_check_lvl_out;
    p_credit_rule_out      := l_credit_check_rule_id;
    p_check_Order_out       := l_check_order;

    oe_debug_pub.ADD('check order after checking payment term :'|| l_check_order);
    EXCEPTION

    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Order'
            );
        END IF;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Check_Order_line;


PROCEDURE Check_Exposure_Line
(   p_header_rec            	IN  	OE_Order_PUB.Header_Rec_Type
,   p_invoice_to_org_id       IN   NUMBER
,   p_customer_id             IN   NUMBER
,   p_credit_check_rule_id	IN   NUMBER
,   p_credit_level            IN   VARCHAR2
,   p_total_exposure		OUT NOCOPY /* file.sql.39 change */	NUMBER
,   p_return_status		     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_open_ar_balance_flag		Varchar2(1) := 'Y';
l_open_ar_days			NUMBER;
l_uninvoiced_orders_flag 	Varchar2(1) := 'Y';
l_orders_on_hold_flag		Varchar2(1) := 'Y';

/* additional task -added the following variable */
l_include_tax_flag 			Varchar2(1) := 'Y';

l_shipping_horizon		Date := TO_DATE('31/12/4712', 'DD/MM/YYYY');
l_include_risk_flag		Varchar2(1) := 'Y';
l_total_from_ar		NUMBER   := 0;
l_total_on_order	     NUMBER   := 0;
l_total_on_hold		NUMBER   := 0;
l_total_exposure	     NUMBER   := 0;
l_payments_at_risk		NUMBER   := 0;
l_current_order 		NUMBER := 0;

-- ZB
l_maximum_days_past_due  NUMBER   := 0;

--additional task :  added the following variable
l_est_valid_days         NUMBER := 0 ;

l_total_commitment       NUMBER := 0;
l_current_commitment     NUMBER := 0;
l_on_hold_commitment     NUMBER := 0;

/* additional task - for adding the Include Tax option, the cursor needs to be modified */

Cursor credit_check_rule IS
        SELECT       OPEN_AR_BALANCE_FLAG
	            ,   OPEN_AR_DAYS
	            ,   UNINVOICED_ORDERS_FLAG
	            ,   ORDERS_ON_HOLD_FLAG
			  ,   INCLUDE_TAX_FLAG
	            ,   DECODE(SHIPPING_INTERVAL, NULL,
                                TO_DATE('31/12/4712', 'DD/MM/YYYY'),
                                SHIPPING_INTERVAL+SYSDATE)
	            ,   INCLUDE_PAYMENTS_AT_RISK_FLAG
        FROM		OE_CREDIT_CHECK_RULES
	   WHERE		CREDIT_CHECK_RULE_ID = p_credit_check_rule_id;

Cursor ar_balance IS
   SELECT	        NVL(SUM(AMOUNT_DUE_REMAINING), 0)
	FROM		AR_PAYMENT_SCHEDULES
    WHERE		CUSTOMER_ID = p_customer_id
       AND    INVOICE_CURRENCY_CODE = p_header_rec.transactional_curr_code
	  AND		NVL(RECEIPT_CONFIRMED_FLAG, 'Y') = 'Y';

Cursor ar_balance_in_ar_days IS
        SELECT	        NVL(SUM(AMOUNT_DUE_REMAINING), 0)
	FROM		AR_PAYMENT_SCHEDULES
	WHERE		CUSTOMER_ID = p_customer_id
     AND       INVOICE_CURRENCY_CODE = p_header_rec.transactional_curr_code
	AND		NVL(RECEIPT_CONFIRMED_FLAG, 'Y') = 'Y'
	AND 		SYSDATE - TRX_DATE > l_open_ar_days;

Cursor pay_risk IS
        SELECT NVL(SUM(CRH.AMOUNT), 0)
	FROM AR_CASH_RECEIPT_HISTORY CRH,
          AR_CASH_RECEIPTS CR
    WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
	 AND	NVL(CR.CONFIRMED_FLAG,'Y') = 'Y'
	 AND	CRH.CURRENT_RECORD_FLAG = 'Y'
	 AND	CRH.STATUS <> DECODE(CRH.FACTOR_FLAG,'Y',
				               'RISK_ELIMINATED','CLEARED')
	 AND	CRH.STATUS <> 'REVERSED'
      AND	CR.CURRENCY_CODE = p_header_rec.transactional_curr_code
	AND	CR.PAY_FROM_CUSTOMER = p_customer_id;

Cursor pay_risk_in_ar_days IS
   SELECT NVL(SUM(CRH.AMOUNT), 0)
	FROM AR_CASH_RECEIPT_HISTORY CRH
	,    AR_CASH_RECEIPTS CR
	WHERE	CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
	AND	NVL(CR.CONFIRMED_FLAG,'Y') = 'Y'
	AND 	CRH.CURRENT_RECORD_FLAG = 'Y'
	AND	CRH.STATUS <>
	        DECODE(CRH.FACTOR_FLAG,'Y',
				'RISK_ELIMINATED','CLEARED')
	AND	CRH.STATUS <> 'REVERSED'
     AND	CR.CURRENCY_CODE = p_header_rec.transactional_curr_code
	AND	CR.PAY_FROM_CUSTOMER = p_customer_id
     AND  SYSDATE - CR.RECEIPT_DATE > l_open_ar_days;


/* additional task : modified the following 2 cursors uninvoiced_orders and
		 orders_on_hold for the following purpose
   1. excluded unbooked orders
   2. excluded orders authorized by credit card
   3. Exclude the Current Order

   So far there was a bug in the application - if the current order was
   on hold and booked then current order value was not getting included
   into the credit exposure. With present logic, we exclude the current order
   initially while calculating the uninvoiced order total and orders_on_hold
   total and then add it up later. Because irrespective of the fact that
   current order is booked/entered/on hold etc, we have to take care of that
   amount in Credit exposure.

   Two additional conditions has been added for all cursors related
   to Include Uninvoiced Orders. We will consider only those orders
   which are not invoiced yet, i.e. invoiced qty is zero.
   Also we should consider Open Orders Only
   The decode statement has been added to improve performance*/

Cursor uninvoiced_orders(p_include_tax VARCHAR2)  IS
        SELECT /* MOAC_SQL_CHANGE */  SUM((NVL(ordered_quantity,0)
	         *NVL(unit_selling_price,0)) + decode(p_include_tax,'Y',NVL(tax_value,0), 0))
	FROM 	 OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
	WHERE	 H.SOLD_TO_ORG_ID = p_customer_id
        AND      H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND	 	 H.HEADER_ID = L.HEADER_ID
	AND        NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
		               <= l_shipping_horizon
     AND        NVL(L.INVOICED_QUANTITY,0) = 0
	AND        L.OPEN_FLAG ='Y'
	AND		 L.LINE_CATEGORY_CODE ='ORDER'
	AND 		 H.BOOKED_FLAG = 'Y'
	AND        H.HEADER_ID <> p_header_rec.header_id
        /*
	AND	 	 decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
		(H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate;
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  );

/* old code, logic remaining same:
	AND       (H.CREDIT_CARD_APPROVAL_CODE IS NULL
			OR
			(H.CREDIT_CARD_APPROVAL_CODE IS NOT NULL
			AND  H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days < SYSDATE))*/

Cursor /* MOAC_SQL_CHANGE */ orders_on_hold(p_include_tax VARCHAR2) IS
        SELECT   SUM((NVL(ordered_quantity,0)
	         *NVL(unit_selling_price,0)) + decode(p_include_tax, 'Y',NVL(tax_value,0),0))
	FROM 	OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
	WHERE	H.SOLD_TO_ORG_ID = p_customer_id
        AND      H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND	 	H.HEADER_ID = L.HEADER_ID
	AND       NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon
	AND       NVL(L.INVOICED_QUANTITY,0) = 0
	AND       L.OPEN_FLAG ='Y'
	AND       L.LINE_CATEGORY_CODE ='ORDER'
        AND       H.BOOKED_FLAG = 'Y'
	AND       H.HEADER_ID <> p_header_rec.header_id
        /*
	AND       decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
			(H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  )
	AND	 	EXISTS (SELECT 	1
		             FROM 	OE_ORDER_HOLDS OH
			        WHERE	H.HEADER_ID = OH.HEADER_ID
			        AND    OH.HOLD_RELEASE_ID IS NULL
				   );
Cursor commitment_total IS
        SELECT /* MOAC_SQL_CHANGE */ NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P, OE_ORDER_HEADERS H, OE_ORDER_LINES_ALL L
	WHERE  H.SOLD_TO_ORG_ID = p_customer_id
        AND      H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND    H.BOOKED_FLAG    = 'Y'
	AND    H.HEADER_ID      = P.HEADER_ID
	AND    H.HEADER_ID     <> p_header_rec.header_id
        /*
	AND    decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
		     (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  )
        AND    L.HEADER_ID                = H.HEADER_ID
        AND    L.LINE_ID                  = P.LINE_ID
        AND    NVL(L.INVOICED_QUANTITY,0) = 0
	AND    L.OPEN_FLAG                = 'Y'
	AND    L.LINE_CATEGORY_CODE       = 'ORDER'
	AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
		               <= l_shipping_horizon;

Cursor on_hold_commitment_total IS
        SELECT /* MOAC_SQL_CHANGE */ NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P, OE_ORDER_HEADERS H, OE_ORDER_LINES_ALL L
	WHERE  H.SOLD_TO_ORG_ID = p_customer_id
        AND      H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND    H.BOOKED_FLAG    = 'Y'
	AND    H.HEADER_ID      = P.HEADER_ID
	AND    H.HEADER_ID     <> p_header_rec.header_id
        /*
	AND    decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
		     (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  )
        AND    L.HEADER_ID                = H.HEADER_ID
        AND    L.LINE_ID                  = P.LINE_ID
        AND    NVL(L.INVOICED_QUANTITY,0) = 0
	AND    L.OPEN_FLAG                = 'Y'
	AND    L.LINE_CATEGORY_CODE       = 'ORDER'
	AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
		               <= l_shipping_horizon
	AND    EXISTS (SELECT 	1
	       FROM    OE_ORDER_HOLDS OH
	       WHERE   H.HEADER_ID = OH.HEADER_ID
	       AND     OH.HOLD_RELEASE_ID IS NULL);

Cursor current_commitment_total IS
        SELECT /* MOAC_SQL_CHANGE */ NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P, OE_ORDER_HEADERS H, OE_ORDER_LINES_ALL L
        WHERE  H.HEADER_ID = p_header_rec.header_id
        AND    H.HEADER_ID = P.HEADER_ID
        AND    L.HEADER_ID = H.HEADER_ID
        AND    L.INVOICE_TO_ORG_ID = p_invoice_to_org_id
        AND    L.LINE_ID   = P.LINE_ID
        AND    NVL(L.INVOICED_QUANTITY,0) = 0
        AND    L.OPEN_FLAG ='Y'
        AND    L.LINE_CATEGORY_CODE ='ORDER'
        /*
        AND    decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
                    (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate;
        */
        AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
                  OR (h.payment_type_code = 'CREDIT_CARD'
                      AND NOT EXISTS
                        (Select 'valid auth code'
                         From   oe_payments op,
                                iby_trxn_ext_auths_v ite
                         Where  op.header_id = h.header_id
                         And    op.trxn_extension_id = ite.trxn_extension_id
                         And    authorization_status = 0
                         And    effective_auth_amount > 0)
                      )
                  );

Cursor current_order(p_include_tax VARCHAR2) IS
     SELECT   /* MOAC_SQL_CHANGE */  SUM((NVL(ordered_quantity,0)
                 *NVL(unit_selling_price,0)) + decode(p_include_tax,'Y',  NVL(tax_value,0), 0))
     FROM      OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
     WHERE     H.HEADER_ID = p_header_rec.header_id
     AND       H.HEADER_ID = L.HEADER_ID
     AND       L.INVOICE_TO_ORG_ID = p_invoice_to_org_id
   --  AND       NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
   --                      <= to_date(l_shipping_horizon, 'DD-MON-YY')
     AND       NVL(L.INVOICED_QUANTITY,0) = 0
     AND       L.OPEN_FLAG ='Y'
     AND       L.LINE_CATEGORY_CODE ='ORDER'
     /*
     AND       decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
                    (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate;
     */
     AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
               OR (h.payment_type_code = 'CREDIT_CARD'
                   AND NOT EXISTS
                     (Select 'valid auth code'
                      From   oe_payments op,
                             iby_trxn_ext_auths_v ite
                      Where  op.header_id = h.header_id
                      And    op.trxn_extension_id = ite.trxn_extension_id
                      And    authorization_status = 0
                      And    effective_auth_amount > 0)
                   )
               );

-- CURSORS FOR SITE - LEVEL EXPOSURE CALCULATIONS
Cursor site_ar_balance IS
    SELECT  NVL(SUM(AMOUNT_DUE_REMAINING), 0)
      FROM  AR_PAYMENT_SCHEDULES
     WHERE  CUSTOMER_SITE_USE_ID  = p_invoice_to_org_id
       AND  INVOICE_CURRENCY_CODE = p_header_rec.transactional_curr_code
       AND  NVL(RECEIPT_CONFIRMED_FLAG, 'Y') = 'Y';

Cursor site_ar_balance_in_ar_days IS
 SELECT  NVL(SUM(AMOUNT_DUE_REMAINING), 0)
   FROM  AR_PAYMENT_SCHEDULES
  WHERE  CUSTOMER_SITE_USE_ID  = p_invoice_to_org_id
    AND  INVOICE_CURRENCY_CODE = p_header_rec.transactional_curr_code
    AND  NVL(RECEIPT_CONFIRMED_FLAG, 'Y') = 'Y'
    AND  SYSDATE - TRX_DATE > l_open_ar_days;

Cursor site_pay_risk IS
         SELECT NVL(SUM(CRH.AMOUNT),0)
         FROM   AR_CASH_RECEIPT_HISTORY CRH
                        ,      AR_CASH_RECEIPTS CR
         WHERE  CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
         AND    NVL(CR.CONFIRMED_FLAG,'Y') = 'Y'
         AND    CRH.CURRENT_RECORD_FLAG = 'Y'
         AND    CRH.STATUS <>
                           DECODE(CRH.FACTOR_FLAG,'Y',
                                  'RISK_ELIMINATED','CLEARED')
         AND    CRH.STATUS <> 'REVERSED'
         AND    CR.CURRENCY_CODE = p_header_rec.transactional_curr_code
 	 AND	CR.PAY_FROM_CUSTOMER = p_customer_id
         AND    CR.CUSTOMER_SITE_USE_ID = p_invoice_to_org_id;

Cursor site_pay_risk_in_ar_days IS
         SELECT NVL(SUM(CRH.AMOUNT),0)
         FROM   AR_CASH_RECEIPT_HISTORY CRH
                        ,      AR_CASH_RECEIPTS CR
         WHERE  CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
         AND    NVL(CR.CONFIRMED_FLAG,'Y') = 'Y'
         AND    CRH.CURRENT_RECORD_FLAG = 'Y'
         AND    CRH.STATUS <>
                           DECODE(CRH.FACTOR_FLAG,'Y',
                                  'RISK_ELIMINATED','CLEARED')
         AND    CRH.STATUS <> 'REVERSED'
         AND    CR.CURRENCY_CODE = p_header_rec.transactional_curr_code
 	 AND	CR.PAY_FROM_CUSTOMER = p_customer_id
         AND    CR.CUSTOMER_SITE_USE_ID = p_invoice_to_org_id
        AND     SYSDATE - TRX_DATE > l_open_ar_days;

/* additional task : modified the following 2 SITE cursors
   1. excluded unbooked orders
   2. excluded orders authorized by credit card
   3. Excludes the current order
*/

Cursor site_uninvoiced_orders(p_include_tax VARCHAR2) IS
     SELECT  /* MOAC_SQL_CHANGE */	SUM(((NVL(ordered_quantity,0) )
	         	*NVL(unit_selling_price,0)) + decode(p_include_tax, 'Y', nvl(tax_value,0), 0))
	FROM		OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
	WHERE	L.INVOICE_TO_ORG_ID = p_invoice_to_org_id
        AND      H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND	 	H.HEADER_ID = L.HEADER_ID
	AND       NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon
	AND       NVL(L.INVOICED_QUANTITY,0) = 0
	AND       L.OPEN_FLAG ='Y'
	AND       L.LINE_CATEGORY_CODE ='ORDER'
        AND       H.BOOKED_FLAG = 'Y'
	AND       H.HEADER_ID <> p_header_rec.header_id
        /*
	AND       decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
			(H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate;
        */
     	AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
       		  OR (h.payment_type_code = 'CREDIT_CARD'
                     AND NOT EXISTS
                     (Select 'valid auth code'
                      From   oe_payments op,
                             iby_trxn_ext_auths_v ite
                      Where  op.header_id = h.header_id
                      And    op.trxn_extension_id = ite.trxn_extension_id
                      And    authorization_status = 0
                      And    effective_auth_amount > 0)
                   )
               );

Cursor site_orders_on_hold(p_include_tax VARCHAR2) IS

	SELECT  /* MOAC_SQL_CHANGE */ 	SUM(((NVL(ordered_quantity,0))
	          *NVL(unit_selling_price,0)) + decode(p_include_tax, 'Y', NVL(tax_value,0),0))
	FROM		OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
	WHERE	L.INVOICE_TO_ORG_ID = p_invoice_to_org_id
        AND      H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND	 	H.HEADER_ID = L.HEADER_ID
	AND       NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon
	AND       NVL(L.INVOICED_QUANTITY,0) = 0
	AND       L.OPEN_FLAG ='Y'
	AND       L.LINE_CATEGORY_CODE ='ORDER'
        AND       H.BOOKED_FLAG = 'Y'
	AND       H.HEADER_ID <> p_header_rec.header_id
        /*
	AND       decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
			(H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
     	AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
       		  OR (h.payment_type_code = 'CREDIT_CARD'
                     AND NOT EXISTS
                     (Select 'valid auth code'
                      From   oe_payments op,
                             iby_trxn_ext_auths_v ite
                      Where  op.header_id = h.header_id
                      And    op.trxn_extension_id = ite.trxn_extension_id
                      And    authorization_status = 0
                      And    effective_auth_amount > 0)
                   )
               )
	AND	 	EXISTS (SELECT 	1
		             FROM 	OE_ORDER_HOLDS OH
			       WHERE	H.HEADER_ID = OH.HEADER_ID
			         AND    OH.HOLD_RELEASE_ID IS NULL
				 );

Cursor site_commitment_total IS
        SELECT /* MOAC_SQL_CHANGE */ NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P, OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
	WHERE  L.INVOICE_TO_ORG_ID        = p_invoice_to_org_id
        AND    H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND    H.HEADER_ID                = P.HEADER_ID
        AND    L.HEADER_ID                = H.HEADER_ID
        AND    L.LINE_ID                  = P.LINE_ID
	AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon
	AND    NVL(L.INVOICED_QUANTITY,0) = 0
	AND    L.OPEN_FLAG                = 'Y'
	AND    L.LINE_CATEGORY_CODE       = 'ORDER'
        AND    H.BOOKED_FLAG              = 'Y'
        /*
	AND    decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
	             (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate;
        */
     	AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
       		  OR (h.payment_type_code = 'CREDIT_CARD'
                     AND NOT EXISTS
                     (Select 'valid auth code'
                      From   oe_payments op,
                             iby_trxn_ext_auths_v ite
                      Where  op.header_id = h.header_id
                      And    op.trxn_extension_id = ite.trxn_extension_id
                      And    authorization_status = 0
                      And    effective_auth_amount > 0)
                   )
               );

Cursor site_on_hold_commitment_total IS
        SELECT /* MOAC_SQL_CHANGE */ NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P, OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
	WHERE  L.INVOICE_TO_ORG_ID        = p_invoice_to_org_id
        AND    H.TRANSACTIONAL_CURR_CODE = p_header_rec.transactional_curr_code
	AND    H.HEADER_ID                = P.HEADER_ID
        AND    L.HEADER_ID                = H.HEADER_ID
        AND    L.LINE_ID                  = P.LINE_ID
	AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
	         	        <= l_shipping_horizon
	AND    NVL(L.INVOICED_QUANTITY,0) = 0
	AND    L.OPEN_FLAG                = 'Y'
	AND    L.LINE_CATEGORY_CODE       = 'ORDER'
        AND    H.BOOKED_FLAG              = 'Y'
	AND    H.HEADER_ID <> p_header_rec.header_id
        /*
	AND    decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
	             (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate
        */
     	AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
       		  OR (h.payment_type_code = 'CREDIT_CARD'
                     AND NOT EXISTS
                     (Select 'valid auth code'
                      From   oe_payments op,
                             iby_trxn_ext_auths_v ite
                      Where  op.header_id = h.header_id
                      And    op.trxn_extension_id = ite.trxn_extension_id
                      And    authorization_status = 0
                      And    effective_auth_amount > 0)
                   )
               )
	AND    EXISTS (SELECT 	1
	               FROM 	OE_ORDER_HOLDS OH
		       WHERE	H.HEADER_ID = OH.HEADER_ID
		       AND    OH.HOLD_RELEASE_ID IS NULL);

/* additional task-  Current Order -  */

Cursor site_current_order(p_include_tax VARCHAR2) IS
	SELECT /* MOAC_SQL_CHANGE */   SUM((NVL(ordered_quantity,0)
			  *NVL(unit_selling_price,0)) + decode(p_include_tax,'Y',  NVL(tax_value,0), 0))
	FROM      OE_ORDER_LINES_ALL L, OE_ORDER_HEADERS H
	WHERE H.HEADER_ID = p_header_rec.header_id
	AND   H.HEADER_ID = L.HEADER_ID
        AND   L.invoice_to_org_id = p_invoice_to_org_id
   --     AND   NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,H.REQUEST_DATE))
   --             <= to_date(l_shipping_horizon, 'DD-MON-YY')
	AND   NVL(L.INVOICED_QUANTITY,0) = 0
	AND   L.OPEN_FLAG ='Y'
	AND   L.LINE_CATEGORY_CODE ='ORDER'
        /*
	AND   decode(H.CREDIT_CARD_APPROVAL_CODE, NULL, (sysdate -1),
               (H.CREDIT_CARD_APPROVAL_DATE + l_est_valid_days)) < sysdate;
        */
     	AND      (nvl(h.payment_type_code, 'NULL') <> 'CREDIT_CARD'
       		  OR (h.payment_type_code = 'CREDIT_CARD'
                     AND NOT EXISTS
                     (Select 'valid auth code'
                      From   oe_payments op,
                             iby_trxn_ext_auths_v ite
                      Where  op.header_id = h.header_id
                      And    op.trxn_extension_id = ite.trxn_extension_id
                      And    authorization_status = 0
                      And    effective_auth_amount > 0)
                   )
               );


BEGIN

 -- Set the default behaviour to pass credit check exposure
 p_return_status := FND_API.G_RET_STS_SUCCESS;
 -- Read the Credit rule and determine the inclusions and exclusions
 -- for exposure

 -- Include Amounts on Receivables if within the AR horizon.
 -- Add the OPEN_AR_DAYS
 -- to todays date to determine the AR Horizon.  Use this to compare the
 -- Due date on
 -- the Invoice. If the due_date is greater than system date by less than
 -- open_ar_days
 -- In the R10SC/R11, if the trx_date/invoice_date is earlier than system date
 -- by open_ar_days, those
 -- orders only are considered. So the check was WHERE SYSDATE - TRX_DATE >
 -- OPEN_AR_DAYS
 -- Include amounts on Order Backlog if within the shipping horizon.
 -- Add the Shipping Horizon
 -- to todays date to determin the shipping horizon.  Use this to compare
 -- the scheduled ship date on the order line.
 -- As in R10SC/R11, if the schedule_date (or when this field is null,
 -- request_date) is within the no. of shipping_interval days of the current
 -- date, include only those amounts for calculating uninvoiced orders total.

 oe_debug_pub.ADD('In Line Level Check Exposure');
 OPEN credit_check_rule;
 FETCH credit_check_rule INTO l_open_ar_balance_flag
				,   l_open_ar_days
				,   l_uninvoiced_orders_flag
				,   l_orders_on_hold_flag
				,   l_include_tax_flag
				,   l_shipping_horizon
				,   l_include_risk_flag;
 CLOSE credit_check_rule;

 oe_debug_pub.ADD('Credit Check Rule is as follows :');
 oe_debug_pub.ADD('Open AR Balance Flag ='||l_open_ar_balance_flag);
 oe_debug_pub.ADD('Open AR days ='||to_char(l_open_ar_days));
 oe_debug_pub.ADD('Uninvoiced Orders Flag ='||l_uninvoiced_orders_flag);
 oe_debug_pub.ADD('Orders On Hold flag ='||l_orders_on_hold_flag);
 oe_debug_pub.ADD('Include Tax Flag ='||l_include_tax_flag);
 oe_debug_pub.ADD('Shipping Horizon days ='||to_char(l_shipping_horizon, 'DD-MON-YYYY'));
 oe_debug_pub.ADD('Include Risk flag ='||l_include_risk_flag);

 l_est_valid_days :=
       to_number( nvl(fnd_profile.value('ONT_EST_AUTH_VALID_DAYS'), '0'));
 oe_debug_pub.ADD('Estimated Valid Days ='||to_char(l_est_valid_days));


 IF p_credit_level = 'CUSTOMER' THEN
 -- Retrieving exposure at CUSTOMER level

  IF l_open_ar_balance_flag = 'Y' THEN
    -- Find Accounts Receivable Exposure
    IF l_open_ar_days IS NULL THEN
      OPEN ar_balance;
      FETCH ar_balance INTO l_total_from_ar;
      IF ar_balance%notfound THEN
         l_total_from_ar := 0;
      END IF;
      CLOSE ar_balance;
    ELSE
      OPEN ar_balance_in_ar_days;
      FETCH ar_balance_in_ar_days INTO l_total_from_ar;
      IF ar_balance_in_ar_days%notfound THEN
         l_total_from_ar := 0;
      END IF;
      CLOSE ar_balance_in_ar_days;
    END IF; -- If l_open_ar_days is null

   oe_debug_pub.ADD('Open Receivables Balance: '||l_total_from_ar);

   /*********************************************************************
    *  If the include payments at risk flag is set to yes, Update the   *
    *  exposure by payments that are not thought to be collectable      *
    * These payments are in the cash receipts history                   *
    *********************************************************************/

    IF l_include_risk_flag = 'Y' THEN

      IF l_open_ar_days IS NULL THEN
	   OPEN pay_risk;
	   FETCH pay_risk INTO l_payments_at_risk;
        IF pay_risk%notfound THEN
	         l_payments_at_risk := 0;
	   END IF;
	   CLOSE pay_risk;
      ELSE
         OPEN pay_risk_in_ar_days;
         FETCH pay_risk_in_ar_days INTO l_payments_at_risk;
         IF pay_risk_in_ar_days%notfound THEN
	        l_payments_at_risk := 0;
	    END IF;
	    CLOSE pay_risk_in_ar_days;
      END IF;  -- If l_open_ar_days is null

      oe_debug_pub.ADD('Payments At Risk: '||l_payments_at_risk);

    END IF;  -- l_include_risk_flag (Include Payments at Risk)

    -- Update the total exposure value.
    l_total_exposure := nvl(l_total_from_ar,0) + nvl(l_payments_at_risk,0);
    oe_debug_pub.ADD('Accounts Receivables Exposure ='||
                        to_char(l_total_exposure));

  END IF; -- l_open_ar_balance_flag (checking accounts receivables exposure)

  -- Depending on the include_tax_flag value tax will be included or
  -- excluded from credit exposure calculation

  IF l_uninvoiced_orders_flag  = 'Y' THEN

     BEGIN
       OPEN uninvoiced_orders(l_include_tax_flag);
       FETCH uninvoiced_orders INTO l_total_on_order;
       IF uninvoiced_orders%notfound THEN
         oe_debug_pub.ADD('not found any uninvoiced orders');
         l_total_on_order := 0;
       END IF;
       CLOSE uninvoiced_orders;
		/*  WHEN others THEN
    		oe_debug_pub.ADD('not found');*/
     END;

     -- Now update the total exposure value to include the Order Backlog Value

     oe_debug_pub.ADD('Total amt. of uninvoiced orders: '|| l_total_on_order);
     l_total_exposure := l_total_exposure + nvl(l_total_on_order,0);

	oe_debug_pub.ADD('Exposure after taking care of uninvoiced orders='
                    || to_char(l_total_exposure));

     -- Next check if we should be excluding orders that are already on hold
     -- from the calculation of Total exposure

     IF l_orders_on_hold_flag = 'N' THEN
       -- Find the value of all orders that are the subject of an order hold
       -- at either the header or line level.

       OPEN orders_on_hold(l_include_tax_flag);
       FETCH orders_on_hold INTO l_total_on_hold;
       IF orders_on_hold%notfound THEN
            l_total_on_hold := 0;
       END IF;
       CLOSE orders_on_hold;

       -- Update the total exposure value to EXCLUDE the value of orders on hold
       oe_debug_pub.ADD('Total amount on hold:' || l_total_on_hold);

       l_total_exposure := l_total_exposure - nvl(l_total_on_hold,0);

       oe_debug_pub.ADD('Total exposure after taking care of Hold ='||
                            to_char(l_total_exposure));
    END IF;  -- l_orders_on_hold_flag

    -- Check Commitment Total if Commitment Sequencing "On"
    IF OE_Commitment_PVT.Do_Commitment_Sequencing THEN

      OPEN commitment_total;
      FETCH commitment_total INTO l_total_commitment;
      IF commitment_total%notfound THEN
        l_total_commitment := 0;
      END IF;
      CLOSE commitment_total;

      oe_debug_pub.ADD('Commitment Amount: ' || l_total_commitment);

      -- If orders on hold are to be excluded then find out
      -- the commitment amount associated to orders on hold
      IF l_orders_on_hold_flag = 'N' THEN
        OPEN on_hold_commitment_total;
        FETCH on_hold_commitment_total INTO l_on_hold_commitment;
        IF on_hold_commitment_total%notfound THEN
          l_on_hold_commitment := 0;
        END IF;

        CLOSE on_hold_commitment_total;

        oe_debug_pub.ADD('On Hold Commitment Amount: ' || l_on_hold_commitment);
      END IF;

      OPEN current_commitment_total;
      FETCH current_commitment_total INTO l_current_commitment;
      IF current_commitment_total%notfound THEN
        l_current_commitment := 0;
      END IF;
      CLOSE current_commitment_total;

      oe_debug_pub.ADD('Current Order Commitment Amount: ' || l_current_commitment);

      l_total_commitment := l_total_commitment + l_current_commitment - nvl(l_on_hold_commitment, 0);

      oe_debug_pub.ADD('Total Commitment Amount: ' || l_total_commitment);

      -- Now update the total exposure value to EXCLUDE already applied Commitments.
      l_total_exposure := l_total_exposure - nvl(l_total_commitment,0);

      oe_debug_pub.ADD('Total exposure after taking care of Commitments = '||to_char(l_total_exposure));

    END IF; -- Commitment Sequencing

    --  ADD Current Order value to the calculated exposure  */

    OPEN current_order(l_include_tax_flag);
    FETCH current_order INTO l_current_order;
    IF current_order%notfound THEN
        l_current_order := 0;
    END IF;
    CLOSE current_order;

    l_total_exposure := l_total_exposure + NVL(l_current_order,0);
    oe_debug_pub.ADD('Total exposure after Current Order (CUSTOMER)='
                        ||to_char(l_total_exposure));

  END IF; -- uninvoiced order flag

 ----------------
 -- SITE LEVEL --
 ----------------
 ELSE  -- Retrieving exposure at SITE level

   IF l_open_ar_balance_flag = 'Y' THEN

     -- Find Accounts Receivable Exposure
     IF l_open_ar_days IS NULL THEN
       OPEN site_ar_balance;
       FETCH site_ar_balance INTO l_total_from_ar;
       IF site_ar_balance%notfound THEN
          l_total_from_ar := 0;
       END IF;
       CLOSE site_ar_balance;
     ELSE
       OPEN site_ar_balance_in_ar_days;
       FETCH site_ar_balance_in_ar_days INTO l_total_from_ar;
       IF site_ar_balance_in_ar_days%notfound THEN
          l_total_from_ar := 0;
       END IF;
       CLOSE site_ar_balance_in_ar_days;
     END IF; -- If open_ar_days is null

   oe_debug_pub.ADD('Open Receivables Balance: '||l_total_from_ar);

     -- If the include payments at risk flag is set to yes
     -- Update the exposure by payments that are not thought to be collectable
     -- These payments are in the cash receipts history

     IF l_include_risk_flag = 'Y' THEN

       IF l_open_ar_days IS NULL THEN
	    OPEN site_pay_risk;
	    FETCH site_pay_risk INTO l_payments_at_risk;
         IF site_pay_risk%notfound THEN
	       l_payments_at_risk := 0;
	    END IF;
	    CLOSE site_pay_risk;
       ELSE
         OPEN site_pay_risk_in_ar_days;
         FETCH site_pay_risk_in_ar_days INTO l_payments_at_risk;
         IF site_pay_risk_in_ar_days%notfound THEN
	        l_payments_at_risk := 0;
	    END IF;
	    CLOSE site_pay_risk_in_ar_days;
       END IF;  -- If open_ar_days is null

      oe_debug_pub.ADD('Payments At Risk: '||l_payments_at_risk);

     END IF;  -- l_include_risk_flag (Include Payments at Risk)

	-- Now update the total exposure value.
    	l_total_exposure := nvl(l_total_from_ar,0) + nvl(l_payments_at_risk,0);
	oe_debug_pub.ADD('Exposure from a/c receivables ='||
                  to_char(l_total_exposure));

   END IF; -- l_open_ar_balance_flag(checking accounts receivables exposure)


   -- If the include_uninvoiced_orders is set to yes,depending on the
   -- value of include_tax_flag, tax valuw will be included in the
   -- calculation of total_exposure.

   IF l_uninvoiced_orders_flag  = 'Y' THEN

      OPEN site_uninvoiced_orders(l_include_tax_flag);
      FETCH site_uninvoiced_orders INTO l_total_on_order;
      IF site_uninvoiced_orders%notfound THEN
             l_total_on_order := 0;
      END IF;
      CLOSE site_uninvoiced_orders;

      -- Update the total exposure value to include the Order Backlog Value

      oe_debug_pub.ADD('Total amt. of uninvoiced orders: '|| l_total_on_order);
      l_total_exposure := l_total_exposure + nvl(l_total_on_order,0);

      oe_debug_pub.ADD('Exposure after uninvoiced orders ='||
                             to_char(l_total_exposure));

      -- Next check if we should be excluding orders that are already on hold
      -- from the calculation of Total exposure

      IF l_orders_on_hold_flag = 'N' THEN
        -- Find the value of all orders that are the subject of an order hold
        -- at either the header or line level.

        OPEN site_orders_on_hold(l_include_tax_flag);
        FETCH site_orders_on_hold INTO l_total_on_hold;
        IF site_orders_on_hold%notfound THEN
            l_total_on_hold := 0;
        END IF;
        CLOSE site_orders_on_hold;

        -- Update the total exposure value to EXCLUDE the value of
        -- orders on hold
        oe_debug_pub.ADD('Total amount on hold:' || l_total_on_hold);
        l_total_exposure := l_total_exposure - nvl(l_total_on_hold,0);

        oe_debug_pub.ADD('Total Exposure after taking care of Hold ='||
                      to_char(l_total_exposure));

      END IF; -- check orders on hold

    -- Check Commitment Total if Commitment Sequencing "On"
    IF OE_Commitment_PVT.do_Commitment_Sequencing THEN

      OPEN site_commitment_total;
      FETCH site_commitment_total INTO l_total_commitment;
      IF site_commitment_total%notfound THEN
        l_total_commitment := 0;
      END IF;
      CLOSE site_commitment_total;

      oe_debug_pub.ADD('Commitment Amount: ' || l_total_commitment);

      -- If orders on hold are to be excluded then find out
      -- the commitment amount associated to orders on hold
      IF l_orders_on_hold_flag = 'N' THEN
        OPEN site_on_hold_commitment_total;
        FETCH site_on_hold_commitment_total INTO l_on_hold_commitment;
        IF site_on_hold_commitment_total%notfound THEN
          l_on_hold_commitment := 0;
        END IF;

        CLOSE site_on_hold_commitment_total;

        oe_debug_pub.ADD('On Hold Commitment Amount: ' || l_on_hold_commitment);
      END IF;

      l_total_commitment := l_total_commitment - nvl(l_on_hold_commitment, 0);

      -- Now update the total exposure value to EXCLUDE already applied Commitments.
      oe_debug_pub.ADD('Total Commitment Amount: ' || l_total_commitment);

      l_total_exposure := l_total_exposure - nvl(l_total_commitment,0);

      oe_debug_pub.ADD('Total exposure after taking care of Commitments = '||to_char(l_total_exposure));

    END IF; -- Commitment Sequencing

      OPEN site_current_order(l_include_tax_flag);
      FETCH site_current_order INTO l_current_order;
      IF site_current_order%notfound THEN
            l_current_order := 0;
      END IF;
      CLOSE site_current_order;

	l_total_exposure := l_total_exposure + NVL(l_current_order,0);
	oe_debug_pub.ADD('Total exposure after including Current Order(SITE)='
                      ||to_char(l_total_exposure));

  END IF;  -- l_uninvoiced_orders_flag

 END IF; -- credit exposure at SITE level or CUSTOMER level

 oe_debug_pub.ADD('Line Level: OUTPUT total exposure:  '|| l_total_exposure);
 p_total_exposure := l_total_exposure;


EXCEPTION
    WHEN others THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Exposure'
            );
     END IF;
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  RAISE ;

END Check_Exposure_Line;

END OE_Credit_PUB;

/
