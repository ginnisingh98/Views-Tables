--------------------------------------------------------
--  DDL for Package HZ_CREDIT_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CREDIT_USAGES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHUSAGS.pls 115.6 2003/08/18 18:09:04 rajkrish ship $ */

--======================================================================
--CONSTANTS
--======================================================================
G_PKG_NAME CONSTANT VARCHAR2(30)    :='HZ_CREDIT_USAGES_PKG';
G_excl_curr_list      VARCHAR2(2000);


----- TYPES
TYPE Usage_Curr_Rec IS RECORD
( usage_curr_code  HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE );


TYPE CURR_TBL_TYPE IS TABLE OF Usage_Curr_Rec
     INDEX BY BINARY_INTEGER;

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--========================================================================
-- FUNCTION  : Check_release                   PUBLIC
-- PARAMETERS:

-- COMMENT   : Function returns 'OLD' if AR Credit Management is not
--             installed or not active and returns 'NEW' if AR Credit
--             Management is installed and active
--========================================================================
FUNCTION Check_release
RETURN VARCHAR2;

--========================================================================
-- PROCEDURE : Insert_row                   PUBLIC
-- PARAMETERS: p_row_id                     ROWID of the current record
--             p_credit_usage_rule_set_id   rule set id
--             p_credit_usage_id            primary key
--             p_credit_profile_amt_id      credit_profile_amt_id
--             p_cust_acct_profile_amt_id   cust_acct_profile_amt_id
--             p_profile_class_amt_id       profile_class_amt_id
--             p_creation_date              date, when a record was inserted
--             p_created_by                 userid of the person,who inserted
--                                          a record
--             p_last_update_date           date, when a record was inserted
--             p_last_updated_by            userid of the person,who inserted
--                                          a record
--             p_last_update_login          login of the person,who inserted
--                                          a record

-- COMMENT   : Procedure inserts record into the table HZ_CREDIT_USAGES
--========================================================================
PROCEDURE Insert_row
( p_row_id    OUT   NOCOPY           VARCHAR2
, p_credit_usage_rule_set_id   NUMBER
, p_credit_usage_id            NUMBER
, p_credit_profile_amt_id      NUMBER
, p_cust_acct_profile_amt_id   NUMBER
, p_profile_class_amt_id       NUMBER
, p_creation_date              DATE
, p_created_by                 NUMBER
, p_last_update_date           DATE
, p_last_updated_by            NUMBER
, p_last_update_login          NUMBER
, p_attribute_category         VARCHAR2
, p_attribute1                 VARCHAR2
, p_attribute2                 VARCHAR2
, p_attribute3                 VARCHAR2
, p_attribute4                 VARCHAR2
, p_attribute5                 VARCHAR2
, p_attribute6                 VARCHAR2
, p_attribute7                 VARCHAR2
, p_attribute8                 VARCHAR2
, p_attribute9                 VARCHAR2
, p_attribute10                VARCHAR2
, p_attribute11                VARCHAR2
, p_attribute12                VARCHAR2
, p_attribute13                VARCHAR2
, p_attribute14                VARCHAR2
, p_attribute15                VARCHAR2
);



--========================================================================
-- PROCEDURE : Delete_row              PUBLIC
-- PARAMETERS: p_row_id                ROWID of the current record
-- COMMENT   : Procedure deletes record with ROWID=p_row_id from the
--             table HZ_CREDIT_USAGES.
--========================================================================
PROCEDURE Delete_row
( p_row_id                     VARCHAR2
);


--========================================================================
-- PROCEDURE : Lock_row                    PUBLIC
-- PARAMETERS: p_row_id                    ROWID of the current record
--             p_credit_usage_rule_set_id  credit_usage_rule_set_id
--             p_credit_profile_amt_id
--             p_profile_class_amount_id
--             p_cust_acct_profile_amt_id
--
-- COMMENT   : Procedure locks current record in the table HZ_CREDIT_USAGES.
--========================================================================
PROCEDURE Lock_row
( p_row_id                     VARCHAR2
, p_credit_usage_rule_set_id   NUMBER
, p_credit_profile_amt_id      NUMBER
, p_profile_class_amount_id    NUMBER
, p_cust_acct_profile_amt_id   NUMBER
);


------------------------------------------------------------------------------
--  PROCEDURE  : Get_Limit_Currency_usages
--  COMMENT    : REturns
--               a) Limit currency
--                b) Credit limits
--                c) Associated usage rules
------------------------------------------------------------------------------
PROCEDURE Get_Limit_Currency_usages (
  p_entity_type                 IN  VARCHAR2
 , p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN  VARCHAR2
 , x_limit_curr_code             OUT NOCOPY VARCHAR2
 , x_trx_limit                   OUT NOCOPY NUMBER
 , x_overall_limit               OUT NOCOPY NUMBER
 , x_cust_acct_profile_amt_id    OUT NOCOPY NUMBER
 , x_global_exposure_flag       OUT  NOCOPY VARCHAR2
 , x_include_all_flag           OUT NOCOPY VARCHAR2
 , x_usage_curr_tbl             OUT NOCOPY HZ_CREDIT_USAGES_PKG.curr_tbl_type
 , x_excl_curr_list             OUT NOCOPY VARCHAR2
) ;



------------------------------------------------------------------------------
--  PROCEDURE  : Get_usage_rules
--  COMMENT    : Returns the Usage currencies associated with a given
--               profile amount currency
--
------------------------------------------------------------------------------
PROCEDURE Get_usage_rules(
 p_cust_acct_profile_amt_id    IN  NUMBER
,p_limit_curr_code             IN VARCHAR2
, x_global_exposure_flag       OUT NOCOPY  VARCHAR2
, x_include_all_flag           OUT NOCOPY VARCHAR2
, x_usage_curr_tbl             OUT NOCOPY HZ_CREDIT_USAGES_PKG.curr_tbl_type
, x_excl_curr_list             OUT NOCOPY VARCHAR2
);


END HZ_CREDIT_USAGES_PKG;

 

/
