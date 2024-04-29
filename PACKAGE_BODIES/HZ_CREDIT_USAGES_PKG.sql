--------------------------------------------------------
--  DDL for Package Body HZ_CREDIT_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CREDIT_USAGES_PKG" AS
/* $Header: ARHUSAGB.pls 115.10 2004/02/03 22:47:44 bsarkar ship $ */


----------Globals
G_ORG_ID            NUMBER:= FND_PROFILE.value('ORG_ID') ;

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
RETURN VARCHAR2
IS
l_count NUMBER;
l_result VARCHAR2(3);

BEGIN

 IF AR_CMGT_CREDIT_REQUEST_API.is_Credit_Management_Installed
   = TRUE
  THEN
    l_result := 'NEW';
  ELSE
   l_result := 'OLD';
  END IF;

  RETURN (l_result);

END Check_release;

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
)
IS

CURSOR usages_csr IS
  SELECT
    rowid
  FROM
    HZ_CREDIT_USAGES
  WHERE credit_usage_id=p_credit_usage_id;

BEGIN

  INSERT INTO hz_credit_usages
  ( credit_usage_id
  , credit_profile_amt_id
  , cust_acct_profile_amt_id
  , profile_class_amount_id
  , credit_usage_rule_set_id
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_application_id
  , program_id
  , program_update_date
  , request_id
  , attribute_category
  , attribute1
  , attribute2
  , attribute3
  , attribute4
  , attribute5
  , attribute6
  , attribute7
  , attribute8
  , attribute9
  , attribute10
  , attribute11
  , attribute12
  , attribute13
  , attribute14
  , attribute15
  )
  VALUES
  ( p_credit_usage_id
  , p_credit_profile_amt_id
  , p_cust_acct_profile_amt_id
  , p_profile_class_amt_id
  , p_credit_usage_rule_set_id
  , p_creation_date
  , p_created_by
  , p_last_update_date
  , p_last_updated_by
  , p_last_update_login
  , null
  , null
  , null
  , null
  , p_attribute_category
  , p_attribute1
  , p_attribute2
  , p_attribute3
  , p_attribute4
  , p_attribute5
  , p_attribute6
  , p_attribute7
  , p_attribute8
  , p_attribute9
  , p_attribute10
  , p_attribute11
  , p_attribute12
  , p_attribute13
  , p_attribute14
  , p_attribute15
  );

  OPEN usages_csr;
  FETCH  usages_csr INTO p_row_id;
  IF (usages_csr%NOTFOUND)
  THEN
    CLOSE usages_csr;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE usages_csr;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Insert_row');
    END IF;
    RAISE;

 END Insert_row;

--========================================================================
-- PROCEDURE : Delete_row              PUBLIC
-- PARAMETERS: p_row_id                ROWID of the current record
-- COMMENT   : Procedure deletes record with ROWID=p_row_id from the
--             table HZ_CREDIT_USAGES.
--========================================================================
PROCEDURE Delete_row
( p_row_id  VARCHAR2
)
IS
BEGIN
  DELETE
  FROM HZ_CREDIT_USAGES
  WHERE ROWID=p_row_id;

    IF (SQL%NOTFOUND)
    THEN
      RAISE NO_DATA_FOUND;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_exc_msg(G_PKG_NAME,'Delete_row');
    END IF;
  RAISE;

END Delete_row;


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
)
IS
  CURSOR usage_csr
  IS
    SELECT *
    FROM hz_credit_usages
    WHERE rowid=CHARTOROWID(p_row_id)
    FOR UPDATE OF cust_acct_profile_amt_id NOWAIT;

  recinfo usage_csr%ROWTYPE;

