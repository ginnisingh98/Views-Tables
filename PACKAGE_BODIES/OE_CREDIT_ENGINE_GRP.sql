--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_ENGINE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_ENGINE_GRP" AS
-- $Header: OEXPCRGB.pls 120.6.12010000.10 2012/01/04 06:48:03 slagiset ship $
--+=======================================================================+
--|               Copyright (c) 2001 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--|                                                                       |
--|  FILENAME                                                             |
--|    OEXPCRGB.pls                                                       |
--|                                                                       |
--|  DESCRIPTION                                                          |
--|    Body of package OE_Credit_Engine_GRP                               |
--|                                                                       |
--|  NOTES                                                                |
--|    This package body contains the procedures that will be             |
--|    used to call Order Specific Payment Verification process           |
--|                                                                       |
--|  HISTORY                                                              |
--|    26-SEP-2001 INGERSOL BUG                                           |
--|    05-FEB-2002 multi org                                              |
--|                ontdev=>  OEXPCRGB.pls 115.17 2001/09/27 22:58:05      |
--|    05-FEB-2002 rajkrish 1PM                                           |
--|    18-FEB-2002 External Credit Checking change                        |
--|    19-MAR-2002 Modified Check_Credit for external credit checking     |
--|    12-JUN-2002 rajkrish 2412678                                       |
--|    12-NOV-2002                                                        |
--|    31-MAR-2003 vto      2846473,2878410. Changed call to              |
--|                         Send_Credit_Hold_NTF                          |
--|    01-APR-2003 vto      2853800. Use globals for activity cc holds    |
--|                         G_cc_hold_activity_name                       |
--|                         G_cc_hold_item_type                           |
--|                         Added Set_G_CC_Hold_info procedure.           |
--|    15-MAY-2003  vto     2894424, 2971689. New cc calling action:      |
--|                         AUTO HOLD, AUTO RELEASE.                      |
--|                         Obsolete calling action: AUTO                 |
--+=======================================================================+

--=========================================================================
-- CONSTANTS
--=========================================================================
G_PKG_NAME    CONSTANT VARCHAR2(30) := 'OE_Credit_Engine_GRP';

--=========================================================================
-- PRIVATE GLOBAL VARIABLES
--=========================================================================
G_debug_flag  VARCHAR2(1) := NVL(OE_CREDIT_CHECK_UTIL.check_debug_flag ,'N');

--=========================================================================
-- PROCEDURES AND FUNCTIONS
--=========================================================================

---------------------------------------------------------------------------
-- PROCEDURE: Set_G_CC_Hold_Info
-- COMMENT:   Set the values for the G_cc_hold_item_type and
--            G_cc_hold_activity_name global variables.
---------------------------------------------------------------------------
PROCEDURE Set_G_CC_Hold_Info
IS
BEGIN
  IF G_debug_flag = 'Y' THEN
    OE_DEBUG_PUB.ADD('OEXPCRGB: In Set_G_CC_Hold_Info', 1);
  END IF;

  SELECT item_type,
         activity_name
  INTO   G_cc_hold_item_type,
         G_cc_hold_activity_name
  FROM   oe_hold_definitions
  WHERE  hold_id = 1;

  IF G_debug_flag = 'Y' THEN
    OE_DEBUG_PUB.ADD('G_cc_hold_item_type     = '||G_cc_hold_item_type, 2);
    OE_DEBUG_PUB.ADD('G_cc_hold_activity_name = '||G_cc_hold_activity_name, 2);
    OE_DEBUG_PUB.ADD('OEXPCRGB: Out Set_G_CC_Hold_Info', 1);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- Hold definition should exist. This exception should not occur if setup is correct.
    -- Ideally, an error should be raised indicating no cc hold definition found instead
    -- of unexpected error.
    IF G_debug_flag = 'Y' THEN
      OE_DEBUG_PUB.ADD('EXCEPTION: No credit check hold definition found.', 1);
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Set_G_CC_Hold_Info'
      );
    END IF;
    RAISE;
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Set_G_CC_Hold_Info'
      );
    END IF;
    RAISE;
END Set_G_CC_Hold_Info;

---------------------------------------------------------------------------
--PROCEDURE: Get_Credit_Check_Rule_ID
--COMMENT:   Returns the credit check rule id attached with
--          the order trn type
---------------------------------------------------------------------------
PROCEDURE Get_Credit_Check_Rule_ID
( p_calling_action      IN VARCHAR2
, p_order_type_id       IN OE_ORDER_HEADERS.order_type_id%TYPE
, x_credit_rule_id      OUT NOCOPY /* file.sql.39 change */ OE_Credit_check_rules.credit_check_rule_id%TYPE
)
IS
BEGIN
IF G_debug_flag = 'Y'
THEN
  OE_DEBUG_PUB.ADD('OEXPCRGB: In Get_Credit_Check_Rule_ID ');
  OE_DEBUG_PUB.ADD('p_order_type_id = '|| p_order_type_id );
  OE_DEBUG_PUB.ADD('p_calling_action = '|| p_calling_action );
END IF;
  x_credit_rule_id := NULL ;

  IF p_calling_action in ('BOOKING','BOOKING_INLINE','UPDATE',
                          'AUTO HOLD', 'AUTO RELEASE')
  THEN

/*7194250
    SELECT ENTRY_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V
    WHERE  ORDER_TYPE_ID = p_order_type_id;
7194250*/
--7194250
    SELECT ENTRY_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE  ORDER_TYPE_ID = p_order_type_id
    AND   ENTRY_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250

    OE_Verify_Payment_PUB.G_credit_check_rule := 'Ordering';   --ER#7479609

  ELSIF p_calling_action = 'SHIPPING'
  THEN
/*7194250
    SELECT SHIPPING_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V
    WHERE  ORDER_TYPE_ID = p_order_type_id;
7194250*/
--7194250
    SELECT SHIPPING_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE  ORDER_TYPE_ID = p_order_type_id
    AND   SHIPPING_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250

    OE_Verify_Payment_PUB.G_credit_check_rule := 'Shipping';   --ER#7479609

  ELSIF p_calling_action = 'PACKING'
  THEN
/*7194250
    SELECT PACKING_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V
    WHERE  ORDER_TYPE_ID = p_order_type_id;
7194250*/
--7194250
    SELECT PACKING_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE  ORDER_TYPE_ID = p_order_type_id
    AND   PACKING_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250

    OE_Verify_Payment_PUB.G_credit_check_rule := 'Packing';   --ER#7479609

  ELSIF p_calling_action = 'PICKING'
  THEN
/*7194250
    SELECT PICKING_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V
    WHERE  ORDER_TYPE_ID = p_order_type_id;
7194250*/
--7194250
    SELECT PICKING_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE  ORDER_TYPE_ID = p_order_type_id
    AND   PICKING_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250

    OE_Verify_Payment_PUB.G_credit_check_rule := 'Picking/Purchase Release';   --ER#7479609

  END IF;

IF G_debug_flag = 'Y'
THEN
  OE_DEBUG_PUB.ADD('OEXPCRGB: Credit Check Rule ID: '
       ||TO_CHAR(x_credit_rule_id) );

  OE_DEBUG_PUB.ADD('OEXPCRGB: Out Get_Credit_Check_Rule_ID');
END IF;

EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
   x_credit_rule_id := NULL ;
   OE_DEBUG_PUB.ADD('EXCEPTION:No credit check rule found');
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Get_Credit_Check_Rule_ID'
      );
    END IF;
    RAISE ;
END Get_Credit_Check_Rule_ID ;

--ER 12363706 start
FUNCTION Is_Tolerance_Enabled
 ( p_header_id             IN  NUMBER,
   p_credit_check_rule_rec  OUT NOCOPY OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
 )
