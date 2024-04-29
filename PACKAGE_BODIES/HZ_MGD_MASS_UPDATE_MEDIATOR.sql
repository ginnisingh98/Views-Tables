--------------------------------------------------------
--  DDL for Package Body HZ_MGD_MASS_UPDATE_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MGD_MASS_UPDATE_MEDIATOR" AS
/* $Header: ARHCMUMB.pls 120.2 2005/06/30 04:46:50 bdhotkar noship $*/
/*+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    ARHCMUMB.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Body of the package HZ_MGD_MASS_UPDATE_MEDIATOR                   |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Mass_Update_Usage_Rules                                           |
--|     Check_Duplicate_ALL                                               |
--|                                                                       |
--| HISTORY                                                               |
--|     05/14/2002 tsimmond    Created                                    |
--|     11/27/2002 tsimmond    Updated   Added WHENEVER OSERROR EXIT      |
--|                                      FAILURE ROLLBACK                 |
--|                                                                       |
--+======================================================================*/


--======================================================================
--CONSTANTS
--======================================================================
--G_PKG_NAME CONSTANT VARCHAR2(30)    := 'HZ_MGD_MASS_UPDATE_MEDIATOR' ;
G_request_id    NUMBER
           := FND_GLOBAL.CONC_Request_id ;
G_program_id  NUMBER
             := FND_GLOBAL.CONC_program_id ;
G_program_application_id NUMBER
    := FND_GLOBAL.PROG_APPL_ID ;
G_user_id      NUMBER          :=
           NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),1) ;
G_login_id          NUMBER     :=
           NVL(TO_NUMBER(FND_PROFILE.Value('LOGIN_ID')),1) ;


--====================================================================
PROCEDURE Get_entity_name
( p_entity_id   IN NUMBER
, p_entity      IN VARCHAR2
, p_cust_account_id IN NUMBER
, x_party_name  OUT NOCOPY   VARCHAR2
, x_cust_name   OUT NOCOPY VARCHAR2
, x_site_name   OUT NOCOPY VARCHAR2
)
IS
l_cust_name hz_parties.party_name%TYPE;
l_cust_num  hz_parties.party_number%TYPE;
l_site_name hz_cust_site_uses.location%TYPE;

BEGIN

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '>> Get_entity_name ' );

  HZ_MGD_MASS_UPDATE_REP_GEN.Log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
  , p_msg => 'entity= '||p_entity
          || ' entity_id= '||TO_CHAR(p_entity_id));

  ----if entity=PARTY-----------
  IF p_entity='PARTY'
  THEN
    SELECT
      SUBSTRB(party_name,1,40)
    INTO
      x_party_name
    FROM hz_parties
    WHERE party_id=p_entity_id;

    x_cust_name:=' ';
    x_site_name:=' ';

    HZ_MGD_MASS_UPDATE_REP_GEN.Log
    ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
    , p_msg => 'party_name= '||x_party_name
    );

  ----if entity=CUSTOMER-----------
  ELSIF p_entity='CUSTOMER'
  THEN
    SELECT
      SUBSTRB(hp.party_name,1,30)
    , hca.account_number
    INTO
      l_cust_name
    , l_cust_num
    FROM
      hz_parties hp
    , hz_cust_accounts hca
    WHERE hca.party_id=hp.party_id
      AND hca.cust_account_id=p_entity_id;

    x_party_name:=' ';
    x_cust_name:=l_cust_name||'('||l_cust_num||')';
    x_site_name:=' ';

    HZ_MGD_MASS_UPDATE_REP_GEN.Log
    ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
    , p_msg => 'customer_name= '||x_cust_name
    );

  ----if entity=SITE-----------
  ELSIF p_entity='SITE'
  THEN

    SELECT
      location
    INTO
      x_site_name
    FROM
      hz_cust_site_uses
    WHERE site_use_id=p_entity_id;

    SELECT
      SUBSTRB(hp.party_name,1,30)
    , hca.account_number
    INTO
      l_cust_name
    , l_cust_num
    FROM
      hz_parties hp
    , hz_cust_accounts hca
    WHERE hca.party_id=hp.party_id
      AND hca.cust_account_id=p_cust_account_id;

    x_cust_name:=l_cust_name||'('||l_cust_num||')';

    HZ_MGD_MASS_UPDATE_REP_GEN.Log
    ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
    , p_msg => 'site_name= '||x_site_name
    );

  END IF;


  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '<< Get_entity_name ' );

END Get_entity_name;

--================================================================

-- Check duplication for all the profile currencies
-- Also extends the logic for ALL_CURRENCIES set up


-------------------------------------------------------------------

/*-------------------------------------------------------------
 PROCEDURE: Check_Duplicate_all
 COMMENTS:  This procedure will check the
            duplication of currencies across  the
            existing assigned rule sets with the
            profile
-----------------------------------------------------------------*/
PROCEDURE Check_Duplicate_all
  (  p_rule_set_id              IN NUMBER
   , p_entity                   IN VARCHAR2
   , p_entity_id                IN NUMBER
   , p_cust_account_id          IN NUMBER
   , p_include_all              IN VARCHAR2
   , p_cust_acct_profile_amt_id IN NUMBER
   , x_duplicate               OUT NOCOPY VARCHAR2
   , x_dupl_curr               OUT NOCOPY VARCHAR2
)
IS

l_usage_curr               VARCHAR2(30) ;
l_cust_acct_profile_amt_id NUMBER;

-------------------------------------------------

