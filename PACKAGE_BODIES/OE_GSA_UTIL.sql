--------------------------------------------------------
--  DDL for Package Body OE_GSA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_GSA_UTIL" AS
/* $Header: OEXUGSAB.pls 120.1 2005/06/13 18:31:52 appldev  $ */

--  Global constants holding the package name.

G_PKG_NAME      	CONSTANT    VARCHAR2(30):='OE_GSA_UTIL';

g_header_rec            OE_Order_PUB.Header_Rec_Type;


FUNCTION Check_GSA_Main
(p_line_rec	 IN  OE_Order_Pub.Line_Rec_Type,
 x_resultout IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2) RETURN VARCHAR2
IS
	l_gsa_enabled_flag         VARCHAR2(1):= 'N';
	l_gsa_indicator_flag       VARCHAR2(1):= 'N';
	l_gsa_passed_flag          VARCHAR2(1):= 'Y';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INSIDE CHECK_GSA_MAIN' ) ;
	END IF;

/* -----------------------------------------------------------------------
   Function Check_GSA_Enabled checks if GSA verification is enabled or
   not by checking the profile options
   ------------------------------------------------------------------------*/
	l_gsa_enabled_flag := Check_GSA_Enabled (p_line_rec);

	IF l_gsa_enabled_flag = 'Y' THEN
	BEGIN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'GSA_ENABLED = Y' ) ;
	   END IF;
	   l_gsa_indicator_flag := 'N';

/* -----------------------------------------------------------------------
   Function Check_GSA_Indicator checks if the customer or its bill-to-site
   is GSA to accordingly check further.
   ------------------------------------------------------------------------*/
	   l_gsa_indicator_flag := Check_GSA_Indicator (p_line_rec);
	   IF l_gsa_indicator_flag = 'Y' THEN
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  'GSA_INDICATOR = Y' ) ;
	      END IF;

/* -----------------------------------------------------------------------
For now, we have commented out nocopy the part in the following line where

   we check for the price offered to a Non-GSA customer against the price
   entered in the order for a GSA customer.
   This is due to the performance issues. We may enable it in the future
   releases.
   ------------------------------------------------------------------------*/
/* 	      l_gsa_passed_flag := Check_GSA_Customer (p_line_rec); */
	      null;
	   ELSE
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  'GSA_INDICATOR = N' ) ;
	      END IF;
/* -----------------------------------------------------------------------
   Function Check_NonGSA_Customer checks for the price offered to a
   GSA customer against the price entered in the order for a NonGSA customer
   and returns whether the check passed or no.
   ------------------------------------------------------------------------*/
 	      l_gsa_passed_flag := Check_NonGSA_Customer (p_line_rec);
	   END IF;
	END;
	END IF;

	IF l_gsa_passed_flag = 'Y' THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'GSA_PASSED = Y' ) ;
	   END IF;
 	   x_resultout := 'COMPLETE:AP_PASS';
	ELSE
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'GSA_PASSED = N' ) ;
	   END IF;
 	   x_resultout := 'COMPLETE:AP_FAIL';
	END IF;

	RETURN x_resultout;

end Check_GSA_Main;


FUNCTION Check_GSA_Enabled
(p_line_rec	 IN  OE_Order_Pub.Line_Rec_Type) RETURN VARCHAR2
IS
	l_profile_option_value   VARCHAR2(1):= 'N';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INSIDE GSA_ENABLED' ) ;
	END IF;

	l_profile_option_value := 'N';
	l_profile_option_value := FND_PROFILE.value ('QP_VERIFY_GSA');

	RETURN l_profile_option_value;


	EXCEPTION

	WHEN NO_DATA_FOUND THEN
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'INSIDE NO-DATA-FOUND EXCEPTION' ) ;
	     END IF;
	     l_profile_option_value := 'N';

	WHEN OTHERS THEN
             -- Unexpected error
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'INSIDE OTHERS EXCEPTION' ) ;
	     END IF;
	     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	     THEN
	        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME  	    ,
    	                    'Check_GSA_Violation. GSA Violation Price ');
	     END IF;
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Check_GSA_Enabled;

