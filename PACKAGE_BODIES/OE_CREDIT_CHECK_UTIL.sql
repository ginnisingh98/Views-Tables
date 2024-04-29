--------------------------------------------------------
--  DDL for Package Body OE_CREDIT_CHECK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREDIT_CHECK_UTIL" AS
-- $Header: OEXUCRCB.pls 120.17.12010000.12 2012/01/01 18:35:52 slagiset ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXUCRCB.pls                                                       |
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
--|     Oct-30-2001 current order exposure global                         |
--|     FEB-06-2002 Multi org changes                                     |
--|     Feb-13-2002 Check External Credit API changes                     |
--|                 Added Get_external_trx_amount                         |
--|     Feb-20-2002 changed Get_Credit_Check_Rule for Manual Release Holds|
--|     Mar-15-2002 Modify get_order_exposure for external exposure.      |
--|     Mar-19-2002 Modify get_credit_check_rule to add new exposure col. |
--|     Mar-28-2002 add the changes for the BUG 2236276                   |
--|     Apr-17-2002 Bug 2328351                                           |
--|     Apr-30-2002 BUG 2352020                                           |
--|     Jun-17-2002 rajkrish 2pm Bug2417717                               |
--|     Jun-18-2002 rajkrish 2412678                                      |
--|     Aug-XX-2002          BUG2408466                                   |
--|     Sep-18-2002          5PM OM-I                                     |
--|     Nov-11-2002                                                       |
--|     Mar-31-2003 vto bug 2846473,2878410. Modified SEND_CREDIT_HLD_NTF |
--|     Apr-24-2003 vto bug 2921490.Performance fix for get_order_exposure|
--|                         2925739.                                      |
--|     May-27-2003 rajkrish BUG 2886786                                  |
--|     Jul-16-2003 tsimmond added code to Get_order_exposure and to      |
--|                         Get_Transaction_Amount for Returns FPJ project|
--|     Aug-11-2003 vto      Changed to remove NVL as much as possible:   |
--|                          Get_Order_Exposure.                          |
--|                          Also removed current order cursors from the  |
--|                          get_order_exposure.  They are ont used.      |
--|                          Modified get prepayments sql                 |
--|     Jan-15-2004 vto      3364726. Check G_crmgmt_installed directly   |
--|                          instead of = TRUE. Removed some unnec NVLs   |
--|     Jan-16-2004 tsimmond Bug fix #3377881. In get_transaction_amount  |
--|                          for order level credit check  in sql statmnts|
--|                       added join between ra_terms_b and oe_order_lines|
--|                       t.term_id = l.payment_term_id                   |
--|     Jan-21-2004 vto      3388857. Current order should not be limited |
--|                          by shipping horizon.                         |
--|     Feb-05-2004 vto      3426436: Fix 3377881 as it is complete.      |
--|                          Added check for t.credit_check_flag=Y also   |
--|     Feb-25-2004 vto      3449827,3463348: get_order_exposure details  |
--|     Jul-27-2004 vto      3818562. Add NVL on h.request_date           |
--+=======================================================================+

--------------------
-- TYPE DECLARATIONS
--------------------
TYPE category_tmp_rec IS RECORD
 ( item_category_id NUMBER
 , profile_exist    VARCHAR2(1)
 );


TYPE category_tmp_tbl_type  IS TABLE OF category_tmp_rec
     INDEX BY BINARY_INTEGER;

------------
-- CONSTANTS
------------
G_PKG_NAME CONSTANT VARCHAR2(30)   := 'OE_CREDIT_CHECK_UTIL';
G_DBG_MSG           VARCHAR2(200)  := NULL;
/* Start MOAC CREDIT CHECK CHANGE */
--G_ORG_ID            NUMBER         :=
--       NVL(TO_NUMBER(FND_PROFILE.value('ORG_ID')), -99);
/* End MOAC CREDIT CHECK CHANGE */
G_debug_flag        VARCHAR2(1)    :=
       NVL( OE_CREDIT_CHECK_UTIL.check_debug_flag ,'N') ;
G_MULTIPLE_PAYMENTS_ENABLED BOOLEAN :=
       OE_PrePayment_Util.IS_MULTIPLE_PAYMENTS_ENABLED;

-------------------
-- PUBLIC GLOBAL VARIABLES
-------------------
G_category_set_id NUMBER ;
G_is_external_check BOOLEAN := FALSE;

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

FUNCTION check_debug_flag
RETURN VARCHAR2
IS
BEGIN
  IF oe_debug_pub.g_debug_level > 0
  THEN
    RETURN('Y');
  ELSE
    RETURN('N') ;
  END IF;
END check_debug_flag ;

FUNCTION Check_drawee_exists
( p_cust_account_id IN NUMBER )
RETURN VARCHAR2
IS
 CURSOR
  drawee_exists_C IS
  SELECT su.site_use_id
  FROM   hz_cust_site_uses su ,
         hz_cust_acct_sites_all cas
  WHERE  cas.cust_account_id  = p_cust_account_id
    AND  su.site_use_code     = 'DRAWEE'
    AND  su.cust_acct_site_id = cas.cust_acct_site_id ;  /* MOAC_SQL_CHANGE */

  l_exists VARCHAR2(1) := 'N' ;
  l_id     NUMBER ;
BEGIN
 IF G_debug_flag = 'Y'
 THEN
    OE_DEBUG_PUB.Add(' Into Check_drawee_exists ');
 END IF;

 OPEN drawee_exists_C ;
 FETCH drawee_exists_C INTO l_id ;

 IF l_id is not NULL
 THEN
   l_exists := 'Y' ;
 ELSE
  l_exists := 'N' ;
 END IF;

 IF drawee_exists_C%NOTFOUND
 THEN
   l_exists := 'N' ;
   l_id := NULL ;
 END IF;

 CLOSE drawee_exists_C ;

 return(NVL(l_exists,'N')) ;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_drawee_exists'
            );
      END IF;
END Check_drawee_exists ;

----------------------------------------------------
--- get_drawee_site_use_id
--- return the BR purpose drawee site use id
-----------------------------------------------------
FUNCTION get_drawee_site_use_id
( p_site_use_id         IN NUMBER
) RETURN NUMBER
IS

l_site_use_id       NUMBER ;
l_cust_acct_site_id NUMBER;
BEGIN

 IF G_debug_flag = 'Y'
 THEN
    oe_debug_pub.add('get_drawee_site_use_id ');
  END IF;

 BEGIN
  SELECT cust_acct_site_id
   INTO  l_cust_acct_site_id
  FROM  hz_cust_site_uses su
  WHERE su.site_use_id  = p_site_use_id ;

  SELECT su.site_use_id
  INTO   l_site_use_id
  FROM   hz_cust_acct_sites cas
      , hz_cust_site_uses_all su
  WHERE cas.cust_acct_site_id = su.cust_acct_site_id
    AND su.cust_acct_site_id  = l_cust_acct_site_id
    AND su.site_use_code      = 'DRAWEE' ;            /* MOAC_SQL_CHANGE */

   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      l_site_use_id := NULL ;


      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add(' No Data found for BR in get_drawee_site_use_id ');
      END IF;

   WHEN TOO_MANY_ROWS
   THEN
      l_site_use_id := NULL ;

      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add(' TOO_MANY_ROWS BR in get_drawee_site_use_id ');
      END IF;
  END ;
 return ( l_site_use_id );

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'get_drawee_site_use_id'
            );
      END IF;

END get_drawee_site_use_id ;


--------------------------------------------------------------------
--FUNCTION: GET_hierarchy_party_limit
--COMMENTS:  Returns the party level credit profile
----------------------------------------------------------------------
PROCEDURE GET_hierarchy_party_limit
( p_party_id                IN NUMBER
, p_trx_curr_code           IN VARCHAR2
, x_limit_curr_code        OUT NOCOPY VARCHAR2
, x_trx_limit              OUT NOCOPY NUMBER
, x_overall_limit          OUT NOCOPY NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
, x_credit_limit_entity_id OUT NOCOPY NUMBER
)
IS

CURSOR party_hier_limit_no_incl_csr IS
  SELECT cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking credit_checking --bug 4967828
  ,      cu.credit_usage_rule_set_id
  ,      cp.party_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  ,      hz_hierarchy_nodes           hn
  WHERE  cp.party_id                  = hn.parent_id
  AND    cp.cust_account_id           = -1
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type                  = 'CURRENCY'
  AND     cur.user_code                   = p_trx_curr_code
  AND     NVL(cur.exclude_flag,'N')       = 'N'
--  AND     NVL(cp.credit_checking,'Y')     = 'Y'  --bug 4967828
  AND     hn.child_id                     = p_party_id
  AND     hn.parent_object_type           = 'ORGANIZATION'
  and     hn.parent_table_name            = 'HZ_PARTIES'
  and     hn.child_object_type            = 'ORGANIZATION'
  and     hn.effective_start_date    <=  sysdate
  and     hn.effective_end_date      >= SYSDATE
  and     hn.hierarchy_type           = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  ORDER BY hn.LEVEL_NUMBER DESC ;


  party_hier_limit_no_incl_rec   party_hier_limit_no_incl_csr%ROWTYPE ;

CURSOR party_hier_limit_incl_csr IS
  SELECT cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking credit_checking --bug 4967828
  ,      cu.credit_usage_rule_set_id
  ,      cp.party_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  ,      hz_hierarchy_nodes           hn
  WHERE  cp.party_id                  = hn.parent_id
  AND    cp.cust_account_id           = -1
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND    cur.include_all_flag = 'Y'
  AND    NOT EXISTS ( SELECT 'EXCLUDE'
                      FROM   hz_credit_usage_rules cur2
                      WHERE  cu.credit_usage_rule_set_id
                             = cur2.credit_usage_rule_set_id
                      AND    cur2.exclude_flag = 'Y'
                      AND    cur2.usage_type  = 'CURRENCY'
                      AND    cur2.user_code   = p_trx_curr_code
                    )
--  AND  NVL(cp.credit_checking,'Y')    = 'Y'  --bug 4967828
  AND hn.child_id                     = p_party_id
  AND hn.parent_object_type           = 'ORGANIZATION'
  and hn.parent_table_name            = 'HZ_PARTIES'
  and hn.child_object_type            = 'ORGANIZATION'
  and hn.effective_start_date  <=  sysdate
  and hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type              = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  ORDER BY hn.LEVEL_NUMBER DESC ;

party_hier_limit_incl_rec party_hier_limit_incl_csr%ROWTYPE ;

CURSOR party_hier_single_limit_csr IS
  SELECT cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100+nvl(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100+nvl(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking credit_checking  --bug 4967828
  ,      cp.party_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_hierarchy_nodes           hn
  WHERE  cp.party_id                  = hn.parent_id
  AND    cp.cust_account_id           = -1
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.currency_code            = p_trx_curr_code
--  AND    cp.credit_checking          = 'Y'  --bug 4967828
  AND  hn.child_id                     = p_party_id
  AND hn.parent_object_type           = 'ORGANIZATION'
  and hn.parent_table_name            = 'HZ_PARTIES'
  and hn.child_object_type            = 'ORGANIZATION'
  and hn.effective_start_date
          <= sysdate
  and hn.effective_end_date
    >= SYSDATE
  and  hn.hierarchy_type              = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  ORDER BY hn.LEVEL_NUMBER DESC ;


  party_hier_single_limit_rec  party_hier_single_limit_csr%ROWTYPE ;

BEGIN

 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.ADD('IN GET_hierarchy_party_limit');
   OE_DEBUG_PUB.ADD('p_party_id ==> '|| p_party_id );
   OE_DEBUG_PUB.ADD('p_trx_curr_code ==> '|| p_trx_curr_code );
   OE_DEBUG_PUB.ADD('party_hier_limit_no_incl_csr ');
 END IF;

  OPEN party_hier_limit_no_incl_csr ;
  FETCH party_hier_limit_no_incl_csr
  INTO  party_hier_limit_no_incl_rec ;

  IF party_hier_limit_no_incl_csr%NOTFOUND
  THEN
     x_return_status := NULL;  --bug 4967828
  ELSIF party_hier_limit_no_incl_rec.credit_checking = 'N'
  THEN
     x_credit_limit_entity_id := NULL ;
     x_return_status := 'N' ;
  ELSE
    x_limit_curr_code := party_hier_limit_no_incl_rec.currency_code;
    x_overall_limit   := party_hier_limit_no_incl_rec.overall_limit;
    x_trx_limit       := party_hier_limit_no_incl_rec.trx_limit;
    x_credit_limit_entity_id :=
          party_hier_limit_no_incl_rec.party_id ;
    x_return_status   := 'Y' ;
  END IF;

  CLOSE party_hier_limit_no_incl_csr ;


  IF x_limit_curr_code IS NULL
  THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('party_hier_limit_incl_csr ');
    END IF;

    OPEN party_hier_limit_incl_csr ;
    FETCH party_hier_limit_incl_csr
    INTO  party_hier_limit_incl_rec ;

    IF party_hier_limit_incl_csr%NOTFOUND
    THEN
     x_return_status := NULL;  --bug 4967828
    ELSIF party_hier_limit_incl_rec.credit_checking = 'N'
    THEN
     x_credit_limit_entity_id := NULL ;
     x_return_status := 'N' ;
    ELSE
      x_limit_curr_code := party_hier_limit_incl_rec.currency_code;
      x_overall_limit   := party_hier_limit_incl_rec.overall_limit;
      x_trx_limit       := party_hier_limit_incl_rec.trx_limit;
      x_credit_limit_entity_id :=
          party_hier_limit_incl_rec.party_id ;
      x_return_status   := 'Y' ;
    END IF;

    CLOSE party_hier_limit_incl_csr ;
  END IF;

  IF x_limit_curr_code IS NULL
  THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('party_hier_single_limit_csr');
    END IF;

    OPEN party_hier_single_limit_csr ;
    FETCH party_hier_single_limit_csr
    INTO  party_hier_single_limit_rec ;

    IF party_hier_single_limit_csr%NOTFOUND
    THEN
     x_return_status := NULL;  --bug 4967828
    ELSIF party_hier_single_limit_rec.credit_checking = 'N'
    THEN
     x_credit_limit_entity_id := NULL ;
     x_return_status := 'N' ;
    ELSE
      x_limit_curr_code := party_hier_single_limit_rec.currency_code;
      x_overall_limit   := party_hier_single_limit_rec.overall_limit;
      x_trx_limit       := party_hier_single_limit_rec.trx_limit;
      x_credit_limit_entity_id :=
          party_hier_single_limit_rec.party_id ;
      x_return_status   := 'Y' ;
    END IF;

    CLOSE party_hier_single_limit_csr ;
  END IF;

 IF G_debug_flag = 'Y'
 THEN

   OE_DEBUG_PUB.ADD('OUT GET_hierarchy_party_limit' );
 END IF;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'GET_hierarchy_party_limit'
            );
      END IF;


END GET_hierarchy_party_limit ;

--------------------------------------------------------------------
--FUNCTION: GET_single_party_limit
--COMMENTS:  Returns the party level credit profile
----------------------------------------------------------------------
PROCEDURE GET_single_party_limit
( p_party_id                IN NUMBER
, p_trx_curr_code           IN VARCHAR2
, x_limit_curr_code        OUT NOCOPY VARCHAR2
, x_trx_limit              OUT NOCOPY NUMBER
, x_overall_limit          OUT NOCOPY NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
, x_credit_limit_entity_id OUT NOCOPY NUMBER
)
IS
CURSOR party_single_limit_csr IS
  SELECT cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100+nvl(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100+nvl(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking credit_checking  --bug 4967828
  ,      cp.party_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  WHERE  cp.cust_account_id           = -1
  AND    cp.site_use_id              IS NULL
  AND    cp.party_id                  = p_party_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.currency_code            = p_trx_curr_code ;  --bug 4967828
--  AND    NVL(cp.credit_checking,'Y')  = 'Y' ;

  party_single_limit_rec  party_single_limit_csr%ROWTYPE ;

BEGIN

 IF G_debug_flag = 'Y'
 THEN

   OE_DEBUG_PUB.ADD('IN GET_single_party_limit');
   OE_DEBUG_PUB.ADD('p_party_id ==> '|| p_party_id );
   OE_DEBUG_PUB.ADD('p_trx_curr_code ==> '|| p_trx_curr_code );
   OE_DEBUG_PUB.ADD(' party_single_limit_csr ');
 END IF;

  OPEN party_single_limit_csr ;
  FETCH party_single_limit_csr
  INTO  party_single_limit_rec ;

  IF party_single_limit_csr%NOTFOUND
  THEN
     x_return_status := NULL;  --bug 4967828
  ELSIF party_single_limit_rec.credit_checking = 'N'
  THEN
     x_credit_limit_entity_id := NULL ;
     x_return_status := 'N' ;
  ELSE
    x_limit_curr_code := party_single_limit_rec.currency_code;
    x_overall_limit   := party_single_limit_rec.overall_limit;
    x_trx_limit       := party_single_limit_rec.trx_limit;
    x_credit_limit_entity_id :=
          party_single_limit_rec.party_id ;
    x_return_status   := 'Y' ;
  END IF;

  CLOSE party_single_limit_csr ;


 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.ADD('OUT GET_single_party_limit' );
 END IF;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'GET_single_party_limit'
            );
      END IF;


END GET_single_party_limit ;

--------------------------------------------------------------------
--FUNCTION: GET_multi_party_limit
--COMMENTS:  Returns the party level credit profile
----------------------------------------------------------------------
PROCEDURE GET_multi_party_limit
( p_party_id                IN NUMBER
, p_trx_curr_code           IN VARCHAR2
, x_limit_curr_code        OUT NOCOPY VARCHAR2
, x_trx_limit              OUT NOCOPY NUMBER
, x_overall_limit          OUT NOCOPY NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
, x_credit_limit_entity_id OUT NOCOPY NUMBER
)
IS
CURSOR party_multi_limit_no_incl_csr IS
  SELECT cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking credit_checking  --bug 4967828
  ,      cu.credit_usage_rule_set_id
  ,      cp.party_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = -1
  AND    cp.site_use_id               IS NULL
  AND    cp.party_id                  = p_party_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type                  = 'CURRENCY'
  AND     cur.user_code                   = p_trx_curr_code
  AND     NVL(cur.exclude_flag,'N')       = 'N' ;  --bug 4967828
--  AND     NVL(cp.credit_checking,'Y')     = 'Y' ;


  party_multi_limit_no_incl_rec   party_multi_limit_no_incl_csr%ROWTYPE ;



 CURSOR party_multi_limit_incl_csr IS
  SELECT cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking credit_checking  --bug 4967828
  ,      cu.credit_usage_rule_set_id
  ,      cp.party_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = -1
  AND    cp.site_use_id               IS NULL
  AND    cp.party_id                   = p_party_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date), TRUNC(SYSDATE)
            )    <= TRUNC(SYSDATE)
  AND    cur.include_all_flag = 'Y'
--  AND    NVL(cp.credit_checking,'Y')     = 'Y'  --bug 4967828
  AND    NOT EXISTS ( SELECT 'EXCLUDE'
                      FROM   hz_credit_usage_rules cur2
                      WHERE  cu.credit_usage_rule_set_id
                             = cur2.credit_usage_rule_set_id
                      AND    cur2.exclude_flag = 'Y'
                      AND    cur2.usage_type  = 'CURRENCY'
                      AND    cur2.user_code   = p_trx_curr_code
                    );


  party_multi_limit_incl_rec party_multi_limit_incl_csr%ROWTYPE ;


BEGIN
 IF G_debug_flag = 'Y'
 THEN

   OE_DEBUG_PUB.ADD('IN GET_multi_party_limit ');
   OE_DEBUG_PUB.ADD('p_party_id ==> '|| p_party_id );
   OE_DEBUG_PUB.ADD('p_trx_curr_code ==> '|| p_trx_curr_code );
   OE_DEBUG_PUB.ADD('party_multi_limit_no_incl_csr ');
 END IF;

  OPEN party_multi_limit_no_incl_csr ;
  FETCH party_multi_limit_no_incl_csr
  INTO  party_multi_limit_no_incl_rec ;

  IF party_multi_limit_no_incl_csr%NOTFOUND
  THEN
     x_return_status := NULL;  --bug 4967828
  ELSIF party_multi_limit_no_incl_rec.credit_checking = 'N'
  THEN
     x_credit_limit_entity_id := NULL ;
     x_return_status := 'N' ;
  ELSE
    x_limit_curr_code := party_multi_limit_no_incl_rec.currency_code;
    x_overall_limit   := party_multi_limit_no_incl_rec.overall_limit;
    x_trx_limit       := party_multi_limit_no_incl_rec.trx_limit;
    x_credit_limit_entity_id :=
          party_multi_limit_no_incl_rec.party_id ;
    x_return_status   := 'Y' ;
  END IF;

  CLOSE party_multi_limit_no_incl_csr ;


  IF x_limit_curr_code IS NULL
  THEN
   IF G_debug_flag = 'Y'
   THEN
     OE_DEBUG_PUB.ADD('party_multi_limit_incl_csr ');
   END IF;

    OPEN party_multi_limit_incl_csr ;
    FETCH party_multi_limit_incl_csr
    INTO  party_multi_limit_incl_rec ;

    IF party_multi_limit_incl_csr%NOTFOUND
    THEN
     x_return_status := NULL;  --bug 4967828
    ELSIF party_multi_limit_incl_rec.credit_checking = 'N'
    THEN
     x_credit_limit_entity_id := NULL ;
     x_return_status := 'N' ;
    ELSE
      x_limit_curr_code := party_multi_limit_incl_rec.currency_code;
      x_overall_limit   := party_multi_limit_incl_rec.overall_limit;
      x_trx_limit       := party_multi_limit_incl_rec.trx_limit;
      x_credit_limit_entity_id :=
          party_multi_limit_incl_rec.party_id ;
      x_return_status   := 'Y' ;
    END IF;

  END IF;

 IF G_debug_flag = 'Y'
 THEN

   OE_DEBUG_PUB.ADD('OUT GET_multi_party_limit ');
 END IF;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'GET_multi_party_limit'
            );
      END IF;


END GET_multi_party_limit ;

--------------------------------------------------------------------
--FUNCTION: GET_party_limit
--COMMENTS:  Returns the party level credit profile
----------------------------------------------------------------------
PROCEDURE GET_party_limit
( p_party_id                IN NUMBER
, p_trx_curr_code           IN VARCHAR2
, x_limit_curr_code        OUT NOCOPY VARCHAR2
, x_trx_limit              OUT NOCOPY NUMBER
, x_overall_limit          OUT NOCOPY NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
, x_credit_limit_entity_id OUT NOCOPY NUMBER
)
IS
l_return_status            VARCHAR2(1);  --bug 4967828
BEGIN
 IF G_debug_flag = 'Y'
 THEN

   OE_DEBUG_PUB.ADD('IN GET_party_limit ');
   OE_DEBUG_PUB.ADD('p_party_id ==> '|| p_party_id );
   OE_DEBUG_PUB.ADD('p_trx_curr_code ==> '|| p_trx_curr_code );
 END IF;

   x_return_status   := 'N' ;
   x_limit_curr_code := NULL;
   x_trx_limit       := NULL ;
   x_overall_limit   := NULL ;

  BEGIN
     GET_multi_party_limit
     ( p_party_id               => p_party_id
     , p_trx_curr_code          => p_trx_curr_code
     , x_limit_curr_code        => x_limit_curr_code
     , x_trx_limit              => x_trx_limit
     , x_overall_limit          => x_overall_limit
     , x_return_status          => l_return_status  --bug 4967828
     , x_credit_limit_entity_id  => x_credit_limit_entity_id
     );

    --Bug 4561384
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' Out GET_multi_party_Limit '|| l_return_status );  --bug 4967828
      OE_DEBUG_PUB.ADD(' x_limit_curr_code = '|| x_limit_curr_code );
      OE_DEBUG_PUB.ADD(' x_trx_limit = '|| x_trx_limit );
      OE_DEBUG_PUB.ADD(' x_overall_limit = '|| x_overall_limit );
    END IF;

    x_return_status := NVL(l_return_status, 'N');  --bug 4967828
    IF l_return_status = 'Y'
       AND x_trx_limit is NULL
       AND x_overall_limit is NULL
    THEN
      l_return_status   := 'N' ;  --bug 4967828
      x_limit_curr_code := NULL ;
      OE_DEBUG_PUB.ADD(' Limits NULL for party MULTI ');
    END IF;
    --Bug 4561384

    IF NVL(l_return_status, 'N') = 'N'  --bug 4967828
    THEN
      GET_single_party_limit
      ( p_party_id               => p_party_id
      , p_trx_curr_code          => p_trx_curr_code
      , x_limit_curr_code        => x_limit_curr_code
      , x_trx_limit              => x_trx_limit
      , x_overall_limit          => x_overall_limit
      , x_return_status          => l_return_status  --bug 4967828
      , x_credit_limit_entity_id  => x_credit_limit_entity_id
      );

      --Bug 4561384
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD(' Out GET_single_party_Limit '|| l_return_status );  --bug 4967828
        OE_DEBUG_PUB.ADD(' x_limit_curr_code = '|| x_limit_curr_code );
        OE_DEBUG_PUB.ADD(' x_trx_limit = '|| x_trx_limit );
        OE_DEBUG_PUB.ADD(' x_overall_limit = '|| x_overall_limit );
      END IF;

      x_return_status := NVL(l_return_status, 'N');  --bug 4967828
      IF l_return_status = 'Y'
         AND x_trx_limit is NULL
         AND x_overall_limit is NULL
      THEN
        l_return_status   := 'N' ;  --bug 4967828
        x_limit_curr_code := NULL ;
        OE_DEBUG_PUB.ADD(' Limits NULL for party SITE ');
      END IF;
    END IF;
      --Bug 4561384

      OE_DEBUG_PUB.ADD('l_return_status '|| l_return_status );  --bug 4967828
      OE_DEBUG_PUB.ADD('x_return_status '|| x_return_status );

      IF NVL(l_return_status, 'N') = 'N'  --bug 4967828
      THEN
        GET_hierarchy_party_limit
        ( p_party_id               => p_party_id
        , p_trx_curr_code          => p_trx_curr_code
        , x_limit_curr_code        => x_limit_curr_code
        , x_trx_limit              => x_trx_limit
        , x_overall_limit          => x_overall_limit
        , x_return_status          => l_return_status  --bug 4967828
        , x_credit_limit_entity_id  => x_credit_limit_entity_id
        );

      --Bug 4561384
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD(' Out GET_hierarchy_party_Limit '|| l_return_status );  --bug 4967828
        OE_DEBUG_PUB.ADD(' x_limit_curr_code = '|| x_limit_curr_code );
        OE_DEBUG_PUB.ADD(' x_trx_limit = '|| x_trx_limit );
        OE_DEBUG_PUB.ADD(' x_overall_limit = '|| x_overall_limit );
      END IF;

      x_return_status := NVL(l_return_status,'Y') ;  --bug 4967828
      IF l_return_status = 'Y'
         AND x_trx_limit is NULL
         AND x_overall_limit is NULL
      THEN
        l_return_status   := 'N' ;  --bug 4967828
        x_limit_curr_code := NULL ;
        OE_DEBUG_PUB.ADD(' Limits NULL for party HIERARCHY ');
      END IF;
      --Bug 4561384

      END IF; -- hierarchy

--    END IF; -- single party   -- Commented for bug 4561384

   END ;

 IF G_debug_flag = 'Y'
 THEN

   OE_DEBUG_PUB.ADD('x_credit_limit_party ==> '|| x_credit_limit_entity_id );
   OE_DEBUG_PUB.ADD('x_limit_curr_code ==> '|| x_limit_curr_code );
   OE_DEBUG_PUB.ADD('x_trx_limit ==> '|| x_trx_limit );
   OE_DEBUG_PUB.ADD('x_overall_limit ==> '|| x_overall_limit );
   OE_DEBUG_PUB.ADD('x_return_status ==> '|| x_return_status );
   OE_DEBUG_PUB.ADD('OUT GET_party_limit ');
 END IF;

EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'GET_party_limit'
            );
      END IF;


END GET_party_limit ;



--------------------------------------------------------------------
--FUNCTION: Get_global_exposure_flag
--COMMENTS: Returns the global exposure flag for a given
--          entity ID and limit currency
--          used by the credit exposure report
--          Multi org enhancement
--          Entity type is accepted but not used for validation
--------------------------------------------------------------------
FUNCTION Get_global_exposure_flag
(  p_entity_type                 IN VARCHAR2
 , p_entity_id                   IN  NUMBER
 , p_limit_curr_code             IN  VARCHAR2
) RETURN VARCHAR2
IS

CURSOR cust_global_exposure_csr IS
  SELECT NVL(curs.global_exposure_flag,'N') global_exposure_flag
  ,      curs.credit_usage_rule_set_id  credit_usage_rule_set_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rule_sets_B  curs
  WHERE  cp.cust_account_id           = p_entity_id
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cpa.currency_code            = p_limit_curr_code
  AND    curs.credit_usage_rule_set_id = cu.credit_usage_rule_set_id
  AND    curs.global_exposure_flag = 'Y' ;

  cust_global_exposure_rec cust_global_exposure_csr%ROWTYPE ;


CURSOR dflt_global_exposure_csr IS
  SELECT NVL(curs.global_exposure_flag,'N') global_exposure_flag
  ,      curs.credit_usage_rule_set_id  credit_usage_rule_set_id
  FROM   hz_credit_profiles           cp
  ,      hz_credit_profile_amts       cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rule_sets_B  curs
  WHERE  cp.organization_id           = p_entity_id
  AND    cp.credit_profile_id         = cpa.credit_profile_id
  AND    cpa.credit_profile_amt_id    = cu.credit_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = curs.credit_usage_rule_set_id
  AND    cp.enable_flag               = 'Y'
  AND    curs.global_exposure_flag    = 'Y'
  AND    cpa.currency_code            = p_limit_curr_code
  AND    ( TRUNC(SYSDATE)   BETWEEN
               TRUNC( NVL(cp.effective_date_from, SYSDATE ))
                  AND
               TRUNC( NVL(cp.effective_date_to, SYSDATE ) )
         );

  dflt_global_exposure_rec dflt_global_exposure_csr%ROWTYPE ;

  l_global_exposure_flag VARCHAR2(1);
BEGIN
 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.ADD('IN Get_global_exposure_flag ');
 END IF;

  l_global_exposure_flag := 'N' ;

  IF p_entity_type = 'CUSTOMER'
  THEN

    OPEN cust_global_exposure_csr ;
    FETCH cust_global_exposure_csr
    INTO  cust_global_exposure_rec ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD( ' credit_usage_rule_set_id => '
               || cust_global_exposure_rec.credit_usage_rule_set_id);
    OE_DEBUG_PUB.ADD( ' global_exposure_flag => '
                  || cust_global_exposure_rec.global_exposure_flag);
  END IF;

    l_global_exposure_flag :=
        cust_global_exposure_rec.global_exposure_flag;

    IF cust_global_exposure_csr%NOTFOUND
    THEN
      l_global_exposure_flag := 'N' ;

      IF G_debug_flag = 'Y'
      THEN
       OE_DEBUG_PUB.ADD( ' cust_global_exposure_csr NO FOUND ');
      END IF;

    END IF;

    CLOSE cust_global_exposure_csr ;

  ELSIF p_entity_type = 'DEFAULT'
  THEN
    OPEN dflt_global_exposure_csr ;
    FETCH dflt_global_exposure_csr
    INTO  dflt_global_exposure_rec ;

    IF G_debug_flag = 'Y'
    THEN

     OE_DEBUG_PUB.ADD( ' credit_usage_rule_set_id => '
               || dflt_global_exposure_rec.credit_usage_rule_set_id);
     OE_DEBUG_PUB.ADD( ' global_exposure_flag => '
                  || dflt_global_exposure_rec.global_exposure_flag);
    END IF;

    l_global_exposure_flag :=
        dflt_global_exposure_rec.global_exposure_flag;

    IF dflt_global_exposure_csr%NOTFOUND
    THEN
      l_global_exposure_flag := 'N' ;
      OE_DEBUG_PUB.ADD( ' dflt_global_exposure_csr NO FOUND ');
    END IF;

    CLOSE dflt_global_exposure_csr ;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('Return out NOCOPY from Get_global_exposure_flag  with '
      || l_global_exposure_flag );
  END IF;

  RETURN(l_global_exposure_flag);



EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_global_exposure_flag'
            );
      END IF;


END Get_global_exposure_flag ;



---------------------------------------------------------------------------
--FUNCTION Get_global_exposure_ruleset
--COMMENT:  REturns the global flag for a given rule set ID

---------------------------------------------------------------------------
FUNCTION Get_global_exposure_ruleset
 (p_credit_usage_rule_set_id IN NUMBER)
RETURN VARCHAR2
IS

l_global_exposure_flag VARCHAR2(1) := 'N' ;
BEGIN
 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.ADD('IN OEXUCRCB: Get_global_exposure_ruleset');
 END IF;

  BEGIN
   SELECT
     NVL(global_exposure_flag,'N')
   INTO
     l_global_exposure_flag
   FROM
    HZ_CREDIT_USAGE_RULE_SETS_B
   WHERE
     credit_usage_rule_set_id = p_credit_usage_rule_set_id ;

   EXCEPTION
   WHEN NO_DATA_FOUND
  THEN
    l_global_exposure_flag := 'N' ;

  END ;

 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.ADD('OUT OEXUCRCB: Get_global_exposure_ruleset');
 END IF;

  RETURN( NVL(l_global_exposure_flag,'N') );

EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Get_global_exposure_ruleset'
      );
    END IF;
    RAISE ;
END Get_global_exposure_ruleset;

---------------------------------------------------------------------------
--FUNCTION GET_GL_currency
--COMMENT:   Returns the SOB currency

---------------------------------------------------------------------------
FUNCTION GET_GL_currency
RETURN VARCHAR2
IS

l_gl_currency VARCHAR2(10);
l_sob_id      NUMBER;

BEGIN
 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.ADD('OEXUCRCB: In Get_GL_currency ');
 END IF;

  BEGIN
    l_sob_id := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID') ;

    IF G_debug_flag = 'Y'
    THEN
     OE_DEBUG_PUB.ADD('l_sob_id = '|| l_sob_id );
     OE_DEBUG_PUB.ADD('GET SOB currency ');
   END IF;

    SELECT
      currency_code
    INTO
      l_gl_currency
    FROM
      GL_sets_of_books
    WHERE set_of_books_id = l_sob_id ;

   IF G_debug_flag = 'Y'
   THEN
     OE_DEBUG_PUB.ADD('l_gl_currency = '|| l_gl_currency );
   END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
     l_gl_currency := NULL ;
    OE_DEBUG_PUB.ADD('EXCEPTION: NO_DATA_FOUND ');
     l_gl_currency := NULL ;
   WHEN TOO_MANY_ROWS
   THEN
     l_gl_currency := NULL ;
    OE_DEBUG_PUB.ADD('EXCEPTION: TOO_MANY_ROWS');
     l_gl_currency := NULL ;
  END ;

 IF G_debug_flag = 'Y'
 THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: Out NOCOPY Get_GL_currency ');
 END IF;
  RETURN(l_GL_currency);
EXCEPTION
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Get_GL_currency'
      );
    END IF;
    RAISE ;
END Get_GL_currency ;




------------------------------------------------------------------------------
--  FUNCTION   : GET_category_set_id                   PRIVATE
--  COMMENT    : Returns the OE default category set ID
--
--------------------------------------------------------------------------------
FUNCTION GET_category_set_id
RETURN NUMBER
IS


l_category_set_id  NUMBER;

BEGIN

  OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_category_set_id ' );
  BEGIN

    SELECT
      category_set_id
    INTO
      l_category_set_id
    FROM
      MTL_DEFAULT_CATEGORY_SEts
    WHERE functional_area_id = 7 ;

  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
    l_category_set_id  := NULL;

  END ;

  OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_category_set_id '|| l_category_set_id );
  RETURN l_category_set_id  ;


 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_category_set_id '
      );
    END IF;
    RAISE;

END GET_category_set_id ;


------------------------------------------------------------------------------
--  FUNCTION   : GET_Credit_check_Flag                  PRIVATE
--  COMMENT    : Returns the Credit Checking flag
--               from HZ_CUSTOMER_PROFILES
--
--------------------------------------------------------------------------------
FUNCTION GET_Credit_check_Flag
( p_entity_id   IN NUMBER
, p_entity_type IN VARCHAR2 )
RETURN VARCHAR2
IS

l_credit_checking   VARCHAR2(1);

BEGIN


  IF p_entity_type = 'CUSTOMER'
  THEN
    BEGIN
      SELECT
        credit_checking
      INTO
        l_credit_checking
      FROM
        HZ_CUSTOMER_PROFILES
      WHERE cust_account_id = p_entity_id
             AND site_use_id IS NULL ;

       EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_credit_checking := NULL ;

    END;

  ELSIF p_entity_type = 'SITE'
  THEN
    BEGIN
      SELECT
        credit_checking
      INTO
        l_credit_checking
      FROM
        HZ_CUSTOMER_PROFILES
      WHERE site_use_id = p_entity_id  ;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_credit_checking := NULL ;
    END;
  END IF;


 RETURN l_credit_checking ;


 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_Credit_check_Flag'
      );
    END IF;
    RAISE;

END GET_Credit_check_Flag ;

------------------------------------------------------------------------------
--  PROCEDURE  : GET_Single_Customer_Limit                  PRIVATE
--  COMMENT    : PROFILE : SINGLE
--               ENTITY  : CUSTOMER
--               Returns the Limit from the Customer Profile Amount directly
--------------------------------------------------------------------------------
PROCEDURE GET_Single_Customer_Limit
(  p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_limit_curr_code             OUT NOCOPY
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_trx_limit                   OUT NOCOPY NUMBER
 , x_overall_limit               OUT NOCOPY NUMBER
 , x_return_status               OUT NOCOPY VARCHAR2
)
IS


----------------------------------------------------
--  The cursor gets credit limit info for         --
--  1. customer                                   --
--  2. directly specified limit (not usage based) --
--    SINGLE - CUSTOMER
----------------------------------------------------

CURSOR cust_single_limit_csr IS
  SELECT cpa.currency_code currency_code
  ,	 cpa.overall_credit_limit * ((100+nvl(cp.tolerance,0))/100)
	   overall_limit
  ,	 cpa.trx_credit_limit * ((100+nvl(cp.tolerance,0))/100)
	   trx_limit
  ,	 cp.credit_checking credit_checking  --bug 5071518
  ,	 0 credit_usage_rule_set_id
  FROM   hz_customer_profiles         cp
  ,	 hz_cust_profile_amts         cpa
  WHERE  cp.cust_account_id           = p_entity_id
  AND    cp.site_use_id IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.currency_code            = p_trx_curr_code ;
--  AND    cp.credit_checking          = 'Y' ;  --bug 5071518

  cust_single_limit_rec  cust_single_limit_csr%ROWTYPE ;

BEGIN
 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_Single_Customer_Limit ' );
 END IF;

  OPEN cust_single_limit_csr;
  FETCH cust_single_limit_csr
  INTO  cust_single_limit_rec ;

  --Modified for Bug 5071518
  --If the customer profile is not created, then NULL should be returned.
  --If customer profile is created and credit check flag is not checked, only then 'N' should be returned
  IF cust_single_limit_csr%NOTFOUND
  THEN
     x_return_status := NULL ;
  ELSIF cust_single_limit_rec.credit_checking = 'N' THEN
     x_return_status := 'N' ;
  ELSE
    x_limit_curr_code      := cust_single_limit_rec.currency_code;
    x_overall_limit        := cust_single_limit_rec.overall_limit;
    x_trx_limit            := cust_single_limit_rec.trx_limit;

    x_return_status        := 'Y' ;

  END IF;

  CLOSE cust_single_limit_csr;

 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_Single_Customer_Limit ' );
 END IF;

 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_Single_Customer_Limit '
      );
    END IF;
    RAISE;

END GET_Single_Customer_Limit ;


------------------------------------------------------------------------------
--  PROCEDURE  : GET_Single_Site_Limit     PRIVATE
--  COMMENT    : PROFILE : SINGLE
--               ENTITY  : SITE
--    Returns the Limit from the Customer Profile Amount directly for
--     the site
--------------------------------------------------------------------------------
PROCEDURE GET_Single_Site_Limit
(  p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_limit_curr_code             OUT NOCOPY
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_trx_limit                   OUT NOCOPY NUMBER
 , x_overall_limit               OUT NOCOPY NUMBER
 , x_return_status               OUT NOCOPY VARCHAR2
)
IS


----------------------------------------------------
--  The cursor gets credit limit info for         --
--  1. Site                                       --
--  2. directly specified limit (not usage based) --
--    SINGLE - SITE
----------------------------------------------------

CURSOR site_single_limit_csr IS
  SELECT cpa.currency_code currency_code
  ,	 cpa.overall_credit_limit * ((100+nvl(cp.tolerance,0))/100)
	   overall_limit
  ,	 cpa.trx_credit_limit * ((100+nvl(cp.tolerance,0))/100)
	   trx_limit
  ,	 cp.credit_checking credit_checking  --bug 4582292
  ,	 0 credit_usage_rule_set_id
  FROM   hz_customer_profiles         cp
  ,	 hz_cust_profile_amts         cpa
  WHERE  cp.site_use_id               = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.currency_code            = p_trx_curr_code
--  AND    cp.credit_checking  = 'Y' bug 4582292
  AND    NVL(TRUNC(cpa.expiration_date)
            , TRUNC(SYSDATE) )    <= TRUNC(SYSDATE);


  site_single_limit_rec  site_single_limit_csr%ROWTYPE ;


BEGIN
 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_Single_site_Limit ' );
 END IF;

  OPEN site_single_limit_csr ;
  FETCH site_single_limit_csr
  INTO  site_single_limit_rec ;

  --Modified for bug 4582292
  --If the site profile is not created, then NULL should be returned.
  --If site profile is created and credit check flag is not checked, only then 'N' should be returned
  IF site_single_limit_csr%NOTFOUND
  THEN
     x_return_status := NULL ;
  ELSIF site_single_limit_rec.credit_checking = 'N' THEN
     x_return_status := 'N' ;
  ELSE
    x_limit_curr_code      := site_single_limit_rec.currency_code;
    x_overall_limit := site_single_limit_rec.overall_limit;
    x_trx_limit     := site_single_limit_rec.trx_limit;

    x_return_status        := 'Y' ;

  END IF;

  CLOSE site_single_limit_csr ;

 IF G_debug_flag = 'Y'
 THEN
   OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_Single_site_Limit ' );
 END IF;


 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_Single_Site_Limit '
      );
    END IF;
    RAISE;

END GET_Single_Site_Limit ;


-----------------------------------------------------------------------------
--  PROCEDURE  : GET_multi_customer_Limit          PRIVATE
--  COMMENT    : PROFILE : MULTI
--               ENTITY  : CUSTOMER
--    Returns the Limit from the Customer Profile Amount after
--    using the credit usage rules
--------------------------------------------------------------------------------
PROCEDURE GET_multi_customer_Limit
(  p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_limit_curr_code             OUT NOCOPY
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_trx_limit                   OUT NOCOPY NUMBER
 , x_overall_limit               OUT NOCOPY NUMBER
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_credit_usage_rule_set_id    OUT NOCOPY NUMBER
 , x_global_exposure_flag        OUT NOCOPY VARCHAR2
)
IS

---------------------------------------------
--  The cursor gets credit limit info for  --
--  1. customer                            --
--  2. usage based limit                   --
--  3. lowest available                    --

--  MULTI  CUSTOMER
---------------------------------------------

CURSOR cust_multi_limit_no_incl_csr IS
  SELECT cpa.currency_code currency_code
  ,	 cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   overall_limit
  ,	 cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   trx_limit
  ,	 cp.credit_checking credit_checking  --bug 5071518
  ,	 curs.credit_usage_rule_set_id
  ,      cu.credit_usage_id
  ,      NVL(curs.global_exposure_flag,'N') global_exposure_flag
  FROM   hz_customer_profiles         cp
  ,	 hz_cust_profile_amts         cpa
  ,	 hz_credit_usages             cu
  ,	 hz_credit_usage_rules        cur
  ,      hz_credit_usage_rule_sets_B   curs
  WHERE  cp.cust_account_id           = p_entity_id
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    curs.credit_usage_rule_set_id = cu.credit_usage_rule_set_id
  AND    curs.credit_usage_rule_set_id = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type = 'CURRENCY'
  AND     cur.user_code = p_trx_curr_code
  AND     NVL(cur.exclude_flag,'N') = 'N' ;
--  AND     cp.credit_checking = 'Y' ;  --bug 5071518


  cust_multi_limit_no_incl_rec   cust_multi_limit_no_incl_csr%ROWTYPE ;


  CURSOR cust_multi_limit_incl_csr IS
  SELECT cpa.currency_code currency_code
  ,	 cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   overall_limit
  ,	 cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   trx_limit
  ,	 cp.credit_checking credit_checking  --bug 5071518
  ,	 cu.credit_usage_rule_set_id
  ,      NVL(curs.global_exposure_flag,'N') global_exposure_flag
  FROM   hz_customer_profiles         cp
  ,	 hz_cust_profile_amts         cpa
  ,	 hz_credit_usages             cu
  ,	 hz_credit_usage_rules        cur
  ,      hz_credit_usage_rule_sets_B  curs
  WHERE  cp.cust_account_id           = p_entity_id
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    curs.credit_usage_rule_set_id = cu.credit_usage_rule_set_id
  AND    curs.credit_usage_rule_set_id = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date), TRUNC(SYSDATE)
            )    <= TRUNC(SYSDATE)
  AND    cur.include_all_flag = 'Y'
  AND    NOT EXISTS ( SELECT 'EXCLUDE'
		      FROM   hz_credit_usage_rules cur2
		      WHERE  cu.credit_usage_rule_set_id
			     = cur2.credit_usage_rule_set_id
                      AND    cur2.exclude_flag = 'Y'
		      AND    cur2.usage_type  = 'CURRENCY'
		      AND    cur2.user_code   = p_trx_curr_code
                    ) ;
--  AND  cp.credit_checking = 'Y' ;  --bug 5071518


  cust_multi_limit_incl_rec cust_multi_limit_incl_csr%ROWTYPE ;

BEGIN
 IF G_debug_flag = 'Y'
 THEN
  OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_multi_Customer_Limit ' );
 END IF;

    x_credit_usage_rule_set_id := NULL ;

  -- The process will first try to find the limit avoiding the
  -- Include all factor.
  -- If not successful, the Include all is considered

  OPEN cust_multi_limit_no_incl_csr ;
  FETCH cust_multi_limit_no_incl_csr
  INTO  cust_multi_limit_no_incl_rec ;


  --Modified for Bug 5071518
  --If the customer profile is not created, then NULL should be returned.
  --If customer profile is created and credit check flag is not checked, only then 'N' should be returned
  IF cust_multi_limit_no_incl_csr%NOTFOUND
  THEN
    x_return_status := NULL ;
  ELSIF cust_multi_limit_no_incl_rec.credit_checking = 'N' THEN
     x_credit_usage_rule_set_id := NULL ;
     x_return_status := 'N' ;
  ELSE
    x_limit_curr_code := cust_multi_limit_no_incl_rec.currency_code;
    x_overall_limit   := cust_multi_limit_no_incl_rec.overall_limit;
    x_trx_limit       := cust_multi_limit_no_incl_rec.trx_limit;
    x_credit_usage_rule_set_id :=
          cust_multi_limit_no_incl_rec.credit_usage_rule_set_id ;
    x_global_exposure_flag := cust_multi_limit_no_incl_rec.global_exposure_flag ;

    x_return_status   := 'Y' ;
  END IF;

  CLOSE cust_multi_limit_no_incl_csr ;

  IF x_limit_curr_code  IS NULL
  THEN
    OPEN cust_multi_limit_incl_csr ;
    FETCH cust_multi_limit_incl_csr
    INTO   cust_multi_limit_incl_rec ;

    --Modified for Bug 5071518
    --If the customer profile is not created, then NULL should be returned.
    --If customer profile is created and credit check flag is not checked, only then 'N' should be returned
    IF cust_multi_limit_incl_csr%NOTFOUND
    THEN
       x_return_status := NULL ;
    ELSIF cust_multi_limit_incl_rec.credit_checking = 'N' THEN
       x_credit_usage_rule_set_id := NULL ;
       x_return_status := 'N' ;
    ELSE
      x_limit_curr_code :=  cust_multi_limit_incl_rec.currency_code;
      x_overall_limit   :=  cust_multi_limit_incl_rec.overall_limit;
      x_trx_limit       :=  cust_multi_limit_incl_rec.trx_limit;
      x_credit_usage_rule_set_id :=
             cust_multi_limit_incl_rec.credit_usage_rule_set_id ;
      x_global_exposure_flag :=
        cust_multi_limit_incl_rec.global_exposure_flag ;  --Bug 4703167
      x_return_status   := 'Y' ;
    END IF;

    CLOSE cust_multi_limit_incl_csr ;

  END IF;
 IF G_debug_flag = 'Y'
 THEN
  OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_multi_Customer_Limit ' );
 END IF;


 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_multi_customer_Limit '
      );
    END IF;
    RAISE;

END GET_multi_customer_Limit ;



-----------------------------------------------------------------------------
--  PROCEDURE  : GET_multi_site_Limit              PRIVATE
--  COMMENT    : PROFILE : MULTI
--               ENTITY  : SITE
--    Returns the limit by using the Credit ussage rules
--------------------------------------------------------------------------------
PROCEDURE GET_multi_site_Limit
(  p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_limit_curr_code             OUT NOCOPY
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_trx_limit                   OUT NOCOPY NUMBER
 , x_overall_limit               OUT NOCOPY NUMBER
 , x_return_status               OUT NOCOPY VARCHAR2
)
IS

---------------------------------------------
--  The cursor gets credit limit info for  --
--  1. Site                                --
--  2. usage based limit                   --
--  3. lowest available                    --

--  MULTI  SITE
---------------------------------------------

CURSOR site_multi_limit_no_incl_csr IS
  SELECT cpa.currency_code currency_code
  ,	 cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   overall_limit
  ,	 cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   trx_limit
  ,	 cp.credit_checking credit_checking  --bug 4582292
  ,	 cu.credit_usage_rule_set_id
  FROM   hz_customer_profiles         cp
  ,	 hz_cust_profile_amts         cpa
  ,	 hz_credit_usages             cu
  ,	 hz_credit_usage_rules        cur
  WHERE  cp.site_use_id               = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type = 'CURRENCY'
  AND     cur.user_code = p_trx_curr_code
-- AND     cp.credit_checking     = 'Y' bug 4582292
 AND     NVL(cur.exclude_flag,'N') = 'N';


  site_multi_limit_no_incl_rec   site_multi_limit_no_incl_csr%ROWTYPE ;


  CURSOR site_multi_limit_incl_csr IS
  SELECT cpa.currency_code currency_code
  ,	 cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   overall_limit
  ,	 cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   trx_limit
  ,	 cp.credit_checking credit_checking --bug 4582292
  ,	 cu.credit_usage_rule_set_id
  FROM   hz_customer_profiles         cp
  ,	 hz_cust_profile_amts         cpa
  ,	 hz_credit_usages             cu
  ,	 hz_credit_usage_rules        cur
  WHERE  cp.site_use_id               = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date), TRUNC(SYSDATE)
            )    <= TRUNC(SYSDATE)
--  AND     cp.credit_checking     = 'Y' bug 4582292
  AND   cur.include_all_flag = 'Y'
  AND   NOT EXISTS ( SELECT 'EXCLUDE'
		      FROM   hz_credit_usage_rules cur2
		      WHERE  cu.credit_usage_rule_set_id
			     = cur2.credit_usage_rule_set_id
                      AND    cur2.exclude_flag = 'Y'
		      AND    cur2.usage_type  = 'CURRENCY'
		      AND    cur2.user_code   = p_trx_curr_code
                    );

 site_multi_limit_incl_rec   site_multi_limit_incl_csr%ROWTYPE ;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
   OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_multi_site_Limit ' );
  END IF;

  -- The process will first try to find the limit avoiding the
  -- Include all factor.
  -- If not successful, the Include all is considered

  OPEN site_multi_limit_no_incl_csr ;
  FETCH site_multi_limit_no_incl_csr
  INTO  site_multi_limit_no_incl_rec ;

  --Modified for Bug 4582292
  --If the site profile is not created, then NULL should be returned.
  --If site profile is created and credit check flag is not checked, only then 'N' should be returne
  IF site_multi_limit_no_incl_csr%NOTFOUND
  THEN
     x_return_status := NULL ;
  ELSIF site_multi_limit_no_incl_rec.credit_checking = 'N' THEN
     x_return_status := 'N';
  ELSE
    x_limit_curr_code  := site_multi_limit_no_incl_rec.currency_code;
    x_overall_limit    := site_multi_limit_no_incl_rec.overall_limit;
    x_trx_limit        := site_multi_limit_no_incl_rec.trx_limit;
    x_return_status    := 'Y' ;

  END IF;

  CLOSE site_multi_limit_no_incl_csr ;

  IF x_limit_curr_code  IS NULL
  THEN
    OPEN site_multi_limit_incl_csr ;
    FETCH site_multi_limit_incl_csr
    INTO  site_multi_limit_incl_rec ;

    --Modified for Bug 4582292
    --If the site profile is not created, then NULL should be returned.
  --If site profile is created and credit check flag is not checked, only then 'N' should be returned
    IF site_multi_limit_incl_csr%NOTFOUND
    THEN
       x_return_status := NULL ;
    ELSIF site_multi_limit_incl_rec.credit_checking = 'N' THEN
       x_return_status := 'N' ;
    ELSE
     x_limit_curr_code  := site_multi_limit_incl_rec.currency_code;
     x_overall_limit    := site_multi_limit_incl_rec.overall_limit;
     x_trx_limit        := site_multi_limit_incl_rec.trx_limit;
     x_return_status    := 'Y' ;

    END IF;

    CLOSE site_multi_limit_incl_csr ;

  END IF;
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_multi_site_Limit ' );
  END IF ;


 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_multi_site_Limit '
      );
    END IF;
    RAISE;

END GET_multi_site_Limit ;



-----------------------------------------------------------------------------
--  PROCEDURE  : GET_single_default_Limit            PRIVATE
--  COMMENT    : PROFILE : SINGLE
--               ENTITY  : DEFAULT ( Organization )
--    Returns the limit from the Credit profile amounts directly
--------------------------------------------------------------------------------
PROCEDURE GET_single_default_Limit
(  p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_limit_curr_code             OUT NOCOPY
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_trx_limit                   OUT NOCOPY NUMBER
 , x_overall_limit               OUT NOCOPY NUMBER
 , x_return_status               OUT NOCOPY VARCHAR2
)
IS

---------------------------------------------------
--  The cursor gets credit limit info for         --
--  1. Organization                               --
--  2. directly specified limit (not usage based) --
--    SINGLE - DEFAULT
----------------------------------------------------

CURSOR dflt_single_limit_csr IS
  SELECT cpa.currency_code   currency_code
  ,	 cpa.overall_credit_limit * ((100+nvl(cp.tolerance,0))/100)
	   overall_limit
  ,	 cpa.trx_credit_limit * ((100+nvl(cp.tolerance,0))/100)
	   trx_limit
  ,	 cp.credit_checking
  FROM   hz_credit_profiles         cp
  ,	 hz_credit_profile_amts     cpa
  WHERE  cp.organization_id           = G_ORG_ID
  AND    cp.credit_profile_id         = cpa.credit_profile_id
  AND    cpa.currency_code            = p_trx_curr_code
  AND    cp.enable_flag     = 'Y'
  AND    ( TRUNC(SYSDATE)   BETWEEN
               TRUNC( NVL(cp.effective_date_from, SYSDATE))
                  AND
               TRUNC( NVL(cp.effective_date_to, SYSDATE ))
         );
  dflt_single_limit_rec       dflt_single_limit_csr%ROWTYPE ;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_single_default_Limit ' );
  END IF ;

  OPEN dflt_single_limit_csr ;
  FETCH dflt_single_limit_csr
  INTO  dflt_single_limit_rec ;

  IF dflt_single_limit_csr%NOTFOUND
  THEN

    x_return_status := 'N' ;
  ELSE

    x_limit_curr_code      := dflt_single_limit_rec.currency_code;
    x_overall_limit := dflt_single_limit_rec.overall_limit;
    x_trx_limit     := dflt_single_limit_rec.trx_limit;

    x_return_status        := 'Y' ;

  END IF;

  CLOSE dflt_single_limit_csr ;

  IF G_debug_flag = 'Y'
  THEN
   OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_single_default_Limit ' );
  END IF ;

 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_single_default_Limit '
      );
    END IF;
    RAISE;

END GET_single_default_Limit ;



-----------------------------------------------------------------------------
--  PROCEDURE  : GET_multi_default_Limit           PRIVATE
--  COMMENT    : PROFILE : SINGLE
--               ENTITY  : DEFAULT ( Organization )
--    Returns the limit using the usage rules
--------------------------------------------------------------------------------
PROCEDURE GET_multi_default_Limit
(  p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_limit_curr_code             OUT NOCOPY
          HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_trx_limit                   OUT NOCOPY NUMBER
 , x_overall_limit               OUT NOCOPY NUMBER
 , x_return_status               OUT NOCOPY VARCHAR2
 , x_credit_usage_rule_set_id    OUT NOCOPY NUMBER
 , x_global_exposure_flag        OUT NOCOPY VARCHAR2
)
IS

---------------------------------------------
--  The cursor gets credit limit info for  --
--  1. Organization                        --
--  2. Default based limit                 --
--  3. lowest available                    --

--  MULTI  DEFAULT
---------------------------------------------


CURSOR dflt_multi_limit_no_incl_csr IS
  SELECT cpa.currency_code currency_code
  ,	 cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   overall_limit
  ,	 cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   trx_limit
  ,	 cp.credit_checking
  ,	 cu.credit_usage_rule_set_id
  ,      NVL(curs.global_exposure_flag,'N') global_exposure_flag
  FROM   hz_credit_profiles           cp
  ,	 hz_credit_profile_amts       cpa
  ,	 hz_credit_usages             cu
  ,	 hz_credit_usage_rules        cur
  ,      hz_credit_usage_rule_sets_B  curs
  WHERE  cp.organization_id           = G_ORG_ID
  AND    cp.credit_profile_id         = cpa.credit_profile_id
  AND    cpa.credit_profile_amt_id    = cu.credit_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    curs.credit_usage_rule_set_id = cu.credit_usage_rule_set_id
  AND    curs.credit_usage_rule_set_id = cur.credit_usage_rule_set_id
  AND    cp.enable_flag     = 'Y'
  AND    ( TRUNC(SYSDATE)   BETWEEN
               TRUNC( NVL(cp.effective_date_from, SYSDATE ))
                  AND
               TRUNC( NVL(cp.effective_date_to, SYSDATE ) )
         )
  AND  NVL (cur.include_all_flag, 'N') = 'N'
  AND  cur.usage_type = 'CURRENCY'
  AND  cur.user_code = p_trx_curr_code
 AND     NVL(cur.exclude_flag,'N') = 'N'
 AND   cp.credit_checking = 'Y' ;


  dflt_multi_limit_no_incl_rec       dflt_multi_limit_no_incl_csr%ROWTYPE ;



CURSOR dflt_multi_limit_incl_csr   IS
  SELECT cpa.currency_code currency_code
  ,	 cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   overall_limit
  ,	 cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
	   trx_limit
  ,	 cp.credit_checking
  ,	 cu.credit_usage_rule_set_id
  ,      NVL(curs.global_exposure_flag,'N') global_exposure_flag
  FROM   hz_credit_profiles           cp
  ,	 hz_credit_profile_amts       cpa
  ,	 hz_credit_usages             cu
  ,	 hz_credit_usage_rules        cur
  ,      hz_credit_usage_rule_sets_B  curs
  WHERE  cp.organization_id           = G_ORG_ID
  AND    cp.credit_profile_id         = cpa.credit_profile_id
  AND    cpa.credit_profile_amt_id    = cu.credit_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    curs.credit_usage_rule_set_id = cu.credit_usage_rule_set_id
  AND    curs.credit_usage_rule_set_id = cur.credit_usage_rule_set_id
  AND    cp.enable_flag      = 'Y'
  AND    ( TRUNC(SYSDATE)   BETWEEN
               TRUNC( NVL(cp.effective_date_from, SYSDATE ))
                  AND
               TRUNC( NVL(cp.effective_date_to, SYSDATE ) )
         )
  AND    cur.include_all_flag = 'Y'
  AND    cp.credit_checking = 'Y'
  AND    NOT EXISTS ( SELECT 'EXCLUDE'
		      FROM   hz_credit_usage_rules cur2
		      WHERE  cu.credit_usage_rule_set_id
			     = cur2.credit_usage_rule_set_id
                      AND    cur2.exclude_flag = 'Y'
		      AND    cur2.usage_type  = 'CURRENCY'
		      AND    cur2.user_code   = p_trx_curr_code
                    );


  dflt_multi_limit_incl_rec          dflt_multi_limit_incl_csr%ROWTYPE ;

BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_multi_default_Limit ' );
  END IF;

  x_credit_usage_rule_set_id := NULL ;
  x_global_exposure_flag := 'N' ;

  -- The process will first try to find the limit avoiding the
  -- Include all factor.
  -- If not successful, the Include all is considered

  OPEN  dflt_multi_limit_no_incl_csr ;
  FETCH  dflt_multi_limit_no_incl_csr
  INTO   dflt_multi_limit_no_incl_rec ;

  IF  dflt_multi_limit_no_incl_csr%NOTFOUND
  THEN
     x_credit_usage_rule_set_id := NULL ;
     x_return_status := 'N' ;
  ELSE
    x_limit_curr_code  := dflt_multi_limit_no_incl_rec.currency_code;
    x_overall_limit    := dflt_multi_limit_no_incl_rec.overall_limit;
    x_trx_limit        := dflt_multi_limit_no_incl_rec.trx_limit;
    x_credit_usage_rule_set_id :=
                 dflt_multi_limit_no_incl_rec.credit_usage_rule_set_id ;
    x_return_status        := 'Y' ;
    x_global_exposure_flag := dflt_multi_limit_no_incl_rec.global_exposure_flag ;  --Bug 4703167

  END IF;

  CLOSE dflt_multi_limit_no_incl_csr ;

  IF x_limit_curr_code IS NULL
  THEN

    OPEN  dflt_multi_limit_incl_csr ;
    FETCH  dflt_multi_limit_incl_csr
    INTO   dflt_multi_limit_incl_rec ;

    IF dflt_multi_limit_incl_csr%NOTFOUND
    THEN
       x_credit_usage_rule_set_id := NULL ;
       x_return_status := 'N' ;
    ELSE
      x_limit_curr_code  := dflt_multi_limit_incl_rec.currency_code;
      x_overall_limit    := dflt_multi_limit_incl_rec.overall_limit;
      x_trx_limit        := dflt_multi_limit_incl_rec.trx_limit;
      x_credit_usage_rule_set_id :=
              dflt_multi_limit_incl_rec.credit_usage_rule_set_id ;
      x_return_status    := 'Y' ;
      x_global_exposure_flag := dflt_multi_limit_incl_rec.global_exposure_flag ;

    END IF;

    CLOSE dflt_multi_limit_incl_csr ;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_multi_default_Limit ' );
  END IF;

 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_multi_default_Limit '
      );
    END IF;
    RAISE;

END GET_multi_default_Limit ;


----------------------------------------------------------------------------
--  PROCEDURE  : GET_single_Item_Limit           PRIVATE
--  COMMENT    : Returns the limit associated with the Items.
--
----------------------------------------------------------------------------
PROCEDURE  GET_single_Item_Limit
( p_category_id                IN NUMBER
, p_trx_curr_code              IN VARCHAR2
, x_limit_curr_code           OUT NOCOPY VARCHAR2
, x_trx_limit                 OUT NOCOPY NUMBER
, x_return_status             OUT NOCOPY VARCHAR2
)
IS


---------------------------------------------------
--  The cursor gets credit limit info for         --
--  1. Item categories
----------------------------------------------------

CURSOR  single_Item_limit_csr   IS
  SELECT cpa.currency_code  limit_curr_code
  ,	 cpa.trx_credit_limit * ((100+nvl(cp.tolerance,0))/100)
	   trx_limit
  FROM   hz_credit_profiles         cp
  ,	 hz_credit_profile_amts     cpa
  WHERE  cp.item_category_id        = p_category_id
  AND    cp.credit_profile_id       = cpa.credit_profile_id
  AND    cpa.currency_code          = p_trx_curr_code
  AND    cp.enable_flag    = 'Y'
  AND    ( TRUNC(SYSDATE)           BETWEEN
               TRUNC( NVL(cp.effective_date_from, SYSDATE ) )
          AND  TRUNC( NVL(cp.effective_date_to, SYSDATE ) )
         ) ;

 l_single_Item_limit_csr_VAL   single_Item_limit_csr%ROWTYPE ;


BEGIN

  OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_single_Item_Limit ' );

  OPEN  single_Item_limit_csr;
  FETCH single_Item_limit_csr
  INTO  l_single_Item_limit_csr_VAL ;

  IF single_Item_limit_csr%NOTFOUND
  THEN
    x_return_status := 'N' ;

  ELSE
    x_trx_limit
               := l_single_Item_limit_csr_VAL.trx_limit ;
    x_limit_curr_code
                := l_single_Item_limit_csr_VAL.limit_curr_code   ;

    x_return_status := 'Y' ;

  END IF;

  OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_single_Item_Limit ' );

 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , '  GET_single_Item_Limit'
      );
    END IF;
    RAISE;

END  GET_single_Item_Limit ;

-----------------------------------------------------------------------------
--  PROCEDURE  : GET_multi_Item_Limit           PRIVATE
--  COMMENT    : Returns the limit associated with the Items.
--
-----------------------------------------------
PROCEDURE GET_multi_Item_Limit
( p_category_id                IN NUMBER
, p_trx_curr_code              IN VARCHAR2
, x_limit_curr_code           OUT NOCOPY VARCHAR2
, x_trx_limit                 OUT NOCOPY NUMBER
, x_return_status             OUT NOCOPY VARCHAR2
)
IS


CURSOR multi_Item_limit_no_incl_csr   IS
  SELECT cpa.currency_code  limit_curr_code
  ,	 cpa.trx_credit_limit * ((100+nvl(cp.tolerance,0))/100)
	   trx_limit
  ,	 cu.credit_usage_rule_set_id
  FROM   hz_credit_profiles           cp
  ,	 hz_credit_profile_amts       cpa
  ,	 hz_credit_usages             cu
  ,	 hz_credit_usage_rules        cur
  WHERE  cp.credit_profile_id         = cpa.credit_profile_id
  AND    cpa.credit_profile_amt_id    = cu.credit_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    cp.enable_flag      = 'Y'
  AND    cp.item_category_id          = p_category_id
  AND    ( TRUNC(SYSDATE)           BETWEEN
               TRUNC( NVL(cp.effective_date_from, SYSDATE ) )
          AND   TRUNC( NVL(cp.effective_date_to, SYSDATE ) )
         )
  AND  NVL (cur.include_all_flag, 'N') = 'N'
  AND  cur.usage_type         = 'CURRENCY'
  AND  cur.user_code          = p_trx_curr_code
 AND     NVL(cur.exclude_flag,'N') = 'N'
   ORDER BY cpa.overall_credit_limit;

  l_multi_Item_limit_no_incl_VAL  multi_Item_limit_no_incl_csr%ROWTYPE ;



CURSOR multi_Item_limit_incl_csr   IS
  SELECT cpa.currency_code  limit_curr_code
  ,	 cpa.trx_credit_limit * ((100+nvl(cp.tolerance,0))/100)
	   trx_limit
  ,	 cu.credit_usage_rule_set_id
  FROM   hz_credit_profiles           cp
  ,	 hz_credit_profile_amts       cpa
  ,	 hz_credit_usages             cu
  ,	 hz_credit_usage_rules        cur
  WHERE  cp.credit_profile_id         = cpa.credit_profile_id
  AND    cpa.credit_profile_amt_id    = cu.credit_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    cp.enable_flag      = 'Y'
  AND    cp.item_category_id          = p_category_id
  AND    ( TRUNC(SYSDATE)           BETWEEN
               TRUNC( NVL(cp.effective_date_from, SYSDATE ) )
          AND   TRUNC( NVL(cp.effective_date_to, SYSDATE ) )
         )
  AND    cur.include_all_flag = 'Y'
  AND    NOT EXISTS ( SELECT 'EXCLUDE'
		      FROM   hz_credit_usage_rules cur2
		      WHERE  cu.credit_usage_rule_set_id
			     = cur2.credit_usage_rule_set_id
                      AND    cur2.exclude_flag = 'Y'
		      AND    cur2.usage_type  = 'CURRENCY'
		      AND    cur2.user_code   = p_trx_curr_code
                    )
   ORDER BY cpa.overall_credit_limit;

  l_multi_Item_limit_incl_VAL   multi_Item_limit_incl_csr%ROWTYPE ;

BEGIN

   OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_multi_item_Limit ' );

    x_return_status := 'N' ;

    OPEN multi_Item_limit_no_incl_csr ;
    FETCH multi_Item_limit_no_incl_csr
    INTO  l_multi_Item_limit_no_incl_VAL ;

    IF multi_Item_limit_no_incl_csr%NOTFOUND
    THEN
      x_return_status := 'N' ;

      OPEN multi_Item_limit_incl_csr ;
      FETCH multi_Item_limit_incl_csr
      INTO  l_multi_Item_limit_incl_VAL ;

      IF multi_Item_limit_incl_csr%NOTFOUND
      THEN
        x_return_status := 'N' ;

      ELSE
        x_trx_limit
               := l_multi_Item_limit_incl_VAL.trx_limit ;
        x_limit_curr_code
                := l_multi_Item_limit_incl_VAL.limit_curr_code   ;
        x_return_status := 'Y' ;

      END IF;
    ELSE
       x_trx_limit
               := l_multi_Item_limit_no_incl_VAL.trx_limit ;
       x_limit_curr_code
                := l_multi_Item_limit_no_incl_VAL.limit_curr_code   ;

       x_return_status := 'Y' ;

    END IF;

   OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_multi_item_Limit ' );

 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , '  GET_multi_Item_Limit '
      );
    END IF;
    RAISE;

END  GET_multi_Item_Limit ;


-----------------------------------------------------------------------------
--  FUNCTION   : check_category           PRIVATE
--  COMMENT    : Returns YES of category exist in the tmp table
--
------------------------------------------------------------------------------
FUNCTION check_category
( p_category_id      IN NUMBER
, p_category_tmp_tbl IN category_tmp_tbl_type
)
RETURN VARCHAR2
IS

 l_return_status VARCHAR2(1) := 'N' ;

BEGIN

 FOR I IN 1..p_category_tmp_tbl.COUNT
 LOOP
   IF p_category_tmp_tbl(I).item_category_id = p_category_id
   THEN
     l_return_status := 'Y' ;
     EXIT;
   ELSE
     l_return_status := 'N' ;
   END IF;

 END LOOP;

 RETURN l_return_status ;

 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'check_category '
      );
    END IF;
    RAISE;

END check_category ;


-----------------------------------------------------------------------------
--  PROCEDURE  : GET_Item_Limit           PUBLIC
--  COMMENT    : Returns the limit associated with the Items.
--
------------------------------------------------------------------------------
PROCEDURE GET_Item_Limit
( p_header_id                  IN NUMBER
, p_trx_curr_code              IN VARCHAR2
, p_site_use_id                IN NUMBER
, p_include_tax_flag           IN VARCHAR2
, x_item_limits_tbl            OUT NOCOPY
                  OE_CREDIT_CHECK_UTIL.item_limits_tbl_type
, x_lines_tbl                  OUT NOCOPY
                  OE_CREDIT_CHECK_UTIL.lines_Rec_tbl_type
)
IS

 l_site_use_id        NUMBER ;
 l_include_tax_flag   VARCHAR2(1) := 'N' ;
 l_tmp_lines_tbl      OE_CREDIT_CHECK_UTIL.lines_Rec_tbl_type ;
 l_tmp_category_tbl   category_tmp_tbl_type ;
 l_selling_price      NUMBER;
 l_tax_value          NUMBER;
 l_ordered_quantity   NUMBER;
 l_credit_profile_id  NUMBER;
 l_ctg_profile_exist  VARCHAR2(1) := 'N' ;

 CURSOR C_SELECT_CTG_CREDIT_PROFILE IS
 SELECT
       cp.credit_profile_id
 FROM
      hz_credit_profiles cp
  WHERE    cp.item_category_id is NOT NULL
    AND    cp.enable_flag    = 'Y'
    AND    ( TRUNC(SYSDATE)           BETWEEN
               TRUNC( NVL(cp.effective_date_from, SYSDATE ) )
           AND  TRUNC( NVL(cp.effective_date_to, SYSDATE ) )
         ) ;

 l_SELECT_CTG_CREDIT_PROFILE C_SELECT_CTG_CREDIT_PROFILE%ROWTYPE ;


 CURSOR C_SELECT_LINES_CSR IS
 SELECT
   ln.line_id            line_id
 , ln.inventory_item_id  item_id
 , ctg.category_id       category_id
 , ln.ordered_quantity   ordered_quantity
 , ln.unit_selling_price selling_price
 , ln.tax_value          tax_value
 FROM
   OE_ORDER_LINES    ln
 , mtl_item_categories   ctg
 , ra_terms_b            trm
 WHERE ln.header_id            = p_header_id
   AND ln.invoice_to_org_id    = NVL(l_site_use_id, ln.invoice_to_org_id )
   AND ln.open_flag            = 'Y'
   AND (ln.invoiced_quantity IS NULL OR ln.invoiced_quantity = 0)
   AND ctg.category_set_id     = G_category_set_id
   --Bug 7651089
   AND ctg.organization_id     = oe_sys_parameters.value('MASTER_ORGANIZATION_ID', G_ORG_ID) --G_ORG_ID
   AND ctg.inventory_item_id   = ln.inventory_item_id
   AND trm.term_id             = ln.payment_term_id
   AND ln.line_category_code   = 'ORDER'
   AND trm.credit_check_flag   = 'Y'
   AND EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_headers_all h
         WHERE  pt.credit_check_flag = 'Y'
         AND    h.header_id = p_header_id
         AND    ln.header_id = h.header_id
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(ln.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         ln.payment_type_code)
        );


 L_SELECT_LINES_VAL  C_SELECT_LINES_CSR%ROWTYPE ;

 l_return_status       VARCHAR2(1);
 I                     NUMBER ; -- INDEX

 l_item_id             NUMBER;
 l_line_id             NUMBER;
 l_trx_limit           NUMBER;
 l_limit_curr_code     VARCHAR2(15) ;
 l_category_id         NUMBER;
 l_curr_category_id    NUMBER;
 l_count               NUMBER := 0 ;

 l_ln_count            NUMBER := 0;
 l_grouping_id         NUMBER := 0;
 l_ctg_count           NUMBER := 0;
 l_line_value          NUMBER := 0 ;
BEGIN

  OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_Item_Limit ');

----------------------------------------------------
-- Two PL/SQL tables are used to maintain the limits
-- associated with the Item categories.
-- Header table with the Item category ID
-- details table that contains the oe lines for that
-- Item category within a bill to site for line level
-- The credit checking Engine will use the information
-- returned in the PL/SQL tables to CC check

-----------------------------------------------------

  l_site_use_id := p_site_use_id ;
  l_tmp_lines_tbl.DELETE ;
  l_tmp_category_tbl.DELETE ;

  g_category_set_id     := NULL;
  l_ctg_profile_exist   := 'N' ;

  OE_DEBUG_PUB.ADD('Initial g_category_set_id ' || g_category_set_id   );
--  OE_DEBUG_PUB.ADD(' G_profile ' || G_profile );

  -- For each Line ID/Item, the limits are selected
  -- using the Category.
  -- The similar selection pattern in coordination
  -- with the profile is used,
  -- that is being used for selecting the
  -- default limit.

  -- First verify if any category exist with a profile

  BEGIN
    OE_DEBUG_PUB.ADD(' Cusror select to check CTG profile exist ');

    OPEN C_SELECT_CTG_CREDIT_PROFILE ;

    FETCH C_SELECT_CTG_CREDIT_PROFILE
    INTO l_SELECT_CTG_CREDIT_PROFILE ;

    IF C_SELECT_CTG_CREDIT_PROFILE%NOTFOUND
    THEN
     l_ctg_profile_exist := 'N' ;
     OE_DEBUG_PUB.ADD(' Category profile do NOT exist ');
    ELSE
      l_credit_profile_id :=
                  l_SELECT_CTG_CREDIT_PROFILE.credit_profile_id ;
      l_ctg_profile_exist := 'Y' ;
     OE_DEBUG_PUB.ADD(' Category profile exist ');
    END IF;
    CLOSE C_SELECT_CTG_CREDIT_PROFILE ;

  END ;


   OE_DEBUG_PUB.ADD('  Out NOCOPY of CTG profile check cursor ');
   OE_DEBUG_PUB.ADD(' l_ctg_profile_exist = '|| l_ctg_profile_exist );

   IF l_ctg_profile_exist = 'Y'
   THEN

   OE_DEBUG_PUB.ADD(' Continue Item category credit get limit ');

    g_category_set_id   := GET_category_set_id ;
    OE_DEBUG_PUB.ADD('g_category_set_id ' || g_category_set_id   );

    FOR L_SELECT_LINES_VAL  IN  C_SELECT_LINES_CSR
    LOOP
      l_line_id          := L_SELECT_LINES_VAL.line_id ;
      l_item_id          := L_SELECT_LINES_VAL.item_id ;
      l_category_id      := L_SELECT_LINES_VAL.category_id ;
      l_selling_price    := L_SELECT_LINES_VAL.selling_price ;
      l_tax_value        := L_SELECT_LINES_VAL.tax_value ;
      l_ordered_quantity := L_SELECT_LINES_VAL.ordered_quantity ;
      l_count            := NVL(l_count,0) + 1 ;

      -- Insert into the TMP PL/SQL table.

      l_tmp_lines_tbl(l_count).grouping_id         := NULL;
      l_tmp_lines_tbl(l_count).item_category_id    := l_category_id ;
      l_tmp_lines_tbl(l_count).line_id             := l_line_id ;
      l_tmp_lines_tbl(l_count).unit_selling_price  := l_selling_price ;
      l_tmp_lines_tbl(l_count).tax_value           := l_tax_value ;
      l_tmp_lines_tbl(l_count).ordered_quantity    := l_ordered_quantity ;

      l_line_id           := NULL;
      l_item_id           := NULL;
      l_category_id       := NULL;
      l_selling_price     := NULL;
      l_tax_value         := NULL;
      l_ordered_quantity  := NULL;

    END LOOP;  -- CTG cursor loop

    OE_DEBUG_PUB.ADD('  Out NOCOPY of category cursor ');

    OE_DEBUG_PUB.ADD(' l_tmp_lines_tbl.COUNT ' || l_tmp_lines_tbl.COUNT );
    -- Now the TMP table needs to be scannned and relocated into
    -- the main table with category check.

    FOR I IN 1.. l_tmp_lines_tbl.COUNT
    LOOP
      IF check_category
      ( p_category_id       => l_tmp_lines_tbl(i).item_category_id
      , p_category_tmp_tbl  => l_tmp_category_tbl
      ) = 'N'
      THEN

        l_ctg_count := NVL(l_ctg_count,0) + 1 ;

        -- Always get multi first and get single if no usages found

          OE_DEBUG_PUB.ADD(' GET_multi_Item_Limit ');

          GET_multi_Item_Limit
          ( p_category_id         => l_tmp_lines_tbl(i).item_category_id
          , p_trx_curr_code       => p_trx_curr_code
          , x_limit_curr_code     => l_limit_curr_code
          , x_trx_limit           => l_trx_limit
          , x_return_status       => l_return_status
          );

          IF l_return_status  = 'N'
          THEN
            OE_DEBUG_PUB.ADD(' Call GET_single_Item_Limit ');
            GET_single_Item_Limit
            ( p_category_id         => l_tmp_lines_tbl(i).item_category_id
            , p_trx_curr_code       => p_trx_curr_code
            , x_limit_curr_code     => l_limit_curr_code
            , x_trx_limit           => l_trx_limit
            , x_return_status       => l_return_status
            );

          END IF;
--        END IF;

         IF G_debug_flag = 'Y'
         THEN
            OE_DEBUG_PUB.ADD(' after getting the limits ');
            OE_DEBUG_PUB.ADD(' l_return_status '|| l_return_status);
            OE_DEBUG_PUB.ADD(' l_trx_limit '|| l_trx_limit);
            OE_DEBUG_PUB.ADD(' l_limit_curr_code '|| l_limit_curr_code );
            OE_DEBUG_PUB.ADD(' p_trx_curr_code '|| p_trx_curr_code );
        END IF;

        l_curr_category_id := l_tmp_lines_tbl(i).item_category_id ;

        l_tmp_category_tbl(l_ctg_count).item_category_id
               := l_tmp_lines_tbl(i).item_category_id ;

        l_tmp_category_tbl(l_ctg_count).profile_exist
               := l_return_status ;

        IF l_return_status = 'Y'
        THEN
          l_grouping_id := NVL(l_grouping_id,0) + 1;

          x_item_limits_tbl(l_grouping_id).grouping_id :=
                 l_grouping_id ;

          x_item_limits_tbl(l_grouping_id).item_category_id :=
                l_curr_category_id ;

          x_item_limits_tbl(l_grouping_id).limit_curr_code :=
               l_limit_curr_code ;

          x_item_limits_tbl(l_grouping_id).item_limit :=
                     l_trx_limit ;
        END IF;

      END IF;
     -- end category_exist IF

     l_line_id         := NULL;
     l_trx_limit       := NULL;
     l_limit_curr_code := NULL;
     l_return_status   := NULL;
     l_curr_category_id := NULL;


   END LOOP;

   -- assign the values to the output table

   l_grouping_id      := NULL;
   l_curr_category_id := NULL;

   FOR ctg_id IN 1 .. x_item_limits_tbl.COUNT
   LOOP
     l_grouping_id :=
           x_item_limits_tbl(ctg_id).grouping_id ;

     l_curr_category_id := x_item_limits_tbl(ctg_id).item_category_id ;

     FOR ln_id IN 1 .. l_tmp_lines_tbl.COUNT
     LOOP
       IF l_tmp_lines_tbl(ln_id).item_category_id =
            l_curr_category_id
       THEN
         l_ln_count := NVL(l_ln_count,0) + 1 ;
         x_lines_tbl(l_ln_count).grouping_id        := l_grouping_id ;
         x_lines_tbl(l_ln_count).item_category_id   := l_curr_category_id ;
         x_lines_tbl(l_ln_count).line_id            :=
                          l_tmp_lines_tbl(ln_id).line_id ;
         x_lines_tbl(l_ln_count).unit_selling_price :=
                          l_tmp_lines_tbl(ln_id).unit_selling_price ;
         x_lines_tbl(l_ln_count).tax_value          :=
                          l_tmp_lines_tbl(ln_id).tax_value ;
         x_lines_tbl(l_ln_count).ordered_quantity   :=
                 l_tmp_lines_tbl(ln_id).ordered_quantity ;

         IF p_include_tax_flag = 'Y'
         THEN
           l_line_value := NVL(l_line_value,0) +
           ( NVL(l_tmp_lines_tbl(ln_id).tax_value,0 ) +
                      (  l_tmp_lines_tbl(ln_id).ordered_quantity
                      * l_tmp_lines_tbl(ln_id).unit_selling_price
                      )
           );
         ELSE
          l_line_value := NVL(l_line_value,0) +
                     (  l_tmp_lines_tbl(ln_id).ordered_quantity
                      * l_tmp_lines_tbl(ln_id).unit_selling_price
                      );
          END IF;
        END IF;
      END LOOP;

     x_item_limits_tbl(ctg_id).ctg_line_amount := NVL(l_line_value,0) ;
     l_line_value := NULL;

    END LOOP;

  ELSE

   OE_DEBUG_PUB.ADD(' No CTG credit profile found - No Item CC required ');


  END IF;  -- Profile check IF


   OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_Item_Limit ');


  EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_Item_Limit '
      );
    END IF;
    RAISE;


END GET_Item_Limit ;



-----------------------------------------------------------------------------
--  PROCEDURE  : Get_Multi_Limit    PRIVATE
--  COMMENT    :
--
---------------------------------------------------------------------------
PROCEDURE Get_Multi_Limit (
   p_entity_type                 IN  VARCHAR2
 , p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN
                           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_limit_curr_code             OUT NOCOPY
                           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_trx_limit                   OUT NOCOPY NUMBER
 , x_overall_limit               OUT NOCOPY NUMBER
 , x_global_exposure_flag        OUT NOCOPY VARCHAR2
--bug 4212981
 , x_site_cc_flag                OUT NOCOPY VARCHAR2
 , x_cust_cc_flag                OUT NOCOPY VARCHAR2
)
IS

l_return_status            VARCHAR2(1);
l_credit_usage_rule_set_id NUMBER;

BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: IN Get_Multi_Limit ');
  END IF;

   x_global_exposure_flag     := 'N' ;

   l_credit_usage_rule_set_id := NULL ;

   IF P_entity_Type = 'CUSTOMER'
   THEN
      GET_multi_customer_Limit
      ( p_entity_id       => p_entity_id
      , p_trx_curr_code   => p_trx_curr_code
      , x_limit_curr_code => x_limit_curr_code
      , x_trx_limit       => x_trx_limit
      , x_overall_limit   => x_overall_limit
      , x_return_status   => l_return_status
      , x_credit_usage_rule_set_id
                => l_credit_usage_rule_set_id
      , x_global_exposure_flag => x_global_exposure_flag
      );

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD(' Out NOCOPY GET_multi_customer_Limit '|| l_return_status );
        OE_DEBUG_PUB.ADD(' x_limit_curr_code = '|| x_limit_curr_code );
        OE_DEBUG_PUB.ADD(' x_trx_limit = '|| x_trx_limit );
        OE_DEBUG_PUB.ADD(' x_overall_limit = '|| x_overall_limit );
      END IF;

    x_cust_cc_flag := l_return_status;  --bug 4582292

    -- BUG 2236276
    -- roll up to next level if limits are NULL

      IF     l_return_status = 'Y'
         AND x_trx_limit is NULL
         AND x_overall_limit is NULL
      THEN
        l_return_status   := 'N' ;
        x_limit_curr_code := NULL ;
        x_global_exposure_flag := 'N' ;

        OE_DEBUG_PUB.ADD(' Limits NULL for customer MULTI ');

      END IF;

      IF NVL(l_return_status, 'N') = 'N' --bug 5071518
      THEN
        x_global_exposure_flag := 'N' ;
        l_credit_usage_rule_set_id := NULL ;

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.ADD(' Calling GET_Single_Customer_Limit ');
        END IF;

        GET_Single_Customer_Limit
        ( p_entity_id       => p_entity_id
        , p_trx_curr_code   => p_trx_curr_code
        , x_limit_curr_code => x_limit_curr_code
        , x_trx_limit       => x_trx_limit
        , x_overall_limit   => x_overall_limit
        , x_return_status   => l_return_status
        );

        IF G_debug_flag = 'Y'
        THEN
         OE_DEBUG_PUB.ADD(' Out NOCOPY GET_Single_Customer_Limit '
                     || l_return_status );
         OE_DEBUG_PUB.ADD(' x_limit_curr_code = '
                 || x_limit_curr_code );
         OE_DEBUG_PUB.ADD(' x_trx_limit = '|| x_trx_limit );
         OE_DEBUG_PUB.ADD(' x_overall_limit = '|| x_overall_limit );
        END IF;

        x_cust_cc_flag := l_return_status; -- bug 4582292

          IF     l_return_status = 'Y'
              AND x_trx_limit is NULL
              AND x_overall_limit is NULL
          THEN
            l_return_status   := 'N' ;
            x_limit_curr_code := NULL ;
            x_global_exposure_flag := 'N' ;
          END IF;
      END IF;


------------------------- Site level -------------------------

    ELSIF P_entity_Type = 'SITE'
    THEN
      x_global_exposure_flag := 'N' ;

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD(' Call GET_multi_site_Limit ');
      END IF;

      GET_multi_site_Limit
      ( p_entity_id       => p_entity_id
      , p_trx_curr_code   => p_trx_curr_code
      , x_limit_curr_code => x_limit_curr_code
      , x_trx_limit       => x_trx_limit
      , x_overall_limit   => x_overall_limit
      , x_return_status   => l_return_status
      );

      IF G_debug_flag = 'Y'
      THEN
         OE_DEBUG_PUB.ADD(' Out NOCOPY GET_multi_site_Limit '|| l_return_status );
         OE_DEBUG_PUB.ADD(' x_limit_curr_code = '|| x_limit_curr_code );
         OE_DEBUG_PUB.ADD(' x_trx_limit = '|| x_trx_limit );
         OE_DEBUG_PUB.ADD(' x_overall_limit = '|| x_overall_limit );
      END IF;

    x_site_cc_flag := l_return_status;  --bug 4212981
    -- BUG 4158439
    -- roll up to next level if limits are NULL

      IF     l_return_status = 'Y'
         AND x_trx_limit is NULL
         AND x_overall_limit is NULL
      THEN
        l_return_status   := 'N' ;
        x_limit_curr_code := NULL ;

        OE_DEBUG_PUB.ADD(' Limits NULL for site MULTI ');

      END IF;

      IF NVL(l_return_status, 'N') = 'N'  --bug 4582292
      THEN
        GET_Single_Site_Limit
        ( p_entity_id       => p_entity_id
        , p_trx_curr_code   => p_trx_curr_code
        , x_limit_curr_code => x_limit_curr_code
        , x_trx_limit       => x_trx_limit
        , x_overall_limit   => x_overall_limit
        , x_return_status   => l_return_status
        );

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.ADD(' Out NOCOPY GET_Single_Site_Limit '|| l_return_status );
          OE_DEBUG_PUB.ADD(' x_limit_curr_code = '|| x_limit_curr_code );
          OE_DEBUG_PUB.ADD(' x_trx_limit = '|| x_trx_limit );
          OE_DEBUG_PUB.ADD(' x_overall_limit = '|| x_overall_limit );
        END IF;

        x_site_cc_flag := l_return_status; --bug 4212981

          -- BUG 4158439
          IF     l_return_status = 'Y'
              AND x_trx_limit is NULL
              AND x_overall_limit is NULL
          THEN
            l_return_status   := 'N' ;
            x_limit_curr_code := NULL ;
            OE_DEBUG_PUB.ADD(' Limits NULL for site SINGLE ');
          END IF;

      END IF;

    ELSE
      NULL;
    END IF;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY Get_Multi_Limit ');
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' Get_Multi_Limit '
      );
    END IF;
    RAISE;


END Get_Multi_Limit ;



-----------------------------------------------------------------------------
--  PROCEDURE  : Get_SIngle_Limit    PRIVATE
--  COMMENT    : Returns the Limit for the SINGLE profile
--
---------------------------------------------------------------------------
PROCEDURE Get_SIngle_Limit (
   p_entity_type                 IN  VARCHAR2
 , p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN
                           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_limit_curr_code             OUT NOCOPY
                           HZ_CREDIT_PROFILE_AMTS.currency_code%TYPE
 , x_trx_limit                   OUT NOCOPY NUMBER
 , x_overall_limit               OUT NOCOPY NUMBER
 , x_default_limit_flag          OUT NOCOPY VARCHAR2
)
IS

l_return_status    VARCHAR2(1);

BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: IN Get_SIngle_Limit ');
  END IF;

    IF P_entity_Type = 'CUSTOMER'
    THEN
      GET_Single_Customer_Limit
      ( p_entity_id       => p_entity_id
      , p_trx_curr_code   => p_trx_curr_code
      , x_limit_curr_code => x_limit_curr_code
      , x_trx_limit       => x_trx_limit
      , x_overall_limit   => x_overall_limit
      , x_return_status   => l_return_status
      );

      IF l_return_status = 'N'
      THEN
        GET_single_default_Limit
        ( p_entity_id       => p_entity_id
        , p_trx_curr_code   => p_trx_curr_code
        , x_limit_curr_code => x_limit_curr_code
        , x_trx_limit       => x_trx_limit
        , x_overall_limit   => x_overall_limit
        , x_return_status   => x_default_limit_flag
        );

      ELSE
       x_default_limit_flag  := 'N' ;
      END IF;

    ELSIF P_entity_Type = 'SITE'
    THEN
      GET_Single_Site_Limit
      ( p_entity_id       => p_entity_id
      , p_trx_curr_code   => p_trx_curr_code
      , x_limit_curr_code => x_limit_curr_code
      , x_trx_limit       => x_trx_limit
      , x_overall_limit   => x_overall_limit
      , x_return_status   => l_return_status
      );

     x_default_limit_flag  := 'N' ;

    ELSE
      NULL;
    END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY Get_SIngle_Limit ');
  END IF;


  EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' Get_SIngle_Limit '
      );
    END IF;
    RAISE;


END Get_SIngle_Limit ;


------------------------------------------------------------------------------
--  PROCEDURE  : Get_Usages     PUBLIC
--  COMMENT    : Returns the Usages associated with a given
--               profile amount currency
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
, x_include_all_flag           OUT  NOCOPY VARCHAR2
, x_usage_curr_tbl             OUT  NOCOPY OE_CREDIT_CHECK_UTIL.curr_tbl_type
)
IS

  l_count  NUMBER;

--------------------------------------------------------
--  This cursor identifies the usage rule sets for    --
--  usages credit limit.                                     --
--------------------------------------------------------

CURSOR   party_rule_set_csr IS
  SELECT credit_usage_rule_set_id
  FROM   hz_credit_usages usg,
         hz_customer_profiles prf,
         hz_cust_profile_amts amt
  WHERE  usg.cust_acct_profile_amt_id   = amt.cust_acct_profile_amt_id
  AND    prf.cust_account_profile_id    = amt.cust_account_profile_id
  AND    amt.currency_code              = p_limit_curr_code
  AND    prf.cust_account_id            = -1
  AND    prf.site_use_id    IS NULL
  AND    prf.party_id                   = p_entity_id ;

CURSOR   cust_rule_set_csr IS
  SELECT credit_usage_rule_set_id
  FROM   hz_credit_usages usg,
         hz_customer_profiles prf,
         hz_cust_profile_amts amt
  WHERE  usg.cust_acct_profile_amt_id   = amt.cust_acct_profile_amt_id
  AND    prf.cust_account_profile_id    = amt.cust_account_profile_id
  AND    amt.currency_code              = p_limit_curr_code
  AND    prf.cust_account_id            = p_entity_id
  AND    prf.site_use_id    IS NULL;

CURSOR   site_rule_set_csr IS
  SELECT credit_usage_rule_set_id
  FROM   hz_credit_usages usg,
         hz_customer_profiles prf,
         hz_cust_profile_amts amt
  WHERE  usg.cust_acct_profile_amt_id   = amt.cust_acct_profile_amt_id
  AND    prf.cust_account_profile_id    = amt.cust_account_profile_id
  AND    amt.currency_code              = p_limit_curr_code
  AND    prf.site_use_id    = p_entity_id ;


--------------------------------------------------------
--  This cursor identifies the usage rule sets for    --
--  Default credit limit.                                     --
--------------------------------------------------------
CURSOR   dflt_rule_set_csr IS
  SELECT credit_usage_rule_set_id
  FROM   hz_credit_usages usg,
         hz_credit_profiles prf,
         hz_credit_profile_amts amt
  WHERE  usg.credit_profile_amt_id      = amt.credit_profile_amt_id
  AND    prf.credit_profile_id          = amt.credit_profile_id
  AND    amt.currency_code              = p_limit_curr_code
  AND    prf.organization_id            = G_ORG_ID ;



--------------------------------------------------------
--  This cursor identifies if the include all flag    --
--  is set for this usage rule set .                  --
--------------------------------------------------------

CURSOR   include_all_csr (c_credit_usage_rule_set_id IN NUMBER) IS
  SELECT 'X'
  FROM   hz_credit_usage_rules
  WHERE  credit_usage_rule_set_id = c_credit_usage_rule_set_id
  AND    usage_type = 'CURRENCY'
  AND    include_all_flag = 'Y';

--------------------------------------------------------
--  This cursor identifies all included usages        --
--  for this usage rule set .                         --
--------------------------------------------------------

CURSOR   incl_curr_csr (c_credit_usage_rule_set_id IN NUMBER) IS
  SELECT user_code
  FROM   hz_credit_usage_rules cur
  WHERE  cur.credit_usage_rule_set_id = c_credit_usage_rule_set_id
  AND    cur.usage_type               = 'CURRENCY'
  AND    cur.user_code                IS NOT NULL
  AND    NVL(cur.exclude_flag,'N')    = 'N';

--------------------------------------------------------
--  This cursor identifies all excluded usages        --
--  for this usage rule set .                         --
--------------------------------------------------------

CURSOR   excl_curr_csr (c_credit_usage_rule_set_id IN NUMBER) IS
  SELECT user_code
  FROM   hz_credit_usage_rules cur
  WHERE  cur.credit_usage_rule_set_id = c_credit_usage_rule_set_id
  AND    cur.usage_type               = 'CURRENCY'
  AND    cur.user_code                IS NOT NULL
  AND    cur.exclude_flag         = 'Y';

--------------------------------------------------------
--  This cursor identifies all currencies in which    --
--  transactions are available for this entity        --
--------------------------------------------------------
--- BUG 2352020
-- Bug 2417717 AR relationshops

CURSOR   trx_curr_csr_customer IS
  SELECT soh.transactional_curr_code user_code
  FROM   oe_order_headers    soh
     ,   hz_cust_acct_sites_all  cas
     ,   hz_cust_site_uses_all   su
  WHERE  soh.org_id            = su.org_id
    AND  soh.invoice_to_org_id = su.site_use_id
    AND  cas.cust_acct_site_id = su.cust_acct_site_id
    AND  cas.cust_account_id   = p_entity_id
  GROUP  BY transactional_curr_code
  UNION
  SELECT pay.invoice_currency_code user_code
  FROM   ar_payment_schedules pay
     ,   hz_cust_acct_sites_all  cas
     ,   hz_cust_site_uses_all   su
  WHERE  pay.org_id               = su.org_id
    AND  pay.customer_site_use_id = su.site_use_id
    AND  cas.cust_acct_site_id = su.cust_acct_site_id
    AND  cas.cust_account_id   = p_entity_id
  GROUP  BY invoice_currency_code
  UNION
  SELECT exs.currency_code
  FROM   oe_credit_summaries exs
  WHERE  exs.balance_type     = 18
   AND   exs.cust_account_id  = p_entity_id
   AND   NVL(exs.org_id,-99)  = G_ORG_ID;              /* MOAC_SQL_CHANGE */



CURSOR   trx_curr_csr_customer_global IS
  SELECT soh.transactional_curr_code user_code
  FROM   oe_order_headers_ALL     soh
    ,   hz_cust_acct_sites_ALL  cas
     ,   hz_cust_site_uses_ALL   su
  WHERE  soh.invoice_to_org_id = su.site_use_id
    AND  cas.cust_acct_site_id = su.cust_acct_site_id
    AND  cas.cust_account_id   = p_entity_id
  GROUP  BY transactional_curr_code
  UNION
  SELECT pay.invoice_currency_code user_code
  FROM   ar_payment_schedules_ALL pay
    ,   hz_cust_acct_sites_ALL  cas
     ,   hz_cust_site_uses_ALL   su
  WHERE  pay.customer_site_use_id = su.site_use_id
    AND  cas.cust_acct_site_id = su.cust_acct_site_id
    AND  cas.cust_account_id   = p_entity_id
  GROUP  BY invoice_currency_code
  UNION
  SELECT exs.currency_code
  FROM   oe_credit_summaries exs
  WHERE  exs.balance_type     = 18
   AND   exs.cust_account_id  = p_entity_id ;



CURSOR   trx_curr_csr_site IS
  SELECT soh.transactional_curr_code user_code
  FROM   oe_order_headers     soh
  WHERE  soh.invoice_to_org_id = p_entity_id
  GROUP  BY transactional_curr_code
  UNION
  SELECT pay.invoice_currency_code user_code
  FROM   ar_payment_schedules pay
  WHERE  pay.customer_site_use_id = p_entity_id
  GROUP  BY invoice_currency_code
  UNION
  SELECT exs.currency_code
  FROM   oe_credit_summaries exs
  WHERE  balance_type  = 18
   AND   site_use_id   = p_entity_id ;




  CURSOR C_g_use_party_hierarchy IS
  SELECT
    'Y'
   FROM
    hz_hierarchy_nodes hn
   WHERE  hn.parent_id                     = p_entity_id
  AND     hn.parent_object_type           = 'ORGANIZATION'
  and     hn.parent_table_name            = 'HZ_PARTIES'
  and     hn.child_object_type            = 'ORGANIZATION'
  and     hn.effective_start_date  <=  sysdatE
  and     hn.effective_end_date    >= SYSDATE
  and     hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type ;

  CURSOR party_txn_cur IS
  SELECT distinct ( currency_code)   user_code
  FROM   oe_credit_summaries
  WHERE  party_id  =  p_entity_id
    AND  bucket_duration     = OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH ;


 CURSOR party_h_txn_cur IS
  SELECT distinct ( oes.currency_code) user_code
  FROM   oe_credit_summaries oes
     ,   hz_hierarchy_nodes hn
  WHERE  hn.parent_id                    = p_entity_id
  AND  hn.parent_object_type           = 'ORGANIZATION'
  and  hn.parent_table_name            = 'HZ_PARTIES'
  and  hn.child_object_type            = 'ORGANIZATION'
  and  hn.effective_start_date  <=  sysdate
  and  hn.effective_end_date    >= SYSDATE
  and  hn.hierarchy_type
                = OE_CREDIT_CHECK_UTIL.G_hierarchy_type
  AND  oes.party_id                        =  hn.child_id
  AND  oes.bucket_duration     = OE_CREDIT_EXPOSURE_PVT.G_MAX_BUCKET_LENGTH ;


include_all_rec         include_all_csr%rowtype;
l_credit_limit_exist    VARCHAR2(1) ;


l_limit_flag           VARCHAR2(1) := 'N';
i                      NUMBER := 0;
j                      NUMBER := 1;
l_return_status        NUMBER;
l_credit_check_flag    VARCHAR2(2);
l_overall_limit        NUMBER;
l_trx_limit            NUMBER;

l_arrsize              NUMBER;

l_incl_curr_list       VARCHAR2(2000);
l_excl_curr_list       VARCHAR2(2000);
l_trx_curr_list        VARCHAR2(2000);
l_seperator            VARCHAR2(1) := '#';
l_currency             VARCHAR2(10);

l_start                NUMBER := 1;
l_end                  NUMBER := 1;

l_exclude_flag         VARCHAR2(1) := 'N' ;
l_use_party_hierarchy  VARCHAR2(1) ;

l_include_all_flag     VARCHAR2(1) := 'N' ;

BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: IN get_usages ');
    OE_DEBUG_PUB.ADD(' p_entity_type     = '|| p_entity_type );
    OE_DEBUG_PUB.ADD(' p_entity_id       = '|| p_entity_id   );
    OE_DEBUG_PUB.ADD(' p_limit_curr_code = '|| p_limit_curr_code );
    OE_DEBUG_PUB.ADD(' p_suppress_unused_usages_flag = '||
         p_suppress_unused_usages_flag );
    OE_DEBUG_PUB.ADD(' p_global_exposure_flag '||
             p_global_exposure_flag );

    OE_DEBUG_PUB.ADD(' ---------------------------------------------- ');

  END IF;

  OE_CREDIT_CHECK_UTIL.G_excl_curr_list := NULL ;
  l_exclude_flag := 'N' ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' Credit Limit found ');
  END IF;

  ---------------------------------------------------
  -- First get all usage rule sets for this limit  --
  ---------------------------------------------------

  IF NVL(p_default_limit_flag,'N')  = 'N'
  THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' Into Default limit = N ');
    END IF;

    IF p_entity_type = 'PARTY'
    THEN
      FOR rule_set_rec IN party_rule_set_csr
      LOOP
        OPEN include_all_csr
          (rule_set_rec.credit_usage_rule_set_id);

        FETCH include_all_csr
        INTO  include_all_rec;

        IF include_all_csr%FOUND
        THEN
          l_include_all_flag := 'Y';
        ELSE
          l_include_all_flag := 'N';
        END IF;

        CLOSE include_all_csr;

        --------------------------------------------------------
        -- identify the included currencies for each rule set --
        --------------------------------------------------------
          FOR incl_curr_rec
          IN  incl_curr_csr
              (rule_set_rec.credit_usage_rule_set_id)
          LOOP
            l_incl_curr_list :=
            l_incl_curr_list || l_seperator || incl_curr_rec.user_code;
          END LOOP;

        --------------------------------------------------------
        -- identify the excluded currencies for each rule set --
        --------------------------------------------------------

        FOR excl_curr_rec
        IN  excl_curr_csr
              (rule_set_rec.credit_usage_rule_set_id)
        LOOP
            l_excl_curr_list :=
            l_excl_curr_list || l_seperator || excl_curr_rec.user_code;
            l_exclude_flag := 'Y' ;
        END LOOP;
      END LOOP;
    ELSIF p_entity_type = 'CUSTOMER'
    THEN
      FOR rule_set_rec IN cust_rule_set_csr
      LOOP
          OPEN include_all_csr
             (rule_set_rec.credit_usage_rule_set_id);

          FETCH include_all_csr
          INTO  include_all_rec;

          IF include_all_csr%FOUND
          THEN
            l_include_all_flag := 'Y';
          ELSE
            l_include_all_flag := 'N';
          END IF;

          CLOSE include_all_csr;

        --------------------------------------------------------
        -- identify the included currencies for each rule set --
        --------------------------------------------------------
          FOR incl_curr_rec
          IN  incl_curr_csr
              (rule_set_rec.credit_usage_rule_set_id)
          LOOP
            l_incl_curr_list :=
            l_incl_curr_list || l_seperator || incl_curr_rec.user_code;
          END LOOP;

        --------------------------------------------------------
        -- identify the excluded currencies for each rule set --
        --------------------------------------------------------

          FOR excl_curr_rec
          IN  excl_curr_csr
                (rule_set_rec.credit_usage_rule_set_id)
          LOOP
            l_excl_curr_list :=
            l_excl_curr_list || l_seperator || excl_curr_rec.user_code;
            l_exclude_flag := 'Y' ;
          END LOOP;
      END LOOP;
      -- End rule_set_rec

    ELSE   --- SITE level
      FOR rule_set_rec IN site_rule_set_csr
      LOOP
          OPEN include_all_csr
             (rule_set_rec.credit_usage_rule_set_id);

          FETCH include_all_csr
          INTO  include_all_rec;

          IF include_all_csr%FOUND
          THEN
            l_include_all_flag := 'Y';
          ELSE
            l_include_all_flag := 'N';
          END IF;
          CLOSE include_all_csr;

        --------------------------------------------------------
        -- identify the included currencies for each rule set --
        --------------------------------------------------------
          FOR incl_curr_rec
          IN  incl_curr_csr
            (rule_set_rec.credit_usage_rule_set_id)
          LOOP
            l_incl_curr_list :=
            l_incl_curr_list || l_seperator || incl_curr_rec.user_code;
          END LOOP;

        --------------------------------------------------------
        -- identify the excluded currencies for each rule set --
        --------------------------------------------------------

          FOR excl_curr_rec
          IN  excl_curr_csr
              (rule_set_rec.credit_usage_rule_set_id)
          LOOP
            l_excl_curr_list :=
            l_excl_curr_list || l_seperator || excl_curr_rec.user_code;
            l_exclude_flag := 'Y' ;
          END LOOP;

      END LOOP;
      -- End rule_set_rec
    END IF;
    -- end entity type IF

  ELSE
    -- Default limit = 'Y'

    IF G_debug_flag = 'Y'
    THEN
        OE_DEBUG_PUB.ADD(' Into Default limit = Y ');
    END IF ;

    FOR rule_set_rec IN dflt_rule_set_csr
    LOOP
        OPEN include_all_csr
             (rule_set_rec.credit_usage_rule_set_id);

        FETCH include_all_csr
        INTO  include_all_rec;

        IF include_all_csr%FOUND
        THEN
          l_include_all_flag := 'Y';
        ELSE
          l_include_all_flag := 'N';
        END IF;

        CLOSE include_all_csr;

      --------------------------------------------------------
      -- identify the included currencies for each rule set --
      --------------------------------------------------------

      FOR incl_curr_rec
      IN  incl_curr_csr
              (rule_set_rec.credit_usage_rule_set_id)
      LOOP
          l_incl_curr_list :=
	  l_incl_curr_list || l_seperator || incl_curr_rec.user_code;
      END LOOP;

      --------------------------------------------------------
      -- identify the excluded currencies for each rule set --
      --------------------------------------------------------

      FOR excl_curr_rec
      IN  excl_curr_csr
              (rule_set_rec.credit_usage_rule_set_id)
      LOOP
          l_excl_curr_list :=
	  l_excl_curr_list || l_seperator || excl_curr_rec.user_code;
          l_exclude_flag := 'Y' ;
      END LOOP;
    END LOOP;
      -- End dflt_rule_set_csr
  END IF;
  -- End default flag IF

  OE_CREDIT_CHECK_UTIL.G_excl_curr_list := l_excl_curr_list ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' G_excl_curr_list => '||
    OE_CREDIT_CHECK_UTIL.G_excl_curr_list );
  END IF;
-----------------------------------------------------------
  ---------------------------------------------
  -- identify all the transaction currencies
  --  This is required if we need to eliminate the
  -- currencies that were never used for any Orders
  -- or if Include all is set to Yes, as we need to
  -- find out NOCOPY the actual currencies
  ---------------------------------------------

  -- p_suppress_unused_usages_flag is used in conjunction
  -- with the l_include_all_flag
  -- The purpose of this flag is to get the transaction curr
  -- list even if the INCLUDE_ALL currency is set to Y
  -- For pre-calculated exposure, the include all flag alone
  -- is enough. But for online exposure calc, the transaction curr
  -- list is crucial even if include all currency is set to Y
  -- The reason being, the exposure calculation must know
  -- what currencies actualy have transactions against to avoid
  -- scanning the order tables for all currencies

  l_use_party_hierarchy := 'N' ;
  IF l_include_all_flag = 'Y' AND p_suppress_unused_usages_flag = 'Y'
  THEN
    IF p_entity_type = 'PARTY'
    THEN
      OPEN C_g_use_party_hierarchy ;
      FETCH C_g_use_party_hierarchy
      INTO l_use_party_hierarchy ;
      CLOSE C_g_use_party_hierarchy ;

      IF l_use_party_hierarchy = 'Y'
      THEN
        FOR trx_curr_rec
          IN party_h_txn_cur
        LOOP
          l_trx_curr_list :=
          l_trx_curr_list || l_seperator || trx_curr_rec.user_code;
        END LOOP;
      ELSE
        FOR trx_curr_rec
        IN party_txn_cur
        LOOP
          l_trx_curr_list :=
          l_trx_curr_list || l_seperator || trx_curr_rec.user_code;
        END LOOP;
      END IF; --- global
    END IF;

    IF p_entity_type = 'CUSTOMER'
    THEN
      IF p_global_exposure_flag = 'Y'
      THEN
          FOR trx_curr_rec
            IN trx_curr_csr_customer_global
          LOOP
            l_trx_curr_list :=
            l_trx_curr_list || l_seperator || trx_curr_rec.user_code;
          END LOOP;
      ELSE
          FOR trx_curr_rec
          IN trx_curr_csr_customer
          LOOP
            l_trx_curr_list :=
            l_trx_curr_list || l_seperator || trx_curr_rec.user_code;
          END LOOP;
      END IF; --- global
    END IF;

    IF p_entity_type = 'SITE'
    THEN
        FOR trx_curr_rec
        IN trx_curr_csr_site
        LOOP
          l_trx_curr_list :=
            l_trx_curr_list || l_seperator || trx_curr_rec.user_code;
        END LOOP;
    END IF;

  END IF;
    -- end l_include_all_flag, p_suppress IF


----------------- Start creating the usages curr table list ------

    IF p_suppress_unused_usages_flag = 'Y'
       AND l_include_all_flag = 'Y'
    THEN

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD(' into suppress = Y ');
      END IF;

      -------------------------------------------------------
      -- include only the intersection of incl currencies  --
      -- and transaction currencies                        --
      -------------------------------------------------------
      l_start := 1;
      l_end   := 1;

      LOOP
        l_start := INSTRB (l_trx_curr_list,l_seperator,l_end,1);
        l_end   := INSTRB (l_trx_curr_list,l_seperator,l_start+1,1);

        IF NVL(l_start,0) = 0
        THEN
          -- List completed
          EXIT;
        END IF;

        IF NVL(l_end,0) = 0
        THEN
          l_end := LENGTHB (l_trx_curr_list) + 1;
        END IF;

        l_currency := SUBSTRB ( l_trx_curr_list
			    , ( l_start + 1 )
			    , ( l_end - l_start - 1 )
			    );
        IF  NVL(INSTRB (l_incl_curr_list,l_currency,1,1),0) <> 0
          AND NVL(INSTRB (l_excl_curr_list,l_currency,1,1),0) = 0
        THEN
          i := i + 1;
          x_usage_curr_tbl(i).usage_curr_code := l_currency;

          IF l_currency = p_limit_curr_code
          THEN
            l_limit_flag := 'Y';
          END IF;
        END IF;
      END LOOP;

    ELSE
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD(' into suppress = N ');
      END IF;

      -------------------------------------------------------
      -- first include all incl currencies (minus excl)    --
      -------------------------------------------------------
      l_start := 1;
      l_end   := 1;

      LOOP
        l_start := INSTRB (l_incl_curr_list,l_seperator,l_end,1);
        l_end   := INSTRB (l_incl_curr_list,l_seperator,l_start+1,1);

        IF NVL(l_start,0) = 0
        THEN
          EXIT;
        END IF;

        IF NVL(l_end,0) = 0
        THEN
          l_end := LENGTHB (l_incl_curr_list) + 1;
        END IF;

        l_currency := SUBSTRB ( l_incl_curr_list
                            , ( l_start + 1 )
  			    , ( l_end - l_start - 1 )
			    );

        IF NVL(INSTRB (l_excl_curr_list,l_currency,1,1),0) = 0
        THEN
          i := i + 1;
          x_usage_curr_tbl(i).usage_curr_code := l_currency;

          IF l_currency = p_limit_curr_code
          THEN
            l_limit_flag := 'Y';
          END IF;
        END IF;
      END LOOP;
    END IF;
    -- end suppress flag IF

    IF l_include_all_flag = 'Y'
    THEN
      --------------------------------------------------------------
      -- include all trx currencies that are not already included --
      --------------------------------------------------------------
      l_start := 1;
      l_end   := 1;

      LOOP
        l_start := INSTRB (l_trx_curr_list,l_seperator,l_end,1);
        l_end   := INSTRB ( l_trx_curr_list ,l_seperator,l_start+1,1);

        IF NVL(l_start,0) = 0
        THEN
          EXIT;
        END IF;

        IF NVL(l_end,0) = 0
        THEN
          l_end := LENGTHB (l_trx_curr_list) + 1;
        END IF;

        l_currency := SUBSTRB ( l_trx_curr_list
			      , ( l_start + 1 )
			      , ( l_end - l_start - 1 )
			      );
        IF NVL(INSTRB (l_incl_curr_list,l_currency,1,1),0) = 0
          AND NVL(INSTRB (l_excl_curr_list,l_currency,1,1),0) = 0
        THEN
          i := i + 1;
          x_usage_curr_tbl(i).usage_curr_code := l_currency;

          IF l_currency = p_limit_curr_code
          THEN
            l_limit_flag := 'Y';
          END IF;
        END IF;
      END LOOP;

    END IF;
    -- end l_include_all_flag IF

  -------------------------------------
  -- if the limit currency code is   --
  -- not already included, do it now --
  -------------------------------------
  IF l_limit_flag = 'N'
  THEN
    i := NVL(i,0) + 1;
    x_usage_curr_tbl(i).usage_curr_code := p_limit_curr_code;
  END IF;

  IF l_exclude_flag = 'Y'
  THEN
    IF p_suppress_unused_usages_flag = 'Y' THEN
      l_include_all_flag := 'N' ;
    END IF;
  END IF;

  x_include_all_flag := l_include_all_flag;

  IF G_debug_flag = 'Y'
  THEN
   OE_DEBUG_PUB.ADD('OEXUCRCB: OUT get_usages ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'get_usages'
      );
    END IF;
    RAISE;

END get_usages ;


-----------------------------------------------------------------------------
--  PROCEDURE: GET_System_parameters           PUBLIC
--  COMMENT    : Returns the OE system parameter info for the current org
--  MODIFICATION:
--  02/12/2002 vto Added NVL on org_id to handle multi-org/non multi-org setup
------------------------------------------------------------------------------
PROCEDURE GET_System_parameters
( x_system_parameter_rec OUT NOCOPY
             OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
)
IS
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_System_parameters');
  END IF;

--  BEGIN   /* MOAC CREDIT CHECK CHANGE */
  -- Start Sys Param Change
  /*
    SELECT
      org_id
    , master_organization_id
    , customer_relationships_flag
    INTO
      x_system_parameter_rec.org_id
    , x_system_parameter_rec.master_organization_id
    , x_system_parameter_rec.customer_relationships_flag
  FROM
    OE_system_parameters_all
  WHERE NVL(org_id,-99) = G_ORG_ID;
  */

  /* Start MOAC CREDIT CHECK CHANGE */
  /*
  x_system_parameter_rec.org_id := G_ORG_ID;
  x_system_parameter_rec.master_organization_id
                 := oe_sys_parameters.value('MASTER_ORGANIZATION_ID', G_ORG_ID);
  x_system_parameter_rec.customer_relationships_flag
                 :=oe_sys_parameters.value('CUSTOMER_RELATIONSHIPS_FLAG', G_ORG_ID);
  -- End Sys Param Change

    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      x_system_parameter_rec := NULL ;
      OE_DEBUG_PUB.ADD(' Exception Get Syetem parameters');
  END ;
  */
  /* End MOAC CREDIT CHECK CHANGE */

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT GET_System_parameters');
  END IF;
 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'GET_System_parameters'
      );
    END IF;
    RAISE;

END GET_System_parameters ;

---------------------------------------------------------------------------
--PROCEDURE: Get_Credit_Check_Rule_ID
--COMMENT:   Returns the credit check rule id attached with
--          the order trn type
---------------------------------------------------------------------------
PROCEDURE Get_Credit_Check_Rule_ID
( p_calling_action       IN VARCHAR2
, p_order_type_id        IN OE_ORDER_HEADERS.order_type_id%TYPE
, x_credit_rule_id      OUT NOCOPY
                            OE_Credit_check_rules.credit_check_rule_id%TYPE
)
IS
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: In Get_Credit_Check_Rule_ID ');
    OE_DEBUG_PUB.ADD('p_order_type_id = '|| p_order_type_id );
    OE_DEBUG_PUB.ADD('p_calling_action = '|| p_calling_action );
  END IF;

  x_credit_rule_id := NULL ;

  IF p_calling_action in ('BOOKING','BOOKING_INLINE','AUTO','UPDATE')
  THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('Selecting the order entry credit check rule');
    END IF;
/*7194250
    SELECT ENTRY_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V
    WHERE  ORDER_TYPE_ID = p_order_type_id;
7194250*/
--7194250
    SELECT NVL(ENTRY_CREDIT_CHECK_RULE_ID, -1)
    INTO x_credit_rule_id
    FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE OT.ORDER_TYPE_ID = p_order_type_id
    AND   ENTRY_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250

    OE_Verify_Payment_PUB.G_credit_check_rule := 'Ordering';   --ER#7479609

  ELSIF p_calling_action = 'SHIPPING'
   THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add('Selecting the shipping credit check rule');
    END IF;

/*7194250
    SELECT SHIPPING_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V
    WHERE  ORDER_TYPE_ID = p_order_type_id;
7194250*/
--7194250
    SELECT NVL(SHIPPING_CREDIT_CHECK_RULE_ID, -1)
    INTO x_credit_rule_id
    FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE OT.ORDER_TYPE_ID = p_order_type_id
    AND   SHIPPING_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250

    OE_Verify_Payment_PUB.G_credit_check_rule := 'Shipping';   --ER#7479609

  ELSIF p_calling_action = 'PICKING'
  THEN

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add('Selecting the picking credit check rule');
    END IF;

/*7194250
    SELECT PICKING_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V
    WHERE  ORDER_TYPE_ID = p_order_type_id;
7194250*/
--7194250
   SELECT NVL(PICKING_CREDIT_CHECK_RULE_ID, -1)
    INTO x_credit_rule_id
    FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE OT.ORDER_TYPE_ID = p_order_type_id
    AND   PICKING_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250

    OE_Verify_Payment_PUB.G_credit_check_rule := 'Picking/Purchase Release';   --ER#7479609

  ELSIF p_calling_action = 'PACKING'
  THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add('Selecting the packing credit check rule');
    END IF;

/*7194250
    SELECT PACKING_CREDIT_CHECK_RULE_ID
    INTO   x_credit_rule_id
    FROM   OE_ORDER_TYPES_V
    WHERE  ORDER_TYPE_ID = p_order_type_id;
7194250*/
--7194250
    SELECT NVL(PACKING_CREDIT_CHECK_RULE_ID, -1)
    INTO x_credit_rule_id
    FROM OE_ORDER_TYPES_V OT,OE_CREDIT_CHECK_RULES CCR
    WHERE OT.ORDER_TYPE_ID = p_order_type_id
    AND   PACKING_CREDIT_CHECK_RULE_ID=CCR.CREDIT_CHECK_RULE_ID
    AND Trunc(SYSDATE) BETWEEN NVL(CCR.START_DATE_ACTIVE, Trunc(SYSDATE)) AND NVL(CCR.END_DATE_ACTIVE, Trunc(SYSDATE));
--7194250
  END IF;
    OE_Verify_Payment_PUB.G_credit_check_rule := 'Packing';   --ER#7479609

  IF G_debug_flag = 'Y'
  THEN

    OE_DEBUG_PUB.ADD('OEXUCRCB: Credit Check Rule ID: '
       ||TO_CHAR(x_credit_rule_id) );

    OE_DEBUG_PUB.ADD('OEXUCRCB: Out NOCOPY Get_Credit_Check_Rule_ID');
  END IF;


EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
   x_credit_rule_id := NULL ;
   OE_DEBUG_PUB.ADD('EXCEPTION:No credit check rule found');
  WHEN OTHERS THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME
      ,   'Get_Credit_Check_Rule_ID'
      );
    END IF;
    RAISE ;
END Get_Credit_Check_Rule_ID ;



-----------------------------------------------------------------------------
--  FUNCTION   : GET_credit_check_level
--  COMMENT    : Returns ORDER or LINE
--  BUG 2114156
------------------------------------------------------------------------------
FUNCTION GET_credit_check_level
( p_calling_action     IN VARCHAR2
, p_order_type_id      IN NUMBER
) RETURN VARCHAR2
IS

l_level VARCHAR2(30);
l_credit_check_rule_id NUMBER;
l_credit_check_rule_rec
        OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type ;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_credit_check_level ');
    OE_DEBUG_PUB.ADD('p_calling_action = '|| p_calling_action );
    OE_DEBUG_PUB.ADD('p_order_type_id = '|| p_order_type_id );
  END IF;

  l_level := NULL ;
  l_credit_check_rule_id := NULL ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('  Calling Get_Credit_Check_Rule_ID ');
  END IF;

  OE_Credit_CHECK_UTIL.Get_Credit_Check_Rule_ID
  ( p_calling_action        => p_calling_action
  , p_order_type_id         => p_order_type_id
  , x_credit_rule_id        => l_credit_check_rule_id
  );

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' out NOCOPY l_credit_check_rule_id = '||
       l_credit_check_rule_id );
  END IF;

  IF l_credit_check_rule_id is NULL
  THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' No credit check attached ');
    END IF;

    l_level := NULL ;

  ELSE

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: Call GET_credit_check_rule ');
  END IF;

     OE_CREDIT_CHECK_UTIL.GET_credit_check_rule
    ( p_credit_check_rule_id   => l_credit_check_rule_id
    , x_credit_check_rules_rec => l_credit_check_rule_rec
    );

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('credit_check_level_code = '||
       l_credit_check_rule_rec.credit_check_level_code );
    END IF;

       l_level := l_credit_check_rule_rec.credit_check_level_code ;

  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_credit_check_level ' || l_level);
  END IF;

  RETURN( l_level ) ;

 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'GET_credit_check_level'
      );
    END IF;
    RAISE;

END GET_credit_check_level ;

-----------------------------------------------------------------------------
--  PROCEDURE: GET_credit_check_rule           PUBLIC
--  COMMENT    : Returns the OE credit check rules info for the current org
--
------------------------------------------------------------------------------
PROCEDURE GET_credit_check_rule
( p_header_id              IN NUMBER := NULL
, p_credit_check_rule_id   IN NUMBER
, x_credit_check_rules_rec OUT NOCOPY
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
)
IS

BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_credit_check_rule ' );
  END IF;

  BEGIN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' Select for ID ' || p_credit_check_rule_id );
    END IF;


    SELECT
      credit_check_rule_id
    , name
    , failure_result_code
    , open_ar_balance_flag
    , uninvoiced_orders_flag
    , orders_on_hold_flag
    , shipping_interval
    , open_ar_days
    , start_date_active
    , end_date_active
    , include_payments_at_risk_flag
    , NVL(include_tax_flag,'N')
    , maximum_days_past_due
    , NVL(QUICK_CR_CHECK_FLAG,'N')
    , NVL(incl_freight_charges_flag,'N')
    , DECODE( shipping_interval, NULL,
              TO_DATE('31/12/4712','DD/MM/YYYY'), shipping_interval + SYSDATE
            )
    , NVL(credit_check_level_code,'ORDER')
    , NVL(credit_hold_level_code,'ORDER')
    , conversion_type
    , NVL(check_item_categories_flag,'N')
    , NVL(send_hold_notifications_flag,'N')
    , days_honor_manual_release
    , NVL(include_external_exposure_flag, 'N')
    ,  NVL(include_returns_flag, 'N')
      --ER 12363706 start
    ,  Tolerance_Percentage
    ,  Tolerance_Curr_Code
    ,  Tolerance_Amount
      --ER 12363706 end
    INTO x_credit_check_rules_rec.credit_check_rule_id
    ,  x_credit_check_rules_rec.name
    ,  x_credit_check_rules_rec.failure_result_code
    ,  x_credit_check_rules_rec.open_ar_balance_flag
    ,  x_credit_check_rules_rec.uninvoiced_orders_flag
    ,  x_credit_check_rules_rec.orders_on_hold_flag
    ,  x_credit_check_rules_rec.shipping_interval
    ,  x_credit_check_rules_rec.open_ar_days
    ,  x_credit_check_rules_rec.start_date_active
    ,  x_credit_check_rules_rec.end_date_active
    ,  x_credit_check_rules_rec.include_payments_at_risk_flag
    ,  x_credit_check_rules_rec.include_tax_flag
    ,  x_credit_check_rules_rec.maximum_days_past_due
    ,  x_credit_check_rules_rec.QUICK_CR_CHECK_FLAG
    ,  x_credit_check_rules_rec.incl_freight_charges_flag
    ,  x_credit_check_rules_rec.shipping_horizon
    ,  x_credit_check_rules_rec.credit_check_level_code
    ,  x_credit_check_rules_rec.credit_hold_level_code
    ,  x_credit_check_rules_rec.conversion_type
    ,  x_credit_check_rules_rec.check_item_categories_flag
    ,  x_credit_check_rules_rec.send_hold_notifications_flag
    ,  x_credit_check_rules_rec.days_honor_manual_release
    ,  x_credit_check_rules_rec.include_external_exposure_flag
    ,  x_credit_check_rules_rec.include_returns_flag
      --ER 12363706 start
    ,  x_credit_check_rules_rec.Tolerance_Percentage
    ,  x_credit_check_rules_rec.Tolerance_Curr_Code
    ,  x_credit_check_rules_rec.Tolerance_Amount
      --ER 12363706 end
    FROM
      OE_Credit_Check_rules
    WHERE credit_check_rule_id = p_credit_check_rule_id ;

      --bug 5031301
      /*The Include Open Recaivables cursors which we use includes payments at risk also.
        This will make the cursors behave as follows:
	If open_ar_balance_flag = 'Y' AND include_risk_flag ='Y' then
		Just consider AR balance, as it already includes payments at risk.
		Ignore payments at risk cursor value
	Else if open_ar_balance_flag = 'Y' AND include_risk_flag ='N' then
		Consider both AR balance and payments at risk, so that it nullifies the effect.
		As such we are not considering payments at risk.
	Else (both are 'N')
		Do Nothing.
	End if*/
	IF x_credit_check_rules_rec.open_ar_balance_flag ='Y'
	   AND x_credit_check_rules_rec.include_payments_at_risk_flag = 'Y'
	THEN
	   x_credit_check_rules_rec.include_payments_at_risk_flag := 'N';
	ELSIF x_credit_check_rules_rec.open_ar_balance_flag ='Y'
	   AND x_credit_check_rules_rec.include_payments_at_risk_flag = 'N'
	THEN
	   x_credit_check_rules_rec.include_payments_at_risk_flag := 'Y';
	END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      x_credit_check_rules_rec := NULL ;
      OE_DEBUG_PUB.ADD(' Get credit check rule No_Data_Found exception ' );

    WHEN TOO_MANY_ROWS
    THEN
      x_credit_check_rules_rec := NULL ;
      OE_DEBUG_PUB.ADD(' Get credit check rule TOO_MANY_ROWS ');
  END ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' conversion_type = '
      || x_credit_check_rules_rec.conversion_type );
  END IF;

  BEGIN
    IF NVL(x_credit_check_rules_rec.conversion_type,'Corporate')
     NOT IN ('Corporate','User')
    THEN
      BEGIN
        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.ADD(' Select user_conversion_type ');
        END IF;

        SELECT
          user_conversion_type
        INTO
          x_credit_check_rules_rec.user_conversion_type
        FROM
         GL_DAILY_CONVERSION_TYPES
        WHERE conversion_type =  x_credit_check_rules_rec.conversion_type ;

        EXCEPTION

        WHEN NO_DATA_FOUND
        THEN
          x_credit_check_rules_rec.user_conversion_type :=
              x_credit_check_rules_rec.conversion_type ;
          OE_DEBUG_PUB.ADD(' conversion type NO_DATA_FOUND ');

        WHEN TOO_MANY_ROWS
        THEN
           x_credit_check_rules_rec.user_conversion_type :=
              x_credit_check_rules_rec.conversion_type ;
          OE_DEBUG_PUB.ADD(' conversion type TOO_MANY_ROWS ');
     END ;

   ELSE
     IF G_debug_flag = 'Y'
     THEN
      OE_DEBUG_PUB.ADD(' No need for selct user_conversion_type ');
     END IF;

    x_credit_check_rules_rec.user_conversion_type :=
          x_credit_check_rules_rec.conversion_type ;
   END IF;


  END ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('Conversion type = '
           || x_credit_check_rules_rec.conversion_type );

    OE_DEBUG_PUB.ADD('User Conversion type = '
           || x_credit_check_rules_rec.user_conversion_type );

    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_credit_check_rule ' );
  END IF;

 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'GET_credit_check_rule'
      );
    END IF;
    RAISE;

END GET_credit_check_rule ;

-----------------------------------------------------------------------------
--  PROCEDURE  : Rounded_Amount    PUBLIC
--  COMMENT    : Returns rounded amount
--  BUG  4320650
---------------------------------------------------------------------------

PROCEDURE Rounded_Amount
(  p_currency_code      IN   VARCHAR2
,  p_unrounded_amount   IN   NUMBER
,  x_rounded_amount     OUT NOCOPY NUMBER
)
IS
l_precision         NUMBER;
l_ext_precision     NUMBER;
l_min_acct_unit     NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXUCRCB: IN  ROUNDED_AMOUNT ( )  WITH AMOUNT : ' ||P_UNROUNDED_AMOUNT , 5 ) ;
     END IF;
     FND_CURRENCY.GET_INFO(Currency_Code => p_currency_code,
                           precision     => l_precision,
                           ext_precision => l_ext_precision,
                           min_acct_unit => l_min_acct_unit);

     IF (l_min_acct_unit = 0 OR l_min_acct_unit IS NULL) THEN
          x_rounded_amount := ROUND(p_unrounded_amount, l_precision);
     ELSE
          x_rounded_amount := ROUND(p_unrounded_amount/l_min_acct_unit)*l_min_acct_unit;
     END IF;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXUCRCB: OUT ROUNDED AMOUNT ( ) WITH AMOUNT : '||X_ROUNDED_AMOUNT , 5 ) ;
     END IF;
END Rounded_Amount;
--ER 12363706 start
--------------------------------------------------------------------------------------------
-- Procedure Update_Released_Amount
-- This procedure is added to update the OCM released amount in OE_HOLD_RELEASES table
-- that will be used for Tolerance Check.
--------------------------------------------------------------------------------------------
PROCEDURE Update_Released_Amount(
    p_header_id       NUMBER,
    p_hold_release_id NUMBER)
IS
  l_credit_check_rule_id NUMBER;
  l_credit_check_rule_rec OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type ;
  l_header_rec OE_Order_PUB.Header_Rec_Type;
  l_released_amount NUMBER;
  l_calling_action  VARCHAR2(30);
  l_conversion_status OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE;
  l_return_status VARCHAR2(30);
BEGIN
  IF G_debug_flag = 'Y' THEN
    oe_debug_pub.add('Starting Update_Released_Amount');
    oe_debug_pub.add('Header ID:'||p_header_id);
    oe_debug_pub.add('Hold Release ID:'||p_hold_release_id);
  END IF;
  l_calling_action := OE_Verify_Payment_PUB.Which_Rule(p_header_id => p_header_id);
  IF G_debug_flag         = 'Y' THEN
	  oe_debug_pub.add('OEXUCRCB: l_calling_action ' || l_calling_action);
  END IF;
  OE_HEADER_UTIL.QUERY_ROW ( p_header_id => p_header_id, x_header_rec => l_header_rec);
  OE_CREDIT_CHECK_UTIL.Get_Credit_Check_Rule_ID ( p_calling_action => l_calling_action , p_order_type_id => l_header_rec.order_type_id , x_credit_rule_id => l_credit_check_rule_id );
  IF G_debug_flag         = 'Y' THEN
	  oe_debug_pub.add('OEXUCRCB: l_credit_check_rule_id ' || l_credit_check_rule_id);
  END IF;

  OE_CREDIT_CHECK_UTIL.GET_credit_check_rule ( p_header_id => p_header_id ,
   					       p_credit_check_rule_id => l_credit_check_rule_id ,
					       x_credit_check_rules_rec => l_credit_check_rule_rec );

  l_credit_check_rule_rec.credit_check_level_code := 'ORDER';

  OE_CREDIT_CHECK_UTIL.GET_transaction_amount ( p_header_id => p_header_id ,
  						p_transaction_curr_code => l_header_rec.transactional_curr_code ,
						p_credit_check_rule_rec => l_credit_check_rule_rec ,
						p_system_parameter_rec => NULL ,
						p_customer_id => NULL ,
						p_site_use_id => NULL ,
						p_limit_curr_code => l_header_rec.transactional_curr_code ,
						p_all_lines => 'Y' ,
						x_amount => l_released_amount ,
						x_conversion_status => l_conversion_status ,
						x_return_status => l_return_status );
  IF G_debug_flag         = 'Y' THEN
	  oe_debug_pub.add('OEXUCRCB: l_released_amount ' || l_released_amount);
	  oe_debug_pub.add('OEXUCRCB: l_return_status ' || l_return_status);
  END IF;

  UPDATE OE_HOLD_RELEASES
  SET Released_Order_Amount=l_released_amount,
    Released_Curr_code     =l_header_rec.transactional_curr_code,
    Last_Update_Date       = sysdate,
    Last_Updated_By        = FND_GLOBAL.user_id
  WHERE hold_release_id    =p_hold_release_id;

  IF G_debug_flag          = 'Y' THEN
    oe_debug_pub.add('Ending Update_Released_Amount');
  END IF;
EXCEPTION
WHEN OTHERS THEN
  IF G_debug_flag = 'Y' THEN
    oe_debug_pub.add('Error in Update_Released_Amount:'||SUBSTR(SQLERRM,1,250));
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Update_Released_Amount;
--------------------------------------------------------------------------------------------
-- Procedure Update_Credit_Profile_Level
-- This procedure is added to update the Credit Profile Lvel in OE_ORDER_HOLDS_ALL table
-- that will be used to decide if the Bill to Change should trigger Credit Checing or not.
--------------------------------------------------------------------------------------------
PROCEDURE Update_Credit_Profile_Level(
    p_hold_source_rec IN  OE_HOLDS_PVT.Hold_Source_Rec_Type)
IS
  l_hold_source_id NUMBER;
BEGIN
	IF G_debug_flag = 'Y' THEN
		oe_debug_pub.add('Starting Update_Credit_Profile_Level');
		oe_debug_pub.add('OEXUCRCB: OE_Credit_Engine_GRP.G_Credit_Profile_Level ' || OE_Credit_Engine_GRP.G_Credit_Profile_Level);
	END IF;

	IF p_hold_source_rec.hold_source_id IS NOT NULL
	THEN
		l_hold_source_id	:=	p_hold_source_rec.hold_source_id;
		IF G_debug_flag         = 'Y' THEN
			oe_debug_pub.add('OEXUCRCB: Hold Source Id is passed: '||p_hold_source_rec.hold_source_id);
		END IF;

	ELSIF p_hold_source_rec.HOLD_ENTITY_CODE is NOT NULL AND
	      p_hold_source_rec.HOLD_ENTITY_ID is NOT NULL
	THEN
		IF G_debug_flag         = 'Y' THEN
			oe_debug_pub.add('OEXUCRCB: Retrieving Hold Source Id');
		END IF;

		BEGIN
			IF  p_hold_source_rec.line_id IS NOT NULL THEN
			      SELECT hold_source_id
			      INTO l_hold_source_id
			       FROM OE_HOLD_SOURCES_ALL HS
			       WHERE HOLD_ENTITY_CODE = p_hold_source_rec.HOLD_ENTITY_CODE
				  AND HOLD_ENTITY_ID   = p_hold_source_rec.HOLD_ENTITY_ID
				  AND HOLD_ID           = p_hold_source_rec.hold_id
				  AND RELEASED_FLAG = 'N'
				  AND  NVL(HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE
				  AND exists (SELECT 'x'
						  FROM OE_ORDER_HOLDS OH
						 WHERE OH.LINE_ID = p_hold_source_rec.line_id
						   AND OH.HOLD_SOURCE_ID =  HS.HOLD_SOURCE_ID);
			ELSE
			      SELECT hold_source_id
			      INTO l_hold_source_id
			       FROM OE_HOLD_SOURCES_ALL
			       WHERE HOLD_ENTITY_CODE = p_hold_source_rec.HOLD_ENTITY_CODE
				  AND HOLD_ENTITY_ID   = p_hold_source_rec.HOLD_ENTITY_ID
				  AND HOLD_ID           = p_hold_source_rec.hold_id
				  AND RELEASED_FLAG = 'N'
				  AND  NVL(HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE;
			END IF;
		EXCEPTION
			WHEN OTHERS THEN
				oe_debug_pub.ADD('OEXUCRCB: Exception raised!');
				-- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		END;
		IF G_debug_flag         = 'Y' THEN
			oe_debug_pub.add('OEXUCRCB: Retrieved Hold Source Id: '|| l_hold_source_id);
		END IF;
	END IF;

	UPDATE OE_ORDER_HOLDS_ALL
	SET Credit_Profile_Level=OE_Credit_Engine_GRP.G_Credit_Profile_Level,
	    Last_Update_Date = SYSDATE,
	    Last_Updated_By  = FND_GLOBAL.user_id
	WHERE hold_source_id    = l_hold_source_id;

	IF G_debug_flag         = 'Y' THEN
		oe_debug_pub.add('OEXUCRCB: Ending Update_Credit_Profile_Level');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF G_debug_flag         = 'Y' THEN
			oe_debug_pub.add('Error in Update_Credit_Profile_Level:'||SUBSTR(SQLERRM,1,250));
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Update_Credit_Profile_Level;
--ER 12363706 end

-----------------------------------------------------------------------------
--  PROCEDURE: GET_transaction_amount           PUBLIC
--  COMMENT    : Returns the transaction amount for a given order. If the
--               p_site_use_id IS null, the entire order is considered
--               x_conversion_status provides any currency conversion
--               error.
-- BUG 2056412 Freights include
-- BUG 4320650 Rounded the transaction amount
------------------------------------------------------------------------------
PROCEDURE GET_transaction_amount
( p_header_id              IN  NUMBER
, p_transaction_curr_code  IN  VARCHAR2
, p_credit_check_rule_rec IN
             OE_CREDIT_CHECK_UTIL.OE_credit_rules_rec_type
, p_system_parameter_rec   IN
             OE_CREDIT_CHECK_UTIL.OE_systems_param_rec_type
, p_customer_id            IN   NUMBER
, p_site_use_id            IN   NUMBER
, p_limit_curr_code        IN   VARCHAR2
, p_all_lines             IN VARCHAR2 := 'N' --ER 12363706
, x_amount                 OUT  NOCOPY NUMBER
, x_conversion_status      OUT  NOCOPY OE_CREDIT_CHECK_UTIL.CURR_TBL_TYPE
, x_return_status          OUT  NOCOPY VARCHAR2
)
IS

l_order_value       NUMBER := 0;
L_LIMIT_ORDER_VALUE NUMBER := 0;
l_commitment        NUMBER := 0;
l_freights          NUMBER := 0;
l_freights_hdr_1    NUMBER := 0;
l_freights_hdr_2    NUMBER := 0;
l_prepayment        NUMBER := 0;

BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_transaction_amount for '
        || p_header_id );
  END IF;

 -- For line level, if it is customer level credit check
 -- all the lines belonging to the sites owned by the
 -- customer  in the order needs to be considered as per the RDD

 -- Bug 2328351 check for line ctg code as well

  x_return_status     := FND_API.G_RET_STS_SUCCESS;

  OE_CREDIT_CHECK_UTIL.g_current_order_value := NULL ;

  IF p_credit_check_rule_rec.credit_check_level_code = 'LINE'
  THEN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('In Line level ');
    END IF;

    IF p_customer_id IS NOT NULL -- line level CC
    THEN
      -----added for Returns
      IF NVL(p_credit_check_rule_rec.include_returns_flag,'N')='N'
      THEN
        ---returns are not included

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.ADD('Line - Customer level select,no returns ');
        END IF;

        SELECT SUM ( DECODE( p_credit_check_rule_rec.include_tax_flag , 'Y',
                         NVL(l.tax_value,0), 0 )
               + ( l.unit_selling_price * l.ordered_quantity )
               )
        INTO   l_order_value
        FROM   oe_order_lines l,
               oe_order_headers_all h,
               ra_terms_b t,
               HZ_CUST_SITE_USES_ALL su,
               HZ_CUST_ACCT_SITES_ALL cas
        WHERE  h.header_id                   = p_header_id
          AND  h.org_id                      = l.org_id                      /* MOAC_SQL_CHANGE */
          AND  h.header_id                   = l.header_id
          AND  l.invoice_to_org_id           = su.site_use_id
          AND  su.CUST_ACCT_SITE_ID          = cas.CUST_ACCT_SITE_ID
          AND  cas.cust_account_id           = p_customer_id
          --ER 12363706 AND  l.open_flag                   = 'Y'
          AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
          AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
          AND  t.term_id                     = l.payment_term_id
          AND  l.line_category_code          = 'ORDER'
          AND  t.credit_check_flag           = 'Y'
          AND  (EXISTS
                 (SELECT NULL
                  FROM   oe_payment_types_all pt
                  WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                                NVL(h.payment_type_code, 'BME'))
                  AND    pt.credit_check_flag = 'Y'
                  AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                OR
                (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

      ELSE
        ---returns are included

        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.ADD('Line - Customer level select,with returns ');
        END IF;

        SELECT
          SUM ( DECODE( p_credit_check_rule_rec.include_tax_flag , 'Y',
            NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0), 0 )
            + ( l.unit_selling_price *
            (DECODE(l.line_category_code,'RETURN',(-1)*l.ordered_quantity,
            l.ordered_quantity) )
              ))
        INTO   l_order_value
        FROM   oe_order_lines l,
               oe_order_headers_all h,
               ra_terms_b t,
               HZ_CUST_SITE_USES_ALL su,
               HZ_CUST_ACCT_SITES_ALL cas
        WHERE  h.header_id                   = p_header_id
          AND  h.org_id                      = l.org_id                       /* MOAC_SQL_CHANGE */
          AND  h.header_id                   = l.header_id
          AND  l.invoice_to_org_id           = su.site_use_id
          AND  su.CUST_ACCT_SITE_ID          = cas.CUST_ACCT_SITE_ID
          AND  cas.cust_account_id           = p_customer_id
          --ER 12363706 AND  l.open_flag                   = 'Y'
          AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
          AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
          AND  t.term_id                     = l.payment_term_id
          AND  t.credit_check_flag           = 'Y'
          AND  (EXISTS
                 (SELECT NULL
                  FROM   oe_payment_types_all pt
                  WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                                NVL(h.payment_type_code, 'BME'))
                  AND    pt.credit_check_flag = 'Y'
                  AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                OR
                (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


      END IF; ----end for checking if returns are included

     IF G_debug_flag = 'Y'
     THEN
       OE_DEBUG_PUB.ADD('Check for Committment profile ');
     END IF;

     IF OE_Commitment_PVT.Do_Commitment_Sequencing THEN
       BEGIN
         IF G_debug_flag = 'Y'
         THEN
           OE_DEBUG_PUB.ADD('Customer level commitment select ');
         END IF;

           SELECT NVL(SUM(P.commitment_applied_amount), 0)
           INTO   l_commitment
	     FROM   OE_PAYMENTS P, OE_ORDER_HEADERS_ALL H, OE_ORDER_LINES L ,
                  HZ_CUST_SITE_USES_ALL su,
                  HZ_CUST_ACCT_SITES_ALL cas,
                  ra_terms_b t
           WHERE  h.header_id                 = p_header_id
           AND  h.org_id                      = l.org_id                       /* MOAC_SQL_CHANGE */
           AND  h.header_id                   = l.header_id
           AND  l.invoice_to_org_id           = su.site_use_id
           AND  su.CUST_ACCT_SITE_ID          = cas.CUST_ACCT_SITE_ID
           AND  cas.cust_account_id           = p_customer_id
            --ER 12363706 AND  l.open_flag                   = 'Y'
           AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
           AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
           AND  t.term_id                     = l.payment_term_id
           AND  t.credit_check_flag           = 'Y'
           AND  p.header_id                   = p_header_id
           AND  p.line_id                     = l.line_id
           AND  l.line_category_code          = 'ORDER'
           AND  p.header_id                   = h.header_id
           AND  (EXISTS
                 (SELECT NULL
                  FROM   oe_payment_types_all pt
                  WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                                NVL(h.payment_type_code, 'BME'))
                  AND    pt.credit_check_flag = 'Y'
                  AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                OR
                (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

             EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
               OE_DEBUG_PUB.ADD(' NO commitment-1 found ');
               l_commitment := 0 ;

             WHEN TOO_MANY_ROWS
             THEN
               OE_DEBUG_PUB.ADD(' Too many rows exception NO commtment-1');
               l_commitment := 0 ;
         END ;
       END IF; --- commitment


       IF  p_credit_check_rule_rec.incl_freight_charges_flag
              = 'Y'
       THEN
         -----added for Returns
         IF NVL(p_credit_check_rule_rec.include_returns_flag,'N')='N'
         THEN
           ---returns are not included
           IF G_debug_flag = 'Y'
           THEN
             OE_DEBUG_PUB.ADD(' Process trx freights - Line level customer without returns ');
           END IF;

           BEGIN
             SELECT
              SUM
              ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
              * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                        p.operand, (l.ordered_quantity * p.adjusted_amount))
              )
             INTO l_freights
             FROM oe_order_lines l,
                  oe_order_headers_all h,
                  ra_terms_b t,
                  HZ_CUST_SITE_USES_ALL su,
                  HZ_CUST_ACCT_SITES_ALL cas,
                  oe_price_adjustments p
             WHERE  h.header_id                  = p_header_id
               AND  h.org_id                     = l.org_id                       /* MOAC_SQL_CHANGE */
               AND  h.header_id                  = l.header_id
               AND  p.line_id                    =  l.line_id
               AND  p.header_id                  =  l.header_id
               AND  p.header_id                  =  h.header_id
               AND  l.invoice_to_org_id          = su.site_use_id
               AND  p.applied_flag               =  'Y'
               AND  p.list_line_type_code        =  'FREIGHT_CHARGE'
               AND  (p.invoiced_flag IS NULL OR p.invoiced_flag =  'N' )
               AND  su.CUST_ACCT_SITE_ID         = cas.CUST_ACCT_SITE_ID
               AND  cas.cust_account_id          = p_customer_id
              --ER 12363706 AND  l.open_flag                  = 'Y'
               AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
               AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
               AND  t.term_id                    = l.payment_term_id
               AND  l.line_category_code         = 'ORDER'
               AND  t.credit_check_flag          = 'Y'
               AND  (EXISTS
                     (SELECT NULL
                      FROM   oe_payment_types_all pt
                      WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                                NVL(h.payment_type_code, 'BME'))
                      AND    pt.credit_check_flag = 'Y'
                      AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                    OR
                    (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

           EXCEPTION
              WHEN NO_DATA_FOUND
              THEN
                OE_DEBUG_PUB.ADD(' NO Freights found ');
                l_freights := 0 ;

           END ;
         ELSE
           ---returns are included
           IF G_debug_flag = 'Y'
           THEN
             OE_DEBUG_PUB.ADD(' Process trx freights - Line level customer,with returns ');
           END IF;

           BEGIN
             SELECT
              SUM
              ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
              * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                        p.operand, (l.ordered_quantity * p.adjusted_amount))
              )
             INTO l_freights
             FROM oe_order_lines l,
                  oe_order_headers_all h,
                  ra_terms_b t,
                  HZ_CUST_SITE_USES_ALL su,
                  HZ_CUST_ACCT_SITES_ALL cas,
                  oe_price_adjustments p
             WHERE  h.header_id                  = p_header_id
               AND  h.org_id                     = l.org_id                      /* MOAC_SQL_CHANGE */
               AND  h.header_id                  = l.header_id
               AND  p.line_id                    =  l.line_id
               AND  p.header_id                  =  l.header_id
               AND  p.header_id                  =  h.header_id
               AND  l.invoice_to_org_id          = su.site_use_id
               AND  p.applied_flag               =  'Y'
               AND  p.list_line_type_code        =  'FREIGHT_CHARGE'
               AND  (p.invoiced_flag IS NULL OR p.invoiced_flag =  'N' )
               AND  su.CUST_ACCT_SITE_ID         = cas.CUST_ACCT_SITE_ID
               AND  cas.cust_account_id          = p_customer_id
               --ER 12363706 AND  l.open_flag                  = 'Y'
               AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
               AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
               AND  t.term_id                    = l.payment_term_id
               AND  t.credit_check_flag          = 'Y'
               AND  (EXISTS
                     (SELECT NULL
                      FROM   oe_payment_types_all pt
                      WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                                NVL(h.payment_type_code, 'BME'))
                      AND    pt.credit_check_flag = 'Y'
                      AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                    OR
                    (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));
           EXCEPTION
              WHEN NO_DATA_FOUND
              THEN
                OE_DEBUG_PUB.ADD(' NO Freights found ');
                l_freights := 0 ;

           END ;

         END IF; ----end of checking if returns are included

       END IF; -- Freights



     ELSE
       -----added for Returns
       IF NVL(p_credit_check_rule_rec.include_returns_flag,'N')='N'
       THEN
         ---returns are not included

         IF G_debug_flag = 'Y'
         THEN
           OE_DEBUG_PUB.ADD('Line - Site level select ');
         END IF;

         SELECT SUM ( DECODE( p_credit_check_rule_rec.include_tax_flag , 'Y',
                    NVL(l.tax_value,0), 0 )
             + ( l.unit_selling_price * l.ordered_quantity )
               )
         INTO   l_order_value
         FROM   oe_order_lines l,
                oe_order_headers_all h,
                ra_terms_b t
         WHERE  h.header_id                   = p_header_id
           AND  h.org_id                      = l.org_id            /* MOAC_SQL_CHANGE */
           AND  h.header_id                   = l.header_id
           AND  l.invoice_to_org_id           = p_site_use_id
           --ER 12363706 AND  l.open_flag                   = 'Y'
           AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
           AND  l.line_category_code          = 'ORDER'
           AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
           AND  t.term_id                     = l.payment_term_id
           AND  t.credit_check_flag           = 'Y'
           AND  (EXISTS
                   (SELECT NULL
                    FROM   oe_payment_types_all pt
                    WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                              NVL(h.payment_type_code, 'BME'))
                    AND    pt.credit_check_flag = 'Y'
                    AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                 OR
                (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

       ELSE
         ---returns are included

         IF G_debug_flag = 'Y'
         THEN
           OE_DEBUG_PUB.ADD('Line - Site level select,including returns ');
         END IF;

         SELECT
           SUM ( DECODE( p_credit_check_rule_rec.include_tax_flag , 'Y',
           NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0), 0 )
           + (l.unit_selling_price * DECODE(l.line_category_code,'RETURN',
           (-1)*l.ordered_quantity,l.ordered_quantity))
              )
         INTO   l_order_value
         FROM   oe_order_lines l,
                oe_order_headers_all h,
                ra_terms_b t
         WHERE  h.header_id                   = p_header_id
           AND  h.org_id                      = l.org_id            /* MOAC_SQL_CHANGE */
           AND  h.header_id                   = l.header_id
           AND  l.invoice_to_org_id           = p_site_use_id
          --ER 12363706 AND  l.open_flag                   = 'Y'
           AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
           AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
           AND  t.term_id                     = l.payment_term_id
           AND  t.credit_check_flag           = 'Y'
           AND  (EXISTS
                   (SELECT NULL
                    FROM   oe_payment_types_all pt
                    WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                              NVL(h.payment_type_code, 'BME'))
                    AND    pt.credit_check_flag = 'Y'
                    AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                 OR
                (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

       END IF; ---end of checking for returns

       IF G_debug_flag = 'Y'
       THEN
         OE_DEBUG_PUB.ADD('Check for Committment ');
       END IF;

     IF OE_Commitment_PVT.Do_Commitment_Sequencing THEN
       BEGIN
           SELECT NVL(SUM(P.commitment_applied_amount), 0)
           INTO   l_commitment
	     FROM   OE_PAYMENTS P,
                  OE_ORDER_HEADERS_ALL H,
                  OE_ORDER_LINES L,
                  ra_terms_b t
           WHERE  h.header_id                   = p_header_id
             AND  h.org_id                      = l.org_id            /* MOAC_SQL_CHANGE */
             AND  h.header_id                   = l.header_id
             AND  l.invoice_to_org_id           = p_site_use_id
            --ER 12363706 AND  l.open_flag                   = 'Y'
             AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
             AND  l.line_category_code   = 'ORDER'
             AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
             AND  t.term_id                     = l.payment_term_id
             AND  t.credit_check_flag           = 'Y'
             AND  p.header_id                   = p_header_id
             AND  l.line_id                     = p.line_id
             AND  p.header_id                   = h.header_id
             AND  (EXISTS
                   (SELECT NULL
                    FROM   oe_payment_types_all pt
                    WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                              NVL(h.payment_type_code, 'BME'))
                    AND    pt.credit_check_flag = 'Y'
                    AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                   OR
                   (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

           EXCEPTION
           WHEN NO_DATA_FOUND
           THEN
             OE_DEBUG_PUB.ADD(' NO commitment-1 found ');
             l_commitment := 0 ;

           WHEN TOO_MANY_ROWS
           THEN
          OE_DEBUG_PUB.ADD(' Too many rows excepn NO commitment-1 found ');
             l_commitment := 0 ;
         END ;
       END IF; --- commitment

       IF  p_credit_check_rule_rec.incl_freight_charges_flag
              = 'Y'
       THEN

         -----added for Returns
         IF NVL(p_credit_check_rule_rec.include_returns_flag,'N')='N'
         THEN
           ---returns are not included

           IF G_debug_flag = 'Y'
           THEN
             OE_DEBUG_PUB.ADD(' Process trx freights - Line level site,no returns ');
           END IF;

           BEGIN
             SELECT
              SUM
              ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
              * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                        p.operand, (l.ordered_quantity * p.adjusted_amount))
              )
             INTO l_freights
             FROM oe_order_lines l,
                  oe_order_headers_all h,
                  ra_terms_b t,
                  oe_price_adjustments p
             WHERE  h.header_id                  = p_header_id
               AND  h.org_id                     = l.org_id           /* MOAC_SQL_CHANGE */
               AND  h.header_id                  = l.header_id
               AND  p.line_id                    =  l.line_id
               AND  p.header_id                  =  l.header_id
               AND  p.header_id                  =  h.header_id
               AND  l.invoice_to_org_id          = p_site_use_id
               AND  p.applied_flag               =  'Y'
               AND  p.list_line_type_code        =  'FREIGHT_CHARGE'
               AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
              --ER 12363706 AND  l.open_flag                  = 'Y'
               AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
               AND  l.line_category_code         = 'ORDER'
               AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
               AND  t.term_id                    = l.payment_term_id
               AND  t.credit_check_flag          = 'Y'
               AND  (EXISTS
                      (SELECT NULL
                       FROM   oe_payment_types_all pt
                       WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                              NVL(h.payment_type_code, 'BME'))
                       AND    pt.credit_check_flag = 'Y'
                       AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                     OR
                     (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));
           EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
               OE_DEBUG_PUB.ADD(' NO Freights found ');
               l_freights := 0 ;

           END ;

         ELSE
           ---returns are included

           IF G_debug_flag = 'Y'
           THEN
             OE_DEBUG_PUB.ADD(' Process trx freights - Line level site, with returns ');
           END IF;

           BEGIN
             SELECT
              SUM
              ( DECODE( p.credit_or_charge_flag, 'C', (-1), (+1) )
              * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                        p.operand, (l.ordered_quantity * p.adjusted_amount))
              )
             INTO l_freights
             FROM oe_order_lines l,
                  oe_order_headers_all h,
                  ra_terms_b t,
                  oe_price_adjustments p
             WHERE  h.header_id                  = p_header_id
               AND  h.org_id                     = l.org_id           /* MOAC_SQL_CHANGE */
               AND  h.header_id                  = l.header_id
               AND  p.line_id                    =  l.line_id
               AND  p.header_id                  =  l.header_id
               AND  p.header_id                  =  h.header_id
               AND  l.invoice_to_org_id          = p_site_use_id
               AND  p.applied_flag               =  'Y'
               AND  p.list_line_type_code        =  'FREIGHT_CHARGE'
               AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
              --ER 12363706 AND  l.open_flag                  = 'Y'
               AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
               AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
               AND  t.term_id                    = l.payment_term_id
               AND  t.credit_check_flag          = 'Y'
               AND  (EXISTS
                      (SELECT NULL
                       FROM   oe_payment_types_all pt
                       WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                              NVL(h.payment_type_code, 'BME'))
                       AND    pt.credit_check_flag = 'Y'
                       AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                     OR
                     (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

           EXCEPTION
             WHEN NO_DATA_FOUND
             THEN
               OE_DEBUG_PUB.ADD(' NO Freights found ');
               l_freights := 0 ;

           END ;

         END IF; ---end for checking if returns are included

       END IF; -- Freights

    END IF; -- site or cust line level

  ELSE --- Header level CC
    -----added for Returns
    -----exclude prepayments if any
    IF NVL(p_credit_check_rule_rec.include_returns_flag,'N')='N'
    THEN
      ---returns are not included

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('In Order header level select ');
      END IF;

      SELECT SUM ( DECODE( p_credit_check_rule_rec.include_tax_flag , 'Y',
                        NVL(l.tax_value,0), 0 )
               + ( l.unit_selling_price * l.ordered_quantity )
             )
      INTO   l_order_value
      FROM   oe_order_lines l,
             oe_order_headers_all h,
             ra_terms_b t
      WHERE  h.header_id                   = p_header_id
        AND  h.org_id                      = l.org_id           /* MOAC_SQL_CHANGE */
        AND  h.header_id                   = l.header_id
        --ER 12363706 AND  l.open_flag                   = 'Y'
        AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
        AND  l.line_category_code   = 'ORDER'
        AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
        AND  t.term_id                     = l.payment_term_id
        AND  t.credit_check_flag           = 'Y'
        AND  (EXISTS
               (SELECT NULL
                FROM   oe_payment_types_all pt
                WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                              NVL(h.payment_type_code, 'BME'))
                AND    pt.credit_check_flag = 'Y'
                AND    NVL(pt.org_id, -99)  = G_ORG_ID)
              OR
              (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

    ELSE
      ---returns are included

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('In Order header level select, with returns ');
      END IF;

      SELECT
        SUM ( DECODE( p_credit_check_rule_rec.include_tax_flag , 'Y',
         NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0), 0 )
        + (l.unit_selling_price * DECODE(l.line_category_code,'RETURN',
         (-1)*l.ordered_quantity,l.ordered_quantity))
        )
      INTO   l_order_value
      FROM   oe_order_lines l,
             oe_order_headers_all h,
             ra_terms_b t
      WHERE  h.header_id                   = p_header_id
        AND  h.org_id                      = l.org_id           /* MOAC_SQL_CHANGE */
        AND  h.header_id                   = l.header_id
        --ER 12363706 AND  l.open_flag                   = 'Y'
        AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
        AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
        AND  t.term_id                     = l.payment_term_id
        AND  t.credit_check_flag           = 'Y'
        AND  (EXISTS
               (SELECT NULL
                FROM   oe_payment_types_all pt
                WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                              NVL(h.payment_type_code, 'BME'))
                AND    pt.credit_check_flag = 'Y'
                AND    NVL(pt.org_id, -99)  = G_ORG_ID)
              OR
              (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


    END IF; ---end for checking if returns are included

     IF G_debug_flag = 'Y'
     THEN
       OE_DEBUG_PUB.ADD('Check for Committment ');
     END IF ;

     IF OE_Commitment_PVT.Do_Commitment_Sequencing
     THEN
       BEGIN
         IF G_debug_flag = 'Y'
         THEN
           OE_DEBUG_PUB.ADD('In Order header commitment');
         END IF;

         SELECT NVL(SUM(P.commitment_applied_amount), 0)
         INTO   l_commitment
         FROM   oe_order_lines l,
                oe_order_headers_all h,
                ra_terms_b t,
                oe_payments p
         WHERE  h.header_id                   = p_header_id
           AND  h.org_id                      = l.org_id           /* MOAC_SQL_CHANGE */
           AND  h.header_id                   = l.header_id
           AND  p.header_id                   = p_header_id
           AND  p.header_id                   = h.header_id
           AND  p.line_id                     = l.line_id
          --ER 12363706 AND  l.open_flag                   = 'Y'
           AND l.open_flag           = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
           AND  l.line_category_code          = 'ORDER'
           AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
           AND  t.term_id                     = l.payment_term_id
           AND  t.credit_check_flag           = 'Y'
           AND  (EXISTS
                  (SELECT NULL
                   FROM   oe_payment_types_all pt
                   WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                                 NVL(h.payment_type_code,'BME'))
                   AND    pt.credit_check_flag = 'Y'
                   AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                 OR
                 (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

         EXCEPTION
           WHEN NO_DATA_FOUND
           THEN
             OE_DEBUG_PUB.ADD(' NO commitment-1 found ');
             l_commitment := 0 ;

            WHEN TOO_MANY_ROWS
            THEN
              OE_DEBUG_PUB.ADD(' Too many rows excepn NO commitment-1 found ');
              l_commitment := 0 ;
         END ;
     END IF; -- commitment

     --
     -- Get prepayment amount if prepayment is used
     -- the order is assumed to have at least one line with
     -- payment type with credit_check_flag = Y since it passes
     -- check the check to determine if credit check is required
     --
     IF G_MULTIPLE_PAYMENTS_ENABLED THEN
       IF G_debug_flag = 'Y' THEN
         OE_DEBUG_PUB.ADD('In Order header prepayment');
       END IF;

       SELECT SUM(P.prepaid_amount)
       INTO   l_prepayment
       FROM   oe_payments p
       WHERE  p.header_id   = p_header_id
       AND    p.line_id IS NULL;

     END IF; -- prepayment

     IF  p_credit_check_rule_rec.incl_freight_charges_flag = 'Y'
     THEN

       -----added for Returns
       IF NVL(p_credit_check_rule_rec.include_returns_flag,'N')='N'
       THEN
         ---returns are not included

         IF G_debug_flag = 'Y'
         THEN
           OE_DEBUG_PUB.ADD(' Process trx freights - order level ');
         END IF;

         BEGIN

            SELECT
              SUM
              ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
              * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                        p.operand, (l.ordered_quantity * p.adjusted_amount))
              )
            INTO l_freights_hdr_1
            FROM   oe_price_adjustments p
                 , oe_order_lines   l
                 , oe_order_headers_all h
                 , ra_terms_b t
            WHERE  h.header_id           = p_header_id
              AND  h.org_id              = l.org_id           /* MOAC_SQL_CHANGE */
              AND  p.line_id             =  l.line_id
              AND  p.header_id           =  l.header_id
              AND  p.header_id           =  h.header_id
              AND  h.booked_flag         =  'Y'
              AND  h.open_flag           =  'Y'
            --ER 12363706 AND  l.open_flag           =  'Y'
              AND l.open_flag          = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
              AND  l.line_category_code  =  'ORDER'
              AND  p.applied_flag        =  'Y'
              AND  p.list_line_type_code =  'FREIGHT_CHARGE'
              AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
              AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
              AND  t.term_id             = l.payment_term_id
              AND  t.credit_check_flag   = 'Y'
              AND  (EXISTS
                     (SELECT NULL
                      FROM   oe_payment_types_all pt
                      WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                                    NVL(h.payment_type_code,'BME'))
                      AND    pt.credit_check_flag = 'Y'
                      AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                    OR
                    (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

           SELECT
            SUM(DECODE(P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
           INTO l_freights_hdr_2
           FROM
               oe_price_adjustments p
             , oe_order_headers h
           WHERE  h.header_id           = p_header_id
             AND  p.line_id             IS NULL
             AND  p.header_id           =  h.header_id
             AND  h.order_category_code IN ('ORDER','MIXED')
             AND  h.open_flag  =  'Y'
             AND  h.booked_flag         =  'Y'
             AND  p.applied_flag        =  'Y'
             AND  p.list_line_type_code = 'FREIGHT_CHARGE'
             AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N');


           l_freights := NVL(l_freights_hdr_2,0) + NVL(l_freights_hdr_1,0) ;

          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
             l_freights := 0 ;
          END ;
      ELSE
        ---returns are included

         IF G_debug_flag = 'Y'
         THEN
           OE_DEBUG_PUB.ADD(' Process trx freights - order level,with returns ');
         END IF;

         BEGIN
            SELECT
              SUM
              ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
              * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                        p.operand, (l.ordered_quantity * p.adjusted_amount))
              )
            INTO l_freights_hdr_1
            FROM oe_price_adjustments p
               , oe_order_lines   l
               , oe_order_headers_all h
               , ra_terms_b t
            WHERE  h.header_id           = p_header_id
              AND  h.org_id              = l.org_id           /* MOAC_SQL_CHANGE */
              AND  p.line_id             =  l.line_id
              AND  p.header_id           =  l.header_id
              AND  p.header_id           =  h.header_id
              AND  h.booked_flag         =  'Y'
              AND  h.open_flag           =  'Y'
            --ER 12363706 AND  l.open_flag           =  'Y'
              AND l.open_flag = DECODE(p_all_lines,'Y',l.open_flag,'Y') --ER 12363706
              AND  p.applied_flag        =  'Y'
              AND  p.list_line_type_code =  'FREIGHT_CHARGE'
              AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N' )
              AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
              AND  t.term_id             = l.payment_term_id
              AND  t.credit_check_flag   = 'Y'
              AND  (EXISTS
                     (SELECT NULL
                      FROM   oe_payment_types_all pt
                      WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                               NVL(h.payment_type_code, 'BME'))
                      AND    pt.credit_check_flag = 'Y'
                      AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                   OR
                 (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

         -- no need to check for credit_check_flag since the order
         -- already have at least one line with the flag set.
         SELECT
            SUM(DECODE(P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
           INTO l_freights_hdr_2
           FROM
               oe_price_adjustments p
             , oe_order_headers h
           WHERE  h.header_id           = p_header_id
             AND  p.line_id             IS NULL
             AND  p.header_id           =  h.header_id
             AND  h.order_category_code IN ('ORDER','MIXED','RETURN')
             AND  h.open_flag  =  'Y'
             AND  h.booked_flag         =  'Y'
             AND  p.applied_flag        =  'Y'
             AND  p.list_line_type_code = 'FREIGHT_CHARGE'
             AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N');


           l_freights := NVL(l_freights_hdr_2,0) + NVL(l_freights_hdr_1,0) ;

          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
             l_freights := 0 ;
          END ;

      END IF; --end of checkig if returns are included
    END IF; -- freights

  END IF; -- Hdr or line

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' l_order_value = '|| l_order_value );
    OE_DEBUG_PUB.ADD(' l_commitment  = '|| l_commitment  );
    OE_DEBUG_PUB.ADD(' l_freights    = ' || l_freights );
  END IF;


  -- convert amount
 BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' GL_CURRENCY = '||
           OE_Credit_Engine_GRP.GL_currency );
  END IF;
 -- Bug 8249878
 /*    l_order_value :=   NVL(l_order_value,0)
                      - NVL(l_commitment,0)
                      - NVL(l_prepayment,0)
                      + NVL(l_freights,0); */
       l_order_value :=   NVL(l_order_value,0)
                      - NVL(l_commitment,0)
                      + NVL(l_freights,0);
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' Total order amount = '|| l_order_value );
  END IF;

  l_limit_order_value :=
        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
        ( p_amount	           => l_order_value
        , p_transactional_currency => p_transaction_curr_code
        , p_limit_currency	   => p_limit_curr_code
        , p_functional_currency	   => OE_Credit_Engine_GRP.GL_currency
        , p_conversion_date	   => SYSDATE
        , p_conversion_type	   => p_credit_check_rule_rec.conversion_type
        );


 END ;

-- x_amount := NVL(l_limit_order_value,0) ;

  OE_CREDIT_CHECK_UTIL.Rounded_Amount(p_currency_code => p_limit_curr_code
			,p_unrounded_amount =>  NVL(l_limit_order_value,0)
			,x_rounded_amount => x_amount);

  OE_CREDIT_CHECK_UTIL.g_current_order_value := x_amount ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' g_current_order_value = '||
       OE_CREDIT_CHECK_UTIL.g_current_order_value );
    OE_DEBUG_PUB.Add(' Final trx check order amount = '|| x_amount,1 );
    OE_DEBUG_PUB.Add(' ====================================');
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_transaction_amount ');
  END IF;

EXCEPTION
   WHEN  GL_CURRENCY_API.NO_RATE
   THEN
    OE_DEBUG_PUB.ADD('EXCEPTION: GL_CURRENCY_API.NO_RATE ');
    x_conversion_status(1).usage_curr_code := p_transaction_curr_code;
    fnd_message.set_name('ONT', 'OE_CONVERSION_ERROR');
    OE_DEBUG_PUB.ADD('Exception table added ');

  WHEN NO_DATA_FOUND
  THEN
    x_amount := 0 ;
    OE_DEBUG_PUB.ADD('EXCEPTION: NO_DATA_FOUND ');

  WHEN TOO_MANY_ROWS
  THEN
    x_amount := 0 ;
    OE_DEBUG_PUB.ADD('EXCEPTION: TOO_MANY_ROWS ');

  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);
    OE_DEBUG_PUB.ADD('EXCEPTION = '||
SUBSTR(sqlerrm,1,200) );
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'GET_transaction_amount'
      );
    END IF;
    RAISE;
END GET_transaction_amount ;


--========================================================================
-- PROCEDURE : Get_Past_Due_Invoice
-- Comments  : for pre-claculated cc the check will be made
--             from summary table
-- Parameters:
--
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
)
IS
  l_maximum_days_past_due   NUMBER;
  l_dummy                   VARCHAR2(30);
BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: In Get_Past_Due_Invoice');
  END IF;

  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NVL(p_credit_check_rule_rec.quick_cr_check_flag,'N')  = 'N'
  THEN
 -- Bug2408466
 -- REmove the OLD code with DECODES
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('maximum_days_past_due ==> '||
         p_credit_check_rule_rec.maximum_days_past_due,1 );

    OE_DEBUG_PUB.ADD('p_credit_level ==> '|| p_credit_level );
    OE_DEBUG_PUB.ADD('p_include_all_flag ==> '|| p_include_all_flag);
    OE_DEBUG_PUB.ADD('p_global_exposure_flag ==> '||
       p_global_exposure_flag );
  END IF;

  IF NVL(p_global_exposure_flag,'N') = 'N'
  THEN
   BEGIN
     IF G_debug_flag = 'Y'
     THEN
       OE_DEBUG_PUB.Add(' Into NOT Global ');
     END IF;
    --bug 4174163
    --IF NVL(p_credit_check_rule_rec.maximum_days_past_due,0) > 0
    IF p_credit_check_rule_rec.maximum_days_past_due is not null
	and p_credit_check_rule_rec.maximum_days_past_due >= 0
    THEN
      IF p_credit_level = 'CUSTOMER'
      THEN
        BEGIN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Into CUSTOMER ');
          END IF;

            FOR i IN 1..p_usage_curr.count
            LOOP
              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('Currency code = '
                          || p_usage_curr(i).usage_curr_code );
              END IF;
              BEGIN
                SELECT 'Y'
                INTO   x_exist_flag
                FROM   ar_payment_schedules
                WHERE  customer_id = p_customer_id
                  AND  ( invoice_currency_code
                            = p_usage_curr(i).usage_curr_code
                   OR p_include_all_flag = 'Y' )
                  AND  NVL(receipt_confirmed_flag, 'Y') = 'Y'
                  AND    gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY')
                  AND  amount_due_remaining > 0
                  AND  due_date <
                   sysdate - p_credit_check_rule_rec.maximum_days_past_due;

                  -- Invoices found
                  x_exist_flag := 'Y' ;

                 IF G_debug_flag = 'Y'
                 THEN
                   OE_DEBUG_PUB.Add('Invoices found ' );
                 END IF;

                 EXIT;

              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 OE_DEBUG_PUB.Add(' No Invoices Past due found ' );

                 x_exist_flag  := 'N' ;

              WHEN TOO_MANY_ROWS THEN
                 OE_DEBUG_PUB.Add('Invoices found ' );
                x_exist_flag  := 'Y' ;
                EXIT;
            END;
          END LOOP;
        END ;

      ELSE
        BEGIN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Into SITE ');
          END IF;

          FOR i IN 1..p_usage_curr.count
          LOOP
            IF G_debug_flag = 'Y'
            THEN
              OE_DEBUG_PUB.Add(' Currency code = '
                 || p_usage_curr(i).usage_curr_code );
            END IF;
            BEGIN
              SELECT 'Y'
              INTO   x_exist_flag
              FROM   ar_payment_schedules
              WHERE  customer_site_use_id = p_site_use_id
                AND  ( invoice_currency_code  = p_usage_curr(i).usage_curr_code
                     OR p_include_all_flag = 'Y' )
                AND  NVL(receipt_confirmed_flag, 'Y') = 'Y'
                AND  gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY')
                AND  amount_due_remaining > 0
                AND  due_date <
                sysdate - p_credit_check_rule_rec.maximum_days_past_due;

               -- Invoices found
               x_exist_flag := 'Y' ;

               IF G_debug_flag = 'Y'
               THEN
                 OE_DEBUG_PUB.Add('Invoices found ' );
               END IF;

             EXIT;

             EXCEPTION
             WHEN NO_DATA_FOUND THEN
               OE_DEBUG_PUB.Add('No Invoices Past due found in this curr' );
              x_exist_flag  := 'N' ;
             WHEN TOO_MANY_ROWS THEN
              OE_DEBUG_PUB.Add('Invoices found ' );
              x_exist_flag  := 'Y' ;
              EXIT;
            END;
          END LOOP;
        END ;
      END IF;

    ELSE
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add(' No need to check ' );
      END IF;
      x_exist_flag := 'N' ;
    END IF;
  END;

 ELSIF p_global_exposure_flag = 'Y'
 THEN
   BEGIN
     IF G_debug_flag = 'Y'
     THEN
       OE_DEBUG_PUB.Add(' Into GLOBAL checking ');
     END IF;
    --bug 4174163
    --IF NVL(p_credit_check_rule_rec.maximum_days_past_due,0) > 0
    IF p_credit_check_rule_rec.maximum_days_past_due is not null
	and p_credit_check_rule_rec.maximum_days_past_due >= 0
    THEN
      IF p_credit_level = 'CUSTOMER'
      THEN
        BEGIN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Into CUSTOMER ');
          END IF;

            FOR i IN 1..p_usage_curr.count
            LOOP
               IF G_debug_flag = 'Y'
               THEN
                OE_DEBUG_PUB.Add('Currency code = '
                          || p_usage_curr(i).usage_curr_code );
               END IF;

              BEGIN
                SELECT 'Y'
                INTO   x_exist_flag
                FROM   ar_payment_schedules_ALL
                WHERE  customer_id = p_customer_id
                  AND  ( invoice_currency_code
                            = p_usage_curr(i).usage_curr_code
                   OR p_include_all_flag = 'Y' )
                  AND  NVL(receipt_confirmed_flag, 'Y') = 'Y'
                  AND    gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY')
                  AND  amount_due_remaining > 0
                  AND  due_date <
                   sysdate - p_credit_check_rule_rec.maximum_days_past_due;

                  -- Invoices found
                  x_exist_flag := 'Y' ;

                  IF G_debug_flag = 'Y'
                  THEN
                    OE_DEBUG_PUB.Add('Invoices found ' );
                 end if;

                 EXIT;

              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 OE_DEBUG_PUB.Add(' No Invoices Past due found ' );

                 x_exist_flag  := 'N' ;

              WHEN TOO_MANY_ROWS THEN
                 OE_DEBUG_PUB.Add('Invoices found ' );
                x_exist_flag  := 'Y' ;
                EXIT;
            END;
          END LOOP;
        END ;
      END IF;
    ELSE
     OE_DEBUG_PUB.Add(' No need to check ' );
      x_exist_flag := 'N' ;
    END IF;


  END ;
  END IF;
  ---- End Global

ELSE
  --bug 4174163
  --IF NVL(p_credit_check_rule_rec.maximum_days_past_due,0) > 0
  IF p_credit_check_rule_rec.maximum_days_past_due is not null
	and p_credit_check_rule_rec.maximum_days_past_due >= 0
  THEN
    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.add('calling get_invoices_over_duedate ');
    END IF;

     OE_CREDIT_EXPOSURE_PVT.get_invoices_over_duedate
     ( p_customer_id          => p_customer_id
     , p_site_use_id          => p_site_use_id
     , p_party_id             => p_party_id
     , p_credit_check_rule_rec => p_credit_check_rule_rec
     , p_credit_level         => p_credit_level
     , p_usage_curr           => p_usage_curr
     , p_include_all_flag     => NVL(p_include_all_flag,'N')
     , p_global_exposure_flag => NVL(p_global_exposure_flag,'N')
     , p_org_id               => G_org_id   --bug# 5031301
     , x_exist_flag           => x_exist_flag
     );
  ELSE
    x_exist_flag := 'N' ;
  END IF;

END IF; -- precalc

 IF x_exist_flag IS NULL
 THEN
   x_exist_flag := 'N' ;
  END IF ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' x_exist_flag = '|| x_exist_flag );
    OE_DEBUG_PUB.ADD('OEXUCRCB: Out NOCOPY Get_Past_Due_Invoice');
  END IF;

 EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Get_Past_Due_Invoice');
     END IF;
     RAISE;
END Get_Past_Due_Invoice ;




--========================================================================
-- PROCEDURE : Get_order_exposure
-- Comments  : Returns the exposure in the limit currency
--             used for online/Header level credit checking
-- BUG 3449827,3463348: return correct values when p_need_exposure_flag enabled
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
IS

l_est_valid_days NUMBER :=
     to_number(nvl(fnd_profile.value('ONT_EST_AUTH_VALID_DAYS'),'0'));


l_total_from_ar             NUMBER := 0 ;
l_total_from_br             NUMBER := 0 ;
l_total_on_order            NUMBER := 0 ;
l_total_commitment          NUMBER := 0 ;
l_total_exposure            NUMBER := 0 ;

l_total_on_hold             NUMBER := 0 ;

l_total_no_hold             NUMBER := 0 ;

l_limit_total_exposure      NUMBER := 0 ;
l_limit_current_order       NUMBER := 0 ;

l_usage_total_commitment    NUMBER := 0 ;
l_usage_total_exposure      NUMBER := 0 ;

l_uninvoiced_hdr_freight1  NUMBER := 0 ;
l_uninvoiced_hdr_freight2  NUMBER := 0 ;
l_uninvoiced_line_freight1 NUMBER := 0 ;

l_hold_hdr_freight1        NUMBER := 0 ;
l_hold_hdr_freight2        NUMBER := 0 ;

l_no_hold_hdr_freight1     NUMBER := 0 ;
l_no_hold_hdr_freight2     NUMBER := 0 ;
l_external_exposure        NUMBER := 0 ;

l_cum_total_from_ar       NUMBER := 0 ;
l_cum_payments_at_risk    NUMBER := 0 ;
l_cum_total_on_order      NUMBER := 0 ;
l_cum_total_on_hold       NUMBER := 0 ;
l_cum_total_no_hold       NUMBER := 0;
l_cum_total_commitment    NUMBER := 0;
l_cum_external_exposure   NUMBER := 0;
l_cum_uninv_order_total   NUMBER := 0;

l_payments_at_risk        NUMBER := 0 ;
l_payments_at_risk_br     NUMBER := 0 ;

l_exposure_amount         NUMBER := 0 ; --bug 2714553

-----------------------------------------
------ Variables for setting default values
------------------------------------------

l_open_ar_days            NUMBER;
l_uninvoiced_orders_flag  VARCHAR2(1) ;
l_orders_on_hold_flag     VARCHAR2(1) ;
l_include_tax_flag        VARCHAR2(1) ;
l_shipping_horizon        DATE        := TO_DATE('31/12/4712', 'DD/MM/YYYY');
l_include_risk_flag       VARCHAR2(1) ;
l_quick_cr_check_flag     VARCHAR2(1) ;
l_freight_charges_flag    VARCHAR2(1) ;
l_open_ar_balance_flag    VARCHAR2(1) ;
l_current_usage_cur       VARCHAR2(100);
l_incl_external_exposure_flag VARCHAR2(1);
l_drawee_site_use_id      NUMBER;
l_need_exposure_details   VARCHAR2(1) := NVL(p_need_exposure_details, 'N');
l_include_returns_flag    VARCHAR2(1);
l_header_id               NUMBER;
---------------------------------------------------------------
-- Cursor definitions
-- a) In order related cursors, use l_header_id instead of
--    p_header_id. This is done to remove the NVL on p_header_id
--    as p_header_id will be coming in as NULL for the
--    exposure reports.
--
-- b) Removed NVL on ordered_quantity and unit_selling_price as these
--    will always have a value for booked orders.
---------------------------------------------------------------
--- CUSTOMER LEVEL CURSORS

-- External exposure cursor
CURSOR cust_external_exposure_csr (p_curr_code IN VARCHAR2 default NULL) IS
   SELECT SUM(balance)
   FROM   oe_credit_summaries
   WHERE  balance_type     = 18
   AND    cust_account_id  = p_customer_id
   AND    NVL(org_id,-99)  = G_ORG_ID
   AND    currency_code    = p_curr_code;

CURSOR cust_external_csr_global
 (p_curr_code IN VARCHAR2 default NULL) IS
   SELECT SUM(balance)
   FROM   oe_credit_summaries
   WHERE  balance_type     = 18
   AND    cust_account_id  = p_customer_id
   AND    currency_code    = p_curr_code;


-- AR BALANCE
-- Bug2417717 Support customer relationships
-- The exposure must include transactions where
-- created by the bill to sites owned by the customer

   CURSOR cust_ar_balance (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM(NVL(ps.amount_due_remaining,0))
    FROM   ar_payment_schedules ps
        ,  hz_cust_site_uses_all su
       -- ,  hz_cust_acct_sites_all cas                      -- Commented Bug#11827225
    WHERE  ps.CUSTOMER_SITE_USE_ID = su.site_use_id
      AND  ps.org_id               = su.org_id                   /* MOAC_SQL_CHANGE */
      AND  ps.status               = 'OP'
      --AND  su.cust_acct_site_id  =  cas.cust_acct_site_id  -- Commented Bug#11827225
      --AND  cas.cust_account_id   = p_customer_id           -- Commented Bug#11827225
      AND  ps.customer_id =   p_customer_id                  -- Added for Bug#11827225
      AND  su.site_use_code       =
           DECODE(l_open_ar_days,0,site_use_code,'BILL_TO' )
      AND  ps.invoice_currency_code =
           p_curr_code
      AND  NVL(ps.receipt_confirmed_flag, 'Y') = 'Y'
      AND  ps.gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY')
      AND  sysdate - ps.trx_date >
   NVL(p_credit_check_rule_rec.OPEN_AR_DAYS, sysdate - ps.trx_date - 1);

---------------------- BR support -------------------

CURSOR cust_BR_balance (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM(NVL(ps.amount_due_remaining,0))
    FROM   ar_payment_schedules ps
        ,  hz_cust_site_uses_all su
       -- ,  hz_cust_acct_sites_all cas                         -- Commented Bug#11827225
    WHERE  ps.CUSTOMER_SITE_USE_ID = su.site_use_id
      AND  ps.org_id               = su.org_id                    /* MOAC_SQL_CHANGE */
      AND  ps.status               = 'OP'
      --AND  su.cust_acct_site_id    =  cas.cust_acct_site_id   -- Commented Bug#11827225
      --AND  cas.cust_account_id     = p_customer_id            -- Commented Bug#11827225
      AND  ps.customer_id =   p_customer_id                     -- Added for Bug#11827225
      AND  ps.invoice_currency_code =
           p_curr_code
      AND    NVL(ps.receipt_confirmed_flag, 'Y') = 'Y'
      AND  su.site_use_code        = 'DRAWEE'
      AND    ps.gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY') ;

--  PAY AT RISK

CURSOR cust_pay_risk (p_curr_code IN VARCHAR2 default NULL) IS
SELECT SUM(NVL(crh.amount,0))
    FROM   ar_cash_receipt_history crh
         , ar_cash_receipts_all cr
         ,  hz_cust_site_uses_all su
         ,  hz_cust_acct_sites_all cas
    WHERE  crh.cash_receipt_id        = cr.cash_receipt_id
    AND    crh.org_id                 = cr.org_id                    /* MOAC_SQL_CHANGE */
    AND    NVL(cr.confirmed_flag,'Y') = 'Y'
    AND    crh.current_record_flag    = 'Y'
    AND    crh.status <> DECODE ( crh.factor_flag
                                , 'Y', 'RISK_ELIMINATED'
                                , 'CLEARED')
    AND    NVL( cr.reversal_category, cr.status||'X' )  <>  cr.status
    AND    crh.status <> 'REVERSED'
    AND    cr.currency_code           =
              p_curr_code
    AND    cr.pay_from_customer    = cas.cust_account_id
    AND    cr.org_id               = cas.org_id
    AND    cr.CUSTOMER_SITE_USE_ID = su.site_use_id
    AND    su.cust_acct_site_id    = cas.cust_acct_site_id
    AND    cas.cust_account_id     = p_customer_id
    AND   su.site_use_code        =
                DECODE(l_open_ar_days,0,
           site_use_code,'BILL_TO' )
    AND    sysdate - cr.receipt_date >
           NVL(p_credit_check_rule_rec.OPEN_AR_DAYS,
              sysdate - cr.receipt_date - 1)
    AND  NOT EXISTS
           (
           SELECT
             'X'
           FROM
             ar_receivable_applications rap
           WHERE
                  rap.cash_receipt_id  =  cr.cash_receipt_id
             AND  rap.applied_payment_schedule_id  =  -2
             AND  rap.display  =  'Y'
         ) ;


CURSOR cust_br_pay_risk (p_curr_code IN VARCHAR2 default NULL) IS
SELECT SUM(NVL(crh.amount,0))
    FROM   ar_cash_receipt_history crh
         , ar_cash_receipts_all cr
         ,  hz_cust_site_uses_all su
         ,  hz_cust_acct_sites_all cas
    WHERE  crh.cash_receipt_id        = cr.cash_receipt_id
    AND    crh.org_id                 = cr.org_id                    /* MOAC_SQL_CHANGE */
    AND    NVL(cr.confirmed_flag,'Y') = 'Y'
    AND    crh.current_record_flag    = 'Y'
    AND    crh.status <> DECODE ( crh.factor_flag
                                , 'Y', 'RISK_ELIMINATED'
                                , 'CLEARED')
    AND    NVL( cr.reversal_category, cr.status||'X' )  <>  cr.status
    AND    crh.status <> 'REVERSED'
    AND    cr.currency_code           =
              p_curr_code
    AND    cr.pay_from_customer    = cas.cust_account_id
    AND    cr.org_id               = cas.org_id
    AND    cr.CUSTOMER_SITE_USE_ID = su.site_use_id
    AND    su.cust_acct_site_id    = cas.cust_acct_site_id
    AND    cas.cust_account_id     = p_customer_id
     AND  su.site_use_code        = 'DRAWEE'
    AND  NOT EXISTS
           (
           SELECT
             'X'
           FROM
             ar_receivable_applications rap
           WHERE
                  rap.cash_receipt_id  =  cr.cash_receipt_id
             AND  rap.applied_payment_schedule_id  =  -2
             AND  rap.display  =  'Y' );



---CUSTOMER UNINVOICED ORDERS

CURSOR cust_uninvoiced_orders (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM (
                 ( l.ordered_quantity * l.unit_selling_price )
               +   DECODE(l_include_tax_flag, 'Y',
                    NVL(l.tax_value,0), 0   )
               )
    FROM    oe_order_lines_all l
          , oe_order_headers h
          , hz_cust_site_uses_all su
          , hz_cust_acct_sites_all cas
    WHERE  h.invoice_to_org_id     = su.site_use_id
    AND    h.org_id                = su.org_id
    AND    su.cust_acct_site_id    = cas.cust_acct_site_id
    AND    cas.cust_account_id     = p_customer_id
    AND    h.header_id             = l.header_id
    AND    h.org_id                = l.org_id                   /* MOAC_SQL_CHANGE */
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag   = 'Y'
    AND    l.line_category_code = 'ORDER'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

---CUSTOMER UNINVOICED ORDERS, including Returns

CURSOR cust_uninv_orders_ret(p_curr_code IN VARCHAR2 default NULL) IS
    SELECT
      SUM (
      ( DECODE(l.line_category_code,'RETURN',(-1)*l.ordered_quantity,l.ordered_quantity)
      * l.unit_selling_price )
      +   DECODE(l_include_tax_flag, 'Y',
      NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0),0
          ))
    FROM   oe_order_lines l
         , oe_order_headers_all h
         ,  hz_cust_site_uses_all su
         ,  hz_cust_acct_sites_all cas
    WHERE  h.invoice_to_org_id     = su.site_use_id
    AND    h.org_id                = su.org_id
    AND    su.cust_acct_site_id    = cas.cust_acct_site_id
    AND    cas.cust_account_id     = p_customer_id
    AND    h.header_id             = l.header_id
    AND    h.org_id                = l.org_id                     /* MOAC_SQL_CHANGE */
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag   = 'Y'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


-------------------------------------------------
------- commitments -- Exsiting code enhancement
------------------------------------------------

Cursor customer_commitment_total (p_curr_code IN VARCHAR2 default NULL) IS
       SELECT NVL(SUM(P.commitment_applied_amount), 0)
        FROM  OE_PAYMENTS P, OE_ORDER_HEADERS_ALL H, OE_ORDER_LINES L
            , hz_cust_site_uses_all su
            , hz_cust_acct_sites_all cas
	WHERE H.invoice_to_org_id     = su.site_use_id
        AND   h.org_id                = su.org_id
        AND   su.cust_acct_site_id    = cas.cust_acct_site_id
        AND   cas.cust_account_id     = p_customer_id
        AND   H.TRANSACTIONAL_CURR_CODE = p_curr_code
	AND   H.OPEN_FLAG      = 'Y'
	AND   H.BOOKED_FLAG    = 'Y'
	AND   H.HEADER_ID      = P.HEADER_ID
	AND   H.HEADER_ID      <> l_header_id
        AND   L.HEADER_ID                = H.HEADER_ID
        AND   L.ORG_ID                   = H.ORG_ID             /* MOAC_SQL_CHANGE */
        AND   L.LINE_ID                  = P.LINE_ID
        AND   (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
	AND   L.OPEN_FLAG                = 'Y'
	AND   L.LINE_CATEGORY_CODE       = 'ORDER'
	AND   NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
	         	        <= l_shipping_horizon
        AND    (EXISTS
                 (SELECT NULL
                  FROM   oe_payment_types_all pt
                  WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                                NVL(h.payment_type_code, 'BME'))
                  AND    pt.credit_check_flag = 'Y'
                  AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                OR
                (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));
Cursor site_commitment_total (p_curr_code IN VARCHAR2 default NULL)  IS
      SELECT NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P, OE_ORDER_HEADERS_ALL H, OE_ORDER_LINES L
	WHERE  H.INVOICE_TO_ORG_ID = p_site_use_id
        AND    H.TRANSACTIONAL_CURR_CODE = p_curr_code
	AND    H.OPEN_FLAG      = 'Y'
	AND    H.BOOKED_FLAG    = 'Y'
	AND    H.HEADER_ID      = P.HEADER_ID
        AND    H.ORG_ID         = L.ORG_ID               /* MOAC_SQL_CHANGE */
	AND    H.HEADER_ID      <> l_header_id
        AND    L.HEADER_ID                = H.HEADER_ID
        AND    L.LINE_ID                  = P.LINE_ID
        AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
	AND    L.OPEN_FLAG                = 'Y'
	AND    L.LINE_CATEGORY_CODE       = 'ORDER'
	AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
	         	        <= l_shipping_horizon
        AND    (EXISTS
                 (SELECT NULL
                  FROM   oe_payment_types_all pt
                  WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                                NVL(h.payment_type_code, 'BME'))
                  AND    pt.credit_check_flag = 'Y'
                  AND    NVL(pt.org_id, -99)  = G_ORG_ID)
                OR
                (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-------------------- End commitment cursors -----------------

-- Customer orders not on hold

  CURSOR cust_orders_not_on_hold (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM (
                 (l.ordered_quantity * l.unit_selling_price )
               +   DECODE(l_include_tax_flag, 'Y',
                    NVL(l.tax_value,0), 0   )
               )
    FROM   oe_order_lines l
         , oe_order_headers_all h
         , hz_cust_site_uses_all su
         , hz_cust_acct_sites_all cas
    WHERE  h.invoice_to_org_id     = su.site_use_id
    AND    h.org_id                = su.org_id
    AND    su.cust_acct_site_id    = cas.cust_acct_site_id
    AND    cas.cust_account_id     = p_customer_id
    AND    h.header_id = l.header_id
    AND    h.org_id    = l.org_id                           /* MOAC_SQL_CHANGE */
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag = 'Y'
    AND    l.line_category_code = 'ORDER'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh --Performance issue (SQL ID-14880589 FTS on OE_ORDER_HOLDS_ALL)
                    WHERE   h.header_id  = oh.header_id
                     AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- Customer orders not on hold including Returns

  CURSOR cust_ord_not_on_hold_ret (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT
      SUM (
      ( DECODE(l.line_category_code,'RETURN',(-1)*l.ordered_quantity,l.ordered_quantity)
      * l.unit_selling_price )
      +   DECODE(l_include_tax_flag, 'Y',
      NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0),0 )
           )
    FROM   oe_order_lines l
         , oe_order_headers_all h
         , hz_cust_site_uses_all su
         , hz_cust_acct_sites_all cas
    WHERE  h.invoice_to_org_id     = su.site_use_id
    AND    h.org_id                = su.org_id
    AND    su.cust_acct_site_id    = cas.cust_acct_site_id
    AND    cas.cust_account_id     = p_customer_id
    AND    h.header_id = l.header_id
    AND    h.org_id    = l.org_id                           /* MOAC_SQL_CHANGE */
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag = 'Y'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh --Performance issue (SQL ID-14880618 FTS on OE_ORDER_HOLDS_ALL)
		    WHERE   h.header_id  = oh.header_id
                     AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- Customer orders on hold
  CURSOR cust_orders_on_hold (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM (
                 (l.ordered_quantity * l.unit_selling_price )
               +   DECODE(l_include_tax_flag, 'Y',
                    NVL(l.tax_value,0), 0   )
               )
    FROM   oe_order_lines l
         , oe_order_headers_all h
         , hz_cust_site_uses_all su
         , hz_cust_acct_sites_all cas
    WHERE  h.invoice_to_org_id     = su.site_use_id
    AND    h.org_id                = su.org_id
    AND    su.cust_acct_site_id    = cas.cust_acct_site_id
    AND    cas.cust_account_id     = p_customer_id
    AND    h.header_id = l.header_id
    AND    h.org_id    = l.org_id                           /* MOAC_SQL_CHANGE */
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag = 'Y'
    AND    l.line_category_code = 'ORDER'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id  = oh.header_id
                     AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- Customer orders on hold including Returns

  CURSOR cust_ord_on_hold_ret (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT
      SUM (
      ( DECODE(l.line_category_code,'RETURN',(-1)*l.ordered_quantity,l.ordered_quantity)
      * l.unit_selling_price )
      +   DECODE(l_include_tax_flag, 'Y',
      NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0),0 )
           )
    FROM   oe_order_lines l
         , oe_order_headers_all h
         , hz_cust_site_uses_all su
         , hz_cust_acct_sites_all cas
    WHERE  h.invoice_to_org_id     = su.site_use_id
    AND    h.org_id                = su.org_id
    AND    su.cust_acct_site_id    = cas.cust_acct_site_id
    AND    su.org_id               = cas.org_id
    AND    cas.cust_account_id     = p_customer_id
    AND    h.header_id = l.header_id
    AND    h.org_id    = l.org_id
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag = 'Y'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id  = oh.header_id
                     AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-------------------------------------------------
--Fix Freight charges CURSORS for shipping Horizons
-------------------------------------------------
-- customer hdr freights , Does not include curr order
CURSOR cust_uninv_hdr_freight1 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  cas.cust_account_id   = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.header_id           =  l.header_id
  AND  h.org_id              =  l.org_id                     /* MOAC_SQL_CHANGE */
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  l.line_category_code  =  'ORDER'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  (EXISTS
         (SELECT NULL
          FROM   oe_payment_types_all pt
          WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                        NVL(h.payment_type_code, 'BME'))
          AND    pt.credit_check_flag = 'Y'
          AND    NVL(pt.org_id, -99)  = G_ORG_ID)
        OR
        (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- customer hdr freights , Does not include curr order,
-- including Returns

CURSOR cust_uninv_hdr_freight1_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  cas.cust_account_id   = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.header_id           =  l.header_id
  AND  h.org_id              =  l.org_id                     /* MOAC_SQL_CHANGE */
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  ( p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  (EXISTS
         (SELECT NULL
          FROM   oe_payment_types_all pt
          WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                        NVL(h.payment_type_code, 'BME'))
          AND    pt.credit_check_flag = 'Y'
          AND    NVL(pt.org_id, -99)  = G_ORG_ID)
        OR
        (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


-- customer freights 2
-- check if there is at least on line with credit check flag = Y, then
-- include the header freight.
CURSOR cust_uninv_hdr_freight2 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id                       /* MOAC_SQL_CHANGE */
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  cas.cust_account_id   = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines l
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id                       /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );


-- customer freights 2 including Returns
-- check if there is at least on line with credit check flag = Y, then
-- include the header freight.

CURSOR cust_uninv_hdr_freight2_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers_all h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id                     /* MOAC_SQL_CHANGE */
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  cas.cust_account_id   = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED','RETURN')
  AND  open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines l
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id                     /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );


-- customer freights not on hold 1
 CURSOR cust_no_hold_hdr_freight1 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  cas.cust_account_id   = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  l.org_id             = h.org_id                  /* MOAC_SQL_CHANGE */
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  l.line_category_code  =  'ORDER'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh --Performance issue (SQL ID-14880775 FTS on OE_ORDER_HOLDS_ALL)
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND (EXISTS
         (SELECT NULL
          FROM   oe_payment_types_all pt
          WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                        NVL(h.payment_type_code, 'BME'))
          AND    pt.credit_check_flag = 'Y'
          AND    NVL(pt.org_id, -99)  = G_ORG_ID)
       OR
       (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


-- customer freights not on hold 1
 CURSOR cust_no_hold_hdr_freight1_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  cas.cust_account_id   = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  l.org_id             = h.org_id                     /* MOAC_SQL_CHANGE */
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  ( p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh --Performance issue (SQL ID-14880801 FTS on OE_ORDER_HOLDS_ALL)
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND (EXISTS
         (SELECT NULL
          FROM   oe_payment_types_all pt
          WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                        NVL(h.payment_type_code, 'BME'))
          AND    pt.credit_check_flag = 'Y'
          AND    NVL(pt.org_id, -99)  = G_ORG_ID)
       OR
       (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- customer freights on hold 1

 CURSOR cust_hold_hdr_freight1 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  cas.cust_account_id   = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  l.org_id             = h.org_id                    /* MOAC_SQL_CHANGE */
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  l.line_category_code  =  'ORDER'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND (EXISTS
         (SELECT NULL
          FROM   oe_payment_types_all pt
          WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                        NVL(h.payment_type_code, 'BME'))
          AND    pt.credit_check_flag = 'Y'
          AND    NVL(pt.org_id, -99)  = G_ORG_ID)
       OR
       (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


-- customer freights on hold 1 with returns

 CURSOR cust_hold_hdr_freight1_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  su.org_id             = cas.org_id
  AND  cas.cust_account_id   = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  l.org_id             = h.org_id
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  ( p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND (EXISTS
         (SELECT NULL
          FROM   oe_payment_types_all pt
          WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                        NVL(h.payment_type_code, 'BME'))
          AND    pt.credit_check_flag = 'Y'
          AND    NVL(pt.org_id, -99)  = G_ORG_ID)
       OR
       (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- customer not on hold freight 2
 CURSOR cust_no_hold_hdr_freight2 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  cas.cust_account_id   = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh --Performance issue (SQL ID-14880869 FTS on OE_ORDER_HOLDS_ALL)
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines_all l --Performance issue (SQL ID-14880869 FTS on OE_ORDER_HOLDS_ALL)
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id                     /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );

-- customer not on hold freight 2 including Returns

 CURSOR cust_no_hold_hdr_freight2_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  cas.cust_account_id   = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED','RETURN')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  ( p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh --Performance issue (SQL ID-14880892 FTS on OE_ORDER_HOLDS_ALL)
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines_all l --Performance issue (SQL ID-14880892 FTS on OE_ORDER_HOLDS_ALL)
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id                  /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );

-- customer on hold  freight 2
 CURSOR cust_hold_hdr_freight2 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  cas.cust_account_id   = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh --Performance issue (SQL ID-14880915 FTS on OE_ORDER_HOLDS_ALL)
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines_all l --Performance issue (SQL ID-14880915 FTS on OE_ORDER_HOLDS_ALL)
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id                   /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );

-- customer on hold freight 2 including Returns

 CURSOR cust_hold_hdr_freight2_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers h
     , hz_cust_site_uses_all su
     , hz_cust_acct_sites_all cas
WHERE  h.invoice_to_org_id   = su.site_use_id
  AND  h.org_id              = su.org_id
  AND  su.cust_acct_site_id  = cas.cust_acct_site_id
  AND  cas.cust_account_id   = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED','RETURN')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  ( p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines l
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id                      /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );

------------------------
--- SITE LEVEL CURSORS
-------------------------

-- site external exposure cursor
CURSOR site_external_exposure_csr (p_curr_code IN VARCHAR2 default NULL) IS
   SELECT SUM(balance)
   FROM   oe_credit_summaries
   WHERE  balance_type  = 18
   AND    site_use_id   = p_site_use_id
   AND    currency_code = p_curr_code;


CURSOR site_ar_balance (p_curr_code IN VARCHAR2 default NULL) IS
SELECT SUM(NVL(amount_due_remaining,0) )
    FROM   ar_payment_schedules
    WHERE  customer_site_use_id = p_site_use_id
    AND    status               = 'OP'
    AND    invoice_currency_code =
            p_curr_code
    AND    (receipt_confirmed_flag IS NULL OR receipt_confirmed_flag = 'Y')
    AND    gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY')
    AND    sysdate - trx_date >
          NVL(p_credit_check_rule_rec.OPEN_AR_DAYS, sysdate - trx_date - 1);

  -- PAY AT RISK

CURSOR site_pay_risk (p_curr_code IN VARCHAR2 default NULL) IS
SELECT SUM(NVL(crh.amount,0))
    FROM   ar_cash_receipt_history crh
         , ar_cash_receipts_all cr
         , hz_cust_site_uses_all s
         , hz_cust_acct_sites_all a
     WHERE  crh.cash_receipt_id = cr.cash_receipt_id
    AND    crh.org_id           = cr.org_id
    AND    crh.current_record_flag = 'Y'
    AND    crh.status <> DECODE ( crh.factor_flag
                                , 'Y', 'RISK_ELIMINATED'
                                , 'CLEARED' )
    AND    NVL( cr.reversal_category, cr.status||'X' )  <>  cr.status
    AND    crh.status <> 'REVERSED'
    AND    cr.currency_code =
           p_curr_code
    AND    cr.customer_site_use_id = s.site_use_id
    AND    cr.org_id               = s.org_id                    /* MOAC_SQL_CHANGE */
    AND    cr.pay_from_customer    = a.cust_account_id
    AND    s.cust_acct_site_id     = a.cust_acct_site_id
    AND    s.site_use_id           = p_site_use_id
    AND    sysdate - cr.receipt_date
           > NVL(p_credit_check_rule_rec.OPEN_AR_DAYS,
               sysdate - cr.receipt_date - 1)
   AND  NOT EXISTS
         (
           SELECT
             'X'
           FROM
             ar_receivable_applications rap
           WHERE
                  rap.cash_receipt_id  =  cr.cash_receipt_id
             AND  rap.applied_payment_schedule_id  =  -2
             AND  rap.display  =  'Y'
         ) ;


------------------------ SITE BR ------------------------------
CURSOR site_br_balance (p_curr_code IN VARCHAR2 default NULL) IS
SELECT SUM(NVL(amount_due_remaining,0) )
    FROM   ar_payment_schedules
    WHERE  customer_site_use_id = l_drawee_site_use_id
    AND    status               = 'OP'
    AND    invoice_currency_code = p_curr_code
    AND    (receipt_confirmed_flag IS NULL OR receipt_confirmed_flag = 'Y')
    AND    gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY');

CURSOR site_br_pay_risk (p_curr_code IN VARCHAR2 default NULL) IS
SELECT SUM(NVL(crh.amount,0))
    FROM   ar_cash_receipt_history crh
         , ar_cash_receipts_all cr
    WHERE  crh.cash_receipt_id = cr.cash_receipt_id
    AND    crh.org_id          = cr.org_id                      /* MOAC_SQL_CHANGE */
    AND    crh.current_record_flag = 'Y'
    AND    crh.status <> DECODE ( crh.factor_flag
                                , 'Y', 'RISK_ELIMINATED'
                                , 'CLEARED' )
    AND    NVL( cr.reversal_category, cr.status||'X' )  <>  cr.status
    AND    crh.status <> 'REVERSED'
    AND    cr.currency_code        = p_curr_code
    AND    cr.pay_from_customer    = p_customer_id
    AND    cr.customer_site_use_id = l_drawee_site_use_id
    AND  NOT EXISTS
         (
           SELECT
             'X'
           FROM
             ar_receivable_applications rap
           WHERE
                  rap.cash_receipt_id  =  cr.cash_receipt_id
             AND  rap.applied_payment_schedule_id  =  -2
             AND  rap.display  =  'Y'
         ) ;



-- SITE UNINVOICED ORDERS

CURSOR site_uninvoiced_orders (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM (
                 ( l.ordered_quantity * l.unit_selling_price )
               +   DECODE(l_include_tax_flag, 'Y',
                    NVL(l.tax_value,0), 0   )
               )
    FROM   oe_order_lines l
         , oe_order_headers_all h
    WHERE  h.invoice_to_org_id = p_site_use_id
    AND    h.header_id      = l.header_id
    AND    h.org_id         = l.org_id           /* MOAC_SQL_CHANGE */
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag   = 'Y'
    AND    l.line_category_code = 'ORDER'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
            OR
            (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));



-- SITE UNINVOICED ORDERS including RETURNS

  CURSOR site_uninvoiced_orders_ret (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT
      SUM (
      ( DECODE(l.line_category_code,'RETURN',(-1)*l.ordered_quantity,l.ordered_quantity)
      * l.unit_selling_price )
      +   DECODE(l_include_tax_flag, 'Y',
      NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0),0 )
           )
    FROM   oe_order_lines l
         , oe_order_headers_all h
    WHERE  h.invoice_to_org_id = p_site_use_id
    AND    h.header_id      = l.header_id
    AND    h.org_id         = l.org_id                    /* MOAC_SQL_CHANGE */
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag   = 'Y'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
            OR
            (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


  -- site orders not on hold

  CURSOR site_orders_not_on_hold (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM( (l.ordered_quantity * l.unit_selling_price )
               +   DECODE( l_include_tax_flag, 'Y',
                           NVL(l.tax_value,0), 0
                         )
               )
    FROM   oe_order_lines l
         , oe_order_headers_all h
    WHERE  h.invoice_to_org_id = p_site_use_id
    AND    h.header_id         = l.header_id
    AND    h.org_id            = l.org_id                 /* MOAC_SQL_CHANGE */
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag                = 'Y'
    AND    l.line_category_code       = 'ORDER'
    AND    h.booked_flag              = 'Y'
    AND    l.open_flag  = 'Y'
    AND    h.header_id <> l_header_id
    AND    NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id  = oh.header_id
                     AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
            OR
            (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));



-- site orders not on hold including Returns

  CURSOR site_orders_not_on_hold_ret (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT
      SUM (
      ( DECODE(l.line_category_code,'RETURN',(-1)*l.ordered_quantity,l.ordered_quantity)
      * l.unit_selling_price )
      +   DECODE(l_include_tax_flag, 'Y',
      NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0),0 )
           )
    FROM   oe_order_lines l
         , oe_order_headers_all h
    WHERE  h.invoice_to_org_id = p_site_use_id
    AND    h.header_id         = l.header_id
    AND    h.org_id            = l.org_id          /* MOAC_SQL_CHANGE */
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag                = 'Y'
    AND    h.booked_flag              = 'Y'
    AND    l.open_flag  = 'Y'
    AND    h.header_id <> l_header_id
    AND    NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id  = oh.header_id
                    AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
            OR
            (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- site orders on hold
  CURSOR site_orders_on_hold (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM( (l.ordered_quantity * l.unit_selling_price )
               +   DECODE( l_include_tax_flag, 'Y',
                           NVL(l.tax_value,0), 0
                         )
               )
    FROM   oe_order_lines l
         , oe_order_headers_all h
    WHERE  h.invoice_to_org_id = p_site_use_id
    AND    h.header_id         = l.header_id
    AND    h.org_id            = l.org_id           /* MOAC_SQL_CHANGE */
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag                = 'Y'
    AND    l.line_category_code       = 'ORDER'
    AND    h.booked_flag              = 'Y'
    AND    l.open_flag  = 'Y'
    AND    h.header_id <> l_header_id
    AND    EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id  = oh.header_id
                     AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
            OR
            (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- site orders on hold including Returns

  CURSOR site_orders_on_hold_ret (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT
      SUM (
      ( DECODE(l.line_category_code,'RETURN',(-1)*l.ordered_quantity,l.ordered_quantity)      * l.unit_selling_price )
      +   DECODE(l_include_tax_flag, 'Y',
      NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0),0 )
           )
    FROM   oe_order_lines l
         , oe_order_headers_all h
    WHERE  h.invoice_to_org_id = p_site_use_id
    AND    h.header_id         = l.header_id
    AND    h.org_id            = l.org_id               /* MOAC_SQL_CHANGE */
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag                = 'Y'
    AND    h.booked_flag              = 'Y'
    AND    l.open_flag  = 'Y'
    AND    h.header_id <> l_header_id
    AND    EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh --Performance issue (SQL ID-14881132 FTS on OE_ORDER_HOLDS_ALL)
                    WHERE   h.header_id  = oh.header_id
                    AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
            OR
            (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- site hdr freights , Does not include curr order
CURSOR site_uninv_hdr_freight1 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  p.line_id             =  l.line_id
  AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  l.org_id             = h.org_id           /* MOAC_SQL_CHANGE */
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  l.line_category_code  =  'ORDER'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  (EXISTS
         (SELECT NULL
          FROM   oe_payment_types_all pt
          WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                        NVL(h.payment_type_code, 'BME'))
          AND    pt.credit_check_flag = 'Y'
          AND    NVL(pt.org_id, -99)  = G_ORG_ID)
        OR
        (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


-- sitehdr freights , Does not include curr order
-- Including Returns

CURSOR site_uninv_hdr_freight1_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  p.line_id             =  l.line_id
  AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  l.org_id             = h.org_id           /* MOAC_SQL_CHANGE */
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  (EXISTS
         (SELECT NULL
          FROM   oe_payment_types_all pt
          WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                        NVL(h.payment_type_code, 'BME'))
          AND    pt.credit_check_flag = 'Y'
          AND    NVL(pt.org_id, -99)  = G_ORG_ID)
        OR
        (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- sitefreights 2
CURSOR site_uninv_hdr_freight2 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines l
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id          /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );

-- sitefreights 2 including Returns

CURSOR site_uninv_hdr_freight2_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED','RETURN')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines l
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id          /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
       );

-- site freights not on hold 1
 CURSOR site_no_hold_hdr_freight1 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  l.org_id             = h.org_id                 /* MOAC_SQL_CHANGE */
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  l.line_category_code  =  'ORDER'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh --Modified the query to access oe_order_holds_all
                    WHERE   h.header_id = oh.header_id --instead of oe_order_holds to avoid FTS (SQL ID#14881276)
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
       OR
       (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


-- sitefreights not on hold 1 including Returns

 CURSOR site_no_hold_hdr_freight1_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  l.org_id             = h.org_id                 /* MOAC_SQL_CHANGE */
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh   --Modified the query to select from
                    WHERE   h.header_id = oh.header_id --oe_order_holds_all to avoid FTS (SQL#14881293)
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
       OR
       (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- site freights on hold 1
 CURSOR site_hold_hdr_freight1 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  l.org_id             = h.org_id                 /* MOAC_SQL_CHANGE */
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  l.line_category_code  =  'ORDER'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = G_ORG_ID)
       OR
       (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- sitefreights on hold 1 including Returns

 CURSOR site_hold_hdr_freight1_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines   l
     , oe_order_headers_all h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  l.org_id             = h.org_id                 /* MOAC_SQL_CHANGE */
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines l
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id                /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );


-- site not on hold freight 2
 CURSOR site_no_hold_hdr_freight2 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines l
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id              /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );


-- site not on hold freight 2 including Returns

 CURSOR site_no_hold_hdr_freight2_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED','RETURN')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines l
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id                  /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );

-- site on hold freight 2

 CURSOR site_hold_hdr_freight2 (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines l
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id             /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );

-- site on hold freight 2 including Returns

 CURSOR site_hold_hdr_freight2_ret (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers h
WHERE  h.invoice_to_org_id   = p_site_use_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED','RETURN')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_all oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
        (SELECT NULL
         FROM   oe_payment_types_all pt,
                oe_order_lines l
         WHERE  pt.credit_check_flag = 'Y'
         AND    l.header_id = h.header_id
         AND    l.org_id    = pt.org_id            /* MOAC_SQL_CHANGE */
         AND    NVL(pt.org_id, -99) = G_ORG_ID
         AND    pt.payment_type_code =
                  DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, pt.payment_type_code,
                            h.payment_type_code),
                         l.payment_type_code)
        );


-------------------------------------------------------------
------------ GLOBAL EXPOSURE CURSORS
-- Discussed with the performance team and
-- was advised to have separate cursors to avoid any
-- performance related Issues , especially if ORG was indexed
-- down the line.

-- Byg 2417717 - AR relationships
-------------------------------------------------------------
-- AR BALANCE
--Bug 7570339
/*CURSOR cust_ar_balance_global
       (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM(NVL(ps.amount_due_remaining,0))
    FROM   ar_payment_schedules_ALL ps
         , hz_cust_site_uses_ALL su
         , hz_cust_acct_sites_ALL cas
    WHERE  ps.customer_site_use_id = su.site_use_id
    AND    ps.status               = 'OP'
    AND    cas.cust_acct_site_id   = su.cust_acct_site_id
    AND    cas.cust_account_id     = p_customer_id
    AND    su.site_use_code        =
             DECODE(l_open_ar_days,0,site_use_code,'BILL_TO' )
    AND    ps.invoice_currency_code = p_curr_code
    AND    (ps.receipt_confirmed_flag IS NULL OR ps.receipt_confirmed_flag='Y')
    AND    ps.gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY')
    AND    sysdate - ps.trx_date >
    NVL(p_credit_check_rule_rec.OPEN_AR_DAYS, sysdate - ps.trx_date - 1); */

CURSOR cust_ar_balance_global
       (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM(NVL(amount_due_remaining,0)) FROM (
    SELECT NVL(ps.amount_due_remaining,0) amount_due_remaining,ps.PAYMENT_SCHEDULE_ID
    FROM   ar_payment_schedules_ALL ps
         , hz_cust_site_uses_ALL su
         , hz_cust_acct_sites_ALL cas
    WHERE  ps.customer_site_use_id = su.site_use_id
    AND    ps.status               = 'OP'
    AND    cas.cust_acct_site_id   = su.cust_acct_site_id
    AND    cas.cust_account_id     = p_customer_id
    AND    su.site_use_code        =
             DECODE(l_open_ar_days,0,site_use_code,'BILL_TO' )
    AND    ps.invoice_currency_code = p_curr_code
    AND    (ps.receipt_confirmed_flag IS NULL OR ps.receipt_confirmed_flag='Y')
    AND    ps.gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY')
    AND    sysdate - ps.trx_date >
    NVL(p_credit_check_rule_rec.OPEN_AR_DAYS, sysdate - ps.trx_date - 1)
UNION

   SELECT NVL(ps.amount_due_remaining,0) amount_due_remaining,ps.PAYMENT_SCHEDULE_ID
    FROM   ar_payment_schedules_ALL ps
    WHERE  ps.status               = 'OP'
    AND    ps.CUSTOMER_ID     = p_customer_id
    AND    ps.CUSTOMER_SITE_USE_ID IS NULL
    AND    ps.invoice_currency_code = p_curr_code
    AND    (ps.receipt_confirmed_flag IS NULL OR ps.receipt_confirmed_flag='Y')
    AND    ps.gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY')
    AND    sysdate - ps.trx_date >
    NVL(p_credit_check_rule_rec.OPEN_AR_DAYS, sysdate - ps.trx_date - 1));

--  PAY AT RISK
--Bug 7570339

/*CURSOR cust_pay_risk_global
       (p_curr_code IN VARCHAR2 default NULL) IS
SELECT SUM(NVL(crh.amount,0))
    FROM   ar_cash_receipt_history_ALL crh
         , ar_cash_receipts_ALL cr
         , hz_cust_site_uses_ALL su
         , hz_cust_acct_sites_ALL cas
    WHERE  crh.cash_receipt_id        = cr.cash_receipt_id
    AND    (cr.confirmed_flag IS NULL OR cr.confirmed_flag = 'Y')
    AND    crh.current_record_flag    = 'Y'
    AND    crh.status <> DECODE ( crh.factor_flag
                                , 'Y', 'RISK_ELIMINATED'
                                , 'CLEARED')
    AND    NVL( cr.reversal_category, cr.status||'X' )  <>  cr.status
    AND    crh.status <> 'REVERSED'
    AND    cr.currency_code           = p_curr_code
    AND    cr.pay_from_customer       = cas.cust_account_id
    AND    cr.customer_site_use_id    = su.site_use_id
    AND    cas.cust_acct_site_id      = su.cust_acct_site_id
    AND    cas.cust_account_id        = p_customer_id
    AND    su.site_use_code           =
             DECODE(l_open_ar_days,0,site_use_code,'BILL_TO' )
    AND    sysdate - cr.receipt_date >
             NVL(p_credit_check_rule_rec.OPEN_AR_DAYS,
              sysdate - cr.receipt_date - 1)
    AND  NOT EXISTS
           (
           SELECT
             'X'
           FROM
             ar_receivable_applications_ALL rap
           WHERE
                  rap.cash_receipt_id  =  cr.cash_receipt_id
             AND  rap.applied_payment_schedule_id  =  -2
             AND  rap.display  =  'Y'
         ) ;
*/
CURSOR cust_pay_risk_global
       (p_curr_code IN VARCHAR2 default NULL) IS
SELECT SUM(NVL(amount,0)) FROM (
SELECT NVL(crh.amount,0) amount,cr.pay_from_customer,cr.cash_receipt_id
    FROM   ar_cash_receipt_history_ALL crh
         , ar_cash_receipts_ALL cr
         , hz_cust_site_uses_ALL su
         , hz_cust_acct_sites_ALL cas
    WHERE  crh.cash_receipt_id        = cr.cash_receipt_id
    AND    (cr.confirmed_flag IS NULL OR cr.confirmed_flag = 'Y')
    AND    crh.current_record_flag    = 'Y'
    AND    crh.status <> DECODE ( crh.factor_flag
                                , 'Y', 'RISK_ELIMINATED'
                                , 'CLEARED')
    AND    NVL( cr.reversal_category, cr.status||'X' )  <>  cr.status
    AND    crh.status <> 'REVERSED'
    AND    cr.currency_code           = p_curr_code
    AND    cr.pay_from_customer       = cas.cust_account_id
    AND    cr.customer_site_use_id    = su.site_use_id
    AND    cas.cust_acct_site_id      = su.cust_acct_site_id
    AND    cas.cust_account_id        = p_customer_id
    AND    su.site_use_code           =
             DECODE(l_open_ar_days,0,site_use_code,'BILL_TO' )
    AND    sysdate - cr.receipt_date >
             NVL(p_credit_check_rule_rec.OPEN_AR_DAYS,
              sysdate - cr.receipt_date - 1)
    AND  NOT EXISTS
           (
           SELECT
             'X'
           FROM
             ar_receivable_applications_ALL rap
           WHERE
                  rap.cash_receipt_id  =  cr.cash_receipt_id
             AND  rap.applied_payment_schedule_id  =  -2
             AND  rap.display  =  'Y'
         )
  UNION
  SELECT NVL(crh.amount,0) amount,cr.pay_from_customer,cr.cash_receipt_id
    FROM   ar_cash_receipt_history_ALL crh
         , ar_cash_receipts_ALL cr
   WHERE  crh.cash_receipt_id        = cr.cash_receipt_id
    AND    (cr.confirmed_flag IS NULL OR cr.confirmed_flag = 'Y')
    AND    crh.current_record_flag    = 'Y'
    AND    crh.status <> DECODE ( crh.factor_flag
                                , 'Y', 'RISK_ELIMINATED'
                                , 'CLEARED')
    AND    NVL( cr.reversal_category, cr.status||'X' )  <>  cr.status
    AND    crh.status <> 'REVERSED'
    AND    cr.currency_code           = p_curr_code
    AND    cr.pay_from_customer       = p_customer_id
    AND    cr.customer_site_use_id IS NULL
    AND    sysdate - cr.receipt_date >
             NVL(p_credit_check_rule_rec.OPEN_AR_DAYS,
              sysdate - cr.receipt_date - 1)
    AND  NOT EXISTS
           (
           SELECT
             'X'
           FROM
             ar_receivable_applications_ALL rap
           WHERE
                  rap.cash_receipt_id  =  cr.cash_receipt_id
             AND  rap.applied_payment_schedule_id  =  -2
             AND  rap.display  =  'Y'
         )
);


----------------------------- BR -----------------------------
CURSOR cust_br_balance_global
       (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM(NVL(ps.amount_due_remaining,0))
    FROM   ar_payment_schedules_ALL ps
        ,  hz_cust_site_uses_ALL su
       -- ,  hz_cust_acct_sites_ALL cas                      -- Commented Bug#11827225
    WHERE  ps.customer_site_use_id = su.site_use_id
    AND    ps.status               = 'OP'
    --AND    cas.cust_acct_site_id   = su.cust_acct_site_id  -- Commented Bug#11827225
    --AND    cas.cust_account_id     = p_customer_id         -- Commented Bug#11827225
    AND    ps.customer_id =  p_customer_id                   -- Added for Bug#11827225
    AND    su.site_use_code        = 'DRAWEE'
    AND    ps.invoice_currency_code = p_curr_code
    AND    (ps.receipt_confirmed_flag IS NULL OR ps.receipt_confirmed_flag='Y')
    AND    ps.gl_date_closed = to_date( '31-12-4712', 'DD-MM-YYYY') ;

CURSOR cust_br_pay_risk_global
       (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM(NVL(crh.amount,0))
    FROM   ar_cash_receipt_history_ALL crh
         , ar_cash_receipts_ALL cr
        ,  hz_cust_site_uses_ALL su
        ,  hz_cust_acct_sites_ALL cas
    WHERE  crh.cash_receipt_id        = cr.cash_receipt_id
    AND    (cr.confirmed_flag IS NULL OR cr.confirmed_flag = 'Y')
    AND    crh.current_record_flag    = 'Y'
    AND    crh.status <> DECODE ( crh.factor_flag
                                , 'Y', 'RISK_ELIMINATED'
                                , 'CLEARED')
    AND    NVL( cr.reversal_category, cr.status||'X' )  <>  cr.status
    AND    crh.status <> 'REVERSED'
    AND    cr.currency_code           = p_curr_code
    AND    cr.pay_from_customer       = cas.cust_account_id
    AND    cr.customer_site_use_id    = su.site_use_id
    AND    cas.cust_acct_site_id      = su.cust_acct_site_id
    AND    cas.cust_account_id        = p_customer_id
    AND    su.site_use_code        = 'DRAWEE'
    AND    NOT EXISTS
           (
           SELECT
             'X'
           FROM
             ar_receivable_applications_ALL rap
           WHERE
                  rap.cash_receipt_id  =  cr.cash_receipt_id
             AND  rap.applied_payment_schedule_id  =  -2
             AND  rap.display  =  'Y');


---CUSTOMER UNINVOICED ORDERS

CURSOR cust_uninvoiced_orders_global
       (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM (
                 ( l.ordered_quantity * l.unit_selling_price )
               +   DECODE(l_include_tax_flag, 'Y',
                    NVL(l.tax_value,0), 0   )
               )
    FROM   oe_order_lines_ALL l
         , oe_order_headers_ALL h
         , hz_cust_site_uses_ALL su
         , hz_cust_acct_sites_ALL cas
    WHERE  h.invoice_to_org_id = su.site_use_id
    AND    cas.cust_acct_site_id  = su.cust_acct_site_id
    AND    cas.cust_account_id    = p_customer_id
    AND    h.header_id      = l.header_id
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag   = 'Y'
    AND    l.line_category_code = 'ORDER'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


---CUSTOMER UNINVOICED ORDERS including Returns

CURSOR cust_uninv_orders_global_ret
       (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT
      SUM (
      ( DECODE(l.line_category_code,'RETURN',(-1)*l.ordered_quantity,l.ordered_quantity)
      * l.unit_selling_price )
      +   DECODE(l_include_tax_flag, 'Y',
      NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0),0 )
           )
    FROM   oe_order_lines_ALL l
         , oe_order_headers_ALL h
         , hz_cust_site_uses_ALL su
         , hz_cust_acct_sites_ALL cas
    WHERE  h.invoice_to_org_id = su.site_use_id
    AND    cas.cust_acct_site_id  = su.cust_acct_site_id
    AND    cas.cust_account_id    = p_customer_id
    AND    h.header_id      = l.header_id
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag   = 'Y'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));



-------------------------------------------------
------- commitments -- Exiting code enhancement
------------------------------------------------
-------- There is no multi org table for OE_PAYMENTS_ALL

Cursor cust_commitment_total_global
 (p_curr_code IN VARCHAR2 default NULL) IS
      SELECT NVL(SUM(P.commitment_applied_amount), 0)
	FROM   OE_PAYMENTS P
             , OE_ORDER_HEADERS_ALL H
             , OE_ORDER_LINES_ALL L
             , hz_cust_site_uses_ALL su
             , hz_cust_acct_sites_ALL cas
	WHERE  H.invoice_to_org_id   = su.site_use_id
        AND    cas.cust_acct_site_id  = su.cust_acct_site_id
        AND    cas.cust_account_id    = p_customer_id
        AND    H.TRANSACTIONAL_CURR_CODE = p_curr_code
	AND    H.OPEN_FLAG      = 'Y'
	AND    H.BOOKED_FLAG    = 'Y'
	AND    H.HEADER_ID      = P.HEADER_ID
	AND    H.HEADER_ID      <> l_header_id
        AND    L.HEADER_ID                = H.HEADER_ID
        AND    L.LINE_ID                  = P.LINE_ID
        AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
	AND    L.OPEN_FLAG                = 'Y'
	AND    L.LINE_CATEGORY_CODE       = 'ORDER'
	AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
	         	        <= l_shipping_horizon
        AND    (EXISTS
                 (SELECT NULL
                  FROM   oe_payment_types_all pt
                  WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                                NVL(h.payment_type_code, 'BME'))
                  AND    pt.credit_check_flag = 'Y'
                  AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
                OR
                (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));



-- Customer orders not on hold global

  CURSOR cust_orders_not_on_hold_global
         (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM (
                 ( l.ordered_quantity * l.unit_selling_price )
               +   DECODE(l_include_tax_flag, 'Y',
                    NVL(l.tax_value,0), 0   )
               )
    FROM   oe_order_lines_ALL l
         , oe_order_headers_ALL h
         , hz_cust_site_uses_ALL su
         , hz_cust_acct_sites_ALL cas
    WHERE  h.invoice_to_org_id     = su.site_use_id
    AND    cas.cust_acct_site_id  = su.cust_acct_site_id
    AND    cas.cust_account_id    = p_customer_id
    AND    h.header_id = l.header_id
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag = 'Y'
    AND    l.line_category_code = 'ORDER'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id  = oh.header_id
                     AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


-- Customer orders not on hold global including Returns

  CURSOR cust_ord_not_on_hold_glb_ret
         (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT
       SUM (
      ( DECODE(l.line_category_code,'RETURN',(-1)*l.ordered_quantity,l.ordered_quantity)
      * l.unit_selling_price )
      +   DECODE(l_include_tax_flag, 'Y',
      NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0),0 )
           )
    FROM   oe_order_lines_ALL l
         , oe_order_headers_ALL h
         , hz_cust_site_uses_ALL su
         , hz_cust_acct_sites_ALL cas
    WHERE  h.invoice_to_org_id     = su.site_use_id
    AND    cas.cust_acct_site_id  = su.cust_acct_site_id
    AND    cas.cust_account_id    = p_customer_id
    AND    h.header_id = l.header_id
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag = 'Y'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id  = oh.header_id
                     AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND   (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- Customer orders on hold global

  CURSOR cust_orders_on_hold_global
         (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT SUM (
                 ( l.ordered_quantity * l.unit_selling_price )
               +   DECODE(l_include_tax_flag, 'Y',
                    NVL(l.tax_value,0), 0   )
               )
    FROM   oe_order_lines_ALL l
         , oe_order_headers_ALL h
         , hz_cust_site_uses_ALL su
         , hz_cust_acct_sites_ALL cas
    WHERE  h.invoice_to_org_id     = su.site_use_id
    AND    cas.cust_acct_site_id  = su.cust_acct_site_id
    AND    cas.cust_account_id    = p_customer_id
    AND    h.header_id = l.header_id
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag = 'Y'
    AND    l.line_category_code = 'ORDER'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND     EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id  = oh.header_id
                     AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND    (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- Customer orders on hold global including Returns

  CURSOR cust_ord_on_hold_glb_ret
         (p_curr_code IN VARCHAR2 default NULL) IS
    SELECT
       SUM (
      ( DECODE(l.line_category_code,'RETURN',(-1)*l.ordered_quantity,l.ordered_quantity)
      * l.unit_selling_price )
      +   DECODE(l_include_tax_flag, 'Y',
      NVL(DECODE(l.line_category_code,'RETURN',(-1)*l.tax_value,l.tax_value),0),0 )
           )
    FROM   oe_order_lines_ALL l
         , oe_order_headers_ALL h
         , hz_cust_site_uses_ALL su
         , hz_cust_acct_sites_ALL cas
    WHERE  h.invoice_to_org_id     = su.site_use_id
    AND    cas.cust_acct_site_id  = su.cust_acct_site_id
    AND    cas.cust_account_id    = p_customer_id
    AND    h.header_id = l.header_id
    AND    NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
    AND    (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
    AND    h.open_flag = 'Y'
    AND    h.booked_flag = 'Y'
    AND    l.open_flag = 'Y'
    AND    h.header_id <> l_header_id
    AND    EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id  = oh.header_id
                     AND     oh.hold_release_id IS NULL )
    AND    h.transactional_curr_code = p_curr_code
    AND   (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
           OR
           (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- customer hdr freights , Does not include curr order
--- There is not multi org table for oe_price_adjustments

CURSOR cust_uninv_hdr_freight1_global
       (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines_ALL   l
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id    = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  l.line_category_code  =  'ORDER'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  ( p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
        OR
        (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


-- customer hdr freights including Returns, Does not include curr order
--- There is not multi org table for oe_price_adjustments

CURSOR cust_uninv_hdr_fr1_glb_ret
       (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines_ALL   l
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id    = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  ( p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
        OR
        (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));



-- customer freights 2
CURSOR cust_uninv_hdr_freight2_global
       (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id     = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  ( p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         );


-- customer freights 2 including Returns

CURSOR cust_uninv_hdr_fr2_glb_ret
       (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id     = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED','RETURN')
  AND  open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         );

-- customer freights not on hold 1 global
 CURSOR cust_no_hold_hdr_freight1_glb
        (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines_ALL   l
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id     = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  l.line_category_code  =  'ORDER'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
        OR
        (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


-- customer freights not on hold 1 global including Returns

CURSOR cust_no_hold_hdr_fr1_glb_ret
        (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines_ALL   l
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id     = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
          <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
        OR
        (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));

-- customer freights on hold 1 global
 CURSOR cust_hold_hdr_freight1_glb
        (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines_ALL   l
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id     = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
           <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  l.line_category_code  =  'ORDER'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
        OR
        (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


-- customer freights on hold 1 global including Returns

CURSOR cust_hold_hdr_fr1_glb_ret
        (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM
      ( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) )
      * DECODE( p.arithmetic_operator, 'LUMPSUM',          --bug 4295299
                p.operand, (l.ordered_quantity * p.adjusted_amount))
      )
FROM   oe_price_adjustments p
     , oe_order_lines_ALL   l
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id     = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  p.line_id             =  l.line_id
  AND  NVL(L.SCHEDULE_SHIP_DATE,NVL(L.REQUEST_DATE,NVL(H.REQUEST_DATE,H.CREATION_DATE)))
          <= l_shipping_horizon
  AND  (l.invoiced_quantity IS NULL OR l.invoiced_quantity = 0)
  AND  l.header_id          = h.header_id
  AND  p.header_id           =  l.header_id
  AND  p.header_id           =  h.header_id
  AND  h.booked_flag         =  'Y'
  AND  h.open_flag  = 'Y'
  AND  l.open_flag  =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code =  'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.transactional_curr_code = p_curr_code
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  (EXISTS
             (SELECT NULL
              FROM   oe_payment_types_all pt
              WHERE  pt.payment_type_code = NVL(l.payment_type_code,
                                            NVL(h.payment_type_code, 'BME'))
              AND    pt.credit_check_flag = 'Y'
              AND    NVL(pt.org_id, -99)  = NVL(h.org_id, -99))
        OR
        (l.payment_type_code IS NULL AND h.payment_type_code IS NULL));


-- customer not on hold freight 2 global
 CURSOR cust_no_hold_hdr_freight2_glb
        (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id     = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         );


-- customer not on hold freight 2 global including Returns

CURSOR cust_no_hold_hdr_fr2_glb_ret
        (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id     = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED','RETURN')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  NOT EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         );

-- customer on hold freight 2 global
 CURSOR cust_hold_hdr_freight2_glb
        (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id     = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         );

-- customer on hold freight 2 global including Returns

CURSOR cust_hold_hdr_fr2_glb_ret
        (p_curr_code IN VARCHAR2 default null) IS
SELECT
      SUM( DECODE( P.CREDIT_OR_CHARGE_FLAG, 'C', (-1), (+1) ) * P.OPERAND )
FROM
       oe_price_adjustments p
     , oe_order_headers_ALL h
     , hz_cust_site_uses_ALL su
     , hz_cust_acct_sites_ALL cas
WHERE  h.invoice_to_org_id     = su.site_use_id
  AND  cas.cust_acct_site_id  = su.cust_acct_site_id
  AND  cas.cust_account_id    = p_customer_id
  AND  NVL(h.request_date, h.creation_date) <= l_shipping_horizon
  AND  h.transactional_curr_code = p_curr_code
  AND  p.line_id IS NULL
  AND  p.header_id           =  h.header_id
  AND  h.order_category_code IN ('ORDER','MIXED','RETURN')
  AND  h.open_flag  =  'Y'
  AND  h.booked_flag         =  'Y'
  AND  p.applied_flag        =  'Y'
  AND  p.list_line_type_code = 'FREIGHT_CHARGE'
  AND  (p.invoiced_flag IS NULL OR p.invoiced_flag = 'N')
  AND  h.header_id           <> l_header_id
  AND  EXISTS ( SELECT  1
                    FROM    oe_order_holds_ALL oh
                    WHERE   h.header_id = oh.header_id
                    AND     oh.line_id IS NULL
                    AND     oh.hold_release_id IS NULL )
  AND  EXISTS
         ( SELECT  NULL
             FROM  oe_payment_types_all t,
                   oe_order_lines_all l
             WHERE t.credit_check_flag = 'Y'
             AND   NVL(t.org_id,-99) = NVL(h.org_id, -99)
             AND   l.header_id = h.header_id
             AND   t.payment_type_code =
                   DECODE(l.payment_type_code, NULL,
                     DECODE(h.payment_type_code, NULL, t.payment_type_code,
                            h.payment_type_code),
                          l.payment_type_code)
         );

----------------------- END Global exposure cursors ---------

   l_cum_order_amount        NUMBER := 0 ;
   l_cum_order_hold_amount   NUMBER := 0 ;
   l_cum_ar_amount           NUMBER := 0 ;

   l_limit_cum_order_amount        NUMBER := 0 ;
   l_limit_cum_order_hold_amount   NUMBER := 0 ;
   l_limit_cum_ar_amount           NUMBER := 0 ;

   l_order_amount        NUMBER := 0 ;
   l_order_hold_amount   NUMBER := 0 ;
   l_ar_amount           NUMBER := 0 ;


BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: IN Get_order_exposure',1);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add('exposure Input parameters ');
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.Add('--------------------------------------------');
    OE_DEBUG_PUB.Add('p_customer_id          = '|| p_customer_id, 1);
    OE_DEBUG_PUB.Add('p_site_use_id          = '|| p_site_use_id, 1);
    OE_DEBUG_PUB.Add('p_header_id            = '|| p_header_id);
    OE_DEBUG_PUB.Add('p_credit_check_rule_id = '
                 || p_credit_check_rule_rec.credit_check_rule_id
                  );

    OE_DEBUG_PUB.Add('Conversion type = '
                 || p_credit_check_rule_rec.conversion_type
                  );

    OE_DEBUG_PUB.Add('p_credit_level         = '|| p_credit_level, 1);
    OE_DEBUG_PUB.Add('p_limit_curr_code      = '|| p_limit_curr_code);
    OE_DEBUG_PUB.Add('p_include_all_flag     = '|| p_include_all_flag);
    OE_DEBUG_PUB.Add('p_global_exposure_flag = '|| p_global_exposure_flag, 1);
    OE_DEBUG_PUB.Add('p_need_exposure_details= '|| p_need_exposure_details);
    OE_DEBUG_PUB.Add('----------------End Parameters------------------------ ');
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.Add('Local Variables');
    OE_DEBUG_PUB.Add('l_need_exposure_details = '||l_need_exposure_details);
    OE_DEBUG_PUB.Add(' ');

  --------------------------------------------------------------------
  --------- Assign default values: credit check rules ----------------
  --------------------------------------------------------------------

    OE_DEBUG_PUB.Add(' Assign Default Values: Credit rules ');
  END IF;

  l_open_ar_days           := p_credit_check_rule_rec.open_ar_days ;
  l_uninvoiced_orders_flag :=
               NVL(p_credit_check_rule_rec.uninvoiced_orders_flag,'N') ;
  l_orders_on_hold_flag    :=
               NVL(p_credit_check_rule_rec.orders_on_hold_flag,'N') ;
  l_include_tax_flag       :=
               NVL(p_credit_check_rule_rec.include_tax_flag,'N') ;
  l_shipping_horizon       := p_credit_check_rule_rec.shipping_horizon ;
  l_include_risk_flag      :=
          NVL(p_credit_check_rule_rec.include_payments_at_risk_flag,'N') ;
  l_quick_cr_check_flag    :=
               NVL(p_credit_check_rule_rec.quick_cr_check_flag,'N') ;
  l_freight_charges_flag   :=
                NVL(p_credit_check_rule_rec.incl_freight_charges_flag,'N') ;
  l_open_ar_balance_flag   :=
                NVL(p_credit_check_rule_rec.open_ar_balance_flag,'N');
  l_incl_external_exposure_flag   :=
                NVL(p_credit_check_rule_rec.include_external_exposure_flag,'N');
  l_header_id              := NVL(p_header_id,0);
  -----added for Returns-------------------
  l_include_returns_flag   :=
                NVL(p_credit_check_rule_rec.include_returns_flag,'N');

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' Credit rule setup values ');
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.Add(' -----------------------------------------------');
    OE_DEBUG_PUB.Add(' l_open_ar_days           = '|| l_open_ar_days );
    OE_DEBUG_PUB.Add(' l_uninvoiced_orders_flag = '||
                         l_uninvoiced_orders_flag );
    OE_DEBUG_PUB.Add(' l_orders_on_hold_flag    = '|| l_orders_on_hold_flag );
    OE_DEBUG_PUB.Add(' l_include_tax_flag       = '|| l_include_tax_flag );
    OE_DEBUG_PUB.Add(' l_shipping_horizon       = '|| l_shipping_horizon );
    OE_DEBUG_PUB.Add(' l_include_risk_flag      = '|| l_include_risk_flag );
    OE_DEBUG_PUB.Add(' l_quick_cr_check_flag    = '|| l_quick_cr_check_flag );
    OE_DEBUG_PUB.Add(' l_freight_charges_flag   = '|| l_freight_charges_flag );
    OE_DEBUG_PUB.Add(' l_open_ar_balance_flag   = '|| l_open_ar_balance_flag );
    OE_DEBUG_PUB.Add(' l_incl_external_exposure_flag = ' ||
                     l_incl_external_exposure_flag );
    OE_DEBUG_PUB.Add(' l_include_returns_flag = ' ||
                     l_include_returns_flag );
    OE_DEBUG_PUB.Add(' -------------------------------------------------- ');
    OE_DEBUG_PUB.Add(' ');
  END IF;


  IF p_credit_level = 'CUSTOMER'
  THEN
    -- Select total exposure using CUSTOMER CURSORs

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add('Get_order_Exposure CUSTOMER ',1);
    END IF;

    -- The exposure calculation must be done for all the
    --  usage currencies as part of the multi currency
    --  set up.
    l_current_usage_cur := NULL ;

    FOR i IN 1..p_usage_curr.count
    LOOP
       l_current_usage_cur := NULL ;
      IF G_debug_flag = 'Y'
      THEN
       OE_DEBUG_PUB.ADD(' ');
       OE_DEBUG_PUB.ADD('############################### ');
       OE_DEBUG_PUB.ADD('USAGE CURR = '|| p_usage_curr(i).usage_curr_code );
       OE_DEBUG_PUB.ADD('############################### ');
       OE_DEBUG_PUB.ADD(' ');
       OE_DEBUG_PUB.ADD('l_current_usage_cur = '|| l_current_usage_cur );
       OE_DEBUG_PUB.ADD(' ');
       OE_DEBUG_PUB.ADD('.');
      END IF;

       l_current_usage_cur := p_usage_curr(i).usage_curr_code ;

      -- get external exposure
      IF l_incl_external_exposure_flag = 'Y'
      THEN
        --- Bug2352020
        IF p_global_exposure_flag = 'Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Get cust_external_csr_global ');
          END IF;

          OPEN cust_external_csr_global (p_usage_curr(i).usage_curr_code);
          FETCH cust_external_csr_global INTO l_external_exposure;
          IF cust_external_csr_global%NOTFOUND
          THEN
            OE_DEBUG_PUB.Add(' No cust_external_csr_global balance found');
            l_external_exposure := 0;
          END IF;
          CLOSE cust_external_csr_global ;

        ELSE

          OE_DEBUG_PUB.Add(' Get customer external exposure balance ');

          OPEN cust_external_exposure_csr (p_usage_curr(i).usage_curr_code);
          FETCH cust_external_exposure_csr INTO l_external_exposure;
          IF cust_external_exposure_csr%NOTFOUND
          THEN
            OE_DEBUG_PUB.Add(' No external exposure balance found');
            l_external_exposure := 0;
          END IF;
          CLOSE cust_external_exposure_csr;
       END IF ; -- p_global check

      END IF; -- external check
      l_cum_external_exposure := l_cum_external_exposure +
                                 NVL(l_external_exposure, 0);

------------------------AR exposure -------------------------

      IF l_open_ar_balance_flag = 'Y'
      THEN

        IF p_global_exposure_flag = 'Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Get cust_ar_balance_global ');
          END IF;

            OPEN cust_ar_balance_global (p_usage_curr(i).usage_curr_code);
            FETCH cust_ar_balance_global INTO l_total_from_ar ;

            IF cust_ar_balance_global%NOTFOUND
            THEN
              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add(' No AR balance found');
              END IF;

              l_total_from_ar := 0 ;
            END IF;

            CLOSE cust_ar_balance_global;

        ELSE
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Get cust_ar_balance ');
          END IF;

            OPEN cust_ar_balance (p_usage_curr(i).usage_curr_code);
            FETCH cust_ar_balance INTO l_total_from_ar ;

            IF cust_ar_balance%NOTFOUND
            THEN
              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add(' No AR balance found');
              END IF;

              l_total_from_ar := 0 ;
            END IF;

            CLOSE cust_ar_balance;
       	end if;
      END IF;

      IF l_include_risk_flag = 'Y'
      THEN
        IF p_global_exposure_flag = 'Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Get cust_pay_risk_global  ');
          END IF;

            OPEN cust_pay_risk_global (p_usage_curr(i).usage_curr_code);
            FETCH cust_pay_risk_global INTO l_payments_at_risk;
            IF cust_pay_risk_global%NOTFOUND
            THEN
              l_payments_at_risk := 0 ;
               IF G_debug_flag = 'Y'
               THEN
                 OE_DEBUG_PUB.Add(' No Pay at risk found ');
               END IF;
            END IF;

            CLOSE cust_pay_risk_global;
        ELSE
           IF G_debug_flag = 'Y'
           THEN
             OE_DEBUG_PUB.Add(' Get cust_pay_risk  ');
           END IF;

            OPEN cust_pay_risk (p_usage_curr(i).usage_curr_code);
            FETCH cust_pay_risk INTO l_payments_at_risk;
            IF cust_pay_risk%NOTFOUND
            THEN
              l_payments_at_risk := 0 ;
              OE_DEBUG_PUB.Add(' No Pay at risk found ');
            END IF;

            CLOSE cust_pay_risk;
        END IF;  -- Global
      END IF;

-------------------------------------- BR support ---------------
     IF l_open_ar_days > 0
     THEN
      IF oe_credit_check_util.Check_drawee_exists
         (p_cust_account_id => p_customer_id )  = 'Y'
      THEN
        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.Add(' Call DRAWEE BR exposure ');
        END IF;

        IF p_global_exposure_flag = 'Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Get cust_br_balance_global ');
          END IF;

            OPEN cust_br_balance_global (p_usage_curr(i).usage_curr_code);
            FETCH cust_br_balance_global INTO l_total_from_br ;

            IF cust_br_balance_global%NOTFOUND
            THEN
               IF G_debug_flag = 'Y'
               THEN
                 OE_DEBUG_PUB.Add(' No AR balance found');
               END IF;

              l_total_from_br := 0 ;
            END IF;

            CLOSE cust_br_balance_global;

       ELSE
         IF G_debug_flag = 'Y'
         THEN
           OE_DEBUG_PUB.Add(' Get cust_br_balance ');
         END IF;

            OPEN cust_br_balance (p_usage_curr(i).usage_curr_code);
            FETCH cust_br_balance INTO l_total_from_br ;

            IF cust_br_balance%NOTFOUND
            THEN
              OE_DEBUG_PUB.Add(' No AR balance found');
              l_total_from_br := 0 ;
            END IF;

            CLOSE cust_br_balance;
        end if;
      END IF;

      IF l_include_risk_flag = 'Y'
      THEN
        IF p_global_exposure_flag = 'Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Get cust_pay_risk_global  ');
          END IF;

            OPEN cust_br_pay_risk_global (p_usage_curr(i).usage_curr_code);
            FETCH cust_br_pay_risk_global INTO l_payments_at_risk_br;
            IF cust_br_pay_risk_global%NOTFOUND
            THEN
              l_payments_at_risk_br := 0 ;
              OE_DEBUG_PUB.Add(' No Pay at risk found ');
            END IF;

            CLOSE cust_br_pay_risk_global;
        ELSE
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Get cust_pay_risk  ');
          END IF;

            OPEN cust_br_pay_risk (p_usage_curr(i).usage_curr_code);
            FETCH cust_br_pay_risk INTO l_payments_at_risk_br;
            IF cust_br_pay_risk%NOTFOUND
            THEN
              l_payments_at_risk_br := 0 ;
              OE_DEBUG_PUB.Add(' No Pay at risk found ');
            END IF;
            CLOSE cust_br_pay_risk;
        END IF;  -- Global
      ELSE
        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.Add(' No Drawee check required ');
        END IF;

      END IF; -- DRAWEE
    ELSE
     IF G_debug_flag = 'Y'
     THEN
        OE_DEBUG_PUB.Add(' No Drawee check - NO horizon ' ||
          p_credit_check_rule_rec.OPEN_AR_DAYS) ;
     END IF;
    END IF;

------------------- end AR exposure --------------------

------------------- OM Exposure logic ------------------------
-------------------------------------------------------------
    IF l_uninvoiced_orders_flag = 'Y'
    THEN
    BEGIN
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add(' Begin OM Exposure calculation ');
      END IF;

      IF OE_Commitment_PVT.Do_Commitment_Sequencing
      THEN
        IF p_global_exposure_flag = 'Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add('  cust_commitments_global');
          END IF;

          OPEN cust_commitment_total_global
              (p_usage_curr(i).usage_curr_code);
          FETCH cust_commitment_total_global
              INTO l_total_commitment ;

          IF cust_commitment_total_global%NOTFOUND
          THEN
            l_total_commitment := 0 ;
            OE_DEBUG_PUB.Add('No commitment amount found ');
          END IF;

          CLOSE cust_commitment_total_global ;
        ELSE
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add('  cust_commitments ');
          END IF;

          OPEN customer_commitment_total (p_usage_curr(i).usage_curr_code);
          FETCH customer_commitment_total INTO l_total_commitment ;

          IF customer_commitment_total%NOTFOUND
          THEN
            l_total_commitment := 0 ;
            OE_DEBUG_PUB.Add('No commitment amount found ');
          END IF;

          CLOSE customer_commitment_total ;
        END IF ; -- Global
      END IF; -- Commitment_Sequencing

      --
      -- Check the l_orders_on_hold_flag.
      -- IF Y, process the uninvoiced cursors
      -- ELSE process the no hold cursors
      --

      IF l_orders_on_hold_flag = 'Y'
      THEN
        IF p_global_exposure_flag = 'Y'
        THEN

          ----added for Returns
          IF l_include_returns_flag='N'
          THEN
            -----returns are not included

            IF G_debug_flag = 'Y'
            THEN
              OE_DEBUG_PUB.Add(' select  cust_uninvoiced_orders_global  ');
            END IF;

            OPEN cust_uninvoiced_orders_global(p_usage_curr(i).usage_curr_code);
            FETCH cust_uninvoiced_orders_global INTO l_total_on_order;

            IF cust_uninvoiced_orders_global%NOTFOUND
            THEN
              l_total_on_order := 0 ;
              OE_DEBUG_PUB.Add('No Uninvoiced Order amount found ');
            END IF;
            CLOSE cust_uninvoiced_orders_global;

          ELSE
            -----returns are included
            IF G_debug_flag = 'Y'
            THEN
              OE_DEBUG_PUB.Add(' select  cust_uninv_orders_global_ret ');
            END IF;

            OPEN cust_uninv_orders_global_ret(p_usage_curr(i).usage_curr_code);
            FETCH cust_uninv_orders_global_ret  INTO l_total_on_order;

            IF cust_uninv_orders_global_ret%NOTFOUND
            THEN
              l_total_on_order := 0 ;
              OE_DEBUG_PUB.Add('No Uninvoiced Order amount found ');
            END IF;

            CLOSE cust_uninv_orders_global_ret;

          END IF; ---end for checking if returns are included

        ELSE

          ----added for Returns
          IF l_include_returns_flag='N'
          THEN
            -----returns are not included
            IF G_debug_flag = 'Y'
            THEN
              OE_DEBUG_PUB.Add(' select  cust_uninvoiced_orders  ');
            END IF;

            OPEN cust_uninvoiced_orders(p_usage_curr(i).usage_curr_code);
            FETCH cust_uninvoiced_orders INTO l_total_on_order;

            IF cust_uninvoiced_orders%NOTFOUND
            THEN
              l_total_on_order := 0 ;
              OE_DEBUG_PUB.Add('No Uninvoiced Order amount found ');
            END IF;

            CLOSE cust_uninvoiced_orders;

          ELSE
            -----returns are included
            IF G_debug_flag = 'Y'
            THEN
              OE_DEBUG_PUB.Add(' select  cust_uninv_orders_ret  ');
            END IF;

            OPEN cust_uninv_orders_ret(p_usage_curr(i).usage_curr_code);
            FETCH cust_uninv_orders_ret INTO l_total_on_order;

            IF cust_uninv_orders_ret%NOTFOUND
            THEN
              l_total_on_order := 0 ;
              OE_DEBUG_PUB.Add('No Uninvoiced Order amount found ');
            END IF;

            CLOSE cust_uninv_orders_ret;

          END IF; -----end of checking if returns are included
        END IF ; --- Global

        IF l_freight_charges_flag ='Y'
        THEN
          IF p_global_exposure_flag = 'Y'
          THEN

            ----added for Returns
            IF l_include_returns_flag='N'
            THEN
              -----returns are not included
              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('  cust_uninv_hdr_freight1_global  ');
              END IF;

              OPEN cust_uninv_hdr_freight1_global
                 (p_usage_curr(i).usage_curr_code);

              FETCH cust_uninv_hdr_freight1_global
                  INTO l_uninvoiced_hdr_freight1;

              IF cust_uninv_hdr_freight1_global%NOTFOUND
              THEN
                l_uninvoiced_hdr_freight1 := 0 ;
                OE_DEBUG_PUB.Add('No Uninvoiced Order Freight1 found ');
              END IF;

              CLOSE cust_uninv_hdr_freight1_global;

            ELSE
              -----returns are included
              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('  open cust_uninv_hdr_fr1_glb_ret  ');
              END IF;

              OPEN cust_uninv_hdr_fr1_glb_ret
                 (p_usage_curr(i).usage_curr_code);

              FETCH cust_uninv_hdr_fr1_glb_ret
                  INTO l_uninvoiced_hdr_freight1;

              IF cust_uninv_hdr_fr1_glb_ret%NOTFOUND
              THEN
                l_uninvoiced_hdr_freight1 := 0 ;
                OE_DEBUG_PUB.Add('No Uninvoiced Order Freight1 found ');
              END IF;

              CLOSE cust_uninv_hdr_fr1_glb_ret;

            END IF;  --end of checking if returns are included

            ----added for Returns
            IF l_include_returns_flag='N'
            THEN
              -----returns are not included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('  cust_uninv_hdr_freight2_global  ');
              END IF;


              OPEN cust_uninv_hdr_freight2_global
                (p_usage_curr(i).usage_curr_code);

              FETCH cust_uninv_hdr_freight2_global
                INTO l_uninvoiced_hdr_freight2;

              IF cust_uninv_hdr_freight2_global%NOTFOUND
              THEN
                l_uninvoiced_hdr_freight2 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No Uninvoiced Order Freight2 found ');
                END IF;
              END IF;

              CLOSE cust_uninv_hdr_freight2_global ;

            ELSE
              -----returns are included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add(' open cust_uninv_hdr_fr2_glb_ret ');
              END IF;

              OPEN cust_uninv_hdr_fr2_glb_ret
                (p_usage_curr(i).usage_curr_code);

              FETCH cust_uninv_hdr_fr2_glb_ret
                INTO l_uninvoiced_hdr_freight2;

              IF cust_uninv_hdr_fr2_glb_ret%NOTFOUND
              THEN
                l_uninvoiced_hdr_freight2 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No Uninvoiced Order Freight2 found ');
                END IF;
              END IF;

              CLOSE cust_uninv_hdr_fr2_glb_ret;

            END IF;   ----end of checking if returns are included

          ELSE

            ----added for Returns
            IF l_include_returns_flag='N'
            THEN
              -----returns are not included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('  cust_uninv_hdr_freight1  ');
              END IF;

              OPEN cust_uninv_hdr_freight1(p_usage_curr(i).usage_curr_code);
              FETCH cust_uninv_hdr_freight1 INTO l_uninvoiced_hdr_freight1;

              IF cust_uninv_hdr_freight1%NOTFOUND
              THEN
                l_uninvoiced_hdr_freight1 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No Uninvoiced Order Freight1 found ');
                END IF;
              END IF;

              CLOSE cust_uninv_hdr_freight1;

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('  cust_uninv_hdr_freight2  ');
              END IF;

              OPEN cust_uninv_hdr_freight2(p_usage_curr(i).usage_curr_code);
              FETCH cust_uninv_hdr_freight2 INTO l_uninvoiced_hdr_freight2;

              IF cust_uninv_hdr_freight2%NOTFOUND
              THEN
                l_uninvoiced_hdr_freight2 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No Uninvoiced Order Freight2 found ');
                END IF;
              END IF;
              CLOSE cust_uninv_hdr_freight2;

            ELSE
              -----returns are included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add(' open cust_uninv_hdr_freight1_ret ');
              END IF;

              OPEN cust_uninv_hdr_freight1_ret(p_usage_curr(i).usage_curr_code);
              FETCH cust_uninv_hdr_freight1_ret INTO l_uninvoiced_hdr_freight1;

              IF cust_uninv_hdr_freight1_ret%NOTFOUND
              THEN
                l_uninvoiced_hdr_freight1 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No Uninvoiced Order Freight1 found ');
                END IF;
              END IF;

              CLOSE cust_uninv_hdr_freight1_ret;

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add(' open cust_uninv_hdr_freight2_ret ');
              END IF;

              OPEN cust_uninv_hdr_freight2_ret(p_usage_curr(i).usage_curr_code);
              FETCH cust_uninv_hdr_freight2_ret INTO l_uninvoiced_hdr_freight2;

              IF cust_uninv_hdr_freight2_ret%NOTFOUND
              THEN
                l_uninvoiced_hdr_freight2 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No Uninvoiced Order Freight2 found ');
                END IF;
              END IF;
              CLOSE cust_uninv_hdr_freight2_ret;

            END IF; -----end of checking if returns are included

          END IF ; --- Global

        END IF; -- freight charges


      ELSE  -- Do not include orders on hold
            -- l_orders_on_hold_flag <> 'Y'

        IF p_global_exposure_flag = 'Y'
        THEN

          ----added for Returns
          IF l_include_returns_flag='N'
          THEN
            -----returns are not included

            IF G_debug_flag = 'Y'
            THEN
              OE_DEBUG_PUB.Add('  cust_orders_not_on_hold_global  ');
            END IF;

            OPEN cust_orders_not_on_hold_global
                (p_usage_curr(i).usage_curr_code);
            FETCH cust_orders_not_on_hold_global
                INTO l_total_no_hold;

            IF cust_orders_not_on_hold_global%NOTFOUND
            THEN
              l_total_no_hold := 0 ;
              OE_DEBUG_PUB.Add('No Orders not on hold amount found ');
            END IF;

            CLOSE cust_orders_not_on_hold_global ;

            -- If the l_need_exposure_details flag enabled, get the
            -- OM amount on hold
            IF l_need_exposure_details = 'Y' THEN
              IF G_debug_flag = 'Y' THEN
                OE_DEBUG_PUB.Add('  cust_orders_on_hold_global  ');
              END IF;
              OPEN  cust_orders_on_hold_global(p_usage_curr(i).usage_curr_code);
              FETCH cust_orders_on_hold_global
              INTO  l_total_on_hold;

              IF cust_orders_on_hold_global%NOTFOUND THEN
                l_total_on_hold := 0 ;
                OE_DEBUG_PUB.Add('No global orders on hold amount found ');
              END IF;
              CLOSE cust_orders_on_hold_global ;
            END IF;

          ELSE
            -----returns are included

            IF G_debug_flag = 'Y'
            THEN
              OE_DEBUG_PUB.Add(' open cust_ord_not_on_hold_glb_ret  ');
            END IF;

            OPEN cust_ord_not_on_hold_glb_ret
                (p_usage_curr(i).usage_curr_code);
            FETCH cust_ord_not_on_hold_glb_ret
                INTO l_total_no_hold;

            IF cust_ord_not_on_hold_glb_ret%NOTFOUND
            THEN
              l_total_no_hold := 0 ;
              OE_DEBUG_PUB.Add('No Orders not on hold amount found ');
            END IF;

            CLOSE cust_ord_not_on_hold_glb_ret ;

            -- If the l_need_exposure_details flag enabled, get the
            -- OM amount on hold
            IF l_need_exposure_details = 'Y' THEN
              IF G_debug_flag = 'Y' THEN
                OE_DEBUG_PUB.Add('  cust_ord_on_hold_glb_ret  ');
              END IF;
              OPEN  cust_ord_on_hold_glb_ret(p_usage_curr(i).usage_curr_code);
              FETCH cust_ord_on_hold_glb_ret
              INTO  l_total_on_hold;

              IF cust_ord_on_hold_glb_ret%NOTFOUND THEN
                l_total_on_hold := 0 ;
                OE_DEBUG_PUB.Add('No return global orders on hold amount found ');
              END IF;
              CLOSE cust_ord_on_hold_glb_ret ;
            END IF;

          END IF; -----end of checking if returns are included

          IF l_freight_charges_flag ='Y'
          THEN
            --
            -- Get header freight if the site is the same as the given site
            -- or the site belong to the same customer as the given site
            -- if the credit level is CUSTOMER.
            --

            ----added for Returns
            IF l_include_returns_flag='N'
            THEN
              -----returns are not included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('  cust_no_hold_hdr_freight1_glb ');
              END IF;

              OPEN cust_no_hold_hdr_freight1_glb
                  (p_usage_curr(i).usage_curr_code);

              FETCH cust_no_hold_hdr_freight1_glb
                    INTO l_no_hold_hdr_freight1;

              IF cust_no_hold_hdr_freight1_glb%NOTFOUND
              THEN
                l_no_hold_hdr_freight1 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No orders without hold freight1 amount found ');
                END IF;
              END IF;

              CLOSE cust_no_hold_hdr_freight1_glb ;

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('  cust_no_hold_hdr_freight2_glb ');
              END IF;

              OPEN cust_no_hold_hdr_freight2_glb
                (p_usage_curr(i).usage_curr_code);

              FETCH cust_no_hold_hdr_freight2_glb
                INTO l_no_hold_hdr_freight2;

              IF cust_no_hold_hdr_freight2_glb%NOTFOUND
              THEN
                l_hold_hdr_freight2 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No orders without hold freight2 amount found');
                END IF;
              END IF;
              CLOSE cust_no_hold_hdr_freight2_glb ;

              -- If the l_need_exposure_details flag enabled, get the
              -- OM amount on hold
              IF l_need_exposure_details = 'Y' THEN
                IF G_debug_flag = 'Y' THEN
                  OE_DEBUG_PUB.Add('  cust_hold_hdr_freight1_glb  ');
                END IF;

                OPEN  cust_hold_hdr_freight1_glb
                      (p_usage_curr(i).usage_curr_code);
                FETCH cust_hold_hdr_freight1_glb
                INTO  l_hold_hdr_freight1;

                IF cust_hold_hdr_freight1_glb%NOTFOUND THEN
                  l_hold_hdr_freight1 := 0 ;
                  OE_DEBUG_PUB.Add
                    ('No orders on hold with freight1 amount found ');
                END IF;

                CLOSE cust_hold_hdr_freight1_glb;

                -- get header freight2 on hold
                IF G_debug_flag = 'Y' THEN
                  OE_DEBUG_PUB.Add('  cust_hold_hdr_freight2_glb  ');
                END IF;

                OPEN  cust_hold_hdr_freight2_glb
                    (p_usage_curr(i).usage_curr_code);
                FETCH cust_hold_hdr_freight2_glb
                INTO  l_hold_hdr_freight2;

                IF cust_hold_hdr_freight2_glb%NOTFOUND THEN
                  l_hold_hdr_freight2 := 0 ;
                  OE_DEBUG_PUB.Add
                    ('No orders on hold with freight2 amount found ');
                END IF;

                CLOSE cust_hold_hdr_freight2_glb;
              END IF;
            ELSE

              -----returns are included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('open  cust_no_hold_hdr_fr1_glb_ret ');
              END IF;

              OPEN cust_no_hold_hdr_fr1_glb_ret
                  (p_usage_curr(i).usage_curr_code);

              FETCH cust_no_hold_hdr_fr1_glb_ret
                    INTO l_no_hold_hdr_freight1;

              IF cust_no_hold_hdr_fr1_glb_ret%NOTFOUND
              THEN
                l_no_hold_hdr_freight1 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No orders without hold freight1 amount found ');
                END IF;
              END IF;

              CLOSE cust_no_hold_hdr_fr1_glb_ret ;

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('open  cust_no_hold_hdr_fr2_glb_ret ');
              END IF;

              OPEN cust_no_hold_hdr_fr2_glb_ret
                (p_usage_curr(i).usage_curr_code);

              FETCH cust_no_hold_hdr_fr2_glb_ret
                INTO l_no_hold_hdr_freight2;

              IF cust_no_hold_hdr_fr2_glb_ret%NOTFOUND
              THEN
                l_hold_hdr_freight2 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No orders without hold freight2 amount found');
                END IF;
              END IF;
              CLOSE cust_no_hold_hdr_fr2_glb_ret ;

              -- If the l_need_exposure_details flag enabled, get the
              -- OM amount on hold
              IF l_need_exposure_details = 'Y' THEN
                IF G_debug_flag = 'Y' THEN
                  OE_DEBUG_PUB.Add('  cust_hold_hdr_fr1_glb_ret  ');
                END IF;

                OPEN  cust_hold_hdr_fr1_glb_ret
                      (p_usage_curr(i).usage_curr_code);
                FETCH cust_hold_hdr_fr1_glb_ret
                INTO  l_hold_hdr_freight1;

                IF cust_hold_hdr_fr1_glb_ret%NOTFOUND THEN
                  l_hold_hdr_freight1 := 0 ;
                  OE_DEBUG_PUB.Add
                    ('No orders on hold with freight1 amount found ');
                END IF;

                CLOSE cust_hold_hdr_fr1_glb_ret;

                -- get header freight2 on hold
                IF G_debug_flag = 'Y' THEN
                  OE_DEBUG_PUB.Add('  cust_hold_hdr_fr2_glb_ret  ');
                END IF;

                OPEN  cust_hold_hdr_fr2_glb_ret
                    (p_usage_curr(i).usage_curr_code);
                FETCH cust_hold_hdr_fr2_glb_ret
                INTO  l_hold_hdr_freight2;

                IF cust_hold_hdr_fr2_glb_ret%NOTFOUND THEN
                  l_hold_hdr_freight2 := 0 ;
                  OE_DEBUG_PUB.Add
                    ('No orders on hold with freight2 amount found ');
                END IF;

                CLOSE cust_hold_hdr_fr2_glb_ret;
              END IF;

            END IF; ---end of checking if returns are included

          END IF; -- freight = Y

        ELSE  -- uninvoiced orders not on hold - Non global

          ----added for Returns
          IF l_include_returns_flag = 'N'
          THEN
            -----returns are not included

            IF G_debug_flag = 'Y'
            THEN
              OE_DEBUG_PUB.Add('  cust_orders_not_on_hold ');
            END IF;

            OPEN cust_orders_not_on_hold (p_usage_curr(i).usage_curr_code);
            FETCH cust_orders_not_on_hold INTO l_total_no_hold;

            IF cust_orders_not_on_hold%NOTFOUND
            THEN
              l_total_no_hold := 0 ;
              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('No orders not on hold amount found ');
              END IF;
            END IF;

            CLOSE cust_orders_not_on_hold;

            -- If the l_need_exposure_details flag enabled, get the
            -- OM amount on hold
            IF l_need_exposure_details = 'Y' THEN
              IF G_debug_flag = 'Y' THEN
                 OE_DEBUG_PUB.Add('  cust_orders_on_hold ');
              END IF;

              OPEN cust_orders_on_hold (p_usage_curr(i).usage_curr_code);
              FETCH cust_orders_on_hold INTO l_total_on_hold;

              IF cust_orders_on_hold%NOTFOUND THEN
                l_total_on_hold := 0 ;
                IF G_debug_flag = 'Y' THEN
                  OE_DEBUG_PUB.Add('No customer orders on hold amount found ');
                END IF;
              END IF;
              CLOSE cust_orders_on_hold;
            END IF;

          ELSE
            -----returns are not included

            IF G_debug_flag = 'Y'
            THEN
              OE_DEBUG_PUB.Add('  cust_ord_not_on_hold_ret ');
            END IF;

            OPEN cust_ord_not_on_hold_ret (p_usage_curr(i).usage_curr_code);
            FETCH cust_ord_not_on_hold_ret INTO l_total_no_hold;

            IF cust_ord_not_on_hold_ret%NOTFOUND
            THEN
              l_total_no_hold := 0 ;
              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('No orders not on hold amount found ');
              END IF;
            END IF;

            CLOSE cust_ord_not_on_hold_ret;

            -- If the l_need_exposure_details flag enabled, get the
            -- OM amount on hold
            IF l_need_exposure_details = 'Y' THEN
              IF G_debug_flag = 'Y' THEN
                 OE_DEBUG_PUB.Add('  cust_ord_on_hold_ret ');
              END IF;

              OPEN cust_ord_on_hold_ret (p_usage_curr(i).usage_curr_code);
              FETCH cust_ord_on_hold_ret INTO l_total_on_hold;

              IF cust_ord_on_hold_ret%NOTFOUND THEN
                l_total_on_hold := 0 ;
                IF G_debug_flag = 'Y' THEN
                  OE_DEBUG_PUB.Add('No customer orders on hold amount found ');
                END IF;
              END IF;
              CLOSE cust_ord_on_hold_ret;
            END IF;

          END IF; -----end of checking if returns are included

          IF l_freight_charges_flag ='Y'
          THEN
            --
            -- Get header freight if the site is the same as the given site
            -- or the site belong to the same customer as the given site
            -- if the credit level is CUSTOMER.
            --
            ----added for Returns
            IF l_include_returns_flag='N'
            THEN
              -----returns are not included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('  cust_no_hold_hdr_freight1 ');
              END IF;

              OPEN cust_no_hold_hdr_freight1(p_usage_curr(i).usage_curr_code);
              FETCH cust_no_hold_hdr_freight1 INTO l_no_hold_hdr_freight1;

              IF cust_no_hold_hdr_freight1%NOTFOUND
              THEN
                l_no_hold_hdr_freight1 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No orders without hold freight1 amount found ');
                END IF;
              END IF;

              CLOSE cust_no_hold_hdr_freight1;

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('  cust_no_hold_hdr_freight2 ');
              END IF;

              OPEN cust_no_hold_hdr_freight2(p_usage_curr(i).usage_curr_code);
              FETCH cust_no_hold_hdr_freight2 INTO l_no_hold_hdr_freight2;

              IF cust_no_hold_hdr_freight2%NOTFOUND
              THEN
                l_no_hold_hdr_freight2 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No orders without hold freight2 amount found');
                END IF;
              END IF;
              CLOSE cust_no_hold_hdr_freight2;

              -- If the l_need_exposure_details flag enabled, get the
              -- OM amount on hold
              IF l_need_exposure_details = 'Y' THEN
                --
                -- Get cust on hold header freight1
                --
                IF G_debug_flag = 'Y' THEN
                  OE_DEBUG_PUB.Add('  cust_hold_hdr_freight1 ');
                END IF;

                OPEN cust_hold_hdr_freight1(p_usage_curr(i).usage_curr_code);
                FETCH cust_hold_hdr_freight1 INTO l_hold_hdr_freight1;

                IF cust_hold_hdr_freight1%NOTFOUND THEN
                  l_hold_hdr_freight1 := 0 ;
                  IF G_debug_flag = 'Y' THEN
                    OE_DEBUG_PUB.Add('No orders with hold freight1 amount found ');
                  END IF;
                END IF;

                CLOSE cust_hold_hdr_freight1;
                --
                -- Get cust on hold header freight2
                --
                IF G_debug_flag = 'Y' THEN
                  OE_DEBUG_PUB.Add('  cust_hold_hdr_freight2 ');
                END IF;

                OPEN cust_hold_hdr_freight2(p_usage_curr(i).usage_curr_code);
                FETCH cust_hold_hdr_freight2 INTO l_hold_hdr_freight2;

                IF cust_hold_hdr_freight2%NOTFOUND THEN
                  l_hold_hdr_freight2 := 0 ;
                  IF G_debug_flag = 'Y' THEN
                    OE_DEBUG_PUB.Add('No orders with hold freight2 amount found ');
                  END IF;
                END IF;

                CLOSE cust_hold_hdr_freight2;
              END IF; -- need details

            ELSE
              -----returns are included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('  cust_no_hold_hdr_freight1_ret ');
              END IF;

              OPEN cust_no_hold_hdr_freight1_ret(p_usage_curr(i).usage_curr_code);
              FETCH cust_no_hold_hdr_freight1_ret INTO l_no_hold_hdr_freight1;

              IF cust_no_hold_hdr_freight1_ret%NOTFOUND
              THEN
                l_no_hold_hdr_freight1 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No orders without hold freight1 amount found ');
                END IF;
              END IF;

              CLOSE cust_no_hold_hdr_freight1_ret;

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add('open  cust_no_hold_hdr_freight2_ret ');
              END IF;

              OPEN cust_no_hold_hdr_freight2_ret(p_usage_curr(i).usage_curr_code);
              FETCH cust_no_hold_hdr_freight2_ret INTO l_no_hold_hdr_freight2;

              IF cust_no_hold_hdr_freight2_ret%NOTFOUND
              THEN
                l_no_hold_hdr_freight2 := 0 ;
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add('No orders without hold freight2 amount found');
                END IF;
              END IF;

              CLOSE cust_no_hold_hdr_freight2_ret;


              -- If the l_need_exposure_details flag enabled, get the
              -- OM amount on hold
              IF l_need_exposure_details = 'Y' THEN
                --
                -- Get cust on hold header freight1 with returns
                --
                IF G_debug_flag = 'Y' THEN
                  OE_DEBUG_PUB.Add('  cust_hold_hdr_freight1_ret ');
                END IF;

                OPEN cust_hold_hdr_freight1_ret(p_usage_curr(i).usage_curr_code);
                FETCH cust_hold_hdr_freight1_ret INTO l_hold_hdr_freight1;

                IF cust_hold_hdr_freight1_ret%NOTFOUND THEN
                  l_hold_hdr_freight1 := 0 ;
                  IF G_debug_flag = 'Y' THEN
                    OE_DEBUG_PUB.Add('No orders with hold freight1 amount found ');
                  END IF;
                END IF;

                CLOSE cust_hold_hdr_freight1_ret;
                --
                -- Get cust on hold header freight2
                --
                IF G_debug_flag = 'Y' THEN
                  OE_DEBUG_PUB.Add('  cust_hold_hdr_freight2_ret ');
                END IF;

                OPEN cust_hold_hdr_freight2_ret(p_usage_curr(i).usage_curr_code);
                FETCH cust_hold_hdr_freight2_ret INTO l_hold_hdr_freight2;

                IF cust_hold_hdr_freight2_ret%NOTFOUND THEN
                  l_hold_hdr_freight2 := 0 ;
                  IF G_debug_flag = 'Y' THEN
                    OE_DEBUG_PUB.Add('No orders with hold freight2 amount found ');
                  END IF;
                END IF;

                CLOSE cust_hold_hdr_freight2_ret;
              END IF; -- need details
            END IF; ---end of checking if returns are included

          END IF; -- include freight charges
        END IF; -- is global
      END IF;  -- Orders on hold

    END ;
  ELSE
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add(' No OM Exposure calculation ',1);
    END IF;
  END IF; -- Uninvoiced Orders


----------------------- End OM Exposure ------------------

    l_cum_total_from_ar := l_cum_total_from_ar
                         + NVL(l_total_from_ar,0)
                         + NVL(l_total_from_br,0) ;

    l_cum_payments_at_risk := l_cum_payments_at_risk
                         + NVL(l_payments_at_risk,0)
                         + NVL(l_payments_at_risk_br ,0);

    l_cum_total_on_order := l_cum_total_on_order
                         + NVL(l_total_on_order,0)
                         + NVL(l_uninvoiced_hdr_freight1,0)
                         + NVL(l_uninvoiced_hdr_freight2,0);

    l_cum_total_no_hold := l_cum_total_no_hold
                         + NVL(l_total_no_hold,0)
                         + NVL(l_no_hold_hdr_freight1,0)
                         + NVL(l_no_hold_hdr_freight2,0);

    l_cum_total_on_hold := l_cum_total_on_hold
                         + NVL(l_total_on_hold,0)
                         + NVL(l_hold_hdr_freight1,0)
                         + NVL(l_hold_hdr_freight2,0);

    l_cum_total_commitment := l_cum_total_commitment
                            + NVL(l_total_commitment,0) ;

    IF l_orders_on_hold_flag = 'Y' THEN
      l_cum_uninv_order_total := l_cum_total_on_order;
    ELSE
      l_cum_uninv_order_total := l_cum_total_no_hold;
    END IF;

    l_usage_total_exposure
                     := NVL(l_cum_total_from_ar,0)
                        + NVL(l_cum_payments_at_risk,0)
                        + NVL(l_cum_uninv_order_total,0)
                        - NVL(l_cum_total_commitment,0)
                        + NVL(l_cum_external_exposure,0) ;

    --
    -- Set the detail output variables only when detail is selected.
    --
    IF l_need_exposure_details = 'Y' THEN
      -- Add hold amount to order amount if hold flag is not set
      -- because the uninvoiced order amount is not available.
      IF l_orders_on_hold_flag = 'Y' THEN
        l_cum_order_amount := l_cum_uninv_order_total -
                              NVL(l_cum_total_commitment,0);
      ELSE
        l_cum_order_amount :=  l_cum_uninv_order_total
                             - NVL(l_cum_total_commitment,0)
                             + l_cum_total_on_hold;
      END IF;

      l_cum_order_hold_amount := l_cum_total_on_hold;
      l_cum_ar_amount    := NVL(l_cum_total_from_ar,0) +
                            NVL(l_cum_payments_at_risk,0) ;
    END IF;

    IF G_debug_flag = 'Y'
    THEN

      OE_DEBUG_PUB.ADD(' l_usage_total_exposure    = '
                    || l_usage_total_exposure );
      OE_DEBUG_PUB.ADD(' l_cum_total_from_ar       = '
                    || l_cum_total_from_ar );
      OE_DEBUG_PUB.ADD(' l_total_from_ar           = '
                    || l_total_from_ar);
      OE_DEBUG_PUB.ADD(' l_total_from_br           = '
                    || l_total_from_br);
      OE_DEBUG_PUB.ADD(' l_cum_payments_at_risk    = '
                    || l_cum_payments_at_risk );
      OE_DEBUG_PUB.ADD(' l_payments_at_risk        = '
                    || l_payments_at_risk);
      OE_DEBUG_PUB.ADD(' l_payments_at_risk_br     = '
                    || l_payments_at_risk_br);
      OE_DEBUG_PUB.ADD(' l_cum_total_on_order      = '
                    || l_cum_total_on_order );
      OE_DEBUG_PUB.ADD(' l_total_on_order          = '
                    || l_total_on_order );
      OE_DEBUG_PUB.ADD(' l_uninvoiced_hdr_freight1 = '
                    || l_uninvoiced_hdr_freight1 );
      OE_DEBUG_PUB.ADD(' l_uninvoiced_hdr_freight2 = '
                    || l_uninvoiced_hdr_freight2 );
      OE_DEBUG_PUB.ADD(' l_cum_total_commitment      = '
                    || l_cum_total_commitment );
      OE_DEBUG_PUB.ADD(' l_total_commitment          = '
                    || l_total_commitment );
      OE_DEBUG_PUB.ADD(' l_usage_total_exposure    = '
                    || l_usage_total_exposure );

      -- no hold
      OE_DEBUG_PUB.ADD(' l_cum_total_no_hold       = '
                    || l_cum_total_no_hold );
      OE_DEBUG_PUB.ADD(' l_total_no_hold           = '
                    || l_total_no_hold );
      OE_DEBUG_PUB.ADD(' l_no_hold_hdr_freight1    = '
                    || l_no_hold_hdr_freight1 );
      OE_DEBUG_PUB.ADD(' l_no_hold_hdr_freight2    = '
                      || l_no_hold_hdr_freight2);
      -- external
      OE_DEBUG_PUB.ADD(' l_external_exposure       = '
                    || l_external_exposure );
      OE_DEBUG_PUB.ADD(' l_cum_external_exposure   = '
                    || l_cum_external_exposure );
      -- details
      OE_DEBUG_PUB.ADD(' l_cum_total_on_hold       = '
                    || l_cum_total_on_hold );
      OE_DEBUG_PUB.ADD(' l_total_on_hold           = '
                    || l_total_on_hold );
      OE_DEBUG_PUB.ADD(' l_hold_hdr_freight1       = '
                    || l_hold_hdr_freight1 );
      OE_DEBUG_PUB.ADD(' l_hold_hdr_freight2       = '
                    || l_hold_hdr_freight2);
      OE_DEBUG_PUB.ADD(' l_cum_order_amount        = '
                    || l_cum_order_amount );
      OE_DEBUG_PUB.ADD(' l_cum_order_hold_amount   = '
                    || l_cum_order_hold_amount );
      OE_DEBUG_PUB.ADD(' l_cum_ar_amount           = '
                    || l_cum_ar_amount);

      OE_DEBUG_PUB.ADD(' Call currency conversion for exposure  ' );
      OE_DEBUG_PUB.Add(' GL_CURRENCY = '||
         OE_Credit_Engine_GRP.GL_currency );
    END IF;


    IF OE_Credit_Engine_GRP.GL_currency IS NULL
    THEN
      OE_DEBUG_PUB.ADD(' Call GET_GL_currency ');

      OE_Credit_Engine_GRP.GL_currency :=
                   OE_CREDIT_CHECK_UTIL.GET_GL_currency ;

          OE_DEBUG_PUB.ADD(' GL_CURRENCY  after = '
                 || OE_Credit_Engine_GRP.GL_currency );

    END IF;

    l_limit_total_exposure :=
    OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
      ( p_amount	            => l_usage_total_exposure
      , p_transactional_currency  => p_usage_curr(i).usage_curr_code
      , p_limit_currency	    => p_limit_curr_code
      , p_functional_currency     => OE_Credit_Engine_GRP.GL_currency
      , p_conversion_date	    => SYSDATE
      , p_conversion_type	    => p_credit_check_rule_rec.conversion_type
      );

    l_total_exposure := NVL(l_total_exposure,0)
                      + NVL(l_limit_total_exposure,0) ;

    IF p_need_exposure_details = 'Y'
    THEN
      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.add( ' Into p_need_exposure_details ');
      END IF;

      l_limit_cum_order_amount :=
        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
        ( p_amount                  => l_cum_order_amount
        , p_transactional_currency  => p_usage_curr(i).usage_curr_code
        , p_limit_currency          => p_limit_curr_code
        , p_functional_currency     => OE_Credit_Engine_GRP.GL_currency
        , p_conversion_date         => SYSDATE
        , p_conversion_type         =>
                                    p_credit_check_rule_rec.conversion_type
        );


      l_limit_cum_order_hold_amount :=
        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
           ( p_amount                  =>l_cum_order_hold_amount
           , p_transactional_currency  => p_usage_curr(i).usage_curr_code
           , p_limit_currency          => p_limit_curr_code
           , p_functional_currency     => OE_Credit_Engine_GRP.GL_currency
           , p_conversion_date         => SYSDATE
           , p_conversion_type         =>
                 p_credit_check_rule_rec.conversion_type
           );

      l_limit_cum_ar_amount :=
        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
           ( p_amount                  => l_cum_ar_amount
           , p_transactional_currency  => p_usage_curr(i).usage_curr_code
           , p_limit_currency          => p_limit_curr_code
           , p_functional_currency     => OE_Credit_Engine_GRP.GL_currency
           , p_conversion_date         => SYSDATE
           , p_conversion_type         =>
              p_credit_check_rule_rec.conversion_type
           );

      l_order_amount := l_order_amount +
               NVL(l_limit_cum_order_amount,0) ;

      l_order_hold_amount := l_order_hold_amount +
                NVL(l_limit_cum_order_hold_amount,0) ;

      l_ar_amount := l_ar_amount +
                NVL(l_limit_cum_ar_amount,0) ;

    END IF;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' l_limit_total_exposure = '
                      || l_limit_total_exposure );
      OE_DEBUG_PUB.ADD(' l_total_exposure       = '|| l_total_exposure );
    END IF;

    l_limit_total_exposure     := 0;
    l_usage_total_exposure     := 0;
    l_cum_uninv_order_total    := 0;

    l_cum_total_on_order       := 0;
    l_total_on_order           := 0;
    l_uninvoiced_hdr_freight1  := 0;
    l_uninvoiced_hdr_freight2  := 0;

    l_cum_total_commitment     := 0;
    l_total_commitment         := 0;

    l_cum_payments_at_risk     := 0;
    l_payments_at_risk         := 0;
    l_payments_at_risk_br      := 0;

    l_cum_total_from_ar        := 0;
    l_total_from_ar            := 0;
    l_total_from_br            := 0;

    l_cum_external_exposure    := 0;
    l_external_exposure        := 0;

    l_cum_total_no_hold        := 0;
    l_total_no_hold            := 0;
    l_no_hold_hdr_freight1     := 0;
    l_no_hold_hdr_freight2     := 0;

    l_cum_total_on_hold        := 0;
    l_total_on_hold            := 0;
    l_hold_hdr_freight1        := 0;
    l_hold_hdr_freight2        := 0;

    l_cum_order_amount         := 0;
    l_cum_order_hold_amount    := 0 ;
    l_cum_ar_amount            := 0 ;

    l_limit_cum_order_amount           := 0;
    l_limit_cum_order_hold_amount      := 0 ;
    l_limit_cum_ar_amount              := 0 ;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add('--------------------------');
      OE_DEBUG_PUB.Add(' ');
    END IF;

    END LOOP ; -- CURRENCY LOOP

  ELSE -- SITE
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.Add('Get_order_Exposure SITE : ',1);
    END IF;

    l_current_usage_cur := NULL ;

    FOR i IN 1..p_usage_curr.count
    LOOP
      l_current_usage_cur := NULL ;

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('  ');
        OE_DEBUG_PUB.ADD('############################### ');
        OE_DEBUG_PUB.ADD('USAGE CURR = '|| p_usage_curr(i).usage_curr_code );
        OE_DEBUG_PUB.ADD('############################### ');
        OE_DEBUG_PUB.ADD('  ');
        OE_DEBUG_PUB.ADD('l_current_usage_cur = '||
                  l_current_usage_cur );
        OE_DEBUG_PUB.ADD('  ');
        OE_DEBUG_PUB.ADD('.');
      END IF;

      l_current_usage_cur := p_usage_curr(i).usage_curr_code ;

      -- get site external exposure
      IF l_incl_external_exposure_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add(' Get site external exposure balance ');

        OPEN site_external_exposure_csr (p_usage_curr(i).usage_curr_code);
        FETCH site_external_exposure_csr INTO l_external_exposure;
        IF site_external_exposure_csr%NOTFOUND
        THEN
          OE_DEBUG_PUB.Add(' No external exposure balance found');
          l_external_exposure := 0;
        END IF;
        CLOSE site_external_exposure_csr;
      END IF;
      l_cum_external_exposure := l_cum_external_exposure +
                                 NVL(l_external_exposure, 0);

      IF l_open_ar_balance_flag = 'Y'
      THEN
        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.Add(' Get site_ar_balance ');
        END IF;

        OPEN site_ar_balance (p_usage_curr(i).usage_curr_code);
        FETCH site_ar_balance INTO l_total_from_ar;
        IF site_ar_balance%NOTFOUND
        THEN
          l_total_from_ar := 0 ;
          OE_DEBUG_PUB.Add(' No site_ar_balance found ');
        END IF;

        CLOSE site_ar_balance;
      END IF;

      IF l_include_risk_flag = 'Y'
      THEN
        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.Add(' Get site_pay_risk ');
        END IF;
        OPEN site_pay_risk (p_usage_curr(i).usage_curr_code);
        FETCH site_pay_risk INTO l_payments_at_risk;
        IF site_pay_risk%NOTFOUND
        THEN
          l_payments_at_risk := 0 ;
          OE_DEBUG_PUB.Add(' No site_pay_risk found ');
        END IF;

        CLOSE site_pay_risk;
      END IF;

      l_drawee_site_use_id := NULL ;
----------------------------- BR ------------------------
      IF l_open_ar_balance_flag = 'Y'
      THEN
        l_drawee_site_use_id :=
           oe_credit_check_util.get_drawee_site_use_id ( p_site_use_id);
      END IF;

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add(' l_drawee_site_use_id ==> '|| l_drawee_site_use_id );
      END IF;

      IF l_drawee_site_use_id is NOT NULL
      THEN
        IF l_open_ar_balance_flag = 'Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
             OE_DEBUG_PUB.Add(' Get site_br_balance ');
          END IF;
          OPEN site_br_balance (p_usage_curr(i).usage_curr_code);
          FETCH site_br_balance INTO l_total_from_br;
          IF site_br_balance%NOTFOUND
          THEN
            l_total_from_br := 0 ;
            OE_DEBUG_PUB.Add(' No site_br_balance found ');
          END IF;

          CLOSE site_br_balance;
        END IF;

        IF l_include_risk_flag = 'Y'
        THEN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Get site_br_pay_risk ');
          END IF;
          OPEN site_br_pay_risk (p_usage_curr(i).usage_curr_code);
          FETCH site_br_pay_risk INTO l_payments_at_risk_br;
          IF site_br_pay_risk%NOTFOUND
          THEN
            l_payments_at_risk_br := 0 ;
            OE_DEBUG_PUB.Add(' No site_pay_risk found ');
          END IF;

          CLOSE site_br_pay_risk;
        END IF; --ar
      ELSE
        IF G_debug_flag = 'Y'
        THEN
         OE_DEBUG_PUB.Add(' No site BR required ');
        END IF;
      END IF;
--vto2
      IF l_uninvoiced_orders_flag = 'Y'
      THEN
        BEGIN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.Add(' Begin OM Exposure for site ');
          END IF;

          IF OE_Commitment_PVT.Do_Commitment_Sequencing THEN
            IF G_debug_flag = 'Y'
            THEN
              OE_DEBUG_PUB.Add('  site_commitments ');
            END IF;

            OPEN site_commitment_total (p_usage_curr(i).usage_curr_code);
            FETCH site_commitment_total INTO l_total_commitment ;
            IF site_commitment_total%NOTFOUND
            THEN
              l_total_commitment := 0 ;
              OE_DEBUG_PUB.Add('No site commitments found ');
            END IF;

            CLOSE site_commitment_total ;
          END IF;

          IF l_orders_on_hold_flag = 'Y'
          THEN

            ----added for Returns
            IF l_include_returns_flag='N'
            THEN
              -----returns are not included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add(' Get site_uninvoiced_orders,site_uninvoiced_orders ');
              END IF;

              OPEN site_uninvoiced_orders(p_usage_curr(i).usage_curr_code);
              FETCH site_uninvoiced_orders INTO l_total_on_order;

              IF site_uninvoiced_orders%NOTFOUND
              THEN
                l_total_on_order := 0 ;
                OE_DEBUG_PUB.Add(' No site_uninvoiced_orders found ');
              END IF;

              CLOSE site_uninvoiced_orders;

            ELSE
              -----returns are included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add(' open site_uninvoiced_orders_ret ');
              END IF;

              OPEN site_uninvoiced_orders_ret(p_usage_curr(i).usage_curr_code);
              FETCH site_uninvoiced_orders_ret INTO l_total_on_order;

              IF site_uninvoiced_orders_ret%NOTFOUND
              THEN
                l_total_on_order := 0 ;
                OE_DEBUG_PUB.Add(' No site_uninvoiced_orders found ');
              END IF;

              CLOSE site_uninvoiced_orders_ret;

            END IF; ---end of checking if returns are included

            IF l_freight_charges_flag ='Y'
            THEN

              ----added for Returns
              IF l_include_returns_flag='N'
              THEN
                -----returns are not included
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add(' Get site_uninv_hdr_freight1 ');
                END IF;

                OPEN site_uninv_hdr_freight1(p_usage_curr(i).usage_curr_code);
                FETCH site_uninv_hdr_freight1 INTO l_uninvoiced_hdr_freight1;

                IF site_uninv_hdr_freight1%NOTFOUND
                THEN
                  l_uninvoiced_hdr_freight1 := 0 ;
                  OE_DEBUG_PUB.Add(' No site_uninv_hdr_freight1 found ');
                END IF;

                CLOSE site_uninv_hdr_freight1;

                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add(' Get site_uninv_hdr_freight2 ');
                END IF;

                OPEN site_uninv_hdr_freight2(p_usage_curr(i).usage_curr_code);

                FETCH site_uninv_hdr_freight2 INTO l_uninvoiced_hdr_freight2;

                IF site_uninv_hdr_freight2%NOTFOUND
                THEN
                  l_uninvoiced_hdr_freight2 := 0 ;
                  OE_DEBUG_PUB.Add(' No site_uninv_hdr_freight2 found ');
                END IF;

                CLOSE site_uninv_hdr_freight2;

              ELSE
                -----returns are included
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add(' Get site_uninv_hdr_freight1_ret ');
                END IF;

                OPEN site_uninv_hdr_freight1_ret(p_usage_curr(i).usage_curr_code);
                FETCH site_uninv_hdr_freight1_ret INTO l_uninvoiced_hdr_freight1;

                IF site_uninv_hdr_freight1_ret%NOTFOUND
                THEN
                  l_uninvoiced_hdr_freight1 := 0 ;
                  OE_DEBUG_PUB.Add(' No site_uninv_hdr_freight1 found ');
                END IF;

                CLOSE site_uninv_hdr_freight1_ret;

                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add(' Get site_uninv_hdr_freight2_ret ');
                END IF;

                OPEN site_uninv_hdr_freight2_ret(p_usage_curr(i).usage_curr_code);

                FETCH site_uninv_hdr_freight2_ret INTO l_uninvoiced_hdr_freight2;

                IF site_uninv_hdr_freight2_ret%NOTFOUND
                THEN
                  l_uninvoiced_hdr_freight2 := 0 ;
                  OE_DEBUG_PUB.Add(' No site_uninv_hdr_freight2_ret found ');
                END IF;

                CLOSE site_uninv_hdr_freight2_ret;

              END IF; ----end of checking if returns are included

            END IF; -- freight = Y
          ELSE -- do not include orders on hold

            ----added for Returns
            IF l_include_returns_flag='N'
            THEN
              -----returns are not included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add(' Get site_orders_not_on_hold ');
              END IF;

              OPEN site_orders_not_on_hold (p_usage_curr(i).usage_curr_code);

              FETCH site_orders_not_on_hold INTO l_total_no_hold;

              IF site_orders_not_on_hold%NOTFOUND
              THEN
                l_total_no_hold := 0 ;
                OE_DEBUG_PUB.Add(' No site orders not on hold found ');
              END IF;

              CLOSE site_orders_not_on_hold;
              -- Get orders on hold amount if need_exposure_details is enabled
              IF l_need_exposure_details = 'Y'
              THEN
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add(' Get site_orders_on_hold ');
                END IF;

                OPEN site_orders_on_hold (p_usage_curr(i).usage_curr_code);
                FETCH site_orders_on_hold INTO l_total_on_hold;

                IF site_orders_on_hold%NOTFOUND
                THEN
                  l_total_on_hold := 0 ;
                  OE_DEBUG_PUB.Add(' No site orders on hold found ');
                END IF;

                CLOSE site_orders_on_hold;
              END IF;

            ELSE
              -----returns are included

              IF G_debug_flag = 'Y'
              THEN
                OE_DEBUG_PUB.Add(' Get site_orders_not_on_hold_ret ');
              END IF;

              OPEN site_orders_not_on_hold_ret (p_usage_curr(i).usage_curr_code);

              FETCH site_orders_not_on_hold_ret INTO l_total_no_hold;

              IF site_orders_not_on_hold_ret%NOTFOUND
              THEN
                l_total_no_hold := 0 ;
                OE_DEBUG_PUB.Add(' No site orders not on hold found ');
              END IF;

              CLOSE site_orders_not_on_hold_ret;

              -- Get orders on hold amount if need_exposure_details is enabled
              IF l_need_exposure_details = 'Y'
              THEN
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add(' Get site_orders_on_hold_ret ');
                END IF;

                OPEN site_orders_on_hold_ret(p_usage_curr(i).usage_curr_code);
                FETCH site_orders_on_hold_ret INTO l_total_on_hold;

                IF site_orders_on_hold_ret%NOTFOUND
                THEN
                  l_total_on_hold := 0 ;
                  OE_DEBUG_PUB.Add(' No site orders on hold found ');
                END IF;

                CLOSE site_orders_on_hold_ret;
              END IF;
            END IF; ----end of checking of returns are included

            IF l_freight_charges_flag ='Y'
            THEN
              --
              -- Get header freight if the site is the same as the given site
              -- or the site belong to the same customer as the given site
              -- if the credit level is CUSTOMER.
              --

              ----added for Returns
              IF l_include_returns_flag='N'
              THEN
                -----returns are not included
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add(' Get site_no_hold_hdr_freight1 ');
                END IF;

                OPEN site_no_hold_hdr_freight1(p_usage_curr(i).usage_curr_code);
                FETCH site_no_hold_hdr_freight1 INTO l_no_hold_hdr_freight1;

                IF site_no_hold_hdr_freight1%NOTFOUND
                THEN
                  l_no_hold_hdr_freight1 := 0 ;
                  OE_DEBUG_PUB.Add(' No site_no_hold_hdr_freight1  found ');
                END IF;

                CLOSE site_no_hold_hdr_freight1;

                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add(' Get  site_no_hold_hdr_freight2 ');
                END IF;

                OPEN site_no_hold_hdr_freight2(p_usage_curr(i).usage_curr_code);

                FETCH site_no_hold_hdr_freight2 INTO l_no_hold_hdr_freight2;

                IF site_no_hold_hdr_freight2%NOTFOUND
                THEN
                  l_no_hold_hdr_freight2 := 0 ;
                  OE_DEBUG_PUB.Add(' No site_no_hold_hdr_freight2 found ');
                END IF;

                CLOSE site_no_hold_hdr_freight2;

                -- Get orders on hold amount if need_exposure_details is enabled
                IF l_need_exposure_details = 'Y'
                THEN
                  IF G_debug_flag = 'Y'
                  THEN
                    OE_DEBUG_PUB.Add(' Get site_hold_hdr_freight1 ');
                  END IF;

                  OPEN site_hold_hdr_freight1(p_usage_curr(i).usage_curr_code);
                  FETCH site_hold_hdr_freight1 INTO l_hold_hdr_freight1;

                  IF site_hold_hdr_freight1%NOTFOUND
                  THEN
                    l_hold_hdr_freight1 := 0 ;
                    OE_DEBUG_PUB.Add(' No site_hold_hdr_freight1  found ');
                  END IF;

                  CLOSE site_hold_hdr_freight1;

                  IF G_debug_flag = 'Y'
                  THEN
                    OE_DEBUG_PUB.Add(' Get site_hold_hdr_freight2 ');
                  END IF;

                  OPEN site_hold_hdr_freight2(p_usage_curr(i).usage_curr_code);
                  FETCH site_hold_hdr_freight2 INTO l_hold_hdr_freight2;

                  IF site_hold_hdr_freight2%NOTFOUND
                  THEN
                    l_hold_hdr_freight2 := 0 ;
                    OE_DEBUG_PUB.Add(' No site_hold_hdr_freight2 found ');
                  END IF;
                  CLOSE site_hold_hdr_freight2;
                END IF; -- details freight on hold
              ELSE
                -----returns are included
                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add(' Get site_no_hold_hdr_freight1_ret ');
                END IF;

                OPEN site_no_hold_hdr_freight1_ret(p_usage_curr(i).usage_curr_code);
                FETCH site_no_hold_hdr_freight1_ret INTO l_no_hold_hdr_freight1;

                IF site_no_hold_hdr_freight1_ret%NOTFOUND
                THEN
                  l_no_hold_hdr_freight1 := 0 ;
                  OE_DEBUG_PUB.Add(' No site_no_hold_hdr_freight1  found ');
                END IF;

                CLOSE site_no_hold_hdr_freight1_ret;

                IF G_debug_flag = 'Y'
                THEN
                  OE_DEBUG_PUB.Add(' Get  site_no_hold_hdr_freight2_ret ');
                END IF;

                OPEN site_no_hold_hdr_freight2_ret(p_usage_curr(i).usage_curr_code);

                FETCH site_no_hold_hdr_freight2_ret INTO l_no_hold_hdr_freight2;

                IF site_no_hold_hdr_freight2_ret%NOTFOUND
                THEN
                  l_no_hold_hdr_freight2 := 0 ;
                  OE_DEBUG_PUB.Add(' No site_no_hold_hdr_freight2_ret found ');
                END IF;

                CLOSE site_no_hold_hdr_freight2_ret;

                -- Get orders on hold amount if need_exposure_details is enabled
                IF l_need_exposure_details = 'Y'
                THEN
                  IF G_debug_flag = 'Y'
                  THEN
                    OE_DEBUG_PUB.Add(' Get site_hold_hdr_freight1_ret ');
                  END IF;

                  OPEN site_hold_hdr_freight1_ret(p_usage_curr(i).usage_curr_code);
                  FETCH site_hold_hdr_freight1_ret INTO l_hold_hdr_freight1;

                  IF site_hold_hdr_freight1_ret%NOTFOUND
                  THEN
                    l_hold_hdr_freight1 := 0 ;
                    OE_DEBUG_PUB.Add(' No site_hold_hdr_freight1_ret  found ');
                  END IF;

                  CLOSE site_hold_hdr_freight1_ret;

                  IF G_debug_flag = 'Y'
                  THEN
                    OE_DEBUG_PUB.Add(' Get site_hold_hdr_freight2_ret ');
                  END IF;

                  OPEN site_hold_hdr_freight2_ret(p_usage_curr(i).usage_curr_code);
                  FETCH site_hold_hdr_freight2_ret INTO l_hold_hdr_freight2;

                  IF site_hold_hdr_freight2_ret%NOTFOUND
                  THEN
                    l_hold_hdr_freight2 := 0 ;
                    OE_DEBUG_PUB.Add(' No site_hold_hdr_freight2_ret found ');
                  END IF;
                  CLOSE site_hold_hdr_freight2_ret;
                END IF; -- details freight on hold
              END IF; -----end of checking if returns are included
            END IF;
          END IF; -- Orders on hold
        END;
      ELSE
        IF G_debug_flag = 'Y'
        THEN
          OE_DEBUG_PUB.Add(' No OM Exposure calculation for site ',1);
        END IF;
      END IF;

      l_cum_total_from_ar := l_cum_total_from_ar + NVL(l_total_from_ar,0) +
                    NVL(l_total_from_br,0) ;

      l_cum_payments_at_risk := l_cum_payments_at_risk
                                + NVL(l_payments_at_risk,0)
                                + NVL(l_payments_at_risk_br ,0 );

      l_cum_total_on_order := l_cum_total_on_order + NVL(l_total_on_order,0)
                                  + NVL(l_uninvoiced_hdr_freight1,0)
                                  + NVL(l_uninvoiced_hdr_freight2,0);
      l_cum_total_on_hold := l_cum_total_on_hold + NVL(l_total_on_hold,0)
                                  + NVL(l_hold_hdr_freight1,0)
                                  + NVL(l_hold_hdr_freight2,0);

      l_cum_total_no_hold := l_cum_total_no_hold + NVL(l_total_no_hold,0)
                                 + NVL(l_no_hold_hdr_freight1,0)
                                 + NVL(l_no_hold_hdr_freight2,0);

      IF l_orders_on_hold_flag = 'Y' THEN
        l_cum_uninv_order_total := l_cum_total_on_order;
      ELSE
        l_cum_uninv_order_total := l_cum_total_no_hold;
      END IF;

      l_cum_total_commitment := l_cum_total_commitment +
              NVL(l_total_commitment,0);

      l_usage_total_exposure := NVL(l_cum_total_from_ar,0)
                    + NVL(l_cum_payments_at_risk,0)
                    + NVL(l_cum_uninv_order_total,0)
                    - NVL(l_cum_total_commitment,0)
                    + NVL(l_cum_external_exposure,0);

      --
      -- Set the detail output variables only when detail is selected.
      --
      IF l_need_exposure_details = 'Y'
      THEN
        -- Add hold amount to order amount if hold flag is not set
        -- because the uninvoiced order amount is not available.
        IF l_orders_on_hold_flag = 'Y'
        THEN
          l_cum_order_amount := l_cum_uninv_order_total -
                                NVL(l_cum_total_commitment,0);
        ELSE
          l_cum_order_amount :=  l_cum_uninv_order_total
                               - NVL(l_cum_total_commitment,0)
                               + l_cum_total_on_hold;
        END IF;
        l_cum_order_hold_amount := l_cum_total_on_hold;
        l_cum_ar_amount         := NVL(l_cum_total_from_ar,0) +
                                   NVL(l_cum_payments_at_risk,0) ;
      END IF;

      IF G_debug_flag = 'Y'
      THEN

        OE_DEBUG_PUB.ADD(' l_usage_total_exposure    = '
                   || l_usage_total_exposure );
        OE_DEBUG_PUB.ADD(' l_cum_total_from_ar       = '
                   || l_cum_total_from_ar );
        OE_DEBUG_PUB.ADD(' l_total_from_ar           = '
                   || l_total_from_ar);
        OE_DEBUG_PUB.ADD(' l_total_from_br           = '
                   || l_total_from_br);
        OE_DEBUG_PUB.ADD(' l_cum_payments_at_risk    = '
                   || l_cum_payments_at_risk );
        OE_DEBUG_PUB.ADD(' l_payments_at_risk        = '
                   || l_payments_at_risk);
        OE_DEBUG_PUB.ADD(' l_payments_at_risk_br     = '
                   || l_payments_at_risk_br);
        OE_DEBUG_PUB.ADD(' l_cum_total_on_order      = '
                    || l_cum_total_on_order );
        OE_DEBUG_PUB.ADD(' l_total_on_order          = '
                    || l_total_on_order );
        OE_DEBUG_PUB.ADD(' l_uninvoiced_hdr_freight1 = '
                      || l_uninvoiced_hdr_freight1 );
        OE_DEBUG_PUB.ADD(' l_uninvoiced_hdr_freight2 = '
                    || l_uninvoiced_hdr_freight2 );
        OE_DEBUG_PUB.ADD(' l_cum_total_commitment    = '
                    || l_cum_total_commitment );
        OE_DEBUG_PUB.ADD(' l_total_commitment        = '
                    || l_total_commitment );
        OE_DEBUG_PUB.ADD(' l_usage_total_exposure    = '
                    || l_usage_total_exposure );

        -- details
        OE_DEBUG_PUB.ADD(' l_cum_total_on_hold       = '
                    || l_cum_total_on_hold );
        OE_DEBUG_PUB.ADD(' l_total_on_hold           = '
                    || l_total_on_hold );
        OE_DEBUG_PUB.ADD(' l_hold_hdr_freight1       = '
                    || l_hold_hdr_freight1 );
        OE_DEBUG_PUB.ADD(' l_hold_hdr_freight2       = '
                    || l_hold_hdr_freight2);
        OE_DEBUG_PUB.ADD(' l_cum_order_amount        = '
                    || l_cum_order_amount );
        OE_DEBUG_PUB.ADD(' l_cum_order_hold_amount   = '
                    || l_cum_order_hold_amount );
        OE_DEBUG_PUB.ADD(' l_cum_ar_amount           = '
                    || l_cum_ar_amount);

        -- external
        OE_DEBUG_PUB.ADD(' l_external_exposure       = '
                    || l_external_exposure );
        OE_DEBUG_PUB.ADD(' l_cum_external_exposure   = '
                    || l_cum_external_exposure );

        -- no holds
        OE_DEBUG_PUB.ADD(' l_cum_total_no_hold       = '
                    || l_cum_total_no_hold );
        OE_DEBUG_PUB.ADD(' l_total_no_hold           = '
                    || l_total_no_hold );
        OE_DEBUG_PUB.ADD(' l_no_hold_hdr_freight1    = '
                    || l_no_hold_hdr_freight1 );
        OE_DEBUG_PUB.ADD(' l_no_hold_hdr_freight2    = '
                    || l_no_hold_hdr_freight2);

        OE_DEBUG_PUB.ADD(' Call currency conversion for exposure ' );

        OE_DEBUG_PUB.Add(' GL_CURRENCY = '||
          OE_Credit_Engine_GRP.GL_currency );
      END IF;

      l_limit_total_exposure :=
        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
        ( p_amount	            => l_usage_total_exposure
        , p_transactional_currency  => p_usage_curr(i).usage_curr_code
        , p_limit_currency          => p_limit_curr_code
        , p_functional_currency     => OE_Credit_Engine_GRP.GL_currency
        , p_conversion_date         => SYSDATE
        , p_conversion_type	    => p_credit_check_rule_rec.conversion_type
        );


      l_total_exposure := l_total_exposure +  NVL(l_limit_total_exposure,0) ;

      IF l_need_exposure_details = 'Y' THEN
        IF G_debug_flag = 'Y' THEN
          oe_debug_pub.add( ' Into p_need_exposure_details ');
        END IF;

        l_limit_cum_order_amount :=
        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
          ( p_amount                  => l_cum_order_amount
          , p_transactional_currency  => p_usage_curr(i).usage_curr_code
          , p_limit_currency          => p_limit_curr_code
          , p_functional_currency     => OE_Credit_Engine_GRP.GL_currency
          , p_conversion_date         => SYSDATE
          , p_conversion_type         =>
                                    p_credit_check_rule_rec.conversion_type
          );

        l_limit_cum_order_hold_amount :=
        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
           ( p_amount                  => l_cum_order_hold_amount
           , p_transactional_currency  => p_usage_curr(i).usage_curr_code
           , p_limit_currency          => p_limit_curr_code
           , p_functional_currency     => OE_Credit_Engine_GRP.GL_currency
           , p_conversion_date         => SYSDATE
           , p_conversion_type         =>
                                       p_credit_check_rule_rec.conversion_type
           );
        l_limit_cum_ar_amount :=
        OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
           ( p_amount                  => l_cum_ar_amount
           , p_transactional_currency  => p_usage_curr(i).usage_curr_code
           , p_limit_currency          => p_limit_curr_code
           , p_functional_currency     => OE_Credit_Engine_GRP.GL_currency
           , p_conversion_date         => SYSDATE
           , p_conversion_type         =>
                                       p_credit_check_rule_rec.conversion_type
           );

        l_order_amount := l_order_amount +
               NVL(l_limit_cum_order_amount,0) ;

        l_order_hold_amount := l_order_hold_amount +
                NVL(l_limit_cum_order_hold_amount,0) ;

        l_ar_amount := l_ar_amount +
                NVL(l_limit_cum_ar_amount,0) ;

      END IF; -- details

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD(' l_limit_total_exposure = '
                   || l_limit_total_exposure );
        OE_DEBUG_PUB.ADD(' l_total_exposure       = '|| l_total_exposure );
      END IF;


      l_limit_total_exposure     := 0 ;
      l_usage_total_exposure     := 0 ;
      l_cum_total_on_order       := 0;
      l_cum_total_commitment     := 0;
      l_total_on_order           := 0;
      l_uninvoiced_hdr_freight1  := 0;
      l_uninvoiced_hdr_freight2  := 0;
      l_total_commitment         := 0;

      l_cum_payments_at_risk     := 0;
      l_payments_at_risk         := 0;
      l_payments_at_risk_br      := 0;

      l_cum_total_from_ar        := 0;
      l_total_from_ar            := 0;
      l_total_from_br            := 0;

      l_external_exposure        := 0;
      l_cum_external_exposure    := 0;

      l_hold_hdr_freight1        := 0;
      l_hold_hdr_freight2        := 0;
      l_total_on_hold            := 0;
      l_cum_total_on_hold        := 0;

      l_no_hold_hdr_freight1     := 0;
      l_no_hold_hdr_freight2     := 0;
      l_total_no_hold            := 0;
      l_cum_total_no_hold        := 0;

      l_cum_order_amount           := 0;
      l_cum_order_hold_amount      := 0 ;
      l_cum_ar_amount              := 0 ;

      l_limit_cum_order_amount           := 0;
      l_limit_cum_order_hold_amount      := 0 ;
      l_limit_cum_ar_amount              := 0 ;

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add(' ');
        OE_DEBUG_PUB.Add('=====================================');
        OE_DEBUG_PUB.Add(' ');
      END IF;

    END LOOP; -- currency loop

    OE_DEBUG_PUB.ADD('** Out NOCOPY of usage currency loop ' );

  END IF;

  l_current_usage_cur := NULL;

  -- Header ID can be passed as NULL to get the
  -- customer exposure

  IF p_header_id is NOT NULL
  THEN
    BEGIN
      -- Check the global. Get the current order value fromt the global
      -- this global would be set when calculating the transaction amount.

      l_limit_current_order  :=
              NVL(OE_CREDIT_CHECK_UTIL.g_current_order_value,0);

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.Add(' Current order value is available already = '
             || OE_CREDIT_CHECK_UTIL.g_current_order_value );
        OE_DEBUG_PUB.Add(' l_limit_current_order = '||
                 l_limit_current_order );
      END IF;
    END ; -- p_header_id

  ELSE
    l_limit_current_order := 0 ;

    OE_DEBUG_PUB.Add(' P_header_id is NULL, No current order check ',1);

  END IF ; -- p_header_id is NULL

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' l_limit_current_order = '|| l_limit_current_order );
    OE_DEBUG_PUB.Add(' l_order_amount        = '|| l_order_amount);
    OE_DEBUG_PUB.Add(' l_order_hold_amount   = '|| l_order_hold_amount);
    OE_DEBUG_PUB.Add(' l_ar_amount           = '|| l_ar_amount);
  END IF;

  x_total_exposure := NVL(l_total_exposure,0) + NVL(l_limit_current_order,0) ;

  IF l_need_exposure_details = 'Y'
  THEN
    x_order_amount      := l_order_amount;
    x_order_hold_amount := l_order_hold_amount;
    x_ar_amount         := l_ar_amount;
  END IF;

  OE_CREDIT_CHECK_UTIL.g_current_order_value := NULL ;

  --bug# 2714553
  OE_CREDIT_INTERFACE_UTIL.Get_exposure_amount
          ( p_header_id              => p_header_id
          , p_customer_id            => p_customer_id
          , p_site_use_id            => p_site_use_id
          , p_credit_check_rule_rec  => p_credit_check_rule_rec
          , p_system_parameter_rec   => p_system_parameter_rec
          , p_credit_level           => p_credit_level
          , p_limit_curr_code        => p_limit_curr_code
          , p_usage_curr             => p_usage_curr
          , p_global_exposure_flag   => p_global_exposure_flag
          , x_exposure_amount        => l_exposure_amount
          , x_conversion_status      => x_conversion_status
          , x_return_status          => x_return_status
         );

  IF G_debug_flag = 'Y'
  THEN
     OE_DEBUG_PUB.Add('after get_exposure_amount ');
     OE_DEBUG_PUB.Add(' x_return_status       = '|| x_return_status );
     OE_DEBUG_PUB.Add(' l_exposure_amount     = '|| l_exposure_amount );
     OE_DEBUG_PUB.Add(' err cur tbl count     = '|| x_conversion_status.COUNT );
     OE_DEBUG_PUB.Add(' l_limit_current_order = '|| l_limit_current_order );
     OE_DEBUG_PUB.Add(' l_total_exposure      = '|| l_total_exposure );
     OE_DEBUG_PUB.Add(' x_total_exposure      = '|| x_total_exposure );
  END IF;

  x_total_exposure := NVL(x_total_exposure,0) + NVL(l_exposure_amount,0) ;

  IF x_conversion_status.COUNT <> 0
  THEN
     FOR f IN 1..x_conversion_status.COUNT
     LOOP
         IF G_debug_flag = 'Y'
         THEN
            OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
            OE_DEBUG_PUB.ADD('!!!!! Exchange rate between '||x_conversion_status(f).usage_curr_code
                   ||' and credit limit currency '
                   ||p_limit_curr_code
                   ||' is missing for conversion type '
             || NVL(p_credit_check_rule_rec.user_conversion_type,'Corporate'),1);
            OE_DEBUG_PUB.ADD('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
         END IF;
     END LOOP;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR
  THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --bug# 2714553

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.Add('XX*****-------------##########-------------------XX' );
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.Add('Final Total Exposure amount  = '|| x_total_exposure,1);
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.Add('XX-------------- ##########------------------------XX' );
    OE_DEBUG_PUB.Add(' ');
    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY Get_order_exposure',1);
  END IF;

EXCEPTION
  WHEN  GL_CURRENCY_API.NO_RATE THEN
    OE_DEBUG_PUB.ADD('EXCEPTION: GL_CURRENCY_API.NO_RATE in get_order_exp',1);
    OE_DEBUG_PUB.ADD('l_current_usage_cur = '||
              l_current_usage_cur );
    x_conversion_status(1).usage_curr_code := l_current_usage_cur ;

    fnd_message.set_name('ONT', 'OE_CONVERSION_ERROR');
    OE_DEBUG_PUB.ADD('Exception table added ');
    IF cust_external_exposure_csr%ISOPEN THEN
      CLOSE cust_external_exposure_csr;
    END IF;
    IF site_external_exposure_csr%ISOPEN THEN
      CLOSE site_external_exposure_csr;
    END IF;
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, '
                                Get_order_exposure');
     END IF;
     IF cust_external_exposure_csr%ISOPEN THEN
       CLOSE cust_external_exposure_csr;
     END IF;
     IF site_external_exposure_csr%ISOPEN THEN
       CLOSE site_external_exposure_csr;
     END IF;
     RAISE;

END Get_order_exposure ;


--========================================================================
-- PROCEDURE : Currency_List
-- Comments  : This procedure is used by the credit snapshot report to derive
--             a comma delimited string of currencies defined in credit usage
-- Parameters: c_entity_type       IN    'CUSTOMER' or 'SITE'
--	       c_entity_id         IN    Customer_Id or Site_Id
--             c_trx_curr_code     IN    Transaction Currency
--             l_limit_curr_code   OUT NOCOPY   Currency Limit used for credit checking
--             Curr_list           OUT NOCOPY   Comma delimited string of currencies
--                                       covered by limit currency code
--========================================================================
Procedure currency_list (
   c_entity_type          IN  VARCHAR2
 , c_entity_id            IN  NUMBER
 , c_trx_curr_code        IN  VARCHAR2
 , l_limit_curr_code      OUT NOCOPY VARCHAR2
 , l_default_limit_flag   OUT NOCOPY VARCHAR2
 , Curr_list              OUT NOCOPY VARCHAR2) IS

  i                       NUMBER;
  l_return_status         NUMBER;
  l_CREDIT_CHECK_FLAG     VARCHAR2(1);
  l_OVERALL_CREDIT_LIMIT  NUMBER;
  l_TRX_CREDIT_LIMIT      NUMBER;
  l_include_all_flag      VARCHAR2(1);
  l_curr_tbl     OE_CREDIT_CHECK_UTIL.curr_tbl_type;
  l_global_exposure_flag  VARCHAR2(1);
  l_credit_limit_party_id  NUMBER ;
  l_use_credit_hierarchy   varchar2(1);


Begin

 l_limit_curr_code := NULL ;

  for i in 1 .. l_curr_tbl.COUNT
  LOOP
    if i = 1 then null;
    else
      curr_list := concat(curr_list,',');
    end if;
    curr_list := concat(curr_list, l_curr_tbl(i).usage_curr_code);
  END LOOP;

END Currency_List;



---========================================================================
-- PROCEDURE : CONVERT_CURRENCY_AMOUNT
-- Comments  :
-- 21-Jun-2001 - rajkrish updated with standard dbg messages
---========================================================================

FUNCTION CONVERT_CURRENCY_AMOUNT
( p_amount	                IN NUMBER := 0
, p_transactional_currency 	IN VARCHAR2
, p_limit_currency	        IN VARCHAR2
, p_functional_currency	        IN VARCHAR2
, p_conversion_date	        IN DATE := SYSDATE
, p_conversion_type	        IN VARCHAR2 := 'Corporate'
) RETURN NUMBER
IS

  l_converted_amount NUMBER;
  l_denominator NUMBER;
  l_numerator   NUMBER;
  l_rate        NUMBER;

BEGIN
  BEGIN
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('OEXUCRCB: IN CONVERT_CURRENCY_AMOUNT ');
      OE_DEBUG_PUB.ADD('  ');
      OE_DEBUG_PUB.ADD('------------------------------------');
      OE_DEBUG_PUB.ADD('p_amount = '|| p_amount );
      OE_DEBUG_PUB.ADD('p_transactional_currency = '
                    || p_transactional_currency );
      OE_DEBUG_PUB.ADD('p_limit_currency = '|| p_limit_currency );
      OE_DEBUG_PUB.ADD('p_functional_currency = '|| p_functional_currency );
      OE_DEBUG_PUB.ADD('p_conversion_date = '|| p_conversion_date );
      OE_DEBUG_PUB.ADD('p_conversion_type = '|| p_conversion_type );
      OE_DEBUG_PUB.ADD('  ');
      OE_DEBUG_PUB.ADD('------------------------------------');
     END IF;

    -- The conversion amount can be les than or greater than
    -- 0. For maounts equal to 0, there is not need for
    -- conversion to proceed and call GL API's

    IF NVL(p_amount,0) <> 0
    THEN
      gl_currency_api.convert_closest_amount
      (  x_from_currency    =>  p_transactional_currency
      ,  x_to_currency      =>  p_limit_currency
      ,  x_conversion_date  =>  p_conversion_date
      ,  x_conversion_type  =>  p_conversion_type
      ,  x_amount           =>  p_amount
      ,  x_user_rate        =>  NULL
      ,  x_max_roll_days    =>  -1
      ,  x_converted_amount =>  l_converted_amount
      ,  x_denominator      =>  l_denominator
      ,  x_numerator        =>  l_numerator
      ,  x_rate             =>  l_rate
      );

    ELSE
      l_converted_amount := 0 ;
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD(' No conversion, amount 0 ');
      END IF;
    END IF;

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD('Convert amt using trx curr = '|| l_converted_amount );
    END IF;

    return l_converted_amount;

    EXCEPTION
    WHEN  GL_CURRENCY_API.NO_RATE  THEN

    DECLARE
      l_functional_amount  NUMBER;
    BEGIN
      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD(' Convert using functional curr traingulate');
      END IF;

      gl_currency_api.convert_closest_amount
        (  x_from_currency    =>  p_transactional_currency
        ,  x_to_currency      =>  p_functional_currency
        ,  x_conversion_date  =>  p_conversion_date
        ,  x_conversion_type  =>  p_conversion_type
        ,  x_amount           =>  p_amount
        ,  x_user_rate        =>  NULL
        ,  x_max_roll_days    =>  -1
        ,  x_converted_amount =>  l_functional_amount
        ,  x_denominator      =>  l_denominator
        ,  x_numerator        =>  l_numerator
        ,  x_rate             =>  l_rate
        );

      gl_currency_api.convert_closest_amount
        (  x_from_currency    =>  p_functional_currency
        ,  x_to_currency      =>  p_limit_currency
        ,  x_conversion_date  =>  p_conversion_date
        ,  x_conversion_type  =>  p_conversion_type
        ,  x_amount           =>  l_functional_amount
        ,  x_user_rate        =>  NULL
        ,  x_max_roll_days    =>  -1
        ,  x_converted_amount =>  l_converted_amount
        ,  x_denominator      =>  l_denominator
        ,  x_numerator        =>  l_numerator
        ,  x_rate             =>  l_rate
        );

      IF G_debug_flag = 'Y'
      THEN
        OE_DEBUG_PUB.ADD('Convert amt using functional curr = '
            || l_converted_amount );
      END IF;
      return l_converted_amount;

    END;
  END;
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY CONVERT_CURRENCY_AMOUNT ');
  END IF;
END CONVERT_CURRENCY_AMOUNT;

--
--
------------------------------------------------------------
-- PROCEDURE: SEND_CREDIT_HOLD_NTF
-- COMMENTS:
------------------------------------------------------------
PROCEDURE SEND_CREDIT_HOLD_NTF
  (p_header_rec        IN  OE_ORDER_PUB.header_rec_type
  ,p_credit_hold_level IN  OE_CREDIT_CHECK_RULES.credit_hold_level_code%TYPE
  ,p_cc_hold_comment   IN  OE_HOLD_SOURCES.hold_comment%TYPE
  ,x_return_status     OUT NOCOPY VARCHAR2
  )
IS

  -- Cursor to get workflow user
  CURSOR wfn_to IS
  SELECT user_name
  FROM   fnd_user
  WHERE  user_id = p_header_rec.created_by ;

  -- Cursor to get the order type
  CURSOR c_order_type IS
  SELECT name
  FROM   oe_transaction_types_vl
  WHERE  transaction_type_id = p_header_rec.order_type_id;

  l_order_hold_comment VARCHAR2(2000);
  l_line_hold_count    NUMBER := 0;
  l_notification_id    NUMBER;
  l_wfn_to             VARCHAR2(100);
  l_order_type         VARCHAR2(30) := NULL;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(3000) ;

BEGIN
  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.ADD('In  OE_CREDIT_CHECK_UTIL.Send_Credit_Hold_NTF', 1);
  END IF;

  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get notification approver -- Created by

  BEGIN
    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.ADD('Get the Notification approver ', 2);
    END IF;
    --Code added for ER 2925718
    l_wfn_to := fnd_profile.Value('OE_CC_NTF_RECIPIENT');

    IF l_wfn_to IS NULL THEN
    --Code added newly is ended for ER 2925718
    OPEN wfn_to;
    FETCH wfn_to INTO l_wfn_to;
    IF wfn_to%NOTFOUND
    THEN
     l_wfn_to := NUll ;
    END IF;
    CLOSE wfn_to;

    END IF;
  END ;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.ADD(' l_wfn_to = '|| l_wfn_to, 2 );
  END IF;

  -- Set message attributes and send notification
  IF l_wfn_to is not NULL
  THEN
    BEGIN
      IF G_debug_flag = 'Y'
      THEN
        oe_debug_pub.ADD('Set the order type ', 2);
      END IF;

      OPEN c_order_type;
      FETCH c_order_type INTO l_order_type;
      IF c_order_type%NOTFOUND
      THEN
        l_wfn_to := NUll ;
      END IF;
      CLOSE c_order_type;
    END ;

    IF NVL(p_credit_hold_level, 'ORDER') = 'ORDER'
    THEN
      l_order_hold_comment := p_cc_hold_comment;
      l_line_hold_count := NULL;
    ELSIF p_credit_hold_level = 'LINE'
    THEN
      FND_MESSAGE.Set_Name('ONT','OE_CC_HLD_GENERAL_MSG');
      l_order_hold_comment := SUBSTR(FND_MESSAGE.GET,1,2000);
      l_line_hold_count := OE_CREDIT_CHECK_LINES_PVT.G_line_hold_count;
    END IF;

    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.ADD(' Before send notification ', 2);
    END IF;

    l_notification_id := wf_notification.send
    (   role         => l_wfn_to
    ,   msg_type     => OE_GLOBALS.g_wfi_hdr
    ,   msg_name     => 'ORDER_CREDIT_HOLDS'
    );

    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.ADD(' After send notification with ID = '||
           l_notification_id, 2 );
    END IF;

    wf_notification.setattrtext
    (   nid          => l_notification_id
    ,   aname        => 'ORDER_HOLD_COMMENT'
    ,   avalue       => l_order_hold_comment
    );

    wf_notification.setattrtext
    (   nid          => l_notification_id
    ,   aname        => 'ORDER_TYPE'
    ,   avalue       => l_order_type
    );

    wf_notification.setattrnumber
    (   nid          => l_notification_id
    ,   aname        => 'ORDER_NUMBER'
    ,   avalue       => p_header_rec.order_number
    );

    wf_notification.setattrnumber
    (   nid          => l_notification_id
    ,   aname        => 'LINE_HOLD_COUNT'
    ,   avalue       => l_line_hold_count
    );

    --
    -- Start: Bug 7476530 Fix (R12.1.1 and R12.2)
    --
    -- Ensure that the notification subject will be properly constructed.
    --

    Wf_Notification.Denormalize_Notification(nid => l_notification_id);

    -- End  : Bug 7476530 Fix


    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.ADD('-------Message Attribute Values-------',2);
      oe_debug_pub.ADD('l_order_type:         '||l_order_type,2);
      oe_debug_pub.ADD('l_order_number:       '||p_header_rec.order_number,2);
      oe_debug_pub.ADD('l_order_hold_comment: '||l_order_hold_comment,2);
      oe_debug_pub.ADD('l_line_hold_count:    '||l_line_hold_count,2);
      oe_debug_pub.ADD('--------------------------------------',2);
    END IF;

  ELSE
    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.ADD('No send notification l_wfn_to = '|| l_wfn_to, 2);
    END IF;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    oe_debug_pub.ADD('OEXUCRCB: OUT NOCOPY Send_Credit_Hold_NTF');
  END IF;

-- No exception raised as notification send is not considered
-- as a stop for credit checking

EXCEPTION
  WHEN OTHERS THEN
  BEGIN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.ADD(' EXCEPTION OTHERS IN SEND_NOTIFICATION');
      oe_debug_pub.ADD( ' Errm  = '|| SUBSTR(sqlerrm,1,200) );
    END IF;
    OE_MSG_PUB.Count_And_Get
           ( p_count => l_msg_count,
             p_data  => l_msg_data
           );
    IF G_debug_flag = 'Y'
    THEN
      oe_debug_pub.ADD(' l_msg_data = ' || l_msg_data );
    END IF;
    l_msg_data := NULL ;
    l_msg_count  := NULL ;
  END ;
END SEND_CREDIT_HOLD_NTF;

----------------------------------------------------------------------------
--  PROCEDURE: GET_external_trx_amount           PUBLIC
--  COMMENT  : Returns the transaction amount in the limit currency given the
--             amount in the transaction currency. If the
--             p_site_use_id IS null, the entire order is considered
--             x_conversion_status provides any currency conversion
--             error.
--             Used for external credit checking API.
-- BUG 4320650 Rounded the External transaction amount
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
)
IS
  l_limit_order_value NUMBER := 0;
BEGIN

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_external_trx_amount');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OE_CREDIT_CHECK_UTIL.g_current_order_value := NULL ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('Order Level Credit Check only');
  END IF ;
  -- convert amount
  BEGIN
  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' GL_CURRENCY = '|| OE_Credit_Engine_GRP.GL_currency);
    OE_DEBUG_PUB.ADD(' Total order amount = '|| p_transaction_amount);
  END IF;


    l_limit_order_value :=
      OE_CREDIT_CHECK_UTIL.CONVERT_CURRENCY_AMOUNT
        ( p_amount                 => p_transaction_amount
        , p_transactional_currency => p_transaction_curr_code
        , p_limit_currency         => p_limit_curr_code
        , p_functional_currency    => OE_Credit_Engine_GRP.GL_currency
        , p_conversion_date        => SYSDATE
        , p_conversion_type        => p_credit_check_rule_rec.conversion_type
      );
  END ;
--  x_amount := NVL(l_limit_order_value,0);

  OE_CREDIT_CHECK_UTIL.Rounded_Amount(p_currency_code => p_limit_curr_code
			,p_unrounded_amount =>  NVL(l_limit_order_value,0)
			,x_rounded_amount => x_amount);

  OE_CREDIT_CHECK_UTIL.g_current_order_value := x_amount ;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.Add(' g_current_order_value = '||
       OE_CREDIT_CHECK_UTIL.g_current_order_value);
    OE_DEBUG_PUB.Add(' Final trx check order amount = '|| x_amount,1 );
    OE_DEBUG_PUB.Add(' ====================================');
    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY Get_external_trx_amount ');
  END IF;

EXCEPTION
  WHEN  GL_CURRENCY_API.NO_RATE THEN
    OE_DEBUG_PUB.ADD('EXCEPTION: GL_CURRENCY_API.NO_RATE ');
    x_conversion_status(1).usage_curr_code := p_transaction_curr_code;
    fnd_message.set_name('ONT', 'OE_CONVERSION_ERROR');
    OE_DEBUG_PUB.ADD('Exception table added ');
  WHEN NO_DATA_FOUND THEN
    x_amount := 0 ;
    OE_DEBUG_PUB.ADD('EXCEPTION: NO_DATA_FOUND ');
  WHEN TOO_MANY_ROWS THEN
    x_amount := 0 ;
    OE_DEBUG_PUB.ADD('EXCEPTION: TOO_MANY_ROWS ');
  WHEN OTHERS THEN
    G_DBG_MSG := SUBSTRB(sqlerrm,1,200);
    OE_DEBUG_PUB.ADD('EXCEPTION = '|| SUBSTRB(sqlerrm,1,200));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     OE_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'GET_external_trx_amount'
      );
    END IF;
    RAISE;
END Get_external_trx_amount;


-----------------------------------------------------------------------------
--  PROCEDURE  : GET_default_Limit
--------------------------------------------------------------------------------
PROCEDURE GET_default_Limit
(  p_entity_id                   IN  NUMBER
 , p_trx_curr_code               IN  VARCHAR2
 , x_limit_curr_code             OUT NOCOPY VARCHAR2
 , x_trx_limit                   OUT NOCOPY NUMBER
 , x_overall_limit               OUT NOCOPY NUMBER
 , x_default_limit_flag          OUT NOCOPY VARCHAR2
 , x_global_exposure_flag        OUT NOCOPY VARCHAR2
)
IS

l_credit_usage_rule_set_id  NUMBER;
BEGIN
  IF G_debug_flag = 'Y'
  THEN
   OE_DEBUG_PUB.ADD('OEXUCRCB: IN GET_default_Limit ');
  END IF;

 x_default_limit_flag    := 'N' ;
 x_limit_curr_code       := NULL ;
 x_global_exposure_flag  := 'N' ;

 OE_DEBUG_PUB.ADD(' calling GET_multi_default_Limit ');

 GET_multi_default_Limit
          ( p_entity_id       => p_entity_id
          , p_trx_curr_code   => p_trx_curr_code
          , x_limit_curr_code => x_limit_curr_code
          , x_trx_limit       => x_trx_limit
          , x_overall_limit   => x_overall_limit
          , x_return_status   => x_default_limit_flag
          , x_credit_usage_rule_set_id
                       => l_credit_usage_rule_set_id
          , x_global_exposure_flag => x_global_exposure_flag
          );

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD(' Out NOCOPY GET_multi_default_Limit '
             || x_default_limit_flag );
    OE_DEBUG_PUB.ADD(' x_limit_curr_code = '|| x_limit_curr_code );
  END IF;

  IF     x_default_limit_flag = 'Y'
     AND x_trx_limit is NULL
     AND x_overall_limit is NULL
  THEN
     x_default_limit_flag := 'N' ;
     x_limit_curr_code    := NULL ;
     OE_DEBUG_PUB.ADD(' Limits NULL ');

  END IF;

  IF x_limit_curr_code IS NULL
  THEN
     x_default_limit_flag := 'N' ;
    OE_DEBUG_PUB.ADD(' calling GET_single_default_Limit ');
    GET_single_default_Limit
    (         p_entity_id       => p_entity_id
            , p_trx_curr_code   => p_trx_curr_code
            , x_limit_curr_code => x_limit_curr_code
            , x_trx_limit       => x_trx_limit
            , x_overall_limit   => x_overall_limit
            , x_return_status   => x_default_limit_flag
    );

   IF G_debug_flag = 'Y'
   THEN
     OE_DEBUG_PUB.ADD(' Out NOCOPY GET_single_default_Limit '
                             || x_default_limit_flag );
     OE_DEBUG_PUB.ADD(' x_limit_curr_code = '|| x_limit_curr_code );
   END IF;

  END IF;


  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY GET_default_Limit ' ||
         x_default_limit_flag );
  END IF;

 EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_default_Limit '
      );
    END IF;
    RAISE;

END GET_default_Limit ;


------------------------------------------------------------------------------
--  PROCEDURE  : Get_Limit_Info        PUBLIC
--  COMMENT    : Returns credit profiles for the
--               a) Customer
--               b) Site
--               c) party level
------------------------------------------------------------------------------
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
IS


l_Return_status          VARCHAR2(1) := NULL ;  --bug 4967828
l_suppress_unused_usages_flag VARCHAR2(1) ;
--bug 4212981
l_site_cc_flag           VARCHAR2(1);
l_cust_cc_flag           VARCHAR2(1);
l_dummy                  VARCHAR2(1);

BEGIN

  x_credit_limit_entity_id       := NULL ;
  x_credit_check_level           := NULL ;
  x_limit_curr_code              := NULL ;
  x_trx_limit                    := NULL ;
  x_overall_limit                := NULL ;
  x_include_all_flag             := 'N' ;
  x_default_limit_flag           := 'N' ;
  x_global_exposure_flag         := 'N' ;
  l_suppress_unused_usages_flag  := p_suppress_unused_usages_flag ;
  x_default_limit_flag           := 'N' ;

  OE_CREDIT_CHECK_UTIL.G_excl_curr_list := NULL ;

  IF G_debug_flag = 'Y'
  THEN

   OE_DEBUG_PUB.ADD('OEXUCRCB: IN get_limit_info', 1);
   OE_DEBUG_PUB.ADD(' ---------------------------------------------' );
   OE_DEBUG_PUB.ADD('G_ORG_ID           ==> '|| G_ORG_ID );
   OE_DEBUG_PUB.ADD('P_entity_Type      ==> '|| P_entity_Type );
   OE_DEBUG_PUB.ADD('P_entity_id        ==> '|| P_entity_id );
   OE_DEBUG_PUB.ADD('P_party_id         ==> '|| P_party_id );
   OE_DEBUG_PUB.ADD('p_trx_curr_code    ==> '|| p_trx_curr_code );
   OE_DEBUG_PUB.ADD('p_navigate_to_next_level ==> '||
           p_navigate_to_next_level );

   OE_DEBUG_PUB.ADD('p_suppress_unused_usages_flag ==> '||
              p_suppress_unused_usages_flag );

   OE_DEBUG_PUB.ADD(' ---------------------------------------------' );

   OE_DEBUG_PUB.ADD(' Call Get_Multi_Limit ');
  END IF;

  IF p_entity_type in ('SITE','CUSTOMER')
  THEN
        Get_Multi_Limit
        ( p_entity_type                    => p_entity_type
        , p_entity_id                      => p_entity_id
        , p_trx_curr_code                  => p_trx_curr_code
        , x_limit_curr_code                => x_limit_curr_code
        , x_trx_limit                      => x_trx_limit
        , x_overall_limit                  => x_overall_limit
        , x_global_exposure_flag           => x_global_exposure_flag
        --bug 4212981
        , x_site_cc_flag                   => l_site_cc_flag
        , x_cust_cc_flag                   => l_dummy
       );

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD(' Out NOCOPY of Get_Multi_Limit ');
      OE_DEBUG_PUB.ADD('x_limit_curr_code ==> '|| x_limit_curr_code );
    END IF;

    IF x_limit_curr_code IS NOT NULL
    THEN

       x_credit_limit_entity_id := p_entity_id ;
       x_credit_check_level     := p_entity_type ;

    ELSIF    x_limit_curr_code IS NULL
          AND p_entity_type = 'SITE'
          AND NVL(l_site_cc_flag, 'Y') = 'Y'  --bug 4212981 , bug 4582292
    THEN
      IF G_debug_flag = 'Y'
      THEN
         OE_DEBUG_PUB.ADD('calling Get_Multi_Limit for CUSTOMER ');
      END IF;
      Get_Multi_Limit
        ( p_entity_type                    => 'CUSTOMER'
         , p_entity_id                      => p_cust_account_id
         , p_trx_curr_code                  => p_trx_curr_code
         , x_limit_curr_code                => x_limit_curr_code
         , x_trx_limit                      => x_trx_limit
         , x_overall_limit                  => x_overall_limit
         , x_global_exposure_flag           => x_global_exposure_flag
         --bug 4582292
         , x_site_cc_flag                   => l_dummy
         , x_cust_cc_flag                   => l_cust_cc_flag
        );

      IF x_limit_curr_code IS NOT NULL
      THEN
        x_credit_limit_entity_id := p_cust_account_id ;
        x_credit_check_level     := 'CUSTOMER' ;
      END IF;
    END IF;
  END IF;

  OE_DEBUG_PUB.ADD('p_navigate_to_next_level ==> '|| p_navigate_to_next_level );
  OE_DEBUG_PUB.ADD('l_site_cc_flag           ==> '|| l_site_cc_flag );
  OE_DEBUG_PUB.ADD('l_cust_cc_flag           ==> '|| l_cust_cc_flag );
  OE_DEBUG_PUB.ADD('x_limit_curr_code        ==> '|| x_limit_curr_code );
  OE_DEBUG_PUB.ADD('l_return_status          ==> '|| l_return_status );

  IF p_navigate_to_next_level = 'Y' THEN --bug 5071518
     IF NVL(l_site_cc_flag, 'Y') = 'Y' AND NVL(l_cust_cc_flag, 'Y') = 'Y'  --bug 4212981 , bug4582292, bug 5071518
  THEN
    -----------------------------------------------------
    ------- Party level changes
    -----------------------------------------------------
    IF  p_precalc_exposure_used = 'Y'
    THEN
      IF OE_CREDIT_CHECK_UTIL.G_crmgmt_installed is NULL
      THEN
        OE_CREDIT_CHECK_UTIL.G_crmgmt_installed :=
          AR_CMGT_CREDIT_REQUEST_API.is_Credit_Management_Installed ;
      END IF;

      -- Get party limit only if credit management is installed
      IF OE_CREDIT_CHECK_UTIL.G_crmgmt_installed
      THEN
        IF  x_limit_curr_code IS NULL
        THEN
          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.ADD( 'OEXUCRCB:  GET_party_limit ');
          END IF;

          GET_party_limit
          (  p_party_id             => p_party_id
           , p_trx_curr_code         => p_trx_curr_code
           , x_limit_curr_code       => x_limit_curr_code
           , x_trx_limit             => x_trx_limit
           , x_overall_limit         => x_overall_limit
           , x_return_status         => l_return_status
           , x_credit_limit_entity_id => x_credit_limit_entity_id
          );

          IF G_debug_flag = 'Y'
          THEN
            OE_DEBUG_PUB.ADD( ' out NOCOPY  GET_party_limit ');
            OE_DEBUG_PUB.ADD( ' l_return_status ==> '|| l_return_status );
          END IF;

          IF x_limit_curr_code IS NOT NULL
          THEN
            x_credit_limit_entity_id := x_credit_limit_entity_id ;
            x_credit_check_level     := 'PARTY' ;
            x_global_exposure_flag   := 'Y' ;
          END IF;
        END IF;
      END IF ; -- support party
    END IF;
    END IF; --bug 5071518

    IF x_limit_curr_code IS NULL
       AND NVL(l_return_status,'Y') = 'Y' -- bug 4958142
    THEN
      OE_DEBUG_PUB.ADD( ' calling GET_default_Limit ');
      GET_default_Limit
       (  p_entity_id                  => p_entity_id
        , p_trx_curr_code              => p_trx_curr_code
        , x_limit_curr_code            => x_limit_curr_code
        , x_trx_limit                  => x_trx_limit
        , x_overall_limit              => x_overall_limit
        , x_default_limit_flag         => x_default_limit_flag
        , x_global_exposure_flag       => x_global_exposure_flag
        );

      IF x_limit_curr_code IS NOT NULL
      THEN
        x_credit_limit_entity_id := p_cust_account_id ;
        x_credit_check_level     := 'CUSTOMER' ;
      END IF;
    END IF;

    -- Start bug 5071518
    OE_DEBUG_PUB.ADD(' x_limit_curr_code    => '|| x_limit_curr_code );
    OE_DEBUG_PUB.ADD(' x_trx_limit          => '|| x_trx_limit );
    OE_DEBUG_PUB.ADD(' x_overall_limit      => '|| x_overall_limit );
    OE_DEBUG_PUB.ADD(' x_default_limit_flag => '|| x_default_limit_flag );

  END IF; -- navigate

  IF x_limit_curr_code IS NULL
  THEN
     OE_DEBUG_PUB.ADD(' No limits for any level ');

     x_trx_limit            := NULL ;
     x_overall_limit        := NULL ;
     x_include_all_flag     := 'N' ;
     x_default_limit_flag   := 'N' ;
     x_global_exposure_flag := 'N' ;
     x_credit_limit_entity_id := NULL ;
     x_credit_check_level     := NULL ;

  ELSE
    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD( ' Calling Get_Usages' );
      OE_DEBUG_PUB.ADD('x_limit_curr_code ==> '|| x_limit_curr_code );
      OE_DEBUG_PUB.ADD('x_default_limit_flag ==> '|| x_default_limit_flag );
      OE_DEBUG_PUB.ADD('x_global_exposure_flag ==> '|| x_global_exposure_flag );
      OE_DEBUG_PUB.ADD('x_include_all_flag ==> '|| x_include_all_flag );
      OE_DEBUG_PUB.ADD('x_credit_limit_entity_id ==> '||
         x_credit_limit_entity_id );
      OE_DEBUG_PUB.ADD('x_credit_check_level ==> '||
         x_credit_check_level );
    END IF;

    IF x_credit_check_level = 'PARTY'
    THEN
      l_suppress_unused_usages_flag := 'N' ;
    END IF;

    Get_Usages
    (   p_entity_type                 => x_credit_check_level
      , p_entity_id                   => x_credit_limit_entity_id
      , p_limit_curr_code             => x_limit_curr_code
      , p_suppress_unused_usages_flag => l_suppress_unused_usages_flag
      , p_default_limit_flag          => x_default_limit_flag
      , p_global_exposure_flag        => x_global_exposure_flag
      , x_include_all_flag            => x_include_all_flag
      , x_usage_curr_tbl              => x_usage_curr_tbl
    );

    IF G_debug_flag = 'Y'
    THEN
      OE_DEBUG_PUB.ADD( ' Out NOCOPY of Get_Usages ');
    END IF;
  END IF;

  IF G_debug_flag = 'Y'
  THEN
    OE_DEBUG_PUB.ADD('OEXUCRCB: OUT NOCOPY get_limit_info  ',1);
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
   G_DBG_MSG := SUBSTR(sqlerrm,1,200);

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' get_limit_info '
      );
    END IF;
    RAISE;

END get_limit_info ;

-- Linda
-----------------------------------------------------
-- to get the lookup meaning
------------------------------------------------------

FUNCTION Get_CC_Lookup_Meaning
        (p_lookup_type	IN VARCHAR2,
         p_lookup_code	IN VARCHAR2
        )
RETURN VARCHAR2
IS

l_meaning	VARCHAR2(80);

BEGIN
  SELECT meaning
  INTO   l_meaning
  FROM   oe_lookups
  WHERE  lookup_type = p_lookup_type
  AND    lookup_code = p_lookup_code;

  RETURN (l_meaning);

EXCEPTION
    When Others Then
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_CC_Lookup_Meaning'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_CC_Lookup_Meaning;


END OE_CREDIT_CHECK_UTIL;

/