-- CASE1 : Add rule set with no Include all currencies

-- CASE2:  Add rule set with Include all currencies

--         This case will be checked both for
--         already attached rules sets with and without
--         Include all currencies

-- The checking will be peformed for the following
-- entities.
-- p_entity_id will contain the reference ID

-- PARTY
-- CUSTOMER
-- SITE ( p_cust_account_id will also be populated )
-- ORGANIZATION
-- ITEM
-- CLASS
-------------------------------------------------
---------------
--  RULES CURSOR --
-------------------------

CURSOR SELECT_USAGE_CURR_CSR IS
 SELECT user_code
  FROM  HZ_CREDIT_USAGE_RULES
  WHERE credit_usage_rule_set_id = p_rule_set_id
    AND usage_type = 'CURRENCY'
    AND NVL (include_all_flag, 'N') = 'N'
    AND NVL(exclude_flag,'N') = 'N' ;


--------------------
 -- PARTY ------
 ----------------------

CURSOR party_check_case1_no_incl_csr IS
 SELECT   cu.credit_usage_id
 ,       substrb(cur.user_code,1,5)  curr
 ,       cpa.currency_code prof_curr
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.party_id           = p_entity_id
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_id =-1
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type = 'CURRENCY'
  AND     cur.user_code  IN (
          SELECT cr2.user_code from
           hz_credit_usage_rules        cr2
          WHERE cr2.credit_usage_rule_set_id = p_rule_set_id
            AND cr2.usage_type = 'CURRENCY' and
            NVL (cr2.include_all_flag, 'N') = 'N'
           AND NVL(cr2.exclude_flag,'N') = 'N'
          )
  AND     NVL(cur.exclude_flag,'N') = 'N';

  party_check_case1_no_incl_rec  party_check_case1_no_incl_csr%ROWTYPE ;


CURSOR party_check_case1_incl_csr ( p_curr_code IN VARCHAR2 ) IS
SELECT   cpa.currency_code profile_curr
  ,      cu.credit_usage_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.party_id           = p_entity_id
  AND    cp.cust_account_id =-1
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date), TRUNC(SYSDATE)
            )    <= TRUNC(SYSDATE)
  AND   NVL (cur.include_all_flag, 'N') = 'Y'
  AND   NOT EXISTS ( SELECT 'EXCLUDE'
                      FROM   hz_credit_usage_rules cur2
                      WHERE  cu.credit_usage_rule_set_id
                             = cur2.credit_usage_rule_set_id
                      AND    NVL(cur2.exclude_flag,'N') = 'Y'
                      AND    cur2.usage_type  = 'CURRENCY'
                      AND    cur2.user_code   = p_curr_code
);


  party_check_case1_incl_rec  party_check_case1_incl_csr%ROWTYPE ;


CURSOR party_check_case2_no_incl_csr IS
SELECT   cu.credit_usage_id
,       substrb(cur.user_code,1,5)  curr
,       cpa.currency_code prof_curr
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.party_id           = p_entity_id
  AND    cp.cust_account_id =-1
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type = 'CURRENCY'
  AND     cur.user_code NOT IN (
          SELECT cr2.user_code from
           hz_credit_usage_rules        cr2
          WHERE cr2.credit_usage_rule_set_id = p_rule_set_id
            AND cr2.usage_type = 'CURRENCY' and
            NVL (cr2.include_all_flag, 'N') = 'N'
           AND NVL(cr2.exclude_flag,'N') = 'Y'
          )
  AND     NVL(cur.exclude_flag,'N') = 'N' ;


  party_check_case2_no_incl_rec  party_check_case2_no_incl_csr%ROWTYPE ;


CURSOR party_check_case2_incl_csr IS
SELECT   cpa.currency_code profile_curr
  ,      cu.credit_usage_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.party_id           = p_entity_id
  AND    cp.cust_account_id =-1
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date), TRUNC(SYSDATE)
            )    <= TRUNC(SYSDATE)
  AND   NVL (cur.include_all_flag, 'N') = 'Y' ;


  party_check_case2_incl_rec  party_check_case2_incl_csr%ROWTYPE ;


  --------------------
  -- SITE ---
  ---------------------

CURSOR site_check_case1_no_incl_csr IS
 SELECT   cu.credit_usage_id
,       substrb(cur.user_code,1,5)  curr
,       cpa.currency_code prof_curr
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = p_cust_account_id
  AND    cp.site_use_id               = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type = 'CURRENCY'
  AND     cur.user_code  IN (
          SELECT cr2.user_code from
           hz_credit_usage_rules        cr2
          WHERE cr2.credit_usage_rule_set_id = p_rule_set_id
            AND cr2.usage_type = 'CURRENCY' and
            NVL (cr2.include_all_flag, 'N') = 'N'
           AND NVL(cr2.exclude_flag,'N') = 'N'
          )
  AND     NVL(cur.exclude_flag,'N') = 'N' ;


  site_check_case1_no_incl_rec site_check_case1_no_incl_csr%ROWTYPE ;

CURSOR site_check_case1_incl_csr ( p_curr_code IN VARCHAR2 ) IS
SELECT   cpa.currency_code profile_curr
  ,      cu.credit_usage_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = p_cust_account_id
  AND    cp.site_use_id               = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date), TRUNC(SYSDATE)
            )    <= TRUNC(SYSDATE)
  AND   NVL (cur.include_all_flag, 'N') = 'Y'
  AND   NOT EXISTS ( SELECT 'EXCLUDE'
                      FROM   hz_credit_usage_rules cur2
                      WHERE  cu.credit_usage_rule_set_id
                             = cur2.credit_usage_rule_set_id
                      AND    NVL(cur2.exclude_flag,'N') = 'Y'
                      AND    cur2.usage_type  = 'CURRENCY'
                      AND    cur2.user_code   = p_curr_code );