RETURN BOOLEAN
IS
l_credit_check_rule_id   NUMBER;
l_credit_check_rule_rec  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type ;
l_header_rec             OE_Order_PUB.Header_Rec_Type;
l_released_order_amount	 NUMBER;
l_curr_order_amount	 NUMBER;
l_tolerance_percentage   NUMBER;
l_tolerance_curr_code    VARCHAR2(30);
l_tolerance_amount	 NUMBER;
l_tolerance_amount_conv	 NUMBER;
l_tolerance_amount_per	 NUMBER;
l_tolerance_amount_fin	 NUMBER;
l_calling_action         VARCHAR2(30);
BEGIN
  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.Add('OEXPCRGB: In Is_Tolerance_Enabled ');
  END IF;

         l_calling_action := OE_Verify_Payment_PUB.Which_Rule(p_header_id => p_header_id);

        OE_HEADER_UTIL.QUERY_ROW ( p_header_id  => p_header_id,
	                           x_header_rec => l_header_rec);

         Get_Credit_Check_Rule_ID
         ( p_calling_action        => l_calling_action
         , p_order_type_id         => l_header_rec.order_type_id
         , x_credit_rule_id        => l_credit_check_rule_id
         );


   	 OE_CREDIT_CHECK_UTIL.GET_credit_check_rule
   	 ( p_header_id              => p_header_id
   	 , p_credit_check_rule_id   => l_credit_check_rule_id
   	 , x_credit_check_rules_rec => l_credit_check_rule_rec
   	  );

         p_credit_check_rule_rec := l_credit_check_rule_rec;


        IF l_credit_check_rule_rec.tolerance_percentage IS NULL and l_credit_check_rule_rec.tolerance_amount IS NULL
        THEN
          RETURN FALSE;
        ELSE
          RETURN TRUE;
        END IF;


   IF G_debug_flag = 'Y'
   THEN
     OE_DEBUG_PUB.Add('OEXPCRGB: Out Is_Tolerance_Enabled ');
   END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Credit_Tolerance_Check'
      );
    END IF;
    OE_DEBUG_PUB.ADD( SUBSTR( SQLERRM,1,300) ,1 ) ;


END Is_Tolerance_Enabled ;

FUNCTION Credit_Tolerance_Check
 ( p_header_id             IN  NUMBER
 )
RETURN BOOLEAN
IS
l_credit_check_rule_id   NUMBER;
l_credit_check_rule_rec  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type ;
l_header_rec             OE_Order_PUB.Header_Rec_Type;
l_released_order_amount	 NUMBER;
l_released_curr_code	 VARCHAR2(15);
l_released_order_amount_conv	 NUMBER;
l_curr_order_amount	 NUMBER;
l_tolerance_amount_conv	 NUMBER;
l_tolerance_amount_per	 NUMBER;
l_tolerance_amount_fin	 NUMBER;
l_return_status      VARCHAR2(30);
l_conversion_status     OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;

CURSOR res_det IS
SELECT OHR.Released_Order_Amount,OHR.Released_Curr_code
FROM OE_ORDER_HOLDS OOH,
OE_HOLD_SOURCES_ALL OHS,
OE_HOLD_RELEASES OHR
WHERE OOH.HOLD_SOURCE_ID = OHS.HOLD_SOURCE_ID
AND OOH.HEADER_ID = p_header_id
AND OOH.HOLD_RELEASE_ID IS NOT NULL
AND OHS.HOLD_ID = 1
AND OHS.HOLD_ENTITY_CODE = 'O'
AND OHS.HOLD_ENTITY_ID = p_header_id
AND OHS.RELEASED_FLAG ='Y'
AND OHR.HOLD_RELEASE_ID = OOH.HOLD_RELEASE_ID
ORDER BY OHR.creation_date DESC;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.Add('OEXPCRGB: In Credit_Tolerance_Check ');
  END IF;

     IF  Is_Tolerance_Enabled(p_header_id,l_credit_check_rule_rec) THEN

        OE_HEADER_UTIL.QUERY_ROW ( p_header_id  => p_header_id,
	                           x_header_rec => l_header_rec);

         l_credit_check_rule_rec.credit_check_level_code := 'ORDER';

   	 OE_CREDIT_CHECK_UTIL.GET_transaction_amount
      	( p_header_id              => p_header_id
      	, p_transaction_curr_code  => l_header_rec.transactional_curr_code
      	, p_credit_check_rule_rec  => l_credit_check_rule_rec
      	, p_system_parameter_rec   => NULL
      	, p_customer_id            => NULL
      	, p_site_use_id            => NULL
      	, p_limit_curr_code        => l_header_rec.transactional_curr_code
      	, p_all_lines	           => 'Y'
      	, x_amount                 => l_curr_order_amount
      	, x_conversion_status      => l_conversion_status
      	, x_return_status          => l_return_status
      	);

        OPEN res_det;
        FETCH res_det INTO l_released_order_amount,l_released_curr_code;
        CLOSE res_det;

        IF l_released_curr_code <> l_header_rec.transactional_curr_code
        THEN
            l_released_order_amount_conv :=
       	    OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
        	    ( p_amount	           => l_released_order_amount
        	    , p_transactional_currency => l_released_curr_code
        	    , p_limit_currency	   => l_header_rec.transactional_curr_code
        	    , p_functional_currency	   => OE_Credit_Engine_GRP.GL_currency
        	    , p_conversion_date	   => SYSDATE
        	    , p_conversion_type	   => l_credit_check_rule_rec.conversion_type
        	  );
        ELSE
            OE_DEBUG_PUB.Add('OEXPCRGB: Currency conversion not required. Released and Transactional currency is same');
            l_released_order_amount_conv  :=  l_released_order_amount;
        END IF;

        /***If No Tolerance Defined , the Credit Checking will always be triggered**/
        IF l_credit_check_rule_rec.tolerance_percentage IS NULL and l_credit_check_rule_rec.tolerance_amount IS NULL
        THEN
          OE_DEBUG_PUB.Add('OEXPCRGB: Tolerance Check Not Required');
          RETURN FALSE;
        END IF;

        IF l_credit_check_rule_rec.tolerance_amount IS NOT NULL
        THEN

            IF l_credit_check_rule_rec.tolerance_curr_code <> l_header_rec.transactional_curr_code
            THEN
              l_tolerance_amount_conv :=
        	      OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
        	      ( p_amount	           => l_credit_check_rule_rec.tolerance_amount
        	      , p_transactional_currency => l_credit_check_rule_rec.tolerance_curr_code
        	      , p_limit_currency	   => l_header_rec.transactional_curr_code
        	      , p_functional_currency	   => OE_Credit_Engine_GRP.GL_currency
        	      , p_conversion_date	   => SYSDATE
        	      , p_conversion_type	   => l_credit_check_rule_rec.conversion_type
        	    );
            ELSE
              OE_DEBUG_PUB.Add('OEXPCRGB: Currency conversion not required. Tolerance and Transactional currency is same');
              l_tolerance_amount_conv := l_credit_check_rule_rec.tolerance_amount;
            END IF;
        END IF;

        IF l_credit_check_rule_rec.tolerance_percentage IS NOT NULL
        THEN
        	l_tolerance_amount_per := l_released_order_amount_conv * (l_credit_check_rule_rec.tolerance_percentage/100);
        END IF;

        IF l_credit_check_rule_rec.tolerance_amount IS NOT NULL  AND l_credit_check_rule_rec.tolerance_percentage IS NULL
        THEN

          l_tolerance_amount_fin := l_tolerance_amount_conv;

        ELSIF l_credit_check_rule_rec.tolerance_amount IS NULL  AND l_credit_check_rule_rec.tolerance_percentage IS NOT NULL
        THEN

          l_tolerance_amount_fin := l_tolerance_amount_per;

        ELSE
                IF l_tolerance_amount_per < l_tolerance_amount_conv
        	THEN
        	  l_tolerance_amount_fin := l_tolerance_amount_per;
        	ELSE
        	  l_tolerance_amount_fin := l_tolerance_amount_conv;
        	END IF;
        END IF;

   	IF G_debug_flag = 'Y'
   	THEN
   	  OE_DEBUG_PUB.Add('OEXPCRGB: l_released_order_amount_conv: ' ||l_released_order_amount_conv);
   	  OE_DEBUG_PUB.Add('OEXPCRGB: l_tolerance_amount_fin: ' ||l_tolerance_amount_fin);
   	  OE_DEBUG_PUB.Add('OEXPCRGB: l_curr_order_amount: ' ||l_curr_order_amount);
   	END IF;

       IF l_curr_order_amount <= (l_released_order_amount + l_tolerance_amount_fin)
       THEN
        OE_DEBUG_PUB.Add('OEXPCRGB: Tolerance Check Passed');
        RETURN TRUE;
       ELSE
        OE_DEBUG_PUB.Add('OEXPCRGB: Tolerance Check Failed');
        RETURN FALSE;
       END IF;
     END IF;



   RETURN FALSE;
   IF G_debug_flag = 'Y'
   THEN
     OE_DEBUG_PUB.Add('OEXPCRGB: Out Credit_Tolerance_Check ');
   END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Credit_Tolerance_Check'
      );
    END IF;
    OE_DEBUG_PUB.ADD( SUBSTR( SQLERRM,1,300) ,1 ) ;


