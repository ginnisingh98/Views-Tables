--------------------------------------------------------
--  DDL for Package OE_CREDIT_CHECK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_CHECK_UTIL" AUTHID CURRENT_USER AS
-- $Header: OEXUCRCS.pls 120.3.12010000.4 2012/01/01 18:28:53 slagiset ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXUCRCS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Package Spec of OE_CREDIT_CHECK_UTIL                              |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Get_Credit_Check_Rule_ID                                          |
--|     Get_Credit_Check_Rule                                             |
--|     Get_Order_Exposure                                                |
--|     Get_Limit_Info                                                    |
--|     Get_System_Parameters                                             |
--|     Get_External_Trx_Amount                                           |
--|                                                                       |
--| HISTORY                                                               |
--|    Oct-30-2001 Global for curent order exposure                       |
--|    Feb-04-2002 Multi org                                              |
--|    Feb-13-2002 Check External Credit API changes                      |
--|    FEB-21-2001 added days_honor_manual release to                     |
--|                 OE_credit_rules_rec_type                              |
--|    Mar-15-2002 Modified to support external exposure                  |
--|    May-23-2002 rajkrish Bug2388454                                    |
--|    Nov-04-2002                                                        |
--|    Mar-30-2003 vto      Bug 2846473.2878410. Added parameters to      |
--|                          Send_Credit_Hold_NTF procedure               |
--|    Jul-18-2003 tsimmond added include_returns_flag to the credit check|
--|                         rule type                                     |
--|    Jan-09-2004 vto      3364726/3327637:Set G_crmgmt_installed to NULL|
--|=======================================================================+

--------------------------------
--- Globals
-------------------------------
g_current_order_value NUMBER ;
G_excl_curr_list      VARCHAR2(2000);
G_hierarchy_type      VARCHAR2(100) :=
  FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE');
G_crmgmt_installed    BOOLEAN;
G_org_id              NUMBER ;  /* MOAC CREDIT CHECK CHANGE */
  --ER 12363706 start
TYPE G_CC_Invoice_Rec
IS
  RECORD
  (
    new_invoice_to_org_id NUMBER,
    old_invoice_to_org_id NUMBER,
    line_id               NUMBER);
TYPE G_CC_Invoice_tab_typ
IS
  TABLE OF G_CC_Invoice_Rec INDEX BY BINARY_INTEGER;
  G_CC_Invoice_tab G_CC_Invoice_tab_typ;
  --ER 12363706 end
---------------------------
--- Type Declaration
----------------------------


TYPE lines_Rectype IS RECORD
( grouping_id        NUMBER
, item_category_id   NUMBER
, line_id            OE_ORDER_LINES_ALL.line_id%TYPE
, ordered_quantity   NUMBER
, tax_value          NUMBER
, unit_selling_price NUMBER
);


TYPE lines_Rec_tbl_type IS TABLE OF lines_Rectype
     INDEX BY BINARY_INTEGER;


TYPE Items_Limit_Rec IS RECORD
( grouping_id      NUMBER
, item_category_id HZ_CREDIT_PROFILES.item_category_id%type
, limit_curr_code  HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
, item_limit       HZ_CREDIT_PROFILE_AMTS.trx_credit_limit%TYPE
, ctg_line_amount  NUMBER
);


TYPE ITEM_LIMITS_TBL_TYPE IS TABLE OF Items_Limit_Rec
     INDEX BY BINARY_INTEGER;


TYPE Usage_Curr_Rec IS RECORD
( usage_curr_code  HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE );


TYPE CURR_TBL_TYPE IS TABLE OF Usage_Curr_Rec
     INDEX BY BINARY_INTEGER;