FUNCTION Check_GSA_Indicator
(p_line_rec	 IN  OE_Order_Pub.Line_Rec_Type) RETURN VARCHAR2
IS
	l_invoice_to_org_id NUMBER;
        l_site_use_id       NUMBER;
        l_customer_id       NUMBER;
	l_gsa_flag          VARCHAR2(1):= 'N';
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN


	BEGIN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INSIDE GSA_INDICATOR_CUSTOMER' , 5 ) ;
	END IF;

 /*	SELECT NVL(GSA_INDICATOR,'N')
 	  INTO l_gsa_flag
 	  FROM OE_SOLD_TO_ORGS_V STO, RA_CUSTOMERS C
 	 WHERE STO.ORGANIZATION_ID = l_invoice_to_org_id
	   AND STO.CUSTOMER_ID (+)= C.CUSTOMER_ID;  */
 --added the following select and assignment statement to fix bug 1738379 Begin
	l_invoice_to_org_id := p_line_rec.invoice_to_org_id;
        select /* MOAC_SQL_CHANGE */ nvl(gsa_indicator,'N')
        into l_gsa_flag
        from hz_cust_site_uses_all hsu
        where site_use_id = l_invoice_to_org_id  ;
 /*        AND  NVL(hsu.org_id,
         NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1 ,1), ' ',NULL,
              SUBSTRB(USERENV('CLIENT_INFO'), 1,10))),-99)) =
         NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',NULL,
         SUBSTRB(USERENV('CLIENT_INFO'),1,10))), -99); */
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'GSA_FLAG VALUE1:'||L_GSA_FLAG , 5 ) ;
	END IF;
    --added the above select and  assignment  statement to fix bug 1738379  End

	EXCEPTION

	WHEN NO_DATA_FOUND THEN
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'INSIDE NO-DATA-FOUND EXCEPTION 1' , 5 ) ;
	     END IF;
	     l_gsa_flag := 'N';

	WHEN OTHERS THEN
             -- Unexpected error
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'INSIDE OTHERS EXCEPTION' ) ;
	     END IF;
	     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	     THEN
	        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME  	    ,
    	                    'Check_GSA_Violation. GSA Violation Price ');
	     END IF;
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;

	IF l_gsa_flag = 'N' THEN
	BEGIN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'INSIDE GSA_INDICATOR_SITE' , 5 ) ;
	   END IF;
--commented to fix bug 1738379
 /*	   SELECT NVL(GSA_INDICATOR,'N')
 	   INTO l_gsa_flag
 	   FROM OE_INVOICE_TO_ORGS_V ITO, RA_SITE_USES SU
 	   WHERE ITO.ORGANIZATION_ID = l_invoice_to_org_id
 	     AND ITO.SITE_USE_ID = SU.SITE_USE_ID;  */
--added the following select and assignment statement to fix bug 1738379  Begin
        l_customer_id := p_line_rec.sold_to_org_id;
        select nvl(gsa_indicator_flag,'N')
        into l_gsa_flag
        from hz_parties hp,hz_cust_accounts hca
        where hp.party_id = hca.party_id
          and hca.cust_account_id = l_customer_id ;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'GSA_FLAG VALUE2:'||L_GSA_FLAG , 5 ) ;
	END IF;
--added the above select and assignment statement to fix bug 1738379  End

	   EXCEPTION

	   WHEN NO_DATA_FOUND THEN
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'INSIDE NO-DATA-FOUND EXCEPTION 2' , 5 ) ;
	     END IF;
	     l_gsa_flag := 'N';

      	   WHEN OTHERS THEN
	     l_gsa_flag := 'N';
             -- Unexpected error
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'INSIDE OTHERS EXCEPTION' ) ;
	     END IF;
	     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	     THEN
	        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME  	    ,
    	                    'Check_GSA_Violation. GSA Violation Price ');
	     END IF;
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'GSA_FLAG VALUE 3:'||L_GSA_FLAG , 5 ) ;
	END IF;

	RETURN l_gsa_flag;

END Check_GSA_Indicator;


-- Function which checks if any GSA customer has got more price for
-- the item as compared to the NonGSA customer's price .

FUNCTION Check_NonGSA_Customer
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type) RETURN VARCHAR2
IS
	l_gsa_count       NUMBER      := 0;
	l_gsa_passed_flag VARCHAR2(1) := 'Y';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
