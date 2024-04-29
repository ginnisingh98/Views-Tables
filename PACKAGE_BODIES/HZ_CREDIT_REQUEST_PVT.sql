--------------------------------------------------------
--  DDL for Package Body HZ_CREDIT_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CREDIT_REQUEST_PVT" AS
-- $Header: OEXCRRQB.pls 120.0.12010000.3 2009/08/21 07:31:08 amimukhe ship $

--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------

-------------------------
-- PUBLIC VARIABLES
-------------------------
  G_PKG_NAME    CONSTANT VARCHAR2(30) := 'HZ_CREDIT_REQUEST_PVT';
----------------------
-- PRIVATE VARIABLES
----------------------
---added for bug#8617023 start
G_debug_flag VARCHAR2(1)  := NVL( OE_CREDIT_CHECK_UTIL.check_debug_flag ,'N') ;
G_hdr_hold_released VARCHAR2(1)  := 'N' ;
---added for bug#8617023 end

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--------------------------------------------------------------------------------------------
-- This procedure is added for bug 8617023.
-- After this change when Credit Manager will submitt the recomendation
-- to release Credit Check Faliure Hold Release_Order_CC_Hold procedure will be used
-- instead of OE_CREDIT_CHECK_ORDER_PVT.Release_Order_CC_Hold.
-- This procedure has an extra parameter of p_user_id to denote the User who actually
-- released the hold. The hold release will be treated as Manual release instead of
-- automatic release.
--------------------------------------------------------------------------------------------

PROCEDURE Release_Order_CC_Hold ( p_header_id            IN NUMBER ,
                                  p_order_number         IN NUMBER ,
                                  p_calling_action       IN VARCHAR2 DEFAULT 'BOOKING',
                                  P_SYSTEM_PARAMETER_REC IN OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type ,
                                  p_user_id              IN NUMBER,  --parameter added
                                  x_cc_result_out OUT NOCOPY VARCHAR2 )
IS
        l_hold_entity_id NUMBER := p_header_id;
        l_hold_id        NUMBER;
        l_hold_exists    VARCHAR2(1);
        l_hold_result    VARCHAR2(30) := NULL;
        l_msg_count      NUMBER := 0;
        l_msg_data       VARCHAR2(2000);
        l_return_status  VARCHAR2(30);
        l_release_reason VARCHAR2(30);
        l_cc_result_out  VARCHAR2(30)                         := 'PASS_NONE';
        l_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type   := OE_HOLDS_PVT.G_MISS_Hold_Source_REC;
        l_hold_release_rec OE_HOLDS_PVT.Hold_Release_Rec_Type := OE_HOLDS_PVT.G_MISS_Hold_Release_REC;

