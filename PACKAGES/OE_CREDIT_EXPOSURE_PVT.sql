--------------------------------------------------------
--  DDL for Package OE_CREDIT_EXPOSURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_EXPOSURE_PVT" AUTHID CURRENT_USER AS
-- $Header: OEXVCRXS.pls 120.1.12010000.1 2008/07/25 07:59:20 appldev ship $

--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXVCRXS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Spec. of OE_CREDIT_EXPOSURE_PVT                                    |
--|                                                                       |
--| HISTORY                                                               |
--|     06/05/2001 Rene Schaub     Created                                |
--|     01-29-2002 rajkrish        updated for Multi org project OM H     |
--|                                ontdev => 115.3 2001/08/25             |
--|     03/15/2002 vto             Added G_EXTERNAL_EXPOSURE balance type |
--|     06/18/2002 vto             renee logic init summary only          |
--|     oct-30 2002 updates                                               |
--|     12/06/2002 vto             Added NOCOPY to OUT variables          |
--|     07/02/2003 tsimmond        Added new balance type globals for the |
--|                                Returns project                        |
--+======================================================================*/

--===================
-- TYPES
--===================

TYPE Binary_rec_type IS RECORD
( bucket         NUMBER
, bucket_length  NUMBER
);

TYPE Binary_tbl_type IS TABLE OF Binary_rec_type
  INDEX BY BINARY_INTEGER;

--===================
-- CONSTANTS
--===================

G_HEADER_UNINVOICED_ORDERS        CONSTANT NUMBER := 1;
G_LINE_UNINVOICED_ORDERS          CONSTANT NUMBER := 2;
G_HEADER_UNINVOICED_ORDERS_TAX    CONSTANT NUMBER := 3;
G_LINE_UNINVOICED_ORDERS_TAX      CONSTANT NUMBER := 4;
G_HEADER_UNINVOICED_FREIGHT       CONSTANT NUMBER := 5;
G_LINE_UNINVOICED_FREIGHT         CONSTANT NUMBER := 6;
G_HEADER_AND_LINE_FREIGHT         CONSTANT NUMBER := 7;
G_INVOICES                        CONSTANT NUMBER := 8;
G_PAYMENTS_AT_RISK                CONSTANT NUMBER := 9;
G_ORDER_HOLDS                     CONSTANT NUMBER := 10;
G_LINE_HOLDS                      CONSTANT NUMBER := 11;
G_ORDER_TAX_HOLDS                 CONSTANT NUMBER := 13;
G_LINE_TAX_HOLDS                  CONSTANT NUMBER := 14;
G_ORDER_FREIGHT_HOLDS             CONSTANT NUMBER := 15;
G_LINE_FREIGHT_HOLDS              CONSTANT NUMBER := 16;
G_HEADER_LINE_FREIGHT_HOLDS       CONSTANT NUMBER := 17;
G_EXTERNAL_EXPOSURE               CONSTANT NUMBER := 18;
G_PAST_DUE_INVOICES               CONSTANT NUMBER := 20;
G_BR_INVOICES                     CONSTANT NUMBER := 21;
G_BR_PAYMENTS_AT_RISK             CONSTANT NUMBER := 22;

-------added for the Returns project (FPJ)
G_HEAD_RETURN_UNINV_ORDERS        CONSTANT NUMBER := 23;
G_LINE_RETURN_UNINV_ORDERS        CONSTANT NUMBER := 24;
G_HEAD_RETURN_UNINV_ORD_TAX       CONSTANT NUMBER := 25;
G_LINE_RETURN_UNINV_ORD_TAX       CONSTANT NUMBER := 26;
G_HEAD_RETURN_UNINV_FREIGHT       CONSTANT NUMBER := 27;
G_LINE_RETURN_UNINV_FREIGHT       CONSTANT NUMBER := 28;
G_HEAD_LINE_RETURN_FREIGHT        CONSTANT NUMBER := 29;
G_ORDER_RETURN_HOLDS              CONSTANT NUMBER := 30;
G_LINE_RETURN_HOLDS               CONSTANT NUMBER := 31;
G_ORDER_RETURN_TAX_HOLDS          CONSTANT NUMBER := 32;
G_LINE_RETURN_TAX_HOLDS           CONSTANT NUMBER := 33;
G_ORDER_RETURN_FREIGHT_HOLDS      CONSTANT NUMBER := 34;
G_LINE_RETURN_FREIGHT_HOLDS       CONSTANT NUMBER := 35;
G_H_L_RETURN_FREIGHT_HOLDS        CONSTANT NUMBER := 36;

