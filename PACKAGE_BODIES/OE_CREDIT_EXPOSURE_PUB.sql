--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_EXPOSURE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_EXPOSURE_PUB" AS
-- $Header: OEXPCRXB.pls 120.0 2005/06/01 03:05:39 appldev noship $
--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------
G_debug_flag  VARCHAR2(1) :=
 NVL( OE_CREDIT_CHECK_UTIL.check_debug_flag ,'N') ;

-------------------
-- PUBLIC VARIABLES
-------------------

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------
----------------------------------------------------------------
-- This procedure returns the total exposure and also the
-- individual balance for OM and AR
-- based on the credit check rule
-- It is an overloaded Get_customer_exposure API

-- This will replace Get_customer_exposure for all new
-- references. The original method Get_customer_exposure
-- will continue to remain for backward compatibility
----------------------------------------------------------------
PROCEDURE Get_customer_exposure
( p_party_id              IN NUMBER
, p_customer_id           IN NUMBER
, p_site_id               IN NUMBER
, p_limit_curr_code       IN VARCHAR2
, p_credit_check_rule_id  IN NUMBER
, x_total_exposure        OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_order_hold_amount     OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_order_amount          OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_ar_amount             OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_external_amount       OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_return_status         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 x_total_exposure        := 0 ;
 x_order_hold_amount     := 0 ;
 x_order_amount          := 0 ;
 x_ar_amount             := 0 ;
 x_external_amount       := 0 ;

 IF G_debug_flag = 'Y'
 THEN
  OE_DEBUG_PUB.ADD( 'IN OEXPCRXB: Get_Customer_Exposure ');
  OE_DEBUG_PUB.ADD(' Calling OE_Credit_Engine_GRP.Get_customer_exposure',1);

  OE_DEBUG_PUB.ADD('OEXPCRGB: IN Get_Customer_Exposure ',1);
  OE_DEBUG_PUB.ADD('p_party_id              => '|| p_party_id );
  OE_DEBUG_PUB.ADD('p_customer_id           => '|| p_customer_id );
  OE_DEBUG_PUB.ADD('p_site_id               => '|| p_site_id );
  OE_DEBUG_PUB.ADD('p_limit_curr_code       => '|| p_limit_curr_code );
  OE_DEBUG_PUB.ADD('p_credit_check_rule_id  => '|| p_credit_check_rule_id );
 END IF;


 OE_Credit_Engine_GRP.Get_customer_exposure
 ( p_party_id             => p_party_id
  , p_customer_id           => p_customer_id
  , p_site_id               => p_site_id
  , p_limit_curr_code       => p_limit_curr_code
  , p_credit_check_rule_id  => p_credit_check_rule_id
  , p_need_exposure_details => 'Y'
  , x_total_exposure        => x_total_exposure
  , x_order_hold_amount     => x_order_hold_amount
  , x_order_amount         => x_order_amount
  , x_ar_amount            => x_ar_amount
  , x_external_amount      => x_external_amount
  , x_return_status        => x_return_status
  );

 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.ADD(' x_return_status => '||
           x_return_status );
   OE_DEBUG_PUB.ADD(' x_external_amount => '||
          x_external_amount );
   OE_DEBUG_PUB.ADD(' x_ar_amount => '||
         x_ar_amount );
   OE_DEBUG_PUB.ADD(' x_order_amount => '||
           x_order_amount );
   OE_DEBUG_PUB.ADD (' x_order_hold_amount => '||
     x_order_hold_amount );
  OE_DEBUG_PUB.ADD (' x_total_exposure => '||
        x_total_exposure );
   OE_DEBUG_PUB.ADD( 'OUT OEXPCRXB: Get_Customer_Exposure ');
 END IF;

END Get_customer_exposure ;

END OE_Credit_Exposure_PUB ;

/