BEGIN

  OPEN usage_csr;
  FETCH usage_csr INTO recinfo;
  IF (usage_csr%NOTFOUND)
  THEN
    CLOSE usage_csr;
    FND_MESSAGE.Set_name('FND', 'FORM_RECORD_DELETED');
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE usage_csr;

  IF ((recinfo.credit_usage_rule_set_id=p_credit_usage_rule_set_id)
      OR (recinfo.credit_usage_rule_set_id is NULL AND p_credit_usage_rule_set_id is NULL))
    AND
    ((NVL(recinfo.credit_profile_amt_id,-1)=p_credit_profile_amt_id)
      OR (recinfo.credit_profile_amt_id is NULL AND p_credit_profile_amt_id is NULL))
    AND
    ((NVL(recinfo.profile_class_amount_id,-1)=p_profile_class_amount_id)
      OR (recinfo.profile_class_amount_id is NULL AND p_profile_class_amount_id is NULL))
    AND
    ((NVL(recinfo.cust_acct_profile_amt_id,-1)=p_cust_acct_profile_amt_id)
      OR (recinfo.cust_acct_profile_amt_id is NULL AND p_cust_acct_profile_amt_id is NULL))
  THEN
     NULL;
  ELSE
     FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.raise_exception;
  END IF;

END Lock_Row;


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
) IS



CURSOR cust_multi_limit_no_incl_csr IS
  SELECT cpa.cust_acct_profile_amt_id
  ,      cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking
  ,      cu.credit_usage_rule_set_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = p_entity_id
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type = 'CURRENCY'
  AND     cur.user_code = p_trx_curr_code
  AND     NVL(cur.exclude_flag,'N') = 'N'
  ORDER BY cpa.overall_credit_limit ;


  cust_multi_limit_no_incl_rec   cust_multi_limit_no_incl_csr%ROWTYPE ;

  CURSOR cust_multi_limit_incl_csr IS
  SELECT  cpa.cust_acct_profile_amt_id
  ,    cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking
  ,      cu.credit_usage_rule_set_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = p_entity_id
  AND    cp.site_use_id               IS NULL
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date), TRUNC(SYSDATE)
            )    <= TRUNC(SYSDATE)
  AND   NVL (cur.include_all_flag, 'N') = 'Y'
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND   NOT EXISTS ( SELECT 'EXCLUDE'
                      FROM   hz_credit_usage_rules cur2
                      WHERE  cu.credit_usage_rule_set_id
                             = cur2.credit_usage_rule_set_id
                      AND    NVL(cur2.exclude_flag,'N') = 'Y'
                      AND    cur2.usage_type  = 'CURRENCY'
                      AND    cur2.user_code   = p_trx_curr_code
                    )
  ORDER BY cpa.overall_credit_limit ;


  cust_multi_limit_incl_rec cust_multi_limit_incl_csr%ROWTYPE ;


CURSOR site_multi_limit_no_incl_csr IS
  SELECT cpa.cust_acct_profile_amt_id
  ,      cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking
  ,      cu.credit_usage_rule_set_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.site_use_id               = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type = 'CURRENCY'
  AND     cur.user_code = p_trx_curr_code
 AND     NVL(cur.exclude_flag,'N') = 'N'
  ORDER BY cpa.overall_credit_limit ;

  site_multi_limit_no_incl_rec   site_multi_limit_no_incl_csr%ROWTYPE ;

  CURSOR site_multi_limit_incl_csr IS
  SELECT cpa.cust_acct_profile_amt_id
  ,      cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking
  ,      cu.credit_usage_rule_set_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.site_use_id               = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
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
                      AND    cur2.user_code   = p_trx_curr_code
                    )
  ORDER BY cpa.overall_credit_limit ;

 site_multi_limit_incl_rec   site_multi_limit_incl_csr%ROWTYPE ;


