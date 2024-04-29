--------------------------------------------------------
--  DDL for Package Body HZ_CREDIT_USAGES_CASCADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CREDIT_USAGES_CASCADE_PKG" AS
/* $Header: ARHCRCCB.pls 115.15 2003/03/15 03:51:18 vto noship $ */
--======================================================================
--CONSTANTS
--======================================================================
G_PKG_NAME CONSTANT VARCHAR2(30)    := 'HZ_CREDIT_USAGES_CASCADE_PKG' ;

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



---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------
--------------------------------------------------------------------
-- PROCEDURE cascade_credit_usage_rules
-- The procedure accepts two input parameters
-- a) p_cust_acct_profile_amt_id
--      This is the new customer / site profile amount id that is
--      being created
-- b) p_profile_class_amt_id
--      This is the profile class amt id from which the new
--   new customer / site profile amount id is created
--------------------------------------------------------------------
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
l_site_use_id           NUMBER;
l_party_id              NUMBER;
l_include_all           VARCHAR2(1);
l_duplicate             VARCHAR2(1);
l_duplicate_curr        VARCHAR2(30);


CURSOR rule_set_csr IS
SELECT
  cu.credit_usage_rule_set_id
, cr.global_exposure_flag
FROM HZ_CREDIT_USAGES cu
,    hz_credit_usage_rule_sets_b cr
WHERE cu.profile_class_amount_id = p_profile_class_amt_id
   AND cu.credit_usage_rule_set_id = cr.credit_usage_rule_set_id ;

RULE_SET_CSR_REC    rule_set_csr%ROWTYPE;

l_id                NUMBER;
l_global_exposure_flag VARCHAR2(1) ;

BEGIN
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

  BEGIN
    -- The following SELECT statement should be fixed as part of the
    -- fix to support cascading usage rules from profile class to party
    -- level credit profile.
    -- Note: the cascading procedure is called after the customer profile
    -- amount is created, and BEFORE the customer profile record is created.
    SELECT
      ca.cust_account_id
    , ca.site_use_id
    INTO
      l_cust_account_id
    , l_site_use_id
    FROM
      hz_cust_profile_amts ca
    WHERE ca.cust_acct_profile_amt_id = p_cust_acct_profile_amt_id;

    --Use the IDs to determine the entity.
    --Note that a party level profile will have a cust_account_id of -1
    --since cust_account_id is a NOT NULL column.

    IF l_site_use_id is not NULL
    THEN
      l_entity    := 'SITE' ;
      l_entity_id := l_site_use_id ;
    ELSE
      IF l_cust_account_id <> -1
      THEN
        l_entity := 'CUSTOMER';
        l_entity_id := l_cust_account_id ;
      ELSE
        -- Get party ID and set it as the entity ID
        BEGIN
          SELECT
            cp.cust_account_id
          , cp.site_use_id
          , cp.party_id
          INTO
            l_cust_account_id
          , l_site_use_id
          , l_party_id
          FROM
            hz_cust_profile_amts ca
          , hz_customer_profiles cp
          WHERE ca.cust_acct_profile_amt_id = p_cust_acct_profile_amt_id
          AND   ca.CUST_ACCOUNT_PROFILE_ID = cp.CUST_ACCOUNT_PROFILE_ID
          AND   cp.cust_account_id = -1;
          IF l_party_id is not NULL
          THEN
            l_entity    := 'PARTY' ;
            l_entity_id := l_party_id ;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_entity          := NULL;
            l_entity_id       := NULL;
            l_cust_account_id := NULL;
            l_site_use_id     := NULL;
            l_party_id        := NULL;
          WHEN TOO_MANY_ROWS THEN
            l_entity          := NULL;
            l_entity_id       := NULL;
            l_cust_account_id := NULL;
            l_site_use_id     := NULL;
            l_party_id        := NULL;
        END ;
      END IF;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_entity          := NULL;
      l_entity_id       := NULL;
      l_cust_account_id := NULL;
      l_site_use_id     := NULL;
      l_party_id        := NULL;

    WHEN TOO_MANY_ROWS THEN
      l_entity          := NULL;
      l_entity_id       := NULL;
      l_cust_account_id := NULL;
      l_site_use_id     := NULL;
      l_party_id        := NULL;
  END ;

  --DBMS_OUTPUT.PUT_LINE('l_entity = '|| l_entity );
  --DBMS_OUTPUT.PUT_LINE('l_entity_id '|| l_entity_id );
  --DBMS_OUTPUT.PUT_LINE('l_cust_account_id '|| l_cust_account_id );
  --DBMS_OUTPUT.PUT_LINE('l_include_all '|| l_include_all);

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
      WHEN NO_DATA_FOUND THEN
        l_include_all := 'N' ;

      WHEN TOO_MANY_ROWS THEN
        l_include_all := 'Y' ;
    END ;

    --DBMS_OUTPUT.PUT_LINE('Rule set ID = '||
    --                      rule_set_csr_rec.credit_usage_rule_set_id );

    IF l_entity = 'PARTY'
      AND NVL(rule_set_csr_rec.global_exposure_flag,'N')= 'N'
    THEN
      l_duplicate := 'Y' ;
    ELSE
      l_duplicate := NULL ;
      HZ_CREDIT_USAGES_CASCADE_PKG.Check_Duplicate_all
      ( p_rule_set_id             =>
                  rule_set_csr_rec.credit_usage_rule_set_id
      , p_entity                  => l_entity
      , p_entity_id               => l_entity_id
      , p_cust_account_id         => l_cust_account_id
      , p_include_all             => l_include_all
      , p_cust_acct_profile_amt_id => p_cust_acct_profile_amt_id
      , x_duplicate               => l_duplicate
      , x_dupl_curr               => l_duplicate_curr
      );
    END IF;

    IF l_duplicate = 'Y'
    THEN
      EXIT ;
    END IF;
  END LOOP; -- check duplicates

  --DBMS_OUTPUT.PUT_LINE('l_duplicate = '|| l_duplicate );

  IF   l_duplicate <> 'Y'
  THEN
    --DBMS_OUTPUT.PUT_LINE('Call delete_credit_usages ');

    HZ_CREDIT_USAGES_CASCADE_PKG.delete_credit_usages
    (  p_cust_acct_profile_amt_id => p_cust_acct_profile_amt_id
     , X_return_status            => X_return_status
     , X_msg_count                => X_msg_count
     , X_msg_data                 => X_msg_data
    );
  END IF;

  IF X_return_status = 'S'
     AND   l_duplicate <> 'Y'
  THEN
    --DBMS_OUTPUT.PUT_LINE('Delete SUCCESS, call INSERT ');

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
    )
    SELECT
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
END cascade_credit_usage_rules ;


