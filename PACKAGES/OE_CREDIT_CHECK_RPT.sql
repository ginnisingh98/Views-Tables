--------------------------------------------------------
--  DDL for Package OE_CREDIT_CHECK_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_CHECK_RPT" AUTHID CURRENT_USER AS
-- $Header: OEXRCRCS.pls 115.7 2003/10/30 21:37:19 vto noship $
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

--=====================================================================
--PROCEDURE:    Credit_Check_Processor                        PUBLIC
--
--COMMENTS:     This is the server pl/sql procedure that perform credit
--              checking for a batch of sales orders.  It is called by
--              the Credit Check Processor report.
--=====================================================================

PROCEDURE Credit_Check_Processor
  ( p_profile_org_id             IN NUMBER	DEFAULT NULL
  , p_cust_prof_class_name_from  IN VARCHAR2	DEFAULT NULL
  , p_cust_prof_class_name_to    IN VARCHAR2	DEFAULT NULL
  , p_party_name_from            IN VARCHAR2	DEFAULT NULL
  , p_party_name_to              IN VARCHAR2	DEFAULT NULL
  , p_cust_acct_number_from      IN VARCHAR2	DEFAULT NULL
  , p_cust_acct_number_to        IN VARCHAR2	DEFAULT NULL
  , p_order_date_from            IN DATE	DEFAULT NULL
  , p_order_date_to              IN DATE	DEFAULT NULL
  , p_header_id                  IN NUMBER	DEFAULT NULL
  , p_order_by                   IN VARCHAR2
  );

--========================================================================
-- PROCEDURE : Get_unchecked_exposure PUBLIC
-- PARAMETERS: p_party_id
--             p_customer_id          customer ID
--             p_site_id              bill-to site id
--             p_base_currency        currency of the current operating unit
--             p_usage_curr_tbl       table of all unchecked currencies
--             x_unchecked_expousre   unchecked exposure
--
-- COMMENT   : This procedure calculates unchecked exposure in the
--             base currency for any given customer.
--
--=====================================================================
PROCEDURE Get_unchecked_exposure
( p_party_id             IN NUMBER DEFAULT NULL
, p_customer_id          IN NUMBER
, p_site_id              IN NUMBER
, p_base_currency        IN VARCHAR2
, p_credit_check_rule_id IN NUMBER
, x_unchecked_expousre   OUT NOCOPY NUMBER
, x_return_status        OUT NOCOPY VARCHAR2
);


--========================================================================
-- PROCEDURE : Credit_exposure_report_utils     PUBLIC
-- PARAMETERS: p_report_by_option
--             p_specific_party_id
--             p_specific_party_num
--             p_party_name_low
--             p_party_name_high
--             p_party_number_low
--             p_party_number_high
--             p_prof_class_low       customer profile class name from
--             p_prof_class_high      customer profile class name to
--             p_customer_name_low    customer name from
--             p_customer_name_high   customer name to
--             p_cust_number_low      customer number from
--             p_cust_number_high     customer number to
--             p_cr_check_rule_id     credit check rule
--             p_report_type          report type ('S' for Summary, 'D' for Detail)
--             p_org_id
--
-- COMMENT   : This is the main procedure for Credit Exposure Report. It calculates
--             exposure and populates temp table OE_CREDIT_EXPOSURE_TMP
--
--=======================================================================--
PROCEDURE Credit_exposure_report_utils
( p_report_by_option   IN VARCHAR2 DEFAULT NULL
, p_specific_party_id  IN NUMBER DEFAULT NULL
, p_spec_party_num_id  IN NUMBER DEFAULT NULL
, p_party_name_low     IN VARCHAR2 DEFAULT NULL
, p_party_name_high    IN VARCHAR2 DEFAULT NULL
, p_party_number_low   IN VARCHAR2 DEFAULT NULL
, p_party_number_high  IN VARCHAR2 DEFAULT NULL
, p_prof_class_low     IN VARCHAR2 DEFAULT NULL
, p_prof_class_high    IN VARCHAR2 DEFAULT NULL
, p_customer_name_low  IN VARCHAR2 DEFAULT NULL
, p_customer_name_high IN VARCHAR2 DEFAULT NULL
, p_cust_number_low    IN VARCHAR2 DEFAULT NULL
, p_cust_number_high   IN VARCHAR2 DEFAULT NULL
, p_cr_check_rule_id   IN NUMBER
, p_org_id             IN NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
);

END OE_CREDIT_CHECK_RPT;

 

/