-- Start Sys Parama Change
/*
TYPE OE_systems_param_rec_type IS RECORD
( org_id          oe_system_parameters_ALL.org_id%TYPE
, master_organization_id
            oe_system_parameters_ALL.master_organization_id%TYPE
, customer_relationships_flag
            oe_system_parameters_ALL.customer_relationships_flag%TYPE
);
*/
TYPE OE_systems_param_rec_type IS RECORD
( org_id                      NUMBER
, master_organization_id      NUMBER
, customer_relationships_flag VARCHAR2(240)
);

-- End Sys Param Change

TYPE OE_credit_rules_rec_type IS RECORD
( credit_check_rule_id
       OE_Credit_Check_Rules.credit_check_rule_id%TYPE
, name OE_Credit_Check_Rules.name%TYPE
, failure_result_code
       OE_Credit_Check_Rules.failure_result_code%TYPE
, open_ar_balance_flag
       OE_Credit_Check_Rules.open_ar_balance_flag%TYPE
, uninvoiced_orders_flag
       OE_Credit_Check_Rules.uninvoiced_orders_flag%TYPE
, orders_on_hold_flag
       OE_Credit_Check_Rules.orders_on_hold_flag%TYPE
, shipping_interval
       OE_Credit_Check_Rules.shipping_interval%TYPE
, open_ar_days
       OE_Credit_Check_Rules.open_ar_days%TYPE
, start_date_active
       OE_Credit_Check_Rules.start_date_active%TYPE
, end_date_active
       OE_Credit_Check_Rules.end_date_active%TYPE
, include_payments_at_risk_flag
       OE_Credit_Check_Rules.include_payments_at_risk_flag%TYPE
, include_tax_flag
       OE_Credit_Check_Rules.include_tax_flag%TYPE
, maximum_days_past_due
       OE_Credit_Check_Rules.maximum_days_past_due%TYPE
, quick_cr_check_flag
       OE_Credit_Check_Rules.QUICK_CR_CHECK_FLAG%TYPE
, incl_freight_charges_flag
       OE_Credit_Check_Rules.incl_freight_charges_flag%TYPE
, shipping_horizon DATE
, credit_check_level_code
                OE_Credit_Check_Rules.credit_check_level_code%TYPE
, credit_hold_level_code
                OE_Credit_Check_Rules.credit_hold_level_code%TYPE
, conversion_type
                OE_Credit_Check_Rules.conversion_type%TYPE
, user_conversion_type
               GL_DAILY_CONVERSION_TYPES.user_conversion_type%TYPE
, check_item_categories_flag
               OE_Credit_Check_Rules.check_item_categories_flag%TYPE
, send_hold_notifications_flag
              OE_Credit_Check_Rules.send_hold_notifications_flag%TYPE
, days_honor_manual_release
            OE_Credit_Check_Rules.days_honor_manual_release%TYPE
, include_external_exposure_flag
            OE_Credit_Check_Rules.include_external_exposure_flag%TYPE
, include_returns_flag
            OE_Credit_Check_Rules.include_returns_flag%TYPE
    --ER 12363706 start
, tolerance_percentage
	    OE_Credit_Check_Rules.Tolerance_Percentage%TYPE
, tolerance_curr_code
            OE_Credit_Check_Rules.Tolerance_Curr_Code%TYPE
, tolerance_amount
   	    OE_Credit_Check_Rules.Tolerance_Amount%TYPE
    --ER 12363706 end
  );
FUNCTION check_debug_flag
RETURN VARCHAR2 ;