END Credit_Tolerance_Check ;
--ER 12363706 end


---------------------------------------------------------------------
-- PROCEDURE: Apply_exception_hold
-- COMMENT:   Apply credit check hold on the specified order
--            during process exceptions
--            when the return status is not SUCCESS
--            The return status will be assigned as Error
--            If apply hold returns error , the process will
--            abort and return Unexpected error
----------------------------------------------------------------------
PROCEDURE Apply_exception_hold
 ( p_header_id             IN  NUMBER
 , x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  )
IS

  l_hold_exists        VARCHAR2(1)  := NULL ;
  l_hold_result        VARCHAR2(30);
  l_msg_count          NUMBER := 0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(30);
  l_hold_comment       VARCHAR2(2000);
  l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type :=
          OE_HOLDS_PVT.G_MISS_Hold_Source_REC;
BEGIN
  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.Add('OEXPCRGB: In Apply_exception_hold ');
  END IF;

  l_hold_source_rec.hold_id          := 1;           -- credit hold
  l_hold_source_rec.hold_entity_code := 'O';         -- order hold
  l_hold_source_rec.hold_entity_id   := p_header_id; -- order header

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('Call OE_HOLDS_PUB.Check_Holds');
  END IF;

  OE_HOLDS_PUB.Check_Holds
                      ( p_api_version    => 1.0
                      , p_header_id      => p_header_id
                      , p_hold_id        => 1
                      , p_wf_item        => OE_Credit_Engine_GRP.G_cc_hold_item_type
                      , p_wf_activity    => OE_Credit_Engine_GRP.G_cc_hold_activity_name
                      , p_entity_code    => 'O'
                      , p_entity_id      => p_header_id
                      , x_result_out     => l_hold_result
                      , x_msg_count      => l_msg_count
                      , x_msg_data       => l_msg_data
                      , x_return_status  => x_return_status
                      );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_hold_result = FND_API.G_TRUE
  THEN
      OE_DEBUG_PUB.Add('OEXVCRHB: Hold already applied on Header ID:' ||
      p_header_id );
  ELSE
      l_hold_comment := 'Credit checking package API Error' ;
      l_hold_source_rec.hold_comment :=
            NVL(OE_Credit_Engine_GRP.G_currency_error_msg, l_hold_comment) ;

      OE_DEBUG_PUB.Add('Call OE_Holds_PUB.Apply_Holds' );

      OE_Holds_PUB.Apply_Holds
        (   p_api_version       => 1.0
        ,   p_validation_level  => FND_API.G_VALID_LEVEL_NONE
        ,   p_hold_source_rec   => l_hold_source_rec
        ,   x_msg_count         => l_msg_count
        ,   x_msg_data          => l_msg_data
        ,   x_return_status     => x_return_status
        );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        OE_DEBUG_PUB.ADD('OEXPCRGB: Credit check hold applied on header_ID: '
                       ||p_header_id, 1);
      END IF;
    END IF; -- Check hold exist

   IF G_debug_flag = 'Y'
   THEN
     OE_DEBUG_PUB.Add('OEXPCRGB: Out Apply_exception_hold ');
   END IF;

EXCEPTION

  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Apply_exception_hold'
      );
    END IF;
    OE_DEBUG_PUB.ADD( SUBSTR( SQLERRM,1,300) ,1 ) ;


END Apply_Exception_hold ;


---------------------------------------------------------------------------
--FUNCTION GET_GL_currency
--COMMENT:   Returns the SOB currency

---------------------------------------------------------------------------
FUNCTION GET_GL_currency
RETURN VARCHAR2
IS

l_gl_currency VARCHAR2(10);
l_sob_id      NUMBER;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXPCRGB: In Get_GL_currency ');
  END IF;

  BEGIN
    l_sob_id := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID') ;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('l_sob_id = '|| l_sob_id );
      OE_DEBUG_PUB.ADD('GET SOB currency ');
    END IF;

    SELECT
      currency_code
    INTO
      l_gl_currency
    FROM
      GL_sets_of_books
    WHERE set_of_books_id = l_sob_id ;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('l_gl_currency = '|| l_gl_currency );
    END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
     l_gl_currency := NULL ;
    OE_DEBUG_PUB.ADD('EXCEPTION: NO_DATA_FOUND ');
     l_gl_currency := NULL ;
   WHEN TOO_MANY_ROWS
   THEN
     l_gl_currency := NULL ;
    OE_DEBUG_PUB.ADD('EXCEPTION: TOO_MANY_ROWS');
     l_gl_currency := NULL ;
  END ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXPCRGB: Out Get_GL_currency ');
  END IF;

  RETURN(l_GL_currency);

EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Get_GL_currency'
      );
    END IF;
    OE_DEBUG_PUB.ADD( SUBSTR(SQLERRM,1,300) ) ;
END Get_GL_currency ;