BEGIN
        IF G_debug_flag = 'Y' THEN
                oe_debug_pub.add('In Release_Order_CC_Hold');
        END IF;
        l_return_status := FND_API.G_RET_STS_SUCCESS;
        IF G_debug_flag  = 'Y' THEN
                oe_debug_pub.add('Check if Holds exist to release ');
        END IF;

         -- check whether holds exists
	 oe_debug_pub.add('Calling OE_HOLDS_PUB.Check_Holds ');
         oe_debug_pub.add('p_wf_item :: '||OE_Credit_Engine_GRP.G_cc_hold_item_type);
         oe_debug_pub.add('p_wf_activity :: '||OE_Credit_Engine_GRP.G_cc_hold_activity_name);

	 OE_HOLDS_PUB.Check_Holds ( p_api_version => 1.0 ,
	 			    p_header_id => p_header_id ,
	 			    p_hold_id => 1 ,
	 			    p_wf_item => OE_Credit_Engine_GRP.G_cc_hold_item_type ,
	 			    p_wf_activity => OE_Credit_Engine_GRP.G_cc_hold_activity_name ,
	 			    p_entity_code => 'O' ,
                                    p_entity_id => p_header_id ,
	 			    x_result_out => l_hold_result ,
	 			    x_msg_count => l_msg_count ,
	 			    x_msg_data => l_msg_data ,
	 			    x_return_status => l_return_status
	 			   );
	IF G_debug_flag = 'Y' THEN
	   oe_debug_pub.add('Out Check_Holds ');
	   oe_debug_pub.add('l_return_status = '|| l_return_status );
     oe_debug_pub.add('l_hold_result = '|| l_hold_result );
	END IF;
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- releasing the Hold
        IF l_hold_result = FND_API.G_TRUE  THEN
                l_hold_source_rec.hold_id              := 1; -- Credit Checking hold
                l_hold_source_rec.HOLD_ENTITY_CODE     := 'O';
                l_hold_source_rec.HOLD_ENTITY_ID       := p_header_id;
                l_hold_release_rec.release_reason_code := 'AR_APPROVE';
                l_hold_release_rec.release_comment     := 'Approved by Credit Manager' ;
                l_hold_release_rec.created_by          := p_user_id; -- Manually Released By Credit Manager
                IF G_debug_flag                         = 'Y' THEN
                        oe_debug_pub.add('Attempt to Release hold on '|| p_header_id);
                END IF;
                IF NVL(p_calling_action, 'BOOKING') <> 'AUTO HOLD' THEN
           	            OE_Holds_PUB.Release_Holds ( p_api_version => 1.0 ,
                                                     p_hold_source_rec => l_hold_source_rec ,
                                                     p_hold_release_rec => l_hold_release_rec ,
                                                     x_msg_count => l_msg_count ,
                                                     x_msg_data => l_msg_data ,
                                                     x_return_status => l_return_status
                                                    );
                        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                                RAISE FND_API.G_EXC_ERROR;
                        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                        ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
                                IF G_debug_flag = 'Y' THEN
                                        oe_debug_pub.add('Released credit check hold on Header ID:'|| p_header_id);
                                END IF;
                        END IF;
                        l_cc_result_out := 'PASS_REL';
                END IF; -- calling action check
        END IF;         -- hold exist
        x_cc_result_out := l_cc_result_out;
        IF G_debug_flag  = 'Y' THEN
                oe_debug_pub.add('Out Release_Order_CC_Hold');
        END IF;
EXCEPTION
WHEN OTHERS THEN
        oe_debug_pub.add('EXCEPTION :: Release_Order_CC_Hold' );
        RAISE;
END Release_Order_CC_Hold;

--------------------------------------------------------------------------------------------
-- This procedure is added for bug 8617023.
-- After this change when Credit Manager will submitt the recomendation
-- to release Credit Check Faliure Hold Release_Line_CC_Hold procedure will be used
-- instead of OE_CREDIT_CHECK_ORDER_PVT.Release_Line_CC_Hold.
-- This procedure has an extra parameter of p_user_id to denote the User who actually
-- released the hold. The hold release will be treated as Manual release instead of
-- automatic release.
--------------------------------------------------------------------------------------------

PROCEDURE Release_Line_CC_Hold
  ( p_header_id            IN NUMBER
  , p_order_number         IN NUMBER
  , p_line_id              IN NUMBER
  , p_line_number          IN NUMBER
  , p_calling_action       IN VARCHAR2   DEFAULT NULL
  , p_credit_hold_level    IN VARCHAR2
  , p_user_id              IN NUMBER
  , x_cc_result_out        OUT NOCOPY VARCHAR2
  )