site_check_case1_incl_rec  site_check_case1_incl_csr%ROWTYPE ;



CURSOR site_check_case2_no_incl_csr IS
SELECT   cu.credit_usage_id
,       substrb(cur.user_code,1,5)  curr
,       cpa.currency_code prof_curr
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = p_cust_account_id
  AND    cp.site_use_id               = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type = 'CURRENCY'
  AND     cur.user_code NOT IN (
          SELECT cr2.user_code from
           hz_credit_usage_rules        cr2
          WHERE cr2.credit_usage_rule_set_id = p_rule_set_id
            AND cr2.usage_type = 'CURRENCY' and
            NVL (cr2.include_all_flag, 'N') = 'N'
           AND NVL(cr2.exclude_flag,'N') = 'Y'
          )
  AND     NVL(cur.exclude_flag,'N') = 'N' ;


  site_check_case2_no_incl_rec   site_check_case2_no_incl_csr%ROWTYPE;

CURSOR site_check_case2_incl_csr IS
SELECT   cpa.currency_code profile_curr
  ,      cu.credit_usage_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = p_cust_account_id
  AND    cp.site_use_id               = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date), TRUNC(SYSDATE)
            )    <= TRUNC(SYSDATE)
  AND   NVL (cur.include_all_flag, 'N') = 'Y' ;



  site_check_case2_incl_rec  site_check_case2_incl_csr%ROWTYPE ;





 --------------------
 -- CUSTOMER ------
 ----------------------

CURSOR cust_check_case1_no_incl_csr IS
 SELECT   cu.credit_usage_id
 ,       substrb(cur.user_code,1,5)  curr
 ,       cpa.currency_code prof_curr
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = p_entity_id
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type = 'CURRENCY'
  AND     cur.user_code  IN (
          SELECT cr2.user_code from
           hz_credit_usage_rules        cr2
          WHERE cr2.credit_usage_rule_set_id = p_rule_set_id
            AND cr2.usage_type = 'CURRENCY' and
            NVL (cr2.include_all_flag, 'N') = 'N'
           AND NVL(cr2.exclude_flag,'N') = 'N'
          )
  AND     NVL(cur.exclude_flag,'N') = 'N' ;

  cust_check_case1_no_incl_rec  cust_check_case1_no_incl_csr%ROWTYPE ;


CURSOR cust_check_case1_incl_csr ( p_curr_code IN VARCHAR2 ) IS
SELECT   cpa.currency_code profile_curr
  ,      cu.credit_usage_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = p_entity_id
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date), TRUNC(SYSDATE)
            )    <= TRUNC(SYSDATE)
  AND   NVL (cur.include_all_flag, 'N') = 'Y'
  AND   NOT EXISTS ( SELECT 'EXCLUDE'
                      FROM   hz_credit_usage_rules cur2
                      WHERE  cu.credit_usage_rule_set_id
                             = cur2.credit_usage_rule_set_id
                      AND    NVL(cur2.exclude_flag,'N') = 'Y'
                      AND    cur2.usage_type  = 'CURRENCY'
                      AND    cur2.user_code   = p_curr_code
);


  cust_check_case1_incl_rec  cust_check_case1_incl_csr%ROWTYPE ;


CURSOR cust_check_case2_no_incl_csr IS
SELECT   cu.credit_usage_id
,       substrb(cur.user_code,1,5)  curr
,       cpa.currency_code prof_curr
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = p_entity_id
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type = 'CURRENCY'
  AND     cur.user_code NOT IN (
          SELECT cr2.user_code from
           hz_credit_usage_rules        cr2
          WHERE cr2.credit_usage_rule_set_id = p_rule_set_id
            AND cr2.usage_type = 'CURRENCY' and
            NVL (cr2.include_all_flag, 'N') = 'N'
           AND NVL(cr2.exclude_flag,'N') = 'Y'
          )
  AND     NVL(cur.exclude_flag,'N') = 'N' ;


  cust_check_case2_no_incl_rec  cust_check_case2_no_incl_csr%ROWTYPE ;


CURSOR cust_check_case2_incl_csr IS
SELECT   cpa.currency_code profile_curr
  ,      cu.credit_usage_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = p_entity_id
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date), TRUNC(SYSDATE)
            )    <= TRUNC(SYSDATE)
  AND   NVL (cur.include_all_flag, 'N') = 'Y' ;


  cust_check_case2_incl_rec  cust_check_case2_incl_csr%ROWTYPE ;