---------------------------------------------------------------------------
--PROCEDURE: Credit_check_with_payment_typ
--COMMENT:   Main API called from verify_payment switch
-- 2412678 add a new input parameter
---------------------------------------------------------------------------
PROCEDURE Credit_check_with_payment_typ
(  p_header_id            IN   NUMBER
,  p_calling_action       IN   VARCHAR2
,  p_delayed_request      IN   VARCHAR2
,  p_credit_check_rule_id IN   NUMBER := NULL
,  x_msg_count            OUT NOCOPY /* file.sql.39 change */  NUMBER
,  x_msg_data             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  x_return_status        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

l_epayment VARCHAR2(1) ;

l_msg_count         NUMBER        := 0 ;
l_msg_data          VARCHAR2(2000):= NULL ;
l_result_out        VARCHAR2(100);
l_cc_hold_comment   VARCHAR2(2000):= NULL;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXPCRGB: IN Credit_check_with_payment_typ ',1);
    OE_DEBUG_PUB.ADD('p_header_id = '|| p_header_id,1 );
    OE_DEBUG_PUB.ADD('p_calling_action = ' || p_calling_action,1 );
    OE_DEBUG_PUB.ADD('p_delayed_request = '|| p_delayed_request,1 );
    OE_DEBUG_PUB.ADD('p_credit_check_rule_id => '|| p_credit_check_rule_id,1 );
  END IF;

  OE_Credit_Engine_GRP.G_delayed_request    := NULL ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('call Check_Credit for credit checking',1);
  END IF;

   Check_Credit
   (      p_header_id       => p_header_id
      ,   p_calling_action  => p_calling_action
      ,   p_delayed_request => p_delayed_request
      ,   p_credit_check_rule_id => p_credit_check_rule_id
      ,   x_msg_count       => x_msg_count
      ,   x_msg_data        => x_msg_data
      ,   x_cc_hold_comment => l_cc_hold_comment
      ,   x_result_out      => l_result_out
      ,   x_return_status   => x_return_status
   );

   IF G_debug_flag = 'Y'
   THEN
      OE_DEBUG_PUB.ADD('x_return_status '|| x_return_status );
   END IF;

   IF x_return_status = FND_API.G_RET_STS_ERROR
   THEN
         -- Assign the status to SUCCESS as the order will
         -- put on hold when the status  is error
         -- GL currency conversion

          x_return_status := FND_API.G_RET_STS_SUCCESS ;

   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  IF G_debug_flag = 'Y'
  THEN
   OE_DEBUG_PUB.ADD('OEXPCRGB:Final x_return_status = '|| x_return_status,1 );
   OE_DEBUG_PUB.ADD('OEXPCRGB:l_result_out = '|| l_result_out,1 );
   OE_DEBUG_PUB.ADD('OEXPCRGB: OUT Credit_check_with_payment_typ ',1);
  END IF;

  Oe_Globals.G_calling_source:= 'WSH';  --8478151

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
  Oe_Globals.G_calling_source:= 'WSH';  --8478151
      x_return_status := FND_API.G_RET_STS_ERROR;
    oe_debug_pub.add(' SQLERRM: '|| SQLERRM );
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  Oe_Globals.G_calling_source:= 'WSH';  --8478151
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    oe_debug_pub.add(' SQLERRM: '|| SQLERRM );
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
  Oe_Globals.G_calling_source:= 'WSH';  --8478151
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    oe_debug_pub.add(' SQLERRM: '|| SQLERRM );
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Credit_check_with_payment_typ'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Credit_check_with_payment_typ ;

--=========================================================================
-- PROCEDURE  : Get_Customer_Exposure   PUBLIC
-- PARAMETERS : p_customer_id           Customer ID
--            : p_site_id               Bill-to Site ID
--            : p_limit_curr_code       Credit limit currency code
--            : p_credit_check_rule_id  Credit Check Rule Id
--            : x_total_exposure        Credit exposure
--            : x_return_status         Status
-- COMMENT    : This procedure calculates credit exposure for given customer
--              or given bill-to site.
--             This procedure will superseed the original get_customer_exposure
--             API for party level changes from ONT-I
--             For backward compatible reasons, the original procedure
--             will call this procedure
--=========================================================================
PROCEDURE Get_customer_exposure
( p_party_id             IN NUMBER
, p_customer_id           IN NUMBER
, p_site_id               IN NUMBER
, p_limit_curr_code       IN VARCHAR2
, p_credit_check_rule_id  IN NUMBER
, p_need_exposure_details IN VARCHAR2 := 'N'
, x_total_exposure        OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_order_hold_amount     OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_order_amount          OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_ar_amount             OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_external_amount       OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS


l_msg_count             NUMBER        := 0 ;
l_msg_data              VARCHAR2(2000):= NULL ;
l_credit_check_rule_rec OE_CREDIT_CHECK_UTIL.OE_CREDIT_RULES_REC_TYPE ;
l_system_parameters_rec OE_CREDIT_CHECK_UTIL.OE_SYSTEMS_PARAM_REC_TYPE ;
l_usage_curr_tbl        OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;
l_total_exposure        NUMBER;
l_error_curr_tbl        OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;
l_conversion_status     OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;
l_return_status         VARCHAR2(50);
l_include_all_flag      VARCHAR2(15);
i                       INTEGER:=0;
j                       INTEGER:=0;
k                       INTEGER:=0;
f                       INTEGER:=0;

l_start                 NUMBER:=0;
l_end                   NUMBER:=0;

l_global_exposure_flag  VARCHAR2(1);
l_org_id                NUMBER:=0; /* MOAC CREDIT CHECK CHANGE */

BEGIN
 IF G_debug_flag = 'Y'
 THEN
  OE_DEBUG_PUB.ADD('OEXPCRGB: IN Get_Customer_Exposure ',1);
  OE_DEBUG_PUB.ADD('p_party_id              => '|| p_party_id );
  OE_DEBUG_PUB.ADD('p_customer_id           => '|| p_customer_id );
  OE_DEBUG_PUB.ADD('p_site_id               => '|| p_site_id );
  OE_DEBUG_PUB.ADD('p_limit_curr_code       => '|| p_limit_curr_code );
  OE_DEBUG_PUB.ADD('p_credit_check_rule_id  => '|| p_credit_check_rule_id );
  OE_DEBUG_PUB.ADD('p_need_exposure_details => '|| p_need_exposure_details );
 END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_global_exposure_flag := 'N' ;


  ---get credit check rule record
  OE_CREDIT_CHECK_UTIL.GET_credit_check_rule
  ( p_credit_check_rule_id   => p_credit_check_rule_id
  , x_credit_check_rules_rec => l_credit_check_rule_rec
  );

  -----Get system parameters record
  OE_CREDIT_CHECK_UTIL.GET_System_parameters
  ( x_system_parameter_rec=>l_system_parameters_rec
  );

   OE_DEBUG_PUB.ADD('Check entity type ');

-------------------- EXPOSURE -----------------------

/* Modified the following condition to fix the bug 5650329 */
  IF p_party_id IS NOT NULL and ( p_customer_id IS NULL ) and ( p_site_id IS NULL )
  THEN
    l_global_exposure_flag := 'Y' ;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('Party level exposure ');
      OE_DEBUG_PUB.ADD('Calling Get_global_exposure_flag ');
      OE_DEBUG_PUB.ADD('l_global_exposure_flag = '||
           l_global_exposure_flag );
      OE_DEBUG_PUB.ADD('OEXPCRGB: Get usages for PARTY level ');
     END IF;

    ----get table of usages
    OE_CREDIT_CHECK_UTIL.Get_Usages
    ( p_entity_type                 => 'PARTY'
    , p_entity_id                   => p_party_id
    , p_limit_curr_code             => p_limit_curr_code
    , p_suppress_unused_usages_flag => 'Y'
    , p_default_limit_flag          => NULL
    , p_global_exposure_flag        => l_global_exposure_flag
    , x_include_all_flag            => l_include_all_flag
    , x_usage_curr_tbl              => l_usage_curr_tbl
    );

   IF G_debug_flag = 'Y'
    THEN
       OE_DEBUG_PUB.ADD('OEXPCRGB: OUT of OE_CREDIT_CHECK_UTIL. Get_Usages ');
       OE_DEBUG_PUB.ADD('x_include_all_flag: '||l_include_all_flag);
       OE_DEBUG_PUB.ADD('---------------------------------------');
    END IF;

    ----IF l_include_all_flag is 'Y', assign it to the global variable
    --- used later for unchecked exposure

    IF l_include_all_flag='Y'
    THEN
      OE_Credit_Engine_GRP.G_cust_incl_all_flag :='Y';
    END IF;

    FOR a IN 1..l_usage_curr_tbl.COUNT
    LOOP
     IF G_debug_flag = 'Y'
     THEN
       OE_DEBUG_PUB.ADD('currency_code=: '
              ||l_usage_curr_tbl(a).usage_curr_code);
     END IF;
    END LOOP;
--------------------------------------------------------------------------------
    ----assign table of usages to the Global variable

    l_start:=OE_Credit_Engine_GRP.G_cust_curr_tbl.COUNT+1;
    l_end:=OE_Credit_Engine_GRP.G_cust_curr_tbl.COUNT+l_usage_curr_tbl.COUNT;

     IF G_debug_flag = 'Y'
     THEN
        OE_DEBUG_PUB.ADD('l_start= '||TO_CHAR(l_start));
        OE_DEBUG_PUB.ADD('l_end= '||TO_CHAR(l_end));
        OE_DEBUG_PUB.ADD('IN loop for assign table of usge to Glb variable ');
     END IF;

    FOR i IN l_start..l_end
    LOOP
      j:=j+1;
      OE_Credit_Engine_GRP.G_cust_curr_tbl(i).usage_curr_code
                 := l_usage_curr_tbl(j).usage_curr_code;

    END LOOP;

     OE_CREDIT_EXPOSURE_PVT.Get_Exposure
      ( p_party_id                => p_party_id
      , p_customer_id             => NULL
      , p_site_use_id             => NULL
      , p_header_id               => NULL
      , p_credit_check_rule_rec   => l_credit_check_rule_rec
      , p_system_parameters_rec   => l_system_parameters_rec
      , p_limit_curr_code         => p_limit_curr_code
      , p_usage_curr_tbl          => l_usage_curr_tbl
      , p_include_all_flag        => l_include_all_flag
      , p_global_exposure_flag    => l_global_exposure_flag
      , p_need_exposure_details  => p_need_exposure_details
      , x_total_exposure         => x_total_exposure
      , x_order_amount           => x_order_amount
      , x_order_hold_amount      => x_order_hold_amount
      , x_ar_amount              => x_ar_amount
      , x_return_status           => l_return_status
      , x_error_curr_tbl          => l_error_curr_tbl
      );


      IF l_error_curr_tbl.COUNT<>0
      THEN

        FOR k IN 1..l_error_curr_tbl.COUNT
        LOOP
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!');
            OE_DEBUG_PUB.ADD('!!!!! Exchange rate between '||l_error_curr_tbl(k)
.usage_curr_code
               ||' and credit limit currency '
               ||p_limit_curr_code
               ||' is missing for conversion type '
              || NVL(l_credit_check_rule_rec.user_conversion_type,'Corporate'),1
);
            OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!');

          END IF;
        END LOOP;

       x_return_status:='C';

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -----------End party ----
  ---customer level exposure
  ELSIF p_site_id IS NULL
  THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('Customer level exposure ');
      OE_DEBUG_PUB.ADD('Calling Get_global_exposure_flag ');
    END IF;

       l_global_exposure_flag :=
       OE_CREDIT_CHECK_UTIL.Get_global_exposure_flag
       (  p_entity_type      => 'CUSTOMER'
        , p_entity_id        => p_customer_id
        , p_limit_curr_code  => p_limit_curr_code
       );

     /* Start MOAC CREDIT CHECK CHANGE */
     IF l_global_exposure_flag = 'N'
     THEN
         OE_Credit_Engine_GRP.Set_context;
     END IF;
     /* End MOAC CREDIT CHECK CHANGE */

     IF G_debug_flag = 'Y'
     THEN
         OE_DEBUG_PUB.ADD('l_global_exposure_flag = '||
           l_global_exposure_flag );
         OE_DEBUG_PUB.ADD('OEXPCRGB: Get usages for CUSTOMER level ');
     END IF;

    ----get table of usages
    OE_CREDIT_CHECK_UTIL.Get_Usages
    ( p_entity_type                 => 'CUSTOMER'
    , p_entity_id                   => p_customer_id
    , p_limit_curr_code             => p_limit_curr_code
    , p_suppress_unused_usages_flag => 'Y'
    , p_default_limit_flag          => NULL
    , p_global_exposure_flag        => l_global_exposure_flag
    , x_include_all_flag            => l_include_all_flag
    , x_usage_curr_tbl              => l_usage_curr_tbl
    );

    IF G_debug_flag = 'Y'
    THEN
       OE_DEBUG_PUB.ADD('OEXPCRGB: OUT of OE_CREDIT_CHECK_UTIL. Get_Usages ');
       OE_DEBUG_PUB.ADD('x_include_all_flag: '||l_include_all_flag);
       OE_DEBUG_PUB.ADD('---------------------------------------');
    END IF;

    ----IF l_include_all_flag is 'Y', assign it to the global variable
    --- used later for unchecked exposure

    IF l_include_all_flag='Y'
    THEN
      OE_Credit_Engine_GRP.G_cust_incl_all_flag :='Y';
    END IF;


    FOR a IN 1..l_usage_curr_tbl.COUNT
    LOOP
     IF G_debug_flag = 'Y'
     THEN
       OE_DEBUG_PUB.ADD('currency_code=: '
              ||l_usage_curr_tbl(a).usage_curr_code);
     END IF;
    END LOOP;
--------------------------------------------------------------------------------
    ----assign table of usages to the Global variable

    l_start:=OE_Credit_Engine_GRP.G_cust_curr_tbl.COUNT+1;
    l_end:=OE_Credit_Engine_GRP.G_cust_curr_tbl.COUNT+l_usage_curr_tbl.COUNT;

     IF G_debug_flag = 'Y'
     THEN
        OE_DEBUG_PUB.ADD('l_start= '||TO_CHAR(l_start));
        OE_DEBUG_PUB.ADD('l_end= '||TO_CHAR(l_end));
        OE_DEBUG_PUB.ADD('IN loop for assign table of usages to Global variable ');
     END IF;

    FOR i IN l_start..l_end
    LOOP
      j:=j+1;
      OE_Credit_Engine_GRP.G_cust_curr_tbl(i).usage_curr_code
                 := l_usage_curr_tbl(j).usage_curr_code;

    END LOOP;

    ----pre-calculate exposure
    IF l_credit_check_rule_rec.quick_cr_check_flag = 'Y'
    THEN

      OE_CREDIT_EXPOSURE_PVT.Get_Exposure
      ( p_customer_id             => p_customer_id
      , p_site_use_id             => NULL
      , p_header_id               => NULL
      , p_credit_check_rule_rec   => l_credit_check_rule_rec
      , p_system_parameters_rec   => l_system_parameters_rec
      , p_limit_curr_code         => p_limit_curr_code
      , p_usage_curr_tbl          => l_usage_curr_tbl
      , p_include_all_flag        => l_include_all_flag
      , p_global_exposure_flag    => l_global_exposure_flag
      , p_need_exposure_details  => p_need_exposure_details
      , x_total_exposure         => x_total_exposure
      , x_order_amount           => x_order_amount
      , x_order_hold_amount      => x_order_hold_amount
      , x_ar_amount              => x_ar_amount
      , x_return_status           => l_return_status
      , x_error_curr_tbl          => l_error_curr_tbl
      );

      IF l_error_curr_tbl.COUNT<>0
      THEN

        FOR k IN 1..l_error_curr_tbl.COUNT
        LOOP
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            OE_DEBUG_PUB.ADD('!!!!! Exchange rate between '||l_error_curr_tbl(k).usage_curr_code
               ||' and credit limit currency '
               ||p_limit_curr_code
               ||' is missing for conversion type '
              || NVL(l_credit_check_rule_rec.user_conversion_type,'Corporate'),1);
            OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          END IF;
        END LOOP;

       ---bug fix 2439029

       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       x_return_status:='C';

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ----non pre-calculate exposure
    ELSIF l_credit_check_rule_rec.quick_cr_check_flag ='N'
    THEN

      OE_CREDIT_CHECK_UTIL.Get_order_exposure
      ( p_header_id              => NULL
      , p_transaction_curr_code  => NULL
      , p_customer_id            => p_customer_id
      , p_site_use_id            => NULL
      , p_credit_check_rule_rec  => l_credit_check_rule_rec
      , p_system_parameter_rec   => l_system_parameters_rec
      , p_credit_level           => 'CUSTOMER'
      , p_limit_curr_code        => p_limit_curr_code
      , p_usage_curr             => l_usage_curr_tbl
      , p_include_all_flag       => l_include_all_flag
      ,  p_global_exposure_flag  => l_global_exposure_flag
      , p_need_exposure_details  => p_need_exposure_details
      , x_total_exposure         => x_total_exposure
      , x_order_amount           => x_order_amount
      , x_order_hold_amount      => x_order_hold_amount
      , x_ar_amount              => x_ar_amount
      , x_return_status          => l_return_status
      , x_conversion_status      => l_conversion_status
      );


      IF l_conversion_status.COUNT<>0
      THEN

        FOR k IN 1..l_conversion_status.COUNT
        LOOP
         IF G_debug_flag = 'Y'
         THEN
          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
          OE_DEBUG_PUB.ADD('!!!!! Exchange rate between '||l_conversion_status(k).usage_curr_code
                ||' and credit limit currency '
                ||p_limit_curr_code
                ||' is missing for conversion type '
            || NVL(l_credit_check_rule_rec.user_conversion_type,'Corporate'),1);
          OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
         END IF;
        END LOOP;

       ---bug fix 2439029

       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       x_return_status:='C';

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;

 ----------------- SITE level exposure ----------------

  -----bill-to site level exposure
  ELSIF p_site_id IS NOT NULL
  THEN
      l_global_exposure_flag := 'N' ;

/* Start MOAC CREDIT CHECK CHANGE */

    BEGIN
      SELECT org_id
      INTO   l_org_id
      FROM   hz_cust_site_uses_all
      WHERE  site_use_id = p_site_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF G_debug_flag = 'Y' THEN
            OE_DEBUG_PUB.ADD ('Exception : No org id via site_id ', 1);
         END IF;

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
           FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Customer_Exposure'
            );
         END IF;

      WHEN OTHERS THEN
         IF G_debug_flag = 'Y' THEN
            OE_DEBUG_PUB.ADD ('Exception : Unexpected error in finding org id via site_id ', 1);
         END IF;

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
           FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Customer_Exposure'
            );
         END IF;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END ;

    MO_GLOBAL.Set_Policy_Context('S', l_org_id) ;

    OE_CREDIT_CHECK_UTIL.G_org_id := l_org_id ;