IS
  l_hold_entity_id         NUMBER := p_header_id;
  l_hold_id	               NUMBER;
  l_hold_exists            VARCHAR2(1);
  l_hold_result            VARCHAR2(30) := NULL;
  l_msg_count              NUMBER := 0;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(30);
  l_release_reason         VARCHAR2(30);
  l_cc_result_out          VARCHAR2(30) := 'PASS_NONE';

  l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type :=
                       OE_HOLDS_PVT.G_MISS_Hold_Source_REC;
  l_hold_release_rec   OE_HOLDS_PVT.Hold_Release_Rec_Type :=
                       OE_HOLDS_PVT.G_MISS_Hold_Release_REC;
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.add(' In Release_Line_CC_Hold');
    oe_debug_pub.add('Processing line ID = '|| p_line_id );
  END IF;

  l_return_status := FND_API.G_RET_STS_SUCCESS;


  --checking whether HOLD exists
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('Check for holds for Header/Line ID : '|| p_header_id || '/' || p_line_id);
      END IF;

      OE_HOLDS_PUB.Check_Holds
  		      (   p_api_version    => 1.0
              		, p_header_id      => p_header_id
  		        , p_line_id        => p_line_id
  		        , p_hold_id        => 1
              		, p_wf_item        => OE_Credit_Engine_GRP.G_cc_hold_item_type
              		, p_wf_activity    => OE_Credit_Engine_GRP.G_cc_hold_activity_name
  		        , p_entity_code    => 'O'
  		        , p_entity_id      => p_header_id
  		        , x_result_out     => l_hold_result
  		        , x_msg_count      => l_msg_count
  		        , x_msg_data       => l_msg_data
  		        , x_return_status  => l_return_status
  		      );

      IF G_debug_flag = 'Y'
      THEN
      	OE_DEBUG_PUB.ADD('Out Check_Holds');
        OE_DEBUG_PUB.ADD('l_return_status :'||l_return_status);
        OE_DEBUG_PUB.ADD('l_hold_result :'||l_hold_result);
      END IF;

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     	RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  --end check hold exits

  IF l_hold_result = FND_API.G_TRUE  THEN
    IF NVL(p_calling_action,'BOOKING') <> 'AUTO HOLD' THEN
      l_hold_source_rec.hold_id                := 1;  -- Credit Checking hold
      l_hold_source_rec.HOLD_ENTITY_CODE       := 'O';
      l_hold_source_rec.HOLD_ENTITY_ID         := p_header_id;
      l_hold_source_rec.line_id                := p_line_id;

      l_hold_release_rec.release_reason_code   := 'AR_APPROVE';
      l_hold_release_rec.release_comment       := 'Approved by Credit Manager' ;
      l_hold_release_rec.created_by            := p_user_id; -- Manually Released By Credit Manager

      OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF NVL(G_hdr_hold_released,'N') = 'N'
        THEN
          l_cc_result_out := 'HDR_HOLD' ;
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF NVL(G_hdr_hold_released,'N') = 'N'
        THEN
          l_cc_result_out := 'HDR_HOLD' ;
        ELSE
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSIF l_return_status =FND_API.G_RET_STS_SUCCESS THEN
          l_cc_result_out := 'PASS_REL';
      END IF;
    END IF; -- check calling action
  ELSE
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' No Hold exist to be Released ');
    END IF;
  END IF;  -- Holds Exist IF

  x_cc_result_out := l_cc_result_out;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('x_cc_result_out = '|| x_cc_result_out );
    OE_DEBUG_PUB.ADD('Out Release_Line_CC_Hold');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
        OE_DEBUG_PUB.ADD('EXCEPTION :: Release_LINE_CC_Hold' );
        RAISE;
     RAISE;

END Release_Line_CC_Hold;
----------------------------------------------------------------

----------------------------------------------------------------
--This is rule function, that is subscribed to the Oracle Workflow
-- Business Event CreditRequest.Recommendation.implement
--to implement recomendations of the AR CRedit Management Review
----------------------------------------------------------------
FUNCTION Rule_Credit_Recco_Impl
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2
IS
l_key                   VARCHAR2(240);
l_credit_check_rule_rec OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type;
l_header_rec           OE_ORDER_PUB.Header_Rec_Type;
l_credit_check_rule_id NUMBER;
l_limit_currency       AR_CMGT_CREDIT_REQUESTS.limit_currency%TYPE;
l_trx_amount           NUMBER;
l_trx_currency         AR_CMGT_CREDIT_REQUESTS.trx_currency%TYPE;
l_source_column1       NUMBER;
l_source_column2       NUMBER;
l_source_column3       VARCHAR2(30);
l_CASE_FOLDER_ID       NUMBER; --bug#8617023
l_released_by          NUMBER; --bug#8617023
l_party_id             NUMBER;
l_cust_account_id      NUMBER;
l_site_use_id          NUMBER;

