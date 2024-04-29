--------------------------------------------------------
--  DDL for Package OE_CREDIT_ENGINE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_ENGINE_GRP" AUTHID CURRENT_USER AS
-- $Header: OEXPCRGS.pls 120.1.12010000.5 2012/01/04 06:45:36 slagiset ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     OEXPCRGS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    OE credit check program                                            |
--|                                                                       |
--|    supports the main credit check engine in retrieving credit data    |
--|    customer or a site (includes multi-currency enhancements)          |
--|                                                                       |
--| HISTORY                                                               |
--| 31-JUL-2001 rajkrish 2PM Global for currency error message            |
--| 12-AUG-2001 tsimmond added procedure Get_Customer_exposure            |
--|                      and two global variables                         |
--|                      G_cust_curr_tbl and G_site_curr_tbl              |
--| 26-SEP-2001 rajkrish Ingersol BUG                                     |
--| 05-FEB-2002          multi org  OEXPCRGS.pls 115.7 2001/09/27 22:56:38|
--| 13-FEB-2002 vto      Modified for legacy support.                     |
--| 11-JUN-2002 rajkrish 2412678S                                         |
--| 05-NOV-2002 rajkrish                                                  |
--| 01-APR-2003 vto      2885044,2853800.Add globals for activity cc holds|
--|                        G_cc_hold_activity_name                        |
--|                        G_cc_hold_item_type                            |
--+=======================================================================+

--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------

-------------------
-- PUBLIC VARIABLES
-------------------
G_cust_curr_tbl  OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;
G_site_curr_tbl  OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;
G_cust_incl_all_flag  VARCHAR2(15);
G_site_incl_all_flag  VARCHAR2(15);
GL_CURRENCY VARCHAR2(10);
G_currency_error_msg VARCHAR2(3000);
-- Ingersol BUG
G_delayed_request    VARCHAR2(30);

-- Use to store activity specific hold information
G_cc_hold_item_type     OE_HOLD_DEFINITIONS.item_type%TYPE;
G_cc_hold_activity_name OE_HOLD_DEFINITIONS.activity_name%TYPE;
  TOLERANCE_CHECK_REQUIRED BOOLEAN      := TRUE; --ER 12363706
  G_Credit_Profile_Level   VARCHAR2(30) := NULL;  --ER 12363706
---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------
---------------------------------------------------------------------------
--PROCEDURE: Credit_check_with_payment_typ
--COMMENT:    Main API that is interfaced to the existing
--            verify_payment package for code switch

-- 2412678 add a new input parameter for credit check rule
---------------------------------------------------------------------------
PROCEDURE Credit_check_with_payment_typ
(  p_header_id            IN   NUMBER
,  p_calling_action       IN   VARCHAR2
,  p_delayed_request      IN   VARCHAR2
,  p_credit_check_rule_id IN   NUMBER := NULL
,  x_msg_count            OUT NOCOPY /* file.sql.39 change */  NUMBER
,  x_msg_data             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,  x_return_status        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


--------------------------------------------------------------------------
--PROCEDURE: Check_Credit
--COMMENT:     Multi currency credit checking API for not electronic
--MODIFICATION:
-- 02/15/2002 Removed Default NULL for p_calling_action
---------------------------------------------------------------------------
PROCEDURE Check_Credit
(   p_header_id                 IN      NUMBER
,   p_calling_action            IN      VARCHAR2
,   p_delayed_request           IN      VARCHAR2 := NULL
,   p_bill_to_site_use_id       IN      NUMBER   := NULL
,   p_credit_check_rule_id      IN      NUMBER 	 := NULL
,   p_functional_currency_code  IN      VARCHAR2 := NULL
,   p_transaction_currency_code IN      VARCHAR2 := NULL
,   p_transaction_amount        IN      NUMBER   := NULL
,   p_org_id                    IN      NUMBER   := NULL
,   x_cc_hold_comment           OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,   x_msg_count                 OUT NOCOPY /* file.sql.39 change */     NUMBER
,   x_msg_data                  OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,   x_result_out                OUT NOCOPY /* file.sql.39 change */     VARCHAR2
,   x_return_status             OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

--=========================================================================
-- PROCEDURE  : Get_customer_exposure   PUBLIC
-- PARAMETERS : p_customer_id           Customer ID
--            : p_site_id               Bill-to Site ID
--            : p_limit_curr_code       Credit limit currency code
--            : p_credit_check_rule_id  Credit Check Rule Id
--            : x_total_exposure        Credit exposure
--            : x_return_status         Status
-- COMMENT    : This procedure calculates credit exposure for given customer
--
--=========================================================================
PROCEDURE Get_customer_exposure
( p_customer_id           IN NUMBER
, p_site_id               IN NUMBER
, p_limit_curr_code       IN VARCHAR2
, p_credit_check_rule_id  IN NUMBER
, x_total_exposure    OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_return_status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);


------------------------------------------------------
-- This procedure will be the main procedure  from ONT-I
-- For backward compatibile Issues, the proginal get_customer_exposure
-- will call this procedure - overloading
----------------------------------------------------
PROCEDURE Get_customer_exposure
( p_party_id              IN NUMBER
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
);

/* Start MOAC CREDIT CHECK CHANGE */
--=========================================================================
-- PROCEDURE  : Set_Context           PRIVATE
-- COMMENT    : This procedure set the context
--
--=========================================================================
PROCEDURE Set_Context;
/* End MOAC CREDIT CHECK CHANGE */
  --ER 12363706 start
  FUNCTION Is_Tolerance_Enabled(
      p_header_id IN NUMBER,
      p_credit_check_rule_rec OUT NOCOPY OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type )
    RETURN BOOLEAN;
  FUNCTION Credit_Tolerance_Check(
      p_header_id IN NUMBER )
    RETURN BOOLEAN;
    --ER 12363706 end
END OE_Credit_Engine_GRP ;

/