--      l_gsa_count stores the number of GSA prices less than the
--      unit selling price of the NonGSA customer.

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INSIDE CHECK_NONGSA_CUSTOMER' ) ;
	END IF;
	l_gsa_count := 0;
	l_gsa_count := Get_GSA_Count (p_line_rec);
   	IF l_gsa_count > 0 THEN
	   l_gsa_passed_flag := 'N';
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'GSA_COUNT >0' ) ;
	   END IF;
   	ELSE
	   l_gsa_passed_flag := 'Y';
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'GSA_COUNT = 0' ) ;
	   END IF;
   	END IF;

        RETURN l_gsa_passed_flag;

END Check_NONGSA_CUSTOMER;


FUNCTION Get_GSA_Count
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type) RETURN NUMBER
IS

--PERFORMANCE no use

	l_gsa_count 		NUMBER := 0;
	l_unit_selling_price 	NUMBER := 0;
	l_price_list_id 	NUMBER;
	l_pricing_quantity 	NUMBER;
	l_customer_item_id 	NUMBER;
	l_inventory_item_id 	NUMBER;
	l_pricing_date 		DATE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
	l_unit_selling_price := p_line_rec.unit_selling_price;
	l_pricing_quantity   := p_line_rec.pricing_quantity;
	l_inventory_item_id  := p_line_rec.inventory_item_id;
	l_price_list_id      := p_line_rec.price_list_id;
	l_pricing_date       := p_line_rec.pricing_date;


--  The select statement checks to see the maximum GSA discount price for the
--  inventory item that is being priced from the Sales Order line.
--
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INSIDE GSA_COUNT' ) ;
	END IF;

	SELECT count(*)
          INTO l_gsa_count
          FROM OE_DISCOUNTS          OEDIS,
               OE_DISCOUNT_CUSTOMERS OEDCU,
               OE_DISCOUNT_LINES     OEDLN,
               OE_PRICE_BREAK_LINES  OEPBL
         WHERE OEDIS.GSA_INDICATOR = 'Y'
           AND OEDIS.PRICE_LIST_ID = l_price_list_id
           AND l_pricing_date
	       BETWEEN NVL(OEDIS.START_DATE_ACTIVE,l_pricing_date)
                   AND NVL(OEDIS.END_DATE_ACTIVE,l_pricing_date)
           AND OEDIS.DISCOUNT_ID = OEDLN.DISCOUNT_ID
           AND OEDLN.ENTITY_VALUE = l_inventory_item_id
           AND l_pricing_date
	       BETWEEN NVL(OEDLN.START_DATE_ACTIVE,l_pricing_date)
                   AND NVL(OEDLN.END_DATE_ACTIVE,l_pricing_date)
           AND OEDLN.DISCOUNT_LINE_ID = OEPBL.DISCOUNT_LINE_ID (+)
           AND l_pricing_quantity
	       BETWEEN NVL(OEPBL.PRICE_BREAK_LINES_LOW_RANGE,1)
               AND NVL(OEPBL.PRICE_BREAK_LINES_HIGH_RANGE,l_pricing_quantity)
           AND l_pricing_date
	       BETWEEN NVL(OEPBL.START_DATE_ACTIVE,l_pricing_date)
                   AND NVL(OEPBL.END_DATE_ACTIVE,l_pricing_date)
           AND NVL(OEPBL.PRICE, OEDLN.PRICE) >= l_unit_selling_price
           AND OEDCU.DISCOUNT_ID (+) = OEDIS.DISCOUNT_ID
           AND l_pricing_date
	       BETWEEN NVL(OEDCU.START_DATE_ACTIVE,l_pricing_date)
                   AND NVL(OEDCU.END_DATE_ACTIVE,l_pricing_date);

	RETURN l_gsa_count;

	EXCEPTION

    	WHEN NO_DATA_FOUND THEN
	     l_gsa_count := 0;
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'INSIDE NO-DATA-FOUND EXCEPTION' ) ;
	     END IF;

    	WHEN OTHERS THEN
             -- Unexpected error
	     IF l_debug_level  > 0 THEN
	         oe_debug_pub.add(  'INSIDE OTHERS EXCEPTION' ) ;
	     END IF;
	     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	          THEN
	         OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME  	    ,
    	                 'Check_GSA_Violation. GSA Violation Price ');
	     END IF;
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_GSA_Count;


--Function which checks if any NonGSA customer has got less price for
-- the item as compared to the GSA customer's price .

FUNCTION Check_GSA_CUSTOMER
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type) RETURN VARCHAR2
IS
	l_nongsa_count    NUMBER      := 0;
	l_gsa_passed_flag VARCHAR2(1) := 'Y';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