/* End MOAC CREDIT CHECK CHANGE */

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('Site level exposure ');
    END IF;

    ----get table of usages
    OE_CREDIT_CHECK_UTIL.Get_Usages
    ( p_entity_type                 => 'SITE'
    , p_entity_id                   => p_site_id
    , p_limit_curr_code             => p_limit_curr_code
    , p_suppress_unused_usages_flag => 'Y'
    , p_default_limit_flag          => NULL
    , p_global_exposure_flag        => 'N'
    , x_include_all_flag            => l_include_all_flag
    , x_usage_curr_tbl              => l_usage_curr_tbl
    );


    ----IF l_include_all_flag is 'Y', assign it to the global variable
    IF l_include_all_flag='Y'
    THEN
      OE_Credit_Engine_GRP.G_site_incl_all_flag:='Y';
    END IF;



    FOR a IN 1..l_usage_curr_tbl.COUNT
    LOOP
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('currency_code=: '||l_usage_curr_tbl(a).usage_curr_code);
      END IF;
    END LOOP;
--------------------------------------------------------------------------------

    ----assign table of usages to the Global variable
    l_start := OE_Credit_Engine_GRP.G_site_curr_tbl.COUNT+1;
    l_end   := OE_Credit_Engine_GRP.G_site_curr_tbl.COUNT+l_usage_curr_tbl.COUNT;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('l_start= '||TO_CHAR(l_start));
      OE_DEBUG_PUB.ADD('l_end= '||TO_CHAR(l_end));
      OE_DEBUG_PUB.ADD('IN loop for assign table of usages to Global variable ');
      OE_DEBUG_PUB.ADD('table of currencies:');
    END IF;

    FOR i IN l_start..l_end
    LOOP

      j:=j+1;
      OE_Credit_Engine_GRP.G_site_curr_tbl(i).usage_curr_code
             := l_usage_curr_tbl(j).usage_curr_code;

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('currency= '||l_usage_curr_tbl(j).usage_curr_code);
      END IF;
    END LOOP;


    ----pre-calculate exposure
    IF l_credit_check_rule_rec.quick_cr_check_flag ='Y'
    THEN

      OE_CREDIT_EXPOSURE_PVT.Get_Exposure
      ( p_customer_id             => p_customer_id
      , p_site_use_id             => p_site_id
      , p_header_id               => NULL
      , p_credit_check_rule_rec   => l_credit_check_rule_rec
      , p_system_parameters_rec   => l_system_parameters_rec
      , p_limit_curr_code         => p_limit_curr_code
      , p_usage_curr_tbl          => l_usage_curr_tbl
      , p_include_all_flag        => l_include_all_flag
      , p_global_exposure_flag    => 'N'
      , p_need_exposure_details  => p_need_exposure_details
      , x_total_exposure         => x_total_exposure
      , x_order_amount           => x_order_amount
      , x_order_hold_amount      => x_order_hold_amount
      , x_ar_amount              => x_ar_amount
      , x_return_status           => l_return_status
      , x_error_curr_tbl          => l_error_curr_tbl
      );

      IF l_error_curr_tbl.COUNT<>0
      THEN
        FOR f IN 1..l_error_curr_tbl.COUNT
        LOOP
         IF G_debug_flag = 'Y'
         THEN
           OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
           OE_DEBUG_PUB.ADD('!!!!! Exchange rate between '||l_error_curr_tbl(f).usage_curr_code
               ||' and credit limit currency '
               ||p_limit_curr_code
               ||' is missing for conversion type '
            || NVL(l_credit_check_rule_rec.user_conversion_type,'Corporate'),1);
           OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
         END IF;
        END LOOP;

       ---bug fix 2439029

       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       x_return_status:='C';

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ----non pre-calculate exposure
    ELSIF l_credit_check_rule_rec.quick_cr_check_flag ='N'
    THEN

      OE_CREDIT_CHECK_UTIL.Get_order_exposure
      ( p_header_id              => NULL
      , p_transaction_curr_code  => NULL
      , p_customer_id            => p_customer_id
      , p_site_use_id            => p_site_id
      , p_credit_check_rule_rec  => l_credit_check_rule_rec
      , p_system_parameter_rec   => l_system_parameters_rec
      , p_credit_level           => 'SITE'
      , p_limit_curr_code        => p_limit_curr_code
      , p_usage_curr             => l_usage_curr_tbl
      , p_include_all_flag       => l_include_all_flag
      , p_global_exposure_flag  => 'N'
      , p_need_exposure_details  => p_need_exposure_details
      , x_total_exposure         => x_total_exposure
      , x_order_amount           => x_order_amount
      , x_order_hold_amount      => x_order_hold_amount
      , x_ar_amount              => x_ar_amount
      , x_return_status          => l_return_status
      , x_conversion_status      => l_conversion_status
      );


      IF l_conversion_status.COUNT<>0
      THEN

        FOR f IN 1..l_conversion_status.COUNT
        LOOP
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            OE_DEBUG_PUB.ADD('!!!!! Exchange rate between '||l_conversion_status(f).usage_curr_code
                   ||' and credit limit currency '
                   ||p_limit_curr_code
                   ||' is missing for conversion type '
             || NVL(l_credit_check_rule_rec.user_conversion_type,'Corporate'),1);
            OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
         END IF;
        END LOOP;

       ---bug fix 2439029

       -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       x_return_status:='C';


      ELSIF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END IF;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXPCRGB: OUT Get_Customer_Exposure with the status='||x_return_status);
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Customer_Exposure'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Get_Customer_Exposure;