BEGIN

  x_duplicate := 'N' ;

  -- using l_cust_acct_profile_amt_id local variable as this
  -- API will be used for other cascading features within
  -- Multi curremcy credit checking project and the
  -- p_cust_acct_profile_amt_id may not be made available

  l_cust_acct_profile_amt_id := p_cust_acct_profile_amt_id;

  IF p_entity = 'SITE'
  THEN
     --------------------- BEGIN SITE ----------------------
     BEGIN
        OPEN site_check_case1_no_incl_csr ;
        FETCH site_check_case1_no_incl_csr
        INTO  site_check_case1_no_incl_rec ;


        IF site_check_case1_no_incl_csr%NOTFOUND
        THEN
          x_duplicate := 'N' ;
          x_dupl_curr := NULL ;
          --FND_MESSAGE.DEBUG(' site - 1 no found');

        ELSE
          x_duplicate := 'Y' ;
          x_dupl_curr := site_check_case1_no_incl_rec.curr ;

          --DBMS_OUTPUT.PUT_LINE(' site - 1 ');
       END IF;

       CLOSE site_check_case1_no_incl_csr ;

       IF x_duplicate = 'N'
       THEN
         l_usage_curr := NULL ;

         OPEN SELECT_USAGE_CURR_CSR ;
         LOOP
           FETCH SELECT_USAGE_CURR_CSR
           INTO  l_usage_curr ;

           IF SELECT_USAGE_CURR_CSR%NOTFOUND
           THEN
             l_usage_curr := NULL ;
             EXIT ;
           END IF;

           --DBMS_OUTPUT.PUT_LINE(' l_usage_curr = '|| l_usage_curr);

           OPEN site_check_case1_incl_csr  ( l_usage_curr );
           FETCH site_check_case1_incl_csr
           INTO  site_check_case1_incl_rec ;

           IF site_check_case1_incl_csr%NOTFOUND
           THEN
             x_duplicate := 'N' ;
             x_dupl_curr := NULL ;

            --DBMS_OUTPUT.PUT_LINE(' site - 2 no found');

           ELSE
              x_duplicate := 'Y' ;
              x_dupl_curr := l_usage_curr ;

              CLOSE site_check_case1_incl_csr ;

            --DBMS_OUTPUT.PUT_LINE(' site - 2 ');

             EXIT ;

           END IF;

           CLOSE site_check_case1_incl_csr ;

         END LOOP;
         CLOSE SELECT_USAGE_CURR_CSR ;
         --DBMS_OUTPUT.PUT_LINE(' site - 2 - Out of LOOP ');

       END IF;

       IF NVL(p_include_all,'N') = 'Y'
       THEN
        IF x_duplicate = 'N'
        THEN
          OPEN site_check_case2_no_incl_csr ;
          FETCH site_check_case2_no_incl_csr
          INTO  site_check_case2_no_incl_rec ;


          IF site_check_case2_no_incl_csr%NOTFOUND
          THEN
            x_duplicate := 'N' ;
            x_dupl_curr := NULL ;

           --DBMS_OUTPUT.PUT_LINE(' site - 3 no found');

          ELSE

            x_duplicate := 'Y' ;
            x_dupl_curr := site_check_case2_no_incl_rec.curr ;

            --DBMS_OUTPUT.PUT_LINE(' site - 3 ');

          END IF;

          CLOSE site_check_case2_no_incl_csr ;

        END IF;

        IF x_duplicate = 'N'
        THEN
          OPEN site_check_case2_incl_csr ;
           FETCH site_check_case2_incl_csr
           INTO  site_check_case2_incl_rec ;


           IF site_check_case2_incl_csr%NOTFOUND
           THEN
             x_duplicate := 'N' ;
             x_dupl_curr :=  NULL;

            -- DBMS_OUTPUT.PUT_LINE(' site - 4 no found');

           ELSE
             x_duplicate := 'Y' ;
             x_dupl_curr := 'ALL Currency' ;
            -- DBMS_OUTPUT.PUT_LINE(' site - 4 ');
          END IF;

           CLOSE site_check_case2_incl_csr ;

        END IF;
       END IF; -- case2
     END ; -- End Site

     --------------- End SITE --------------------------------


     --------------------- BEGIN CUST ----------------------

    ELSIF p_entity = 'CUSTOMER'
    THEN

      BEGIN

        OPEN CUST_check_case1_no_incl_csr ;
        FETCH CUST_check_case1_no_incl_csr
        INTO  CUST_check_case1_no_incl_rec ;


       IF CUST_check_case1_no_incl_csr%NOTFOUND
       THEN
         x_duplicate := 'N' ;
         x_dupl_curr := NULL ;
        --FND_MESSAGE.DEBUG(' CUST - 1 no found');

       ELSE
          x_duplicate := 'Y' ;
          x_dupl_curr := CUST_check_case1_no_incl_rec.curr ;

          --FND_MESSAGE.DEBUG(' CUST - 1 ');
       END IF;

       CLOSE CUST_check_case1_no_incl_csr ;

       IF x_duplicate = 'N'
       THEN
        l_usage_curr := NULL ;

        OPEN SELECT_USAGE_CURR_CSR ;
        LOOP
          FETCH SELECT_USAGE_CURR_CSR
          INTO  l_usage_curr ;

          IF SELECT_USAGE_CURR_CSR%NOTFOUND
          THEN
            l_usage_curr := NULL ;
            EXIT ;
          END IF;

         --FND_MESSAGE.DEBUG(' l_usage_curr = '|| l_usage_curr);

         OPEN CUST_check_case1_incl_csr  ( l_usage_curr );
         FETCH CUST_check_case1_incl_csr
         INTO  CUST_check_case1_incl_rec ;

         IF CUST_check_case1_incl_csr%NOTFOUND
         THEN
            x_duplicate := 'N' ;
            x_dupl_curr := NULL ;

          --FND_MESSAGE.DEBUG(' CUST - 2 no found');

         ELSE

            x_duplicate := 'Y' ;
            x_dupl_curr := l_usage_curr ;

            CLOSE CUST_check_case1_incl_csr ;

           --FND_MESSAGE.DEBUG(' CUST - 2 ');

           EXIT ;

         END IF;

         CLOSE CUST_check_case1_incl_csr ;

        END LOOP;
        CLOSE SELECT_USAGE_CURR_CSR ;
        --FND_MESSAGE.DEBUG(' CUST - 2 - Out of LOOP ');

       END IF;

       IF NVL(p_include_all,'N') = 'Y'
       THEN
        IF x_duplicate = 'N'
        THEN
          OPEN CUST_check_case2_no_incl_csr ;
          FETCH CUST_check_case2_no_incl_csr
          INTO  CUST_check_case2_no_incl_rec ;


          IF CUST_check_case2_no_incl_csr%NOTFOUND
          THEN
            x_duplicate := 'N' ;
            x_dupl_curr := NULL ;

           --FND_MESSAGE.DEBUG(' CUST - 3 no found');

          ELSE

          x_duplicate := 'Y' ;
          x_dupl_curr := CUST_check_case2_no_incl_rec.curr ;

          --FND_MESSAGE.DEBUG(' CUST - 3 ');

          END IF;

          CLOSE CUST_check_case2_no_incl_csr ;

        END IF;

        IF x_duplicate = 'N'
        THEN
          OPEN CUST_check_case2_incl_csr ;
           FETCH CUST_check_case2_incl_csr
           INTO  CUST_check_case2_incl_rec ;


           IF CUST_check_case2_incl_csr%NOTFOUND
           THEN
             x_duplicate := 'N' ;
             x_dupl_curr := NULL ;

             --FND_MESSAGE.DEBUG(' CUST - 4 no found');

          ELSE
             x_duplicate := 'Y' ;
             x_dupl_curr := 'ALL Currency' ;
             --FND_MESSAGE.DEBUG(' CUST - 4 ');
          END IF;

          CLOSE CUST_check_case2_incl_csr ;

         END IF;
       END IF; -- case2

     END ; -- Customer

     --------------- End CUST --------------------------------

       --------------------- BEGIN PARTY ----------------------

    ELSIF p_entity = 'PARTY'
    THEN

      BEGIN

        OPEN party_check_case1_no_incl_csr ;
        FETCH party_check_case1_no_incl_csr
        INTO  party_check_case1_no_incl_rec ;


       IF party_check_case1_no_incl_csr%NOTFOUND
       THEN
         x_duplicate := 'N' ;
         x_dupl_curr := NULL ;
        --FND_MESSAGE.DEBUG(' PARTY - 1 no found');

       ELSE
          x_duplicate := 'Y' ;
          x_dupl_curr := party_check_case1_no_incl_rec.curr ;

          --FND_MESSAGE.DEBUG(' PARTY - 1 ');
       END IF;

       CLOSE party_check_case1_no_incl_csr ;

       IF x_duplicate = 'N'
       THEN
        l_usage_curr := NULL ;

        OPEN SELECT_USAGE_CURR_CSR ;
        LOOP
          FETCH SELECT_USAGE_CURR_CSR
          INTO  l_usage_curr ;

          IF SELECT_USAGE_CURR_CSR%NOTFOUND
          THEN
            l_usage_curr := NULL ;
            EXIT ;
          END IF;

         --FND_MESSAGE.DEBUG(' l_usage_curr = '|| l_usage_curr);

         OPEN party_check_case1_incl_csr  ( l_usage_curr );
         FETCH party_check_case1_incl_csr
         INTO  party_check_case1_incl_rec ;

         IF party_check_case1_incl_csr%NOTFOUND
         THEN
            x_duplicate := 'N' ;
            x_dupl_curr := NULL ;

          --FND_MESSAGE.DEBUG(' PARTY - 2 no found');

         ELSE

            x_duplicate := 'Y' ;
            x_dupl_curr := l_usage_curr ;

            CLOSE party_check_case1_incl_csr ;

           --FND_MESSAGE.DEBUG(' PARTY - 2 ');

           EXIT ;

         END IF;

         CLOSE party_check_case1_incl_csr ;

        END LOOP;
        CLOSE SELECT_USAGE_CURR_CSR ;
        --FND_MESSAGE.DEBUG(' PARTY - 2 - Out of LOOP ');

       END IF;

       IF NVL(p_include_all,'N') = 'Y'
       THEN
        IF x_duplicate = 'N'
        THEN
          OPEN party_check_case2_no_incl_csr ;
          FETCH party_check_case2_no_incl_csr
          INTO  party_check_case2_no_incl_rec ;


          IF party_check_case2_no_incl_csr%NOTFOUND
          THEN
            x_duplicate := 'N' ;
            x_dupl_curr := NULL ;

           --FND_MESSAGE.DEBUG(' PARTY - 3 no found');

          ELSE

          x_duplicate := 'Y' ;
          x_dupl_curr := party_check_case2_no_incl_rec.curr ;

          --FND_MESSAGE.DEBUG(' PARTY - 3 ');

          END IF;

          CLOSE party_check_case2_no_incl_csr ;

        END IF;

        IF x_duplicate = 'N'
        THEN
          OPEN party_check_case2_incl_csr ;
           FETCH party_check_case2_incl_csr
           INTO  party_check_case2_incl_rec ;


           IF party_check_case2_incl_csr%NOTFOUND
           THEN
             x_duplicate := 'N' ;
             x_dupl_curr := NULL ;

             --FND_MESSAGE.DEBUG(' PARTY - 4 no found');

          ELSE
             x_duplicate := 'Y' ;
             x_dupl_curr := 'ALL Currency' ;
             --FND_MESSAGE.DEBUG(' PARTY - 4 ');
          END IF;

          CLOSE party_check_case2_incl_csr ;

         END IF;
       END IF; -- case2

     END ; -- Party

     --------------- End Party --------------------------------


  ELSE
    x_duplicate := 'Y' ;
     x_dupl_curr := 'INVALID ENTITY' ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE ;