PROCEDURE get_limit_info (
   p_header_id                   IN NUMBER := NULL
 , p_entity_type                 IN  VARCHAR2
 , p_entity_id                   IN  NUMBER
 , p_cust_account_id             IN  NUMBER
 , p_party_id                    IN  NUMBER
 , p_trx_curr_code               IN
                           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , p_suppress_unused_usages_flag IN  VARCHAR2 := 'N'
 , p_navigate_to_next_level      IN  VARCHAR2 := 'Y'
 , p_precalc_exposure_used       IN  VARCHAR2 := 'N'
 , x_limit_curr_code             OUT NOCOPY
                           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_trx_limit                   OUT NOCOPY NUMBER
 , x_overall_limit               OUT NOCOPY NUMBER
 , x_include_all_flag            OUT NOCOPY VARCHAR2
 , x_usage_curr_tbl              OUT NOCOPY
                   OE_CREDIT_CHECK_UTIL.curr_tbl_type
 , x_default_limit_flag          OUT NOCOPY VARCHAR2
 , x_global_exposure_flag        OUT NOCOPY VARCHAR2
 , x_credit_limit_entity_id      OUT NOCOPY NUMBER
 , x_credit_check_level          OUT NOCOPY VARCHAR2
)
;



------------------------------------------------------------------------------
--  PROCEDURE  : Get_Usages     PUBLIC
--  COMMENT    : Returns the MCC Usages associated with a profile
--
------------------------------------------------------------------------------
PROCEDURE Get_Usages (
  p_entity_type                 IN  VARCHAR2
, p_entity_id                   IN  NUMBER
, p_limit_curr_code             IN
                       HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
, p_suppress_unused_usages_flag IN  VARCHAR2 := 'N'
, p_default_limit_flag          IN  VARCHAR2 := 'N'
, p_global_exposure_flag        IN  VARCHAR2 := 'N'
, x_include_all_flag            OUT NOCOPY VARCHAR2
, x_usage_curr_tbl              OUT NOCOPY
                        OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE
);


-----------------------------------------------------------------------------
--  PROCEDURE  : GET_Item_Limit           PUBLIC
--  COMMENT    : Returns the limit associated with the Item categories.
--
------------------------------------------------------------------------------
PROCEDURE GET_Item_Limit
( p_header_id                   IN NUMBER
, p_trx_curr_code               IN VARCHAR2
, p_site_use_id                 IN NUMBER
, p_include_tax_flag            IN VARCHAR2
, x_item_limits_tbl            OUT NOCOPY
                  OE_CREDIT_CHECK_UTIL.item_limits_tbl_type
, x_lines_tbl                  OUT NOCOPY
                  OE_CREDIT_CHECK_UTIL.lines_Rec_tbl_type
);

-----------------------------------------------------------------------------
--  PROCEDURE: GET_System_parameters           PUBLIC
--  COMMENT    : Returns the OE system parameter info for the current org
--
------------------------------------------------------------------------------
PROCEDURE GET_System_parameters
( x_system_parameter_rec OUT NOCOPY
             OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
);



-----------------------------------------------------------------------------
--  PROCEDURE: GET_credit_check_rules           PUBLIC
--  COMMENT    : Returns the OE credit check rules info for the current org
--
------------------------------------------------------------------------------
PROCEDURE GET_credit_check_rule
( p_header_id              IN NUMBER := NULL
, p_credit_check_rule_id   IN NUMBER
, x_credit_check_rules_rec OUT NOCOPY
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
);

-----------------------------------------------------------------------------
--  PROCEDURE  : Rounded_Amount    PUBLIC
--  COMMENT    : Returns the rounded amount
--  FPBUG  4320650
---------------------------------------------------------------------------

PROCEDURE Rounded_Amount
(  p_currency_code      IN   VARCHAR2
,  p_unrounded_amount   IN   NUMBER
,  x_rounded_amount     OUT NOCOPY NUMBER
);