-----------------------------------------------------------------
-- PROCEDURE: delete_credit_usages
-- COMMENTS: This procedure will accept the
--           cust_acct_profile_amt_id as input and
--           remove records from the multi currency credit checking
--           usages table HZ_CREDIT_USAGES for this ID
-----------------------------------------------------------------
PROCEDURE delete_credit_usages
( p_cust_acct_profile_amt_id IN NUMBER
, X_return_status            OUT NOCOPY VARCHAR2
, X_msg_count                OUT NOCOPY NUMBER
, X_msg_data                 OUT NOCOPY VARCHAR2
) IS

BEGIN
  -- Delete the Rule set assigned for a given
  -- profile amt id

  X_return_status := 'S' ;

  DELETE FROM
    HZ_CREDIT_USAGES
  WHERE CUST_ACCT_PROFILE_AMT_ID  =  p_cust_acct_profile_amt_id ;

EXCEPTION
  WHEN OTHERS THEN
    X_return_status := 'U' ;
END delete_credit_usages ;


-----------------------------------------------------------------
-- PROCEDURE: Check_Duplicate_all
-- COMMENTS:  This procedure will check the
--            duplication of currencies across  the
--            existing assigned rule sets with the
--            profile
-----------------------------------------------------------------
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
  FROM   HZ_CREDIT_USAGE_RULES
  WHERE  credit_usage_rule_set_id = p_rule_set_id
  AND    usage_type = 'CURRENCY'
  AND    NVL (include_all_flag, 'N') = 'N'
  AND    NVL(exclude_flag,'N') = 'N' ;


  --------------------
  -- SITE ---
  ---------------------

CURSOR site_check_case1_no_incl_csr IS
  SELECT  cu.credit_usage_id
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

-------------------------- party ------------------------------
CURSOR party_check_case1_no_incl_csr IS
 SELECT   cu.credit_usage_id
 ,       substrb(cur.user_code,1,5)  curr
 ,       cpa.currency_code prof_curr
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = -1
  AND    cp.site_use_id               IS NULL
  AND    cp.party_id                  = p_entity_id
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

  party_check_case1_no_incl_rec  party_check_case1_no_incl_csr%ROWTYPE ;