--===================
-- GLOBAL VARIABLES
--===================

G_MAX_BUCKET_LEVEL                         NUMBER := 8;
G_MAX_BUCKET_LENGTH                        NUMBER := 256; -- 2^8
G_COMPLETE                                 BOOLEAN := TRUE;


--========================================================================
-- PROCEDURE : Init_Summary_Table     PUBLIC
-- PARAMETERS: x_retcode              0 success, 1 warning, 2 error
--             x_errbuf               error buffer
--             p_lock_tables          'Y' or 'N' for all transaction tables
---
-- COMMENT   : This is the concurrent program specification for
--             Initialize Credit Summaries Table
--             which will repopulate oe_credit_summaries table with summarized
--             credit exposure information.
--             The p_lock_tables flag specifies if
--             the oe_order_lines_all, oe_order_headers_all,
--             oe_cash_adjustments, ar_payment_schedules_all,
--            ar_cash_receipts_all tables should all be locked in exclusive mode
--             until all of the summary data is obtained.
--             If the flag is not set to 'Y', none of the tables is locked.
--=======================================================================--


PROCEDURE  Init_Summary_Table
( x_retcode        OUT NOCOPY VARCHAR2
, x_errbuf         OUT NOCOPY VARCHAR2
, p_lock_tables    IN  VARCHAR2  DEFAULT  'N'
);


--========================================================================
-- PROCEDURE : Get_Exposure            PUBLIC
-- PARAMETERS: x_retcode               0 success, 1 warning, 2 error
--             x_errbuf                error buffer
--             p_customer_id           not null
--             p_site_use_id           can be null
--             p_header_id             order header
--             p_credit_check_rule_rec
--             p_system_parameters_rec
--             p_limit_curr_code       currency in which to show the exposure
--             p_usage_curr_tbl    only include transactions in these currencies
--             p_include_all_flag      include transactions in any currency
--             x_total_exposure
--             x_return_status
--             x_error_curr_tbl        contains currencies with no rates

---
-- COMMENT   : This returns the total exposure for a customer or customer site
--             using precalculated data.
--=======================================================================--
PROCEDURE  Get_Exposure
( p_customer_id             IN    NUMBER
, p_site_use_id             IN    NUMBER
, p_party_id                IN    NUMBER := NULL
, p_header_id               IN    NUMBER
, p_credit_check_rule_rec IN
          OE_CREDIT_CHECK_UTIL.oe_credit_rules_rec_type
, p_system_parameters_rec IN
          OE_CREDIT_CHECK_UTIL.oe_systems_param_rec_type
, p_limit_curr_code         IN
           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
, p_usage_curr_tbl          IN  OE_CREDIT_CHECK_UTIL.curr_tbl_type
, p_include_all_flag        IN    VARCHAR2
, p_global_exposure_flag    IN    VARCHAR2 := 'N'
, p_need_exposure_details   IN    VARCHAR2 := 'N'
, x_total_exposure          OUT   NOCOPY NUMBER
, x_order_amount            OUT   NOCOPY NUMBER
, x_order_hold_amount       OUT   NOCOPY NUMBER
, x_ar_amount               OUT   NOCOPY NUMBER
, x_return_status           OUT   NOCOPY VARCHAR2
, x_error_curr_tbl          OUT   NOCOPY OE_CREDIT_CHECK_UTIL.curr_tbl_type
);



PROCEDURE get_invoices_over_duedate
( p_customer_id          IN   NUMBER
, p_site_use_id          IN   NUMBER
, p_party_id             IN   NUMBER
, p_credit_check_rule_rec IN
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
, p_credit_level         IN   VARCHAR2
, p_usage_curr           IN   oe_credit_check_util.curr_tbl_type
, p_include_all_flag     IN   VARCHAR2
, p_global_exposure_flag IN   VARCHAR2 := 'N'
, p_org_id               IN   NUMBER
, x_exist_flag           OUT  NOCOPY VARCHAR2
)
;



END OE_CREDIT_EXPOSURE_PVT;

/