l_new_amount           NUMBER;

l_cc_result_out        VARCHAR2(30);
l_conversion_status    OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE ;
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_return_status        VARCHAR2(30);
l_credit_request_id    NUMBER;
l_user_id              NUMBER;
l_resp_id              NUMBER;
l_resp_appl_id         NUMBER;
l_security_group_id    NUMBER;
l_count                NUMBER;
l_source_org_id        NUMBER; -- bug 7120635

-- note: This cursor does not take payment type into account for 11.5.10
CURSOR billto_lines_csr(p_site_use_id NUMBER,p_header_id NUMBER)
IS
SELECT
  l.line_id
, l.line_number
FROM
  oe_order_lines_all l
, ra_terms_b t
WHERE  l.invoice_to_org_id = p_site_use_id
  AND    l.header_id         = p_header_id
  AND    l.open_flag         = 'Y'
  AND    l.booked_flag       = 'Y'
  AND    NVL(l.invoiced_quantity,0) = 0
  AND    NVL(l.shipped_quantity,0) = 0
  AND    l.line_category_code  = 'ORDER'
  AND    l.payment_term_id   = t.term_id
  AND    t.credit_check_flag = 'Y'
ORDER BY l.line_id;

-- 4299254
CURSOR lines_csr(p_header_id NUMBER)
IS
SELECT
  l.line_id
, l.line_number
FROM
  oe_order_lines_all l
, ra_terms_b t
WHERE    l.header_id         = p_header_id
  AND    l.open_flag         = 'Y'
  AND    l.booked_flag       = 'Y'
  AND    NVL(l.invoiced_quantity,0) = 0
  AND    NVL(l.shipped_quantity,0) = 0
  AND    l.line_category_code  = 'ORDER'
  AND    l.payment_term_id   = t.term_id
  AND    t.credit_check_flag = 'Y'
ORDER BY l.line_id;