CURSOR party_multi_limit_no_incl_csr IS
  SELECT cpa.cust_acct_profile_amt_id
  ,      cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking
  ,      cu.credit_usage_rule_set_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = -1
  AND    cp.site_use_id               IS NULL
  AND    cp.party_id                  = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
  AND    cu.credit_usage_rule_set_id  = cur.credit_usage_rule_set_id
  AND    NVL(TRUNC(cpa.expiration_date) , TRUNC(SYSDATE) )
             <= TRUNC(SYSDATE)
  AND     NVL (cur.include_all_flag, 'N') = 'N'
  AND     cur.usage_type = 'CURRENCY'
  AND     cur.user_code = p_trx_curr_code
  AND     NVL(cur.exclude_flag,'N') = 'N'
  ORDER BY cpa.overall_credit_limit ;


  party_multi_limit_no_incl_rec   party_multi_limit_no_incl_csr%ROWTYPE ;

  CURSOR party_multi_limit_incl_csr IS
  SELECT  cpa.cust_acct_profile_amt_id
  ,    cpa.currency_code currency_code
  ,      cpa.overall_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           overall_limit
  ,      cpa.trx_credit_limit * ((100 + NVL(cp.tolerance,0))/100)
           trx_limit
  ,      cp.credit_checking
  ,      cu.credit_usage_rule_set_id
  FROM   hz_customer_profiles         cp
  ,      hz_cust_profile_amts         cpa
  ,      hz_credit_usages             cu
  ,      hz_credit_usage_rules        cur
  WHERE  cp.cust_account_id           = -1
  AND    cp.site_use_id               IS NULL
  AND    cp.party_id                  = p_entity_id
  AND    cp.cust_account_profile_id   = cpa.cust_account_profile_id
  AND    cpa.cust_acct_profile_amt_id = cu.cust_acct_profile_amt_id
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
                      AND    cur2.user_code   = p_trx_curr_code
                    )
  ORDER BY cpa.overall_credit_limit ;


  party_multi_limit_incl_rec party_multi_limit_incl_csr%ROWTYPE ;




BEGIN

 IF p_entity_type = 'SITE'
 THEN

  BEGIN
      OPEN site_multi_limit_no_incl_csr ;
      FETCH site_multi_limit_no_incl_csr
      INTO  site_multi_limit_no_incl_rec ;

         x_limit_curr_code  := site_multi_limit_no_incl_rec.currency_code;
         x_cust_acct_profile_amt_id    :=
                 site_multi_limit_no_incl_rec.cust_acct_profile_amt_id;
         x_overall_limit    := site_multi_limit_no_incl_rec.overall_limit;
         x_trx_limit        := site_multi_limit_no_incl_rec.trx_limit;

      CLOSE site_multi_limit_no_incl_csr ;


      IF x_limit_curr_code  IS NULL
      THEN
          OPEN site_multi_limit_incl_csr ;
          FETCH site_multi_limit_incl_csr
          INTO  site_multi_limit_incl_rec ;

          x_limit_curr_code  := site_multi_limit_incl_rec.currency_code;
          x_overall_limit    := site_multi_limit_incl_rec.overall_limit;
          x_trx_limit        := site_multi_limit_incl_rec.trx_limit;
         x_cust_acct_profile_amt_id    :=
                 site_multi_limit_incl_rec.cust_acct_profile_amt_id;

          CLOSE site_multi_limit_incl_csr ;

       END IF;
  END;

 ELSIF p_entity_type = 'CUSTOMER'
   THEN
    BEGIN
      --dbms_output.put_line(' into customer');
      OPEN cust_multi_limit_no_incl_csr ;
      FETCH cust_multi_limit_no_incl_csr
      INTO  cust_multi_limit_no_incl_rec ;

       x_limit_curr_code := cust_multi_limit_no_incl_rec.currency_code;
       x_overall_limit   := cust_multi_limit_no_incl_rec.overall_limit;
       x_trx_limit       := cust_multi_limit_no_incl_rec.trx_limit;
       x_cust_acct_profile_amt_id    :=
                 cust_multi_limit_no_incl_rec.cust_acct_profile_amt_id;


      --dbms_output.put_line(' cust_multi_limit_no_incl_csr ');
      --dbms_output.put_line(' x_limit_curr_code  ==> '
        -- || x_limit_curr_code  );
      --dbms_output.put_line(' x_cust_acct_profile_amt_id => '
         --      || x_cust_acct_profile_amt_id );

       CLOSE cust_multi_limit_no_incl_csr ;

       IF x_limit_curr_code  IS NULL
       THEN
          OPEN cust_multi_limit_incl_csr ;
          FETCH cust_multi_limit_incl_csr
          INTO   cust_multi_limit_incl_rec ;

          x_limit_curr_code :=  cust_multi_limit_incl_rec.currency_code;
          x_overall_limit   :=  cust_multi_limit_incl_rec.overall_limit;
          x_trx_limit       :=  cust_multi_limit_incl_rec.trx_limit;
          x_cust_acct_profile_amt_id    :=
                 cust_multi_limit_incl_rec.cust_acct_profile_amt_id;


      --dbms_output.put_line(' cust_multi_limit_incl_csr ');
      --dbms_output.put_line(' x_limit_curr_code  ==> '
        -- || x_limit_curr_code  );
      --dbms_output.put_line(' x_cust_acct_profile_amt_id => '
         --      || x_cust_acct_profile_amt_id );

          CLOSE cust_multi_limit_incl_csr ;

       END IF;
   END ;

 ELSIF p_entity_type = 'PARTY'
   THEN
    BEGIN
      OPEN party_multi_limit_no_incl_csr ;
      FETCH party_multi_limit_no_incl_csr
      INTO  party_multi_limit_no_incl_rec ;

       x_limit_curr_code := party_multi_limit_no_incl_rec.currency_code;
       x_overall_limit   := party_multi_limit_no_incl_rec.overall_limit;
       x_trx_limit       := party_multi_limit_no_incl_rec.trx_limit;
          x_cust_acct_profile_amt_id    :=
                 party_multi_limit_no_incl_rec.cust_acct_profile_amt_id;

       CLOSE party_multi_limit_no_incl_csr ;

       IF x_limit_curr_code  IS NULL
       THEN
          OPEN party_multi_limit_incl_csr ;
          FETCH party_multi_limit_incl_csr
          INTO   party_multi_limit_incl_rec ;

          x_limit_curr_code :=  party_multi_limit_incl_rec.currency_code;
          x_overall_limit   :=  party_multi_limit_incl_rec.overall_limit;
          x_trx_limit       :=  party_multi_limit_incl_rec.trx_limit;
          x_cust_acct_profile_amt_id    :=
                 party_multi_limit_incl_rec.cust_acct_profile_amt_id;

          CLOSE party_multi_limit_incl_csr ;

       END IF;
      END ;