--      l_gsa_count stores the number of NonGSA prices less than the
--      unit selling price of the GSA customer.

	l_nongsa_count := 0;
	l_nongsa_count := Get_NonGSA_Count (p_line_rec);
   	IF l_nongsa_count > 0 THEN
	   l_gsa_passed_flag := 'N';
   	ELSE
	   l_gsa_passed_flag := 'Y';
   	END IF;

END Check_GSA_Customer;


FUNCTION Get_NonGSA_Count
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type) RETURN NUMBER
IS
	l_nongsa_count     	NUMBER := 0;
	l_header_id 		NUMBER := 0;
	l_inventory_item_id 	NUMBER;
	l_unit_selling_price 	NUMBER := 0;
	l_pricing_quantity 	NUMBER;
	l_price_list_id 	NUMBER;
	l_pricing_date 		DATE;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

	l_unit_selling_price := p_line_rec.unit_selling_price;
	l_inventory_item_id  := p_line_rec.inventory_item_id;
	l_pricing_quantity   := p_line_rec.pricing_quantity;
	l_price_list_id      := p_line_rec.price_list_id;
	l_pricing_date       := p_line_rec.pricing_date;

	SELECT count(*)
 	  INTO l_nongsa_count
 	  FROM OE_DISCOUNTS          OEDIS,
               OE_DISCOUNT_CUSTOMERS OEDCU,
               OE_DISCOUNT_LINES     OEDLN,
               OE_PRICE_BREAK_LINES  OEPBL
 	 WHERE OEDIS.GSA_INDICATOR = 'N'
 	   AND OEDIS.PRICE_LIST_ID = l_price_list_id
 	   AND l_pricing_date
	       BETWEEN NVL(OEDIS.START_DATE_ACTIVE,l_pricing_date)
 		   AND NVL(OEDIS.END_DATE_ACTIVE,l_pricing_date)
 	   AND OEDIS.DISCOUNT_ID = OEDLN.DISCOUNT_ID
 	   AND OEDLN.ENTITY_VALUE = l_inventory_item_id
 	   AND l_pricing_date
	       BETWEEN NVL(OEDLN.START_DATE_ACTIVE,l_pricing_date)
 	  	   AND NVL(OEDLN.END_DATE_ACTIVE,l_pricing_date)
 	   AND OEDLN.DISCOUNT_LINE_ID = OEPBL.DISCOUNT_LINE_ID (+)
 	   AND l_pricing_quantity
	       BETWEEN NVL(OEPBL.PRICE_BREAK_LINES_LOW_RANGE,1)
 	         AND NVL(OEPBL.PRICE_BREAK_LINES_HIGH_RANGE,l_pricing_quantity)
 	   AND l_pricing_date
	       BETWEEN NVL(OEPBL.START_DATE_ACTIVE,l_pricing_date)
 		   AND NVL(OEPBL.END_DATE_ACTIVE,l_pricing_date)
 	   AND NVL(OEPBL.PRICE, OEDLN.PRICE) <= l_unit_selling_price
 	   AND OEDIS.DISCOUNT_ID = OEDCU.DISCOUNT_ID (+)
 	   AND l_pricing_date
               BETWEEN NVL(OEDCU.START_DATE_ACTIVE,l_pricing_date)
 		   AND NVL(OEDCU.END_DATE_ACTIVE,l_pricing_date);

	RETURN l_nongsa_count;

	EXCEPTION

	WHEN NO_DATA_FOUND THEN
             l_nongsa_count := 0;

	WHEN OTHERS THEN
             -- Unexpected error
	     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	     THEN
	         OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME  	    ,
  	      'Check_GSA_Violation. GSA Violation Price ');
	     END IF;
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_NonGSA_Count;


FUNCTION Get_Hold_id(hold NUMBER) RETURN NUMBER
IS
	 x_hold_id NUMBER :=0;
	 --
	 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	 --
BEGIN

	 SELECT OE_HOLD_definitions.HOLD_ID
	 INTO x_hold_id
	 FROM OE_HOLD_definitions WHERE TYPE_CODE = 'GSA';

	RETURN x_hold_id;

	EXCEPTION
           WHEN NO_DATA_FOUND THEN RETURN 0;
           WHEN OTHERS THEN RETURN 0;

END Get_Hold_id;