-----------------------------------------------------------------------------
--  PROCEDURE: GET_transaction_amount           PUBLIC
--  COMMENT    : Returns the transaction amount for a given order. If the
--               p_site_use_id IS null, the entire order is considered
--               x_conversion_status proviees any currency conversion
--               error.
------------------------------------------------------------------------------
PROCEDURE GET_transaction_amount
( p_header_id             IN  NUMBER
, p_transaction_curr_code IN  VARCHAR2
, p_credit_check_rule_rec IN
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
, p_system_parameter_rec  IN
             OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
, p_customer_id           IN  NUMBER
, p_site_use_id           IN  NUMBER
, p_limit_curr_code       IN  VARCHAR2
, p_all_lines             IN VARCHAR2 := 'N' --ER 12363706

, x_amount                OUT NOCOPY NUMBER
, x_conversion_status     OUT NOCOPY OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE
, x_return_status         OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Get_Past_Due_Invoice
-- Comments  : Returns Yes, if Invoices with past due date exist
--========================================================================
PROCEDURE Get_Past_Due_Invoice
( p_customer_id        IN   NUMBER
, p_site_use_id        IN   NUMBER
, p_party_id           IN   NUMBER
, p_credit_check_rule_rec IN
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
, p_system_parameter_rec   IN
             OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
, p_credit_level       IN   VARCHAR2
, p_usage_curr         IN   oe_credit_check_util.curr_tbl_type
, p_include_all_flag   IN   VARCHAR2
, p_global_exposure_flag IN VARCHAR2 := 'N'
, x_exist_flag         OUT  NOCOPY VARCHAR2
, x_return_status      OUT  NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Get_order_exposure
-- Comments  : Retrun the overall exposure ,
--             by calculating directly from the
--             transaction tables
--========================================================================
PROCEDURE Get_order_exposure
( p_header_id              IN  NUMBER
, p_transaction_curr_code  IN  VARCHAR2
, p_customer_id            IN  NUMBER
, p_site_use_id            IN  NUMBER
, p_credit_check_rule_rec IN
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
, p_system_parameter_rec   IN
             OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
, p_credit_level           IN  VARCHAR2
, p_limit_curr_code        IN  VARCHAR2
, p_usage_curr             IN  oe_credit_check_util.curr_tbl_type
, p_include_all_flag       IN  VARCHAR2
, p_global_exposure_flag   IN  VARCHAR2 := 'N'
, p_need_exposure_details  IN  VARCHAR2 := 'N'
, x_total_exposure         OUT NOCOPY NUMBER
, x_ar_amount              OUT NOCOPY NUMBER
, x_order_amount           OUT NOCOPY NUMBER
, x_order_hold_amount      OUT NOCOPY NUMBER
, x_conversion_status      OUT NOCOPY CURR_TBL_TYPE
, x_return_status          OUT NOCOPY VARCHAR2
)
;


--========================================================================
-- PROCEDURE : Currency_List
-- Comments  : This procedure is used by the credit snapshot report to derive
--             a comma delimited string of currencies defined in credit usage
-- Parameters: c_entity_type       IN    'CUSTOMER' or 'SITE'
--			c_entity_id         IN    Customer_Id or Site_Id
--             c_trx_curr_code     IN    Transaction Currency
--             l_limit_curr_code   OUT   Currency Limit used for credit checking
--             Curr_list           OUT   Comma delimited string of currencies
--                                       covered by limit currency code
--========================================================================
PROCEDURE Currency_List(
   c_entity_type          IN  VARCHAR2
 , c_entity_id            IN  NUMBER
 , c_trx_curr_code        IN  VARCHAR2
 , l_limit_curr_code      OUT NOCOPY VARCHAR2
 , l_default_limit_flag   OUT NOCOPY VARCHAR2
 , Curr_list              OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : CONVERT_CURRENCY_AMOUNT
-- Comments  : Returns the converted amount in the limit curr
--             The conversion will also attempt to triangulate if
--             no exchange rate is found between transactional curr
--             and limit currency
--========================================================================
FUNCTION CONVERT_CURRENCY_AMOUNT
( p_amount	                IN NUMBER := 0
, p_transactional_currency 	IN VARCHAR2
, p_limit_currency	        IN VARCHAR2
, p_functional_currency	        IN VARCHAR2
, p_conversion_date	        IN DATE     := SYSDATE
, p_conversion_type	        IN VARCHAR2 := 'Corporate'
) RETURN NUMBER ;

--========================================================================
-- PROCEDURE : SEND_CREDIT_HOLD_NTF
-- Comments  : Set message attributes and send workflow notification
--             on all the credit holds for the order.
--========================================================================
PROCEDURE Send_Credit_Hold_NTF
( p_header_rec        IN  oe_order_pub.header_rec_type
, p_credit_hold_level IN  OE_CREDIT_CHECK_RULES.credit_hold_level_code%TYPE
, p_cc_hold_comment   IN  OE_HOLD_SOURCES.hold_comment%TYPE
, x_return_status     OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------------
--  PROCEDURE: GET_credit_check_level
--  COMMENT    : Returns ORDER or LINE
--  BUG 2114156
------------------------------------------------------------------------------
FUNCTION GET_credit_check_level
( p_calling_action     IN VARCHAR2
, p_order_type_id      IN NUMBER
) RETURN VARCHAR2 ;

---------------------------------------------------------------------------
--PROCEDURE: Get_Credit_Check_Rule_ID
--COMMENT:   Returns the credit check rule id attached with
--          the order trn type
---------------------------------------------------------------------------
PROCEDURE Get_Credit_Check_Rule_ID
( p_calling_action      IN VARCHAR2
, p_order_type_id       IN OE_ORDER_HEADERS.order_type_id%TYPE
, x_credit_rule_id      OUT NOCOPY
                           OE_Credit_check_rules.credit_check_rule_id%TYPE
);




---------------------------------------------------------------------------
--FUNCTION GET_GL_currency
--COMMENT:   Returns the SOB currency

---------------------------------------------------------------------------
FUNCTION GET_GL_currency
RETURN VARCHAR2 ;

---------------------------------------------------------------------------
--FUNCTION: Get_global_exposure_flag
--COMMENTS: Returns the global exposure flag for a given
--          entity ID and limit currency
--          used by the credit exposure report
--          Multi org enhancement
--          Entity type is accepted but not used for validation
---------------------------------------------------------------i-----------
FUNCTION Get_global_exposure_flag
(  p_entity_type                 IN VARCHAR2
 , p_entity_id                   IN  NUMBER
 , p_limit_curr_code             IN  VARCHAR2
) RETURN VARCHAR2;

----------------------------------------------------------------------------
--  PROCEDURE: GET_external_trx_amount           PUBLIC
--  COMMENT  : Returns the transaction amount in the limit currency given the
--             amount in the transaction currency. If the
--             p_site_use_id IS null, the entire order is considered
--             x_conversion_status provides any currency conversion
--             error.
----------------------------------------------------------------------------
PROCEDURE GET_external_trx_amount
( p_transaction_curr_code IN  VARCHAR2
, p_transaction_amount    IN  NUMBER
, p_credit_check_rule_rec IN
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
, p_system_parameter_rec  IN
             OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
, p_limit_curr_code       IN  VARCHAR2
, x_amount                OUT NOCOPY NUMBER
, x_conversion_status     OUT NOCOPY OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE
, x_return_status         OUT NOCOPY VARCHAR2
);

FUNCTION Check_drawee_exists
( p_cust_account_id IN NUMBER )
RETURN VARCHAR2 ;

FUNCTION get_drawee_site_use_id
( p_site_use_id         IN NUMBER
) RETURN NUMBER ;

FUNCTION Get_CC_Lookup_Meaning
        (p_lookup_type  IN VARCHAR2,
         p_lookup_code  IN VARCHAR2
        )
RETURN VARCHAR2;

  --ER 12363706 start
PROCEDURE Update_Released_Amount(
    p_header_id       NUMBER,
    p_hold_release_id NUMBER);
PROCEDURE Update_Credit_Profile_Level(
    p_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type);
  --ER 12363706 end

END OE_CREDIT_CHECK_UTIL;

/