END IF;

--dbms_output.put_line ( 'about to call Get_usage_rules ');
  Get_usage_rules(
        p_cust_acct_profile_amt_id    => x_cust_acct_profile_amt_id
       ,p_limit_curr_code             => x_limit_curr_code
       , x_global_exposure_flag      => x_global_exposure_flag
      , x_include_all_flag           => x_include_all_flag
      , x_usage_curr_tbl             => x_usage_curr_tbl
      , x_excl_curr_list             => x_excl_curr_list
      );

--dbms_output.put_line ( 'after  Get_usage_rules ');
--dbms_output.put_line ( 'x_include_all_flag => '|| x_include_all_flag );
--dbms_output.put_line ( 'x_global_exposure_flag => '||
  --      x_global_exposure_flag );
--dbms_output.put_line ( 'x_usage_curr_tbl.count' ||
   --    x_usage_curr_tbl.count );

 EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Get_Limit_Currency_usages'
      );
    END IF;
    RAISE;


END Get_Limit_Currency_usages ;



------------------------------------------------------------------------------
--  PROCEDURE  : Get_usage_rules
--  COMMENT    : Returns the Usage currencies associated with a given
--               profile amount currency
--
------------------------------------------------------------------------------
PROCEDURE Get_usage_rules(
 p_cust_acct_profile_amt_id    IN  NUMBER
,p_limit_curr_code             IN VARCHAR2
, x_global_exposure_flag       OUT  NOCOPY VARCHAR2
, x_include_all_flag           OUT NOCOPY VARCHAR2
, x_usage_curr_tbl             OUT NOCOPY HZ_CREDIT_USAGES_PKG.curr_tbl_type
, x_excl_curr_list             OUT NOCOPY VARCHAR2
)
IS