BEGIN

  l_key                  := p_event.GetEventKey();
  l_credit_request_id    := p_event.GetValueForParameter('CREDIT_REQUEST_ID');
  l_source_column1       := p_event.GetValueForParameter('SOURCE_COLUMN1');
  l_source_column2       := p_event.GetValueForParameter('SOURCE_COLUMN2');
  l_source_column3       := p_event.GetValueForParameter('SOURCE_COLUMN3');
  l_CASE_FOLDER_ID       := p_event.GetValueForParameter('CASE_FOLDER_ID'); --bug#8617023

  --check that the recomendation exist

  --bug# 8617023 start
  --changed the logic of the select statement
  --instead of count we will now fetch the
  --id of the user who actually released the
  --hold
    l_count := 1;
    BEGIN
  	  SELECT CREATED_BY
  	  INTO l_released_by
  	  FROM  ar_cmgt_cf_recommends
  	  WHERE credit_request_id = l_credit_request_id
  	  AND credit_recommendation = 'REMOVE_ORDER_HOLD'
  	  AND status = 'I'
  	  AND CASE_FOLDER_ID = l_CASE_FOLDER_ID;
   EXCEPTION
   	  WHEN OTHERS THEN
   	       l_count := 0;
   END;
    /*
  SELECT COUNT(1)
  INTO l_count
  FROM  ar_cmgt_cf_recommends
  WHERE credit_request_id = l_credit_request_id
    AND credit_recommendation = 'REMOVE_ORDER_HOLD'
    AND status = 'I';*/
  --bug# 8617023 end

  -- proceed if recommendation is to release order
  IF l_count > 0 THEN
    -- Get the credit management information required to release the hold
    BEGIN
      SELECT
          limit_currency
        , credit_check_rule_id
        , trx_currency
        , trx_amount
        , party_id
        , cust_account_id
        , site_use_id  --4299254
        , source_user_id
        , source_resp_id
        , source_resp_appln_id
        , source_security_group_id
        , source_org_id -- Bug 7120635
      INTO l_limit_currency
        , l_credit_check_rule_id
        , l_trx_currency
        , l_trx_amount
        , l_party_id
        , l_cust_account_id
        , l_site_use_id
        , l_user_id
        , l_resp_id
        , l_resp_appl_id
        , l_security_group_id
        , l_source_org_id -- Bug 7120635
      FROM ar_cmgt_credit_requests
      WHERE credit_request_id = l_credit_request_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    -- set security context
    FND_GLOBAL.apps_initialize
    (  l_user_id
     , l_resp_id
     , l_resp_appl_id
     , l_security_group_id
    );

     -- for 7120635
       MO_GLOBAL.set_policy_context('S', l_source_org_id);
    --MO_GLOBAL.INIT('ONT');

    --Populate credit check rule record
    OE_CREDIT_CHECK_UTIL.GET_credit_check_rule
    ( p_header_id              => l_source_column1
    , p_credit_check_rule_id   => l_credit_check_rule_id
    , x_credit_check_rules_rec => l_credit_check_rule_rec
     );

    -- for order level hold we will call
    IF l_source_column3 = 'ORDER' THEN
      -- Get new transactional amount
      OE_CREDIT_CHECK_UTIL.GET_transaction_amount
      ( p_header_id              => l_source_column1
      , p_transaction_curr_code  => l_trx_currency
      , p_credit_check_rule_rec  => l_credit_check_rule_rec
      , p_system_parameter_rec   => NULL
      , p_customer_id            => l_cust_account_id
      , p_site_use_id            => l_site_use_id
      , p_limit_curr_code        => l_limit_currency
      , x_amount                 => l_new_amount
      , x_conversion_status      => l_conversion_status
      , x_return_status          => l_return_status
      );

      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --check if the order_amount has been changed
      --if amount has not been changed, release the hold
      --should raise message indicating that amount has changed and hold is not release.

      IF l_new_amount = l_trx_amount THEN
        --commented for bug#8617023
        /*OE_CREDIT_CHECK_ORDER_PVT.Release_Order_CC_Hold
        (  p_header_id           => l_source_column1
         , p_order_number        => l_source_column2
         , p_calling_action      =>  NULL
         , p_system_parameter_rec=>  NULL
         , x_cc_result_out       => l_cc_result_out
        ); */

	--added for bug#8617023
	  Release_Order_CC_Hold
	  (  p_header_id           => l_source_column1
	   , p_order_number        => l_source_column2
	   , p_calling_action      =>  NULL
	   , p_system_parameter_rec=>  NULL
           , p_user_id             => l_released_by
	   , x_cc_result_out       => l_cc_result_out
	  );

      END IF;
    ELSE  --for line level hold
      --4299254: If the order goes on hold using site level limits, release hold
      --for the lines corresponding to that bill to site, otherwise release the hold
      --for all the lines.
      -- Credit Management inserts site_use_id as -99,if OM pass it as NULL.
      IF nvl(l_site_use_id,-99) > 0 THEN
         --Get new transactional amount for this bill to site..
	 --Bug 4377933: If customer_id is passed as NULL,then this API returns the transaction
	 --amount for site..
	 OE_CREDIT_CHECK_UTIL.GET_transaction_amount
	  ( p_header_id              => l_source_column1
	  , p_transaction_curr_code  => l_trx_currency
	  , p_credit_check_rule_rec  => l_credit_check_rule_rec
	  , p_system_parameter_rec   => NULL
	  , p_customer_id            => NULL
	  , p_site_use_id            => l_site_use_id
	  , p_limit_curr_code        => l_limit_currency
	  , x_amount                 => l_new_amount
	  , x_conversion_status      => l_conversion_status
	  , x_return_status          => l_return_status
	  );
	 IF l_return_status = FND_API.G_RET_STS_ERROR
	 THEN
	    RAISE FND_API.G_EXC_ERROR;
	 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	 THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
         --Check if amount per bill-to site has been changed
         --if amount has not been changed, release holds for bill_to site
	 IF l_new_amount = l_trx_amount THEN
           --OPEN the cursor for sites
		FOR c_line IN billto_lines_csr(p_site_use_id =>l_site_use_id
			 ,p_header_id =>l_source_column1)
		LOOP
		  --commented for bug#8617023
		  /* OE_CREDIT_CHECK_LINES_PVT.Release_Line_CC_Hold
		  ( p_header_id         => l_source_column1
		  , p_order_number      => l_source_column2
		  , p_line_id           => c_line.line_id
		  , p_line_number       => c_line.line_number
		  , p_calling_action    => NULL
		  , p_credit_hold_level => 'LINE'
		  , x_cc_result_out     => l_cc_result_out
		  ); */
		  --added for bug#8617023
      		  Release_Line_CC_Hold
		  ( p_header_id         => l_source_column1
		  , p_order_number      => l_source_column2
		  , p_line_id           => c_line.line_id
		  , p_line_number       => c_line.line_number
		  , p_calling_action    => NULL
		  , p_credit_hold_level => 'LINE'
      		  , p_user_id           => l_released_by
		  , x_cc_result_out     => l_cc_result_out
		  );

		END LOOP;
         END IF;
      ELSE --If the order goes on hold using customer credit limits
         OE_CREDIT_CHECK_UTIL.GET_transaction_amount
	  ( p_header_id              => l_source_column1
	  , p_transaction_curr_code  => l_trx_currency
	  , p_credit_check_rule_rec  => l_credit_check_rule_rec
	  , p_system_parameter_rec   => NULL
	  , p_customer_id            => l_cust_account_id
	  , p_site_use_id            => l_site_use_id
	  , p_limit_curr_code        => l_limit_currency
	  , x_amount                 => l_new_amount
	  , x_conversion_status      => l_conversion_status
	  , x_return_status          => l_return_status
	  );
	 IF l_return_status = FND_API.G_RET_STS_ERROR
	 THEN
	    RAISE FND_API.G_EXC_ERROR;
	 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
	 THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
         IF l_new_amount = l_trx_amount THEN
           --OPEN the cursor for all lines
		FOR c_line IN lines_csr(p_header_id =>l_source_column1)
		LOOP
		  --commented for bug#8617023
		  /*OE_CREDIT_CHECK_LINES_PVT.Release_Line_CC_Hold
		  ( p_header_id         => l_source_column1
		  , p_order_number      => l_source_column2
		  , p_line_id           => c_line.line_id
		  , p_line_number       => c_line.line_number
		  , p_calling_action    => NULL
		  , p_credit_hold_level => 'LINE'
		  , x_cc_result_out     => l_cc_result_out
		  );*/

		  --added for bug#8617023
                  Release_Line_CC_Hold
		  ( p_header_id         => l_source_column1
		  , p_order_number      => l_source_column2
		  , p_line_id           => c_line.line_id
		  , p_line_number       => c_line.line_number
		  , p_calling_action    => NULL
		  , p_credit_hold_level => 'LINE'
      	          , p_user_id           => l_released_by
		  , x_cc_result_out     => l_cc_result_out
		  );

		END LOOP;
         END IF;
      END IF; -- end of check if site_use_id is passed.
    END IF;  --end of check if hold is line level or order level
  END IF;  --end of check if recommendation is to release hold

  RETURN 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME( 'AR', 'GENERIC_MESSAGE' );
    FND_MESSAGE.SET_TOKEN( 'GENERIC_TEXT' ,SQLERRM );
    FND_MSG_PUB.ADD;
    WF_CORE.CONTEXT('HZ_CREDIT_REQUEST_PVT',
                    'Rule_Credit_Recco_Impl',
                    p_event.getEventName(),
                    p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');

    RETURN 'ERROR';
END Rule_Credit_Recco_Impl;



END HZ_CREDIT_REQUEST_PVT ;

/