CURSOR party_check_case1_incl_csr ( p_curr_code IN VARCHAR2 ) IS
SELECT   cpa.currency_code profile_curr
  ,      cu.credit_usage_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = -1
  AND    cp.site_use_id               IS NULL
  AND    cp.party_id                  = p_entity_id
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
  WHERE  cp.cust_account_id           = -1
  AND    cp.site_use_id               IS NULL
  AND    cp.party_id                  = p_entity_id
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
  WHERE  cp.cust_account_id           = -1
  AND    cp.site_use_id               IS NULL
  AND    cp.party_id                  = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.cust_acct_profile_amt_id <> l_cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date), TRUNC(SYSDATE)
            )    <= TRUNC(SYSDATE)
  AND   NVL (cur.include_all_flag, 'N') = 'Y' ;


  party_check_case2_incl_rec  party_check_case2_incl_csr%ROWTYPE ;

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

          --FND_MESSAGE.DEBUG(' site - 1 ');
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

           --FND_MESSAGE.DEBUG(' l_usage_curr = '|| l_usage_curr);

           OPEN site_check_case1_incl_csr  ( l_usage_curr );
           FETCH site_check_case1_incl_csr
           INTO  site_check_case1_incl_rec ;

           IF site_check_case1_incl_csr%NOTFOUND
           THEN
             x_duplicate := 'N' ;
             x_dupl_curr := NULL ;

            --FND_MESSAGE.DEBUG(' site - 2 no found');

           ELSE
              x_duplicate := 'Y' ;
              x_dupl_curr := l_usage_curr ;

              CLOSE site_check_case1_incl_csr ;

            --FND_MESSAGE.DEBUG(' site - 2 ');

             EXIT ;

           END IF;

           CLOSE site_check_case1_incl_csr ;

         END LOOP;
         CLOSE SELECT_USAGE_CURR_CSR ;
         --FND_MESSAGE.DEBUG(' site - 2 - Out of LOOP ');

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

           --FND_MESSAGE.DEBUG(' site - 3 no found');

          ELSE

            x_duplicate := 'Y' ;
            x_dupl_curr := site_check_case2_no_incl_rec.curr ;

            --FND_MESSAGE.DEBUG(' site - 3 ');

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

             --FND_MESSAGE.DEBUG(' site - 4 no found');

           ELSE
             x_duplicate := 'Y' ;
             x_dupl_curr := 'ALL Currency' ;
             --FND_MESSAGE.DEBUG(' site - 4 ');
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

------------------- party ---------------------------

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
        --FND_MESSAGE.DEBUG(' CUST - 1 no found');

       ELSE
          x_duplicate := 'Y' ;
          x_dupl_curr := party_check_case1_no_incl_rec.curr ;

          --FND_MESSAGE.DEBUG(' CUST - 1 ');
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

          --FND_MESSAGE.DEBUG(' CUST - 2 no found');

         ELSE

            x_duplicate := 'Y' ;
            x_dupl_curr := l_usage_curr ;

            CLOSE party_check_case1_incl_csr ;

           --FND_MESSAGE.DEBUG(' CUST - 2 ');

           EXIT ;

         END IF;

         CLOSE party_check_case1_incl_csr ;

        END LOOP;
        CLOSE SELECT_USAGE_CURR_CSR ;
        --FND_MESSAGE.DEBUG(' CUST - 2 - Out of LOOP ');

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

           --FND_MESSAGE.DEBUG(' CUST - 3 no found');

          ELSE

          x_duplicate := 'Y' ;
          x_dupl_curr := party_check_case2_no_incl_rec.curr ;

          --FND_MESSAGE.DEBUG(' CUST - 3 ');

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

             --FND_MESSAGE.DEBUG(' CUST - 4 no found');

          ELSE
             x_duplicate := 'Y' ;
             x_dupl_curr := 'ALL Currency' ;
             --FND_MESSAGE.DEBUG(' CUST - 4 ');
          END IF;

          CLOSE party_check_case2_incl_csr ;

         END IF;
       END IF; -- case2

     END ;

     --------------- End party --------------------------------
  ELSE
    x_duplicate := 'Y' ;
     x_dupl_curr := 'INVALID ENTITY' ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  RAISE ;
END Check_Duplicate_all ;




END HZ_CREDIT_USAGES_CASCADE_PKG ;

/