END Check_Duplicate_all ;



/*-------------------------------------------------------------
 PROCEDURE: delete_credit_usages
 COMMENTS: This procedure will accept the
           cust_acct_profile_amt_id as input and
           remove records from the multi currency credit checking
           usages table HZ_CREDIT_USAGES for this ID
-----------------------------------------------------------------*/
PROCEDURE delete_credit_usages
( p_cust_acct_profile_amt_id IN NUMBER
, X_return_status            OUT NOCOPY VARCHAR2
, X_msg_count                OUT NOCOPY NUMBER
, X_msg_data                 OUT NOCOPY VARCHAR2
) IS

BEGIN
 -- Delete the Rule set assigned for a given
 -- profile amt id

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '>> delete_credit_usages' );

  X_return_status := 'S' ;

  DELETE FROM
       HZ_CREDIT_USAGES
  WHERE CUST_ACCT_PROFILE_AMT_ID
    =  p_cust_acct_profile_amt_id ;

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '<< delete_credit_usages' );

EXCEPTION
  WHEN OTHERS THEN
    X_return_status := 'U' ;
END delete_credit_usages ;


--------------------------------------------------------------------
-- PROCEDURE cascade_credit_usage_rules
-- The procedure accepts two input parameters
-- a) p_cust_acct_profile_amt_id
--      This is the new customer / site profile amount id that is
--      being created
-- b) p_profile_class_amt_id
--      This is the profile class amt id from which the new
--   new customer / site profile amount id is created
-------------------------------------------------------------------
PROCEDURE cascade_credit_usage_rules
( p_cust_acct_profile_amt_id IN NUMBER
, p_cust_profile_id          IN NUMBER
, p_profile_class_amt_id     IN NUMBER
, p_profile_class_id         IN NUMBER
, X_return_status            OUT NOCOPY VARCHAR2
, X_msg_count                OUT NOCOPY NUMBER
, X_msg_data                 OUT NOCOPY VARCHAR2
)
IS