--------------------------------------------------------
-- The following is the Original procedure released with ONT-G
-- From the ONT-I, this procedure is overloaded with the
-- party level
-- for backward compatible this procedure is retained
-------------------------------------------------------------
PROCEDURE Get_customer_exposure
( p_customer_id           IN NUMBER
, p_site_id               IN NUMBER
, p_limit_curr_code       IN VARCHAR2
, p_credit_check_rule_id  IN NUMBER
, x_total_exposure    OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

l_msg_count             NUMBER        := 0 ;
l_msg_data              VARCHAR2(2000):= NULL ;

l_order_hold_amount NUMBER;
l_ar_amount         NUMBER;
l_order_amount      NUMBER;
l_EXTERNAL_AMOUNT   NUMBER ;

BEGIN

 IF G_debug_flag = 'Y'
 THEN
    OE_DEBUG_PUB.ADD(' Into Get_customer_exposure ');
    OE_DEBUG_PUB.ADD(' Calling Get_customer_exposure with details');
    OE_DEBUG_PUB.ADD('p_customer_id           => '|| p_customer_id );
    OE_DEBUG_PUB.ADD('p_site_id               => '|| p_site_id );
    OE_DEBUG_PUB.ADD('p_limit_curr_code       => '|| p_limit_curr_code );
    OE_DEBUG_PUB.ADD('p_credit_check_rule_id  => '|| p_credit_check_rule_id );

 END IF;

OE_CREDIT_ENGINE_GRP.Get_customer_exposure
( p_party_id              => NULL
, p_customer_id           => p_customer_id
, p_site_id               => p_site_id
, p_limit_curr_code       => p_limit_curr_code
, p_credit_check_rule_id  => p_credit_check_rule_id
, p_need_exposure_details => 'N'
, x_total_exposure        => x_total_exposure
, x_order_hold_amount     => l_order_hold_amount
, x_order_amount          => l_order_amount
, x_ar_amount             => l_ar_amount
, x_external_amount       => l_external_amount
, x_return_status         => x_return_status
);

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' Out x_total_exposure => '|| x_total_exposure );
    OE_DEBUG_PUB.ADD(' Out x_return_status => '|| x_return_status );
    OE_DEBUG_PUB.ADD(' Out Get_customer_exposure');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Customer_Exposure'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Get_Customer_Exposure;


