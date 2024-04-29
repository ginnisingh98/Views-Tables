--------------------------------------------------------
--  DDL for Package OE_CREDIT_CHECK_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_CHECK_LINES_PVT" AUTHID CURRENT_USER AS
-- $Header: OEXVCRLS.pls 120.2.12010000.1 2008/07/25 07:59:18 appldev ship $
--+=======================================================================+
--|               Copyright (c) 2001 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--|                                                                       |
--|  FILENAME      OEXVCRLS.pls                                           |
--|  DESCRIPTION   Spec of package OE_Credit_check_lines_PVT              |
--|                Determines if an Order is Subject to Credit Check.     |
--|                                                                       |
--|  HISTORY                                                              |
--|    Mar-27-2002 dbdrv                                                  |
--|    Aug-23-2002 tsimmond added Release_Line_CC_Hold procedure          |
--|    Oct-XX-2002 rajkrish party                                         |
--|    Dec-06-2002 vto      Added NOCOPY to OUT variables                 |
--|    Mar-31-2003 vto      2878410.Added line count global               |
--|=======================================================================+

---------------------------------------------
----------- PL/SQL table record types
------------------------------------------
TYPE Line_Hold_Rectype IS RECORD
	( line_id      NUMBER
	, line_number  NUMBER
	, hold         VARCHAR2(30)
	, limit_used   VARCHAR2(80)
	, profile_used VARCHAR2(30)
	, customer_id  NUMBER
	, site_use_id  NUMBER
	, party_id     NUMBER
	, item_category_id NUMBER
        , line_total   NUMBER -- ER 6135714
	);

TYPE Line_Holds_Tbl_Rectype IS TABLE OF Line_Hold_Rectype
	INDEX BY BINARY_INTEGER;

--------------------------------------------
-- Global Variables
--------------------------------------------
G_line_hold_count NUMBER;

---------------------------------------------------------
-- Release credit check holds on order lines belonging to
-- a bill-to site
---------------------------------------------------------

PROCEDURE Release_Line_CC_Hold
( p_header_id            IN NUMBER
, p_order_number         IN NUMBER
, p_line_id              IN NUMBER
, p_line_number          IN NUMBER
, p_calling_action       IN VARCHAR2   DEFAULT NULL
, p_credit_hold_level    IN VARCHAR2
, x_cc_result_out        OUT NOCOPY VARCHAR2
);


  ------------------------------------------
  --  Mainline procedure that will read   --
  --  an Order Header and determine       --
  --  if should be checked, determines    --
  --  if order has passed or failed       --
  --  the credit check (no holds placed)  --
  ------------------------------------------

PROCEDURE Check_order_lines_credit
  ( p_header_rec            IN  OE_ORDER_PUB.Header_Rec_Type
  , p_calling_action        IN  VARCHAR2 DEFAULT 'BOOKING'
  , p_credit_check_rule_rec IN  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  , p_system_parameter_rec  IN  OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
  , x_msg_count             OUT NOCOPY NUMBER
  , x_msg_data              OUT NOCOPY VARCHAR2
  , x_cc_result_out         OUT NOCOPY VARCHAR2
  , x_cc_limit_used         OUT NOCOPY VARCHAR2
  , x_cc_profile_used       OUT NOCOPY VARCHAR2
  , x_return_status         OUT NOCOPY VARCHAR2
  ) ;

-------------------------------------------------
---- Check_Order_lines_exposure
-- Checks the overall credit exposure for order line level
-- bill to site.
-- Will select the overall exposure from the pre-calculated
-- exposure table
---------------------------------------------------

PROCEDURE Check_Order_lines_exposure
( p_customer_id	           IN	NUMBER
, p_site_use_id	           IN	NUMBER
, p_header_id	           IN	NUMBER
, p_credit_level	   IN	VARCHAR2
, p_limit_curr_code	   IN	VARCHAR2
, p_overall_credit_limit   IN	NUMBER
, p_calling_action	   IN	VARCHAR2
, p_usage_curr	           IN	OE_CREDIT_CHECK_UTIL.curr_tbl_type
, p_include_all_flag	   IN	VARCHAR2 DEFAULT 'N'
, p_holds_rel_flag	   IN	VARCHAR2 DEFAULT 'N'
, p_default_limit_flag	   IN	VARCHAR2 DEFAULT 'N'
, p_credit_check_rule_rec  IN OE_Credit_Check_Util.OE_credit_rules_rec_type
, p_system_parameter_rec   IN OE_Credit_Check_Util.OE_systems_param_rec_type
, p_global_exposure_flag   IN VARCHAR2 := 'N'
, p_party_id               IN NUMBER
, p_credit_limit_entity_id IN NUMBER
, x_total_exposure	  OUT	NOCOPY NUMBER
, x_cc_result_out 	  OUT 	NOCOPY VARCHAR2
, x_error_curr_tbl	  OUT	NOCOPY OE_CREDIT_CHECK_UTIL.curr_tbl_type
, x_return_status	  OUT	NOCOPY VARCHAR2
);




END OE_Credit_check_lines_PVT;

/