FUNCTION Get_Source_id(header_id  NUMBER) RETURN NUMBER
IS
	 x_source_id NUMBER :=0;
	 l_header_id   NUMBER;
	 --
	 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	 --
BEGIN
	l_header_id := header_id;

	 SELECT MAX(S.HOLD_SOURCE_ID)
	   INTO x_source_id
	   FROM OE_HOLD_SOURCES S
          WHERE S.HOLD_ENTITY_ID = l_header_id
	    AND S.HOLD_ENTITY_CODE = 'O'
	    AND NVL(RELEASED_FLAG,'N') ='N';

	RETURN x_source_id;

	EXCEPTION
           WHEN OTHERS THEN
	      IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  'FAILED IN GET_SOURCE_ID' ) ;
	      END IF;
              RETURN 0;
END Get_Source_id;


FUNCTION Release_Hold
(p_line_rec	 IN	 OE_Order_Pub.Line_Rec_Type,
 x_resultout     IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2) RETURN VARCHAR2
IS
	l_header_id NUMBER := 0;
	l_hold_release_id NUMBER := 0;
	l_hold_source_id NUMBER := 0;
        l_request_id NUMBER :=0;
	l_line_id NUMBER:=0;
        l_program_application_id NUMBER :=0;
        l_program_id NUMBER :=0;
        --
        l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
        --
BEGIN
	l_header_id := p_line_rec.header_id;
	l_line_id := p_line_rec.line_id;
	l_request_id := p_line_rec.request_id;
	l_hold_source_id := Get_Source_id(l_line_id);
	l_program_application_id := p_line_rec.program_application_id;
	l_program_id := p_line_rec.program_id;


        SELECT OE_HOLD_RELEASES_S.NEXTVAL
          INTO l_hold_release_id
          FROM  DUAL;

        BEGIN
          INSERT INTO OE_HOLD_RELEASES
                     (HOLD_RELEASE_ID,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_DATE,
          	      LAST_UPDATED_BY,
          	      LAST_UPDATE_LOGIN,
          	      REQUEST_ID,
          	      PROGRAM_APPLICATION_ID,
          	      PROGRAM_ID,
          	      PROGRAM_UPDATE_DATE,
          	      HOLD_SOURCE_ID,
          	     -- HOLD_ENTITY_CODE,
          	     -- HOLD_ENTITY_ID,
          	      RELEASE_REASON_CODE )
    	       SELECT l_hold_release_id,
          	      SYSDATE,
          	      FND_GLOBAL.user_id,
          	      SYSDATE,
          	      FND_GLOBAL.user_id,
          	      FND_GLOBAL.login_id,
          	      l_request_id,
          	      l_program_application_id,
          	      l_program_id,
          	      DECODE(l_request_id, NULL, NULL, SYSDATE ),
          	      l_hold_source_id,
          	     --'O',
          	     --l_header_id,
          	      'PASS_GSA'
	         FROM DUAL
	        WHERE l_hold_source_id <> 0;

	  If l_hold_source_id <> 0 then
	     FND_MESSAGE.SET_NAME('OE', 'GSA Hold Removed');
	     OE_MSG_PUB.Add;
	  End If;

	  EXCEPTION
	     WHEN OTHERS THEN null;
	     -- put real handling here
	END;

	BEGIN
	   UPDATE OE_ORDER_HOLDS OEHLD
    	      SET HOLD_RELEASE_ID = l_hold_release_id,
			RELEASED_FLAG='Y',
          	  LAST_UPDATE_DATE = SYSDATE,
          	  LAST_UPDATED_BY =  FND_GLOBAL.user_id,
          	  LAST_UPDATE_LOGIN = FND_GLOBAL.login_id,
          	  REQUEST_ID = l_request_id,
          	  PROGRAM_APPLICATION_ID = l_program_application_id,
          	  PROGRAM_ID = l_program_id,
          	  PROGRAM_UPDATE_DATE = DECODE( l_request_id, NULL, NULL, SYSDATE )
            WHERE HOLD_SOURCE_ID = l_hold_source_id
              AND HEADER_ID = l_header_id
    	      AND LINE_ID = l_line_id;

	   RETURN  'COMPLETE:AP_PASS';

	   EXCEPTION
	      WHEN OTHERS THEN null;
		--need more thinking here
	END;

        EXCEPTION
	   WHEN OTHERS THEN RETURN 'COMPLETE:AP_FAIL';

END Release_Hold;

END OE_GSA_UTIL;

/