--------------------------------------------------------------------------
--PROCEDURE: Check_Credit
--COMMENT:  main procedure for checking non electronic payments
--MODIFICATION:
-- 02/15/2002 Removed Default NULL for p_calling_action
---------------------------------------------------------------------------
PROCEDURE Check_Credit
(   p_header_id                 IN      NUMBER
,   p_calling_action            IN      VARCHAR2
,   p_delayed_request           IN      VARCHAR2 := NULL
,   p_bill_to_site_use_id       IN      NUMBER   := NULL
,   p_credit_check_rule_id      IN      NUMBER   := NULL
,   p_functional_currency_code  IN      VARCHAR2 := NULL
,   p_transaction_currency_code IN      VARCHAR2 := NULL
,   p_transaction_amount        IN      NUMBER   := NULL
,   p_org_id                    IN      NUMBER   := NULL
,   x_cc_hold_comment           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,   x_msg_count                 OUT NOCOPY /* file.sql.39 change */     NUMBER
,   x_msg_data                  OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,   x_result_out                OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,   x_return_status             OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

l_msg_count              NUMBER        := 0 ;
l_msg_data               VARCHAR2(2000):= NULL ;
l_credit_check_rule_id   NUMBER;
l_credit_check_rule_rec  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type ;
l_system_parameter_rec   OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type ;
l_cc_limit_used          NUMBER;
l_cc_profile_used        VARCHAR2(30);
l_header_rec             OE_Order_PUB.Header_Rec_Type;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXPCRGB: IN Check_Credit ',1);
    OE_DEBUG_PUB.ADD('Input parameters list ');
    OE_DEBUG_PUB.ADD('p_header_id = '|| p_header_id,1 );
    OE_DEBUG_PUB.ADD('p_delayed_request = '|| p_delayed_request,1 );
    OE_DEBUG_PUB.ADD('p_calling_action = '|| p_calling_action,1 );
    OE_DEBUG_PUB.ADD('p_credit_check_rule_id => '|| p_credit_check_rule_id );
  END IF;

  OE_Credit_Engine_GRP.G_delayed_request    := NULL ;
  OE_Credit_Engine_GRP.G_currency_error_msg := NULL ;
  OE_Credit_Engine_GRP.G_delayed_request    := p_delayed_request ;

--ER#7479609 start
  IF p_calling_action in ('AUTO HOLD','AUTO RELEASE')  THEN
   OE_Verify_Payment_PUB.G_init_calling_action := p_calling_action;
  END IF;
--ER#7479609 end

--bug# 4967828
  IF p_org_id IS NOT NULL THEN
     OE_CREDIT_CHECK_UTIL.G_org_id := p_org_id ;
  END IF;

  -- Get Gl currency if calling action is not EXTERNAL
  --
  IF NVL(p_calling_action, 'BOOKING') <> 'EXTERNAL' THEN
    OE_Credit_Engine_GRP.GL_currency := OE_Credit_Engine_GRP.GET_GL_currency;

    OE_Header_UTIL.Query_Row
        (p_header_id            => p_header_id
        ,x_header_rec           => l_header_rec
        );

    --bug# 4967828
    IF p_org_id IS NULL THEN
       OE_CREDIT_CHECK_UTIL.G_org_id := l_header_rec.org_id ;
    END IF;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('after query header ');
      OE_DEBUG_PUB.ADD(' ');
      OE_DEBUG_PUB.ADD('======================================');
      OE_DEBUG_PUB.ADD('Header ID = '|| l_header_rec.header_id );
      OE_DEBUG_PUB.ADD('order_category_code = '||
         l_header_rec.order_category_code );
      OE_DEBUG_PUB.ADD('Booked flag = '||
         l_header_rec.booked_flag );
      OE_DEBUG_PUB.ADD('Order number = '||
         l_header_rec.order_number );
      --OE_DEBUG_PUB.ADD('Credit crad approval date = '||
      --   l_header_rec.credit_card_approval_date );
      OE_DEBUG_PUB.ADD('payment_term_id = ' ||
      l_header_rec.payment_term_id );
      OE_DEBUG_PUB.ADD('order_type_id = '||
      l_header_rec.order_type_id );
      OE_DEBUG_PUB.ADD(' ');
      OE_DEBUG_PUB.ADD('======================================');
   END IF;

    IF p_credit_check_rule_id is NULL or
         NVL(p_credit_check_rule_id,0) = 0
    THEN

       Get_Credit_Check_Rule_ID
       ( p_calling_action        => p_calling_action
       , p_order_type_id         => l_header_rec.order_type_id
       , x_credit_rule_id        => l_credit_check_rule_id
      );
    ELSE
     l_credit_check_rule_id := p_credit_check_rule_id;
    END IF;

  ELSE
    -- External credit checking call
    l_credit_check_rule_id := p_credit_check_rule_id;
    OE_CREDIT_ENGINE_GRP.GL_Currency := p_functional_currency_code;
    l_header_rec.header_id := NULL;
    l_header_rec.transactional_curr_code := p_transaction_currency_code;
    l_header_rec.invoice_to_org_id := p_bill_to_site_use_id;
  END IF;

    IF G_debug_flag = 'Y'
    THEN
     OE_DEBUG_PUB.ADD(' GL_CURRENCY after = '|| OE_Credit_Engine_GRP.GL_currency );
     OE_DEBUG_PUB.ADD('l_credit_check_rule_id = '|| l_credit_check_rule_id );
    END IF;

  ----------------------- start Processing --------------------

  IF l_credit_check_rule_id is NULL
  THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' No credit check attached, return ');
    END IF;
    RETURN ;
  END IF;

  -- Initialize the G_cc_hold_item_type and G_cc_hold_activity_name
  -- global variables
  Set_G_CC_Hold_Info;

  OE_CREDIT_CHECK_UTIL.GET_credit_check_rule
  ( p_credit_check_rule_id   => l_credit_check_rule_id
  , x_credit_check_rules_rec => l_credit_check_rule_rec
  );

  OE_CREDIT_CHECK_UTIL.GET_System_parameters
  ( x_system_parameter_rec => l_system_parameter_rec
  );

  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.ADD('credit_check_level_code = '||
       l_credit_check_rule_rec.credit_check_level_code );
  END IF;

  IF NVL(l_credit_check_rule_rec.credit_check_level_code,'ORDER')
          = 'ORDER'
  THEN
    OE_Credit_check_order_PVT.Check_order_credit
    ( p_header_rec            => l_header_rec
    , p_calling_action        => p_calling_action
    , p_credit_check_rule_rec => l_credit_check_rule_rec
    , p_system_parameter_rec  => l_system_parameter_rec
    , p_transaction_amount    => p_transaction_amount
    , x_msg_count             => x_msg_count
    , x_msg_data              => x_msg_data
    , x_cc_result_out         => x_result_out
    , x_cc_hold_comment       => x_cc_hold_comment
    , x_return_status         => x_return_status
    );

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXPCRGB: Out of Check_order_credit ');
      OE_DEBUG_PUB.ADD('x_return_status = '|| x_return_status );
      OE_DEBUG_PUB.ADD('x_result_out =>' || x_result_out );
    END IF;

  ELSIF NVL(l_credit_check_rule_rec.credit_check_level_code,'ORDER')
          = 'LINE'
  THEN