l_entity                VARCHAR2(30);
l_entity_id             NUMBER;
l_cust_account_id       NUMBER;
l_include_all           VARCHAR2(1);
l_duplicate             VARCHAR2(1);
l_duplicate_curr        VARCHAR2(30);
l_cust_name             VARCHAR2(50);
l_site_name             VARCHAR2(50);
l_party_name            VARCHAR2(50);
l_count                 NUMBER;



CURSOR rule_set_csr IS
SELECT
  credit_usage_rule_set_id
FROM HZ_CREDIT_USAGES
WHERE profile_class_amount_id = p_profile_class_amt_id;

RULE_SET_CSR_REC    rule_set_csr%ROWTYPE;

l_id                NUMBER;
l_cust_account_profile_id NUMBER;

BEGIN

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '>> cascade_credit_usage_rules' );

 -- The API will duplicate the rule set assignments
 -- made with the profile class limit currency with
 -- profile amt currency being created when the
 --  profile class amt currency ic used as reference
 --  The information is currently stores in the
 --  HZ_credit_usages table

 -- The logic is to replicate the exact image of the rule sets
 -- assignments made with the profile class amount currency
 -- so the exiting rule sets assigned with the
 -- cust_profile_amt currency is removed first

 -- Before the actual cascade , the customer/site profile
 -- is verified to check to make sure that the cascade will
 -- not cause any duplicates in the currency usage
 -- assignments

  X_return_status := 'S' ;

  ---------check duplicates------------------
  FOR rule_set_csr_rec IN rule_set_csr
  LOOP
    BEGIN
        SELECT credit_usage_rule_id
        INTO   l_id
        FROM   hz_credit_usage_rules
        WHERE  credit_usage_rule_set_id
                   =  rule_set_csr_rec.credit_usage_rule_set_id
        AND    user_code IS NULL;

        l_include_all := 'Y' ;

        EXCEPTION
        when no_data_found
        THEN
         l_include_all := 'N' ;

        WHEN TOO_MANY_ROWS
        THEN
          l_include_all := 'Y' ;

    END ;


    BEGIN
      SELECT
        cust_account_id
      , DECODE(site_use_id,NULL,'CUSTOMER','SITE') entity_type
      , DECODE(site_use_id,NULL,cust_account_id,site_use_id) entity_id
      , cust_account_profile_id
      INTO
        l_cust_account_id
      , l_entity
      , l_entity_id
      , l_cust_account_profile_id
     FROM
      hz_cust_profile_amts
     WHERE cust_acct_profile_amt_id =
           p_cust_acct_profile_amt_id ;

     IF l_cust_account_id=-1
     THEN

       l_entity:='PARTY';

       SELECT party_id
       INTO
         l_entity_id
       FROM hz_customer_profiles
       WHERE cust_account_profile_id=l_cust_account_profile_id;

     END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        l_entity          := NULL ;
        l_entity_id       := NULL ;
        L_cust_account_id := NULL;

      WHEN TOO_MANY_ROWS
      THEN
        l_entity          := NULL ;
        l_entity_id       := NULL ;
        l_cust_account_id := NULL;

    END ;

   /*DBMS_OUTPUT.PUT_LINE('Rule set ID = '||
     rule_set_csr_rec.credit_usage_rule_set_id );

   DBMS_OUTPUT.PUT_LINE('l_entity = '||
     l_entity );

   DBMS_OUTPUT.PUT_LINE('l_entity_id '||
     l_entity_id );

   DBMS_OUTPUT.PUT_LINE('l_cust_account_id '||
     l_cust_account_id );

   DBMS_OUTPUT.PUT_LINE('l_include_all '||
     l_include_all);
    */

    Check_Duplicate_all
    (  p_rule_set_id             =>
                rule_set_csr_rec.credit_usage_rule_set_id
     , p_entity                  => l_entity
     , p_entity_id               => l_entity_id
     , p_cust_account_id         => l_cust_account_id
     , p_include_all             => l_include_all
     , p_cust_acct_profile_amt_id => p_cust_acct_profile_amt_id
     , x_duplicate               => l_duplicate
     , x_dupl_curr               => l_duplicate_curr
    );

    HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
  , p_msg => ' Check_Duplicate_all returns '||l_duplicate);


    IF l_duplicate = 'Y'
    THEN
      IF l_entity='PARTY'
      THEN
        Get_entity_name
        ( p_entity_id   => l_entity_id
        , p_entity      => l_entity
        , p_cust_account_id=>l_cust_account_id
        , x_party_name  => l_party_name
        , x_cust_name   => l_cust_name
        , x_site_name   => l_site_name
        );

        HZ_MGD_MASS_UPDATE_REP_GEN.Add_Exp_Item
        ( p_party       => l_party_name
        , p_customer    => NULL
        , p_site        => NULL
        );

      ELSIF l_entity='CUSTOMER'
      THEN
        Get_entity_name
        ( p_entity_id   => l_entity_id
        , p_entity      => l_entity
        , p_cust_account_id=>l_cust_account_id
        , x_party_name  => l_party_name
        , x_cust_name   => l_cust_name
        , x_site_name   => l_site_name
        );

        HZ_MGD_MASS_UPDATE_REP_GEN.Add_Exp_Item
        ( p_party       => NULL
        , p_customer    => l_cust_name
        , p_site        => NULL
        );
      ELSIF l_entity='SITE'
      THEN

        Get_entity_name
        ( p_entity_id   => l_entity_id
        , p_entity      => l_entity
        , p_cust_account_id=>l_cust_account_id
        , x_party_name  => l_party_name
        , x_cust_name   => l_cust_name
        , x_site_name   => l_site_name
        );

        HZ_MGD_MASS_UPDATE_REP_GEN.Add_Exp_Item
        ( p_party       => NULL
        , p_customer    => l_cust_name
        , p_site        => l_site_name
        );
      END IF;

      EXIT ;
    END IF;
  END LOOP; -- check duplicates


  ---DBMS_OUTPUT.PUT_LINE('l_duplicate = '|| l_duplicate );


  IF   l_duplicate <> 'Y'
  THEN
    ---DBMS_OUTPUT.PUT_LINE('Call delete_credit_usages ');

    Delete_credit_usages
    (  p_cust_acct_profile_amt_id => p_cust_acct_profile_amt_id
     , X_return_status            => X_return_status
     , X_msg_count                => X_msg_count
     , X_msg_data                 => X_msg_data
    );


  END IF;

  IF X_return_status = 'S'
  AND   l_duplicate <> 'Y'
  THEN
    ---DBMS_OUTPUT.PUT_LINE('Delete SUCCESS, call INSERT ');

    INSERT INTO HZ_CREDIT_USAGES
    (    CREDIT_USAGE_ID
       , CREDIT_PROFILE_AMT_ID
       , CUST_ACCT_PROFILE_AMT_ID
       , PROFILE_CLASS_AMOUNT_ID
       , CREDIT_USAGE_RULE_SET_ID
       , CREATION_DATE
       , CREATED_BY
       , LAST_UPDATE_DATE
       , LAST_UPDATED_BY
       , LAST_UPDATE_LOGIN
       , PROGRAM_APPLICATION_ID
       , PROGRAM_ID
       , PROGRAM_UPDATE_DATE
       , REQUEST_ID
       , ATTRIBUTE_CATEGORY
       , ATTRIBUTE1
       , ATTRIBUTE2
       , ATTRIBUTE3
       , ATTRIBUTE4
       , ATTRIBUTE5
       , ATTRIBUTE6
       , ATTRIBUTE7
       , ATTRIBUTE8
       , ATTRIBUTE9
       , ATTRIBUTE10
       , ATTRIBUTE11
       , ATTRIBUTE12
       , ATTRIBUTE13
       , ATTRIBUTE14
       , ATTRIBUTE15
   ) SELECT
        HZ_CREDIT_USAGES_S.NEXTVAL
       , NULL
       , p_cust_acct_profile_amt_id
       , NULL
       , cu.CREDIT_USAGE_RULE_SET_ID
       , SYSDATE
       , G_user_id
       , SYSDATE
       , G_user_id
       , G_login_id
       , G_program_application_id
       , G_program_id
       , SYSDATE
       , G_request_id
       , cu.ATTRIBUTE_CATEGORY
       , cu.ATTRIBUTE1
       , cu.ATTRIBUTE2
       , cu.ATTRIBUTE3
       , cu.ATTRIBUTE4
       , cu.ATTRIBUTE5
       , cu.ATTRIBUTE6
       , cu.ATTRIBUTE7
       , cu.ATTRIBUTE8
       , cu.ATTRIBUTE9
       , cu.ATTRIBUTE10
       , cu.ATTRIBUTE11
       , cu.ATTRIBUTE12
       , cu.ATTRIBUTE13
       , cu.ATTRIBUTE14
       , cu.ATTRIBUTE15
      FROM
        HZ_CREDIT_USAGES cu
    WHERE cu.PROFILE_CLASS_AMOUNT_ID = p_profile_class_amt_id ;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    X_return_status := 'U' ;

HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '<< cascade_credit_usage_rules' );

END cascade_credit_usage_rules ;

--========================================================================
-- PROCEDURE : Mass_Update_Usage_Rules  PUBLIC
-- PARAMETERS: p_profile_class_id     Profile Class ID
--             p_currency_code        Currency Code
--             p_profile_class_amount_id
--             x_errbuf               error buffer
--             x_retcode              0 success, 1 warning, 2 error
--
-- COMMENT   : This is the concurrent program for Mass update credit usages
--
--========================================================================
PROCEDURE Mass_Update_Usage_Rules
( p_profile_class_id  IN  NUMBER
, p_currency_code     IN  VARCHAR2
, p_profile_class_amount_id IN NUMBER
, x_errbuf            OUT NOCOPY VARCHAR2
, x_retcode           OUT NOCOPY VARCHAR2
)

IS
l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);
l_cust_count     NUMBER;
l_count          NUMBER;

CURSOR cust_prof_csr
( p_profile_class_id NUMBER
, p_currency_code    VARCHAR2
)
IS
SELECT cpa.cust_acct_profile_amt_id
,      cp.cust_account_profile_id
,      NVL(cp.site_use_id, cp.cust_account_id) entity_id
,      cp.cust_account_id
    ,  DECODE(cp.site_use_id,NULL,'CUSTOMER','SITE') entity_type