--------------------------------------------------------
--  Selecting the usage rule sets
--------------------------------------------------------
CURSOR   usage_rule_set_csr IS
  SELECT rset.credit_usage_rule_set_id ,
         rset.global_exposure_flag
  FROM   hz_credit_usages usg
    ,    hz_credit_usage_rule_sets_b rset
  WHERE  usg.cust_acct_profile_amt_id   = p_cust_acct_profile_amt_id
    AND  rset.credit_usage_rule_set_id = usg.credit_usage_rule_set_id ;

--------------------------------------------------------
--  This cursor identifies if the include all flag    --
--  is set for this usage rule set .                  --
--------------------------------------------------------

CURSOR   include_all_csr (c_credit_usage_rule_set_id IN NUMBER) IS
  SELECT 'X'
  FROM   hz_credit_usage_rules
  WHERE  credit_usage_rule_set_id = c_credit_usage_rule_set_id
  AND    usage_type = 'CURRENCY'
  AND    NVL(include_all_flag, 'N') = 'Y';

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
  AND    NVL(cur.exclude_flag,'N')    = 'Y';


include_all_rec         include_all_csr%rowtype;

l_limit_flag           VARCHAR2(1) := 'N';
i                      NUMBER := 0;
j                      NUMBER := 1;
l_return_status        NUMBER;
l_arrsize              NUMBER;

l_incl_curr_list       VARCHAR2(2000);
l_trx_curr_list        VARCHAR2(2000);
l_seperator            VARCHAR2(1) := '#';
l_currency             VARCHAR2(10);

l_start                NUMBER := 1;
l_end                  NUMBER := 1;

l_exclude_flag         VARCHAR2(1) := 'N' ;

BEGIN

  l_exclude_flag     := 'N' ;
  x_excl_curr_list   := NULL;
  x_include_all_flag := NULL ;
  x_usage_curr_tbl.DELETE ;
  x_global_exposure_flag := 'N' ;
  --------------------------------------
-- select the rule set and the associated rules
 -------------------------------------------

  FOR rule_set_rec IN usage_rule_set_csr
  LOOP
    IF NVL(rule_set_rec.global_exposure_flag,'N') = 'Y'
    THEN
      x_global_exposure_flag := 'Y' ;
    END IF;

    OPEN include_all_csr
      (rule_set_rec.credit_usage_rule_set_id);

    --- Include ALL

          FETCH include_all_csr
          INTO  include_all_rec;

          IF include_all_csr%FOUND
          THEN
            x_include_all_flag := 'Y';
          ELSE
            x_include_all_flag := 'N';
          END IF;

    CLOSE include_all_csr;

    --------------------------------------------------------
    -- identify the included currencies for each rule set --
    --------------------------------------------------------

    -- Include directly
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
   -- Excluded currency

    FOR excl_curr_rec
    IN  excl_curr_csr
          (rule_set_rec.credit_usage_rule_set_id)
    LOOP
            x_excl_curr_list :=
	    x_excl_curr_list || l_seperator || excl_curr_rec.user_code;

            l_exclude_flag := 'Y' ;
    END LOOP;

  END LOOP;
      -- End rule_set_rec

      -------------------------------------------------------
      -- first include all incl currencies (minus excl)    --
      -------------------------------------------------------

  IF x_include_all_flag = 'N'
  THEN
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

      IF NVL(INSTRB (x_excl_curr_list,l_currency,1,1),0) = 0
      THEN
          i := i + 1;
          x_usage_curr_tbl(i).usage_curr_code := l_currency;

         IF l_currency = p_limit_curr_code
          THEN
            l_limit_flag := 'Y';
          END IF;


      END IF;
    END LOOP;

  -------------------------------------
  -- if the limit currency code is   --
  -- not already included, do it now --
  -------------------------------------
    IF l_limit_flag = 'N'
    THEN
      i := NVL(i,0) + 1;
      x_usage_curr_tbl(i).usage_curr_code := p_limit_curr_code;
    END IF;


  END IF; -- Invlude ALL flag check

  IF  x_include_all_flag IS NULL
  THEN
       x_include_all_flag := 'N' ;
       x_excl_curr_list  := NULL ;
  END IF;


 EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'get_usage_rules'
      );
    END IF;
    RAISE;


END get_usage_rules ;



END HZ_CREDIT_USAGES_PKG;

/