--8478151
      IF NVL(p_delayed_request, FND_API.G_FALSE) = FND_API.G_TRUE  and p_calling_action = 'SHIPPING' THEN
          Oe_Globals.G_calling_source:= 'ONT';
      END IF;
--8478151

    OE_Credit_Check_lines_PVT.G_line_hold_count := 0;
    OE_Credit_check_lines_PVT.Check_order_lines_credit
    ( p_header_rec            => l_header_rec
    , p_calling_action        => p_calling_action
    , p_credit_check_rule_rec => l_credit_check_rule_rec
    , p_system_parameter_rec  => l_system_parameter_rec
    , x_msg_count             => x_msg_count
    , x_msg_data              => x_msg_data
    , x_cc_result_out         => x_result_out
    , x_cc_limit_used         => l_cc_limit_used
    , x_cc_profile_used       => l_cc_profile_used
    , x_return_status         => x_return_status
    ) ;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXPCRGB: Out of Check_order_lines_credit ');
      OE_DEBUG_PUB.ADD('x_return_status = '|| x_return_status );
      OE_DEBUG_PUB.ADD('x_result_out => '|| x_result_out );
      OE_DEBUG_PUB.ADD('line hold count =>'||OE_Credit_Check_lines_PVT.G_line_hold_count);
    END IF;
  END IF;

  -- Moved calling_action check to outside of status check
  IF p_calling_action <> 'EXTERNAL' THEN
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN


      Apply_exception_hold
        ( p_header_id            => p_header_id
        , x_return_status        => x_return_status
        );

       IF G_debug_flag = 'Y'
       THEN
         OE_DEBUG_PUB.ADD('Apply_exception_hold  x_return_status => '
              || x_return_status );
       END IF;

      IF x_return_status = FND_API.G_RET_STS_SUCCESS
      THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;
    END IF;  -- apply exception hold
    -- set result out to FAIL when credit check failed or
    -- when an exception occurred and a hold was successfully placed

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_result_out := 'FAIL' ;
    END IF;
  ELSE  -- for the case of EXTERNAL credit check
    -- x_return_status is either SUCCESS, ERROR or UNEXP_ERROR
    -- for external. If it is is and expected error, it might be
    -- due to credit check failure or failure from currency conversion.
    -- In this case, don't attempt to place credit hold
    -- set return status to SUCCESS with result_out=FAIL to indicate that
    -- credit checking completed successfully, even though
    -- the result_out is failure.
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

      IF G_debug_flag = 'Y'
      THEN
         OE_DEBUG_PUB.ADD( ' x_return_status = '|| x_return_status );
         OE_DEBUG_PUB.ADD( ' G_currency_error_msg = '||
              OE_Credit_Engine_GRP.G_currency_error_msg );
       END IF;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      x_result_out := 'FAIL';
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      x_result_out := 'FAIL';
    END IF;
    -- for success, default is PASS
  END IF;

  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.ADD('after excp holds  x_return_status => '
            || x_return_status );
     OE_DEBUG_PUB.ADD('after excp holds x_result_out => '
            || x_result_out );
     OE_DEBUG_PUB.ADD('Check for notification send ' ) ;
   END IF;

  IF x_result_out = 'FAIL_HOLD' AND -- Bug 4506263 FP
      NVL(p_calling_action, 'BOOKING') NOT IN ('EXTERNAL', 'AUTO RELEASE')
  THEN
    IF  l_credit_check_rule_rec.send_hold_notifications_flag = 'Y'
    THEN
      OE_credit_check_util.send_credit_hold_ntf
      ( p_header_rec        => l_header_rec
      , p_credit_hold_level => l_credit_check_rule_rec.credit_hold_level_code
      , p_cc_hold_comment   => x_cc_hold_comment
      , x_return_status     => x_return_status
      );

      IF G_debug_flag = 'Y'
      THEN

        OE_DEBUG_PUB.ADD('after call send_credit_hold_ntf ');
        OE_DEBUG_PUB.ADD('x_return_status = '|| x_return_status );
        OE_DEBUG_PUB.ADD('line hold count =>'||OE_Credit_Check_lines_PVT.G_line_hold_count);
      END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS
       THEN

         OE_DEBUG_PUB.ADD('send failed ');

         x_return_status := FND_API.G_RET_STS_SUCCESS ;

        OE_DEBUG_PUB.ADD(' after assign x_return_status = '
                || x_return_status );
       END IF;


     ELSE
       IF G_debug_flag = 'Y'
       THEN
          OE_DEBUG_PUB.ADD('No need for sending notifications flag OFF or ignored',1);
       END IF;
     END IF;

  END IF;



  OE_Credit_Engine_GRP.G_delayed_request    := NULL ;

  IF p_calling_action = 'EXTERNAL'
  THEN
    OE_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    );
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('Final x_return_status => '|| x_return_status );
    OE_DEBUG_PUB.ADD('Final x_result_out => '|| x_result_out );
    OE_DEBUG_PUB.ADD('OEXPCRGB: OUT Check_Credit ',1);
  END IF;

  Oe_Globals.G_calling_source:= 'WSH';  --8478151

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
  Oe_Globals.G_calling_source:= 'WSH';  --8478151
      x_return_status := FND_API.G_RET_STS_ERROR;
       x_result_out := 'FAIL' ;
      OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  Oe_Globals.G_calling_source:= 'WSH';  --8478151
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_result_out := 'FAIL' ;
      OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

    WHEN OTHERS THEN
  Oe_Globals.G_calling_source:= 'WSH';  --8478151
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       x_result_out := 'FAIL' ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_Credit'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

END Check_Credit ;

/* Start MOAC CREDIT CHECK CHANGE */
------------------------------------------------------------------------------
--  PROCEDURE  : Set_context                 PRIVATE
--  COMMENT    : This procedure set the context
--
--------------------------------------------------------------------------------
PROCEDURE Set_context
IS
--
l_org_id        NUMBER;
--
BEGIN

  OE_DEBUG_PUB.ADD('OEXPCRGB: IN Set_context ' );
  BEGIN

    l_org_id :=  mo_global.get_current_org_id;

    IF l_org_id IS NOT NULL THEN
       IF G_debug_flag = 'Y' THEN
          oe_debug_pub.add(  'OEXPCRGB: setting single org context to '|| l_org_id , 1 );
       END IF;

       MO_GLOBAL.Set_Policy_Context('S', l_org_id);
    ELSE
       IF G_debug_flag = 'Y' THEN
          oe_debug_pub.add('OEXPCRGB: Unexpected error in setting org context where Customer Exposure flag is ''''N', 1 );
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OE_CREDIT_CHECK_UTIL.G_org_id := l_org_id ;

    IF l_org_id IS NULL THEN
       Fnd_Message.set_name('FND','MO_ORG_REQUIRED');
       Oe_Msg_Pub.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
    l_org_id := NULL ;

    OE_CREDIT_CHECK_UTIL.G_org_id := NULL ;

    OE_DEBUG_PUB.ADD(' Exception Set context');
  END ;

  OE_DEBUG_PUB.ADD('OEXPCRGB: OUT Set_context ' );

EXCEPTION
  WHEN OTHERS THEN
    IF G_debug_flag = 'Y' THEN
       OE_DEBUG_PUB.ADD ('Exception : Unexpected error from Set_Context ', 1);
    END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
       ,   'Set_Context'
       );
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Set_context ;

/* End MOAC CREDIT CHECK CHANGE */

END OE_Credit_Engine_GRP ;

/