FROM   hz_cust_profile_amts cpa
,      hz_customer_profiles cp
WHERE  cp.cust_account_profile_id = cpa.cust_account_profile_id
  AND  cp.profile_class_id        = p_profile_class_id
  AND  cpa.currency_code          = NVL(p_currency_code,currency_code) ;



BEGIN
  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '>> Mass_Update_Usage_Rules' );

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
  , p_msg => '  Starting loop for customer profiles for
             p_profile_class_id='||TO_CHAR(p_profile_class_id)
             ||'p_currency_code='||p_currency_code
    );

  ----initilize count
  l_cust_count:=0;

  --Cascade insert usages for customer/site profiles
  FOR cust_prof_csr_rec IN cust_prof_csr( p_profile_class_id=> p_profile_class_id
                                        , p_currency_code   => p_currency_code)
  LOOP
    HZ_MGD_MASS_UPDATE_REP_GEN.log
    ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
    , p_msg => ' HZ_CREDIT_USAGES_CASCADE_PKG.Cascade_credit_usage_rules for
                 p_cust_acct_profile_amt_id='||TO_CHAR(cust_prof_csr_rec.cust_acct_profile_amt_id)
             ||' p_profile_class_amt_id='||TO_CHAR(p_profile_class_amount_id)
    );

  ------check if there are any credit check rule set assigned
  ------to the profile class
  SELECT
    COUNT(*)
  INTO
    l_count
  FROM HZ_CREDIT_USAGES
  WHERE profile_class_amount_id = p_profile_class_amount_id;

  IF l_count=0
  THEN
    -------cascade delete -------------------
    Delete_credit_usages
    (  p_cust_acct_profile_amt_id => cust_prof_csr_rec.cust_acct_profile_amt_id
     , X_return_status            => l_return_status
     , X_msg_count                => l_msg_count
     , X_msg_data                 => l_msg_data
    );

    COMMIT;

  ELSE
  --------continue cascade

    Cascade_credit_usage_rules
    ( p_cust_acct_profile_amt_id  => cust_prof_csr_rec.cust_acct_profile_amt_id
    , p_cust_profile_id           => NULL
    , p_profile_class_amt_id      => p_profile_class_amount_id
    , p_profile_class_id          => NULL
    , x_return_status             => l_return_status
    , x_msg_count                 => l_msg_count
    , x_msg_data                  => l_msg_data
    );

    IF l_return_status='S'
    THEN
      l_cust_count:=l_cust_count+1;
    END IF;

    COMMIT;

    END IF;

  END LOOP;

  HZ_MGD_MASS_UPDATE_REP_GEN.G_PROF_NUMBER:=l_cust_count;



  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_STATEMENT
  , p_msg => '  End loop for customer profiles ');

  HZ_MGD_MASS_UPDATE_REP_GEN.log
  ( p_priority => HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_PROCEDURE
  , p_msg => '<< Mass_Update_Usage_Rules' );


  EXCEPTION
  WHEN OTHERS THEN
    HZ_MGD_MASS_UPDATE_REP_GEN.Log( HZ_MGD_MASS_UPDATE_REP_GEN.G_LOG_EXCEPTION,'SQLERRM '|| SQLERRM) ;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, 'Mass_Update_Usage_Rules');
    END IF;

    x_retcode := 2;
    x_errbuf  := SUBSTRB(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE),1,255);
    ROLLBACK;
    RAISE;



END Mass_Update_Usage_Rules;


END HZ_MGD_MASS_UPDATE_MEDIATOR;

/
