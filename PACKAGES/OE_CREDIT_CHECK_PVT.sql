--------------------------------------------------------
--  DDL for Package OE_CREDIT_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_CHECK_PVT" AUTHID CURRENT_USER AS
-- $Header: OEXVCRCS.pls 120.0 2005/06/01 01:52:17 appldev noship $

--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------

-------------------
-- PUBLIC VARIABLES
-------------------

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

------------------------------------------------------------------------------
--  PROCEDURE  : Get_Limit_Info        PUBLIC
--  COMMENT    : Returns the credit limit info of a customer or a site
--  PARAMETER LIST :
--     IN
--      p_header_id
--      p_entity_type
--      p_entity_id
--      p_trx_curr_code
--      p_include_all_flag
--      p_suppress_unused_usages_flag
--
--     OUT
--
--      x_limit_curr_code
--      x_trx_limit
--      x_overall_limit
--      x_default_limit_flag
--      x_credit_check_flag
--      x_include all flag
--      x_item_limits_tbl
--      x_usage_curr_tbl


--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------
PROCEDURE get_limit_info (
   p_header_id                   IN NUMBER
 , p_entity_type                 IN  VARCHAR2
 , p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN
                           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , p_suppress_unused_usages_flag IN  VARCHAR2 DEFAULT 'Y'
, x_limit_curr_code OUT NOCOPY

                           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
, x_trx_limit OUT NOCOPY NUMBER

, x_overall_limit OUT NOCOPY NUMBER

, x_credit_check_flag OUT NOCOPY VARCHAR2

, x_include_all_flag OUT NOCOPY VARCHAR2

, x_usage_curr_tbl OUT NOCOPY

                   OE_CREDIT_CHECK_GLOBALS.usage_curr_tbl_type
, x_default_limit_flag OUT NOCOPY VARCHAR2

);



------------------------------------------------------------------------------
--  PROCEDURE  : Get_Usages     PUBLIC
--  COMMENT    : Returns the Usages
--
--  PARAMETER LIST :
--     IN
--      p_entity_type
--      p_entity_id
--      p_limit_curr_code
--      p_suppress_unused_usages_flag
--
--     OUT
--

--      x_include all flag
--      x_usage_curr_tbl


--     PRE-CONDITIONS  :  None
--     POST-CONDITIONS :  None
--     EXCEPTIONS      :  None
------------------------------------------------------------------------------
PROCEDURE Get_Usages (
  p_entity_type                 IN  VARCHAR2
, p_entity_id                   IN  NUMBER
, p_limit_curr_code             IN
                       HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
, p_suppress_unused_usages_flag IN  VARCHAR2 DEFAULT 'Y'
, p_default_limit_flag          IN  VARCHAR2 DEFAULT 'N'
, x_include_all_flag OUT NOCOPY VARCHAR2

, x_usage_curr_tbl OUT NOCOPY

                        OE_CREDIT_CHECK_GLOBALS.usage_curr_tbl_type
);


-----------------------------------------------------------------------------
--  PROCEDURE  : GET_Item_Limit           PUBLIC
--  COMMENT    : Returns the limit associated with the Items.
--
------------------------------------------------------------------------------
PROCEDURE GET_Item_Limit
( p_header_id                   IN NUMBER
, p_trx_curr_code               IN VARCHAR2
, p_site_use_id                 IN NUMBER
, x_item_limits_tbl OUT NOCOPY

                  OE_CREDIT_CHECK_GLOBALS.item_limits_tbl_type
, x_lines_tbl OUT NOCOPY OE_CREDIT_CHECK_GLOBALS.lines_Rec_tbl_type

);


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
, l_limit_curr_code OUT NOCOPY VARCHAR2

, l_default_limit_flag OUT NOCOPY VARCHAR2

, Curr_list OUT NOCOPY VARCHAR2

);



END OE_Credit_Check_PVT;

 

/
