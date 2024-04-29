--------------------------------------------------------
--  DDL for Package HZ_CREDIT_USAGES_CASCADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CREDIT_USAGES_CASCADE_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHCRCCS.pls 115.8 2003/01/09 02:47:43 vto noship $ */
--======================================================================
--CONSTANTS
--======================================================================
G_PKG_NAME CONSTANT VARCHAR2(30)    := 'HZ_CREDIT_USAGES_CASCADE_PKG' ;


---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------
------------------------------------------------------------------------
-- PROCEDURE cascade_credit_usage_rules
-- The procedure accepts the input parameters
--
-- p_cust_acct_profile_amt_id
--   New cust acct profile amt ID that is being created
--
-- p_cust_profile_id
--   The parent cust profile id of the new cust acct profile amt ID
--   being created
--
-- p_profile_class_amt_id
--   The profile_class_amt_id that is being used to create the new
--   cust_acct_profile_amt_id
--
-- p_profile_class_id
--   The parent profile_class_id of the profile_class_amt_id that is
--   being used to create the new cust_acct_profile_amt_id
--
------------------------------------------------------------------------

PROCEDURE cascade_credit_usage_rules
( p_cust_acct_profile_amt_id IN NUMBER
, p_cust_profile_id          IN NUMBER
, p_profile_class_amt_id     IN NUMBER
, p_profile_class_id         IN NUMBER
, X_return_status            OUT NOCOPY VARCHAR2
, X_msg_count                OUT NOCOPY NUMBER
, X_msg_data                 OUT NOCOPY VARCHAR2
);

------------------------------------------------------------------------
-- PROCEDURE: delete_credit_usages
-- COMMENTS: This procedure will accept the
--           cust_acct_profile_amt_id as input and
--           remove records from the multi currency credit checking
--           usages table HZ_CREDIT_USAGES for this ID
------------------------------------------------------------------------
PROCEDURE delete_credit_usages
( p_cust_acct_profile_amt_id IN NUMBER
, X_return_status            OUT NOCOPY VARCHAR2
, X_msg_count                OUT NOCOPY NUMBER
, X_msg_data                 OUT NOCOPY VARCHAR2
);


------------------------------------------------------------------------
-- PROCEDURE: Check_Duplicate_all
-- COMMENTS:  This procedure will check the
--            duplication of currencies across  the
--            existing assigned rule sets with the
--            profile
------------------------------------------------------------------------
PROCEDURE Check_Duplicate_all
  (  p_rule_set_id              IN  NUMBER
   , p_entity                   IN  VARCHAR2
   , p_entity_id                IN  NUMBER
   , p_cust_account_id          IN  NUMBER
   , p_include_all              IN  VARCHAR2
   , p_cust_acct_profile_amt_id IN  NUMBER
   , x_duplicate                OUT NOCOPY VARCHAR2
   , x_dupl_curr                OUT NOCOPY VARCHAR2
) ;

END HZ_CREDIT_USAGES_CASCADE_PKG ;

 

/
