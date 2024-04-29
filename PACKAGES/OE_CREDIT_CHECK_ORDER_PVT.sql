--------------------------------------------------------
--  DDL for Package OE_CREDIT_CHECK_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_CHECK_ORDER_PVT" AUTHID CURRENT_USER AS
-- $Header: OEXVCRHS.pls 120.1.12010000.1 2008/07/25 07:59:16 appldev ship $

-----------------------------------------
-- Release order level credit check hold
-- in the database.
-----------------------------------------

PROCEDURE Release_Order_CC_Hold
(  p_header_id            IN  NUMBER
, p_order_number          IN  NUMBER
, p_calling_action        IN  VARCHAR2   DEFAULT 'BOOKING'
, P_SYSTEM_PARAMETER_REC  IN  OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
, x_cc_result_out         OUT NOCOPY VARCHAR2
);

  ------------------------------------------
  --  Mainline procedure that will read   --
  --  an Order Header and determine       --
  --  if should be checked, determines    --
  --  if order has passed or failed       --
  --  the credit check (no holds placed)  --
  ------------------------------------------

PROCEDURE Check_order_credit
  ( p_header_rec            IN  OE_ORDER_PUB.Header_Rec_Type
  , p_calling_action        IN  VARCHAR2 DEFAULT 'BOOKING'
  , p_credit_check_rule_rec IN  OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
  , p_system_parameter_rec  IN  OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
  , p_transaction_amount    IN  NUMBER   DEFAULT NULL
  , x_msg_count             OUT NOCOPY NUMBER
  , x_msg_data              OUT NOCOPY VARCHAR2
  , x_cc_result_out         OUT NOCOPY VARCHAR2
  , x_cc_hold_comment       OUT NOCOPY VARCHAR2
  , x_return_status         OUT NOCOPY VARCHAR2
  ) ;


-------------------------------------------------------
-- Checks the overall credit exposure for the
-- credit checking process
-- Will calculate exposure from the transaction tables
-- directly
-----------------------------------------------------------
/*
PROCEDURE Check_Order_exposure
( p_customer_id	          IN	NUMBER
, p_site_use_id	          IN	NUMBER
, p_header_id	          IN	NUMBER
, p_credit_level	  IN	VARCHAR2
, p_transaction_curr_code IN    VARCHAR2
, p_transaction_amount    IN    NUMBER DEFAULT 0
, p_limit_curr_code	  IN	VARCHAR2
, p_overall_credit_limit  IN	NUMBER
, p_calling_action	  IN	VARCHAR2
, p_usage_curr	          IN	OE_CREDIT_CHECK_UTIL.curr_tbl_type
, p_include_all_flag	  IN	VARCHAR2 DEFAULT 'N'
, p_holds_rel_flag	  IN	VARCHAR2 DEFAULT 'N'
, p_default_limit_flag	  IN	VARCHAR2 DEFAULT 'N'
, p_credit_check_rule_rec IN OE_Credit_Check_Util.OE_credit_rules_rec_type
, p_system_parameter_rec  IN OE_Credit_Check_Util.OE_systems_param_rec_type
, p_global_exposure_flag  IN   VARCHAR2 := 'N'
, x_total_exposure	  OUT	NOCOPY NUMBER
, x_cc_result_out 	  OUT 	NOCOPY VARCHAR2
, x_error_curr_tbl	  OUT	NOCOPY   OE_CREDIT_CHECK_UTIL.curr_tbl_type
, x_return_status	  OUT	NOCOPY VARCHAR2
);

*/

PROCEDURE Check_order_exposure
( p_customer_id           IN    NUMBER
, p_site_use_id           IN    NUMBER
, p_party_id              IN    NUMBER
, p_header_id             IN    NUMBER
, p_credit_level          IN    VARCHAR2
, p_transaction_curr_code IN    VARCHAR2
, p_transaction_amount    IN    NUMBER DEFAULT 0
, p_limit_curr_code       IN    VARCHAR2
, p_overall_credit_limit  IN    NUMBER
, p_calling_action        IN    VARCHAR2
, p_usage_curr            IN    OE_CREDIT_CHECK_UTIL.curr_tbl_type
, p_include_all_flag      IN    VARCHAR2 DEFAULT 'N'
, p_holds_rel_flag        IN    VARCHAR2 DEFAULT 'N'
, p_default_limit_flag    IN    VARCHAR2 DEFAULT 'N'
, p_credit_check_rule_rec IN    OE_Credit_Check_Util.OE_credit_rules_rec_type
, p_system_parameter_rec  IN    OE_Credit_Check_Util.OE_systems_param_rec_type
, p_global_exposure_flag  IN    VARCHAR2 := 'N'
, p_credit_limit_entity_id IN   VARCHAR2
, x_total_exposure        OUT   NOCOPY NUMBER
, x_cc_result_out         OUT   NOCOPY VARCHAR2
, x_error_curr_tbl        OUT   NOCOPY OE_CREDIT_CHECK_UTIL.curr_tbl_type
, x_return_status         OUT   NOCOPY VARCHAR2
);


END OE_Credit_check_order_PVT;

/
